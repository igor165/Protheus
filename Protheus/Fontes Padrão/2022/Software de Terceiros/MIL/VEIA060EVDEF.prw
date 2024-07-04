#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#INCLUDE "VEIA060EVDEF.CH"

#DEFINE lDebug .f.

/*/{Protheus.doc} VEIA060EVDEF
//TODO Descrição auto-gerada.

Eventos padrão do Pedido de Venda de Veiculos para Montadora/Distribuidora de Veiculos, as regras
definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC.

@author Rubens
@since 02/12/2018
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
CLASS VEIA060EVDEF FROM FWModelEvent

	Data cStatusAtual
	Data cSeqVRL
	Data nTamSeqVRL
	Data lVRKCANCELProc_Item
	Data lVRLCANCELProc_Financeiro
	Data cOperPadrao
	Data cTESPadrao

	Data _oVeiculo

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD VldActivate()
	METHOD DeActivate()
	METHOD GridLinePreVld()
	METHOD FieldPreVld()
	METHOD BeforeTTS()
	METHOD AfterTTS()
	METHOD ModelPreVld()
	METHOD ModelPosVld()

ENDCLASS

METHOD New() CLASS VEIA060EVDEF

	Pergunte("VEIA060",.f.,,,,.f.)
	::cOperPadrao := MV_PAR01
	::cTESPadrao  := MV_PAR02
	::_oVeiculo := DMS_Veiculo():New()

RETURN

METHOD Activate(oModel, lCopy) CLASS VEIA060EVDEF
	Local nOperation := oModel:GetOperation()
	Local oModelVRK := oModel:GetModel("MODEL_VRK")

	If nOperation == MODEL_OPERATION_INSERT
		::cStatusAtual := ""
	Else
		::cStatusAtual := oModel:GetValue('MODEL_VRJ','VRJ_STATUS')
	EndIf

	::lVRKCANCELProc_Item := .f.
	::lVRLCANCELProc_Financeiro := .f.

	// Adiciona informacoes dos campos da VRK criados manualmente
	// Adiciona itens no fiscal
	VA060E0103_procItensPedido(oModel)
	//

	oModelVRK:GoLine(1)

RETURN .T.

METHOD VldActivate(oModel, cModelId) CLASS VEIA060EVDEF
	Local nOperation := oModel:GetOperation()
	Local lRet := .t.

	If nOperation == MODEL_OPERATION_UPDATE
		If VRJ->VRJ_STATUS $ "C/R"
			FMX_HELP("VA060EVDEFERR008",STR0001) // "Alteração não permitida para atendimentos Cancelados ou Reprovados."
			lRet := .f.
		EndIf
		If (VRJ->VRJ_STATUS <> "A" .or. Empty(VRJ->VRJ_STATUS))
			If ! IsInCallStack("VEIA060A") .AND. ! IsInCallStack("VEIA060B") .AND. ! IsInCallStack("VA0600273_FaturarAtendimentos")

				//VA060ED_SaidaConsole("VldActivate - Bloqueando alteração do Pedido ...")
				// Configura limitações de edição do pedido ...
				oModel:GetModel("MODEL_VRJ"):SetOnlyView()
				oModel:GetModel("MODEL_VRK"):SetNoInsertLine(.t.)
				oModel:GetModel("MODEL_VRK"):SetNoDeleteLine(.t.)
				oModel:GetModel("MODEL_VRL"):SetOnlyView()

				//FMX_HELP("VA060EVDEFERR002","Alteração permitida somente para pedidos com status Aberto")
				//lRet := .f.
			EndIf
		EndIf
	EndIf

Return lRet

METHOD DeActivate(oModel) CLASS VEIA060EVDEF
	If MaFisFound("NF")
		MaFisEnd()

		//VA060ED_SaidaConsole("MaFisEnd")
		//VA060ED_SaidaConsole(" ")
		//VA060ED_SaidaConsole("DeActivate")
		//VA060ED_SaidaConsole(" ")
		//VA060ED_SaidaConsole("----------------------------------------------------")
		//If lDebug
		//	Conout(" ")
		//	Conout(" ")
		//EndIf
	EndIf

RETURN


METHOD BeforeTTS(oModel, cModelId) CLASS VEIA060EVDEF

	Local oModelVRJ := oModel:GetModel("MODEL_VRJ")
	Local oModelVX0 := oModel:GetModel("MODEL_VX0")
	Local nLinhaAtual
	Local cAuxSeq := ""

	If ::cStatusAtual <> oModelVRJ:GetValue("VRJ_STATUS")
		If Empty(oModelVRJ:GetValue("VRJ_LOGVX0"))
			oModelVX0:SetValue("VX0_CODIGO", GetSXENum("VX0","VX0_CODIGO"))
			oModelVRJ:SetValue("VRJ_LOGVX0", oModelVX0:GetValue("VX0_CODIGO"))
		EndIf

		nLinhaAtual := oModelVX0:Length()
		If nLinhaAtual == 1 .and. Empty(oModelVX0:GetValue("VX0_TIPO"))
			oModelVX0:SetValue("VX0_SEQUEN", "01")
		Else
			For nLinhaAtual := 1 to oModelVX0:Length()
				If oModelVX0:GetValue("VX0_SEQUEN", nLinhaAtual) > cAuxSeq
					cAuxSeq := oModelVX0:GetValue("VX0_SEQUEN", nLinhaAtual)
				EndIf
			Next nLinhaAtual
			cAuxSeq := Soma1(cAuxSeq)
			nLinhaAtual := oModelVX0:AddLine()
			oModelVX0:SetValue("VX0_SEQUEN", cAuxSeq)
		EndIf

		oModelVX0:SetValue("VX0_DATA", dDataBase)
		oModelVX0:SetValue("VX0_HORA", Left(Time(),2) + SubString(Time(),4,2) )
		oModelVX0:SetValue("VX0_TIPO", "PVA" + oModelVRJ:GetValue("VRJ_STATUS"))

	EndIf
RETURN .T.

METHOD AfterTTS(oModel, cModelId) CLASS VEIA060EVDEF
	Local nOperation := oModel:GetOperation()
	Local oModelVRK

	//VA060ED_SaidaConsole("AfterTTS - " + cModelID )

	If VRJ->VRJ_STATUS == "A"
		If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
			oModelVRK := oModel:GetModel("MODEL_VRK")
			VEIVM130TAR(VRJ->VRJ_PEDIDO,"1","3",VRJ->VRJ_FILIAL,.f.,VRJ->VRJ_TIPVEN, VA0600203_FormatINMarca(oModelVRK) ) // Tarefas: 1-Gravacao / 3-Pedido de Venda Atacado
		Endif
	Endif

RETURN

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cID, xValue, xCurrentValue) CLASS VEIA060EVDEF
	Local cCodMar
	Local cModVei
	Local nItemFiscal

	Default cID := ""
	Default xValue := ""
	Default xCurrentValue := ""

	Private bRefresh := { || .t. } // Variavel utilizada no FISCAL

	Do Case
	Case cModelID == "MODEL_VRK"

		nItemFiscal := VA0600093_VeiFis() // Ajusta Variavel Private N de acordo com o Ambiente Fiscal

		If cAction == "DELETE"
			If oSubModel:GetValue("VRK_CANCEL") == "1"
				FMX_HELP("VA060EVDEFERR006",STR0002, STR0005) // "Não é permitido alteração de registro cancelado." // "Selecione um novo registro para manuteção"
				Return .f.
			EndIf
			If N <> 0
				MaFisDel(N,.t.)

				If oSubModel:GetValue("VV2RECNO") <> 0
					aAtuResumo := {}
					If oSubModel:GetValue("VRK_VALVDA") <> 0
						AADD(aAtuResumo, { "RESVALTOT" , oSubModel:GetValue("VRK_VALVDA") * -1})
					EndIf
					AADD(aAtuResumo, { "RESQTDEVEND" , -1 })
					If ! Empty(oSubModel:GetValue("VRK_CHAINT"))
						AADD(aAtuResumo, { "RESQTDEVINC" , -1 })
					EndIf
					VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, aAtuResumo)
				EndIf

			EndIf
		EndIf

		If cAction == "UNDELETE" .and. N <> 0
			If ::lVRKCANCELProc_Item == .f.
				MaFisDel(N,.f.)
				If oSubModel:GetValue("VV2RECNO") <> 0
					// Restaura linha quando deletada ...
					VA0600233_AddResumo(, oSubModel, {oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")})
					//
					aAtuResumo := {}
					If oSubModel:GetValue("VRK_VALVDA") <> 0
						AADD(aAtuResumo, { "RESVALTOT" , oSubModel:GetValue("VRK_VALVDA") })
					EndIf
					If ! Empty(oSubModel:GetValue("VRK_CHAINT") )
						AADD(aAtuResumo, { "RESQTDEVINC" , 1 })
					EndIf
					VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, aAtuResumo)

					oAuxView := FWViewActive()
					If oAuxView <> NIL
						oAuxView:Refresh("VIEW_RESUMO")
					EndIf
				EndIf
			EndIf
		EndIf

		If cAction == "CANSETVALUE"


			lInserted := oSubModel:IsInserted() // Linha nova na GetDados

			//VA060ED_SaidaConsole( cAction + " - " + cID + " - " + cValToChar(lInserted))

			If oSubModel:GetValue("VRK_CANCEL") == "1"
				Return .f.
			EndIf

			If Left(cID,3) == "VRK"
				// Quando o status for diferente de ABERTO, so sera permitida alteração do campo de chassi ou chaint
				If oSubModel:GetValue("STATPED") <> "A"
					If ! Empty( oSubModel:GetValue("VRK_NUMTRA") )
						Return .f.
					EndIf
					If ! cID $ "VRK_CHASSI/VRK_CHAINT"
						Return .f.
					EndIf
				EndIf
			EndIf

			If cID $ "VRK_CODMAR/VRK_GRUMOD/VRK_MODVEI/VRK_SEGMOD/VRK_OPCION/VRK_COREXT/VRK_CORINT/"
				If lInserted
				Else
					Return .f.
				EndIf
			EndIf

			If cID $ "VRK_FABMOD/"
				//VA060ED_SaidaConsole("VRK_FABMOD - " + cValToChar(lInserted))
				If lInserted
				Else
					If oSubModel:GetDataID() <> 0 // Retorna o RECNO do Registro
						If ! Empty(FM_SQL("SELECT VRK_FABMOD FROM " + RetSQLName("VRK") + " WHERE R_E_C_N_O_ = " + cValToChar(oSubModel:GetDataID())))
							Return .f.
						EndIf
					EndIf
				EndIf
			EndIf

			If cID $ "VRL_GERTIT"
				//VA060ED_SaidaConsole("VRL_GERTIT - " + cValToChar(oSubModel:GetValue("STATUS_FIN")))
				If oSubModel:GetValue("STATUS_FIN") <> "SEM_FINANC"
					Return .f.
				EndIf
			EndIf

			If cID $ "SEL_DESVINCULAR"
				//VA060ED_SaidaConsole( cAction + " - " + cID + " - VRK_NUMTRA - " + cValToChar(oSubModel:GetValue("VRK_NUMTRA")) + " - STATPED " + cValToChar(oSubModel:GetValue("STATPED")))
				If ! Empty(oSubModel:GetValue("VRK_NUMTRA"))
					MsgStop(STR0003) // "Não é possivel selecionar um item com atendimento gerado."
					Return .f.
				EndIf
			EndIf

		EndIf

		If cAction == "SETVALUE"

			Do Case
			Case cID == "VRK_CODMAR"
				If Empty(xValue)
					Return .t.
				EndIf

				// Posicionamento da tabela VE1 para funcionamento correto do consulta padrao de grupo de modelo
				VE1->(dbSetOrder(1))
				VE1->(dbSeek(xFilial("VE1") + xValue))
				//

			Case cID == "VRK_OPER"
				If Empty(xValue)
					Return .t.
				EndIf
				If ! ExistCpo("SX5","DJ" + xValue)
					Return .f.
				EndIf

				VA060E0033_TES(oSubModel, "", xValue)

			Case cID == "VRK_CODTES"
				If Empty(xValue)
					Return .t.
				EndIf
				If ! ExistCpo("SF4",xValue)
					Return .f.
				EndIf
				MaFisRef("IT_TES","VA060", xValue )

				// Atualiza campos de valores para o Fiscal rescalcular os impostos...
				// Importante, a sequencia a baixo sera respeitada ...
				Do Case
					Case oSubModel:GetValue("VRK_VALPRE") <> 0
						//oSubModel:SetValue("VRK_VALPRE", oSubModel:GetValue("VRK_VALPRE"))
						oSubModel:SetValue("VRK_VALMOV", VA060E0093_ValorPretendido())
					Case oSubModel:GetValue("VRK_VALMOV") <> 0
						oSubModel:SetValue("VRK_VALMOV", oSubModel:GetValue("VRK_VALMOV"))
					Case oSubModel:GetValue("VRK_VALTAB") <> 0
						oSubModel:SetValue("VRK_VALTAB", oSubModel:GetValue("VRK_VALTAB"))
				EndCase

			Case cID == "VRK_VALTAB"
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALTAB - " + cValToChar(xValue))
				MaFisRef("IT_QUANT" ,"VA060", 1 )
				MaFisRef("IT_PRCUNI","VA060",xValue )
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALTAB - IT_PRCUNI - " + cValToChar(MaFisRet(,"IT_PRCUNI") ) )
				If oSubModel:GetValue("VRK_VALMOV") == 0
					oSubModel:SetValue("VRK_VALMOV", xValue)
				EndIf

			Case cID == "VRK_VALPRE"
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALPRE - " + cValToChar(xValue))

			Case cID == "VRK_VALMOV"
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALMOV - " + cValToChar(xValue))
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALMOV - Item Fiscal - " + cValToChar( n ) )
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALMOV - IT_PRCUNI - " + cValToChar(MaFisRet(,"IT_PRCUNI") ) )
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALMOV - IT_VALMERC - " + cValToChar(MaFisRet(,"IT_VALMERC") ) )

				// Necessario limpar valores de impostos...
				// Forma de tratamento do fiscal foi enviada pela propria equipe do fiscal para tratar de forma paliativa o problema de calculo de PIS3/COFINS3 para zona franca de manaus
				// MaFisRef("IT_VALMERC" ,"VA060", xValue )
				MaFisLoad("IT_VALCF3",0,nItemFiscal)
				MaFisLoad("IT_VALPS3",0,nItemFiscal)
				MaFisLoad("IT_VALCF2",0,nItemFiscal)
				MaFisLoad("IT_VALPS2",0,nItemFiscal)
				MaFisLoad("IT_DESCZF",0,nItemFiscal)
				MaFisLoad("IT_DESCZFCOF",0,nItemFiscal)
				MaFisLoad("IT_DESCZFPIS",0,nItemFiscal)
				
				MaFisLoad("IT_VALMERC",xValue,nItemFiscal)
				MaFisRecal("",nItemFiscal)
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALMOV - IT_PRCUNI - " + cValToChar(MaFisRet(,"IT_PRCUNI") ) )
				//VA060ED_SaidaConsole("SETVALUE - VRK_VALMOV - IT_VALMERC - " + cValToChar(MaFisRet(,"IT_VALMERC") ) )

				VA0600143_FiscalAtuCampoLinhaAtual()
				VA0600033_FiscalAtualizaCabecalho()

				If ( xValue <> xCurrentValue ) .and. oSubModel:GetValue("VV2RECNO") <> 0
					aAtuResumo := {}
					If xCurrentValue <> 0
						AADD(aAtuResumo, { "RESVALTOT" , xCurrentValue * -1 })
					EndIf
					AADD(aAtuResumo, { "RESVALTOT" , xValue })

					VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, aAtuResumo)

				EndIf

			Case cID == "VRK_VALDES"
				MaFisRef("IT_DESCONTO" ,"VA060", xValue )

				VA0600143_FiscalAtuCampoLinhaAtual()
				VA0600033_FiscalAtualizaCabecalho()

			Case cID == "VRK_VALVDA"

				//If ( xValue <> xCurrentValue ) .and. oSubModel:GetValue("VV2RECNO") <> 0
				//	aAtuResumo := {}
				//	If xCurrentValue <> 0
				//		AADD(aAtuResumo, { "RESVALTOT" , xCurrentValue * -1 })
				//	EndIf
				//	AADD(aAtuResumo, { "RESVALTOT" , xValue })
				//
				//	VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, aAtuResumo)
				//
				//EndIf

			Case cID == "VRK_CHASSI"
				If Empty(xValue)
					If oSubModel:GetValue("VV2RECNO") <> 0 .and. ! Empty( xCurrentValue )
						VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, {{"RESQTDEVINC",-1}})
					EndIf
					//VA060ED_SaidaConsole("Ajustando campo VRK_CHAINT")
					oSubModel:LoadValue("VRK_CHAINT",Space(TamSX3("VRK_CHAINT")[1]))
					Return .t.
				EndIf

				If ! VA060E0113_PodeSelecionarVeiculo( oSubModel, 2, xValue, ::_oVeiculo)
					Return .f.
				EndIf

				VA060E0123_LoadDadosVeiculo(oSubModel, 2)

				//VA060ED_SaidaConsole("VRK_CHASSI")
				VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, {{"RESQTDEVINC",1}})

			Case cID == "VRK_CHAINT"
				If Empty(xValue) // Desvinculando o Veiculo do Item do Pedido
					If oSubModel:GetValue("VV2RECNO") <> 0 .and. ! Empty( xCurrentValue )
						VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, {{"RESQTDEVINC",-1}})
					EndIf
					//VA060ED_SaidaConsole("Ajustando campo VRK_CHASSI")
					oSubModel:LoadValue("VRK_CHASSI",Space(TamSX3("VRK_CHASSI")[1]))
					Return .t.
				EndIf

				If ! VA060E0113_PodeSelecionarVeiculo( oSubModel, 1, xValue, ::_oVeiculo)
					Return .f.
				EndIf

				VA060E0123_LoadDadosVeiculo(oSubModel, 1)

				//VA060ED_SaidaConsole("VRK_CHAINT")
				VA0600253_AtualizaResumo(,{oSubModel:GetValue("VV2RECNO"), oSubModel:GetValue("VRK_FABMOD")}, {{"RESQTDEVINC",1}})

			Case cID == "VRK_MODVEI"
				cCodMar := oSubModel:GetValue("VRK_CODMAR")
				cSegMod := Space(TamSX3("VRK_SEGMOD")[1])

				VV2->(dbSetOrder(1))
				If VV2->(msSeek(xFilial("VV2") +  cCodMar + xValue + cSegMod ))
					oSubModel:SetValue("VV2RECNO", VV2->(Recno()))
					oSubModel:SetValue("VRK_DESMOD", VV2->VV2_DESMOD)
				EndIf

				// Existe modelo sem segmento
				If Empty(oSubModel:GetValue("VRK_CHAINT")) .AND. ExistCPO("VV2", cCodMar + xValue + cSegMod )
					//VA060ED_SaidaConsole("Chamando VA060E0023_IniProdutoFiscal - VRK_MODVEI")
					VA060E0023_IniProdutoFiscal(oSubModel, cCodMar, xValue, cSegMod,, oSubModel:GetValue("VRK_FABMOD"))
				EndIf

			Case cID == "VRK_SEGMOD"

				cCodMar := oSubModel:GetValue("VRK_CODMAR")
				cModVei := oSubModel:GetValue("VRK_MODVEI")

				VV2->(dbSetOrder(1))
				If VV2->(msSeek(xFilial("VV2") +  cCodMar + cModVei + xValue ))
					oSubModel:SetValue("VV2RECNO", VV2->(Recno()))
					oSubModel:SetValue("VRK_DESMOD", VV2->VV2_DESMOD)
				Else
					Return .f.
				EndIf

				If Empty(oSubModel:GetValue("VRK_CHAINT"))
					//VA060ED_SaidaConsole("Chamando VA060E0023_IniProdutoFiscal - VRK_SEGMOD")
					VA060E0023_IniProdutoFiscal(oSubModel, cCodMar, cModVei, xValue,, oSubModel:GetValue("VRK_FABMOD"))
				Endif

			Case cID == "VRK_FABMOD"

				If Empty(xValue) .or. FG_ANOMOD(,xValue)
					//VA060ED_SaidaConsole("VRK_FABMOD - " + cValToChar(xCurrentValue) + " - " + cValToChar(xValue))
					VA060E0073_ResumoAtuCompleto(cID, xValue, xCurrentValue, oSubModel)
				EndIf

				//VA060ED_SaidaConsole("Chamando VA060E0023_IniProdutoFiscal - VRK_FABMOD")
				VA060E0023_IniProdutoFiscal(oSubModel, , , , , xValue)

			Case cId == "B1COD"
				VA060E0043_ItemFiscal(oSubModel)

				MaFisRef("IT_PRODUTO","VA060",SB1->B1_COD)

			Case cId == "VV2RECNO"

				//VA060ED_SaidaConsole("VV2RECNO - " + cValToChar(xCurrentValue) + " - " + cValToChar(xValue))
				VA060E0073_ResumoAtuCompleto(cID, xValue, xCurrentValue, oSubModel)

			EndCase

		EndIf

	Case cModelID == "MODEL_VRL"
		If cAction == "DELETE"
			If oSubModel:GetValue("VRL_CANCEL") == "1"
				FMX_HELP("VA060EVDEFERR007",STR0004 , STR0005) // "Não é permitido alteração de registro cancelado." / "Selecione um novo registro para manuteção"
				Return .f.
			EndIf
		EndIf

		If cAction == "CANSETVALUE"
			If oSubModel:GetValue("VRL_CANCEL") == "1"
				Return .f.
			EndIf
		EndIf

		If cAction == "UNDELETE"
			If ::lVRLCANCELProc_Financeiro == .f.
			EndIf
		EndIf

	EndCase

RETURN .t.

METHOD ModelPreVld(oModel, cModelId) CLASS VEIA060EVDEF
	Local oModelVRK
	Do Case
	Case cModelId == "MODEL_VRK"
		Return MaFisFound("NF")
	Case cModelId == "MODEL_VRL"
		oModelVRK := oModel:GetModel("MODEL_VRK")
		If oModelVRK:GetValue("ITEMFISCAL") == 0
			Return .f.
		EndIf
		Return MaFisFound("IT",oModelVRK:GetValue("ITEMFISCAL"))
	EndCase

RETURN .T.

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA060EVDEF
	Local nOperation := oModel:GetOperation()
	Local oModelVRJ := oModel:GetModel("MODEL_VRJ")
	Local oModelVRK := oModel:GetModel("MODEL_VRK")
	Local oModelVRL := oModel:GetModel("MODEL_VRL")
	Local nLinhaAtual
	Local nLinhaFinan
	Local oModelAct

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE

		oModelAct := FWModelActive()

		Begin Transaction
		Begin Sequence

			Private lMSHelpAuto := .t.
			Private lMsErroAuto := .f.

			// Percorre itens do pedido pois o relacionamento do financeiro
			// é por item do pedido
			For nLinhaAtual := 1 to oModelVRK:Length()

				oModelVRK:GoLine(nLinhaAtual)
				If oModelVRK:GetValue("VRK_CANCEL") == "1"
					Loop
				EndIf

				// Criando titulos financeiros do atendimento
				For nLinhaFinan := 1 to oModelVRL:Length()
					oModelVRL:GoLine(nLinhaFinan)

					//VA060ED_SaidaConsole("VA060E0083_CtaReceber - " + cValToChar(oModelVRL:GetValue("VRL_E1VALO")))

					If ! VA060E0083_CtaReceber(nOperation, oModelVRJ, oModelVRK, oModelVRL, @self)
						Break
					EndIF

				Next nLinhaFinan

			Next nLinhaAtual

		Recover
			DisarmTransaction()
			MostraErro()
			Return .f.

		End Sequence
		End Transaction

		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1") + oModelVRJ:GetValue("VRJ_CODCLI") + oModelVRJ:GetValue("VRJ_LOJA") ))

		FWModelActive( oModelAct )

		//
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE
		::lVRKCANCELProc_Item := .t.
		For nLinhaAtual := 1 to oModelVRK:Length()

			If oModelVRK:IsDeleted(nLinhaAtual) .and. ! oModelVRK:IsInserted(nLinhaAtual)
				oModelVRK:GoLine(nLinhaAtual)
				oModelVRK:UnDeleteLine()
				oModelVRK:SetValue("VRK_CANCEL","1")
			EndIf
		Next nLinhaAtual
		::lVRKCANCELProc_Item := .f.

	EndIf

RETURN .T.


METHOD FieldPreVld(oSubModel, cModelID, cAction, cID, xValue) class VEIA060EVDEF
	Local lRet := .t.

	Default cID := ""
	Default xValue := ""

	If cModelID == "MODEL_VRJ"
		If cAction == "SETVALUE"
			Do Case
			Case cID == "VRJ_LOJA"
				If ! MaFisFound("NF") .and. ExistCPO("SA1",FWFldGet("VRJ_CODCLI")+xValue)
					VA0600023_IniFiscal(oSubModel:GetValue("VRJ_CODCLI"), xValue)
				EndIf

			Case cID == "VRJ_TIPOCL"
				//VA060ED_SaidaConsole("POS - FieldPreVld - VRJ_TIPOCL")
				MaFisRef("NF_TPCLIFOR","VA060",xValue)

			Case cID == "VRJ_TPFRET"
				//VA060ED_SaidaConsole("POS - FieldPreVld - VRJ_TPFRET - MaFisRet " + MaFisRet(,"NF_TPFRETE") + " - " + xValue)
				MaFisRef("NF_TPFRETE","VA060",xValue)
				//VA060ED_SaidaConsole("POS - FieldPreVld - VRJ_TPFRET - MaFisRet " + MaFisRet(,"NF_TPFRETE") + " - " + xValue)

			Case cID == "VRJ_DESACE"
				//VA060ED_SaidaConsole("POS - FieldPreVld - VRJ_DESACE - MaFisRet " + cValToChar(MaFisRet(,"NF_DESPESA")) + " - " + cValToChar(xValue))
				MaFisRef("NF_DESPESA","VA060",xValue)
				//VA060ED_SaidaConsole("POS - FieldPreVld - VRJ_DESACE - MaFisRet " + cValToChar(MaFisRet(,"NF_DESPESA")) + " - " + cValToChar(xValue))

			EndCase
		EndIf
	EndIf

RETURN lRet

Static Function VA060E0013_PesqVV1(oSubModel, nIndice, cChave)
	VV1->(dbSetOrder(nIndice))
	If !VV1->(dbSeek(xFilial("VV1") + cChave))
		HELP(" ",1,"REGNOIS",,cChave,4,1)
		Return .f.
	EndIf

	// Se possuir modelo e segmento informado, verifica se o veiculo é do mesmo modelo / segmento
	If !Empty(oSubModel:GetValue("VRK_MODVEI"))
		If VV1->VV1_MODVEI <> oSubModel:GetValue("VRK_MODVEI") .or. VV1->VV1_SEGMOD <> oSubModel:GetValue("VRK_SEGMOD")
			FMX_HELP("VA060EVDEFERR003",STR0006 , STR0007) // "Veículo informado é diferente do modelo/segmento informado no item do pedido.","Selecionar um veículo do mesmo modelo/segmento."
			Return .f.
		EndIf
	EndIf
	//
Return .t.

Static Function VA060E0123_LoadDadosVeiculo(oSubModel, nIndice)

	FGX_VV2()

	oSubModel:LoadValue("VRK_CODMAR", VV1->VV1_CODMAR)
	oSubModel:LoadValue("VRK_GRUMOD", VV2->VV2_GRUMOD)

	If oSubModel:GetValue("VV2RECNO") == 0
		oSubModel:LoadValue("VRK_FABMOD", VV1->VV1_FABMOD)
		If Empty(VV1->VV1_SEGMOD)
			oSubModel:SetValue("VRK_MODVEI", VV1->VV1_MODVEI)
		Else
			oSubModel:LoadValue("VRK_MODVEI", VV1->VV1_MODVEI)
			oSubModel:SetValue("VRK_SEGMOD", VV1->VV1_SEGMOD)
		EndIf
	Else
		If oSubModel:GetValue("VRK_FABMOD") <> VV1->VV1_FABMOD
			oSubModel:SetValue("VRK_FABMOD", VV1->VV1_FABMOD) // Atualiza o Resumo ...
		EndIf
	EndIf

	// O chassi so pode ser atualizado neste ponto para nao dar problema na Atualizacao do Resumo
	If nIndice == 1
		oSubModel:LoadValue("VRK_CHASSI", VV1->VV1_CHASSI)
	Else
		oSubModel:LoadValue("VRK_CHAINT", VV1->VV1_CHAINT)
	EndIf

	//VA060ED_SaidaConsole("Chamando VA060E0023_IniProdutoFiscal - PesqVV1")
	VA060E0023_IniProdutoFiscal(oSubModel, VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD, VV1->VV1_CHAINT, VV1->VV1_FABMOD)

	oSubModel:SetValue( "VRK_CENCUS" , IIf( Empty(VV1->VV1_CC     ), SB1->B1_CC     , VV1->VV1_CC     ))
	oSubModel:SetValue( "VRK_CONTA"  , IIf( Empty(VV1->VV1_CONTA  ), SB1->B1_CONTA  , VV1->VV1_CONTA  ))
	oSubModel:SetValue( "VRK_ITEMCT" , IIf( Empty(VV1->VV1_ITEMCC ), SB1->B1_ITEMCC , VV1->VV1_ITEMCC ))
	oSubModel:SetValue( "VRK_CLVL"   , IIf( Empty(VV1->VV1_CLVL   ), SB1->B1_CLVL   , VV1->VV1_CLVL   ))

Return .t.

/*/{Protheus.doc} VA060E0023_IniProdutoFiscal

