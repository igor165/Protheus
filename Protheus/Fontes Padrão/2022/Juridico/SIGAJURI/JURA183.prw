#INCLUDE "JURA183.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA183
  Instancias de processos

@author Wellington Coelho
@since 24//11/14
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA183()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef Instancias de processos


@author Wellington Coelho
@since 24//11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Instancias de processos

@author Wellington Coelho
@since 24//11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Assuntos Juridicos

@author Wellington Coelho
@since 24//11/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NUQ", { |x| ALLTRIM(x) $ 'NUQ_FILIAL, NUQ_CAJURI, NUQ_COD, NUQ_INSATU,  NUQ_INSTAN, NUQ_CCORRE , NUQ_LCORRE, NUQ_DCORRE' } )

	oModel:= MPFormModel():New( "JURA183" )
	oModel:AddFields( "NUQ_DETAIL", NIL, oStruct )

Return oModel

//-------------------------------------------------------------------

/*/{Protheus.doc} JUR183L4OK
Valida se o campo de Localiza��o de 4. Nivel est� vinculado ao de
Localiza��o de 3. Nivel
Uso no cadastro de Inst�ncia.

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@sample

@author Rafael Rezende Costa
@since 08/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183L4OK()
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaNY3 := NY3->( GetArea() )
	Local oModel   := FWModelActive() 			//Retorna o modelo de dados que esteja ativa no momento
	Local cLoc3N   := oModel:GetValue("NUQDETAIL","NUQ_CLOC3N")
	Local cLoc4N   := oModel:GetValue("NUQDETAIL","NUQ_CLOC4N")

	If !Empty(cLoc4N)

		NY3->( dbSetOrder( 1 ) )	// Chave Indice: NY3_FILIAL + NY3_COD

		If NY3->( dbSeek( xFilial( 'NY3' ) + cLoc4N ) ) = .t.

			While !NY3->( EOF() ) .AND. ( NY3->NY3_FILIAL + NY3->NY3_COD ) == ( xFilial( 'NY3' ) + cLoc4N )
				If cLoc3N == NY3->NY3_CLOC3N
					lRet := .T.
				Endif

				NY3->( dbSkip() )
			End
		Else
			lRet := .F.
		EndIf

		If !lRet
			JurMsgErro(STR0008 + RetTitle("NUQ_CLOC4N")) //"Campo invalido "
			lRet := .F.
		EndIf

	EndIf


	RestArea( aAreaNY3 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------

/*/{Protheus.doc} JU183CORR()
Verifica se h� Contrato de Correspondente Ativo

@Return lRet
@author Tiago Martins
@since 20/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JU183CORR()
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local cQuery  := ''
	Local cAlias  := GetNextAlias()

	cQuery	:= "SELECT NSU.NSU_FIMVGN DtFimVig, NSU.NSU_DCAREN DtCaren"
	cQuery	+= "  FROM "+RetSqlName("NSU")+" NSU"
	cQuery	+= " WHERE NSU.NSU_FILIAL = '"+ FwxFilial("NSU",cFilAnt) +"'"
	cQuery	+= "   AND NSU.NSU_CFORNE = '"+ FwFldGet('NUQ_CCORRE') +"'"
	cQuery	+= "   AND NSU.NSU_INSTAN = '"+ FwFldGet('NUQ_INSTAN') +"'"
	cQuery	+= "   AND NSU.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If Empty((cAlias)->DtFimVig) .Or. dTos(Date()) < (cAlias)->DtFimVig .Or. dTos(Date()) < (cAlias)->DtCaren
			lRet := .F.
			JurMsgErro(STR0009)//"H� Contrato de Correspondente em vig�ncia para a inst�ncia deletada."

			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	(cAlias)->(dbCloseArea())
	RestArea (aArea)

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183CORRES
Fun��o que valida a data de distribui��o do prcesso para que n�o
seja futura.
@return lRet
@author Cl�vis Eduardo Teixeira
@since 06/08/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J183CORRES(oModelGrid, nIndex)
	Local cAlias       := ""
	Local oModel       := FWModelActive()
	Local lRet         := .T.
	Local cNUQCod      := oModelGrid:GetValue('NUQ_COD', nIndex)
	Local nRet         := 1
	Local aArea        := GetArea()
	Local aShow        := {{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil}}
	Local oM93         := Nil
	Local nOper        := MODEL_OPERATION_INSERT
	Local lRestExecute := JModRst() // Valida se � TOTVS Legal

	Private c095Cajuri := oModel:GetValue('NSZMASTER','NSZ_COD')
	Private c095NumPro := oModelGrid:GetValue('NUQ_NUMPRO', nIndex)
	Private c095Instan := oModelGrid:GetValue('NUQ_INSTAN', nIndex)
	Private c095cCor   := oModelGrid:GetValue('NUQ_CCORRE', nIndex)
	Private c095lCor   := oModelGrid:GetValue('NUQ_LCORRE', nIndex)
	Private c095dCor   := ''
	Private d095Data   := Date()

	If lRestExecute
		lRet := .T.
	Else
		cAlias := GetNextAlias()

		BeginSql Alias cAlias
			SELECT NUQ_CCORRE, NUQ_LCORRE
			FROM %Table:NUQ% NUQ
			WHERE NUQ.NUQ_CAJURI  = %Exp:c095Cajuri%
				AND NUQ.NUQ_COD     = %Exp:cNUQCod%
				AND NUQ.NUQ_FILIAL  = %xFilial:NUQ%
				AND NUQ.NUQ_CCORRE <> ' '
				AND NUQ.NUQ_LCORRE <> ' '
				AND NUQ.%notDEL%
		EndSql

		dbSelectArea(cAlias)

		If !(cAlias)->(EOF()) .And. ( ( (cAlias)->NUQ_CCORRE <> c095cCor ) .Or. ( (cAlias)->NUQ_LCORRE <> c095lCor ) )

			If ApMsgYesNo(STR0031) //O(s) correspondente(s) do processo foi alterado, � necess�rio preencher as informa��es de hist�rico. Confirma Opera��o?

				c095cCor := (cAlias)->NUQ_CCORRE
				c095lCor := (cAlias)->NUQ_LCORRE
				c095dCor := JurGetDados('SA2',1,xFilial('SA2') + c095cCor + c095lCor,'A2_NOME')

				oM93 := FWLoadModel('JURA093')
				oM93:SetOperation(nOper)
				oM93:Activate()
				oM93:SetValue("NTCMASTER","NTC_FILIAL",cTipoAsJ)
				oM93:SetValue("NTCMASTER","NTC_CAJURI",c095Cajuri)
				oM93:SetValue("NTCMASTER","NTC_NUMPRO",c095NumPro)
				oM93:SetValue("NTCMASTER","NTC_INSTAN",c095Instan)
				oM93:SetValue("NTCMASTER","NTC_CCORES",c095cCor)
				oM93:SetValue("NTCMASTER","NTC_LCORRE",c095lCor)
				oM93:SetValue("NTCMASTER","NTC_DCORRE",c095dCor)

				MsgRun(STR0032,STR0033,{|| nRet:= FWExecView(STR0034, 'JURA093', nOper,,{||lRet := .T., lRet},,,aShow,,,,oM93 )}) //"Carregando..." e "Pesquisa de Processos"

				If nRet == 0
					lRet := .T.
				Else
					lRet := .F.
					JurMsgErro(STR0035) //Opera��o Cancelada
				Endif

				If lRet
					lRet := J183EnCnt(oModel, 2, nIndex)
				Endif

				oM93:Deactivate()
				oM93:Destroy()

				oModel:Activate()
			Else
				lRet := .F.
				JurMsgErro(STR0035) //Opera��o Cancelada
			Endif
		Endif

		(cAlias)->(dbCloseArea())
	Endif

	RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA183Enc(cCajuri, cCForne, cLForne, cInstan, cCodCont, , cSequen, cSeqOri)
Fun��o para encerrar os contratos do processo.
@Return cQtde		Quantidade de processo

@param cCajuri 		- C�digo do Assunto Jur�dico
@param cCForne 		- C�digo do Forncedor
@param cLForne 		- C�digo da Loja do Fornecedor
@param cInstan 		- C�digo da Instancia
@param cCodCont		- C�digo do Contrato
@return lRet
@author Cl�vis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA183Enc(cCajuri, cCForne, cLForne, cInstan, cSequen, cSeqOri, cCod)
	Local lRet := .T.

	If NSU->(dbSeek(xFilial('NSU') + cCajuri + cCForne + cLForne + cInstan + cSequen + cSeqOri + cCod))	 //Exclus�o de Incidente
		RecLock('NSU', .F.)
		NSU->NSU_FIMVGN := Date()
		NSU->NSU_NCAREN := 0
		NSU->NSU_DCAREN := Date()
		MsUnlock()
	Else
		JurMsgErro(STR0010) //"N�o foi poss�vel encerrar os contratos destes processos"
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183EnCnt(oModel)
Fun��o para verificar a necessidade de encerramento dos contratos da
instancia anterior.
@Return cQtde		Quantidade de processo

