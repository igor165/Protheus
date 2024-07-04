#INCLUDE "JURA106A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106A
Follow-ups automáticos

@author Juliana Iwayama Velho
@since 10/08/09
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} J106GFWAUT
Rotina para inclusão automática de follow-ups a partir do follow-up
padrão

@param cAssJur   - Código do assunto jurídico
@param cCodFw    - Código do follow-up
@param dDtFw     - Data do follow-up
@param cTipoFw   - Tipo do follow-up
@param lDtProxEv - Se a data vem do campo prox evento

@author Juliana Iwayama Velho
@since 10/08/09
@version 1.0

@obs NTAMASTER - Dados do Follow-ups
@obs NTEDETAIL - Responsáveis
/*/
//-------------------------------------------------------------------
Function J106GFWAUT(cAssJur, cCodFw, dDtFw, cTipoFw, cCodAnd, cFupPai, cDesc, oModelAct, lDtProxEv)

Local aArea      := GetArea()
Local aAreaNRT   := NRT->( GetArea() )
Local aAreaNRR   := NRR->( GetArea() )
Local aAreaNVD   := NVD->( GetArea() )
Local oModelFw   := NIL
Local oStruct    := FWFormStruct( 1, "NTA" )
Local oStructNTE := FWFormStruct( 1, "NTE" )
Local cQueryR    := ""
Local cAliasR    := GetNextAlias()
Local nI         := 0
Local oAux       := NIL
Local dNvDtFw    := ctod('')
Local aDePara    := {}
Local aDetail    := {}
Local lRet       := .T.
Local aPartiNZ5  := {}
Local nCont      := 0
Local nPosDel    := 0
Local cCodAn     := ''

Default oModelAct  := FWModelActive()
Default cCodAnd    := "" //cod do andamento gerador do fup
Default cFupPai    := "" //cod do fup gerador do andamento ou do próprio fup
Default cDesc      := ""
Default lDtProxEv  := .F.

	//Pega a descrição do Follow-up ou andamento origem.
	If Empty(cDesc)
		If Empty(NTA->NTA_DESC)
			cDesc := NT4->NT4_DESC
		Else 
			cDesc := NTA->NTA_DESC
		EndIf
	EndIf

	//Retira estes campos para não serem apresentada na abertura da view, caso ocorra algum erro na inclusão do fw automático
	oStructNTE:RemoveField("NTE_CFLWP")
	oStructNTE:RemoveField("NTE_CAJURI")

	//campos extras da 106 para o FLUIG.
	oStruct:AddField( ;
					STR0009        , ;     // [01] Titulo do campo   //"Obs Fluig"
					STR0010        , ;     // [02] ToolTip do campo  //"Observacao do Executor Fluig"
					"NTA__OBSER"   , ;     // [03] Id do Field
					"C"            , ;     // [04] Tipo do campo
					200            , ;     // [05] Tamanho do campo
					0              , ;     // [06] Decimal do campo
					NIL            , ;     // [07] Code-block de validação do campo
					NIL            , ;     // [08] Code-block de validação When do campo
					NIL            , ;     // [09] Lista de valores permitido do campo
					.F.            )       // [10] Indica se o campo tem preenchimento obrigatório

	oStruct:AddField( ;
					STR0011       , ;     // [01] Titulo do campo   //"Valor Fluig"
					STR0012	       , ;     // [02] ToolTip do campo  //"Valor aprovacao Fluig"
					"NTA__VALOR"  , ;     // [03] Id do Field
					"N"           , ;     // [04] Tipo do campo
					12            , ;     // [05] Tamanho do campo
					2             , ;     // [06] Decimal do campo
					NIL           , ;     // [07] Code-block de validação do campo
					NIL           , ;     // [08] Code-block de validação When do campo
					NIL           , ;     // [09] Lista de valores permitido do campo
					.F.           )       // [10] Indica se o campo tem preenchimento obrigatório

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModelFw:= MPFormModel():New( "JURA106A", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX| JURA106ACOM(oX)}/*Commit*/,/*Cancel*/)
	oModelFw:AddFields( "NTAMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModelFw:AddGrid( "NTEDETAIL", "NTAMASTER" /*cOwner*/, oStructNTE, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	oModelFw:SetDescription( STR0001 ) // "Modelo de Dados de Follow-ups"
	oModelFw:GetModel( "NTAMASTER" ):SetDescription( STR0002 ) // "Dados de Follow-ups"
	oModelFw:GetModel( "NTEDETAIL" ):SetUniqueLine( { "NTE_CPART" } )

	oModelFw:SetRelation( "NTEDETAIL", { { "NTE_FILIAL", "XFILIAL('NTE')" }, { "NTE_CFLWP", "NTA_COD" },{ "NTE_CAJURI", "NTA_CAJURI" }  }, NTE->( IndexKey( 1 ) ) )
	oModelFw:GetModel( "NTEDETAIL" ):SetDescription( STR0003 ) //"Responsaveis"
	oModelFw:GetModel( "NTEDETAIL" ):SetUseOldGrid( .F. )

	//----------------------------------------
	//Verificação modelo padrão de follow-up para sugerir os campos no fw
	//----------------------------------------

	lRet := .T.

	oModelFw:SetOperation( 3 )
	oModelFw:Activate()

	//Retorna a data do follow-up baseada no modelo do follow-up.
	dNvDtFw := JUR106DTFU(NRT->NRT_DATAT, dDtFw, NRT->NRT_QTDED, lDtProxEv)

	//----------------------------------------
	//Preenche o array com as informações a serem inseridas
	//----------------------------------------
	aDePara := {}
	aAdd( aDePara, { "NTA_CAJURI", cAssJur         } )
	aAdd( aDePara, { "NTA_CTIPO" , NRT->NRT_CTIPOF } )
	aAdd( aDePara, { "NTA_DTORIG", dNvDtFw         } )
	aAdd( aDePara, { "NTA_DTFLWP", dNvDtFw         } )
	aAdd( aDePara, { "NTA_HORA"  , AllTrim(StrTran(NRT->NRT_HORAF ,":","")) } )
	aAdd( aDePara, { "NTA_DURACA", AllTrim(StrTran(NRT->NRT_DURACA,":","")) } )
	aAdd( aDePara, { "NTA_CPREPO", NRT->NRT_CPREPO } )
	//aAdd( aDePara, { "NTA_CADVCR", NRT->NRT_CADVGC } )
	aAdd( aDePara, { "NTA_CRESUL", NRT->NRT_CRESUL } )
	aAdd( aDePara, { "NTA_CATO"  , NRT->NRT_CSUATO } )
	aAdd( aDePara, { "NTA_CFASE" , NRT->NRT_CFASE  } )

	If NRT->NRT_SUGDES == "1" // Sugere descrição do andamento a partir da origem.
		aAdd( aDePara, { "NTA_DESC"  , cDesc } )//Descrição do modelo do followup
	Else
		aAdd( aDePara, { "NTA_DESC"  , NRT->NRT_DESC } )//Descrição do modelo do followup
	EndIf

	If IsInCallStack('JURA100COM') .and. Empty(cCodFw)
		cCodFw := cFupPai
		cCodAn := oModelFw:GetValue("NTAMASTER","NTA_CANDAM")
		If IsInCallStack('JURA100COM') .and. Empty(cCodFw) .and. !Empty(cCodAnd)
			cCodAn:= cCodAnd
		EndIF
	EndIf

	aAdd( aDePara, { "NTA_CANDAM", cCodAn          } )
	aAdd( aDePara, { "NTA_CFLWPP", cCodFw          } )

	// alternativa para preencher o campo de assunto jurídico, estando ele desabilitado para edição
	nPosCAJURI := aScan( oModelFw:AMODELSTRUCT[1][3]:OFORMMODELSTRUCT:AFIELDS , { |aX| aX[3] == "NTA_CAJURI" } )
	bBkpBl := oModelFw:AMODELSTRUCT[1][3]:OFORMMODELSTRUCT:AFIELDS[nPosCAJURI][8]
	oModelFw:AMODELSTRUCT[1][3]:OFORMMODELSTRUCT:AFIELDS[nPosCAJURI][8] := NIL
	oModelFw:SetValue("NTAMASTER",aDePara[1][1],aDePara[1][2])
	oModelFw:AMODELSTRUCT[1][3]:OFORMMODELSTRUCT:AFIELDS[nPosCAJURI][8] := bBkpBl

	For nI := 2 To Len( aDePara )
		If !oModelFw:SetValue("NTAMASTER",aDePara[nI][1],aDePara[nI][2])
			lRet := .F.
			JurMsgErro( STR0004 + aDePara[nI][1] + STR0005 + AllToChar( aDePara[nI][2] ) ) // "Erro ao incluir follow-up: Campo = " " Conteúdo = "
			Exit
		EndIf
	Next

	//----------------------------------------------------------------
	//Atualiza as variáveis para utilizar na inclusão do próximo nível
	//----------------------------------------------------------------
	cTipoFw := NRT->NRT_CTIPOF
	cCodFw  := oModelFw:GetValue("NTAMASTER","NTA_COD")

	//----------------------------------------
	//Verifica se há configuração no modelo para múltiplos responsáveis
	//----------------------------------------
	If lRet

		DbSelectArea("RD0")
		cQueryR := ChangeQuery ( JURA106NRR(NRT->NRT_COD) )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryR),cAliasR,.T.,.F.)

		(cAliasR)->( dbSelectArea( cAliasR ) )
		(cAliasR)->( dbGoTop() )

		nCt := 0

		oAux := oModelFw:GetModel( "NTEDETAIL" )
		aDetail := {}

		While !(cAliasR)->( EOF() )

			nCt++

			If nCt > 1
				If oAux:AddLine() <> nCt
					lRet := .F.
					JurMsgErro( STR0006 ) // "Erro ao incluir follow-up: Linha da Grid"
					Exit
				EndIf
			EndIf

			If !(lRet := oAux:SetValue("NTE_CPART", (cAliasR)->NRR_CPART))

				//Valida participante
				lRet := J106aVlPar(cAssJur, (cAliasR)->NRR_CPART, @oModelFw)

				If !lRet
					aAdd( aDetail, {"NTE_CPART", (cAliasR)->NRR_CPART})
					Exit
				EndIf
			EndIf

			If lRet
				If !(lRet := oAux:LoadValue("NTE_SIGLA", Alltrim((cAliasR)->NRR_SIGLA) ) )
					JurMsgErro( STR0004 + "NTE_SIGLA" + STR0005 + AllToChar( (cAliasR)->NRR_SIGLA ) ) // "Erro ao incluir follow-up: Campo = " " Conteúdo = "
					aAdd( aDetail, { "NTE_SIGLA", (cAliasR)->NRR_SIGLA } )
					Exit
				EndIf
			EndIf

			(cAliasR)->( dbSkip() )
		End

		(cAliasR)->(dbCloseArea())

		If lRet

			//Carrega os participantes relacionados a tabela NZ5
			aPartiNZ5 := JURA106NZ5( NRT->NRT_COD, oModelFw:GetValue("NTAMASTER", "NTA_CAJURI") )

			//Remove participantes do array aPartiNZ5 que ja estao no grid
			If Len(aPartiNZ5) > 0 .AND. !Empty( oModelFw:GetValue("NTEDETAIL", "NTE_CPART") )

				For nCont:=1 To oAux:GetQtdLine()

					oAux:GoLine( nCont )

					If !oAux:IsDeleted()

						nPosDel := 1
						While nPosDel > 0

							nPosDel := Ascan(aPartiNZ5, { |x| x[1] == oModelFw:GetValue("NTEDETAIL" ,"NTE_CPART") } )
							If nPosDel > 0
								Adel( aPartiNZ5, nPosDel)
								Asize( aPartiNZ5, Len(aPartiNZ5) - 1)
							EndIf
						EndDo
					EndIf
				Next nCont
			EndIf

			//Carrega grid com participantes da NZ5
			For nCont:=1 To Len(aPartiNZ5)

				If !Empty( oModelFw:GetValue("NTEDETAIL", "NTE_CPART") )
					oAux:AddLine()
				EndIf

				If !( lRet := oAux:SetValue("NTE_CPART", aPartiNZ5[nCont][1]) )

					//Valida participante
					lRet := J106aVlPar(cAssJur, aPartiNZ5[nCont][1], @oModelFw)

					If !lRet
						aAdd( aDetail, { "NTE_CPART", aPartiNZ5[nCont][1] } )
						Exit
					EndIf
				EndIf

				If lRet
					If !( lRet := oAux:LoadValue("NTE_SIGLA", Alltrim( aPartiNZ5[nCont][2] ) ) )
						JurMsgErro( STR0004 + "NTE_SIGLA" + STR0005 + AllToChar( aPartiNZ5[nCont][2] ) )	// "Erro ao incluir follow-up: Campo = " " Conteúdo = "
						aAdd( aDetail, { "NTE_SIGLA", aPartiNZ5[nCont][2] } )
						Exit
					EndIf
				EndIf

			Next nCont
		EndIf

		If	 lRet
			If ( lRet := oModelFw:VldData() )

				oModelFw:CommitData()

				If __lSX8
					ConfirmSX8()
				EndIf

			EndIf
		EndIf

	EndIf

	If !lRet
		If !IsBlind()
			//Limpa mensagem de erro para nao ser apresentada novamente na abertura da tela de follow-up
			For nCont:=1 To Len(oModelFw:AERRORMESSAGE)
				oModelFw:AERRORMESSAGE[nCont] := ""
			Next nCont

			If (FWExecView(STR0003,'JURA106',3,,{||lRet := .T.},,,,,,,oModelFw) == 1)
				lRet := .T.
			EndIf

			//determina se houve erro na inclusão do followup para avisar a rotina de conciliação.
			if valtype("__JurConErr") != "U"
				__JurConErr := .T.
			EndIf
		Else
			aErro := oModelFw:GetErrorMessage()
			JurMsgErro( aErro[6], 'JURA106A' )
		Endif
	EndIf


	//-----------------------------------------
	//Rotina para verificar o próximo nível
	//-----------------------------------------
	NVD->( dbSetOrder( 1 ) )
	NVD->( dbSeek( xFilial( 'NVD' ) + cTipoFw ) )

	While !NVD->( EOF() ) .And. xFilial( 'NVD' ) + cTipoFw == NVD->NVD_FILIAL + NVD->NVD_CTIPOF

		NRT->( dbSetOrder( 2 ) )

		If NRT->( dbSeek( xFilial( 'NRT' ) + NVD->NVD_CTFPAD + '1') )

			lRet := J106GFWAUT(cAssJur, cCodFw, dNvDtFw, NRT->NRT_CTIPOF, cCodAnd, cFupPai, cDesc, oModelFw, lDtProxEv)

		ElseIf NRT->( dbSeek( xFilial( 'NRT' ) + NVD->NVD_CTFPAD + '2') )

			JA106GFWIU(cAssJur, cCodFw, dNvDtFw , NRT->NRT_CTIPOF, cCodFw, lDtProxEv, cCodAnd )

		EndIf

		NVD->( dbSkip() )

	End

	oModelFw:DeActivate()
	oModelFw:Destroy()
	oModelFw := Nil

	//Voltar ao modelo que chamou esta função
	FwModelActive(oModelAct, .T.)

	RestArea( aAreaNRT )
	RestArea( aAreaNRR )
	RestArea( aAreaNVD )
	RestArea( aArea )

	FWFreeObj(oStruct)
	FWFreeObj(oStructNTE)
	FWFreeObj(oAux)
	FWFreeObj(aDePara)
	FWFreeObj(aDetail)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAINCFWAUT(oModel)
