#include "PROTHEUS.CH"
#include "OFIXDEF.CH"
#include "OFINJD18.CH"

Static cMVGARJD_T := OFNJD15SIMU()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFINJD18 ºAutor  ³ Takahashi          º Data ³ 01/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera Solicitação de Garantia da John Deere                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina - John Deere                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD18(cSituac , cTipTem , cLibVOO , cStatusTT , aRetWS )

Local aPeca
Local aSrvc
Local nCont
Local nCntFor

Local nRecVMB
Local cAliasVOO := "ALIASVOO"
Local cAliasREQ := "ALIASREQ"

Local nAuxTotal := 0

Local lNovaSG := .f.


Local aAuxIteVO4 := {}
Local aIteVO4    := {}

Local aIteVSJ := {}

Local aIteTemp := {}
Local aCabSGJD := {}
Local aIteSGJD := {}

Local lB1CODFAB := (SB1->(FieldPos("B1_CODFAB")) <> 0)

Local cAliasVX5 := "TVX5"

Local aTpGarCod := {}
Local aTpGarDes := {}

Local aRetParam := {}
Local aParParam := {}

Local cGSerDesloc
Local cCSerDesloc
Local cTSerDesloc

Local cTTSerRev
Local cGSerRev
Local cCodSecRev
Local cDepGarRev
Local cTipSerRev

Local cTTPecPMP
Local cTTSerPMP
Local cGSerPMP
Local cCodSecPMP
Local cDepGarPMP
Local cTipSerPMP
Local cCodServPMP

Local cUM

Local cCodGar := ""

Local nii
Local cTitAviso
Local cMsgPeca

Local cVMBAlias := GetNextAlias()
Local cAliasSG := "TRECVMB"

Local nVMBRecno

Local cMVGRUVEI
Local cAliasAMS := "TAMS"

Local cProbConvPeca

Local lErro := .f.

Local lVMB_SREEMB := (VMB->(FieldPos("VMB_SREEMB")) <> 0)
Local lSemReembolso := .t.

Local cPerg := "OFINJD15"
Pergunte(cPerg,.f.,,,,.f.)

cGSerDesloc  := MV_PAR20	// "02"
cCSerDesloc  := MV_PAR21	// "DESLOC         "
cTSerDesloc  := MV_PAR22	// "DJD"

cTTSerRev	 := MV_PAR23	// "GJD "
cGSerRev     := MV_PAR24	// "01"
cCodSecRev   := MV_PAR25	// "001"
cDepGarRev   := MV_PAR26	// "G"
cTipSerRev   := MV_PAR27	// "MTI"

cTTPecPMP    := MV_PAR28	// "GJDP"
cTTSerPMP    := MV_PAR29	// Tipo de tempo de Servico de PMP
cGSerPMP     := MV_PAR30	// "01"
cCodSecPMP   := MV_PAR31	// Codigo da Secao para servico de PMP
cDepGarPMP   := MV_PAR32	// "G"
cTipSerPMP   := MV_PAR33	// Tipo de Servico de Revisao
cCodServPMP	 := MV_PAR35	// Codigo de Servico PMP

// Conversao de Unidade de Medida
Private aConvUM := {}
If !Empty(MV_PAR38)
	aConvUM := StrTokArr(AllTrim(MV_PAR38),";")
	aSort(aConvUM)
Else
	AADD( aConvUM , "BD/L " )
EndIf
//

//Cancelamento
If cSituac == "C"

	//Otavio - 22/01/2014 - Há casos onde a John Deere autoriza valores diferentes dos enviados. Por isso, o OFINJD15 realiza o cancelamento e em seguida a requisição com os valores retornados da John Deere.
	If FM_PILHA("OFINJD15") //Cancelamento Manual
		Return .t.
	EndIf

	//Otavio -  23/01/2014 - Verifica se para esta liberação (VOO) foi emitida nota e se possui serviço.
	cSQL := "SELECT VOO.VOO_SERNFI, VOO.VOO_NUMNFI, VOO.VOO_TOTSRV, VOO.VOO_TOTPEC "
	cSQL +=  " FROM " + RetSQLName("VOO") + " VOO "
	cSQL += " WHERE VOO.VOO_FILIAL = '" + xFilial("VOO") + "'"
	cSQL +=   " AND VOO.VOO_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VOO.VOO_TIPTEM = '" + cTipTem + "'"
	cSQL +=   " AND VOO.VOO_LIBVOO = '" + cLibVOO + "'"
	cSQL +=   " AND VOO.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVOO, .T., .T. )

	//Não encontrou nota fiscal. Portanto, não se trata de um cancelamento de nota fiscal e deve ser verificada a garantia JD.
	If Empty(( cAliasVOO )->VOO_SERNFI) .and. Empty(( cAliasVOO )->VOO_NUMNFI) .and. cStatusTT <> "F"

		//Otavio -  11/02/2014 - Se todos os status das SGs deste tipo de tempo da OS nao forem "Nao enviada / Rejeitado / Deletado", será barrado o cancelamento da liberação.
		cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRECNO"
		cSQL += " FROM " + RetSQLName("VMB") + " VMB "
		cSQL +=        " JOIN " + RetSQLName("VMC") + " VMC "
		cSQL +=               " ON VMC_FILIAL = VMB_FILIAL "
		cSQL +=              " AND VMC_CODGAR = VMB_CODGAR "
		cSQL +=              " AND VMC.D_E_L_E_T_ = ' ' "
		cSQL +=        " JOIN " + RetSQLName("VOI") + " VOI "
		cSQL +=               " ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' "
		cSQL +=              " AND VOI.VOI_TIPTEM = '" + cTipTem + "' " // Join deve ser feito com o TT passado como parametro para controle das garantias sem reembolso. Neste caso o Tipo de tempo validado nao é de Garantia ...
		cSQL +=              " AND VOI.D_E_L_E_T_ = ' '"
		cSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=   " AND VMB.VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
		cSQL +=   " AND ( "
		cSQL +=           " VMB.VMB_STATUS NOT IN ('  ','04','05','03','09','12','15') " // Nao enviada / Rejeitado / Deletado / Debitado
		cSQL +=           " OR
		cSQL +=           " ( "
		cSQL +=               " VMB.VMB_STATUS IN ('03','09','12') "
		cSQL +=               " AND "
		cSQL +=               " ( "
		cSQL +=                   " ( "
		cSQL +=                       " VOI.VOI_SITTPO IN ('2','4') " // Validacao de tipo de tempo de garantia 
		cSQL +=                       " AND "
		cSQL +=                       " ( "
		cSQL +=                           " ( ( VMC.VMC_TIPOPS = 'P' OR ( VMC.VMC_TIPOPS = 'O' AND VMC.VMC_CODITE <> ' ' ) ) AND VMC.VMC_VTPECR <> 0 ) " // Ao menos uma peca foi paga
		cSQL +=                           " OR "
		cSQL +=                           " ( ( VMC.VMC_TIPOPS = 'S' OR ( VMC.VMC_TIPOPS = 'O' AND VMC.VMC_CODITE =  ' ' ) ) AND VMC.VMC_VTSERR <> 0 ) " // Ao menos um servico foi pago
		cSQL +=                       " ) "
		cSQL +=                   " ) "
		If lVMB_SREEMB
			cSQL +=                " OR "
			cSQL +=                " ( "
			cSQL +=                    " VOI.VOI_SITTPO IN ('1','3') " // Validacao de tipo de tempo de cliente ou interno
			cSQL +=                    " AND "
			cSQL +=                    " VMB.VMB_SREEMB = '1' " //  Garantia sem reembolso ... 
			cSQL +=                " ) " //  Garantia sem reembolso ... 
		EndIf
		cSQL +=               " ) "
		cSQL +=           " ) "
		cSQL +=       " ) "
		cSQL +=   " AND VMB.D_E_L_E_T_ = ' ' "
		cSQL +=   " AND ( ( VMC.VMC_TIPTEM = '" + cTipTem + "' AND VOI.VOI_SITTPO = '2' ) " // Neste ponto considerar somente tipo de tempo de GARANTIA
		If lVMB_SREEMB
			cSQL +=         " OR "
			cSQL +=         " ( VOI.VOI_SITTPO IN ('1','3') AND VMB.VMB_SREEMB = '1' "
			cSQL +=          " AND EXISTS ( SELECT VO4.VO4_TIPTEM "
			cSQL +=                       " FROM " + RetSQLName("VO4") + " VO4 "
			cSQL +=                       " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
			cSQL +=                         " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"
			cSQL +=                         " AND VO4.VO4_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cSQL +=                         " AND VO4.D_E_L_E_T_ = ' ' ) )" // Validacao especifica para garantias sem reembolso 
		EndIf
		cSQL += " )"
		nRecVMB := FM_SQL(cSQL)

		If nRecVMB <> 0
			VMB->(dbGoTo(nRecVMB))
			cAuxTexto := CHR(13) + CHR(10) + CHR(13) + CHR(10) + AllTrim(RetTitle("VMB_CODGAR")) + ": " + VMB->VMB_CODGAR
			If lVMB_SREEMB .and. VMB->VMB_SREEMB == "1"
				cAuxTexto += CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0035 // "Esta ordem de serviço possui uma solicitação de garantia sem reembolso relacionada."
			EndIf
			MsgAlert(STR0019 + cAuxTexto,STR0018) // "Existem solicitações de garantia para esta ordem de serviço que foram transmitidas para a John Deere. Não será possível cancelar a liberação deste tipo de tempo se o status destas solicitações estiverem válidas na John Deere!"
			( cAliasVOO )->( dbCloseArea() )
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			Return (.f.)
		EndIf

		// Remove as Pecas/Servicos da Liberacao de Tipo de Tempo que está sendo cancelada ...
		cSQL := "SELECT VMC_CODGAR, VMC_SEQGAR "
		cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
		cSQL +=         " JOIN " + RetSQLName("VMC") + " VMC ON VMC.VMC_FILIAL = VMB.VMB_FILIAL AND VMC.VMC_CODGAR = VMB.VMB_CODGAR AND VMC.D_E_L_E_T_ = ' '"
		cSQL += "WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=  " AND VMB.VMB_NUMOSV = '" +  VO1->VO1_NUMOSV + "'"
		cSQL +=  " AND VMB.VMB_STATUS = '  '" // Remove somente quando a solicitacao nao foi enviada
		cSQL +=  " AND VMB.D_E_L_E_T_ = ' '"
		cSQL +=  " AND VMC.VMC_LIBVOO = '" + cLibVOO + "'"
		cSQL +=  " AND VMC.VMC_ORIGEM <> '1'" // Remove itens que foram importados do webservice (Revisao/PMP)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasREQ , .F., .T. )
		While !(cAliasREQ)->(Eof())

			cCodGar := (cAliasREQ)->VMC_CODGAR

			aIteTemp := {}
			AADD( aIteTemp , { "LINPOS"    , "VMC_SEQGAR" , (cAliasREQ)->VMC_SEQGAR } )
			AADD( aIteTemp , { "AUTDELETA" , "S" , Nil })

			AADD( aIteSGJD,aClone(aIteTemp))

			(cAliasREQ)->(dbSkip())
		End
		(cAliasREQ)->(dbCloseArea())

		If Len(aIteSGJD) > 0

			VMB->(dbSetOrder(1))
			VMB->(dbSeek(xFilial("VMB") + cCodGar))

			AADD( aCabSGJD , { "VMB_CODGAR" , cCodGar , NIL } )
			AADD( aCabSGJD , { "VMB_TIPGAR" , VMB->VMB_TIPGAR , NIL } )

			lMSHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| OFINJD15(x,y,z)},aCabSGJD,aIteSGJD,4)
			If lMsErroAuto
				MsUnlockAll()
				MostraErro()
				Return .f.
			EndIf
			//
		EndIf
		//

	// Encontrou nota fiscal e série para este tipo de tempo.
	// Então se trata de um cancelamento da emissão da NF.
	Else

		If lVMB_SREEMB .and. OFNJD18TTPUBLICO( cTipTem )
			( cAliasVOO )->( dbCloseArea() )
			Return .t.
		EndIf

		// Cancelamento da NF de Servicos
		If ( cAliasVOO )->VOO_TOTSRV <> 0

			lErro := .f.

			cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRECNO"
			cSQL += " FROM " + RetSQLName("VMB") + " VMB JOIN " + RetSQLName("VMC") + " VMC ON VMC.VMC_FILIAL = VMB.VMB_FILIAL AND VMC.VMC_CODGAR = VMB.VMB_CODGAR AND VMC.D_E_L_E_T_ = ' '"
			cSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
			cSQL += " AND VMB.VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cSQL += " AND "
			cSQL += " ( ( VMB.VMB_SRVNNF = '" + ( cAliasVOO )->VOO_NUMNFI + "'" // Mesma NF da liberação
			cSQL += "     AND VMB.VMB_SRVSNF = '" + ( cAliasVOO )->VOO_SERNFI + "' )" // Mesma série da liberação
			cSQL += "   OR VMC.VMC_LIBVOO = '" + cLibVOO + "' ) "
			cSQL += " AND VMB.D_E_L_E_T_ = ' ' "
			cSQL += " AND VMC.VMC_TIPTEM = '" + cTipTem + "'"
			nRecVMB := FM_SQL(cSQL)
			If nRecVMB <> 0
				VMB->(dbGoTo(nRecVMB))
				 // VMB_STATSG DIFERENTE DE 2=NF Enviada / 5=Pagto Efetuado
				 // OU
				 // VMB_STATUS IGUAL A 04=Rejeitado/05=Deletado/07=Retornado
				If (!(VMB->VMB_STATSG $ "2/5") .or. VMB->VMB_STATUS $ "04/05/07") .OR. OFNJD15SERIE5000()
					If !RecLock("VMB",.f.)
						lErro := .t.
					Else
						VMB->VMB_SRVSNF := " "
						VMB->VMB_SRVNNF := " "
						VMB->VMB_STATSG := "1" //Pendente NF
						VMB->(MsUnLock())
					EndIf
				Else
					lErro := ! OFNJD18CancNFSTransm(cAliasVOO)
				EndIf
			Else
				MsgStop(STR0021,STR0018) // "A nota fiscal deste tipo de tempo não foi encontrada em nenhuma solicitação de garantia pertencente a esta ordem de serviço! Verifique!"
				lErro := .t.
			EndIf

			If lErro
				( cAliasVOO )->( dbCloseArea() )
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				Return(.f.)
			EndIf

		// Cancelamento da NF de Pecas/Servicos
		Else//If ( cAliasVOO )->VOO_TOTPEC <> 0
			cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRENO"
			cSQL +=  " FROM " + RetSQLName("VMB") + " VMB JOIN " + RetSQLName("VMC") + " VMC ON VMC_FILIAL = VMB_FILIAL AND VMC_CODGAR = VMB_CODGAR AND VMC.D_E_L_E_T_ = ' '"
			cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
			cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cSQL +=   " AND VMB_MEMTYP = '1'" // Pagamento Efetuado
			cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"
			cSQL +=   " AND VMC.VMC_TIPTEM = '" + cTipTem + "'"
			cSQL +=   " AND VMC.VMC_LIBVOO = '" + cLibVOO + "'"
			nAuxRecno := FM_SQL(cSQL)
			//
			If nAuxRecno <> 0
				VMB->(dbGoTo(nAuxRecno))

				// Verifica se a SG possui somente pecas ...
				If (( cAliasVOO )->VOO_TOTPEC <> 0 .AND. OFNJD18SOPECA( VMB->VMB_CODGAR )) .OR. OFNJD15SERIE5000()
					If !RecLock("VMB",.f.)
						( cAliasVOO )->( dbCloseArea() )
						DisarmTransaction()
						RollbackSx8()
						MsUnlockAll()
						Help("  ",1,"REGNLOCK")
						Return(.f.)
					EndIf
					VMB->VMB_STATSG := "1" //Pendente NF
					VMB->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf

	( cAliasVOO )->( dbCloseArea() )

