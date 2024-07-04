#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA223.CH"

#DEFINE PULALINHA	CRLF + CRLF

Static aVldClient		//Dados de acesso do cliente retornados do serviço do PBO

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA223()
Baixa e grava os andamentos automáticos.

@param aParams:     Informações do ambiente
					aParams[1]: Empresa
					aParams[2]: Filial
@param aAutomation: Dados que de automação para validação da regra
					[1]: Lista dos Andamentos a serem gravados
					[1][nI][1]: Número do processo
					[1][nI][2]: Data do Andamento
					[1][nI][3]: Teor

					[2] Lista dos processos que deverão ser recusados.
					[2][nI][1][1]: CNUMEROPROCESSO
					[2][nI][1][2]: Número do processo
					[2][nI][2][1]: CSTATUS
					[2][nI][2][2]: Algum status da Solucionare (Ex: NAO VALIDADO)

@since   26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA223(aParams, aAutomation)
Local lManual     := (aParams == NIL)
Local cEmpImp     := ""
Local cFilImp     := ""
Local lContinua   := .T.
Local dUltAndAut  := CtoD("")
Local aAndamentos := {}
Local cUser       := '000000'

Default aAutomation := {}

	If !lManual
		lContinua := .F.
		VarInfo(STR0001 + "[aParams]", aParams) //"Parametros do schedule de andamentos automaticos: " 
		
		If Len(aParams) >= 2
			lContinua := .T.
			cEmpImp   := aParams[1]
			cFilImp   := aParams[2]

			//Normalmente utiliza-se RPCSetType(3) para informar ao Server que a RPC não consumirá licenças
			RpcSetType(3)
			RPCSetEnv( cEmpImp, cFilImp, , , ,"JURA223")

			__CUSERID := cUser
			
		Else
			JurConOut(STR0002, {JurTimeStamp()}) //"#1 - Aviso: Parametros incorretos no schedule de andamentos automaticos."
		EndIf
	EndIf

	If lContinua
		//Trava a execução para evitar que mais de uma sessão faça a importação de andamentos.
		If !LockByName("JURA223", .T., .T.)
			JurConOut(STR0003, {JurTimeStamp()}) //"#1 - Aviso: Rotina de andamentos automaticos já esta sendo utilizada por outra instancia."
			Return Nil
		Endif

		//Pega a data do ultimo andamento automatico
		dUltAndAut := DtUlAndAut()

		//Atualiza para o proximo dia para buscar os andamentos a partir desta data
		dUltAndAut := IIF(Empty(dUltAndAut), dUltAndAut, dUltAndAut + 1)
		
		//Busca os andamentos
		JurConOut(STR0004, {JurTimeStamp()}) //"#1 - Aviso: Buscando andamentos automaticos."

		aAndamentos := IIf(Len(aAutomation) > 0, aAutomation[1], J223BusAnd(dUltAndAut))
		//Inclui os andamentos
		If Len(aAndamentos) > 0
			JurConOut(STR0005, {JurTimeStamp()}) //"#1 - Aviso: Gravando andamentos automaticos."
			GravaAnds(aAndamentos)
		Else
			JurConOut(STR0006, {JurTimeStamp()}) //"#1 - Aviso: Não existem andamentos automaticos."
		EndIf

		//Processa recusados
		JurConOut(STR0061, {JurTimeStamp()}) //"#1 - Aviso: Analisando processos recusados."

		IIf(Len(aAutomation) > 0, ProcRecusa(aAutomation[2]), ProcRecusa())

		JurConOut(STR0007, {JurTimeStamp()}) //"#1 - Aviso: Fim do processamento dos andamentos automaticos."
	EndIf

	//limpa o array
	aSize(aAndamentos, 0)
	
	//Libera a execução do login
	UnLockByName("JURA223", .T., .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J223CadPro()
Função que ira cadastrar o processo no parceiro para que ele receba os
andamentos automaticamente.

@return lRetorno
 
@author  Rafael Tenorio da Costa
@since 	 26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223CadPro(cNumPro, cUf, cComarca, cPartes, cTribunal, lVldCNJ)
Local aArea     := GetArea()
Local lRetorno  := .T.
Local oWS       := Nil
Local cReturn   := ""
Local aDadosCli := {}
Local aDadosTri := {}

Default cComarca  := ""
Default cPartes   := ""
Default cTribunal := ""
Default lVldCNJ   := .F.

	cNumPro := AllTrim(cNumPro)

	//Valida se o cliente está habilitado para andamentos automáticos
	aDadosCli := VldClient()
	If Len(aDadosCli) > 0
	
		If lVldCNJ
			//Tira pontos e traços do numero do processo caso existam
			cNumPro := StrTran(cNumPro, "-", "")
			cNumPro := StrTran(cNumPro, ".", "")

			cNumPro	 	:= AllTrim( Transform(cNumPro, "@R XXXXXXX-XX.XXXX.X.XX.XXXX") )
			aDadosTri 	:= GetTribunal(cNumPro, @cReturn) 

			//Valida informações do tribunal
			If Len(aDadosTri) == 0
				lRetorno := .F.
			Else
				cComarca  := ""
				cTribunal := aDadosTri[1]
				cUf       := aDadosTri[2]
			EndIf
		Else
			cComarca  := AllTrim(POSICIONE("NQ6", 1, xFilial("NQ6") + cComarca, "NQ6_DESC"))
			cTribunal := AllTrim(POSICIONE("NQC", 1, xFilial("NQC") + cTribunal, "NQC_DESC"))
		EndIf
		
		If lRetorno
		
			oWS := JURA224():New()
			
			oWS:cNomeRelacional	:= aDadosCli[1]			//Nome do cliente junto a vista. (Obrigatório)
			oWS:cToken			:= aDadosCli[2]			//Senha para integração do webservice. (Obrigatório)
			oWS:cNProcesso		:= cNumPro				//Número do processo no padrão da CNJ, com os pontos e traços. (Obrigatório)
			oWS:cUf				:= cUf					//UF (Estado) do processo em 2 digitos. (Obrigatório)
			oWS:cComarca		:= AllTrim(cComarca)	//Comarca de onde o processo iniciou.
			oWS:cTribunal		:= cTribunal			//Tribunal de onde o processo iniciou. (Obrigatório)
			oWS:nCodEscritorio	:= aDadosCli[3]			//Código do escritório em que esse processo estará relacionado. (Obrigatório)
			oWS:cPartes			:= cPartes				//Nome das partes em que o processo esta relacionado, separados por “;”

			If oWS:cadastrar()
			
				If oWS:cReturn <> Nil 

					cReturn := oWS:cReturn
					cReturn := AllTrim( Upper(cReturn) ) 

					If !((cNumPro $ cReturn) .Or. (cReturn == STR0066) .OR. (cReturn == '0')) //"PROCESSO JÁ CADASTRADO"
						lRetorno := .F.
					EndIf	
				EndIf

			Else
		
				If Empty(cReturn)
					cReturn := GetWSCError()
				EndIf	
		
				JurMsgErro( STR0008 + PULALINHA +;	//"Não foi possível incluir o processo no recebimento de andamentos automático."
							STR0009 + cReturn)		//"Erro: "
			EndIf

			FwFreeObj(oWS)
		EndIf
	Else
	
		lRetorno := .F.
		JurMsgErro( STR0010 + CRLF +;	//"Cliente não esta habilitado a utilizar a funcionalidade de recebimento de andamentos automático."
					STR0011 + CRLF +;	//"Processo não será incluído no recebimento automático de andamentos."
					STR0012)			//"Entre em contato com a TOTVS."
	EndIf
	
	RestArea( aArea )
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J223ExcPro()
Função exclui o processo no parceiro para que ele não receba os 
andamentos automaticamente.

@return lRetorno
 
@author  Rafael Tenorio da Costa
@since 	 26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223ExcPro(cNumPro, lVldCNJ)

	Local aArea		:= GetArea()
	Local lRetorno	:= .F.
	Local oWS 		:= Nil
	Local aDadosCli := {}
	
	Default lVldCNJ := .F.

	//Valida se o cliente está habilitado para andamentos automáticos
	aDadosCli := VldClient()
	If Len(aDadosCli) > 0
	
		If lVldCNJ
			//Tira pontos e traços do numero do processo caso existam
			cNumPro := StrTran(cNumPro, "-", "")
			cNumPro := StrTran(cNumPro, ".", "")
			cNumPro := AllTrim(cNumPro)
			cNumPro := Transform(cNumPro, "@R XXXXXXX-XX.XXXX.X.XX.XXXX")
		EndIf
	
		oWS := JURA224():New()
		
		oWS:cnomeRelacional	:= aDadosCli[1]		//Nome do cliente junto a vista. (Obrigatório)
		oWS:ctoken			:= aDadosCli[2]		//Senha para integração do webservice. (Obrigatório)
		oWS:cnProcesso		:= cNumPro			//Número do processo no padrão da CNJ, com os pontos e traços. (Obrigatório)
		oWS:ncodEscritorio	:= aDadosCli[3]		//Código do escritório em que esse processo estará relacionado. (Obrigatório)
		
		If oWS:remover()
		
			If oWS:lReturn <> Nil
			
				//Se o retorno for falso o processo já não existe, retorno true o processo existia e foi excluido
				//If oWS:removerResponse:return
					lRetorno := .T.
				//EndIf	
			EndIf
		EndIf
		
		If !lRetorno
			JurMsgErro( STR0013 + PULALINHA +;		//"Não foi possível excluir o processo do recebimento de andamentos automático."
						STR0009 + GetWSCError())	//"Erro: "
		EndIf	
			
		FwFreeObj(oWS)
	Else
	
		lRetorno := .F.
		JurMsgErro( STR0010 + CRLF +;	//"Cliente não esta habilitado a utilizar a funcionalidade de recebimento de andamentos automático."
					STR0014 + CRLF +;	//"Processo não será excluído do recebimento automático de andamentos."
					STR0012)			//"Entre em contato com a TOTVS."
	EndIf
	
	RestArea( aArea )
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J223BusAnd()
Função que busca os andamentos automaticamente.

@return aAndamentos
 
@author  Rafael Tenorio da Costa
@since 	 26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223BusAnd(dData)

	Local aArea			:= GetArea()
	Local aCajuris		:= {}
	Local aDadosCli 	:= {}
	Local aDados		:= {}
	Local aDadosAnd		:= {}
	Local aAndamentos 	:= {}
	Local oWS 			:= Nil
	Local cData			:= ""
	Local nProcesso		:= 0

	//Valida se o cliente está habilitado para andamentos automáticos
	aDadosCli := VldClient()
	If Len(aDadosCli) > 0
	
		//Prepara a data que sera utilizada para filtrar os andamentos que serão retornados
		If !Empty(dData)
			cData 	:= DtoS(dData)
			cData 	:= SubStr(cData, 1, 4) + "-" + SubStr(cData, 5, 2) + "-" + SubStr(cData, 7, 2)
		EndIf	  
	
		oWS := JURA224():New()
		
		oWS:cnomeRelacional	:= aDadosCli[1]		//Nome do cliente junto a vista. (Obrigatório)
		oWS:ctoken			:= aDadosCli[2]		//Senha para integração do webservice. (Obrigatório)
		oWS:ncodEscritorio	:= aDadosCli[3]		//Código do escritório em que esse processo estará relacionado. (Obrigatório)
		oWS:cdata			:= cData			//Data no padrão (2015-09-17 00:00:00). A pesquisa será feita buscando os processos que tiveram andamentos a partir da data.
		
		If oWS:getAndamentosAtualizados()
		
			//Verifica se existe processos
			If oWS:oWsGetAndamentosAtualizadosReturn:oWsProcesso <> Nil
			
				aDados := oWS:oWsGetAndamentosAtualizadosReturn:oWsProcesso
				
				For nProcesso:=1 To Len(aDados)
				
					cNumPro := AllTrim( aDados[nProcesso]:cNumeroProcesso )

					//Verifica se o processo tem andamento
					If aDados[nProcesso]:oWsAndamentos <> Nil .And. aDados[nProcesso]:oWsAndamentos:oWsAndamento <> Nil
						//Busca todos os assuntos juridicos tem quem este numero do processo
						aCajuris := BusCajuris( cNumPro )
						If len(aCajuris) > 0
							aDadosAnd := aDados[nProcesso]:oWsAndamentos:oWsAndamento
							Aadd(aAndamentos, {aCajuris,aDadosAnd,cNumPro})
						Endif
					EndIf
				Next nProcesso
			EndIf
		Else
		
			JurMsgErro( STR0015 + PULALINHA +;		//"Não foi possível receber os andamentos automático."
						STR0009 + GetWSCError())	//"Erro: "
		EndIf
	Else
	
		JurMsgErro( STR0010 + CRLF +;	//"Cliente não esta habilitado a utilizar a funcionalidade de recebimento de andamentos automático."
					STR0012)			//"Entre em contato com a TOTVS."
	EndIf
	
	RestArea( aArea )
	
Return aAndamentos

//-------------------------------------------------------------------
/*/{Protheus.doc} J223ProCad()
Função que retorna os processos que estão cadastrados para recebimento
de andamentos automáticamente.

@return aProcessos
 
@author  Rafael Tenorio da Costa
@since 	 26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223ProCad()

	Local aArea      := GetArea()
	Local oWS        := Nil
	Local aDadosCli  := {}
	Local aDados     := {}
	Local aProcessos := {}
	Local nCont      := 0	

	//Valida se o cliente está habilitado para andamentos automáticos
	aDadosCli := VldClient()
	If Len(aDadosCli) > 0
	
		oWS := JURA224():New()
		
		oWS:cnomeRelacional	:= aDadosCli[1]		//Nome do cliente junto a vista. (Obrigatório)
		oWS:ctoken			:= aDadosCli[2] 	//Senha para integração do webservice. (Obrigatório)
		
		If oWS:getAndamentos()
		
			If oWS:oWSgetAndamentosReturn:oWsProcesso <> Nil
			
				//Pega os processos cadastrados
				aDados := oWS:oWSgetAndamentosReturn:oWsProcesso
				
				For nCont:=1 To Len(aDados)
				
					//Carrega os dados dos processos
					Aadd(aProcessos, {	{"CNUMEROPROCESSO"			, AllTrim( aDados[nCont]:cNumeroProcesso )	}	,;
										{"CDATAATUALIZACAOPROCESSO"	, aDados[nCont]:cDataAtualizacaoProcesso	}	,;
										{"CAUTOR"					, aDados[nCont]:cAutor						}	,;
										{"CREU"						, aDados[nCont]:cReu						}	,;
										{"CUF"						, aDados[nCont]:cUf							}	,;
										{"CTRIBUNAL"				, aDados[nCont]:cTribunal					}	,;
										{"CCOMARCA"					, aDados[nCont]:cComarca					}	,;
										{"CFORUM"					, aDados[nCont]:cForum						}	,;
										{"CVARA"					, aDados[nCont]:cVara						}	,;
										{"CSTATUS"					, AllTrim( Upper(aDados[nCont]:cStatus) )	}	}	)
				Next nCont
			EndIf
		EndIf
		
		FwFreeObj(aDados)	
		FwFreeObj(oWS)
	Else
	
		JurMsgErro(	STR0010 + CRLF +;	//"Cliente não esta habilitado a utilizar a funcionalidade de recebimento de andamentos automático."
					STR0012)			//"Entre em contato com a TOTVS."
	EndIf
	
	RestArea( aArea )
	
Return aProcessos

//-------------------------------------------------------------------
/*/{Protheus.doc} J223ProAge()
Função que retorna os processos que estão agendados. Este processos estão
A VALIDAR ou NÃO FORAM VALIDADOS pela VISTA, por causa de alguma informação.

@return aProcessos
 
@author  Rafael Tenorio da Costa
@since 	 15/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223ProAge()

	Local aArea			:= GetArea()
	Local oWS 			:= Nil
	Local aDadosCli 	:= {}
	Local aDados		:= {}
	Local aProcessos 	:= {}
	Local nCont			:= 0	

	//Valida se o cliente está habilitado para andamentos automáticos
	aDadosCli := VldClient()
	If Len(aDadosCli) > 0
	
		oWS := JURA224():New()
		
		oWS:cnomeRelacional	:= aDadosCli[1]		//Nome do cliente junto a vista. (Obrigatório)
		oWS:ctoken			:= aDadosCli[2] 	//Senha para integração do webservice. (Obrigatório)
		
		If oWS:getAndamentosAgendados()
		
			If oWS:oWSgetAndamentosAgendadosReturn:oWsProcesso <> Nil
			
				//Pega os processos cadastrados
				aDados := oWS:oWSgetAndamentosAgendadosReturn:oWsProcesso
				
				For nCont:=1 To Len(aDados)
					If aDados[nCont]:nCodEscritorio == aDadosCli[3]
						//Carrega os dados dos processos
						Aadd(aProcessos, {	{"CNUMEROPROCESSO"			, AllTrim( aDados[nCont]:cNumeroProcesso )	}	,;
											{"CDATAATUALIZACAOPROCESSO"	, aDados[nCont]:cDataAtualizacaoProcesso	}	,;
											{"CAUTOR"					, aDados[nCont]:cAutor						}	,;
											{"CREU"						, aDados[nCont]:cReu						}	,;
											{"CUF"						, aDados[nCont]:cUf							}	,;
											{"CTRIBUNAL"				, aDados[nCont]:cTribunal					}	,;
											{"CCOMARCA"					, aDados[nCont]:cComarca					}	,;
											{"CFORUM"					, aDados[nCont]:cForum						}	,;
											{"CVARA"					, aDados[nCont]:cVara						}	,;
											{"CSTATUS"					, AllTrim( Upper(aDados[nCont]:cStatus) )	}	}	)
					EndIf
				Next nCont
			EndIf
		EndIf
		
		FwFreeObj(aDados)	
		FwFreeObj(oWS)
	Else
	
		JurMsgErro(	STR0010 + CRLF +;	//"Cliente não esta habilitado a utilizar a funcionalidade de recebimento de andamentos automático."
					STR0012)			//"Entre em contato com a TOTVS."
	EndIf
	
	RestArea( aArea )
	
Return aProcessos

//-------------------------------------------------------------------
/*/{Protheus.doc} VldClient()
Função que valida o cliente junto a Totvs, para ver se ele está habilitado
para o recebimento de andamentos automáticos.

@return aDados
 
@author  Rafael Tenorio da Costa
@since 	 26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldClient()

	Local aDados 	:= {}
	Local cUsuario	:= SuperGetMV('MV_JINDUSR', , "")
	Local cSenha   	:= SuperGetMV('MV_JINDPSW', , "")
	Local lRetorno	:= .F.
	Local oWS		:= Nil
	
	//Verifica se ja carregou os dados do cliente	
	If aVldClient <> Nil
		aDados := aClone(aVldClient)
	Else	
	
		oWS := JURA224A():New()
		
		oWS:cUSUARIO := cUsuario
		oWS:cSENHA   := cSenha
		
		If oWS:MTANDAMENTOS()
			If oWS:oWsMtAndamentosResult <> Nil
			
				lRetorno := .T.
				
				Aadd(aDados, oWS:oWsMtAndamentosResult:cNomeRelacional		)
				Aadd(aDados, oWS:oWsMtAndamentosResult:cToken				)
				Aadd(aDados, Val(oWS:oWsMtAndamentosResult:cCodEscritorio)	)
				
				aVldClient := aClone(aDados)
			EndIf
		EndIf
		
		If !lRetorno
			JurMsgErro( STR0016 + PULALINHA +;		//"Erro ao validar serviço de monitoramento TOTVS. (MTANDAMENTOS)"
						STR0009 + GetWSCError())	//"Erro: "
			aVldClient := Nil
		EndIf
		
		FwFreeObj(oWS)
	EndIf
	
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} DtUlAndAut()
Busca data do ultimo andamento automático.

@return dData - Data do ultimo andamento automático
 
@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DtUlAndAut()

	Local aArea	 	:= GetArea()
	Local dData  	:= CtoD("")		//Caso não tenha andamentos automaticos retorna em branco para pegar todos os andamentos
	Local cQuery 	:= ""
	Local aRetorno 	:= {}
	
	cQuery := " SELECT NT4_DTANDA"
	cQuery += " FROM " + RetSqlName("NT4")
	cQuery += " WHERE NT4_FILIAL = '" + xFilial("NT4") + "'"  
  	cQuery += 	" AND NT4_ANDAUT = '1'"
	cQuery += 	" AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY NT4_DTANDA DESC"
		
	aRetorno := JurSQL(cQuery, {"NT4_DTANDA"})

	If Len(aRetorno) > 0
		dData := StoD( aRetorno[1][1] )
	EndIf
	
	RestArea( aArea )

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaAnds
Grava os andamentos

@return dData - Data do ultimo andamento automático
 
@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaAnds(aAndamentos)

	Local aArea     := GetArea()
	Local aCajuris  := {}
	Local dDataAnd  := CtoD("")
	Local lRetorno  := .T.
	Local nCont     := 1
	Local nContAnd 	:= 1
	Local cAto      := ""
	Local cDesc 	:= ""
	Local cNumPro   := ""

	For nCont := 1 To Len(aAndamentos)
		If(VALTYPE(aAndamentos[nCont][2]) == "A")
			For nContAnd:=1 To Len(aAndamentos[nCont][2])
							
				If aAndamentos[nCont][2][nContAnd]:cData <> Nil
					dDataAnd := StoD( StrTran( SubStr( aAndamentos[nCont][2][nContAnd]:cData, 1, 10), "-", "") )
					cDesc := AllTrim( aAndamentos[nCont][2][nContAnd]:cTexto)
					cDesc := StrTran(cDesc, Chr(10), " ")
					cDesc := AllTrim(StrTran(cDesc, Chr(13), " "))
				EndIf

				aCajuris := aAndamentos[nCont][1]
				cNumPro  := aAndamentos[nCont][3]
				
				cAto	 := ""
				If Empty(cDesc)
					cDesc := STR0067 //"Descrição não recebida"
				EndIf
				//Verifica se o andamento ja esta cadastrado
				If !VldAnd(cNumPro, dDataAnd, cDesc)
					lRetorno := InsertAnd(dDataAnd, cDesc, aCajuris)
				EndIf
			Next nContAnd
		Else
			cNumPro  := aAndamentos[nCont][1]
			dDataAnd := aAndamentos[nCont][2]
			cDesc	 := AllTrim( aAndamentos[nCont][3] )
			cDesc 	 := StrTran(cDesc, Chr(10), " ")
			cDesc 	 := StrTran(cDesc, Chr(13), " ")
			If !VldAnd(cNumPro, dDataAnd, cDesc)
				aCajuris := BusCajuris(cNumPro)
				lRetorno := InsertAnd(dDataAnd, cDesc, aCajuris)
			EndIf
		EndIf
	Next nCont

	RestArea( aArea )
	FwFreeObj(aAndamentos)	

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAnd()
Verifica se o andamento ja esta cadastrado

@return lRetorno - 
 
@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldAnd(cNumPro, dDataAnd, cDesc)

	Local aArea	   := GetArea()
	Local cTmp     := GetNextAlias()
	Local cBanco   := Upper( TcGetDb() )
	Local cQuery   := ""
	Local lRetorno := .F.
	
	//Tira pontos e traços do numero do processo
	cNumPro := StrTran(cNumPro, "-", "")
	cNumPro := StrTran(cNumPro, ".", "")
	cNumPro := AllTrim(cNumPro)
	
	//Limpa campo para pesquisa pela descrição
	cDesc := Substring(Replace(Lower(cDesc),' ',''),0,2000)
	cDesc := Replace(cDesc,"'","")
	cQuery := " SELECT COUNT(*) qtd"
	cQuery += " FROM " + RetSqlName("NUQ") + " NUQ INNER JOIN " + RetSqlName("NT4") + " NT4"
	cQuery += " ON NUQ_FILIAL = NT4_FILIAL AND NUQ_CAJURI = NT4_CAJURI AND NUQ.D_E_L_E_T_ = NT4.D_E_L_E_T_"
	cQuery += " WHERE NUQ_FILIAL = '" + xFilial("NUQ") + "'"  
	cQuery += " AND RTRIM( LTRIM(NUQ_NUMPRO) ) = '" + cNumPro + "'"
	cQuery += " AND NT4_ANDAUT = '1'"
	cQuery += " AND NT4_DTANDA = '" + DtoS(dDataAnd) + "'"
	cQuery += " AND SUBSTRING(REPLACE(" + JurLower(TamSx3("NT4_DESC")[3], "NT4_DESC", cBanco) + ",' ',''),0,2000) LIKE '%" + cDesc + "%'"
	cQuery += " AND NUQ.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cQuery := strtran(cQuery, ",' ')", ",'')")
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmp, .T., .F. )

	If !(cTmp)->(EOF()) .AND. (cTmp)->qtd > 0
		lRetorno := .T.
	EndIf
	(cTmp)->( dbCloseArea() )
	RestArea(aArea)

Return lRetorno
		
//-------------------------------------------------------------------
/*/{Protheus.doc} BusCajuris()
Busca todos os codigo de assunto jurídico a que o numero do processo pertente.

@return aRetorno - 
 
@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BusCajuris(cNumPro)

	Local aArea    := GetArea()
	Local cQuery   := ""
	Local aRetorno := {}

	//Tira pontos e traços do numero do processo
	cNumPro := StrTran(cNumPro, "-", "")
	cNumPro := StrTran(cNumPro, ".", "")
	cNumPro := AllTrim(cNumPro)
	
	cQuery := " SELECT NUQ_CAJURI, NSZ_TIPOAS, NUQ.R_E_C_N_O_ RECNONUQ, NUQ_CNATUR"
	cQuery += " FROM " + RetSqlName("NUQ") + " NUQ INNER JOIN " + RetSqlName("NSZ") + " NSZ"
	cQuery += 	" ON NUQ_FILIAL = NSZ_FILIAL AND NUQ_CAJURI = NSZ_COD AND NUQ.D_E_L_E_T_ = NSZ.D_E_L_E_T_"
	cQuery += " WHERE NUQ_FILIAL = '" + xFilial("NUQ") + "'"
	cQuery += 	" AND NUQ_ANDAUT = '1'" //1=Andamento Automatico - só inclui para processos que ainda estão com andamento automatico ativo  
  	cQuery += 	" AND RTRIM( LTRIM(NUQ_NUMPRO) ) = '" + cNumPro + "'"
	cQuery += 	" AND NUQ.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY NUQ_CAJURI"
	
	aRetorno := JurSQL(cQuery, {"NUQ_CAJURI", "NSZ_TIPOAS", "RECNONUQ", "NUQ_CNATUR"})

	RestArea( aArea )

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J223Wizard()
Wizard para configuração do Andamento Automatico

@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223Wizard()

	Local aArea      := GetArea()
	Local oWizard    := Nil
	Local nPanel     := 1
	Local oPanel1    := Nil
	Local oLayer1    := Nil
	Local oColumn1   := Nil 
	Local cUsuario   := SuperGetMV('MV_JINDUSR', , "")
	Local cSenha     := SuperGetMV('MV_JINDPSW', , "") 
	Local oPanel2    := Nil
	Local oLayer2    := Nil
	Local oColumn2   := Nil
	Local lChkInsAtu := .F.
	Local lChkProAnd := .F.
	Local lChkProAdm := .F.
	Local oPanel3    := Nil
	Local oLayer3    := Nil
	Local oColumn3   := Nil
	Local oColumn3_1 := Nil
	Local aHeader    := {}
	Local aCols      := {}
	Local oPanel6    := Nil
	Local oLayer6    := Nil
	Local oColumn6   := Nil
	Local nQtdPro    := 0
	
	DbSelectArea("NUQ")
	If !( ColumnPos("NUQ_ANDAUT") > 0 )
		MsgInfo(STR0018, "J223Wizard")		//"É necessario a atualização do release."
		Return Nil
	EndIf

	aSizeD := FWGetDialogSize( oMainWnd )
	aCoord := { aSizeD[1]*0.50, aSizeD[2]*0.50, aSizeD[3]*0.70, aSizeD[4]*0.50 }

	oWizard := APWizard():New(	STR0019/*<chTitle>*/,;	//"Atenção"
								STR0020/*<chMsg>*/,;	//"Este assistente o auxiliara na configuração do serviço de monitoramento TOTVS."
								STR0021/*<cTitle>*/,;	//"Configuração do serviço de monitoramento TOTVS"
								STR0022/*<cText>*/,;	//"Neste assistente será configurado todo o modo de funcionamento para ter acesso ao serviço de monitoramento TOTVS, e assim receber os Andamentos de forma Automática."
								{|| .T.}/*<bNext>*/, ;
								{|| .T.}/*<bFinish>*/,;
								/*<lPanel>*/,;
								/*<cResHead> */,;
								/*<bExecute>*/,;
								/*<lNoFirst>*/,;
								aCoord/*<aCoord>*/)

	//---------- Panel Usuário e Senha ----------
	If Empty(cUsuario) .Or. Empty(cSenha)
	
		cUsuario := IIF(Empty(cUsuario)	, Space(100), cUsuario)  
		cSenha   := IIF(Empty(cSenha)	, Space(100), cSenha)
	
		oWizard:NewPanel(	STR0023/*<chTitle>*/,;	//"Usuário e Senha"
							STR0024/*<chMsg>*/, ;	//"Neste passo deve-se informar o Usuário e Senha cadastrado junto ao serviço de monitoramento TOTVS."
						 	{||.T.}/*<bBack>*/, ;
						 	{|| !(Empty(cUsuario) .And. Empty(cSenha)) }/*<bNext>*/, ;
						 	{||.T.}/*<bFinish>*/,;
						 	.T./*<.lPanel.>*/,;
						 	{||.T.}/*<bExecute>*/)
	
		nPanel++
		oPanel1 := oWizard:GeTPanel(nPanel)
		oLayer1 := FWLayer():New()
		oLayer1:Init(oPanel1, .F.)
		oLayer1:AddCollumn("BOX_FULL", 100, .F.)
	
		oColumn1 		:= oLayer1:getColPanel("BOX_FULL", Nil)
		oColumn1:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
		TSay():New(oColumn1:nTop + 12, oColumn1:nLeft + 10, {|| STR0025 }, oColumn1,,,,,, .T.,,, 050, 08)	//"Usuário.:"
		TGet():New(oColumn1:nTop + 10, oColumn1:nLeft + 40, {|u| If(PCount()>0, cUsuario:=u, cUsuario)}, oColumn1, 150, 10,,,,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F., , cUsuario)
		
		TSay():New(oColumn1:nTop + 32, oColumn1:nLeft + 10, {|| STR0026 }, oColumn1,,,,,, .T.,,, 050, 08)	//"Senha.:"
		TGet():New(oColumn1:nTop + 30, oColumn1:nLeft + 40, {|u| If(PCount()>0, cSenha:=u, cSenha)}, oColumn1, 150, 10,,,,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F., , cSenha)
	EndIf

	//---------- Panel Processos já cadastrados ----------
	oWizard:NewPanel(	STR0027/*<chTitle>*/,;	//"Deseja receber andamentos de processos já cadastrados"
						STR0028 + CRLF + STR0029/*<chMsg>*/, ;	//"Neste ponto serão definidos os processos já cadastrados que serão incluídos no serviço de monitoramento TOTVS."		//"Os processos aqui selecionados terão seus Andamentos recebidos de forma Automática na próxima janela de atualização do serviço."
					 	{||.T.}/*<bBack>*/, ;
					 	{||.T.}/*<bNext>*/, ;
					 	{||.T.}/*<bFinish>*/,;
					 	.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/)

	nPanel++
	oPanel2 := oWizard:GeTPanel(nPanel)
	oLayer2 := FWLayer():New()
	oLayer2:Init(oPanel2, .F.)
	oLayer2:AddCollumn("BOX_FULL", 100, .F.)

	oColumn2 		:= oLayer2:getColPanel("BOX_FULL", Nil)
	oColumn2:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
	TCheckBox():New(oColumn2:nTop + 10, oColumn2:nLeft + 10, STR0030, {|u|if( pcount()>0, lChkInsAtu:= u, lChkInsAtu)}, oColumn2, 300, 210,,,,,,,, .T.,,,)	//"Apenas instâncias atuais"
	TCheckBox():New(oColumn2:nTop + 20, oColumn2:nLeft + 10, STR0031, {|u|if( pcount()>0, lChkProAnd:= u, lChkProAnd)}, oColumn2, 300, 210,,,,,,,, .T.,,,)	//"Apenas processos em andamento"
	TCheckBox():New(oColumn2:nTop + 30, oColumn2:nLeft + 10, STR0068, {|u|if( pcount()>0, lChkProAdm:= u, lChkProAdm)}, oColumn2, 300, 210,,,,,,,, .T.,,,)  //"Processos Administrativos"
	
	//---------- Panel Configurando Parâmetros ----------
	oWizard:NewPanel(	STR0032/*<chTitle>*/,;	//"Configuração de Parâmetros"
						STR0033/*<chMsg>*/, ;	//"Como este serviço será ativado por Tipo de Assunto Jurídico, será necessário configurar alguns parâmetros."
					 	{||.T.}/*<bBack>*/, ;
					 	{|| VldCfgPar(aHeader, aCols)[1]}/*<bNext>*/, ;
					 	{||.T.}/*<bFinish>*/,;
					 	.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/)

	nPanel++
	oPanel3 := oWizard:GeTPanel(nPanel)
	oLayer3 := FWLayer():New()
	oLayer3:Init(oPanel3, .F.)
	
	oLayer3:AddLine('ACIMA', 55, .F.)
	oLayer3:AddCollumn('ALL', 100, .T., 'ACIMA')
	oColumn3 		:= oLayer3:GetColPanel( 'ALL', 'ACIMA' )
	oColumn3:Align 	:= CONTROL_ALIGN_ALLCLIENT

	oLayer3:AddLine('ABAIXO', 45, .F. )
	oLayer3:AddCollumn('ALL' , 100, .T., 'ABAIXO')
	oColumn3_1		 := oLayer3:GetColPanel('ALL', 'ABAIXO')
	oColumn3_1:Align := CONTROL_ALIGN_ALLCLIENT
	
				//Título , Campo			, Picture, Tamanho				, Decimal, Validação									, Usado  , Tipo, F3	  , Context , Cbox		, Relacao, When							, Visual, VldUser, Obrigatorio, IniBrw
	aHeader := {}
	Aadd(aHeader,{STR0034, "COD"			, ""	  , TamSx3("NYB_COD")[1], 0	     , ""		  									, ""	 , "C" , ""	  ,	""	    })															//"Cód"
	Aadd(aHeader,{STR0035, "ASSUNTO"		, ""	  , 20	   				, 0	     , ""		  									, ""	 , "C" , ""	  ,	""	    })															//"Assunto"
	Aadd(aHeader,{STR0036, "AUTOMATICO"	 	, ""	  , 1	   				, 0	     , "J223VldCmp('AUTOMATICO',M->AUTOMATICO)"		, ""	 , "C" , ""	  ,	""	    , STR0037	})												//"And. Automático"	//"1=Sim;2=Não"	
	Aadd(aHeader,{STR0038, "ENCERRAMENTO" 	, ""	  , 1	   				, 0	     , "J223VldCmp('ENCERRAMENTO',M->ENCERRAMENTO)"	, ""	 , "C" , ""	  ,	""	    , STR0037	 ,""		 , "J223AtvCmp()"				})	//"Encerramento"	//"1=Sim;2=Não"
	Aadd(aHeader,{STR0039, "MODO" 		 	, ""	  , 1	   				, 0	     , "Pertence('12')"								, ""	 , "C" , ""	  ,	""	    , STR0040	 ,""		 , "J223AtvCmp()"				})	//"Modo"			//"1=Por processo;2=Por instância"
	Aadd(aHeader,{STR0041, "ATO"			, ""	  , TamSx3("NRO_COD")[1], 0	     , "ExistCpo('NRO',M->ATO,1)"					, ""	 , "C" , "NRO",	""		,""			 ,""		 , "J223AtvCmp()"				})	//"Ato"
	Aadd(aHeader,{STR0042, "JUSTIFICATIVA"	, ""	  , TamSx3("NQX_COD")[1], 0	     , "ExistCpo('NQX',M->JUSTIFICATIVA,1)"			, ""	 , "C" , "NQX",	""		,""			 ,"" 		 , "J223AtvCmp('JUSTIFICATIVA')"})	//"Justificativa"


	//Carrega tipos de assuntos jurídicos
	aCols := CarregaAsj()

	//Cria grid
	oGet := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, "J223VlLiWi()",,, {"AUTOMATICO","ENCERRAMENTO","MODO","ATO","JUSTIFICATIVA"}, 0, 9999,,,, oColumn3, aHeader, aCols)
	oGet:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT
	oGet:aCols 			:= aCols
	oGet:Refresh()
	
	TSay():New(oColumn3_1:nTop 		, oColumn3_1:nLeft + 10, {|| STR0043}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"And. Automático - Define se deseja receber andamentos de forma automática"
	TSay():New(oColumn3_1:nTop + 11	, oColumn3_1:nLeft + 10, {|| STR0044}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"Encerramento - Define se os processos encerrados devem ser removidos do serviço de monitoramento TOTVS"
	
	TSay():New(oColumn3_1:nTop + 20	, oColumn3_1:nLeft + 10, {|| STR0045}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"Modo - Define o como irá ser feita a inclusão do processo no serviço de monitoramento TOTVS"
	TSay():New(oColumn3_1:nTop + 28	, oColumn3_1:nLeft + 18, {|| STR0046}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"1 = Por Processo - Todas as instâncias do processo serão cadastradas"
	TSay():New(oColumn3_1:nTop + 36	, oColumn3_1:nLeft + 18, {|| STR0047}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"2 = Por Instância - Será selecionada manualmente a instância que deve ser cadastrada"
	
	TSay():New(oColumn3_1:nTop + 45	, oColumn3_1:nLeft + 10, {|| STR0048}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"Ato - Define o ato processual que deve ser utilizado para cadastrar os andamentos recebidos de forma automática"
	TSay():New(oColumn3_1:nTop + 54	, oColumn3_1:nLeft + 10, {|| STR0049}	, oColumn3_1,,,,,, .T.,,, 290, 008)	//"Justificativa - Define qual motivo de justificativa deve ser informado para incluir andamentos em processos encerrados."
	
	//---------- Panel Resumo ----------
	oWizard:NewPanel(	STR0050/*<chTitle>*/,;	//"Resumo"
						STR0051/*<chMsg>*/, ;	//"Veja as configurações que serão feitas"
					 	{||.T.}/*<bBack>*/, ;
					 	{||.T.}/*<bNext>*/, ;
					 	{|| HabAndAut(cUsuario, cSenha, aHeader, aCols, lChkInsAtu, lChkProAnd, lChkProAdm)}/*<bFinish>*/,;
					 	.T./*<.lPanel.>*/,;
					 	{|| nQtdPro := QtdProcess(lChkInsAtu, lChkProAnd, lChkProAdm, aHeader, aCols), .T.}/*<bExecute>*/)

	nPanel++
	oPanel6 := oWizard:GeTPanel(nPanel)
	oLayer6 := FWLayer():New()
	oLayer6:Init(oPanel6, .F.)
	oLayer6:AddCollumn("BOX_FULL", 100, .F.)

	oColumn6 		:= oLayer6:getColPanel("BOX_FULL", Nil)
	oColumn6:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
	TSay():New(oColumn6:nTop + 010, oColumn6:nLeft + 10, {|| STR0025 + AllTrim(cUsuario)	}, oColumn6,,,,,, .T.,,, 200, 008)	//"Usuario: "
	TSay():New(oColumn6:nTop + 018, oColumn6:nLeft + 10, {|| STR0026 + AllTrim(cSenha)		}, oColumn6,,,,,, .T.,,, 200, 008)	//"Senha..: "
	
	TSay():New(oColumn6:nTop + 040, oColumn6:nLeft + 10, {|| STR0052						}, oColumn6,,,,,, .T.,,, 290, 008)	//"Processos já cadastrados que serão incluídos no serviço de monitoramento TOTVS:"
	TSay():New(oColumn6:nTop + 048, oColumn6:nLeft + 20, {|| cValToChar(nQtdPro)			}, oColumn6,,,,,, .T.,,, 290, 008)
	
	TSay():New(oColumn6:nTop + 070, oColumn6:nLeft + 10, {|| STR0053					 	}, oColumn6,,,,,, .T.,,, 290, 008)	//"Tipos de Assunto Jurídico que serão habilitados no serviço de monitoramento TOTVS:"
	TSay():New(oColumn6:nTop + 078, oColumn6:nLeft + 20, {|| VldCfgPar(aHeader, aCols)[2]	}, oColumn6,,,,,, .T.,,, 290, 056)
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
					 {||.T.}/*<bValid>*/,;
					 {||.T.}/*<bInit>*/	,;
					 {||.T.}/*<bWhen>*/ )
					 
	FreeObj( oWizard )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdProcess()
Carrega a quantidade de processos que seram cadastrados no serviço de
monitoramento TOTVS.

@author  Rafael Tenorio da Costa
@since 	 01/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function QtdProcess(lChkInsAtu, lChkProAnd, lChkProAdm, aHeader, aCols)

	Local aArea  	:= GetArea()
	Local cQuery 	:= ""
	Local aAux		:= {}
	Local nQtdPro 	:= 0
	Local nCont		:= 0
	Local nPosCod 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "COD"			})
	Local nPosAut 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "AUTOMATICO"	})

	If lChkInsAtu .Or. lChkProAnd

		//Carrega assuntos que foram ativados
		For nCont:=1 To Len(aCols)
			If aCols[nCont][nPosAut] == "1"
				Aadd(aAux, aCols[nCont][nPosCod])
			EndIf
		Next nCont
		
		cQuery := " SELECT COUNT(1) QTDPRO"
		cQuery += " FROM ("
		
		cQuery += QryProCad( lChkInsAtu, lChkProAnd, lChkProAdm, aAux, "1" )
		
		cQuery += " ) CONTADOR " 
			
		aAux := {}		
		aAux := JurSQL(cQuery, {"QTDPRO"})
		
		If Len(aAux) > 0 
			nQtdPro := aAux[1][1]
		EndIf
	
	EndIf
	
	aSize(aAux, 0)
	RestArea( aArea )

Return nQtdPro

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaAsj()
Carrega os tipos de assunto juridico que podem ser configurados.

@author  Rafael Tenorio da Costa
@since 	 01/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaAsj()

	Local aArea  	:= GetArea()
	Local cQuery 	:= ""
	Local aAux		:= {}
	Local aRetorno 	:= {}
	Local cAndAuto	:= "" 
	Local cEncerra	:= ""
	Local cModo		:= ""
	Local cAto		:= "" 
	Local cSpaAto	:= Space(TamSx3("NRO_COD")[1])
	Local cJus		:= ""
	Local cSpaJus	:= Space(TamSx3("NQX_COD")[1])
	Local nCont		:= 0

	//Retorna todos os tipos de assunto jurídico que tem a tabela NUQ
	cQuery := " SELECT NYB_COD, NYB_DESC" 
	cQuery += " FROM " + RetSqlName("NYB") + " NYB"
	cQuery += " WHERE NYB_FILIAL = '" + xFilial("NYB") + "'"
	cQuery += " AND NYB.D_E_L_E_T_ = ' '"
	cQuery += " AND NYB_COD IN (SELECT NYC_CTPASJ"
	cQuery += 				  " FROM " + RetSqlName("NYC") + " NYC" 
	cQuery +=  				  " WHERE NYC.D_E_L_E_T_ = ' ' AND NYC_FILIAL = NYB_FILIAL AND NYC_TABELA = 'NUQ')"
		
	aAux := JurSQL(cQuery, {"NYB_COD", "NYB_DESC"})
	
	For nCont:=1 To Len(aAux)
	
		//Carrega a configura dos parametros que ja foi feita
		cAndAuto := JGetParTpa(aAux[nCont][1], "MV_JANDAUT", "2"						)
		cEncerra := JGetParTpa(aAux[nCont][1], "MV_JANDEXC", "2"						)
		cModo	 := JGetParTpa(aAux[nCont][1], "MV_JTPANAU", "1"						)
		cAto	 := JGetParTpa(aAux[nCont][1], "MV_JATOAUT", Space(TamSx3("NRO_COD")[1]))
		cJus	 := JGetParTpa(aAux[nCont][1], "MV_JAJUENC", Space(TamSx3("NQX_COD")[1]))
		
		cAto	 := IIF(Empty(cAto), cSpaAto, cAto)
		cJus	 := IIF(Empty(cJus), cSpaJus, cJus)
	
		Aadd(aRetorno, {aAux[nCont][1], aAux[nCont][2], cAndAuto, cEncerra, cModo, cAto, cJus, .F.})
	Next nCont
	
	RestArea( aArea )

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCfgPar()
Valida o preenchimento dos parâmetros

@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldCfgPar(aHeader, aCols)

	Local aRetorno	:= {.T., ""}
	Local nPosCod 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "COD"			})
	Local nPosAsj 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ASSUNTO"		})
	Local nPosAut 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "AUTOMATICO"	})
	Local nPosEnc 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ENCERRAMENTO"	})
	Local nPosAto 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ATO"			})
	Local nPosJus 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "JUSTIFICATIVA"	})
	Local cCod	  	:= ""
	Local cAssunto	:= ""
	Local cAndAuto	:= "" 
	Local cEncerra	:= ""
	Local cAto	  	:= ""
	Local cJus    	:= ""
	Local nCont   	:= 0
	
	For nCont:=1 To Len(aCols)

		cCod	:= AllTrim( aCols[nCont][nPosCod] )
		cAssunto:= AllTrim( aCols[nCont][nPosAsj] )
		cAndAuto:= aCols[nCont][nPosAut]
		cEncerra:= aCols[nCont][nPosEnc]
		cAto	:= aCols[nCont][nPosAto] 
		cJus    := aCols[nCont][nPosJus]
		
		If cAndAuto == "1"
		
			//Valida Ato
			If Empty(cAto)
				aRetorno[1] := .F.
			EndIf
			
			//Valida se ira receber andamentos mesmo com processo encerado, obrigatória a justificativa
			If cEncerra == "2" .And. Empty(cJus)
				aRetorno[1] := .F.
			EndIf 
						
			If aRetorno[1]
				aRetorno[2] += cCod + "-" + cAssunto + ", "
			Else
				Exit								
			EndIf
		EndIf	
	Next nCont
	
	//Tira a ultima virgula
	aRetorno[2] := SubStr(aRetorno[2], 1, Len(aRetorno[2]) - 2) 

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} HabAndAut()
Faz a configuração para habilitar o serviço de andamento automatico.

