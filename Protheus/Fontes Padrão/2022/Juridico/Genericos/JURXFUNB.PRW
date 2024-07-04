#INCLUDE 'JURXFUNB.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE PARFILBKP	2
#DEFINE PARFILREC	3
#DEFINE PARFILTAM	3

Static __cLibVersion

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSOMA
Calcula a soma de todos os registros de um determinado campo de valor de qualquer tabela do modulo SIGAJURI.
Que faz referência a tabela de Assunto Jurídico (NSZ) através do campo CAJURI

Uso Geral.

@param 	cNomeCampo      	Nome do campo para ser somado
@param 	cAliasTabela 	    Alias da tabela
@param 	cAssuntoJuridico  Código do Assunto Jurídico (CAJURI)
@param 	cRestricao       	Restrição para soma, notação em SQL
@param 	nValor           	Valor numérico do registro corrente

@Return nRet	         	Valor numérico de retorno

@sample
JURSOMA( 'NT3_VALOR', 'NT3', M->NT3_CAJURI, "AND NT3_MOVFIN = '1' ")

@author Raphael Zei
@since 23/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSOMA( cNomeCampo, cAliasTabela, cAssuntoJuridico, cCodigo, cRestricao, nValor, cTipoPedido)
	Local nRet    := 0
	Local cTmp    := GetNextAlias()
	Local cQuery  := ''
	Local aArea   := GetArea()
	Local aCampos := {}

	ParamType 0 Var cNomeCampo       As Character
	ParamType 1 Var cAliasTabela     As Character
	ParamType 2 Var cAssuntoJuridico As Character
	ParamType 3 Var cCodigo          As Character
	ParamType 4 Var cRestricao       As Character Optional Default ''
	ParamType 5 Var nValor           As Numeric

	Default cTipoPedido := ""

	If Empty(cTipoPedido)
		cQuery += "SELECT SUM( ROUND(" +cNomeCampo+ ",2) ) SOMA "
	Else
		aCampos := JURGetCampos(cTipoPedido)
		cQuery += "SELECT SUM( ROUND(" +cNomeCampo+ ",2) + ROUND(" +aCampos[1][1]+ ",2) + ROUND(" +aCampos[1][2]+ ",2) ) SOMA "
	Endif

	cQuery += "  FROM " + RetSqlName( cAliasTabela ) + " " + cAliasTabela
	cQuery += " WHERE " + cAliasTabela + "_FILIAL = '" + xFilial( cAliasTabela ) + "' "
	cQuery += "   AND " + cAliasTabela + "_CAJURI =  '" + cAssuntoJuridico + "' "
	cQuery += "   AND " + cAliasTabela + "_COD <>  '" + cCodigo + "' "
	cQuery += "   AND " + cAliasTabela + ".D_E_L_E_T_ = ' ' "
	cQuery += cRestricao
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

	If !(cTmp)->( EOF() )
		nRet := (cTmp)->SOMA + nValor
	EndIf

	(cTmp)->( dbCloseArea() )

	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSITPROC
Verifica a situação do processo e as configurações para poder alterá-lo
com justificativa ou bloquear a alteração

Uso Geral.

@param 	cAssJur      	Código do Assunto Jurídico
@param 	cParametro 	    Nome do parâmetro da tela a verificar a permissão de operações

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 04/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSITPROC(cAssJur, cParametro, lAltSituac, lAltLote, cUsuAlt)
	Local lRet      := .F.
	Local lCtrlMsg	:= .T.
	Local cSituacao := ""
	Local dEncerra  := ctod('')
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local cTipoAs   := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_TIPOAS')
	Local cMotProc  := "" //  Motivo padrão utilizado no remanejamento de Processos encerrados.
	Local cJustif   := "" 
	Local oModelNUV := Nil


	ParamType 2 Var lAltSituac As Logical Optional default .F.
	Default lAltLote := .F.
	Default cUsuAlt  := ""

	If !IsInCallStack('J063Remanj')

		If IsPesquisa()

			If IsInCallStack('JURA095')
				dEncerra := If (!Empty(M->NSZ_DTENCE),M->NSZ_DTENCE,NSZ->NSZ_DTENCE)
				cSituacao:= (M->NSZ_SITUAC)
				If cSituacao == JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_SITUAC') .And. lAltSituac
					lAltSituac := .F.
					dEncerra := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_DTENCE')
				ElseIf lAltSituac .And. INCLUI
					lAltSituac := .F.
					cSituacao:= JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_SITUAC')
					dEncerra := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_DTENCE')
				EndIf
			Else
				cSituacao:= JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_SITUAC')
				dEncerra := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_DTENCE')
			EndIf

		Else

			If  oModel:GetId() == 'JURA095'
				dEncerra := If (!Empty(FwFldGet('NSZ_DTENCE')),FwFldGet('NSZ_DTENCE'),NSZ->NSZ_DTENCE)
				cSituacao:= FwFldGet('NSZ_SITUAC')
				If cSituacao == JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_SITUAC') .And. lAltSituac
					lAltSituac := .F.
					dEncerra := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_DTENCE')
				ElseIf lAltSituac .And. INCLUI
					lAltSituac := .F.
					cSituacao:= JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_SITUAC')
					dEncerra := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_DTENCE')
				EndIf
			Else
				cSituacao:= JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_SITUAC')
				dEncerra := JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_DTENCE')
			EndIf

		Endif

		If 	( ( lAltSituac .And. cSituacao == '1') .Or. ( !lAltSituac .And. cSituacao == '2' ) )

			If (SuperGetMV('MV_JTVENJF',, '2') == '1')

				If lAltSituac .And. cSituacao == '1' .AND. lAltLote
					lRet := .T.
				Else

					Do Case

						//Permite alteração em lote de processos encerrados
					Case lAltLote
						lRet := .T.

						//Permite alteração pelo Fluig
					Case IsInCallStack("MTJurSyncFollowUp") .Or. IsInCallStack("MTJurEncerraAssJur")
						lRet := .T.

						//Permite inclusão de andamento feito pelo Historico do Fluig
					Case IsInCallStack("J95HisFlu")
						lRet := .T.
						// Quando a requisição for do TOTVS Legal não faz a gravação da justificativa, pois já foi efetuada.
					Case JModRst() // Valida se é TOTVS Legal
						lRet := .T.

						//Grava justificativa para andamento automatico
					Case ( IsInCallStack("JURA223") .OR. IsInCallStack('J283ImpPub') .OR. IsInCallStack('TombAutom') )
						lRet := J223GrvJus()

						//Grava justificativa para conciliação de publicação
					Case IsInCallStack("J20Concil") .And. !Empty( JGetParTpa(cTipoAs, "MV_JAJUENC", "") )
						lRet := J223GrvJus(USRRETNAME(__CUSERID), STR0109)  //"Conciliação para processos encerrados"

					Case isBlind() .And. IsInCallStack('JURA106TOK')
						cMotProc  := SuperGetMV('MV_JMOTREM', , '') //  Motivo padrão utilizado no remanejamento de Processos encerrados.
						cJustif   := JurGetDados('NQX', 1, xFilial('NQX') + cMotProc, 'NQX_DESC')
						If !Empty(cMotProc)
							oModelNUV := FWLoadModel("JURA166")
							oModelNUV:SetOperation(MODEL_OPERATION_INSERT)
							oModelNUV:Activate()

							oModelNUV:SetValue( 'NUVMASTER', 'NUV_CAJURI', cAssJur )
							oModelNUV:SetValue( 'NUVMASTER', 'NUV_USUALT', cUsuAlt )
							oModelNUV:SetValue( 'NUVMASTER', 'NUV_DTALT' , Date()  )
							oModelNUV:SetValue( 'NUVMASTER', 'NUV_CMOTIV', cMotProc )
							oModelNUV:SetValue( 'NUVMASTER', 'NUV_JUSTIF', cJustif  )
								
							lRet := oModelNUV:VldData() .And. oModelNUV:CommitData()
				
							If !lRet
								Conout( "----------------------------------------------------")
								Conout( STR0116 ) //"Não foi possível cadastrar a justificativa de remanejamento de processos encerrados. Verifique."
								Conout( "----------------------------------------------------")
							EndIf
				
							oModelNUV:DeActivate()
						Else
							Conout( "----------------------------------------------------")
							Conout( STR0117 + STR0116 ) //"Motivo de alteração padrão para remanejamento não preenchido. //Não foi possível cadastrar a justificativa de remanejamento de processos encerrados. Verifique."
							Conout( "----------------------------------------------------")
						EndIf

					//0 Se o usuário finalizar a operação com o botão confirmar;
					//1 Se o usuário finalizar a operação com o botão cancelar;
					Case ApMsgYesNo(STR0007 + DTOC(dEncerra) + STR0008)
					lRet := ( FWExecView(STR0003,'JURA166',3,,{||.T.} ) == 0 )

					OtherWise
						lCtrlMsg := .F.
						If IsInCallStack("JURA020")
							JurMsgOk(STR0092 + DTOC(dEncerra))		//"Conciliação não efetuada devido a opção do usuario de não alterar o processo encerrado desde "
						Else
							JurMsgOk(STR0025)	//Alterações não foram salvas
						EndIf

					End Case

				Endif

				If !lRet .And. lCtrlMsg
					JurMsgErro(STR0011)		//"É necessário o preenchimento da justificativa para alteração do processo encerrado"
				EndIf
			Else
				If (cSituacao == '2' .Or. lAltSituac) .And.(SuperGetMV(cParametro,, '2') == '1')
					JurMsgErro(STR0009)		//"Este processo está encerrado e não é permitida a inclusão/alteração/exclusão"
				Else
					lRet := .T.
				Endif
			EndIf
		Else
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURCLICAS0
Retorna o código do cliente e o número do caso do assunto jurídico.

Uso Geral.

@param 	cAssuntoJuridico  	Código do Assunto Jurídico (CAJURI)
@param 	lTipo           	Informa o tipo de retorno: .T. para utilização do SIGAJURI (com os zeros a esquerda)
.F. para utilização do GED      (sem os zeros a esquerda)
@Return aRet	         	Array de retorno 1- Código do Cliente, 2- Número do Caso

@sample
JURSOMA( 'NT3_VALOR', 'NT3', M->NT3_CAJURI, "AND NT3_MOVFIN = '1' ")

@author Raphael Zei
@since 23/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURCLICAS0( cAssuntoJuridico, lTipo )
	Local aRet     := {}
	Local cAssunto := GetNextAlias()
	Local cQuery   := ''
	Local aArea    := GetArea()

	ParamType 0 Var cAssuntoJuridico As Character
	ParamType 1 Var lTipo            As Logical default .T.

	cQuery += "SELECT NSZ_CCLIEN, NSZ_NUMCAS "
	cQuery += "  FROM " + RetSqlName( 'NSZ' ) + ' NSZ '
	cQuery += " WHERE NSZ_FILIAL = '" + xFilial( 'NSZ' ) + "' "
	cQuery += "   AND NSZ_COD =  '" + cAssuntoJuridico + "' "
	cQuery += "   AND NSZ.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAssunto, .T., .F. )

	TcSetField( cAssunto, 'NSZ_CCLIEN', 'C', TamSX3('NSZ_CCLIEN')[1], 0 )
	TcSetField( cAssunto, 'NSZ_NUMCAS', 'C', TamSX3('NSZ_NUMCAS')[1], 0 )

	if lTipo
		(cAssunto)->( dbEVal( { || aAdd( aRet, { (cAssunto)->NSZ_CCLIEN, (cAssunto)->NSZ_NUMCAS } ) } ,, { || !EOF() } ) )
	else
		(cAssunto)->( dbEVal( { || aAdd( aRet, { AllTrim(IIF(VAL((cAssunto)->NSZ_CCLIEN)>0,STR(VAL((cAssunto)->NSZ_CCLIEN)),(cAssunto)->NSZ_CCLIEN)), AllTrim(STR(VAL((cAssunto)->NSZ_NUMCAS))) } ) } ,, { || !EOF() } ) )
	endif

	(cAssunto)->( dbCloseArea() )

	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURQRYRD0
Monta a query de participantes conforme o parâmetro de retorno

@param 	cTipo Tipo do retorno dos participantes
1 - Funcionários Ativos
2 - Sócios
3 - Sócios ou Revisores
4 - Assinam Fatura

@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JQRYRD0AT(cTipo, cSqlBloc, lShowBloc)
	Local cQuery   := ""

	Default cSqlBloc  := "2"
	Default lShowBloc := .F.

//1 - Todos (ativos), 2 - Sócios (ativos) , 3 - Sócio ou revisores (ativos)
	If cTipo $ "1|2|3"
		cQuery := " SELECT RD0.RD0_SIGLA, RD0.RD0_CODIGO, RD0.RD0_NOME, "
		cQuery += Iif(lShowBloc, "RD0.RD0_MSBLQL, ", " ") + "RD0.R_E_C_N_O_ RD0RECNO "
		cQuery += "   FROM "+RetSqlName("RD0")+" RD0, "
		cQuery += " 			 "+RetSqlName("NUR")+" NUR  "
		cQuery += " WHERE RD0.D_E_L_E_T_ = ' ' "
		cQuery += "   AND NUR.D_E_L_E_T_ = ' ' "
		cQuery += "   AND RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "'"
		cQuery += "   AND NUR.NUR_FILIAL = '" + xFilial( "NUR" ) + "'"
		cQuery += "   AND RD0.RD0_CODIGO = NUR.NUR_CPART  "
		cQuery += Iif(cSqlBloc != "3", " AND RD0.RD0_MSBLQL = '" + cSqlBloc + "'", " ")
		cQuery += "   AND RD0.RD0_TPJUR = '1' "
		If cTipo == '2'
			cQuery += "   AND NUR.NUR_SOCIO  = '1' "
		ElseIf cTipo == '3'
			cQuery += "   AND (NUR.NUR_SOCIO  = '1' OR  NUR.NUR_REVFAT = '1') "
		EndIf

		//4 - Participantes (ativos) cuja categoria pode assinar fatura
	ElseIf cTipo == '4'
		cQuery := " SELECT RD0.RD0_CODIGO, RD0.RD0_NOME, "
		cQuery += Iif(lShowBloc, "RD0.RD0_MSBLQL, ", " ") + "RD0.R_E_C_N_O_ RD0RECNO "
		cQuery += "   FROM "+RetSqlName("RD0")+" RD0, "
		cQuery += " 			 "+RetSqlName("NUR")+" NUR  "
		cQuery += " 			 "+RetSqlName("NRN")+" NRN  "
		cQuery += " WHERE RD0.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND NUR.D_E_L_E_T_ = ' ' "
		cQuery += "   AND NRN.D_E_L_E_T_ = ' ' "
		cQuery += "   AND RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "'"
		cQuery += "   AND NUR.NUR_FILIAL = '" + xFilial( "NUR" ) + "'"
		cQuery += Iif(cSqlBloc != "3", " AND RD0.RD0_MSBLQL = '" + cSqlBloc + "'", " ")
		cQuery +=    " AND RD0.RD0_TPJUR = '1' "
		cQuery +=    " AND RD0.RD0_FILIAL = NRN.NRN_FILIAL "
		cQuery += "   AND RD0.RD0_CODIGO = NUR.NUR_CPART  "
		cQuery += "   AND NUR.NUR_CCAT   = NRN.NRN_COD    "
		cQuery += "   AND NRN.NRN_ASSINA = '1'            "

	Else //Se não for de nenhum tipo definido taz o record vazio (where 1=2).
		cQuery := " SELECT RD0.RD0_CODIGO, RD0.RD0_NOME, RD0.R_E_C_N_O_ RD0RECNO "
		cQuery += "   FROM "+RetSqlName("RD0")+" RD0 "
		cQuery += " WHERE RD0.D_E_L_E_T_ = ' ' "
		cQuery += "   AND RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "'"
		cQuery += "	  AND '1' = '2' "
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRD0
Verifica se o valor do campo de participante é válido quando o mesmo o
digita no campo
Uso Geral.

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
Function JURRD0(cMaster, cCampo, cTipo, lSigla)
	Local lRet       := .F.
	Local aArea      := GetArea()
	Local cQuery     := JQRYRD0AT(cTipo)
	Local cAlias     := GetNextAlias()
	Local oModel     := FWModelActive()
	Local oModMaster := Nil
	Local cCodSig    := ""

	Default lSigla := .F.

	If oModel == NIL .Or. ValType(oModMaster := oModel:GetModel(cMaster)) != "O"
		cCodSig := &("M->"+cCampo)
	Else
		cCodSig := oModMaster:GetValue(cCampo)
	EndIf

	If !lSigla
		cQuery += " AND RD0_CODIGO = '" + cCodSig + "'"
	Else
		cQuery += " AND RD0_SIGLA = '" + cCodSig + "'"
	EndIf

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If !(cAlias)->( EOF() )
		lRet := .T.
	Else
		JurMsgErro(STR0010)
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3RD0AT
Monta a consulta padrão participantes ativos
Uso Geral.
@param 	cTipo Tipo do retorno dos participantes
1 - Funcionários Ativos
2 - Sócios
3 - Sócios ou Revisores
4 - Assinam Fatura

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
Consulta padrão específica RD0ATV

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3RD0AT(cTipo, lVisual)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local aPesq    := {"RD0_SIGLA","RD0_CODIGO","RD0_NOME"}
	Local nResult  := 0
	Local cFiltro  := ""

	Default lVisual  := .F. //Indica se a opcao de visualizacao estara presente

	If cTipo != '1'

		cQuery := JQRYRD0AT(cTipo)
		cQuery := ChangeQuery(cQuery, .F.)

		RestArea( aArea )

		If cTipo $ "2|3"
			lVisual := .T.
		EndIf

		nResult := JurF3SXB("RD0", aPesq,, lVisual, .F.,,cQuery)
		lRet := nResult > 0

		If lRet
			DbSelectArea("RD0")
			RD0->(dbgoTo(nResult))
		EndIf
	Else
		cFiltro := " RD0->RD0_MSBLQL == '2' .AND. RD0->RD0_TPJUR == '1' "

		RD0->( DbSetOrder( 1 ) )

		nResult := JurF3SXB("RD0", aPesq, cFiltro, lVisual, .F.)
		lRet := nResult > 0

		If lRet
			DbSelectArea("RD0")
			RD0->(dbgoTo(nResult))
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAVLDCAMPO()
Verifica se o valor informado para um campo pertence a um registro validado por outro campo
Uso Geral.

@param 	cMaster  	Fields ou Grid a ser verificado (NÃO USADO - COMPATIBILIDADE)
@param  cCampo	  	Campo do Fields ou Grid a ser verificado
@param 	cTabela   	Tabela que será consultada
@param 	cTabCampo 	Campo da Tabela de consulta que será validado
@param 	cValValido	Valor que indicará se o campo da tabela é valido
@param 	aCmpMoeda	Dados da moeda indicada (data e moeda)

@Return lRet	 	.T./.F. As informações são bcválidas ou não

@sample
Vazio().OR.(ExistCpo('NRB',M->NSZ_CAREAJ,1).AND.(JAVLDCAMPO('NSZMASTER', 'NSZ_CAREAJ', 'NRB', 'NRB_ATIVO', '1' )))

Vazio().OR.(ExistCpo('CTO',M->NRE_MOEDA,1).AND.(JAVLDCAMPO('NREMASTER', 'NRE_MOEDA', 'CTO', 'CTO_BLOQ', '2' )))

@author Juliana Iwayama Velho / David Gonçalves Fernandes
@since 25/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAVLDCAMPO(cMaster, cCampo, cTabela, cTabCampo , cValValido,aCmpMoeda)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aExcept  := {}
	Local cMsgErr  := ''
	Local cSolucao := ''
	Local cCondic  := ''

	Default cMaster     := ''
	Default cCampo      := ''
	Default cTabela     := ''
	Default cTabCampo   := ''
	Default cValValido  := ''
	Default aCmpMoeda   := {}

	If !Empty(cCampo) .And. !Empty(cTabela)

		aExcept := JCpoExcept(cCampo, M->&cCampo,cTabela,cTabCampo,cValValido) //Usar essa rotina para implementar exeções de validação

		If aExcept[1]
			lRet := aExcept[2]
		Else
			lRet := JurGetDados(cTabela, 1 , xFilial(cTabela) + M-> &cCampo , cTabCampo) == cValValido
		EndIf

		If !lRet
			If Empty(aExcept[3])
				If Empty(cCondic  := JurInfBox(cTabCampo, cValValido))
					cCondic := cValValido
				EndIf
				cMsgErr := I18N(STR0095, {AllTrim(RetTitle(cCampo)), AllTrim(RetTitle(cTabCampo)), cCondic} ) //"O valor digitado no campo '#1' é inválido ou o registro selecionado não atende a condição '#2 = #3'."
			Else
				cMsgErr := aExcept[3]
			EndIf

			If Empty(aExcept[4])
				cSolucao := I18N(STR0097, {AllTrim(RetTitle(cCampo))} ) //"Por favor, verifique o valor digitado no campo '#1'."
			Else
				cSolucao := aExcept[4]
			EndIf

			JurMsgErro(cMsgErr , , cSolucao)
		EndIf

		If lRet .And. Len(aCmpMoeda) > 0
			lRet := ExistCpo('CTO',M->&cCampo,1)
		EndIf

	EndIF

// Valida se a moeda preenchida esta condizente com o período cadastrada.
	If lRet.And.Len(aCmpMoeda) > 0
		If !Empty(aCmpMoeda[1]) .And. !Empty(aCmpMoeda[2]) // Necessário esta preenchida para entrar na validação
			lRet := JurVinMoe(aCmpMoeda[1],aCmpMoeda[2] )
		EndIF
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCpoExcept(cCampo, xValor, cTabela, cTabCampo, cValValido)
Controle de exceção para validação adicional de campo para rotina JAVLDCAMPO().

@param 	cCampo      Campo para validar a exceção
@param 	xValor Valor do campo a ser validado
@param 	cTabela   	Tabela que será consultada
@param 	cTabCampo 	Campo da Tabela de consulta que será validado
@param 	cValValido	Valor que indicará se o campo da tabela é valido

@Return aRet[1]  .T. Se o campo for exceção
@Return aRet[2]  .T. Se a validação for positiva
@Return aRet[3]  Mensagem de erro alternativa

@Obs A Rotina fez necessária para não alterar o comportamento da
rotina principal, utilizada em vários campos.

@author Luciano Pereira dos Santos
@since 29/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCpoExcept(cCampo, xValor, cTabela, cTabCampo, cValValido)
	Local lExcept  := .F.
	Local lValid   := .T.
	Local cMsgErr  := ""
	Local cSolucao := ""
	Local aRet     := {lExcept, lValid, cMsgErr, cSolucao}

	Default cCampo := ""
	Default cTabela    := ""
	Default cTabCampo  := ""
	Default cValValido := ""

	Do Case
	Case cCampo == 'NVE_CESCRI'
		lExcept := SuperGetMV("MV_JFTJURI",, "2" ) == "2" //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
	Case cCampo == 'OH8_SIGLA'
		lExcept := JurGetDados(cTabela, 9 , xFilial(cTabela) + M-> &cCampo , cTabCampo) == cValValido
	OtherWise
		lExcept := .F.
	EndCase

	aRet := {lExcept, lValid, cMsgErr, cSolucao}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurEscrFat()
Filtro para consulta padrao de escritório (NS7) de faturamento
verificando o parametro de integração com o PFS

@Return cRet  Filtro com a validação

@sample @#JurEscrFat()

@author Luciano Pereira dos Santos
@since 29/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurEscrFat()
	Local cRet  := "@#@#"

	If SuperGetMV("MV_JFTJURI",, "2") == "1" .And. !FwIsInCallStack("JURA078") // Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao) e não é o cadastro de Feriado
		cRet := "@#NS7->NS7_EMITEF=='1'@#"
	EndIf

Return cRet

Function JurLoadCon( oGrid, cAlias, cEntida, cChvEnt )
	Local aArea      := GetArea()
	Local aAreaSU5   := GetArea()
	Local aLine      := {}
	Local aRet       := {}
	Local aStruct    := {}
	Local cQuery     := ''
	Local cSelect    := ''
	Local cTmp       := ''
	Local nX         := 0
	Local nI         := 0
	Local oModel     := oGrid:GetModel()
	Local oModelAC8
	nOperation := oModel:GetOperation()

	SU5->( dbSetOrder( 1 ) )

	If !( nOperation == MODEL_OPERATION_INSERT )
		aStruct   := oGrid:oFormModelStruct:GetFields()

		For nX := 1 To Len( aStruct )
			If aStruct[nX][MODEL_FIELD_TIPO] <> "M" .AND. ( cAlias )->( FieldPos( aStruct[nX][MODEL_FIELD_IDFIELD] ) ) <> 0
				cSelect += ", " + aStruct[nX][MODEL_FIELD_IDFIELD]
			EndIf
		Next nX

		cSelect := SubStr( cSelect, 2 ) + " "

		If  cAlias == 'AC8'
			cQuery := " SELECT " + PrefixoCpo( cAlias ) + "_FILIAL, R_E_C_N_O_ RECNO, " + cSelect
			cQuery += "   FROM " + RetSqlName( cAlias ) + " " + cAlias + " "
			cQuery += "  WHERE AC8_FILIAL = '" + xFilial( 'AC8' ) + "' "
			cQuery += "    AND AC8_FILENT = '" + xFilial( cEntida ) + "' "
			cQuery += "    AND AC8_ENTIDA = '" + cEntida + "' "
			cQuery += "    AND AC8_CODENT = '" + cChvEnt + "' "
			cQuery += "    AND AC8.D_E_L_E_T_ = ' ' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "

			cTmp := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

			For nX := 1 To Len( aStruct )
				If ( aStruct[nX][MODEL_FIELD_TIPO] <> "C" .AND. (cTmp)->( FieldPos( aStruct[nX][MODEL_FIELD_IDFIELD] ) ) <> 0 )
					TcSetField( cAlias, aStruct[nX][MODEL_FIELD_IDFIELD], aStruct[nX][MODEL_FIELD_TIPO], aStruct[nX][MODEL_FIELD_TAMANHO], aStruct[nX][MODEL_FIELD_DECIMAL] )
				EndIf
			Next

			While !(cTmp)->( EOF() )
				aLine := {}

				For nX := 1 To Len( aStruct )

					If (cTmp)->( FieldPos( aStruct[nX][MODEL_FIELD_IDFIELD] ) ) <> 0
						aAdd( aLine, (cTmp)->( FieldGet( FieldPos( aStruct[nX][MODEL_FIELD_IDFIELD] ) ) ) )
					Else
						aAdd( aLine, CriaVar( aStruct[nX][MODEL_FIELD_IDFIELD]  ) )
					EndIf

				Next nX

				aAdd( aRet, { (cTmp)->RECNO, aLine } )

				(cTmp)->( dbSkip() )
			End

			(cTmp)->( dbCloseArea() )

		ElseIf cAlias == 'SU5'

			oModelAC8 := oModel:GetModel( 'AC8DETAIL' )

			For nI := 1 To oModelAC8:GetQtdLine()
				oModelAC8:GoLine( nI )
				cCodCont := oModelAC8:GetValue( 'AC8_CODCON' )

				If SU5->( dbSeek( xFilial( 'SU5' ) + cCodCont )  )
					aLine := {}

					For nX := 1 To Len( aStruct )

						If  (cAlias)->( FieldPos( aStruct[nX][MODEL_FIELD_IDFIELD] ) ) <> 0
							aAdd( aLine, (cAlias)->( FieldGet( FieldPos( aStruct[nX][MODEL_FIELD_IDFIELD] ) ) ) )
						Else
							aAdd( aLine, CriaVar( aStruct[nX][MODEL_FIELD_IDFIELD]  ) )
						EndIf

					Next nX

					aAdd( aRet, { (cAlias)->( RECNO()) , aLine } )

				EndIf
			Next

		EndIf

	EndIf

	If Empty( aRet )
		aLine := {}
		For nX := 1 To Len( aStruct )
			aAdd( aLine, CriaVar( aStruct[nX][MODEL_FIELD_IDFIELD] ) )
		Next
		aAdd( aRet, { 0, aLine } )
	EndIf

	RestArea( aAreaSU5 )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094VNT9
Valida se o envolvido pertence ao processo.
Uso Geral.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 16/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAVLDNT9( cEnvolv, cAssJur )
	Local aArea    := GetArea()
	Local aAreaNT9 := NT9->( GetArea() )
	Local lRet     := .F.

	If !Empty(cEnvolv)

		NT9->( dbSetOrder( 2 ) )
		If NT9->( dbSeek( xFilial( 'NT9' ) + cAssJur ) )

			While !NT9->( EOF() ) .AND. xFilial( 'NT9' ) + cAssJur == NT9->NT9_FILIAL + NT9->NT9_CAJURI
				If (cEnvolv == NT9->NT9_COD)
					lRet := .T.
					Exit
				Endif
				NT9->( dbSkip() )
			End

		EndIf

		If !lRet
			JurMsgErro( STR0010 )
		EndIf

	Else
		lRet := .T.
	EndIf

	RestArea( aAreaNT9 )
	RestArea( aArea )

Return lRet