@author Rubens
@since 31/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oSubModel, object, descricao
@param cCodMar, characters, descricao
@param cModVei, characters, descricao
@param cSegMod, characters, descricao
@param cChaInt, characters, descricao
@type function
/*/
Static Function VA060E0023_IniProdutoFiscal(oSubModel, cCodMar, cModVei, cSegMod, cChaInt, cAnoFab)

	Local nValorTab
	Local nValorMov
	Local nValorPre
	Local lContinua := .f.
	Local nItemFiscal
	Local lItemNovo := .f.

	Local cTESAux
	Local cOperAux

	Default cCodMar := oSubModel:GetValue("VRK_CODMAR")
	Default cModVei := oSubModel:GetValue("VRK_MODVEI")
	Default cSegMod := oSubModel:GetValue("VRK_SEGMOD")

	Default cChaInt := ""
	Default cAnoFab := ""

	//VA060ED_SaidaConsole("VA060E0023_IniProdutoFiscal - INICIO PROCESSAMENTO")

	If Empty(cChaInt)
		lContinua := FGX_VV2SB1( cCodMar , cModVei , cSegMod)
		//VA060ED_SaidaConsole("                           " + " - MODELO - [" + AllTrim(cCodMar) + "] - [" + AllTrim(cModVei) + "] - [" + AllTrim(cSegMod) + "]")
	Else
		lContinua := FGX_VV1SB1("CHAINT", cChaInt )
		//VA060ED_SaidaConsole("                           " + " - CHAINT - " + cChaInt )
	EndIf

	If lContinua

		//VA060ED_SaidaConsole("                           " + " - SB1 - [" + SB1->B1_COD + "]")

		oSubModel:LoadValue("B1COD", SB1->B1_COD)
		nItemFiscal := VA060E0043_ItemFiscal(oSubModel)
		lItemNovo := (MaFisFound("IT", nItemFiscal) == .f.)

		nValorTab := oSubModel:GetValue("VRK_VALTAB")
		nValorMov := oSubModel:GetValue("VRK_VALMOV")
		nValorPre := oSubModel:GetValue("VRK_VALPRE")

		If nValorTab == 0
			nValorTab := FGX_VLRSUGV(;
				cChaInt,;  // _cChaInt
				cCodMar ,;  // _cCodMar
				cModVei ,;  // _cModVei
				cSegMod,;  // _cSegMod
				" ",;  // _cCorVei
				.t.,;  // _lMinCom
				"",;  // _cCodCli
				"",;  // _cLojCli
				cAnoFab )  // _cAnoFab

			If nValorMov == 0
				nValorMov := nValorTab
			EndIf

			If ! lItemNovo
				oSubModel:LoadValue("VRK_VALTAB", nValorTab)
			EndIf

		EndIf

		//VA060ED_SaidaConsole("                           " + " - ItemFiscal - " + cValToChar(oSubModel:GetValue("ITEMFISCAL")) )
		//VA060ED_SaidaConsole("                           " + " - Novo - " + cValToChar(lItemNovo) )

		If lItemNovo
			Pergunte("VEIA060",.f.,,,,.f.)
			cOperPad := MV_PAR01
			cTESPad  := MV_PAR02

			FGX_VV2SB1(cCodMar, cModVei, cSegMod)
			oSubModel:LoadValue("B1COD", SB1->B1_COD)

			VA0600193_RetTESOperPadrao(oSubModel, @cTESAux, @cOperAux, FWFldGet("VRJ_CODCLI"), FWFldGet("VRJ_LOJA"), cOperPad, cTESPad, SB1->B1_COD)

			VA0600073_FiscalAdProduto(nItemFiscal, nValorTab, cTESAux, SB1->B1_COD, .T. )
			oSubModel:LoadValue("ITEMFISCAL", nItemFiscal)

			oSubModel:LoadValue("VRK_CODTES", cTESAux)
			If !Empty(cOperAux)
				oSubModel:LoadValue("VRK_OPER", cOperAux )
			EndIf

			oSubModel:SetValue("VRK_VALTAB", nValorTab)
			//VA060ED_SaidaConsole("                           " + " - Valor Movimento - " + cValToChar(FWFldGet("VRK_VALMOV")) )

		Else
			If MaFisRet(nItemFiscal,"IT_PRODUTO") <> SB1->B1_COD
				MaFisRef("IT_PRODUTO" ,"VA060",SB1->B1_COD)
				MaFisRef("IT_QUANT"   ,"VA060", 1 )
			EndIf

			If Empty( oSubModel:GetValue("VRK_CODTES") )
				VA060E0033_TES(oSubModel, SB1->B1_TS, ,"LOADVALUE")
			EndIf

			If nValorTab <> 0 .and. MaFisRet(nItemFiscal,"IT_PRCUNI") <> nValorTab
				//VA060ED_SaidaConsole("                           " + " - Setando Valor Tabela" )
				oSubModel:SetValue("VRK_VALTAB", nValorTab)
				//VA060ED_SaidaConsole("                           " + " - nValorTab - " + cValToChar(nValorTab) )
			EndIf

			If nValorPre <> 0
				oSubModel:SetValue("VRK_VALPRE", nValorPre )
			Else
				If (nValorMov <> 0 .and. MaFisRet(nItemFiscal,"IT_VALMERC") <> nValorMov)
					//VA060ED_SaidaConsole("                           " + " - VRK_VALMOV - " + cValToChar(nValorMov) )
					oSubModel:SetValue("VRK_VALMOV", nValorMov )
				EndIf
			EndIf

			//VA060ED_SaidaConsole("                           " + " - IT_PRCUNI - " + cValToChar(MaFisRet(nItemFiscal,"IT_PRCUNI") ) )
			//VA060ED_SaidaConsole("                           " + " - IT_VALMERC - " + cValToChar(MaFisRet(nItemFiscal,"IT_VALMERC") ) )

		EndIf

	EndIf

	// Verificar o cliente da negociacao do veiculo...
	// Se estiver vazio inicializa a GRID de negociacao para buscar o cliente informado no pedido
	If Empty(FWFldGet("VRL_E1CLIE"))
		oSubModel:GetModel():GetModel("MODEL_VRL"):ClearData(.t.,.t.)
	EndIf

	//VA060ED_SaidaConsole("VA060E0023_IniProdutoFiscal - FIM PROCESSAMENTO")

Return .t.


/*/{Protheus.doc} VA060E0033_TES
Inicializa código do TES
@author Rubens
@since 31/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oSubModel, object, descricao
@param cTESSB1, characters, descricao
@type function
/*/
Static Function VA060E0033_TES(oSubModel, cTESSB1, cOperacao, cSetLoad)
	Local cTESAux := ""

	Default cTESSB1 := ""
	Default cOperacao := oSubModel:GetValue("VRK_OPER")
	Default cSetLoad := "SETVALUE"

	If ! Empty(cOperacao)
		cTESAux := MaTesInt(2,cOperacao,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"),"C",SB1->B1_COD)
	Else
		cTESAux := oSubModel:GetValue("VRK_CODTES")
		If Empty(cTESAux)
			cTESAux := cTESSB1
		EndIf
	EndIf

	If Empty(cTESAux)
		Return .t.
	Endif

	SF4->(dbSetOrder(1))
	If ! SF4->(msSeek(FWxFilial("SF4") + cTESAux))
		Help(" ",1,"REGNOIS",,RetTitle("F4_CODIGO") + ": " + cTESAux ,4,1)
		Return .f.
	EndIf

	If SF4->F4_TIPO <> "S"
		FMX_HELP("VA060EVDEFERR001",STR0009) // "Tipo de Operação não está relacionado a um TES de Saída."
		Return .f.
	EndIf

	//VA060ED_SaidaConsole("Setando Codigo da TES - " + cTESAux)
	Do Case
	Case cSetLoad == "SETVALUE"
		oSubModel:SetValue("VRK_CODTES", cTESAux)
	Case cSetLoad == "LOADVALUE"
		oSubModel:LoadValue("VRK_CODTES", cTESAux)
	EndCase

Return .t.

/*/{Protheus.doc} VA060E0043_ItemFiscal
Inicializa item do fiscal

