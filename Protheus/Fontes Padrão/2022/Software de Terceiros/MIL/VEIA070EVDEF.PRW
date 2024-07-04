#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "VEIA070.CH"


CLASS VEIA070EVDEF FROM  FWModelEvent

	DATA cIDVV1

	DATA cMVGRUVEI
	DATA cPrefB1COD

	DATA cMVMIL0003
	DATA cMVMIL0010

	DATA lB1CHASSI
	DATA lVV1CONTA  
	DATA lVV1CEST   
	DATA lVV1MSBLQL
	DATA lVV1GRPTI
	DATA lVV1GRTIDC

	DATA lVV1_PLAANT

	DATA oVeiculos
	DATA oPeca

	METHOD New() CONSTRUCTOR
	METHOD BeforeTTS()
	METHOD InTTS()
	METHOD VldActivate()

ENDCLASS

METHOD New(cIDVV1) CLASS VEIA070EVDEF
	Local nTamB1GRUPO := GetSX3Cache("B1_GRUPO","X3_TAMANHO")

	Default cIDVV1 := "MODEL_VV1"

	::cMVGRUVEI := PadR(AllTrim(GetMv("MV_GRUVEI")),nTamB1GRUPO)
	::cPrefB1COD := ::cMVGRUVEI + "_"

	::lB1CHASSI  := SB1->(FieldPos("B1_CHASSI")) > 0
	::lVV1CONTA  := VV1->(FieldPos("VV1_CONTA")) > 0
	::lVV1CEST   := (VV1->(FieldPos("VV1_CEST")) > 0 .and. SB1->(FieldPos("B1_CEST")) > 0)
	::lVV1MSBLQL := (VV1->(FieldPos("VV1_MSBLQL")) > 0 .and. SB1->(FieldPos("B1_MSBLQL")) > 0)
	::lVV1GRPTI  := (VV1->(FieldPos("VV1_GRPTI")) > 0 .and. SB1->(FieldPos("B1_GRPTI")) > 0)

	::lVV1_PLAANT := VV1->(FieldPos("VV1_PLAANT")) > 0

	// Cria registro no SB1 quando for cadastrado um veículo na rotina Veículos Mod. 2 (VEIXA010)? (0=Não / 1=Sim) - CARACTERE	
	::cMVMIL0003 := GetNewPar("MV_MIL0003","1") 

	// O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
	::cMVMIL0010 := GetNewPar("MV_MIL0010","0") 

	::cIDVV1     := cIDVV1	

	::oVeiculos := DMS_Veiculo():New()

	::oPeca     := DMS_Peca():New()

Return

METHOD BeforeTTS(oModel, cModelId) CLASS VEIA070EVDEF

	Local oMVV1
	Local cTmpObs

	Local cPlaAnt
	Local cPlavei

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		oMVV1 := oModel:GetModel("MODEL_VV1")
		cTmpObs := oMVV1:GetValue("VV1_OBSERV")
		// Dados informados e Log de Inclusão
		cTmpObs := Alltrim(cTmpObs) + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
			"*** " + left(Alltrim(UsrRetName(__CUSERID)), 15) + " " + Transform(dDataBase,"@D") + "-" + Transform(time(),"@R 99:99") + "h" + " ***" + Chr(13) + Chr(10) +; // hs
			Repl("_", TamSx3("VV1_OBSERV")[1] - 4) + Chr(13) + Chr(10)

		oMVV1:LoadValue("VV1_OBSERV", cTmpObs)
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		If ::lVV1_PLAANT
			cPlaVei := oMVV1:GetValue("VV1_PLAVEI")
			cPlaAnt := FM_SQL("SELECT VV1_PLAVEI FROM " + RetSQLName("VV1") + " WHERE R_E_C_N_O_ = " + cValToChar(oMVV1:GetDataId()) )
			If cPlaAnt <> cPlaVei .and. Empty(oMVV1:GetValue("VV1_PLAANT")) .and. ( Subs(cPlaAnt,5,1) >= "0" .and. Subs(cPlaAnt,5,1) <= "9" ) .and. ( Subs(cPlaVei,5,1) <= "0" .or. Subs(cPlaVei,5,1) >= "9" )
				oMVV1:LoadValue("VV1_PLAANT", cPlaAnt)
				If ExistFunc("VXA0100012_AtualizaPlacaMercosul")
					VXA0100012_AtualizaPlacaMercosul(cPlaVei, cPlaAnt)
				EndIf
			EndIf
		Endif
	Endif

RETURN

