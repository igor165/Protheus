#INCLUDE "JURA095_V.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095_V
Functions de validação de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA095_V()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef Functions de validação de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Functions de validação de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Functions de validação de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J95AltValH
Valida alterações nos campos de valor e data dos valores
atualizáveis para ajustar o histórico conforme necessário.

@param 	oModel   Modelo de dados
@param 	cTabela   Tabela que está sendo alterada

@author André Spirigoni Pinto
@since 21/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95AltValH(oModel, cTabela)
Local aArea     := GetArea()
Local aAreaNYZ  := NYZ->( GetArea() )
Local lData     := .F.
Local lForma    := .F.
Local lValor    := .F.
Local lAviso    := .F.
Local nI        := 0
Local aCampos   := J095NW8(cTabela) //1 - campo, 2 - data, 3 - historico, 4 forma, 5 - correção, 6 - juros

For nI := 1 to Len(aCampos)

	lData := .F.
	lValor := .F.

	If !lForma //Não precisa nem continuar no case caso a forma tenha sido alterada
		Do Case
			Case oModel:isFieldUpdated(aCampos[nI][4])
				lForma := .T.
			Case oModel:isFieldUpdated(aCampos[nI][1])
				lValor := .T.
			Case oModel:isFieldUpdated(aCampos[nI][2])
				lData  := .T.
		End Case
	Endif

	//caso a forma de correção tenha sido alterada o sistema deve recalcular tudo.
	If lForma
		dbSelectArea("NYZ")
		NYZ->(DBSetOrder(1))

		If NYZ->( dbSeek( xFilial('NYZ') + oModel:GetValue('NSZ_COD') ) )
			While !NYZ->(EOF()) .And. NYZ->NYZ_CAJURI ==  oModel:GetValue('NSZ_COD')
				Reclock( 'NYZ', .F. )
				NYZ->&(aCampos[nI][3]) := 0
				if !Empty(Replace(aCampos[nI][5],cTabela,"NYZ"))
					NYZ->&(Replace(aCampos[nI][5],cTabela,"NYZ")) := 0
				Endif
				if !Empty(Replace(aCampos[nI][6],cTabela,"NYZ"))
					NYZ->&(Replace(aCampos[nI][6],cTabela,"NYZ")) := 0
				Endif
				NYZ->NYZ_CFCORR := oModel:GetValue(aCampos[nI][4])
				MsUnlock()
				NYZ->( dbSkip() )
				lAviso := .T.
			End
		Endif
	//Caso a data seja alterada, a correção deve mudar a partir da mesma. Caso o valor tenha sido alterado.
	ElseIf lValor
		dbSelectArea("NYZ")
		NYZ->(DBSetOrder(1))

		If NYZ->( dbSeek( xFilial('NYZ') + oModel:GetValue('NSZ_COD') + AnoMes(oModel:GetValue(aCampos[nI][2])) ) )
			While !NYZ->(EOF()) .And. NYZ->NYZ_CAJURI ==  oModel:GetValue('NSZ_COD')
				Reclock( 'NYZ', .F. )
				NYZ->&(aCampos[nI][3]) := 0
				if !Empty(Replace(aCampos[nI][5],cTabela,"NYZ"))
					NYZ->&(Replace(aCampos[nI][5],cTabela,"NYZ")) := 0
				Endif
				if !Empty(Replace(aCampos[nI][6],cTabela,"NYZ"))
					NYZ->&(Replace(aCampos[nI][6],cTabela,"NYZ")) := 0
				Endif
				MsUnlock()
				NYZ->( dbSkip() )
				lAviso := .T.
			End
		Endif
	EndIf

Next

If lAviso
	ApMsgInfo(STR0001) //"Para atualizar os valores, execute a correção de valores."
Endif

RestArea(aAreaNYZ)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J95CPgador
Função para validar Cliente Somente Pagador na inclusão de Processos

Uso Geral. Campos de inicialização padrão

@Return lRet	   .T. ou .F.

@author Rafael Rezende Costa
@since 22/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95CPgador()
Local lRet 	:= .T.
Local oModel	:= FWModelActive()
Local aArea	:= GetArea()
Local cCliente := ''
Local cLoja := ''

	If oModel:GetID() == 'JURA095'
		cCliente := oModel:GetModel("NSZMASTER"):GetValue("NSZ_CCLIEN")
		cLoja	:= oModel:GetModel("NSZMASTER"):GetValue("NSZ_LCLIEN")

		If !(Empty(cCliente) .And. Empty(cLoja))
			dbSelectArea('NUH')
			NUH->( dbSetOrder(1) )
			IF NUH->( DbSeek(xFilial("NUH") + cCliente + RTrim( cLoja ) ) )
				If NUH->NUH_PERFIL == '2'
					lRet := .F.
					//"Atenção: Este Cliente possui perfil 'Somente Pagador' no cadastro de Clientes."+ CRLF+ "Não é possivel cadastrar um processo com este tipo de perfil de cliente."
					JurMsgErro( STR0002+ CRLF+ STR0003 )
				EndIF
			EndIF
		EndIf
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95VldCpo
Valida regras de campos que serão incluidos

