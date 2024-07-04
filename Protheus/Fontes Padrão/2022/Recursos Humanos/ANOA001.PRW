#INCLUDE "ANOA001.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ANOA001()
Função para processar a anonimizacao das solicitacoes
@author  Gisele Nuncherino
@since   30/12/19
/*/
//-------------------------------------------------------------------
Function ANOA001()
	Local aAllUser := {}
	Local nTamEmp  := 0
	Local nTamFil  := 0

   	Private oReturn
   	Private cAliasQry
   	Private cOBS    := space(250)
   	Private cFilUsr := ""
	Private cMatUsr := ""

	Private cFilBrw    := "RH3_FILIAL = '" + xfilial("RH3") + "' "
	Private oMark	   := NIL
	Private bProcessa  := {|| MsgRun ("Aguarde, processando...","Anonimização",{||ProcRH3(oMark)}) }
	Private cSeparador:= "****************************************"

	dbSelectArea("SX5")
	IF !SX5->(DbSeek(xFilial("SX5")+"JQX"))
		MSGALERT( OEMTOANSI( STR0026 ))
		RETURN
	ENDIF

   	//Busca vinculo funcional
   	If (PswSeek(__cUserId,.T.))
       aAllUser := PswRet()

       nTamEmp := len(Alltrim(cEmpAnt))
       nTamFil := len(Alltrim(cFilAnt))

       cFilUsr := SUBSTR(aAllUser[1,22], nTamEmp+1, nTamFil)
       cMatUsr := SUBSTR(aAllUser[1,22], nTamEmp+nTamFil+1, 6)
   EndIf

	oMark:= FWMarkBrowse():New()
	oMark:SetDescription( OEMTOANSI( STR0028 ) )
	oMark:SetAlias( 'RH3' )

	If RH3->(ColumnPos("RH3_OK")) > 0
		oMark:SetFieldMark( "RH3_OK" )
		oMark:SetCustomMarkRec({|| Rh3MkB(oMark) })
		oMark:SetAllMark({|| Rh3MkBTud(oMark) })
		oMark:SetWalkThru(.F.)
		oMark:SetAmbiente(.F.)
		oMark:DisableReport(.T.)
		oMark:AddButton("Processar em Lote", bProcessa, NIL, 3) //Confirmar
	EndIf

	oMark:AddLegend('RH3->RH3_STATUS=="1"',  "YELLOW"	, OemToAnsi(STR0001) ) //"Solicitado"
	oMark:AddLegend('RH3->RH3_STATUS=="2"',  "GREEN"	, OemToAnsi(STR0002) ) //"Atendido"
	oMark:AddLegend('RH3->RH3_STATUS=="3"',  "RED"		, OemToAnsi(STR0003) ) //"Rejeitado"

	cFilBrw += ' .AND. RH3_TIPO $ "X"' //apenas solicitacoes de anonimizacao

	/*Tratamento ColumnPos provisorio ate saida dos campos no dicionario*/
	If RH3->(ColumnPos("RH3_EMP")) > 0
		cFilBrw += " .AND. ( Empty(RH3_EMP) .Or. RH3_EMP == '"+cEmpAnt+"')"
	End If

	oMark:SetFilterDefault(cFilBrw)
	oMark:Activate()
Return


/*{Protheus.doc}MenuDef
Cria os Menus para visualizar
@author Gisele Nuncherino
@since 29/11/2019
@version P12
@return aRotina , Vetor,Vetor com as opções da Rotina do Vetor
*/
Static Function MenuDef()
	Local aRotina := {}
	Local aArea	:= GetArea()

	ADD OPTION aRotina Title OemToAnsi(STR0004)	Action 'VIEWDEF.ANOA001'	OPERATION 2  ACCESS 0 // //"Visualizar"

	If ChkFile("SQG") .And. SQG->(ColumnPos("QG_OK")) > 0
		ADD OPTION aRotina Title OemToAnsi(STR0027)	Action 'ANOA010'	OPERATION 4  ACCESS 0 // //"Anonimizar sem Solic."
	EndIf

	aAdd( aRotina, { OemToAnsi(STR0005),"ANOA1Leg", 0 , 2,,.F.} )	//"Legenda"
	RestArea(aArea)
Return aRotina


/*{Protheus.doc}ANOA1Leg
Cria as legendas para os status das solicitações
@author Gisele Nuncherino
@since 29/11/2019
@version P12
@return
*/
Function ANOA1Leg()

	Local aLegenda	:= {}
	Local aSvKeys	:= GetKeys()

	aLegenda := {	{ "BR_AMARELO" , OemToAnsi( STR0006 ) } ,; //"Solicitado"
					{ "BR_VERDE"   , OemToAnsi( STR0007 ) } ,; //"Atendido"
					{ "BR_VERMELHO", OemToAnsi( STR0008 ) } } //"Rejeitado"

	BrwLegenda(	OemToAnsi(STR0009) , OemToAnsi(STR0009) , aLegenda ) //"Legendas do processo"

	RestKeys( aSvKeys )

Return( NIL )