@author Rubens
@since 31/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function VA060E0043_ItemFiscal(oModel)
	If oModel:GetValue("ITEMFISCAL") == 0
		oModel:LoadValue("ITEMFISCAL", VA0600103_ProximoItemFiscal())
	EndIf
	N := oModel:GetValue("ITEMFISCAL")
Return N

/*/{Protheus.doc} VA060E0053_FormulaCalcReverso
Retorna para calulo reverso do valor do veiculo
@author Rubens
@since 02/01/2019
@version 1.0
@return cForm121, characters, Formula para calculo reverso
@param oSubModel, object, descricao
@type function
/*/
Static Function VA060E0053_FormulaCalcReverso(cCodMar, cModVei, cSegMod)

	Local cForm121 := ""

	Default cCodMar := FWFldGet("VRK_CODMAR")
	Default cModVei := FWFldGet("VRK_MODVEI")
	Default cSegMod := FWFldGet("VRK_SEGMOD")

	If VV2->(FieldPos("VV2_FORREV")) > 0

		////VA060ED_SaidaConsole("VA060E0053_FormulaCalcReverso - [" + AllTrim(oSubModel:GetValue("VRK_CODMAR")) + "] - [" + AllTrim(oSubModel:GetValue("VRK_MODVEI")) + "] - [" + AllTrim(oSubModel:GetValue("VRK_SEGMOD")) + "]" )
		//VA060ED_SaidaConsole("VA060E0053_FormulaCalcReverso - [" + AllTrim(cCodMar) + "] - [" + AllTrim(cModVei) + "] - [" + AllTrim(cSegMod) + "]")

		FGX_VV2( cCodMar, cModVei, cSegMod )
		cForm121 := VV2->VV2_FORREV
	EndIf

	If Empty(cForm121)
		cForm121 := GetNewPar("MV_MIL0121","")
	EndIf
	//VA060ED_SaidaConsole("VA060E0053_FormulaCalcReverso - Formula " + cForm121 )