@author Jorge Luis Branco Martins Junior
@since 19/05/2014
@version 1.0s
/*/
//-------------------------------------------------------------------
Function J95VldCpo(cCampo, cTabela, cProc )
Local cTipoAj := ''
Local lRet    := .T.

If Type("cTipoAsJ") == "U"
	cTipoAj := 'CFG'
Else
	cTipoAj := cTipoASJ
Endif

If cTipoAj != 'CFG' .And. cTipoAj > '050'
	cTipoAj := JurGetDados("NYB",1,XFILIAL("NYB")+cTipoAj, "NYB_CORIG")
EndIf

//Validação LIMINAR - Somente Contencioso e filhos
If cTipoAj != 'CFG' .And. cTabela == 'NSZ' .And. JURX3INFO( cCampo, 'X3_FOLDER' ) == '4' .And. cTipoAj <> '001'
	lRet := .F.
EndIf

If lRet .And. cTipoAj != 'CFG'
	lRet := JURCPO(cCampo, xFilial(cTabela), cProc, cTipoASJ)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095Relac
Validação dos Assuntos Juridicos acessíveis pelo usuário, independente
da pesquisa selecionada no momento
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Jorge Luis Branco Martins Junior
@since 30/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095Relac(cCod)
Local aArea 	:= GetArea()
Local cRet		:= GetNextAlias()
Local cSQL	 	:= ''
Local cTipo 	:= ''
Local cFiltro := ''

cSQL :="SELECT NVJ.NVJ_CASJUR CASJUR " + CRLF
cSQL +="FROM "+ RetSqlName("NVJ") + " NVJ , "+ CRLF
cSQL += RetSqlName("NVK")+" NVK " + CRLF
cSQL += "WHERE NVJ.NVJ_FILIAL = " + ValToSQL(xFilial("NVJ"))+ CRLF
cSQL +=   " AND NVK.NVK_FILIAL = " + ValToSQL(xFilial("NZY"))+ CRLF
cSQL +=   " AND NVK.NVK_CPESQ = NVJ.NVJ_CPESQ"               + CRLF
cSQL +=   " AND NVK.NVK_CUSER = " + ValToSQL(cCod)          + CRLF
cSQL +=   " AND NVK.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=   " AND NVJ.D_E_L_E_T_ = ' ' " + CRLF
cSQL +="UNION SELECT NVJ.NVJ_CASJUR CASJUR" + CRLF
cSQL +="FROM" + RetSqlName("NVJ")+ " NVJ ," + CRLF
cSQL += RetSqlName("NVK") + " NVK,"+ CRLF
cSQL += RetSqlName("NZY") + " NZY " + CRLF
cSQL += "WHERE NVJ.NVJ_FILIAL = " + ValToSQL(xFilial("NVJ")) + CRLF
cSQL +=   " AND NVK.NVK_FILIAL = " + ValToSQL(xFilial("NVK")) + CRLF
cSQL +=   " AND NZY.NZY_FILIAL = " + ValToSQL(xFilial("NZY")) + CRLF
cSQL +=   " AND NVK.NVK_CPESQ = NVJ.NVJ_CPESQ "
cSQL +=   " AND NVK.NVK_CGRUP = NZY_CGRUP "                    + CRLF
cSQL +=   " AND NZY.NZY_CUSER = "+ ValToSQL(cCod)           + CRLF
cSQL +=   " AND NVK.D_E_L_E_T_ = ' '" + CRLF
cSQL +=   " AND NVJ.D_E_L_E_T_ = ' '" + CRLF
cSQL +=   " AND NZY.D_E_L_E_T_ = ' '" + CRLF

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cRet,.T.,.T.)

  If !(cRet)->( EOF() )
 		While !(cRet)->( EOF() )
			cTipo += "'" + (cRet)->CASJUR + "',"
			(cRet)->( dbSkip() )
		End
  EndIf

  nTam := Len(AllTrim(cTipo))

	If nTam > 0
		cFiltro := SubStr(AllTrim(cTipo),1,nTam-1)
	EndIf

  (cRet)->( dbcloseArea() )
	RestArea( aArea )

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095CAut()
Função utilizada para verificar se o cliente possui abertura automática
de caso
Uso Geral.
@param  cUser Código do Usuário
@author Clóvis Teixeira
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095CAut()
Local aArea     := GetArea()
Local oModel    := Nil
Local cCliente  := ''
Local cLoja     := ''
Local lRet      := .T.

If !IsInCallStack("JURA063") //habilita o campo caso para o remanejamento

	If isPesquisa()		// Se a origem do chamado da função foi o fonte Jura162 ou a tela de pesquisa, resgata o valor da menoria, senão resgata por GetValue no MVC
		cCliente 	:= M->NSZ_CCLIEN
		cLoja		:= M->NSZ_LCLIEN
	Else
		oModel   := FWModelActive()
		If  oModel <> nil .AND. oModel:cID == 'JURA095'
			cCliente := oModel:GetValue("NSZMASTER","NSZ_CCLIEN")
			cLoja    := oModel:GetValue("NSZMASTER","NSZ_LCLIEN")
		EndIf
	EndIf

	If !Empty(cCliente) .And. !Empty(cLoja)
		lRet := !J95CasAut(cCliente,cLoja)
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95CasAut
Query para verificar se o Cliente é Caso Automático

@param cCliente - Código do Cliente
@param cLoja - Código da Loja
@Param cFilialNUH - Filial

@author Willian Yoshiaki Kazahaya
@since 06/06/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function J95CasAut(cCliente, cLoja, cFilialNUH)
Local lRet := .F.
Local cQuerySel := ""
Local cQueryFrm := ""
Local cQueryWhr := ""
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

Default cFilialNUH := xFilial("NUH")

	cQuerySel += " SELECT NUH_CASAUT "
	cQueryFrm += " FROM " + RetSqlName("NUH") + " NUH "
	cQueryWhr += " WHERE NUH_COD = '" + cCliente + "' "
	cQueryWhr +=   " AND NUH_LOJA = '" + cLoja + "' "
	cQueryWhr +=   " AND NUH_FILIAL = '" + cFilialNUH + "' "


	cQuery := ChangeQuery(cQuerySel + cQueryFrm + cQueryWhr)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )

	If (cAliasQry)->(!Eof())
		lRet := (cAliasQry)->NUH_CASAUT == "1"
	EndIf

	(cAliasQry)->(dbCloseArea())

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J95AcesBtn
Verifica se o form principal não esta em modo de inclusão
@author Clóvis Eduardo Teixeira
@since 22/03/13
@version 1.0

/*/
//-------------------------------------------------------------------
Function J95AcesBtn()
Local oModel := FWModelActive()
Local nOpc 	:= oModel:GetOperation()
Local lRet   := .T.

  If nOpc == 3
    lRet := .F.
    JurMsgErro(STR0004) //'Para acessar este cadastro é necessário salvar o registro atual.'
  Endif

Return lRet

//-------------------------------------------------------------------

