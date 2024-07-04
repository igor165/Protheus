#Include "Protheus.ch"
#Include "TmsA190.ch"

//--- Estrutura aManComb
#DEFINE CTFILMAN  1 
#DEFINE CTMANIFE  2
#DEFINE CTSERMAN  3
#DEFINE CTRECMAN  4

Static cFilOri		:= ""
Static cViagem		:= ""
Static cFilMan_De	:= ""
Static cFilMan_Ate	:= ""
Static cManife_De	:= ""
Static cManife_Ate	:= ""
Static lMostraTela	:= .T.
Static cPFilOri		:= ""
Static cPViagem		:= ""
Static cPFilMan_De	:= ""
Static cPFilMan_Ate	:= ""
Static cPManife_De	:= ""
Static cPManife_Ate	:= ""
Static cCadastro    := STR0001 //'Manifesto de Carga'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa190  ³ Autor ³ Richard Anderson      ³ Data ³23.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manifesto de Carga.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa190()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS (Transporte)                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA190()
Local lPainel  := .F.
Local aSetKey  := {}

Private aRotina	  := MenuDef()

//-- Teclas de Atalhos
If AliasInDic("DL5")
	AAdd(aSetKey, { VK_F12 , { || Pergunte('TMA190D',.T.,,,,.T.)} } )
	TmsKeyOn(aSetKey)
EndIF

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76")

If lPainel
	If !Empty(aPanAgeTMS)
		&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + Str(aPanAgeTMS[3]) + ")")
	EndIf
Else
	mBrowse( 6,1,22,75,"DTX",,,,"Empty(DTX_NUMCTC)")
EndIf

Return Iif(lPainel,aRotina,Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa190Mnt³ Autor ³ Richard Anderson      ³ Data ³23.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao Manifesto de Carga.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA190Mnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA190Mnt( cAlias, nRecno, nOpc, cFilOri, cViagem, lVgeExpr, lConfirma , lManAutom, lMDFEAut,cFilger)

Local aRotOld   := {}
Local nOpcVge   := 4
Local lRet      := .T.
Local cObs
Local lTm190Exc := ExistBlock("TM190EXC")
Local lManViag  := GetNewPar("MV_MANVIAG",.F.)
Local lAberto   := .T.

//-- Controle de dimensoes de objetos
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aButtons  := {}
Local bEval     := {}

//-- Folder I
Local aPages    := {'HEADER'}
Local aTitles   := {STR0039} //'Documentos'
Local oFolder
//-- Folder II
Local aTitles2  := {STR0040} //'Resumo'
Local oFolder2
//-- Listbox I
Local cLbx      := ''
Local oLbx
//-- Listbox II
Local cLbx2     := ''
Local oLbx2

//-- Enchoice
Local oEnch
Local oDlgEsp
Local nOpca     := 0
Local nCntFor   := 0
Local lIncOld   := Inclui
Local nMdfeExc  := SuperGetMv( "MV_MDFEEXC", .F., 0   ) //-- Prazo em horas para cancelamento do MDF-e autorizado
Local nHoras    := 0
Local cObsCan   := ""
Local cSerieMDF := ""
Local lDTX_PRMACO := DTX->(FieldPos("DTX_PRMACO")) > 0
Local lPergA    := .T.
Local cAtivSai := SuperGetMV('MV_ATIVSAI',,'') //-- Atividade de Saida de Viagem
Local cQuery	:= ""
Local cAliasQry	:= ""
Local cAtvChgC 	:= SuperGetMv("MV_ATVCHGC",,'')
Local cAtivChg 	:= SuperGetMv("MV_ATIVCHG",,'')
Local cAtvSaiC 	:= SuperGetMV('MV_ATVSAIC',,'')
Local aManComb  := {}
Local cManfsExc := ""
Local nQtVeicDTR:= 0
Local nCExtMdf  := SuperGetMv("MV_CEXTMDF",,0)		//-- Cancelamento Extemporaneo do MDFe  
Local nPrazo    := 0
Local cAtvChgApo:= SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local cAtvSaiApo:= SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local lMdfeSrv  := .T.
Local aAreas    := {}
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lAltSerie := ExistBlock("TMALTSERIE")
Local cSerie	:= ""

Default lMDFEAut  := .F.
Default lManAutom := "TMSA14" $ Substr(FunName(),1,6) .Or. IsInCallStack("TMSAF90GRV") //Identifica se a chamada do manifesto veio do carregamento automatico
Default cFilOri   := ""
Default cViagem   := ""
Default lVgeExpr  := .F.
Default lConfirma := .T.
Default cFilger   := ""

Private aTela[0][0]
Private aGets[0]
Private aDoctos  := {}
Private aTotal   := {}
Private cSerman := SuperGetMv( "MV_SERMAN", .F., ""   ) //-- Série do Manifesto
Private cTipMan := "1"

If Type("aRotina") == "U"
	Private aRotina := MenuDef()
EndIf
aRotOld:= aClone(aRotina) // Salva o aRotina.

If lAltSerie
	cSerie := ExecBlock("TMALTSERIE",.F.,.F., {"TMSA190", cSerie, cFilAnt }) // PE retorna a serie á ser usada no MDFe
	If ValType(cSerie) == "C" .And. !Empty(cSerie)
		cSerman := cSerie
	EndIf
EndIf

If ExistFunc("TmsAutViag") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0
	aAreas := {DTQ->(GetArea()),GetArea()}
	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial("") + cFilOri + cViagem))
		If TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA190")
			lMDFeAut := .T.
		EndIf
	EndIf
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
EndIf

If Left(FunName(),7) == "TMSA190" .Or. (!lMDFeAut .And. lVgeMod3 )
	nOpc := aRotina[nOpc,4]
Endif
If nOpc == 2

    RegToMemory("DTX", .F.)

	Aadd(aButtons,	{'CARGA',{||TmsVisViag(DTX->DTX_FILORI,DTX->DTX_VIAGEM)},STR0041, STR0041}) //"Viagem"

	If !Empty(DTX->DTX_SERMAN)
		cSerieMDF := DTX->DTX_SERMAN
	EndIf

	//-- Carrega o Vetor com os documentos do Manifesto
	TMSA190Doc(DTX->DTX_FILORI, DTX->DTX_VIAGEM, DTX->DTX_FILMAN, DTX->DTX_MANIFE, cSerieMDF, Iif(lDTX_PRMACO,DTX->DTX_PRMACO,''))

	If Len(aDoctos) > 0
		//-- Calcula as dimensoes dos objetos
		aSize  := MsAdvSize(.T.)

		AAdd( aObjects, { 100,35,.T.,.T. } )
		AAdd( aObjects, { 100,50,.T.,.T. } )
		AAdd( aObjects, { 100,30,.T.,.T. } )

		aInfo   := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )

		DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
			//-- Monta a Enchoice
			oEnch := MsMGet():New( "DTX", nRecno, nOpc, , , , , aPosObj[1], , 3, , , , , ,.T. )

			//-- Monta o Objeto Folder contendo os documentos do manifesto
			oFolder := TFolder():New( aPosObj[2,1], aPosObj[2,2], aTitles, aPages, oDlgEsp,,,,.T.,.T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

			For nCntFor := 1 To Len( oFolder:aDialogs )
				oFolder:aDialogs[ nCntFor ]:oFont := oDlgEsp:oFont
			Next

			@ 0, 0 LISTBOX oLbx VAR cLbx FIELDS HEADER STR0042 , STR0043 , STR0044 , STR0038 , STR0037 , STR0038 , STR0036 , STR0034 ,; //'CTRC','Serie','Remetente','Insc.Estadual','Destinatario', 'Insc.Estadual','Cidade','UF'
			        STR0033 , STR0032 , STR0031 , STR0030 , STR0029 , STR0028 , STR0027 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1]-15	OF oFolder:aDialogs[1] ON DBLCLICK ( .T. ) PIXEL //'Vols.','Peso Real','Peso Cob.','Valor Merc.','Tp.Frete','Filial Orig.', 'Filial Dest.'
			oLbx:SetArray(aDoctos)
			oLbx:bLine:={ || aDoctos[ oLbx:nAT ] }

			//-- Monta o Objeto Folder contendo o resumo do Manifesto
			oFolder2:=TFolder():New( aPosObj[3,1], aPosObj[3,2], aTitles2, aPages, oDlgEsp,,,,.T.,.T.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1])

			For nCntFor := 1 To Len( oFolder2:aDialogs )
				oFolder2:aDialogs[ nCntFor ]:oFont := oDlgEsp:oFont
			Next

			@ 0, 0 LISTBOX oLbx2 VAR cLbx2 FIELDS HEADER '', STR0030 , STR0026 , STR0025 , STR0024 , STR0023 , STR0022 , STR0032 , STR0021 , STR0020 SIZE aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1]-15	OF oFolder2:aDialogs[1] ON DBLCLICK ( .T. ) PIXEL //' Valor Merc. ',' Valor Frete ','Valor N. Tributavel',' Valor Tributavel ',' Valor ICMS ',' Volumes ',' Peso Real ',' Peso Cobrado ','No. CTRCs'
			oLbx2:SetArray(aTotal)
			oLbx2:bLine:={ || aTotal[ oLbx2:nAT ] }

		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar( oDlgEsp, { || nOpca := 1,oDlgEsp:End()}, {||oDlgEsp:End()},,aButtons)
	EndIf

ElseIf nOpc == 5
	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
	If !TMSAVerAge("7",,,,,,,,,,,,"2",.T.,.T.,,mv_par02,)
		Return .F.
	EndIf

	If ( ExistBlock('TMMANVIAG') )
		lRet := ExecBlock('TMMANVIAG',.F.,.F.)
		If !lRet
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help("", 1, "TMSA19014") // "Não é permitido excluir manifesto."
			Return .F.
		EndIf
	EndIf
	If !Empty(DTX->DTX_NUMAWB) //Manifesto com AWB relacionada.
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help("", 1, "TMSA19013") // "Não é permitido excluir manifesto com AWB relacionada"
		Return .F.
	EndIf

	If DTQ->DTQ_STATUS = "2"	// Viagem em transito.

		cQuery += "SELECT DTW_ATIVID"
		cQuery += "	FROM " + RetSqlName("DTW") + " DTW "
		cQuery += "	WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "'"
		cQuery += "		AND DTW.DTW_FILORI = '" + DTQ->DTQ_FILORI + "'"
		cQuery += "		AND DTW.DTW_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
		cQuery += "		AND DTW.DTW_STATUS = '2'"
		cQuery += "		AND DTW.D_E_L_E_T_ = ' '"
		cQuery += "	ORDER BY "

		If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .AND. DTW->(ColumnPos("DTW_SYSHOR")) > 0
			cQuery += "DTW.DTW_SYSDAT DESC, DTW.DTW_SYSHOR DESC, DTW.DTW_DATREA DESC, DTW.DTW_HORREA DESC"
		Else
			cQuery += "DTW.DTW_DATREA DESC, DTW.DTW_HORREA DESC"
		EndIf

		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		While (cAliasQry)->(!Eof())
			If (cAliasQry)->DTW_ATIVID == cAtivSai .OR. (cAliasQry)->DTW_ATIVID == cAtvSaiC .OR. (cAliasQry)->DTW_ATIVID == cAtvSaiApo   
				Help('', 1, "TMSA19022", , STR0067, 1) // "É possível excluir manifestos somente quando a última operação apontada for de Chegada em Cliente ou Apoio."
				(cAliasQry)->(dbCloseArea())
				Return .F.
			ElseIf (cAliasQry)->DTW_ATIVID == cAtvChgC .OR. (cAliasQry)->DTW_ATIVID == cAtivChg .Or. (cAliasQry)->DTW_ATIVID == cAtvChgApo
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		End

		(cAliasQry)->(dbCloseArea())
	EndIf

	If !FWChkFuncAccess('TMSA190', 4, .F.)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help('',1,'TMSA19021') //-- Usuario sem acesso a rotina de exclusao.
		Return .F.
	EndIf

	If DTX->(FieldPos("DTX_STIMDF")) > 0
		If  !Empty(DTX->DTX_CHVMDF) 
			If  DTX->DTX_STIMDF = '1'
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help("", 1, "TMSA19018")	// "Não é permitido excluir manifesto. Aguardando retorno da Sefaz"
				Return .F.

			ElseIf Empty(DTX->DTX_STIMDF) .And. DTX->DTX_IDIMDF <> '100' .And. ( DTX->DTX_STATUS == '0' .Or. DTX->DTX_STATUS == '1' )
				
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help("", 1, "TMSA19018")	// "Não é permitido excluir manifesto. Aguardando retorno da Sefaz"
				Return .F.

			EndIf
		EndIf

		If DTX->DTX_STIMDF == '2' .And. DTX->DTX_STFMDF <> '2' // 100 - Autorizado o uso do CT-e
			nHoras := Round(SubtHoras( DTX->DTX_DATMAN, SubStr(DTX->DTX_HORMAN,1,2) + ":" + SubStr(DTX->DTX_HORMAN,3,2) , ;
			Date(), 		  SubStr(Time(),1,2)		  + ":" + SubStr(Time(),4,2) ),2) //Prazo em Horas
			If nHoras > nMdfeExc
				If nCExtMdf > 0
					nPrazo := SubtHoras(DTX->DTX_DATMAN,SubStr(DTX->DTX_HORMAN,1,2) + ":" + SubStr(DTX->DTX_HORMAN,3,2),dDataBase,SubStr(Time(),1,2) + ":" + SubStr(Time(),4,2)) / 24	//-- Prazo em dias
					If nPrazo > nCExtMdf
					    //'TMSA19025'
						Help("",1,"HELP",, STR0073 + ' ' + STR0072 + " : " + Alltrim(STR(nCExtMdf)) + " " + STR0070 ,5,4,,,,,,{STR0074})  //"Não é permitido excluir o manifesto. Prazo para cancelamento extemporâneo do MDF-e inválido. Parametro MV_CEXTMDF"
						lRet:=.F.
					EndIf	
				Else
					Help(' ', 1, 'TMSA19015', , STR0072 + ": " + Alltrim(STR(nMdfeExc)) + " " + STR0069 ,5,1 )  // Prazo para cancelamento do MDF-e ultrapassado. / horas
					lRet:=.F.
				EndIf
			EndIf

			If lRet
				If lMdfeAut .And. !lConfirma
					cObsCan := STR0071 //"Cancelamento Automático do Sistema"
				Else
				    lRet:= TMSA190Obs(@cObsCan)
				EndIf
			EndIf

			If !lRet
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return .F.
			EndIf

		ElseIf DTX->DTX_STFMDF == '2' 
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help("", 1, "TMSA19017")
			Return .F.
		EndIf
	EndIf

	If Empty(DTX->DTX_NUMCTC) // Em Aberto
		/* Se o parametro MV_MANVIAG estiver desabilitado, somente permitir excluir os manifestos para viagens em aberto. */
		If lManViag .And. DTQ->DTQ_FILORI <> cFilAnt
			lAberto := .F. //-- Nao verifica se a viagem esta em Aberto
		EndIf
		If ! TMSChkViag( DTX->DTX_FILORI, DTX->DTX_VIAGEM, lAberto, .F., .F., , .F., , , .T., .T. )
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return .F.
		EndIf

		If lTm190Exc //PE de tratamento da exclusao do manifesto
			lRet := ExecBlock("TM190EXC",.F.,.F.)
		EndIf

		If lRet .And. lConfirma
			aManComb := {}

			If lDTX_PRMACO 
				nQtVeicDTR:= TMA190VCom(DTX->DTX_FILORI, DTX->DTX_VIAGEM) //-- Verifica se é uma viagem de Comboio
	
				If nQtVeicDTR > 1 //Verifica se existe mais de um Manifesto Comboio
					TMA190MaCm(DTX->DTX_FILMAN, DTX->DTX_MANIFE, DTX->DTX_SERMAN,.T.,@cManfsExc,@aManComb)
				EndIf
			EndIf

			If !Empty(cManfsExc) //Comboio
				//"O Manifesto que esta sendo excluído foi gerado a partir de processo de comboio. Por conta disso, os Manifestos a seguir também serão excluidos: XXXX. Confirma exclusão?"
				lRet := MsgYesNo(STR0062 + cManfsExc + STR0063)
			Else
				lRet := MsgYesNo( STR0006 + DTX->DTX_MANIFE + " ?")  //"Deseja realmente excluir o manifesto "
			EndIf	

		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Excuta a funcao para excluir o Manifesto.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FWMsgRun(, {|| TmsA190Proc(.T., DTX->DTX_FILORI, DTX->DTX_VIAGEM, cObsCan, aManComb)},STR0008)   //"Excluindo Manifesto. Por favor aguarde..."
		EndIf
	Else
		Help("", 1, "TMSA19001") // "Ja existe contrato para esse Manifesto."
	EndIf