Função utilizada para incluir follow-up automatico a partir do cadastro de follow-up automatico (JURA250)
Uso Geral.
@Param cTpMov  - Tipo de Movimentação (1=Inclusao processo;2=Alteração Correspondente; 
									  3=Audiência Distribuição; 4=Alteração Responsável) 
@Param cCajuri   - ID do processo
@Param cCobjet   - Código do objeto(assunto) do processo 
@Param cCareaj   - Código da área jurídica 
@Param cTpAss    - Tipo de Assunto jurídico 
@Param dDataAudi - Data da audiência 
@Param cHoraAudi - Hora da audiência

@author Beatriz Gomes Alves
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAINCFWAUT(cTpMov, cCajuri, cCobjet, cCareaj, cTpAss, dDataAudi, cHoraAudi)

Local cQrySelect  := ""
Local cQryFrom    := ""
Local cQryWhere   := ""
Local cQuery      := ""
Local aArea       := GetArea()
Local cAlias      := GetNextAlias()
Local oModel106   := Nil
Local aErro       := {}
Default dDataAudi := SToD("")
Default cHoraAudi := ""

	//Verifica se há as tabelas O0J E O0K
	If FWAliasInDic("O0J") .AND. FWAliasInDic("O0K")

		cQrySelect := "SELECT O0J.O0J_COD COD, "
		cQrySelect +=        "O0K.O0K_CODMOD CODMOD, "
		cQrySelect +=        "O0K.O0K_CODMOV MOVI "

		cQryFrom   := "FROM "  + RetSqlName('O0J') + " O0J INNER JOIN " + RetSqlName('O0K') +" O0K ON (O0K.O0K_CFWAUT = O0J.O0J_COD
		cQryFrom   +=                                                                        " AND O0K.O0K_CODMOV = '"+ cTpMov +"'"
		cQryFrom   +=                                                                        " AND O0K.O0K_FILIAL ='" + xFilial('O0K')+ "'"
		cQryFrom   +=                                                                        " AND O0K.D_E_L_E_T_ = '')"

		cQryWhere  := " WHERE O0J.O0J_FILIAL = '" + xFilial('O0J')+ "'"
		cQryWhere  += " AND O0J.O0J_TIPOAS IN ('','"+ cTpAss +"')"
		cQryWhere  += " AND O0J.O0J_CAREAJ IN ('','"+cCareaj+"')"
		cQryWhere  += " AND O0J.O0J_COBJET IN ('','"+cCobjet+"')"
		cQryWhere  += " AND O0J.D_E_L_E_T_ = ' ' "

		cQuery := cQrySelect + cQryFrom + cQryWhere

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		//Carrega o model de follow-up apenas 1 vez
		If !(cAlias)->( Eof() )
			oModel106 := FWLoadModel("JURA106")
		Else
			aErro := {.F.}
		EndIf

		While !(cAlias)->( Eof() )

			//Gera follow-up a partir do modelo
			aErro := J106aFwMod(xFilial("NSZ"), cCajuri, (cAlias)->CODMOD, oModel106, dDataAudi, cHoraAudi)

			If Len(aErro) > 0
				Exit
			Else
				aErro := {.T.}
			EndIf

			(cAlias)->( DbSkip() )
		End

		//Destroy model de follow-up
		If oModel106 <> Nil
			oModel106:Destroy()
		EndIf

		(cAlias)->( dbcloseArea() )
	Else
		aErro := {.F.}
	EndIf

	RestArea(aArea)