Function JQRYNRL(cTipoA, cTipoS,cArea)
	Local cQuery  := ""

	cQuery := "	SELECT DISTINCT NRL.NRL_COD, NRL.NRL_DESC, NRL.R_E_C_N_O_ NRLRECNO"
	cQuery += "   FROM "+RetSqlName("NRL")+" NRL, "
	cQuery += " 	   "+RetSqlName("NRB")+" NRB  "
	cQuery += " WHERE NRL.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NRB.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NRL.NRL_FILIAL = '" + xFilial( "NRL" ) + "'"

	If !Empty (cTipoS)    //Quando se tratar de histórico, deve-se permitir vincular área inativa, por isso o parâmetro virá vazio.
		cQuery += "   AND NRL.NRL_ATIVO  = '"+cTipoS+"'"
	EndIf

	If !Empty (cArea)
		cArea := StrTran(cArea, ";", "','")
		cArea :=  Iif("','" $ cArea ,LEFT(cArea, (RAT(",", cArea) - 2)),RTrim(cArea) )
		cQuery += "   AND NRL.NRL_CAREA IN ('"+cArea+"')"
		cQuery += "   AND NRL.NRL_CAREA  =  NRB.NRB_COD"
		cQuery += "   AND NRB.NRB_FILIAL = '" + xFilial( "NRB" ) + "'"
	Endif

	If !Empty (cTipoA) //Quando se tratar de histórico, deve-se permitir vincular subárea inativa, por isso o parâmetro virá vazio.
		cQuery += "   AND NRB.NRB_ATIVO  = '"+cTipoA+"'"
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNRLV
Verifica se o valor do campo de subárea é válido conforme a área ativa
e se a subárea está ativa também
Uso Geral.

@param 	cMaster  	Fields ou Grid a ser verificado
@param  cCampo	    Campo de código da subárea a ser verificado
@param  cTipoA		Se a área está ativa ou não (1=Sim;2=Não)
@param  cTipoS		Se a subárea está ativa ou não (1=Sim;2=Não)
@param  cArea		Área a ser verificada
@Return lRet	 	.T./.F. As informações são válidas ou não

@sample
(ExistCpo('NRL',M->NSZ_CSUBAR,1).AND.(JURNRLV('NSZMASTER','NSZ_CSUBAR','1','1',M->NSZ_CAREAJ))).OR.Vazio()

@author Juliana Iwayama Velho
@since 02/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNRLV(cMaster, cCampo, cTipoA, cTipoS, cArea)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := JQRYNRL(cTipoA,cTipoS,cArea)
	Local cAlias   := GetNextAlias()
	Local oModel   := FWModelActive()

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	While !(cAlias)->( EOF() )
		If (cAlias)->NRL_COD == oModel:GetValue(cMaster,cCampo)
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0010)
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNRLF3
Monta a consulta padrão de subárea
Uso Geral.
@param  cTipoA		Se a área está ativa ou não (1=Sim;2=Não)
@param  cTipoS		Se a subárea está ativa ou não (1=Sim;2=Não)

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 24/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNRLF3(cTipoA, cTipoS)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cAreaNRL := ''
	Local cQuery   := ''
	Local oModel   := Nil
	Local oCmpPesq := Nil
	Local aPesq    := {"NRL_COD", "NRL_DESC"}
	Local nResult  := 0
	Local nCt      := 0

	Default cTipoA := '2'
	Default cTipoS := '1'


	If IsPesquisa()

		oCmpPesq := J162CmpPes()

		For nCt := 1 To Len(oCmpPesq)
			If oCmpPesq[nCt]:CNomeCampo == 'NSZ_CAREAJ'
				cAreaNRL := oCmpPesq[nCt]:Valor
				Exit
			Endif
		Next

	Else

		oModel   := FwModelActive()

		If  oModel:GetId() == 'JURA095'  .Or. oModel:GetId() == 'JURA055'
			cAreaNRL := FwFldGet( 'NSZ_CAREAJ' )
		ElseIf  oModel:GetId() == 'JURA070'
			If "NUU_CSUBAR" $ readvar()
				cAreaNRL := FwFldGet( 'NUU_CAREAJ' )
			Else
				cAreaNRL := FwFldGet( 'NVE_CAREAJ' )
			EndIf
		EndIf

	EndIf

	cQuery := ChangeQuery(JQRYNRL(cTipoA,cTipoS,cAreaNRL), .F. )

	RestArea( aArea )

	nResult := JurF3SXB("NRL", aPesq, "", .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("NRL")
		NRL->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURCORVLRS
Realiza a correção monetária dos valores conforme assunto jurídico
Uso Geral.

@param  cTabela     - Nome da tabela
@param  cCajuri     - Código do assunto juridico
@param  lRecalculo  - Define se será recalculado o valor
@param  cDataCorte  - Data de corte
@param  lAuto       - Define a execução é feita sem a tela
@param  lFiltraExtr - Define se irá utilizar o filtro extra
@param  cFiltroExtr - valor do campo extra pra filtrar, no caso, filtrar pelo campo NSY_CVERBA

@Return lRet .T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 15/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURCORVLRS(cTabela, cCajuri, lRecalculo, cDataCorte, lAuto, lFiltraExtr, cFiltroExtr)
	Local lRet 	     := .T.
	Local cAssJur    := &(cTabela+'->'+cTabela+'_CAJURI')
	Local cFilJur    := &(cTabela+'->'+cTabela+'_FILIAL')
	Local lHideMsg   := .F.

	Default cCajuri     := ""
	Default lRecalculo  := .F.
	Default cDataCorte  := Nil
	Default lAuto       := .F.
	Default lFiltraExtr := .F.
	Default cFiltroExtr := ""

	lHideMsg := JurAuto() .Or. lAuto

	If !lHideMsg
		lRet := ApMsgYesNo(STR0014)
	EndIf

	If lRet
		If !Empty(cCajuri)
			cAssJur := cCajuri
		EndIF

		If !Empty(cAssJur)
			lRet := JURA002({ {cAssJur,cFilJur} },{cTabela},!lHideMsg,cDataCorte,{},,lRecalculo,lFiltraExtr, cFiltroExtr)
		EndIf
	EndiF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValTpAs
Valida se o código do assunto jurídico pode ser utilizado pelo usuário
conforme o tipo de assunto jurídico vinculado ao mesmo.
Uso Geral.

@param  cAssJur		Código do assunto jurídico

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 21/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurValTpAs(cAssJur)
	Local lRet  := .T.
	Local cSQL  := ""
	Local cAlias:= Nil
	Local aArea := GetArea()

	If !IsPesquisa() .And. !Empty(cAssJur)

		cSQL := "SELECT NSZ_COD CODIGO FROM "+RetSqlName("NSZ")+" NSZ"
		cSQL += " WHERE NSZ_FILIAL = '"+xFilial("NSZ")+"' "
		cSQL += "   AND NSZ.D_E_L_E_T_ = ' ' "
		cSQL += "   AND NSZ.NSZ_COD = '"+cAssJur+"'"

		if IsInCallStack( 'JURA162' ) .Or. IsBlind() //Automação de testes
			cSQL += "   AND NSZ.NSZ_TIPOAS IN (" + JurTpAsJr(__CUSERID) + ") "
		endif

		cSQL  := ChangeQuery(cSQL)
		cAlias:= GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAlias,.T.,.T.)

		If (cAlias)->(EOF())
			lRet := .F.
			JurMsgErro(STR0016)
		EndIf

		(cAlias)->( dbcloseArea() )

	EndIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JurVDtDist
Valida se a data é superior a atual ou inferior a data de distribuição
Uso Geral.

@param  cCampoAs		Campo de assunto jurídico
@param  cCamposDt		Campo de data

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 22/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVDtDist(cCampoAs,cCampoDt)
	Local cAliasAtu  := Alias()
	Local cAliasCpo  := ""
	Local aArea      := GetArea()
	Local aAreaNUQ   := NUQ->( GetArea() )
	Local lRet       := .T.
	Local cAssJur    := FwFldGet(cCampoAs)
	Local dData      := FwFldGet(cCampoDt)
	Local dDistrib   := ''
	Local oModel     := FWModelActive()
	Local aSaveLines := FWSaveRows()
	Local oModelNUQ  := oModel:GetModel('NUQDETAIL')
	Local nCt

//Tratamento para evitar a chamada da RetTitle sem que exista area selecionada
	If Empty(cAliasAtu)
		cAliasCpo := Left(cCampoAs,3)

		If SubStr(cAliasCpo,3,1) == "_"
			cAliasCpo := "S" + SubStr(cAliasCpo,1,2)
		EndIf

		DbSelectArea(cAliasCpo)
	EndIf

	If oModelNUQ <> Nil
		For nCt := 1 To oModelNUQ:GetQtdLine()
			oModelNUQ:GoLine( nCt )
			If oModelNUQ:GetValue('NUQ_INSATU') == '1' .And. !oModelNUQ:IsDeleted()
				dDistrib := oModelNUQ:GetValue('NUQ_DTDIST')
			EndIf
		Next
	EndIf

	If !Empty(cAssJur) .And. !Empty(dDistrib) .And. !Empty(dData)
		If dData > Date()
			If ( (Alltrim(cCampoDt) <> 'NSZ_DTENVO') .Or. (SuperGetMV('MV_JBLQDTF',, '1') == '1') )
				JurMsgErro(STR0019 + AllTrim(RetTitle(cCampoDt)) + STR0017)
				lRet := .F.
			EndIf
		Else
			If SuperGetMV('MV_JBLQDIS',, '1') == '1'
				If !Empty(dDistrib)
					If (dData < dDistrib)
						JurMsgErro(STR0019 + AllTrim(RetTitle(cCampoDt)) + STR0018)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNUQ )
	RestArea(aArea)

	FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTpAsJr
Função que verifica os tipo de assuntos jurídicos que o usuário esta
habilitado para filtrar os registros dos cadastros filhos, como Andamento,
Follow-up, Garantias, Despesas.

@Param cUser   - Código do usuário
@param lSepara - Boleano para concatenar os tipos para consulta padrão (.T./.F.)

@Return cTipoAj - Código(s) do(s) tipo(s) de assunto jurídico

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTpAsJr(cUser,lSepara,dConf)
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local aVetor    := {}
	Local cTipoAj   := "'00'"  // '00' // By JPP - 07/03/2014 - 15:18 - Todos os dados desta função são retornados com aspas simples. Alem das apas simples, os dados devem estar entre aspas para consider a expressão com caracter e manter as aspas simples.
	Local cQuery    := ""
	Local nI        := 1
	Local lWSTLegal := .F.
	Local lNVKNvCmp := .F.

	Default lSepara := .T.
	Default dConf   :=  ''

	cQuery := " SELECT DISTINCT NVJ.NVJ_CASJUR CASJUR"
	cQuery += " FROM " + RetSqlName("NVJ") + " NVJ, " + RetSqlName("NYB") + " NYB, " + RetSqlName("NVK") + " NVK"
	cQuery += " WHERE NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "'"
	cQuery +=   " AND NYB.NYB_FILIAL = '" + xFilial("NYB") + "'"
	cQuery +=   " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "'"
	cQuery +=   " AND NVJ.NVJ_CASJUR = NYB.NYB_COD"
	cQuery +=   " AND NVK.NVK_CPESQ  = NVJ.NVJ_CPESQ"
	cQuery +=   " AND ( NVK.NVK_CUSER = '" + cUser + "'"

	//Usuários x Grupos
	DbSelectArea("NVK")
	If ColumnPos("NVK_CGRUP") > 0 .And. FWAliasInDic("NZY")
		cQuery +=   "  OR NVK_CGRUP IN (SELECT NZY_CGRUP"
		cQuery +=                       " FROM " + RetSqlName("NZY") + " NZY"
		cQuery +=                      " WHERE NZY_FILIAL = '" + xFilial("NZY") + "'"
		cQuery +=                        " AND NZY.NZY_CUSER = '" + cUser + "'"
		cQuery +=                        " AND NZY.D_E_L_E_T_ = ' ') )"
	Else
		cQuery += " )"
	EndIf

	cQuery += " AND NVK.D_E_L_E_T_ = ' '"
	cQuery += " AND NVJ.D_E_L_E_T_ = ' '"
	cQuery += " AND NYB.D_E_L_E_T_ = ' '"

	lWSTLegal := JModRst() .Or. isInCallStack('GET_TPASSUNTOJUR') .Or. isInCallStack('WsJGetTpAss') .Or. isInCallStack('GET_CHILDRENLEGALMATTER')
	If lWSTLegal
		//Verifica se o campo NVK_CASJUR existe no dicionário
		If Select("NVK") > 0
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		Else
			DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
			NVK->( DBCloseArea() )
		EndIf

		If lNVKNvCmp
			cQuery += " UNION "
			cQuery += " SELECT DISTINCT NVK.NVK_CASJUR CASJUR "
			cQuery += " FROM   " + RetSqlName("NYB") + " NYB, "
			cQuery +=              RetSqlName("NVK") + " NVK "
			cQuery += " WHERE  NYB.NYB_FILIAL = '" + xFilial("NYB") + "' "
			cQuery +=        " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
			cQuery +=        " AND ( NVK.NVK_CUSER = '" + cUser + "' "
			cQuery +=              " OR NVK_CGRUP IN (SELECT NZY_CGRUP "
			cQuery +=                               " FROM   " + RetSqlName("NZY") + " NZY "
			cQuery +=                               " WHERE  NZY_FILIAL = '" + xFilial("NZY") + "' "
			cQuery +=                                      " AND NZY.NZY_CUSER = '" + cUser + "' "
			cQuery +=                                      " AND NZY.D_E_L_E_T_ = ' ') ) "
			cQuery +=       " AND NVK.D_E_L_E_T_ = ' ' "
			cQuery +=       " AND NYB.D_E_L_E_T_ = ' ' "
		EndIf
	EndIf

	If !Empty(dConf)
		Do Case
		Case J162Active()
			cPesq := J162GetPesq()
		Case J163Active()
			cPesq := J163GetPesq()
		End Case

		cQuery += " AND NVJ.NVJ_CPESQ = '" + cPesq + "'"
	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasQry, .T., .F.)

	While !(cAliasQry)->( EOF())
		If !Empty((cAliasQry)->CASJUR)
			aAdd(aVetor, (cAliasQry)->CASJUR )
		EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	If Len(aVetor) == 0
		Return cTipoAj

	ElseIf Len(aVetor) == 1
		cTipoAj := "'"+aVetor[1]+"'"

	Else
		If lSepara
			cTipoAj := ""
			For nI := 1 to LEN(aVetor)
				cTipoAj += "'"+aVetor[nI]+"'"
				If nI < LEN(aVetor)
					cTipoAj += ","
				Endif
			Next
		Else
			cTipoAj := "'"
			For nI := 1 to LEN(aVetor)
				cTipoAj += aVetor[nI]
				If nI < LEN(aVetor)
					cTipoAj += "/"
				Endif
			Next

			cTipoAj += "'"
		EndIf
	Endif

	RestArea(aArea)