ElseIf nOpc == 3

	If ( ExistBlock('TMMANVIAG') )
		lRet := ExecBlock('TMMANVIAG',.F.,.F.)
		If !lRet
			Help("", 1, "TMSA19014") // "Não é permitido excluir manifesto.
			Return .F.
		EndIf
	EndIf

	//-- Pergunte TmsA190A: Variaveis utilizadas como parametros
	// mv_par01		Tipo Manifesto              1- Normal / 2- Eletronico
	//
	// Em seguida, de acordo com o retorno do TMA190A, eh aberto outro Pergunte:
	//-- Pergunte TmsA190B (Caso Manifesto Eletronico): Variaveis utilizadas como parametros
	// mv_par01		Filial Origem            ?
	// mv_par02		Viagem                   ?
	//
	//-- Pergunte TmsA190C (Caso Manifesto Normal): Variaveis utilizadas como parametros
	// mv_par01		Filial Origem            ?
	// mv_par02		Viagem                   ?
	// mv_par03		Separar por Filial       ? 1=Descarga / 2=Destino / 3=Nao separa
	// mv_par04		Separar Filial de Origem ? 1=Sim / 2=Nao
	// mv_par05		Separar por Estado       ? 1=Sim / 2=Nao
	// mv_par06		Separar Regioes Isentadas? 1=Sim / 2=Nao
	// mv_par07		Separar Carga Perigosa   ? 1=Sim / 2=Nao
	// mv_par08		Imprime Manifesto        ? 1=Sim / 2=Nao
	// mv_par09		Separar Regioes Destinos ? 1=Sim / 2=Nao
	// mv_par10		Quantidade de Documentos por manifesto

	//Se o campo do Tipo de Manifesto ainda nao constar na base, utilizar o Pergunte antigo.
	If DTX->(FieldPos("DTX_TIPMAN")) > 0
		If lMDFEAut
	        SetMVValue("TMA190A","MV_PAR01",2)	// Manifesto Eletrônico
			Pergunte("TMA190A", .F.)
			cTipMan := cValToChar(mv_par01)
			If cTipMan == "2"    //Manifesto eletronico
                If Empty(cSerman)
	                Help("",1,"TMSA19027") // É obrigatório o preenchimento do parâmetro MV_SERMAN para geração e transmissão do MDF-e !!
	                Return .F.
                EndIf
				mv_par03 := 1    //Separar por Filial       ? 1=Descarga / 2=Destino / 3=Nao separa
				mv_par04 := 2	   //Separar Filial de Origem ? 1=Sim / 2=Nao
				mv_par05 := 1    //Separar por Estado       ? 1=Sim / 2=Nao (Informe se deve separar por estado da regiao de calculo)
				mv_par06 := 2	   //Separar Regioes Isentadas? 1=Sim / 2=Nao
				mv_par07 := 2	   //Separar Carga Perigosa   ? 1=Sim / 2=Nao
				mv_par08 := 2    //Imprime Manifesto        ? 1=Sim / 2=Nao
				mv_par09 := 2	   //Separar Regioes Destinos ? 1=Sim / 2=Nao
				mv_par10 := 9999 //Quantidade de Documentos por manifesto
			EndIf
			lPergA := .T.
		Else
			lPergA := .F.
		EndIf

		If !lMDFEAut .And. Pergunte("TMA190A", .T.)
			cTipMan := cValToChar(mv_par01)
			If cTipMan == "2"    //Manifesto eletronico
			  If Empty(cSerman)
	                Help("",1,"TMSA19027") // É obrigatório o preenchimento do parâmetro MV_SERMAN para geração e transmissão do MDF-e !!
	                Return .F.
                EndIf	
				mv_par03 := 1    //Separar por Filial       ? 1=Descarga / 2=Destino / 3=Nao separa
				mv_par04 := 2	   //Separar Filial de Origem ? 1=Sim / 2=Nao
				mv_par05 := 1    //Separar por Estado       ? 1=Sim / 2=Nao (Informe se deve separar por estado da regiao de calculo)
				mv_par06 := 2	   //Separar Regioes Isentadas? 1=Sim / 2=Nao
				mv_par07 := 2	   //Separar Carga Perigosa   ? 1=Sim / 2=Nao
				mv_par08 := 2    //Imprime Manifesto        ? 1=Sim / 2=Nao
				mv_par09 := 2	   //Separar Regioes Destinos ? 1=Sim / 2=Nao
				mv_par10 := 9999 //Quantidade de Documentos por manifesto
			EndIf
			lPergA := .T.
		Else
			lPergA := .F.
		EndIf
	Else
		cTipMan := "1"
	EndIf

	If cTipMan == "2" .And. lMDFEAut .And. !(IsInCallStack("TMSA310GRV") .Or. IsInCallStack("TMSA350MNT") .Or. IsInCallStack("TMSA350EST"))
		If !Empty(cFilOri) .And. !Empty(cViagem) //Verifica o serviço de transporte da viagem
			lMdfeSrv:= TMA190Srv(cFilOri,cViagem)  
		EndIf

		If lMdfeSrv  
			//Não é permitido gerar MDF-e para viagem quando o parâmetro MV_MDFEAUT estiver habilitado.
			//"Para a geração manual do MDF-e será necessário desabilitar o paramentro MV_MDFEAUT, ATENÇÃO - Isso poderá gerar MDF-e conflitantes, para maiores informações consultar documentação."
			Help("",1,"TMSA19026")  
			Return .F.
		EndIf
	EndIf

	// Seta a viagem posicionada na parametrização do manifesto
	If !lManAutom  
		If lVgeMod3 .And. Empty(cViagem) //--- Executada a rotina pela Vge Mod3 (Browse Doctos)
			cFilOri:= DTQ->DTQ_FILORI
			cViagem:= DTQ->DTQ_VIAGEM
		EndIf
		// Fil. Origem
		SetMVValue(Iif(cTipMan=="2","TMA190B","TMA190C"),"MV_PAR01",cFilOri)

		//Viagem
		SetMVValue(Iif(cTipMan=="2","TMA190B","TMA190C"),"MV_PAR02",cViagem)
	EndIf

	If lPergA .And. (Pergunte(Iif(cTipMan=="2","TMA190B","TMA190C"), Iif(lManAutom,.F.,.T.).Or. lMDFEAut ))
		//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
		If !TMSAVerAge("7",,,,,,,,,,,,"2",.T.,.T.,,mv_par02,)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return .F.
		EndIf

		cFilOri := mv_par01
		cViagem := mv_par02
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente permitir gerar manifestos para viagens de transporte           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DTQ")
		DbSetOrder(2)
		DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
		If !TMSChkViag( cFilOri, cViagem, .F., .F., .F., , .F., , , .T., .T. )
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return .F.
		EndIf

		If	DTQ->DTQ_SERTMS != '2' .And. DTQ->DTQ_SERTMS != '3'
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help("",1,"TMSA19006") // So sera permitido Gerar Manifesto para Viagens de Transporte ou Entrega
			Return .F.
		EndIf

		If	DTQ->DTQ_STATUS $ '3|9'
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help("",1,"TMSA19023") // Não é permitida geração de manifestos com a viagem com status de encerrada ou cancelada.
			Return .F.
		EndIf

		If lMDFeAut   //Verifica o serviço de transporte da viagem
			lMDFeAut:= TMA190Srv(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
		EndIf	

		If	DTQ->DTQ_STATUS $ '1' .AND. lMDFeAut		
			Help("",1,"TMSA19024") // Não é permitido gerar MDf-e para viagens em aberto quando parâmetro MV_MDFEAUT estiver habilitado.
			Return .F.
		EndIf

		If ExistFunc('TM73OpeCli') .And. DTQ->DTQ_STATUS == '2' 
			lOk:= TM73OpeCli( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )  
			If !lOk
				Help( ' ', 1, 'HELP',, STR0068,3,0) // Não é permitido gerar o Manifesto para viagem em Transito sem o apontamento da Operação de Chegada em Cliente ou Apoio.
				Return .F.
			EndIf
		EndIf

		If !AliasInDic("DL0")
			DTR->( DbSetOrder( 1 ) )
			If DTR->( MsSeek( xFilial("DTR") + cFilOri + cViagem ) )
				Altera := .T.
				Inclui := .F.
			Else
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help( " ", 1, "TMSA24002",, STR0015 + cFilOri + " " + cViagem, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR).	//'Viagem : '
				Return .F.
			EndIf

			//-- Observacao da Viagem

			cObs := MsMM(DTQ->DTQ_CODOBS,80)

			If (lManViag .And. DTQ->DTQ_FILORI <> cFilAnt)
				bEval := { || .T.}
			Else
				DTY->( DbSetOrder( 2 ) )
				If DTY->(MsSeek(xFilial('DTY') + cFilOri + cViagem)) .And. DTY->DTY_FILORI == cFilAnt
					//Se tiver Contrato chama o Complemento como Visualizacao, evitando que o usuario altere os dados
					bEval := { || TMSA240Mnt( 'DTR', DTR->( Recno() ), 2, cFilOri, cViagem,,,,,cObs,,,lConfirma,,!lVgeExpr) == 1	}
					Inclui := .F.
				Else
					bEval := { || TMSA240Mnt( 'DTR', DTR->( Recno() ), nOpcVge, cFilOri, cViagem,,,,,cObs,,,lConfirma,,!lVgeExpr) == 1	}
				EndIf
			EndIf

		EndIf

		If Iif(AliasInDic("DL0"),.T.,Eval(bEval))

			If cTipMan == "2"    //Manifesto eletronico
				mv_par03 := 1    //Separar por Filial       ? 1=Descarga / 2=Destino / 3=Nao separa
				mv_par04 := 2	   //Separar Filial de Origem ? 1=Sim / 2=Nao
				mv_par05 := 1    //Separar por Estado       ? 1=Sim / 2=Nao (Informe se deve separar por estado da regiao de calculo)
				mv_par06 := 2	   //Separar Regioes Isentadas? 1=Sim / 2=Nao
				mv_par07 := 2	   //Separar Carga Perigosa   ? 1=Sim / 2=Nao
				mv_par08 := 2    //Imprime Manifesto        ? 1=Sim / 2=Nao
				mv_par09 := 2	   //Separar Regioes Destinos ? 1=Sim / 2=Nao
				mv_par10 := 9999 //Quantidade de Documentos por manifesto
			EndIf

			Inclui := lIncOld

			If ExistBlock("TMA190TOk")
				lRet := ExecBlock("TMA190TOk",.F.,.F.)
			EndIf

			If lRet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao Gerar Manifesto, se nao foi informado nenhum Veiculo  para a Viagem  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DTR->(dbSetOrder(3))
				If !DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem))
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help("",1,"TMSA19008") //  O Manifesto Nao sera gerado porque nao foi informado Veiculo para esta viagem ...
					Return .F.
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao Gerar Manifesto, se nao foi informado nenhum Motorista para a Viagem ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DUP->(dbSetOrder(2))
				If !DUP->(MsSeek(xFilial('DUP')+cFilOri+cViagem)) .Or. Empty(DUP->DUP_CODMOT)
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help("",1,"TMSA1907") //  O Manifesto Nao sera gerado porque nao foi informado motorista para esta viagem ...
					Return .F.
				EndIf

				If TMS190LDUD(cFilOri, cViagem) .And. !lMdfeAut
					FWMsgRun(, {|| lRet:= TmsA190Proc(.F., cFilOri, cViagem ) }, STR0011)  //"Manifesto de Carga"
				EndIf

			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura o aRotina.                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRotina := aClone(aRotOld)
		EndIf
		//--MDFe Automático
		If lMdfeAut
			FWMsgRun(, {|| lRet:= TmsA190Proc(.F., cFilOri, cViagem ) }, STR0011)  //"Manifesto de Carga"
		EndIf
	EndIf
EndIf
//--MDFe Automático
If lMdfeAut   //Verifica o serviço de transporte da viagem
	lMdfeAut:= TMA190Srv(cFilOri,cViagem)
EndIf	 
If  nOpc == 3 .And. lMdfeAut
	
	FWMsgRun(, {|| lRet:= TmsA190Proc(.F., cFilOri, cViagem ) }, STR0011)  //"Manifesto de Carga"
