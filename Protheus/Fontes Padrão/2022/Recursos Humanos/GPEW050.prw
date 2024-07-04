#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GPEW050.CH'

/*/{Protheus.doc} GPEW050
Workflow Vencimento período de experiência
@type Function
@author Cícero Alves
@since 02/10/2019
@see (links_or_references)
/*/
Function GPEW050()
	
	Local aArea := GetArea()
	Local cFil	:= FWCodFil()
	Local cEmp	:= FWCodEmp() 
	Local aLog	:= {}
	Local cMail := SuperGetMV("MV_WFFEREM") //e-Mail a ser utilizado caso o superior não tenha email definido e para envio do log 
	
	Aadd(aLog, STR0013 ) // Processamento GPEW050 - Vencimento de período de experiência
	
	Aadd(aLog, Replicate("*", 50))
	Aadd(aLog, STR0014 + DtoC(Date()) + STR0015 + Time()) // Processamento GPEW050 Início - dd/MM/YYYY" HORA : "
	Aadd(aLog, Replicate("*", 50))
	
	WFFimExp(cEmp, cFil, @aLog, cMail)
	
	Aadd(aLog, Replicate("*", 50))
	Aadd(aLog, STR0016 + DtoC(Date()) + STR0015 + Time()) // "Processamento GPEW050 Fim - "//" HORA : "
	Aadd(aLog, Replicate("*", 50))
	
	GeraLog("GPEW050_" + cFil, aLog, cMail)
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} WFFimExp()
Workflow Vencimento contrato de experiência
@type Static Function
@author Cícero Alves
@since 02/10/2019
@param cEmp, Caractere, Código do grupo de empresas
@param cFil, Caractere, Código da filial
@param aLog, Array, Array onde será armazenado o log - passar por referência
@param cMail, Caractere, e-Mail utilizado caso o superior não tenha no cadastro
@example
	WFAvisoExp("T1", "D MG 01 ", @aLog, "superior@teste.com")