Return cTipoAj
//-------------------------------------------------------------------
/*/{Protheus.doc} JurGrpRest
Verifica o grupo de acesso para restrição do SIGAJURI
Uso Geral.

@Return cTipoA  Clientes
                  Correspondentes
                  Matriz

@author Juliana Iwayama Velho
@since 18/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGrpRest(cUser)

	Local aAreaGru   := GetArea()
	Local cAliasGrup := GetNextAlias()
	Local cTipoA     := ''
	Local cQuery     := ""
	Local lNZXInDic  := .F.
	Local lNZYInDic  := .F.

	Default cUser := __CUSERID

	If SELECT('SX2') > 0 //No SIGAMDI o dicionário não está aberto ao expandir menu, só ao entrar nas rotinas.
		//Verifica se o SX2 está aberto. Caso não esteja, não executa query e retorna o tipo de acesso 'Ambiente fechado'.
		lNZXInDic := FWAliasInDic("NZX") // GRUPO DE USUÁRIOS
		lNZYInDic := FWAliasInDic("NZY") // USUÁRIOS X GRUPO

		// Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
		If !lNZXInDic .Or. !lNZYInDic // Caso não existam as novas tabelas executa a rotina antiga de grupos de usuários (via configurador - SIGACFG)
			cTipoA := GrpRestCFG(cUser)
		Else

			cQuery := " SELECT A.NVK_TIPOA "
			cQuery += "  FROM " + RetSqlName("NVK") + " A "
			cQuery += "   JOIN " + RetSqlName("NZY") + " B "
			cQuery += "   ON NZY_CGRUP = A.NVK_CGRUP "
			cQuery += "   AND NZY_CUSER = '" + cUser + "' "
			cQuery += "   AND A.D_E_L_E_T_ = ' ' "
			cQuery += "   AND B.D_E_L_E_T_ = ' ' "
			cQuery += "   AND A.NVK_FILIAL = '" + xFilial("NVK") + "' "
			cQuery += "   AND B.NZY_FILIAL = '" + xFilial("NZY") + "' "
			cQuery += " UNION "
			cQuery += " SELECT NVK.NVK_TIPOA "
			cQuery += "  FROM " + RetSqlName("NVK") + " NVK "
			cQuery += "   WHERE NVK.NVK_CUSER = '" + cUser + "' "
			cQuery += "   AND NVK.D_E_L_E_T_ = ' ' "
			cQuery += "   AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasGrup, .T., .F.)

			If (cAliasGrup)->(!Eof())
				cTipoA := (cAliasGrup)->NVK_TIPOA
				cTipoA := JTrataCbox( 'NVK_TIPOA', cTipoA )
			EndIf

			(cAliasGrup)->( dbCloseArea() )

		EndIf
	Else
		cTipoA := STR0096	//"Ambiente fechado"
	EndIf

	RestArea(aAreaGru)

Return cTipoA

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValSA2
Validação o correspondente conforme a disponibilidade do módulo
Jurídico e usuário ativo
Uso no cadastro de Instância.

@Return lRet	 	.T./.F. As informações são válidas ou não

@param  cEscritorio		Código do correspondente
@param  cLojaEsc		Loja do correspondente

@author Juliana Iwayama Velho
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurValSA2(cEscritorio,cLojaEsc)
	Local lRet     := .T.
	Local cCorresp := ''
	Local cLoja    := ''

	cCorresp := FWFldGet(cEscritorio)
	cLoja    := FWFldGet(cLojaEsc)

	If JurGetDados('SA2', 1 , xFilial('SA2') + cCorresp + cLoja , 'A2_MJURIDI') <> '1' .Or.;
			JurGetDados('SA2', 1 , xFilial('SA2') + cCorresp + cLoja , 'A2_MSBLQL') <> '2'
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValNW7(nCodFrCrr)
Validação dos campos de Formas de Correção caso código não seja vísivel na Cons. Padrão

@Return lRet	 	.T./.F. As informações são válidas ou não

@param  nCodFrCrr	Código da Forma de Correção

@author Tiago Martins
@since 23/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurValNW7(nCodFrCrr)

	Local lRet := .F.

	//Valida preenchimento do campo de forma de correção
	If Empty(nCodFrCrr) .Or. JurGetDados('NW7', 1, XFILIAL('NW7') + nCodFrCrr, 'NW7_VISIV') == '1'
		lRet:= .T.
	EndIf

	//Limpa os campos atualizados pela correção monetária
	If lRet
		J002ClrAtu()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurErrLog(cMemo,cTitulo)
Rotina adaptada da função MostraErro() para exibir uma janela de log
de erro a partir de um texto.

@Params     cMemo    Texto para exibido na janela de log.
@Params     cTitulo  Título da janela de log
@Params     cLevel   Tipo da mensagem (ex.: INFO) para ser mostrado
                     na mensagem no console
@Params     cModulo  Módulo para ser mostrado na mensagem no console

@Returns    Nil

@author Luciano Pereira dos Santos

@since 11/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurErrLog(cMemo, cTitulo, cLevel, cModulo)
	Local oDlg      := Nil
	Local oFont     := Nil
	Local cFile     := ""
	Local cMask     := STR0020 //"Arquivos Texto (*.TXT) |*.txt|"

	Default cTitulo := "Error Log"
	Default cLevel  := ""
	Default cModulo := ""

	If !Empty(cMemo)

		If !IsBlind()

			DEFINE FONT oFont NAME "Courier New" SIZE 5, 0

			DEFINE MSDIALOG oDlg TITLE cTitulo From 3, 0 to 340, 417 PIXEL

			@ 5, 5 GET oMemo  VAR cMemo MEMO SIZE 200, 145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont := oFont

			DEFINE SBUTTON  FROM 153,175 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL

			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile := cGetFile(cMask, OemToAnsi(STR0021)),; //"Salvar Como..."
			If(cFile == "", .T., MemoWrite(cFile, cMemo)), oDlg:End()) ENABLE OF oDlg PIXEL

				DEFINE SBUTTON  FROM 153,115 TYPE 6  ACTION (JurPrtErr(cMemo), oDlg:End()) ENABLE OF oDlg PIXEL //Imprime

				ACTIVATE MSDIALOG oDlg CENTER

			Else

				JurLogMsg(cMemo, cLevel, cModulo)

			EndIf
		EndIf

		Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPrtErr(cMemo)
Rotina auxiliar da função JurErrLog() para imprimir o conteudo da
janela do log.

@Params		cMemo	texto da janela de log para impresso.

@Returns	Nil

@author Luciano Pereira dos Santos

@since 11/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurPrtErr(cTexto)
	Local nLinha	:= ""
	Local nLin		:= 0
	Local nX   		:= 0
	Local cFileLog  := NomeAutoLog()

	Default cTexto  := ""

	If !Empty(cFileLog)
		If File(cFileLog)
			FErase(cFileLog)
		EndIf
	EndIf

	AutoGRLog(cTexto)
	cFileLog := NomeAutoLog()

	Private aReturn:= {STR0022, 1, STR0023, 1, 2, 1, "",1 }   //"Zebrado" ### "Administracao"

	SetPrint(,cFileLog ,nil ,STR0024, cFileLog,'','',.F.,"",.F.,"M") //"Impressão do Log"
	If nLastKey <> 27
		SetDefault(aReturn,"")
		nLinha:= MLCount(cTexto,132)
		For nX:= 1 To nLinha
			nLin++
			If nLin > 80
				nLin := 1
				@ 00,00 PSAY AvalImp(132)
			Endif
			@ nLin,000 PSAY Memoline(cTexto,132,nX)
		Next nX
		Set device to Screen
		MS_FLUSH()
	EndIf

	If File(cFileLog)
		FErase(cFileLog)
	EndIf

Return Nil

///-------------------------------------------------------------------
/*/{Protheus.doc} JurIntJuri
Commit dos dados
@author Clóvis Eduardo Teixeira
@since 15/12/09
@version 1.0
/*/
//--------------------------------------------------------------------
Function JurIntJuri(cChave, cCajuri, cRotina, cOperacao)
	Local cCliente  := JurGetDados('NSZ', 1, xFilial('NSZ') + cCajuri, 'NSZ_CCLIEN')
	Local cLoja     := JurGetDados('NSZ', 1, xFilial('NSZ') + cCajuri, 'NSZ_LCLIEN')
	Local aArea    	:= GetArea()

	ChkFile("NV9")

	NV6->(dbSetOrder( 1 ))
	if NV6->(dbSeek(xFilial('NV6') +cCliente +cLoja +cRotina))
		Begin TransAction
			if RecLock('NV9', .T.)
				NV9->NV9_FILIAL := xFilial('NV9')
				NV9->NV9_COD    := GetSXeNum("NV9","NV9_COD")
				NV9->NV9_ROTINA := cRotina
				NV9->NV9_TIPO   := AllTrim(cOperacao)
				NV9->NV9_CHAVE  := cChave
				NV9->NV9_CAJURI := cCajuri
				NV9->NV9_CINTJU := NV6->NV6_COD
				NV9->NV9_FLAGEN := "N"

				MsUnlock()
			Endif
		End TransAction
	Endif

	RestArea( aArea )

Return Nil


///-------------------------------------------------------------------
/*/{Protheus.doc} JurIntJuri
Commit dos dados
@author Clóvis Eduardo Teixeira
@since 15/12/09
@version 1.0
/*/
//--------------------------------------------------------------------
Function JURGetCampos(cTipoPedido)
	Local aCampos := {}

	Do Case
	Case cTipoPedido == "P"
		aAdd(aCampos, {"NSY_VLRMUL", "NSY_VLRJUR"})
	Case cTipoPedido == "1"
		aAdd(aCampos, {"NSY_VLRMU1", "NSY_VLRJU1"})
	Case cTipoPedido == "2"
		aAdd(aCampos, {"NSY_VLRMU2", "NSY_VLRJU2"})
	Case cTipoPedido == "T"
		aAdd(aCampos, {"NSY_VLRMT" , "NSY_VLRJUT"})
	Case cTipoPedido == "C"
		aAdd(aCampos, {"NSY_VLRMUC", "NSY_CLRJUC"})
	Case cTipoPedido == "PA"
		aAdd(aCampos, {"NSY_MUATUA", "NSY_JURATU"})
	Case cTipoPedido == "1A"
		aAdd(aCampos, {"NSY_MUATU1", "NSY_JUATU1"})
	Case cTipoPedido == "2A"
		aAdd(aCampos, {"NSY_MUATU2", "NSY_JUATU2"})
	Case cTipoPedido == "TA"
		aAdd(aCampos, {"NSY_MUATT" , "NSY_JUATUT"})
	Case cTipoPedido == "CA"
		aAdd(aCampos, {"NSY_MUATC" , "NSY_JUATUC"})
	EndCase

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JurHisCont
Faz a gravacao das alteracoes na tabela de historico de movimentaçoes

@param  cCajuri --> Codigo do processo
@param  cCod	  --> Codigo da Garantia/ Despesas
@param  cDataVl --> Data de cadastro da Garantia (NT2) ou Despesas (NT3)
@param  cTipoM  --> Codigo de Tipo de Movimentação. (1 -> Valor / 2-> Correção / 3-> Juros)
@param  cTipoL	  --> Codigo de Origem da chamada. Onde ocorreu a chamada (1-> Processos	/ 2-> Garantias / 3-> Despesas)
@param  cPrefixo--> Codigo de prefixo da tabela correspondente.  ('NSZ' -> Processos  / 'NT2' -> Garantias / 'NT3' -> Despesas)
@param  nOpc	  --> Codigo de operação efetuada no model (oModel:GetOperation())
@param  cGrupo	  --> Codigo do grupo de aprovação

@return

@author Jorge Luis Branco Martins Junior
@since 16/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurHisCont(cCajuri, cCod	 , cDataVl, nValor , cTipoM ,;
		cTipoL , cPrefixo, nOpc	  , cGrupo , lAjuste,;
		cProgn , cCEmpCl , cLojaCl, lAltRat, cSituac,;
		cPrognA, cFilDest, lIntCom)

	Local aArea       := GetArea()
	Local aAreaNV3    := NV3->(GetArea())
	Local lRet        := .F.
	Local lCondicao   := .F.
	Local lCondInteg  := .F.
	Local lOk         := .T.
	Local lAlcada     := (SuperGetMV('MV_JALCADA',, '2') == '1')
	Local lCtb        := (SuperGetMV('MV_JCTBFIN',, '1') == '1') //1=Contabilização de levantamentos diretamente via contábil; 2=Via módulo financeiro
	Local lFluigAp    := (SuperGetMV('MV_JFLUIGA',, '2') == '1') //Aprovações via FLUIG - Uso na auditoria
	Local aCampos     := {}
	Local aCamposB    := {}
	Local aRegistro   := {}
	Local aRegistroB  := {}
	Local cSQL        := ""
	Local cOpera      := ""
	Local cSQLEx      := ""
	Local cPedido     := ""
	Local cRet        := Nil
	Local cRetEx      := Nil
	Local nOpera      := 0
	Local nCont       := 0
	Local lAlvara     := .F.
	Local lTit        := .F.
	Local lData       := .F.
	Local lValor      := .F.
	Local lRatEnv     := .F.
	Local lPrognAlt   := .F.
	Local lSituaAlt   := .F.
	Local lJAGERPAG   := ExistBlock( 'JAGERPAG' )
	Local oModelSAVE  := FWModelActive()
	Local lCposAudit  := .F.
	Local cFilSE2     := ""
	Local cCodArea    := Posicione('NSZ', 1, Xfilial('NSZ') + cCajuri, 'NSZ_CAREAJ')

	DbSelectArea("NV3")
	lCposAudit := ColumnPos('NV3_PROGN') > 0 .And. ColumnPos('NV3_CEMPCL') > 0 .And. ColumnPos('NV3_LOJACL') > 0 .And. ColumnPos('NV3_SITPRO') > 0 // Indica se existem os campos que fazem parte do requisito de auditoria (Proteção)

	If (cTipoL == '9') .Or. (cTipoL == 'B')
		lAlvara := .T.
	EndIf

	If nOpc == 4 //Se for uma alteracao
		nOpera := 3 //A variavel de operacao do historico vira de inclusao ja que vai incluir um novo registro
	Else
		nOpera := nOpc
	EndIf

	Default cCod     := ""
	Default cPrefixo := ""
	Default cGrupo   := ""
	Default cPrognA  := "" //Prognóstico Anterior - Apenas para valores de provisão
	Default cProgn   := "" //Prognóstico - Apenas para valores de provisão
	Default cCEmpCl  := "" //Envolvido - Cliente - Usado no rateio de provisão por envolvido
	Default cLojaCl  := "" //Envolvido - Loja - Usado no rateio de provisão por envolvido
	Default cSituac  := "1" //Situação do processo - Apenas para valores de provisão
	Default lAjuste  := .F.
	Default lAltRat  := .F. //Indica que houve mudança ou inclusão de envolvido para rateio
	Default cFilDest := xFilial("NV3")
	Default lIntCom  := .F.

	If lCposAudit
		aCampos := {"NV3_FILIAL", "NV3_COD", "NV3_CAJURI", "NV3_CODLAN", "NV3_DATA", "NV3_DATAVL", "NV3_VALOR", "NV3_TIPOM", "NV3_TIPOL", "NV3_OPERA", "NV3_PEDIDO", "NV3_LA", "NV3_PROGN", "NV3_CEMPCL", "NV3_LOJACL", "NV3_SITPRO", "NV3_FILORI", "NV3_CAREAJ"}	//18
		cSQL := "SELECT NV3.NV3_COD CODIGO, NV3.NV3_DATAVL DATAVALOR, NV3.NV3_CAJURI CAJURI , NV3.NV3_CODLAN CODLAN , NV3.NV3_VALOR VALOR, NV3.NV3_OPERA OPERA, NV3.NV3_PROGN PROGN, NV3_CEMPCL CEMPCL, NV3_LOJACL LOJACL, NV3_SITPRO SITUAC, NV3_FILORI, A.MENOR, A.SOMA"+ CRLF
	Else
		lAltRat  := .F.
		lFluigAp := .F.
		cProgn   := ""
		cCEmpCl  := ""
		cLojaCl  := ""
		cSituac  := ""
		cPrognA  := ""

		aCampos := {"NV3_FILIAL", "NV3_COD", "NV3_CAJURI", "NV3_CODLAN", "NV3_DATA", "NV3_DATAVL", "NV3_VALOR", "NV3_TIPOM", "NV3_TIPOL", "NV3_OPERA", "NV3_PEDIDO", "NV3_LA", "NV3_FILORI", "NV3_CAREAJ"}	//14
		cSQL := "SELECT NV3.NV3_COD CODIGO, NV3.NV3_DATAVL DATAVALOR, NV3.NV3_CAJURI CAJURI , NV3.NV3_CODLAN CODLAN , NV3.NV3_VALOR VALOR, NV3.NV3_OPERA OPERA, NV3_FILORI, A.MENOR, A.SOMA"+ CRLF
	EndIf

//Query que indica o historico do registro atual
//cSQL := "SELECT NV3.NV3_COD CODIGO, NV3.NV3_DATAVL DATAVALOR, NV3.NV3_CAJURI CAJURI , NV3.NV3_CODLAN CODLAN , NV3.NV3_VALOR VALOR, NV3.NV3_OPERA OPERA, NV3.NV3_PROGN PROGN, NV3_CEMPCL CEMPCL, NV3_LOJACL LOJACL, NV3_SITPRO SITUAC, A.MENOR, A.SOMA"+ CRLF
	cSQL += "  FROM "+RetSqlName("NV3") +" NV3, (SELECT MIN(NV3_COD) MENOR, SUM(NV3_VALOR) SOMA, NV3_CAJURI, NV3_CODLAN"+ CRLF
	cSQL += "  											FROM "+RetSqlName("NV3")
	cSQL += "  										   WHERE NV3_CAJURI = '"+cCajuri+"'"+ CRLF
	cSQL += "  										   AND NV3_CODLAN = '"+cCod+"'"+ CRLF
	cSQL += "  											 AND NV3_TIPOL = '"+cTipoL+"'"+ CRLF
	cSQL += "  											 AND NV3_TIPOM = '"+cTipoM+"'"+ CRLF

	If lFluigAp
		cSQL += "  											 AND NV3_PROGN <> '2'"+ CRLF
		cSQL += "  											 AND NV3_PROGN <> '3'"+ CRLF
	EndIf

	cSQL += "  											 AND D_E_L_E_T_ = ' '"+ CRLF

	If lAltRat .OR. (!Empty(cCEmpCl).And.!Empty(cLojaCl))
		cSQL += "  	 AND NV3_CEMPCL = '"+cCEmpCl+"'"+ CRLF
		cSQL += "  	 AND NV3_LOJACL = '"+cLojaCl+"'"
	EndIf

	cSQL += "  											 GROUP BY NV3_CAJURI, NV3_CODLAN) A"+ CRLF
	cSQL += "  WHERE NV3.NV3_CAJURI = A.NV3_CAJURI"+ CRLF
	cSQL += "  	 AND NV3.NV3_CODLAN = A.NV3_CODLAN"+ CRLF
	cSQL += "  	 AND NV3_TIPOL = '"+cTipoL+"'"+ CRLF
	cSQL += "  	 AND NV3_TIPOM = '"+cTipoM+"'"+ CRLF
	cSQL += "  	 AND NV3.NV3_FILIAL = '"+xFilial("NV3")+"' " + CRLF
	cSQL += "  	 AND NV3.D_E_L_E_T_ = ' '"

	If lAltRat .OR. (!Empty(cCEmpCl).And.!Empty(cLojaCl))
		cSQL += "  	 AND NV3_CEMPCL = '"+cCEmpCl+"'"+ CRLF
		cSQL += "  	 AND NV3_LOJACL = '"+cLojaCl+"'"
	EndIf

	cSQL := ChangeQuery(cSQL)
	cRet := GetNextAlias()
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cRet, .T., .F.)

	If (cRet)->( EOF() )//Se nao existir historico
		If nOpc == 5      //Se for exclusao de um dado que nao tem historico, simplesmente exclui
			lRet := .T.
		Else
			If lAlcada .AND. (cPrefixo == 'NT3' .Or. cPrefixo == 'NT2') .AND. cTipoM == '1'
				cPedido := AVKey( Criavar("C7_NUM",.T.), "C7_NUM")
				If Empty(Alltrim(cPedido))
					cPedido := AVKey( GetSXENum("SC7", "C7_NUM"), "C7_NUM")
				EndIf
			EndIf

			If cPrefixo == 'NT2' .And. ( (cTipoM == '1' .AND. !lAlvara) .or. (lAlvara .AND. cTipoM <> '1' .And. !lAjuste) ) // Apenas se for valor original de garantias, ou se for correção ou juros de alvará terá o Grupo de aprovação, pois vão para o financeiro. Não pode ser ajuste, pois ajuste não vai para o financeiro.

				aCampos := {"NV3_FILIAL", "NV3_COD", "NV3_CAJURI", "NV3_CODLAN", "NV3_DATA", "NV3_DATAVL", "NV3_VALOR", "NV3_TIPOM", "NV3_TIPOL", "NV3_OPERA", "NV3_PEDIDO", "NV3_LA", "NV3_GRPAPR", "NV3_FILORI", "NV3_CAREAJ"}	//15

				If lAlvara .And. !lCtb// Se for correção e juros de levantamento que serão contabilizados pelo financeiro o campo NV3_LA deve estar como 'S'.
					aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, nValor, cTipoM, cTipoL, '3', cPedido, 'S', cGrupo, cFilDest, cCodArea}	//15
				Else
					aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, nValor, cTipoM, cTipoL, '3', cPedido, 'N', cGrupo, cFilDest, cCodArea}	//15
				EndIf
			Else

				If lCposAudit
					aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, nValor, cTipoM, cTipoL, '3', cPedido, 'N', cProgn, cCEmpCl, cLojaCl, cSituac, cFilDest, cCodArea}	//18
				Else
					aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, nValor, cTipoM, cTipoL, '3', cPedido, 'N', cFilDest, cCodArea}	//14
				EndIf
			EndIf

			lRet := JurOperacao(nOpera, "NV3",,, aCampos, aRegistro) //Faz a inclusao no historico
			If lRet .AND. ((cPrefixo <> 'NSZ' .AND. !lAlvara) .Or. (lAlvara .AND. cTipoM <> '1')) //Se for o Valor (nao for correcao nem juros), ou se for correção ou juros de alvará
				nCont += 1
				If !lAlcada .Or. lAlvara //Caso não tiver controle de alçada ou seja alvará (alvarás não passam por controle de alçada)
					// <-- Ponto de Entrada para permitir a customização das informações gravadas no financeiro  -->
					If lJAGERPAG .AND. cTipoL <> '1'
						lRet := ExecBlock( 'JAGERPAG',,, { nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3' } )
					Else
						lRet := JurGerPag(nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3', nCont, (lCtb .And. lAlvara), cTipoM, aRegistro[2] ) //Grava o titulo com o valor
					EndIf
				Else
					If cPrefixo == 'NT2' .And. !lIntCom // Se não tiver a integraçao com compras, ele terá o mesmo comportamento de antes

						//Gera o documento para aprovação no compras
						//Se geração retornar .T., titulo pode ser gerado direto sem alçada, caso contrário foi gerado com bloqueio, necessitando de aprovação
						//MaAlcDoc({'NV3'+aRegistro[2],'GA',nValor,,,cGrupo,,,,aRegistro[6],cObs},dRefer,1)
						// <-- Ponto de Entrada para permitir a customização das informações gravadas no financeiro -->
						If lJAGERPAG .AND. cTipoL <> '1'
							lRet := ExecBlock( 'JAGERPAG',,, { nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3' } )
						Else
							lRet := JurGerPag(nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3', nCont, /*lCtb*/, cTipoM,/*cCodNV3*/,cGrupo) //Grava o titulo com o valor
						EndIf
					Else
						// <-- Ponto de Entrada para permitir a customização das informações gravadas no financeiro -->
						If lJAGERPAG .AND. cTipoL <> '1'
							lRet := ExecBlock( 'JAGERPAG',,, { nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, cPedido } )
						Else
							lRet := JurContAlc(nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, cPedido, cGrupo) //Grava o pedido de compras com o valor
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		cOpera := (cRet)->OPERA

		//Preenche a Filial da SE2 com a filial origem para tratar os casos de filial destino preenchida
		If Empty( (cRet)->NV3_FILORI )
			cFilSE2 := xFilial("SE2")
		Else
			cFilSE2 := FwxFilial("SE2", (cRet)->NV3_FILORI)
		EndIf

		//Verificacao se houve alteracao em campos cruciais
		If cPrefixo == 'NSZ'
			If lCposAudit
				lRatEnv    := !Empty(cCEmpCl) .And. !Empty(cLojaCl) //Indica se existe Rateio por envolvidos
				lPrognAlt  := AllTrim(cProgn) <> AllTrim((cRet)->PROGN) .OR. (!Empty(AllTrim(cPrognA)) .And. AllTrim(cPrognA) <> AllTrim(cProgn)) //Indica se o prognóstico do processo (NSZ) foi alterado
				lSituaAlt  := AllTrim(cSituac) <> AllTrim((cRet)->SITUAC) //Indica se a situação do processo (NSZ) foi alterada
			EndIf
			lCondicao  := (cCajuri == (cRet)->CAJURI) .AND. ((DToS(cDataVl) <> (cRet)->DATAVALOR) .OR. (Round (nValor,2) <> (cRet)->SOMA) .OR. lPrognAlt .Or. lRatEnv .Or. lSituaAlt)
			lData      := (DToS(cDataVl) <> (cRet)->DATAVALOR)
			lValor     := (Round (nValor,2) <> (cRet)->SOMA) .Or. lAltRat //Caso tenha rateio por envolvido conta como alteração de valor.
			lCondInteg := .T.
		Else
			lCondicao := (cCajuri == (cRet)->CAJURI) .AND. (cCod == (cRet)->CODLAN) .AND. ((DToS(cDataVl) <> (cRet)->DATAVALOR) .OR. (Round (nValor,2) <> (cRet)->SOMA))

			If cPrefixo == 'NT2' .And. nOpera <> 5
				// Valida a linha da NT2 - Verifica se os campos estão preenchidos OU o campo de integração estiver como NÃO.
				If (!Empty(JurGetDados ('NT2', 1, xFilial('NT2') + cCajuri + cCod, 'NT2_CFORNT')).AND.;
						!Empty(JurGetDados ('NT2', 1, xFilial('NT2') + cCajuri + cCod, 'NT2_LFORNT')).AND.;
						!Empty(JurGetDados ('NT2', 1, xFilial('NT2') + cCajuri + cCod, 'NT2_CTIPOT')).AND.;
						!Empty(JurGetDados ('NT2', 1, xFilial('NT2') + cCajuri + cCod, 'NT2_CNATUT'))).OR.;
						(JurGetDados ('NT2', 1, xFilial('NT2') + cCajuri + cCod, 'NT2_INTFIN')== '2')
					lCondInteg := .T.
				EndIf
			Else
				lCondInteg := .T.
			EndIf

		EndIf

		If nOpera == 3 //Se Opera == 3 eh para inclusao no historico
			nOpc := 4    //Por nao ser fim da query a operacao nao sera inclusao e sim alteracao do financeiro
		EndIf

		If lAjuste //Como já existe registro na NV3 (devivo ao valor de correção ou juros do levantamento), os sistema entrará na condição de alterar, mas como é um ajuste, o histórico deve ser de inclusão e não de alteração. Por isso o comportamento nessa opção será totalmente diferenciado.
			lCondicao := .F.
			If lCposAudit
				aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, Abs(nValor), cTipoM, cTipoL, '3', '', 'N', cProgn, cCEmpCl, cLojaCl, cSituac, cFilDest, cCodArea}	//18
			Else
				aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, Abs(nValor), cTipoM, cTipoL, '3', '', 'N', cFilDest, cCodArea}	//14
			EndIf
			lRet := JurOperacao(nOpera, "NV3",,, aCampos, aRegistro)//Faz a alteraçao do historico
		Else
			If lCposAudit
				If !Empty(AllTrim(cPrognA)) .And. AllTrim(cPrognA) <> AllTrim(cProgn) .And. lFluigAp
					aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, (nValor), cTipoM, cTipoL, '4', '', 'N', cProgn, cCEmpCl, cLojaCl, cSituac, cFilDest, cCodArea}	//18
				ElseIf AllTrim(cProgn) == '1' .Or. !lFluigAp
					aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, (nValor-(cRet)->SOMA), cTipoM, cTipoL, '4', '', 'N', cProgn, cCEmpCl, cLojaCl, cSituac, cFilDest, cCodArea}	//18
				EndIf
			Else
				aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), cCajuri, cCod, Date(), cDataVl, (nValor-(cRet)->SOMA), cTipoM, cTipoL, '4', '', 'N', cFilDest, cCodArea}	//14
			EndIf
		EndIf

		If lCondicao .OR. nOpera == 5 //Verifica se houve alteracoes de campos cruciais, se eh exclusao ou se foram preenchidos os campos de integracao
			If lCondInteg
				If !lAlcada .OR. cPrefixo == 'NSZ'
					If (nOpera <> 5) .AND. lCondicao
						If (lValor .Or. lPrognAlt) .And. !lData
							lRet := JurOperacao(nOpera, "NV3",,, aCampos, aRegistro)//Faz a alteraçao do historico
						ElseIf (lValor .Or. lPrognAlt) .And. lData
							lRet := JurOperacao(nOpera, "NV3",,, aCampos, aRegistro)//Faz a alteraçao do historico
							If lRet
								aCamposB 	:= {'NV3_DATAVL'}
								aRegistroB	:= {cDataVl}
								lRet := JurOperacao(4, "NV3",1,xFilial("NV3")+(cRet)->CODIGO, aCamposB, aRegistroB) //Faz a alteração no historico
							EndIf
						ElseIf lData .And. !lValor .And. !lPrognAlt
							aCamposB 	:= {'NV3_DATAVL'}
							aRegistroB	:= {cDataVl}
							lRet := JurOperacao(4, "NV3",1,xFilial("NV3")+(cRet)->CODIGO, aCamposB, aRegistroB) //Faz a alteração no historico
						EndIf
					Else
						lRet := .T.
					EndIf

					If lRet .And. cPrefixo <> 'NSZ'
						If lAlcada .OR. cPrefixo == 'NT2'
							lTit := .T.
						EndIf

						aAlcada := JurQryAlc(cPrefixo, cCajuri, cCod, cTipoL, lTit)

						If aAlcada[1] // Verifica antes se está correto para fazer as alterações
							If cPrefixo <> 'NT2' .Or. (cPrefixo == 'NT2' .AND. lIntCom)
								lRet := JurContAlc(nOpc, cPrefixo, nValor, cCajuri, cCod, cTipoL, cPedido) //Altera ou exclui o Pedido de compras
							EndIf

							If lRet
								If nOpera <> 5
									lRet := JurOperacao(nOpera, "NV3",,, aCampos, aRegistro)//Faz a alteraçao do historico
								Else
									lRet := JAQryHis(cCajuri,cCod,cTipoL,nOpera)//Faz a exclusao do historico
								EndIf
							EndIf
						ElseIf lRet .AND. cTipoM == '1' .AND. lCondInteg .And. cOpera == '3'
							//Query para verificar se existe CP para o registro

							cSQLEx := "SELECT COUNT(*) CONTADOR " + CRLF
							cSQLEx += "	FROM "+RetSqlName("NV3") +" NV3 INNER JOIN "+RetSqlName("SE2") +" E2 ON " + CRLF
							cSQLEx +=		"	E2_PREFIXO = NV3_PREFIX AND " + CRLF
							cSQLEx +=		"	E2_NUM = NV3_NUM AND " + CRLF
							cSQLEx +=		" E2_PARCELA = NV3_PARC AND " + CRLF
							cSQLEx +=		" E2_TIPO = NV3_TIPO AND " + CRLF
							cSQLEx +=		" E2_FORNECE = NV3_FORNEC AND " + CRLF
							cSQLEx +=		" E2_LOJA = NV3_LOJA AND " + CRLF
							cSQLEx +=		" E2_FILIAL = '"+cFilSE2+"' AND" + CRLF
							cSQLEx +=		" E2.D_E_L_E_T_ = ' ' " + CRLF
							cSQLEx +=	"	WHERE NV3_FILIAL = '"+xFilial("NV3")+"' " + CRLF
							cSQLEx += 	" AND NV3_COD = '"+(cRet)->MENOR+"'"+ CRLF
							cSQLEx += 	" AND NV3.D_E_L_E_T_ = ' '"

							cSQLEx := ChangeQuery(cSQLEx)
							cRetEx := GetNextAlias()
							dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQLEx ) , cRetEx, .T., .F.)

							While !(cRetEx)->( EOF() )
								If (cRetEx)->CONTADOR > 0// Conta os CPs, se existir algum ele altera ou exclui
									nCont += 1

									// <-- Ponto de Entrada para permitir a customização das informações gravadas no financeiro -->
									If lJAGERPAG .AND. cTipoL <> '1'
										lRet := ExecBlock( 'JAGERPAG',,, { nOpc, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3' } )
									Else
										lRet := JurGerPag(nOpc, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3', nCont, /*lCtb*/, cTipoM) //Altera ou exclui o registro no financeiro
									Endif
								ElseIf nOpera <> 5
									nCont += 1

									// <-- Ponto de Entrada para permitir a customização das informações gravadas no financeiro -->
									If lJAGERPAG .AND. cTipoL <> '1'
										lRet := ExecBlock( 'JAGERPAG',,, { nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3' } )
									Else
										lRet := JurGerPag(nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3', nCont, /*lCtb*/, cTipoM)//Se nao existir registro no financeiro, entao cria
									EndIf
								EndIf
								(cRetEx)->(dbSkip())
							EndDo
							(cRetEx)->( dbCloseArea() )
						EndIf
					EndIf

					If lRet .And. lOk .And. nOpera == 5 //Se o processo foi excluido, exclui todo o restante do historico daquele codigo
						lRet := JAQryHis(cCajuri,cCod,cTipoL,nOpera)//Faz a exclusao do historico
						lOk := .F.
					EndIf

				Else // Se for com controle de alcada, alteracao e exclusao sao feitas de modo diferente

					If cPrefixo == 'NT2'
						lTit := .T.
					EndIf

					aAlcada := JurQryAlc(cPrefixo, cCajuri, cCod, cTipoL, lTit)

					If aAlcada[1] // Verifica antes se está correto para fazer as alterações
						If cPrefixo == 'NT2'
							lRet := .F.
							JurMsgErro(STR0078) // "Nao é possível 'Alterar / Excluir' este registro pois existe pedido de compra gerado via integração contábil"
						Else
							lRet := JurContAlc(nOpc, cPrefixo, nValor, cCajuri, cCod, cTipoL, cPedido) //Altera ou exclui o Pedido de compras
						EndIf

						If lRet
							If nOpera <> 5
								lRet := JurOperacao(nOpera, "NV3",,, aCampos, aRegistro)//Faz a alteraçao do historico
							Else
								lRet := JAQryHis(cCajuri,cCod,cTipoL,nOpera)//Faz a exclusao do historico
							EndIf
						EndIf
					ElseIf lAlcada .OR. cPrefixo == 'NT2'
						If nOpera == 5

							If cPrefixo <> 'NSZ' .AND. cTipoM == '1' .AND. lCondInteg .And. cOpera == '3'
								//Query para verificar se existe CP para o registro
								cSQLEx := "SELECT COUNT(*) CONTADOR " + CRLF
								cSQLEx += "	FROM "+RetSqlName("NV3") +" NV3 INNER JOIN "+RetSqlName("SE2") +" E2 ON " + CRLF
								cSQLEx +=		"	E2_PREFIXO = NV3_PREFIX AND " + CRLF
								cSQLEx +=		"	E2_NUM = NV3_NUM AND " + CRLF
								cSQLEx +=		" E2_PARCELA = NV3_PARC AND " + CRLF
								cSQLEx +=		" E2_TIPO = NV3_TIPO AND " + CRLF
								cSQLEx +=		" E2_FORNECE = NV3_FORNEC AND " + CRLF
								cSQLEx +=		" E2_LOJA = NV3_LOJA AND " + CRLF
								cSQLEx +=		" E2_FILIAL = '"+cFilSE2+"' AND " + CRLF
								cSQLEx +=		" E2.D_E_L_E_T_ = ' ' " + CRLF
								cSQLEx +=	"	WHERE NV3_FILIAL = '"+xFilial("NV3")+"' " + CRLF
								cSQLEx += 	" AND NV3_COD = '"+(cRet)->MENOR+"'"+ CRLF
								cSQLEx += 	" AND NV3.D_E_L_E_T_ = ' '"

								cSQLEx := ChangeQuery(cSQLEx)
								cRetEx := GetNextAlias()
								dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQLEx ) , cRetEx, .T., .F.)

								While !(cRetEx)->( EOF() )
									If (cRetEx)->CONTADOR > 0// Conta os CPs, se existir algum ele altera ou exclui
										nCont += 1

										// <-- Ponto de Entrada para permitir a customização das informações gravadas no financeiro -->
										If lJAGERPAG .AND. cTipoL <> '1'
											lRet := ExecBlock( 'JAGERPAG',,, { nOpera, cPrefixo, nValor, cCajuri, cCod, cTipoL, cPedido } )
										Else
											lRet := JurGerPag(nOpc, cPrefixo, nValor, cCajuri, cCod, cTipoL, 'NV3', nCont, /*lCtb*/, cTipoM) //Altera ou exclui o registro no financeiro
										EndIf

									EndIf
									(cRetEx)->(dbSkip())
								EndDo
								(cRetEx)->( dbCloseArea() )
							EndIf

							If cPrefixo == 'NT2' .And. (lRet .Or. nCont == 0)
								lRet := .T.
							EndIf

							If lRet
								lRet := JAQryHis(cCajuri,cCod,cTipoL,nOpera)//Faz a exclusao do historico
							Endif
						EndIf
					EndIf

				EndIf
			Else
				lRet := .F.
				MsgAlert(STR0027)//Não foram preenchidos campos de integração contábil. Verifique!
			EndIf
		Else
			lRet := .T.
		EndIf
		(cRet)->(dbSkip())
	EndIf
	(cRet)->( dbCloseArea() )

//Reativa o model que chamou a integracao, porque a msexecauto do fina050 estava desativando o model
	If oModelSAVE <> Nil
		FWModelActive(oModelSAVE)
	EndIf

	RestArea( aAreaNV3 )
	RestArea( aArea )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JurGerPag
Geracao de Titulos no Financeiro

@param nOper    Operação(3=Inclusão 4=Alteração ou 5=Exclusão
@param cTabela  Tabela usada
@param nValor   Valor do titulo
@param cCajuri  Cód do assunto juridico
@param cCodlan  Cód do lançamento
@param cTipoL   Indica Tipo do lanaçamento (Despesas ou Garantias)
@param cPrefix  Indica a "Sigla" que será usada como Prefixo

#Return  lRetFun  .T. ou .F.

@author Jorge Luis Branco Martins Junior
@since 26/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGerPag( nOper  , cTabela, nValor, cCajuri, cCodlan,;
		cTipoL , cPrefix, nCont , lCtb	 , cTipoM ,;
		cCodNV3, cGrupo)

Local aArea      := GetArea()
Local lRetFun    := .T.
Local cMsgErr    := ""
Local cSQL       := ""
Local cCod       := ""
Local cRet       := ""
Local aCabSE2    := {}
Local aCampos    := {}
Local lIntegra   := (SuperGetMV('MV_JINTVAL',, '2') == '1')
Local cE2FILIAL  := ""
Local cE2FORNECE := ""
Local cE2LOJA    := ""
Local cE2PREFIXO := ""
Local cE2NUM     := ""
Local cE2PARCELA := ""
Local cE2TIPO    := ""
Local cE2NATUREZ := ""
Local dE2EMISSAO := CtoD("")
Local dE2VENCTO  := CtoD("")
Local dE2VENCREA := CtoD("")
Local nE2VALOR   := 0
Local nE2MOEDA   := 0
Local nE2SALDO   := 0
Local cE2ORIGEM  := ""
Local cE2BANCO   := ""
Local cE2AGENCIA := ""
Local cE2CONTA   := ""
Local cE2HIST    := ""
Local cE2CCUSTO  := ""
Local aParcela   := {}
Local cCondic    := ""
Local nI         := 0
Local lCmpCustom := .F.
Local aCmpCustom := {}
Local nPosCustom := {}
Local nC         := 0
Local nPercenRat := 0
Local nValorRat  := 0
Local aDadosCTB  := {}
Local nPosVlrSE2 := 0
Local nPosVlrCTJ := 0
Local nPosPercen := 0
Local aRetEAI    := {}
Local aDadosNT2  := {}
Local cFilBkp    := cFilAnt
Local cFilDes    := ""
Local cChaveRM   := ""
Local cChaveSE2  := ""
Local lIntFinRm  := SuperGetMv("MV_JINFIRM", , .F.)
Local oModelAct	 := FwModelActive()
Local nPosFld    := 0
Local bError     := ErrorBlock( {|e| JurMsgErro(e:description) } )

Private lMsErroAuto := .T.
Private lMsHelpAuto := .T.

Default nOper    := 3
Default cPrefix  := 'NV3'
Default nCont    := 0
Default lCtb     := .F.
Default cTipoM   := ""
Default cCodNV3  := ""
Default cGrupo   := ""

	If lRetFun .And. nValor == 0 .And. lIntegra
		cMsgErr := STR0028 //'Valor deve ser maior que zero'
		lRetFun := .F.
	EndIf

	If lRetFun .And. lIntegra

		//Query que pega o ID no historico para que seja gerado CP daquele registro.
		cSQL := "SELECT MIN(NV3_COD) MENOR, NV3_FORNEC FORNEC, NV3_LOJA LOJA, NV3_TIPO TIPO, NV3_NUM NUM, NV3_PREFIX PREFIX, NV3_PARC PARC "
		cSQL += " FROM "+RetSqlName("NV3") +" NV3"
		cSQL += " WHERE NV3_CAJURI = '"+cCajuri+"'"
		cSQL +=       " AND NV3_CODLAN = '"+cCodlan+"'"
		cSQL +=       " AND NV3_TIPOL = '"+cTipoL+"'"
		cSQL +=       " AND NV3_TIPOM = '1'"
		cSQL +=       " AND NV3.NV3_FILIAL = '"+xFilial("NV3")+"' "
		cSQL +=       " AND NV3.D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY NV3_FORNEC, NV3_LOJA, NV3_TIPO, NV3_NUM, NV3_PREFIX, NV3_PARC"

		cSQL := ChangeQuery(cSQL)
		cRet := GetNextAlias()
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cRet, .T., .F.)

		While !(cRet)->( EOF() )
			If !Empty(cCodNV3) .And. cTipoM > '1' .And. (cTipoL == '9' .Or. cTipoL == 'B')
				cCod := cCodNV3
			Else
				cCod := (cRet)->MENOR //codigo do primeiro cadastro no historico desse registro
			EndIf
			If nOper == 5
				cE2FORNECE := AVKey( (cRet)->FORNEC, "E2_FORNECE" )
				cE2LOJA    := AVKey( (cRet)->LOJA,    "E2_LOJA"    )
				cE2TIPO    := AVKey( (cRet)->TIPO,   "E2_TIPO"    )
				cE2PREFIXO := AVKey( (cRet)->PREFIX, "E2_PREFIXO" )
				cE2NUM     := AVKey( (cRet)->NUM,    "E2_NUM"     )
				cE2PARCELA := AVKey( (cRet)->PARC,   "E2_PARCELA" )
			EndIf
			(cRet)->(dbSkip())
		EndDo
		(cRet)->( dbCloseArea() )

		If (!IsInCallStack('JURA002') .And. !IsInCallStack('A097PROCLIB')) .Or. (nOper == 5) // IsInCallStack('MATA097') - MATA097 é o nome do programa. O correto é utilizar o nome da função A097PROCLIB.
			//Ajusta a quantidade de digitos utilizada na numeracao do titulo
			If nOper <> 5
				cE2FORNECE := AVKey( FwFldGet(cTabela+"_CFORNT"), "E2_FORNECE" )
				cE2LOJA    := AVKey( FwFldGet(cTabela+"_LFORNT"), "E2_LOJA"    )
				cE2TIPO    := AVKey( FwFldGet(cTabela+"_CTIPOT"), "E2_TIPO"    )
				cE2PREFIXO := AVKey( FwFldGet(cTabela+"_PREFIX"), "E2_PREFIXO" )
			EndIf

			cE2NATUREZ := AVKey( FwFldGet(cTabela+"_CNATUT"), "E2_NATUREZ" )
			nE2VALOR   := FwFldGet(cTabela+"_VALOR")
			nE2MOEDA   := Val(FwFldGet(cTabela+"_CMOEDA"))
			dE2EMISSAO := IIF( Empty( FwFldGet(cTabela + "_DTFIN") ), FwFldGet(cTabela + "_DATA"), FwFldGet(cTabela + "_DTFIN") )

			If cTabela == 'NT2'

				cE2ORIGEM  := AVKey( "JURA098",   "E2_ORIGEM"  )
				cE2BANCO   := FwFldGet(cTabela+"_CBANCO")
				cE2AGENCIA := FwFldGet(cTabela+"_CAGENC")
				cE2CONTA   := FwFldGet(cTabela+"_CCONTA")
				cFilDes    := FwFldGet("NT2_FILDES")

				If cTipoM > '1'
					cE2HIST := AVKey( STR0103 + cCodlan, "E2_HIST" ) //"ALVARÁ: "
				Else
					cE2HIST := AVKey( STR0104 + cCodlan, "E2_HIST" ) //"GARANTIA: "
				EndIf
			Else

				cE2ORIGEM := AVKey( "JURA099", "E2_ORIGEM" )
				cE2HIST   := AVKey( STR0105 + cCodlan, "E2_HIST" ) //"DESPESA: "
				cCondic   := FwFldGet('NT3_CONDPG')
				cFilDes   := FwFldGet("NT3_FILDES")
				If !JurAuto()
					cE2BANCO   := AllTrim(cBancoAdt)
					cE2AGENCIA := AllTrim(cAgenciaAdt)
					cE2CONTA   := AllTrim(cNumCon)
				EndIf
			EndIf

		ElseIf cTabela == 'NT2'

			aDadosNT2 := JurGetDados('NT2', 5, xFilial('NT2') + cCodlan + cCajuri, {"NT2_CFORNT", "NT2_LFORNT", "NT2_CTIPOT", "NT2_CNATUT", "NT2_PREFIX",;
				"NT2_DATA"  , "NT2_VALOR" , "NT2_CBANCO", "NT2_CAGENC", "NT2_CCONTA",;
				"NT2_CMOEDA", "NT2_FILDES"})

			cE2FORNECE := aDadosNT2[1]
			cE2LOJA    := aDadosNT2[2]
			cE2TIPO    := aDadosNT2[3]
			cE2NATUREZ := aDadosNT2[4]
			cE2PREFIXO := aDadosNT2[5]
			dE2EMISSAO := aDadosNT2[6]
			nE2VALOR   := aDadosNT2[7]
			cE2BANCO   := aDadosNT2[8]
			cE2AGENCIA := aDadosNT2[9]
			cE2CONTA   := aDadosNT2[10]
			cE2ORIGEM  := "JURA098"
			cE2HIST    := IIF(cTipoM > '1', STR0103, STR0104) + cCodlan	//"ALVARÁ: "	//"GARANTIA: "
			nE2MOEDA   := Val( aDadosNT2[11] )
			cFilDes    := aDadosNT2[12]
		EndIf

		If nOper <> 5
			cE2NUM     := StrZero( Val(cCod), TamSX3("E2_NUM")[1] )
			cE2NUM     := AVKey( cE2NUM, "E2_NUM")
			cE2PARCELA := AVKey( "1",	 "E2_PARCELA" )
		EndIf

		cE2FILIAL  := xFilial("SE2")
		dE2VENCTO  := dE2EMISSAO
		dE2VENCREA := DataValida(dE2EMISSAO, .T.)
		nE2SALDO   := nE2VALOR
		cE2CCUSTO  := IIF( IsInCallStack("JURA095") .And. Type("M->NSZ_CCUSTO") == "C", M->NSZ_CCUSTO, JurGetDados("NSZ", 1, xFilial("NSZ") + cCajuri, "NSZ_CCUSTO") )

		If Empty(Alltrim(cE2FORNECE)) .OR. Empty(Alltrim(cE2LOJA)) .OR. Empty(Alltrim(cE2TIPO)) .OR. Empty(Alltrim(cE2NATUREZ)) //Campos obrigatorios para integracao
			cMsgErr := STR0029 + CRLF //"Os parametros para criacao do compromisso a pagar nao foram preenchidos corretamente. Verifique. "
			lRetFun := .F.
		EndIf

		If !Empty(cCodNV3) .And. cTipoM > '1' .And. (cTipoL = '9' .Or.  cTipoL == 'B')
			nE2VALOR := nValor
			nE2SALDO := nE2VALOR
		EndIf

		If lRetFun .AND. ((cTipoM == '1' .AND. cTipoL == '2') .OR. (cTipoM > '1' .AND. cTipoL == '9') .OR. (cTipoL  == '3'))

			//Carrega a variavel de filial do sistema para gerar o financeiro na filial de destino
			If !Empty(cFilDes)
				cFilAnt := cFilDes
			EndIf

			//Verifica se existe CP e se esta em aberto quando for alteração ou exclusão
			If nOper > MODEL_OPERATION_INSERT
				//aCampos[1] : Existe CP
				//aCampos[2] : Está em aberto
				aCampos := JurVerPag(cE2NATUREZ, cE2FORNECE, cE2LOJA, cE2TIPO, cE2NUM, cE2PREFIXO)
			EndIf

			//Alimenta o array para geracao do titulo a pagar
			AAdd(aCabSE2, {"E2_FILIAL"  , cE2FILIAL  , Nil})
			AAdd(aCabSE2, {"E2_FORNECE" , cE2FORNECE , Nil})
			AAdd(aCabSE2, {"E2_LOJA"    , cE2LOJA    , Nil})
			AAdd(aCabSE2, {"E2_PREFIXO" , cE2PREFIXO , Nil})
			AAdd(aCabSE2, {"E2_NUM"     , cE2NUM     , Nil})
			AAdd(aCabSE2, {"E2_PARCELA" , cE2PARCELA , Nil})
			AAdd(aCabSE2, {"E2_TIPO"    , cE2TIPO    , Nil})
			AAdd(aCabSE2, {"E2_NATUREZ" , cE2NATUREZ , Nil})
			AAdd(aCabSE2, {"E2_EMISSAO" , dE2EMISSAO , Nil}) //data emissão
			AAdd(aCabSE2, {"E2_VENCTO"  , dE2VENCTO  , Nil}) //vencimento
			AAdd(aCabSE2, {"E2_VENCREA" , dE2VENCREA , Nil}) //vencimento
			AAdd(aCabSE2, {"E2_VALOR"   , nE2VALOR   , Nil}) //valor
			AAdd(aCabSE2, {"E2_SALDO"   , nE2SALDO   , Nil}) //valor
			AAdd(aCabSE2, {"E2_MOEDA"   , nE2MOEDA   , Nil}) //valor
			AAdd(aCabSE2, {"E2_ORIGEM"  , cE2ORIGEM  , Nil})
			AAdd(aCabSE2, {"E2_HIST"    , cE2HIST	 , Nil})
			AAdd(aCabSE2, {"E2_CCUSTO"  , cE2CCUSTO	 , Nil})
			AAdd(aCabSE2, {"E2_IDMOV"   , ""         , Nil})

			If !Empty(cGrupo)
				AAdd(aCabSE2, {"E2_CODAPRO" , cGrupo , Nil}) //Aprovador
			EndIf
			If cTabela == 'NT2' .And. lCtb .And. cTipoM > '1'
				AAdd(aCabSE2, {"E2_LA"  , "S" , Nil})
			EndIf

			If cTabela == "NT2"
				AAdd(aCabSE2, {"AUTBANCO" , cE2BANCO , Nil})
				AAdd(aCabSE2, {"AUTAGENCIA", cE2AGENCIA , Nil})
				AAdd(aCabSE2, {"AUTCONTA" , cE2CONTA , Nil})
			Else
				If cTabela == 'NT3' .And. !JurAuto()
					//Se for despesa, por não ter os campos de banco agencia e conta é aberta uma tela para que seja preenchida as informações
					AAdd(aCabSE2, {"AUTBANCO" , cE2BANCO , Nil})
					AAdd(aCabSE2, {"AUTAGENCIA", cE2AGENCIA , Nil})
					AAdd(aCabSE2, {"AUTCONTA" , cE2CONTA , Nil})
					If AllTrim(cE2TIPO) == "PA"
						AAdd(aCabSE2, {"AUTCHEQUE" , cChequeAdt , Nil})
						AAdd(aCabSE2, {"AUTMOED" , FwFldGet('NT3_CMOEDA') , Nil})
					EndIf
				EndIf
			EndIf

			If cTabela == 'NT2'
				If FWAliasIndic("O11")
					DbSelectArea("O11")
					O11->(DbSetOrder(1)) // O11_FILIAL + O11_CAJURI
					If O11->( DbSeek( xFilial("O11") + cCajuri) )

						aAdd(aCabSE2, {"E2_CCD"   , NSZ->(NSZ_CCUSTO), Nil })
						aAdd(aCabSE2, {"E2_CLVLDB", O11->(O11_CLVLDB), Nil })
						aAdd(aCabSE2, {"E2_DEBITO", O11->(O11_DEBITO), Nil })
						aAdd(aCabSE2, {"E2_ITEMD" , O11->(O11_ITEMD) , Nil })

					EndIf
					O11->( DbCloseArea() )
				EndIf
			Else
				//Carrega o rateio da contabilizasção utilizado no FINA050, informações necessárias para a integração com o Logix
				aDadosCTB := JuRatCtb(cTabela, cCodLan, cCajuri, aCabSE2)

				//Habilita flag de rateio
				If Len(aDadosCTB) > 0
					Aadd(aCabSE2, {"E2_RATEIO" , "S", Nil})
					//Quando a distribuição é de apenas um centro de custo, incluimos as informações do rateio são adicionadas
					If len(aDadosCTB) == 1
						aAdd(aCabSE2, {"E2_CCD"   , NSZ->(NSZ_CCUSTO)                                                           , Nil} )
						If (nPosFld := aScan(aDadosCTB[1],{ |x| x[1] == "CTJ_CLVLDB" }) ) > 0 
							aAdd(aCabSE2, {"E2_CLVLDB", AllTrim( aDadosCTB[1][nPosFld][2] ), Nil} )
						Endif

						If ( nPosFld := aScan(aDadosCTB[1],{ |x| x[1] == "CTJ_DEBITO" }) ) > 0 
							aAdd(aCabSE2, {"E2_DEBITO", AllTrim( aDadosCTB[1][nPosFld][2] ), Nil} )
						Endif

						If (nPosFld :=aScan(aDadosCTB[1],{ |x| x[1] == "CTJ_ITEMD"  }) ) > 0
							aAdd(aCabSE2, {"E2_ITEMD" , AllTrim( aDadosCTB[1][nPosFld][2] ), Nil} )
						Endif
					EndIf
				EndIf
			EndIf

			//--------------------------------------------------------------------------------------
			//Ponto de Entrada PEJURFIN
			//Ponto de Entrada para Inclusão de campos na integração de valores FINANCEIRO
			If 	ExistBlock( "PEJURFIN" )
				aCmpCustom := ExecBlock( "PEJURFIN", .F., .F. ,  {cCajuri, cCodLan, cTabela, aCabSE2})
				If ValType( aCmpCustom ) == "A"
					lCmpCustom := .T.
				EndIf
			EndIf

			If lCmpCustom
				For nC:= 1 To Len(aCmpCustom)

					nPosCustom := Ascan(aCabSE2, {|x| AllTrim(x[1]) == AllTrim(aCmpCustom[nC][1])})

					//Se o campo ja existir atualiza
					If nPosCustom > 0

						aCabSE2[nPosCustom][2] := aCmpCustom[nC][2]
						aCabSE2[nPosCustom][3] := aCmpCustom[nC][3]

						//Inclui campos novos
					Else
						AAdd(aCabSE2, {aCmpCustom[nC][1], aCmpCustom[nC][2], aCmpCustom[nC][3]})
					EndIf
				Next nC
			EndIf
			//--------------------------------------------------------------------------------------

			//Retorna as parcelas do titulo dependendo da condição de pagamento
			aParcela := JurParPg(aCabSE2, cCondic, nE2VALOR, dE2EMISSAO, cTabela)

			//Verifica se é inclusão ou existe titulo aberto e é alteração ou exclusão
			If nOper == MODEL_OPERATION_INSERT .Or. (nOper > MODEL_OPERATION_INSERT .And. aCampos[2])

				Begin Transaction
					For nI := 1 to Len(aParcela )

						//	Begin Transaction

						lMsErroAuto := .F.
						aCabSE2   	:= aParcela[nI]

						DbSelectArea("SE2")
						SE2->( DbSetOrder(1) )		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

						//Carrega a chave primaria da tabela de titulos a pagar (SE2)
						cChaveSE2 := xFilial( "SE2" )
						cChaveSE2 += AVKey(cE2PREFIXO											, "E2_PREFIXO" )
						cChaveSE2 += AVKey(cE2NUM    											, "E2_NUM"     )
						cChaveSE2 += AVKey(aCabSE2[Ascan(aCabSE2, {|x| x[1]=="E2_PARCELA"})][2] , "E2_PARCELA" )
						cChaveSE2 += AVKey(cE2TIPO   											, "E2_TIPO"    )
						cChaveSE2 += AVKey(cE2FORNECE											, "E2_FORNECE" )
						cChaveSE2 += AVKey(cE2LOJA   											, "E2_LOJA"	   )

						If nOper == 3 .OR. nOper == 4

							//Atualiza valor de rateio a partir do valor da parcela
							For nC := 1 To Len(aDadosCTB)

								nPosVlrSE2  := Ascan(aCabSE2	  , {|x| x[1] == "E2_VALOR"  })
								nPosVlrCTJ  := Ascan(aDadosCTB[nC], {|x| x[1] == "CTJ_VALOR" })
								nPosPercen  := Ascan(aDadosCTB[nC], {|x| x[1] == "CTJ_PERCEN"})

								//Calcula valor de rateio
								nPercenRat := aDadosCTB[nC][nPosPercen][2]
								nValorRat  := aCabSE2[nPosVlrSE2][2] * (nPercenRat/100)

								//Atualiza valor de rateio
								aDadosCTB[nC][nPosVlrCTJ][2] := nValorRat
							Next nC
						EndIf

						//Quando Alteração ou Exclusão e integração RM
						If nOper <> MODEL_OPERATION_INSERT .And. lIntFinRm

							//Pega chave do lançamento do RM
							If SE2->( DbSeek(cChaveSE2) )
								aCabSE2[Ascan(aCabSE2, {|x| x[1]=="E2_IDMOV"})][2] := AllTrim(SE2->E2_IDMOV)
							EndIf
						EndIf
						
						BEGIN SEQUENCE
							//Gera financeiro
							MSExecAuto({|a,b,c,d,e,f,g,h| FINA050(a,b,c,d,e,f,g,h)}, aCabSE2, Nil, nOper, /*bExecuta*/, /*aDadosBco*/, /*lExibeLanc*/, /*lOnline*/, aDadosCTB) //Efetua a operacao
						END SEQUENCE

						//Restaura para o modelo que chamou a rotina e esta ativo
						//Tratamento para não dar erro no envio da mensagem unica FINA050
						If oModelAct <> Nil
							FWModelActive(oModelAct)
						EndIf

						If lMsErroAuto
							lRetFun := .F.
						Else
							//Verifica se existe Contas a Pagar para este lancamento
							If SE2->( DbSeek(cChaveSE2) )
								If cTabela == 'NT2' .And. lCtb .And. cTipoM > '1'
									Reclock('SE2', .F.)
									SE2->E2_LA := "S" //Quando a contabilização é feita via contábil (lCtb = .T.), o título gerado deve estar como contabilizado (E2_LA = "S"). Está sendo feito via Reclock pois a rotina FINA050 não permite o preenchimento do campo E2_LA via MSExecAuto.
									MsUnlock()
								EndIf
							EndIf
						EndIf

						//Verifica se existe a integração financeira entre Sigajuri e RM
						If lRetFun .And. lIntFinRm

							//Envia titulo ao RM
							cChaveRM := JiRmInTiPg(nOper, aCabSE2)

							If nOper <> MODEL_OPERATION_DELETE .And. !Empty(cChaveRM)
								If SE2->( DbSeek(cChaveSE2) )
									Reclock("SE2", .F.)
									SE2->E2_IDMOV := cChaveRM
									SE2->E2_HIST  := AllTrim(SE2->E2_HIST) + " - RM: " + cChaveRM
									SE2->( MsUnlock() )
								EndIf
							Else
								lRetFun := .F.
							EndIf
						EndIf

						If !lRetFun
							Exit
						EndIf
					Next

					//Faz as integrações financeiras cadstradas na tabela O0U
					If lRetFun .And. !lIntFinRm .And. FWAliasInDic('O0U')
						aRetEAI := JurIntFin(nOper, cTabela, oModelAct)
						lRetFun := aRetEAI[1]
						cMsgErr := aRetEAI[2]
					EndIf

					If !lRetFun
						//Faz o rollback do que gravou dentro da transação
						DisarmTransaction()

						//Caso o erro seja da rotina automatica FINA050 apresenta
						If lMsErroAuto
							If !JurAuto()
								MostraErro()
							Else
								JurMsgErro( MemoRead(NomeAutoLog()))
							Endif
						EndIf
					EndIf

				End Transaction

				//Existe titulo mas ja foi pago
			ElseIf aCampos[1] .And. !aCampos[2]

				If nOper == 5 .And. nCont == 1
					cMsgErr += STR0030 + CRLF 	//'Financeiro já gerado, não é possivel remover lançamento.'
				ElseIf nOper == 4 .And. nCont == 1
					cMsgErr += STR0031 + CRLF	//'Financeiro já gerado, não é possivel alterar lançamento.'
				EndIf

				lRetFun := .F.
			EndIf

			//Volta para filial que chamou essa rotina
			cFilAnt := cFilBkp

			If lRetFun .And. nOper <> MODEL_OPERATION_DELETE
				DbSelectArea("NV3")
				NV3->( DbSetOrder(1) )
				If NV3->( DbSeek(xFilial("NV3") + cCod) )
					RecLock('NV3', .F.)
					NV3->NV3_PREFIX := SE2->E2_PREFIXO
					NV3->NV3_NUM 	:= SE2->E2_NUM
					NV3->NV3_PARC 	:= SE2->E2_PARCELA
					NV3->NV3_TIPO 	:= SE2->E2_TIPO
					NV3->NV3_FORNEC := SE2->E2_FORNECE
					NV3->NV3_LOJA 	:= SE2->E2_LOJA
					NV3->NV3_FILORI := SE2->E2_FILORIG
					NV3->( MsUnlock() )
				EndIf
			EndIf

		EndIf
	EndIf

	If !lRetFun .And. nCont == 1 .And. !Empty(cMsgErr)
		JurMsgErro(cMsgErr)
	EndIf

	RestArea(aArea)
	ErrorBlock(bError)

Return lRetFun



//-------------------------------------------------------------------
/*/{Protheus.doc} JurParPg
Rotina para gerar o Array com as parcelas segundo a condição de pagamento

@param aCabSE2   Array com as informações para o execAuto do contas a pagar
@param cCondic   Condição da Pagamento
@param nValor    Valor do titulo
@param dEmite    Data de emissão

@Return aParcela Array com array das informações do execAuto conforme as paarcelas


@author Luciano Pereira dos Santos
@since 03/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurParPg(aCabSE2, cCondic, nValor, dEmite, cTabela)

	Local aParCond   := {}
	Local aParcela   := {}
	Local nPosParc   := aScan( aCabSE2, { |aX| AllTrim(aX[1]) == "E2_PARCELA" } )
	Local nPosVenc   := aScan( aCabSE2, { |aX| AllTrim(aX[1]) == "E2_VENCTO"  } )
	Local nPosVencR  := aScan( aCabSE2, { |aX| AllTrim(aX[1]) == "E2_VENCREA" } )
	Local nPosValor  := aScan( aCabSE2, { |aX| AllTrim(aX[1]) == "E2_VALOR"   } )
	Local nPosSaldo  := aScan( aCabSE2, { |aX| AllTrim(aX[1]) == "E2_SALDO"   } )
	Local nI         := 0
	Local aTempSE2   := {}

	//Ponto de entrada para definir as parcelas do titulo
	If ExistBlock("JURPARPG")
		aParCond := Execblock("JURPARPG", .F., .F., {cTabela, cCondic, nValor, dEmite})

		If ValType(aParCond) <> "A"
			aParCond := {}
			JurMsgErro(STR0106, {"JURPARPG"})	//"Retorno incorreto do ponto de entrada #1, será desconsiderado."
		EndIf
	EndIf

	If Len(aParCond) == 0

		//Parcela única sem condigção de pagamento
		If Empty(cCondic)
			aParcela := {aCabSE2}

			//Calcula as parcelas pela condição de pagamento
		Else
			aParCond := Condicao(nValor, cCondic, , dEmite)
		EndIf
	EndIf

	For nI := 1 to Len(aParCond)

		aTempSE2 := aClone(aCabSE2)

		Iif(nPosParc >  0, aTempSE2[nPosParc][2]  := AVKey(cValTochar(nI), "E2_PARCELA"), Nil )

		Iif(nPosVenc >  0, aTempSE2[nPosVenc][2]  := aParCond[nI][1], Nil )
		Iif(nPosVencR > 0, aTempSE2[nPosVencR][2] := DataValida(aParCond[nI][1], .T.), Nil )

		Iif(nPosValor > 0, aTempSE2[nPosValor][2] := aParCond[nI][2], Nil )
		Iif(nPosSaldo > 0, aTempSE2[nPosSaldo][2] := aParCond[nI][2], Nil )

		Aadd(aParcela, aTempSE2)
	Next nI

Return aParcela

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVerPag
Verifica se existe o Contas a Pagar

#Return  lRetFun  .T. ou .F.

@author Jorge Luis Branco Martins Junior
@since 29/03/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVerPag(cNatur, cCodFor, cLojFor, cTipo, cCod, cPrefixo)

	Local aArea	 	 := GetArea()
	Local lRetFun 	 := .F.
	Local lTitAberto := .F.
	Local aCampos	 := {}
	Local cQuery	 := ""
	Local aRetorno	 := {}
	Local oTituloRM	 := Nil
	Local nCont		 := 0

	//Obtem o saldo dos titulos
	cQuery := " SELECT E2_PREFIXO, E2_NUM, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA,"
	cQuery += 	" SUM(E2_SALDO + E2_SDACRES) SALDO, SUM(E2_VALOR + E2_ACRESC) VALOR "
	cQuery += " FROM " + RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL	 = '" + xFilial("SE2") + "'"
	cQuery += 	" AND E2_PREFIXO = '" + cPrefixo + "'"
	cQuery += 	" AND E2_NUM	 = '" + cCod + "'"
	cQuery += 	" AND E2_TIPO	 = '" + cTipo + "'"
	cQuery += 	" AND E2_FORNECE = '" + cCodFor + "'"
	cQuery += 	" AND E2_LOJA	 = '" + cLojFor + "'"
	cQuery += 	" AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY E2_PREFIXO, E2_NUM, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA"

	aRetorno := JurSQL(cQuery, {"*"})

	If Len(aRetorno) > 0
		lRetFun	   := .T.
		lTitAberto := aRetorno[1][7] == aRetorno[1][8]

		//Verifica se existe a integração financeira entre Sigajuri e RM e valida se o titulo já foi baixado no RM
		If lTitAberto .And. SuperGetMv("MV_JINFIRM", , .F.)

			cQuery := " SELECT E2_IDMOV"
			cQuery += " FROM " + RetSqlName("SE2")
			cQuery += " WHERE E2_FILIAL	 = '" + xFilial("SE2") + "'"
			cQuery += 	" AND E2_PREFIXO = '" + cPrefixo + "'"
			cQuery += 	" AND E2_NUM	 = '" + cCod + "'"
			cQuery += 	" AND E2_TIPO	 = '" + cTipo + "'"
			cQuery += 	" AND E2_FORNECE = '" + cCodFor + "'"
			cQuery += 	" AND E2_LOJA	 = '" + cLojFor + "'"
			cQuery += 	" AND E2_IDMOV	 <> '" + Space( TamSx3("E2_IDMOV")[1] ) + "'"
			cQuery += 	" AND D_E_L_E_T_ = ' '"

			aRetorno := JurSQL(cQuery, {"*"})

			For nCont:=1 To Len(aRetorno)

				//Retorna informações do titulo
				oTituloRM := JiRmReadRe("FinLanDataTBC", "<FLAN>", aRetorno[nCont][1])

				If oTituloRM <> Nil .And. XmlChildEx(oTituloRM, "_VALORBAIXADO") <> Nil
					If Val(oTituloRM:_VALORBAIXADO:TEXT) > 0
						lTitAberto := .F.
						Exit
					EndIf
				EndIf
			Next nCont

			FreeObj(oTituloRM)
		EndIf

	Endif

	Aadd(aCampos, lRetFun	)
	Aadd(aCampos, lTitAberto)

	aSize(aRetorno, 0)
	RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JurContAlc
Geração de Titulos com controle de alçadas

@param nOper   	Operação (3=Inclusão 4=Alteração ou 5=Exclusão
@param cTabela  Tabela usada
@param nValor   Valor do titulo
@param cCajuri  Codigo do assunto juridico
@param cCodlan	Codigo do lancamento
@param cTipoL   Indica Tipo do lancamento (Despesas ou Garantias)
@param cPrefix  Indica a "Sigla" que será µsada como Prefixo

#Return  lRetFun  .T. ou .F.

@author Jorge Luis Branco Martins Junior
@since 09/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurContAlc(nOper, cTabela, nValor, cCajuri, cCodlan, cTipoL, cPedido,cGrupo)
	Local lRetFun 	:= .T.
	Local lSeek 		:= .F.
	Local cNatureza := ""
	Local cTipo     := ""
	Local cMsgErr 	:= ""
	Local cSQL		:= ""
	Local cCod		:= ""
	Local cRet		:= Nil
	Local aCabSC7 	:= {}
	Local aCampos 	:= {}
	Local aArea		:= {}
	Local cC7NUM	 := ""
	Local dC7EMISSAO := CtoD("")
	Local cC7FORNECE := ""
	Local cC7LOJA    := ""
	Local cC7COND    := ""
	Local cC7CONTATO := ""
	Local nC7MOEDA	 := 0
	Local cC7TXMOEDA := ""
	Local cC7PRODUTO := ""
	Local cC7UM	     := ""
	Local cC7FILENT  := ""
	Local nC7QUANT	 := 0
	Local nC7PRECO   := 0
	Local cC7LOCAL   := ""
	Local aCmpCustom :={}
	Local nC 		 := 0
	Local lCmpCustom := .F.
	Local lIntegra   := (SuperGetMV('MV_JINTVAL',, '2') == '1')
	Local aDadosNT2	 := {}
	Local cFilBkp	 := cFilAnt
	Local cFilDes	 := ""
	Local cFilNV3	 := xFilial("NV3")
	local cC7Grupo   := ''

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default nOper 	:= 3
	Default cPedido := ""
	Default cGrupo  := ""

	If lRetFun .And. nValor == 0 .And. lIntegra
		cMsgErr := STR0028 //'Valor deve ser maior que zero'
		lRetFun := .F.
	EndIf

	If lRetFun .And. lIntegra
		//Query que pega o ID no historico para que seja gerado Pedido daquele registro.
		cSQL := "SELECT MIN(NV3_COD) MENOR "
		cSQL += " FROM "+RetSqlName("NV3") +" NV3"
		cSQL += " WHERE NV3_CAJURI = '"+ cCajuri +"'"
		cSQL +=   " AND NV3_CODLAN = '"+ cCodlan +"'"
		cSQL +=   " AND NV3_TIPOL = '" + cTipoL +"'"
		cSQL +=   " AND NV3_TIPOM = '1'"
		cSQL +=   " AND NV3.NV3_FILIAL = '"+ cFilNV3 +"' "
		cSQL +=   " AND NV3.D_E_L_E_T_ = ' '"

		cSQL := ChangeQuery(cSQL)
		cRet := GetNextAlias()
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cRet, .T., .F.)

		While !(cRet)->( EOF() )
			cCod := (cRet)->MENOR //codigo do primeiro cadastro no historico desse registro
			(cRet)->(dbSkip())
		EndDo
		(cRet)->( dbCloseArea() )

		If (!IsInCallStack('JURA002') .And. !IsInCallStack('MATA097')) .Or. (nOper == 5)
			//Ajusta a quantidade de digitos utilizada na numeracao do titulo
			cC7FORNECE := AVKey( FwFldGet(cTabela+"_CFORNT"), "C7_FORNECE")
			cC7LOJA    := AVKey( FwFldGet(cTabela+"_LFORNT"), "C7_LOJA")
			dC7EMISSAO := AVKey( FwFldGet(cTabela+"_DATA"), "C7_EMISSAO")
			nC7MOEDA   := Val(FwFldGet(cTabela+"_CMOEDA"))
			nC7PRECO   := FwFldGet(cTabela+"_VALOR")
			cNatureza  := FwFldGet(cTabela+"_CNATUT")
			cTipo      := FwFldGet(cTabela+"_CTIPOT")
			If cTabela == 'NT3' .Or. cTabela == 'NT2'
				cC7COND    := AVKey( FwFldGet(cTabela + "_CONDPG"), "C7_COND")
				cC7PRODUTO := AVKey( FwFldGet(cTabela + "_PRODUT"), "C7_PRODUTO")
				cFilDes    := FwFldGet(cTabela+"_FILDES")
			EndIf
			If !Empty(cGrupo) .AND. cTabela == 'NT2'
				cC7Grupo := AVKey(cGrupo, "C7_APROV")
			EndIf

		ElseIf cTabela == 'NT2'

			aDadosNT2 := JurGetDados('NT2', 5, xFilial('NT2') + cCodlan + cCajuri, {"NT2_CFORNT", "NT2_LFORNT", "NT2_DATA"	, "NT2_CMOEDA", "NT2_VALOR",;
				"NT2_CNATUT", "NT2_CTIPOT", "NT2_FILDES"})

			cC7FORNECE := aDadosNT2[1][1]
			cC7LOJA    := aDadosNT2[1][2]
			dC7EMISSAO := aDadosNT2[1][3]
			nC7MOEDA   := Val( aDadosNT2[1][4] )
			nC7PRECO   := aDadosNT2[1][5]
			cNatureza  := aDadosNT2[1][6]
			cTipo      := aDadosNT2[1][7]
			cFilDes    := aDadosNT2[1][8]
		EndIf

		//Carrega a variavel de filial do sistema para gerar o pedido de compras na filial de destino
		If !Empty(cFilDes)
			cC7FILENT  := AVKey(cFilDes, "C7_FILENT") //Pega a filial da despesa no SIGAJURI
		EndIf

		If Empty(cPedido)
			cPedido := JurGetDados('SC7', 14, cFilDes + Posicione('NV3', 1, cFilNV3 + cCod, 'NV3_PEDIDO') + '0001', 'C7_NUM')
		EndIf

		cC7NUM     := cPedido
		cC7TXMOEDA := Criavar("C7_TXMOEDA",.T.)
		cC7UM      := AVKey( JurGetDados ('SB1' , 1, xFilial('SB1') + cC7PRODUTO, 'B1_UM'), "C7_UM")
		cC7CONTATO := AVKey( CriaVar("C7_CONTATO",.T.), "C7_CONTATO")

		If(Empty(cC7FILENT))
			cC7FILENT := AVKey( CriaVar("C7_FILENT",.T.), "C7_FILENT")
		EndIf

		nC7QUANT   := 1
		cC7LOCAL   := AVKey( JurGetDados ('SB1', 1, xFilial('SB1') + cC7PRODUTO, 'B1_LOCPAD'),	"C7_LOCAL"   )

		If (Empty(Alltrim(cC7PRODUTO)) .OR. Empty(Alltrim(cC7COND))) //Campos obrigatorios para integracao
			cMsgErr := STR0033 + CRLF //"Os parametros para criacao do pedido de compras não foram preenchidos(Condição de pagamento e Produto). Verifique! "
			lRetFun := .F.
		Else
			If lRetFun .And. nOper <> 3
				If JurGetDados('SC7' , 1, xFilial('SC7') + cC7NUM, 'C7_QUJE') > 0
					cMsgErr += STR0064 + CRLF //Não é possível alterar ou excluir a despesa, pois já foi gerado documento de entrada referente a ela.
					lRetFun := .F.
				EndIf
			EndIf
		EndIf

		If lRetFun
			//Alimenta o array para geracao do pedido de compra
			AAdd(aCabSC7, 	{"C7_NUM" 		, cC7NUM					,NIL})

			If nOper <> 5
				AAdd(aCabSC7, {"C7_EMISSAO"	, STOD(dC7EMISSAO)			,NIL})
				AAdd(aCabSC7, {"C7_FORNECE" , cC7FORNECE				,NIL})
				AAdd(aCabSC7, {"C7_LOJA"	, cC7LOJA					,NIL})
				AAdd(aCabSC7, {"C7_CONTATO"	, cC7CONTATO				,NIL})
				AAdd(aCabSC7, {"C7_COND"	, cC7COND					,NIL})
				AAdd(aCabSC7, {"C7_FILENT"	, cC7FILENT					,NIL})
				AAdd(aCabSC7, {"C7_MOEDA"	, nC7MOEDA					,NIL})
				AAdd(aCabSC7, {"C7_TXMOEDA"	, cC7TXMOEDA				,NIL})
				AAdd(aCabSC7, {"C7_FRETE"	, CriaVar("C7_FRETE",.F.)	,NIL})
				AAdd(aCabSC7, {"C7_DESPESA"	, CriaVar("C7_DESPESA",.F.)	,NIL})
				AAdd(aCabSC7, {"C7_SEGURO"	, CriaVar("C7_SEGURO",.F.)	,NIL})
				AAdd(aCabSC7, {"C7_DESC1"	, CriaVar("C7_DESC1",.F.)	,NIL})
				AAdd(aCabSC7, {"C7_DESC2"	, CriaVar("C7_DESC2",.F.)	,NIL})
				AAdd(aCabSC7, {"C7_DESC3"	, CriaVar("C7_DESC3",.F.)	,NIL})
				AAdd(aCabSC7, {"C7_MSG"		, CriaVar("C7_MSG",.F.)		,NIL})
				AAdd(aCabSC7, {"C7_REAJUST"	, CriaVar("C7_REAJUST",.F.)	,NIL})

				AAdd(aCampos, {"C7_ITEM"	, StrZero(1,Len(SC7->C7_ITEM))	,NIL})
				AAdd(aCampos, {"C7_PRODUTO"	, cC7PRODUTO					,NIL})
				AAdd(aCampos, {"C7_UM"		, cC7UM							,NIL})
				AAdd(aCampos, {"C7_PRECO"	, nC7PRECO						,NIL})
				AAdd(aCampos, {"C7_QUANT"	, nC7QUANT						,NIL})
				AAdd(aCampos, {"C7_TOTAL"	, nC7PRECO						,NIL})
				AAdd(aCampos, {"C7_LOCAL"	, cC7LOCAL						,NIL})
				If !Empty(cC7Grupo)
					AAdd(aCampos, {"C7_APROV"	, cC7Grupo						,NIL})
				EndIf

				//Ponto de Entrada PEJURCOM ( Integração de Despesas com módulo de Compras - Ponto de entrada associa novos campos para a integração)
				//------------------------------------------------------------------------------------------------------
				//Ponto de Entrada para Inclusão de campos na integração de valores COMPRAS
				If ExistBlock( "PEJURCOM" )
					aCmpCustom := ExecBlock( "PEJURCOM", .F., .F. , {cCajuri,cCodLan,cTabela,aCabSC7,aCampos})

					If ValType( aCmpCustom ) == "A"
						lCmpCustom := .T.
					EndIf

				EndIf

				If lCmpCustom
					For nC:= 1 to len(aCmpCustom)
						If (cTabela == 'NT3' .Or. cTabela == 'NT2')
							If aCmpCustom[nC][4] == "C"
								AAdd(aCabSC7,{aCmpCustom[nC][1],aCmpCustom[nC][2],aCmpCustom[nC][3]})
							ElseIf aCmpCustom[nC][4] == "I"
								AAdd(aCampos,{aCmpCustom[nC][1],aCmpCustom[nC][2],aCmpCustom[nC][3]})
							EndIF
						EndIf
					Next
				EndIf
				If nOper == 4
					AAdd(aCampos, {"C7_ALI_WT", 'SC7'         , NIL})
					AAdd(aCampos, {"C7_REC_WT", SC7->(RECNO()), NIL})
				EndIf

			EndIf

			aArea := GetArea()
			If nOper <> 3
				dbSelectArea('SC7')
				dbSetOrder(3)
				dbSeek(xFilial('SC7')+cC7FORNECE+cC7LOJA+cC7NUM)
			EndIf
			MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCabSC7,{aCampos},nOper,.F.)//Efetua a operacao
			RestArea(aArea)
		EndIf

		If nOper == 3
			dbSelectArea('SC7')
			dbSetOrder(3)
			lSeek := dbSeek(xFilial('SC7')+cC7FORNECE+cC7LOJA+cC7NUM)
		EndIf

		If lMsErroAuto .AND. !lSeek
			If !JurAuto()
				MostraErro()
			Else
				JurMsgErro( MemoRead(NomeAutoLog()))
			Endif
			lRetFun := .F.
		EndIf

		//Volta para filial que chamou essa rotina
		cFilAnt := cFilBkp
	EndIf

	If !lRetFun .And. !Empty(cMsgErr)
		JurMsgErro(cMsgErr)
	EndIf

Return lRetFun
//-------------------------------------------------------------------
/*/{Protheus.doc} JurQryAlc
Query de verificacao de pedidos de compra, documentos de entrada e CP

@author Jorge Luis Branco Martins Junior
@since 09/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurQryAlc(cTabela, cCajuri, cCodlan, cTipoL, lTit)
	Local aArea		:= GetArea()
	Local cSQLP 	:= "" //Pedido de compra
	Local cSQLT 	:= "" //Titulo
	Local cPed		:= ""
	Local cPrefix 	:= ""
	Local cParcela	:= ""
	Local cTipo 	:= ""
	Local cFornec	:= ""
	Local cLoja 	:= ""
	Local cNum 		:= ""
	Local lEncer 	:= .F.
	Local lBloq  	:= .F.
	Local lPed	 	:= .F.
	Local lAlvara 	:= .F.
	Local nAlvara 	:= 0
	Local cRet		:= ""
	Local cRetT		:= GetNextAlias()
	Local aRet		:= {}
	Local cRetP		:= GetNextAlias()
	Local cFilOri 	:= ""
	Local cFilSE2 	:= ""
	Local cFilSC7 	:= ""
	Local cMoeda    := cTabela+"_CMOEDA"

	Default lTit 	:= .F.

	cSQLP := "SELECT MIN(NV3_COD) MENOR, NV3_PEDIDO PEDIDO, C7_CONAPRO CONAPRO, C7_ENCER ENCER, NV3_FILORI, C7_MOEDA," + cMoeda
	cSQLP += "FROM "+RetSqlName('NV3') + " NV3"
	cSQLP += "	INNER JOIN "+RetSqlName(cTabela) +" "+ cTabela
	cSQLP += "        ON("+cTabela+"_CAJURI  = NV3_CAJURI"
	cSQLP += "       AND "+cTabela+"_COD	 = NV3_CODLAN"
	cSQLP += "       AND "+cTabela+"_FILIAL  = NV3_FILIAL)"
	cSQLP += "	INNER JOIN "+RetSqlName('SC7')+"  C7"
	cSQLP += "        ON(C7_FORNECE  = "+cTabela+"_CFORNT"
	cSQLP += "       AND C7_LOJA	 = "+cTabela+"_LFORNT"
	If cTabela <> 'NT2'
		cSQLP += "       AND C7_COND	   = "+cTabela+"_CONDPG"
		cSQLP += "	   	 AND C7_PRODUTO  = "+cTabela+"_PRODUT"
	EndIf
	cSQLP += ")"
	cSQLP += "WHERE NV3_FILIAL = '" + xFilial("NV3") +"' "
	cSQLP += "  AND NV3_CAJURI = '" + cCajuri + "'"
	cSQLP += "  AND NV3_CODLAN = '" + cCodlan + "'"
	cSQLP += "	AND NV3_TIPOL  = '" + cTipoL + "'"
	cSQLP += "  AND NV3_TIPOM  = '1'"
	cSQLP += "  AND C7.D_E_L_E_T_  = ' '"
	cSQLP += "  AND NV3.D_E_L_E_T_ = ' '"
	cSQLP += "  AND "+cTabela+".D_E_L_E_T_ = ' '"
	cSQLP += "  AND NV3_PEDIDO <> '' AND C7_NUM = NV3_PEDIDO "
	cSQLP += "GROUP BY NV3_PEDIDO, C7_CONAPRO, C7_ENCER, NV3_FILORI, C7_MOEDA," + cMoeda

	cSQLP := ChangeQuery(cSQLP)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQLP ) , cRetP, .T., .F.)

	While !(cRetP)->( EOF() )
		cPed 	:= (cRetP)->PEDIDO //codigo do primeiro cadastro
		cFilOri	:= (cRetP)->NV3_FILORI
		(cRetP)->(dbSkip())
	EndDo

	If !EMPTY(cPed)

		If Empty(cFilOri)
			cFilSE2 := xFilial("SE2")
			cFilSC7 := xFilial("SC7")
		Else
			cFilSE2 := FwxFilial("SE2", cFilOri)
			cFilSC7 := FwxFilial("SC7", cFilOri)
		EndIf

		cSQLT := "SELECT C7_CONAPRO CONAPRO, C7_ENCER ENCER ,D1_PEDIDO PEDIDO, E2_PREFIXO PREFIXO, E2_NUM NUM, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA " + CRLF
		cSQLT += "FROM "+RetSqlName('SC7')+" C7" + CRLF
		cSQLT += " INNER JOIN  "+RetSqlName('SD1')+"  D1" + CRLF
		cSQLT += "   ON (D1_PEDIDO  = C7_NUM"		+ CRLF
		cSQLT += "	 AND D1_FORNECE = C7_FORNECE"	+ CRLF
		cSQLT += "   AND D1_LOJA	= C7_LOJA)"		+ CRLF
		cSQLT += "	INNER JOIN  "+RetSqlName('SE2')+"  E2"		+ CRLF
		cSQLT += "   ON (E2_NUM 	= D1_DOC"		+ CRLF
		cSQLT += "   AND E2_LOJA 	= D1_LOJA"		+ CRLF
		cSQLT += "   AND E2_FORNECE = D1_FORNECE"	+ CRLF
		cSQLT += "	 AND E2_PREFIXO = D1_SERIE)	"	+ CRLF
		cSQLT += "WHERE C7_FILIAL = '" +cFilSC7+ "'" + CRLF
		cSQLT += "	AND C7_NUM 	  = '" +cPed+ "'"	 + CRLF
		cSQLT += "	AND C7.D_E_L_E_T_ = ' '"	+ CRLF
		cSQLT += "	AND D1.D_E_L_E_T_ = ' '"	+ CRLF
		cSQLT += "	AND E2.D_E_L_E_T_ = ' '"

		cSQLT := ChangeQuery(cSQLT)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQLT ) , cRetT, .T., .F.)

		If !(cRetT)->( EOF() )
			While !(cRetT)->( EOF() )
				cPrefix	 := (cRetT)->PREFIXO
				cNum 	 := (cRetT)->NUM
				cParcela := (cRetT)->PARCELA
				cTipo 	 := (cRetT)->TIPO
				cFornec	 := (cRetT)->FORNECE
				cLoja	 := (cRetT)->LOJA
				lEncer 	 := (cRetT)->ENCER == 'E'
				lBloq  	 := (cRetT)->CONAPRO == 'B'
				lPed 	 := .T.
				(cRetT)->(dbSkip())
			EndDo
			(cRetT)->( dbCloseArea() )
		Else
			cPrefix  := ""
			cNum 	 := ""
			cParcela := ""
			cTipo 	 := ""
			cFornec	 := ""
			cLoja	 := ""
			lEncer 	 := (cRetP)->ENCER == 'E'
			lBloq  	 := (cRetP)->CONAPRO == 'B'
			lPed 	 := .T.
			cFilOri	 := ""
		EndIf
		aRet := {lPed, lEncer, lBloq, cNum, cPrefix, cParcela, cTipo, cFornec, cLoja, cFilOri}
	ElseIf lTit

		cSQL := "SELECT MIN(NV3_COD) MENOR, NV3_PREFIX PREFIX, NV3_NUM NUM, NV3_FILORI, E2_PARCELA PARCELA, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA " + CRLF
		cSQL += "	FROM "+RetSqlName("NV3") +" NV3 INNER JOIN "+RetSqlName("SE2") +" E2 ON " + CRLF
		cSQL +=		" E2_PREFIXO = NV3_PREFIX AND " + CRLF
		cSQL +=		" E2_NUM = NV3_NUM AND " + CRLF
		cSQL +=		" E2_PARCELA = NV3_PARC AND " + CRLF
		cSQL +=		" E2_TIPO = NV3_TIPO AND " + CRLF
		cSQL +=		" E2_FORNECE = NV3_FORNEC AND " + CRLF
		cSQL +=		" E2_LOJA = NV3_LOJA AND " + CRLF
		cSQL +=		" E2_FILORIG = NV3_FILORI AND " + CRLF
		cSQL +=		" E2.D_E_L_E_T_ = ' ' " + CRLF
		cSQL +=	 "	WHERE NV3_FILIAL = '"+xFilial("NV3")+"' " + CRLF
		cSQL += 	" AND NV3_CAJURI = '"+cCajuri+"'"+ CRLF
		cSQL += 	" AND NV3_CODLAN = '"+cCodlan+"'"+ CRLF
		If cTabela == 'NT2'
			If JurGetDados ('NT2', 1, xFilial("NT2") + cCajuri + cCodlan, 'NT2_MOVFIN') == "2"
				lAlvara := .T.
				cSQL += " AND NV3_TIPOM <> '1'"+ CRLF
				cSQL += " AND NV3_TIPOL = '9'"+ CRLF
			Else
				cSQL += " AND NV3_TIPOM = '1'"+ CRLF
				cSQL += " AND NV3_TIPOL = '"+cTipoL+"'"+ CRLF
			EndIf
		Else
			cSQL += " AND NV3_TIPOM = '1'"+ CRLF
			cSQL += " AND NV3_TIPOL = '"+cTipoL+"'"+ CRLF
		EndIf
		cSQL += 	" AND NV3.D_E_L_E_T_ = ' '"
		cSQL += " GROUP BY NV3_PREFIX, NV3_NUM, NV3_FILORI, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA "

		cSQL := ChangeQuery(cSQL)
		cRet := GetNextAlias()

		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cRet, .T., .F.)

		While !(cRet)->( EOF() )
			cCod	:= (cRet)->MENOR //codigo do primeiro cadastro no historico desse registro
			cPrefix	:= (cRet)->PREFIX
			If lAlvara
				If nAlvara == 0
					cNum 	:= (cRet)->NUM
					nAlvara := 1
				Else
					cNum += "','"+(cRet)->NUM
				EndIf
			Else
				cNum := (cRet)->NUM
			EndIf
			cParcela := (cRet)->PARCELA
			cTipo 	 := (cRet)->TIPO
			cFornec	 := (cRet)->FORNECE
			cLoja	 := (cRet)->LOJA
			cFilOri	 := (cRet)->NV3_FILORI
			(cRet)->(dbSkip())
		EndDo
		(cRet)->( dbCloseArea() )

		aRet := {.F., .F., .F., cNum, cPrefix, cParcela, cTipo, cFornec, cLoja, cFilOri}
	Else
		aRet := {.F., .F., .F., "", "", "", "", "", "", ""}
	EndIf

	(cRetP)->( dbCloseArea() )
	RestArea(aArea)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JurTitPag()
