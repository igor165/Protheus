#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA370.CH"

// Definições para o controle de Semaforo
#DEFINE F74CARTEIRA 1
#DEFINE F74DTDE 2
#DEFINE F74DTATE 3
#DEFINE F74FILDE 4
#DEFINE F74FILATE 5


STATIC _MSSQL7 := (ALLTRIM(UPPER(TCGetDB())) $ "MSSQL7")
Static _lBlind := IsBlind()
Static __lConoutR := FindFunction("CONOUTR")

//Dummy Function
Function FINBCCTblTmp()
Return NIL

// Init Class Implementation -----------------------------------------------------------------------
CLASS FINBCCTblTmp FROM LongNameClass
	DATA aIndexes
	DATA aFields
	DATA cChave
	DATA cClassName
	DATA cRealName
	DATA cAlias
	DATA oFWTMPTBL

	METHOD AddIndex(cOrd,cKey)
	METHOD Create(lShared)
	METHOD Delete()
	METHOD GetAlias()
	METHOD GetRealName()
	METHOD New(cTabName,aFields) CONSTRUCTOR
	METHOD SetFields(aFields)
    METHOD Zap()
ENDCLASS

/*/{Protheus.doc} New()
Método Construtor da classe FINBCCTblTmp

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@param cAlias, character, Alias da tabela a ser pesquisada
@param aFields, array, Lista de Campos para estrutura da tabela
@return nil, nil, void
/*/
METHOD New(cAlias,aFields) CLASS FINBCCTblTmp
	::aFields		:= aFields
	::aIndexes		:= {}
	::cAlias		:= cAlias
	::cClassName	:= 'FINBCCTblTmp'
	::cRealName		:= ''
RETURN NIL

/*/{Protheus.doc} AddIndex()
Método da classe FINBCCTblTmp. Adiciona indice à tabela temporária

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@param cOrd, character, Código ordenador de indice
@param cKey, Character, String contendo os campos da ordem separados por vírgula
@return nil, nil, void
/*/
METHOD AddIndex(cOrd,cKey) CLASS FINBCCTblTmp
	DEFAULT cOrd := ''
	DEFAULT cKey := ''
	
	IF !EMPTY(cOrd) .AND. !EMPTY(cKey)
		AADD(::aIndexes, {cOrd, cKey})
	ENDIF
RETURN NIL

/*/{Protheus.doc} Create()
Método da classe FINBCCTblTmp. Criar a tabela no banco de dados.

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@param lShared, logico, Compartilhado ou não
@return nil, nil, void
/*/
METHOD Create(lShared) CLASS FINBCCTblTmp
	LOCAL nI	as Numeric
	DEFAULT lShared := .F.

	::Delete()	//Deleta a tabela temporaria no banco de dados, caso ja exista

	If !_MSSQL7 .OR. lShared
		MsCreate(::cAlias,::aFields,'TOPCONN')
		Sleep(100)
		dbUseArea(.T.,'TOPCONN',::cAlias,::cAlias,.T.,.F.)
		//Cria o Indice
		For nI := 1 To LEN(::aIndexes)
			DbCreateIndex(::cAlias+STRZERO(nI,2), ::aIndexes[nI,2], {|| ::aIndexes[nI,2]})
		Next nI
	Else
		::oFWTMPTBL := FWTemporaryTable():New(::cAlias,::aFields)
		For nI := 1 To LEN(::aIndexes)
			::oFWTMPTBL:AddIndex(::aIndexes[nI,1], StrToKarr(::aIndexes[nI,2],"+"))
		Next nI
		::oFWTMPTBL:Create()
		::cRealName := ::oFWTMPTBL:GetRealName()
	EndIf
RETURN NIL

/*/{Protheus.doc} Delete()
Método da classe FINBCCTblTmp. Apagar a tabela no banco de dados.

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@return nil, nil, void
/*/
METHOD Delete() CLASS FINBCCTblTmp
	If !EMPTY(::oFWTMPTBL)
		::oFWTMPTBL:Delete()
		::oFWTMPTBL := NIL
	Else
		IF SELECT(::cAlias) > 0
			(::cAlias)->(DBCLOSEAREA())
		ENDIF
		If TCCanOpen(::cAlias)
			TcDelFile(::cAlias)
		EndIf 
	EndIf
RETURN NIL

/*/{Protheus.doc} Getalias()
Método da classe FINBCCTblTmp. Obtem o alias da tabela.

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@return cAlias, character, O alias da tabela temporária
/*/
METHOD GetAlias() CLASS FINBCCTblTmp
RETURN ::cAlias

/*/{Protheus.doc} GetRealName()
Método da classe FINBCCTblTmp. Obtem o nome da tabela.

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@return cRet, character, O nome da tabela temporária
/*/
METHOD GetRealName() CLASS FINBCCTblTmp
	LOCAL cRet as Character
	cRet := If(!EMPTY(::cRealName),::cRealName,::cAlias)
RETURN cRet

/*/{Protheus.doc} SetFields()
Método da classe FINBCCTblTmp. Campos da tabela no banco de dados.

@author Norberto M de Melo
@since 25/08/2020
@version 1.0

@param aFields, array, Estrutura de campos da tabela temporaria
@return nil, nil, void
/*/
METHOD SetFields(aFields) CLASS FINBCCTblTmp
	::aFields := ACLONE(aFields)
RETURN NIL

/*/{Protheus.doc} Zap()
Método da classe FINBCCTblTmp. Remove todos os registros da tabela representada pela classe.

@author Norberto M de Melo
@since 16/07/2022
@version 1.0

@return nil, nil, void
/*/
METHOD Zap() CLASS FINBCCTblTmp
    LOCAL nOrder AS NUMERIC
    nOrder := (::cAlias)->(IndexOrd())

	TcSqlExec("DELETE FROM "+ ::GetRealName())
    CTBConout('[CLASS FINBCCTblTmp METHOD ]['+PROCNAME()+"]:[TCSQLEXEC][" + TcSQLError() + ']')
    (::cAlias)->(dbSetOrder(0))         //- mudar para a ordem de recno
    (::cAlias)->(DbSetFilter( { || .T.  }, "1=1" ) )
    (::cAlias)->(DbClearFilter())
    (::cAlias)->(dbGotop())             //- envio para o topo da tabela
    (::cAlias)->(dbSetOrder(nOrder))    //- retorna a ordem salva
    CTBConout('[CLASS FINBCCTblTmp METHOD ]['+PROCNAME()+"]:[EOF][" + cValToChar((::cAlias)->(EOF())) + ']')