EndIf

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa190Pro³ Autor ³ Richard Anderson      ³ Data ³23.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava ou exclui o Manifesto de Carga.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA190Proc(ExpL1,ExpC2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. = Excluir                                      ³±±
±±³          ³ ExpC2 = Filial de Origem                                   ³±±
±±³          ³ ExpC3 = Viagem                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA190Proc(lExcluir, cFilOri, cViagem, cObsCan, aManComb)

Local aAreaDUD    := DUD->(GetArea())
Local lAchouDoc   := .F.
Local nA          := 0
Local nC          := 0
Local cManife     := ""
Local aManifestos := {}
Local aDataBase   := {}
Local dDatMan	    := ""
Local cHoraBase   := ""
Local lTm190Grv   := ExistBlock("TM190GRV")
Local lTm190Fim   := ExistBlock("TM190FIM")
Local cSerie      := ""
Local lDTX_CDRDES := DTX->(FieldPos("DTX_CDRDES")) > 0
Local lDTX_CODVEI := DTX->(FieldPos("DTX_CODVEI")) > 0
Local lDUD_FILATU := DUD->(FieldPos("DUD_FILATU")) > 0
Local lManViag    := GetNewPar("MV_MANVIAG",.F.)
Local lTm190Fil   := ExistBlock('TM190FIL') //-- Permite ao usuario, incluir filtro.
Local lRet        := .T.
Local lRetTran    := .T.
Local cMdfeDoc    := SuperGetMV('MV_MDFEDOC',,'')
Local lHVerao     := SuperGetMV("MV_TMSHRVR",,.F.)	//-- Define se encontra-se no periodo de horario de verao.
Local cHVerFil    := SuperGetMV("MV_TMSHRFL",,"")	//-- Define Filiais que nao aderiram ao horario de verao e/ou possuem diferenca de fuso.
Local cUF         := SuperGetMV("MV_ESTADO",.F.,"") //-- Define o estado da filial
Local lMdfeAut    := SuperGetMV("MV_MDFEAUT",,.F.)  .And. ExistFunc("TmsMDFeAut") //--MDFe Automatico
Local aTipoDoc    := Iif(!Empty(cMdfeDoc),Str2Arr(Upper(cMdfeDoc), ","),'')  //quebra em array por delimitador "+"
Local aViagens    := {}
Local aVgaPrinc   := {}
Local cQuery      := ""
Local cAliasTop   := GetNextAlias()
Local lVgaCol     := .F.
Local aVgaColig   := {}
Local lTm190Clg   := ExistBlock("TM190CLG")
Local aVgaClg     := {}

Local nQtVeicDTR  := 1
Local nCntVeiDTR  := 1
Local cCntVeiDTR  := ''
Local cPrMaCo     := ''
Local lDTX_PRMACO := DTX->(ColumnPos("DTX_PRMACO")) > 0

Local aCteSemAvb  := {}
Local cFiltroVge  := ''
Local cAliasDL5   := GetNextAlias()
Local nValidAvb   := 1

Local cIdEnt		:= ""
Local aListMDFE	:= {}
Local lLimpaDL0	:= .F.
Local aDocs     := {}
Local lUFAtiv   := DTX->(ColumnPos("DTX_UFATIV")) > 0
Local cTipoLote	:= ""
Local lVgeComb  := .F.
Local aAreaAnt  := {}
Local nCnt      := 0
Local nRecDTX   := 0
Local nQtVeic   := 0
Local lRoteiro	:= .F. 
Local lBloqueia := .F.

Private lUsaColab := UsaColaboracao("5")
Private lInCond   := .F.

Default lExcluir  := .F.
Default cObsCan   := ""
Default aManComb  := {}

If lExcluir
    
	If lDTX_PRMACO 
		If Len(aManComb) > 1
			lVgeComb:= .T.
		Else
			nQtVeic:= TMA190VCom(DTX->DTX_FILORI, DTX->DTX_VIAGEM)   //-- Verifica se é uma viagem de Comboio
			If nQtVeic > 1   //Verifica se existe mais de um Manifesto Comboio
				TMA190MaCm(DTX->DTX_FILMAN, DTX->DTX_MANIFE, DTX->DTX_SERMAN,.T.,,@aManComb)
				If Len(aManComb) > 1
					lVgeComb:= .T.
				EndIf
			EndIf
		EndIf	
	EndIf

	If !lVgeComb
		TMA190DYN(cObsCan)  //Grava Tabela para envio do Cancelamento da MDFe	

		//-- Se o MV_MDFEAUT estiver configurado com .T. realiza a transmissão do Cancelamento do MDF-e
		If DTX->DTX_TIPMAN == '2' .And. DTX->DTX_STIMDF == '2'
			If lMDFeAut   //Verifica o serviço de transporte da viagem
				lMDFeAut:= TMA190Srv(DTX->DTX_FILORI,DTX->DTX_VIAGEM)
			EndIf	
	
			If lMdfeAut
				Aadd(aDocs,{DTX->DTX_FILMAN,;
							DTX->DTX_MANIFE,;
							DTX->DTX_MANIFE,;
							DTX->DTX_SERMAN,;
							DTX->DTX_VIAGEM,;
							Iif(lUFAtiv, DTX->DTX_UFATIV, '')})
				TmsMDFeAut(aDocs, 3)
			EndIf

			//-- Verifica se MDF-e teve o cancelamento autorizado pela SEFAZ
			If SuperGetMv("MV_MDFECAN",,.F.) == .T.
				/* Consulta TSS para validar a existencia da transmissão do MDF-e e verificar seu status*/
				If CTIsReady( ,,,lUsaColab )
					cIdEnt    := RetIdEnti( lUsaColab )
					cSerie    := DTX->DTX_SERMAN
					cNotaIni  := DTX->DTX_MANIFE
					cNotaFim  := DTX->DTX_MANIFE
					aListMDFE := WsMDFeMnt(cIdEnt,cSerie,cNotaIni,cNotaFim,.F.,.T.)
				Else
					Help("",1,"TMSA190","TMSA190","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",1,2)
					Return .F.
				EndIf

				If DTX->DTX_TIPMAN == '2' .And. DTX->DTX_STIMDF == '2'
					If !(DYN->DYN_STCMDF $ "2") .And. !(SubStr(DYN->DYN_RTCMDF,1,3) $ "101")
						// ( [ uPar1 ] [ uPar2 ] [ cCampo ] [ cNome ] [ cMensagem ] [ nLinha1 ] [ nColuna ] [ lPop ] [ uPar9 ] [ uPar10 ] [ uPar11 ] [ lGravaLog ][aSoluc] )
						Help("",1,"TMSA190","TMSA190CAN",STR0058,1,2,,,,,,{{"Faça a transmissão do cancelamento do MDF-e."}}) //-- "Somente documentos com cancelamento autorizado pela SEFAZ poderão ser excluídos, realize a transmissão do cancelamento antes de continuar."
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf

	Else //Manifesto em Comboio
		cManfsExc:= ""
		nRecDTX:= DTX->(Recno()) 

		For nCnt:= 1 To Len(aManComb)
			DTX->(dbGoTo(aManComb[nCnt][CTRECMAN]))
			TMA190DYN(cObsCan)  //Grava Tabela para envio do Cancelamento da MDFe
			
			If Empty(cManfsExc)
				cManfsExc +=  "('" + DTX->DTX_MANIFE + "' "
			Else
				cManfsExc += ", '" + DTX->DTX_MANIFE
			EndIf	

			If DTX->DTX_TIPMAN == '2' .And. DTX->DTX_STIMDF == '2'
				Aadd(aDocs,{DTX->DTX_FILMAN,;
							DTX->DTX_MANIFE,;
							DTX->DTX_MANIFE,;
							DTX->DTX_SERMAN,;
							DTX->DTX_VIAGEM,;
							Iif(lUFAtiv, DTX->DTX_UFATIV, '')})
			EndIf
		Next nCnt
		DTX->(dbGoTo(nRecDTX))

		If !Empty(cManfsExc)
        	cManfsExc+= "') "
		EndIf	
		
		If lMdfeAut
			aAreaAnt:= GetArea()
			TmsMDFeAut(aDocs, 3)
			RestArea(aAreaAnt)
		EndIf

		aAreaAnt:= GetArea()
		nRecDTX:= DTX->(Recno())
		//-- Verifica se MDF-e teve o cancelamento autorizado pela SEFAZ
		If SuperGetMv("MV_MDFECAN",,.F.) == .T.
			For nCnt:= 1 To Len(aDocs)  
				DTX->(dbSetOrder(2))
				If DTX->(DbSeek(xFilial('DTX')+aDocs[nCnt][1]+aDocs[nCnt][2]+aDocs[nCnt][4]))
					DYN->(DbSetOrder(3)) //-- DYN_FILIAL+DYN_FILMAN+DYN_MANIFE+DYN_SERMAN+DYN_STCMDF
					If DYN->(DbSeek(DTX->(xFilial("DYN") + DTX_FILMAN + DTX_MANIFE + DTX_SERMAN)))

						/* Consulta TSS para validar a existencia da transmissão do MDF-e e verificar seu status*/
						If CTIsReady( ,,,lUsaColab )
							cIdEnt    := RetIdEnti( lUsaColab )
							cSerie   := DTX->DTX_SERMAN
							cNotaIni := DTX->DTX_MANIFE
							cNotaFim := DTX->DTX_MANIFE
							aListMDFE := WsMDFeMnt(cIdEnt,cSerie,cNotaIni,cNotaFim,.F.,.T.)
						Else
							Help("",1,"TMSA190","TMSA190","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",1,2)
							lRet:= .F.
							Exit
						EndIf

						If DTX->DTX_TIPMAN == '2' .And. DTX->DTX_STIMDF == '2'
							If !(DYN->DYN_STCMDF $ "2") .And. !(SubStr(DYN->DYN_RTCMDF,1,3) $ "101")
								Help("",1,"TMSA190","TMSA190CAN",STR0058,1,2,,,,,,{{"Faça a transmissão do cancelamento do MDF-e."}}) //-- "Somente documentos com cancelamento autorizado pela SEFAZ poderão ser excluídos, realize a transmissão do cancelamento antes de continuar."
								lRet:= .F.
								Exit
							EndIf
						EndIf
					EndIf	

				EndIf	
			Next nCnt	
		EndIf
		RestArea(aAreaAnt)
		DTX->(dbGoTo(nRecDTX))

		If !lRet
			Return .F.	
		EndIf
	
	EndIf

	ProcRegua(1)

	Begin Transaction

		cQuery :=  " SELECT DUD.R_E_C_N_O_ DUDRECNO FROM "
		cQuery +=  RetSqlName('DUD')+" DUD "
		cQuery +=  " WHERE  DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += " AND DUD.DUD_FILORI = '" + DTX->DTX_FILORI + "' 
		cQuery += " AND DUD.DUD_VIAGEM = '" + DTX->DTX_VIAGEM + "' 
		cQuery += " AND DUD.DUD_FILMAN = '" + DTX->DTX_FILMAN + "' 
		If lDTX_PRMACO
			cQuery += " AND DUD.DUD_MANIFE = '" + Iif(!Empty(DTX->DTX_PRMACO),DTX->DTX_PRMACO,DTX->DTX_MANIFE) + "' "
		Else
			cQuery += " AND DUD.DUD_MANIFE = '" + DTX->DTX_MANIFE + "' "
		EndIf	
		cQuery += " AND DUD.DUD_SERMAN = '" + DTX->DTX_SERMAN + "' "
		cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

		While (cAliasTop)->(!Eof())
			IncProc()

			DUD->(dbGoTo((cAliasTop)->DUDRECNO))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Limpa Seq. Carregamento e Documento do Manifesto                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("DUD", .F.)
			DUD->DUD_FILMAN := Space( Len( DUD->DUD_FILMAN ) )
			DUD->DUD_MANIFE := Space( Len( DUD->DUD_MANIFE ) )
			DUD->DUD_SERMAN := Space( Len( DUD->DUD_SERMAN ) )
			MsUnLock()
			
			(cAliasTop)->(dbSkip())
		EndDo
		(cAliasTop)->(DbCloseArea())
		
		// Limpa o Manifesto do Percurso
		If AliasInDic("DL0")
			DL0->( DbSetOrder( 2 ) )
			If DL0->(MsSeek( FWxFilial("DL0") + cFilOri + cViagem ))
				lLimpaDL0:= .T.
			Else
				// Verifica se a viagem é coligada
				DTR->( DbSetOrder( 1 ) )
				If DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem)) .And. !Empty(DTR->DTR_NUMVGE)
					DL0->( DbSetOrder( 2 ) )
					If DL0->(MsSeek( FWxFilial("DL0")+DTR->DTR_FILVGE+DTR->DTR_NUMVGE ))   //Posiciona na viagem Principal
						lLimpaDL0:= .T.
					EndIf
				EndIf
			EndIf

			If lLimpaDL0
				DL0->( DbSetOrder( 2 ) )
				DL0->(MsSeek( FWxFilial("DL0")+cFilOri + cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
				DL0->(DbSkip(-1))

				If lDTX_PRMACO
					AF16AtuMan(DL0->DL0_PERCUR,,,DTX->DTX_FILMAN,IIf(!Empty(DTX->DTX_PRMACO),DTX->DTX_PRMACO,DTX->DTX_MANIFE),DTX->DTX_SERMAN,.T.)
				Else
					AF16AtuMan(DL0->DL0_PERCUR,,,DTX->DTX_FILMAN,DTX->DTX_MANIFE,DTX->DTX_SERMAN,.T.)
				EndIf
			EndIf
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui DTX(Manifesto de Carga).                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lVgeComb
			For nCnt:= 1 To Len(aManComb)
				DTX->(dbGoTo(aManComb[nCnt][CTRECMAN]))
				RecLock("DTX", .F.)
				dbDelete()
				MsUnLock()
			Next nCnt	
		Else	
			RecLock("DTX", .F.)
			dbDelete()
			MsUnLock()
		EndIf

		// Exclui o percurso caso não existam manifestos na viagem.
		dbSelectArea("DTX")
		DTX->(dbSetOrder(5))
		If !DTX->(MsSeek(xFilial("DTX") + cFilOri + cViagem))
			dbSelectArea("DL0")
			DL0->(dbSetOrder(2))
			If DL0->(MsSeek( FWxFilial("DL0") + cFilOri + cViagem ))
				DL0->(MsSeek( FWxFilial("DL0") + cFilOri + cViagem + Replicate("Z", Len(DL0->DL0_PERCUR)), .T.))
				DL0->(DbSkip(-1))

				dbSelectArea("DL1")
				DL1->(dbSetOrder(5))
				DL1->(dbSeek(FWxFilial("DL1") + DL0->DL0_PERCUR))
				While DL1->(!Eof()) .AND. DL1->DL1_FILIAL + DL1->DL1_PERCUR == FWxFilial("DL1") + DL0->DL0_PERCUR
					RecLock("DL1", .F.)
					dbDelete()
					MsUnLock()
					DL1->(dbSkip())
				End

				dbSelectArea("DL2")
				DL2->(dbSetOrder(1))
				DL2->(dbSeek(FWxFilial("DL2") + DL0->DL0_PERCUR))
				While DL2->(!Eof()) .AND. DL2->DL2_FILIAL + DL2->DL2_PERCUR == FWxFilial("DL2") + DL0->DL0_PERCUR
					RecLock("DL2", .F.)
					dbDelete()
					MsUnLock()
					DL2->(dbSkip())
				End

				RecLock("DL0", .F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf

	End Transaction

	If !lRetTran
		Return .F.
	EndIf
Else

	dbSelectArea("DUD")
	dbSetOrder(4)
  	If AliasInDic("DL5")
  		Pergunte("TMA190D", .F.)
  		nValidAvb := mv_par01
  	EndIF

	If DTX->(FieldPos('DTX_TIPMAN')) > 0 .And. cTipMan == '2'
		Pergunte(Iif(cTipMan=="2","TMA190B","TMA190C"), .F.)
	Else
		Pergunte("TMA190C", .F.)
	EndIf

	If MsSeek( xFilial("DUD") + cFilOri + StrZero(1,Len(DUD->DUD_STATUS)) + cViagem )
		While DUD->( !Eof() ) .And. DUD->( DUD_FILIAL+DUD_FILORI+DUD_STATUS+DUD_VIAGEM ) == xFilial("DUD") + cFilOri + StrZero(1,Len(DUD->DUD_STATUS)) + cViagem
			If DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS))
				lRet:= .F.
				Exit
			EndIf
			DUD->( dbSkip() )
		EndDo
	EndIf

	If !lRet
		Help("", 1, "TMSA19002") //"Existem conhecimentos que ainda nao foram carregados."
		Return .F.
	EndIf

	Aadd(aViagens, {cFilOri,cViagem})

	DbSelectArea("DTR")
	DbSetOrder(1)
	MsSeek(xFilial("DTR") + cFilOri + cViagem)
	If !Empty(DTR->DTR_FILVGE+DTR->DTR_NUMVGE)
		//Não e a Viagem Principal, acha viagem principal
		aVgaPrinc := VgaPrincial(cFilOri, cViagem)
	Else
		DbSetOrder(2) //DTR_FILIAL+DTR_FILVGE+DTR_NUMVGE+DTR_ITEM
		If MsSeek(xFilial("DTR")  + cFilOri + cViagem)
			//Achou viagem coligada, procura a principal
			aVgaPrinc := VgaPrincial(cFilOri, cViagem)
		EndIf
	EndIf

	//Procura Viagens Coligadas
	If Len(aVgaPrinc) > 0
		aVgaColig := VgaColigada(aVgaPrinc[1][1], aVgaPrinc[1][2] )
	EndIf

	If lTm190Clg
		aVgaClg := ExecBlock('TM190CLG',.F.,.F.,{aVgaColig})
		If ValType(aVgaClg) == 'A'
			aVgaColig := aClone(aVgaClg)
		EndIf
	EndIf

	If Len(aVgaColig) > 0
		aViagens := aClone(aVgaColig)
		lVgaCol := .T.
	EndIf

	If AliasInDic("DL5")
		IF nValidAvb <> 3
			If Len(aViagens) > 0
				aCteSemAvb := {}
				cFiltroVge := ''
				For nC := 1 To Len(aViagens)
			  		IF nC == 1
			     		cFiltroVge := " AND ( (A.DUD_FILORI = '"+aViagens[nC][1]+ "' AND A.DUD_VIAGEM = '"+aViagens[nC][2]+ "') "
		  			Else
				  	 	cFiltroVge += " OR (A.DUD_FILORI = '"+aViagens[nC][1]+ "' AND A.DUD_VIAGEM = '"+aViagens[nC][2]+ "') "
		  			EndIF
				Next nC
				cFiltroVge += ')'

				cQuery := " SELECT A.DUD_FILDOC, A.DUD_DOC, A.DUD_SERIE "
				cQuery += " FROM " + RetSqlName("DUD")+ " A "
				cQuery += " 	LEFT JOIN " + RetSqlName("DL5")+ " B ON B.DL5_FILIAL = '" + xFilial("DL5")+ "' "
				cQuery += "		AND B.DL5_FILDOC = A.DUD_FILDOC AND B.DL5_DOC = A.DUD_DOC AND B.DL5_SERIE = A.DUD_SERIE AND B.D_E_L_E_T_ = ' ' "
				cQuery += " WHERE  A.DUD_FILIAL = '" + xFilial("DUD")+ "' "
				cQuery += cFiltroVge
				cQuery += " AND A.DUD_SERIE <> 'COL' "
				cQuery += " AND A.D_E_L_E_T_ = ' ' "
				cQuery += " And (B.DL5_STATUS <> '2' OR B.DL5_STATUS IS NULL)"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDL5, .F., .T.)

				Do While !(cAliasDL5)->(Eof())
					If len(aCteSemAvb) < 1 .And. nValidAvb == 1       //Lista os documentos, porem permite a geracao do manifesto
						Aadd(aCteSemAvb,{STR0060})
					ElseIf len(aCteSemAvb) < 1 .And. nValidAvb == 2   //Bloqueia a emissao do manifesto
						Aadd(aCteSemAvb,{STR0059})
					EndIf
					Aadd(aCteSemAvb, {AllTrim(RetTitle("DUD_DOC"))   +;
										(cAliasDL5)->DUD_FILDOC + ' / ' +;
										(cAliasDL5)->DUD_DOC    + ' '   +;
										(cAliasDL5)->DUD_SERIE})
					(cAliasDL5)->(DbSkip())
				EndDo
				(cAliasDL5)->( DbCloseArea() )

				If !Empty(aCteSemAvb)

					//Tratamento para que os botoes do help apresentado seja: Confirmar/Cancelar
					lValorAnt  := inclui
					lValorAnt1 := altera
					inclui := .F.
					altera := .F.

					TmsMsgErr(aCteSemAvb)

					inclui := lValorAnt
					altera := lValorAnt1

					If nValidAvb== 2
						Return .F.
					EndIf
				EndIF
			EndIF
		EndIF
	EndIf

	//--Verifica se usa rota de roteiro
	lRoteiro := F11RotRote(DTQ->DTQ_ROTA) //Rota Roteiro
	// Chama a rotina de percurso de viagem
	If AliasInDic("DL0") .AND. ExistFunc("F16LdVia") .And. !lRoteiro
		If !(lRet := F16LdVia(cFilOri,cViagem,aViagens))
			Return .F.
		EndIf
	EndIf

	Begin Transaction
		For nC := 1 To Len(aViagens)

			// Documentos do movimento de viagem
			DbSelectArea("DUD")
			DbSetOrder(2)
			MsSeek(xFilial("DUD") + aViagens[nC][1] + aViagens[nC][2])

			While DUD->( !Eof() ) .And. DUD->( DUD_FILIAL+DUD_FILORI+DUD_VIAGEM ) == xFilial("DUD")+aViagens[nC][1] + aViagens[nC][2]

				If !Empty(DUD->DUD_FILMAN) .Or. !Empty(DUD->DUD_MANIFE)
					DUD->( dbSkip() )
					Loop
				EndIf

				If DUD->DUD_SERTMS == StrZero( 2, Len( DT6->DT6_DOCTMS )) .And. lMdfeAut .And. DUD->DUD_FILDCA == cFilAnt
					DUD->( dbSkip() )
					Loop
				EndIf

				If DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) //-- Encerrado
					DUD->( dbSkip() )
					Loop
				EndIf

				If lDUD_FILATU .And. lManViag .And. DUD->DUD_FILATU <> cFilAnt
					DUD->( dbSkip() )
					Loop
				EndIf

				If AllTrim(DUD->DUD_SERIE) == 'COL'
					DUD->( dbSkip() )
					Loop
				EndIf

				DT6->( DbSetOrder( 1 ) )
				DT6->( MsSeek( xFilial("DT6") + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )

				cTipoLote := Posicione('DTP', 2, XFilial('DTP') + DT6->( DT6_FILORI + DT6_LOTNFC ), 'DTP_TIPLOT' )

				 //-- Lote Normal em Manifesto Eletrônico.
                If cTipoLote == "1" .And. cTipMan == "2"
					DUD->( dbSkip() )
					Loop

                //-- Lote Eletrônico ou CTe Único
                ElseIf ( cTipoLote == "3" .Or. cTipoLote == "4" )

                    //-- Manifesto Eletrônico, Documento for 1=Ordem de Coleta, 5=Nota Fiscal ou K=Carregamento em Partes e Situação do CTE for diferente de 2=Autorizado e 4=Em Contingencia.
                    If cTipMan == "2" 
						lBloqueia:= DT6->DT6_DOCTMS $ "1|5|K" 
						If !lBloqueia
							If !(DT6->DT6_SITCTE $ "2|4")  //2-Autorizado,4-Contingencia
								lBloqueia:= .T.
								If !Empty(DT6->DT6_CHVCTG) //Contingencia FSDA
									lBloqueia:= .F.
								EndIf	
							EndIf
						EndIf

						If lBloqueia
							DUD->( dbSkip() )
							Loop
						EndIf
                    EndIf
					

                    //-- Manifesto Normal e Documento = CTE
                    If cTipMan == "1" .And. ( DT6->DT6_DOCTMS $ "2|6|7|9|A|E" )
                        DUD->( dbSkip() )
                        Loop
                    EndIf

                EndIf

                lRet := .T.

				lAchouDoc := .T.

				If lTm190Fil
					lRet :=ExecBlock('TM190FIL',.F.,.F.)
					If ValType(lRet) <> 'L'
						lRet := .F.
					EndIf
				EndIf

				If lRet
					//MLOG-2579 - Verificar se existe mais de 1 veiculo tracionado na viagem.
					// Uma vez existindo, entende-se que se trata de operacao de comboio, e por conta disto, caso seja MDF-e,
					// devera ser gerado 1 Manifesto para cada veiculo da viagem.
					If cTipMan = "2" .And. lDTX_PRMACO
						nQtVeicDTR:= TMA190VCom(DUD->DUD_FILORI, DUD->DUD_VIAGEM)  
					Else
						nQtVeicDTR := 1
					EndIf

					For nCntVeiDTR := 1 To nQtVeicDTR
						cCntVeiDTR := Padl(cValtoChar(nCntVeiDTR),2,"0")
						cManife := TmsA190Num( @aManifestos,cCntVeiDTR,lVgaCol) // Obtem a sequencia de carregamento.

						//MLOG-2579 - Caso se trate de comboio, armazenar o primeiro Manifesto gerado para esta operacao.
						If nQtVeicDTR > 1 .And. nCntVeiDTR = 1
							cPrMaCo := cManife
						EndIf

						If Empty(cManife)
							DisarmTransaction()
							lRetTran := .F.
							Break
						EndIf

						aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][5]  += 1
						aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][6]  += DT6->DT6_QTDVOL
						aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][7]  += DT6->DT6_PESO
						aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][8]  += DT6->DT6_PESOM3
						aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][9]  += DT6->DT6_VALMER
						aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][10] += DT6->DT6_PESCOB

						If !Empty(DT6->DT6_CHVCTE) .Or. !Empty(DT6->DT6_CHVCTG)
							aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][16] += 1
						EndIf

						If Len(aTipoDoc) > 0 .And. Ascan(aTipoDoc,{|x| x == DT6->DT6_DOCTMS})  > 0
							aManifestos[Ascan(aManifestos, {|x| x[4] == cManife  })][17] += 1
						EndIf
						RecLock("DUD",.F.)
						DUD->DUD_FILMAN := cFilAnt
						DUD->DUD_MANIFE := cManife

						//MLOG-2579 - Se o Primeiro Manifesto de Comboio estiver preenchido, ele deve ser armazenado na DUD.
						// Entendemos que Manifestos de operacao de Comboio sao gerados todos ao mesmo tempo em uma mesma filial,
						// portanto, somente o numero precisa ser armazenado. Filial e Serie serao os mesmos.
						If lDTX_PRMACO
							If !Empty(cPrMaCo)
								DUD->DUD_MANIFE := cPrMaCo
							Else
								DUD->DUD_MANIFE := cManife
							EndIf
						EndIf

						DUD->DUD_SERMAN := cSerman   //-- Serie do Manifesto
						MsUnLock()
					Next nQtVeicDTR

					//--- Busca dentro da Tabela de Percurso para atualizar os dados referentes ao manifesto.
					If AliasInDic("DL0")
						dbSelectArea("DL0")
						DL0->(dbSetOrder(2))
						If DL0->(MsSeek( FWxFilial("DL0")+ cFilOri + cViagem ))
							DL0->(MsSeek( FWxFilial("DL0")+ cFilOri + cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
							DL0->(DbSkip(-1))

							DL2->(dbSetOrder(2))
							If DL2->(MsSeek(xFilial("DL2")+DUD->(DUD_FILORI+DUD_VIAGEM+DUD_FILDOC+DUD_DOC+DUD_SERIE)+DL0->DL0_PERCUR))
								DL1->(dbSetOrder(1))
								If DL1->(MsSeek(xFilial("DL1")+DL2->(DL2_PERCUR+DL2_IDLIN)))
									// Atualiza o manifesto nas tabelas de percurso.
									AF16AtuMan(DL0->DL0_PERCUR,DL1->DL1_UFORIG, DL1->DL1_UF,cFilAnt,DUD->DUD_MANIFE,cSerman)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				aAdd( aDocs, {DUD->DUD_VIAGEM, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, DUD->DUD_FILMAN, DUD->DUD_MANIFE, DUD->DUD_SERMAN, DUD->DUD_FILORI})
				DUD->( dbSkip() )
			EndDo
		Next nC

		If !lAchouDoc
			Help(' ', 1, 'TMSA19005')   //-- "Nenhum Documento foi encontrado para esta Viagem!"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o DTX(Manifesto de Carga).                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nA := 1 To Len(aManifestos)
				If !Empty(aManifestos[nA][4])
					//-- Busca a data e hora de emissao - Tratamento horário de verão
					If	!Empty(cHVerFil) .And. cFilAnt $ cHVerFil
						If	FindFunction("FwTimeUF")
							//-- Depois de oito anos sem adota-lo, o estado da Bahia, no Nordeste, o adotou em 2011.
							//-- Em 2012, no entanto, a Bahia voltou atras nessa decisao.
							cUF := IIF(cUF == "BA", "PE", cUF)
							aDataBase 	:= FwTimeUF(cUF,,lHVerao)
							dDatMan		:= Stod(aDataBase[1])
							cHoraBase 	:= StrTran(Left(aDataBase[2],5),':','')
						EndIf
					Else
						dDatMan	:= Date()
						cHoraBase 	:= Left( StrTran( Time(), ":", "" ), 4 )
					EndIf
					RecLock("DTX", .T.)
					DTX->DTX_FILIAL := xFilial("DTX")
					DTX->DTX_FILMAN := cFilAnt
					DTX->DTX_FILDCA := aManifestos[nA][1]
					DTX->DTX_MANIFE := aManifestos[nA][4]
					DTX->DTX_SERMAN := aManifestos[nA][18]
					If lVgaCol
						DTX->DTX_FILORI := aManifestos[nA][19] //aVgaPrinc[1][1]
						DTX->DTX_VIAGEM := aManifestos[nA][20] //aVgaPrinc[1][2]
					Else
						DTX->DTX_FILORI := cFilOri
						DTX->DTX_VIAGEM := cViagem
					EndIf
					DTX->DTX_DATMAN := dDatMan
					DTX->DTX_HORMAN := cHoraBase
					If lUFAtiv
						DTX->DTX_UFATIV := aManifestos[nA][3]
					EndIf
					DTX->DTX_QTDDOC := aManifestos[nA][5]
					DTX->DTX_QTDVOL := aManifestos[nA][6]
					DTX->DTX_PESO   := aManifestos[nA][7]
					DTX->DTX_PESOM3 := aManifestos[nA][8]
					DTX->DTX_VALMER := aManifestos[nA][9]
					DTX->DTX_PESCOB := aManifestos[nA][10]
					If lDTX_CDRDES
						DTX->DTX_CDRDES := aManifestos[nA][13]
					EndIf
					If lDTX_CODVEI
						DTX->DTX_CODVEI := aManifestos[nA][14]
					EndIf

					If DTX->(FieldPos('DTX_TIPMAN')) > 0
						DTX->DTX_TIPMAN := cTipMan    //Normal ou Eletronico
						If cTipMan = "2"
							//--- Se todos os documentos do Manifesto forem do Tipo Apoio, nao gera como manifesto eletronico
							If aManifestos[nA][17] > 0 .And. aManifestos[nA][17] == aManifestos[nA][5]
								DTX->DTX_TIPMAN := '1'  		//Normal
							Else
								DTX->DTX_STATUS = StrZero(1,Len(DTX->DTX_STATUS))  //Em Aberto
								DTX->DTX_RTIMDF := STR0047 		//'003 - O MDF-e ainda não foi transmitida - aguarde a transmissao'
								DTX->DTX_RTFMDF := STR0048 		//'033 - Encerramento do MDF-e nao transmitido'
							EndIf
						EndIf
						DTX->DTX_QTDCTE := aManifestos[nA][16]
					EndIf
					If lDTX_PRMACO
						If !Empty(cPrMaCo) .And. cPrMaCo <> aManifestos[nA][4]
							DTX->DTX_PRMACO := cPrMaCo
						Else
							DTX->DTX_PRMACO := ''
						EndIf
					EndIf
					MsUnLock()
				EndIf
				If lTm190Grv //PE para tratamento posterior a cada gravacao do manifesto
					ExecBlock("TM190GRV",.F.,.F.)
				EndIf
			Next nA
			If TableInDic("DLH") .And. Len(aDocs) > 0 .And. lRet
				TM190GrvDLH(aDocs)
			EndIf
		EndIf
	End Transaction

	If !lRetTran
		Return .F.
	EndIf

	If lTm190Fim //PE apos a gravação e fora da transação
		ExecBlock("TM190FIM",.F.,.F.)
	EndIf

	If lAchouDoc
		TmsA190Imp("DTX",0) //Chamada de impressao se a opcao for manifestar
	EndIf
EndIf

RestArea(aAreaDUD)

Return lAchouDoc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA190Num³ Autor ³ Richard Anderson      ³ Data ³23.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtem a sequencia de carregamento a partir da filial de     ³±±
±±³          ³Descarga + Estado do conhecimento que esta sendo manifestado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA190Num(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Manifestos e seus atributos.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Static Function TmsA190Num( aManifestos, cCntVeiDTR,lVgaCol )

Local cRet, nPos
Local cManife   := ""
Local cFilSep   := ""
Local cEstado   := ""
Local cSepOri   := ""
Local lSepEst   := Iif(cTipMan == "2",.T.,mv_par05 == 1) // Separa por Estado. Para MDFe, sempre separar por UF.
Local lSepCar   := (SB5->(FieldPos("B5_CARPER")) > 0 .And. mv_par07 == 1)
Local cSepCar   := "0"
Local lSepIsent :=(DUY->(FieldPos("DUY_REGISE")) > 0 .And. mv_par06 == 1) // Separa por Regioes Isentadas
Local lSepDes   :=(DTX->(FieldPos("DTX_CDRDES")) > 0 .And. mv_par09 == 1) // Separa por Regioes Destinos
Local cCdrDes   := ""
Local cCodVei   := ""
Local cCond     := ""
Local cMay      := ""
Local cChave    := ""
Local cEstOri   := ""
Local a190UFRD  := {}
Local lPercurso := SuperGetMv("MV_TMSPERC",.F.,.F.)

Default lVgaCol := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as Filiais / Regioes de Descarga da Rota                      ³
//³ Elementos contidos por dimensao:                                      ³
//³ 1. Regiao Origem da Rota                                              ³
//³ 2. Regioes de Descarga da Rota                                        ³
//³ 3. Filiais de Descarga da Rota                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Viagem de Entrega
If	DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS))
	If cTipMan == "2" //Eletronico
		cFilSep := DUD->DUD_FILDCA
	Else
		cFilSep := cFilAnt
	EndIf
//-- Viagem de Transporte
Else
	If cTipMan == "2" //Eletronico
		cFilSep := DUD->DUD_FILDCA
	ElseIf mv_par03 == 1   		// Separar Filial 1 = Descarga
		cFilSep := DUD->DUD_FILDCA
	ElseIf mv_par03 == 2 		// Separar Filial 2 = Destino
		cFilSep := DT6->DT6_FILDES
	ElseIf mv_par03 == 3 		// Separar Filial 3 = Nao Separa
		cFilSep := cFilAnt
	EndIf
EndIf

cSepOri := If(mv_par04 == 1 .And. DT6->DT6_FILDOC <> cFilAnt,"1","0")
cIsenta := If(lSepIsent,Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_REGISE'),"")
cCdrDes := If(lSepDes,DUD->DUD_CDRDES,"")

aAreaSM0 := SM0->(GetArea())
If cTipMan == "2" //Eletronico
	If DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS)) //Entrega
		//--- Busca dentro da Tabela de Percurso -- 23/05/2017
		If AliasInDic("DL0") .AND. lPercurso
			dbSelectArea("DL0")
			DL0->(dbSetOrder(2))
			If DL0->(MsSeek( FWxFilial("DL0")+ DUD->(DUD_FILORI+DUD_VIAGEM) ))
				DL0->(MsSeek( FWxFilial("DL0")+ DUD->(DUD_FILORI+DUD_VIAGEM) + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
				DL0->(DbSkip(-1))

				DL2->(dbSetOrder(2))
				If DL2->(MsSeek(xFilial("DL2")+DUD->(DUD_FILORI+DUD_VIAGEM+DUD_FILDOC+DUD_DOC+DUD_SERIE)+DL0->DL0_PERCUR))
					DL1->(dbSetOrder(1))
					If DL1->(MsSeek(xFilial("DL1")+DL2->(DL2_PERCUR+DL2_IDLIN)))
						cEstado := DL1->DL1_UF
						cEstOri := DL1->DL1_UFORIG
					EndIf
				EndIf
			Else
				cEstado := Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_EST')
			EndIf
		Else
			cEstado := Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_EST')
		EndIf
		//----

	ElseIf DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //Transferencia
		aAreaSM0 := SM0->(GetArea())
		cEstado := If(lSepEst,Posicione('SM0',1,cEmpAnt+DUD->DUD_FILDCA,'M0_ESTENT'),Space(Len(DUY->DUY_EST)))
		If !lVgaCol
			cEstOri := If(lSepEst,Posicione('SM0',1,cEmpAnt+DUD->DUD_FILORI,'M0_ESTENT'),Space(Len(DUY->DUY_EST)))
		EndIf
		RestArea(aAreaSM0)
	EndIf
Else
	cEstado := If(lSepEst,Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_EST'),Space(Len(DUY->DUY_EST)))
EndIf
RestArea(aAreaSM0)

//MLOG-3026 - Busca da UF do Parceiro. Esta UF sera considerada como UF Fim do Manifesto
a190UFRD := TMS190UFRD(cTipMan, DUD->DUD_SERTMS, DUD->DUD_NUMRED)
If Len(a190UFRD) > 0
	cEstado := a190UFRD[1]
EndIf

If lSepCar
	DTC->(dbSetOrder(3))
	DTC->(MsSeek(xFilial("DTC")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))

	SB5->(dbSetOrder(1))
	SB5->(MsSeek(xFilial("SB5")+DTC->DTC_CODPRO))

	If SB5->B5_CARPER == StrZero(1,Len(SB5->B5_CARPER)) //-- Sim
		cSepCar := "1"
	EndIf
EndIf

If DTX->(FieldPos('DTX_CODVEI')) > 0
	aAreaDTR := DTR->(GetArea())
	DTR->(dbSetOrder(1))
	DTR->(MsSeek(xFilial('DTQ') + DUD->(DUD_FILORI+DUD_VIAGEM+cCntVeiDTR)))
	cCodVei := DTR->DTR_CODVEI
	RestArea(aAreaDTR)

	If Empty(cCodVei)
		cCodVei := Posicione('DTA',1,xFilial('DTA')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM),'DTA_CODVEI')
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca no array a posicao da Filial de Descarga + Estado do conhecimen- ³
//³ to que esta sendo Manifestado, para criar ou obter o numero do mesmo.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//-- Ponto de entrada antes da busca do que esta sendo manifestado.
If ExistBlock("TMS190MAN")
	cCond := ExecBlock("TMS190MAN",.F.,.F.,{aManifestos})
	If ValType(cCond) <> 'C'
		cCond := ""
	EndIf
EndIf

If	( cTipMan == "2" .And. ( nPos := Ascan(aManifestos, { |x| x[2] + x[3] + x[11] + x[12] + x[13] + x[14] + x[15] + x[21] == cSepOri + cEstado + cSepCar + cIsenta + cCdrDes + cCodVei + cCond + cEstOri .And. x[5] < mv_par10 } ) ) == 0 ) .Or.;
	( cTipMan == "1" .And. ( nPos := Ascan(aManifestos, { |x| x[1] + x[2] + x[3]  + x[11] + x[12] + x[13] + x[14] + x[15]== cFilSep + cSepOri + cEstado + cSepCar + cIsenta + cCdrDes + cCodVei + cCond .And. x[5] < mv_par10 } ) ) == 0 )
	cManife := TmsA190Ser()

		If AliasInDic("DYN")
		//--- Verifica se o manifesto foi cancelado e nao permite a mesma numeracao
		cChave := xFilial('DYN') + cFilAnt + cManife + cSerman
		cMay:= AllTrim(xFilial('DYN'))+cFilAnt+cManife+cSerman
		FreeUsedCode()

		DYN->( DbSetOrder( 1 ) )
		While DYN->(MsSeek( cChave )) .Or. !LockByName(cMay)
			ConfirmSx8()
			cManife := TmsA190Ser()
			FreeUsedCode()
			cMay    := cChave
		EndDo
	EndIf
	If __lSX8
		ConfirmSX8()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo os Manifestos e seus atributos.                 ³
	//³ Elementos contidos por dimensao:                                      ³
	//³  1. Filial de Separacao                                               ³
	//³  2. Separacao por Origem                                              ³
	//³  3. Estado                                                            ³
	//³  4. Numero do Manifesto.                                              ³
	//³  5. Quantidade de Documentos.                                         ³
	//³  6. Quantidade de Volumes.                                            ³
	//³  7. Peso Real                                                         ³
	//³  8. Peso Cubado                                                       ³
	//³  9. Valor mercadoria                                                  ³
	//³ 10. Peso Cobrado                                                      ³
	//³ 11. Separacao por carga perigosa                                      ³
	//³ 12. Regiao Isenta                                                     ³
	//³ 13. Regiao de Destino                                                 ³
	//³ 14. Codigo do Veiculo                                                 ³
	//³ 15. Campo especifico retornado pelo ponto de entrada                  ³
	//³ 16. Qtd Conhecimento de Transporte - Eletronico                       ³
	//³ 17. Qtd Conhecimento do Tipo Apoio                                    ³
	//³ 18. Serie do Manifesto                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aManifestos, { cFilSep, cSepOri, cEstado, cManife, 0, 0, 0, 0, 0, 0, cSepCar, cIsenta, cCdrDes, cCodVei, cCond, 0, 0 ,cSerman, DUD->DUD_FILORI, DUD->DUD_VIAGEM,cEstOri} )
	nPos := Len(aManifestos)
Else
	If aManifestos[nPos][5] == mv_par10
		cManife := TmsA190Ser()

	    If AliasInDic("DYN")
		    //--- Verifica se o manifesto foi cancelado e nao permite a mesma numeracao
			cChave := xFilial('DYN') + cFilAnt + cManife + cSerman
			cMay:= AllTrim(xFilial('DYN'))+cFilAnt+cManife+cSerman
			FreeUsedCode()

			DYN->( DbSetOrder( 1 ) )
			While DYN->(MsSeek( cChave )) .Or. !LockByName(cMay)
				ConfirmSx8()
				cManife := TmsA190Ser()
				FreeUsedCode()
				cMay    := cChave
			EndDo
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
		Aadd(aManifestos, { cFilSep, cSepOri, cEstado, cManife, 0, 0, 0, 0, 0, 0, cSepCar, cIsenta, cCdrDes, cCodVei, cCond, 0, 0 , cSerman, DUD->DUD_FILORI, DUD->DUD_VIAGEM,cEstOri} )
		nPos := Len(aManifestos)
	EndIf
EndIf

cRet := aManifestos[nPos][4]

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA190Leg³ Autor ³ Patricia A. Salomao   ³ Data ³04.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status do Manifesto.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA190Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function TmsA190Leg()

BrwLegenda(cCadastro, STR0019,; //"Status"
			{{"BR_VERDE",		STR0013},;	//"Em Aberto"
			{ "BR_VERMELHO",	STR0014}})	//"Contrato Gerado"

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA190Doc³ Autor ³ Patricia A. Salomao   ³ Data ³20.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega o Vetor (aDoctos) com os documentos do Manifesto e  ³±±
±±³          ³Vetor (aTotal) contendo o Resumo do Manifesto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsA190Doc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial de Origem da Viagem                          ³±±
±±³          ³ExpC2 - No. da Viagem                                       ³±±
±±³          ³ExpC3 - Filial do Manifesto                                 ³±±
±±³          ³ExpC4 - No. do Manifesto                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA190                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Static Function TMSA190Doc(cFilOri, cViagem, cFilMan, cManife, cSerman, cPrMaCo )

Local cSeekDUD   := ''
Local cInscRem   := ''
Local cNomRem    := ''
Local cInscDes   := ''
Local cNomDes    := ''
Local cAliasTop  := ''
Local cQuery     := ''
Local nValMercC  := 0
Local nValFreteC := 0
Local nValICMC   := 0
Local nVolsC     := 0
Local nPesoC     := 0
Local nPesoCobC  := 0
Local nCtrcsC    := 0
Local nVarNTribC := 0
Local nVarTribC  := 0
Local nValMercF  := 0
Local nValFreteF := 0
Local nValICMF   := 0
Local nVolsF     := 0
Local nPesoF     := 0
Local nPesoCobF  := 0
Local nCtrcsF    := 0
Local nVarNTribF := 0
Local nVarTribF  := 0
Local lLGPD		 := ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)
Local aCpoAccess := {"A1_INSCR","A1_NOME","A1_MUN","A1_EST"}
Local cMunici  	 := ""
Local cEstado    := ""
Local nCountCpo  := 0
Local aCpoAccNew := {}
Local aUsrAcsPFl := {}
Default cFilOri  := ''
Default cViagem  := ''
Default cFilMan  := ''
Default cManife  := ''
Default cSerman  := ''
Default cPrMaCo  := ''

cSeekDUD   := ''
cAliasTop  := ''
cQuery     := ''

cAliasTop := GetNextAlias()
cQuery := " SELECT DUD_FILDOC,DUD_DOC, DUD_SERIE, DUD_FILORI, DUD_VIAGEM, DUD_FILMAN, DUD_MANIFE, DT6_DOC, DT6_SERIE, DT6_QTDVOL, DT6_PESO,"
cQuery += "  DT6_PESCOB, DT6_VALMER, DT6_TIPFRE, DT6_FILDES, DT6_CLIREM, DT6_LOJREM, DT6_CLIDES, DT6_LOJDES, DT6_VALFAT, F2_VALICM, F2_BASEICM"
cQuery += "  ,DUD_SERMAN "
cQuery += " FROM "
cQuery += RetSqlName('DUD')+" DUD, "
cQuery += RetSqlName('DT6')+" DT6  "
cQuery += "  LEFT JOIN " + RetSqlName("SF2") + " SF2 "
If !Empty(xFilial('SF2'))	//-- Arquivo SF2 criado em modo exclusivo
	cQuery += "     ON  SF2.F2_FILIAL  = DT6.DT6_FILDOC"
Else
	cQuery += "     ON  SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"
EndIf
cQuery += "		AND SF2.F2_DOC      = DT6.DT6_DOC"
cQuery += "		AND SF2.F2_SERIE    = DT6.DT6_SERIE"
cQuery += "		AND SF2.D_E_L_E_T_  = ' '"
cQuery += " WHERE DUD.DUD_FILIAL  = '"+xFilial("DUD")+"'"
cQuery += "		AND DUD.DUD_FILMAN  = '"+cFilMan+"'"
cQuery += "		AND DUD.DUD_MANIFE  = '"+Iif(!Empty(cPrMaCo),cPrMaCo,cManife)+"'"
cQuery += "		AND DUD.DUD_SERMAN  = '"+cSerman+"'"
cQuery += "		AND DUD.D_E_L_E_T_  = ' '"
cQuery += "		AND DT6.DT6_FILIAL  = '"+xFilial("DT6")+"'"
cQuery += "		AND DT6.DT6_FILDOC  = DUD.DUD_FILDOC "
cQuery += "		AND DT6.DT6_DOC     = DUD.DUD_DOC"
cQuery += "		AND DT6.DT6_SERIE   = DUD.DUD_SERIE"
cQuery += "		AND DT6.D_E_L_E_T_  = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

While (cAliasTop)->(!Eof())

	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial('SA1')+(cAliasTop)->DT6_CLIREM+(cAliasTop)->DT6_LOJREM))
	cInscRem := Iif(Empty(SA1->A1_INSCR), STR0018 , SA1->A1_INSCR) //'Em Branco'
	cNomRem  := Iif(Empty(SA1->A1_NOME) , STR0018 , Left(SA1->A1_NOME, 25)) //'Em Branco'

	SA1->(MsSeek(xFilial('SA1')+(cAliasTop)->DT6_CLIDES+(cAliasTop)->DT6_LOJDES))
	cInscDes := Iif(Empty(SA1->A1_INSCR), STR0018 , SA1->A1_INSCR) //'Em Branco'
	cNomDes  := Iif(Empty(SA1->A1_NOME) , STR0018 , Left(SA1->A1_NOME, 25)) //'Em Branco'

	cMunici  := SA1->A1_MUN
	cEstado  := SA1->A1_EST

	If llGPD .And. ExistFunc('TMLGPDCpPr')
		aCpoAccNew := TMLGPDCpPr(aCpoAccess,'SA1') //--Campos protegidos e que são apresentados na rotina.
		aUsrAcsPFl := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCpoAccNew ) //--Campos protegidos usados na rotina e que o usuário possue acesso

		//--Monta Array com as colunas que nao serao exibidas devido ao acesso do usuario
		If Len(aCpoAccess) > 0
			For nCountCpo := 1 To Len(aCpoAccess)
				If Ascan( aUsrAcsPFl, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
					If aCpoAccess[nCountCpo] == "A1_NOME"
						cNomRem  := Replicate('*',TamSX3('A1_NOME')[1])
						cNomDes  := Replicate('*',TamSX3('A1_NOME')[1])
					Endif
					If aCpoAccess[nCountCpo] == "A1_INSCR"
						cInscRem := Replicate('*',TamSX3('A1_INSCR')[1])
						cInscDes := Replicate('*',TamSX3('A1_INSCR')[1])
					EndIf
					If aCpoAccess[nCountCpo] == "A1_MUN"
						cMunici  := Replicate('*',TamSX3('A1_MUN')[1]) 
					EndIf
					If aCpoAccess[nCountCpo] == "A1_EST"
						cEstado  := Replicate('*',TamSX3('A1_EST')[1]) 
					EndIf
				EndIf
			Next nCountCpo
		EndIf	
	EndIf
		
		AAdd(aDoctos, { (cAliasTop)->DT6_DOC ,;
						(cAliasTop)->DT6_SERIE,;
						Substr(cNomRem,1,20),;
						Transform(cInscRem,PesqPict("SA1", "A1_INSCR")),;
						Substr(cNomDes,1,20),;
						Transform(cInscDes,PesqPict("SA1", "A1_INSCR")),;
						cMunici,;
						cEstado,;
						Transform((cAliasTop)->DT6_QTDVOL,PesqPict("DT6", "DT6_QTDVOL")),;
						Transform((cAliasTop)->DT6_PESO,  PesqPict("DT6", "DT6_PESO"  )),;
						Transform((cAliasTop)->DT6_PESCOB,PesqPict("DT6", "DT6_PESCOB")),;
						Transform((cAliasTop)->DT6_VALMER,PesqPict("DT6", "DT6_VALMER")),;
						IIf((cAliasTop)->DT6_TIPFRE == "1", "CIF", "FOB"),;
						cFilAnt,;
						(cAliasTop)->DT6_FILDES } )

		If (cAliasTop)->DT6_TIPFRE == "1" // Frete CIF
			nValMercC  += (cAliasTop)->DT6_VALMER	// Valor Mercadoria CIF
			nValFreteC += (cAliasTop)->DT6_VALFAT	// Valor do Frete CIF
			nValICMC   += (cAliasTop)->F2_VALICM	// Valor do ICMS CIF
			nVolsC     += (cAliasTop)->DT6_QTDVOL	// Volumes CIF
			nPesoC     += (cAliasTop)->DT6_PESO		// Peso Liquido CIF
			nPesoCobC  += (cAliasTop)->DT6_PESCOB	// Peso Cobrado Liquido CIF
			nVarNTribC += (cAliasTop)->DT6_VALFAT-(cAliasTop)->F2_BASEICM	// Valor nao Tributavel CIF
			nVarTribC  += (cAliasTop)->F2_BASEICM	// Valor Tributavel CIF
			nCtrcsC    += 1							// Numero de Conhecimentos CIF
		Else // Frete FOB
			nValMercF  += (cAliasTop)->DT6_VALMER	// Valor Mercadoria FOB
			nValFreteF += (cAliasTop)->DT6_VALFAT	// Valor do Frete FOB
			nValICMF   += (cAliasTop)->F2_VALICM	// Valor do ICMS FOB
			nVolsF     += (cAliasTop)->DT6_QTDVOL	// Volumes FOB
			nPesoF     += (cAliasTop)->DT6_PESO		// Peso Liquido FOB
			nPesoCobF  += (cAliasTop)->DT6_PESCOB	// Peso Cobrado FOB
			nVarNTribF += (cAliasTop)->DT6_VALFAT-(cAliasTop)->F2_BASEICM	// Valor nao Tributavel CIF
			nVarTribF  += (cAliasTop)->F2_BASEICM	// Valor Tributavel CIF
			nCtrcsF    += 1							// Numero de Conhecimentos FOB
		EndIf
	(cAliasTop)->(dbSkip())
EndDo
(cAliasTop)->(dbCloseArea())

//-- Resumo Geral do Manifesto :

//-- Documentos CIF
AAdd(aTotal, {	STR0017 ,;  //"CIF"
				Transform(nValMercC ,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nValFreteC,PesqPict("DT6", "DT6_VALFAT")),;
				Transform(nVarNTribC,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nVarTribC ,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nValICMC  ,PesqPict("SF2", "F2_VALICM" )),;
				Transform(nVolsC    ,PesqPict("DT6", "DT6_QTDVOL")),;
				Transform(nPesoC    ,PesqPict("DT6", "DT6_PESO"  )),;
				Transform(nPesoCobC ,PesqPict("DT6", "DT6_PESO"  )),;
				nCtrcsC } )

//-- Documentos FOB
AAdd(aTotal, {	STR0016 ,; //"FOB"
				Transform(nValMercF ,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nValFreteF,PesqPict("DT6", "DT6_VALFAT")),;
				Transform(nVarNTribF,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nVarTribF ,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nValICMF  ,PesqPict("SF2", "F2_VALICM" )),;
				Transform(nVolsF    ,PesqPict("DT6", "DT6_QTDVOL")),;
				Transform(nPesoF    ,PesqPict("DT6", "DT6_PESO"  )),;
				Transform(nPesoCobF ,PesqPict("DT6", "DT6_PESO"  )),;
				nCtrcsF } )

//-- Documentos CIF+FOB
AAdd(aTotal, {	STR0007 ,; //"TOTAL"
				Transform(nValMercC+nValMercF  ,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nValFreteC+nValFreteF,PesqPict("DT6", "DT6_VALFAT")),;
				Transform(nVarNTribC+nVarNTribF,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nVarTribC+nVarTribF  ,PesqPict("DT6", "DT6_VALMER")),;
				Transform(nValICMC+nValICMF    ,PesqPict("SF2", "F2_VALICM" )),;
				Transform(nVolsC+nVolsF        ,PesqPict("DT6", "DT6_QTDVOL")),;
				Transform(nPesoC+nPesoF        ,PesqPict("DT6", "DT6_PESO"  )),;
				Transform(nPesoCobC+nPesoCobF  ,PesqPict("DT6", "DT6_PESO"  )),;
				nCtrcsC+nCtrcsF } )

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA190Imp³ Autor ³Rodolfo K. Rosseto     ³ Data ³21.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama o programa de impressao do cliente de acordo com      ³±±
±±³          ³manif. posicionado e grava os ultimos valores no SX1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 = Imprime o manifesto apos a gravacao?                ³±±
±±³			 |ExpL2 = Origem de Chamada da função 1=aRotina 2=Manifesto	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA190Imp(cAlias,nRecno,nOpcx,cTipManif)

Local lImp        := .F.
Local lRTMSR04    := ExistBlock("RTMSR04")
Local lRTMSR32    := ExistBlock("RTMSR32")
Local lRTMSR34    := ExistBlock("RTMSR34")
Local lTMSR590    := FindFunction("TMSR590") .And. FindFunction("TRepInUse") //.And. TRepInUse()
Local aArea       := GetArea()
Local cPerg		  := Iif(__lPyme,'RTMSR32P', 'RTMSR32')
Default cTipManif := ''

If DTX->(FieldPos('DTX_TIPMAN')) > 0 .And. Iif(nRecno > 0, DTX->DTX_TIPMAN == '2', cTipMan == '2')
	Pergunte("TMA190B", .F.)
	If !lRTMSR04
		mv_par08 := 2
	EndIf
Else
	Pergunte("TMA190C", .F.)
EndIf
cFilOri := Iif(nRecno > 0,DTX->DTX_FILORI,mv_par01)
cViagem := Iif(nRecno > 0,DTX->DTX_VIAGEM,mv_par02)
lImpMan := Iif(nRecno > 0,.T.,(SB5->(FieldPos("B5_CARPER")) > 0 .And. mv_par08 == 1))

If nRecno > 0 //-- Chamada da mBrowse
	cFilOri		:= DTX->DTX_FILORI
	cViagem		:= DTX->DTX_VIAGEM
	cFilMan_De	:= DTX->DTX_FILMAN
	cFilMan_Ate	:= DTX->DTX_FILMAN
	cManife_De	:= DTX->DTX_MANIFE
	cManife_Ate	:= DTX->DTX_MANIFE
	cSerie_De	:= DTX->DTX_SERMAN
	cSerie_Ate	:= DTX->DTX_SERMAN
Else
	cFilOri		:= DTX->DTX_FILORI
	cViagem		:= DTX->DTX_VIAGEM
	cFilMan_De	:= DTX->DTX_FILMAN
	cFilMan_Ate	:= DTX->DTX_FILMAN
	cManife_De	:= DTX->DTX_MANIFE
	cManife_Ate	:= DTX->DTX_MANIFE
	cSerie_De	:= DTX->DTX_SERMAN
	cSerie_Ate	:= DTX->DTX_SERMAN
EndIf

If lImpMan
	lMostraTela := .T.
	If Empty(cTipManif) .Or. cTipManif = 'NORMAL'
		If lRTMSR04
			ExecBlock("RTMSR04",.F.,.F.,{cFilOri,cViagem,cFilMan_De,cFilMan_Ate,cManife_De,cManife_Ate})
			lImp := .T.
		ElseIf lTMSR590 .And. !lImp
			TMSR590() //--Manifesto do Padrao
		EndIf
	EndIf
	If	cTipManif = 'DAMDFE'
		If lRTMSR32 .Or. lRTMSR34
			SetMVValue(cPerg,"MV_PAR01",cFilOri) 
            SetMVValue(cPerg,"MV_PAR02",cViagem) 
            SetMVValue(cPerg,"MV_PAR03",cViagem) 
            SetMVValue(cPerg,"MV_PAR04",cFilMan_De)
            SetMVValue(cPerg,"MV_PAR05",cFilMan_Ate)
            SetMVValue(cPerg,"MV_PAR06",cManife_De)
            SetMVValue(cPerg,"MV_PAR07",cManife_Ate)
            SetMVValue(cPerg,"MV_PAR08",cSerie_De)
            SetMVValue(cPerg,"MV_PAR09",cSerie_Ate)

			If lRTMSR34
				ExecBlock("RTMSR34",.F.,.F.,{cFilOri,cViagem,cViagem,cFilMan_De,cFilMan_Ate,cManife_De,cManife_Ate,cSerie_De,cSerie_Ate})
			Else
				ExecBlock("RTMSR32",.F.,.F.,{cFilOri,cViagem,cViagem,cFilMan_De,cFilMan_Ate,cManife_De,cManife_Ate,cSerie_De,cSerie_Ate})
			EndIf
		EndIf
	EndIf

EndIf
RestArea(aArea)

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA190Obs³ Autor:³ TOTVS                 ³ Data:³19/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Observacao do Cancelamento do Manifesto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA190Obs                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA190Obs(cObsCan)

Local oDlgObs
Local nOpcao   := 0
Local cObsDlg  := ""
Local lRet     := .T.

DEFINE MSDIALOG oDlgObs TITLE STR0050 FROM 15,20 TO 25,62

@ 0.5,0.7  GET oGet VAR cObsDlg OF oDlgObs MEMO SIZE 150,40

DEFINE SBUTTON FROM 52,100 TYPE 1 OF oDlgObs ENABLE ACTION (nOpcao := 1,oDlgObs:End())
DEFINE SBUTTON FROM 52,128 TYPE 2 OF oDlgObs ENABLE ACTION (nOpcao := 0,oDlgObs:End())

ACTIVATE MSDIALOG oDlgObs CENTERED

If nOpcao == 0
	lRet:= .F.
Else
	cObsDlg := NoAcentoCte( cObsDlg )
	If Empty(cObsDlg) .Or. Len(AllTrim(cObsDlg)) < 15
		Help("", 1, "TMSA19016")
		lRet:= .F.
	Else
		cObsCan:= cObsDlg
	EndIf
EndIf

Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA190Ser³ Autor:³ Alex Amaral           ³ Data:³12/06/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que retorna o numero do manifesto                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA190Ser                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA190Ser()

Local cRet  	  := ""
Local cNumNF  	  := ""
Local cTabSX5     := ""
Local aSeries     := {}
Local cSerie 	  := SuperGetMv( "MV_SERMAN", .F., ""   ) //-- Série do Manifesto
Local lTM190Num   := ExistBlock("TM190NUM")


If lTM190Num
	cRet := ExecBlock('TM190NUM',.F.,.F.)
EndIf

If Empty(cRet)
	If !Empty(cSerie)	
		aSeries  := FWGetSX5("PT", cSerie)
		If Empty(aSeries)
			aSeries  := FWGetSX5("ZV", cSerie)
		EndIf

		If !Empty(aSeries)
			cNumNF  := aSeries[1][4]
			cTabSX5 := aSeries[1][2]
		EndIf

		If !Empty(cNumNF)
			cNumNF := Soma1(AllTrim(cNumNF))
			FwPutSX5(, cTabSX5, cSerie, cNumNF, cNumNF, cNumNF )
			cRet := StrZero( Val( cNumNF ),TamSx3("DTX_MANIFE")[1],0 )
		Else
			Help(' ', 1, 'TMSA19019', ,"Série: "+Alltrim(cSerie) ) //"Série do manifesto não encontrada na tabela genérica ZV"
		EndIf
	Else
		cRet  := GETSX8NUM("DTX","DTX_MANIFE")
	EndIf
EndIf

Return(cRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local lRTMSR04 := ExistBlock("RTMSR04")
Local lTMSR590 := FindFunction("TMSR590") .And. FindFunction("TRepInUse") //.And. TRepInUse()
Local lRTMSR32 := ExistBlock("RTMSR32")
Local lRTMSR34 := ExistBlock("RTMSR34")
Local aOpcMenu := {}
Local lVgeMod3 := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

Private aRotina := {}

If lRTMSR04 .Or. lTMSR590
	AAdd(aOpcMenu, { STR0035, 'TmsA190Imp'  ,0 ,2})
EndIf

If lRTMSR34
	AAdd(aOpcMenu, { STR0046, 'U_RTMSR34'  ,0 ,2})	    //-- DAMDFE
ElseIf lRTMSR32
	AAdd(aOpcMenu, { STR0046, 'U_RTMSR32'  ,0 ,2})	    //-- DAMDFE
EndIf

aRotina	:= {	{ STR0002 ,"AxPesqui"  ,0,1,0,.F.},;	// "Pesquisar"
				{ STR0003 ,"TmsA190Mnt",0,2,0,NIL},;  	// "Visualizar"
				{ STR0004 ,"TmsA190Mnt",0,3,0,NIL},;  	// "Manifestar"
				{ STR0005 ,"TmsA190Mnt",0,5,0,NIL},;  	// "Excluir"
				{ STR0012 ,"TmsA190Leg",0,6,0,.F.},;  	// "Legenda"
				{ STR0035 ,aOpcMenu  ,0,7,0,NIL} }   	// "Imprimir"

If IsInCallStack("TMSAF76")
	AAdd(aRotina, { STR0045 ,"Tmsae73" ,0,8,0,.F.} )	// "MDF-e"
Else
	AAdd(aRotina, { STR0045 ,"Tmsae73()" ,0,Iif(lVgeMod3,3,8),0,.F.} )	// "MDF-e"
EndIf

If TableInDic("DLH", .F.) .And. ExistFunc("TMSA190A")
	AAdd(aRotina, { STR0064 ,"TMSA190A(2)" ,0,Iif(lVgeMod3,3,9),0,.F.} )	// "Historico MDF-e"
EndIf
If ExistFunc("TMSAE73B") .AND. TMSA73BX1()
    aAdd(aRotina, {STR0075, "TMSAE73B()", 0, Iif(lVgeMod3,3,2)})
EndIf
If IsInCallStack("TMSAF60") .And. TableInDic("DM3", .F.)
	aAdd(aRotina, {STR0076, "TM190Condt()", 0, 2})  //Inclusão de Condutor
EndIf

Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VgaPrincial³Autor:³ Fabio Marchiori       ³ Data:³01/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procura a Viagem Principal	                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VgaPrincial                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function VgaPrincial(cFilOri, cViagem)

Local aViagens    := {}
Local aAreaDTR    := DTR->(GetArea())
Local cChave      := ""
Local nMaxLoop    := 0

	DbSelectArea("DTR")
	DbSetOrder(1)
	If MsSeek(xFilial("DTR") + cFilOri + cViagem)
		If Empty(DTR->DTR_FILVGE+DTR->DTR_NUMVGE)
			Aadd(aViagens, { DTR->DTR_FILORI, DTR->DTR_VIAGEM})
			//Achou Viagem Principal
		Else
			While ++nMaxLoop < 5000
				If !Empty(DTR->DTR_FILVGE+DTR->DTR_NUMVGE)
					cChave := DTR->DTR_FILVGE+DTR->DTR_NUMVGE
					DbSetOrder(1)
					If MsSeek(xFilial("DTR",DTR->DTR_FILVGE) + cChave)
						If Empty(DTR->DTR_FILVGE+DTR->DTR_NUMVGE)
							Aadd(aViagens, { DTR->DTR_FILORI, DTR->DTR_VIAGEM})
							Exit
							//Achou a Viagem Principal
						EndIf
					Else
						Exit
					EndIf
				Else 
					Exit
				EndIf
			EndDo
		EndIf
	EndIf

RestArea(aAreaDTR)
Return (aViagens)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VgaColigada³Autor:³ Fabio Marchiori       ³ Data:³01/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procura Viagens Coligadas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VgaColigada                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function VgaColigada(cFilOri, cViagem, lTransf)

Local aViagens    := {{cFilOri, cViagem, .F., "", ""}}
Local aAreaDTR    := DTR->(GetArea())
Local aAreaDTQ    := DTQ->(GetArea())
Local nX          := 0
Local nLinha      := 0

Default lTransf := .T.

	DTQ->(DbSetOrder(2))
	DTQ->(DbSeek(xFilial("DTQ") + aViagens[1,1] + aViagens[1,2]))
	aViagens[Len(aViagens),4] := DTQ->DTQ_SERTMS
	aViagens[Len(aViagens),5] := DTQ->DTQ_STATUS
	DbSelectArea("DTR")
	DbSetOrder(2)
		//Viagem Principal
		For nX := 1 To Len(aViagens)
			If MsSeek(xFilial("DTR") + aViagens[nX][1] + aViagens[nX][2] )
				If aViagens[nX][3] == .F.
					While !DTR->( Eof() ) .And. DTR->DTR_FILVGE + DTR->DTR_NUMVGE = aViagens[nX][1] + aViagens[nX][2]
						aViagens[nX][3] := .T.
						DTQ->(DbSeek(xFilial("DTQ") + DTR->(DTR_FILORI + DTR_VIAGEM)))
						Aadd(aViagens, { DTR->DTR_FILORI, DTR->DTR_VIAGEM, .F., DTQ->DTQ_SERTMS, DTQ->DTQ_STATUS})
					DTR->( dbSkip() )
					EndDo
				EndIf
			EndIf
		Next nX
		// Viagem Principal + Coligadas
		For nX := 1 To Len(aViagens)
			If MsSeek(xFilial("DTR") + aViagens[nX][1] + aViagens[nX][2] )
				If aViagens[nX][3] == .F.
					While !DTR->( Eof() ) .And. DTR->DTR_FILVGE + DTR->DTR_NUMVGE = aViagens[nX][1] + aViagens[nX][2]
						aViagens[nX][3] := .T.
						DTQ->(DbSeek(xFilial("DTQ") + DTR->(DTR_FILORI + DTR_VIAGEM)))
						Aadd(aViagens, { DTR->DTR_FILORI, DTR->DTR_VIAGEM, .F., DTQ->DTQ_SERTMS, DTQ->DTQ_STATUS})
					DTR->( dbSkip() )
					EndDo
				EndIf
			EndIf
		Next nX

		If !lTransf
			While (nLinha := Ascan(aViagens,{|x| x[4] == "2"})) > 0
				aDel(aViagens,nLinha)
				aSize(aViagens,Len(aViagens) - 1)
			EndDo
		EndIf

RestArea(aAreaDTQ)
RestArea(aAreaDTR)
Return (aViagens)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA190Static()
Retorna variáveis estáticas
@since 24/01/2016
@version 12
/*/
//-------------------------------------------------------------------
Function TMSA190Static()
Return {cFilOri,cViagem,cFilMan_De,cFilMan_Ate,cManife_De,cManife_Ate}

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA190Pergunte()
Retorna valor para as perguntas dos relatórios RTMSR04 e TMSR590
@since 24/01/2016
@version 12
/*/
//-------------------------------------------------------------------
Function TMSA190Pergunte(nPerg)
Local aStatics	:= TMSA190Static()
Local lRTMSR04	:= ExistBlock("RTMSR04")
Local lTMSR590	:= TRepInUse()
Local cValor		:= ""
Local cPerg01 	:= ""
Local cPerg02 	:= ""
Local cPerg03 	:= ""
Local cPerg04 	:= ""
Local cPerg05 	:= ""
Local cPerg06 	:= ""
Local oGrp1
Local oDlg
Local oSize

Default nPerg := 0

//Verifica se está utilizando os relatórios
If (lRTMSR04 .Or. lTMSR590)
	//Verifica se é a primeira vez que está passando pela função e mostra a interface
	If lMostraTela

		//Carrega as varíaveis com os valores padrão
		cPerg01 	:= aStatics[1]
		cPerg02 	:= aStatics[2]
		cPerg03 	:= aStatics[3]
		cPerg04 	:= aStatics[4]
		cPerg05 	:= aStatics[5]
		cPerg06 	:= aStatics[6]

		//Monta tela
		DEFINE MSDIALOG oDlg FROM 100,100 TO 450,540 TITLE "Parâmetros" Of oMainWnd PIXEL

		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:aWorkArea := {000, 035, 220, 320 }

		oSize:AddObject( "CABECALHO",  100, 10, .T., .T. ) // Totalmente dimensionavel

		oSize:lProp 	:= .T. // Proporcional
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

		oSize:Process() // Dispara os calculos

		oGrp1 := TGroup():New(	oSize:GetDimension("CABECALHO","LININI"),;
								oSize:GetDimension("CABECALHO","COLINI"),;
								oSize:GetDimension("CABECALHO","LINEND"),;
								oSize:GetDimension("CABECALHO","COLEND"),"Manifesto de Carga",oDlg,,,.T.,)

		@ 52,15	SAY "Fil. Origem" of oGrp1 PIXEL SIZE 30,09
		@ 50,46	MSGET aStatics[1] VAR cPerg01 PICTURE PesqPict("DTX","DTX_FILIAL") of oGrp1 PIXEL SIZE 20,10

		@ 72,15	SAY "Viagem" of oGrp1 PIXEL SIZE 30,09
		@ 70,46	MSGET aStatics[2] VAR cPerg02 PICTURE PesqPict("DTX","DTX_VIAGEM") of oGrp1 PIXEL SIZE 20,10

		@ 90,15	SAY "Fil. Manif. de:" of oGrp1 PIXEL SIZE 30,15
		@ 90,46	MSGET aStatics[3] VAR cPerg03 PICTURE PesqPict("DTX","DTX_FILIAL") of oGrp1 PIXEL SIZE 20,10
		@ 90,85	SAY "Fil. Manif. ate:" of oGrp1 PIXEL SIZE 30,15
		@ 90,110	MSGET aStatics[4] VAR cPerg04 PICTURE PesqPict("DTX","DTX_FILIAL") of oGrp1 PIXEL SIZE 20,10

		@ 110,15	SAY "Manifesto de:" of oGrp1 PIXEL SIZE 30,15
		@ 110,46	MSGET aStatics[5] VAR cPerg05 PICTURE PesqPict("DTX","DTX_MANIFE") of oGrp1 PIXEL SIZE 20,10
		@ 110,85	SAY "Manifesto ate:" of oGrp1 PIXEL SIZE 30,15
		@ 110,110	MSGET aStatics[6] VAR cPerg06 PICTURE PesqPict("DTX","DTX_MANIFE") of oGrp1 PIXEL SIZE 20,10

		oDlg:bInit := {||  EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() },,)}

		oDlg:Activate()

	EndIf