Return aErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J106aFwMod
Inclui follow-up a partir do modelo.

@param 	 cFilPro  	- Filial do processo para o qual o follow-up será gerado
@param 	 cCodPro	- Código do processo para o qual o follow-up será gerado
@param 	 cCodMod  	- Código do modelo que será utilizado para gerar o follow-up
@param 	 oModel106 	- Modelo do JURA106 ja carregado para otimizar a performance
@param 	 dDataAudi  - Seta a data da audiência
@param 	 cHoraAudi  - Seta a hora da audiência

@return	 aErro		- Array com as mensagens de erro do modelo JURA106

@author  Rafael Tenorio da Costa
@since 	 20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106aFwMod(cFilPro, cCodPro, cCodMod, oModel106, dDataAudi, cHoraAudi )

Local aArea    	:= GetArea()
Local aAreaNRT 	:= NRT->( GetArea() )
Local dDataFw	:= dDataBase
Local aNTA		:= {}
Local aNTE		:= {}
Local nCont 	:= 0
Local lRet		:= .F.
Local aErro		:= {}
Local lDestroy  := .F.
Local oModelNTA	:= Nil
Local oModelNTE	:= Nil
Local cDesc     := Iif(Empty(NTA->NTA_DESC),NT4->NT4_DESC,NTA->NTA_DESC)

