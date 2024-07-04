#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "GPEM923.CH"

/*/{Protheus.doc} function GPEM923
Serviço automático de envio de dados para integração com NG
@author  Hugo de Oliveira
@since   14/04/2020
@version 1.0
/*/
Function GPEM923(aParam)

	Local aRJP		:= {}
	Local aInputs	:= {}

	DEFAULT aParam 	:= {}

	conout(STR0001) // "Processamento do JOB iniciado!"

	If LEN(aParam) == 4
		aInputs := {"","",aParam[1],aParam[2],aParam[3],aParam[4]}
	Else
		aInputs := aParam
	EndIf

	RpcSetType(3)
	RPCsetEnv(aInputs[3], aInputs[4]) // Abertura do Ambiente

	// Verifica se a rotina está sendo executada e realiza o Lock
	If LockByName("GPEM923" + aInputs[3] + aInputs[4], .T., .T., .T.)

		aRJP := fGetRJP(aInputs) // Selecão dos dados com base nos filtros e suas regras

		If !Empty(aRJP)
			fSendData(aRJP) // Chamada da API que envia os dados de Origem
		Else
			ConOut(STR0005) // "Nao foram encontrados registros na tabela RJP."
		EndIf

		// Libera a rotina após finalizar a execução das Threads
		UnLockByName("GPEM923" + cEmpAnt + cFilAnt, .T., .T., .T.)
	Else
		conout(STR0002) // "A rotina 'GPEM923' está sendo executada por outro processo"
	EndIf

	RpcClearEnv()

	conout(STR0004) // "Processamento do JOB Finalizado!"
Return

/*/{Protheus.doc} function fGetRJP
Função para buscar os dados de acordo com o filtro do JOB
@author  Hugo de Oliveira
@since   14/04/2020
@version 1.0
/*/
Static Function fGetRJP(aParam)
	Local aData 	:= {}
	Local cMat		:= ""
	Local cFilTab	:= ""
	Local nRecno    := 0
	Local cTab 		:= ""
	Local cKey 		:= ""
	Local cOper		:= ""
	Local dDt		:= ""
	Local cHora		:= ""
	Local cUser		:= ""
	Local cRTN 		:= ""
	Local cDtIn		:= ""
	Local cHoraIn	:= ""
	Local cCorte	:= ""
	Local cQuery	:= ""
	Local cAlias	:= "RJP"
	Local cAliasRJP := GetNextAlias()

	ConOut(STR0006) // "Buscando dados na tabela RJP de acordo com os parametros informados..."

	// Montagem da consulta
	cQuery := " SELECT * FROM " + RetSqlName(cAlias)
	cQuery += " WHERE RJP_DTIN = ' ' " // Filtra todos os registro que ainda não foram integrados
	cQuery += " AND " + RetSqlName(cAlias) + ".D_E_L_E_T_ = ' ' "

	// Se a Filial for informada
	If !Empty(aParam[4])
		cQuery += " AND ( RJP_FILIAL = '" + xFilial('RJP', aParam[4]) + "' OR RJP_FILIAL = ' ' ) "
	EndIf

	// Se a Competência for informada
	If !Empty(aParam[1])
		cQuery += " AND RJP_DATA = '" + aParam[1] + "' "
	EndIf

	// Se os dias de corte forem informados
	If !Empty(aParam[2]) .AND. aParam[2] != "0" .AND. Empty(aParam[1])
		cCorte 		:=	DATE() - VAL(ALLTRIM(aParam[2]))
		cCorte 		:= cValToChar(YEAR(cCorte)) + SUBSTR(cValToChar(cCorte),4,2) + SUBSTR(cValToChar(cCorte),0,2)
		cQuery 		+= " AND RJP_DATA >= '" + cCorte + "' "
	EndIf

	cQuery += " ORDER BY RJP_TAB, R_E_C_N_O_ "

	// Executa a consulta
	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasRJP, .T., .T. )

	While (cAliasRJP)->(!Eof())
		If (cAliasRJP)->RJP_FIL ==  xFilial(ALLTRIM((cAliasRJP)->RJP_TAB), aParam[4]) .or. empty((cAliasRJP)->RJP_FIL) .Or. ((cAliasRJP)->RJP_TAB == "SRE" .And. (cAliasRJP)->RJP_FIL ==  xFilial("SRA", aParam[4]))

			cMat	:= (cAliasRJP)->RJP_MAT
			cTab 	:= ALLTRIM((cAliasRJP)->RJP_TAB)
			cFilTab := (cAliasRJP)->RJP_FIL
			cKey 	:= ALLTRIM((cAliasRJP)->RJP_KEY)
			cOper	:= ALLTRIM((cAliasRJP)->RJP_OPER)
			dDt		:= ALLTRIM((cAliasRJP)->RJP_DATA)
			cHora	:= ALLTRIM((cAliasRJP)->RJP_HORA)
			cUser	:= ALLTRIM((cAliasRJP)->RJP_USER)
			cDtIn	:= ALLTRIM((cAliasRJP)->RJP_DTIN)
			cHoraIn	:= ALLTRIM((cAliasRJP)->RJP_HORAIN)
			nRecno	:= (cAliasRJP)->R_E_C_N_O_

			Aadd(aData, {cMat, cTab, cKey, cOper, dDt, cHora, cUser, cRTN, cDtIn, cHoraIn, nRecno, cFilTab})
		EndIf
		(cAliasRJP)->(dbSkip())

	EndDo