EndIf

//Carrega variáveis estáticas referentes ao pergunte
If lMostraTela
	lMostraTela	:= .F.
	cPFilOri		:= cPerg01
	cPViagem		:= cPerg02
	cPFilMan_Ate	:= cPerg03
	cPFilMan_Ate	:= cPerg04
	cPManife_De	:= cPerg05
	cPManife_Ate	:= cPerg06
EndIf

//Retorna o valor referente à pergunta
Do Case
	Case nPerg == 1
		cValor :=	cPFilOri
	Case nPerg == 2
		cValor :=	cPViagem
	Case nPerg == 3
		cValor :=	cPFilMan_Ate
	Case nPerg == 4
		cValor :=	cPFilMan_Ate
	Case nPerg == 5
		cValor :=	cPManife_De
	Case nPerg == 6
		cValor :=	cPManife_Ate
EndCase

Return cValor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS190LDUD³ Autor ³ Ruan Salvador         ³ Data ³24/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ISSUE     ³MLOG-2565                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÙ±±
±±³Descri‡…o ³Limpa os campos DUD_SERMAN,DUD_FILMAN,DUD_MANIFE da tabela  ³±±
±±³          ³DUD - Movimento de viagem, com a finalidade de "librarar"   ³±±
±±³          ³os conhecimento para geracao de um novo manifesto.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS190LDUD(cFilOri, cViagem)