Posição do contas a pagar para garantias e alvarás.

@author Jorge Luis Branco Martins Junior
@since 12/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTitPag(cTabela, cCajuri, cCod, lConfirma, cFilDest, aDadosSE2)

Local aArea      := GetArea()
Local aAreaSE2   := SE2->( GetArea() )
Local aAreaSX3   := SX3->( GetArea() )
Local cQuery     := ''
Local cTmp      	 := Nil
Local lExisteTit := .F.
Local cFilTit    := IIF(!Empty(cFilDest), FwXfilial('SE2',cFilDest), xFilial("SE2"))
Local aDados     := {}
Local lTLegal    := isInCallStack('GET_TITULOPAG')
Local lIntegraRM := SuperGetMv("MV_JINFIRM", , .F.)

Default cCajuri   := ''
Default cCod      := ''
Default lConfirma := .F. //Indica que o retorno será apenas uma confirmação se existe título ou não. Quando for .T. não exibirá a tela de títulos caso existam, apenas retornará que existe títulos.
Default aDadosSE2 := {}

	aDados := JurQryAlc(cTabela, cCajuri, cCod, IIF(cTabela == 'NT2','2','3'),.T.)

	If ValType(aDados) == "A"

		// Obtem os titulos do contas a pagar do tabelado
		cQuery := "SELECT R_E_C_N_O_ SE2RECNO, E2_IDMOV "

		If lTLegal
			cQuery +=        " , E2_EMISSAO EMISSAO, "
			cQuery +=        " E2_VENCTO VENCTO, "
			cQuery +=        " E2_VALOR VALOR, "
			cQuery +=        " E2_SALDO SALDO, "
			cQuery +=        " E2_PARCELA PARCELA, "
			cQuery +=        " E2_TIPO TIPO, "
			cQuery +=        " E2_FORNECE FORNECE, "
			cQuery +=        " E2_LOJA LOJA "
		EndIf

		cQuery += "  FROM " + RetSqlName( "SE2" ) + " SE2 "
		cQuery += "  WHERE SE2.E2_FILIAL	= '" + cFilTit + "' "
		cQuery += "	AND SE2.E2_PREFIXO	= '" + aDados[5] + "' "
		cQuery += "	AND SE2.E2_NUM IN ('" + aDados[4] + "') "
		cQuery += "	AND SE2.E2_TIPO		= '" + aDados[7] + "' "
		cQuery += "	AND SE2.E2_FORNECE	= '" + aDados[8] + "' "
		cQuery += "	AND SE2.E2_LOJA		= '" + aDados[9] + "' "
		cQuery += "	AND SE2.D_E_L_E_T_	= ' ' "
		cQuery += "	ORDER BY " +  SQLOrder( SE2->( IndexKey( 1 ) ) )

		cTmp := GetNextAlias()

		dbUseArea(.T., 'TOPCONN', TcGenQry( , , cQuery), cTmp, .T., .F.)

		If !( cTmp )->( EOF() )

			lExisteTit := .T.

			If !lConfirma //Quando for .T. não exibirá a tela de títulos caso existam, apenas retornará que existe títulos.

				While !(cTmp)->( Eof() )

					//Verifica se existe a integração financeira entre Sigajuri e RM
					If lIntegraRM
						If !Empty( (cTmp)->E2_IDMOV )
							//Consulta o status do titulo a pagar no RM e atualiza o titulo a pagar(SE2) no Protheus
							JiRmBxTiPg((cTmp)->E2_IDMOV, (cTmp)->SE2RECNO)
						EndIf
					EndIf

					If lTLegal
						aAdd(aDadosSE2, {aDados[4], aDados[5], (cTmp)->PARCELA,(cTmp)->TIPO, (cTmp)->FORNECE, (cTmp)->LOJA, aDados[10], (cTmp)->EMISSAO, (cTmp)->VENCTO, (cTmp)->VALOR, (cTmp)->SALDO})
					EndIf
					(cTmp)->( DbSkip() )

				EndDo

				If !lTLegal
					//Abre tela para apresentação do titulo
					J190TitSE2(aDados[5], aDados[4], aDados[7], aDados[8], aDados[9], cFilTit)
				EndIf
			EndIf

		ElseIf !lConfirma
			APMsgStop(STR0040)//"Titulo não encontrado para visualização!"
		EndIf

		(cTmp)->( DbCloseArea() )

	ElseIf !lConfirma
		APMsgStop(STR0040)//"Titulo não encontrado para visualização!"
	EndIf

	RestArea( aAreaSE2 )
	RestArea( aAreaSX3 )
	RestArea( aArea    )