Return aData

/*/{Protheus.doc} function fSendData
Função para buscar os dados das tabelas origem, de acordo com a tabela de transações
@author  Hugo de Oliveira
@since   17/04/2020
@version 1.0
/*/
Static Function fSendData(aRJP)
	Local nX		:= 1
	Local aSR7Data  := {}
	Local aSRAData	:= {}
	Local aSRBData  := {}
	Local aSREData  := {}
	Local aRA4Data  := {}
	Local aRD0Data  := {}
	Local aSQBData	:= {}
	Local aSQ3Data	:= {}

	Local cTable 	:= ""
	Local lRet		:= .T.

	ConOut(STR0007) // "Processando dados encontrados na tabela RJP..."

	For nX := 1 TO LEN(aRJP)

		// Inicializa variáveis
		cTable		:= ALLTRIM(aRJP[nX][2])

		If cTable == "RD0" // Pessoas
			fGetRD0(aRJP[nX],@aRD0Data)

		ElseIf cTable == "SRA" // Funcionários
			fGetSRA(aRJP[nX],@aSRAData)

		ElseIf cTable == "SR7" // Historico Funcional - Alterações Salariais
			fGetSR7(aRJP[nX],@aSR7Data)

		ElseIf cTable == "SRB" // Dependentes
			fGetSRB(aRJP[nX],@aSRBData)

		ElseIf cTable == "SRE" // Histórico Funcional - Transferências
			fGetSRE(aRJP[nX],@aSREData)

		ElseIf cTable == "RA4" // Treinamentos
			fGetRA4(aRJP[nX],@aRA4Data)

		ElseIf cTable == "SQB" // Departamentos
			fGetSQB(aRJP[nX],@aSQBData)

		ElseIf cTable == "SQ3" // Cargos
			fGetSQ3(aRJP[nX],@aSQ3Data)
		EndIf
	Next nX

	If !Empty(aRD0Data)
		GPESAPIRD0(aRD0Data) // person - Envia Pessoas
	EndIf

	If !Empty(aSRAData)
		GPESAPISRA(aSRAData) // employee - Envia Funcionários
	EndIf

	If !Empty(aRA4Data)
		GPESAPIRA4(aRA4Data) // trainingHistory - Envia Treinamentos
	EndIf

	If !Empty(aSRBData)
		GPESAPISRB(aSRBData) // dependant - Envia Dependentes
	EndIf

	If !Empty(aSR7Data)
		GPESAPISR7(aSR7Data) // functionalhistory - Envia Histórico Funcional - Alterações Salariais
	EndIf

	If !Empty(aSREData)
		GPESAPISR7(aSREData) // functionalhistory - Envia Histórico Funcional - Transferências
	EndIf

	If !Empty(aSQBData)
		GPESAPISQB(aSQBData) // Departament - Envia Departamento
	EndIf

	If !Empty(aSQ3Data)
		GPESAPISQ3(aSQ3Data) // position - Envia Cargos
	EndIf

Return lRet

/*/{Protheus.doc} function fGetSQ3
Retorna os dados da tabela SQ3 que serão enviados para a API.
@author  Wesley Alves Pereira
@since   24/08/2020
@version 1.0
/*/
Static Function fGetSQ3(aRjpInfor,aData)

	Local cmyAlias  := "SQ3"
	Local aKey      := {}
	Local cFil      := ""
	Local cMat      := ""
	Local cCar      := ""
	Local cDes      := ""
	Local cCus      := ""
	Local cDescDet	:= ""

	DEFAULT aData   := {}
	DEFAULT	aRjpInfor := {}

	aKey := StrTokArr( aRjpInfor[3], "|")

	If len(aKey) == 3
		aAdd(aKey,"")
	EndIf

	If aRjpInfor[4] == "E"

		Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
						aRjpInfor[11],; // 02 - RECNO
						aRjpInfor[3],; 	// 03 - idProtheus
						aKey[1],;	   	// 04 - erpCompany
						aKey[2],;	   	// 05 - erpBranch
						cMat,;	       	// 06 - erpEmployee
						cCar,;		   	// 07 - id
						cDes,;		   	// 08 - description
						cCus,;			// 09 - costcenter
						cDescDet})		// 10 - observation   	

	Else

		DbSelectArea(cmyAlias)
		(cmyAlias)->(DbSetOrder(1)) //Q3_FILIAL+Q3_CARGO+Q3_CC
		If DbSeek(aKey[2] + aKey[3] + aKey[4])

			cFil := (cmyAlias)->Q3_FILIAL
			cMat := ""
			cCar := (cmyAlias)->Q3_CARGO
			cDes := (cmyAlias)->Q3_DESCSUM
			cCus := (cmyAlias)->Q3_CC
			cDescDet := fSubstRH(AllTrim(MSMM((cmyAlias)->Q3_DESCDET)))

			Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
							aRjpInfor[11],; // 02 - RECNO
							aRjpInfor[3],; 	// 03 - idProtheus
							aKey[1],;	   	// 04 - erpCompany
							aKey[2],;	   	// 05 - erpBranch
							cMat,;	       	// 06 - erpEmployee
							cCar,;		   	// 07 - id
							cDes,;		   	// 08 - description
							cCus,;			// 09 - costcenter
							cDescDet})		// 10 - observation

		EndIf

	EndIf