/*/
Static Function WFFimExp(cEmp, cFil, aLog, cMail)
	
	Local cAliasSRA := GetNextAlias()
	Local nDias		:= SuperGetMV("MV_WFFIMXP", , 10) // Dias para acrescentar na database para usar como critério de busca
	Local dDtLimite	:= dDataBase + nDias
	Local cTipoOrg	:= SuperGetMV("MV_ORGCFG", , "0")
	Local cVisao	:= SuperGetMv("MV_APDVIS")
	Local aDeptos	:= {}
	Local aSup		:= {}
	Local aFunc		:= {}
	Local cCodigo	:= ""
	
	If cTipoOrg == "0"
		aDeptos := fEstrutDepto(cFil)
	EndIf
	
	BeginSQL Alias cAliasSRA
		COLUMN RA_ADMISSA AS DATE
		COLUMN RA_VCTOEXP AS DATE
		COLUMN RA_VCTEXP2 AS DATE
		
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_ADMISSA, RA_DEPTO, RA_CC, RA_VCTOEXP, RA_VCTEXP2, RA_CODFUNC
		FROM %table:SRA% SRA
		WHERE
		SRA.RA_FILIAL = %exp:cFil% AND
		(SRA.RA_VCTOEXP = %exp:Dtos(dDtLimite)% OR SRA.RA_VCTEXP2 = %exp:Dtos(dDtLimite)%) AND
		SRA.RA_SITFOLH IN (' ', 'A') AND
		SRA.%NotDel%
	EndSQL
	
	While ! (cAliasSRA)->(EoF())
		
		// Agrupa os funcionários por superior, para não enviar mais de um e-mail para a mesma pessoa
		aSup := {}
		cCodigo := (cAliasSRA)->(fSuperior(@aSup, cVisao, RA_FILIAL, RA_MAT, RA_DEPTO, aDeptos, cTipoOrg))
		
		If (nPos := Ascan(aFunc,{|x| x[1] == cCodigo})) > 0
			(cAliasSRA)->(Aadd(aFunc[nPos][3], {RA_NOME, RA_MAT, RA_FILIAL, RA_CC, RA_CODFUNC, RA_ADMISSA, RA_VCTOEXP, RA_VCTEXP2}))
		Else
			(cAliasSRA)->(Aadd(aFunc, {cCodigo, aSup, {{RA_NOME, RA_MAT, RA_FILIAL, RA_CC, RA_CODFUNC, RA_ADMISSA, RA_VCTOEXP, RA_VCTEXP2}}}))
		EndIf
		
		(cAliasSRA)->(dbSkip())
		
	EndDo
	
	(cAliasSRA)->(dbCloseArea())
	
	// Envia os e-Mails
	SendMail(aFunc, aLog, cMail, dDtLimite)
	
Return

/*/{Protheus.doc} SendMail
Envia os e-mails sobre o vencimento do período de experiência para os funcionário passados por parâmetro
@type Static Function
@author Cícero Alves
@since 03/10/2019
@param aFunc, Array, Informações do funcionário e seu superior 
@param aLog, Array, Array para gravar o log de execução da rotina
@param cMail, Caractere, e-mail secundário para envio caso o superior não tenha no cadastro
@param dDtLimite, Data, Data que foi utilizada na busca 
/*/
Static Function SendMail(aFunc, aLog, cMail, dDtLimite)
	
	Local cNome		:= ""
	Local cHTML		:= ""
	Local cAssunto	:= STR0001 // "Aviso de vencimento de experiência"
	Local nI, nJ
	
	For nI:= 1 to Len(aFunc)
		
		If Len(aFunc[nI][2]) > 0
			If !Empty(aFunc[nI][2][1][3])
				cMail := aFunc[nI][2][1][3]
			EndIf
			cNome := aFunc[nI][2][1][4]
		EndIf
		
		cHTML := "<html>"
		cHTML += "<p>"
		cHTML += STR0002 + " " + AllTrim(cNome) +   ", </p>" // 'Prezado'
		cHTML += "<p>"
		cHTML += STR0003 + " " + DtoC(dDtLimite) + "</p>" // "O período de experiência dos funcionários abaixo irá vencer no dia "
		For nJ := 1 To Len(aFunc[nI][3])
			cHTML += "<p>"
			cHTML += STR0004 + " " + AllTrim(aFunc[nI][3][nJ][1]) + "<br>"	// 'Nome:'
			cHTML += STR0005 + " " + AllTrim(aFunc[nI][3][nJ][2]) + "<br>"	// 'Matrícula:'
			cHTML += STR0006 + " " + AllTrim(aFunc[nI][3][nJ][3]) + "<br>" 	// 'Filial:'
			cHTML += STR0007 + " " + AllTrim(aFunc[nI][3][nJ][4]) + "<br>"	// 'Centro de Custo:'
			cHTML += STR0008 + " " + AllTrim(aFunc[nI][3][nJ][5]) + "<br>"	// 'Fução:'
			cHTML += STR0009 + " " + DtoC(aFunc[nI][3][nJ][6]) 	  + "<br>"	// 'Admissão:'
			cHTML += STR0010 + " " + DtoC(aFunc[nI][3][nJ][7])    + "<br>"	// 'Data Vencimento 1ª Experiência:'
			cHTML += STR0011 + " " + DtoC(aFunc[nI][3][nJ][8])    + "</p>"	// 'Data Vencimento 2ª Experiência:'
		Next nJ
		cHTML += "</html>"
		
		If ! GPEMail(cAssunto, cHTML, cMail, {})
			Aadd(aLog, STR0012 ) // 'Erro ao enviar email:'
		EndIf
		
	Next nI
	
Return

/*/{Protheus.doc} GeraLog
Funcao para gravar arquivo TXT com o log da execução da rotina
@type  Static Function
@author Cícero Alves
@since 03/10/2019
@param param, param_type, param_descr
@param param, param_type, param_descr
@param param, param_type, param_descr
/*/
Static Function GeraLog(cNomeArq, aDados, cMail)
	
	Local aArea 	:= GetArea()
	Local cArq 		:= ""                                     
	Local cServer	:= "\_logs\"      
	Local nI	 	:= 0
	Local cErro		:= ""
	Local nHdlA
	
	If !ExistDir(cServer) 
		if MakeDir( cServer ) != 0
				Conout(STR0017) // "Erro ao criar diretório de saída."
			Return
		EndIf                    
	EndIf         
	
	cNome := cNomeArq + "_" + DtoS(Date()) + "_" + Replace(Time(), ":" , "" ) + ".log"
	
	If !File (cServer + "\" + cNome)
		nHdlA := fCreate( cServer + "\" +cNome)
	Else
		If fErase(cServer + "\" + cNome) >= 0
			nHdlA := fCreate( cServer + "\" + cNome)
		Else      
			Conout(STR0018) // "Não foi possível gerar o arquivo, ele já existe."
			Return	
		EndIf
	EndIf
	
	For nI := 1 To Len(aDados)
		cArq := aDados[nI] + CRLF
		fWrite(nHdlA, cArq, Len(cArq)) 
	Next nI
	
	fClose(nHdlA) 
	
	If !gpeMail("GPEW050" + STR0019, "", cMail, {cServer + "\" + cNome}, @cErro) // Log de Geração
		conout(STR0012 + cErro) // Erro enviar email
	EndIf
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} SchedDef
Função static para carregar ambiente do schedule
@type Static Function
@author Cícero Alves
@since 03/10/2019
@return aParam, Array, Array com os parâmetros informados no schedule
/*/
Static Function SchedDef()
	
	Local aOrd		:= {}
	Local aParam	:= {}
	
	aParam := {"P", "PARAMDEF", "", aOrd, }	
	
Return aParam