METHOD InTTS(oModel, cModelId) CLASS VEIA070EVDEF

	Local cCodSB1  
	Local aVetSB1  
	Local lRet := .T.
	Local nOpcA := 3
	Local nOperModel := oModel:GetOperation()


	If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE 

		If VV1->VV1_SITVEI <> "8"
			INCLUI := ( nOperModel == MODEL_OPERATION_INSERT )
			ALTERA := ( nOperModel == MODEL_OPERATION_UPDATE )
	
			cCodSB1   := ::cPrefB1COD + VV1->VV1_CHAINT
			aVetSB1   := {}
			lRet := .T.
			nOpcA := 3
	
			If ::cMVMIL0003  == "1"// Cria registro no SB1 quando for cadastrado um veículo na rotina Veículos Mod. 2 (VEIXA010)? (0=Não / 1=Sim) - CARACTERE
				DBSelectArea("SB1")
				DBSetOrder(1)
				if dbSeek(xFilial("SB1")+cCodSB1)
					nOpcA := 4
				endif
				If nOpcA <> 3 // Alteração
					aAdd(aVetSB1,{"B1_DESC"    ,VV1->VV1_CHASSI })
					aAdd(aVetSB1,{"B1_LOCPAD"  ,VV1->VV1_LOCPAD })
					aAdd(aVetSB1,{"B1_PRV1"    ,VV1->VV1_SUGVDA })
					aAdd(aVetSB1,{"B1_ORIGEM"  ,VV1->VV1_PROVEI })
					aAdd(aVetSB1,{"B1_POSIPI"  ,VV1->VV1_POSIPI })
					aAdd(aVetSB1,{"B1_GRTRIB"  ,VV1->VV1_GRTRIB })
					If ::lB1CHASSI
						aAdd(aVetSB1,{"B1_CHASSI"  ,VV1->VV1_CHASSI })
					Endif
					If ::lVV1CONTA
						aAdd(aVetSB1,{"B1_CONTA"   ,VV1->VV1_CONTA  }) 
						aAdd(aVetSB1,{"B1_CC"      ,VV1->VV1_CC     }) 
						aAdd(aVetSB1,{"B1_ITEMCC"  ,VV1->VV1_ITEMCC })
						aAdd(aVetSB1,{"B1_CLVL"    ,VV1->VV1_CLVL   })
					EndIf
					If ::lVV1CEST
						aAdd(aVetSB1,{"B1_CEST"    ,VV1->VV1_CEST   })
					EndIf
	
					// Bloqueio/Desbloqueio de Chassi
					If ::lVV1MSBLQL
						aAdd(aVetSB1,{"B1_MSBLQL"  ,VV1->VV1_MSBLQL })
					EndIf

					// Grupo TI
					If ::lVV1GRPTI
						aAdd(aVetSB1,{"B1_GRPTI"   ,VV1->VV1_GRPTI })
					EndIf
				EndIf
				lRet := ::oVeiculos:CriaPeca(VV1->VV1_CHAINT,nOpcA,aVetSB1,"VA010AB1") // Inclui/Altera SB1 do Veiculo
				If !lRet
					AutoGrLog(RetTitle("VV1_CHAINT")+" :"+VV1->VV1_CHAINT)
					MostraErro()
				Endif
			Endif
		Endif

	ElseIf nOperModel == MODEL_OPERATION_DELETE

		lRet := .T.
		If ::cMVMIL0003  == "1"// Cria registro no SB1 quando for cadastrado um veículo na rotina Veículos Mod. 2 (VEIXA010)? (0=Não / 1=Sim) - CARACTERE
			If ::cMVMIL0010 == "0" // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
				cCodSB1 := ::cPrefB1COD + VV1->VV1_CHAINT
				lRet := ::oPeca:ExcluiPeca(cCodSB1) // Excluir SB1 correspondente ao VV1
			EndIf
		EndIf

	Endif

RETURN lRet

 METHOD VldActivate(oModel, cModelId) CLASS VEIA070EVDEF	
	Local nOperation := oModel:GetOperation()	
	Local nRegs := 0

	If nOperation == 5
		nRegs:= FM_SQL(" SELECT COALESCE(count(*),0) as COUNT FROM "+RetSQLName('VQ0')+" WHERE VQ0_CHAINT = '"+VV1->VV1_CHAINT+"' AND D_E_L_E_T_ = ' ' ")
		If nRegs > 0 			
			FMX_HELP("VEIA070EVDEFERR01",STR0004,STR0005)//("O Chassi selecionado ja possui um pedido. Impossivel continuar. / Atencao")	 	
			Return .f.		
		endIf		
	EndIf

RETURN .T.