Return (.T.)

/*/{Protheus.doc} function fGetSQB
Retorna os dados da tabela SQB que serão enviados para a API.
@author  Gisele Nuncherino
@since   18/08/2020
@version 1.0
/*/
Static Function fGetSQB(aRjpInfor,aData)

	Local cmyAlias  := "SQB"
	Local aKey      := {}
	Local cOperac	:= ''

	DEFAULT aData   	:= {}
	DEFAULT	aRjpInfor 	:= {}

	cOperac	:= aRjpInfor[4]

	aKey := StrTokArr( aRjpInfor[3], "|")

	If !(cOperac == "E") // Não é exclusão

		DbSelectArea(cmyAlias)
		(cmyAlias)->(DbSetOrder(3)) // QB_FILIAL+QB_DEPTO+QB_CC
		If DbSeek(aKey[2] + aKey[3] + iif(len(akey) > 3, aKey[4], ''))

			Aadd(aData, { 	aRjpInfor[4],;  					// 01 - Operação
							aRjpInfor[11],; 					// 02 - RECNO
							aRjpInfor[3],; 						// 03 - id
							aKey[1],;	   						// 04 - erpCompany
							aKey[2],;	   						// 05 - erpBranch
							(cmyAlias)->QB_DESCRIC	})			// 06 - description
		EndIf
	Else
		// Na exclusão monta array com valores DEFAULT
		Aadd(aData, { aRjpInfor[4],;	// 01 - Operação
		aRjpInfor[11],; 			 	// 02 - Recno RJP
		aRjpInfor[3],; 			 		// 03 - id
		aKey[1],;				 		// 04 - erpCompany
		aKey[2],;	 					// 05 - erpBranch
		''})		 					// 06 - description
	EndIf

Return (.T.)

/*/{Protheus.doc} function fGetSR7
Retorna os dados da tabela SR7 que serão enviados para a API.
@author  Wesley Alves Pereira
@since   24/04/2020
@version 1.0
/*/
Static Function fGetSR7(aRjpInfor,aData)
	Local cmyAlias  := "SR7"
	Local aKey      := {}
	Local cFil      := ""
	Local cMat      := ""
	Local cDat      := ""
	Local cCCu      := ""
	Local cDCu      := ""
	Local cCDe      := ""
	Local cDDe      := ""
	Local cCFu      := ""
	Local cDFu      := ""
	Local cCCa      := ""
	Local cDCa      := ""
	Local cCef      := ""

	DEFAULT aData   := {}
	DEFAULT	aRjpInfor := {}

	aKey := StrTokArr2( aRjpInfor[3], "|",.T.)

	DbSelectArea(cmyAlias)
	(cmyAlias)->(DbSetOrder(2)) // R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ+R7_TIPO
	If DbSeek(aKey[2] + aKey[3] + aKey[4] + aKey[5] + aKey[6])

		cFil      := (cmyAlias)->R7_FILIAL
		cMat      := (cmyAlias)->R7_MAT
		cDat      := DTOS((cmyAlias)->R7_DATA)
		cCFu      := aKey[1] + "|" + xFilial("SRJ", cFil) + "|" + (cmyAlias)->R7_FUNCAO
		cDFu      := (cmyAlias)->R7_DESCFUN
		cCCa      := If(!Empty((cmyAlias)->R7_CARGO), aKey[1] + "|" + xFilial("SQ3", cFil) + "|" + (cmyAlias)->R7_CARGO, (cmyAlias)->R7_CARGO)
		cDCa      := (cmyAlias)->R7_DESCCAR

		DbSelectArea("SRA")
		DbSelectArea("CTT")
		DbSelectArea("SQB")

		cCCu      := POSICIONE("SRA",1,aKey[2]+cMat,"RA_CC")
		cDCu      := Alltrim(POSICIONE("CTT",1,xFilial("CTT")+cCCu,"CTT_DESC01"))
		cCCu      := aKey[1] + "|" + xFilial("CTT", aKey[2]) + "|" + POSICIONE("SRA",1,aKey[2]+cMat,"RA_CC")
		cCDe      := POSICIONE("SRA",1,aKey[2]+cMat,"RA_DEPTO")
		cDDe      := Alltrim(POSICIONE("SQB",1,xFilial("SQB")+cCDe,"QB_DESCRIC"))
		cCDe      := If(!Empty(cCDe), aKey[1] + "|" + xFilial("SQB", aKey[2]) + "|" + cCDe, cCDe)
		cCef      := POSICIONE("SRA",1,aKey[2]+cMat,"RA_CATEG")

		Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
						aRjpInfor[11],; // 02 - RECNO
						aRjpInfor[3],; 	// 03 - id
						aKey[1],;	   	// 04 - erpCompany
						aKey[2],;	   	// 05 - erpBranch
						cMat,;	       	// 06 - erpEmployee
						cDat,;		   	// 07 - occurenceDate
						cCCu,;		   	// 08 - erpCostCenter
						cDCu,;		   	// 09 - costCenterDescription
						cCDe,;		   	// 10 - erpDepartment
						cDDe,;			// 11 - departmentDescription
						cCFu,;			// 12 - erpOccupation
						cDFu,;			// 13 - occupationDescription
						cCCa,;			// 14 - erpEmployeePosition
						cDCa,;			// 15 - employeePositionDescription
						cCef})			// 16 - sefipCategory
		EndIf