/*/{Protheus.doc} J95CmpNUZ

Verifica se o campo passado como parametro existe e, se existir, se esta
configurado na tabela NUZ vinculados a ele.

@Return lRet	 	.T./.F. Se o campo existir para o codigo de assunto juridico
								enviado como parametro.
@sample

@author Rafael Rezende Costa
@since 08/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95CmpNUZ(cCampo,cTpAssJur)
Local aArea 	  := GetArea()
Local cQuery		:= ''
Local cAliasQry := nil
local lRet := .F.

Default cCampo := ''
Default cTpAssJur := ''

	If (cCampo <> '' .And. cTpAssJur <> '')

		cQuery := "SELECT NUZ_CAMPO,NUZ_CTAJUR "
		cQuery += " FROM "+RetSqlName("NUZ")+" NUZ"
		cQuery += " WHERE NUZ_FILIAL = '" + xFilial( "NUZ" ) + "'"
		cQuery += " AND NUZ_CAMPO  = '" + cCampo +"'"
		cQuery += " AND NUZ_CTAJUR  = '" + cTpAssJur +"'"
		cQuery += " AND NUZ.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )

		IiF( Empty( (cAliasQry)->(NUZ_CTAJUR) ), lRet:= .F., lRet:=.T. 	 )

	  (cAliasQry)->(dbCloseArea())
	EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VincOk
Preenchimento automatico do tipo de processo (principal ou incidente)
Uso no cadastro de Processos.
@return 	cRet   Descrição do tipo do processo
@author Juliana Iwayama Velho
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VincOk(cCajur)
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local lRet      := .T.

	BeginSql Alias cAliasQry
		SELECT NVO.NVO_CAJUR1, NVO.NVO_CAJUR2
		FROM %Table:NVO% NVO
		WHERE (NVO.NVO_CAJUR1 = %Exp:cCajur% OR NVO_CAJUR2 = %Exp:cCajur%)
		AND NVO.NVO_FILIAL  = %xFilial:NSZ%
		AND NVO.%notDEL%
	EndSql
	dbSelectArea(cAliasQry)

	If !(cAliasQry)->(EOF())
		JurMsgErro(STR0005)
		lRet := .F.
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095IncOk
Preenchimento automatico do tipo de processo (principal ou incidente)
Uso no cadastro de Processos.
@return 	cRet   Descrição do tipo do processo
@author Juliana Iwayama Velho
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095IncOk(cCajur)
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local lRet      := .T.

  BeginSql Alias cAliasQry
  	SELECT NSZ.NSZ_COD
  	  FROM %Table:NSZ% NSZ
     WHERE NSZ.NSZ_CPRORI = %Exp:cCajur%
	     AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
   		 AND NSZ.%notDEL%
	EndSql
	dbSelectArea(cAliasQry)

	If !(cAliasQry)->(EOF())
   	JurMsgErro(STR0005)
	  lRet := .F.
	Endif

(cAliasQry)->(dbCloseArea())

RestArea( aArea )

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} JA095EncInc(cCajur)
Função que verifica se o assunto jurídico possui incidentes vinculados,
caso tenha ele efetua o encerramento automatico dos incidentes.
Uso Geral.
@param cCajur - Código do Assunto Jurídico
@author Clóvis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//----------------------------------------------------------------------
Function JA095EncInc(cCajur)
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local lRet      := .T.

  	BeginSql Alias cAliasQry
		SELECT NSZ.NSZ_COD, NSZ.NSZ_SITUAC
				FROM %Table:NSZ% NSZ
			WHERE NSZ.NSZ_CPRORI = %Exp:cCajur%
				AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
				AND NSZ.%notDEL%
	EndSql
	dbSelectArea(cAliasQry)

	While !(cAliasQry)->( EOF())
		If (cAliasQry)->NSZ_SITUAC == '1' // Apenas se o processo estiver aberto
			If !(JA095UpdInc((cAliasQry)->NSZ_COD)) // Encerra o processo/incidente
				lRet := .F.
			EndIf
		EndIf
		If !(JA095EncInc((cAliasQry)->NSZ_COD)) // Verifica os incidentes (recursão)
			lRet := .F.
		EndIf
		(cAliasQry)->( dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	RestArea( aArea )

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} lIncdtTOK(cProcOrigem, cIncidente)
Função utilizada para não permitir que processo seja origem e incidentes
dentro da mesma familia de incidentes.
Uso Geral.
@author Clóvis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//-----------------------------------------------------------------------
Function lIncdtTOK(cProcOrigem, cIncidente)
Local aArea     := GetArea()
Local lRet      := .T.
Local cAliasQry := GetNextAlias()

 BeginSql Alias cAliasQry

   SELECT NSZ_FILIAL, NSZ.NSZ_COD, NSZ_FPRORI, NSZ.NSZ_CPRORI
     FROM %table:NSZ% NSZ
    WHERE NSZ.NSZ_COD    = %Exp:cProcOrigem%
      AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
      AND NSZ.%notDEL%

 EndSql
 dbSelectArea(cAliasQry)

 if !Empty((cAliasQry)->NSZ_CPRORI)
   lRet:= lIncdtTOK((cAliasQry)->NSZ_CPRORI, cIncidente)

 Elseif cIncidente == (cAliasQry)->NSZ_COD
   JurMsgErro(STR0006)
   lRet := .F.
 Endif

 (cAliasQry)->( dbCloseArea() )

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VLD
Validação dos campo de Grupo, Cliente e Caso
Verifica se o Cliente, Loja, Caso pertence ao grupo selecionado
@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Clóvis Eduardo Teixeira
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VLD()
Local oM     := FWModelActive()
Local lRet   := .T.
Local cGrupo := ''

if !Empty(oM:GetValue('NSZMASTER','NSZ_CGRCLI'))

  cGrupo := JurGetDados('SA1', 1, xFilial('SA1') + oM:GetValue('NSZMASTER','NSZ_CCLIEN') + oM:GetValue('NSZMASTER','NSZ_LCLIEN'), 'A1_GRPVEN')
  if cGrupo <> oM:GetValue('NSZMASTER','NSZ_CGRCLI')
	  JurMsgErro(STR0007)
	  lRet := .F.
	  Return lRet
  Endif

Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VENV
Valida os campos de valor envolvido
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VENV()
Local lRet      := .T.
Local aArea     := GetArea()

If (SuperGetMV('MV_JVLENOB',, '2') == '1' .And. FwFldGet('NSZ_VLINES') == '2')
	If Empty(FwFldGet('NSZ_DTENVO')) .Or. Empty(FwFldGet('NSZ_CMOENV')) .Or. Empty(FwFldGet('NSZ_VLENVO'))
		JurMsgErro(STR0008)
		lRet:= .F.
	Else
	  lRet := JurVinMoe(FwFldGet('NSZ_DTENVO'), FwFldGet('NSZ_CMOENV'))
	EndIf
ElseIf FwFldGet('NSZ_VLINES') == '2' 
	If !('E' $ Upper(SuperGetMV('MV_JVLZERO',, ''))) ; //Parâmetro bloqueia valor zero
		.And. (!Empty(FwFldGet('NSZ_DTENVO')) .Or. !Empty(FwFldGet('NSZ_CMOENV')) .Or. !Empty(FwFldGet('NSZ_VLENVO')));
		.And. !(!Empty(FwFldGet('NSZ_DTENVO')) .And. !Empty(FwFldGet('NSZ_CMOENV')) .And. !Empty(FwFldGet('NSZ_VLENVO')))

		JurMsgErro(STR0008)
		lRet:= .F.
	EndIf
	
	If lRet .And. !Empty(FwFldGet('NSZ_DTENVO')) .And. !Empty(FwFldGet('NSZ_CMOENV'))
		lRet := JurVinMoe(FwFldGet('NSZ_DTENVO'), FwFldGet('NSZ_CMOENV'))
	EndIf
EndIf

If lRet .And. !Empty(FwFldGet('NSZ_DTENVO'))
	lRet := JurVDtDist("NSZ_COD",'NSZ_DTENVO')
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VFIN
Validação o preenchimento dos campos de valor final (encerramento)
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VFIN()
Local lRet     := .T.
Local aArea    := GetArea()

If SuperGetMV('MV_JOBRENC',, '2') == '1'
	If Empty(FwFldGet('NSZ_DTENCE')) .Or. Empty(FwFldGet('NSZ_CMOFIN')) .Or.;
		Empty(FwFldGet('NSZ_VLFINA')) .Or. Empty(FwFldGet('NSZ_DETENC'))
		JurMsgErro(STR0014+RetTitle('NSZ_DTENCE')+', '+RetTitle('NSZ_CMOFIN')+', '+RetTitle('NSZ_VLFINA')+' e '+RetTitle('NSZ_DETENC'))
		lRet := .F.
	EndIf
Else
	If (!Empty(FwFldGet('NSZ_CMOFIN')) .Or. !Empty(FwFldGet('NSZ_VLFINA'))) .And.;
		!(!Empty(FwFldGet('NSZ_CMOFIN')) .And. !Empty(FwFldGet('NSZ_VLFINA')))
		JurMsgErro(STR0009)
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VHIS
Validação o preenchimento dos campos de valor histórico
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VHIS()
Local lRet     := .T.
Local aArea    := GetArea()

If (!Empty(FwFldGet('NSZ_DTHIST')) .Or. !Empty(FwFldGet('NSZ_CMOHIS')) .Or. !Empty(FwFldGet('NSZ_VLHIST'))) .And.;
	!(!Empty(FwFldGet('NSZ_DTHIST')) .And. !Empty(FwFldGet('NSZ_CMOHIS')) .And. !Empty(FwFldGet('NSZ_VLHIST')))

	JurMsgErro(STR0010)
	lRet:= .F.

Else
	lRet := JurVinMoe(FwFldGet('NSZ_DTHIST'), FwFldGet('NSZ_CMOHIS'))
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VALOR
Validação do preenchimento dos campos de valores (Moeda e Valor)
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Leandro Figueredo Chaves
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VALOR()
Local lRet := .T.
Local aArea    := GetArea()

If (!Empty(FwFldGet('NSZ_CMOEDA')) .Or. !Empty(FwFldGet('NSZ_VALOR'))) .And. !(!Empty(FwFldGet('NSZ_CMOEDA')) .And. !Empty(FwFldGet('NSZ_VALOR')))
	JurMsgErro(STR0011)
	lRet:= .F.
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VPRO
Validação do preenchimento dos campos de valor de provisão do processo
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Leandro Figueredo Chaves
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VPRO()
Local lRet     := .T.

If !('P' $ Upper(SuperGetMV('MV_JVLZERO',, ''))) ; //Parâmetro bloqueia valor zero
	.And. ( !Empty(FwFldGet('NSZ_DTPROV')) .Or. !Empty(FwFldGet('NSZ_CMOPRO')) .Or. !Empty(FwFldGet('NSZ_VLPROV'))) ;
	.And. !(!Empty(FwFldGet('NSZ_DTPROV')) .And. !Empty(FwFldGet('NSZ_CMOPRO')) .And. !Empty(FwFldGet('NSZ_VLPROV')))

	JurMsgErro(STR0012)
	lRet:= .F.

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VCAU
Validação o preenchimento dos campos de valor da causa
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VCAU()
Local lRet     := .T.

	If !('C' $ Upper(SuperGetMV('MV_JVLZERO',, ''))) ; //Parâmetro bloqueia valor zero
		.And. (!Empty(FwFldGet('NSZ_DTCAUS')) .Or. !Empty(FwFldGet('NSZ_CMOCAU')) .Or. !Empty(FwFldGet('NSZ_VLCAUS'))) ;  // Tem um preenchido
		.And. !(!Empty(FwFldGet('NSZ_DTCAUS')) .And. !Empty(FwFldGet('NSZ_CMOCAU')) .And. !Empty(FwFldGet('NSZ_VLCAUS'))) // Mas tem um vazio vazio

		JurMsgErro(STR0013)
		lRet:= .F.
	EndIf

	// Valida vigência da moeda
	If lRet .And. !Empty(FwFldGet('NSZ_DTCAUS')) .And. !Empty(FwFldGet('NSZ_CMOCAU'))
		lRet := JurVinMoe(FwFldGet('NSZ_DTCAUS'), FwFldGet('NSZ_CMOCAU'))
	EndIf

	// Valida datta menor que distribuição
	If lRet .And. !Empty(FwFldGet('NSZ_DTCAUS'))
		lRet := JurVDtDist("NSZ_COD",'NSZ_DTCAUS')
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU95VGAR
Validação o preenchimento dos campos de valor da garantia e obra do Grid Aditivo
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Reginaldo N Soares
@since 01/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU95VGAR(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local nI
Local oModelGrid := oModel:GetModel("NXYDETAIL")

If oModelGrid <> Nil
	For nI := 1 To oModelGrid:GetQtdLine()

		If (!Empty(FwFldGet('NXY_CMOGAR')) .Or. !Empty(FwFldGet('NXY_VLGARA'))) .And.;
			!(!Empty(FwFldGet('NXY_CMOGAR')) .And. !Empty(FwFldGet('NXY_VLGARA')))
			JurMsgErro("Preencha os Dados da Garantia")
			lRet:= .F.
			Exit
		EndIf

		If (!Empty(FwFldGet('NXY_CMOBRA')) .Or. !Empty(FwFldGet('NXY_VLOBRA'))) .And.;
			!(!Empty(FwFldGet('NXY_CMOBRA')) .And. !Empty(FwFldGet('NXY_VLOBRA')))
			JurMsgErro("Preencha os Dados da Obra")
			lRet:= .F.
			Exit
		EndIf
	Next
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95ENC()
Validação dos campos de encerramento, ao encerrar o processo
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Marcelo Araujo DEnte
@since 04/01/18
@version 2.0
/*/
//-------------------------------------------------------------------
Function JURA95ENC()
Local lRet  := .T.