EndIf

// Abertura de OS
If cSituac == "A"

	If Len(aRetWS) == 0
		Return .t.
	EndIf

	// Verifica se ja foi criada uma OS para a mesma Revisao / PMP
	cSQL := "SELECT VMB_CODGAR, VMB_NUMOSV "
	cSQL +=  " FROM " + RetSQLName("VMB")
	cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
	cSQL +=   " AND VMB_CHASSI = '" + AllTrim(VV1->VV1_CHASSI) + "'"
	If aRetWS[1] == 1
		cSQL +=   " AND VMB_TIPGAR = 'ZZMK'"
		cSQL +=   " AND VMB_SUBGAR = 'MTC'"
		cSQL +=   " AND VMB_PLAMAN = '" + AllTrim(aRetWS[2,1]) + "'"
		cSQL +=   " AND VMB_INTSRV = '" + AllTrim(aRetWS[2,8]) + "'"
	Else
		cSQL +=   " AND VMB_TIPGAR = 'ZPIP'"
		cSQL +=   " AND VMB_NROPIP = '" + aRetWS[2,1] + "'"
	EndIf
	cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15')" // 04=REJEITADO ou 05=DELETADO ou 15=DEBITADO
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cVMBAlias , .F., .T. )
	If !(cVMBAlias)->(Eof())
		MsgStop(STR0014 +chr(13)+chr(10)+chr(13)+chr(10)+; // "Já existe uma solicitação de garantia o programa selecionado."
				STR0015 + ": " + (cVMBAlias)->(VMB_CODGAR)+chr(13)+chr(10)+; // "Solicitação de Garantia
				STR0016 + ": " + (cVMBAlias)->(VMB_NUMOSV)) // "Ordem de Serviço

		(cVMBAlias)->(dbCloseArea())
		lRetorno := .f.
		Return .f.
	EndIf
	(cVMBAlias)->(dbCloseArea())
	//

	// PMP, valida se todas as peças possuem um  TES para exportar para a OS
	If aRetWS[1] == 2 .and. Len(aRetWS[4]) > 0

		VOI->(dbSetOrder(1))
		VOI->(dbSeek(xFilial("VOI") + cTTPecPMP ))

		aImpFatPar := {"","",""}
		cCodMarca := OFNJD18CodMarca(VV1->VV1_CODMAR)
		If !( FG_TIPTPFAT(cTTPecPMP,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",cCodMarca,'P',,.F.,.t.) )
			lRetorno := .f.
			Return .f.
		EndIf

		SB1->(dbSetOrder(1))

		// Gera VSJ das peças ...
		For nCntFor := 1 to Len(aRetWS[4])
			SB1->(dbSeek(xFilial("SB1") + aRetWS[4,nCntFor,2] ))
			cAuxTES := ""
			If !Empty(VOI->VOI_CODOPE)
				cAuxTES := MaTesInt(2,VOI->VOI_CODOPE,aImpFatPar[1],aImpFatPar[2],"C",SB1->B1_COD)
				SF4->(dbSetOrder(1))
				If !Empty(cAuxTES)
					If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
						cAuxTES := ""
					EndIf
				EndIf
			EndIf
			If Empty(cAuxTES)
				cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
				If !Empty(cAuxTES)
					If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
						cAuxTES := ""
					EndIf
				EndIf
			Endif

			If Empty(cAuxTES)
				MsgStop(STR0026 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
						AllTrim(RetTitle("C6_PRODUTO")) + ": " + SB1->B1_GRUPO + " - " + SB1->B1_CODITE + CHR(13) + CHR(10) +;
						AllTrim(RetTitle("VV0_CODCLI")) + ": " + aImpFatPar[1] + " - " + aImpFatPar[2] + CHR(13) + CHR(10) +;
						AllTrim(RetTitle("VV0_OPEMOV")) + ": " + VOI->VOI_CODOPE + CHR(13) + CHR(10) +;
						AllTrim(RetTitle("VOI_TIPTEM")) + ": " + VOI->VOI_TIPTEM ) // "Não é possível continuar, peça não possui um TES válido."
				lRetorno := .f.
				Return .f.
			EndIf

		Next nCntFor
	EndIf
	//

	Do Case
		// REVISAO
		Case aRetWS[1] == 1

			aImpFatPar := {"","",""}
			cCodMarca := OFNJD18CodMarca(VV1->VV1_CODMAR)
			If !( FG_TIPTPFAT(cTTSerRev,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",cCodMarca,'S',,.F.,.t.) )
				lRetorno := .f.
				Return .f.
			EndIf

			// Requisita servicos ...
			For nCntFor := 1 to Len(aRetWS[4])

				nTempoSrvc := OFNJD18TEMPAD( "VO4" , aRetWS[4,nCntFor,7] )
				If nTempoSrvc == 0
					Loop
				EndIf

				lSemReembolso := .f.
				
				aAuxIteVO4 := {}
				AADD(aAuxIteVO4, { "VO4_NUMOSV" , VO1->VO1_NUMOSV , nil } )
				AADD(aAuxIteVO4, { "VO4_TIPTEM" , cTTSerRev , nil } )

				If aRetWS[4,nCntFor,3] == "WTYLABORA"
					AADD(aAuxIteVO4, { "VO4_GRUSER" , cGSerRev, nil } )
					AADD(aAuxIteVO4, { "VO4_CODSER" , aRetWS[4,nCntFor,9], nil } )
				EndIf

				AADD(aAuxIteVO4, { "VO4_TIPSER" , cTipSerRev , nil } )
				AADD(aAuxIteVO4, { "VO4_TEMPAD" , nTempoSrvc , nil } )
				AADD(aAuxIteVO4, { "VO4_CODSEC" , cCodSecRev , nil } )
				AADD(aAuxIteVO4, { "VO4_DEPGAR" , cDepGarRev , nil } )
				AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

			Next nCntFor
			//

			// Outros Creditos (Deslocamento) ...
			For nCntFor := 1 to Len(aRetWS[5])
				// Deslocamento
				If aRetWS[5,nCntFor,4] <> "WTYSUBL8"
					Loop
				EndIf
				//

				lSemReembolso := .f.
				
				If nCntFor == 1
					aAuxIteVO4 := {}
					AADD(aAuxIteVO4, { "VO4_NUMOSV" , VO1->VO1_NUMOSV , nil } )
					AADD(aAuxIteVO4, { "VO4_TIPTEM" , cTTSerRev , nil } )
					AADD(aAuxIteVO4, { "VO4_GRUSER" , cGSerDesloc , nil } )
					AADD(aAuxIteVO4, { "VO4_CODSER" , cCSerDesloc , nil } )
					AADD(aAuxIteVO4, { "VO4_TIPSER" , cTSerDesloc , nil } )
					AADD(aAuxIteVO4, { "VO4_KILROD" , 0 , nil } )
					AADD(aAuxIteVO4, { "VO4_CODSEC" , cCodSecRev , nil } )
					AADD(aAuxIteVO4, { "VO4_DEPGAR" , cDepGarRev , nil } )
					AADD( aIteVO4 , aClone( aAuxIteVO4 ) )
				EndIf
				aIteVO4[ Len(aIteVO4) , aScan(aIteVO4[Len(aIteVO4)], { |x| x[1] == "VO4_KILROD"}) ,2 ] += aRetWS[5,nCntFor,3]

				If aRetWS[5,nCntFor,3] == 0 //Quilometragem zerada.
					MsgStop(STR0017,STR0018) // "Existe(m) serviço(s) de Outros Crédito (Deslocamento) com quilometragem zerada. Entre em contato com a John Deere!"
					lRetorno := .f.
					Return .f.
				EndIf

			Next nCntFor
			//

			If Len(aIteVO4) > 0
				lMSHelpAuto := .t.
				lMsErroAuto := .f.
				MSExecAuto({|x,y,z| OFIOM030(,,x,y,z)},{},aIteVO4,2)

				If lMsErroAuto
					MsUnlockAll()
					MostraErro()
					lRetorno := .f.
					Return .f.
				Endif
				//
			EndIf

			// Gera solicitação de garantia
			AADD( aCabSGJD , { "VMB_TIPGAR" , "ZZMK" , NIL } )
			AADD( aCabSGJD , { "VMB_SUBGAR" , "MTC" , NIL } )
			AADD( aCabSGJD , { "VMB_NUMOSV" , VO1->VO1_NUMOSV , NIL } )
			AADD( aCabSGJD , { "VMB_CHASSI" , VO1->VO1_CHASSI , NIL } )
			AADD( aCabSGJD , { "VMB_CHAINT" , VO1->VO1_CHAINT , NIL } )
			AADD( aCabSGJD , { "VMB_TIPMAQ" , aRetWS[2,2] , NIL } )
			AADD( aCabSGJD , { "VMB_DTFALH" , dDataBase , NIL } )
			AADD( aCabSGJD , { "VMB_PLAMAN" , AllTrim(aRetWS[2,1])  , NIL } )
			AADD( aCabSGJD , { "VMB_INTSRV" , AllTrim(aRetWS[2,8])  , NIL } )
			//		AADD( aCabSGJD , { "VMB_DATMAN" , dDataBase , NIL } )
			If AllTrim(aRetWS[2,1]) == "PDI"
				AADD( aCabSGJD , { "VMB_NOTRAV" , "0" , NIL } )
			EndIf
			AADD( aCabSGJD , { "VMB_QTDUTI" , VO1->VO1_KILOME , NIL } )
			AADD( aCabSGJD , { "VMB_UNIMED" , "H" , NIL } )
			//

			If lSemReembolso .and. lVMB_SREEMB
				AADD( aCabSGJD , { "VMB_SREEMB" , "1" , NIL } )
				AADD( aCabSGJD , { "VMB_NOTRAV" , "0" , NIL } )
			EndIf

			For nCntFor := 1 to Len(aRetWS[4])

				nTempoSrvc := OFNJD18TEMPAD( "VMC" , aRetWS[4,nCntFor,7] )
			
				aIteTemp := {}
				AADD( aIteTemp , { "VMC_TIPOPS" , "S" , NIL } )
				AADD( aIteTemp , { "VMC_TIPTEM" , cTTSerRev , nil } )	// definir como encontrar o tipo de tempo correto
				AADD( aIteTemp , { "VMC_TIPTRA" , aRetWS[4,nCntFor,3] , NIL } )

				If aRetWS[4,nCntFor,3] == "WTYLABORA"
					AADD(aIteTemp, { "VMC_GRUSER" , cGSerRev, nil } )
					AADD(aIteTemp, { "VMC_CODSER" , aRetWS[4,nCntFor,9], nil } )
				EndIf

				AADD( aIteTemp , { "VMC_QTDTRA" , nTempoSrvc , NIL } )
				AADD( aIteTemp , { "VMC_LOCTRA" , aRetWS[4,nCntFor,5]  , NIL } )
				AADD( aIteTemp , { "VMC_TECHID" , "0" , NIL } )
				AADD( aIteTemp , { "VMC_ORIGEM" , "1" , NIL } )
				AADD(aIteSGJD,aClone(aIteTemp))
			Next nCntFor

			For nCntFor := 1 to Len(aRetWS[5])
				aIteTemp := {}
				AADD( aIteTemp , { "VMC_TIPOPS" , "O" , NIL } )
				AADD( aIteTemp , { "VMC_TIPTEM" , cTTSerRev , nil } )	// definir como encontrar o tipo de tempo correto

				// Deslocamento
				If aRetWS[5,nCntFor,4] == "WTYSUBL8"
					AADD(aIteTemp, { "VMC_GRUSER" , cGSerDesloc , nil } )
					AADD(aIteTemp, { "VMC_CODSER" , cCSerDesloc , nil } )
				EndIf

				AADD( aIteTemp , { "VMC_CODMAT" , aRetWS[5,nCntFor,4] , NIL } )
				If aRetWS[5,nCntFor,4] <> "WTYSUBL7"
					AADD( aIteTemp , { "VMC_CUSMAT" , aRetWS[5,nCntFor,3] , NIL } )
				Endif
				AADD( aIteTemp , { "VMC_ORIGEM" , "1" , NIL } )
				AADD(aIteSGJD,aClone(aIteTemp))
			Next nCntFor

			lMSHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| OFINJD15(x,y,z)},aCabSGJD,aIteSGJD,3)
			If lMsErroAuto
				MsUnlockAll()
				MostraErro()
				lRetorno := .f.
				Return .f.
			Endif
			//

		// Campanha (PMP/PIP)
		Case aRetWS[1] == 2

			aImpFatPar := {"","",""}
			cCodMarca := OFNJD18CodMarca(VV1->VV1_CODMAR)
			If !( FG_TIPTPFAT(cTTSerPMP,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",cCodMarca,'S',,.F.,.t.) )
				lRetorno := .f.
				Return .f.
			EndIf

			// Requisita servicos ...
			For nCntFor := 1 to Len(aRetWS[3])
				AADD(aAuxIteVO4, { "VO4_NUMOSV" , VO1->VO1_NUMOSV , nil } )
				AADD(aAuxIteVO4, { "VO4_TIPTEM" , cTTSerPMP , nil } )	// definir como encontrar o tipo de tempo correto
				AADD(aAuxIteVO4, { "VO4_GRUSER" , cGSerPMP, nil } )		// Definir onde vem o grupo de servico
				AADD(aAuxIteVO4, { "VO4_CODSER" , cCodServPMP , nil } )
				AADD(aAuxIteVO4, { "VO4_TIPSER" , cTipSerPMP , nil } )
				AADD(aAuxIteVO4, { "VO4_TEMPAD" , OFNJD18TEMPAD( "VO4" , aRetWS[3,nCntFor,7]) , nil } )
				AADD(aAuxIteVO4, { "VO4_CODSEC" , cCodSecPMP , nil } )
				AADD(aAuxIteVO4, { "VO4_DEPGAR" , cDepGarPMP , nil } )
				AADD( aIteVO4 , aClone( aAuxIteVO4 ) )
			Next nCntFor

			If Len(aIteVO4) > 0
				lMSHelpAuto := .t.
				lMsErroAuto := .f.

				MSExecAuto({|x,y,z| OFIOM030(,,x,y,z)},{},aIteVO4,2)
				If lMsErroAuto
					MsUnlockAll()
					MostraErro()
					lRetorno := .f.
					Return .f.
				Endif
			Endif
			//

			VOI->(dbSetOrder(1))
			VOI->(dbSeek(xFilial("VOI") + cTTPecPMP ))

			SB1->(dbSetOrder(1))

			SF4->(dbSetOrder(1))

			aImpFatPar := {"","",""}
			cCodMarca := OFNJD18CodMarca(VO1->VO1_CODMAR)
			If !( FG_TIPTPFAT(cTTPecPMP,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",cCodMarca,'P',,.F.,.t.) )
				lRetorno := .f.
				Return .f.
			EndIf

			// Gera VSJ das peças ...
			For nCntFor := 1 to Len(aRetWS[4])

				SB1->(dbSeek(xFilial("SB1") + aRetWS[4,nCntFor,2] ))

				cAuxTES := ""
				If !Empty(VOI->VOI_CODOPE)
					cAuxTES := MaTesInt(2,VOI->VOI_CODOPE,aImpFatPar[1],aImpFatPar[2],"C",SB1->B1_COD)
					SF4->(dbSetOrder(1))
					If !Empty(cAuxTES)
						If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
							cAuxTES := ""
						EndIf
					EndIf
				EndIf
				If Empty(cAuxTES)
					cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
					If !Empty(cAuxTES)
						If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
							cAuxTES := ""
						EndIf
					EndIf
				Endif

				nValPec := FG_VALPEC(cTTPecPMP,,SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)

				// Verifica se deve fazer conversao de UM ...
				nQtde := aRetWS[4,nCntFor,7]
				cUM   := SB1->B1_SEGUM
				OFNJD18CONV( SB1->B1_COD , SB1->B1_UM , SB1->B1_SEGUM , @nQtde , @cUM )
				//

				AADD(aIteVSJ, Array(22))
				aIteVSJ[nCntFor,01] := SB1->B1_GRUPO       // 01 - Grupo do Item
				aIteVSJ[nCntFor,02] := SB1->B1_CODITE      // 02 - Codigo do Item
				aIteVSJ[nCntFor,03] := nQtde               // 03 - Qtde
				aIteVSJ[nCntFor,04] := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") // 04
				aIteVSJ[nCntFor,05] := " "                 // 05 - Grupo do Inconveniente
				aIteVSJ[nCntFor,06] := " "                 // 06 - Codigo do Inconveniente
				aIteVSJ[nCntFor,07] := cTTPecPMP           // 07 - Tipo de Tempo
				aIteVSJ[nCntFor,08] := aImpFatPar[1]       // 08 - Cliente Faturar Para
				aIteVSJ[nCntFor,09] := aImpFatPar[2]       // 09 - Loja Faturar Para
				aIteVSJ[nCntFor,10] := " "                 // 10 - Seq. do Inconveniente
				aIteVSJ[nCntFor,11] := " "                 // 11 - Numero do Orcamento
				aIteVSJ[nCntFor,12] := cAuxTES             // 12 - TES
				aIteVSJ[nCntFor,13] := SF4->F4_ESTOQUE     // 13 - TES Mov. Estoque ??? (F4_ESTOQUE)
				aIteVSJ[nCntFor,14] := nValPec             // 14 - Valor da Peca
				aIteVSJ[nCntFor,15] := cDepGarPMP          // 15 - Depto Garantia
				aIteVSJ[nCntFor,16] := ""                  // 16 - Depto Interno
				aIteVSJ[nCntFor,17] := ""                  // 17 - Lote
				aIteVSJ[nCntFor,18] := ""                  // 18 - Sub-Lote
				aIteVSJ[nCntFor,19] := IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),Space(15)) // 19 - Endereco DMS
				aIteVSJ[ncntFor,20] := "3"                 // 20 - Origem do registro
				aIteVSJ[ncntFor,21] := CtoD(" ")           // 21 - Validade do Lote
				aIteVSJ[ncntFor,22] := 0                   // 22 - Valor de Desconto

				// Registra Peças / Kits
				aIteTemp := {}
				AADD( aIteTemp , { "VMC_TIPOPS" , "P" , NIL } )
				AADD( aIteTemp , { "VMC_TIPTEM" , cTTPecPMP , nil } )	// definir como encontrar o tipo de tempo correto
				AADD( aIteTemp , { "VMC_GRUITE" , SB1->B1_GRUPO  , NIL } )
				AADD( aIteTemp , { "VMC_CODITE" , SB1->B1_CODITE , NIL } )
				AADD( aIteTemp , { "VMC_PARTNO" , IIf(lB1CODFAB .and. !Empty(SB1->B1_CODFAB),SB1->B1_CODFAB,SB1->B1_CODITE) , NIL } )
				AADD( aIteTemp , { "VMC_QTDPEC" , aRetWS[4,nCntFor,7] , NIL } )
				AADD( aIteTemp , { "VMC_UM"     , IIf( nQtde <> aRetWS[4,nCntFor,7] .AND. !Empty(SB1->B1_SEGUM) , SB1->B1_SEGUM , SB1->B1_UM ) , NIL } )
				AADD( aIteTemp , { "VMC_ORIGEM" , "1" , NIL } )
				AADD(aIteSGJD,aClone(aIteTemp))
				//

			Next nCntFor

			If Len(aIteVSJ) > 0
				aItensNImp := {}
				If FM_IMPVSJ( @aItensNImp , , VO1->VO1_NUMOSV , aIteVSJ , 2 )
					If Len(aItensNImp[2]) > 0
						cTitAviso := STR0028 // "Peça(s) sem saldo em estoque!"
						cMsgPeca  := STR0029 // "A(s) peça(s) abaixo está(ão) com saldo em estoque insuficiente para realizar a requisição! Verifique:"+CHR(13)+CHR(10)
						For nii := 1 to Len(aItensNImp[2])
							cMsgPeca += STR0030 + ": " + AllTrim(aItensNImp[2,nii,4]) + ; // "Grupo da Peça"
								" / " + STR0031 + ": " + AllTrim(aItensNImp[2,nii,5]) + ; // "Código da Peça"
								" / " + STR0032 + ": " + CValtoChar(aItensNImp[2,nii,10]) + CHR(13)+CHR(10) // "Quantidade a requisitar"
						Next nCntFor
						MsgStop(cMsgPeca,cTitAviso)
						lRetorno := .f.
						Return .f.
					EndIf
				Else
					lRetorno := .f.
					Return .f.
				EndIf
			EndIf
			//

			AADD( aCabSGJD , { "VMB_NUMOSV" , VO1->VO1_NUMOSV , NIL } )
			AADD( aCabSGJD , { "VMB_TIPGAR" , "ZPIP" , NIL } )
			AADD( aCabSGJD , { "VMB_CHASSI" , VO1->VO1_CHASSI , NIL } )
			AADD( aCabSGJD , { "VMB_CHAINT" , VO1->VO1_CHAINT , NIL } )
			AADD( aCabSGJD , { "VMB_DTABER" , , NIL } )
			AADD( aCabSGJD , { "VMB_NROPIP" , aRetWS[2,1] , NIL } )
			AADD( aCabSGJD , { "VMB_KEYPAR" , aRetWS[2,1] , NIL } )
			AADD( aCabSGJD , { "VMB_QTDUTI" , VO1->VO1_KILOME , NIL } )
			AADD( aCabSGJD , { "VMB_UNIMED" , "H" , NIL } )
			AADD( aCabSGJD , { "VMB_DTFALH" , dDataBase , NIL } )

			// Registra Servicos ...
			For nCntFor := 1 to Len(aRetWS[3])
				aIteTemp := {}
				AADD( aIteTemp , { "VMC_TIPOPS" , "S" , NIL } )
				AADD( aIteTemp , { "VMC_TIPTEM" , cTTSerPMP , nil } )	// definir como encontrar o tipo de tempo correto
				AADD( aIteTemp , { "VMC_TIPTRA" , aRetWS[3,nCntFor,4] , NIL } )
				AADD( aIteTemp , { "VMC_GRUSER" , cGSerPMP , nil } )		// Definir onde vem o grupo de servico
				AADD( aIteTemp , { "VMC_CODSER" , cCodServPMP , nil } )
				AADD( aIteTemp , { "VMC_QTDTRA" , OFNJD18TEMPAD( "VMC" , aRetWS[3,nCntFor,7] ) , NIL } )
				AADD( aIteTemp , { "VMC_LOCTRA" , aRetWS[3,nCntFor,5]  , NIL } )
				AADD( aIteTemp , { "VMC_ORIGEM" , "1" , NIL } )
				AADD(aIteSGJD,aClone(aIteTemp))
			Next nCntFor
			//

			lMSHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| OFINJD15(x,y,z)},aCabSGJD,aIteSGJD,3)
			If lMsErroAuto
				MsUnlockAll()
				MostraErro()
				lRetorno := .f.
				Return .f.
			EndIf
			//
	EndCase
EndIf

// Validacao da Liberação do Tipo de Tempo
If cSituac == "VD"

	If FM_PILHA("OFINJD15") //Liberacao Automatica na Atualizacao da OS
		Return .t.
	EndIf

	If ! ExistFunc("OM1400013_PecaUmaLinha")
		Return .t.
	EndIf

	If ! OM1400013_PecaUmaLinha(VO1->VO1_NUMOSV, cTipTem) .and. ! MsgNoYes(STR0041 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0042) // "Liberar o tipo de tempo com peças gerando mais de uma linha de requisição pode ocasionar problema de arredondamento de casas decimais de valor no momento da atualização da Ordem de Serviço." / "Deseja continuar a liberação do tipo de tempo?"
		lRetorno := .f.
		Return .f.
	EndIf

EndIf

// Liberação do Tipo de Tempo
If cSituac == "D"

	// Liberacao no momento da atualizacao da OS
	If FM_PILHA("OFINJD15") //Cancelamento Manual
		Return .t.
	EndIf

	// Esta Atualizando a O.S.
	cSQL := "SELECT VMB_STATSG "
	cSQL += " FROM " + RetSQLName("VMB") + " VMB "
	cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
	cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VMB_STATUS NOT IN ('  ','04','05','15') " // Nao enviada / Rejeitado / Deletado / Debitado
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == "4" // 4=Warranty Memo Proc.
		Return .t.
	EndIf
	//

	If lVMB_SREEMB .and. OFNJD18SEMREEMBOLSO( VO1->VO1_NUMOSV )
		MsgStop( STR0035 + CHR(13) + CHR(10) + STR0036, STR0006) // "Esta ordem de serviço possui uma solicitação de garantia sem reembolso relacionada." // "Para prosseguir com a liberação, utilize um tipo de tempo que não seja de garantia."
		lRetorno := .f.
		Return .f.
	EndIf

	cCodGar := ""

	// Se encontrar alguma SG adiciona os itens nela
	cSQL := "SELECT R_E_C_N_O_ VMBREC "
	cSQL += " FROM " + RetSQLName("VMB") + " VMB "
	cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
	cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VMB_STATUS IN ('  ') " // Somente garantias que não foram transmitidas podem ser liberadas. A liberação do tipo de tempo deve ocorrer antes da transmissão da garantia.
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	nRecVMB := FM_SQL(cSQL)

	If nRecVMB <> 0
		VMB->(dbGoTo(nRecVMB))

		lNovaSG := .f.

		AADD( aCabSGJD , { "VMB_CODGAR" , VMB->VMB_CODGAR , NIL } )
		cTipoGar := VMB->VMB_TIPGAR
		cCodGar := VMB->VMB_CODGAR
	Else

		cWhenParambox := ".t."

		// Verifica se é um caso de SG de Revisao/PMP
		// Pesquisa considera os registros deletados, pois o usuario pode excluir a SG depois que ela foi deletada do portal da John Deere
		cSQL := "SELECT VMB_CODGAR, VMB_TIPGAR , VX5_DESCRI "
		cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
		cSQL +=  " JOIN " + RetSQLName("VX5") + " VX5 ON VX5.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5_CODIGO = VMB_TIPGAR AND VX5_CHAVE = '006' AND VX5.D_E_L_E_T_ = ' ' "
		cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
		cSQL +=   " AND VMB_TIPGAR IN ('ZPIP','ZZMK')"
		cSQL +=   " AND VMB_REPARO = '00' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5 , .F., .T. )
		If !(cAliasVX5)->(Eof())
			cWhenParambox := ".f."
			cCodGar := (cAliasVX5)->VMB_CODGAR
			AADD(aTpGarCod , AllTrim((cAliasVX5)->VMB_TIPGAR) )
			AADD(aTpGarDes , (cAliasVX5)->VX5_DESCRI )
		EndIf
		(cAliasVX5)->(dbCloseArea())
		//

		// Parambox para solicitar o tipo de garantia que sera gerado
		cSQL := "SELECT VX5_CODIGO , VX5_DESCRI FROM " + RetSQLName("VX5") + " VX5 "
		cSQL += " WHERE VX5.VX5_FILIAL = '" + xFilial("VX5") + "'"
		cSQL +=   " AND VX5.VX5_CHAVE = '006'"
		If !cMVGARJD_T
			cSQL +=   " AND VX5.VX5_CODIGO NOT IN ('ZPIP','ZZMK') " // Não pode ser PMP ou Revisao
		EndIf
		cSQL +=   " AND VX5.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5 , .F., .T. )
		While !(cAliasVX5)->(Eof())
			AADD(aTpGarCod , AllTrim((cAliasVX5)->VX5_CODIGO) )
			AADD(aTpGarDes , (cAliasVX5)->VX5_DESCRI )
			(cAliasVX5)->(dbSkip())
		End
		(cAliasVX5)->(dbCloseArea())

		aRetParam := {}
		// Paramebox para selecionar o tipo de garantia que será criado
		aParParam := {{3,STR0004,1,aTpGarDes,90,,.T.,cWhenParambox}} // "Tipo de Garantia"
		If !ParamBox(aParParam,STR0004,aRetParam) // "Tipo de Garantia"
			lRetorno := .f.
			Return .f.
		EndIf
		cTipoGar := aTpGarCod[aRetParam[1]]
		//

		AADD( aCabSGJD , { "VMB_TIPGAR" , cTipoGar , NIL } )
		AADD( aCabSGJD , { "VMB_NUMOSV" , VO1->VO1_NUMOSV , NIL } )

		lAddChassi := .t.
		If cTipoGar $ "ZPAR/ZZBT"
			VV1->(dbSetOrder(1))
			VV1->(dbSeek(xFilial("VV1") + VO1->VO1_CHAINT))

			cSQL := "SELECT VE1_MARFAB "
			cSQL +=  " FROM " + RetSQLName("VE1")
			cSQL += " WHERE VE1_FILIAL = '" + xFilial("VE1")+"'"
			cSQL +=   " AND VE1_CODMAR = '" + VV1->VV1_CODMAR + "'"
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			If !(FM_SQL(cSQL) $ "JD /GRS/PLA/JDC/HCM")
				lAddChassi := .f.
			EndIf
		EndIf

		// Registro de Revisao ...
		If cTipoGar $ "ZZMK/ZPIP"
			cSQL := "SELECT VMB_TIPMAQ, VMB_PLAMAN, VMB_INTSRV, VMB_NOTRAV, VMB_UNIMED, VMB_NROPIP, VMB_KEYPAR"
			cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
			cSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
			cSQL +=   " AND VMB.VMB_CODGAR = '" + cCodGar + "'"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasSG , .F., .T. )
			If !(cAliasSG)->(Eof())
				If cTipoGar == "ZZMK"
					AADD( aCabSGJD , { "VMB_SUBGAR" , "MTC" , NIL } )
					AADD( aCabSGJD , { "VMB_TIPMAQ" , (cAliasSG)->VMB_TIPMAQ , NIL } )
					AADD( aCabSGJD , { "VMB_PLAMAN" , (cAliasSG)->VMB_PLAMAN , NIL } )
					AADD( aCabSGJD , { "VMB_INTSRV" , (cAliasSG)->VMB_INTSRV , NIL } )
					AADD( aCabSGJD , { "VMB_NOTRAV" , (cAliasSG)->VMB_NOTRAV , NIL } )
					AADD( aCabSGJD , { "VMB_UNIMED" , (cAliasSG)->VMB_UNIMED , NIL } )
				Else
					AADD( aCabSGJD , { "VMB_NROPIP" , (cAliasSG)->VMB_NROPIP , NIL } )
					AADD( aCabSGJD , { "VMB_KEYPAR" , (cAliasSG)->VMB_KEYPAR , NIL } )
				EndIf
			End
			(cAliasSG)->(dbCloseArea())

			AADD( aCabSGJD , { "VMB_QTDUTI" , VO1->VO1_KILOME , NIL } )
		EndIf
		//

		If lAddChassi
			AADD( aCabSGJD , { "VMB_CHASSI" , VO1->VO1_CHASSI , NIL } )
			AADD( aCabSGJD , { "VMB_CHAINT" , VO1->VO1_CHAINT , NIL } )
		Else
			AADD( aCabSGJD , { "VMB_CHASSI" , Space(TamSX3("VMB_CHASSI")[1]) , NIL } )
			AADD( aCabSGJD , { "VMB_CHAINT" , Space(TamSX3("VMB_CHAINT")[1]) , NIL } )
		EndIf
		AADD( aCabSGJD , { "VMB_QTDUTI" , VO1->VO1_KILOME , NIL } )
		AADD( aCabSGJD , { "VMB_UNIMED" , "H" , NIL } )
		AADD( aCabSGJD , { "VMB_DTFALH" , VO1->VO1_DATABE , NIL } )

		lNovaSG := .t.

	EndIf

	SB1->(dbSetOrder(7))

	aPeca := FMX_CALPEC( VO1->VO1_NUMOSV , cTipTem , , , .f. , .f. , .t. , .t. , .t. , .f. , .f. , cLibVOO , )
	aSrvc := FMX_CALSER( VO1->VO1_NUMOSV , cTipTem , , , .f. , .f. , .t. , .t. , .t. , .f. , cLibVOO , )
	
	If !lNovaSG
		If cTipoGar == "ZZMK"
			If !OFNJD18VLIB(aSrvc,VMB->VMB_CODGAR)
				MsgStop(STR0034) //"O tempo padrão do serviço na ordem de serviço difere do tempo padrão que consta na solicitação de garantia!"
				lRetorno := .f.
				Return .f.
			EndIf
		EndIf
	EndIf

	// Se não for garantia do tipo bateria, verifica se foi utilizado produto bateria
	cCodBateria := "DQ68477                    /DQ68477                    /DQ68478                    /AH232902                   /CB11480232                 /CQM14168                   /CQM14169                   /SJ10989                    /SJ10990                    /AKK11390                   /"
	cCodBateria += "TY21754                    /TY23020                    /TY25221                    /TY25803                    /TY25866                    /TY25876                    /TY25878                    /TY25879                    /TY25881                    /TY26442                    /TY26783                    /TY6128                     /"
	If cTipoGar <> "ZZBT"
		If aScan(aPeca,{ |x| x[PECA_CODITE] $ cCodBateria } ) <> 0
			MsgStop(STR0001) // "Foi utilizado um código de produto de bateria para uma solicitação de garantia diferente de bateria"
			lRetorno := .f.
			Return .f.
		EndIf
		If lB1CODFAB
			SB1->(dbSetOrder(7))
			For nCont := 1 to Len(aPeca)
				If SB1->(dbSeek(xFilial("SB1") + aPeca[nCont,PECA_GRUITE] + aPeca[nCont,PECA_CODITE] ))
					If !Empty(SB1->B1_CODFAB) .and. SB1->B1_CODFAB $ cCodBateria
						MsgStop(STR0001) // "Foi utilizado um código de produto de bateria para uma solicitação de garantia diferente de bateria"
						lRetorno := .f.
						Return .f.
					EndIf
				EndIf
			Next nCont
		EndIf
	EndIf
	//

	// Verifica se existe algum produto que deve ter sua unidade de medida alterada ...
	// Verifica se é Balde de Oleo ou Mangueira ...
	cProbConvPeca := ""
	SB1->(dbSetOrder(7))
	For nCont := 1 to Len(aPeca)
		SB1->(dbSeek( xFilial("SB1") + aPeca[nCont, PECA_GRUITE ] + aPeca[nCont, PECA_CODITE ] ))
		If SB1->B1_UM $ "BD/" .and. ( Empty(SB1->B1_SEGUM) .or. Empty(SB1->B1_TIPCONV) .or. SB1->B1_CONV == 0 )
			cProbConvPeca += aPeca[nCont, PECA_GRUITE ] + " - " + aPeca[nCont, PECA_CODITE ] + " - " + AllTrim(SB1->B1_DESC) + chr(13) + chr(10)
		EndIf
	Next nCont
	If !Empty(cProbConvPeca)
		cProbConvPeca := STR0033 + ; // "As peças abaixo não possuem configuração para conversão de unidade de medida. A não conversão de unidade de alguns produtos pode ocasionar problemas no retorno da solicitação de garantia. Deseja continuar com a liberação do tipo de tempo e geração da solicitação de garantia ?"
			chr(13) + chr(10) + chr(13) + chr(10) + cProbConvPeca
		If !MsgNoYes(cProbConvPeca, STR0006)
			lRetorno := .f.
			Return .f.
		EndIf
	EndIf
	//

	cMVGRUVEI := PadR(GetMv("MV_GRUVEI"),TamSX3("B1_GRUPO")[1])

	SBM->(dbSetOrder(1))
	SB1->(dbSetOrder(7))

	VMC->(dbSetOrder(3))

	// Verifica por alguma regra da FMX_CALPEC, uma peca foi duplicada no retorno da funcao
	// Ajusta para enviar somente uma linha com todas as pecas
	aProcPeca := {}
	For nCont := 1 to Len(aPeca)
		nPosProcPeca := aScan( aProcPeca , { |x| x[PECA_GRUITE] == aPeca[nCont,PECA_GRUITE] .and. ;
		                                         x[PECA_CODITE] == aPeca[nCont,PECA_CODITE] } )
		If nPosProcPeca == 0
			AADD( aProcPeca , aClone( aPeca[nCont] ) )
			Loop
		EndIf

		aProcPeca[ nPosProcPeca , PECA_QTDREQ ] += aPeca[ nCont, PECA_QTDREQ ]
		aProcPeca[ nPosProcPeca , PECA_VALBRU ] += aPeca[ nCont, PECA_VALBRU ]
		aProcPeca[ nPosProcPeca , PECA_VALDES ] += aPeca[ nCont, PECA_VALDES ]
	Next nCont

	aSX3ValUni := TamSX3("VMC_VUPECE")
	aEval( aProcPeca , { |x| x[ PECA_VALOR] := Round( ( x[ PECA_VALBRU ] - x[ PECA_VALDES ] ) / x[ PECA_QTDREQ ] , aSX3ValUni[2] ) } )
	aPeca := aClone(aProcPeca)

	For nCont := 1 to Len(aPeca)

		aIteTemp := {}

		SB1->(dbSeek( xFilial("SB1") + aPeca[nCont, PECA_GRUITE ] + aPeca[nCont, PECA_CODITE ] ))
		SBM->(MsSeek( xFilial("SBM") + aPeca[nCont, PECA_GRUITE ] ))

		nAuxTotal += aPeca[nCont,PECA_VALBRU] - aPeca[nCont,PECA_VALDES]

		// Verifica se deve fazer conversao de UM ...
		nQtde := aPeca[nCont, PECA_QTDREQ ]
		cUM   := SB1->B1_UM
		OFNJD18CONV( SB1->B1_COD , SB1->B1_UM , SB1->B1_SEGUM , @nQtde , @cUM )
		//

		// So adiciona pecas que não estao na SG ...
		If !lNovaSG
			If VMC->(dbSeek(xFilial("VMC") + aCabSGJD[1,2] + "P" + aPeca[nCont, PECA_GRUITE ] + aPeca[nCont, PECA_CODITE ] ))

				AADD( aIteTemp, { "LINPOS" , "VMC_SEQGAR", VMC->VMC_SEQGAR })

				// Se for PMP e a origem for FABRICA, so a certa o numero da liberacao do VOO
				//Otávio - 11/04/2014 - De acordo com o Gilberto, existe a opção de requisitar mais kits de PMP (como por exemplo, um para cada cubo da roda do pulverizado).
				//Por isso, precisamos atualizar a quantidade de acordo com a requisição.
				If VMB->VMB_TIPGAR == "ZPIP" .and. VMC->VMC_ORIGEM == "1"
					AADD( aIteTemp , { "VMC_QTDPEC" , nQtde   , NIL } )
					AADD( aIteTemp , { "VMC_UM"     , cUM     , NIL } )
					AADD( aIteTemp , { "VMC_LIBVOO" , cLibVOO , NIL } )
					AADD(aIteSGJD,aClone(aIteTemp))
					Loop
				EndIf
				//
			EndIf
		EndIf
		//

		// Registra Peças / Kits
		// Se for Peça Original adiciona como peças...
		If SBM->BM_PROORI == "1" .or. SB1->B1_GRUPO == cMVGRUVEI
			AADD( aIteTemp , { "VMC_TIPOPS" , "P" , NIL } )
		// Do Contrario, envia como outros creditos ...
		Else
			AADD( aIteTemp , { "VMC_TIPOPS" , "O" , NIL } )
			AADD( aIteTemp , { "VMC_CUSMAT" , aPeca[nCont, PECA_VALBRU ] , NIL } )
		EndIf
		//

		AADD( aIteTemp , { "VMC_TIPTEM" , cTipTem , NIL } )
		AADD( aIteTemp , { "VMC_LIBVOO" , cLibVOO , NIL } )

		AADD( aIteTemp , { "VMC_GRUITE" , aPeca[nCont, PECA_GRUITE ] , NIL } )
		AADD( aIteTemp , { "VMC_CODITE" , aPeca[nCont, PECA_CODITE ] , NIL } )

		// Requisicao de AMS com Chassi - Equipamento
		If SB1->B1_GRUPO == cMVGRUVEI
			cSQL := "SELECT VV1_MODVEI, VV2_MODFAB "
			cSQL += " FROM " + RetSQLName("VV1") + " VV1 "
			cSQL += " JOIN " + RetSQLName("VV2") + " VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "'"
			cSQL +=                                   " AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
			cSQL +=                                   " AND VV2.VV2_MODVEI = VV1.VV1_MODVEI "
			cSQL +=                                   " AND VV2.D_E_L_E_T_ = ' ' "
			cSQL += "WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
			cSQL +=  " AND VV1.VV1_CHAINT = '" + PadR(SB1->B1_CODITE,Len(VV1->VV1_CHAINT)) + "'"
			cSQL +=  " AND VV1.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasAMS , .F., .T. )
			If !(cAliasAMS)->(Eof())
				AADD( aIteTemp , { "VMC_PARTNO" , IIf( !Empty((cAliasAMS)->VV2_MODFAB) , (cAliasAMS)->VV2_MODFAB , (cAliasAMS)->VV1_MODVEI ) , NIL } )
			EndIf
			(cAliasAMS)->(dbCloseArea())
		Else
			AADD( aIteTemp , { "VMC_PARTNO" , IIf(lB1CODFAB .and. !Empty(SB1->B1_CODFAB),SB1->B1_CODFAB,SB1->B1_CODITE) , NIL } )
		EndIf

		AADD( aIteTemp , { "VMC_QTDPEC" , nQtde , NIL } )
		AADD( aIteTemp , { "VMC_UM"     , cUM   , NIL } )

		AADD( aIteTemp , { "VMC_VUPECE" , aPeca[nCont, PECA_VALOR  ] , NIL } )
		AADD( aIteTemp , { "VMC_VTPECE" , aPeca[nCont, PECA_VALBRU ] , NIL } )

		AADD(aIteSGJD,aClone(aIteTemp))
		//

	Next nCont

	VMC->(dbSetOrder(4))

	For nCont := 1 to Len(aSrvc)

		aIteTemp := {}

		//cTipOps := aSrvc[nCont,SRVC_INCMOB]
		If aSrvc[nCont,SRVC_INCMOB] $ "2/5"
			cTipOps := "O"
		Else
			cTipOps := "S"
		EndIf

		nAuxTotal += aSrvc[nCont,09]

		// So adiciona pecas que não estao na SG ...
		If !lNovaSG
			If VMC->(dbSeek(xFilial("VMC") + aCabSGJD[1,2] + cTipOps + aSrvc[nCont,SRVC_CODSER] ))
				AADD( aIteTemp, { "LINPOS" , "VMC_SEQGAR", VMC->VMC_SEQGAR })

				// Se for PMP e a origem for FABRICA ou Revisao, so a certa o numero da liberacao do VOO
				If (VMB->VMB_TIPGAR == "ZPIP" .and. VMC->VMC_ORIGEM == "1") .or. VMB->VMB_TIPGAR == "ZZMK"

					If ! OFNJD18VldValHor(aSrvc[nCont,SRVC_VALHOR], aSrvc[nCont,SRVC_CODSER])
						lRetorno := .f.
						Return .f.
					EndIf

					AADD( aIteTemp , { "VMC_LIBVOO" , cLibVOO , NIL } )
					AADD( aIteTemp , { "VMC_VALHRE" , aSrvc[nCont,SRVC_VALHOR] , NIL } )
					AADD( aIteTemp , { "VMC_VTSERE" , aSrvc[nCont,SRVC_VALBRU] , NIL } )
					AADD( aIteTemp , { "VMC_QTDTRA" , aSrvc[nCont,SRVC_TEMCOB] / 100 , NIL } )
					AADD(aIteSGJD,aClone(aIteTemp))
					Loop
				EndIf
				//
			EndIf
		EndIf
		//

		AADD( aIteTemp , { "VMC_TIPOPS" , cTipOps , NIL } )
		AADD( aIteTemp , { "VMC_TIPTEM" , cTipTem , NIL } )
		AADD( aIteTemp , { "VMC_LIBVOO" , cLibVOO , NIL } )

		AADD( aIteTemp , { "VMC_GRUSER" , aSrvc[nCont,SRVC_GRUSER] , NIL } )
		AADD( aIteTemp , { "VMC_CODSER" , aSrvc[nCont,SRVC_CODSER] , NIL } )

		If cTipOps == "S"

			If ! OFNJD18VldValHor(aSrvc[nCont,SRVC_VALHOR], aSrvc[nCont,SRVC_CODSER])
				lRetorno := .f.
				Return .f.
			EndIf

			AADD( aIteTemp , { "VMC_QTDTRA" , aSrvc[nCont,SRVC_TEMCOB] / 100 , NIL } )
			AADD( aIteTemp , { "VMC_VALHRE" , aSrvc[nCont,SRVC_VALHOR] , NIL } )
			AADD( aIteTemp , { "VMC_VTSERE" , aSrvc[nCont,SRVC_VALBRU] , NIL } )
		Else
			AADD( aIteTemp , { "VMC_CUSMAT" , aSrvc[nCont,SRVC_VALBRU] , NIL } )
		EndIf

		// Verifica se este servico estava no outro registro de garantia
		If cTipoGar == "ZZMK" //.and. !Empty(cCodGar)
			cSQL := "SELECT VMC_TIPTRA, VMC_LOCTRA, VMC_CODMAT"
			cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
			cSQL += " WHERE VMC.VMC_FILIAL = '" + xFilial("VMC") + "'"
			cSQL +=   " AND VMC.VMC_CODGAR IN ("
			cSQL += "SELECT VMB_CODGAR "
			cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
			cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
			cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cSQL +=   " AND VMB_TIPGAR = '" + cTipoGar + "'"
			cSQL +=   " AND VMB_REPARO = '00' "
			cSQL += " ) "
			cSQL +=   " AND VMC.VMC_TIPOPS = '" + cTipOps + "'"
			cSQL +=   " AND VMC.VMC_CODSER = '" + aSrvc[nCont,SRVC_CODSER] + "'"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasSG , .F., .T. )
			If !(cAliasSG)->(Eof())
				If cTipOps == "S"
					AADD( aIteTemp , { "VMC_TIPTRA" , (cAliasSG)->VMC_TIPTRA , NIL } )
					AADD( aIteTemp , { "VMC_LOCTRA" , (cAliasSG)->VMC_LOCTRA , NIL } )
				Else
					AADD( aIteTemp , { "VMC_CODMAT" , (cAliasSG)->VMC_CODMAT , NIL } )
				EndIf
			EndIf
			(cAliasSG)->(dbCloseArea())
		EndIf
		//

		AADD(aIteSGJD,aClone(aIteTemp))

	Next nCont

	dbSelectArea("VMB")

	lMSHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| OFINJD15(x,y,z)},aCabSGJD,aIteSGJD, IIf( nRecVMB == 0 , 3 , 4 ))
	If lMsErroAuto
		MsUnlockAll()
		MostraErro()
		lRetorno := .f.
		Return .f.
	EndIf


