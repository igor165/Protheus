#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS001

Job da integração Protheus x Copastur

@author  CM Solutions - Allan Constantino Bonfim
@since   01/03/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FINWS001(_aParam)

	Local _aRet			:= {}
	//Local cFunExec	:= ""
	Local _aComboA 		:= {"1=Todos", "2=Cadastros", "3=Pagamentos"}
	Local _aComboB 		:= {"1=Todos", "2=Participantes", "3=Aprovadores", "4=Centros de Custos", "5=Despesas/Reembolsos"}
	Local _aComboC 		:= {"1=Todos os Registros", "2=Somente Integradora"}
	//Local _aComboD 		:= {"01=Sanchez", "02=Fini", "03=Fini Franquias"}
	//Local _aComboE 		:= {"01=Matriz", "06=Matriz"}
	Local _aParamBox	:= {}
	Local _cPerg		:= "FINWS001"
	Local _cPrcTipo		:= ""
	Local _cIntTipo		:= ""
	Local _cIntOpcao	:= ""
	Local _cEmpAtu		:= ""
	Local _cFilAtu		:= ""
	//Local _cATmpPart	//:= ""
	//Local _cATmpAprov	//:= ""
	//Local _cATmpCcusto	//:= ""
	//Local _cATmpDesp	//:= ""
	//Local _lRet			:= .T.
	//Local _cCodFil		:= ""

	Default _aParam	:= {}
		

	If Len(_aParam) > 0
		_cPrcTipo	:= _aParam[1]
		_cIntTipo	:= _aParam[2]
		_cIntOpcao 	:= _aParam[3]
		_cEmpAtu	:= _aParam[4]
		_cFilAtu	:= _aParam[5]
	EndIf

	If Type("oMainWnd") == "O"
		If GetNewPar("ZZ_WSALATU", .F.)
			_cEmpAtu := FwCodEmp()
			_cFilAtu := FwCodFil()
			//_cCodFil := FwCodFil()

			AADD(_aParamBox,{2, "Processar:"	, 3, _aComboA, 100, ".F.", .F. })
			AADD(_aParamBox,{2, "Tipo:     "	, 5, _aComboB, 100, ".F.", .F. })
			AADD(_aParamBox,{2, "Integrar: "	, 1, _aComboC, 100, ".F.", .F. })
			//AADD(_aParamBox,{2, "Empresa:  "	, 1, _aComboD, 100, ".F.", .F. })
			//AADD(_aParamBox,{2, "Filial:   "	, 1, _aComboE, 100, ".F.", .F. })
			//AADD(_aParambox,{1, "Filial:"		, _cCodFil, "@!", "!Vazio()", "", ".T.", 50, .T.})

			If ParamBox(_aParamBox, "Integração Copastur...",@_aRet,,,,,,, _cPerg,.T.,.T.)	
				If ValType(_aRet[1]) == "N"
					_cPrcTipo := Alltrim(Str(_aRet[1]))
				Else
					_cPrcTipo := Alltrim(_aRet[1])
				EndIf

				If ValType(_aRet[2]) == "N"
					_cIntTipo := Alltrim(Str(_aRet[2]))
				Else
					_cIntTipo := Alltrim(_aRet[2])
				EndIf

				If ValType(_aRet[3]) == "N"
					_cIntOpcao := Alltrim(Str(_aRet[3]))
				Else
					_cIntOpcao := Alltrim(_aRet[3])
				EndIf