If FwFldGet('NSZ_SITUAC') == '2'

// Validação de Campos de Encerramento e Validação de Rotinas no Encerramento
	lRet:= JA95ENCCMP() .And. JA95ENCROT()

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95DTEN
Validação da data de entrada a partir de parâmetro
Uso no cadastro de Processo.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 31/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95DTEN()
Local oModel:= FWModelActive()
Local nOpc  := oModel:GetOperation()
Local dData := Date() - SuperGetMV('MV_JDTENTR',, 0)
Local lRet  := .T.
Local aArea := GetArea()

If nOpc == 3 .Or. (nOpc == 4 .And. oModel:IsFieldUpdated('NSZMASTER','NSZ_DTENTR'))
	If FwFldGet('NSZ_DTENTR') < dData
		JurMsgErro(STR0019 + DTOC(dData))
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95LPRONYP
Pós-validação da linha dos dados do Acordo jurídico para registrar o usuário de alteração.
Uso no cadastro de Acordos.

@author Antonio Carlos Ferreira
@since 14/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95LPRONYP(oModelNYP, nLinha)

Local aSaveLines := nil

If  !( oModelNYP:IsInserted(nLinha) ) .And. oModelNYP:IsUpdated(nLinha)
     aSaveLines := FWSaveRows()

     oModelNYP:GoLine(nLinha)
	oModelNYP:SetValue("NYP_DATALT",DATE())                   //Atualiza a data de alteracao da linha da grid.
	oModelNYP:SetValue("NYP_USUAL" ,PswChave(__CUSERID))    //Atualiza o usuario de alteracao da linha da grid.

	FWRestRows( aSaveLines )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J95ACTVNYP
Pré-validação dos dados do Acordo para nao manipular os dados caso haja um registro como realizado.
Uso no cadastro de Acordos.

@author Antonio Carlos Ferreira
@since 11/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95ACTVNYP(oModel, lNYP)

Local nCt        := 0    //Contador para o for/next
Local nVz        := 0    //Vezes que encontrar o registro de acordo realizado, ja gravado na NYP e nao incluido agora na grid pelo usuario.

If  !( lNYP )
    Return .T.
EndIf

nVz := 0
For nCt := 1 To oModel:GetModel( "NYPDETAIL" ):GetQtdLine()

    If  (oModel:GetModel( "NYPDETAIL" ):GetValue("NYP_REALIZ", nCt) == "1")
	    nVz += 1  //Contar os Acordos realizados.
	EndIf
Next

If  (nVz > 0)
	oModel:GetModel( "NYPDETAIL" ):SetOnlyView( .T. )    //Somente visualizar a aba de Acordos
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VlDt2
Validação da Data de Assinatura do Aditivo, para que não seja
anterior à data de assinatura do contrato, e o período entre
Início e Término da Vigência.