@author  Rafael Tenorio da Costa
@since 	 01/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function HabAndAut(cUsuario, cSenha, aHeader, aCols, lChkInsAtu, lChkProAnd, lChkProAdm)

	Local aArea		:= GetArea()
	Local aAreaNZ6	:= NZ6->( GetArea() )
	Local aAreaNUZ	:= NUZ->( GetArea() )
	Local lRetorno 	:= .F.
	Local nPosCod 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "COD"			})
	Local nPosAut 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "AUTOMATICO"	})
	Local nPosEnc 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ENCERRAMENTO" 	})
	Local nPosMod 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "MODO"		 	})
	Local nPosAto	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ATO"			})
	Local nPosJus 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "JUSTIFICATIVA"	})
	Local cCod	  	:= ""
	Local cAndAuto	:= "" 
	Local cEncerra	:= ""
	Local cModo		:= ""
	Local cAto	  	:= ""
	Local cJus    	:= ""
	Local nCont   	:= 0
	Local cFilNZ6	:= ""
	Local aDadosNZ6	:= {}
	Local cFilNUZ	:= ""
	Local aDadosNUZ	:= {}
	Local nDados	:= 0
	
	//Atualiza usuario e senha
	PutMv("MV_JINDUSR", cUsuario)
	PutMv("MV_JINDPSW", cSenha	)
	
	DbSelectArea("NZ6")
	NZ6->( DbSetOrder(1) )		//NZ6_FILIAL+NZ6_TIPOAS+NZ6_CPARAM
	cFilNZ6	:= xFilial("NZ6")
	
	DbSelectArea("NUZ")
	NUZ->( DbSetOrder(1) )		//NUZ_FILIAL+NUZ_CTAJUR+NUZ_CAMPO
	cFilNUZ	:= xFilial("NUZ")
	
	For nCont:=1 To Len(aCols)
	
		lRetorno:= .T.
		cCod	:= aCols[nCont][nPosCod]
		cAndAuto:= aCols[nCont][nPosAut]
		cEncerra:= aCols[nCont][nPosEnc]
		cModo	:= aCols[nCont][nPosMod]
		cAto	:= aCols[nCont][nPosAto] 
		cJus    := aCols[nCont][nPosJus]
		
		//Verifica se foi ativado o andamento automatico e quer cadastrar os processos ja existentes ou não foi ativado o andamento automatico
		If ( cAndAuto == "1" .And. (lChkInsAtu .Or. lChkProAnd) ) .Or. cAndAuto == "2"
			Processa( {|| lRetorno := AtuDadServ(lChkInsAtu, lChkProAnd, lChkProAdm, cCod, cAndAuto)}, STR0064, I18n(STR0056, {cCod}) )	//"Atualizando dados no serviço de monitoramento TOTVS"		//"Assunto Jurídico #1"
		EndIf
		
		//Verifica se os processos foram cadastrados no serviço
		If lRetorno 
	 
	 		Begin Transaction
	 
				//Atualiza assuntos juridicos que ja tem os parametros
				aDadosNZ6 := {}
				Aadd(aDadosNZ6, {"MV_JANDAUT", cAndAuto})
				Aadd(aDadosNZ6, {"MV_JANDEXC", cEncerra})
				Aadd(aDadosNZ6, {"MV_JATOAUT", cAto}	)
				Aadd(aDadosNZ6, {"MV_JAJUENC", cJus}	)
				Aadd(aDadosNZ6, {"MV_JTPANAU", cModo}	)
				
				For nDados:=1 To Len(aDadosNZ6)
				
					If NZ6->( DbSeek(cFilNZ6 + cCod + aDadosNZ6[nDados][1]) )
						RecLock("NZ6", .F.)
							NZ6->NZ6_CONTEU := aDadosNZ6[nDados][2]
						NZ6->( MsUnLock() )
					Else
						RecLock("NZ6", .T.)
							NZ6->NZ6_FILIAL := cFilNZ6 
							NZ6->NZ6_TIPOAS := cCod
							NZ6->NZ6_CPARAM := aDadosNZ6[nDados][1]
							NZ6->NZ6_TIPO	:= "C"
							NZ6->NZ6_CONTEU := aDadosNZ6[nDados][2]
						NZ6->( MsUnLock() )
					EndIf
					NZ6->( DBCloseArea())
					
				Next nDados
			
				//Inclui os campos no assunto jurídico
				aDadosNUZ := {}
				Aadd(aDadosNUZ, {"NUQ_ANDAUT", RetTitle("NUQ_ANDAUT")})
				Aadd(aDadosNUZ, {"NT4_ANDAUT", RetTitle("NT4_ANDAUT")})
				
				For nDados:=1 To Len(aDadosNUZ)
				
					//Inclui os campos nos assuntos juridicos pais
					If !NUZ->( DbSeek(cFilNUZ + cCod + aDadosNUZ[nDados][1]) )
					
						If cCod <= "050"
							RecLock("NUZ", .T.) 
								NUZ->NUZ_FILIAL	:= cFilNUZ
								NUZ->NUZ_CAMPO	:= aDadosNUZ[nDados][1]
								NUZ->NUZ_DESCPO	:= aDadosNUZ[nDados][2]
								NUZ->NUZ_CTAJUR	:= cCod
							NUZ->( MsUnLock() )
						EndIf
					Else
					
						//Verifica se foi desabilitado o andamento automatico
						If cAndAuto == "2"
							RecLock("NUZ", .F.)
								NUZ->( DbDelete() )
							NUZ->( MsUnLock() )
						EndIf
					EndIf
				Next nDados
			
			End Transaction
			
		EndIf
			
	Next nCont
	
	If lRetorno 
		MsgInfo(STR0054)	//"Configuração finalizada com sucesso"
	EndIf		
	
	Asize(aDadosNZ6, 0)
	Asize(aDadosNUZ, 0)
	
	RestArea( aAreaNUZ )
	RestArea( aAreaNZ6 )
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuDadServ()
Cadastra\Remove os processos já existentes no serviço de monitoramento TOTVS