Return (.T.)

/*/{Protheus.doc} function fGetSRA
Retorna os dados da tabela SRA que serão enviados para a API.
@author  martins.marcio
@since   24/04/2020
@version 1.0
/*/
Static Function fGetSRA(aRjpSRA,aData)

	Local cSRA		 := "SRA"
	Local cErpEmp	 := ""
	Local cErpFil	 := ""
	Local cMatFun	 := ""
	Local cOperac	 := ""
	Local cDescTurn	 := ""
	Local cCCDesc	 := ""
	Local cFuncaoDes := ""
	Local cDeptoDesc := ""
	Local cDescSum	 := ""
	Local cCCKey	 := ""
	Local cFuncKey	 := ""
	Local cDeptoKey	 := ""
	Local cCargoKey	 := ""

	DEFAULT aData	:= {}
	DEFAULT	aRjpSRA := {}

	aKey := StrTokArr( aRjpSRA[3], "|")
	cErpEmp := aKey[1]
	cErpFil := aKey[2]
	cMatFun	:= aRjpSRA[1]
	cOperac	:= aRjpSRA[4]

	If !(cOperac == "E") // Não é exclusão

		DbSelectArea(cSRA)
		(cSRA)->(DbSetOrder(1)) // RA_FILIAL+RA_MAT+RA_NOME
		If DbSeek(cErpFil + AllTrim(cMatFun))

			cDescTurn	:= Posicione("SR6",1,XFILIAL("SR6",cErpFil)+(cSRA)->RA_TNOTRAB,"R6_DESC")
			cCCKey		:= cErpEmp + "|" + xFilial("CTT", cErpFil) + "|" + (cSRA)->RA_CC
			cCCDesc		:= Posicione("CTT",1,XFILIAL("CTT",cErpFil)+(cSRA)->RA_CC,"CTT_DESC01")
			cFuncKey	:= cErpEmp + "|" + xFilial("SRJ", cErpFil) + "|" + (cSRA)->RA_CODFUNC
			cFuncaoDes	:= Posicione("SRJ",1,XFILIAL("SRJ",cErpFil)+(cSRA)->RA_CODFUNC,"RJ_DESC")
			cDeptoKey	:= If(!Empty((cSRA)->RA_DEPTO), cErpEmp + "|" + xFilial("SQB", cErpFil) + "|" + (cSRA)->RA_DEPTO, (cSRA)->RA_DEPTO)
			cDeptoDesc	:= Posicione("SQB",1,XFILIAL("SQB",cErpFil)+(cSRA)->RA_DEPTO,"QB_DESCRIC")
			cCargoKey	:= If(!Empty((cSRA)->RA_CARGO), cErpEmp + "|" + xFilial("SQ3", cErpFil) + "|" + (cSRA)->RA_CARGO + "|" + Posicione("SQ3", 1, xFilial("SQ3", cErpFil) + (cSRA)->RA_CARGO, "Q3_CC"), (cSRA)->RA_CARGO)
			cDescSum	:= Posicione("SQ3",1,XFILIAL("SQ3",cErpFil)+(cSRA)->RA_CARGO,"Q3_DESCSUM")



			Aadd(aData, { aRjpSRA[4],;	// 01 - Operação
			aRjpSRA[11],; 			 	// 02 - Recno RJP
			aRjpSRA[3],; 			 	// 03 - id
			cErpEmp,;				 	// 04 - erpCompany
			(cSRA)->RA_FILIAL,;	 		// 05 - erpBranch
			(cSRA)->RA_MAT,;		 	// 06 - registration
			(cSRA)->RA_NOMECMP,;	 	// 07 - name
			(cSRA)->RA_NASC,;		 	// 08 - birth
			(cSRA)->RA_CIC,;		 	// 09 - cpf
			(cSRA)->RA_SEXO,;		 	// 10 - gender
			(cSRA)->RA_RG,;	     		// 11 - rg
			(cSRA)->RA_EMAIL,;		 	// 12 - email
			(cSRA)->RA_TNOTRAB,;	 	// 13 - erpWorkShift
			cCCKey,;		 			// 14 - erpCostCenter
			cFuncKey,;				 	// 15 - erpOccupation
			cDeptoKey,;				 	// 16 - erpDepartment
			(cSRA)->RA_ENDEREC,;	 	// 17 - street
			(cSRA)->RA_NUMENDE,;	 	// 18 - number
			(cSRA)->RA_BAIRRO,;	 		// 19 - district
			(cSRA)->RA_MUNICIP,;	 	// 20 - city
			(cSRA)->RA_CEP,;		 	// 21 - zipCode
			{(cSRA)->RA_DDDFONE,(cSRA)->RA_TELEFON},; 	// 22 - phone
			(cSRA)->RA_SITFOLH,;	 	// 23 - situation
			(cSRA)->RA_CATEFD,;	 		// 24 - eSocialRoleId
			(cSRA)->RA_ADMISSA,;	 	// 25 - admissionDate
			(cSRA)->RA_DEMISSA,;		// 26 - dismissalDate
			(cSRA)->RA_PIS,;		 	// 27 - pisCode
			(cSRA)->RA_CODUNIC,;	 	// 28 - eSocialId
			(cSRA)->RA_CATEG,;	 		// 29 - sefipCategory
			fSubstRH(cDescTurn),;		// 30 - workshiftDescription
			cCCDesc,;	 				// 31 - costCenterDescription
			cFuncaoDes,;	 			// 32 - occupationDescription
			cDeptoDesc,;	 			// 33 - departmentDescription
			(cSRA)->RA_MAE,;			// 34 - mothersName
			(cSRA)->RA_ESTCIVI,;		// 35 - civilStatus
			(cSRA)->RA_NUMCP,;			// 36 - ctps
			(cSRA)->RA_GRINRAI,;		// 37 - educationLevel
			(cSRA)->RA_ESTADO,;			// 38 - state
			(cSRA)->RA_VIEMRAI,;		// 39 - rais
			(cSRA)->RA_CATEFD,; 		// 40 - eSocialCategory
			cCargoKey,;					// 41 - position
			cDescSum,;					// 42 - positionDescription
			IIf(AT("1",(cSRA)->RA_PORTDEF) > 0 , "S" ,"N") ,; // 43 - defFisica
			IIf(AT("3",(cSRA)->RA_PORTDEF) > 0 , "S" ,"N") ,; // 44 - defVisual
			IIf(AT("2",(cSRA)->RA_PORTDEF) > 0 , "S" ,"N") ,; // 45 - defAuditiva
			IIf(AT("4",(cSRA)->RA_PORTDEF) > 0 , "S" ,"N") ,; // 46 - defMental
			IIf(AT("5",(cSRA)->RA_PORTDEF) > 0 , "S" ,"N") ,; // 47 - defIntelectual
			IIf(AT("6",(cSRA)->RA_PORTDEF) > 0 , "S" ,"N") }) // 48 - reabReadap

		EndIf
	Else
		// Na exclusão monta array com valores DEFAULT
		Aadd(aData, { aRjpSRA[4],;	// 01 - Operação
		aRjpSRA[11],; 			 	// 02 - Recno RJP
		aRjpSRA[3],; 			 	// 03 - id
		cErpEmp,;				 	// 04 - erpCompany
		cErpFil,;	 				// 05 - erpBranch
		cMatFun,;		 			// 06 - registration
		"",;						// 07 - name
		STOD(""),;		 			// 08 - birth
		"",;		 				// 09 - cpf
		"",;		 				// 10 - gender
		"",;	     				// 11 - rg
		"",;		 				// 12 - email
		"",;	 					// 13 - erpWorkShift
		"",;		 				// 14 - erpCostCenter
		"",;	 					// 15 - erpOccupation
		"",;		 				// 16 - erpDepartment
		"",;	 					// 17 - street
		"",;	 					// 18 - number
		"",;	 					// 19 - district
		"",;	 					// 20 - city
		"",;		 				// 21 - zipCode
		{"",""},;	 				// 22 - phone
		"",;	 					// 23 - situation
		"",;	 					// 24 - eSocialRoleId
		STOD(""),;	 				// 25 - admissionDate
		STOD(""),;					// 26 - dismissalDate
		"",;		 				// 27 - pisCode
		"",;	 					// 28 - eSocialId
		"",;	 					// 29 - sefipCategory
		"",;						// 30 - workshiftDescription
		"",;						// 31 - costCenterDescription
		"",;						// 32 - occupationDescription
		"",;						// 33 - departmentDescription
		"",;						// 34 - mothersName
		"",;						// 35 - civilStatus
		"",;						// 36 - ctps
		"",;						// 37 - educationLevel
		"",;						// 38 - state
		"",;						// 39 - rais
		"",; 						// 40 - eSocialCategory
		"",;						// 41 - position
		"",;						// 42 - positionDescription
		"",;						// 43 - defFisica
		"",;						// 44 - defVisual
		"",;						// 45 - defAuditiva
		"",;						// 46 - defMental
		"",;						// 47 - defIntelectual
		"" })						// 48 - reabReadap

	EndIf