@Return lRet	 	.T./.F. As informações são válidas ou não
@author Jorge Luis Branco Martins Junior
@since 05/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VlDt2(oModel)
Local aArea     := GetArea()
Local lRet      := .T.
Local oModelNXY := oModel:GetModel("NXYDETAIL")
Local nLine     := oModelNXY:nLine
Local nQtd      := oModelNXY:GetQtdLine()
Local nI        := 0
Local lDt       := !EMPTY(AllTrim(DToS(oModel:GetValue('NSZMASTER','NSZ_DTADIT'))))
Local cDTIni    := ""
Local cDTFim    := ""

For nI := 1 To nQtd
	oModelNXY:GoLine( nI )

	If lDt .And. !EMPTY(AllTrim(DToS(oModelNXY:GetValue('NXY_DTASSI'))))
		If oModel:GetValue('NSZMASTER','NSZ_DTADIT') > oModelNXY:GetValue('NXY_DTASSI')
			JurMsgErro(STR0018 + RetTitle('NXY_DTASSI') + STR0020 + RetTitle('NSZ_DTADIT') + STR0021 + oModelNXY:GetValue('NXY_COD') )
			lRet := .F.
			Exit
		Endif
	ElseIf lDt .And. EMPTY(AllTrim(DToS(oModelNXY:GetValue('NXY_DTASSI'))))
		JurMsgErro(STR0018 + RetTitle('NXY_DTASSI') + STR0022 + oModelNXY:GetValue('NXY_COD') + STR0023)
		lRet := .F.
		Exit
	ElseIf !lDt .And. !EMPTY(AllTrim(DToS(oModelNXY:GetValue('NXY_DTASSI'))))
		JurMsgErro(STR0024 + RetTitle('NSZ_DTADIT') + STR0025)
		lRet := .F.
		Exit
	EndIf

	If oModelNXY:HasField("NXY_DTINVI") .And. oModelNXY:HasField("NXY_DTTMVI")
		cDTIni	:= dTos(oModelNXY:GetValue('NXY_DTINVI'))
		cDTFim	:= dTos(oModelNXY:GetValue('NXY_DTTMVI'))

		If !Empty(Alltrim(cDTIni)) .And. !Empty(Alltrim(cDTFim))
			If cDTIni > cDTFim
				JurMsgErro(STR0033)//'Data inicial da vigência do aditivo não pode ser maior que a data final'
				lRet := .F.
			EndIf
		EndIf
	EndIf

Next

oModelNXY:GoLine( nLine )

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VlDt1
Validação de data, para que não seja maior que a atual

@param 	cDate  	Data a ser verificada
@param 	nPar  	nPar == 1 -> Data de Inicio da Vigencia - NSZ_DTINVI
                nPar == 2 -> Data de Fim da Vigencia    - NSZ_DTTMVI

@Return lRet	 	.T./.F. As informações são válidas ou não
@author Jorge Luis Branco Martins Junior
@since 05/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VlDt1()
Local aArea 	:= GetArea()
Local lRet 		:= .T.
Local cDTIni	:= dTos(M->NSZ_DTINVI)
Local cDTFim	:= dTos(M->NSZ_DTTMVI)

	If !Empty(Alltrim(cDTIni)) .And. !Empty(Alltrim(cDTFim))
  	If cDTIni > cDTFim
  		JurMsgErro(STR0026)//'Data inicial da vigência não pode ser maior que a data final'
			lRet := .F.
		EndIf
	EndIf

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095DTNXY
Validação da Data de Assinatura do Aditivo, para que não seja
anterior à data de assinatura do contrato, e o período entre
Início e Término da Vigência.

@Return lRet	 	.T./.F. As informações são válidas ou não
@author Jorge Luis Branco Martins Junior
@since 01/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095DTNXY(cDate)
Local aArea	:= GetArea()
Local lRet  := .T.

If !EMPTY(cDate)
	If !EMPTY(M->NSZ_DTADIT)
		If cDate < M->NSZ_DTADIT
			JurMsgErro(STR0027+RetTitle('NSZ_DTADIT'))//'Data não pode ser anterior à data de assinatura do contrato'
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95VUNI
Validação dos campos de unidade
Uso no cadastro de unidade

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 31/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95VUNI()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := FWModelActive()
Local oModelNYJ  := oModel:GetModel('NYJDETAIL')
Local nCt        := 0
Local nUnidade   := 0
Local nQtd       := 0

	For nCt := 1 To oModelNYJ:GetQtdLine()

		If oModelNYJ:GetValue('NYJ_UNIDAD', nCt) == '1' .And. !oModelNYJ:IsDeleted(nCt)
			nUnidade++
		EndIf
		//conta a quantidade de linhas não apagadas	 e valida o preenchimento da data de abertura/encerramento
		If !oModelNYJ:IsDeleted(nCt) .And. !oModelNYJ:IsEmpty(nCt)
			nQtd++

			//Validação de datas
			If !Empty(oModelNYJ:GetValue('NYJ_DTABER',nCt)) .And. !Empty(oModelNYJ:GetValue('NYJ_DTENCE',nCt))
				If oModelNYJ:GetValue('NYJ_DTENCE',nCt) < oModelNYJ:GetValue('NYJ_DTABER',nCt)
					JurMsgErro(STR0028) //"Verifique as datas de abertura/encerramento da aba Unidades."
					lRet:= .F.
				Endif
			Endif

		Endif
	Next


	If lRet .And. nQtd >=1 // o modelo pode estar vazio
		If nUnidade == 0 .Or. nUnidade > 1   //Verifica se a unidade não é atual ou se possui mais de uma
			JurMsgErro(STR0029) //"É necessário ter uma unidade matriz, verificar"
			lRet:= .F.
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095VLDNYJ
Validação dos campo de Grupo, Cliente para unidade
Verifica se o Cliente, Loja, pertence ao grupo selecionado

@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Rodrigo Guerato
@since 31/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095VLDNYJ()
Local oM     := FWModelActive()
Local lRet   := .T.
Local cGrupo := ''

if !Empty(oM:GetValue('NSZMASTER','NSZ_CGRCLI'))

  cGrupo := JurGetDados('SA1', 1, xFilial('SA1') + oM:GetValue('NYJDETAIL','NYJ_CCLIEN') + oM:GetValue('NYJDETAIL','NYJ_LCLIEN'), 'A1_GRPVEN')
  if cGrupo <> oM:GetValue('NSZMASTER','NSZ_CGRCLI')
	  JurMsgErro(STR0007)
	  lRet := .F.
	  Return lRet
  Endif

Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095VLDTSC

Valida os Campos de Tipo de Sociedade para o perfil societario

@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Rodrigo Guerato
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095VLDTSC()
	Local lRet	     := .T.
	Local oModel	 := FWModelActive()
	Local oMdlNSZ	 := oModel:GetModel("NSZMASTER")
	Local oMdlNYJ	 := oModel:GetModel("NYJDETAIL")
	Local aArea 	 := GetArea()
	Local aAreaNSZ := NSZ->( GetArea() )
	Local aAreaNYJ := NYJ->( GetArea() )
	Local nX		 := 0

	//Valida a NSZ
	If	Empty( oMdlNSZ:GetValue("NSZ_CTPSOC") )
		JurMsgErro(STR0030)
		lRet := .F.
	Endif

	If lRet
		For nX := 1 to oMdlNYJ:GetQtdLine()
			If !oMdlNYJ:IsDeleted( nX ) .And. !oMdlNYJ:IsEmpty( nX )
				If Empty( oMdlNYJ:GetValue("NYJ_CTPSOC", nX) )
					JurMsgErro(STR0030)
					lRet := .F.
					Exit
				Endif
			Endif
		Next nX
	Endif

	RestArea( aArea )
	NSZ->( RestArea( aAreaNSZ ) )
	NYJ->( RestArea( aAreaNYJ ) )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VCAPT