EndIf

// Verifica se é possível gerar NF de Garantia ...
If cSituac == "VF"

	cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRECNO "
	cSQL +=  " FROM " + RetSQLName("VMB") + " VMB JOIN " + RetSQLName("VMC") + " VMC ON VMC_FILIAL = VMB_FILIAL AND VMC_CODGAR = VMB_CODGAR AND VMC.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
	cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15') " // Nao esta com status RETORNADO / DELETADO / DEBITADO
	cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VMC_TIPTEM = '" + cTipTem + "'"
	cSQL +=   " AND VMC_LIBVOO = '" + cLibVOO + "'"
	nVMBRecno := FM_SQL(cSQL)

	If nVMBRecno == 0

		// Procura o codigo da Marca John Deere
		cCodMarJD := FMX_RETMAR("JD ") + "/" + FMX_RETMAR("GRS") + "/" + FMX_RETMAR("PLA") + "/" + FMX_RETMAR("JDC") + "/" + FMX_RETMAR("HCM")

		// Se o chassi for John Deere e o tipo de tempo de garantia, deve existir um registro de Solicitacao de garantia ...
		If aRetWS[1] $ cCodMarJD
			MsgStop(STR0005 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
				RetTitle("VMB_NUMOSV") + ": " + VO1->VO1_NUMOSV + CHR(13) + CHR(10) +;
				RetTitle("VMC_TIPTEM") + ": " + cTipTem + CHR(13) + CHR(10) +;
				RetTitle("VMC_LIBVOO") + ": " + cLibVOO ;
				,STR0006) // "Registro de solicitação de garantia não encontrado."
			lRetorno := .f. // a funcao FG_VERFORGAR considera o conteudo da variavel private lRetorno
			Return .f.
		EndIf

	EndIf

	VMB->(dbGoTo(nVMBRecno))

	If Empty(VMB->VMB_STATUS)
		MsgStop(STR0013,STR0006) // "Solicitação de Garantia não foi transmitida."
		lRetorno := .f.
		Return .f.
	EndIf

	If !VMB->VMB_STATSG $ "1/2/3/5"
		MsgStop(STR0007,STR0006) // "Solicitação de garantia não aprovada para faturamento."
		lRetorno := .f. // a funcao FG_VERFORGAR considera o conteudo da variavel private lRetorno
		Return .f.
	EndIf

	If !VMB->VMB_MEMTYP $ "1/4"
		MsgStop(STR0008,STR0006) // "Não foi processado retorno da Solicitação de Garantia."
		lRetorno := .f. // a funcao FG_VERFORGAR considera o conteudo da variavel private lRetorno
		Return .f.
	EndIf

	nValPecGar := aRetWS[2]
	nValSerGar := aRetWS[3]

	// Valida total de pecas com total do requisitado ...
	cSQL := "SELECT SUM(VMC_VTPECR + VMC_CUSMAR) TOTAL, COUNT(*) QREG "
	cSQL +=  " FROM " + RetSQLName("VMC")
	cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
	cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
	cSQL +=   " AND ( VMC_TIPOPS = 'P' OR ( VMC_TIPOPS = 'O' AND VMC_CODITE <> '  '))" // Outros creditos com codigo de peca, é uma PECA de outra marca enviada na garantia ...
	cSQL +=   " AND VMC_TIPTEM = '" + cTipTem + "'"
	cSQL +=   " AND VMC_LIBVOO = '" + cLibVOO + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	nTotal := FM_SQL(cSQL)
	If nTotal <> nValPecGar
		MsgStop(STR0009 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
				RetTitle("VMB_CODGAR") + ": " + VMB->VMB_CODGAR + chr(13) + chr(10) +;
				RetTitle("VMB_NUMOSV") + ": " + VMB->VMB_NUMOSV + chr(13) + chr(10) +;
				RetTitle("VMC_TIPTEM") + ": " + cTipTem + chr(13) + chr(10) +;
				RetTitle("VMC_LIBVOO") + ": " + cLibVOO + chr(13) + chr(10) +;
				STR0010 + ": " + Transform(nTotal,"@E 9,999,999.99") + chr(13) + chr(10) +;
				STR0011 + ": " + Transform(nValPecGar,"@E 9,999,999.99"),STR0006) // "Valor total de peças da solicitação de garantia está divergente com o valor total do tipo de tempo."
		lRetorno := .f. // a funcao FG_VERFORGAR considera o conteudo da variavel private lRetorno
		Return .f.
	EndIf

	// Valida total de servicos com total do requisitado ...
	// Desconsidera as garantias da série 5000, para isso verifica se é uma REVISAO e o valor é menor que R$ 1,00
	If  !OFNJD15SERIE5000()
		cSQL := "SELECT SUM(VMC_VTSERR + VMC_CUSMAR) TOTAL, COUNT(*) QREG "
		cSQL +=  " FROM " + RetSQLName("VMC")
		cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
		cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
		cSQL +=   " AND ( VMC_TIPOPS = 'S' OR ( VMC_TIPOPS = 'O' AND VMC_CODITE = '  '))" // Outros creditos nao pode possuir codigo de peca
		cSQL +=   " AND VMC_TIPTEM = '" + cTipTem + "'"
		cSQL +=   " AND VMC_LIBVOO = '" + cLibVOO + "'"
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		nTotal := FM_SQL(cSQL)
		If nTotal <> nValSerGar
			MsgStop(STR0012 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
					RetTitle("VMB_CODGAR") + ": " + VMB->VMB_CODGAR + chr(13) + chr(10) +;
					RetTitle("VMB_NUMOSV") + ": " + VMB->VMB_NUMOSV + chr(13) + chr(10) +;
					RetTitle("VMC_TIPTEM") + ": " + cTipTem + chr(13) + chr(10) +;
					RetTitle("VMC_LIBVOO") + ": " + cLibVOO + chr(13) + chr(10) +;
					STR0010 + ": " + Transform(nTotal,"@E 9,999,999.99") + chr(13) + chr(10) +;
					STR0011 + ": " + Transform(nValSerGar,"@E 9,999,999.99"),STR0006) // "Valor total de serviços da solicitação de garantia está divergente com o valor total do tipo de tempo."
			lRetorno := .f. // a funcao FG_VERFORGAR considera o conteudo da variavel private lRetorno
			Return .f.
		EndIf
	EndIf
