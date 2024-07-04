#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"

STATIC __oQryFK4		:= Nil
STATIC __oQryFK7		:= Nil
STATIC __oQryK6TPDES	:= Nil
STATIC __oQryK6CODVAL	:= Nil
STATIC __oQryFK1	    := Nil
STATIC __oQryFK2	    := Nil
STATIC __oQryFK5        := Nil
STATIC __oQryFK5R       := Nil
STATIC __oQryK2MNat		:= Nil
STATIC __oQryK7Dupl		:= Nil
STATIC __oQryFKX        := Nil
STATIC __oQryFK3P		:= Nil
STATIC __oQryFK3R		:= Nil
STATIC __oQryFK4P		:= Nil
STATIC __oQryFK4R		:= Nil
STATIC __oQryFK7P		:= Nil
STATIC __oQryFK7R		:= Nil
STATIC __oQrySE5		:= Nil
STATIC __oQryGPA		:= Nil
STATIC __oQryFK5DC      := Nil
STATIC __aSitDsc		:= Nil
STATIC __oQryFK3A		:= Nil
STATIC __oQryFK4A		:= Nil
STATIC __oQryFK3B		:= Nil
STATIC __oQryFK4B		:= Nil
STATIC __oQryFK4M		:= Nil
STATIC __oQryFK3M		:= Nil
STATIC __oQryK2DtDig	:= Nil
STATIC __oQryFE1		:= Nil
STATIC __oQryFE2		:= Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FKsxFix
Grupo de funções que realizarão ajustes nas tabelas FKs

@author Mauricio Pequim Jr
@since 10/09/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Function FKsxFix()

	Local aArea As Array
	
	aArea := GetArea()
	
	StartJob( "FinExecJob" , GetEnvServer() , .F. ,SM0->M0_CODIGO, FWGETCODFILIAL)
	
	RestArea(aArea)
	FwFreeArray(aArea)

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExecJob
Função que executa as atualizações na FKs

@author Pâmela Bernardo
@since 01/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Function FinExecJob (cEmp As Character, cFil As Character)
	Local aTabelas  As Array 
	Local aSM0  	As Array 
	Local cEmpAux   As Character
	Local cLockBy	As Character
	Local nx   		As Numeric
	Local nTamSM0	As Numeric

	cLockBy	:= "JobFixFks"

	If LockByName( cLockBy, .F., .F. )

		aTabelas:= {"FK1", "FK2", "FK3", "FK4", "FK5", "FK6", "FK7", "FK8", "FK9", "FKA"}
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,"FIN",,,aTabelas, /*lShowFinal*/, /*lAbend*/, .T. /*lOpenSX*/, /*lConnect*/)

		aSM0	:= FWLoadSM0()
		nTamSM0	:= len(aSM0)
		cEmpAux := ""
		nx		:= 0

		//Executa a FinExecFks() para cada grupo de empresa
		For nx:= 1 to nTamSM0
			If nx == 1 .or. (!Empty(cEmpAux) .and. cEmpAux <> aSM0[nx,1])
				StartJob( "FinExecFks" , GetEnvServer() , .T. ,aSM0[nx,1], aSM0[nx,2])			
				cEmpAux := aSM0[nx,1]
			EndIf
		Next nx

		UnLockByName( cLockBy, .F., .F. )
	Endif
Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExecFks
Função que executa as atualizações na FKs

@author Pâmela Bernardo
@since 01/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Function FinExecFks (cEmp As Character, cFil As Character)
	Local cMVFinFix As Character
	Local aTabelas  As Array 
	Local lMetrics As Logical

	aTabelas:= {"FK1", "FK2", "FK3", "FK4", "FK5", "FK6", "FK7", "FK8", "FK9", "FKA"}

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,"FIN",,,aTabelas, /*lShowFinal*/, /*lAbend*/, .T. /*lOpenSX*/, /*lConnect*/)
	
	lMetrics := FWLibVersion() >= "20210517"
	
	SetFunName("FINXFIX")

	cMVFinFix := SuperGetMv("MV_FINFIX",.F.,' ') //Verifico se tenho o novo parâmetero

	//Ajuste 001 - Clifor FK4
	If FK4->(FieldPos("FK4_CLIFOR")) > 0 .And. !ExecFix001(cEmp, cMVFinFix)
		FinExec001(cEmp, cMVFinFix)
	EndIf

	//Ajuste 002 - Ajuste colunas FK7
	If !Empty(cMvFinFix) .and. FK7->(FieldPos("FK7_CLIFOR")) > 0 .And. !ExecFix002()
		FinExec002(cEmp, cFil)
	EndIf

	//Ajuste 003 - Ajuste do campo FK6_TPDESC
	If !Empty(cMvFinFix) .and. !ExecFixN("3")
		FinExec003()
	EndIf

	//Ajuste 004 - Ajuste do campo FK6_CODVAL
	If !Empty(cMvFinFix) .and. !ExecFixN("4")
		FinExec004()
	EndIf

	//Ajuste 005 - Deleta duplicidades ao cancel. baixa de PA CNAB (devolução do pagamento) - Ref. DFINCOM-115
	If !Empty(cMvFinFix) .and. !ExecFixN("5")
		FinExec005()
	EndIf

	//Ajuste 006 - Ajusta FK2/FK5/SE5 ao baixar PA CNAB c/ cheque - Ref. DFINCOM-115
	If !Empty(cMvFinFix) .and. !ExecFixN("6")
		FinExec006()
	EndIf

	//Ajuste 007 - Deleta FK7 sem vinculo com titulos - Ref. DFINCOM-249
	If !Empty(cMvFinFix) .and. !ExecFixN("7")
		FinExec007()
	EndIf

	//Ajuste 008 - Ajusta FK2/SE5 o campo MULTNAT em branco - Ref. DFINCOM-169
	If !Empty(cMvFinFix) .and. !ExecFixN("8")
		FinExec008()
	EndIf

	//Ajuste 009 - Eliminar os registros de FK7 errados - Ref. DFINCOM-9727
	If !Empty(cMvFinFix) .and. !ExecFixN("9")
		FinExec009()
	EndIf

	//Ajuste 010 - Deleta FKA e FK1/FK2 de variação monetária (FINA350) cujo titulo foi excluido da SE1/SE2 - Ref. DFINCOM-166
	If !Empty(cMvFinFix) .and. !ExecFixN("10")
		FinExec010()
	EndIf

	//Ajuste 011 - Deleta FK7 de título (SE1/SE2 Deletado e FK7 com filial em branco)
	If !Empty(cMvFinFix) .and. !ExecFixN("11")
		FinExec011()
	EndIf

	//Ajuste 012 - Ajusta a tabela FK4 gravando os campos FK4_CGC e FK4_RAICGC
	If !Empty(cMvFinFix) .and. FK4->(FieldPos("FK4_CGC")) > 0 .And.  !ExecFixN("12")
		FinExec012(cEmp, cFil)
	EndIf

	//Ajuste 013 - Ajusta a tabela FK3 gravando os campos FK3_CGC e FK3_RAICGC
	If !Empty(cMvFinFix) .and. FK3->(FieldPos("FK3_CGC")) > 0 .And.  !ExecFixN("13")
		FinExec013(cEmp, cFil)
	EndIf

	//Ajuste 014 - Ajusta a tabela FK2 - Campo FK2_IDCOMP (Ref. DFINCOM-10187)
	If !Empty(cMvFinFix) .and. !ExecFixN("14")
		FinExec014(cEmp, cFil)
	EndIf

	//Ajuste 015 - Ajusta a tabela FK1 - Campo FK1_IDCOMP (Ref. DFINCOM-10187)
	If !Empty(cMvFinFix) .and. !ExecFixN("15")
		FinExec015(cEmp, cFil)
	EndIf

	//Ajuste 016 - Ajusta a tabela FK5 - Campo FK5_IDDOC (Ref. DFINCOM-10281)
	If !Empty(cMvFinFix) .and. !ExecFixN("16")
		FinExec016(cEmp, cFil)
	EndIf

	//Ajuste 017 - Ajusta a tabela FKs - Ajuste reservado para a PA
	If !Empty(cMvFinFix) .and. !ExecFixN("17")
		FinExec017(cEmp, cFil)
	EndIf

	//Ajuste 018 - Ajusta movimento V2 referente a titulo descontado (DFINCOM-10687)
	If !Empty(cMvFinFix) .and. !ExecFixN("18")
		FinExec018(cEmp, cFil)
	EndIf
	//Ajuste 019 - Adiciona a gravação dos campos FK3_CODRET e FK4_CODRET
	If !Empty(cMvFinFix) .and. !ExecFixN("19")
		FinExec019(cEmp, cFil)
	EndIf

	//Ajuste 020 - Preenche os campos FK2_DTDIG e FK2_DTDISP
	If !Empty(cMvFinFix) .and. !ExecFixN("20")
		FinExec020()
		//Caso seja incluido mais algum FIX, o bloco abaixo deve ser replicado para o último FIX do processo e o 3º parâmetro incrementado com o número 1
		If lMetrics .and. GetMv("MV_FINFIX",.F.,' ') == "20"
			//Telemetria - Último FIX executado
			FwCustomMetrics():setSumMetric("FINXFIX", "financeiro-protheus_financeiroprotheus_statusfixfks_info", 20)
		EndIf
	EndIf

	If !Empty(cMvFinFix) .and. !ExecFixN("21")
		//Executa a importação dos registros de origem FINA470, que foi descontinuado na versão 12.1.23
		FinExec021(cEmp, cFil)
		//Caso seja incluido mais algum FIX, o bloco abaixo deve ser replicado para o último FIX do processo e o 3º parâmetro incrementado com o número 1
		If lMetrics .and. GetMv("MV_FINFIX",.F.,' ') == "21"
			//Telemetria - Último FIX executado
			FwCustomMetrics():setSumMetric("FINXFIX", "financeiro-protheus_financeiroprotheus_statusfixfks_info", 21)
		EndIf
	EndIf

Return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ExecFix001
Verifica se a rotina de atualização do FK4 já foi executada

@param cEmp, characters, código da empresafilial
@return lRet, Lógico indicado se a rotina ja foi executada anteriormente
@author Simone Mie Sato Kakinoana
@since 04/11/2019
@version P12
/*/
//-------------------------------------------------------------------------------
Function ExecFix001(cEmp As Character, cMVFinFix As Character)

	Local cFile as Character 	
	Local lRet  as Logical

    Default cMVFinFix := ' '       //Verifico se tenho o novo parâmetero

	cFile	    := "FIXFK4"+cEmp+".VRF"
	lRet	    := .F.
	
	//Verifico se existe o parâmetro e se já a rotina já foi executada
	SX6->(DbSetOrder(1))
	If !SX6->(DbSeek(xFilial("SX6")+"MV_FIXFK4"))
		If FILE(cFile) //Verifico se existe o arquivo da empresa
			lRet	:= .T.
		EndIf
	Else
		If GetMV("MV_FIXFK4") == "1"	//Se executou a rotina
			lRet	:= .T.
		Else
			If FILE(cFile) //Verifico se existe o arquivo da empresa
				lRet	:= .T.
				PutMv("MV_FIXFK4","1")
				Ferase(cFile)
			EndIf
		EndIf	
	EndIf

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("1")
    EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec001
Chama rotina de atualização os campos FK4_CLIFOR e FK4_LOJA

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Simone Mie Sato Kakinoana
@since 01/11/2019
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec001(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local cFile		As Character
	Local nRecSM0 	As Numeric
    Local cMVFinFix As Character
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cFile	:= "FIXFK4"+cEmp+".VRF"
	cBkpEmp := cEmp
	cBkpFil	:= cFil
	cCodFil	:= ""
	lRet	:= .T.
    cMVFinFix := SuperGetMV("MV_FINFIX",.T.,' ')       //Verifico se tenho o novo parâmetero
	
	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf
	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == cCodFil
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf
		
		lRet := FnClForFK4(cCodFil)
		
		If !lRet		
			Exit
		EndIf
			
		SM0->(DbSkip())
		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	End
	SM0->(dbGoto(nRecSM0))

	If lRet
		SX6->(DbSetOrder(1))
		If SX6->(DbSeek(xFilial("SX6")+"MV_FIXFK4"))
			PutMv("MV_FIXFK4","1")
		Else
			fCreate(cFile)
		End
	EndIf

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix) .and. !(cMVFinFix >= '1')
        PutMv("MV_FINFIX","1")
    Endif

    If __oQryFK4 != Nil
        __oQryFK4:Destroy()
        FwFreeObj(__oQryFK4)
        __oQryFK4 := Nil
    EndIf

	cEmpAnt	:= cBkpEmp
	cFilAnt := cBkpFil

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnClForFK4
Atualiza os campos FK4_CLIFOR e FK4_LOJA

@param cFilAtu, characters, código da filial
@return lRet, Lógico indicado se a query foi executada corretamente
@author Simone Mie Sato Kakinoana
@since 29/10/2019
@version P12
/*/
//-------------------------------------------------------------------------------
Function FnClForFK4(cFilAtu As Character)

	Local cQry 		As Character
	Local cAliasFK4	As Character
	Local lRet	    As Logical

	lRet	:= .F.

	If TCGetDB() == "MSSQL"
		cQry := " UPDATE "  + RetSqlName("FK4")
		cQry += " SET FK4_CLIFOR = SE5.E5_CLIFOR, FK4_LOJA = SE5.E5_LOJA "
		cQry += " FROM "+ RetSqlName("FK4")+ " FK4, " + RetSqlName("SE5") + " SE5 "  
		cQry += " WHERE FK4.FK4_FILIAL = '"+ cFilAtu+ "' "
		cQry += " AND FK4.FK4_CLIFOR = ' '"
		cQry += " AND FK4.FK4_FILIAL = SE5.E5_FILIAL "
		cQry += " AND FK4.FK4_IDORIG = SE5.E5_IDORIG "
		cQry += " AND FK4.D_E_L_E_T_ = ' '"
		cQry += " AND SE5.D_E_L_E_T_ = ' '"
		
		lRet	:= TCSQLExec( cQry ) == 0 
	Else
		If __oQryFK4 == Nil
			cQry := " SELECT FK4.R_E_C_N_O_ FK4RECNO, FK4_FILIAL, FK4_IDORIG , FK4_CLIFOR, FK4_LOJA, FK4_RECPAG, E5_FILIAL, E5_IDORIG, E5_CLIFOR, E5_LOJA "
			cQry += " FROM " + RetSqlName("SE5") + " SE5, "+ RetSqlName("FK4") + " FK4 "
			cQry += " WHERE FK4.FK4_FILIAL = ? "
			cQry += " AND FK4.FK4_CLIFOR = ' ' "
			cQry += " AND FK4.FK4_FILIAL = SE5.E5_FILIAL "
			cQry += " AND FK4.FK4_IDORIG = SE5.E5_IDORIG "
			cQry += " AND FK4.D_E_L_E_T_ = ' '"
			cQry += " AND SE5.D_E_L_E_T_ = ' '"
			cQry := ChangeQuery(cQry)
			__oQryFK4 := FWPreparedStatement():New(cQry)
		EndIf
		
		__oQryFK4:SetString(1, cFilAtu)
		
		cQry := __oQryFK4:GetFixQuery()
		cAliasFK4 := MpSysOpenQuery(cQry)
		
		DbGotop()
			
		While (cAliasFK4)->(!Eof())

			lRet	:= .T.
			
			FK4->(dbGoto( (cAliasFK4)->FK4RECNO) )
			Reclock("FK4",.F.)
			FK4->FK4_CLIFOR := 	(cAliasFK4)->E5_CLIFOR
			FK4->FK4_LOJA	:= 	(cAliasFK4)->E5_LOJA
			MsUnlock()
			
			(cAliasFK4)->(DbSkip())
		EndDo
		
		If Select(cAliasFK4) > 0
			(cAliasFK4)->(DBCloseArea())
		EndIf

	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ExecFix002
Verifica se a rotina de atualização do FK7 - NOVAS COLUNAS

