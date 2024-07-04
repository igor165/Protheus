#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'VEIA144.CH'

CLASS VEIA144EVF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD GridLinePreVld()

ENDCLASS


METHOD New() CLASS VEIA144EVF

RETURN .T.

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA144EVF

	Local lRet := .t.
	Local aVetCb	:= {}
	Local aVetIt	:= {}
	Local oMGridBonus := oModel:GetModel("BONUSLIBERADO")
	Local oMGridArq := oModel:GetModel("ARQUIVORETORNO")
	Local nQtdLines  := oMGridBonus:Length()
	Local nX
	Local lRetSel := .F.

	If oModel:GetValue("CAMPOSTOTAL","CPOTOTBON") == 0 .or. oModel:GetValue("CAMPOSTOTAL","CPOTOTRET") == 0 // Nao selecionou o Bonus
		MsgInfo( STR0017 , STR0018 ) //"Necessario selecionar os registros!" / "Atenção"
		lRet := .f.
	Else
		lRet := .f.
		If oModel:GetValue("CAMPOSTOTAL","CPOTOTDIV") == 0 // Nao ha divergencia
			lRet := .t.
		Else // com divergencia entre Retorno e Bonus selecionados
			If MsgYesNo( STR0019 , STR0018 ) // Ha divergencia entre o Retorno e os Bonus selecionados. NF sera gerada no valor total dos Bonus selecionados. Deseja continuar? / Atencao
				lRet := .t.
			EndIf
		EndIf
	EndIf

	If lRet

		aVetCb := {	oModel:GetValue("INFORMACAONF","C5CLIENTE"),;
					oModel:GetValue("INFORMACAONF","C5LOJACLI"),;
					oModel:GetValue("INFORMACAONF","C5VEND1"),;
					oModel:GetValue("INFORMACAONF","C5CONDPAG"),;
					oModel:GetValue("INFORMACAONF","C5NATUREZ"),;
					oModel:GetValue("INFORMACAONF","C5BANCO"),;
					oModel:GetValue("INFORMACAONF","PAROBSNF"),;
					oModel:GetValue("INFORMACAONF","C5MENNOTA"),;
					oModel:GetValue("INFORMACAONF","C5MENPAD") }

		aAdd( aVetIt ,{ oModel:GetValue("INFORMACAONF","CPOCODPRD"),;
						oModel:GetValue("INFORMACAONF","PARVALOR")})

		aNF := FMX_GERNFS(	aVetCb,;
							aVetIt,;
							.t.,;
							GetNewPar("MV_PREFVEI","VEI"),;
							,;
							oModel:GetValue("INFORMACAONF","C5TIPOCLI"),;
							oModel:GetValue("INFORMACAONF","C5INDPRES"),;
							oModel:GetValue("INFORMACAONF","C5ESTPRES"),;
							oModel:GetValue("INFORMACAONF","C5MUNPRES"))

		For nX := 1 to nQtdLines

			oMGridBonus:GoLine(nX)

			If oMGridBonus:GetValue("CPOSELBON")

				DbSelectArea("VQ1")
				VQ1->(DbGoTo(oMGridBonus:GetValue("RECNOVQ1")))

				RecLock("VQ1",.f.)

					VQ1->VQ1_FILNFI := xFilial("SF2")
					VQ1->VQ1_NUMNFI := aNF[1]
					VQ1->VQ1_SERNFI := aNF[2]

					if FieldPos("VQ1_SDOC") > 0
						VQ1->VQ1_SDOC := FGX_UFSNF(aNF[2])
					Endif

					VQ1->VQ1_DATNFI := dDataBase
					VQ1->VQ1_STATUS := "3" // NF Gerada

					lRetSel := oMGridArq:SeekLine({{"CPOSELRET", .T.}})
					if lRetSel
						VQ1->VQ1_RETUID := oModel:GetValue("ARQUIVORETORNO","VQ4RETUID")
					Endif

					MSMM(VQ1->VQ1_OBSNFC,TamSx3("VQ1_OBSNFM")[1],,oModel:GetValue("INFORMACAONF","PAROBSNF"),1,,,"VQ1","VQ1_OBSNFC")

				MsUnLock()

			EndIf

		Next nX

	EndIf

RETURN lRet

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA144EVF

	Local oModel:= FWModelActive()
	Local oView := FWViewActive()

	If cAction == "SETVALUE"
		If cModelID == "BONUSLIBERADO"

			If cId == "CPOSELBON"
				If xValue
					nValBon += oModel:GetModel("BONUSLIBERADO" ):GetValue("VQ1VLRTOT")
				Else
					nValBon -= oModel:GetModel("BONUSLIBERADO" ):GetValue("VQ1VLRTOT")
				EndIF
				oModel:SetValue("CAMPOSTOTAL","CPOTOTBON",nValBon)
			EndIf
			oModel:SetValue("INFORMACAONF","PARVALOR",nValBon)

		ElseIf cModelID == "ARQUIVORETORNO"

			If cId == "CPOSELRET"
				If xValue
					lSeek := oSubModel:SeekLine({;
										{ "CPOSELRET" , .t. };
									})
					If lSeek
						oSubModel:LoadValue("CPOSELRET", .f. )
					EndIF

					oSubModel:GoLine(nLine)

					nValRet := oModel:GetModel("ARQUIVORETORNO"):GetValue("VQ4VLRTOT")
				Else
					nValRet := 0
				EndIf

				oModel:SetValue("CAMPOSTOTAL","CPOTOTRET",nValRet)

				SA1->(DbSetOrder(3))
				If SA1->(DbSeek(xFilial("SA1")+oModel:GetValue("ARQUIVORETORNO","VQ4CIACGC")))
					oModel:SetValue("INFORMACAONF","C5CLIENTE",SA1->A1_COD)
					oModel:SetValue("INFORMACAONF","C5LOJACLI",SA1->A1_LOJA)
				EndIf
				SA1->(DbSetOrder(1))

			EndIf

		EndIf

		oModel:SetValue("CAMPOSTOTAL","CPOTOTDIV", nValRet - nValBon )

	EndIf

	oView:Refresh()

RETURN .t.