RETURN NIL
// End Class Implementation ------------------------------------------------------------------------

//-------------------------------------------------------------------------
/*/{Protheus.doc} ClearFlagE5

Função para Limpeza de Flag das tabelas FK1,FK2,FK5 e SE5.
Utilizada pelo moduto SIGACTB.

@author Luiz Henrique
@since  06/01/2020
@param  cAliasOrig, char, Tabela de origem do rastreio contábil.
@version 12
/*/
//-------------------------------------------------------------------------  
Function ClearFlagE5(cAliasOrig)

	Local lLimpaFlag 	:= .F.
	Local cTamIdORI  	:= Space(TAMSX3("FKA_IDORIG")[1])
	Local cIdOrig 	 	:= cTamIdORI
	Local cKeySE5		:= ""

	DEFAULT cAliasOrig := ""
	
	// Limpa flags da tabelas nos cadastros de multiplas natureza (Rateio FIN)
	If cAliasOrig $ "SEZ|SEV|SE1|SE2|SE5"
		CTBApLAMN(cAliasOrig)						
	EndIf

	/// VERIFICA REGISTROS DO SE5 RELACIONADOS A BAIXA DE TITULOS (JUROS/MULTA/DESCONTO)
	If (cAliasOrig $ "SE5|SEZ" .and. !Empty(SE5->E5_NUMERO)) .OR.  ( cAliasOrig == "SE1" .AND. Alltrim(SE1->E1_TIPO) == 'RA')

		cKeySE5 := SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ)
					
		FK1->(dbSetOrder(1)) //FK1_FILIAL, FK1_IDFK1, R_E_C_N_O_, D_E_L_E_T_
		FK2->(dbSetOrder(1)) //FK2_FILIAL, FK2_IDFK2, R_E_C_N_O_, D_E_L_E_T_
		FKA->(dbSetOrder(3)) //FKA_FILIAL, FKA_TABORI, FKA_IDORIG, R_E_C_N_O_, D_E_L_E_T_
		FK5->(dbSetOrder(1)) //FK5_FILIAL, FK5_IDMOV, R_E_C_D_E_L_
		SE5->(dbSetOrder(7)) //E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
		if SE5->(MsSeek(cKeySE5,.T.))

			While SE5->(!Eof()) .and.cKeySE5 == SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ)

				lLimpaFlag := !Empty(SE5->E5_LA)

				If lLimpaFlag
					If (CV3->CV3_LP == '531') .And. (SE5->(RecNo()) != Int(Val(CV3->CV3_RECORI)))
						lLimpaFlag := .F.
					EndIf
				EndIf

				If lLimpaFlag

					//Baixas a Receber
					If SE5->E5_TABORI = 'FK1'
						If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))	
							If FK1->FK1_LA == "S"
								FK1->(RecLock("FK1",.F.))
								FK1->FK1_LA := ""
								FK1->(MsUnlock())
							EndIf
						Endif	
					//Baixas a Pagar
					ElseIf SE5->E5_TABORI = 'FK2'
						If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
							If FK2->FK2_LA == "S"	
								FK2->(RecLock("FK2",.F.))
								FK2->FK2_LA := ""
								FK2->(MsUnlock())
							EndIf
						Endif
					//Movimentação bancaria.
					ElseIf SE5->E5_TABORI = 'FK5'
						//Posiciona a FKA com base no IDORIG da SE5 posicionada
						If FKA->(dbseek(SE5->E5_FILIAL+"FK5"+SE5->E5_IDORIG))	
							cIdOrig := FKA->FKA_IDORIG
						Endif

						If !Empty(cIdOrig) 
							If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
								If FK5->FK5_LA == "S"	
									FK5->(RecLock("FK5",.F.))
									FK5->FK5_LA := ""
									FK5->(MsUnlock())
								EndIf
							Endif
						EndIf	
					EndIf
					//Atualiza a flag da SE5
					Reclock("SE5")
						REPLACE E5_LA With ''
					MsUnlock()

				EndIf

				CTBApLAMN(cAliasOrig)			// Limpa flags da tabelas nos cadastros de multiplas natureza (Rateio FIN)
				
				cIdOrig := cTamIdORI

				SE5->(dbSkip())
			EndDo
		EndIf
	EndIf	

Return


//-------------------------------------------------------------------------
/*/{Protheus.doc} CTBApLAMN

Apaga flag de contabilizacao nos movimentos com Rateio de 
Multiplas Naturezas ou Multiplas Naturezas por C.Custo 

@author Marcos S. Lobo
@since  01/28/06
@version 12
/*/
//-------------------------------------------------------------------------  