@param  oModel 	- Modelo de Dados
@return lRet
@author Cl�vis Eduardo Teixeira
@since 01/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183EnCnt(oModel, nTipo, nIndex)
	Local aArea     := GetArea()
	Local cCajuri   := oModel:GetValue('NSZMASTER','NSZ_COD')
	Local oModelNUQ := oModel:GetModel('NUQDETAIL')
	Local nUltLin   := oModelNUQ:GetQtdLine()
	Local cAlias    := Nil
	Local cAlsNUQ   := Nil
	Local nQtdeInst := 0
	Local cFimVgn   := ''
	Local cInstAtu  := ''
	Local lRet      := .T.
	Local cHoje     := dToS(Date())
	Local nI        := 0
	Local lResp     := .F.

	Default nTipo   := 1
	Default nIndex  := 1

	If nUltLin > 0

		cAlias    := GetNextAlias()
		cAlsNUQ   := GetNextAlias()

		If nTipo == 1

			BeginSql Alias cAlsNUQ
				SELECT COUNT(*) QTDE
				FROM %Table:NUQ% NUQ
				WHERE NUQ.NUQ_CAJURI = %Exp:cCajuri%
				AND NUQ.NUQ_FILIAL = %xFilial:NUQ%
				AND NUQ.%notDEL%
			EndSql
			dbSelectArea(cAlsNUQ)

			nQtdeInst := (cAlsNUQ)->QTDE

			If nUltLin > nQtdeInst .Or. oModel:IsFieldUpdated('NUQDETAIL','NUQ_INSATU')

				For nI := 1 To oModelNUQ:GetQtdLine()

					If (!oModelNUQ:IsDeleted( nI ) .And. !oModelNUQ:IsEmpty( nI )) .And. (oModelNUQ:GetValue('NUQ_INSATU', nI) == '1')
						cInstAtu := (oModelNUQ:GetValue('NUQ_INSTAN', nI ))
						Exit
					EndIf
				Next

				BeginSql Alias cAlias
					column NSU_FIMVGN as date
					SELECT NSU_CAJURI, NSU_CFORNE, NSU_LFORNE, NSU_INSTAN, NSU_FLGREJ
					NSU_CPADRA, NSU_CTCONT, NSU_SEQUEN, NSU_SEQORI, NSU_COD,NSU_NCAREN, NSU_FIMVGN
					FROM %Table:NSU% NSU
					WHERE (NSU.NSU_FIMVGN = %Exp:cFimVgn% OR NSU.NSU_FIMVGN >= %Exp:cHoje% OR NSU.NSU_DCAREN >= %Exp:cHoje%)
					AND NSU.NSU_CAJURI  = %Exp:cCajuri%
					AND NSU.NSU_INSTAN <> %Exp:cInstAtu%
					AND NSU.NSU_FILIAL  = %xFilial:NSU%
					AND NSU.%notDEL%
				EndSql
				dbSelectArea(cAlias)

				If !(cAlias)->(Eof())
					//Valida se o contrato est� ativo em fun��o da daa de vig�ncia ou em fun��o da car�ncia para exibir a mensagem correta.
					If (cAlias)->NSU_NCAREN>0 .And. (cAlias)->NSU_FIMVGN < DATE()
						lResp := ApMsgYesNo(STR0011) // "Existe(m) contrato(s) ativo(s) da inst�ncia anterior devido a car�ncia. Deseja encerrar este(s) contrato(s)?"
					Else
						lresp := ApMsgYesNo(STR0012) // "Existe(m) contrato(s) ativo(s) da inst�ncia anterior. Deseja encerrar este(s) contrato(s)?"
					Endif
				Endif

				If !(cAlias)->(Eof()) .And. lResp
					While !(cAlias)->(EOF())
						lRet := JA183Enc((cAlias)->NSU_CAJURI,(cAlias)->NSU_CFORNE,(cAlias)->NSU_LFORNE,;
							(cAlias)->NSU_INSTAN,(cAlias)->NSU_SEQUEN, (cAlias)->NSU_SEQORI, (cAlias)->NSU_COD)
						(cAlias)->(dbSkip())
					End
				Endif

				(cAlias)->(dbCloseArea())

			Endif

			(cAlsNUQ)->(dbCloseArea())

		Else
			cInstAtu := (oModelNUQ:GetValue('NUQ_INSTAN', nIndex))

			BeginSql Alias cAlias
				column NSU_FIMVGN as date
				SELECT NSU_CAJURI, NSU_CFORNE, NSU_LFORNE, NSU_INSTAN, NSU_FLGREJ
				NSU_CPADRA, NSU_CTCONT, NSU_SEQUEN, NSU_SEQORI, NSU_COD, NSU_NCAREN, NSU_FIMVGN
				FROM %Table:NSU% NSU
				WHERE (NSU.NSU_FIMVGN = %Exp:cFimVgn% OR NSU.NSU_FIMVGN >= %Exp:cHoje% OR NSU.NSU_DCAREN >= %Exp:cHoje%)
				AND NSU.NSU_CAJURI  = %Exp:cCajuri%
				AND NSU.NSU_INSTAN  = %Exp:cInstAtu%
				AND NSU.NSU_FILIAL  = %xFilial:NSU%
				AND NSU.%notDEL%
			EndSql
			dbSelectArea(cAlias)

			If !(cAlias)->(Eof())
				//Valida se o contrato est� ativo em fun��o da daa de vig�ncia ou em fun��o da car�ncia para exibir a mensagem correta.
				If (cAlias)->NSU_NCAREN>0 .And. (cAlias)->NSU_FIMVGN < DATE()
					lResp := ApMsgYesNo(STR0011) // "Existe(m) contrato(s) ativo(s) da inst�ncia anterior devido a car�ncia. Deseja encerrar este(s) contrato(s)?"
				Else
					lresp := ApMsgYesNo(STR0012) // "Existe(m) contrato(s) ativo(s) da inst�ncia anterior. Deseja encerrar este(s) contrato(s)?"
				Endif
			Endif

			If !(cAlias)->(Eof()) .And. lResp
				While !(cAlias)->(EOF())
					lRet := JA183Enc((cAlias)->NSU_CAJURI,(cAlias)->NSU_CFORNE,(cAlias)->NSU_LFORNE,;
						(cAlias)->NSU_INSTAN,(cAlias)->NSU_SEQUEN, (cAlias)->NSU_SEQORI, (cAlias)->NSU_COD)
					(cAlias)->(dbSkip())
				End
			Endif

			(cAlias)->(dbCloseArea())

		Endif

	Endif

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA183Cont(cCajuri, cCodInstan, cCodCorresp)
Verifica se instancia e correspondente est�o preenchidos corretamente.

@param  cCajuri
@param  cCodInstan
@param  cCodCorresp
@author Cl�vis Teixeira
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA183Cont(cCajuri, cCodInstan, cCodCorresp)
	Local lRet := .F.

	If !Empty(cCodCorresp) .And. !Empty(cCodInstan)
		NUQ->( dbSetOrder( 5 ))
		If NUQ->(dbSeek(xFilial('NUQ') + cCajuri + cCodInstan))
			lRet := .T.
		Else
			JurMsgErro(STR0013)  //"N�o foi poss�vel localizar os dados de inst�ncia deste processo. Opera��o cancelada!"
		Endif
	Else
		JurMsgErro(STR0014) //"Os campos: Inst�ncia e C�d. Correspondente do cadastro de inst�ncia devem estar preenchidos para acessar este cadastro. Opera��o cancelada!"
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183AssOrg(cFilOri, cCajur)
Fun��o utilizada para n�o permitir que processo seja origem e incidentes
dentro da mesma familia de incidentes.
Uso Geral.
@author Cl�vis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183AssOrg(cFilOri, cCajur)
	Local cRotina := 'JURA095'
	Local aArea   := GetArea()
	Local aShow   := {{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil}}

	If !Empty(cCajur)
		NSZ->(DBSetOrder(1))

		If NSZ->(dbSeek(xFilial('NSZ') + cCajur))
			MsgRun(STR0015, STR0016,{|| FWExecView( STR0016, cRotina, 4,, { || lOk := .T., lOk },,,aShow) }) //Carregando... Processo Origem
		Endif

	Else
		JurMsgErro( STR0017 )
	EndIf

	RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA183PRO(nOpc)