@author  Rafael Tenorio da Costa
@since 	 01/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuDadServ(lChkInsAtu, lChkProAnd, lChkProAdm, cTipoAs, cAndAuto)

	Local aArea		 := GetArea()
	Local aAreaNUQ	 := NUQ->( GetArea() )
	Local lRetorno	 := .T.
	Local cQuery	 := ""
	Local aProcessos := {}
	Local nCont		 := 0
	Local lVldCNJ    := .T.

	ProcRegua(0)
	IncProc()

	//Carrega query com os processos que seram cadastrados
	cQuery := QryProCad( lChkInsAtu, lChkProAnd, lChkProAdm, {cTipoAs}, cAndAuto )

	//Executa query	
	aProcessos := JurSQL(cQuery, {"NUQ_NUMPRO", "NUQ_ESTADO", "RECNONUQ", "NQ6_COD", "NQC_COD", "NUQ_CNATUR"})
	
	DbSelectArea("NUQ")
	NUQ->( DbSetOrder(1) )	//NUQ_FILIAL+NUQ_CAJURI

	For nCont:=1 To Len(aProcessos)
	
		IncProc(STR0055 + I18n(STR0056, {cTipoAs}))	//"Processando... "		//"Assunto Jurídico #1"
		
		lVldCNJ := J183VldCnj(cTipoAs, aProcessos[nCont][6])

		//Cadastra Processo no recebimento automatico		
		If cAndAuto == "1"
		
			lRetorno := J223CadPro(aProcessos[nCont][1], aProcessos[nCont][2], aProcessos[nCont][4],, aProcessos[nCont][5], lVldCNJ)
			
		//Remove Processo do recebimento automatico			
		Else
			lRetorno := J223ExcPro(aProcessos[nCont][1], lVldCNJ) 
		EndIf
		
		If 	lRetorno

			//Atualiza flag na instancia		
			NUQ->( DbGoTo(aProcessos[nCont][3]) )
			If !NUQ->( Eof() )
				RecLock("NUQ", .F.)
					NUQ->NUQ_ANDAUT = cAndAuto
				NUQ->( MsUnLock() )			
			EndIf
		Else
		
			JurMsgErro( STR0057 + CRLF +;			//"Tente refazer o procedimento mais tarde."
						I18n(STR0056, {cTipoAs}))	//"Assunto Jurídico #1"
			Exit		
		EndIf
	Next nCont
	
	Asize(aProcessos, 0)
	RestArea( aAreaNUQ )	
	RestArea( aArea )
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTribunal()
Rotina que retorna o tribunal e uf do processo a partir do numero do processo.
Rotina ira morrer quando entrar em produção a funcionalidade CNJ.