Function CTBApLAMN(cAliasPos)

	Local aAreaOri		:= GetArea()
	Local aAreaMN
	Local cFilSEV		:= xFilial("SEV")
	Local cFilSEZ		:= xFilial("SEZ")
	Local cAliasORI 	:= ""
	Local cTamIdORI 	:= Space(TAMSX3("FKA_IDORIG")[1])
	Local cTamIdPRO		:= Space(TAMSX3("FKA_IDPROC")[1])
	Local cIdOrig 		:= cTamIdORI 
	Local cIdProc		:= cTamIdPRO 
	Local cChaveSev 	:= ""
	Local cChaveSez 	:= ""
	Local lSEVLimpaFlag := .F.

	DEFAULT cAliasPos := ""

	cAliasORI := cAliasPos

	If !Empty(cAliasPos)
		aAreaMN := (cAliasPos)->(GetArea())
	EndIf

	If cAliasPos == "SEZ"			/// SE RASTREAMENTO ESTIVER PELO SEZ LOCALIZA O TÍTULO DE ORIGEM
		If SEZ->EZ_RECPAG == "R"	/// SE FOR REGISTRO DO CONTAS A RECEBER
			If SEZ->EZ_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE1")
				dbSetorder(2)
				If MsSeek(xFilial("SE1")+SEZ->(EZ_CLIfOR+EZ_LOJA+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO),.F.)
					If !Empty(SE1->E1_LA)
						RecLock("SE1",.F.)
						E1_LA := ""
						SE1->(MsUnlock())
					EndIf
					cAliasPos := "SE1"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
				EndIf

			ElseIf SEZ->EZ_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA)
				If !Empty(SEZ->EZ_SEQ)
					cChaveE5+=SEZ->EZ_SEQ
				EndIf

				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEZ->EZ_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK1 com base no IDORIG da SE5 posicionada
					FK1->(dbSelectArea("FK1"))							
					FK1->(dbSetOrder(1))
					If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK1->FK1_LA == "S"	
							FK1->(RecLock("FK1",.F.))
							FK1->FK1_LA := ""
							FK1->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK1"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							Endif
							FKA->(dbskip())

						Enddo 
					
					EndIf

						//Posiciona a FK5 com base no IDORIG da FKA posicionada
					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						Endif
					Endif	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf

			EndIf
		Else
			If SEZ->EZ_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE2")
				dbSetorder(1)
				If MsSeek(xFilial("SE2")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA),.F.)
					RecLock("SE2",.F.)
					E2_LA := ""
					SE2->(MsUnlock())
					cAliasPos := "SE2"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
				EndIf

			ElseIf SEZ->EZ_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA)
				If !Empty(SEZ->EZ_SEQ)
					cChaveE5+=SEZ->EZ_SEQ
				EndIf

				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEZ->EZ_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf
					
					//Posiciona a FK2 com base no IDORIG da SE5 posicionada
					FK2->(dbSelectArea("FK2"))							
					FK2->(dbSetOrder(1))
					If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK2->FK2_LA == "S"	
							FK2->(RecLock("FK2",.F.))
							FK2->FK2_LA := ""
							FK2->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK2"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							Endif
							FKA->(dbskip())

						Enddo 

					EndIf

					//Posiciona a FK5 com base no IDORIG da FKA posicionada
					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						Endif
					Endif	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf

			EndIf
		EndIf
	ElseIf cAliasPos == "SEV"			/// SE RASTREAMENTO ESTIVER PELO SEV LOCALIZA O TÍTULO DE ORIGEM
		If SEV->EV_RECPAG == "R"	/// SE FOR REGISTRO DO CONTAS A RECEBER
			If SEV->EV_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE1")
				dbSetorder(2)
				If MsSeek(xFilial("SE1")+SEV->(EV_CLIfOR+EV_LOJA+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO),.F.)
					RecLock("SE1",.F.)
					E1_LA := ""
					SE1->(MsUnlock())
					cAliasPos := "SE1"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
				EndIf

			ElseIf SEV->EV_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA)
				If !Empty(SEV->EV_SEQ)
					cChaveE5+=SEV->EV_SEQ
				EndIf

				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEV->EV_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK1 com base no IDORIG da SE5 posicionada
					FK1->(dbSelectArea("FK1"))							
					FK1->(dbSetOrder(1))
					If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK1->FK1_LA == "S"		
							FK1->(RecLock("FK1",.F.))
							FK1->FK1_LA := ""
							FK1->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK1"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							EndIf
							FKA->(dbskip())

						Enddo 	

					EndIf

					//Posiciona a FK5 com base no IDORIG da FKA posicionada

					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						EndIf
					EndIf	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf

			EndIf
		Else
			If SEV->EV_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE2")
				dbSetorder(1)
				If MsSeek(xFilial("SE2")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA),.F.)
					RecLock("SE2",.F.)
					E2_LA := ""
					SE2->(MsUnlock())
					cAliasPos := "SE2"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
				EndIf

			ElseIf SEV->EV_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA)
				If !Empty(SEV->EV_SEQ)
					cChaveE5+=SEV->EV_SEQ
				EndIf
				
				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEV->EV_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK2 com base no IDORIG da SE5 posicionada
					FK2->(dbSelectArea("FK2"))							
					FK2->(dbSetOrder(1))
					If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK2->FK2_LA == "S"	
							FK2->(RecLock("FK2",.F.))
							FK2->FK2_LA := ""
							FK2->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK2"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							Endif
							FKA->(dbskip())

						Enddo

					EndIF
					
					//Posiciona a FK5 com base no IDORIG da FKA posicionada
					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						Endif
					EndIf	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TÍTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf		                                                                                   // |
			EndIf                                                                                              // |
		EndIf                                                                                                  // |
	EndIf		/// If DE MULTIPLA NATUREZA ESTA NA MESMA LINHA (CASO HABILITAR REMARCAÇÃO DE TODOS SEV E SEZ)----|

	
	If cAliasPos == "SE1"				/// Rateio no Contas a Receber
	
		cChaveSev := RetChaveSev("SE1")
		cChaveSez := RetChaveSev("SE1",,"SEZ")

		DbSelectArea("SEV")
		// Se utiliza multiplas naturezas, contabiliza pelo SEV
		If SE1->E1_MULTNAT=="1" .And. SEV->(MsSeek(cChaveSev))
			DbSelectArea("SEV")
			dbSetOrder(2)
			While SEV->(!Eof()) .and.;
				cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT) == ;
				cChaveSev+"1"

				lSEVLimpaFlag := .F.
				If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1" // Rateou multinat por c.custo

					dbSelectArea("SEZ")
					dbSetOrder(4)
					MsSeek(cChaveSeZ+SEV->EV_NATUREZ) // Posiciona no arquivo de Rateio C.Custo da MultiNat

					While SEZ->(!Eof()) .and.;
						cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT);
						== cChaveSeZ+SEV->EV_NATUREZ+"1"

						If SEZ->(RECNO() <> aAreaOri[3])
							SEZ->(DBSKIP())
							Loop
						EndIF
													
						lSEVLimpaFlag := .T.
						If !Empty(SEZ->EZ_LA)
							RecLock("SEZ")
							SEZ->EZ_LA := ""
							SEZ->(MsUnlock())
						EndIf

						dbSkip()
					Enddo

					DbSelectArea("SEV")

				EndIf

				If ((aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO())) .OR.;
					(aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .OR.;
					(aAreaOri[1] == 'SE1' .and. SEV->EV_RATEICC == "2")) .AND.;
					!Empty(SEV->EV_LA)
					RecLock("SEV")
					SEV->EV_LA := ""
					SEV->(MsUnlock())
				EndIf


				DbSelectArea("SEV")
				DbSkip()
			Enddo
		EndIf
	
	ElseIf cAliasPos == "SE2"			/// Rateio no Contas a Pagar
	
		If SE2->E2_RATEIO != "S"
			cChaveSev := RetChaveSev("SE2")
			cChaveSeZ := RetChaveSev("SE2",,"SEZ")
			DbSelectArea("SEV")
			// Se utiliza multiplas naturezas, contabiliza pelo SEV
			If SE2->E2_MULTNAT == "1" .And. MsSeek(cChaveSev)
				DbSelectArea("SEV")
				dbSetOrder(2)
				While SEV->(!Eof()) .and.;
						cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT);
						== cChaveSev+"1"

					lSEVLimpaFlag := .F.
					If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1" // Rateou multinat por c.custo

						dbSelectArea("SEZ")
						dbSetOrder(4)
						MsSeek(cChaveSeZ+SEV->EV_NATUREZ) // Posiciona no arquivo de Rateio C.Custo da MultiNat

						While SEZ->(!Eof()) .and.;
							cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT);
							== cChaveSeZ+SEV->EV_NATUREZ+"1"

							If SEZ->(RECNO() <> aAreaOri[3])
								SEZ->(DBSKIP())
								Loop
							EndIF
							
							lSEVLimpaFlag := .T.
							If !Empty(SEZ->EZ_LA)
								RecLock("SEZ")
								SEZ->EZ_LA := ""
								SEZ->(MsUnlock())
							EndIf
							dbSkip()
						Enddo
					EndIf

					If ((aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO())) .OR.;
						(aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .Or.;
						(aAreaOri[1] == 'SE2' .And. SEV->EV_RATEICC == "2" )) .AND.;
						!Empty(SEV->EV_LA)
						RecLock("SEV")
						SEV->EV_LA := ""
						SEV->(MsUnlock())
					EndIf

					dbSelectArea("SEV")
					DbSkip()
				Enddo
			EndIf
		EndIf
	
	ElseIf cAliasPos == "SE5"			/// Rateio nas Baixas e Mov.Bancario
	
		If SE5->E5_MULTNAT == "1"

			cSeqSE5	:= SE5->E5_SEQ

			/////////////////////////////////////////////////////////////////////////////////////////////
			If SE5->E5_RECPAG == "R" 		/// Movimentos de Baixas e Mov. Bancario Receber
			/////////////////////////////////////////////////////////////////////////////////////////////
				lAdiant 	:= .f.
				lEstorno 	:= .F.
				lEstRaNcc 	:= .F.
				lCompens 	:= .F.

				If SE5->E5_TIPODOC == "ES"
					lEstorno := .T.
				EndIf
				If SE5->E5_TIPODOC == "ES" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
					lEstRaNcc := .T.
				EndIf
				If SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG
					lAdiant := .T.
				EndIf
				If  SE5->E5_TIPODOC == "BA" .and. SE5->E5_MOTBX == "CMP"
					lCompens := .T.
				EndIf

				If (lAdiant .or. lEstorno) .and. !lEstRaNcc
					dbSelectArea("SE2")
					dbSetOrder(1)
					MsSeek(xFilial("SE2")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA),.T.)
				Else
					dbSelectArea( "SE1" )
					dbSetOrder(2)
					cFilorig := xFilial("SE1")
					If lCompens
						If !Empty(xFilial("SE5"))
							If !Empty(SE5->E5_FILORIG)
								cFilOrig := SE5->E5_FILORIG
							EndIf
						EndIf
					EndIf

					MsSeek(cFilOrig+SE5->(E5_CLIfOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),.T.)
				EndIf

				If Found()
					If lEstorno
						cChaveSev := RetChaveSev("SE2")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE2",,"SEZ")
					Else
						cChaveSev := RetChaveSev("SE1")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE1",,"SEZ")
					EndIf

					DbSelectArea("SEV")
					dbSetOrder(2)
					// Se utiliza multiplas naturezas, contabiliza pelo SEV
					If MsSeek(cChaveSev)

						DbSelectArea("SEV")
						While SEV->(!Eof()) .and.;
							cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT+EV_SEQ);
							== cChaveSev

							//Se estou contabilizando um estorno, trata-se de um C. Pagar,
							//So contabiliza EV_SITUACA == E
							If (lEstorno .and. !(SEV->EV_SITUACA == "E")) .or. ;
								(!lEstorno .and. (SEV->EV_SITUACA == "E"))
								//Se nao for um estorno, nao devo contabilizar o registro se
								//EV_SITUACA == E
								dbSkip()
								Loop
							EndIf

							lSEVLimpaFlag := .F.
							If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1" // Rateou multinat por c.custo

								dbSelectArea("SEZ")
								dbSetOrder(4)
								MsSeek(cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5) // Posiciona no arquivo de Rateio C.Custo da MultiNat

								While SEZ->(!Eof()) .and.;
									cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ);
									== cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5

									//Se estou contabilizando um estorno, trata-se de um C. Pagar,
									//So vou contabilizar os EZ_SITUACA == E
									//Se nao for um estorno, nao devo contabilizar o registro se
									//EZ_SITUACA == E
									If (lEstorno .and. !(SEZ->EZ_SITUACA == "E")) .or. ;
										(!lEstorno .and. (SEZ->EZ_SITUACA == "E"))
										dbSkip()
										Loop
									EndIf

									If SEZ->(RECNO() <> aAreaOri[3])
										SEZ->(DBSKIP())
										Loop
									EndIF

									lSEVLimpaFlag := .T.
									If !Empty(SEV->EV_LA)
										RecLock("SEZ")
										SEZ->EZ_LA    := ""
										MsUnlock( )
									EndIf

									dbSkip()
								Enddo
							EndIf			/// Se Rateou Mult.Natur x C.Custo

							DbSelectArea("SEV")
							If ((aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO())) .OR.;
								(aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .OR.;
								(aAreaOri[1] == 'SE5' .AND. SEV->EV_RATEICC == "2")) .AND.;
								!Empty(SEV->EV_LA)

								RecLock("SEV")
								SEV->EV_LA := ""
								MsUnlock( )
							EndIf

							DbSelectArea("SEV")
							DbSkip()
						Enddo
					EndIf		/// Encontrou no SEV
				EndIf

			/////////////////////////////////////////////////////////////////////////////////////////////
			ElseIf SE5->E5_RECPAG == "P" 	/// Movimentos de Baixas e Mov. Bancario Pagar
			/////////////////////////////////////////////////////////////////////////////////////////////
				lAdiant 	:= .F.
				lEstorno 	:= .F.
				lEstPaNdf 	:= .F.
				lEstCart2 	:= .F.
				lCompens  	:= .F.

				If SE5->E5_TIPODOC == "ES"
					lEstorno := .T.
				EndIf

				If SE5->E5_TIPODOC == "E2"
					lEstCart2 := .T.
				EndIf

				If SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. SE5->E5_TIPODOC == "ES"
					lEstPaNdf := .T.
				EndIf

				If SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
					lAdiant := .T.
				EndIf

				If SE5->E5_TIPODOC == "BA" .and. SE5->E5_MOTBX == "CMP"
					lCompens := .T.
				EndIf


				If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
					dbSelectArea("SE1")
					dbSetOrder(2)
					MsSeek(xFilial("SE1")+SE5->(E5_CLIfOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),.T.)
				Else
					dbSelectArea( "SE2" )
					dbSetOrder(1)
					cFilorig := xFilial("SE2")
					If lCompens
						If !Empty(xFilial("SE5"))
							If !Empty(SE5->E5_FILORIG)
								cFilOrig := SE5->E5_FILORIG
							EndIf
						EndIf
					EndIf

					MsSeek( cFilOrig +SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA),.T.)
				EndIf

				If Found()

					//Contabilizando estorno de C.Receber
					If lEstorno
						cChaveSev := RetChaveSev("SE1")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE1",,"SEZ")
					Else
						cChaveSev := RetChaveSev("SE2")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE2",,"SEZ")
					EndIf

					DbSelectArea("SEV")
					dbSetOrder(2)
					If MsSeek(cChaveSev)

						DbSelectArea("SEV")
						While SEV->(!Eof()) .and.;
							cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT+EV_SEQ);
							== cChaveSev

							//Se estou contabilizando um estorno, trata-se de um C. Pagar,
							//So vou contabilizar os EV_SITUACA == E
							//Se nao for um estorno, nao devo contabilizar o registro se
							//EV_SITUACA == E
							If (lEstorno .and. !(SEV->EV_SITUACA == "E")) .or. ;
								(!lEstorno .and. (SEV->EV_SITUACA == "E"))
								dbSkip()
								Loop
							EndIf

							dbSelectArea("SEV")

							lSEVLimpaFlag := .F.
							If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1"  // Rateou multinat por c.custo

								dbSelectArea("SEZ")
								dbSetOrder(4)
								MsSeek(cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5) // Posiciona no arquivo de Rateio C.Custo da MultiNat

								While SEZ->(!Eof()) .and.;
									cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ);
									== cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5

									//Se estou contabilizando um estorno, trata-se de um C. Pagar,
									//So vou contabilizar os EZ_SITUACA == E
									//Se nao for um estorno, nao devo contabilizar o registro se
									//EZ_SITUACA == E
									If (lEstorno .and. !(SEZ->EZ_SITUACA == "E")) .or. ;
										(!lEstorno .and. (SEZ->EZ_SITUACA == "E"))
										dbSkip()
										Loop
									EndIf

									If SEZ->(RECNO() <> aAreaOri[3])
										SEZ->(DBSKIP())
										Loop
									EndIF

									lSEVLimpaFlag := .T.
									If !Empty(SEZ->EZ_LA)
										RecLock("SEZ")
										SEZ->EZ_LA    := ""
										MsUnlock( )
									EndIf

									dbSkip()
								Enddo

								DbSelectArea("SEV")
							EndIf

							If ((aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO())) .OR.;
								(aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .OR.;
								(aAreaOri[1] == 'SE5' .AND. SEV->EV_RATEICC == "2")) .AND.;
								!Empty(SEV->EV_LA)
								
								RecLock("SEV")
								SEV->EV_LA := ""
								MsUnlock()
							EndIf

							DbSelectArea("SEV")
							DbSkip()
						Enddo
					EndIf	/// Se achou SEV
				EndIf
			/////////////////////////////////////////////////////////////////////////////////////////////
			EndIf
			/////////////////////////////////////////////////////////////////////////////////////////////
		EndIf	/// Fecha If do E5_MULTNAT == '1'
	EndIf

	If !Empty(cAliasPos)
		RestArea(aAreaMN)
	EndIf
	RestArea(aAreaOri)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A370CanProºAutor  ³Marcos S. Lobo      º Data ³  06/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria Semaforo de processamento e verIfica concorrencia com  º±±