EndIf

// Verifica se é possivel gerar NF da OS quando possui uma SG sem reembolso (Linha 5000)
If cSituac == "SEMREEMB"

	cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRECNO "
	cSQL +=  " FROM " + RetSQLName("VMB") + " VMB JOIN " + RetSQLName("VMC") + " VMC ON VMC_FILIAL = VMB_FILIAL AND VMC_CODGAR = VMB_CODGAR AND VMC.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
	cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VMB_SREEMB = '1'"
	cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15') " // Nao esta com status RETORNADO / DELETADO / DEBITADO
	cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"
	nVMBRecno := FM_SQL(cSQL)
	If nVMBRecno == 0
		Return .T.
	EndIf

	VMB->(dbGoTo(nVMBRecno))

	If Empty(VMB->VMB_STATUS)
		MsgStop(STR0035 + CHR(13) + CHR(10) + STR0037 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
				  RetTitle("VMB_CODGAR") + ": " + VMB->VMB_CODGAR ,STR0006) // "Esta ordem de serviço possui uma solicitação de garantia sem reembolso relacionada."  "Para prosseguir com o fechamento, transmita a solicitação de garantia à John Deere."
		lRetorno := .f.
		Return .f.
	EndIf

	If VMB->VMB_STATUS <> "03"
		MsgStop(STR0035 + CHR(13) + CHR(10) + STR0007,STR0006) // "Ordem de serviço possui uma solicitação de garantia sem reembolso relacionada." "Solicitação de garantia não aprovada para faturamento."
		lRetorno := .f. // a funcao FG_VERFORGAR considera o conteudo da variavel private lRetorno
		Return .f.
	EndIf