Verifica��o de Numero de Duplicado por tipo de assunto jur�dico
@Return lRet	.T./.F. As informa��es s�o v�lidas ou n�o
@param  nOpc    N�mero da opera��o
@author Cl�vis Eduardo Teixeira
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA183PRO(nOpc)
	Local lRet      := .T.
	Local oM        := FWModelActive()
	Local oMNUQ     := oM:GetModel('NUQDETAIL')
	Local cAlias    := Nil
	Local cQuery    := ''
	Local aArea     := GetArea()
	Local cProcDpl  := SuperGetMV('MV_JNUMPRO',.F.,'2')
	Local lAterado  := .F.
	Local nLine     := oMNUQ:GetLine()
	Local nCt       := 0
	Local cNumPro	:= ""

	If nOpc == 4

		For nCt:=1 To oMNUQ:GetQtdLine()

			oMNUQ:GoLine(nCt)

			If oMNUQ:IsFieldUpdated('NUQ_NUMPRO') .And. !oMNUQ:IsDeleted()
				lAterado := .T.
				Exit
			EndIf
		Next nCt

		oMNUQ:GoLine(nLine)
	EndIf

	If nOpc == 3 .Or. lAterado

		If Existblock("JA183QRY") // PE substitui o filtro de duplicidade de numero de processo.

			lRet := ExecBlock("JA183QRY",.F.,.F.,{oM})

			If ValType(lRet) <> "L"
				lRet := .T.
			EndIf
		Else

			cNumPro := oM:GetValue("NUQDETAIL", "NUQ_NUMPRO")
			cNumPro := AllTrim( StrTran( Lower( JurLmpCpo(cNumPro) ), "#", "") )

			cQuery += "SELECT COUNT(1) QTDE "
			cQuery += "  FROM "+RetSqlName("NUQ")+" NUQ,"+RetSqlName("NSZ")+" NSZ"
			cQuery += " WHERE NUQ_FILIAL = '"+xFilial("NUQ")+"' AND NSZ_FILIAL = '"+xFilial("NSZ")+"'"
			cQuery += "   AND NUQ.D_E_L_E_T_ = ' ' AND NSZ.D_E_L_E_T_ = ' '"
			cQuery += "   AND NSZ_COD = NUQ_CAJURI"
			cQuery += "   AND NUQ_COD   <>  '" + oM:GetValue('NUQDETAIL','NUQ_COD')	   + "'"
			cQuery += "   AND NSZ_TIPOAS =  '" + oM:GetValue('NSZMASTER','NSZ_TIPOAS') + "'"
			cQuery += "   AND NUQ_CAJURI <> '" + oM:GetValue('NSZMASTER','NSZ_COD')	   + "'"

			cQuery := ChangeQuery(cQuery)
			cQuery += "   AND REPLACE("+ JurFormat("NUQ_NUMPRO", .T., .T.) + ",' ','') = '" + cNumPro + "'"

			cAlias := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

			If !(cAlias)->( EOF() )
				If (cAlias)->QTDE > 0
					If cProcDpl == '2'
						If !(IsInCallStack("MILESCHIMP") .OR. IsInCallStack("FWMILEMVC")  .OR. IsInCallStack("CFGA600"))
							//Webservice de integra��o
							If  FWViewActive() == NIL
								lRet := .T.
							ElseIf !(lRet := ApMsgYesNo(STR0019) )	//"J� existe um processo com este n�mero. Deseja continuar assim mesmo ?"
								JurMsgErro(STR0020)					//"Verifique o n�mero do processo"
							EndIf
						Else
							lRet := .t.
						EndIf
					ElseIf cProcDpl == '1'
						JurMsgErro(STR0021)							//"O sistema j� possui um registro com este n�mero de processo, favor alterar!"
						lRet := .F.
					EndIf
				EndIf
			End

			(cAlias)->( dbcloseArea() )
		Endif
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183VINS
Valida��o dos campos de inst�ncia
Uso no cadastro de inst�ncia.

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author Juliana Iwayama Velho
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183VINS()
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aAreaNUQ   := NUQ->( GetArea() )
	Local oModel     := FWModelActive()
	Local oModelNUQ  := oModel:GetModel('NUQDETAIL')
	Local aSaveLines := FWSaveRows()		// salva o contexto da linha em que esta posicionado.
	Local nLineAtual := oModelNUQ:GetLine()
	Local nCt        := 0
	Local lInstAtual := .F.
	Local lDupInstAt := .F.

	For nCt := 1 To oModelNUQ:GetQtdLine()

		oModelNUQ:GoLine( nCt )

		If oModelNUQ:IsDeleted(nCt)
			If lRet .And. !Empty( oModelNUQ:GetValue('NUQ_INSTAN',nCt) )	// Se o registro estiver deletado e
				lRet:= JU183CORR() //verificar se h� Contrato Correspondente Vigente, caso esteja deletando a linha!!!
			EndIf
		Else
			If oModelNUQ:GetValue('NUQ_INSATU',nCt) == '1'
				//<- Verifica se j� h� alguma Inst Atual ->
				If lInstAtual
					lDupInstAt := .T.  	// Duplicidade de Inst�ncia Atual
				Else
					lInstAtual := .T.
				EndIf

				If lRet .And. oModelNUQ:GetValue('NUQ_EXECUC',nCt) == '1' .And. Empty(oModelNUQ:GetValue('NUQ_DTEXEC',nCt))
					JurMsgErro(STR0022) // "Preencher os dados da execu��o "
					lRet:= .F.
					Exit
				EndIf
			EndIf

			If lRet
				If (!Empty(oModelNUQ:GetValue('NUQ_CCORRE',nCt)) .Or. !Empty(oModelNUQ:GetValue('NUQ_LCORRE',nCt))) .And.;
						!(!Empty(oModelNUQ:GetValue('NUQ_CCORRE',nCt)) .And. !Empty(oModelNUQ:GetValue('NUQ_LCORRE',nCt)))
					JurMsgErro(STR0023)  // "� necess�rio preencher os campos de correspondente"
					lRet:= .F.
					Exit
				EndIf
			EndIf

			If lRet .And. JGetParTpa(cTipoAsJ, 'MV_JFORVAR','1') == '1' ; // Foro e Vara sao obrigatorios no processo?
				.And. Empty(oModelNUQ:GetValue('NUQ_CLOC3N',nCt)) ; // Vara est� preenchida?
				.And. Iif(oModelNUQ:HasField('NUQ_TLOC3N'), Empty(oModelNUQ:GetValue('NUQ_TLOC3N',nCt)), .T.) // O complemento est� vazio?

				// Valida se h� varas cadastradas para o foro selecionado
				If !Empty( JurGetDados('NQE', 3 , xFilial('NQE') + oModelNUQ:GetValue('NUQ_CLOC2N') , 'NQE_COD') )
					JurMsgErro( I18n(STR0018, {J95TitCpo('NUQ_CLOC3N', cTipoAsJ)}) )//"� necess�rio preencher o(s) campo(s) de "
					lRet := .F.
					Exit
				EndIf
			EndIf

			If lRet .And. oModelNUQ:GetValue('NUQ_EXECUC') = '1' .And. Empty(oModelNUQ:GetValue('NUQ_DTEXEC'))
				JurMsgErro(STR0024)   //"O campo de data de execu��o precisa ser preenchido."
				lRet := .F.
				Exit
			EndIf

			If lRet .And. !IsInCallStack("OpAltLote") .And. ( oModelNUQ:IsFieldUpdated('NUQ_CCORRE',nCt) .Or. oModelNUQ:IsFieldUpdated('NUQ_LCORRE', nCt) )
				lRet := J183CORRES(oModelNUQ, nCt) //Verifica��o do preenchimento do hist�rico do Correspondente
			EndIf

			//Valida os campos de Decis�o
			If lRet
				If (!Empty(FwFldGet('NUQ_OBSERV')) .And. Empty(FwFldGet('NUQ_DTDECI')) .And. Empty(FwFldGet('NUQ_CDECIS')) )    //permitir utilizar apenas o campo de observa��o
					lRet := .T.
				Else
					If (!Empty(FwFldGet('NUQ_DTDECI')) .Or. !Empty(FwFldGet('NUQ_CDECIS')) .Or. !Empty(FwFldGet('NUQ_OBSERV'))) ;          //Se um destes campos estiver preenchido...
						.AND. !(!Empty(FwFldGet('NUQ_DTDECI')) .And. !Empty(FwFldGet('NUQ_CDECIS')) .And. !Empty(FwFldGet('NUQ_OBSERV'))) //... mas um deles estiver em branco, deve ser preenchido!

						JurMsgErro(STR0025+RetTitle('NUQ_DTDECI')+', '+RetTitle('NUQ_CDECIS')+', '+RetTitle('NUQ_OBSERV'))  // "Preencher os dados da decis�o. "
						lRet:= .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	//<- Verifica Duplicidade de 'Inst�ncia Atual' e se h� pelo menos um 'Inst�ncia Atual'->
	If lRet
		If lDupInstAt
			JurMsgErro(STR0026) //'N�o � permitido ter mais de uma inst�ncia atual. Verificar.'
			lRet:= .F.
		ElseIf !lInstAtual
			JurMsgErro(STR0027) //"� necess�rio ter uma inst�ncia atual, verificar"
			lRet:= .F.
		EndIf
	EndIf

	// Retorna a linha quando ocorreu a chamada
	oModelNUQ:GoLine( nLineAtual )

	RestArea( aAreaNUQ )
	RestArea( aArea )

	FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183NQU(cNatureza)
Monta a query de tipo de a��o partir de par�metro de natureza
Uso no cadastro de Inst�ncia.

@Return cNatureza   Campo de c�digo de Natureza
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR183NQU(cNatureza)
	Local aArea    := GetArea()
	Local cQuery   := ""

	cQuery += "SELECT NQU_COD, NQU_DESC, NQU.R_E_C_N_O_ NQURECNO "
	cQuery += " FROM "+RetSqlName("NQU")+" NQU "
	cQuery += " WHERE NQU_FILIAL = '"+xFilial("NQU")+"'"
	cQuery += " AND NQU.D_E_L_E_T_ = ' '"

	If !Empty(cNatureza)
		cQuery += " AND NQU_ORIGEM IN ( "
		cQuery += "  SELECT DISTINCT NQ1_TIPO FROM "+RetSqlName("NQ1")+" NQ1 "
		cQuery += "  WHERE NQ1_FILIAL = '"+xFilial("NQ1")+"'"
		cQuery += "    AND NQ1_COD = '"+cNatureza+"'"
		cQuery += "    AND NQ1.D_E_L_E_T_ = ' ')"
	EndIf

	RestArea( aArea )

Return cQuery