@author  Rafael Tenorio da Costa
@since 	 04/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetTribunal(cNumPro, cMsgErro)

	Local aDadosCNJ := {}
	Local nPos		:= 0	
	Local cCod		:= AllTrim( SubStr(cNumPro, 17, 4) )	//"XXXXXXX-XX.XXXX.X.XX.XXXX"
	Local aRetorno	:= {}
	
	cMsgErro := ""
	
	Aadd(aDadosCNJ, {"1.00", "STF"	, "DF"})
	Aadd(aDadosCNJ, {"2.00", "CNJ"	, "DF"})
	Aadd(aDadosCNJ, {"3.00", "STJ"	, "DF"})
	Aadd(aDadosCNJ, {"4.90", "CJF"	, "DF"})
	Aadd(aDadosCNJ, {"4.01", "TRF1"	, "DF"})
	Aadd(aDadosCNJ, {"4.02", "TRF2"	, "RJ"})
	Aadd(aDadosCNJ, {"4.03", "TRF3"	, "SP"})
	Aadd(aDadosCNJ, {"4.04", "TRF4"	, "RS"})
	Aadd(aDadosCNJ, {"4.05", "TRF5"	, "PE"})
	Aadd(aDadosCNJ, {"5.00", "TST"	, "DF"})
	Aadd(aDadosCNJ, {"5.90", "CSJT"	, "DF"})
	Aadd(aDadosCNJ, {"5.01", "TRRJ"	, "RJ"})
	Aadd(aDadosCNJ, {"5.02", "TRSP2", "SP"})
	Aadd(aDadosCNJ, {"5.03", "TRMG" , "MG"})
	Aadd(aDadosCNJ, {"5.04", "TRRS" , "RS"})
	Aadd(aDadosCNJ, {"5.05", "TRBA" , "BA"})
	Aadd(aDadosCNJ, {"5.06", "TRPE" , "PE"})
	Aadd(aDadosCNJ, {"5.07", "TRCE" , "CE"})
	Aadd(aDadosCNJ, {"5.08", "TRPA" , "PA"})
	Aadd(aDadosCNJ, {"5.09", "TRPR" , "PR"})
	Aadd(aDadosCNJ, {"5.10", "TRDF" , "DF"})
	Aadd(aDadosCNJ, {"5.11", "TRAM" , "AM"})
	Aadd(aDadosCNJ, {"5.12", "TRSC" , "SC"})
	Aadd(aDadosCNJ, {"5.13", "TRPB" , "PB"})
	Aadd(aDadosCNJ, {"5.14", "TRRO" , "RO"})
	Aadd(aDadosCNJ, {"5.15", "TRSP" , "SP"})
	Aadd(aDadosCNJ, {"5.16", "TRMA" , "MA"})
	Aadd(aDadosCNJ, {"5.17", "TRES" , "ES"})
	Aadd(aDadosCNJ, {"5.18", "TRGO" , "GO"})
	Aadd(aDadosCNJ, {"5.19", "TRAL" , "AL"})
	Aadd(aDadosCNJ, {"5.20", "TRSE" , "SE"})
	Aadd(aDadosCNJ, {"5.21", "TRRN" , "RN"})
	Aadd(aDadosCNJ, {"5.22", "TRPI" , "PI"})
	Aadd(aDadosCNJ, {"5.23", "TRMT" , "MT"})
	Aadd(aDadosCNJ, {"5.24", "TRMS" , "MS"})
	Aadd(aDadosCNJ, {"6.00", "TSE"	, "DF"})
	Aadd(aDadosCNJ, {"6.01", "TEAC" , "AC"})
	Aadd(aDadosCNJ, {"6.02", "TEAL" , "AL"})
	Aadd(aDadosCNJ, {"6.03", "TEAP" , "AP"})
	Aadd(aDadosCNJ, {"6.04", "TEAM" , "AM"})
	Aadd(aDadosCNJ, {"6.05", "TEBA" , "BA"})
	Aadd(aDadosCNJ, {"6.06", "TECE" , "CE"})
	Aadd(aDadosCNJ, {"6.07", "TEDF" , "DF"})
	Aadd(aDadosCNJ, {"6.08", "TEES" , "ES"})
	Aadd(aDadosCNJ, {"6.09", "TEGO" , "GO"})
	Aadd(aDadosCNJ, {"6.10", "TEMA" , "MA"})
	Aadd(aDadosCNJ, {"6.11", "TEMT" , "MT"})
	Aadd(aDadosCNJ, {"6.12", "TEMS" , "MS"})
	Aadd(aDadosCNJ, {"6.13", "TEMG" , "MG"})
	Aadd(aDadosCNJ, {"6.14", "TEPA" , "PA"})
	Aadd(aDadosCNJ, {"6.15", "TEPB" , "PB"})
	Aadd(aDadosCNJ, {"6.16", "TEPR" , "PR"})
	Aadd(aDadosCNJ, {"6.17", "TEPE" , "PE"})
	Aadd(aDadosCNJ, {"6.18", "TEPI" , "PI"})
	Aadd(aDadosCNJ, {"6.19", "TERJ" , "RJ"})
	Aadd(aDadosCNJ, {"6.20", "TERN" , "RN"})
	Aadd(aDadosCNJ, {"6.21", "TERS" , "RS"})
	Aadd(aDadosCNJ, {"6.22", "TERO" , "RO"})
	Aadd(aDadosCNJ, {"6.23", "TERR" , "RR"})
	Aadd(aDadosCNJ, {"6.24", "TESC" , "SC"})
	Aadd(aDadosCNJ, {"6.25", "TESE" , "SE"})
	Aadd(aDadosCNJ, {"6.26", "TESP" , "SP"})
	Aadd(aDadosCNJ, {"6.27", "TETO" , "TO"})
	Aadd(aDadosCNJ, {"8.01", "TJAC" , "AC"})
	Aadd(aDadosCNJ, {"8.02", "TJAL" , "AL"})
	Aadd(aDadosCNJ, {"8.03", "TJAP" , "AP"})
	Aadd(aDadosCNJ, {"8.04", "TJAM" , "AM"})
	Aadd(aDadosCNJ, {"8.05", "TJBA" , "BA"})
	Aadd(aDadosCNJ, {"8.06", "TJCE" , "CE"})
	Aadd(aDadosCNJ, {"8.07", "TJDF" , "DF"})
	Aadd(aDadosCNJ, {"8.08", "TJES" , "ES"})
	Aadd(aDadosCNJ, {"8.09", "TJGO" , "GO"})
	Aadd(aDadosCNJ, {"8.10", "TJMA" , "MA"})
	Aadd(aDadosCNJ, {"8.11", "TJMT" , "MT"})
	Aadd(aDadosCNJ, {"8.12", "TJMS" , "MS"})
	Aadd(aDadosCNJ, {"8.13", "TJMG" , "MG"})
	Aadd(aDadosCNJ, {"8.14", "TJPA" , "PA"})
	Aadd(aDadosCNJ, {"8.15", "TJPB" , "PB"})
	Aadd(aDadosCNJ, {"8.16", "TJPR" , "PR"})
	Aadd(aDadosCNJ, {"8.17", "TJPE" , "PE"})
	Aadd(aDadosCNJ, {"8.18", "TJPI" , "PI"})
	Aadd(aDadosCNJ, {"8.19", "TJRJ" , "RJ"})
	Aadd(aDadosCNJ, {"8.20", "TJRN" , "RN"})
	Aadd(aDadosCNJ, {"8.21", "TJRS" , "RS"})
	Aadd(aDadosCNJ, {"8.22", "TJRO" , "RO"})
	Aadd(aDadosCNJ, {"8.23", "TJRR" , "RR"})
	Aadd(aDadosCNJ, {"8.24", "TJSC" , "SC"})
	Aadd(aDadosCNJ, {"8.25", "TJSE" , "SE"})
	Aadd(aDadosCNJ, {"8.26", "TJSP" , "SP"})
	Aadd(aDadosCNJ, {"8.27", "TJTO" , "TO"})
	
	//Localiza dados do tribunal
	nPos := Ascan(aDadosCNJ, {|x| x[1]==cCod})
	
	If nPos > 0 
	
		Aadd(aRetorno, aDadosCNJ[nPos][2])
		Aadd(aRetorno, aDadosCNJ[nPos][3])
	Else
			
		cMsgErro  := I18n(STR0058, {cCod, AllTrim(cNumPro)})	//"Não foi possível localizar a sigla do tribunal(#1), verifique o número do processo.(#2)"
	EndIf	
			
Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} QryProCad()
Retorna a query que define os processos que serão cadastrados no 
serviço de monitoramento TOTVS.