//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados das solicitações
@author Gisele Nuncherino
@since  29/11/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := MPFormModel():New("ANOA001")
	Local oStructRH3 := FWFormStruct(1, "RH3")
	Local oStructRH4 := FWFormStruct(1, "RH4")

	oStructRH3:SetProperty( "RH3_MAT", MODEL_FIELD_OBRIGAT, .F. )

	oModel:AddFields("ANOA001_RH3", NIL, oStructRH3)

	oModel:AddGrid(	"ANOA001_RH4",;			//cId - Identificador do modelo
						"ANOA001_RH3",;			//cOwner - Identificador superior do modelo
					  	   	oStructRH4,;			//oModelStruct - Objeto com a estrutura de dados
									NIL,;			//bLinePre - Code-Block de pre-edição da linha do grid de edição. Indica se a edição esta liberada
									NIL,;			//bLinePost - Code-Block de validação da linha do grid de edição
									NIL,;			//bPre - Code-Block de pre-edição do grid de edição. Indica se a edição esta liberada
									NIL,;			//bPost - Code-Block de validação do grid de edição
									NIL;			//bLoad - Code-Block de carga dos dados do formulário de edição
							)


	oModel:GetModel("ANOA001_RH4"):SetOnlyView( .F. )
	oModel:GetModel("ANOA001_RH4"):SetOnlyQuery( .F. )

	oModel:SetPrimaryKey({"RH3_CODIGO"})

	oModel:SetDescription(OemToAnsi(STR0010))

	oModel:GetModel("ANOA001_RH4"):SetUniqueLine({"RH4_ITEM"}) //Diz ao model que o campo deve ser validado quanto a repeticao

	oModel:SetRelation(	 "ANOA001_RH4",;
						{	{"RH4_FILIAL", "xFilial('RH4')"},;
					      	{"RH4_CODIGO", "RH3_CODIGO"}	},;
							 "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3)")


Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
@author Gisele Nuncherino
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 	:= FWLoadModel("ANOA001")
	Local oView 	:= FWFormView():New()

	Local oStructRH3 := FWFormStruct(2, "RH3")
	Local oStructRH4 := FWFormStruct(2, "RH4")


	oStructRH3:RemoveField("RH3_FILIAL")
	oStructRH3:RemoveField("RH3_NOME")
	oStructRH3:RemoveField("RH3_VISAO")
	oStructRH3:RemoveField("RH3_NVLINI")
	oStructRH3:RemoveField("RH3_FILINI")
	oStructRH3:RemoveField("RH3_MATINI")
	oStructRH3:RemoveField("RH3_NVLAPR")
	oStructRH3:RemoveField("RH3_FILAPR")
	oStructRH3:RemoveField("RH3_MATAPR")
	oStructRH3:RemoveField("RH3_WFID")
	oStructRH3:RemoveField("RH3_IDENT")
	oStructRH3:RemoveField("RH3_KEYINI")

	oStructRH4:RemoveField("RH4_FILIAL")
	oStructRH4:RemoveField("RH4_CAMPO")
	oStructRH4:RemoveField("RH4_CODIGO")

	If !(RH3->RH3_TIPO $ "1")
		oStructRH4:RemoveField("RH4_VALANT")
	EndIf

	oView:SetModel(oModel)
	oView:AddField("ANOA001_RH3", oStructRH3)

	oView:AddGrid("ANOA001_RH4", oStructRH4)
	oView:CreateHorizontalBox("TOP", 50)
	oView:CreateHorizontalBox("BOTTOM", 50)

	oView:SetOwnerView("ANOA001_RH3", "TOP")
	oView:SetOwnerView("ANOA001_RH4", "BOTTOM")

	oView:AddUserButton(OemToAnsi(STR0011), "CLIPS", {|| ProcAnoni() })

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc}ProcAnoni
Realiza o processamento das solicitações. Chama a execauto para excluir o curriculo
@author Gisele Nuncherino
@since  29/11/2019
@version 12
/*/
//-------------------------------------------------------------------
Function ProcAnoni()

Local cCpf		:= ""
Local cNome		:= ""
Local cStatus	:= '1' //1=Em processo de aprovação
Local lRet		:= .T.

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.

IF RH3->RH3_STATUS $ '2/3'
	MSGINFO(OemToAnsi(STR0012))
	RETURN
ENDIF

cMsg 	:= cSeparador + Chr(13) + Chr(10)
cCpf 	:= ""
cNome 	:= ""

RH4->(DBSETORDER(1))
IF RH4->(DBSEEK(RH3->(RH3_FILIAL + RH3_CODIGO)))
	while RH4->(!EOF()) .AND. RH4->(RH4_FILIAL + RH4_CODIGO) ==  RH3->(RH3_FILIAL + RH3_CODIGO)
		IF ALLTRIM(RH4->RH4_CAMPO) == 'TMP_CPF'
			cCpf := alltrim(RH4->RH4_VALNOV)
		ELSEIF ALLTRIM(RH4->RH4_CAMPO) == 'TMP_NOME'
			cNome := RH4->RH4_VALNOV
		ENDIF
		RH4->(DBSKIP())
	ENDDO
ELSE
	lret := .F.
	cCpf := "999.999.999.-99"
	cNome:= "xxxxxxxxxx"
ENDIF

IF LRET
	lRet := ProcSQG(cCPF, @cMsg)
ENDIF

//RH3 STATUS
//1=Em processo de aprovação
//2=Atendida
//3=Reprovada
//4=Aguardando Efetivação do RH
//5=Aguardando Aprovação do RH

IIF(LRET, cStatus := '2', cStatus := '3')

IF !LRET
	IF MsgYesNo(OemToAnsi(STR0022) + Chr(13) + Chr(10) + Chr(13) + Chr(10) + OemToAnsi(STR0023) + Chr(13) + Chr(10) + OemToAnsi(STR0024),"")
		// RETORNAR O STATUS PARA 1-EM PROCESSO DE APROVACAO
		cStatus := '1'
	ENDIF
ENDIF

RECLOCK("RH3", .F.)
	RH3->RH3_STATUS := cStatus
	RH3->RH3_DTATEN := iif( cstatus == '1', ctod('  /  /  '), DDATABASE)
RH3->(MSUNLOCK())

//Gera o log do processamento
fMakeLog( {{cMsg}} , {} , "ANOA001" , NIL , FunName() , OemToAnsi(STR0021))

RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} VerRelac(cCpf, aTabelas)
Função para verificar se é possivel excluir o registro
@author  Gisele Nuncherino
@since   30/12/19
/*/
//-------------------------------------------------------------------
Function VerRelac(cCpf, aTabelas)
Local lRet 		:= .T.
Local cQuery 	:= ''
Local cAlias 	:= GetNextAlias()
Local cOracle	:= TcGetDb()