Local lRet := .T.
Local cFilEst  := {}
Local aMNConfl := {}
Local cMNConfl := ''
Local nCont
Local cAliasMNE


	cFilEst := TMS190ESTD(cFilOri, cViagem) /* Busca todas as Filiais por Estados, presentes nos conhecimentos da viagem */

	If !Empty(cFilEst)
		aMNConfl := TMS190MNCF(cFilOri, cViagem, cFilEst) /* Busca todos manifesto que sao conflitantes com os novos conhecimentos*/
	EndIf

	If !Empty(aMNConfl)
		/* Mensagem com os manifestos conflitantes */
		For nCont := 1 To Len (aMNConfl)
			If cMNConfl = ''
				cMNConfl = CHR(13)+CHR(10) + STR0057 + aMNConfl[nCont,1] + ' ' + STR0045 + ': '  + aMNConfl[nCont,2]
			Else
				cMNConfl += CHR(13)+CHR(10) + STR0057 + aMNConfl[nCont,1] + ' ' + STR0045 + ': '  + aMNConfl[nCont,2]
			EndIf
		Next
		ApMsgStop (STR0051 + CHR(13)+CHR(10) + cMNConfl, STR0052 )
		Return .F.
	EndIf

	cAliasMNE := TMS190MNEN(cFilOri, cViagem) /* Busca todos os manifestos que foram encerrados antes de seu destino */

	If (cAliasMNE)->(!Eof())
		lRet := TMS190TDUD(cAliasMNE, cFilOri, cViagem)
	EndIf


Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS190ESTD³ Autor ³ Ruan Salvador         ³ Data ³24/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca todas as Filiais por Estados, presentes nos          ³±±
±±³          ³ conhecimentos da viagem                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS190ESTD(cFilOri, cViagem)