Return lExisteTit


//-------------------------------------------------------------------
/*/{Protheus.doc} JAQryHis
Query para busca dos registros no histórico para serem excluidos

@author Jorge Luis Branco Martins Junior
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JAQryHis(cCajuri,cCod,cTipoL,nOpera)
	Local cSQL 		:= ""
	Local cRet 		:= GetNextAlias()
	Local lRet 		:=	.T.
	Local aCampos 	:= {"NV3_OPERA"}
	Local aRegistro	:= {'5'}
	Local cTipoL2 := "" //Tipo que eh incluido quando eh feita integracao
	Local cTipoL3 := "" //Tipo que eh incluido quando eh feita integracao

	Do Case
	Case cTipoL == '1' // Provisão
		cTipoL2 := '4'   // Provisao Positiva
		cTipoL3 := '6'   // Provisao Negativa
	Case cTipoL == '2' // Garantias
		cTipoL2 := '5'   // Garantia Positiva
		cTipoL3 := '7'   // Garantia Negativa
	Case cTipoL == '9' // Levantamento
		cTipoL2 := 'A'   // Levantamento Estorno
		cTipoL2 := 'B'   // Tarifas Bancarias
	EndCase

	cSQL := "SELECT NV3_COD CODIGO, NV3_DATAUL DATAUL, NV3_LA LA "+ CRLF
	cSQL += "  	FROM "+RetSqlName("NV3") + CRLF
	cSQL += "  WHERE NV3_CAJURI = '"+cCajuri+"'"+ CRLF
	cSQL += "  	AND NV3_CODLAN = '"+cCod+"' " + CRLF
	cSQL += "  	AND (NV3_TIPOL = '"+cTipoL+"' or NV3_TIPOL = '"+cTipoL2+"' or NV3_TIPOL = '"+cTipoL3+"')"+ CRLF
	cSQL += "  	AND NV3_FILIAL = '"+xFilial("NV3")+"' " + CRLF
	cSQL += "  	AND D_E_L_E_T_ = ' '"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cRet, .T., .F.)

	If cCod == ''
		cCod := '          '
	EndIf

	While !(cRet)->( EOF() ) .AND. lRet
		If Alltrim((cRet)->LA) == 'S' .AND. Alltrim((cRet)->DATAUL) <> ''
			aAdd( aCampos, "NV3_LA" )
			aAdd( aRegistro, 'N' )
		EndIf

		lRet := JurOperacao(4, "NV3",1,xFilial("NV3")+(cRet)->CODIGO, aCampos, aRegistro) //Faz a alteração no historico
		(cRet)->(dbSkip())
	EndDo
	(cRet)->( dbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLAltera
Verifica o parametro de Integracao contabil e operacao para bloquear

@author Jorge Luis Branco Martins Junior
@since 27/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLAltera(cTabela)
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local nOpc     := oModel:GetOperation()
	local cExstNV3 := ''

	If (SuperGetMV('MV_JINTVAL',, '2') == '1') .AND. nOpc == 4

	/* Alterado de FwFldGet para oModel, pois será necessário analisar não o campo que esta na tela, mas sim no model */
		If cTabela == 'NT3'			//NT3 Despesas (JURA099)
			DbSelectArea(cTabela)
			IF( !Empty( oModel:GetValue("NT3MASTER",cTabela+"_CNATUT") ) .AND. !Empty( oModel:GetValue("NT3MASTER",cTabela+"_CTIPOT") ) .AND. ;
					!Empty( oModel:GetValue("NT3MASTER",cTabela+"_CFORNT") ) .AND. !Empty( oModel:GetValue("NT3MASTER",cTabela+"_LFORNT") ) .AND. ;
					!Empty( oModel:GetValue("NT3MASTER",cTabela+"_NOMEFT") ) .AND. ;
					IIf( (ColumnPos(cTabela+"_CONDPG") > 0) .AND. ;
					(ColumnPos(cTabela+"_PRODUT") > 0), ;
					!Empty( oModel:GetValue("NT3MASTER",cTabela+"_PRODUT") ) .AND.;
					!Empty( oModel:GetValue("NT3MASTER",cTabela+"_CONDPG") )     ;
					, .T.) ;
					)

				lRet := .F.
			EndIF

		ElseIf cTabela == 'NT2'		// NT2 - Garantia ( JURA098)

			cExstNV3:= JurGetDados("NV3", 2, xFilial("NV3") + oModel:GetValue("NT2MASTER", cTabela+"_CAJURI") + oModel:GetValue("NT2MASTER", cTabela+"_COD")+ '2' , "NV3_CAJURI")

			If !Empty(cExstNV3)
				DbSelectArea(cTabela)
				IF(	!Empty( oModel:GetValue("NT2MASTER", cTabela+"_CNATUT") ) .AND. !Empty( oModel:GetValue("NT2MASTER", cTabela+"_CTIPOT")).AND. ;
						!Empty( oModel:GetValue("NT2MASTER", cTabela+"_CFORNT") ) .AND. !Empty( oModel:GetValue("NT2MASTER", cTabela+"_LFORNT")).AND. ;
						!Empty( oModel:GetValue("NT2MASTER", cTabela+"_CBANCO") ) .AND. !Empty( oModel:GetValue("NT2MASTER", cTabela+"_CAGENC")).AND. ;
						!Empty( oModel:GetValue("NT2MASTER", cTabela+"_CCONTA") ) .AND. !Empty( oModel:GetValue("NT2MASTER", cTabela+"_NOMEFT")).AND. ;
						IIf( (ColumnPos(cTabela+"_CONDPG") > 0) .AND. ;
						(ColumnPos(cTabela+"_PRODUT") > 0), ;
						!Empty( oModel:GetValue("NT2MASTER", cTabela+"_CONDPG" )) .AND. ;
						!Empty( oModel:GetValue("NT2MASTER", cTabela+"_PRODUT" )) ;
						, .T.) ;
						)

					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFiltRst
Verifica se a consulta F3 utilizada, para restrição de cadastro
básico
Uso Geral, partindo das telas de pesquisa

@param 	cAlias      Alias da tabela

@Return cFiltro	 	Filtro em sintaxe ADVPL da consulta

@author Juliana Iwayama Velho
@since 07/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFiltRst(cTabela, lSql)
	Local aArea      := GetArea()
	Local cPesq      := ''
	Local cCampo     := ''
	Local cRet       := ''
	Local lRestCad   := (AllTrim( SuperGetMv('MV_JRSTCAD',,'2')) == '1')
	Local oSaveModel := FWModelActive()			// Alterado apôs analise em conjunto com o Ernani Forastieri.
	Local cRestEscri := ""
	Local cRestArea  := ""
	Local lNYKInDic  := FWAliasInDic("NYK")
	Local lNYLInDic  := FWAliasInDic("NYL")
	Local cConcat    := ""
	Local cQuery     := ""
	Local cQrySel    := ""
	Local cQryFrm    := ""
	Local cQryWhr    := ""
	Local cAliasRst  := GetNextAlias()
	Local aX2Unico   := {}

	Default lSql := .F.

	If  IsInCallStack('JURA162') .And. lRestCad

		Do Case
		Case J162Active()
			cPesq := J162GetPesq()
		Case J163Active()
			cPesq := J163GetPesq()
		End Case

		If  cPesq <> Nil .And. !Empty(cPesq)
			If  (cTabela == 'NS7') .And. lNYKInDic
				J162XBEscri("xx", @cRestEscri)

				If  !( Empty(cRestEscri) )  //Caso haja, prioriza Restricao de dados e desconsidera a restricao do cadastro basico.
					cPesq := ""  //Anula o valor para nao entrar no cadastro basico
				EndIf
			ElseIf (cTabela == 'NRB') .And. lNYLInDic
				J162XBArea("xx", .T./*lAtivo*/, @cRestArea)

				If  !( Empty(cRestArea) )  //Caso haja, prioriza Restricao de dados e desconsidera a restricao do cadastro basico.
					cPesq := ""  //Anula o valor para nao entrar no cadastro basico
				EndIf
			EndIf
		EndIf

		If  cPesq <> Nil .And. !Empty(cPesq) .And. Len(cTabela) > 2
			aX2Unico := StrToKArr(FWX2Unico(cTabela), '+')

			// Verifica se o X2Unico tem mais de 2 posições
			If Len(aX2Unico) > 1
				cCampo := aX2Unico[2] // [1] = Filial [2] = Código

				cAliasRst  := GetNextAlias()

				cQrySel := " SELECT NVA_PESQ "
				cQrySel +=       " ,NVB_TABELA "
				cQrySel +=       " ,NVC_VALOR "

				cQryFrm := " FROM " + RetSqlName('NVA') + " NVA INNER JOIN " + RetSqlName('NVB') + " NVB ON (NVB.NVB_CPESQ  = NVA.NVA_COD "
				cQryFrm +=                                                                             " AND NVB.NVB_FILIAL = NVA.NVA_FILIAL "
				cQryFrm +=                                                                             " AND NVB.D_E_L_E_T_ = ' ') "
				cQryFrm +=                                    " INNER JOIN " + RetSqlName('NVC') + " NVC ON (NVC.NVC_CTABEL = NVB.NVB_COD "
				cQryFrm +=                                                                             " AND NVC.NVC_FILIAL = NVB.NVB_FILIAL "
				cQryFrm +=                                                                             " AND NVC.D_E_L_E_T_ = ' ') "

				cQryWhr := " WHERE NVA.NVA_CPESQ = '" + cPesq + "' "
				cQryWhr +=   " AND NVB.NVB_TABELA = '" + cTabela + "' "
				cQryWhr +=   " AND NVA.D_E_L_E_T_ = ' '"

				cQuery := cQrySel + cQryFrm + cQryWhr

				cQuery := ChangeQuery(cQuery)

				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasRst, .F., .F. )

				While (cAliasRst)->(!Eof())
					If lSql
						cConcat += "'" + SubStr((cAliasRst)->NVC_VALOR,1 , TamSX3(cCampo)[1]) + "'"
					Else
						cConcat += "Alltrim(" + cCampo + ") == '" + AllTrim((cAliasRst)->NVC_VALOR) + "'"
					EndIf
					(cAliasRst)->(DbSkip())

					If (cAliasRst)->(!Eof())
						If lSql
							cConcat += ","
						Else
							cConcat += " .Or. "
						EndIf
					EndIf
				End

				If lSql .AND. !Empty(cConcat)
					cRet := cCampo + " IN (" +cConcat + ")"
				Else
					cRet := cConcat
				EndIf

				(cAliasRst)->( dbCloseArea() )

			EndIf
		EndIf
	EndIf

	FWModelActive(oSaveModel,.T.)

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldRest
Validação dos campos restritos