Return cForm121

Static Function VA060E0113_PodeSelecionarVeiculo(oSubModel, nIndice, cChave, oVeiculo)

	Local nRecVV1

	If VA060E0063_VeiculoJaSelecionado(oSubModel, nIndice, cChave)
		Return .f.
	EndIf

	If oVeiculo:emPedidoDeVenda( IIf( nIndice == 1, "CHAINT", "CHASSI" ), cChave, oSubModel:GetValue("VRK_PEDIDO"), oSubModel:GetValue("VRK_ITEPED") )
		FMX_HELP("VA060EVDEFERR004",STR0009, STR0010) // "Veículo já relacionado em outro pedido." - "Selecione um outro veículo."
		Return .f.
	EndIf

	If oVeiculo:emAtendimento( IIf( nIndice == 1, "CHAINT", "CHASSI" ), cChave )
		FMX_HELP("VA060EVDEFERR009",STR0011, STR0010) // "Veículo já relacionado em outro atendimento." - "Selecione um outro veículo.")
		Return .f.
	EndIf

	If ! VA060E0013_PesqVV1( oSubModel, nIndice, cChave )
		Return .f.
	EndIf

	If ! ( VV1->VV1_SITVEI $ "0/2/3/4/8" )
		FMX_HELP("VA060EVDEFERR010",STR0012 + CRLF + CRLF + RetTitle("VV1_SITVEI") + " - " + X3CBOXDESC("VV1_SITVEI", VV1->VV1_SITVEI),STR0010) // "Veículo não pode ser relacionado no pedido." - "Selecione um outro veículo."
		Return .f.
	EndIf

	nRecVV1 := VV1->(RecNo())

	// nTp     ( 1=Digitacao / 2=Finalizacao )
	// cFilVei ( Filial de Pesquisa do Veiculo )
	// cChaInt ( Chassi Interno do Veiculo )
	// cCodTes ( Codigo do TES )
	// cNumAte ( Numero do Atendimento )
	//VA060ED_SaidaConsole("Chamando VEIXX012 - " + VV1->VV1_CHASSI + " - " + oSubModel:GetValue("VRK_CODTES") )
	If ! VEIXX012(2,xFilial("VV1"),VV1->VV1_CHAINT,oSubModel:GetValue("VRK_CODTES"),"_", .t. , , oVeiculo)
		Return .f.
	EndIf

	VV1->(dbGoTo(nRecVV1))