Validação o preenchimento dos campos de valor capital
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Juliana Iwayama Velho
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VCAPT()
Local lRet     := .T.
Local aArea    := GetArea()

If (!Empty(FwFldGet('NSZ_DTCAPI')) .Or. !Empty(FwFldGet('NSZ_CMOCAP')) .Or. !Empty(FwFldGet('NSZ_VLCAPI')) .Or. !Empty(FwFldGet('NSZ_VLACAO'))) .And.;
	!(!Empty(FwFldGet('NSZ_DTCAPI')) .And. !Empty(FwFldGet('NSZ_CMOCAP')) .And. !Empty(FwFldGet('NSZ_VLCAPI')) .And. !Empty(FwFldGet('NSZ_VLACAO')))
	JurMsgErro(STR0031)
	lRet:= .F.
Else
	lRet := JurVinMoe(FwFldGet('NSZ_DTCAPI'), FwFldGet('NSZ_CMOCAP'))
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095FCLMP()
Função utilizada para encontrar campos modificados definidos na NW8 ( JURA062 )
e seus respectivos campos a sejam limpos
Uso Geral.

@param 	cModel   	Modelo vigente da rotina.
@param 	cTabela   	Tabela que deve ser utilizada no filtro.

@Return .T. Se as verificações e alterações foram válidas
@author Marcelo Araujo Dente
@since 16/12/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095FCLMP(oModel, cTabela)
Local aArea     := GetArea()
Local lAviso    := .F.
Local nI        := 0
Local aCampos   := J095NW8(cTabela) //1 - campo, 2 - data, 3 - historico, 4 forma
Local lRet      := .F.
Local aNw8		:= {}
Local cJVlProv	:= JGetParTpa(cTipoAsJ, "MV_JVLPROV", "1")	//Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos

For nI := 1 to Len(aCampos)

	//Se o valor da Provisao vier dos Objetos não atualiza os campos do Processo Valor Provisão\Valor Envolvido
	If cTabela == "NSZ" .And. cJVlProv == "2" .And. AllTrim(aCampos[nI][8]) $ "NSZ_VAPROV|NSZ_VAENVO"
		Loop
	EndIf

	aNw8 := {}
	aAdd(aNw8,Iif(!Empty(aCampos[nI][1]),oModel:isFieldUpdated(aCampos[nI][1]),.F.))
	aAdd(aNw8,Iif(!Empty(aCampos[nI][2]),oModel:isFieldUpdated(aCampos[nI][2]),.F.))
	aAdd(aNw8,Iif(!Empty(aCampos[nI][4]),oModel:isFieldUpdated(aCampos[nI][4]),.F.))

	//NW8_CCAMPO	NW8_CDATA	 NW8_CFORMA
	If ANw8[1] .OR. ANw8[2]	.OR. ANw8[3]

		//NW8_CCORRM
	 	If !Empty(aCampos[nI][5])
			lVal := oModel:SetValue(aCampos[nI][5],0)
		Else
			lVal := .T.
		EndIf

		lRet := lRet .And. lVal

		//NW8_CJUROS
		If !Empty(aCampos[nI][6])
			lVal := oModel:SetValue(aCampos[nI][6],0)
		Else
			lVal := .T.
		EndIf

		lRet := lRet .And. lVal

		//NW8_MULATU
	    If !Empty(aCampos[nI][7])
			lVal := oModel:SetValue(aCampos[nI][7],0)
		Else
			lVal := .T.
		EndIf

		lRet := lRet .And.  lVal

		//NW8_CCMPAT
		If !Empty(aCampos[nI][8])
			lVal := oModel:SetValue(aCampos[nI][8],0)
		Else
			lVal := .T.
		EndIf

		lRet := lRet .And.  lVal
	EndIf

Next

If lAviso
	JurMsgErro(STR0032) //"Para atualizar os valores, execute a correção de valores."
Endif

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J95EXCVINC(cCajuri)
Função  para exclui vinculos de incidentes e relacionados

@param 	cCajuri   codigo do assunto juridico

@author Wellington Coelho
@since 26/10/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95EXCVINC(cCajuri)
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()

//Verifica NVO Vinculados
DbSelectArea("NVO")
//NVO->( dbSetOrder(1))
NVO->( dbGoTop())
While !NVO->(Eof())
	If (xFilial("NVO") == xFilial("NSZ")) .AND. NVO->NVO_CAJUR1 == Alltrim(cCajuri) .OR. NVO->NVO_CAJUR2 == Alltrim(cCajuri)

		RecLock( "NVO",.F. )
		DBDelete()
		NVO->( MsUnlock() )

	EndIf
	NVO->(dbSkip())
EndDo

//Verifica Incidentes

BeginSql Alias cAliasQry
	SELECT NSZ.NSZ_COD
	FROM %Table:NSZ% NSZ
	WHERE NSZ.NSZ_CPRORI = %Exp:cCajuri%
	AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
	AND NSZ.%notDEL%
EndSql

dbSelectArea(cAliasQry)

DbSelectArea("NSZ")
NSZ->( dbSetOrder(1))

