#INCLUDE "JURA095_F.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095_F
Functions de validação de rotinas envolvidas com FLUIG

@author Jorge Luis Branco Martins Junior
@since 23/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA095_F()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef Functions de validação de processos

@author Jorge Luis Branco Martins Junior
@since 23/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Functions de validação de processos

@author Jorge Luis Branco Martins Junior
@since 23/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Functions de validação de processos

@author Jorge Luis Branco Martins Junior
@since 23/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J95FFluig
Valida alterações nos campos de valor e data dos valores
atualizáveis para ajustar o histórico conforme necessário.

@param 	oModel   Modelo de dados
@param 	cTabela   Tabela que está sendo alterada

@author André Spirigoni Pinto
@since 21/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95FFluig(oModel, nOpc)

	Local lRet 		 := .T.
	Local nI   		 := 0
	Local cDescFwApv := ""
	Local lNZKInDic  := FWAliasInDic("NZK") //Verifica se existe a tabela NZK no Dicionário
	Local aDadFwApv  := {}
	Local cTipFwApv  := ""
	Local oView		 := Nil
	Local nValorOld  := IIF(nOpc == 3, 0, NSZ->NSZ_VLPROV)
	Local lCodWf     := !(NSY->( FieldPos("NSY_CODWF") ) > 0)//Se não existir o campo da NSY a aprovação de valores é gerada pelo AssJUR
	Local cCmpDetEnc := ""

	//*********************************************************************************************************************
	// Gera follow-up e tarefas de follow-up para aprovacao no fluig quando nao for uma aprovacao do fluig
	//*********************************************************************************************************************
	If lNZKInDic .And. !IsInCallStack("JA106ConfNZK") .And. !IsInCallStack("MTJurEncerraAssJur") .And.;
		( oModel:IsFieldUpdated("NSZMASTER", "NSZ_CPROGN") .Or. oModel:IsFieldUpdated("NSZMASTER", "NSZ_VLPROV") .Or.;
			oModel:IsFieldUpdated("NSZMASTER", "NSZ_SITUAC") ) .And. !IsInCallStack('J270Commit')

		//Verifica se ja existe tarefa de follow-up em aprovacao
		If J95FTarFw( FwFldGet("NSZ_COD"), "1", {"1", "5"} )
			JurMsgErro(	STR0004 )		//"Já existe follow-up para aprovação pendente. Não será possível prosseguir com a alteração."
			lRet := .F.
		Else

			//Verifica se alterou valor da provisao
			If (JGetParTpa(cTipoAsj, "MV_JVLPROV", "1") == "1" .OR. lCodWf ).AND.;
			   ( FwFldGet("NSZ_VLPROV") <> NSZ->NSZ_VLPROV .Or. (FwFldGet("NSZ_CPROGN") <> NSZ->NSZ_CPROGN .And. FwFldGet("NSZ_VLPROV") > 0) )

				cTipFwApv	:= "1"		//1=Alteracao Valor Provisao
				cDescFwApv 	:= STR0001	//"Valor de Provisão"

				//Verifica se existe o tipo de follow-up para aprovacao
				If Empty( JurGetDados("NQS", 3, xFilial("NQS") + cTipFwApv, "NQS_COD") )	//NQS_FILIAL + NQS_TAPROV	1=Alteracao Valor Provisao 2=Aprovacao de despesas 3=Aprovacao de Garantias 4=Aprovacao de Levantamento 5=Encerramento
					cTipFwApv := ""
				Else

					//Alterações que seram feitas quando for aprovada a alteracao do valor da provisao
					aDadFwApv := {}
					Aadd( aDadFwApv, {"NSZ_DTPROV", FwFldGet("NSZ_DTPROV")} )
					Aadd( aDadFwApv, {"NSZ_CMOPRO", FwFldGet("NSZ_CMOPRO")} )
					Aadd( aDadFwApv, {"NSZ_VLPROV", FwFldGet("NSZ_VLPROV")} ) // Novo valor de provisão
					Aadd( aDadFwApv, {"NSZ_CPROGN", FwFldGet("NSZ_CPROGN")} )
					Aadd( aDadFwApv, {"PROV_NTA"  , FwFldGet("NSZ_VLPROV")- nValorOld} ) // Valor de provisão a ser aprovado
					Aadd( aDadFwApv, {"NUMCAS_NTA", FwFldGet("NSZ_NUMCAS")} )
				EndIf

			EndIf

			//Verifica se esta encerrando o processo
			If FwFldGet("NSZ_SITUAC") == "2" .And. FwFldGet("NSZ_SITUAC") <> NSZ->NSZ_SITUAC

				cTipFwApv	:= "5"		//5=Encerramento
				cDescFwApv 	:= STR0002	//"Encerramento"

				//Verifica se existe o tipo de follow-up para aprovacao
				If Empty( JurGetDados("NQS", 3, xFilial("NQS") + cTipFwApv, "NQS_COD") )	//NQS_FILIAL + NQS_TAPROV	1=Alteracao Valor Provisao 2=Aprovacao de despesas 3=Aprovacao de Garantias 4=Aprovacao de Levantamento 5=Encerramento
					cTipFwApv := ""
				Else
					If !Empty(FwFldGet("NSZ_DETENC"))
							
						//Alterações que seram feitas quando for aprovado o encerramento do processo
						aDadFwApv := {}
						Aadd( aDadFwApv, {"NSZ_SITUAC", FwFldGet("NSZ_SITUAC")	} )
						Aadd( aDadFwApv, {"NSZ_USUENC", FwFldGet("NSZ_USUENC")	} )
						Aadd( aDadFwApv, {"NSZ_DTENCE", FwFldGet("NSZ_DTENCE")	} )
						Aadd( aDadFwApv, {"NSZ_CMOFIN", FwFldGet("NSZ_CMOFIN")	} )
						Aadd( aDadFwApv, {"NSZ_VLFINA", FwFldGet("NSZ_VLFINA")	} )
						Aadd( aDadFwApv, {"NSZ_CMOENC", FwFldGet("NSZ_CMOENC")	} )
						Aadd( aDadFwApv, {"NSZ_DETENC", FwFldGet("NSZ_DETENC")	} )

						oView := FWViewActive()

						if oView != Nil //valida se existe view
							For nI := 1 to len(aDadFwApv) //Retira os campos que não estão disponíveis na view.
								if nI > 0
									if nI <= len(aDadFwApv) .And. !oView:HasField("NSZMASTER",aDadFwApv[nI][1])
										aDel(aDadFwApv,nI)
										aSize(aDadFwApv,len(aDadFwApv)-1)
										nI := nI - 1
									Endif
								Endif
							Next
						Endif
					Else 
						lRet       := .F.
						cTipFwApv  := ""
						cCmpDetEnc := Alltrim( J95TitCpo('NSZ_DETENC', FwFldGet("NSZ_TIPOAS") ) ) 
						JurMsgErro( I18N( STR0021, { cCmpDetEnc } ), Nil, I18N( STR0022, {cCmpDetEnc } ) ) // "O campo '#1' não foi preenchido" ## "Necessário preencher o campo '#1'"
					Endif
				EndIf
			EndIf

			//Verifica se existe dados para enviar para aprovação
			If !Empty( cTipFwApv )

				//Verifica se existe algum resultado de follow-up com o tipo 4=Em Aprovacao
				If Empty( JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD") )	//NQN_FILIAL + NQN_TIPO
					JurMsgErro(	I18N( STR0003, {cDescFwApv}) )		//"Não existe resultado de follow-up com o tipo 4=Em Aprovacao cadastrado. Verifique o cadastro de tipos de follow-up!"
					lRet := .F.
				EndIf

				If lRet
					//Volta dados da provisao antes de alteracao
					If cTipFwApv == "1"

						//Busca dados da provisao antes da alteracao
						if nOpc == 4
							//Busca dados da provisao antes da alteracao
							oModel:LoadValue("NSZMASTER", "NSZ_DTPROV", NSZ->NSZ_DTPROV )
							oModel:LoadValue("NSZMASTER", "NSZ_CMOPRO", NSZ->NSZ_CMOPRO )
							oModel:LoadValue("NSZMASTER", "NSZ_VLPROV", NSZ->NSZ_VLPROV )
							oModel:LoadValue("NSZMASTER", "NSZ_CPROGN", NSZ->NSZ_CPROGN )
						else
							//Busca dados da provisao antes da alteracao. se for inclusão, não existe antes.
							oModel:LoadValue("NSZMASTER", "NSZ_DTPROV", SToD("") )
							oModel:LoadValue("NSZMASTER", "NSZ_CMOPRO", '' )
							oModel:LoadValue("NSZMASTER", "NSZ_VLPROV", 0 )
							oModel:LoadValue("NSZMASTER", "NSZ_CPROGN", '' )
						endif

					//Volta dados do encerramento antes de alteracao
					ElseIf cTipFwApv == "5"

					//Busca dados do encerramento antes da alteracao
						oModel:LoadValue("NSZMASTER", "NSZ_SITUAC", NSZ->NSZ_SITUAC )
						oModel:LoadValue("NSZMASTER", "NSZ_USUENC", NSZ->NSZ_USUENC )
						oModel:LoadValue("NSZMASTER", "NSZ_DTENCE", NSZ->NSZ_DTENCE )
						oModel:LoadValue("NSZMASTER", "NSZ_CMOFIN", NSZ->NSZ_CMOFIN )
						oModel:LoadValue("NSZMASTER", "NSZ_VLFINA", NSZ->NSZ_VLFINA )
						oModel:LoadValue("NSZMASTER", "NSZ_CMOENC", NSZ->NSZ_CMOENC )
						oModel:LoadValue("NSZMASTER", "NSZ_DETENC", NSZ->NSZ_DETENC )
					EndIf
				EndIf
			EndIf

			//Gera follow-up de aprovacao de Valor de Provisao ou Encerramento
			if lRet .And. (nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_INSERT)
				If !Empty( cTipFwApv )
					Processa( {| | lRet := J95FFwApv(oModel:GetValue("NSZMASTER", "NSZ_COD"), aDadFwApv, cTipFwApv, oModel)}, STR0018, "")	//"Gerando aprovação no Fluig"
				EndIf
			Endif

		EndIf
	EndIf

	Asize(aDadFwApv, 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95FFwApv
Gera follow-up de aprovacao
Uso geral.

@return	aCampos - Campos que seram gravados na NZK
@author Rafael Tenorio da Costa
@since 16/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95FFwApv( cProcesso, aCampos, cTipoFwApr, oModelAtu )
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local oModelFw  := Nil
	Local aTipoFw   := JurGetDados("NQS", 3, xFilial("NQS") + cTipoFwApr, {"NQS_COD", "NQS_DPRAZO"} )	//NQS_FILIAL + NQS_TAPROV	1=Alteracao Valor Provisao 2=Aprovacao de despesas 3=Aprovacao de Garantias 4=Aprovacao de Levantamento 5=Encerramento
	Local cTipoFw   := ""
	Local nDiaPrazo := 0
	Local cResultFw := JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD")					//NQN_FILIAL + NQN_TIPO		4=Em Aprovacao
	Local cPart	    := JurUsuario(__cUserId)
	Local cSigla    := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA")				//RD0_FILIAL + RD0_CODIGO
	Local aNTA      := {}
	Local aNTE      := {}
	Local aNZK      := {}
	Local aNZM      := {}
	Local aAux      := {}
	Local nCont     := 0
	Local nReg      := 0
	Local nOpc      := 3
	Local cConteudo  := ""
	Local nPosValor  := aScan(aCampos,{|x| x[1] == "NSZ_VLPROV"})
	Local nPosValNTA := aScan(aCampos,{|x| x[1] == "PROV_NTA"})
	Local nPosNumCas := aScan(aCampos,{|x| x[1] == "NUMCAS_NTA"})
	Local nValor     := IIF(nPosValor>0,aCampos[nPosValor][2],0)
	Local nValorNTA  := IIF(nPosValNTA>0,aCampos[nPosValNTA][2],0) // No caso de ser valor de provisão essa variável guardará o valor da diferença. Por exemplo, se estamos alterando a provisão de 15.000 para 20.000, esta variável guardará 5.000
	Local cValNumCas := IIF(nPosNumCas>0,aCampos[nPosNumCas][2],'0')
	Local cNQNTipoF  := "" //variável que vai guardar o tipo do resultado após incluir o WF no FLUIG.
	Local lFwPen     := .F.
	Local lFwAprov   := .F.
	Local cComplemento := ""
	Local dDataFu
	Local aErroNTA   := {}
	Local aExcCampos := {"PROV_NTA","NUMCAS_NTA"}

	ProcRegua(0)
	IncProc()
	IncProc()

	//Carrega follow-up
	If !Empty(aTipoFw)
		cTipoFw		:= aTipoFw[1]
		nDiaPrazo	:= Val( aTipoFw[2] ) //Verificar se o campo NQS_DPRAZO sera mesmo caracter
	EndIf

	// Verifica se já existe um follow-up com resultado PENDENTE e que possuí código de WF, ou seja,
	// um follow-up de uma aprovação que foi recusado, logo o follow-up teve seu resultado alterado para pendente.
	// Portanto não deve ser criado um novo follow-up. Os fluxos devem ter continuidade nesse mesmo follow-up.
	DbSelectArea("NTA")
	NTA->(DbSetOrder(2))

	If NTA-> ( DbSeek(xFilial("NTA") + cProcesso ) ) //NTA_FILIAL+NTA_CAJURI
		While !NTA->(eof()) .And. !lFwPen .And. !lFwAprov .And. NTA->NTA_FILIAL == xFilial("NTA") .And. NTA->NTA_CAJURI == cProcesso
			//Valida o tipo de aprovação do follow-up e se ele está como pendente
			If JurGetDados("NQS", 1, xFilial("NQS") + NTA->NTA_CTIPO, "NQS_TAPROV") == cTipoFwApr .And. NTA->NTA_CRESUL == JurGetDados("NQN", 3, xFilial("NQN") + "1", "NQN_COD") .And. !Empty(AllTrim(NTA->NTA_CODWF))
				lFwPen := .T.
				nOpc := 4
				cResultFw	:= JurGetDados("NQN", 3, xFilial("NQN") + "2", "NQN_COD")					//NQN_FILIAL + NQN_TIPO		2=Concluido
			ElseIf JurGetDados("NQS", 1, xFilial("NQS") + NTA->NTA_CTIPO, "NQS_TAPROV") == cTipoFwApr .And. NTA->NTA_CRESUL == JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD") .And. !Empty(AllTrim(NTA->NTA_CODWF))
				lFwAprov := .T.
			Else
				NTA->(dbSkip())
			EndIf
		End
	EndIf

	//Valida se já existe um follow-up em aprovação
	If !lFwAprov

		//se for domingo, acrescenda um dia
		if DOW(Date() + nDiaPrazo) == 1
			nDiaPrazo++
		Endif

		//se for sábado, acrescenda dois dias
		if DOW(Date() + nDiaPrazo) == 7
			nDiaPrazo := nDiaPrazo + 2
		Endif

		dDataFu := DataValida(Date() + nDiaPrazo,.T.)

		Aadd(aNTA, {"NTA_CAJURI", cProcesso			} )
		Aadd(aNTA, {"NTA_CTIPO" , cTipoFw			} )
		Aadd(aNTA, {"NTA_DTFLWP", dDataFu			} )
		Aadd(aNTA, {"NTA_CRESUL", cResultFw			} )
		Aadd(aNTA, {"NTA__VALOR", nValorNTA			} ) // Quando for valor de provisão, guarda o valor de diferença que esá na variável nValorNTA
		Aadd(aNTA, {"NTA__NUMCAS", cValNumCas		} )

		If lFwPen //se for pendente, atualiza o texto do follow-up
			cComplemento := CRLF + STR0005 + Transform(NSZ->NSZ_VLPROV, "@E 9999,999.99" ) // "Valor de provisão atual: "
			cComplemento += CRLF + STR0006 + Transform(nValorNTA, "@E 9999,999.99" ) // "Valor para aprovação: "
			cComplemento += CRLF + STR0007 + Transform(nValor, "@E 9999,999.99" ) //"Valor da provisão após aprovação: "

			Aadd(aNTA, {"NTA_DESC", cComplemento} )

			aAdd(aNZM, {"NZM_CODWF",AllTrim(NTA->NTA_CODWF)})
			aAdd(aNZM, {"NZM_CAMPO","sObsExecutor"})
			aAdd(aNZM, {"NZM_CSTEP","16"})
			aAdd(aNZM, {"NZM_STATUS","2"})

		EndIf

		//Valida se a aprovação é do tipo de encerramento para usar o texto do detalhamento do encerramento como descrição do follow-up
		if (aScan(aCampos,{|x| x[1] == "NSZ_DETENC"}) > 1)
			Aadd(aNTA, {"NTA_DESC", aCampos[aScan(aCampos,{|x| x[1] == "NSZ_DETENC"})][2]	} )
		Endif

		//Carerga participante
		Aadd(aNTE, {"NTE_SIGLA", cSigla	} )
		Aadd(aNTE, {"NTE_CPART", cPart	} )

		//Carrega Tarefas do Follow-up
		For nCont:=1 To Len( aCampos )

			If aScan(aExcCampos,aCampos[nCont][1]) <= 0// Como é um campo de valor de aprovação que é usado na NTA, não é necessário incluir na NZK

				Do Case

				Case ValType( aCampos[nCont][2] ) == "D"
					cConteudo := DtoS( aCampos[nCont][2] )

				Case ValType( aCampos[nCont][2] ) == "N"
					cConteudo := cValToChar( aCampos[nCont][2] )

				OtherWise
					cConteudo := aCampos[nCont][2]
				End Case

				aAux := {}
				Aadd(aAux, {"NZK_STATUS", "1"							} )		//1=Em Aprovacao
				Aadd(aAux, {"NZK_FONTE"	, "JURA095"						} )
				Aadd(aAux, {"NZK_MODELO", "NSZMASTER"					} )
				Aadd(aAux, {"NZK_CAMPO" , aCampos[nCont][1]				} )
				Aadd(aAux, {"NZK_VALOR" , cConteudo						} )
				Aadd(aAux, {"NZK_CHAVE" , xFilial("NSZ") + cProcesso	} )		//Chave da NSZ
				Aadd(aNZK, aAux)

			EndIf
		Next nCont

		//Prepara follow-up para inclusao
		oModelFw  := FWLoadModel("JURA106")
		oModelFw:SetOperation( nOpc )
		oModelFw:Activate()

		//Atualiza follow-up
		For nCont:=1 To Len( aNTA )

			If aNTA[nCont][1] == "NTA_CAJURI"

				If nOpc == 3
					oModelFw:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
				EndIf

				Loop

			EndIf

			If aNTA[nCont][1] == "NTA_CRESUL"
				If nOpc == 4
					oModelFw:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
				Else
					If !( oModelFw:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
						lRet := .F.
						Exit
					EndIf
				EndIf
			Else
				If !( oModelFw:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			EndIf

		Next nCont

		If lRet

			If nOpc == 3 //Somente se for uma inclusão
				//Atualiza participante
				For nCont:=1 To Len( aNTE )
					If !( oModelFw:SetValue("NTEDETAIL", aNTE[nCont][1], aNTE[nCont][2]) )
						lRet := .F.
						Exit
					EndIf
				Next nCont
			EndIf

			If nOpc == 4 //Somente se for uma alteração
				//Atualiza participante
				For nCont:=1 To Len( aNZM )
					If !( oModelFw:SetValue("NZMDETAIL", aNZM[nCont][1], aNZM[nCont][2]) )
						lRet := .F.
						Exit
					EndIf
				Next nCont
			EndIf

			If lRet

				//Atualiza tarefas do follow-up
				For nReg:=1 To Len( aNZK )

					If nReg > 1
						oModelFw:GetModel("NZKDETAIL"):AddLine()
					EndIf

					For nCont:=1 To Len( aNZK[nReg] )
						If !( oModelFw:SetValue("NZKDETAIL", aNZK[nReg][nCont][1], aNZK[nReg][nCont][2]) )
							lRet := .F.
							Exit
						EndIf
					Next nCont
				Next nReg

				//Inclui follow-up
				If lRet
					If ( lRet := oModelFw:VldData() )
						lRet := oModelFw:CommitData()
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet

			//Valida se o follow-up está concluído ou em aprovação
			cNQNTipoF := JurGetDados('NQN',1,xFilial('NQN')+oModelFw:GetValue("NTAMASTER","NTA_CRESUL"),"NQN_TIPO")

			if (cNQNTipoF == "2")

				//Volta os valores pois o FW foi concluído.
				For nCont := 1 to Len(aCampos)
					If aScan(aExcCampos,aCampos[nCont][1]) <= 0
						oModelAtu:LoadValue("NSZMASTER",aCampos[nCont][1],aCampos[nCont][2])
					Endif
				Next
			Else

			 	//Exibe mensagem de aprovação
				ApMsgInfo(	STR0008 + CRLF + CRLF +;	//"Aprovação enviada para o FLUIG."
				STR0009, ProcName(0) )		//"Os dados alterados serão atualizados quando a aprovação for concluída."
			Endif
		Else

			aErroNTA := oModelFw:GetErrorMessage()
		EndIf

		oModelFw:DeActivate()
		oModelFw:Destroy()

		FWModelActive( oModelAtu )
		oModelAtu:Activate()

	//Já existe um follow-up que está pendente com a mesma aprovação
	Else
		lRet := .F.
		aErroNTA	:= Array(7)
		aErroNTA[6] := STR0011 + CRLF + STR0012	//"Já existe uma aprovação pendente"	"Encerre a solicitação atual antes de solicitar nova aprovação. Você pode consultar na rotina de follow-ups as solicitações pendentes."
	EndIf

	//Seta erro no modelo atual para retornar mensagem
	If !lRet .And. Len(aErroNTA) > 0
		oModelAtu:SetErrorMessage(aErroNTA[1]			 	  , aErroNTA[2], aErroNTA[3], aErroNTA[4] 	, aErroNTA[5],;
			   					  STR0010 + CRLF + aErroNTA[6], aErroNTA[7], /*xValue*/ , /*xOldValue*/ )	//"Não foi possível incluír o follow-up de aprovação. Verifique!"
	EndIf

	aSize(aErroNTA, 0)

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95FTarFw
Verifica se existe tarefa de follow-up para o processo.
Uso geral.

@param	cProcesso	- Codigo do processo que sera procurado
@param	cStatus		- Status da tarefa do follow-up que sera procurada na tabela NZK.
@param	cTipFwApv
@return	lRetorno 	- Informando se existe ou nao tarefa de follow-up.
@author Rafael Tenorio da Costa
@since 17/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95FTarFw( cProcesso, cStatus, aTipFwApv )

	Local aArea		:= GetArea()
	Local lRetorno	:= .F.
	Local cTabela	:= GetNextAlias()
	Local cQuery	:= ""
	Local nCont		:= 0
	Local cTipFwApv	:= ""

	For nCont:=1 To Len(aTipFwApv)
		cTipFwApv += "'" + aTipFwApv[nCont] + "',"
	Next nCont
	cTipFwApv := SubStr(cTipFwApv, 1, Len(cTipFwApv) - 1)

	cQuery := " SELECT NTA_COD " + CRLF
	cQuery += " FROM " +RetSqlName("NTA")+ " NTA INNER JOIN " +RetSqlName("NZK")+ " NZK " + CRLF
	cQuery +=	" ON NTA_FILIAL = NZK_FILIAL AND NTA_COD = NZK_CFLWP " + CRLF
	cQuery += " INNER JOIN " +RetSqlName("NQS")+ " NQS " +CRLF
	cQuery += 	" ON NQS_FILIAL = '" +xFilial("NQS")+ "' AND NTA_CTIPO = NQS_COD " + CRLF
	cQuery += " INNER JOIN " +RetSqlName("NQN")+ " NQN " +CRLF
	cQuery += 	" ON NQN_FILIAL = '" +xFilial("NQN")+ "' AND NTA_CRESUL = NQN_COD AND (NQN_TIPO <> '2' AND NQN_TIPO <> '3') " + CRLF
	cQuery += " WHERE NTA_FILIAL = '" +xFilial("NTA")+ "' " + CRLF
	cQuery += 	" AND NTA_CAJURI = '" +cProcesso+ "' " 		+ CRLF
	cQuery += 	" AND NZK_STATUS = '" +cStatus+ "' "		+ CRLF		//0=Em Execucao; 1=Em Aprovacao; 2=Aprovada; 3=Reprovada
	cQuery += 	" AND NQS_TAPROV IN (" +cTipFwApv+ ") "		+ CRLF		//1=Alteracao Valor Provisao; 2=Aprovacao de despesas; 3=Aprovacao de Garantias; 4=Aprovacao de Levantamento; 5=Encerramento; 6=Objeto
	cQuery += 	" AND NTA.D_E_L_E_T_ = ' ' "				+ CRLF
	cQuery += 	" AND NZK.D_E_L_E_T_ = ' ' "				+ CRLF
	cQuery += 	" AND NQS.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

	If !(cTabela)->( Eof() )
		lRetorno := .T.
	EndIf

	(cTabela)->( DbCloseArea() )
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J95WFEnd
Obtém do workflow do fluig o status atual.

@param cIDwF Número da solicitação do workflow
@param cState Estado que deve ser validado. Informar sempre o último status.
@Return lRet .T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 17/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95WFEnd(cIdWF)

	Local aArea       := GetArea()
	Local nC          := 0
	Local cSolicitId  := ''
	Local cUsuario    := SuperGetMV('MV_ECMUSER',,'')
	Local cSenha      := SuperGetMV('MV_ECMPSW',,'')
	Local cEmpresa    := SuperGetMV('MV_ECMEMP',,'0')
	Local cMensagem   := ''
	Local aValores    := {}
	Local aCardData   := {}
	Local aSubs       := {}
	Local xRet        := ''
	Local oXml        := nil
	Local cErro       := ''
	Local cAviso      := ''
	Local cTag        := ''
	Local lRet        := .F.

	Begin Sequence

    //Solicitante como o usuario logado.
	cSolicitId := JColId(cUsuario,cSenha,cEmpresa,UsrRetMail(__cUserID))

	If  Empty( cSolicitId )
		cMensagem := STR0015 //"Não foi possível obter id do solicitante!"
		Break
	EndIf

	aadd(aValores, {"username"          , cUsuario   })
	aadd(aValores, {"password"          , cSenha     })
	aadd(aValores, {"companyId"         , cEmpresa   })
	aadd(aValores, {"processInstanceId" , cIdWF      })
	aadd(aValores, {"userId"            , cSolicitId })

   	//Retirado o elemento da tag devido o obj nao suportar
	aadd( aSubs, {'"', "'"})
	aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
	aadd( aSubs, {"<item />", ""})

	If  !( JA106TWSDL("ECMWorkflowEngineService", "getAllActiveStates", aValores, aCardData, aSubs, @xRet, @cMensagem) )
		Break
	EndIf

  	//Obtem somente a Tag do XML de retorno
	cTag := '</States>'
	nC   := At(StrTran(cTag,"/",""),xRet)
	xRet := SubStr(xRet, nC, Len(xRet))
	nC   := At(cTag,xRet) + Len(cTag) - 1
	xRet := Left(xRet, nC)

  	//Gera o objeto do Result Tag
	oXml := XmlParser( xRet, "_", @cErro, @cAviso )

	If  Empty(oXml) .And. !Empty(cMensagem)
		cMensagem := STR0016 //"Não foi possível obter o XML de retorno do WS Fluig!"
		Break
	EndIf

    //Verifica se esta concluido ou nao.
	if oXml != nil .And. !Empty(oXml) .And. Empty(cMensagem)
		lRet := .F. //retorna falso pois não houve retorno
	Endif

    //valida se o processo ja foi concluído e o retorno é vazio
	if (oXml == nil .Or. Empty(oXml)) .And. Empty(cMensagem)
		lRet := .T.
	Endif

End Sequence

If  !( Empty(cMensagem) )
	JurConOut(STR0017 + cMensagem)		//"Erro: "
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95FAtPeCo()
Atualiza permissões dos Correspondentes nas pastas do Fluig

@author  Rafael Tenorio da Costa
@since   10/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95FAtPeCo(oModel)
Local cCodCli    := oModel:GetValue("NSZMASTER", "NSZ_CCLIEN")
Local cLojCli    := oModel:GetValue("NSZMASTER", "NSZ_LCLIEN")
Local cCaso      := oModel:GetValue("NSZMASTER", "NSZ_NUMCAS")
Local nOpc       := oModel:GetOperation()
Local oModelNUQ  := oModel:GetModel("NUQDETAIL")
Local nCont      := 0
Local nPos       := 0
Local cCodCor    := ""
Local cLojCor    := "'
Local aDelCorres := {}
Local aIncCorres := {}
Local lPrimeira  := .T.
Local aCaso      := {cCodCli, cLojCli, cCaso}
Local cCodAsJur  := oModel:GetValue("NSZMASTER", "NSZ_TIPOAS")

	If !JurAuto()

		//Carrega correspondentes alterados
		For nCont := 1 To oModelNUQ:GetQtdLine()

			oModelNUQ:GoLine(nCont)

			cCodCor := oModelNUQ:GetValue("NUQ_CCORRE")
			cLojCor := oModelNUQ:GetValue("NUQ_LCORRE")

			//Se for alteração pega correspondente da base
			If  nOpc == MODEL_OPERATION_UPDATE .And. lPrimeira
				aDelCorres := J183RetCor(FwFldGet("NSZ_FILIAL"), FwFldGet("NSZ_COD"))
			EndIf

			If !oModelNUQ:IsDeleted(nCont) .And. !Empty(cCodCor) .And. !Empty(cLojCor)

				nPos := Ascan(aDelCorres, {|x| AllTrim(x[1]) == cCodCor .And. AllTrim(x[2]) == cLojCor} )

				//Correspodente ja existe
				If nPos > 0
					aDel(aDelCorres, nPos)
					aSize(aDelCorres, Len(aDelCorres) - 1)

				//Correspodente não existe
				Else
					Aadd(aIncCorres, {cCodCor, cLojCor})
				EndIf
			EndIf

			lPrimeira := .F.

		Next nCont

		//Altera as permissões
		If Len(aDelCorres) > 0 .Or. Len(aIncCorres) > 0
			Processa( {|| J163AtPeCo(Iif(IsInCallStack("JURA162"), JurGetPesq(),""), aCaso, aDelCorres, aIncCorres,cCodAsJur, "JURA095")}, STR0013, , .F.)	//"Atualizando permissões dos Correspondentes"
		EndIf
	EndIf

	aSize(aCaso, 0)
	aSize(aDelCorres, 0)
	aSize(aIncCorres, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J95FPstFlu()
Atualiza pastas dos casos no Fluig

@author  Rafael Tenorio da Costa
@since   18/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95FPstFlu(oModel)

	Local aArea		:= GetArea()
	Local aAreaNZ7	:= NZ7->( GetArea() )
	Local cCodCli	:= oModel:GetValue("NSZMASTER", "NSZ_CCLIEN")
	Local cLojCli	:= oModel:GetValue("NSZMASTER", "NSZ_LCLIEN")
	Local cCaso		:= oModel:GetValue("NSZMASTER", "NSZ_NUMCAS")
	Local cChvCaso	:= cCodCli + cLojCli + cCaso
	Local cTipoAsj	:= ""
	Local nOpc 	    := oModel:GetOperation()

	DbSelectArea("NS7")
	NZ7->( DbSetOrder(1) )

	//Verifica se teve alguma alteração no cliente\caso ou se não existe o link do caso com fluig
	If nOpc == MODEL_OPERATION_UPDATE .And.;
	   ( oModel:IsFieldUpdated("NSZMASTER", "NSZ_CCLIEN") .Or.;
	     oModel:IsFieldUpdated("NSZMASTER", "NSZ_LCLIEN") .Or.;
	     oModel:IsFieldUpdated("NSZMASTER", "NSZ_NUMCAS") .Or.;
		 !NZ7->( DbSeek(xFilial("NZ7") + cChvCaso) )	  .Or.;
		 Empty(NZ7->NZ7_LINK) )

		cTipoAsj := oModel:GetValue("NSZMASTER", "NSZ_TIPOAS")

		//Atualiza pastas
		Processa( {|| J070PFluig(cChvCaso, "", cTipoAsj)}, STR0014, , .F.)	//"Atualizando pastas no Fluig"
	EndIf

	RestArea( aAreaNZ7 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J95FHisFlu
Obtem o historio da atividade no Fluig

@param 	cIDwF 		- Id da tarefa no Fluig
@return	aHistorico	- Historico de alteração na tarefa no Fluig

@author  Rafael Tenorio da Costa
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95FHisFlu(cIdWF)

	Local aArea      := GetArea()
	Local cUsuario   := SuperGetMV("MV_ECMUSER", , "" )
	Local cSenha     := SuperGetMV("MV_ECMPSW" , , "" )
	Local cEmpresa   := SuperGetMV("MV_ECMEMP" , , "0")
	Local cSolicitId := JColId(cUsuario, cSenha, cEmpresa, cUsuario)
	Local cMensagem  := ""
	Local aValores   := {}
	Local xRet       := ""
	Local oXml       := Nil
	Local cErro      := ""
	Local cAviso     := ""
	Local aAux       := {}
	Local aHistorico := {}
	Local nHistorico := 0
	Local nHist      := 0

	If Empty(cSolicitId)

		cMensagem := STR0015 //"Não foi possível obter id do solicitante!"
	Else

		Aadd(aValores, {"username"          , cUsuario  })
		Aadd(aValores, {"password"          , cSenha    })
		Aadd(aValores, {"companyId"         , cEmpresa  })
		Aadd(aValores, {"userId"            , cSolicitId})
		Aadd(aValores, {"processInstanceId" , cIdWF     })

		//Prepara e executa a classe TWSDLManager
		If Ja106TWsdl("ECMWorkflowEngineService", "getHistories", aValores, /*aCardData*/, /*aSubs*/, @xRet, @cErro)

			//Verifica se teve erro
			If Empty(cErro)
				cErro := GetSimples(xRet, "<faultstring>", "</faultstring>")
			EndIf

			//Obtem somente a Tag do XML de retorno
			If Empty(cErro)
				xRet := GetSimples(xRet, "<Histories>", "</Histories>")
				If !Empty(xRet)
					xRet := "<Histories>" + xRet + "</Histories>"
				EndIf

				//Gera o objeto do Result Tag
				oXml := XmlParser(xRet, "_", @cErro, @cAviso)
			EndIf

			If oXml <> Nil .And. XmlChildEx(oXml, "_HISTORIES") <> Nil

				If ValType(oXml:_HISTORIES:_ITEM) == "A"

					nHistorico := Len(oXml:_HISTORIES:_ITEM)

					For nHist:=1 To nHistorico

						aAux  := {}
						Aadd(aAux, TrataCmp("D", oXml:_HISTORIES:_ITEM[nHist]:_MOVEMENTDATE:TEXT	) )
						Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_MOVEMENTHOUR:TEXT	) )
						Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_MOVEMENTSEQUENCE:TEXT) )
						Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_LABELACTIVITY:TEXT	) )

						If XmlChildEx(oXml:_HISTORIES:_ITEM[nHist], "_TASKS") <> Nil
							If ValType(oXml:_HISTORIES:_ITEM[nHist]:_TASKS) == "A"
								Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_TASKS[1]:_HISTORCOMPLETECOLLEAGUE:TEXT) )
								Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_TASKS[1]:_HISTORTASKOBSERVATION:TEXT  ) )
							Else
								Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_TASKS:_HISTORCOMPLETECOLLEAGUE:TEXT) )
								Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM[nHist]:_TASKS:_HISTORTASKOBSERVATION:TEXT  ) )
							EndIf
						Else
							Aadd(aAux, "")
							Aadd(aAux, "")
						EndIf

						Aadd(aHistorico, aClone(aAux))
					Next nHist
				Else

					aAux  := {}
					Aadd(aAux, TrataCmp("D", oXml:_HISTORIES:_ITEM:_MOVEMENTDATE:TEXT	 ) )
					Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM:_MOVEMENTHOUR:TEXT	 ) )
					Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM:_MOVEMENTSEQUENCE:TEXT) )
					Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM:_LABELACTIVITY:TEXT	 ) )

					If XmlChildEx(oXml:_HISTORIES:_ITEM, "_TASKS") <> Nil
						Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM:_TASKS:_HISTORCOMPLETECOLLEAGUE:TEXT) )
						Aadd(aAux, TrataCmp("C", oXml:_HISTORIES:_ITEM:_TASKS:_HISTORTASKOBSERVATION:TEXT  ) )
					Else
						Aadd(aAux, "")
						Aadd(aAux, "")
					EndIf

					Aadd(aHistorico, aClone(aAux))
				EndIf

			EndIf
		EndIf

		If Empty(oXml) .Or. !Empty(cErro)
			cMensagem := STR0016 + CRLF + cErro //"Não foi possível obter o XML de retorno do WS Fluig!"
		EndIf
	EndIf

	If !Empty(cMensagem)
		JurMsgErro(cMensagem)
	EndIf

	FwFreeObj(oXml)
	FwFreeObj(aAux)
	FwFreeObj(aValores)

	RestArea( aArea )