Return (.T.)


/*/{Protheus.doc} function fGetSRB
Retorna os dados da tabela SRB que serão enviados para a API.
@author  Wesley Alves Pereira
@since   23/04/2020
@version 1.0
/*/
Static Function fGetSRB(aRjpInfor,aData)

	Local cmyAlias  := "SRB"
	Local aKey      := {}
	Local cFil      := ""
	Local cMat      := ""
	Local cSeq      := ""
	Local cNom      := ""
	Local cNas      := ""
	Local cDoc      := ""
	Local nSex      := 1

	DEFAULT aData   := {}
	DEFAULT	aRjpInfor := {}

	aKey := StrTokArr( aRjpInfor[3], "|")

	If aRjpInfor[4] == "E"

		Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
						aRjpInfor[11],; // 02 - RECNO
						aRjpInfor[3],; 	// 03 - id
						aKey[1],;	   	// 04 - erpCompany
						aKey[2],;	   	// 05 - erpBranch
						cMat,;	       	// 06 - erpEmployee
						cNom,;		   	// 07 - name
						cNas,;		   	// 08 - birth
						cDoc,;		   	// 09 - cpf
						nSex})		   	// 10 - gender

	Else

	DbSelectArea(cmyAlias)
	(cmyAlias)->(DbSetOrder(1)) // RB_FILIAL+RB_MAT+RB_COD
	If DbSeek(aKey[2] + aKey[3] + aKey[4])


		cFil := (cmyAlias)->RB_FILIAL
		cMat := aKey[1] + "|" + aKey[2] + "|" + (cmyAlias)->RB_MAT
		cSeq := (cmyAlias)->RB_COD
		cNom := (cmyAlias)->RB_NOME
		cNas := DTOS((cmyAlias)->RB_DTNASC)
		cDoc := (cmyAlias)->RB_CIC

		If Alltrim((cmyAlias)->RB_SEXO) == "M"
				nSex := 1
		ElseIf Alltrim((cmyAlias)->RB_SEXO) == "F"
				nSex := 2
		EndIf

		Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
						aRjpInfor[11],; // 02 - RECNO
						aRjpInfor[3],; 	// 03 - id
						aKey[1],;	   	// 04 - erpCompany
						aKey[2],;	   	// 05 - erpBranch
						cMat,;	       	// 06 - erpEmployee
						cNom,;		   	// 07 - name
						cNas,;		   	// 08 - birth
						cDoc,;		   	// 09 - cpf
						nSex})		   	// 10 - gender

		EndIf

	EndIf

