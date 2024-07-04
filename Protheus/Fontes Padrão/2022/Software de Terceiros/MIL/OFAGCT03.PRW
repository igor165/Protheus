
#include "protheus.ch"
#include "FWMVCDef.ch"
#include 'FWBrowse.ch'

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  14/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"


/*/{Protheus.doc} OFAGCT03
	Tela de verificação de dados gerados do VMI

	@author Vinicius Gati
	@since  27/06/2017
/*/
Function OFAGCT03()
	Local oBrowse     := FWMBrowse():New()
	Private oVmi      := OFAGVmi():New()
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oUtil     := DMS_Util():New()
	Private oPrcEnvio := MsNewProcess():New( { || OFAGT031_Envia() }, "Gerando dados", "Aguarde...", .T. )
	Private oPrcRecri := MsNewProcess():New( { || OFAGT032_Recria() }, "Gerando dados", "Aguarde...", .T. )

	dbSelectArea("VB6")
	oBrowse:SetAlias("VB6")
	oBrowse:SetDescription("Objetos VMI")

	oBrowse:AddFilter("Envio Pendente"   , " VB6_FLGENV == '0' ")
	oBrowse:AddFilter("Enviados"         , " VB6_FLGENV == '1' ")
	oBrowse:AddFilter("Com Erro"         , " VB6_ERRO   <> ' ' ")
	oBrowse:AddFilter("Do dia"           , " VB6_DATA   == '"+DTOS(DATE())+"' ")
	oBrowse:AddFilter("Impeditivos"      , " VB6_IMPEDI == '1' ")
	oBrowse:AddFilter("Interface DMS-1"  , " 'DMS-1' $ VB6_INTERF ")
	oBrowse:AddFilter("Interface DMS-2"  , " 'DMS-2' $ VB6_INTERF ")
	oBrowse:AddFilter("Interface DMS-3"  , " 'DMS-3' $ VB6_INTERF ")
	oBrowse:AddFilter("Interface DMS-4"  , " 'DMS-4' $ VB6_INTERF ")
	oBrowse:AddFilter("Interface DMS-5"  , " 'DMS-5' $ VB6_INTERF ")
	oBrowse:AddFilter("Interface DMS-6"  , " 'DMS-6' $ VB6_INTERF ")

	oBrowse:AddLegend(" VB6_FLGENV == '1' "                       , "GREEN"  , "Enviado")
	oBrowse:AddLegend(" VB6_FLGENV == '0' .AND.  Empty(VB6_ERRO) ", "YELLOW" , "À enviar")
	oBrowse:AddLegend(" VB6_FLGENV == '0' .AND. !Empty(VB6_ERRO) ", "RED"    , "Erro no envio")

	oBrowse:AddButton("Reenviar"       , {|| oPrcEnvio:activate()    },,2,2)
	oBrowse:AddButton("Recriar"        , {|| oPrcRecri:activate()    },,2,2)
	oBrowse:AddButton("Limpar Arquivos", {|| OFAGT033_Limpa()        },,2,2)
	oBrowse:AddButton("Ajustar Diário" , {|| OFAGT035_AjustaDiario() },,2,2)

	oBrowse:Activate()
Return .T.