local aEstados   := {} //Array contendo todas as filiais dos estados presentes na viagem
Local cAliasEst  := GetNextAlias()
Local cQuery     := ''
Local cFilEst
Local cEstados
Local nContEst

	cQuery :=  " SELECT DISTINCT DUD_FILDCA "
	cQuery +=  "   FROM "+RetSqlName('DUD')+" DUD "
	cQuery +=  "  WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cQuery +=  "    AND DUD.DUD_FILORI = '" + cFilOri + "'"
	cQuery +=  "    AND DUD.DUD_VIAGEM = '" + cViagem + "'"
	cQuery +=  "    AND DUD.DUD_SERTMS = '2' " // 2-Transporte
	cQuery +=  "    AND ISNULL(DUD.DUD_MANIFE,'"+Space(TamSX3('DUD_MANIFE')[1])+ "') = '"+Space(TamSX3('DUD_MANIFE')[1])+"'"
	cQuery +=  "    AND DUD.DUD_STATUS NOT IN ('4','9') " //1-Aberto 2-Transito 3-Carregado 4-Encerrado 9-Cancelado
	cQuery +=  "    AND DUD.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasEst,.T.,.T.)

	aArea := (cAliasEst)->(GetArea())
	aAreaSM0 := SM0->(GetArea())

	/* Busca os Estados das filiais presentes nos conhecimentos da viagem*/
	While (cAliasEst)->(!Eof())
	   cEstados := Posicione('SM0',1,cEmpAnt + (cAliasEst)->DUD_FILDCA,'M0_ESTENT')

	   If aScan( aEstados,{|x| x == cEstados }) = 0
	     aadd(aEstados,cEstados)
	   EndIf

	   (cAliasEst)->(dbSkip())
	EndDo
	RestArea(aArea)

	/* Busca Filiais por Estado */
	For nContEst := 1 to Len(aEstados)
		DbSelectArea("SM0")
		SM0->(DbGoTop())

		While SM0->(!Eof())
			If SM0->M0_ESTENT == aEstados[nContEst] .and. SM0->M0_CODIGO == cEmpAnt
				If Empty(cFilEst)
					cFilEst := "'"+SM0->M0_CODFIL+"'"
				Else
					cFilEst := cFilEst + "," +"'"+SM0->M0_CODFIL+"'"
				EndIf
			EndIf
		SM0->(dbSkip())
		EndDo
	End
	RestArea(aAreaSM0)