@param cEmp, characters, código da empresafilial
@return lRet, Lógico indicado se a rotina ja foi executada anteriormente
@author Mauricio Pequim Jr
@since 14/09/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function ExecFix002()

	Local lRet  	As Logical
	Local cMVFinFix As Character
	Local lFK7Cpos	As Logical
	
	lFK7Cpos	:= FK7->(ColumnPos("FK7_CLIFOR")) > 0 .and. FindFunction("FinFK7Cpos")
	lRet	    := .F.
    cMVFinFix   := GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	
	//Verifico se existe o parâmetro e se já a rotina já foi executada
	If lFK7Cpos .and. !Empty(cMVFinFix)
		If cMVFinFix >= "2"	//Se executou a rotina
			lRet	:= .T.
		EndIf	
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec002
Chama rotina de atualização os campos novos da FK7

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Mauricio Pequim Jr
@since 11/09/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec002(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoFK7	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
    Local cMVFinFix As Character
	Local nTamFil	As Numeric
	
	cModoFK7	:= FWModeAccess("FK7",1)+FWModeAccess("FK7",2)+FWModeAccess("FK7",3)
	
	cBkpEmp := cEmp
	cBkpFil	:= cFil
	cCodFil	:= ""
	lRet	:= .T.
    cMVFinFix := GetMV("MV_FINFIX")  
	nTamFil := Len(cFilAnt)
	
	If cModoFK7 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoFK7 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf
	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoFK7 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoFK7 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoFK7 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf
		
		cFilAnt := PadR(SM0->M0_CODFIL,nTamFil)
		cCodFil := PadR(cCodFil,nTamFil)

		lRet := FnGColFK7(cCodFil)  //FIX 002
		
		If lRet
			FAjFilFK7(cCodFil) 		//FIX 002.1
		Endif

		If !lRet		
			Exit
		EndIf

		SM0->(DbSkip())
		If ( cModoFK7 == "CCC" )
			Exit
		EndIf
	End

	SM0->(dbGoto(nRecSM0))

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("2")
    Endif

    If __oQryFK7 != Nil
        __oQryFK7:Destroy()
        FwFreeObj(__oQryFK7)
        __oQryFK7 := Nil
    EndIf

	cEmpAnt	:= cBkpEmp
	cFilAnt := cBkpFil

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnGColFK7
Atualiza os campos novos da tabela FK7

@param cFilAtu, characters, código da filial
@return lRet, Lógico indicado se a query foi executada corretamente
@author Mauricio Pequim Jr
@since 11/09/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnGColFK7(cCodFil As Character)

	Local cQry 		As Character
	Local cAliasFK7	As Character
	Local lRet	    As Logical

	cQry 	  := ""
	lRet	  := .F.
	cAliasFK7 := ""

	Default cCodFil := cFilAnt

	If __oQryFK7 == Nil
		cQry := " SELECT R_E_C_N_O_ FK7RECNO, FK7_FILIAL, FK7_CLIFOR "
		cQry += " FROM " + RetSqlName("FK7") + " "
		cQry += " WHERE FK7_FILIAL = ? "
		cQry += " AND FK7_CLIFOR = ' ' "
		cQry += " AND D_E_L_E_T_ = ' ' "
		cQry := ChangeQuery(cQry)
		__oQryFK7 := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK7:SetString(1, cCodFil)

	cQry := __oQryFK7:GetFixQuery()
	cAliasFK7 := MpSysOpenQuery(cQry)

	DbGotop()
		
	While (cAliasFK7)->(!Eof())
		lRet	:= .T.
		
		FK7->(dbGoto( (cAliasFK7)->FK7RECNO) )
		FinFK7Cpos (FK7->FK7_CHAVE)
		(cAliasFK7)->(DbSkip())
	Enddo

	If Select(cAliasFK7) > 0
		(cAliasFK7)->(DBCloseArea())
	EndIf
	
Return(lRet)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FAjFilFK7
Atualiza os campos FK7_CHAVE e FK7_FILIAL quando SE1/SE2/FK7 possuir compartilhamento
diferente (FK7=SE5 e FK7<>SE1/SE2)

@param cFilAtu, characters, código da filial
@return lRet, Lógico indicado se a query foi executada corretamente
@author Mauricio Pequim Jr
@since  04/10/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FAjFilFK7(cCodFil As Character)

	Local cQry 		As Character
	Local cAliasFK7	As Character
	Local cModoFK7	As Character
	Local cModoSE2	As Character
	Local cModoSE1	As Character		
	Local cModoSE5	As Character		

	cModoSE1 := FWModeAccess("SE1",1)+FWModeAccess("SE1",2)+FWModeAccess("SE1",3)
	cModoSE2 := FWModeAccess("SE2",1)+FWModeAccess("SE2",2)+FWModeAccess("SE2",3)
	cModoSE5 := FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	cModoFK7 := FWModeAccess("FK7",1)+FWModeAccess("FK7",2)+FWModeAccess("FK7",3)

	If (cModoSE1 != cModoFK7 .and. cModoSE5 == cModoFK7)

		If __oQryFE1 == Nil
			cQry := " SELECT R_E_C_N_O_ FK7RECNO, FK7_FILIAL, FK7_FILTIT "
			cQry += " FROM " + RetSqlName("FK7") + " "
			cQry += " WHERE FK7_FILIAL = ? "
			cQry += " AND FK7_FILTIT <> ? "
			cQry += " AND FK7_FILTIT = ? "		
			cQry += " AND FK7_ALIAS = 'SE1' "					
			cQry += " AND D_E_L_E_T_ = ' ' "
			cQry := ChangeQuery(cQry)
			__oQryFE1 := FWPreparedStatement():New(cQry)
		EndIf

		__oQryFE1:SetString(1, cCodFil)
		__oQryFE1:SetString(2, xFilial("SE1"))
		__oQryFE1:SetString(3, xFilial("SE5"))

		cQry := __oQryFE1:GetFixQuery()
		cAliasFK7 := MpSysOpenQuery(cQry)

		DbGotop()
			
		While (cAliasFK7)->(!Eof())
			FK7->(dbGoto( (cAliasFK7)->FK7RECNO) )
			FinFK7Fil ("SE1")
			(cAliasFK7)->(DbSkip())
		Enddo

		If Select(cAliasFK7) > 0
			(cAliasFK7)->(DBCloseArea())
		EndIf
	Endif

	If (cModoSE2 != cModoFK7 .and. cModoSE5 == cModoFK7)

		If __oQryFE2 == Nil
			cQry := " SELECT R_E_C_N_O_ FK7RECNO, FK7_FILIAL, FK7_FILTIT "
			cQry += " FROM " + RetSqlName("FK7") + " "
			cQry += " WHERE FK7_FILIAL = ? "
			cQry += " AND FK7_FILTIT <> ? "
			cQry += " AND FK7_FILTIT = ? "		
			cQry += " AND FK7_ALIAS = 'SE2' "					
			cQry += " AND D_E_L_E_T_ = ' ' "
			cQry := ChangeQuery(cQry)
			__oQryFE2 := FWPreparedStatement():New(cQry)
		EndIf

		__oQryFE2:SetString(1, cCodFil)
		__oQryFE2:SetString(2, xFilial("SE2"))
		__oQryFE2:SetString(3, xFilial("SE5"))

		cQry := __oQryFE2:GetFixQuery()
		cAliasFK7 := MpSysOpenQuery(cQry)

		DbGotop()
			
		While (cAliasFK7)->(!Eof())
			FK7->(dbGoto( (cAliasFK7)->FK7RECNO) )
			FinFK7Fil ("SE2")
			(cAliasFK7)->(DbSkip())
		Enddo

		If Select(cAliasFK7) > 0
			(cAliasFK7)->(DBCloseArea())
		EndIf
	Endif

Return


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}FinFK7Fil
Grava o ajuste nos campos FK7_CHAVE  e FK7_FILTIT 

@param cAlias, Alias origem do título

@author Mauricio Pequim Jr
@since  04/10/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------------------------------------------------
Function FinFK7Fil(cAlias As Character)
	Local cChave	AS Character
	Local cChaveFK7	AS Character

	Default cAlias	:= ''

	cChave	:= ""

	cChaveFK7 := xFilial(cAlias) + "|" + FK7->FK7_PREFIX + "|" + FK7->FK7_NUM	+ "|" +	FK7->FK7_PARCEL + "|" +	FK7->FK7_TIPO + "|" + FK7->FK7_CLIFOR + "|" + FK7->FK7_LOJA

	RecLock("FK7")
		FK7->FK7_FILTIT := xFilial(cAlias)	// Filial Titulo
		FK7->FK7_CHAVE  := cChaveFK7 		// Chave do título
	MsUnlock()

Return 


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AtuMvFix
Ajusta o MV_FINFIX

@param cCodFix, characters, código do fix executado

