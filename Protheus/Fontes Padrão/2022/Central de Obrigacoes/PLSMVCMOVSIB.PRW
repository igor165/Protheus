#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#DEFINE PDTE_VALID     "1" // Pendente Validação
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO       "3" // Inválido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado

#DEFINE SIB_INCLUIR    "1" // Incluir
#DEFINE SIB_RETIFIC    "2" // Retificar
#DEFINE SIB_MUDCONT    "3" // Mud.Contrat
#DEFINE SIB_CANCELA    "4" // Cancelar
#DEFINE SIB_REATIVA    "5" // Reativar

#DEFINE JOB_VALID		"1" // Job Validacao
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCMOVSIB

Visualização de movimentações SIB

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMOVSIB()

	Local oMark	     := Nil
	Local cFiltro 	 := 	""
	Local cFilterCan := StrTran(cFiltro, "B3X_STATUS $ '1,2,3,5'","B3X_STATUS $ '1,2,3,5,7'")
	local cMarca     :=""
	Private dDatIni  := cToD("01/" +  B3D->B3D_CODIGO + "/"+ B3D->B3D_ANO )
	Private dDatAte  := Lastday(dDatIni)
	private nCount   := 0

	cFiltro := 	" B3X_FILIAL 	 = xFilial( 'B3X' ) .AND. " +;
		" ( " +;
		"		( DTOS(B3X_DATA) >= '" + DTOS(dDatIni) + "' .AND. DTOS(B3X_DATA) <='" + DTOS(dDatAte) + "' ) .OR. "+;
		"		( DTOS(B3X_DATA) <= '" + DTOS(dDatAte) + "' .AND. B3X_STATUS $ '1,2,3,5' ) " +;
		" ) "

	If B3X->(FieldPos("B3X_CODOPE")) > 0
		cFiltro += " .AND. B3X_CODOPE == B3D->B3D_CODOPE "
	EndIf

	If B3D->B3D_TIPOBR == "2" //Sib
		oMark := FWMarkBrowse():New()
		oMark:SetAlias('B3X')
		oMark:SetDescription("Movimentações SIB") //Produtos
		oMark:SetFieldMark("B3X_MARK") //Produtos
		oMark:SetMenuDef( 'PLSMVCMOVSIB' )
		oMark:SetProfileID( 'MOV1' )
		oMark:SetAllMark({|| MsgRun("Selecionando Movimentações","Movimentações SIB",{||SetMrkAll(oMark,'B3X',"B3X_MARK")})})

		oMark:ForceQuitButton()
		oMark:DisableDetails()
		oMark:SetWalkthru(.F.)
		oMark:SetAmbiente(.F.)
		oMark:AddFilter('Exib.Cancelados',cFilterCan,.F.,.F.,,)
		oMark:SetFilterDefault(cFiltro)
		oMark:AddLegend("B3X->B3X_STATUS == '7'", "RED"  , "Não Ativo")
		oMark:AddLegend("B3X->B3X_STATUS != '7'", "GREEN", "Ativo")
		oMark:Activate()

		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Movimen. SIB", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		cMarca := oMark:Mark()

		If cMarca == nil .and. oMark:cMark <> nil
			cMarca := oMark:cMark
		Endif

		If cMarca <> nil
			// Desmarca tudo que foi marcado. Devido ao controle de semaforo do FWMarkBrowse não podemos usar
			// O update direto no banco.
			cSql := "Select R_E_C_N_O_ RECNO FROM "+RetSqlName("B3X")+" WHERE B3X_FILIAL = '"+xFilial("B3X")+"' "
			cSql += "AND B3X_MARK = '"+cMarca+"' "
			cSql += "AND D_E_L_E_T_ = ' '"
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB3X1",.F.,.T.)
			While !TRBB3X1->( Eof() )
				B3X->( dbGoto(TRBB3X1->RECNO) )

				// Desmarca
				oMark:MarkRec()

				TRBB3X1->( dbSkip() )
			Enddo
			TRBB3X1->( dbCloseArea() )
		Endif

	Else
		Alert("Operação não disponível para este tipo de obrigação.")
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina 	:= {}

	ADD OPTION aRotina Title 'Visualizar' 			         Action 'VIEWDEF.PLSMVCMOVSIB'		               OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Val. Moviment.' 	             Action 'CenVldMov()'				               OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Críticas' 				     Action 'PlCenCriOpe'				               OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Cancelar Mvto' 		         Action "PLMVTOMF('7')"			                   OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Exibir/Ocultar Cancelados'     Action "SHOWCANC()"			                   OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Reativar Mvto' 		         Action "PLMVTOMF('1')"                            OPERATION 4 ACCESS 0

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o conjunto B3X e B3X

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB3X 	:= FWFormStruct( 1, 'B3X' )
	Local oModel  	:= MPFormModel():New( 'PLSMVCMOVSIB' )

	oModel:AddFields( 'B3XMASTER', /*cOwner*/ , oStruB3X )
	oModel:SetDescription( 'Compromissos' )
	oModel:GetModel( 'B3XMASTER' ):SetDescription( "Movimentações SIB" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3X e B3X

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel( 'PLSMVCMOVSIB' )
	Local oStruB3X 			:= FWFormStruct( 2, 'B3X' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3X', oStruB3X, 'B3XMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B3X', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B3X', "Movimentações SIB" )
Return oView


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCOMPMF

Rotina que centraliza as regras de mudanca de fase de um compromisso

@param cStatus	 Status em que quero colocar o compromisso

@return lRet	Indica se atualizou .T. ou nao .F. o status

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLMVTOMF(cStatusSeg,lManual)

	Local lRet       := .T.
	Local lRevertMov := GetNewPar("MV_PLREVMO",.T.)
	local aMarkCanc  := {}
	local cMsg       := ''
	local nMarks     := 0
	Local cMarca     := ''
	Local lAuto      := IsBlind()
	Local aArea	     := GetArea()
	Local aAreaB3K   := B3K->(GetArea())
	Local aAreaB3X   := B3X->(GetArea())

	DEFAULT cStatusSeg := PDTE_VALID
	DEFAULT	lManual := .T. //Indica se o status está sendo alterado por JOB ou pela rotina da central

	iif(lManual,cMarca := oMark:Mark(), cMarca := '')

	If lAuto
		cMarca:="88"
	Endif

	B4W->(DbSetOrder(1))

	cStatusAtual := B3X->B3X_STATUS
	//1=Pendente Envio;2=Enviado ANS;3=Criticado;4=Acatado ANS;5=Cancelado
	If cStatusSeg == ""

		lRet := .F.
		cMensagem := "Informe o status"
		Help( ,, 'HELP',,  cMensagem, 1, 0)

	ElseIf (cStatusSeg == CANCELADO .AND. (!(cStatusAtual $ PDTE_VALID+","+VALIDO+","+INVALIDO+","+CRIT_ANS) ) ) .OR.;
			(cStatusSeg $ PDTE_VALID+","+VALIDO+","+INVALIDO .AND. !(cStatusAtual $ CANCELADO ) )

		lRet := .F.
		cMensagem := "Não é permitido passar do Status " + X3COMBO("B3X_STATUS",cStatusAtual) ;
			+ " para o Status " + X3COMBO("B3X_STATUS",cStatusSeg)
		Help( ,, 'HELP',,  cMensagem, 1, 0)

	Else

		aMarkCanc:=BusMovMar(cMarca)

		If lAuto
			aAdd(aMarkCanc,{B3X->B3X_BENEF,B3X->(RECNO())})
		EndIf

		If lAuto .Or. (Len(aMarkCanc)==0 .And. lManual)
			If cStatusSeg == "1"
				IIF(!lAuto,MsgInfo("Marque os beneficiários que deseja Reativar."),"")
			Else
				IIF(!lAuto,MsgInfo("Marque os beneficiários que deseja Cancelar."),"")
			Endif
			lRet :=.F.
		Endif

		RestArea(aAreaB3X)

		If lRet
			If len(aMarkCanc) > 0
				cMsg := 'Deseja mudar o status dos beneficiários selecionados para ' + X3COMBO("B3X_STATUS",cStatusSeg) + ' ?'
			Else
				cMsg := "Deseja mudar o status de " + X3COMBO("B3X_STATUS",cStatusAtual) + " para " + X3COMBO("B3X_STATUS",cStatusSeg) + ' ?'
			EndIf
		Endif

		aAreaB3X := B3X->(GetArea())

		//Perguntar ao usuario se deseja continuar
		If lAuto .Or. (lRet .And. (!lManual .OR. ApMsgNoYes ("Deseja mudar o status de " + X3COMBO("B3X_STATUS",cStatusAtual) + ;
				" para " + X3COMBO("B3X_STATUS",cStatusSeg) ,"Central de Obrigações")))

			For nMarks := 1 to len(aMarkCanc)
				BEGIN TRANSACTION

					B3K->(DbGoto(aMarkCanc[nMarks][1]))
					B3X->(DbGoto(aMarkCanc[nMarks][2]))
					If lRevertMov .AND. (B3X->B3X_OPERA == SIB_CANCELA .OR. B3X->B3X_OPERA == SIB_REATIVA)
						cTipo := IIf(B3X->B3X_OPERA == SIB_CANCELA,"0","1") //0=Bloqueio;1=Desbloqueio
						cStHist := IIf(cStatusSeg == CANCELADO,"0","1") //0=Cancelado;1=Ativo


						If B4W->(MsSeek(xFilial("B4W")+PADR(B3K->B3K_MATRIC,tamSX3("B4W_MATRIC")[1])+DTOS(B3X->B3X_DATA)+cTipo+B3X->B3X_HORA ) )
							RecLock("B4W",.F.)
							B4W->B4W_STATUS = cStHist
							B4W->(MsUnlock())
						EndIf

						AjusData(B3K->B3K_MATRIC, cTipo)

					EndIf

					Reclock("B3X",.F.)
					B3X->B3X_STATUS := cStatusSeg
					MsUnlock()

					If B3X->B3X_OPERA $ "" + SIB_CANCELA + ","+ SIB_REATIVA
						CnBlReaPdte(B3X->B3X_BENEF)
						PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),B3K->B3K_CODOPE,cEmpAnt,Nil,JOB_VALID,{},,,B3X->B3X_BENEF)
					EndIf

				END TRANSACTION
			Next nMarks
		EndIf

	EndIf

	RestArea(aArea)
	RestArea(aAreaB3K)
	RestArea(aAreaB3X)

	If lRet .And. cStatusSeg == "1"
		PlCenLimArq()
	Endif

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjusData

Funcao criada para ajustar a data de bloqueio ou desbloqueio quando cancela-se uma operação

@param cMatric	 Matricula do beneficiário
@param cTipo	 0-Bloqueio;1-Desbloqueio

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function AjusData(cMatric, cTipo)
	Local cSql := ""

	//B4W_FILIAL+B4W_MATRIC+B4W_TIPO
	cSql := " SELECT B4W_DATA "
	cSql += " FROM " + RetSqlName("B4W") + " "
	cSql += " WHERE "
	cSql += "	B4W_FILIAL = '" + xFilial('B4W') + "' "
	cSql += "	AND B4W_MATRIC = '" + cMatric + "' "
	cSql += "	AND B4W_TIPO = '" + cTipo + "' "
	cSql += "	AND B4W_STATUS = '1'"
	cSql += "	AND D_E_L_E_T_ = ' ' "
	cSql += "	ORDER BY "
	cSql += "	B4W_DATA DESC "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBDTA",.F.,.T.)
	RecLock("B3K",.F.)
	If TRBDTA->(Eof())
		If cTipo == '0'
			B3K->B3K_DATBLO := STOD("")
		Else
			B3K->B3K_DATREA := STOD("")
		EndIf
	Else
		If cTipo == '0'
			B3K->B3K_DATBLO = STOD(TRBDTA->B4W_DATA)
		Else
			B3K->B3K_DATREA = STOD(TRBDTA->B4W_DATA)
		EndIf
	EndIf

	B3K->(MsUnlock())

	TRBDTA->(DbCloseArea())

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExibeCadastro

Funcao criada para exibir as telas de cadastros de beneficiario, produto ou despesa

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlCenCriOpe()

	Local cFiltro := " B3F_FILIAL = xFilial( 'B3F' ) .AND. " +;
		" B3F_ORICRI = 'B3X' .AND. " +;
		" B3F_CHVORI = " + AllTrim(Str(B3X->(Recno()))) + " "
	PLBRWCrit(cFiltro)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlCenLimArq

Limpa o nome do arquivo da movimentação SIB

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlCenLimArq()
	Reclock("B3X",.F.)
	B3X->B3X_ARQUIV := ""
	MsUnlock()
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnLmpMovSib

Limpa o histórico de movimentação de um beneficiários

@return lRetorno	.F. registros nao apagados ou .T. registros apagados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnLmpMovSib(nRecno)

	Local cSql			:= ""
	Local lRet			:= .T.

	//Limpa as críticas da movimentação

	cSql := " DELETE FROM " + RetSqlName('B3F') + " "
	cSql += " WHERE "
	cSql += "	B3F_FILIAL = '" + xFilial("B3F") + "' "
	cSql += " AND B3F_ORICRI = 'B3X' "
	cSql += " AND B3F_CHVORI IN  "
	cSql += " ( "
	cSql += " 	SELECT R_E_C_N_O_ FROM " + RetSqlName('B3X') + " "
	cSql += " 	WHERE "
	cSql += " 		B3X_FILIAL = '" + xFilial("B3X") + "' "
	cSql += " 		AND B3X_BENEF = " + AllTrim(Str(nRecno)) + " "
	cSql += " ) "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0
	If lRet

		cSql := " DELETE FROM " + RetSqlName('B3X') + " "
		cSql += " WHERE "
		cSql += " B3X_FILIAL = '" + xFilial("B3X") + "' "
		cSql += " AND B3X_BENEF = " + AllTrim(Str(nRecno)) + " "

		nRet := TCSQLEXEC(cSql)
		If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		Endif

		lRet := nRet >= 0
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenVldMov

Executa a rotina de validação para a movimentação selecionada

@author everton.mateus
@since 19/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenVldMov(lReativ)

	Local aArea       := GetArea()
	Local cMarca      := oMark:Mark()
	Local nCt         := 0
	Local nI          := 0
	default lReativ   := .F.
	default aMarkCanc :={}

	aMarkCanc:=BusMovMar(cMarca)

	For nI:=1 to Len(aMarkCanc)
		B3X->(DbGoto(aMarkCanc[nI][2]))
		PLSIBVLOP( cEmpAnt,cFilAnt,{},DTOS(dDataBase),B3D->B3D_CODOPE,cEmpAnt,Nil,JOB_VALID,{}, B3X->(RECNO()) )
		nCt++
	Next

	If !lReativ
		ApMsgInfo( 'Foram validados ' + AllTrim( Str( nCt ) ) + ' registros.' )
	EndIf
	RestArea( aArea )
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SHOWCANC

Altera o filtro da tela para exibir ou nao os movimentos cancelados

@author everton.mateus
@since 19/11/2018
/*/
//--------------------------------------------------------------------------------------------------
function SHOWCANC()
	Local cFilter := 	" B3X_FILIAL 	 = xFilial( 'B3X' ) .AND. " +;
		" ( " +;
		"		( DTOS(B3X_DATA) >= '" + DTOS(dDatIni) + "' .AND. DTOS(B3X_DATA) <='" + DTOS(dDatAte) + "' ) .OR. "+;
		"		( DTOS(B3X_DATA) <= '" + DTOS(dDatAte) + "' .AND. B3X_STATUS $ '1,2,3,5' ) " +;
		" ) "

	nCount++
	If (nCount%2 != 0)
		cFilter := StrTran(cFilter, "B3X_STATUS $ '1,2,3,5'","B3X_STATUS $ '1,2,3,5,7'")
	EndIf
	oMark:CleanFilter()
	oMark:SetFilterDefault(cFilter)
	oMark:Refresh()
return

Static Function BusMovMar(cMarca)
	Local cSql      := ""
	Local aMarkCanc := {}
	Default cMarca  :=""

	cSql := " SELECT B3X_BENEF,R_E_C_N_O_ AS RECNO "
	cSql += " FROM " + RetSqlName("B3X") + " "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_MARK = '" + cMarca + "' "
	cSql += "	AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMRK",.F.,.T.)

	while !TRBMRK->(Eof())
		aAdd(aMarkCanc,{TRBMRK->B3X_BENEF,TRBMRK->RECNO})
		TRBMRK->( dbSkip() )
	EndDo

	TRBMRK->(DbCloseArea())

Return aClone(aMarkCanc)

function RetCompIn()
	Local cCompIn := "0"+SubStr(DtoS(B3X->B3X_DATA),5,2)
return cCompIn

function RetCompOu()
	Local cCompOu := ""
	If !Empty(B3X->B3X_ARQUIV)
		cCompOu := "0"+SubStr(B3X->B3X_ARQUIV,11,2)
	EndIf
return cCompOu


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMrkAll
Função para execução do MarkAll da MarkBrowse

@author jose.paulo
@since  23/07/2021
/*/
//-------------------------------------------------------------------

Static Function SetMrkAll(oObjTmp As Object,cAliasMrk As Character,cFlag As Character)

	cMarca := oObjTmp:cMark

	(cAliasMrk)->(dbGotop())

	While (cAliasMrk)->(!Eof())
		RecLock(cAliasMrk,.F.)
		If Empty((cAliasMrk)->&(cFlag))
			(cAliasMrk)->&(cFlag)	:= cMarca
		Else
			(cAliasMrk)->&(cFlag)	:= "  "
		Endif
		MsUnlock()
		(cAliasMrk)->(dbSkip())
	EndDo

	(cAliasMrk)->(dbGotop())

	If oObjTmp <> nil
		oObjTmp:Refresh()
	Endif

Return