@author  Rafael Tenorio da Costa
@since 	 09/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function QryProCad( lChkInsAtu, lChkProAnd, lChkProAdm, aTipoAs, cAndAuto )

	Local cQuery 		:= ""
	Local nCont			:= 0
	Local cTipoAs		:= ""
	
	Default cAndAuto 	:= "1"	//1=Andamento Automatico Sim

	//Carrega os tipos de assunto
	For nCont:=1 To Len(aTipoAs)
		If lChkProAdm //Se for enviar processos administrativos, não considerar a validação do nº CNJ
			cTipoAs += "'" + aTipoAs[nCont] + "',"
		Else
			//Verifica se esta ativo o padrao CNJ
			If JGetParTpa(aTipoAs[nCont], "MV_JNUMCNJ", "2") == "1"
				cTipoAs += "'" + aTipoAs[nCont] + "',"
			EndIf	 
		EndIf
	Next nCont
	
	cTipoAs := SubStr(cTipoAs, 1, Len(cTipoAs) - 1)
	cTipoAs := IIF( Empty(cTipoAs), "''", cTipoAs)

	cQuery := " SELECT NUQ_NUMPRO, NUQ_ESTADO, NUQ.R_E_C_N_O_ RECNONUQ, NQ6_COD, NQC_COD, NUQ_CNATUR"
	cQuery += " FROM " + RetSqlName("NSZ") + " NSZ INNER JOIN " + RetSqlName("NUQ") + " NUQ"
	cQuery += 	" ON NSZ_FILIAL = NUQ_FILIAL AND NSZ_COD = NUQ_CAJURI AND NSZ.D_E_L_E_T_ = NUQ.D_E_L_E_T_"
	cQuery += " INNER JOIN " + RetSqlName("NQ1") + " NQ1 "
	cQuery += 	" ON NQ1_FILIAL = '" + xFilial("NQ1") + "' AND NUQ_CNATUR = NQ1_COD AND NSZ.D_E_L_E_T_ = NQ1.D_E_L_E_T_" 
	
	cQuery += " LEFT JOIN " + RetSqlName("NQ6") + " NQ6 " //Relacionamento para trazer as comarcas relacionadas (para processos Administrativos)
	cQuery += " ON NQ6_FILIAL = '" + xFilial("NQ6") + "' AND NUQ_CCOMAR = NQ6_COD"
	cQuery += " LEFT JOIN " + RetSqlName("NQC") + " NQC "
	cQuery += " ON NQC_FILIAL = '" + xFilial("NQC") + "' AND NUQ_CLOC2N = NQC_COD"	
	
	cQuery += " WHERE NSZ_FILIAL = '" + xFilial("NSZ") + "'"
	cQuery += 	" AND NSZ.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NSZ_TIPOAS IN (" + cTipoAs + ")"
	
	If !lChkProAdm
		cQuery += 	" AND NQ1_VALCNJ IN (' ', '1')"			//Naturezas com CNJ ativo
	EndIf
	
	If cAndAuto == "1"
		cQuery += 	" AND NUQ_ANDAUT <> '1'"	//Pega todos os processos que não estão cadastrados no serviço de monitoramento TOTVS
		
		//1=Em andamento
		If lChkProAnd
	  		cQuery += " AND NSZ_SITUAC = '1'"		
		EndIf
	
		//1=Instância Atual
		If lChkInsAtu  
	  		cQuery += " AND NUQ_INSATU = '1'"
	  	EndIf
	Else
	
		cQuery += 	" AND NUQ_ANDAUT = '1'"		//Pega todos os processos que estão cadastrados no serviço de monitoramento TOTVS	
	EndIf
  	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J223GrvJus()