@author Jorge Luis Branco Martins Junior
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------

Function JurVldRest(cTabela, cCod)
	Local aArea   := GetArea()
	Local lRet 		:= .F.
	Local lCtr		:= .F.
	Local cFiltro	:= ""
	Local nI			:= 0
	Local aCampo	:= {}
	Local cParam	:= AllTrim( SuperGetMv('MV_JRSTCAD',,'2'))
	Local cRestEscri := ""
	Local cRestArea  := ""
	Local lNYKInDic  := FWAliasInDic("NYK")
	Local lNYLInDic  := FWAliasInDic("NYL")

	If cTabela == 'RD0'
		cCod := RD0->RD0_SIGLA
	EndIf

	Begin Sequence

		If (cParam != '1')
			lRet := .T.
			Break
		EndIf

		If  (cTabela == 'NS7') .And. lNYKInDic
			J162XBEscri(AllTrim(cCod), @cRestEscri)

			If  !( Empty(cRestEscri) )  //Caso haja, prioriza Restricao de dados e desconsidera a restricao do cadastro basico.
				lRet := !Empty(cCod) .And. (AllTrim(cCod) $ cRestEscri)
				Break
			EndIf
		ElseIf (cTabela == 'NRB') .And. lNYLInDic
			J162XBArea(AllTrim(cCod), .T./*lAtivo*/, @cRestArea)

			If  !( Empty(cRestArea) )  //Caso haja, prioriza Restricao de dados e desconsidera a restricao do cadastro basico.
				lRet := !Empty(cCod) .And. (AllTrim(cCod) $ cRestArea)
				Break
			EndIf
		EndIf

		cFiltro := JurFiltRst(cTabela)

		If  Empty(cFiltro)
			lRet := .T.
			Break
		EndIf

		For nI := 1 to Len(AllTrim(cFiltro))
			If SubStr(AllTrim(cFiltro),nI,1) == "'" .And. !lCtr
				aAdd( aCampo, SubStr(AllTrim(cFiltro),nI+1,Len(AllTrim(cCod))))
				lCtr := .T.
			ElseIf SubStr(AllTrim(cFiltro),nI,1) == "'" .And. lCtr
				lCtr := .F.
			EndIf
		Next

		If !Empty(aCampo)
			For nI := 1 to Len(aCampo)
				If aCampo[nI] == AllTrim(cCod)
					lRet := .T.
				EndIf
			Next
		EndIf

	End Sequence

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurQryRest
Retorna trecho de Query para consultas específicas, onde entrará a
restrição

@param 	cAlias   Tabela de restrição da NVB

@Return cFiltro	 Trecho de Query para consultas específicas

@author Jorge Luis Branco Martins Junior
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------

Function JurQryRest(cAlias)
	Local aArea   := GetArea()
	Local cPesq   := ''
	Local cCampo  := ''
	Local cRet    := ''
	Local aCod    := {}
	Local nCt     := 0
	Local oModel  := NIL
	Local oGridNVB, oGridNVC
	Local cParam	:= AllTrim( SuperGetMv('MV_JRSTCAD',,'2'))

	If IsInCallStack('JURA162') .And. cParam == '1'

		Do Case
		Case J162Active()
			cPesq := J162GetPesq()
		Case J163Active()
			cPesq := J163GetPesq()
		End Case

		If cPesq <> Nil .And. !Empty(cPesq)

			dbSelectArea("NVA")
			NVA->( dbSetOrder(2) )
			NVA->( dbSeek( xFilial( 'NVA' ) + cPesq ) )
			oModel   := FWLOADMODEL("JURA116")
			oModel:SetOperation(1)
			oModel:Activate()
			oGridNVB := oModel:GetModel("NVBDETAIL")
			oGridNVC := oModel:GetModel("NVCDETAIL")

			If oGridNVB:SeekLine( { {"NVB_TABELA",cAlias} } )

				aCod  := StrToArray(FWX2Unico(cEntidade), '+' )
				If !Empty(aCod )


					If cAlias == 'RD0'
						cCampo:= 'RD0_SIGLA'
					Else
						cCampo:= aCod[2]
					EndIf
				EndIf

				If oGridNVC:GetQtdLine() > 0
					For nCt := 1 To oGridNVC:GetQtdLine()
						oGridNVC:GoLine( nCt )
						If nCt == 1
							cRet += " And " + cCampo + " in ('" + AllTrim(oGridNVC:GetValue('NVC_VALOR')) + "' "
						Else
							cRet += ",'" + AllTrim(oGridNVC:GetValue('NVC_VALOR')) + "'"
						EndIf
					Next

					cRet += ")"
				EndIf
			Endif

			oModel:DeActivate()

		EndIf
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetRest
Rotina que exibe a tela para a seleção da pesquisa para restrição

@param 	cTabela   	Tabela de restrição da NVB
@param 	cCod   			Código de restrição da NVC
@param 	lMostra   	Verifica se será necessário aparecer a pergunta
										para restringir registro (para que não apareça
										a pegunta várias vezes seguidas para um mesmo
										cadastro)

@author Jorge Luis Branco Martins Junior
@since 13/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetRest(cTabela,cCod)
	Local aArea   := GetArea()
	Local cQuery  := ''
	Local cTmp    := ''
	Local lOk     := .T.
	Local nCt     := 0
	Local nI      := 0
	Local oDlg    := Nil
	Local aVetor  := {}
	Local aRet    := {}
	Local aDesc   := {}
	Local nTop    := 0
	Local cDesc   := ''
	Local oBtnConf , oBtnCancel, oPnlT, oPnlBtn
	Local cParam  := AllTrim( SuperGetMv('MV_JRSTCAD',,'2'))

	If cParam == '1' .and. !(JurAuto()) //"Se não for execução automática"

		If ApMsgYesNo(STR0044) //Deseja restringir esse cadastro?
			cQuery := "SELECT NVG_CPESQ CPESQ, NVG_DESC DESCR, NVG_TPPESQ TPPESQ
			cQuery += "	FROM " + RetSqlName( 'NVG' ) + " NVG "
			cQuery += "		WHERE NVG_FILIAL = '" +xFilial('NVG')+ "' "
			cQuery += "			AND NVG.D_E_L_E_T_ = ' '
			cQuery += "			AND NVG_DESC <> ''
			cQuery += "		GROUP BY NVG_FILIAL, NVG_CPESQ, NVG_DESC , NVG_TPPESQ
			cQuery += "		ORDER BY NVG_FILIAL, NVG_TPPESQ, NVG_CPESQ, NVG_DESC

			cQuery := ChangeQuery( cQuery )

			cTmp   := GetNextAlias()
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

			If (cTmp)->( EOF() )
				JurMsgErro(STR0045) //Não existem pesquisas para a restrição
				Return NIL
			Else
				While !(cTmp)->( EOF() )
					nCt += 1
					(cTmp)->( dbSkip() )
				End

				ProcRegua( nCt )

				If lOk
					(cTmp)->( dbGoTop() )
					While !(cTmp)->( EOF() )
						Do Case
						Case (cTmp)->(TPPESQ) == '4'
							cDesc := STR0068 //'Andamento'
						Case (cTmp)->(TPPESQ) == '2'
							cDesc := STR0052 //'Follow-Up'
						Case (cTmp)->(TPPESQ) == '1'
							cDesc := STR0053 //'Processo'
						Case (cTmp)->(TPPESQ) == '3'
							cDesc := STR0054 //'Garantia'
						End Case
						aAdd(aVetor, {(cTmp)->(DESCR) , cDesc, (cTmp)->(CPESQ) })
						(cTmp)->( dbSkip() )
					End

					(cTmp)->( dbCloseArea() )

					DEFINE DIALOG oDlg TITLE STR0046 FROM 0,0 TO 300,200 PIXEL //Restrição de Cadastros
					oPnlT         := TScrollBox():New(oDlg,0,0,0,0,.T.,.F.,.T.)
					oPnlBtn       := tPanel():New(0,0,'',oDlg,,,,,,20,20)
					oPnlBtn:Align := CONTROL_ALIGN_BOTTOM
					oPnlT:Align   := CONTROL_ALIGN_ALLCLIENT

					For nI := 1 To Len(aVetor)
						aAdd(aRet, TJurCheckBox():New(nTop, 1, aVetor[nI][1] ,{|| },oPnlT,058,010,,,,,,,,.T.,,,) )
						aAdd(aDesc, TSay():New(nTop, 60,{|| '' },oPnlT,,,,,,.T.,,,30,10) )
						aDesc[nI]:SetText(AllTrim(aVetor[nI][2]))
						aDesc[nI]:lWordWrap := .T.
						aRet[nI]:lCheckJur := .F.
						nTop += 10
					Next

					@ oPnlBtn:nTop + 5, oPnlBtn:nLeft + 10 Button oBtnConf  Prompt STR0047 Size 28 , 12 Of oPnlBtn Pixel Action ( JurRestOk(aRet,aDesc,aVetor,cTabela,cCod),oDlg:End())//'Confirmar'
					@ oPnlBtn:nTop + 5, oPnlBtn:nLeft + 65 Button oBtnCancel Prompt STR0048 Size 28 , 12 Of oPnlBtn Pixel Action ( oDlg:End())//'Cancelar'

					ACTIVATE MSDIALOG oDlg CENTER

				EndIf

			EndIf
		EndIf
	EndIf
	RestArea( aArea )

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} JurRestOk(cCajur)
Função que incluí o registro no cadastro para restrições selecionadas
Uso Geral.

@param aRet   - Vetor de conteúdo dos check-box selecionados
@param aDesc  - Vetor com as descrições da seleção
@param aVetor	- Vetor

@author Jorge Luis Branco Martins Junior
@since 15/08/12
@version 1.0
/*/
//----------------------------------------------------------------------
Function JurRestOk(aRet,aDesc,aVetor,cTabela,cCod,lAutomato,aDados)
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local lNVA				:= .F.
	Local cDesc			:= ''
	Local aRestr			:= {}
	Local nI				:= 0
	Local lGrNVA			:= .F.
	Local oModel, oModelNVB, oModelNVC

	Default lAutomato := .F.
	Default aDados    := {}

	If lAutomato
		If Len(aDados) > 0
			aRestr := aDados
		EndIf
	Else
		For nI := 1 to LEN(aRet)
			If aRet[nI]:lCheckJur
				Do Case
				Case aVetor[nI][2] == STR0068 //'Andamento'
					cDesc := '4'
				Case aVetor[nI][2] == STR0052 //'Follow-Up'
					cDesc := '2'
				Case aVetor[nI][2] == STR0053 //'Processo'
					cDesc := '1'
				Case aVetor[nI][2] == STR0054 //'Garantia'
					cDesc := '3'
				End Case
				aAdd(aRestr,{ aVetor[nI][3], cDesc , Alltrim(aVetor[nI][1]) })
			EndIf
		Next
	EndIf

	If LEN(aRestr) > 0
		For nI := 1 to LEN(aRestr)
			dbSelectArea("NVA")
			NVA->( dbSetOrder(2) )
			lNVA := NVA->( dbSeek( xFilial( 'NVA' ) + aRestr[nI][1] + aRestr[nI][2] ) )
			oModel   := FWLOADMODEL("JURA116")

			//Configuração para Pesquisa
			If !lNVA
				oModel:SetOperation( 3 )
				oModel:Activate()

				lGrNVA := ( oModel:SetValue('NVAMASTER','NVA_CPESQ',Alltrim(aRestr[nI][1])) .AND. oModel:SetValue('NVAMASTER','NVA_PESQ', aRestr[nI][3]) .AND.;
					oModel:SetValue('NVAMASTER','NVA_TIPO', aRestr[nI][2]) )

				If !lGrNVA
					lRet := .F.
					JurMsgErro(STR0049)//Houve erro na inclusão de restrição de pesquisa
				EndIf
			Else
				oModel:SetOperation( 4 )
				oModel:Activate()
			EndIf

			If lRet
				//Configuração de Tabelas
				oModelNVB := oModel:GetModel("NVBDETAIL")
				If !oModelNVB:SeekLine( { {"NVB_TABELA",cTabela} } )
					oModelNVB:AddLine()
					If !oModelNVB:SetValue('NVB_TABELA',cTabela)
						lRet := .F.
						JurMsgErro(STR0050)//Houve erro na inclusão de restrição da Tabela
					EndIf
				EndIf
			EndIf

			If lRet
				//Configuração de Registros
				oModelNVC := oModel:GetModel("NVCDETAIL")
				oModelNVC:AddLine()
				If !oModelNVC:LoadValue('NVC_VALOR',cCod)
					lRet := .F.
					JurMsgErro(STR0051)//Houve erro na inclusão de restrição do Registro
					Exit
				EndIf
			EndIf

			If lRet
				lRet := JurGrava(oModel)
			EndIf
			oModel:DeActivate()
		Next
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGrava
Grava a configuração de Restrição de cadastros básicos

@Param oModel	Model ativo
@Param lRet		.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 15/08/12
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JurGrava(oModel)
	Local aErro:= {}
	Local lRet := .F.
	If lRet := oModel:VldData()
		oModel:CommitData()
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6])
	EndIf
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} JurCodPai(cCajur)
FunÃ§Ã£o que retorna o processo origem de uma familia de incidentes.
Uso Geral.
@param cCajur - CÃ³digo do Assunto JurÃ­dico
@author ClÃ³vis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//----------------------------------------------------------------------
Function JurCodPai(cCajur)
	Local cAliasQry := GetNextAlias()
	Local cCajurPai := cCajur
	Local aArea     := GetArea()

	BeginSql Alias cAliasQry

	SELECT NSZ.NSZ_COD, NSZ.NSZ_CPRORI
	FROM %table:NSZ% NSZ
	WHERE NSZ.NSZ_COD  = %Exp:cCajur%
	AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
	AND NSZ.%notDEL%

	EndSql

	If !(cAliasQry)->( Eof() )

		//Verifica se existe o assunto jurídico
		If !Empty( (cAliasQry)->NSZ_CPRORI ) .And. !Empty( JurGetDados("NSZ", 1, xFilial("NSZ") + (cAliasQry)->NSZ_CPRORI, "NSZ_COD") )
			cCajurPai := JurCodPai( (cAliasQry)->NSZ_CPRORI )
		Endif
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return cCajurPai

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLibDoc
Exibe a tela de liberação de documento no módulo de compras para
consulta do status da garantia/despesa

@Param oModel	Model ativo
@Param lRet		.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 15/08/12
@version 1.0

/*/
//-------------------------------------------------------------------
Function JurLibDoc(cTabela, cTipoL, cCajuri, cCod, cFilDest)
	Local aArea     := GetArea()
	Local aAreaSCR  := SCR->( GetArea() )
	Local aAreaSC7  := SC7->( GetArea() )
	Local aDados	:= {}
	Local aNV3		:= {}
	Local cNum		:= ''
	Local cTipo		:= ''
	Local lPedido   := .F.
	Local aRotClone := NIL
	Local cFiltro   := ""
	Local cFilTit	:= IIf(!Empty(cFilDest),FwXfilial('SCR',cFilDest),xFilial("SCR"))
	Local aLegendas :=     {{ 'CR_STATUS == "01"' ,'BLUE' },;	//Bloqueado p/ sistema (aguardando outros niveis)
	{ 'CR_STATUS == "02"' ,'RED'  },;	//Aguardando Liberacao do usuario
	{ 'CR_STATUS == "03"' ,'GREEN'},; 	//Pedido Liberado pelo usuario
	{ 'CR_STATUS == "04"' ,'BLACK'},;  	//Pedido Bloqueado pelo usuario
	{ 'CR_STATUS == "05"' ,'GRAY' }}  	//Pedido Liberado por outro usuario

	Private cCadastro := ''
	Private aRotina

	aAdd( aNV3, 'NV3_COD'  )
	aAdd( aNV3, 'NV3_PEDIDO'  )
	aDados := JurGetDados("NV3",2,xFilial("NV3")+cCajuri+cCod+cTipoL, aNV3)
	If len(aDados) > 0
		If cTabela == 'NT3' .OR. cTabela == 'NT2'
			If ValType(aDados) == "A"
				If !Empty(aDados[2])
					cTipo := 'PC'
					cNum := aDados[2]
					SC7->( dbSetOrder( 1 ) )
					If Type( 'aRotina' ) == 'A'
						aRotClone := aClone( aRotina )
					EndIF
					aRotina := {{ "Visualizar", "A120PEDIDO", 0, 2, 0, NIL } }
					lPedido := SC7->( dbSeek( xFilial( 'SC7' ) + cNum ) )
				EndIf
			EndIf
		EndIf

		If lPedido
			a120Posic( 'SC7', SC7->(Recno()), 1,/*''*/, .f. )
			If aRotClone <> NIL
				aRotina :=aClone( aRotClone )
			EndIf
		Else
			If !Empty(Posicione('SCR', 2, cFilTit + cTipo + cNum,'CR_NUM'))

				cCadastro := STR0062	//'Liberação de Documentos Jurídicos'
				aRotina   := {{STR0001, "AxPesqui"                      , 0, 1} ,; //"Pesquisar"
				{STR0002, "AxVisual"                      , 0, 2} ,; //"Visualizar"
				{STR0063, "JALegLibDc()" 					, 0, 7} } // 'Liberação de Documentos Jurídicos'"

				cFiltro := " CR_FILIAL  = '" + cFilTit + "' "
				cFiltro += "   AND CR_NUM  = '" + cNum  + "' "
				cFiltro += "   AND CR_TIPO = '" + cTipo + "' "


				DbSelectArea("SCR")
				SCR->( DbSetOrder(2) )
				mBrowse( 0, 0, 0, 0, "SCR",,,,,, aLegendas,,,,,,,, cFiltro)
			Else
				APMsgStop(STR0061)//"Não existe documento a ser liberado vinculado a este registro"
			EndIf
		EndIf
	EndIf

	RestArea( aAreaSC7 )
	RestArea( aAreaSCR )
	RestArea( aArea    )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JALegLibDc
Exibe a legenda da tela de Liberação de documento

@param 	Nil

@Return Nil

@author Jorge Luis Branco Martins Junior
@since 29/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JALegLibDc()
	Local aCores    := {}
	Local cCadastro := STR0062 //'Liberação de Documentos Jurídicos'

	aAdd( aCores, { "BR_AZUL" , STR0056 } )	//Bloqueado (aguardando outros niveis)
	aAdd( aCores, { "DISABLE" , STR0057 } ) //Aguardando Liberacao do usuario
	aAdd( aCores, { "ENABLE"  , STR0058 } ) //Pedido Liberado pelo usuario
	aAdd( aCores, { "BR_PRETO", STR0059 } ) //Pedido Bloqueado pelo usuario
	aAdd( aCores, { "BR_CINZA", STR0060 } ) //Pedido Liberado por outro usuario

	BrwLegenda( cCadastro, OemToAnsi(STR0063), aCores ) // "Status"

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} IsPesquisa()
Retorna .T. se esta sendo chamado pela pesquisa, sendo a pesquisa de
Assuntos jurÃ­dicos ou o configurador da pesquisa.
Uso Geral.

@Return 	Boolean		Se Ã© pesquisa ou nÃ£o.

@author Felipe Bonvicini Conti
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function IsPesquisa()
Return (Type('lPesquisa') != 'U' .And. lPesquisa)
//-------------------------------------------------------------------
/*/{Protheus.doc} JAGetGrpAp
Indica o grupo de aprovação de garantias para o controle de alçada

@param 	cCajuri		Codigo do Processo
				cCod      Codigo da Garantia
				cTipo     Tipo da Garantia
				nTipo     1 - Inclusão de Garantia
									2 - Correção de valores de garantias
				lMsg			Indica se é necessário exibir mensagem de erro
									(No caso da correção de valores para que não
									fique repetindo a mensagem várias vezes)

@Return cGrupo		Grupo de Aprovação

@author Jorge Luis Branco Martins Junior
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAGetGrpAp(cCajuri, cCod, cTipo, nTipo, lMsg)
	Local cGrupo     := ""
	Local lRet       := .T.
	Local lAlcada    := (SuperGetMV('MV_JALCADA',, '2') == '1')
	Local lLibAlcada := (SuperGetMV('MV_FINCTAL',, '2') == '2')//Opção para liberação de movimentos com base no formato de liberação simples ou alçada Ex: 1=Liberação Simples ou 2=Alçada
	local lIntCom    := ''

	Default cCajuri := ""
	Default cCod    := ""
	Default cTipo   := JurGetDados("NT2",5,XFILIAL("NT2")+cCod+cCajuri, "NT2_CTPGAR")
	Default lMsg    := .T.

	lIntCom := JurGetDados("NQW", 1, XFILIAL("NQW") + cTipo, "NQW_INTCOM") == "1"

	If lAlcada

		If lIntCom
			cGrupo := JurGetDados("NQW", 1, XFILIAL("NQW") + cTipo, "NQW_GRPAPR")
		EndIf

		If Empty(Alltrim(cGrupo))
			cGrupo := SuperGetMV('MV_JAPROVE',, '')

			Do Case
			Case lIntCom .and. !Empty(cGrupo)
				lRet := !Empty(JurGetDados("SAL", 1, XFILIAL("SAL") + cGrupo, "AL_COD"))

				If !lRet
					JurMsgErro(STR0110 + ": " + cGrupo + STR0111) // "Não é possível confirmar a inclusão, pois a integração com o controle de alçada está ativo e o grupo: " + código do grupo
					// " que foi informado no parâmetro MV_JAPROVE não pertence ao grupo de aprovação do módulo: Compras! Verifique!"
				EndIf
			Case !lIntCom .and. !Empty(cGrupo)
				lRet := !Empty(JurGetDados("FRP", 1, XFILIAL("FRP") + cGrupo, "FRP_COD"))

				If !lRet
					JurMsgErro(STR0112 + ": " + cGrupo + STR0113) // "Não é possível confirmar a inclusão, pois a integração com o controle de alçada está ativo e o grupo: " + código do grupo
					// " que foi informado no parâmetro MV_JAPROVE não pertence ao grupo de aprovação do módulo: Financeiro! Verifique!"
				EndIf
			End Case
		EndIf

		If Empty(Alltrim(cGrupo)) .AND. lLibAlcada
			lRet := .F.
			If nTipo == 1
				JurMsgErro(STR0065 + cTipo + " - " + Alltrim(JurGetDados("NQW", 1, XFILIAL("NQW") + cTipo, "NQW_DESC")) + STR0066)
			ElseIf nTipo == 2 .And. lMsg
				JurMsgErro(STR0067 + cTipo + " - " + Alltrim(JurGetDados("NQW", 1, XFILIAL("NQW") + cTipo, "NQW_DESC")) + STR0066)
			EndIf
		EndIf
	EndIf

	aRet := {lRet, cGrupo}

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VlDtMoeda()
Valida a data e o codigo da moeda.
Uso Geral.

@param 		aCmpMoeda		Array com as informações de Data[1] e Codigo[2]
							moeda
@Return 	Boolean		Se e valido ou nÃ£o.

@author Rafael Rezende Costa
@since 05/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function VlDtMoeda(aCmpMoeda)
	Local lRet := .T.
	Default aCmpMoeda := {}

// Valida se a moeda preenchida esta condizente com o período cadastrada.
	If lRet.And.Len(aCmpMoeda) > 0
		If !Empty(aCmpMoeda[1]) .And. !Empty(aCmpMoeda[2]) // Necessário esta preenchida para entrar na validação
			lRet := JurVinMoe(aCmpMoeda[1],aCmpMoeda[2] )
		EndIF
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JURX3XADesc()
Retorna o conteudo do X3_Folder

@Return 	cRet		Informação da SXA (Folders)

@author Ernani Forastieri
@since 16/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURX3XADesc( cField, lX3Seek )
	Local aArea     := GetArea()
	Local aAreaSXA  := SXA->( GetArea() )
	Local cRet      := ''
	Local lGo       := .T.

	Default lX3Seek := .T.

	If lX3Seek
		lGo := !Empty( GetSx3Cache(cField,"X3_FOLDER") )
	EndIf

	If lGo
		SXA->( dbSetOrder( 1 ) )
		If SXA->( dbSeek( GetSx3Cache(cField,"X3_ARQUIVO") + GetSx3Cache(cField,"X3_FOLDER") ) )
			cRet := XADescric()
		EndIf
	EndIf


	RestArea( aAreaSXA )
	RestArea( aArea    )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURCPO
Campos a serem exibidos

@param 	 cTabela  	Tabela a ser verificada
@Return aArray	 	  Array de campos

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURCPO(cCampo, cFil, cAssJur, cTipoAjCPO)
	Local lRet       := .F.
	Local aArea      := GetArea()
	Local aAreaNUZ   := NUZ->( GetArea() )
	Local cTipoOri	 := ''

	Default cTipoAjCPO := JurGetDados("NSZ",1,XFILIAL("NSZ")+cAssJur, "NSZ_TIPOAS")

	If x3Obrigat( PadR( cCampo, 10 ) )
		lRet := .T.
		Return lRet
	Else

		If cTipoAjCPO > '050'
			cTipoOri := JurGetDados("NYB",1,XFILIAL("NYB")+cTipoAjCPO, "NYB_CORIG")
		EndIf

		NYD->( dbSetOrder( 1 ) )

		If !(cTipoAjCPO > '050' .AND. (NYD->( dbSeek( xFilial( 'NYD' ) + cTipoAjCPO + PadR( cCampo, 10 ) ) ) ) )

			NUZ->( dbSetOrder( 1 ) )

			If cTipoAjCPO > '050' .AND. NUZ->( dbSeek( xFilial( 'NUZ' ) + cTipoOri + PadR( cCampo, 10 ) ) )

				lRet := .T.
				Return lRet

			EndIf

			If NUZ->( dbSeek( xFilial( 'NUZ' ) + cTipoAjCPO + PadR( cCampo, 10 ) ) )

				lRet := .T.
				Return lRet

			EndIf

		EndIf

	EndIf

	RestArea( aAreaNUZ )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetCPesq()
Retorna a pesquisa vigente

@Return 	cPesq		Codigo da pesquisa usada

@author Jorge Luis Branco Martins Junior
@since 28/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetCPesq()
	Local cPesq	:= ""

	If IsPesquisa().Or. IsInCallStack("JURA162")
		Do Case
		Case J162Active()
			cPesq := J162GetPesq()
		Case J163Active()
			cPesq := J163GetPesq()
		End Case
	ElseIf J162Active()
		cPesq := J162GetPesq()
	EndIf

Return cPesq

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetNmFld
Funcao para alterar nome/título do campo conforme configuração feita

@Param oStruct 			Struct ativo;
				cPesq 				Código da pesquisa usada no momento;
				cTipoAJ 			Código do tipo de assunto jurídico selecionado;
				cTipoAJ2 		Código "Pai" do tipo de assunto jurídico
											selecionado( Caso cTipoAJ > '50', trás o tipo
do assunto pai;

@author Jorge Luis Branco Martins Junior
@since 17/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
	Function JGetNmFld(oStruct, cTipoAJ, cTipoAJ2)
	Local aArea	:= GetArea()
	Local aAux	:= {}
	Local nI	:= 0

	If __Language == 'PORTUGUESE' .And. cTipoAJ2 != "CFG"

		aAux := oStruct:GetFields()

		NUZ->( dbSetOrder( 1 ) )
		For nI := 1 to Len(aAux)
			If NUZ->( dbSeek( xFilial( 'NUZ' ) + cTipoAJ + PadR( Alltrim(aAux[nI][1]), 10 ) ) )
				oStruct:SetProperty( Alltrim(aAux[nI][1]) , MVC_VIEW_TITULO, AllTrim(NUZ->NUZ_DESCPO) )
			ElseIf cTipoAJ != cTipoAJ2 .And. !Empty(Alltrim(cTipoAJ2)) .And. NUZ->( dbSeek( xFilial( 'NUZ' ) + cTipoAJ2 + PadR( Alltrim(aAux[nI][1]), 10 ) ) )
				oStruct:SetProperty( Alltrim(aAux[nI][1]) , MVC_VIEW_TITULO, AllTrim(NUZ->NUZ_DESCPO) )
			EndIf
		Next
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldClRst
Função para validar cliente e loja caso haja restrição de usuario

@param  cCliente - codigo de cliente selecionado
@param  cLoja    - codigo de loja selecionado
@Return lRet     - .T. ou .F.

@author Rafael Rezende Costa
@since 23/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldClRst(cCliente, cLoja)
	Local lRet		:= .T.
	Local aRstri	:= {}
	Local cUser	:= ''
	Local cLojaAuto := SuperGetMv( "MV_JLOJAUT" , .F. , "2" , ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	Default cCliente := ''
	Default cLoja := ''

	If !EMPTY(cCliente) .AND. !EMPTY(cLoja)

		If !('CORRESPONDENTES' == JurGrpRest(__CUSERID))  //grupo de restricao
			aRstri:= JA162RstUs(,,.T.) // 3 Parametro para verificar a restricao de grupos de clientes e correspondentes para filtro dos registros de acordo com a restricao utilizada (sendo por código de cliente/fornecedor)

			If LEN (aRstri) > 0
				If aScan( aRstri, {|x| x[2]== cCliente .AND. x[3]== cLoja } ) < 1
					lRet := .F.
					cUser	:= __CUSERID
					JurMsgErro(STR0070 +CRLF+CRLF+ STR0071 + PswChave(cUser) + STR0072 +CRLF+CRLF+STR0073) // "Cliente e Loja inválidos!"+CRLF+"O Usuario " + UsrRetName(cUser) + " possui restrição de clientes/correspondente ativada."+CRLF+" Adicione este 'Cliente/Loja' na restrição caso deseje utilizá-lo."
				EndIf
			EndIf
		EndIf
	EndIf

	If cLojaAuto == '1' .And. lRet
		If (Val(cLoja) / 1) <> 0
			lRet:= .F.
			JurMsgErro(STR0101, ,STR0102)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURFILUSR
Pesquisa no cadastro do usuário as filiais que ele podera ter acesso
no sistema

@author Roberto Vagner Gomes
@since 16/10/2013
@version MP11.8

@param cCodUsr, character, String contendo o codigo do usuário a ser pesquisado
@param cAliasFil, character, Alias para verificar o compartilhamento entre empresas, unidades de negocio e filiais
@return array, Vetor contendo as filiais para o usuario
@obs
Formato do array de retorno
aRet[1] := "E1U1F1;E1U1F2" //String concatenada
aRet[2] := ";" //Caracter Separador
aRet[3] := {"E1U1F1","E1U1F2"} //Vetor por filial
/*/
//-------------------------------------------------------------------
Function JURFILUSR( cCodUsr, cAliasFil )
	Local aArea   	:= GetArea()
	Local aSM0Area	:= SM0->(GetArea())
	Local aRet    	:= {}
	Local aAux    	:= {}
	Local aUser		:= {}
	Local cFilTmp 	:= ""
	Local cFilRet 	:= ""
	Local nPos    	:= 0
	Local nFor			:= 0
	Local cGrpEmp		:= cEmpAnt //SM0->M0_CODIGO
	Local cGrpUser	:= ""


	Default cAliasFil := "NSZ"