±±º          ³base nos intervalos de parametros                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Contabilizacao Off-Line Financeiro                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBCanProc(nCart, dDtVldDe, dDtVldAte, cFilDe, cFilAte, oSelf)
Local lRet		:= .F.
Local nEr		:= 0 
Local cFile		:= ""
Local cUserCTB	:= PADR('SCHED',15)

Default nCart := 0
Default dDtVldDe := dDataBase
Default dDtVldAte := dDataBase
Default cFilDe := cFilAnt
Default cFilAte:= cFilAnt

If !IsBlind()
	cUserCTB := cUserName
EndIf

While !LockByName("FINA370LOCKPROC"+cEmpAnt,.T.,.T.,.T.)
    nER++
	If !_lBlind
		MsAguarde({|| Sleep(1000) }, STR0026+ALLTRIM(STR(nER)), STR0027) //"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
	Else
		Sleep(5000)		
	EndIf
	If nER > 5	/// A PARTIR DA QUINTA TENTATIVA
		If !_lBlind
			If Aviso(STR0028,STR0029,{STR0030,STR0034},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
				If Funname() == "FINA370" .and. !_lBlind
					oSelf:Savelog("ERRO",STR0031,STR0032+STR0033)	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Utilizacao da funcao ProcLogAtu para permitir a gravacao ³
					//³do log no CV8 quando do uso da classe tNewProcess que    ³
					//³grava o LOG no SXU (FNC 00000028259/2009)                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ProcLogAtu("ERRO",STR0031,STR0032+STR0033)						
				Else	
					ProcLogAtu("ERRO",STR0031,STR0032+STR0033)	
				EndIf	
				Return lRet
			Else
				nER := 0
			EndIf		
		ElseIf nER >= 30
			If Funname() == "FINA370" .and. !_lBlind
				oSelf:Savelog("ERRO",STR0031,STR0032+STR0033)	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Utilizacao da funcao ProcLogAtu para permitir a gravacao ³
				//³do log no CV8 quando do uso da classe tNewProcess que    ³
				//³grava o LOG no SXU (FNC 00000028259/2009)                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ProcLogAtu("ERRO",STR0031,STR0032+STR0033)		
			Else	
				ProcLogAtu("ERRO",STR0031,STR0032+STR0033)	
			EndIf	
			Return lRet
		EndIf
    EndIf
EndDo

IF AliasInDic("F74")
	lRet := FinSemaphore(nCart, dDtVldDe, dDtVldAte, cFilDe, cFilAte, oSelf)
	UnLockByName("FINA370LOCKPROC"+cEmpAnt,.T.,.T.,.T.)
	RETURN lRet
ENDIF

cFile := "CTB370"+AllTrim(cEmpAnt)

lCriaTrab := !(MsFile(cFile,,"TOPCONN"))

If !lCriaTrab
	If Select("SEM370") <= 0
		dbUseArea(.T.,'TOPCONN',cFile,"SEM370",.T.,.F.)
	EndIf
	If (lCriaTrab := VALTYPE(SEM370->DTDE) == 'D')
		SEM370->(DBCLOSEAREA())
		MSERASE(cFile,,"TOPCONN")
	Endif
EndIf

If lCriatrab
	aStruct  := {}
	AAdd( aStruct, { "FILDE"	, "C", Len( cFilAnt )	, 0 } )
	AAdd( aStruct, { "FILATE"	, "C", Len( cFilAnt )	, 0 } )
	AAdd( aStruct, { "DTDE"		, "C", 8 				, 0 } )
	AAdd( aStruct, { "DTATE"	, "C", 8 				, 0 } )
	AAdd( aStruct, { "CCART"	, "C", 1				, 0 } )
	AAdd( aStruct, { "CUSER"	, "C", Len( cUserCTB )	, 0 } )
	AAdd( aStruct, { "HORAI"	, "C", Len(Time())		, 0 } )
	AAdd( aStruct, { "DATAI"	, "C", 8				, 0 } )
	AAdd( aStruct, { "HORAF"	, "C", Len(Time())		, 0 } )
	AAdd( aStruct, { "DATAF"	, "C", 8				, 0 } )
	MsCreate( cFile , aStruct , 'TOPCONN' )
EndIf

If Select("SEM370") <= 0
	dbUseArea(.T.,'TOPCONN',cFile,"SEM370",.T.,.F.)
EndIf

dbSelectArea("SEM370")			
dbGoTop()

lSai		:= .F.
lRet1		:= .T.
lRet2		:= .T.
lRet3		:= .T.	

While !lSai .and. SEM370->(!Eof())
	        
	If cFilDe <= SEM370->FILDE .and. cFilAte >= SEM370->FILATE
		lRet1 := .F.
	ElseIf cFilDe >= SEM370->FILDE .and. cFilDe <= SEM370->FILATE
		lRet1 := .F.
	ElseIf cFilAte >= SEM370->FILDE .and. cFilAte <= SEM370->FILATE
		lRet1 := .F.
	ElseIf cFilDe > cFilAte
		lRet1 := .F.		
	EndIf	    

	IF !lRet1
		If DTOS(dDtVldDe) <= SEM370->DTDE .and. DTOS(dDtVldAte) >= SEM370->DTATE
			lRet2 := .F.
		ElseIf DTOS(dDtVldDe) >= SEM370->DTDE .and. DTOS(dDtVldDe) <= SEM370->DTATE
			lRet2 := .F.
		ElseIf DTOS(dDtVldAte) >= SEM370->DTDE .and. DTOS(dDtVldAte) <= SEM370->DTATE
			lRet2 := .F.
		ElseIf DTOS(dDtVldDe) > DTOS(dDtVldAte)
			lRet2 := .F.		
		EndIf
		
		If nCart == 4 .or. SEM370->CCART == "4"
			lRet3 := .F.
		ElseIf Str(nCart,1) == SEM370->CCART	
			lRet3 := .F.	
		EndIf
	ENDIF
	
	If !lRet1 .and. !lRet2 .and. !lRet3
		// SE LOCALIZOU NO MESMO PERIODO E NAS MESMAS FILIAIS E MESMA CARTEIRA

		If SEM370->(RLock())			/// SE CONSEGUIR ALOCAR 	
			SEM370->(dbDelete())		/// NAO TEM CONCORRENCIA
			SEM370->(MsUnlock())
		Else		
			If !_lBlind
				Aviso(STR0031,STR0032+Alltrim(SEM370->CUSER)+" "+SEM370->HORAI+" "+STR0033,{STR0034},2) //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."###"Fechar"
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento com o erro  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Funname() == "FINA370" .and. !_lBlind
				If ValType(oSelf) == "O"
					oSelf:Savelog("ERRO",STR0031,STR0032+Alltrim(SEM370->CUSER)+STR0033)
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Utilizacao da funcao ProcLogAtu para permitir a gravacao ³
				//³do log no CV8 quando do uso da classe tNewProcess que    ³
				//³grava o LOG no SXU (FNC 00000028259/2009)                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ProcLogAtu("ERRO",STR0031,STR0032+AllTrim(SEM370->CUSER)+STR0033)	
			Else	
				ProcLogAtu("ERRO",STR0031,STR0032+Alltrim(SEM370->CUSER)+STR0033)
			EndIf	
			lSai := .T.
		EndIf
	EndIf
	SEM370->(dbSkip())
EndDo

If !lSai
	RecLock("SEM370",.T.)
	SEM370->FILDE	:= PADR(cFilDe,LEN(cFilAnt))
	SEM370->FILATE	:= PADR(cFilAte,LEN(cFilAnt))
	SEM370->DTDE	:= DTOS(dDtVldDe)
	SEM370->DTATE	:= DTOS(dDtVldAte)
	SEM370->CCART	:= Str(nCart,1)
	SEM370->CUSER	:= cUserCTB
	SEM370->HORAI	:= Time()
	SEM370->DATAI	:= DTOS(Date())
	MsUnlock()	
	RecLock("SEM370",.F.)	// DEIXA REGISTRO ALOCADO
	lRet := .T.				// PROCESSAMENTO PODE SER EFETUADO
EndIf

UnLockByName("FINA370LOCKPROC"+cEmpAnt,.T.,.T.,.T.)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A370FREEPRºAutor  ³Marcos S. Lobo      º Data ³  06/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Contabilizacao Off-Line Financeiro                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBFreeProc(aKeyProc)

Local cFile 	:= "CTB370"+AllTrim(cEmpAnt)
Local nER		:= 0
Local nI		:= NIL
Local lTRBEmpty := .F.

DEFAULT aKeyProc := NIL

IF !AliasInDic('F74')
	If !( MsFile(cFile,,"TOPCONN") )
		Return
	EndIf

	If Select("SEM370") <= 0
		Return
	EndIf
ENDIF

While !LockByName("FINA370LOCKPROC"+cEmpAnt,.T.,.T.,.T.)
    nER++
	If !_lBlind
		MsAguarde({|| Sleep(1000) }, STR0026+ALLTRIM(STR(nER)), STR0029)//"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
	Else
		Sleep(5000)		
	EndIf
	If nER > 5	/// A PARTIR DA QUINTA TENTATIVA
		If !_lBlind
			If Aviso(STR0028,STR0029,{STR0030,STR0034},2) == 2//"Gravacao de Semaforo de processamento."#"Não foi possivel acesso exclusivo para gravar o semaforo de processamento."#"Repetir"#"Fechar"
				If Funname() == "FINA370" .and. !_lBlind
					oSelf:Savelog("ERRO",STR0031,STR0032+STR0033)	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Utilizacao da funcao ProcLogAtu para permitir a gravacao ³
					//³do log no CV8 quando do uso da classe tNewProcess que    ³
					//³grava o LOG no SXU (FNC 00000028259/2009)                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ProcLogAtu("ERRO",STR0031,STR0032+STR0033)	
				Else	
					ProcLogAtu("ERRO",STR0031,STR0032+STR0033)	
				EndIf
				
				Return
			Else
				nER := 0
			EndIf		
		ElseIf nER >= 30
			If Funname() == "FINA370" .and. !_lBlind
				oSelf:Savelog("ERRO",STR0031,STR0032+STR0033)	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Utilizacao da funcao ProcLogAtu para permitir a gravacao ³
				//³do log no CV8 quando do uso da classe tNewProcess que    ³
				//³grava o LOG no SXU (FNC 00000028259/2009)                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ProcLogAtu("ERRO",STR0031,STR0032+STR0033)	
			Else	
				ProcLogAtu("ERRO",STR0031,STR0032+STR0033)	
			EndIf
			Return
		EndIf
    EndIf
EndDo

IF AliasInDic("F74")
	FinCloseSemaph(aKeyProc)
	UnLockByName("FINA370LOCKPROC"+cEmpAnt,.T.,.T.,.T.)
	RETURN NIL
ENDIF

If !EMPTY(aKeyProc)
	cEval := ''
	For nI := 1 To Len(aKeyProc)
		cEval += "SEM370->" + aKeyProc[nI][1] + " =='" + aKeyProc[nI][2] + "' "
		If nI < Len(aKeyProc)
			cEval += " .and. "
		EndIf
	Next nI
	bEval := {|| &cEval }
Else
	bEval := {|| .T.}
EndIf

dbSelectArea("SEM370")
SEM370->(dbGoTop())
While !SEM370->(Eof()) 
	If Eval(bEval) .and. SEM370->(RLock())
		Field->HORAF	:= Time()
		Field->DATAF	:= DTOS(Date())
		MsUnlock()
		RecLock("SEM370",.F.)
		SEM370->(dbDelete())
		MsUnlock()
	EndIf
	SEM370->(DBSKIP())
EndDo

SEM370->(DBCLOSEAREA())
dbUseArea(.T.,'TOPCONN',cFile,"SEM370",.T.,.F.)
lTRBEmpty := SEM370->(EOF())
SEM370->(DBCLOSEAREA())

If lTRBEmpty
	MSERASE(cFile,,"TOPCONN")
Endif

UnLockByName("FINA370LOCKPROC"+cEmpAnt,.T.,.T.,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FinSemaphore

Efetua registro no arquivo de semaforo F74

@author Norberto M de Melo
@since 26/02/2021
@Return lRet, Logical, Validação OK
/*/
//-------------------------------------------------------------------
FUNCTION FinSemaphore(nCart AS NUMERIC, dDtVldDe AS DATE, dDtVldAte AS DATE, cFilDe AS CHARACTER, cFilAte AS CHARACTER, oSelf AS OBJECT) AS LOGICAL
LOCAL lRet AS LOGICAL
LOCAL lRet1 AS LOGICAL
LOCAL lRet2 AS LOGICAL
LOCAL lRet3 AS LOGICAL
LOCAL lSai AS LOGICAL
LOCAL aF74KEY AS ARRAY
LOCAL nPos AS NUMERIC

DEFAULT nCart := 0
DEFAULT dDtVldDe := dDataBase
DEFAULT dDtVldAte := dDataBase
DEFAULT cFilDe := cFilAnt
DEFAULT cFilAte := cFilAnt

nPos := 0
lRet := .T.
lSai := .F.

// Efetua limpeza da tabela F74 dos registros deletados.
FinClearSemaphore()

DBSelectArea("F74")
F74->(DBSETORDER(1))	// F74_FILIAL+DTOS(F74_DTPROC)+F74_ROTINA+F74_KEY
F74->(DBGOTOP())

WHILE F74->(!EOF())
	
    // Reinicia variáveis de controle
    lRet1 := .T.
    lRet2 := .T.
    lRet3 := .T.

	// Leitura e conversão de Tipos	
	aF74Key := StrToKArr(F74->F74_KEY,'|')
	aF74Key[F74CARTEIRA] := VAL(aF74Key[F74CARTEIRA])
	aF74Key[F74DTDE] := STOD(aF74Key[F74DTDE])
	aF74Key[F74DTATE] := STOD(aF74Key[F74DTATE])

	// Verifica se a faixa de Filiais possui intersecção no processamento ativo
	If cFilDe <= aF74Key[F74FILDE] .and. cFilAte >= aF74Key[F74FILATE]
		lRet1 := .F.
	ElseIf cFilDe >= aF74Key[F74FILDE] .and. cFilDe <= aF74Key[F74FILATE]
		lRet1 := .F.
	ElseIf cFilAte >= aF74Key[F74FILDE] .and. cFilAte <= aF74Key[F74FILATE]
		lRet1 := .F.
	ElseIf cFilDe > cFilAte
		lRet1 := .F.		
	EndIf

	IF !lRet1
		// Verifica se a faixa de Datas possui intersecção no processamento ativo
		If dDtVldDe <= aF74Key[F74DTDE] .and. dDtVldAte >= aF74Key[F74DTATE]
			lRet2 := .F.
		ElseIf dDtVldDe >= aF74Key[F74DTDE] .and. dDtVldDe <= aF74Key[F74DTATE]
			lRet2 := .F.
		ElseIf dDtVldAte >= aF74Key[F74DTDE] .and. dDtVldAte <= aF74Key[F74DTATE]
			lRet2 := .F.
		ElseIf dDtVldDe > dDtVldAte
			lRet2 := .F.		
		EndIf

		// Verifica se a carteira possui intersecção no processamento ativo
		If nCart == 4 .or. aF74Key[F74CARTEIRA] == 4
			lRet3 := .F.
		ElseIf nCart == aF74Key[F74CARTEIRA]
			lRet3 := .F.
		EndIf
	ENDIF

	// Se localizou processo executando com alguma intersecção de periodo, filial e carteira
	IF !lRet1 .AND. !lRet2 .AND. !lRet3
		IF F74->(RLock())	// Se conseguir alocar não tem concorrência
			F74->(dbDelete())
			F74->(MsUnlock())
        // Libera processo mesmo com registro bloqueado no DBACCESS,
        // pois a thread que o bloqueou não está mais presente no Monitor.
        // Este registro será excluído na próxima execução.
		ELSEIF ASCAN(GETUSERINFOARRAY(.T.),{|E| E[3] == VAL(F74->F74_IDTHR)}) == 0
        // Exibe mensagem e impede a concorrência na execução da contabilização. 
        ELSE
			IF !_lBlind
				IF AliasInDic('F74')
					Aviso(STR0031,STR0032+Alltrim(F74->F74_USER)+" "+STR0033,{STR0034},2) 
				ELSE
					Aviso(STR0031,STR0032+Alltrim(SEM370->CUSER)+" "+SEM370->HORAI+" "+STR0033,{STR0034},2) 
				ENDIF
				// "Atenção!
				// "###" Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário 
				// "###" no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde.
				// "###" Fechar"
			ENDIF
		
			// Atualiza o log de processamento com o erro 
			IF FUNNAME() == "FINA370" .and. !_lBlind
				IF VALTYPE(oSelf) == "O"
					oSelf:Savelog("ERRO",STR0031,STR0032+Alltrim(SEM370->CUSER)+STR0033)
				ENDIF
			ENDIF
			// Utilizacao da funcao ProcLogAtu para permitir a gravacao
			// do log no CV8 quando do uso da classe tNewProcess que
			// grava o LOG no SXU (FNC 00000028259/2009)
			IF AliasInDic('F74')
				ProcLogAtu("ERRO",STR0031,STR0032+Alltrim(F74->F74_USER)+STR0033)
			ELSE
				ProcLogAtu("ERRO",STR0031,STR0032+Alltrim(SEM370->CUSER)+STR0033)
			ENDIF

			lSai := .T.
			lRet := .F.
		ENDIF
	ENDIF

	F74->(DBSKIP())
ENDDO

If !lSai
	nPos := ASCAN(GETUSERINFOARRAY(.T.),{|E| E[3] == VAL(GETTHREADID()) })
	
	RecLock("F74",.T.)
	F74->F74_FILIAL := cFilAnt
	F74->F74_DTPROC := dDataBase
	F74->F74_ROTINA := FUNNAME()
	F74->F74_KEY := STR(nCart,1)+'|'+DTOS(dDtVldDe)+'|'+DTOS(dDtVldAte)+'|'+cFilDe+'|'+cFilAte+'|'
	F74->F74_USER := cUserName
	F74->F74_IDTHR := GETTHREADID()
	
	IF !EMPTY(nPos)
		F74->F74_SIDTHR := GETUSERINFOARRAY(.T.)[nPos,13]
		F74->F74_ENVIR := GETUSERINFOARRAY(.T.)[nPos,6]
	ENDIF

	F74->(MsUnlock())
	RecLock("F74",.F.)	// Mantém registro alocado
	lRet := .T.			// Processamento pode ser efetuado
EndIf

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCloseSemaph

Deleta registro de controle de processamento, e deletados se houver, 
do arquivo de semaforo F74

@author Norberto M de Melo
@since 26/02/2021
@Return lRet, Logical, Validação OK
/*/
//-------------------------------------------------------------------
FUNCTION FinCloseSemaph(aKeyProc AS ARRAY) AS LOGICAL
LOCAL lRet AS LOGICAL
LOCAL cKey AS CHARACTER
LOCAL nI AS NUMERIC
LOCAL nPos AS NUMERIC

DEFAULT aKeyProc := {} 

IF LEN(aKeyProc) == 3
	AADD(aKeyProc, {'FILDE',cFilAnt})
	AADD(aKeyProc, {'FILATE',cFilAnt})
ENDIF

cKey := ''

FOR nI := 1 TO LEN(aKeyProc)
	cKey += aKeyProc[nI][2] + '|'
NEXT nI

lRet := .T.

DBSELECTAREA('F74')
F74->(DBSETORDER(1))		// F74_FILIAL+DTOS(F74_DTPROC)+F74_ROTINA+F74_KEY
F74->(DBGOTOP())
WHILE F74->(!EOF())

	nPos := ASCAN(GETUSERINFOARRAY(.T.),{|E| E[3] == VAL(GETTHREADID()) })
	IF EMPTY(nPos) .OR. ALLTRIM(F74->F74_KEY) == cKey
		RecLock('F74',.F.)
		F74->(DBDELETE())
		F74->(MSUNLOCK())
	ENDIF
	F74->(DBSKIP())
ENDDO

// Efetua limpeza da tabela F74 dos registros deletados.
FinClearSemaphore()

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCloseSemaph

Efetua limpeza da tabela F74 dos registros deletados.

@author Norberto M de Melo
@since 26/02/2021
@Return cRet, character, Erro retornado pela execução TCSQLEXEC()
/*/
//-------------------------------------------------------------------
FUNCTION FinClearSemaphore() AS CHARACTER
LOCAL cNewAlias AS CHARACTER
LOCAL cSQLCommand AS CHARACTER
LOCAL cRet AS CHARACTER

cRet := ""
cNewalias := GetNextAlias()
cSQLCommand := "DELETE FROM " + RetSQLName('F74') + " WHERE D_E_L_E_T_ = '*'"

IF TCSQLExec(cSQLCommand) < 0
	cRet := TCSqlError()
ENDIF

RETURN cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBConout
Geração de comentários de processamento 

@author Norberto M de Melo
@since 28/05/2021
@version 1.0
@type function

@return NIL
/*/
//-------------------------------------------------------------------
FUNCTION CTBConout(cMsg AS CHARACTER, lUserException AS LOGICAL)
    DEFAULT cMsg := ''
    DEFAULT lUserException := .T.
	IF !EMPTY(cMsg)
		IF __lConOutR
			ConOutR(cMsg)
		ELSEIF lUserException
			UserException(cMsg)
		ENDIF
	ENDIF
RETURN NIL
//-------------------------------------------------------------------
