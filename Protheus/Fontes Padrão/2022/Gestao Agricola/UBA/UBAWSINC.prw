#include 'protheus.ch'
#include 'parmtype.ch'
 
/**---------------------------------------------------------------------
{Protheus.doc} UBIncSinc
Inclus�o da tabela NC2 - Sincroniza��es do aplicativo

@param: cTpOpe, character, Tipo de Opera��o (1=Recebimento;2=Estorno;3=Classifica��o;4=An�lise de contaminantes;5=Revis�o da Classifica��o);6=Emb. Fisico;7=Carregamento
@param: cTpEnt, character, Tipo de entidade (1=Fardo;2=Bloco;3=Mala;4=Remessa)
@param: cTpFilt, character, Tipo de filtro (1=C�digo �nico;2=Intervalo)
@param: cCodUn, character, C�digo �nico (Filtro)
@param: cCodIni, character, C�digo inicial (Filtro Intervalo)
@param: cCodFin, character, C�digo final (Filtro Intervalo)
@param: cDataOpe, data, Data da opera��o (Apenas para o tipo de opera��o 1, 3 e 4)
@param: cHoraOpe, character, Hora da opera��o (Apenas para o tipo de opera��o 1 e 3)
@param: cUsuOpe, character, Usu�rio da opera��o (Apenas para o tipo de opera��o 1, 3, 4)
@param: cObsCon, character, Observa��o do Contaminante (Apenas para o tipo de opera��o 4)
@param: cTpClas, character, Tipo de Classifica��o (Apenas para os tipos de opera��o 3 e 5)
@param: cCodClas, character, Classificador (Apenas para o tipo de opera��o 3)
@param: cObs, memo, campo memo para armazenar informa��es da sincroniza��o
@param: cValor Char, campo que armazena o valor de altera��o enviado pelo app
@return: aChvNC2, array, Chave �nica da tabela NC2 (Filial + Data + Hora + Sequencia)
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
		NC2->NC2_STATUS := "1" // 1=Sincronizado;2=Erro de sincroniza��o
		NC2->NC2_TPOPE  := cTpOpe // 1=Recebimento;2=Estorno;3=Classifica��o;4=An�lise de contaminantes;5=Revis�o da Classifica��o;6=Benef. F�sico;7=Carregamento
		NC2->NC2_TPENT  := cTpEnt // 1=Fardo;2=Bloco;3=Mala;4=Remessa;5=Romaneio 
		NC2->NC2_TPFILT := cTpFilt // 1=C�digo �nico;2=Intervalo 
		
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
Inclus�o da tabela NC3 - Contaminantes (Sincroniza��o)

@param: cFilNC2, character, Filial da sincroniza��o
@param: cDataNC2, character, Data da sincroniza��o
@param: cHoraNC2, character, Hora da sincroniza��o
@param: cSeqSinNC2, character, Sequencia da sincroniza��o
@param: cSeqCont, character, Sequencial do erro da sicroniza��o
@param: cCodCon, character, C�digo do contaminante
@param: cTpResult, character, Tipo de resultado do contaminante
@param: cResult, character, Resultado da an�lise de contaminante
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
Buscar a sequencia da sincroniza��o

@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@return: cSeqSin, character, Sequencia da sincroniza��o
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
Buscar a sequencia do erro da sincroniza��o

@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
@return: cSeqErr, character, Sequencia do erro de sincroniza��o
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
Inclus�o do erro na sincroniza��o

@param: cFilNC2, character, Filial da sincroniza��o
@param: cDataNC2, character, Data da sincroniza��o
@param: cHoraNC2, character, Hora da sincroniza��o
@param: cSeqSinNC2, character, Sequencia da sincroniza��o
@param: cCodErr, character, C�digo do erro
@param: cMsgErr, character, Mensagem do erro
@param: cTpEnt, character, Tipo de entidade (1=Fardo;2=Bloco;3=Mala;4=Remessa)
@param: cFilEnt, character, Filial da entidade
@param: cCodBar, character, C�digo de barras
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
		NC4->NC4_STATUS := "1" // 1=Aguardando corre��o;2=Corrigido
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
Corre��o do erro da sincroniza��o - Altera��o do status

@param: cFilNC4, character, Filial da sincroniza��o
@param: cDataNC4, character, Data da sincroniza��o
@param: cHoraNC4, character, Hora da sincroniza��o
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
			
			NC4->NC4_STATUS := "2" // 1=Aguardando corre��o;2=Corrigido
			NC4->NC4_DATATU := dDatabase
			NC4->NC4_HORATU := Time()
			
			NC4->(MsUnlock())
		EndIf		
	EndIf

Return .T.

/**---------------------------------------------------------------------
{Protheus.doc} UBAltStSin
Altera��o do status da sincroniza��o

@param: cFilNC2, character, Filial da sincroniza��o
@param: cDataNC2, character, Data da sincroniza��o
@param: cHoraNC2, character, Hora da sincroniza��o
@param: cSeqSinNC2, character, Sequencia da sincroniza��o
@param: cStatus, character, Status da sincroniza��o
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
			
			NC2->NC2_STATUS := cStatus // 1=Sincronizado;2=Erro de sincroniza��o		
			NC2->(MsUnlock())
		EndIf		
	EndIf
	
Return .T.

/**---------------------------------------------------------------------
{Protheus.doc} UBIncFrd
Inclus�o da tabela NCW - Fardos (Sincroniza��o)

@param: cFilNC2, character, Filial da sincroniza��o
@param: cDataNC2, character, Data da sincroniza��o
@param: cHoraNC2, character, Hora da sincroniza��o
@param: cSeqSinNC2, character, Sequencia da sincroniza��o
@param: cSeqFrd, character, Sequencial do fardo
@param: cSafra, character, Safra do fardo
@param: cEtiqu, character, Etiqueta do fardo
@param: cBloco, character, Bloco do fardo
@param: cCodOpe, character, Opera��o a ser realizada (1=Vinculo/2=Desvinculo)
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