Return .t.

Static Function VA060E0063_VeiculoJaSelecionado(oSubModel, nIndice, cChave)
	Local lSeek
	If nIndice == 1
		lSeek := oSubModel:SeekLine({{ "VRK_CHAINT" , cChave },{"VRK_CANCEL","0"}},.f.,.f.)
	Else
		lSeek := oSubModel:SeekLine({{ "VRK_CHASSI" , cChave },{"VRK_CANCEL","0"}},.f.,.f.)
	EndIf
	If lSeek
		FMX_HELP("VA060EVDEFERR005",STR0013,STR0010) // - "Selecione um outro veículo."
	EndIf
Return lSeek

Static Function VA060E0073_ResumoAtuCompleto(cID, xValue, xCurrentValue, oSubModel)
	Local	aAtuResumo := {}
	Local lDelResumo := .f.
	Local aChaveAntiga := {} // [1] - VV2RECNO / [2] - FabMod
	Local aChaveNova   := {} // [1] - VV2RECNO / [2] - FabMod

	Do Case
	Case cID == "VV2RECNO"
		aChaveNova := { xValue , oSubModel:GetValue("VRK_FABMOD") }
		If xCurrentValue <> 0
			aChaveAntiga := { xCurrentValue , oSubModel:GetValue("VRK_FABMOD") }
		EndIf

	Case cID == "VRK_FABMOD"
		aChaveNova := { oSubModel:GetValue("VV2RECNO"), xValue }
		aChaveAntiga := { oSubModel:GetValue("VV2RECNO"), xCurrentValue }

	EndCase

	If lDelResumo == .f. .and. Len(aChaveAntiga) <> 0
		aAtuResumo := {}
		If oSubModel:GetValue("VRK_VALVDA") <> 0
			AADD(aAtuResumo, { "RESVALTOT" , oSubModel:GetValue("VRK_VALVDA") * -1 })
			AADD(aAtuResumo, { "RESQTDEVEND" , -1 })
			If ! Empty( oSubModel:GetValue("VRK_CHAINT") )
				AADD(aAtuResumo, { "RESQTDEVINC" , -1 })
			EndIf
		EndIf
		VA0600253_AtualizaResumo(,aChaveAntiga, aAtuResumo)
	EndIf

	VA0600233_AddResumo(, oSubModel, aChaveNova)

	aAtuResumo := {}
	If oSubModel:GetValue("VRK_VALVDA") <> 0
		AADD(aAtuResumo, { "RESVALTOT" , oSubModel:GetValue("VRK_VALVDA") })
	EndIf
	If ! Empty( oSubModel:GetValue("VRK_CHAINT") )
		AADD(aAtuResumo, { "RESQTDEVINC" , 1 })
	EndIf
	VA0600253_AtualizaResumo(,aChaveNova, aAtuResumo)