Return (.T.)

/*/{Protheus.doc} function fGetSRE
Retorna os dados da tabela SRE que serão enviados para a API.
@author  martins.marcio
@since   28/04/2020
@version 1.0
/*/
Static Function fGetSRE(aRjpSRE,aData)

	Local cSRE		:= "SRE"
	Local cSRA		:= "SRA"
	Local cOperac	:= ""
	Local cEmpD		:= ""
	Local cFilialD	:= ""
	Local cMatD		:= ""
	Local cRACodFun	:= ""
	Local cRACargo	:= ""
	Local cRACatSef	:= ""
	Local cFilCTT	:= ""
	Local cNewKey	:= ""
	Local cDeptoDesc := ""
	Local cCCDesc	 := ""
	Local cRAFuncDes := ""
	Local cCargoDesc := ""
	Local cCCPara	 := ""
	Local cDeptoP	 := ""

	DEFAULT aData	:= {}
	DEFAULT	aRjpSRE := {}

	aKey := StrTokArr( aRjpSRE[3], "|")

	cOperac		:= aRjpSRE[4]
	cEmpD		:= PADR(aKey[1],TAMSX3("RE_EMPD")[1])
	cFilialD	:= PADR(aKey[2],TAMSX3("RE_FILIALD")[1])
	cMatD		:= PADR(aKey[3],TAMSX3("RE_MATD")[1])

	If !(cOperac == "E") // Não é Exclusão

		DbSelectArea(cSRE)
		(cSRE)->(DbSetOrder(1)) // RE_EMPD+RE_FILIALD+RE_MATD+DTOS(RE_DATA)
		(cSRE)->(DbGoTop())
		(cSRE)->(DbSeek(cEmpD + cFilialD + cMatD + aKey[4]))

		While (cSRE)->(!EOF()) .AND. cEmpD + cFilialD + cMatD + aKey[4]  == (cSRE)->RE_EMPD + (cSRE)->RE_FILIALD + (cSRE)->RE_MATD + DTOS((cSRE)->RE_DATA)

			DbSelectArea(cSRA)
			(cSRA)->(DbSetOrder(1))
			If (cSRA)->(DbSeek(xFilial(cSRA, aKey[2]) + AllTrim(aKey[3])))
				cRACodFun	:= (cSRA)->RA_CODFUNC
				cRACargo	:= (cSRA)->RA_CARGO
				cRACatSef	:= (cSRA)->RA_CATEG
			EndIf
			cFilCTT		:= XFILIAL("CTT", AllTrim(cFilialD))

			cDeptoDesc	:= Posicione("SQB",1,XFILIAL("SQB",aKey[2])+(cSRE)->RE_DEPTOP,"QB_DESCRIC")
			cCCDesc		:= Posicione("CTT",1,XFILIAL("CTT",aKey[2])+(cSRE)->RE_CCP,"CTT_DESC01")
			cRAFuncDes	:= Posicione("SRJ",1,XFILIAL("SRJ",aKey[2])+cRACodFun,"RJ_DESC")
			cCargoDesc	:= Posicione("SQ3",1,XFILIAL("SQ3",aKey[2])+cRACargo,"Q3_DESCSUM")

			cRACodFun	:= If(!Empty(cRACodFun), aKey[1] + "|" + xFilial("SRJ", aKey[2]) + "|" + (cSRA)->RA_CODFUNC, cRACodFun)
			cRACargo	:= If(!Empty(cRACargo), aKey[1] + "|" + xFilial("SQ3", aKey[2]) + "|" + cRACargo + "|" + Posicione("SQ3", 1, xFilial("SQ3", aKey[2]) + cRACargo, "Q3_CC"), cRACargo)
			cCCPara		:= aKey[1] + "|" + xFilial("CTT", aKey[2]) + "|" + (cSRE)->RE_CCP
			cDeptoP		:= If(!Empty((cSRE)->RE_DEPTOP), aKey[1] + "|" + xFilial("SQB", aKey[2]) + "|" + (cSRE)->RE_DEPTOP, (cSRE)->RE_DEPTOP)
			cNewKey 	:= aKey[1] + "|" + aRjpSRE[12] + "|" + aRjpSRE[1] + "|" + aKey[4]

			Aadd(aData, { cOperac,;		// 01 - Operação
			aRjpSRE[11],; 			 	// 02 - Recno RJP
			cNewKey,; 				 	// 03 - id
			aKey[1],;				 	// 04 - erpCompany
			aRjpSRE[12],;				// 05 - erpBranch
			aRjpSRE[1],;				// 06 - erpEmployee
			aKey[4],;					// 07 - occurenceDate
			cCCPara,;					// 08 - erpCostCenter
			cCCDesc,;	 				// 09 - costCenterDescription
			cDeptoP,;					// 10 - erpDepartment
			cDeptoDesc,;	 			// 11 - departmentDescription
			cRACodFun,;					// 12 - erpOccupation
			cRAFuncDes,;	 			// 13 - occupationDescription
			cRACargo,;	 				// 14 - erpEmployeePosition
			cCargoDesc,;	 			// 15 - employePositionDescription
			cRACatSef })	 			// 16 - sefipCategory

			(cSRE)->(dbSkip())
		EndDo

	Else
		cNewKey 	:= aKey[1] + "|" + aRjpSRE[12] + "|" + aRjpSRE[1] + "|" + aKey[4]
		// Na exclusão monta array com valores DEFAULT
		Aadd(aData, { cOperac,;		// 01 - Operação
		aRjpSRE[11],; 			 	// 02 - Recno RJP
		cNewKey,; 				 	// 03 - id
		aKey[1],;				 	// 04 - erpCompany
		aRjpSRE[12],;				// 05 - erpBranch
		aRjpSRE[1],;					// 06 - erpEmployee
		"",;						// 07 - occurenceDate
		"",;						// 08 - erpCostCenter
		"",;	 					// 09 - costCenterDescription
		"",;						// 10 - erpDepartment
		"",;	 					// 11 - departmentDescription
		"",;						// 12 - erpOccupation
		"",;	 					// 13 - occupationDescription
		"",;	 					// 14 - erpEmployeePosition
		"",;	 					// 15 - employePositionDescription
		""})	 					// 16 - sefipCategory
	EndIf