// Pesquisa usuário
	PswOrder(1)
	If PswSeek(cCodUsr,.T.)
		aUser 		:= PswRet()
		If Len(aUser[1][10] ) > 0
			cGrpUser 	:= aUser[1][10][1]
		Endif
	Endif

	SM0->(DbSetOrder(1))

// Pequisa pelo usuário
	If Len(aUser[2][6] ) > 0

		// Verifica as filiais que tem acesso
		For nFor := 1 To Len(aUser[2][6])

			cFilTmp := aUser[2][6][nFor]

			// Situação em que o usuário tem acesso a todas as filiais
			If Alltrim(cFilTmp) == "@@@@"

				SM0->(DbSeek(cGrpEmp))

				While SM0->(!EOF()) .And. SM0->M0_CODIGO  == cGrpEmp

					//Executa o xFilial para o Alias
					cFilTmp := SM0->M0_CODFIL
					cFilTmp := FWxFilial( cAliasFil,cFilTmp)

					//Se ja nao teve nenhuma ocorrencia, adiciona no retorno
					If ( nPos := aScan( aAux, cFilTmp ) == 0 )

						aAdd(aAux,cFilTmp)
						cFilRet += IIf( Empty(cFilRet),"",";") + cFilTmp

					Endif

					SM0->(DbSkip())

				Enddo


			Else

				If SM0->(DbSeek(aUser[2][6][nFor])) .And. SM0->M0_CODIGO ==  cGrpEmp

					//Executa o xFilial para o Alias
					cFilTmp := SM0->M0_CODFIL
					cFilTmp := FWxFilial( cAliasFil,cFilTmp)

					//Se ja nao teve nenhuma ocorrencia, adiciona no retorno
					If ( nPos := aScan( aAux, cFilTmp ) == 0 )

						aAdd( aAux, cFilTmp )

						cFilRet += IIf( Empty(cFilRet), "", ";" ) + cFilTmp

					EndIf

				Endif

			Endif

		Next nFor

	Else

		// Pesquisa o Grupo
		PswOrder(1)
		If PswSeek(cGrpUser,.F.)
			aUser := PswRet()
		Endif

		SM0->(DbSetOrder(1))

		If Len(aUser[1][11] ) > 0 .AND. VALTYPE(aUser[1][11]) == 'A'

			// Verifica as filiais que tem acesso
			For nFor := 1 To Len(aUser[1][11])

				cFilTmp := aUser[1][11][nFor]

				// Situação em que o usuário tem acesso a todas as filiais
				If Alltrim(cFilTmp) == "@@@@"

					SM0->(DbSeek(cGrpEmp))

					While SM0->(!EOF()) .And. SM0->M0_CODIGO  == cGrpEmp

						//Executa o xFilial para o Alias
						cFilTmp := SM0->M0_CODFIL
						cFilTmp := FWxFilial( cAliasFil,cFilTmp)

						//Se ja nao teve nenhuma ocorrencia, adiciona no retorno
						If ( nPos := aScan( aAux, cFilTmp ) == 0 )

							aAdd(aAux,cFilTmp)
							cFilRet += IIf( Empty(cFilRet),"",";") + cFilTmp

						Endif

						SM0->(DbSkip())

					Enddo


				Else

					If SM0->(DbSeek(aUser[1][11][nFor])) .And. SM0->M0_CODIGO ==  cGrpEmp

						//Executa o xFilial para o Alias
						cFilTmp := SM0->M0_CODFIL
						cFilTmp := FWxFilial( cAliasFil,cFilTmp)

						//Se ja nao teve nenhuma ocorrencia, adiciona no retorno
						If ( nPos := aScan( aAux, cFilTmp ) == 0 )

							aAdd( aAux, cFilTmp )

							cFilRet += IIf( Empty(cFilRet), "", ";" ) + cFilTmp

						EndIf

					Endif

				Endif

			Next nFor

		Endif

	Endif

	aAdd( aRet, cFilRet )
	aAdd( aRet, ";"     )
	aAdd( aRet, aAux    )

	RestArea( aArea )
	RestArea( aSM0Area )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCANCHANGE
Validação de Operações
@param 	oModel  	Model a ser verificado
@Return lTudoOk	Valor lógico de retorno
@sample {|oModel| JURA098CAN(oModel)}
@author Clóvis Eduardo Teixeira
@since 29/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCANCHANGE( oModel , cTabela )
	Local nOpc     := oModel:GetOperation()
	Local aArea    := GetArea()
	Local lRet     := .T.
	Local cCajuri  := ''
	Local cCod     := ''
	Local aDados   := {}
	Local cTmp     := ""
	Local aNV3     := {}
	Local aDados2  := {}
	Local lPedido  := .F.
	Local cTipo    := ''
	Local lIntVal  := SuperGetMV('MV_JINTVAL',, '2') == '1'

	If cTabela == 'NT2'

		cCajuri  := NT2->NT2_CAJURI
		cCod     := NT2->NT2_COD

		If (nOpc == 4 .Or. nOpc == 5) .And. AllTrim(JurGetDados("NV3",2,FwxFilial('NV3')+cCajuri+cCod+"91", "NV3_LA")) == "S"
			lRet := .F.
			JurMsgErro(STR0090)//"Não é possivel 'Alterar / Excluir' este registro pois seus valores já foram contabilizados"
			RestArea ( aArea )
			Return lRet
		ElseIf lIntVal .and. nOpc == 4 .And. NT2->NT2_INTFIN != "2" .And. !Empty(NT2->NT2_CTIPOT)
			lRet := .F.
			JurMsgErro(STR0091)//"Não é possivel alterar este registro pois a integração do SIGAJURI com o módulo SIGAFIN está habilitada"
			RestArea ( aArea )
			Return lRet
		EndIf

		If nOpc == 4

			aDados  := JurQryAlc(cTabela, cCajuri, cCod, IIF(cTabela == 'NT2','2','3'),.T.)
			cTmp	:= GetNextAlias()

			// Obtem os titulos do contas a pagar do tabelado
			cQuery := "SELECT R_E_C_N_O_ SE2RECNO "
			cQuery += "  FROM " + RetSqlName( "SE2" ) + " SE2 "
			cQuery += "  WHERE SE2.E2_FILIAL	= '" + FwxFilial('SE2') + "' "
			cQuery += "	AND SE2.E2_PREFIXO	= '" + aDados[5] + "' "
			cQuery += "	AND SE2.E2_NUM IN ('" + aDados[4] + "') "
			cQuery += "	AND SE2.E2_TIPO		= '" + aDados[7] + "' "
			cQuery += "	AND SE2.E2_FORNECE	= '" + aDados[8] + "' "
			cQuery += "	AND SE2.E2_LOJA		= '" + aDados[9] + "' "
			cQuery += "	AND SE2.D_E_L_E_T_	= ' ' "
			cQuery += "	ORDER BY " +  SQLOrder( SE2->( IndexKey( 1 ) ) )

			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

			If !( cTmp )->( EOF() )
				lRet := .F.
				JurMsgErro(STR0076) //"Nao e possivel 'Alterar / Excluir' este registro pois existe titulo gerado via integracao contabil."
				( cTmp )->( DbCloseArea() )
				RestArea ( aArea )
				Return lRet
			Endif
			( cTmp )->( DbCloseArea() )

			aAdd( aNV3, 'NV3_COD'  )
			aAdd( aNV3, 'NV3_PEDIDO'  )
			aDados2 := JurGetDados("NV3",2,FwxFilial('NV3')+cCajuri+cCod+"2", aNV3)

			If JurGetDados("NT2",5,FwxFilial("NT2")+cCod+cCajuri, 'NT2_MOVFIN') == '1'
				If  Len(aDados2) > 0
					If !Empty(aDados2[1])
						cTipo := 'GA'
						cNum := 'NV3'+aDados2[1]
					EndIf
				EndIf
			EndIf

			if !Empty(cTipo) .And. !Empty(cNum)

				cQuery := "SELECT R_E_C_N_O_ SCRRECNO"
				cQuery += "  FROM " + RetSqlName( "SCR" ) + " SCR "
				cQuery += "  WHERE SCR.CR_FILIAL  = '" + FwxFilial('SCR') + "' "
				cQuery += "   AND SCR.CR_NUM  = '" + cNum  + "' "
				cQuery += "   AND SCR.CR_TIPO = '" + cTipo + "' "
				cQuery += "   AND SCR.D_E_L_E_T_ = ' ' "
				cQuery += "   ORDER BY " +  SQLOrder( SCR->( IndexKey( 1 ) ) )

				dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

				If !( cTmp )->( EOF() )
					lRet := .F.
					JurMsgErro(STR0077) //"Nao e possivel 'Alterar / Excluir' este registro pois existe pedido de compra gerado via integracao contabil."
				Endif
				( cTmp )->( DbCloseArea() )
			Endif
		Endif

		RestArea ( aArea)

	Else

		If nOpc == 4

			cCajuri  := NT3->NT3_CAJURI
			cCod     := NT3->NT3_COD
			aDados   := JurQryAlc(cTabela, cCajuri, cCod, IIF(cTabela == 'NT2','2','3'),.T.)
			cTmp     := GetNextAlias()

			// Obtem os titulos do contas a pagar do tabelado
			cQuery := "SELECT R_E_C_N_O_ SE2RECNO "
			cQuery += "  FROM " + RetSqlName( "SE2" ) + " SE2 "
			cQuery += "  WHERE SE2.E2_FILIAL	= '" + FwxFilial('SE2') + "' "
			cQuery += " AND SE2.E2_PREFIXO	= '" + aDados[5] + "' "
			cQuery += " AND SE2.E2_NUM		= '" + aDados[4] + "' "
			cQuery += " AND SE2.E2_TIPO		= '" + aDados[7] + "' "
			cQuery += " AND SE2.E2_FORNECE	= '" + aDados[8] + "' "
			cQuery += " AND SE2.E2_LOJA		= '" + aDados[9] + "' "
			cQuery += " AND SE2.D_E_L_E_T_	= ' ' "
			cQuery += " ORDER BY " +  SQLOrder( SE2->( IndexKey( 1 ) ) )

			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

			If !( cTmp )->( EOF() )
				lRet := .F.
				JurMsgErro(STR0076) //"Nao e possivel 'Alterar / Excluir' este registro pois existe titulo gerado via integracao contabil."
				( cTmp )->( DbCloseArea() )
				RestArea ( aArea )
				Return lRet
			Endif
			( cTmp )->( DbCloseArea() )

			aAdd( aNV3, 'NV3_COD'  )
			aAdd( aNV3, 'NV3_PEDIDO'  )
			aDados2 := JurGetDados("NV3",2,FwxFilial('NV3')+cCajuri+cCod+"3", aNV3)

			If  Len(aDados2) > 0
				If !Empty(aDados2[2])
					cTipo := 'PC'
					cNum := aDados2[2]
					SC7->( dbSetOrder( 1 ) )
					lPedido := SC7->( dbSeek( FwxFilial('SC7') + cNum ) )
				EndIf
			EndIf

			If lPedido
				lRet := .F.
				JurMsgErro(STR0078) //"Nao e possivel 'Alterar / Excluir' este registro pois existe pedido de compra gerado via integracao contabil."
			Endif
		Endif

		RestArea ( aArea)

	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetParTpa
Retorna o valor do parametro configurado na tabela NZ6 (TIPO ASS.JURIDICO X PARAMETROS) caso exista,
não existindo pega o valor do SX6.

@param	cTipoAs		- Codigo do tipo de assunto juridico
@param	cParam		- Nome do parametro que tera seu conteudo retornado
@param	cDefault	- Valor retornado caso nao encontre o parametro nas tabelas
@return xConteudo	- Retorna o valor do parametro

@author Rafael Tenorio da Costa
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetParTpa(cTipoAs, cParam, cDefault)

	Local aArea		:= GetArea()
	Local xConteudo := Nil

	Default cTipoAs := cTipoAsj

	DbSelectArea("NZ6")
	NZ6->( DbSetOrder(1) )		//NZ6_FILIAL+NZ6_TIPOAS+NZ6_CPARAM
	If NZ6->( DbSeek(xFilial("NZ6") + cTipoAs + cParam) )

		Do Case
		Case NZ6->NZ6_TIPO == "N"
			xConteudo := Val(NZ6->NZ6_CONTEU)

		Case NZ6->NZ6_TIPO == "D"
			xConteudo := CToD(NZ6->NZ6_CONTEU)

		Case NZ6->NZ6_TIPO == "C"
			xConteudo := AllTrim(NZ6->NZ6_CONTEU)
		Case NZ6->NZ6_TIPO == "L"
			xConteudo := &(AllTrim(NZ6->NZ6_CONTEU))

		Otherwise
			xConteudo := NZ6->NZ6_CONTEU
		EndCase
	Else

		xConteudo := SuperGetMv(cParam, .F., cDefault)

	EndIf

	If xConteudo == Nil
		xConteudo := cDefault
	EndIf

	RestArea( aArea )

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSM0FIL
Apresenta as Filiais disponiveis conforme acesso do usuário

@author Roberto Vagner Gomes
@since 21/10/2013
@version MP11.8

@param cAliasFil, character, Alias para verificar o compartilhamento entre empresas, unidades de negocio e filiais
@return array, Vetor contendo as informacoes da Filial
@obs
Formato do array de retorno
aRet[1] := "01SP01" //Filial utilizada
aRet[2] := "01MG01" //Backup do cFilAnt
aRet[3] := "001" //Bakup do Recno SM0

/*/
//-------------------------------------------------------------------

Function JURSM0FIL ( cAliasFil, cSM0Cpo, lShowPesq, cCodFil )
	Local aRet			:= {}
	Local cFilRet		:= ""
	Local cBkpFil		:= cFilAnt
	Local nRecSM0		:= SM0->(Recno())
	DEFAULT cSM0Cpo 	:= "M0_CODFIL"
	DEFAULT lShowPesq	:= .T.
	DEFAULT cCodFil		:= ""

	If lShowPesq

		//Exibe as Filiais disponivel para o grupo de empresa
		cFilRet := FWPesqSM0(cSM0Cpo,,FWModeAccess(cAliasFil,1),FWModeAccess(cAliasFil,2),FWModeAccess(cAliasFil,3),.T.)

	Else

		cFilRet := cCodFil

	Endif

//Verifica a Filial Selecionada
	If !Empty(cFilRet)

		If cFilAnt <> Subs(cFilRet,1,FWSizeFilial())

			cFilAnt := Subs(cFilRet,1,FWSizeFilial())

			SM0->(DbSetOrder(1))

			If SM0->(DbSeek(cEmpAnt+cFilAnt))

				If GetVersao(.F.) == "P10"

					oMsgItem3:SetText( Capital(AllTrim(FWGrpName(SM0->M0_CODIGO))) + " / " + Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) )

				Else

					// Versão 11 - Sem utilização do MDI
					If !FlatMode()

						AppSetMsgItem("EMPFIL", Capital(AllTrim(FWGrpName(SM0->M0_CODIGO))) + " / " + Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) )

					Else

						If !SetMDIChild(0)

							SetMDIBar(SPACE(2)+Capital(AllTrim(FWGrpName(SM0->M0_CODIGO))) + " / " + Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) + Chr(9) + oApp:oMsgItem2:cMsg + Chr(9) + oApp:oMsgItem1:cMsg)
							oApp:SetStatusBarText(GetMDIBar())

						Else
							__cMDIBar := " " + chr(9) + OemToAnsi(GetVersao()) + Chr(9) + cUserName + Chr(9) + Dtoc(dDataBase) + Chr(9) + Capital(AllTrim(FWGrpName(SM0->M0_CODIGO)))+ " / " +Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) + chr(9)+"#fw_rodape_logo_siga"
							SetMDIBar(__cMDIBar)
							oApp:SetStatusBarText(__cMDIBar)
						EndIf

					Endif


				Endif

			Endif

		Endif

	Endif

	aAdd( aRet, cFilRet )
	aAdd( aRet, cBkpFil )
	aAdd( aRet, nRecSM0 )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURVLDEDIT
Retorna se o usuário poderá editar ou visualizar registros de outras filiais

@author Roberto Vagner Gomes
@since 23/10/2013
@version MP11.8

@param nOpc, numeric, Opcao Selecionado
@param cFilEdit, character, Filial em que se deseja realizar alteracao
@return lRetorno , Boolean, Permite ou não realizar a alteração

/*/
//-------------------------------------------------------------------
Function JURVLDEDIT ( nOpc, cFilEdit, aEnvBkp )
	Local lRetorno := .F.
	Local lVisual	:= VerSenha(114)
	Local lEdita	:= VerSenha(115)
	Local cOpc		:= Alltrim(Str(nOpc ))

// Sendo a mesma filial permite a visualizacao e edicao

	If aEnvBkp[2] == cFilEdit

		lRetorno := .T.

	Else

		//Caso de Pesquisa e Visualizacao
		If cOpc $ "12" .And. ( lVisual .OR. lEdita )

			lRetorno := .T.

		Else

			lRetorno := lEdita

		Endif

	Endif

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J95NuzCpo
Campos a serem exibidos na tela

@param 	 cTabela  	Tabela a ser verificada
@param 	 lObrigat 	Adiciona uma condição na query que retorna os
campos selecionados como obrigatórios na configuração de pesquisa

@Return aArray	 	  Array de campos

@author André Spirigoni Pinto
@since 24/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95NuzCpo(cTipoAs,cTabela,lReport,lObrigat)
	Local aRet   := {}
	Local cSQL   := ''
	Local aArea  := GetArea()
	Local cAlias := GetNextAlias()
	Local lPort  := (__Language == 'PORTUGUESE')

	Default cTipoAs  := ""
	Default cTabela  := ""
	Default lReport  := .F.
	Default lObrigat := .F.

	cSQL  := "SELECT NUZ.NUZ_CAMPO "+Iif(lReport,', NUZ.NUZ_DESCPO', "") + " FROM "+ RetSqlname('NUZ') +" NUZ "+CRLF
	cSQL  += " WHERE NUZ.D_E_L_E_T_ = ' ' " +CRLF
	cSQL  += " AND NUZ.NUZ_CTAJUR = '"+cTipoAs+"' " +CRLF
	cSQL  += " AND NUZ.NUZ_FILIAL = '" + xFilial('NUZ') + "'"
	cSQL  += Iif(lObrigat," AND NUZ.NUZ_OBRIGA = 'T' ", "")

	If !Empty(cTabela)
		cSQL  += " AND NUZ.NUZ_CAMPO LIKE '" + (cTabela + '_') + "%' "
	Endif

	cSQL  += " AND NUZ.NUZ_FILIAL = '" + xFilial('NUZ') + "'"
	cSQL  += " UNION "
	cSQL  += "SELECT NUZ.NUZ_CAMPO "+Iif(lReport,', NUZ.NUZ_DESCPO', "") + " FROM "+ RetSqlname('NUZ') +" NUZ "+CRLF
	cSQL  += " JOIN "+RetSqlname('NYB')+" NYB "+CRLF
	cSQL  +=   " ON (NUZ.NUZ_CTAJUR = NYB.NYB_CORIG AND NYB.NYB_COD = '"+cTipoAs+"')"+CRLF
	cSQL  +=  " WHERE NUZ.D_E_L_E_T_ = ' ' " +CRLF
	cSQL  +=    " AND NUZ.NUZ_FILIAL = '" + xFilial('NUZ') + "'"
	cSQL  +=    " AND NYB.NYB_FILIAL = '" + xFilial('NYB') + "'"

	If !Empty(cTabela)
		cSQL  += " AND NUZ.NUZ_CAMPO LIKE '" + (cTabela + '_') + "%' "
	Endif

	cSQL  += Iif(lObrigat," AND NUZ.NUZ_OBRIGA = 'T' ", "")

	cSQL  += " AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("NYD")+" NYD WHERE NYD_CTPASJ ='"+ cTipoAs + "' AND NYD_CAMPO = NUZ.NUZ_CAMPO AND NYD.D_E_L_E_T_ = ' ' )"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )

		If lReport
			aAdd(aRet, {(cAlias)->NUZ_CAMPO, IIF(lPort, (cAlias)->NUZ_DESCPO, RetTitle((cAlias)->NUZ_CAMPO)) })
		Else
			aAdd(aRet, (cAlias)->NUZ_CAMPO)
		EndIf

		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JUltAnd
Função que retorna o último andamento de um assunto jurídico.

@param cCajuri: Código do assunto jurídico NT4_CAJURI
@param cFilNT4: Código da filial da tabela NT4 que deve ser utilizada.
@param lDesc:   Indica se é apresentado o teor

@Return aRet Array que contém as seguintes informações: 1 - RECNO, 2 - NT4_COD, 3 - NT4_CAJURI, 4 - NT4_DTANDA, 5-NT4_CATO, 6- NT4_DATO, 7- NT4_DESC

@author André Spirigoni Pinto
@since 27/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUltAnd(cCajuri, cFilNT4, lDesc)
Local aRet   := {}
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

Default cFilNT4 := xFilial("NT4")
Default lDesc   := .T.

	cSQL  := "SELECT NT4.R_E_C_N_O_ RECNO, NT4.NT4_COD, NT4.NT4_CAJURI, NT4.NT4_DTANDA, NT4.NT4_CATO, NRO.NRO_DESC NT4_DATO "
	cSQL  += "FROM "+ RetSqlname('NT4') +" NT4 JOIN "+RetSqlname('NRO')+" NRO ON (NT4.NT4_CATO = NRO.NRO_COD AND NRO.D_E_L_E_T_=' ') "
	cSQL  += "WHERE NT4.D_E_L_E_T_ = ' ' "
	cSQL  += "AND NT4.NT4_CAJURI = '" + cCajuri + "' "
	cSQL  += "AND NT4.NT4_FILIAL = '" + cFilNT4 + "'"
	cSQL  += "AND NT4.R_E_C_N_O_ =  (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlname('NT4') + " WHERE D_E_L_E_T_= ' ' AND NT4_FILIAL = NT4.NT4_FILIAL AND NT4_CAJURI = NT4.NT4_CAJURI AND NT4_DTANDA = (SELECT MAX(NT4_DTANDA) FROM "+RetSqlname('NT4')+" WHERE NT4_FILIAL = NT4.NT4_FILIAL AND NT4_CAJURI = NT4.NT4_CAJURI AND D_E_L_E_T_=' '))"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd(aRet,{(cAlias)->RECNO,(cAlias)->NT4_COD,(cAlias)->NT4_CAJURI,(cAlias)->NT4_DTANDA,(cAlias)->NT4_CATO,(cAlias)->NT4_DATO,""})
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	//Preenche o campo do tipo memo que não pode ser obtido pela query.
	If lDesc .And. len(aRet) > 0 .And. aRet[1][1] > 0
		dbSelectArea("NT4")
		NT4->( dbGoTo( aRet[1][1] ))

		aRet[1][7] := AllTrim(NT4->NT4_DESC)
	EndIf

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRespNTE
Responsáveis de um follow-up

@param        cFilNTA    Filial da tabela de follow-up
@param        cFollowup  Código do Follow-up
@Return aArray            Array de responsáveis

@author André Spirigoni Pinto
@since 24/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JRespNTE(cFilNTA, cFollowup, cFieldRd0)
	Local aRet := {}
	Local cSQL        := ''
	Local aArea := GetArea()
	Local cAlias      := GetNextAlias()

	Default cFieldRd0 := 'RD0_SIGLA'

	cSQL  := "SELECT RD0." + cFieldRd0 + " RD0_FIELD FROM "+ RetSqlname('NTE') +" NTE JOIN " + RetSqlname('RD0') + " RD0 ON (NTE.NTE_CPART = RD0.RD0_CODIGO) "+CRLF
	cSQL  += " WHERE NTE.D_E_L_E_T_ = ' ' " +CRLF
	cSQL  += " AND NTE.NTE_FILIAL = '" + cFilNTA + "'"
	cSQL  += " AND NTE.NTE_CFLWP  = '"+cFollowup+"' " +CRLF
	cSQL  += " AND RD0.D_E_L_E_T_ = ' ' " +CRLF
	cSQL  += " AND RD0.RD0_FILIAL = '" + xFilial('RD0') + "'"
	cSQL += " ORDER BY RD0.RD0_CODIGO"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd(aRet, AllTrim((cAlias)->RD0_FIELD))
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldSigla
Valida os campos xxx_SIGLA e atualiza os campos de codigo xxx_CPART
(NSZ_SIGLA1, NSZ_SIGLA2 ... NSZ_CPART1, NSZ_CPART2 ...)

@param	cSigla 	 - Codigo da sigla que sera validada
@param	cModel	 - Nome do modelo que tera o campo de codigo atualizado
@param	cCmpCod	 - Nome do campo de codigo que será atualizado

@return lRetorno - Define se a sigla foi validada

@author Rafael Tenorio da Costa
@since 08/12/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldSigla(cSigla, cModel, cCmpCod)

	Local aAreaRD0 	:= RD0->( GetArea() )
	Local lRetorno	:= .F.
	Local oModel	:= FWModelActive()

	RD0->( DbSetOrder(9) )		//RD0_FILIAL + RD0_SIGLA
	If RD0->( DbSeek( xFilial("RD0") + cSigla ) ) .And. RD0->RD0_TPJUR == "1"

		//Atualiza o codigo do participante
		lRetorno := oModel:SetValue(cModel, cCmpCod, RD0->RD0_CODIGO)
	EndIf

	RestArea( aAreaRD0 )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JGatSigla
Gatilho dos campos xxx_SIGLA (NSZ_SIGLA1, NSZ_SIGLA2 ...)

@param	cSigla 	 - Codigo da sigla que sera validada

@return cRetorno - Nome do participante

@author Rafael Tenorio da Costa
@since 08/12/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGatSigla(cSigla)

	Local aAreaRD0 	:= RD0->( GetArea() )
	Local cRetorno	:= ""

	//Retorna a descricao se nao for alteracao em lote
	If !IsInCallStack("JAltLote") .AND. !Empty(cSigla)

		RD0->( DbSetOrder(9) )		//RD0_FILIAL + RD0_SIGLA
		If RD0->( DbSeek( xFilial("RD0") + cSigla ) )
			cRetorno := RD0->RD0_NOME
		EndIf
	EndIf

	RestArea( aAreaRD0 )

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JUREXCRESTR
Faz a exclusão do cadastro de restrição

@param cTabela    - Tabela que terá o registro excluído da NVC
@param cCod       - Código do registro que será excluído da NVC

