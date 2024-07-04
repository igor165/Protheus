#INCLUDE "TOTVS.CH"
#INCLUDE "GPEM011.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEM011    Ё Autor Ё Mauricio Takakura     	      Ё Data Ё 16/10/11 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Cancelamento do Calculo de Plano de Saude                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEM011()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁLeandro Dr.  Ё07/02/2012ЁM12RH01         ЁUnificacao da Folha.                  		Ё╠╠
╠╠Ё				Ё		   ЁRHU210_03_07	Ё       .									Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEM011()

	Local bProcesso		:= { |oSelf| GPMProcessa(oSelf)}

	Local cPergCal
	Local cCadastro		:= OemToAnsi(STR0001)	//"Cancelamento de Calculo Plano de Saude
	Local cDescricao	:= OemToAnsi(STR0002)	//"Este Programa cancelarА o calculo de Planos de Saude"

	Private lAbortPrint := .F.

	cPergCal 	:= "GPEM011"

	Pergunte(cPergCal,.F.)

	tNewProcess():New( "GPEM011", cCadastro, bProcesso, cDescricao, cPergCal, , , , , .T., .T. )

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPMProcessa	ЁAutorЁ  Mauricio TakakuraЁ Data Ё15/01/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRotina de Processamento.                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM011                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPMProcessa(oSelf)
	Local aPerAtual		:= {}
	Local dDataRef
	Local cFilDe
	Local cFilAte
	Local cCcDe
	Local cCcAte
	Local cMatrDe
	Local cMatrAte
	Local cCateg
	Local cSituacao
	Local cProcesso

	Local cAcessaSRA	:= &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM011" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )

	Local cAliasSRA		:= "SRA"
	Local cFilAux		:= "!!"
	Local cMesAtual
	Local cRHK_Titular
	Local cCposQuery
	Local cCatQuery
	Local cSitQuery

	Local lCont			:= .T.
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	Local lOfusca		:= Len(aFldRel) > 0

	// Carregar as variaveis do grupo de perguntas //
	dDataRef	:=  mv_par01	//	Data de Referencia - Competencia
	cAnoMes		:=  Substr(DTOS( dDataRef ), 1, 6)
	cFilDe		:=	mv_par02	//	Filial De
	cFilAte 	:=	mv_par03	//	Filial Ate
	cCcDe		:=	mv_par04	//	Centro de Custo De
	cCcAte		:=	mv_par05	//	Centro de Custo Ate
	cMatrDe 	:=	mv_par06	//	Matricula De
	cMatrAte	:=	mv_par07	//	Matricula Ate
	cCateg      :=  mv_par08	//  Categorias a serem calculadas
	cSituacao	:=  mv_par09	//  Situacoes a serem calculadas
	cProcesso	:=  mv_par10    //  Periodo a ser descalculado


	// Abrindo as tabelas //
	DbSelectArea("RHK")
	DbSelectArea("RHL")
	DbSelectArea("RHM")

	oSelf:SetRegua1(SRA->(RecCount()))
	oSelf:SaveLog( STR0001 + " - " + STR0005) //"Calculo do Plano de Saude"##"Inicio do processamento"

	If Empty(cProcesso)

		MsgAlert(STR0010)
		lCont := .F.
	Else 
		fGetPerAtual( @aPerAtual, xFilial("RCH"), cProcesso, fGetCalcRot("C") )
		If !Empty(aPerAtual) .and. !Empty(aPerAtual[1,10])
			Help(,,OemToAnsi(STR0011),,OemToAnsi(STR0012),1,0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0013) } )	//"O perМodo selecionado jА foi integrado." ### "Efetue o cancelamento da integraГЦo antes de excluir o cАlculo"
			lCont := .F.
		EndIf
		aPerAtual := {}
	EndIf

	If lCont

		// Filtrar os funcionarios que serao processados //
		dbSelectArea( "SRA" )
		dbSetOrder( 1 )
		dbSeek( cFilDe + cMatrDe , .T. )

		cAliasSRA 	:= "QSRA"
		If ( Select( cAliasSRA ) > 0 )
			( cAliasSRA )->( dbCloseArea() )
		EndIf

		cCposQuery 	:= "%SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_PROCES%"

		If Empty(cCateg)
			cCatQuery 	:= "%'" + "*" + "'%"
		Else
			cCatQuery 	:= Upper("%" + fSqlIN( cCateg, 1 ) + "%")
		EndIf

		If Empty( cSituacao )
			cSitQuery	:= "%'" + " " + "'%"
		Else
			cSitQuery	:= Upper("%" + fSqlIN( cSituacao, 1 ) + "%")
		EndIf

		cRHK_Titular := "%INNER JOIN "+ RetSqlName("RHK") + " RHK "
		cRHK_Titular += "ON  SRA.RA_FILIAL = RHK.RHK_FILIAL AND SRA.RA_MAT = RHK.RHK_MAT AND RHK.D_E_L_E_T_  = ' ' %"

		//Sempre que alterar esta query, a query abaixo (count), tb devera ser alterada.
		BeginSql alias cAliasSRA
			SELECT %exp:cCposQuery%
			FROM %table:SRA% SRA
			%Exp:cRHK_Titular%
			WHERE  SRA.RA_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte%
			AND SRA.RA_MAT BETWEEN %exp:cMatrDe% AND %exp:cMatrAte%
			AND SRA.RA_CC BETWEEN %exp:cCCDe% AND %exp:cCCAte%
			AND SRA.RA_CATFUNC IN (%exp:cCatQuery%)
			AND SRA.RA_SITFOLH IN (%exp:cSitQuery%)
			AND SRA.%notDel%
			GROUP BY SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_PROCES
		EndSql

		While (cAliasSRA)->( !Eof() )

			If oSelf:lEnd
				Break
			EndIf

			If Eof() .Or. ( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT > cFilAte + cMatrAte )
				Exit
			EndIf

			If Empty(aPerAtual) .or. !(aPerAtual[1,8] == (cAliasSRA)->RA_PROCES) .or. !(cFilAux == (cAliasSRA)->RA_FILIAL)

			//--> Alterado para pegar o cСdigo do processo da variАvel cProcesso, ao invИs de buscar do RA_PROCES
			//fGetPerAtual( @aPerAtual, xFilial("RCH"), (cAliasSRA)->RA_PROCES, fGetRotOrdinar() )

				fGetPerAtual( @aPerAtual, xFilial("RCH"), cProcesso, fGetRotOrdinar() )

				cMesAtual := ""

				If !Empty(aPerAtual)
					cMesAtual 	:= aPerAtual[1,5]+aPerAtual[1,4] //RCH_ANO + RCH-MES
				EndIf

				cFilAux     := (cAliasSRA)->RA_FILIAL
				If cAnoMes < cMesAtual .and. !Empty(cMesAtual)
					Help(,,'HELP',,OemToAnsi(STR0003) + CRLF + OemToAnsi(STR0008) + cFilAux + " - " + OemToAnsi(STR0009) + (cAliasSRA)->RA_PROCES,1,0)	//"Informe uma data de ReferЙncia maior ou igual Ю CompetЙncia da Folha de Pagamento!"#Filial: - Processo: "
					dbSkip()
					Loop
				EndIf
			EndIf

			If cAnoMes < cMesAtual .or. Empty(cMesAtual)
				dbSkip()
				Loop
			EndIf

			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Posiciona na tabela SRA - Fisica                    	 	   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			DbSelectArea( "SRA" )
			DbSetOrder( RetOrder( "SRA", "RA_FILIAL+RA_MAT" ))
			DbSeek( (cAliasSRA)->(RA_FILIAL+RA_MAT),.F.)

			/*
			зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			ЁConsiste Filiais e Acessos                                             Ё
			юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			IF !( (cAliasSRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
				dbSelectArea(cAliasSRA)
				dbSkip()
				Loop
			EndIF

			oSelf:IncRegua1(OemToAnsi(STR0004) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + If(lOfusca, "", " - " + SRA->RA_NOME) )//"Cancelando Calculo do Plano de Saude de:"

			// Deletar o Calculo do Funcionario //
			fDeleCalc()

			DbSelectArea( cAliasSRA )
			DbSkip()
		EndDo

		If (Select( "QSRA" ) > 0)
			QSRA->(DbCloseArea())
		EndIf
	EndIf

	oSelf:SaveLog( STR0001+" - "+STR0006) //"Calculo da Folha de Pagamento"##"Termino do processamento"

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fDeleCalc 		ЁAutorЁ  Mauricio TakakuraЁ Data Ё15/01/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDeletar o Calculo anterior da Competencia a Calcular        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM011                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fDeleCalc()
	Local aArea := GetArea()
	Local cQuery
	Local cNameDB
	Local cDelet
	Local cSqlName := InitSqlName( "RHR" )

 	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁO banco DB2 nao aceita o nome da tabela apos o comando DELETE			 Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cNameDB	:= Upper(TcGetDb())

	cQuery := "DELETE "
	cDelet := "RHR.D_E_L_E_T_ = ' ' "

	If ( cNameDB $ "INFORMIX" )
		cDelet	:= cSqlName +  ".D_E_L_E_T_ = ' ' "
	EndIf

	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += cSqlName
	EndIf

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁO Informix precisa do nome da tabela ao inves do Alias no comando DELETEЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	If ( cNameDB $ "INFORMIX" )
		cQuery += " FROM " + cSqlName
	Else
		cQuery += " FROM " + cSqlName + " RHR"
		cSqlName := "RHR"
	EndIf

	cQuery += " WHERE " + cSqlName + ".RHR_FILIAL = '" + SRA->RA_FILIAL + "'"
	cQuery += " AND " + cSqlName + ".RHR_MAT = '" + SRA->RA_MAT + "'"
	cQuery += " AND " + cSqlName + ".RHR_COMPPG = '" + cAnoMes + "'"
	cQuery += " AND " + cDelet

	TcSqlExec( cQuery )

	RestArea( aArea )

Return( .T. )