@author Mauricio Pequim Jr
@since 11/09/25020
@version P12
/*/
//-------------------------------------------------------------------------------

Static Function AtuMvFix(cCodFix As Character)

Local cMvFinFix As Character

DEFAULT cCodFix := ''

cMvFinFix := GetMv("MV_FINFIX")

// Garante que o numero do bordero seja sempre superior ao numero anterior
If Val(cMvFinFix) < Val(cCodFix)
	PutMv("MV_FINFIX",cCodFix)
EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ExecFixN
Verifica se a rotina de atualização do FK6_TPDESC já foi executada

@param cEmp, characters, código da empresafilial
@return lRet, Lógico indicado se a rotina ja foi executada anteriormente
@author Pâmela Bernardo
@since 01/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function ExecFixN(cFix As Character) as Logical
	Local lRet  	As Logical
	Local cMVFinFix As Character
	
	lRet	    := .F.
    cMVFinFix   := GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	
	//Verifico se existe o parâmetro e se já a rotina já foi executada
	If !Empty(cMVFinFix)
		If VAL(cMVFinFix) >= VAL(cFix)	//Se executou a rotina
			lRet	:= .T.
		EndIf	
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec003
Chama rotina de atualização do campo FK6_TPDESC

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Pâmela Bernardo
@since 01/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec003()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnGK6TPDESC()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("3")
    Endif

    If __oQryK6TPDES != Nil
        __oQryK6TPDES:Destroy()
        FwFreeObj(__oQryK6TPDES)
        __oQryK6TPDES := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnGK6TPDESC
Atualiza os campos FK6_TPDESC

@param cFilAtu, characters, código da filial
@return lRet, Lógico indicado se a query foi executada corretamente
@author Pâmela Bernardo
@since 01/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnGK6TPDESC()

	Local cQry 		As Character
	Local cAliasFK6	As Character
	Local lRet	    As Logical

	cQry		:= ""
	cAliasFK6	:= ""
	lRet		:= .F.

	If __oQryK6TPDES == Nil
		cQry := " SELECT R_E_C_N_O_ FK6RECNO, FK6_TPDESC "
		cQry += " FROM " + RetSqlName("FK6") + " FK6 "
		cQry += " WHERE (FK6.FK6_TPDESC = 'I' "
		cQry += " OR FK6.FK6_TPDESC = 'C') "
		cQry += " AND FK6.D_E_L_E_T_ = ' '"
		cQry := ChangeQuery(cQry)
		__oQryK6TPDES := FWPreparedStatement():New(cQry)
	EndIf
	
	cQry := __oQryK6TPDES:GetFixQuery()
	cAliasFK6 := MpSysOpenQuery(cQry)
	
	DbGotop()
		
	While (cAliasFK6)->(!Eof())
		
		lRet	:= .T.
		
		FK6->(dbGoto( (cAliasFK6)->FK6RECNO) )
		
		Reclock("FK6",.F.)
			If FK6->FK6_TPDESC == 'C'
				FK6->FK6_TPDESC := '1'
			Else 
				FK6->FK6_TPDESC := '2'
			EndIf
		MsUnlock()
		
		(cAliasFK6)->(DbSkip())
	EndDo
	
	If Select(cAliasFK6) > 0
		(cAliasFK6)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec004
Chama rotina de atualização do campo FK6_CODVAL

@author Rodrigo Oliveira
@since 05/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec004()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnGK6CODVAL()
		
    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("4")
    Endif

    If __oQryK6CODVAL != Nil
        __oQryK6CODVAL:Destroy()
        FwFreeObj(__oQryK6CODVAL)
        __oQryK6CODVAL := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnGK6CODVAL
Atualiza os campos FK6_CODVAL

@return lRet, Lógico indicado se a query foi executada corretamente
@author Rodrigo Oliveira
@since 05/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnGK6CODVAL() As Logical

	Local cQry 		As Character
	Local cAliasFK6	As Character
	Local lRet	    As Logical

	cQry		:= ""
	cAliasFK6	:= ""
	lRet		:= .F.

	If __oQryK6CODVAL == Nil
		cQry := " SELECT FK6.R_E_C_N_O_ FK6RECNO, FKC_DESC HIST, FKC_CODIGO COD, FKC_ACAO ACAO "
		cQry += " FROM " + RetSqlName("FK6") + " FK6 "
		cQry += " LEFT JOIN " + RetSqlName("FK2") + " FK2 "
		cQry += " ON FK6_TABORI = 'FK2' AND FK6_IDORIG = FK2_IDFK2 AND FK2.D_E_L_E_T_ = ' ' "
		cQry += " JOIN " + RetSqlName("FKD") + " FKD "
		cQry += " ON ( FK6_TABORI = 'FK2' AND FK2_IDDOC = FKD_IDDOC ) AND FKD.D_E_L_E_T_ = ' ' "
		cQry += " JOIN " + RetSqlName("FKC") + " FKC "
		cQry += " ON FKC_CODIGO = FKD_CODIGO AND FKC.D_E_L_E_T_ = ' ' "
		cQry += " WHERE FK6_CODVAL = ' '"
		cQry += " AND FK6_TPDOC = 'VA'"
		cQry += " AND FK6_VALCAL < 0"
		cQry += " AND FK6.D_E_L_E_T_ = ' ' "
		cQry := ChangeQuery(cQry)
		__oQryK6CODVAL := FWPreparedStatement():New(cQry)
	EndIf
	
	cQry := __oQryK6CODVAL:GetFixQuery()
	cAliasFK6 := MpSysOpenQuery(cQry)
	
	DbGotop()
		
	While (cAliasFK6)->(!Eof())
		lRet	:= .T.
		
		FK6->(dbGoto( (cAliasFK6)->FK6RECNO) )
		
		Reclock("FK6",.F.)
			FK6->FK6_CODVAL := (cAliasFK6)->COD
			FK6->FK6_HISTOR	:= (cAliasFK6)->HIST
			FK6->FK6_ACAO	:= (cAliasFK6)->ACAO			
		MsUnlock()
		
		(cAliasFK6)->(DbSkip())
	EndDo
	
	If Select(cAliasFK6) > 0
		(cAliasFK6)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec005
Chama rotina de delecao dos registros em duplicidade originados do cancelamento 
da baixa de titulos PA CNAB (devolução do pagamento) - Issue DFINCOM-115

@author Fabio Casagrande Lima
@since 14/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec005()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnDelCanPA()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("5")
    Endif

    If __oQryFK2 != Nil
        __oQryFK2:Destroy()
        FwFreeObj(__oQryFK2)
        __oQryFK2 := Nil
    EndIf

    If __oQryFK5 != Nil
        __oQryFK5:Destroy()
        FwFreeObj(__oQryFK5)
        __oQryFK5 := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnDelCanPA
Ajusta registros em duplicidade das tabelas FKA/FK2/FK5/FK6, originados do 
cancelamento de baixa de titulos PA CNAB (devolução do pagamento) - Issue DFINCOM-115.
Deletar as FKA, FK2, FK6, FK5 quando nao houver correspondente na tabela SE5.

@return lRet, Lógico indicado se a query foi executada corretamente
@author Fabio Casagrande Lima
@since 14/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnDelCanPA() As Logical

	Local cQry1	  As Character
	Local cQry2   As Character
	Local cAlias1 As Character
	Local cAlias2 As Character	
	Local lRet	  As Logical

	cQry1		:= ""
	cQry2		:= ""	
	cAlias1		:= ""
	cAlias2		:= ""	
	lRet		:= .F.

	//Query para buscar registros inconsistentes na tabela FK2
	If __oQryFK2 == Nil
		cQry1 := " SELECT FK2_IDFK2,FKA_IDPROC,FK2.R_E_C_N_O_ RECFK2,FKA.R_E_C_N_O_ RECFKA"
		cQry1 += " FROM  " + RetSqlName("FK2") + " FK2 "
		cQry1 += " INNER JOIN  " + RetSqlName("FK7") + " FK7 "
		cQry1 += 	" ON FK7_FILIAL = FK2_FILIAL AND FK7_IDDOC = FK2_IDDOC AND FK7_TIPO = 'PA' AND FK7.D_E_L_E_T_ = ' '"
		cQry1 += " INNER JOIN  " + RetSqlName("FKA") + " FKA "
		cQry1 += 	" ON FKA_FILIAL = FK2_FILIAL AND FKA_TABORI = 'FK2' AND FKA_IDORIG = FK2_IDFK2 AND FKA.D_E_L_E_T_ = ' '"
		cQry1 += " WHERE FK2_TPDOC = 'ES' AND FK2_MOTBX <> 'CMP' AND FK2_RECPAG = 'R' AND FK2.D_E_L_E_T_ = ' '"
		cQry1 += " AND NOT EXISTS( "
		cQry1 += 		" SELECT 1 FROM  " + RetSqlName("SE5") + " SE5 "
		cQry1 += 		" WHERE E5_FILIAL = FK2_FILIAL AND E5_TABORI = 'FK2' AND E5_IDORIG = FK2_IDFK2 AND E5_TIPO = 'PA' AND E5_RECPAG = 'P' AND E5_TIPODOC = 'ES' )"
		cQry1 := ChangeQuery(cQry1)
		__oQryFK2 := FWPreparedStatement():New(cQry1)
	EndIf
	
	cQry1    := __oQryFK2:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	DbGotop()
		
	While (cAlias1)->(!Eof())
		lRet := .T.

		//Query para buscar registros inconsistentes na tabela FK5, a partir do FKA_IDPROC da query acima
		If __oQryFK5 == Nil
			cQry2 := " SELECT FK5.R_E_C_N_O_ RECFK5"
			cQry2 += " FROM " + RetSqlName("FKA") + " FKA" 
			cQry2 += " INNER JOIN " + RetSqlName("FK5") + " FK5"
			cQry2 += 	" ON FKA_FILIAL = FK5_FILIAL AND FKA_IDORIG = FK5_IDMOV AND FK5_RECPAG = 'P' AND FK5_TPDOC = 'ES' AND FK5.D_E_L_E_T_ = ' '"
			cQry2 += " WHERE FKA_IDPROC = ? AND FKA_TABORI = 'FK5' AND FKA.D_E_L_E_T_ = ' '"

			cQry2 := ChangeQuery(cQry2)
			__oQryFK5 := FWPreparedStatement():New(cQry2)
		EndIf

		__oQryFK5:SetString(1, (cAlias1)->FKA_IDPROC)

		cQry2   := __oQryFK5:GetFixQuery()
		cAlias2 := MpSysOpenQuery(cQry2)

		While (cAlias2)->(!Eof())
			//Deleta registros da tabela FK5
			FK5->(dbGoto( (cAlias2)->RECFK5))
			Reclock("FK5",.F.)
			FK5->(dbDelete())
			FK5->(MsUnlock())

			(cAlias2)->(DbSkip())
		EndDo

		If Select(cAlias2) > 0
			(cAlias2)->(DBCloseArea())
		EndIf

		//Deleta registros da tabela FK2
		FK2->(dbGoto( (cAlias1)->RECFK2))
		Reclock("FK2",.F.)
		FK2->(dbDelete())
		FK2->(MsUnlock())

		//Deleta registros da tabela FKA
		FKA->(dbGoto( (cAlias1)->RECFKA ))
		Reclock("FKA",.F.)
		FKA->(dbDelete())
		FKA->(MsUnlock())

		//Deleta registros da tabela FK6
		DbSelectArea("FK6")
		FK6->( dbSetOrder(1) )
		If FK6->( dbSeek( xFilial("FK6") + (cAlias1)->FK2_IDFK2 + "FK2" ))
			RecLock("FK6",.F.)
			FK6->(dbDelete())
			FK6->(MsUnLock())
		EndIf

		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec006
Chama rotina de ajuste dos registros da FK2/FK5/SE5 originados da movimentacao 
de titulos PA CNAB com cheque gerados via FINA090/FINA091 - Issue DFINCOM-115

@author Fabio Casagrande Lima
@since 14/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec006()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnGCheqPa()
		
    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("6")
    EndIf

    If __oQryFK2 != Nil
        __oQryFK2:Destroy()
        FwFreeObj(__oQryFK2)
        __oQryFK2 := Nil
    EndIf

    If __oQryFK5 != Nil
        __oQryFK5:Destroy()
        FwFreeObj(__oQryFK5)
        __oQryFK5 := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnGCheqPa
Ajusta registros da FK2/FK5/SE5 que eram gerados c/ inconsistencia na movimentacao 
de titulos PA CNAB com cheque via FINA090/FINA091 (issue DFINCOM-115).

1) SE5 gravava para cada título um registro c/ E5_TIPODOC=PA e mais o registro 
totalizador do cheque (E5_TIPODOC=CH). Ajuste: de E5_TIPODOC=PA p/ E5_TIPODOC=BA;
2) FK2 gravava para cada título um registro c/ FK2_TPDOC=PA.
Ajuste: de E5_TIPODOC=PA p/ E5_TIPODOC=BA;
3) FK5 gravava para cada título um registro c/ E5_TIPODOC=PA e mais o registro 
totalizador do cheque (E5_TIPODOC=CH). Ajuste: Deletar os registros com E5_TIPODOC=PA;

@return lRet, Lógico indicado se a query foi executada corretamente
@author Fabio Casagrande Lima
@since 14/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnGCheqPa() As Logical

	Local cQry1	  As Character
	Local cQry2   As Character
	Local cAlias1 As Character
	Local cAlias2 As Character	
	Local lRet	  As Logical

	cQry1		:= ""
	cQry2		:= ""
	cAlias1		:= ""
	cAlias2		:= ""
	lRet		:= .F.

	//Query para buscar registros inconsistentes na tabela FK2
	If __oQryFK2 == Nil
		cQry1 := " SELECT FK2_IDFK2,FKA_IDPROC,FK2.R_E_C_N_O_ RECFK2,FKA.R_E_C_N_O_ RECFKA,SE5.R_E_C_N_O_ RECSE5" 
		cQry1 += " FROM " + RetSqlName("FK2") + " FK2" 
		cQry1 += " INNER JOIN " + RetSqlName("FK7") + " FK7"
		cQry1 += 	" ON FK7_FILIAL = FK2_FILIAL AND FK7_IDDOC = FK2_IDDOC AND FK7_TIPO = 'PA' AND FK7.D_E_L_E_T_ = ' '"
		cQry1 += " INNER JOIN " + RetSqlName("FKA") + " FKA"
		cQry1 += 	" ON FKA_FILIAL = FK2_FILIAL AND FKA_TABORI = 'FK2' AND FKA_IDORIG = FK2_IDFK2 AND FKA.D_E_L_E_T_ = ' '"
		cQry1 += " INNER JOIN " + RetSqlName("SE5") + " SE5"
		cQry1 += 	" ON E5_FILIAL = FK2_FILIAL AND E5_TABORI = 'FK2' AND E5_IDORIG = FK2_IDFK2 AND E5_TIPO = 'PA' AND E5_RECPAG = 'P' AND E5_TIPODOC = 'PA'" 
		cQry1 += 		" AND E5_NUMCHEQ <> ' ' AND SE5.D_E_L_E_T_ = ' '"
		cQry1 += " WHERE FK2_TPDOC = 'PA' AND FK2_MOTBX <> 'CMP' AND FK2_RECPAG = 'P' AND FK2.D_E_L_E_T_ = ' '"

		cQry1 := ChangeQuery(cQry1)
		__oQryFK2 := FWPreparedStatement():New(cQry1)
	EndIf
	
	cQry1    := __oQryFK2:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	DbGotop()
		
	While (cAlias1)->(!Eof())
		lRet := .T.

		//Query para busca registros inconsistentes na tabela FK5, a partir do FKA_IDPROC da query acima
		If __oQryFK5 == Nil
			cQry2 := " SELECT FK5.R_E_C_N_O_ RECFK5"
			cQry2 += " FROM " + RetSqlName("FKA") + " FKA"
			cQry2 += " INNER JOIN " + RetSqlName("FK5") + " FK5" 
			cQry2 += 	" ON FKA_FILIAL = FK5_FILIAL AND FKA_IDORIG = FK5_IDMOV AND FK5_RECPAG = 'P' AND FK5_TPDOC = 'PA' AND FK5.D_E_L_E_T_ = ' '
			cQry2 += " WHERE FKA_IDPROC = ? AND FKA_TABORI = 'FK5' AND FK5_NUMCH <> ' ' AND FKA.D_E_L_E_T_ = ' '

			cQry2 := ChangeQuery(cQry2)
			__oQryFK5 := FWPreparedStatement():New(cQry2)
		EndIf

		__oQryFK5:SetString(1, (cAlias1)->FKA_IDPROC)

		cQry2    := __oQryFK5:GetFixQuery()
		cAlias2 := MpSysOpenQuery(cQry2)

	 	//Deleta registros da tabela FK5 com FK5_TPDOC=PA, pois para PA com cheque só devera constar o FK5_TPDOC=CH 
		While (cAlias2)->(!Eof())
			FK5->(dbGoto( (cAlias2)->RECFK5 ))
			Reclock("FK5",.F.)
			FK5->(dbDelete())
			MsUnlock()

			(cAlias2)->(DbSkip())
		EndDo

		If Select(cAlias2) > 0
			(cAlias2)->(DBCloseArea())
		EndIf		

		//Ajusta registro na tabela FK2
		FK2->(dbGoto( (cAlias1)->RECFK2 ))
		RecLock("FK2",.F.)
		FK2->FK2_TPDOC := "BA"
		MsUnlock()

		//Ajusta registro na tabela SE5
		SE5->(dbGoto( (cAlias1)->RECSE5 ))
		RecLock("SE5",.F.)
		SE5->E5_TIPODOC := "BA"
		MsUnlock()		

		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec007
Chama rotina de ajuste que deleta registros da FK7 que nao possuem vinculo com
titulos, ou seja, que foram gerados indevidamente em branco.

@author Fabio Casagrande Lima
@since 20/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec007()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnDelK7Dupl()
		
    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("7")
    EndIf

    If __oQryFK7 != Nil
        __oQryFK7:Destroy()
        FwFreeObj(__oQryFK7)
        __oQryFK7 := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnDelK7Dupl
Deleta registros gerados indevidamente na tabela FK7, onde nao possui chave,
e consequentemente nao possui vinculo com titulos.
A execucao do passo 2 do FIX (FinExec002) é indispensavel para esse ajuste

@return lRet, Lógico indicado se a query foi executada corretamente
@author Fabio Casagrande Lima
@since 20/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnDelK7Dupl() As Logical

	Local cQry1	  As Character
	Local cAlias1 As Character
	Local lRet	  As Logical

	cQry1		:= ""
	cAlias1		:= ""
	lRet		:= .F.

	//Query para buscar registros inconsistentes na tabela FK2
	If __oQryFK7 == Nil
		cQry1 := " SELECT R_E_C_N_O_ RECFK7 "
		cQry1 += " FROM " + RetSqlName("FK7") + " "
		cQry1 += " WHERE D_E_L_E_T_ = ' ' AND FK7_PREFIX = ' ' AND FK7_NUM = ' ' " 
		cQry1 := ChangeQuery(cQry1)
		__oQryFK7 := FWPreparedStatement():New(cQry1)
	EndIf
	
	cQry1    := __oQryFK7:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	DbGotop()
		
	While (cAlias1)->(!Eof())
		lRet := .T.

		//Deleta registros da tabela FK7
		DbSelectArea("FK7")
		FK7->(dbGoto( (cAlias1)->RECFK7 ))
		Reclock("FK7",.F.)
		FK7->(dbDelete())
		MsUnlock()

		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec008
Ajuste no campo E5_MULTNAT, oriundo do FINA300 (Sispag), para ser preenchido
corretamente (1- Sim, 2- Não)

@author Rodrigo Oliveira
@since 21/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec008()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnFK2MUNAT()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("8")
    EndIf

    If __oQryK2MNat != Nil
        __oQryK2MNat:Destroy()
        FwFreeObj(__oQryK2MNat)
        __oQryK2MNat := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnFK2MUNAT
Rotina de atualização do campo FK2_MULNAT

@author Rodrigo Oliveira
@since 05/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnFK2MUNAT()

	Local cQry 		As Character
	Local cAliasFK2	As Character
	Local lRet	    As Logical

	cQry		:= ""
	cAliasFK2	:= ""
	lRet		:= .F.

	If __oQryK2MNat == Nil
	
		cQry := " SELECT FK2.R_E_C_N_O_ RECFK2, FK2_MULNAT, SE5.R_E_C_N_O_ RECSE5, E5_MULTNAT "
		cQry += " FROM " + RetSqlName("FK2") + " FK2 "
		cQry += " JOIN " + RetSqlName("SE5") + " SE5 "
		cQry += " ON E5_FILIAL = FK2_FILIAL "
		cQry += " AND E5_TABORI = 'FK2' "
		cQry += " AND E5_IDORIG = FK2_IDFK2 "
		cQry += " AND E5_ORIGEM = 'FINA300' "
		cQry += " AND SE5.D_E_L_E_T_ = ' ' "
		cQry += " WHERE FK2_MULNAT = ' ' "
		cQry += " AND FK2.D_E_L_E_T_ = ' ' "
		cQry := ChangeQuery(cQry)
	
		__oQryK2MNat := FWPreparedStatement():New(cQry)
	EndIf
	
	cQry 		:= __oQryK2MNat:GetFixQuery()
	cAliasFK2 	:= MpSysOpenQuery(cQry)
	
	(cAliasFK2)->(DbGotop())
	
	While (cAliasFK2)->(!Eof())
		lRet	:= .T.

		If Empty((cAliasFK2)->E5_MULTNAT)

			FK2->(dbGoto( (cAliasFK2)->RECFK2) )
			
			Reclock("FK2",.F.)
				FK2->FK2_MULNAT := "2"
			MsUnlock()
		
			SE5->(dbGoto( (cAliasFK2)->RECSE5) )
			
			Reclock("SE5",.F.)
				SE5->E5_MULTNAT := "2"
			MsUnlock()
		
		Else

			FK2->(dbGoto( (cAliasFK2)->RECFK2) )
			
			Reclock("FK2",.F.)
				FK2->FK2_MULNAT := (cAliasFK2)->E5_MULTNAT
			MsUnlock()
			
		EndIf
		(cAliasFK2)->(DbSkip())
	
	EndDo
	
	If Select(cAliasFK2) > 0
		(cAliasFK2)->(DBCloseArea())
	EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec009

@author Rodrigo Oliveira
@since 26/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec009()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnFK7DUPL()
		
    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("9")
    EndIf

    If __oQryK7Dupl != Nil
        __oQryK7Dupl:Destroy()
        FwFreeObj(__oQryK7Dupl)
        __oQryK7Dupl := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnFK7DUPL
Rotina de eliminação dos registros FK7 duplicados

@author Rodrigo Oliveira
@since 26/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnFK7DUPL()

	Local cQry 		As Character
	Local cAliasFK2	As Character
	Local cAliasFK1	As Character
	Local lRet	    As Logical

	cQry		:= ""
	cAliasFK2	:= ""
	cAliasFK1	:= ""
	lRet		:= .F.

	If __oQryK7Dupl == Nil
	
		cQry := " SELECT"
		cQry += " FK7_FILTIT, FK7_IDDOC IDDOC, FK7_CHAVE,"
		cQry += " SE2.E2_FILIAL E2FIL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, SE2.R_E_C_N_O_ RECSE2,"
		cQry += " FK2.FK2_ORIGEM, FK2.FK2_IDDOC, FK2.FK2_IDFK2, FK2.FK2_SEQ, FK2.R_E_C_N_O_ RECFK2, FKA.FKA_IDPROC,"

		cQry += " (SELECT FK7_IDDOC FROM " + RetSqlName("FK7") + " FK7RGHT"
		cQry += " WHERE E2_FILIAL = FK7_FILTIT"
	 	cQry += 	" AND E2_PREFIXO = FK7_PREFIX"
	 	cQry += 	" AND E2_NUM = FK7_NUM"
	 	cQry += 	" AND E2_PARCELA = FK7_PARCEL"
	 	cQry += 	" AND E2_TIPO = FK7_TIPO"
		cQry += 	" AND E2_FORNECE = FK7_CLIFOR"
	 	cQry += 	" AND E2_LOJA = FK7_LOJA"
		cQry += 	" AND FK7RGHT.FK7_ALIAS = 'SE2'"		 
	 	cQry += 	" AND FK7RGHT.D_E_L_E_T_ = ' ') FK7IDDOCRGHT"
		cQry += 	" , FK5_IDDOC, FK5.R_E_C_N_O_ RECFK5"

		cQry += " FROM " + RetSqlName("FK7") + " FK7"

		cQry += " JOIN " + RetSqlName("SE2") + " SE2 ON"
		cQry += " SE2.E2_PREFIXO = FK7.FK7_PREFIX AND"
		cQry += " SE2.E2_NUM = FK7.FK7_NUM AND"
		cQry += " SE2.E2_PARCELA = FK7.FK7_PARCEL AND"
		cQry += " SE2.E2_TIPO = FK7_TIPO AND"
		cQry += " SE2.E2_FORNECE = FK7_CLIFOR AND"
		cQry += " SE2.E2_LOJA = FK7.FK7_LOJA"

		cQry += " JOIN " + RetSqlName("FK2") + " FK2 ON FK2_IDDOC = FK7.FK7_IDDOC"
		cQry += " JOIN " + RetSqlName("FKA") + " FKA ON FK2_IDFK2 = FKA.FKA_IDORIG"
		cQry += " LEFT JOIN " + RetSqlName("FK5") + " FK5 ON FK5_IDDOC = FK2_IDDOC"
		cQry += " WHERE FK7.D_E_L_E_T_ = ' ' AND"
		cQry += " SE2.E2_FILIAL != FK7_FILTIT AND"
		cQry += " SE2.E2_PREFIXO = FK7_PREFIX AND"
		cQry += " SE2.E2_NUM = FK7_NUM AND"
		cQry += " SE2.E2_PARCELA = FK7_PARCEL AND"
		cQry += " SE2.E2_TIPO = FK7_TIPO AND"
		cQry += " SE2.E2_FORNECE = FK7_CLIFOR AND"
		cQry += " SE2.E2_LOJA  = FK7_LOJA AND"
		cQry += " FK7_ALIAS = 'SE2'"
		cQry += " AND SE2.D_E_L_E_T_ = ' '"

		cQry += " ORDER BY FK7_CHAVE"

		cQry := ChangeQuery(cQry)
	
		__oQryK7Dupl := FWPreparedStatement():New(cQry)
	EndIf
	
	cQry 		:= __oQryK7Dupl:GetFixQuery()
	cAliasFK2 	:= MpSysOpenQuery(cQry)
	
	(cAliasFK2)->(DbGoTop())

	CV8->(DbSetOrder(1))
	SE2->(DbSetOrder(1))

	While !(cAliasFK2)->(Eof())
		lRet	:= .T.
		If !Empty((cAliasFK2)->FK7IDDOCRGHT)
			If !SE2->(DbSeek((cAliasFK2)->(FK7_FILTIT + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ) )
				If CV8->(DbSeek(xFilial("CV8") + (cAliasFK2)->IDDOC) )
					RecLock("CV8", .F.)
					CV8->CV8_PROC := (cAliasFK2)->FK7IDDOCRGHT
					CV8->(MsUnLock())
				EndIf
				If !Empty((cAliasFK2)->RECFK2)
					FK2->(DbGoTo((cAliasFK2)->RECFK2))
					RecLock("FK2", .F.)
					FK2->FK2_IDDOC := (cAliasFK2)->FK7IDDOCRGHT
					FK2->(MsUnLock())
				EndIf
				If !Empty((cAliasFK2)->FK5_IDDOC)
					FK5->(DbGoTo((cAliasFK2)->RECFK5))
					RecLock("FK5", .F.)
					FK5->FK5_IDDOC := (cAliasFK2)->FK7IDDOCRGHT
					FK5->(MsUnLock())
				EndIf
				RecLock("FK7", .F.)
				FK7->(DbDelete())
				FK7->(MsUnlock())
			EndIf
		EndIf
		(cAliasFK2)->(DbSkip())
	EndDo

    __oQryK7Dupl:Destroy()
    FwFreeObj(__oQryK7Dupl)
    __oQryK7Dupl := Nil

	If Select(cAliasFK2) > 0
		(cAliasFK2)->(DBCloseArea())
	EndIf

	cQry := " SELECT"
	cQry += " FK7.FK7_IDDOC IDDOC, FK7_FILTIT, FK7.FK7_CHAVE,"
	cQry += " SE1.E1_FILIAL E1FIL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, SE1.R_E_C_N_O_ RECSE1,"
	cQry += " FK1.FK1_ORIGEM, FK1.FK1_IDDOC, FK1.FK1_IDFK1, FK1.FK1_SEQ, FK1.R_E_C_N_O_ RECFK1, FKA.FKA_IDPROC"

	cQry += " , (SELECT FK7_IDDOC FROM " + RetSqlName("FK7") + " FK7RGHT"
	cQry += " 	WHERE E1_FILIAL = FK7_FILTIT"
	cQry += 	" AND E1_PREFIXO = FK7_PREFIX"
	cQry += 	" AND E1_NUM = FK7_NUM"
	cQry += 	" AND E1_PARCELA = FK7_PARCEL"
	cQry += 	" AND E1_TIPO = FK7_TIPO"
	cQry += 	" AND E1_CLIENTE = FK7_CLIFOR"
	cQry += 	" AND E1_LOJA = FK7_LOJA"
	cQry += 	" AND FK7RGHT.FK7_ALIAS = 'SE1'"		 	
	cQry += 	" AND FK7RGHT.D_E_L_E_T_ = ' ') FK7IDDOCRGHT"
	cQry += 	" , FK5_IDDOC, FK5.R_E_C_N_O_ RECFK5"

	cQry += " FROM " + RetSqlName("FK7") + " FK7"

	cQry += " JOIN " + RetSqlName("SE1") + " SE1 ON"
	cQry += " SE1.E1_PREFIXO = FK7.FK7_PREFIX AND"
	cQry += " SE1.E1_NUM = FK7.FK7_NUM AND"
	cQry += " SE1.E1_PARCELA = FK7.FK7_PARCEL AND"
	cQry += " SE1.E1_TIPO = FK7_TIPO AND"
	cQry += " SE1.E1_CLIENTE = FK7_CLIFOR AND"
	cQry += " SE1.E1_LOJA = FK7.FK7_LOJA"

	cQry += " JOIN " + RetSqlName("FK1") + " FK1 ON FK1_IDDOC = FK7.FK7_IDDOC"
	cQry += " JOIN " + RetSqlName("FKA") + " FKA ON FK1_IDFK1 = FKA.FKA_IDORIG"
	cQry += " LEFT JOIN " + RetSqlName("FK5") + " FK5 ON FK5_IDDOC = FK1_IDDOC"
	cQry += " WHERE FK7.D_E_L_E_T_ = ' ' AND"
	cQry += " SE1.E1_FILIAL != FK7_FILTIT AND"
	cQry += " SE1.E1_PREFIXO = FK7_PREFIX AND"
	cQry += " SE1.E1_NUM = FK7_NUM AND"
	cQry += " SE1.E1_PARCELA = FK7_PARCEL AND"
	cQry += " SE1.E1_TIPO = FK7_TIPO AND"
	cQry += " SE1.E1_CLIENTE = FK7_CLIFOR AND"
	cQry += " SE1.E1_LOJA  = FK7_LOJA AND"
	cQry += " FK7_ALIAS = 'SE1'"
	cQry += " AND SE1.D_E_L_E_T_ = ' '"

	cQry += " ORDER BY FK7_CHAVE"
	cQry := ChangeQuery(cQry)
	
	__oQryK7Dupl := FWPreparedStatement():New(cQry)

	cQry 		:= __oQryK7Dupl:GetFixQuery()
	cAliasFK1 	:= MpSysOpenQuery(cQry)

	(cAliasFK1)->(DbGoTop())

	CV8->(DbSetOrder(1))
	SE1->(DbSetOrder(1))
	
	While !(cAliasFK1)->(Eof())
		lRet	:= .T.
		If !Empty((cAliasFK1)->FK7IDDOCRGHT)
			If !SE1->(DbSeek((cAliasFK1)->(FK7_FILTIT + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO) ) )
				If CV8->(DbSeek(xFilial("CV8") + (cAliasFK1)->IDDOC) )
					RecLock("CV8", .F.)
					CV8->CV8_PROC := (cAliasFK1)->FK7IDDOCRGHT
					CV8->(MsUnLock())
				EndIf
				If !Empty((cAliasFK1)->RECFK1)
					FK1->(DbGoTo((cAliasFK1)->RECFK1))
					RecLock("FK1", .F.)
					FK1->FK1_IDDOC := (cAliasFK1)->FK7IDDOCRGHT
					FK1->(MsUnLock())
				EndIf
				If !Empty((cAliasFK1)->FK5_IDDOC)
					FK5->(DbGoTo((cAliasFK1)->RECFK5))
					RecLock("FK5", .F.)
					FK5->FK5_IDDOC := (cAliasFK1)->FK7IDDOCRGHT
					FK5->(MsUnLock())
				EndIf
				RecLock("FK7", .F.)
				FK7->(DbDelete())
				FK7->(MsUnlock())
			EndIf
		EndIf
		(cAliasFK1)->(DbSkip())
	EndDo

	If lRet .And. Select(cAliasFK1) > 0
		(cAliasFK1)->(DBCloseArea())
	EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec010
Chama rotina de delecao dos registros da FKA e FK1/FK2 originados da apuração de
variação monetária e cujo título já foi deletado.
Issue DFINCOM-166

@author Mauricio Pequim Jr
@since 26/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec010()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnDelFKVM()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("10")
    Endif

    If __oQryFK2 != Nil
        __oQryFK2:Destroy()
        FwFreeObj(__oQryFK2)
        __oQryFK2 := Nil
    EndIf

    If __oQryFK1 != Nil
        __oQryFK1:Destroy()
        FwFreeObj(__oQryFK1)
        __oQryFK1 := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnDelFKVM
Deleta FKA e FK1/FK2 de variação monetária (FINA350) cujo titulo foi excluido 
da SE1/SE2 - Ref. DFINCOM-166

@return lRet, Lógico indicado se a query foi executada corretamente
@author Mauricio Pequim Jr
@since 26/10/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnDelFKVM() As Logical

	Local cQry1	  As Character
	Local cQry2   As Character
	Local cAlias1 As Character
	Local cAlias2 As Character
	Local lRet	  As Logical

	cQry1		:= ""
	cQry2		:= ""	
	cAlias1		:= ""
	cAlias2		:= ""	
	lRet		:= .F.

	//Query para buscar registros inconsistentes na tabela FK2
	If __oQryFK1 == Nil
		cQry1 := " SELECT FK1_IDFK1,FKA_IDPROC,FK1.R_E_C_N_O_ RECFK1,FKA.R_E_C_N_O_ RECFKA"
		cQry1 += " FROM  " + RetSqlName("FK1") + " FK1 "
		cQry1 += " INNER JOIN  " + RetSqlName("FK7") + " FK7 "
		cQry1 += 	" ON FK7_FILIAL = FK1_FILIAL AND FK7_IDDOC = FK1_IDDOC AND FK7.D_E_L_E_T_ = '*'"
		cQry1 += " INNER JOIN  " + RetSqlName("FKA") + " FKA "
		cQry1 += 	" ON FKA_FILIAL = FK1_FILIAL AND FKA_TABORI = 'FK1' AND FKA_IDORIG = FK1_IDFK1 AND FKA.D_E_L_E_T_ = ' '"
		cQry1 += " WHERE FK1_MOTBX = 'VM ' AND FK1.D_E_L_E_T_ = ' '"
		cQry1 := ChangeQuery(cQry1)
		__oQryFK1 := FWPreparedStatement():New(cQry1)
	EndIf

	cQry1    := __oQryFK1:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	DbGotop()
		
	While (cAlias1)->(!Eof())
		lRet := .T.

		//Deleta registros da tabela FK1
		FK1->(dbGoto( (cAlias1)->RECFK1))
		Reclock("FK1",.F.)
		FK1->(dbDelete())
		FK1->(MsUnlock())

		//Deleta registros da tabela FKA
		FKA->(dbGoto( (cAlias1)->RECFKA ))
		Reclock("FKA",.F.)
		FKA->(dbDelete())
		FKA->(MsUnlock())

		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

	//Query para buscar registros inconsistentes na tabela FK2
	If __oQryFK2 == Nil
		cQry2 := " SELECT FK2_IDFK2,FKA_IDPROC,FK2.R_E_C_N_O_ RECFK2,FKA.R_E_C_N_O_ RECFKA"
		cQry2 += " FROM  " + RetSqlName("FK2") + " FK2 "
		cQry2 += " INNER JOIN  " + RetSqlName("FK7") + " FK7 "
		cQry2 += 	" ON FK7_FILIAL = FK2_FILIAL AND FK7_IDDOC = FK2_IDDOC AND FK7.D_E_L_E_T_ = '*'"
		cQry2 += " INNER JOIN  " + RetSqlName("FKA") + " FKA "
		cQry2 += 	" ON FKA_FILIAL = FK2_FILIAL AND FKA_TABORI = 'FK2' AND FKA_IDORIG = FK2_IDFK2 AND FKA.D_E_L_E_T_ = ' '"
		cQry2 += " WHERE FK2_MOTBX = 'VM ' AND FK2.D_E_L_E_T_ = ' '"
		cQry2 := ChangeQuery(cQry2)
		__oQryFK2 := FWPreparedStatement():New(cQry2)
	EndIf

	cQry2    := __oQryFK2:GetFixQuery()
	cAlias2 := MpSysOpenQuery(cQry2)
	
	DbGotop()
		
	While (cAlias2)->(!Eof())
		lRet := .T.

		//Deleta registros da tabela FK2
		FK2->(dbGoto( (cAlias2)->RECFK2))
		Reclock("FK2",.F.)
		FK2->(dbDelete())
		FK2->(MsUnlock())

		//Deleta registros da tabela FKA
		FKA->(dbGoto( (cAlias2)->RECFKA ))
		Reclock("FKA",.F.)
		FKA->(dbDelete())
		FKA->(MsUnlock())

		(cAlias2)->(DbSkip())
	EndDo

	If Select(cAlias2) > 0
		(cAlias2)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec011
Deleta FK7 de título (SE1/SE2 Deletado e FK7 com filial em branco) 
Ref. DFINCOM-9735

@author Mauricio Pequim Jr
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec011()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FDelFK7DS()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("11")
    Endif

    If __oQryFKX != Nil
        __oQryFKX:Destroy()
        FwFreeObj(__oQryFK1)
        __oQryFKX := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FDelFK7DS
Deleta FK7 de título (SE1/SE2 Deletado e FK7 com filial em branco) 
Ref. DFINCOM-9735

@return lRet, Lógico indicado se a query foi executada corretamente
@author Mauricio Pequim Jr
@since 25/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FDelFK7DS() As Logical

	Local cQry			As Character
	Local cAlias		As Character
	Local lRet			As Logical
	Local lSE1Comp		As Logical 
	Local lSE2Comp		As Logical

	cQry		:= ""
	cAlias		:= ""
	lRet		:= .F.
	nX			:= 0
	lSE1Comp  	:= FWModeAccess("SE1",1)== "C"
	lSE2Comp  	:= FWModeAccess("SE2",1)== "C"

	//Query para buscar registros inconsistentes na tabela FK7
	cQry += " SELECT DISTINCT FK7.R_E_C_N_O_ FK7RECNO "
	cQry += " FROM " + RetSqlName("FK7") + " FK7"

	//SE1 compartilhado, verifico se o SE1 correspondente está deletado
	//SE1 exclusivo e os campos FK7_FILIAL e FK7_FILTIT vazios, deleto sem olhar para SE1 (erro de gravação)
	If lSE1Comp	
		cQry += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON"
		cQry += " E1_FILIAL = FK7_FILTIT "	
		cQry += " AND E1_PREFIXO = FK7_PREFIX"
		cQry += " AND E1_NUM = FK7_NUM"
		cQry += " AND E1_PARCELA = FK7_PARCEL"
		cQry += " AND E1_TIPO = FK7_TIPO"
		cQry += " AND E1_CLIENTE = FK7_CLIFOR"
		cQry += " AND E1_LOJA = FK7_LOJA"
		cQry += " AND SE1.D_E_L_E_T_ = '*' "
	Endif	

	cQry += " WHERE FK7_ALIAS = 'SE1'"
	cQry += 	" AND FK7_FILIAL = ' ' "
	cQry += 	" AND FK7_FILTIT = ' '"
	cQry += 	" AND FK7.D_E_L_E_T_ = ' ' "

	cQry += " UNION ALL "

	cQry += " SELECT DISTINCT FK7.R_E_C_N_O_ FK7RECNO "
	cQry += " FROM " + RetSqlName("FK7") + " FK7"

	//SE2 compartilhado, verifico se o SE2 correspondente está deletado
	//SE2 exclusivo em algum nível e os campos FK7_FILIAL e FK7_FILTIT vazios, deleto sem olhar para SE2 (erro de gravação)
	If lSE2Comp
		cQry += " INNER JOIN " + RetSqlName("SE2") + " SE2 ON"
		cQry += " E2_FILIAL = FK7_FILTIT "	
		cQry += " AND E2_PREFIXO = FK7_PREFIX"
		cQry += " AND E2_NUM = FK7_NUM"
		cQry += " AND E2_PARCELA = FK7_PARCEL"
		cQry += " AND E2_TIPO = FK7_TIPO"
		cQry += " AND E2_FORNECE = FK7_CLIFOR"
		cQry += " AND E2_LOJA = FK7_LOJA"
		cQry += " AND SE2.D_E_L_E_T_ = '*'"
	Endif	

	cQry += " WHERE FK7_ALIAS = 'SE2'"
	cQry += 	" AND FK7_FILIAL = ' ' "
	cQry += 	" AND FK7_FILTIT = ' '"
	cQry += 	" AND FK7.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)
	__oQryFKX := FWPreparedStatement():New(cQry)

	cQry    := __oQryFKX:GetFixQuery()
	cAlias := MpSysOpenQuery(cQry)
	
	DbGotop()
		
	While (cAlias)->(!Eof())
		lRet := .T.

		//Deleta registros da tabela FK7
		FK7->(dbGoto( (cAlias)->FK7RECNO))
		Reclock("FK7",.F.)
		FK7->(dbDelete())
		FK7->(MsUnlock())

		(cAlias)->(DbSkip())

	EndDo

	If Select(cAlias) > 0
		(cAlias)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec012
Ajusta a tabela FK4 gravando os campos FK4_CGC e FK4_RAICGC

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Mauricio Pequim Jr
@since 27/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec012(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
    Local cMVFinFix As Character
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp := cEmp
	cBkpFil	:= cFil
	cCodFil	:= ""
	lRet	:= .T.
    cMVFinFix := GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	
	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf

		cCodFil := Padr(cCodFil,Len(FK4->FK4_FILIAL))

		lRet := FCGCFK4(cCodFil)
		
		If !lRet		
			Exit
		EndIf
			
		SM0->(DbSkip())
		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	End
	SM0->(dbGoto(nRecSM0))

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("12")
    Endif

    If __oQryFK4P != Nil
        __oQryFK4P:Destroy()
        FwFreeObj(__oQryFK4P)
        __oQryFK4P := Nil
    EndIf

    If __oQryFK4R != Nil
        __oQryFK4R:Destroy()
        FwFreeObj(__oQryFK4R)
        __oQryFK4R := Nil
    EndIf

    If __oQryFK7P != Nil
        __oQryFK7P:Destroy()
        FwFreeObj(__oQryFK7P)
        __oQryFK7P := Nil
    EndIf

    If __oQryFK7R != Nil
        __oQryFK7R:Destroy()
        FwFreeObj(__oQryFK7R)
        __oQryFK7R := Nil
    EndIf

	cEmpAnt	:= cBkpEmp
	cFilAnt := cBkpFil

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FCGCFK4
Atualiza os campos FK4_CGC e FK4_RAICGC

@param cFilAtu, characters, código da filial
@return lRet, Lógico indicado se a query foi executada corretamente
@author Mauricio Pequim Jr
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Function FCGCFK4(cFilAtu As Character)

	Local cQry 		As Character
	Local cAliasFK4	As Character
	Local lRet	    As Logical

	cQry := ""
	cAliasFK4 := ""
	lRet := .F.

	//BAIXAS CP
	If __oQryFK4P == Nil
		cQry := " SELECT DISTINCT FK4.R_E_C_N_O_ FK4RECNO, FK4_FILIAL, FK4_IDORIG, FK4_CLIFOR, FK4_LOJA, FK4_RECPAG, FK4_FILORI, "
		cQry += " E5_FILIAL, E5_IDORIG, E5_CLIFOR, E5_LOJA, "
		cQry += " A2_FILIAL, A2_COD, A2_LOJA, A2_CGC "		
		cQry += " FROM " + RetSqlName("SE5") + " SE5, "+ RetSqlName("FK4") + " FK4, "+ RetSqlName("SA2") + " SA2 "
		cQry += " WHERE FK4.FK4_FILIAL = ? "
		cQry += " AND FK4.FK4_CGC = ' ' "
		cQry += " AND FK4.FK4_FILIAL = SE5.E5_FILIAL "
		cQry += " AND FK4.FK4_IDORIG = SE5.E5_IDORIG "
		cQry += " AND SA2.A2_FILIAL = ? "
		cQry += " AND SA2.A2_COD = SE5.E5_CLIFOR "	
		cQry += " AND SA2.A2_LOJA = SE5.E5_LOJA "
		cQry += " AND ((SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC <> 'ES') "	
		cQry +=   " OR (SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC = 'ES' ) ) "
		cQry += " AND FK4.D_E_L_E_T_ = ' '"
		cQry += " AND SE5.D_E_L_E_T_ = ' '"
		cQry += " AND SA2.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK4P := FWPreparedStatement():New(cQry)
	EndIf
	
	__oQryFK4P:SetString(1, cFilAtu)
	__oQryFK4P:SetString(2, xFilial("SA2", cFilAtu))
	
	cQry := __oQryFK4P:GetFixQuery()
	cAliasFK4 := MpSysOpenQuery(cQry)
	
	DbGotop()
		
	While (cAliasFK4)->(!Eof())
		lRet	:= .T.

		FK4->(dbGoto( (cAliasFK4)->FK4RECNO) )
		Reclock("FK4",.F.)
		FK4->FK4_CLIFOR := (cAliasFK4)->E5_CLIFOR
		FK4->FK4_LOJA	:= (cAliasFK4)->E5_LOJA
		FK4->FK4_CGC 	:= (cAliasFK4)->A2_CGC
		FK4->FK4_RAICGC	:= Substr((cAliasFK4)->A2_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK4)->(DbSkip())
	EndDo
	
	If Select(cAliasFK4) > 0
		(cAliasFK4)->(DBCloseArea())
	EndIf

	//BAIXAS CR
	If __oQryFK4R == Nil
		cQry := " SELECT DISTINCT FK4.R_E_C_N_O_ FK4RECNO, FK4_FILIAL, FK4_IDORIG, FK4_CLIFOR, FK4_LOJA, FK4_RECPAG, FK4_FILORI, "
		cQry += " E5_FILIAL, E5_IDORIG, E5_CLIFOR, E5_LOJA, "
		cQry += " A1_FILIAL, A1_COD, A1_LOJA, A1_CGC "		
		cQry += " FROM " + RetSqlName("SE5") + " SE5, "+ RetSqlName("FK4") + " FK4, "+ RetSqlName("SA1") + " SA1 "
		cQry += " WHERE FK4.FK4_FILIAL = ? "
		cQry += " AND FK4.FK4_CGC = ' ' "
		cQry += " AND FK4.FK4_FILIAL = SE5.E5_FILIAL "
		cQry += " AND FK4.FK4_IDORIG = SE5.E5_IDORIG "
		cQry += " AND SA1.A1_FILIAL = ? "
		cQry += " AND SA1.A1_COD = SE5.E5_CLIFOR "	
		cQry += " AND SA1.A1_LOJA = SE5.E5_LOJA "
		cQry += " AND ((SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC <> 'ES') "	
		cQry +=   " OR (SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC = 'ES') ) "
		cQry += " AND FK4.D_E_L_E_T_ = ' '"
		cQry += " AND SE5.D_E_L_E_T_ = ' '"
		cQry += " AND SA1.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK4R := FWPreparedStatement():New(cQry)
	EndIf
	
	__oQryFK4R:SetString(1, cFilAtu)
	__oQryFK4R:SetString(2, xFilial("SA1", cFilAtu))
	
	cQry := __oQryFK4R:GetFixQuery()
	cAliasFK4 := MpSysOpenQuery(cQry)
	
	DbGotop()
		
	While (cAliasFK4)->(!Eof())
		lRet	:= .T.
		
		FK4->(dbGoto( (cAliasFK4)->FK4RECNO) )
		Reclock("FK4",.F.)
		FK4->FK4_CLIFOR := (cAliasFK4)->E5_CLIFOR
		FK4->FK4_LOJA	:= (cAliasFK4)->E5_LOJA
		FK4->FK4_CGC 	:= (cAliasFK4)->A1_CGC
		FK4->FK4_RAICGC	:= Substr((cAliasFK4)->A1_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK4)->(DbSkip())
	EndDo
	
	If Select(cAliasFK4) > 0
		(cAliasFK4)->(DBCloseArea())
	EndIf

	//EMISSOES CP
	If __oQryFK7P == Nil
		cQry := " SELECT DISTINCT FK4.R_E_C_N_O_ FK4RECNO, "
		cQry += " A2_COD, A2_LOJA, A2_CGC "		
		cQry += " FROM " + RetSqlName("FK7") + " FK7, "+ RetSqlName("FK4") + " FK4, "+ RetSqlName("SA2") + " SA2 "
		cQry += " WHERE FK4.FK4_FILIAL = ? "
		cQry += " AND FK4.FK4_CGC = ' ' "
		cQry += " AND FK4.FK4_FILIAL = FK7.FK7_FILIAL "
		cQry += " AND FK4.FK4_IDORIG = FK7.FK7_IDDOC "
		cQry += " AND SA2.A2_FILIAL = ? "
		cQry += " AND SA2.A2_COD = FK7.FK7_CLIFOR "	
		cQry += " AND SA2.A2_LOJA = FK7.FK7_LOJA "
		cQry += " AND FK7_ALIAS = 'SE2' "		
		cQry += " AND FK4.D_E_L_E_T_ = ' '"
		cQry += " AND FK7.D_E_L_E_T_ = ' '"
		cQry += " AND SA2.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK7P := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK7P:SetString(1, cFilAtu)
	__oQryFK7P:SetString(2, xFilial("SA2", cFilAtu))
	
	cQry := __oQryFK7P:GetFixQuery()
	cAliasFK4 := MpSysOpenQuery(cQry)
	
	DbGotop()

	While (cAliasFK4)->(!Eof())
		lRet	:= .T.
		
		FK4->(dbGoto( (cAliasFK4)->FK4RECNO) )
		Reclock("FK4",.F.)
		FK4->FK4_CLIFOR := (cAliasFK4)->A2_COD
		FK4->FK4_LOJA	:= (cAliasFK4)->A2_LOJA
		FK4->FK4_CGC 	:= (cAliasFK4)->A2_CGC
		FK4->FK4_RAICGC	:= Substr((cAliasFK4)->A2_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK4)->(DbSkip())
	EndDo

	If Select(cAliasFK4) > 0
		(cAliasFK4)->(DBCloseArea())
	EndIf

	//EMISSOES CR
	If __oQryFK7R == Nil
		cQry := " SELECT FK4.R_E_C_N_O_ FK4RECNO, "
		cQry += " A1_COD, A1_LOJA, A1_CGC "		
		cQry += " FROM " + RetSqlName("FK7") + " FK7, "+ RetSqlName("FK4") + " FK4, "+ RetSqlName("SA1") + " SA1 "
		cQry += " WHERE FK4.FK4_FILIAL = ? "
		cQry += " AND FK4.FK4_CGC = ' ' "
		cQry += " AND FK4.FK4_FILIAL = FK7.FK7_FILIAL "
		cQry += " AND FK4.FK4_IDORIG = FK7.FK7_IDDOC "
		cQry += " AND SA1.A1_FILIAL = ? "
		cQry += " AND SA1.A1_COD = FK7.FK7_CLIFOR "	
		cQry += " AND SA1.A1_LOJA = FK7.FK7_LOJA "
		cQry += " AND FK7_ALIAS = 'SE1' "
		cQry += " AND FK4.D_E_L_E_T_ = ' '"
		cQry += " AND FK7.D_E_L_E_T_ = ' '"
		cQry += " AND SA1.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK7R := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK7R:SetString(1, cFilAtu)
	__oQryFK7R:SetString(2, xFilial("SA1", cFilAtu))
	
	cQry := __oQryFK7R:GetFixQuery()
	cAliasFK4 := MpSysOpenQuery(cQry)
	
	DbGotop()

	While (cAliasFK4)->(!Eof())
		lRet := .T.

		FK4->(dbGoto( (cAliasFK4)->FK4RECNO) )
		Reclock("FK4",.F.)
		FK4->FK4_CLIFOR := (cAliasFK4)->A1_COD
		FK4->FK4_LOJA	:= (cAliasFK4)->A1_LOJA
		FK4->FK4_CGC 	:= (cAliasFK4)->A1_CGC
		FK4->FK4_RAICGC	:= Substr((cAliasFK4)->A1_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK4)->(DbSkip())
	EndDo

	If Select(cAliasFK4) > 0
		(cAliasFK4)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec013
Ajusta a tabela FK3 gravando os campos FK3_CGC e FK3_RAICGC

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Mauricio Pequim Jr
@since 27/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec013(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
    Local cMVFinFix As Character
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp := cEmp
	cBkpFil	:= cFil
	cCodFil	:= ""
	lRet	:= .T.
    cMVFinFix := GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	
	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf

		cCodFil := Padr(cCodFil,Len(FK4->FK4_FILIAL))

		lRet := FCGCFK3(cCodFil)
		
		If !lRet		
			Exit
		EndIf
			
		SM0->(DbSkip())
		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	End
	SM0->(dbGoto(nRecSM0))


    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("13")
    Endif

    If __oQryFK3P != Nil
        __oQryFK3P:Destroy()
        FwFreeObj(__oQryFK4P)
        __oQryFK3P := Nil
    EndIf

    If __oQryFK3R != Nil
        __oQryFK3R:Destroy()
        FwFreeObj(__oQryFK4R)
        __oQryFK3R := Nil
    EndIf

    If __oQryFK7P != Nil
        __oQryFK7P:Destroy()
        FwFreeObj(__oQryFK7P)
        __oQryFK7P := Nil
    EndIf

    If __oQryFK7R != Nil
        __oQryFK7R:Destroy()
        FwFreeObj(__oQryFK7R)
        __oQryFK7R := Nil
    EndIf

	cEmpAnt	:= cBkpEmp
	cFilAnt := cBkpFil

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FCGCFK3
Atualiza os campos FK3_CGC e FK3_RAICGC

@param cFilAtu, characters, código da filial
@return lRet, Lógico indicado se a query foi executada corretamente
@author Mauricio Pequim Jr
@since 27/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Function FCGCFK3(cFilAtu As Character)

	Local cQry 		As Character
	Local cAliasFK3	As Character
	Local lRet	    As Logical

	cQry := ""
	cAliasFK3 := ""
	lRet := .F.

	//BAIXAS CR
	If __oQryFK3R == Nil
		cQry := " SELECT DISTINCT FK3.R_E_C_N_O_ FK3RECNO, FK3_FILIAL, FK3_IDORIG, FK3_CLIFOR, FK3_LOJA, FK3_RECPAG, FK3_FILORI, "
		cQry += " E5_FILIAL, E5_IDORIG, E5_CLIFOR, E5_LOJA, "
		cQry += " A1_FILIAL, A1_COD, A1_LOJA, A1_CGC "		
		cQry += " FROM " + RetSqlName("SE5") + " SE5, "+ RetSqlName("FK3") + " FK3, "+ RetSqlName("SA1") + " SA1 "
		cQry += " WHERE FK3.FK3_FILIAL = ? "
		cQry += " AND FK3.FK3_CGC = ' ' "
		cQry += " AND FK3.FK3_FILIAL = SE5.E5_FILIAL "
		cQry += " AND FK3.FK3_IDORIG = SE5.E5_IDORIG "
		cQry += " AND SA1.A1_FILIAL = ? "
		cQry += " AND SA1.A1_COD = SE5.E5_CLIFOR "	
		cQry += " AND SA1.A1_LOJA = SE5.E5_LOJA "
		cQry += " AND ((SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC <> 'ES') "	
		cQry +=   " OR (SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC = 'ES') ) "
		cQry += " AND FK3.D_E_L_E_T_ = ' '"
		cQry += " AND SE5.D_E_L_E_T_ = ' '"
		cQry += " AND SA1.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK3R := FWPreparedStatement():New(cQry)
	EndIf
	
	__oQryFK3R:SetString(1, cFilAtu)
	__oQryFK3R:SetString(2, xFilial("SA1", cFilAtu))
	
	cQry := __oQryFK3R:GetFixQuery()
	cAliasFK3 := MpSysOpenQuery(cQry)
	
	DbGotop()
		
	While (cAliasFK3)->(!Eof())
		lRet	:= .T.
		
		FK3->(dbGoto( (cAliasFK3)->FK3RECNO) )
		Reclock("FK3",.F.)
		FK3->FK3_CLIFOR := (cAliasFK3)->A1_COD
		FK3->FK3_LOJA	:= (cAliasFK3)->A1_LOJA
		FK3->FK3_CGC 	:= (cAliasFK3)->A1_CGC
		FK3->FK3_RAICGC	:= Substr((cAliasFK3)->A1_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK3)->(DbSkip())
	EndDo
	
	If Select(cAliasFK3) > 0
		(cAliasFK3)->(DBCloseArea())
	EndIf

	//BAIXAS CP
	If __oQryFK3P == Nil
		cQry := " SELECT DISTINCT FK3.R_E_C_N_O_ FK3RECNO, FK3_FILIAL, FK3_IDORIG, FK3_CLIFOR, FK3_LOJA, FK3_RECPAG, FK3_FILORI, "
		cQry += " E5_FILIAL, E5_IDORIG, E5_CLIFOR, E5_LOJA, "
		cQry += " A2_FILIAL, A2_COD, A2_LOJA, A2_CGC "		
		cQry += " FROM " + RetSqlName("SE5") + " SE5, "+ RetSqlName("FK3") + " FK3, "+ RetSqlName("SA2") + " SA2 "
		cQry += " WHERE FK3.FK3_FILIAL = ? "
		cQry += " AND FK3.FK3_CGC = ' ' "
		cQry += " AND FK3.FK3_FILIAL = SE5.E5_FILIAL "
		cQry += " AND FK3.FK3_IDORIG = SE5.E5_IDORIG "
		cQry += " AND SA2.A2_FILIAL = ? "
		cQry += " AND SA2.A2_COD = SE5.E5_CLIFOR "	
		cQry += " AND SA2.A2_LOJA = SE5.E5_LOJA "
		cQry += " AND ((SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC <> 'ES') "	
		cQry +=   " OR (SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC = 'ES') ) "
		cQry += " AND FK3.D_E_L_E_T_ = ' '"
		cQry += " AND SE5.D_E_L_E_T_ = ' '"
		cQry += " AND SA2.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK3P := FWPreparedStatement():New(cQry)
	EndIf
	
	__oQryFK3P:SetString(1, cFilAtu)
	__oQryFK3P:SetString(2, xFilial("SA2", cFilAtu))
	
	cQry := __oQryFK3P:GetFixQuery()
	cAliasFK3 := MpSysOpenQuery(cQry)
	
	DbGotop()
	
	While (cAliasFK3)->(!Eof())
		lRet	:= .T.
		
		FK3->(dbGoto( (cAliasFK3)->FK3RECNO) )
		Reclock("FK3",.F.)
		FK3->FK3_CLIFOR := (cAliasFK3)->A2_COD
		FK3->FK3_LOJA	:= (cAliasFK3)->A2_LOJA
		FK3->FK3_CGC 	:= (cAliasFK3)->A2_CGC
		FK3->FK3_RAICGC	:= Substr((cAliasFK3)->A2_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK3)->(DbSkip())
	EndDo
	
	If Select(cAliasFK3) > 0
		(cAliasFK3)->(DBCloseArea())
	EndIf


	//EMISSOES CP
	If __oQryFK7P == Nil
		cQry := " SELECT DISTINCT FK3.R_E_C_N_O_ FK3RECNO, "
		cQry += " A2_COD, A2_LOJA, A2_CGC "		
		cQry += " FROM " + RetSqlName("FK7") + " FK7, "+ RetSqlName("FK3") + " FK3, "+ RetSqlName("SA2") + " SA2 "
		cQry += " WHERE FK3.FK3_FILIAL = ? "
		cQry += " AND FK3.FK3_CGC = ' ' "
		cQry += " AND FK3.FK3_FILIAL = FK7.FK7_FILIAL "
		cQry += " AND FK3.FK3_IDORIG = FK7.FK7_IDDOC "
		cQry += " AND SA2.A2_FILIAL = ? "
		cQry += " AND SA2.A2_COD = FK7.FK7_CLIFOR "	
		cQry += " AND SA2.A2_LOJA = FK7.FK7_LOJA "
		cQry += " AND FK7_ALIAS = 'SE2' "		
		cQry += " AND FK3.D_E_L_E_T_ = ' '"
		cQry += " AND FK7.D_E_L_E_T_ = ' '"
		cQry += " AND SA2.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK7P := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK7P:SetString(1, cFilAtu)
	__oQryFK7P:SetString(2, xFilial("SA2", cFilAtu))
	
	cQry := __oQryFK7P:GetFixQuery()
	cAliasFK3 := MpSysOpenQuery(cQry)
	
	DbGotop()
	
	While (cAliasFK3)->(!Eof())
		lRet	:= .T.
		
		FK3->(dbGoto( (cAliasFK3)->FK3RECNO) )
		Reclock("FK3",.F.)
		FK3->FK3_CLIFOR := (cAliasFK3)->A2_COD
		FK3->FK3_LOJA	:= (cAliasFK3)->A2_LOJA
		FK3->FK3_CGC 	:= (cAliasFK3)->A2_CGC
		FK3->FK3_RAICGC	:= Substr((cAliasFK3)->A2_CGC, 1, 8)
		MsUnlock()
		(cAliasFK3)->(DbSkip())
	EndDo

	If Select(cAliasFK3) > 0
		(cAliasFK3)->(DBCloseArea())
	EndIf

	//EMISSOES CR
	If __oQryFK7R == Nil
		cQry := " SELECT DISTINCT FK3.R_E_C_N_O_ FK3RECNO, "
		cQry += " A1_COD, A1_LOJA, A1_CGC "		
		cQry += " FROM " + RetSqlName("FK7") + " FK7, "+ RetSqlName("FK3") + " FK3, "+ RetSqlName("SA1") + " SA1 "
		cQry += " WHERE FK3.FK3_FILIAL = ? "
		cQry += " AND FK3.FK3_CGC = ' ' "
		cQry += " AND FK3.FK3_FILIAL = FK7.FK7_FILIAL "
		cQry += " AND FK3.FK3_IDORIG = FK7.FK7_IDDOC "
		cQry += " AND SA1.A1_FILIAL = ? "
		cQry += " AND SA1.A1_COD = FK7.FK7_CLIFOR "	
		cQry += " AND SA1.A1_LOJA = FK7.FK7_LOJA "
		cQry += " AND FK7_ALIAS = 'SE1' "
		cQry += " AND FK3.D_E_L_E_T_ = ' '"
		cQry += " AND FK7.D_E_L_E_T_ = ' '"
		cQry += " AND SA1.D_E_L_E_T_ = ' '"		
		cQry := ChangeQuery(cQry)
		__oQryFK7R := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK7R:SetString(1, cFilAtu)
	__oQryFK7R:SetString(2, xFilial("SA1", cFilAtu))
	
	cQry := __oQryFK7R:GetFixQuery()
	cAliasFK3 := MpSysOpenQuery(cQry)
	
	DbGotop()

	While (cAliasFK3)->(!Eof())
		lRet	:= .T.
			
		FK3->(dbGoto( (cAliasFK3)->FK3RECNO) )
		Reclock("FK3",.F.)
		FK3->FK3_CLIFOR := (cAliasFK3)->A1_COD
		FK3->FK3_LOJA	:= (cAliasFK3)->A1_LOJA
		FK3->FK3_CGC 	:= (cAliasFK3)->A1_CGC
		FK3->FK3_RAICGC	:= Substr((cAliasFK3)->A1_CGC, 1, 8)
		MsUnlock()
		
		(cAliasFK3)->(DbSkip())
	EndDo

	If Select(cAliasFK3) > 0
		(cAliasFK3)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec014
Ajusta a tabela FK2 gravando o campo FK2_IDCOMP para as compençações CP

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Fabio Casagrande Lima
@since 12/01/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec014(cEmp As Character, cFil As Character)

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnK2Comp()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("14")
    EndIf

    If __oQryFK2 != Nil
        __oQryFK2:Destroy()
        FwFreeObj(__oQryFK2)
        __oQryFK2 := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnK2Comp
Ajusta gravacao do FK2_IDCOMP para as compençações a pagar

@return lRet, Lógico indicado se a query foi executada corretamente
@author Fabio Casagrande Lima
@since 12/01/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnK2Comp() As Logical

	Local cQry1	  As Character
	Local cAlias1 As Character
	Local cSubs   As Character
	Local lRet	  As Logical
	Local lFKExc  As Logical
	Local nTamPrf As Numeric
	Local nTamNum As Numeric
	Local nTamPar As Numeric
	Local nTamTip As Numeric
	Local nTamFor As Numeric
	Local nTamLoj As Numeric
	Local nTamIdD As Numeric
	Local nTamId  As Numeric
	Local nTamDoc As Numeric
	Local nIniPrf As Numeric
	Local nIniNum As Numeric
	Local nIniPar As Numeric
	Local nIniTip As Numeric
	Local nIniFor As Numeric 
	Local nIniLoj As Numeric

	cQry1	:= ""
	cAlias1	:= ""
	cSubs   := "SUBSTRING"
	lRet	:= .F.
	lFKExc	:= FwModeAccess("FK2",3) == "E"
	nTamPrf := TamSx3("FK7_PREFIX")[1]
	nTamNum := TamSx3("FK7_NUM")[1]
	nTamPar := TamSx3("FK7_PARCEL")[1]
	nTamTip := TamSx3("FK7_TIPO")[1]
	nTamFor := TamSx3("FK7_CLIFOR")[1]
	nTamLoj := TamSx3("FK7_LOJA")[1]
	nTamIdD := TamSx3("FK7_IDDOC")[1]		
	nTamId  := TamSx3("FK2_IDCOMP")[1]
	nTamDoc := TamSx3("FK2_DOC")[1]
	nIniPrf := 1
	nIniNum := nTamPrf+1
	nIniPar := nTamPrf+nTamNum+1
	nIniTip := nTamPrf+nTamNum+nTamPar+1
	nIniFor := nTamPrf+nTamNum+nTamPar+nTamTip+1
	nIniLoj := nTamPrf+nTamNum+nTamPar+nTamTip+nTamFor+1
	
	//Query para buscar registros inconsistentes na tabela FK2
	If __oQryFK2 == Nil
		If Upper( TCGetDB() ) $ "ORACLE|POSTGRES|DB2"
			cSubs := "SUBSTR"
		EndIf
		cQry1 := " SELECT FK7_IDDOC IDCOMP, FK2.R_E_C_N_O_ RECFK2 "
		cQry1 += " FROM " + RetSqlName("FK2") + " FK2 " 
		cQry1 += " LEFT JOIN " + RetSqlName("FK7") + " FK7 ON FK7.D_E_L_E_T_ = ' ' " 
		cQry1 +=  		"AND FK7_ALIAS = 'SE2' AND FK7_NUM <> '"+Space(nTamNum)+"' "
		cQry1 +=  		"AND FK7_IDDOC <> '"+Space(nTamIdD)+"' AND "
		If lFKExc
			cQry1 +=  		"FK2_FILORI = FK7_FILIAL "
		Else
			DbSelectArea("FK2")
			cQry1 +=  		cSubs + "(FK2_FILORI,1," + Str(Len(AllTrim(FK2->FK2_FILIAL))) + ") = FK7_FILIAL "
		EndIf
		cQry1 +=  		"AND FK7_PREFIX = "+cSubs+"(FK2_DOC,"+cValtochar(nIniPrf)+","+cValtochar(nTamPrf)+") "
		cQry1 +=  		"AND FK7_NUM = "+cSubs+"(FK2_DOC,"+cValtochar(nIniNum)+","+cValtochar(nTamNum)+") "
		cQry1 +=  		"AND FK7_PARCEL = "+cSubs+"(FK2_DOC,"+cValtochar(nIniPar)+","+cValtochar(nTamPar)+") "
		cQry1 +=  		"AND FK7_TIPO = "+cSubs+"(FK2_DOC,"+cValtochar(nIniTip)+","+cValtochar(nTamTip)+") " 
		cQry1 +=  		"AND FK7_CLIFOR = "+cSubs+"(FK2_DOC,"+cValtochar(nIniFor)+","+cValtochar(nTamFor)+") " 
		cQry1 +=  		"AND FK7_LOJA = "+cSubs+"(FK2_DOC,"+cValtochar(nIniLoj)+","+cValtochar(nTamLoj)+") "
		cQry1 += " WHERE FK2.D_E_L_E_T_ = ' ' AND FK2_IDCOMP = '"+Space(nTamId)+"' "
		cQry1 +=  		"AND FK2_MOTBX = 'CMP' AND FK2_DOC <> '"+Space(nTamDoc)+"' " 

		cQry1 := ChangeQuery(cQry1)
		__oQryFK2 := FWPreparedStatement():New(cQry1)
	EndIf

	cQry1    := __oQryFK2:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	DbGotop()
		
	While (cAlias1)->(!Eof())
		lRet := .T.
		
		//Ajusta FK2_IDCOMP
		DbSelectArea("FK2")
		FK2->(dbGoto( (cAlias1)->RECFK2 ))
		Reclock("FK2",.F.)
		FK2->FK2_IDCOMP := 	(cAlias1)->IDCOMP
		MsUnlock()
		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec015
Ajusta a tabela FK2 gravando o campo FK1_IDCOMP para as compençações CR

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial
@author Fabio Casagrande Lima
@since 12/01/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec015(cEmp As Character, cFil As Character)

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnK1Comp()

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("15")
    EndIf

    If __oQryFK1 != Nil
        __oQryFK1:Destroy()
        FwFreeObj(__oQryFK1)
        __oQryFK1 := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnK1Comp
Ajusta gravacao do FK1_IDCOMP para as compençações a receber

@return lRet, Lógico indicado se a query foi executada corretamente
@author Fabio Casagrande Lima
@since 12/01/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnK1Comp() As Logical

	Local cQry1	  As Character
	Local cAlias1 As Character
	Local cSubs   As Character
	Local lRet	  As Logical
	Local lFKExc  As Logical
	Local nTamPrf As Numeric
	Local nTamNum As Numeric
	Local nTamPar As Numeric
	Local nTamTip As Numeric
	Local nTamFor As Numeric
	Local nTamLoj As Numeric
	Local nTamDoc As Numeric
	Local nTamIdD As Numeric
	Local nTamId  As Numeric
	Local nIniPrf As Numeric
	Local nIniNum As Numeric
	Local nIniPar As Numeric
	Local nIniTip As Numeric
	Local nIniLoj As Numeric

	cQry1	:= ""
	cAlias1	:= ""
	cSubs   := "SUBSTRING"
	lRet	:= .F.
	lFKExc	:= FwModeAccess("FK1", 3) == "E"
	nTamPrf := TamSx3("FK7_PREFIX")[1]
	nTamNum := TamSx3("FK7_NUM")[1]
	nTamPar := TamSx3("FK7_PARCEL")[1]
	nTamTip := TamSx3("FK7_TIPO")[1]
	nTamFor := TamSx3("FK7_CLIFOR")[1]
	nTamLoj := TamSx3("FK7_LOJA")[1]
	nTamDoc := TamSx3("FK1_DOC")[1]	
	nTamIdD := TamSx3("FK7_IDDOC")[1]	
	nTamId  := TamSx3("FK1_IDCOMP")[1]
	nIniPrf := 1
	nIniNum := nTamPrf+1
	nIniPar := nTamPrf+nTamNum+1
	nIniTip := nTamPrf+nTamNum+nTamPar+1
	nIniLoj := nTamPrf+nTamNum+nTamPar+nTamTip+1

	//Query para buscar registros inconsistentes na tabela FK1
	If __oQryFK1 == Nil
		If Upper( TCGetDB() ) $ "ORACLE|POSTGRES|DB2"
			cSubs := "SUBSTR"
		EndIf
		cQry1 := " SELECT FK7_IDDOC IDCOMP, FK1.R_E_C_N_O_ RECFK1 "
		cQry1 += " FROM " + RetSqlName("FK1") + " FK1 " 
		cQry1 += " LEFT JOIN " + RetSqlName("FK7") + " FK7 ON FK7.D_E_L_E_T_ = ' ' " 
		cQry1 +=  		"AND FK7_ALIAS = 'SE1' AND FK7_NUM <> '"+Space(nTamNum)+"' "
		cQry1 +=		"AND FK7_IDDOC <> '"+Space(nTamIdD)+"' AND "
		If lFKExc
			cQry1 +=  		"FK1_FILORI = FK7_FILIAL "
		Else
			DbSelectArea("FK1")
			cQry1 +=  		cSubs + "(FK1_FILORI,1," + Str(Len(AllTrim(FK1->FK1_FILIAL))) + ") = FK7_FILIAL "
		EndIf
		cQry1 +=		"AND FK7_PREFIX = "+cSubs+"(FK1_DOC,"+cValtochar(nIniPrf)+","+cValtochar(nTamPrf)+") "
		cQry1 +=  		"AND FK7_NUM = "+cSubs+"(FK1_DOC,"+cValtochar(nIniNum)+","+cValtochar(nTamNum)+") "
		cQry1 +=  		"AND FK7_PARCEL = "+cSubs+"(FK1_DOC,"+cValtochar(nIniPar)+","+cValtochar(nTamPar)+") "
		cQry1 +=  		"AND FK7_TIPO = "+cSubs+"(FK1_DOC,"+cValtochar(nIniTip)+","+cValtochar(nTamTip)+") " 
		cQry1 +=  		"AND FK7_LOJA = "+cSubs+"(FK1_DOC,"+cValtochar(nIniLoj)+","+cValtochar(nTamLoj)+") "
		cQry1 += " WHERE FK1.D_E_L_E_T_ = ' ' AND FK1_IDCOMP = '"+Space(nTamId)+"' "
		cQry1 +=  		"AND FK1_MOTBX = 'CMP' AND FK1_DOC <> '"+Space(nTamDoc)+"' " 

		cQry1 := ChangeQuery(cQry1)
		__oQryFK1 := FWPreparedStatement():New(cQry1)
	EndIf

	cQry1    := __oQryFK1:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	DbGotop()
		
	While (cAlias1)->(!Eof())
		lRet := .T.

		//Ajusta FK1_IDCOMP
		DbSelectArea("FK1")
		FK1->(dbGoto( (cAlias1)->RECFK1 ))
		Reclock("FK1",.F.,,,.T.)
		FK1->FK1_IDCOMP := 	(cAlias1)->IDCOMP
		MsUnlock()
		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec016
Ajusta a tabela FK5 gravando o campo FK5_IDDOC para os movimentos das RAs

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial

@author Mauricio Pequim Jr
@since 09/02/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec016(cEmp As Character, cFil As Character)

	Local lRet		As Logical
    Local cMVFinFix As Character
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp := cEmp
	cBkpFil	:= cFil
	cCodFil	:= ""
	lRet	:= .T.
    cMVFinFix := GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero

	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf

		cCodFil := Padr(cCodFil, Len(FK5->FK5_FILIAL))

		lRet := FnK5MovRa(cCodFil)
		
		If !lRet		
			Exit
		EndIf
			
		SM0->(DbSkip())
		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	EndDo
	SM0->(dbGoto(nRecSM0))

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("16")
    EndIf

    If __oQryFK5 != Nil
        __oQryFK5:Destroy()
        FwFreeObj(__oQryFK5)
        __oQryFK5 := Nil
    EndIf

    If __oQryFK5R != Nil
        __oQryFK5R:Destroy()
        FwFreeObj(__oQryFK5R)
        __oQryFK5R := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnK5MovRa
Ajusta gravacao do FK5_IDDOC para os movimentos de RA

@return lRet, Lógico indicado se a query foi executada corretamente

@author Mauricio Pequim Jr
@since 08/02/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnK5MovRa(cFilAtu As Character) As Logical

	Local cQry1	  As Character
	Local cQry2	  As Character
	Local cAlias1 As Character
	Local nTamIdD As Numeric
	Local cChaveFK7 As Character

	cQry1	:= ""
	cQry2	:= ""
	cAlias1	:= ""
	lRet	:= .F.
	nTamIdD := TamSx3("FK7_IDDOC")[1]	

	//Query para buscar registros inconsistentes na tabela FK5 - Movimentos de RA sem FK5_IDDOC preenchido e SEM registro na FK7
	If __oQryFK5 == Nil
		cQry1 := " SELECT FK5.R_E_C_N_O_ RECFK5, "
		cQry1 += " SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA "
		cQry1 += " FROM " + RetSqlName("FK5") + " FK5 " 
		cQry1 += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON SE5.D_E_L_E_T_ = ' ' " 
		cQry1 += 		"AND SE5.E5_IDORIG = FK5.FK5_IDMOV "
		cQry1 += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' " 
		cQry1 +=  		"AND SE1.E1_FILIAL = ?  "		
		cQry1 +=  		"AND SE1.E1_PREFIXO = SE5.E5_PREFIXO  "
		cQry1 +=  		"AND SE1.E1_NUM = SE5.E5_NUMERO "
		cQry1 +=  		"AND SE1.E1_PARCELA = SE5.E5_PARCELA "
		cQry1 +=  		"AND SE1.E1_TIPO = SE5.E5_TIPO " 
		cQry1 +=  		"AND SE1.E1_CLIENTE = SE5.E5_CLIFOR " 		
		cQry1 +=  		"AND SE1.E1_LOJA = SE5.E5_LOJA "
		cQry1 += " WHERE FK5.D_E_L_E_T_ = ' ' 
		cQry1 +=  		"AND FK5_TPDOC = 'RA ' "
		cQry1 +=  		"AND FK5_IDDOC = '" + Space(nTamIdD) + "' " 
		cQry1 += 		"AND NOT EXISTS( "
		cQry1 += 			"SELECT 1 FROM  " + RetSqlName("FK7") + " FK7 "
		cQry1 += 			"WHERE FK7_FILTIT = ?  "
		cQry1 += 				"AND FK7_ALIAS = 'SE1' "
		cQry1 +=  				"AND FK7_PREFIX = SE5.E5_PREFIXO  "
		cQry1 +=		  		"AND FK7_NUM = SE5.E5_NUMERO "
		cQry1 +=  				"AND FK7_PARCEL = SE5.E5_PARCELA "
		cQry1 +=  				"AND FK7_TIPO = SE5.E5_TIPO " 
		cQry1 +=  				"AND FK7_CLIFOR = SE5.E5_CLIFOR " 		
		cQry1 +=  				"AND FK7_LOJA = SE5.E5_LOJA "
		cQry1 +=  				"AND FK7.D_E_L_E_T_ = ' ' )"

		cQry1 := ChangeQuery(cQry1)
		__oQryFK5 := FWPreparedStatement():New(cQry1)
	EndIf

	__oQryFK5:SetString(1, xFilial("SE1", cFilAtu))
	__oQryFK5:SetString(2, xFilial("FK7", cFilAtu))

	cQry1    := __oQryFK5:GetFixQuery()
	cAlias1 := MpSysOpenQuery(cQry1)
	
	(cAlias1)->(DbGotop())
		
	While (cAlias1)->(!Eof())
		lRet := .T.

		//Dados da tabela auxiliar com o código do título RA
		cChaveTit := (cAlias1)->E1_FILIAL + "|" + (cAlias1)->E1_PREFIXO + "|" + (cAlias1)->E1_NUM   + "|" + (cAlias1)->E1_PARCELA + "|" + ;
					 (cAlias1)->E1_TIPO   + "|" + (cAlias1)->E1_CLIENTE + "|" + (cAlias1)->E1_LOJA
		cChaveFK7 := FINGRVFK7( "SE1", cChaveTit )

		//Ajusta FK5_IDDOC
		DbSelectArea("FK5")
		FK5->(dbGoto( (cAlias1)->RECFK5 ))
		Reclock("FK5",.F.,,,.T.)
		FK5->FK5_IDDOC := cChaveFK7
		MsUnlock()
		(cAlias1)->(DbSkip())
	EndDo

	If Select(cAlias1) > 0
		(cAlias1)->(DBCloseArea())
	EndIf

	//Query para buscar registros inconsistentes na tabela FK5 - Movimentos de RA sem FK5_IDDOC preenchido e MAS com registro na FK7
	If lRet
		If __oQryFK5R == Nil
			lRet := .F.
			cQry2 := " SELECT FK5.R_E_C_N_O_ RECFK5, FK7.FK7_IDDOC IDDOC "
			cQry2 += " ,FK7.FK7_FILTIT, FK7.FK7_PREFIX, FK7.FK7_NUM, FK7.FK7_PARCEL, FK7.FK7_TIPO, FK7.FK7_CLIFOR, FK7.FK7_LOJA "
			cQry2 += " FROM " + RetSqlName("FK5") + " FK5 " 
			cQry2 += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON SE5.D_E_L_E_T_ = ' ' " 
			cQry2 += 		"AND SE5.E5_IDORIG = FK5.FK5_IDMOV "
			cQry2 += " INNER JOIN " + RetSqlName("FK7") + " FK7 ON FK7.D_E_L_E_T_ = ' ' " 
			cQry2 +=  		"AND FK7.FK7_FILTIT = ?  "		
			cQry2 +=  		"AND FK7.FK7_PREFIX = SE5.E5_PREFIXO  "
			cQry2 +=  		"AND FK7.FK7_NUM = SE5.E5_NUMERO "
			cQry2 +=  		"AND FK7.FK7_PARCEL = SE5.E5_PARCELA "
			cQry2 +=  		"AND FK7.FK7_TIPO = SE5.E5_TIPO " 
			cQry2 +=  		"AND FK7.FK7_CLIFOR = SE5.E5_CLIFOR " 		
			cQry2 +=  		"AND FK7.FK7_LOJA = SE5.E5_LOJA "
			cQry2 += " WHERE FK5.D_E_L_E_T_ = ' ' AND FK5_TPDOC = 'RA ' "
			cQry2 +=  		"AND FK5_IDDOC = '" + Space(nTamIdD) + "' " 

			cQry2 := ChangeQuery(cQry2)
			__oQryFK5R := FWPreparedStatement():New(cQry2)
		EndIf

		__oQryFK5R:SetString(1, xFilial("FK7", cFilAtu))

		cQry2    := __oQryFK5R:GetFixQuery()
		cAlias1 := MpSysOpenQuery(cQry2)
		
		(cAlias1)->(DbGotop())
			
		While (cAlias1)->(!Eof())
			lRet := .T.

			//Ajusta FK5_IDDOC
			DbSelectArea("FK5")
			FK5->(dbGoto( (cAlias1)->RECFK5 ))
			Reclock("FK5",.F.,,,.T.)
			FK5->FK5_IDDOC := (cAlias1)->IDDOC
			MsUnlock()
			(cAlias1)->(DbSkip())
		EndDo

		If Select(cAlias1) > 0
			(cAlias1)->(DBCloseArea())
		EndIf
	Endif

Return(lRet)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec021
Migração dos registros da tabela SE5 gerados pela rotina FINA470 ainda 
usado na versão 12.1.17

@author Mauricio Pequim Jr
@since 02/02/2022
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec021(cEmp As Character, cFil As Character)

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FinExec470(cEmp, cFil) 

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("21")
    Endif

    If __oQrySE5 != Nil
        __oQrySE5:Destroy()
        FwFreeObj(__oQrySE5)
        __oQrySE5 := Nil
    EndIf

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec470
Migração dos registros da tabela SE5 gerados pela rotina FINA470 ainda usado na versão 12.1.17

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial

@author Pâmela Bernardo
@since 02/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec470(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp := cEmp
	cBkpFil	:= cFil
	cCodFil	:= ""
	lRet	:= .T.
  
	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf

		cCodFil := Padr(cCodFil, Len(FK5->FK5_FILIAL))

		lRet := FnSE5Mov(cCodFil)
		
		If !lRet		
			Exit
		EndIf
		SM0->(DbSkip())
		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	EndDo
	SM0->(dbGoto(nRecSM0))

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnSE5Mov
Busca os dados da SE5 sem migração e chama migrador FINXSE5

@return lRet, Lógico indicado se a migração foi executada corretamente

@author Pâmela Bernardo
@since 02/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnSE5Mov(cFilAtu As Character) As Logical

	Local cQry	  	As Character
	Local cAliasE5 	As Character
	Local lRet  	As Logical

	cQry		:= ""
	cAliasE5	:= ""
	lRet		:= .F.

	//Query para buscar registros inconsistentes na tabela SE5 - Movimentos Gerados pela rotina FINA470 sem migração
	If __oQrySE5 == Nil
		cQry := " SELECT SE5.R_E_C_N_O_ RECSE5 "
		cQry += " FROM " + RetSqlName("SE5") + " SE5 " 
		cQry += " WHERE SE5.E5_FILIAL = ? "
		cQry += " AND SE5.E5_IDORIG = '  ' "
		cQry += " AND SE5.E5_TIPODOC = '  ' "
		cQry += " AND SE5.E5_MOVFKS = ' ' 
		cQry += " AND SE5.E5_TABORI = '  ' "
		cQry += " AND SE5.E5_MOEDA IN ('C1', 'M1') "
		cQry += " AND SE5.E5_SITUACA = ' ' "
		cQry += " AND SE5.E5_ORIGEM = ' ' "
		cQry += " AND SE5.D_E_L_E_T_ = ' '  "
		cQry := ChangeQuery(cQry)
		__oQrySE5 := FWPreparedStatement():New(cQry)
	EndIf

	__oQrySE5:SetString(1, xFilial("SE5", cFilAtu))
	
	cQry    := __oQrySE5:GetFixQuery()
	cAliasE5 := MpSysOpenQuery(cQry)
	
	(cAliasE5)->(DbGotop())
		
	While (cAliasE5)->(!Eof())
		lRet := .T.

		//Efetuar a chamada da SE5
		FINXSE5((cAliasE5)->(RECSE5), 1)
		(cAliasE5)->(DbSkip())
	EndDo

	If Select(cAliasE5) > 0
		(cAliasE5)->(DBCloseArea())
	EndIf

Return(lRet)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec017
Deleção dos registros da tabela FK2 referente ao movimento bancário da PA, gerado pelos fontes
FINA090, FINA091, FINXSE5
Ajuste da tabela FKA/SE5 para migrar o registros para tabelas:
Se for inclusão movimento bancário direto: retirar vinculo com a FK2 e refazer com a tabela FK5
Se for inclusão movimento bancário via cheque: retirar vinculo com a FK2 e refazer com a tabela SE2

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial

@author Pâmela Bernardo
@since 23/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec017(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
	Local cMVFinFix As Character
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp 	:= cEmp
	cBkpFil		:= cFil
	cCodFil		:= ""
	lRet		:= .T.
	cMVFinFix 	:= GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	cLayOut 	:= ""
	nRecSM0		:= 0
  

	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf

		cCodFil := Padr(cCodFil, Len(FK5->FK5_FILIAL))

		lRet := FnSE5GERPA(cCodFil)
		
		If !lRet		
			Exit
		EndIf
		SM0->(DbSkip())
		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	EndDo
	SM0->(dbGoto(nRecSM0))

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("17")
    EndIf

    If __oQryGPA != Nil
        __oQryGPA:Destroy()
        FwFreeObj(__oQryGPA)
        __oQryGPA := Nil
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnSE5GERPA
Busca dos dados de PA vinculados a FK2, e efetua os ajustes

@return lRet, Lógico indicado se o ajuste foi executada corretamente

@author Pâmela Bernardo
@since 23/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnSE5GERPA(cFilAtu As Character) As Logical

	Local cQry	  	As Character
	Local cIdProc  	As Character
	Local cIdMov  	As Character
	Local cAliasPA 	As Character
	Local lRet  	As Logical
	Local nRecnoFKA As Numeric
	Local lDelFKA	As Logical

	cQry		:= ""
	cIdMov		:= ""
	cAliasPA	:= ""
	lRet		:= .F.
	nRecnoFKA	:= 0
	cIdProc		:= ""
	lDelFKA		:= .F.

	//Query para buscar registros inconsistentes na tabela SE5 - Movimentos Gerados pela rotina FINA470 sem migração
	If __oQryGPA == Nil
		cQry := "SELECT FK2.R_E_C_N_O_ FK2RECNO, SE5.R_E_C_N_O_ SE5RECNO "
		cQry += " FROM " + RetSqlName("FK2") + " FK2 " 
		cQry += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON " 
		cQry += " SE5.E5_FILIAL = FK2.FK2_FILIAL "  
		cQry += " AND SE5.E5_IDORIG = FK2.FK2_IDFK2 "
		cQry += " AND SE5.E5_TABORI = 'FK2' "
		cQry += " AND SE5.E5_TIPO = 'PA ' "
		cQry += " AND SE5.E5_SITUACA <> 'C ' "
		cQry += " AND SE5.D_E_L_E_T_ = ' ' "
		cQry += " WHERE " 
		cQry += " FK2.FK2_FILIAL = ? " 
		cQry += " AND FK2.FK2_RECPAG = 'P'  " 
		cQry += " AND FK2.FK2_MOTBX <>'CMP' " 
		cQry += " AND FK2.FK2_TPDOC <> 'ES' " 
		cQry += " AND FK2.D_E_L_E_T_ =' '  " 
		cQry := ChangeQuery(cQry)
		__oQryGPA := FWPreparedStatement():New(cQry)
	EndIf

	__oQryGPA:SetString(1, xFilial("FK2", cFilAtu))
	
	cQry    := __oQryGPA:GetFixQuery()
	cAliasPA := MpSysOpenQuery(cQry)
	
	
	(cAliasPA)->(DbGotop())
	DbSelectArea("FK2")
	DbSelectArea("FKA")
	FKA->(dbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
	DbSelectArea("SE5")
	DbSelectArea("FK5")

	While (cAliasPA)->(!Eof())
		lRet := .T.

		FK2->(dbGoto( (cAliasPA)->FK2RECNO ))
		SE5->(dbGoto( (cAliasPA)->SE5RECNO))
		nRecnoFKA:= 0
		lDelFKA := .F.
		cIdProc := ""
		If FKA->( dbSeek( xFilial("FKA", cFilAtu) +"FK2" + FK2->FK2_IDFK2 ))
			nRecnoFKA := FKA->(Recno())
			If FK2->FK2_TPDOC = 'PA' //Indica movimento direto
				cIdMov := FnFK5GERPA(FKA->FKA_IDPROC)
				If !Empty(cIdMov) .and.  FK5->( dbSeek( xFilial("FK5", cFilAtu) + cIdMov ))
					Reclock("FK5",.F.)
						FK5->FK5_IDDOC := FK2->FK2_IDDOC
					FK5->(MsUnlock())

					Reclock("SE5",.F.)
						SE5->E5_IDORIG := FK5->FK5_IDMOV
						SE5->E5_TABORI := "FK5"
					SE5->(MsUnlock())
				EndIf
			Else
				Reclock("SE5",.F.)
					SE5->E5_IDORIG := FK2->FK2_IDDOC
					SE5->E5_TABORI := "SE2"
				SE5->(MsUnlock())
			EndIf
			
			If nRecnoFKA>0
				cIdProc:= FKA->FKA_IDPROC
				If FKA->( dbSeek( xFilial("FKA", cFilAtu) +"SE2" + FK2->FK2_IDDOC )) .AND. cIdProc == FKA->FKA_IDPROC //Já existe processo 
					lDelFKA:= .T.
				EndIf
				
				FKA->(dbGoto(nRecnoFKA))
				If lDelFKA
					//Deleção da FKA relacionada a FK2
					Reclock("FKA",.F.)
						FKA->(dbDelete())
					FKA->(MsUnlock())
				Else
					Reclock("FKA",.F.)
						FKA->FKA_IDORIG := FK2->FK2_IDDOC
						FKA->FKA_TABORI := "SE2"
					FKA->(MsUnlock())
				EndIf
			EndIf

			//Deleção da FK2
			Reclock("FK2",.F.)
				FK2->(dbDelete())
			FK2->(MsUnlock())
		EndIf 
		(cAliasPA)->(DbSkip())
	EndDo

	If Select(cAliasPA) > 0
		(cAliasPA)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnFK5GERPA
Função para buscar ID de movimento FK5

@return Id de movimento bancário (FK5_IDMOV)

@author Pâmela Bernardo
@since 23/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnFK5GERPA(cProcesso As Character) As Character
	Local cIdMov As Character
	Local aAreaFKA As Array
	
	cIdMov := ""
	aAreaFKA := FKA->(GetArea())

	FKA->(DbSetOrder(2)) //FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
	FKA->(DbGotop())
	FKA->(DbSeek(xFilial("FKA")+cProcesso))

	While FKA->(!Eof()) .And. FKA->FKA_IDPROC == cProcesso
		If FKA->FKA_TABORI = "FK5"
			cIdMov := FKA->FKA_IDORIG
			Exit
		EndIf
		FKA->(DbSkip())
	EndDo

	RestArea(aAreaFKA)
Return cIdMov

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec018
Deleção dos registros da tabela FK5 referente a registros v2 ligados ao movimento
bancário da baixa de um título (FINA070) de cobrança descontada.

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial

@author Mauricio Pequim Jr
@since 31/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec018(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
	Local cMVFinFix As Character
	Local cSitDsc	As Character
	Local cSitAtcpa As Character
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp 	:= cEmp
	cBkpFil		:= cFil
	cCodFil		:= ""
	lRet		:= .T.
	cMVFinFix 	:= GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	cLayOut 	:= ""
	nRecSM0		:= 0
	cSitDsc		:= ""
	cSitAtcpa	:= ""
  
	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
		
		If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
			SM0->(DbSkip())
			Loop
		EndIf 
		
		If cModoSE5 $ "EEC/ECC"
			cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
		ElseIf cModoSE5 $ "EEE"
			cCodFil	:= SM0->M0_CODFIL
		EndIf

		cCodFil := Padr(cCodFil, Len(FK5->FK5_FILIAL))

		//Obtenho a lista das situacoes de cobranca com desconto
		cSitDsc		:= FN022LSTCB(2) 
		cSitAtcpa	:= GETMV("MV_CARTECF",.T., "")

		If !Empty(cSitAtcpa) .and. cSitAtcpa $ cSitDsc
			cSitAtcpa	:= "|" + cSitAtcpa
			cSitDsc		:= STRTRAN(cSitDsc, cSitAtcpa, "")
		EndIf

		__aSitDsc := Strtokarr2( cSitDsc, "|", .F.)

		lRet := FnFK5DESC(cCodFil)
		
		If !lRet		
			Exit
		EndIf
		SM0->(DbSkip())

		If ( cModoSE5 == "CCC" )
			Exit
		EndIf
	EndDo
	SM0->(dbGoto(nRecSM0))

    //Ajusta o parâmetro de controle - NOVO
    If !Empty(cMVFinFix)
        AtuMvFix("18")
    EndIf

    If __oQryFK5DC != Nil
        __oQryFK5DC:Destroy()
        FwFreeObj(__oQryFK5DC)
        __oQryFK5DC := Nil
    EndIf

	If __aSitDsc != NIL
		FwFreeArray(__aSitDsc)
		__aSitDsc := NIL
	EndIF
		
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnFK5DESC
Busca dos dados de baixa de título em cobrança descontadaPA vinculados a FK2, e efetua os ajustes

@return lRet, Lógico indicado se o ajuste foi executada corretamente

@author Mauricio Pequim Jr
@since 31/03/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnFK5DESC(cFilAtu As Character) As Logical

	Local cQry	  	As Character
	Local cAliasFK5	As Character
	Local lRet  	As Logical

	cQry		:= ""
	cAliasFK5	:= ""
	lRet		:= .F.

	//Query para buscar registros inconsistentes na tabela SE5 - Movimentos Gerados pela rotina FINA470 sem migração
	If __oQryFK5DC == Nil
		cQry := "SELECT FK5.R_E_C_N_O_ FK5RECNO,FKA.R_E_C_N_O_ FKARECNO  "
		cQry += " FROM " + RetSqlName("FK5") + " FK5 " 

		cQry += " INNER JOIN " + RetSqlName("FKA") + " FKA ON " 
		cQry += " FKA.FKA_FILIAL = FK5.FK5_FILIAL "  
		cQry += " AND FKA.FKA_IDORIG = FK5.FK5_IDMOV "
		cQry += " AND FKA.FKA_TABORI = 'FK5' "

		cQry += " INNER JOIN " + RetSqlName("FKA") + " FKA1 ON " 
		cQry += " FKA1.FKA_FILIAL = FKA.FKA_FILIAL "
		cQry += " AND FKA1.FKA_IDPROC = FKA.FKA_IDPROC "

		cQry += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON " 
		cQry += " SE5.E5_FILIAL = FKA1.FKA_FILIAL "
		cQry += " AND SE5.E5_IDORIG = FKA1.FKA_IDORIG "
		cQry += " AND FKA1.FKA_TABORI = 'FK1' "
		cQry += " AND SE5.E5_SITCOB IN (?) " 

		cQry += " WHERE " 
		cQry += " FK5.FK5_FILIAL = ? " 
		cQry += " AND FK5.FK5_RECPAG = 'R'  " 
		cQry += " AND FK5.FK5_TPDOC = 'V2' " 
		cQry += " AND FK5.FK5_ORIGEM = 'FINA070' " 
		cQry += " AND FK5.D_E_L_E_T_ =' '  " 

		cQry := ChangeQuery(cQry)

		__oQryFK5DC := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK5DC:SetIN(1, __aSitDsc )
	__oQryFK5DC:SetString(2, xFilial("FK5", cFilAtu))

	cQry    := __oQryFK5DC:GetFixQuery()
	cAliasFK5 := MpSysOpenQuery(cQry)
		
	(cAliasFK5)->(DbGotop())
	DbSelectArea("FKA")
	FKA->(dbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
	DbSelectArea("FK5")

	While (cAliasFK5)->(!Eof())
		lRet := .T.

		//Deleção da FKA relacionada a FK1 - V2
		FKA->(dbGoto( (cAliasFK5)->FKARECNO ))
		Reclock("FKA",.F.)
		FKA->(dbDelete())
		FKA->(MsUnlock())

		//Deleção da FK2
		FK5->(dbGoto( (cAliasFK5)->FK5RECNO))
		Reclock("FK5",.F.)
		FK5->(dbDelete())
		FK5->(MsUnlock())

		(cAliasFK5)->(DbSkip())
	EndDo

	If Select(cAliasFK5) > 0
		(cAliasFK5)->(DBCloseArea())
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec019
Adiciona a gravação dos campos FK3_CODRET/FK4_CODRET

@param cEmp, characters, código da empresa 
@param cFil, characters, código da filial

@author Pâmela Bernardo
@since 12/04/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec019(cEmp As Character, cFil As Character)

	Local lRet		As Logical
	Local cBkpEmp	As Character
	Local cBkpFil	As Character
	Local cModoSE5	As Character
	Local cLayOut	As Character
	Local cCodFil	As Character
	Local nRecSM0 	As Numeric
	Local cMVFinFix As Character
	Local lFKCodRet As Character
	
	cModoSE5	:= FWModeAccess("SE5",1)+FWModeAccess("SE5",2)+FWModeAccess("SE5",3)
	
	cBkpEmp 	:= cEmp
	cBkpFil		:= cFil
	cCodFil		:= ""
	lRet		:= .T.
	cMVFinFix 	:= GetMV("MV_FINFIX")       //Verifico se tenho o novo parâmetero
	cLayOut 	:= ""
	nRecSM0		:= 0
	lFKCodRet	:= (cPaisLoc == "BRA" .and. FK3->(FieldPos("FK3_CODRET")) > 0 .and. FK4->(FieldPos("FK4_CODRET")) > 0)
  

	If cModoSE5 == "EEC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
	ElseIf cModoSE5 == "ECC"
		cLayOut := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
	EndIf

	nRecSM0	:= SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGotop())
	SM0->(DbSeek(cEmp))

	If lFKCodRet
		While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmp
			
			If cModoSE5 $ "EEC/ECC" .And. SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout)) == SUBSTR(cCodFil, 1,VAL(cLayout))
				SM0->(DbSkip())
				Loop
			EndIf 
			
			If cModoSE5 $ "EEC/ECC"
				cCodFil	:= SUBSTR(SM0->M0_CODFIL, 1,VAL(cLayout))
			ElseIf cModoSE5 $ "EEE"
				cCodFil	:= SM0->M0_CODFIL
			EndIf

			cCodFil := Padr(cCodFil, Len(FK5->FK5_FILIAL))

			lRet := FnCodRet(cCodFil)
			
			If !lRet		
				Exit
			EndIf
			SM0->(DbSkip())
			If ( cModoSE5 == "CCC" )
				Exit
			EndIf
		EndDo
		SM0->(dbGoto(nRecSM0))

		//Ajusta o parâmetro de controle - NOVO
		If !Empty(cMVFinFix)
			AtuMvFix("19")
		EndIf
	EndIf

    If __oQryFK3A != Nil
        __oQryFK3A:Destroy()
        FwFreeObj(__oQryFK3A)
        __oQryFK3A := Nil
    EndIf

    If __oQryFK4A != Nil
        __oQryFK4A:Destroy()
        FwFreeObj(__oQryFK4A)
        __oQryFK4A := Nil
    EndIf

	If __oQryFK3B != Nil
        __oQryFK3B:Destroy()
        FwFreeObj(__oQryFK3B)
        __oQryFK3B := Nil
    EndIf

    If __oQryFK4B != Nil
        __oQryFK4B:Destroy()
        FwFreeObj(__oQryFK4B)
        __oQryFK4B := Nil
    EndIf

	If __oQryFK3M != Nil
        __oQryFK3M:Destroy()
        FwFreeObj(__oQryFK3M)
        __oQryFK3M := Nil
    EndIf

    If __oQryFK4M != Nil
        __oQryFK4M:Destroy()
        FwFreeObj(__oQryFK4M)
        __oQryFK4M := Nil
    EndIf


Return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnCodRet
Busca dos dados de impostos calculados e retidos que não possuem os campos FK3_CODRET e FK4_CODRET em branco
e preencher os campos.

@return lRet, Lógico indicado se o ajuste foi executada corretamente

@author Pâmela Bernardo
@since 14/04/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnCodRet(cFilAtu As Character) As Logical

	Local cQry	  		As Character
	Local cAliasFK3A 	As Character
	Local cAliasFK3B 	As Character
	Local cAliasFK4A 	As Character
	Local cAliasFK4B 	As Character
	Local cCodret 		As Character
	Local lRet  		As Logical
	Local aCodRet		As Array
	Local nRecSE2		As Numeric
	Local cAliasFK3M 	As Character
	Local cAliasFK4M 	As Character

	cQry		:= ""
	cAliasFK3A	:= ""
	cAliasFK3B	:= ""
	cAliasFK4A	:= ""
	cAliasFK4B	:= ""
	lRet		:= .F.
	cCodret		:= ""
	aCodRet		:= {}
	nRecSE2		:= 0
	cAliasFK3M	:= ""
	cAliasFK4M	:= ""

	DbSelectArea("SE2")
	DbSelectArea("FK3")
	DbSelectArea("FK4")

	//Query de títulos baixados e inclusão de PA com retenção
	If __oQryFK3A == Nil
		cQry := "select SE2.R_E_C_N_O_ SE2RECNO, FK3.R_E_C_N_O_ FK3RECNO  "
		cQry += " FROM " + RetSqlName("SE2") + " SE2 " 

		cQry += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON " 
		cQry += " SE5.E5_FILIAL = ? AND "  
		cQry += " SE2.E2_PREFIXO = SE5.E5_PREFIXO AND "
		cQry += " SE2.E2_NUM = SE5.E5_NUMERO AND "
		cQry += " SE2.E2_PARCELA = SE5.E5_PARCELA AND "
		cQry += " SE2.E2_TIPO = SE5.E5_TIPO AND "
		cQry += " SE2.E2_FORNECE = SE5.E5_CLIFOR AND "
		cQry += " SE2.E2_LOJA = SE5.E5_LOJA AND "
		cQry += " SE5.D_E_L_E_T_ = ' '  "
		
		cQry += " INNER JOIN " + RetSqlName("FK3") + " FK3 ON " 
		cQry += " SE5.E5_IDORIG = FK3.FK3_IDORIG AND "
		cQry += " FK3.FK3_CODFKM = ' '  AND "
		cQry += " FK3.FK3_CODRET = ' '  AND "
		cQry += " FK3.D_E_L_E_T_ = ' '  "

		cQry += " WHERE " 
		cQry += " SE2.E2_FILIAL = ? " 
		cQry += " AND SE2.D_E_L_E_T_ =' '  " 

		cQry := ChangeQuery(cQry)

		__oQryFK3A := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK3A:SetString(1, xFilial("SE5", cFilAtu) )
	__oQryFK3A:SetString(2, xFilial("SE2", cFilAtu))

	cQry    := __oQryFK3A:GetFixQuery()
	cAliasFK3A := MpSysOpenQuery(cQry)
		
	(cAliasFK3A)->(DbGotop())
	While (cAliasFK3A)->(!Eof())
		lRet := .T.

		cCodret := ""
		If nRecSE2 <> (cAliasFK3A)->SE2RECNO
			nRecSE2 := (cAliasFK3A)->SE2RECNO
			SE2->(dbGoto( (cAliasFK3A)->SE2RECNO ))
			aCodRet := getCodRet()
		EndIf 
		FK3->(dbGoto( (cAliasFK3A)->FK3RECNO ))

		Do Case
			Case alltrim(FK3->FK3_IMPOS) == "IRF"
				cCodret := SE2->E2_CODRET
			Case alltrim(FK3->FK3_IMPOS) == "PIS"
				cCodret := aCodRet[1]
			Case alltrim(FK3->FK3_IMPOS) == "COF"
				cCodret := aCodRet[2]
			Case alltrim(FK3->FK3_IMPOS) == "CSL"
				cCodret := aCodRet[3]
		Endcase
	
		Reclock("FK3",.F.)
			FK3->FK3_CODRET := cCodret
		FK3->(MsUnlock())
		(cAliasFK3A)->(DbSkip())
	EndDo

	If Select(cAliasFK3A) > 0
		(cAliasFK3A)->(DBCloseArea())
	EndIf

	//Query de títulos baixados e inclusão de PA com retenção
	If __oQryFK4A == Nil
		lRet	:= .F.
		cQry := "select SE2.R_E_C_N_O_ SE2RECNO, FK4.R_E_C_N_O_ FK4RECNO   "
		cQry += " FROM " + RetSqlName("SE2") + " SE2 " 

		cQry += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON " 
		cQry += " SE5.E5_FILIAL = ? AND "  
		cQry += " SE2.E2_PREFIXO = SE5.E5_PREFIXO AND "
		cQry += " SE2.E2_NUM = SE5.E5_NUMERO AND "
		cQry += " SE2.E2_PARCELA = SE5.E5_PARCELA AND "
		cQry += " SE2.E2_TIPO = SE5.E5_TIPO AND "
		cQry += " SE2.E2_FORNECE = SE5.E5_CLIFOR AND "
		cQry += " SE2.E2_LOJA = SE5.E5_LOJA AND "
		cQry += " SE5.D_E_L_E_T_ = ' '  "
		
		cQry += " INNER JOIN " + RetSqlName("FK4") + " FK4 ON " 
		cQry += " SE5.E5_IDORIG = FK4.FK4_IDORIG AND "
		cQry += " FK4.FK4_CODFKM = ' '  AND "
		cQry += " FK4.FK4_CODRET = ' '  AND "
		cQry += " FK4.D_E_L_E_T_ = ' '  "

		cQry += " WHERE " 
		cQry += " SE2.E2_FILIAL = ? " 
		cQry += " AND SE2.D_E_L_E_T_ =' '  " 

		cQry := ChangeQuery(cQry)

		__oQryFK4A := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK4A:SetString(1, xFilial("SE5", cFilAtu) )
	__oQryFK4A:SetString(2, xFilial("SE2", cFilAtu))

	cQry    := __oQryFK4A:GetFixQuery()
	cAliasFK4A := MpSysOpenQuery(cQry)
		
	(cAliasFK4A)->(DbGotop())
	While (cAliasFK4A)->(!Eof())
		lRet := .T.
		cCodret := ""
		If nRecSE2 <> (cAliasFK4A)->SE2RECNO
			nRecSE2 := (cAliasFK4A)->SE2RECNO
			SE2->(dbGoto( (cAliasFK4A)->SE2RECNO ))
			aCodRet := getCodRet()
		EndIf 
		FK4->(dbGoto( (cAliasFK4A)->FK4RECNO ))

		Do Case
			Case alltrim(FK4->FK4_IMPOS) == "IRF"
				cCodret := SE2->E2_CODRET
			Case alltrim(FK4->FK4_IMPOS) == "PIS"
				cCodret := aCodRet[1]
			Case alltrim(FK4->FK4_IMPOS) == "COF"
				cCodret := aCodRet[2]
			Case alltrim(FK4->FK4_IMPOS) == "CSL"
				cCodret := aCodRet[3]
		Endcase
	
		Reclock("FK4",.F.)
			FK4->FK4_CODRET := cCodret
		FK4->(MsUnlock())
		(cAliasFK4A)->(DbSkip())
	EndDo

	If Select(cAliasFK4A) > 0
		(cAliasFK4A)->(DBCloseArea())
	EndIf

	//QUERY DE TÍTULOS INCLUSOS VIA BORDERÔ/INCLUSÃO DE PA/IRRF NA EMISSÃO
	If __oQryFK3B == Nil
		cQry := "select SE2.R_E_C_N_O_ SE2RECNO, FK3.R_E_C_N_O_ FK3RECNO  "
		cQry += " FROM " + RetSqlName("SE2") + " SE2 " 

		cQry += " INNER JOIN " + RetSqlName("FK7") + " FK7 ON " 
		cQry += " SE2.E2_FILIAL = FK7.FK7_FILTIT AND"
		cQry += " SE2.E2_PREFIXO = FK7.FK7_PREFIX AND"
		cQry += " SE2.E2_NUM = FK7.FK7_NUM AND"
		cQry += " SE2.E2_PARCELA = FK7.FK7_PARCEL AND"
		cQry += " SE2.E2_TIPO = FK7.FK7_TIPO AND"
		cQry += " SE2.E2_FORNECE = FK7.FK7_CLIFOR AND"
		cQry += " SE2.E2_LOJA = FK7.FK7_LOJA AND "
		cQry += " FK7.D_E_L_E_T_ = ' ' "

		cQry += " INNER JOIN " + RetSqlName("FK3") + " FK3 ON " 
		cQry += " FK7.FK7_IDDOC = FK3.FK3_IDORIG AND "
		cQry += " FK3.FK3_CODFKM = ' '  AND "
		cQry += " FK3.FK3_CODRET = ' '  AND "
		cQry += " FK3.D_E_L_E_T_ = ' '  "

		cQry += " WHERE " 
		cQry += " SE2.E2_FILIAL = ? " 
		cQry += " AND SE2.D_E_L_E_T_ =' '  " 

		cQry := ChangeQuery(cQry)
		__oQryFK3B := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK3B:SetString(1, xFilial("SE2", cFilAtu) )
	
	cQry    := __oQryFK3B:GetFixQuery()
	cAliasFK3B := MpSysOpenQuery(cQry)
			
	(cAliasFK3B)->(DbGotop())

	While (cAliasFK3B)->(!Eof())
		lRet := .T.

		cCodret := ""
		If nRecSE2 <> (cAliasFK3B)->SE2RECNO
			nRecSE2 := (cAliasFK3B)->SE2RECNO
			SE2->(dbGoto( (cAliasFK3B)->SE2RECNO ))
			aCodRet := getCodRet()
		EndIf 
		FK3->(dbGoto( (cAliasFK3B)->FK3RECNO ))

		Do Case
			Case alltrim(FK3->FK3_IMPOS) == "IRF"
				cCodret := SE2->E2_CODRET
			Case alltrim(FK3->FK3_IMPOS) == "PIS"
				cCodret := aCodRet[1]
			Case alltrim(FK3->FK3_IMPOS) == "COF"
				cCodret := aCodRet[2]
			Case alltrim(FK3->FK3_IMPOS) == "CSL"
				cCodret := aCodRet[3]
		Endcase
	
		Reclock("FK3",.F.)
			FK3->FK3_CODRET := cCodret
		FK3->(MsUnlock())
		(cAliasFK3B)->(DbSkip())
	EndDo

	If Select(cAliasFK3B) > 0
		(cAliasFK3B)->(DBCloseArea())
	EndIf
	
	//QUERY DE TÍTULOS INCLUSOS VIA BORDERÔ/INCLUSÃO DE PA/IRRF NA EMISSÃO
	If __oQryFK4B == Nil
		cQry := "select SE2.R_E_C_N_O_ SE2RECNO, FK4.R_E_C_N_O_ FK4RECNO  "
		cQry += " FROM " + RetSqlName("SE2") + " SE2 " 

		cQry += " INNER JOIN " + RetSqlName("FK7") + " FK7 ON " 
		cQry += " SE2.E2_FILIAL = FK7.FK7_FILTIT AND"
		cQry += " SE2.E2_PREFIXO = FK7.FK7_PREFIX AND"
		cQry += " SE2.E2_NUM = FK7.FK7_NUM AND"
		cQry += " SE2.E2_PARCELA = FK7.FK7_PARCEL AND"
		cQry += " SE2.E2_TIPO = FK7.FK7_TIPO AND"
		cQry += " SE2.E2_FORNECE = FK7.FK7_CLIFOR AND"
		cQry += " SE2.E2_LOJA = FK7.FK7_LOJA AND "
		cQry += " FK7.D_E_L_E_T_ = ' ' "

		cQry += " INNER JOIN " + RetSqlName("FK4") + " FK4 ON " 
		cQry += " FK7.FK7_IDDOC = FK4.FK4_IDORIG AND "
		cQry += " FK4.FK4_CODFKM = ' '  AND "
		cQry += " FK4.FK4_CODRET = ' '  AND "
		cQry += " FK4.D_E_L_E_T_ = ' '  "

		cQry += " WHERE " 
		cQry += " SE2.E2_FILIAL = ? " 
		cQry += " AND SE2.D_E_L_E_T_ =' '  " 

		cQry := ChangeQuery(cQry)
		__oQryFK4B := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK4B:SetString(1, xFilial("SE2", cFilAtu) )
	
	cQry    := __oQryFK4B:GetFixQuery()
	cAliasFK4B := MpSysOpenQuery(cQry)
			
	(cAliasFK4B)->(DbGotop())

	While (cAliasFK4B)->(!Eof())
		lRet := .T.
		cCodret := ""
		If nRecSE2 <> (cAliasFK4B)->SE2RECNO
			nRecSE2 := (cAliasFK4B)->SE2RECNO
			SE2->(dbGoto( (cAliasFK4B)->SE2RECNO ))
			aCodRet := getCodRet()
		EndIf 
		FK4->(dbGoto( (cAliasFK4B)->FK4RECNO ))

		Do Case
			Case alltrim(FK4->FK4_IMPOS) == "IRF"
				cCodret := SE2->E2_CODRET
			Case alltrim(FK4->FK4_IMPOS) == "PIS"
				cCodret := aCodRet[1]
			Case alltrim(FK4->FK4_IMPOS) == "COF"
				cCodret := aCodRet[2]
			Case alltrim(FK4->FK4_IMPOS) == "CSL"
				cCodret := aCodRet[3]
		Endcase
	
		Reclock("FK4",.F.)
			FK4->FK4_CODRET := cCodret
		FK4->(MsUnlock())
		(cAliasFK4B)->(DbSkip())
	EndDo

	If Select(cAliasFK4B) > 0
		(cAliasFK4B)->(DBCloseArea())
	EndIf

	//MOTOR DE RETENÇÃO
	If __oQryFK3M == Nil
		cQry := "select FK3.R_E_C_N_O_ FK3RECNO, FKK.FKK_CODRET  "
		cQry += " FROM " + RetSqlName("FK3") + " FK3 " 

		cQry += " INNER JOIN " + RetSqlName("FKK") + " FKK ON " 
		cQry += " FK3.FK3_CODFKM = FKK.FKK_CODIGO AND "
		cQry += " FKK.FKK_CODRET <> ' '  AND "
		cQry += " FKK.D_E_L_E_T_ = ' ' "

		cQry += " WHERE " 
		cQry += " FK3.FK3_FILIAL = ? AND " 
		cQry += " FK3.FK3_CODRET = ' '  AND "
		cQry += " FK3.D_E_L_E_T_ = ' '  " 

		cQry := ChangeQuery(cQry)
		__oQryFK3M := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK3M:SetString(1, xFilial("FK3", cFilAtu) )
	
	cQry    := __oQryFK3M:GetFixQuery()
	cAliasFK3M := MpSysOpenQuery(cQry)
			
	(cAliasFK3M)->(DbGotop())

	While (cAliasFK3M)->(!Eof())
		lRet := .T.

		FK3->(dbGoto( (cAliasFK3M)->FK3RECNO ))
		Reclock("FK3",.F.)
			FK3->FK3_CODRET := (cAliasFK3M)->FKK_CODRET
		FK3->(MsUnlock())
		(cAliasFK3M)->(DbSkip())
	EndDo

	If Select(cAliasFK3M) > 0
		(cAliasFK3M)->(DBCloseArea())
	EndIf
	
	//MOTOR DE RETENÇÃO
	If __oQryFK4M == Nil
		cQry := "select FK4.R_E_C_N_O_ FK4RECNO, FKK.FKK_CODRET  "
		cQry += " FROM " + RetSqlName("FK4") + " FK4 " 

		cQry += " INNER JOIN " + RetSqlName("FKK") + " FKK ON " 
		cQry += " FK4.FK4_CODFKM = FKK.FKK_CODIGO AND "
		cQry += " FKK.FKK_CODRET <> ' '  AND "
		cQry += " FKK.D_E_L_E_T_ = ' ' "

		cQry += " WHERE " 
		cQry += " FK4.FK4_FILIAL = ? AND " 
		cQry += " FK4.FK4_CODRET = ' '  AND "
		cQry += " FK4.D_E_L_E_T_ = ' '  " 

		cQry := ChangeQuery(cQry)
		__oQryFK4M := FWPreparedStatement():New(cQry)
	EndIf

	__oQryFK4M:SetString(1, xFilial("FK4", cFilAtu) )
	
	cQry    := __oQryFK4M:GetFixQuery()
	cAliasFK4M := MpSysOpenQuery(cQry)
			
	(cAliasFK4M)->(DbGotop())

	While (cAliasFK4M)->(!Eof())
		lRet := .T.

		FK4->(dbGoto( (cAliasFK4M)->FK4RECNO ))
		Reclock("FK4",.F.)
			FK4->FK4_CODRET := (cAliasFK4M)->FKK_CODRET
		FK4->(MsUnlock())
		(cAliasFK4M)->(DbSkip())
	EndDo

	If Select(cAliasFK4M) > 0
		(cAliasFK4M)->(DBCloseArea())
	EndIf

Return(lRet)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinExec020
Ajuste para preenchimento dos campos FK2_DTDIGI e FK2_DTDISP

@author Mauricio Pequim Jr
@since 13/04/2021
@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FinExec020()

	Local lRet		As Logical
    Local cMVFinFix As Character

    cMVFinFix := GetMV("MV_FINFIX")  
	
	lRet := FnFK2DTDIG()

    //Ajusta o parâmetro de controle - NOVO
	If !Empty(cMVFinFix)
        AtuMvFix("20")
    EndIf

    If __oQryK2DtDig != Nil
        __oQryK2DtDig:Destroy()
        FwFreeObj(__oQryK2DtDig)
        __oQryK2DtDig := Nil
    EndIf


Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FnFK2DTDIG
Rotina de preenchimento dos campos FK2_DTDIGI e FK2_DTDISP

@author Mauricio Pequim Jr
@since 13/04/2021

@version P12
/*/
//-------------------------------------------------------------------------------
Static Function FnFK2DTDIG()

	Local cQry 		As Character
	Local cAliasFK2	As Character
	Local lRet	    As Logical

	cQry		:= ""
	cAliasFK2	:= ""
	lRet		:= .F.

	If __oQryK2DtDig == Nil
	
		cQry := " SELECT DISTINCT(FK2.R_E_C_N_O_) RECFK2, SE5.R_E_C_N_O_ RECSE5, SE5.E5_DTDISPO DTDISP, SE5.E5_DTDIGIT DTDIGI "
		cQry += " FROM " + RetSqlName("FK2") + " FK2 "
		cQry += " JOIN " + RetSqlName("SE5") + " SE5 "
		cQry += " ON E5_FILIAL = FK2_FILIAL "
		cQry += " AND E5_TABORI = 'FK2' "
		cQry += " AND E5_IDORIG = FK2_IDFK2 "
		cQry += " AND SE5.D_E_L_E_T_ = ' ' "
		cQry += " WHERE FK2_DTDIGI = ' ' "
		cQry += " AND FK2.D_E_L_E_T_ = ' ' "
		cQry := ChangeQuery(cQry)

		__oQryK2DtDig := FWPreparedStatement():New(cQry)
	EndIf
	
	cQry 		:= __oQryK2DtDig:GetFixQuery()
	cAliasFK2 	:= MpSysOpenQuery(cQry)
	
	(cAliasFK2)->(DbGotop())
	
	While (cAliasFK2)->(!Eof())
		lRet	:= .T.

		FK2->(dbGoto( (cAliasFK2)->RECFK2) )
			
		Reclock("FK2")
		FK2->FK2_DTDIGI := STOD((cAliasFK2)->DTDIGI)
		FK2->FK2_DTDISP := STOD((cAliasFK2)->DTDISP)
		MsUnlock()

		(cAliasFK2)->(DbSkip())
	
	EndDo
	
	If Select(cAliasFK2) > 0
		(cAliasFK2)->(DBCloseArea())
	EndIf

Return lRet