Return (.T.)

/*/{Protheus.doc} function fGetRA4
Retorna os dados da tabela RA4 que serão enviados para a API.
@author  martins.marcio
@since   20/04/2020
@version 1.0
/*/
Static Function fGetRA4(aRjpRa4,aData)

	Local cRA4		:= "RA4"
	Local cDescCurs := ""
	Local nAprovado	:= 0 //1-Aprovado / 2-Reprovado
	Local cOperac	:= ""

	DEFAULT aData	:= {}
	DEFAULT	aRjpRa4 := {}

	aKey := StrTokArr( aRjpRa4[3], "|")

	cOperac := aRjpRa4[4]

	If !(cOperac == "E") // Não é Exclusão

		DbSelectArea(cRA4)
		(cRA4)->(DbSetOrder(1)) // RA4_FILIAL+RA4_MAT+RA4_CURSO
		(cRA4)->(DbSeek(aKey[2] + aKey[3] + aKey[4]))

		While (cRA4)->(!EOF()) .AND. aKey[2] + aKey[3] + aKey[4]  == (cRA4)->RA4_FILIAL + (cRA4)->RA4_MAT + (cRA4)->RA4_CURSO

			nAprovado	:= IIf(RA4Aprovad(aKey),1,2) // 1-Aprovado / 2-Reprovado
			cDescCurs	:= Posicione("RA1",1,XFILIAL("RA1",aKey[2])+(cRA4)->RA4_CURSO,"RA1_DESC")

			Aadd(aData, { cOperac,;		// 01 - Operação
			aRjpRa4[11],; 			 	// 02 - Recno RJP
			aRjpRa4[3],; 			 	// 03 - id
			aKey[1],;				 	// 04 - erpCompany
			aKey[2],;					// 05 - erpBranch
			aKey[3],;					// 06 - erpEmployee
			(cRA4)->RA4_DATAIN,;		// 07 - expectedDate
			(cRA4)->RA4_CURSO,;			// 08 - erpTraining
			ALLTRIM(cDescCurs),;		// 09 - trainingDescription
			(cRA4)->RA4_DATAFI,;		// 10 - completionDate
			nAprovado,;					// 11 - approval
			(cRA4)->RA4_VALIDA })		// 12 - expirationDate

			(cRA4)->(dbSkip())
		EndDo
	Else
		// Na exclusão monta array com valores DEFAULT
		Aadd(aData, { cOperac,;	// 01 - Operação
		aRjpRa4[11],; 			// 02 - Recno RJP
		aRjpRa4[3],; 			// 03 - id
		aKey[1],;				// 04 - erpCompany
		aKey[2],;				// 05 - erpBranch
		aKey[3],;				// 06 - erpEmployee
		STOD(""),;				// 07 - expectedDate
		"",;					// 08 - erpTraining
		"",;					// 09 - trainingDescription
		STOD(""),;				// 10 - completionDate
		0,;						// 11 - approval
		STOD("") })				// 12 - expirationDate
	EndIf

Return (.T.)

