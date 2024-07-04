#INCLUDE "TOTVS.CH"
#INCLUDE "GPEM009.CH"

Static lGPM19RGB

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤ao    	Ё GPEM009    Ё Autor Ё Mauricio Takakura     	      Ё Data Ё 24/10/11 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Integracao do calculo de Plano de Saude com a Folha de Pagamento		Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEM009()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁLeandro Dr.  Ё07/02/2012ЁM12RH01         ЁUnificacao da Folha.                  		Ё╠╠
╠╠Ё				Ё		   ЁRHU210_03_07	Ё       .									Ё╠╠
╠╠ЁJoao Balbino Ё02/06/2016ЁTVGHGX          ЁCorreГЦo para tratar funcionАrios 			Ё╠╠
╠╠Ё				Ё		   Ё            	Ё       . semanalista.						Ё╠╠
╠╠ЁCМcero Alves Ё18/10/2016ЁTW3476          ЁAjuste na funГЦo fSqlIN para nЦo realizar  Ё╠╠
╠╠Ё				Ё		   Ё            	ЁRTrim quando a string estiver apenas com umЁ╠╠
╠╠Ё				Ё		   Ё            	ЁespaГo 									Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEM009()

	GPEM019()

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPMProcessa	ЁAutorЁ  Mauricio TakakuraЁ Data Ё24/10/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRotina de Processamento.                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM009                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPMProcessa(oSelf)

	Local aCodFol	:= {}
	Local cJoin
	Local cAcessaSRA	:= &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM009" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
	Local cCposQuery
	Local cRoteiro		:= ""
	Local cRotBen		:= fGetCalcRot("C") //Plano de Saude
	Local cFilAux		:= ""
	Local cRotAuxAut	:= fGetCalcRot("9")
	Local cRotAuxFol	:= fGetCalcRot("1")

	Local nRet			:= 0
	Local nSRAReg		:= 0
	Local nRecRCH

	Local aTamIt	:= TamSx3("RA_ITEM")
	Local aTamClVL	:= TamSx3("RA_CLVL")

	Local lSemana	:= .T.
	Local lAvisoBlq	:= .T.
	Local lIntOk
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

	Private aLog		:= {}
	Private aTitle		:= {}
	Private lOfusca		:= Len(aFldRel) > 0
	Private lTemItem	:= !Empty( aTamIt )
	Private lTemClVl	:= !Empty( aTamClVl )

	Private cAnoMes 	:= ""
	Private cSemana 	:= ""
	Private cAliasSRA	:= "SRA"
	Private nSobrepor
	Private nAgrupa

	// Carregar as variaveis do grupo de perguntas //
	cProcesso	:= mv_par01     // Processo
	cPeriodo	:= mv_par02     // Periodo
	cSemana 	:= mv_par03   	// Nro.Pagamento
	nSobrepor	:= mv_par04		//  Sobrepor Registros
	nAgrupa		:= mv_par05		//  Agrupar Beneficios 1-sim 2-nЦo

	If Empty(cFilRCJ)
		cFilRCJ := xFilial("RCJ")
	EndIf

	// Guarda o Recno do RCH para resposicionamento
	RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
	If !RCH->( dbSeek( xFilial("RCH") + cProcesso + cRotBen + cPeriodo + cSemana, .F. ) )
		RCH->( dbSeek( xFilial("RCH") + cProcesso + cRotBen + cPeriodo, .F. ) )
		lSemana := .F.
	EndIf
	While RCH->(!Eof() .and. ((RCH_FILIAL + RCH_PROCES + RCH_ROTEIR + RCH_PER ) == (xFilial("RCH") + cProcesso + cRotBen + cPeriodo )))
		If lSemana
			If RCH->RCH_NUMPAG <> cSemana
				RCH->( dbSkip() )
				Loop
			EndIf
		EndIf
		If Empty(RCH->RCH_DTFECH)
			Exit
		EndIf
		If !Empty(RCH->RCH_DTINTE)
			nRet := 1
		EndIf
		RCH->( dbSkip() )
	EndDo

	If !RCH->( Eof() )
		nRecRCH := RCH->(Recno())
	Else
		If nRet == 1
			Help(,,'HELP',,OemToAnsi(STR0015),1,0)	// "Periodo informado ja esta integrado"
			Return( .F. )
		Else
			Help(,,'HELP',,OemToAnsi(STR0014),1,0)	// "Periodo informado nao cadastrado ou ja fechado."
			Return( .F. )
		EndIf
	EndIf

	cAnoMes	:=	cPeriodo

	If !FP_CODFOL(@aCodFol,xFilial("SRA"))
		Help(,,'HELP',,OemToAnsi(STR0007),1,0)	//"Nao foi possivel carregar os Identificadores de Calculo!"
		Return( .F. )
	EndIf

	If !Empty(RCH->RCH_DTINTE)
		Help(,,'HELP',,OemToAnsi(STR0015),1,0)	// "Este beneficio ja foi integrado."
		Return( .F. )
	EndIf

	If !Empty(RCH->RCH_DTFECH)
		Help(,,'HELP',,OemToAnsi(STR0016),1,0)	// "O periodo selecionado ja esta fechado."
		Return( .F. )
	EndIf

	cJoin := "% "
	cJoin += FWJoinFilial( "RCJ", "SRA" ) + " AND "
	cJoin += " RCJ.RCJ_CODIGO 	  = SRA.RA_PROCES "
	cJoin += "%"

	cAliasSRA 	:= "QSRA"
	If ( Select( cAliasSRA ) > 0 )
		( cAliasSRA )->( dbCloseArea() )
	EndIf
	cCposQuery       := "%SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CATFUNC%"

	//Sempre que alterar uma query, a outra tb devera ser alterada.
	BeginSql alias cAliasSRA
		SELECT count(*) CONTADOR
		FROM %table:SRA% SRA
		INNER JOIN %table:RCJ% RCJ
		ON %exp:cJoin%
		WHERE SRA.RA_PROCES = %exp:cProcesso%
		AND RCJ.RCJ_FILIAL = %exp:cFilRCJ%
		AND NOT EXISTS( SELECT RG_FILIAL, RG_MAT FROM %table:SRG% SRG WHERE SRG.%notDel% AND SRG.RG_FILIAL = SRA.RA_FILIAL AND SRG.RG_MAT = SRA.RA_MAT AND SRG.RG_EFETIVA <> 'N' )
		AND SRA.%notDel% AND RCJ.%notDel%
	EndSql

	If (cAliasSRA)->( !Eof() )
		nSRAReg := (cAliasSRA)->CONTADOR
	EndIf

	( cAliasSRA )->( dbCloseArea() )

	BeginSql alias cAliasSRA
		SELECT %exp:cCposQuery%
		FROM %table:SRA% SRA
		INNER JOIN %table:RCJ% RCJ
		ON %exp:cJoin%
		WHERE SRA.RA_PROCES = %exp:cProcesso%
		AND RCJ.RCJ_FILIAL = %exp:cFilRCJ%
		AND NOT EXISTS( SELECT RG_FILIAL, RG_MAT FROM %table:SRG% SRG WHERE SRG.%notDel% AND SRG.RG_FILIAL = SRA.RA_FILIAL AND SRG.RG_MAT = SRA.RA_MAT AND SRG.RG_EFETIVA <> 'N' )
		AND SRA.%notDel% AND RCJ.%notDel%
		ORDER BY 1,2
	EndSql

	Aadd(aTitle, OemToAnsi(STR0006))  //"Registros nao Integrados"
	Aadd( aLog,{} )

	oSelf:SetRegua1(nSRAReg)
	oSelf:SaveLog( STR0001 + " - " + STR0009) //"Calculo do Plano de Saude"##"Inicio do processamento"

	lIntOk := .T.

	While (cAliasSRA)->( !Eof() )

		If (cAliasSRA)->RA_CATFUNC $ "A*P"
			cRoteiro := cRotAuxAut
		Else
			cRoteiro := cRotAuxFol
		EndIf

		If oSelf:lEnd
			Break
		EndIf

		// Consiste Filiais e Acessos
		If !( (cAliasSRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
			dbSelectArea(cAliasSRA)
			dbSkip()
			Loop
		EndIf

		// Verifica bloqueio de periodo
		If !fVldAccess( (cAliasSRA)->RA_FILIAL, cPeriodo,, lAvisoBlq, cRotBen,"2" )
			lAvisoBlq 	:= .F.
			lIntOk 		:= .F.
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
		ЁVerifica se periodo nao esta bloqueado                                 Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If !fVldAccess( (cAliasSRA)->RA_FILIAL,cPeriodo,cSemana,.F.,cRoteiro, "2" )
			dbSelectArea(cAliasSRA)
			dbSkip()
			Loop
		EndIf

		oSelf:IncRegua1(OemToAnsi(STR0004) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + If(lOfusca, "", " - " + SRA->RA_NOME) )//"Integrando o Calculo Plano de Saude de:"

		If cFilAux <> SRA->RA_FILIAL
			If !FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
				Aadd(aTitle, OemToAnsi(STR0007))  //"Nao foi possivel carregar os Identificadores de Calculo!"
				Aadd( aLog,{} )
				lIntOk := .F.
				Exit
			EndIf
			cFilAux := SRA->RA_FILIAL
		EndIf

		If !(lIntOk := fIntegraPLS(aCodFol,cAnoMes,cRoteiro,cPeriodo,cSemana))
			Exit
		EndIf

		DbSelectArea( cAliasSRA )
		DbSkip()
	EndDo

	// Fechamento do Periodo na tabela RCH
	If lIntOk
		RCH->(dbGoTo(nRecRCH))
		DbSelectArea( "RCH" )
		RecLock("RCH",.F.)                 // Bloqueio registro RCH
		RCH->RCH_DTINTE  := dDataBase
		RCH->( MsUnlock() )
	EndIf

	If (Select( cAliasSRA ) > 0)
		( cAliasSRA )->( dbCloseArea() )
	EndIf

	oSelf:SaveLog( STR0001+" - "+STR0010) //"Calculo da Folha de Pagamento"##"Termino do processamento"

	/*
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Apresenta com Log de erros                              Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	fMakeLog(aLog,aTitle,,,"PS"+cAnoMes,STR0005,"M","P",,.F.)  //"LOG de Ocorrencias - Dissidio"

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fSqlIN			ЁAutorЁ  Mauricio TakakuraЁ Data Ё24/10/2011Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSeparar os itens para incluir como IN na query              Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁALL			                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fSqlIN( cTexto, nStep )

	Local cRet := ""
	Local i

	If ! Empty(cTexto)
		cTexto := Rtrim( cTexto )
	EndIf

	If Len( cTexto ) > 0
	   For i := 1 To Len( cTexto ) Step nStep
	       cRet += "'" + SubStr( cTexto, i, nStep ) + "'"

	       If i + nStep <= Len( cTexto )
	          cRet += ","
	       EndIf
	   Next
	EndIf

Return( cRet )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fIntegraPLS	ЁAutorЁ  Leandro Drumond  Ё Data Ё11/08/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIntegra o calculo do plano de saude              			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁALL			                                                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁLogico														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fIntegraPLS(aCodFol,cAnoMes,cRoteiro,cPeriodo,cSemana)

Local aMatPD	  := {}
Local c1PdEmprTit := aCodFol[213,1]		//-- Base parte Empresa Assist.Medica
Local c1PdEmprDep := aCodFol[725,1]		//-- Base parte Empresa Ass.Medica Dependentes
Local c1PdEmprAgr := aCodFol[726,1]		//-- Base parte Empresa Ass.Medica Agregados
Local c1PdDfEmpT  := ""					//-- 1426 - Base parte Empresa DiferenГa Assist.Medica
Local c1PdDfEmpD  := ""					//-- 1427 - Base parte Empresa DiferenГa Assist.Medica Dep/Agreg.
Local c1PdTotTit  := ""					//-- 1862 - Valor Assist. Med. Titular
Local c1PdTotDep  := ""					//-- 1863 - Valor Assist. Med. Dependente
Local c1PdTotAgr  := ""					//-- 1864 - Valor Assist. Med. Agregado
Local c2PdEmprTit := aCodFol[717,1]		//-- Parte Empresa Assist.Odontologica Titular
Local c2PdEmprDep := aCodFol[718,1]		//-- Parte Empresa Assist.Odontologica Dependente
Local c2PdEmprAgr := aCodFol[719,1]		//-- Parte Empresa Assist.Odontologica Agregado
Local c2PdDfEmpT  := ""					//-- 1428 - Base parte Empresa DiferenГa Assist.Odontologica
Local c2PdDfEmpD  := ""					//-- 1429 - Base parte Empresa DiferenГa Assist.Odontologica Dep/Agreg.
Local c2PdTotTit  := ""					//-- 1865 - Valor Assist. Med. Titular
Local c2PdTotDep  := ""					//-- 1866 - Valor Assist. Med. Dependente
Local c2PdTotAgr  := ""					//-- 1867 - Valor Assist. Med. Agregado
Local c1PdTab     := ""					//-- Base parte Empresa Assist.Medica/Odontologica Titular Informado diretamente no fornecedor => Tabela S016/S017
Local c2PdTab     := ""					//-- Base parte Empresa Assist.Medica/Odontologica Dependentes Informado diretamente no fornecedor => Tabela S016/S017
Local c3PdTab     := ""					//-- Base parte Empresa Assist.Medica/Odontologica Agregados Informado diretamente no fornecedor => Tabela S016/S017
Local cPDFind	  := ""
Local cPdDif      := ""
Local cPdEmpDif   := ""
Local cPdTot   	  := ""
Local cIdErro	  := ""
Local cRotPLS	  := fGetCalcRot("C") //Roteiro plano de saude
Local lNotPDEmp	  := .F.
Local lGrava	  := .F.
Local lRet 		  := .T.
Local lRHKDatFim  := .F.
Local nLine		  := 0
Local nIndice	  := 0
Local nI		  := 0
Local nSeq		  := 0
Local nLinFor	  := 0
Local nLinha      := 0
Local dDtRef      := sTod(cPeriodo + "01")
Local nSeqDep     := 0 // Sequencia para a contagem dos dependentes acima de 9.

DEFAULT lGPM19RGB := ExistBlock("GPM19RGB")

aVbsForn:= If( Type("aVbsForn") <> "U", aVbsForn, {} )
nAgrupa := If( Type("nAgrupa") <> "U", nAgrupa, 1 )

DbSelectArea( "RHK" )
lRHKDatFim := RHK->(ColumnPos("RHK_DATFIM")) > 0

If lRHKDatFim
	c1PdDfEmpT := aCodFol[1426,1]
	c1PdDfEmpD := aCodFol[1427,1]
	c2PdDfEmpT := aCodFol[1428,1]
	c2PdDfEmpD := aCodFol[1429,1]
	cPdDif := ""
	RHK->(DbSetOrder(1))
	RHK->(DbSeek( (cAliasSRA)->(RA_FILIAL+RA_MAT), .F.))
	While !Eof() .and. RHK->(RHK_FILIAL+RHK_MAT) == (cAliasSRA)->(RA_FILIAL+RA_MAT)
		If !Empty(RHK->RHK_PDDIFT)
			cPdDif += RHK->RHK_PDDIFT + "*"
		EndIf
		If !Empty(RHK->RHK_PDDIFD)
			cPdDif += RHK->RHK_PDDIFD + "*"
		EndIf
		RHK->(DbSkip())
	EndDo
EndIf

If Len(aCodFol) >= 1862
	c1PdTotTit	:= aCodFol[1862,1]		//-- 1862 - Valor Assist. Med. Titular
	c1PdTotDep	:= aCodFol[1863,1]		//-- 1863 - Valor Assist. Med. Dependente
	c1PdTotAgr	:= aCodFol[1864,1]		//-- 1864 - Valor Assist. Med. Agregado
	c2PdTotTit	:= aCodFol[1865,1]		//-- 1865 - Valor Assist. Med. Titular
	c2PdTotDep	:= aCodFol[1866,1]		//-- 1866 - Valor Assist. Med. Dependente
	c2PdTotAgr	:= aCodFol[1867,1]		//-- 1867 - Valor Assist. Med. Agregado
EndIf

DbSelectArea( "RHR" )
DbSetOrder( 1 )
DbSeek( (cAliasSRA)->(RA_FILIAL+RA_MAT) + cAnoMes, .F.)

While !Eof() .and. RHR->(RHR_FILIAL+RHR_MAT+RHR_COMPPG) == (cAliasSRA)->(RA_FILIAL+RA_MAT) + cAnoMes

	nSeq		  := 0

	//Avalia se as verbas da parte empresa da Assistencia Medica foi informada por Fornecedor
	If RHR->RHR_TPFORN == '1'

		nLinFor := aScan( aVbsForn, { |x| x[1]+x[2]+x[3] == RHR->RHR_FILIAL+RHR->RHR_CODFOR+RHR->RHR_TPFORN } )

		If nLinFor > 0
			c1PdEmprTit := aVbsForn[nLinFor,4]	//-- Base parte Empresa Assist.Medica
			c1PdEmprDep := aVbsForn[nLinFor,5]	//-- Base parte Empresa Ass.Medica Dependentes
			c1PdEmprAgr := aVbsForn[nLinFor,6]	//-- Base parte Empresa Ass.Medica Agregados
		Else
			If ( nLinha := fPosTab( 'S016', RHR->RHR_CODFOR, "=", 4, , , , , , , .T., RHR->RHR_FILIAL ) ) > 0

				c1PdTab	:= fTabela('S016',nLinha,08,,RHR->RHR_FILIAL )
				c2PdTab	:= fTabela('S016',nLinha,09,,RHR->RHR_FILIAL )
				c3PdTab	:= fTabela('S016',nLinha,10,,RHR->RHR_FILIAL )

				c1PdEmprTit := If( !Empty(c1PdTab), c1PdTab, c1PdEmprTit )	//-- Base parte Empresa Assist.Medica
				c1PdEmprDep := If( !Empty(c2PdTab), c2PdTab, c1PdEmprDep )	//-- Base parte Empresa Ass.Medica Dependentes
				c1PdEmprAgr := If( !Empty(c3PdTab), c3PdTab, c1PdEmprAgr )	//-- Base parte Empresa Ass.Medica Agregados

				//Adiciona no array poder ser utilizado ao processar outras matriculas do mesmo fornecedor
				aAdd( aVbsForn, {;
									RHR->RHR_FILIAL,; 	//Filial
									RHR->RHR_CODFOR,; 	//Codigo do Fornecedor
									RHR->RHR_TPFORN,; 	//Tipo de Fornecedor
									c1PdEmprTit,; 		//Verba Assistencia Medica Titular
									c1PdEmprDep,; 		//Verba Assistencia Medica Dependente
									c1PdEmprAgr })		//Verba Assistencia Medica Agregado
	    	EndIf
		EndIf
	EndIf

	//Avalia se as verbas da parte empresa da Assistencia Odontologica foi informada por Fornecedor
	If RHR->RHR_TPFORN == '2'

		nLinFor := aScan( aVbsForn, { |x| x[1]+x[2]+x[3] == RHR->RHR_FILIAL+RHR->RHR_CODFOR+RHR->RHR_TPFORN } )

		If nLinFor > 0
			c2PdEmprTit := aVbsForn[nLinFor,4]	//-- Base parte Empresa Assist.Odontologica
			c2PdEmprDep := aVbsForn[nLinFor,5]	//-- Base parte Empresa Ass.Odontologica Dependentes
			c2PdEmprAgr := aVbsForn[nLinFor,6]	//-- Base parte Empresa Ass.Odontologica Agregados
		Else
			If ( nLinha := fPosTab( 'S017', RHR->RHR_CODFOR, "=", 4, , , , , , , .T., RHR->RHR_FILIAL ) ) > 0

				c1PdTab	:= fTabela('S017',nLinha,08,,RHR->RHR_FILIAL )
				c2PdTab	:= fTabela('S017',nLinha,09,,RHR->RHR_FILIAL )
				c3PdTab	:= fTabela('S017',nLinha,10,,RHR->RHR_FILIAL )

				c2PdEmprTit := If( !Empty(c1PdTab), c1PdTab, c2PdEmprTit )	//-- Base parte Empresa Assist.Odontologica
				c2PdEmprDep := If( !Empty(c2PdTab), c2PdTab, c2PdEmprDep )	//-- Base parte Empresa Ass.Odontologica Dependentes
				c2PdEmprAgr := If( !Empty(c3PdTab), c3PdTab, c2PdEmprAgr )	//-- Base parte Empresa Ass.Odontologica Agregados

				//Adiciona no array poder ser utilizado ao processar outras matriculas do mesmo fornecedor
				aAdd( aVbsForn, {;
									RHR->RHR_FILIAL,; 	//Filial
									RHR->RHR_CODFOR,; 	//Codigo do Fornecedor
									RHR->RHR_TPFORN,; 	//Tipo de Fornecedor
									c2PdEmprTit,; 		//Verba Assistencia Odontologica Titular
									c2PdEmprDep,; 		//Verba Assistencia Odontologica Dependente
									c2PdEmprAgr })		//Verba Assistencia Odontologica Agregado
	    	EndIf
		EndIf
	EndIf

	If (RHR->RHR_ORIGEM == '1' .and. RHR->RHR_TPFORN == "1" .and. RHR->RHR_VLREMP > 0 )
		If Empty(c1PdEmprTit)
			cIdErro += " 213,"
			lNotPDEmp := .T.
		EndIf
		If lRHKDatFim .AND. !Empty(cPdDif) .AND. Empty(c1PdDfEmpT)
			cIdErro += " 1426,"
			lNotPDEmp := .T.
		EndIf
	EndIf

	If (RHR->RHR_ORIGEM == '2' .and. RHR->RHR_TPFORN == "1" .and.RHR->RHR_VLREMP > 0 )
		If Empty(c1PdEmprDep)
			cIdErro += " 725,"
			lNotPDEmp := .T.
		EndIf
		If lRHKDatFim .AND. !Empty(cPdDif) .AND. Empty(c1PdDfEmpD)
			cIdErro += " 1427,"
			lNotPDEmp := .T.
		EndIf
	EndIf

	If (RHR->RHR_ORIGEM == '3' .and. RHR->RHR_TPFORN == "1" .and.RHR->RHR_VLREMP > 0 )
		If Empty(c1PdEmprAgr)
			cIdErro += " 726,"
			lNotPDEmp := .T.
		EndIf
		If lRHKDatFim .AND. !Empty(cPdDif) .AND. Empty(c1PdDfEmpD)
			cIdErro += " 1427,"
			lNotPDEmp := .T.
		EndIf
	EndIf

	If (RHR->RHR_ORIGEM == '1' .and. RHR->RHR_TPFORN == "2" .and. RHR->RHR_VLREMP > 0 )
		If Empty(c2PdEmprTit)
			cIdErro += " 717,"
			lNotPDEmp := .T.
		EndIf
		If lRHKDatFim .AND. !Empty(cPdDif) .AND. Empty(c2PdDfEmpT)
			cIdErro += " 1428,"
			lNotPDEmp := .T.
		EndIf
	EndIf

	If (RHR->RHR_ORIGEM == '2' .and. RHR->RHR_TPFORN == "2" .and.RHR->RHR_VLREMP > 0 )
		If Empty(c2PdEmprDep)
			cIdErro += " 718,"
			lNotPDEmp := .T.
		EndIf
		If lRHKDatFim .AND. !Empty(cPdDif) .AND. Empty(c2PdDfEmpD)
			cIdErro += " 1429,"
			lNotPDEmp := .T.
		EndIf
	EndIf

	If (RHR->RHR_ORIGEM == '3' .and. RHR->RHR_TPFORN == "2" .and.RHR->RHR_VLREMP > 0 )
		If Empty(c2PdEmprAgr)
			cIdErro += " 719,"
			lNotPDEmp := .T.
		EndIf
		If lRHKDatFim .AND. !Empty(cPdDif) .AND. Empty(c2PdDfEmpD)
			cIdErro += " 1429,"
			lNotPDEmp := .T.
		EndIf
	EndIf


	If lNotPDEmp
		Exit
	EndIf

	If Len( aMatPD ) > 0
		nLine := aScan( aMatPD, { |x,y| x[1] == RHR->RHR_PD } )
	EndIf

	cPDFind := ""
	If RHR->RHR_ORIGEM == "1" .and. RHR->RHR_TPFORN == "1"
		cPDFind 	:= c1PdEmprTit
		cPdEmpDif	:= c1PdDfEmpT
		cPdTot 		:= c1PdTotTit
	ElseIf RHR->RHR_ORIGEM == "2" .and. RHR->RHR_TPFORN == "1"
		cPDFind 	:= c1PdEmprDep
		cPdEmpDif 	:= c1PdDfEmpD
		cPdTot 		:= c1PdTotDep
	ElseIf RHR->RHR_ORIGEM == "3" .and. RHR->RHR_TPFORN == "1"
		cPDFind 	:= c1PdEmprAgr
		cPdEmpDif 	:= c1PdDfEmpD
		cPdTot 		:= c1PdTotAgr
	ElseIf RHR->RHR_ORIGEM == "1" .and. RHR->RHR_TPFORN == "2"
		cPDFind 	:= c2PdEmprTit
		cPdEmpDif 	:= c2PdDfEmpT
		cPdTot 		:= c2PdTotTit
	ElseIf RHR->RHR_ORIGEM == "2" .and. RHR->RHR_TPFORN == "2"
		cPDFind 	:= c2PdEmprDep
		cPdEmpDif 	:= c2PdDfEmpD
		cPdTot 		:= c2PdTotDep
	ElseIf RHR->RHR_ORIGEM == "3" .and. RHR->RHR_TPFORN == "2"
		cPDFind 	:= c2PdEmprAgr
		cPdEmpDif 	:= c2PdDfEmpD
		cPdTot 		:= c2PdTotAgr
	EndIf

	If nLine == 0 .OR. nAgrupa == 2

		if nAgrupa == 2 .AND. nLine > 0
			if empty(aMatPD[nLine][3])
				aMatPD[nLine][3] := "1"
			endIf
			 AEval( aMatPD,  { |x| iif(x[1]==RHR->RHR_PD, nSeq++,.F. ) } )
			 nSeq++
		endIf

		aAdd( aMatPD, {	RHR->RHR_PD, RHR->RHR_VLRFUN, iif(nSeq == 0,'',allTrim(STR(nSeq))), RHR->(Recno()) } )
		If RHR->RHR_PD $ cPdDif
			nLine := aScan( aMatPD, { |x,y| x[1] == cPDEmpDif } )
			If nLine == 0
				aAdd( aMatPD, {	cPDEmpDif, RHR->RHR_VLREMP,"",0 } )
			Else
				aMatPD[nLine, 2] += RHR->RHR_VLREMP
			EndIf
		Else
			nLine := aScan( aMatPD, { |x,y| x[1] == cPDFind } )
			If nLine == 0
				aAdd( aMatPD, {	cPDFind, RHR->RHR_VLREMP,"",0 } )
			Else
				aMatPD[nLine, 2] += RHR->RHR_VLREMP
			EndIf
			If !Empty(cPdTot)
				nLine := aScan( aMatPD, { |x,y| x[1] == cPdTot } )
				If nLine == 0
					aAdd( aMatPD, {	cPdTot, (RHR->RHR_VLRFUN+RHR->RHR_VLREMP), "", 0 } )
				Else
					aMatPD[nLine, 2] += (RHR->RHR_VLRFUN+RHR->RHR_VLREMP)
				EndIf			
			EndIf		
		EndIf

	Else
		aMatPD[nLine, 2] += RHR->RHR_VLRFUN
		If RHR->RHR_PD $ cPdDif
			nLine := aScan( aMatPD, { |x,y| x[1] == cPDEmpDif } )
			If nLine == 0
				aAdd( aMatPD, {	cPDEmpDif, RHR->RHR_VLREMP,"",0 } )
			Else
				aMatPD[nLine, 2] += RHR->RHR_VLREMP
			EndIf
		Else
			nLine := aScan( aMatPD, { |x,y| x[1] == cPDFind } )
			If nLine == 0
				aAdd( aMatPD, {	cPDFind, RHR->RHR_VLREMP,"",0 } )
			Else
				aMatPD[nLine, 2] += RHR->RHR_VLREMP
			EndIf
			If !Empty(cPdTot)
				nLine := aScan( aMatPD, { |x,y| x[1] == cPdTot } )
				If nLine == 0
					aAdd( aMatPD, {	cPdTot, (RHR->RHR_VLRFUN+RHR->RHR_VLREMP), "", 0 } )
				Else
					aMatPD[nLine, 2] += (RHR->RHR_VLRFUN+RHR->RHR_VLREMP)
				EndIf			
			EndIf	
		EndIf
	EndIf

	RHR->( DbSkip() )
EndDo

If !lNotPDEmp

	// Gravacao dos Registros
	nIndice := RetOrder( "RGB", "RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ" )
	Begin Transaction
		For nI := 1 To Len( aMatPD )
			// Somente gravar verbas com valor
			If aMatPD[nI,2] > 0.00
				// Caso a sequencia do Array seja maior que 9, quer dizer que possui 10 dependentes ou mais.
				If !Empty(aMatPD[nI,3]) .And. Val(aMatPD[nI,3]) >= 9
					nSeqDep ++
				EndIf
				lGrava := .T.
				DbSelectArea("RGB")
				DbSetOrder( nIndice )
				DbSeek( SRA->(RA_FILIAL+RA_MAT) + aMatPD[nI, 1] + cPeriodo + cSemana + aMatPD[nI, 3], .F. )
				If !Eof() .And. !(AllTrim(RGB->RGB_NUMID) == "UPDDIFPLA")
					If nSobrepor == 1
						RGB->( RecLock( "RGB" , .F. ) )
					Else
						aAdd( aLog[1], SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + If(lOfusca, Replicate('*',15), SRA->RA_NOME) + "   " + aMatPD[nI, 1] + "   " + Str( aMatPD[nI, 2], 12, 2) )
						lGrava := .F.
					EndIf
				Else
					RGB->( RecLock( "RGB" , .T. ) )
				EndIf

				If lGrava
					RGB->RGB_FILIAL 	:= 	SRA->RA_FILIAL
					RGB->RGB_MAT	 	:= 	SRA->RA_MAT
					RGB->RGB_CC			:= 	SRA->RA_CC
					RGB->RGB_PD			:= 	aMatPD[nI,1]
					RGB->RGB_PROCES		:=	SRA->RA_PROCES
					RGB->RGB_PERIOD		:= 	cPeriodo
					RGB->RGB_ROTEIR		:= 	cRoteiro
					RGB->RGB_ROTORI 	:=  cRotPLS
					RGB->RGB_SEMANA 	:=	cSemana
					RGB->RGB_TIPO1		:= 	"V"
					RGB->RGB_TIPO2		:= 	"G"
					RGB->RGB_HORAS		:= 	0
					RGB->RGB_VALOR		:= 	aMatPD[nI,2]
					RGB->RGB_PARCEL		:= 	0
					RGB->RGB_SEQ		:= 	aMatPD[nI, 3]
					//Se possuir 10 dependentes ou mais, utiliza a data de referencia da RGB para gravaГЦo.
					If nSeqDep > 0
						RGB->RGB_DTREF	:= dDtRef + (nSeqDep - 1)
					EndIf
					If lTemItem
						RGB->RGB_ITEM := SRA->RA_ITEM
					EndIf
					If lTemClVl
						RGB->RGB_CLVL := SRA->RA_CLVL
					EndIf

					If lGPM19RGB
						ExecBlock("GPM19RGB", .F. , .F., { cRotPLS, SRA->RA_FILIAL, SRA->RA_MAT, cPeriodo, cSemana } )
					EndIf

					MsUnLock()

					If !Empty(aMatPD[nI,4])
						RHR->(DbGoTo(aMatPD[nI,4]))
						If RecLock("RHR",.F.)
							RHR->RHR_INTFOL := "1"
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf
        Next nI

	End Transaction
Else
	aAdd(aTitle, OemToAnsi(STR0008))  //"Nao existem verbas vinculadas aos Identificadores de Bases de Assistencia Medica e Odontologica!"
	aAdd( aLog,{} )
	aAdd( aLog[1], STR0017 + SubStr(cIdErro,1,Len(cIdErro)-1 ) )
	lRet := .F.
EndIf

Return lRet