@author Andreia Lima
@since 04/02/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JUREXCRESTR(cTabela, cCod)
	Local lRet    := .T.
	Local cSQL    := ''
	Local aArea   := GetArea()
	Local cAlias  := GetNextAlias()
	Local aCodTab := {}
	Local nX      := 0

	cSQL := "SELECT NVC.NVC_COD, NVC.NVC_CTABEL FROM "+ RetSqlname('NVC') + " NVC "
	cSQL += " WHERE NVC.D_E_L_E_T_ = ' ' " +CRLF
	cSQL += "   AND NVC.NVC_FILIAL = '" + xFilial('NVC') + "'"
	cSQL += "   AND EXISTS (SELECT 1 FROM" + RetSqlname('NVB') + " NVB "
	cSQL += "                WHERE NVB.NVB_COD = NVC.NVC_CTABEL"
	cSQL += "                  AND NVB.D_E_L_E_T_ = ' ' " +CRLF
	cSQL += "                  AND NVB.NVB_TABELA = '" + cTabela+"' )"
	cSQL += "   AND NVC.NVC_VALOR = '" + cCod +"' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd(aCodTab, (cAlias)->NVC_CTABEL)
		DbSelectArea("NVC")
		NVC->(DbSetOrder(1))
		While NVC->(dbSeek(xFilial('NVC')+(cAlias)->NVC_COD))
			Reclock( "NVC", .F. )
			dbDelete()
			MsUnLock()
		End
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )


	For nX:= 1 to Len(aCodTab)

		cSQL := ''
		cSQL := "SELECT COUNT(NVC.NVC_COD) CONTADOR FROM "+ RetSqlname('NVC') + " NVC "
		cSQL += " WHERE NVC.NVC_CTABEL = '" + aCodTab[nX]+"' "
		cSQL += "   AND NVC.D_E_L_E_T_ = ' ' " +CRLF
		cSQL += "   AND NVC.NVC_FILIAL = '" + xFilial('NVC') + "'"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

		If (cAlias)->CONTADOR = 0
			DbSelectArea("NVB")
			NVB->(DbSetOrder(1))
			While NVB->(dbSeek(xFilial('NVB')+aCodTab[nX]))
				Reclock( "NVB", .F. )
				dbDelete()
				MsUnLock()
			End
		Endif

		(cAlias)->( dbcloseArea() )

	End

	aSize(aCodTab,0)

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataCbox
Função geral que retorna o valor de uma opção de combobox

@param cCampo  Nome do campo (Ex: NSZ_SITUAC)
        cValor  Opção selecionada no combo (Ex: 1)

@Return cValor   Valor referênte a opção selecionada (Ex: Em Andamento)

@author Jorge Luis Branco Martins Junior
@since 15/02/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JTrataCbox( cCampo, cValor )

	Local aArea   := GetArea()
	Local aX3CBox := {}
	Local nOpc    :=  Val(cValor)

	If nOpc > 0
		aX3CBox := Separa(GetSx3Cache(cCampo,'X3_CBOX'),";",.F.)

		If Len(aX3CBox) >= nOpc .OR. ("#" $ aX3CBox[1])
			If (At( "#",aX3CBox[1]) == 1)
				aX3CBox := Separa(&(AllTrim(SubStr(aX3CBox[1],2,Len(aX3CBox[1])))),";",.F.)
			EndIf
			cValor := AllTrim(SubStr(aX3CBox[nOpc],3,Len(aX3CBox[nOpc])))
		EndIf
	EndIf

	RestArea(aArea)

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GrpRestCFG
Verifica no configurador o grupo de acesso para restrição do SIGAJURI
via SIGACFG.

Antiga função JurGrpRest

Uso Geral.

@Return cGrupo Clientes
                 Correspondentes
                 Matriz

@author Jorge Luis Branco Martins Junior
@since 07/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrpRestCFG(cUser)
	Local aArea  := GetArea()
	Local aRet   := {}
	Local nCt    := 0
	Local cGrupo := ''
	Local lRest  := .F.

	Default cUser := __CUSERID

	If !Empty(cUser)

		aRet := FWSFUsrGrps(cUser)

		For nCt:= 1 to Len(aRet)
			cGrupo:= Upper(AllTrim(FWGetNameGrp(aRet[nCt])))
			If !Empty(cGrupo)
				If cGrupo $ 'CLIENTES|CORRESPONDENTES|MATRIZ'
					lRest := .T.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If !lRest
		cGrupo := ''
	EndIf

	RestArea(aArea)

Return cGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilRst( )
Função que retorna a query para filtro de restrição f3

@Return cQuery   Query para filtro de F3

@author Wellington Coelho
@since 26/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFilRst()
	Local lRet        := .F.
	Local aArea       := GetArea()
	Local cQuery      := ""
	Local aQuery      := {}
	Local lVisual     := .F.
	Local lExibeDados := .T.
	Local cTabela     := "NSZ"
	Local cTpAJ       := ""
	Local aPesq       := {{"NSZ","NSZ_COD"},{"NSZ","NSZ_CCLIEN"},{"NSZ","NSZ_LCLIEN"},{"SA1","A1_NOME"},{"NSZ","NSZ_NUMCAS"},;
		{"NVE","NVE_TITULO"},{"NSZ","NSZ_NUMPRO"},{"NSZ","NSZ_PATIVO"},{"NSZ","NSZ_PPASSI"}}

	cQuery := " SELECT NSZ.NSZ_COD, NSZ.NSZ_CCLIEN, NSZ.NSZ_LCLIEN, SA1.A1_NOME , NSZ.NSZ_NUMCAS ,
	cQuery += " NVE.NVE_TITULO, NSZ.NSZ_NUMPRO, NSZ.NSZ_PATIVO, NSZ.NSZ_PPASSI, NSZ.R_E_C_N_O_ NSZRECNO" "
	cQuery += "   FROM "+RetSqlName("NSZ")+" NSZ "
	cQuery += "   INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "   ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SA1.A1_COD = NSZ.NSZ_CCLIEN "
	cQuery += "   AND SA1.A1_LOJA = NSZ.NSZ_LCLIEN "
	cQuery += "   INNER JOIN " + RetSqlName("NVE") + " NVE "
	cQuery += "   ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQuery += "   AND NVE.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN "
	cQuery += "   AND NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN "
	cQuery += "   AND NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS "

	cQuery += " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NSZ.NSZ_FILIAL = '" + xFilial( "NSZ" ) + "'"

//Quando o usuário selecionou o assunto, caso a pesquisa selecionada na tela tenha mais de um assunto configurado
	If IsInCallStack( 'JURA162' ) .And. !Empty(cTipoAJ) .And. !lPesquisa
		cTpAJ  := "'" + cTipoAJ + "'"
		cQuery += "   AND NSZ_TIPOAS = " + cTpAJ
	Else
		//Verifica Tipos de assunto da pesquisa
		cTpAJ := AllTrim( JurSetTAS(.F.) )

		//Tratamento de aspas simples para a query
		cTpAJ := IIf(  Left(cTpAJ,1) == "'", "", "'" ) + cTpAJ
		cTpAJ += IIf( Right(cTpAJ,1) == "'", "", "'" )

		If cTpAJ == "'000'"
			lExibeDados := .F. // Indica que o browse não apresentará dados sem que tenha sido feita uma pesquisa, ou seja, abrirá em branco.
		Else
			cQuery += " AND NSZ_TIPOAS IN (" + cTpAJ + ")"
		EndIf
	EndIf

	aQuery := Ja162RstUs() //Verifica se existem restrições

//<- Adiciona a restrição de Acesso ->
	If !Empty(aQuery)
		cQuery += " AND ("+Ja162SQLRt(aQuery, , , , , , , , , cTpAJ)+")"
	EndIf

	cQuery += VerRestricao()  //Restricao de Escritorio e Area

	cQuery := ChangeQuery(cQuery, .F.)

	RestArea( aArea )

	nResult := JurF3SXB(cTabela,aPesq,,lVisual,.F.,,cQuery,lExibeDados)
	lRet    := nResult > 0

	If lRet
		DbSelectArea("NSZ")
		NSZ->( dbGoto( nResult ) )
	endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURESTFIL
Retorna a filial original após a utilização da JURSM0FIL

@author Roberto Vagner Gomes
@since 23/10/2013
@version MP11.8

@param aParFil, array, Alias gerado pela JURSM0FIL
@return lRetorno , Boolean, Realizou a restauracao da rotina
@obs
Formato do array como parametro de entrada
aRet[1] := "01SP01" //Filial utilizada
aRet[2] := "01MG01" //Backup do cFilAnt
aRet[3] := 001 //Bakup do Recno SM0

/*/
//-------------------------------------------------------------------
Function JURRESTFIL ( aParFil )
	Local lRetorno := .F.

	If Len(aParFil) == PARFILTAM

		If !Empty(aParFil[PARFILBKP])

			// Verifica a necessidade de alteração da filial
			If cFilAnt <> Subs(aParFil[PARFILBKP],1,FWSizeFilial())

				// Atualiza o campo de Filial
				cFilAnt := Subs(aParFil[PARFILBKP],1,FWSizeFilial())

				//Restaura o SM0 correto
				SM0->(DbGoTo(aParFil[PARFILREC]))

				SM0->(DbSetOrder(1))

				If SM0->(DbSeek(cEmpAnt+cFilAnt))
					If GetVersao(.F.) == "P10"
						oMsgItem3:SetText( Capital(AllTrim(FWGrpName(SM0->M0_CODIGO))) + " / " + Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) )
					Else
						// Versão 11 - Sem utilização do MDI
						If !FlatMode()
							AppSetMsgItem("EMPFIL", Capital(AllTrim(FWGrpName(SM0->M0_CODIGO))) + " / " + Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) )
						Else
							If !SetMDIChild(0)
								SetMDIBar(SPACE(2)+Capital(AllTrim(FWGrpName(SM0->M0_CODIGO))) + " / " + Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) + Chr(9) + oApp:oMsgItem2:cMsg + Chr(9) + oApp:oMsgItem1:cMsg)
								oApp:SetStatusBarText(GetMDIBar())
							Else
								__cMDIBar := " " + chr(9) + OemToAnsi(GetVersao()) + Chr(9) + cUserName + Chr(9) + Dtoc(dDataBase) + Chr(9) + Capital(AllTrim(FWGrpName(SM0->M0_CODIGO)))+ " / " +Capital(AllTrim(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1))) + chr(9)+"#fw_rodape_logo_siga"
								SetMDIBar(__cMDIBar)
								oApp:SetStatusBarText(__cMDIBar)
							EndIf
						Endif
					Endif
				Endif
				MsgRun("Aguarde.....",,{|| })
				lRetorno := .T.
			Endif
		Endif
	Endif

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JuRatCtb( )
Carrega informações do rateio da contabilidade utilizado no FINA050.

@param	 cTabela - Tabela que esta gerando o lançamento
@param	 cCodLan - Código da lançamento
@param	 cCajuri - Código do assunto jurídico
@param	 aCabSE2 - Campos que irão compor o titulo a pagar
@return  aRatCTB - Dados do rateio da CTJ
@author	 Rafael Tenorio da Costa
@since 	 22/11/16
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function JuRatCtb(cTabela, cCodLan, cCajuri, aCabSE2)

	Local aArea   := GetArea()
	Local aAux	  := {}
	Local aRatCTB 	 := {}
	Local nCampo  := 0
	Local cCampo  := ""
	Local cCodRateio   := ""

	//Ponto de entrada para definir o rateio da contabilização
	If ExistBlock("JURATCTB")
		aRatCTB := Execblock("JURATCTB", .F., .F., {cTabela, cCodLan, cCajuri, aCabSE2})

		If ValType(aRatCTB) <> "A"
			aRatCTB := {}
			JurMsgErro(STR0106, {"JURATCTB"})	//"Retorno incorreto do ponto de entrada #1, será desconsiderado."
		EndIf
	EndIf

	If Len(aRatCTB) == 0 .And. cTabela == "NT3" .And. !Empty(FwFldGet("NT3_CRATEI"))

		cCodRateio := FwFldGet("NT3_CRATEI")

		DbSelectArea("CTJ")
		CTJ->( DbSetOrder(1) )	//CTJ_FILIAL+CTJ_RATEIO+CTJ_SEQUEN
		If CTJ->( DbSeek(xFilial("CTJ") + cCodRateio) )

			While !CTJ->( Eof() ) .And. CTJ->CTJ_RATEIO == cCodRateio

				aAux := {}
				For nCampo:= 1 To FCount()

					cCampo := Field(nCampo)

					If cCampo $ "CTJ_DEBITO|CTJ_CREDIT|CTJ_PERCEN|CTJ_VALOR|CTJ_HIST|CTJ_CCD|CTJ_CCC|CTJ_ITEMD|CTJ_ITEMC|CTJ_CLVLDB|CTJ_CLVLCR"
						Aadd(aAux, {cCampo, FieldGet(nCampo)})
					EndIf
				Next nCampo

				Aadd(aRatCTB, aAux)
				CTJ->( DbSkip() )
			EndDo
		EndIf
	EndIf

	If Len(aRatCTB) == 0 .And. cTabela == "NT3" .And. FWAliasIndic("O11")

		DbSelectArea("O11")
		O11->(DbSetOrder(1)) // O11_FILIAL + O11_CAJURI
		If O11->( DbSeek( xFilial("O11") + cCajuri ) )

			aAux := {}
			aAdd(aAux, {"CTJ_CCD"   , NSZ->(NSZ_CCUSTO) })
			aAdd(aAux, {"CTJ_CLVLDB", O11->(O11_CLVLDB) })
			aAdd(aAux, {"CTJ_DEBITO", O11->(O11_DEBITO) })
			aAdd(aAux, {"CTJ_ITEMD" , O11->(O11_ITEMD)  })
			Aadd(aAux, {"CTJ_PERCEN", 100               })
			Aadd(aAux, {"CTJ_VALOR" , 0	                })

			Aadd(aRatCTB, aAux)
		EndIf
		O11->( DbCloseArea() )

	EndIf

	RestArea( aArea )

Return aRatCTB

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVerSCHtml(cTipo)
Versão do SmartClient HTML
@param cTipo - "C" ou Nulo Caracter / "N" Numérico
@author Marcelo Araujo Dente
@since 13/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVerSCHtml(cTipo)
	Local cBinInfo := ''
	Local cSCTp    := GetRemoteType(@cBinInfo)
	Local cBinVer  := ''
	Local xVer     := IIF(cTipo == "N", 0, "")
	Local nInicio  := 0
	Local nFim     := 0

	If cSCTp == 5
		nInicio := AT('-',cBinInfo)+1
		nFim    := RAT(' ',cBinInfo)-AT('-',cBinInfo)-1
		cBinVer := Substr(cBinInfo,nInicio,nFim)
		cBinVer := Substr(cBinVer,1, RAT(".",cBinVer)) + PADL(Substr(cBinVer,RAT(".",cBinVer)+1,Len(cBinVer) ),3,"0")
		If !Empty(cBinVer)
			xVer := StrTran(cBinVer, ".", "")

			If cTipo == "N"
				xVer := Val(xVer)
			EndIf
		EndIf
	EndIf

Return xVer

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGtExist(cTabela, cWhere)
Função utilizada para montar a condição de EXISTS.
Uso Geral.

@Param	cTabela    Nome da tabela.
@Param	cWhere     Condição referente a tabela.
@Param	cEntFilial Entidade para relacionar Filial.
@Return	cExists    Condição de EXISTS.
@Return	lExport    Indica se é exportação

@author Breno Gomes
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGtExist(cTabela, cWhere, cEntFilial, lExport)
	Local cExists   := ''
	Local cCondicao := ''
	Local cCampo    := '*'
	Local aEXPDOM   := {}
	Local aEXPCDOM  := {}
	Local nI        := 0
	Local cTabDom   := ""

	Default cEntFilial := ''
	Default lExport    := .F.

	If !Empty(cWhere)
		SX9->(dbsetorder(2))
		IF SX9->(DBSeek(SUBSTRING(cTabela,1,3)+'NSZ'))

			aEXPDOM  := STRToArray(SX9->X9_EXPDOM, '+')
			aEXPCDOM := STRToArray(SX9->X9_EXPCDOM, '+')
			IF LEN(aEXPDOM) == LEN(aEXPCDOM)
				For nI := 1 to LEN(aEXPDOM)
					If nI > 1
						cCondicao += " AND "
					Endif
					//Verifica se é exportação para pegar o apelido
					If lExport
						cTabDom  := AllTrim(JurGetDados('NQ0', 2 , xFilial('NQ0') + SX9->X9_DOM , 'NQ0_APELID'))//NQ0_FILIAL+NQ0_TABELA

						cCondicao += cTabDom + "." + aEXPDOM[nI] + " = " + aEXPCDOM[nI] + " "
					Else
						cCondicao += aEXPDOM[nI] + " = " + aEXPCDOM[nI] + " "
					EndIf

					cCampo := aEXPCDOM[nI]
				NEXT
			EndIF

			cExists := " AND EXISTS( SELECT " + cCampo + " FROM " + cTabela + " WHERE "
			cExists += cCondicao
			cExists += " AND " + cTabela + ".D_E_L_E_T_ = ' ' "

			If Empty(cEntFilial)
				cExists += " AND "+SUBSTRING(cTabela,1,3)+"_FILIAL = '"+xFilial(SUBSTRING(cTabela,1,3))+"'"
			else
				cExists += " AND "+SUBSTRING(cTabela,1,3)+"_FILIAL = "+cEntFilial
			EndIf

			cExists += cWhere + ' ) '
		Else
			cExists += cWhere
		EndIf

	EndIf

Return cExists

//-------------------------------------------------------------------
/*/{Protheus.doc} JMsgErrFlg(oXml)
Função utilizada para retornar a mensagem de erro quando é Gerado o objeto do Result Tag (FLUIG)
Uso Geral.

@Param  oXML Xml gerado com o objeto do result
@Return cMsg Mensagem com o erro especifico

@author Beatriz Gomes Alves
@since 08/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JMsgErrFlg(oXML)
	Local cMsg := ''
	If !Empty(oXML)
		If (ValType(oXml:_Result:_Item) != 'A')
			cMsg := oXml:_Result:_Item:_Value:Text
			If AT(" {",cMsg) > 0
				cMsg := STR0108 + CRLF + SUBSTR(cMsg,1, AT(" {",cMsg)) //"Problema para obter o XML de retorno do WS Fluig!"
			Else
				cMsg := STR0108 + CRLF + cMsg
			EndIf
		Else
			cMsg := STR0108
		EndIF
	Else
		cMsg := STR0108
	EndIF
Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} JTstSetPa(cTipoAssu, cParam, xValor)
Setar parametros da NZ6 para Automacao de Testes

@param 	cTipoAssu      	Código do Assunto Jurídico
@param 	cParam 	        Nome do parâmetro
@param 	xValor 	        valor do parâmetro
@Return lRet	 	.T./.F. As informações são válidas ou não

@author leandro.silva
@since 23/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JTstSetPa(cTipoAssu, cParam, xValor)

	Local lRet         := .F.
	Local aArea        := GetArea()
	Local aAreaSX6                 := SX6->( GetArea() )
	Local aAreaNZ6                := NZ6->( GetArea() )
	Local xValorOld := ""

	//Atualiza NZ6 (Tipo de assunto juridico X Parametros com o parametro criado na SX6
	DbSelectArea("SX6")
	SX6->( dbSetOrder(1) ) //X6_VAR

	If SX6->( dbSeek( xFilial("SX6") + cParam ) )       //recebe parametro
		If FWAliasInDic("NZ6")
			DbSelectArea("NZ6")
			NZ6->( dbSetOrder(1) )      //NZ6_FILIAL+NZ6_TIPOAS+NZ6_CPARAM

			If NZ6->( dbSeek( xFilial("NZ6") + cTipoAssu + cParam) )
				xValorOld := NZ6->NZ6_CONTEU           //grava conteudo anterior
				lRet := .T.

				Reclock('NZ6', .F.)
				NZ6->NZ6_CONTEU := xValor          //atualiza conteudo
				NZ6->( MsUnlock() )
			Endif
		Endif
	EndIf

	RestArea(aAreaNZ6)
	RestArea(aAreaSX6)
	RestArea(aArea)

Return {lRet, xValorOld}

//-------------------------------------------------------------------
/*/{Protheus.doc} JFlgUrl()
Retorna a URL a ser utilizada na Integração SIGAJURI x Fluig

@Return cUrl	 	URL de integração com o Fluig

@author nishizaka.cristiane/ lucivan.correia
@since 20/11/2018
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function JFlgUrl()

	Local cFlgUrl	:= SuperGetMV('MV_JFLGURL' ,,"")
	Local cEcmUrl	:= SuperGetMV('MV_ECMURL' ,,"")
	Local cUrl		:= ""

	If Empty(cFlgUrl)
		cUrl := cEcmUrl
	Else
		cUrl := cFlgUrl
	EndIf

Return cUrl

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryFilial()
Verifica compartilhamento de tabelas

@param 	cTabPai		Alias da tabela Pai
@param 	cTabFilha	Alias da tabela Filha
@param 	cApPai		Apelido da tabela Pai
@param 	cApFilha	Apelido da tabela Filha
@Return cRet	 	Retorna a condição do campo Filial de acordo
					com o compartilhamento das tabelas

@author nishizaka.cristiane / rebeca.asuncao
@since 09/01/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function JQryFilial(cTabPai, cTabFilha, cApPai, cApFilha)
Local cAcPai    := ''
Local cAcFilha  := ''
Local cRet      := ''
Local cFilPai   := ''
Local cFilFilha := ''
Local nTamPai   := 0
Local nTamFilha := 0
Local cTam      := ""

	cTabPai   := AllTrim(cTabPai)
	cTabFilha := AllTrim(cTabFilha)
	cApPai    := AllTrim(cApPai)
	cApFilha  := AllTrim(cApFilha)
	cFilPai   := cApPai + "." + PrefixoCpo(cTabPai) + "_FILIAL
	cFilFilha := cApFilha + "." + PrefixoCpo(cTabFilha) + "_FILIAL
	cAcFilha  := FWModeAccess(cTabFilha,1) + FWModeAccess(cTabFilha,2) + FWModeAccess(cTabFilha,3)
	cAcPai    := FWModeAccess(cTabPai,1) + FWModeAccess(cTabPai,2) + FWModeAccess(cTabPai,3)"

	nTamPai   := Len(Alltrim(xFilial(cTabPai)))
	nTamFilha := Len(Alltrim(xFilial(cTabFilha)))
	cTam       := cValToChar(If(nTamPai > nTamFilha, nTamFilha, nTamPai))
	
	If cAcPai == cAcFilha 
		cRet += cFilPai + " = " + cFilFilha + " "
	ElseIf 'CCC' $ cAcPai + '|' + cAcFilha
		cRet := " 1 = 1 "
	else
		cRet := "SUBSTRING(SUBSTRING(" + cFilPai + ",1," + cTam + ") || '"+Space(Val(cTam))+"',1," + cTam + ") "
		cRet += " = SUBSTRING(SUBSTRING(" + cFilFilha + ",1," + cTam + ") || '"+Space(Val(cTam))+"',1," + cTam + ") "
	EndIf

	cRet := ChangeQuery('SELECT 1 FROM X WHERE ' + cRet)

Return SubStr(cRet,23)

//-------------------------------------------------------------------
/*/{Protheus.doc} JConLogXML(cMsg, cTipOper)
Gera o Log de XML para o Fluig

@param 	cMsg		XML a ser gravado no Log
@param 	cTipOper	Tipo de operação. R = Recebimento; E = Envio

@Return Nil

@author Willian.Kazahaya
@since 11/12/2019
/*/
//-------------------------------------------------------------------
Function JConLogXML(cMsg, cTipOper)
	Local cMsgCompl := ""
	Local cProgName := Left(ProcName(2) + Space(10),10)
	Local lTraceAtv := GetSrvProfString("Trace","0") == "1"

	If cTipOper == "R"
		cMsgCompl := STR0114 //"Recebimento"
	Else
		cMsgCompl := STR0115 //"Envio"
	EndIf

	If lTraceAtv
		JurConOut("[" + Left(cMsgCompl + Space(11), 11)  + "] " + cMsg,,cProgName)
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} JXFTratVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Trata os tipos de campos e imprime os valores
 
Uso Geral.

@param cTabela Nome da tabela
@param cCpoTab Nome do campo na tabela
@param cCpoQry Nome do campo na query
@param cTipo   Tipo do campo
@param TMP     Alias aberto da query principal
@param SUB     Alias aberto da query do sub relatório que esta sendo impresso
@param lSub    Indica se é um sub relatório

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 15/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JXFTratVal(cTabela, cCpoTab, cCpoQry, cTipo, TMP, SUB, lSub)
Local cValor := ""
Local cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
Local lPicture := Iif(Empty(cPicture),.F.,.T.)

If lSub
	If cTipo == "D" // Tipo do campo
		TCSetField(SUB, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((SUB)->&(cCpoQry))) //Conteúdo a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((SUB)->&(cCpoQry))) // Esse seek é para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "O" // Lista de opções
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((SUB)->&(cCpoQry))) ) //Retorna o valor do campo
	ElseIf cTipo == "N"
		TcSetField(SUB, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		If lPicture
			cValor   := TRANSFORM((SUB)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conteúdo a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((SUB)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((SUB)->&(cCpoQry)))
	EndIf
Else 
	If cTipo == "D" // Tipo do campo
		TCSetField(TMP, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((TMP)->&(cCpoQry))) //Conteúdo a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((TMP)->&(cCpoQry))) // Esse seek é para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "O" // Lista de opções
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((TMP)->&(cCpoQry))) ) //Retorna o valor do campo
	ElseIf cTipo == "N"
		TcSetField(TMP, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		If lPicture
			cValor   := TRANSFORM((TMP)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conteúdo a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((TMP)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
	EndIf
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMetric(cParam, xValue)
Envia as métricas para o License server.

@param cType       - Tipo de Métrica
@param cSubRoutine - Subrotina da métrica
@param cIdMetric   - ID da Metrica a ser registada
@param xValue      - Valor da métrica
@param dDateSend   - Tempo de uso, em segundos -> setSumMetric responsável pelo default
@param nLapTime    - Data de envio -> setSumMetric responsável pelo default
@param cRotina     - Sobrescreve a rotina que está definindo a métrica -> setSumMetric responsável pelo default

@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMetric(cType,cSubRoutine, cIdMetric, xValue, dDateSend, nLapTime, cRotina)
Default cSubRoutine   := ""
Default cIdMetric     := ""
Default __cLibVersion := __FWLibVersion()

	If !Empty(cSubRoutine) .and. !Empty(cIdMetric) .and. __cLibVersion >= "20210517" 
		Do Case
			Case cType == "metric"
				FWCustomMetrics():setMetric(cSubRoutine, cIdMetric, xValue, dDateSend, nLapTime, cRotina)
			Case cType == "unique"
				FWCustomMetrics():setUniqueMetric(cSubRoutine, cIdMetric, xValue, dDateSend, nLapTime, cRotina)
			Case cType == "average"
				FWCustomMetrics():setAverageMetric(cSubRoutine, cIdMetric, xValue, dDateSend, nLapTime, cRotina)
			Case cType == "sum"
				FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, xValue, dDateSend, nLapTime, cRotina)
		End Case
		
	Endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValidNat( cNatu, cCampoNatu, cCampoWhen )
Valida se deve habilitar / bloquear os campos de detalhes de acordo
com o parâmetro MV_JDETDES

@Param  cNatu      - Código da natureza origem / destino selecionada
@Param  cCampoNatu - Campo da natureza de origem / destino
@Param  cCampoWhen - Valor no centro de custo jurídico na natureza
@Return lRet (.T. / .F.) - Permite alterar o campo?

@since 01/04/2022
/*/
//-------------------------------------------------------------------
Function JurValidNat( cNatu, cCampoNatu, cCampoWhen )

Local lRet       := .T.
Local cNatureza  := IIF( VALTYPE(cNatu) <> "U", cNatu, "" )
Local cClassNat  := ""

	If !Empty( cNatureza )
		cClassNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI")

		If Empty( cClassNat )
			lRet := SuperGetMV('MV_JDETDES', .T., '1') == '1'
		EndIf
	EndIf

	If lRet
		// Campos da natureza OHF
		If cCampoNatu == "OHF_CNATUR"
			lRet := JurWhNatCC(cCampoWhen, "OHFDETAIL", cCampoNatu, "OHF_CESCR","OHF_CCUSTO","OHF_SIGLA2","OHF_CRATEI",)
		EndIf

		// Campos da natureza OHG
		If cCampoNatu == "OHG_CNATUR"
			lRet := JurWhNatCC(cCampoWhen, "OHGDETAIL", cCampoNatu, "OHG_CESCR","OHG_CCUSTO","OHG_SIGLA2","OHG_CRATEI")
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRepDirSO( cDiretorio, cSO )
Função responsável ajustar o caminho da pasta olhando o SO

@param cDiretorio - Caminho do diretório
@param cSO        - Sistema operacional. Se vazio pega do SrvInfo

@since 21/07/2022
/*/
//-------------------------------------------------------------------
Function JRepDirSO( cDiretorio, cSO )

Default cSO := GetSrvInfo()[2]

	cDiretorio := IIF("Linux" == cSO, StrTran(cDiretorio,"\","/"), cDiretorio)
Return cDiretorio

//-------------------------------------------------------------------
/*/{Protheus.doc} JNomeArqSO( cNomeArq, cSO )
Responsável por tratar o nome de arquivos para gravação de relatórios,
desta forma remove acentuação e caracteres especiais e transforma 
todos os caracteres para minúsculo.

@param cSO      - Sistema operacional. Se vazio pega do SrvInfo
@param cNomeArq - Nome do arquivo

@since 26/09/2022
/*/
//-------------------------------------------------------------------
Function JNomeArqSO( cNomeArq, cSO )

Default cSO := GetSrvInfo()[2]

	cNomeArq := IIF( "Linux" == cSO, JurClearStr(LOWER( cNomeArq ), .T., .T., .F., .F., ""), cNomeArq )

Return cNomeArq