Default dDataAudi := Stod("")
Default cHoraAudi := ''

	DbSelectArea("NRT")
	NRT->( DbSetOrder(1) )	//NRT_FILIAL + NRT_COD
	If !Empty(cCodMod) .And. NRT->( DbSeek(xFilial("NRT") + cCodMod) )

		//Se for intervenção de usuario e estiver utilizando a rotina automatica ele pula
		If NRT->NRT_TIPOGF == "2" .And. JurAuto()
			JurConout( I18n(STR0015, {cCodMod}) )	//"Não será gerado o follow-up automático, porque o modelo de follow-up #1 está configurado para Intervenção de Usuário e esta sendo utilizada uma rotina automática que não permite interação do usuário."
		Else

			// Seta a data da audiência
			If (Empty(dDataAudi))
				//Retorna a data do follow-up baseada no modelo do follow-up.
				dDataFw := JUR106DTFU(NRT->NRT_DATAT, dDataFw, NRT->NRT_QTDED)
			Else
				dDataFw := IIF(valType(dDataAudi) == "C", SToD(dDataAudi), dDataAudi)
			EndIf

			// Tratamento para data retroativa
			If (dDataFw < dDataBase) .And. (SuperGetMV("MV_JTRFWDR") == "1")
				dDataFw := dDataBase
			EndIf

			cHoraAudi := IIF( Empty(cHoraAudi), NRT->NRT_HORAF, cHoraAudi)

			//Se não for intervenção de usuário
			If NRT->NRT_TIPOGF <> "2"
				Aadd(aNTA, {"NTAMASTER", "NTA_CAJURI", cCodPro     } )
			Endif

			Aadd(aNTA, {"NTAMASTER", "NTA_CTIPO" , NRT->NRT_CTIPOF } )
			Aadd(aNTA, {"NTAMASTER", "NTA_DTORIG", dDataFw         } )
			Aadd(aNTA, {"NTAMASTER", "NTA_DTFLWP", dDataFw         } )
			Aadd(aNTA, {"NTAMASTER", "NTA_HORA"  , AllTrim( StrTran(cHoraAudi , ":", "") ) } )
			Aadd(aNTA, {"NTAMASTER", "NTA_DURACA", AllTrim( StrTran(NRT->NRT_DURACA, ":", "") ) } )
			Aadd(aNTA, {"NTAMASTER", "NTA_CPREPO", NRT->NRT_CPREPO } )
			Aadd(aNTA, {"NTAMASTER", "NTA_CADVCR", NRT->NRT_CADVGC } )
			Aadd(aNTA, {"NTAMASTER", "NTA_CRESUL", NRT->NRT_CRESUL } )
			Aadd(aNTA, {"NTAMASTER", "NTA_CATO"  , NRT->NRT_CSUATO } )
			Aadd(aNTA, {"NTAMASTER", "NTA_CFASE" , NRT->NRT_CFASE  } )

			//Descrição do follow-up
			//1=Andamento/Follow-up origem
			If NRT->NRT_SUGDES == "1" .And. ( IsInCallStack("JURA020") .Or. IsInCallStack("JURA100COM") )
				Aadd(aNTA, {"NTAMASTER", "NTA_DESC", cDesc } )
			
			Else //2= Modelo
				Aadd(aNTA, {"NTAMASTER", "NTA_DESC", NRT->NRT_DESC} )
			EndIf

			//Busca os responsaveis cadastrados no modelo
			aNTE := J106aReMod(cCodMod, cCodPro)

			//Carrega modelo do follow-up caso não seja passado
			If oModel106 == Nil
			   	lDestroy  := .T.
				oModel106 := FWLoadModel("JURA106")
			EndIf
			oModel106:SetOperation(MODEL_OPERATION_INSERT)

			//Se não for intervenção de usuário
			If NRT->NRT_TIPOGF <> "2"
				oModelNTA := oModel106:GetModel("NTAMASTER")
				oModelNTA:GetStruct():SetProperty("*", MODEL_FIELD_NOUPD, .F.)
				oModelNTA:GetStruct():SetProperty("*", MODEL_FIELD_WHEN , {|| .T.} )

				oModelNTE := oModel106:GetModel("NTEDETAIL")
				oModelNTE:GetStruct():SetProperty("*", MODEL_FIELD_NOUPD, .F.)
				oModelNTE:GetStruct():SetProperty("*", MODEL_FIELD_WHEN , {|| .T.} )
			EndIf

			oModel106:Activate()

			//Setando valores no follow-up
			For nCont:=1 To Len(aNTA)
				If !( lRet := oModel106:SetValue(aNTA[nCont][1], aNTA[nCont][2], aNTA[nCont][3]) )
					Exit
				EndIf
			Next nCont

			//Setando os responsaveis vindos do modelo
			If lRet

				For nCont:=1 To Len(aNTE)
					If nCont > 1
						oModel106:GetModel("NTEDETAIL"):AddLine()
					EndIf

					If !( lRet := oModel106:SetValue("NTEDETAIL", "NTE_SIGLA", aNTE[nCont][2]) )
						Exit
					EndIf
				Next nCont
			EndIf

			//Incluii follow-up automático
			//Com intervenção de usuário
			If NRT->NRT_TIPOGF == "2"
				lRet := ( FWExecView(STR0001, "JURA106", 3, , {||.T.}, , , , , , , oModel106) == 0 )	//"Incluir"

			//Automatico
			Else
				If !oModel106:VldData() .Or. !oModel106:CommitData()
					lRet := .F.
				EndIf
			EndIf

			//Pega erro
			If !lRet
				aErro := oModel106:GetErrorMessage()
			EndIf

			oModel106:DeActivate()

			If lDestroy
				oModel106:Destroy()
			EndIf
		EndIf
	EndIf

	Asize(aNTE, 0)
	Asize(aNTA, 0)

	RestArea(aAreaNRT)
	RestArea(aArea)