Return

Static Function VA060E0083_CtaReceber(nOperation, oModelVRJ, oModelVRK, oModelVRL, oAuxSelf)
	Local aFINA040 := {}
	Local cDMSPrefOri:= GetNewPar("MV_PREFVEI","VEI")
	Local nOperFINA := 3
	Local lIntegra := .t.
	Local lDelItemVRL := .f.
	Local lRetPEFin := .t.
	Local lCancTit := .f.

	//VA060ED_SaidaConsole(oModelVRL:GetValue('VRL_E1PREF') + " - " + oModelVRL:GetValue('VRL_E1NUM') + " - " + oModelVRL:GetValue('VRL_E1PARC'))

	If oModelVRL:GetValue('VRL_E1VALO') == 0
		Return .t.
	EndIf

	If oModelVRL:GetValue('VRL_CANCEL') == "1"
		Return .t.
	EndIf

	If oModelVRL:IsDeleted() .or. oModelVRJ:GetValue("VRJ_STATUS") == "C" .or. oModelVRK:IsDeleted() .or. nOperation == MODEL_OPERATION_DELETE
		lCancTit := .t.
		lDelItemVRL := ! oModelVRL:IsInserted()
	EndIf

	SA1->(dbSetOrder(1))
	SA1->(MsSeek( xFilial("SA1") + oModelVRL:GetValue("VRL_E1CLIE") + oModelVRL:GetValue("VRL_E1LOJA")))

	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(oModelVRL:GetValue('VRL_E1FILI') + oModelVRL:GetValue('VRL_E1PREF') + oModelVRL:GetValue('VRL_E1NUM') + oModelVRL:GetValue('VRL_E1PARC') + oModelVRL:GetValue('VRL_E1TIPO') ))

		If lCancTit

			If oModelVRL:GetValue("STATUS_FIN") == "SEM_FINANC"
			Else
				nOperFINA := 5
				lIntegra := .t.
				aFINA040 := {;
					{"E1_PREFIXO" , SE1->E1_PREFIXO , NIL } ,;
					{"E1_NUM"     , SE1->E1_NUM     , NIL } ,;
					{"E1_PARCELA" , SE1->E1_PARCELA , NIL } ,;
					{"E1_TIPO"    , SE1->E1_TIPO    , NIL } ,;
					{"E1_NATUREZ" , SE1->E1_NATUREZ , NIL } ,;
					{"E1_CLIENTE" , SE1->E1_CLIENTE , NIL } ,;
					{"E1_LOJA"    , SE1->E1_LOJA    , NIL } }
			EndIf

		Else

			nOperFINA := 4
			lIntegra := .f.

			If oModelVRL:GetValue('VRL_E1NATU') <> SE1->E1_NATUREZ ;
				.or. oModelVRL:GetValue('VRL_E1DTEM') <> SE1->E1_EMISSAO ;
				.or. oModelVRL:GetValue('VRL_E1DTVE') <> SE1->E1_VENCTO  ;
				.or. oModelVRL:GetValue('VRL_E1DTVR') <> SE1->E1_VENCREA ;
				.or. oModelVRL:GetValue('VRL_E1VALO') <> SE1->E1_VALOR   ;
				.or. oModelVRJ:GetValue('VRJ_CODVEN') <> SE1->E1_VEND1

				lIntegra := .t.

			EndIf

			If ! lIntegra .and. ExistBlock("VA060CRINT")
				lIntegra := ExecBlock("VA060CRINT",.f.,.f.,{ oModelVRL })
			EndIf

		EndIf
	Else
		If oModelVRL:GetValue("VRL_GERTIT") == "0" .or. lCancTit
			//VA060ED_SaidaConsole("VRL configurado para não gerar titutlo - " + cValToChar(oModelVRL:GetValue("VRL_GERTIT")) + " - " + oModelVRL:GetValue('VRL_E1PARC'))
			lIntegra := .f.
		EndIf
	EndIf

	If lIntegra
		// Na operacao de exclusao, a matriz aFINA040 já esta preenchida com os valores que devem ser enviados na integracao com FINA040
		If nOperFINA <> 5
			aFINA040 := {;
				{"E1_PREFIXO" , oModelVRL:GetValue('VRL_E1PREF') , NIL } ,;
				{"E1_NUM"     , oModelVRL:GetValue('VRL_E1NUM')  , NIL } ,;
				{"E1_PARCELA" , oModelVRL:GetValue('VRL_E1PARC') , NIL } ,;
				{"E1_TIPO"    , oModelVRL:GetValue('VRL_E1TIPO') , NIL } ,;
				{"E1_NATUREZ" , oModelVRL:GetValue('VRL_E1NATU') , NIL } ,;
				{"E1_CLIENTE" , oModelVRL:GetValue('VRL_E1CLIE') , NIL } ,;
				{"E1_LOJA"    , oModelVRL:GetValue('VRL_E1LOJA') , NIL } ,;
				{"E1_EMISSAO" , oModelVRL:GetValue('VRL_E1DTEM') , NIL } ,;
				{"E1_VENCTO"  , oModelVRL:GetValue('VRL_E1DTVE') , NIL } ,;
				{"E1_VENCREA" , oModelVRL:GetValue('VRL_E1DTVR') , NIL } ,;
				{"E1_VALOR"   , oModelVRL:GetValue('VRL_E1VALO') , NIL } ,;
				{"E1_PREFORI" , cDMSPrefOri                      , NIL } ,;
				{"E1_ORIGEM"  , "MATA460"                        , NIL } ,;
				{"E1_VEND1"   , oModelVRJ:GetValue('VRJ_CODVEN') , NIL } }

			If ! Empty( oModelVRL:GetValue("VRL_CENCUS") )
				AADD( aFINA040 , {"E1_CCUSTO" , oModelVRL:GetValue("VRL_CENCUS") , NIL } )
			EndIf
			If ! Empty( oModelVRL:GetValue("VRL_ITEMCT") )
				AADD( aFINA040 , { "E1_ITEMCTA", oModelVRL:GetValue("VRL_ITEMCT") , NIL } )
			EndIf
			If ! Empty( oModelVRL:GetValue("VRL_CLVL") )
				AADD( aFINA040 , { "E1_CLVL", oModelVRL:GetValue("VRL_CLVL") , NIL } )
			EndIf

			If ExistBlock("VA060CR")
				aFINA040 := ExecBlock("VA060CR",.f.,.f.,{ oModelVRL, aClone(aFINA040) })
			EndIf

		EndIf

		If ExistBlock("VA060FIN")
			lRetPEFin := ExecBlock("VA060FIN",.f.,.f.,{ nOperFINA, aClone(aFINA040) })
		EndIf

		If lRetPEFin
			MSExecAuto({|x,y| FINA040(x,y)},aFINA040, nOperFINA)

			If lMsErroAuto
				MostraErro()
				Return .f.
			EndIf
		EndIf

	EndIf

	If lDelItemVRL
		oAuxSelf:lVRLCANCELProc_Financeiro := .t.
		oModelVRL:UnDeleteLine()
		oModelVRL:SetValue("VRL_CANCEL","1")
		oAuxSelf:lVRLCANCELProc_Financeiro := .f.
	EndIf