Return (cFilEst)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS190MNCF³ Autor ³ Ruan Salvador         ³ Data ³24/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca todos manifesto que sao conflitantes com os novos    ³±±
±±³          ³ conhecimentos												    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS190MNCF(cFilOri, cViagem, cFilEst)

Local cAliasDoc  := GetNextAlias()
Local cQuery := ''
Local aMNConfl := {} //Manifestos conflitantes

	cQuery :=  ""
	cQuery :=  " SELECT DISTINCT DUD.DUD_FILMAN , DUD.DUD_MANIFE "
	cQuery +=  "   FROM "+RetSqlName('DUD')+" DUD,"+ RetSqlName('DTX')+" DTX "
	cQuery +=  "  WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cQuery +=  "    AND DUD.DUD_FILORI = '" + cFilOri + "'"
	cQuery +=  "    AND DUD.DUD_VIAGEM = '" + cViagem + "'"
	cQuery +=  "    AND ISNULL(DUD.DUD_MANIFE,'"+Space(TamSX3('DUD_MANIFE')[1])+ "') <> '"+Space(TamSX3('DUD_MANIFE')[1])+"'"
	cQuery +=  "    AND DUD.DUD_STATUS NOT IN ('4','9') " //1-Aberto 2-Transito 3-Carregado 4-Encerrado 9-Cancelado
	cQuery +=  "    AND DUD.DUD_FILDCA IN ("+cFilEst+")"
	cQuery +=  "    AND DUD.D_E_L_E_T_ = ' ' "
	cQuery +=  "    AND DTX.DTX_FILMAN = DUD.DUD_FILMAN "
	cQuery +=  "    AND DTX.DTX_MANIFE = DUD.DUD_MANIFE "
	cQuery +=  "    AND DTX.DTX_SERMAN = DUD.DUD_SERMAN "
	cQuery +=  "	  AND DTX.DTX_STATUS IN ('1','2') "
	cQuery +=  "    AND DTX.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDoc,.T.,.T.)
	aArea := (cAliasDoc)->(GetArea())

	While (cAliasDoc)->(!Eof())
		Aadd(aMNConfl, {(cAliasDoc)->DUD_FILMAN, (cAliasDoc)->DUD_MANIFE})
		(cAliasDoc)->(dbSkip())
	EndDo
	RestArea(aArea)

Return (aMNConfl)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS190MNEN³ Autor ³ Ruan Salvador         ³ Data ³24/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca todos os manifestos que foram encerrados antes de    ³±±
±±³          ³ seu destino 													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS190MNEN(cFilOri, cViagem)

Local cQuery := ''
Local cAliasMNE  := GetNextAlias()

	cQuery :=  ""
	cQuery :=  " SELECT DUD.DUD_FILMAN , DUD.DUD_MANIFE, DUD.DUD_SERMAN, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.DUD_FILDCA, DUD.DUD_SEQUEN "
	cQuery +=  "   FROM "+RetSqlName('DUD')+" DUD,"+ RetSqlName('DTX')+" DTX "
	cQuery +=  "  WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cQuery +=  "    AND DUD.DUD_FILORI = '" + cFilOri + "'"
	cQuery +=  "    AND DUD.DUD_VIAGEM = '" + cViagem + "'"
	cQuery +=  "    AND ISNULL(DUD.DUD_MANIFE,'"+Space(TamSX3('DUD_MANIFE')[1])+ "') <> '"+Space(TamSX3('DUD_MANIFE')[1])+"'"
	cQuery +=  "    AND DUD.DUD_STATUS NOT IN ('4','9') " //1-Aberto 2-Transito 3-Carregado 4-Encerrado 9-Cancelado
	cQuery +=  "    AND DUD.D_E_L_E_T_ = ' ' "
	cQuery +=  "    AND DTX.DTX_FILMAN = DUD.DUD_FILMAN "
	cQuery +=  "    AND DTX.DTX_MANIFE = DUD.DUD_MANIFE "
	cQuery +=  "    AND DTX.DTX_SERMAN = DUD.DUD_SERMAN "
	cQuery +=  "    AND DTX.DTX_STATUS = '" + StrZero(3,Len(DTX->DTX_STATUS)) + "' " //Encerrado
	cQuery +=  "    AND DTX.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasMNE,.T.,.T.)

Return (cAliasMNE)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS190TDUD³ Autor ³ Ruan Salvador         ³ Data ³24/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de selecao de conhecimentos que tiveram MDF-e         ³±±
±±³          ³ encerrado antes do destino (UF)           				    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS190TDUD(cAliasMNE, cFilOri, cViagem)

Local aButtons    := {} //Botoes da tela
Local aStructBrw  := {} //Estrutura da tela
Local aCamposBrw  := {} //Campos que compoem a tela
Local aColsBrw    := {} //Colunas que compoem a tela
Local cAliComp    := GetNextAlias()
Local aAreaDUD    := DUD->(GetArea())
Local nCont
Local lRetDUD
Local cFilEst  := {}
Local aMNConfl := {}
Local cMNConfl := ''

	Aadd(aCamposBrw,"DUD_FILMAN")
	Aadd(aCamposBrw,"DUD_MANIFE")
	Aadd(aCamposBrw,"DUD_SERMAN")
	Aadd(aCamposBrw,"DUD_FILDOC")
	Aadd(aCamposBrw,"DUD_DOC")
	Aadd(aCamposBrw,"DUD_SERIE")
	Aadd(aCamposBrw,"DUD_FILDCA")
	Aadd(aCamposBrw,"DUD_SEQUEN")

	Aadd(aStructBrw, {"MARK"  , "C", 1, 0})

	For nCont := 1 To Len(aCamposBrw)
        Aadd(aStructBrw, { aCamposBrw[nCont],;
                           GetSX3Cache(aCamposBrw[nCont], "X3_TIPO"   ), ;
                           GetSX3Cache(aCamposBrw[nCont], "X3_TAMANHO"), ;
                           GetSX3Cache(aCamposBrw[nCont], "X3_DECIMAL")  ;
                         })

		If aCamposBrw[nCont] != 'DUD_SEQUEN'
			oBrwCol := FWBrwColumn():New()
			oBrwCol:SetType   ( GetSX3Cache(aCamposBrw[nCont], "X3_TIPO"  ) )
			oBrwCol:SetData   ( &("{|| " + aCamposBrw[nCont] + " }"       ) )
			oBrwCol:SetTitle  ( Trim(X3Titulo() ) )
			oBrwCol:SetSize   ( GetSX3Cache(aCamposBrw[nCont], "X3_TAMANHO") )
			oBrwCol:SetDecimal( GetSX3Cache(aCamposBrw[nCont], "X3_DECIMAL") )
			oBrwCol:SetPicture( GetSX3Cache(aCamposBrw[nCont], "X3_PICTURE") )
			oBrwCol:SetReadVar(aCamposBrw[nCont])

            AAdd(aColsBrw, oBrwCol)
		EndIf
	Next

	oTempComp := FWTemporaryTable():New(cAliComp)
	oTempComp:SetFields(aStructBrw)
	oTempComp:Create()

	While (cAliasMNE)->(!Eof())
		(cAliComp)->(RecLock((cAliComp), .T.))
		(cAliComp)->DUD_FILMAN := (cAliasMNE)->DUD_FILMAN
		(cAliComp)->DUD_MANIFE := (cAliasMNE)->DUD_MANIFE
		(cAliComp)->DUD_SERMAN := (cAliasMNE)->DUD_SERMAN
		(cAliComp)->DUD_FILDOC := (cAliasMNE)->DUD_FILDOC
		(cAliComp)->DUD_DOC    := (cAliasMNE)->DUD_DOC
		(cAliComp)->DUD_SERIE  := (cAliasMNE)->DUD_SERIE
		(cAliComp)->DUD_FILDCA := (cAliasMNE)->DUD_FILDCA
		(cAliComp)->DUD_SEQUEN := (cAliasMNE)->DUD_SEQUEN
		(cAliComp)->(MsUnlock())
		(cAliasMNE)->(dbSkip())
	EndDo

	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle(STR0055)
	oDlgMan:SetEscClose(.T.)
	oDlgMan:SetSize(300, 500)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()

	oFWLayer := FWLayer():New() //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.) //-- Inicializa container

	oFWLayer:AddLine('LIN', 100, .F.) //-- Linha
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna

	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	aBkpRotina := aRotina
	aRotina := ()

	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias(cAliComp)
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0056)
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetWalkThru(.F.)
	oMarkBrw:SetAmbiente(.F.)
	oMarkBrw:DisableConfig()
	oMarkBrw:DisableFilter()
	oMarkBrw:SetMenuDef("") 
	oMarkBrw:DisableSeek()
	oMarkBrw:DisableSaveConfig()

	bConfir := {|| oDlgMan:DeActivate(),;
					 lRetDUD    := .T.}

	bCancel := {|| oDlgMan:DeActivate(),;
					 lRetDUD    := .F.}

	//-- Cria botoes de operacao
	Aadd(aButtons, {"", STR0053, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aButtons, {"", STR0054, bCancel, , , .T., .F.}) // 'Cancelar'
	oDlgMan:AddButtons(aButtons)

	oMarkBrw:Activate()
	While (cAliComp)->(!Eof())
		oMarkBrw:MarkRec() 
		(cAliComp)->(dbSkip())
	EndDo
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)

	oDlgMan:Activate()

	If lRetDUD
		aArea := (cAliComp)->(GetArea())
		(cAliComp)->(DbGoTop())

		While (cAliComp)->(!Eof()) 
			If !Empty((cAliComp)->MARK) .or. (cAliComp)->MARK <> ' '
				DUD->( dbSetOrder(2) ) //DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
				If DUD->(MsSeek( xFilial("DUD") + cFilOri + cViagem + (cAliComp)->DUD_SEQUEN + (cAliComp)->DUD_FILDOC + (cAliComp)->DUD_DOC + (cAliComp)->DUD_SERIE ))

					RecLock("DUD", .F.)
					DUD->DUD_FILMAN := Space( Len( DUD->DUD_FILMAN ) )
					DUD->DUD_MANIFE := Space( Len( DUD->DUD_MANIFE ) )
				   	DUD->DUD_SERMAN := Space( Len( DUD->DUD_SERMAN ) )
					MsUnLock()

				EndIf
			EndIf
			(cAliComp)->(dbSkip())
		EndDo
		RestArea(aArea)
		RestArea(aAreaDUD)

		cFilEst := TMS190ESTD(cFilOri, cViagem) /* Busca todas as Filiais por Estados, presentes nos conhecimentos da viagem */

		If !Empty(cFilEst)
			aMNConfl := TMS190MNCF(cFilOri, cViagem, cFilEst) /* Busca todos manifesto que sao conflitantes com os novos conhecimentos*/
		EndIf

		If !Empty(aMNConfl)
			/* Mensagem com os manifestos conflitantes */
			For nCont := 1 To Len (aMNConfl)
				If cMNConfl = ''
					cMNConfl = CHR(13)+CHR(10) + STR0057 + aMNConfl[nCont,1] + STR0045 + ': '  + aMNConfl[nCont,2]
				Else
					cMNConfl += CHR(13)+CHR(10) + STR0057 + aMNConfl[nCont,1] + STR0045 + ': '  + aMNConfl[nCont,2]
				EndIf
			Next
			ApMsgStop (STR0051 + CHR(13)+CHR(10) + cMNConfl, STR0052 )
			Return .F.
		EndIf
	EndIf

	//-- Ao finalizar, elimina tabelas temporarias
	DbSelectArea((cAliComp))
	DbCloseArea()

	oTempComp:Delete()
	aRotina := aBkpRotina

Return (lRetDUD)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS190UFRD³ Autor ³ Aluizio Habizenreuter ³ Data ³27/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para busca da UF do Redespachante.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS190UFRD(cTipMan, cSerTms, cNumRed)
Local   aINFORD := {}

Default cTipMan := ''
Default cSerTms := ''
Default cNumRed := ''