aTabelas := {}

if !empty(cCpf)

	IF chkfile("RBW")
		if cOracle $ "ORACLE"
			cQuery := "SELECT "
		else
			cQuery := "SELECT TOP (1) "
		ENDIF
		cQuery += " RBW_CPF4, RBW_CPF5, RBW_CPF6, RBW_CPF7, RBW_CPF8, RBW_CPF9, RBW_CPFSUB "

		cQuery += " FROM "
		cQuery += RetSqlName("RBWT10") +" RBW "

		cQuery += " WHERE  "

		if cOracle $ "ORACLE"
			cQuery += " ROWNUM = 1 AND "
		ENDIF

		cQuery += " ((RBW_CPF4 = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') OR "
		cQuery += " (RBW_CPF5 = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') OR "
		cQuery += " (RBW_CPF6 = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') OR "
		cQuery += " (RBW_CPF7 = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') OR "
		cQuery += " (RBW_CPF8 = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') OR "
		cQuery += " (RBW_CPF9 = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') OR "
		cQuery += " (RBW_CPFSUB = '" + cCpf + "' AND RBW.D_E_L_E_T_ = ' ') )"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
		IF (cAlias)->(!Eof())
			aadd(aTabelas, {"RBW", FwSX2Util():GetX2Name( "RBW" )})
			lret := .F.
		endif
		(cAlias)->(dbCloseArea())
	ELSE
		LRET := .t.
	ENDIF

	if LRET
		if cOracle $ "ORACLE"
			cQuery := "SELECT "
		else
			cQuery := "SELECT TOP (1) "
		ENDIF

		cQuery += " RD0_CIC, "
		cQuery += " REY_CPF "

		cQuery += " FROM "
		cQuery += RetSqlName("RD0") +" RD0, "
		cQuery += RetSqlName("REY") +" REY "

		cQuery += " WHERE  "

		if cOracle $ "ORACLE"
			cQuery += " ROWNUM = 1 AND "
		ENDIF
		cQuery += " ((RD0_CIC = '" + cCpf + "' AND RD0.D_E_L_E_T_ = ' ') OR "
		cQuery += " (REY_CPF = '" + cCpf + "' AND REY.D_E_L_E_T_ = ' '))  "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
		IF (cAlias)->(!Eof())
			if (cAlias)->RD0_CIC == cCpf
				aadd(aTabelas, {"RD0", FwSX2Util():GetX2Name( "RD0" )})
			endif
			if (cAlias)->REY_CPF == cCpf
				aadd(aTabelas, {"REY", FwSX2Util():GetX2Name( "REY" )})
			endif
			lret := .F.
		endif

		(cAlias)->(dbCloseArea())

		if LRET
			if cOracle $ "ORACLE"
				cQuery := "SELECT "
			else
				cQuery := "SELECT TOP (1) "
			ENDIF

			cQuery += " REZ_CPF, "
			cQuery += " RI6_CPF, "
			cQuery += " RGC_CPFCGC"

			cQuery += " FROM "
			cQuery += RetSqlName("REZ") +" REZ, "
			cQuery += RetSqlName("RGC") +" RGC, "
			cQuery += RetSqlName("RI6") +" RI6 "

			cQuery += " WHERE  "
			if cOracle $ "ORACLE"
				cQuery += " ROWNUM = 1 AND "
			ENDIF
			cQuery += " ((REZ_CPF = '" + cCpf + "' AND REZ.D_E_L_E_T_ = ' ') OR "
			cQuery += " (RI6_CPF = '" + cCpf + "' AND RI6.D_E_L_E_T_ = ' ') OR "
			cQuery += " (RGC_CPFCGC = '" + cCpf + "' AND RGC.D_E_L_E_T_ = ' ') ) "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
			IF (cAlias)->(!Eof())
				if (cAlias)->REZ_CPF == cCpf
					aadd(aTabelas, {"REZ", FwSX2Util():GetX2Name( "REZ" )})
				endif
				if (cAlias)->RI6_CPF == cCpf
					aadd(aTabelas, {"RI6", FwSX2Util():GetX2Name( "RI6" )})
				endif
				if (cAlias)->RGC_CPFCGC == cCpf
					aadd(aTabelas, {"RGC", FwSX2Util():GetX2Name( "RGC" )})
				endif
				lret := .F.
			endif

			(cAlias)->(dbCloseArea())

			if LRET
				if cOracle $ "ORACLE"
					cQuery := "SELECT "
				else
					cQuery := "SELECT TOP (1) "
				ENDIF

				cQuery += " PW_CPF, "
				cQuery += " R4_CPFCGC "

				cQuery += " FROM "
				cQuery += RetSqlName("SPW") +" SPW, "
				cQuery += RetSqlName("SR4") +" SR4 "

				cQuery += " WHERE  "
				if cOracle $ "ORACLE"
					cQuery += " ROWNUM = 1 AND "
				ENDIF
				cQuery += " ((PW_CPF = '" + cCpf + "' AND SPW.D_E_L_E_T_ = ' ') OR "
				cQuery += " (R4_CPFCGC = '" + cCpf + "' AND SR4.D_E_L_E_T_ = ' '))  "

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
				IF (cAlias)->(!Eof())
					if (cAlias)->PW_CPF == cCpf
						aadd(aTabelas, {"SPW", FwSX2Util():GetX2Name( "SPW" )})
					endif
					if (cAlias)->R4_CPFCGC == cCpf
						aadd(aTabelas, {"SR4", FwSX2Util():GetX2Name( "SR4" )})
					endif
					lret := .F.
				endif

				(cAlias)->(dbCloseArea())

				if LRET
					if cOracle $ "ORACLE"
						cQuery := "SELECT "
					else
						cQuery := "SELECT TOP (1) "
					ENDIF
					cQuery += " RB_CIC, "
					cQuery += " RL_CPFCGC, "
					cQuery += " RQ_CIC "

					cQuery += " FROM "
					cQuery += RetSqlName("SRB") +" SRB, "
					cQuery += RetSqlName("SRL") +" SRL, "
					cQuery += RetSqlName("SRQ") +" SRQ "

					cQuery += " WHERE  "
					if cOracle $ "ORACLE"
						cQuery += " ROWNUM = 1 AND "
					ENDIF
					cQuery += " ((RB_CIC = '" + cCpf + "' AND SRB.D_E_L_E_T_ = ' ') OR "
					cQuery += " (RL_CPFCGC = '" + cCpf + "' AND SRL.D_E_L_E_T_ = ' ') OR "
					cQuery += " (RQ_CIC = '" + cCpf + "' AND SRQ.D_E_L_E_T_ = ' ')) "

					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
					IF (cAlias)->(!Eof())
						if (cAlias)->RB_CIC == cCpf
							aadd(aTabelas, {"SRB", FwSX2Util():GetX2Name( "SRB" )})
						endif
						if (cAlias)->RL_CPFCGC == cCpf
							aadd(aTabelas, {"SRL", FwSX2Util():GetX2Name( "SRL" )})
						endif
						if (cAlias)->RQ_CIC == cCpf
							aadd(aTabelas, {"SRQ", FwSX2Util():GetX2Name( "SRQ" )})
						endif
						lret := .F.
					endif

					(cAlias)->(dbCloseArea())

					if LRET
						if cOracle $ "ORACLE"
							cQuery := "SELECT "
						else
							cQuery := "SELECT TOP (1) "
						ENDIF

						cQuery += " RA_CIC "

						cQuery += " FROM "
						cQuery += RetSqlName("SRA") +" SRA "

						cQuery += " WHERE  "
						if cOracle $ "ORACLE"
							cQuery += " ROWNUM = 1 AND "
						ENDIF
						cQuery += " (RA_CIC = '" + cCpf + "' AND SRA.D_E_L_E_T_ = ' ') "

						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
						IF (cAlias)->(!Eof())
							if (cAlias)->RA_CIC == cCpf
								aadd(aTabelas, {"SRA", FwSX2Util():GetX2Name( "SRA" )})
							endif
							lret := .F.
						endif

						(cAlias)->(dbCloseArea())

						if LRET
							if cOracle $ "ORACLE"
								cQuery := "SELECT "
							else
								cQuery := "SELECT TOP (1) "
							ENDIF

							cQuery += "RCS_CPFCGC,"
							cQuery += "RCU_CGC,"
							cQuery += "RFI_CPFCGC,"
							cQuery += "RFI_CPFADV,"
							//cQuery += "RGE_CIC,"
							cQuery += "RHM_CPF,"
							cQuery += "RHO_CPF,"
							cQuery += "RHP_INMED,"
							cQuery += "RIE_CPF,"
							cQuery += "M8_CPFCGC,"
							cQuery += "QG_CIC,"
							cQuery += "R4_CPFCGC,"
							cQuery += "TM0_CPF,"
							cQuery += "TMK_CIC "

							cQuery += " FROM "
							cQuery += RetSqlName("RCS") +" RCS, "
							cQuery += RetSqlName("RCU") +" RCU, "
							cQuery += RetSqlName("RFI") +" RFI, "
							cQuery += RetSqlName("RHM") +" RHM, "
							cQuery += RetSqlName("RHO") +" RHO, "
							cQuery += RetSqlName("RHP") +" RHP, "
							cQuery += RetSqlName("RIE") +" RIE, "
							cQuery += RetSqlName("SM8") +" SM8, "
							cQuery += RetSqlName("SQG") +" SQG, "
							cQuery += RetSqlName("SR4") +" SR4, "
							cQuery += RetSqlName("TM0") +" TM0, "
							cQuery += RetSqlName("TMK") +" TMK "

							cQuery += " WHERE  "
							if cOracle $ "ORACLE"
								cQuery += " ROWNUM = 1 AND "
							ENDIF

							cQuery += " ((RCS_CPFCGC = '" + cCpf + "' AND RCS.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RCU_CGC = '" + cCpf + "' AND RCU.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RFI_CPFCGC = '" + cCpf + "' AND RFI.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RFI_CPFADV = '" + cCpf + "' AND RFI.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RHM_CPF = '" + cCpf + "' AND RHM.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RHO_CPF = '" + cCpf + "' AND RHO.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RHP_INMED = '" + cCpf + "' AND RHP.D_E_L_E_T_ = ' ') OR "
							cQuery += " (RIE_CPF = '" + cCpf + "' AND RIE.D_E_L_E_T_ = ' ') OR "
							cQuery += " (M8_CPFCGC = '" + cCpf + "' AND SM8.D_E_L_E_T_ = ' ') OR "
							cQuery += " (QG_CIC = '" + cCpf + "' AND SQG.D_E_L_E_T_ = ' ') OR "
							cQuery += " (R4_CPFCGC = '" + cCpf + "' AND SR4.D_E_L_E_T_ = ' ') OR "
							cQuery += " (TM0_CPF = '" + cCpf + "' AND TM0.D_E_L_E_T_ = ' ') OR "
							cQuery += " (TMK_CIC = '" + cCpf + "' AND TMK.D_E_L_E_T_ = ' ')) "

							cQuery := ChangeQuery(cQuery)
							dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
							IF (cAlias)->(!Eof())
								if (cAlias)->RCS_CPFCGC == cCpf
									aadd(aTabelas, {"RCS", FwSX2Util():GetX2Name( "RCS" )})
								endif
								if (cAlias)->RCU_CGC == cCpf
									aadd(aTabelas, {"RCU", FwSX2Util():GetX2Name( "RCU" )})
								endif
								if (cAlias)->RFI_CPFCGC == cCpf  .or. RFI_CPFADV == cCpf
									aadd(aTabelas, {"RFI", FwSX2Util():GetX2Name( "RFI" )})
								endif
								/*if RGE_CIC == cCpf
									aadd(aTabelas, {"RGE", FwSX2Util():GetX2Name( "RGE" )})
								endif*/
								if (cAlias)->RHM_CPF == cCpf
									aadd(aTabelas, {"RHM", FwSX2Util():GetX2Name( "RHM" )})
								endif
								if (cAlias)->RHO_CPF == cCpf
									aadd(aTabelas, {"RHO", FwSX2Util():GetX2Name( "RHO" )})
								endif
								if (cAlias)->RHP_INMED == cCpf
									aadd(aTabelas, {"RHP", FwSX2Util():GetX2Name( "RHP" )})
								endif
								if (cAlias)->RIE_CPF == cCpf
									aadd(aTabelas, {"RIE", FwSX2Util():GetX2Name( "RIE" )})
								endif
								if (cAlias)->M8_CPFCGC == cCpf
									aadd(aTabelas, {"SM8", FwSX2Util():GetX2Name( "SM8" )})
								endif
								if (cAlias)->QG_CIC == cCpf
									aadd(aTabelas, {"SQG", FwSX2Util():GetX2Name( "SQG" )})
								endif
								if (cAlias)->R4_CPFCGC == cCpf
									aadd(aTabelas, {"SR4", FwSX2Util():GetX2Name( "SR4" )})
								endif
								if (cAlias)->TM0_CPF == cCpf
									aadd(aTabelas, {"TM0", FwSX2Util():GetX2Name( "TM0" )})
								endif
								if (cAlias)->TMK_CIC == cCpf
									aadd(aTabelas, {"TMK", FwSX2Util():GetX2Name( "TMK" )})
								endif
								lret := .F.
							endif

							(cAlias)->(dbCloseArea())

							IF LRET
								if cOracle $ "ORACLE"
									cQuery := "SELECT "
								else
									cQuery := "SELECT TOP (1) "
								ENDIF

								cQuery += " * FROM  "
								cQuery += RetSqlName("SQD") +" SQD "
								cQuery += "INNER JOIN "
								cQuery += RetSQLName("SQG") + " SQG "
								cQuery += " ON "
								cQuery += "	QD_FILIAL = '" + xFilial("SQD") + "' "
								cQuery += " AND QD_CURRIC  = QG_CURRIC "
								cQuery += "	AND SQG.D_E_L_E_T_ = ' ' AND SQD.D_E_L_E_T_ = ' ' AND QG_CIC = '" + cCpf + "' AND QG_FILIAL = '" + xFilial("SQG") + "' "
								cQuery := ChangeQuery(cQuery)
								dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
								IF (cAlias)->(!Eof())
									aadd(aTabelas, {"SQD", FwSX2Util():GetX2Name( "SQD" )})
									lret := .F.
								endif
								(cAlias)->(dbCloseArea())

								IF LRET
									if cOracle $ "ORACLE"
										cQuery := "SELECT "
									else
										cQuery := "SELECT TOP (1) "
									ENDIF

									cQuery += " * FROM  "
									cQuery += RetSqlName("SQR") +" SQR "
									cQuery += "INNER JOIN "
									cQuery += RetSQLName("SQG") + " SQG "
									cQuery += " ON "
									cQuery += "	QR_FILIAL = QG_FILIAL "
									cQuery += " AND QR_CURRIC  = QG_CURRIC "
									cQuery += "	AND SQG.D_E_L_E_T_ = ' ' AND SQR.D_E_L_E_T_ = ' ' AND QG_CIC = '" + cCpf + "'"
									cQuery := ChangeQuery(cQuery)
									dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
									IF (cAlias)->(!Eof())
										aadd(aTabelas, {"SQR", FwSX2Util():GetX2Name( "SQR" )})
										lret := .F.
									endif
									(cAlias)->(dbCloseArea())

									IF LRET
										if cOracle $ "ORACLE"
											cQuery := "SELECT "
										else
											cQuery := "SELECT TOP (1) "
										ENDIF

										cQuery += " * FROM  "
										cQuery += RetSqlName("SQI") +" SQI "
										cQuery += "INNER JOIN "
										cQuery += RetSQLName("SQG") + " SQG "
										cQuery += " ON "
										cQuery += "	QI_FILIAL = QG_FILIAL "
										cQuery += " AND QI_CURRIC  = QG_CURRIC "
										cQuery += "	AND SQG.D_E_L_E_T_ = ' ' AND SQI.D_E_L_E_T_ = ' ' AND QG_CIC = '" + cCpf + "'"
										cQuery := ChangeQuery(cQuery)
										dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
										IF (cAlias)->(!Eof())
											aadd(aTabelas, {"SQI", FwSX2Util():GetX2Name( "SQI" )})
											lret := .F.
										endif
										(cAlias)->(dbCloseArea())

										IF LRET
											if cOracle $ "ORACLE"
												cQuery := "SELECT "
											else
												cQuery := "SELECT TOP (1) "
											ENDIF

											cQuery += " * FROM  "
											cQuery += RetSqlName("SQL") +" SQL "
											cQuery += "INNER JOIN "
											cQuery += RetSQLName("SQG") + " SQG "
											cQuery += " ON "
											cQuery += "	QL_FILIAL = QG_FILIAL "
											cQuery += " AND QL_CURRIC  = QG_CURRIC "
											cQuery += "	AND SQG.D_E_L_E_T_ = ' ' AND SQL.D_E_L_E_T_ = ' ' AND QG_CIC = '" + cCpf + "'"
											cQuery := ChangeQuery(cQuery)
											dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
											IF (cAlias)->(!Eof())
												aadd(aTabelas, {"SQL", FwSX2Util():GetX2Name( "SQL" )})
												lret := .F.
											endif
											(cAlias)->(dbCloseArea())

											IF LRET
												if cOracle $ "ORACLE"
													cQuery := "SELECT "
												else
													cQuery := "SELECT TOP (1) "
												ENDIF

												cQuery += " * FROM  "
												cQuery += RetSqlName("SQM") +" SQM "
												cQuery += "INNER JOIN "
												cQuery += RetSQLName("SQG") + " SQG "
												cQuery += " ON "
												cQuery += "	QM_FILIAL = QG_FILIAL "
												cQuery += " AND QM_CURRIC  = QG_CURRIC "
												cQuery += "	AND SQG.D_E_L_E_T_ = ' ' AND SQM.D_E_L_E_T_ = ' ' AND QG_CIC = '" + cCpf + "'"
												cQuery := ChangeQuery(cQuery)
												dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
												IF (cAlias)->(!Eof())
													aadd(aTabelas, {"SQM", FwSX2Util():GetX2Name( "SQM" )})
													lret := .F.
												endif
												(cAlias)->(dbCloseArea())
											ENDIF
										ENDIF
									ENDIF
								ENDIF
							ENDIF
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function ANOA010
description Anonimizacao sem solicitacao
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Function ANOA010()