Return aErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J106aReMod(cCodMod)
Retorna um array com os participantes responsáveis pelo follow-up,
cadastrados no modelo.

@param cCodMod - Código do modelo
@param cCodPro - Código do assunto jurídico

@return aSiglas - array com os responsaveis {}CODIGO, SIGLA}

@author  Rafael Tenorio da Costa
@since 	 23/04/18
@version 2.0
/*/
//-------------------------------------------------------------------
Function J106aReMod(cCodMod, cCodPro)

	Local aArea  	:= GetArea()
	Local cAlias 	:= GetNextAlias()
	Local aSiglas 	:= {}
	Local cSQL   	:= ""

	//Carrega os participantes da tabela NZ5 - Outros Responsáveis follow-up padrão
	If !Empty(cCodMod) .And. !Empty(cCodPro)
		aSiglas := JURA106NZ5(cCodMod, cCodPro)
	EndIf

	//Carrega os participantes da tabela NRR - Responsáveis modelo follow-up
	cSQL  := " SELECT RD0_CODIGO, RD0_SIGLA, RD0_NOME"
	cSQL  += " FROM " + RetSqlname("NRR") + " NRR INNER JOIN " + RetSqlname("RD0") + " RD0"
	cSQL  +=	" ON NRR_FILIAL = RD0_FILIAL AND NRR_CPART = RD0_CODIGO"
	cSQL  += " WHERE NRR_FILIAL = '" + xFilial("NRR") + "'"
	cSQL  +=   " AND NRR_CFOLWP = '" + cCodMod + "'"
	cSQL  +=   " AND NRR.D_E_L_E_T_ = ' '"
	cSQL  +=   " AND RD0.D_E_L_E_T_ = ' '"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cSQL), cAlias, .T., .F.)

	While !(cAlias)->( Eof() )

		If Ascan(aSiglas, {|x| x[1] == (cAlias)->RD0_CODIGO .And. x[2] == (cAlias)->RD0_SIGLA} ) == 0
			Aadd(aSiglas, {(cAlias)->RD0_CODIGO, (cAlias)->RD0_SIGLA})
	  	EndIf

		(cAlias)->( DbSkip() )
	End

	(cAlias)->( DbcloseArea() )

	RestArea(aArea)

Return aSiglas

//-------------------------------------------------------------------
/*/{Protheus.doc} JADESCMOD(cCodMod)
Retorna o tipo de geração do Fup e o tipo fup do modelo incluido na linha

