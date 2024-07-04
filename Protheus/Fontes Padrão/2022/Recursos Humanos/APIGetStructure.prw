#include 'protheus.ch'
#include 'parmtype.ch'
#include 'wsorg010.CH'
#include 'apwebsrv.CH'

#DEFINE PAGE_LENGTH 10

/*/{Protheus.doc}APIGetStructure
- Refactory do mИtodo GETSTRUCTURE do WS - WSORG010
- A Partir deste Refact o novo PORTAL ( RestFull Services ) e o portal atual ( WSDL ) poderЦo utilizar a mesma API 
- para manutenГЦo do cСdigo fonte e regra de negСcio encapsulada.

@author:	Matheus Bizutti
@since:		30/03/2017
@obs:		- Qualquer AlteraГЦo nesta API deverА estar de acordo com as equipes responsАveis pelos portais PP e Novo PORTAL RH Unificado.
			- Pois os dois a utilizam.
@return:	- Devolve uma Lista ( Array ) com a estrutura organizacional e cada service trata este array.
/*/

Function APIGetStructure(ParticipantID, ;
						TypeOrg, 		;
						Vision, 		;
						EmployeeFil, 	;
						Registration, 	;
						Page, 			;
						FilterValue, 	;
						FilterField, 	;
						RequestType, 	;
						EmployeeSolFil, ;
						RegistSolic, 	;
						DepartmentID, 	;
						KeyVision, 		;
						IDMENU, 		;
						SolEmployeeEmp, ;
						lMeuRH, 		;
						aListEmp,		;
						aQryParam,		;
						lMorePages,		;
						lOnlySup)

Local lQryResp       	:= .F.
Local lAllRegs			:= .T.
Local nPageSize			:= 20
Local nPage				:= 1
Local nPos   	     	:= 0
Local nPosItem   	   	:= 0
Local nFunc		    	:= 0
Local nReg		    	:= 0
Local cItem  	     	:= ""
Local cChave         	:= ""
Local cLike          	:= ""
Local cDeptos        	:= ""
Local cNome          	:= ""
Local cParticipantId 	:= ""
Local cRD4Alias      	:= "QRD4"
Local cVision
Local cEmpSM0	     	:= SM0->M0_CODIGO
Local aChvItem	   		:= {}
Local aRet           	:= {}
Local aDeptos	     	:= {}
Local aSuperior      	:= {}
Local PageLen  			:= 20 //GETMV("ES_QTITPG")  //Quantidade de itens por pАgina no setor de produtos  (NЗmerico)
Local nX 			 	:= 0
Local nRecCount 	 	:= 0
Local nSkip				:= 1
Local nLoopSkip			:= 0
Local cWhere    	 	:= ""
Local cAuxAlias1 	 	:= GetNextAlias()
Local cAuxAlias2     	:= GetNextAlias()	
Local cChaveComp     	:= ""
Local cChaveOrig     	:= ""
Local nTamEmpFil	 	:= TamSX3("RDZ_FILENT")[1]	//Tamanho do campo RDZ_FILENT
Local nTamRegist	 	:= TamSX3("RDZ_CODENT")[1]	//Tamanho do campo RDZ_CODENT
Local cCampoMat
Local cEmpFil
Local cRegist
Local cCampo
Local cChaveItem		:= ""
Local cFiltro			:= ""
Local cFilRD4			:= ""
Local cFilRD41			:= ""
Local cFilSQB			:= ""
Local cFilSQB1			:= ""
Local cFilSRA			:= ""
Local cMatSup			:= ""
Local cFilSup			:= ""
Local cSra				:= ""
Local cFilFunc			:= ""
Local cCC				:= ""
Local cCodFunc 			:= ""
Local cSitFol			:= ""
Local cCargo			:= ""
Local cSalario			:= ""
Local cCatFunc			:= ""
Local cHrsMes			:= ""
Local cLoop				:= ""
Local cDepSol			:= "" //Departamento Para Aumento de Quadro / Nova ContrataГЦo
Local cRegime			:= ""
Local cNomeSoc          := ""
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁO parametro MV_GSPUBL = "2" identifica que eh GSP-Caixa.                     Ё
//ЁSe existir o parametro MV_VDFLOGO, eh porque eh GSP-MP (novo modelo de GSP). Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Local cGSP := SuperGetMv("MV_GSPUBL",,"1")
Local EmployeeData		:= {}
Local cFiliais			:= "%%"

Local aAliasNewEmp		:= {"SRA","RDZ","RD0","SQB","CTT","SRJ","SQ3"}
Local lTrocou 			:= .F.
Local aAreaSM0			:= SM0->(GetArea())

Local nI				:= 1
Local aEmpEquip			:= {}
Local cQry				:= ""
Local cVisMenu			:= GetMv("MV_TCFVREN", ,"N")
Local lPEPRHSIT 		:= ExistBlock("PRHSITFOL")

If cGSP >= "2" 
	cGSP := "3"
EndIf

// Variaveis para a funГЦo ChangeEmp
Private __cLastEmp 	:= ""
Private __cLastData	:= ""
Private __cEmpAnt	:= cEmpAnt
Private __cFilAnt	:= cFilAnt
Private __cArqTab	:= cArqTab
Private aTabCompany := {}
Private lCorpManage := fIsCorpManage()

DEFAULT ParticipantID  	:= ""
DEFAULT TypeOrg 		:= ""
DEFAULT Vision 	  		:= ""
DEFAULT EmployeeFil		:= ""
DEFAULT Registration	:= ""
DEFAULT Page 			:= 1
DEFAULT FilterField		:= ""
DEFAULT FilterValue		:= ""
DEFAULT RequestType 	:= ""
DEFAULT EmployeeSolFil 	:= EmployeeFil	
DEFAULT RegistSolic 	:= Registration
DEFAULT DepartmentID	:= ""
DEFAULT KeyVision   	:= ""
DEFAULT IDMENU			:= ""
DEFAULT SolEmployeeEmp 	:= cEmpAnt
DEFAULT lMeuRH			:= .F.
DEFAULT aListEmp		:= FWAllGrpCompany()
DEFAULT aQryParam       := {}
DEFAULT lMorePages		:= .F.
DEFAULT lOnlySup		:= .F.

If cEmpSM0 <> SolEmployeeEmp .And. !Empty(SolEmployeeEmp)
	SM0->(DbGoTop())
	SM0->(DbSeek(SolEmployeeEmp))
	lTrocou := ChangeEmp(aAliasNewEmp, SM0->M0_CODIGO, SM0->M0_CODFIL)
	cEmpSM0	:= SM0->M0_CODIGO
EndIf

If Empty(SM0->M0_CODIGO)	//valida posicionamento da SM0
	OpenSm0()
	SM0->(DbGoTop())
	
	While SM0->(!Eof())
		If AllTrim(SM0->M0_CODIGO) == AllTrim(cEmpAnt)
			cEmpSM0 := SM0->M0_CODIGO
			exit
		EndIf
		SM0->(DbSkip())
	EndDo
EndIf

cVision := Vision
cCampo	:= FilterField
cFiltro	:= FilterValue
cKeyVision	:= KeyVision

aadd(EmployeeData,WsClassNew('TEmployeeData'))

lAllRegs := Len(aQryParam) == 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ёcheca o tipo de estrutura - Departamentos/Postos                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !TipoOrg(@TypeOrg, cVision)
	EmployeeData := {}
	Aadd(EmployeeData,.F.)
	Aadd(EmployeeData,"GetStructure1")
	Aadd(EmployeeData,PorEncode(STR0003))	 //"Visao nЦo encontrada"

	// Restaura dados da empresa logada apСs troca de empresa
	If lTrocou
		ChangeEmp(aAliasNewEmp, __cEmpAnt, __cFilAnt)
	EndIf
	RestArea( aAreaSM0 )

	Return(EmployeeData)
EndIf

If !Empty(EmployeeSolFil) .and. !Empty(RegistSolic)
	// Prepara corretamente tamanho campo para busca no RDZ
	cEmpFil := EmployeeSolFil  + Space(nTamEmpFil - Len(EmployeeSolFil))
	cRegist := RegistSolic + Space(nTamRegist - (Len(RegistSolic)+Len(cEmpFil)))
	
	dbSelectArea("RDZ")
	RDZ->( dbSetOrder(1) ) //RDZ_FILIAL+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA+RDZ_CODENT+RDZ_CODRD0           
	If RDZ->( dbSeek(xFilial("RDZ") + cEmpSM0 + xFilial("SRA", cEmpFil) + "SRA" + cEmpFil + cRegist))
		dbSelectArea("RD0")
		RD0->( dbSetOrder(1) ) //RD0_FILIAL+RD0_CODIGO
		If RD0->( dbSeek(xFilial("RD0") + RDZ->RDZ_CODRD0) )
			cParticipantId := RD0->RD0_CODIGO
		EndIf
	EndIf 
Else
	//Localizar o funcionАrio(SRA) a partir do ID logado (participante - RD0)
	cParticipantId := ParticipantID   
EndIf