Local cPerg        := "ANOA001"

Private cFilSQG    := ''
Private oMarkBrow  := NIL
Private bProcSQG  := {|| MsgRun ("Aguarde, processando...","Anonimização",{||Processa(oMarkBrow)}) }

	SQG->(DBSetOrder(1))
	cFilSQG := "QG_FILIAL = '" + xfilial("SQG") + "' "

	oMarkBrow:= FWMarkBrowse():New()
	oMarkBrow:SetDescription( "Anonimização de Currículos" )
	oMarkBrow:SetAlias( 'SQG' )
	oMarkBrow:SetMenuDef( '' )
	oMarkBrow:SetFieldMark( "QG_OK" )
	oMarkBrow:SetCustomMarkRec({|| AnoMkB(oMarkBrow) })
	oMarkBrow:SetAllMark({|| AnoMkBTud(oMarkBrow) })
	oMarkBrow:SetWalkThru(.F.)
	oMarkBrow:SetAmbiente(.F.)
	oMarkBrow:SetFilterDefault( cFilSQG )
	oMarkBrow:AddButton("Processar", bProcSQG, NIL, 2) //Confirmar
	oMarkBrow:SetParam({||Pergunte(cPerg,.T.)})
	oMarkBrow:DisableReport(.T.)
	oMarkBrow:Activate()

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} function ProcRH3
description Processamento da anonimizacao
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function ProcRH3(oMark)