while !(cAliasQry)->(EOF())

	If NSZ->( dbSeek(xFilial("NSZ") + (cAliasQry)->NSZ_COD ) )
		RecLock( "NSZ",.F. )
		NSZ->NSZ_CPRORI := ""
		NSZ->( MsUnlock() )
	Endif

	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea( aArea )

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} JA95BLQEMB(oModel)
Justificativa de Alteração de Valor Envolvido ou
@param oModel Modelo de Dados ativo no momento do envio de informações
@return lRet .T./.F. As informações são válidas ou não
@author  Clóvis Eduardo Teixeira
@since   28/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95BLQEMB(oModel)
Local aArea     := GetArea()
Local lRet      := .T.
Local lJustif   := .F.
Local cOTpProg  := JurGetDados("NQ7", 1, xFilial("NQ7") + NSZ->NSZ_CPROGN, "NQ7_TIPO")
Local cNtpProg  := JurGetDados("NQ7", 1, xFilial("NQ7") + oModel:GetValue("NSZMASTER","NSZ_CPROGN"), "NQ7_TIPO")
Local lSldJuizo := JA95lSld(oModel:GetValue("NSZMASTER","NSZ_COD"))

	If lSldJuizo
		If oModel:IsFieldUpdate("NSZMASTER",'NSZ_VLENVO') //.And. lEmbargo
			If cOTpProg == '1'
				If  !isBlind()
					If ApMsgYesNo(STR0035) //"O valor envolvido do processo foi alterado, para confirmar esta alteração é necessário incluir justificativa, deseja prosseguir?"
						//0 Se o usuário finalizar a operação com o botão confirmar;
						//1 Se o usuário finalizar a operação com o botão cancelar;

						oModelNUV := FWLoadModel("JURA166")
						oModelNUV:SetOperation(3)
						oModelNUV:Activate()

	 					If oModelNUV:GetModel("NUVMASTER"):HasField("NUV_CLMTAL")
							oModelNUV:LoadValue("NUVMASTER", "NUV_CLMTAL", "2")
						EndIf

						lRet := (FWExecView(STR0034,"JURA166",3,,{|| .T.}, ,,,,,,oModelNUV ) == 0)

						oModelNUV:DeActivate()
						oModelNUV:Destroy()

						FWModelActive(oModel)

						lJustif := .T.
					Else
						lRet := .F.
					EndIf
				Else
					lRet := JA95lAutom(oModel)//automação
				Endif
			Endif
		Elseif oModel:IsFieldUpdate("NSZMASTER",'NSZ_CPROGN') .And. !lJustif //.And. lEmbargo
			If cOTpProg == '1' .And. cNtpProg <> '1'
				If !isBlind()
					If ApMsgYesNo(STR0036) //"O prognostico do processo esta sendo alterado, para confirmar esta alteração é necessário incluir justificativa, deseja prosseguir?"
						//0 Se o usuário finalizar a operação com o botão confirmar;
						//1 Se o usuário finalizar a operação com o botão cancelar;

						oModelNUV := FWLoadModel("JURA166")
						oModelNUV:SetOperation(3)
						oModelNUV:Activate()

	 					If oModelNUV:GetModel("NUVMASTER"):HasField("NUV_CLMTAL")
							oModelNUV:LoadValue("NUVMASTER", "NUV_CLMTAL", "2")
						EndIf

						lRet := (FWExecView(STR0034,"JURA166",3,,{|| .T.}, ,,,,,,oModelNUV ) == 0)

						oModelNUV:DeActivate()
						oModelNUV:Destroy()

						FWModelActive(oModel)
					else
						lRet := .F.
					Endif
				Else
					lRet := JA95lAutom(oModel)
				Endif
			Endif
		Endif

		if !lRet .AND. !isBlind()
			JurMsgErro(STR0037) //"As alterações não foram salvas"
		Endif
	Endif

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95ENCCMP()
Validação de campos relacionados aos dados de encerramento de processo NSZ

@return lRet .T./.F. As informações são válidas ou não
@author  Marcelo Araujo Dente
@since   04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95ENCCMP()
Local lRet := .T.
Local oModel:= FWModelActive()
Local nOpc  := oModel:GetOperation()
Local dData := Date() - SuperGetMV('MV_JDTENCE',, 0)
Local aArea := GetArea()

	If Empty(FwFldGet('NSZ_CMOENC'))
		JurMsgErro(STR0014 + RetTitle("NSZ_CMOENC"))
		lRet:= .F.
	EndIf

	If lRet .And. !(c162TipoAs $ "005")
		lRet:= JURA95VFIN()
	EndIf

	If lRet .And. nOpc == 4
		If oModel:IsFieldUpdated('NSZMASTER','NSZ_DTENCE')
			If FwFldGet('NSZ_DTENCE') < dData
				JurMsgErro(STR0015 + DTOC(dData))
				lRet := .F.
			ElseIf FwFldGet('NSZ_DTENCE') > Date()
				JurMsgErro(STR0016)
				lRet := .F.
			EndIf
		Else
			If Empty(FwFldGet('NSZ_DTENCE')) // Ao alterar um processo encerrado o sistema exibia a mensagem mesmo com o campo NSZ_DTENCE preenchido
				JurMsgErro(STR0038, STR0039,STR0040)
				lRet := .F.
			Endif
		EndIf
	EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95ENCROT()
Validação de rotinas relacionadas aos dados de encerramento

@return lRet .T./.F. As informações são válidas ou não
@author  Marcelo Araujo Dente
@since   04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95ENCROT()
Local lRet   := .T.

lRet:= JA95ENCGAR()

If lRet
	lRet:=JA95ENCFLW()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95ENCGAR()
Validação de Saldo de Garantias no Encerramento do assunto jurídico

@return lRet .T./.F. As informações são válidas ou não
@author  Marcelo Araujo Dente
@since   05/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95ENCGAR()
Local aSaldo := {}
Local nRet   := 0
Local nI     := 1
Local lRet   := .T.
If lRet .And. SuperGetMV('MV_JLEVGAR',,'2') == '1' //Verifica se Processo pode ser encerrado, desde que o Saldo em Juízo das garantias deste esteja Zerado
	aSaldo := JA098CriaS(FwfldGet('NSZ_COD'))
	nRet   := 0
	If Len(aSaldo) > 0
	    For nI:= 1 to Len(aSaldo)
	    	If aSaldo[nI][4] == 'TT'
		    	nRet := nRet + Round(aSaldo[nI][5],2)
		    	If nRet > 0
	    			JurMsgErro(STR0017)//'Verificar o valor em juízo antes de encerrar este processo.'
	    			lRet := .F.
	    			Exit
	    		EndIf
		    EndIf
	    Next
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95ENCFLW()
Validação de Follow-ups em aberto/pendente/em aprovação no encerramento no Encerramento do assunto jurídico

@return lRet .T./.F. As informações são válidas ou não
@author  Marcelo Araujo Dente
@since   05/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95ENCFLW()
Local lRet   := .T.
Local cSQL   := ''
Local cRet   := GetNextAlias()
If SuperGetMV('MV_JENCFLW',, '2') == '1'
	cSQL := "SELECT COUNT(NTA.NTA_COD) QTD_FOLLOWUPS "     +  CRLF
	cSQL += "FROM " + RetSQLName('NTA') +" NTA "    +  CRLF
	cSQL += "WHERE NTA.NTA_CRESUL IN (SELECT NQN_COD FROM " + RetSQLName("NQN") + " NQN WHERE (NQN.NQN_TIPO <> '2' AND NQN.NQN_TIPO <> '3') AND NQN.D_E_L_E_T_ = ' ' AND NQN.NQN_FILIAL = '" + xFilial("NQN") + "')" + CRLF
	cSQL += "   AND NTA.NTA_FILIAL = '" + xFilial("NTA") + "'"
	cSQL += "   AND NTA.NTA_CAJURI = '" + FwfldGet("NSZ_COD") + "'"
	cSQL += "   AND NTA.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cRet,.T.,.F.)

	If (cRet)->QTD_FOLLOWUPS <> 0

		//Se não for aprovação de follow-up pelo fluig
		If !( (cRet)->QTD_FOLLOWUPS == 1 .And. IsInCallStack("JA106ConfNZK") )
			JurMsgErro(cValToChar((cRet)->QTD_FOLLOWUPS) + " - " + STR0042, STR0041,STR0043)
			lRet:=.F.
		EndIf
	EndIf

	(cRet)->( dbcloseArea() )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95lSld(CAssJur)