If Participant(cParticipantId, aRet, , RegistSolic,, EmployeeSolFil)
	EmployeeSolFil := If( Empty(EmployeeSolFil), aRet[3], EmployeeSolFil )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDepartamento (sem visao)                                                     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If TypeOrg == "0"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁMonta a estrutura de departamentos                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aDeptos := fEstrutDepto( aRet[3] )
		
		cItem  := ""
		cLike  := ""
		cChave := ""
	Else
		If !ChaveRD4(TypeOrg,@aRet,cVision,@cItem,@cChave,@cLike)
			EmployeeData := {}
			Aadd(EmployeeData,.F.)
			Aadd(EmployeeData,"GetStructure2")
			Aadd(EmployeeData,PorEncode(STR0003))	 //"Visao nЦo encontrada"

			// Restaura dados da empresa logada apСs troca de empresa
			If lTrocou
				ChangeEmp(aAliasNewEmp, __cEmpAnt, __cFilAnt)
			EndIf
			RestArea( aAreaSM0 )

			Return(EmployeeData)
		EndIf       
	EndIf
	
	dbSelectArea("SRA")
	SRA->( dbSetOrder(1) )
	If (SRA->( dbSeek(aRet[3] +aRet[1] ) ))
		cSitFol		:= SRA->RA_SITFOLH
		If lPEPRHSIT
			cSitFol	:= ExecBlock("PRHSITFOL", .F., .F., { SRA->RA_FILIAL, SRA->RA_MAT} )
		EndIf
		If cSitFol == "D" .And. SRA->RA_DEMISSA > dDataBase .And. cVisMenu == "L"
			cSitFol := " "
		EndIf
		cFilFunc	:= SRA->RA_FILIAL
		cCC			:= SRA->RA_CC
		cCodFunc	:= SRA->RA_CODFUNC
		cCargo		:= SRA->RA_CARGO
		cSalario	:= SRA->RA_SALARIO
		cCatFunc	:= SRA->RA_CATFUNC
		cHrsMes		:= SRA->RA_HRSMES
		cNomeSoc    := SRA->RA_NSOCIAL
		If !cGSP == "1"
			cRegime	:= SRA->RA_REGIME
		EndIf
	EndIf
	
	EmployeeData[1]:ListOfEmployee := {}
	aadd(EmployeeData[1]:ListOfEmployee,WsClassNew('DataEmployee'))
	nFunc++
	EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeEmp		:= cEmpAnt
	EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeFilial	:= aRet[3]
	EmployeeData[1]:ListOfEmployee[nFunc]:Registration		:= aRet[1]
	EmployeeData[1]:ListOfEmployee[nFunc]:ParticipantID		:= cParticipantId
	EmployeeData[1]:ListOfEmployee[nFunc]:Name				:= AllTrim(aRet[2])
	EmployeeData[1]:ListOfEmployee[nFunc]:SocialName		:= AllTrim(cNomeSoc)
	EmployeeData[1]:ListOfEmployee[nFunc]:AdmissionDate		:= DTOC(aRet[5])
	EmployeeData[1]:ListOfEmployee[nFunc]:BirthdayDate		:= DTOC(SRA->RA_NASC)
	EmployeeData[1]:ListOfEmployee[nFunc]:Department		:= aRet[8]
	EmployeeData[1]:ListOfEmployee[nFunc]:DescrDepartment	:= fDesc('SQB',aRet[8],'SQB->QB_DESCRIC',,xFilial("SQB", aRet[3]),1)
	EmployeeData[1]:ListOfEmployee[nFunc]:Item				:= cItem
	EmployeeData[1]:ListOfEmployee[nFunc]:KeyVision			:= cChave
	EmployeeData[1]:ListOfEmployee[nFunc]:LevelHierar		:= (len(Alltrim(cChave))/3)-1
	EmployeeData[1]:ListOfEmployee[nFunc]:TypeEmployee		:= "1"
	EmployeeData[1]:ListOfEmployee[nFunc]:Situacao			:= cSitFol
	EmployeeData[1]:ListOfEmployee[nFunc]:DescSituacao		:= AllTrim(fDesc("SX5", "31" + cSitFol, "X5DESCRI()", NIL, aRet[3]))
	EmployeeData[1]:ListOfEmployee[nFunc]:FunctionId		:= cCodFunc
	EmployeeData[1]:ListOfEmployee[nFunc]:FunctionDesc		:= Alltrim(Posicione('SRJ',1,xFilial("SRJ", cFilFunc)+cCodFunc,'SRJ->RJ_DESC'))
	EmployeeData[1]:ListOfEmployee[nFunc]:CostId			:= cCC
	EmployeeData[1]:ListOfEmployee[nFunc]:Cost				:= Alltrim(Posicione('CTT',1,xFilial("CTT",cFilFunc)+Alltrim(cCC),'CTT->CTT_DESC01'))
	EmployeeData[1]:ListOfEmployee[nFunc]:PositionId		:= cCargo
	If !cGSP == "1"
		EmployeeData[1]:ListOfEmployee[nFunc]:Polity		:= cRegime
	Else
		EmployeeData[1]:ListOfEmployee[nFunc]:Polity	:= ' ' 
	EndIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁBusca dados de substituto para gestao publica                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cGSP == "3" .And. IDMENU=="GFP"// Gestao Publica - MP
		BEGINSQL alias cAuxAlias2
			SELECT SQ3.Q3_DESCSUM, SQ3.Q3_SUBSTIT
			FROM %table:SQ3% SQ3
			WHERE SQ3.Q3_FILIAL = %exp:xFilial("SQ3",cFilFunc)% AND
			SQ3.Q3_CARGO = %exp:cCargo% AND
			SQ3.%notDel%
		EndSql

		If !(cAuxAlias2)->(Eof())
			EmployeeData[1]:ListOfEmployee[nFunc]:Position			:= (cAuxAlias2)->Q3_DESCSUM
			If (cAuxAlias2)->Q3_SUBSTIT == '1'
				EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst	:= .T.
			Else
				EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst	:= .F.
			EndIf
		Else
			EmployeeData[1]:ListOfEmployee[nFunc]:Position			:= Alltrim(Posicione('SQ3',1,xFilial("SQ3",cFilFunc)+cCargo,'SQ3->Q3_DESCSUM'))
			EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst		:= .F.
		EndIf
		(cAuxAlias2)->(dbCloseArea())
	Else
		EmployeeData[1]:ListOfEmployee[nFunc]:Position				:= Alltrim(Posicione('SQ3',1,xFilial("SQ3",cFilFunc)+cCargo,'SQ3->Q3_DESCSUM'))
		EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst			:= .F.
	EndIf
	
	EmployeeData[1]:ListOfEmployee[nFunc]:Salary			:= cSalario
	EmployeeData[1]:ListOfEmployee[nFunc]:FilialDescr		:= Alltrim(Posicione("SM0",1,cnumemp,"M0_FILIAL"))
	EmployeeData[1]:ListOfEmployee[nFunc]:CatFunc			:= cCatFunc
	EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncDesc		:= Alltrim(FDESC("SX5","28"+cCatFunc,"X5DESCRI()"))
	EmployeeData[1]:ListOfEmployee[nFunc]:HoursMonth		:= Alltrim(Str(cHrsMes))
	EmployeeData[1]:ListOfEmployee[nFunc]:ResultConsolid	:= ''

	If TypeOrg == "0"
		If (nPos := aScan(aDeptos, {|x| x[1] == aRet[8]})) > 0
			cChave := aDeptos[nPos][5]
			EmployeeData[1]:ListOfEmployee[nFunc]:KeyVision		:= cChave
			EmployeeData[1]:ListOfEmployee[nFunc]:LevelHierar	:= (len(Alltrim(cChave))/3)-1
		EndIf
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁVerificar se possui alguma solicitacao para o funcionario de acordo com o tipo de requisicao(RequestType) Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	EmployeeData[1]:ListOfEmployee[nFunc]:PossuiSolic := .F.
	
	If Empty(DepartmentID)
		cDepSol := aRet[8]
	Else
		cDepSol := DepartmentID //Usada nas gravaГУes do tipo 3 e 5 (Aumento de Quadro e ContrataГЦo)
	EndIf
	
	Do Case
	Case RequestType == "A" //Treinamento
		cCampoMat  := 'RA3_MAT'
	Case RequestType == "B" //Ferias
		cCampoMat  := 'R8_MAT'
	Case RequestType == "2" //AlteraГЦo Cadastral eSocial 2.1
		cCampoMat  := 'RA_MAT'
	Case RequestType == "4" //Transferencia
		cCampoMat  := 'RE_MATD'
	Case RequestType == "6" //Desligamento
		cCampoMat  := 'RA_MAT'
	Case RequestType == "8" //Justificativa
		cCampoMat  := 'RF0_MAT'
	Case RequestType == "7" //Acao Salarial
		cCampoMat  := 'RB7_MAT'
	Case RequestType == "N" //Gestao Publica - alteracao de jornada
		cCampoMat  := 'PF_MAT'
	Case RequestType == "O" //Gestao Publica - Saldo de ferias
		cCampoMat  := 'RA_MAT'
	Case RequestType == "P" //Gestao Publica - programacao de ferias
		cCampoMat  := 'RA_MAT'
	Case RequestType == "Q" //Gestao Publica - diarias
		cCampoMat  := 'RA_MAT'
	Case RequestType == "R" //Gestao Publica - Licenca e afastamento
		cCampoMat  := 'RA_MAT'
	Case RequestType == "S" //Gestao Publica - Certidao Funcional
		cCampoMat  := 'RA_MAT'
	Case RequestType == "T" //Gestao Publica - dias de folga
		cCampoMat  := 'RA_MAT'
	Case RequestType == "V" //Solic subsМdio AcadЙmico
		cCampoMat  := 'RI1_MAT'
	OtherWise
		cCampoMat  := ''
	EndCase
	
	If cCampoMat != ''
		BeginSql alias cAuxAlias1
			SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH4.RH4_CAMPO, RH4.RH4_VALNOV
			FROM  %table:RH3% RH3
			INNER JOIN %table:RH4% RH4
			ON RH3.RH3_FILIAL = RH4.RH4_FILIAL AND
			RH3.RH3_CODIGO = RH4.RH4_CODIGO
			WHERE
			RH3.RH3_FILIAL = %exp:aRet[3]% AND
			RH4.RH4_CAMPO = %exp:cCampoMat% AND
			RH4.RH4_VALNOV = %exp:aRet[1]% AND
			RH3.RH3_STATUS in ('1', '4') AND
			RH3.RH3_TIPO = %exp:RequestType% AND
			RH4.%notDel% AND
			RH3.%notDel%
		EndSql
		
		If !(cAuxAlias1)->(Eof())
			EmployeeData[1]:ListOfEmployee[nFunc]:PossuiSolic := .T.
		EndIf
		(cAuxAlias1)->(dbCloseArea())
	EndIf
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁBusca Informacoes do superior                                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aSuperior := fBuscaSuperior(aRet[3], aRet[1], cDepSol, aDeptos, TypeOrg, cVision, cEmpAnt, EmployeeSolFil, RegistSolic)
	
	If Len(aSuperior) > 0
		EmployeeData[1]:ListOfEmployee[nFunc]:SupFilial			:= aSuperior[1][1]
		EmployeeData[1]:ListOfEmployee[nFunc]:SupRegistration	:= aSuperior[1][2]
		EmployeeData[1]:ListOfEmployee[nFunc]:NameSup			:= aSuperior[1][3]
		EmployeeData[1]:ListOfEmployee[nFunc]:LevelSup			:= aSuperior[1][4]
		EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncSup		:= aSuperior[1][6]
		EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncDescSup	:= Alltrim(FDESC("SX5","28"+aSuperior[1][6],"X5DESCRI()"))
		EmployeeData[1]:ListOfEmployee[nFunc]:SupEmpresa		:= aSuperior[1][7]
		EmployeeData[1]:ListOfEmployee[nFunc]:DepartAprovador	:= aSuperior[1][8]
		EmployeeData[1]:ListOfEmployee[nFunc]:SocialNameSup	    := fGetRANome(EmployeeData[1]:ListOfEmployee[nFunc]:SupFilial,;
																			  EmployeeData[1]:ListOfEmployee[nFunc]:SupRegistration,;
																			  EmployeeData[1]:ListOfEmployee[nFunc]:SupEmpresa)
	Else
		EmployeeData[1]:ListOfEmployee[nFunc]:SupFilial			:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:SupRegistration	:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:NameSup			:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:LevelSup			:= 99
		EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncSup		:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncDescSup	:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:SupEmpresa		:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:DepartAprovador	:= ""
		EmployeeData[1]:ListOfEmployee[nFunc]:SocialNameSup	    := ""
	EndIf
	
	cMatSup := EmployeeData[1]:ListOfEmployee[nFunc]:Registration
	cFilSup := EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeFilial

	//Permite limitar a consulta apenas para retornar dados do superior conforme a estrutura hierarquica
	If !lOnlySup        
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁDados da Equipe                                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁDepartamento (sem visao)                                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If TypeOrg == "0"
			cFilSQB := xFilial("SQB",cFilFunc)
			For nPos := 1 to Len(aDeptos)
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁVerificarА na query quais deptos o funcionario logado И responsАvel direto	Ё
				//ЁaDeptos[nPos][2] -> Filial        											Ё
				//ЁaDeptos[nPos][3] -> Matricula												Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If aDeptos[nPos][2] == aRet[3] .and. aDeptos[nPos][3] == aRet[1]
					cChave := aDeptos[nPos][5]
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁVerifica quais departamentos estЦo abaixo do departamento					Ё
					//Ёque o funcionario logado И responsАvel										Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					For nReg := 1 to Len(aDeptos)
						If (substr(aDeptos[nReg][5],1,len(cChave)) == cChave .and. len(aDeptos[nReg][5]) == len(cChave) + 3)
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//ЁArmazena todos os departamentos que o funcionАrio logado tem acesso          Ё
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							cDeptos += "'" + aDeptos[nReg][1] + "',"
						EndIf
					Next nReg
				EndIf
			Next nPos
			
			cWhere := "%"
			If !Empty(cFiltro) .AND. !Empty(cCampo)
				If(cCampo == "1")		//cСdigo
					cWhere += " AND SRA.RA_MAT LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "2")	//nome
					cWhere += " AND SRA.RA_NOME LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "3")	//admissЦo
					cWhere += " AND SRA.RA_ADMISSA LIKE '%" + Replace(dToS(cToD(cFiltro)),"'","") + "%'"
				ElseIf(cCampo == "4")	//departamento
					cWhere += " AND SRA.RA_DEPTO LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "5")	//situaГЦo
					cWhere += " AND SRA.RA_SITFOLH LIKE '%" + Replace(cFiltro,"'","") + "%'"
				EndIf
			EndIf
			If IDMENU == "GFP"
				cWhere += " AND SRA.RA_REGIME = '2'"  
			ElseIf IDMENU == "GCH"
				cWhere += " AND SRA.RA_REGIME <> '2'" 
			EndIf
			If lMeuRH .And. !lAllRegs
				cWhere += fMrhWhere(aQryParam, @lAllRegs, @nPage, @nPageSize)
			EndIf
			cWhere += "%"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFaz validacao do modo de acesso do Departamento                                             Ё
			//ЁCompartilhado: nao faz filtro da filial do SRA e traz funcionarios do departamento          Ё
			//ЁExclusivo: faz filtro da filial do SRA de acordo com a filial do responsavel do departamentoЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty( xFilial("SQB") )
				cFiliais := "%" + Upper( FWJoinFilial( "SRA", "SQB" ) ) + " AND %"
			EndIf

			If Empty(cDeptos)
				cDeptos := "%(' ')%"
			Else
				cDeptos := "%(" + substr(cDeptos, 1, len(cDeptos)-1)+ ")%"
			EndIf

			BeginSql alias cRD4Alias
				SELECT
					SRA.RA_SITFOLH,
					SRA.RA_FILIAL,
					SRA.RA_MAT,
					SRA.RA_NSOCIAL,
					RD0.RD0_NOME,
					RD0.RD0_CODIGO,
					SRA.RA_NOME,
					SRA.RA_NOMECMP,
					SRA.RA_ADMISSA,
					SRA.RA_DEPTO,
					SRA.RA_SITFOLH,
					SRA.RA_CC,
					SRA.RA_CARGO,
					SRA.RA_CODFUNC,
					SRA.RA_SALARIO,
					SRA.RA_CATFUNC,
					SRA.RA_HRSMES,
					SRA.RA_NASC
				FROM %table:SRA% SRA
				LEFT JOIN %table:RDZ% RDZ
					ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND
					RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
					RDZ.RDZ_EMPENT = %exp:cEmpSM0% AND
					RDZ.%notdel%
				LEFT JOIN %table:RD0% RD0
					ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 AND
					RD0.RD0_FILIAL = %xfilial:RD0% AND
					RD0.%notdel%
				INNER JOIN %table:SQB% SQB
					ON SQB.QB_DEPTO = SRA.RA_DEPTO AND
					%exp:cFiliais%
					SQB.%notDel%
				WHERE SQB.QB_MATRESP = %exp:aRet[1]% AND
					SQB.QB_FILRESP = %exp:aRet[3]% AND
					SRA.RA_SITFOLH <> 'D' AND
					SRA.RA_FILIAL || SRA.RA_MAT NOT IN (%exp: cFilSup+cMatSup%) AND
					RDZ.RDZ_ENTIDA = 'SRA' AND
					SRA.%notDel%
					%exp:cWhere%
				UNION
				SELECT SRA.RA_SITFOLH,SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NSOCIAL, RD0.RD0_NOME, RD0.RD0_CODIGO, SRA.RA_NOME, SRA.RA_NOMECMP, SRA.RA_ADMISSA,
					SRA.RA_DEPTO, SRA.RA_SITFOLH, SRA.RA_CC, SRA.RA_CARGO, SRA.RA_CODFUNC,SRA.RA_SALARIO,SRA.RA_CATFUNC,SRA.RA_HRSMES,SRA.RA_NASC
				FROM %table:SQB% SQB
				INNER JOIN %table:SRA% SRA
					ON SQB.QB_FILRESP = SRA.RA_FILIAL AND
					SQB.QB_MATRESP = SRA.RA_MAT
				LEFT JOIN %table:RDZ% RDZ
					ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND
					RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
					RDZ.RDZ_EMPENT = %exp:cEmpSM0% AND
					RDZ.%notdel%
				LEFT JOIN %table:RD0% RD0
					ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 AND
					RD0.RD0_FILIAL = %xfilial:RD0% AND
					RD0.%notdel%
				WHERE SQB.QB_DEPTO IN %exp:cDeptos% AND
					SRA.RA_SITFOLH <> 'D' AND
					SQB.QB_FILIAL = %exp:cFilSQB% AND
					SRA.RA_FILIAL || SRA.RA_MAT NOT IN (%exp: cFilSup+cMatSup%) AND
					RDZ.RDZ_ENTIDA = 'SRA' AND
					SQB.%notDel% AND
					SRA.%notDel%
					%exp:cWhere%
			EndSql

			COUNT TO nRecCount
			(cRD4Alias)->(DbGoTop())

			If !lMeuRH
				EmployeeData[1]:PagesTotal := Ceiling(nRecCount / PAGE_LENGTH)
				If Page > 1
					nSkip := (Page-1) * PAGE_LENGTH
					For nLoopSkip := 1 to nSkip
						(cRD4Alias)->(DBSkip())
					Next nLoopSkip
				EndIf
			Else
				If !lAllRegs
					EmployeeData[1]:PagesTotal := Ceiling(nRecCount / nPageSize)
					If nPage > 1
						nSkip := (nPage-1) * nPageSize
						For nLoopSkip := 1 to nSkip
							(cRD4Alias)->(DBSkip())
						Next nLoopSkip
					EndIf
				EndIf
			EndIf

			While (cRD4Alias)->( !Eof() ) .AND. If( !lMeuRH, Len(EmployeeData[1]:ListOfEmployee) <= PAGE_LENGTH, Len(EmployeeData[1]:ListOfEmployee) <= nPageSize .Or. lAllRegs )

				cNome := alltrim(If(! Empty((cRD4Alias)->RA_NOMECMP),(cRD4Alias)->RA_NOMECMP,If(! Empty((cRD4Alias)->RD0_NOME),(cRD4Alias)->RD0_NOME,(cRD4Alias)->RA_NOME)))

				If (cRD4Alias)->RA_FILIAL + (cRD4Alias)->RA_MAT <> aRet[3] + aRet[1] .And. (cRD4Alias)->RA_SITFOLH <> 'D'
					nFunc++
					aAdd(EmployeeData[1]:ListOfEmployee,WsClassNew('DataEmployee'))
					EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeEmp		:= cEmpAnt
					EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeFilial	:= (cRD4Alias)->RA_FILIAL
					EmployeeData[1]:ListOfEmployee[nFunc]:Registration		:= (cRD4Alias)->RA_MAT
					EmployeeData[1]:ListOfEmployee[nFunc]:ParticipantID		:= (cRD4Alias)->RD0_CODIGO
					EmployeeData[1]:ListOfEmployee[nFunc]:Name				:= AllTrim(cNome)
					EmployeeData[1]:ListOfEmployee[nFunc]:SocialName		:= AllTrim((cRD4Alias)->RA_NSOCIAL)
					EmployeeData[1]:ListOfEmployee[nFunc]:AdmissionDate		:= If(valtype((cRD4Alias)->RA_ADMISSA)== "D",DTOC((cRD4Alias)->RA_ADMISSA),DTOC(STOD((cRD4Alias)->RA_ADMISSA)))
					EmployeeData[1]:ListOfEmployee[nFunc]:BirthdayDate		:= If(valtype((cRD4Alias)->RA_NASC)== "D",DTOC((cRD4Alias)->RA_NASC),DTOC(STOD((cRD4Alias)->RA_NASC)))
					EmployeeData[1]:ListOfEmployee[nFunc]:Department		:= (cRD4Alias)->RA_DEPTO
					EmployeeData[1]:ListOfEmployee[nFunc]:DescrDepartment	:= Alltrim(Posicione('SQB',1,xFilial("SQB",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_DEPTO,'SQB->QB_DESCRIC'))
					EmployeeData[1]:ListOfEmployee[nFunc]:Item				:= ""
					EmployeeData[1]:ListOfEmployee[nFunc]:TypeEmployee		:= "2"
					EmployeeData[1]:ListOfEmployee[nFunc]:SupFilial			:= EmployeeData[1]:ListOfEmployee[1]:EmployeeFilial
					EmployeeData[1]:ListOfEmployee[nFunc]:SupRegistration	:= EmployeeData[1]:ListOfEmployee[1]:Registration
					EmployeeData[1]:ListOfEmployee[nFunc]:NameSup			:= aRet[2]
					EmployeeData[1]:ListOfEmployee[nFunc]:LevelSup			:= EmployeeData[1]:ListOfEmployee[1]:LevelHierar
					EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncSup		:= EmployeeData[1]:ListOfEmployee[1]:CatFunc
					EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncDescSup	:= EmployeeData[1]:ListOfEmployee[1]:CatFuncDesc
					EmployeeData[1]:ListOfEmployee[nFunc]:Situacao			:= (cRD4Alias)->RA_SITFOLH
					EmployeeData[1]:ListOfEmployee[nFunc]:DescSituacao		:= AllTrim(fDesc("SX5", "31" + (cRD4Alias)->RA_SITFOLH, "X5DESCRI()", NIL, (cRD4Alias)->RA_FILIAL))
					EmployeeData[1]:ListOfEmployee[nFunc]:CostId			:= (cRD4Alias)->RA_CC
					EmployeeData[1]:ListOfEmployee[nFunc]:Cost				:= Alltrim(Posicione('CTT',1,xFilial("CTT",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CC,'CTT->CTT_DESC01'))
					EmployeeData[1]:ListOfEmployee[nFunc]:FunctionId		:= (cRD4Alias)->RA_CODFUNC
					EmployeeData[1]:ListOfEmployee[nFunc]:FunctionDesc		:= Alltrim(Posicione('SRJ',1,xFilial("SRJ", (cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CODFUNC,'SRJ->RJ_DESC'))
					EmployeeData[1]:ListOfEmployee[nFunc]:PositionId		:= (cRD4Alias)->RA_CARGO

					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁBusca dados de substituto para gestao publica                                Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cGSP == "3" // Gestao Publica - MP
						BEGINSQL alias cAuxAlias2
							SELECT SQ3.Q3_DESCSUM, SQ3.Q3_SUBSTIT
							FROM %table:SQ3% SQ3
							WHERE SQ3.Q3_FILIAL = %exp:xFilial("SQ3",cFilFunc)%  AND
								SQ3.Q3_CARGO = %exp:(cRD4Alias)->RA_CARGO% AND
								SQ3.%notDel%
						EndSql

						If !(cAuxAlias2)->(Eof())
							EmployeeData[1]:ListOfEmployee[nFunc]:Position			:= (cAuxAlias2)->Q3_DESCSUM
							If (cAuxAlias2)->Q3_SUBSTIT == '1'
								EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst	:= .T.
							Else
								EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst	:= .F.
							EndIf
						Else
							EmployeeData[1]:ListOfEmployee[nFunc]:Position			:= Alltrim(Posicione('SQ3',1,xFilial("SQ3")+(cRD4Alias)->RA_CARGO,'SQ3->Q3_DESCSUM'))
							EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst		:= .F.
						EndIf
						(cAuxAlias2)->(dbCloseArea())
					Else
						EmployeeData[1]:ListOfEmployee[nFunc]:Position				:= Alltrim(Posicione('SQ3',1,xFilial("SQ3")+(cRD4Alias)->RA_CARGO,'SQ3->Q3_DESCSUM'))
						EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst			:= .F.
					EndIf

					EmployeeData[1]:ListOfEmployee[nFunc]:Salary			:= (cRD4Alias)->RA_SALARIO
					EmployeeData[1]:ListOfEmployee[nFunc]:Total				:= 1
					EmployeeData[1]:ListOfEmployee[nFunc]:FilialDescr		:= Alltrim(Posicione("SM0",1,cnumemp,"M0_FILIAL"))
					EmployeeData[1]:ListOfEmployee[nFunc]:CatFunc			:= (cRD4Alias)->RA_CATFUNC
					EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncDesc		:= Alltrim(FDESC("SX5","28"+(cRD4Alias)->RA_CATFUNC,"X5DESCRI()"))
					EmployeeData[1]:ListOfEmployee[nFunc]:HoursMonth		:= Alltrim(Str((cRD4Alias)->RA_HRSMES))
					EmployeeData[1]:ListOfEmployee[nFunc]:ResultConsolid	:= ''

					If (nPos := aScan(aDeptos, {|x| x[1] == (cRD4Alias)->RA_DEPTO})) > 0
						cChave := aDeptos[nPos][5]
						EmployeeData[1]:ListOfEmployee[nFunc]:KeyVision		:= cChave
						EmployeeData[1]:ListOfEmployee[nFunc]:LevelHierar	:= (len(Alltrim(cChave))/3)-1
					EndIf

					BEGINSQL alias cAuxAlias1
						SELECT
						SQB.QB_DEPTO
						FROM %table:SQB% SQB
						WHERE SQB.QB_FILRESP = %exp:(cRD4Alias)->RA_FILIAL% AND
							SQB.QB_MATRESP = %exp:(cRD4Alias)->RA_MAT% AND
							SQB.%notDel%
					EndSql

					If !(cAuxAlias1)->(Eof())
						EmployeeData[1]:ListOfEmployee[nFunc]:PossuiEquipe := .T.
					Else
						EmployeeData[1]:ListOfEmployee[nFunc]:PossuiEquipe := .F.
					EndIf
					(cAuxAlias1)->(dbCloseArea())

					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁVerificar se possui alguma solicitacao para o funcionario de acordo com o tipo de requisicao(RequestType)Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					EmployeeData[1]:ListOfEmployee[nFunc]:PossuiSolic := .F.

					Do Case
						Case RequestType == "A" //Treinamento
							cCampoMat  := 'RA3_MAT'
						Case RequestType == "B" //Ferias
							cCampoMat  := 'R8_MAT'
						Case RequestType == "4" //Transferencia
							cCampoMat  := 'RE_MATD'
						Case RequestType == "6" //Desligamento
							cCampoMat  := 'RA_MAT'
						Case RequestType == "8" //Justificativa
							cCampoMat  := 'RF0_MAT'
						Case RequestType == "7" //Acao Salarial
							cCampoMat  := 'RB7_MAT'
						Case RequestType == "N" //Gestao Publica - alteracao de jornada
							cCampoMat  := 'PF_MAT'
						Case RequestType == "O" //Gestao Publica - Saldo de ferias
							cCampoMat  := 'RA_MAT'
						Case RequestType == "P" //Gestao Publica - programacao de ferias
							cCampoMat  := 'RA_MAT'
						Case RequestType == "Q" //Gestao Publica - diaria
							cCampoMat  := 'RA_MAT'
						Case RequestType == "R" //Gestao Publica - Licenca e afastamento
							cCampoMat  := 'RA_MAT'
						Case RequestType == "S" //Gestao Publica - Certidao Funcional
							cCampoMat  := 'RA_MAT'
						Case RequestType == "T" //Gestao Publica - dias de folga
							cCampoMat  := 'RA_MAT'
						Case RequestType == "V" //Solic subsМdio AcadЙmico
							cCampoMat  := 'RI1_MAT'
						OtherWise
							cCampoMat  := ''
					EndCase

					If cCampoMat != ''
						BeginSql alias cAuxAlias1
							SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH4.RH4_CAMPO, RH4.RH4_VALNOV
							FROM  %table:RH3% RH3
							INNER JOIN %table:RH4% RH4
								ON 	RH3.RH3_FILIAL = RH4.RH4_FILIAL AND
								RH3.RH3_CODIGO = RH4.RH4_CODIGO
							WHERE
								RH4.RH4_CAMPO = %exp:cCampoMat% AND
								RH4.RH4_VALNOV = %exp:(cRD4Alias)->RA_MAT% AND
								RH3.RH3_FILIAL = %exp:(cRD4Alias)->RA_FILIAL% AND
								RH3.RH3_STATUS IN ('1', '4') AND
								RH3.RH3_TIPO = %exp:RequestType% AND
								RH4.%notDel% AND
								RH3.%notDel%
						EndSql

						If !(cAuxAlias1)->(Eof())
							EmployeeData[1]:ListOfEmployee[nFunc]:PossuiSolic := .T.
						EndIf
						(cAuxAlias1)->(dbCloseArea())
					EndIf
				EndIf
				(cRD4Alias)->( DbSkip() )
			EndDo
			(cRD4Alias)->( DbCloseArea() )
			If nFunc > nPageSize
				lMorePages := .T.
			EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPosto                                                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf TypeOrg == "1"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁSelecionar a equipe do funcionario logado                       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cWhere := " "
			If !Empty(cFiltro) .AND. !Empty(cCampo)
				If(cCampo == "1")
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁCodigo                                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_MAT LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "2")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁNome                                                            Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_NOME LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "3")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁAdmissa                                                         Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_ADMISSA LIKE '%" + Replace(dToS(cToD(cFiltro)),"'","") + "%'"
				ElseIf(cCampo == "4")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁDepartamento                                                    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_DEPTO LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "5")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁSituacao                                                        Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_SITFOLH LIKE '%" + Replace(cFiltro,"'","") + "%'"
				EndIf
			EndIf
			If IDMENU == "GFP"
				cWhere += " AND SRA.RA_REGIME = '2'"  
			ElseIf IDMENU == "GCH"
				cWhere += " AND SRA.RA_REGIME <> '2'" 
			EndIf
			If lMeuRH .And. !lAllRegs
				cWhere += fMrhWhere(aQryParam, @lAllRegs, @nPage, @nPageSize)
			EndIf
			cWhere += " "
			
			cRD4Alias := GetNextAlias()
			BeginSQL ALIAS cRD4Alias
				SELECT DISTINCT RD4_EMPIDE
				FROM %table:RD4% RD4 
				WHERE RD4.RD4_CODIGO = %exp:cVision% 
				AND	RD4.RD4_FILIAL = %xfilial:RD4% 
				AND	RD4.%notDel%                   
			EndSQL
			
			cSra	:= RetFullName("SRA",cEmpAnt)	
			cRdz	:= RetFullName("RDZ",cEmpAnt)	
			cRd0	:= RetFullName("RD0",cEmpAnt)

			cLoop := ""
			While !(cRD4Alias)->(Eof())
				cLoop += " SELECT "
				cLoop += " SRA.RA_SITFOLH, "
				cLoop += " SRA.RA_FILIAL, "
				cLoop += " SRA.RA_MAT, "
				cLoop += " RD0.RD0_NOME, "
				cLoop += " RD0.RD0_CODIGO, "
				cLoop += " SRA.RA_NOME, "
				cLoop += " SRA.RA_NSOCIAL, "
				cLoop += " SRA.RA_NOMECMP, "
				cLoop += " SRA.RA_ADMISSA, "
				cLoop += " SRA.RA_DEPTO, "
				cLoop += " RD4.RD4_ITEM, "
				cLoop += " RD4.RD4_TREE, "
				cLoop += " RD4.RD4_CHAVE, "
				cLoop += " RD4.RD4_EMPIDE, "
				cLoop += " SRA.RA_CC, "
				cLoop += " SRA.RA_CARGO, "
				cLoop += " SRA.RA_CODFUNC, "
				cLoop += " SRA.RA_SALARIO, "
				cLoop += " SRA.RA_CATFUNC, "
				cLoop += " SRA.RA_HRSMES, "
				cLoop += " SRA.RA_NASC, "
				cLoop += " SRA.RA_REGIME "
				cLoop += " FROM " + RetSqlName("RD4") + " RD4 "
				cLoop += " INNER JOIN " +  RetFullName("RCX",(cRD4Alias)->RD4_EMPIDE) + " RCX ON RCX.RCX_POSTO = RD4.RD4_CODIDE "
				cLoop += " INNER JOIN " +  RetFullName("SRA",(cRD4Alias)->RD4_EMPIDE) + " SRA ON RCX.RCX_FILFUN = SRA.RA_FILIAL	AND "
				cLoop += " RCX.RCX_MATFUN = SRA.RA_MAT "
				cLoop += " LEFT JOIN " +  RetFullName("RDZ",(cRD4Alias)->RD4_EMPIDE) + " RDZ  ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND "
				cLoop += " RDZ.RDZ_FILIAL = '"+xFilial("RDZ")+"'   AND "
				cLoop += " RDZ.RDZ_EMPENT = '"+(cRD4Alias)->RD4_EMPIDE+"'    AND "
				cLoop += " RDZ.D_E_L_E_T_ = ' ' "
				cLoop += " LEFT JOIN " +  RetFullName("RD0",(cRD4Alias)->RD4_EMPIDE) + " RD0  ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0   AND "
				cLoop += " RD0.RD0_FILIAL = '"+xFilial("RD0")+"'    AND "
				cLoop += " RD0.D_E_L_E_T_ = ' ' "
				cLoop += " WHERE SRA.RA_SITFOLH <> 'D'              AND "
				cLoop += " RCX.RCX_SUBST  = '2'				 AND "
				cLoop += " RCX.RCX_TIPOCU = '1'               AND "
				cLoop += " RCX.RCX_FILIAL = RD4.RD4_FILIDE     AND "
				cLoop += " RD4.RD4_TREE   = '"+cItem+"'       AND "
				cLoop += " RD4.RD4_CODIGO = '"+cVision+"'     AND "
				cLoop += " RD4.RD4_FILIAL = '"+xFilial("RD4")+"'     AND "
				cLoop += " RD4.RD4_EMPIDE='"+(cRD4Alias)->RD4_EMPIDE+"' AND "
				cLoop += " RD4.D_E_L_E_T_ = ' '                      AND "
				cLoop += " SRA.D_E_L_E_T_ = ' '                       AND "
				cLoop += " RCX.D_E_L_E_T_ = ' ' "
				cLoop += cWhere
				cLoop += " UNION "
				(cRD4Alias)->(dbSkip())
			EndDo 
			(cRD4Alias)->(dbCloseArea())
			
			If Right(cloop,7 )== " UNION "
				cLoop := substr(cLoop,1,len(cLoop)-7)
			EndIf
			cLoop += " ORDER BY RD4.RD4_CHAVE "
				
			
			cLoop := ChangeQuery(cLoop)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cLoop),cRD4Alias,.F.,.T.)
			
			
			COUNT TO nRecCount
			(cRD4Alias)->(DbGoTop())
			
			If !lMeuRH
				EmployeeData[1]:PagesTotal     := Ceiling(nRecCount / PAGE_LENGTH)
				If Page > 1
					nSkip := (Page-1) * PAGE_LENGTH
					For nLoopSkip := 1 to nSkip
						(cRD4Alias)->(DBSkip())
					Next nLoopSkip			
				EndIf
			Else
				EmployeeData[1]:PagesTotal := Ceiling(nRecCount / nPageSize)
				If nPage > 1
					nSkip := (nPage-1) * nPageSize
					For nLoopSkip := 1 to nSkip
						(cRD4Alias)->(DBSkip())
					Next nLoopSkip
				EndIf
			EndIf
			
			While (cRD4Alias)->( !Eof() ) .AND. If( !lMeuRH, Len(EmployeeData[1]:ListOfEmployee) <= PAGE_LENGTH, Len(EmployeeData[1]:ListOfEmployee) <= nPageSize .Or. lAllRegs )
					nFunc++
					nX++
					aAdd(EmployeeData[1]:ListOfEmployee,WsClassNew('DataEmployee'))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:EmployeeEmp       := (cRD4Alias)->RD4_EMPIDE
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:EmployeeFilial    := (cRD4Alias)->RA_FILIAL
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Registration  	:= (cRD4Alias)->RA_MAT
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:ParticipantID 	:= (cRD4Alias)->RD0_CODIGO
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Name          	:= AllTrim(if(! Empty((cRD4Alias)->RA_NOMECMP),(cRD4Alias)->RA_NOMECMP,If(!Empty((cRD4Alias)->RD0_NOME),(cRD4Alias)->RD0_NOME,(cRD4Alias)->RA_NOME)))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:SocialName      := AllTrim((cRD4Alias)->RA_NSOCIAL)
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:AdmissionDate 	:= DTOC(STOD((cRD4Alias)->RA_ADMISSA))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:BirthdayDate 	:= DTOC(STOD((cRD4Alias)->RA_NASC))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Department    	:= (cRD4Alias)->RA_DEPTO
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:DescrDepartment   := GetAnyDesc((cRD4Alias)->RD4_EMPIDE, (cRD4Alias)->RA_FILIAL, "SQB", (cRD4Alias)->RA_DEPTO)
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Item          	:= (cRD4Alias)->RD4_ITEM
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:SupFilial      	:= EmployeeData[1]:ListOfEmployee[1]:EmployeeFilial
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:SupRegistration	:= EmployeeData[1]:ListOfEmployee[1]:Registration
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:NameSup      	    := aRet[2]
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:KeyVision      	:= (cRD4Alias)->RD4_CHAVE
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:LevelHierar		:= (len(Alltrim((cRD4Alias)->RD4_CHAVE))/3)-1
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:TypeEmployee	    := "2"
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:LevelSup      	:= EmployeeData[1]:ListOfEmployee[1]:LevelHierar
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Situacao			:= (cRD4Alias)->RA_SITFOLH
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:DescSituacao		:= AllTrim(fDesc("SX5", "31" + (cRD4Alias)->RA_SITFOLH, "X5DESCRI()", NIL, (cRD4Alias)->RA_FILIAL))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:CostId			:= (cRD4Alias)->RA_CC
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Cost				:= Alltrim(Posicione('CTT',1,xFilial("CTT",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CC,'CTT->CTT_DESC01'))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FunctionId     	:= (cRD4Alias)->RA_CODFUNC
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FunctionDesc   	:= GetAnyDesc((cRD4Alias)->RD4_EMPIDE, (cRD4Alias)->RA_FILIAL, "SRJ", (cRD4Alias)->RA_CODFUNC)
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:PositionId      	:= (cRD4Alias)->RA_CARGO
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁBusca dados de substituto para gestao publica                   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cGSP == "3" // Gestao Publica - MP
						BEGINSQL alias cAuxAlias2
							SELECT SQ3.Q3_DESCSUM, SQ3.Q3_SUBSTIT
							FROM %table:SQ3% SQ3
							WHERE SQ3.Q3_FILIAL = %exp:xFilial("SQ3",cFilFunc)%                AND
							SQ3.Q3_CARGO  = %exp:(cRD4Alias)->RA_CARGO%   AND
							SQ3.%notDel%
						EndSql
						
						If !(cAuxAlias2)->(Eof())
							EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Position            	:= (cAuxAlias2)->Q3_DESCSUM
							If (cAuxAlias2)->Q3_SUBSTIT == '1'
								EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FunctionSubst   	:= .T.
							Else
								EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FunctionSubst   	:= .F.
							EndIf
						Else
							EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Position            	:= Alltrim(Posicione('SQ3',1,xFilial("SQ3",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CARGO,'SQ3->Q3_DESCSUM'))
							EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FunctionSubst       	:= .F.
						EndIf
						(cAuxAlias2)->(dbCloseArea())
					Else
						EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Position                	:= Alltrim(Posicione('SQ3',1,xFilial("SQ3",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CARGO,'SQ3->Q3_DESCSUM'))
						EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FunctionSubst           	:= .F.
					EndIf
					
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:Salary					   	:= (cRD4Alias)->RA_SALARIO
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:total       				:= nRecCount
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:FilialDescr				:= Alltrim(Posicione("SM0",1,cnumemp,"M0_FILIAL"))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:CatFunc		    			:= (cRD4Alias)->RA_CATFUNC
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:CatFuncDesc				:= Alltrim(FDESC("SX5","28"+(cRD4Alias)->RA_CATFUNC,"X5DESCRI()"))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:HoursMonth					:= Alltrim(Str((cRD4Alias)->RA_HRSMES))
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:ResultConsolid  			:= ''
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁVerificar se possui alguma solicitaГЦo de aumento de quadro para o funcionario de acordo com o tipo de requisicao (RequestType)Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:PossuiSolic 					:= .F.
					
					Do Case
					Case RequestType == "A" //Treinamento
						cCampoMat  := 'RA3_MAT'
					Case RequestType == "B" //Ferias
						cCampoMat  := 'R8_MAT'
					Case RequestType == "4" //Transferencia
						cCampoMat  := 'RE_MATD'
					Case RequestType == "6" //Desligamento
						cCampoMat  := 'RA_MAT'
					Case RequestType == "8" //Justificativa
						cCampoMat  := 'RF0_MAT'
					Case RequestType == "7" //Acao Salarial
						cCampoMat  := 'RB7_MAT'
					Case RequestType == "N" //Gestao Publica - alteracao de jornada
						cCampoMat  := 'PF_MAT'
					Case RequestType == "O" //Gestao Publica - Saldo de ferias
						cCampoMat  := 'RA_MAT'
					Case RequestType == "P" //Gestao Publica - programacao de ferias
						cCampoMat  := 'RA_MAT'
					Case RequestType == "Q" //Gestao Publica - diaria
						cCampoMat  := 'RA_MAT'
					Case RequestType == "R" //Gestao Publica - Licenca e afastamento
						cCampoMat  := 'RA_MAT'
					Case RequestType == "S" //Gestao Publica - Certidao Funcional
						cCampoMat  := 'RA_MAT'
					Case RequestType == "T" //Gestao Publica - dias de folga
						cCampoMat  := 'RA_MAT'
					Case RequestType == "V" //Solic subsМdio AcadЙmico
						cCampoMat  := 'RI1_MAT'
					OtherWise
						cCampoMat  := ''
					EndCase
					
					If cCampoMat != ''
						BeginSql alias cAuxAlias1
							SELECT
							RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH4.RH4_CAMPO, RH4.RH4_VALNOV
							FROM
							%table:RH3% RH3
							INNER JOIN %table:RH4% RH4
							ON 	RH3.RH3_FILIAL	= RH4.RH4_FILIAL AND
							RH3.RH3_CODIGO  = RH4.RH4_CODIGO
							WHERE
							RH4.RH4_CAMPO		= %exp:cCampoMat%			AND
							RH4.RH4_VALNOV 		= %exp:(cRD4Alias)->RA_MAT% AND
							RH3.RH3_STATUS 		in ('1', '4')    			AND
							RH3.RH3_TIPO 		= %exp:RequestType% 	AND
							RH4.%notDel%             				        AND
							RH3.%notDel%
						EndSql
						
						If !(cAuxAlias1)->(Eof())
							EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:PossuiSolic := .T.
						EndIf
						(cAuxAlias1)->(dbCloseArea())
					EndIf
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁVerificar se o funcionario listado no array possui equipe.      Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cChaveOrig := AllTrim((cRD4Alias)->RD4_CHAVE)
					cChaveComp := AllTrim((cRD4Alias)->RD4_CHAVE) + "%"
					
					BEGINSQL alias cAuxAlias1
						SELECT
						RD4.RD4_ITEM,
						RD4.RD4_TREE,
						RD4.RD4_CHAVE
						FROM %table:RD4% RD4
						WHERE RD4_CODIGO    = %exp:cVision%     AND
						RD4.RD4_CHAVE LIKE %exp:cChaveComp%  AND
						RD4.RD4_CHAVE <> %exp:cChaveOrig% AND
						RD4.%notDel%
					EndSql
					
					If !(cAuxAlias1)->(Eof())
						EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:PossuiEquipe := .T.
					Else
						EmployeeData[1]:ListOfEmployee[len(EmployeeData[1]:ListOfEmployee)]:PossuiEquipe := .F.
					EndIf
					(cAuxAlias1)->(dbCloseArea())
					
					If(valtype(PageLen)) == "C"
						PageLen = val(PageLen)
					EndIf
					
					If !lMeuRH .And. len(EmployeeData[1]:ListOfEmployee) >= PageLen .And. PageLen <> 0
						Exit
					EndIf
				(cRD4Alias)->( DbSkip() )
			EndDo
			If nFunc > nPageSize
				lMorePages := .T.
			EndIf
			(cRD4Alias)->( DbCloseArea() )
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDepartamento (com visao)                                        Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf TypeOrg == "2"
			
			cWhere := ""
			If !Empty(cFiltro) .AND. !Empty(cCampo)
				If(cCampo == "1")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁMatricula                                                       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_MAT LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "2")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁNome                                                            Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_NOME LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "3")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁAdmissao                                                        Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_ADMISSA LIKE '%" + Replace(dToS(cToD(cFiltro)),"'","") + "%'"
				ElseIf(cCampo == "4")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁDepartamento                                                    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_DEPTO LIKE '%" + Replace(cFiltro,"'","") + "%'"
				ElseIf(cCampo == "5")
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁSituacao                                                        Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cWhere += " AND SRA.RA_SITFOLH LIKE '%" + Replace(cFiltro,"'","") + "%'"
				EndIf
			EndIf
			If IDMENU == "GFP"
				cWhere += " AND SRA.RA_REGIME = '2'"  
			ElseIf IDMENU == "GCH"
				cWhere += " AND SRA.RA_REGIME <> '2'" 
			EndIf
			If lMeuRH .And. !lAllRegs
				cWhere += fMrhWhere(aQryParam, @lAllRegs, @nPage, @nPageSize)
			EndIf		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFaz validacao do modo de acesso do Departamento                                             Ё
			//ЁCompartilhado: nao faz filtro da filial do SRA e traz funcionarios do departamento          Ё
			//ЁExclusivo: faz filtro da filial do SRA de acordo com a filial do responsavel do departamentoЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Empty( xFilial("SQB") )
				cFilRD4 := "%%"
				cFilRD41 := ""
				cFilSQB := "%'" + xFilial("SQB") + "'%"
				cFilSQB1 :=  xFilial("SQB")
				cFilSRA := ""
			Else
				cFilRD4 := "%RD4.RD4_FILIDE = SQB.QB_FILIAL AND%"
				cFilRD41 := "RD4.RD4_FILIDE = SQB.QB_FILIAL AND"
				cFilSQB  := "%'" + xFilial( 'SQB', aRet[3] ) + "'%"
				cFilSQB1 := xFilial( 'SQB', aRet[3] ) 
				cFilSRA  := FWJoinFilial( "SRA", "SQB" ) + " AND"
				cFilSRA  := StrTran(cFilSRA, "SQB.QB_FILIAL", "RD4.RD4_FILIDE")
			EndIf
						
			//Filial do superior
			cSra	:= "%"+ RetFullName("SRA",cEmpAnt)+"%"	
			cSqb	:= "%"+RetFullName("SQB",cEmpAnt)+"%"	
			cRdz	:= "%"+RetFullName("RDZ",cEmpAnt)+"%"	
			cRd0	:= "%"+RetFullName("RD0",cEmpAnt)+"%"
						
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁBusca as chaves dos departamentso que o funcionario e' responsavel para verificar           Ё
			//Ёtodos os departamentos abaixo do nivel hierarquico da chave                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			
			If SQB->(ColumnPos("QB_EMPRESP")) > 0
			
				cQuery := fMontaQry(cVision,aRet[3],aRet[1],cFilRD4,aListEmp)
				BeginSQL ALIAS cRD4Alias
					SELECT %exp:cQuery%
				EndSQL
			
			Else
				BeginSQL ALIAS cRD4Alias
					SELECT RD4.RD4_CHAVE, RD4.RD4_ITEM, RD4_TREE, RD4.RD4_EMPIDE
					FROM %Exp:cSqb% SQB
					INNER JOIN %table:RD4% RD4 ON %exp:cFilRD4% RD4.RD4_CODIDE = SQB.QB_DEPTO
					WHERE RD4.RD4_FILIAL = %xfilial:RD4% AND
					RD4.RD4_CODIGO = %exp:cVision% AND			
					SQB.QB_FILRESP = %exp:aRet[3]% 	AND
					SQB.QB_MATRESP = %exp:aRet[1]% 	AND
					RD4.%notDel%                   AND
					SQB.%notDel%
				EndSQL
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁMonta o filtro da instrucao Like de todos os departamentos que o funcionario e' o responsavelЁ
			//ЁSe nao for responsavel por nenhum, nao ira trazer de nenhum departamento                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aChvTree := {}
			While (cRD4Alias)->( !Eof() )
				//Valida se a empresa logada И a mesma do responsАvel pelo Departamento
				If cEmpAnt == (cRD4Alias)->QB_EMPRESP .Or. Empty((cRD4Alias)->QB_EMPRESP) 
					If aScan(aEmpEquip, { |x| x == (cRD4Alias)->RD4_EMPIDE }) == 0
						aAdd(aEmpEquip, (cRD4Alias)->RD4_EMPIDE)
					EndIf
					If Empty(cKeyVision)
						If aScan( aChvItem, { |aChvItem| aChvItem[1] == AllTrim( (cRD4Alias)->RD4_ITEM ) } ) == 0
							aAdd( aChvItem, { AllTrim( (cRD4Alias)->RD4_ITEM ),(cRD4Alias)->RD4_CHAVE   } )
							lQryResp	:= .T.
						EndIf
					Else
						If (Substr(cKeyVision,1,Len(cKeyVision)-3) $ (cRD4Alias)->RD4_CHAVE) .AND. ( aScan( aChvItem, { |aChvItem| aChvItem[1] == AllTrim( (cRD4Alias)->RD4_ITEM ) } ) == 0 )
							aAdd( aChvItem, { AllTrim( (cRD4Alias)->RD4_ITEM ),(cRD4Alias)->RD4_CHAVE   } )
							lQryResp	:= .T.
						EndIf
					EndIf
				EndIf
				(cRD4Alias)->( dbSkip() )
			End While
			If lQryResp
				cChaveItem := " RD4.RD4_ITEM IN ("
				For nPosItem := 1 To Len(aChvItem)
					cChaveItem += "'" + aChvItem[nPosItem, 1] + "' ,"
				Next nPosItem
				cChaveItem := SubStr( cChaveItem, 1, Len(cChaveItem) - 2 )
				cChaveItem += ") "
			Else
				cChaveItem := " RD4.RD4_ITEM = 'ZZZZZZ' "
			EndIf
			(cRD4Alias)->( dbCloseArea() )
			cWhe := "%" + cChaveItem + "%"	
			cWhe := Replace(cWhe,"RD4_ITEM","RD4_TREE")
			cRD4Alias := GetNextAlias()
			BeginSQL ALIAS cRD4Alias
				SELECT DISTINCT RD4_EMPIDE
				FROM %table:RD4% RD4 
				WHERE RD4.RD4_FILIAL = %xfilial:RD4% 
				AND	RD4.RD4_CODIGO = %exp:cVision%
				AND	RD4.%notDel%       
				AND %exp:cWhe%            
			EndSQL
			
			cWhe := Replace(cChaveItem,"RD4_ITEM","RD4_TREE")
			
			cLoop := ""
			While !(cRD4Alias)->(Eof())
				cLoop += "SELECT RD4.RD4_EMPIDE,"
				cLoop += "SRA.RA_SITFOLH,"
				cLoop += "SRA.RA_FILIAL,"
				cLoop += "SRA.RA_MAT,"
				cLoop += "RD0.RD0_NOME,"
				cLoop += "RD0.RD0_CODIGO,"
				cLoop += "SRA.RA_NOME,"
				cLoop += "SRA.RA_NOMECMP, "
				cLoop += "SRA.RA_NSOCIAL, "
				cLoop += "SRA.RA_ADMISSA,"
				cLoop += "SRA.RA_DEPTO,"
				cLoop += "RD4.RD4_ITEM,"
				cLoop += "RD4.RD4_TREE,"
				cLoop += "RD4.RD4_CHAVE,"
				cLoop += "RD4.RD4_EMPIDE,"
				cLoop += "SRA.RA_CC,"
				cLoop += "SRA.RA_CARGO,"
				cLoop += "SRA.RA_CODFUNC,"
				cLoop += "SRA.RA_SALARIO,"
				cLoop += "SRA.RA_CATFUNC,"
				cLoop += "SRA.RA_HRSMES,"
				cLoop += "SRA.RA_NASC, "
				cLoop += "SRA.RA_REGIME"
				cLoop += "FROM "+ RetFullName("SQB",(cRD4Alias)->RD4_EMPIDE) + " SQB "
				cLoop += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON RD4.RD4_EMPIDE = '"+(cRD4Alias)->RD4_EMPIDE+"' AND SQB.QB_FILIAL = RD4.RD4_FILIDE AND "
				cLoop += "RD4.RD4_CODIDE = SQB.QB_DEPTO "
				cLoop += "INNER JOIN "+ RetFullName("SRA",(cRD4Alias)->RD4_EMPIDE) + " SRA ON SRA.RA_FILIAL = SQB.QB_FILRESP AND "
				cLoop += "SRA.RA_MAT = SQB.QB_MATRESP "
				cLoop += "LEFT JOIN "+ RetFullName("RDZ",(cRD4Alias)->RD4_EMPIDE) + " RDZ ON RDZ.RDZ_EMPENT = '"+(cRD4Alias)->RD4_EMPIDE + "' AND "
				cLoop += "RDZ.RDZ_FILIAL = '"+xFilial("RDZ")+"' AND "
				cLoop += "RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND "
				cLoop += "RDZ.D_E_L_E_T_ = '' "
				cLoop += "LEFT JOIN "+ RetFullName("RD0",(cRD4Alias)->RD4_EMPIDE)	+" RD0 ON RD0.RD0_FILIAL = '"+xFilial("RD0")+"' AND "
				cLoop += "RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 AND "
				cLoop += "RD0.D_E_L_E_T_ = '' "
				cLoop += "WHERE RD4.RD4_FILIAL = '"+xFilial("RD4")+"' AND "
				cLoop += "RD4.RD4_CODIGO = '"+cVision+"' AND "
							cLoop += cWhe + " AND "			
				cLoop += "SRA.RA_SITFOLH <> 'D'	AND "
				cLoop += "SRA.D_E_L_E_T_ = '' AND "
				cLoop += "RD4.D_E_L_E_T_ = '' AND "
				cLoop += "SQB.D_E_L_E_T_ = '' "
				cLoop += "UNION "	
				(cRD4Alias)->(dbSkip())
			EndDo	
			(cRD4Alias)->( dbCloseArea() )							                       
			
			If !Empty(aEmpEquip)
				For nI := 1 To Len(aEmpEquip)
					cSqb	:= RetFullName("SQB",aEmpEquip[nI])
					cSra	:= RetFullName("SRA",aEmpEquip[nI])	
					cRdz	:= RetFullName("RDZ",aEmpEquip[nI])	
					cRd0	:= RetFullName("RD0",aEmpEquip[nI])
					
					If nI <> 1
						cLoop += "UNION "	
					EndIf
				
					cLoop += "SELECT RD4.RD4_EMPIDE,"
					cLoop += "SRA.RA_SITFOLH,"
					cLoop += "SRA.RA_FILIAL,"
					cLoop += "SRA.RA_MAT,"
					cLoop += "RD0.RD0_NOME,"
					cLoop += "RD0.RD0_CODIGO,"
					cLoop += "SRA.RA_NOME,"
					cLoop += "SRA.RA_NOMECMP,"
					cLoop += "SRA.RA_NSOCIAL,"
					cLoop += "SRA.RA_ADMISSA,"
					cLoop += "SRA.RA_DEPTO,"
					cLoop += "RD4.RD4_ITEM,"
					cLoop += "RD4.RD4_TREE,"
					cLoop += "RD4.RD4_CHAVE,"
					cLoop += "RD4.RD4_EMPIDE,"
					cLoop += "SRA.RA_CC,"
					cLoop += "SRA.RA_CARGO,"
					cLoop += "SRA.RA_CODFUNC,"
					cLoop += "SRA.RA_SALARIO,"
					cLoop += "SRA.RA_CATFUNC," 
					cLoop += "SRA.RA_HRSMES,"
					cLoop += "SRA.RA_NASC, "
					cLoop += "SRA.RA_REGIME"
					cLoop += "FROM" + RetSqlName("RD4") + " RD4 "
					cLoop += "INNER JOIN " + cSra + " SRA ON " + cFilSRA
					cLoop += "	SRA.RA_DEPTO = RD4.RD4_CODIDE "
					cLoop += "LEFT JOIN " + cRdz + " RDZ ON RDZ.RDZ_EMPENT = '" + aEmpEquip[nI] +"' AND "
					cLoop += "RDZ.RDZ_FILIAL = '"+xFilial("RDZ")+"' AND "
					cLoop += "RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND "
					cLoop += "RDZ.D_E_L_E_T_ = '' "
					cLoop += "LEFT JOIN " + cRd0 + " RD0 ON RD0.RD0_FILIAL = '"+xFilial("RD0")+"' AND "
					cLoop += "RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 AND "
					cLoop += "RD0.D_E_L_E_T_ = '' "
					cLoop += "WHERE RD4.RD4_FILIAL = '"+xFilial("RD4")+"' AND "
					cLoop += "RD4.RD4_CODIGO = '" + cVision + "' AND "
					cLoop += "RD4.RD4_EMPIDE = '" + aEmpEquip[nI] + "' AND "
					cLoop += cChaveItem + " AND "
					cLoop += "SRA.RA_SITFOLH <> 'D'	AND "
					cLoop += "	SRA.D_E_L_E_T_ = '' AND "
					cLoop += "	RD4.D_E_L_E_T_ = '' "
					cLoop += cWhere
				Next nI
			Else
				cSqb	:= RetFullName("SQB",cEmpAnt)
				cSra	:= RetFullName("SRA",cEmpAnt)	
				cRdz	:= RetFullName("RDZ",cEmpAnt)	
				cRd0	:= RetFullName("RD0",cEmpAnt)

				cLoop += "SELECT RD4.RD4_EMPIDE,"
				cLoop += "SRA.RA_SITFOLH,"
				cLoop += "SRA.RA_FILIAL,"
				cLoop += "SRA.RA_MAT,"
				cLoop += "RD0.RD0_NOME,"
				cLoop += "RD0.RD0_CODIGO,"
				cLoop += "SRA.RA_NOME,"
				cLoop += "SRA.RA_NOMECMP,"
				cLoop += "SRA.RA_NSOCIAL,"
				cLoop += "SRA.RA_ADMISSA,"
				cLoop += "SRA.RA_DEPTO,"
				cLoop += "RD4.RD4_ITEM,"
				cLoop += "RD4.RD4_TREE,"
				cLoop += "RD4.RD4_CHAVE,"
				cLoop += "RD4.RD4_EMPIDE,"
				cLoop += "SRA.RA_CC,"
				cLoop += "SRA.RA_CARGO,"
				cLoop += "SRA.RA_CODFUNC,"
				cLoop += "SRA.RA_SALARIO,"
				cLoop += "SRA.RA_CATFUNC," 
				cLoop += "SRA.RA_HRSMES,"
				cLoop += "SRA.RA_NASC, "
				cLoop += "SRA.RA_REGIME"
				cLoop += "FROM" + RetSqlName("RD4") + " RD4 "
				cLoop += "INNER JOIN " + cSra + " SRA ON " + cFilSRA
				cLoop += "	SRA.RA_DEPTO = RD4.RD4_CODIDE "
				cLoop += "LEFT JOIN " + cRdz + " RDZ ON RDZ.RDZ_EMPENT = '" + cEmpSM0 +"' AND "
				cLoop += "RDZ.RDZ_FILIAL = '"+xFilial("RDZ")+"' AND "
				cLoop += "RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND "
				cLoop += "RDZ.D_E_L_E_T_ = '' "
				cLoop += "LEFT JOIN " + cRd0 + " RD0 ON RD0.RD0_FILIAL = '"+xFilial("RD0")+"' AND "
				cLoop += "RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 AND "
				cLoop += "RD0.D_E_L_E_T_ = '' "
				cLoop += "WHERE RD4.RD4_FILIAL = '"+xFilial("RD4")+"' AND "
				cLoop += "RD4.RD4_CODIGO = '" + cVision + "' AND "
				cLoop += cChaveItem + " AND "
				cLoop += "SRA.RA_SITFOLH <> 'D'	AND "
				cLoop += "	SRA.D_E_L_E_T_ = '' AND "
				cLoop += "	RD4.D_E_L_E_T_ = '' "
				cLoop += cWhere
			EndIf
			
			cLoop := ChangeQuery(cLoop)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cLoop),cRD4Alias,.F.,.T.)
		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁSelecionar todos os departamentos que o funcionario logado И responsАvelЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

			COUNT TO nRecCount
			(cRD4Alias)->(DbGoTop())
			
			If !lMeuRH
				EmployeeData[1]:PagesTotal     := Ceiling(nRecCount / PAGE_LENGTH)
				If Page > 1
					nSkip := (Page-1) * PAGE_LENGTH
					For nLoopSkip := 1 to nSkip
						(cRD4Alias)->(DBSkip())
					Next nLoopSkip
				EndIf
			Else
				EmployeeData[1]:PagesTotal := Ceiling(nRecCount / nPageSize)
				If nPage > 1
					nSkip := (nPage-1) * nPageSize
					For nLoopSkip := 1 to nSkip
						(cRD4Alias)->(DBSkip())
					Next nLoopSkip
				EndIf
			EndIf
			
		
			While (cRD4Alias)->( !Eof() ) .AND.	If( !lMeuRH, Len(EmployeeData[1]:ListOfEmployee) <= PAGE_LENGTH, Len(EmployeeData[1]:ListOfEmployee) <= nPageSize .Or. lAllRegs )
				If (cRD4Alias)->RA_FILIAL + (cRD4Alias)->RA_MAT <> aRet[3] + aRet[1]
					If aScan( EmployeeData[1]:ListOfEmployee, {|x| AllTrim( x:EmployeeEmp ) == AllTrim( (cRD4Alias)->RD4_EMPIDE ) .And. AllTrim( x:EmployeeFilial ) == AllTrim( (cRD4Alias)->RA_FILIAL ) .And. AllTrim( x:Registration ) == AllTrim( (cRD4Alias)->RA_MAT ) } ) == 0
						nX++
						nFunc++
						aadd(EmployeeData[1]:ListOfEmployee,WsClassNew('DataEmployee'))
						EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeEmp	  	:= (cRD4Alias)->RD4_EMPIDE
						EmployeeData[1]:ListOfEmployee[nFunc]:EmployeeFilial  	:= (cRD4Alias)->RA_FILIAL
						EmployeeData[1]:ListOfEmployee[nFunc]:Registration  		:= (cRD4Alias)->RA_MAT
						EmployeeData[1]:ListOfEmployee[nFunc]:ParticipantID  	:= (cRD4Alias)->RD0_CODIGO
						EmployeeData[1]:ListOfEmployee[nFunc]:Name          		:= AllTrim(substr(if(!Empty((cRD4Alias)->RD0_NOME),(cRD4Alias)->RD0_NOME,If(!Empty((cRD4Alias)->RA_NOME),(cRD4Alias)->RA_NOME,"")),1,28))
						EmployeeData[1]:ListOfEmployee[nFunc]:SocialName          	:= AllTrim((cRD4Alias)->RA_NSOCIAL)
						EmployeeData[1]:ListOfEmployee[nFunc]:AdmissionDate 		:= DTOC(STOD((cRD4Alias)->RA_ADMISSA))
						EmployeeData[1]:ListOfEmployee[nFunc]:BirthdayDate 		:= DTOC(STOD((cRD4Alias)->RA_NASC))
						EmployeeData[1]:ListOfEmployee[nFunc]:Department    		:= (cRD4Alias)->RA_DEPTO
						EmployeeData[1]:ListOfEmployee[nFunc]:DescrDepartment   	:= GetAnyDesc((cRD4Alias)->RD4_EMPIDE, (cRD4Alias)->RA_FILIAL, "SQB", (cRD4Alias)->RA_DEPTO)
						EmployeeData[1]:ListOfEmployee[nFunc]:Item          		:= (cRD4Alias)->RD4_ITEM
						EmployeeData[1]:ListOfEmployee[nFunc]:SupFilial      	:= EmployeeData[1]:ListOfEmployee[1]:EmployeeFilial
						EmployeeData[1]:ListOfEmployee[nFunc]:SupRegistration	:= EmployeeData[1]:ListOfEmployee[1]:Registration
						EmployeeData[1]:ListOfEmployee[nFunc]:NameSup      		:= aRet[2]
						EmployeeData[1]:ListOfEmployee[nFunc]:KeyVision       	:= (cRD4Alias)->RD4_CHAVE
						EmployeeData[1]:ListOfEmployee[nFunc]:LevelHierar		:= (len(Alltrim((cRD4Alias)->RD4_CHAVE))/3)-1
						EmployeeData[1]:ListOfEmployee[nFunc]:TypeEmployee		:= "2"
						EmployeeData[1]:ListOfEmployee[nFunc]:LevelSup      		:= EmployeeData[1]:ListOfEmployee[1]:LevelHierar
						EmployeeData[1]:ListOfEmployee[nFunc]:Situacao			:= (cRD4Alias)->RA_SITFOLH
						EmployeeData[1]:ListOfEmployee[nFunc]:DescSituacao		:= AllTrim(fDesc("SX5", "31" + (cRD4Alias)->RA_SITFOLH, "X5DESCRI()", NIL, (cRD4Alias)->RA_FILIAL))
						EmployeeData[1]:ListOfEmployee[nFunc]:CostId				:= (cRD4Alias)->RA_CC
						EmployeeData[1]:ListOfEmployee[nFunc]:Cost				:= Alltrim(Posicione('CTT',1,xFilial("CTT",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CC,'CTT->CTT_DESC01'))
						EmployeeData[1]:ListOfEmployee[nFunc]:FunctionId       	:= (cRD4Alias)->RA_CODFUNC
						EmployeeData[1]:ListOfEmployee[nFunc]:FunctionDesc     	:= GetAnyDesc((cRD4Alias)->RD4_EMPIDE, (cRD4Alias)->RA_FILIAL, "SRJ", (cRD4Alias)->RA_CODFUNC) 
						EmployeeData[1]:ListOfEmployee[nFunc]:PositionId     	:= (cRD4Alias)->RA_CARGO
						If !cGSP == "1"
							EmployeeData[1]:ListOfEmployee[nFunc]:Polity	     	:= (cRD4Alias)->RA_REGIME	
						EndIf
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//ЁBusca dados de substituto para gestao publica                           Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If cGSP == "3" // Gestao Publica - MP
							BEGINSQL alias cAuxAlias2
								SELECT SQ3.Q3_DESCSUM, SQ3.Q3_SUBSTIT
								FROM %table:SQ3% SQ3
								WHERE SQ3.Q3_FILIAL = %xfilial:SQ3%          AND
								SQ3.Q3_CARGO  = %exp:(cRD4Alias)->RA_CARGO%   AND
								SQ3.%notDel%
							EndSql
							
							If !(cAuxAlias2)->(Eof())
								EmployeeData[1]:ListOfEmployee[nFunc]:Position            := (cAuxAlias2)->Q3_DESCSUM
								If (cAuxAlias2)->Q3_SUBSTIT == '1'
									EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst   := .T.
								Else
									EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst   := .F.
								EndIf
							Else
								EmployeeData[1]:ListOfEmployee[nFunc]:Position            := Alltrim(Posicione('SQ3',1,xFilial("SQ3",(cRD4Alias)->RA_FILIAL)+(cRD4Alias)->RA_CARGO,'SQ3->Q3_DESCSUM'))
								EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst       := .F.
							EndIf
							(cAuxAlias2)->(dbCloseArea())
						Else
							EmployeeData[1]:ListOfEmployee[nFunc]:Position                := GetAnyDesc((cRD4Alias)->RD4_EMPIDE, (cRD4Alias)->RA_FILIAL, "SQ3", (cRD4Alias)->RA_CARGO) //Alltrim(Posicione('SQ3',1,xFilial("SQ3")+(cRD4Alias)->RA_CARGO,'SQ3->Q3_DESCSUM'))
							EmployeeData[1]:ListOfEmployee[nFunc]:FunctionSubst           := .F.
						EndIf
						EmployeeData[1]:ListOfEmployee[nFunc]:Salary			:= (cRD4Alias)->RA_SALARIO
						EmployeeData[1]:ListOfEmployee[nFunc]:total          := 1
						EmployeeData[1]:ListOfEmployee[nFunc]:FilialDescr		:= Alltrim(Posicione("SM0",1,cnumemp,"M0_FILIAL"))
						EmployeeData[1]:ListOfEmployee[nFunc]:CatFunc			:= (cRD4Alias)->RA_CATFUNC
						EmployeeData[1]:ListOfEmployee[nFunc]:CatFuncDesc		:= Alltrim(FDESC("SX5","28"+(cRD4Alias)->RA_CATFUNC,"X5DESCRI()"))
						EmployeeData[1]:ListOfEmployee[nFunc]:HoursMonth		:= Alltrim(Str((cRD4Alias)->RA_HRSMES))
						EmployeeData[1]:ListOfEmployee[nFunc]:ResultConsolid	:= ''
						If !cGSP == "1"
							EmployeeData[1]:ListOfEmployee[nFunc]:Polity			:= (cRD4Alias)->RA_REGIME																			
						EndIf
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//ЁVerificar se possui alguma solicitacao para o funcionario de acordo com o tipo de requisicao(RequestType) Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						EmployeeData[1]:ListOfEmployee[nFunc]:PossuiSolic 	:= .F.
						
						
						If SQB->(ColumnPos("QB_EMPRESP")) > 0
							
							cQry 	:= ""
							For nI:=1 To Len(aListEmp)
								
								If !Empty(cQry)
									cQry += " UNION SELECT"
								EndIf
								
								cQry += " RD4.RD4_ITEM "
								cQry += " FROM " + RetFullName("SQB",aListEmp[nI]) + " SQB"
								cQry += " INNER JOIN " + RetFullName("RD4",aListEmp[nI]) + " RD4 ON RD4.RD4_CODIDE = SQB.QB_DEPTO "
								cQry += " WHERE RD4.RD4_CODIGO = '" + cVision + "' AND "
								cQry += " RD4.RD4_FILIAL = '" + xFilial("RD4") + "' AND "
								cQry += " RD4.RD4_FILIDE = SQB.QB_FILIAL AND "
								cQry += " SQB.QB_FILRESP = '" + (cRD4Alias)->RA_FILIAL + "' 	AND "
								cQry += " SQB.QB_MATRESP = '" + (cRD4Alias)->RA_MAT + "' 	AND "
								cQry += " RD4.D_E_L_E_T_ = ' ' AND"
								cQry += " SQB.D_E_L_E_T_ = ' ' "
							Next nI
							
							cQry := "%" + cQry + "%"
							
							BeginSQL ALIAS cAuxAlias1
								SELECT %exp:cQry%
							EndSQL
							
						Else
							If !Empty((cRD4Alias)->RD4_EMPIDE)	
								cSqb1	:= "%"+RetFullName("SQB",(cRD4Alias)->RD4_EMPIDE)+"%"
							Else
								cSqb1	:= "%"+RetFullName("SQB",cEmpAnt)+"%"
							EndIf
							
							//Busca as chaves dos departamentso que o funcionario e' responsavel para verificar
							//todos os departamentos abaixo do nivel hierarquico da chave
							BeginSQL ALIAS cAuxAlias1
								SELECT RD4.RD4_ITEM
								FROM %Exp:cSqb1% SQB
								INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = SQB.QB_DEPTO
								WHERE RD4.RD4_CODIGO = %exp:cVision% AND
								RD4.RD4_FILIAL = %xfilial:RD4% AND
								RD4.RD4_FILIDE = SQB.QB_FILIAL AND
								SQB.QB_FILRESP = %exp:(cRD4Alias)->RA_FILIAL% 	AND
								SQB.QB_MATRESP = %exp:(cRD4Alias)->RA_MAT% 	AND
								RD4.%notDel% AND
								SQB.%notDel%
							EndSQL
						
						EndIf
						
						If !(cAuxAlias1)->(Eof())
							EmployeeData[1]:ListOfEmployee[nFunc]:PossuiEquipe := .T.
						Else
							EmployeeData[1]:ListOfEmployee[nFunc]:PossuiEquipe := .F.
						EndIf
						(cAuxAlias1)->(dbCloseArea())
						
						Do Case
						Case RequestType == "A" //Treinamento
							cCampoMat  := 'RA3_MAT'
						Case RequestType == "B" //Ferias
							cCampoMat  := 'R8_MAT'
						Case RequestType == "4" //Transferencia
							cCampoMat  := 'RE_MATD'
						Case RequestType == "6" //Desligamento
							cCampoMat  := 'RA_MAT'
						Case RequestType == "8" //Justificativa
							cCampoMat  := 'RF0_MAT'
						Case RequestType == "7" //Acao Salarial
							cCampoMat  := 'RB7_MAT'
						Case RequestType == "N" //Gestao Publica - alteracao de jornada
							cCampoMat  := 'PF_MAT'
						Case RequestType == "O" //Gestao Publica - Saldo de ferias
							cCampoMat  := 'RA_MAT'
						Case RequestType == "P" //Gestao Publica - programacao de ferias
							cCampoMat  := 'RA_MAT'
						Case RequestType == "Q" //Gestao Publica - diaria
							cCampoMat  := 'RA_MAT'
						Case RequestType == "R" //Gestao Publica - Licenca e afastamento
							cCampoMat  := 'RA_MAT'
						Case RequestType == "S" //Gestao Publica - Certidao Funcional
							cCampoMat  := 'RA_MAT'
						Case RequestType == "T" //Gestao Publica - dias de folga
							cCampoMat  := 'RA_MAT'
						Case RequestType == "V" //Solic SubsМdio AcadЙmico
							cCampoMat  := 'RI1_MAT'
						OtherWise
							cCampoMat  := ''
						EndCase
						
						If cCampoMat != ''
							BeginSql alias cAuxAlias1
								SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH4.RH4_CAMPO, RH4.RH4_VALNOV
								FROM  %table:RH3% RH3
								INNER JOIN %table:RH4% RH4
								ON 	RH3.RH3_FILIAL = RH4.RH4_FILIAL AND
								RH3.RH3_CODIGO = RH4.RH4_CODIGO
								WHERE
								RH4.RH4_CAMPO      = %exp:cCampoMat%			AND
								RH4.RH4_VALNOV     = %exp:(cRD4Alias)->RA_MAT%	AND
								RH3.RH3_STATUS    in ('1', '4')    				AND
								RH3.RH3_TIPO       = %exp:RequestType% 	AND
								RH4.%notDel%             				    	AND
								RH3.%notDel%
							EndSql
							
							If !(cAuxAlias1)->(Eof())
								EmployeeData[1]:ListOfEmployee[nFunc]:PossuiSolic := .T.
							EndIf
							(cAuxAlias1)->(dbCloseArea())
						EndIf

						If(valtype(PageLen)) == "C"
							PageLen = val(PageLen)
						EndIf
						
						If !lMeuRH .And. len(EmployeeData[1]:ListOfEmployee) >= PageLen .And. PageLen <> 0
							Exit
						EndIf
					EndIf
				EndIf
				(cRD4Alias)->( DbSkip() )
			EndDo
			If nFunc > nPageSize
				lMorePages := .T.
			EndIf
			(cRD4Alias)->( DbCloseArea() )
		EndIf
	EndIf

Else
	EmployeeData := {}
	Aadd(EmployeeData,.F.)
	Aadd(EmployeeData,"GetStructure3")
	Aadd(EmployeeData,PorEncode(STR0004))	 //"Visao nЦo encontrada"
	
	// Restaura dados da empresa logada apСs troca de empresa
	If lTrocou
		ChangeEmp(aAliasNewEmp, __cEmpAnt, __cFilAnt)
	EndIf
	RestArea( aAreaSM0 )	
	
	Return(EmployeeData)
EndIf

// Restaura dados da empresa logada apСs troca de empresa
If lTrocou
	ChangeEmp(aAliasNewEmp, __cEmpAnt, __cFilAnt)
EndIf
RestArea( aAreaSM0 )	
	
Return( EmployeeData )

/*/{Protheus.doc} fOpenSx2
FunГЦo para abrir a SX2 de outra empresa
@author Rafael Reis
@since 29/12/2017
/*/
Static Function fOpenSx2(cEmp)
	Local lOk	:=	.T.

	SX2->(DBCloseArea())
	OpenSxs(,,,,cEmp,"SX2","SX2",,.F.)
	If Select("SX2") == 0
		lOk := .F.
	Endif

Return lOk

/*
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁMyEmpOpenFile Ё Autor ЁWilson de Godoy        Ё Data Ё03/01/2001Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁAbre Arquivo de Outra Empresa                         			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁx1 - Alias com o Qual o Arquivo Sera Aberto                  	Ё
Ё          Ёx2 - Alias do Arquivo Para Pesquisa e Comparacao                Ё
Ё          Ёx3 - Ordem do Arquivo a Ser Aberto                              Ё
Ё          Ёx4 - .T. Abre e .F. Fecha                                       Ё
Ё          Ёx5 - Empresa                                                    Ё
Ё          Ёx6 - Modo de Acesso (Passar por Referencia)                     Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MyEmpOpenFile(x1,x2,x3,x4,x5,x6)
Local cSavE := cEmpAnt
Local cSavF := cFilAnt
Local xRet

cEmpAnt := __cEmpAnt
cFilAnt := __cFilAnt
xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF
Return( xRet )


/*/{Protheus.doc} ChangeEmp
//TODO Muda a empresa.
@author martins.marcio
@since 17/06/2019
@version 1.0
@return ${return}, ${return_description}
@param aAliasNewEmp, array, descricao
@param cEmp, characters, Empresa de Destino
@param cFil, characters, Filial de Destino
@type function
/*/
Function ChangeEmp(aAliasNewEmp, cEmp, cFil)
	Local nAT
	Local nX		:= 0
	Local cModo 	:= ""
	Local cAliaAux	:= ""

	If Valtype(__cEmpAnt) <> "U" .and. !empty(__cEmpAnt)

		IF cEmp+cFil != __cLastEmp

			If (ValType(aAliasNewEmp) == "A" )
				fOpenSx2(cEmp)
				FWClearXFilialCache()

				For nX := 1 to Len(aAliasNewEmp)
					cAliaAux:= aAliasNewEmp[nX]

					IF cEmp != SubStr(__cLastEmp,1,2)
						UniqueKey( NIL , cAliaAux , .T. )
						MyEmpOpenFile(cAliaAux,cAliaAux,1,.t.,cEmp,@cModo)
						aAdd( aTabCompany, cAliaAux )
						If !lCorpManage
							nAT := AT(cAliaAux,cArqTab)
							IF nAT > 0
								cArqTab := SubStr(cArqTab,1,nAT+2)+cModo+SubStr(cArqTab,nAT+4)
							Else
								cArqTab += cAliaAux+cModo+"/"
							EndIF
						EndIf
					EndIF
					
					ChkFile(cAliaAux)

				Next Nx
				cEmpAnt := cEmp
				cFilAnt := cFil

				__cLastEmp := cEmp+cFil
				__cLastData:= cAliaAux

			Endif
		Endif
	EndIF
Return( .T. )

/*/{Protheus.doc} CloseOtherTb
//TODO Fecha tabelas abertas em outras empresas.
@author martins.marcio
@since 17/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function CloseOtherTb()

Local nX := 0

// Fechar as tabelas abertas para outra empresa
If !Empty(aTabCompany)
	For nX := 1 To Len(aTabCompany)
		If Select(aTabCompany[nX]) > 0
			(aTabCompany[nX])->(DbCloseArea())
		EndIf
	Next nX
	aSize(aTabCompany,0)
EndIf

Return


/*/{Protheus.doc} fMontaQry
//TODO DescriГЦo auto-gerada.
@author martins.marcio
@since 22/07/2019
@version 1.0
@return ${return}, ${return_description}
@param cVision, characters, Visao
@param cFilResp, characters, Filial do Responsavel
@param cMatResp, characters, Matricula do responsАvel
@type function
/*/
Static Function fMontaQry(cVision,cFilResp,cMatResp,cFilRD4,aListEmp)

Local nI := 0
Local cQuery := ""
Local lEmpResp	:= .T. // Se existe o campo QB_EMPRESP
Local aAliasNewEmp	:= {"SRA","RDZ","RD0","SQB","CTT","SRJ","SQ3"}
Local lTrocou := .F.
Local aAreaSM0	:= SM0->(GetArea())

// Variaveis para a funГЦo ChangeEmp
Private __cLastEmp 	:= ""
Private __cLastData	:= ""
Private __cEmpAnt	:= cEmpAnt
Private __cFilAnt	:= cFilAnt
Private __cArqTab	:= cArqTab
Private aTabCompany := {}
Private lCorpManage := fIsCorpManage()

DEFAULT aListEmp := FWAllGrpCompany()

DbSelectArea("SQB")
lEmpResp := SQB->(ColumnPos("QB_EMPRESP")) > 0

cFilRD4 := StrTran(cFilRD4,"%","")

For nI := 1 To Len(aListEmp)

	// Verifica se o campo QB_EMPRESP existe no grupo de empresa aListEmp[nI]
	If  aListEmp[nI] <> cEmpAnt
		If SM0->(DbSeek(aListEmp[nI]))
			lTrocou := ChangeEmp(aAliasNewEmp, SM0->M0_CODIGO, SM0->M0_CODFIL)
		EndIf
		lEmpResp := SQB->(ColumnPos("QB_EMPRESP")) > 0
		// Se o campo QB_EMPRESP nЦo existir, descarta Unions com outros grupos de empresa
		If !lEmpResp
			CloseOtherTb()
			LOOP
		EndIf	
	EndIf

	If !Empty(cQuery)
		cQuery += " UNION SELECT"
	EndIf
	
	cQuery += " RD4.RD4_CHAVE, RD4.RD4_ITEM, RD4_TREE, RD4.RD4_EMPIDE"
	If lEmpResp	
		cQuery += ",SQB.QB_EMPRESP"
	Else
		cQuery += ", " + cEmpAnt + " AS SQB.QB_EMPRESP"
	EndIf
	cQuery += " FROM " + RetFullName("SQB",aListEmp[nI]) + " SQB"
	cQuery += " INNER JOIN " + RetFullName("RD4",cEmpAnt) + " RD4"
	cQuery += " ON " + cFilRD4 + " RD4.RD4_CODIDE = SQB.QB_DEPTO "

	cQuery += " WHERE RD4.RD4_FILIAL = '" + xFilial("RD4") + "' AND "
	cQuery += " RD4.RD4_CODIGO = '" + cVision + "' AND "
	cQuery += " RD4.RD4_EMPIDE = '" + cEmpAnt + "' AND "
	cQuery += " SQB.QB_FILRESP = '" + cFilResp + "' AND "
	cQuery += " SQB.QB_MATRESP = '" + cMatResp + "' AND "
	cQuery += " SQB.D_E_L_E_T_ = ' ' AND"
	cQuery += " RD4.D_E_L_E_T_ = ' ' "
	
	// Fechar as tabelas abertas para outra empresa
	CloseOtherTb()
	
Next nI

// Restaura dados da empresa logada apСs troca de empresa
If lTrocou
	ChangeEmp(aAliasNewEmp, __cEmpAnt, __cFilAnt)
EndIf

cEmpAnt := __cEmpAnt
cFilAnt := __cFilAnt
cArqTab := __cArqTab

cQuery := "%" + cQuery + "%" 

RestArea( aAreaSM0 )

Return cQuery

Static Function fMrhWhere(aQryParam, lAllRegs, nPage, nPageSize)

Local nX           := 0

Local cNameFunc    := ""
Local cCodFuncoes  := ""
Local cCodDeptos   := ""
Local cCodFil      := ""
Local cCodMat      := ""
Local cWhere       := ""
Local cCatFuncNot  := ""

//Filtros que serЦo processados no RHNP01 e nЦo na APIGET. Nesse caso, carrega todos os funcionАrios.
Local cFilAllReg   := "INITVIEW|ENDVIEW|STATUS|CONDITION|MONTHINADVANCE"

Local lOnlyConf    := .F.
Local lNomeSoc     := SuperGetMv("MV_NOMESOC", NIL, .F.)

DEFAULT aQryParam := {}
DEFAULT nPage     := 1
DEFAULT nPageSize := 20


For nX := 1 to Len(aQryParam)
	DO Case
		CASE UPPER(aQryParam[nX,1]) == "PAGE"
			nPage := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
			nPageSize := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) $ "NAME|USERNAME|EMPLOYEENAME"
			cNameFunc = UPPER(AllTrim(aQryParam[nX,2]))
		CASE UPPER(aQryParam[nX,1]) == "ROLE" // O ServiГo team/absence/all utiliza o Team como Filtro nos querysparams da busca avanГada.
			cCodFuncoes := getValueByQP(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "TEAM" // O ServiГo team/absence/all utiliza o Team como Filtro nos querysparams da busca avanГada.
			cCodDeptos := getValueByQP(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "CATFUNC" // O ServiГo team/absence/all remove os funcionАrios.
			cCatFuncNot := AllTrim(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "BRANCH"
			cCodFil := AllTrim(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "REGISTRY"
			cCodMat := AllTrim(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "ONLYVACATIONCONFLICTS"
			lOnlyConf := Iif( aQryParam[nX,2] == "true", .T., .F. )
		CASE !lAllRegs .And. UPPER(aQryParam[nX,1]) $ cFilAllReg
			lAllRegs := .T.
		OTHERWISE
			Loop
	ENDCASE
Next nX

// Caso realize algum desses filtros, entЦo nЦo precisa passar todos os registros.
// Caso o pageSize for igual a 3, quer dizer que И a gestЦo de fИrias da Home. Neste caso, limita a 99 registros a serem processados.
If !Empty(cNameFunc) .Or. !Empty(cCodFuncoes) .Or. !Empty(cCodDeptos) .Or. !Empty(cCodFil) .Or. !Empty(cCodMat) .Or. nPageSize == 3
	lAllRegs   := .F.
	If nPageSize == 3
		nPageSize := 100
	EndIf
EndIf

If !lAllRegs .And. lOnlyConf
	lAllRegs := .T.
EndIf

If !Empty(cNameFunc)
	cWhere += " AND (SRA.RA_NOME LIKE '%" + cNameFunc + "%' "
	cWhere += " OR SRA.RA_NOMECMP LIKE '%" + cNameFunc + "%' "
	cWhere += If(lNomeSoc, " OR SRA.RA_NSOCIAL LIKE '%" + cNameFunc + "%' ", "")
	cWhere += ")"
EndIf
If !Empty(cCodFil)
	cWhere += " AND SRA.RA_FILIAL = '" + cCodFil + "'"
EndIf
If !Empty(cCodMat)
	cWhere += " AND SRA.RA_MAT = '" + cCodMat + "'"
EndIf
If !Empty(cCodDeptos)
	cWhere += " AND SRA.RA_DEPTO IN ( " + cCodDeptos + " )"
EndIf
If !Empty(cCodFuncoes)
	cWhere += " AND SRA.RA_CODFUNC IN ( " + cCodFuncoes + " )"
EndIf
If !Empty(cCatFuncNot)
	cWhere += " AND SRA.RA_CATFUNC NOT IN ( " + cCatFuncNot  + " )"
EndIf

Return cWhere