EndIf

// Se gerou nota fiscal de servico, atualizar a serie e numero da NF gerada ...
If cSituac == "F"

	VOO->(dbSetOrder(1))
	VOO->(MsSeek(xFilial("VOO") + VO1->VO1_NUMOSV + cTipTem + cLibVOO ))
	If VOO->VOO_TOTSRV <> 0
		cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRENO"
		cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
		cSQL +=         " JOIN " + RetSQLName("VMC") + " VMC "
		cSQL +=                 " ON VMC.VMC_FILIAL = VMB_FILIAL "
		cSQL +=                " AND VMC.VMC_CODGAR = VMB_CODGAR "
		cSQL +=                " AND VMC.D_E_L_E_T_ = ' '"
		cSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=   " AND VMB.VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
		cSQL +=   " AND ( VMB.VMB_MEMTYP = '4'" // Garantia esperando Nota Fiscal
		cSQL +=         " OR "
		cSQL +=         " ( VMB.VMB_MEMTYP = '1' AND VMB.VMB_TOTALW < 1 AND VMB.VMB_TIPGAR = 'ZZMK' AND VMB.VMB_SUBGAR = 'MTC' ) )" // Garantia Serie 5000
		cSQL +=   " AND VMB.VMB_STATUS NOT IN ('04','05','15') " // Nao esta com status RETORNADO / DELETADO / DEBITADO
		cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"
		cSQL +=   " AND VMC_TIPTEM = '" + cTipTem + "'"
		nAuxRecno := FM_SQL(cSQL)
		If nAuxRecno <> 0
			VMB->(dbGoTo(nAuxRecno))
			If VMB->VMB_STATSG == "2" .and. !Empty(VMB->VMB_SRVNNF)
				If (VMB->VMB_SRVNNF <> VOO->VOO_NUMNFI .or. VMB->VMB_SRVSNF <> VOO->VOO_SERNFI) .and. !OFNJD15SERIE5000() // Nao exibir msg para garantia da serie 5000
					MsgInfo(STR0027 ,STR0018) // "Se a nota fiscal de serviço foi cancelada e gerada outra nota com novo número, não esquecer de abrir um DTAC no portal informando o novo número de nota gerada e anexar a nota fiscal errada e a correta."
				EndIf
			Else
				If !RecLock("VMB",.f.)
					DisarmTransaction()
					RollbackSx8()
					MsUnlockAll()
					Help("  ",1,"REGNLOCK")
					Return(.f.)
				EndIf
				VMB->VMB_SRVSNF := VOO->VOO_SERNFI
				VMB->VMB_SRVNNF := VOO->VOO_NUMNFI
				If OFNJD15SERIE5000()
					VMB->VMB_STATSG := "5" // Pagamento Efetuado
				Else
					VMB->VMB_STATSG := "3" // Pendente Atualizacao NF
				EndIf
				VMB->(MsUnLock())
			EndIf
		EndIf
	Else
			// Verifica se o warrmemo processado já é o de Pagamento Efetuado
		cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRENO"
		cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
		cSQL +=         " JOIN " + RetSQLName("VMC") + " VMC "
		cSQL +=                 " ON VMC.VMC_FILIAL = VMB_FILIAL "
		cSQL +=                " AND VMC.VMC_CODGAR = VMB_CODGAR "
		cSQL +=                " AND VMC.D_E_L_E_T_ = ' '"
		cSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=   " AND VMB.VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
		cSQL +=   " AND VMB.VMB_MEMTYP = '1'" // Pagamento Efetuado
		cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15') " // Nao esta com status RETORNADO / DELETADO / DEBITADO
		cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"
		cSQL +=   " AND VMC_TIPTEM = '" + cTipTem + "'"
		nAuxRecno := FM_SQL(cSQL)
		//
		If nAuxRecno <> 0

			VMB->(dbGoTo(nAuxRecno))

			// Verifica se a SG possui somente pecas ...
			// Se possuir somente pecas ja ajusta o Status para PAGAMENTO EFETUADO ...
			If OFNJD18SOPECA( VMB->VMB_CODGAR ) .or. OFNJD15SERIE5000()
				If !RecLock("VMB",.f.)
					DisarmTransaction()
					RollbackSx8()
					MsUnlockAll()
					Help("  ",1,"REGNLOCK")
					Return(.f.)
				EndIf
				VMB->VMB_STATSG := "5" // Pagamento Efetuado
				VMB->(MsUnLock())
			EndIf
		EndIf
	EndIf