Local _cMark 	:= oMark:Mark()
Local cMsg		:= ''

RH3->(DBSetOrder(1))
RH3->(DBGOTOP())
RH3->(DBSEEK( XFILIAL('RH3') ))
While RH3->(! Eof()) .AND. RH3->RH3_FILIAL == XFILIAL('RH3')
	If oMark:IsMark(_cMark)
		RH4->(DBSETORDER())
		RH4->(DBSEEK(XFILIAL("RH4") + RH3->RH3_CODIGO))
		WHILE RH4->(!EOF()) .AND. RH4->(RH4_FILIAL + RH4_CODIGO) == XFILIAL("RH4") + RH3->RH3_CODIGO
			IF alltrim(RH4->RH4_CAMPO) == 'TMP_CPF'
				ProcSQG(alltrim(RH4->RH4_VALNOV), @cMsg, .T.)
				EXIT
			ENDIF
			RH4->(DBSKIP())
		ENDDO
	ENDIF

	RecLock("RH3",.F.)
		RH3->RH3_OK  := ""
	RH3->(MsUnLock())

	RH3->(DBSKIP())
ENDDO


IF EMPTY(cMsg)
	cMsg := OEMTOANSI( STR0030 ) //"Nenhum registro selecionado e processado"
ENDIF

//Gera o log do processamento
fMakeLog( {{cMsg}} , {} , "ANOA001" , NIL , FunName() , OemToAnsi(STR0021))

