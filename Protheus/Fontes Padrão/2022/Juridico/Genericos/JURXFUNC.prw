#INCLUDE "JURXFUNC.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

Static lVarFiltro := .F.  //Variaveis para o filtro da consulta de cliente da função JURSA1PFL().
Static cXFilial   := ""   //Configurar estas variaveis pela função JURSA1VAR().
Static cXGrupo    := ""
Static cXPerfil   := ""
Static lLogLote   := .F.  //Utilizado para saber se houve gravação de log - Operação em lote
Static __cTpLanc  := ""   // Tipo de Lançamento do Motivo de WO (NXV_TPLANC)

Static _cNWECFixo  := ""
Static _cNWECContr := ""
Static _cNWEDContr := ""
Static _cNWEParc   := ""
Static _dNWEDataVe := ""
Static _dNWEDataAt := ""
Static _lDisarmWO  := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSA1GRP()
Criação da validação na consulta padrão de cliente para filtrar de acordo com o grupo.
Uso Geral.

@Return nRet   Valor numérico de retorno

@author Fabio Crespo Arruda
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSA1GRP()
	Local oModel := FwModelActive()
	Local cRet   := Space( TamSx3( 'ACY_GRPVEN')[1] )

	If oModel:GetId() == 'JURA096'
		If !Empty(M->NT0_CGRPCL) .And. !(M->NT0_TPFAT == '1')
			cRet := M->NT0_CGRPCL
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYNVE
Query para mostrar a pesquisa de casos

@Return cQuery   Query montada

@author Fabio Crespo Arruda
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JQRYNVE(cGrupo, cCliente, cLoja)
	Local cQuery   := ""

	cQuery := "SELECT DISTINCT NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS, NVE.R_E_C_N_O_ NVERECNO"
	cQuery += " FROM " + RetSqlName("NVE") + " NVE," + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE NVE.NVE_FILIAL = '" + xFilial( "NVE" ) + "'"
	cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND NVE.NVE_CCLIEN = SA1.A1_COD "
	cQuery += " AND NVE.NVE_LCLIEN = SA1.A1_LOJA "
	If cGrupo != ' '
		cQuery += " AND SA1.A1_GRPVEN = '" + cGrupo + "'"
	EndIf
	If cCliente != ' '
		cQuery += " AND SA1.A1_COD = '" + cCliente + "'"
	EndIf
	If cLoja != ' '
		cQuery += " AND SA1.A1_LOJA = '" + cLoja + "'"
	EndIf
	cQuery += " AND NVE.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JFILNVE
Filtra os casos de acordo com o grupo de clientes ou o cliente preenchidos

@Return lRet    .T./.F. As informações são válidas ou não

@author Fabio Crespo Arruda
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFILNVE()
	Local oModel   := FwModelActive()
	Local cQuery   := ""
	Local lRet     := .T.
	Local aArea    := GetArea()

	If oModel:GetId() == 'JURA096'
		cQuery   := JQRYNVE(oModel:GetValue("NT0MASTER", "NT0_CGRPCL"), oModel:GetValue("NUTDETAIL", "NUT_CCLIEN"), oModel:GetValue("NUTDETAIL", "NUT_CLOJA"))
		cQuery   := ChangeQuery(cQuery, .F.)

		uRetorno := ''

		RestArea( aArea )

		If JurF3Qry( cQuery, 'JURNVE', 'NVERECNO', @uRetorno,, {"NVE_NUMCAS", "NVE_TITULO"} )
			NVE->( dbGoto( uRetorno ) )
			lRet := .T.
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNVE
Verifica se a consulta padrão de caso deve ser filtrada por cliente
e loja

@param cMaster    Nome do master
@param cCliente   Nome do campo de cliente
@param cLoja      Nome do campo de loja
@param aValue     Valor do Código do cliente e Loja

@return cRet      Comando para filtro

@sample @#JURNVE('NSZMASTER', 'NSZ_CCLIEN', 'NSZ_LCLIEN')

@author Juliana Iwayama Velho
@since 04/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNVE(cMaster, cCliente, cLoja)
Local cRet       := "@#@#"
Local oModel     := Nil

Default cMaster  := ""
Default cCliente := ""
Default cLoja    := ""

If IsPesquisa()
	cRet := "@# .T."
	If !Empty(M->NSZ_CCLIEN)
		cRet += " .AND. NVE->NVE_CCLIEN == '" + M->NSZ_CCLIEN + "'"
	EndIf

	If !Empty(M->NSZ_LCLIEN)
		cRet += " .AND. NVE->NVE_LCLIEN == '" + M->NSZ_LCLIEN + "'"
	EndIf
	cRet += "@#"
Else
	Do Case
	Case IsInCallStack( 'JURA201' )
		cRet := "@#@#"

	Case IsInCallStack('JURA109')
		If !Empty(FWFldGet("NWM_CCLIEN")) .And. !Empty(FWFldGet("NWM_CLOJA"))
			cRet := "@# NVE->NVE_LANTAB == 1 .AND. NVE->NVE_CCLIEN == '" + FWFldGet("NWM_CCLIEN") + "' .AND. NVE->NVE_LCLIEN == '" + FWFldGet("NWM_CLOJA") + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf

	Case (IsInCallStack('JURA246') .Or. IsInCallStack('J246AtuOHF')) .And. FWAliasInDic("OHF") //Proteção
		If !Empty(FWFldGet("OHF_CCLIEN")) .And. !Empty(FWFldGet("OHF_CLOJA"))
			cRet := "@# NVE->NVE_CCLIEN == '" + FWFldGet("OHF_CCLIEN") +"' .AND. NVE->NVE_LCLIEN == '"+ FWFldGet("OHF_CLOJA") + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf

	Case IsInCallStack('JURA281') .And. FWAliasInDic("OHV") //Proteção
		If !Empty(FWFldGet("OHV_CCLIEN")) .And. !Empty(FWFldGet("OHV_CLOJA"))
			cRet := "@# NVE->NVE_CCLIEN == '" + FWFldGet("OHV_CCLIEN") +"' .AND. NVE->NVE_LCLIEN == '"+ FWFldGet("OHV_CLOJA") + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf

	Case IsInCallStack('JURA247') .And. FWAliasInDic("OHG") //Proteção
		If !Empty(FWFldGet("OHG_CCLIEN")) .And. !Empty(FWFldGet("OHG_CLOJA"))
			cRet := "@# NVE->NVE_CCLIEN == '" + FWFldGet("OHG_CCLIEN") +"' .AND. NVE->NVE_LCLIEN == '"+ FWFldGet("OHG_CLOJA") + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf

	Case IsInCallStack('JURA096') .And. NT0->(ColumnPos("NT0_CCLICM")) > 0
		If !Empty(FWFldGet("NT0_CCLICM")) .And. !Empty(FWFldGet("NT0_CLOJCM"))
			cRet := "@# NVE->NVE_CCLIEN == '" + FWFldGet("NT0_CCLICM") +"' .AND. NVE->NVE_LCLIEN == '"+ FWFldGet("NT0_CLOJCM") + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf

	OtherWise
		cRet := "@#NVE->NVE_SITUAC == '1'"
		If (oModel := FWModelActive()) != Nil
			If !Empty(oModel:GetValue(cMaster,cCliente))
				cRet += " .AND. NVE->NVE_CCLIEN == '" + oModel:GetValue(cMaster,cCliente) + "'"
			EndIf

			If !Empty(oModel:GetValue(cMaster,cLoja))
				cRet += " .AND. NVE->NVE_LCLIEN == '" + oModel:GetValue(cMaster,cLoja) + "'"
			EndIf
		EndIf
		cRet += "@#"
	End Case
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNT0
Consulta padrão de contratos.

@param 	cMaster  	Nome do master
@param  cGrupo		Nome do campo de cliente
@param  cCliente	Nome do campo de cliente
@param  cLoja	    Nome do campo de loja

@Return cRet	 	Comando para filtro

@sample
@#JURNT0('NUEMASTER','NUE_CCLIEN','NUE_CLOJA')

@author Felipe Bonvicini Conti
@since 14/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNT0(cMaster, cCliente, cLoja)
	Local cRet       := "@#@#"

	Default cMaster  := ""
	Default cCliente := ""
	Default cLoja    := ""

	If !IsPesquisa()

		// Para utilizar a consulta padrão em outra tela, inclua um novo Case como o abaixo("JURA109")
		// Para telas que irão utilizar esta consulta em mais de um campo, pode-se validar o campo que chamou a consulta padrão
		// utilizando a variável __ReadVar Exemplo:  __ReadVar $ "NWM_CCONTR"
		Do Case
		Case IsInCallStack('JURA109')
			If !Empty(FWFldGet("NWM_CCLIEN")) .And. !Empty(FWFldGet("NWM_CLOJA"))
				cRet := "@#NT0->NT0_CCLIEN == '" + FWFldGet("NWM_CCLIEN") + "' .AND. NT0->NT0_CLOJA == '" + FWFldGet("NWM_CLOJA") + "'@#"
			EndIf
		Case IsInCallStack('J203FilUsr')
			If !Empty(oCliente:GetValue() ) .And. !Empty(oLoja:GetValue())
				cRet := "@#NT0->NT0_CCLIEN == '" + oCliente:GetValue() + "' .AND. NT0->NT0_CLOJA == '" + oLoja:GetValue() + "'@#"
			EndIf
		OtherWise
			If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty( FWFldGet(cCliente)) .And. !Empty( FWFldGet(cLoja))
				cRet := "@#NT0->NT0_CCLIEN == '" + FWFldGet(cCliente) + "' .AND. NT0->NT0_CLOJA == '" + FWFldGet(cLoja) + "'@#"
			EndIf
		End Case

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNTSCons
Consulta padrão do tipo de Serviço tabelado

@Return   cRet     String para o filtro

@author Felipe Bonvicini Conti
@since 18/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNTSCons(cClient, cLoja, cCaso, cDataLanc)
	Local cRet         := "@#@#"
	Local aArrRet      := {}

	Default cClient    := ""
	Default cLoja      := ""
	Default cCaso      := ""
	Default cDataLanc  := ""

	Do Case
	Case IsInCallStack('JURA109')
		aArrRet := FBusSrv(FwFldGet('NWM_CCLIEN'), FwFldGet('NWM_CLOJA'), FwFldGet('NWN_CCASO'), Left(DToS(FwFldGet('NWM_DTBASE')), 6))
		If !Empty(aArrRet[1])
			cRet := "@#NTS->NTS_CTAB == '" + aArrRet[2] + "' .AND.  NTS->NTS_CHIST == '" + aArrRet[1] + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf
	OtherWise
		aArrRet := FBusSrv(FwFldGet(cClient), FwFldGet(cLoja), FwFldGet(cCaso), Left(DToS(FwFldGet(cDataLanc)), 6))
		If !Empty(aArrRet[1])
			cRet := "@#NTS->NTS_CTAB == '" + aArrRet[2] + "' .AND.  NTS->NTS_CHIST == '" + aArrRet[1] + "'@#"
		Else
			cRet := "@#.F.@#"
		EndIf
	End Case

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FBusSrv
Busca Servicos do Caso

@Param    cCodCli  Código do Cliente
@Param    cLojCli  Código da Loja
@Param    cCodCas  Código do Caso
@Param    cAnoMes  Ano Mes

@Return   cRet     String para o filtro

@author Jacques Alves Xavier
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function FBusSrv(cCodCli, cLojCli, cCodCas, cAnoMes)
	Local cCodHis := ''
	Local cCodTab := ''
	Local cMsgErr := ''

	If !Empty(cAnoMes)
		NUU->(dbSetOrder(1))
		NUU->(dbSeek(xFilial('NUU') + cCodCli + cLojCli + cCodCas))

		While !NUU->(Eof()) .And. NUU->(NUU_FILIAL + NUU_CCLIEN + NUU_CLOJA + NUU_CCASO) ==  xFilial('NUU') + cCodCli + cLojCli + cCodCas
			If cAnoMes >= NUU->NUU_AMINI .And. (cAnoMes <= NUU->NUU_AMFIM .Or. Empty(NUU->NUU_AMFIM))
				cCodTab := NUU->NUU_CTABS
				Exit
			EndIf

			NUU->(dbSkip())
		EndDo

		If !Empty(cCodTab)
			NU1->(dbSetOrder(1))
			NU1->(dbSeek(xFilial('NU1') + cCodTab))

			While ! NU1->(Eof()) .And. NU1->(NU1_FILIAL + NU1_CTAB) == xFilial('NUU') + cCodTab

				If cAnoMes >= NU1->NU1_AMINI .And. (cAnoMes <= NU1->NU1_AMFIM .Or. Empty(NU1->NU1_AMFIM))
					cCodHis := NU1->NU1_COD
					Exit
				EndIf

				NU1->(dbSkip())
			EndDo

			If Empty(cCodHis)
				cMsgErr := STR0032 //'Historico das tabelas de nao localizado'
			EndIf
		Else
			cMsgErr := STR0033 //'Historico do caso nao localizado'
		EndIf
	Else
		cMsgErr := STR0034 //'Data de lancamento deve ser preenchida anteriormente'
	EndIf

Return {cCodHis, cCodTab, cMsgErr}

//-------------------------------------------------------------------
/*/{Protheus.doc} JAEXECPLAN
Função para exetucar rotinas ao preencher o cliente, loja ou caso
nos lançamentos (Time-Sheet / Despesa / Tabelado)
- Preenche o Grupo, Cliente e Loja ao digitar o caso quando a numeração única
- Preenche o Grupo, ao digitar Cliente e Loja

@param  cModel      Nome do Model que possui os campos
@param  cGrupo      Nome do Campo de Gruo de cliente do model
@param  cCliente    Nome do Campo de cliente do model
@param  cLoja       Nome do Campo de Loja do model
@param  cCaso       Nome do Campo de Caso do model

@Return cRet        Indica se a validação foi bem sucedida ou não( .T. / .F. )

@sample JAEXECPLAN('NUEMASTER', 'NUE_C', cCliente, cLoja, cCaso)

@author David Gonçalves Fernandes
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAEXECPLAN(cModel, cCpGrupo, cCpCliente, cCpLoja, cCpCaso, cCampo)
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local cNumCaso := SuperGetMV('MV_JCASO1',, '1')
	Local aArea    := GetArea()
	Local aAreaNVE := NVE->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local cClien   := ''
	Local cLoja    := ''
	Local cGrupo   := ''
	Local cMsg     := ''
	Local aCliLoj  := {}

	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4

		If cCampo == cCpCaso .And. cNumCaso == '2' .And. !Empty(oModel:GetValue(cModel, cCpCaso))

			aCliLoj := JCasoAtual(oModel:GetValue(cModel, cCpCaso))

			If !Empty(aCliLoj)
				cClien := aCliLoj[1][1]
				cLoja  := aCliLoj[1][2]
			Else
				cClien := oModel:GetValue(cModel, cCpCliente)
				cLoja  := oModel:GetValue(cModel, cCpLoja)
			EndIf
			cGrupo := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_GRPVEN')

			If cCpGrupo == ""
				lRet := oModel:LoadValue(cModel, cCpCliente, IIF(Empty(cClien), "", cClien) ) .And.;
				        oModel:LoadValue(cModel, cCpLoja,    IIF(Empty(cLoja),  "", cLoja ) )
				If !lRet
					cMsg := STR0048 //"Erro ao preencher o código do Cliente / Loja"
				EndIf
			Else
				lRet := oModel:LoadValue(cModel, cCpGrupo,   IIF(Empty(cGrupo), "", cGrupo) ) .And.;
				        oModel:LoadValue(cModel, cCpCliente, IIF(Empty(cClien), "", cClien) ) .And.;
				        oModel:LoadValue(cModel, cCpLoja,    IIF(Empty(cLoja),  "", cLoja ) )
				If !lRet
					cMsg := STR0001 //"Erro ao preencher o código do Grupo / Cliente / Loja"
				EndIf
			EndIf

		ElseIf cCampo == cCpCliente .Or. cCampo == cCpLoja

			If !Empty(oModel:GetValue(cModel, cCpCliente)) .And. !Empty(oModel:GetValue(cModel, cCpLoja))
				If cCpGrupo != ""
					cGrupo := JurGetDados('SA1', 1, xFilial('SA1') + oModel:GetValue(cModel, cCpCliente) + oModel:GetValue(cModel, cCpLoja), 'A1_GRPVEN ')
					If !(oModel:LoadValue(cModel, cCpGrupo, cGrupo) )
						lRet := .F.
						cMsg := STR0002 //"Erro ao preencher o código do Grupo"
					EndIf
				EndIf

				If lRet .And. !Empty(cCpCaso)
					If lRet .And. !Empty(oModel:GetValue(cModel, cCpCaso))
						If !ExistCpo('NVE', oModel:GetValue(cModel, cCpCliente) + oModel:GetValue(cModel, cCpLoja) + oModel:GetValue(cModel, cCpCaso), 1)
							oModel:LoadValue(cModel, cCpCaso, "")
						EndIf
					EndIf
				EndIf
			EndIf

			If cCampo == cCpCliente .And. Empty(oModel:GetValue(cModel, cCpCliente))
				oModel:LoadValue(cModel, cCpLoja, "")
			EndIf

		ElseIf cCampo == cCpCaso .And. cNumCaso == '1'

			If !Empty(oModel:GetValue(cModel, cCpCliente)) .And. !Empty(oModel:GetValue(cModel, cCpLoja))
				lRet := ExistCpo('NVE', oModel:GetValue(cModel, cCpCliente) + oModel:GetValue(cModel, cCpLoja) + oModel:GetValue(cModel, cCpCaso), 1)
				If !lRet
					oModel:LoadValue(cModel, cCpCaso, "")
					cMsg := STR0047 //"Preenchimento de Grupo / Cliente / Loja / Caso inválido. Verifique!"
				EndIf
			EndIf

		EndIf

	EndIf

	If !lRet
		JurMsgErro(cMsg)
	EndIf

	RestArea( aAreaNVE )
	RestArea( aAreaSA1 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAVLDCPLAN
Função para validar os referências dos campos ao preencher o
cliente, loja, caso nos lançamentos (Time-Sheeet, Despesa , Tabelado)

@param  cCampo  Nome do campo que será validado
@Return cRet    Indica se a validação foi bem sucedida ou não( .T. / .F. )

@author David Gonçalves Fernandes
@since 09/12/09
@version 1.0

@OBS Proteção - Excluída na FENALAW e mantida por compatibilidade
/*/
//-------------------------------------------------------------------
Function JAVLDCPLAN(cModel, cCpCliente, cCpLoja, cCpCaso, cCampo, cCpoLanc, cCpoPreFt)
	Local lRet		:= .T.
	Local oModel	:= FWModelActive()
	Local aArea		:= GetArea()
	Local aAreaNVE	:= NVE->(GetArea())
	Local aAreaSA1	:= SA1->(GetArea())
	Local cClien	:= oModel:GetValue(cModel,cCpCliente)
	Local cLoja		:= oModel:GetValue(cModel,cCpLoja)
	Local cCaso		:= oModel:GetValue(cModel,cCpCaso)

	If ((oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4))

		If cCampo == cCpCaso .AND. !Empty(cClien) .AND. !Empty(cLoja)
			lRet := ExistCpo('NVE', cClien + cLoja + cCaso, 1)
			//Condições para o lançamento
			If lRet .AND. !IsInCallStack( 'JURA063' ) .AND. !IsInCallStack( 'J063REMANJ' )
				lRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, cCpoLanc) == '1'
				If lRet
					lRet := JurGetDados ("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, 'NVE_SITUAC') == '1'
					If !lRet
						lRet := JRetDtEnc(JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_DTENCE"), SuperGetMV('MV_JLANC1',, 0)) >= Date()
						If !lRet
							lRet := JurGetDados("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), "NUR_CASOEN") == '1'
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == cCpLoja .AND. !Empty(cClien) .AND. !Empty(cLoja)
			lRet := ExistCpo('SA1', cClien + cLoja, 1)
		EndIf

	EndIf
	
	RestArea( aAreaNVE )
	RestArea( aAreaSA1 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLancPre
Rotina para verificar se há lançamentos vinculados à pré:
@param cPreFt       Código da Pré-fatura.
@param lCobraHora  Informa se cobra Timesheet .T./.F.

@Return nRet Quantidade de lançamentos validos na Pré

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLancPre(cPreFt, lCobraHora)
	Local nRet      := 0
	Local aArea     := GetArea()
	Local cQuery    := ""
	Local cQueryRes := GetNextAlias()
	Local aOrd      := SaveOrd({"NT1"})
	Local nNumRegs  := 0

	If !Empty(cPreFt)
		If ValType(lCobraHora) <> "L" // Se estiver vazio, mantem a rotina antiga utilizada por outras rotinas que não fazem parte do WO Fixo.
			cQuery := " SELECT SUM(A.CONTA) TOTAL FROM ( "
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NUE") + " NUE "
			cQuery +=     " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
			cQuery +=     " AND NUE.NUE_CPREFT = '" + cPreFt + "' "
			cQuery +=     " AND NUE.D_E_L_E_T_ = ' ' "
			cQuery +=     " UNION ALL "
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NVY") + " NVY "
			cQuery +=     " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
			cQuery +=     " AND NVY.NVY_CPREFT = '" + cPreFt + "' "
			cQuery +=     " AND NVY.D_E_L_E_T_ = ' ' "
			cQuery +=     " UNION ALL "
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NV4") + " NV4 "
			cQuery +=     " WHERE NV4.NV4_FILIAL ='" + xFilial("NV4") + "' "
			cQuery +=     " AND NV4.NV4_CPREFT = '" + cPreFt + "' "
			cQuery +=     " AND NV4.D_E_L_E_T_ = ' ' "
			cQuery +=     " UNION ALL "
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NT1") + " NT1 "
			cQuery +=     " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
			cQuery +=     " AND NT1.NT1_CPREFT ='" + cPreFt + "' "
			cQuery +=     " AND NT1.D_E_L_E_T_ = ' ' "
			cQuery +=     " UNION ALL "
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NVV") + " NVV "
			cQuery +=     " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
			cQuery +=     " AND NVV.NVV_CPREFT = '" + cPreFt + "' "
			cQuery +=     " AND NVV.D_E_L_E_T_ = ' ' "
			cQuery += " ) A "
		Else // Verifica se há lançamentos exclusivo para o WO Fixo.
			cQuery := " SELECT SUM(A.CONTA) TOTAL FROM ( "
			If lCobraHora
				cQuery += " SELECT COUNT(1) CONTA "
				cQuery += " FROM " + RetSqlName("NUE") + " NUE "
				cQuery += " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
				cQuery += " AND NUE.NUE_CPREFT = '" + cPreFt + "' "
				cQuery += " AND NUE.D_E_L_E_T_ = ' ' "
				cQuery += " UNION ALL "
			EndIf
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NVY") + " NVY "
			cQuery +=     " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
			cQuery +=     " AND NVY.NVY_CPREFT = '" + cPreFt + "' "
			cQuery +=     " AND NVY.D_E_L_E_T_ = ' ' "
			cQuery +=     " UNION ALL "
			cQuery +=     " SELECT COUNT(1) CONTA "
			cQuery +=     " FROM " + RetSqlName("NV4") + " NV4 "
			cQuery +=     " WHERE NV4.NV4_FILIAL ='" + xFilial("NV4") + "' "
			cQuery +=     " AND NV4.NV4_CPREFT = '" + cPreFt + "' "
			cQuery +=     " AND NV4.D_E_L_E_T_ = ' ' "
			cQuery += " ) A "
		EndIf

		cQuery := ChangeQuery(cQuery, .F.)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

		nRet := (cQueryRes)->TOTAL

		(cQueryRes)->(DbCloseArea())

		If ValType(lCobraHora) == "L" // Verifica se há lançamentos exclusivo para o WO Fixo.
			NT1->(DbSetOrder(3)) // NT1_FILIAL+NT1_CPREFT+NT1_CCONTR
			NT1->(DbSeek(xFilial("NT1") + RTrim(cPreFt)))
			Do While ! NT1->(Eof()) .And. NT1->NT1_FILIAL + RTrim(NT1->NT1_CPREFT) == xFilial("NT1") + RTrim(cPreFt)
				nNumRegs += 1

				NT1->(DbSkip())
			EndDo
			If nNumRegs > 1
				nRet := nRet + nNumRegs
			EndIf
		EndIf
	EndIf

	RestArea( aArea )
	RestOrd(aOrd)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAALTCASO
Rotina para cancelar a pré ao mudar o caso do lançamento

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAALTCASO(cCodPre, cModel, cTabela, cCodLanc, cClien, cLoja, cCaso, oModel)
Local lRet      := .F.
Local aArea     := GetArea()
Local cQuery    := ""
Local cQueryRes := GetNextAlias()
Local lRemvVinc := .F. //remover vinculo com a pré-fatura
Local cTpLanc   := ''
Local cAcaoLD   := ""

Default oModel  := FWModelActive()

If &(cTabela)->(ColumnPos(cTabela + "_ACAOLD")) > 0
	cAcaoLD := oModel:GetValue(cModel, cTabela + "_ACAOLD")
EndIf

// Verifica se o caso novo também está na mesma pré-fatura, se não estiver, desvincula o lançamento
If !Empty(cCodPre)

	//Verifica se o caso está na mesma pré:
	cQuery := " SELECT COUNT(NX1.R_E_C_N_O_) CONTA "
	cQuery +=     " FROM " + RetSqlName("NX1") + " NX1"
	cQuery +=     " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") +"' "
	cQuery +=       " AND NX1.NX1_CPREFT = '" + cCodPre + "' "
	cQuery +=       " AND NX1.NX1_CCLIEN = '" + cClien + "' "
	cQuery +=       " AND NX1.NX1_CLOJA  = '" + cLoja + "' "
	cQuery +=       " AND NX1.NX1_CCASO  = '" + cCaso + "' "
	cQuery +=       " AND NX1.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

	lRemvVinc := (cQueryRes)->CONTA == 0 .Or. cAcaoLD == "1" //Não é a da mesma pré-fatura OU acão do legal Desk de Retirar da pré-fatura

	(cQueryRes)->(DbCloseArea())

	If lRemvVinc
		lRet := oModel:ClearField(cModel, cTabela + "_CPREFT")
		If cTabela != "NVV"
			lRet := lRet .And. oModel:ClearField(cModel, cTabela + "_COTAC1")
			lRet := lRet .And. oModel:ClearField(cModel, cTabela + "_COTAC2")
		EndIf

		If cTabela == "NUE"
			lRet := lRet .And. oModel:ClearField(cModel, cTabela + "_VALOR1")
		EndIf
	EndIf

	// Verifica se ainda há mais lançamentos na pré:
	If lRet .AND. (JurLancPre( cCodPre ) <= 1)
		JA202CANPF( cCodPre )
	EndIf

EndIf

Do Case
Case cTabela == "NUE"
	cTpLanc := 'TS'
Case cTabela == "NVY"
	cTpLanc := 'DP'
Case cTabela == "NV4"
	cTpLanc := 'LT'
Case cTabela == "NT1"
	cTpLanc := 'FX'
Case cTabela == "NVV"
	cTpLanc := 'FA'
EndCase

//Verifica e cancela o vinculo do lançamento
JACanVinc(cTpLanc, cCodPre, cCodLanc, lRemvVinc )

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANVELANC
Rotina para consulta padrão de caso , considerando o parâmetro dias de
encerramento do caso e as permissões do participante logado.
Uso Geral.

@param 	cMaster  	Nome do master
@param 	cMaster  	Nome do master
@param  cGrupo		Nome do campo de cliente
@param  cCliente	Nome do campo de cliente
@param  cLoja	    Nome do campo de loja
@param  cCpoLanc	Nome do campo do caso que permite / bloqueia o lançamento
NVE_LANTS / NVE_LANDSP / NVE_LANTAB

@Return cRet	 		Comando para filtro

@sample
@#JANVELANC("NUEMASTER","NUE_CGRPCL","NUE_CCLIEN","NUE_CLOJA","NVE_LANTS") //Não pode ter espaços

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANVELANC(cMaster, cGrupo, cCliente, cLoja, cCpoLanc)
	Local aArea      := GetArea()
	Local cRet       := "@#@#"
	Local cCodGrp    := ""
	Local cCodCli    := ""
	Local cCodLoj    := ""
	Local lSituac    := JurGetDados("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), "NUR_CASOEN") == "1"
	Local nLanc1     := SuperGetMV('MV_JLANC1',, 0)
	Local cMvJCaso   := SuperGetMV('MV_JCASO1',, '1')

	Default cMaster  := "NUEMASTER"
	Default cGrupo   := "NUE_CGRPCL"
	Default cCliente := "NUE_CCLIEN"
	Default cLoja    := "NUE_CLOJA"

	If IsInCallStack("JA144DIVTS")
		cCodGrp := cGetGrup
		cCodCli := cGetClie
		cCodLoj := cGetLoja
	Else
		oModel  := FWModelActive()
		cCodGrp := oModel:GetValue(cMaster, cGrupo)
		cCodCli := oModel:GetValue(cMaster, cCliente)
		cCodLoj := oModel:GetValue(cMaster, cLoja)
	EndIf

	//Filtra casos que permitem lançamento
	cRet := "@#NVE->" + cCpoLanc + " == '1' "

	Do Case
	Case Empty(cCodCli) .And. cMvJCaso == '1'
		cRet += " .AND. .F. "

	Case !Empty(cCodCli)
		If !Empty(cCodCli)
			cRet += " .AND. NVE->NVE_CCLIEN == '" + cCodCli + "'"
		EndIf
		If !Empty(cCodLoj)
			cRet += " .AND. NVE->NVE_LCLIEN == '" + cCodLoj + "'"
		EndIf
		If !Empty(cCodGrp)
			cRet += ".AND. NVE->NVE_CGRPCL == '" + cCodGrp + "'"
		Endif
	EndCase

	//Filtra a situação do caso for em andamento ou estiver na permissão
	If !lSituac
		cRet += " .AND. ( NVE->NVE_SITUAC == '1' "
		cRet += " .OR. (NVE->NVE_SITUAC == '2'"
		cRet += " .AND. NVE->NVE_DTENCE >= '" + DtoS(JRetDtEnc(Date(), nLanc1, .T.)) + "' ))@#"
	Else
		cRet += "@#"
	EndIf

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYNRCNR5
Monta a query de atividades conforme o idioma do caso

@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JQRYNRCNR5(cClien, cLoja, cCaso, cAtiv)
	Local cQuery   := ""
	Local cIdioma  := JurGetDados('NVE', 1, xFilial('NVE') + cClien + cLoja + cCaso, 'NVE_CIDIO')
	Default cAtiv  := ""

	cQuery := " SELECT NRC.NRC_COD, NR5.NR5_DESC, NRC.R_E_C_N_O_ NRCRECNO "
	cQuery +=   " FROM " + RetSqlName("NRC") + " NRC, "
	cQuery +=        " " + RetSqlName("NR5") + " NR5 "
	cQuery += " WHERE NRC.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NR5.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NRC.NRC_FILIAL = '" + xFilial( "NRC" ) + "' "
	cQuery +=   " AND NR5.NR5_FILIAL = '" + xFilial( "NR5" ) + "' "
	cQuery +=   " AND NRC.NRC_COD = NR5.NR5_CTATV "
	cQuery +=   " AND NR5.NR5_CIDIOM = '" + cIdioma + "' "
	cQuery +=   " AND NRC.NRC_COD NOT IN ( "
	cQuery +=                              " SELECT NTJ.NTJ_CTPATV "
	cQuery +=                                " FROM " + RetSqlName("NTJ") + " NTJ "
	cQuery +=                              " WHERE NTJ.NTJ_CCONTR IN ( SELECT NUT.NUT_CCONTR "
	cQuery +=                                                          " FROM " + RetSqlName("NUT") + " NUT "
	cQuery +=                                                        " WHERE NUT.NUT_CCLIEN = '" + cClien + "' "
	cQuery +=                                                        " AND NUT.NUT_CLOJA = '" + cLoja + "' "
	cQuery +=                                                        " AND NUT.NUT_CCASO = '" + cCaso + "' "
	cQuery +=                                                        " AND NUT.D_E_L_E_T_ = ' ' "
	cQuery +=                                                        " ) "
	cQuery +=                                " AND NTJ.D_E_L_E_T_ = ' ' "
	cQuery +=                           " ) "
	cQuery +=   " AND NRC.NRC_ATIVO = '1' "

	If cAtiv <> ""
		cQuery += " AND NRC.NRC_COD = '" + cAtiv + "' "
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNRC
Verifica se o valor do campo de atividade é válido quando o mesmo o
digita no campo

@param 	cMaster  	Fields ou Grid a ser verificado
@Return cCampo	    Campo de participante a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@sample
ExistCpo('RD0',M->NTE_CPART,1).AND.JURRD0('NTEDETAIL','NTE_CPART')

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNRC(cMaster, cCpClien, cCpLoja, cCpCaso, cCpAtiv)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cAlias   := GetNextAlias()
	Local oModel   := FWModelActive()
	Local cClien   := oModel:GetValue(cMaster, cCpClien)
	Local cLoja    := oModel:GetValue(cMaster, cCpLoja)
	Local cCaso    := oModel:GetValue(cMaster, cCpCaso)
	Local cQuery   := JQRYNRCNR5(cClien, cLoja, cCaso)

	cQuery := JQRYNRCNR5(cClien, cLoja, cCaso)
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If (cAlias)->NRC_COD == oModel:GetValue(cMaster, cCpAtiv)
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	EndDo

	If !lRet
		JurMsgErro(STR0003)//Não há registro relacionado com este código
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3NRC
Monta a consulta padrão participantes ativos
Uso Geral.
@param 	cMaster 	Nome da estrutura do modelo de dados
cCpClien 	Nome do campo de cliente do cadastro utilizado
cCpLoja 	Nome do campo de loja
cCpCaso 	Nome do campo de caso

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
Consulta padrão específica RD0ATV

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3NRC(cMaster, cCpClien, cCpLoja, cCpCaso)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local oModel   := FWModelActive()
	Local cClien   := oModel:GetValue(cMaster, cCpClien)
	Local cLoja    := oModel:GetValue(cMaster, cCpLoja)
	Local cCaso    := oModel:GetValue(cMaster, cCpCaso)
	Local aPesq    := { "NRC_COD", "NR5_DESC" }

	cQuery := JQRYNRCNR5(cClien, cLoja, cCaso)
	cQuery := ChangeQuery(cQuery, .F.)

	uRetorno := ''

	RestArea( aArea )

	If JurF3Qry( cQuery, 'JURNRC', 'NRCRECNO', @uRetorno, , aPesq )
		NRC->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURATIV
Retorna a descrição da atividade no idioma do caso
Uso Geral.
@param 	cClien 	Cliente do cadastro utilizado
        cLoja 	Código da loja
        cCaso 	Código do caso
        cAtivi 	Código da Atividade

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURATIV(cClien, cLoja, cCaso, cAtiv)
	Local cRet     := ""
	Local cAlias   := GetNextAlias()
	Local aArea    := GetArea()
	Local cQuery   := ""
	cQuery         := JQRYNRCNR5(cClien, cLoja, cCaso, cAtiv)
	cQuery         := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	If !Empty( (cAlias)->NR5_DESC )
		cRet := (cAlias)->NR5_DESC
	EndIf
	(cAlias)->( dbcloseArea() )
	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAUSAEBILL
Retorna o código do documento, senão, retorna vazio
Uso Geral.
@param 	cClien	Código do cliente
cLoja		Código da loja

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAUSAEBILL(cClien, cLoja)
	Local lRet := ""

	lRet := JurGetDados("NUH", 1, xFilial("NUH") + cClien + cLoja, "NUH_UTEBIL") == '1'

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAEMPEBILL
Retorna o código do documento, senão, retorna vazio
Uso Geral.
@param 	cClien	Código do cliente
cLoja		Código da loja

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAEMPEBILL(cClien,cLoja)
	Local cEmp := ""
	Local cRet := ""

	cEmp := JurGetDados("NUH", 1, xFilial("NUH") + cClien + cLoja, "NUH_CEMP")

	If Empty(cEmp) .And. FwIsInCallStack("JURA148") .And. !IsInCallStack("JA144Ebil")
		cEmp := FwFldGet("NUH_CEMP")
	EndIf

	If !Empty(cEmp)
		cRet := JurGetDados("NRX", 1, xFilial("NRX") + cEmp, "NRX_CDOC")
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAEBILLCPO
Valida se a fase ou tarefa existem para o documento padrão do cliente
Uso Geral.
@param cClient, Codigo do Cliente e-Billing
@param cLoja  , Codigo da Loja do Cliente e-Billing
@param cFase  , Codigo da Fase e-Billing
@param cTarefa, Codigo da Tarefa e-Billing
@param cAtivid, Codigo da Atividade e-Billing
@param cDocto , Codigo do Documento e-Billing (Somente para retorno por referencia)
@param lAlert , .T. para exiber erro com ApMsgAlert, .F. para exiber erro com JurMsgErro

@Return lRet     .T. para validação positiva do codigo testado

@Obs A validação da tarefa depende da informação da fase e-billing

@author Luciano Pereira dos Santos
@since 15/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAEBILLCPO(cClient, cLoja, cFase, cTarefa, cAtivi, lMsg, cDocto, lAlert)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNRZ  := NRZ->( GetArea() )
Local aAreaNRY  := NRY->( GetArea() )
Local cFaseInt  := ""
Local cMsg      := ""
Local cSolucao  := ""

Default lMsg    := .T.
Default cDocto  := ""
Default lAlert  := .F.

If !Empty(cClient) .AND. !Empty(cLoja)

	cDocto := JAEMPEBILL(cClient, cLoja)

	If !Empty(cDocto)
		If !Empty(cFase)
			NRY->(DbSetOrder(5)) //NRY_FILIAL + NRY_CFASE + NRY_CDOC
			If !(lRet := NRY->(DbSeek(xFilial("NRY") + cFase + cDocto)))
				cSolucao := I18N(STR0138, {Alltrim(RetTitle('NUE_CFASE'))}) //"Verifique o valor digitado no campo '#1'."
			Else
				cFaseInt := NRY->NRY_COD //Codigo interno da fase
			EndIf
		EndIf

		If lRet .And. !Empty(cTarefa)
			NRZ->(DbSetOrder(2)) //NRZ_FILIAL + NRZ_CDOC + NRZ_CFASE + NRZ_CTAREF
			If !(lRet:= NRZ->( DbSeek( xFilial('NRZ') + cDocto + cFaseInt + cTarefa) ))
				cSolucao := I18N(STR0138, {Alltrim(RetTitle('NUE_CTAREF'))}) //"Verifique o valor digitado no campo '#1'."
			EndIf
		EndIf

		If lRet .And. !Empty(cAtivi)
			NS0->(DbSetOrder(2)) //NS0_FILIAL + NS0_CDOC + NS0_CATIV
			If !(lRet:= NS0->(DbSeek(xFilial("NS0") + cDocto + cAtivi)))
				cSolucao := I18N(STR0138, {Alltrim(RetTitle('NUE_CTAREB'))}) //"Verifique o valor digitado no campo '#1'."
			EndIf
		EndIf

		If !lRet
			cMsg := STR0003 //Não há registro relacionado com este código
		EndIf
	Else
		lRet := .F.
		cMsg := STR0004 //"A Empresa de Ebilling não foi definida no cadastro do cliente
		cSolucao := I18N(STR0139, {Alltrim(RetTitle('NUE_CCLIEN')) + " '" + cClien + "'", Alltrim(RetTitle('NUE_CLOJA')) + " '" + cLoja + "'" }) //"Verifique o cadastro de cliente se o #1 e #2 utiliza empresa e-billing."
	EndIf

Else
	lRet := .F.
	cMsg := STR0005 //"Dados do cliente não preenchidos"
	cSolucao := I18N(STR0140, {Alltrim(RetTitle('NUE_CCLIEN')), Alltrim(RetTitle('NUE_CLOJA'))})
EndIf

If !lRet .And. lMsg
	If lAlert
		ApMsgAlert(cMsg + CRLF + cSolucao)
	Else
		JurMsgErro(cMsg, , cSolucao)
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaNRZ)
RestArea(aAreaNRY)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAEBILLFAS
Verifica a fase e-billing
Uso Geral.

@param 	cClien	Código de Cliente
@param  cLoja	Código da loja
@param  cFase	Código da fase

@Return cRet	Código sequencial da fase

@author Juliana Iwayama Velho
@since 27/05/1
@version 1.0
/*/
//-------------------------------------------------------------------
function JAEBILLFAS(cClien, cLoja, cFase)
	Local cRet      := ''
	Local aArea     := GetArea()
	Local aAreaNRY  := NRY->( GetArea() )
	Local cDocto    := ""

	If !Empty(cClien) .AND. !Empty(cLoja)

		cDocto := JAEMPEBILL(cClien,cLoja)

		If !Empty(cDocto)

			If !Empty(cFase)

				NRY->( dbSetOrder( 1 ) )
				If NRY->( dbSeek( xFilial('NRY') + cDocto ) )

					While !NRY->( EOF() ) .AND. NRY->NRY_CDOC == cDocto
						If AllTrim(NRY->NRY_CFASE) == AllTrim(cFase)
							cRet := NRY->NRY_COD
							Exit
						EndIf
						NRY->( dbSkip() )
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaNRY)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAEBILLATV
Verifica a atividade do e-billing
Uso Geral.

@param 	cClien	Código de Cliente
@param  cLoja	Código da loja
@param  cAtiv	Código da atividade

@Return cRet	Código sequencial da fase

@author Felipe Bonvicini Conti
@since 14/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAEBILLATV(cClien, cLoja, cAtiv)
	Local lRet   := .F.
	Local cDocto := ""

	If !Empty(cClien) .AND. !Empty(cLoja) .And. !Empty(cAtiv)

		cDocto := JAEMPEBILL(cClien, cLoja)
		If !Empty(cDocto)
			lRet := !Empty(JurGetDados('NS0', 2, xFilial('NS0') + cDocto + cAtiv, 'NS0_CATIV'))
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JASelOpcao
Cria a tela para definir qual a ação a realizar nos time-sheets

@param 	cCampo	"NUE_DATIVI" ou "NUE_DCASO"
@Return lRet	 	.T./.F. As informações são válidas ou não

@author David G. Fernandes
@since 22/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JASelOpcao(cCampo, aCoord, cTitle, cTitCampo)
	Local cRet     := ''
	Local aInfo    := Nil
	Local aArea    := GetArea()
	Local cTipoAlt := CriaVar(cCampo)
	Local oDlg, oBtnOk, oBtnCan
	Local oCmbValor
	Local oGetValor
	Local oPnlTop, oPnlBtn, oPnlBtnR, oPnlBtnL
	Local aItems    := {}

	Default cTitle  :=  STR0006

	aInfo := AVSX3(cCampo)
	If !Empty(aInfo[5]) .And. Empty(cTitCampo)
		cTitCampo  := aInfo[5]
	EndIf
	If !Empty(aInfo[12])
		aItems  := StrToArray( aInfo[12], ';' )
	EndIf

	ParamType 1 Var aCoord  As Array Optional Default { 0, 0, 100, 240 }

	Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Title cTitle Pixel Of oMainWnd

	oPnlTop       := tPanel():New(0,0,'',oDlg,,,,,,0,25)
	oPnlBtn       := tPanel():New(0,0,'',oDlg,,,,,,0,20)
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

	oPnlBtnR      := tPanel():New(0,0,'',oPnlBtn,,,,,,35,0)
	oPnlBtnL      := tPanel():New(0,0,'',oPnlBtn,,,,,,35,0)
	oPnlBtnR:Align:= CONTROL_ALIGN_RIGHT
	oPnlBtnL:Align:= CONTROL_ALIGN_RIGHT

	oSayTipoAlt := tSay():New(01,03,{||cTitCampo},oPnlTop,,,,,,.T.,,,50,10)
	oSayTipoAlt:lWordWrap   := .T.
	oSayTipoAlt:lTransparent:= .T.

	If !Empty(aInfo[12])
		oCmbValor := TComboBox():New(10,03,{|u|IIf(PCount()>0,cTipoAlt:=u,cTipoAlt)},;
			aItems,60,10,oPnlTop,,{||/*Ação*/},,,,.T.,,,,,,,,,'cTipoAlt')
	Else
		If !Empty(aInfo[8])
			oGetValor := TGet():New(10,03,{|u|IIf(PCount()>0,cTipoAlt:=u,cTipoAlt)},oPnlTop,100,010,;
				/*"@!"*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,aInfo[8]/*F3*/,'cTipoAlt',,,,.T. )
		Else
			oGetValor := TGet():New(10,03,{|u|IIf(PCount()>0,cTipoAlt:=u,cTipoAlt)},oPnlTop,100,010,;
				/*"@!"*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cTipoAlt',,,, )
		EndIf
	EndIf

	@ 03,03 Button oBtnOk  Prompt STR0007 Size 30,10 Pixel Of oPnlBtnL Action (  iif(Empty(cTipoAlt),(jurmsgerro(STR0010,STR0009),cRet := ''), (cRet := cTipoAlt , oDlg:End()) ) )
	@ 03,03 Button oBtnCan Prompt STR0008 Size 30,10 Pixel Of oPnlBtnR Action ( cRet :=          ''       , oDlg:End()  )

	Activate MsDialog oDlg Centered

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAQRYNT0
Monta a query para relacionar os contratos envolvidos do caso ao efetuar lançamentos

@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAQRYNT0(cClien, cLoja, cCaso)
	Local cQuery   := ""

	cQuery := "SELECT NT0.NT0_FILIAL, NT0.NT0_COD, NT0.NT0_NOME, NT0.NT0_CCLIEN, NT0.NT0_CLOJA, NT0.R_E_C_N_O_ NT0RECNO "
	cQuery += " FROM " + RetSqlName("NT0") + " NT0 "
	cQuery += " WHERE NT0.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "
	cQuery +=    " AND NT0.NT0_COD IN ( SELECT NW3_CCONTR "
	cQuery +=                           " FROM " + RetSqlName("NW3") + " NW3 "
	cQuery +=                          " WHERE NW3.D_E_L_E_T_ = ' ' "
	cQuery +=                            " AND NW3.NW3_FILIAL = '" + xFilial( "NW3" ) + "' "
	cQuery +=                            " AND NW3.NW3_CJCONT IN (SELECT NW3_CJCONT "
	cQuery +=                                                     " FROM " + RetSqlName("NW3") + " NW3_2 "
	cQuery +=                                                    " WHERE NW3_2.NW3_CCONTR IN ( SELECT NUT.NUT_CCONTR "
	cQuery +=                                                                                  " FROM " + RetSqlName("NUT") + " NUT "
	cQuery +=                                                                                  " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery +=                                                                                    " AND NUT.NUT_FILIAL = '" + xFilial( "NUT" ) + "' "
	cQuery +=                                                                                    " AND NUT.NUT_CCLIEN = '" + cClien + "' "
	cQuery +=                                                                                    " AND NUT.NUT_CLOJA  = '" + cLoja  + "' "
	cQuery +=                                                                                    " AND NUT.NUT_CCASO  = '" + cCaso  + "') "
	cQuery +=                                                   " ) "
	cQuery +=                         " ) "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JAF3NT0
Monta a consulta padrão de contratos envolvidos para o lançamento
@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAF3NT0(cClien, cLoja, cCaso)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := ''

	cQuery   := JAQRYNT0( cClien, cLoja, cCaso )
	cQuery   := ChangeQuery(cQuery, .F.)
	uRetorno := ''

	RestArea( aArea )

	If JurF3Qry( cQuery, 'JURNT0', 'NT0RECNO', @uRetorno )
		NT0->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAVLDNT0
Valida o contrato envolvido ao vincluar o contrato ao lançamento (digitando o código)

@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAVLDNT0(cMaster, cCpClien, cCpLoja, cCpCaso, cCpContr)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := ''
	Local cAlias   := GetNextAlias()
	Local oModel   := FWModelActive()
	Local cClien   := oModel:GetValue(cMaster, cCpClien)
	Local cLoja    := oModel:GetValue(cMaster, cCpLoja)
	Local cCaso    := oModel:GetValue(cMaster, cCpCaso)

	cQuery := JAQRYNT0(cClien, cLoja, cCaso )

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If (cAlias)->NT0_COD == oModel:GetValue(cMaster, cCpContr)
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	EndDo

	If !lRet
		JurMsgErro(STR0003) //Verificar????
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMotWO
Cria a tela para incluir o Motivo de Envio o cancelamento de WO

@param  cCampo   - Campo referente a operação "NUF_OBSEMI" ou "NUF_OBSCAN"
@param  cTitle   - Titulo da janela
@param  cTitObs  - Titulo do campo observação
@param  cTpLanc  - Tipo do Lançamento que está executando o WO
                   1 - TimeSheet
                   2 - Despesa
                   3 - Lançamento Tabelado
                   4 - Fatura
                   5 - Fixo
                   6 - Todos

@Return aRet     - Array com as informações Observação e Codigo do Motivo de WO

@author Luciano Pereira dos Santos
@since 26/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMotWO(cCpoObs, cTitle, cTitObs, cTpLanc)
Local aRet      := {}
Local cF3       := ""
Local lMot      := .F.
Local lObs      := .F.
Local bTitulo   := { |cCampo| SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)), AllTrim(X3Titulo()) }
Local oLayer    := FWLayer():New()
Local oMainColl := Nil

Local oDlg      := Nil
Local oCod      := Nil
Local cCod      := Criavar( 'NXV_COD', .F. )
Local oObs      := Nil
Local cObs      := Criavar( 'NUF_OBSEMI', .F. )
Local oMot      := Nil
Local cMotivo   := Criavar( 'NXV_DESC', .F. )

Default cTitle  := STR0045 // "Observação - W0"
Default cCpoObs := "NUF_OBSEMI"
Default cTitObs := Eval(bTitulo, cCpoObs) // Título
Default cTpLanc := "" // Tipo do Lançamento do WO

If cCpoObs == "NUF_OBSEMI"
	cCodWO  := 'NUF_CMOTEM'
	cMotivo := 'NUF_DMOTEM'
	cF3     := "NXVEMI"

ElseIf cCpoObs == "NUF_OBSCAN"
	cCodWO  := 'NUF_CMOTCA'
	cMotivo := 'NUF_DMOTCA'
	cF3     := "NXVCAN"
EndIf

// Variável estática do tipo de lançamento utilizado na consulta padrão de Motivo de WO
__cTpLanc := cTpLanc

lMot := X3OBRIGAT( cCodWO )
lObs := X3OBRIGAT( cCpoObs )

DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 200, 480 PIXEL // "Observação - W0"

oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oCod := TJurPnlCampo():New(005,005, 40, 22, oMainColl, , cCodWO, {|| }, {|| },,,,cF3)
oCod:SetChange({|| (cCod := oCod:Valor, oMot:Valor := JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_DESC"), oMot:Refresh()) })
oCod:SetValid({|| JurVldMot("1", lMot, lObs, cF3, cCod, cObs, cTpLanc) })

oMot := TJurPnlCampo():New(005,055, 170, 22, oMainColl, , cMotivo, {|| }, {|| },,,.F.,)

oObs := TJurPnlCampo():New(035,005, 220, 22, oMainColl, cTitObs, cMotivo, {|| }, {|| },,,,)
oObs:SetChange({|| (cObs := oObs:Valor)})

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
															{|| Iif(JurVldMot("2", lMot, lObs, cF3, cCod, cObs, cTpLanc), (aRet := {cObs, cCod}, oDlg:End()), .F.)},;
															{|| (oDlg:End())}, , /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

// Limpa variável estática do tipo de lançamento do Motivo de WO
__cTpLanc := ""

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldMot
Rotina de validação da tela para incluir o Motivo de Emissão / Cancelamento de WO
JurMotWO.

@param cOrig    - Origem da chamada da função
                  1 - Valid do campo de motivo do WO na tela
                  2 - Validação ao clicar do botão de confirmar o WO na tela
                  3 - Validação do motivo e observação inseridos na 
                      despesa durante a revisão da pré-fatura (LegalDesk)
                  4 - Validação motivo do WO no Lançamento (TS, DP ou LT)
@param lMot     - Indica se deve validar o preenchimento do Motivo de WO
@param lObs     - Indica se deve validar o preenchimento da Observação
@param cF3      - Consulta que será utilizada no campo de Motivo
                  NXVEMI - Emissão de WO
                  NXVCAN - Cancelamento de WO
@param cCod     - Código do motivo de WO
@param cObs     - Observação do WO
@param cTpLanc  - Tipo do Lançamento que está executando o WO
                  1 - TimeSheet
                  2 - Despesa
                  3 - Lançamento Tabelado
                  4 - Fatura
                  5 - Fixo
                  6 - Todos

@return lRet    - Informações válidas para realizar o WO

@author Luciano Pereira dos Santos
@since 27/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldMot(cOrig, lMot, lObs, cF3, cCod, cObs, cTpLanc)
Local lRet       := .T.
Local lNXVTpLanc := NXV->(ColumnPos("NXV_TPLANC")) > 0
Local cCampo     := ""
Local cAliasCpo  := ""
Local cMotTpLanc := ""
Local cDespCob   := ""
Local cTipo      := IIF(cF3 == "NXVEMI", "1", "2") // 1 = Emissão de WO / 2 - Cancelamento de WO
Local cLcTodos   := "6"
Local cMsgErro   := ""

Default cCod     := ""
Default cObs     := ""
Default cTpLanc  := ""

	Do Case
	Case cOrig == "1"
		If !Empty(cCod)
			cMsgErro := IIf(cTipo == "1", STR0043, STR0046) //"Por favor, informe um código de motivo válido para emissão de WO."#"Por favor, informe um código de motivo válido para cancelamento de WO."
			If JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TIPO") != cTipo
				lRet := JurMsgErro(cMsgErro)
			ElseIf lNXVTpLanc .And. !Empty(cTpLanc)
				cTpLanc += "|" + cLcTodos
				cMotTpLanc := JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TPLANC")
				If Empty(cMotTpLanc) .Or. !(cMotTpLanc $ cTpLanc)
					lRet := JurMsgErro(cMsgErro)
				EndIf
			EndIf
		EndIf

	Case cOrig == "2"
		If lMot
			cMsgErro := IIf(cTipo == "1", STR0043, STR0046) //"Por favor, informe um código de motivo válido para emissão de WO."#"Por favor, informe um código de motivo válido para cancelamento de WO."
			If Empty(cCod)
				lRet := JurMsgErro(cMsgErro)
			Else
				If JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TIPO") != cTipo
					lRet := JurMsgErro(cMsgErro)
				ElseIf lNXVTpLanc .And. !Empty(cTpLanc)
					cTpLanc += "|"+cLcTodos
					cMotTpLanc := JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TPLANC")
					If Empty(cMotTpLanc) .Or. !(cMotTpLanc $ cTpLanc) 
						lRet := JurMsgErro(cMsgErro)  // "Por favor, informe um código de motivo válido para emissão de WO."
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet .And. lObs .And. Empty(cObs)
			lRet := JurMsgErro(STR0044) // "Por favor, informe o campo de observação antes de confirmar."
		EndIf

		If lRet .And. lNXVTpLanc .And. !Empty(cTpLanc)
			cTpLanc += "|" + cLcTodos
			cMotTpLanc := JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TPLANC")
			If Empty(cMotTpLanc) .Or. !(cMotTpLanc $ cTpLanc)
				lRet := JurMsgErro(STR0043) // "Por favor, informe um código de motivo válido para emissão de WO."
			EndIf
		EndIf
	
	Case lNXVTpLanc .And. cOrig == "3" .And. cTipo == "1" // Observação de Despesa de Wo - Retirar
		
		cDespCob  := FwFldGet("NVY_COBRAR")

		If lRet
			If lMot // Valida o preenchimento do Motivo do WO
				If cDespCob == "1" // Despesa Cobrável
					lRet := JurMsgErro(STR0302) // "Não é possível informar código de motivo da revisão, quando despesa for cobrável"
				Else
					If JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TIPO") != cTipo
						lRet := JurMsgErro(STR0300) // "Por favor, informe um código de motivo da revisão válido para emissão de WO."
					Else
						cMotTpLanc := JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TPLANC") // Tipo do lançamento do Motivo
						cTpLanc    += "|" + cLcTodos

						If Empty(cMotTpLanc) .Or. !(cMotTpLanc $ cTpLanc)
							lRet := JurMsgErro(STR0300)  // "Por favor, informe um código de motivo da revisão válido para emissão de WO."
						EndIf
					EndIf
				EndIf
			ElseIf lObs .And. cDespCob == "1" // Valida o preenchimento da Observação do WO
				lRet := JurMsgErro(STR0301)  // "Não é possível informar observação da revisão, quando despesa for cobrável"
			EndIf
		EndIf

	Case lNXVTpLanc .And. cOrig == "4" .And. lMot .And. cTipo == "1"
		If Empty(cCod)
			cCampo := ReadVar()
			cCod   := FwFldGet(Substr(cCampo,4))
		EndIf
		If JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TIPO") != cTipo
			lRet := JurMsgErro(STR0043) // "Por favor, informe um código de motivo válido para emissão de WO."
		Else
			If Empty(cTpLanc)
				cAliasCpo := Substr(cCampo, 4, 3)
				Do Case
					Case cAliasCpo = "NUE"
						cTpLanc := "1"
					Case cAliasCpo = "NVY"
						cTpLanc := "2"
					Case cAliasCpo = "NV4"
						cTpLanc := "3"
					OtherWise
						cTpLanc := cLcTodos
				EndCase
			EndIf
			cTpLanc += "|" + cLcTodos
			cMotTpLanc := JurGetDados("NXV", 1, xFilial("NXV") + cCod, "NXV_TPLANC")
			If Empty(cMotTpLanc) .Or. !(cMotTpLanc $ cTpLanc)
				lRet := JurMsgErro(STR0043) // "Por favor, informe um código de motivo válido para emissão de WO."
			EndIf
		EndIf
	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAWOInclui
Cria o registro de WO para utilizar no WO caso e vincular aos lançamentos
Após utilizar a rotina é preciso chamar o ConfirmSX8

@Param aObs	 Array com as informações de Codigo do Motivo e Observação,
				também com o participante do ajuste caso seja via REST.

@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAWOInclui(aOBS)
	Local aArea    := GetArea()
	Local aAreaNUF := NUF->(GetArea())
	Local cWoCodig := GetSxEnum('NUF', 'NUF_COD')

	RecLock( 'NUF', .T. )
	NUF->NUF_FILIAL := xFilial('NUF')
	NUF->NUF_COD    := cWoCodig
	NUF->NUF_SITUAC := '1'
	NUF->NUF_DTEMI  := Date()
	NUF->NUF_USREMI := Iif(JurIsRest(), aOBS[3], __cUserId)
	NUF->NUF_OBSEMI := aOBS[1]
	NUF->NUF_CMOTEM := aOBS[2]
	NUF->NUF_PERFAT := 100.00
	NUF->(MsUnlock())

	RestArea( aAreaNUF )
	RestArea( aArea )

	J170GRAVA("NUF", xFilial("NUF") + cWoCodig, "3")

Return cWoCodig

//-------------------------------------------------------------------
/*/{Protheus.doc} JAWOCasInc
Inclui um registro no WO caso com os dados informados
Após utilizar a rotina é preciso chamar o ConfirmSX8

@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAWOCasInc(cWoCodig, cClien, cLoja, cCaso, cMoeda, nValorCaso)
	Local aArea      := GetArea()
	Local aAreaNUG   := NUG->(GetArea())
	Local cWoCasCod  := GetSxEnum('NUG', 'NUG_COD')

	RecLock( 'NUG', .T. )
	NUG->NUG_FILIAL  := xFilial('NUG')
	NUG->NUG_COD     := cWoCasCod
	NUG->NUG_CWO     := cWoCodig
	NUG->NUG_CCLIEN  := cClien
	NUG->NUG_CLOJA   := cLoja
	NUG->NUG_CCASO   := cCaso
	NUG->NUG_CMOEDA  := cMoeda
	NUG->NUG_VALOR   := nValorCaso
	NUG->(MsUnlock())

	RestArea( aAreaNUG )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JAWOLancto
Envia os Lanctos Tabelados filtrados para WO utilizando a barra de progresso.

@param  cTipo       Tipo do WO - 1 - Time-Sheet, 2 - Despesas, 3 - Tabelado
@param  aOBS        Array contendo a Observação e o codigo do motivo para o WO
@param  cFiltro     Filtro para envio dos lançamentos
@param  cDefFiltro  Filtro Default da tela que chama a rotina, caso haja

@Return ncountWO	Retorna a quantidade de lançamentos que sofreram WO

@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAWOLancto(nTipo, aOBS, cFiltro, cDefFiltro, cAliasTmp, aTimShePro, aTimeSNWo)
	Local nRet
	Default aTimShePro := {}
	Default aTimeSNWo := {}

	Processa( { || nRet := JAWOLancR(nTipo, aOBS, cFiltro, cDefFiltro, cAliasTmp, aTimShePro,aTimeSNWo) }, STR0029, STR0042, .F. )  //'Aguarde'###  "Enviando lançamentos para WO"

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAWOLancR
Envia os Lanctos Tabelados Filtradas para WO

@param 	nTipo		- Tipo do WO - 1 - Time-Sheet, 2 - Despesas, 3 - Tabelado
@param 	aOBS		- Array contendo a Observação e o codigo do motivo para o WO
@param 	cFiltro     - Filtro para envio dos lançamentos
@param 	cDefFiltro	- Filtro Default da tela que chama a rotina, caso haja
@param 	cAliasTmp	- Tabela temporia que sera processada
@param 	aTimShePro	- Codigo Time Sheet, Código WO e observações dos time sheets processados
@param 	aTimeSNWo	- Codigo Time Sheet sem WO Lançados e observações dos time sheets não processados
@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAWOLancR(nTipo, aOBS, cFiltro, cDefFiltro, cAliasTmp, aTimShePro, aTimeSNWo)
	Local aCampos    := {}
	Local cCaso      := ""
	Local cClien     := ""
	Local cLoja      := ""
	Local cWoCodig   := ""
	Local cCodWOLD   := ""
	Local nValorCaso := ""
	Local nCountWO   := 0

	Local aArea      := {}
	Local aAreaWO    := {}
	Local cAliasVinc := ""
	Local cCpCaso    := ""
	Local cCpClien   := ""
	Local cCpCodigo  := ""
	Local cCpLoja    := ""
	Local cCpMoeda   := ""
	Local cCpSituac  := ""
	Local cCpValor   := ""
	Local cCpVinculo := ""
	Local cCpCodLD   := ""
	Local cCpPartLD  := ""
	Local cCpMtWOLD  := ""
	Local cCpObWOLD  := ""
	Local cAlias     := "" // Alias do lançamento (Original)
	Local cAliasFil  := "" // Alias da tabela de filtro
	Local lFind      := .F.
	Local lIsRest    := JurIsRest() //Indica que o processo do WO é a partir do REST / Integração com a tela de Revisão do LD

	Local lCasoMae   := SuperGetMV("MV_JFSINC", .F., '2') == "1"  // Indica se utiliza a integração com o Legal Desk, consequentemente o conceito de Caso Mãe
	Local aIncLanc   := Array(13)                                 // Array com os dados adicionais para incluir o vinculo do WO

	Local cTpLanc    := ""
	Local aPfLog     := {}
	Local cMsgLog    := ""
	Local cCpPreFt   := ""
	Local cPrefat    := ""
	Local cPFVinc    := ""
	Local aDespesas  := {}
	Local nI         := 0
	Local cMoedaNac  := GetMv('MV_JMOENAC',, "01") // Gravação no caso de valores referentes a despesas.
	Local cCodigo    := ""
	Local aCasoMae   := {}
	Local lAlterada  := .F.
	Local cPartLog   := JurUsuario(__CUSERID)
	Local lAltHr     := NUE->(ColumnPos('NUE_ALTHR')) > 0
	Local lProcReg	 := .T. //Processa o Registro
	Local lJVlRc	 := ExistFunc("J143VlrRec")
	Local cLogPE	 := ""

	Default cDefFiltro := ""
	Default aTimShePro := {}
	Default aTimeSNWo := {} 

	/* Contabilização movida da função JAWOLancR() para a função JAWODspNWZ(). */

	If lIsRest //Tratamento para os campos novos preenchidos pela Revisão no LD

		AAdd(aCampos, {"NUE_CCLIEN", "NUE_CLOJA" , "NUE_CCASO" , "NUE_CMOEDA", "NUE_VALOR" , "NUE_SITUAC", "NUE_COD", "",;
		               ""          , ""          , "NUE_DATATS", "NUE_CPART1", "NUE_CPREFT",;
		               "NUE_CDWOLD", "NUE_PARTLD", "NUE_CMOTWO", "NUE_OBSWO"} ) //Time Sheet

		AAdd(aCampos, {"NVY_CCLIEN", "NVY_CLOJA" , "NVY_CCASO" , "NVY_CMOEDA", "NVY_VALOR" , "NVY_SITUAC", "NVY_COD", "",;
		               ""          , ""          , "NVY_DATA"  , ""          , "NVY_CPREFT",;
		               "NVY_CDWOLD", "NVY_PARTLD", "NVY_CMOTWO", "NVY_OBSWO"} ) //Despesas

		AAdd(aCampos, {"NV4_CCLIEN", "NV4_CLOJA" , "NV4_CCASO" ,"NV4_CMOEH" ,"NV4_VLHFAT","NV4_SITUAC","NV4_COD", "NUE",;
		               "NUE_CLTAB" , "NUE_COD"   , "NV4_DTCONC", "NV4_CPART"  , "NV4_CPREFT",;
		               "NV4_CDWOLD", "NV4_PARTLD", "NV4_CMOTWO", "NV4_OBSWO"} ) //Tabelados

	Else

		AAdd(aCampos, {"NUE_CCLIEN", "NUE_CLOJA", "NUE_CCASO" , "NUE_CMOEDA", "NUE_VALOR", "NUE_SITUAC", "NUE_COD", "",;
		               ""          , ""         , "NUE_DATATS", "NUE_CPART1", "NUE_CPREFT"} ) //Time Sheet

		AAdd(aCampos, {"NVY_CCLIEN","NVY_CLOJA", "NVY_CCASO", "NVY_CMOEDA", "NVY_VALOR" , "NVY_SITUAC", "NVY_COD", "",;
		               ""          , ""        , "NVY_DATA" , ""          , "NVY_CPREFT" } ) //Despesas

		AAdd(aCampos, {"NV4_CCLIEN", "NV4_CLOJA", "NV4_CCASO" , "NV4_CMOEH", "NV4_VLHFAT", "NV4_SITUAC", "NV4_COD", "NUE",;
		               "NUE_CLTAB" , "NUE_COD"  , "NV4_DTCONC", "NV4_CPART", "NV4_CPREFT" } ) //Tabelados

		ProcRegua( 0 )
		IncProc()
		IncProc()
		IncProc()

	EndIf

	cAlias := SubStr(aCampos[nTipo][1], 1, 3)

	If Empty(cAliasTmp)
		cAliasFil := cAlias

		cFiltro := cFiltro + " .AND. " + cAliasFil + "_FILIAL = '" + xFilial( cAliasFil ) + "'"
		cAux    := &( '{|| ' + cFiltro + ' }')
		(cAliasFil)->( dbSetFilter( cAux, cFiltro ) )
	Else
		cAliasFil := cAliasTmp
	EndIf

	aArea      := GetArea()
	aAreaWO    := (cAlias)->( GetArea() )         //Tabela original

	cCpClien   := aCampos[nTipo][01] //- Cliente
	cCpLoja    := aCampos[nTipo][02] //- Loja
	cCpCaso    := aCampos[nTipo][03] //- Caso
	cCpMoeda   := aCampos[nTipo][04] //- Moeda
	cCpValor   := aCampos[nTipo][05] //- Valor
	cCpSituac  := aCampos[nTipo][06] //- Situação
	cCpCodigo  := aCampos[nTipo][07] //- Cód do Lançamento
	cAliasVinc := aCampos[nTipo][08] //- Alias
	cCpVinculo := aCampos[nTipo][09] //- Cód do Lançamento
	cCpVincCod := aCampos[nTipo][10] //- Cód do Lançamento
	cCpDtlanc  := aCampos[nTipo][11] //- Data do Lançamento
	cCpPartic  := aCampos[nTipo][12] //- Participante do Lançamento
	cCpPreFt   := aCampos[nTipo][13] //- Pre Fatura

	(cAliasFil)->( dbSetOrder(2) )// ordena pelo cliente / loja /caso - tem que criar um WO por cliente
	(cAliasFil)->( dbgotop() )

	cClien := (cAliasFil)->&(cCpClien)
	cLoja  := (cAliasFil)->&(cCpLoja)
	cCaso  := (cAliasFil)->&(cCpCaso)
	cMoeda := (cAliasFil)->&(cCpMoeda)

	If lIsRest
		cCpCodLD   := aCampos[nTipo][14] //- Código do WO no Legal Desk
		cCpPartLD  := aCampos[nTipo][15] //- Participante do WO no Legal Desk
		cCpMtWOLD  := aCampos[nTipo][16] //- Código do Motivo de WO no Legal Desk
		cCpObWOLD  := aCampos[nTipo][17] //- Observação de WO no Legal Desk

		cCodWOLD   := (cAliasFil)->&(cCpCodLD)
	EndIf

	BEGIN TRANSACTION

		If !((cAliasFil)->( EOF() ))
			//Adiciona na NUF
			//Cria o número do WO
			nValorCaso := 0
			Do Case
			Case nTipo == 1
				cTpLanc := STR0095 // "TimeSheet"
			Case nTipo == 2
				cTpLanc := STR0096 // "Despesas"
			Case nTipo == 3
				cTpLanc := STR0097 // "Serviço Tabelado"
			EndCase

			AutoGrLog( I18N(STR0101 + CRLF, {cTpLanc} ) )  //#"Inclusão de WO - #1. "

		EndIf

		While !((cAliasFil)->( EOF() ))
			lProcReg   := .T.
			lFind      := .F.
			lWO        := .F.
			_lDisarmWO := .F.

			cPrefat := (cAliasFil)->&(cCpPreFt)
			cCodigo := (cAliasFil)->&(cCpCodigo)
			cMsgLog := ""
			cLogPE  := ""	

			If nTipo == 2 .AND. lJVlRc
				lProcReg	 := J143VlrRec(cAliasFil, @cLogPE)				
				If !lProcReg	
					If Empty(cLogPE)						
						cMsgLog := I18N(STR0297 + CRLF, {cCodigo}) //"Não foi possível efetuar o WO do lançamento '#1' "
					Else
						cMsgLog := cLogPE						
					EndIf
					AutoGrLog( cMsgLog )
					Aadd(aTimShePro, {cCodigo, "", cMsgLog})
					Aadd(aTimeSNWo, {cCodigo, cLogPE, cAlias, cCpCodigo})
					(cAliasFil)->( dbSkip() )
					Loop
				EndIf
				cMsgLog := ""
			EndIf

			If lIsRest
				aObs := {(cAliasFil)->&(cCpObWOLD), (cAliasFil)->&(cCpMtWOLD), (cAliasFil)->&(cCpPartLD)}
			EndIf

			If !Empty(cPrefat)

				If NX0->(dbSeek(xFilial('NX0') + cPreFat) )
					lAlterada := NX0->NX0_SITUAC == '3'
					If NX0->NX0_SITUAC $ '2|3|D|E'  // Pré-Fatura alterável - Análise | Alterada | Revisada | Revisada com Restrições

						RecLock("NX0", .F.)
						NX0->NX0_SITUAC := '3'
						NX0->NX0_USRALT := cPartLog
						NX0->NX0_DTALT  := Date()
						NX0->(MsUnlock())

						If !lAlterada
							J202HIST('99', cPreFat, cPartLog, I18N(STR0101, {cTpLanc} ) ) //#"Inclusão de WO - #1. "
						EndIf

						// Cancela as minutas da pré-fatura
						J202CanMin(cPrefat, I18N(STR0101, {cTpLanc} )) //#"Inclusão de WO - #1. "

						lWO := .T.

					ElseIf NX0->NX0_SITUAC == '4' // Definitivo

						cMsgLog := I18N(STR0100 + CRLF, {cCodigo, cPrefat, JurSitGet(NX0->NX0_SITUAC)}) // "Não foi possível efetuar o WO do lançamento #1 esta em pré-fatura #2 com situação #3."
						AutoGrLog( cMsgLog )
						Aadd(aTimShePro, {cCodigo, "", cMsgLog})

						(cAliasFil)->( dbSkip() )
						LOOP

					ElseIf NX0->NX0_SITUAC $ '5|6|7|9|A|B' // Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada

						cMsgLog := I18N(STR0099 + CRLF, {cCodigo, cPrefat, JurSitGet(NX0->NX0_SITUAC)}) // "Não foi possível efetuar o WO do lançamento #1 esta em minuta #2 com situação #3."
						AutoGrLog( cMsgLog )
						Aadd(aTimShePro, {cCodigo, "", cMsgLog})

						(cAliasFil)->( dbSkip() )
						LOOP

					ElseIf NX0->NX0_SITUAC $ 'C|F' //Em Revisão | Aguardando Sincronização
						If lIsRest
							lWO := .T.
						Else
							cMsgLog := I18N(STR0100 + CRLF, {cCodigo, cPrefat, JurSitGet(NX0->NX0_SITUAC)}) // "Não foi possível efetuar o WO do lançamento #1 esta em pré-fatura #2 com situação #3.
							AutoGrLog( cMsgLog )
							Aadd(aTimShePro, {cCodigo, "", cMsgLog})

							(cAliasFil)->( dbSkip() )
							LOOP
						EndIf
					EndIf
				EndIf

				If Empty(cWoCodig) .And. lWO
					cWoCodig   := JAWOInclui(aOBS)
				EndIf
			Else
				If Empty(cWoCodig)
					cWoCodig   := JAWOInclui(aOBS)
				EndIf

			EndIf

			//Se mudar o cliente, adiciona novo WO na NUF
			If (cAliasFil)->&(cCpClien) != cClien .OR. (cAliasFil)->&(cCpLoja) != cLoja
				If nTipo <> 2
					JAWOCasInc(cWoCodig, cClien, cLoja, cCaso, cMoeda, 0) // A especificação diz para demais lançamentos diferentes de desesas o valor deverá estar zerado.
				EndIf
				//Grava a tabela NWZ para Despesas
				If nTipo == 2
					JAWODspNWZ(cWoCodig)
				EndIf

				cWoCodig   := JAWOInclui(aOBS)
				nValorCaso := 0
				cClien     := (cAliasFil)->&(cCpClien)
				cLoja      := (cAliasFil)->&(cCpLoja)
				cCaso      := (cAliasFil)->&(cCpCaso)
				Iif(lIsRest, cCodWOLD := (cAliasFil)->&(cCpCodLD), )
			EndIf

			If (cAliasFil)->&(cCpClien) != cClien .Or. (cAliasFil)->&(cCpLoja) != cLoja .Or. (cAliasFil)->&(cCpCaso) != cCaso

				//Se mudar o caso, grava o total do caso e zera o valor do WO para o caso
				If nTipo <> 2
					JAWOCasInc(cWoCodig, cClien, cLoja, cCaso, cMoeda, 0) // A especificação diz para demais lançamentos diferentes de desesas o valor deverá estar zerado.
				EndIf
				nValorCaso := 0
				cClien     := (cAliasFil)->&(cCpClien)
				cLoja      := (cAliasFil)->&(cCpLoja)
				cCaso      := (cAliasFil)->&(cCpCaso)
				Iif(lIsRest, cCodWOLD := (cAliasFil)->&(cCpCodLD), )
			EndIf

			//Incluir na tabela de utilização do Lançamento:
			aIncLanc[1] := (cAliasFil)->&(cCpClien) //cliente
			aIncLanc[2] := (cAliasFil)->&(cCpLoja)  //loja
			aIncLanc[3] := (cAliasFil)->&(cCpCaso)  // caso
			aIncLanc[4] := (cAliasFil)->&(cCpMoeda) // Moeda do lançamento

			If cAlias $ "NUE"
				aIncLanc[5] := (cAliasFil)->NUE_VALORH  // Valor
			Else
				aIncLanc[5] := (cAliasFil)->&(cCpValor) // Valor
			EndIf

			If cAlias $ "NV4"
				aIncLanc[6] := (cAliasFil)->NV4_DTCONC   //data de conclusão do Tabelado
			Else
				aIncLanc[6] := (cAliasFil)->&(cCpDtlanc) //data de inclusão do Lançamento
			EndIf

			If cAlias $ "NUE|NV4"
				aIncLanc[7] := (cAliasFil)->&(cCpPartic) // participante
			Else
				aIncLanc[7] := ""
			EndIf
			If cAlias $ "NUE"
				aIncLanc[8] := (cAliasFil)->NUE_TEMPOR // Hora frac revisada
				aIncLanc[9] := (cAliasFil)->NUE_TEMPOL // Hora frac lançada
			Else
				aIncLanc[8] := 0
				aIncLanc[9] := 0
			EndIf
			If cAlias $ "NVY"
				aIncLanc[10] := (cAliasFil)->NVY_CTPDSP // codigo do tipo de despesa
			Else
				aIncLanc[10] := ""
			EndIf

			If lCasoMae
				aCasoMae := JACasMae(nTipo, aIncLanc[1], aIncLanc[2], aIncLanc[3]) // Tipo de Lançamento: 1-TS, 2-DP, 3-TB, Cliente, Loja, Caso
				If !Empty(aCasoMae)
					aIncLanc[11] := Alltrim(aCasoMae[1][1])
					aIncLanc[12] := Alltrim(aCasoMae[1][2])
					aIncLanc[13] := Alltrim(aCasoMae[1][3])
				EndIf
			EndIf

			If !lCasoMae .Or. Empty(aCasoMae)
				aIncLanc[11] := ""
				aIncLanc[12] := ""
				aIncLanc[13] := ""
			EndIf

			If JExistWO(cWoCodig, cAlias, (cAliasFil)->&(cCpCodigo))
				JAUsaLanc(cAlias, (cAliasFil)->&(cCpCodigo), '3', cWoCodig, __cUserId, aIncLanc)
			EndIf

			If nTipo == 2 // Gravação de valores referentes a despesas agrupados por moeda no campo NUG_VALOR.
				//                           Cliente                   Loja                      Caso                      Moeda
				nI := Ascan(aDespesas, {|x| x[1] == aIncLanc[1] .And. x[2] == aIncLanc[2] .And. x[3] == aIncLanc[3] .And. x[4] == aIncLanc[4]})
				If nI == 0           // Cliente     Loja        Caso        Moeda       Valor         Cd WO
					Aadd(aDespesas, {aIncLanc[1], aIncLanc[2], aIncLanc[3], aIncLanc[4], aIncLanc[5], cWoCodig})
				Else
					aDespesas[nI, 5] += aIncLanc[5] // VAlor
				EndIf
			EndIf

			//Inclui os lançamentos vinculados para WO - Previsto para Tabelado vinculado em TS
			//Necessários ajustes caso este processo seja feito para outras situações
			If !Empty(cAliasVinc) .AND. !Empty(cCpVinculo)
				cFiltro := ""
				cFiltro += cAliasVinc + "_CCLIEN == '" + (cAliasFil)->&(cCpClien) + "' .AND. "
				cFiltro += cAliasVinc + "_CLOJA  == '" + (cAliasFil)->&(cCpLoja)  + "' .AND. "
				cFiltro += cAliasVinc + "_CCASO  == '" + (cAliasFil)->&(cCpCaso)  + "' .AND. "
				cFiltro += cCpVinculo + " == '" + (cAliasFil)->&(cCpCodigo) + "'"

				cAux := &( '{|| ' + cFiltro + ' }')

				(cAliasVinc)->( dbSetFilter( cAux, cFiltro ) )
				(cAliasVinc)->( dbSetOrder(1) )// ordena pelo Código do Lancto
				(cAliasVinc)->( dbGoTop() )

				While !((cAliasVinc)->( EOF() ))

					aIncLanc[1]  := (cAliasVinc)->&(cAliasVinc + "_CCLIEN") // cliente
					aIncLanc[2]  := (cAliasVinc)->&(cAliasVinc + "_CLOJA")  // loja
					aIncLanc[3]  := (cAliasVinc)->&(cAliasVinc + "_CCASO")  // caso
					aIncLanc[4]  := (cAliasvinc)->&(cAliasVinc + "_CMOEDA") // Moeda do lançamento
					aIncLanc[5]  := (cAliasVinc)->&(cAliasVinc + "_VALORH") // Valor
					aIncLanc[6]  := (cAliasVinc)->&(cAliasVinc + "_DATATS") //data de inclusão do Lançamento
					aIncLanc[7]  := (cAliasVinc)->&(cAliasVinc + "_CPART1") // participante
					aIncLanc[8]  := (cAliasVinc)->&(cAliasVinc + "_TEMPOR") // Hora frac revisada
					aIncLanc[9]  := (cAliasVinc)->&(cAliasVinc + "_TEMPOL") // Hora frac lançada
					aIncLanc[10] := ""

					If JExistWO(cWoCodig, cAlias, (cAliasFil)->&(cCpCodigo))
						JAUsaLanc(cAliasVinc, (cAliasVinc)->&(cCpVincCod), '3', cWoCodig, __cUserId, aIncLanc)
					EndIf

					If nTipo == 2 // Gravação de valores referentes a despesas agrupados por moeda no campo NUG_VALOR.
						//                           Cliente                   Loja                      Caso                      Moeda
						nI := Ascan(aDespesas, {|x| x[1] == aIncLanc[1] .And. x[2] == aIncLanc[2] .And. x[3] == aIncLanc[3] .And. x[4] == aIncLanc[4]}) == 0
						If nI == 0           // Cliente     Loja        Caso        Moeda       Valor         Cd WO
							Aadd(aDespesas, {aIncLanc[1], aIncLanc[2], aIncLanc[3], aIncLanc[4], aIncLanc[5], cWoCodig})
						Else
							aDespesas[nI, 5] += aIncLanc[5] // VAlor
						EndIf
					EndIf

					cPFVinc := (cAliasVinc)->&(cAliasVinc + "_CPREFT")

					RecLock( cAliasVinc, .F. )
					(cAliasVinc)->&(cAliasVinc + "_SITUAC") := "2" //Cancelado
					(cAliasVinc)->&(cAliasVinc + "_CPREFT") := ""  //Cod da Pre fatura
					(cAliasVinc)->(MsUnlock())

					If !Empty(cPFVinc)
						NW0->(DbSetOrder(1)) // NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
						If NW0->( dbSeek( xFilial("NW0") + (cAliasVinc)->&(cAliasVinc + "_COD") + '1' + cPFVinc) )
							RecLock("NW0", .F.)
							NW0->NW0_CANC := "1"
							NW0->(MsUnLock())
						EndIf
					EndIf

					(cAliasVinc)->( dbSkip() )
				EndDo
				(cAliasVinc)->( dbClearFilter() )
			EndIf

			If !Empty( cAliasTmp )

				DbSelectArea(cAlias)
				(cAlias)->(DbSetOrder(1))
				If (cAlias)->( dbSeek( xFilial(cAlias) + (cAliasFil)->&(cCpCodigo) ) )
					lFind := .T.
				EndIf
			Else
				lFind := .T.
			EndIf

			If lFind

				Do Case
				Case nTipo == 1
					cTpLanc := 'TS'
				Case nTipo == 2
					cTpLanc := 'DP'
				Case nTipo == 3
					cTpLanc := 'LT'
				EndCase

				//Ajusta a situação do Lançamento
				RecLock( cAlias, .F. )
				(cAlias)->&(cCpSituac) := '2' //<- Insere como WO ->
				(cAlias)->&(cCpPreFt)  := ''  //<- Cod da Pre fatura ->
				If cAlias $ "NUE"
					NUE->NUE_OK     := " "
					NUE->NUE_CUSERA := IIf(lIsRest .And. !Empty((cAliasFil)->&(cCpPartLD)), (cAliasFil)->&(cCpPartLD), cPartLog )
					NUE->NUE_ALTDT  := Date()
					If lAltHr
						NUE->NUE_ALTHR := Time()
					EndIf
				EndIf
				(cAlias)->(DbCommit())
				(cAlias)->(MsUnlock())

				//Grava na fila de sincronização a alteração
				J170GRAVA(cAlias, xFilial(cAlias) + (cAliasFil)->&(cCpCodigo), "4")

				nValorCaso += (cAlias)->&(cCpValor)

				JACanVinc(cTpLanc, cPrefat, (cAliasFil)->&(cCpCodigo))  //Cancela o vinculo do histórico do lançamento caso esteja em pré-fatura

				If !lIsRest .And. ( !Empty(cPrefat)) .And. JurLancPre(cPrefat) < 1 // Não executa o cancelamento da pré quando for via REST
					JA202CANPF(cPrefat)
					J202HIST('5', cPrefat, JurUsuario(__CUSERID)) //Insere o Histórico na pré-fatura
					AutoGrLog( I18N(STR0098 + CRLF, {cPrefat}) )  //<- A pré-fatura #1 foi cancelada por não conter mais lançamentos."
				EndIf

				aPfLog := JA202VERPRE((cAliasFil)->&(cCpClien), (cAliasFil)->&(cCpLoja), (cAliasFil)->&(cCpCaso), (cAliasFil)->&(cCpDtlanc), cTpLanc)

				JurLogLanc(aPfLog, cPrefat, 4, .F., .T.)

				//Carrega codigo de time sheet que proccesso WO corretamente
				Aadd(aTimShePro, {cCodigo, cWoCodig, ""})
				nCountWO++
			EndIf

			(cAliasFil)->( dbSkip() )
		EndDo

		If nTipo == 2 // Gravação de valores referentes a despesas agrupados por moeda no campo NUG_VALOR.
			For nI := 1 To Len(aDespesas)
				//              Código WO  , Cod. Cliente    , Loja Cliente    , Numero do Caso  , Moeda           , Valor na Moeda.
				JAWOCasInc(aDespesas[nI, 6], aDespesas[nI, 1], aDespesas[nI, 2], aDespesas[nI, 3], aDespesas[nI, 4], aDespesas[nI, 5])
			Next
			//Grava a tabela NWZ para Despesas
			JAWODspNWZ(cWoCodig)
		Else  // Para os demais tipos de WO deverá ser gravado a moeda padrão do parâmetro MV_JMOENAC, e o valor deverá ser sempre zero.
			JAWOCasInc(cWoCodig, cClien, cLoja, cCaso, cMoedaNac, 0)
		EndIf

		If Empty(cAliasTmp)
			If Empty(cDefFiltro)
				(cAliasFil)->( dbClearFilter() )
			Else
				cAux := &( "{|| " + cDefFiltro + " }") //Filtro padrão - somente lançamentos ativos...
				(cAliasFil)->( dbSetFilter( cAux, cDefFiltro ) )
			EndIf
		EndIf

		While GetSX8Len() > 0
			ConfirmSX8()
		EndDo

	END TRANSACTION

	RestArea( aAreaWO )
	RestArea( aArea )

Return nCountWO

//-------------------------------------------------------------------
/*/{Protheus.doc} JACanVinc(cTpLanc, cPrefat, cCodigo, lCanVinc )
Cancela o vinculo do lançamento na pré-fatura.

@param 	cTpLanc		Tipo do lançamento 'TS' - Time Sheet; 'DP' - Despesas; 'LT' - Lançamento Tabelado
@param 	cPrefat		Numero das pré-fatura
@param 	cCodigo		Código do lançamento
@param 	lCanVinc    Se .T. cancela o vinculo do lançamento na pré-fatura. Padrão é .T.

@Return Nil

@author Luciano Pereira dos Santos
@since 10/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JACanVinc(cTpLanc, cPrefat, cCodigo, lCanVinc)
Local aArea      := GetArea()
Local aAreaNW0   := NW0->(GetArea())
Local aAreaNVZ   := NVZ->(GetArea())
Local aAreaNW4   := NW4->(GetArea())
Local aAreaNWE   := NWE->(GetArea())
Local aAreaNWD   := NWD->(GetArea())

Default lCanVinc := .T.

Do Case
Case cTpLanc == 'TS'
	NW0->(dbSetOrder(1)) //NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
	If NW0->(dbseek(xFilial('NW0') + cCodigo + '1'))
		While !NW0->(EOF()) .And. NW0->(NW0_FILIAL + NW0_CTS + NW0_SITUAC) == xFilial('NW0') + cCodigo + '1'
			If ((NW0->NW0_PRECNF == cPrefat) .And. lCanVinc) .Or.;
			   (!Empty(NW0->NW0_PRECNF) .And. JurGetDados("NX0", 1, xFilial("NX0") + NW0->NW0_PRECNF, "NX0_SITUAC") == '1')
				RecLock('NW0', .F.)
				NW0->NW0_CANC := "1"
				NW0->(MsUnLock())
				NW0->(DbCommit())
			EndIf
			NW0->(DbSkip())
		EndDo
	EndIf

Case cTpLanc == 'DP'
	NVZ->(dbSetOrder(1)) //NVZ_FILIAL, NVZ_CDESP, NVZ_SITUAC, NVZ_PRECNF, NVZ_CFATUR, NVZ_CESCR, NVZ_CWO
	If NVZ->( dbseek( xFilial('NVZ') + cCodigo + '1'))
		While !NVZ->(EOF()) .And. NVZ->(NVZ_FILIAL + NVZ_CDESP + NVZ_SITUAC) == xFilial('NVZ') + cCodigo + '1'
			If ((NVZ->NVZ_PRECNF == cPrefat) .And. lCanVinc) .Or.;
			    (!Empty(NVZ->NVZ_PRECNF) .And. JurGetDados("NX0", 1, xFilial("NX0") + NVZ->NVZ_PRECNF, "NX0_SITUAC") == '1')
				RecLock('NVZ', .F.)
				NVZ->NVZ_CANC := "1"
				NVZ->(MsUnLock())
				NVZ->(DbCommit())
			EndIf
			NVZ->(DbSkip())
		EndDo
	EndIf

Case cTpLanc == 'LT'
	NW4->( dbSetOrder(4) ) //NW4_FILIAL, NW4_CLTAB, NW4_SITUAC, NW4_PRECNF
	If NW4->( dbseek( xFilial('NW4') + cCodigo + '1'))
		While !NW4->(EOF()) .And. NW4->(NW4_FILIAL + NW4_CLTAB + NW4_SITUAC) == xFilial('NW4') + cCodigo + '1'
			If ((NW4->NW4_PRECNF == cPrefat) .And. lCanVinc) .Or.;
			   (!Empty(NW4->NW4_PRECNF) .And. JurGetDados("NX0", 1, xFilial("NX0") + NW4->NW4_PRECNF, "NX0_SITUAC") == '1')
				RecLock('NW4', .F.)
				NW4->NW4_CANC := "1"
				NW4->(MsUnLock())
				NW4->(DbCommit())
			EndIf
			NW4->(DbSkip())
		EndDo
	EndIf

Case cTpLanc == 'FX'
	NWE->(DbSetOrder(1)) //NWE_FILIAL, NWE_CFIXO, NWE_SITUAC, NWE_PRECNF, NWE_CFATUR, NWE_CESCR, NWE_CWO
	If NWE->(dbSeek( xFilial("NWE") + cCodigo + "1"))
		While !NWE->(EOF()) .And. NWE->(NWE_FILIAL + NWE_CFIXO + NWE_SITUAC) == xFilial('NWE') + cCodigo + '1'
			If ((NWE->NWE_PRECNF == cPrefat) .And. lCanVinc) .Or.;
			   (!Empty(NWE->NWE_PRECNF) .And. JurGetDados("NX0", 1, xFilial("NX0") + NWE->NWE_PRECNF, "NX0_SITUAC") == '1')
				RecLock("NWE", .F.)
				NWE->NWE_CANC := "1"
				NWE->(MsUnlock())
				NWE->(DbCommit())
			EndIf
			NWE->(DbSkip())
		EndDo
	EndIf

Case cTpLanc == 'FA'
	NWD->(DbSetOrder(1)) //NWD_FILIAL, NWD_CFTADC, NWD_SITUAC, NWD_PRECNF, NWD_CFATUR, NWD_CESCR, NWD_CWO
	If NWD->(DbSeek( xFilial("NWD") + cCodigo + "1" ))
		While !NWD->(EOF()) .And. NWD->(NWD_FILIAL + NWD_CFTADC + NWD_SITUAC) == xFilial('NWD') + cCodigo + '1'
			If ((NWD->NWD_PRECNF == cPrefat) .And. lCanVinc) .Or.;
			   (!Empty(NWD->NWD_PRECNF) .And. JurGetDados("NX0", 1, xFilial("NX0") + NWD->NWD_PRECNF, "NX0_SITUAC") == '1')
				RecLock("NWD", .F.)
				NWD->NWD_CANC := "1"
				NWD->(MsUnlock())
				NWD->(DbCommit())
			EndIf
			NWD->(DbSkip())
		EndDo
	EndIf
EndCase

RestArea( aAreaNW0 )
RestArea( aAreaNVZ )
RestArea( aAreaNW4 )
RestArea( aAreaNWE )
RestArea( aAreaNWD )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JAWOFATURA
Envia os Lanctos da Fatura para WO.

@Param  cFiltro, expressão de filtro da tabela de fatura
@Param  aObs   , Dados do motivo de WO da fatura

@Return lRet   Indica se a operação foi bem sucedida ou não.

@author David G. Fernandes
@since 28/12/2009
/*/
//-------------------------------------------------------------------
Function JAWOFATURA(cFiltro, aOBS)
	Local nRet       := 0
	Local cWOCodig   := ""
	Local cQuery     := ""
	Local nLanctos   := 0
	Local aArea      := GetArea()
	Local aAreaNXA   := NXA->( GetArea() )
	Local aAreaNUF   := NUF->( GetArea() )
	Local aAreaNW0   := NW0->( GetArea() )
	Local aAreaNVZ   := NVZ->( GetArea() )
	Local aAreaNW4   := NW4->( GetArea() )
	Local aAreaNWC   := NWC->( GetArea() )
	Local aAreaNWD   := NWD->( GetArea() )
	Local aAreaNWE   := NWE->( GetArea() )
	Local aAreaNXG   := NXG->( GetArea() )
	Local aAreaSE1   := SE1->( GetArea() )
	Local cMsg       := ""
	Local lWODesp    := .F.
	Local cNumFatura := ""
	Local cCodEscr   := ""
	Local dResult    := stod("  /  /    ")
	Local nPerFat    := 0
	Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
	Local lRet       := .T.
	Local cClient    := ""
	Local cLoja      := ""
	Local cCaso      := ""
	Local dDtlanc    := stod("  /  /    ")
	Local cPartic    := ""
	Local cTpDes     := ""
	Local nVAlor     := 0
	Local cMoeda     := ""
	Local nTempoR    := 0
	Local nTempoL    := 0
	Local nCotac1    := 0
	Local nCotac2    := 0
	Local aLanc      := {}
	Local nRec       := 0
	Local cCodTS     := ""
	Local cCodDP     := ""
	Local cCodLT     := ""
	Local cCodFA     := ""
	Local aDespesas  := {} // Gravação no caso de valores referentes a despesas.
	Local nI         := 0
	Local nCotac3    := 0
	Local nCotac4    := 0
	Local nVAlorD    := 0
	Local nVAlorT    := 0

	//Variaveis para novos campos reais da NWE
	Local nValorB    := 0
	Local nValorA    := 0
	Local dDataIn    := ctod('')
	Local dDataFi    := ctod('')

	//Informações para gravação do Caso Mãe no WO
	Local cCliMae    := ""
	Local cLojaMae   := ""
	Local cCasoMae   := ""
	Local aCasoMae   := {}
	Local lCasoMae   := SuperGetMV("MV_JFSINC", .F., '2') == "1"  // Indica se utiliza a integração com o Legal Desk, consequentemente o conceito de Caso Mãe
	Local lCpoCotac  := NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
	Local lVincTs    := NW0->(ColumnPos('NW0_DTVINC')) > 0 //Proteção
	Local dVincTs    := ctod('')
	Local lAltHr     := NUE->(ColumnPos('NUE_ALTHR')) > 0
	Local cPreFat    := Space(TamSx3('NW0_PRECNF')[1])
	Local lTemTit    := .F.
	Local lBaixas    := .F.
	Local aSE1       := {}
	
	Default cFiltro := ""
	Default aOBS    := {}

	If Empty(cFiltro)
		cFiltro := "NXA_TIPO == 'FT' .And. NXA_SITUAC == '1' .And. NXA_FILIAL == '" + xFilial( "NXA" ) + "')"
	Else
		cFiltro := cFiltro + " .And. (NXA_FILIAL = '" + xFilial( "NXA" ) + "')"
	EndIf

	NXA->( dbSetFilter( &( '{|| ' + cFiltro + ' }'), cFiltro ) )
	NXA->( dbSetOrder(1) )
	NXA->( dbGoTop() )

	While !(NXA->( EOF() ))

		cNumFatura := NXA->NXA_COD
		cCodEscr   := NXA->NXA_CESCR
		nPerFat    := NXA->NXA_PERFAT
		lTemTit    := NXA->NXA_TITGER == '1'

		dResult:= JURA203G( 'FT', Date(), 'FATCAN' )[1]
		If Empty(dResult) .Or. (dResult < NXA->NXA_DTEMI)
			dResult := Date()
		EndIf

		If NXA->NXA_SITUAC == '1'
			
			If lTemTit
				aSE1 := J204Baixas() // Obtem títulos da fatura

				//Valida a existencia de baixas na fatura - manter mesmo havendo o filtro de tela, para caso seja feita baixa após a abertura da tela 
				lBaixas := aScan(aSE1, {|x| x[2] == "S"}) > 0 //Busca baixas diferente de compensação nos títulos da fatura
				
				If lBaixas
					cMsg += I18N(STR0028, {cCodEscr + "-" + cNumFatura}) + CRLF //"A fatura: #1 possui baixas e por isso não é possível realizar o WO."
					JurFreeArr(aSE1)
					NXA->(DbSkip())
					Loop
				EndIf
			EndIf

			// Verifica se já possui documento fiscal gerado
			// Manter mesmo havendo o filtro de tela, para caso seja feita a emissão do documento fiscal após a abertura da tela
			If NXA->NXA_NFGER == "1"
				cMsg := I18N(STR0298, {cCodEscr + "-" + cNumFatura}) + CRLF //"A fatura: #1 possui Documento Fiscal gerado e por isso não é possível realizar o WO."
				JurFreeArr(aSE1)
				NXA->(DbSkip())
				Loop
			EndIf

			BEGIN TRANSACTION

				If lTemTit
					If FindFunction("J204CanBxCP") .And. ! J204CanBxCP(aSE1, NXA->NXA_CESCR) // Cancelamento de baixas por compensação
						DisarmTransaction()
						Break
					EndIf
				EndIf

				//Cancela a Fatura
				RecLock("NXA", .F.)
				NXA->NXA_SITUAC  := '2'
				NXA->NXA_WO      := '1'
				NXA->NXA_DTCANC  := dResult
				NXA->(MsUnlock())

				//Cria o Num de WO para a Fatura
				cWoCodig := JAWOInclui(aOBS)

				// Time Sheets
				aLanc := JurGetFtLan("NW0", cNumFatura, cCodEscr)

				For nRec := 1 To Len(aLanc)
					//Cancela o lancto Faturado
					NW0->( dbGoTo( aLanc[nRec][1] ) )
					RecLock("NW0", .F.)
					NW0->NW0_CANC := '1'
					NW0->(MsUnlock())

					cCodTS   := NW0->NW0_CTS
					cClient  := NW0->NW0_CCLIEN
					cLoja    := NW0->NW0_CLOJA
					cCaso    := NW0->NW0_CCASO
					dDtlanc  := NW0->NW0_DATATS
					cPartic  := NW0->NW0_CPART1
					nVAlor   := NW0->NW0_VALORH
					cMoeda   := NW0->NW0_CMOEDA
					nTempoR  := NW0->NW0_TEMPOR
					nTempoL  := NW0->NW0_TEMPOL
					nCotac1  := NW0->NW0_COTAC1
					nCotac2  := NW0->NW0_COTAC2
					If  lVincTs
						dVincTs := NW0->NW0_DTVINC
					EndIf
					If lCasoMae
						aCasoMae := JACasMae(1, cClient, cLoja, cCaso) // Tipo de Lançamento: 1-TS, 2-DP, 3-TB, Cliente, Loja, Caso
						If !Empty(aCasoMae)
							cCliMae  := Alltrim(aCasoMae[1][1])
							cLojaMae := Alltrim(aCasoMae[1][2])
							cCasoMae := Alltrim(aCasoMae[1][3])
						Else
							cCliMae  := ""
							cLojaMae := ""
							cCasoMae := ""
						EndIf
					EndIf

					// NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
					If Empty(JurGetDados("NW0", 1, xFilial("NW0") + cCodTS + "3" + cPreFat + cNumFatura + cCodEscr + cWOCodig, "NW0_CTS"))
						// Adiciona o lancto no WO
						RecLock("NW0", .T.)
						NW0->NW0_FILIAL     := xFilial("NW0")
						NW0->NW0_CTS        := cCodTS
						NW0->NW0_CFATUR     := cNumFatura
						NW0->NW0_CESCR      := cCodEscr
						NW0->NW0_SITUAC     := '3'   //WO
						NW0->NW0_CANC       := '2'
						NW0->NW0_CWO        := cWOCodig
						NW0->NW0_CODUSR     := __CUSERID
						NW0->NW0_CCLIEN     := cClient
						NW0->NW0_CLOJA      := cLoja
						NW0->NW0_CCASO      := cCaso
						NW0->NW0_DATATS     := dDtlanc
						NW0->NW0_CPART1     := cPartic
						NW0->NW0_VALORH     := nVAlor
						NW0->NW0_CMOEDA     := cMoeda
						NW0->NW0_TEMPOR     := nTempoR
						NW0->NW0_TEMPOL     := nTempoL
						NW0->NW0_COTAC1     := nCotac1
						NW0->NW0_COTAC2     := nCotac2
						If lCpoCotac
							NW0->NW0_COTAC  := JurCotac(nCotac1, nCotac2)
						EndIf
						If lCasoMae .And. NW0->(ColumnPos("NW0_CCLICM")) > 0
							NW0->NW0_CCLICM := cCliMae
							NW0->NW0_CLOJCM := cLojaMae
							NW0->NW0_CCASCM := cCasoMae
						EndIf
						If lVincTs
							NW0->NW0_DTVINC := dVincTs
						EndIf
						NW0->(MsUnlock())
						nLanctos++

						//Ajusta as informações de alteração no TS
						NUE->( dbSetOrder(1) )
						NUE->( dbSeek(xFilial("NUE") + cCodTS))
						RecLock("NUE", .F.)
						NUE->NUE_CUSERA := JurUsuario(__CUSERID)
						NUE->NUE_ALTDT  := Date()
						If lAltHr
							NUE->NUE_ALTHR := Time()
						EndIf
						NUE->(MsUnlock())
					EndIf

				Next nRec

				//Despesas
				aLanc := JurGetFtLan("NVZ", cNumFatura, cCodEscr)

				For nRec := 1 To Len(aLanc)
					//Marca que foram efetuados WOs de Despesas
					lWODesp := .T.

					//Cancela o lancto Faturado
					NVZ->( dbGoTo( aLanc[nRec][1] ) )
					RecLock("NVZ", .F.)
					NVZ->NVZ_CANC := '1'
					NVZ->(MsUnlock())

					cCodDP      := NVZ->NVZ_CDESP
					cTpDes      := NVZ->NVZ_CTPDSP
					cClient     := NVZ->NVZ_CCLIEN
					cLoja       := NVZ->NVZ_CLOJA
					cCaso       := NVZ->NVZ_CCASO
					dDtlanc     := NVZ->NVZ_DTDESP
					nValor      := NVZ->NVZ_VALORD
					cMoeda      := NVZ->NVZ_CMOEDA
					nCotac1     := NVZ->NVZ_COTAC1
					nCotac2     := NVZ->NVZ_COTAC2
					If lCasoMae
						aCasoMae := JACasMae(2, cClient, cLoja, cCaso) // Tipo de Lançamento: 1-TS, 2-DP, 3-TB, Cliente, Loja, Caso
						If !Empty(aCasoMae)
							cCliMae  := Alltrim(aCasoMae[1][1])
							cLojaMae := Alltrim(aCasoMae[1][2])
							cCasoMae := Alltrim(aCasoMae[1][3])
						Else
							cCliMae  := ""
							cLojaMae := ""
							cCasoMae := ""
						EndIf
					EndIf

					// Gravação no caso de valores referentes a despesas agrupados por moeda.
					nI := Ascan(aDespesas, {|x| x[1] == cClient .And. x[2] == cLoja .And. x[3] == cCaso .And. x[4] == cMoeda})
					If nI == 0
						Aadd(aDespesas, {cClient, cLoja, cCaso, cMoeda, nVAlor})
					Else
						aDespesas[nI, 5] += nVAlor
					EndIf

					//Adiciona o lancto no WO
					RecLock("NVZ", .T.)
					NVZ->NVZ_FILIAL     := xFilial("NVZ")
					NVZ->NVZ_CDESP      := cCodDP
					NVZ->NVZ_CFATUR     := cNumFatura
					NVZ->NVZ_CESCR      := cCodEscr
					NVZ->NVZ_SITUAC     := '3'     //WO
					NVZ->NVZ_CANC       := '2'
					NVZ->NVZ_CWO        := cWOCodig
					NVZ->NVZ_CODUSR     := __CUSERID
					NVZ->NVZ_CTPDSP     := cTpDes
					NVZ->NVZ_CCLIEN     := cClient
					NVZ->NVZ_CLOJA      := cLoja
					NVZ->NVZ_CCASO      := cCaso
					NVZ->NVZ_DTDESP     := dDtlanc
					NVZ->NVZ_VALORD     := nVAlor
					NVZ->NVZ_CMOEDA     := cMoeda
					NVZ->NVZ_COTAC1     := nCotac1
					NVZ->NVZ_COTAC2     := nCotac2
					If lCpoCotac
						NVZ->NVZ_COTAC  := JurCotac(nCotac1, nCotac2)
					EndIf
					If lCasoMae .And. NVZ->(ColumnPos("NVZ_CCLICM")) > 0
						NVZ->NVZ_CCLICM := cCliMae
						NVZ->NVZ_CLOJCM := cLojaMae
						NVZ->NVZ_CCASCM := cCasoMae
					EndIf
					NVZ->(MsUnlock())
					nLanctos++

				Next nRec

				//Tabelados
				aLanc := JurGetFtLan("NW4", cNumFatura, cCodEscr)

				For nRec := 1 To Len(aLanc)
					//Cancela o lancto Faturado
					NW4->( dbGoTo( aLanc[nRec][1] ) )
					RecLock("NW4", .F.)
					NW4->NW4_CANC := '1'
					NW4->(MsUnlock())

					cCodLT   := NW4->NW4_CLTAB
					cClient  := NW4->NW4_CCLIEN
					cLoja    := NW4->NW4_CLOJA
					cCaso    := NW4->NW4_CCASO
					dDtlanc  := NW4->NW4_DTCONC
					cPartic  := NW4->NW4_CPART1
					nVAlor   := NW4->NW4_VALORH
					cMoeda   := NW4->NW4_CMOEDH
					nCotac1  := NW4->NW4_COTAC1
					nCotac2  := NW4->NW4_COTAC2
					If lCasoMae
						aCasoMae := JACasMae(3, cClient, cLoja, cCaso) // Tipo de Lançamento: 1-TS, 2-DP, 3-TB, Cliente, Loja, Caso
						If !Empty(aCasoMae)
							cCliMae  := Alltrim(aCasoMae[1][1])
							cLojaMae := Alltrim(aCasoMae[1][2])
							cCasoMae := Alltrim(aCasoMae[1][3])
						Else
							cCliMae  := ""
							cLojaMae := ""
							cCasoMae := ""
						EndIf
					EndIf

					//Adiciona o lancto no WO
					RecLock("NW4", .T.)
					NW4->NW4_FILIAL     := xFilial("NW4")
					NW4->NW4_CLTAB      := cCodLT
					NW4->NW4_CFATUR     := cNumFatura
					NW4->NW4_CESCR      := cCodEscr
					NW4->NW4_SITUAC     := '3'     //WO
					NW4->NW4_CANC       := '2'
					NW4->NW4_CWO        := cWOCodig
					NW4->NW4_CODUSR     := __CUSERID
					NW4->NW4_CCLIEN     := cClient
					NW4->NW4_CLOJA      := cLoja
					NW4->NW4_CCASO      := cCaso
					NW4->NW4_DTCONC     := dDtlanc
					NW4->NW4_CPART1     := cPartic
					NW4->NW4_VALORH     := nVAlor
					NW4->NW4_CMOEDH     := cMoeda
					NW4->NW4_COTAC1     := nCotac1
					NW4->NW4_COTAC2     := nCotac2
					If lCpoCotac
						NW4->NW4_COTAC  := JurCotac(nCotac1, nCotac2)
					EndIf
					If lCasoMae .And. NW4->(ColumnPos("NW4_CCLICM")) > 0
						NW4->NW4_CCLICM := cCliMae
						NW4->NW4_CLOJCM := cLojaMae
						NW4->NW4_CCASCM := cCasoMae
					EndIf
					NW4->(MsUnlock())
					nLanctos++

				Next nRec

				//Parc. Fat. Adic
				aLanc := JurGetFtLan("NWD", cNumFatura, cCodEscr)

				For nRec := 1 To Len(aLanc)
					//Cancela o lancto Faturado
					NWD->( dbGoTo( aLanc[nRec][1] ) )
					RecLock("NWD", .F.)
					NWD->NWD_CANC := '1'
					NWD->(MsUnlock())
					cCodFA  := NWD->NWD_CFTADC
					nCotac1 := NWD->NWD_COTAC1
					nVAlor  := NWD->NWD_VALORH
					nCotac2 := NWD->NWD_COTAC2
					nCotac3 := NWD->NWD_COTAC3
					nVAlorD := NWD->NWD_VALORD
					nCotac4 := NWD->NWD_COTAC4
					nVAlorT := NWD->NWD_VALORT

					//Adiciona o lancto no WO
					RecLock("NWD", .T.)
					NWD->NWD_FILIAL := xFilial("NWD")
					NWD->NWD_CFTADC := cCodFA
					NWD->NWD_CFATUR := cNumFatura
					NWD->NWD_CESCR  := cCodEscr
					NWD->NWD_SITUAC := '3'     //WO
					NWD->NWD_CANC   := '2'
					NWD->NWD_CWO    := cWOCodig
					NWD->NWD_CODUSR := __CUSERID
					NWD->NWD_VALORH := nVAlor //Honorarios
					NWD->NWD_COTAC1 := nCotac1 //Cotação honorarios
					NWD->NWD_COTAC2 := nCotac2 //Cotação Fatura
					NWD->NWD_VALORD := nVAlorD //Despesa
					NWD->NWD_COTAC3 := nCotac3 //Cotação Despesa
					NWD->NWD_VALORT := nVAlorT //Tabelado
					NWD->NWD_COTAC4 := nCotac4 //Cotação Tabelado

					NWD->(MsUnlock())
					nLanctos++

				Next nRec

				//Par. Fixo
				aLanc := JurGetFtLan("NWE", cNumFatura, cCodEscr)

				For nRec := 1 To Len(aLanc)
					//Cancela o lancto Faturado
					NWE->( dbGoTo( aLanc[nRec][1] ))
					RecLock("NWE", .F.)
					NWE->NWE_CANC := '1'
					NWE->(MsUnlock())

					cCodFA  := NWE->NWE_CFIXO
					cMoeda  := NWE->NWE_CMOEDA
					nValorB := NWE->NWE_VALORB
					nValorA := NWE->NWE_VALORA
					dDataIn := NWE->NWE_DATAIN
					dDataFi := NWE->NWE_DATAFI
					nCotac1 := NWE->NWE_COTAC1
					nCotac2 := NWE->NWE_COTAC2

					//Adiciona o lancto no WO
					RecLock("NWE", .T.)
					NWE->NWE_FILIAL     := xFilial("NWE")
					NWE->NWE_CFIXO      := cCodFA
					NWE->NWE_CFATUR     := cNumFatura
					NWE->NWE_CESCR      := cCodEscr
					NWE->NWE_SITUAC     := '3' //WO
					NWE->NWE_CANC       := '2'
					NWE->NWE_CMOEDA     := cMoeda
					NWE->NWE_CWO        := cWOCodig
					NWE->NWE_CODUSR     := __CUSERID
					NWE->NWE_VALORB     := nValorB
					NWE->NWE_VALORA     := nValorA
					NWE->NWE_DATAIN     := dDataIn
					NWE->NWE_DATAFI     := dDataFi
					NWE->NWE_COTAC1     := nCotac1
					NWE->NWE_COTAC2     := nCotac2
					If lCpoCotac
						NWE->NWE_COTAC  := JurCotac(nCotac1, nCotac2)
					EndIf
					NWE->(MsUnlock())
					nLanctos++

				Next nRec

				// Substituição do trecho abaixo para gravação no caso de valores referentes a despesas agrupados por moeda.
				If !lWODesp
					//Casos da Fatura
					cQuery := " SELECT NXC_CCLIEN, NXC_CLOJA, NXC_CCASO "
					cQuery +=   " FROM " + RetSqlName( 'NXC' ) + " "
					cQuery += " WHERE NXC_FILIAL = '" + xFilial("NXC") + "' "
					cQuery +=   " AND NXC_CFATUR = '" + cNumFatura + "'"
					cQuery +=   " AND NXC_CESCR  = '" + cCodEscr + "'"
					cQuery +=   " AND D_E_L_E_T_ = ' ' "

					aDespesas := JurSQL(cQuery, {"NXC_CCLIEN", "NXC_CLOJA", "NXC_CCASO"})

					For nI := 1 To Len(aDespesas)
						JAWOCasInc(cWOCodig, aDespesas[nI, 1], aDespesas[nI, 2], aDespesas[nI, 3], cMoedaNac, 0) // Quando não possuir despesa, gravar no histórico do WO a moeda nacional e zero no valor da despesa.
					Next nI

				Else
					For nI := 1 To Len(aDespesas)
						       // Código WO, Cod. Cliente    , Loja Cliente    , Numero do Caso  , Moeda           , Valor na Moeda.
						JAWOCasInc(cWOCodig, aDespesas[nI, 1], aDespesas[nI, 2], aDespesas[nI, 3], aDespesas[nI, 4], aDespesas[nI, 5])
					Next
				EndIf

				NUF->( dbSetOrder(1) )
				If NUF->(dbSeek(xFilial('NUF') + cWOCodig ) )
					RecLock("NUF", .F.)
					NUF->NUF_CFATU  := cNumFatura
					NUF->NUF_CESCR  := cCodEscr
					NUF->NUF_PERFAT := nPerFat
					NUF->(MsUnlock())

					J170GRAVA("NUF", xFilial("NUF") + cWOCodig, "4")
				EndIf

				NXG->(dbSetOrder(5))
				If NXG->(DbSeek(xFilial("NXG") + cCodEscr + cNumFatura ) )
					RecLock("NXG", .F.)
					NXG->NXG_CWO  := cWOCodig
					NXG->(MsUnlock())
				EndIf

				//Grava o resumo de WOs de Despesas
				If lWODesp
					JAWODspNWZ(cWOCodig)
				EndIf

				FWMsgRun(, {|| lRet := JA204CanTit(dResult)}, STR0029, STR0030) // "Aguarde" ### "Cancelando Financeiro..."

				//Disarma a transação no caso de problemas no cancelamento dos títulos
				If !lRet
					Disarmtransaction()
					Break
				Else
					nRet++
				EndIf

			END TRANSACTION

			JurFreeArr(aSE1)

		Else
			cMsg += I18N(STR0018, {cCodEscr + "-" + cNumFatura}) + CRLF //"A fatura: #1 está cancelada e não pode ser enviada para WO."
		EndIf

		NXA->( dbSkip() )
	EndDo

	NXA->( dbClearFilter() )

	While GetSX8Len() > 0
		ConfirmSX8()
	EndDo

	RestArea( aAreaNXA )
	RestArea( aAreaNUF )
	RestArea( aAreaNW0 )
	RestArea( aAreaNVZ )
	RestArea( aAreaNW4 )
	RestArea( aAreaNWC )
	RestArea( aAreaNWD )
	RestArea( aAreaNWE )
	RestArea( aAreaNXG )
	RestArea( aAreaSE1 )
	RestArea( aArea )

Return {nRet, nLanctos, cMsg}

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetFtLan(cTab, cFatura, cEscr)
Rotina para retornar um array com os recnos dos lançamento em fatura

@Param   cTab     Alias da tabela do lançamento
@Param   cEscr    Código do Escritório da Fatura
@Param   cFatura  Código da Fatura

@Return  aRet, array, Informações da área temporária

@author  Luciano Pereira dos Santos
@since   20/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurGetFtLan(cTab, cFatura, cEscr)
	Local cQuery := ""
	Local aLanc  := {}

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery +=     " FROM " + RetSqlName(cTab) + " "
	cQuery +=    " WHERE " + cTab + "_FILIAL = '" + xFilial(cTab) + "' "
	cQuery +=      " AND " + cTab + "_CFATUR = '" + cFatura + "'"
	cQuery +=      " AND " + cTab + "_CESCR = '" + cEscr + "'"
	cQuery +=      " AND " + cTab + "_CANC = '2' "
	cQuery +=      " AND D_E_L_E_T_ = ' ' "

	aLanc := JurSQL(cQuery, {"RECNO"})

Return aLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} JAFATPAGA
Marca os lançamentos como WO
/*/
//-------------------------------------------------------------------
Function JAFATPAGA
	Local lRet := .F.
	//Verifica se o compromisso a pagar está pago

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAUsaLanc
Faz a gravação do registro de WO na tabela de Faturamento do lançamento.

aIncLanc[1] = cliente
aIncLanc[2] = loja
aIncLanc[3] = caso
aIncLanc[4] = Moeda do lançamento
aIncLanc[5] = Valor
aIncLanc[6] = Data do lançamento
aIncLanc[7] = participante
aIncLanc[8] = Hora frac revisada
aIncLanc[9] = Hora frac lançada
aIncLanc[10] = codigo do tipo de despesa
aIncLanc[11] = Cliente do caso mãe
aIncLanc[12] = Loja do caso mãe
aIncLanc[13] = Caso mãe
/*/
//-------------------------------------------------------------------
Function JAUsaLanc(cAlias, cCodLanc, cSituac, cCodOper, cUser, aIncLanc)
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local cPreFat    := Space(TamSx3('NW0_PRECNF')[1])
	Local cFatura    := Space(TamSx3('NW0_CFATUR')[1])
	Local cEscrit    := Space(TamSx3('NW0_CESCR')[1])

	Default aIncLanc := Array(13)

	Do Case
	Case cAlias == "NUE"  //Time-Sheet
		// NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
		If Empty(JurGetDados("NW0", 1, xFilial("NW0") + cCodLanc + cSituac + cPreFat + cFatura + cEscrit + cCodOper, "NW0_CTS"))
			RecLock( 'NW0', .T. )
			NW0->NW0_FILIAL := xFilial("NW0")
			NW0->NW0_CTS    := cCodLanc
			NW0->NW0_SITUAC := cSituac
			NW0->NW0_CWO    := cCodOper
			NW0->NW0_CANC   := '2'
			NW0->NW0_CODUSR := cUser
			NW0->NW0_CCLIEN := aIncLanc[1]
			NW0->NW0_CLOJA  := aIncLanc[2]
			NW0->NW0_CCASO  := aIncLanc[3]
			NW0->NW0_CMOEDA := aIncLanc[4]
			NW0->NW0_VALORH := aIncLanc[5]
			NW0->NW0_DATATS := Iif(ValType(aIncLanc[6]) == "C", StoD(aIncLanc[6]), aIncLanc[6] )
			NW0->NW0_CPART1 := aIncLanc[7]
			NW0->NW0_TEMPOL := aIncLanc[8]
			NW0->NW0_TEMPOR := aIncLanc[9]
			If NW0->(ColumnPos("NW0_CCLICM")) > 0
				NW0->NW0_CCLICM := aIncLanc[11]
				NW0->NW0_CLOJCM := aIncLanc[12]
				NW0->NW0_CCASCM := aIncLanc[13]
			EndIf
			NW0->(MsUnlock())
		EndIf

	Case cAlias == "NVY"  //Despesa
		RecLock( 'NVZ', .T. )
		NVZ->NVZ_FILIAL := xFilial("NVZ")
		NVZ->NVZ_CDESP  := cCodLanc
		NVZ->NVZ_SITUAC := cSituac
		NVZ->NVZ_CWO    := cCodOper
		NVZ->NVZ_CANC   := '2'
		NVZ->NVZ_CODUSR := cUser
		NVZ->NVZ_CCLIEN := aIncLanc[1]
		NVZ->NVZ_CLOJA  := aIncLanc[2]
		NVZ->NVZ_CCASO  := aIncLanc[3]
		NVZ->NVZ_CMOEDA := aIncLanc[4]
		NVZ->NVZ_VALORD := aIncLanc[5]
		NVZ->NVZ_DTDESP := Iif(ValType(aIncLanc[6]) == "C", StoD(aIncLanc[6]), aIncLanc[6] )
		NVZ->NVZ_CTPDSP := aIncLanc[10]
		If NVZ->(ColumnPos("NVZ_CCLICM")) > 0
			NVZ->NVZ_CCLICM := aIncLanc[11]
			NVZ->NVZ_CLOJCM := aIncLanc[12]
			NVZ->NVZ_CCASCM := aIncLanc[13]
		EndIf
		NVZ->(MsUnlock())

	Case cAlias == "NV4"  //Tabelado
		RecLock( 'NW4', .T. )
		NW4->NW4_FILIAL := xFilial("NW4")
		NW4->NW4_CLTAB  := cCodLanc
		NW4->NW4_SITUAC := cSituac
		NW4->NW4_CWO    := cCodOper
		NW4->NW4_CANC   := '2'
		NW4->NW4_CODUSR := cUser
		NW4->NW4_CCLIEN := aIncLanc[1]
		NW4->NW4_CLOJA  := aIncLanc[2]
		NW4->NW4_CCASO  := aIncLanc[3]
		NW4->NW4_CMOEDH := aIncLanc[4]
		NW4->NW4_VALORH := aIncLanc[5]
		NW4->NW4_DTCONC := Iif(ValType(aIncLanc[6]) == "C", StoD(aIncLanc[6]), aIncLanc[6] )
		NW4->NW4_CPART1 := aIncLanc[7]
		If NW4->(ColumnPos("NW4_CCLICM")) > 0
			NW4->NW4_CCLICM := aIncLanc[11]
			NW4->NW4_CLOJCM := aIncLanc[12]
			NW4->NW4_CCASCM := aIncLanc[13]
		EndIf
		NW4->(MsUnlock())

	Case cAlias == "NVV"  //Fat. Adicional
		RecLock( "NWD", .T. )
		NWD->NWD_FILIAL := xFilial("NWD")
		NWD->NWD_CFTADC := cCodLanc
		NWD->NWD_SITUAC := cSituac
		NWD->NWD_CWO    := cCodOper
		NWD->NWD_CANC   := "2"
		NWD->NWD_CODUSR := cUser
		NWD->(MsUnlock())

	Case cAlias == "NT1"  //Fixo
		RecLock( 'NWE', .T. )
		NWE->NWE_FILIAL := xFilial("NWE")
		NWE->NWE_CFIXO  := cCodLanc
		NWE->NWE_SITUAC := cSituac
		NWE->NWE_CWO    := cCodOper
		NWE->NWE_CANC   := '2'
		NWE->NWE_CODUSR := cUser
		NWE->NWE_CMOEDA := aIncLanc[1]  // Código da Moeda

		NWE->(MsUnlock())

	Otherwise
		lRet := .F.
	EndCase

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JACANCWO
Cancela o WO e volta os lançamentos para Pendente.

@param  cWoCodig      Código do WO que será cancelado
@Return nRet          Retorna a quantidade de lançamentos alterados

@author David G. Fernandes
@since 28/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JACANCWO(cWoCodig, aObs)
Local nRet      := 0
Local nI        := 0
Local nY        := 0
Local nLancWO   := 0
Local nLancOK   := 0
Local cQuery    := ""
Local aArea     := GetArea()
Local aAreaNUF  := NUF->(GetArea())
Local aAreaNXG  := NXG->(GetArea())
Local aAreaNX0  := NX0->(GetArea())
Local cCodPre   := ""
Local lTemFt    := .F.
Local cCpClien  := ""
Local cCpLoja   := ""
Local cCpCaso   := ""
Local cTpLanc   := ""
Local cCodLan   := ""
Local cClient   := ""
Local cLoja     := ""
Local cCaso     := ""
Local dDtLanc   := CtoD("")
Local lAlterada := .F.
Local cDescLanc := ""
Local cPartLog  := JurUsuario(__CUSERID)
Local aPfLog    := {}
Local aLanc     := {}
Local aCampos   := { {"NW0", "NUE", "NW0_CTS"   , 'NW0_CWO', 'NW0_SITUAC', 'NUE_SITUAC', 'NUE_CCLIEN', 'NUE_CLOJA', 'NUE_CCASO', 'NUE_DATATS' },;  //Time-Sheet
                     {"NVZ", "NVY", "NVZ_CDESP" , 'NVZ_CWO', 'NVZ_SITUAC', 'NVY_SITUAC', 'NVY_CCLIEN', 'NVY_CLOJA', 'NVY_CCASO', 'NVY_DATA' },;    //Despesas
                     {"NW4", "NV4", "NW4_CLTAB" , 'NW4_CWO', 'NW4_SITUAC', 'NV4_SITUAC', 'NV4_CCLIEN', 'NV4_CLOJA', 'NV4_CCASO', 'NV4_DTCONC' },;  //Tabelado
                     {"NWD", "NVV", "NWD_CFTADC", 'NWD_CWO', 'NWD_SITUAC', 'NVV_SITUAC', '',           '',          '',          ''},;             //Fatura Adicional
                     {"NWE", "NT1", "NWE_CFIXO" , 'NWE_CWO', 'NWE_SITUAC', 'NT1_SITUAC', '',           '',          '',          ''} }             //Fixo
Local lAltHr    := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local cUsrProc  := ""
Local cUsrTs	:= ""

	If Len(aObs) > 2  .And. JurIsRest()
		// Envio de WO via Rest
		cUsrProc := aObs[03]
		cUsrTs   := cUsrProc
	Else
		cUsrProc := __CUSERID
		cUsrTs   := cPartLog
	EndIf

	BEGIN TRANSACTION

		//Cancela o WO
		RecLock( 'NUF', .F. )
		NUF->NUF_SITUAC := "2"  //Cancelado
		NUF->NUF_DTCAN  := MsDate()
		NUF->NUF_OBSCAN := aObs[1]
		NUF->NUF_CMOTCA := aObs[2]
		NUF->NUF_USRCAN := cUsrProc
		NUF->(MsUnlock())
		NUF->(DbCommit())
		J170GRAVA("NUF", xFilial("NUF") + cWoCodig, "4") // Grava na fila de sincronização o cancelamento do WO

		If !Empty(NUF->NUF_CESCR + NUF->NUF_CFATU)
			NXG->(dbSetOrder(5))
			If NXG->(DbSeek(xFilial("NXG") + NUF->NUF_CESCR + NUF->NUF_CFATU + NUF->NUF_COD ))
				cCodPre := NXG->NXG_CPREFT
				lTemFt  := JA201TemFt(NXG->NXG_CPREFT, , , NXG->NXG_CFIXO, NXG->NXG_CFATAD)
				RecLock("NXG",.F.)
				If !Empty(NXG->NXG_CPREFT) .Or. !Empty(NXG->NXG_CFATAD)
					NXG->NXG_CESCR   := ""
					NXG->NXG_CFATUR  := ""
					NXG->NXG_CWO     := ""
				ElseIf !Empty(NXG->NXG_CFIXO)
					If lTemFt
						NXG->NXG_CWO := "" //Se for de fixo e tiver outras faturas ativas, só limpa o WO para recuparar o pagador na reemissão
					Else
						NXG->(DbDelete())
					EndIf
				EndIf
				NXG->(MsUnlock())
				NXG->(DbCommit())
			EndIf

			NXA->(dbSetOrder(1)) //NXA_FILIAL + NXA_CESCR + NXA_COD
			If NXA->(DbSeek(xFilial("NXA") + NUF->NUF_CESCR + NUF->NUF_CFATU))
				RecLock("NXA",.F.)
				NXA->NXA_WO := "2" // Com o cancelamento do WO, a fatura passa a ter só um cancelamento simples
				NXA->(MsUnlock())
				NXA->(DbCommit())
			EndIf

		EndIf

		For nI := 1 To Len(aCampos)

			cAliasWO   := aCampos[nI][1]
			cAliasLan  := aCampos[nI][2]
			cCodLanWo  := aCampos[nI][3]
			cCodWo     := aCampos[nI][4]
			cSituacWo  := aCampos[nI][5]
			cSituacLan := aCampos[nI][6]
			cCpClien   := aCampos[nI][7]
			cCpLoja    := aCampos[nI][8]
			cCpCaso    := aCampos[nI][9]
			cCpDtlanc  := aCampos[nI][10]

			Do Case
				Case aCampos[nI][2] == "NUE"
					cTpLanc := 'TS'
					cDescLanc := STR0095 //'TimeSheet'
				Case aCampos[nI][2] == "NVY"
					cTpLanc := 'DP'
					cDescLanc := STR0096 //"Despesas"
				Case aCampos[nI][2] == "NV4"
					cTpLanc := 'LT'
					cDescLanc := STR0097 // "Serviço Tabelado"
			EndCase

			cQuery := " SELECT R_E_C_N_O_ RECNO "
			cQuery +=   " FROM " + RetSqlName(cAliasWO) + " "
			cQuery +=    " WHERE " + cAliasWO + "_FILIAL = '" + xFilial( cAliasWO ) + "' "
			cQuery +=    " AND " + cCodWo + " = '" + cWoCodig + "' "
			cQuery +=    " AND " + cSituacWo + " = '3' "
			cQuery +=    " AND D_E_L_E_T_ = ' ' "

			aLanc   := JurSQL(cQuery, {"RECNO"})
			nLancWO := Len(aLanc)
			nLancOK := 0

			For nY := 1 To nLancWO
				(cAliasWO)->(DBGoto(aLanc[nY][1]))

				RecLock(cAliasWO, .F. )
				(cAliasWO)->(FieldPut(FieldPos(cAliasWO + "_CANC"), "1")) //WO do Lancto Cancelado
				(cAliasWO)->(MsUnlock())

				cCodLan := (cAliasWO)->(FieldGet(FieldPos(cCodLanWo)))

				(cAliasLan)->(dbSetOrder(1)) //Filial + Cód
				If (cAliasLan)->(dbSeek( xFilial(cAliasLan) +  cCodLan ) )

					RecLock( cAliasLan, .F. )
					(cAliasLan)->(FieldPut(FieldPos(cSituacLan), IIF(lTemFt, "2", "1") )) //Ajusta a situação do Lançamento Pendente caso nao tenha mais faturas
					If cAliasLan $ "NUE"
						NUE->NUE_CUSERA := cUsrTs
						NUE->NUE_ALTDT  := Date()
						If lAltHr
							NUE->NUE_ALTHR := Time()
						EndIf
					EndIf
					(cAliasLan)->(MsUnlock())

					J170GRAVA(cAliasLan, xFilial(cAliasLan) + cCodLan, "4") //Grava na fila de sincronização a alteração

					If !Empty(cTpLanc)
						cClient := (cAliasLan)->(FieldGet(FieldPos(cCpClien)))
						cLoja   := (cAliasLan)->(FieldGet(FieldPos(cCpLoja)))
						cCaso   := (cAliasLan)->(FieldGet(FieldPos(cCpCaso)))
						dDtLanc := (cAliasLan)->(FieldGet(FieldPos(cCpDtlanc)))
						aPfLog  := JA202VerPre(cClient, cLoja, cCaso, dDtLanc, cTpLanc)

						If !Empty(aPfLog)
							NX0->(dbSeek(xFilial('NX0') + aPfLog[1][1]))
							lAlterada := NX0->NX0_SITUAC == "3"
							If NX0->NX0_SITUAC $ '2|3|D|E'  //Pré-Fatura alterável
								RecLock("NX0",.F.)
								NX0->NX0_SITUAC := "3"
								NX0->NX0_USRALT := cPartLog
								NX0->NX0_DTALT  := Date()
								NX0->(MsUnlock())
								If !lAlterada
									J202HIST('99', aPfLog[1][1], cPartLog, I18N(STR0200, {cDescLanc})) // "Cancelamento de WO - #1."
								EndIf
							EndIf
						EndIf

						JurLogLanc(aPfLog, '', 4, .F., .F.)
					EndIf
					nLancOK++
				EndIf

			Next nY

			If (nRet >= 0) .AND. (nLancOK == nLancWO)
				nRet += nLancOK
			Else
				nRet := -1
			EndIf

		Next nI

		If nRet >= 0
			If !Empty( cCodPre )
				JA204RPre(NUF->NUF_CESCR, NUF->NUF_CFATU)
			EndIf
		Else
			RollBackDelTran(STR0016)  // "Problema para cancelar o WO"
		EndIf

	END TRANSACTION

	RestArea( aAreaNX0 )
	RestArea( aAreaNUF )
	RestArea( aAreaNXG )
	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANUFDESC
Descrição dos campos virtuais da tabela NUF

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo

@Sample 	JANUFDESC("NUF_DCLIEN")

@author David Gonçalves Fernandes
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANUFDESC(cCampo)
	Local xRet     := Nil
	Local cCFatura := ""
	Local cCEscrit := ""
	Local cMoeda   := ""

	cCodigo  := NUF->NUF_COD
	cCFatura := NUF->NUF_CFATU
	cCEscrit := NUF->NUF_CESCR

	Do Case
	Case cCampo == "NUF_DTEMI"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DTEMI')
	Case cCampo == "NUF_DTVENF"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DTVENC')
	Case cCampo == "NUF_CMOEDA"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_CMOEDA')
	Case cCampo == "NUF_DMOEDA"
		cMoeda := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_CMOEDA')
		xRet   := JurGetDados('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB')
	Case cCampo == "NUF_VLFATH"
		xRet :=  JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_VLFATH')
	Case cCampo == "NUF_VLFATD"
		xRet :=  JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_VLFATD')
	Case cCampo == "NUF_VLDESC"
		xRet :=  JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_VLDESC')
	Case cCampo == "NUF_DREFIH"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DREFIH')
	Case cCampo == "NUF_DREFFH"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DREFFH')
	Case cCampo == "NUF_DREFID"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DREFID')
	Case cCampo == "NUF_DREFFD"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DREFFD')
	Case cCampo == "NUF_VLACRE"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_VLACRE')
	Case cCampo == "NUF_DREFIT"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DREFIT')
	Case cCampo == "NUF_DREFFT"
		xRet := JurGetDados('NXA', 1, xFilial('NXA') + cCEscrit + cCFatura, 'NXA_DREFFT')
	Otherwise
		xRet := ""
	EndCase

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANUGDESC
Descrição dos campos virtuais da tabela NUG

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JA146DESC("NUG_DCLIEN")

@author David Gonçalves Fernandes
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANUGDESC(cCampo)
	Local cRet := ""

	Do Case
	Case cCampo == "NUG_DCLIEN"
		cRet := JurGetDados('SA1', 1, xFilial('SA1') + NUG->NUG_CCLIEN + NUG->NUG_CLOJA, 'A1_NOME')
	Case cCampo == "NUG_DCASO"
		cRet := JurGetDados('NVE', 1, xFilial('NVE') + NUG->NUG_CCLIEN + NUG->NUG_CLOJA + NUG->NUG_CCASO, 'NVE_TITULO')
	Otherwise
		cRet := ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANW0DESC
Retorna a descrição dos campos virtuais da tabela NW0

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JANW0DESC("NW0_DATATS")

@author David Gonçalves Fernandes
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANW0DESC(cCampo)
	Local cRet    := ""
	Local cCodigo := ""
	Local cClien  := ""
	Local cLoja   := ""
	Local cCaso   := ""
	Local cPart2  := ""

	cCodigo := NW0->NW0_CTS
	cClien  := NW0->NW0_CCLIEN
	cLoja   := NW0->NW0_CLOJA
	cCaso   := NW0->NW0_CCASO

	Do Case
	Case cCampo == "NW0_SIGLA1"
		cRet := JurGetDados("RD0", 1, xFilial("RD0") + NW0->NW0_CPART1, "RD0_SIGLA")
	Case cCampo == "NW0_DPART1"
		cRet   := JurGetDados("RD0", 1, xFilial("RD0") + NW0->NW0_CPART1, "RD0_NOME")
	Case cCampo == "NW0_CPART2"
		cRet := GetAdvFVal( "NUE", "NUE_CPART2", xFilial("NUE") + cCodigo )
	Case cCampo == "NW0_SIGLA2"
		cPart2 := GetAdvFVal( "NUE", "NUE_CPART2", xFilial("NUE") + cCodigo )
		cRet := JurGetDados("RD0", 1, xFilial("RD0") + cPart2, "RD0_SIGLA")
	Case cCampo == "NW0_DPART2"
		cPart2 := GetAdvFVal( "NUE", "NUE_CPART2", xFilial("NUE") + cCodigo )
		cRet   := JurGetDados("RD0", 1, xFilial("RD0") + cPart2, "RD0_NOME")
	Case cCampo == "NW0_DCLIEN"
		cRet := JurGetDados("SA1", 1, xFilial("SA1") + cClien + cLoja, "A1_NOME")
	Case cCampo == "NW0_DCASO"
		cRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_TITULO")
	Case cCampo == "NW0_DMOEDA"
		cRet := JurGetDados("CTO", 1, xFilial("CTO") + NW0->NW0_CMOEDA, "CTO_SIMB")
	Otherwise
		cRet := ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANVZDESC
Retorna a descrição dos campos virtuais da tabela NVY

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JANVZDESC("NVZ_DTDESP")

@author David Gonçalves Fernandes
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANVZDESC(cCampo)
	Local cRet    := ""
	Local cCodigo := ""
	Local cClien  := ""
	Local cLoja   := ""
	Local cCaso   := ""
	Local aArea   := GetArea()

	cCodigo := NVZ->NVZ_CDESP
	cClien  := NVZ->NVZ_CCLIEN
	cLoja   := NVZ->NVZ_CLOJA
	cCaso   := NVZ->NVZ_CCASO

	Do Case
	Case cCampo == "NVZ_DTDESP"
		cRet := JurGetDados("NVY", 1, xFilial("NVY") + cCodigo, "NVY_DATA")
	Case cCampo == "NVZ_DCLIEN"
		cRet := JurGetDados("SA1", 1, xFilial("SA1") + cClien + cLoja, "A1_NOME")
	Case cCampo == "NVZ_DCASO"
		cRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_TITULO")
	Case cCampo == "NVZ_CTPDSP"
		cRet := JurGetDados("NVY", 1, xFilial("NVY") + cCodigo, "NVY_CTPDSP")
	Case cCampo == "NVZ_DTPDSP"
		cRet := JurGetDados("NRH", 1, xFilial("NRH") + NVZ->NVZ_CTPDSP, "NRH_DESC")
	Case cCampo == "NVZ_DMOEDA"
		cRet := JurGetDados("CTO", 1, xFilial("CTO") + NVZ->NVZ_CMOEDA, "CTO_SIMB")
	Otherwise
		cRet := ""
	EndCase

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANW4DESC
Retorna a descrição dos campos virtuais da tabela NW4

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JANW4DESC("NW4_DATA")

@author David Gonçalves Fernandes
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANW4DESC(cCampo)
	Local xRet      := Nil
	Local cCodigo   := ""
	Local cClien    := ""
	Local cLoja     := ""
	Local cCaso     := ""
	Local cTpSrv    := ""
	Local cMoeda    := ""

	cCodigo := NW4->NW4_CLTAB
	cClien  := NW4->NW4_CCLIEN
	cLoja   := NW4->NW4_CLOJA
	cCaso   := NW4->NW4_CCASO

	Do Case
	Case cCampo == "NW4_DATA"
		xRet := GetAdvFVal("NV4", "NV4_DTLANC", xFilial("NV4") + cCodigo )
	Case cCampo == "NW4_SIGLA1"
		xRet := JurGetDados("RD0", 1, xFilial("RD0") + NW4->NW4_CPART1, "RD0_SIGLA")
	Case cCampo == "NW4_DPART1"
		xRet   := JurGetDados("RD0", 1, xFilial("RD0") + NW4->NW4_CPART1, "RD0_NOME")
	Case cCampo == "NW4_DCLIEN"
		xRet := JurGetDados("SA1", 1, xFilial("SA1") + cClien + cLoja, "A1_NOME")
	Case cCampo == "NW4_DCASO"
		xRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_TITULO")
	Case cCampo == "NW4_CTPSRV"
		xRet := GetAdvFVal("NV4", "NV4_CTPSRV", xFilial("NV4") + cCodigo )
	Case cCampo == "NW4_DTPSRV"
		cTpSrv := GetAdvFVal("NV4", "NV4_CTPSRV", xFilial("NV4") + cCodigo )
		xRet := JurGetDados("NRD", 1, xFilial("NRD") + cTpSrv, "NRD_DESCH")
	Case cCampo == "NW4_DMOEDH"
		xRet   := JurGetDados("CTO", 1, xFilial("CTO") + NW4->NW4_CMOEDH, "CTO_SIMB")
	Case cCampo == "NW4_CMOEDT"
		xRet := GetAdvFVal("NV4", "NV4_CMOED", xFilial("NV4") + cCodigo)
	Case cCampo == "NW4_DMOEDT"
		cMoeda := GetAdvFVal("NV4", "NV4_CMOED", xFilial("NV4") + cCodigo)
		xRet   := JurGetDados("CTO", 1, xFilial("CTO") + cMoeda, "CTO_SIMB")
	Case cCampo == "NW4_VALORT"
		xRet := GetAdvFVal("NV4", "NV4_VLDFAT", xFilial("NV4") + cCodigo)
	Otherwise
		xRet := ""
	EndCase

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldAnoMes
Retorna a validar se uma data no fomato Ano Mes("201001") esta correta.

@param 		cAnoMes		Campo com data no formato de ano mes
@Return 	nRet	 		.T./.F.
@Sample 	JVldAnoMes("201001")

@author Felipe Bonvicini Conti
@since 12/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldAnoMes(cAnoMes)
	Local lRet      := .T.
	Local nAno      := 0
	Local nMes      := 0
	Local cMes      := ""
	Local cAno      := ""

	Default cAnoMes := &(ReadVar())

	If !Empty(cAnoMes)
		cAno := SubStr(cAnoMes, 1, 4)
		cMes := SubStr(cAnoMes, 5, 2)

		If At(" ", cAno) > 0 .Or. At(" ", cMes) > 0
			lRet := JurMsgErro(STR0011, , STR0134) //# "Data informada está inválida!" ## "Informe uma data válida."
		Else
			nAno := Val(cAno)
			nMes := Val(cMes)
			If (nAno < 0000 .Or. nAno > 9999) .Or. (nMes < 01 .Or. nMes > 12)
				lRet := JurMsgErro(STR0011, , STR0134) //# "Data informada está inválida!" ## "Informe uma data válida."
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANWCDESC
Retorna a descrição dos campos virtuais da tabela NWC

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JANWCDESC("NWC_CCLIEN")

@author David Gonçalves Fernandes
@since 13/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANWCDESCS()
	Local cRet   := ""
	Local cMoeda := ""
	Local cCampo := AllTrim(ReadVar())

	cCodigo := NWC->NWC_CEXITO
	cClien  := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_CCLIEN")
	cLoja   := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_CLOJA")
	cCaso   := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_NUMCAS")

	Do Case
	Case "NWC_CCLIEN" $ cCampo
		cRet := cClien
	Case "NWC_CLOJA"  $ cCampo
		cRet := cLoja
	Case "NWC_DCLIEN" $ cCampo
		cRet := JurGetDados("SA1", 1, xFilial("SA1") + cClien + cLoja, "A1_NOME")
	Case "NWC_CCASO"  $ cCampo
		cRet := cCaso
	Case "NWC_DCASO"  $ cCampo
		cRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_TITULO")
	Case "NWC_PARC "  $ cCampo
		cRet := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_PARC")
	Case "NWC_DTVENC" $ cCampo
		cRet := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_DTVENC")
	Case "NWC_CMOEDA" $ cCampo
		cRet := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_CMOEDA")
	Case "NWC_DMOEDA" $ cCampo
		cMoeda := JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_CMOEDA")
		cRet   := JurGetDados("CTO", 1, xFilial("CTO") + cMoeda, "CTO_SIMB")
	Case "NWC_VALOR"  $ cCampo
		cRet := AllTrim(Transform( JurGetDados("NUI", 1, xFilial("NUI") + cCodigo, "NUI_VALOR"), '@E 99,999,999,999.99'))
	Otherwise
		cRet := ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANWDDESC
Retorna a descrição dos campos virtuais da tabela NWD

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JANWDDESC("NWD_CCLIEN")

@author David Gonçalves Fernandes
@since 13/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANWDDESCS()
	Local cRet      := ""
	Local cMoeda    := ""
	Local cCampo    := AllTrim(ReadVar())
	Local cFatura   := NWD->NWD_CFATUR
	Local cEscr     := NWD->NWD_CESCR
	Local cCodigo   := NWD->NWD_CFTADC

	If !Empty(cEscr + cFatura)
		cClien  := JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_CLIPG")
		cLoja   := JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_LOJPG")
	Else
		cClien  := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_CCLIEN")
		cLoja   := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_CLOJA")
	EndIf

	Do Case
	Case "NWD_CCLIEN"  $ cCampo
		cRet := cClien
	Case "NWD_CLOJA"  $ cCampo
		cRet := cLoja
	Case "NWD_DCLIEN" $ cCampo
		cRet := JurGetDados("SA1", 1, xFilial("SA1") + cClien + cLoja, "A1_NOME")
	Case "NWD_PARC" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_PARC")
	Case "NWD_DTINIH" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_DTINIH")
	Case "NWD_DTFIMH" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_DTFIMH")
	Case "NWD_CMOE1" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_CMOE1")
	Case "NWD_DMOE1" $ cCampo
		cMoeda := JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_CMOEDA")
		cRet   := JurGetDados("CTO", 1, xFilial("CTO") + cMoeda, "CTO_SIMB")
	Case "NWD_VALORH" $ cCampo
		cRet := AllTrim(Transform( JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_VLFATH"), '@E 99,999,999,999.99'))
	Case "NWD_DTINID" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_DTINID")
	Case "NWD_DTFIMD" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_DTFIMD")
	Case "NWD_CMOE2" $ cCampo
		cRet := JurGetDados("NVV", 1, xFilial("NVV") + cCodigo, "NVV_CMOE2")
	Case "NWD_DMOE2" $ cCampo
		cMoeda := JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_CMOEDA")
		cRet := JurGetDados("CTO", 1, xFilial("CTO") + cMoeda, "CTO_SIMB")
	Case "NWD_VALORD" $ cCampo
		cRet := AllTrim(Transform( JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_VLFATD"), '@E 99,999,999,999.99'))
	Case "NWD_VALORT" $ cCampo
		cRet := ""
	Otherwise
		cRet := ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANWEDESC
Retorna a descrição dos campos virtuais da tabela NWE

@param 		cCampo		Campo virtual que irá exibir a descrição
@Return 	nRet	 		Descrição a ser exibida no campo
@Sample 	JANWEDESC("NWE_CCLIEN")

@author David Gonçalves Fernandes
@since 13/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANWEDESCS()
	Local cRet      := ""
	Local cCampo    := AllTrim(ReadVar())
	Local cCodigo   := NWE->NWE_CFIXO
	Local lNovaParc := _cNWECFixo <> cCodigo

	If lNovaParc
		// Se for uma parcela nova pega os dados referente a parcela e armazena nas variáveis estáticas e reaproveita enquanto estiver nessa parcela
		// Isso é necessário devido a PERFORMANCE na abertura do modelo de contratos de fixo que tem muitas NWE
		aDadosNT1  := JurGetDados("NT1", 1, xFilial("NT1") + cCodigo, {"NT1_CCONTR", "NT1_PARC", "NT1_DATAVE", "NT1_DATAAT"})
		If Len(aDadosNT1) > 0
			_cNWECFixo  := cCodigo
			_cNWECContr := aDadosNT1[1]
			_cNWEParc   := aDadosNT1[2]
			_dNWEDataVe := aDadosNT1[3]
			_dNWEDataAt := aDadosNT1[4]
			_cNWEDContr := JurGetDados("NT0", 1, xFilial("NT0") + _cNWECContr , "NT0_NOME")
		EndIf
	EndIf

	Do Case
	Case "NWE_CCONTR" $ cCampo
		cRet := _cNWECContr
	Case "NWE_DCONTR" $ cCampo
		cRet := _cNWEDContr
	Case "NWE_PARC" $ cCampo
		cRet := _cNWEParc
	Case "NWE_DATAVE" $ cCampo
		cRet := _dNWEDataVe
	Case "NWE_DATAAT" $ cCampo
		cRet := _dNWEDataAt
	Otherwise
		cRet := ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURHIST
Rotina para comparar os campos.

@param oModel    , Model
@param cIdMdlHist, Id do model do histórico
@param aMldCpos  , Array com a estrutura dos campos de origem x histórico
                   [n][1] IdModel do campo de origem
                   [n][2] Array com os campos de origem x histórico
                   [n][2][n][1] Campo de origem
                   [n][2][n][2] Campo do histórico
@obs aMldCpos, Quando a origem for um grid, só é possível passar um IdModel para a origem dos dados.

@param lGrid     , Se a origem dos valores estão em um grid
@param aCpoCond  , Array com o nome de do campos de condição.
                   [1] Campo de origem
                   [2] Campo do histórico
@param cCondicao , Valor a ser encontrado para condição.

@Return lRet, .T./.F. As informações são válidas ou não

@author Bruno Ritter / Luciano Pereira
@since 17/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURHIST(oModel, cIdMdlHist, aMldCpos, lGrid, aCpoCond)
	Local nOperation := oModel:GetOperation()
	Local nI         := 0
	Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )
	Local lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .F. )
	Local lRet       := .T.
	Local lAjustHist := .F.
	Local lAtuHist   := .F.
	Local nPosAMIni  := 1
	Local nPosAMFim  := 2
	Local nIdOrig    := 3
	Local oGridHist  := oModel:GetModel(cIdMdlHist)
	Local cTableD    := oGridHist:GetStruct():GetTable()[1]
	Local cCpoDtIni  := cTableD + "_AMINI"
	Local cCpoDtFim  := cTableD + "_AMFIM"
	Local nLinTblOld := 0
	Local nPosAMFech := 0
	Local cCondicao  := ""
	Local cCpoCondO  := ""
	Local cCpoCondH  := ""
	Local nLine      := 0
	Local nChave     := 0
	Local aValOrigem := {}
	Local aCondOrd   := {}
	Local aNovoHist  := {}
	Local aColsOrd   := {}
	Local cAnoMesAbr := ""
	Local cCampoHist := ""
	Local xVlOrig    := Nil
	Local cAnoMesFec := AnoMes(MsSomaMes(MsDate(), Iif(lHstMesAnt, -2, -1)))
	Local cAMIniPad  := "190001"

	Default lGrid    := .T.
	Default aCpoCond := {}

	If (nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR) .And. !JHistEmpty(oModel, aMldCpos, cIdMdlHist)
		nLinTblOld := oGridHist:GetLine()
		aValOrigem := JRetValOri(oModel, aMldCpos, lGrid)

		If !Empty(aCpoCond)
			If Len(aCpoCond) == 2
				cCpoCondO := aCpoCond[1]
				cCpoCondH := aCpoCond[2]
				aCondOrd  := {cCpoCondH}
			ElseIf Len(aCpoCond) == 4 // Usado para Participação no Caso e no Cliente
				cCpoCondO := aCpoCond[1] + ", " + aCpoCond[3]
				cCpoCondH := aCpoCond[2] + ", " + aCpoCond[4]
				aCondOrd  := {aCpoCond[2], aCpoCond[4]}
			EndIf
		EndIf

		If oGridHist:Length(.T.) == 0 .Or. oGridHist:IsEmpty()
			cAnoMesAbr := cAMIniPad
		Else
			cAnoMesAbr := AnoMes(MsSomaMes(StoD(cAnoMesFec + "01"), 1))
		EndIf

		For nChave := 1 To Len(aValOrigem)
			nPosAMFech := 0
			aCampos    := aValOrigem[nChave][1]
			nLine      := aValOrigem[nChave][2] // Vem Nil quando o model de origem é Field

			If !Empty(cCpoCondO)
				If Len(aCpoCond) == 2
					cCondicao := FwFldGet(cCpoCondO, nLine)
				ElseIf Len(aCpoCond) == 4
					cCondicao := FwFldGet(aCpoCond[1], nLine) + FwFldGet(aCpoCond[3], nLine)
				EndIf 
			EndIf

			// Agrupa os dados do histórico com base na condição.
			aColsOrd := JGeraColOrd(oGridHist, cCpoDtIni, cCpoDtFim, aCondOrd, cCondicao)

			// Localiza a linha no histórico com o periódo em aberto
			aEval(aColsOrd, {|x| Iif(!Empty(AllTrim(x[nPosAMIni])) .And. Empty(AllTrim(x[nPosAMFim])), nPosAMFech := x[nIdOrig], Nil )})

			// Não foi encontrado histórico em aberto deve ajustar o histórico
			lAjustHist := nPosAMFech == 0

			If !lAjustHist
				// Verifica se o periódo em aberto está difernte da origem dos dados com base no nPosAMFech
				For nI := 1 To Len(aCampos)
					cCampoHist := aCampos[nI][3]
					xVlOrig    := aCampos[nI][2]

					If oGridHist:GetValue(cCampoHist, nPosAMFech) != xVlOrig
						lAjustHist := .T.
					EndIf
				Next nI
			EndIf

			If lUsaHist
				// Se usa histórico, verifica se tem algum periódo que tem que ser fechado,
				// pois se um periódo deve se fechado, então todos devem ser fechados.
				lAtuHist := lAtuHist .Or. lAjustHist

				If nPosAMFech > 0 .And. oGridHist:GetValue(cCpoDtIni, nPosAMFech) == cAnoMesAbr
					aAdd(aNovoHist, {nPosAMFech, aCampos}) // Atualiza o período
				Else
					aAdd(aNovoHist, {0, aCampos}) // Cria um novo período
				EndIf

			Else // Não usa histórico

				// Senão usa histórico e a data de inicio do mês fechado é diferente da data inicial padrão
				If !lAjustHist
					lAjustHist := oGridHist:GetValue(cCpoDtIni, nPosAMFech) != cAMIniPad
				EndIf

				If lAjustHist
					// Adiciona a linha quando existem históricos mas não para a condição atual de aValOrigem
					If Len(aColsOrd) == 0 .And. !oGridHist:IsEmpty()
						oGridHist:AddLine()
					Else
						For nI := 1 To Len(aColsOrd)
							oGridHist:Goline(aColsOrd[nI][nIdOrig])
							If nI < Len(aColsOrd)
								oGridHist:DeleteLine() // Quando nao usar histórico, garante que só exista uma linha com a mesma condição
							EndIf
						Next nI
					EndIf

					lRet := lRet .And. (oGridHist:SetValue( cCpoDtIni, cAMIniPad ))
					lRet := lRet .And. (oGridHist:ClearField(cCpoDtFim))
					lRet := lRet .And. (JURHSTSET(oGridHist, aCampos) ) //Grava os demais campos da condição do histórico
					lRet := lRet .And. oGridHist:VldLineData()

					If !lRet
						JurMsgErro(STR0255) // "Erro ao gerar o histórico"
						Exit
					EndIf
				EndIf
			EndIf
		Next nI

		If lUsaHist .And. lAtuHist
			// Fecha o período existente
			For nI := 1 To oGridHist:GetQtdLine()
				If !oGridHist:IsDeleted(nI)
					cDtValIni := oGridHist:GetValue(cCpoDtIni, nI)
					cDtValFim := oGridHist:GetValue(cCpoDtFim, nI)

					If !Empty(cDtValIni) .And. Empty(cDtValFim); // Periódo em aberto
					   .And. cDtValIni <= cAnoMesFec // Data de inicio menor que a data de fechamento
						oGridHist:GoLine(nI)
						lRet := lRet .And. oGridHist:SetValue(cCpoDtFim, cAnoMesFec)
						lRet := lRet .And. oGridHist:VldLineData()
					EndIf
				EndIf
			Next nI

			// Abre/Atualiza os períodos
			For nI := 1 To Len(aNovoHist)
				nLine   := aNovoHist[nI][1]
				aCampos := aNovoHist[nI][2]
				If Empty(nLine)
					Iif(!oGridHist:IsEmpty(), oGridHist:AddLine(), Nil)
					lRet := lRet .And. (oGridHist:SetValue(cCpoDtIni, cAnoMesAbr))
					lRet := lRet .And. (oGridHist:ClearField(cCpoDtFim))
				Else
					oGridHist:Goline(nLine)
				EndIf

				lRet := lRet .And. (JURHSTSET(oGridHist, aCampos)) //Grava os demais campos da condição do histórico
			Next nI
		EndIf

		//Verifica se há registros inconsistentes
		If lRet
			JIsIncons(aValOrigem, Iif(Len(aCpoCond) == 4, aCondOrd, cCpoCondH), oGridHist, cCpoDtIni, cCpoDtFim, cAMIniPad, cAnoMesAbr, cAnoMesFec)
		EndIf

		oGridHist:GoLine(nLinTblOld)

		JurFreeArr(@aValOrigem)
		JurFreeArr(@aCondOrd  )
		JurFreeArr(@aNovoHist )
		JurFreeArr(@aColsOrd  )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JHistEmpty()
Rotina para verificar se os Modelos utilizados na JURHIST estão vazios.

@param oModel     Modelo
@param aMldOrig   Array com a estrutura dos campos de origem x histórico
                  [n][1] Id dos modelos de origem
@param cIdMdlHist Id do model do histórico (destino)

@Return lRet      .T. Se todos os modelos relacionados ao historico estão vazios

@author Luciano Pereira dos Santos
@since 16/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JHistEmpty(oModel, aMldOrig, cIdMdlHist)
Local lRet     := .T.
Local lIsEmpty := .T.
Local nI       := 0

If oModel:GetModel(cIdMdlHist):IsEmpty()
	For nI := 1 To Len(aMldOrig)
		If (oModel:GetModel(aMldOrig[nI][1]):ClassName() == 'FWFORMGRID')
			lIsEmpty := lIsEmpty .And. oModel:GetModel(aMldOrig[nI][1]):IsEmpty()
		Else
			lIsEmpty := .F.
		EndIf
		If !lIsEmpty
			lRet := .F.
			Exit
		EndIf
	Next nI
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIsIncons
Rotina para verificar do Grid para a origem dos dados
se o histórico está inconsistente e ajusta quando necessario.

@param aValOrigem Array com os valores e campos para incluir/validar no histórico
                    [n][1] Array com os campos e valores
                    [n][1][n][1] Nome do campo
                    [n][1][n][2] Valor do campo
                    [n][1][n][3] Nome do campo no histórico
                    [n][2] Linha quando a origem for um grid
@param xCpoCondOr, Nome do campo da condição do grid ou array quando forem vários campos
@param oGridHist , Objeto com os dados do Histórico
@param cCpoDtIni , Nome da data inicial do histórico
@param cCpoDtFim , Nome da data final do histórico
@param cAMIniPad , Data de inicio padrão para criar um histórico
@param cAnoMesAbr, Data de inicio para criar um novo período (só quando usa historico)
@param cAnoMesFec, Data final para fechar um período (só quando usa historico)

@Return lRet   .T. Se a linha do histórico está inconsistente

@author Luciano Pereira / Bruno Ritter
@since 14/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JIsIncons(aValOrigem, xCpoCondOr, oGridHist, cCpoDtIni, cCpoDtFim, cAMIniPad, cAnoMesAbr, cAnoMesFec)
	Local lRet        := .T.
	Local lDeleta     := .F.
	Local lCondExist  := .F.
	Local aCampos     := {}
	Local cNomeCpo    := ""
	Local cValCpoOri  := ""
	Local nLine       := 0
	Local nI          := 0
	Local nY          := 0
	Local nConta      := 0
	Local cValCond    := ""
	Local cTypeCondOr := ""
	Local lUsaHist    := SuperGetMV( 'MV_JURHS1',, .F. )

	For nLine := 1 To oGridHist:GetQtdLine()
		If !oGridHist:IsDeleted(nLine) .And.;
		   ( !lUsaHist .Or. Empty(oGridHist:GetValue(cCpoDtFim, nLine)) ) // Se usa histórico, só podemos ajustar o período que está em aberto.
			lDeleta  := .F.

			If !lUsaHist .And. Len(aValOrigem) == 0
				lDeleta := .T.

			ElseIf !lUsaHist .And. oGridHist:GetValue(cCpoDtIni, nLine) != cAMIniPad
				lDeleta := .T.

			ElseIf !Empty(xCpoCondOr)
				
				cTypeCondOr := ValType(xCpoCondOr)
				If cTypeCondOr == "C"
					cValCond := oGridHist:GetValue(xCpoCondOr, nLine)
	
					For nI := 1 To Len(aValOrigem)
						aCampos    := aValOrigem[nI][1]
						lCondExist := .F.
	
						For nY := 1 To Len(aCampos)
							cNomeCpo   := aCampos[nY][3]
							cValCpoOri := aCampos[nY][2]
	
							If xCpoCondOr == cNomeCpo .And. cValCond == cValCpoOri
								lCondExist := .T.
								Exit
							EndIf
						Next nY
	
						If lCondExist
							Exit
						EndIf
					Next nI
				ElseIf cTypeCondOr == "A" // Mais de um campo na condição, usado na Participação do Cliente e do Caso
					
					cValCond  := oGridHist:GetValue(xCpoCondOr[1], nLine)
					cValCond2 := oGridHist:GetValue(xCpoCondOr[2], nLine)
	
					For nI := 1 To Len(aValOrigem)
						aCampos    := aValOrigem[nI][1]
						lCondExist := .F.
						nConta     := 0
						
						For nY := 1 To Len(aCampos)
							cNomeCpo   := aCampos[nY][3]
							cValCpoOri := aCampos[nY][2]
	
							If ( xCpoCondOr[1] == cNomeCpo .Or. xCpoCondOr[2] == cNomeCpo ) .And. ( cValCond == cValCpoOri .Or. cValCond2 == cValCpoOri )
								nConta ++
								If ( lCondExist := nConta == 2 )
									Exit
								EndIf
							EndIf
						Next nY
	
						If lCondExist
							Exit
						EndIf
					Next nI
				
				EndIf

				If !lCondExist
					If lUsaHist .And. cAnoMesAbr != oGridHist:GetValue(cCpoDtIni, nLine)
						oGridHist:GoLine(nLine)
						lRet := lRet .And. oGridHist:SetValue(cCpoDtFim, cAnoMesFec)
					Else
						lDeleta := .T.
					EndIf
				EndIf
			EndIf

			If lDeleta
				oGridHist:GoLine( nLine )
				lRet := lRet .And. oGridHist:DeleteLine()
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf
	Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRetValOri
Rotina para retornar um array com os valores dos campos de origem com a mesma estrutura
quando for um grid ou field

@param oModel, modelo principal da rotina.
@param aMldCps, Array com os campos e id do model
                [n][1] Id do modelo dos campos
                [n][2] Array com os campos do modelo
                [n][2][n][1] Nome do campos do model
                [n][2][n][2] Nome do campo no histórico

@return aValOrigem, Array com os valores e campos para incluir/valida no histórico
                    [n][1] Array com os campos e valores
                    [n][1][n][1] Nome do campo
                    [n][1][n][2] Valor do campo
                    [n][1][n][3] Nome do campo no histórico
                    [n][2] Linha quando a origem for um grid

@author Bruno Ritter / Luciano Pereira
@since 13/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRetValOri(oModel, aMldCpos, lGrid )
	Local oGridTemp  := Nil
	Local oMdlTemp   := Nil
	Local aCpoTemp   := {}
	Local nQtdLine   := 0
	Local cCpoOrig   := ""
	Local cCpoHist   := ""
	Local aCpoVal    := {}
	Local nY         := 0
	Local nLine      := 0
	Local nMdl       := 0
	Local aValOrigem := {}
	Local cIdModel   := ""

	If lGrid
		cIdModel  := aMldCpos[1][1]
		oGridTemp := oModel:GetModel(cIdModel)
		If !oGridTemp:IsEmpty()
			aCpoTemp := aMldCpos[1][2]
			nQtdLine := oGridTemp:GetQtdLine()

			For nLine := 1 To nQtdLine
				If !oGridTemp:IsDeleted(nLine)

					ASize(aCpoVal, 0)
					For nY := 1 To Len(aCpoTemp)
						cCpoOrig := aCpoTemp[nY][1]
						cCpoHist := aCpoTemp[nY][2]

						aAdd(aCpoVal, {cCpoOrig, oGridTemp:GetValue(cCpoOrig, nLine), cCpoHist})
					Next nY

					aAdd(aValOrigem, {aClone(aCpoVal), nLine})
				EndIf
			Next nLine
		EndIf

	Else
		For nMdl := 1 To Len(aMldCpos)
			cIdModel := aMldCpos[nMdl][1]
			oMdlTemp := oModel:GetModel(cIdModel)
			aCpoTemp := aMldCpos[nMdl][2]

			For nY := 1 To Len(aCpoTemp)
				cCpoOrig := aCpoTemp[nY][1]
				cCpoHist := aCpoTemp[nY][2]

				aAdd(aCpoVal, {cCpoOrig, oMdlTemp:GetValue(cCpoOrig), cCpoHist})
			Next nY
		Next nMdl

		aAdd(aValOrigem, {aClone(aCpoVal), Nil})
	EndIf

Return aValOrigem

//-------------------------------------------------------------------
/*/{Protheus.doc} JURHSTSET
Rotina para setar os valores dos campos.

@param oGridHist, Grid do histórico
@param aCampos[n] Array com os campos e valores
               [n][1] Nome do campo
               [n][2] Valor do campo
               [n][3] Nome do campo no histórico

@Return lRet   .T. Todos os campos foram gravados

@author Luciano Pereira / Bruno Ritter
@since 14/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURHSTSET(oGridHist, aCampos)
	Local lRet     := .F.
	Local nI       := 0
	Local nQtd     := Len(aCampos)
	Local nSucesso := 0

	For nI := 1 To nQtd
		If oGridHist:LoadValue(aCampos[nI][3], aCampos[nI][2])
			nSucesso += 1
		EndIf
	Next

	lRet := nQtd == nSucesso

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur070VMIni
Validação da data inicial no cadastro de histórico

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JHISTVMIni(cAlias)
	Local lRet       := .T.
	Local lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .T. ) // Considerar a alteração dos cadatros ajustando o históricos no mês anterior
	Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )
	Local dData      := MsDate()
	Local dDataIni   := FwFldGet(cAlias + "_AMINI")
	Local dDataFim   := FwFldGet(cAlias + "_AMFIM")

	If JVldAnoMes(dDataIni)

		If lHstMesAnt .And. lUsaHist
			dData := MsSomaMes(dData, -1)
		EndIf

		If dDataIni > MesAno(dData)
			lRet := JurMsgErro(STR0014) //"Não é permitido histórico futuro"
		EndIf

		If lRet .And. !Empty(dDataFim) .And. dDataIni > dDataFim
			lRet := JurMsgErro(STR0015) //"Ano-Mes final deve ser maior que Ano-Mes inicial"
		EndIf

	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JHistValid
Validação da data inicial no cadastro de histórico

@param oGrid,    objeto, Objeto com grid do histórico.
@param aCpoCond, array , Array formado com o nome dos campos para identificar uma linha única.

@Return lRet .T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 10/12/09
@version 2.0
/*/
//-------------------------------------------------------------------
Function JHistValid(oGrid, aCpoCond)
	Local lRet       := .T.
	Local lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .T. ) // Considerar a alteração dos cadatros ajustando o históricos no mês anterior
	Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )
	Local cMsg       := ""
	Local cSolucao   := ""
	Local cCondLine  := ""
	Local cAlias     := oGrid:GetStruct():GetTable()[1]
	Local cAMInicial := cAlias + "_AMINI"
	Local cAMFinal   := cAlias + "_AMFIM"
	Local cVlAMIni   := oGrid:GetValue(cAMInicial)
	Local cVlAmFinal := oGrid:GetValue(cAMFinal)
	Local cAMIniCond := ""
	Local cAMFimCond := ""
	Local nOperation := oGrid:GetOperation()
	Local nLinhaAtu  := oGrid:GetLine()
	Local nPosAMIni  := 1
	Local nPosAMFim  := 2
	Local nPosLine   := 3
	Local nI         := 0
	Local aColsOrd   := {}
	Local dData      := MsDate()

	Default aCpoCond := {}

	If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR

		// Valida o formato da do ano mês.
		lRet := JVldAnoMes(cVlAMIni) .And. JVldAnoMes(cVlAmFinal)

		If lRet
			If lHstMesAnt .And. lUsaHist
				dData := MsSomaMes(dData, -1)
			EndIf

		EndIf

		If lRet
			// Monta array da data e condições semelhantes sem as linhas deletadas.
			aEval(aCpoCond, {|cCondicao| cCondLine += cValToChar(oGrid:GetValue(cCondicao, nLinhaAtu)) })
			aColsOrd := JGeraColOrd(oGrid, cAMInicial, cAMFinal, aCpoCond, cCondLine)

			For nI := 1 To Len(aColsOrd)
				cAMIniCond := aColsOrd[nI][ nPosAMIni ]
				cAMFimCond := aColsOrd[nI][ nPosAMFim ]
				cSolucao   := i18n(STR0250, {aColsOrd[nI][nPosLine]}) // "Ajuste os valores para não sobrepor o hitórico da linha '#1'."

				//Não permitir inclusão de mais de 1 hist com ano-mês final em branco para a mesma condição
				If Empty(cVlAmFinal) .And. Empty(cAMFimCond) .And. !Empty(cAMIniCond) .And. cAMIniCond != cVlAMIni
					cMsg := STR0025 // "É preciso preencher o ano-nês final deste histórico"
					lRet := .F.
					Exit
				EndIf

				//Não permitir inclusão da data futura, com exceção de tabelas onde a criação dos registros é feita diretamente nos históricos manualmente
				If Len(aCpoCond) == 0 .Or. (Len(aCpoCond) > 1 .And. !(Substr(aCpoCond[1], 1, 3) $ "NUW|NV0|OHR|OHO"))
					If cVlAMIni > MesAno(dData) .Or. (!Empty(cVlAmFinal) .And. cVlAmFinal > MesAno(dData))
						lRet := .F.
						cMsg := STR0014 //"Não é permitido histórico futuro"
					EndIf
				EndIf

				//Não permitir períodos sobrepostos
				//Verifica se o ano-mês inicial é menor ou igual a algum ano-mês final de período anterior
				If (cAMIniCond < cVlAMIni) .And. (cAMFimCond >= cVlAMIni) .And. (cAMIniCond != cAMFimCond)
					lRet  := .F.
					cMsg  := STR0026 + CRLF +; // "Períodos sobrepostos no histórico."
					         I18N(STR0251,; // "O campo '#1' com o valor '#2' está menor ou igual ao campo '#3' com o valor '#4'."
					                {AllTrim(RetTitle(cAMInicial));
					                , Transform(cVlAMIni, '@R 9999-99');
					                , AllTrim(RetTitle(cAMFinal));
					                , Transform(cAMFimCond, '@R 9999-99')})
					Exit
				EndIf

				//Verifica se o ano-mês final é maior ou igual a algum ano-mês inicial de período posterior
				If !Empty(cVlAmFinal) .And. (cAMIniCond > cVlAMIni) .And. (cAMIniCond <= cVlAmFinal) .And. (cAMIniCond != cAMFimCond)
					lRet  := .F.
					cMsg  := STR0026 + CRLF +; // "Períodos sobrepostos no histórico."
					         I18N(STR0252,; // "O campo '#1' com o valor '#2' está maior ou igual ao campo '#3' com o valor '#4'."
					                {AllTrim(RetTitle(cAMFinal));
					                , Transform(cVlAmFinal,'@R 9999-99');
					                , AllTrim(RetTitle(cAMInicial));
					                , Transform(cAMIniCond,'@R 9999-99')})
					Exit
				EndIf

				//Verifica se o ano-mês inicial do período aberto é menor ou igual a algum ano-mês final
				If Empty(cVlAmFinal) .And. (cAMFimCond >= cVlAMIni) .And. !Empty(cAMFimCond)
					lRet  := .F.
					cMsg  := STR0026 + CRLF + STR0253 //#"Períodos sobrepostos no histórico" ##"Já existe um histório contido no periódo informado."
					Exit
				EndIf

				//Verifica se o ano-mês inicial é maior que algum ano-mês inicial em aberto
				If !Empty(cVlAmFinal) .And. (cAMIniCond <= cVlAMIni) .And. Empty(cAMFimCond)
					lRet  := .F.
					cMsg  := STR0026 + CRLF + STR0254 //#"Períodos sobrepostos no histórico" ##"O periodo informado está contido em outro histório."
					Exit
				EndIf
			Next nI

			If !lRet
				JurMsgErro(cMsg,, cSolucao)
			EndIf
		EndIf
	EndIf

	JurFreeArr(@aColsOrd)
	Asize(aCpoCond, 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGeraColOrd
Validação da data final no cadastro de histórico

@param oGrid     , Grid do histórico para ser validado.
@param cAMInicial, Nome do campo ano/mês incial
@param cAMFinal  , Nome do campo ano/mês final
@param aCpoCond  , Array simples com os nomes dos campos para condicionar o retorno
@param cValCond  , Valor de condição concatenada conforme o aCpoCond

@Return aColsOrd , [n] Array formado por subarrays com os valores do ano/mês inicial, final
                       e os valores das condições, ordenado por condição e ano/mês
                        [n][1] Ano/mês incial
                        [n][2] Ano/mês final
                        [n][3] Linha no histórico
                        [n][n] condições

@author Bruno Ritter / Luciano Pereira
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGeraColOrd(oGrid, cAMInicial, cAMFinal, aCpoCond, cValCond)
	Local cCondHist    := ""
	Local nI           := 0
	Local aAux         := {}
	Local aColsOrd     := {}
	Local nQtdLines    := oGrid:GetQtdLine()

	Default aCpoCond   := {}

	For nI := 1 To nQtdLines
		If !oGrid:IsDeleted(nI) .And. !oGrid:IsEmpty(nI)
			// Verifica se a linha pertence a condição da linha alterada.
			cCondHist := ""
			aEval(aCpoCond, {|cCondicao| cCondHist += cValToChar(oGrid:GetValue(cCondicao, nI))})

			If Empty(cValCond) .Or. cCondHist == StrTran(cValCond, ",", "")
				aAdd(aAux, oGrid:GetValue(cAMInicial, nI))
				aAdd(aAux, oGrid:GetValue(cAMFinal, nI))
				aAdd(aAux, nI)

				aEval(aCpoCond, {|cCondicao| aAdd(aAux, oGrid:GetValue(cCondicao, nI)) })

				aAdd(aColsOrd, aClone(aAux))
				ASize(aAux, 0)
			EndIf
		EndIf
	Next
	aSort( aColsOrd,,, { |aX, aY| aX[1] > aY[1] } )

Return aColsOrd

//-------------------------------------------------------------------
/*/{Protheus.doc} JHISTVMFim
Validação da data final no cadastro de histórico

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JHISTVMFim(cAlias)
	Local lRet := .F.

	If JVldAnoMes(FwFldGet(cAlias + "_AMFIM"))
		lRet := Vazio(M->&(cAlias + "_AMFIM")) .Or. FwFldGet(cAlias + "_AMFIM") >= FwFldGet(cAlias + "_AMINI")
		If !lRet
			JurMsgErro(STR0015) //"Ano-Mes final deve ser maior que Ano-Mes inicial"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JLoadGrid
Faz a carga dos dados da grid e ordena decrescente pelo campo informado

@author Felipe Bonvicini Conti
@since 05/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JLoadGrid( oGrid, cCampo, oModel)
	Local nOperacao := oGrid:GetModel():GetOperation()
	Local aStruct   := {}
	Local nAt       := 0
	Local aRet      := {}

	If nOperacao <> OP_INCLUIR
		aRet := FormLoadGrid(oGrid)
		
		// Ordena decrescente pelo campo informado
		If Len(aRet) > 0
			aStruct := oGrid:oFormModelStruct:GetFields()
			If ( nAt := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == cCampo } ) ) > 0
				aSort( aRet,,, { |aX,aY| aX[2][nAt] > aY[2][nAt] } )
			EndIf
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JValidDts
Função utilizada para validar se a data inicial é menor do que a final.

@author Felipe Bonvicini Conti
@since 14/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JValidDts(cCpoDataIni, cCpoDataFim)
	Local lRet := .T.

	If !Empty(FWFLDGET(cCpoDataIni)) .And. !Empty(FWFLDGET(cCpoDataFim)) .And. ;
			FWFLDGET(cCpoDataIni) > FWFLDGET(cCpoDataFim)
		lRet := JurMsgErro(STR0020) // "A Data Final deve ser maior do que a Data Inicial"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldFaixas
Função utilizada para validar sobreposição de faixas.

@Params 	  cCpoIni 	 Campo de Inicio da Faixa
cCpoFim   Campo de Final da Faixa
cCpoCod   Código da Faixa

@Return		nPos 			 Linha do grid onde há sobreposição

@author David G. Fernandes
@since 18/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldFaixas(oGrid, cCpoIni, cCpoFim, cCpoCod)
	Local nOperation := oGrid:GetModel():GetOperation()
	Local nPosIni    := 1
	Local nPosFim    := 2
	Local nPosCod    := 3
	Local nPosSobre  := 0
	Local aColsOrd   := {}
	Local nI         := 0

	If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR

		//Não permitir Faixas sobrepostas
		For nI := 1 To oGrid:GetQtdLine()
			If !oGrid:IsDeleted(nI) .And. !oGrid:IsEmpty(nI)
				aAdd(aColsOrd, {oGrid:GetValue(cCpoIni, nI), oGrid:GetValue(cCpoFim, nI), oGrid:GetValue(cCpoCod, nI)})
			EndIf
		Next

		//Ordena os dados em uma copia, para nao prejudicar a referencia do aCols
		aSort( aColsOrd,,, { |aX,aY| aX[nPosIni] > aY[nPosIni] } )

		//Verifica se existe valores intercalados entre as faixas
		If nPosSobre == 0 .And. !Empty(oGrid:GetValue(cCpoFim))
			nPosSobre := ascan(aColsOrd, {|x| (((x[nPosIni] >= oGrid:GetValue(cCpoIni) .And. x[nPosIni] <= oGrid:GetValue(cCpoFim)) .Or. ;
				(x[nPosFim] >= oGrid:GetValue(cCpoIni) .And. x[nPosFim] <= oGrid:GetValue(cCpoFim))  .Or.   ;
				(oGrid:GetValue(cCpoIni) >= x[nPosIni] .And. oGrid:GetValue(cCpoIni) <= x[nPosFim] .And.   ;
				oGrid:GetValue(cCpoFim) >= x[nPosIni] .And. oGrid:GetValue(cCpoFim) <= x[nPosFim]))) .And. ;
				x[ nPosCod ] <> oGrid:GetValue(cCpoCod) .And. ;
				x[ nPosIni ] <> x[ nPosFim ] } )
		Else
			nPosSobre := 1
		EndIf

	EndIf

Return nPosSobre

//-------------------------------------------------------------------
/*/{Protheus.doc} JMdlNewLine
Função utilizada para verificar se a única linha do model é valida.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 26/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JMdlNewLine(oModel)
	Local lRet := .F.

	If oModel:GetQtdLine() == 1
		oModel:GoLine(1)
		aDados := oModel:GetData()
		If aDados[1][MODEL_GRID_ID] == 0 .And. !oModel:IsUpdated()
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRetDtEnc
Calcula Quantidade de Dias Uteis entre duas datas.

@param 	dData1  Primeira Data
@param 	nQtde   Qtde de dias

@sample Data := JRetDtEnc( CToD( '01/10/09' ), 10 )

@author Jacques Alves Xavier
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JRetDtEnc( dData1, nQtde, lDecr )
	Local dData  := dData1
	Local nQtTot := nQtde

	ParamType 0 Var dData1       As Date Optional Default Date()

	While nQtTot > 0
		If (dData == DataValida( dData ))
			nQtTot -= 1
		EndIf

		Iif (!lDecr, dData++, dData--)
	EndDo

Return dData

Function JurConvVal(cMoedaNac, cMoedaFat, cMoedaCond, nValor, cDtCotacao)
	Local aRet     := {,,,}
	Local aSQL     := {}
	Local nTaxa1   := 0
	Local nTaxa2   := 0
	Local cSemTaxa := '2'
	Local cSQL     := ""
	Local cErro    := ""

	/*
	Parâmetros
	1 - Moeda Nacional (MOENAC)
	2 - Moeda Fatura (@IN_MOEFAT )
	3 - Moeda da Condição (MOECOND)
	4 - @VALOR a ser convertido (@VALOR)
	5 - @IN_TIPOCALC (@IN_TIPOCALC = 1 - Pré-Fatura / 2 - Regerar Pré / 3 - Minuta de Pré /
	4 - Minuta da Fatura / 5 - Fatura / 6 - Regerar Fatura /
	7 - Conferência Fatura)
	6 - Data da Cotação (DTCOT = AAAAMMDD)
	Return @OUT_RESULT, @OUT_TAXA1, @OUT_TAXA2 (NUMBER)
	*/

	cSQL := "SELECT CTP_TAXA FROM " + RetSqlname('CTP')
	cSQL +=  " WHERE CTP_FILIAL = '" + xFilial("CTP") + "' AND D_E_L_E_T_ = ' ' "
	cSQL +=    " AND CTP_DATA = '" + cDtCotacao + "'"
	cSQL +=    " AND CTP_MOEDA = '" + cMoedaCond + "'"
	aSQL := JurSQL(cSQL, {"CTP_TAXA"})
	If !Empty( aSQL )
		nTaxa1 := aSQL[1][1]
	Else
		nTaxa1 := 1
	EndIf

	cSQL := "SELECT CTP_TAXA FROM " + RetSqlname('CTP')
	cSQL +=  " WHERE CTP_FILIAL = '" + xFilial("CTP") + "' AND D_E_L_E_T_ = ' ' "
	cSQL +=    " AND CTP_DATA  = '" + cDtCotacao + "' "
	cSQL +=    " AND CTP_MOEDA = '" + cMoedaFat + "' "
	aSQL := JurSQL(cSQL, {"CTP_TAXA"})
	If !Empty( aSQL )
		nTaxa2 := aSQL[1][1]
	Else
		nTaxa2 := 1
	EndIf

	If (cMoedaFat == cMoedaCond .And. cMoedaFat == cMoedaNac) .Or. (cMoedaFat == cMoedaCond)
		aRet[1] := nValor
		aRet[2] := nTaxa1
		aRet[3] := nTaxa2
	Else
		If cMoedaFat == cMoedaNac
			If nTaxa1 > 0 .Or. !Empty(nTaxa1)
				aRet[1] := Round((nValor / nTaxa1), 2)   //FAZER O ROUND DO RESULTADO PARA DUAS CASAS DECIMAIS
				aRet[2] := nTaxa1
				aRet[3] := 1
			Else
				cSemTaxa := '1'
				cErro    := STR0021 + cMoedaCond + STR0022 + cDtCotacao // "É necessário informar a cotação da moeda " e " na data "
			EndIf
		Else
			If cMoedaCond == cMoedaNac
				If nTaxa1 > 0 .Or. !Empty(nTaxa2)
					aRet[1] := Round((nValor * nTaxa2), 2)   //FAZER O ROUND DO RESULTADO PARA DUAS CASAS DECIMAIS
					aRet[2] := nTaxa2
					aRet[3] := 1
				Else
					cSemTaxa := '1'
					cErro    := STR0021 + cMoedaCond + STR0022 + cDtCotacao // "É necessário informar a cotação da moeda " e " na data "
				EndIf
			Else
				If (nTaxa1 > 0 .Or. !Empty(nTaxa1)) .And. (nTaxa2 > 0 .Or. !Empty(nTaxa1))
					aRet[1] := Round(((nValor * nTaxa1) / nTaxa2), 2)   //FAZER O ROUND DO RESULTADO PARA DUAS CASAS DECIMAIS
					aRet[2] := nTaxa1
					aRet[3] := nTaxa2
				Else
					cSemTaxa := '1'
					cErro    := STR0021 + cMoedaCond + STR0022 + cDtCotacao // "É necessário informar a cotação da moeda " e " na data "
				EndIf
			EndIf
		EndIf
	EndIf

	If cSemTaxa == '1'
		aRet[1] := nValor
		aRet[2] := 1
		aRet[3] := 1
	EndIf

	aRet[4] := cErro

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCorrIndic
Função utilizada para corrigir um determinado valor quanto a tabela de indices.

@Param nValorBase, Valor a ser calculado, podendo ser nulo
@Param cDataBas  , Data base do valor
@Param cDataVenc , Data de vencimento
@Param nPeriodic , Periodiciade que será calculado o valor
@Param nIndice   , Código do indice(NW5)
@Param cTpRetorno, Tipo de retorno, sendo o valor calculado, ou a taxa do indice ("V", "I")
@Param lAutomato , Se verdadeiro indica que a execução é chamada via automação

@Return Valor calculado, ou a taxa do indice

@author Felipe Bonvicini Conti
@since 12/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCorrIndic(nValorBase, cDataBase, cDataVenc, nPeriodic, cIndice, cTpRetorno, lShowErro, cCompl, lAutomato)
	Local nRet            := 0
	Local fRet            := DEC_CREATE("0", 12, 11)
	Local cErro           := ""
	Local fTaxa           := DEC_CREATE("1", 12, 11)
	Local fTaxaIndice     := DEC_CREATE("1", 12, 11)
	Local cDataAux
	Local cProxDtCor
	Local aSql            := {}
	Local fTaxaCadas      := DEC_CREATE("0", 12, 11)

	Default nValorBase    := 0
	Default cDataBase     := Date()
	Default cDataVenc     := Date()
	Default nPeriodic     := 0
	Default cIndice       := ""
	Default cTpRetorno    := "V"
	Default lShowErro     := .T. // para não exibir a msg durante a geração do lançamentos em lote
	Default cCompl        := ""
	Default lAutomato     := .F.

	cDataAux   := JurDtAdd( cDataBase, "M", 1 )
	cProxDtCor := JurDtAdd( cDataBase, "M", nPeriodic )
	cDataVenc  := JSToFormat(cDataVenc, "YYYYMM") + "01"

	While JSToFormat(cDataAux,'YYYYMM') <= JSToFormat(cDataVenc,'YYYYMM')

		cQuery := "SELECT NW6_PVALOR VALOR "
		cQuery +=  " FROM " + RetSqlName("NW6") + " NW6 "
		cQuery += " WHERE NW6_FILIAL = '" + xFilial("NW6") + "' AND NW6.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND NW6_CINDIC ='" + cIndice + "' "
		cQuery +=   " AND NW6_DTINDI ='" + JSToFormat(JurDtAdd(cDataAux, "M", -1), "YYYYMM") + "01' "
		cQuery +=   " AND NW6_VALOR IS NOT NULL "

		aSql := JurSQL(cQuery, "VALOR")
		If Empty(aSql)
			fTaxaCadas := DEC_CREATE("0", 12, 11)
			If (JSToFormat(JurDtAdd(cDataAux, "M", -1), 'yyyy-mm') < JSToFormat(JurDtAdd(Date(), "M", -1), 'YYYY-MM'))
				cErro := STR0023 + JurGetDados('NW5', 1, xFilial('NW5') + cIndice, 'NW5_DESC') + STR0024 + JSToFormat(JurDtAdd(cDataAux, "M", -1), 'YYYY-MM')
				//"Não existe valor do índice " + cIndice + " cadastrado no Ano-Mês " + cDataAux
			EndIf
		Else
			fTaxaCadas := DEC_CREATE((StrTran((aSql[1][1]), ',', '.')), 12, 11)
		EndIf

		If JSToFormat(cDataAux,'YYYY-MM') == JSToFormat(cProxDtCor,'YYYY-MM')
			fTaxaIndice := DEC_MUL((fTaxa), (DEC_ADD(DEC_CREATE("1", 12, 11), (DEC_DIV(fTaxaCadas, DEC_CREATE("100", 12, 11))))))
			cProxDtCor  := JurDtAdd(cProxDtCor, "M", nPeriodic)
		EndIf

		fTaxa    := DEC_MUL((fTaxa), (DEC_ADD(DEC_CREATE("1", 12, 11), (DEC_DIV(fTaxaCadas, DEC_CREATE("100", 12, 11))))))
		cDataAux := JurDtAdd(cDataAux, "M", 1)

	EndDo

	Do Case
	Case cTpRetorno == "V"
		fRet := DEC_RESCALE(DEC_MUL(DEC_CREATE(nValorBase, 12, 11), fTaxaIndice), 8, 0)
		nRet := Val(cValToChar(fRet))
	Case cTpRetorno == "I"
		fRet := DEC_RESCALE(fTaxa, 8, 0)
		nRet := Val(cValToChar(fRet))
	EndCase
	
	If !lAutomato .And. !Empty(cErro)
		If lShowErro
			JurMsgErro(cErro)
		Else
			AutoGrLog(cCompl + cErro + CRLF) // "Log de geração: "
		EndIf
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSA6
Retorna a informação do banco, agência e conta para
o inicializador do browse

@Param 	cBanco		Código do banco
@Param 	cAgencia	Código da agencia
@Param 	cConta		Código da conta
@Param 	cRet		Campo de retorno

@author Juliana Iwayama Velho
@since 18/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSA6(cBanco, cAgencia, cConta, cRet)
Return JurGetDados("SA6", 1, xFilial("SA6") + cBanco + cAgencia + cConta, cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURINSIDIO
Função utilizada para incluir todos os idiomas nas telas de Tipo de
Despesas, Tipo de Atividade e Categoria de Participantes.

@author Felipe Bonvicini Conti
@since 22/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURADDIDIO(oGrid, cTable,nTab)
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local nQtdLnNR1  := JurQtdReg("NR1")
	Local aSaveLines := FWSaveRows()

	Default nTab     := 0

	If oGrid:GetModel():GetOperation() == OP_INCLUIR

		NR1->(dbSetOrder(1))

		NR1->(dbgotop())
		While !NR1->(EOF())
			If  cTable == "NR3" .or. nTab == 1
				lRet := oGrid:SetValue(cTable + "_CIDIOM", NR1->NR1_COD ) .And. oGrid:SetValue(cTable + "_DESCHO", "")
			Else
				lRet := oGrid:SetValue(cTable + "_CIDIOM", NR1->NR1_COD ) .And. oGrid:SetValue(cTable + "_DESC", "")
			EndIf

			If lRet
				nQtdLnNR1--
			Else
				Exit
			EndIf

			If nQtdLnNR1 > 0
				oGrid:AddLine()
			EndIf
			NR1->(dbSkip())
		EndDo

	EndIf
	RestArea(aArea)
	FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldDesc
Função utilizada para validar campos de descrição.

@param 	oGrid	Objeto Model
@param 	aCampos	Array com os campos a validar

@return Valor lógico: .T. -> Todas as descrições estão OK    .F. -> Uma das descrições não está OK

@sample lRet := JurVldDesc( oModelNR3, { "NR3_DESCHO", "NR3_DESCDE", "NR3_NARRAP" )

@author Felipe Bonvicini Conti
@since 25/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldDesc( oGrid, aCampos )
	Local lRet      := .T.					//retorno da função
	Local nLineOld  := oGrid:nLine			//linha atual que a grid esta posicionada
	Local nQtdLn    := oGrid:GetQtdLine()	//quantidade de linhas da grid
	Local nLoop1							//contador do numero de linhas da grid
	Local nLoop2							//contador do numero de campos passados
	Local nQtdCp							//quantidade de campos passados
	Local aCpoVal   := {}					//array com os campos que não estao preenchidos
	Local cStrCpos  := ""					//String com todos os campos que não foram preenchidos
	Local cCampo    := ""					//String com o nome do campo posicionado no array

	Default aCampos := {}

	nQtdCp := Len( aCampos )

	If ! nQtdCp == 0 //Verifica se não foram passados campos para validação
		For nLoop1 := 1 To nQtdLn
			oGrid:GoLine( nLoop1 )
			For nLoop2 := 1 To nQtdCp
				//Carrega o nome do campo para validação
				cCampo := aCampos[ nLoop2 ]
				If ! oGrid:IsDeleted() .And. Empty( FwFldGet( cCampo ) )
					//Verifica se ja existe o campo no array para não duplicar as descrições da mensagem
					//Guarda a descrição do campo para uso fora dos loops
					nAux := aScan( aCpoVal, { | _x| _x[ 1 ] == cCampo } )
					IIf( nAux == 0, aadd( aCpoVal, { cCampo, AvSX3( cCampo )[ 5 ] } ), NIL )
				EndIf
			Next nLoop2
		Next nLoop1

		//Verifica se foram encontrados campos sem preenchimento
		If ! Empty( aCpoVal )
			lRet := .F.
			//Monta string com todos os campos não preenchidos
			For nLoop1 := 1 To Len( aCpoVal )
				cStrCpos += aCpoVal[ nLoop1 ][ 2 ] + CRLF
			Next nLoop1
			JurMsgErro( STR0027 + CRLF + cStrCpos ) // "É preciso incluir todas as descrições!"
		EndIf

	Else

		//Avisa o usuário em caso de erro na passagem de parametros
		//Retorna falso para a rotina chamadora caso o array de campos esteja vazio
		ApMsgInfo( STR0031 ) //"Erro nos parametros. Comunique a TOTVS."
		lRet := .F.

	EndIf

	oGrid:GoLine(nLineOld) //Retorna para a linha original da grid

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSA1PG
Verifica se a consulta padrão de cliente filtrando pelo grupo ou
pelo cliente/loja pagador
Uso Geral.

@Return cRet	 		Comando para filtro

@sample @#JURSA1PG()

@author Jacques Alves Xavier
@since 05/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSA1PG()
	Local cRet := "@#@#"

	If ! IsPesquisa()
		If !(Empty(FWFldGet("NW2_CGRUPO")))
			cRet   := "@#SA1->A1_GRPVEN == '" + FWFldGet("NW2_CGRUPO") + "'@#"
		Else
			cRet   := "@#SA1->A1_COD == '" + FWFldGet("NW2_CCLIEN") + "' .AND. SA1->A1_LOJA == '" + FWFldGet("NW2_CLOJA") + "'@#"
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSGNUT
Função utilizada no inicializador dos campos para sugestão de cliente
e loja.

@Return cRet	 		Cliente ou Loja

@author Juliana Iwayama Velho
@since 21/12/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSGNUT()
	Local aArea  := {}
	Local cRet   := ''
	Local cCampo := AllTrim(ReadVar())

	Do Case
	Case "NUT_CCLIEN" $ cCampo

		If !INCLUI
			If IsInCallStack('JURA070')
				cRet := NVE->NVE_CCLIEN
			ElseIf IsInCallStack('JURA096') .And. !Empty(M->NT0_CCLIEN)
				cRet := M->NT0_CCLIEN
			Else
				cRet := ''
			EndIf
		Else
			If IsInCallStack('JURA096') .And. !Empty(M->NT0_CCLIEN)
				cRet := M->NT0_CCLIEN
			Else
				cRet := ''
			EndIf
		EndIf

	Case "NUT_CLOJA" $ cCampo

		If !INCLUI
			If IsInCallStack('JURA070')
				cRet := NVE->NVE_LCLIEN
			ElseIf IsInCallStack('JURA096') .And. !Empty(M->NT0_CLOJA)
				cRet := M->NT0_CLOJA
			Else
				cRet := ''
			EndIf
		Else
			If IsInCallStack('JURA096') .And. !Empty(M->NT0_CLOJA)
				cRet := M->NT0_CLOJA
			Else
				cRet := ''
			EndIf
		EndIf

	Case "NUT_DCLIEN" $ cCampo
		aArea  := GetArea()

		If !INCLUI
			If IsInCallStack('JURA096')
				If SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA == xFilial("SA1") + NUT->NUT_CCLIEN + NUT->NUT_CLOJA .And. M->NT0_COD == NUT->NUT_CCONTR
					cRet := SA1->A1_NOME
				ElseIf M->NT0_COD == NUT->NUT_CCONTR
					cRet := Posicione("SA1", 1, xFilial("SA1") + NUT->NUT_CCLIEN + NUT->NUT_CLOJA, "A1_NOME")
				EndIf

				If Empty(cRet)					
					If SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA == xFilial("SA1") + M->NT0_CCLIEN + M->NT0_CLOJA
						cRet := SA1->A1_NOME
					Else
						cRet := Posicione("SA1", 1, xFilial("SA1") + M->NT0_CCLIEN + M->NT0_CLOJA, "A1_NOME")
					EndIf
					
				EndIf

			Else
				cRet := Posicione("SA1", 1, xFilial('SA1') + NUT->( NUT_CCLIEN + NUT_CLOJA ), "A1_NOME")
			EndIf
		Else
			If IsInCallStack('JURA096') .And. !Empty(M->NT0_DCLIEN)
				cRet := Posicione("SA1", 1,  xFilial( 'SA1') + M->NT0_CCLIEN + M->NT0_CLOJA, "A1_NOME")
			Else
				cRet := ''
			EndIf
		EndIf

		RestArea(aArea)
	End Case

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMarkALL
Marca Todos

@author Felipe Bonvicini Conti
@since 28/04/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMarkALL(oBrowse, cTabela, cCampo, lMarcar, bCondicao, lClearFlt)
	Local aArea      := GetArea()
	Local cFiltro    := ''
	Local bFiltro    := { || }
	Local cFiltOld   := ''
	Local bFiltOld   := { || }
	Local cMarca     := oBrowse:Mark()

	Default bCondicao := {|| .T.}
	Default lClearFlt := .T.

	If lClearFlt .And. oBrowse:oBrowse:oFWFilter <> NIL
		cFiltro := oBrowse:oBrowse:oFWFilter:GetExprADVPL()
	EndIf

	If !Empty( cFiltro )

		cFiltOld := (cTabela)->( dbFilter() )
		bFiltOld := IIf( !Empty( cFiltOld ), &( ' { || ' + AllTrim( cFiltOld ) + ' } ' ), '' )

		bFiltro  := &( ' { || ' + cFiltro + ' } ' )

		(cTabela)->( dbSetFilter( bFiltro, cFiltro ) )

	EndIf

	(cTabela)->( dbGoTop() )

	While !( (cTabela)->( EOF() ) )
		If Eval(bCondicao)
			RecLock( cTabela, .F. )
			(cTabela)->&cCampo := IIf( lMarcar, cMarca, '  ' )
			(cTabela)->(MsUnLock())
		EndIf
		(cTabela)->( dbSkip() )
	EndDo

	If !Empty( cFiltro )

		(cTabela)->( dbClearFilter() )
		If !Empty( cFiltOld )
			(cTabela)->( dbSetFilter( bFiltOld, cFiltOld ) )
		EndIf

	EndIf

	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JurUserEmi
Inclusão do usuário de emissão da fatura

@author Clóvis Eduardo Teixeira
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurUserEmi()
	Local lRet  := .T.
	Local cUser := JurUsuario(__cUSERID)

	RD0->(dbSetOrder(1))
	If !RD0->(dbSeek(xFilial("RD0") + cUser))
		lRet := .F.
	Else
		If RD0->RD0_MSBLQL != "2" //"Código de participante inativo"
			lRet := .F.
		EndIf

		If !Empty(RD0->RD0_DTADEM) //Verificando se o participante tem data de demissão cadastrada
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNS0()
Filtro da Consulta padrão de Atividade Ebilling (NS0).

@param  cCliente	Nome do campo de cliente
@param  cLoja	    Nome do campo de loja

@Return cRet	 	Comando para filtro

@author Luciano Pereira dos Santos
@since 20/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNS0()
	Local cRet := "@#@#"

	Do Case
	Case IsInCallStack('JURA145')
		cRet := "@#NS0->NS0_CDOC == '" + JAEMPEBILL(cCliOr, cLojaOr) + "'@#"
	OtherWise
		cRet := "@#@#"
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSA1VAR
Altera as variaveis da consulta padrão de cliente filtrando pelo grupo e perfil Cliente/Pagador
Uso Geral.

@param  cFil	Código da filial a ser filtrada! Nulo ou Branco não utilizada.
@param  cGrp	Código do grupo a ser filtrado! Nulo ou Branco não utilizado.
@param  cPerf  Valor do perfil a ser filtrado! Nulo ou Branco não utilizado.

@Return lRet	 	.T./.F. As informações são válidas ou não

@sample JURSA1VAR("","001","1")

@author Antonio Carlos Ferreira
@since 08/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSA1VAR(cFil, cGrp, cPerf)
	Default cFil  := ""
	Default cGrp  := ""
	Default cPerf := ""

	cXFilial := If(ValType(cFil) == "C",  cFil , "")
	cXGrupo  := If(ValType(cGrp) == "C",  cGrp , "")
	cXPerfil := If(ValType(cPerf) == "C", cPerf, "")

	lVarFiltro := !( Empty(cXFilial) ) .Or. !( Empty(cXGrupo) ) .Or. !( Empty(cXPerfil) )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSA1PFL
Consulta padrão de cliente filtrando pelo grupo e perfil Cliente/Pagador
Uso Geral.

@param lPreload  .T./.F. Indica se a consulta deve ser pré-carregada

@Return lRet     .T./.F. As informações são válidas ou não

@sample JURSA1PFL()

@author Juliana Iwayama Velho
@since 19/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSA1PFL(lPreload)
Local aArea       := GetArea()
Local aCampos     := {}
Local aFiltro     := {}
Local cCampo      := AllTrim(ReadVar())
Local cFilFilt    := ""
Local cFiltName   := ""
Local cFiltro     := ""
Local cGrupo      := ''
Local cLoja       := ""
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cPerfil     := ''
Local cSQL        := ""
Local lFilFilt    := .F.
Local lIgnLojaAut := .F. //Ignora o filtro gerado pelo parâmetro MV_JLOJAUT de retorna apenas Lojas = "00"
Local lLote       := .F.
Local lRet        := .F.
Local lSitCli     := .F.
Local nI          := 0

Default lPreload  := .T.

	If ("_CLIPG" $ cCampo .OR. "NWF_CCLIAD" $ cCampo)
		lIgnLojaAut := .T.
	EndIf

	// Colocar todas as condições com "IsInCallStack()" no começo do Do Case - Felipe Conti
	Do Case
	Case lVarFiltro   //Favor utilizar estas variaveis para realizar a filtragem. Altere as variaveis atraves da função JURSA1VAR().

		cFilFilt := If(!Empty(cXFilial), cXFilial, cFilFilt)
		cGrupo   := If(!Empty(cXGrupo) , cXGrupo , cGrupo)
		cPerfil  := If(!Empty(cXPerfil), cXPerfil, cPerfil)

	Case IsInCallStack('JURA201') .Or. IsInCallStack('JA144DIVTS')
		If !Empty(cGetGrup)
			cGrupo := cGetGrup
		EndIf
		cPerfil := '1'

	Case IsInCallStack('JURA063')
		cPerfil := '1'

	Case IsInCallStack('JURA109')
		If !Empty(FWFldGet("NWM_CGRUPO"))
			cGrupo := FWFldGet("NWM_CGRUPO")
		EndIf
		cPerfil := '1'

	Case IsInCallStack('JA144DIVTS') .Or. IsInCallStack('JA145DLG') .Or.;
			IsInCallStack('JA143DLG') .Or. IsInCallStack('JA142DLG')
		lLote := .T.
		cPerfil := '1'

	Case IsInCallStack('JURA027') .And. !lLote .And. !IsInCallStack("GETFILTER") //alterado pois a tela de lote e chamada pela JURA027
		If !Empty(FwFldGet("NV4_CGRUPO"))
			cGrupo := FwFldGet("NV4_CGRUPO")
		EndIf
		cPerfil := '1'

	Case IsInCallStack('JURA243')
		lFilFilt    := .T.
		cFilFilt    := FWxFilial("SA1")
		If l243CliPag
			cPerfil     := '1#2'
			lIgnLojaAut := .T.
		Else
			cPerfil     := '1'
			lIgnLojaAut := .F.
		EndIf

	Case "NT0_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NT0_CGRPCL"))
			cGrupo := FwFldGet("NT0_CGRPCL")
		EndIf
		cPerfil := '1'

	Case "NVE_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NVE_CGRPCL"))
			cGrupo := FwFldGet("NVE_CGRPCL")
		EndIf
		cPerfil  := '1'
		lFilFilt := .T.
		If FWModeAccess("NVE", 1) == "E" // Verifica se a tabela Caso é exclusiva
			cFilFilt := FWxFilial("SA1")
		EndIf

	Case "NVV_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NVV_CGRUPO"))
			cGrupo := FwFldGet("NVV_CGRUPO")
		Endif
		If "NVV_CCLIEN" $ cCampo
			cPerfil := '1'
		EndIf

	Case "NVW_CCLIEN" $ cCampo
		If IsInCallStack('JURA033') .And. !Empty(FwFldGet("NVV_CGRUPO"))
			cGrupo := FwFldGet("NVV_CGRUPO")
		EndIf
		cPerfil := '1'

	Case "NW2_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NW2_CGRUPO"))
			cGrupo := FwFldGet("NW2_CGRUPO")
		EndIf
		cPerfil := '1'

	Case "NUE_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NUE_CGRPCL"))
			cGrupo := FwFldGet("NUE_CGRPCL")
		EndIf
		cPerfil := '1'

	Case "NVY_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NVY_CGRUPO"))
			cGrupo := FwFldGet("NVY_CGRUPO")
		EndIf
		cPerfil := '1'

	Case "NV4_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NV4_CGRUPO"))
			cGrupo := FwFldGet("NV4_CGRUPO")
		EndIf
		cPerfil := '1'

	Case "NWF_CCLIEN" $ cCampo
		If !Empty(FwFldGet("NWF_CGRPCL"))
			cGrupo := FwFldGet("NWF_CGRPCL")
		EndIf
		cPerfil := '1'

	Case "NXP_CLIPG" $ cCampo
		lFilFilt := .T.
		cFilFilt := FWxFilial("SA1")
		cGrupo   := ""
		cPerfil  := '1#2'

	Case "NXG_CLIPG" $ cCampo
		lFilFilt := .T.
		cFilFilt := FWxFilial("SA1")
		cGrupo   := ""
		cPerfil  := '1#2'

	Case "NUT_CCLIEN" $ cCampo
		lFilFilt := .T.
		cFilFilt := FWxFilial("SA1")
		cGrupo   := ""
		cPerfil  := '1'
		lSitCli  := FWFldGet("NT0_SIT") == "2"

	Case "NUH_COD" $ cCampo .Or. IsInCallStack("JURAPAD026")
		lFilFilt := .T.
		cFilFilt := FWxFilial("SA1")
		cGrupo   := ""
		cPerfil  := '1'

	Case Substr(cCampo, 4, Len(cCampo)) $ "OHF_CCLIEN|OHG_CCLIEN|NZQ_CCLIEN|OHB_CCLID|NTP_CCLIEN"
		lFilFilt   := .T.
		cFilFilt   := FWxFilial("SA1")
		cPerfil    := '1'

	Case "A1_COD" $ cCampo
		If Type("M->A1_GRPVEN") <> "U" .And. !Empty(M->A1_GRPVEN)
			cGrupo  := M->A1_GRPVEN
			cPerfil := '1'
		ElseIf IsInCallStack("J203FilUsr") .And. !Empty(oGrClien:valor)
			cGrupo  := oGrClien:valor
			cPerfil := '1'
		EndIf

	End Case

	IIf( !Empty(FWxFilial("SA1")), aAdd(aCampos, 'A1_FILIAL'), )
	aAdd(aCampos, 'A1_COD')
	IIf( cLojaAuto == "2" .Or. lIgnLojaAut, aAdd(aCampos, 'A1_LOJA'), )
	aAdd(aCampos, 'A1_NOME')
	aAdd(aCampos, 'A1_CGC')

	/* Filtro
	[1] Condição para adicionar o filtro ou não
	[2] Tipo = A(Comando ADVPL) / S(Comando SQL)
	[3] Titulo do filtro
	[4] Comando
	[5] Tabela para filtro relacional (apenas para comando SQL)
	*/
	If !Empty(cFilFilt)
		aAdd( aFiltro, {lFilFilt    , 'A', STR0087, "A1_FILIAL == '" + cFilFilt + "'"} ) //"Filial"
	EndIf

	aAdd( aFiltro, {!Empty(cGrupo)  , 'A', STR0036, "A1_GRPVEN == '" + cGrupo + "'"} ) //"Grupo"

	cFiltName := I18N(STR0161, {AllTrim(RetTitle("A1_LOJA"))}) //Campo '#1' automático
	lFilFilt  := cLojaAuto == "1" .And. !lIgnLojaAut
	cLoja     := JurGetLjAt()
	aAdd( aFiltro, {lFilFilt , 'A', cFiltName, "A1_LOJA == '" + cLoja + "'"} )

	aAdd( aFiltro, {!Empty(cPerfil), 'S', STR0037, "NUH_PERFIL IN " + FormatIn(cPerfil, "#"), 'NUH'} ) // "Perfil"

	aAdd( aFiltro, {lSitCli, 'S', STR0299, "NUH_SITCAD = '2'", 'NUH'} ) // "Situação"

	//Abre a area se ela estiver fechada, pois a utlização dessa consulta em outros modulos a tabela NUH não é aberta por padrão,
	//assim o filtro do NUH_PERFIL não é aplicado quando a tabela não está aberta.
	If Select('NUH') == 0
		DBSelectArea('NUH')
	EndIf

	For nI := 1 To Len( aFiltro )
		If aFiltro[nI][1]
				cFiltro += " AND " + aFiltro[nI][4]
		EndIf
	Next nI

	cFiltro := SubStr(cFiltro, 5)
	cFiltro := StrTran(cFiltro,"==","=")

	cSQL := "SELECT "
				
	For nI := 1 To Len(aCampos)
		cSQL += aCampos[nI] + ", "
	Next

	cSQL +=         " SA1.R_E_C_N_O_ RECNOSA1 "

	cSQL +=  " FROM " + RetSqlName('SA1') + " SA1"
	cSQL += " INNER JOIN " + RetSqlName('NUH') + " NUH "
	CsQL +=    " ON ( NUH.NUH_COD = SA1.A1_COD"
	cSQL +=         " AND NUH.NUH_LOJA = SA1.A1_LOJA"
	CsQL +=         " AND NUH.NUH_FILIAL = SA1.A1_FILIAL ) "

	cSQL += " WHERE SA1.D_E_L_E_T_ =  ' ' "
	cSQL +=   " AND NUH.D_E_L_E_T_ =  ' ' "

	nResult := JurF3SXB("SA1", aCampos, cFiltro,.T. ,.F. , "JURA148", cSQL, lPreload)

	RestArea( aArea )

	If nResult > 0
		lRet := .T.
		DbSelectArea("SA1")
		SA1->(dbgoTo(nResult))
	EndIf
	

	//Conforme o chamado DFRM1-168, alteração no ReadVar é devido não ter nenhum campo em foco no meio tempo de fechar o browse da consulta e a volta para o modelo
	__ReadVar := cCampo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JDelImgPre(cPreFat, cPastaDest, cMsgLog)
Função para remover os arquivos de imagem da pré-fatura.

@Param cPreFat     Código da Pré-fatura
@Param cPastaDest  Pasta da imagem do relatório a
@Param  cMsgLog     Mensagem de log da rotina, passada por referência

@author Luciano Pereira dos Santos
@since 30/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDelImgPre(cPreFat, cPastaDest, cMsgLog)
	Local lRet         := .T.
	Local aArquivo     := {}
	Local nI           := 0

	Default cMsgLog    := ''
	Default cPastaDest := JurImgPre(cPreFat, .T., .F.)

	aArquivo := Directory(cPastaDest + "prefatura_" + cPreFat + "*.*")

	For nI := 1 To Len(aArquivo)
		If File(cPastaDest + aArquivo[nI][1])
			If FErase(cPastaDest + aArquivo[nI][1]) != 0
				cMsgLog += "JDelImgPre..: " + I18N(STR0119, {Lower(cPastaDest + aArquivo[nI][1])}) + CRLF  //Não foi possível remover o arquivo '#1'. Verifique se o arquivo está aberto.
				lRet := lRet .and. .F.
			EndIf
		EndIf
	Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurImgPre(cPref, lfullPath)
Rotina para recupera o caminho da Imagem da Pré-Fatura

@Param  cPref      Código da Pré-fatura
@Param  lfullPath  Se .T. concatena o caminho do MV_JIMGFT com a pastas
                   destino dos paramentros MV_JPASPRE e MV_JPASGRP.
@Param  lAbsRoot   Fornece o caminho absoluto do rootpath (nessario para a função CpyS2TEx)
@Param  cMsgLog    Log da rotina, passada por referência

@author Luciano Pereira dos Santos
@since 30/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurImgPre(cPref, lfullPath, lAbsRoot, cMsgLog)
	Local cRetDir     := ""
	Local cCrysPas    := SuperGetMV("MV_JCRYPAS", Nil, "") //Se o paramentro esta preenchido o servidor esta em Cloud
	Local cImgPref    := Iif(Empty(cCrysPas), SuperGetMV("MV_JIMGFT", Nil, ""), "") //Se o servidor esta em Cloud o caminho deve ser obrigatoriamente apartir do rootpath
	Local cAbsRoot    := JurFixPath(GetSrvProfString("RootPath", ""), 0, 1)
	Local cMsgRet     := ''

	Default lfullPath := .F.
	Default lAbsRoot  := .F.
	Default cMsgLog   := ''

	If lfullPath
		If Empty(cImgPref)
			cRetDir := Iif(lAbsRoot, cAbsRoot, '\') + J201GetPFat(cPref, @cMsgRet) //Caminho relativo ou absoluto do servidor + MV_JPASPRE e MV_JPASGRP
		Else
			cRetDir := JurFixPath(cImgPref, 0, 1) + J201GetPFat(cPref, @cMsgRet) //Caminho absoluto especificado no paramentro MV_JIMGFT + MV_JPASPRE e MV_JPASGRP.
		EndIf

		If !Empty(cMsgRet)
			cMsgLog += CRLF + "JurImgPre---> " +cMsgRet
		EndIf

	Else
		If Empty(cImgPref)
			cRetDir := Iif(lAbsRoot, cAbsRoot, '\') //Caminho relativo ou absoluto do servidor
		Else
			cRetDir := JurFixPath(cImgPref, 0, 1) //Caminho absoluto especificado no paramentro MV_JIMGFT
		EndIf
	EndIf

	If !ExistDir(cRetDir)
		cMsgLog += CRLF + "JurImgPre...: " + I18N(STR0120, {cRetDir}) //#"Não foi possível localizar o diretório '#1'."
	EndIf

Return cRetDir

//-------------------------------------------------------------------
/*/{Protheus.doc} JurImgFat(cEscrit, cFatura, lfullPath, lAbsRoot, cMsgLog)
Rotina para recupera o caminho da Imagem da Fatura verificando a estrutura do servidor

@Param  cEscrit   Código do escritório Fatura
@Param  cFatura   Código da Fatura
@Param  lDestPath  Se .T. concatena  o caminho com a pastas destino dos paramentros MV_JPASFAT e MV_JPASGRF
@Param  cMsgLog   Log da rotina, passada por referência

@author Luciano Pereira dos Santos

@Obs Se o servidor estiver em Cloud configurar o paramentro MV_JCRYPAS com caminho do item EXPORT do
crysini.ini relativo ao rootpath servidor do rootpath Ex: ''

@since 30/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurImgFat(cEscrit, cFatura, lfullPath, lAbsRoot, cMsgLog)
	Local cRetDir     := ""
	Local cCrysPas    := SuperGetMV("MV_JCRYPAS", Nil, "") //Se o paramentro esta preenchido o servidor esta em Cloud
	Local cImgFat     := Iif(Empty(cCrysPas), SuperGetMV("MV_JIMGFT", Nil, ""), "") //Se o servidor esta em Cloud o caminho deve ser obrigatoriamente apartir do rootpath
	Local cAbsRoot    := JurFixPath(GetSrvProfString("RootPath", ""), 0, 1)
	Local cMsgRet     := ''

	Default lfullPath := .F.
	Default lAbsRoot  := .F.
	Default cMsgLog   := ''

	If lfullPath
		If Empty(cImgFat)
			cRetDir := Iif(lAbsRoot, cAbsRoot, '\') + J203GetPFat(cEscrit, cFatura, @cMsgRet) //Caminho relativo ou absoluto do servidor + MV_JPASFAT e MV_JPASGRF
		Else
			cRetDir := JurFixPath(cImgFat, 0, 1) + J203GetPFat(cEscrit, cFatura, @cMsgRet) //Caminho absoluto especificado no paramentro MV_JIMGFT + MV_JPASFAT e MV_JPASGRF.
		EndIf

		If !Empty(cMsgRet)
			cMsgLog += CRLF + "JurImgFat--> " + cMsgRet
		EndIf

	Else
		If Empty(cImgFat)
			cRetDir := Iif(lAbsRoot, cAbsRoot, '\') //Caminho relativo ou absoluto do servidor
		Else
			cRetDir := JurFixPath(cImgFat, 0, 1) //Caminho absoluto especificado no paramentro MV_JIMGFT
		EndIf
	EndIf

	If !ExistDir(cRetDir)
		cMsgLog += CRLF + "JurImgFat..: " + I18N(STR0120, {cRetDir}) //#"Não foi possível localizar o diretório '#1'."
	EndIf

Return cRetDir

//-------------------------------------------------------------------
/*/{Protheus.doc} JAWODspNWZ
Grava a tabela NWZ para WO de Despesas
@Param  cWoCodig   Código da Despesa

@author Daniel Magalhaes
@since 20/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAWODspNWZ(cWoCodig)
Local aArea       := GetArea()
Local cAliasQry   := GetNextAlias()
Local cQuery      := ""
Local cChave      := ""
Local lSeek       := .F.
Local aValorConv  := {}
Local cMoedaNac   := SuperGetMv("MV_JMOENAC",, "01") // Ajustar esta rotina para que a moeda gravada seja sempre igual a moeda nacional. O valor deverá ser convertido.
Local nValGrpDesp := 0        // Valor de agrupamento de despesas
Local cCodWO      := ""
Local cCClien     := ""
Local cCLoja      := ""
Local cCCaso      := ""
Local cCTpDsp     := ""
Local cGrupo      := ""
Local lNWZFilLan  := NVY->(ColumnPos("NVY_FILLAN")) > 0 .And. NWZ->(ColumnPos("NWZ_FILLAN")) > 0
Local cNVYFilLan  := IIF(lNWZFilLan, " NVY.NVY_FILLAN, ", "")
Local cFilLan     := ""

	cQuery += " SELECT NUF.NUF_COD, "
	cQuery +=        " NVY.NVY_CCLIEN, "
	cQuery +=        " NVY.NVY_CLOJA, "
	cQuery +=        " NVY.NVY_CCASO, "
	cQuery +=        cNVYFilLan //NVY.NVY_FILLAN
	cQuery +=        " NVY.NVY_CTPDSP, "
	cQuery +=        " NVY.NVY_CMOEDA, "
	cQuery +=        " NVY.NVY_DATA, "
	cQuery +=        " SUM(NVY.NVY_VALOR) SUM_VALOR "
	cQuery +=   " FROM " +  RetSQLName("NUF") + " NUF "
	cQuery +=  " INNER JOIN " + RetSQLName("NVZ") + " NVZ "
	cQuery +=     " ON (NVZ.NVZ_FILIAL = '" + xFilial("NVZ") + "' "
	cQuery +=    " AND NVZ.NVZ_CWO = NUF.NUF_COD "
	cQuery +=    " AND NVZ.D_E_L_E_T_ = ' ') "
	cQuery +=  " INNER JOIN " + RetSQLName("NVY") + " NVY "
	cQuery +=     " ON (NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=    " AND NVY.NVY_COD    = NVZ.NVZ_CDESP "
	cQuery +=    " AND NVY.D_E_L_E_T_ = ' ') "
	cQuery +=  " WHERE NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
	cQuery +=    " AND NUF.NUF_COD = '" + cWoCodig + "' "
	cQuery +=    " AND NUF.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY"
	cQuery +=        " NUF.NUF_COD, "
	cQuery +=        " NVY.NVY_CCLIEN, "
	cQuery +=        " NVY.NVY_CLOJA, "
	cQuery +=        " NVY.NVY_CCASO, "
	cQuery +=        cNVYFilLan //NVY.NVY_FILLAN
	cQuery +=        " NVY.NVY_CTPDSP, "
	cQuery +=        " NVY.NVY_CMOEDA, "
	cQuery +=        " NVY.NVY_DATA "
	cQuery +=  " ORDER BY "    // Mover a contabilização da função JAWOLancR() para a função JAWODspNWZ().
	cQuery +=        " NUF.NUF_COD, "
	cQuery +=        " NVY.NVY_CCLIEN, "
	cQuery +=        " NVY.NVY_CLOJA, "
	cQuery +=        " NVY.NVY_CCASO, "
	cQuery +=        cNVYFilLan //NVY.NVY_FILLAN
	cQuery +=        " NVY.NVY_CTPDSP, "
	cQuery +=        " NVY.NVY_CMOEDA, "
	cQuery +=        " NVY.NVY_DATA"

	cQuery := ChangeQuery(cQuery, .F.)

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )
	TcSetField(cAliasQry, "NVY_DATA", "D", 8, 0)

	NWZ->(DbSetOrder(1)) //NWZ_FILIAL+NWZ_CODWO+NWZ_CCLIEN+NWZ_CLOJA+NWZ_CCASO+NWZ_CTPDSP+NWZ_CMOEDA+NVY_FILLAN

	nValGrpDesp := 0        // Valor de agrupamento de despesas
	cGrupo      :=  (cAliasQry)->(NUF_COD + NVY_CCLIEN + NVY_CLOJA + NVY_CCASO + NVY_CTPDSP + IIF(lNWZFilLan, NVY_FILLAN, ""))

	While !(cAliasQry)->(Eof())
		cChave := xFilial("NWZ") + (cAliasQry)->(NUF_COD + NVY_CCLIEN + NVY_CLOJA + NVY_CCASO + NVY_CTPDSP)

		aValorConv := JA201FConv(cMoedaNac, (cAliasQry)->NVY_CMOEDA, (cAliasQry)->SUM_VALOR, "1", (cAliasQry)->NVY_DATA )

		// O agrupamento deve ser por Código WO, Cliente, loja, caso e tipo de despesa.
		cCodWO  := (cAliasQry)->NUF_COD
		cCClien := (cAliasQry)->NVY_CCLIEN
		cCLoja  := (cAliasQry)->NVY_CLOJA
		cCCaso  := (cAliasQry)->NVY_CCASO
		cCTpDsp := (cAliasQry)->NVY_CTPDSP
		cFilLan := ""

		If lNWZFilLan
			cFilLan := (cAliasQry)->NVY_FILLAN
			cChave += cFilLan
		EndIf
		nValGrpDesp += aValorConv[1]
		(cAliasQry)->(DbSkip())

		If (cGrupo <> (cAliasQry)->(NUF_COD + NVY_CCLIEN + NVY_CLOJA + NVY_CCASO + NVY_CTPDSP+ IIF(lNWZFilLan, NVY_FILLAN, ""))) .Or. (cAliasQry)->(Eof())
			If ! (cAliasQry)->(Eof())
				cGrupo := (cAliasQry)->(NUF_COD + NVY_CCLIEN + NVY_CLOJA + NVY_CCASO + NVY_CTPDSP+IIF(lNWZFilLan, NVY_FILLAN, ""))
			EndIf

			lSeek := NWZ->( DbSeek(cChave) )
			RecLock("NWZ", !lSeek)

			NWZ->NWZ_FILIAL := xFilial("NWZ")
			NWZ->NWZ_CODWO  := cCodWO
			NWZ->NWZ_CCLIEN := cCClien
			NWZ->NWZ_CLOJA  := cCLoja
			NWZ->NWZ_CCASO  := cCCaso
			NWZ->NWZ_CTPDSP := cCTpDsp
			NWZ->NWZ_CMOEDA := cMoedaNac
			NWZ->NWZ_VALOR  := nValGrpDesp
			If lNWZFilLan
				NWZ->NWZ_FILLAN  := cFilLan
			EndIf 
			NWZ->(MsUnlock())

			J170GRAVA("NUF", xFilial("NUF") + cCodWO, If(!lSeek, "3", "4"))

			nValGrpDesp := 0

		EndIf

	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JurX2Nome()
Rotina que retorna o nome da tabela

@param  cTab    Tabela que se deseja obter o nome

@return cRet    A descrição da tabela

@author Luciano Pereira dos Santos
@since 18/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurX2Nome(cTab)
	Local cRet  := ""
	Local aArea := GetArea()

	dbSelectArea("SX2")
	dbSetOrder(1)

	If dbSeek( cTab )
		cRet := AllTrim(X2Nome())
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetTitCaso
Função para buscar o titulo do caso.

@author Felipe Bonvicini Conti
@since 10/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetTitCaso(cClien, cLoja, cCaso)
	Local cRet      := ""

	Default cClien  := ""
	Default cLoja   := ""
	Default cCaso   := ""

	If !Empty(cClien) .And. !Empty(cLoja) .And. !Empty(cCaso)
		cRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_TITULO")
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCasoAtual
Função para buscar o cliente/loja/caso atual tratando a questão de casos em andamento/remanejados
quando o parametro "MV_JCASO1" for igual a 2 (Sequencia de caso independente do cliente).

@author Jacques Alves Xavier
@since 02/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCasoAtual(cCaso)
	Local aRet    := {}
	Local cQuery  := ""
	Local aCasos  := {}
	Local nI      := 0
	Local cQuery1 := ""
	Local aNY1    := {}
	Local cClien  := ""
	Local cLoja   := ""

	Default cCaso := ""

	cQuery := "SELECT NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS, NVE.NVE_SITUAC, NVE.R_E_C_N_O_ NVERECNO"
	cQuery +=  " FROM " + RetSqlName("NVE") + " NVE "
	cQuery += " WHERE NVE.NVE_FILIAL = '" + xFilial( "NVE" ) + "'"
	cQuery +=   " AND NVE.NVE_NUMCAS = '" + cCaso + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aCasos := JurSQL(cQuery, {"NVE_CCLIEN", "NVE_LCLIEN", "NVE_NUMCAS", "NVE_SITUAC", "NVERECNO"},,, .F.)

	If Len(aCasos) == 1
		aAdd(aRet, {aCasos[1][1], aCasos[1][2]})
	ElseIf Len(aCasos) > 1
		For nI := 1 To Len(aCasos)
			If aCasos[nI][4] == "1"
				aAdd(aRet, {aCasos[nI][1], aCasos[nI][2]})
				Exit
			EndIf
		Next nI

		If Empty(aRet)
			cQuery1 := "SELECT NY1_CCLIEN, NY1_CLOJA, MAX(NY1_SEQ) NY1_SEQ"
			cQuery1 += " FROM " + RetSqlName("NY1") + " NY1 "
			cQuery1 += " WHERE NY1.NY1_FILIAL = '" + xFilial( "NY1" ) + "'"
			cQuery1 += " AND NY1.NY1_CCASO = '" + cCaso + "'"
			cQuery1 += " AND D_E_L_E_T_ = ' ' "
			cQuery1 += " GROUP BY NY1_CCLIEN, NY1_CLOJA "
			cQuery1 += " ORDER BY MAX(NY1_SEQ) DESC "

			aNY1 := JurSQL(cQuery1, {"NY1_CCLIEN", "NY1_CLOJA"})

			If !Empty(aNY1) .And. Len(aNY1[1]) == 2
				cClien := aNY1[1][1]
				cLoja  := aNY1[1][2]
				aAdd(aRet, JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, {"NVE_CCLINV", "NVE_CLJNV"}))
			EndIf

		EndIf
	EndIf

	If Empty(aRet)
		aRet := {{CriaVar("NY1_CCLIEN"), CriaVar("NY1_CLOJA")}}
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPerHist
Rotina para validar lacunas de periodo e linhas duplicadas nas tabelas de histórico.

@Param		oGrid   - Modelo de dados da tabela de histórico a ser validada.
@Param		lValLac - Verifica lacunas de periodo.
@Param		aCampos - Array com os campos para validação adicional.

@Return		lRet  - .T. se não haver lacunas de periodo no grid do histórico.

@author Luciano Pereira dos Santos
@since 28/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURPerHist(oGrid, lValLac, aCampos)
	Local oStruct    := oGrid:GetStruct()
	Local lRet       := .T.
	Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )  //Habilita a gravação dos históricos
	Local lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .F. )  //Valida a patir do mês anterior
	Local cAlias     := oStruct:GetTable()[1]
	Local cAliasDesc := oStruct:GetTable()[3]
	Local cMsg       := ""
	Local cSolucao   := ""
	Local cAnoMes    := ""
	Local nOperation := oGrid:GetModel():GetOperation()
	Local nI         := 0
	Local nPosAMIni  := 1
	Local nPosAMFim  := 2
	Local aColsOrd   := {}

	Default lValLac  := .F.
	Default aCampos  := {}

	If lUsaHist .And. oGrid <> Nil .And. nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR //Inclusão (3) ou Alteração (4)

		lRet := JGridInteg(oGrid)

		If lRet .And. lValLac // Verifica se existe lacunas de período no Histórico
			aColsOrd := JGeraColOrd(oGrid, cAlias + "_AMINI", cAlias + "_AMFIM", aCampos)

			For nI := 1 To Len(aColsOrd)
				If nI == 1 .And. !Empty(aColsOrd[nI][nPosAMFim]) // Se o último mes estiver encerrado, verifica o mês de encerramento conforme o paramentro MV_JURHS2

					cAnoMes := Iif(lHstMesAnt, AnoMes(MsSomaMes(MsDate(), -2)), AnoMes(MsSomaMes(MsDate(), -1)))

					If aColsOrd[nI][nPosAMFim] != cAnoMes
						lRet    := .F.
						cAnoMes := Transform(cAnoMes, '@R 9999-99')
						cMsg    := STR0056 + AllTrim(RetTitle(cAlias + "_AMFIM")) + STR0057 + cAnoMes + "." // "Conforme o parâmetro MV_JURHS2, o último " - " válido para o histórico é "

						If (aColsOrd[nI][nPosAmIni] <= cAnoMes)
							cSolucao := I18N(STR0130, {Transform(aColsOrd[nI][nPosAmIni], '@R 9999-99'), cAnoMes, AllTrim(RetTitle(cAlias + "_AMFIM")), cAnoMes }) //"Insira um período de '#1' até '#2', ou encerre o período com o #3 '#4'."
						Else
							cSolucao := I18N(STR0141, {AllTrim(RetTitle(cAlias + "_AMFIM")), Transform('', '@R 9999-99') }) //"Para o período corrente, o #1 deve ser em aberto '#2'."
						EndIf

						JurMsgErro(I18n(STR0246, {cAliasDesc}) + CRLF + cMsg, , cSolucao) // "Existem inconsistências no preenchimento do '#1':"
						Exit
					EndIf
				EndIf

				If nI + 1 <= Len(aColsOrd)

					nAnoIcor := Val(Substr(aColsOrd[nI][nPosAMIni], 1, 4))   // ano da periodo da linha posicionda
					nAnoFant := Val(Substr(aColsOrd[nI+1][nPosAMFim], 1, 4)) // ano do periodo anterior.

					nMesIcor := Val(Substr(aColsOrd[nI][nPosAMIni], 5, 2))   // ano da periodo da linha posicionda
					nMesFant := Val(Substr(aColsOrd[nI+1][nPosAMFim], 5, 2)) // ano do periodo anterior.

					If (((nMesIcor + 12 * (nAnoIcor - nAnoFant)) - nMesFant) > 1) .And. (nAnoFant > 0 .And. nMesFant > 0) // diferença de no máximo um mês
						lRet := .F.

						cMsg := STR0049 + "'" + Transform(aColsOrd[nI+1][nPosAMFim], '@R 9999-99') + "'" // "Não pode haver lacunas de tempo entre "
						cMsg += STR0050 + "'" + Transform(aColsOrd[nI][nPosAMIni], '@R 9999-99') + "'."  // " e "

						cSolucao := I18N(STR0131, {AllTrim(RetTitle(cAlias + "_AMINI")), AllTrim(RetTitle(cAlias + "_AMFIM"))}) // "Efetue o ajuste nas lacunas do histórico. O '#1' do próximo período deve ser imediatamente posterior ao '#2' do periodo anterior."

						JurMsgErro(I18n(STR0246, {cAliasDesc}) + CRLF + cMsg, , cSolucao) // "Existem inconsistências no preenchimento do '#1':"
						Exit
					EndIf

				EndIf
			Next nI
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGridInteg
Valida a integridade do grid, se os campos X2UNICO forem editaveis.
Desta forma se uma chave for alterada e recriada acima da alterada,
ocorre um erro no commit do MVC

@Param  oGrid - Modelo de dados do grid.

@Return lRet - .T. se o model está integro

@author Bruno Ritter / Luciano Pereira
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGridInteg(oGrid)
	Local aRetTable  := oGrid:GetStruct():GetTable()
	Local aPKTable   := aRetTable[2]
	Local nTotalLine := oGrid:GetQtdLine()
	Local nX         := 0
	Local nY         := 0
	Local cAliasDesc := aRetTable[3]
	Local cVlPkConcX := ""
	Local cVlPkConcY := ""
	Local cNumDel    := ""
	Local cNumAlt    := ""
	Local lRet       := .T.
	Local cMsg       := ""
	Local cSolucao   := ""

	For nX := 1 To nTotalLine
		cVlPkConcX := ""
		aEval(aPKTable, {|cPkCpo| cVlPkConcX += Iif(oGrid:HasField(cPkCpo), oGrid:GetValue(cPkCpo, nX), "") })

		// Verifica linhas duplicadas no grid (considera também linha as deletadas para validar a violação de integridade)
		For nY := 1 To nTotalLine
			cVlPkConcY := ""
			aEval(aPKTable, {|cPkCpo| cVlPkConcY += Iif(oGrid:HasField(cPkCpo), oGrid:GetValue(cPkCpo, nY), "") })

			If nY != nX .And. cVlPkConcX == cVlPkConcY // não é a mesma linha e a chave é igual

				Do Case
					Case !oGrid:IsDeleted(nX) .And. !oGrid:IsDeleted(nY) // Se os dois não foram deletados, causa violação de integridade
						lRet := .F.
					Case oGrid:IsDeleted(nY) .And. !oGrid:IsDeleted(nX) .And. nY > nX // Se o registro deletado for posterior, causa violação de integridade
						lRet := .F.
					Case oGrid:IsDeleted(nX) .And. !oGrid:IsDeleted(nY) .And. nX > nY // Se o registro deletado for posterior, causa violação de integridade
						lRet := .F.
				EndCase

				If !lRet
					cNumDel  := cValtochar( Iif(oGrid:IsDeleted(nX), nX, nY ))
					cNumAlt  := cValtochar( Iif(oGrid:IsUpdated(nX), nX, nY ))

					cMsg     := I18n(STR0244, {cValtochar(nY), cValtochar(nX) }) // "As Linhas '#1' e '#2' possuem informações em duplicidade."
					cSolucao := I18n(STR0245, {cNumAlt, cNumDel }) // "Reverta as alterações da linha '#1' e/ou utilize a linha '#2'."
					Exit
				EndIf
			EndIf
		Next nY

		If !lRet
			Exit
		EndIf
	Next nX

	If !lRet
		JurMsgErro(I18n(STR0246, {cAliasDesc}) + CRLF + cMsg, , cSolucao) // "Existem inconsistências no preenchimento do '#1':"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JEBILLMOE()
Rotina de validação e preenchimento da Moeda E-billing nas telas de geração do E-billing 1998B e 2000

@Param   oEscri  - Escritório da Fatura
@Param   oFatura - Número da Fatura
@Param   oMoeda  - Moeda da Fatura

@Return  lRet

@author Cristina Cintra Santos
@since 05/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JEBillMoe(oEscri, oFatura, oMoeda)
	Local lRet   := .T.
	Local aArea  := GetArea()

	If !Empty( oEscri:GetValue() ) .And. !Empty( oFatura:GetValue() ) .And. Empty( oMoeda:GetValue() ) .Or. ;
	   !Empty( oMoeda:GetValue() ) .And. ( oEscri:IsChanged() .Or. oFatura:IsChanged() )

		NXA->( DbSetOrder(1) ) //NXA_FILIAL+NXA_CESCR+NXA_COD
		If NXA->( DbSeek( xFilial('NXA') + oEscri:GetValue() + oFatura:GetValue() ) )
			oMoeda:SetValue( JurGetDados('NXA', 1, xFilial('NXA') + oEscri:GetValue() + oFatura:GetValue(), 'NXA_CMOEDA') )
			oMoeda:Refresh()
		Else
			lRet := .F.
			Alert(STR0059) //"Fatura não encontrada."
		EndIf
	Else
		If !Empty( oMoeda:GetValue() ) .And. ( Empty( oEscri:GetValue() ) .Or. Empty( oFatura:GetValue() ) )
			oMoeda:Limpar()
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JEBillFatCanc
Valida se a fatura foi cancelada

@param 	oFatura		Número da fatura
@Return lRet		.T. - Fatura válida; .F. - Fatura cancelada

@author Luciano Pereira dos Santos
@since 06/06/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JEBillFatCanc(oEscri, oFatura)
	Local lRet  := .T.
	Local aArea := GetArea()

	If Empty(Posicione('NXA', 1, xFilial('NXA') + oEscri:Valor + oFatura:Valor, 'NXA_DTCANC'))
		lRet := .T.
	Else
		lRet := .F.
		Alert(STR0058) //"Não é possivel gerar arquivo de uma fatura cancelada!"
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JDescriMemo
Rotina que trata campo tipo MEMO

@author Jorge Luis Branco Martins Junior
@since 19/06/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDescriMemo(nRecno, cCampo)
	Local aArea     := GetArea()
	Local cVlrCampo := ""
	Local cTab      := Left(cCampo, 3)

	If  nRecno > 0
		&(cTab)->( dbGoTo( nRecno ))
		cVlrCampo := &(cTab)->(&(cCampo))
	EndIf

	RestArea(aArea)

Return cVlrCampo

//-------------------------------------------------------------------
/*/{Protheus.doc} JFiltraCaso
Tela de parâmetros para fazer filtro por caso.

@param oBrowse  Browser que sofre alteração do filtro

@author Luciano Pereira dos Santos
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFiltraCaso(oBrowse)
Local nOldArea    := Select()
Local oGetGrup    := Nil
Local oGetClie    := Nil
Local oGetLoja    := Nil
Local oGetCaso    := Nil
Local oCanSub     := Nil
Local oFatCan     := Nil
Local oMinuta     := Nil
Local oDlg        := Nil
Local lCancSub    := .F.
Local lFatCan     := .F.
Local lMinuta     := .F.
Local lRet        := .T.
Local cAliasMast  := ""
Local cAliasCaso  := ""
Local cFiltro     := ""
Local nData       := 0
Local nCpo        := 0
Local dDtIni      := Date() - 30
Local dDtFim      := Date()
Local cFilDt      := STR0105 //"Emissão"
Local oFilDt      := Nil
Local oDtIni      := Nil
Local oDtFim      := Nil
Local nDialog     := 0
Local oLayer      := FWLayer():New()
Local oMainColl   := Nil
Local aButtons    := {}
Local cCpoGrp     := ""
Local cCpoClie    := ""
Local cCpoLoja    := ""
Local cCpoCaso    := ""
Local cCpoDtEm    := ""

Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nLoj        := 0

Local bTitulo     := { |cCampo| SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)), AllTrim(X3Titulo()) }
Local cTitGrup    := ""
Local cTitClie    := ""
Local cTitLoja    := ""
Local cTitCaso    := ""

Private cGetGrup  := ""
Private cGetClie  := ""
Private cGetLoja  := ""
Private cGetCaso  := ""

If IsInCallStack('JURA202')
	cAliasMast := "NX0"
	cAliasCaso := "NX1"
	cFiltro    := "NX0_SITUAC!='1'"
	nDialog    := 90
ElseIf IsInCallStack('JURA204')
	cAliasMast := "NXA"
	cAliasCaso := "NXC"
	cFiltro    := "NXA_TIPO!='MF'"
	nDialog    := 90
	nData      := 80
ElseIf IsInCallStack('JURA096')
	cAliasMast := "NT0"
	cAliasCaso := "NUT"
	cFiltro    := ""
	nCpo       :=  5
EndIf

If cAliasMast == "NX0"
	cCpoGrp  := cAliasMast + "_CGRUPO"
	cGetGrup := Criavar(cCpoGrp, .F.)
Else
	cCpoGrp  := cAliasMast + "_CGRPCL"
	cGetGrup := Criavar(cCpoGrp, .F.)
EndIf

cCpoClie  := cAliasCaso + "_CCLIEN"
cCpoLoja  := cAliasCaso + "_CLOJA"
cCpoCaso  := cAliasCaso + "_CCASO"
cCpoDtEm  := cAliasMast + "_DTEMI"

cTitGrup  := Eval(bTitulo, cCpoGrp)
cTitClie  := Eval(bTitulo, cCpoClie)
cTitLoja  := Eval(bTitulo, cCpoLoja)
cTitCaso  := Eval(bTitulo, cCpoCaso)

cGetClie := Criavar(cCpoClie, .F.)
cGetLoja := Criavar(cCpoLoja, .F.)
cGetCaso := Criavar(cCpoCaso, .F.)

AADD(aButtons, {"", {|| (oBrowse:DeleteFilter(cAliasMast))}, STR0064, STR0064, {|| .T.}}) //"Remover Filtro"

DEFINE MSDIALOG oDlg TITLE STR0070 FROM 0, 0 TO 160 + nDialog, 480 PIXEL // "Filtrar por caso"

oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel('MainColl' )

oGetGrup := TJurPnlCampo():New(05+nCpo,05,50,22,oMainColl, cTitGrup, cCpoGrp, {|| },,,,,'ACY') //"Grupo"
oGetGrup:SetValid({||JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "GRP")})

oGetClie := TJurPnlCampo():New(05+nCpo,65,50,22,oMainColl,cTitClie, cCpoClie, {|| },,,,,'SA1NVE') //"Cliente"
oGetClie:SetValid({||JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "CLI")})

oGetLoja := TJurPnlCampo():New(05+nCpo,125,25,22,oMainColl,cTitLoja, cCpoLoja, {|| },,,,,) //"Loja"
oGetLoja:SetValid({||JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "LOJ")})
If(cLojaAuto == "1")
	oGetLoja:Visible(.F.)
	nLoj := 40
EndIf

oGetCaso := TJurPnlCampo():New(05+nCpo,165-nLoj,60,22,oMainColl,cTitCaso, cCpoCaso, {|| },,,,,'NVENX0') //"Caso"
oGetCaso:SetValid({||JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "CAS")})

oGetCaso:oCampo:bWhen := {|| JWhenCaso(oGetClie, oGetLoja, oGetCaso) }

If cAliasMast == "NX0"
	oCanSub := TJurCheckBox():New( 45, 05, STR0063, {|| }, oMainColl, 180, 008, , {|| } , , , , , , .T., , , )
	oCanSub:SetCheck(lCancSub)
	oCanSub:bChange := {|| lCancSub := oCanSub:Checked() }
EndIf

If cAliasMast == "NXA"
	oFatCan := TJurCheckBox():New( 35, 05, STR0071, {|| }, oMainColl, 180, 008, , {||} , , , , , , .T., , , ) //"Apresenta faturas canceladas?"
	oFatCan:SetCheck(lFatCan)
	oFatCan:bChange := {|| (Iif(lFatCan := oFatCan:Checked(), oFilDt:Enable(), (cFilDt := STR0105, oFilDt:SetValue(STR0105), oFilDt:Disable())), oFilDt:Refresh()) } //"Emissão"

	oMinuta := TJurCheckBox():New( 50, 05, STR0072, {|| }, oMainColl, 180, 008, , {|| } , , , , , , .T., , , ) //"Apresenta minutas?"
	oMinuta:SetCheck(lMinuta)
	oMinuta:bChange := {|| lMinuta := oMinuta:Checked() }

	oFilDt := TJurPnlCampo():New(65,05,60,25, oMainColl, STR0106, '', {|| },, STR0105,, lFatCan,,, (STR0105 + ";" + STR0107) ) //"Filtrar data por: " ## "Emissão" ### "Cancelamento"
	oFilDt:SetChange({|| cFilDt := Alltrim(oFilDt:Valor) })
EndIf

If cAliasMast $ "NXA|NX0"
	oDtIni := TJurPnlCampo():New(65, 005+nData, 60, 22, oMainColl, STR0108, cCpoDtEm,{|| },, DtoC(dDtIni),,,) //"Data início: "
	oDtIni:SetChange({|| dDtIni := oDtIni:Valor })

	oDtFim := TJurPnlCampo():New(65, 085+nData, 60, 22, oMainColl, STR0109, cCpoDtEm,{|| },, DtoC(dDtFim),,,) //"Data fim: "
	oDtFim:SetChange({|| dDtFim := oDtFim:Valor })
EndIf

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lRet := (JGetFltCaso(oBrowse, cGetClie, cGetLoja, cGetCaso,lCancSub,lFatCan,lMinuta,cFiltro,dDtIni,dDtFim,cFilDt)), IIf(lRet, oDlg:End(), .F.) },;
																	{||(oDlg:End())}, ,aButtons,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

DbSelectArea(nOldArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetFltCaso()
Função que devolve o browse filtrado para a dialog de pesquisa por casos.

@Param oBrowse   Estrutura da tela que sofre ação do filtro
@Param cGetClie	 Código do cliente
@Param cGetLoja	 Código da loja
@Param cGetCaso	 Código do Caso
@Param lCanSub   Filtro de situação de pré-fatura
@Param lFatCan   Filtro de faturas canceladas
@Param lMinuta   Filtro de minutas
@Param cFiltro   Filtro padrão das rotinas
@Param cDtIni    Filtro de data inicial
@Param cDtFim    Filtro de data final
@Param cFilDt    Filtro do tipo de data

@Return    @lret retorno com exito ou fracasso ao realizar o filtro.

@author Luciano Pereira dos Santos
@since 13/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetFltCaso(oBrowse, cGetClie, cGetLoja, cGetCaso, lCancSub, lFatCan, lMinuta, cFiltro, dDtIni, dDtFim, cFilDt)
Local cCaso      := SuperGetMV("MV_JCASO1",, "1")
Local nOldArea   := Select()
Local cQuery     := " "
Local cQryRes    := GetNextAlias()
Local lRet       := .T.
Local aSequen    := {}
Local cFilFat    := ''
Local aFiltro    := Iif( Valtype(oBrowse:FWFilter():GetFilter()) == "A", oBrowse:FWFilter():GetFilter(), {} )
Local nI         := 0
Local nY         := 0
Local nQtdFat    := 0
Local nQtdEsc    := 0
Local cEscrit    := ''
Local aFatura    := {}
Local cFilCon    := ''
Local cFilPre    := ''
Local nTamFil    := 1400 //A tecnologia promete 2000 bytes para o tamanho do filtro, mas o binario só esta aceitando por volta de 1400

Default lCancSub := .F.
Default lFatCan  := .F.
Default lMinuta  := .F.

If cCaso == "1" .And. (Empty(cGetClie) .And. Empty(cGetLoja))
	lRet := JurMsgErro(STR0127,, STR0066) //#"O código do cliente e/ou da loja não são válidos."   ##"Por favor, preencha corretamente as informações."
EndIf

If lRet .And. Empty(cGetCaso)
	lRet := JurMsgErro(STR0128,, STR0066) //#"O código do caso não é válido."  ##"Por favor, preencha corretamente as informações."
EndIf

If lRet .And. IsInCallStack('JURA204')
	If Empty(cFilDt)
		lRet := JurMsgErro(STR0143,, STR0110) //#"O filtro por tipo de data não foi informado."  ##"Por favor, selecione uma opção no filtro por data."
	EndIf
EndIf

If lRet .And. IsInCallStack( 'JURA202' )

	cQuery := " SELECT NX0.NX0_COD FROM " + RetSqlName("NX0") + " NX0, "
	cQuery += " " + RetSqlName("NX1") + " NX1 "
	cQuery += " WHERE NX0_FILIAL = '" + xFilial("NX0") + "' "
	cQuery += " AND NX1_FILIAL = '" + xFilial("NX0") + "' "
	cQuery += " AND NX0.NX0_COD = NX1.NX1_CPREFT "
	If !(lCancSub)
		cQuery += " AND NX0.NX0_SITUAC IN ('2','3','4','5','6','7','9','A','B','C','D','E','F') "
	Else
		cQuery += " AND NX0.NX0_SITUAC IN ('7','8', 'B') "
	EndIf

	If !Empty(dDtIni) .And. !Empty(dDtFim)
		cQuery += " AND NX0.NX0_DTEMI >= '" + DtoS(dDtIni) + "' "
		cQuery += " AND NX0.NX0_DTEMI <= '" + DtoS(dDtFim) + "' "
	EndIf

	If !Empty(cGetClie) .And. !Empty(cGetLoja)
		cQuery += " AND NX1.NX1_CCLIEN = '" + cGetClie + "' "
		cQuery += " AND NX1.NX1_CLOJA = '" + cGetLoja + "' "
	EndIf
	cQuery += " AND NX1.NX1_CCASO = '" + cGetCaso + "' "
	cQuery += " AND NX1.D_E_L_E_T_ = ' ' "
	cQuery += " AND NX0.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NX0.NX0_COD "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->( EOF() )
		aAdd(aSequen, (cQryRes)->NX0_COD)
		(cQryRes)->( dbSkip() )
	EndDo

	(cQryRes)->( DbCloseArea() )

	If Len(aSequen) > 0
		If aScan( aFiltro, { |aX| aX[1] == STR0067 } ) > 0
			oBrowse:DeleteFilter("NX0")
		EndIf

		nQtdFat := Len(aSequen)
		For nI  := 1 To nQtdFat

			cFilPre += "NX0_COD=='" + aSequen[nI] + "'"
			If nI != nQtdFat
				cFilPre += ".Or."
			EndIf

		Next nI

		If Len(cFiltro + cFilPre) <= nTamFil
			oBrowse:AddFilter(STR0067, cFiltro + ".And.(" + cFilPre + ")", .F., .T., , , , "NX0") // "Pesq. por Caso"
			oBrowse:Refresh(.T.)
		Else
			lRet := JurMsgErro(STR0125,, STR0126) //"O intervalo de tempo informado excedeu o retorno máximo de registros!" ## "Por favor, selecione um intervalo de tempo menor."
		EndIf

	Else
		lRet := JurMsgErro(STR0068,, STR0142) //#"Não foram encontradas pré-faturas para o caso informado!" ## "Verifique as informações contidas no filtro."
	EndIf

ElseIf lRet .And. IsInCallStack( 'JURA204' )

	cQuery := " SELECT NXA.NXA_CESCR, NXA.NXA_COD FROM " + RetSqlName("NXA") + " NXA, "
	cQuery += " " + RetSqlName("NXC") + " NXC "
	cQuery +=  " WHERE NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQuery +=    " AND NXC_FILIAL = '" + xFilial("NXC") + "' "
	cQuery +=    " AND NXA.NXA_CESCR = NXC.NXC_CESCR "
	cQuery +=    " AND NXA.NXA_COD = NXC.NXC_CFATUR "
	If !Empty(dDtIni) .And. !Empty(dDtFim)
		If cFilDt == Alltrim(STR0105) //"Emissão"
			cQuery += " AND NXA.NXA_DTEMI >= '" + DtoS(dDtIni) + "' "
			cQuery += " AND NXA.NXA_DTEMI <= '" + DtoS(dDtFim) + "' "
		ElseIf cFilDt == Alltrim(STR0107) //"Cancelamento"
			cQuery += " AND NXA.NXA_DTCANC >= '" + DtoS(dDtIni) + "' "
			cQuery += " AND NXA.NXA_DTCANC <= '" + DtoS(dDtFim) + "' "
		EndIf
	EndIf

	If !(lFatCan)
		cQuery += " AND NXA.NXA_SITUAC = '1' "
	EndIf
	If !(lMinuta)
		cQuery += " AND NXA.NXA_TIPO = 'FT' "
	EndIf
	If !Empty(cGetClie) .And. !Empty(cGetLoja)
		cQuery += " AND NXC.NXC_CCLIEN = '" + cGetClie + "' "
		cQuery += " AND NXC.NXC_CLOJA = '" + cGetLoja + "' "
	EndIf
	cQuery += " AND NXC.NXC_CCASO = '" + cGetCaso + "' "
	cQuery += " AND NXA.D_E_L_E_T_ = ' ' "
	cQuery += " AND NXC.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NXA.NXA_CESCR, NXA.NXA_COD "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	If !(cQryRes)->( EOF() )
		cEscrit := (cQryRes)->NXA_CESCR

		While !(cQryRes)->( EOF() )
			If (cQryRes)->NXA_CESCR == cEscrit
				aAdd(aFatura,(cQryRes)->NXA_COD) //grava N faturas
			Else
				aAdd(aSequen, {cEscrit, aFatura}) //grava o escritório com N faturas
				cEscrit := (cQryRes)->NXA_CESCR
				aFatura := {}
				aAdd(aFatura,(cQryRes)->NXA_COD) //Grava o primeiro registro do próximo escritorio
			EndIf
			(cQryRes)->( dbSkip() )
		EndDo
		aAdd(aSequen, {cEscrit, aFatura}) //Grava o último registro de escritorio com N faturas
	EndIf

	(cQryRes)->( DbCloseArea() )

	If Len(aSequen) > 0

		If aScan( aFiltro, { |aX| aX[1] == STR0067 } ) > 0
			oBrowse:DeleteFilter("NXA")
		EndIf

		nQtdEsc := Len(aSequen)
		For nI := 1 To nQtdEsc
			cFilFat += "(NXA_CESCR=='" + aSequen[nI][1] + "'.And.("
			aFatura := Aclone(aSequen[nI][2])
			nQtdFat := Len(aFatura)

			For nY  := 1 To nQtdFat
				cFilFat += "NXA_COD=='" + aFatura[nY] + "'"
				If nY != nQtdFat
					cFilFat += ".Or."
				Else
					cFilFat += ")"
				EndIf
			Next nY

			If nI != nQtdEsc
				cFilFat += ").Or."
			Else
				cFilFat += ")"
			EndIf
		Next nI

		If Len(cFiltro + cFilFat) <= nTamFil
			oBrowse:AddFilter(STR0067, cFiltro + ".And.(" + cFilFat + ")", .F., .T., , , , "NXA") // "Pesq. por Caso"
			oBrowse:Refresh(.T.)
		Else
			lRet := JurMsgErro(STR0125,, STR0126) //"O intervalo de tempo informado excedeu o retorno máximo de registros!" ## "Por favor, selecione um intervalo de tempo menor."
		EndIf
	Else
		lRet := JurMsgErro(STR0069,, STR0142) //#"Não foram encontradas faturas para o caso informado!" ## "Verifique as informações contidas no filtro."
	EndIf

ElseIf lRet .And. IsInCallStack( 'JURA096' )

	cQuery := " SELECT NT0.NT0_COD FROM " + RetSqlName("NT0") + " NT0, "
	cQuery += " " + RetSqlName("NUT") + " NUT  "
	cQuery +=   " WHERE NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQuery +=     " AND NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQuery +=     " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	If !Empty(cGetClie) .And. !Empty(cGetLoja)
		cQuery += " AND NUT.NUT_CCLIEN = '" + cGetClie + "' "
		cQuery += " AND NUT.NUT_CLOJA = '" + cGetLoja + "' "
	EndIf
	cQuery +=     " AND NUT.NUT_CCASO = '" + cGetCaso + "' "
	cQuery +=     " AND NT0.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NUT.D_E_L_E_T_ = ' ' "
	cQuery +=     " ORDER BY NT0.NT0_COD "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->( EOF() )
		aAdd(aSequen, (cQryRes)->NT0_COD)
		(cQryRes)->( dbSkip() )
	EndDo

	(cQryRes)->( DbCloseArea() )

	If Len(aSequen) > 0
		If aScan( aFiltro, { |aX| aX[1] == STR0067 } ) > 0
			oBrowse:DeleteFilter("NT0")
		EndIf

		nQtdFat := Len(aSequen)
		For nI  := 1 To nQtdFat

			cFilCon += "NT0_COD=='" + aSequen[nI] + "'"
			If nI != nQtdFat
				If Len(cFiltro + cFilCon) >= nTamFil
					Exit
				Else
					cFilCon += ".Or."
				EndIf
			EndIf

		Next nI

		oBrowse:AddFilter(STR0067, cFilCon, .F., .T., , , , "NT0") // "Pesq. por Caso"
		oBrowse:Refresh(.T.)
	Else
		lRet := JurMsgErro(STR0082,, STR0142) // "Não foram encontrados contratos para o caso informado." ## "Verifique as informações contidas no filtro."
	EndIf

EndIf

DbSelectArea(nOldArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurLogLanc()
Rotina para gerar o log dos lançamento x situção da pré-fatura para
operações em lote.

@param 	aPreFat  Array de pré-faturas e situação em que o caso do Lanc esta associado.
@param 	cPrefat  Pré-faturas em que o lançamento esta associado.
@param 	nOper    Tipo de operação Ex: 3=Inclusão, 4=alteração
@param  lText    Se retorna o log em forma de texto
@param  lRetira  informa que o lançamento foi retirado da pré-fatura

@author Luciano Pereira dos Santos
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLogLanc(aPreFat, cPrefat, nOper, lText, lRetira)
	Local cRet      := ""
	Local cMsgLog   := ""
	Local nI        := 0
	Local lCalLot   := .F.
	Local cFileLog  := ""
	Local cMemoLog  := ""
	Local aDirLog   := {}
	Local cMsgVinc  := ""
	Local cMsgTp    := ""
	Local lVinc     := .F.

	Default nOper   := 4
	Default lText   := .F.
	Default lRetira := .F.

	lCalLot := (IsInCallStack('JURA142') .Or. IsInCallStack('JURA143') .Or. IsInCallStack('JURA145') .Or.;
	            IsInCallStack('JURA146') .Or. IsInCallStack('JURA202') .Or. IsInCallStack('JURA063'))

	If !Empty(aPreFat)

		For nI := 1 To Len(aPreFat)
			lVinc := aPreFat[nI][1] == cPrefat

			If lVinc
				cMsgVinc := STR0074 //# "O lançamento"
			Else
				cMsgVinc := STR0075 //# "O caso"
			EndIf

			If IsInCallStack('JURA146')
				cMsgTp := STR0104 //# "Pelo menos um dos casos do WO"
			Else
				cMsgTp := STR0073 //# "O caso destino"
			EndIf

			If (nOper == 3 .Or. nOper == 4) .And. !lRetira
				If aPreFat[nI][3] //Verifica se o caso esta ou pode ser adicionado na pré.
					cMsgLog += I18N(STR0081, {Iif(lCalLot, cMsgTp, cMsgVinc), aPreFat[nI][1], JurSitGet(aPreFat[nI][2]) }) //# "#1 está vinculado na pré-fatura #2 com situação '#3"
				Else
					cMsgLog += I18N(STR0111, {Iif(lCalLot, cMsgTp, cMsgVinc), aPreFat[nI][1], JurSitGet(aPreFat[nI][2]) }) //# "#1 pode ser vinculado à pré-fatura #2 com situação '#3"
				EndIf

				cMsglog += Iif(aPreFat[nI][2] $ '2|D|E', I18N(STR0092, {JurSitGet('3')}), "'." ) +CRLF+CRLF //"', a pré-fatura terá o status atualizado para '#1'."

				If !lVinc .And. Empty(cPrefat) //Somente exibe a mensagem se o lançamento não estiver vinculado a nenhuma pré-fatura
					If lCalLot
						cMsgLog += STR0076 + CRLF //"Obs.: Os lançamentos não foram associados automaticamente à pré-fatura correspondente e estão disponíveis na opção 'Novos' em operações de pré-fatura."
					Else
						If (nI == Len(aPreFat))
							cMsgLog += STR0077 //"Obs.: O lançamento não foi associado automaticamente à pré-fatura correspondente e está disponível na opção 'Novos' em operações de pré-fatura."
						EndIf
					EndIf
				EndIf

			ElseIf nOper == 5 .Or. lRetira
				If lVinc
					cMsglog += I18N(Iif(lCalLot, STR0094, STR0093), {aPreFat[nI][1], JurSitGet(aPreFat[nI][2]) })  // "O lançamento estava vinculado à pré-fatura #1 com situação '#2" ##"Pelo menos um dos lançamentos selecionados estava vinculado à pré-fatura #1 com situação '#2"
					cMsglog += Iif(aPreFat[nI][2] == '2', I18N(STR0092, {JurSitGet('3')}), "'." ) +CRLF //"', a pré-fatura terá o status atualizado para '#1'."   ##  "O lançamento está vinculado à pré-fatura #2 com situação '#3"
				EndIf
			EndIf

			If lCalLot .And. !Empty(cMsgLog)
				If !Empty(cFileLog := NomeAutoLog())
					aDirLog := Directory("\" + CurDir() + cFileLog, "D")

					If !Empty(aDirLog) .And. aDirLog[1][2] < 1024000
						cMemoLog := MemoRead(cFileLog)
						If (AT(aPreFat[nI][1], cMemoLog) == 0)
							AutoGrLog(cMsgLog)
						EndIf
					Else
						AutoGrLog(cMsgLog)
					EndIf
				Else
					AutoGrLog(cMsgLog)
				EndIf
				cMsgLog := ""
				JurSetLog(.T.)
			EndIf

		Next nI

		If !lCalLot
			If !Empty(cMsgLog)
				If lText
					cRet := cMsgLog
				Else
					ApMsgInfo(cMsgLog)
				EndIf
			EndIf
		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurSetLog(lSet)
Rotina alterar o valor da variável lLogLote.
@author Luciano Pereira dos Santos
@since 15/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetLog(lSet)
	lLogLote := lSet
Return lLogLote

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurGetLog()
Rotina trazer o valor da variável lLogLote.
@author Luciano Pereira dos Santos
@since 15/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetLog()
Return lLogLote

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurLogLote()
Rotina para exibir o log da tela de operações em lote.
operações em lote.

@author Luciano Pereira dos Santos
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function  JurLogLote(lShow)
	Local cFileLog := NomeAutoLog()
	Local cRet     := ""
	Local aDir     := {}
	Default lShow  := .T.

	If JurGetLog() .And. !Empty(cFileLog)

		aDir := Directory("\" + CurDir() + cFileLog, "D")

		If !Empty(aDir) .And. aDir[1][2] < 1024000
			Iif(lShow, MostraErro(), cRet := MemoRead(cFileLog))
		Else
			cRet  := STR0078 //#"Ocorreram críticas no processo de alteração dos lançamentos que ultrapassaram o limite de exibição.
			cRet  += STR0080 + "\" + CurDir() + cFileLog +CRLF // ##Para maiores informações, verifique o arquivo "
			If lShow
				ApMsgAlert(cRet)
				MostraErro()
			Else
				cRet  += Replicate( "-", 65 ) + CRLF
				cRet  += MemoRead(cFileLog)
			EndIf
		EndIf

		JurSetLog(.F.)

	ElseIf !Empty(cFileLog)

		FClose(cFileLog)
		FErase(cFileLog)

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDesCli()
Função para carregar a descrição do cliente.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDesCli(cAlias)
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaNVE := NVE->(GetArea())

	If !Empty(cCliOr) .And. !Empty(cLojaOr)
		SA1->(DbSetOrder(1))
		If SA1->(Dbseek(xFilial('SA1') + cCliOr + cLojaOr))
			oDesCli:Enable()
			cDesCli := SA1->A1_NOME
			cCliGrp := SA1->A1_GRPVEN
			oDesCli:Refresh()

			If !Empty(cCasoOr)
				NVE->(DbSetOrder(1))
				If !NVE->(Dbseek(xFilial('NVE') + cCliOr + clojaOr + cCasoOr ))
					cCasoOr := CriaVar(cAlias + '_CCASO', .F.)
					oCasoOr:Refresh()
					JurDesCaso()
				EndIf
			EndIf
		Else
			cLojaOr := CriaVar(cAlias + '_CLOJA', .F.)
			oLojaOr:Refresh()
			cCasoOr := CriaVar(cAlias + '_CCASO', .F.)
			oCasoOr:Refresh()
			cDesCli := ""
			oDesCli:Refresh()
		EndIf

	Else
		cDesCli := ""
		oDesCli:Disable()
		oDesCli:Refresh()
		If Empty(cCliOr)
			cLojaOr  := CriaVar(cAlias + '_CLOJA', .F.)
			oLojaOr:Refresh()
			cCasoOr := CriaVar(cAlias + '_CCASO', .F.)
			oCasoOr:Refresh()
			JurDesCaso()
		EndIf

		If Empty(cLojaOr)
			cCasoOr := CriaVar(cAlias + '_CCASO', .F.)
			oCasoOr:Refresh()
			JurDesCaso()
		EndIf
	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaNVE)
	RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDesCaso()
Função para carregar a descrição do caso.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDesCaso()
	Local lRet := .T.
	
	If !Empty(cCliOr) .And. !Empty(cLojaOr) .And. !Empty(cCasoOr)
		oDesCas:Enable()
		oDesCas:Refresh()
		cDesCas := JurGetDados('NVE', 1, xFilial('NVE') + cCliOr + cLojaOr + cCasoOr, 'NVE_TITULO')
	Else
		cDesCas := ""
		oDesCas:Disable()
		oDesCas:Refresh()
	EndIf
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValCli()
Função habilitar/ Desabilitar o Cliente da alteração em lote

@Param cCampo Campo a ser validado

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0

@OBS Proteção - Excluída na FENALAW e mantida por compatibilidade
/*/
//-------------------------------------------------------------------
Function JurValCli(cAlias)
	Local lRet := .T.

	If lChkCli
		oCliOr:Enable()
		oDesCli:Enable()
		oLojaOr:Enable()
		oCasoOr:Enable()
		oDesCas:Enable()
		oCliOr:Refresh()
		oDesCli:Refresh()
		oLojaOr:Refresh()
		oCasoOr:Refresh()
		oDesCas:Refresh()
	Else
		cCliOr    := CriaVar(cAlias + '_CCLIEN')
		cDesCli   := ""
		cLojaOr   := CriaVar(cAlias + '_CLOJA')
		oCliOr:Disable()
		oDesCli:Disable()
		oLojaOr:Disable()
		cCasoOr   := CriaVar(cAlias + '_CCASO')
		cDesCas   := ""
		oCasoOr:Disable()
		oDesCas:Disable()
		oCliOr:Refresh()
		oDesCli:Refresh()
		oLojaOr:Refresh()
		oCasoOr:Refresh()
		oDesCas:Refresh()
	EndIf
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurChkCli()
Função habilitar/ Desabilitar o Cliente/Loja/Caso da alteração em lote

@Obs Passar parâmetros como referência
     Utilizar apenas objetos TJurPnlCampo

@Sample JurChkCli(@oClien, @cClien, @oLoja, @cLoja, @oDeClien, @cDeClien, @oCaso, @cCaso, @oDeCaso, @cDeCaso, lChkCli)

@author Bruno Ritter
@since 06/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurChkCli(oClien, cClien, oLoja, cLoja, oDeClien, cDeClien, oCaso, cCaso, oDeCaso, cDeCaso, lChkCli)
Local cCVarCli   := Criavar( 'A1_COD', .F. )
Local cCVarLoj   := Criavar( 'A1_LOJA', .F. )
Local cCVarDCl   := Criavar( 'A1_NOME', .F. )
Local cCVarCas   := Criavar( 'NVE_NUMCAS', .F. )
Local cCVarDCa   := Criavar( 'NVE_TITULO', .F. )

Default oClien   := Nil
Default oLoja    := Nil
Default oCaso    := Nil
Default cClien   := ""
Default cLoja    := ""
Default cCaso    := ""

	If lChkCli
		oClien:Enable()
		oLoja:Enable()
		oCaso:Enable()
	Else
		oClien:SetValue(cCVarCli)
		cClien       := cCVarCli
		oClien:Disable()

		oLoja:SetValue(cCVarLoj)
		cLoja       := cCVarLoj
		oLoja:Disable()

		oDeClien:SetValue(cCVarDCl)
		cDeClien       := cCVarDCl

		oCaso:SetValue(cCVarCas)
		cCaso       := cCVarCas
		oCaso:Disable()

		oDeCaso:SetValue(cCVarDCa)
		cDeCaso       := cCVarDCa
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JurVlTra
Rotina de validação e preenchimento dos campos Grupo,Cliente,Loja e Caso na tela de transferência

@Param    cTipo   Tipo da Ação: 1 = Grupo / 2 = Cliente/Loja / 3 = Caso

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVlTra(cAlias)
	Local lRet     := .T.
	Local cCaso    := GETMV('MV_JCASO1')
	Local aAreaNVE := NVE->(GetArea())
	Local aArea    := GetArea()

	If !Empty(cCasoOr)
		If cCaso == '1' .And. !Empty(cCliOr) .And. !Empty(clojaOr)
			NVE->(DbSetOrder(1))
			If !NVE->(Dbseek(xFilial('NVE') + cCliOr + clojaOr + cCasoOr ))
				cCasoOr := CriaVar(cAlias + '_CCASO', .F.)
				oCasoOr:Refresh()
				cDesCas := ""
				oDesCas:Refresh()
				ApMsgStop(STR0128) //"Caso inválido."
			EndIf
		ElseIf cCaso != '2'
			JurMsgErro(STR0079) //"Informe cliente, loja e caso!"
		EndIf

		If cCaso == '2'
			NVE->(DbSetOrder(3))
			If NVE->(Dbseek(xFilial('NVE') + cCasoOr ))
				cCliOr  := NVE->NVE_CCLIEN
				cLojaOr := NVE->NVE_LCLIEN
			Else
				cCasoOr  := CriaVar(cAlias + '_CCASO', .F.)
				oCasoOr:Refresh()
				cCliOr   := CriaVar(cAlias + '_CCLIEN', .F.)
				oCliOr:Refresh()
				cLojaOr  := CriaVar(cAlias + '_CLOJA', .F.)
				oLojaOr:Refresh()
				cDesCas := ""
				oDesCas:Refresh()
				ApMsgStop(STR0128) //"Caso inválido."
			EndIf
		EndIf
	EndIf

	JurDesCaso()
	JurDesCli(cAlias)

	RestArea(aAreaNVE)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDesAdv()
Função para carregar a descrição do Participante.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDesAdv(cSigla, cDesAdv,oDesAdv)
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaRD0 := RD0->(GetArea())

	If !Empty(cSigla)
		RD0->(dbSetOrder(9))
		If RD0->(dbSeek(xFilial("RD0") + cSigla))
			cDesAdv := Posicione('RD0', 9, xFilial('RD0') + Alltrim(cSigla), 'RD0_NOME')
			oDesAdv:SetValue(cDesAdv)
		Else
			cDesAdv := ""
			oDesAdv:SetValue(cDesAdv)
			ApMsgStop(STR0129) //"Sigla do advogado inválida."
			lRet := .F.
		EndIf
	Else
		cDesAdv := ""
		oDesAdv:SetValue(cDesAdv)
	EndIf

	RestArea(aAreaRD0)
	RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValAdv()
Função habilitar/ Desabilitar o participante da alteração em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurValAdv(cSigla, oAdv, cDesAdv, oDesAdv)
	Local lRet := .T.

	If lChkAdv
		oAdv:Enable()
		oAdv:Refresh()
		oDesAdv:Enable()
		oDesAdv:Refresh()
	Else
		cSigla := CriaVar('RD0_SIGLA', .F.)
		oAdv:SetValue(cSigla)
		cDesAdv   := ""
		oDesAdv:SetValue(cDesAdv)
		oAdv:Disable()
		oDesAdv:Disable()
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldPart
Função para validar os campos de Participante dos lançamentos.
Usado nos campos NUE_SIGLA1, NUE_SIGLA2, NVY_SIGLA, NV4_SIGLA e nos
campos de data dos lançamentos.

@Param    cCampo   Campo a ser validado

@author Cristina Cintra
@since 06/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldPart(cCampo)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local dDtDemis  := CToD('  /  /  ')// Data de demissão do Participante
	Local dDtLanc   := CToD('  /  /  ')//Data do lançamento
	Local lIsRest   := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

	Default cCampo  := ""

	//Colocado o 6º parametro no Existcpo como .F. para que na alteração da data dos lançamentos não sejam verificados os participantes inativos
	If !(IsInCallStack("JURA175IMP")) .And. !Empty(cCampo)
		If cCampo == "NUE_SIGLA1"
			lRet := (ExistCpo("RD0", FWFLDGET("NUE_SIGLA1"), 9) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA1"), 'RD0_TPJUR') == "1")
			If lRet
				dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA1"), 'RD0_DTADEM')
				If !Empty(dDtDemis)
					dDtLanc := FWFLDGET("NUE_DATATS")
					If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
						lRet := .T.
					Else
						lRet := JurMsgErro(STR0088) //A data do lançamento é posterior a data de demissão do participante lançado.
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NUE_CPART1" .And. lIsRest
			lRet := (ExistCpo("RD0", FWFLDGET("NUE_CPART1"), 1) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART1"), 'RD0_TPJUR') == "1")
			If lRet
				dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART1"), 'RD0_DTADEM')
				If !Empty(dDtDemis)
					dDtLanc := FWFLDGET("NUE_DATATS")
					If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
						lRet := .T.
					Else
						ApMsgInfo(STR0088) //A data do lançamento é posterior a data de demissão do participante lançado.
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NUE_SIGLA2"
			lRet := (ExistCpo("RD0", FWFLDGET("NUE_SIGLA2"), 9) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA2"), 'RD0_TPJUR') == "1")
			If lRet
				dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA2"), 'RD0_DTADEM')
				If !Empty(dDtDemis)
					dDtLanc := FWFLDGET("NUE_DATATS")
					If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
						lRet := .T.
					Else
						lRet := JurMsgErro(STR0089) //A data do lançamento é posterior a data de demissão do participante revisado.
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NUE_CPART2" .And. lIsRest
			lRet := (ExistCpo("RD0", FWFLDGET("NUE_CPART2"), 1) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART2"), 'RD0_TPJUR') == "1")
			If lRet
				dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART2"), 'RD0_DTADEM')
				If !Empty(dDtDemis)
					dDtLanc := FWFLDGET("NUE_DATATS")
					If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
						lRet := .T.
					Else
						lRet := JurMsgErro(STR0089) //A data do lançamento é posterior a data de demissão do participante revisado.
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NUE_DATATS"
			If !Empty(FWFLDGET("NUE_SIGLA1"))
				lRet := (ExistCpo("RD0", FWFLDGET("NUE_SIGLA1"), 9,,, .F.) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA1"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA1"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NUE_DATATS")
						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0088) //A data do lançamento é posterior a data de demissão do participante lançado.
						EndIf
					EndIf
				EndIf
			ElseIf !Empty(FWFLDGET("NUE_CPART1")) .And. lIsRest
				lRet := (ExistCpo("RD0", FWFLDGET("NUE_CPART1"), 1,,, .F.) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART1"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART1"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NUE_DATATS")
						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0088) //A data do lançamento é posterior a data de demissão do participante lançado.
						EndIf
					EndIf
				EndIf
			EndIf
			If lRet .And. !Empty(FWFLDGET("NUE_SIGLA2"))
				lRet := (ExistCpo("RD0", FWFLDGET("NUE_SIGLA2"), 9,,, .F.) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA2"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NUE_SIGLA2"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NUE_DATATS")
						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0089) //A data do lançamento é posterior a data de demissão do participante revisado.
						EndIf
					EndIf
				EndIf
			ElseIf lRet .And. !Empty(FWFLDGET("NUE_CPART2")) .And. lIsRest
				lRet := (ExistCpo("RD0", FWFLDGET("NUE_CPART2"), 1,,, .F.) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART2"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NUE_CPART2"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NUE_DATATS")
						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0089) //A data do lançamento é posterior a data de demissão do participante revisado.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NVY_SIGLA"
			If !Empty(FWFLDGET("NVY_SIGLA"))
				lRet := (ExistCpo("RD0", FWFLDGET("NVY_SIGLA"), 9) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NVY_SIGLA"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NVY_SIGLA"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NVY_DATA")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NVY_CPART" .And. lIsRest
			If !Empty(FWFLDGET("NVY_CPART"))
				lRet := (ExistCpo("RD0", FWFLDGET("NVY_CPART"), 1) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NVY_CPART"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NVY_CPART"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NVY_DATA")
						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NVY_DATA"
			If !Empty(FWFLDGET("NVY_SIGLA"))
				lRet := (ExistCpo("RD0", FWFLDGET("NVY_SIGLA"), 9,,, .F.) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NVY_SIGLA"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NVY_SIGLA"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NVY_DATA")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			ElseIf !Empty(FWFLDGET("NVY_CPART")) .And. lIsRest
				lRet := (ExistCpo("RD0", FWFLDGET("NVY_CPART"), 1,,, .F.) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NVY_CPART"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NVY_CPART"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NVY_DATA")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NV4_SIGLA"
			If !Empty(FWFLDGET("NV4_SIGLA"))
				lRet := (ExistCpo("RD0", FWFLDGET("NV4_SIGLA"), 9) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NV4_SIGLA"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NV4_SIGLA"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NV4_DTCONC")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NV4_CPART" .And. lIsRest
			If !Empty(FWFLDGET("NV4_CPART"))
				lRet := (ExistCpo("RD0", FWFLDGET("NV4_CPART"), 1) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NV4_CPART"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NV4_CPART"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NV4_DTCONC")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NV4_DTCONC"
			If !Empty(FWFLDGET("NV4_SIGLA"))
				lRet := (ExistCpo("RD0", FWFLDGET("NV4_SIGLA"), 9,,, .F.) .And. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NV4_SIGLA"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NV4_SIGLA"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NV4_DTCONC")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			ElseIf !Empty(FWFLDGET("NV4_CPART")) .And. lIsRest
				lRet := (ExistCpo("RD0", FWFLDGET("NV4_CPART"), 1,,, .F.) .And. JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NV4_CPART"), 'RD0_TPJUR') == "1")
				If lRet
					dDtDemis := JurGetDados('RD0', 1, xFilial('RD0') + FWFLDGET("NV4_CPART"), 'RD0_DTADEM')
					If !Empty(dDtDemis)
						dDtLanc := FWFLDGET("NV4_DTCONC")

						If Empty(dDtLanc) .Or. dDtDemis >= dDtLanc
							lRet := .T.
						Else
							lRet := JurMsgErro(STR0090) //A data do lançamento é posterior a data de demissão do participante.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "NTT_SIGLA"
			lRet := Vazio() .Or. !Empty(JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NTT_SIGLA"), 'RD0_CODIGO'))
		EndIf
	ElseIf cCampo == "NSD_CPART"
		lRet := Vazio() .Or. Iif(JurIsRest(), (ExistCpo('RD0', FWFLDGET('NSD_SIGLA'), 1) .And. JURRD0('NSDDETAIL', 'NSD_SIGLA', '1') .And. JA042CHAV('NSD')), JA042CHAV('NSD'))
	ElseIf cCampo == "NTT_CPART"
		lRet := Vazio() .Or. Iif(JurIsRest(), (ExistCpo('RD0', FWFLDGET('NTT_CPART'), 1) .And. JURRD0('NTTDETAIL', 'NTT_CPART', '1') .And. JA042VLDCP('NTT_CPART')), JA042VLDCP('NTT_CPART'))
	ElseIf cCampo == "NU9_CPART"
		lRet := Vazio() .Or. Iif(JurIsRest(), (ExistCpo('RD0', FWFLDGET('NU9_CPART'), 1) .And. JURRD0('NU9DETAIL', 'NU9_CPART', JA148TPORI()) .And. JA148CHAV('NU9')), JA148CHAV('NU9'))
	ElseIf cCampo == "NUD_CPART"
		lRet := Vazio() .Or. Iif(JurIsRest(), (ExistCpo('RD0', FWFLDGET('NUD_CPART'), 1) .And. JURRD0('NUDDETAIL', 'NUD_CPART', '1') .And. JA148CHAV('NUD')), JA148CHAV('NUD'))
	EndIf

	RestArea( aArea )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTSCob
Função para verificar se o TS é cobrável ou não, considerando a flag Cobrar,
o tipo de atividade e o contrato relacionados ao TS.

@param cCodTS  , Código do TS a ser verificado se é cobrável ou não
@param cCliente, Cliente do TS
@param cLoja   , Loja do cliente do TS
@param cCaso   , Caso do TS
@param cAtiv   , Código do Tipo de Atividade do TS
@param lFxNC   , Indica se está sendo analisada uma atividade de um TS de 
                 pré-fatura de TSs de contratos fixos ou não cobráveis

@return   lCob     Indica se o TS é cobrável ou não

@author Cristina Cintra
@since  08/11/2013
/*/
//-------------------------------------------------------------------
Function JurTSCob(cCodTS, cCliente, cLoja, cCaso, cAtiv, lFxNC)
Local aArea    := GetArea()
Local lCob     := .T.

Default lFxNC  := .F.

	If JurGetDados("NUE", 1, xFilial("NUE") + cCodTS, "NUE_COBRAR") == "2" ;     // Verifica se o TS é cobrável
	   .Or. JurGetDados("NRC", 1, xFilial("NRC") + cAtiv, "NRC_TEMPOZ") == "2" ; // Verifica se o tipo de atividade do TS é cobrável
	   .Or. J144AtvNC(cCliente, cLoja, cCaso, cAtiv, lFxNC) == "2"               // Verifica se o tipo de atividade do TS está como cobrável no contrato
		lCob := .F.
	EndIf

	RestArea( aArea )

Return lCob

//-------------------------------------------------------------------
/*/{Protheus.doc} JURConsCli
Consulta padrão de cliente filtrando pelo grupo e perfil Cliente/Pagador
Uso Geral.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 02/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURConsCli()
	Local aArea     := GetArea()
	Local lRet      := .F.
	Local cGrupo    := ''
	Local cPerfil   := '1'
	Local aSearch   := {{'A1_COD', 1}, {'A1_NOME', 2}}
	Local aCampos   := {}
	Local aFiltro   := {}
	Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	aCampos := Iif(cLojaAuto == "1", {'A1_COD', 'A1_NOME'}, {'A1_COD', 'A1_LOJA', 'A1_NOME'} )

	If !Empty(cGetGrup)
		cGrupo := cGetGrup
	EndIf

	/* Filtro
	[1] Condição para adicionar o filtro ou não
	[2] Tipo = A(Comando ADVPL) / S(Comando SQL)
	[3] Titulo do filtro
	[4] Comando
	[5] Tabela para filtro relacional (apenas para comando SQL)
	*/
	aAdd( aFiltro, {!Empty(cGrupo)  , 'A', STR0036, "A1_GRPVEN == '" + cGrupo + "'"} )
	aAdd( aFiltro, {!Empty(cPerfil) , 'S', STR0037, "NUH_PERFIL = '" + cPerfil + "'", 'NUH'} )
	aAdd( aFiltro, {cLojaAuto == "1", 'A', "MV_JLOJAUT", "A1_LOJA == '" + JurGetLjAt() + "'"} )

	RestArea( aArea )

	If JurF3Tab( aSearch, 'SA1', aFiltro, aCampos, 'JURA148')
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MySeek
Adiciona internamente a filial da tabela para realizar a pesquisa.
Uso Geral.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 02/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function MySeek(oSeek,oBrowse)
	Local xValue    := ""
	Local cIndex    := Indexkey()
	Local nPosFil   := At("_FILIAL", cIndex)
	Local cAlias    := ""
	Local cSaveSeek := oSeek:cSeek
	Local nStyle    := oSeek:GetSeekStyle() // 1 = Pesquisa por chave; 2 = Pesquisa por colunas

	If nStyle == 1 .And. nPosFil > 0
		cAlias := SubStr(cIndex, 1, nPosFil - 1)
		oSeek:cSeek := xFilial(cAlias) + oSeek:cSeek
	Endif
	
	xValue := oBrowse:oData:Seek(oSeek, oBrowse)
	oSeek:cSeek := cSaveSeek
	
Return xValue

//-------------------------------------------------------------------
/*/{Protheus.doc} JWhenCaso
Função usada para carregar a propriedade WHEN de campos de caso.
Uso Geral.

@Param oGetClie		Objeto contendo o método "valor" com Código do cliente
@Param oGetLoja		Objeto contendo o método "valor" com Código da loja
@Param oGetCaso		Objeto contendo o método "valor" com Código do Caso
@Return lRet	 	.T./.F. O campo ficará disponível ou não

@author André Spirigoni Pinto
@since 11/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWhenCaso (oGetClie, oGetLoja, oGetCaso)
	Local lRet := .T.

	If SuperGetMV('MV_JCASO1',,'1') == '1' .And. (Empty(oGetClie:Valor) .Or. Empty(oGetLoja:Valor))
		lRet := .F.
		oGetCaso:Refresh()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldPerFx
Função utilizada para validar se existem faixas iniciadas em 0 e
terminadas em 999999.

@author Cristina Cintra
@since 13/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldPerFx(oGrid, cCpoIni, cCpoFim, lQtdCas)
	Local nOperation := oGrid:GetModel():GetOperation()
	Local lRet       := .T.
	Local lIni       := .F.
	Local lFim       := .F.
	Local nI

	Default lQtdCas  := .F.

	If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR

		For nI := 1 To oGrid:GetQtdLine()
			If (!oGrid:IsEmpty(nI) .And. !oGrid:IsDeleted(nI))
				If oGrid:GetValue(cCpoIni, nI) == 0 .And. !lIni
					lIni := .T.
				Endif
				If lQtdCas //Se for Quantidade de Casos, não deve comparar casas decimais, vide alteração de picture em J96PICTPFX()
					If AllTrim(Str(oGrid:GetValue(cCpoFim, nI))) == Replicate("9", (TamSX3(cCpoFim)[1] - 3)) .And. !lFim
						lFim := .T.
					EndIf
				Else
					If AllTrim(Str(oGrid:GetValue(cCpoFim, nI))) == Replicate("9", (TamSX3(cCpoFim)[1] - 3)) + "." + Replicate("9", (TamSX3(cCpoFim)[2])) .And. !lFim
						lFim := .T.
					EndIf
				EndIf
			Endif
		Next

		If !lIni .Or. !lFim
			lRet := JurMsgErro(STR0102) //"Ao menos uma das faixas de faturamento deve ter Valor Inicial = 0 e outra com Valor Final = ao valor máximo do campo (Ex.: 9.999.999.999.999,99)".
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldLacFx
Função utilizada para validar se existem lacunas entre as faixas de
faturamento.

@author Cristina Cintra
@since 14/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldLacFx(oGrid, cCpoIni, cCpoFim, lQtdCas)
	Local nOperation := oGrid:GetModel():GetOperation()
	Local nPosIni    := 1
	Local nPosFim    := 2
	Local nFimAnt    := 0
	Local nI         := 0
	Local nDif       := 0
	Local aColsOrd   := {}
	Local lRet       := .T.

	Default lQtdCas  := .F.

	If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR

		Iif(lQtdCas, nDif := 1, nDif := 0.01 ) //Trata a diferença entre as faixas para Quantidade de Casos, pois é número inteiro.

		For nI := 1 To oGrid:GetQtdLine()
			If !oGrid:IsDeleted(nI) .And. !oGrid:IsEmpty(nI)
				aAdd(aColsOrd, {oGrid:GetValue(cCpoIni, nI), oGrid:GetValue(cCpoFim, nI)})
			EndIf
		Next

		aSort( aColsOrd,,, { |aX, aY| aX[nPosIni] < aY[nPosIni] } )

		For nI := 1 To Len(aColsOrd)
			If nI > 1 .And. nFimAnt > 0 .And. !( aColsOrd[nI][nPosIni] - nFimAnt == nDif )
				lRet := JurMsgErro(STR0103) //"Não são permitidas lacunas entre os valores das faixas de faturamento."
				Exit
			EndIf
			nFimAnt := aColsOrd[nI][nPosFim]
		Next

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JFxHrVr
Rotina para apuração do valor por faixa nas situações onde há necessidade
de varrer os TSs, tais como Tab Estática >> Hora >> Tabela de Honorários,
Tab Progressiva >> Hora >> % Cobrar e Tabela de Honorários.
Alimenta o array aNTRExc com os valores das faixas onde há esta necessidade
e a função JClcFxHrVr utiliza estes valores somando com as demais faixas do
contrato para chegar no valor total do contrato.

@Param    cCodPre  Código da Pré-fatura
@Param    cTpFx    Tipo da Faixa, onde "1"=Estática e "2"=Progressiva
@Param    cCalFx   Tipo de Cálculo de Faixa, onde "1"=Valor e "2"=Hora
@Param    cContr   Código do Contrato para cálculo de valor
@Param    nVTS     Soma do Valor de TS do contrato para cálculo considerando as faixas por Hora
@Param    nTempo   Soma das Horas de TS do contrato para cálculo considerando as faixas por Valor
@Param    cTpExec  Tipo de execução proveniente da JURA201E, pois caso seja emissão os dados da NX0 ainda não estão gravados

@Return   nValor   Valor total de honorários do contrato, baseado nas faixas

@author Cristina Cintra
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFxHrVr(cCodPre, cTpFx, cCalFx, cContr, nVTS, nTempo, cTpExec)
Local aArea    := GetArea()

Local nI       := 0
Local nJ       := 0
Local nValor   := 0
Local nFaixa   := 0
Local nHrTSs   := 0
Local nQtd     := 0
Local nDif     := 0

Local cSQLNUE  := ''
Local cMoePre  := Iif(cTpExec == "1" /*Emissão de Pré*/, JurGetDados('NT0', 1, xFilial('NT0') + cContr, 'NT0_CMOE'), JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_CMOEDA') )

Local aNTR     := {}
Local aNTRExc  := {}
Local aRet     := {}
Local aNUE     := ''

Default cCodPre:= ""
Default cTpFx  := ""
Default cCalFx := ""
Default cContr := ""
Default nVTS   := 0
Default nTempo := 0

If !Empty(cCodPre) .And. !Empty(cTpFx) .And. !Empty(cCalFx) .And. !Empty(cContr) .And. ( nVTS > 0 .Or. nTempo > 0 )

	aNTR := JSeekFxFt(cContr) //Retorna as faixas de faturamento do contrato

	For nI := 1 To Len(aNTR)
		// Tipo Faixa = "Progressiva" e Calc Faixa = "Hora" e Tipo Valor = % Cobrar ou Tab Hon ou
		// Tipo Faixa = "Estática" e Calc Faixa = "Hora" e Tipo Valor Tab Hon
		If ( cTpFx == "2" .And. cCalFx == "2" .And. (aNTR[nI][3] == '3' .Or. aNTR[nI][3] == '4') ) .Or.;
				( cTpFx == "1" .And. cCalFx == "2" .And. aNTR[nI][3] == '4' )
			aAdd(aNTRExc, aNTR[nI])
		EndIf
	Next nI

	If !Empty(aNTRExc)

		cSQLNUE := " SELECT NUE_COD, NUE_CPART2, NUE_CCLIEN, NUE_CLOJA, NUE_CCASO, NUE_ANOMES, NUE_TEMPOR, NUE_VALOR1, NUE_CATIVI "
		cSQLNUE +=   " FROM " + RetSqlName("NUE") + " NUE, " + RetSqlName("NX1") + " NX1 "
		cSQLNUE +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
		cSQLNUE +=    " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
		cSQLNUE +=    " AND NUE.NUE_CPREFT = '" + cCodPre + "' "
		cSQLNUE +=    " AND NX1.NX1_CCONTR = '" + cContr  + "' "
		cSQLNUE +=    " AND NX1.NX1_CPREFT = '" + cCodPre + "' "
		cSQLNUE +=    " AND NX1.NX1_CCLIEN = NUE.NUE_CCLIEN "
		cSQLNUE +=    " AND NX1.NX1_CLOJA  = NUE.NUE_CLOJA "
		cSQLNUE +=    " AND NX1.NX1_CCASO  = NUE.NUE_CCASO "
		cSQLNUE +=    " AND NUE.D_E_L_E_T_ = ' ' "
		cSQLNUE +=    " AND NX1.D_E_L_E_T_ = ' ' "
		cSQLNUE +=  " ORDER BY NUE.NUE_DATATS, NUE.NUE_CPART2 "

		aNUE := JurSQL(cSQLNUE, {"NUE_COD", "NUE_CPART2", "NUE_CCLIEN", "NUE_CLOJA", "NUE_CCASO", "NUE_ANOMES", "NUE_TEMPOR", "NUE_VALOR1", "NUE_CATIVI" })

		If !Empty(aNUE)

			For nJ := 1 To Len(aNTRExc)

				nDif := Iif(aNTRExc[nJ][2] == aNTR[1][2], 0.00, 0.01) //Para considerar a diferença a partir da segunda faixa

				For nI := 1 To Len(aNUE)

					//Cálculo da situação com tabela Estática e por Hora >> Tab Honorários
					//Varre todos os TSs verificando o valor na tabela de honorários da faixa e acumulando os valores. Efetua a conversão caso a moeda
					//da tabela seja diferente da moeda da pré-fatura
					If cTpFx == "1" .And. !Empty(aNTRExc[nJ][5])
						aRet := JURA200(aNUE[nI][1], aNUE[nI][2], aNUE[nI][3], aNUE[nI][4], aNUE[nI][5], aNUE[nI][6], aNTRExc[nJ][5], aNUE[nI][9] )
						Iif( aRet[1] == cMoePre, nFaixa += aRet[2] * aNUE[nI][7], nFaixa += ( JA201FConv(cMoePre, aRet[1], aRet[2], "1", JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_DTEMI') )[1] ) * aNUE[nI][7] )

						//Cálculo da situação com tabela Progressiva e por Hora >> % a Cobrar
					ElseIf cTpFx == "2" .And. aNTRExc[nJ][3] == "3"
						If ( nHrTSs + aNUE[nI][7] ) >= aNTRExc[nJ][1] //Considera apenas os TSs que entram na faixa
							//Caso o TS exceda o valor da faixa, pega apenas a qtdade de horas para completar a faixa e se nHrTSs for menor do que o início da faixa, pega apenas o novo a partir do início
							Iif ( nHrTSs + aNUE[nI][7] > aNTRExc[nJ][2], nQtd := Iif(nHrTSs > aNTRExc[nJ][1], aNTRExc[nJ][2] - nHrTSs, aNTRExc[nJ][2] - aNTRExc[nJ][1] + nDif), nQtd := Iif( nHrTSs < aNTRExc[nJ][1], (( aNUE[nI][7] + nHrTSs ) - aNTRExc[nJ][1] + nDif), aNUE[nI][7] ) )
							nFaixa += ( (nQtd * (aNUE[nI][8] / aNUE[nI][7])) * aNTRExc[nJ][4] ) / 100
						EndIf
						nHrTSs += aNUE[nI][7]
						If nHrTSs >= aNTRExc[nJ][2]
							Exit
						EndIf

						//Cálculo da situação com tabela Progressiva e por Hora >> Tab Honorários
					ElseIf cTpFx == "2" .And. aNTRExc[nJ][3] == "4"
						If ( nHrTSs + aNUE[nI][7] ) >= aNTRExc[nJ][1] //Considera apenas os TSs que entram na faixa
							//Caso o TS exceda o valor da faixa, pega apenas a qtdade de horas para completar a faixa e se nHrTSs for menor do que o início da faixa, pega apenas o novo a partir do início
							Iif ( nHrTSs + aNUE[nI][7] > aNTRExc[nJ][2], nQtd := Iif(nHrTSs > aNTRExc[nJ][1], aNTRExc[nJ][2] - nHrTSs, aNTRExc[nJ][2] - aNTRExc[nJ][1] + nDif), nQtd := Iif( nHrTSs < aNTRExc[nJ][1], (( aNUE[nI][7] + nHrTSs ) - aNTRExc[nJ][1] + nDif), aNUE[nI][7] ) )
							aRet := JURA200(aNUE[nI][1], aNUE[nI][2], aNUE[nI][3], aNUE[nI][4], aNUE[nI][5], aNUE[nI][6], aNTRExc[nJ][5], aNUE[nI][9] )
							Iif( aRet[1] == cMoePre, nFaixa += aRet[2] * nQtd, nFaixa += ( JA201FConv(cMoePre, aRet[1], aRet[2], "1", JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_DTEMI') )[1] ) * nQtd )
						EndIf
						nHrTSs += aNUE[nI][7]
						If nHrTSs >= aNTRExc[nJ][2]
							Exit
						EndIf
					EndIf

				Next nI

				aAdd(aNTRExc[nJ], nFaixa)
				nFaixa := 0
				nHrTSs := 0
				aRet   := {}

			Next nJ

		Else
			For nI := 1 To Len (aNTRExc)
				aAdd(aNTRExc[nI], 0)
			Next nI
		EndIf

	EndIf

	nValor := JClcFxHrVr(cTpFx, cCalFx, nVTS, nTempo, aNTR, aNTRExc) //Rotina que faz a somatória das faixas de faturamento simples com as
	                                                                 //calculadas aqui (exceções), retornando a somatória total do contrato.

	RestArea(aArea)

EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JClcFxHrVr
Rotina para cálculo do valor do contrato da pré-fatura considerando
as faixas de faturamento do tipo Hora e Valor.

@Param    cTpFx    Tipo da Faixa, onde "1"=Estática e "2"=Progressiva
@Param    cCalFx   Tipo de Cálculo de Faixa, onde "1"=Valor e "2"=Hora
@Param    nVTS     Soma do Valor de TS do contrato para cálculo considerando as faixas por Hora
@Param    nTempo   Soma das Horas de TS do contrato para cálculo considerando as faixas por Valor
@Param    aNTR     Array com as faixas de faturamento do Contrato
@Param    aNTRExc  Array com as faixas consideradas exceção de cálculo

@Return   nValor   Valor total de honorários do contrato, baseado nas faixas

@author Cristina Cintra
@since 19/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JClcFxHrVr(cTpFx, cCalFx, nVTS, nTempo, aNTR, aNTRExc)
	Local aArea    := GetArea()
	Local nValor   := 0
	Local nI       := 0

	Default cCalFx := ""
	Default nVTS   := 0
	Default nTempo := 0

	If !Empty(aNTR) // {"NTR_VLINI, NTR_VLFIM, NTR_TPVL, NTR_VALOR, NTR_CTABH"}

		For nI := 1 To Len(aNTR)

			Do Case
			Case cTpFx == "1" // Estática

				If cCalFx == "1" //1-Valor
					If aNTR[nI][1] <= nVTS .And. aNTR[nI][2] >= nVTS
						If aNTR[nI][3] == "1"  //1-Valor Fixo
							nValor += aNTR[nI][4]
						Else                    //3-% a Cobrar
							nValor += (nVTS * aNTR[nI][4]) / 100
						EndIf
						Exit
					EndIf

				Else             //2-Hora

					If aNTR[nI][1] <= nTempo .And. aNTR[nI][2] >= nTempo
						If aNTR[nI][3] == "1"        //1-Valor Fixo
							nValor += aNTR[nI][4]
						ElseIf aNTR[nI][3] == "3"    //3-% a Cobrar
							nValor += (nVTS * aNTR[nI][4]) / 100
						Else                           //4-Tab Honorários
							nValor += aNTRExc[aScan(aNTRExc,{|x| x[1] == aNTR[nI][1] .And. x[2] == aNTR[nI][2] .And. x[3] == aNTR[nI][3] .And. x[4] == aNTR[nI][4] })][6]
						EndIf
						Exit
					EndIf

				EndIf

			Case cTpFx == "2" // Progressiva

				If cCalFx == "1" //1-Valor
					If aNTR[nI][3] == "1"         //1-Valor Fixo
						If nVTS >= aNTR[nI][1]
							nValor += aNTR[nI][4]
						EndIf
					Else                            //3-% a Cobrar
						If nVTS >= aNTR[nI][1]
							If nVTS <= aNTR[nI][2]
								nValor += ( ( nVTS - aNTR[nI][1] ) * aNTR[nI][4] ) / 100
							Else
								nValor += ( ( aNTR[nI][2] - aNTR[nI][1] ) * aNTR[nI][4] ) / 100
							EndIf
						EndIf
					EndIf

				Else             //2-Hora
					If aNTR[nI][3] == "1"        //1-Valor Fixo
						If nTempo >= aNTR[nI][1]
							nValor += aNTR[nI][4]
						EndIf
					ElseIf aNTR[nI][3] == "3"    //3-% a Cobrar
						nValor += aNTRExc[aScan(aNTRExc,{|x| x[1] == aNTR[nI][1] .And. x[2] == aNTR[nI][2] .And. x[3] == aNTR[nI][3] .And. x[4] == aNTR[nI][4] })][6]
					Else                           //4-Tab Honorários
						nValor += aNTRExc[aScan(aNTRExc,{|x| x[1] == aNTR[nI][1] .And. x[2] == aNTR[nI][2] .And. x[3] == aNTR[nI][3] .And. x[4] == aNTR[nI][4] })][6]
					EndIf

				EndIf

			End Case

		Next nI

	EndIf

	RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JSeekFxFt
Busca e retorna as faixas de faturamento do contrato passado como parâmetro.

@param    cContr   Contrato para busca das Faixas de Faturamento

@return   aFaixas  Array com as faixas de faturamento do contrato: "NTR_VLINI", "NTR_VLFIM", "NTR_TPVL", "NTR_VALOR", "NTR_CTABH"

@author Cristina Cintra
@since 26/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSeekFxFt(cContr)
	Local aFaixas  := {}
	Local cSQLNTR  := ''

	Default cContr := ""

	If !Empty(cContr)
		cSQLNTR := "SELECT NTR_VLINI, NTR_VLFIM, NTR_TPVL, NTR_VALOR, NTR_CTABH "
		cSQLNTR +=  " FROM " + RetSqlName("NTR") + " NTR "
		cSQLNTR += " WHERE NTR.NTR_FILIAL = '" + xFilial( "NTR" ) + "' "
		cSQLNTR +=   " AND NTR.NTR_CCONTR = '" + cContr + "' "
		cSQLNTR +=   " AND NTR.D_E_L_E_T_ = ' ' "

		aFaixas := JurSQL(cSQLNTR, {"NTR_VLINI", "NTR_VLFIM", "NTR_TPVL", "NTR_VALOR", "NTR_CTABH"})
	EndIf

Return aFaixas

//-------------------------------------------------------------------
/*/{Protheus.doc}JRecQtdCas
Busca e retorna as faixas de faturamento do contrato, calculando com base nos casos
da pré-fatura ou fatura passada como parâmetro - Tipo de faixa Quantidade de Casos.
Semelhante a J96CalcCDF(), mas esta considera os casos do contrato para atualização
do valor da parcela (NT1) posicionada.

@Param    cFatura     Código da fatura (quando se tratar de recálculo no momento da emissão de fatura)
@Param    cCodPre     Código da pré-fatura a qual o contrato está vinculado
@Param    cNT0TPFX    Tipo de Faixa onde 1=Tabela Estática e 2=Tabela Progressiva
@Param    cContr      Contrato para busca das Faixas de Faturamento
@Param    cDtIni      Data inicial da parcela da pré-fatura
@Param    cDtFin      Data final da parcela da pré-fatura
@Param    cCasPros    Indica se a contagem será por 1=Casos ou 2=Processos.
                      Para a 2º opção, as informações virão do SIGAJURI ou LD Jurídico
@Param    nQtdManual  Quantidade a ser usada quando o preenchimento for manual, ou seja, não tem os casos 
                      no sistema e não integra o jurídico MV_JQTDAUT = 2

@Return   aRet      Array contendo: Valor base atualizado do Fixo com base nas faixas e a quantidade de casos/processos

@author Cristina Cintra
@since 26/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JRecQtdCas(cFatura, cCodPre, cNT0TPFX, cContr, cDtIni, cDtFin, cCasPros, nQtdManual)
Local aArea        := GetArea()
Local cAlQry       := GetNextAlias()
Local cSQL         := ""
Local aFaixas      := {}
Local aRet         := {}
Local nQtdCasos    := 0
Local nValor       := 0
Local nI           := 0
Local nDif         := 0
Local lRet         := .T.

Default cCodPre    := ""
Default cNT0TPFX   := ""
Default cCONTR     := ""
Default cDtIni     := ""
Default cDtFin     := ""
Default cCasPros   := "1" //1=Casos ou 2=Processos
Default nQtdManual := 0

If !Empty(cNT0TPFX) .And. !Empty(cContr)

	lFxAber := JurGetDados("NT0", 1, xFilial("NT0") + cContr, "NT0_FXABM") == '1'   //Considera casos abertos no mês de referência
	lFxEnce := JurGetDados("NT0", 1, xFilial("NT0") + cContr, "NT0_FXENCM") == '1'  //Considera casos encerrados no mês de referência

	If nQtdManual > 0
		nQtdCasos := nQtdManual
	ElseIf cCasPros == "1" //Casos
		If !Empty(cCodPre)
			cSQL := "SELECT NVE.NVE_DTENTR DTENTR, NVE.NVE_DTENCE DTENCE, NVE.NVE_SITUAC SITUAC "
			cSQL +=  " FROM " + RetSqlName("NX1") + " NX1 "
			cSQL +=      " INNER JOIN " + RetSqlName("NVE") + " NVE "
			cSQL +=      " ON NVE.NVE_FILIAL = '" + xFilial("NX1") + "' "
			cSQL +=         " AND NVE.NVE_CCLIEN = NX1.NX1_CCLIEN "
			cSQL +=         " AND NVE.NVE_LCLIEN = NX1.NX1_CLOJA "
			cSQL +=         " AND NVE.NVE_NUMCAS = NX1.NX1_CCASO "
			cSQL +=         " AND NVE.NVE_ENCHON = '2' "
			cSQL +=         " AND NVE.D_E_L_E_T_ = ' ' "
			cSQL += " WHERE "
			cSQL +=   " NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
			cSQL +=   " AND NX1.NX1_CCONTR = '" + cContr  + "' "
			cSQL +=   " AND NX1.NX1_CPREFT = '" + cCodPre + "' "
			cSQL +=   " AND NX1.D_E_L_E_T_ = ' ' "
		ElseIf !Empty(cFatura)
			cSQL := "SELECT NVE.NVE_DTENTR DTENTR, NVE.NVE_DTENCE DTENCE, NVE.NVE_SITUAC SITUAC "
			cSQL +=  " FROM " + RetSqlName("NXC") + " NXC "
			cSQL +=      " INNER JOIN " + RetSqlName("NVE") + " NVE "
			cSQL +=      " ON NVE.NVE_FILIAL = '" + xFilial("NXC") + "' "
			cSQL +=         " AND NVE.NVE_CCLIEN = NXC.NXC_CCLIEN "
			cSQL +=         " AND NVE.NVE_LCLIEN = NXC.NXC_CLOJA "
			cSQL +=         " AND NVE.NVE_NUMCAS = NXC.NXC_CCASO "
			cSQL +=         " AND NVE.NVE_ENCHON = '2' "
			cSQL +=         " AND NVE.D_E_L_E_T_ = ' ' "
			cSQL += " WHERE NXC.NXC_FILIAL = '" + xFilial( "NXC" ) + "' "
			cSQL +=   " AND NXC.NXC_CFATUR = '" + cFatura + "' "
			cSQL +=   " AND NXC.NXC_CCONTR = '" + cContr  + "' "
			cSQL +=   " AND NXC.D_E_L_E_T_ = ' ' "
		Else
			lRet := .F.
		EndIf

		cSQL := ChangeQuery(cSQL, .F.)
		DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cSQL ), cAlQry, .T., .F. )
		While !(cAlQry)->(Eof())
			If Empty(cDtIni) .Or. Empty(cDtIni)
				lRet := .F.
			EndIf
			If lRet
				If (cAlQry)->SITUAC == "1" //Andamento
					If lFxAber
						lCasoAtiv := (cAlQry)->DTENTR <= cDtFin
					Else
						lCasoAtiv := (cAlQry)->DTENTR < cDtIni
					EndIf
				Else   //Encerrado
					If lFxAber
						If lFxEnce
							lCasoAtiv := (cAlQry)->DTENTR <= cDtFin .AND. (cAlQry)->DTENCE >= cDtIni
						Else
							lCasoAtiv := (cAlQry)->DTENTR <= cDtFin .AND. (cAlQry)->DTENCE > cDtFin
						EndIf
					Else
						If lFxEnce
							lCasoAtiv := (cAlQry)->DTENTR < cDtIni .AND. (cAlQry)->DTENCE >= cDtIni
						Else
							lCasoAtiv := (cAlQry)->DTENTR < cDtIni .AND. (cAlQry)->DTENCE > cDtFin
						EndIf
					EndIf
				EndIf
			EndIf
			If lCasoAtiv
				nQtdCasos := nQtdCasos + 1
			EndIf
			(cAlQry)->(DbSkip())
		EndDo
		(cAlQry)->(DbCloseArea())

	Else //Processos
		nQtdCasos := JurQtdProc(cDtIni, cDtFin, .T. /*Em andamento*/, lFxAber, lFxEnce, cContr) //Função do SIGAJURI que retorna o número de processos, considerando os parâmetros passados
	EndIf

	If lRet .And. nQtdCasos > 0
		aFaixas := JSeekFxFt(cContr)
		If !Empty(aFaixas) // {"NTR_VLINI, NTR_VLFIM, NTR_TPVL, NTR_VALOR, NTR_CTABH"}
			For nI := 1 To Len(aFaixas)
				Do Case
				Case cNT0TPFX == "1" // Estática
					If aFaixas[nI][1] <= nQtdCasos .And. aFaixas[nI][2] >= nQtdCasos
						If aFaixas[nI][3] == "1"  //1-Valor Fixo
							nValor += aFaixas[nI][4]
						Else                     //2-Valor Unitário
							nValor += nQtdCasos * aFaixas[nI][4]
						EndIf
						Exit
					EndIf
				Case cNT0TPFX == "2" // Progressiva
					If nQtdCasos >= aFaixas[nI][1]
						If aFaixas[nI][3] == "1"         //1-Valor Fixo
							nValor += aFaixas[nI][4]
						Else                            //2-Valor Unitário
							Iif(nI > 1, nDif := 1, nDif := 0)
							If nQtdCasos <= aFaixas[nI][2]
								nValor += ((nQtdCasos - (aFaixas[nI][1] - nDif)) * aFaixas[nI][4]) //Considera o intervalo apenas até o valor final dentro da faixa
							Else
								nValor += ((aFaixas[nI][2] - (aFaixas[nI][1] - nDif)) * aFaixas[nI][4]) //Considera todo o intervalo da faixa
							EndIf
						EndIf
					EndIf
				End Case
			Next nI
		EndIf
	EndIf

	If lRet
		aRet := {nValor, nQtdCasos}
	EndIf

EndIf

RestArea(aArea)

Return (aRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} JTransData
Transforma a cadeia de caracteres em uma data considerando o formato informado.

@Param  cData       Cadeia de caracteres para transformação em data
@Param  cFormato   Formato da cadeia de caracteres a ser convertida para data

@Return dData       Data no formato padrão retornado pelo CtoD = "14/10/2014"

@author Cristina Cintra
@since 14/10/2014
/*/
//------------------------------------------------------------------------
Function JTransData(cData, cFormato)
	Local cDia       := ""
	Local cMes       := ""
	Local cAno       := ""
	Local nPosIniDia := 0
	Local nPosFimDia := 0
	Local nPosIniMes := 0
	Local nPosFimMes := 0
	Local nPosIniAno := 0
	Local nPosFimAno := 0
	Local dData      := CtoD("")

	Default cData    := ""
	Default cFormato := ""

	If !Empty(cData) .And. !Empty(cFormato)

		cFormato := Strtran(cFormato, "-", "/")
		cData    := Strtran(cData, "-", "/")

		cFormato := Upper(Alltrim(cFormato))

		If cFormato == "AAAAMMDD" .Or. cFormato == "YYYYMMDD"
			dData := StoD(cData)
		ElseIf cFormato == "DD/MM/AAAA" .Or. cFormato == "DD/MM/YYYY"
			dData := CtoD(cData)
		Else
			nPosIniDia := At("D", cFormato)
			nPosFimDia := Rat("D", cFormato)
			nPosIniMes := At("M", cFormato)
			nPosFimMes := Rat("M", cFormato)
			nPosIniAno := Iif(At("Y", cFormato) > 0, At("Y", cFormato), At("A", cFormato))
			nPosFimAno := Iif(At("Y", cFormato) > 0, Rat("Y", cFormato), Rat("A", cFormato))

			cDia  := Alltrim(Substr(cData, nPosIniDia, (nPosFimDia - nPosIniDia) + 1))
			cMes  := Alltrim(Substr(cData, nPosIniMes, (nPosFimMes - nPosIniMes) + 1))
			cAno  := Alltrim(Substr(cData, nPosIniAno, (nPosFimAno - nPosIniAno) + 1))

			dData := CtoD(cDia + "/" + cMes + "/" + cAno)

		EndIf

	EndIf

Return dData

//------------------------------------------------------------------------
/*/{Protheus.doc} JExistCpo
Função para buscar registro na tabela, com a chave e índice informado.
Usado no lugar do ExistCpo para que não dê mensagem de Help na tela.
Usado na integração Equitrac.

@Param  cTabela     Tabela onde deverá ser feita a busca
@Param  cChave      Conteúdo a ser procurado na tabela
@Param  nIndice     Índice de busca na tabela indicada

@Return lRet        Retorna se encontrou (.T.) ou não (.F.)

@author Cristina Cintra
@since 15/10/2014
/*/
//------------------------------------------------------------------------
Function JExistCpo(cTabela, cChave, nIndice)
	Local aArea     := GetArea()
	Local lRet      := .T.

	Default cTabela := ""
	Default cChave  := ""
	Default nIndice := 1

	If !Empty(cTabela) .And. !Empty(cChave)
		dbSelectArea(cTabela)
		dbSetOrder(nIndice)
		If !DbSeek(xFilial(cTabela) + cChave)
			lRet := .F.
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JFILASINC
Rotina genérica utilizada no Commit de diversas rotinas para efetuar a
inclusão do registro manipulado na fila de sincronização (Legal Desk).

@author Cristina Cintra
@since 21/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFILASINC(oModel, cTabela, cModelo, cCampo1, cCampo2, cCampo3)
Local lRet      := .T.

Default oModel  := Nil
Default cTabela := ""
Default cModelo := ""
Default cCampo1 := ""
Default cCampo2 := ""
Default cCampo3 := ""

If oModel <> Nil .And. !Empty(cTabela) .And. !Empty(cCampo1)
	lRet := J170GRAVA(oModel, xFilial(cTabela) + oModel:GetValue(cModelo, cCampo1) + ;
	                  Iif(!Empty(cCampo2), oModel:GetValue(cModelo, cCampo2), "") + ;
	                  Iif(!Empty(cCampo3), oModel:GetValue(cModelo, cCampo3), ""))
EndIf

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} JBlqTSheet
Determinar se um TimeSheet deve ou não ser bloqueado para manutenção,
Inclusão, Alteração e Exclusão.

@Param  dDtTimeSheet Data de criação do Timesheet

@Return aRet  Retorna Array lógico com as liberações do TimeSheet: {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao}

@author Julio de Paula Paz
@since 13/01/2015
/*/
//------------------------------------------------------------------------
Function JBlqTSheet(dDtTimeSheet)
	Local aRet           := {.T., .T., .T., .T.}    // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao}
	Local cPerCorte      := GetMv("MV_JCORTE",, "") // Define o critério para corte de lançamento dos time sheets, onde 1=Mensal e 2=Quinzenal.
	Local nNrDiasUteis   := GetMv("MV_JCORDIA",, 0) // Define a quantidade de dias úteis para digitação dos time sheets após o corte.
	Local cHoraLimLanc   := GetMv("MV_JCORHRA",, "23:59") // Horário de corte dos lançamentos dos time sheets.
	Local cCodUser       := __CUSERID  // Código de usuário de logon do SIGAPFS.
	Local nOldArea       := Select()
	Local aOrd           := SaveOrd({"NUR", "NW9"})
	Local cCodPart       := ""
	Local cPerManip      := '1' // Permite manipulação após corte
	Local cPerIncl       := '1' // Permite inclusão após corte
	Local cPerAlter      := '1' // Permite alteração após corte
	Local cPerExcl       := '1' // Permite exclusão após corte
	Local cDataCorte     := ""
	Local lLiberaInc     := .T.
	Local lLiberaAlt     := .T.
	Local lLiberaExc     := .T.
	Local nHoraDtBase    := 0
	Local nMinDtBase     := 0
	Local nHoraCorte     := 0
	Local nMinCorte      := 0
	Local nDiaTs         := 0
	Local dDtMesSeguinte := Nil
	Local dDtCorte       := Nil // Data de Corte

	// Proteção após alteração do parâmetro MV_JCORTE para que use números
	If cPerCorte == "M"
		cPerCorte := "1"
	ElseIf cPerCorte == "Q"
		cPerCorte := "2"
	EndIf

	Begin Sequence
		If !AllTrim(cPerCorte) $ "1|2|M|Q"
			JurMsgErro(STR0262, , STR0263)//"Atualize o parâmetro MV_JCORTE." "Deve ser igual a '1' ou '2': 1=Mensal ou 2=Quinzenal."
			aRet := {.F., .F., .F., .F., .F.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
			Break
		EndIf

		If Empty(cPerCorte) // Se não existir período de corte, não validar período de lançamento no TimeSheet.
			Break
		ElseIf ! AllTrim(cPerCorte) $ "1|2"
			MsgInfo(STR0112, STR0113)  // "Critério para corte de lançamento dos time sheets inválido. O critério indicado no parâmetro MV_JCORTE deve ser igual a '1' ou '2': 1=Mensal ou 2=Quinzenal." ### "Atenção"
			aRet := {.F., .F., .F., .F., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
			Break
		EndIf

		If Empty(dDtTimeSheet)
			MsgInfo(STR0114, STR0113)  //  "Data do Time Sheet não informada." ### "Atenção"
			aRet := {.F., .F., .F., .F., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
			Break
		EndIf

		cQry := "SELECT RD0_CODIGO FROM " + RetSQLName('RD0') + " RD0 "
		cQry += " WHERE RD0.D_E_L_E_T_ = ' ' AND RD0.RD0_FILIAL = '" + xFilial('RD0') + "' AND RD0.RD0_USER = '" + cCodUser + "' "

		cQry := ChangeQuery(cQry, .F.)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry ), "QRYRD0", .T., .F. )

		If QRYRD0->(Eof())
			MsgInfo(STR0115, STR0113)  //   "Código de usuário do SIGAPFS não localizado no cadastro de participantes." ### "Atenção"
			aRet := {.F., .F., .F., .F., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}

			QRYRD0->(DbCloseArea())
			Break
		EndIf
		cCodPart := QRYRD0->RD0_CODIGO

		QRYRD0->(DbCloseArea())

		NUR->(DbSetOrder(1)) // NUR_FILIAL+NUR_CPART
		If ! NUR->(DbSeek(xFilial("NUR") + cCodPart))
			MsgInfo(STR0116, STR0113)  //  "Código de usuário do SIGAPFS não localizado no cadastro de participantes." ### "Atenção"
			aRet := {.F., .F., .F., .F., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
			Break
		EndIf

		cPerManip := NUR->NUR_PERIOD  // Permite a manipulação (inclusão, alteração e exclusão) de time sheets após o corte.
		cPerIncl  := NUR->NUR_PERINC  // Permite a inclusão de time sheets após o corte.
		cPerAlter := NUR->NUR_PERALT  // Permite a alteração de time sheets após o corte.
		cPerExcl  := NUR->NUR_PEREXC  // Permite a exclusão de time sheets após o corte.

		If cPerManip == '1' // Sim
			aRet := {.T., .T., .T., .T., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
			Break
		EndIf
		nDiaTs := Day(dDtTimeSheet)
		If nDiaTs > 25 // Isso se faz necessário por que o mes do Timesheet pode terminar nos dias 28,29,30 e 31. No nosso caso, o mês seguinte pode terminar no dia 31.
			nDiaTs -= 5  // Só precisamos posicionar no mês seguinte para calcular o ultimo dia do mês do Timesheet.
		EndIf
		If (Month(dDtTimeSheet) + 1) <= 12 // Retorna a data do Timesheet no mes seguinte
			dDtMesSeguinte := CtoD( StrZero(nDiaTs, 2) + "/" + StrZero(Month(dDtTimeSheet) + 1, 2) + "/" + StrZero(Year(dDtTimeSheet), 4))
		Else
			dDtMesSeguinte := CtoD( StrZero(nDiaTs, 2) + "/01/" + StrZero(Year(dDtTimeSheet) + 1, 4))
		EndIf

		Do Case
		Case AllTrim(cPerCorte) == '2' // Critério para Corte Quinzenal
			If Day(dDtTimeSheet) <= 15  // Pega a primeira quinzena da data do Timesheet
				cDataCorte := '15/' + StrZero(Month(dDtTimeSheet), 2) + '/' + SubStr(StrZero(Year(dDtTimeSheet), 4), 3, 2)
				dDtCorte   := CtoD(cDataCorte) // Dia 15 do mês do Timesheet.
			Else   // Pega a segunda quinzena da data do timesheet.
				cDataCorte := '01/' + StrZero(Month(dDtMesSeguinte), 2) + '/' + SubStr(StrZero(Year(dDtMesSeguinte), 4), 3, 2)
				dDtCorte   := CtoD(cDataCorte) - 1 // Ultimo dia do mes do Timesheet.
			EndIf

		Case AllTrim(cPerCorte) == '1' // Critério para Corte Mensal
			cDataCorte := '01/' + StrZero(Month(dDtMesSeguinte), 2) + '/' + SubStr(StrZero(Year(dDtMesSeguinte), 4), 3, 2)
			dDtCorte   := CtoD(cDataCorte) - 1 // Ultimo dia do mes do Timesheet.
		EndCase

		dDtCorte := dDtCorte + nNrDiasUteis // Acrescenta numero de dias úteis para a data de corte.

		NW9->(DbSetOrder(2)) // NW9_FILIAL+DTOS(NW9_DATA)+NW9_CESCR // Cadastro de feriados do SIGAPFS
		Do While .T.
			If DoW(dDtCorte) == 7 // é sábado ?
				dDtCorte := dDtCorte + 2 // posiciona a data na segunda-feira
			ElseIf DoW(dDtCorte) == 1 // é domingo ?
				dDtCorte := dDtCorte + 1 // posiciona a data na segunda-feira
			EndIf
			If NW9->(DbSeek(xFilial("NW9") + Dtos(dDtCorte))) // é feriado ?
				dDtCorte += 1 // posiciona a data de corte no dia seguinte
			ElseIf DoW(dDtCorte) < 7 // É de segunda a sexta-feira e Não é feriado ?
				Exit
			EndIf
		EndDo

		If dDataBase < dDtCorte
			aRet := {.T., .T., .T., .T., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
			Break
		ElseIf dDataBase == dDtCorte // Data de corte e data da manutenção no timesheet iguais.
			nHoraDtBase := Val(SubStr(Time(), 1, 2)) // Hora no momento da manutenção
			nMinDtBase  := Val(SubStr(Time(), 4, 2)) // Minuto no momento da manutenção
			nHoraCorte  := Val(SubStr(cHoraLimLanc, 1, 2))  // Hora de corte definida no parâmetro
			nMinCorte   := Val(SubStr(cHoraLimLanc, 4, 2) ) // Minuto de corte definido no parâmetro

			If nHoraDtBase < nHoraCorte // Hora no momento da manutenção menor que a hora de corte.
				aRet := {.T., .T., .T., .T., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
				Break
			EndIf

			If nHoraDtBase == nHoraCorte // Hora no momento da manutenção igual a hora de corte
				If nMinDtBase < nMinCorte .Or. nMinDtBase == nMinCorte  // Minuto no momento da manutenção menor ou igual ao minuto de corte.
					aRet := {.T., .T., .T., .T., .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
					Break
				EndIf
			EndIf

			lLiberaInc := If(cPerIncl  == '1', .T., .F.)
			lLiberaAlt := If(cPerAlter == '1', .T., .F.)
			lLiberaExc := If(cPerExcl  == '1', .T., .F.)
		Else  // A data no momento ou hora e minuto de manutenção estão acima do limite de corte.
			lLiberaInc := If(cPerIncl  == '1',.T.,.F.)
			lLiberaAlt := If(cPerAlter == '1',.T.,.F.)
			lLiberaExc := If(cPerExcl  == '1',.T.,.F.)
		EndIf

		// Neste caso a liberação será dada com base nas permições dadas ao usuário.
		If lLiberaInc .And. lLiberaAlt .And. lLiberaExc // Inlcusão, Alteração e Exclusão liberado. O usuário pode realizar todas as manutenções.
			aRet := {.T., .T., .T., .T., .T.}
		Else
			aRet := {.F., lLiberaInc, lLiberaAlt, lLiberaExc, .T.} // {lLiberado, lLiberaInclusao, lLiberaAlteracao, lLiberaExclusao, lLibParam}
		EndIf

	End Sequence

	DbSelectArea(nOldArea)
	RestOrd(aOrd)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetPerFT(cFatura, cEscri)
Rotina para trazer o periodo real dos lançamentos (TS,DP,LT,FX) na fatura.

@param	cEscri		Cod Escritorio
@param	cFatura		Cod Fatura

@Return aRet        [1] Inicio do Periodo de faturamento da fatura - string
                    [2] Final do periodo de faturamento da fatura - string

@author Luciano Pereira dos Santos
@since 02/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetPerFT(cFatura, cEscr )
	Local aArea   := GetArea()
	Local cQuery  := ''
	Local aRet    := {"", ""}

	cQuery := " SELECT MIN(DTINI) DTINI, MAX(DTFIM) DTFIM FROM "
	cQuery += " ( "
	cQuery +=      " SELECT MIN(NUE.NUE_DATATS) DTINI, MAX(NUE.NUE_DATATS) DTFIM "
	cQuery +=   " FROM " + RetSqlName( 'NUE' ) + " NUE "
	cQuery +=   " INNER JOIN " + RetSqlName("NW0") + " NW0 "
	cQuery +=         " ON( NW0.NW0_FILIAL = '" + xFilial("NW0") + "' "
	cQuery +=             " AND NW0.NW0_CTS = NUE.NUE_COD "
	cQuery +=             " AND NW0.NW0_CESCR = '" + cEscr + "' "
	cQuery +=             " AND NW0.NW0_CFATUR = '" + cFatura + "' "
	cQuery +=             " AND NW0.D_E_L_E_T_ = ' ' ) "
	cQuery +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=    " AND NUE.D_E_L_E_T_ = ' ' "

	cQuery +=      " UNION "
	cQuery += " SELECT MIN(NVY.NVY_DATA) DTINI, MAX(NVY.NVY_DATA) DTFIM "
	cQuery +=   " FROM " + RetSqlName( 'NVY' ) + " NVY "
	cQuery +=   " INNER JOIN " + RetSqlName("NVZ") + " NVZ "
	cQuery +=         " ON( NVZ.NVZ_FILIAL = '" + xFilial("NVZ") + "' "
	cQuery +=             " AND NVZ.NVZ_CDESP = NVY.NVY_COD "
	cQuery +=             " AND NVZ.NVZ_CESCR = '" + cEscr + "' "
	cQuery +=             " AND NVZ.NVZ_CFATUR = '" + cFatura + "' "
	cQuery +=             " AND NVZ.D_E_L_E_T_ = ' ' ) "
	cQuery +=  " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=    " AND NVY.D_E_L_E_T_ = ' ' "

	cQuery +=      " UNION "
	cQuery += " SELECT MIN(NV4.NV4_DTCONC) DTINI, MAX(NV4.NV4_DTCONC) DTFIM "
	cQuery +=   " FROM " + RetSqlName( 'NV4' ) + " NV4 "
	cQuery +=   " INNER JOIN " + RetSqlName("NW4") + " NW4 "
	cQuery +=         " ON( NW4.NW4_FILIAL = '" + xFilial("NW4") + "' "
	cQuery +=             " AND NW4.NW4_CLTAB =  NV4.NV4_COD "
	cQuery +=             " AND NW4.NW4_CESCR = '" + cEscr + "' "
	cQuery +=             " AND NW4.NW4_CFATUR = '" + cFatura + "' "
	cQuery +=             " AND NW4.D_E_L_E_T_ = ' ' ) "
	cQuery +=  " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery +=    " AND NV4.D_E_L_E_T_ = ' ' "

	cQuery +=      " UNION "
	cQuery += " SELECT MIN(NT1.NT1_DATAIN) DTINI, MAX(NT1.NT1_DATAFI) DTFIM "
	cQuery +=   " FROM " + RetSqlName( 'NT1' ) + " NT1 "
	cQuery +=  " INNER JOIN " + RetSqlName("NWE") + " NWE "
	cQuery +=     " ON NWE.NWE_FILIAL = '" + xFilial("NWE") + "' "
	cQuery +=    " AND NWE.NWE_CFIXO  =  NT1.NT1_SEQUEN "
	cQuery +=    " AND NWE.NWE_CESCR  = '" + cEscr   + "' "
	cQuery +=    " AND NWE.NWE_CFATUR = '" + cFatura + "' "
	cQuery +=    " AND NWE.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
	cQuery +=    " AND NT1.D_E_L_E_T_ = ' ' "
	cQuery += " ) LANCS "

	aRet := JurSQL(cQuery, {"DTINI", "DTFIM"})

	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurShowPf(cAliasTb, cTipoLanc, nOperacao, aCampos, cTpDesp)
Informa se o lançamento esta sendo retirado ou adicionado em um caso que possui pré-fatura

@Param  cAliasTb    Alias da tabela
@Param  cTipoLanc   Tipo do lançamento (TS = Time Sheet / DP = Despesa / LT = Lançamento Tabelado)
@Param  nOperacao   Código de operação do modelo (3: Inclusão, 4: Alteração e 5: Exclusão)
@Param  aCampos     Array com as informações:.
[1,1] codigo do cliente do banco
[1,2] codigo do cliente do modelo (alterado)
[2,1] codigo da loja do banco
[2,2] codigo da loja do modelo (alterado)
[3,1] codigo do caso do banco
[3,2] codigo do caso do modelo (alterado)
[4,1] data do lançamento do banco
[4,2] data do lançamento do modelo (alterado)
[5,1] número da pré-fatura do banco
[5,2] número da pré-fatura do modelo (alterado)
@Param  cTpDesp     Código do tipo de despesa
@Param  lCobravel   Indica se o lançamento é cobrável
@Param  cCodLanc    Código do lançamento
@Param  lShowMsg    Informa se exibe mensagem de log

@obs Usar antes do commit do modelo.

@author Ricardo Ferreira Neves
@since 29/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurShowPf(cAliasTb, cTipoLanc, nOperacao, aCampos, cTpDesp, lCobravel, cCodLanc, lShowMsg)
	Local aArea       := GetArea()
	Local aAreaNX0    := NX0->(GetArea())
	Local nI          := 0
	Local aPreFatIn   := {}
	Local aPreFatOut  := {}
	Local cMsgLanc    := ''
	Local lMesmaPre   := .F.
	Local cTitulo     := ''
	Local cPartLog    := ''
	Local cMsg        := ""
	Local cOper       := ""
	Local cClient     := ""
	Local lAlterada   := .F.
	Local lIntFinanc  := SuperGetMV("MV_JURXFIN",, .F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local lOrigJ241   := .F.
	Local lOrigJ246   := .F.
	Local lOrigJ247   := .F.
	Local lFinanceiro := .F.

	Default cTpDesp   := ''
	Default lCobravel := .T.
	Default lShowMsg  := .T.

	If lIntFinanc
		lOrigJ241 := FwIsInCallStack("J241CMDesp") // Quando a origem da operação for da JURA241(Lançamento)
		lOrigJ246 := FwIsInCallStack("J246CMDesp") // Quando a origem da operação for da JURA246(Desdobramento)
		lOrigJ247 := FwIsInCallStack("J247CMDesp") // Quando a origem da operação for da JURA247(Desdobramento pós pagamento)
	EndIf

	// Indica se a chamada está vindo do Financeiro
	lFinanceiro := lOrigJ241 .Or. lOrigJ246 .Or. lOrigJ247

	If !Empty(aCampos)
		Do Case
		Case cTipoLanc == 'TS'
			cMsg := STR0194 //"#1 do timesheet '#2' do cliente '#3', caso '#4'."
		Case cTipoLanc == 'DP'
			cMsg := STR0195 //"#1 da despesa '#2' do cliente '#3', caso '#4'."
		Case cTipoLanc == 'LT'
			cMsg := STR0196 //"#1 do lançamento tabelado '#2' do cliente '#3', caso '#4'."
		EndCase

		Do Case
		Case nOperacao == 3
			cOper := STR0197 //"Inclusão"
		Case nOperacao == 4
			cOper := STR0198 //"Ateração"
		Case nOperacao == 5
			cOper := STR0199 //"Exclusão"
		EndCase

		If lCobravel //Se ele não é cobravel não pode ir pra nenhuma pré-fatura
			//Verifica se o lançamento esta indo para algum caso com pré-fatura
			cPartLog := JurUsuario(__CUSERID)
			If Empty(aCampos[5][2])
				aPreFatIn := JA202VERPRE(aCampos[1][2], aCampos[2][2], aCampos[3][2], aCampos[4][2], cTipoLanc, cTpDesp)
			Else //Se o lançamento já estiver na pré, só altera a propria pré-fatura.
				aPreFatIn := {{aCampos[5][2], JurGetDados('NX0', 1, xFilial('NX0') + aCampos[5][2], "NX0_SITUAC"), .T.}}
			EndIf

			For nI := 1 To Len(aPreFatIn)
				If NX0->(dbSeek(xFilial('NX0') + aPreFatIn[nI][1]))
					lAlterada := NX0->NX0_SITUAC == '3'
					If NX0->NX0_SITUAC $ '2|3|D|E'
						RecLock('NX0', .F.)
						NX0->NX0_SITUAC := '3'
						NX0->NX0_USRALT := cPartLog
						NX0->NX0_DTALT  := Date()
						NX0->(MsUnlock())
						NX0->(DbCommit())
						NX0->(DbSkip())
						If !lAlterada
							cClient := aCampos[1][2] + '|' + aCampos[2][2]
							J202HIST('99', aPreFatIn[nI][1], cPartLog, I18N(cMsg, {cOper, cCodLanc, cClient, aCampos[3][2]} ))
						EndIf
					EndIf
				EndIf
			Next nI
			cMsgLanc += JurLogLanc(aPreFatIn, aCampos[5][2], nOperacao, .T.)
		EndIf

		//Verifica se o lançamento saiu de algum caso com pré-fatura
		If !Empty(aCampos[5][1]) .And. nOperacao != 3
			aPreFatOut := JA202VERPRE(aCampos[1][1], aCampos[2][1], aCampos[3][1], aCampos[4][1], cTipoLanc, cTpDesp)

			lMesmaPre  := (aScan(aPreFatIn, {|x| x[1] == aCampos[5][1]}) != 0) //verifica se o caso de destino esta na mesma pré-fatura
			If !lMesmaPre
				cPartLog := JurUsuario(__CUSERID)
				For nI :=1 To Len(aPreFatOut)
					If (aPreFatOut[nI][1] ==  aCampos[5][1]) .And. (aPreFatOut[nI][2] $ '2|3|D|E') //Só altera a pré-fatura que o lançamento saiu.
						NX0->(dbSeek(xFilial('NX0') + aPreFatOut[nI][1]))
						RecLock('NX0', .F.)
						NX0->NX0_SITUAC := '3'
						NX0->NX0_USRALT := cPartLog
						NX0->NX0_DTALT  := Date()
						NX0->(MsUnlock())
						NX0->(DbCommit())
						NX0->(DbSkip())
						If aPreFatOut[nI][1] != '3'
							cClient := aCampos[1][1] + '|' + aCampos[2][1]
							J202HIST('99', aPreFatOut[nI][1], cPartLog, I18N(cMsg, {cOper, cCodLanc, cClient, aCampos[3][1]} ))
						EndIf
					EndIf
				Next nI

				cMsgLanc += JurLogLanc(aPreFatOut, aCampos[5][1], nOperacao, .T., .T.)
			EndIf
		EndIf
		

		Do Case
		Case cTipoLanc == 'TS'
			cTitulo := STR0095  //"TimeSheet"
		Case cTipoLanc == 'DP'
			cTitulo := STR0096 //"Despesas"
		Case cTipoLanc == 'LT'
			cTitulo := STR0097 //"Serviço Tabelado"
		EndCase

		If !Empty(cMsgLanc) .And. !lFinanceiro .And. lShowMsg
			ApMsgInfo(cMsgLanc, cTitulo)
		EndIf

	EndIf

	RestArea( aAreaNX0 )
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JMsgVerPre(cTipo)
Rotina para retornar a mesagem de solução para a alteração de lançamento em pré-fatura
considerando as situções e o parâmtros do legaldesk; se participante esta sem permissão de
alteração em pré-fatura; e se o usuario logado nao esta associado a um participante.

@Param   cTipo '1' - Mensagem de solução para alteração de lançamento em pré-fatura;
				'2' - Solução para participante esta sem permissão de alteração em pré-fatura;
				'3' - Mensagem de solução para usuario logado sem estar associado a um participante

@Return   cRet  Mensagem de solução

@obs Usada na JA027VERPRE, JA049VERPRE e JA144VERPRE

@author Luciano Pereira dos  Santos
@since 20/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JMsgVerPre(cTipo)
Local aSituac := {}
Local cSituac := ''
Local cUltima := ''
Local cPart   := ''
Local cSigla  := ''
Local cRet    := ''
Local nI      := 0

Default cTipo := ''

Do Case
Case cTipo == '1'

	If (SuperGetMV("MV_JFSINC", .F., '2') == '1')
		aSituac := {'2','3','D','E'}
	Else
		aSituac := {'2','3'}
	EndIf

	For nI := 1 To Len(aSituac)
		If nI == Len(aSituac)
			cUltima := Alltrim(JurSitGet(aSituac[nI]))
		Else
			cSituac += IIf(nI != 1 .and. Len(aSituac) > 2 , ', ', '') + Alltrim(JurSitGet(aSituac[nI]))
		EndIf
	Next nI

	cRet   := I18N(STR0135, {cSituac, cUltima}) //"É possivel alterar lançamentos em pré-fatura somente nas situações #1 e #2."

Case cTipo == '2'

	cPart  := JurUsuario(__CUSERID)
	cSigla := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA")
	cRet   := I18N(STR0136, {cSigla}) //"No cadastro de participantes, verifique se o participante de sigla '#1' possui permissão para alteração de lançamentos em pré-fatura."

Case cTipo == '3'

	cRet   := I18N(STR0137, {__CUSERID}) //"No cadastro de participantes, verifique se existe algum participante associado ao usuário '#1'."

OtherWise

	cRet  := ""

EndCase

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JNzoVldTrf(cTipoRF)
Valida se o tipo de relatorio de pre-fatura (NZO) esta ativo

@param	cTipoRF		Tipo de Relatorio de Pre-Fatura

@return lRet   .T. - validacao OK, libera o campo
               .F. - validacao falhou, nao libera o campo

@author Mauricio Canalle
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JNzoVldTrf(cTipoRF)
	Local lRet      := .T.
	Local aArea     := GetArea()

	NZO->( dbSetOrder( 1 ) ) //NZO_FILIAL+NZO_COD
	If NZO->( dbSeek( xFilial('NZO') + cTipoRF, .F. ) )
		If !NZO->NZO_ATIVO == '1'
			lRet := JurMsgErro( STR0123 ) //'Este tipo de relatório não pode ser utilizado pois está inativo'
		EndIf
	Else
		lRet := JurMsgErro( STR0124 ) //'Tipo de Relatório Não Cadastrado...'
	EndIf

	RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRound()
Rotina de arredondamento segundo a Norma ABNT 5891:2014

@Param    nValor   Valor a ser arrendondado
@Param    nDecimal Numero de casas decimais. Default := 2
@Param    nModo    Modo de Arredondamento: 1-ABNT; 2-Padrão; 3-Trunca. Default := 1

@Return   nRet Valor arredondado

@author Luciano Pereira dos  Santos
@since 22/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurRound(nValor, nDecimal, nModo)
	Local nRet       := 0
	Local cValor     := ''
	Local cInteiro   := ''
	Local cFracao    := ''
	Local nConserv   := 0
	Local nSeguido   := 0
	Local nRestant   := 0

	Default nDecimal := 2
	Default nModo    := 1

	If nModo == 1

		cValor   := Alltrim(Str(nValor))
		cInteiro := Alltrim(Str(Int(nValor))) //String da parte inteira
		cFracao  := Substr(cValor, At('.', cValor) + 1) //String da parte fracionada
		nConserv := Val(substr(cFracao, nDecimal, 1)) //Algarismo a ser conservado
		nSeguido := Val(substr(cFracao, nDecimal + 1, 1)) //Algarismo seguinte ao algarismo conservado
		nRestant := Val(substr(cFracao, nDecimal + 2)) //Restante dos algarismos da fração

		Do Case
		Case nConserv < 5 //ABNT 5891:2014 2.1
			nRet := Val(cInteiro + '.' + Substr(cFracao, 1, nDecimal))
		Case nConserv >= 5 .And. nRestant != 0 //ABNT 5891:2014 2.2
			nRet := Val(cInteiro + '.' + Substr(cFracao, 1, nDecimal)) + (1 / (10^nDecimal))
		Case Mod(nConserv, 2) != 0 .And. nSeguido == 5 .And. nRestant == 0 //ABNT 5891:2014 2.3
			nRet := Val(cInteiro + '.' + Substr(cFracao, 1, nDecimal)) + (1 / (10^nDecimal))
		Case Mod(nConserv, 2) == 0 .And. nSeguido == 5 .And. nRestant == 0 //ABNT 5891:2014 2.4
			nRet := Val(cInteiro + '.' + Substr(cFracao, 1, nDecimal))
		OtherWise
			nRet := Round(nValor, nDecimal)
		EndCase

	ElseIf nModo == 2
		nRet := Round(nValor, nDecimal)

	ElseIf nModo == 3
		nRet := NoRound(nValor, nDecimal)

	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoja()
Rotina para gatilho da Loja onde não envolve pagamento, para atender
o parâmetro MV_JLOJAUT

@Return   cRet - valor de loja

@author Bruno Ritter
@since 13/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLoja()
Local cRet      := ""
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cCodCli   := &(READVAR()) //Recebe o valor do campo que está sendo editado

	If (cLojaAuto == "1" .And. !Empty(cCodCli))
		cRet := JurGetLjAt()
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRetLoja()
Rotina para verificar se deve retorna a loja na consulta especifica SA1NUH

@Return   cRet - valor de loja

@author Bruno Ritter
@since 13/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurRetLoja()
Local cRet        := ""
Local oModel      := FwModelActive()
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lIgnLojaAut := .F.
Local cCampo      := AllTrim(__ReadVar)

	If "_CLIPG" $ cCampo;
	.Or. cCampo == "M->NWF_CCLIAD";
	.Or. Empty(oModel);
	.Or. IsInCallStack("J246DIALOG")
		lIgnLojaAut := .T.
	ElseIf cCampo == "M->NT0_CCLICM"
		If cLojaAuto == "2"
			lIgnLojaAut := .T.
		Else
			Return cRet
		EndIf
	EndIf

	If (cLojaAuto == "2" .Or. lIgnLojaAut)
		cRet := SA1->A1_LOJA
	Else
		If cCampo != "M->NYX_CCLIEN" // No cadastro de aprovação tarifador o nome do cliente NÃO vem após a loja
			cRet := SA1->A1_NOME
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldCli (cGrupo, cClien, cLoja, cCaso, cCpoLanc, cVal, lMsg)
Validação padrão dos campos: Grupo, Cliente, Loja e Caso.
Valiação não deve ser usada para clientes pagadores, exemplo, não deve ser usada para validar o cliente da NXP

@param cGrupo -   Valor do grupo do cliente no modelo
@param cClien -   Valor do código do cliente no modelo
@param cLoja -    Valor da loja do cliente no modelo
@param cCaso -    Valor do Casono modelo
@param cCpoLanc - Informar o nome do campo de lançamento para validar o Caso
                            nos lançamentos (Time-Sheeet, Despesa , Tabelado)
@param cVal -     Campo que está sendo validado: "GRP" - Grupo do Cliente,
                                                 "CLI" - Código do Cliente,
                                                 "LOJ" - Loja do Cliente,
                                                 "CAS" - Caso.
@param lMsg -     Se será exibida a mensagem de erro, Valor padrão .T. (sim)
@param lCliPag -  Se o cliente é pagador
@param dDtLanc -  Data do lançamento para verificar se o caso ainda pode ser usado quando encerrado
@param lValBlq -  .T. habilita a validação de cliente bloqueado.

@Sample 1 JurVldCli (cGrupo, cClien, cLoja, cCaso, ,"CAS", .T.)
@Sample 2 JurVldCli (cGrupo, cClien, cLoja, cCaso, "NVE_LANDSP", "CAS", .T.)

@Return   lRet  .T. ou .F.

@author Bruno Ritter
@since 21/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldCli(cGrupo, cClien, cLoja, cCaso, cCpoLanc, cVal, lCliPag, lMsg, dDtLanc, lValBlq)
Local lRet         := .T.
Local cPerfil      := ''
Local aCliLoj      := {}
Local cNumCaso     := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local cLojaAuto    := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Default cGrupo     := ""
Default cLoja      := ""
Default cCaso      := ""
Default cCpoLanc   := ""
Default lCliPag    := .F.
Default lMsg       := .T.
Default dDtLanc    := CToD( '  /  /  ' )
Default lValBlq    := .T.

	//---------------------------------------------------------//
	//	Grupo do Cliente
	//---------------------------------------------------------//
	If Upper(cVal) == "GRP" .And. !Empty(cGrupo)
		lRet := Iif(lMsg, ExistCpo( "ACY", cGrupo, 1 ), !Empty(JurGetDados('ACY', 1, xFilial('ACY') + cGrupo, 'ACY_GRPVEN')))

	//---------------------------------------------------------//
	//	Código do Cliente
	//---------------------------------------------------------//
	ElseIf  Upper(cVal) == "CLI" .And. !Empty(cClien)
		If(cLojaAuto == "1" .And. !lCliPag )
			lRet := JurVldCli(cGrupo, cClien, JurGetLjAt(),,, "LOJ", lCliPag, lMsg) //Valida a loja antes de ser preenchida pelo gatilho.
		Else
			If Empty(Posicione("NUH", 1, xFilial("NUH") + cClien, "NUH_COD"))
				Iif(lMsg, lRet := JurMsgErro(STR0152,, STR0153), lRet := .F.) //#"Código do cliente não foi localizado!"  ##"Informe um código de Cliente válido."			
			EndIf
		EndIf

	//---------------------------------------------------------//
	//	Loja do Cliente
	//---------------------------------------------------------//
	ElseIf Upper(cVal) == "LOJ" .And. !Empty(cLoja)
		lRet := Iif(lMsg, ExistCpo( "SA1", cClien + cLoja, 1, , , lValBlq), !Empty(JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_COD')))

		If(lRet)
			cPerfil := JurGetDados('NUH', 1, xFilial('NUH') + cClien + cLoja, 'NUH_PERFIL')
			If(Empty(cPerfil))
				Iif(lMsg, lRet := JurMsgErro(STR0147), lRet := .F.) //"Cadastro de cliente incompleto, verificar preenchimento dos dados complementares pelo módulo Jurídico"				
			ElseIf (cPerfil != '1' .And. !lCliPag)
				Iif(lMsg, lRet := JurMsgErro(STR0145,, STR0146 + " (" + cClien + " / " + cLoja + ")"), lRet := .F.)//"Perfil do cliente não é Cliente/Pagador!" ##"Favor, verificar o cadastro do cliente preenchido"
			ElseIf (cLojaAuto == "1" .And. cLoja != JurGetLjAt() .And. !lCliPag)
				Iif(lMsg, lRet := JurMsgErro(STR0144), lRet := .F.) //#"A loja deve está com o valor '00' quando o parâmetro MV_JLOJAUT for igual à 1 (um)!"
			EndIf
		EndIf

	//---------------------------------------------------------//
	//	Caso
	//---------------------------------------------------------//
	ElseIf Upper(cVal) == "CAS" .And. !Empty(cCaso)

		If( Empty(cLoja) .And. cNumCaso == "2")
			aCliLoj := JCasoAtual(cCaso)
			If Empty(aCliLoj) .Or. Empty(aCliLoj[1][2])
				lRet := JurMsgErro(I18N(STR0150, {cCaso}),,; //"Não existe registro relacionado ao código de Caso '#1'."
				                   STR0151) //"Informe um código de Caso válido."
			Else
				cClien := aCliLoj[1][1]
				cLoja  := aCliLoj[1][2]
			EndIf
		Else
			If((Empty(cClien) .Or. Empty(cLoja)) .And. cNumCaso == "1")
				lRet := Iif(lMsg, JurMsgErro(STR0162), .F.) //"É necessário informar o Cliente antes de informar o Caso."
			EndIf

			If (lRet .And. Empty(JurGetDados('NVE', 1, xFilial('NVE') + cClien + cLoja + cCaso, 'NVE_NUMCAS')))
				If(lMsg)
					lRet := JurMsgErro(I18N(STR0149, {RetTitle('A1_LOJA'), cClien, cLoja, cCaso}),; //"Preenchimento de Cliente/'#1' ('#2'/'#3') x Caso ('#4') inválido!"
					                   "JurVldCli",;
					                   STR0151) //"Informe um código de Caso valido."
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf

		//-------------------------------------------------------------------//
		//	Condições para o lançamento de Time Sheet / Despesa / Tabelado
		//-------------------------------------------------------------------//
		If lRet .And. !Empty(cCpoLanc) .And. !IsInCallStack( 'JURA063' ) .And. !IsInCallStack( 'J063REMANJ' )
			If (lRet .And. JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, cCpoLanc) <> '1')
				If(lMsg)
					lRet := JurMsgErro(STR0159, "JurVldCli",; //"O Caso não permite este tipo de lançamento"
					                   I18N(STR0160, {RetTitle(cCpoLanc)})) //"Verifique o campo '#1' do Caso informado"
				Else
					lRet := .F.
				EndIf
			EndIf

			If lRet
				lRet := JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, 'NVE_SITUAC') == '1'
				If !lRet
					lRet := JRetDtEnc(JurGetDados("NVE", 1, xFilial("NVE") + cClien + cLoja + cCaso, "NVE_DTENCE"), SuperGetMV('MV_JLANC1',, 0)) >= dDtLanc
					If !lRet
						lRet := JurGetDados ("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), "NUR_CASOEN") == '1'
					EndIf
				EndIf
				If(!lRet .And. lMsg)
					JurMsgErro(STR0154,; //#O Caso está encerrado e não é permitida sua alteração."
				               "JurVldCli",;
				               STR0155 + CRLF; //#"Informe um código de Caso valido ou verifique:"
				               + I18N(STR0156, {RetTitle("NVE_SITUAC")}) + CRLF; //"1) O campo '#1' do Caso informado."
				               + I18N(STR0157, {RetTitle("NVE_DTENCE")}) + CRLF; //"2) A data de encerramento '#1' do Caso informado e o parâmetro 'MV_JLANC1'."
				               + I18N(STR0158, {RetTitle("NUR_CASOEN")}) ) //"3) O campo '#1' do Participante referente ao seu usúario."
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurClxCa(cClien, cLoja, cCaso)
Rotina para verificar se o cliente/loja pertence ao caso.

@obs Rotina geralmente usada na condição do gatilho do campo xxx_CCLIEN e xxx_CLOJA como campo dominio xxx_CCASO e xxx_DCASO,
     pois quando o parâmetro MV_JCASO1 = 2 (Númeração Independente do cliente), o campo xxx_CCASO pode ser preechido sem o cliente
     está previamente preenchido, desta forma os gatilhos preenche os campos xxx_CCLIEN e xxx_CLOJA automáticamente ao preencher o
     xxx_CCASO, assim se faz necessário utilizar essa condição no gatilho dos campos do Cliente para que não apagem os campos do Caso
     ao serem preenchidos pelo gatilho do Caso.

@sample JurClxCa("000000","00","000001")

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 22/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurClxCa(cClien, cLoja, cCaso)
Local lRet      := .F.
Local cNumCaso  := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Iif(cLojaAuto == "1", cLoja := JurGetLjAt(), )

If(cNumCaso == "2")
	aCliLoj := JCasoAtual(cCaso)
	If(!Empty(aCliLoj))
		If !Empty(cClien)
			lRet := cClien == aCliLoj[1][1]
		EndIf
		If lRet .And. !Empty(cLoja)
			lRet := cLoja  == aCliLoj[1][2]
		EndIf
	EndIf

ElseIf(cNumCaso == "1")
	lRet := !Empty(JurGetDados('NVE', 1, xFilial('NVE') + AllTrim(cClien + cLoja + cCaso), 'NVE_NUMCAS'))

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBrwRev(oBrowse, cAlias, aCampos)
Rotina para remover campos do browse em uma rotina MVC

@obs Não é necessário validar os campos (ex: if(X3_BROWSE=='S')),
     pois o Browser já executa esse tipo de validação.

@param cCampo - Nome do campo que deve ser removido.

@author Bruno Ritter
@since 27/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurBrwRev(oBrowse, cAlias, aCampos)
	Local cSX3Tmp  := GetNextAlias()
	Local aFilds   := {}
	Local cX3Campo := ""

	OpenSxs(,,,, cEmpAnt, cSX3Tmp, "SX3", , .F.)

	If (cSX3Tmp)->(DbSeek(cAlias))
		While (cSX3Tmp)->X3_ARQUIVO == cAlias .And. !(cSX3Tmp)->(EOF())
			cX3Campo := AllTrim((cSX3Tmp)->X3_CAMPO)
			If aScan(aCampos, cX3Campo) == 0
				Aadd(aFilds, cX3Campo)
			EndIf
			(cSX3Tmp)->(DbSkip())
		EndDo
	EndIf

	(cSX3Tmp)->(DbCloseArea())

	oBrowse:SetOnlyFields( aFilds )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetLjAt()
Rotina para gerar o valor da loja automatica conforme o tamanho do campo A1_LOJA

@author Bruno Ritter
@since 29/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetLjAt()
Local cRet      := ""
Local nLoja     := TamSX3('A1_LOJA')[1]
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

If cLojaAuto == "1"
	cRet := StrZero(0, nLoja)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTrgGCLC()
Gatilhos e validações para grupo/cliente/loja/Caso em telas feitas a mão utilizando a classe TJurPnlCampo

@obs Passar os objetos e as variáveis dos mesmos como referência.

@param cVal - Campo que está sendo validado: "GRP" - Grupo do Cliente,
                                             "CLI" - Código do Cliente,
                                             "LOJ" - Loja do Cliente,
                                             "CAS" - Caso.
@param cCpoLanc - Informar o nome do campo de lançamento para validar o Caso
                            nos lançamentos (Time-Sheeet, Despesa , Tabelado)

@param lCliPag  - Se o cliente é pagador

@Sample JurTrgGCLC(@oGrupo , @cGrupo , @oClien , @cClien , @oLoja  , @cLoja, @oCaso, @cCaso, "CLI",;
                   @oDesGrp, @cDesGrp, @oDesCli, @cDesCli, @oDesCas, @cDesCas)
@author Bruno Ritter
@since 04/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTrgGCLC(oGrupo, cGrupo, oClien, cClien, oLoja, cLoja, oCaso, cCaso, cVal, oDesGrp, cDesGrp, oDesCli, cDesCli, oDesCas, cDesCas, cCpoLanc, lCliPag)
Local cNumCaso     := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local aCliLoj      := {}
Local cLojaAuto    := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cRetGrp      := ""
Local lValid       := .T.
Local cAtuCli      := ""
Local cAtuLoj      := ""
Local cCVarGrp     := Criavar('ACY_GRPVEN', .F. )
Local cCVarCli     := Criavar( 'A1_COD', .F. )
Local cCVarLoj     := Criavar( 'A1_LOJA', .F. )
Local cCVarCas     := Criavar( 'NVE_NUMCAS', .F. )
Local cCVarDCa     := Criavar( 'NVE_TITULO', .F. )

Default oGrupo     := Nil
Default oClien     := Nil
Default oLoja      := Nil
Default oCaso      := Nil
Default oDesGrp    := Nil
Default oDesCli    := Nil
Default oDesCas    := Nil
Default cGrupo     := ""
Default cClien     := ""
Default cLoja      := ""
Default cCaso      := ""
Default cDesGrp    := ""
Default cDesCli    := ""
Default cDesCas    := ""
DeFault cCpoLanc   := ""
Default lCliPag    := .F.

cGrupo := IIF(Empty(oGrupo), "", oGrupo:GetValue() )
cClien := IIF(Empty(oClien), "", oClien:GetValue() )
cLoja  := IIF(Empty(oLoja),  "", oLoja:GetValue()  )
cCaso  := IIF(Empty(oCaso),  "", oCaso:GetValue()  )

If cNumCaso == "1"
	lValid := JurVldCli(cGrupo, cClien, cLoja, cCaso, cCpoLanc, cVal, lCliPag)
EndIf

//---------------------------------------------------------//
//	GRUPO
//---------------------------------------------------------//
If (lValid .And. Upper(cVal) == "GRP" .And. !Empty(oGrupo))

	If (!JurClxGr(cClien, cLoja, cGrupo)) //Se grupo NÃO pertence ao cliente
		If(!Empty(oClien))
			cClien := cCVarCli
			oClien:SetValue(cCVarCli)
		EndIf

		If(!Empty(oLoja))
			cLoja := cCVarLoj
			oLoja:SetValue(cCVarLoj)
		EndIf

		If(!Empty(oCaso))
			cCaso := cCVarCas
			oCaso:SetValue(cCVarCas)
		EndIf
	ElseIf (!Empty(oDesGrp))
		cDesGrp := JurGetDados('ACY', 1, xFilial('ACY') + cGrupo, 'ACY_DESCRI')
		oDesGrp:SetValue(cDesGrp)
	EndIf

//---------------------------------------------------------//
//	CÓDIGO CLIENTE
//---------------------------------------------------------//
ElseIf (lValid .And. Upper(cVal) == "CLI" .And. !Empty(oClien))

	If(!Empty(oLoja))
		If(cLojaAuto == "1" .And. !lCliPag) // Loja automatica
			If( Empty(cClien))
				cLoja := cCVarLoj
				oLoja:SetValue(cCVarLoj)
			Else
				cLoja := JurGetLjAt()
				oLoja:SetValue(JurGetLjAt())
			EndIf

		ElseIf(cLojaAuto == "2")
			If Empty(cClien) .Or. !JurVldCli(cGrupo, cClien, cLoja, cCaso, cCpoLanc, "LOJ", lCliPag, .F.)
				cLoja := cCVarLoj
				oLoja:SetValue(cCVarLoj)
			EndIf

		EndIf

	EndIf
	JurTrgGCLC( @oGrupo , @cGrupo , @oClien , @cClien , @oLoja  , @cLoja, @oCaso, @cCaso, "LOJ",;
	            @oDesGrp, @cDesGrp, @oDesCli, @cDesCli, @oDesCas, @cDesCas, cCpoLanc, lCliPag)

//---------------------------------------------------------//
//	LOJA
//---------------------------------------------------------//
ElseIf ( lValid .And. Upper(cVal) == "LOJ" .And. !Empty(oLoja))

	If (!Empty(oCaso))
		If (Empty(cLoja) .Or. !JurClxCa(cClien, cLoja, cCaso)) //Se caso NÃO pertence ao cliente)
			cCaso := cCVarCas
			oCaso:SetValue(cCVarCas)
			If (!Empty(oDesCas))
				cDesCas := cCVarDCa
				oDesCas:SetValue(cCVarDCa)
			EndIf
		Else //Se caso PERTENCE ao cliente
			JurTrgGCLC( @oGrupo , @cGrupo , @oClien , @cClien , @oLoja  , @cLoja, @oCaso, @cCaso, "CAS",;
			            @oDesGrp, @cDesGrp, @oDesCli, @cDesCli, @oDesCas, @cDesCas, cCpoLanc, lCliPag)
		EndIf
	EndIf

	If (!Empty(oGrupo) .AND. !Empty(cLoja))
		cRetGrp := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_GRPVEN')
		Iif (Empty(cRetGrp), cRetGrp := cCVarGrp, )
		cGrupo := cRetGrp
		oGrupo:SetValue(cRetGrp)
		JurTrgGCLC( @oGrupo , @cGrupo , @oClien , @cClien , @oLoja  , @cLoja, @oCaso, @cCaso, "GRP",;
		            @oDesGrp, @cDesGrp, @oDesCli, @cDesCli, @oDesCas, @cDesCas, cCpoLanc, lCliPag)
	EndIf

	If (!Empty(oDesCli))
		cDesCli := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_NOME')
		oDesCli:SetValue(cDesCli)
	EndIf

//---------------------------------------------------------//
//	CASO
//---------------------------------------------------------//
ElseIf (lValid .And. Upper(cVal) == "CAS" .And. !Empty(oCaso))

	If cNumCaso == "2"
		aCliLoj := JCasoAtual(cCaso)
		If (!Empty(aCliLoj))

			cAtuCli := Iif(Empty(aCliLoj[1][1]), cClien, aCliLoj[1][1])
			cAtuLoj := Iif(Empty(aCliLoj[1][2]), cLoja, aCliLoj[1][2])

			cClien := cAtuCli
			oClien:SetValue( cAtuCli )
			cLoja := cAtuLoj
			oLoja:SetValue( cAtuLoj )
			If oGrupo != Nil
				cRetGrp := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_GRPVEN')
				Iif (Empty(cRetGrp), cRetGrp := cCVarGrp, )
				cGrupo := cRetGrp
				oGrupo:SetValue(cRetGrp)
			EndIf

		EndIf
	EndIf

	If (!Empty(oDesCas))
		cDesCas := Iif(Empty(cCaso), cCVarDCa, JurGetDados('NVE', 1, xFilial('NVE') + cClien + cLoja + cCaso, 'NVE_TITULO'))
		oDesCas:SetValue(cDesCas)
	EndIf
EndIf

If cNumCaso == "2"
	lValid := JurVldCli(cGrupo, cClien, cLoja, cCaso, cCpoLanc, cVal, lCliPag)
EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} JurClxGr(cClien, cLoja, cGrupo)
Rotina para verificar se o cliente/loja pertence ao grupo.
Usada principalmente na condição de gatilhos.

@sample JurClxGr("000000","00","000001")

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurClxGr(cClien, cLoja, cGrupo)
Local lRet     := .F.
Local cRetGrp  := ""

If(!Empty(cClien) .AND. !Empty(cLoja) )
	cRetGrp := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_GRPVEN')
	lRet    := Iif(Empty(cGrupo), Empty(cRetGrp), cGrupo == cRetGrp)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurArrPart(cCampo, nPerc, cTipoOrig)
Função para pré arredondar um percentual de participação.
Utilizado para gatilhos no caso(NUK_PERC) e no cliente(NU9_PERC)
http://tdn.totvs.com/x/5WwtE

@param nPerc     - Pecentual informado pelo usuário.
@param cTipoOrig - Código do tipo de Originação utilizado.
@param cCampo    - Campo de percentual que vai ser arredondado.

@sample JurArrPart("NUK_PERC", 33.33, "001")

@Return - nRet - Valor Arredondado ou o próprio valor.

@author Bruno Ritter
@since 14/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurArrPart(cCampo, nPerc, cTipoOrig)
Local nRet        := nPerc
Local lArredondar := SuperGetMV("MV_JARPART", .F., "2") == '1' //Arredondar participação? 1 - Sim; 2 - Não
Local nTamDecCmp  := TamSX3(cCampo)[02]
Local nSomaOrig   := 0

If (lArredondar)
	nSomaOrig := JurGetDados("NRI", 1, xFilial("NRI") + cTipoOrig, "NRI_SOMAOR")
	If ( nSomaOrig == 100 )
		If nPerc >= 33.33 .And. nPerc <= 33.34
			nRet := Val(PadR( "33.", 3 + nTamDecCmp, "3" ))

		ElseIf nPerc >= 66.66 .And. nPerc <= 66.67
			nRet := Val(PadR( "66.", 3 + nTamDecCmp, "6" ))

		ElseIf nPerc >= 16.66 .And. nPerc <= 16.67
			nRet := Val(PadR( "16.", 3 + nTamDecCmp, "6" ))

		ElseIf nPerc >= 83.33 .And. nPerc <= 83.34
			nRet := Val(PadR( "83.", 3 + nTamDecCmp, "3" ))

		EndIf
	EndIf
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBlqLnc(cClien, cLoja, cCaso, dtLanc, lErro)
Função para identificar a existência de Fatura Adicional faturada cujo período de referência englobe a data do 'dtLanc'
@param cClien   - Código do Cliente
@param cLoja    - Loja do cliente.
@param cCaso    - Caso do lançamento.
@param dtLanc   - Data do Lançamento.
@param cTipo    - Tipo de Lançamento
				  TS  = Time Sheet
				  DEP = Despesa
				  TAB = Lançamento Tabeldo
@param cMsg     - Controle de Mensagem.
				  "0" = Nenhuma Mensagem
				  "1" = Mensagem de Erro
				  "2" = Mensagem de Aviso
@Return - lRet - .T. caso não encontre, e não será bloqueado o lançamento
				   .F. se encontrar, e o lançamento deverá ser bloquado

@author Bruno Ritter
@since 14/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurBlqLnc(cClien, cLoja, cCaso, dDataLC, cTipo, cMsg)
Local lRet      := .T.
Local xRet      := Nil
Local cBloqLan  := SuperGetMV("MV_JBLQLFA ", .F., "1") //Bloquear a manipulação de lançs para casos que possuam fatura de Fat Adic e que a data do lançamento esteja dentro do período de ref.? (1-Sim, 2-Não)
Local cQuery    := ""
Local cQryRes   := GetNextAlias()
Local cSiglaP   := ""
Local aRetDados := JurGetDados("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), {"NUR_REVFAT", "NUR_SOCIO", "NUR_LCPRE"})

Default cMsg    := "1"

xRet := Iif(cMsg == "0", "", lRet)
If cBloqLan == "1" .And. aScan(aRetDados, { |aX| '1' == aX}) == 0

	cQuery := "SELECT COUNT(NVV.R_E_C_N_O_) CONTA FROM " + RetSqlName( 'NVV' ) + " NVV "
	cQuery += " INNER JOIN " + RetSqlName( 'NVW' ) + " NVW "
	cQuery += " ON NVW.NVW_FILIAL = '" + xFilial( "NVV" ) + "' "
	cQuery += " AND NVV.NVV_COD = NVW.NVW_CODFAD "
	cQuery += " AND NVW.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NVV.NVV_SITUAC  = '2' "
	cQuery += " AND NVV.NVV_FILIAL = '" + xFilial( "NVV" ) + "' "
	cQuery += " AND NVV.D_E_L_E_T_ = ' ' "
	cQuery += " AND NVW.NVW_CCLIEN = '" + cClien + "' "
	cQuery += " AND NVW.NVW_CLOJA = '" + cLoja + "' "
	cQuery += " AND NVW.NVW_CCASO = '" + cCaso + "' "

	If Upper(cTipo) == "TS"
		cQuery += " AND NVV.NVV_DTINIH <= '" + DToS(dDataLC) + "' "
		cQuery += " AND NVV.NVV_DTFIMH >= '" + DToS(dDataLC) + "' "

	ElseIf Upper(cTipo) == "DEP"
		cQuery += " AND NVV.NVV_DTINID <= '" + DToS(dDataLC) + "' "
		cQuery += " AND NVV.NVV_DTFIMD >= '" + DToS(dDataLC) + "' "

	ElseIf Upper(cTipo) == "TAB"
		cQuery += " AND NVV.NVV_DTINIT <= '" + DToS(dDataLC) + "' "
		cQuery += " AND NVV.NVV_DTFIMT >= '" + DToS(dDataLC) + "' "
	EndIf

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	lRet   := (cQryRes)->CONTA == 0
	(cQryRes)->(DbCloseArea())

	If !lRet

		cSiglaP := AllTrim(JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__cUserId), "RD0_SIGLA"))

		If cMsg == "1" //Erro
			JurMsgErro(STR0163,;//"O participante não tem permissão para realizar essa operação quando existe Fatura Adicional faturada."
					"JurBlqLnc()",;
					STR0164 +CRLF+; //"Verifique:"
					STR0165 +CRLF+; //"1) O parâmetro MV_JBLQLFA"
					I18N(STR0166, {cClien, cLoja, cCaso, DTOC(dDataLC)}) +CRLF+; //"2) Fatura adicional faturada, para o cliente '#1'/'#2', caso '#3' e a data '#4'."
					I18N(STR0167, {AllTrim(RetTitle("RD0_SIGLA")), cSiglaP}))    //"3) O participante com o campo '#1' = '#2'."
			xRet := .F.
		ElseIf cMsg == "2" //Aviso
			MsgInfo(I18N(STR0168, {cCaso, DTOC(dDataLC)}) +CRLF+CRLF+; //"Alteração com restrição, pois existe fatura adicional faturada para o Caso '#1', e a data deste lançamento '#2' está entre o seu período de referência."
					STR0164 +CRLF+; //"Verifique:"
					STR0165 +CRLF+; //"1) O parâmetro MV_JBLQLFA"
					I18N(STR0166, {cClien, cLoja, cCaso, DTOC(dDataLC)}) +CRLF+; //"2) Fatura adicional faturada, para o cliente '#1'/'#2', caso '#3' e a data '#4'."
					I18N(STR0167, {AllTrim(RetTitle("RD0_SIGLA")), cSiglaP}))    //"3) O participante com o campo '#1' = '#2'."
			xRet := .F.
		ElseIf cMsg == "0" //Sem Mensagem
			xRet := I18N(STR0168, {cCaso, DTOC(dDataLC)}) //"Alteração com restrição, pois existe fatura adicional faturada para o Caso '#1', e a data deste lançamento '#2' está entre o seu período de referência."

		EndIf
	EndIf
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurClearLD()
Limpar os campos referente o Legal Desk

@param oModel , Modelo de dados do lançamento
@param cModel , Id do modelo (Ex. NUEMASTER)
@param cTabela, Tabela do lançamento

@Return aLD   , Valores dos campos LD antes de serem limpos

@author Bruno Ritter
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurClearLD(oModel, cModel, cTabela)
	Local lOk := .T.
	Local aLD  := {}

	aAdd(aLD, {cTabela + "_ACAOLD", oModel:GetValue(cModel, cTabela + "_ACAOLD") })
	aAdd(aLD, {cTabela + "_CCLILD", oModel:GetValue(cModel, cTabela + "_CCLILD") })
	aAdd(aLD, {cTabela + "_CLJLD" , oModel:GetValue(cModel, cTabela + "_CLJLD")  })
	aAdd(aLD, {cTabela + "_CCSLD" , oModel:GetValue(cModel, cTabela + "_CCSLD")  })
	aAdd(aLD, {cTabela + "_PARTLD", oModel:GetValue(cModel, cTabela + "_PARTLD") })
	aAdd(aLD, {cTabela + "_CMOTWO", oModel:GetValue(cModel, cTabela + "_CMOTWO") })
	aAdd(aLD, {cTabela + "_OBSWO" , oModel:GetValue(cModel, cTabela + "_OBSWO")  })

	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_ACAOLD")
	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_CCLILD")
	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_CLJLD")
	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_CCSLD")
	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_PARTLD")
	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_CMOTWO")
	lOk := lOk .And. oModel:ClearField(cModel, cTabela + "_OBSWO")

Return aLD

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCotacD(cMoeda, dData)
Verifica e retorna a cotação diária da moeda (CTP) e data passada no
parâmetro.
Usado no JURA201TestCase.

@Param    cMoeda   Moeda que se deseja saber a cotação
@Param    dData    Data da cotação desejada

@Return   nCotacD   Valor da taxa da moeda no dia informado

@author Cristina Cintra
@since 02/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function GetCotacD(cMoeda, dData)
Local aArea    := GetArea()
Local aAreaCTP := CTP->(GetArea())
Local nCotacD  := 0

Default cMoeda := ""
Default dData  := cToD("")

If !Empty(cMoeda) .And. !Empty(dData)
	DbSelectArea("CTP")
	CTP->(DbSetorder(1))
	If CTP->(DbSeek(xFilial('CTP') + Dtos(dData) + cMoeda)) //CTP_FILIAL+DTOS(CTP_DATA)+CTP_MOEDA
		nCotacD := CTP->CTP_TAXA
	EndIf
EndIf

RestArea( aAreaCTP )
RestArea( aArea )

Return nCotacD

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCotacD(cMoeda, dData, nValor)
Seta a cotação diária da moeda (CTP e SM2) na data e com o valor passados no
parâmetro.
Usado no JURA201TestCase.

@Param    cMoeda    Moeda que se deseja saber a cotação
@Param    dData     Data da cotação desejada
@Param    nValor    Valor a ser setado para a moeda e data
@Param    nValSM2   Valor a ser setado para a moeda e data na tabela SM2

@Return   lRet     .T. se foi possível o set

@author Cristina Cintra
@since 02/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function SetCotacD(cMoeda, dData, nValor, nValSM2)
Local aArea     := GetArea()
Local lRet      := .F.
Local cCampo    := ""

Default cMoeda  := ""
Default dData   := cToD("")
Default nValor  := 0
Default nValSM2 := nValor

If !Empty(cMoeda) .And. !Empty(dData)
	DbSelectArea("CTP")
	CTP->(DbSetorder(1))
	If CTP->(DbSeek(xFilial('CTP') + Dtos(dData) + cMoeda))  //CTP_FILIAL+DTOS(CTP_DATA)+CTP_MOEDA
		Reclock('CTP', .F.)
     Else
        Reclock('CTP', .T.)
		CTP->CTP_FILIAL := xFilial('CTP')
		CTP->CTP_DATA   := dData
		CTP->CTP_MOEDA  := cMoeda
	EndIf
	CTP->CTP_TAXA  := nValor
	CTP->CTP_BLOQ  := "2"
	CTP->(MsUnlock())
	CTP->(DbCommit())
	lRet := .T.

	DbSelectArea("SM2")
	SM2->(DbSetorder(1))
	If SM2->(DbSeek(Dtos(dData)))  // M2_DATA
		Reclock('SM2', .F.)
	Else
		Reclock('SM2', .T.)
		SM2->M2_DATA := dData
	EndIf

	cCampo := "M2_MOEDA" + SubStr(cMoeda, 2, 1)

	SM2->&(cCampo)  := nValSM2
	SM2->M2_INFORM  := "S"
	SM2->(MsUnlock())
	SM2->(DbCommit())

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetCotM
Seta a cotação mensal da moeda conforme parâmetros recebidos

@Param  cMoeda , caractere, Moeda que se deseja saber a cotação
@Param  cAnomes, caractere, Data da cotação desejada
@Param  nTaxa  , numérico , Valor a ser setado para a moeda e data
@Param  lForce , lógico   , Informa se força alteração da taxa caso já existir

@Return lRet   , lógico   , Se .T. a cotação foi gravada

@author Jonatas Martins
@since  17/12/2019
/*/
//-------------------------------------------------------------------
Function JurSetCotM(cMoeda, cAnoMes, nTaxa, lForce)
	Local aAreas    := {GetArea(), CTO->(GetArea()), NXQ->(GetArea())}
	Local oModel    := Nil
	Local oModelNXQ := Nil
	Local cOper     := ""
	Local cLog      := ""
	Local lSetCot   := .F.

	Default cMoeda  := ""
	Default cAnoMes := ""
	Default nValor  := 0
	Default lForce  := .F.

	CTO->(DbSetOrder(1)) // CTO_FILIAL + CTO_MOEDA
	If CTO->(DbSeek(xFilial("CTO") + cMoeda))
		NXQ->(DbSetOrder(1)) // NXQ_FILIAL + NXQ_ANOMES + NXQ_CMOEDA
		If NXQ->(DbSeek(xFilial("NXQ") + cAnoMes + cMoeda))
			cOper := MODEL_OPERATION_UPDATE
		Else
			cOper := MODEL_OPERATION_INSERT
		EndIf

		If cOper == MODEL_OPERATION_INSERT .Or. lForce // Inclusão ou força alteração
			oModel := FWLoadModel("JURA111")
			oModel:SetOperation(cOper)
			oModel:Activate()
			oModelNXQ := oModel:GetModel("NXQMASTER")
			lSetCot   := oModelNXQ:SetValue("NXQ_ANOMES", cAnoMes)
			lSetCot   := lSetCot .And. oModelNXQ:SetValue("NXQ_CMOEDA", cMoeda)
			lSetCot   := lSetCot .And. oModelNXQ:SetValue("NXQ_COTAC" , nTaxa)
			
			If lSetCot .And. oModel:VldData()
				oModel:CommitData()
			Else
				cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[6])
				JurMsgErro(cLog, , STR0292) // "Ajuste as inconsistências."
			EndIf
		EndIf
	Else
		JurMsgErro(I18N(STR0293, {cMoeda}), , STR294) // "Moeda: '#1' inválida!" # "Informe um código de moeda válido."
	EndIf

	AEVal(aAreas, {|aArea| RestArea(aArea)})

Return (lSetCot)

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetPerMoe
Seta o período da moeda.

@Param   cMoeda  , Moeda que se deseja saber a cotação
@Param   dDataIni, Data inicial da moeda
@Param   dDataFim, Data final da moeda
@Param   cFilMoe , Filial da moeda

@Return  lRet    , .T. se foi possível o set

@author  Luciano Pereira
@since   13/02/2019
@obs     Usado no JURA063TestCase.prw
/*/
//-------------------------------------------------------------------
Function JSetPerMoe(cMoeda, dDataIni, dDataFim, cFilMoe)
	Local aArea      := GetArea()
	Local aAreaCTO   := CTO->(GetArea())
	Local aDados     := {CtoD(""), CtoD(""), .F.}

	Default cMoeda   := ""
	Default dDataIni := CtoD("")
	Default dDataFim := CtoD("")
	Default cFilMoe  := xFilial("CTO")

	If !Empty(cMoeda)
		DbSelectArea("CTO")
		CTO->(DbSetorder(1))
		If CTO->(DbSeek(cFilMoe + cMoeda)) // CTO_FILIAL + CTO_MOEDA
			aDados := {CTO->CTO_DTINIC, CTO->CTO_DTFINA, .T.}
			Reclock("CTO", .F.)
			CTO->CTO_DTINIC := dDataIni
			CTO->CTO_DTFINA := dDataFim
			CTO->(MsUnLock())
		EndIf
	EndIf

	RestArea(aAreaCTO)
	RestArea(aArea)

Return (aDados)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3RD0JU
Monta a consulta padrão de participantes do jurídico, independente de
estar bloqueado ou não
Consulta padrão específica RD0JUR

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 04/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3RD0JU()
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := ""
Local aPesq    := {"RD0_SIGLA","RD0_CODIGO","RD0_NOME"}
Local nResult  := 0
Local cFiltro  := ""
Local cTipo    := "1"
Local cSqlBloc := "2"
Local lVisual  := .F. //Indica se a opcao de visualizacao estara presente
Local lInclui  := .F. //Indica se a opcao de incluir estara presente
Local lExibe   := .T. //Indica se os dados
Local cFonte   := "JURA159"

If FWIsInCallStack('JURA201')
	cTipo  := '3' //3 - Sócio ou revisores (observar os campos conforme a opção
	cSqlBloc := cSocAtivo //private da emissão de pré-fatura
	Aadd(aPesq, "RD0_MSBLQL")
EndIf

cQuery := JQRYRD0AT(cTipo, cSqlBloc, .T.)
cQuery := ChangeQuery(cQuery)

RD0->( DbSetOrder( 1 ) )

nResult := JurF3SXB("RD0", aPesq, cFiltro, lVisual, lInclui, cFonte, cQuery, lExibe)

lRet := nResult > 0

If lRet
	DbSelectArea("RD0")
	RD0->(dbgoTo(nResult))
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JCtb030Vld
Validações de preenchimento de campos do cadastro de Centro de Custo (CTBA030)

@param oModel Modelo de Dados

@return lRet

@author Jorge Luis Branco Martins Junior
@version 12.1.17
@since 21/09/17
/*/
//-------------------------------------------------------------------------------------------------------------
Function JCtb030Vld(nOpc)
Local cProblema := ""
Local cSolucao  := ""
Local lRet      := .T.
Local lIntPFS   := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

If CTT->(ColumnPos('CTT_CESCRI')) > 0 // Proteção

	If lIntPFS .And. (M->CTT_CLASSE) == '2' .And. Empty(M->CTT_CESCRI)

		cProblema := I18N(STR0172, {AllTrim(RetTitle('CTT_CESCRI'))}) // "O campo '#1' não foi preenchido."
		cSolucao  := I18N(STR0173, {AllTrim(RetTitle('CTT_CLASSE'))}) // "Quando o campo '#1' estiver preenchido é obrigatório preencher o campo citado acima."

		lRet := JurMsgErro(cProblema,, cSolucao)
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JF3CTTNS7
Monta a consulta padrão de centro de custo com escritórios

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 22/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JF3CTTNS7()
Local cRet    := "@# "
Local cCampo  := ReadVar()
Local cEscrit := JFtCTTNS7(cCampo)
Local lIntPFS := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

If !lIntPFS // Não filtrar a consulta caso a integração esteja desabilitada
	cRet += ".T."
Else
	cRet += " CTT->CTT_BLOQ == '2' .AND. "

	If Empty(cEscrit)
		cRet += " CTT->CTT_CUSTO == ''"
	Else
		cRet += " CTT->CTT_CESCRI == '" + cEscrit + "' "
	EndIf
EndIf

cRet += "@#"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JFtCTTNS7
Indica o escritório que deve ser usado como filtro na consulta de
centro de custo

@param cCampo    Campos de centro de custo que será preenchido

@return cEscrit  Escritório que deveser usado como filtro para centro de custo

@author Jorge Luis Branco Martins Junior
@since 22/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFtCTTNS7(cCampo)
Local cEscrit := ""

Do Case
	Case cCampo == "M->RD0_CC"
		cEscrit := FwFldGet("NUR_CESCR")

	Case cCampo == "M->NUS_CC"
		cEscrit := FwFldGet("NUS_CESCR")

	Case cCampo == "M->NSS_CC"
		cEscrit := FwFldGet("NSS_CESCR")

	Case cCampo == "M->NVM_CC"
		cEscrit := FwFldGet("NVM_CESCR")

	Case cCampo == "M->OH7_CCCUST"
		cEscrit := FwFldGet('OH7_CESCRI')

	Case cCampo == "M->OH8_CCCUST"
		cEscrit := FwFldGet('OH8_CESCRI')

	Case cCampo == "M->OHB_CCUSTO"
		cEscrit := FwFldGet('OHB_CESCRO')

	Case cCampo == "M->OHB_CCUSTD"
		cEscrit := FwFldGet('OHB_CESCRD')

	Case cCampo == "M->OHF_CCUSTO"
		cEscrit := FwFldGet('OHF_CESCR')

	Case cCampo == "M->OHG_CCUSTO"
		cEscrit := FwFldGet('OHG_CESCR')

	Case cCampo == "M->NZQ_GRPJUR"
		// Uso na tela de aprovação de despesa em lote para ser usada como filtro nessa consulta
		If IsInCallStack("JURA235B")
			cEscrit := J235BGetEs()
		ElseIf IsInCallStack("JURA235C")
			cEscrit := J235CGetEs()
		Else
			cEscrit := FwFldGet('NZQ_CESCR')
		EndIf

	Case cCampo == "M->E7_CCUSTO"
		cEscrit := M->E7_CESCR

	Case cCampo == "M->NUE_CC"
		cEscrit := FwFldGet("NUE_CESCR")

	Case cCampo == "M->OHV_CCUSTO"
		cEscrit := FwFldGet("OHV_CESCR")

EndCase

Return cEscrit

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCTTNS7
Validação dos campos de centro de custo com escritórios

@param cEscrit   Campo do escritório indicado como filtro para centro de custo
@param cCCusto   Campo do centro de custo a ser validado
@param lValBloq  Indica se deve ser feita a validação do bloqueio do C.C.
@param lMVC      Indica se a rotina é MVC

@return lRet   .T./.F. As informações são válidas ou não

@sample Vazio().OR.(ExistCpo('CTT', M->NSS_CC, 1).AND.JVldCTTNS7("NSS_CESCR","NSS_CC"))

@author Jorge Luis Branco Martins Junior
@since 22/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldCTTNS7(cEscrit, cCCusto, lValBloq, lMVC)
Local lRet       := .T.
Local aCposCTT   := {}
Local cValEscrit := ""
Local cValCCusto := ""
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local oModel     := FwModelActive()

Default lValBloq := .T.

If ValType(oModel) == "O"
	lMVC := oModel:GetID() != "JURA144"
Else
	lMVC := .F.
EndIf

cValEscrit := IIf(lMVC, FwFldGet(cEscrit), M->&(cEscrit))
cValCCusto := IIf(lMVC, FwFldGet(cCCusto), M->&(cCCusto))

aCposCTT := JurGetDados("CTT", 1, xFilial("CTT") + cValCCusto, {"CTT_BLOQ", "CTT_CLASSE", "CTT_CESCRI"})

If Empty(aCposCTT)
	lRet := JurMsgErro(STR0174,, STR0175) // #"Centro de custo não encontrado." ##"Informe um código de centro de custo válido."
EndIf

If lRet .And. aCposCTT[1] == "1" .And. lValBloq // Bloqueado
	lRet := JurMsgErro(STR0176,, STR0177) // #"Centro de custo inválido." ##"Informe um centro de custo ativo."
EndIf

If lRet .And. aCposCTT[2] == "1" // Sintética
	lRet := JurMsgErro(STR0176,, STR0178) // #"Centro de custo inválido." ##"Informe um centro de custo analítico."
EndIf

If lRet .And. lIntPFS .And. aCposCTT[3] != cValEscrit
	lRet := JurMsgErro(STR0179,,; // #"Centro de custo não pertence ao escritório selecionado."
			i18n(STR0180, {cValEscrit})) // ##"Informe um centro de custo correspondente ao escritório '#1'."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCTTMdl
Validação dos campos de centro de custo com escritórios.
Usado quando valid é feito no modelo via SetProperty

@param cEscrit   Campo de escritório indicado como filtro para centro de custo
@param cCCusto   Valor do campo de centro de custo a ser validado
@param lValBloq  Indica se deve ser feita a validação do bloqueio do C.C.

@return lRet   .T./.F. As informações são válidas ou não

@sample JVldCTTMdl("NSS_CESCR","00001"))

@author Jorge Luis Branco Martins Junior
@since 26/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldCTTMdl(cEscrit, cCCusto, lValBloq)
Local lRet       := .T.
Local aCposCTT   := {}
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local oModel     := FWModelActive()
Local cValEscrit := IIf(!Empty(cEscrit), FwFldGet(cEscrit), "")

Default lValBloq := .T.

aCposCTT := JurGetDados("CTT", 1, xFilial("CTT") + cCCusto, {"CTT_BLOQ", "CTT_CLASSE", "CTT_CESCRI"})

If !Empty(cCCusto)
	If Empty(aCposCTT)
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, "JVldCTTMdl", STR0174, STR0175,, ) // "Centro de custo não encontrado." - "Informe um código de centro de custo válido."
	EndIf

	If lRet .And. aCposCTT[1] == "1" .And. lValBloq // Bloqueado
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, "JVldCTTMdl", STR0176, STR0177,, ) // "Centro de custo inválido." - "Informe um centro de custo ativo."
	EndIf

	If lRet .And. aCposCTT[2] == "1" // Sintética
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, "JVldCTTMdl", STR0176, STR0178,, ) // "Centro de custo inválido." - "Informe um centro de custo analítico."
	EndIf

	If lRet .And. lIntPFS .And. aCposCTT[3] != cValEscrit
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, "JVldCTTMdl", STR0179, ; // "Centro de custo não pertence ao escritório selecionado."
		                                    i18n(STR0180, {cValEscrit}),, ) // "Informe um centro de custo correspondente ao escritório '#1'."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldNCC
Validação dos campos obrigatórios referentes a Natureza x Centro de Custos

@param oModel     => Model para validação
@param cModelId   => Id do model para validação (ex: OHBMASTER)
@param cNatureza  => Nome do campo do Código da Natureza financeira.
@param cEscrit    => Nome do campo do Código do Escritório.
@param cCusto     => Nome do campo do Código do Centro de Custo.
@param cPartCC    => Nome do campo do Código do Participante referente ao centro de custo.
@param cSiglaCC   => Nome do campo da Sigla de participante referente ao centro de custo.
@param cTabRateio => Nome do campo da Tabela de Rateio.
@param cClienDesp => Nome do campo do Código do cliente referente a despesa.
@param cLojaDesp  => Nome do campo da Loja do cliente referente a despesa.
@param cCasoDesp  => Nome do campo do Caso referente a despesa.
@param cTipoDesp  => Nome do campo do Tipo de despesa.
@param cQtdDesp   => Nome do campo da Quantidade de despesas.
@param cDataDesp  => Nome do campo da Data de Despesa
@param cPartDesp  => Nome do campo do Código do Participante referente a Despesa
@param cSiglaDesp => Nome do campo da Sigla de participante referente a Despesa.
@param cProjeto   => Nome do campo de Projeto/Finalidade.
@param cItemProj  => Nome do campo de Item de Projeto/Finalidade.

Centro de Custo Jurídico
1 - Escritório
2 - Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldNCC(oModel, cModelId, cNatureza, cEscrit, cCusto, cPartCC, cSiglaCC, cTabRateio, cClienDesp, cLojaDesp, cCasoDesp, cTipoDesp, cQtdDesp, cCobraDesp, cDataDesp, cPartDesp, cSiglaDesp, cProjeto, cItemProj)
Local lRet          := .T.
Local cSolucErro    := ""
Local cCmpErrObr    := ""
Local cCCNaturez    := ""
Local cTpConta      := ""
Local oModelx       := Nil
Local cValNatureza  := ""
Local cValEscrit    := ""
Local cValCusto     := ""
Local cValPartCC    := ""
Local cValTabRateio := ""
Local cValClienDesp := ""
Local cValLojaDesp  := ""
Local cValCasoDesp  := ""
Local cValTipoDesp  := ""
Local cValQtdDesp   := ""
Local cValCobraDesp := ""
Local dValDataDesp  := CToD("")
Local cValPartDesp  := ""
Local cValProjeto   := ""
Local cValItProj    := ""
Local lUtProj       := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc      := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

Default oModel      := Nil
Default cModelId    := ""
Default cClienDesp  := ""
Default cLojaDesp   := ""
Default cCasoDesp   := ""
Default cTipoDesp   := ""
Default cQtdDesp    := ""
Default cCobraDesp  := ""
Default cDataDesp   := ""
Default cPartDesp   := ""
Default cSiglaDesp  := ""
Default cProjeto    := ""
Default cItemProj   := ""

If Empty(cModelId)

	cValNatureza  := IIf( Empty(cNatureza) , "", M->&(cNatureza)  )
	cValEscrit    := IIf( Empty(cEscrit)   , "", M->&(cEscrit)    )
	cValCusto     := IIf( Empty(cCusto)    , "", M->&(cCusto)     )
	cValPartCC    := IIf( Empty(cPartCC)   , "", M->&(cPartCC)    )
	cValTabRateio := IIf( Empty(cTabRateio), "", M->&(cTabRateio) )
	cValClienDesp := IIf( Empty(cClienDesp), "", M->&(cClienDesp) )
	cValLojaDesp  := IIf( Empty(cLojaDesp) , "", M->&(cLojaDesp)  )
	cValCasoDesp  := IIf( Empty(cCasoDesp) , "", M->&(cCasoDesp)  )
	cValTipoDesp  := IIf( Empty(cTipoDesp) , "", M->&(cTipoDesp)  )
	cValQtdDesp   := IIf( Empty(cQtdDesp)  , "", M->&(cQtdDesp)   )
	cValCobraDesp := IIf( Empty(cCobraDesp), "", M->&(cCobraDesp) )
	dValDataDesp  := IIf( Empty(cDataDesp) , "", M->&(cDataDesp)  )
	cValPartDesp  := IIf( Empty(cPartDesp) , "", M->&(cPartDesp)  )
	If lContOrc .Or. lUtProj
		cValProjeto   := IIf( Empty(cProjeto) , "", M->&(cProjeto)   )
		cValItProj    := IIf( Empty(cItemProj), "", M->&(cItemProj)  )
	EndIf

Else

	oModel        := FWModelActive()
	oModelx       := oModel:GetModel(cModelId)

	cValNatureza  := IIf( Empty(cNatureza) , "", oModelx:GetValue(cNatureza)  )
	cValEscrit    := IIf( Empty(cEscrit)   , "", oModelx:GetValue(cEscrit)    )
	cValCusto     := IIf( Empty(cCusto)    , "", oModelx:GetValue(cCusto)     )
	cValPartCC    := IIf( Empty(cPartCC)   , "", oModelx:GetValue(cPartCC)    )
	cValTabRateio := IIf( Empty(cTabRateio), "", oModelx:GetValue(cTabRateio) )
	cValClienDesp := IIf( Empty(cClienDesp), "", oModelx:GetValue(cClienDesp) )
	cValLojaDesp  := IIf( Empty(cLojaDesp) , "", oModelx:GetValue(cLojaDesp)  )
	cValCasoDesp  := IIf( Empty(cCasoDesp) , "", oModelx:GetValue(cCasoDesp)  )
	cValTipoDesp  := IIf( Empty(cTipoDesp) , "", oModelx:GetValue(cTipoDesp)  )
	cValQtdDesp   := IIf( Empty(cQtdDesp)  , "", oModelx:GetValue(cQtdDesp)   )
	cValCobraDesp := IIf( Empty(cCobraDesp), "", oModelx:GetValue(cCobraDesp) )
	dValDataDesp  := IIf( Empty(cDataDesp) , "", oModelx:GetValue(cDataDesp)  )
	cValPartDesp  := IIf( Empty(cPartDesp) , "", oModelx:GetValue(cPartDesp)  )
	If lContOrc .Or. lUtProj
		cValProjeto   := IIf( Empty(cProjeto) , "", oModelx:GetValue(cProjeto)   )
		cValItProj    := IIf( Empty(cItemProj), "", oModelx:GetValue(cItemProj)  )
	EndIf

EndIf

cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cValNatureza, "ED_CCJURI")
cTpConta   := JurGetDados("SED", 1, xFilial("SED") + cValNatureza, "ED_TPCOJR")

If cTpConta != "1" // 1-Banco/Caixa
	Do Case
		Case cCCNaturez == "1" .Or. cCCNaturez == "2"
			Iif(Empty(cValEscrit), cCmpErrObr += "'" + RetTitle(cEscrit) + "', ", )
			If cCCNaturez == "2"
				Iif(Empty(cValCusto), cCmpErrObr += "'" + RetTitle(cCusto) + "', ", )
			EndIf

		Case cCCNaturez == "3"
			Iif(Empty(cValPartCC)   , cCmpErrObr += "'" + RetTitle(cSiglaCC) + "', ", )

		Case cCCNaturez == "4"
			Iif(Empty(cValTabRateio), cCmpErrObr += "'" + RetTitle(cTabRateio) + "', ", )

		Case cCCNaturez == "5"
			Iif(Empty(cValClienDesp), cCmpErrObr += "'" + RetTitle(cClienDesp) + "', ", )
			Iif(Empty(cValLojaDesp) , cCmpErrObr += "'" + RetTitle(cLojaDesp)  + "', ", )
			Iif(Empty(cValCasoDesp) , cCmpErrObr += "'" + RetTitle(cCasoDesp)  + "', ", )
			Iif(Empty(cValTipoDesp) , cCmpErrObr += "'" + RetTitle(cTipoDesp)  + "', ", )
			Iif(Empty(cValQtdDesp)  , cCmpErrObr += "'" + RetTitle(cQtdDesp)   + "', ", )
			Iif(Empty(cValCobraDesp), cCmpErrObr += "'" + RetTitle(cCobraDesp) + "', ", )
			Iif(Empty(dValDataDesp) , cCmpErrObr += "'" + RetTitle(cDataDesp)  + "', ", )
	End Case
EndIf

If lContOrc .And. cTpConta $ "4|8" // “4-Investimento” ou “8-Despesa"
	Iif(Empty(cValProjeto), cCmpErrObr += "'" + RetTitle(cProjeto) + "', ", )
	Iif(Empty(cValItProj) , cCmpErrObr += "'" + RetTitle(cItemProj) + "', ", )
EndIf

//Campos obrigatórios
If !Empty(cCmpErrObr)
	lRet       := .F.
	cSolucErro := STR0181 + CRLF//"Preencha o(s) campo(s) abaixo:"
	cSolucErro += SubStr(cCmpErrObr, 1, Len(cCmpErrObr) - 2) + "."
EndIf

If !lRet
	JurMsgErro(STR0183,, cSolucErro) //"Existem campos obrigatórios que não foram preenchidos"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurWhNatCC
When dos campos de Natureza Financeira x Contas Contáveis

@param cCampoWhen => Campo para validação do When (
	"1"=Escritorio,
	"2"=Centro de Custo,
	"3"=Código e Sigla do participante do centro de custo,
	"4"=Tabela de Rateio,
	"5"=Campos da despesa:(Cliente, loja, Quantidade, Cobrar, Data),
	"6"=Caso da Despesa)
@param cModelId   => Id do model para validação (ex: OHBMASTER)
@param cNatureza  => Nome do campo do Código da Natureza financeira.
@param cEscrit    => Nome do campo do Código do Escritório.
@param cCusto     => Nome do campo do Código do Centro de Centro de Custo.
@param cSiglaCC   => Nome do campo da Sigla de participante referente ao centro de custo.
@param cTabRateio => Nome do campo da Tabela de Rateio.
@param cClienDesp => Nome do campo do Código do cliente referente a despesa.
@param cLojaDesp  => Nome do campo da Loja do cliente referente a despesa.
@param cCasoDesp  => Nome do campo do Caso referente a despesa.

Centro de Custo JurídicO
1 - Escritório
2 - Escritório e Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurWhNatCC(cCampoWhen, cModelId, cNatureza, cEscrit, cCusto, cSiglaCC, cTabRateio, cClienDesp, cLojaDesp, cCasoDesp)
Local lRet          := .T.
Local oModel        := Nil
Local oModelx       := Nil
Local cCCNaturez    := ""
Local cValNatureza  := ""
Local cValEscrit    := ""
Local cValCusto     := ""
Local cValSiglaCC   := ""
Local cValTabRateio := ""
Local cValClienDesp := ""
Local cValLojaDesp  := ""
Local cValCasoDesp  := ""
Local cTpConta      := ""

Default cCampoWhen := ""
Default cModelId   := ""
Default cNatureza  := ""
Default cEscrit    := ""
Default cCusto     := ""
Default cSiglaCC   := ""
Default cTabRateio := ""
Default cClienDesp := ""
Default cLojaDesp  := ""
Default cCasoDesp  := ""

If Empty(cModelId)

	cValNatureza  := IIf( Empty(cNatureza) , "", M->&(cNatureza)  )
	cValEscrit    := IIf( Empty(cEscrit)   , "", M->&(cEscrit)    )
	cValCusto     := IIf( Empty(cCusto)    , "", M->&(cCusto)     )
	cValSiglaCC   := IIf( Empty(cSiglaCC)  , "", M->&(cSiglaCC)   )
	cValTabRateio := IIf( Empty(cTabRateio), "", M->&(cTabRateio) )
	cValClienDesp := IIf( Empty(cClienDesp), "", M->&(cClienDesp) )
	cValLojaDesp  := IIf( Empty(cLojaDesp) , "", M->&(cLojaDesp)  )
	cValCasoDesp  := IIf( Empty(cCasoDesp) , "", M->&(cCasoDesp)  )

Else

	oModel        := FWModelActive()
	oModelx       := oModel:GetModel(cModelId)

	cValNatureza  := IIf( Empty(cNatureza) , "", oModelx:GetValue(cNatureza)  )
	cValEscrit    := IIf( Empty(cEscrit)   , "", oModelx:GetValue(cEscrit)    )
	cValCusto     := IIf( Empty(cCusto)    , "", oModelx:GetValue(cCusto)     )
	cValSiglaCC   := IIf( Empty(cSiglaCC)  , "", oModelx:GetValue(cSiglaCC)   )
	cValTabRateio := IIf( Empty(cTabRateio), "", oModelx:GetValue(cTabRateio) )
	cValClienDesp := IIf( Empty(cClienDesp), "", oModelx:GetValue(cClienDesp) )
	cValLojaDesp  := IIf( Empty(cLojaDesp) , "", oModelx:GetValue(cLojaDesp)  )
	cValCasoDesp  := IIf( Empty(cCasoDesp) , "", oModelx:GetValue(cCasoDesp)  )

EndIf

cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cValNatureza, "ED_CCJURI")
cTpConta   := JurGetDados("SED", 1, xFilial("SED") + cValNatureza, "ED_TPCOJR")

Do Case
	Case cCampoWhen == "1" //Código Escritorio
		If (lRet := !Empty(cValNatureza) .And. cTpConta != "1") // 1-Banco/Caixa
			// Tipo de Natureza == Escritório OU Escritório e Grupo Jurídico OU sem definição E os outros campos estão vazios
			lRet := cCCNaturez == "1" .Or. cCCNaturez == "2" .Or. (Empty(cCCNaturez) .And. Empty(cValSiglaCC);
			                                                                         .And. Empty(cValTabRateio))
		EndIf

	Case cCampoWhen == "2" // Código de Centro de Custo
		If (lRet := !Empty(cValNatureza) .And. cTpConta != "1") // 1-Banco/Caixa
			// Tipo de Natureza == Escritório e Grupo Jurídico OU sem definição E os outros campos estão vazios
			lRet := ( ( cCCNaturez == "2" .And. !Empty(cValEscrit) ) .Or. (Empty(cCCNaturez) .And. !Empty(cValEscrit);
			                                                                                 .And. Empty(cValSiglaCC);
			                                                                                 .And. Empty(cValTabRateio)) )
		EndIf

	Case cCampoWhen == "3" // Código e Sigla do participante do centro de custo
		If (lRet := !Empty(cValNatureza) .And. cTpConta != "1") // 1-Banco/Caixa
			// Tipo de Natureza == Profissional OU sem definição E os outros campos estão vazios
			lRet := cCCNaturez == "3" .Or. (Empty(cCCNaturez) .And. Empty(cValCusto);
			                                                  .And. Empty(cValEscrit);
			                                                  .And. Empty(cValTabRateio))
		EndIf

	Case cCampoWhen == "4" // Tabela de Rateio
		If (lRet := !Empty(cValNatureza) .And. cTpConta != "1") // 1-Banco/Caixa
			// Tipo de Natureza == Tabela de Rateio OU sem definição E os outros campos estão vazios
			lRet := cCCNaturez == "4" .Or. (Empty(cCCNaturez) .And. Empty(cValCusto);
			                                                  .And. Empty(cValSiglaCC);
			                                                  .And. Empty(cValEscrit))
		EndIf

	Case cCampoWhen $ "5|6" // Campos da despesa: (Cliente, loja, caso, tipo despesa, qtd despesa, cobrar despesa, data despesa)

		If (lRet :=  cCCNaturez == "5") // Tipo de Natureza == Cliente Despesa
			If cCampoWhen == "6" // Caso da despesa
				cJcaso   := SuperGetMv( "MV_JCASO1", .F., "1",  ) // 1 – Por Cliente; 2 – Independente de cliente
				If cJcaso == "1"
					lRet := lRet .And. !Empty(cValClienDesp) .And. !Empty(cValLojaDesp) // Código do cliente e loja preenchidas
				EndIf
			EndIf
		EndIf

	OtherWise
		lRet := .F.
End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVlTpDp()
Validação do campo para o tipo de despesa.

@param cCodDsp  Código de tipo de despesa a ser validado.
@param lValBlq  .T. Valida o tipo de despesa esta ativo.

@author bruno.ritter
@since 05/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVlTpDp(cCodDsp, lValBlq)
Local lRet      := .T.

Default lValBlq := .T.

	NRH->(dbSetOrder(1)) //NRH_FILIAL+NRH_COD
	If !NRH->(dbSeek(xFilial("NRH") + cCodDsp))
		lRet := JurMsgErro(STR0191,, STR0193)//"Código do Tipo de Despesa inválido" ##"Informe um código válido"

	Else
		If NRH->NRH_ATIVO != "1" .And. lValBlq
			lRet := JurMsgErro(STR0192,, STR0193)//"Código do Tipo de Despesa inativo" ##"Informe um código válido"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldPro
Rotina de dicionário para validar o código projeto, considerando
se bloqueia se for diferente de determinada situação.

@author Luciano Pereira dos Santos
@since   11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldProj(cProjeto, cSituac, lValBlq)
	Local lRet      := .T.
	Local cSitProj  := JurGetDados("OHL", 1, xFilial("NS7") + cProjeto, {"OHL_SITUAC"})

	Default cSituac := "2"
	Default lValBlq := .T.

	If Empty(cSitProj)
		lRet := JurMsgErro(STR0266, , STR0267) //#"O código do projeto não é válido." ##  "Selecione um código de projeto válido."
	EndIf

	If lRet .And. cSitProj != cSituac .And. lValBlq //1=Pendente;2=Aprovado;3=Bloqueado;4=Cancelado
		lRet := JurMsgErro(I18n(STR0268, {JurInfBox("OHL_SITUAC", cSitProj, "3")}) , , ; //# "A situação do projeto selecionado se encontra em '#1'."
		           I18n(STR0269, {JurInfBox("OHL_SITUAC", cSituac , "3")}) ) //## "Selecione um código de projeto com situação '#1'."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVlDtDp
Validação de campos Data para que não seja permitida data futura.
Usado nos campos OHF_DTDESP e OHB_DTDESP.

@author Cristina Cintra
@since 09/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVlDtDp(dData)
Local lRet := .T.

If !Empty(dData)
	lRet := (dData <= Date())
	If !lRet
		JurMsgErro(STR0186,, STR0187) //"Não é permitido o preenchimento com data futura." "Utilize uma data válida."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCCPart
Função para buscar o escritório e centro de custo do participante em
seu cadastro (RD0 e NUR).

@param  cPart   Código do Participante a ser usado na busca.

@return aRet    Array com escritório e centro de custo.

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCCPart(cPart)
Local aRet  := {'', ''}
Local oModelAct := FwModelActive()
Local cModelId  := oModelAct:GetId()

If !Empty(cPart) .And. cModelId $ "JURA235|JURA235A"
	aRet[1] := JurGetDados('NUR', 1, xFilial('NUR') + cPart, 'NUR_CESCR')
	aRet[2] := JurGetDados('RD0', 1, xFilial('RD0') + cPart, 'RD0_CC')
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGrModel()
Gera um modelo pronto para o commit.

@param cFonte         => Fonte para gerar o modelo
@param nOper          => Operação a ser executada

@param aSeek          => Array com os dados para o Seek no caso da operação de UPDATE e DELETE
       aSeek[1]       => [cTab]   Tabela (ex: SE2)
       aSeek[2]       => [nOrder] Indice para ser usado (ex: 1)
       aSeek[3]       => [cChave] Chave para busca com o indice (ex: xFilial("SE2")+cChave)

@param aSetFields              => Array com os campos/valores para realizar uma atribuição
       aSetFields[n][1]        => [cIdModel]  Codigo do submodelo do Modelo que terá uma atribuição (Ex: OHFDETAIL)
       aSetFields[n][2]        => [aSeekLine] Array com os dados de busca na seguinte estrutura (ex: { {"OHF_CITEM",cItemDesdobramento)} })
       aSetFields[n][2][n][1]  =>             cIdCampo Codigo/Nome do atributo da folha de dados (ex: "OHF_CITEM")
       aSetFields[n][2][n][2]  =>             xValue Valor a ser buscado (ex: "0001")
       aSetFields[n][3]        => [aSetValue] Array com os campos/valores para atribuição
       aSetFields[n][3][n][1]  => [cIdCampo]  Codigo/Nome do atributo da folha de dados (Ex: OHF_CCLIEN)
       aSetFields[n][3][n][2]  => [xValue]    Valor a ser atribuido (ex: "PFS001")
       aSetFields[n][4]        => [lItem]     Indica se deve ser preenchido o campo CITEM - usado para a OHF e OHG
       aSetFields[n][5]        => [cItem]     Código do item para SetValue nos campos de AutoIncremento

@param aErro        => Passar como referência se for necessário receber o erro em uma variável
@param lExibeErro   => Indica se as mensagens de erro devem ser exibidas.
                       (Controle usado como .F. para execuções em lote que não podem exibir mensagem a cada registro)

@Return oModel  => Model pronto para o commit

@Sample
	Inclusão (Field)  - JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}   , {"OHBMASTER", {}                                , aSetValue} )
	Inclusão (Grid)   - JurGrModel("JURA246", MODEL_OPERATION_UPDATE, {}   , {"OHFDETAIL", { {"OHF_CITEM", NZQ->NZQ_ITDES } }, aSetValue, lItem, cItem} )

	Alteração (Field) - JurGrModel("JURA241", MODEL_OPERATION_UPDATE, aSeek, {"OHBMASTER", {}                                , aSetValue} )
	Alteração (Grid)  - JurGrModel("JURA246", MODEL_OPERATION_UPDATE, aSeek, {"OHFDETAIL", { {"OHF_CITEM", NZQ->NZQ_ITDES } }, aSetValue, lItem, cItem} )

	Exclusão (Field)  - JurGrModel("JURA241", MODEL_OPERATION_DELETE, aSeek)
	Exclusão (Grid)   - JurGrModel("JURA246", MODEL_OPERATION_UPDATE, aSeek, {"OHFDETAIL", { {"OHF_CITEM", NZQ->NZQ_ITDES } }, {}       , .F., "" } )

@author bruno.ritter
@since 19/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGrModel(cFonte, nOper, aSeek, aSetFields, aErro, lExibeErro, lSetValue)
Local aArea        := GetArea()
Local oModel       := Nil
Local lSeekOk      := .T.
Local cTab         := ""
Local nOrder       := 0
Local cChave       := ""

Default aSeek      := {}
Default aSetFields := {}
Default aErro      := {}
Default lExibeErro := .T.
Default lSetValue  := .T.

	//Posiciona no registro antes de ativar o model para operações de update e delete
	If (nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE) .And. !Empty(aSeek)
		cTab    := aSeek[1]
		nOrder  := aSeek[2]
		cChave  := aSeek[3]

		(cTab)->(DbSetOrder(nOrder))

		If !((cTab)->(DbSeek(cChave)))
			lSeekOk := .F.
			If lExibeErro
				JurMsgErro(i18n(STR0190, {cTab}))//"Erro ao pesquisar o registro relacionado para a tabela '#1'."
			EndIf
		EndIf
	EndIf

	//Inicia o Modelo para insert OU quando o seek do registro foi bem sucedido para as outras operações
	If nOper == MODEL_OPERATION_INSERT .Or. lSeekOk
		oModel     := FWLoadModel(cFonte)
		oModel:SetOperation(nOper)
		cDescModel := oModel:GetDescription()

		If lModelAct := oModel:CanActivate()
			oModel:Activate()
		Else
			aErro := oModel:GetErrorMessage()
			If lExibeErro
				JurMsgErro(i18n(STR0188, {cDescModel}),, aErro[7]) //"Erro ao atualizar os dados referete ao '#1':"
			EndIf
			oModel := Nil
		EndIf

		If lModelAct .And. (nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE)
			oModel := JSetVlMdl(oModel, aSetFields, lExibeErro, @aErro, lSetValue)
		EndIf
	EndIf

	If !Empty(oModel) .And. !oModel:VldData()
		aErro := oModel:GetErrorMessage()
		If lExibeErro
			JurMsgErro(i18n(STR0188, {cDescModel}),, aErro[7]) //"Erro ao atualizar os dados referentes ao '#1':"
		EndIf
		oModel := Nil
	EndIf

	RestArea(aArea)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetVlMdl
Função para para percorrer as diferentes folhas de dados
       e ou linhas de um Grid para a função JurGrModel()

@param oModel, objeto, Objeto do modelo
@param aSetFields              => Array com os campos/valores para realizar uma atribuição
       aSetFields[n][1]        => [cIdModel]  Codigo do submodelo do Modelo que terá uma atribuição (Ex: OHFDETAIL)
       aSetFields[n][2]        => [aSeekLine] Array com os dados de busca na seguinte estrutura (ex: { {"OHF_CITEM",cItemDesdobramento)} })
       aSetFields[n][2][n][1]  =>             cIdCampo Codigo/Nome do atributo da folha de dados (ex: "OHF_CITEM")
       aSetFields[n][2][n][2]  =>             xValue Valor a ser buscado (ex: "0001")
       aSetFields[n][3]        => [aSetValue] Array com os campos/valores para atribuição
       aSetFields[n][3][n][1]  => [cIdCampo]  Codigo/Nome do atributo da folha de dados (Ex: OHF_CCLIEN)
       aSetFields[n][3][n][2]  => [xValue]    Valor a ser atribuido (ex: "PFS001")
       aSetFields[n][4]        => [lItem]     Indica se deve ser preenchido o campo CITEM - usado para a OHF e OHG
       aSetFields[n][5]        => [cItem]     Código do item para SetValue nos campos de AutoIncremento
@param lExibeErro, lógico, Se deve exibir mensagem para usuário
@param aErro     , array, Passar como referência se for necessário receber o erro em uma variável

@Return oModel, objeto, Retorna o modelo já setado.

@author Bruno Ritter
@since 05/07/2019
/*/
//-------------------------------------------------------------------
Static Function JSetVlMdl(oModel, aSetFields, lExibeErro, aErro, lSetValue)
	Local nQtdModel  := Len(aSetFields)
	Local nModel     := 1
	Local nOperLine  := 0
	Local nTamItem   := 0
	Local nQtdField  := 0
	Local nField     := 0
	Local cIdModel   := ""
	Local cItem      := ""
	Local cIdCampo   := ""
	Local lSetVlOk   := .T.
	Local aSeekLine  := {}
	Local aSetValue  := {}
	Local aChildMdl  := {}
	Local oModelGrid := Nil
	Local xValue     := Nil
	Local xValModel  := Nil
	Local lDifVal    := .T.

	Default lSetValue := .T.

	For nModel := 1 To nQtdModel
		cIdModel  := aSetFields[nModel][1]
		aSeekLine := aSetFields[nModel][2]
		aSetValue := aSetFields[nModel][3]
		aChildMdl := Iif(Len(aSetFields[nModel]) >= 6, aSetFields[nModel][6], {})

		//Tratamento quando o idModel é um grid, para adicionar uma para inclusão ou pesquisar linha para update/delete
		If oModel:GetModelStruct(cIdModel)[1] == "GRID"
			oModelGrid := oModel:GetModel(cIdModel)

			If Empty(aSeekLine) //Se não tem o array para o seekline, é pq é um novo registro na grid
				nOperLine := MODEL_OPERATION_INSERT

				If !oModelGrid:IsEmpty()
					oModelGrid:AddLine()
				EndIf

				If aSetFields[nModel][4] // Indica se deve ser preenchido o campo CITEM - usado para a OHF e OHG
					nTamItem := TamSX3(Substr(cIdModel, 1, 3) + "_CITEM")[1]

					If Empty(cItem) .And. (Len(aSetFields[nModel]) < 5 .Or. Empty(Alltrim(aSetFields[nModel][5])))
						cItem := StrZero(1, nTamItem)
					ElseIf Empty(cItem)
						cItem := Strzero((Val(aSetFields[nModel][5]) + 1), nTamItem)
					Else
						cItem := StrZero((Val(cItem) + 1), nTamItem)
					EndIf

					oModel:LoadValue(cIdModel, Substr(cIdModel, 1, 3) + "_CITEM", cItem) // Preenche o campo de Código do item na grid
				EndIf

			Else //Existe um SeekLine
				If oModelGrid:SeekLine(aSeekLine)
					If Empty(aSetValue) //Se está vazio os campos para atribuição de valores no registro, é pq é uma exclusão de registro
						nOperLine := MODEL_OPERATION_DELETE
						oModelGrid:DeleteLine()
					Else
						nOperLine := MODEL_OPERATION_UPDATE
					EndIf
				Else
					aErro := oModel:GetErrorMessage()
					If lExibeErro
						JurMsgErro(i18n(STR0189, {cIdModel}),, aErro[7])//"Erro ao pesquisar o registro relacionado para o modelo '#1'."
					EndIf
					oModel    := Nil
					Exit
				EndIf
			EndIf
		EndIf

		//Atribui os valores.
		If oModel:GetModelStruct(cIdModel)[1] == "FIELD" .Or. nOperLine == MODEL_OPERATION_INSERT .Or. nOperLine == MODEL_OPERATION_UPDATE
			nQtdField := Len(aSetValue)
			For nField := 1 To nQtdField
				cIdCampo  := aSetValue[nField][1]
				xValue    := aSetValue[nField][2]
				xValModel := oModel:GetValue(cIdModel, cIdCampo)
				lDifVal   := !(AllTrim(cValToChar(xValue)) == AllTrim(cValToChar(xValModel)))

				If lSetVlOk .And. oModel:CanSetValue(cIdModel, cIdCampo) .And. lDifVal
					If lSetValue .OR. Len(aSetValue[nField]) <= 2 .or. !aSetValue[nField][3]
						lSetVlOk := oModel:SetValue(cIdModel, cIdCampo, xValue)
					Else
						lSetVlOk := oModel:LoadValue(cIdModel, cIdCampo, xValue)
					EndIf
				EndIf
			Next nField

			If !lSetVlOk .Or. (oModel:GetModelStruct(cIdModel)[1] == "GRID" .And. !oModelGrid:VldLineData())
				aErro := oModel:GetErrorMessage()
				If lExibeErro
					JurMsgErro(i18n(STR0188, {oModel:GetDescription()}),, aErro[7]) //"Erro ao atualizar os dados referentes ao '#1':"
				EndIf
				oModel := Nil
				Exit
			EndIf
		EndIf

		// Preeche os valores dos modelos filhos
		If !Empty(aChildMdl)
			oModel := JSetVlMdl(oModel, aChildMdl, lExibeErro, aErro, lSetValue)
			If oModel == Nil
				Exit
			EndIf
		EndIf

	Next nModel

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetItem
Função para buscar o maior Código de Item das tabelas de Desdobramentos.
Usado na JURA235A para as tabelas OHF e OHG, visto que o AddIncrementField
só funciona pela view.

@param  cTab      Tabela para busca do maior CITEM
@param  cFilTab   Filial para busca
@param  cCampo    Campo de item para busca do Max
@param  cChave    Chave para busca na tabela

@return cItem     Código do maior item.

@author Cristina Cintra
@since 20/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetItem(cTab, cFilTab, cCampo, cChave)
Local cItem  := ""
Local cSQL   := ""
Local aSQL   := {}

cSQL := "SELECT MAX(" + cCampo + ") CITEM FROM " + RetSqlname(cTab)
cSQL +=  " WHERE " + cTab + "_FILIAL = '" + cFilTab + "' AND D_E_L_E_T_ = ' ' "
cSQL +=    " AND " + cTab + "_IDDOC = '" + cChave + "' "

aSql := JurSQL(cSQL, "CITEM")

If !Empty(aSQL)
	cItem := aSQL[1][1]
EndIf

Return cItem

//-------------------------------------------------------------------
/*/{Protheus.doc} JACasMae
Função para buscar o Cliente, Loja e Caso Mãe de acordo com o tipo de
lançamento informado.

@param  nTipo     Tipo de Lançamento: 1-TimeSheet, 2-Despesa, 3-Tabelado
@param  cCliente  Cliente do Lançamento
@param  cLoja     Loja do Lançamento
@param  cCaso     Caso do Lançamento

@return aCasoMae  Cliente, Loja e Caso Mãe

@author Cristina Cintra
@since 17/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JACasMae(nTipo, cCliente, cLoja, cCaso)
Local cSQL     := ""
Local aCasoMae := {}

If NT0->(ColumnPos("NT0_CCLICM")) > 0 // Proteção

	cSQL := " SELECT NT0.NT0_CCLICM, NT0.NT0_CLOJCM, NT0.NT0_CCASCM "
	cSQL += " FROM " + RetSqlName('NUT') + " NUT, "
	cSQL +=      " " + RetSqlName('NT0') + " NT0 "
	If nTipo == 1
		cSQL +=  ", " + RetSqlName('NRA') + " NRA "
	EndIf
	cSQL +=      " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cSQL +=        " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	If nTipo == 1
		cSQL +=    " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	EndIf
	cSQL +=        " AND NUT.NUT_CCLIEN = '" + cCliente + "' "
	cSQL +=        " AND NUT.NUT_CLOJA = '"  + cLoja + "' "
	cSQL +=        " AND NUT.NUT_CCASO = '"  + cCaso + "' "
	cSQL +=        " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	If nTipo == 2
		cSQL +=    " AND NT0.NT0_DESPES = '1' "
	ElseIf nTipo == 3
		cSQL +=    " AND NT0.NT0_SERTAB = '1' "
	Else
		cSQL +=    " AND NRA.NRA_COD = NT0.NT0_CTPHON "
		cSQL +=    " AND NRA.NRA_COBRAH = '1' "
	EndIf
	cSQL +=        " AND NT0.D_E_L_E_T_ = ' ' "
	cSQL +=        " AND NUT.D_E_L_E_T_ = ' ' "
	If nTipo == 1
		cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' "
	EndIf

	aCasoMae := JURSQL(cSQL, {"NT0_CCLICM", "NT0_CLOJCM", "NT0_CCASCM"})

EndIf

Return aCasoMae

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPartHst(cPart, dDate, xCampo )
Função semelhante ao JurGetDados, mas é especifica para buscar os dados do participante no histórico do próprio

@param  cPart     Código do Participante
@param  dDate     Data de refência para buscar no histórico
@param  xCampos   Campo(s) para a busca

@return xRet      Retorna os valores do(s) campo(s) informados no parâmetro xCampo
                  o tipo do retorno é conforme o tipo passado no parâmetro xCampo

@author Bruno Ritter
@since 01/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurPartHst(cPart, dDate, xCampo)
Local xRet      := Nil
Local aCampos   := {}
Local cAnoMes   := AnoMes(dDate)
Local lRetArray := ValType(xCampo) == "A"
Local cQuery    := ""
Local aSql      := {}
Local nI        := 0
Local nQtdCpos  := 0

If lRetArray
	aCampos := aClone(xCampo)
	xRet    := {}
Else
	aAdd(aCampos, xCampo)
EndIf

cQuery := " SELECT " + AtoC(aCampos, ", ")
cQuery += " FROM " + RetSqlName( "NUS" ) + " NUS "
cQuery +=        " WHERE NUS_FILIAL = '" + xFilial( "NUS" ) + "' "
cQuery +=        " AND NUS.NUS_CPART = '" + cPart + "' "
cQuery +=        " AND NUS.NUS_AMINI <= '" + cAnoMes + "' "
cQuery +=        " AND (NUS.NUS_AMFIM >= '" + cAnoMes + "' OR NUS.NUS_AMFIM = '" + CriaVar("NUS_AMFIM", .F.) + "') "
cQuery +=        " AND NUS.D_E_L_E_T_ = ' '"

aSQL := JurSQL(cQuery, aCampos)

If !Empty(aSQL)
	nQtdCpos  := Len(aCampos)

	If nQtdCpos == 1
		xRet := aSQL[1][1]
	Else
		For nI := 1 To nQtdCpos
		  aAdd(xRet, aSQL[1][nI])
		Next
	EndIf
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLogMsg()
Função para padronizar a geração de mensagens (Antigo Conout)

@param  cMsg      Conteúdo da mensagem
@param  cLevel    Indica severidade da mensagem ("INFO", "WARN", "ERROR", "FATAL", "DEBUG").
@param  cModulo   Módulo do sistema jurídico ("SIGAPFS","SIGAJURI")

@Obs    Necessário ativar a chave FWTRACELOG=1 no arquivo appserver.ini

@author Abner Fogaça de Oliveira
@since 22/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLogMsg(cMsg, cLevel, cModulo)
Default cLevel  := "INFO"
Default cMsg    := ""
Default cModulo := "SIGAPFS"

cLevel := PadR(Upper(cLevel), 7)

FWLogMsg(cLevel, "LAST", cModulo, ProcName(2), , "01", cMsg, , , {}, 2)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDspTrib()
Verifica se a despesa é tributavel

@param  cTpDesp Código do tipo de despesa a ser verificado
@param  cEscrit Código do escritório a ser verificado

@author Bruno Ritter / Cris Cintra / Jorge Martins
@since 16/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDspTrib(cTpDesp, cEscrit)
Local lTrib     := .F.
Local cTipoCob  := ""
Local lDespTrib := .F.

Default cEscrit := JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD")

lDespTrib := FWAliasInDic("OHJ") .And. NRH->(ColumnPos('NRH_CTPCB')) > 0

If lDespTrib
	cTipoCob := JurGetDados('OHJ', 1, xFilial('OHJ') + cEscrit + cTpDesp, "OHJ_TPCOB") //OHJ_FILIAL+OHJ_COD+OHJ_CTPDP

	If Empty(cTipoCob)
		cTipoCob := JurGetDados('NRH', 1, xFilial('NRH') + cTpDesp, "NRH_CTPCB") //NRH_FILIAL+NRH_COD
	EndIf

	lTrib := cTipoCob == "2"
EndIf

Return lTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTxTrib()
Retorna o do Gross Up e a taxa administrativa das despesas tributáveis.

@param nVlDpTrib, Valor Total de despesas tributáveis
@param cEscrit,   Código do escritório
@param cFatura,   Código da Fatura

@Return aVlTaxas[1], Valor Gross Up
@Return aVlTaxas[2], Valor Taxa Adm

@author Bruno Ritter / Cris Cintra / Jorge Martins
@since 16/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTxTrib(nVlDpTrib, cEscrit, cFatura)
Local aVlTaxas   := {0,0}
Local aRetTaxas  := {}
Local aRetTxCli  := {}
Local aRetNXA    := {}
Local cPrefat    := ""
Local cJuncao    := ""
Local cContrato  := ""
Local cClientePg := ""
Local cLojaPg    := ""
Local cFatAdc    := ""
Local cFixo      := 0
Local nGrossUp   := 0
Local nTxAdm     := 0

If !Empty(cFatura) ;
	.And. NXG->(ColumnPos('NXG_GROSUP')) > 0 .And. NXG->(ColumnPos('NXG_TXADM')) > 0 ; // Proteção
	.And. NXP->(ColumnPos('NXP_GROSUP')) > 0 .And. NXP->(ColumnPos('NXP_TXADM')) > 0 ; // Proteção
	.And. NUH->(ColumnPos('NUH_GROSUP')) > 0 .And. NUH->(ColumnPos('NUH_TXADM')) > 0   // Proteção

	aRetNXA := JurGetDados("NXA", 1, xFilial("NXA") + cEscrit + cFatura, {"NXA_CPREFT", "NXA_CFTADC", "NXA_CJCONT", "NXA_CCONTR", "NXA_CLIPG", "NXA_LOJPG", "NXA_CFIXO"})

	cPrefat    := aRetNXA[1]
	cFatAdc    := aRetNXA[2]
	cJuncao    := aRetNXA[3]
	cContrato  := aRetNXA[4]
	cClientePg := aRetNXA[5]
	cLojaPg    := aRetNXA[6]
	cFixo      := aRetNXA[7]

	If Empty(cJuncao) .And. !Empty(cFixo)
		cJuncao := JurGetDados("NW3", 2, xFilial("NW3") + cContrato, "NW3_CJCONT")
	EndIf

	aRetTxCli := JurGetDados("NUH", 1, xFilial("NUH") + cClientePg + cLojaPg, {"NUH_GROSUP", "NUH_TXADM"}) //Verifica o gross-up e Taxa do cliente

	Do Case //Verifica se houve alteração no processo de emissão
		Case !Empty(cPrefat)
			aRetTaxas := JurGetDados("NXG", 2, xFilial("NXG") + cPrefat + cClientePg + cLojaPg, {"NXG_GROSUP", "NXG_TXADM"})

		Case !Empty(cFatAdc)
			aRetTaxas := JurGetDados("NXG", 2, xFilial("NXG") + CriaVar("NXG_CPREFT", .F.) + cClientePg + cLojaPg + cFatAdc, {"NXG_GROSUP", "NXG_TXADM"})

		Case !Empty(cJuncao)
			aRetTaxas := JurGetDados("NXP", 1, xFilial("NXP") + cJuncao + cClientePg + cLojaPg, {"NXP_GROSUP", "NXP_TXADM"})

		Case !Empty(cContrato)
			aRetTaxas := JurGetDados("NXP", 2, xFilial("NXP") + cContrato + cClientePg + cLojaPg, {"NXP_GROSUP", "NXP_TXADM"})
	End Case

	If Len(aRetTaxas) > 0 .And. Len(aRetTxCli) > 0 //Aplica o Gross-up e Taxa do cliente caso não houver alteração no processo de emissão
		aRetTaxas[1] := Iif(aRetTaxas[1] == 0, aRetTxCli[1], aRetTaxas[1])
		aRetTaxas[2] := Iif(aRetTaxas[2] == 0, aRetTxCli[2], aRetTaxas[2])
	Else
		aRetTaxas := {0, 0}
	EndIf

	nGrossUp := Iif(aRetTaxas[1] == 0, 0, aRetTaxas[1] / 100)
	nTxAdm   := Iif(aRetTaxas[2] == 0, 0, aRetTaxas[2] / 100)

	aVlTaxas[1] := nVlDpTrib * nGrossUp
	aVlTaxas[2] := nVlDpTrib * nTxAdm

EndIf

Return aVlTaxas

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRelFilia
Verifica o compartilhamento do relacionamento de duas tabelas e retorna uma
expressão para relacionar a filial

@param  cCampoRel   , Campo da Tabela que está sendo incluinda no relacionamento da query
@param  cCampoQry   , Campo que já está na query

@author Bruno Ritter
@since  04/04/2018
/*/
//-------------------------------------------------------------------
Function JurRelFilia(cCampoRel, cCampoQry)
Local cFilQry   := ""
Local cTabRel   := ""
Local cTabCpo   := ""
Local cFilRel   := ""
Local cFilCpo   := ""

//Remove o texto do ponto para traz
cTabRel   := SubStr(cCampoRel, At(".", cCampoRel) + 1 )
cTabCpo   := SubStr(cCampoQry, At(".", cCampoQry) + 1 )

//Remove o texto do underline para frente
cTabRel   := SubStr(cTabRel, 1, At("_", cTabRel) - 1 )
cTabCpo   := SubStr(cTabCpo, 1, At("_", cTabCpo) - 1 )

//Inclui S caso necessário nas tabela antigas.
cTabRel := Iif(Len(cTabRel) == 2, "S" + cTabRel, cTabRel)
cTabCpo := Iif(Len(cTabCpo) == 2, "S" + cTabCpo, cTabCpo)

cFilRel := Alltrim(xFilial(cTabRel))
cFilCpo := Alltrim(xFilial(cTabCpo))

Do Case
	Case Empty( cFilRel )
		cFilQry := " " + cCampoRel + " = '" + xFilial(cTabRel) + "' "

	Case cFilRel == cFilCpo
		cFilQry := " " + cCampoRel + " = " + cCampoQry + " "

	Case cFilRel $ cFilCpo
		cVazio  := Space( Len(xFilial(cTabCpo)) - Len(cFilRel) )
		cFilQry := " " + cCampoRel + " = SUBSTRING(" + cCampoQry + ", 1, " + Str(Len(cFilRel), 3) + ") ||'" + cVazio + "'"

	Case cFilQry $ cFilRel
		cVazio  := Space(Len(xFilial(cTabRel) - Len(cFilCpo)))
		cFilQry := " " + cCampoQry + " = SUBSTRING(" + cCampoRel + ", 1, " + Str(Len(cFilCpo), 3) + ") ||'" + cVazio + "'"
End Case

Return cFilQry

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFiltrWO()
Tela de filtro genérica para as rotinas WO TimeSheet, despesa e tabelado

@param cTab     , Código da Tabela de WO
@param lAtualiza, Reabre browse com novos filtros 

@author Abner Fogaça
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFiltrWO(cTab, lAtualiza)
Local aFiltrosWO  := {}
Local oDlg        := Nil
Local oPanel      := Nil
Local oGrClien    := Nil
Local oCliente    := Nil
Local oLoja       := Nil
Local oContrato   := Nil
Local oCaso       := Nil
Local oDataIni    := Nil
Local oDataFim    := Nil
Local oTpData     := Nil
Local oTipo       := Nil
Local oCobraLanc  := Nil
Local oCobraTipo  := Nil
Local oCobraCli   := Nil
Local oCobraCont  := Nil
Local oMotWODP    := Nil
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nLoc        := Iif(cLojaAuto == "2", 0, 45)
Local oLayer      := FWLayer():New()
Local oMainColl   := Nil
Local cTipoLanc   := ""
Local cRotina     := ""
Local cTitGrupoC  := ""
Local cTitCobLc   := ""
Local cCpoDtLanc  := ""
Local nTamVDlg    := 0 // Tamanho Vertical da Dialog
Local nTamHDlg    := 0 // Tamanho Horizontal da Dialog
Local nTamTipoL   := 0 // Tamanho do campo de Tipo do lançamento
Local cListBox    := STR0224 + ";" + STR0225 // "1 - Lançamento;2 - Conclusão"
Local cListMotWO  := STR0304 + ";" + STR0305 // "1 - Sim;2 - Não"
Local lNXVTpLanc  := NXV->(ColumnPos("NXV_TPLANC")) > 0
Local lRevisLD    := SuperGetMV("MV_JREVILD", .F., '2') == '1' // Controla a integracao da revisão de pré-fatura com o Legal Desk
Local lMotWO      := .F.

Private cGetClie  := ""
Private cGetLoja  := ""

Default cTab      := ""
Default lAtualiza := .F.

If cTab == "NV4"
	nTamVDlg  := 280
	nTamTipoL := 80
Else
	nTamVDlg  := 300
	nTamTipoL := 50
EndIf

If cLojaAuto == "2"
	nTamHDlg := 500
Else
	nTamHDlg := 475
EndIf

INCLUI := .F. //Alteração para o botão do EnchoiceBar mudar de "Salvar" para "Confirmar"

If cTab == "NV4"
	cTipoLanc  := "NV4_CTPSRV"
	cRotina    := "JurFilTdOk(aFiltrosWO,cTab).And.JUR142BrwR(aFiltrosWO, lAtualiza)"
	cTitGrupoC := "NV4_CGRPCL"
	cTitCobLc  := STR0223 // "No Tabelado:"
	cCpoDtLanc := "NV4_DTLANC"

ElseIf cTab == "NVY"
	cTipoLanc   := "NVY_CTPDSP"
	cRotina     := "JurFilTdOk(aFiltrosWO,cTab).And.JUR143BrwR(aFiltrosWO, lAtualiza)"
	cTitGrupoC  := "NVY_CGRUPO"
	cTitCobLc   := STR0210 // "Na Despesa:"
	cCpoTipoCb  := "NRH_COBRAR"
	cCpoDtLanc  := "NVY_DATA"

ElseIf cTab == "NUE"
	cTipoLanc  := "NUE_CATIV"
	cRotina    := "JurFilTdOk(aFiltrosWO,cTab).And.JUR145BrwR( , aFiltrosWO, lAtualiza)"
	cTitGrupoC := "NUE_CGRUPO"
	cTitCobLc  := STR0222 //"No Time Sheet:"
	cCpoTipoCb := "NRC_COBRAR"
	cCpoDtLanc := "NUE_DATATS"
EndIf

DEFINE MSDIALOG oDlg TITLE STR0206 FROM 0, 0 TO nTamVDlg, nTamHDlg PIXEL // "Filtro"

oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oPanel := tPanel():New(0,0,'',oMainColl,,,,,,0,0,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

oGrClien := TJurPnlCampo():Initialize(10, 10, 50, 22, oPanel, RetTitle(cTitGrupoC), "A1_GRPVEN") // "Cód Gr. Cliente"
oGrClien:SetF3 ("ACY")
oGrClien:SetChange  ( {|| JURSA1VAR( xFilial(cTab), oGrClien:GetValue(), '1') ,;
						 JurGatiWO("GrpCli" , oGrClien, oCliente, oLoja, oCaso, oContrato)} )
oGrClien:SetValid({|| JurTrgGCLC(@oGrClien,,,,,,,,"GRP",,,,,,,,)})
oGrClien:Activate()

oCliente := TJurPnlCampo():Initialize(10, 60, 50, 22, oPanel, RetTitle(cTab + "_CCLIE"), "A1_COD") // "Cód. Cliente"
oCliente:SetF3 ("SA1NUH")
If(cLojaAuto == "2")
	oCliente:SetChange  ( {|| cGetClie := oCliente:VALOR, JurGatiWO("Cliente" , oGrClien, oCliente, oLoja, oCaso, oContrato)} )
Else
	oCliente:SetChange  ( {|| cGetClie := oCliente:GetValue(), JurGatiWO("Cliente" , oGrClien, oCliente, oLoja, oCaso, oContrato),;
	                          cGetLoja := JurGetLjAt(), oLoja:SetValue(cGetLoja),;
	                          JurGatiWO("Loja" , oGrClien, oCliente, oLoja, oCaso, oContrato)} )
EndIf
oCliente:SetValid({|| JurTrgGCLC(@oGrClien,,@oCliente,,,,,,"CLI",,,,,,,,)})
oCliente:Activate()

oLoja := TJurPnlCampo():Initialize(10, 110, 40, 22, oPanel, RetTitle(cTab + "_CLOJA"), "A1_LOJA") // "Cód. Loja"
oLoja:SetChange( {|| cGetLoja := oLoja:GetValue(), JurGatiWO("Loja" , oGrClien, oCliente, oLoja, oCaso, oContrato)} )
oLoja:SetValid({|| JurTrgGCLC(@oGrClien,,@oCliente,,@oLoja,,,,"LOJ",,,,,,,,)})
oLoja:Visible(cLojaAuto == "2")
oLoja:Activate()
oLoja:SetWhen( {|| !Empty(oCliente:GetValue()) } )

oCaso := TJurPnlCampo():Initialize(10, 155 - nLoc, 50, 22, oPanel, RetTitle(cTab + "_CCASO"), "NVE_NUMCAS") // "Cód. Caso"
oCaso:SetF3("NVELOJ")
oCaso:SetChange( {|| cGetClie := oCliente:GetValue(), cGetLoja := oLoja:GetValue(), ;
					 JurGatiWO("Caso", oGrClien, oCliente, oLoja, oCaso, oContrato)} )
oCaso:SetValid({|| JurTrgGCLC(@oGrClien,,@oCliente,,@oLoja,,@oCaso,,"CAS",,,,,,,,)})
oCaso:Activate()

oContrato := TJurPnlCampo():Initialize(10, 205 - nLoc, 50, 22, oPanel, ,"NUT_CCONTR") // "Cód. Contrato"
oContrato:SetF3("NUTNT0")
oContrato:SetChange( {|| JurGatiWO("Contrato", oGrClien, oCliente, oLoja, oCaso, oContrato)} )
oContrato:Activate()
oContrato:SetWhen( {|| Empty(oCaso:GetValue()) } )
oGrClien:SetWhen( {|| Empty(oContrato:GetValue()) } )
oCliente:SetWhen( {|| Empty(oContrato:GetValue()) } )
oCaso:SetWhen( {|| Empty(oContrato:GetValue()) } )

oDataIni := TJurPnlCampo():Initialize(40, 10, 50, 22, oPanel, STR0108, cCpoDtLanc) // "Data início: "
oDataIni:Activate()

oDataFim := TJurPnlCampo():Initialize(40, 60, 50, 22, oPanel, STR0109, cCpoDtLanc) // "Data fim: "
oDataFim:Activate()

If cTab == "NV4"

	oTpData := TJurPnlCampo():Initialize(40, 110, 60, 25, oPanel, STR0226 , , , , , , , , ,cListBox) //#"Por data de:" ##"1 - Lançamento"
	oTpData:Activate()

	oCobraLanc := TJurPnlCampo():Initialize(70,10,40,25,oPanel, STR0213, cTab+"_COBRAR") // Cobrável:
	oCobraLanc:Activate()

	oTipo := TJurPnlCampo():Initialize(70, 60, nTamTipoL, 22, oPanel,, cTipoLanc ) // "Tipo do Lançamento:"
	oTipo:Activate()

Else

	oTipo := TJurPnlCampo():Initialize(40, 110, nTamTipoL, 22, oPanel,, cTipoLanc ) // "Tipo do Lançamento:"
	oTipo:Activate()

	If lNXVTpLanc .And. lRevisLD .And. cTab == "NVY" // Somente para despesas
		oMotWODP := TJurPnlCampo():Initialize(40, 155, 85, 25, oPanel, STR0303, , , , , , , , , cListMotWO) // "Mostra itens com Motivo de WO?"
		oMotWODP:Activate()
		lMotWO := .T.
	EndIf

	oCobraLanc := TJurPnlCampo():Initialize(80, 15, 40, 25, oPanel, cTitCobLc, cTab + "_COBRAR") // Lançamento Cobrar:
	oCobraLanc:Activate()

	oCobraTipo := TJurPnlCampo():Initialize(80, 72, 40, 25, oPanel, STR0211, cCpoTipoCb) // "No Tipo:"
	oCobraTipo:Activate()

	oCobraCli := TJurPnlCampo():Initialize(80, 129, 40, 25, oPanel, STR0212, cTab + "_COBRAR") // "No Cliente:"
	oCobraCli:Activate()

	oCobraCont := TJurPnlCampo():Initialize(80, 186, 40, 25, oPanel, STR0220, cTab + "_COBRAR") // "No Contrato:"
	oCobraCont:Activate()

	@ 70, 10  To  110, 230 Label STR0213 Pixel Of oPanel // Cobrável
EndIf

//Sempre utiliza #DEFINE conforme JURA143
bButtonOk := {|| aFiltrosWO := { oGrClien:GetValue()                                   ,; // nPGrCli    1
                                 oCliente:GetValue()                                   ,; // nPClien    2
                                 oLoja:GetValue()                                      ,; // nPLoja     3
                                 oCaso:GetValue()                                      ,; // nPCaso     4
                                 oContrato:GetValue()                                  ,; // nPContr    5
                                 oDataIni:GetValue()                                   ,; // nPDtIni    6
                                 oDataFim:GetValue()                                   ,; // nPDtFim    7
                                 oTipo:GetValue()                                      ,; // nPTipo     8
                                 oCobraLanc:GetValue()                                 ,; // nPCobraNVY 9
                                 IIf( cTab <> "NV4", oCobraTipo:GetValue(), "" )       ,; // nPCobraNRH 10
                                 IIf( cTab <> "NV4", oCobraCont:GetValue(), "" )       ,; // nPCobraNTK 11
                                 IIf( cTab <> "NV4", oCobraCli:GetValue(),  "" )       ,; // nPCobraNUC 12
                                 IIf( cTab == "NV4", JurTpData(oTpData:GetValue()), ""),; // nPDtInc 13 //#"1 - Lançamento"
                                 IIf( lMotWO, oMotWODP:GetValue(), "") }               ,; // nPMotWODesp 14
                                 IIf( Eval({|| &cRotina }), oDlg:End(), ) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
	(oDlg, bButtonOk, {|| oDlg:End()}, .F., /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F., .F., .T., .F.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTpData(cValor)
Rotina para tratar o tipo de data para lançamento tabelado

@Return cRet Retorna o campo de data para a query do filtro tabelado

@author Luciano Pereira dos Santos
@since 23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurTpData(cValor)
Local cRet  := ""

If cValor == STR0224 //#"1 - Lançamento"
	cRet := "NV4_DTLANC"
ElseIf  cValor == STR0225 //#"2 - Conclusão"
	cRet := "NV4_DTCONC"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilTdOk()
Rotina de validação do tudoOk para tela de Filtro de WO

@Param  aFiltrosWO array com paramentros para o filtro
@Param  cTab        Alias da tabela do lançamento

@Return lRet .T. Validação de data

@author Luciano Pereira dos Santos
@since 23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurFilTdOk(aFiltrosWO, cTab)
Local lRet := .T.

If !Empty(aFiltrosWO[6]) .And. !Empty(aFiltrosWO[7])

	lRet := aFiltrosWO[7] >= aFiltrosWO[6]

	If !lRet
		ApMsgStop( STR0208 ) // "A data inicial não pode ser maior que a data final."
	EndIf

EndIf

If lRet .And. cTab == "NV4" .And. (!Empty(aFiltrosWO[6]) .Or. !Empty(aFiltrosWO[7]))
	If Empty(aFiltrosWO[13])
		ApMsgStop(I18n(STR0227, {STR0226})) //#"Selecione uma das opções no campo '#1' antes de confirmar." ## "Por data de:"
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGatiWO()
Campo que dispara esse gatilho: CLiente, Loja, Contrato e Grupo de Cliente

@author Abner Fogaça
@since 06/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurGatiWO(cCampo, oGrupo, oClien, oLoja, oCaso, oContrato)
Local cRet       := ""
Local cVGrupo    := oGrupo:GetValue()
Local cVClien    := oClien:GetValue()
Local cVLoja     := oLoja:GetValue()

//Validacao do campo Grupo
If cCampo  == "GrpCli"
	If !Empty(JurGetDados("ACY", 1, xFilial("ACY") + cVGrupo, "ACY_GRPVEN"))
		If JurGetDados('SA1', 1, xFilial('SA1') + cVClien + cVLoja, 'A1_GRPVEN') != cVGrupo
			oClien:Clear()
			oLoja:Clear()
			oCaso:Clear()
			oContrato:Clear()
		EndIf
	EndIf
EndIf

//Validacao do campo Cliente
If cCampo == "Cliente"
	oLoja:Clear()
	oContrato:Clear()
EndIf

//Validacao do campo Loja
If cCampo == "Loja"
	oGrupo:SetValue (JurGetDados('SA1', 1, xFilial('SA1') + cVClien + cVLoja, 'A1_GRPVEN'), cVGrupo)
	oContrato:Clear()
EndIf

//Validacao do campo Contrato
If cCampo == "Contrato"
	oGrupo:Clear()
	oClien:Clear()
	oLoja:Clear()
	oCaso:Clear()
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBoleto
Emite os boletos da Fatura.

@Param cEscrit    Escritório para filtro de emissão
@Param cFatura    Fatura para filtro de emissão
@Param cResult    Resultado da emissão dos boletos
@Param cParcela   Parcela do título que terá o boleto emitido
@Param lRelat     Indica se a emissão do boleto será feita pelo financeiro

@author Cristina Cintra
@since 09/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurBoleto(cEscrit, cFatura, cResult, cParcela, lRelat, lFatura)
Local lRet       := .F.
Local aMVPAR     := {}
Local cNumTit    := ""
Local cPreFix    := ""
Local cBanco     := ""
Local cDestPath  := JurImgFat(cEscrit, cFatura, .T., .F., /*@cMsgRet*/)
Local cArquivo   := STR0249 + "_(" + Trim(cEscrit) + "-" + Trim(cFatura) + ")"  // boleto
Local aParams    := {}
Local nOrdem     := 0
Local lCpoTit    := AliasInDic("OHT") .And. NXM->(ColumnPos("NXM_TITNUM")) > 0//@12.1.35
Local cFilSE1    := ""
Local cFilTit    := ""
Local cTipo      := ""
Local cEmail     := "1"
Local lTitFat    := .F.

Default lRelat   := .T.
Default lFatura  := .F.

DbselectArea("OH1")

If lRelat //Emissão pelo SigaPFS
	cPreFix    := SuperGetMV( 'MV_JPREFAT',, 'PFS')
	cNumTit    := cFatura
	cBanco     := JurGetDados('NXA', 1, xFilial('NXA') + cEscrit + cFatura, 'NXA_CBANCO')
	cTipo := SuperGetMV( 'MV_JTIPFAT',, 'FT ' )
	cFilTit := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
	lTitFat := .T.
Else //Emissão pelo Financeiro
	cPreFix    := SE1->E1_PREFIXO
	cNumTit    := SE1->E1_NUM
	cBanco     := SE1->E1_PORTADO
	cTipo      := SE1->E1_TIPO
	cFilTit    := SE1->E1_MSFIL
	cFilSE1    := SE1->E1_FILIAL
	cParcela   := cParcela
	lTitFat := !Empty(StrTran(SE1->E1_JURFAT,"-", ""))
	If lCpoTit .And. !lTitFat
		cArquivo   := STR0249 + "_(" + Trim(cFilSE1) + "-" + Trim(cPreFix) + "-" + Trim(cNumTit) +  "-" + Trim(cParcela) + "-" + Trim(cTipo) +  ")"  // boleto	
		cArquivo    := StrTran(cArquivo, " ", "_")
		cEmail := "2"
	EndIf
	
	If !lTitFat
		cDestPath := JurImgFat("", "", .T., .F., /*@cMsgRet*/)
	EndIf
EndIf

aParams    := {cDestPath, cArquivo}
aMVPAR := { AvKey(cPreFix , "E1_PREFIXO") /*Prefixo*/   , ;
			AvKey(cNumTit , "E1_NUM"    ) /*Número*/    , ;
			AvKey(cBanco  , "E1_PORTADO") /*Banco*/     , ;
			AvKey(cParcela, "E1_PARCELA") /*Parcela*/   , ;
			AvKey(cEscrit , "NXA_CESCR")  /*Escritório*/, ;
			AvKey(cFatura , "NXA_COD")    /*Fatura*/    , ;
			AvKey(cTipo ,   "E1_TIPO")    /*Tipo*/      , ;
			AvKey(cFilTit , "E1_MSFIL")   /*Filial*/     ;
		}

lRet := StartJob("JobBoleto", GetEnvServer(), .T., cEmpAnt, cFilAnt, __cUserID, aMVPAR, aParams)

If lRet
	If cResult $ "1|2" // Resultado do relatório: '1' - Impressora / '2' - Tela / '3' - Word / '4' - Nenhum
		JurOpenFile( cArquivo + ".pdf", cDestPath, cResult, .F.)
	EndIf

	If FindFunction("J203GrvFil") .And. (lFatura .Or.  (!lFatura .And. lCpoTit .And. !lTitFat) )
		
		If  (lFatura .And. IsInCallStack("J204GERARPT") ) 

			nOrdem := JurSeqNXM(cEscrit, cFatura)

		ElseIf (!lFatura .And. lCpoTit) 

			nOrdem := JurSeqNXM("", "", cFilSE1, cPreFix, cNumTit, cParcela, cTipo)
		EndIf
	
		If lFatura
			J203GrvFil("4", cEscrit, cFatura, cArquivo + ".pdf", nOrdem, /*cFilSE1*/, /*cPreFix*/, /*cNumTit*/, /*cParcela*/, /*cTipo*/, cEmail)
		ElseIf !lTitFat .And. lCpoTit
			J203GrvFil("4", ""/*cEscrit*/, ""/*cFatura*/, cArquivo + ".pdf", nOrdem, cFilSE1, cPreFix, cNumTit, cParcela, cTipo, cEmail )
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JobBoleto()
Executa a emissão do boleto via JOB.

@param cEmpAux    - Código da empresa para abrir o ambiente
@param cFilAux    - Código da filial para abrir o ambiente
@param cCodUser   - Código do usuário para abrir o ambiente e o controle de emissão
@param aMVPAR     - Informações para localizar o Título
@param aParams    - Informações para geração do arquivo (boleto)

@author Jorge Martins / Luciano Pereira
@since 17/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JobBoleto(cEmpAux, cFilAux, cCodUser, aMVPAR, aParams)
Local lRet := .T.
Local cFunc := "U_FINX999"

If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(cEmpAux,cFilAux, , , , 'FINX999') // Abre o ambiente

	__cUserID := cCodUser

	&cFunc.(.F., aMVPAR, aParams) // Emissão do boleto

	RpcClearEnv() // Reseta o ambiente
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3SA6
Filtra a consulta padrão de SA6JUR de bancos com base no escritório.
Uso Geral.

@sample @#JURF3SA6()

@author Luciano Pereira dos Santos
@since 26/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3SA6()
Local cRet     := "@#SA6->A6_BLOCKED != '1'"
Local cEscrit  := ""
Local oModel   := Nil
Local aInfo    := {}
Local lJurxFin := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

If lJurxFin .And. FWAliasInDic("OHK") //Proteção

	If ! FWIsInCallStack('FINA080') .And. ! FWIsInCallStack('FINA090') .And. ! FWIsInCallStack('FINA091') .And.;
	   ! FWIsInCallStack('FINA240') .And. ! FWIsInCallStack('FINA241') .And. ! FWIsInCallStack('FINA050') .And. ;
	   ! FWIsInCallStack('FINA040') .And. ! FWIsInCallStack('FINA061') .And. ! FWIsInCallStack('FINA070') .And. ;
	   ! FWIsInCallStack('FINA460') .And. ! FWIsInCallStack('FINA460A') .And. ! FWIsInCallStack('FINA110')
		oModel := FWModelActive()
		aInfo  := JurInfPag(oModel)
	Else
		aInfo := {JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD")}
	EndIf

	If Len(aInfo) >= 1
		If Empty(aInfo[1])
			cRet := "@#.F."
		Else
			cEscrit += " .And. Posicione('OHK', 1, xFilial('OHK') + '" + aInfo[1] + "'+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON,'OHK_CESCRI') == '" + aInfo[1] + "'@#"
		EndIf
	EndIf

EndIf

cRet += IIf(Empty(cEscrit), "@#", cEscrit)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JF3SA6OHK()
Consulta padrão da SA6 com a OHK

@since 22/03/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function JF3SA6OHK()
Local lRet           := .T.
Local nI             := 0
Local cQuery         := ""
Local lJurxFin       := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local aCampos        := {'A6_COD','A6_AGENCIA','A6_NUMCON', 'A6_NREDUZ', 'A6_NOMEAGE'}
Local aInfo          := {}
Local lIsInCallStack := .F.
Local aNaoUsaMdl     := {'FINA080','FINA090','FINA091','FINA240','FINA241',;
                         'FINA050','FINA040','FINA061','FINA070','FINA460',;
				      	 'FINA460A','FINA110'} // Array de Modelos que buscam o Cód do escritório via JurGetDados
	
	For nI := 1 to Len(aNaoUsaMdl)
		lIsInCallStack := (FWIsInCallStack(aNaoUsaMdl[nI]))

		If (lIsInCallStack)
			Exit
		EndIf
	Next nI

	If lJurxFin .And. FWAliasInDic("OHK") //Proteção

		If lIsInCallStack
			aInfo := {JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD")}
		Else
			oModel := FWModelActive()
			aInfo  := JurInfPag(oModel)
		EndIf
	EndIf

	cQuery += " SELECT SA6.A6_COD,SA6.A6_AGENCIA,SA6.A6_NUMCON, SA6.A6_NREDUZ, SA6.A6_NOMEAGE,  SA6.R_E_C_N_O_ SA6RECNO "
	cQuery +=   " FROM " + RetSqlName("OHK") + " OHK "
	cQuery +=  " INNER JOIN "+ RetSqlName("SA6") + " SA6 "
	cQuery +=     " ON (SA6.A6_COD = OHK.OHK_CBANCO "
	cQuery +=    " AND SA6.A6_AGENCIA = OHK.OHK_CAGENC "
	cQuery +=    " AND SA6.A6_NUMCON = OHK.OHK_CCONTA "
	cQuery +=    " AND SA6.D_E_L_E_T_ = ' ') "
	cQuery +=  " WHERE OHK.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SA6.A6_BLOCKED <> '1' "
	cQuery +=    " AND SA6.A6_FILIAL = '" + FWxFilial("SA6", cFilAnt) + "' "

	If (Len(aInfo) > 0)
		cQuery +=    " AND OHK.OHK_CESCRI = '" + aInfo[1] + "' "
	EndIf
 
	// Função genérica para consultas especificas
	nResult := JurF3SXB("SA6", aCampos, "", .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("SA6")
		SA6->( dbgoTo(nResult) )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurInfPag()
Rotina para retornar informações com base no modelo enviado.

@param oModel   Modelo de dados envolvendo Bancos
@param nLinha   Linha do SubModelo de Pagadores

@author Luciano Pereira dos Santos
@since 27/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurInfPag(oModel, nLinha)
Local aRet     := {}
Local cTabM    := ""
Local cTabD    := ""
Local oModelD  := Nil
Local oModelM  := Nil
Local cEscrit  := ""
Local cBanco   := ""
Local cAgencia := ""
Local cConta   := ""
Local lAlterCl := .F.
Local cCliPg   := ""
Local cLojPg   := ""
Local nPercent := 0
Local cCampo   := ""
Local nPerDesc := 0

Do Case
Case oModel:GetId() == 'JURA096'
	cTabM := 'NT0'
	cTabD := 'NXP'
Case oModel:GetId() == 'JURA056'
	cTabM := 'NW2'
	cTabD := 'NXP'
Case oModel:GetId() == 'JURA033'
	cTabM := 'NVV'
	cTabD := 'NXG'
Case oModel:GetId() == 'JURA202'
	cTabM := 'NX0'
	cTabD := 'NXG'
Case oModel:GetId() == 'JURA203'
	cTabM := 'NX5'
	cTabD := 'NXG'
Case oModel:GetId() == 'JURA204'
	cTabM := 'NXA'
Case oModel:GetId() == 'JURA069'
	cTabM := 'NWF'
Case oModel:GetId() == 'JURA148'
	cTabM := 'NUH'
EndCase

If !Empty(cTabM)

	oModelM := oModel:GetModel(cTabM + 'MASTER' + Iif(cTabM == 'NVV', 'CAB', ''))
	cEscrit := oModelM:GetValue(cTabM + '_CESCR' + Iif(cTabM == 'NUH', '2', ''))
	cCampo  := cTabM + '_CESCR' + Iif(cTabM == 'NUH', '2', '')

	If !(cTabM $ 'NWF|NUH|NXA')
		oModelD  := oModel:GetModel(cTabD + 'DETAIL')
		nLinha   := Iif(Empty(nLinha), oModelD:Getline(), nLinha)
		cBanco   := oModelD:GetValue(cTabD + "_CBANCO", nLinha)
		cAgencia := oModelD:GetValue(cTabD + "_CAGENC", nLinha)
		cConta   := oModelD:GetValue(cTabD + "_CCONTA", nLinha)
		cCliPg   := oModelD:GetValue(cTabD + "_CLIPG",  nLinha)
		cLojPg   := oModelD:GetValue(cTabD + "_LOJAPG", nLinha)
		lAlterCl := oModelD:IsFieldUpdated(cTabD + "_CLIPG", nLinha) .Or.;
		            oModelD:IsFieldUpdated(cTabD + "_LOJAPG", nLinha) //Verifica se o pagador foi alterado
		nPercent := oModelD:GetValue(cTabD + "_PERCEN", nLinha)
		nPerDesc := oModelD:GetValue(cTabD + "_DESPAD", nLinha)

	ElseIf cTabM == 'NXA'
		cBanco   := oModel:GetValue(cTabM + 'MASTER', 'NXA_CBANCO')
		cAgencia := oModel:GetValue(cTabM + 'MASTER', 'NXA_CAGENC')
		cConta   := oModel:GetValue(cTabM + 'MASTER', 'NXA_CCONTA')

	Else
		cBanco   := oModel:GetValue(cTabM + 'MASTER', Iif(cTabM == 'NUH', "NUH_CBANCO", 'NWF_BANCO' ))
		cAgencia := oModel:GetValue(cTabM + 'MASTER', Iif(cTabM == 'NUH', "NUH_CAGENC", 'NWF_AGENCI'))
		cConta   := oModel:GetValue(cTabM + 'MASTER', Iif(cTabM == 'NUH', "NUH_CCONTA", 'NWF_CONTA' ))
	EndIf

	aRet := {cEscrit, cBanco, cAgencia, cConta, oModelD, lAlterCl, cCliPg, cLojPg, nPercent, cCampo, nPerDesc}

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldPag()
Rotina para validação dos pagadores.

@param oModel modelo ativo
@param lShowMsg valida se irá mostrar o erro 
@author Luciano Pereira dos Santos
@since 26/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldPag(oModel, lShowMsg)
Local lRet     := .T.
Local cEscrit  := ""
Local oGrid    := Nil
Local nI       := 0
Local cBanco   := ""
Local cAgencia := ""
Local cConta   := ""
Local cCliPg   := ""
Local cLojPg   := ""
Local nPercent := 0
Local lAlterCl := .F.
Local lJurxFin := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local nPerDesc := 0
Local cErro    := ""
Local cSolucao := STR0229
Local aRet     := {.T., ""}

Default lShowMsg := .T.

If Len(aInfo := JurInfPag(oModel)) >= 5
	cEscrit  := aInfo[1]
	oGrid    := aInfo[5]
EndIf

For nI := 1 To oGrid:Length()
	If !oGrid:IsDeleted(nI)
		oGrid:Goline(nI)
		If Len(aInfo := JurInfPag(oModel, nI)) >= 9
			cBanco   := aInfo[2]
			cAgencia := aInfo[3]
			cConta   := aInfo[4]
			lAlterCl := aInfo[6]
			cCliPg   := aInfo[7]
			cLojPg   := aInfo[8]
			nPercent += aInfo[9]
			nPerDesc := aInfo[11]

		EndIf

		If JurGetDados('SA6', 1, xFilial('SA6') + cBanco + cAgencia + cConta, "A6_BLOCKED") == "1" //Validação de bloqueio de banco
			cErro := I18n( STR0228, {cBanco, cAgencia, cConta}) //#"O banco #1, agência #2 e conta #3 está bloqueado." ## "Verifique o cadastro de banco ou selecione outro banco."
			lRet  := .F.
			Exit
		EndIf

		If lRet
			If lJurxFin .And. FWAliasInDic("OHK") // Proteção OHK
				If Empty(JurGetDados("OHK", 1, xFilial("OHK") + cEscrit + cBanco + cAgencia + cConta, "OHK_CESCRI")) //Validação de conta associada ao banco
					cErro := I18n(STR0230, {cBanco, cAgencia, cConta, cEscrit}) //# "O banco #1, agência #2 e conta #3 não está associado ao escritório #4." ##"Verifique o cadastro de banco ou selecione outro banco."
					lRet  := .F.
					Exit
				EndIf
			Else
				If Empty(JurGetDados("SA6", 1, xFilial("SA6") + cBanco + cAgencia + cConta, "A6_COD"))
					cErro :=  I18n(STR0239, {cBanco,cAgencia,cConta}) //# "O banco #1, agência #2 e conta #3 não foi encontrado." ##"Verifique o cadastro de banco ou selecione outro banco."
					lRet  := .F.
				EndIf
			EndIf
		EndIf

		If lAlterCl //Validação de Encaminhamento de Fatura
			
			If !lShowMsg
				aRet := JurVldEnc(oModel, cCliPg, cLojPg, lShowMsg)
				lRet  := aRet[1]
				cErro := aRet[2]
			ElseIf !(lRet := JurVldEnc(oModel, cCliPg, cLojPg, lShowMsg))
				Exit
			EndIf
		EndIf

		If nPerDesc == 100
			cErro    := I18n(STR0306, {cCliPg}) // "Desconto de 100% não permitido no pagador '#1'","Verifique o desconto concedido."
			cSolucao := STR0307
			lRet     := .F.
			Exit
		EndIf

	EndIf

Next nI

If lRet .And. (nPercent != 100.00) //Validação da soma dos percentuais dos pagadores
	cSolucao := STR0232
	lRet     := .F.
	cErro    := I18n(STR0231, {cValtochar(nPercent)}) //#"O valor atual da soma dos pagadores é de #1%." ## //"Ajsute os valores dos percentuais dos pagadores para que a soma seja igual a 100%."
EndIf


If lShowMsg .And. !lRet
	JurMsgErro(cErro, , cSolucao)
Else
	If !Empty(cErro)
		cErro += cSolucao
	EndIf
	aRet := { lRet, cErro }

EndIf

Return Iif(lShowMsg, lRet, aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldEnc
Rotina para validar os contatos do encaminhamento de fatura.

@author Luciano Pereira dos Santos
@since 16/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurVldEnc(oModel, cCliPg, cLojPg, lShowMsg)
Local lRet      := .T.
Local nI        := 0
Local oModelNVN := oModel:GetModel('NVNDETAIL')
Local cContato  := ''
Local aRet      := {.T., ""}

Default lShowMsg  := .T.

If !oModelNVN:IsEmpty()
	For nI := 1 To oModelNVN:GetQtdLine()
		If !oModelNVN:IsDeleted(nI)
			cContato := oModelNVN:GetValue('NVN_CCONT', nI)
			If !lShowMsg
				aRet := JurVldCont(cContato, cCliPg, cLojPg, lShowMsg)
			ElseIf !(lRet := JurVldCont(cContato, cCliPg, cLojPg, lShowMsg))
				Exit
			EndIf
		EndIf
	Next nI
EndIf

Return Iif(lShowMsg, lRet, aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldCnt(cContato, cCliPg, cLojPg)
Rotina para validar os contatos dos pagadores.

@author Luciano Pereira dos Santos
@since 26/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldCont(cContato, cCliPg, cLojPg, lShowMsg)
Local lRet    := .T.
Local oModel  := Nil
Local cChave  := ''
Local aRet    := {.T., ""}

Default lShowMsg  := .T.

If Empty(cCliPg) .Or. Empty(cLojPg)
	cChave := JURGetPag()
Else
	cChave := cCliPg + cLojPg
EndIf

If Empty(cContato)
	oModel   := FWModelActive()
	cContato := oModel:GetModel("NVNDETAIL"):GetValue('NVN_CCONT')
EndIf

If lShowMsg
	lRet := JurContOK('SA1', cContato, xFilial("SA1") + cChave, "SU5->U5_ATIVO=='1'", lShowMsg)
Else
	aRet := JurContOK('SA1', cContato, xFilial("SA1") + cChave, "SU5->U5_ATIVO=='1'", lShowMsg)
EndIf

Return Iif(lShowMsg, lRet, aRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldSA6
Validação dos campos de Banco, Agência e Conta quando usado filtro
de banco por escritório. Será permitido indicar somente registros
vinculados ao escritório.

Usado nos campos de Banco, Agência e Conta que utilizam a consulta
padrão SA6JUR

@Param cTipo    Indica se é campo Banco (1), Agência (2) ou Conta(3)
@Param aInfo    Array com as informações de Escritório, Banco, Agência
				e Conta para chamadas não MVC

@author Jorge Martins
@since 26/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldSA6(cTipo, aInfo)
Local lRet      := .T.
Local oModel    := Nil
Local cBanco    := ""
Local cAgencia  := ""
Local cConta    := ""
Local cChave    := ""
Local cProblema := ""
Local cSolucao  := ""
Local lJurxFin  := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lJFilBco  := SuperGetMV("MV_JFILBCO",, .F.) // Integração SIGAPFS x SIGAFIN
Local lModel    := .F.
Local cCampo    := ""

Default aInfo   := {}

If Len(aInfo) == 0
	oModel  := FWModelActive()
	aInfo   := JurInfPag(oModel)
	lModel  := .T.
EndIf

If Len(aInfo) >= 4

	cEscrit  := aInfo[1]
	cBanco   := aInfo[2]
	cAgencia := aInfo[3]
	cConta   := aInfo[4]

	Do Case
	Case cTipo == "1"
		cChave    := cBanco
	Case cTipo == "2"
		cChave    := cBanco + cAgencia
	Case cTipo == "3"
		cChave    := cBanco + cAgencia + cConta
	EndCase

	If cTipo == "3" .AND. JurGetDados("SA6", 1, xFilial("SA6") + cChave, "A6_BLOCKED") == "1"
		lRet := JurMsgErro(I18n(STR0228, {cBanco, cAgencia, cConta}), , STR0229, lModel) ////#"O banco #1, agência #2 e conta #3 está bloqueado." ## "Verifique o cadastro de banco ou selecione outro banco."
	EndIf

	If lRet
		If lJurxFin .And. FWAliasInDic("OHK") // Proteção OHK
			If lModel
				If Empty(cEscrit)
					cCampo    := RetTitle(aInfo[10])
					cProblema := I18N(STR0240, {cCampo, aInfo[10]}) //""O campo '#1' não está preenchido"
					cSolucao  := STR0241 //"Informe um escritório válido antes de preencher os dados do banco."

					lRet := .F.
				Else
					lRet := !Empty(JurGetDados("OHK", 1, xFilial("OHK") + cEscrit + cChave, "OHK_CESCRI"))
				EndIf
			ElseIf !lModel .And. lJFilBco
				If Empty(cEscrit)
					cProblema := STR0242 //"Não foi encontrado um escritório para esta filial"
					cSolucao  := STR0243 //"Vincule um escritório válido para esta filial."

					lRet := .F.
				Else
					lRet := !Empty(JurGetDados("OHK", 1, xFilial("OHK") + cEscrit + cChave, "OHK_CESCRI"))
				EndIf
			Else
				lRet := ExistCpo('SA6', cChave, 1)
			EndIf
		Else
			lRet := ExistCpo('SA6', cChave, 1)
		EndIf

		If !lRet
			If Empty(cProblema)
				Do Case
				Case cTipo == "1"
					cProblema := STR0233 //"Banco inválido ou inexistente."
					cSolucao  := I18n(STR0234, {cEscrit}) //"Informe um banco válido que esteja vinculado ao escritório '#1'."
				Case cTipo == "2"
					cProblema :=  STR0235 //"Agência inválida ou inexistente."
					cSolucao  := I18n(STR0236, {cEscrit}) //"Informe uma agência válida que esteja vinculada ao escritório '#1'."
				Case cTipo == "3"
					cProblema := STR0237 //"Conta inválida ou inexistente."
					cSolucao  := I18n(STR0238, {cEscrit}) //"Informe uma conta válida que esteja vinculada ao escritório '#1'."
				EndCase
			EndIf
			JurMsgErro(cProblema,, cSolucao, lModel)
		EndIf
	EndIf

	If lRet .And. lJurxFin .And. FindFunction("JurBnkNat")
		lRet := JurBnkNat(cBanco, cAgencia, cConta) // Valida natureza do banco
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSX7SA6
Função de gatilho dos campos de Banco, Agência e Conta quando usado
filtro de banco por escritório.

Usado nos campos de Escritório, como condição de gatilhos para
limpar os campos de Banco, Agência e Conta que utilizam a consulta
padrão SA6JUR

@author Jorge Martins
@since 26/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSX7SA6()
Local lRet      := .T.
Local cEscrit   := ""
Local oModel    := FWModelActive()
Local aInfo     := {}
Local cBanco    := ""
Local cAgencia  := ""
Local cConta    := ""

If oModel != Nil .And. FWAliasInDic("OHK") // Proteção

	If Len(aInfo := JurInfPag(oModel)) >= 4
		cEscrit  := aInfo[1]
		cBanco   := aInfo[2]
		cAgencia := aInfo[3]
		cConta   := aInfo[4]
	EndIf

	lRet := Empty(JurGetDados("OHK", 1, xFilial("OHK") + cEscrit + cBanco + cAgencia + cConta, "OHK_CESCRI") )

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurWhenSA6
Função de when dos campos de Banco, Agência e Conta quando usado
filtro de banco por escritório.

@author Jorge Martins
@since 26/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurWhenSA6()
Local lRet     := .T.
Local cEscrit  := ""
Local oModel   := Nil
Local aInfo    := {}
Local lJurxFin := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

If lJurxFin .And. FWAliasInDic("OHK") // Proteção

	oModel   := FWModelActive()
	If oModel != Nil .And. Len(aInfo := JurInfPag(oModel)) >= 1
		cEscrit := aInfo[1]
	EndIf

	lRet := !Empty(cEscrit)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFreeArr
Função para limpar o array ou objeto da memória

@Param aArray, array que está sendo utilizado
@author queizy.nascimento/bruno.ritter
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFreeArr(aArray)
Local nI := 0

If ValType(aArray) == 'A'
	For nI := 1 To Len(aArray)
		If ValType(aArray[nI]) == 'A'
			JurFreeArr(aArray[nI])
		ElseIf ValType(aArray[nI]) == 'O'
			FreeObj(aArray[nI])
		EndIf
	Next nI

	ASize(aArray, 0)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNVELOJA()
Consulta especifica do Caso validando o parâmetro MV_JLOJAUT.

@author Anderson Carvalho
@since 14/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNVELOJA()
Local lRet        := .T.
Local oModel      := FWModelActive()
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aCampos     := ""
Local cIdmodel    := ""
Local cFiltro     := ""

If !Empty(oModel)
	cIdmodel := oModel:GetId()
EndIf

Do Case
	Case cIdmodel == "JURA027" //Lançamento Tabelado
		cFiltro := J027FCas4()
	Case cIdmodel == "JURA033" //Fatura Adcional
		cFiltro := J033FCASW()
	Case cIdmodel == "JURA049" //Despesas
		cFiltro := JA049NVE("NVYMASTER", "NVY_CGRUPO", "NVY_CCLIEN", "NVY_CLOJA", "NVE_LANTS")
	Case FWIsInCallStack('JURA063') .Or. FWIsInCallStack('JURA146') // Remanejamento de Casos e Consulta de WO - Casos Vinculados
		cFiltro := JA202F3("2")
	Case cIdmodel == "JURA069" //Controle de Adiantamentos
		cFiltro := J069FCasF()
	Case cIdmodel == "JURA096" // Contratos
		cFiltro := J096NVENUT()
	Case cIdmodel == "JURA109" ;// Lançamento Tabelado em Lote
		.Or. cIdmodel == "JURA246" .Or. cIdmodel == "JURA247" .Or. cIdmodel == "JURA281" // Desdobramentos/Desd. Pós Pagamento/Desd. NF Entrada.
		cFiltro := JURNVE('NWMMASTER', 'NWM_CCLIEN', 'NWM_LCLIEN')
	Case FWIsInCallStack('JURA142') .Or. FWIsInCallStack('JURA143'); // Inclusão de WO - Tabelado, Despesas
		.Or. FWIsInCallStack('JURA145') .Or. FWIsInCallStack('JURA201') // Inclusão de WO - Time Sheets e Emissão de Pré-Fatura
		cFiltro := JA201F3("2")
	Case cIdmodel == "JURA144" //Timesheet
		cFiltro := JANVELANC("NUEMASTER", "NUE_CGRPCL", "NUE_CCLIEN", "NUE_CLOJA", "NVE_LANTS")
	Case cIdmodel == "JURA241" // Tela de Lançamentos (entre Naturezas).
		cFiltro := J241FCasF()
	Case cIdmodel == "JURA235" .Or. cIdmodel == "JURA235A" // Solicitação de Despesa e Aprovação de Despesa.
		cFiltro := J235NVEF3()
	Case FWIsInCallStack('JURA235B') // Aprovação de Despesas em Lote
		cFiltro := J235BNVEF3()
	Case FWIsInCallStack('JURA176A') // Aprovação tarifador
		cFiltro := JURNVE('NYXMASTER', 'NYX_CCLIEN', 'NYX_CLOJA')
EndCase

If cLojaAuto == "2"
	aCampos := {'NVE_CCLIEN', 'NVE_LCLIEN', 'NVE_NUMCAS', 'NVE_TITULO'}
Else
	aCampos := {'NVE_CCLIEN', 'NVE_NUMCAS', 'NVE_TITULO'}
EndIf

cFiltro := Replace(cFiltro, "@#", "")
cFiltro := Replace(cFiltro, "#@", "")
cFiltro := Replace(cFiltro, ".T.", "1==1")
cFiltro := Replace(cFiltro, ".F.", "1==2")
cFiltro := Replace(cFiltro, ".And.", "And")

lRet := JURSXB("NVE", "NVELOJ", aCampos, .T., .T., cFiltro, "JURA070",, 10) // Função genérica para consultas especificas

JurFreeArr(@aCampos)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVdMultRev
Valida o conteúdo da aba Sócio/Revisores (OHN) existente na JURA202 e
JURA070.

@Param   oModelOHN    Submodelo da OHN (OHNDETAIL)

@Return  lRet         .T. ou .F.

@Sample  JVdMultRev(oModel:GetModel("OHNDETAIL"))

@author Cristina Cintra
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVdMultRev(oModelOHN)
Local lRet       := .T.
Local nQtd       := oModelOHN:GetQtdLine()
Local nLineOld   := oModelOHN:GetLine()
Local cDescModel := oModelOHN:GetDescription()
Local nI         := 0
Local aInfo      := {}
Local cMsg       := ""
Local cSolucao   := ""

If oModelOHN:IsUpdated() .And. !oModelOHN:IsEmpty()
	For nI := 1 To nQtd
		If !oModelOHN:IsDeleted(nI) .And. !oModelOHN:IsEmpty(nI)

			// Valida a duplicidade de Ordens
			If ( aScan( aInfo, { |aX| aX[1] == oModelOHN:GetValue("OHN_ORDEM", nI) .And. aX[2] == oModelOHN:GetValue("OHN_REVISA", nI) } ) ) > 0
				lRet     := .F.
				cMsg     := STR0256 // "Não é permitida a existência de ordens em duplicidade!"
				cSolucao := I18N(STR0257, {Alltrim(RetTitle('OHN_ORDEM')), cDescModel}) // "Verifique o valor digitado no campo '#1' da aba '#2'."
				Exit
			Else
				Aadd(aInfo, {oModelOHN:GetValue("OHN_ORDEM", nI), oModelOHN:GetValue("OHN_REVISA", nI) })
			EndIf

			//Valida os tipos de Revisão - só pode usar Ambos ou Despesas/Honorários
			If ( aScan( aInfo, { |aX| aX[2] $ Iif(oModelOHN:GetValue("OHN_REVISA", nI) == "3", "12", "3") } ) ) > 0
				lRet     := .F.
				cMsg     := STR0258 // "Não é permitida a existência de revisores com tipo de revisão ambos e despesas/honorários no mesmo caso!"
				cSolucao := I18N(STR0257, {Alltrim(RetTitle('OHN_REVISA')), cDescModel}) // "Verifique o valor digitado no campo '#1' da aba '#2'."
				Exit
			EndIf

		EndIf
	Next nI
EndIf

If !lRet
	JurMsgErro(cMsg,, cSolucao)
EndIf

oModelOHN:GoLine(nLineOld)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCompart()
Compara o nivel de compartilhamento entre as tabelas

@author Luciano Pereira
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCompart(aTabs, nNivel, cMsgErro)
Local lRet       := .T.
Local nI         := 0
Local nY         := 0
Local cComp      := ""
Local aComp      := {}
Local aDiff      := {}

Default nNivel   := 3
Default cMsgErro := STR0259 //"Existem problemas de compartilhamento entre tabelas que impendem a utilização do sistema."

aNivel := Iif(nNivel == 1, {1}, Iif(nNivel == 2, {1,2}, {1,2,3}))

For nI := 1 To Len(aTabs)
	aEval(aNivel, {|a| cComp += FwModeAccess(aTabs[nI], a)}) //Verifica os niveis de compartilhamento
	aAdd(aComp, {aTabs[nI], cComp})
	cComp := ''
Next nI

For nI := 1 To Len(aComp)
	For nY := 1 To Len(aComp)
		If aComp[nI][2] != aComp[nY][2]
			If aScan(aDiff, {|a| (aComp[nI, 1] == a[1] .And. aComp[nY, 1] == a[2]) .Or. (aComp[nY, 1] == a[1] .And. aComp[nI, 1] == a[2])}) == 0
				Aadd(aDiff, {aComp[nY][1], aComp[nI][1]})
			EndIf
		EndIf
	Next nY
Next nI

aEval(aDiff, {|a| cComp += I18n(STR0260, {a[1] + " (" + Alltrim(FWX2Nome(a[1])) + ")", a[2] + " (" + Alltrim(FWX2Nome(a[2])) + ")"}) + CRLF}) //"#1 e #2."

If !Empty(cComp)
	ApMsgStop(cMsgErro + CRLF + CRLF + STR0261 + CRLF + cComp ) //#"Verifique o compartilhamento das tabelas: "
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTSTab()
Verifica e retorna os Time Sheets relacionados ao Tabelado, para que seja
feito o vínculo deles na pré-fatura.

@param  cCodTB  Cod Lancto Tabelado

@return aRet    Código dos Time Sheets encontrados

@author Cristina Cintra
@since 01/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTSTab(cCodTB)
Local aArea     := GetArea()
Local cQuery    := ""
Local aRet      := {}

cQuery := " SELECT NUE_COD COD "
cQuery += " FROM " + RetSqlName("NUE") + " NUE "
cQuery += " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
cQuery +=   " AND NUE.NUE_CLTAB = '" + cCodTB + "' "
cQuery +=   " AND NUE.D_E_L_E_T_ = ' '"

aRet := JurSQL(cQuery, "COD")

RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTrgEbil()
Gatilhos e validações para Atividade Jurídica/Atividade E-billing/Fase/Tarefa em telas feitas a mão utilizando a classe TJurPnlCampo

@param oAtivJur  , Objeto atividade jurídica.
@param cAtivJur  , Variável do objeto de atividade jurídica.
@param oDesAtivJ , Objeto da descrição atividade jurídica.
@param cDesAtivJ , Variável da descrição atividade jurídica.
@param oAtivEbill, Objeto atividade ebilling.
@param cAtivEbill, Variável do objeto de atividade ebilling.
@param oDesAtivE , Objeto da descrição atividade ebilling.
@param cDesAtivE , Variável da descrição atividade ebilling.
@param oFase     , Objeto fase ebilling.
@param cFase     , Variável do objeto de fase ebilling.
@param oDesFase  , Objeto da descrição fase ebilling.
@param cDesFase  , Variável da descrição fase ebilling.
@param oTarefa   , Objeto tarefa ebilling.
@param cTarefa   , Variável do objeto de tarefa ebilling.
@param oDesTarefa, Objeto da descrição tarefa ebilling.
@param cDesTarefa, Variável da descrição tareafa ebilling.
@param cValid    , Tipo de validação "ATIVJUR" = Avidade Jurídica
                                     "ATIVEBI" = Ativida Ebilling
                                     "FASE"    = Fase Ebilling
                                     "TAREF"   = Tarefa Ebilling
@param lMsg      , Se exibe a mensagem de erro.

@Return aRet    Código dos Time Sheets encontrados

@author Bruno Ritter
@since 07/12/2018
/*/
//-------------------------------------------------------------------
Function JurTrgEbil(cCliente, cLoja, oAtivJur, cAtivJur, oDesAtivJ, cDesAtivJ, oAtivEbill, cAtivEbill, oDesAtivE, cDesAtivE, oFase, cFase, oDesFase, cDesFase, oTarefa, cTarefa, oDesTarefa, cDesTarefa, cValid, lMsg)
	Local lValid       := .T.
	Local aRetDados    := {}
	Local oModelAct    := Nil
	Local cEmp         := ""
	Local cDoc         := ""
	Local lLimpAtivJ   := .F.
	Local lLimpAtivE   := .F.
	Local lLimpFase    := .F.
	Local lLimpTaref   := .F.
	Local lUsaEbill    := .F.
	Local cCodSeqEbi   := ""
	Local cCodAtvEbi   := ""
	Local lAtvJurChg   := Iif(Empty(oAtivJur), .T., oAtivJur:IsModified())
	Local lAtvEbiChg   := Iif(Empty(oAtivEbill), .T., oAtivEbill:IsModified())

	Default cCliente   := ""
	Default cLoja      := ""
	Default oAtivJur   := Nil
	Default cAtivJur   := ""
	Default oDesAtivJ  := Nil
	Default cDesAtivJ  := ""
	Default oAtivEbill := Nil
	Default cAtivEbill := ""
	Default oDesAtivE  := Nil
	Default cDesAtivE  := ""
	Default oFase      := Nil
	Default cFase      := ""
	Default oDesFase   := Nil
	Default cDesFase   := ""
	Default oTarefa    := Nil
	Default cTarefa    := ""
	Default oDesTarefa := Nil
	Default cDesTarefa := ""
	Default cValid     := ""
	Default lMsg       := .T.

	cAtivJur   := IIF(Empty(oAtivJur)  , CriaVar('NRC_COD', .F.)   , oAtivJur:GetValue())
	cAtivEbill := IIF(Empty(oAtivEbill), CriaVar('NS0_CATIV', .F.) , oAtivEbill:GetValue())
	cFase      := IIF(Empty(oFase)     , CriaVar('NRY_CFASE', .F.) , oFase:GetValue())
	cTarefa    := IIF(Empty(oTarefa)   , CriaVar('NRZ_CTAREF', .F.), oTarefa:GetValue())

	If (Empty(cCliente) .Or. Empty(cLoja)) .And. Upper(cValid) != "ATIVJUR"
		lValid      := .F.
		lLimpAtivJ  := .T.
		lLimpAtivE  := .T.
		lLimpFase   := .T.
		lLimpTaref  := .T.
		ApMsgAlert(STR0264) // "Para alterar esse campo é necessário informar cliente e loja e caso!"
	Else
		oModelAct := FWModelActive()
		If oModelAct != Nil .And. oModelAct:GetId() == "JURA148"
			lUsaEbill := oModelAct:GetValue("NUHMASTER", "NUH_UTEBIL") == '1'
			cEmp      := oModelAct:GetValue("NUHMASTER", "NUH_CEMP")
		Else
			lUsaEbill := JAUSAEBILL(cCliente,cLoja)
			cEmp      := JurGetDados("NUH", 1, xFilial("NUH") + cCliente + cLoja, "NUH_CEMP")
		EndIf
	EndIf

	If lValid .And. !lUsaEbill .And. Upper(cValid) != "ATIVJUR"
		lValid      := .F.
		lLimpAtivJ  := .T.
		lLimpAtivE  := .T.
		lLimpFase   := .T.
		lLimpTaref  := .T.
		ApMsgAlert(STR0265) // "O campo não pode ser alterado pois o Cliente não é EBilling!"
	EndIf

	If lValid
		cDoc := JurGetDados("NRX", 1, xFilial("NRX") + cEmp, "NRX_CDOC")
	EndIf

	If lValid .AND. Upper(cValid) == "ATIVJUR" .And. lAtvJurChg

		If !Empty(cAtivJur) .And. (lValid := ExistCpo('NRC', cAtivJur, 1))
				If lUsaEbill
					cCodAtvEbi := JurGetDados('NS1', 3, xFilial("NS1") + cDoc + cAtivJur, "NS1_CATIV") // NS1_FILIAL+NS1_CDOC+NS1_CATIVJ

					If !Empty(cCodAtvEbi)

						If NS0->(ColumnPos("NS0_CFASE")) > 0 .And. NS0->(ColumnPos("NS0_CTAREF")) > 0 // Proteção
							aRetDados  := JurGetDados('NS0', 1, xFilial("NS0") + cDoc + cCodAtvEbi, {"NS0_CATIV", "NS0_CFASE", "NS0_CTAREF"}) // NS0_FILIAL+NS0_CDOC+NS0_COD
						Else
							cAtivEbill := JurGetDados('NS0', 1, xFilial("NS0") + cDoc + cCodAtvEbi, "NS0_CATIV") // NS0_FILIAL+NS0_CDOC+NS0_COD
						EndIf

						If !Empty(aRetDados) .And. Len(aRetDados) == 3
							cAtivEbill  := aRetDados[1]
							cFase       := aRetDados[2]
							cTarefa     := aRetDados[3]
						Else
							lLimpFase  := .T.
							lLimpTaref := .T.
						EndIf
					Else
						lLimpAtivE := .T.
						lLimpFase  := .T.
						lLimpTaref := .T.
					EndIf
				EndIf
			Else
				lLimpAtivE := .T.
				lLimpFase  := .T.
				lLimpTaref := .T.
			EndIf

	//---------------------------------------------------------//
	// Atividade Ebilling
	//---------------------------------------------------------//
	ElseIf lValid .And. Upper(cValid) == "ATIVEBI" .And. lAtvEbiChg

		If !Empty(cAtivEbill) .And. (lValid := JAEBILLCPO(cCliente, cLoja, , , cAtivEbill, lMsg, , .T.))
			If NS0->(ColumnPos("NS0_CFASE")) > 0 .And. NS0->(ColumnPos("NS0_CTAREF")) > 0 // Proteção
				aRetDados := JurGetDados('NS0', 2, xFilial('NS0') + cDoc + cAtivEbill, {"NS0_CFASE", "NS0_CTAREF"}) // NS0_FILIAL+NS0_CDOC+NS0_COD
			EndIf

			If !Empty(aRetDados) .And. Len(aRetDados) == 2
				cFase   := aRetDados[1]
				cTarefa := aRetDados[2]
			Else
				lLimpFase  := .T.
				lLimpTaref := .T.
			EndIf
		Else
			lLimpFase  := .T.
			lLimpTaref := .T.
		EndIf

	//---------------------------------------------------------//
	// Fase Ebilling
	//---------------------------------------------------------//
	ElseIf lValid .And. Upper(cValid) == "FASE"

		If Empty(cFase) .Or. (lValid := JAEBILLCPO(cCliente, cLoja, cFase,,, lMsg, , .T.))
			If !JurTrgEbil(cCliente, cLoja,;
			               @oAtivJur, @cAtivJur, @oDesAtivJ, @cDesAtivJ,;
			               @oAtivEbill, @cAtivEbill, @oDesAtivE, @cDesAtivE,;
			               @oFase, @cFase, @oDesFase, @cDesFase,;
			               @oTarefa, @cTarefa, @oDesTarefa, @cDesTarefa, "TAREF", .F.)
				lLimpTaref := .T.
			EndIf
		EndIf

	//---------------------------------------------------------//
	// Tarefa Ebilling
	//---------------------------------------------------------//
	ElseIf lValid .AND. Upper(cValid) == "TAREF"
		If !Empty(cTarefa)
			lValid := JAEBILLCPO(cCliente, cLoja, cFase, cTarefa, ,lMsg, , .T.)
		EndIf
	EndIf

	//---------------------------------------------------------//
	// Gatilhos
	//---------------------------------------------------------//
	If lValid
		If lLimpAtivJ .Or. Empty(cAtivJur)
			cAtivJur  := CriaVar('NRC_COD', .F.)
			cDesAtivJ := ""
		Else
			cDesAtivJ := JurGetDados('NRC', 1, xFilial('NRC') + cAtivJur, "NRC_DESC")
		EndIf

		If lLimpAtivE .Or. Empty(cAtivEbill)
			cAtivEbill := CriaVar('NS0_CATIV', .F.)
			cDesAtivE  := ""
		Else
			cDesAtivE  := JurGetDados("NS0", 2, xFilial("NS0") + cDoc + cAtivEbill, "NS0_DESC")
		EndIf

		If lLimpFase .Or. Empty(cFase)
			cFase    := CriaVar('NRY_CFASE', .F.)
			cDesFase := ""
		Else
			cDesFase := JurGetDados("NRY", 5, xFilial("NRY") + cFase, "NRY_DESC")
		EndIf

		If lLimpTaref .Or. Empty(cTarefa)
			cTarefa    := CriaVar('NRZ_CTAREF', .F.)
			cDesTarefa := ""
		Else
			NRY->( dbSetOrder( 1 ) )
			If NRY->( dbSeek( xFilial('NRY') + cDoc ) )

				While !NRY->( EOF() ) .AND. NRY->NRY_CDOC == cDoc
					If AllTrim(NRY->NRY_CFASE) == AllTrim(cFase)
						cCodSeqEbi := NRY->NRY_COD
						Exit
					Else
						cCodSeqEbi := ''
					EndIf

					NRY->( dbSkip() )
				EndDo

				cDesTarefa := JurGetDados("NRZ", 2, xFilial("NRZ") + cDoc + cCodSeqEbi + cTarefa, "NRZ_DESC")
			EndIf
		EndIf

		Iif(Empty(oAtivJur  ), Nil, oAtivJur:SetValue(cAtivJur, cAtivJur  ))
		Iif(Empty(oDesAtivJ ), Nil, oDesAtivJ:SetValue(cDesAtivJ))
		Iif(Empty(oAtivEbill), Nil, oAtivEbill:SetValue(cAtivEbill, cAtivEbill))
		Iif(Empty(oDesAtivE ), Nil, oDesAtivE:SetValue(cDesAtivE))
		Iif(Empty(oFase     ), Nil, oFase:SetValue(cFase, cFase))
		Iif(Empty(oDesFase  ), Nil, oDesFase:SetValue(cDesFase))
		Iif(Empty(oTarefa   ), Nil, oTarefa:SetValue(cTarefa, cTarefa))
		Iif(Empty(oDesTarefa), Nil, oDesTarefa:SetValue(cDesTarefa))
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRetPraz
Sugere a data final da participação confirme o prazo de validade da orignação
Funação para ser utilziada no campo Tipo de Originação e Data Inicio da
participação

@Param cCampo - Campo alterado: NU9_CTIPO / NU9_DTINI

@Return cData - Data final da participação ajustada

@author David Gonçalves Fernandes
@since 12/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurRetPraz(cTipo, dDataIni)
	Local dData  := CtoD('  /  /  ')
	Local nPrazo := 0

	If !Empty(ddataini) .AND. !Empty(cTipo)
		nPrazo := JurGetDados("NRI", 1, xFilial("NRI") + cTipo, "NRI_PRAZOV")
		If nPrazo > 0
			dData := DaySum(dDataIni, nPrazo)
		Else
			dData := DaySum(dDataIni, 1)
		EndIf
	EndIf

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} JURFlagLD
Ajusta flags dos lançamentos na pré-fatura, contrato e caso na
transferência de lançamentos via LegalDesk

@param  oModel,  objeto    , Modelo de dados do TS, Despesa ou LT
@param  cTable,  Caracatere, Alias do TS (NUE), Despesa (NVY) ou LT (NV4)
@param  cTabFat, Caracatere, Alias de faturamento do TS (NW0), Despesa (NVZ) ou LT (NW4)

@author Jonatas Martins
@since  25/03/2019
@obs    Função chamada nos BeforTTS nos modelos de TS, DESP ou LT
/*/
//-------------------------------------------------------------------
Function JURFlagLD(oModel, cTable, cTabFat)
	Local aArea      := GetArea()
	Local aAreaFat   := {}
	Local aRetDados  := {}
	Local lJURA202   := .F.
	Local lCobra     := .F.
	Local oModLanc   := Nil
	Local cIdModel   := ""
	Local cFlag      := ""
	Local cCodLanc   := ""
	Local cPrefat    := ""
	Local cClient    := ""
	Local cLoja      := ""
	Local cCaso      := ""
	Local cContr     := ""
	Local cJContr    := ""
	Local cContrAju  := ""
	Local cClientOld := ""
	Local cLojaOld   := ""
	Local cCasoOld   := ""
	Local cPrefatOld := ""
	Local cContrOld  := ""
	Local cJContrOld := ""
	Local nRecFat    := 0
	Local lOk        := .T.

	Default oModel  := Nil
	Default cTable  := ""
	Default cTabFat := ""

	//Se a operação estiver ocorrendo via REST - Integração com o Legal Desk
	If ValType(oModel) == "O"
		lJURA202  := oModel:GetId() == "JURA202"

		If cTable == "NUE"
			cIdModel := IIF(lJURA202, "NUEDETAIL", "NUEMASTER")
			cFlag    := "_TS"
		ElseIf cTable == "NVY"
			cIdModel := IIF(lJURA202, "NVYDETAIL", "NVYMASTER")
			cFlag    := "_DESP"
		Else
			cIdModel := IIF(lJURA202, "NV4DETAIL", "NV4MASTER")
			cFlag    := "_LANTAB"
		EndIf

		oModLanc := oModel:GetModel(cIdModel)
		cCodLanc := oModLanc:GetValue(cTable + "_COD")
		cPrefat  := oModLanc:GetValue(cTable + "_CPREFT")
		lCobra   := oModLanc:GetValue(cTable + "_COBRAR") == '1' .And. oModLanc:GetValue(cTable + "_SITUAC") == '1'

		If oModel:GetOperation() == MODEL_OPERATION_UPDATE
			cClientOld := (cTable)->(FieldGet(FieldPos(cTable + "_CCLIEN")))
			cLojaOld   := (cTable)->(FieldGet(FieldPos(cTable + "_CLOJA" )))
			cCasoOld   := (cTable)->(FieldGet(FieldPos(cTable + "_CCASO" )))
			cPrefatOld := (cTable)->(FieldGet(FieldPos(cTable + "_CPREFT" )))

			aRetDados := JurGetDados("NX0", 1, xFilial("NX0") + cPrefatOld, {"NX0_CCONTR", "NX0_CJCONT"})
			If Len(aRetDados) == 2
				cContrOld  := aRetDados[1]
				cJContrOld := aRetDados[2]
			EndIf

			aRetDados := J202BCntPf(cPrefatOld, cContrOld, cJContrOld, cClientOld, cLojaOld, cCasoOld)
			If Len(aRetDados) >= 3
				lOk := JurAjFlag(cPrefatOld, cClientOld, cLojaOld, cCasoOld, aRetDados[3], cFlag, cTable, cCodLanc, .F.) // Ajusta flag do contrato/caso antigo
			EndIf
		EndIf

		//Força o recálculo da pré-fatura para criação da NX2 - em situações onde não há TSs na pré-fatura do TS incluído
		If lOk .And. lCobra .And. !Empty(cPrefat)
			cClient  := oModLanc:GetValue(cTable + "_CCLIEN")
			cLoja    := oModLanc:GetValue(cTable + "_CLOJA")
			cCaso    := oModLanc:GetValue(cTable + "_CCASO")

			aRetDados := JurGetDados("NX0", 1, xFilial("NX0") + cPrefat, {"NX0_CCONTR", "NX0_CJCONT"})
			If Len(aRetDados) == 2
				cContr  := aRetDados[1]
				cJContr := aRetDados[2]
			EndIf

			aRetDados  := J202BCntPf(cPrefat, cContr, cJContr, cClient, cLoja, cCaso)
			If Len(aRetDados) >= 3
				cContrAju := aRetDados[3]
			EndIf

			lOk := JurAjFlag(cPrefat, cClient, cLoja, cCaso, cContrAju, cFlag, cTable, cCodLanc, .T.) // Ajusta flag do contrato/caso novo

			// Ajusta tabela de faturamento do lançamento
			If lOk .And. !Empty(cTabFat)
				nRecFat := JRecLancFt(cTabFat, cCodLanc, cPreFat)

				If nRecFat > 0
					aAreaFat := (cTabFat)->(GetArea())
					(cTabFat)->(DbGoTo(nRecFat))
					RecLock(cTabFat, .F.)
					(cTabFat)->(FieldPut(FieldPos(cTabFat + "_CCLIEN"), cClient))
					(cTabFat)->(FieldPut(FieldPos(cTabFat + "_CLOJA") , cLoja))
					(cTabFat)->(FieldPut(FieldPos(cTabFat + "_CCONTR"), cContrAju))
					(cTabFat)->(FieldPut(FieldPos(cTabFat + "_CCASO") , cCaso))
					(cTabFat)->(MsUnlock())
					RestArea(aAreaFat)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JRecLancFt
Função que localiza o registro não cancelado de faturamento do lançamento

@param  cTabFat , Caracatere, Alias de faturamento do TS (NW0), Despesa (NVZ) ou LT (NW4)
@param  cCodLanc, Caracatere, Código do TS, Despesa ou LT
@param  cPreFat , Caracatere, Código da Pré-Fatura

@return nRecFat , numerico  , Recno do lançamento na tabela de faturamento

@author Jonatas Martins
@since  25/03/2019
/*/
//-------------------------------------------------------------------
Static Function JRecLancFt(cTabFat, cCodLanc, cPreFat)
	Local cQuery   := ""
	Local cCpoLanc := ""
	Local aRecFat  := {}
	Local nRecFat  := 0

	Do Case
		Case cTabFat == "NW0"
			cCpoLanc := "NW0_CTS"
		Case cTabFat == "NVZ"
			cCpoLanc := "NVZ_CDESP"
		OtherWise
			cCpoLanc := "NW4_CLTAB"
	End Case

	cQuery := "SELECT R_E_C_N_O_ RECTABFAT"
	cQuery +=  " FROM " + RetSqlName(cTabFat)
	cQuery += " WHERE " + cTabFat + "_FILIAL = '" + xFilial(cTabFat) + "' "
	cQuery +=   " AND " + cCpoLanc + " = '" + cCodLanc + "' "
	cQuery +=   " AND " + cTabFat + "_SITUAC = '1' "
	cQuery +=   " AND " + cTabFat + "_PRECNF = '" + cPrefat + "' "
	cQuery +=   " AND " + cTabFat + "_CANC = '2' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aRecFat := JurSQL(cQuery, "RECTABFAT")

	If Len(aRecFat) == 1
		nRecFat := aRecFat[1][1]
	EndIf

	JurFreeArr(aRecFat)

Return (nRecFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} JPELancLote
Ponte de entrada que define se o processamento dos modelos de
lançamentos de LT, DESP ou TS é executado em lote.

@Param   cIdModel, caractere, Identificaçãod do modelo de dados
@Param   nOper   , numerico , Operação do modelo

@Return  lLote, logico, Se .T. define que é um processamento em lote

@author  Jonatas Martins
@since   22/04/16
@version 1.0
@obs     Função chamada nas rotinas JA027CM, JA049CM e JA144CM
/*/
//-------------------------------------------------------------------
Function JPELancLote(cIdModel, nOper)
	Local lPERotLote := ExistBlock("JExecLote")
	Local aUserFunc  := {}
	Local nFunc      := 0
	Local nLenFunc   := 0
	Local cUserFunc  := ""
	Local lLote      := .F.

	Default cIdModel := ""
	Default nOper    := 0

	If lPERotLote
		aUserFunc := ExecBlock("JExecLote", .F., .F., {cIdModel, nOper})
		If ValType(aUserFunc) == "A" .And. !Empty(aUserFunc)
			nLenFunc := Len(aUserFunc)
			For nFunc := 1 To nLenFunc
				cUserFunc := UPPER(AllTrim(aUserFunc[nFunc]))
				If ValType(cUserFunc) == "C" .And. !Empty(cUserFunc)
					cUserFunc := IIF(SubStr(cUserFunc, 1, 2) == "U_", cUserFunc, "U_" + cUserFunc)
					If FWIsInCallStack(cUserFunc)
						lLote := .T.
						Exit
					EndIf
				EndIf
			Next nFunc
		EndIf
	EndIf

Return (lLote)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldAcLd
Valida o preenchimento das informações necessárias para as ações do
Legal Desk no lançamento. 1-Retirar e o 6-Vincular

@Param oModel   - Modelo completo do lançamento
@Param cIDField - Id do modelo parcial do field
@Param cTab     - Tabela de dados
@Param oTabTmp  - Tabela Temporária do Lançamento

@Return lRet    - Se está correto o preenchimento do LD para a ação informada

@author Cristina Cintra / Jorge Martins
@since 18/04/2019
/*/
//-------------------------------------------------------------------
Function JurVldAcLd(oModel, cIDField, cTab, oTabTmp)
	Local lRet        := .T.
	Local cBoxAcao    := ""
	Local oModelFld   := oModel:GetModel(cIDField)
	Local nOpc        := oModel:GetOperation()
	Local cCpoAcaoLD  := cTab + "_ACAOLD"
	Local cCpoPreFt   := cTab + "_CPREFT"
	Local cPreFtBd    := (cTab)->(FieldGet(FieldPos(cCpoPreFt)))
	Local cPreFtMdl   := oModelFld:GetValue(cCpoPreFt)
	Local cAcaoLd     := oModelFld:GetValue(cCpoAcaoLD)
	Local cSolucao    := ""
	Local cSituac     := ""
	Local cPreftSit   := ""

	Default oTabTmp   := Nil

	If cAcaoLd == "1" .And. nOpc == MODEL_OPERATION_UPDATE .And. !Empty(cPreFtBd)
		cPreftSit := cPreFtBd

	ElseIf cAcaoLd == "6" .And. !Empty(cPreFtMdl)
		cPreftSit := cPreFtMdl
	EndIf

	If !Empty(cPreftSit)
		cSituac := JurGetDados("NX0", 1, xfilial("NX0") + cPreftSit, "NX0_SITUAC")

		If !(cSituac $ "C|F")
			lRet := JurMsgErro(i18N(STR0290, {cSituac, cPreftSit}),,; // "Situação '#1' da pré-fatura '#2', não permite vincular ou retirar lançamentos."
			           i18n(STR0291, {"C", "F"}) ) // "Essa alteração é permitida apenas para as situações da pré-fatura: '#1' e '#2'"
		EndIf
	EndIf

	If lRet
		If cAcaoLd == "6" // Vincular
			If nOpc == MODEL_OPERATION_UPDATE .And. !Empty(cPreFtBd) .And. cPreFtBd != cPreFtMdl
				lRet := JurMsgErro(STR0274,, STR0275) // "O Lançamento já se encontra vinculado a uma pré-fatura!" # "Retire o Lançamento da pré-fatura em que ele se encontra para fazer um novo vínculo."
			EndIf

			If lRet
				If Empty(cPreFtMdl)
					lRet := JurMsgErro(STR0270,,;                                     // "Para vincular um lançamento é obrigatório informar o destino do mesmo."
							i18n(STR0271, {AllTrim(RetTitle(cCpoPreFt))})) // "Informe o campo '#1'."
				Else
					// Realiza as validações necessárias para o vínculo do lançamento na pré-fatura
					lRet := JVldVinPre(oModelFld, cTab, @oTabTmp)
				EndIf
			EndIf

		ElseIf !Empty(cAcaoLd) .And. cAcaoLd != "1"
			cBoxAcao := JurInfBox(cCpoAcaoLD, cAcaoLd, "3")
			cSolucao := i18n(STR0276, {JurInfBox(cCpoAcaoLD, "1", "3"), JurInfBox(cCpoAcaoLD, "6", "3")}) // "Estão disponíveis apenas as ações 1 - Retirar e 6 - Vincular"

			lRet     := JurMsgErro(i18n(STR0272, {cBoxAcao}), , cSolucao) // "Ação '#1' não está disponível nesta rotina."
		EndIf
	EndIf

	If lRet .And. cAcaoLd != "6"
		If (nOpc == MODEL_OPERATION_UPDATE .And. !(cPreFtMdl == cPreFtBd));
		    .Or. (nOpc == MODEL_OPERATION_INSERT .And. !Empty(cPreFtMdl))
			lRet := JurMsgErro(STR0277, , STR0278) // "Não é permitido alterar a pré-fatura do lançamento." # "Indique uma pré-fatura somente em situações de vínculo (NUE_ACAOLD = '6')."
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTmpMdl
Cria uma tabela temporária com base em um modelo ativo com os campos
já preenchidos.

@Param oModel     - Modelo de dados para criação da tabela temporária
@Param aFldNotVld - Campos que não devem ser preenchidos

@Return oTmpTable - Objeto da tabela temporária

@author Jorge Martins / Bruno Ritter
@since 22/04/2019
/*/
//-------------------------------------------------------------------
Function JurTmpMdl(oModel, aFldNotVld)
Local oStruct   := oModel:GetStruct()
Local cTable    := oStruct:GetTable()[1]
Local aFields   := oStruct:GetFields()
Local cQuery    := ""
Local aTemp     := {}
Local oTmpTable := Nil
Local cAliasTmp := ""
Local nFld      := 0
Local cField    := ""
Local lVirtual  := .T.
Local cType     := ""
Local xValue    := Nil

Default aFldNotVld := {}

cQuery     := "SELECT * FROM " + RetSQLName(cTable) + " " + cTable + " WHERE 1=2"
aTemp      := JurCriaTmp(GetNextAlias(), cQuery, cTable, , , , , , .F.)
oTmpTable  := aTemp[1]
cAliasTmp  := oTmpTable:GetAlias()

RecLock(cAliasTmp, .T.)

For nFld := 1 To Len(aFields)
	cField   := aFields[nFld][3]
	lVirtual := aFields[nFld][14]
	cType    := aFields[nFld][4]
	xValue   := oModel:GetValue(cField)

	If !lVirtual .And. cType != "M" .And. aScan(aFldNotVld, {|cFldNotVld| cField == cFldNotVld } ) == 0
		(cAliasTmp)->( FieldPut( FieldPos( cField ), xValue ) )
	EndIf
Next

(cAliasTmp)->(MsUnlock())
(cAliasTmp)->(DbCommit())

Return oTmpTable

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAjFlag
Ajusta flags que indicam se existem lançamento na pré-fatura (NX0, NX8 e NX1)

@param cPrefat   , Pré-fatura
@param cClient   , Cliente
@param cLoja     , Loja
@param cCaso     , Caso
@param cContr    , Contrato
@param cFlag     , Campo de flag sem prefixo
@param cTable    , Tabela do lançamento
@param cCodLanc  , Código do Lançamento
@param lInclui   , Indica se o lançamento deve ser incluido/vinculado em pré-fatura

@author Bruno Ritter / Jorge Martins
@since  24/04/2019
/*/
//-------------------------------------------------------------------
Static Function JurAjFlag(cPrefat, cClient, cLoja, cCaso, cContr, cFlag, cTable, cCodLanc, lInclui)
	Local aArea      := GetArea()
	Local aAreaNX1   := NX1->(GetArea())
	Local aAreaNX8   := NX8->(GetArea())
	Local aAreaNX0   := NX0->(GetArea())
	Local cExistNX1  := Iif(lInclui, "1", "2") // 1= Sim, 2 = Não
	Local cExistNX8  := "1" // 1= Sim, 2 = Não
	Local cExistNX0  := "1" // 1= Sim, 2 = Não
	Local lRet       := .F.
	Local cQuery     := ""

	// Ajusta a flag no caso
	NX1->(dbSetOrder(1)) // NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
	If NX1->(DbSeek(xFilial("NX1") + cPrefat + cClient + cLoja + cContr + cCaso))
		If cExistNX1 == "2"
			cQuery := " SELECT COUNT(R_E_C_N_O_) TEMLANC "
			cQuery +=   " FROM " + RetSqlName(cTable) + " "
			cQuery += " WHERE " + cTable + "_FILIAL = '" + xFilial(cTable) + "' "
			cQuery +=   " AND " + cTable + "_CCLIEN = '" + cClient + "' "
			cQuery +=   " AND " + cTable + "_CLOJA = '"  + cLoja + "' "
			cQuery +=   " AND " + cTable + "_CCASO = '"  + cCaso + "' "
			cQuery +=   " AND " + cTable + "_COD <> '"   + cCodLanc + "' "
			cQuery +=   " AND " + cTable + "_CPREFT = '" + cPrefat + "' "
			cQuery +=   " AND D_E_L_E_T_ = ' ' "

			cExistNX1 := Iif(JurSql(cQuery, "TEMLANC")[1][1] > 0, "1", "2")
		EndIf

		RecLock("NX1", .F.)
		NX1->(FieldPut(FieldPos("NX1" + cFlag), cExistNX1))
		NX1->(MsUnlock())

		// Ajusta a flag no contrato
		If cExistNX1 == "2"
			cQuery := " SELECT MIN(NX1.NX1" + cFlag + ") TEMNX1 "
			cQuery += " FROM " + RetSqlName("NX1") + " NX1 "
			cQuery += " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
			cQuery +=   " AND NX1.NX1_CPREFT = '" + cPrefat + "' "
			cQuery +=   " AND NX1.D_E_L_E_T_ = ' ' "

			cExistNX8 := JurSql(cQuery, "TEMNX1")[1][1]
		EndIf

		NX8->(DbSetOrder(1)) // NX8_FILIAL+NX8_CPREFT+NX8_CCONTR
		If NX8->(DbSeek(xFilial("NX8") + cPrefat + cContr))
			RecLock("NX8", .F.)
			NX8->(FieldPut(FieldPos("NX8" + cFlag), cExistNX8))
			NX8->(MsUnlock())
		EndIf

		// Ajusta a flag na pré-fatura
		If cExistNX8 == "2"
			cQuery := " SELECT MIN(NX8.NX8" + cFlag + ") TEMNX8 "
			cQuery += " FROM " + RetSqlName("NX8") + " NX8 "
			cQuery += " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
			cQuery +=   " AND NX8.NX8_CPREFT = '" + cPrefat + "' "
			cQuery +=   " AND NX8.D_E_L_E_T_ = ' ' "

			cExistNX0 := JurSql(cQuery, "TEMNX8")[1][1]
		EndIf

		NX0->(dbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC
		If NX0->(DbSeek(xFilial("NX0") + cPrefat))
			RecLock("NX0", .F.)
			NX0->(FieldPut(FieldPos("NX0" + cFlag), cExistNX0))
			NX0->(MsUnlock())
		EndIf

		lRet := .T.
	EndIf

	RestArea(aAreaNX0)
	RestArea(aAreaNX8)
	RestArea(aAreaNX1)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURFWCotac
Função para chamada da gravação da fila de sincronização da cotação 
posicionada na SM2 ou do recno informado.
Usado na telinha de Cotação de abertura do Protheus, chamado na LIB.

@Param nRecnoSM2   Recno da Cotação SM2

@Return Nil

@author Cristina Cintra
@since 14/05/2019
/*/
//-------------------------------------------------------------------
Function JURFWCotac(nRecnoSM2)
Local cData       := ""

Default nRecnoSM2 := 0

If SuperGetMV("MV_JFSINC", .F., "2") == "1" .And. FindFunction("J170GRAVA")

	If nRecnoSM2 > 0
		SM2->(DbGoto(nRecnoSM2))
	EndIf

	cData := DToS(SM2->M2_DATA)
	If !Empty(cData)
		J170GRAVA("SM2", cData, "3")
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldUxP
Função para validar a existência de participante relacionado ao usuário
logado, que esteja ativo e sem data de demissão preenchida.

@param  oModel  Modelo ativo

@return lRet  .T. para caso exista 
              .F. caso não exista ou tenha alguma inconsistência

@author Cristina Cintra
@since 05/08/2019
/*/
//-------------------------------------------------------------------
Function JurVldUxP(oModel)
Local lRet      := .T.
Local cPart     := JurUsuario(__CUSERID)
Local cProblema := ""
Local cSolucao  := ""
Local aPartInfo := {}
Local lView     := .F.

Default oModel  := Nil

If ValType( oModel ) == 'O'
	lView := oModel:GetOperation() == MODEL_OPERATION_VIEW // Visualização
EndIf

If !lView // Só valida em operações de inclusão, alteração, exclusão ou abertura de tela
	If Empty(cPart)
		cProblema := STR0279 // "Não foi possível abrir a rotina, pois o usuário logado não está vinculado a um participante."
		cSolucao  := STR0280 // "Associe seu usuário a um participante para ter acesso a operação."
	Else
		aPartInfo := JurGetDados("RD0", 1, xFilial("RD0") + cPart, {"RD0_MSBLQL", "RD0_DTADEM"})
		If aPartInfo[1] != "2"
			cProblema := STR0281 // "Não foi possível abrir a rotina, pois o usuário logado está vinculado a um participante inativo."
			cSolucao  := STR0282 // "Associe seu usuário a um participante ativo para ter acesso a operação."
		ElseIf !Empty(aPartInfo[2])
			cProblema := STR0283 // "Não foi possível abrir a rotina, pois o usuário logado está vinculado a um participante com data de demissão preenchida."
			cSolucao  := STR0284 // "Associe seu usuário a um participante não demitido para ter acesso a operação."
		EndIf
	EndIf

	If !Empty(cProblema)
		lRet := JurMsgErro(cProblema,, cSolucao)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetTabRat
Função para gatilhar a tabela de rateio relacionada a natureza. Se o
se não for chamado das rotinas de desdobramento ou lançamento mantém
o valor antigo caso já esteja preenchido.

@param cNatureza , Código da natureza
@param cTabRatAtu, Código da tabela de rateio atual

@return cTabRat  , Código da tabela de rateio vinculada a natureza

@author Jonatas Martins
@since  13/08/2019
@obs    Função utilizada no dicionário X7_REGRA
/*/
//-------------------------------------------------------------------
Function JGetTabRat(cNatureza, cTabRatAtu)
	Local oModel  := Nil
	Local lSetVal := .F.

	Default cNatureza  := ""
	Default cTabRatAtu := ""

	If !Empty(cNatureza)
		oModel  := FWModelActive()
		lSetVal := IIF(ValType(oModel) <> "O", .F., oModel:GetID() $ "JURA241|JURA246|JURA247|JURA281")
		If Empty(cTabRatAtu) .Or. lSetVal
			cTabRatAtu := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_RATJUR")
		EndIf
	EndIf

Return (cTabRatAtu)

//-------------------------------------------------------------------
/*/{Protheus.doc} JAjusNfe
Função que chama a gravação do número da Nota Fiscal Eletrônica em 
entidades do SIGAPFS, a partir do E1_NFELETR.
Usado na Fis022Upd - FISA022.

@param nRecSE1   Recno da SE1 que está sendo alterado o campo E1_NFELETR.
@param cNfEletr  Código da NFS-e (conteúdo do campo E1_NFELETR).

@return Nil

@author Cristina Cintra
@since  17/10/2019
/*/
//-------------------------------------------------------------------
Function JAjusNfe(nRecSE1, cNfEletr)
Local cLink      := ""

Default nRecSE1  := 0
Default cNfEletr := ""

If FWAliasInDic("OHH") .And. FWAliasInDic("NS7") .And. FWAliasInDic("NXA") .And. nRecSE1 > 0 

	// Ajusta o campo OHH_NFELET com o número da NFS-e 
	If OHH->(ColumnPos("OHH_NFELET")) > 0
		J255AjNfe(nRecSE1)
	EndIf
	
	If !Empty(cNfEletr) 
	
		// Busca o link da NFS-e
		If ChkFile("SPED051")
			cLink := JLinkNfe(cNfEletr)
		EndIf
		
		// Busca fórmula e compõe o link da NFS-e com base em campo no Escritório (NS7)
		If Empty(cLink) .And. NS7->(ColumnPos("NS7_LINKNF")) > 0
			cLink := JLinkNfEsc(nRecSE1)
		EndIf
		
	EndIf

	// Grava o link e o número da NFS-e na Fatura
	If NXA->(ColumnPos("NXA_NFELET")) > 0
		JGrvNfeFat(nRecSE1, cNfEletr, cLink)
	EndIf
	
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JLinkNfe
Função que busca o link da NFS-e (campo LINK_NFSE) na SPED051.
Na SPED051, B.F2_SERIE || B.F2_DOC = A.NFSE_ID e o NFSE é o 
código da NFS-e.

@param cNfEletr  Código da NFS-e (conteúdo do campo E1_NFELETR).

@return cLink    Link da NFS-e

@author Cristina Cintra
@since  18/10/2019
/*/
//-------------------------------------------------------------------
Static Function JLinkNfe(cNfEletr)
Local cQry  := ""
Local aQry  := {}
Local cLink := ""

cQry := "SELECT LINK_NFSE LINK FROM SPED051 "
cQry +=  " WHERE NFSE = '" + cNfEletr + "' AND D_E_L_E_T_ = ' ' "

aQry := JurSQL(cQry, "LINK")

If !Empty(aQry)
	cLink := Alltrim(aQry[1][1])
EndIf

Return cLink

//-------------------------------------------------------------------
/*/{Protheus.doc} JLinkNfEsc
Busca fórmula e compõe o link da NFS-e com base em campo no Escritório (NS7).

@param  nRecSE1  Recno da SE1

@return cLink    Link da NFS-e

@author Cristina Cintra
@since  21/10/2019
/*/
//-------------------------------------------------------------------
Static Function JLinkNfEsc(nRecSE1)
Local nRecOld   := SE1->(Recno())
Local aArea     := GetArea()
Local cLink     := ""
Local cEscrit   := ""
Local cChvFatur := ""

SE1->(dbGoTo(nRecSE1))
cChvFatur := Substr(StrTran(SE1->E1_JURFAT, "-", ""), 1, TamSX3("NXA_FILIAL")[1] + TamSX3("NXA_CESCR")[1] + TamSX3("NXA_COD")[1])
cEscrit   := Substr(cChvFatur, TamSX3("NXA_FILIAL")[1] + 1, TamSX3("NXA_CESCR")[1])
cFormLink := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_LINKNF")

If !Empty(cFormLink)
	cLink := JTrtLinkNf(cFormLink, cChvFatur)
EndIf

SE1->(dbGoTo(nRecOld))
RestArea(aArea)

Return cLink

//-------------------------------------------------------------------
/*/{Protheus.doc} JGrvNfeFat
Grava o número e o link de acesso da NFS-e na Fatura correspondente.

@param  nRecSE1  Recno da SE1 (usado para encontrar a fatura relacionada)
@param cNfEletr  Código da NFS-e (conteúdo do campo E1_NFELETR)
@param cLink     Link de acesso a NFS-e

@return Nil

@author Cristina Cintra
@since  21/10/2019
/*/
//-------------------------------------------------------------------
Static Function JGrvNfeFat(nRecSE1, cNfEletr, cLink)
Local nRecOld   := SE1->(Recno())
Local aArea     := GetArea()
Local cChvFatur := ""

SE1->(dbGoTo(nRecSE1))
cChvFatur := Substr(StrTran(SE1->E1_JURFAT, "-", ""), 1, TamSX3("NXA_FILIAL")[1] + TamSX3("NXA_CESCR")[1] + TamSX3("NXA_COD")[1])

NXA->(dbSetOrder(1)) //NXA_FILIAL + NXA_CESCR + NXA_COD
If NXA->(DbSeek(cChvFatur))
	RecLock("NXA", .F.)
	NXA->NXA_NFELET := cNfEletr
	NXA->NXA_LINKNF := cLink
	NXA->(MsUnlock())
	NXA->(DbCommit())
EndIf

SE1->(dbGoTo(nRecOld))
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrtLinkNf
Macro substitui os campos da fórmula para geração do link da NFS-e
constante no escritório.
Preparada apenas para macro substituir campos da NXA, SF2 e NS7.

@param  cFormLink  Fórmula para geração do link
@param  cChvFatur  Chave da fatura para posicionamento

@return cFormLink  Link da NFS-e

@author Cristina Cintra
@since 21/10/2019
/*/
//-------------------------------------------------------------------
Static Function JTrtLinkNf(cFormLink, cChvFatur)
Local aArea       := GetArea()
Local nRecOldNXA  := NXA->(Recno())
Local nRecOldNS7  := NS7->(Recno())
Local nRecOldSF2  := SF2->(Recno())
Local cVar        := ""
Local cLink       := cFormLink
Local cRetForm    := ""
Local cTabela     := ""
Local nPosCpo     := 0

NXA->(dbSetOrder(1)) // NXA_FILIAL + NXA_CESCR + NXA_COD
If NXA->(DbSeek(cChvFatur))

	NS7->(dbSetOrder(1)) // NS7_FILIAL+NS7_COD
	NS7->(DbSeek(xFilial("NS7") + NXA->NXA_CESCR))
	
	SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	SF2->(DbSeek(xFilial("SF2") + NXA->NXA_DOC + NXA->NXA_SERIE + NXA->NXA_CLIPG + NXA->NXA_LOJPG))

	While RAt("#@", cLink) > 0

		cRetForm := "" 
		cVar     := Upper( Substr(cLink, At("@#", cLink) + 2, At("#@", cLink) - ( At("@#", cLink) + 2 )))
		
		If !Empty(cVar) .And. Left(cVar, 1) != "|"

			cTabela := SubStr(cVar, 1, At("_", cVar) - 1)
			If Len(cTabela) == 2
				cTabela := "S" + cTabela
			EndIf

			If FWAliasInDic(cTabela)
				nPosCpo := (cTabela)->(FieldPos(cVar))
			Else
				nPosCpo := 0
			EndIf
                              
			If nPosCpo > 0
				cRetForm := cValToChar((cTabela)->(FieldGet(nPosCpo)))
			EndIf
	    ElseIf !Empty(cVar) .And. Left(cVar, 1) == "|"	 
			cRetForm  := &(Substr(cVar, 2)) //#@|Substr(SF2->F2_CODNFE,'-','')#@ Exemplo de Codigo 	
		EndIf

	    cLink := Substr(cLink, 1, At("@#", cLink) - 1) + Alltrim(cRetForm) + Substr(cLink, At("#@", cLink) + 2)
	EndDo

EndIf

SF2->(dbGoTo(nRecOldSF2))
NS7->(dbGoTo(nRecOldNS7))
NXA->(dbGoTo(nRecOldNXA))

RestArea(aArea)

Return Alltrim(cLink)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTxtDesp
Busca o texto padrão do Tipo de Despesa, de acordo com o idioma do Caso.

@param  cIdModel   Id do modelo

@return cTextoPad  Texto padrão do Tipo de Despesa

@author Jonatas Martins
@since 25/10/2019
/*/
//------------------------------------------------------------
Function JurTxtDesp(cIdModel)
	Local aArea      := GetArea()
	Local aAreaNVE   := NVE->(GetArea())
	Local aAreaNR4   := NR4->(GetArea())
	Local oModel     := Nil
	Local oSubModel  := Nil
	Local cTab       := ""
	Local cCpoCli    := ""
	Local cCpoLoja   := ""
	Local cCpoCaso   := ""
	Local cCpoTpDesp := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cCaso      := ""
	Local cTpDesp    := ""
	Local cTextoPad  := ""

	Default cIdModel := ""

	If !Empty(cIdModel)
		oModel     := FWModelActive()
		oSubModel  := oModel:GetModel(cIdModel)
		cTab       := Substr(cIdModel, 1, 3) // OHB - OHF - OHG
		cCpoCli    := IIF(cIdModel == "OHBMASTER", "OHB_CCLID" , cTab + "_CCLIEN")
		cCpoLoja   := IIF(cIdModel == "OHBMASTER", "OHB_CLOJD" , cTab + "_CLOJA" )
		cCpoCaso   := IIF(cIdModel == "OHBMASTER", "OHB_CCASOD", cTab + "_CCASO" )
		cCpoTpDesp := IIF(cIdModel == "OHBMASTER", "OHB_CTPDPD", cTab + "_CTPDSP")
		cCliente   := oSubModel:GetValue(cCpoCli)
		cLoja      := oSubModel:GetValue(cCpoLoja)
		cCaso      := oSubModel:GetValue(cCpoCaso)
		cTpDesp    := oSubModel:GetValue(cCpoTpDesp)
		
		If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso)
			NVE->(DbSetOrder(1)) // NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS + NVE_SITUAC
			If NVE->(DbSeek(xFilial("NVE") + cCliente + cLoja + cCaso)) .And. !Empty(NVE->NVE_CIDIO) // Idioma do caso
	
				NR4->(DbSetOrder(3)) // NR4_FILIAL + NR4_CTDESP + NR4_CIDIOM
				If NR4->(DbSeek(xFilial("NR4") + cTpDesp + NVE->NVE_CIDIO))
					If NR4->(ColumnPos("NR4_TXTPAD")) > 0 .And. !Empty(NR4->NR4_TXTPAD) // Proteção
						cTextoPad := NR4->NR4_TXTPAD
					Else
						cTextoPad := AllTrim(NR4->NR4_DESC)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNR4 )
	RestArea( aAreaNVE )
	RestArea( aArea )

Return (cTextoPad)

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldVinPre
Valida a possibilidade do vínculo na pré-fatura informada.

@Param oModelLan - Modelo de dados do lançamento
@Param cTab      - Tabela de dados
@Param oTmpLanc  - Tabela temporária para vínculo do lançamento na Pré via LD

@Return lRet     - Se é permitido o vínculo do TS na pré informada

@author Cristina Cintra
@since 18/04/2019
/*/
//-------------------------------------------------------------------
Static Function JVldVinPre(oModelLan, cTab, oTmpLanc)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local dDIniLanc := StoD("  /  /    ")
	Local dDFimLanc := StoD("  /  /    ")
	Local cSituac   := ""
	Local cTpHon    := ""
	Local aInfoNRA  := {}
	Local lCobraH   := .F.
	Local lCobraF   := .F.
	Local lAtivNaoC := .F.
	Local lVincNaoC := .F.
	Local lVincTS   := .F.
	Local cCpoPreFt := cTab + "_CPREFT"
	Local cProblema := STR0308 // "Não é possível víncular o Time-Sheet a essa pré-fatura." 
	Local cSolucao  := STR0309 // "Por favor verifique."

	Local cCodLanc  := oModelLan:GetValue(cTab + "_COD")
	Local cPreFat   := oModelLan:GetValue(cCpoPreFt)
	Local cClien    := oModelLan:GetValue(cTab + "_CCLIEN")
	Local cLoja     := oModelLan:GetValue(cTab + "_CLOJA")
	Local cAtiv     := ""
	Local dDataLanc := StoD("  /  /    ")

	Local oTmpReg    := Nil
	Local cNameTmp   := ""
	Local aTmpLancLD := {}
	Local cAlsLancLD := ""

	Default oTmpLanc := Nil

	dbSelectArea("NX0")
	NX0->(dbSetOrder(1)) //NX0_FILIAL+NX0_COD+NX0_SITUAC

	If NX0->(dbSeek(xFilial('NX0') + cPreFat))

		Do Case
			Case cTab == "NUE"
				dDataLanc := oModelLan:GetValue("NUE_DATATS")
				cAtiv     := oModelLan:GetValue("NUE_CATIVI")
				dDIniLanc := NX0->NX0_DINITS
				dDFimLanc := NX0->NX0_DFIMTS
				lAtivNaoC := SuperGetMV('MV_JURTS4',, .F. ) // Zera o tempo revisado de atividades nao cobraveis
				lVincNaoC := SuperGetMV('MV_JTSNCOB',, .F.) // Indica se vincula TS não cobrável na pré-fatura e fatura
				lVincTS   := SuperGetMv('MV_JVINCTS ',,.T.) // Vinc TS em contrato Fixo

			Case cTab == "NVY"
				dDataLanc := oModelLan:GetValue("NVY_DATA")
				dDIniLanc := NX0->NX0_DINIDP
				dDFimLanc := NX0->NX0_DFIMDP

			Case cTab == "NV4"
				dDataLanc := oModelLan:GetValue("NV4_DTCONC")
				dDIniLanc := NX0->NX0_DINITB
				dDFimLanc := NX0->NX0_DFIMTB
		EndCase

		cSituac := NX0->NX0_SITUAC

		If cSituac $ ("C|F") .And. ( !Empty(dDIniLanc) .And. !Empty(dDFimLanc) )
			If (dDataLanc >= dDIniLanc) .And. (dDataLanc <= dDFimLanc)

				If cTab == "NUE" .And. !lAtivNaoC .And. !lVincNaoC .And. JurGetDados("NRC", 1, xFilial("NRC") + cAtiv, "NRC_TEMPOZ") != "1"
					lRet := JurMsgErro(STR0295, , STR0296) // "O Time Sheet não pode ser vinculado na pré-fatura, pois não é cobrável." #  "Verifique o parâmetro 'MV_JURTS4'."
				EndIf

				// Verifica se o Caso está na pré-fatura ou pode ser vinculado
				If lRet .And. cTab == "NUE"
					NX1->(dbSetOrder(1)) //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
					If NX1->( dbSeek( xFilial( 'NX1' ) + cPreFat + cClien + cLoja ) )
						While !NX1->( EOF() ) .And. cPreFat == NX1->NX1_CPREFT .And. ;
						                            cClien  == NX1->NX1_CCLIEN .And. ;
						                            cLoja   == NX1->NX1_CLOJA
							cTpHon   := JurGetDados("NX8", 1, xFilial("NX8") + cPreFat + NX1->NX1_CCONTR, "NX8_CTPHON")
							aInfoNRA := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, {"NRA_COBRAH", "NRA_COBRAF"}) // Tipo de Honorários
							lCobraH  := aInfoNRA[1] == "1" // Cobra Hora
							lCobraF  := aInfoNRA[2] == "1" // Cobra Fixo

							If lCobraH // Cobra Hora
								lRet := .T.
							Else
								lRet := .F.
								
								If lCobraF // Cobra Fixo
									If JurGetDados("NT0", 1, xFilial("NT0") + NX1->NX1_CCONTR, "NT0_FIXEXC") == "1" // Fixo e Excedente
										lRet := .T.
									Else
										If lVincTS // Permite Vínculo de TS em contrato Fixo e encontrou uma parcela
											lRet := !Empty(JurGetDados("NT1", 3, xFilial("NT1") + cPreFat + NX1->NX1_CCONTR, "NT1_PARC"))
										EndIf
										IIf(!lRet, cSolucao := STR0311, Nil) // "Verifique se é permitido vínculo de TS em contrato de fixo (parâmetro MV_JVINCTS) e se existe parcela vínculada a pré-fatura."
									EndIf
								EndIf
							EndIf

							If lRet
								Exit
							Else
								NX1->( dbSkip() )
							EndIf
						EndDo

						If !lRet
							JurMsgErro(cProblema,, cSolucao)
						EndIf
					EndIf
				EndIf

			Else
				lRet := JurMsgErro(STR0310,, STR0309) //"O período de Time Sheets na pré-fatura não contempla a data do Time Sheet." "Por favor verifique."
			EndIf

			If lRet
				// Cria uma tabela temporária com o lançamento que está sendo incluído via LD
				oTmpReg   := JurTmpMdl(oModelLan, {cCpoPreFt})
				cNameTmp  := oTmpReg:GetRealName()

				// Executa o filtro da opção "NOVOS" da pré na tabela temporária
				// E valida se o Lançamento que está sendo incluído poderá ser vinculado na pré-fatura
				// Será criada outra tabela temporária com o retorno da função J202Filtro
				aTmpLancLD := J202Filtro(cTab, cCodLanc, cPreFat, cNameTmp)

				oTmpReg:Delete() // Deleta a primeira tabela temporária
				
				If ValType(aTmpLancLD[1]) == "A" // Não cria tabela temporária
					If Empty(aTmpLancLD[1]) // Se não retornar o registro, indica que o Lançamento não pode ser vinculado na pré-fatura
						lRet := JurMsgErro(STR0285,, STR0286) //"Não é possível víncular o Lançamento a essa pré-fatura." "Por favor verifique."
					EndIf
				Else
					oTmpLanc   := aTmpLancLD[1]
					cAlsLancLD := oTmpLanc:GetAlias()
					If (cAlsLancLD)->(LastRec()) == 0 // Se não retornar o registro, indica que o Lançamento não pode ser vinculado na pré-fatura
						lRet := JurMsgErro(STR0285,, STR0286) //"Não é possível víncular o Lançamento a essa pré-fatura." "Por favor verifique."
					EndIf
				EndIf
			EndIf

		Else
			If Empty(dDIniLanc) .Or. Empty(dDFimLanc)
				lRet := JurMsgErro(STR0287,, STR0286) // "A pré-fatura de destino não permite o vínculo do Lançamento." "Por favor verifique."
			Else
				lRet := JurMsgErro(STR0288,, STR0286) // "A situação da pré-fatura não permite o vínculo do Lançamento." "Por favor verifique."
			EndIf
		EndIf

	Else
		lRet := JurMsgErro(STR0289,, STR0286) //"Código de pré-fatura não encontrado." "Por favor verifique."
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVincLanLD
Realiza o vínculo dos Lançamentos na pré-fatura, conforme dados do AçãoLD.

@Param oModelLanc - Modelo de dados do Lançamento
@Param cTab       - Tabela do lançamento
@Param oTmpAcaoLD - Tabela temporária para vínculo do Lançamento na Pré via LD
@Param aVlCpoLD   - Array com os campos e valores referente ao ação LD

@Return Nil

@author Jorge Martins / Bruno Ritter
@since 18/04/2019
/*/
//-------------------------------------------------------------------
Function JVincLanLD(oModelLanc, cTab, oTmpAcaoLD, aVlCpoLD)
	Local cCodPre    := oModelLanc:GetValue(cTab + "_CPREFT")
	Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
	Local nPosAcao   := 0
	Local lAcaoVinc  := .F.

	If lIsRest .And. oModelLanc:GetOperation() != 5
		nPosAcao  := Iif( Empty(aVlCpoLD), 0, aScan(aVlCpoLD, {|aCpo| aCpo[1] == cTab+"_ACAOLD"}))
		lAcaoVinc := Iif(nPosAcao > 0, aVlCpoLD[nPosAcao][2] == "6", .F.) // Acão LD 6 = Vincular

		If lAcaoVinc .And. ValType(oTmpAcaoLD) == "O" // Vínculo do TS pelo Ação LD
			NX0->(dbSetOrder(1)) //NX0_FILIAL + NX0_COD + NX0_SITUAC
			If NX0->(DbSeek(xFilial("NX0") + cCodPre))
				Do Case
					Case cTab == "NUE"
						JA202BASS(Nil, oTmpAcaoLD:GetAlias())

					Case cTab == "NVY"
						JA202CASS(Nil, .F., oTmpAcaoLD:GetAlias())

					Case cTab == "NV4"
						JA202DASS(Nil, .F., oTmpAcaoLD:GetAlias())
				EndCase
				
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPDOfusca
Realiza o ofuscamento dos campos adicionados manualmente via
AddField no Struct.

@param oStruct    - Estrutura de campos da tabela (Deve ser SEMPRE passado por referência)
@param aCampos    - Array com os nomes dos campos
       aCampos[1] - Array com os nomes dos campos virtuais que serão adicionados
       aCampos[2] - Array com os nomes dos campos utilizados como referência para criação dos virtuais

@return Nil

@author Jorge Martins
@since 22/01/2020
/*/
//-------------------------------------------------------------------
Function JPDOfusca(oStruct, aCampos)
	Local aAccessFld := {}
	Local aCpoVirt   := {}
	Local aCpoOrig   := {}
	Local nCpo       := 0

	AEval(aCampos, {|x| AAdd(aCpoVirt, x[1])})
	AEval(aCampos, {|x| AAdd(aCpoOrig, x[2])})

	If Len(aCpoVirt) == Len(aCpoOrig)
		If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se o sistema trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
			aAccessFld := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCpoOrig )
			For nCpo := 1 To Len(aCpoVirt)
				oStruct:SetProperty( aCpoVirt[nCpo], MVC_VIEW_OBFUSCATED, aScan(aAccessFld, aCpoOrig[nCpo]) == 0)
			Next
		EndIf
	EndIf

	JurFreeArr(aCampos)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPDUserAc
Indica se o usuário tem acesso a dados sensíveis/pessoais (LGPD)

@return lPDUserAc, Indica se o usuário tem acesso aos dados

@author Jorge Martins
@since  26/03/2020
/*/
//-------------------------------------------------------------------
Function JPDUserAc()
	Local lPDUserAc := .T.

	If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se o sistema trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
		lPDUserAc := FwProtectedDataUtil():UsrPersonAccessPD() .And. FwProtectedDataUtil():UsrSensiAccessPD() // Verifica se o usuário tem acesso a Dados Sensíveis e Pessoais
	EndIf

Return lPDUserAc

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPDLogUser
Realiza o log dos dados acessados, de acordo com as informações enviadas, quando 
a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada (LGPD)

@param cFunction  , caractere, Rotina que será utilizada no log das tabelas
@param nOpc       , numerico , Opção atribuída a função em execução

@return lPDLogUser, logico   , Retorna se o log dos dados foi executado. Caso o log esteja 
                               desligado ou a melhoria não esteja aplicada, também retorna falso.

@author Jonatas Martins
@since  26/03/2020
/*/
//--------------------------------------------------------------------------------------------------
Function JPDLogUser(cFunction, nOpc)
	Local lPDLogUser  := .F.

	Default cFunction := ""
	Default nOpc      := 0

	If FindFunction("FwPDLogUser")
		lPDLogUser := FwPDLogUser(cFunction, nOpc)
	EndIf

Return (lPDLogUser)

//----------------------------------------------------------------------
/*/ { Protheus.doc } JurF3NXA2
Função filtra faturas para o escritório digitado e clientes que
utilizam e-billing.

@author Jonatas Martins
@since  26/10/2017
@obs    Variável "cEscri" é uma PRIVATE criada nos fontes LEDES98.prw 
        e LEDES00.prw. 
        Função utilizada na consulta padrão NXA2.
/*/
//----------------------------------------------------------------------
Function JurF3NXA2()
	Local cFilEscr := ""
	Local cFilter  := ""

	If Type('cEscri') == 'C' .And. !Empty(cEscri)
		cFilEscr := JurGetDados("NS7", 1, xFilial("NS7") + cEscri, "NS7_CFILIA")
		
		cFilter += "@NXA_CESCR = '" + cEscri + "' AND "
		cFilter += "NXA_COD IN (SELECT NXA_COD "
		cFilter +=               "FROM " + RetSqlName("NXA") + " NXA, " + RetSqlName("NUH") + " NUH "
		cFilter +=              "WHERE NXA.NXA_FILIAL = '" + FWxFilial("NXA", cFilEscr) + "' "
		cFilter +=                "AND NXA.NXA_CESCR = '" + cEscri + "' "
		cFilter +=                "AND NXA.NXA_TIPO = 'FT' "
		cFilter +=                "AND NXA.NXA_SITUAC = '1' "
		cFilter +=                "AND NUH.NUH_FILIAL = '" + FWxFilial("NUH", cFilEscr) + "' "
		cFilter +=                "AND NUH.NUH_UTEBIL = '1' "
		cFilter +=                "AND NXA.NXA_CCLIEN = NUH.NUH_COD "
		cFilter +=                "AND NXA.NXA_CLOJA = NUH.NUH_LOJA "
		cFilter +=                "AND NUH.D_E_L_E_T_ = ' ' "
		cFilter +=                "AND NXA.D_E_L_E_T_ = ' ') "
	EndIf

Return (cFilter)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurvldSx1
Indica se o pergunte existe na base de dados
@param cPerg  Nome do Pergunte

@return lRet Pergunte existe

@author  fabiana.silva
@since   10/08/2020
/*/
//-------------------------------------------------------------------
Function JurvldSx1(cPerg)
	Local oObjSX1   :=  FWSX1Util():New()
	Local aPergunte := {}
	Local lRet      := .F.
	
	Default cPerg   := ""

	oObjSX1:AddGroup(cPerg)
	oObjSX1:SearchGroup()
	aPergunte := oObjSX1:GetGroup(cPerg)

	lRet :=  Len(aPergunte) >= 2 .AND. !Empty(aPergunte[01]) .AND. Len(aPergunte[02]) > 0


	FreeObj(@oObjSX1)
	JurFreeArr(aPergunte)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldNatPg()
Função utilizada para validação no dicionário.
Verifica se a natureza é válida.

@Return lValid Se a natureza é válida.

@author Jorge Martins / Jonatas Martins
@since  30/12/2020
@Obs    Função chamada no X3_VALID dos campos NXG_CNATPG e NXP_CNATPG
/*/
//-------------------------------------------------------------------
Function JVldNatPg(cCampo)
Local lValid := .T.

	lValid := JurValNat(cCampo, "2", Nil, .F., "6|7")

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} JAnexoM020()
Função utilizada no botão de anexar documentos no cadastro de 
fornecedor

@author Jorge Martins / Abner Oliveira
@since  23/02/2021
@Obs    Função chamada no fonte MATA020 (AddUserButton)
/*/
//-------------------------------------------------------------------
Function JAnexoM020()

	JURANEXDOC("SA2", "SA2MASTER", "", "A2_COD", , , , , , "3", "A2_LOJA", , , .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JExcAnxSinc()
Exclui o(s) anexo(s) na NUM, além da ACB e AC9 se for base de 
conhecimento e registra a exclusão na fila de sincronização.

@param  cEntidade - Nome da Entidade (Ex: SA2)
@param  cCodEnt   - Chave da entidade (Valor da expressão A2_COD + A2_LOJA)

@author Jorge Martins / Abner Oliveira
@since  25/02/2021
@Obs    Função executada durante o commit da exclusão (InTTs)
        de registros em entidades que permitem inclusão de anexos.
        Ex: Casos, Contratos, Cliente, Fornecedores.
/*/
//-------------------------------------------------------------------
Function JExcAnxSinc(cEntidade, cCodEnt)
Local aArea    := GetArea()
Local aAreaNUM := NUM->(GetArea())
Local lBaseCon := SuperGetMv('MV_JDOCUME', ,'1') == "2" // Base de Conhecimento
Local cFilEnt  := xFilial(cEntidade)
Local cFilNUM  := xFilial("NUM")

	NUM->(dbSetOrder(5)) // NUM_FILIAL + NUM_ENTIDA + NUM_FILENT + NUM_CENTID
	If NUM->(dbSeek(cFilNUM + cEntidade + cFilEnt + cCodEnt))
		While !NUM->(EOF()) .And. NUM->NUM_FILIAL == cFilNUM   .And. ;
		                          NUM->NUM_ENTIDA == cEntidade .And. ;
		                          NUM->NUM_FILENT == cFilEnt   .And. ;
		                          RTrim(NUM->NUM_CENTID) == RTrim(cCodEnt)

			
			JExcDAnSinc(lBaseCon)
			NUM->(dbSkip())
		EndDo
	EndIf

	RestArea(aAreaNUM)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGrAnxFila()
Verifica se os registros de anexos (NUM) de uma determinada entidade 
serão gravados na fila de sincronização (NYS)

@param  cEntidade - Nome da Entidade (Ex: SA2)

@return lGrava    - Indica se o registro será gravado na fila

@author Jorge Martins / Abner Oliveira
@since  02/03/2021
/*/
//-------------------------------------------------------------------
Function JGrAnxFila(cEntidade)
Local lGrava := cEntidade $ "SA1|NVE|NZQ"

/*
Entidades que permitem anexos e devem sincronizar os anexos
SA1 - JURA148  - Clientes
NVE - JURA070  - Casos
NZQ - JURA235  - Solicitação Despesas
NZQ - JURA235A - Aprov Despesas

Entidades que permitem anexos, porém não é necessário sincronizar os anexos
SA2 - MATA020  - Fornecedor
NT0 - JURA096  - Contrato
NT0 - JURA202  - Op. Pré-fatura
OHB - JURA241  - Lançamentos
OHF - JURA246  - Desdobramentos
OHG - JURA247  - Desd. Pós Pagto
SF1 - MATA103  - Documento de Entrada
*/

Return lGrava

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3WO()
Consulta especifica de motivo de WO por lançamento.

@return  cFiltro - Filtro para consulta padrão de Motivo de WO,
                   conforme tipo do lançamentos

@obs     Filtro utilizado na consulta padrão NXVEMI

@author  Reginaldo Borges
@since   18/03/2021
/*/
//-------------------------------------------------------------------
Function JURF3WO()
Local cFiltro    := "@NXV_TIPO = '1'"
Local lNXVTpLanc := NXV->(ColumnPos("NXV_TPLANC")) > 0

	If lNXVTpLanc
		__cTpLanc := IIf(Empty(__cTpLanc) .And. FwIsInCallStack("JURA049"), "2", __cTpLanc) // Caso o F3 seja executado no cadastro de despesas (JURA049)

		If !Empty(__cTpLanc)
			cFiltro += " AND NXV_TPLANC IN ('" + __cTpLanc + "','6')"
		Else
			cFiltro += " AND NXV_TPLANC = '6' "
		EndIf
	EndIf

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} JAnonimiza()
Define as regras de anonimização considerando o tempo de guarda 
das informações para das seguintes tabelas:
- NXA - Faturas
- NUR - Participantes

@param  cTabela, Tabela para que será aplicada a regra

@return lAnonimiza, Indica se a anonimização será aplicada para o registro

@obs    Utilizada pela tabela XAP - LGPD

Importante destacar que para anonimizar os dados, todos os registros 
envolvidos no processo devem atender as regras, ou seja,
caso uma fatura não atenda aos requisitos, nenhuma fatura e nem os dados
do cliente serão anonimizados.

@author Jorge Martins
@since  31/05/2021
/*/
//-------------------------------------------------------------------
Function JAnonimiza(cTabela)
Local lAnonimiza := .F.
Local dDataDemis := Nil

Default cTabela  := ""

	If cTabela == "NXA" // Regra de anonimização de Cliente - 5 anos após a emissão da fatura
		lAnonimiza := dDataBase > (NXA->NXA_DTEMI + 1825)
	ElseIf cTabela == "NUR" // Regra de anonimização de participante - 5 anos após a demissão
		dDataDemis := JurGetDados("RD0", 1, xFilial("RD0") + NUR->NUR_CPART, "RD0_DTADEM")
		If !Empty(dDataDemis)
			lAnonimiza := dDataBase > (dDataDemis + 1825)
		EndIf
	EndIf

Return lAnonimiza
//-------------------------------------------------------------------
/*/{Protheus.doc} JurSeqNXM
Retorna a proxima sequencia da NXM

@param cEscrit,  caracter, Escritorio da Fatura
@param cFatura,  caracter, Numero da Fatura
@param cFilTit,  caracter, Filial do Titulo do Boleto
@param cPrefTit, caracter, Prefixo do Titulo do Boleto
@param cNumTit,  caracter, Numero do Titulo do Boleto
@param cParcTit, caracter, Parcela do Titulo do Boleto
@param cTipoTit, caracter, Tipo do Titulo do Boleto

@return nOrdem, Indica o proximo numero

@author fabiana.silva
@since  30/07/2021
/*/
//-------------------------------------------------------------------
Function JurSeqNXM(cEscrit, cFatura, cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit)
Local nOrdem := 0
Local cQuery := ""

	If !Empty(cEscrit) .And. !Empty(cFatura)
		cQuery := "SELECT COALESCE(MAX(NXM_ORDEM), 0) + 1 "
		cQuery +=   "FROM " + RetSqlName("NXM") "
		cQuery +=  "WHERE NXM_FILIAL = '" + xFilial("NXM") + "' "
		cQuery +=    "AND NXM_CESCR = '" + cEscrit + "' "
		cQuery +=    "AND NXM_CFATUR = '" + cFatura + "' "
		cQuery +=    "AND D_E_L_E_T_ = ' '"

		nOrdem := JurSql(cQuery, "*")[1][1]

	ElseIf !Empty(cPrefTit) .And. !Empty(cNumTit)

		cQuery := "SELECT COALESCE(MAX(NXM_ORDEM), 0) + 1 "
		cQuery +=   "FROM " + RetSqlName("NXM") "
		cQuery +=  "WHERE NXM_FILIAL = '" + xFilial("NXM") + "' "
		cQuery +=    "AND NXM_FILTIT = '" + cFilTit + "' "
		cQuery +=    "AND NXM_PREFIX = '" + cPrefTit + "' "
		cQuery +=    "AND NXM_TITNUM = '" + cNumTit + "' "
		cQuery +=    "AND NXM_TITPAR = '" + cParcTit + "' "
		cQuery +=    "AND NXM_TITTPO = '" + cTipoTit + "' "
		cQuery +=    "AND D_E_L_E_T_ = ' '"

		nOrdem := JurSql(cQuery, "*")[1][1]
	EndIf

Return nOrdem

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVlX7Bco()
Validar o banco do pagador e o vinculo ao 
escritório da mesma.

@return lRet, Indica se o banco deve ser validado

@author fabiana.silva
@since  28/07/2021
/*/
//-------------------------------------------------------------------
Function JurVlX7Bco()
Local lRet     := .T.
Local oModel   := FWModelActive()
Local cChave   := ""
Local cCliPg   := ""
Local cLojaPg  := ""
Local aInfo    := {}
Local lJurxFin := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

	If oModel:GetId() = "JURA033" 
		aInfo  := JurInfPag(oModel)
	EndIf

	If Len(aInfo) >= 8

		cEscrit := aInfo[1]
		cCliPg  := aInfo[7]
		cLojaPg := aInfo[8]

		lRet := !Empty(cCliPg) .And. !Empty(cLojaPg)

		If lRet
			aInfo := JurGetDados("NUH", 1, xFilial("NUH") + cCliPg + cLojaPg, {"NUH_CBANCO", "NUH_CAGENC", "NUH_CCONTA"})
			lRet := Len(aInfo) >= 3 .And. !Empty(aInfo[1]) .And. !Empty(aInfo[2]) .And. !Empty(aInfo[3])
			cChave := aInfo[1] + aInfo[2] + aInfo[3]
			If lRet
				lRet := JurGetDados("SA6", 1, xFilial("SA6") + cChave, "A6_BLOCKED") != "1"
				If lRet
					If lJurxFin .And. FWAliasInDic("OHK") // Proteção OHK
						lRet := !Empty(cEscrit) .And. !Empty(JurGetDados("OHK", 1, xFilial("OHK") + cEscrit + cChave, "OHK_CESCRI"))
					Else
						lRet := ExistCpo('SA6', cChave, 1)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JExcDAnSinc
Exclui o anexo e envia para a fila de sincronização a exclusão
Especialização da rotina JExcAnxSinc

@param lBaseCon, Indica se utiliza a base de conhecimento

@author fabiana.silva
@since  28/07/2021
/*/
//-------------------------------------------------------------------
Function JExcDAnSinc(lBaseCon)
Local cCodNUM   := NUM->NUM_COD
Local cEntidade := NUM->NUM_ENTIDA
Local cChvACB   := ""
Local cChvAC9   := ""

Default lBaseCon := SuperGetMv('MV_JDOCUME', ,'1') == "2"

	If lBaseCon
		cChvACB := NUM->NUM_NUMERO // ACB_CODOBJ
		cChvAC9 := NUM->NUM_NUMERO + NUM->NUM_ENTIDA + NUM->NUM_FILENT + NUM->NUM_CENTID // AC9_CODOBJ, AC9_ENTIDA, AC9_FILENT, AC9_CODENT
	EndIf

	Reclock("NUM", .F.)
	NUM->( DbDelete() )
	NUM->( MsUnLock() )

	If NUM->(Deleted())
		If lBaseCon
			JAnxDlBaseCon(cChvACB, cChvAC9, 1) // Exclui registros na ACB e AC9 (Base de conhecimento)
		EndIf

		If JGrAnxFila(cEntidade) // Verifica se os anexos dessa entidade serão gravados na fila
			J170GRAVA("NUM", xFilial("NUM") + cCodNUM, "5")
		EndIf
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} JVldAltMdl(oModelVer, nIndDtMdl, aPrmAltFld, lGrid)
Verifica os campos que foram alterados. Caso algum campo que
não esteja no aPrmAltFld tenha sido alterado, retorna falso

@param cMasterId  - Modelo a ser validado
@param nIndDtMdl  - Indice do DataModel a ser validado
@param aPrmAltFld - Campos que podem ser alterados
@param lGrid - Indica se o Modelo passado no oModelVer é Grid

@author Willian Kazahaya
@since 26/01/2022

@example
Local oMdl       := FWModelActive()
Local oMdlNVY    := oMdl:GetModel('NVYMASTER')

JVldAltMdl(oMdlNVY, 1, {"NVY_DESCRI"})
/*/
//-------------------------------------------------------------------
Function JVldAltMdl(oModelVer, nIndDtMdl, aPrmAltFld, lGrid)
Local lRet       := .T.
Local nI         := 0
Local oDataModel := Nil
Local aGridDtMdl := {}
Local aGridHeader:= {}
Local nLine      := 0

Default nIndDtMdl  := 1
Default aPrmAltFld := {}
Default lGrid      := .F.

	If (lGrid)
		nLine := oModelVer:GetLine()
		aGridDtMdl := oModelVer:aDataModel[nLine][1] // O DataModel retorna os Valores e se foi alterado
		aGridHeader := oModelVer:aHeader // O aHeader retorna a estrutura da coluna

		For nI := 1 to Len(aGridDtMdl[2]) // A primeira posição são os valores, o segundo indica se houve alteração
			If (aGridDtMdl[2][nI] .And. aScan(aPrmAltFld, aGridHeader[nI][2]) == 0 )
				lRet := .F.
				Exit
			EndIf
		Next nI
	Else
		oDataModel := oModelVer:aDataModel[nIndDtMdl]
		For nI := 1 To Len(oDataModel)
			If (oDataModel[nI][3] .And. aScan(aPrmAltFld, oDataModel[nI][1]) == 0 )
				lRet := .F.
				Exit
			EndIf
		Next nI
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JF3SED
Consulta especifica de natureza

@param aFields   , array, Array de campos
@param lShow     , boolean, Indica se o formulário deve ser exibido
@param lInsert   , boolean, Indica se o usuário pode incluir novo registro
@param cFilter   , string, Filtro de pesquisa
@param lPreload  , boolean, Indica se o grid deve ser pré-carregado

@return lRet     , boolean, Indica se houve sucesso na consulta
@since  08/04/2022
/*/
//-------------------------------------------------------------------
Function JF3SED(aFields, lShow, lInsert, cFilter, lPreload)
	Local lRet       := .F.
	Default lShow    := .T.
	Default cFilter  := ""
	Default aFields  := {"ED_CODIGO", "ED_DESCRIC"}
	Default lInsert  := .F.
	Default lPreload := .T.

	If IsInCallStack('JURA164') .OR. IsInCallStack('JURA235A') .OR. IsInCallStack('JURA241') .OR. IsInCallStack('JURA242') 
		cFilter += " SED.ED_TIPO = '2' AND SED.ED_CMOEJUR <> '' AND SED.ED_MSBLQL = '2' "
	ElseIf IsInCallStack('FINA050') .OR. IsInCallStack('JURA281') .OR. IsInCallStack('JURA247')
		cFilter += " SED.ED_TIPO = '2' AND SED.ED_CMOEJUR <> '' AND SED.ED_MSBLQL = '2' AND SED.ED_CPJUR = '1' "
	ElseIf IsInCallStack('JURA266')
		cFilter += "@#J266FilNat(.T.)"
	EndIf

	lRet := JURSXB("SED", "JF3SED", aFields, lShow, lInsert , cFilter, , lPreload)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JExistWO
Rotina para validar a existência do código do WO.

@param  cWoCodig, Código do WO
@param  cAlias  , Tabela do Lançamento (NUE - NVY - NV4)
@param  cCodLanc, Código do lançamento (NUE - NVY - NV4)

@return lExistWO, Se verdadeiro informa que existe o código do WO
@autor  Jorge Martins / Jonatas Martins
@since  08/04/2022
/*/
//-------------------------------------------------------------------
Static Function JExistWO(cWoCodig, cAlias, cCodLanc)
Local lExistWO := !Empty(cWoCodig)

	If !lExistWO // Código do WO em branco
		JurMsgErro(STR0312,, STR0313) // "Não foi possível realizar o WO dos lançamentos." - "Refaça a operação."
		JurConout("Lancto com WO sem codigo - Alias: " + cAlias + " - Codigo: " + cCodLanc + " - Usuario: " + __cUserId )
		JSetDisarmWO(.T.)
		DisarmTransaction()
		Break
	EndIf

Return (lExistWO)

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetDisarmWO
Retorno da variável estática que define se a transação foi desarmada
na inclusão do WO.

@return _lDisarmWO, Se verdadeiro a transação foi desarmada
@autor  Jorge Martins / Jonatas Martins
@since  08/04/2022
/*/
//-------------------------------------------------------------------
Function JGetDisarmWO()
Return (_lDisarmWO)

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetDisarmWO
Atribui valor na variável estática que define se a transação foi desarmada
na inclusão do WO.

@return _lDisarmWO, Se verdadeiro a transação foi desarmada
@autor  Jorge Martins / Jonatas Martins
@since  08/04/2022
@obs    Função utilizada na JURA202
/*/
//-------------------------------------------------------------------
Function JSetDisarmWO(lValue)
Default lValue := .F.

	_lDisarmWO := lValue
Return Nil