/*/{Protheus.doc} OFAGT031_Envia
	Faz nova tentativa de envio dos jsons selecionados
	@author Vinicius Gati
	@since 29/06/2017
/*/
Static Function OFAGT031_Envia()
	local oSqlHlp := DMS_SqlHelper():New()
	local aSelecionados := OFAGT034_Filtrados()
	local cQuery  := ""
	local nIdx    := 1
	local cErros  := ""
	local cErro   := ''
	local nQtd    := len(aSelecionados)
	local lCont   := .t.

	if nQtd > 100
		lCont := .f.
		if MsgNoYes("Existem " + cvaltochar(nQtd) + " registros para serem reenviados, deseja continuar? ", "Atenção")
			lCont := .t.
		endif
	endif

	if lCont
		oPrcEnvio:SetRegua1(len(aSelecionados))

		For nIdx:= 1 to Len(aSelecionados)
			VB6->(DbGoTo(aSelecionados[nIdx]))
			cFilAnt := VB6->VB6_FILIAL
			cErro := oVmi:Enviar({{"RECNO", aSelecionados[nIdx]}, {"FORCE", .T.}})
			if !Empty(cErro) .AND. ! cErro $ cErros
				cErro += chr(13) + chr(10) +  cErro
			endif
			oPrcEnvio:IncRegua1(" Enviados : " + cvaltochar(nIdx)  + " objetos de um total de "+cvaltochar(len(aSelecionados))+". ")
		Next

		if ! Empty(cErro)
			MSGALERT("Erros encontrados : " + cErro, "Atenção")
		else
			MSGALERT("Processo concluído com sucesso, nenhum erro encontrado.")
		endif
	endif
	oPrcEnvio := MsNewProcess():New( { || OFAGT031_Envia() }, "Gerando dados", "Aguarde...", .T. )
Return .T.

/*/{Protheus.doc} OFAGT032_Recria
	Faz nova tentativa de envio dos jsons selecionados
	@author Vinicius Gati
	@since 29/06/2017
/*/
Static Function OFAGT032_Recria()
	local cQuery  := ""
	local nIdx    := 1
	local cErros  := ""
	local cErro   := ''
	local aSelecionados := OFAGT034_Filtrados()
	local nQtd    := len(aSelecionados)
	local lCont   := .t.

	if nQtd > 100
		lCont := .f.
		if MsgNoYes("Existem " + cvaltochar(nQtd) + " registros para serem refeitos, deseja continuar? ", "Atenção")
			lCont := .t.
		endif
	endif

	if lCont
		oPrcRecri:SetRegua1(len(aSelecionados))

		For nIdx:= 1 to Len(aSelecionados)
			VB6->(DbGoTo(aSelecionados[nIdx]))
			cFilAnt := VB6->VB6_FILIAL
			oVmi:Recriar(aSelecionados[nIdx])
			oPrcRecri:IncRegua1(" Recriados : " + cvaltochar(nIdx)  + " objetos de um total de "+cvaltochar(len(aSelecionados))+". ")
		Next

		if ! Empty(cErro)
			MSGALERT("Erros encontrados : " + cErro, "Atenção")
		else
			MSGALERT("Processo concluído com sucesso, nenhum erro encontrado.")
		endif
	endif
	oPrcRecri := MsNewProcess():New( { || OFAGT032_Recria() }, "Gerando dados", "Aguarde...", .T. )
Return .T.