Verifica se existe saldo me juizo para o Cajuri informado
@param cCajuri - Código do assunto jurídico
@return lRet .T./.F. As informações são válidas ou não
@author  Clóvis Eduardo Teixeira
@since   28/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA95lSld(cCajuri)
Local aArea  := GetArea()
Local aSaldo := {}
Local lRet   := .F.
Local nI

	aSaldo := JA098CriaS(cCajuri)

	For nI:= 1 to Len(aSaldo)

		If Ascan(aSaldo, {|x| x[4] == 'TTSA' .And. x[5] > 0}) > 0
			lRet := .T.
			Exit
		EndIf
	Next

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95lAutom(oModel)
Função que seta as informações necessárias pra incluir uma justificativa - utilizada na automação
@param   oModel - modelo ativo
@return  lRet .T./.F. As informações são válidas ou não
@author  Beatriz Gomes
@since   09/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA95lAutom(oModel)
Local lRet      := .F.
Local cMotiv    := '0002'
Local cDescJust := oModel:GetValue("NSZMASTER","NSZ_DETALH")
Local oModelNew := FWLoadModel("JURA166")

	oModelNew:SetOperation(MODEL_OPERATION_INSERT)
	oModelNew:Activate()

	oModelNew:SetValue('NUVMASTER','NUV_CMOTIV',cMotiv)
	oModelNew:SetValue('NUVMASTER','NUV_JUSTIF',cDescJust)

	If oModelNew:VldData()
		lRet := oModelNew:CommitData()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95ZerPro
Zera a provisão quando o processo é encerrado

@param 	 oModel Modelo de dados

@author  Rafael Tenorio da Costa
@since   30/01/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA95ZerPro(oModel095)

	Local aArea  	:= GetArea()
	Local aAreaNSY 	:= NSY->( GetArea() )
	Local cLocProv	:= JGetParTpa(cTipoAsj, "MV_JVLPROV", "1")
	Local lRet		:= .T.
	Local cCajuri   := oModel095:GetValue("NSZMASTER", "NSZ_COD")
	Local oModel270 := NIL
	Local oModel094 := NIL
	Local oModelO0W := NIL
	Local aErro		:= {}
	Local lZeraProc	:= SuperGetMv("MV_JZERPRO", , .T.)
	Local nI        := 0
	Local lGrava270 := .F.

	//Zera valor do processo e objetos no encerramento do processo
	If lZeraProc
		If cLocProv == "2"
			//*********************************************************************************************************************
			// Zera Provisão pedidos O0W
			//*********************************************************************************************************************
			If FWAliasInDic("O0W") .And. NSZ->( DbSeek(xFilial('NSZ') + cCajuri) )
 				oModel270 := FWLoadModel('JURA270') 
				oModel270:SetOperation(MODEL_OPERATION_UPDATE)
				oModel270:Activate()
				oModelO0W  := oModel270:GetModel("O0WDETAIL")	

				// Pega a linha da O0W que foi alterada para a atualização de valores
				for nI := 1 to oModelO0W:Length(.T.)
					If oModelO0W:GetValue("O0W_VPROVA",nI) > 0 .or. oModelO0W:GetValue("O0W_VPOSSI",nI) > 0
						oModelO0W:GoLine(nI)
						lGrava270 := .T.

						//provável
						If  oModelO0W:GetValue("O0W_VPROVA",nI) > 0
							oModelO0W:SetValue("O0W_VINCON",oModelO0W:GetValue("O0W_VPROVA") + oModelO0W:GetValue("O0W_VINCON"))
							oModelO0W:SetValue("O0W_VPROVA",0)
						Endif
						//possível
						If  oModelO0W:GetValue("O0W_VPOSSI",nI) > 0
							oModelO0W:SetValue("O0W_VREMOT",oModelO0W:GetValue("O0W_VPOSSI") + oModelO0W:GetValue("O0W_VREMOT"))			
						Endif		
					EndIf
				next nI

				If lGrava270
					lRet := oModel270:VldData()
				If lRet
					lRet := oModel270:CommitData()
				EndIf
				If !lRet
					JurMsgErro(oModel270:aErrorMessage[6],"Atualização de Pedidos",oModel270:aErrorMessage[7])
				EndIf
            EndIf
		EndIf
			//*********************************************************************************************************************
			// Zera Provisão Objetos
			//*********************************************************************************************************************
			DbSelectArea("NSY")
			NSY->( DbSetOrder(1) )
			If NSY->( DbSeek(xFilial('NSY') + cCajuri) )

				//Carrega o modelo uma unica vez
				oModel094 := FWLoadModel('JURA094')

				While !NSY->( Eof() ) .And. NSY->NSY_FILIAL == xFilial('NSY') .And. NSY->NSY_CAJURI == cCajuri .AND. EMPTY(NSY->NSY_CVERBA)

					oModel094:SetOperation(MODEL_OPERATION_UPDATE)
					oModel094:Activate()

					oModel094:ClearField("NSYMASTER", "NSY_CPROG" )
					oModel094:ClearField("NSYMASTER", "NSY_DTJURC")
					oModel094:SetValue("NSYMASTER"	, "NSY_INECON", "2")	//Valor inestimável 2=Não para liberar a alteração dos campos abaixo
					oModel094:ClearField("NSYMASTER", "NSY_CMOCON")
					oModel094:ClearField("NSYMASTER", "NSY_VLCONT")

					If oModel094:GetModel("NSYMASTER"):HasField("NSY_VLREDU")
						oModel094:ClearField("NSYMASTER", "NSY_VLREDU")
					EndIf

					If !oModel094:VldData() .Or. !oModel094:CommitData()
						lRet  := .F.
						aErro := oModel094:GetErrorMessage()
					EndIf

					oModel094:DeActivate()

					If !lRet
						Exit
					EndIf

					NSY->( DbSkip() )
				EndDo

				oModel094:Destroy()

				FWModelActive(oModel095)
				oModel095:Activate()

				//Seta erro no modelo atual para retornar mensagem para a tela
				If !lRet .And. Len(aErro) > 0
					oModel095:SetErrorMessage(aErro[1]			 	  , aErro[2], aErro[3], aErro[4] 	, aErro[5],;
				    STR0044 + CRLF + aErro[6], aErro[7], /*xValue*/ , /*xOldValue*/ )	//"Erro ao zerar a contingência dos objetos"
				EndIf
			EndIf
		EndIf

		//*********************************************************************************************************************
		// Zera Provisão Processo
		//*********************************************************************************************************************
		If lRet
			oModel095:ClearField("NSZMASTER", "NSZ_DTPROV")
			oModel095:ClearField("NSZMASTER", "NSZ_CMOPRO")
			oModel095:ClearField("NSZMASTER", "NSZ_VLPROV")
			oModel095:ClearField("NSZMASTER", "NSZ_VAPROV")
			oModel095:ClearField("NSZMASTER", "NSZ_CPROGN")

			If oModel095:GetModel("NSZMASTER"):HasField("NSZ_VRDPRO")
				oModel095:ClearField("NSZMASTER", "NSZ_VRDPRO")
			EndIf

			If oModel095:GetModel("NSZMASTER"):HasField("NSZ_VRDPOS")
				oModel095:ClearField("NSZMASTER", "NSZ_VRDPOS")
			EndIf

			If oModel095:GetModel("NSZMASTER"):HasField("NSZ_VRDREM")
				oModel095:ClearField("NSZMASTER", "NSZ_VRDREM")
			EndIf
		EndIf
	EndIf

	RestArea(aAreaNSY)
	RestArea(aArea)

Return lRet