@param cCodMod  Código do modelo

@Return cDesc Informação concatenada (Automático/Intervenção + Tipo Fup)

@author Beatriz Gomes
@since 30/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JADESCMOD(cCodMod)
Local cDesc  := ''
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

	If !Empty(cCodMod)
		cSQL  := "SELECT NRT.NRT_TIPOGF TIPOGF,"
		cSQL  +=       " NRT.NRT_CTIPOF TIPOF, "
		cSQL  +=       " NQS.NQS_DESC DESCR "
		cSQL  += "FROM "+ RetSqlname('NRT') +" NRT "
		cSQL  +=        "INNER JOIN " + RetSqlName('NQS') + " NQS ON (NQS.NQS_COD = NRT.NRT_CTIPOF "
		cSQL  +=              " AND NQS.NQS_FILIAL = '" + xFilial('NQS') + "' "
		cSQL  +=              " AND NQS.D_E_L_E_T_ = ' ') "
		cSQL  += " WHERE NRT.D_E_L_E_T_ = ' ' "
		cSQL  +=   " AND NRT.NRT_FILIAL = '" + xFilial('NRT') + "' "
		cSQL  +=   " AND NRT.NRT_COD = '" + cCodMod + "' "

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

		If (cAlias)->TIPOGF == '1'
			cDesc := STR0013 + " - " + AllTrim((cAlias)-> DESCR)
		Else
			cDesc := STR0014 + " - " + AllTrim((cAlias)-> DESCR)
		EndIf

		(cAlias)->( dbcloseArea() )

		RestArea(aArea)
	EndIF
Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} J106aVlPar()
Validações do participante