*/
//-------------------------------------------------------------------
/*/{Protheus.doc} JA183NPro(oModel)
Informa o n�mero do processo da inst�ncia atual
Uso no cadastro de Processos.
@param  oModel Modelo de dados do cadastro de processo
@return cNumPro
@author Cl�vis Eduardo Teixeira
@since 24/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA183NPro(oModel)
	Local cNumPro    := ''
	Local nI         := 0
	Local oModelGrid := oModel:GetModel("NUQDETAIL")

	If oModelGrid <> Nil
		For nI := 1 To oModelGrid:GetQtdLine()
			If !oModelGrid:IsDeleted( nI ) .And. !oModelGrid:IsEmpty( nI ) .And. oModelGrid:GetValue('NUQ_INSATU', nI) == '1'
				cNumPro := (oModelGrid:GetValue( 'NUQ_NUMPRO', nI ))
				Exit
			EndIf
		Next
	EndIf

Return cNumPro

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183L3OK
Valida se o campo de Localiza��o de 3. Nivel est� vinculado ao de
Localiza��o de 2. Nivel
Uso no cadastro de Inst�ncia.

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@sample

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183L3OK()
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaNQE := NQE->( GetArea() )
	Local oModel   := FWModelActive()
	Local cLoc2N   := oModel:GetValue("NUQDETAIL","NUQ_CLOC2N")
	Local cLoc3N   := oModel:GetValue("NUQDETAIL","NUQ_CLOC3N")

	If !Empty(cLoc3N)

		NQE->( dbSetOrder( 1 ) )
		NQE->( dbSeek( xFilial( 'NQE' ) + cLoc3N ) )

		While !NQE->( EOF() ) .AND. xFilial( 'NQE' ) + cLoc3N == NQE->NQE_FILIAL + NQE->NQE_COD
			If cLoc2N == NQE->NQE_CLOC2N
				lRet := .T.
			Endif
			NQE->( dbSkip() )
		End

		If !lRet
			JurMsgErro(STR0005) // "Vara ou Camara n�o compat�veis com o Foro e/ou Tribunal"
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaNQE )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183L2OK
Valida se o campo de Localiza��o de 2. Nivel est� vinculado ao de
Comarca e se o digitado � da inst�ncia
Uso no cadastro de Inst�ncia.

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@sample

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183L2OK()
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaNQC := NQC->( GetArea() )
	Local oModel   := FWModelActive()
	Local cComarca := oModel:GetValue("NUQDETAIL","NUQ_CCOMAR")
	Local cLoc2N   := oModel:GetValue("NUQDETAIL","NUQ_CLOC2N")

	NQC->( dbSetOrder( 3 ) )
	NQC->( dbSeek( xFilial( 'NQC' ) + cLoc2N ) )

	While !NQC->( EOF() ) .AND. xFilial( 'NQC' ) + cLoc2N == NQC->NQC_FILIAL + NQC->NQC_COD
		If cComarca == NQC->NQC_CCOMAR
			lRet := .T.
		Endif
		NQC->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0004) //"Foro ou Tribunal n�o compat�veis com a Comarca e/ou Instancia informadas"
		lRet := .F.
	EndIf

	RestArea( aAreaNQC )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183UF
Funcao para validar os codigos de municipios em rela��o ao estado
nas abas de Detalhe e Inst�ncias do Processo.

@Param cOrimge:Indica o nome da origem da chamada.
				Exemplo:
				 'NSZMASTER' -> validar a aba de Detalhes
				 'NUQDETAIL' -> Validar a aba de Instancias / Unidades
@author Rafael Rezende Costa
@since 05/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183UF( cOrigem )
	Local lRet   := .T.
	Local cMun   := ""
	Local cEst   := ""
	Local oModel := FWModelActive()

	Default cOrigem := ''

	If oModel <> NIL .AND. cOrigem <> ''
		Do Case

			//<- Detalhes do Processo ->
		Case cOrigem == 'NSZMASTER'

			IF oModel:GetModel('NSZMASTER'):HasField('NSZ_ESTADO') .And. oModel:GetModel('NSZMASTER'):HasField('NSZ_CMUNIC')
				cMun := oModel:GetModel('NSZMASTER'):GetValue('NSZ_CMUNIC')
				cEst := oModel:GetModel('NSZMASTER'):GetValue('NSZ_ESTADO')

				If EMPTY(cEst) .AND. !EMPTY(cMun)
					JurMsgErro(STR0028) // "Aten��o: Para escolher/digitar o c�digo do munic�pio � necess�rio que haja uma UF preenchida !"
					lRet := .F.
				Else
					If __ReadVar $ 'M->NSZ_ESTADO'
						lRet := ExistCpo("SX5","12"+cEst)
					ElseIf __ReadVar $ 'M->NSZ_CMUNIC'
						lRet := ExistCpo("CC2",cEst + ALLTRIM(cMun))
					EndIf

					If !Empty(cMun)
						DBSelectArea('CC2')
						(DbSetOrder(1)) 			//CC2_FILIAL+CC2_EST+CC2_CODMUN

						If !CC2->(DbSeek(xFilial("CC2")+cEst+cMun))
							JurMsgErro(STR0029) 	//"Aten��o: O C�digo de municipio n�o � v�lido para esta UF !"
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIF

			//<- Aba de Inst�ncia / Unidades ->
		Case cOrigem == 'NUQDETAIL'

			IF oModel:GetModel('NUQDETAIL'):HasField('NUQ_ESTADO') .And. oModel:GetModel('NUQDETAIL'):HasField('NUQ_CMUNIC')
				cMun := oModel:GetModel('NUQDETAIL'):GetValue('NUQ_CMUNIC')
				cEst := oModel:GetModel('NUQDETAIL'):GetValue('NUQ_ESTADO')

				If EMPTY(cEst) .AND. !EMPTY(cMun)
					JurMsgErro(STR0028)  // "Aten��o: Para escolher/digitar o c�digo do munic�pio � necess�rio que haja uma UF preenchida !"
					lRet := .F.
				Else
					If __ReadVar $ 'M->NUQ_ESTADO'
						lRet := ExistCpo("SX5","12"+cEst)
					ElseIf __ReadVar $ 'M->NUQ_CMUNIC'
						lRet := ExistCpo("CC2",cEst + cMun)
					EndIf

					If !Empty(cMun)
						DBSelectArea('CC2')
						(DbSetOrder(1)) 			//CC2_FILIAL+CC2_EST+CC2_CODMUN
						If !CC2->(DbSeek(xFilial("CC2")+cEst+cMun))
							JurMsgErro(STR0029) 						//JurMsgErro("Aten��o: O C�digo de municipio n�o � v�lido para esta UF !")
							lRet := .F.
						EndIf
					EndIf

				EndIf
			EndIf
		EndCase
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA183VSU5
Verifica se o valor do campo de advogado � v�lido
Uso no cadastro de Inst�ncia

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author Juliana Iwayama Velho
@since 29/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA183VSU5()
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oModelNUQ := oModel:GetModel('NUQDETAIL')
	Local cQuery    := JA95SU5( oModelNUQ:GetValue('NUQ_CCORRE') )
	Local cAlias    := GetNextAlias()

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If (cAlias)->U5_CODCONT == oModel:GetValue('NUQDETAIL','NUQ_CADVOG')
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0008) //"Campo inv�lido "
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183VNQ1
Verifica se o valor do campo de natureza � v�lido
Uso no cadastro de Inst�ncia.

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183VNQ1()
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaNQ1 := NQ1->( GetArea() )

	NQ1->( dbSetOrder( 1 ) )
	NQ1->( dbSeek( xFilial( 'NQ1' ) + FwFldGet('NUQ_CNATUR') ) )

	If !NQ1->( EOF() ) .AND. xFilial( 'NQ1' ) + FwFldGet('NUQ_CNATUR') == NQ1->NQ1_FILIAL + NQ1->NQ1_COD

		lRet:= IIF(EMPTY(FwFldGet('NSZ_CPRORI')), NQ1->NQ1_ORIGEM == '1', NQ1->NQ1_ORIGEM == '2')

	EndIf

	If !lRet
		JurMsgErro(STR0030)  //"O c�digo n�o � v�lido para a origem do processo!"
	EndIf

	RestArea( aAreaNQ1 )
	RestArea( aArea )

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183VLNQU
Verifica se o valor do campo de tipo de a��o � v�lido
Uso no cadastro de Inst�ncia.

@param 	cMaster  	NUQDETAIL - Dados da Inst�ncia
@Return cCampo	    NUQ_CNATUR - Campo de c�digo da natureza
@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183VLNQU(cMaster, cCampo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local oModel   := FWModelActive()
	Local cQuery   := JUR183NQU(oModel:GetValue(cMaster,cCampo))
	Local cAlias   := GetNextAlias()

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If (cAlias)->NQU_COD == oModel:GetValue(cMaster,'NUQ_CTIPAC')
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0030) //"O c�digo n�o � v�lido para a origem do processo!"
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183CliNUQ

Consulta padrao para cliente da unidade respeitando a restricao

@author Rodrigo Guerato
@since 31/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183CliNUQ()
	Local aArea     := GetArea()
	Local aAreaSA1  := SA1->(GetArea())
	Local lRet      := .F.
	Local aCampos   := {'A1_COD','A1_LOJA','A1_NOME'}
	Local aRestr    := {}
	Local cRetFim   := ""
	Local cRet      := ""
	Local nPos      := 0
	Local cSQL      := ""
	Local aTemp     := {}
	Local TABLANC   := ""
	Local aFields   := {}
	Local aOrder    := {}
	Local aFldsFilt := {}
	Local aCodsUser := {}
	Local nI        := 0
	Local nY        := 0
	Local lNY2InDic := FWAliasInDic("NY2")
	Local oTabTmp   := Nil
	Local aStruAdic := {}

	If IsPesquisa() .OR. IsInCallStack("JURA162")

		aRestr := JA162RstUs()

		If !Empty(aRestr)

			cSQL := "	SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,  SA1.R_E_C_N_O_ RECNOLAN " + CRLF
			cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF

			If 'CLIENTES' $ cGrpRest

				cSQL += "	INNER JOIN " + RetSqlName("NWO") + " NWO ON (NWO.NWO_FILIAL = '"+xFilial("NWO")+"' AND "+ CRLF
				cSQL +=                                              " NWO.NWO_CCONF = '" + aRestr[1][1] + "' AND " + CRLF
				cSQL +=                                              " NWO.NWO_CCLIEN = SA1.A1_COD AND "+ CRLF
				cSQL +=                                              " NWO.NWO_CLOJA = SA1.A1_LOJA AND "+ CRLF
				cSQL +=                                              " NWO.D_E_L_E_T_ = ' ') "+ CRLF

				cSQL += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
				cSQL +=   " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

				If lNY2InDic

					cSQL += " UNION " + CRLF

					cSQL += "	SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,  SA1.R_E_C_N_O_ RECNOLAN " + CRLF
					cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF

					cSQL +=        " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "+ CRLF
					cSQL +=                                                     " NSZ.NSZ_CCLIEN = SA1.A1_COD AND " + CRLF
					cSQL +=                                                     " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND " + CRLF
					cSQL +=                                                     " NSZ.D_E_L_E_T_ = ' ') " + CRLF
					cSQL +=         " LEFT JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_FILIAL = '"+xFilial("NUQ")+"' AND "+ CRLF
					cSQL +=                                                     " NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND " + CRLF
					cSQL +=                                                     " NUQ.NUQ_INSATU = '1' AND " + CRLF
					cSQL +=                                                     " NUQ.D_E_L_E_T_ = ' ') " + CRLF

					cSQL += "	INNER JOIN " + RetSqlName("NY2") + " NY2 ON (NY2.NY2_FILIAL = '"+xFilial("NY2")+"' AND "+ CRLF
					cSQL +=                                              " NY2.NY2_CCONF = '" + aRestr[1][1] + "' AND " + CRLF
					cSQL +=                                              " NY2.NY2_CGRUP = SA1.A1_GRPVEN AND "+ CRLF
					cSQL +=                                              " NY2.D_E_L_E_T_ = ' ') "+ CRLF

					cSQL += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
					cSQL +=   " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

				Endif
			EndIf

			cSQL += " GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_  " + CRLF

			cSQL := ChangeQuery(cSQL, .F.)

			nPos   := Len(AllTrim(cRet))
			cRetFim:= SUBSTRING(cRet,1,nPos-4)

			Aadd(aStruAdic, { "RECNOLAN", "RECNOLAN", "N", 100, 0, ""})

			aTemp     := JurCriaTMP(GetNextAlias(), cSQL, 'SA1', , aStruAdic)
			oTabTmp   := aTemp[1]
			aFields   := aTemp[2]
			aOrder    := aTemp[3]
			aFldsFilt := aTemp[4]
			TABLANC   := oTabTmp:GetAlias()

			RestArea( aArea )
			RestArea(aAreaSA1)

			dbSelectArea(TABLANC)
			nResult := JurF3SXB('SA1', aCampos, "", .T., .F.,, cSQL)
			lRet := nResult > 0

			If lRet
				dbSelectArea("SA1")
				SA1->( dbGoto( nResult ) )
			EndIf

			//Apaga a Tabela tempor�ria
			oTabTmp:Delete()

		Else
			nResult := JurF3SXB('SA1', aCampos, cRetFim, .T., .F.)
			lRet := nResult > 0

			If lRet
				dbSelectArea("SA1")
				SA1->( dbGoto( nResult ) )
			EndIf
		EndIf

	Else
		oModel := FWModelActive()

		if !Empty(oModel:GetValue('NSZMASTER','NSZ_CGRCLI'))
			cRetFim := "A1_GRPVEN == '"+oModel:GetValue('NSZMASTER','NSZ_CGRCLI')+"'"
		endif

		// Se o usuario conter o grupo de Cliente, dever� carregar os codigos de clientes j� configurados.
		IF 'CLIENTES' $ cGrpRest
			aCodsUser := JurCodRst()

			cRetFim := ''
			For nI := 1 TO LEN(aCodsUser)
				aCods:= JurCdCliRst(aCodsUser[nI][1])

				For nY:= 1 to LEN(aCods)
					cRetFim += "A1_COD == '"+aCods[nY][1]+"'.AND.A1_LOJA=='"+aCods[nY][2]+"'"
					cRetFim += " .OR. "
				Next nY
			Next nI
			cRetFim:= LEFT(cRetFim , RAT(' .OR. ',cRetFim)-1 )
		EndIF

		nResult := JurF3SXB('SA1', aCampos, cRetFim, .T., .F.)
		lRet := nResult > 0

		If lRet
			dbSelectArea("SA1")
			SA1->( dbGoto( nResult ) )
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183NY3()
Filtra consulta padr�o de localiza��o de 4. nivel conforme localiza��o de 3. nivel
Uso no cadastro de Inst�ncia.

@Return cRet	 	Comando para filtro
@#JUR183NY3()

@author Rafael Rezende Costa
@since 04/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183NY3()
	Local aArea       := GetArea()
	Local aSaveLines  := {}
	Local oModel      := Nil
	Local oModelNUQ   := Nil
	Local c3Loc       := ''
	Local cRet        := "@#@#"

	If !IsPesquisa()
		oModel := FwModelActive()

		If !(oModel:cId $ 'JURA095|JURA219')	// Se o Model que vier carregado for diferente do JURA095, carrega o Modelo correspondente do JURA095
			oModel := FWLoadModel( 'JURA095' )
			oModel:Activate()	// Ativa o model.

			oModelNUQ := oModel:GetModel( 'NUQDETAIL' )
			c3Loc     := oModel:GetValue('NUQDETAIL', 'NUQ_CLOC3N') // parametro para pesquisa
		EndIF

		aSaveLines := FWSaveRows()		// salva o contexto da linha em que esta posicionado.

		If FwFldGet('NUQ_CLOC4N') == Nil .Or. Empty(FwFldGet('NUQ_CLOC3N'))
			cRet := "@#NY3->NY3_CLOC3N == '"+c3Loc+"'@#"
		Else
			cRet := "@#NY3->NY3_CLOC3N == '"+FwFldGet('NUQ_CLOC3N')+"'@#"
		EndIf
	EndIf

	RestArea( aArea )
	FWRestRows( aSaveLines )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183F3SU5
Customiza a consulta padr�o de advogado para verificar o correspondente
da inst�ncia
Uso no cadastro de Inst�ncia

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author Juliana Iwayama Velho
@since 29/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183F3SU5()
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local aPesq     := {"U5_CODCONT","U5_CONTAT"}
	Local oModel    := Nil
	Local oModelNUQ := Nil
	Local cQuery    := ''
	Local uRetorno  := 0

	If IsPesquisa()
		cQuery   := JA95SU5(M->NUQ_CCORRE)
	Else
		oModel    := FWModelActive()
		oModelNUQ := oModel:GetModel('NUQDETAIL')

		//<-- Verifica se o campo esta no model  ->
		IF oModelNUQ:HasField('NUQ_LCORRE')
			cQuery := JA95SU5( oModelNUQ:GetValue('NUQ_CCORRE') , oModelNUQ:GetValue('NUQ_LCORRE') )
		Else
			cQuery := JA95SU5( oModelNUQ:GetValue('NUQ_CCORRE') )
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery, .F.)
	RestArea( aArea )

	uRetorno := JurF3SXB("SU5", aPesq, "", .F., .F.,, cQuery)
	lRet := uRetorno > 0

	If lRet
		DbSelectArea("SU5")
		SU5->( dbGoto( uRetorno ) )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183NQE
Filtra consulta padr�o de localiza��o de 3. nivel conforme localiza��o de 2. nivel
Uso no cadastro de Inst�ncia.

@Return cRet	 	Comando para filtro
@#JUR183NQE()

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183NQE()
	Local aArea       := GetArea()
	Local aSaveLines  := {}
	Local oModel      := Nil
	Local oModelNUQ   := Nil
	Local cRet        := "@#@#"
	local cVara       := ''
	Local oCmpPesq2   := Nil
	Local nCt         := 0

	If IsPesquisa()
		oCmpPesq2 := J162CmpPes()  //Fun��o para retornar os campos da pesquisa.
		For nCt := 1 To Len(oCmpPesq2)
			If oCmpPesq2[nCt]:CNomeCampo == 'NUQ_CLOC2N'
				cVara := oCmpPesq2[nCt]:Valor
				Exit
			Endif
		Next

		If Len(cVara) > 5
			cVara := StrTran(cVara, ";", "','")
			cVara :=  LEFT(cVara, RAT(",", cVara) - 2)
		Endif

	Endif

	If IsPesquisa() .and. !IsInCallStack('JA095INC')
		cRet := "@#NQE->NQE_CLOC2N IN ('"+cVara+"')@#"
	Else
		If Empty(cVara)
			cRet := "@#NQE->NQE_CLOC2N IN ('"+FwFldGet('NUQ_CLOC2N')+"')@#"
		Else
			If FwFldGet('NUQ_CLOC2N') == Nil .Or. Empty(FwFLdGet('NUQ_CLOC2N'))
				cRet := "@#NQE->NQE_CLOC2N IN ('"+cVara+"')@#"
			EndIf
		Endif
	EndIf

	If !IsPesquisa()
		oModel:= FwModelActive()

		If !(AllTrim(oModel:cId) $ 'JURA095|JURA219')			// Se o Model que vier carregado for diferente do JURA095, carrega o Modelo correspondente do JURA095
			oModel := FWLoadModel( 'JURA095' )
			oModel:Activate()	// Ativa o model.
			aSaveLines := FWSaveRows()
		Else
			aSaveLines := FWSaveRows()		// salva o contexto da linha em que esta posicionado.
		EndIf

		oModelNUQ := oModel:GetModel( 'NUQDETAIL' )
		cVara     := oModelNUQ:GetValue('NUQ_CLOC2N')
	EndIf

	RestArea( aArea )
	FWRestRows( aSaveLines )

	If Empty(cVara)
		cRet := ''
	EndIf

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183NQC
Filtra consulta padr�o de localiza��o de 2. nivel conforme inst�ncia e comarca
Uso no cadastro de Inst�ncia.

@Return cRet	 	Comando para filtro
@sample
@#JUR183NQC()

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183NQC()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local cComar    := ''
	Local cRet      := "@#@#"
	Local oCmpPesq  := Nil
	Local nCt       := 0

	If IsPesquisa()
		oCmpPesq := J162CmpPes()                      //Fun��o para retornar os campos da pesquisa.
		For nCt := 1 To Len(oCmpPesq)
			If 	oCmpPesq[nCt]:CNomeCampo == 'NUQ_CCOMAR'
				cComar := oCmpPesq[nCt]:Valor
				Exit
			Endif
		Next

		If Len(cComar) > 4
			cComar := StrTran(cComar, ";", "','")
			cComar :=  LEFT(cComar, RAT(",", cComar) - 2)
		Endif

	Endif

	If IsPesquisa() .and. !IsInCallStack('JA095INC')
		cRet := "@#NQC->NQC_CCOMAR IN ('"+cComar+"')@#"
	Else
		If Empty(cComar)
			cRet := "@#NQC->NQC_CCOMAR IN ('"+FwFldGet('NUQ_CCOMAR')+"')@#"
			cRet += " .AND. @#NQC->NQC_INSTAN IN ('"+FwFldGet('NUQ_INSTAN')+"', ' ')@#"
		Else
			cRet := "@#NQC->NQC_CCOMAR IN ('"+cComar+"')@#"
		Endif
	EndIf

	If !IsPesquisa()
		cComar  := oModel:GetValue('NUQDETAIL', 'NUQ_CCOMAR')
	EndIf

	If Empty(Alltrim(cComar))
		cComar := Alltrim(M->NUQ_CCOMAR)
	EndIf

	RestArea( aArea )

	If Empty(cComar)
		cRet := ''
	EndIf


Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183F3NQU
Customiza a consulta padr�o de tipo de a��o conforme a natureza
Uso no cadastro de Inst�ncia.

@param 	cMaster  	NUQDETAIL - Dados da Inst�ncia
@param cCampo	    NUQ_CNATUR - Campo de c�digo da natureza
@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183F3NQU(cMaster, cCampo)
	Local lRet   := .F.
	Local aArea  := GetArea()
	Local oModel := Nil
	Local cQuery := ''
	Local aPesq  := {"NQU_COD","NQU_DESC"}

	Default cMaster := ''
	Default cCampo  := ''

	If IsPesquisa()
		cQuery   := JUR183NQU(M->NUQ_CNATUR)
	Else
		oModel   := FWModelActive()
		cQuery   := JUR183NQU(oModel:GetValue(cMaster,cCampo))
	EndIF

	cQuery := ChangeQuery(cQuery, .F.)
	uRetorno := ''
	RestArea( aArea )

	If JurF3Qry( cQuery, 'JURA95F3', 'NQURECNO', @uRetorno, , aPesq,,,,,'NQU' )
		NQU->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183MES
Quando o processo est� encerrado, verifica a quantidade de meses entre
a data de encerramento e a de distribui��o do processo. Quando o processo
est� em andamento, verifica a data atual e a data de distribui��o.
@Return nRet	 	Quantidade de meses
@author Juliana Iwayama Velho
@since 03/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183MES()
	Local nRet       := 0
	Local cSituacao  := FwFldGet('NSZ_SITUAC')
	Local cDtDistrib := JurGetDados('NUQ',2,XFILIAL('NUQ')+FwFldGet('NSZ_COD')+'1','NUQ_DTDIST')
	Local cDtEncerra := FwFldGet('NSZ_DTENCE')

	If !Empty(cSituacao) .And. !Empty(cDtDistrib)
		If cSituacao == '1'
			nRet := DateDiffMonth(Date(),cDtDistrib)
		Elseif cSituacao == '2'
			If !Empty(cDtEncerra)
				nRet := DateDiffMonth(cDtEncerra, cDtDistrib)
			Endif
		EndIf
	Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183CTPA
Preenchimento automatico da descricao do tipo de a��o do processo,
conforme a inst�ncia atual

@param 	cTipoAcao  	C�digo do tipo de a��o
@Return cRet	 	Descri��o do tipo de a��o do processo

@author Juliana Iwayama Velho
@since 02/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183CTPA(cTipoAcao)
	Local cRet := JurGetDados('NQU',1,xFilial('NQU')+cTipoAcao,'NQU_DESC')
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183CNAT
Preenchimento automatico da descricao da natureza do processo,
conforme a inst�ncia atual

@param 	cNatureza  	C�digo da natureza
@Return cRet	 	Descri��o da natureza do processo

@author Juliana Iwayama Velho
@since 02/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183CNAT(cNatureza)
	Local cRet := JurGetDados('NQ1',1,xFilial('NQ1')+cNatureza,'NQ1_DESC')
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183CL3N
Preenchimento automatico da descricao da localiza��o de 3� n�vel do processo,
conforme a inst�ncia atual

@param 	cLoc3n  	C�digo da localiza��o de 3� nivel
@Return cRet	 	Descri��o da localiza��o de 3� nivel do processo

@author Juliana Iwayama Velho
@since 02/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183CL3N(cLoc3n)
	Local cRet := JurGetDados('NQE',1,xFilial('NQE')+cLoc3n,'NQE_DESC')
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183CL2N
Preenchimento automatico da descricao da localiza��o de 2� n�vel do processo,
conforme a inst�ncia atual

@param 	cLoc2n  	C�digo da localiza��o de 2� nivel
@Return cRet	 	Descri��o da localiza��o de 2� nivel do processo

@author Juliana Iwayama Velho
@since 02/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183CL2N(cLoc2n)
	Local cRet := JurGetDados('NQC',1,xFilial('NQC')+cLoc2n,'NQC_DESC')
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JUR183CCOM
Preenchimento automatico da descricao da comarca do processo, conforme
a inst�ncia atual

@param 	cComarca  	C�digo da comarca
@Return cRet	 	Descri��o da comarca do processo

@author Juliana Iwayama Velho
@since 02/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR183CCOM(cComarca)
	Local cRet := JurGetDados('NQ6',1,XFILIAL('NQ6')+cComarca,'NQ6_DESC')
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU183VNPRO()
Valida CNJ e busca Comarca, foro e vara no cadastro De/Para de Comarcas

Uso no cadastro de instancias do processo e Inclus�o de Processos TOTVS Legal

@param cNumPro   - Numero do Processo
@param cNatureza - C�digo da Natureza
@param cTipoAS   - Tipo de Assunto Jur�dico

@return Protheus    -> lValido   (boolean) - Informa se o valor do campo foi aceito
        TOTVS Legal -> aDadosVal (array)   - Dados do cadastro De/Para de comarcas
	        aDadosVal[1] - UF do De/Para
			aDadosVal[2] - Comarca do De/Para
			aDadosVal[3] - Foro do De/Para
			aDadosVal[4] - Vara do De/Para
			aDadosVal[5] - CNJ Valido?
			aDadosVal[6] - Mensagem CNJ inv�lido
			aDadosVal[7] - CNJ n�mero verificador inv�lido, continuar?

@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU183VNPRO(cNumPro, cNatureza, cTipoAS)

	Local oModel    := Nil
	Local oModelNUQ := Nil
	Local lValido   := .T.
	Local lContinuar:= .F.
	Local cDigito   := ""
	Local cValCnj   := ""
	Local cProcesso := ""
	Local cAno      := ""
	Local cJtr      := ""
	Local cOrigem   := ""
	Local nResto    := 0
	Local lO00InDic := FWAliasInDic("O00")
	Local cComarca  := ""
	Local cForo     := ""
	Local cVara     := ""
	Local cUf       := ""
	Local cMsg      := ""
	Local lTLegal   := IsInCallStack("post_vldcnj") //chamada do TotvsLegal
	Local aDadosVal := {}

	Default cNumPro    := ""
	Default cNatureza  := ""
	Default cTipoAS    := ""

	// Verifica se ira utilizar as informa��es do TOTVS Legal ou do modelo
	If !lTLegal
		oModel    := FWModelActive()
		oModelNUQ := oModel:GetModel('NUQDETAIL')
		cNumPro   := AllTrim( FwFldGet("NUQ_NUMPRO") )
		cTipoAS   := FwFldGet('NSZ_TIPOAS')
		cNatureza := FwFldGet("NUQ_CNATUR")
	EndIf

	If !Empty(cNumPro)

	EndIf

	//Verifica se deve fazer a validacao do numero do processo CNJ
	If JGetParTpa(cTipoAS, "MV_JNUMCNJ", "2") == "1"

		If Empty( cNatureza ) 	//Se n�o for Importa��o Manual de Distribui��o
			lValido := .F.
			If !lTLegal .and. !IsInCallStack("SugInfoProc")
				JurMsgErro(STR0038)		//"A Natureza deve ser informada."
			Else
				cMsg := STR0038 //"A Natureza deve ser informada."
			EndIf

		Else

			cValCnj	:= JurGetDados("NQ1", 1, xFilial("NQ1") + cNatureza, "NQ1_VALCNJ")

			//Verifica se a natureza valida CNJ
			If cValCnj == "1" .Or. IsInCallStack("SugInfoProc")	//Importa��o Manual de Distribui��o

				//Valida��o CNJ
				If Len(cNumPro) == 20
					//Pega N�mero seq�encial do Processo, por Unidade de Origem, a ser reiniciado a cada ano
					cProcesso	:= PadL( SubStr(cNumPro, 1	, 7), 7)

					//Pega digito verificador
					cDigito		:= PadL( SubStr(cNumPro, 8	, 2), 2)

					//Pega Ano do ajuizamento do Processo
					cAno		:= PadL( SubStr(cNumPro, 10	, 4), 4)

					//Pega	J	- �rg�o ou Segmento do Poder Judici�rio
					//		TR 	- Tribunal do respectivo Segmento do Poder Judici�rio
					cJtr		:= PadL( SubStr(cNumPro, 14	, 3), 3)

					//Pega unidade de origem do Processo
					cOrigem		:= PadL( SubStr(cNumPro, 17	, 4), 4)

					//-------------------------------------------------------------------
					//Efetua a valida��o do processo com o digito verficador
					//-------------------------------------------------------------------
					nResto := Mod( Val( cProcesso ), 97)

					nResto := Mod( Val( StrZero(nResto, 2) + cAno + cJtr), 97)

					nResto := Mod( Val( StrZero(nResto, 2) + cOrigem + cDigito), 97)

					//Valida numero de processo com digito verificador
					If nResto <> 1
						If !lTLegal
							If !isBlind()
								lValido := ApMsgYesNo(STR0036 + STR0040)		//"N�mero do processo incorreto, fora do padr�o CNJ." "Deseja continuar?"
							Else
								lValido    := .T.
							EndIf
						Else
							lValido    := .F.
							lContinuar := .T. //Flag para indicar se deve mostrar a pergunta (Deseja continuar?) no TotvsLegal
						EndIf
					EndIf
				Else
					lValido := .F.
					If !lTLegal
						JurMsgErro(STR0037)	//"N�mero CNJ inv�lido, verifique"
					Else
						cMsg := STR0037 //"N�mero CNJ inv�lido, verifique"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	// Busca Comarca no cadastro De/Para
	If ( lValido .OR. lTLegal ) .AND. lO00InDic

		If Empty(cJtr)
			//Pega	J	- �rg�o ou Segmento do Poder Judici�rio
			//		TR 	- Tribunal do respectivo Segmento do Poder Judici�rio
			cJtr		:= SubStr(Right(cNumPro, 7),1,3)

			//Pega unidade de origem do Processo
			cOrigem		:= Right(cNumPro, 4)
		EndIf

		dbSelectArea("O00")
		O00->(dbSetOrder(1))

		If O00->(dbSeek(xFilial("O00") + SubStr(AllTrim(cJtr), 1, 1) + '.' + SubStr(AllTrim(cJtr), 2, 3) + '.' + AllTrim(cOrigem) ))
			cUf      := O00->O00_UF
			cComarca := O00->O00_CCOMAR
			cForo    := O00->O00_CLOC2N
			cVara    := O00->O00_CLOC3N
		Endif

		If !Empty(cUf) .And. !Empty(cComarca) .AND. !lTLegal .And. !isBlind()
			lValido := oModelNUQ:SetValue("NUQ_ESTADO", cUf)

			If lValido
				oModelNUQ:SetValue("NUQ_CCOMAR", cComarca)
			EndIf

			If lValido
				oModelNUQ:SetValue("NUQ_CLOC2N", cForo)
			EndIf

			If lValido
				oModelNUQ:SetValue("NUQ_CLOC3N", cVara)
			EndIf
		EndIf
	EndIf

	If lTLegal
		aAdd( aDadosVal, cUf        ) //UF do De/Para
		aAdd( aDadosVal, cComarca   ) //Comarca do De/Para
		aAdd( aDadosVal, cForo      ) //Foro do De/Para
		aAdd( aDadosVal, cVara      ) //Vara do De/Para
		aAdd( aDadosVal, lValido    ) //CNJ Valido?
		aAdd( aDadosVal, cMsg       ) //Mensagem CNJ inv�lido
		aAdd( aDadosVal, lContinuar ) //CNJ n�mero verificador inv�lido, continuar?
	EndIf

Return IIF( lTLegal, aDadosVal, lValido )

//-------------------------------------------------------------------
/*/{Protheus.doc} JU183MNPRO()
Retorna a mascara do campo NUQ_NUMPRO
Uso no cadastro de instancias do processo campo X3_PICTVAR
@return lValido	- Informa se o valor do campo foi aceito
@author Rafael Tenorio da Costa
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU183MNPRO()

	Local aArea    := GetArea()
	Local aAreaNUQ := NUQ->( GetArea() )
	Local cMascara := ""
	Local cTipoAS  := ""
	Local cValCnj  := ""
	Local oModel   := FWModelActive()
	Local cNatureza:= ""

	If oModel <> Nil .And. oModel:GetId() == "JURA095"

		//Se for chamado da NSZ posiciona na inst�ncia principal
		If ReadVar() == "M->NSZ_NUMPRO"
			oModel:GetModel("NUQDETAIL"):SeekLine( { {"NUQ_INSATU", "1"} } )
		EndIf

		cTipoAS	  := FwFldGet("NSZ_TIPOAS")
		cNatureza := FwFldGet("NUQ_CNATUR")
	Else

		If IsPesquisa()

			cTipoAS := StrTran( c162TipoAs, "'", "")

			DbSelectArea("NUQ")
			NUQ->( DbSetOrder(2) )	//NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
			If NUQ->( DbSeek(xFilial("NUQ") + NSZ->NSZ_COD + "1") )
				cNatureza := NUQ->NUQ_CNATUR
			EndIf
		EndIf
	EndIf

	//Carrega tipo de formata��o do CNJ
	cValCnj	:= JurGetDados("NQ1", 1, xFilial("NQ1") + cNatureza, "NQ1_VALCNJ")

	//Verifica se deve fazer a validacao do numero do processo CNJ
	If JGetParTpa(cTipoAS, "MV_JNUMCNJ", "2") == "1" .And. ( Empty(cValCnj) .Or. cValCnj == "1" )
		cMascara := "@R XXXXXXX-XX.XXXX.X.XX.XXXX"
	EndIf

	If oModel <> Nil .And. oModel:GetId() == "JURA095"
		cMascara += "%C"
	EndIf

	RestArea( aAreaNUQ )
	RestArea( aArea )