Grava a justificativa, quando inclui andamento para processo encerrado.

@author  Rafael Tenorio da Costa
@since 	 09/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223GrvJus(cUserAut, cJustifi)

	Local oModel    := FWModelActive()
	Local cCod		:= oModel:GetValue("NT4MASTER", "NT4_COD")
	Local cCajuri	:= oModel:GetValue("NT4MASTER", "NT4_CAJURI")
	Local cTipoAs	:= JurGetDados("NSZ", 1, xFilial("NSZ") + cCajuri, "NSZ_TIPOAS")
	Local cCodJust	:= JGetParTpa(cTipoAs, "MV_JAJUENC", "")
	Local lRetorno	:= .F.
	
	Default cUserAut := "Schedule"
	Default cJustifi := I18n(STR0059, {cCod}) 	//"Alteração feita pela inclusão do andamento automático. (#1)"

	lRetorno := J166GrvJus(cCajuri, cUserAut, cCodJust, cJustifi)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J223VldCmp()
Valida campos AUTOMATICO\ENCERRAMENTO do wizard

@author  Rafael Tenorio da Costa
@since 	 12/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223VldCmp(cCampo, cConteudo)

	Local lRetorno 	:= ( cConteudo $ "1|2" )
	Local nPosEnc 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ENCERRAMENTO" 	})
	Local nPosMod 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "MODO"		 	})
	Local nPosAto 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ATO"			})
	Local nPosJus 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "JUSTIFICATIVA"	})

	If lRetorno

		//"AUTOMATICO"
		If cCampo == "AUTOMATICO"
	
			//Se desativar andamento automatico, volta dados padrões dos campos
			If cConteudo == "2"
				aCols[n][nPosEnc] := "2"	
				aCols[n][nPosMod] := "1"
				aCols[n][nPosAto] := Space( TamSx3("NT4_CATO")[1] 	)
				aCols[n][nPosJus] := Space( TamSx3("NUV_CMOTIV")[1] )
			EndIf
		
		//"ENCERRAMENTO"
		Else
		
			//Se for retirar os processos encerados dos andamentos automatico não precisa de justificativa
			If cConteudo == "1"
				aCols[n][nPosJus] := Space( TamSx3("NUV_CMOTIV")[1] )
			EndIf
		EndIf
	
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J223AtvCmp()
Ativa campos dos parametros do wizard.

