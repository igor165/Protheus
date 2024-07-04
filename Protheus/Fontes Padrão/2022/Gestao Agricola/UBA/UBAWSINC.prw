#include 'protheus.ch'
#include 'parmtype.ch'
 
/**---------------------------------------------------------------------
{Protheus.doc} UBIncSinc
Inclusão da tabela NC2 - Sincronizações do aplicativo

@param: cTpOpe, character, Tipo de Operação (1=Recebimento;2=Estorno;3=Classificação;4=Análise de contaminantes;5=Revisão da Classificação);6=Emb. Fisico;7=Carregamento
@param: cTpEnt, character, Tipo de entidade (1=Fardo;2=Bloco;3=Mala;4=Remessa)
@param: cTpFilt, character, Tipo de filtro (1=Código único;2=Intervalo)
@param: cCodUn, character, Código único (Filtro)
@param: cCodIni, character, Código inicial (Filtro Intervalo)
@param: cCodFin, character, Código final (Filtro Intervalo)
@param: cDataOpe, data, Data da operação (Apenas para o tipo de operação 1, 3 e 4)
@param: cHoraOpe, character, Hora da operação (Apenas para o tipo de operação 1 e 3)
@param: cUsuOpe, character, Usuário da operação (Apenas para o tipo de operação 1, 3, 4)
@param: cObsCon, character, Observação do Contaminante (Apenas para o tipo de operação 4)
@param: cTpClas, character, Tipo de Classificação (Apenas para os tipos de operação 3 e 5)
@param: cCodClas, character, Classificador (Apenas para o tipo de operação 3)
@param: cObs, memo, campo memo para armazenar informações da sincronização
@param: cValor Char, campo que armazena o valor de alteração enviado pelo app
@return: aChvNC2, array, Chave única da tabela NC2 (Filial + Data + Hora + Sequencia)
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBIncSinc(cTpOpe, cTpEnt, cTpFilt, cCodUn, cCodIni, cCodFin, cDataOpe, cHoraOpe, cUsuOpe, cObsCon, cTpClas, cCodClas, cObs, cValor)
	
	Local cFilNC2 := ""
	Local cData   := ""
	Local cHora   := ""
	Local aChvNC2 := {}	
	Local cSeqSin := ""
	Default cValor := ''
	
	DbSelectArea("NC2")
	
	If RecLock("NC2", .T.)
		
		NC2->NC2_FILIAL := FWxFilial("NC2")
		NC2->NC2_DATA   := dDatabase
		NC2->NC2_HORA   := Time()
		NC2->NC2_STATUS := "1" // 1=Sincronizado;2=Erro de sincronização
		NC2->NC2_TPOPE  := cTpOpe // 1=Recebimento;2=Estorno;3=Classificação;4=Análise de contaminantes;5=Revisão da Classificação;6=Benef. Físico;7=Carregamento
		NC2->NC2_TPENT  := cTpEnt // 1=Fardo;2=Bloco;3=Mala;4=Remessa;5=Romaneio 
		NC2->NC2_TPFILT := cTpFilt // 1=Código único;2=Intervalo 
		
		cFilNC2 := NC2->NC2_FILIAL
		cData   := NC2->NC2_DATA
		cHora   := NC2->NC2_HORA
		
		cSeqSin := GetSeqSinc(cFilNC2, cData, cHora)
		
		NC2->NC2_SEQUEN := cSeqSin
		
		If cTpFilt == "1"		
			NC2->NC2_CODUN := cCodUn
		Else
			NC2->NC2_CODINI := cCodIni
			NC2->NC2_CODFIN := cCodFin
		EndIf
		
		If cTpOpe $ "1|3|4"
			NC2->NC2_DATOPE := cToD(SUBSTR(cDataOpe, 7, 2) + "/" + SUBSTR(cDataOpe, 5, 2) + "/" + SUBSTR(cDataOpe, 1, 4))
			NC2->NC2_USUOPE := cUsuOpe
		EndIf 
		
		If cTpOpe $ "1|3"
			NC2->NC2_HOROPE := cHoraOpe
		EndIf
		
		If cTpOpe == "4"
			NC2->NC2_OBSCON := cObsCon
		EndIf
		
		If cTpOpe $ "3|5"
			NC2->NC2_TPCLAS := cTpClas
		EndIf
		
		If cTpOpe == "3"
			NC2->NC2_CODCLA := cCodClas
		EndIf
		
		NC2->NC2_CODALT := cValor 
		
		NC2->(MsUnlock())		
	EndIf
	
	aChvNC2 := {cFilNC2, cData, cHora, cSeqSin}

Return aChvNC2

/**---------------------------------------------------------------------
{Protheus.doc} UBIncCont
Inclusão da tabela NC3 - Contaminantes (Sincronização)

@param: cFilNC2, character, Filial da sincronização
@param: cDataNC2, character, Data da sincronização
@param: cHoraNC2, character, Hora da sincronização
@param: cSeqSinNC2, character, Sequencia da sincronização
@param: cSeqCont, character, Sequencial do erro da sicronização
@param: cCodCon, character, Código do contaminante
@param: cTpResult, character, Tipo de resultado do contaminante
@param: cResult, character, Resultado da análise de contaminante
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBIncCont(cFilNC2, cDataNC2, cHoraNC2, cSeqSinNC2, cSeqCont, cCodCon, cTpResult, cResult)

	Local cSeqNC3 := IIf(Empty(cSeqCont), StrZero(1, TamSX3("NC3_SEQUEN")[1]), cSeqCont)

	DbSelectArea("NC3")
		
	If RecLock("NC3", .T.)
		
		NC3->NC3_FILIAL := cFilNC2		
		NC3->NC3_DATA   := cDataNC2
		NC3->NC3_HORA   := cHoraNC2
		NC3->NC3_SEQSIN := cSeqSinNC2
		NC3->NC3_SEQUEN := cSeqNC3
		NC3->NC3_CODCON := cCodCon
		NC3->NC3_TPRES  := cTpResult
		NC3->NC3_RESULT := cResult
		
		cSeqCont := Soma1(cSeqNC3)
				
		NC3->(MsUnlock())		
	EndIf

Return .T.

/**---------------------------------------------------------------------
{Protheus.doc} GetSeqSinc
Buscar a sequencia da sincronização

@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@return: cSeqSin, character, Sequencia da sincronização
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Static Function GetSeqSinc(cFilSinc, cDataSinc, cHoraSinc)

	Local cSeqSin   := ""
	Local cAliasSin := ""
	Local cQuerySin := ""
	Local cData		:= ""
	
	cData := Year2Str(Year(cDataSinc)) + Month2Str(Month(cDataSinc)) + Day2Str(Day(cDataSinc))
		
    cAliasSin := GetNextAlias()
    cQuerySin := "   SELECT MAX(NC2.NC2_SEQUEN) AS SEQUEN "
    cQuerySin += "     FROM " + RetSqlName("NC2") + " NC2 "
    cQuerySin += "    WHERE NC2.NC2_FILIAL = '" + cFilSinc + "' "
    cQuerySin += "      AND NC2.NC2_DATA   = '" + cData + "' "
    cQuerySin += "      AND NC2.NC2_HORA   = '" + cHoraSinc + "' "
    cQuerySin += "      AND NC2.D_E_L_E_T_ = '' "
    
    cQuerySin := ChangeQuery(cQuerySin)
    MPSysOpenQuery(cQuerySin, cAliasSin)
    
    If (cAliasSin)->(!Eof())
    	cSeqSin := Soma1((cAliasSin)->SEQUEN)
    Else
    	cSeqSin := StrZero(1, TamSX3("NC2_SEQUEN")[1])
    EndIf

Return cSeqSin

/**---------------------------------------------------------------------
{Protheus.doc} GetSeqErr
Buscar a sequencia do erro da sincronização

@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@return: cSeqErr, character, Sequencia do erro de sincronização
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Static Function GetSeqErr(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)

	Local cSeqErr   := ""
	Local cAliasErr := ""
	Local cQueryErr := ""
	Local cData		:= ""
	
	cData := Year2Str(Year(cDataSinc)) + Month2Str(Month(cDataSinc)) + Day2Str(Day(cDataSinc))
		
    cAliasErr := GetNextAlias()
    cQueryErr := "   SELECT MAX(NC4.NC4_SEQUEN) AS SEQUEN "
    cQueryErr += "     FROM " + RetSqlName("NC4") + " NC4 "
    cQueryErr += "    WHERE NC4.NC4_FILIAL = '" + cFilSinc + "' "
    cQueryErr += "      AND NC4.NC4_DATA   = '" + cData + "' "
    cQueryErr += "      AND NC4.NC4_HORA   = '" + cHoraSinc + "' "
    cQueryErr += "      AND NC4.NC4_SEQSIN = '" + cSeqSinc + "' "
    cQueryErr += "      AND NC4.D_E_L_E_T_ = '' "
    
    cQueryErr := ChangeQuery(cQueryErr)
    MPSysOpenQuery(cQueryErr, cAliasErr)
    
    If (cAliasErr)->(!Eof())
    	cSeqErr := Soma1((cAliasErr)->SEQUEN)
    Else
    	cSeqErr := StrZero(1, TamSX3("NC4_SEQUEN")[1])
    EndIf

Return cSeqErr

/**---------------------------------------------------------------------
{Protheus.doc} UBIncErro
Inclusão do erro na sincronização

@param: cFilNC2, character, Filial da sincronização
@param: cDataNC2, character, Data da sincronização
@param: cHoraNC2, character, Hora da sincronização
@param: cSeqSinNC2, character, Sequencia da sincronização
@param: cCodErr, character, Código do erro
@param: cMsgErr, character, Mensagem do erro
@param: cTpEnt, character, Tipo de entidade (1=Fardo;2=Bloco;3=Mala;4=Remessa)
@param: cFilEnt, character, Filial da entidade
@param: cCodBar, character, Código de barras
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBIncErro(cFilNC2, cDataNC2, cHoraNC2, cSeqSinNC2, cCodErr, cMsgErr, cTpEnt, cFilEnt, cCodBar)

	Local cSeqNC4 := ""
	
	cSeqNC4 := GetSeqErr(cFilNC2, cDataNC2, cHoraNC2, cSeqSinNC2)
		
	DbSelectArea("NC4")
			
	If RecLock("NC4", .T.)
		
		NC4->NC4_FILIAL := cFilNC2
		NC4->NC4_DATA   := cDataNC2
		NC4->NC4_HORA   := cHoraNC2
		NC4->NC4_SEQSIN := cSeqSinNC2
		NC4->NC4_SEQUEN := cSeqNC4		
		NC4->NC4_STATUS := "1" // 1=Aguardando correção;2=Corrigido
		NC4->NC4_CODERR := cCodErr
		NC4->NC4_MSGERR := cMsgErr
		NC4->NC4_TPENT  := cTpEnt // 1=Fardo;2=Bloco;3=Mala;4=Remessa;5=Romaneio;6=Inst. Emb.
		NC4->NC4_FILENT := cFilEnt
		NC4->NC4_CODBAR := cCodBar
				
		NC4->(MsUnlock())		
	EndIf

Return .T.

/**---------------------------------------------------------------------
{Protheus.doc} UBCorErro
Correção do erro da sincronização - Alteração do status

@param: cFilNC4, character, Filial da sincronização
@param: cDataNC4, character, Data da sincronização
@param: cHoraNC4, character, Hora da sincronização
@param: cSeqNC4, character, Sequencia do erro
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBCorErro(cFilNC4, cDataNC4, cHoraNC4, cSeqNC4)

	cFilNC4  := PADR(cFilNC4, TamSX3("NC4_FILIAL")[1])
	cDataNC4 := PADR(cDataNC4, TamSX3("NC4_DATA")[1])
	cHoraNC4 := PADR(cHoraNC4, TamSX3("NC4_HORA")[1])
	cSeqNC4  := PADR(cSeqNC4, TamSX3("NC4_SEQUEN")[1])

	DbSelectArea("NC4")
	NC4->(DbSetOrder(1)) //NC4_FILIAL+NC4_DATA+NC4_HORA+NC4_SEQUEN
	If NC4->(DbSeek(cFilNC4+cDataNC4+cHoraNC4+cSeqNC4))
		
		If RecLock("NC4", .F.)
			
			NC4->NC4_STATUS := "2" // 1=Aguardando correção;2=Corrigido
			NC4->NC4_DATATU := dDatabase
			NC4->NC4_HORATU := Time()
			
			NC4->(MsUnlock())
		EndIf		
	EndIf

Return .T.

/**---------------------------------------------------------------------
{Protheus.doc} UBAltStSin
Alteração do status da sincronização

@param: cFilNC2, character, Filial da sincronização
@param: cDataNC2, character, Data da sincronização
@param: cHoraNC2, character, Hora da sincronização
@param: cSeqSinNC2, character, Sequencia da sincronização
@param: cStatus, character, Status da sincronização
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBAltStSin(cFilNC2, cDataNC2, cHoraNC2, cSeqSinNC2, cStatus)
	
	cFilNC2  := PADR(cFilNC2, TamSX3("NC2_FILIAL")[1])	
	cHoraNC2 := PADR(cHoraNC2, TamSX3("NC2_HORA")[1])
	
	cDataNC2 := Year2Str(Year(cDataNC2)) + Month2Str(Month(cDataNC2)) + Day2Str(Day(cDataNC2))
	
	DbSelectArea("NC2")
	NC2->(DbSetOrder(1)) //NC2_FILIAL+NC2_DATA+NC2_HORA+NC2_SEQUEN
	If NC2->(DbSeek(cFilNC2+cDataNC2+cHoraNC2+cSeqSinNC2))
		
		If RecLock("NC2", .F.)
			
			NC2->NC2_STATUS := cStatus // 1=Sincronizado;2=Erro de sincronização		
			NC2->(MsUnlock())
		EndIf		
	EndIf
	
Return .T.

/**---------------------------------------------------------------------
{Protheus.doc} UBIncFrd
Inclusão da tabela NCW - Fardos (Sincronização)

@param: cFilNC2, character, Filial da sincronização
@param: cDataNC2, character, Data da sincronização
@param: cHoraNC2, character, Hora da sincronização
@param: cSeqSinNC2, character, Sequencia da sincronização
@param: cSeqFrd, character, Sequencial do fardo
@param: cSafra, character, Safra do fardo
@param: cEtiqu, character, Etiqueta do fardo
@param: cBloco, character, Bloco do fardo
@param: cCodOpe, character, Operação a ser realizada (1=Vinculo/2=Desvinculo)
@author: francisco.nunes
@since: 15/01/2019
---------------------------------------------------------------------**/
Function UBIncFrd(cFilNC2, cDataNC2, cHoraNC2, cSeqSinNC2, cSeqFrd, cSafra, cEtiqu, cBloco, cCodOpe)

	Local cSeqNCW := IIf(Empty(cSeqFrd), StrZero(1, TamSX3("NCW_SEQUEN")[1]), cSeqFrd)
	
	DbSelectArea("NCW")		
	If RecLock("NCW", .T.)
		
		NCW->NCW_FILIAL := cFilNC2		
		NCW->NCW_DATA   := cDataNC2
		NCW->NCW_HORA   := cHoraNC2
		NCW->NCW_SEQSIN := cSeqSinNC2
		NCW->NCW_SEQUEN := cSeqNCW	
		NCW->NCW_SAFRA  := cSafra
		NCW->NCW_ETIQ   := cEtiqu
		NCW->NCW_BLOCO  := cBloco
		NCW->NCW_TPOPER := cCodOpe
		
		cSeqFrd := Soma1(cSeqNCW)
				
		NCW->(MsUnlock())		
	EndIf

Return .T.