//Caso exista Redespacho para o documento, buscar a UF do Redespachante. Esta sera considerada a UF de Destino do Manifesto.
If cTipMan == "1" .Or. (cTipMan == "2" .And. cSerTms == StrZero(3,Len(DUD->DUD_SERTMS))) //Normal ou Entrega e Eletronico
	If !Empty(cNumRed)
		aAreaDFT := DFT->(GetArea())
		DFT->(DbSetOrder(1))
		If DFT->(MsSeek(xFilial('DFT') + cNumRed))
			aAreaSA2 := SA2->(GetArea())
			If SA2->(MsSeek(xFilial('SA2') + DFT->DFT_CODFOR + DFT->DFT_LOJFOR))
				Aadd(aINFORD, SA2->A2_EST)
				Aadd(aINFORD, SA2->A2_COD_MUN)
				Aadd(aINFORD, SA2->A2_MUN)
			EndIf
			RestArea(aAreaSA2)
		EndIf
		RestArea(aAreaDFT)
	EndIf
EndIf

Return aINFORD

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TM190GrvDLH³ Autor ³ Felipe Barbieri      ³ Data ³06/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para gravação da tabela DLH (MDFe x Documentos)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM190GrvDLH(aDocs)
Local nCont := 0

For nCont := 1 to Len(aDocs)
	RecLock("DLH", .T.)
	DLH->DLH_FILIAL := xFilial('DLH')
	DLH->DLH_VIAGEM := aDocs[nCont, 1]
	DLH->DLH_FILDOC := aDocs[nCont, 2]
	DLH->DLH_DOC    := aDocs[nCont, 3]
	DLH->DLH_SERIE  := aDocs[nCont, 4]
	DLH->DLH_FILMAN := aDocs[nCont, 5]
	DLH->DLH_MANIFE := aDocs[nCont, 6]
	DLH->DLH_SERMAN := aDocs[nCont, 7]
	DLH->DLH_FILORI := aDocs[nCont, 8]
	MsUnlock()
Next nCont

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSLimpDUD³ Autor ³ Alex Amaral           ³ Data ³13/09/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para Limpar a DUD que tiveram MDF-e  encerrado      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSLimpDUD(cFilOri,cViagem,aMDFe,cFilLim)

Local cQuery		:= ""
Local cAliasDUD	:= GetNextAlias()
Local aAreaDUD	:= DUD->(GetArea())
Local cFilMan		:= ''
Local cManife		:= ''
Local cSerMan		:= ''
Local lRet        := .F.
Local nCnt
Local lUFAtiv     := DTX->(ColumnPos("DTX_UFATIV")) > 0

Default cFilOri		:= '' //-- Filial de Origem
Default cViagem		:= '' //-- VIAGEM
Default aMDFE			:= {}
Default cFilLim      := ""

If IsInCallStack("TMSA350Est")
	aMDFE := {}
	DTX->(DbSetOrder(5)) //-- DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI
	DTX->(MsSeek(xFilial("DTX")+cFilOri+cViagem ))
	Do WHile DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ cFilOri + cViagem
		If DTX->DTX_TIPMAN  == '2' .And. DTX->DTX_STFMDF == '2'
			Aadd(aMDFE ,Array(6))
			aMDFE[Len(aMDFE),1] := DTX->DTX_FILMAN //-- Filial Manif
			aMDFE[Len(aMDFE),2] := DTX->DTX_MANIFE //-- Manif. Inicial
			aMDFE[Len(aMDFE),3] := DTX->DTX_MANIFE //-- Manif. final
			aMDFE[Len(aMDFE),4] := DTX->DTX_SERMAN //-- Serie Manif.
			aMDFE[Len(aMDFE),5] := DTX->DTX_VIAGEM //-- VIAGEM
			If lUFAtiv
				aMDFe[Len(aMDFe),6] := DTX->DTX_UFATIV  //-- UF Atividade
		    EndIf
		EndIf
		DTX->(DbSkip())
	EndDo
EndIf

If !Empty(aMDFE)
	For nCnt := 1 To Len(aMDFE)

		cFilMan		:= aMDFE[nCnt,1]//-- Filial Manif
		cManife		:= aMDFE[nCnt,3]//-- Manifesto
		cSerMan		:= aMDFE[nCnt,4] //-- Serie Manif.

		cQuery := " SELECT DUD_FILIAL, DUD_FILORI, DUD_VIAGEM, DUD_FILMAN, DUD_MANIFE, DUD_SERMAN, DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD_FILDCA, DUD_SEQUEN "
		cQuery += " FROM " + RetSqlName("DUD")
		cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQuery += " AND DUD_FILORI = '" + cFilOri + "'"
		cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
		cQuery += " AND DUD_FILMAN = '" + cFilMan + "'"
		cQuery += " AND DUD_MANIFE = '" + cManife + "'"
		cQuery += " AND DUD_SERMAN = '" + cSerMan + "'"
		If !Empty(cFilLim)
			cQuery += " AND DUD_FILDCA = '" + cFilLim + "'"
		EndIf
		cQuery += " AND D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)

		(cAliasDUD)->(DbGoTop())

		While (cAliasDUD)->(!Eof())
			DUD->( dbSetOrder(2) ) //DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
			If DUD->(MsSeek( xFilial("DUD") + cFilOri + cViagem + (cAliasDUD)->DUD_SEQUEN + (cAliasDUD)->DUD_FILDOC + (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE )) .AND. (cAliasDUD)->DUD_MANIFE <> ''
				RecLock("DUD", .F.)
				DUD->DUD_FILMAN := Space( Len( DUD->DUD_FILMAN ) )
				DUD->DUD_MANIFE := Space( Len( DUD->DUD_MANIFE ) )
				DUD->DUD_SERMAN := Space( Len( DUD->DUD_SERMAN ) )
				MsUnLock()
				lRet := .T.
			EndIf
			(cAliasDUD)->(dbSkip())
		EndDo
		(cAliasDUD)->(DbCloseArea())
		RestArea(aAreaDUD)

	Next nCnt
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} TMA190MaCm()
Verifica se o Manifesto faz parte de uma viagem de Comboio

@Parametros			ExpC1 - Filial Manifesto
 				    ExpC2 - Manifesto
					Expc3 - Serie Manifesto
					
@author Katia
@since 03/05/2018
@version 1.0
/*/
//-----------------------------------------------------------
Function TMA190MaCm(cFilMan, cManife, cSerMan, lValida, cManfsExc, aManComb)

Local cAliasCom   := GetNextAlias()
Local cQuery      := ''
Local aAreaDTX    := DTX->(GetArea())
Local lRet        := .T.

Default cFilMan   := ''
Default cManife   := ''
Default cSerMan   := ''
Default lValida   := .T.   //Somente Valida ou Retorna dados do aManfsExc
Default cManfsExc := ""
Default aManComb  := {}

cQuery:= " SELECT * FROM ( "
cQuery+= " SELECT DTX1.DTX_FILMAN DTX_FILMAN, DTX1.DTX_MANIFE DTX_MANIFE, DTX1.DTX_SERMAN DTX_SERMAN, DTX1.R_E_C_N_O_ RECNODTX, DTX1.DTX_PRMACO DTX_PRMACO "
cQuery+= "  FROM " + RetSqlName('DTX') + " DTX "
cQuery+= "  LEFT JOIN " + RetSqlName('DTX') + " DTX1 "
cQuery+= "  ON DTX1.DTX_FILIAL = '"+ xFilial("DTX") + "' "
cQuery+= "  AND DTX1.DTX_FILMAN = DTX.DTX_FILMAN  "
cQuery+= "  AND (DTX1.DTX_MANIFE = DTX.DTX_PRMACO OR DTX1.DTX_MANIFE = DTX.DTX_MANIFE)  "
cQuery+= "  AND DTX1.DTX_SERMAN = DTX.DTX_SERMAN "
cQuery+= "  AND DTX1.DTX_TIPMAN = DTX.DTX_TIPMAN "
cQuery+= "  AND DTX1.D_E_L_E_T_= ' ' "
cQuery+= "  WHERE DTX.DTX_FILIAL = '"+ xFilial("DTX") + "' "
cQuery+= "    AND DTX.DTX_FILMAN = '" + cFilMan + "' "
cQuery+= "    AND DTX.DTX_MANIFE = '" + cManife + "' "
cQuery+= "    AND DTX.DTX_SERMAN = '" + cSerMan + "' "
cQuery+= "    AND DTX.D_E_L_E_T_= ' ' "

cQuery+= "  UNION "

cQuery+= " SELECT DTX1.DTX_FILMAN DTX_FILMAN, DTX1.DTX_MANIFE DTX_MANIFE, DTX1.DTX_SERMAN DTX_SERMAN, DTX1.R_E_C_N_O_ RECNODTX, DTX1.DTX_PRMACO DTX_PRMACO "
cQuery+= "  FROM " + RetSqlName('DTX') + " DTX "
cQuery+= "  LEFT JOIN " + RetSqlName('DTX') + " DTX1 "
cQuery+= "  ON DTX1.DTX_FILIAL = '"+ xFilial("DTX") + "' "
cQuery+= "  AND DTX1.DTX_FILMAN = DTX.DTX_FILMAN  "
cQuery+= "  AND ( DTX1.DTX_PRMACO = DTX.DTX_MANIFE OR DTX1.DTX_PRMACO = DTX.DTX_PRMACO ) AND DTX1.DTX_PRMACO <> '' "
cQuery+= "  AND DTX1.DTX_SERMAN = DTX.DTX_SERMAN "
cQuery+= "  AND DTX1.DTX_TIPMAN = DTX.DTX_TIPMAN "
cQuery+= "  AND DTX1.D_E_L_E_T_= ' ' "
cQuery+= "  WHERE DTX.DTX_FILIAL = '"+ xFilial("DTX") + "' "
cQuery+= "    AND DTX.DTX_FILMAN = '" + cFilMan + "' "
cQuery+= "    AND DTX.DTX_MANIFE = '" + cManife + "' "
cQuery+= "    AND DTX.DTX_SERMAN = '" + cSerMan + "' "
cQuery+= "    AND DTX.D_E_L_E_T_= ' ' "

cQuery+= "  GROUP BY DTX1.DTX_FILMAN, DTX1.DTX_MANIFE, DTX1.DTX_SERMAN, DTX1.R_E_C_N_O_, DTX1.DTX_PRMACO "
cQuery += ") QRY1 "
cQuery += " WHERE DTX_MANIFE > ' ' OR DTX_PRMACO > ' ' "
cQuery += " ORDER BY DTX_FILMAN, DTX_MANIFE "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasCom,.T.,.T.)
While (cAliasCom)->(!Eof())
	If lValida 
		If Empty(cManfsExc)
			cManfsExc := (cAliasCom)->DTX_MANIFE
		Else
			cManfsExc += ", " + (cAliasCom)->DTX_MANIFE
		EndIf
	EndIf		
	aAdd(aManComb, {(cAliasCom)->DTX_FILMAN, (cAliasCom)->DTX_MANIFE, (cAliasCom)->DTX_SERMAN, (cAliasCom)->RECNODTX })
	
	(cAliasCom)->(dbSkip())
EndDo

(cAliasCom)->(DbCloseArea())
RestArea(aAreaDTX)

Return lRet
	
//----------------------------------------------------------
/*/{Protheus.doc} TMA190VCom()
Retorna Qtde de Veiculos da Viagem para identificar se é uma
Viagem de Comboio
@Parametros			ExpC1 - Filial Origem
 				    ExpC2 - Viagem
					
@author Katia
@since 03/05/2018
@version 1.0
/*/
//-----------------------------------------------------------	
Function TMA190VCom(cFilOri, cViagem)
Local nQtVeicDTR := 0
Local cQuery     := ""
Local cAliasCnt  := GetNextAlias()

Default cFilOri:= ""
Default cViagem:= ""

cQuery := "SELECT COUNT(*) nQtdVeic "
cQuery += " FROM " + RetSqlName("DTR") + " DTR "
cQuery += " WHERE DTR_FILIAL = '" + xFilial("DTR") +  "' "
cQuery += "   AND DTR_FILORI = '" + cFilOri + "' "
cQuery += "   AND DTR_VIAGEM = '" + cViagem + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCnt)

nQtVeicDTR := (cAliasCnt)->nQtdVeic

(cAliasCnt)->(dbCloseArea())

Return nQtVeicDTR

//----------------------------------------------------------
/*/{Protheus.doc} TMA190DYN()
Grava Tabela para envio do Cancelamento da MDFe

@Parametros			ExpC1 - Observação Cancelamento
					Registro DTX posicionado
@author Katia
@since 07/05/2018
@version 1.0
/*/
//-----------------------------------------------------------	
Static Function TMA190DYN(cObsCan)

Local lDTX_CODVEI := DTX->(FieldPos("DTX_CODVEI")) > 0
Local lDTX_PRMACO := DTX->(FieldPos("DTX_PRMACO")) > 0

Default cObsCan:= ""

DYN->(DbSetOrder(3)) //-- DYN_FILIAL+DYN_FILMAN+DYN_MANIFE+DYN_SERMAN+DYN_STCMDF
If !DYN->(MsSeek(DTX->(xFilial("DYN") + DTX_FILMAN + DTX_MANIFE + DTX_SERMAN)))
	//+----------------------------------------------------------------------------
	//| Grava Tabela para envio do Cancelamento da MDFe
	//+----------------------------------------------------------------------------
	If DTX->(FieldPos('DTX_TIPMAN')) > 0 .And. DTX->DTX_TIPMAN == '2' .And. DTX->DTX_STIMDF == '2'
		RecLock("DYN", .T.)
		DYN->DYN_FILIAL:= xFilial('DYN')
		DYN->DYN_FILMAN:= DTX->DTX_FILMAN
		DYN->DYN_MANIFE:= DTX->DTX_MANIFE
		DYN->DYN_SERMAN:= DTX->DTX_SERMAN
		DYN->DYN_FILORI:= DTX->DTX_FILORI
		DYN->DYN_VIAGEM:= DTX->DTX_VIAGEM
		DYN->DYN_DATMAN:= DTX->DTX_DATMAN
		DYN->DYN_HORMAN:= DTX->DTX_HORMAN
		DYN->DYN_FILDCA:= DTX->DTX_FILDCA
		DYN->DYN_CDRDES:= DTX->DTX_CDRDES
		If lDTX_CODVEI
			DYN->DYN_CODVEI:= DTX->DTX_CODVEI
		EndIf
		DYN->DYN_CHVMDF:= DTX->DTX_CHVMDF
		DYN->DYN_PRIMDF:= DTX->DTX_PRIMDF
		DYN->DYN_STIMDF:= DTX->DTX_STIMDF
		DYN->DYN_RTIMDF:= DTX->DTX_RTIMDF
		DYN->DYN_IDIMDF:= DTX->DTX_IDIMDF
		DYN->DYN_CTGMDF:= DTX->DTX_CTGMDF
		DYN->DYN_STCMDF:= '0'
		DYN->DYN_RTCMDF:= STR0049 //'016 - Cancelamento do MDF-e nao transmitido.
		DYN->DYN_IDCMDF:= ''
		
		If lDTX_PRMACO
			If !Empty(DTX->DTX_PRMACO)
				DYN->DYN_PRMACO := DTX->DTX_PRMACO
			EndIf
		EndIf
		MSMM(DYN->DYN_CODOBS,,,cObsCan,1,,,"DYN","DYN_CODOBS")
		MsUnLock()
	EndIf
EndIf
Return 


//----------------------------------------------------------
/*/{Protheus.doc} TMA190Srv()
Verifica se o Manifesto Automaticao está habilitado
para todas os serviços de Transporte das viagens
@Parametros	
@author Katia
@since 07/12/2020
@version 
/*/
//-----------------------------------------------------------	
Function TMA190Srv(cFilOri,cViagem)
Local cMdfeSrv   := SuperGetMv('MV_MDFESRV',,'')  //''-Todos,2-Transferencia,3-Entrega
Local lMdfeAut   := SuperGetMV("MV_MDFEAUT",,.F.) 
Local aAreas   	 := {DTQ->(GetArea()),GetArea()}
Local lRet       := .F.
Local lVgeMod3   := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

Default cFilOri := ""
Default cViagem := ""

DTQ->(DbSetOrder(2))
If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))

	If lVgeMod3 .And. ExistFunc("TmsAutViag") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0
		lRet := TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA190")
	EndIf
	
	If !lRet
		If lMdfeAut
			If !Empty(cMdfeSrv)   
				lRet := (DTQ->DTQ_SERTMS == cMdfeSrv)
			Else
				lRet := .T.
			EndIf
		EndIf
	EndIf

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} TM190Condt()
Inclusao do Condutor - MenuDef para o Browse da Vge Mod3
@Parametros	
@author Katia
@since 29/04/2021
@version 
/*/
//-----------------------------------------------------------	
Function TM190Condt()
	//-- Executa a alteração da viagem
	If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))	//-- Viagem em trânsito
		//-- Indica para o modelo da viagem que é inclusão de condutor
		TMFSetStat("lIncMot",.T.)
	
		FWExecView(, "TMSAF60", 4, , { || .T. } )
		
		//-- Indica para o modelo da viagem que não é inclusão de condutor
		TMFSetStat("lIncMot",.F.)

	Else
  		Help("",1,"TMSXFUNA25")
	EndIF
Return