/*
				If ValType(_aRet[4]) == "N"
					_cEmpAtu := Alltrim(Strzero(_aRet[4], 2))
				Else
					_cEmpAtu := Alltrim(PADL(_aRet[4], 2))
				EndIf
			
				If ValType(_aRet[5]) == "N"
					_cFilAtu := Alltrim(Strzero(_aRet[5], 2))
				Else
					_cFilAtu := Alltrim(PADL(_aRet[5], 2))
				EndIf
*/
				If _cEmpAtu	== FwCodEmp() .AND. _cFilAtu == FwCodFil()
					DbSelectArea("FL2")
					DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC, R_E_C_N_O_, D_E_L_E_T_
					
					If FL2->(Dbseek(FwxFilial("FL2")+_cEmpAtu+_cFilAtu))	
						If _cPrcTipo == "1" .OR. _cPrcTipo == "2" //"2=Cadastros"
							
							If GetNewPar("ZZ_WSAINT1", .T.) .AND. (_cIntTipo == "1" .OR. _cIntTipo == "2") //"2=Participantes"
								FWMsgRun(, {|| _lRet := U_FIN5WS01(_cIntOpcao)}, "Processando Cadastro...", "Integração do cadastro de Participantes")
								
								/*If Select(_cATmpPart) > 0
									(_cATmpPart)->(DbCloseArea())
								EndIf
								
								If _cIntOpcao == "2"
									_cATmpPart	:= U_FIWS3TMP(2,, {"2"}, "1")
									If Select(_cATmpPart) > 0
										(_cATmpPart)->(DbGotop())
										DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
										DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
										WHile !(_cATmpPart)->(EOF())
											If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
												FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
												(_cATmpPart)->(DbSkip())
											EndIf
										EndDo
									EndIf
								Else
									If Select(_cATmpPart) > 0
										(_cATmpPart)->(DbCloseArea())
									EndIf
									_cATmpPart	:= U_FIWS3TMP(1)
									If Select(_cATmpPart) > 0
										(_cATmpPart)->(DbGotop())
										WHile !(_cATmpPart)->(EOF())
											FWMsgRun(, {|| _lRet := U_FINWS05I((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO, "2", "1",,, "1")}, "Integrando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
											FWMsgRun(, {|| _lRet := U_FINWS03P((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, "RD0", (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
											(_cATmpPart)->(DbSkip())
										EndDo
									EndIf
								EndIf*/
							EndIf
							


							If GetNewPar("ZZ_WSAINT2", .T.) .AND. (_cIntTipo == "1" .OR. _cIntTipo == "3") //"3=Aprovadores"	
								FWMsgRun(, {|| _lRet := U_FIN5WS02(_cIntOpcao)}, "Processando Cadastro...", "Integração do cadastro de Aprovadores")

							/*	If Select(_cATmpPart) > 0
									(_cATmpPart)->(DbCloseArea())
								EndIf
								
								If _cIntOpcao == "2"
									_cATmpPart	:= U_FIWS3TMP(2,, {"2"}, "2")
									If Select(_cATmpPart) > 0
										(_cATmpPart)->(DbGotop())
										DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
										DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
										WHile !(_cATmpPart)->(EOF())
											If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
												FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
												(_cATmpPart)->(DbSkip())
											EndIf
										EndDo
									EndIf
								Else
									If Select(_cATmpAprov) > 0
										(_cATmpAprov)->(DbCloseArea())
									EndIf
									_cATmpAprov	:= U_FIWS3TMP(7)

									If Select(_cATmpAprov) > 0
										(_cATmpAprov)->(DbGotop())
										WHile !(_cATmpAprov)->(EOF())
											If Select(_cATmpPart) > 0
												(_cATmpPart)->(DbCloseArea())
											EndIf
											_cATmpPart	:= U_FIWS3TMP(1,, {,,,(_cATmpAprov)->RD0_CODIGO})
											(_cATmpPart)->(DbGotop())
											WHile !(_cATmpPart)->(EOF())
												FWMsgRun(, {|| _lRet := U_FINWS06I((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO, "2", "2", "1")}, "Integrando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
												FWMsgRun(, {|| _lRet := U_FINWS03P((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, "RD0", (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
												(_cATmpPart)->(DbSkip())
											EndDo
											(_cATmpAprov)->(DbSkip())
										EndDo
									EndIf
								EndIf */
							EndIf
							
							If GetNewPar("ZZ_WSAINT3", .T.) .AND. (_cIntTipo == "1" .OR. _cIntTipo == "4") //"4=Centros de Custos"
								FWMsgRun(, {|| _lRet := U_FIN4WS03(_cIntOpcao, _cEmpAtu, _cFilAtu)}, "Processando Cadastro...", "Integração do cadastro de Centros de Custos")
		
								/*If Select(_cATmpCcusto) > 0
									(_cATmpCcusto)->(DbCloseArea())
								EndIf	

								If _cIntOpcao == "2"
									_cATmpCcusto := U_FIWS3TMP(2,, {"2"}, "3")
									If Select(_cATmpCcusto) > 0
										(_cATmpCcusto)->(DbGotop())
										DbSelectArea((_cATmpCcusto)->ZWQ_CALIAS)
										DbSetOrder((_cATmpCcusto)->ZWQ_INDICE) //CTT_FILIAL+CTT_CUSTO
										WHile !(_cATmpCcusto)->(EOF())
											If CTT->(Dbseek((_cATmpCcusto)->ZWQ_FILALI+(_cATmpCcusto)->ZWQ_CHAVE))
												FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", CTT->CTT_FILIAL, CTT->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->DESC01))
												(_cATmpCcusto)->(DbSkip())
											EndIf
										EndDo
									EndIf									
								Else
									If Select(_cATmpCcusto) > 0
										(_cATmpCcusto)->(DbCloseArea())
									EndIf
									_cATmpCcusto := U_FIWS3TMP(4)
									If Select(_cATmpCcusto) > 0
										(_cATmpCcusto)->(DbGotop())
										WHile !(_cATmpCcusto)->(EOF())
											FWMsgRun(, {|| _lRet := U_FINWS04I(_cEmpAtu, _cFilAtu, (_cATmpCcusto)->CTT_FILIAL, (_cATmpCcusto)->CTT_CUSTO, "2", "3",,, "1")}, "Integrando Cadastro...", "Centro de Custo " + ALLTRIM((_cATmpCcusto)->CTT_CUSTO) + " - " + ALLTRIM((_cATmpCcusto)->DESC01))
											FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", (_cATmpCcusto)->CTT_FILIAL, (_cATmpCcusto)->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM((_cATmpCcusto)->CTT_CUSTO) + " - " + ALLTRIM((_cATmpCcusto)->DESC01))
											(_cATmpCcusto)->(DbSkip())
										EndDo
									EndIf

								EndIf */
							EndIf 
						EndIf

						If GetNewPar("ZZ_WSAINT5", .T.) .AND. (_cPrcTipo == "1" .OR. _cPrcTipo == "3") //3=Pagamentos
							If _cIntTipo == "1" .OR. _cIntTipo == "5" //"5=Despesas/Reembolsos"
								FWMsgRun(, {|| _lRet := U_FIN7WS05(_cIntOpcao, _cEmpAtu, _cFilAtu)}, "Processando Cadastro...", "Integração das Despesas")
							/*	FWMsgRun(, {|| _aRet := U_FIWS7FAL(_cEmpAtu, _cFilAtu,,, .F., .T.)}, "Aguarde", "Consultando as despesas pendentes no Copastur")
								If Len(_aRet) > 0
									DbSelectArea("RD0")
									DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
									
									For _nX := 1 to Len(_aRet)
										If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_aRet[_nX][2]))))
											FWMsgRun(, {|| _lRet := U_FINWS05I(_cEmpAtu, _cFilAtu, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", "5", _aRet[_nX][1],, "1")}, "Integrando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
											FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "5")}, "Processando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
										EndIf	
									Next
								EndIf */
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	Else
	
		//---------------------------------------------------------------------
		// Inicializa ambiente sem consumir licencas
		//---------------------------------------------------------------------
		RPCSetType(3)
		RpcSetEnv(_cEmpAtu,_cFilAtu,,,,GetEnvServer(),{ })
		cUserName := "JOBADMIN"

		CONOUT("INTEGRACAO COPASTUR - INICIO - "+DTOC(ddatabase)+" - "+Time())
		If GetNewPar("ZZ_WSALATU", .F.)		
			DbSelectArea("FL2")
			DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC, R_E_C_N_O_, D_E_L_E_T_
			
			If FL2->(Dbseek(FwxFilial("FL2")+_cEmpAtu+_cFilAtu))	
				If _cPrcTipo == "1" .OR. _cPrcTipo == "2" //"2=Cadastros"
					If GetNewPar("ZZ_WSAINT1", .T.) .AND. (_cIntTipo == "1" .OR. _cIntTipo == "2") //"2=Participantes"
						CONOUT("INTEGRANDO PARTICIPANTES - INICIO - "+DTOC(ddatabase)+" - "+Time())
						FWMsgRun(, {|| _lRet := U_FIN5WS01(_cIntOpcao)}, "Processando Cadastro...", "Integração do cadastro de Participantes")

						/*If Select(_cATmpPart) > 0
							(_cATmpPart)->(DbCloseArea())
						EndIf
						
						If _cIntOpcao == "2"
							_cATmpPart	:= U_FIWS3TMP(2,, {"2"}, "1")
							If Select(_cATmpPart) > 0
								(_cATmpPart)->(DbGotop())
								DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
								DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
								WHile !(_cATmpPart)->(EOF())
									If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
										FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
										(_cATmpPart)->(DbSkip())
									EndIf
								EndDo
							EndIf
						Else
							If Select(_cATmpPart) > 0
								(_cATmpPart)->(DbCloseArea())
							EndIf
							_cATmpPart	:= U_FIWS3TMP(1)
							If Select(_cATmpPart) > 0
								(_cATmpPart)->(DbGotop())
								WHile !(_cATmpPart)->(EOF())
									FWMsgRun(, {|| _lRet := U_FINWS05I((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO, "2", "1",,, "1")}, "Integrando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
									FWMsgRun(, {|| _lRet := U_FINWS03P((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, "RD0", (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO,, "1")}, "Processando Cadastro...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
									(_cATmpPart)->(DbSkip())
								EndDo
							EndIf
						EndIf	*/
						CONOUT("INTEGRANDO PARTICIPANTES - FIM - "+DTOC(ddatabase)+" - "+Time())
					EndIf
				

					If GetNewPar("ZZ_WSAINT2", .T.) .AND. (_cIntTipo == "1" .OR. _cIntTipo == "3") //"3=Aprovadores"	
						CONOUT("INTEGRANDO APROVADORES - INICIO - "+DTOC(ddatabase)+" - "+Time())
						FWMsgRun(, {|| _lRet := U_FIN5WS02(_cIntOpcao)}, "Processando Cadastro...", "Integração do cadastro de Aprovadores")
						/*If Select(_cATmpPart) > 0
							(_cATmpPart)->(DbCloseArea())
						EndIf
						
						If _cIntOpcao == "2"
							_cATmpPart	:= U_FIWS3TMP(2,, {"2"}, "2")
							If Select(_cATmpPart) > 0
								(_cATmpPart)->(DbGotop())
								DbSelectArea((_cATmpPart)->ZWQ_CALIAS)
								DbSetOrder((_cATmpPart)->ZWQ_INDICE) //RD0_FILIAL+RD0_CODIGO
								WHile !(_cATmpPart)->(EOF())
									If RD0->(Dbseek((_cATmpPart)->ZWQ_FILALI+(_cATmpPart)->ZWQ_CHAVE))
										FWMsgRun(, {|| _lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
										(_cATmpPart)->(DbSkip())
									EndIf
								EndDo
							EndIf
						Else
							If Select(_cATmpAprov) > 0
								(_cATmpAprov)->(DbCloseArea())
							EndIf
							_cATmpAprov	:= U_FIWS3TMP(7)

							If Select(_cATmpAprov) > 0
								(_cATmpAprov)->(DbGotop())
								WHile !(_cATmpAprov)->(EOF())
									If Select(_cATmpPart) > 0
										(_cATmpPart)->(DbCloseArea())
									EndIf
									_cATmpPart	:= U_FIWS3TMP(1,, {,,,(_cATmpAprov)->RD0_CODIGO})
									(_cATmpPart)->(DbGotop())
									WHile !(_cATmpPart)->(EOF())
										FWMsgRun(, {|| _lRet := U_FINWS06I((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO, "2", "2", "1")}, "Integrando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
										FWMsgRun(, {|| _lRet := U_FINWS03P((_cATmpPart)->RD0_EMPATU, (_cATmpPart)->RD0_FILATU, "RD0", (_cATmpPart)->RD0_FILIAL, (_cATmpPart)->RD0_CODIGO,, "2")}, "Processando Cadastro...", "Aprovador do participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
										(_cATmpPart)->(DbSkip())
									EndDo
									(_cATmpAprov)->(DbSkip())
								EndDo
							EndIf
						EndIf*/
						CONOUT("INTEGRANDO APROVADORES - FIM - "+DTOC(ddatabase)+" - "+Time())
					EndIf
					
					If GetNewPar("ZZ_WSAINT3", .T.) .AND. (_cIntTipo == "1" .OR. _cIntTipo == "4") //"4=Centros de Custos"
						CONOUT("INTEGRANDO CENTROS DE CUSTOS - INICIO - "+DTOC(ddatabase)+" - "+Time())
						FWMsgRun(, {|| _lRet := U_FIN4WS03(_cIntOpcao, _cEmpAtu, _cFilAtu)}, "Processando Cadastro...", "Integração do cadastro de Centros de Custos")

						/*If Select(_cATmpCcusto) > 0
							(_cATmpCcusto)->(DbCloseArea())
						EndIf	

						If _cIntOpcao == "2"
							_cATmpCcusto := U_FIWS3TMP(2,, {"2"}, "3")
							If Select(_cATmpCcusto) > 0
								(_cATmpCcusto)->(DbGotop())
								DbSelectArea((_cATmpCcusto)->ZWQ_CALIAS)
								DbSetOrder((_cATmpCcusto)->ZWQ_INDICE) //CTT_FILIAL+CTT_CUSTO
								WHile !(_cATmpCcusto)->(EOF())
									If CTT->(Dbseek((_cATmpCcusto)->ZWQ_FILALI+(_cATmpCcusto)->ZWQ_CHAVE))
										FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", CTT->CTT_FILIAL, CTT->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->DESC01))
										(_cATmpCcusto)->(DbSkip())
									EndIf
								EndDo
							EndIf									
						Else
							If Select(_cATmpCcusto) > 0
								(_cATmpCcusto)->(DbCloseArea())
							EndIf
							_cATmpCcusto := U_FIWS3TMP(4)
							If Select(_cATmpCcusto) > 0
								(_cATmpCcusto)->(DbGotop())
								WHile !(_cATmpCcusto)->(EOF())
									FWMsgRun(, {|| _lRet := U_FINWS04I(_cEmpAtu, _cFilAtu, (_cATmpCcusto)->CTT_FILIAL, (_cATmpCcusto)->CTT_CUSTO, "2", "3",,, "1")}, "Integrando Cadastro...", "Centro de Custo " + ALLTRIM((_cATmpCcusto)->CTT_CUSTO) + " - " + ALLTRIM((_cATmpCcusto)->DESC01))
									FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "CTT", (_cATmpCcusto)->CTT_FILIAL, (_cATmpCcusto)->CTT_CUSTO,, "3")}, "Processando Cadastro...", "Centro de Custo " + ALLTRIM((_cATmpCcusto)->CTT_CUSTO) + " - " + ALLTRIM((_cATmpCcusto)->DESC01))
									(_cATmpCcusto)->(DbSkip())
								EndDo
							EndIf
						EndIf*/
						CONOUT("INTEGRANDO CENTROS DE CUSTOS - FIM - "+DTOC(ddatabase)+" - "+Time())
					EndIf 
				EndIf

				If GetNewPar("ZZ_WSAINT5", .T.) .AND. (_cPrcTipo == "1" .OR. _cPrcTipo == "3") //3=Pagamentos
					If _cIntTipo == "1" .OR. _cIntTipo == "5" //"5=Despesas/Reembolsos"
						CONOUT("INTEGRANDO DESPESAS - INICIO - "+DTOC(ddatabase)+" - "+Time())
						FWMsgRun(, {|| _lRet := U_FIN7WS05(_cIntOpcao, _cEmpAtu, _cFilAtu)}, "Processando Cadastro...", "Integração das Despesas")

						/*FWMsgRun(, {|| _aRet := U_FIWS7FAL(_cEmpAtu, _cFilAtu,,, .F., .T.)}, "Aguarde", "Consultando as despesas pendentes no Copastur")
						If Len(_aRet) > 0
							DbSelectArea("RD0")
							DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN
							
							For _nX := 1 to Len(_aRet)
								If RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(_aRet[_nX][2]))))
									FWMsgRun(, {|| _lRet := U_FINWS05I(_cEmpAtu, _cFilAtu, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", "5", _aRet[_nX][1],, "1")}, "Integrando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
									FWMsgRun(, {|| _lRet := U_FINWS03P(_cEmpAtu, _cFilAtu, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "5")}, "Processando Despesas...", "Participante " + ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
								EndIf	
							Next
						EndIf */
						CONOUT("INTEGRANDO DESPESAS - FIM - "+DTOC(ddatabase)+" - "+Time())
					EndIf
				EndIf
			EndIf
		EndIf

		DelClassIntf()
		RpcClearEnv()		
	
		CONOUT("INTEGRACAO COPASTUR - FIM - "+DTOC(ddatabase)+" - "+Time())	
	EndIf	

Return