/*/{Protheus.doc} OFAGT033_Limpa
	Será usado para remover os arquivos de execução do VMI para que em caso de problemas
	com cliente seja possível resolver alguns problemas.

	@author Vinicius Gati
	@since 29/06/2017
/*/
Static Function OFAGT033_Limpa()
	Local   nIdx      := 0
	Private aFilis    := oVmiPars:filiais()


	if MsgNoYes("Tem certeza que deseja limpar as configurações e execuções do VMI? Em caso de dúvidas no processo entre em contato com a TOTVS.", "Atenção")
		lFile1 := MsgNoYes("Deseja limpar os dados de execução de objetos diária?", "Atenção")
		lFile2 := MsgNoYes("Deseja que os dados iniciais sejam gerados e enviados novamente a AGCO?", "Atenção")
		lFile3 := MsgNoYes("Deseja remover todos os arquivos não enviados a AGCO?")

		oObj := DMS_DataContainer():New({})
		For nIdx:= 1 to Len(aFilis)
			cFilAnt := aFilis[nIdx]

			if lFile1
				cFile1  := xFilial('VS3') + "_VMI_DELIMITA_INIT.JSON"
				If FERASE(cFile1) == -1
					MsgStop('Falha na deleção do Arquivo')
				Endif
			endif

			if lFile2
				cFile2  := xFilial('VS3') + "_VMI_DADOS_EXECUCAO_INIT.JSON"
				oUtil:ParamFileOpen(cFile2)
				oUtil:ParamFileSave(cFile2, oObj)
			endif

			// Grava dados de delimitação da inicialização do VMI para separar
			oVmi := OFAGVmi():New()
			oVmi:oVmiParametros:DelimitaInit(aFilis)

			if lFile3
				if tcSqlExec(" UPDATE " + RetSqlName('VB6') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VB6_FILIAL = '"+xFilial('VB6')+"' AND VB6_FLGENV = '0' ") < 0
					MSGSTOP("Erro de sql detectado: " + TCSQLError())
				endif
			endif

		Next
	else
		alert("Operação abortada", "Atenção")
	endif

Return .T.

/*/{Protheus.doc} OFAGT034_Filtrados
	Pega os elementos que foram filtrados no grid para efetuar uma acao
	
	@type function
	@author Vinicius Gati
	@since 05/07/2018
/*/
Static Function OFAGT034_Filtrados()
	local aSelecionados := {}
	Local aArea    := VB6->(GetArea())
	VB6->(dbgotop())
	While ! VB6->(EOF())
		aadd(aSelecionados, VB6->(recno()))
		VB6->(DbSkip())
	End
	RestArea(aArea)
	VB6->(dbgotop())
return aSelecionados

/*/{Protheus.doc} OFAGT035_AjustaDiario
	Pega os elementos que foram filtrados no grid para efetuar uma acao
	
	@type function
	@author Vinicius Gati
	@since 05/07/2018
/*/
Static Function OFAGT035_AjustaDiario()
	Local aParamBox := {}
	Local aRet      := {}
	Local dDtEsc    := dDatabase
	Local aFilis    := oVmiPars:filiais()
	Local oJson     := DMS_Json():New()
	Local nIdx      := 1
	Local cMsg      := ""

	AADD(aParamBox,{1,"Data",dDatabase,"@D","","",".T.",80,.T.})

	if !ParamBox(aParamBox,"Data para setar diário", @aRet,,,,,,,,.T.)
		Return .F.
	else
		dDtEsc := aRet[1]

		for nIdx:= 1 to Len(aFilis)
			cFilAnt   := aFilis[nIdx]
			cFileName := xFilial('VS3') + "_VMI_DELIMITA_INIT.JSON"

			oDados    := oUtil:ParamFileOpen(cFileName)
			cD1NUMSEQ := FM_SQL(" SELECT MAX(D1_NUMSEQ) FROM "+RetSqlName('SD1')+" WHERE D1_FILIAL = '"+xFilial('SD1')+"' AND D1_DTDIGIT <= '"+dtos(dDtEsc)+"' AND D_E_L_E_T_ = ' ' ")
			cD2NUMSEQ := FM_SQL(" SELECT MAX(D2_NUMSEQ) FROM "+RetSqlName('SD2')+" WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_EMISSAO <= '"+dtos(dDtEsc)+"' AND D_E_L_E_T_ = ' ' ")
			cD3NUMSEQ := FM_SQL(" SELECT MAX(D3_NUMSEQ) FROM "+RetSqlName('SD3')+" WHERE D3_FILIAL = '"+xFilial('SD3')+"' AND D3_EMISSAO <= '"+dtos(dDtEsc)+"' AND D_E_L_E_T_ = ' ' ")
			oObjD1 := DMS_DataContainer():New({{"NUMSEQ", cD1NUMSEQ}})
			oObjD2 := DMS_DataContainer():New({{"NUMSEQ", cD2NUMSEQ}})
			oObjD3 := DMS_DataContainer():New({{"NUMSEQ", cD3NUMSEQ}})
			cMsg := cFileName + " : " + oJson:toJson(oDados)
			oDados:SetValue("SD1", oObjD1)
			oDados:SetValue("SD2", oObjD2)
			oDados:SetValue("SD3", oObjD3)
			oDados:SetValue("DATA", DTOS(date()))
			cMsg += chr(13) + chr(10) + "             ==> " + oJson:toJson(oDados)
			alert(cMsg)
			
			oUtil:ParamFileSave(cFileName, oDados)
		next
	endif
return .T.