oMark:SetFilterDefault( cFilBrw )
oMark:Refresh()

RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} function Processa
description Processamento da anonimizacao
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function Processa(oMarkBrow)

Local _cMark 	:= oMarkBrow:Mark()
Local cMsg		:= ''

SQG->(DBSetOrder(1))
SQG->(DBGOTOP())
SQG->(DBSEEK( XFILIAL('SQG') ))
While SQG->(! Eof()) .AND. SQG->QG_FILIAL == XFILIAL('SQG')

	If oMarkBrow:IsMark(_cMark)
		ProcSQG(SQG->QG_CIC, @cMsg)
	ENDIF

	RecLock("SQG",.F.)
		SQG->QG_OK  := ""
	SQG->(MsUnLock())

	SQG->(DBSKIP())
ENDDO

IF EMPTY(cMsg)
	cMsg := OEMTOANSI( STR0030 ) //"Nenhum registro selecionado e processado"
ENDIF

//Gera o log do processamento
fMakeLog( {{cMsg}} , {} , "ANOA001" , NIL , FunName() , OemToAnsi(STR0021))

oMarkBrow:SetFilterDefault( cFilSQG )
oMarkBrow:Refresh()

RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} function Rh3MkBTud
description Marca/desmarca todos os itens da markbrowse
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function Rh3MkBTud(oMark)
Local cAlias		:= oMark:Alias()
Local aAreaRH3   	:= RH3->(GetArea())

