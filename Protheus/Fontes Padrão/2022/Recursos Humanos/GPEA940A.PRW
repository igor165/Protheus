#include 'PROTHEUS.CH'
#include 'parmtype.ch'
#include 'GPEA940A.CH'

/*/{Protheus.doc} GPEA940A
	Atualização da SQG de acordo com Termo de Consentimento Vigente via job
	@type	Function
	@author	isabel.noguti
	@since	05/03/2020
/*/
Function GPEA940A(aParam)
	Local cHrIni	:= Time()
	Local cSegs		:= ""
	Local aVigente	:= {}
	Local cEmpJob	:= ""
	Local cFilJob	:= ""

	If Len(aParam)>0
		cEmpJob := aParam[1]
		cFilJob := aParam[2]
	else
		cEmpJob := cEmpAnt
		cFilJob := cFilAnt
	EndIf
	RpcSetType(3)
	RPCsetEnv(cEmpJob, cFilJob)

	ConOut(STR0021 + cEmpJob + " " + cFilJob)	//"Iniciando processamento de atualização dos aceites dos candidatos para: "
	If LockByName("GPEA940A"+cEmpJob+cFilJob,.T.,.T.,.T.)

		aVigente := fTCVigente()
		If !Empty(aVigente)
			If fAtuAceite(aVigente[1])
				ConOut(STR0022)	//"Status de aceite dos candidatos atualizados."
			Else
				ConOut(STR0023)	//"Sem registro de aceite de candidato a ser atualizado."
			EndIf
		Else
			ConOut(STR0024)		//"Termo de consentimento vigente não encontrado; Status de aceite nÃ£o serÃ£o processados."
		EndIf

		UnLockByName("GPEA940A"+cEmpJob+cFilJob,.T.,.T.,.T.)
	Else
		ConOut(STR0025)			//"Rotina sendo executada em outro processo."
	EndIf
	ConOut(STR0026)				//"Finalizando o processamento de atualização dos aceites dos candidatos."
	If (cSegs := ElapTime( cHrIni, Time() )) < "00:01:00"
		Sleep( (60 - Val(Substr(cSegs,7,2))) * 1000 )	//Evitar processamentos dentro do mesmo minuto
	EndIf

Return

/*/{Protheus.doc} fTCVigente
	Verificação de Termo de Consentimento Vigente
	@type	Function
	@author	isabel.noguti
	@since	04/03/2020
	@return	aVigente, Array com o código e caminho do pdf de Consentimento vigente
/*/
Function fTCVigente()
	Local aVigente	:= {}
	Local cAliasRI2	:= GetNextAlias()
	Local dDataAtu	:= dDatabase
	Local nHoraAtu	:= Val(StrTran(Substr(time(),1,5),":","."))

	If ChkFile("RI2")
		BeginSql Alias cAliasRI2
			SELECT	RI2_CODIGO, RI2.RI2_ARQUIV
			FROM	%table:RI2% RI2
			WHERE	RI2.RI2_FILIAL = %exp:xFilial("RI2")%
					AND ( RI2.RI2_DTINI < %exp:dDataAtu% OR ( RI2.RI2_DTINI = %exp:dDataAtu% AND RI2.RI2_HRINI <= %exp:nHoraAtu% ) )
					AND ( RI2_DTFIM = '' OR RI2_DTFIM > %exp:dDataAtu% OR ( RI2_DTFIM = %exp:dDataAtu% AND RI2.RI2_HRFIM >= %exp:nHoraAtu% ) )
					AND RI2.%notDel%
		EndSql

		If !(cAliasRI2)->(Eof())
			aVigente := { (cAliasRI2)->RI2_CODIGO, (cAliasRI2)->RI2_ARQUIV }
		EndIf
	EndIf

	IF Select(cAliasRI2) > 0
		(cAliasRI2)->(DBCloseArea())
	ENDIF

Return aVigente

/*/{Protheus.doc} fAtuAceite
	Atualiza Status dos registros da SQG ao entrar em vigência um novo termo de consentimento
	@type	Function
	@author	isabel.noguti
	@since	03/03/2020
	@param	cCodigo, characters, código do termo vigente
	@param	cFilRI2, characters, Filial a ser atualizada
	@return	lRet, boolean, retorna se algum registro foi atualizado
/*/
Function fAtuAceite( cCodigo, cFilRI2 )
	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()

	Default cCodigo	:= ""
	Default cFilRI2	:= xFilial("RI2")	//cFilAnt

	Begin Transaction
		DbSelectArea("SQG")

		If SQG->(ColumnPos("QG_ACEITE")) > 0 .And. ChkFile("RI3")

			BeginSql Alias cAliasQry
				SELECT	SQG.QG_FILIAL, SQG.QG_CURRIC
				FROM	%table:SQG% SQG
				WHERE	SQG.QG_FILIAL = %exp:xFilial("SQG", cFilRI2)%
					AND SQG.QG_ACEITE <> '1'
					AND SQG.%notDel%
					AND SQG.QG_FILIAL || SQG.QG_CURRIC NOT IN (SELECT RI3_USER FROM %table:RI3% RI3
															WHERE RI3_FILIAL = %exp:cFilRI2% AND RI3_CODVER = %exp:cCodigo% AND RI3.%notDel%)
			EndSql

			SQG->( DbSetOrder(1) )
			While (cAliasQry)->(!Eof())
				If SQG->(DbSeek( (cAliasQry)->QG_FILIAL + (cAliasQry)->QG_CURRIC ) )
					RecLock("SQG",.F.)
					Replace QG_ACEITE With "1"
					MsUnlock()
					lRet := .T.
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo

		EndIf
		(cAliasQry)->(DbCloseArea())
		SQG->( DbCloseArea() )
	End Transaction

	RestArea(aArea)
Return lRet