@author  Rafael Tenorio da Costa
@since 	 12/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223AtvCmp(cCampo)

	Local lRetorno 	:= .T.
	Local nPosAut 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "AUTOMATICO"	})
	Local nPosEnc 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ENCERRAMENTO" 	})
	
	Default cCampo	:= ""
	
	lRetorno := ( cValToChar(aCols[n][nPosAut]) == "1" )
	
	If lRetorno .And. cCampo == "JUSTIFICATIVA"
	
		//Se for retirar os processos encerados dos andamentos automatico não precisa de justificativa
		If cValToChar(aCols[n][nPosEnc]) == "1"
			lRetorno := .F.
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J223VldAut()
Valida linha do grid do wizard.

@author  Rafael Tenorio da Costa
@since 	 12/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J223VlLiWi()

	Local lRetorno 	:= .T.
	Local nPosAut 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "AUTOMATICO"	})
	Local nPosEnc 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ENCERRAMENTO" 	})
	Local nPosAto 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "ATO"			})
	Local nPosJus 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "JUSTIFICATIVA"	})

	//Andamento automatico ativado
	If cValToChar(aCols[n][nPosAut]) == "1"

		//Verifica se o Ato foi preenchido
		If Empty(aCols[n][nPosAto])
			JurMsgErro(STR0063)		//"Preencha o Ato"
			lRetorno := .F.
		EndIf
		
		//Verifica se ira receber andamentos mesmo com processo encerado
		If cValToChar(aCols[n][nPosEnc]) == "2"
			
			//Valida justificativa
			If Empty(aCols[n][nPosJus])
				JurMsgErro(STR0062)		//"Preencha a Justificativa"
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvRecusa()
Envia processo que foi recusado pelo Vista para o serviço do BPO