@param 	cCajuri  - Código do processo
@param 	cParte 	 - Código do participante
@param	oModelFw - Modelo do JURA106 - Follow-up
@return lRetorno - Retorna se houve erro no participante

@author  Rafael Tenorio da Costa
@since   07/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J106aVlPar(cCajuri, cParte, oModelFw)

	Local aArea    := GetArea()
	Local aAreaRD0 := RD0->( GetArea() )
	Local lRetorno := .F.
	Local cMsgErro := ""
	Local oModAux  := oModelFw:GetModel("NTEDETAIL")

	RD0->( DbSetOrder(1) )	//RD0_FILIAL+RD0_CODIGO

	If RD0->( FieldPos("RD0_MSBLQL") ) > 0 .And. RD0->( DbSeek(xFilial("RD0") + cParte) ) .And. RD0->RD0_MSBLQL == "1"

		//Define se permite participante inátivo
		If ExistBlock("JuParIna")

			lRetorno := ExecBlock("JuParIna", .F., .F., {cCajuri , RD0->RD0_SIGLA})

			If ValType(lRetorno) <> "L"
				lRetorno := .F.
			EndIf
		EndIf

		If lRetorno
			//Limpa mensagem de erro do modelo
			oModelFw:GetErrorMessage(.T.)

			oModAux:LoadValue("NTE_SIGLA", RD0->RD0_SIGLA )
			oModAux:LoadValue("NTE_CPART", RD0->RD0_CODIGO)
			oModAux:LoadValue("NTE_DPART", RD0->RD0_NOME  )
		Else

			cMsgErro := I18N(STR0007, {AllTrim(RD0->RD0_SIGLA) + " - " + AllTrim(RD0->RD0_NOME)})	//"O responsável do Follow-up #1 está inativo."
		EndIf
	Else

		cMsgErro := STR0004 + "NTE_CPART" + STR0005 + AllToChar(cParte)								//"Erro ao incluir follow-up: Campo = " " Conteúdo = "
	EndIf

	If !Empty(cMsgErro)
		JurMsgErro(cMsgErro)
	EndIf

	RestArea(aAreaRD0)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106ACOM
Salva as informações do follow-up automático e faz as verificações de inclusão/alteração
automática e de intervenção de usuário

@param 	oModel  	Model a ser verificado

@Return .T.

@since 20/11/2020
/*/
//-------------------------------------------------------------------
Static Function JURA106ACOM(oModel)

Local aArea       := GetArea()
Local aAreaNQS    := NQS->( GetArea() )
Local nOpc        := oModel:GetOperation()

	FWFormCommit(oModel)

	If nOpc == 3
		NQS->( dbSetOrder( 1 ) ) //NQS_FILIAL+NQS_COD
		If NQS->( dbSeek( xFilial( 'NQS' ) + FwFldGet( 'NTA_CTIPO' ) ) )
			//Se sugere andamento e for inclusão, verifica se o resultado do tipoFup esta vazio ou se estão iguais
			If NQS->NQS_SUGERE == '1' .And.;
				( nOpc == 3 .AND.;
				  (Empty(NQS->NQS_CRESUL) .OR. NQS->NQS_CRESUL == FwFldGet( 'NTA_CRESUL' ))) 
				
				JA106IncAn( nOpc,oModel )
			EndIf

		EndIf
	EndIf

	RestArea( aAreaNQS )
	RestArea( aArea )

Return .T.