Return cMascara

//-------------------------------------------------------------------
/*/{Protheus.doc} JU183F3NQ6()
Filtro de comarca por UF.
Uso na consulta padr�o de instancias do processo

@return lRet - Informa se a comarca pode ser exibida no F3
@author Jorge Luis Branco Martins Junior
@since 29/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU183F3NQ6()
	Local aArea := GetArea()
	Local cRet  := "@#@#"
	Local cUF   := ""
	Local nLine := 0
	Local oModel, oModelO00

	If !IsPesquisa() .And. IsInCallStack('JURA162')
		cUF := FwFldGet('NUQ_ESTADO')
	ElseIf IsInCallStack('JURA226') //De/Para Comarca CNJ
		oModel    := FwModelActive()
		oModelO00 := oModel:GetModel("O00DETAIL")
		nLine     := oModelO00:GetLine()
		cUF := oModelO00:GetValue('O00_UF', nLine)
	EndIf

	If !Empty(Alltrim(cUF))
		cRet := "@#NQ6->NQ6_UF == '" + cUF + "'@#"
	EndIf

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU183VlNQ6()
Valida��o de comarca por UF.
Uso na consulta padr�o de instancias do processo

@return lRet	- Informa se o valor do campo � v�lido
@author Jorge Luis Branco Martins Junior
@since 29/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU183VlNQ6()
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cUF   := ""

	If !IsPesquisa() .And. IsInCallStack('JURA162')
		cUF := FwFldGet('NUQ_ESTADO')
	EndIf

	If !Empty(Alltrim(cUF))
		lRet := JurGetDados("NQ6",1,XFILIAL("NQ6") + FwFldGet('NUQ_CCOMAR'), "NQ6_UF") == cUF
	EndIf

	RestArea( aArea )

	If !lRet
		// "Registro n�o encontrado."
		// "Verifique se o c�digo da comarca digitado pertence ao estado selecionado."
		JurMsgErro(STR0041, ,STR0042)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_MES(aParam)
Quantidade de meses do processo

@param Processo, Situa��o, Data Encerramento
@return nMeses
@since 06/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function FEXP_MES(aParams)
Local aArea    := GetArea()
Local aMeses   := {}
Local cLista   := GetNextAlias()
Local cQuery   := ""
Local cChave   := ""
Local xRet     := 0
Local lTemFila := JCheckFila()

	If Len(aParams) < 2
		aAdd(aParams, "")
		aAdd(aParams, SubStr(AllTrim(Str(ThreadId())),1,4) )
	EndIf

	cQuery := " SELECT NSZ_FILIAL, "
	cQuery +=        " NSZ_COD, " 
	cQuery +=        " NSZ_SITUAC, " 
	cQuery +=        " NSZ_DTENCE, " 
	cQuery +=        " NUQ_DTDIST "
	cQuery +=   " FROM " + RetSqlName("NSZ") + " NSZ "
	cQuery += " INNER JOIN " + RetSqlName("NUQ") + " NUQ "
	cQuery +=    " ON ( NSZ_FILIAL = NUQ_FILIAL "
	cQuery +=         " AND NSZ_COD = NUQ_CAJURI "
	cQuery +=         " AND NUQ_INSATU = '1' "
	cQuery +=         " AND NUQ.D_E_L_E_T_ = ' ') "

	If lTemFila
		cQuery += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
		cQuery +=   " ON ( NQ3.NQ3_CAJURI = NUQ.NUQ_CAJURI "  
		cQuery +=        " AND NQ3.NQ3_FILORI = NUQ.NUQ_FILIAL "
		cQuery +=        " AND NQ3.NQ3_CUSER  = '"+__CUSERID+"'" 
		cQuery +=        " AND NQ3.NQ3_SECAO  = '" + aParams[3] + "' )"
	EndIf

	cQuery += " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NUQ_DTDIST <> ' ' "

	If aParams[2] != "All" .Or. !lTemFila
		cQuery += " AND NUQ.NUQ_CAJURI = '" + aParams[1] + "'" 
		aParams[2] := "One"
	EndIf

	cQuery += " ORDER BY NSZ_FILIAL, NSZ_COD "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cLista, .T., .T.)

	dbSelectArea(cLista)
	(cLista)->(dbGoTop())

	While (cLista)->(!Eof())
		cChave := (cLista)->NSZ_FILIAL + (cLista)->NSZ_COD

		If (cLista)->NSZ_SITUAC == "2"
			xRet := DateDiffMonth(StoD((cLista)->NSZ_DTENCE), StoD((cLista)->NUQ_DTDIST))
		Else
			xRet :=  DateDiffMonth(Date(), StoD((cLista)->NUQ_DTDIST))
		EndIf

		aAdd(aMeses, {cChave, Str(xRet)})

		(cLista)->(dbSkip())
	End

	(cLista)->( dbcloseArea() )

	aAdd(aMeses, {cChave, xRet})

	If aParams[2] == "All"
		xRet := aMeses
	Else
		xRet := aMeses[1][2]
	EndIf

	RestArea(aArea)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_AND(aParam)
Busca por processo o �ltimo andamento concatenando data + texto
@param Processo
@return nMeses
@since 06/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function FEXP_AND(aParam)
	Local aArea   := GetArea()
	Local lFound  := .T.
	Local cResult := ""
	Local cCajuri := aParam[1]

	If Type("oMainWnd") == "U"
		RPCSetType(3)
		RPCSetEnv("01","01")
	EndIf

	dbSelectArea("NT4")
	NT4->(dbSetOrder(2))

	if NT4->(dbSeek(xFilial("NT4") + cCAJURI))

		While !NT4->(Eof()) .and. lFound
			lFound := NT4->NT4_CAJURI == cCAJURI
			if lFound
				cResult := ""
				cResult := I18N("#1 - #2", {NT4->NT4_DTANDA,NT4->NT4_DESC})
			endif

			NT4->(DbSkip())
		EndDo
	endif

	NT4->(dbcloseArea())
	RestArea(aArea)

return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_OBJ(aParam)
Concatena objetos por processo
@param Processo
@return nMeses
@since 06/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function FEXP_OBJ(aParam)
Local xRet := ""

	xRet := FEXP_PEDC(aParam)

return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183VldCnj()
Verifica se a valida��o CNJ esta ativa

@return lRetorno
@author Rafael Tenorio da Costa
@since 	08/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183VldCnj(cTipoAS, cNatureza)

	Local aArea    := GetArea()
	Local aAreaNQ1 := NQ1->( GetArea() )
	Local cValCnj  := ""
	Local lRetorno := .F.

	Default cTipoAS   := FwFldGet("NSZ_TIPOAS")
	Default cNatureza := FwFldGet("NUQ_CNATUR")

	If Empty(cNatureza)
		lRetorno := .F.
	Else
		//Verifica se o CNJ esta ativo
		cValCnj  := JurGetDados("NQ1", 1, xFilial("NQ1") + cNatureza, "NQ1_VALCNJ")
		lRetorno := JGetParTpa(cTipoAS, "MV_JNUMCNJ", "2") == "1" .And. (Empty(cValCnj) .Or. cValCnj == "1")
	EndIf

	RestArea( aAreaNQ1 )
	RestArea( aArea )

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} J183InAnAu()
X3_RELACAO\X3_WHEN do campo de andamento automatico. NUQ_ANDAUT

@return cRetorno
@author Rafael Tenorio da Costa
@since 	11/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183InAnAu()
	Local cRetorno := "1"

	If !JurAuto() .Or. JModRst()
		//Verifica se o andamento automatico esta ativo 2=Por inst�ncia
		If JGetParTpa(cTipoAsJ, "MV_JANDAUT", "2") == "1" .And. JGetParTpa(cTipoAsJ, "MV_JTPANAU", "1") == "2"
			cRetorno := "2" //2=Por Inst�ncia
		EndIf
	EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JA183F3CNJ( )
Rotina que faz a chamada do processamento da carga inicial

@author Wellington Coelho
@since 08/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA183F3CNJ(lVisualiza,lInclui)
	local lResult   := .F.
	local nResult   := 0
	local cFilter   := ""
	Local cNatureza := ""

	Default lVisualiza := .T.
	Default lInclui    := .T.

	If IsPesquisa()
		cNatureza   := M->NUQ_CNATUR
	Else
		oModel    := FWModelActive()
		cNatureza := oModel:GetValue('NUQDETAIL','NUQ_CNATUR')
	EndIF

	If !Empty(cNatureza) // valida tipo da natureza
		cFilter += " NQU_ORIGEM IN ( "
		cFilter += "  SELECT DISTINCT NQ1_TIPO FROM "+RetSqlName("NQ1")+" NQ1 "
		cFilter += "   WHERE NQ1_FILIAL = '"+xFilial("NQ1")+"'"
		cFilter += "    AND NQ1_COD = '"+cNatureza+"'"
		cFilter += "    AND NQ1.D_E_L_E_T_ = ' ')"
	EndIf

	nResult := JurF3SXB("NQU",{"NQU_DESC","NQU_HRQCNJ"},cFilter, lVisualiza, lInclui)
	lResult := nResult > 0

	if lResult
		DbSelectArea("NQU")
		NQU->(dbgoTo(nResult))
	endif

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J183ADD3N()
Faz o cadastro da vara quando a vara n�o for identificada e o usu�rio
tenha preenchido o campo NUQ_TLOC3N

@param
@return lRet .T./.F. As informa��es s�o v�lidas ou n�o
@author Jorge Luis Branco Martins Junior
@since 28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU183ADD3N(oModelNUQ, cComar, cForo)
	Local lRet       := .T.
	Local cCodVara   := ""
	Local cVara      := AllTrim(oModelNUQ:GetValue("NUQ_TLOC3N"))

	If !Empty(cVara)
		cCodVara := J219IncNQE( cComar, cForo, SubStr( cVara, 1, TamSx3("NQE_DESC")[1] ), @lRet)
	EndIf

	If !Empty(cCodVara)
		cCodVara := AllTrim( cCodVara )

		If !( oModelNUQ:SetValue("NUQ_CLOC3N", cCodVara) )
			lRet := .F.
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183COMEST()
Condi��o dos Gatilhos 003 ao 008 do campo NUQ_ESTADO para limpar os campos da comarca.

@param
@return lRet .T./.F. Se a comarca � do estado ou n�o.
@author Leandro Armellini
@since 08/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183COMEST()
	Local lRet   := .F.
	Local oModel := FWModelActive()

	If oModel:GetValue("NUQDETAIL", "NUQ_ESTADO") = Posicione( 'NQ6', 1, xFilial( 'NQ6') + oModel:GetValue("NUQDETAIL", "NUQ_CCOMAR"), 'NQ6_UF')
		lRet := .F.
	Else
		lRet := .T.
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183StaIns()
Fun��o para pegar o Status da Inst�ncia.
Uso no X3_RELA��O e gatilho do campo NUQ_STATUS.

@author  Rafael Tenorio da Costa
@since   26/09/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Function J183StaIns()

	Local cRet := "1"	//Ativo
	If !INCLUI .And. !Empty(NUQ->NUQ_DTENC)
		cRet := "2"		//Encerrado
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J183RetCor()
Retorna os correspondentes de um determinado processo.

@return  aCorres - Codigo, Loja
@author  Rafael Tenorio da Costa
@since   07/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J183RetCor(cFilPro, cCodPro)

	Local aArea   := GetArea()
	Local aCorres := {}
	Local cQuery  := ""

	cQuery  := " SELECT NUQ_CCORRE, NUQ_LCORRE"
	cQuery  += " FROM " + RetSqlName("NUQ")
	cQuery  += " WHERE NUQ_FILIAL = '" + cFilPro + "'"
	cQuery  += 	 " AND NUQ_CAJURI = '" + cCodPro + "'"
	cQuery	+=	 " AND NUQ_CCORRE > ' '"
	cQuery  += 	 " AND D_E_L_E_T_ = ' '"
	cQuery  += " GROUP BY NUQ_CCORRE, NUQ_LCORRE"

	aCorres := JurSql(cQuery, {"NUQ_CCORRE", "NUQ_LCORRE"})

	RestArea( aArea )

Return aCorres