Return aHistorico

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataCmp()
Formata os campos retornados no XML.

@param	 cTipo		- Tipo do campo
@param	 xConteudo	- Conteúdo a ser formatado
@return  xConteudo 	- Conteúdo formatado

@author	 Rafael Tenorio da Costa
@since 	 27/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TrataCmp(cTipo, xConteudo)

	Do Case
		Case cTipo == "C"
			xConteudo := StrTran(xConteudo, Chr(10), " ")
			xConteudo := StrTran(xConteudo, Chr(13), " ")
			xConteudo := AllTrim(xConteudo)

		Case cTipo == "D"
			xConteudo := Left(xConteudo, 10)
			xConteudo := StrTran(xConteudo, "-", "")
			xConteudo := StoD(xConteudo)

		Case cTipo == "N"
			xConteudo := AllTrim(xConteudo)
			xConteudo := Val(xConteudo)
	End Case

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpPstCorr( cCodFili, cCodNSZ )
Formata os campos retornados no XML.

@param	 cCodFili  - Filial do Processo
@param	 cCodNSZ   - Código do Processo

@author	 Willian Yoshiaki Kazahaya
@since   20/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUpPstCorr( cCodFili, cCodNSZ )
Local cAliasNUQ  := Nil
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryGrp    := ""
Local cQryOrd    := ""
Local cQuery     := ""
Local aDelCorres := {}
Local aIncCorres := {}
Local aCaso      := {}
Local cCodAsJur  := ""

	cQrySel := " SELECT NSZ.NSZ_CCLIEN,"
	cQrySel +=        " NSZ.NSZ_LCLIEN,"
	cQrySel +=        " NSZ.NSZ_NUMCAS,"
	cQrySel +=        " NSZ.NSZ_TIPOAS,"
	cQrySel +=        " NUQ.NUQ_CCORRE,"
	cQrySel +=        " NUQ.NUQ_LCORRE "
	cQryFrm := " FROM " + RetSqlName("NSZ") + " NSZ INNER JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrm +=                                                                             " AND NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrm +=                                                                             " AND NUQ.D_E_L_E_T_ = ' ') "
	cQryWhr := " WHERE NSZ.NSZ_COD = '" + cCodNSZ + "'"
	cQryWhr +=   " AND NSZ.NSZ_FILIAL = '" + cCodFili + "'"
	cQryWhr +=   " AND NSZ.D_E_L_E_T_ = ' ' "
	cQryWhr +=   " AND NUQ.NUQ_CCORRE > ' ' "
	cQryGrp := " GROUP BY NSZ.NSZ_CCLIEN, "
	cQryGrp +=         " NSZ.NSZ_LCLIEN, "
	cQryGrp +=         " NSZ.NSZ_NUMCAS, "
	cQryGrp +=         " NSZ.NSZ_TIPOAS, "
	cQryGrp +=         " NUQ.NUQ_CCORRE, "
	cQryGrp +=         " NUQ.NUQ_LCORRE  "
	cQryOrd := " ORDER BY NUQ.NUQ_CCORRE, "
	cQryOrd +=          " NUQ.NUQ_LCORRE  "

	cAliasNUQ := GetNextAlias()

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr + cQryGrp + cQryOrd )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cAliasNUQ,.T.,.T.)

	// Busca os Correspondentes a serem incluidos
	While( (cAliasNUQ)->(!Eof()) )
		If Len(aCaso) == 0 //Somente insere um Caso
			Aadd(aCaso, (cAliasNUQ)->NSZ_CCLIEN )
			Aadd(aCaso, (cAliasNUQ)->NSZ_LCLIEN )
			Aadd(aCaso, (cAliasNUQ)->NSZ_NUMCAS )
		EndIf

		cCodAsJur := (cAliasNUQ)->NSZ_TIPOAS

		Aadd(aIncCorres, { (cAliasNUQ)->NUQ_CCORRE, (cAliasNUQ)->NUQ_LCORRE })

		(cAliasNUQ)->( DbSkip() )
	EndDo
	(cAliasNUQ)->( DbCloseArea() )

	// Se houver correspondente, roda a rotina de atualização de permissões
	If Len(aIncCorres) > 0
		J163AtPeCo(Iif(IsInCallStack("JURA162"), JurGetPesq(),""), aCaso, aDelCorres, aIncCorres,cCodAsJur, "TJurAnxFluig")
	EndIf

	aSize(aCaso, 0)
	aSize(aDelCorres, 0)
	aSize(aIncCorres, 0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpPstClie( cCodFili, cCodNSZ )
Atualiza a permissão de pasta do Cliente

@param  cCodFili - Filial do Assunto juridico
@param  cCajuri  - Código do assunto juridico

@author  Willian Yoshiaki Kazahaya
@since   20/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUpPstClie( cCodFili, cCodNSZ )
Local cAliasNUQ  := Nil
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""
Local cQryGrp    := ""
Local cQuery     := ""
Local cCodPasta  := ""
Local cEndEmail  := ""
Local cColIdInc  := ""
Local cErro      := ""
Local cCodUsu    := ""
Local cNomeUseId := ""
Local nCont      := 0
Local aGuardaUsu := {}
Local cUsuario   := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha     := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local nEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,0 ))

	cQrySel := " SELECT NSZ.NSZ_NUMCAS, NSZ.NSZ_TIPOAS, NZY.NZY_CUSER, NVK.NVK_CUSER, NZ7.NZ7_LINK "
	cQryFrm := " FROM " + RetSqlName("NWO") + " NWO INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_COD = NWO.NWO_CCONF)"
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_CCLIEN = NWO.NWO_CCLIEN "
	cQryFrm +=                                                                             " AND NSZ.NSZ_LCLIEN = NWO.NWO_CLOJA) "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NZ7") + " NZ7 ON (NZ7.NZ7_CCLIEN = NSZ.NSZ_CCLIEN "
	cQryFrm +=                                                                             " AND NZ7.NZ7_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrm +=                                                                             " AND NZ7.NZ7_NUMCAS = NSZ.NSZ_NUMCAS)"
	cQryFrm +=                                    " LEFT  JOIN " + RetSqlName("NZX") + " NZX ON (NZX.NZX_COD = NVK.NVK_CGRUP "
	cQryFrm +=                                                                             " AND NZX.D_E_L_E_T_ = ' ') "
	cQryFrm +=                                    " LEFT  JOIN " + RetSqlName("NZY") + " NZY ON (NZY.NZY_CGRUP = NZX.NZX_COD "
	cQryFrm +=                                                                             " AND NZY.D_E_L_E_T_ = ' ') "
	cQryWhr := " WHERE NSZ.NSZ_COD    = '" + cCodNSZ + "' "
	cQryWhr +=   " AND NSZ.NSZ_FILIAL = '" + cCodFili + "' "
	cQryWhr +=   " AND NWO.D_E_L_E_T_ = ' ' "
	cQryWhr +=   " AND NVK.D_E_L_E_T_ = ' ' "
	cQryWhr +=   " AND NSZ.D_E_L_E_T_ = ' ' "
	cQryWhr +=   " AND NZ7.D_E_L_E_T_ = ' ' "
	cQryGrp := " GROUP BY NSZ.NSZ_CCLIEN, "
	cQryGrp +=          " NSZ.NSZ_LCLIEN, "
	cQryGrp +=          " NSZ.NSZ_NUMCAS, "
	cQryGrp +=          " NZY.NZY_CUSER, "
	cQryGrp +=          " NVK.NVK_CUSER, "
	cQryGrp +=          " NSZ.NSZ_TIPOAS, "
	cQryGrp +=          " NZ7.NZ7_LINK "
	cQryOrd := " ORDER BY NSZ.NSZ_CCLIEN, "
	cQryOrd +=          " NSZ.NSZ_LCLIEN,"
	cQryOrd +=          " NSZ.NSZ_NUMCAS,"
	cQryOrd +=          " NZY.NZY_CUSER "

	cAliasNUQ := GetNextAlias()

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr + cQryGrp + cQryOrd)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cAliasNUQ,.T.,.T.)

	// Busca os Correspondentes a serem incluidos
	While( (cAliasNUQ)->(!Eof()) )
		//Carrega o Id do usuario no fluig
		If Empty((cAliasNUQ)->NZY_CUSER)
			cCodUsu := (cAliasNUQ)->NVK_CUSER
		Else
			cCodUsu := (cAliasNUQ)->NZY_CUSER
		EndIf

		// Busca o E-mail para buscar o ColleagueId do usuário
		cEndEmail := AllTrim( UsrRetMail( cCodUsu ) )

		If !Empty(cEndEmail) .And. aScan( aGuardaUsu, {|x| AllTrim(x[1]) == AllTrim(cEndEmail)} ) == 0

			cColIdInc := JColId(cUsuario, cSenha, nEmpresa, cEndEmail, @cErro, .F.)

			If Empty(cColIdInc) .And. !Empty(cErro)
				Aadd(aGuardaUsu, {cEndEmail, cColIdInc, cErro})
				
				(cAliasNUQ)->( DbSkip() )
				loop
			EndIf

			// Se não houve erro, altera a config de Segurança da pasta
			cCodPasta := SubStr((cAliasNUQ)->NZ7_LINK, 1, At(";", (cAliasNUQ)->NZ7_LINK) - 1)

			J163SetPer( cCodPasta, cUsuario, cSenha, nEmpresa, "1", cColIdInc, .T.)
		Else
			If Empty(cEndEmail)
				cEndEmail := UsrRetName( cCodUsu )
				
				If Len(aGuardaUsu) > 0 .And. aScan(aGuardaUsu, { |x| cEndEmail == x[2] }) == 0
					Aadd(aGuardaUsu, {cEndEmail, cEndEmail, I18n(STR0019, {cEndEmail})})
				EndIf
			EndIf
		EndIf
		
		(cAliasNUQ)->( DbSkip() )
	EndDo

	If Len(aGuardaUsu) > 0
		cErro      := ""
		cEndEmail  := ""
		cNomeUseId := AllTrim( UsrRetMail(__cUserID) )

		If Empty(cNomeUseId)
			cNomeUseId := UsrRetName( __cUserID )
		EndIf

		If aScan( aGuardaUsu, { |x| !Empty(x[3]) } ) > 0
			For nCont := 1 to Len(aGuardaUsu)
				If !Empty(aGuardaUsu[nCont][3])
					If STR0020 $ aGuardaUsu[nCont][3]
						cErro := STR0020 //"Objeto XML nao criado, verificar a estrutura do XML"
					Else
						If (cNomeUseId == aGuardaUsu[nCont][1])
							cEndEmail := aGuardaUsu[nCont][1] + CRLF
							Exit
						EndIf
					EndIf
				EndIf
			Next

			If !Empty(cEndEmail)
				cErro := I18n(STR0019, {cEndEmail}) //"Usuário #1 não está ativo no Fluig!"
			EndIf

			If !Empty(cErro) .And. !JurAuto()
				JurMsgErro('JColId: ' + cErro)
			EndIf
		EndIf
	EndIf
	
	(cAliasNUQ)->( DbCloseArea() )
Return