Return .T.



/*/{Protheus.doc} SaidaConsole
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
//Function VA060ED_SaidaConsole(Mensagem)
//
//	If lDebug
//		Conout("| VEIA060EVDEF | " + Time() + " | " + Mensagem)
//		//AADD( aSaidaConsole, {"| VEIA060EVDEF | " + Time() + " | " + Mensagem})
//	EndIf
//
//	//VA060_SaidaConsole(Mensagem, "VEIA060EVDEF")
//
//Return

Function VA060E0093_ValorPretendido(cCodMar, cModVei, cSegMod, nValTab, nValPre)

	Default cCodMar := FWFldGet("VRK_CODMAR")
	Default cModVei := FWFldGet("VRK_MODVEI")
	Default cSegMod := FWFldGet("VRK_SEGMOD")
	Default nValTab := FWFldGet("VRK_VALTAB")
	Default nValPre := FWFldGet("VRK_VALPRE")

	//VA060ED_SaidaConsole("VA060E0093_ValorPretendido - [" + AllTrim(cCodMar) + "] - [" + AllTrim(cModVei) + "] - [" + AllTrim(cSegMod) + "]")

	// Se o usuario zerar o valore pretendido, volta o valor de tabela...
	If nValPre == 0
		nValMovimento := nValTab
	Else
		cForm121 := VA060E0053_FormulaCalcReverso(cCodMar, cModVei, cSegMod)

		//VA060ED_SaidaConsole("VA060E0093_ValorPretendido - Valor Pretendido - Formula - " + cForm121 )

		If Empty(cForm121)
			nValMovimento := nValPre
		Else
			//VA060ED_SaidaConsole("VA060E0093_ValorPretendido - Ajusta fiscal com o valor Pretendido - " + cValToChar(nValPre) )
			nValMovimento := nValPre

			nValorPre := nValPre // Valor utilizada na formula...
			nValorMov := FG_FORMULA(cForm121)

			If nValorMov <> nValPre
				//VA060ED_SaidaConsole("VA060E0093_ValorPretendido - Ajusta Valor Unitario com o Valor Calculado" )
				//VA060ED_SaidaConsole("VA060E0093_ValorPretendido - VALOR PRETENDIDO - " + cValToChar(nValorMov) )
				nValMovimento := nValorMov
			EndIf
		EndIf
	EndIf

Return nValMovimento

Function VA060E0103_procItensPedido(oModel)

	Local nOperation := oModel:GetOperation()
	Local oModelVRJ := oModel:GetModel("MODEL_VRJ")
	Local oModelVRK := oModel:GetModel("MODEL_VRK")

	Local cMVMIL0010 := GetNewPar("MV_MIL0010","0")
	Local cAuxGruVei := PadR( AllTrim(GetMv("MV_GRUVEI")) , TamSx3("B1_GRUPO")[1] )

	Local nLinhaAtual := 1
	Local nLinhaTotal := oModelVRK:Length()
	Local nItemFiscal := 0

	Local lAddFiscal := (nOperation == MODEL_OPERATION_UPDATE)
	Local lRecalcFiscal := .f.
	Local lFoundSB1 := .f.

	//If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_DELETE .or. nOperation == MODEL_OPERATION_VIEW
	//	Return
	//EndIf

	VV2->(dbSetOrder(1))

	While nLinhaAtual <= nLinhaTotal

		//VA060ED_SaidaConsole("VA060E0103_procItensPedido - " + cValToChar(nLinhaAtual))

		If oModelVRK:GetValue("VRK_CANCEL", nLinhaAtual) == "1"
			nLinhaAtual++
			Loop
		EndIf

		oModelVRK:GoLine(nLinhaAtual)

		cCodMar := oModelVRK:GetValue( "VRK_CODMAR" )
		cModVei := oModelVRK:GetValue( "VRK_MODVEI" )
		cSegMod := oModelVRK:GetValue( "VRK_SEGMOD" )

		oModelVRK:LoadValue("STATPED", oModelVRJ:GetValue("VRJ_STATUS"))

		lFoundSB1 := .f.
		If ! Empty(oModelVRK:GetValue("VRK_CHAINT"))
			If FGX_VV1SB1("CHAINT", oModelVRK:GetValue("VRK_CHAINT") , cMVMIL0010 , cAuxGruVei )
				oModelVRK:LoadValue("B1COD", SB1->B1_COD)
				lFoundSB1 := .t.
			EndIf
		EndIf
		If ! lFoundSB1
			If FGX_VV2SB1( cCodMar , cModVei , cSegMod)
				oModelVRK:LoadValue("B1COD", SB1->B1_COD)
				lFoundSB1 := .t.
			EndIf
		EndIf

		If VV2->(MsSeek(xFilial("VV2") + cCodMar + cModVei + cSegMod))
			oModelVRK:LoadValue("VV2RECNO", VV2->(Recno()))
		EndIf

		If lFoundSB1 .and. lAddFiscal
			// Se for ultima linha, ou penultinha linha e a ultima linha estiver cancelada ...
			If nLinhaAtual == nLinhaTotal .or. (nLinhaAtual + 1 == nLinhaTotal .and. oModelVRK:GetValue("VRK_CANCEL",nLinhaAtual + 1) == "1")
				lRecalcFiscal := .t.
			EndIf

			nItemFiscal++

			VA0600073_FiscalAdProduto(;
				nItemFiscal,; // nItemFiscal
				oModelVRK:GetValue( "VRK_VALTAB" ),; // nValorVeic
				oModelVRK:GetValue( "VRK_CODTES" ),; // cTES
				SB1->B1_COD,; // cB1Cod
				lRecalcFiscal ,;
				oModelVRK:GetValue( "VRK_VALMOV" ) ) // nValorMov

			oModelVRK:LoadValue("ITEMFISCAL", nItemFiscal)

		EndIf

		nLinhaAtual++

	End

	If lAddFiscal
		VA0600033_FiscalAtualizaCabecalho()
	EndIf

Return