(cAlias)->(DbSeek(xFilial((cAlias))))
While (cAlias)->(!Eof()) .And. (cAlias)->RH3_FILIAL == xFilial(cAlias)
	If (!oMark:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->RH3_OK  := oMark:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->RH3_OK  := ""
		(cAlias)->(MsUnLock())
	EndIf
	(cAlias)->(DbSkip())
End

oMark:Refresh()
oMark:SetFilterDefault( cFilBrw )
RestArea(aAreaRH3)
Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} function Rh3MkB
description SetCustomMarkRec
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function Rh3MkB(oMark)

If ( !oMark:IsMark() )
	RecLock(oMark:Alias(),.F.)
	(oMark:Alias())->RH3_OK  := oMark:Mark()
	(oMark:Alias())->(MsUnLock())

Else
	RecLock(oMark:Alias(),.F.)
	(oMark:Alias())->RH3_OK  := ""
	(oMark:Alias())->(MsUnLock())
EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} function AnoMkBTud
description Marca/desmarca todos os itens da markbrowse
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function AnoMkBTud(oMrkBrowse)
Local cAlias		:= oMrkBrowse:Alias()
Local aAreaSQG   	:= SQG->(GetArea())

(cAlias)->(DbSeek(xFilial((cAlias))))
While (cAlias)->(!Eof()) .And. (cAlias)->QG_FILIAL == xFilial(cAlias)
	If (!oMrkBrowse:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->QG_OK  := oMrkBrowse:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->QG_OK  := ""
		(cAlias)->(MsUnLock())
	EndIf
	(cAlias)->(DbSkip())
End

oMarkBrow:Refresh()
oMarkBrow:SetFilterDefault( cFilSQG )
RestArea(aAreaSQG)
Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} function AnoMkB
description SetCustomMarkRec
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function AnoMkB(oMrkBrowse)