@author  Rafael Tenorio da Costa
@since 	 12/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvRecusa(cNumPro)

	Local lRetorno 	:= .F.
	Local cRetorno	:= ""
	Local cUsuario	:= SuperGetMV('MV_JINDUSR', , "")
	Local cSenha   	:= SuperGetMV('MV_JINDPSW', , "")
	Local oWS		:= Nil
	
	oWS := JURA224A():New()
	
	oWS:cUSUARIO 	:= cUsuario
	oWS:cSENHA   	:= cSenha
	oWS:cProcesso	:= cNumPro
	
	If oWS:MTRECUSADOS()
		If oWS:cMtRecusadosResult <> Nil
		
			cRetorno := Upper( oWS:cMtRecusadosResult )
			
			If cRetorno == "OK"
				lRetorno := .T.
			EndIf	
		EndIf
	EndIf
	
	If !lRetorno
		JurMsgErro( STR0065 + PULALINHA +;		//"Erro ao enviar processo recusado para o serviço de monitoramento TOTVS. (MTRECUSADOS)"
					STR0009 + GetWSCError())	//"Erro: "
		aVldClient := Nil
	EndIf
	
	FwFreeObj(oWS)
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRecusa()
Efetua validaçaõ nos processos para ver se foram mesmo cadastrados na vista.

@param aAutomation: Lista dos processos que deverão ser recusados.
					[nI][1][1]: CNUMEROPROCESSO
					[nI][1][2]: Número do processo
					[nI][2][1]: CSTATUS
					[nI][2][2]: Algum status da Solucionare (Ex: NAO VALIDADO)

@since  11/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcRecusa(aAutomation)
Local aArea       := GetArea()
Local aAreaNUQ    := NUQ->( GetArea() )
Local lRetorno    := .T.
Local aProcessos  := {}
Local aCajuris    := {}
Local cNumPro     := ""
Local cStatus     := ""
Local nCont       := 0
Local nCajuri     := 0
Local lVldCNJ     := .T.
Local lAutomation := .F.

Default aAutomation := {}

	lAutomation := Len(aAutomation) > 0

	//Retorna os processos a validar ou que não foram validados
	aProcessos := IIf(lAutomation, aAutomation, J223ProAge())

	If Len(aProcessos) > 0
		DbSelectArea("NUQ")
		NUQ->( DbSetOrder(1) ) //NUQ_FILIAL+NUQ_CAJURI

		nPosPro := Ascan(aProcessos[1], {|x| x[1] == "CNUMEROPROCESSO" })
	 	nPosSta := Ascan(aProcessos[1], {|x| x[1] == "CSTATUS"         })
	 	
		For nCont:=1 To Len(aProcessos)
			lRetorno := .T.
			aCajuris := {}
			cNumPro  := aProcessos[nCont][nPosPro][2]
			cStatus  := aProcessos[nCont][nPosSta][2]

			If cStatus == "NAO VALIDADO"
				//Busca todos os assuntos juridicos tem quem este numero do processo
				aCajuris := BusCajuris(cNumPro)

				//Envia numero do processo recusado para o BPO
				If !lAutomation
					lRetorno := EnvRecusa(cNumPro)
				EndIf

				If lRetorno
					If Len(aCajuris) > 0
						//Verifica se deve considerar a validação do número CNJ ou não de acordo com o parâmetro e a natureza da instância
						lVldCNJ := J183VldCnj(aCajuris[1][2], aCajuris[1][4])
					EndIf

					//Remove o processo da Vista, porque mesmo ele não sendo VALIDADO ele conta no numero que será cobrado.
					If !lAutomation
						lRetorno := J223ExcPro(cNumPro, lVldCNJ)
					EndIf

					If lRetorno
						For nCajuri := 1 To Len(aCajuris)

							//Atualiza flag na instancia para pendente
							NUQ->( DbGoTo(aCajuris[nCajuri][3]) )
							If !NUQ->( Eof() )
								RecLock("NUQ", .F.)
									NUQ->NUQ_ANDAUT = "3" //3=Pendente
								NUQ->( MsUnLock() )
							EndIf
						Next nCajuri
					EndIf
				EndIf
			EndIf
		Next nCont
	EndIf

	RestArea( aAreaNUQ )
	RestArea( aArea )

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} InsertAnd()
Inserção de andamentos via modelo

@param 
	dDataAnd - Data do andamento
	cDesc 	 - Descrição
	aCajuris - Codigo do Cajuri

@return lRetorno - Conseguiu fazer o commit ou não

@since  31/08/2021
/*/
//-------------------------------------------------------------------
Static Function InsertAnd(dDataAnd, cDesc, aCajuris)
	Local oModelNT4 := Nil
	Local lRetorno  := .T.
	Local nProces   := 1
	Local cAto      := ""

	Default dDataAnd  := CtoD("")
	Default aCajuris  := {}
	Default cDesc 	:= ""

	oModelNT4 := FWLoadModel("JURA100")

	For nProces:=1 To Len(aCajuris)
					
		oModelNT4:SetOperation(MODEL_OPERATION_INSERT)
		oModelNT4:Activate()
	
		lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_CAJURI", aCajuris[nProces][1])
	
		If lRetorno
			lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_DESC", cDesc)
		EndIf
		
		If lRetorno
			lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_DTANDA", dDataAnd)
		EndIf
		
		If lRetorno
		
			//Busca o codigo do ato processual para andamento automático
			cAto := JGetParTpa(aCajuris[nProces][2], "MV_JATOAUT", "")
		
			lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_CATO", cAto)
		EndIf
		
		If lRetorno
			lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_ANDAUT", "1")	//1=Sim
		EndIf

		If lRetorno
			lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_USUINC", "Schedule")
			lRetorno := oModelNT4:SetValue("NT4MASTER", "NT4_USUALT", "Schedule")
		EndIf
		
		If lRetorno
			//Valida andamento
			If ( lRetorno := oModelNT4:VldData() )
		
				//Grava andamento
				lRetorno := oModelNT4:CommitData()
			EndIf
		EndIf
		
		//Exibe mensagem de erro
		If !lRetorno
		
			JurMsgErro(STR0017)		//"Não foi possível incluir o andamento automático."
			oModelNT4:Deactivate()
			Exit
		EndIf
		
		oModelNT4:Deactivate()
	Next nProces
	oModelNT4:Destroy()	
Return lRetorno