EndIf

RETURN .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ OFNJD18SOPECA º Autor ³ Rubens Takahashi º Data ³ 29/09/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se a SG possui somente pecas                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OFNJD18SOPECA( cCodGar )

Local cSQL

cSQL := "SELECT COUNT(*) "
cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
cSQL += " WHERE VMC.VMC_FILIAL = '" + xFilial("VMC") + "' "
cSQL +=   " AND VMC.VMC_CODGAR = '" + cCodGar + "'"
cSQL +=   " AND (VMC.VMC_TIPOPS = 'S' OR (VMC.VMC_TIPOPS = 'O' AND VMC.VMC_PARTNO = '                  ' )) "
cSQL +=   " AND VMC.D_E_L_E_T_ = ' '"

Return (FM_SQL(cSQL) == 0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ OFNJD18CONV   º Autor ³ Rubens Takahashi º Data ³ 18/03/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se deve converter a quantidade de acordo com a    º±±
±±º          ³ unidade de medida                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OFNJD18CONV( cCodProduto , cCodB1UM , cCodB1SEGUM , nQtde , cUM )

Local nPosConvUM := 0
Local nPos := 0

If Empty(cCodB1SEGUM)
	Return
EndIf

If (nPos := aScan(aConvUM,{ |x| cCodB1UM $ AllTrim(x) })) <> 0
	For nPosConvUM := nPos to Len(aConvUM)
		nPos := At("/",aConvUM[nPosConvUM])
		cUMDe   := AllTrim(SubStr(aConvUM[nPosConvUM],1,nPos-1))
		cUMPara := AllTrim(SubStr(aConvUM[nPosConvUM],nPos+1))

		If cUMDe == AllTrim(cCodB1UM) .and. cUMPara == AllTrim(cCodB1SEGUM)
			If AllTrim(cUM) == cUMDe
				nQtde := Round( ConvUm(cCodProduto,nQtde,1,2) , TamSX3( "VMC_QTDPEC" )[2] )
				cUM   := cCodB1SEGUM
				Exit
			EndIf
			If AllTrim(cUM) == cUMPara
				nQtde := Round( ConvUm(cCodProduto,1,nQtde,1) , TamSX3( "VMC_QTDPEC" )[2] )
				cUM   := cCodB1UM
				Exit
			EndIf
		EndIf

	Next nPosConvUM
EndIf

Return


/*/{Protheus.doc} OFNJD18TEMPAD
Retorna o tempo convertido para ser utilizando pelas tabelas do DMS
@author Rubens
@since 26/12/2017
@version 1.0
@return nTempoRet, Tempo padrao utilizado nas tabelas do DMS
@param cTabUtil, character, descricao
@param nTempo, numeric, descricao
@type function
/*/
Static Function OFNJD18TEMPAD( cTabUtil , nTempo )

	Local nTempoRet := 0

	// Na garantia 5000 a John Deere esta enviando a quantidade de hora igual a 0.001
	If nTempo == 0.001
		nTempo := 0.01
	EndIf

	Do Case
	Case cTabUtil == "VO4"
		nTempoRet := (nTempo * 100 )
	Case cTabUtil == "VMC"
		nTempoRet := nTempo
	EndCase

Return nTempoRet

/*/{Protheus.doc} OFNJD18VLIB
Valida se o tempo padrao que consta na ordem de serviço é o mesmo da solicitação de garantia
@author Renato Vinicius
@since 15/02/2018
@version 1.0
@return lógico
@param aServicos, array, descricao
@param cCodGta, caracter, descricao
@type function
/*/

Static Function OFNJD18VLIB(aServicos,cCodGta)

Local nSrv

Default aServicos := {}
Default cCodGta := ""

For nSrv := 1 to Len(aServicos)

	If aServicos[nSrv,6] $ "2/5" // Serviço de Terceiro / Km Socorro
		Loop
	EndIf

	cQuery := "SELECT VMC.R_E_C_N_O_ VMCRECNO "
	cQuery += "FROM " + RetSQLName( "VMC" ) + " VMC "
	cQuery += "WHERE  VMC.VMC_FILIAL = '" + xFilial("VMC") + "' "
	cQuery +=   " AND VMC.VMC_CODGAR = '" + cCodGta + "' "
	cQuery +=   " AND VMC.VMC_TIPOPS = 'S' "
	cQuery +=   " AND VMC.VMC_TIPTEM = '" + cTipTem + "' "
	cQuery +=   " AND VMC.VMC_GRUSER = '" + aServicos[nSrv,SRVC_GRUSER] + "' "
	cQuery +=   " AND VMC.VMC_CODSER = '" + aServicos[nSrv,SRVC_CODSER] + "' "
	cQuery +=   " AND VMC.VMC_QTDTRA <> " + cValtoChar(aServicos[nSrv,SRVC_TEMCOB] / 100)
	cQuery +=   " AND VMC.VMC_QTDTRA <> " + cValtoChar(aServicos[nSrv,SRVC_TEMCOB])
	cQuery +=   " AND VMC.D_E_L_E_T_ = ' ' "
	If FM_SQL(cQuery) > 0
		Return .f.
	EndIf
Next

Return .t.

/*/{Protheus.doc} OFNJD18SEMREEMBOLSO
Retorna se existe uma solicitação de garantia sem reembolso para a Ordem de Servico informada
@author Rubens
@since 18/06/2018
@version 1.0
@return lRetorno, Retorna se é uma solicitacao sem reembolso
@param cNumOsv, characters, Numero da ordem de servico a ser pesquisada
@type function
/*/
Static Function OFNJD18SEMREEMBOLSO( cNumOsv )
	Local cSQl
	Local nRecRetVMB
	Local lRetorno := .f.

	cSQL := "SELECT DISTINCT(VMB.R_E_C_N_O_) VMBRECNO"
	cSQL += " FROM " + RetSQLName("VMB") + " VMB "
	cSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
	cSQL +=   " AND VMB.VMB_NUMOSV = '" + cNumOsv + "'"
	cSQL +=   " AND VMB.VMB_STATUS NOT IN ('04','05','15') " // Rejeitado / Deletado / Debitado
	cSQL +=   " AND VMB.D_E_L_E_T_ = ' ' "
	cSQL +=   " AND VMB.VMB_SREEMB = '1' "
	nRecRetVMB := FM_SQL(cSQL)
	lRetorno := (nRecRetVMB <> 0)

Return lRetorno


/*/{Protheus.doc} OFNJD18TTPUBLICO
Retorna se o tipo de tempo é de Publico
@author Rubens
@since 19/07/2018
@version 1.0
@return lRetorno , boolean, Retorna se o tipo de tempo é de publico
@param cTipTem, characters, Codigo do tipo de tempo que está sendo cancelado
@type function
/*/
Static Function OFNJD18TTPUBLICO( cTipTem )
	Local lRetorno
	Local cSQL 
	cSQL := "SELECT VOI_SITTPO" +;
		" FROM " + RetSQLName("VOI") + " VOI " +;
		"WHERE VOI.VOI_FILIAL = '" + xFilial("VOI") + "'" +;
		 " AND VOI.VOI_TIPTEM = '" + cTipTem + "' " +;
		 " AND VOI.D_E_L_E_T_ = ' '"
	lRetorno := (FM_SQL(cSQL) <> "2")
Return lRetorno

/*/{Protheus.doc} OFNJD18CodMarca
Retorna o codigo da marca utilizada para buscar o Cliente Faturar Para
@author Rubens
@since 16/08/2018
@version 1.0
@return cRetorno, Codigo da Marca
@param cVV1Marca, characters, descricao
@type function
/*/
Static Function OFNJD18CodMarca(cVV1Marca)
	Local cRetorno := ""
	If ExistFunc("OFNJD15011_RetornaMarca")
		OFNJD15011_RetornaMarca(cVV1Marca)
	Else
		cRetorno := FMX_RETMAR("JD ")
	EndIf

Return cRetorno

/*/{Protheus.doc} OFNJD18VldValHor
Cria uma trava para o valor da hora do Servico. Trava foi necessária para evitar erros no processamento do retorno. Nao existe valor de hora maior que R$ 999,00
@author rubens.takahashi
@since 26/12/2019
@version 1.0
@return boolean, 
@param nValor, numeric, description
@param cCodSer, characters, description
@type function
/*/
Static Function OFNJD18VldValHor(nValor, cCodSer )
	If nValor >= 1000
		FMX_HELP("OFNJD18ERR01",;
			STR0038 + CRLF + CRLF +; // "Valor de hora inválido."
			RetTitle("VO4_CODSER") + " - " + cCodSer + CRLF +;
			RetTitle("VO4_VALHOR") + " - " + Transform(nValor, "@E 999,999.99"),;
			STR0039) // "Altere o valor da hora do serviço requisitado."
		Return .f.
	EndIf
Return .t.

/*/{Protheus.doc} OFNJD18CancNFSTransm

Verificar permissao para cancelamento de nota fiscal de servico transmitida

@author rubens.takahashi
@since 30/06/2020
@version 1.0
@return boolean, 
@type function

/*/
Static Function OFNJD18CancNFSTransm(cAliasVOO)

	Local oLoginHelper
	Local oLogger
	Local lVAICNFSGA := (VAI->(ColumnPos("VAI_CNFSGA")) <> 0)
	Local lCancNFS := .f.

	// --------------------------------------------------------------------------------------------------------------------------------------- //
	// Rubens - 16/03/2016                                                                                                                     //
	// De acordo com instrução da Neusa Fensterseifer através de email enviado em 19/01/2015, quando o número da nota fiscal de servico        //
	// já foi enviada a John Deere através do WebService, somente o usuário administrador deve ter permissão para cancelamento da nota fiscal. //
	// --------------------------------------------------------------------------------------------------------------------------------------- //
	MsgInfo(STR0022 + CHR(13) + CHR(10) + STR0023 , STR0018 ) // "Número da nota fiscal já foi enviada a John Deere." / "Para cancelamento será necessário informar o usuário e senha de administrador."
	oLoginHelper := DMS_LoginHelper():New()
	While .t.
		If ! oLoginHelper:GetUserPass()
			lCancNFS := .f.
			Exit
		Else
			If oLoginHelper:IsAdmin() .or. (lVAICNFSGA .and. OFNJD18CNFSGA(oLoginHelper:cId) )
				MsgInfo( STR0025 , STR0018 ) // "Ao final da geração da nova nota fiscal de serviço, é necessário abrir um DTAC na John Deere informando o novo número de nota fiscal gerada."
				lCancNFS := .t.
				Exit
			Else
				If lVAICNFSGA
					MsgStop( STR0040 , STR0018 ) // "Somente o usuário administrador do sistema ou com permissão para cancelamento de nota fiscal transmitida pode cancelar a nota fiscal de serviço."
				Else
					MsgStop( STR0024 , STR0018 ) // "Somente o usuário administrador do sistema pode cancelar a nota fiscal de serviço."
				EndIf
				Loop
			EndIf
		EndIf
	End

	If lCancNFS

		If MethIsMemberOf( oLoginHelper, "GetName", .f. )
			cLogUserAuth := ', "USERAUTHID" : "' + oLoginHelper:GetId() + '" , "USERAUTHNAME" : "' + oLoginHelper:GetName() + '"'
		Else
			cLogUserAuth := ""
		EndIf

		oLogger := DMS_Logger():New()
		oLogger:LogToTable({ ;
			{'VQL_AGROUP'     , 'OFINJD15'        },;
			{'VQL_TIPO'       , 'CANC_NFS_TRANSR' },;
			{'VQL_DADOS'      , '{ "USERID" : "' + __cUserID + '" , "USERNAME" : "' + Upper(cUserName) + '"' + cLogUserAuth + ', "ENV_SERIE" : "' + VMB->VMB_SRVSNF + '" , "ENV_NF" : "' + VMB->VMB_SRVNNF + '" , "CANC_SERIE" : "' + ( cAliasVOO )->VOO_SERNFI + '" , "CANC_NF" : "' + ( cAliasVOO )->VOO_NUMNFI + '" }' } ,;
			{'VQL_FILORI'     , xFilial("VMB")    } ;
			})

		FWFreeObj(oLogger)
	EndIf

	FWFreeObj(oLoginHelper)

Return lCancNFS


/*/{Protheus.doc} OFNJD18CNFSGA
	(long_description)
	@type  Static Function
	@author Rubens Takahashi
	@since 29/06/2020
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function OFNJD18CNFSGA(cParUserID)

	Local lCanJS := .f.
	Local cAlVAI

	cAlVAI := 'TABVAI'
	BeginSql alias cAlVAI
		SELECT
			VAI.VAI_CNFSGA
		FROM
			%table:VAI% VAI
		WHERE
			VAI.VAI_FILIAL = %xfilial:VAI% AND
			VAI.VAI_CODUSR = %exp:cParUserID% AND
			VAI.%notDel%
	EndSql

	If ! (cAlVAI)->(Eof()) .and. (cAlVAI)->VAI_CNFSGA == "1"
		lCanJS := .t.
	EndIf

	(cAlVAI)->(dbCloseArea())
	
Return lCanJS