If ( !oMrkBrowse:IsMark() )
	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->QG_OK  := oMrkBrowse:Mark()
	(oMrkBrowse:Alias())->(MsUnLock())

Else
	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->QG_OK  := ""
	(oMrkBrowse:Alias())->(MsUnLock())
EndIf

Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} function ProcSQG
description chama a execauto rspa010
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function ProcSQG(cCPF, cMsgAux, lRH3)
Local nx
Local ATABELAS, aLog
Local lRet 		:= .T.
Local aArea 	:= GetArea()

Private lMsErroAuto		:= .F.

Default cMsgAux := ''
DEFAULT lRH3 := .F.

IF empty(cMsgAux)
	cMsgAux := cSeparador + Chr(13) + Chr(10)
ENDIF

IF lRH3
	IF RH3->RH3_STATUS $ '2/3'
		cMsgAux += OemToAnsi(STR0013) +  transform(cCPF, "@R 999.999.999-99") + Chr(13) + Chr(10)
		cMsgAux += OemToAnsi(STR0012) + " Código: " + RH3->RH3_CODIGO + Chr(13) + Chr(10)
		LRET := .F.
	else
		lRet := .T.
	ENDIF
ENDIF

IF lRet
	SQG->(DBSETORDER(3)) //QG_FILIAL+QG_CIC
	IF SQG->(DBSEEK(XFILIAL('SQG')+cCpf))
		cMsgAux += OemToAnsi(STR0013) +  transform(SQG->QG_CIC, "@R 999.999.999-99") + Chr(13) + Chr(10)
		cMsgAux += OemToAnsi(STR0014) + alltrim(SQG->QG_NOME) + Chr(13) + Chr(10)

		ATABELAS := {}

		IF VerRelac(cCpf, @aTabelas) //O REGISTRO PODE SER EXCLUIDO - ANONIMIZADO
				//RSPA010
				MSExecAuto({|v,x,y,z| RSPA010(v,x,y,z)}, "SQG", ,5, {})
				If lMsErroAuto
					aLog := GETAUTOGRLOG()

					cMsgAux += OemToAnsi(STR0015) + Chr(13) + Chr(10)
					for nx := 1 to len(aLog)
						cMsgAux += aLog[nx] + Chr(13) + Chr(10)
					next nx
					lMsErroAuto := .F.
					lRet := .F.
				ELSE
					lRet := .T.
				Endif

				if lRet
					cMsgAux += OemToAnsi(STR0016) + Chr(13) + Chr(10)
				EndIf
		ELSE
			lret := .F.
			cMsgAux += OemToAnsi(STR0017) + Chr(13) + Chr(10)
			for nx := 1 to len(aTabelas)
				cMsgAux += aTabelas[nx][1] + "->" + aTabelas[nx][2] + Chr(13) + Chr(10)
			next nx
		ENDIF
	ELSE
		lret := .F.
		cMsgAux += OemToAnsi(STR0013) +  transform(cCpf, "@R 999.999.999-99") + Chr(13) + Chr(10)
		cMsgAux += OemToAnsi( STR0015 ) + Chr(13) + Chr(10)
		cMsgAux += OemToAnsi( STR0019 ) + Chr(13) + Chr(10)
	endif

	IF lRH3 .AND. LRET
		RECLOCK("RH3", .F.)
			RH3->RH3_STATUS := '2'
			RH3->RH3_DTATEN := DDATABASE
		RH3->(MSUNLOCK())
	ENDIF
ENDIF

cMsgAux += cSeparador + Chr(13) + Chr(10)

RestArea(aArea)

Return lRet