/*/{Protheus.doc} function fGetRD0
Retorna os dados da tabela RD0 que serão enviados para a API.
@author  Wesley Alves Pereira
@since   05/05/2020
@version 1.0
/*/
Static Function fGetRD0(aRjpInfor,aData)

	Local cmyAlias  := "RD0"
	Local aKey      := {}
	Local cCod      := ""
	Local cNom      := ""
	Local cDat      := ""
	Local cDoc      := ""
	Local nSex      := 1
	Local cNrg      := ""
	Local cEma      := ""
	Local cRua      := ""
	Local nNum      := 0
	Local cBai      := ""
	Local cCid      := ""
	Local cCep      := ""
	Local cDDD		:= ""
	Local cFon      := ""

	DEFAULT aData   := {}
	DEFAULT	aRjpInfor := {}

	aKey := StrTokArr( aRjpInfor[3], "|")

	If aRjpInfor[4] == "E"

			Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
							aRjpInfor[11],; // 02 - RECNO
							aRjpInfor[3],; 	// 03 - id
							aKey[1],;	   	// 04 - erpCompany
							aKey[2],;	   	// 05 - erpBranch
							cCod,;	       	// 06 - registration
							cNom,;		   	// 07 - name
							cDat,;		   	// 08 - birth
							cDoc,;		   	// 09 - cpf
							nSex,;          // 10 - gender
							cNrg,;          // 11 - rg
							cEma,;		   	// 12 - email
							cRua,;			// 13 - street
							nNum,;			// 14 - number
							cBai,;			// 15 - district
							cCid,;			// 16 - city
							cCep,;			// 17 - zipCode
							cDDD,;			// 18 - DDD
							cFon})			// 19 - phone

	Else

		DbSelectArea(cmyAlias)
		(cmyAlias)->(DbSetOrder(1)) // RD0_FILIAL+RD0_CODIGO
		If DbSeek(aKey[2] + aKey[3])

			cCod      := (cmyAlias)->RD0_CODIGO
			cNom      := (cmyAlias)->RD0_NOME
			cDat      := DTOS((cmyAlias)->RD0_DTNASC)
			cDoc      := (cmyAlias)->RD0_CIC
			cEma      := (cmyAlias)->RD0_EMAIL
			cRua      := (cmyAlias)->RD0_END
			cNum      := Val((cmyAlias)->RD0_NUMEND)
			cBai      := (cmyAlias)->RD0_BAIRRO
			cCid      := (cmyAlias)->RD0_MUN
			cCep      := (cmyAlias)->RD0_CEP
			cDDD      := (cmyAlias)->RD0_DDD
			cFon      := IIF(!Empty((cmyAlias)->RD0_FONE), (cmyAlias)->RD0_FONE, (cmyAlias)->RD0_NUMCEL)

			If Alltrim((cmyAlias)->RD0_SEXO) == "M"
				nSex := 1
			ElseIf Alltrim((cmyAlias)->RD0_SEXO) == "F"
				nSex := 2
			EndIf

			cNrg      := ""

			Aadd(aData, { 	aRjpInfor[4],;  // 01 - Operação
							aRjpInfor[11],; // 02 - RECNO
							aRjpInfor[3],; 	// 03 - id
							aKey[1],;	   	// 04 - erpCompany
							aKey[2],;	   	// 05 - erpBranch
							cCod,;	       	// 06 - registration
							cNom,;		   	// 07 - name
							cDat,;		   	// 08 - birth
							cDoc,;		   	// 09 - cpf
							nSex,;          // 10 - gender
							cNrg,;          // 11 - rg
							cEma,;		   	// 12 - email
							cRua,;			// 13 - street
							cNum,;			// 14 - number
							cBai,;			// 15 - district
							cCid,;			// 16 - city
							cCep,;			// 17 - zipCode
							cDDD,;			// 18 - DDD
							cFon})			// 19 - phone
		EndIf

	EndIf

Return (.T.)

/*/{Protheus.doc} function RA4Aprovad
Retorna se o funcionário foi aprovado no treinamento.
@author  Marcio Felipe Martins
@since   28/04/2020
@version 1.0
/*/
Static Function RA4Aprovad(aKey)
	Local lRet		:= .T.
	Local lNotaOk	:= .T.
	Local lPresenOk	:= .T.
	Local cCargoFun	:= ""

	DbselectArea("SRA")
	SRA->(DbSetOrder(1)) //RA_FILIAL+RA_MAT+RA_NOME
	SRA->(DbGoTop())
	If SRA->(DbSeek(xFilial("SRA",aKey[2]) + aKey[3]))
		cCargoFun	:= SRA->RA_CARGO
		DbSelectArea("RA5")
		RA5->(DbSetOrder(1)) //RA5_FILIAL+RA5_CARGO+RA5_CURSO
		RA5->(DbGoTop())
		If RA5->(DbSeek(xFilial("RA5",aKey[2]) + cCargoFun + RA4->RA4_CURSO))
			lNotaOk		:= Empty(RA5->RA5_NOTA) .Or. RA4->RA4_NOTA >= RA5->RA5_NOTA
			lPresenOk	:= Empty(RA5->RA5_FREQUE) .Or. RA4->RA4_PRESEN >= RA5->RA5_FREQUE
		EndIf
	EndIf

	lRet := (lNotaOk .And. lPresenOk)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fSubstRH
substitui os caracteres especiais
@author  martins.marcio
@since   19/10/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function fSubstRH(cTexto)

Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""
Local nTamTxt := Len(cTexto)
Local j
Local nPos

// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
// maximo possivel para visualizacao dos mesmos.
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),Chr(045),Chr(047),Chr(061),Chr(060),Chr(062);
			}

aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u","","","","","";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin
