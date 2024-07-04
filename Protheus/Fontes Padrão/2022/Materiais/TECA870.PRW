#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA870.CH"
#INCLUDE "GCTXDEF.CH"

//Status do orçamento de serviços
#DEFINE DEF_TFJ_ATIVO     "1"			//TFJ_STATUS Ativo
#DEFINE DEF_TFJ_EMREVISAO "2"			//TFJ_STATUS Em Revisão	
#DEFINE DEF_TFJ_REVISADO  "3"			//TFJ_STATUS Revisado
#DEFINE DEF_TFJ_AGDAPROVA "4"			//TFJ_STATUS Aguardando Aprovação
#DEFINE DEF_TFJ_ENCERRADO "5"			//TFJ_STATUS Encerrado
#DEFINE DEF_TFJ_CANCELADO "6"			//TFJ_STATUS Cancelado
#DEFINE DEF_TFJ_REVPLANEJ "8"			//TFJ_STATUS Revisão Planejada

//GESTÃO DE CONTRATOS
#DEFINE DEF_NDESC         "CNBNDESC"	//Identificacao da coluna Novo Desconto
#DEFINE DEF_NVLDESC       "CNBNVLDESC"	//Identificacao da coluna Novo Valor de Desconto
#DEFINE DEF_DESCNA        "CNBDESC"	//Nome de alteracao do campo CNB_DESC para impedir execucao do gatilho
#DEFINE DEF_VLDECNA       "CNBVLDESC"	//Nome de alteracao do campo CNB_DESC para impedir execucao do gatilho

//REVISAO
Static lViTc740 := .F. //Determina se a view do teca740 já está ativa na tela
Static lMtImp   := .T.
Static lMtCns   := .T.

//VINCULO DE BENEFICIOS
Static _aTFFCOD_     := {}	// Armazena os codigos gerados para os itens do RH
Static _aRevisao_    := {}	// Armazena se é revisao e o tipo de revisao
Static aLinesTFU	 := {}
Static lTravLin		 := .F.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA870
Gestão do Contrato
@author Serviços
@since 30/09/2013
@version P11 R9
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA870()

Local oBrowse		
Local aColumns		:= {}
Local cQuery		:= ""
Local cAliasPro		:= "MNTPRO"
Local oDlg			:= Nil   							// Janela Principal.
Local aSize			:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local aRotPE		:= {}
Local nI			:= 0								//Array P.E.
Local aButtons 		:= {} //Array dos botoes da gestão de Contratos
Local aCloneBtn		:= {}
Local lGSLE 		:= GSGetIns('LE')
Local lGSRH 		:= GSGetIns('RH')
Local lHasOrcSmp 	:= HasOrcSimp()
Local lOrcSimp		:= lHasOrcSmp .And. SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local lOrcPrc		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lRevisaPla	:= SuperGetMv("MV_GSDSGCN",,"2") == "1" .AND. !lGSLE .AND. !lOrcPrc
Local nTamRev		:= TamSX3("CN9_REVATU")[1]
Local dSemana       := (dDataBase - 7)
Local dTrimes       := (dDataBase - 90)
Local dAno          := (dDataBase - 365)
Local dAnoIni       := CTOD("")
Local dAnoFim       := CTOD("")

dAnoIni := FirstYDate(dAno)
dAnoFim := LastYDate(dAno)

AT870GetTr( .F. )
Pergunte("CNT100",.F.)

aColumns := At870Cols(cAliasPro)
// Posição 3 de aColumns são as colunas do ponto de entrada TC870BRW - padrão é vazio
cQuery   := At870Query(aColumns[3])

If FindFunction("TecBMetrics")
	TecBMetrics()
EndIf

If !isBlind()
	//Cria a tela para o browse
	DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL STYLE WS_DLGFRAME       // "Manutenção de Proposta"

		// Cria um Form Browse
		oBrowse := FWFormBrowse():New()
		// Atrela o browse ao Dialog form nao abre sozinho
		oBrowse:SetOwner(oDlg)
		// Indica que vai utilizar query
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAliasPro)
		oBrowse:SetQuery(cQuery)

		//Filtros
		oBrowse:SetUseFilter( .T. )
		oBrowse:SetFieldFilter(aColumns[2])

		//Colunas
		oBrowse:AddStatusColumns({|| At870Contr((cAliasPro)->TFJ_STATUS, (cAliasPro)->TFJ_CONTRT, (cAliasPro)->TFJ_CONREV)}, {|| At870Legen()})
		oBrowse:SetColumns(aColumns[1])

        If At680Perm(NIL, __cUserId,"062", .T.)
		    AADD(aButtons, {STR0027,; // "01 - Visualizar Orçamento"
			    {|| MsgRun(STR0003,STR0004,{|| At870View((cAliasPro)->TFJ_CODIGO)})},1})// "Montando os componentes visuais..."##"Aguarde"
		Endif		

		// Botao de alocação de atendentes
        If At680Perm(NIL, __cUserId, "063", .T.)		
		    AADD(aButtons, { STR0077,; // 02 - "Visualizar Contrato"
			     {|| MsgRun(STR0003,STR0004,{|| At870ViCtr((cAliasPro)->TFJ_CODIGO)})},1})// "Montando os componentes visuais..."##"Aguarde"
        Endif

        // Botao de confirmacao de entrega e coleta
		If  lGSLE .And. At680Perm(NIL, __cUserId, "064", .T.)
			AADD(aButtons, {  STR0103,; //03 - "Confirm. de Entrega e Coleta"
				{|| MsgRun(STR0003,STR0004,{|| At870Conf((cAliasPro)->TFJ_CODIGO,(cAliasPro)) } ) },1})// "Montando os componentes visuais..."##"Aguarde"
		EndIf

        If At680Perm(NIL, __cUserId, "047", .T.)	
		    AADD(aButtons, {STR0006, {||MsgRun(STR0003,STR0004,{|| At870PRev((cAliasPro)->TFJ_CODIGO,(cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV)}),; //06 - "Revisão GCT"
				MsgRun(STR0023,STR0004,{|| At870AtuBrw(oBrowse)})},2})  // "Atualizando informações" # "Aguarde"
		Endif			
					
        If At680Perm(NIL, __cUserId, "048", .T.)
		    AADD(aButtons, {STR0035, {|| At870VlEfR((cAliasPro)->TFJ_STATUS,(cAliasPro)->TFJ_CODIGO,(cAliasPro)->TFJ_TIPREV,oBrowse) },1} )//07 - "Efetiva Revisão"
		Endif		

        If At680Perm(NIL, __cUserId, "049", .T.)
		    AADD(aButtons, {STR0036, {|| INCLUI:=.F.,ALTERA:=.T.,At870AprRv((cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV,(cAliasPro)->TFJ_STATUS,,(cAliasPro)->TFJ_CODIGO),INCLUI:=.F.,ALTERA:=.F.,At870AtuBrw(oBrowse) },1} )//08 - "Aprova Revisão"
		Endif

        If At680Perm(NIL, __cUserId, "050", .T.)
			AADD(aButtons, {STR0056, {|| At870GerOrc((cAliasPro)->TFJ_CODIGO,(cAliasPro) ) }, 2 })	//09 - 'Adicionar Itens Extras'
		Endif	

        If At680Perm(NIL, __cUserId, "051", .T.)
		    AADD(aButtons, {STR0037, {|| lRet := At870ExcR((cAliasPro)->TFJ_STATUS,(cAliasPro)->TFJ_CODIGO,(cAliasPro)->TFJ_CONTRT , (cAliasPro)->TFJ_CONREV ), IIF(lRet,At870AtuBrw(oBrowse),Nil),IIf(lRet,MsgInfo(STR0038),Nil)  }, 1} )//11 - "Excluir"#"Revisão apagada com sucesso."
		Endif	

		If !lGSLE .And. At680Perm(NIL, __cUserId, "052", .T.)
			AADD(aButtons, {STR0304, {|| lRet := At870DesRe((cAliasPro)->TFJ_STATUS,(cAliasPro)->TFJ_CODIGO,(cAliasPro)->TFJ_CONTRT , (cAliasPro)->TFJ_CONREV, lOrcPrc), IIF(lRet,At870AtuBrw(oBrowse),Nil),IIf(lRet,MsgInfo(STR0305),Nil)  }, 1} )// "Desfazer Revisão" ## "Processo concluido."
		EndIf

		If  lGSRH .And. At680Perm(NIL, __cUserId, "053", .T.)
			AADD(aButtons, {STR0060, {|| At870GerMem((cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV,(cAliasPro)) }, 2 }) //12 - Memorando
		Endif

        If At680Perm(NIL, __cUserId, "054", .T.)		
		    AADD(aButtons, {STR0067, {|| At870EncPo((cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV,(oBrowse), (cAliasPro)) }, 2 })	//13 - "Encerramento Posto"
		Endif	

        If At680Perm(NIL, __cUserId, "055", .T.)	
		    AADD(aButtons, {STR0081, {|| At870NwSit((cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV, DEF_TFJ_CANCELADO, .T.),;		//14 - "Cancelamento"
					MsgRun(STR0023,STR0004,{|| At870AtuBrw(oBrowse) } ) }, 2 } ) // "Atualizando informações" # "Aguarde"
		Endif			

        If At680Perm(NIL, __cUserId, "056", .T.)	
		    AADD(aButtons, {STR0147, {|| TECA850((cAliasPro)->TFJ_CODIGO, (cAliasPro)->TFJ_CONTRT, (cAliasPro)->TFJ_CONREV, (cAliasPro)->TFJ_PROPOS),;//16 - "Manutenção do assistente"
                    MsgRun(STR0023,STR0004,{|| At870AtuBrw(oBrowse) } ) }, 2 })	
		ENDIF

        If At680Perm(NIL, __cUserId, "057", .T.)	
		    AADD(aButtons, {STR0252, {|| At870Docum() }, 2 }) // Conhecimento
		Endif	

		If ExistFunc("TECA870D") .AND. !lOrcPrc .And. At680Perm(NIL, __cUserId, "059", .T.)	
			aAdd( aButtons, {STR0273, {|| TECA870D(),;		//"Revisão em Lote"
			MsgRun(STR0023,STR0004,{|| At870AtuBrw(oBrowse) } )}, 2 }) // "Atualizando informações" # "Aguarde"
		EndIf

		If At870Perm()
			aAdd(aButtons, {STR0277, {|| At870AddCli(oBrowse, (cAliasPro)->TFJ_STATUS, (cAliasPro)->TFJ_CONTRT, (cAliasPro)->TFJ_CONREV)}, 2}) //"Adicionar Clientes"
		EndIf

		If lRevisaPla .AND. TecVerRePl() .And. At680Perm(NIL, __cUserId, "060", .T.) .And. At680Perm(NIL, __cUserId, "061", .T.)	
			aAdd(aButtons, {STR0315, {|| AT870PlaRe((cAliasPro)->TFJ_CODIGO,(cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV), At870AtuBrw(oBrowse)}, 2}) //"Revisão Planejada"
			aAdd(aButtons, {STR0321, {|| AT870RvPlC(), At870AtuBrw(oBrowse)}, 2}) //"Aplicar Revisão Planejada"
		EndIf

        If At680Perm(NIL, __cUserId, "065", .T.)
		   aAdd( aButtons, {STR0355, {|| AT870Antco((cAliasPro)->TFJ_CONTRT,(cAliasPro)->TFJ_CONREV,(cAliasPro)->TFJ_CODIGO)},2})	//17 - "Antecipar Contrato"		
        EndIf                                                                                                                                                                                                                                                                                                                                                                                                                                                       

		//Ponto de Entrada para retornar os  botoes da interface
		If (ExistBlock( "AT870NWMNU" ))
			aCloneBtn  := aClone(aButtons)
			aRotPE := ExecBlock( "AT870NWMNU", .F., .F., aCloneBtn ) //Retorna o Novo Menu Definido pelo usuário
			If ValType(aRotPE) = "A"
				aButtons := aClone(aRotPE)
			EndIf
			aRotPE := {}
		EndIf

		//Adiciona a Legenda
		aAdd( aButtons, { STR0016, {|| AT870Legen()}, 2 } )	//18 - 'Legenda'

		//Ponto de Entrada para adicionair os botoes na interface
		If (ExistBlock( "AT870MNU" ))
			aRotPE := ExecBlock( "AT870MNU", .F., .F., {cAliasPro,@oBrowse} )
			If ValType(aRotPE) == "A"
				For nI:=1 To Len(aRotPE)
					If ValType(aRotPE[nI]) == "A"
						aAdd( aButtons, { aRotPE[nI][1], aRotPE[nI][2], 2 } )
					EndIf
				Next nI
			EndIf
		EndIf

		aAdd( aButtons, { STR0005, {|| oDlg:End()},1 } ) //19 - "Sair"

		For nI := 1 to len(aButtons)
			oBrowse:AddButton(aButtons[nI][1], aButtons[nI][2],,,, .F., aButtons[nI][3] )
		Next nI

		oBrowse:SetParam({|| Pergunte("CNT100",.T.)}) //F12

		SetKey(VK_F10,{|| At870Filt(oBrowse)}) //F10

		oBrowse:DisableDetails()
		oBrowse:SetDescription(STR0001)  // "Manutenção da proposta"

		oBrowse:AddFilter( STR0296, "TFJ_CNTREC == '1' ")//Contrato Recorrente
		oBrowse:AddFilter( STR0297, "CN9_DTINIC >= '" +DTOS(dSemana)+"'")//Gerados na última semana
		oBrowse:AddFilter( STR0298, "CN9_DTINIC >= '" +DTOS(dTrimes)+"'")//Gerados no último trimestre
		oBrowse:AddFilter( STR0299, "CN9_DTINIC >= '" +DTOS(dAnoIni)+"' .AND. CN9_DTINIC <= '" +DTOS(dAnoFim)+ "'" )//Gerados no último ano
		oBrowse:AddFilter( STR0268, "CN9_REVATU == 	'"+Space(nTamRev)+"'")//"Apenas contratos vigentes"
		oBrowse:AddFilter( STR0007, "TFJ_STATUS == '1' ")//Contrato Ativo
		oBrowse:AddFilter( STR0008, "TFJ_STATUS == '2' ")//Contrato em Revisão
		oBrowse:AddFilter( STR0040, "TFJ_STATUS == '3' ")//Contrato Revisado
		oBrowse:AddFilter( STR0041, "TFJ_STATUS == '4' ")//Contrato Aguardando aprovação
		oBrowse:AddFilter( STR0070, "TFJ_STATUS == '5' ")//Contrato Encerrado
		oBrowse:AddFilter( STR0080, "TFJ_STATUS == '6' ")//Contrato Cancelado

		If isBlind()
			oBrowse := nil
		Else
			oBrowse:Activate() 
		EndIf

	ACTIVATE DIALOG oDlg CENTERED
EndIf

Return(Nil)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Query
Query com os dados da proposta
@author Serviços
@since 01/10/2013
@version P11 R9
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870Query(cUSRqry)  

Local	cQuery		:= ""
Local	nTamCont	:= TamSX3("TFJ_CONTRT")[2]
Local 	lHasOrcSmp := HasOrcSimp()
Local 	lOrcSimp	:= lHasOrcSmp .And. SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local lResTec		:= TFJ->(ColumnPos("TFJ_RESTEC"))>0

Default cUSRqry := ""

If IsInCallStack('At870Filt')
	Pergunte("TECA870",.T.)
EndIf

cQuery += " SELECT TFJ.TFJ_CODIGO, TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS, TFJ.TFJ_STATUS, TFJ.TFJ_TIPREV, "
cQuery += "TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_CNTREC,"

If lOrcSimp
   cQuery += " TFJ.TFJ_DATA,"
EndIf

If TecVerRePl()
	cQuery += " CASE WHEN TFJ2.TFJ_DTPLRV IS NOT NULL THEN TFJ2.TFJ_DTPLRV ELSE '' END TFJ_DTPLRV, "
EndIf

cQuery += " CASE WHEN CN9.CN9_DTINIC IS NOT NULL THEN CN9.CN9_DTINIC ELSE '' END CN9_DTINIC,"
cQuery += " CASE WHEN CN9.CN9_DTFIM IS NOT NULL THEN CN9.CN9_DTFIM ELSE '' END CN9_DTFIM,"
cQuery += " CASE WHEN ADY.ADY_ENTIDA  IS NOT NULL THEN  ADY.ADY_ENTIDA ELSE '' END ADY_ENTIDA ,"
cQuery += " CASE WHEN ADY.ADY_CODIGO IS NOT NULL THEN ADY.ADY_CODIGO ELSE " + IIF( !lOrcSimp, " '' ", " TFJ.TFJ_CODENT ") + " END ADY_CODIGO, "
cQuery += " CASE WHEN ADY.ADY_LOJA IS NOT NULL THEN ADY.ADY_LOJA ELSE " + IIF( !lOrcSimp, " '' " ,"TFJ.TFJ_LOJA ") + " END ADY_LOJA, "
cQuery += " CASE WHEN AD1.AD1_DTINI IS NOT NULL THEN AD1.AD1_DTINI ELSE '' END AD1_DTINI, "
cQuery += " CASE WHEN AD1.AD1_DTFIM IS NOT NULL THEN AD1.AD1_DTFIM ELSE '' END AD1_DTFIM, "
cQuery += " CASE WHEN AD1.AD1_NROPOR IS NOT NULL THEN AD1.AD1_NROPOR ELSE '' END AD1_NROPOR, "
cQuery += " CASE WHEN AD1.AD1_DESCRI IS NOT NULL THEN AD1.AD1_DESCRI ELSE '' END AD1_DESCRI, "
cQuery += " CASE WHEN A1_NOME IS NOT NULL THEN A1_NOME ELSE '' END A1_NOME, "
cQuery += " CASE WHEN A1_CGC IS NOT NULL THEN A1_CGC ELSE '' END A1_CGC, "
cQuery += " CASE WHEN CN9_REVATU IS NOT NULL THEN  CN9_REVATU ELSE '' END  CN9_REVATU "
// Inclusão das colunas do ponto de entrada TC870BRW na query do browse
If !Empty(cUSRqry)
	cQuery += ", " + cUSRqry
EndIf
cQuery += " FROM " + RetSqlName("TFJ") + " TFJ "
cQuery += " LEFT JOIN " + RetSqlName("ADY") + " ADY"
cQuery += " ON ADY.ADY_FILIAL = '" + xFilial("ADY") + "' AND "
cQuery += " ADY.D_E_L_E_T_ = ' ' AND "

cQuery += " TFJ.TFJ_PROPOS = ADY.ADY_PROPOS AND "
cQuery += " TFJ.TFJ_PREVIS = ADY.ADY_PREVIS AND "
If	isBlind() .OR. ( IsInCallStack('At870Filt') .And. MV_PAR01 <> 5 )
	cQuery +=       " TFJ.TFJ_STATUS = '" + Alltrim(STR(MV_PAR01)) + "' AND "
EndIf
If lResTec
	cQuery += " TFJ.TFJ_RESTEC <> '2' AND " // Desconsiderar Orcamento de Reserva Tecnica 
EndIf
cQuery +=           " TFJ.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("AD1") + " AD1 "
cQuery +=        " ON AD1.AD1_FILIAL = '" + xFilial("AD1") + "' AND "
cQuery +=           " AD1.AD1_NROPOR = ADY.ADY_OPORTU  AND "
cQuery +=           " AD1.AD1_REVISA = ADY.ADY_REVISA  AND "
cQuery +=           " AD1.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("AAH") + " AAH "
cQuery +=        " ON AAH.AAH_FILIAL = '" + xFilial("AAH") + "' AND "
cQuery +=           " AAH.AAH_CONTRT = TFJ.TFJ_CONTRT AND "
cQuery +=           " AAH.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("CN9") + " CN9 "
cQuery +=        " ON CN9.CN9_FILIAL = '" + xFilial("CN9") + "' AND "
cQuery +=           " CN9.CN9_NUMERO = TFJ.TFJ_CONTRT AND "
cQuery +=           " CN9.CN9_REVISA = TFJ.TFJ_CONREV AND "
cQuery +=           " CN9.D_E_L_E_T_ = ' ' "

If !lOrcSimp
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=        " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
	cQuery +=           " SA1.A1_COD = AD1.AD1_CODCLI AND "
	cQuery +=           " SA1.A1_LOJA = AD1.AD1_LOJCLI AND "
	cQuery +=           " SA1.D_E_L_E_T_ = ' ' "
Else
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=        " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
	cQuery +=  			" SA1.D_E_L_E_T_ = ' '  AND "
	cQuery +=           " ( (SA1.A1_COD = TFJ.TFJ_CODENT AND "
	cQuery +=           " SA1.A1_LOJA = TFJ.TFJ_LOJA AND "
	cQuery +=           " TFJ.TFJ_ORCSIM = '1' ) OR "
	cQuery +=           " (SA1.A1_COD = AD1.AD1_CODCLI AND "
	cQuery +=           " SA1.A1_LOJA = AD1.AD1_LOJCLI AND 
	cQuery +=           " TFJ.TFJ_ORCSIM <> '1') )"	
	         
EndIf
If TecVerRePl()
	cQuery += " LEFT JOIN " + RetSQLName("TFJ") + " TFJ2 "
	cQuery += " ON TFJ.TFJ_CODIGO = TFJ2.TFJ_CODREL "
	cQuery += " AND TFJ.TFJ_FILIAL = TFJ2.TFJ_FILIAL "
	cQuery += " AND TFJ2.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFJ2.TFJ_STATUS = '8' "
EndIf
cQuery +=       "WHERE (TFJ.TFJ_CONTRT <> '"+Space(nTamCont)+"') AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
cQuery += 					" TFJ.D_E_L_E_T_ = ' ' AND "
cQuery += 					" TFJ.TFJ_STATUS <> '8' AND "
cQuery += 	" (AAH.AAH_CONTRT IS NULL OR AAH.AAH_STATUS = '1') "
If lOrcSimp
	cQuery += "ORDER BY TFJ.TFJ_CODIGO"
Else
	cQuery += "ORDER BY ADY.ADY_PROPOS, ADY.ADY_REVISA"
EndIf

Return(cQuery)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Cols
Colunas para o browse com os dados da proposta
@author Serviços
@since 01/10/2013
@version P11 R9
@param		ExpC1, string ,Alias utilizado para o retorno das colunas
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870Cols(cAliasPro)
Local lHasOrcSmp 	:= HasOrcSimp()
Local lOrcSimp		:= lHasOrcSmp.And. SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local nI			:= 0
Local aArea			:= GetArea()
Local aColumns		:= {}
Local aFiltros		:= {}
Local aCampos		:= {}
Local lTC870BRW		:= EXISTBLOCK("TC870BRW") // Ponto de entrada para inclusão de colunas no browse
Local aUSRCpos		:= {}
Local cUSRqry		:= ""
Local nX 			:= 0
Local nAux			:= 0
Local aTables		:= {}

If lOrcSimp
	aCampos 	:= {"TFJ_CONTRT","TFJ_CONREV","TFJ_CODIGO","AD1_NROPOR", "TFJ_PROPOS", "TFJ_PREVIS", "A1_CGC", "A1_NOME",;
					 "AD1_DESCRI","ADY_ENTIDA", "ADY_CODIGO", "ADY_LOJA",   "AD1_DTINI", "AD1_DTFIM", "CN9_DTFIM", "TFJ_DATA","CN9_DTINI"}
Else
    aCampos 	:= {"AD1_NROPOR", "TFJ_PROPOS", "TFJ_PREVIS", "TFJ_CONTRT",  "A1_CGC", "A1_NOME",   "AD1_DESCRI",;
    				"TFJ_CONREV", "ADY_ENTIDA", "ADY_CODIGO", "ADY_LOJA",   "AD1_DTINI", "AD1_DTFIM", "CN9_DTFIM", "TFJ_CODIGO","CN9_DTINI"}
EndIf

If TecVerRePl()
	AADD( aCampos, "TFJ_DTPLRV")
EndIf
// Array aTables é utilizado para validar se a coluna, inserida pelo P.E TC870BRW é válida
aTables := AT870tbl(aCampos)
aAdd(aTables, "SA1")
aAdd(aTables, "AAH")

If lTC870BRW
	nAux := len(aCampos)
	aUSRCpos := ACLONE(EXECBLOCK("TC870BRW", .F., .F. ))
	If Len(aUSRCpos) > 0
		for nX := 1 to Len(aUSRCpos)
			If aScan(aCampos, {|x| x == aUSRCpos[nX] }) == 0 .AND. AT870VLCP(aUSRCpos[nX], aTables)
			    IF Substring(aUSRCpos[nX],1,2) = "A1"
                    cUSRqry += ' CASE WHEN  '+'SA1'+"."+aUSRCpos[nX]+'  IS NOT NULL THEN  '+'SA1'+"."+aUSRCpos[nX]+" ELSE '' END "+aUSRCpos[nX]+','
                Else
				    cUSRqry += ' CASE WHEN  '+Substring(aUSRCpos[nX],1,3)+"."+aUSRCpos[nX]+' IS NOT NULL THEN '+Substring(aUSRCpos[nX],1,3)+"."+aUSRCpos[nX]+" ELSE '' END "+aUSRCpos[nX]+','
				Endif	
				AADD(aCampos, aUSRCpos[nX])
			EndIf
		Next nX
		cUSRqry := LEFT(cUSRqry, Len(cUSRqry)-1)
   	Endif
EndIf

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For nI:=1 To Len(aCampos)

	If SX3->(dbSeek(aCampos[nI]))

		cCampo := AllTrim(SX3->X3_CAMPO)

		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType(SX3->X3_TIPO)
	   	aColumns[nLinha]:SetTitle(X3Titulo())
		aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
		aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
		aColumns[nLinha]:SetPicture(SX3->X3_PICTURE)
		If SX3->X3_TIPO == "D"
			aColumns[nLinha]:SetData(&("{|| sTod(" + cCampo + ")}"))
		ElseIf cCampo == "ADY_ENTIDA"
			aColumns[nLinha]:SetData( &("{|| X3Combo('ADY_ENTIDA',MNTPRO->ADY_ENTIDA)}") )
		Else
			aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))
		EndIf

		aAdd(aFiltros,{SX3->X3_CAMPO,X3Titulo(),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})
	EndIf

Next nI

SX3->(dbCloseArea())

RestArea(aArea)

Return({aColumns, aFiltros,cUSRqry})

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870PRev
@author rogerio.souza
@since 17/10/2013
@version 11.9
@param cCodTfj, character, Código da referencia da proposta.
@param cCont, character, Código do Contrato.
@param cRevis, character, Revisão do contrato.
@description
Apresenta tela para preenchimento de informações para realização de revisão do gestão de serviços integrada ao Gestão de Contratos
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870PRev(cCodTfj, cCont, cRevis, lSemTela, cCodCN0, lRevAssist, nPercAuto, nDiasAuto, bSemTela, cNewTFJ )

Local oDlg			:= Nil	//Dialog
Local aSize			:= FWGetDialogSize( oMainWnd )	// Array com tamanho da janela.
Local cCodTR		:= CriaVar("CN0_CODIGO", .F.)	//Space(TamSx3("CN0_CODIGO")[2])
Local cDescTR		:= CriaVar("CN0_DESCRI", .F.)
Local aArea			:= GetArea()
Local aAreaTFJ		:= TFJ->(GetArea())
Local lParamRealM	:= SuperGetMv("MV_CNREALM",,"N") == "S"
Local lWhenCN0		:= .T.
Local lATVREVI		:= SuperGetMv("MV_ATVREVI",,.F.)
Local lOrcPrc		:= SuperGetMV("MV_ORCPRC",,.F.)
Local lGSRH      	:= GSGetIns("RH")
Local lRet 			:= .T.
Local nRadio		:= 1
Local lHasRev		:= At580BSit(cCont) == '2'
Local cChave		:= ""
Local cTFJStatus	:= POSICIONE("TFJ",1,xFilial("TFJ")+cCodTfj,"TFJ_STATUS")
Local lTFJStatus	:= cTFJStatus == '1' .OR. cTFJStatus == '2' .OR. cTFJStatus == '8'
Private nPerc		:= 0
Private nPrazo		:= 0
Private oPerc		:= Nil
Private oPrazo		:= Nil
Default lSemTela := .F.
Default cCodCN0 := ""
Default lRevAssist := .F.
Default nPercAuto := 0
Default nDiasAuto := 0
Default bSemTela := {||.T.}
Default cNewTFJ := ""

cChave	:=	xFilial("CN9")+cCont+cRevis+cTFJStatus
If LockByName("TEC870"+cChave,.T.,.T.)

	If lTFJStatus
		If lParamRealM
			lRet := .F.
			If lSemTela
				AutoGrLog( "GSMMVREALM" + " / " + STR0066 )	// "Para realizar revisões de contrato no Gestão de Serviços é necessário desabilitar o parâmetro MV_CNREALM"
			Else
				Help( ' ', 1, "GSMMVREALM", , STR0066, 1, 0 )  // "Para realizar revisões de contrato no Gestão de Serviços é necessário desabilitar o parâmetro MV_CNREALM"
			EndIf
		Else
			DbSelectArea("CN9")
			DbSetOrder(1)
			If CN9->(DbSeek(xFilial("CN9")+cCont+cRevis))
				If !(CN9->CN9_SITUAC == DEF_SELAB .Or. CN9->CN9_SITUAC == DEF_SAPRO) .AND. (!lHasRev .OR. cTFJStatus == '2')	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
					// Verfica se o parametro MV_ATVREVI obriga verificação de itens separados
					If lATVREVI
						lRet := At870Sep(cCodTFJ, lSemTela)
					Endif

					If lRet .And. At870VldTFJ(cCodTFJ, lSemTela)

						//Recupera tipo de contrato do orçamento de serviços em revisão.
						TFJ->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO
						If lSemTela .And. !Empty(cCodCN0)
							If At870VldCN0(cCodCN0, @cDescTR, lSemTela)
								cCodTR := cCodCN0
							Else
								lRet := .F.
								AutoGrLog( "At870RevAuto" + " / " + STR0204 ) // "Parâmetros incompletos para a revisão automática. Envie o Tipo de Revisão e se usar assistente, envie também o percentual ou dias."
							EndIf
						ElseIf TFJ->(DbSeek(xFilial("TFJ")+cCodTfj)) .AND. TFJ->TFJ_STATUS == DEF_TFJ_EMREVISAO
							cCodTR := Posicione("TFJ", 1, xFilial("TFJ")+cCodTfj, "TFJ_TIPREV")
							cDescTR := If(!Empty(cCodTR), Posicione("CN0", 1, xFilial("CN0")+cCodTR, "CN0_DESCRI"), CriaVar("CN0_DESCRI", .F.))
							lWhenCN0 := .F.
						EndIf

						If lSemTela
							If !Empty(cCodTR) .And. ( !lRevAssist .Or. ( lRevAssist .And. ( nPercAuto > 0 .Or. nDiasAuto > 0 ) ) )
								lRet := At870Revis(cCodTfj, cCodTr, lRevAssist, nPercAuto, nDiasAuto, lSemTela, bSemTela, @cNewTFJ )
							Else
								lRet := .F.
								AutoGrLog( "At870RevAuto" + " / " + STR0204 ) // "Parâmetros incompletos para a revisão automática. Envie o Tipo de Revisão e se usar assistente, envie também o percentual ou dias."
							EndIf
						Else
							If !((!Empty(TFJ->TFJ_CODTAB) .And. !lOrcPrc) .Or. (Empty(TFJ->TFJ_CODTAB) .And. lOrcPrc .And. lGSRH))

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Assistente de Revisão						                    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DEFINE DIALOG oDlg TITLE STR0001 FROM  100,115 TO 400,520 PIXEL // "Manutenção de Proposta"
								oDlg:bInit :={|| EnchoiceBar(oDlg, {||( If( lRet := At870LoadRv(cCodTfj,cCodTr,nRadio <> 1,nPerc,nPrazo, cCont),oDlg:End(),Nil) )} , {||( oDlg:End() )} ,, {}) }

									oGrpTp := TGroup():New(035,005,057,200,"",oDlg,,,.T.)
									@ 043,008 Say STR0010 of oGrpTp PIXEL//"Código"
									@ 040,030 MsGet cCodTR Picture PesqPict("CN0","CN0_CODIGO") F3 "CN0" Valid At870VldCN0(cCodTR, @cDescTR) When lWhenCN0 of oGrpTp PIXEL
									@ 040,073 MsGet cDescTR Picture PesqPict("CN0","CN0_DESCRI") Size 120,0 When .F. of oGrpTp PIXEL

									// Modo de Revisão
									oGrpModo := TGroup():New(062,005,090,200,STR0154,oDlg,,,.T.) // "Modo de Revisão"

									If !Empty(TFJ->TFJ_CODTAB)
										oRadModo := TRadMenu():New(70,10,{STR0155,STR0156},,oDlg,,,,,,,{||!Empty(cCodTR)},170,80,,,,.T.) // 'Edição livre' ### 'Com assistente'
									Else
										oRadModo := TRadMenu():New(70,10,{STR0155,STR0213},,oDlg,,,,,,,{||!Empty(cCodTR)},170,80,,,,.T.) // 'Edição livre' ### '"Automático"'
									EndIf

									oRadModo:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
									oRadModo:bChange := {|| RefreshGet(oRadModo:nOption == 2,cCodTR) }

									// Parametros
									oGrpAss := TGroup():New(095,005,140,200,STR0157,oDlg,,,.T.) // "Parâmetros do Assistente"
									@ 107,010 Say STR0158 of oGrpAss PIXEL // "Percentual"
									@ 105,040 MsGet oPerc VAR nPerc PICTURE '@E 9999.9999' VALID Positivo(nPerc) Size 30,0 of oGrpAss PIXEL
									oPerc:bWhen := {|| .F.}
									@ 108,087 Say "%" of oGrpAss PIXEL//""

									If TFJ->TFJ_CNTREC <> '1'
										@ 122,010 Say STR0159 of oGrpAss PIXEL // "Prazo"
										@ 120,040 MsGet oPrazo VAR nPrazo PICTURE '@E 999'  Size 25,0 VALID Positivo(nPrazo) of oGrpAss PIXEL
										oPrazo:bWhen := {|| .F.}
										@ 122,070 Say STR0160 of oGrpAss PIXEL // "Dias"
									EndIf
								ACTIVATE DIALOG oDlg CENTERED
							Else
								If (Empty(TFJ->TFJ_CODTAB) .And. lOrcPrc)
									Help(,,"AT870VTPC",, STR0161,1,0)  // "Orçamento gerado sem tabela de precificação, desabilite o parametro MV_ORCPRC, para abrir o orçamento desta proposta!"
								EndIf
								If (!Empty(TFJ->TFJ_CODTAB) .And. !lOrcPrc)
									Help(" ",1,"AT870PRECF",,STR0242 ; //"Orçamento gerado com tabela de precificação, habilite o parametro MV_ORCPRC, para abrir o orçamento desta proposta!"
															,4,0)
								EndIf

							EndIf
						EndIf
					EndIf
				Else
					If lHasRev
						Help( ' ', 1, "At870PRev", , STR0243 , 1, 0 ) //"Não é possível realizar revisões em contrato com processo de revisão pendente de aprovação."
					Else
						Help( ' ', 1, "At870PRev", , STR0033, 1, 0 )	//"Não é possivel realizar revisões em contratos ainda em elaboração, para realizar alteração no contrato acesse o modulo SIGAGCT e realize as alterações!"
					EndIf
				EndIF
			EndIf
		Endif
	Else
		Help( ' ', 1, "At870PRev", , STR0253, 1, 0 ) //"Não é possivel revisar contrato já revisado ou cancelado. Por favor selecione um contrato com status ativo."
	EndIf
Else
	Help(NIL, NIL, "At870PRev", NIL, STR0244 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0245}) //"O registro está em processo de edição por outro usuáro."#"Aguarde e tente novamente."
EndIf

RestArea(aAreaTFJ)
RestArea(aArea)

UnLockByName("TEC870"+cChave,.T.,.T.)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RefreshGet
@author Cesar Bianchi
@since 11/18/2016
@version 12.1.15
@return lRet
@description
Refresh dos GETs de Percentual e Dias
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function RefreshGet(lEnable,cCodTR)
	Default lEnable := .F.
	Default cCodTR	:= ""

	If ValType(oPerc) == "O"
		//So habilita os gets o codigo do tipo de Revisao nao for vazio
		If !(Empty(cCodTR))
			//Habilita os Gets de acordo com a opcao escolhida
			oPerc:bWhen := {|| lEnable}

			If !lEnable
				nPerc := 0
			EndIf

		Else
			oPerc:bWhen := {|| .F.}

			If !lEnable
				nPerc := 0
			EndIf
		EndIf

		//Refresh dos componetes de GET

		oPerc:Refresh()
		oPerc:SetFocus()
		oPerc:CtrlRefresh()
	EndIf

	If Valtype(oPrazo) == "O"
		//So habilita os gets o codigo do tipo de Revisao nao for vazio
		If !(Empty(cCodTR))
			//Habilita os Gets de acordo com a opcao escolhida
			oPrazo:bWhen := {|| lEnable}

			If !lEnable
				nPrazo := 0
			EndIf

		Else
			oPrazo:bWhen := {|| .F.}

			If !lEnable
				nPrazo := 0
			EndIf
		EndIf

		//Refresh dos componetes de GET
		oPrazo:Refresh()
		oPrazo:SetFocus()
		oPrazo:CtrlRefresh()
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870LoadRv
@author Cesar Bianchi
@since 11/18/2016
@version 12.1.15
@param cCodTfj, character, Codigo do orçamento de serviços (TFJ)
@param cCodTr, character, Codigo do tipo de revisão
@return lRet
@description
Realiza a chamada para a funcao principal de Revisao do GS, apresentando uma dialog de Processamento.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870LoadRv(cCodTfj,cCodTr,lRevAuto,nPerc,nDias, cContrato)
Local lRet := .F.

Processa({ || lRet := At870Revis(cCodTfj,cCodTr,lRevAuto,nPerc,nDias, , , , cContrato) } )

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Revis
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTfj, character, Codigo do orçamento de serviços (TFJ)
@param cCodTr, character, Codigo do tipo de revisão
@return lRet
@description
Realiza processo para geração de revisão do orçamento de serviços
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870Revis(cCodTfj,cCodTr,lRevAuto,nPerc,nDias, lSemTela, bSemTela, cNewTFJ, cContrato )
Local lRet 		:= .T.
Local oOrcServico	:= Nil
Local oMdlRev 	:= Nil
Local oModel	 	:= Nil
Local lConfirm 	:= .F.
Local lOk	 		:= .T.
Local cRevisao 	:= ""
Local cTpRev		:= ""
Local nI	 		:= 1
Local nY	 		:= 1
Local nZ	 		:= 1
Local lOrcPrc		:= SuperGetMv("MV_ORCPRC",,.F.)
Local cOrcMod		:= If( lOrcPrc, "TECA740F", "TECA740" )
Local lGSRH      := GSGetIns("RH")
Local aTabPrc 	:= ''
Local cTabela 	:= ''
Local cTabRev		:= ''
Local lExeOrc 	:= !lOrcPrc
Local lRetQry	:= AtQryVal(cCodTFJ)

Local lConPrc

// Variaveis Vinculo de Beneficios
Local nX		 := 0
Local nW		 := 0
Local lTecxRh	 := SuperGetMV("MV_TECXRH",,.F.)	// Define se o Gestao de Servico esta integrado com Rh do Microsiga Protheus.
Local cAliasSLY	 := ''
Local cQuerySLY	 := ''
Local aTFFCOD	 := {}
Local aRevisao	 := {}
Local lOkSly	 := AliasInDic('SLY')
Local cAtuProp 	 := ""
Local cValUser 	 := ""
Local bLocalVld  := Nil
Local oMdlAssist := Nil
Local lTFFXML	 := TFF->( ColumnPos('TFF_TABXML') ) > 0
Local cXMLOrig	 := ""
Local oMTFF		 := Nil
Local oMLoc		 := Nil
Local nR		 := 1
Local nS		 := 1
Local aXMLOri	 := {}
Local aAreaTFJ	 := TFJ->(GetArea())
Local aAreaTFF	 := TFF->(GetArea())
Local nRecTFJ	 := 0

Default lRevAuto := .F.
Default lSemTela := .F.
Default bSemTela := {|| .T. }
Default cNewTFJ 	:= ""
Default cContrato 	:= ""

If 	!At870VldInfo(cCodTr)//valida informações
	lOk := .F.
EndIf

TFJ->( DbSetOrder( 1 ) ) //TFJ_FILIAL + TFJ_CODIGO
If lOK .AND. !TFJ->( DbSeek( xFilial('TFJ')+cCodTFJ ) )
	lOk := .F.
	If lSemTela
		AutoGrLog( "At870Revis" + " / " + STR0018 )	//"Orçamento de Serviços não encontrado"
	Else
		Help( ' ', 1, "At870Revis", , STR0018, 1, 0 )	//"Orçamento de Serviços não encontrado"
	EndIf
EndIf

If lOk
	Begin Transaction
		If lRevAuto .AND. lRetQry .AND. !isBlind()
			If !MsgYesNo( STR0301,STR0302 )
				MsgAlert( STR0303,STR0301 )
				lOK := .F.
			Endif
		EndIf
		If lOK
			If lGSRH .and. lOrcprc
				At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV )
			EndIf
			aTabPrc 	:= At600GetTab()
			cTabela 	:= If( aTabPrc[1] <> Nil, aTabPrc[1], "" )
			cTabRev	:= If( aTabPrc[2] <> Nil, aTabPrc[2], "" )

			// Atualiza a variavel da revisao
			Aadd(aRevisao,{.T.,At870TpCont(cCodTr)})
			At870SetRe(aRevisao)

			// Atualiza as informações para o novo modelo de precificação
			// Informando o codigo da tabela e sua revisão
			If lOrcPrc
				If Empty(cTabela) .And. Empty(cTabRev)  .AND. lGSRH
					lConPrc := Conpad1( NIL, NIL, NIL, "TV6" )
					If lConPrc
						At600STabPrc( TV6->TV6_NUMERO, TV6->TV6_REVISA )
					EndIf
				EndIf
				aTabPrc := At600GetTab()
				cTabela := If( aTabPrc[1] <> Nil, aTabPrc[1], "" )
				cTabRev := If( aTabPrc[2] <> Nil, aTabPrc[2], "" )
				lExeOrc := (!Empty(cTabela) .Or. !Empty(cTabRev) .or. Empty(cTabela ))  // Verifica tabela e revisao para execução
				If !lExeOrc
					If lSemTela
						AutoGrLog( "TABPRCINVLD" + " / " + STR0078 )	//"Orçamento de Serviços não encontrado"
					Else
						Help(,,"TABPRCINVLD",, STR0078,1,0) // "Tabela de precificação invalida! Não sera possivel carregar o orçamento de serviços."
					EndIf
				EndIf
			EndIf

			At740FMsg( .F. )
			If (TFJ->TFJ_STATUS == DEF_TFJ_EMREVISAO)//Atualiza Orçamento de serviços que está em revisão
				oMdlRev 		:= FwLoadModel(cOrcMod)
				oMdlRev:SetOperation( MODEL_OPERATION_UPDATE )

				lRet := oMdlRev:Activate()
				If lRet
					cRevisao := oMdlRev:GetValue('TFJ_REFER', 'TFJ_PREVIS')
				EndIf

			Else // Cria Revisão
				TFJ->( DbSeek( xFilial('TFJ')+cCodTFJ ) )
				cRevisao := TFJ->TFJ_PREVIS

				//Cria copia do Model da TFJ
				If lRet
					oMdlRev := FwLoadModel(cOrcMod)
					If IsIncallStack("AplicaRevi")
						oMdlRev:SetOperation(MODEL_OPERATION_UPDATE)
						lRet := oMdlRev:Activate()
					Else
						oMdlRev:SetOperation(MODEL_OPERATION_INSERT)
						lRet := oMdlRev:Activate(.T.)
					EndIf 

					If lRet
						If !Empty(oMdlRev:GetErrorMessage()[MODEL_MSGERR_MESSAGE])//6
							Ft600ErroMvc( oMdlRev )
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Aplica os percentuais de reajuste
			If lRet .And. Empty(cTabela) .And. lRevAuto
				lRet := At870RAuto(oMdlRev,nPerc,nDias)
			Else
				If lRet .And. lRevAuto
					oMdlAssist := FwLoadModel("TECA870B")
					oMdlAssist:SetOperation(MODEL_OPERATION_UPDATE)
					// atribui o percentual padrão
					At870bSet( 1, nPerc )
					// atribui a qtde de dias a prorrogar padrão
					At870bSet( 2, nDias )
					// ativa o modelo para que os dados sejam carregados corretamente utilizando os valores padrões inseridos pelo usuário
					lRet := oMdlAssist:Activate()
					// exibe a janela para o assistente de percentual para revisão quando a rotina não é automática
					If lRet .And. !lSemTela
						lRet := ( FWExecView( STR0205, "VIEWDEF.TECA870B", MODEL_OPERATION_UPDATE, /*oDlg*/,; // "Assistente Revisão"
													{||.T.}/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/,/*aEnableButtons*/,;
													/*bCancel*/, /*cOpratId*/, /*cTooBar*/, oMdlAssist /*oModelAct*/ ) == 0 )
						If !lRet
							oMdlRev:SetErrorMessage(oMdlRev:GetId(),oMdlRev:GetId(),oMdlRev:GetId(), oMdlRev:GetId(),"",;
									STR0206, STR0207 ) // "Assistente de percentual cancelado." ### "Faça novamente o processo de revisão."
						EndIf
					EndIf

					// remonta o modelo de dados considerando as informações recebidas via xml
					If lRet
						// verifica se o objeto está ativo, quando não está recarrega as informações via xml
						If !oMdlAssist:IsActive()
							oMdlAssist := FwLoadModel("TECA870B")
							lRet := oMdlAssist:LoadXmlData(At870bGet( 3 )) .And. !oMdlAssist:HasErrorMessage()
						EndIf
						// avalia se aconteceu algum erro para exibir ou registrar para o usuário
						If !lRet
							AtErroMvc( oMdlAssist:GetModel() )
							If !lSemTela
								MostraErro()
							EndIf
						EndIf
					EndIf
					lRet := lRet .And. At870RReaj(oMdlRev,lOrcPrc, oMdlAssist)
				EndIf
			EndIf
			If lRet
				If IsIncallStack("AplicaRevi")
					oMdlRev:LoadValue("TFJ_REFER","TFJ_CONTRT",cContrato)
				EndIf	
				oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_PREVIS', cRevisao )//Atualiza revisão da proposta
				oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_STATUS', DEF_TFJ_EMREVISAO )//Coloca orçamento serviço em revisão
				oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_TIPREV', cCodTr) //Orçamento fica com o tipo de revisão
				oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_CONDPG', CN9->CN9_CONDPG ) //Atualiza a Condição de Pagamento do orçamento
				cNewTFJ := oMdlRev:GetValue('TFJ_REFER', 'TFJ_CODIGO')
				If !EMPTY(oMdlRev:GetValue("TFL_LOC", "TFL_LOCAL"))
					oMdlRev:LoadValue( 'TFL_LOC' , 'TFL_CODSUB', "" )//Atualiza CODSUB
					If IsIncallStack("AplicaRevi")
						oMdlRev:LoadValue( 'TFL_LOC' , 'TFL_CONTRT', "" )
						oMdlRev:LoadValue( 'TFL_LOC' , 'TFL_CONREV', "" )
					EndIf
				EndIf
				If !EMPTY(oMdlRev:GetValue("TFF_RH", "TFF_PRODUT"))
					oMdlRev:LoadValue( 'TFF_RH'  , 'TFF_CODSUB', "" )//Atualiza CODSUB
					If IsIncallStack("AplicaRevi")
						oMdlRev:LoadValue( 'TFF_RH' , 'TFF_CONTRT', "" )
						oMdlRev:LoadValue( 'TFF_RH' , 'TFF_CONREV', "" )
					EndIf
				EndIf
				If !EMPTY(oMdlRev:GetValue("TFG_MI", "TFG_PRODUT"))
					oMdlRev:LoadValue( 'TFG_MI'  , 'TFG_CODSUB', "" )//Atualiza CODSUB
					If IsIncallStack("AplicaRevi")
						oMdlRev:LoadValue( 'TFG_MI' , 'TFG_CONTRT', "" )
						oMdlRev:LoadValue( 'TFG_MI' , 'TFG_CONREV', "" )
					EndIf
				EndIf
				If !EMPTY(oMdlRev:GetValue("TFH_MC", "TFH_PRODUT"))
					oMdlRev:LoadValue( 'TFH_MC'  , 'TFH_CODSUB', "" )//Atualiza CODSUB
					If IsIncallStack("AplicaRevi")
						oMdlRev:LoadValue( 'TFH_MC' , 'TFH_CONTRT', "" )
						oMdlRev:LoadValue( 'TFH_MC' , 'TFH_CONREV', "" )
					EndIf
				EndIf
				If !EMPTY(oMdlRev:GetValue("TFI_LE", "TFI_PRODUT"))
					oMdlRev:LoadValue( 'TFI_LE'  , 'TFI_CODSUB', "" )//Atualiza CODSUB
				EndIf
				
				cTpRev := At870TpCont(cCodTr)

				// bloqueia a alteração do local/posto ABS
				oMdlRev:GetModel("TFL_LOC"):GetStruct():SetProperty("TFL_LOCAL", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFL_CONTRT"))})
				// monta a validação para o campo TFL_LOCAL
				cAtuProp := RTrim( GetSX3Cache("TFL_LOCAL","X3_VALID") ) //+ " .And. At870Nwl('TFL_LOC')" -- permitir incluir novas CNCs
				If !Empty( Alltrim(cValUser := GetSX3Cache("TFL_LOCAL","X3_VLDUSER") ) )
					cAtuProp += " .And. " + cValUser
				EndIf
				bLocalVld := FwBuildFeature( STRUCT_FEATURE_VALID, cAtuProp )
				oMdlRev:GetModel("TFL_LOC"):GetStruct():SetProperty("TFL_LOCAL", MODEL_FIELD_VALID, bLocalVld )

				// bloqueia a alteração do produtos nos itens
				oMdlRev:GetModel("TFF_RH" ):GetStruct():SetProperty("TFF_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFF_CONTRT"))})
				oMdlRev:GetModel("TFG_MI" ):GetStruct():SetProperty("TFG_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFG_CONTRT"))})
				oMdlRev:GetModel("TFH_MC" ):GetStruct():SetProperty("TFH_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFH_CONTRT"))})
				oMdlRev:GetModel("TFI_LE" ):GetStruct():SetProperty("TFI_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFI_CONTRT"))})
				oMdlRev:GetModel("TFI_LE" ):GetStruct():SetProperty("TFI_QTDVEN", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFI_CONTRT"))})

				At740SLoad( oMdlRev ) // atribui o model com o conteúdo copiado para carga na view da rotina
				
			Else
				If oMdlRev:HasErrorMessage()
					ViewErroMvc( oMdlRev, !lSemTela /*lExibeErro*/ )
				EndIf
			EndIf

			At740FMsg( .T. ) //Habilita as mensagens de erro
			At740SCmt( .T. )//habilita commit

			If lRet .And. lExeOrc
				If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
					If (oMdlRev:GetOperation() == MODEL_OPERATION_INSERT)
						TEC740iTFJ(cCodTFJ,oMdlRev:GetValue("TFJ_REFER","TFJ_CODIGO"))
					ElseIf oMdlRev:GetOperation() == MODEL_OPERATION_UPDATE .AND. isInCallStack("AplicaRevi")
						TEC740iTFJ(/*cCodTFJ*/,;
							oMdlRev:GetValue("TFJ_REFER","TFJ_CODIGO"),;
							oMdlRev:GetValue("TFJ_REFER","TFJ_CONTRT"),;
							oMdlRev:GetValue("TFJ_REFER","TFJ_CONREV"))
					EndIf
				EndIf
				AT870SETVT('1', .T.) // indica que o orçamento de serviços estará aberto na tela
				At870RestLins( oMdlRev, lOrcPrc )
				If lSemTela
					lRet := EVal( bSemTela, oMdlRev, oMdlAssist)
					If FindFunction("_870BTestC") .AND. _870BTestC()
						at870DClck(,"BTNCALC",.T.,oMdlAssist)
						at870DClck(,"TFF_STATUS", .T.)
					EndIf
					lRet := lRet .And. oMdlRev:VldData() .And. At870VRes(oMdlRev,cCodTfj) .And. At740Cmt(@oMdlRev)
					If !lRet
						ViewErroMvc( oMdlRev, !lSemTela /*lExibeErro*/ )
					EndIf
				Else
					If FindFunction("At352LimpA") .AND. !IsIncallStack("AplicaRevi")
						At352LimpA() 
					EndIf
					If IsIncallStack("AplicaRevi")
						lRet := ( FWExecView(STR0017,"VIEWDEF."+cOrcMod, MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // 'Orçamento Serviços'
												{||At870VRes(oMdlRev,cCodTfj,cContrato,cRevisao)}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )	//apresenta copia do model na interface
					Else
						lRet := ( FWExecView(STR0017,"VIEWDEF."+cOrcMod, MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // 'Orçamento Serviços'
												{||At870VRes(oMdlRev,cCodTfj)}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )	//apresenta copia do model na interface
					EndIf
					If FindFunction("At352LimpA") .AND. !IsIncallStack("AplicaRevi")
						At352LimpA()
					EndIf
				EndIf
				AT870SETVT('1', .F.) // indica que o orçamento de serviços não está mais aberto na tela
			Else
				lRet := .F.
			EndIf

			At740FMsg( .F. )

			At740SLoad( Nil )
			If lRet
				//Realiza commit do Model com dados de substituiçao anterior a revisão
				If !Empty(TFJ->TFJ_GRPCOM)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SIGATEC WorkFlow # CT - Interações de Contratos Revisão ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					At774Mail("TFJ",TFJ->TFJ_GRPCOM,"CT","<b>"+STR0106+"</b> "+TFJ->TFJ_PROPOS+"<b> "+STR0107+"</b>"+TFJ->TFJ_CONTRT,,STR0108) //"Num. Proposta: " # "Nr. Contrato: " # "Revisão"
				Endif

				If !(SuperGetMv("MV_GSAPROV",,"2") == "1" .And.;
				 	TFJ->(ColumnPos('TFJ_APRVOP')) > 0 .And. TFJ->TFJ_APRVOP == "2") .And.;
					!lSemTela .And. MsgYesNo(STR0039) //"Deseja efetivar a revisão do Orçamento de Serviços?"
					//efetiva revisão
					MsgRun ( STR0029, STR0004, {|| lRet := At870EftRv(cNewTFJ,cCodTr,cTpRev ) } ) // 'Processando revisão...' ### "Aguarde..."
					If !lRet .And. MsgYesNo(STR0217,STR0216 ) // 'Houveram inconsistências na efetivação da revisão do contrato, deseja desfazer as alterações feitas no orçamento?' 'Revisão de contrato'
						DisarmTransaction()
						break
					EndIf
				EndIf
			EndIf
		EndIf
	End Transaction
EndIf

At870SetRe({}) // Limpa o Array da Revisao

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870EftRv
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTfj, character, Codigo do orçamento de serviços (TFJ)
@param cCodTr, character, Codigo do tipo de revisão
@return lRet
@description
Efetiva a geração da revisão do orçamento de serviço, gerando uma revisão para o contrato correspondente
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870EftRv(cCodTfj,cCodTr,cTpRev,lSemTela, bSemTela, cCTRPla, cRevPla)

Local cContrato	:= ""
Local cRevisa		:= ""
Local nY			:= 0
Local nZ			:= 0
Local oModel		:= Nil
Local oMdl			:= Nil
Local oMdlRev		:= Nil
Local lRet			:= .F.
Local nRec			:= 0
Local nDifDay		:= 0
Local aInfo		:= {}
Local nTotLocal 	:= 0
Local nK			:= 1
Local nX			:= 0
Local oOldModel 	:= NIL
Local lOrcPrc		:= SuperGetMv("MV_ORCPRC",,.F.)
Local cOrcMod		:= If( lOrcPrc, "TECA740F", "TECA740" )
Local lGSRH         := GSGetIns("RH")
Local dDtFimCtr 	:= CTOD('')
Local oMdlTFJ 		:= Nil
Local oMdlTFL 		:= Nil
Local oMdlTFF 		:= Nil
Local oMdlTFG 		:= Nil
Local oMdlTFH 		:= Nil
Local oMdlTFI 		:= Nil
Local oMdlTEV 		:= Nil
Local oMdlCN9 		:= Nil
Local oMdlCNA 		:= Nil
Local oMdlCNB 		:= Nil
Local lAgrup 		:= .T.
Local nTotRHold 	:= 0
Local nTotRHnew 	:= 0
Local nTotMIold 	:= 0
Local nTotMInew 	:= 0
Local nTotMCold 	:= 0
Local nTotMCnew 	:= 0
Local nTotLEold 	:= 0
Local nTotLEnew 	:= 0
Local nTotalOld 	:= 0
Local nTotalNew 	:= 0
Local cPedTit 		:= ""
Local lBlqRevi 		:= SuperGetMv("MV_BLQREVI",,.F.)
Local cCodCli 		:= ""
Local cLojCli 		:= ""
Local cNumPlan 		:= ""
Local lAtuDtPLan 	:= .T.
Local cRev 			:= ""
Local nTotalMed 	:= 0
Local lMedicaoMaior := .F.
Local cLocCCusto 	:= ""
Local nTotLocal 	:= 0
Local cPeriodo		:= ""
Local nQuantRec		:= 0
Local nPerioRec		:= 0
Local cRecPagAnt	:= ""
Local oStruCN9      := Nil

Private lRevisad	:= .F.
Private nRevRtp		:= 0 //Tipo de Alteracao: 1-Prosseguir,2-Reiniciar,3-Excluir

Default lSemTela 	:= .F.
Default bSemTela := {|| .T. }
Default cCTRPla	:= ""
Default cRevPla	:= ""

INCLUI := .T.
AT870GetTr( .F. )
TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))
	If TFJ->TFJ_STATUS == DEF_TFJ_EMREVISAO .OR. TFJ->TFJ_STATUS == DEF_TFJ_REVPLANEJ
		At740FMsg( .F. ) // Desabilita as mensagens de erro dos campos
		nRec := TFJ->(Recno())
		If lOrcPrc .And. lGSRH
			At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV )
		EndIf
		oModel := FWLoadModel(cOrcMod)
		oModel:SetOperation( MODEL_OPERATION_UPDATE)

		cContrato 	:= TFJ->TFJ_CONTRT
		cRevisa 	:= TFJ->TFJ_CONREV

		A300STpRev(cTpRev)

		//Posicionar no Contrato
		DbSelectArea("CN9")
		DbSetOrder(1) // CN9_FILIAL + CN9_NUMERO + CN9_REVISA
		If CN9->(DbSeek(xFilial("CN9")+cContrato+cRevisa))

			TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
			TFJ->(DbGoTo(nRec))

			If !(SuperGetMv("MV_GSAPROV",,"2") == "1" .And.;
				 	TFJ->(ColumnPos('TFJ_APRVOP')) > 0 .And. TFJ->TFJ_APRVOP == "2")

				oMdlRev := FwLoadModel('CNTA301')
				oMdlRev:SetOperation( OP_INCLUIR ) //Operação como copia para trazer os dados
				lRet := oMdlRev:Activate(.T. /*lCopia*/) // irá copiar os dados dos registros posicionados na CN9 mesmo sendo operação incluir

				If lRet

					oOldModel := FWModelActive()

					lRet := TecActivt(@oModel)

					If lRet

						//--------------------------------------------
						// modelos Orçamento de Serviços
						oMdlTFJ := oModel:GetModel("TFJ_REFER")
						oMdlTFL := oModel:GetModel("TFL_LOC")
						oMdlTFF := oModel:GetModel("TFF_RH")
						oMdlTFG := oModel:GetModel("TFG_MI")
						oMdlTFH := oModel:GetModel("TFH_MC")
						oMdlTFI := oModel:GetModel("TFI_LE")
						oMdlTEV := oModel:GetModel("TEV_ADICIO")

						//--------------------------------------------
						// modelos Contrato GCT
						oMdlCN9 := oMdlRev:GetModel("CN9MASTER")
						oMdlCNA := oMdlRev:GetModel("CNADETAIL")
						oMdlCNB := oMdlRev:GetModel("CNBDETAIL")
						oMdlCNC := oMdlRev:GetModel("CNCDETAIL")

						// identifica como o contrato foi gerado (agrupado ou não)
						lAgrup := ( oMdlTFJ:GetValue("TFJ_DSGCN") <> "1" )

						FWModelActive(oMdlRev)  //define model GCT como ativo
						oMdlCN9:GetStruct():SetProperty("CN9_TIPREV", MODEL_FIELD_WHEN, {||.T.})

						// atribui o tipo de revisão do contrato e condição de pagamento
						lRet := lRet .And. oMdlCN9:SetValue("CN9_TIPREV", cCodTr)
						If oMdlCN9:GetValue("CN9_CONDPG") != oMdlTFJ:GetValue("TFJ_CONDPG")
							oMdlCN9:SetValue("CN9_CONDPG", oMdlTFJ:GetValue("TFJ_CONDPG"))
						EndIf

						// captura a data máxima atual do contrato
						dDtFimCtr := oMdlRev:GetValue('CN9MASTER', 'CN9_DTFIM')

						//---------------------------------------------------------------------------
						// executa o primeiro loop nos locais para verificar se precisa trocar o prazo de execução do contrato


						For nY := 1 To oMdlTFL:Length()
							oMdlTFL:GoLine(nY)
							If oMdlTFL:GetValue( "TFL_ENCE" )  <> '1'
								If !oMdlTFL:IsDeleted() .And. dDtFimCtr < oMdlTFL:GetValue( "TFL_DTFIM")
									dDtFimCtr := oMdlTFL:GetValue("TFL_DTFIM")
								EndIf
							EndIf
						Next nY

						// avalia se a data final do contrato sofreu alguma alteração
						If oMdlCN9:GetValue('CN9_DTFIM') <> dDtFimCtr

							nDifday := DateDiffDay(oMdlCN9:GetValue('CN9_DTFIM'),dDtFimCtr)

							lRet := lRet .And. oMdlCN9:SetValue('CN9_VIGE',  oMdlCN9:GetValue('CN9_VIGE') + nDifDay)
						EndIf

						//----------------------------------------------------------------------------
						// executa uma segunda passagem por todos os locais para alterar as informações das planilhas e seus itens
						For nY := 1 To oMdlTFL:Length()
							oMdlTFL:GoLine(nY)

							// captura a configuração de geração de pedido ou nf
							cPedTit := If( oMdlTFL:GetValue("TFL_PEDTIT") == "2", "2", "1" )
							cLocCCusto := At160GetCC( oMdlTFL:GetValue("TFL_LOCAL") )
							nTotLocal := oMdlTFL:GetValue( "TFL_TOTRH" ) + oMdlTFL:GetValue( "TFL_TOTMI" ) + oMdlTFL:GetValue( "TFL_TOTMC" ) + oMdlTFL:GetValue( "TFL_TOTLE" )
							// pula os locais que não estejam com valor para o contrato
							If nTotLocal > 0
								// posicionar planilha conforme o local em Edição
								If !Empty( oMdlTFL:GetValue("TFL_PLAN") )

									// já existe no contrato
									FwModelActive(oMdlCNA:GetModel())
									If oMdlCNA:SeekLine( {{"CNA_NUMERO", oMdlTFL:GetValue("TFL_PLAN") }} )
										//   atualiza a data final sempre pois se a data no cabeçalho for alterada irá replicar o fim a todas
										// as planilhas
										If lAtuDtPLan
											lRet := lRet .And. oMdlCNA:SetValue("CNA_DTFIM", oMdlTFL:GetValue("TFL_DTFIM"))

										// caso a data da planilha tenha sido alterada mas ainda esteja dentro do período total do contrato
										ElseIf oMdlTFL:GetValue("TFL_DTFIM") > oMdlCNA:GetValue("CNA_DTFIM")
											lRet := lRet .And. oMdlCNA:SetValue("CNA_DTFIM", oMdlTFL:GetValue("TFL_DTFIM"))
										EndIf

										If !lRet // já sai da rotina em caso de erro na atualização das datas
											Exit
										EndIf

										// captura os valores totais de rh, materiais e locação, desconsiderando as cobranças fora do contrato
										At870ValOld( At870LocAnt( oMdlTFL:GetValue("TFL_CODIGO"), cCodTfj ), @nTotRHold, @nTotMIold, @nTotMCold, @nTotLEold )

										// captura os valores totais de rh, materiais e locação, desconsiderando as cobranças fora do contrato
										At870ValNew( oModel, nY, @nTotRHnew, @nTotMInew, @nTotMCnew, @nTotLEnew )

										nTotalOld := nTotRHold + nTotMIold + nTotMCold + nTotLEold
										nTotalNew := nTotRHnew + nTotMInew + nTotMCnew + nTotLEnew
										nTotalMed := oMdlCNA:GetValue("CNA_VLTOT") - oMdlCNA:GetValue("CNA_SALDO")

										// avalia se o novo valor do item é menor que o valor já medido no contrato
										lMedicaoMaior := ( nTotalOld > nTotalNew .And. nTotalNew < nTotalMed )
										lBlqRevi := lBlqRevi .And. ( nTotalOld > nTotalNew )

										If lBlqRevi
											lRet := .F.
											Help( "", 1, "At870REVBLOQ", , STR0162, 1, 0,,,,,,; // "Parâmetro MV_BLQREVI está ativo e não pode acontecer medição para valor menor."
														{STR0163})  // "Altere novamente o orçamento de serviços e insira um valor maior que o anterior para o local."
											Exit

										// verifica se o novo valor é maior que o valor já medido na planilha
										ElseIf lMedicaoMaior

											lRet := .F.
											Help( "", 1, "At870MEDPLAN", , STR0164, 1, 0,,,,,,;  // "Valor já medido na planilha é superior ao novo valor para ela."
														{STR0165})  // "Altere novamente o orçamento de serviços e insira um valor maior que o já medido."
											Exit
										Else
											// usa agrupadores??
											If lAgrup

												lRet := lRet .And. At870ItAgr( oMdlTFJ, oMdlTFL, oMdlCNB, cPedTit,;
																				nTotRHold, nTotRHnew, nTotMIold, nTotMInew,;
																				nTotMCold, nTotMCnew, nTotLEold, nTotLEnew,;
																				oMdlCNA:GetValue("CNA_NUMERO"), cLocCCusto )
												If !lRet
													Exit
												EndIf

											Else

												lRet := lRet .And. At870ItDsAgr( oModel, oMdlCNB, cContrato, .T./*lOldValues*/,;
																				cPedTit, oMdlCNA:GetValue("CNA_NUMERO"), cLocCCusto )
												If !lRet
													Exit
												EndIf
											EndIf

										EndIf
									Else
										lRet := .F.
										Help( ' ', 1, 'At870NOPLAN', , STR0166, 1, 0)  // "Planilha não encontrada no contrato."
										Exit
									EndIf
								Else
									// planilha ainda não existe no contrato, será adicionada

									// adicionar nova linha na planilha
									nK := oMdlCNA:Length()
									oMdlCNA:GoLine( nK )

									cTipPlan := oMdlCNA:GetValue("CNA_TIPPLA")
									cNumPlan :=  Soma1( oMdlCNA:GetValue("CNA_NUMERO") )
									cRecPagAnt	:= oMdlCNA:GetValue("CNA_RPGANT")
									cPeriodo	:= oMdlCNA:GetValue("CNA_PERIOD")
									nPerioRec	:= oMdlCNA:GetValue("CNA_PERREC")
									nQuantRec	:= oMdlCNA:GetValue("CNA_QTDREC")

									FwModelActive( oMdlCNA:GetModel() )

									If oMdlCNA:AddLine() <> nK + 1
										lRet := .F.
										Help( "", 1, "At870NONEWPLA1", , STR0167, 1, 0,,,,,,;  // "Problemas ao adicionar nova planilha."
															{STR0168})  // "Verifique se a revisão do contrato deveria permitir adicionar."
										If oMdlCNA:GetModel():HasErrorMessage()
											AtErroMvc( oMdlCNA:GetModel() )
											If !lSemTela
												MostraErro()
											EndIf
										EndIf
										Exit
									Else
										If At850GetCli( @cCodCli, @cLojCli, oMdlTFL:GetValue("TFL_LOCAL"),;
														Posicione("TFJ", 1, xFilial("TFJ")+oMdlTFL:GetValue("TFL_CODPAI"), "TFJ_AGRUP" ) )

											TECPrepCNC(oMdlCNC,cCodCli,cLojCli)

											lRet := lRet .And. oMdlCNA:LoadValue("CNA_NUMERO", cNumPlan )
											lRet := lRet .And. oMdlCNA:SetValue("CNA_CLIENT", cCodCli )
											lRet := lRet .And. oMdlCNA:SetValue("CNA_LOJACL", cLojCli )
											lRet := lRet .And. oMdlCNA:SetValue("CNA_TIPPLA", cTipPlan )
											lRet := lRet .And. oMdlCNA:SetValue("CNA_DTINI"	, oMdlTFL:GetValue("TFL_DTINI") )
											lRet := lRet .And. oMdlCNA:SetValue("CNA_DTFIM"	, oMdlTFL:GetValue("TFL_DTFIM") )

											If !Empty(cPeriodo) .And. nPerioRec > 0 .And. nQuantRec > 0
												lRet := lRet .And. oMdlCNA:SetValue("CNA_RPGANT", cRecPagAnt )
												lRet := lRet .And. oMdlCNA:SetValue("CNA_PERIOD", cPeriodo )
												lRet := lRet .And. oMdlCNA:SetValue("CNA_PERREC", nPerioRec )
												lRet := lRet .And. oMdlCNA:SetValue("CNA_QTDREC", nQuantRec )
											Endif
										Else
											lRet := .F.
											Help( "", 1, "At870CLILOC", , STR0169, 1, 0,,,,,,;  // "Problemas identificar o cliente no local de atendimento."
																{STR0170})  // "Verifique a configuração de qual cliente utilizar no orçamento de serviços e o preenchimento no local de atendimento."
											Exit
										EndIf
									EndIf

									// usa agrupadores?
									If lRet .And. lAgrup

										// captura os valores totais de rh, materiais e locação, desconsiderando as cobranças fora do contrato
										At870ValNew( oModel, nY, @nTotRHnew, @nTotMInew, @nTotMCnew, @nTotLEnew )
										nTotRHold := 0
										nTotMIold := 0
										nTotMCold := 0
										nTotLEold := 0

										// chama função para incluir os itens com o formato de agrupadores
										lRet := lRet .And. At870ItAgr( oMdlTFJ, oMdlTFL, oMdlCNB, cPedTit,;
																		nTotRHold, nTotRHnew, nTotMIold, nTotMInew,;
																		nTotMCold, nTotMCnew, nTotLEold, nTotLEnew,;
																		cNumPlan, cLocCCusto )
										If !lRet
											Exit
										EndIf

									ElseIf lRet
										// chama função para incluir os itens com o formato sem agrupadores
										lRet := lRet .And. At870ItDsAgr( oModel, oMdlCNB, cContrato, .F./*lOldValues*/, cPedTit,;
																		cNumPlan, cLocCCusto )
										If !lRet
											Exit
										EndIf
									EndIf

									// valida se a linha da CNA está ok para depois prosseguir com o processo de revisão
									FwModelActive( oMdlCNA:GetModel() )
									lRet := lRet .And. oMdlCNA:VldLineData()

									// adiciona 1 ao número da planilha anterior
									lRet := lRet .And. oMdlTFL:SetValue("TFL_PLAN", cNumPlan )

									If !lRet
										Help( "", 1, "At870NONEWPLA2", , STR0171, 1, 0,,,,,,;  // "Problemas ao adicionar nova planilha."
														{STR0172})  // "Verifique se a revisão do contrato deveria permitir adicionar."
										If oMdlCNA:GetModel():HasErrorMessage()
											AtErroMvc( oMdlCNA:GetModel() )
											If !lSemTela
												MostraErro()
											EndIf
										EndIf
										If oMdlTFL:GetModel():HasErrorMessage()
											AtErroMvc( oMdlTFL:GetModel() )
											If lSemTela
												MostraErro()
											EndIf
										EndIf
										Exit
									EndIf

								EndIf
							EndIf
						Next nY

						//Verifica se foi realizado a exclusão da local (TFL) para realizar a exclusão na planilha (CNA).
						If lRet
							For nY := 1 To oMdlCNA:Length()
								oMdlCNA:Goline(nY)

								If !oMdlCNA:IsDeleted() .And. At870DlCNA(oMdlCNA:GetValue("CNA_CONTRA"),;
																		oMdlCNA:GetValue("CNA_REVISA"),;
																		oMdlCNA:GetValue("CNA_NUMERO"),;
																		cCodTFJ)
									TecDelPln(.T.)
									lRet := lRet .And. oMdlCNA:DeleteLine()
									TecDelPln(.F.)
									If !lRet
										Exit
									Endif
								Endif
							Next nY
						Endif

						If lRet
							oOldModel := FWModelActive()
							FWModelActive(oMdlRev)  //seta model GCT como ativo

							oMdlRev:nOperation := 3 //Foi alterado operação para que a manipulação no oMldRev seja incluido em uma nova revisão

							oMdlRev:GetModel("CNADETAIL"):GoLine(1)
							oMdlRev:GetModel("CNBDETAIL"):GoLine(1)

							If lSemTela
								lRet := lRet .And. Eval( bSemTela, oMdlRev )
								lRet := lRet .And. oMdlRev:VldData() .And. oMdlRev:CommitData()
								If !lRet
									AtErroMvc( oMdlTFL:GetModel() )
								EndIf
							Else
								// bloqueia as alterações nas planilhas, itens e pool de clientes
								oMdlRev:GetModel("CNADETAIL"):SetNoDeleteLine(.T.)
								oMdlRev:GetModel("CNADETAIL"):SetNoInsertLine(.T.)
								oMdlRev:GetModel("CNBDETAIL"):SetNoDeleteLine(.T.)
								oMdlRev:GetModel("CNBDETAIL"):SetNoInsertLine(.T.)
								oMdlRev:GetModel("CNCDETAIL"):SetNoDeleteLine(.T.)
								oMdlRev:GetModel("CNCDETAIL"):SetNoInsertLine(.F.)
								oMdlCN9:GetStruct():SetProperty("CN9_FLGREJ", MODEL_FIELD_WHEN, {||.T.})
								oMdlCN9:GetStruct():SetProperty("CN9_INDICE", MODEL_FIELD_WHEN, {||CN300WReCt()})
								oMdlCNA:GetStruct():SetProperty("CNA_FLREAJ", MODEL_FIELD_WHEN, {||.T.})
								oMdlCNA:GetStruct():SetProperty("CNA_PRORAT", MODEL_FIELD_WHEN, {||.T.})
					
								ALTERA	:= .F.
								AT870GetTr( .T. )
								If !isBlind()
									lRet := (FWExecView(STR0006,"CNTA301",OP_COPIA,,{|| .T.},,,,,,,oMdlRev) == 0 ) //"Revisão do Contrato"
								Else
									If FindFunction("AT870TRevs")
										lRet := AT870TRevs(@oMdlRev)
									Else
										lRet := .F.
									EndIf
								EndIf
								ALTERA := nil
							EndIf
							FWModelActive(oOldModel)//REstaura ModelActive
						Else
							// caso tenha acontecido erro, cancela os dados do modelo do orçamento de serviços
							If oModel:HasErrorMessage()
								AtErroMvc( oModel )
								If !lSemTela
									MostraErro()
								EndIf
							EndIf
							oModel:CancelData()

							// cancela os dados do modelo do contrato e desativa
							If oMdlRev:HasErrorMessage()
								AtErroMvc( oMdlRev )
								If !lSemTela
									MostraErro()
								EndIf
							EndIf
							oMdlRev:CancelData()
							oMdlRev:DeActivate()
						EndIf

						If lRet

							cRev := Soma1(cRevisa)

							oOldModel := FWModelActive()
							FWModelActive(oModel)  //seta model SIGATEC como ativo
							oModel:SetValue("TFJ_REFER","TFJ_CONREV",cRev)
							oModel:SetValue("TFJ_REFER","TFJ_STATUS",DEF_TFJ_AGDAPROVA)
							FWModelActive(oOldModel)  //REstaura ModelActive
							
							If isInCallStack("AplicaRevi") .OR. AT870CtRev( oModel:GetValue("TFJ_REFER","TFJ_CODIGO") )
								oMdlTFL := oModel:GetModel("TFL_LOC")
								oMdlTFF := oModel:GetModel("TFF_RH")
								oMdlTFG := oModel:GetModel("TFG_MI")
								oMdlTFH := oModel:GetModel("TFH_MC")
								oModel:LoadValue("TFJ_REFER","TFJ_CONTRT",cContrato)
								oModel:LoadValue("TFJ_REFER","TFJ_CODREL","")
								oModel:LoadValue("TFJ_REFER","TFJ_DTPLRV",SToD(""))
								For nX := 1 To oMdlTFL:Length()
									oMdlTFL:Goline(nX)
									If !oMdlTFL:IsDeleted()
										oMdlTFL:LoadValue("TFL_CONTRT", cContrato)
										oMdlTFL:LoadValue("TFL_CONREV",cRev)
										oMdlTFL:LoadValue("TFL_CODREL","")
										oMdlTFL:LoadValue("TFL_MODPLA","1")
										For nY := 1 To oMdlTFF:Length()
											oMdlTFF:Goline(nY)
											If !oMdlTFF:IsDeleted() .AND. !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
												oMdlTFF:LoadValue("TFF_CONTRT", cContrato)
												oMdlTFF:LoadValue("TFF_CONREV",cRev)
												oMdlTFF:LoadValue("TFF_CODREL","")
												oMdlTFF:LoadValue("TFF_MODPLA","1")
												For nZ := 1 To oMdlTFG:Length()
													oMdlTFG:Goline(nZ)
													If !oMdlTFG:IsDeleted() .AND. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
														oMdlTFG:LoadValue("TFG_CONTRT", cContrato)
														oMdlTFG:LoadValue("TFG_CONREV",cRev)
														oMdlTFG:LoadValue("TFG_CODREL","")
														oMdlTFG:LoadValue("TFG_MODPLA","1")
													EndIf
												Next nZ
												For nZ := 1 To oMdlTFH:Length()
													oMdlTFH:Goline(nZ)
													If !oMdlTFH:IsDeleted() .AND. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
														oMdlTFH:LoadValue("TFH_CONTRT", cContrato)
														oMdlTFH:LoadValue("TFH_CONREV",cRev)
														oMdlTFH:LoadValue("TFH_CODREL","")
														oMdlTFH:LoadValue("TFH_MODPLA","1")
													EndIf
												Next nZ
											EndIf
										Next nY
									EndIf
								Next nX
							EndIf
							// alterar para realizar somente a atualização dos campos de saldo nas tabelas TFG, TFH e TEV
							At870DelIn(oModel)
							lRet := lRet .AND. At870AtuOr(oModel,cContrato,cRev)

							At740SCmt( .T. )
							// Se o dados foram validados faz-se a gravação dos dados (commit)
							If ( lRet := lRet .AND. ( oModel:VldData() .And. oModel:CommitData() ) )
								If isInCallStack("AplicaRevi")
									//atualizar SLY - conforme encerramento do posto
									At352Sly(oModel)
								EndIf
							Else
								aErro := oModel:GetErrorMessage()

								AutoGrLog( STR0047 + ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem:"
								AutoGrLog( STR0048 + ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
								AutoGrLog( STR0049 + ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro: "
								AutoGrLog( STR0050 + ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
								AutoGrLog( STR0051 + ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
								AutoGrLog( STR0052 + ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
								AutoGrLog( STR0053 + ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução: "
								AutoGrLog( STR0054 + ' [' + AllToChar( aErro[8] ) + ']' )	//"Valor atribuído: "
								AutoGrLog( STR0055 + ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "

								If !lSemTela
									MostraErro()
								EndIf
							EndIf

						EndIf

						oModel:DeActivate()
					EndIf

				Else
					aErro := oMdlRev:GetErrorMessage()

					AutoGrLog( STR0047 + ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem:"
					AutoGrLog( STR0048 + ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
					AutoGrLog( STR0049 + ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro: "
					AutoGrLog( STR0050 + ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
					AutoGrLog( STR0051 + ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
					AutoGrLog( STR0052 + ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
					AutoGrLog( STR0053 + ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução: "
					AutoGrLog( STR0054 + ' [' + AllToChar( aErro[8] ) + ']' )	//"Valor atribuído: "
					AutoGrLog( STR0055 + ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "

					If !lSemTela
						MostraErro()
					EndIf
				EndIf
			Else
				Help( ' ', 1, 'At870EftRv', , "Orçamento de serviço pendente de aprovação operacional.", 1, 0 )	// "Orçamento de serviço pendente de aprovação operacional."
			Endif
		Else
			Help( ' ', 1, 'At870EftRv', , STR0064, 1, 0 )	// "Contrato não localizado"
		EndIf

	Else
		Help( ' ', 1, 'At870EftRv', , STR0022, 1, 0 )	//"Efetivação de revisão permitida somente para orçamento de serviços com status 'Em Revisão'."
	EndIf

Else
	Help( ' ', 1, 'At870EftRv', , STR0018, 1, 0 )	//"Orçamento de Serviços não encontrado"
EndIf

If lRet .AND. !Empty(TFJ->TFJ_GRPCOM)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SIGATEC WorkFlow # CT - Interações de Contratos Efetivação ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	At774Mail("TFJ",TFJ->TFJ_GRPCOM,"CT","<b>"+STR0106+"</b> "+TFJ->TFJ_PROPOS+"<b> "+STR0107+"</b>"+TFJ->TFJ_CONTRT,,STR0109) //"Num. Proposta: " # "Nr. Contrato: " # "Efetivação"
Endif
At740SCmt( .F. )
AT870GetTr( .F. )
If IsInCallStack("ExecutaRev")
	oOldModel:DeActivate()
	oModel:DeActivate()
	oMdlRev:DeActivate()
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Aprov
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cContra, character Numero do contrato
@param cRevisa, character Revisão do contrato aprovado
@description
Realiza processo de aprovação da revisão do contrato, realizando atualizações de referencias e revisões no Gestão de Serviços
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870Aprov(cContra, cRevisa, lSemTela)
Local cAliasQry	:= GetNextAlias()
Local cStatus		:= DEF_TFJ_AGDAPROVA//Status aguardando aprovação
Local cCodTFJ		:= ""
Local cFilTFJ		:= ""
Local cOldRevis	:= ""//Revisão anterior
Local aItens		:= {}
Local cCodTfjAnt	:= ""
Local cCodRevPla	:= ""
Local aArea		:= GetArea()
Local aAreaTFJ	:= TFJ->(GetArea())
Local aAreaTFI	:= TFI->(GetArea())
Local aAreaTFL	:= TFL->(GetArea())
Local aAreaTFF	:= TFF->(GetArea())
Local cGrpCom	:= ""
Local cNumProp	:= ""
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lGSLE 		:= GSGetIns('LE')
Local lRevisaPla	:= SuperGetMv("MV_GSDSGCN",,"2") == "1" .AND. !lGSLE .AND. !lOrcPrc
Local cGesMat   :=  ""
Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6") //Parâmetro de integração entre o SIGAMDT x SIGATEC 	//Parâmetro de integração entre o SIGAMDT x SIGATEC

Default lSemTela := .F.

//Recupera TFJ com status em revisão referente ao contrato que está sendo aprovado
BeginSQL Alias cAliasQry
	SELECT  TFJ_FILIAL, TFJ_CODIGO, TFJ_CONREV, TFJ_GRPCOM, TFJ_PROPOS
	FROM %Table:TFJ% TFJ
WHERE
	TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
	TFJ.TFJ_CONTRT = %Exp:cContra% AND
	TFJ.TFJ_STATUS = %Exp:cStatus% AND
	TFJ.%notDel%
EndSql

If  (cAliasQry)->(!EOF())
	cFilTFJ := (cAliasQry)->TFJ_FILIAL
	cCodTFJ := (cAliasQry)->TFJ_CODIGO
	cOldRevis := (cAliasQry)->TFJ_CONREV
	cGrpCom	  := (cAliasQry)->TFJ_GRPCOM
	cNumProp  := (cAliasQry)->TFJ_PROPOS
EndIf

(cAliasQry)->(DbCloseArea())


BEGIN TRANSACTION

	//Atualiza status da TFJ para revisado.
	TFJ->(DbSetOrder(5))//TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	TFJ->(DbSeek(cFilTFJ+cContra /*+cOldRevis*/ ))
	While TFJ->(!EOF()) .AND. TFJ->TFJ_CONTRT == cContra
		If TFJ->TFJ_STATUS != DEF_TFJ_AGDAPROVA

			//Armazena condigo anterior da TFJ
			If TFJ->TFJ_STATUS == DEF_TFJ_ATIVO  
				cCodTfjAnt := TFJ->TFJ_CODIGO
				TFJ->(RecLock("TFJ", .F.))
				TFJ->TFJ_STATUS := DEF_TFJ_REVISADO
				TFJ->(MsUnlock())
			EndIf
		EndIf
		TFJ->(DbSkip())
	EndDo

	//Atualiza status e revisão do orçamento que será considerado como ativo
	TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
	If TFJ->(DbSeek(cFilTFJ+cCodTFJ))
		TFJ->(RecLock("TFJ", .F.))
		TFJ->TFJ_CONREV := cRevisa
		TFJ->TFJ_STATUS := DEF_TFJ_ATIVO
		cGesMat         := TFJ->TFJ_GESMAT
		If AT870CtRev( TFJ->TFJ_CODIGO )
			TFJ->TFJ_CODREL := ""
			TFJ->TFJ_DTPLRV := SToD("")
		EndIf 
		TFJ->(MsUnlock())
	EndIf

	//Atualiza informações da TFL e TFI
	TFL->(DbSetOrder(2))//TFL_FILIAL+TFJ_CODPAI
	TFI->(DbSetOrder(3))//TFI_FILIAL+TFI_CODPAI
	TFF->(DbSetOrder(3))//TFF_FILIAL+TFF_CODPAI
	TFL->(DbSeek(xFilial("TFL")+cCodTFJ))
	While TFL->(!EOF()) .AND. TFL->TFL_FILIAL == cFilTFJ .AND. TFL->TFL_CODPAI == cCodTFJ

		//Recupera itens das planilhas que foram criados devido ao realinhamento
		aItens := atuItPL(cContra, cOldRevis, cRevisa, TFL->TFL_PLAN, {TFL->TFL_ITPLRH, TFL->TFL_ITPLMI, TFL->TFL_ITPLMC, TFL->TFL_ITPLLE })

		TFL->(RecLock("TFL", .F.))
		TFL->TFL_CONTRT := cContra
		TFL->TFL_CONREV := cRevisa
		TFL->TFL_ITPLRH := aItens[1]
		TFL->TFL_ITPLMI := aItens[2]
		TFL->TFL_ITPLMC := aItens[3]
		TFL->TFL_ITPLLE := aItens[4]
		TFL->(MsUnlock())

		//Atualiza TFF
		If TFF->(DbSeek(xFilial("TFF")+TFL->TFL_CODIGO))
			While ( TFF->(!EOF()) .AND. TFF->TFF_FILIAL == xFilial("TFF") .AND. TFF->TFF_CODPAI == TFL->TFL_CODIGO)
				TFF->(RecLock("TFF"), .F.)
				TFF->TFF_CONTRT := cContra
				TFF->TFF_CONREV := cRevisa
				TFF->(MsUnlock())

				If !lOrcPrc
					At870MtCtr(lOrcPrc, cContra, cRevisa)
				EndIf

				TFF->(DbSkip())
			EndDo
		EndIf

		If lOrcPrc
			At870MtCtr(lOrcPrc, cContra, cRevisa)
		EndIf

		//Atualiza TFI
		If TFI->(DbSeek(xFilial("TFI")+TFL->TFL_CODIGO))

			While ( TFI->(!EOF()) .AND. TFI->TFI_FILIAL == xFilial("TFI") .AND. TFI->TFI_CODPAI == TFL->TFL_CODIGO)
				TFI->(RecLock("TFI"), .F.)
				If Empty(TFI->TFI_CONTRT)
					TFI->TFI_SEPARA := "2"
				EndIf
				TFI->TFI_CONTRT := cContra
				TFI->TFI_CONREV := cRevisa
				TFI->(MsUnlock())
				TFI->(DbSkip())
			EndDo

		EndIf

		TFL->(DbSkip())
	EndDo
	
	AtuApont(cCodTfjAnt,cGesMat) // Atualiza a referência dos apontamentos de materiais de implantação e consumo

	CopyABQ(cCodTFJ)//realiza cópia dos dados de configuração de alocação para a revisão atual.

	CopyTWZ(cCodTfjAnt,cCodTFJ) //realiza cópia dos dados de Registro de Custo para a revisão atual.

	If At870AtAlo(cCodTfjAnt, cContra)//Atualiza agenda do tecnico para nova configuração de alocação

		AtuLocEqui(cCodTFJAnt, cCodTFJ, lSemTela)//Atualiza referencias da locação de equipamentos

		At870AtGES(cCodTFJAnt, cCodTFJ)  // atualiza informação da gestão de escalas

		At870OsMont( cCodTFJAnt, cCodTFJ )

		If FindFunction("At581UpRot")
			At581UpRot(cCodTFJAnt)
		EndIf

		If FindFunction("At850CrTar") .And. lMdtGS //Integração entre o SIGAMDT x SIGATEC
			dBSelectArea("TFF")
			If TFF->( ColumnPos("TFF_RISCO")) > 0 
				At850CrTar(cContra,cRevisa)
			Endif
		Endif

		If lRevisaPla .AND. TecVerRePl()
			If !AT870RevPl( cCodTFJAnt, @cCodRevPla )
				If !isBlind()
					FwMsgRun(Nil,{|| UpdMantPl(cCodTFJAnt, cCodTFJ, cCodRevPla)}, Nil, STR0327) //"Realizando alterações na Revisão Planejada"
					FwMsgRun(Nil,{|| DelMantPl(cCodTFJAnt, cCodTFJ, cCodRevPla)}, Nil, STR0327) //"Realizando alterações na Revisão Planejada"
				Else
					UpdMantPl(cCodTFJAnt, cCodTFJ, cCodRevPla)
					DelMantPl(cCodTFJAnt, cCodTFJ, cCodRevPla)
				EndIf
			Else
				If !isBlind()
					FwMsgRun(Nil,{|| AtuModPla(cCodTFJ)}, Nil, STR0327) //"Realizando alterações na Revisão Planejada"
				Else
					AtuModPla(cCodTFJ)
				EndIf
			EndIf
		EndIf
		
		If !Empty(cGrpCom)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SIGATEC WorkFlow # CT - Interações de Contratos Aprovação Revisão ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			At774Mail("TFJ",TFJ->TFJ_GRPCOM,"CT","<b>"+STR0106+"</b> "+cNumProp+"<b> "+STR0107+"</b>"+cContra,,STR0110) //"Num. Proposta: " # "Nr. Contrato: " # "Aprovação da Revisão"
		Endif
	Else
		DisarmTransaction()
	EndIf
END TRANSACTION

RestArea(aAreaTFJ)
RestArea(aAreaTFI)
RestArea(aAreaTFL)
RestArea(aAreaTFF)
RestArea(aArea)

Return

/*/{Protheus.doc} At870MtCtr
@description 	Atualiza os dados de contrato e revisão nos materias conforme o orçamento sendo utilizado (com precificação ou não)
@author 		josimar.assuncao
@since 			23/11/2016
/*/
Static Function At870MtCtr(lOrcPrc, cContra, cRevisa)

Local cSuperior := If( lOrcPrc, TFL->TFL_CODIGO, TFF->TFF_COD )
Local cFilTFG 	:= xFilial("TFG")
Local cFilTFH 	:= xFilial("TFH")

TFG->(DbSetOrder(3))  //TFG_FILIAL+TFG_CODPAI
TFH->(DbSetOrder(3))  //TFH_FILIAL+TFH_CODPAI

If TFG->( DbSeek( xFilial("TFG")+cSuperior ) )

	While TFG->(!EOF()) .And. TFG->TFG_FILIAL == cFilTFG .And. TFG->TFG_CODPAI == cSuperior

		TFG->(RecLock("TFG"), .F.)
		TFG->TFG_CONTRT := cContra
		TFG->TFG_CONREV := cRevisa
		TFG->(MsUnlock())

		TFG->(DbSkip())
	End
EndIf

If TFH->( DbSeek( xFilial("TFH")+cSuperior ) )

	While TFH->(!EOF()) .And. TFH->TFH_FILIAL == cFilTFG .And. TFH->TFH_CODPAI == cSuperior

		TFH->(RecLock("TFH"), .F.)
		TFH->TFH_CONTRT := cContra
		TFH->TFH_CONREV := cRevisa
		TFH->(MsUnlock())

		TFH->(DbSkip())
	End
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuLocEqui
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTFJ, character, Codigo do orçamento de serviços
@param cCodTFJNew, character, Codigo do orçamento de serviços da revisão anterior
@description
Atualiza referencias da locação de equipamentos.
Atualização das referencias entre TFI e TEW (TEW_ORCSER, TEW_CODEQU) para considerar os novos itens.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtuLocEqui(cCodTFJ, cCodTFJNew, lSemTela)
Local cAliasQry	:= GetNextAlias()
Local cMsgErr		:= ""
Local lRet			:= .T.
Local aArea		:= GetArea()
Local aAreaTEW	:= TEW->(GetArea())
Local aAreaTFJ	:= TFJ->(GetArea())

Default lSemTela := .F.

//Atualiza movimentações
BeginSQL Alias cAliasQry
	SELECT  TEW.TEW_FILIAL, TEW.TEW_CODMV, TFI.TFI_CODSUB
		FROM %Table:TEW% TEW

		INNER JOIN %Table:TFI% TFI ON
			TEW.TEW_FILIAL = TFI.TFI_FILIAL AND
			TEW.TEW_CODEQU = TFI.TFI_COD AND
			TFI.%notDel%

		INNER JOIN %Table:TFL% TFL ON
			TFI.TFI_FILIAL = TFI.TFI_FILIAL AND
			TFI.TFI_CODPAI = TFL.TFL_CODIGO AND
			TFL.TFL_CODPAI = %Exp:cCodTFJ% AND
			TFL.%notDel%
	WHERE
		TEW.TEW_FILIAL = %xFilial:TEW% AND
		TFL.TFL_CODPAI = %Exp:cCodTFJ% AND
		TEW.%notDel%
EndSql

DbSelectArea("TEW")
TEW->(DbSetOrder(1))// TEW_FILIAL+TEW_CODMV
While (cAliasQry)->(!EOF())
	If TEW->(DbSeek((cAliasQry)->TEW_FILIAL+(cAliasQry)->TEW_CODMV))
		TEW->(RecLock("TEW", .F.))
		TEW->TEW_CODEQU := (cAliasQry)->TFI_CODSUB
		TEW->TEW_ORCSER := cCodTFJNew
		MsUnlock()
	EndIf

	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

//Gera movimentação da locação de atendimento
DbSelectArea('TFJ')
TFJ->( DbSetOrder( 1 ) ) //TFJ_FILIAL+TFJ_CODIGO
If TFJ->( DbSeek( xFilial('TFJ')+cCodTFJNew ) )
	If lSemTela
		lRet := At800Start( @cMsgErr, TFJ->TFJ_CODIGO )
	Else
		MsgRun ( STR0028, STR0004, {|| lRet := At800Start( @cMsgErr, TFJ->TFJ_CODIGO ) } ) // 'Gerando movimentos para locação de equipamentos' ### "Aguarde..."
	EndIf
EndIf

If !lRet
	Help(,,'AT870LOCEQUIP',, cMsgErr,1,0)
EndIf

RestArea(aAreaTFJ)
RestArea(aAreaTEW)
RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} copyABQ
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTFJ, character, Codigo do orçamento de serviços)
@description
Gera registros de configuração de alocação para a nova revisão do orçamento de serviços
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function copyABQ(cCodTFJ)

Local cAliasQry	:= GetNextAlias()
Local aItemRh		:= {}
Local aArea		:= GetArea()
Local aAreaTFF	:= TFF->(GetArea())
Local oDlg		:= nil
Local oSayMtr	:= nil
Local nMeter	:= 0
Local nTotal	:= 0
Local nTotLoc := 0
Local nCntLoc := 0
Local cAlias2 := GetNextAlias()
Local aTFFOrg := {}

//Recupera locais de atendimento
BeginSQL Alias cAliasQry
	SELECT  TFL_CONTRT, TFL_LOCAL, TFL_CODIGO, TFJ_CNTREC
	FROM %Table:TFL% TFL
	INNER JOIN %table:TFJ% TFJ ON ( TFJ.TFJ_FILIAL = %xFilial:TFJ% AND TFJ.TFJ_CODIGO =  %Exp:cCodTFJ% AND TFJ.%notDel% )
WHERE
	TFL.TFL_FILIAL = %xFilial:TFL% AND
	TFL.TFL_CODPAI = %Exp:cCodTFJ% AND
	TFL.%notDel%
EndSql

TFF->(DbSetOrder(3))//TFF_FILIAL+TFF_CODPAI

If !IsBlind()
	(cAliasQry)->(DbEval({|| nTotLoc := nTotLoc + 1}))
	(cAliasQry)->(DbGoTop())
EndIf

While (cAliasQry)->(!EOF())

	aItemRH := {}
	TFF->(DbSeek(xFilial("TFF")+(cAliasQry)->TFL_CODIGO))
	While TFF->(!EOF()) .AND. TFF->TFF_FILIAL == xFilial("TFF") .AND. TFF->TFF_CODPAI ==  (cAliasQry)->TFL_CODIGO

		//Se não for CTT Recorrente, consulta os dados do contrato anterior para verificar se recalcula o saldo
		If (cAliasQry)->TFJ_CNTREC <> "1"
			BeginSQL Alias cAlias2
				COLUMN TFF_PERINI AS DATE
				COLUMN TFF_PERFIM AS DATE
				SELECT  
					TFF_FILIAL, TFF_COD, TFF_CALEND, TFF_TURNO, TFF_SEQTRN, TFF_ESCALA, TFF_PERINI, TFF_PERFIM, TFF_QTDVEN
				FROM %Table:TFF% TFF
				WHERE
					TFF.TFF_FILIAL = %xFilial:TFF% AND
					TFF.TFF_CODSUB = %Exp:TFF->TFF_COD% AND
					TFF.%notDel%
			EndSql
			
			If (cAlias2)->(!Eof())	 				
				aTFFOrg := { (cAlias2)->TFF_FILIAL, ; //1
								(cAlias2)->TFF_COD,  ; //2
								(cAlias2)->TFF_CALEND,; //3
								(cAlias2)->TFF_TURNO,; //4
								(cAlias2)->TFF_ESCALA, ;//5
								IIF(EMPTY((cAlias2)->TFF_SEQTRN), "01", (cAlias2)->TFF_SEQTRN), ;//6
								(cAlias2)->TFF_PERINI, ; //7
								(cAlias2)->TFF_PERFIM, ;//8
								(cAlias2)->TFF_QTDVEN,; //9
								(cAlias2)->TFF_CALEND ,; //10
								TFF->TFF_CALEND ,;//11
								TFF->TFF_ESCALA  }  //12 - Envia a escala para calcular baseado no turno + escala (legado)
				
			EndIf
			(cAlias2)->(DbCloseArea())
			//Branco - calcula integral
		EndIf
	
		Aadd(aItemRH,{;
					TFF->TFF_PRODUT	,; //1
					TFF->TFF_CARGO	,; //2
					TFF->TFF_FUNCAO	,; //3
					TFF->TFF_PERINI	,; //4
					TFF->TFF_PERFIM	,; //5
					TFF->TFF_TURNO	,;//6
					TFF->TFF_QTDVEN	,; //7
					TFF->TFF_COD		,; //8
					TFF->TFF_SEQTRN,; //9
					.T.,; //10
					TFF->TFF_FILIAL ,; //11
					aClone(aTFFOrg),; //12
					IIF(TecABBPRHR(), TecConvHr(TFF->TFF_QTDHRS), 0),; //13
					""}) //14 
		aTFFOrg := {}
		TFF->(DbSkip())
		
	EndDo
	If isBlind()
		At850CnfAlc((cAliasQry)->TFL_CONTRT,(cAliasQry)->TFL_LOCAL,aItemRH,,,.F.,(cAliasQry)->TFJ_CNTREC == "1")//Gera ABQ
	Else
		oDlg := nil
		oSayMtr := nil
		nMeter := 0
		nTotal := LEN(aItemRH)
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0258 + " ( " + cValToChar(++nCntLoc) + " / " + cValToChar(nTotLoc) + " )" //"Atualizando configuração de alocação..."
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.,/*uParam10*/,/*uParam11*/,.T.)
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (At850CnfAlc((cAliasQry)->TFL_CONTRT,(cAliasQry)->TFL_LOCAL,aItemRH,@oDlg,@oMeter,.F.,(cAliasQry)->TFJ_CNTREC == "1"))
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aAreaTFF)
RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870AtAlo
@sample        At870AtAlo(cTFJOrig)
@param         cTFJOrig, character, Codigo do orçamento de serviços PAI (TFJ)
@return        NIL
@author        rogerio.souza
@version       11.9
@description
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870AtAlo(cTFJOrig, cContra)

Local cAliasABQ	:= GetNextAlias()
Local cAliasABB	:= GetNextAlias()
Local aInfo		:= {}
Local cIn		:= ""
Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local aAreaABQ	:= ABQ->(GetArea())
Local nTotal 	:= 0
Local oDlg		:= nil
Local oSayMtr	:= nil
Local nMeter	:= 0
Local lRet		:= .T.
Default cContra := ""

BeginSql Alias cAliasABQ
	SELECT
		TFF.TFF_COD,
		TFF.TFF_CODSUB,
		ABQ.ABQ_CONTRT,
		ABQ.ABQ_ITEM,
		ABQ.ABQ_ORIGEM,
		ABQ.ABQ_TOTAL,
		ABQ.ABQ_SALDO,
		ABQ2.ABQ_CONTRT CONTRTSUB,
		ABQ2.ABQ_ITEM ITEMSUB,
		ABQ2.ABQ_ORIGEM ORIGEMSUB

	FROM %table:ABQ% ABQ

	INNER JOIN %table:TFF% TFF ON
		TFF.TFF_FILIAL = %xFilial:TFF% AND
		TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND
		TFF.TFF_COD = ABQ.ABQ_CODTFF AND
		TFF.%notdel%

	INNER JOIN %table:TFL% TFL ON
		TFL.TFL_FILIAL = %xFilial:TFL% AND
		TFL.TFL_CODPAI = %Exp:cTFJOrig% AND
		TFL.TFL_CODIGO = TFF.TFF_CODPAI	AND
		TFL.%notdel%

	INNER JOIN %table:ABQ% ABQ2 ON
		ABQ2.ABQ_FILIAL = %xFilial:ABQ% AND
		ABQ2.ABQ_CODTFF = TFF.TFF_CODSUB AND
		ABQ2.ABQ_FILTFF = TFF.TFF_FILIAL AND
		ABQ2.%notdel%

	WHERE
		ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
		TFL.TFL_CODPAI = %Exp:cTFJOrig% AND
		ABQ.%notdel%
EndSql

If !isBlind()
	(cAliasABQ)->(DbEval({|| nTotal := nTotal + 1}))
	(cAliasABQ)->(DbGoTop())
EndIf


If isBlind()
	SumABQConf(cAliasABQ,@aInfo,@cIn)
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0259 //"Localizando configuração de alocação"
		oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (SumABQConf(cAliasABQ,@aInfo,@cIn,@oDlg,@oMeter))
EndIf

nTotal := 0
oDlg := nil
oSayMtr	:= nil
nMeter	:= 0

If !Empty(cIn)
	cIn := SubStr(cIn, 1, Len(cIn)-1)//Retira ultimo caracter
	cIn := StrTran(cIn, ',', "','")//substitui virgula considerando aspas da instrução IN do SQL

	BeginSql Alias cAliasABB
		SELECT
	        ABB_CODIGO, ABB_IDCFAL, ABB.R_E_C_N_O_ AS REGISTRO
		FROM %table:ABB% ABB

		WHERE
			ABB.ABB_FILIAL = %xFilial:ABB% AND
			ABB.ABB_IDCFAL IN (%Exp:cIn%)		AND
			ABB.%notdel%
	EndSql
	If !isBlind()
		If TcGetDb() $ "MSSQL,ORACLE,DB2"
			nTotal := LEN(aInfo)
		Else
			(cAliasABB)->(DbEval({|| nTotal := nTotal + 1}))
			(cAliasABB)->(DbGoTop())
		EndIf
	EndIf

	If isBlind()
		lRet := UpdABBIdCf(cAliasABB, aInfo)
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0260 //"Atualizando ID das alocações"
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (lRet := UpdABBIdCf(cAliasABB, aInfo,@oDlg,@oMeter))
	EndIf
	
	nTotal := 0
	oDlg := nil
	oSayMtr	:= nil
	nMeter	:= 0
EndIf

nTotal := Len(aInfo)
If isBlind()
	If Empty(cContra) .OR. At740Recor(cContra)
		UpdABQSald(aInfo)
	EndIf
Else
	If Empty(cContra) .OR. At740Recor(cContra)
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0261 //"Atualizando saldo de alocação"
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (UpdABQSald(aInfo,@oDlg,@oMeter))
	EndIf
EndIf

RestArea(aAreaABQ)
RestArea(aAreaABB)
RestArea(aArea)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTFHSubs
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTFH, character, Codigo TFH
@return cRet, codigo do registro substituto (TFH_CODSUB))
@description
Recupera TFH_CODSUB
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetTFHSubs(cCodTFH)

Local aArea	:= TFH->(GetArea())
Local cRet		:= ""

TFH->(DbSetOrder(1))//TFH_FILIAL+TFH_CODIGO
If TFH->(DbSeek(xFilial("TFH")+cCodTFH))
	cRet := TFH->TFH_CODSUB
EndIf

TFH->(RestArea(aArea))

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTFGSubs
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTFG, character, Codigo TFG
@return cRet, codigo do registro substituto (TFG_CODSUB))
@description
Recupera TFG_CODSUB
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetTFGSubs(cCodTFG)

Local aArea	:= TFG->(GetArea())
Local cRet		:= ""

TFG->(DbSetOrder(1))//TFG_FILIAL+TFG_CODIGO
If TFG->(DbSeek(xFilial("TFG")+cCodTFG))
	cRet := TFG->TFG_CODSUB
EndIf

TFG->(RestArea(aArea))

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuItPL
@author rogerio.souza
@since 31/10/2013
@version 1.0
@param cContra, character, Numero do contrato
@param cOldRevisa, character, Codigo da revisão anterior
@param cNewRevisa, character, Codigo da nova revisão
@param cPlan, character, Codigo da planilha
@param aItens, array, Relação de itens da planilha que serão verificados os seus substitutos
@return aRet, Estrutura com codigos dos itens substituidos baseados no parametro aItens
@description
Recupera relação de itens da planilha que foram criados devido a nova revisão de realinhamento do contrato
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function atuItPL(cContra, cOldRevisa, cNewRevisa, cPlan, aItens)

Local aRet			:= {}//Array com substitutos do aitens
Local aArea		:= CNB->(GetArea())
Local nQtdNewItem	:= 0//itens novos
Local nTotIt		:= 0//Total de itens
Local cItem		:= ""
Local aAntXNovos	:= {}//relação item Anterior vs Novo
Local nI			:= 1
Local nPos			:= 0

//Verifica quantidade de itens da planilha que serão criados para a proxima revisão
CNB->(DbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
CNB->(DbSeek(xFilial("CNB")+cContra+cOldRevisa+cPlan))
While CNB->(!EOF()) .AND. cContra == CNB->CNB_CONTRA .AND. cOldRevisa == CNB->CNB_REVISA .AND. cPlan == CNB->CNB_NUMERO
	If CNB->CNB_QTDMED > 0 .AND. CNB->CNB_SLDMED > 0
			aAdd(aAntXNovos, {CNB->CNB_ITEM, CNB->CNB_ITEM})//cria estrutura para identificar item novo
		nQtdNewItem++
	EndIf

	nTotIt++
	CNB->(DbSkip())
EndDo

cItem := StrZero(nTotIt+1, TamSx3("CNB_ITEM")[1])

CNB->(DbSeek(xFilial("CNB")+cContra+cNewRevisa+cPlan+cItem))
While CNB->(!EOF()) .AND. cContra == CNB->CNB_CONTRA .AND. cNewRevisa == CNB->CNB_REVISA .AND. cPlan == CNB->CNB_NUMERO
	If Len(aAntXNovos) >= nI
		aAntXNovos[nI][2] := CNB->CNB_ITEM
		nI++
	EndIf
	CNB->(DbSkip())
EndDo

aRet := aClone(aItens)

For nI:=1 To Len(aAntXNovos)
	nPos:=aScan(aRet, {|x| x == aAntXNovos[nI][1]})
	If nPos > 0
		aRet[nPos] := aAntXNovos[nI][2] // sobrescreve item antigo pelo item novo de acordo com itens passados por parametro
	EndIf
Next

CNB->(RestArea(aArea))
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistRev
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param cCodTFJ, character, (Codigo do orçamento de serviços)
@return lRet
@description
verifica se já existe revisão em aberto para a proposta
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ExistRev(cCodTFJ)

Local lRet		:= .F.
Local aArea	:= TFJ->(GetArea("TFJ"))
Local cChav	:= ""
Local lHasOrcSmp := HasOrcSimp()
TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))
	If lHasOrcSmp .And. TFJ->TFJ_ORCSIM == "1" //Se for Orçamento Simplificado
		cContrato := TFJ->TFJ_CONTRT
		cAliasQry	:= GetNextAlias()

			BeginSQL Alias cAliasQry
				SELECT '1' FROM %Table:TFJ% TFJ
				WHERE 	TFJ.TFJ_CONTRT = %Exp:cContrato% AND
						TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
						TFJ.TFJ_STATUS = '2' AND
						TFJ.TFJ_ORCSIM = '1' AND
						TFJ.%notDel%
			EndSql

		lRet := (cAliasQry)->(!EOF())
		(cAliasQry)->(DbCloseArea())
	Else
		cChav := xFilial("TFJ") + DEF_TFJ_EMREVISAO + TFJ->TFJ_PROPOS + TFJ->TFJ_PREVIS

		TFJ->( DbSetOrder( 4 ) ) //TFJ_FILIAL+TFJ_STATUS+TFJ_PROPOS+TFJ_PREVIS
		If TFJ->(DbSeek(cChav))
			lRet := .T.
		EndIf
	EndIf
EndIf

TFJ->(RestArea(aArea))
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870Legen
@author rogerio.souza
@since 17/10/2013
@version 11.9
@description
Aprensentação das Legendas disponiveis
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT870Legen()

Local oLegenda	:= FWLegend():New()

oLegenda:Add( "", "BR_VERDE",    STR0007 )		//"Ativo"
oLegenda:Add( "", "BR_BRANCO",   STR0040 )	 	//"Revisado"
oLegenda:Add( "", "BR_AMARELO",  STR0008 )		//"Em revisão"
oLegenda:Add( "", "BR_PINK",     STR0041 )		//"Aguardando aprovação"
oLegenda:Add( "", "BR_VERMELHO", STR0030 )		//"Contrato em elaboração no SIGAGCT"
oLegenda:Add( "", "BR_VIOLETA",  STR0150 )		//"Contrato emitido no SIGAGCT"
oLegenda:Add( "", "BR_LARANJA",  STR0151 )		//"Contrato em aprovação no SIGAGCT"
oLegenda:Add( "", "BR_AZUL",     STR0070 )		//"Contrato Encerrado"
oLegenda:Add( "", "BR_PRETO",    STR0080 )		//"Cancelado"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870View
@author rogerio.souza
@since 12/11/2013
@version 11.9
@param cCodTFJ, character
@description
Apresenta visualização do orçamento de serviço.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870View(cCodTFJ, lAutomato, bSemTela)

Local aArea 	:= TFJ->(GetArea())
Local oModel 	:= Nil
Local lRet 	:= .F.
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)
Local cOrcMod	:= If( lOrcPrc, "TECA740F", "TECA740" )
Local lRet		:= .F.
Default bSemTela := {||.T.}
Default lAutomato := .F.
TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))

	If lOrcPrc
		At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV )
	EndIf

	At740FMsg( .F. ) // Desabilita as mensagens de erro
	At740SLoad( Nil )

	If lAutomato
		oModel := FwLoadModel(cOrcMod)
		oModel:SetOperation(MODEL_OPERATION_VIEW)
		oModel:Activate()
		lRet := Eval( bSemTela, oModel )
	Else
		FWExecView(STR0017,"VIEWDEF."+cOrcMod, MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ )
	EndIf

	If lOrcPrc
		at740ClSht()
	EndIf
	At600STabPrc( '', '' )

Else
	Help( ' ', 1, "TECA870", , STR0018, 1, 0 )	//"Orçamento de Serviços não encontrado"
EndIf

TFJ->(RestArea(aArea))
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870VldCN0
@author rogerio.souza
@since 18/10/2013
@version 1.0
@param cCod, character
@param cDesc, character - atualiza descrição do tipo de revisão por referencia
@return lRet, Boolean
@description
Valida tipo de revisão
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870VldCN0(cCod, cDesc, lNoHelp)

Local lRet		:= .T.
Local aArea	:= GetArea("CN0")
Default lNoHelp := .F.
CN0->(DbSetOrder(1))//CN0_FILIAL+CN0_CODIGO
If CN0->(DbSeek(xFilial("CN0")+cCod))
	If CN0->CN0_TIPO!='F'
		//A partir do Release 15, apenas o novo tipo de revisao "Orcamento Servicos" é aceitavel para
		//as revisoes do SIGATEC
		lRet := .F.
		If lNoHelp
			AutoGrLog( "At870VldCN0" + " / " + STR0012 )	//"Orçamento de serviço não informado"
		Else
			Help( ' ', 1, "At870VldCN0", , STR0012, 1, 0 )	//"Tipo de revisão inválido"
		EndIf
	EndIf
Else
	lRet := .F.
	If lNoHelp
		AutoGrLog( "At870VldCN0" + " / " + STR0013 )	//"Orçamento de serviço não informado"
	Else
		Help( ' ', 1, "At870VldCN0", , STR0013, 1, 0 )	//"Tipo de revisão não encontrado"
	EndIf
EndIf

If lRet .AND. ValType(cDesc) == "C"
	cDesc := CN0->CN0_DESCRI
EndIf

CN0->(RestArea(aArea))
Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870VldInfo
@author rogerio.souza
@since 18/10/2013
@version 11.9
@param cCodTr, character, Código do tipo de revisão
@param cCodDes, character, Descrição do tipo de revisão, é realizada a atualização por referencia
@return lRet, Verdadeiro caso campos estejam OK
@description
Realiza validação das informações para geração de revisão a partir do gestão de contratos
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870VldInfo(cCodTr)

Return At870VldCN0(cCodTr)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870VldTFJ
@version 11.9
@param cCodTFJ, character, Código do Orçamento de Serviços
@return lRet, Verdadeiro caso campos estejam OK
@description
Realiza validação geral da TFJ
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870VldTFJ(cCodTFJ, lNoHelp)
Local lHasOrcSmp := HasOrcSimp()
Local	lRet	:= .T.

If Empty(cCodTFJ)
	lRet := .F.
	If lNoHelp
		AutoGrLog( "At870VldTFJ_1" + " / " + STR0020 )	//"Orçamento de serviço não informado"
	Else
		Help( ' ', 1, "At870VldTFJ_1", , STR0020, 1, 0 )	//"Orçamento de serviço não informado"
	EndIf
ElseIf lHasOrcSmp
	If !AT745Simp(cCodTfj) .AND. !isIntegGCT(cCodTfj)//verifica proposta com tipo de contrato integrado ao GCT
		lRet := .F.
		If lNoHelp
			AutoGrLog( "At870VldTFJ_2" + " / " + STR0014 )	//"Realização de revisões permitida somente para itens integrado ao GCT"
		Else
			Help( ' ', 1, "At870VldTFJ_2", , STR0014, 1, 0 )	//"Realização de revisões permitida somente para itens integrado ao GCT"
		EndIf
	EndIf
ElseIf !isIntegGCT(cCodTfj)//verifica proposta com tipo de contrato integrado ao GCT
	lRet := .F.
	If lNoHelp
		AutoGrLog( "At870VldTFJ_2" + " / " + STR0014 )	//"Realização de revisões permitida somente para itens integrado ao GCT"
	Else
		Help( ' ', 1, "At870VldTFJ_2", , STR0014, 1, 0 )	//"Realização de revisões permitida somente para itens integrado ao GCT"
	EndIf
ElseIf hasNewRev(cCodTFJ)//verifica proposta com tipo de contrato integrado ao GCT
	lRet := .F.
	If lNoHelp
		AutoGrLog( "At870VldTFJ_3" + " / " + STR0024 )	//"Não é possivel gerar a revisão. Existe uma revisão em aberto para o contrato no Gestão de Contratos."
	Else
		Help( ' ', 1, "At870VldTFJ_3", , STR0024, 1, 0 )	//"Não é possivel gerar a revisão. Existe uma revisão em aberto para o contrato no Gestão de Contratos."
	EndIf
Else
	TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
	If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))
		If 	TFJ->TFJ_STATUS == DEF_TFJ_CANCELADO
			lRet := .F.
			If lNoHelp
				AutoGrLog( "At870VldTFJ_4" + " / " + STR0090 )	//"O orçamento de serviços encontra-se cancelado"
			Else
				Help( ' ', 1, "At870VldTFJ_4", , STR0090, 1, 0 )	//"O orçamento de serviços encontra-se cancelado"
			EndIf
		ElseIf TFJ->TFJ_STATUS == DEF_TFJ_ENCERRADO
			lRet := .F.
			If lNoHelp
				AutoGrLog( "At870VldTFJ_5" + " / " + STR0085 )	//"O orçamento de serviços já encontra-se encerrado."
			Else
				Help( ' ', 1, "At870VldTFJ_5", , STR0085, 1, 0)	//"O orçamento de serviços já encontra-se encerrado."
			EndIf
		ElseIf	TFJ->TFJ_STATUS == DEF_TFJ_AGDAPROVA
			lRet := .F.
			If lNoHelp
				AutoGrLog( "At870VldTFJ_7" + " / " + STR0019 )	//"Já existe revisão em aberto para o orçamento de serviços"
			Else
				Help( ' ', 1, "At870VldTFJ_7", , STR0019, 1, 0 )	//"Já existe revisão em aberto para o orçamento de serviços"
			EndIf
		ElseIf	TFJ->TFJ_STATUS != DEF_TFJ_EMREVISAO
			If ExistRev(cCodTfj)
				lRet := .F.
				If lNoHelp
					AutoGrLog( "At870VldTFJ_6" + " / " + STR0019 )	//"Já existe revisão em aberto para o orçamento de serviços"
				Else
					Help( ' ', 1, "At870VldTFJ_6", , STR0019, 1, 0 )	//"Já existe revisão em aberto para o orçamento de serviços"
				EndIf
			EndIf
		EndIf

		IF	!EMPTY(TFJ->TFJ_CODTAB)
			At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV ) //Atribuir nessa Static a tabela/revisão do orçamento
		EndIf

	EndIf
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isIntegGCT
@author rogerio.souza
@since 18/10/2013
@version 11.9
@param cCodTFJ, character
@return lRet, indica se o registro da proposta é integrado ao Gestão de Contratos (GCT)
@description
Verifica se a proposta da TFJ utiliza integração com gestão de Contratos.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function isIntegGCT(cCodTFJ)
Local lRet			:= .F.
Local cAliasQry	:= GetNextAlias()

BeginSQL Alias cAliasQry
	SELECT  ADY_TPCONT
		FROM %Table:ADY% ADY
	INNER JOIN %Table:TFJ% TFJ ON
		TFJ.TFJ_FILIAL = ADY.ADY_FILIAL AND
		TFJ.TFJ_PROPOS = ADY.ADY_PROPOS AND
		TFJ.TFJ_PREVIS = ADY.ADY_PREVIS AND
		TFJ.TFJ_CODIGO = %Exp:cCodTFJ% AND
		TFJ.%notDel%
	WHERE
		ADY.ADY_FILIAL = %xFilial:ADY% AND
		ADY.%notDel%
EndSql

If (cAliasQry)->(!EOF()) .AND. (cAliasQry)->(ADY_TPCONT) == '4'//Contrato integrado GCT
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasNewRev
@author rogerio.souza
@since 31/10/2013
@version 1.0
@param cCodTFJ, character, (DescriÃ§Ã£o do parÃ¢metro)
@return lRet
@description
verifica se já existe uma nova revisão no GCT
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function hasNewRev(cCodTFJ)
Local lRet			:= .F.
Local cAliasQry	:= GetNextAlias()

BeginSQL Alias cAliasQry
	SELECT
		CN9.CN9_REVATU

	FROM %Table:TFJ% TFJ

	INNER JOIN %Table:CN9% CN9 ON
		CN9.CN9_FILIAL = %xFilial:CN9% AND
		CN9.CN9_NUMERO = TFJ.TFJ_CONTRT AND
		CN9.CN9_REVISA = TFJ.TFJ_CONREV AND
		CN9.CN9_SITUAC NOT IN ('01', '08') AND
		CN9.%notDel%

	WHERE
		TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
		TFJ.TFJ_CODIGO = %Exp:cCodTFJ% AND
		TFJ.%notDel%
EndSql

If (cAliasQry)->(!EOF()) .AND. !Empty((cAliasQry)->CN9_REVATU)
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At870AtuBrw
@author rogerio.souza
@since 31/10/2013
@version 11.9
@param oBrowse, objeto, (Browser a ser atualizado)
@description
Atualiza browse
/*/
//-------------------------------------------------------------------
Static Function At870AtuBrw(oBrowse)

oBrowse:Refresh()
oBrowse:ExecuteFilter(.T.)
oBrowse:UpdateBrowse()

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewErroMvc
@sample        ViewErroMvc( oObjMdl )
@param         oObjMdl, Objeto, Objeto Model
@return        NIL
@author        rogerio.souza
@version       11.9
@description
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewErroMvc( oObjMdl, lExibeErro )

Local aErro	:= {}
Default lExibeErro := .F.

aErro := oObjMdl:GetErrorMessage()

If Len(aErro) > 0
	AutoGrLog( '[' + AllToChar( aErro[MODEL_MSGERR_IDFORMERR] ) + ']' )
	AutoGrLog( '[' + AllToChar( aErro[MODEL_MSGERR_IDFIELDERR] ) + ']' )
	AutoGrLog( '[' + AllToChar( aErro[MODEL_MSGERR_ID] ) + ']' )
	AutoGrLog( '[' + AllToChar( aErro[MODEL_MSGERR_MESSAGE] ) + '|' + AllToChar( aErro[MODEL_MSGERR_SOLUCTION] ) + ']' )

	If lExibeErro
		MostraErro()
	EndIf
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At870Contr
@since 02/01/2014
@version 11.9
@param Status do contrato, contrato e revisão
@description
Atualiza browse
/*/
//-------------------------------------------------------------------
Function At870Contr(cStatus,cCont,cRevis, cFilCN9)
Local cColor	:= "BR_AMARELO"
Local aArea	:= GetArea()

Default cFilCN9 := xFilial("CN9")

DbSelectArea("CN9")
DbSetOrder(1)
If CN9->(DbSeek(cFilCN9 + cCont + cRevis))
	If CN9->CN9_SITUAC == DEF_SELAB			//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
		cColor	:=	"BR_VERMELHO"
	ElseIf CN9->CN9_SITUAC == DEF_SEMIT	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
		cColor	:=	"BR_VIOLETA"
	ElseIf CN9->CN9_SITUAC == DEF_SAPRO	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
		cColor	:=	"BR_LARANJA"
	ElseIf CN9->CN9_SITUAC == DEF_SREVS	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
		cColor	:=	"BR_PINK"
	ElseIf CN9->CN9_SITUAC == DEF_SSPAR	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
		cColor	:=	"BR_MARROM"
	ElseIf cStatus == DEF_TFJ_ATIVO //"1"
		cColor	:=	"BR_VERDE"
	ElseIf cStatus == DEF_TFJ_REVISADO //"3"
		cColor := "BR_BRANCO"
	ElseIf cStatus == DEF_TFJ_ENCERRADO //"5"
		cColor := "BR_AZUL"
	ElseIf cStatus == DEF_TFJ_CANCELADO //"6"
		cColor := "BR_PRETO"
	Else
		cColor	:=	"BR_AMARELO" //"2"
	EndIf
ElseIf cStatus == DEF_TFJ_ATIVO //"1"
	cColor	:=	"BR_VERDE"
ElseIf cStatus == DEF_TFJ_REVISADO //"3"
	cColor := "BR_BRANCO"
ElseIf cStatus == DEF_TFJ_AGDAPROVA //"4"
	cColor := "BR_PINK"
Elseif	cStatus == DEF_TFJ_ENCERRADO //"5"
	cColor := "BR_AZUL"
ElseIf cStatus == DEF_TFJ_CANCELADO //"6"
	cColor := "BR_PRETO"
Else
	cColor	:=	"BR_AMARELO" //"2"
EndIf
RestArea(aArea)
Return cColor

//-------------------------------------------------------------------
/*/{Protheus.doc} At870GerOrc
Consiste o contrato para a geração dos itens extras.
@sample 	At870GerOrc( nOperacao, oModel )
@param		cOrcServico	Orçamento de serviços utilizado para referencia
							dos itens extra para o contrato.
@author	Serviços
@since		17/04/2014
@version	P12
/*/
//-------------------------------------------------------------------
Function At870GerOrc( cOrcServico, cAliasPro, lAutomato, bAuto )
Local lRet			:= .T.					// Retorno da validacao.
Local lConfirm	:= .T.
Local aArea		:= GetArea()
Local lOrcPrc
Local cOrcMod
Local oOrcServico
Local oAuto
Local lTecItExtOp := IsInCallStack("At190dGrOrc") 
Local lTec855 := IsInCallStack("AT855ORC") 
Local aButtons := {}
Default bAuto := {|| .T. }
Default lAutomato := .F.

dbSelectArea("TFJ")
TFJ->(dbSetOrder(1))

lRet := TFJ->(dbSeek(xFilial("TFJ")+cOrcServico))

If lRet

	lOrcPrc		:= !EMPTY(TFJ->TFJ_CODTAB)
	cOrcMod		:= If( lOrcPrc, "TECA740F", "TECA740" )
	If TFJ->TFJ_STATUS == DEF_TFJ_REVISADO
		Help( ' ', 1, "At870GerOrc", , STR0240, 1, 0 ) //"Não é permitido adicionar Item Extra em um contrato já revisado. Por favor, selecione o orçamento ativo (legenda verde)"
	ElseIf TFJ->TFJ_STATUS == DEF_TFJ_ENCERRADO
		Help( ' ', 1, "At870GerOrc", , STR0073, 1, 0 )	//"Contrato Encerrado"
	ElseIf TFJ->TFJ_STATUS == DEF_TFJ_CANCELADO
		Help( ' ', 1, "At870GerOrc", , STR0090, 1, 0 )	//"O orçamento de serviços encontra-se cancelado"
	ElseIf !lOrcPrc .AND. !(At870VldItEx(cOrcServico , lOrcPrc)) .AND. !lTec855
		Help( ' ', 1, "At870GerOrc", , STR0152, 1, 0 )//#"Nesse contrato não foi gerado itens de RH, Por isso Não é Possivel fazer a inclusão de Itens Extra"
	ElseIf At580BSit(TFJ->TFJ_CONTRT) == '2' .AND. !lTec855
		Help( ' ', 1, "At870GerOrc", , STR0241, 1, 0 ) //"Não é permitido adicionar Item Extra em um contrato que está em processo de revisão."
	Else
		If lRet

			At740FMsg( .F. ) // Desabilita as mensagens de erro

			If lOrcPrc
				At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV )
			EndIf

			oOrcServico := FwLoadModel(cOrcMod)

			If lTec855			
				oOrcServico:SetOperation(MODEL_OPERATION_VIEW)
			Else
				oOrcServico:SetOperation(MODEL_OPERATION_UPDATE)				
			EndIf
			
			lRet := TecActivt(@oOrcServico)

			If lRet

				At740SLoad( oOrcServico ) 	// atribui o model com o conteúdo copiado para carga na view da rotina
				At740SCmt( .T. )				// habilita commit
				At740FMsg( .T. )				// Habilita as mensagens de erro
				If !lAutomato
					If lTecItExtOp
						aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0275},{.T.,STR0276},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"#"Fechar"
						lRet := ( FWExecView( IIF(lTec855,STR0017,STR0274), "VIEWDEF." + cOrcMod, MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // "Item Extra Operacional"
										{||.T.}/*bOk*/,/*nPercRed*/,aButtons, {||.T.}/*bCancel*/ ) == 0 )					
					Else
						lRet := ( FWExecView( STR0239, "VIEWDEF." + cOrcMod, MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // 'Item Extra'
												{||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )
					Endif
				Else
					oAuto := FwLoadModel(cOrcMod)
					oAuto:SetOperation( MODEL_OPERATION_UPDATE)
					oAuto:Activate()

					lRet := Eval(bAuto, oAuto)
				EndIf

				At740SLoad( Nil )
				At740SCmt( .F. )
				At740FMsg( .F. )

			Else
				ViewErroMvc( oOrcServico )
			EndIf
		EndIf
	Endif
Else
	Help(,,"AT870ORC",,STR0058,1,0) // "Orçamento de serviços invalido/inexistente para essa operação!"
EndIf
RestArea(aArea)
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At870VldItEx
Validação para Verificar se Existe RH quando Não for Utilizado tabela de Precificação

@sample 	At870VldItEx( cOrcServico )
@param		cOrcServico,Caractere,	Orçamento de serviços utilizado para referencia
									dos itens extra para o contrato.
@return		lRet, logico, .T. OK, .F. Não OK

@author		Joni.Carmo
@since		24/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function At870VldItEx(cOrcServico,lOrcPrc)

Local aArea 	:= GetArea()
Local lRet  	:= .F.
Local cTmpAlias    := GetNextAlias()

Default lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)

If !lOrcPrc //Caso não utilize Tabela de Precificação

	BeginSql Alias cTmpAlias

		SELECT
			TFF_COD
		FROM %Table:TFJ% TFJ
		INNER JOIN %Table:TFL% TFL
			 ON TFL_FILIAL = %xFilial:TFL%
			AND TFL_CODPAI = TFJ_CODIGO
		INNER JOIN %Table:TFF% TFF
			 ON TFF_FILIAL = %xFilial:TFF%
			AND TFF_CODPAI = TFL_CODIGO
		WHERE
			TFJ_FILIAL = %xFilial:TFJ% AND
			TFJ_CODIGO = %Exp:cOrcServico% AND
			TFJ.%NotDel% AND
			TFL.%NotDel% AND
			TFF.%NotDel%
	EndSql

	(cTmpAlias)->(dbGoTop())
	lRet := ( !(cTmpAlias)->(Eof()) )
	(cTmpAlias)->(DbCloseArea())

EndIf

RestArea(aArea)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870ExcR
@since 17/04/2014
@version 12
@param cStatus, character status do contrato
@param cCodTFJ, character código do orçamento de serviços
@description
Realiza processo de exclusão da revisão do contrato
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870ExcR(cStatus,cCodTFJ,cContrato,cRevContrt)

Local lRet		:= .F.
Local lOrcPrc
Local cModLoad
Local oModel 	:= Nil
Local lNoPlan := AT870RevPl(cCodTFJ)

If (cStatus == DEF_TFJ_AGDAPROVA .AND. lNoPlan) .AND. ( isBlind() .OR. MsgYesNo(STR0218) )
	//"A operação excluirá o contrato com o status Em Revisão correspondente. Essa opção também exclui o orçamento Em Elaboração. Deseja continuar?"
	lRet := AT870DelRe(cContrato, cRevContrt, cCodTFJ)
ElseIf (cStatus == DEF_TFJ_EMREVISAO ) .AND. (!hasNewRev(cCodTFJ) .OR. AT870IsAct(cContrato))
	If lNoPlan
		DbSelectArea("TFJ")
		DbSetOrder(1) //TFJ_FILIAL+TFJ_CODIGO
		If DbSeek(xFilial("TFJ")+cCodTFJ)
			If ( isBlind() .OR. MsgYesNo(STR0042) ) //"Deseja excluir essa revisão?"

				lOrcPrc 	:= !(EMPTY(TFJ->TFJ_CODTAB))
				cModLoad 	:= If( lOrcPrc, "TECA740F", "TECA740" )

				oModel := FwLoadModel( cModLoad )
				oModel:SetOperation( MODEL_OPERATION_DELETE )

				If lOrcPrc
					At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV ) //Atribuir nessa Static a tabela/revisão do orçamento
				EndIf

				If ( lRet := TecActivt(@oModel) )
					// habilita a gravação dos dados do orçamento de serviços no banco
					At740SCmt( .T. )
					cContrato := oModel:GetModel("TFJ_REFER"):GetValue("TFJ_CONTRT")
					cRevContrt := oModel:GetModel("TFJ_REFER"):GetValue("TFJ_CONREV")
					lRet := lRet .And. oModel:VldData() .And. oModel:CommitData()
					At740SCmt( .F. )
					at740ClSht()
				EndIf

				If lRet
					At870RemSub( cCodTFJ, lOrcPrc, cContrato, cRevContrt )
				ElseIf oModel:HasErrorMessage()
					AtErroMvc( oModel )
					MostraErro()
				Else
					Help( ' ', 1, 'At870ExcR4', ,STR0173, 1, 0 )  // "Não foi possível excluir o orçamento da revisão do contrato"
				Endif

				If lRet .And. !Empty(TFJ->TFJ_GRPCOM)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SIGATEC WorkFlow # CT - Interações de Contratos Exclusão da Revisão ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					At774Mail("TFJ",TFJ->TFJ_GRPCOM,"CT","<b>"+STR0106+"</b> "+TFJ->TFJ_PROPOS+"<b> "+STR0107+"</b>"+TFJ->TFJ_CONTRT,"RED",STR0111) //"Num. Proposta: " # "Nr. Contrato: " # "Exclusão da Revisão"
				EndIf
			EndIf
		EndIf
	Else
		Help( ' ', 1, 'At870ExcR4', ,STR0326, 1, 0 ) //"Orçamento é de uma revisão planejada, não é possivel exclui-lo!"
	EndIf
Elseif cStatus == DEF_TFJ_ENCERRADO
	Help( ' ', 1, 'At870ExcR5', ,STR0074, 1, 0 )	//"Contrato encerrado, não é permitida a sua exclusão"
Elseif cStatus == DEF_TFJ_CANCELADO
	Help( ' ', 1, 'At870ExcR6', ,STR0092, 1, 0 )	//"Contrato cancelado, não é permitida a sua exclusão"
Else
	Help( ' ', 1, 'At870ExcR7', ,STR0043, 1, 0 )	//"Só é possível excluir orçamento 'em revisão' e que não esteja com a revisão em andamento."
EndIf

Return lRet

/*/{Protheus.doc} At870RemSub
	Realiza processo de exclusão da revisão do contrato dos itens que ficaram com códigos de substituto
@since 30/11/2016
@version 12
@param cCodTFJ, character, código do orçamento de serviços
@param lOrcPrc, Lógico, determina se é ou não orçamento com precificação
/*/
Static Function At870RemSub( cCodTFJ, lOrcPrc, cContrato ,cRevContrt )
Local cCodTFJAnt 	:= ""
Local cQry := GetNextAlias()
Local cFilTFL := xFilial("TFL")
Local cFilTFF := xFilial("TFF")
Local cFilTFI := xFilial("TFI")

BeginSQL Alias cQry
	SELECT TFJ.TFJ_CODIGO, TFJ.R_E_C_N_O_ TFJRECNO
	FROM %Table:TFJ% TFJ
	WHERE TFJ.TFJ_FILIAL = %xFilial:TFJ%
		AND TFJ.TFJ_CONTRT = %Exp:cContrato%
		AND TFJ.TFJ_CONREV = %Exp:cRevContrt%
		AND TFJ.%NotDel%
EndSQL

If (cQry)->(!EOF())

	DbSelectArea("TFJ")
	TFJ->( DbGoTo( (cQry)->TFJRECNO ) )
	cCodTFJAnt := TFJ->TFJ_CODIGO

	(cQry)->(DbCloseArea())

	DbSelectArea("TFL")
	TFL->(DbSetOrder( 2 )) // TFL_FILIAL + TFL_CODPAI
	DbSelectArea("TFF")
	TFF->(DbSetOrder( 3 )) // TFF_FILIAL + TFF_CODPAI
	DbSelectArea("TFI")
	TFI->(DbSetOrder( 3 )) // TFF_FILIAL + TFF_CODPAI
	DbSelectArea("TFG")
	TFG->(DbSetOrder( 3 )) // TFF_FILIAL + TFF_CODPAI
	DbSelectArea("TFH")
	TFH->(DbSetOrder( 3 )) // TFF_FILIAL + TFF_CODPAI

	TFL->( DbSeek( cFilTFL + cCodTFJAnt ) )

	While TFL->(!EOF()) .And. TFL->TFL_FILIAL == cFilTFL .And. TFL->TFL_CODPAI == cCodTFJAnt

		Reclock("TFL", .F.)
			TFL->TFL_CODSUB := ""
		TFL->(MsUnlock())

		// percorrer os itens de recursos humanos para remover a marcaçao de item destino substituto em função da revisão
		TFF->( DbSeek( cFilTFF + TFL->TFL_CODIGO ) )
		While TFF->(!EOF()) .And. TFF->TFF_FILIAL == cFilTFF .And. TFF->TFF_CODPAI == TFL->TFL_CODIGO
			Reclock("TFF", .F.)
				TFF->TFF_CODSUB := ""
			TFF->(MsUnlock())

			If !lOrcPrc
				At870RemMats( lOrcPrc )
			EndIf
			TFF->(DbSkip())
		End

		If lOrcPrc
			At870RemMats( lOrcPrc )
		EndIf

		// percorrer os itens de locação de equipamentos para remover a marcaçao de item destino substituto em função da revisão
		TFI->( DbSeek( cFilTFI + TFL->TFL_CODIGO ) )
		While TFI->(!EOF()) .And. TFI->TFI_FILIAL == cFilTFI .And. TFI->TFI_CODPAI == TFL->TFL_CODIGO
			Reclock("TFI", .F.)
				TFI->TFI_CODSUB := ""
			TFI->(MsUnlock())
			TFI->(DbSkip())
		End

		TFL->(DbSkip())
	End

EndIf

Return

/*/{Protheus.doc} At870RemMats
	Realiza processo de exclusão da revisão do contrato dos itens de materiais que ficaram com códigos de substituto
@since 30/11/2016
@version 12
@param lOrcPrc, Lógico, determina se é ou não orçamento com precificação
/*/
Static Function At870RemMats( lOrcPrc )
Local cFilTFG := xFilial("TFG")
Local cFilTFH := xFilial("TFH")
Local cCodSup := If( lOrcPrc, TFL->TFL_CODIGO, TFF->TFF_COD )

// indicação do índice já aconteceu na função anterior
TFG->( DbSeek(cFilTFG + cCodSup ) )
While TFG->(!EOF()) .And. TFG->TFG_FILIAL == cFilTFG .And. TFG->TFG_CODPAI == cCodSup

	Reclock("TFG", .F.)
		TFG->TFG_CODSUB := ""
	TFG->(MsUnlock())

	TFG->( DbSkip() )
End

// indicação do índice já aconteceu na função anterior
TFH->( DbSeek(cFilTFH + cCodSup ) )
While TFH->(!EOF()) .And. TFH->TFH_FILIAL == cFilTFH .And. TFH->TFH_CODPAI == cCodSup

	Reclock("TFH", .F.)
		TFH->TFH_CODSUB := ""
	TFH->(MsUnlock())

	TFH->( DbSkip() )
End

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870VlEfR
@since 17/04/2014
@version 12
@param cStatus, character status do contrato
@description
Realiza processo de efetivação da revisão
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870VlEfR(cStatus,cCodTFJ,cTpRev,oBrowse)

Local lRet		:= .T.

cTp := At870TpCont(cTpRev)


If cStatus == "2"
	Begin Transaction
		MsgRun ( STR0029, STR0004, {|| At870EftRv(cCodTfj,cTpRev,cTp ) } ) // 'Processando revisão...' ### "Aguarde..."
		At870AtuBrw(oBrowse)
	End Transaction
Else
	lRet := .F.
	Help( ' ', 1, 'At870VlEfR', ,STR0044, 1, 0 )	//"Somente Orçamento de serviço que esteja 'EM REVISÃO' poderá ser efetivado"
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870TpCont
@since 17/04/2014
@version 12
@param cCodTr, character Código do Tipo de revisão
@description
Busca o Tipo de revisão
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870TpCont(cCodTr)

Local aAreaCN0	:= GetArea()
Local cTp			:= ""

DbSelectArea("CN0")
CN0->(DbSetOrder(1))//CN0_FILIAL+CN0_CODIGO
If CN0->(DbSeek(xFilial("CN0")+cCodTr))
	cTp := CN0->CN0_TIPO
EndIf

RestArea(aAreaCN0)

Return cTp

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Nwl
@since 17/04/2014
@version 12
@param cModel, character Modelo
@description
Validação da nova linha no orçamento de serviços
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870Nwl(cModel)
Local lRet		:= .T.
Local oModel := FWModelActive()
Local oGrid		:= oModel:GetModel(cModel)
Local cContr		:= oModel:GetModel('TFJ_REFER'):GetValue("TFJ_CONTRT")
Local cRev		:= oModel:GetModel('TFJ_REFER'):GetValue("TFJ_CONREV")
Local cCodCli 	:= ""
Local cLojCli 	:= ""

If At850GetCli( @cCodCli, @cLojCli, oGrid:GetValue("TFL_LOCAL"), oModel:GetModel('TFJ_REFER'):GetValue("TFJ_AGRUP") )
	DbSelectArea("CNC")
	DbSetOrder(3) //CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CLIENT+CNC_LOJACL
	If CNC->(!DbSeek(xFilial("CNC")+cContr+cRev+cCodCli+cLojCli))
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_LOCAL",oModel:GetModel():GetId(), "TFL_LOCAL",'AT870NWL',;
											STR0148, STR0149 ) //"Não é possivel incluir novos locais de atendimento com clientes diferentes"
		lRet := .F.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Filt
@since 17/04/2014
@version 12
@param oBrowse, objeto Janela
@description
Realiza o filtro das informações
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870Filt(oBrowse)
Return At870AtuBrw(oBrowse)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870AprRv
@since 17/04/2014
@version 12
@param cContr, character Numero do contrato
@param cRev, character Revisão do contrato
@param cStatus, character Status do contrato
@description
Realiza a aprovação do contrato com status aguardando aprovação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870AprRv(cContr, cRev,cStatus,lAutomato,cCodTFJ)
Local nRetorno		:= 0
Default cCodTFJ		:= ""
Default lAutomato	:= .F.

AT870GetTr( .T. )

If cStatus == DEF_TFJ_AGDAPROVA
	
	DbSelectArea("CN9")
	DbSetOrder(1) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA
	If DbSeek(xFilial("CN9")+cContr+cRev)
				
		If ValidTFFs(cContr,cRev,cStatus,lAutomato) .And. TecAprTrav(xFilial("TFJ"),cCodTFJ)
	
			Begin Transaction

				nRetorno := CN300Aprov(lAutomato)

				If nRetorno == 0 //Retorna 0 se for clicado em OK e 1 em Cancelar.
					
					At870Aprov(cContr,cRev,lAutomato)

					If ExistBlock('AT870RVAPR')
						ExecBlock('AT870RVAPR', .F., .F., {cContr,cRev})
					EndIf
				EndIf
			End Transaction
		EndIf
	EndIf
	

Else
	Help( ' ', 1, 'At870AprRv', ,STR0046, 1, 0 )	//"Ação permitida apenas para orçamento com status revisado"
EndIf
AT870GetTr( .F. )
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870AtuOr
@since 17/04/2014
@version 12
@param cContra, character Numero do contrato
@param cRevisa, character Revisão do contrato
@description
Atualiza as informações do novo local no orçamento de serviços
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870AtuOr(oModel,cContrato,cRevisa)

Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local oMdlRh	:= oModel:GetModel('TFF_RH')
Local oMdlMc	:= oModel:GetModel('TFH_MC')
Local oMdlLep	:= oModel:GetModel('TFI_LE')
Local oMdlLe	:= oModel:GetModel('TEV_ADICIO')
Local nI		:= 0
Local nL		:= 0
Local nK		:= 0
Local lOrcPrc 	:= SuperGetMV("MV_ORCPRC",,.F.)
Local lRet		:= .T.

For nL := 1 To oMdlLoc:Length()

	oMdlLoc:Goline( nL )

	For nI := 1 To oMdlRh:Length()

		oMdlRH:GoLine( nI )

		If !oMdlRH:IsDeleted() .And. !Empty(oMdlRH:GetValue("TFF_PRODUT")) .And. oMdlRH:GetValue("TFF_COBCTR") <> "2"

			lRet := lRet .AND. oMdlRH:SetValue("TFF_CONTRT",cContrato)
			lRet := lRet .AND. oMdlRH:SetValue("TFF_CONREV",cRevisa)

		EndIf
	Next nI

	For nI := 1 To oMdlLep:Length()

		oMdlLep:GoLine( nI )

		If !oMdlLep:IsDeleted() .And. !Empty(oMdlLep:GetValue("TFI_PRODUT"))

			lRet := lRet .AND. oMdlLep:SetValue("TFI_CONTRT",cContrato)
			lRet := lRet .AND. oMdlLep:SetValue("TFI_CONREV",cRevisa)

			For nK := 1 To oMdlLe:Length()

				oMdlLe:GoLine( nK )

				If !oMdlLe:IsDeleted() .AND. !Empty(oMdlLe:GetValue("TEV_MODCOB"))
					nQtdLe := oMdlLe:GetValue("TEV_QTDE")
					lRet := lRet .AND. oMdlLe:SetValue("TEV_SLD",nQtdLe)
				EndIf

			Next nK
		EndIf
	Next nI

Next nL

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870AtGES
@since 05/01/2015
@version 11.9
@param cCodTFJAnt, Codigo do orçamento de serviços anterior
@param cCodTFJ, Codigo do novo orçamento de serviços
@description Função para atualizar todos os funcionarios do local de atenidimento para a
			 gestão de escalas.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870AtGES( cCodTFJAnt, cCodTFJ )

Local cAliasTGY := GetNextAlias()
Local cAliasTGZ := GetNextAlias()
Local cAliasTXH := GetNextAlias()
Local aCodTFF   := At870CodTFF(cCodTFJAnt)
Local cSqlTFF   := ""
Local nPosTFF   := 0
Local nTotal 	:= 0
Local oDlg		:= nil
Local oSayMtr	:= nil
Local nMeter	:= 0
Local nI

If Len(aCodTFF) > 0

	cSqlTFF := "%("

	For nI:=1 To Len(aCodTFF)

		cSqlTFF += "'" + aCodTFF[ nI, 1 ] + "'"

		If (nI+1) <= Len(aCodTFF)
			cSqlTFF += ","
		EndIf

	Next nI

	cSqlTFF += ")%"

	// Verificar as configurações dos efetivos
	BeginSql Alias cAliasTGY

		SELECT
			TGY.TGY_FILIAL, TGY.TGY_ESCALA, TGY.TGY_CODTDX,
			TGY.TGY_CODTFF, TGY.TGY_ITEM
		FROM
			%table:TGY% TGY
		WHERE
			TGY.TGY_FILIAL = %xFilial:TGY% AND
			TGY.%notDel% AND
			TGY.TGY_CODTFF IN %Exp:cSqlTFF%

	EndSql

	While (cAliasTGY)->(!Eof())
		nTotal++
		(cAliasTGY)->(dbSkip())
	End
	(cAliasTGY)->(dbGoTop())
	
	dbSelectArea("TGY")
	TGY->(DbSetOrder(1)) //TGY_FILIAL+TGY_ESCALA+TGY_CODTDX+TGY_CODTFF+TGY_ITEM

	If isBlind()
		UpdTGYxTFF(cAliasTGY, aCodTFF)
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0262 //"Atualizando configuração de alocação"
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (UpdTGYxTFF(cAliasTGY, aCodTFF,@oDlg,@oMeter))
	EndIf
	
	nTotal := 0
	oDlg := nil
	oSayMtr := nil
	nMeter := 0
	
	// Verificar as configurações das coberturas
	BeginSql Alias cAliasTGZ

		SELECT
			TGZ.TGZ_FILIAL, TGZ.TGZ_ESCALA, TGZ.TGZ_CODTDX,
			TGZ.TGZ_CODTFF, TGZ.TGZ_ITEM
		FROM
			%table:TGZ% TGZ
		WHERE
			TGZ.TGZ_FILIAL = %xFilial:TGZ% AND
			TGZ.%notDel% AND
			TGZ.TGZ_CODTFF IN %Exp:cSqlTFF%
	EndSql

	While (cAliasTGZ)->(!Eof())
		nTotal++
		(cAliasTGZ)->(dbSkip())
	End
	(cAliasTGZ)->(dbGoTop())

	dbSelectArea("TGZ")
	TGZ->(DbSetOrder(1))//TGZ_FILIAL+TGZ_ESCALA+TGZ_CODTDX+TGZ_CODTFF+TGZ_ITEM
	
	If IsBlind()
		UpdTGZxTFF(cAliasTGZ, aCodTFF)
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0263 //"Atualizando configuração de cobertura"
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (UpdTGZxTFF(cAliasTGZ, aCodTFF,@oDlg,@oMeter))
	EndIf

	If TableInDic("TXH")
		BeginSql Alias cAliasTXH
			SELECT
				TXH.TXH_CODTFF, TXH.R_E_C_N_O_ AS REC
			FROM
				%table:TXH% TXH
			WHERE
				TXH.TXH_FILIAL = %xFilial:TXH% AND
				TXH.%notDel% AND
				TXH.TXH_CODTFF IN %Exp:cSqlTFF%
		EndSql
		
		While (cAliasTXH)->(!Eof())
			TXH->(DbGoTo((cAliasTXH)->REC))
			nPosTFF := aScan( aCodTFF, { |x| x[1] == (cAliasTXH)->TXH_CODTFF } )
	
			If nPosTFF > 0
				RecLock("TXH", .F.)
				TXH->TXH_CODTFF := aCodTFF[ nPosTFF, 2 ]
				TXH->(msUnlock())
			EndIf
	
			(cAliasTXH)->(DbSkip())
		EndDo
		
		(cAliasTXH)->(dbCloseArea())
	EndIf
	(cAliasTGY)->(dbCloseArea())
	(cAliasTGZ)->(dbCloseArea())
EndIf

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870CodTFF
@since 05/01/2015
@version 11.9
@param cCodTFJ, Codigo do orçamento de serviços
@description Função para retornar o codigo do recurso humano dentro do orçamento.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870CodTFF( cCodTFJ )

Local aRet      := {}
Local cAliasTFJ := GetNextAlias()

BeginSql Alias cAliasTFJ

	SELECT
		TFF.TFF_COD, TFF.TFF_CODSUB
	FROM
		%table:TFJ% TFJ
	JOIN %table:TFL% TFL ON
		TFL.TFL_FILIAL = %xFilial:TFL% AND
		TFL.TFL_CODPAI = TFJ.TFJ_CODIGO AND
		TFL.%notDel%
	JOIN %table:TFF% TFF ON
		TFF.TFF_FILIAL = %xFilial:TFF% AND
		TFF.TFF_CODPAI = TFL.TFL_CODIGO AND
		TFF.%notDel%
	WHERE
		TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
		TFJ.TFJ_CODIGO = %Exp:cCodTFJ% AND
		TFJ.%notDel%
	GROUP BY
		TFF.TFF_COD, TFF.TFF_CODSUB

EndSql

While (cAliasTFJ)->(!Eof())
	aAdd( aRet, { (cAliasTFJ)->TFF_COD, (cAliasTFJ)->TFF_CODSUB } )
	(cAliasTFJ)->(DbSkip())
EndDo

(cAliasTFJ)->(dbCloseArea())
Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870GerMem
@since 05/02/2015
@version 12
@sample 	At870GerMem(cNumContr, cRevContr, cAliasPro)
@param cNumContr - Numero do Contrato
@param cRevContr - Numero da Revisao
@param cAliasPro - Temporario
@return lRet, Retorno logico
@description
Realiza consistencias e chama tela de memorando
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870GerMem(cNumContr, cRevContr, cAliasPro)

Local lRet      := .F.
Local aAreaMe   := GetArea()
Local cAliasCN9 := GetNextAlias()
Local cMaxRev   := Space(TamSX3("CN9_REVISA")[1])
Local cSVig     := ''

If (cAliasPro)->TFJ_STATUS == DEF_TFJ_ATIVO

	// Verifica o Status do Contrato
	// Somente podera gerar o memorando para contratos vigentes
	IF ! Empty(cNumContr)
		DbSelectArea("CN9")
		CN9->(DbSetOrder(1)) // CN9_FILIAL, CN9_NUMERO, CN9_REVISA
		If CN9->(DbSeek(xFilial("CN9")+cNumContr+cRevContr))

			If CN9->CN9_SITUAC == DEF_SVIGE	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado

				cSVig := DEF_SVIGE //Necessario embedded não reconhece direto a Define

				// Verifica se contrato possui revisao
				BeginSql Alias cAliasCN9

					SELECT
						MAX(CN9.CN9_REVISA) AS CN9_REVISA
					FROM
						%table:CN9% CN9
					WHERE
						CN9.CN9_FILIAL = %xFilial:CN9% AND
						CN9.%notDel% AND
						CN9.CN9_NUMERO = %Exp:cNumContr% AND
						CN9.CN9_SITUAC = %Exp:cSVig%

				EndSql

				DbSelectArea(cAliasCN9)

				While (cAliasCN9)->( !Eof() )
					cMaxRev := (cAliasCN9)-> CN9_REVISA
					(cAliasCN9)->(DbSkip())
				EndDo

				(cAliasCN9)->( DbCloseArea() )

				If cMaxRev <> cRevContr
					Help( ' ', 1, "At870GerMem", , STR0061, 1, 0 )	//"Não é possível gerar o memorando para revisões anteriores"
				Else
					If !(isBlind()) .AND. ( PerguntMemo() .AND. MSGYESNO( STR0062,STR0060 ) ) //"Deseja realmente gerar os memorandos?" # "Memorando"
						// Chama rotina de geracao do memorando
						lRet := At330GerMem(cNumContr, cRevContr, '')
					Else
						lRet := .F.
					EndIf
				EndIf
			Else
				Help( ' ', 1, "At870GerMem", , STR0063, 1, 0 )	//"Permitido somente para contratos vigentes"
			EndIf
		Else
			Help( ' ', 1, "At870GerMem", , STR0064, 1, 0 )	//"Contrato não localizado"
		EndIf
	Else
		Help( ' ', 1, "At870GerMem", , STR0065, 1, 0 )	//"Não existe contrato gerado"
	EndIf
Elseif (cAliasPro)->TFJ_STATUS == DEF_TFJ_ENCERRADO
	Help( ' ', 1, "At870GerMem", , STR0099, 1, 0 )	//"Não é possível gerar memorandos para orçamentos de serviços encerrados."
Elseif (cAliasPro)->TFJ_STATUS == DEF_TFJ_CANCELADO
	Help( ' ', 1, "At870GerMem", , STR0093, 1, 0 )	//"Não é possível gerar memorandos para orçamentos de serviços cancelados."
Else
	Help( ' ', 1, "At870GerMem", , STR0094, 1, 0 )	//"Não é possível gerar memorandos para orçamentos de serviços em revisão."
EndIf

RestArea(aAreaMe)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870VRes
@since 04/03/2015
@version 12
@param oMdRes , Modelo da Revisao
@param cCodTFJ, Codigo do orçamento de serviços
@description Função que efetua o tratamento do bloqueio da revisão do contrato
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870VRes(oMdRes,cCodTFJ,cContrato,cRevisao)

Local lRet		:= .T.
Local aSaveRows	:= FwSaveRows( oMdRes )
Local cAliasTFL	:= GetNextAlias()
Local aAreaBLQ	:= GetArea()
Local nRecTFL	:= 0
Local nX		:= 0

Local oAuxTFL	:= oMdRes:GetModel("TFL_LOC")
Local oAuxTFF	:= oMdRes:GetModel("TFF_RH")
Local oAuxTFG	:= oMdRes:GetModel("TFG_MI")
Local oAuxTFH	:= oMdRes:GetModel("TFH_MC")
Local oAuxTFI	:= oMdRes:GetModel("TFI_LE")

// Totais do orcamento atual
Local nValRHOld	:= 0
Local nValMIOld	:= 0
Local nValMCOld	:= 0
Local nValLEOld	:= 0

// Totais do orcamento revisado
Local nValRHNew	:= 0
Local nValMINew	:= 0
Local nValMCNew	:= 0
Local nValLENew	:= 0

// Indices do local
Local cCdTFL		:= ''
Local cCTRTFL		:= ''
Local cREVTFL		:= ''
Local cPLATFL		:= ''
Local nLocAnt		:= 0

Default cContrato 	:= ""
Default cRevisao 	:= ""

// Percorre as localizacoes do orcamento
DbSelectArea("TFL")
TFL->(DbSetOrder(2)) // TFL_FILIAL, TFL_CODPAI

If POSICIONE("TFJ",1,xFilial("TFJ") + cCodTFJ, "TFJ_CNTREC") != '1' .AND. TFL->(DbSeek(xFilial("TFL")+cCodTFJ))

	Do While TFL->(!Eof()) .And. TFL->TFL_FILIAL == xFilial("TFL") .AND. TFL->TFL_CODPAI == cCodTFJ

		cCdTFL  := TFL->TFL_CODIGO
		cCTRTFL := TFL->TFL_CONTRT
		cREVTFL := TFL->TFL_CONREV
		cPLATFL := TFL->TFL_PLAN
 		nRecTFL := TFL->(Recno())
 		
		oAuxTFL:SeekLine( { {"TFL_CODIGO",cCdTFL} } )
		If ( nLocAnt := At870LocAnt( oAuxTFL:GetValue("TFL_CODIGO"), cCodTfj ) ) > 0
			// Totaliza os valores totais do orcamento atual
			At870ValOld( nLocAnt, @nValRHold, @nValMIold, @nValMCold, @nValLEold )
	
			// Totaliza os valores totais do orcamento revisado
			At870ValNew( oMdRes, oAuxTFL:GetLine(), @nValRHnew, @nValMInew, @nValMCnew, @nValLEnew )
	
			// Compara a diferenca dos totais do orcamento
			If !Empty( TFL->TFL_PLAN ) .And. ;
				( nValRHOld + nValMIOld + nValMCOld + nValLEOld ) > ( nValRHNew + nValMINew + nValMCNew + nValLENew )
	
				//Carrega Planilhas do contrato
				DbSelectArea("CNA")
				CNA->(DbSetOrder(1))  // CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
				If CNA->(DbSeek(xFilial("CNA")+cCTRTFL+cREVTFL+cPLATFL))
					lRet := ( ( nValRHNew + nValMINew + nValMCNew + nValLENew ) >= ( CNA->(CNA_VLTOT - CNA_SALDO) ) )
				Else
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				Help( ' ', 1, 'At870VRes', , STR0255 + TFL->TFL_PLAN +  STR0367 + CValToChar(CNA->(CNA_VLTOT - CNA_SALDO)) + STR0256 , 1, 0 ) //"O total da planilha de numero " ## " precisa ser igual ou maior que o valor ja medido ( " ## " ) no Gestão de Contratos." 
				EXIT
			EndIf
		EndIf
		
		If !lRet
			EXIT
		EndIf

		TFL->(DbSkip())
	EndDo
EndIf

FwRestRows(aSaveRows,oMdRes)
RestArea(aAreaBLQ)
Return lRet
//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870GetRE()
Busca o conteúdo da variável estática da revisao do contrato,
evitando assim, a declaração de variáveis Private.
@sample     AT870GetRE(_aRevisao_)
@return     _aRevisao_: array( <lrevisao>, <tipo da revisao> )
@author     totvs
@since      23/06/2015
@version    P12
/*/
//-----------------------------------------------------------------------------------------
Function AT870GetRE()

Return( _aRevisao_ )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870SetRE
Guarda o conteúdo da variável estática da revisao do contrato,
evitando assim, a declaração de variáveis Private.
@sample        AT870SetRE( aRevisao )
@param         aRevisao, Array, Array da revisão
@return        NIL
@author        rogerio.souza
@since         23/06/2015
@version       11.9
@description
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT870SetRE( aRevisao )
_aRevisao_ := aRevisao
Return


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870GETVT()
Guarda o conteúdo da variável estática da revisao do contrato,
evitando assim, a declaração de variáveis Private.
@sample     AT870GETVT(cTipo)
@return     cTipo: caracter 1=Vistoria Tecnica 2=Material de Implantacao 3=Material de Consumo
@author     totvs
@since      23/06/2015
@version    P12
/*/
//-----------------------------------------------------------------------------------------
Function AT870GETVT(cTipo)
Local lRet := .T.

Do Case
	Case cTipo == '1'
		lRet := lViTc740
	Case cTipo == '2'
		lRet := lMtImp
	Case cTipo == '3'
		lRet := lMtCns
EndCase
Return( lRet )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870SetVT
@sample        AT870SetVT(cTipo,lValor)
@param         cTipo, caracter
@param         lValor, Lógico
@return        NIL
@author        rogerio.souza
@since         23/06/2015
@version       11.9
@description
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT870SetVT(cTipo,lValor)

Do Case
	Case cTipo == '1'
		lViTc740 := lValor
	Case cTipo == '2'
		lMtImp := lValor
	Case cTipo == '3'
		lMtCns := lValor
EndCase
Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870ViCtr
@since 23/11/2015
@version 12
@param cCodTFJ, Codigo do orçamento de serviços
@description Realiza a visualização do contrato do GCT
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870ViCtr(cCodTFJ)

Local aArea 	:= {}

DbSelectArea("TFJ")
TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
aArea := TFJ->(GetArea())

DbSelectArea("CN9")
CN9->(DbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA

If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ)) .And. CN9->( DbSeek( xFilial("CN9")+TFJ->(TFJ_CONTRT+TFJ_CONREV) ) )
	Inclui := .F.
	Altera := .F.
	CN300Visua()
Else
	Help( ' ', 1, "At870ViCtr", , STR0069, 1, 0 )	// "Orçamento de Serviços ou contrato do GCT não localizado"
EndIf

TFJ->(RestArea(aArea))
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At870EncPo(cContrato, cRevisao)
Interface para encerramento do posto
@sample     At870EncPo(cContrato, cRevisao)
@return
@author     serviços
@since      25/08/2015
@version    P12
/*/
//-----------------------------------------------------------------------------------------
Function At870EncPo(cContrato,cRevisao,oBrowse,cAliasPro,lAutomato,cMsg,nTotal)

Local oModel	:= Nil
Local aArea := GetArea()
Local lRet		:= .F.
Local aPreEnce := {}
Local aPosEnce := {}
Local aMsgs	:= {}
Local cCodTFJ := ""
Local nX
Local nY
Local nRecAux
Local nOrc := 0
Local nMed := 0
Local nEnces := 0
Local cPict := PesqPict("TFF","TFF_PRCVEN")

Default cMsg := ""
Default nTotal := 0
Default lAutomato := .F.

//Foi necessario abrir o SX3
DbSelectArea("SX3")
SX3->(DbSetOrder(1))

If lAutomato
	TFJ->(dbSetOrder(5))//TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	If TFJ->(dbSeek(xFilial("TFJ")+cContrato+cRevisao))


	    If TFJ->TFJ_STATUS <> DEF_TFJ_ATIVO  .OR. at870InRev(TFJ->TFJ_CONTRT )
	    	Help( ' ', 1, "At870EncPo", , STR0270, 1, 0 )	//"Só é possível encerrar posto com orçamento de serviços ativos e que não estejam em revisão."
		Else
			lRet := .T.

		EndIf
	EndIf
Else

	If (cAliasPro)->TFJ_STATUS  <> DEF_TFJ_ATIVO  .OR. at870InRev((cAliasPro)->TFJ_CONTRT)
	    Help( ' ', 1, "At870EncPo", , STR0270, 1, 0 )	//"Só é possível encerrar posto com orçamento de serviços ativos e que não estejam em revisão."
	Else
		DbSelectArea("TFJ")
		TFJ->(DbSetOrder(5))//TFJ_CONTRTL+TFJ_CONREV
		If TFJ->(DbSeek(xFilial("TFJ")+cContrato+cRevisao))
			cCodTFJ := TFJ->TFJ_CODIGO
			aPreEnce := At870gEnce(cCodTFJ)
			If isBlind()
				If FindFunction("AT870TEnce")
					lRet := AT870TEnce()
				EndIf
			Else
				lRet := FWExecView( STR0079, "VIEWDEF.TECA871", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/,	{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ ) == 0//"Encerramento do Posto"
			EndIf
			If lRet
				aPosEnce := At870gEnce(cCodTFJ)

				For nX := 1 to Len(aPosEnce)
					If aPosEnce[nX][2] == '1'
						nEnces++
					EndIf
				Next

				If nEnces != LEN(aPosEnce) .AND. TECdiffArr(aPreEnce, aPosEnce)
					/*
						array itens encerrados:
							[1] R_E_C_N_O_ da TFL
							[2] TFL_ENCE (1 = Sim , Else = Não )
							[3] R_E_C_N_O_ da TFF
							[4] TFF_ENCE (1 = Sim , Else = Não )
							[5] R_E_C_N_O_ da TFI
							[6] TFI_ENCE (1 = Sim , Else = Não )
							[7] Bool que indica se a TFL já foi processada (.T. = Sim ; .F. = Não)
							[8] Bool que indica se a TFF já foi processada (.T. = Sim ; .F. = Não)
							[9] Bool que indica se a TFI já foi processada (.T. = Sim ; .F. = Não)
					*/
					For nX := 1 To LEN(aPosEnce)

						IIF(VALTYPE(aPosEnce[nX][2]) != "C", aPosEnce[nX][2] := "",)
						IIF(VALTYPE(aPosEnce[nX][4]) != "C", aPosEnce[nX][4] := "",)
						IIF(VALTYPE(aPosEnce[nX][6]) != "C", aPosEnce[nX][6] := "",)

						IIF(VALTYPE(aPosEnce[nX][1]) != "N", aPosEnce[nX][1] := 0,)
						IIF(VALTYPE(aPosEnce[nX][3]) != "N", aPosEnce[nX][3] := 0,)
						IIF(VALTYPE(aPosEnce[nX][5]) != "N", aPosEnce[nX][5] := 0,)

						If ( EMPTY(aPreEnce[nX][2]) .OR. aPreEnce[nX][2] == "2" ) .AND. aPosEnce[nX][2] == "1"
							If !(aPosEnce[nX][7])
								//Encerrou uma TFL
								nOrc := At871TotVl("TFL",aPosEnce[nX][1])
								nMed := At871TotMd("TFL",aPosEnce[nX][1])

								DbSelectArea("TFL")
								DbGoTo(aPosEnce[nX][1])

								AADD(aMsgs, {1,;
									STR0219 + TFL->TFL_PLAN + ";" + CRLF +;
									STR0220 + STR0221 + TFL->TFL_LOCAL + " (" +;
												ALLTRIM(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_DESCRI")) + ");" + CRLF + ;
									STR0222 + STR0223 + ";" + CRLF +;
									STR0224 + STR0225 + ";" + CRLF +;
									STR0226 + ALLTRIM(Transform(nOrc, cPict)) + ";" + CRLF +;
									STR0227 + ALLTRIM(Transform(nMed, cPict)) + ";" + CRLF +;
									STR0228 + "-" + ALLTRIM(Transform( nOrc - nMed, cPict))})

								nTotal -= (nOrc - nMed)

								//		Por se tratar de um LEFT JOIN, todos os itens de um Local de Atendimento
								//	possuem a informação que aquela TFL foi encerrada/ativada. O tratamento abaixo
								//	faz com que o log de TFL seja cálculado apenas uma vez

								nRecAux := aPosEnce[nX][1]
								For nY := 1 To LEN(aPosEnce)
									If aPosEnce[nY][1] == nRecAux
										aPosEnce[nY][7] := .T.
									EndIf
								Next
							EndIf
						ElseIf aPreEnce[nX][2] == "1" .AND. aPosEnce[nX][2] == "2" .AND. (At871ChkAr(aPreEnce, aPosEnce, aPosEnce[nX][1]))
							//A função At871ChkAr trata a situação de "desencerrar" um local de atendimento mas manter encerrado um dos seus filhos

							/*
								#define STR0219 "Planilha: "
								#define STR0220 "Item do Orçamento: "
								#define STR0221 "Local de Atendimento: "
								#define STR0222 "Situação anterior: "
								#define STR0223 "Ativo"
								#define STR0224 "Nova situação: "
								#define STR0225 "Encerrado"
								#define STR0226 "Total orçado do item: R$ "
								#define STR0227 "Total apurado do item: R$ "
								#define STR0228 "Alteração sugerida na planilha do contrato: R$ "
								#define STR0229 "Número do Item: "
								#define STR0230 "Recursos Humanos: "
								#define STR0231 "Função do atendente: "
								#define STR0232 "Locação de Equipamentos: "
							*/

							If !(aPosEnce[nX][7])
								//"Desencerrou" uma TFL
								nOrc := At871TotVl("TFL",aPosEnce[nX][1])
								nMed := At871TotMd("TFL",aPosEnce[nX][1])

								DbSelectArea("TFL")
								DbGoTo(aPosEnce[nX][1])

								AADD(aMsgs, {1,;
									STR0219 + TFL->TFL_PLAN + ";" + CRLF +;
									STR0220 + STR0221 + TFL->TFL_LOCAL + " (" +;
												ALLTRIM(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_DESCRI")) + ");" + CRLF + ;
									STR0222 + STR0225 + ";" + CRLF +;
									STR0224 + STR0223 + ";" + CRLF +;
									STR0226 + ALLTRIM(Transform(nOrc, cPict)) + ";" + CRLF +;
									STR0227 + ALLTRIM(Transform(nMed, cPict)) + ";" + CRLF +;
									STR0228 + "+" + ALLTRIM(Transform( nOrc - nMed, cPict))})

								nTotal += (nOrc - nMed)

								nRecAux := aPosEnce[nX][1]
								For nY := 1 To LEN(aPosEnce)
									If aPosEnce[nY][1] == nRecAux
										aPosEnce[nY][7] := .T.
									EndIf
								Next
							EndIf
						Else
							If ( EMPTY(aPreEnce[nX][4]) .OR. aPreEnce[nX][4] == "2" ) .AND. aPosEnce[nX][4] == "1" .AND. !(aPosEnce[nX][8])
								//Encerrou uma TFF
								nOrc := At871TotVl("TFF",aPosEnce[nX][3])
								nMed := At871TotMd("TFF",aPosEnce[nX][3])

								DbSelectArea("TFL")
								DbGoTo(aPosEnce[nX][1])

								DBSelectArea("TFF")
								DbGoTo(aPosEnce[nX][3])

								AADD(aMsgs, {2,;
									STR0219 + TFL->TFL_PLAN + ";" + CRLF +;
									STR0220 + STR0230 + TFF->TFF_PRODUT + " (" +;
												ALLTRIM(Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")) + ");" + CRLF + ;
									STR0229 + TFF->TFF_ITEM + ";" + CRLF +;
									STR0231 + TFF->TFF_FUNCAO + " (" +;
												ALLTRIM(Posicione("SRJ",1,xFilial("SRJ")+TFF->TFF_FUNCAO,"RJ_DESC")) + ");" + CRLF +;
									STR0222 + STR0223 + ";" + CRLF +;
									STR0224 + STR0225 + ";" + CRLF +;
									STR0226 + ALLTRIM(Transform(nOrc, cPict)) + ";" + CRLF +;
									STR0227 + ALLTRIM(Transform(nMed, cPict)) + ";" + CRLF +;
									STR0228 + "-" + ALLTRIM(Transform( nOrc - nMed, cPict))})

								nTotal -= (nOrc - nMed)

								nRecAux := aPosEnce[nX][3]
								For nY := 1 To LEN(aPosEnce)
									If aPosEnce[nY][3] == nRecAux
										aPosEnce[nY][8] := .T.
									EndIf
								Next

							ElseIf aPreEnce[nX][4] == "1" .AND. aPosEnce[nX][4] == "2" .AND. !(aPosEnce[nX][8])
								//"Desencerrou" uma TFF
								nOrc := At871TotVl("TFF",aPosEnce[nX][3])
								nMed := At871TotMd("TFF",aPosEnce[nX][3])

								DbSelectArea("TFL")
								DbGoTo(aPosEnce[nX][1])

								DBSelectArea("TFF")
								DbGoTo(aPosEnce[nX][3])

								AADD(aMsgs, {2,;
									STR0219 + TFL->TFL_PLAN + ";" + CRLF +;
									STR0220 + STR0230 + TFF->TFF_PRODUT + " (" +;
												ALLTRIM(Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")) + ");" + CRLF + ;
									STR0229 + TFF->TFF_ITEM + ";" + CRLF +;
									STR0231 + TFF->TFF_FUNCAO + " (" +;
												ALLTRIM(Posicione("SRJ",1,xFilial("SRJ")+TFF->TFF_FUNCAO,"RJ_DESC")) + ");" + CRLF +;
									STR0222 + STR0225 + ";" + CRLF +;
									STR0224 + STR0223 + ";" + CRLF +;
									STR0226 + ALLTRIM(Transform(nOrc, cPict)) + ";" + CRLF +;
									STR0227 + ALLTRIM(Transform(nMed, cPict)) + ";" + CRLF +;
									STR0228 + "+" + ALLTRIM(Transform( nOrc - nMed, cPict))})

								nTotal += (nOrc - nMed)

								nRecAux := aPosEnce[nX][3]
								For nY := 1 To LEN(aPosEnce)
									If aPosEnce[nY][3] == nRecAux
										aPosEnce[nY][8] := .T.
									EndIf
								Next

							EndIf

							If ( EMPTY(aPreEnce[nX][6]) .OR. aPreEnce[nX][6] == "2" ) .AND. aPosEnce[nX][6] == "1" .AND. !(aPosEnce[nX][9])
								//Encerrou uma TFI
								nOrc := At871TotVl("TFI",aPosEnce[nX][5])
								nMed := At871TotMd("TFI",aPosEnce[nX][5])

								DbSelectArea("TFL")
								DbGoTo(aPosEnce[nX][1])

								DBSelectArea("TFI")
								DbGoTo(aPosEnce[nX][5])

								AADD(aMsgs, {3,;
									STR0219 + TFL->TFL_PLAN + ";" + CRLF +;
									STR0220 + STR0232 + TFI->TFI_PRODUT + " (" +;
												ALLTRIM(Posicione("SB1",1,xFilial("SB1")+TFI->TFI_PRODUT,"B1_DESC")) + ");" + CRLF + ;
									STR0229 + TFI->TFI_ITEM + ";" + CRLF +;
									STR0222 + STR0223 + ";" + CRLF +;
									STR0224 + STR0225 + ";" + CRLF +;
									STR0226 + ALLTRIM(Transform(nOrc, cPict)) + ";" + CRLF +;
									STR0227 + ALLTRIM(Transform(nMed, cPict)) + ";" + CRLF +;
									STR0228 + "-" + ALLTRIM(Transform( nOrc - nMed, cPict))})

								nTotal -= (nOrc - nMed)

								nRecAux := aPosEnce[nX][5]
								For nY := 1 To LEN(aPosEnce)
									If aPosEnce[nY][5] == nRecAux
										aPosEnce[nY][9] := .T.
									EndIf
								Next

							ElseIf aPreEnce[nX][6] == "1" .AND. aPosEnce[nX][6] == "2" .AND. !(aPosEnce[nX][9])
								//"Desencerrou" uma TFI
								nOrc := At871TotVl("TFI",aPosEnce[nX][5])
								nMed := At871TotMd("TFI",aPosEnce[nX][5])

								DbSelectArea("TFL")
								DbGoTo(aPosEnce[nX][1])

								DBSelectArea("TFI")
								DbGoTo(aPosEnce[nX][5])

								AADD(aMsgs, {3,;
									STR0219 + TFL->TFL_PLAN + ";" + CRLF +;
									STR0220 + STR0232 + TFI->TFI_PRODUT + " (" +;
												ALLTRIM(Posicione("SB1",1,xFilial("SB1")+TFI->TFI_PRODUT,"B1_DESC")) + ");" + CRLF + ;
									STR0229 + TFI->TFI_ITEM + ";" + CRLF +;
									STR0222 + STR0225 + ";" + CRLF +;
									STR0224 + STR0223 + ";" + CRLF +;
									STR0226 + ALLTRIM(Transform(nOrc, cPict)) + ";" + CRLF +;
									STR0227 + ALLTRIM(Transform(nMed, cPict)) + ";" + CRLF +;
									STR0228 + "+" + ALLTRIM(Transform( nOrc - nMed, cPict))})
								nTotal += (nOrc - nMed)

								nRecAux := aPosEnce[nX][5]
								For nY := 1 To LEN(aPosEnce)
									If aPosEnce[nY][5] == nRecAux
										aPosEnce[nY][9] := .T.
									EndIf
								Next

							EndIf
						EndIf
					Next
					If !(Empty(aMsgs))
						aSort( aMsgs, , , {|x,y| x[1] < y[1] })
						For nX := 1 To Len(aMsgs)
							cMsg += aMsgs[nX][2] + CRLF + IIF(nX < Len(aMsgs) ,REPLICATE("-",15) + CRLF, CRLF)
						Next
						If !IsBlind()
							AtShowLog(cMsg + REPLICATE("-*", 25) + CRLF + CRLF + CRLF +;
								STR0233 + ALLTRIM(Transform(nTotal, cPict)),STR0234) //"Alteração total sugerida: R$ " # "Encerramento do Posto"
							If MsgYesNo(STR0235) //"Deseja realizar a Revisão do contrato?"
								RestArea(aArea)
								At870PRev(cCodTFJ,cContrato,cRevisao)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			//atualiza o browse com o novo status
			If !isBlind()
				At870AtuBrw(oBrowse)
			EndIf
		Else
			MsgStop(STR0069)//"Registro não encontrado
		Endif
	EndIf
Endif
Return lRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Sep
@author Rogerio Melonio
@since 31/03/2016
@version 12.7
@return lRet, Verdadeiro caso campos estejam OK
@description
Realiza verificação de itens de locação separados
/*/
//-------------------------------------------------------------------------------------
Static Function At870Sep(cCodTFJ, lNoHelp)

Local lRet := .T.
Local cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry
	SELECT  TEW.TEW_FILIAL, TEW.TEW_CODMV, TFI.TFI_CODSUB, TEW.TEW_BAATD, TFI_CODPAI
			FROM %Table:TEW% TEW

			INNER JOIN %Table:TFI% TFI ON
				TEW.TEW_FILIAL = TFI.TFI_FILIAL AND
				TEW.TEW_CODEQU = TFI.TFI_COD AND
				TFI.%notDel%

			INNER JOIN %Table:TFL% TFL ON
				TFI.TFI_FILIAL = TFL.TFL_FILIAL AND
				TFI.TFI_CODPAI = TFL.TFL_CODIGO AND
				TFL.TFL_CODPAI = %Exp:cCodTFJ% AND
				TFL.%notDel%
		WHERE
			TEW.TEW_FILIAL = %xFilial:TEW% AND
			TEW.TEW_BAATD <> '' AND
			TEW.%notDel%
EndSql

If (cAliasQry)->(!EOF())
	lRet := .F.
	If lNoHelp
		AutoGrLog( STR0095 + " / " + STR0096 )	// "Contrato com Separação"#"Não é possivel revisar contrato que já teve separação de equipamento."
	Else
		Help( ' ', 1, STR0095 , , STR0096, 1, 0 )	//"Contrato com Separação"#"Não é possivel revisar contrato que já teve separação de equipamento."
	EndIf
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At870NwSit(cNumContr, cRevContr, cNewStaGS, lConfirm)
@description Realiza a troca do status (nova situação) do orçamento de serviços
@sample       At870NwSit(cNumContr, cRevContr, cNewStaGS, lConfirm)
@param        cNumContr:  Número do contrato
@param        cRevContr:  Revisão do contrato
@param        cNewStaGS:  Novo status para o orçamento de serviços
@param        lConfirm:   .T.=Solicita confirmação do usuário para efetivar a operação // .F.=Não solicita confirmação do usuário para efetivar a operação
@return       .T.=Atualização da nova situação do Orçamento de Serviços ocorreu com sucesso // .F.=A atualização da nova situação do Orçamento de Serviços não ocorreu
@author       Alexandre da Costa
@since        29/03/2016
@version      P12
/*/
//-----------------------------------------------------------------------------------------
Function At870NwSit(cNumContr, cRevContr, cNewStaGS, lConfirm, lAutomato)

Local	aOldArea	:=	If(Select(Alias()) > 0, (Alias())->(GetArea()), {})
Local	aOldTFJ	:=	TFJ->(GetArea())
Local	aOldCN9	:=	CN9->(GetArea())
Local	cFilTFJ	:=	xFilial("TFJ")
Local	cFilCN9	:=	xFilial("CN9")
Local	cSituacGCT	:=	""
Local	lEfetNwSta	:=	.T.
Local	lRet		:=	.F.

Default	cNewStaGS	:= ""
Default	lConfirm	:= .T.
Default lAutomato	:= .F.

If	! Empty(cNumContr) .And. ! Empty(cNewStaGS)

	TFJ->(DbSetOrder(5))	//TFJ_FILIAL+TFJ_CONTRTL+TFJ_CONREV
	TFJ->(DbSeek(cFilTFJ+cNumContr+cRevContr))
	cSituacGCT := Posicione("CN9",1,cFilCN9+cNumContr+cRevContr,"CN9_SITUAC")

	Do	Case
		Case	cNewStaGS == DEF_TFJ_CANCELADO

			If	TFJ->TFJ_STATUS == DEF_TFJ_CANCELADO
				Help(,,"At870NwSit",, STR0084, 1, 0)	//"O orçamento de serviços já encontra-se cancelado."
				lRet	:= .F.
			ElseIf	TFJ->TFJ_STATUS == DEF_TFJ_ENCERRADO
				Help(,,"At870NwSit",, STR0085, 1, 0)	//"O orçamento de serviços já encontra-se encerrado."
				lRet	:= .F.
			Else
				If	cSituacGCT	== DEF_SELAB //01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
					If	lConfirm .And. !( IIF (!lAutomato , MsgYesNo(STR0082), .T.) ) //"Deseja efetivar o cancelamento do Orçamento de Serviços?"
						lEfetNwSta	:=	.F.
						lRet		:=	.F.
					EndIf
					If	lEfetNwSta
						If	( lRet := CN100SitCh( cNumContr, cRevContr, DEF_SCANC, "" ) )	// Atualiza o status do contrato no GCT como CANCELADO
							TFJ->(RecLock("TFJ",.F.))
							TFJ->TFJ_STATUS := DEF_TFJ_CANCELADO
							TFJ->(MsUnLock())
							If !Empty(TFJ->TFJ_GRPCOM)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³SIGATEC WorkFlow # CT - Interações de Contratos Cancelamento		 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								At774Mail("TFJ",TFJ->TFJ_GRPCOM,"CT","<b>"+STR0106+"</b> "+TFJ->TFJ_PROPOS+"<b> "+STR0107+"</b>"+TFJ->TFJ_CONTRT,"RED",STR0112) //"Num. Proposta: " # "Nr. Contrato: " # "Cancelamento"
							Endif
						EndIf
					EndIf
				Else
					Help(,,"At870NwSit",, STR0083, 1, 0)	//"É permitido o cancelamento de um orçamento de serviços somente quando o contrato a ele associado estiver em elaboração"
					lRet	:= .F.
				EndIf
			EndIf

		Case	cNewStaGS == DEF_TFJ_ENCERRADO

			If	TFJ->TFJ_STATUS == DEF_TFJ_CANCELADO
				Help(,,"At870NwSit",, STR0084, 1, 0)	//"O orçamento de serviços já encontra-se cancelado."
				lRet	:= .F.
			ElseIf	TFJ->TFJ_STATUS == DEF_TFJ_ENCERRADO
				Help(,,"At870NwSit",, STR0085, 1, 0)	//"O orçamento de serviços já encontra-se encerrado."
				lRet	:= .F.
			Else
				If	lConfirm .And. !( MsgYesNo(STR0086) ) //"Deseja efetivar o encerramento do Orçamento de Serviços?"
					lEfetNwSta	:=	.F.
					lRet		:=	.F.
				EndIf
				If	lEfetNwSta
					If	( IIF( !lAutomato .AND. !IsBlind(), lRet := MsgYesNo(STR0271,STR0272), .T.) .And. (lRet := CN100SitCh( cNumContr, cRevContr, DEF_SFINA, "" )) )	// "A solicitação de encerramento está encerrando todos os postos. Ao confirmar, o contrato também será encerrado e esta operação não pode ser desfeita. Deseja contiunar?"##"Encerramento do Posto"##Atualiza o status do contrato no GCT como FINALIZADO
						TFJ->(RecLock("TFJ",.F.))
						TFJ->TFJ_STATUS := DEF_TFJ_ENCERRADO
						TFJ->(MsUnLock())
					EndIf
				EndIf
			EndIf

	EndCase
EndIf

RestArea(aOldCN9)
RestArea(aOldTFJ)
If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Conf()
@description Exibe a tela para a cofirmação da data de entrega e coleta do equipamento.
@sample       At870Conf(cCodTFJ)
@param        cCodTFJ:  Codigo do Orçamento de Serviços
@author       Kaique Schiller
@since        24/05/2016
@version      P12
/*/
//-----------------------------------------------------------------------------------------
Function At870Conf(cCodTFJ,cAliasPro,lAutomato)

Default lAutomato := .F.

If !lAutomato
	If (cAliasPro)->TFJ_STATUS == DEF_TFJ_ENCERRADO .OR. (cAliasPro)->TFJ_STATUS == DEF_TFJ_CANCELADO //Cancelado ## Encerrado
		Help(,, "At870Conf",,STR0104,1,0,,,,,,{STR0105+CRLF+STR0007+CRLF+STR0040+CRLF+STR0008+CRLF+STR0041+CRLF+STR0030})// "Não é permetido realizar a confirmação de entrega/coleta." ## "Os status permitidos são:" ## "Ativo" ## "Revisado" ## "Em revisão" ## "Aguardando aprovação" ## "Contrato em elaboração"
	Else
		DbSelectArea("TFJ")
		TFJ->(dbSetOrder(1))
		If TFJ->(dbSeek(xFilial("TFJ")+cCodTFJ))
			TECA743()
		EndIf
	EndIf
Else
	DbSelectArea("TFJ")
	TFJ->(dbSetOrder(1))
	If TFJ->(dbSeek(xFilial("TFJ")+cCodTFJ))
		If TFJ->TFJ_STATUS == DEF_TFJ_ENCERRADO .OR. TFJ->TFJ_STATUS == DEF_TFJ_CANCELADO //Cancelado ## Encerrado
			Help(,, "At870Conf",,STR0104,1,0,,,,,,{STR0105+CRLF+STR0007+CRLF+STR0040+CRLF+STR0008+CRLF+STR0041+CRLF+STR0030}) //"Não é permetido realizar a confirmação de entrega/coleta."|"Os status permitidos são:"|"Ativo"|"Revisado"|"Em revisão"|"Aguardando aprovação"|"Contrato em elaboração"
		EndIf
	EndIf
EndIf

Return

/*/{Protheus.doc} At870EspCtr

@since 12/05/2015
@version 12

@param cCodTpRev, character Código do Tipo de revisão

@description
Busca através do tipo da revisão a especie

/*/
Function At870EspCtr(cCodTpRev,cAcao,cCampo)

Local aAreaCN0	:= GetArea()
Local lRet		:= .F.

DbSelectArea("CN0")
CN0->(DbSetOrder(1))//CN0_FILIAL+CN0_CODIGO
If CN0->(DbSeek(xFilial("CN0")+cCodTpRev))
	If (cAcao == "CANSETVALUE" .Or. cAcao == "SETVALUE") .And. cCampo == "TFI_PERFIM" .And. CN0->CN0_ESPEC == "3"
		lRet := .T.
	EndIf
EndIf

RestArea(aAreaCN0)

Return lRet

/*/{Protheus.doc} At870LocAnt
@since 21/01/2015
@version 11.9
@param cCodAtual, Codigo atual do item na tabela TFL
@description Função para retornar o recno anterior do item do local
/*/
Static Function At870LocAnt( cCodAtual, cCodTfj )

Local nRecno := 0
Local cSqlArea := GetNextAlias()

Local aArea := GetArea()
Local aAreaTFL := TFL->(GetArea())

If AT870CtRev(cCodTfj)
	BeginSql Alias cSqlArea

		SELECT R_E_C_N_O_ TFLRECNO
		FROM %Table:TFL% TFL
		WHERE TFL.%NotDel% AND TFL_FILIAL = %xFilial:TFL% AND TFL_CODIGO = %Exp:cCodAtual%

	EndSql
Else
	BeginSql Alias cSqlArea

		SELECT R_E_C_N_O_ TFLRECNO
		FROM %Table:TFL% TFL
		WHERE TFL.%NotDel% AND TFL_FILIAL = %xFilial:TFL% AND TFL_CODSUB = %Exp:cCodAtual%

	EndSql
EndIf

If (cSqlArea)->(!EOF())
	nRecno := (cSqlArea)->TFLRECNO
EndIf

(cSqlArea)->(DbCloSeArea())

RestArea(aAreaTFL)
RestArea(aArea)

Return nRecno

/*/{Protheus.doc} At870ValOld
@since 06/02/2015
@version 11.9
@param nRecTFL, registro da TFL a ser utilizado para identificação do conteúdo
@param nValRH, referência, valor do item de RH para retorno
@param nValMI, referência, valor do item de MI para retorno
@param nValMC, referência, valor do item de MC para retorno
@param nValLE, referência, valor do item de LE para retorno
@description Função para retornar o recno anterior do item do local
/*/
Function At870ValOld( nRecTFL, nValRH, nValMI, nValMC, nValLE )

Local cTmpTFL 		:= GetNextAlias()
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local cOrcPrc 		:= If(lOrcPrc, "1", "0" )
Local lSomaImp 		:= SuperGetMv("MV_ATOPIMP",,.T.)

BeginSQL Alias cTmpTFL

SELECT
	TFL_CODIGO
	, TFL_TOTIMP
	, ( SELECT COALESCE( SUM ( ( TFF_QTDVEN * TFF_PRCVEN) - TFF_VALDES + TFF_ADM + TFF_LUCRO ), 0)
				FROM %Table:TFF% TFF
				WHERE TFF_FILIAL = %xFilial:TFF% AND TFF_CODPAI = TFL_CODIGO AND TFF_COBCTR <> '2' AND TFF.%NotDel%
	) TOTRH
	, ( SELECT COALESCE( SUM( (TFG_QTDVEN * TFG_PRCVEN) - TFG_VALDES + TFG_ADM + TFG_LUCRO), 0 )
				FROM %Table:TFG% TFG
					LEFT JOIN %Table:TFF% TFF ON '0' = %Exp:cOrcPrc% AND TFF_FILIAL = %xFilial:TFF% AND TFF_CODPAI = TFL_CODIGO
						AND TFF_COBCTR <> '2' AND TFF.%NotDel%
				WHERE TFG_FILIAL = %xFilial:TFG% AND ( ( '0' = %Exp:cOrcPrc% AND TFG_CODPAI = TFF_COD ) OR ( '1' = %Exp:cOrcPrc% AND TFG_CODPAI = TFL_CODIGO) )
						AND TFG_COBCTR <> '2' AND TFG.%NotDel%
	) TOTMI
	, ( SELECT COALESCE( SUM( (TFH_QTDVEN * TFH_PRCVEN) - TFH_VALDES + TFH_ADM + TFH_LUCRO), 0 )
				FROM %Table:TFH% TFH
					LEFT JOIN %Table:TFF% TFF ON '0' = %Exp:cOrcPrc% AND TFF_FILIAL = %xFilial:TFF%
						AND TFF_CODPAI = TFL_CODIGO AND TFF_COBCTR <> '2' AND TFF.%NotDel%
				WHERE TFH_FILIAL = %xFilial:TFH% AND ( ( '0' = %Exp:cOrcPrc% AND TFH_CODPAI = TFF_COD ) OR ( '1' = %Exp:cOrcPrc% AND TFH_CODPAI = TFL_CODIGO) )
						AND TFH_COBCTR <> '2' AND TFH.%NotDel%
	) TOTMC
	, ( SELECT COALESCE( SUM( TFI_TOTAL ), 0 )
				FROM %Table:TFI% TFI
				WHERE TFI_FILIAL = %xFilial:TFI% AND TFI_CODPAI = TFL_CODIGO AND TFI.%NotDel%
	) TOTLE
FROM %Table:TFL% TFL
WHERE TFL.R_E_C_N_O_ = %Exp:nRecTFL% AND TFL.%NotDel%

EndSql

If (cTmpTFL)->(!EOF())

	nValRH := (cTmpTFL)->TOTRH
	nValMI := (cTmpTFL)->TOTMI
	nValMC := (cTmpTFL)->TOTMC
	nValLE := (cTmpTFL)->TOTLE

	If lOrcPrc .And. lSomaImp
		nValRH += (cTmpTFL)->TFL_TOTIMP
	EndIf
EndIf

(cTmpTFL)->(DbCloseArea())
Return

/*/{Protheus.doc} At870ValNew
@description Função para retornar o recno anterior do item do local
@since 21/01/2015
@version 11.9
@param oMdlGeral, modelo principal do mvc para
@param nLinGrid, Codigo atual do item na tabela TFL
@param nValRH, referência, valor do item de RH para retorno
@param nValMI, referência, valor do item de MI para retorno
@param nValMC, referência, valor do item de MC para retorno
@param nValLE, referência, valor do item de LE para retorno
/*/
Function At870ValNew( oMdlGeral, nLinGrid, nValRH, nValMI, nValMC, nValLE )

Local aSaveRows := FwSaveRows( oMdlGeral )
Local oAuxTFL 	:= oMdlGeral:GetModel("TFL_LOC")
Local oAuxTFF 	:= oMdlGeral:GetModel("TFF_RH")
Local oAuxTFG 	:= oMdlGeral:GetModel("TFG_MI")
Local oAuxTFH 	:= oMdlGeral:GetModel("TFH_MC")
Local oAuxTFI 	:= oMdlGeral:GetModel("TFI_LE")
Local nLinRH 	:= 0
Local nLinMI 	:= 0
Local nLinMC 	:= 0
Local nLinLE 	:= 0
Local lOrcPrc 	:= SuperGetMV("MV_ORCPRC",,.F.)
Local lSomaImp 	:= SuperGetMv("MV_ATOPIMP",,.T.)

nValRH := 0
nValMI := 0
nValMC := 0
nValLE := 0

oAuxTFL:GoLine(nLinGrid)
// varre os itens capturando o valor
For nLinRH := 1 To oAuxTFF:Length()
	oAuxTFF:GoLine(nLinRH)

	If oAuxTFF:GetValue("TFF_COBCTR") <> "2" .AND. !EMPTY(oAuxTFF:GetValue("TFF_PRODUT"))
		nValRH += ( oAuxTFF:GetValue("TFF_SUBTOT") )
	EndIf

	If !lOrcPrc
		For nLinMI := 1 To oAuxTFG:Length()
			oAuxTFG:GoLine(nLinMI)
			If oAuxTFG:GetValue("TFG_COBCTR") <> "2" .AND. !EMPTY(oAuxTFG:GetValue("TFG_PRODUT"))
				nValMI += ( oAuxTFG:GetValue("TFG_TOTGER") )
			EndIf
		Next nLinMI

		For nLinMC := 1 To oAuxTFH:Length()
			oAuxTFH:GoLine(nLinMC)
			If oAuxTFH:GetValue("TFH_COBCTR") <> "2" .AND. !EMPTY(oAuxTFH:GetValue("TFH_PRODUT"))
				nValMC += ( oAuxTFH:GetValue("TFH_TOTGER") )
			EndIf
		Next nLinMC
	EndIf
Next nLinRH

If lOrcPrc
	For nLinMI := 1 To oAuxTFG:Length()
		oAuxTFG:GoLine(nLinMI)

		If oAuxTFG:GetValue("TFG_COBCTR") <> "2" .AND. !EMPTY(oAuxTFG:GetValue("TFG_PRODUT"))
			nValMI += ( oAuxTFG:GetValue("TFG_TOTGER") )
		EndIf
	Next

	For nLinMC := 1 To oAuxTFH:Length()
		oAuxTFH:GoLine(nLinMC)

		If oAuxTFH:GetValue("TFH_COBCTR") <> "2" .AND. !EMPTY(oAuxTFH:GetValue("TFH_PRODUT"))
			nValMC += ( oAuxTFH:GetValue("TFH_TOTGER") )
		EndIf
	Next
EndIf

For nLinLE := 1 To oAuxTFI:Length()
	oAuxTFI:GoLine(nLinLE)
	nValLE += ( oAuxTFI:GetValue("TFI_TOTAL") )
Next nLinLE

If lOrcPrc .And. lSomaImp
	nValRH += oAuxTFL:GetValue("TFL_TOTIMP")
EndIf

FwRestRows(aSaveRows,oMdlGeral)

Return

/*/{Protheus.doc} At870CNBUpd
	Atualiza os dados no item da planilha considerando a revisão do tipo Renovação
@since 			17.11.2016
@version 		12.15
@param 			oMdlCNB, Objeto, grid da revisão de contratos para atualização das informações de quantidade e valor unitário
@param 			nTotOldGS, Numérico, valor anterior do item no gestão de serviços
@param 			nTotNewGS, Numérico, valor novo do item no gestão de serviços
@return 		Lógico, determina se conseguiu realizar a atualização (verdadeiro) ou não (falso)
/*/
Static Function At870CNBUpd( oMdlCNB, nTotOldGS, nTotNewGS, nNewQtItem, lDelete, cAtualiza, cLocEntida)
Local lRet 			:= .T.
// variáveis para alterar a qtde e refletir na qtde de saldo
Local nQtdItem 		:= oMdlCNB:GetValue("CNB_QUANT")
Local nQtdMed 		:= oMdlCNB:GetValue("CNB_QTDMED")
Local nValTotItem 	:= 0
Local nQtdItemNew 	:= 0
Local nDifItem 		:= 0
Local nTotLinCNB 	:= 0
Local nLineCNB := oMdlCNB:GetLine()
Local nX
Local cProdut := oMdlCNB:GetValue("CNB_PRODUT")
Local nTotMedido := 0
Local nVlrOrg := 0
Local cItemDest := ""
Local nLinCNB := 0
Local oStruCNB := Nil
Local oFieldsCNB := Nil
Local nI := 1
Local AWHENS := {}
Local cCCusto := ""
Local lUpdQtd := .F.

Default nNewQtItem := 1
Default lDelete := .F.
Default cAtualiza := ""

// variáveis para atualizar o valor unitário e refletir o novo valor adicionado no GS

If (nTotNewGS - nTotOldGS) < 0 .AND. IsInCallStack("At870ItAgr") .AND. EMPTY(nQtdMed)
	For nX := 1 to oMdlCNB:Length()
		oMdlCNB:GoLine(nX)
		If oMdlCNB:GetValue("CNB_PRODUT") == cProdut .AND. !EMPTY(oMdlCNB:GetValue("CNB_ITMDST"))
			nTotMedido += oMdlCNB:GetValue("CNB_VLTOT")
		EndIf
	Next
	oMdlCNB:GoLine(nLineCNB)
EndIf

nDifItem := nTotNewGS - nTotOldGS
If nDifItem <> 0
	If !EMPTY(nTotMedido) .AND. EMPTY(nQtdMed)
		nValTotItem := nTotNewGS - nTotMedido
	Else
		nValTotItem := oMdlCNB:GetValue("CNB_VLTOT") + nDifItem
	EndIf

	FwModelActive( oMdlCNB:GetModel() )

	If nQtdMed > 0
		If IsInCallStack("At870ItAgr")
			nVlrOrg := oMdlCNB:GetValue("CNB_VLTOT")
			nLinCNB := oMdlCNB:GetLine()

			lRet := lRet .And. oMdlCNB:SetValue("CNB_VLUNIT", nValTotItem )

			oMdlCNB:GoLine(nLinCNB)
			nVlrOrg := oMdlCNB:GetValue("CNB_VLTOT")
			cItemDest := oMdlCNB:GetValue("CNB_ITMDST")

			oStruCNB := oMdlCNB:GetStruct()
			oFieldsCNB := oStruCNB:GetFields()

			For nI := 1 To Len(oFieldsCNB)
				Aadd(aWhens,{oFieldsCNB[nI,MODEL_FIELD_IDFIELD],oFieldsCNB[nI,MODEL_FIELD_WHEN]})
			Next nI

			oStruCNB:SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
			oMdlCNB:SeekLine({{"CNB_ITEM", cItemDest}})
			oMdlCNB:SetValue('CNB_QUANT',1)
			oMdlCNB:SetValue('CNB_VLUNIT',oMdlCNB:GetValue('CNB_VLUNIT') - nVlrOrg)

			For nI := 1 To Len(aWhens)
				oStruCNB:SetProperty(aWhens[ni,1],MODEL_FIELD_WHEN,aWhens[ni,2])
			Next nI

			If nTotLinCNB <> oMdlCNB:Length()
				oMdlCNB:GoLine(oMdlCNB:Length())
			EndIf
		ElseIf isInCallStack("At870ItDsAgr")
			nTotLinCNB := oMdlCNB:Length()
			If (lUpdQtd := oMdlCNB:GetValue("CNB_QUANT") != nNewQtItem) .Or. (oMdlCNB:GetValue("CNB_VLUNIT") != (nTotNewGS / nNewQtItem))
				lRet := lRet .And. oMdlCNB:SetValue("CNB_VLUNIT", (nTotNewGS / nNewQtItem))
			Else
				lRet := lRet .And. oMdlCNB:SetValue("CNB_VLUNIT", nValTotItem)
			EndIf
			If nTotLinCNB <> oMdlCNB:Length()
				cItemDest := oMdlCNB:GetValue("CNB_ITMDST")
				While oMdlCNB:SeekLine({{"CNB_ITMDST", cItemDest}})
					nVlrOrg += oMdlCNB:GetValue("CNB_VLTOT")
					cItemDest := oMdlCNB:GetValue("CNB_ITEM")
				EndDo
				oMdlCNB:GoLine(oMdlCNB:Length())
			//	lRet := lRet .And. oMdlCNB:SetValue("CNB_VLUNIT", Round( ((nTotNewGS - nVlrOrg) / nNewQtItem), TamSx3("CNB_VLUNIT")[2] ))
			EndIf
			lRet := lRet .And. oMdlCNB:SetValue("CNB_QUANT", nNewQtItem-nQtdMed)
		EndIf

	Else
		// não refaz o saldo somente o ajusta o novo valor
		//  para isso precisa recalcular o valor unitário usando a quantidade atual

		// verifica se a quantidade sofreu alteração para considerar a geração não agrupada do contrato
		If nNewQtItem <> nQtdItem
			nQtdItemNew := nNewQtItem
			lRet := lRet .And. oMdlCNB:SetValue("CNB_QUANT", nQtdItemNew )
		Else
			nQtdItemNew :=  nQtdItem
		EndIf
		If !lDelete
			lRet := lRet .And. oMdlCNB:SetValue("CNB_VLUNIT", ( nValTotItem / nQtdItemNew ) )
		Else
			lRet := lRet .And. oMdlCNB:DeleteLine()
		EndIf
	EndIf
EndIf

//pega o valor do campo e verifica foi selecionado para atualizar
If cAtualiza == "1" .AND. lRet
	DbSelectArea("ABS")
	ABS->(DbSetOrder(1))
	If ABS->(DbSeek(xFilial("ABS")+cLocEntida))
		If ABS->ABS_CCUSTO <> oMdlCNB:GetValue('CNB_CC')
			lRet := oMdlCNB:SetValue('CNB_CC', ABS->ABS_CCUSTO)
		Endif
		If FindFunction("TecEntCtb") .And. TecEntCtb("ABS")
			If lRet .And. ABS->ABS_CONTA <> oMdlCNB:GetValue('CNB_CONTA')
				lRet := oMdlCNB:SetValue('CNB_CONTA', ABS->ABS_CONTA)
			Endif
			If lRet .And. ABS->ABS_ITEM <> oMdlCNB:GetValue('CNB_ITEMCT')
				lRet := oMdlCNB:SetValue('CNB_ITEMCT', ABS->ABS_ITEM)
			Endif
			If lRet .And. ABS->ABS_CLVL <> oMdlCNB:GetValue('CNB_CLVL')
				lRet := oMdlCNB:SetValue('CNB_CLVL', ABS->ABS_CLVL)
			Endif
		Endif
	Endif
EndIf

Return lRet

/*/{Protheus.doc} At870CNBAdd
@description 	Adiciona um item na planilha considerando a revisão do tipo Renovação
@since 			17.11.2016
@version 		12
@param 			oMdlCNB, Objeto, grid da revisão de contratos para atualização das informações de quantidade e valor unitário
@param 			nTotNewGS, Numérico, valor novo do item no gestão de serviços
@return 		Lógico, determina se conseguiu realizar a atualização (verdadeiro) ou não (falso)
/*/
Static Function At870CNBAdd( oMdlCNB, aDadosCNB  )
Local lRet := .T.
Local nTotLinCNB := oMdlCNB:Length()
Local nPosDados := 0
Local cFldsLoad := "CNB_PRODSV" //campos que devem ser "Load"
Default aDadosCNB := {}

FwModelActive( oMdlCNB:GetModel() )

If nTotLinCNB > 1 .Or. !Empty( oMdlCNB:GetValue("CNB_PRODUT") )
	If oMdlCNB:AddLine() <> (nTotLinCNB + 1)
		lRet := .F.
	EndIf
EndIf

If lRet
	// percorre o array para preencher os dados na CNB
	For nPosDados := 1 To Len(aDadosCNB)
		If aDadosCNB[nPosDados, 1] $ cFldsLoad
			lRet := lRet .And. oMdlCNB:LoadValue( aDadosCNB[nPosDados, 1], aDadosCNB[nPosDados, 2] )
		Else
			lRet := lRet .And. oMdlCNB:SetValue( aDadosCNB[nPosDados, 1], aDadosCNB[nPosDados, 2] )
		EndIf
	Next nPosDados
EndIf

Return lRet

/*/{Protheus.doc} At870AllPrds
@description 	Adiciona um item na planilha considerando a revisão do tipo Renovação
@since 			17.11.2016
@version 		12
@param 			oMdlCNB, Objeto, grid da revisão de contratos para atualização das informações de quantidade e valor unitário
@param 			nTotNewGS, Numérico, valor novo do item no gestão de serviços
@return 		Lógico, determina se conseguiu realizar a atualização (verdadeiro) ou não (falso)
/*/
Static Function At870AllPrds( oModel, lBuscaAnt, cContrt )
Local aItens := {}
Local cCodTFJ	:= oModel:GetValue("TFJ_REFER","TFJ_CODIGO")
Local nX := 0
Local nY := 0
Local nValNew := 0
Local nValOld := 0
Local oMdlLocal := oModel:GetModel("TFL_LOC")
Local oMdlRH := oModel:GetModel("TFF_RH")
Local oMdlMI := oModel:GetModel("TFG_MI")
Local oMdlMC := oModel:GetModel("TFH_MC")
Local oMdlLE := oModel:GetModel("TFI_LE")
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local lGsIss := SuperGetMv("MV_GSISS",,.F.)
Local cPlanilha := oMdlLocal:GetValue("TFL_PLAN")
Local aAreaCNB
Local cIdPed := ""
Local aISSxID := {}

Default lBuscaAnt := .T.
Default cContrt := oMdlRh:GetValue("TFF_CONTRT")

// percorre os itens de recursos humanos
For nX := 1 To oMdlRh:Length()
	oMdlRh:GoLine(nX)

	If !Empty( oMdlRh:GetValue("TFF_PRODUT") ) .And. oMdlRh:GetValue("TFF_COBCTR") <> "2"

		nValNew := oMdlRh:GetValue("TFF_SUBTOT") // >>>> lembrar avaliar se o campo _codsub já foi preenchido neste momento
		nValOld := If( lBuscaAnt, At870OldValue( "TFF", cContrt, oMdlRH:GetValue("TFF_ITEM"), oMdlRH:GetValue("TFF_PRODUT"), oMdlRH:GetValue("TFF_COD"), cCodTFJ),;
								0 )

		aAdd( aItens, { oMdlRh:GetValue("TFF_ITEM"), ;		//1
						oMdlRh:GetValue("TFF_PRODUT"),;		//2
						cPlanilha, ;						//3
						oMdlRh:GetValue("TFF_ITCNB"),;		//4
						nValNew, ;							//5
						nValOld, ;							//6
						oMdlRh:GetValue("TFF_QTDVEN"), ;	//7
						"RH",;								//8
						oMdlRh:GetValue("TFF_TESPED"),;		//9
						"",;								//10
						oMdlRh:GetValue("TFF_PRODUT")})		//11

		If lGsIss .AND. !lOrcPrc
			aAreaCNB := CNB->(GetArea())
			cIdPed := ""
			If !EMPTY(oMdlRh:GetValue("TFF_ITCNB"))
				cIdPed := Posicione("CNB",1,xFilial("CNB")+cContrt+oMdlRh:GetValue("TFF_CONREV")+oMdlLocal:GetValue("TFL_PLAN")+oMdlRh:GetValue("TFF_ITCNB"),"CNB_IDPED")
				AADD(aISSxID, {TECBGetISS(oMdlRh:GetValue("TFF_PRODUT")), cIdPed})
			EndIf
			If EMPTY(cIdPed)
				cIdPed := GetIdPed(cContrt,;
				 			oMdlRh:GetValue("TFF_CONREV"),;
				 			oMdlLocal:GetValue("TFL_PLAN"),;
				 			TECBGetISS(oMdlRh:GetValue("TFF_PRODUT")),;
				 			@aISSxID)
			EndIf
			RestArea(aAreaCNB)
			aItens[LEN(aItens)][10] := cIdPed
		EndIf
	EndIf
	//  pesquisa e adiciona os materiais caso não seja orçamento com precificação
	If !lOrcPrc
		At870GetMats( @aItens, oMdlMI, oMdlMC, lBuscaAnt, cContrt, cPlanilha, oMdlRh:GetValue("TFF_PRODUT"), @aISSxID )
	EndIf

Next nX

//  pesquisa e adiciona os materiais caso seja orçamento com precificação
If lOrcPrc
	At870GetMats( @aItens, oMdlMI, oMdlMC, lBuscaAnt, cContrt, cPlanilha )
EndIf

// percorre os itens de locação de equipamentos
For nX := 1 To oMdlLE:Length()
	oMdlLE:GoLine(nX)

	If !Empty( oMdlLE:GetValue("TFI_PRODUT") )

		nValNew := oMdlLE:GetValue("TFI_TOTAL")
		nValOld := If( lBuscaAnt, At870OldValue( "TFI", cContrt, oMdlLE:GetValue("TFI_ITEM"), oMdlLE:GetValue("TFI_PRODUT"), oMdlLE:GetValue("TFI_COD") ),;
								0 )

		aAdd( aItens, { oMdlLE:GetValue("TFI_ITEM"), ;
						oMdlLE:GetValue("TFI_PRODUT"), ;
						cPlanilha , ;
						oMdlLE:GetValue("TFI_ITCNB"),;
						nValNew, ;
						nValOld,;
						oMdlLE:GetValue("TFI_QTDVEN"), ;
						"LE",;
						oMdlLE:GetValue("TFI_TESPED") } )
	EndIf
Next nX

Return aClone(aItens)

/*/{Protheus.doc} At870GetMats
@description 	Adiciona os itens de materiais, em função separada para ter a chamado com e sem precificação
@since 			18.11.2016
@version 		12
@param 			aItens, Array, dados para uso posterior na atualização da planilha/itens do contrato
@param 			oMdlMI, Objeto, parte do modelo de dados de material de implantação do orçamento de serviços
@param 			oMdlMC, Objeto, parte do modelo de dados de material de consumo do orçamento de serviços
@param 			lBuscaAnt, Lógico, indica se deve ou não pesquisar por valores anteriores dentro
@param 			cContrt, Caracter, Número do contrato ter as informações de materiais resgatadas
/*/
Static Function At870GetMats( aItens, oMdlMI, oMdlMC, lBuscaAnt, cContrt, cPlanilha, cProdSV, aISSxID )
Local nY := 0
Local nValNew := 0
Local nValOld := 0
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local lGsIss := SuperGetMv("MV_GSISS",,.F.)
Local aAreaCNB
Local cIdPed
Local oModel := oMdlMI:GetModel()
Local oMdlLocal := oModel:GetModel("TFL_LOC")
Local oMdlRh := oModel:GetModel("TFF_RH")
Local cCodTFJ	:= oModel:GetValue("TFJ_REFER","TFJ_CODIGO")
Default cProdSV := ""
Default aISSxID := {}

// itens que formam o orçamento de serviços
// considerar também se o item deve ou não ser faturado dentro do contrato

// percorre os itens de materiais de implantação
For nY := 1 To oMdlMI:Length()
	oMdlMI:GoLine(nY)

	If !Empty( oMdlMI:GetValue("TFG_PRODUT") ) .And. oMdlMI:GetValue("TFG_COBCTR") <> "2"
		nValNew := oMdlMI:GetValue("TFG_TOTGER")
		nValOld := If( lBuscaAnt, At870OldValue( "TFG", cContrt, oMdlMI:GetValue("TFG_ITEM"), oMdlMI:GetValue("TFG_PRODUT"), oMdlMI:GetValue("TFG_COD"), cCodTFJ ),;
								0 )

		aAdd( aItens, { oMdlMI:GetValue("TFG_ITEM"), ;		//1
						oMdlMI:GetValue("TFG_PRODUT"), ;	//2
						cPlanilha ,;						//3
						oMdlMI:GetValue("TFG_ITCNB"),;		//4
						nValNew, ;							//5
						nValOld,;							//6
						oMdlMI:GetValue("TFG_QTDVEN"), ;	//7
						"MI",;								//8
						oMdlMI:GetValue("TFG_TESPED"),;		//9
						"",;								//10
						"",;											//11
						IIF(!lOrcPrc,oMdlRh:GetValue("TFF_COD"),"") } )	//12

		If lGsIss .AND. !lOrcPrc .AND. !EMPTY(cProdSV)
			aAreaCNB := CNB->(GetArea())
			cIdPed := ""
			If !EMPTY(oMdlMI:GetValue("TFG_ITCNB"))
				cIdPed := Posicione("CNB",1,xFilial("CNB")+cContrt+oMdlMI:GetValue("TFG_CONREV")+oMdlLocal:GetValue("TFL_PLAN")+oMdlMI:GetValue("TFG_ITCNB"),"CNB_IDPED")
				AADD(aISSxID, {TECBGetISS(cProdSV), cIdPed})
			EndIf
			If EMPTY(cIdPed)
				cIdPed := GetIdPed(cContrt,;
				 			oMdlMI:GetValue("TFG_CONREV"),;
				 			oMdlLocal:GetValue("TFL_PLAN"),;
				 			TECBGetISS(cProdSV),;
				 			@aISSxID)
			EndIf
			RestArea(aAreaCNB)
			aItens[LEN(aItens)][10] := cIdPed
			aItens[LEN(aItens)][11] := cProdSV
		EndIf
	EndIf
Next nY
// percorre os itens de materiais de consumo
For nY := 1 To oMdlMC:Length()
	oMdlMC:GoLine(nY)

	If !Empty( oMdlMC:GetValue("TFH_PRODUT") ) .And. oMdlMC:GetValue("TFH_COBCTR") <> "2"
		nValNew := oMdlMC:GetValue("TFH_TOTGER")
		nValOld := If( lBuscaAnt, At870OldValue( "TFH", cContrt, oMdlMC:GetValue("TFH_ITEM"), oMdlMC:GetValue("TFH_PRODUT"), oMdlMC:GetValue("TFH_COD"), cCodTFJ ),;
								0 )

		aAdd( aItens, { oMdlMC:GetValue("TFH_ITEM"), ;		//1
						oMdlMC:GetValue("TFH_PRODUT"), ;	//2
						cPlanilha ,;						//3
						oMdlMC:GetValue("TFH_ITCNB"),;		//4
						nValNew, ;							//5
						nValOld,;							//6
						oMdlMc:GetValue("TFH_QTDVEN"), ;	//7
						"MC",;								//8
						oMdlMc:GetValue("TFH_TESPED"),;		//9
						"",;								//10
						"",;											//11
						IIF(!lOrcPrc,oMdlRh:GetValue("TFF_COD"),"") } )	//12

		If lGsIss .AND. !lOrcPrc .AND. !EMPTY(cProdSV)
			aAreaCNB := CNB->(GetArea())
			cIdPed := ""
			If !EMPTY(oMdlMc:GetValue("TFH_ITCNB"))
				cIdPed := Posicione("CNB",1,xFilial("CNB")+cContrt+oMdlMc:GetValue("TFH_CONREV")+oMdlLocal:GetValue("TFL_PLAN")+oMdlMc:GetValue("TFH_ITCNB"),"CNB_IDPED")
				AADD(aISSxID, {TECBGetISS(cProdSV), cIdPed})
			EndIf
			If EMPTY(cIdPed)
				cIdPed := GetIdPed(cContrt,;
				 			oMdlMc:GetValue("TFH_CONREV"),;
				 			oMdlLocal:GetValue("TFL_PLAN"),;
				 			TECBGetISS(cProdSV),;
				 			@aISSxID)
			EndIf
			RestArea(aAreaCNB)
			aItens[LEN(aItens)][10] := cIdPed
			aItens[LEN(aItens)][11] := cProdSV
		EndIf
	EndIf
Next nY

Return

/*/{Protheus.doc} At870OldValue
@description 	Busca o valor anterior de um item dos conceitos de produtos RH, MI, MC e LE
@since 			18.11.2016
@version 		12
@param 			cTab, Caracter, tabela a ter o registro pesquisado
@param 			cContrato, Caracter, número do contrato que o registro está vinculado
@param 			cItem, Caracter, posição do item no aba/tabela pesquisada
@param 			cProd, Caracter, código do produto a ser pesquisado
@param 			cCodAtual, Caracter, código atual para comparar com o campo _CODSUB das tabelas
@return 		Numérico, valor total do item pesquisado
/*/
Static Function At870OldValue( cTab, cContrato, cItem, cProd, cCodAtual, cCodTfj)

Local cQry := ""
Local nOldValue := 0
Local cTabTemp  := GetNextAlias()

Default cCodTFJ	:= ""

If !Empty(cCodTFJ) .AND. AT870CtRev(cCodTfj)
	cQry := "SELECT " + cTab + "2.* "
	cQry += "FROM "+RetSqlName(cTab)+" "+cTab+" "
	cQry += " INNER JOIN "+RetSqlName(cTab)+" "+cTab+"2 "
	cQry += " ON "+cTab+"."+cTab+"_CODREL = "+cTab+"2."+cTab+"_COD"
	cQry += " AND "+cTab+"."+cTab+"_FILIAL = "+cTab+"2."+cTab+"_FILIAL"
	cQry += " AND "+cTab+"2.D_E_L_E_T_=' '"
	cQry += "WHERE "+cTab+"."+cTab+"_FILIAL = '"+xFilial(cTab)+"' "
	cQry += 	"AND "+cTab+"."+cTab+"_ITEM = '"+cItem+"' "
	cQry += 	"AND "+cTab+"."+cTab+"_PRODUT = '"+cProd+"' "
	cQry += 	"AND "+cTab+"."+cTab+"_COD = '"+cCodAtual+"' "
	cQry += 	"AND "+cTab+".D_E_L_E_T_=' '"
Else
	cQry := "SELECT * "
	cQry += "FROM "+RetSqlName(cTab)+" "+cTab+" "
	cQry += "WHERE "+cTab+"_FILIAL = '"+xFilial(cTab)+"' "
	cQry += 	"AND "+cTab+"_ITEM = '"+cItem+"' "
	cQry += 	"AND "+cTab+"_PRODUT = '"+cProd+"' "
	cQry += 	"AND "+cTab+"_CODSUB = '"+cCodAtual+"' "
	cQry += 	"AND "+cTab+"_CONTRT = '"+cContrato+"' "
	cQry += 	"AND "+cTab+".D_E_L_E_T_=' '"
EndIf
// >>>> lembrar avaliar se o campo _codsub já foi preenchido neste momento
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabTemp,.T.,.T.)

If (cTabTemp)->(!EOF())
	If cTab == "TFF"
		 nOldValue := ( (cTabTemp)->TFF_QTDVEN * (cTabTemp)->TFF_PRCVEN ) - (cTabTemp)->TFF_VALDES + (cTabTemp)->TFF_ADM + (cTabTemp)->TFF_LUCRO
	ElseIf cTab == "TFG"
		nOldValue := ( (cTabTemp)->TFG_QTDVEN * (cTabTemp)->TFG_PRCVEN ) - (cTabTemp)->TFG_VALDES + (cTabTemp)->TFG_ADM + (cTabTemp)->TFG_LUCRO
	ElseIf cTab == "TFH"
		nOldValue := ( (cTabTemp)->TFH_QTDVEN * (cTabTemp)->TFH_PRCVEN) - (cTabTemp)->TFH_VALDES + (cTabTemp)->TFH_ADM + (cTabTemp)->TFH_LUCRO
	ElseIf cTab == "TFI"
		nOldValue := (cTabTemp)->TFI_TOTAL
	EndIf
EndIf

(cTab)->(DbCloseArea())

Return nOldValue

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At870RReaj()

@author       Matheus Lando Raimundo
@version      P12
/*/
//-----------------------------------------------------------------------------------------
Function At870RReaj( oMdlRev,  lOrcPrc, oMdlAssist)
Local lRet 		:= .T.
Local oTFLRev 	:= oMdlRev:GetModel('TFL_LOC')
Local oTFIRev 	:= oMdlRev:GetModel('TFI_LE')
Local oTFFRev 	:= oMdlRev:GetModel('TFF_RH')
Local oTEVRev 	:= oMdlRev:GetModel('TEV_ADICIO')
Local oTFGRev	:= oMdlRev:GetModel('TFG_MI')
Local oTFHRev	:= oMdlRev:GetModel('TFH_MC')
Local aMdlTab 	:= Nil

Local nI		:= 0
Local nJ		:= 0
Local nX		:= 0
Local aSaveRows	:= FwSaveRows()
Local lCobCtr 	:= .F.

Local oTFLassist := oMdlAssist:GetModel("TFLDETAIL")
Local oTFFassist := oMdlAssist:GetModel("TFFDETAIL")
Local oTV7assist := oMdlAssist:GetModel("TV7DETAIL")
Local oTFIassist := oMdlAssist:GetModel("TFIDETAIL")
Local oTEVassist := oMdlAssist:GetModel("TEVDETAIL")

Local nMdlTemp	:= 0
Local nTotAbas  := 0
Local cFldTab 	:= ""
Local cModoFld	:= ""
Local aAllModels := oMdlRev:GetAllSubModels()
Local lReco		 := TFJ->TFJ_CNTREC == '1'

For nX := 1 To oTFLRev:Length()
	oTFLRev:GoLine(nX)
	oTFLassist:GoLine(nX)

	//-- Data do Local de atendimento
	If !lReco
		lRet := lRet .And. oTFLRev:SetValue('TFL_DTFIM', oTFLRev:GetValue('TFL_DTFIM') + oTFLassist:GetValue("TFL_PRAZO"))
	EndIf
	//-- Data e valor do RH
	If  lRet .And. !oTFFRev:IsEmpty()
		For nI := 1 To oTFFRev:Length()
			oTFFRev:GoLine(nI)
			oTFFassist:GoLine(nI)

			lCobCtr := oTFFRev:GetValue("TFF_COBCTR") <> "2"
			// não atualiza itens não pertencentes ao contrato e nem itens calculados com planilha de preço
			If  lRet .And. lCobCtr .And. Empty(oTFFRev:GetValue("TFF_CALCMD"))
				If lOrcPrc
					nMdlTemp := 1
					aMdlTab := {}
					// copia os modelos de dados dos fields da precificação
					While nMdlTemp <= Len(aAllModels)
						If "RH0" $ aAllModels[nMdlTemp]:GetId()
							aAdd( aMdlTab, aAllModels[nMdlTemp])
						EndIf
						nMdlTemp += 1
					End

					If (( nTotAbas := Len(aMdlTab) ) >= 1 )
						// executar a atualização nos campos dentro da tabela de precificação
						For nJ := 1 To oTV7assist:Length()
							oTV7assist:GoLine(nJ)
							cFldTab := RTrim(oTV7assist:GetValue("TV7_IDENT"))
							cModoFld := RTrim(oTV7assist:GetValue("TV7_MODO"))
							nMdlTemp := 1
							While nMdlTemp <= nTotAbas
								// verifica qual modelo possui o campo para atualização do valor
								If aMdlTab[nMdlTemp]:HasField(cFldTab) // verificar coluna de nome do campo
									Exit
								Else
									nMdlTemp += 1
								EndIf
							End

							If nMdlTemp <= nTotAbas
								If cModoFld == '1'
									lRet := lRet .And. aMdlTab[nMdlTemp]:SetValue( cFldTab, oTV7assist:GetValue("TV7_VLRNEW") )
								EndIf
							Else
								lRet := .F.
								oMdlRev:SetErrorMessage(oMdlRev:GetId(),"TFF_COD",oMdlRev:GetId(), "TFF_COD",cFldTab,;
											STR0208, STR0209 )  // "Campo da tabela de precificação não encontrado na estrutura do modelo de dados." ### "Verifique a tabela e revisão associada a este orçamento de serviços."
								Exit
							EndIf
						Next nJ
					Else
						lRet := .F.
						oMdlRev:SetErrorMessage(oMdlRev:GetId(),"TFF_COD",oMdlRev:GetId(), "TFF_COD", "RH***",;
									STR0210, STR0209 ) // "Os modelos da tabela de precificação não carregaram corretamente." ### "Verifique a tabela e revisão associada a este orçamento de serviços."
						Exit
					EndIf
				Else
					lRet := lRet .And. oTFFRev:SetValue('TFF_PRCVEN', oTFFassist:GetValue("TFF_VLRNEW") )
					If !lReco
						lRet := lRet .And. oTFFRev:SetValue('TFF_PERFIM', oTFFRev:GetValue('TFF_PERFIM') + oTFFassist:GetValue("TFF_PRAZO"))
					EndIf
				EndIf
			EndIf

			If lRet .And. !lOrcPrc .And. lCobCtr
				lRet := lRet .And. At870RRjMt( oTFGRev, oTFHRev, oMdlAssist )
			EndIf
		Next nI
	EndIf
	// atualiza os materias de implantação e consumo
	If lRet .And. lOrcPrc
		lRet := lRet .And. At870RRjMt( oTFGRev, oTFHRev, oMdlAssist )
	EndIf
	// -- Data e Valor locação de equipamentos
	If lRet .And. !oTFIRev:IsEmpty()
		For nI := 1 To oTFIRev:Length()
			oTFIRev:GoLine(nI)
			oTFIassist:GoLine(nI)
			//-- Não aplicar itens que ja voltaram e não aplicar em itens calculados por planilha de preço
			If At870QtRet(oTFIRev:GetValue('TFI_COD')) < oTFIRev:GetValue('TFI_QTDVEN') .And. Empty( oTFIRev:GetValue("TFI_CALCMD") )
				If !lReco
					lRet := lRet .And. oTFIRev:SetValue('TFI_PERFIM', oTFIRev:GetValue('TFI_PERFIM') + oTFIassist:GetValue("TFI_PRAZO"))
				EndIf
				For nJ := 1 To oTEVRev:Length()
					oTEVRev:GoLine(nJ)
					oTEVassist:GoLine(nJ)
					//-- Não aplicar mobilização
					If oTEVRev:GetValue('TEV_MODCOB') <> '3'
						lRet := lRet .And. oTEVRev:SetValue('TEV_VLRUNI', oTEVassist:GetValue("TEV_VLRNEW") )
					EndIf
				Next nJ
			EndIf
		Next nI
	EndIf
Next nX

FwRestRows(aSaveRows)

Return lRet

/*/{Protheus.doc} At870RRjMt
	Atualiza as informações de valores e quantidade de dias dos itens de materiais
@author       josimar.assuncao
@version      P12
@param 		oTFGRev, objeto fwformgridmodel, modelo da dados da tabela TFG
@param 		oTFHRev, objeto fwformgridmodel, modelo de dados da tabela TFH
@param 		nPerc, numérico, valor para acrescentar em percentual ao item
@param 		nDias, numérico, quantidade de dias para acrescentar ao prazo
@return 	Lógico, determina se a atualização aconteceu com sucesso ou não
/*/
Static Function At870RRjMt( oTFGRev, oTFHRev, oMdlAssist )
Local lRet := .T.
Local nJ := 0
Local oTFGassist := oMdlAssist:GetModel("TFGDETAIL")
Local oTFHassist := oMdlAssist:GetModel("TFHDETAIL")
Local lReco		 := TFJ->TFJ_CNTREC == '1'

If !oTFGRev:IsEmpty()
	For nJ := 1 To oTFGRev:Length()
		oTFGRev:GoLine(nJ)
		oTFGassist:GoLine(nJ)
		// não atualiza itens fora do contrato
		If oTFGRev:GetValue('TFG_COBCTR') <> "2"
			lRet := lRet .And. oTFGRev:SetValue('TFG_PRCVEN', oTFGassist:GetValue("TFG_VLRNEW") )
			If !lReco
				lRet := lRet .And. oTFGRev:SetValue('TFG_PERFIM', oTFGRev:GetValue('TFG_PERFIM') + oTFGassist:GetValue("TFG_PRAZO"))
			EndIf
		EndIf
	Next nJ
EndIf

If lRet .And. !oTFHRev:IsEmpty()
	For nJ := 1 To oTFHRev:Length()
		oTFHRev:GoLine(nJ)
		oTFHassist:GoLine(nJ)
		// não atualiza itens fora do contrato
		If oTFHRev:GetValue('TFH_COBCTR') <> "2"
			lRet := lRet .And. oTFHRev:SetValue('TFH_PRCVEN', oTFHassist:GetValue("TFH_VLRNEW") )
			If !lReco
				lRet := lRet .And. oTFHRev:SetValue('TFH_PERFIM', oTFHRev:GetValue('TFH_PERFIM') + oTFHassist:GetValue("TFH_PRAZO"))
			EndIf
		EndIf
	Next nJ
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At870QtRet()

@author       Matheus Lando Raimundo
@version      P12
/*/
//-----------------------------------------------------------------------------------------
Function At870QtRet(cCodTFI)
Local cAliasQry := GetNextAlias()
Local nRet		  := 0

BeginSQL Alias cAliasQry
	SELECT SUM(TWP_QTDRET) TWP_QTDRET FROM %Table:TEW% TEW
		INNER JOIN %Table:TWP% TWP ON
			TWP.TWP_FILIAL = %xFilial:TWP%
			AND TWP.%notDel%
			AND TWP.TWP_IDREG = TEW.TEW_CODMV
		WHERE  TEW.TEW_FILIAL = %xFilial:TEW%
			AND TEW.%notDel%
			AND TEW.TEW_CODEQU = %Exp:cCodTFI%
			AND TEW.TEW_TIPO = '1'
EndSql

nRet := ((cAliasQry)->TWP_QTDRET)
(cAliasQry)->(DbCloseArea())

Return nRet

/*/{Protheus.doc} At870ItAgr
@description 	Atualizar os dados na CNB quando o contrato está com a definição para gerar os itens de forma agrupada
@since 			18.11.2016
@version 		12
/*/
Static Function At870ItAgr( oMdlTFJ, oMdlTFL, oMdlCNB, cPedTit,;
							nTotRHold, nTotRHnew, nTotMIold, nTotMInew,;
							nTotMCold, nTotMCnew, nTotLEold, nTotLEnew,;
							cNumPlan, cLocCCusto )
Local lAvalTFGCNB 	:= .T.
Local lAvalTFHCNB 	:= .T.
Local lAvalTFICNB 	:= .T.
Local lRet 			:= .T.
Local aAux 			:= {}
Local nTotalOld 	:= 0
Local nTotalNew 	:= 0
Local cItemCNB 		:= ""
Local cAtualiza		:= ""
Local cTFLATCC		:= oMdlTFL:GetValue("TFL_LOCAL")
Local lDelete
// POSICIONAR NO ITEM DE RH
If !Empty(oMdlTFL:GetValue("TFL_ITPLRH"))
	If oMdlCNB:SeekLine({{"CNB_ITEM", oMdlTFL:GetValue("TFL_ITPLRH")}})

		// calcula o valor de outros conceitos de produtos que apontam para o mesmo item
		nTotalOld := nTotRHold
		nTotalNew := nTotRHnew

		// Verifica e soma o total dos materiais de implantação
		If oMdlTFL:GetValue("TFL_ITPLMI") == oMdlTFL:GetValue("TFL_ITPLRH")
			nTotalOld += nTotMIold
			nTotalNew += nTotMInew
			lAvalTFGCNB := .F.
		EndIf

		// Verifica e soma o total dos materiais de implantação
		If oMdlTFL:GetValue("TFL_ITPLMC") == oMdlTFL:GetValue("TFL_ITPLRH")
			nTotalOld += nTotMCold
			nTotalNew += nTotMCnew
			lAvalTFHCNB := .F.
		EndIf

		// Verifica e soma o total dos materiais de implantação
		If oMdlTFL:GetValue("TFL_ITPLLE") == oMdlTFL:GetValue("TFL_ITPLRH")
			nTotalOld += nTotLEold
			nTotalNew += nTotLEnew
			lAvalTFICNB := .F.
		EndIf

		//Verifica se o campo existe
		If (TFL->(ColumnPos('TFL_ATCC')) > 0)
			cAtualiza := oMdlTFL:GetValue("TFL_ATCC")
		Else
			cAtualiza := "2"
		EndIf
		// função para atualizar os dados da CNB
		lRet := lRet .And. At870CNBUpd( oMdlCNB, nTotalOld, nTotalNew, , ,cAtualiza, cTFLATCC )
		lRet := lRet .And. oMdlCNB:VldLineData()
		// atualiza o item da CNB caso tenha diferença entre o inicial e o novo item
		If lRet .And. oMdlTFL:GetValue("TFL_ITPLRH") <> oMdlCNB:GetValue("CNB_ITEM")
			lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLRH", oMdlCNB:GetValue("CNB_ITEM"))

			If !lAvalTFGCNB
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMI", oMdlCNB:GetValue("CNB_ITEM"))
			EndIf

			If !lAvalTFHCNB
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMC", oMdlCNB:GetValue("CNB_ITEM"))
			EndIf

			If !lAvalTFICNB
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", oMdlCNB:GetValue("CNB_ITEM"))
			EndIf
		EndIf

		If !lRet
			Help( "", 1, "At870AGR_RH", , STR0174, 1, 0,,,,,,;  // "Problemas ao atualizar o item de RH na revisão."
					{STR0175})  // "Verifique os valores informados para os produtos de Recursos Humanos."
			If oMdlCNB:GetModel():HasErrorMessage()
				AtErroMvc( oMdlCNB:GetModel() )
				MostraErro()
			EndIf
			If oMdlTFL:GetModel():HasErrorMessage()
				AtErroMvc( oMdlTFL:GetModel() )
				MostraErro()
			EndIf
		EndIf

	Else
		lRet := .F.
		Help( "", 1, "At870NOITEM_RH", , STR0176, 1, 0,,,,,,;  // "Item do agrupamento de Recursos Humanos não existe no contrato."
					{STR0177})  // "Verifique se o campo TFL_ITPLRH tem conteúdo correspondente com o campo CNB_ITEM no contrato."
	EndIf
ElseIf nTotRHnew > 0
	// criar um novo item na planilha
	oMdlCNB:GoLine( oMdlCNB:Length() )
	cItemCNB := Soma1(oMdlCNB:GetValue("CNB_ITEM"))

	nTotalNew := nTotRHnew
	//----------------------------------------------------
	// Verifica se o código dos produtos são iguais para agrupar o valor em um único item
	If lAvalTFGCNB .And. oMdlTFJ:GetValue("TFJ_GRPRH") == oMdlTFJ:GetValue("TFJ_GRPMI")
		lAvalTFGCNB := .F.
		nTotalNew += nTotMInew
	EndIf

	If lAvalTFHCNB .And. oMdlTFJ:GetValue("TFJ_GRPRH") == oMdlTFJ:GetValue("TFJ_GRPMC")
		lAvalTFHCNB := .F.
		nTotalNew += nTotMCnew
	EndIf

	If lAvalTFICNB .And. oMdlTFJ:GetValue("TFJ_GRPRH") == oMdlTFJ:GetValue("TFJ_GRPLE")
		lAvalTFICNB := .F.
		nTotalNew += nTotLEnew
	EndIf
	//----------------------------------------------------
	aAux := {}
	Aadd(aAux ,{"CNB_ITEM"  , cItemCNB } )
	Aadd(aAux ,{"CNB_NUMERO", cNumPlan } )
	Aadd(aAux ,{"CNB_PRODUT", oMdlTFJ:GetValue("TFJ_GRPRH") } )
	Aadd(aAux ,{"CNB_QUANT" , 1 })
	Aadd(aAux ,{"CNB_VLUNIT", nTotalNew } )
	Aadd(aAux ,{"CNB_TS"    , oMdlTFJ:GetValue("TFJ_TES") })
	Aadd(aAux ,{"CNB_PEDTIT", cPedTit })
	If !Empty(cLocCCusto)
		Aadd(aAux ,{"CNB_CC", cLocCCusto })
	EndIf

	lRet := lRet .And. At870CNBAdd( oMdlCNB, aAux )
	lRet := lRet .And. oMdlCNB:VldLineData()

	lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLRH", cItemCNB)

	If !lRet
		Help( "", 1, "At870AGR_ADD_RH", , STR0178, 1, 0,,,,,,; // "Problemas ao incluir um item de RH na revisão."
				{STR0179}) // "Verifique se a revisão permite a inclusão de novas linhas no contrato."
		If oMdlCNB:GetModel():HasErrorMessage()
			AtErroMvc( oMdlCNB:GetModel() )
			MostraErro()
		EndIf
		If oMdlTFL:GetModel():HasErrorMessage()
			AtErroMvc( oMdlTFL:GetModel() )
			MostraErro()
		EndIf
	Else
		//----------------------------------------------------
		// caso não vá mais fazer avaliação do conceito de produto faz a atualização do item
		If !lAvalTFGCNB
			lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMI", cItemCNB)
		EndIf

		If !lAvalTFHCNB
			lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMC", cItemCNB)
		EndIf

		If !lAvalTFICNB
			lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", cItemCNB)
		EndIf
		//----------------------------------------------------
	EndIf

	aSize( aAux, 0 )
	aAux := Nil
EndIf

// POSICIONAR NO ITEM DE MI
If lRet .And. lAvalTFGCNB
	If !Empty(oMdlTFL:GetValue("TFL_ITPLMI"))
		If oMdlCNB:SeekLine({{"CNB_ITEM", oMdlTFL:GetValue("TFL_ITPLMI")}})

			// calcula o valor de outros conceitos de produtos que apontam para o mesmo item
			nTotalOld := nTotMIold
			nTotalNew := nTotMInew

			// Verifica e soma o total dos materiais de implantação
			If oMdlTFL:GetValue("TFL_ITPLMC") == oMdlTFL:GetValue("TFL_ITPLMI")
				nTotalOld += nTotMCold
				nTotalNew += nTotMCnew
				lAvalTFHCNB := .F.
			EndIf

			// Verifica e soma o total dos materiais de implantação
			If oMdlTFL:GetValue("TFL_ITPLLE") == oMdlTFL:GetValue("TFL_ITPLMI")
				nTotalOld += nTotLEold
				nTotalNew += nTotLEnew
				lAvalTFICNB := .F.
			EndIf

			lDelete := TecSumPrd(oMdlTFJ:GetValue("TFJ_CODIGO"),oMdlTFL:GetValue("TFL_CODIGO"),oMdlTFJ:GetValue("TFJ_GRPMI")) == 0


				//Verifica se o campo existe
			If (TFL->(ColumnPos('TFL_ATCC')) > 0)
				cAtualiza := oMdlTFL:GetValue("TFL_ATCC")
			Else
				cAtualiza := "2"
			EndIf
			// função para atualizar os dados da CNB
			lRet := lRet .And. At870CNBUpd( oMdlCNB, nTotalOld, nTotalNew,, lDelete, cAtualiza, cTFLATCC )
			lRet := lRet .And. oMdlCNB:VldLineData()
			// atualiza o item da CNB caso tenha diferença entre o inicial e o novo item
			If lRet .And. oMdlTFL:GetValue("TFL_ITPLMI") <> oMdlCNB:GetValue("CNB_ITEM")
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMI", oMdlCNB:GetValue("CNB_ITEM"))

				If !lAvalTFHCNB
					lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMC", oMdlCNB:GetValue("CNB_ITEM"))
				EndIf

				If !lAvalTFICNB
					lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", oMdlCNB:GetValue("CNB_ITEM"))
				EndIf
			EndIf

			If !lRet
				Help( "", 1, "At870AGR_MI", , STR0180, 1, 0,,,,,,; // "Problemas ao atualizar o item de MI na revisão."
						{STR0181}) // "Verifique os valores informados para os produtos de Materiais de Implantação."
				If oMdlCNB:GetModel():HasErrorMessage()
					AtErroMvc( oMdlCNB:GetModel() )
					MostraErro()
				EndIf
				If oMdlTFL:GetModel():HasErrorMessage()
					AtErroMvc( oMdlTFL:GetModel() )
					MostraErro()
				EndIf
			EndIf

		Else
			lRet := .F.
			Help( "", 1, "At870NOITEM_MI", , STR0182, 1, 0,,,,,,; // "Item do agrupamento de Materiais de Implantação não existe no contrato."
						{STR0183}) // "Verifique se o campo TFL_ITPLMI tem conteúdo correspondente com o campo CNB_ITEM no contrato."
		EndIf
	ElseIf nTotMInew > 0
		// criar um novo item na planilha
		oMdlCNB:GoLine( oMdlCNB:Length() )
		cItemCNB := Soma1(oMdlCNB:GetValue("CNB_ITEM"))

		nTotalNew := nTotMInew
		//----------------------------------------------------
		// Verifica se o código dos produtos são iguais para agrupar o valor em um único item
		If lAvalTFHCNB .And. oMdlTFJ:GetValue("TFJ_GRPMI") == oMdlTFJ:GetValue("TFJ_GRPMC")
			lAvalTFHCNB := .F.
			nTotalNew += nTotMCnew
		EndIf

		If lAvalTFICNB .And. oMdlTFJ:GetValue("TFJ_GRPMI") == oMdlTFJ:GetValue("TFJ_GRPLE")
			lAvalTFICNB := .F.
			nTotalNew += nTotLEnew
		EndIf
		//----------------------------------------------------

		aAux := {}
		Aadd(aAux ,{"CNB_ITEM"  , cItemCNB } )
		Aadd(aAux ,{"CNB_NUMERO", cNumPlan } )
		Aadd(aAux ,{"CNB_PRODUT", oMdlTFJ:GetValue("TFJ_GRPMI") } )
		Aadd(aAux ,{"CNB_QUANT" , 1 })
		Aadd(aAux ,{"CNB_VLUNIT", nTotalNew } )
		Aadd(aAux ,{"CNB_TS"    , oMdlTFJ:GetValue("TFJ_TESMI") })
		Aadd(aAux ,{"CNB_PEDTIT", cPedTit })
		If !Empty(cLocCCusto)
			Aadd(aAux ,{"CNB_CC", cLocCCusto })
		EndIf

		lRet := lRet .And. At870CNBAdd( oMdlCNB, aAux )
		lRet := lRet .And. oMdlCNB:VldLineData()

		lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMI", cItemCNB)

		If !lRet
			Help( "", 1, "At870AGR_ADD_MI", , STR0184, 1, 0,,,,,,; // "Problemas ao incluir um item de MI na revisão."
					{STR0185}) // "Verifique se a revisão permite a inclusão de novas linhas no contrato."
			If oMdlCNB:GetModel():HasErrorMessage()
				AtErroMvc( oMdlCNB:GetModel() )
				MostraErro()
			EndIf
			If oMdlTFL:GetModel():HasErrorMessage()
				AtErroMvc( oMdlTFL:GetModel() )
				MostraErro()
			EndIf
		Else
			//----------------------------------------------------
			// caso não vá mais fazer avaliação do conceito de produto faz a atualização do item
			If !lAvalTFHCNB
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMC", cItemCNB)
			EndIf

			If !lAvalTFICNB
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", cItemCNB)
			EndIf
			//----------------------------------------------------
		EndIf

		aSize( aAux, 0 )
		aAux := Nil
	EndIf
EndIf

// POSICIONAR NO ITEM DE MC
If lRet .And. lAvalTFHCNB
	If !Empty(oMdlTFL:GetValue("TFL_ITPLMC"))
		If oMdlCNB:SeekLine({{"CNB_ITEM", oMdlTFL:GetValue("TFL_ITPLMC")}})

			// calcula o valor de outros conceitos de produtos que apontam para o mesmo item
			nTotalOld := nTotMCold
			nTotalNew := nTotMCnew

			// Verifica e soma o total dos materiais de consumo
			If oMdlTFL:GetValue("TFL_ITPLLE") == oMdlTFL:GetValue("TFL_ITPLMC")
				nTotalOld += nTotLEold
				nTotalNew += nTotLEnew
				lAvalTFICNB := .F.
			EndIf


			//Verifica se o campo existe
			If (TFL->(ColumnPos('TFL_ATCC')) > 0)
				cAtualiza := oMdlTFL:GetValue("TFL_ATCC")
			Else
				cAtualiza := "2"
			EndIf

			// função para atualizar os dados da CNB
			lDelete := TecSumPrd(oMdlTFJ:GetValue("TFJ_CODIGO"),oMdlTFL:GetValue("TFL_CODIGO"),oMdlTFJ:GetValue("TFJ_GRPMC")) == 0

			lRet := lRet .And. At870CNBUpd( oMdlCNB, nTotalOld, nTotalNew, ,lDelete, cAtualiza, cTFLATCC )
			lRet := lRet .And. oMdlCNB:VldLineData()
			// atualiza o item da CNB caso tenha diferença entre o inicial e o novo item
			If lRet .And. oMdlTFL:GetValue("TFL_ITPLMC") <> oMdlCNB:GetValue("CNB_ITEM")
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMC", oMdlCNB:GetValue("CNB_ITEM"))

				If !lAvalTFICNB
					lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", oMdlCNB:GetValue("CNB_ITEM"))
				EndIf
			EndIf

			If !lRet
				Help( "", 1, "At870AGR_MC", , STR0186, 1, 0,,,,,,;  // "Problemas ao atualizar o item de MC na revisão."
						{STR0187}) // "Verifique os valores informados para os produtos de Materiais de Consumo."
				If oMdlCNB:GetModel():HasErrorMessage()
					AtErroMvc( oMdlCNB:GetModel() )
					MostraErro()
				EndIf
				If oMdlTFL:GetModel():HasErrorMessage()
					AtErroMvc( oMdlTFL:GetModel() )
					MostraErro()
				EndIf
			EndIf

		Else
			lRet := .F.
			Help( "", 1, "At870NOITEM_MC", , STR0188, 1, 0,,,,,,; // "Item do agrupamento de Materiais de Consumo não existe no contrato."
						{STR0189}) // "Verifique se o campo TFL_ITPLMC tem conteúdo correspondente com o campo CNB_ITEM no contrato."
		EndIf
	ElseIf nTotMCnew > 0
		// criar um novo item na planilha
		oMdlCNB:GoLine( oMdlCNB:Length() )
		cItemCNB := Soma1(oMdlCNB:GetValue("CNB_ITEM"))

		nTotalNew := nTotMCnew
		//----------------------------------------------------
		// Verifica se o código dos produtos são iguais para agrupar o valor em um único item
		If lAvalTFICNB .And. oMdlTFJ:GetValue("TFJ_GRPMC") == oMdlTFJ:GetValue("TFJ_GRPLE")
			lAvalTFICNB := .F.
			nTotalNew += nTotLEnew
		EndIf
		//----------------------------------------------------

		aAux := {}
		Aadd(aAux ,{"CNB_ITEM"  , cItemCNB } )
		Aadd(aAux ,{"CNB_NUMERO", cNumPlan } )
		Aadd(aAux ,{"CNB_PRODUT", oMdlTFJ:GetValue("TFJ_GRPMC") } )
		Aadd(aAux ,{"CNB_QUANT" , 1 })
		Aadd(aAux ,{"CNB_VLUNIT", nTotalNew } )
		Aadd(aAux ,{"CNB_TS"    , oMdlTFJ:GetValue("TFJ_TESMC") })
		Aadd(aAux ,{"CNB_PEDTIT", cPedTit })
		If !Empty(cLocCCusto)
			Aadd(aAux ,{"CNB_CC", cLocCCusto })
		EndIf

		lRet := lRet .And. At870CNBAdd( oMdlCNB, aAux )
		lRet := lRet .And. oMdlCNB:VldLineData()

		lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLMC", cItemCNB)

		If !lRet
			Help( "", 1, "At870AGR_ADD_MC", , STR0190, 1, 0,,,,,,; // "Problemas ao incluir um item de MC na revisão."
					{STR0191}) // "Verifique se a revisão permite a inclusão de novas linhas no contrato."
			If oMdlCNB:GetModel():HasErrorMessage()
				AtErroMvc( oMdlCNB:GetModel() )
				MostraErro()
			EndIf
			If oMdlTFL:GetModel():HasErrorMessage()
				AtErroMvc( oMdlTFL:GetModel() )
				MostraErro()
			EndIf
		Else
			//----------------------------------------------------
			// caso não vá mais fazer avaliação do conceito de produto faz a atualização do item
			If !lAvalTFICNB
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", cItemCNB)
			EndIf
			//----------------------------------------------------
		EndIf

		aSize( aAux, 0 )
		aAux := Nil
	EndIf
EndIf

// POSICIONAR NO TIEM DE LE
If lRet .And. lAvalTFICNB
	If !Empty(oMdlTFL:GetValue("TFL_ITPLLE"))
		If oMdlCNB:SeekLine({{"CNB_ITEM", oMdlTFL:GetValue("TFL_ITPLLE")}})

			// calcula o valor de outros conceitos de produtos que apontam para o mesmo item
			nTotalOld := nTotLEold
			nTotalNew := nTotLEnew

				//Verifica se o campo existe
			If (TFL->(ColumnPos('TFL_ATCC')) > 0)
				cAtualiza := oMdlTFL:GetValue("TFL_ATCC")
			Else
				cAtualiza := "2"
			EndIf
			// função para atualizar os dados da CNB
			lRet := lRet .And. At870CNBUpd( oMdlCNB, nTotalOld, nTotalNew, , ,cAtualiza, cTFLATCC )
			lRet := lRet .And. oMdlCNB:VldLineData()
			// atualiza o item da CNB caso tenha diferença entre o inicial e o novo item
			If lRet .And. oMdlTFL:GetValue("TFL_ITPLLE") <> oMdlCNB:GetValue("CNB_ITEM")
				lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", oMdlCNB:GetValue("CNB_ITEM"))

			EndIf

			If !lRet
				Help( "", 1, "At870AGR_LE", , STR0192, 1, 0,,,,,,; // "Problemas ao atualizar o item de LE na revisão."
						{STR0193}) // "Verifique os valores informados para os produtos de Locação de Equipamentos."
				If oMdlCNB:GetModel():HasErrorMessage()
					AtErroMvc( oMdlCNB:GetModel() )
					MostraErro()
				EndIf
				If oMdlTFL:GetModel():HasErrorMessage()
					AtErroMvc( oMdlTFL:GetModel() )
					MostraErro()
				EndIf
			EndIf

		Else
			lRet := .F.
			Help( "", 1, "At870NOITEM_LE", , STR0194, 1, 0,,,,,,; // "Item do agrupamento de Locação de Equipamentos não existe no contrato."
						{STR0195}) // "Verifique se o campo TFL_ITPLLE tem conteúdo correspondente com o campo CNB_ITEM no contrato."
		EndIf
	ElseIf nTotLEnew > 0
		// criar um novo item na planilha
		oMdlCNB:GoLine( oMdlCNB:Length() )
		cItemCNB := Soma1(oMdlCNB:GetValue("CNB_ITEM"))

		nTotalNew := nTotLEnew

		aAux := {}
		Aadd(aAux ,{"CNB_ITEM"  , cItemCNB } )
		Aadd(aAux ,{"CNB_NUMERO", cNumPlan } )
		Aadd(aAux ,{"CNB_PRODUT", oMdlTFJ:GetValue("TFJ_GRPLE") } )
		Aadd(aAux ,{"CNB_QUANT" , 1 })
		Aadd(aAux ,{"CNB_VLUNIT", nTotalNew } )
		Aadd(aAux ,{"CNB_TS"    , oMdlTFJ:GetValue("TFJ_TESLE") })
		Aadd(aAux ,{"CNB_PEDTIT", cPedTit })
		If !Empty(cLocCCusto)
			Aadd(aAux ,{"CNB_CC", cLocCCusto })
		EndIf

		lRet := lRet .And. At870CNBAdd( oMdlCNB, aAux )
		lRet := lRet .And. oMdlCNB:VldLineData()

		lRet := lRet .And. oMdlTFL:SetValue("TFL_ITPLLE", cItemCNB)

		If !lRet
			Help( "", 1, "At870AGR_ADD_LE", , STR0196, 1, 0,,,,,,;  // "Problemas ao incluir um item de LE na revisão."
					{STR0197}) // "Verifique se a revisão permite a inclusão de novas linhas no contrato."
			If oMdlCNB:GetModel():HasErrorMessage()
				AtErroMvc( oMdlCNB:GetModel() )
				MostraErro()
			EndIf
			If oMdlTFL:GetModel():HasErrorMessage()
				AtErroMvc( oMdlTFL:GetModel() )
				MostraErro()
			EndIf
		EndIf

		aSize( aAux, 0 )
		aAux := Nil
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} At870ItDsAgr
@description 	Atualizar os dados na CNB quando o contrato está com a definição para gerar os itens de forma não agrupada
@since 			18.11.2016
@version 		12
/*/
Static Function At870ItDsAgr( oModel, oMdlCNB, cContrato, lOldValues, cPedTit, cNumPlan, cLocCCusto )
Local aAux 			:= {}
Local aPrds 		:= {}
Local lRet 			:= .T.
Local nK 			:= 0
Local nTotalOld 	:= 0
Local nTotalNew 	:= 0
Local oMdlTFL 		:= oModel:GetModel("TFL_LOC")
Local oMdlTFJ 		:= oModel:GetModel("TFJ_REFER")
Local oMdlTFF		:= oModel:GetModel("TFF_RH")
Local oMdlItemGS 	:= Nil
Local cCpoBusca 	:= ""
Local cCpoSet 		:= ""
Local cItemCNB 		:= ""
Local cTESCNB 		:= ""
Local cCpoTFLItem 	:= ""
Local cAtualiza		:= ""
Local cTFLATCC		:= oMdlTFL:GetValue("TFL_LOCAL")
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local lGsIss := SuperGetMv("MV_GSISS",,.F.)

Default lOldValues := .T.

// quando a geração aconteceu de forma não agrupada
//   busca todos os itens com os valores anteriores e atuais
aPrds := At870AllPrds( oModel, lOldValues, cContrato )

// percorrer os itens dos conceitos de produtos Rh, Mi, Mc e Le
For nK := 1 To Len(aPrds)
	/* estrutura do array :: aPrds ::
		{
			1 = ITEM ORÇAMENTO DE SERVIÇOS,;
			2 = PRODUTO ORÇAMENTO DE SERVIÇOS,;
			3 = PLANILHA NO CONTRATO,;
			4 = ITEM NO CONTRATO,;
			5 = VALOR REVISADO (novo),;
			6 = VALOR ANTERIOR (antigo),;
			7 = QUANTIDADE DO ITEM NO ORÇAMENTO DE SERVIÇOS,;
			8 = Tipo [RH / MI / MC / LE].
			9 = TES do Pedido (Apenas para desagrupados)
		}
	*/

	oMdlCNB:GoLine( oMdlCNB:Length() )
	cItemCNB := Soma1(oMdlCNB:GetValue("CNB_ITEM"))

	// identifica qual a TES para usar no item
	If aPrds[nK][8] == "RH"
		oMdlItemGS 		:= oModel:GetModel("TFF_RH")
		cCpoBusca 		:= "TFF_ITEM"
		cCpoSet 		:= "TFF_ITCNB"
		cCpoTFLItem 	:= "TFL_ITPLRH"
		cTESCNB 		:= oMdlItemGS:GetValue("TFF_TESPED")
	ElseIf aPrds[nK][8] == "MI"
		oMdlItemGS 		:= oModel:GetModel("TFG_MI")
		cCpoBusca 		:= "TFG_ITEM"
		cCpoSet 		:= "TFG_ITCNB"
		cCpoTFLItem 	:= "TFL_ITPLMI"
		cTESCNB := oMdlItemGS:GetValue("TFG_TESPED")
	ElseIf aPrds[nK][8] == "MC"
		oMdlItemGS 		:= oModel:GetModel("TFH_MC")
		cCpoBusca 		:= "TFH_ITEM"
		cCpoSet 		:= "TFH_ITCNB"
		cCpoTFLItem 	:= "TFL_ITPLMC"
		cTESCNB := oMdlItemGS:GetValue("TFH_TESPED")
	ElseIf aPrds[nK][8] == "LE"
		oMdlItemGS 		:= oModel:GetModel("TFI_LE")
		cCpoBusca 		:= "TFI_ITEM"
		cCpoSet 		:= "TFI_ITCNB"
		cCpoTFLItem 	:= "TFL_ITPLLE"
		cTESCNB 		:= oMdlItemGS:GetValue("TFI_TESPED")
	Else
		oMdlItemGS 		:= Nil
		cCpoBusca 		:= ""
		cCpoSet 		:= ""
		cCpoTFLItem 	:= ""
		cTESCNB 		:= ""
	EndIf

	// planilha já está posicionada pelo itens acima
	If !Empty( aPrds[nK][4] )
		// posicionar na linha do item no contrato
		If oMdlCNB:SeekLine( {{"CNB_ITEM", aPrds[nK][4] }} )

			// calcula o valor de outros conceitos de produtos que apontam para o mesmo item
			nTotalOld := aPrds[nK][6]
			nTotalNew := aPrds[nK][5]
					//Verifica se o campo existe
			If (TFL->(ColumnPos('TFL_ATCC')) > 0)
				cAtualiza := oMdlTFL:GetValue("TFL_ATCC")
			Else
				cAtualiza := "2"
			EndIf
			// função para atualizar os dados da CNB
			lRet := lRet .And. At870CNBUpd( oMdlCNB, nTotalOld, nTotalNew, aPrds[nK][7], , cAtualiza, cTFLATCC )
			If !EMPTY(aPrds[nK][9])
				lRet := lRet .AND. oMdlCNB:SetValue("CNB_TS", aPrds[nK][9])
			EndIf
			If LEN(aPrds[nK]) >= 11 .AND. lGSISS .AND. !lOrcPrc
				lRet := lRet .AND. oMdlCNB:LoadValue("CNB_IDPED", aPrds[nK][10])
				lRet := lRet .AND. oMdlCNB:LoadValue("CNB_PRODSV", aPrds[nK][11])
			EndIf
			lRet := lRet .And. oMdlCNB:VldLineData()

			// atualiza o item da CNB caso tenha diferença entre o inicial e o novo item
			//  posicionar na linha conforme o item do orçamento de serviços e adicionar o item da CNB nele
			If aPrds[nK][4] <> oMdlCNB:GetValue( "CNB_ITEM" )
				If oMdlItemGS:SeekLine( { { cCpoBusca, aPrds[nK][1] } } )
					lRet := lRet .And. oMdlItemGS:SetValue( cCpoSet, cItemCNB)
					// verifica se o item no cabeçalho do orçamento já possui preenchimento
					If Empty( oMdlTFL:GetValue( cCpoTFLItem ) )
						lRet := lRet .And. oMdlTFL:SetValue( cCpoTFLItem, cItemCNB )
					EndIf
				Else
					lRet := .F.
					Help( "", 1, "At870NOAGR_05", , STR0198, 1, 0,,,,,,; // "Problemas ao atualizar o item do Contrato no Orçamento de Serviços."
							{i18n(STR0199,{ aPrds[nK][1], aPrds[nK][8] }) } ) // "Não foi possível identificar o item #1 no conceito de produto #2."
				EndIf
			EndIf

			If !lRet
				Help( "", 1, "At870NOAGR_01", , i18n(STR0200,{ aPrds[nK][4], oMdlCNB:GetValue("CNB_NUMERO") }), 1, 0,,,,,,; // "Problema na atualização do item #1 na planilha #2."
						{STR0201})  // "Verifique os valores informados para o item correspondente no orçamento de serviços."
				If oMdlCNB:GetModel():HasErrorMessage()
					AtErroMvc( oMdlCNB:GetModel() )
					MostraErro()
				EndIf
				If oModel:HasErrorMessage()
					AtErroMvc( oMdlTFL:GetModel() )
					MostraErro()
				EndIf
				Exit
			EndIf

		Else
			lRet := .F.
			Help( "", 1, "At870NOAGR_02", , i18n(STR0202,{ aPrds[nK][4], oMdlCNB:GetValue("CNB_NUMERO") }), 1, 0,,,,,,; // "O item #1 na planilha #2 não foi encontrado."
					{STR0201}) // "Verifique os valores informados para o item correspondente no orçamento de serviços."
			Exit
		EndIf
	ElseIf aPrds[nK][5] > 0
		// adicionar um novo item na CNB
		// criar um novo item na planilha
		aAux := {}
		Aadd(aAux ,{"CNB_ITEM"  , cItemCNB } )
		Aadd(aAux ,{"CNB_NUMERO", cNumPlan } )
		Aadd(aAux ,{"CNB_PRODUT", aPrds[nK][2] } )
		Aadd(aAux ,{"CNB_QUANT" , aPrds[nK][7] })
		Aadd(aAux ,{"CNB_VLUNIT", ( aPrds[nK][5] / aPrds[nK][7] ) } )
		Aadd(aAux ,{"CNB_TS"    , cTESCNB })
		Aadd(aAux ,{"CNB_PEDTIT", cPedTit })
		If !Empty(cLocCCusto)
			Aadd(aAux ,{"CNB_CC", cLocCCusto })
		EndIf
		If LEN(aPrds[nK]) >= 11 .AND. lGSISS .AND. !lOrcPrc
			Aadd(aAux ,{"CNB_IDPED", aPrds[nK][10]})
			Aadd(aAux ,{"CNB_PRODSV", aPrds[nK][11]})
		EndIf

		lRet := lRet .And. At870CNBAdd( oMdlCNB, aAux )
		lRet := lRet .And. oMdlCNB:VldLineData()
		If !lOrcPrc .AND. aPrds[nK][8] $ "MI|MC" .AND. LEN(aPrds[nK]) >= 12
			oMdlTFF:SeekLine( { { "TFF_COD", aPrds[nK][12] } } )
		EndIf
		//-------------------------------------------------
		//  posicionar na linha conforme o item do orçamento de serviços e adicionar o item da CNB nele
		If oMdlItemGS:SeekLine( { { cCpoBusca, aPrds[nK][1] } } )
			lRet := lRet .And. oMdlItemGS:SetValue( cCpoSet, cItemCNB)
			// verifica se o item no cabeçalho do orçamento já possui preenchimento
			If Empty( oMdlTFL:GetValue( cCpoTFLItem ) )
				lRet := lRet .And. oMdlTFL:SetValue( cCpoTFLItem, cItemCNB )
			EndIf
		Else
			lRet := .F.
			Help( "", 1, "At870NOAGR_04", , STR0198, 1, 0,,,,,,; // "Problemas ao atualizar o item do Contrato no Orçamento de Serviços."
					{i18n(STR0199,{ aPrds[nK][1], aPrds[nK][8] }) } ) // "Não foi possível identificar o item #1 no conceito de produto #2."
		EndIf
		If !lRet
			Help( "", 1, "At870NOAGR_03", , STR0203, 1, 0,,,,,,; // "Problemas ao incluir um item na revisão."
					{STR0197})  // "Verifique se a revisão permite a inclusão de novas linhas no contrato."
			If oMdlCNB:GetModel():HasErrorMessage()
				AtErroMvc( oMdlCNB:GetModel() )
				MostraErro()
			EndIf
			If oModel:HasErrorMessage()
				AtErroMvc( oModel )
				MostraErro()
			EndIf
			Exit
		EndIf

		aSize( aAux, 0 )
		aAux := Nil
	EndIf

Next nK

If lRet
	For nK := 1 TO oMdlCNB:Length()
		oMdlCNB:GoLine(nK)
		If !(oMdlCNB:isInserted()) .AND. EMPTY(oMdlCNB:GetValue("CNB_ITMDST"))
			If ASCAN(aPrds, {|a| a[4] == oMdlCNB:GetValue("CNB_ITEM") .AND. a[2] == oMdlCNB:GetValue("CNB_PRODUT")}) == 0
				If !( lRet := lRet .AND. oMdlCNB:DeleteLine() )
					Exit
				EndIf
			EndIf
		EndIf
	Next
EndIf

Return lRet

/*/{Protheus.doc} At870RestLins
@description 	Reposiciona todos os modelos do orçamento de serviços para a primeira linha
@since 			02.12.2016
@version 		12
@param 			oMdlRev, Objeto FwFormModel/MpFormModel, objeto geral para o reposicionamento.
@param 			lOrcPrc, Lógico, define se o orçamento de serviços é com precificação ou não.
/*/
Static Function At870RestLins( oMdlRev, lOrcPrc )

Local aRhMdls := {}
Local aLeMdls := {}
Local nX := 0
Local nY := 0
Local nZ := 0
Local oMdlLocal := oMdlRev:GetModel("TFL_LOC")
Local oMdlRH := oMdlRev:GetModel("TFF_RH")
Local oMdlLE := oMdlRev:GetModel("TFI_LE")
Local oMdlFacil := oMdlRev:GetModel("TWODETAIL")
Local nQtSubRH := 0
Local nQtSubLE := 0
Local oMdlTemp1 := Nil

Default lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)

If lOrcPrc
	aRhMdls := { "ABP_BENEF", "TFU_HE", "TGV_RH", "TDS_RH", "TDT_RH" }
Else
	aRhMdls := { "ABP_BENEF", "TFG_MI", "TFH_MC", "TFU_HE", "TGV_RH", "TDS_RH", "TDT_RH" }
EndIf

aLeMdls := { "TEV_ADICIO" }

nQtSubRH := Len(aRhMdls)
nQtSubLE := Len(aLeMdls)

For nX := 1 To oMdlLocal:Length()

	oMdlLocal:GoLine( nX )
	// manda o facilitador para a primeira linha
	oMdlFacil:GoLine( 1 )
	// posiciona os submodelos de rh para a primeira linha
	For nY := 1 To oMdlRH:Length()
		oMdlRH:GoLine( nY )

		For nZ := 1 To nQtSubRH
			oMdlTemp1 := oMdlRev:GetModel(aRhMdls[nZ])
			oMdlTemp1:GoLine(1)
		Next nZ
	Next nY
	// manda o recurso humano para a primeira linha
	oMdlRH:GoLine( 1 )

	// posiciona os submodelos de locação de equipamentos para a primeira linha
	For nY := 1 To oMdlLE:Length()
		oMdlLE:GoLine( nY )

		For nZ := 1 To nQtSubLE
			oMdlTemp1 := oMdlRev:GetModel(aLEMdls[nZ])
			oMdlTemp1:GoLine(1)
		Next nZ
	Next nY
	// manda a locção de equipamentos para a primeira linha
	oMdlLE:GoLine( 1 )

Next nX
// devolve o local para a primeira linha
oMdlLocal:GoLine( 1 )

Return

Function At870RAuto(oMdlRev,nPerc,nDias)
Local lRet 		:= .T.
Local oTFJRev 	:= oMdlRev:GetModel('TFJ_REFER')
Local oTFLRev 	:= oMdlRev:GetModel('TFL_LOC')
Local oTFIRev 	:= oMdlRev:GetModel('TFI_LE')
Local oTFFRev 	:= oMdlRev:GetModel('TFF_RH')
Local oTEVRev 	:= oMdlRev:GetModel('TEV_ADICIO')
Local oTFGRev	:= oMdlRev:GetModel('TFG_MI')
Local oTFHRev	:= oMdlRev:GetModel('TFH_MC')
Local nI		   	:= 0
Local nJ			:= 0
Local nX			:= 0
Local nW			:= 0
Local nZ			:= 0
Local nVlrUnit	:= 0
Local aSaveRows	:= FwSaveRows()
Local lCobCtr := oTFFRev:GetValue("TFF_COBCTR") <> "2"
Local lRecorrente	:= oTFJRev:GetValue('TFJ_CNTREC') == "1"

//-- Não aplicar mobilizaão
//-- Não aplicar itens que ja voltaram

For nX := 1 To oTFLRev:Length()
	oTFLRev:GoLine(nX)

	If oTFLRev:GetValue("TFL_ENCE") <> "1"
		//-- Data do Local de atendimento
		If !lRecorrente
			lRet := lRet .And. oTFLRev:SetValue('TFL_DTFIM',oTFLRev:GetValue('TFL_DTFIM') + nDias)
		Endif
		//-- Data e valor do RH
		If  lRet .And. !oTFFRev:IsEmpty()
			For nI := 1 To oTFFRev:Length()
				oTFFRev:GoLine(nI)
				If oTFFRev:GetValue("TFF_ENCE") <> "1"
					If oTFFRev:GetValue("TFF_COBCTR") <> "2" 
						nVlrUnit := oTFFRev:GetValue('TFF_PRCVEN')
						lRet := lRet .And. oTFFRev:SetValue('TFF_PRCVEN',nVlrUnit + ( nVlrUnit / 100) * nPerc )
						If !lRecorrente
							lRet := lRet .And. oTFFRev:SetValue('TFF_PERFIM',oTFFRev:GetValue('TFF_PERFIM') + nDias)
						Endif
						If lRet
							If !oTFGRev:IsEmpty()
								For nJ := 1 To oTFGRev:Length()
									oTFGRev:GoLine(nJ)
									nVlrUnit := oTFGRev:GetValue('TFG_PRCVEN')
										lRet := lRet .And. oTFGRev:SetValue('TFG_PRCVEN',nVlrUnit + ( nVlrUnit / 100) * nPerc )
									If !lRecorrente
										lRet := lRet .And. oTFGRev:SetValue('TFG_PERFIM',oTFGRev:GetValue('TFG_PERFIM') + nDias)
									Endif
								Next nJ
							EndIf

							If lRet .And. !oTFHRev:IsEmpty()
								For nJ := 1 To oTFHRev:Length()
									oTFHRev:GoLine(nJ)
									nVlrUnit := oTFHRev:GetValue('TFH_PRCVEN')
										lRet := lRet .And. oTFHRev:SetValue('TFH_PRCVEN',nVlrUnit + ( nVlrUnit / 100) * nPerc )
									If !lRecorrente
										lRet := lRet .And. oTFHRev:SetValue('TFH_PERFIM',oTFHRev:GetValue('TFH_PERFIM') + nDias)
									Endif
								Next nJ
							EndIf
						EndIf
					EndIf
				EndIf
			Next nI
		EndIf

		If lRet .And. !oTFIRev:IsEmpty()
			For nI := 1 To oTFIRev:Length()
				oTFIRev:GoLine(nI)
				If oTFIRev:GetValue("TFI_ENCE") <> "1"
					If At870QtRet(oTFIRev:GetValue('TFI_COD')) < oTFIRev:GetValue('TFI_QTDVEN') .And. Empty( oTFIRev:GetValue("TFI_CALCMD") ) // Testar
						If !lRecorrente
							lRet := lRet .And. oTFIRev:SetValue('TFI_PERFIM',oTFIRev:GetValue('TFI_PERFIM') + nDias)
						Endif
						For nJ := 1 To oTEVRev:Length()
							oTEVRev:GoLine(nJ)
							If oTEVRev:GetValue('TEV_MODCOB') <> '3'
								nVlrUnit := oTEVRev:GetValue('TEV_VLRUNI')
								lRet := lRet .And. oTEVRev:SetValue('TEV_VLRUNI',nVlrUnit + ( nVlrUnit / 100) * nPerc )
							EndIf
						Next nJ
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf
Next nX

FwRestRows(aSaveRows)

Return lRet

/*/{Protheus.doc} At870OsMont
@description 	Reposiciona todos os modelos do orçamento de serviços para a primeira linha
@since 			02.12.2016
@version 		12
@param 			oMdlRev, Objeto FwFormModel/MpFormModel, objeto geral para o reposicionamento.
@param 			lOrcPrc, Lógico, define se o orçamento de serviços é com precificação ou não.
/*/
Static Function At870OsMont( cCodTFJAnt, cCodTFJ )
Local cQryAB6Alt 	:= GetNextAlias()
Local cFilTFJ 		:= xFilial("TFJ")
Local aArea 		:= GetArea()
Local aAreaTFJ 		:= TFJ->(GetArea())
Local aAreaTFL 		:= TFL->(GetArea())
Local aAreaTFI 		:= TFI->(GetArea())
Local aAreaAB6 		:= AB6->(GetArea())
Local aAreaTFF 		:= TFF->(GetArea())
Local nTotal 	:= 0
Local oDlg		:= nil
Local oSayMtr	:= nil
Local nMeter	:= 0

BeginSQL Alias cQryAB6Alt
	SELECT AB6.R_E_C_N_O_ AB6RECNO
	FROM %Table:AB6% AB6
	WHERE AB6_FIORCS = %Exp:cFilTFJ%
		AND AB6_CDORCS = %Exp:cCodTFJAnt%
		AND AB6.%NotDel%
EndSQL

While (cQryAB6Alt)->(!EOF())
	nTotal++
	(cQryAB6Alt)->(DbSkip())
End

(cQryAB6Alt)->(DbGoTop())

TFF->(DbSetOrder( 1 ))  // TFF_FILIAL + TFF_COD
TFI->(DbSetOrder( 1 ))  // TFI_FILIAL + TFI_COD

If isBlind()
	UpdAB6xTFF(cQryAB6Alt,cCodTFJ)
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0264 //"Atualizando ordens de serviço"
		oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (UpdAB6xTFF(cQryAB6Alt,cCodTFJ,@oDlg,@oMeter))
EndIf

RestArea(aAreaTFF)
RestArea(aAreaAB6)
RestArea(aAreaTFI)
RestArea(aAreaTFL)
RestArea(aAreaTFJ)
RestArea(aArea)

Return

/*/{Protheus.doc} Function at870InRev(cContra)

@description 	Retorna se um determinado orçamento esta em revisão
@since 			27.09.2017
@version 		12

/*/
Function at870InRev(cContra)
Local lRet := .F.
Local cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry
	SELECT  1 FROM %Table:TFJ% TFJ
WHERE
	TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
	TFJ.TFJ_CONTRT = %Exp:cContra% AND
	TFJ.TFJ_STATUS IN ('2','4') AND
	TFJ.%notDel%
EndSql

lRet := (cAliasQry)->(!Eof())

(cAliasQry)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} AT870DelRe

@description 	Exclui o contrato de um orçamento Aguardando Aprovação e retorna seu status para Em Elaboração
@param			cContrato, string, código do contrato
@param			cRevContrt, string, código da revisão
@since 			24/04/2018
@author		Mateus Boiani
/*/
Function AT870DelRe(cContrato, cRevContrt, cCodTFJ, lSemTela)
Local aArea := GetArea()
Local oModel
Local oMdlOrc
Local cRev
Local lOrcPrc
Local lRet
Local cRevAnt := CnRevAnt(.F.,cRevContrt)
Default lSemTela := isBlind()

DbSelectArea("CN9")
DbSetOrder(1) // CN9_FILIAL + CN9_NUMERO + CN9_REVISA

If CN9->(DbSeek(xFilial("CN9")+cContrato+cRevContrt))
	oModel := FwLoadModel('CNTA301')
	oModel:SetOperation( MODEL_OPERATION_DELETE )
	lRet := oModel:Activate()
	lRet := lRet .AND. oModel:CommitData() //Apaga o contrato EM REVISÃO gerado.
	If lRet
		If !IsInCallStack("At870DesRe")
			DbSelectArea("TFJ")
			DbSetOrder(1)
			If MSSEEK(xFilial("TFJ") + cCodTFJ)
				If EMPTY(TFJ->TFJ_CODTAB) //Orçamento sem precificação
					oMdlOrc := FwLoadModel('TECA740')
					lOrcPrc := .F.
				Else
					oMdlOrc := FwLoadModel('TECA740F')
					At600STabPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV ) //Atribuir nessa Static a tabela/revisão do orçamento
					lOrcPrc := .T.
				EndIf

				oMdlOrc:SetOperation( MODEL_OPERATION_DELETE )
				If ( lRet := TecActivt(@oMdlOrc))

					At740SCmt( .T. )
					lRet := oMdlOrc:CommitData()
					At740SCmt( .F. )

				EndIf
				If !lRet .AND. oMdlOrc:HasErrorMessage()
					AtErroMvc( oMdlOrc )
					MostraErro()
				ElseIf !lRet
					Help( ' ', 1, 'At870ExcR3', ,STR0173, 1, 0 )  // "Não foi possível excluir o orçamento da revisão do contrato"
				Else
					At870RemSub( , lOrcPrc, cContrato, cRevAnt )
				EndIf
			Else
				lRet := .F.
				Help( ' ', 1, 'At870NOORC', , STR0018, 1, 0)  // "Orçamento de Serviços não encontrado"
			EndIf
		EndIf
	ElseIf oModel:HasErrorMessage()
		AtErroMvc( oModel )
		MostraErro()
	Else
		Help( ' ', 1, 'At870ExcR2', ,STR0173, 1, 0 )  // "Não foi possível excluir o orçamento da revisão do contrato"
	EndIF
Else
	lRet := .F.
	Help( ' ', 1, 'At870NOCONTR', , STR0113, 1, 0)  // "Contrato não localizado no SIGAGCT, verifique!"
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} TECPrepCNC

@description 	Inclui novos clientes na CNC de acordo com o que foi incluído na Revisão do Orçamento
@param			oMdlCNC, obj, model da CNC
@param			cCliente, string, código do cliente que será incluído
@param			cLoja, string, loja do cliente que será incluído
@return		lAchou, bool, indica se o registro foi incluido com sucesso (.T.) ou se ele já existia na CNC (.T.);
								se retornar .F. indica que o registro não existe na CNC e não foi possível adiciona-lo
@since 			15/05/2018
@author		Mateus Boiani
/*/
Static Function TECPrepCNC(oMdlCNC, cCliente, cLoja)
Local lAchou := oMdlCNC:SeekLine({{"CNC_CLIENT",  cCliente},{"CNC_LOJACL", cLoja}})
Local aProp := GetPropMdl(oMdlCNC)
Local oStrtCNC := oMdlCNC:GetStruct()
Local bCNCCli := oStrtCNC:GetProperty("CNC_CLIENT", MODEL_FIELD_WHEN)
Local bCNCLoj := oStrtCNC:GetProperty("CNC_LOJACL", MODEL_FIELD_WHEN)
Local bCNCNom := oStrtCNC:GetProperty("CNC_NOME", MODEL_FIELD_WHEN)

If !lAchou
	oMdlCNC:SetNoInsertLine(.F.)
		oMdlCNC:GoLine(oMdlCNC:AddLine())
		oMdlCNC:SetNoUpdateLine(.F.)

			oStrtCNC:SetProperty("CNC_CLIENT"	,MODEL_FIELD_WHEN,{||.T.})
			oStrtCNC:SetProperty("CNC_LOJACL"		,MODEL_FIELD_WHEN,{||.T.})
			oStrtCNC:SetProperty("CNC_NOME"		,MODEL_FIELD_WHEN,{||.T.})

			lAchou := oMdlCNC:SetValue("CNC_CLIENT", cCliente)
			lAchou := lAchou .AND. oMdlCNC:SetValue("CNC_LOJACL", cLoja)

			oStrtCNC:SetProperty("CNC_CLIENT"	,MODEL_FIELD_WHEN,bCNCCli)
			oStrtCNC:SetProperty("CNC_LOJACL"		,MODEL_FIELD_WHEN,bCNCLoj)
			oStrtCNC:SetProperty("CNC_NOME"		,MODEL_FIELD_WHEN,bCNCNom)

	RstPropMdl(oMdlCNC,aProp)
EndIf

Return lAchou

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870revMt
Atualiza os saldos da TFH e TFG no modelo da revisão

@author 	Diego A. Bezerra
@since		30/05/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At870revMt(oModel,cTabela,cCod)
Local oMdlTFG		:= oModel:GetModel('TFG_MI')
Local oMdlTFH		:= oModel:GetModel('TFH_MC')

If cTabela == 'TFG'
	TFG->(DbSetOrder(1))
	If TFG->(DbSeek(xFilial("TFG") + cCod ))
		If oMdlTFG:GetValue('TFG_QTDVEN') <> TFG->TFG_QTDVEN
			oMdlTFG:LoadValue('TFG_SLD', TFG->TFG_SLD + (oMdlTFG:GetValue('TFG_QTDVEN') - TFG->TFG_QTDVEN) )
		EndIf
	EndIf
Else
	TFH->(DbSetOrder(1))
	If TFH->(DbSeek(xFilial("TFH") + cCod ))
		If oMdlTFH:GetValue('TFH_QTDVEN') <> TFH->TFH_QTDVEN
			oMdlTFH:LoadValue('TFH_SLD', TFH->TFH_SLD + (oMdlTFH:GetValue('TFH_QTDVEN') - TFH->TFH_QTDVEN) )
		EndIf
	EndIf
EndIf

Return nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} copyTWZ

@author guilherme.pimentel

@since 18/06/2018
@version 12
@param cCodTFJAnt	Codigo do orçamento de serviços revisado
@param cCodTFJ		Codigo do orçamento de serviços novo

@description
Realiza a copia dos lançamentos de custo realizados no orçamento de serviços para a nova revisão
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function copyTWZ(cCodTFJAnt,cCodTFJ)

Local cAliasQry	:= GetNextAlias()
Local aArea		:= GetArea()
Local nTotal := 0
Local oDlg		:= nil
Local oSayMtr	:= nil
Local nMeter	:= 0

DbSelectArea("TWZ")
TWZ->(DbSetOrder(1))

BeginSQL Alias cAliasQry
	SELECT TWZ_CODIGO
		FROM %Table:TWZ% TWZ
	WHERE
		TWZ.TWZ_FILIAL = %xFilial:TWZ% AND
		TWZ.TWZ_CODORC = %Exp:cCodTFJAnt% AND
		TWZ.%notDel%
EndSql

While (cAliasQry)->(!EOF())
	nTotal++
	(cAliasQry)->(DbSkip())
End

(cAliasQry)->(DbGoTop())

If isBlind()
	UpdtTWS(cAliasQry, cCodTFJ, cCodTFJAnt)
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0265 //"Atualizando registro de custo"
		oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (UpdtTWS(cAliasQry, cCodTFJ, cCodTFJAnt,@oDlg,@oMeter))
EndIf

RestArea(aArea)
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870gEnce

@author Mateus Boiani
@since 02/07/2018
@description Busca no banco de dados se TFL x TFF x TFI estão encerrados
@param cCodTFJ	, string, Codigo do orçamento de serviços verificado
@return aRet, array, itens do orçamento
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870gEnce(cCodTFJ)
Local aRet := {}
Local aArea := GetArea()
Local aAreaTFJ := TFJ->(GetArea())
Local cTabTemp := GetNextAlias()
Local cQuery

cQuery		:= "SELECT TFL.TFL_ENCE AS ENC_TFL,"
cQuery		+=       " TFL.R_E_C_N_O_ AS REC_TFL, "
cQuery		+=       " TFF.TFF_ENCE AS ENC_TFF, "
cQuery		+=       " TFF.R_E_C_N_O_ AS REC_TFF, "
cQuery		+=       " TFI.TFI_ENCE AS ENC_TFI, "
cQuery		+=       " TFI.R_E_C_N_O_ AS REC_TFI "
cQuery		+= " FROM " + RetSQLName("TFL") + " TFL "

cQuery		+= " LEFT JOIN " + RetSQLName("TFF") + " TFF "
cQuery		+= " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery		+= " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "

cQuery		+= " LEFT JOIN " + RetSQLName("TFI") + " TFI "
cQuery		+= " ON TFI.TFI_FILIAL = '" + xFilial("TFI") + "' "
cQuery		+= " AND TFI.TFI_CODPAI = TFL.TFL_CODIGO "

cQuery		+= " WHERE TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery		+= " AND TFL.TFL_CODPAI = '" + cCodTFJ + "' "
cQuery		+= " AND TFL.D_E_L_E_T_ = ' ' "
cQuery		+= " AND (TFI.D_E_L_E_T_ = ' ' OR TFI.D_E_L_E_T_ IS NULL ) "
cQuery		+= " AND (TFF.D_E_L_E_T_ = ' ' OR TFF.D_E_L_E_T_ IS NULL ) "

//Os itens do array precisam estar na mesma ordem no momento do diff
cQuery		+= " ORDER BY TFL.R_E_C_N_O_, TFF.R_E_C_N_O_, TFI.R_E_C_N_O_ "


cQuery		:= ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cTabTemp , .T., .T.)
While ( cTabTemp  )->( !EOF() )
	AADD(aRet, {( cTabTemp )->(REC_TFL),;
				 ( cTabTemp )->(ENC_TFL),;
				 ( cTabTemp )->(REC_TFF),;
				 ( cTabTemp )->(ENC_TFF),;
				 ( cTabTemp )->(REC_TFI),;
				 ( cTabTemp )->(ENC_TFI),;
				 .F.,.F.,.F.})
	( cTabTemp  )->( DbSkip() )
End
( cTabTemp  )->(DbCloseArea())

RestArea(aAreaTFJ)
RestArea(aArea)

Return aRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870DelIn

@author Mateus Lando
@since 09/11/2018
@description Função para apagar do modelo as linhas que não tem código do produto
@param oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870DelIn(oModel)
Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local oMdlRh	:= oModel:GetModel('TFF_RH')
Local oMdlLE	:= oModel:GetModel('TFI_LE')
Local oMdlMI	:= oModel:GetModel('TFG_MI')
Local oMdlMC	:= oModel:GetModel('TFH_MC')
Local nI		:= 0
Local nL		:= 0
Local nK		:= 0
Local nJ		:= 0
Local aSaveLines := FwSaveRows()
Local cId 		:= oModel:GetId()
Local lRet := .T.

If IsInCallStack("At870Revis")
	For nL := 1 To oMdlLoc:Length()
		oMdlLoc:Goline( nL )
		If !oMdlLoc:IsDeleted()

			For nI := 1 To oMdlRh:Length()
				oMdlRH:GoLine( nI )
				If oMdlRH:IsUpdated() .And. !oMdlRH:IsDeleted() .And. Empty(oMdlRH:GetValue("TFF_PRODUT"))
					lRet := lRet .AND. oMdlRH:DeleteLine()
				Else
					If cId == 'TECA740'
						For nJ := 1 To oMdlMI:Length()
							oMdlMI:GoLine( nJ )
							If oMdlMI:IsUpdated() .And. !oMdlMI:IsDeleted() .And. Empty(oMdlMI:GetValue("TFG_PRODUT"))
								lRet := lRet .AND. oMdlMI:DeleteLine()
							EndIf
						Next nJ

						For nJ := 1 To oMdlMC:Length()
							oMdlMC:GoLine( nJ )
							If oMdlMC:IsUpdated() .And. !oMdlMC:IsDeleted() .And. Empty(oMdlMC:GetValue("TFH_PRODUT"))
								lRet := lRet .AND. oMdlMC:DeleteLine()
							EndIf
						Next nJ
					EndIf
				EndIf
			Next nI

			For nI := 1 To oMdlLE:Length()
				oMdlLE:GoLine( nI )
				If oMdlLE:IsUpdated() .And. !oMdlLE:IsDeleted() .And. Empty(oMdlLE:GetValue("TFI_PRODUT"))
					lRet := lRet .AND. oMdlLE:DeleteLine()
				EndIf
			Next nI

			If cId == 'TECA740F'
				For nI := 1 To oMdlMI:Length()
					oMdlMI:GoLine( nI )
					If oMdlMI:IsUpdated() .And. !oMdlMI:IsDeleted() .And. Empty(oMdlMI:GetValue("TFG_PRODUT"))
						lRet := lRet .AND. oMdlMI:DeleteLine()
					EndIf
				Next nI

				For nI := 1 To oMdlMC:Length()
					oMdlMC:GoLine( nI )
					If oMdlMC:IsUpdated() .And. !oMdlMC:IsDeleted() .And. Empty(oMdlMC:GetValue("TFH_PRODUT"))
						lRet := lRet .AND. oMdlMC:DeleteLine()
					EndIf
				Next nI
			EndIf
		EndIf
	Next nL
EndIf
FWRestRows( aSaveLines )

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870TFLSk

@author fabiansa.silva
@since 13/02/2019
@description Função para localizar o orçamento de Origem
@param lOrcRev - Orçamento em revisão, caso afirmativo, busca o orçamento de origem
 		oTFLDetail - Modelo TFL
 		cFieldTFL - Campo TFL a ser localizado
 		cItemTFL - Valor o Campo TFL
		nRecTFF - Registro do Orçamento de Origem
		lValidDel - Valida registro excluído (busca no modelo)
@ return lRet - Orçamento Localizado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870TFLSk( lOrcRev, oTFLDetail, cFieldTFL, cItemTFL, ;
							nRecTFF, lValidDel )

Local aAreaTFL 	:= {}
Local cChvTFL 	:= ""
Local lRet 		:= .F.

Default lValidDel := .F.

If !lOrcRev
	lRet := oTFLDetail:SeekLine({{cFieldTFL,cItemTFL}}) .AND. (!lValidDel  .AND. !oTFLDetail:IsDeleted())
Else
	aAreaTFL := TFL->(GetArea())
	TFL->(DbSetOrder(4)) //TFL_FILIAL + TFL_CONTRT + TFL_CONREV
	cChvTFL := oTFLDetail:GetValue("TFL_FILIAL") + oTFLDetail:GetValue("TFL_CONTRT") + oTFLDetail:GetValue("TFL_CONREV")
	TFL->(DbSeek(cChvTFL))

	Do While !lRet .AND. TFL->(!Eof() .AND. cChvTFL == FIELD->TFL_FILIAL + FIELD->TFL_CONTRT + FIELD->TFL_CONREV)
		If TFL->( FieldGet( FieldPos(cFieldTFL)))  == cItemTFL
			lRet := .T.
			nRecTFF := TFL->(Recno())
		Else
			TFL->(DbSkip(1))
		EndIf
	EndDo
	RestArea(aAreaTFL)
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870MdlS

@author fabiansa.silva
@since 13/02/2019
@description Função para localizar o registro no model/na tabela relacionada
@param lOrcRev - Orçamento em revisão ?
		oModel - Modelo a ser localizado
		cModel - Id do Modelo
		cField2 - Campo de Busca,
		cItem2 - Valor do Campo de Buscao
		aRecPai - Recno do Registro Relacionado (Pai)
		aAliasPai - Alias do registro relacionadio (pai)
		lValidDel - Valida registro deletado (busca no model)
		cFieldGet - Campo de registro
		uFieldRet - Valor do campo de retorno
@ return lRet - Registro Localizado
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At870MdlS(lOrcRev, oModel, cModel, cField2, ;
						 cItem2, aRecPai, aAliasPai,lValidDel,;
						  cFieldGet, uFieldRet)

Local lRet 			:= .F.
Local aRelation 	:= {}
Local bFiltro 		:= {}
Local cFiltro 		:= ""
Local nC 			:= 0
Local uValue 		:= ""
Local cQuot 		:= ""
Local cAliasM 		:= Left(cModel,3)
Local cAliasPai 	:= ""
Local cAliasRel 	:= ""
Local aArea 		:= {}
Local aAreaPai 		:= {}
Local aAreaM 		:= {}
Local lProssegue 	:= .T.

If !lOrcRev
	lRet := oModel:SeekLine({{cField2,cItem2}}) .AND. ( !lValidDel .OR. !oModel:IsDeleted())
Else
	aRelation := oModel:GetRelation(cModel)
	If Len(aRecPai) > 0 .AND. Len(aRecPai) == Len(aAliasPai) .AND. Len(aRelation) >= 2
		aArea := GetArea()

		For nC := 1 to Len(aAliasPai)

			aAdd(aAreaPai, (aAliasPai[nC])->(GetArea()) )

			If !Empty(aRecPai[nC])

				cAliasPai += "|"+aAliasPai[nC]

				(aAliasPai[nC])->(DbGoto(aRecPai[nC]))
			Else
				lProssegue := .F.
				Exit
			EndIf

		Next nC

		If lProssegue
			cQuot := IIF(ValType(cItem2) == "C" , "'", "")
			cFiltro := cField2 + " = " + cQuot + cValToChar(cItem2) + cQuot

			For nC := 1 to Len(aRelation[1])

				cAliasRel := Left(aRelation[1][nC][2],3)

				If cAliasRel $ cAliasPai
					uValue := (cAliasRel)->(FieldGet(FieldPos(aRelation[1][nC][2])))
				Else
					uValue := &(aRelation[1][nC][2])
				EndIf

				cQuot := IIF(ValType(uValue) == "C" , "'", "")
				cFiltro += " .AND. " + aRelation[1][nC][1] + " = " + cQuot + cValToChar(uValue) + cQuot
			Next nC

			aAreaM := (cAliasM)->(GetArea())

			(cAliasM)->(DbSetFilter({|| &cFiltro}, cFiltro))
			(cAliasM)->(DbGoTop())
			lRet := (cAliasM)->(!Eof())
			If lRet .AND. !empty(cFieldGet)
				If cFieldGet <> "RECNO"
					uFieldRet := (cAliasM)->(FieldGet(FieldPos(cFieldGet)))
				Else
					uFieldRet := (cAliasM)->(Recno())
				EndIf
			EndIf

			(cAliasM)->(DBClearFilter())
			RestArea(aAreaM)
		EndIf
		For nC := 1 to Len(aAreaPai)
			RestArea(aAreaPai[nC])
		Next nC
		RestArea(aArea)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT870IsAct(cCont)

Verifica se o contrato possui orçamento ativo na TFJ e orçamento em revisão ao mesmo tempo

@author Diego Bezerra
@since 02/04/2019
/*/
//-------------------------------------------------------------------
Function AT870IsAct(cCont)

Local lRet := .T.
Local cAliasTFJ	:= GetNextAlias()
Local aArea := GetArea()

BeginSQL Alias cAliasTFJ
	SELECT  COUNT(1)  AS result
		FROM %Table:TFJ% TFJ
	WHERE
		TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
		TFJ.TFJ_CONTRT = %Exp:cCont% AND
		(TFJ.TFJ_STATUS = '1' OR TFJ.TFJ_STATUS = '2') AND
		TFJ.%notDel%
EndSql

If (cAliasTFJ)->(!EOF())
	lRet := (cAliasTFJ)->result == 2
EndIf

(cAliasTFJ)->(DbCloseArea())
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At870Docum(cCont)

Banco de Conhecimento

@author Luiz Gabriel
@since 04/06/2019
/*/
//-------------------------------------------------------------------
Function At870Docum()
Local aAreaCN9	:= CN9->(GetArea())
Local nRecnoCN9	:= CN9->(Recno())

//VARIAVEIS ADICIONADAS DEVIDO A UTILIZAÇÃO NA FUNÇÃO MSDOCUMENT.
Private aRotina	:= {}
Private cCadastro	:= "Contratos - Documentos"		//"Contratos - Documentos"

Aadd(aRotina,{,,,3,})
MsDocument('CN9',CN9->(Recno()),1)
CN9->(dbGoTo(nRecnoCN9))
aRotina := {}

RestArea(aAreaCN9)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetIdPed

@author boiani
@since 17/06/2019
/*/
//-------------------------------------------------------------------
Static Function GetIdPed(cContra,cRev,cPlan,cCodIss, aISSxID)
Local cRet := ""
Local aArea := GetArea()
Local cSql := ""
Local cAliasAux := GetNextAlias()
Local nAux
Local cAux
Local nX

If (nAux := ASCAN(aISSxID, {|a| a[1] == cCodISS})) > 0
	cRet := aISSxID[nAux][2]
EndIf

If EMPTY(cRet)
	cSql += " SELECT CNB.CNB_IDPED FROM " + RetSqlName("CNB") + " CNB "
	cSql += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cSql += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cSql += " SB1.D_E_L_E_T_ = ' ' AND "
	cSql += " CNB.CNB_PRODUT = SB1.B1_COD "
	cSql += " WHERE CNB.CNB_FILIAL = '" + xFilial("CNB") + "' AND "
	cSql += " CNB.D_E_L_E_T_ = ' ' AND "
	cSql += " CNB.CNB_CONTRA = '" + cContra + "' AND "
	cSql += " CNB.CNB_REVISA = '" + cRev + "' AND "
	cSql += " CNB.CNB_NUMERO = '" + cPlan + "' AND "
	cSql += " SB1.B1_CODISS = '" + cCodIss + "' "

	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

	If (cAliasAux)->(EOF())
		(cAliasAux)->(DbCloseArea())
		cAliasAux := GetNextAlias()
		cSql := " SELECT MAX(CNB.CNB_IDPED) CNB_IDPED FROM " + RetSqlName("CNB") + " CNB "
		cSql += " WHERE CNB.CNB_FILIAL = '" + xFilial("CNB") + "' AND "
		cSql += " CNB.D_E_L_E_T_ = ' ' AND "
		cSql += " CNB.CNB_CONTRA = '" + cContra + "' AND "
		cSql += " CNB.CNB_REVISA = '" + cRev + "' AND "
		cSql += " CNB.CNB_NUMERO = '" + cPlan + "' "
		cSql := ChangeQuery(cSql)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)
		For nX := 1 to LEN(aISSxID)
			If aISSxID[nX][2] > cAux
				cAux := aISSxID[nX][2]
			EndIf
		Next nX
		If !EMPTY(cAux) .AND. cAux > (cAliasAux)->(CNB_IDPED)
			cRet := Soma1(cAux)
		Else
			cRet := Soma1((cAliasAux)->(CNB_IDPED))
		EndIf

		AADD(aISSxID, {cCodIss,cRet})
		(cAliasAux)->(DbCloseArea())
	Else
		cRet := (cAliasAux)->(CNB_IDPED)
		AADD(aISSxID, {cCodIss,cRet})
		(cAliasAux)->(DbCloseArea())
	EndIf
	RestArea(aArea)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At870DlCNA(cContr,cRevCnt,cPlan)

Verifica se existe local (TFL) para a planilha (CNA), se não existir deleta a planilha.

@author Kaique Schiller
@since 22/07/2019
/*/
//-------------------------------------------------------------------
Static Function At870DlCNA(cContr,cRevCnt,cPlan,cCodTFJ)
Local lRet         := .F.
Local aAreaTFL    := TFL->(GetArea())
Local cAliasQry    := GetNextAlias()

If AT870CtRev(cCodTfj)
	BeginSQL Alias cAliasQry

		SELECT TFL_CODIGO AS TFL_CODSUB
			FROM %Table:TFL% TFL        
		WHERE TFL.TFL_FILIAL = %xFilial:TFL% 
			AND TFL.TFL_CODPAI = %Exp:cCodTFJ% 
			AND TFL.TFL_PLAN   = %Exp:cPlan%   
			AND TFL.%notDel%
	EndSql
Else
	BeginSQL Alias cAliasQry

		SELECT TFL_CODSUB
			FROM %Table:TFL% TFL        
		WHERE TFL.TFL_FILIAL = %xFilial:TFL% 
			AND TFL.TFL_CONTRT = %Exp:cContr%  
			AND TFL.TFL_CONREV = %Exp:cRevCnt% 
			AND TFL.TFL_PLAN   = %Exp:cPlan%   
			AND TFL.%notDel%
	EndSql
EndIf

While (cAliasQry)->(!EOF())
	lRet := .T.
	If !EMPTY((cAliasQry)->TFL_CODSUB)
		lRet := .F.
		Exit
	EndIf
	(cAliasQry)->(dbSkip()) 
End

(cAliasQry)->(DbCloseArea())

RestArea(aAreaTFL)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuApont
@author Diego Bezerra
@since 17/10/2019
@version 12.1.25
@param cGesMat, String, tipo de apontamento de materiais
@param cCodTFJ, String, Codigo do orçamento de serviços
@description Atualiza a referência dos apontamentos de materiais de implantação e consumo 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtuApont(cCodTFJ, cGesMat)

Local cAliasTFL := GetNextAlias()
Local aArea		:= GetArea()
Local aAreaTFL	:= TFL->(GetArea())
Local cQry		:= ""
Local oDlg		:= nil
Local oSayMtr	:= nil
Local nMeter	:= 0
Local nTotal	:= 0

cQry := "SELECT TFL_CODIGO, TFL_CODSUB, TFL_CONTRT, TFL_CONREV FROM " + retSqlName("TFL") + " TFL "
cQry += "WHERE TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
cQry += "TFL.TFL_CODPAI = '" + cCodTFJ + "' AND "
cqry += "TFL.D_E_L_E_T_ = ' '" 

cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTFL, .F., .T.)

While (cAliasTFL)->(!EOF())
	nTotal++
	(cAliasTFL)->(dbSkip())
End

(cAliasTFL)->(DbGoTop())

If  Empty (cGesMat) .or. cGesMat $ "1|4|5"
	If isBlind()
		AtAptMat(cAliasTFL,cCodTFJ, cGesMat)
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0266 //"Atualizando apontamentos por item"
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (AtAptMat(cAliasTFL,cCodTFJ, cGesMat,@oDlg,@oMeter))
	EndIf
EndIf

nMeter := 0
oDlg := nil
oSayMtr := nil

(cAliasTFL)->(DbGoTop())
	
If Empty (cGesMat) .or. cGesMat $ "2|4|5"
	If isBlind()
		AtAptTGU(cAliasTFL,cCodTFJ, cGesMat)
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0267 //"Atualizando apontamentos por valor"
			oSayMtr := tSay():New(10,10,{||STR0257},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (AtAptTGU(cAliasTFL,cCodTFJ, cGesMat,@oDlg,@oMeter))
	EndIf
EndIf

(cAliasTFL)->(dbCloseArea())
RestArea(aAreaTFL)
RestArea(aArea)
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtAptMat
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função AtuApont com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtAptMat(cAliasTFL,cCodTFJ, cGesMat, oDlg ,oMeter)
Local cQry		:= ""
Local cAliasTFG := GetNextAlias()
Local cAliasTFH	:= GetNextAlias()
Local cAliasTFS	:= GetNextAlias()
Local cAliasTFT	:= GetNextAlias()
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

While (cAliasTFL)->(!EOF())
	// DADOS DOS MATERIAIS DE IMPLANTAÇÃO
	cQry := "SELECT TFG_COD, TFG_CODSUB FROM " + retSqlName("TFG") + " TFG "
	cQry += "WHERE TFG.TFG_CONTRT = '" + (cAliasTFL)->TFL_CONTRT + "' "
	cQry += "AND TFG.TFG_CONREV = '"  + (cAliasTFL)->TFL_CONREV + "' "
	cQry += "AND TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
	cQry += "AND TFG.D_E_L_E_T_ = ' '"
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTFG, .F., .T.)
	
	// DADOS DOS MATERIAIS DE CONSUMO
	cQry := "SELECT TFH_COD, TFH_CODSUB FROM " + retSqlName("TFH") + " TFH "
	cQry += "WHERE TFH.TFH_CONTRT = '" + (cAliasTFL)->TFL_CONTRT + "' "
	cQry += "AND TFH.TFH_CONREV = '"  + (cAliasTFL)->TFL_CONREV + "' "
	cQry += "AND TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
	cQry += "AND TFH.D_E_L_E_T_ = ' '"
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTFH, .F., .T.)
	
	While (cAliasTFG)->(!EOF())
	
		// DADOS DOS APONTAMENTOS DE MATERIAIS DE IMPLANTAÇÃO
		cQry := "SELECT R_E_C_N_O_ as REC FROM " + retSqlName("TFS") + " TFS "
		cQry += "WHERE TFS.TFS_CODTFG = '" + (cAliasTFG)->TFG_COD + "' "
		cQry += "AND TFS.TFS_FILIAL ='" + xFilial("TFS") + "' "
		cQry += "AND TFS.D_E_L_E_T_ = ' '"
		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTFS, .F., .T.)
		
		While (cAliasTFS)->(!EOF())
			// Atualizando os dados dos apontamentos de materiais de implantação
			TFS->(DbGoTo((cAliasTFS)->REC))
			TFS->(RecLock("TFS", .F.))
			TFS->TFS_CODTFG := (cAliasTFG)->TFG_CODSUB
			TFS->TFS_CODTFL := (cAliasTFL)->TFL_CODSUB
			TFS->(MsUnlock())
			
			(cAliasTFS)->(dbSkip())
		End
		(cAliasTFG)->(dbSkip())
		(cAliasTFS)->(dbCloseArea())
	End
	(cAliasTFG)->(dbCloseArea())
	
	While (cAliasTFH)->(!EOF())
		
		// DADOS DOS APONTAMENTOS DE MATERIAIS DE CONSUMO
		cQry := "SELECT R_E_C_N_O_ as REC FROM " + retSqlName("TFT") + " TFT "
		cQry += "WHERE TFT.TFT_CODTFH = '" + (cAliasTFH)->TFH_COD + "' "
		cQry += "AND TFT.TFT_FILIAL ='" + xFilial("TFT")+"' "
		cQry += "AND TFT.D_E_L_E_T_ = ' '"
		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTFT, .F., .T.)
		
		While (cAliasTFT)->(!EOF())
			// Atualizando os dados dos apontamentos de materiais de consumo
			TFT->(DbGoTo((cAliasTFT)->REC))
			TFT->(RecLock("TFT", .F.))
			TFT->TFT_CODTFH := (cAliasTFH)->TFH_CODSUB
			TFT->TFT_CODTFL := (cAliasTFL)->TFL_CODSUB
			TFT->(MsUnlock())			
			
			(cAliasTFT)->(dbSkip())
		End
		(cAliasTFH)->(dbSkip())
		(cAliasTFT)->(dbCloseArea())
	End
	(cAliasTFH)->(dbCloseArea())
	
	(cAliasTFL)->(dbSkip())
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
End
If lLoadBar
	oDlg:End()
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtAptMat
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função AtuApont com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtAptTGU(cAliasTFL,cCodTFJ, cGesMat,oDlg,oMeter)
Local cQry := ""
Local cAliasTGU := GetNextAlias()
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

While (cAliasTFL)->(!EOF())
	// DADOS DOS APONTAMENTOS DE MATERIAIS DE POR VALOR
	cQry := "SELECT R_E_C_N_O_ as REC FROM "+retSqlName("TGU")+" TGU "
	cQry += "WHERE TGU.TGU_CODTFL = '"+(cAliasTFL)->TFL_CODIGO+"' "
	cQry += "AND TGU.TGU_FILIAL ='"+xFilial("TGU")+"' "
	cQry += "AND TGU.D_E_L_E_T_ = ' '"
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTGU, .F., .T.)
	
	While (cAliasTGU)->(!EOF())
		TGU->(DbGoTo((cAliasTGU)->REC))
		TGU->(RecLock("TGU", .F.))
		TGU->TGU_CODTFL := (cAliasTFL)->TFL_CODSUB
		TGU->(MsUnlock())
		
		(caliasTGU)->(dbSkip())
	End
	(cAliasTGU)->(dbCloseArea())
	(cAliasTFL)->(dbSkip())
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
End
If lLoadBar
	oDlg:End()
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtAptMat
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função copyTWZ com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdtTWS(cAliasQry, cCodTFJ, cCodTFJAnt,oDlg,oMeter)
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

While (cAliasQry)->(!EOF())
	If TWZ->(DbSeek(xFilial("TWZ")+(cAliasQry)->TWZ_CODIGO))
		TWZ->(RecLock("TWZ", .F.))
		TWZ->TWZ_CODORC := cCodTFJ
		TWZ->(MsUnlock())
	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
If lLoadBar
	oDlg:End()
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SumABQConf
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função At870AtAlo com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SumABQConf(cAliasABQ,aInfo,cIn,oDlg,oMeter)
Local aAux
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

//Busca relação entre configuração anterior e atual
While (cAliasABQ)->(!EOF())
	aAux := Array(3)
	aAux[1] := (cAliasABQ)->ABQ_CONTRT+(cAliasABQ)->ABQ_ITEM+(cAliasABQ)->ABQ_ORIGEM
	aAux[2] := (cAliasABQ)->CONTRTSUB+(cAliasABQ)->ITEMSUB+(cAliasABQ)->ORIGEMSUB
	aAux[3] := (cAliasABQ)->ABQ_TOTAL -(cAliasABQ)->ABQ_SALDO//consumido da configuração original

	aAdd(aInfo, aAux)
	cIn += (cAliasABQ)->ABQ_CONTRT+(cAliasABQ)->ABQ_ITEM+(cAliasABQ)->ABQ_ORIGEM+","
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
	(cAliasABQ)->(DbSkip())
EndDo
If lLoadBar
	oDlg:End()
EndIf

(cAliasABQ)->(DbCloseArea())

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdABBIdCf
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função At870AtAlo com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdABBIdCf(cAliasABB, aInfo, oDlg, oMeter)
Local nPos		:= 0
Local nCount 	:= 0
Local lLoadBar 	:= .F.
Local nX		:= 0
Local cQry 		:= GetNextAlias()
Local cIn 		:= ""
Local lRet 		:= .T.
Local nStatus	:= 0

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

//Realiza atuação da agenda do atendente
For nX := 1 To LEN(aInfo)
	nStatus := TCSQLEXEC("UPDATE " + RetSqlName( "ABB" ) + " SET ABB_IDCFAL = '" + aInfo[nX][2] +;
	"' WHERE ABB_IDCFAL = '" + aInfo[nX][1] + "' AND D_E_L_E_T_ = ' ' AND ABB_FILIAL = '"+xFilial('ABB')+"'")
	If (nStatus < 0)
		conout("Erro UpdABBIdCf() " + TCSQLError())
	EndIf
	cIn += " '" + aInfo[nX][1] + "' "
	If nX != LEN(aInfo)
		cIn += ","
	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
Next nX
cIn := "% IN ( " + cIn + ") %"
BeginSQL Alias cQry
	SELECT ABB_IDCFAL, ABB.R_E_C_N_O_ AS REGISTRO
		FROM %Table:ABB% ABB
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
		AND ABB.%NotDel%
		AND ABB.ABB_IDCFAL %Exp:cIn%
EndSQL
While (cQry)->(!EOF())
	nPos := aScan(aInfo, {|x| x[1] == (cQry)->ABB_IDCFAL })//encontra registro substituido
	If nPos > 0 
		ABB->(DbGoTo((cQry)->REGISTRO))
		RecLock("ABB", .F.)
			ABB->ABB_IDCFAL :=  aInfo[nPos][2]//Atualiza IDCFAL
		ABB->(MsUnlock())
	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
	(cQry)->(DbSkip())
EndDo
(cQry)->(DbCloseArea())

If lLoadBar
	oDlg:End()
EndIf
(cAliasABB)->(DbCloseArea())
Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdABQSald
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função At870AtAlo com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdABQSald(aInfo,oDlg,oMeter)
Local nCount := 0
Local nI
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

//Atualiza saldo da configuração de alocação
For nI:=1 To Len(aInfo)
	//Atualiza Saldo
	ABQ->(DbSetOrder(1))//ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
	If ABQ->(DbSeek(xFilial("ABQ")+aInfo[nI][2]))
		RecLock("ABQ", .F.)
		ABQ->ABQ_SALDO := ABQ->ABQ_TOTAL - aInfo[nI][3]//Desconta o que já foi consumido na configuração anterior
		MsUnlock()
	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
Next nI
If lLoadBar
	oDlg:End()
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdTGYxTFF
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função At870AtGES com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdTGYxTFF(cAliasTGY, aCodTFF,oDlg,oMeter)
Local nPosTFF
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

//Realiza a atualização das configurações do efetivo
While (cAliasTGY)->(!Eof())
	//Atualiza TGY
	If TGY->( DbSeek( xFilial("TGY")+(cAliasTGY)->TGY_ESCALA+(cAliasTGY)->TGY_CODTDX+;
					(cAliasTGY)->TGY_CODTFF+(cAliasTGY)->TGY_ITEM ) )

		nPosTFF := aScan( aCodTFF, { |x| x[1] == (cAliasTGY)->TGY_CODTFF } )

		If nPosTFF > 0
			RecLock("TGY", .F.)
			TGY->TGY_CODTFF := aCodTFF[ nPosTFF, 2 ]
			TGY->(msUnlock())
		EndIf

	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
	(cAliasTGY)->(DbSkip())
EndDo
If lLoadBar
	oDlg:End()
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdTGZxTFF
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função At870AtGES com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdTGZxTFF(cAliasTGZ, aCodTFF,oDlg,oMeter)
Local nPosTFF
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

//Realiza a atualização das configurações do efetivo
While (cAliasTGZ)->(!Eof())
	//Atualiza TGZ
	If TGZ->( DbSeek( xFilial("TGZ")+(cAliasTGZ)->TGZ_ESCALA+(cAliasTGZ)->TGZ_CODTDX+;
					(cAliasTGZ)->TGZ_CODTFF+(cAliasTGZ)->TGZ_ITEM ) )

		nPosTFF := aScan( aCodTFF, { |x| x[1] == (cAliasTGZ)->TGZ_CODTFF } )

		If nPosTFF > 0
			RecLock("TGZ", .F.)
			TGZ->TGZ_CODTFF := aCodTFF[ nPosTFF, 2 ]
			TGZ->(msUnlock())
		EndIf

	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
	(cAliasTGZ)->(DbSkip())
EndDo
If lLoadBar
	oDlg:End()
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdAB6xTFF
@author Mateus Boiani
@since 06/11/2019

@description Realiza o processamento da função At870OsMont com uma barra de load
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdAB6xTFF(cQryAB6Alt,cCodTFJ,oDlg,oMeter)
Local cNewItem := ""
Local nCount := 0
Local lLoadBar := .F.

Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

While (cQryAB6Alt)->(!EOF())

	AB6->( DbGoTo( (cQryAB6Alt)->AB6RECNO ) )

	If AB6->AB6_ITORCS <> " "
		If AB6->AB6_TPORCS == "2" .And. ;// item de Le
			TFI->(DbSeek( xFilial("TFI")+AB6->AB6_ITORCS ))

			cNewItem := TFI->TFI_CODSUB

		ElseIf AB6->AB6_TPORCS == "3" .And. ;// item de Rh
			TFF->(DbSeek( xFilial("TFF")+AB6->AB6_ITORCS ))

			cNewItem := TFF->TFF_CODSUB
		EndIf
	Else
		cNewItem := ""
	EndIf

	Reclock("AB6",.F.)
		AB6->AB6_CDORCS := cCodTFJ
		If !Empty(cNewItem)
			AB6->AB6_ITORCS := cNewItem
		EndIF
	AB6->(MsUnlock())
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf
	(cQryAB6Alt)->(DbSkip())
End
If lLoadBar
	oDlg:End()
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870GetTr

@description Função de Get/Set na variavel static lTravLin
@author	Augusto Albuquerque
@since	20/05/2019
/*/
//------------------------------------------------------------------------------
Function AT870GetTr( lSetValue )

If ValType( lSetValue ) == "L"
	lTravLin := lSetValue
EndIf

Return ( lTravLin )


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870tbl

@description Retorna as tabelas que fazem parte de uma lista de campos
@author	Diego Bezerra
@param aCampos, array, lista com o nome dos campos, no formato {"AAA_AAAAA","AA_AAAAA}
@return	aTables, array, lista com o nome das tabelas, no formato {"AAA"}
@since	31/03/2020
/*/
//------------------------------------------------------------------------------
Static function AT870tbl(aCampos)

Local cLast 	:= ""
Local aTables	:= {}
Local nX		:= 0

Default aCampos := {}

For nX := 1 to len(aCampos)
	cLast := Right(Left(aCampos[nX],3),1)
	If cLast == "_"
		If aScan(aTables, {|x| x == "S"+Left(aCampos[nX],2)}) == 0
			aAdd(aTables,"S"+Left(aCampos[nX],2))
		EndIf
	Else
		If aScan(aTables, {|x| x == Left(aCampos[nX],3)}) == 0
			aAdd(aTables,Left(aCampos[nX],3))
		EndIf
	EndIf
	
Next nX

Return aTables

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870VLCP

@description Valida se um campo pertence a uma lista de tabelas
@author	Diego Bezerra
@param cCampo, string, nome do campo
@param aTables, array, lista com os nomes das tabelas permitidas
@return	lRet, booleano, .T. = Pertence ao grupo de tabelas permitidas ; .F. não pertence ao grupo de tabelas permitidas
@since	31/03/2020
/*/
//------------------------------------------------------------------------------
Static function AT870VLCP(cCampo, aTables)

Local cLast 	:= ""
Local lRet 		:= .F.

cLast := Right(Left(cCampo,3),1)

If cLast == "_"
	lRet := aScan(aTables,{|x| x == "S"+Left(cCampo,2)}) > 0
Else
	lRet := aScan(aTables,{|x| x == Left(cCampo,3)}) > 0
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At870AddCli(cStatus, cContrato, cRevisao)
Rotina de Inclusão de Clientes (CNC) em contratos Ativos
@author Mario A. Cavenaghi - EthosX
@since  09/11/2020
/*/
//-------------------------------------------------------------------
Function At870AddCli(oBrowse, cStatus, cContrato, cRevisao)
	Local aArea := GetArea()
	Local aClientes := {}
	Local cCliente := Space(Len(SA1->(A1_COD)))
	Local cLoja := Space(Len(SA1->(A1_LOJA)))
	Local lRet := At870Perm() // Define regras de restrição
	Local lOutroReg := .F. 
	Local nOpcao := 0
	Local oCli
	Local oDlg

	If !lRet
		Help(,, 'TECA870',, STR0278, 1, 0)	//"Acesso negado: Usuário sem permissão para adicionar clientes"
	Else
		If cStatus <> DEF_TFJ_ATIVO	//	"1"
			MsgAlert(STR0279) //"Não é permitido adicionar Clientes nesse Contrato, pois não está ativo"
		ElseIf Posicione("CN9", 1, xFilial("CN9") + cContrato + cRevisao, "CN9_SITUAC") <> DEF_SVIGE	//	05 - Vigente
			MsgAlert(STR0295) //"Situação do contrato (CN9) não permite inclusão de novos clientes."
		Else
			TFJ->(dbSetOrder(5))
			TFJ->(dbSeek(xFilial() + cContrato + cRevisao))
			TFJ->(dbSkip())
			While ! TFJ->(Eof()) .And. TFJ->(TFJ_FILIAL + TFJ_CONTRT) == xFilial("TFJ") + cContrato
				If TFJ->TFJ_STATUS < DEF_TFJ_ENCERRADO	//	5 - Encerrado
					lOutroReg := .T.
					Exit
				Endif
				TFJ->(dbSkip())
			Enddo
			If lOutroReg 	//	Outros STATUS diferentes de Encerrado e Cancelado
				MsgAlert(STR0280) //"Não é permitido adicionar clientes em contratos em processo de revisão"
			Else
				SA1->(dbSetOrder(1))
				CNC->(dbSetOrder(3))
				CNC->(dbSeek(xFilial() + cContrato + cRevisao))
				While ! CNC->(Eof()) .And. CNC->(CNC_FILIAL + CNC_NUMERO + CNC_REVISA) == xFilial("CNC") + cContrato + cRevisao
					SA1->(dbSeek(xFilial() + CNC->CNC_CLIENT + CNC->CNC_LOJACL))
					aAdd(aClientes, {CNC->CNC_CLIENT, CNC->CNC_LOJACL, SA1->A1_NOME})
					CNC->(dbSkip())
				Enddo
				While lRet
					nOpcao := 0
					lRet := .F.	//	Se sair com ESC
					Define MsDialog oDlg From 0, 0 To 300, 500 Pixel TITLE STR0281 //"Inclusão de Cliente"
					@ 030, 010 ListBox oCli Fields Header STR0282, STR0283, STR0284 Size 230, 70 Of oDlg PIXEL
					oCli:SetArray(aClientes)
					oCli:bLine := {|| { ;
						aClientes[oCli:nAt,  1],;
						aClientes[oCli:nAt,  2],;
						aClientes[oCli:nAt,  3]}}
					@ 010, 010 Say STR0285  Of oDlg Pixel
					@ 010, 065 MsGet cContrato When .F.   Of oDlg Pixel
					@ 010, 190 Say STR0286              Of oDlg Pixel
					@ 010, 220 MsGet cRevisao  When .F.   Of oDlg Pixel
					@ 110, 010 Say STR0287 Of oDlg Pixel
					@ 110, 065 MsGet cCliente   F3 "SA1"  Of oDlg Pixel
					@ 110, 190 Say STR0288       Of oDlg Pixel
					@ 110, 225 MsGet cLoja                Of oDlg Pixel 
					@ 130, 010 Button STR0289         Of oDlg Pixel Size 60, 15 Action (nOpcao := 1, oDlg:End())
					@ 130, 180 Button STR0290             Of oDlg Pixel Size 60, 15 Action oDlg:End()
					Activate MsDialog oDlg Centered
					If nOpcao == 1
						If Empty(cCliente)
							MsgAlert(STR0291) //"Código do cliente não informado"
							lRet := .T.
						ElseIf ! SA1->(dbSeek(xFilial() + cCliente + cLoja))
							MsgAlert(STR0292) //"Cliente não cadastrado"
							lRet := .T.
						Elseif CNC->(dbSeek(xFilial() + cContrato + cRevisao + cCliente + cLoja))
							MsgAlert(STR0293) //"Cliente já está cadastrado no Contrato"
							lRet := .T.
						Endif
					Endif
				Enddo
				If nOpcao == 1
					CNC->(RecLock("CNC", .T.))
					CNC->CNC_FILIAL := xFilial("CNC")
					CNC->CNC_NUMERO := cContrato
					CNC->CNC_REVISA := cRevisao
					CNC->CNC_CLIENT := cCliente
					CNC->CNC_LOJACL := cLoja
					CNC->(msUnLock())
					MsgInfo(STR0294) //"Cliente incluído com sucesso !"
				Endif
			Endif
		Endif
		RestArea(aArea)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At870Perm
Verifica se o usuário tem permissão de acessar a Inclusão de Cliente no contrato vigente, mesmo se for ADMIN
@author Mario A. Cavenaghi - EthosX
@since  11/11/2020
/*/
//-------------------------------------------------------------------
Function At870Perm()
	Local cAliasQry := GetNextAlias()
	Local cQuery := ""
	Local lRet := .T.
	
	cQuery := "SELECT 1 REC "
	cQuery += "  FROM "      + RetSqlName("TIN") + " TIN "
	cQuery += " INNER JOIN " + RetSqlName("TCT") + " TCT "
	cQuery += "    ON TCT_FILIAL = '" + xFilial("TCT") + "' " 	//	Está na oredem no indice 1 do TCT
	cQuery += "   AND TCT_GRUPO  = TIN_GRUPO " 
	cQuery += "   AND TCT_ITEM   = '045' "     
	cQuery += "   AND TCT_PODE   = '1' "       
	cQuery += "   AND TCT.D_E_L_E_T_ = ' ' "   
	cQuery += " WHERE TIN_FILIAL = '" + xFilial("TIN") + "'  " 	//	Está na oredem no indice 3 do TIN
	cQuery += "   AND TIN_CODUSR = '" + __cUserId + "' " 
	cQuery += "   AND TIN_MSBLQL = '2' "     
	cQuery += "   AND TIN.D_E_L_E_T_ = ' ' " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
	lRet := ! (cAliasQry)->(Eof())
	(cAliasQry)->(dbCloseArea())

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AtQryVal
Verifica se o orçamento contem itens calculados pela planilha de preços 
@param cCodTFJ, String, Codigo do orçamento de serviços
@author Matheus Gonçalves 
@since  19/11/2020
/*/
//-------------------------------------------------------------------
Static Function AtQryVal(cCodTFJ)

	Local cAliasQry := GetNextAlias()
	Local cQuery := ""
	Local lRet := .T.

	cQuery := " SELECT 1 REC "
	cQuery += " FROM " + RetSqlName("TFF") + "  TFF "
	cQuery += " INNER JOIN "+RetSqlName("TFL")+" TFL ON TFF_FILIAL='" +  xFilial("TFF") +"' "
	cQuery += " AND TFL_CODIGO = TFF_CODPAI "
	Cquery +="	AND TFL.D_E_L_E_T_ = '' "
	cQuery += " WHERE TFL_CODPAI = '" + cCodTFJ + "' "
	cQuery += " AND TFF.TFF_CALCMD IS NOT NULL "
	cQuery += " AND TFF.TFF_PLACOD <> '' "
	cQuery += "	AND TFF.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
	lRet := ! (cAliasQry)->(Eof())
	(cAliasQry)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At870DesRe
Cria msgrun para desfazer a revisão
@author Augusto Albuquerque 
@since  29/12/2020
/*/
//-------------------------------------------------------------------
Function At870DesRe(cStatus,cCodTFJ,cContrato,cRevContrt, lOrcPrc)
Local lRet := .T.
If cStatus == DEF_TFJ_AGDAPROVA 
	If  isBlind() .OR. MsgYesNo(STR0307)  //"A operação ira Desfazer Revisão atual e o contrato voltara para o status 'Em Revisão' "
		MsgRun(STR0306,STR0304,{|| lRet := At870RevDe(cStatus,cCodTFJ,cContrato,cRevContrt, lOrcPrc) } ) // "Desfazendo..." ## "Desfazer Revisão"
	Else
		lRet := .F.
		MsgInfo(STR0308) //"Operação cancelada!"
	EndIf
Else
	lRet := .F.
	MsgInfo(STR0309) //"Para utilizar essa função é necessario selecionar um contrato com a legenda 'Aguardando Aprovação'. "
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At870RevDe
Desfaz a revisão e volta para o status "Em Revisão"
@author Augusto Albuquerque 
@since  29/12/2020
/*/
//-------------------------------------------------------------------
Static Function At870RevDe(cStatus,cCodTFJ,cContrato,cRevContrt, lOrcPrc)
Local cFilTFJ	:= ""
Local cRev		:= ""
Local cAliasQry	:= GetNextAlias()
Local lRet		:= .F.

Begin Transaction
	lRet := AT870DelRe(cContrato, cRevContrt, cCodTFJ)
	If lRet
		BeginSQL Alias cAliasQry
			SELECT  TFJ.TFJ_FILIAL, TFJ.TFJ_CONREV
			FROM %Table:TFJ% TFJ
		WHERE
			TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
			TFJ.TFJ_CONTRT = %Exp:cContrato% AND
			TFJ.TFJ_STATUS = "1" AND
			TFJ.%notDel%
		EndSql

		
		If (cAliasQry)->(!EOF())
			cRev := (cAliasQry)->TFJ_CONREV
			cFilTFJ := (cAliasQry)->TFJ_FILIAL
	
			DbSelectArea("TFJ")
			DbSetOrder(1) //TFJ_FILIAL+TFJ_CODIGO
			If MsSeek(xFilial("TFJ")+cCodTFJ)
				TFL->(DbSetOrder(2))//TFL_FILIAL+TFJ_CODPAI
				TFF->(DbSetOrder(3))//TFF_FILIAL+TFF_CODPAI
				TFL->(DbSeek(xFilial("TFL")+cCodTFJ))
				While TFL->(!EOF()) .AND. TFL->TFL_FILIAL == cFilTFJ .AND. TFL->TFL_CODPAI == cCodTFJ
					//Atualiza TFF
					If TFF->(DbSeek(xFilial("TFF")+TFL->TFL_CODIGO))
						While ( TFF->(!EOF()) .AND. TFF->TFF_FILIAL == xFilial("TFF") .AND. TFF->TFF_CODPAI == TFL->TFL_CODIGO)
							TFF->(RecLock("TFF"), .F.)
								TFF->TFF_CONREV := cRev
							TFF->(MsUnlock())
							TFF->(DbSkip())
						EndDo
					EndIf

					TFL->(DbSkip())
				EndDo
				TFJ->(RecLock("TFJ"), .F.)
					TFJ->TFJ_CONREV := cRev	
					TFJ->TFJ_STATUS := DEF_TFJ_EMREVISAO
				TFJ->(MsUnlock())
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		DisarmTransaction()
	EndIf
End Transaction

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870PlaRe
@description Função para abertura do contrato em revisão planejada.
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function AT870PlaRe( cCodTfj, cCont, cRevis,lAutomato,nOpcTela,bSemTela)
Local aArea			:= GetArea()
Local aAreaTFJ		:= TFJ->(GetArea())
Local cChave		:= ""
Local cTFJStatus	:= POSICIONE("TFJ",1,xFilial("TFJ")+cCodTfj,"TFJ_STATUS")
Local cRevisao		:= ""
Local cTfjPla		:= ""
Local cCodTR		:= CriaVar("CN0_CODIGO", .F.)	//Space(TamSx3("CN0_CODIGO")[2])
Local lTFJStatus	:= cTFJStatus == '1'
Local lHasRev		:= At580BSit(cCont) == '2'
Local lRet 			:= .T.
Local nOpcao		:= 0
Local nMod			:= 3

Default lAutomato   := .F.
Default nOpcTela    := 0
Default bSemTela    := {||.T.}

Begin Transaction
	cChave	:=	xFilial("CN9")+cCont+cRevis+cTFJStatus
	If LockByName("TEC870"+cChave,.T.,.T.)
		If lTFJStatus
			DbSelectArea("CN9")
			DbSetOrder(1)
			If CN9->(DbSeek(xFilial("CN9")+cCont+cRevis))
				If !(CN9->CN9_SITUAC == DEF_SELAB .Or. CN9->CN9_SITUAC == DEF_SAPRO .OR. CN9->CN9_SITUAC == DEF_SREVD) .AND. !lHasRev//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
					TFJ->( DbSeek( xFilial('TFJ')+cCodTFJ ) )
					cRevisao := TFJ->TFJ_PREVIS
					If lAutomato 
					    nOpcao := nOpcTela
					else 
					   	nOpcao := OpcRevisaP()
					Endif
					If nOpcao <> 0
						If nOpcao == 1 .OR. nOpcao == 2
							//Cria copia do Model da TFJ
							If lRet
								If AT870RevPl( cCodTfj ) .AND. nOpcao == 1
									nMod := MODEL_OPERATION_INSERT
									oMdlRev := FwLoadModel("TECA740")
									oMdlRev:SetOperation(MODEL_OPERATION_INSERT)
									lRet := oMdlRev:Activate(.T.)

									If lRet
										If !Empty(oMdlRev:GetErrorMessage()[MODEL_MSGERR_MESSAGE])//6
											Ft600ErroMvc( oMdlRev )
										Else
											cNewTFJ := oMdlRev:GetValue('TFJ_REFER', 'TFJ_CODIGO')
											oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_PREVIS', cRevisao )//Atualiza revisão da proposta
											oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_STATUS', DEF_TFJ_REVPLANEJ )//Coloca orçamento serviço em revisão
											//oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_TIPREV', cCodTr) //Orçamento fica com o tipo de revisão
											oMdlRev:SetValue( 'TFJ_REFER', 'TFJ_CONDPG', CN9->CN9_CONDPG ) //Atualiza a Condição de Pagamento do orçamento

											If !EMPTY(oMdlRev:GetValue("TFL_LOC", "TFL_LOCAL"))
												oMdlRev:LoadValue( 'TFL_LOC' , 'TFL_CODSUB', "" )//Atualiza CODSUB
												oMdlRev:LoadValue( 'TFL_LOC' , 'TFL_CONTRT', "" )
												oMdlRev:LoadValue( 'TFL_LOC' , 'TFL_CONREV', "" )
											EndIf
											If !EMPTY(oMdlRev:GetValue("TFF_RH", "TFF_PRODUT"))
												oMdlRev:LoadValue( 'TFF_RH'  , 'TFF_CODSUB', "" )//Atualiza CODSUB
												oMdlRev:LoadValue( 'TFF_RH' , 'TFF_CONTRT', "" )
												oMdlRev:LoadValue( 'TFF_RH' , 'TFF_CONREV', "" )
											EndIf
											If !EMPTY(oMdlRev:GetValue("TFG_MI", "TFG_PRODUT"))
												oMdlRev:LoadValue( 'TFG_MI'  , 'TFG_CODSUB', "" )//Atualiza CODSUB
												oMdlRev:LoadValue( 'TFG_MI' , 'TFG_CONTRT', "" )
												oMdlRev:LoadValue( 'TFG_MI' , 'TFG_CONREV', "" )
											EndIf
											If !EMPTY(oMdlRev:GetValue("TFH_MC", "TFH_PRODUT"))
												oMdlRev:LoadValue( 'TFH_MC'  , 'TFH_CODSUB', "" )//Atualiza CODSUB
												oMdlRev:LoadValue( 'TFH_MC' , 'TFH_CONTRT', "" )
												oMdlRev:LoadValue( 'TFH_MC' , 'TFH_CONREV', "" )
											EndIf
											
											cTpRev := At870TpCont(cCodTr)

											// bloqueia a alteração do local/posto ABS
											oMdlRev:GetModel("TFL_LOC"):GetStruct():SetProperty("TFL_LOCAL", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFL_CONTRT"))})
											// monta a validação para o campo TFL_LOCAL
											cAtuProp := RTrim( GetSX3Cache("TFL_LOCAL","X3_VALID") ) //+ " .And. At870Nwl('TFL_LOC')" -- permitir incluir novas CNCs
											If !Empty( Alltrim(cValUser := GetSX3Cache("TFL_LOCAL","X3_VLDUSER") ) )
												cAtuProp += " .And. " + cValUser
											EndIf
											bLocalVld := FwBuildFeature( STRUCT_FEATURE_VALID, cAtuProp )
											oMdlRev:GetModel("TFL_LOC"):GetStruct():SetProperty("TFL_LOCAL", MODEL_FIELD_VALID, bLocalVld )

											// bloqueia a alteração do produtos nos itens
											oMdlRev:GetModel("TFF_RH" ):GetStruct():SetProperty("TFF_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFF_CONTRT"))})
											oMdlRev:GetModel("TFG_MI" ):GetStruct():SetProperty("TFG_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFG_CONTRT"))})
											oMdlRev:GetModel("TFH_MC" ):GetStruct():SetProperty("TFH_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFH_CONTRT"))})
											oMdlRev:GetModel("TFI_LE" ):GetStruct():SetProperty("TFI_PRODUT", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFI_CONTRT"))})
											oMdlRev:GetModel("TFI_LE" ):GetStruct():SetProperty("TFI_QTDVEN", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("TFI_CONTRT"))})

											At740SLoad( oMdlRev ) // atribui o model com o conteúdo copiado para carga na view da rotina
										EndIf
									EndIf
								ElseIf nOpcao == 2
									If !AT870RevPl( cCodTfj, @cTfjPla )
										nMod := MODEL_OPERATION_UPDATE
										TFJ->( DbSeek( xFilial('TFJ')+cTfjPla ) )
										oMdlRev 		:= FwLoadModel("TECA740")
										oMdlRev:SetOperation( MODEL_OPERATION_UPDATE )

										lRet := oMdlRev:Activate()
										If lRet
											cRevisao := oMdlRev:GetValue('TFJ_REFER', 'TFJ_PREVIS')
										EndIf
									Else
										Help( ' ', 1, "At870PRev", , STR0311 , 1, 0 ) // "O orçamento não tem uma revisão planejada."
										lRet := .F.
									EndIf
								Else
									lRet := .F.
									Help( ' ', 1, "At870PRev", , STR0312 , 1, 0 ) // "O orçamento ja possui uma revisão planejada, não é possivel inserir outra revisão planejada para este orçamento."
								EndIf
							EndIf
						ElseIf nOpcao == 3
							If !AT870RevPl( cCodTfj, @cTfjPla)
								nMod := MODEL_OPERATION_DELETE
								TFJ->( DbSeek( xFilial('TFJ')+cTfjPla ) ) 
								oMdlRev := FwLoadModel("TECA740")
								oMdlRev:SetOperation(MODEL_OPERATION_DELETE)
								lRet := oMdlRev:Activate(.T.)

								If lRet
									If !Empty(oMdlRev:GetErrorMessage()[MODEL_MSGERR_MESSAGE])//6
										Ft600ErroMvc( oMdlRev )
									EndIf
								EndIf
							Else
								Help( ' ', 1, "At870PRev", , STR0313 , 1, 0 ) //"Não existe orçamento em revisao planejada."
								lRet := .F.
							EndIf
						ElseIf nOpcao == 4
							If !AT870RevPl( cCodTfj, @cTfjPla)
								nMod := MODEL_OPERATION_VIEW
								TFJ->( DbSeek( xFilial('TFJ')+cTfjPla ) ) 
								oMdlRev := FwLoadModel("TECA740")
								oMdlRev:SetOperation(MODEL_OPERATION_VIEW)
								lRet := oMdlRev:Activate(.T.)

								If lRet
									If !Empty(oMdlRev:GetErrorMessage()[MODEL_MSGERR_MESSAGE])//6
										Ft600ErroMvc( oMdlRev )
									EndIf
								EndIf
							Else
								Help( ' ', 1, "At870PRev", , STR0313 , 1, 0 ) // "Não existe orçamento em revisao planejada."
								lRet := .F.
							EndIf
						EndIf 
						If lRet
							At740FMsg( .T. ) //Habilita as mensagens de erro
							At740SCmt( .T. )//habilita commit
							AT870SETVT('1', .T.) // indica que o orçamento de serviços estará aberto na tela
							At870RestLins( oMdlRev, .F. )
							If !lAutomato
							    lRet := ( FWExecView(STR0017,"VIEWDEF.TECA740", nMod, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // 'Orçamento Serviços'
															/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )	//apresenta copia do model na interface
							Else
							    Eval(bSemTela,oMdlRev)
						    Endif
							If lRet .AND. nMod == MODEL_OPERATION_INSERT
								If TFJ->( MSSeek( xFilial('TFJ')+cNewTFJ ) )
									RecLock('TFJ',.F.)
										TFJ->TFJ_CODREL := cCodTfj
										TFJ->TFJ_CONTRT := ""
									TFJ->(MsUnlock())
								EndIf
								At740SLoad( Nil )
							EndIf
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					If lHasRev
						Help( ' ', 1, "At870PRev", , STR0243 , 1, 0 ) //"Não é possível realizar revisões em contrato com processo de revisão pendente de aprovação."
					Else
						Help( ' ', 1, "At870PRev", , STR0033, 1, 0 )	//"Não é possivel realizar revisões em contratos ainda em elaboração, para realizar alteração no contrato acesse o modulo SIGAGCT e realize as alterações!"
					EndIf
				EndIF
			EndIf
		Else
			Help( ' ', 1, "At870PRev", , STR0314, 1, 0 )	//"Contrato não vigente."
		EndIf
	Else
		Help(NIL, NIL, "AT870PlaRe", NIL, STR0244 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0245}) //"O registro está em processo de edição por outro usuáro."#"Aguarde e tente novamente."
	EndIf
End Transaction

RestArea(aAreaTFJ)
RestArea(aArea)

UnLockByName("TEC870"+cChave,.T.,.T.)

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870RevPl
@description Verifica se o contrato esta em processo de revisão planejada
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function AT870RevPl( cCodTFJ, nTfjPla )
Local cQuery	:= ""
Local cAliasTFJ
Local lRet		:= .T.

Default cTfjPla := ""
If TecVerRePl()
	cAliasTFJ	:= GetNextAlias()
	cQuery := ""
	cQuery += " SELECT TFJ.TFJ_CODIGO FROM " + RetSQLName("TFJ") + " TFJ "
	cQuery += " WHERE TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' " 
	cQuery += " AND TFJ.TFJ_CODREL = '" + cCodTFJ + "' "
	cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTFJ, .F., .T.)

	If !(cAliasTFJ)->(Eof())
		nTfjPla := (cAliasTFJ)->TFJ_CODIGO
		lRet := .F.
	Else
		lRet := .T.
	EndIf

	(cAliasTFJ)->(dbCloseArea())
EndIf
Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpcRevisaP
@description Tela para aparecer as opções da revisão planejada.
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function OpcRevisaP()
Local aItems		:= {}
Local nRadio		:= 1
Local lRet			:= .F.
Local oRadio		:= NIL
Local oDlg			:= NIL
Local oDlgSelect	:= Nil

IF !IsBlind()
    DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 150,180 PIXEL TITLE STR0315 // "Revisão Planejada"
	  @ 5, 9 SAY STR0316 SIZE 50, 30 PIXEL // "Opções"

	  aItems := {STR0317,STR0318, STR0319, STR0320} //'Incluir' ## 'Alterar' ## 'Excluir' ## 'Visualizar' 
	  oRadio := TRadMenu():New (015,009,aItems,,oDlg,,,,,,,,075,010,,,,.T.)
	  oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

	  oExit := TButton():New( 058	, 010, STR0005,oDlgSelect,{|| lRet := .F., oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

	  oRefresh := TButton():New( 058, 050, STR0275,oDlgSelect,{|| lRet := .T., oDlgSelect:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Confirma"

    ACTIVATE MSDIALOG oDlgSelect CENTER
Endif	

If !lRet
	nRadio := 0
EndIf

Return( nRadio )

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870RvPlC

Tela de Seleção do contrato para aplicar a revisão.
@sample 	AT870RvPlC() 
@author		Augusto Albuquerque
@since		02/07/2021
/*/
//------------------------------------------------------------------------------
Function AT870RvPlC()
Local oMrkBrowse	:= FWMarkBrowse():New()
Local oGSTmpTb		:= Nil
Local lOk 			:= .T.
Local aStruct		:= {}
Local aIdx			:= {}
Local aColumns    	:= {}
Local aSeek			:= {}
Local aInsertTmp	:= {}
Local cQuery 		:= ""
Local cContr		:= ""
Local cAliasTFJ		:= GetNextAlias()
Local nStepCmmIns	:= 900 //Quantidade do lote de regsitros a serem gravados na tabela temporária a cada INSERT do objeto GsTmpTable
Local nY			:= 0
Local nTot			:= 0
Local nTotPla		:= 0
Local nTotContr		:= 0
Local aAgendRet		:= {}

cQuery := ""
cQuery += " SELECT TFJ.TFJ_CODIGO, TFJ2.TFJ_CONTRT, TFJ2.TFJ_CONREV, TFJ.TFJ_TIPREV, TFJ.TFJ_DTPLRV, "
cQuery += " TFL.TFL_TOTRH AS TOTRHPL, TFL.TFL_TOTMI AS TOTMIPL, TFL.TFL_TOTMC AS TOTMCPL, TFL.TFL_PLAN, "
cQuery += " TFL2.TFL_TOTRH AS TOTRHCT, TFL2.TFL_TOTMI AS TOTMICT, TFL2.TFL_TOTMC AS TOTMCCT "
cQuery += " FROM " + RetSQLName("TFJ") + " TFJ "
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL2 "
cQuery += " ON TFL2.TFL_CODPAI = TFJ.TFJ_CODREL "
cQuery += " AND TFL2.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFJ") + " TFJ2 "
cQuery += " ON TFJ2.TFJ_CODIGO = TFJ.TFJ_CODREL "
cQuery += " AND TFJ2.TFJ_FILIAL = TFJ.TFJ_FILIAL"
cQuery += " AND TFJ2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TFJ.TFJ_STATUS = '8' "
cQuery += " AND TFJ.TFJ_DTPLRV <= '" + DtoS(dDataBase) + "' "
cQuery += " AND TFJ.TFJ_CODREL <> '" + Space(TamSx3("TFJ_CODREL")[1]) + "' "
cQuery += " AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY TFJ2.TFJ_CONTRT, TFJ2.TFJ_CONREV "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFJ,.T.,.T.)

If (cAliasTFJ)->(!Eof())
	
	//Cria estrutura e tabela tmp com os campos necessarios
	//Aadd(aStruct, {"OK"         , "C", 1 , 0})
	Aadd(aStruct, {"TFJ_CONTRT"	, "C", TamSX3("TFJ_CONTRT")[1]	, TamSX3("TFJ_CONTRT")[2]})
	Aadd(aStruct, {"TFJ_CONREV"	, "C", TamSX3("TFJ_CONREV")[1]	, TamSX3("TFJ_CONREV")[2]})
	Aadd(aStruct, {"TFJ_CODIGO"	, "C", TamSX3("TFJ_CODIGO")[1]	, TamSX3("TFJ_CODIGO")[2]})
	Aadd(aStruct, {"TFJ_TIPREV"	, "C", TamSX3("TFJ_TIPREV")[1]	, TamSX3("TFJ_TIPREV")[2]})
	Aadd(aStruct, {"TFJ_DTPLRV"	, "D", TamSX3("TFJ_DTPLRV")[1]	, TamSX3("TFJ_DTPLRV")[2]})
	Aadd(aStruct, {"TFJ_PORPLA"	, "C", 10	, 3})


	//Cria indices para a tabela temporária 
	Aadd(aIdx, {"I1",{ 'TFJ_CONTRT' }})
	Aadd(aIdx, {"I2",{ 'TFJ_CONREV' }})
	Aadd(aIdx, {"I3",{ 'TFJ_CODIGO' }})
	Aadd(aIdx, {"I4",{ 'TFJ_TIPREV' }})
	Aadd(aIdx, {"I5",{ 'TFJ_DTPLRV' }})
	
	//Aadd(aIdx, {"I2",{ 'ABB_CODTEC' }})

	//Cria arABBy da busca de acordo com os indices da tabela temporária
	aAdd(aSeek, {TxDadosCpo('TFJ_CONTRT')[1]	,{{'','C',TamSX3('TFJ_CONTRT')[1],TamSX3('TFJ_CONTRT')[2],TxDadosCpo('TFJ_CONTRT')[1],PesqPict('TFJ','TFJ_CONTRT'),NIL}},1,.T.})
	aAdd(aSeek, {TxDadosCpo('TFJ_CONREV')[1]	,{{'','C',TamSX3('TFJ_CONREV')[1],TamSX3('TFJ_CONREV')[2],TxDadosCpo('TFJ_CONREV')[1],PesqPict('TFJ','TFJ_CONREV'),NIL}},2,.T.})
	aAdd(aSeek, {TxDadosCpo('TFJ_CODIGO')[1]	,{{'','C',TamSX3('TFJ_CODIGO')[1],TamSX3('TFJ_CODIGO')[2],TxDadosCpo('TFJ_CODIGO')[1],PesqPict('TFJ','TFJ_CODIGO'),NIL}},3,.T.})
	aAdd(aSeek, {TxDadosCpo('TFJ_TIPREV')[1]	,{{'','C',TamSX3('TFJ_TIPREV')[1],TamSX3('TFJ_TIPREV')[2],TxDadosCpo('TFJ_TIPREV')[1],PesqPict('TFJ','TFJ_TIPREV'),NIL}},4,.T.})
	aAdd(aSeek, {TxDadosCpo('TFJ_DTPLRV')[1]	,{{'','D',TamSX3('TFJ_DTPLRV')[1],TamSX3('TFJ_DTPLRV')[2],TxDadosCpo('TFJ_DTPLRV')[1],PesqPict('TFJ','TFJ_DTPLRV'),NIL}},5,.T.})
	//aAdd(aSeek, {TxDadosCpo('ABB_CODTEC')[1]	,{{'','C',TamSX3('ABB_CODTEC')[1],TamSX3('ABB_CODTEC')[2],TxDadosCpo('ABB_CODTEC')[1],PesqPict('ABB','ABB_CODTEC'),NIL}},2, .T.})
	
	//Instancia o método NEW para criação da tabela temporária
	oGSTmpTb := GSTmpTable():New('TRBTFJ',aStruct, aIdx, {}, nStepCmmIns )
	cRetTab  := 'TRBTFJ'

	//Validação para a criação da tabela temporária
	If !oGSTmpTb:CreateTMPTable()
		oGSTmpTb:ShowErro()
	Else
		//Preenche Tabela temporária com as informações do array
		While (cAliasTFJ)->(!Eof())
			
			If cContr <> (cAliasTFJ)->(TFJ_CONTRT)
				cContr := (cAliasTFJ)->(TFJ_CONTRT)
				If !Empty(aInsertTmp)
					nTot := ((nTotPla - nTotContr ) / nTotContr) * 100
					If nTot > 0
						Aadd(aInsertTmp, {'TFJ_PORPLA'	,"+ " + cValToChar(Round(nTot,3)) + " %"})
					ElseIf nTot < 0
						Aadd(aInsertTmp, {'TFJ_PORPLA'	,cValToChar(Round(nTot, 3))+ " %"})
					Else
						Aadd(aInsertTmp, {'TFJ_PORPLA'	,cValToChar(nTot)})
					EndIf
					If oGSTmpTb:Insert(aInsertTmp)
						lOk := oGSTmpTb:Commit()
						aInsertTmp :={}
						nTotPla := 0
						nTotContr := 0
					Else
						lOk := .F.
						Exit
					EndIf
				EndIf	
				Aadd(aInsertTmp, {'TFJ_CONTRT'	,(cAliasTFJ)->(TFJ_CONTRT)})
				Aadd(aInsertTmp, {'TFJ_CONREV'	,(cAliasTFJ)->(TFJ_CONREV)})
				Aadd(aInsertTmp, {'TFJ_CODIGO'	,(cAliasTFJ)->(TFJ_CODIGO)}) 
				Aadd(aInsertTmp, {'TFJ_TIPREV'	,(cAliasTFJ)->(TFJ_TIPREV)})
				Aadd(aInsertTmp, {'TFJ_DTPLRV'	,SToD((cAliasTFJ)->(TFJ_DTPLRV))})

				If Empty((cAliasTFJ)->(TFL_PLAN))
					nTotPla += (cAliasTFJ)->(TOTRHPL) + (cAliasTFJ)->(TOTMIPL) + (cAliasTFJ)->(TOTMCPL)
				Else
					nTotContr += (cAliasTFJ)->(TOTRHCT) + (cAliasTFJ)->(TOTMICT) + (cAliasTFJ)->(TOTMCCT)
					nTotPla += (cAliasTFJ)->(TOTRHPL) + (cAliasTFJ)->(TOTMIPL) + (cAliasTFJ)->(TOTMCPL)
				EndIf
			Else
				If Empty((cAliasTFJ)->(TFL_PLAN))
					nTotPla += (cAliasTFJ)->(TOTRHPL) + (cAliasTFJ)->(TOTMIPL) + (cAliasTFJ)->(TOTMCPL)
				Else
					nTotContr += (cAliasTFJ)->(TOTRHCT) + (cAliasTFJ)->(TOTMICT) + (cAliasTFJ)->(TOTMCCT)
					nTotPla += (cAliasTFJ)->(TOTRHPL) + (cAliasTFJ)->(TOTMIPL) + (cAliasTFJ)->(TOTMCPL)
				EndIf
			EndIf
			(cAliasTFJ)->(DbSkip())
		EndDo
		//Usado para processar o ultimo registro inserido
		If !Empty(aInsertTmp)
			nTot := ((nTotPla - nTotContr ) / nTotContr) * 100
			If nTot > 0
				Aadd(aInsertTmp, {'TFJ_PORPLA'	,"+ " + cValToChar(Round(nTot,3)) + " %"})
			ElseIf nTot < 0
				Aadd(aInsertTmp, {'TFJ_PORPLA'	,cValToChar(Round(nTot, 3))+ " %"})
			Else
				Aadd(aInsertTmp, {'TFJ_PORPLA'	,cValToChar(nTot)})
			EndIf
			If oGSTmpTb:Insert(aInsertTmp)
				lOk := oGSTmpTb:Commit()
				aInsertTmp :={}
				cContr := (cAliasTFJ)->(TFJ_CONTRT)
				nTotPla := 0
				nTotContr := 0
			Else
				lOk := .F.
			EndIf
		EndIf
		//MarkBrowse
		For nY := 1 To Len(aStruct)
			If !(aStruct[nY][1] == "OK")
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nY][1]+"}") )			
				If aStruct[nY][1] == "TFJ_PORPLA"
					aColumns[Len(aColumns)]:SetTitle("% Reajuste")
				Else	
					aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nY][1]))
				EndIf
				aColumns[Len(aColumns)]:SetSize(aStruct[nY][3])
				aColumns[Len(aColumns)]:SetDecimal(aStruct[nY][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict(cRetTab,aStruct[nY][1]))
			EndIf
		Next nY
	    If !Isblind()
			DEFINE MSDIALOG oDlg TITLE STR0321 From 100,0 To 500,1000 PIXEL //"Aplica Revisão Planejada"
			oMrkBrowse:SetOwner(oDlg)
			oMrkBrowse:DisableFilter()
			oMrkBrowse:SetDescription(STR0323) //"Selecione o Contrato desejado"
			oMrkBrowse:SetTemporary(.T.)     	
			oMrkBrowse:AddButton(STR0324,{||AplicaRevi((cRetTab)->TFJ_CODIGO, (cRetTab)->TFJ_CONTRT, (cRetTab)->TFJ_CONREV),oDlg:End()},,3,)	//"Aplicar"
			oMrkBrowse:AddButton(STR0325,{||oDlg:End()},,1,)	//"Cancelar"
			oMrkBrowse:SetAlias(cRetTab) //Seta o arquivo temporario para exibir a seleção dos dados
			oMrkBrowse:SetSeek(.T., aSeek)       
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:DisableReport()
			oMrkBrowse:SetMenuDef("")
		
			oMrkBrowse:Activate()
			ACTIVATE MSDIALOG oDlg CENTERED	
		Endif	
			
	     
		oGSTmpTb:Close()
		TecDestroy(oGSTmpTb)
		
	EndIf
Else
	MsgInfo(STR0322) // "Não foi encontrado um contrato em revisão planejada inferior a data base."
EndIf 

(cAliasTFJ)->(dbCloseArea())

Return aAgendRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AplicaRevi
@description Tela para aplicar a revisão planejada
@author	augusto.albuquerque
@since 02/07/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function AplicaRevi(cCodTFJ,cContr,cRevisa)
Local lRet		:= .T.

Begin Transaction
	MsgRun ( STR0029, STR0004, {|| lRet := At870PRev(cCodTFJ,cContr,cRevisa) } )
	If !lRet
		DisarmTransaction()
	EndIf
End Transaction

Return .T.

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870CtRev
@description Verifica se o contrato esta em processo de revisão planejada
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function AT870CtRev( cCodTFJ )
Local cQuery	:= ""
Local cAliasTFJ
Local lRet		:= .F.

Default cTfjPla := ""
If TecVerRePl()
	cAliasTFJ	:= GetNextAlias()
	cQuery := ""
	cQuery += " SELECT 1 FROM " + RetSQLName("TFJ") + " TFJ "
	cQuery += " WHERE TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' " 
	cQuery += " AND TFJ.TFJ_CODIGO = '" + cCodTFJ + "' "
	cQuery += " AND TFJ.TFJ_CODREL <> ' ' "
	cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTFJ, .F., .T.)

	lRet := !(cAliasTFJ)->(Eof())

	(cAliasTFJ)->(dbCloseArea())
EndIf
Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdMantPl
@description Faz a o update e adiciona os itens conforme a revisão na manutenção planejada
@author	augusto.albuquerque
@since	07/07/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function UpdMantPl( cCodAnt, cNewCod, cCodRevPla )
Local cAliasCTR	:= GetNextAlias()
Local cQuery	:= ""
Local cCodAux	:= ""
Local cItem		:= ""
Local aCampos	:= {}
Local aTFLs		:= {}
Local nX

DbSelectArea("TFJ")
TFJ->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFL")
TFL->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFF")
TFF->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFG")
TFG->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFH")
TFH->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFU")
TFU->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

If TFJ->(MSSeek(xFilial("TFJ")+cCodRevPla))
	
	cQuery := ""
	cQuery += " SELECT TFJ.* "
	cQuery += " FROM " + RetSQLName("TFJ") + " TFJ "
	cQuery += " WHERE "
	cQuery += " TFJ.TFJ_CODIGO = '" + cNewCod + "' "
	cQuery += " AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

	If !(cAliasCTR)->(Eof())
		aCampos := FWSX3Util():GetAllFields( 'TFJ' , .F. )
		For nX := 1 To Len(aCampos)
			If !(aCampos[nX] $ "TFJ_CODIGO|TFJ_CODREL|TFJ_TABXML|TFJ_OBSPRC|TFJ_STATUS|TFJ_DTPLRV") 
				TFJ->(RecLock("TFJ", .F.))
					If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
						TFJ->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
					ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
							REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
					ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
						TFJ->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
					EndIf
				TFJ->(MsUnlock())
			ElseIf aCampos[nX] == "TFJ_CODREL"
				TFJ->(RecLock("TFJ", .F.))
					TFJ->TFJ_CODREL := cNewCod
				TFJ->(MsUnlock())
			EndIf
		Next nX
	EndIf
	
	(cAliasCTR)->(dbCloseArea())

	cQuery := ""
	cQuery += " SELECT CASE WHEN TFL3.TFL_CODIGO IS NOT NULL THEN TFL3.TFL_CODIGO ELSE '' END CODIGO, "
	cQuery += " TFL.* "
	cQuery += " FROM " + RetSQLName("TFL") + " TFL "
	cQuery += " LEFT JOIN " + RetSQLName("TFL") + " TFL2 "
	cQuery += " ON TFL.TFL_CODIGO = TFL2.TFL_CODSUB "
	cQuery += " AND TFL2.TFL_FILIAL = TFL.TFL_FILIAL "
	cQuery += " AND TFL2.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSQLName("TFL") + " TFL3 "
	cQuery += " ON TFL2.TFL_CODIGO = TFL3.TFL_CODREL "
	cQuery += " AND TFL3.TFL_FILIAL = TFL.TFL_FILIAL "
	cQuery += " AND TFL3.D_E_L_E_T_ = ' '"
	cQuery += " WHERE "
	cQuery += " TFL.TFL_CODPAI = '" + cNewCod + "' "
	cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQuery += " AND TFL.TFL_MODPLA <> '1' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' "

	cAliasCTR := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

	If !(cAliasCTR)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
		aCampos := FWSX3Util():GetAllFields( 'TFL' , .F. )
		While (cAliasCTR)->(!EOF())
			If TFL->(MSSeek(xFilial("TFL")+(cAliasCTR)->(CODIGO)))
				AADD(aTFLs, TFL->(Recno()))
				For nX := 1 To Len(aCampos)
					If !(aCampos[nX] $ "TFL_CODIGO|TFL_CODPAI|TFL_CONTRT|TFL_CONREV|TFL_CODREL") 
						TFL->(RecLock("TFL", .F.))
							If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
								TFL->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
								REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
								TFL->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
							EndIf
							TFL->(MsUnlock())
					ElseIf aCampos[nX] == "TFL_CODREL"
						TFL->(RecLock("TFL", .F.))
							TFL->TFL_CODREL := (cAliasCTR)->(TFL_CODIGO)
						TFL->(MsUnlock())
					EndIf
				Next nX
			Else
				cCodAux := CriaVar("TFL_CODIGO",.T.)
				TFL->(RecLock("TFL", .T.))
					For nX := 1 To Len(aCampos)
						If !(aCampos[nX] $ "TFL_CODIGO|TFL_CODPAI|TFL_CONTRT|TFL_CONREV|TFL_CODREL") 
							If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
								TFL->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
								TFL->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
							EndIf
						ElseIf aCampos[nX] == "TFL_CODPAI"
							TFL->TFL_CODPAI := cCodRevPla
						ElseIf aCampos[nX] == "TFL_CODIGO"
							TFL->TFL_CODIGO := cCodAux
						ElseIf aCampos[nX] == "TFL_CODREL"
							TFL->TFL_CODREL := (cAliasCTR)->(TFL_CODIGO)
						EndIf
					Next nX
				TFL->(MsUnlock())
			EndIf
			(cAliasCTR)->(DbSkip())
		EndDo
	EndIf

	(cAliasCTR)->(dbCloseArea())

	cQuery := ""
	cQuery += " SELECT TFL.TFL_CODIGO, CASE WHEN TFF3.TFF_COD IS NOT NULL THEN TFF3.TFF_COD ELSE '' END CODIGO, "
	cQuery += " TFF.* "
	cQuery += " FROM " + RetSQLName("TFF") + " TFF "
	cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF2 "
	cQuery += " ON TFF.TFF_COD = TFF2.TFF_CODSUB "
	cQuery += " AND TFF2.TFF_FILIAL = TFF.TFF_FILIAL "
	cQuery += " AND TFF2.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF3 "
	cQuery += " ON TFF2.TFF_COD = TFF3.TFF_CODREL "
	cQuery += " AND TFF3.TFF_FILIAL = TFF.TFF_FILIAL "
	cQuery += " AND TFF3.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
	cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFL.TFL_CODPAI = '" + cNewCod + "' "
	cQuery += " WHERE "
	cQuery += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.TFF_MODPLA <> '1' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "

	cAliasCTR := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

	If !(cAliasCTR)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
		aCampos := FWSX3Util():GetAllFields( 'TFF' , .F. )
		While (cAliasCTR)->(!EOF())
			cCodLocal := CodLocCtrP( (cAliasCTR)->(TFL_CODIGO) )
			If TFF->(MSSeek(xFilial("TFF")+(cAliasCTR)->(CODIGO)))
				For nX := 1 To Len(aCampos)
					If !(aCampos[nX] $ "TFF_COD|TFF_CODPAI|TFF_CONTRT|TFF_CONREV|TFF_CODREL")
						If TFF->TFF_MODPLA != '1'
							TFF->(RecLock("TFF", .F.))
								If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
									TFF->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
									TFF->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
								EndIf
							TFF->(MsUnlock())
						EndIf
					ElseIf aCampos[nX] == "TFF_CODREL"
						TFF->(RecLock("TFF", .F.))
							TFF->TFF_CODREL := (cAliasCTR)->(TFF_COD)
						TFF->(MsUnlock())
					EndIf
				Next nX
			Else
				cCodAux := CriaVar("TFF_COD",.T.)
				If Empty(cItem)	
					cItem := Soma1(ItemCtrPla( cCodLocal ))
				Else
					cItem := Soma1(cItem)
				EndIf
				TFF->(RecLock("TFF", .T.))
					For nX := 1 To Len(aCampos)
						If !(aCampos[nX] $ "TFF_COD|TFF_CODPAI|TFF_CONTRT|TFF_CONREV|TFF_ITEM|TFF_CODREL") 
							If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
								TFF->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
								TFF->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
							EndIf
						ElseIf aCampos[nX] == "TFF_CODPAI"
							TFF->TFF_CODPAI := cCodLocal
						ElseIf aCampos[nX] == "TFF_COD"
							TFF->TFF_COD := cCodAux
						ElseIf aCampos[nX] == "TFF_ITEM"
						 	TFF->TFF_ITEM := cItem
						ElseIf aCampos[nX] == "TFF_CODREL"
						 	TFF->TFF_CODREL := (cAliasCTR)->(TFF_COD)
						EndIf
					Next nX
				TFF->(MsUnlock())
			EndIf
			(cAliasCTR)->(DbSkip())
		EndDo
	EndIf

	(cAliasCTR)->(dbCloseArea())

	cItem := ""

	cQuery := ""
	cQuery += " SELECT TFF.TFF_COD, CASE WHEN TFG3.TFG_COD IS NOT NULL THEN TFG3.TFG_COD ELSE '' END CODIGO, "
	cQuery += " TFG.* "
	cQuery += " FROM " + RetSQLName("TFG") + " TFG "
	cQuery += " LEFT JOIN " + RetSQLName("TFG") + " TFG2 "
	cQuery += " ON TFG.TFG_COD = TFG2.TFG_CODSUB "
	cQuery += " AND TFG2.TFG_FILIAL = TFG.TFG_FILIAL "
	cQuery += " AND TFG2.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("TFG") + " TFG3 "
	cQuery += " ON TFG2.TFG_COD = TFG3.TFG_CODREL "
	cQuery += " AND TFG3.TFG_FILIAL = TFG.TFG_FILIAL "
	cQuery += " AND TFG3.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFG.TFG_CODPAI "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
	cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFL.TFL_CODPAI = '" + cNewCod + "' "
	cQuery += " WHERE "
	cQuery += " TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
	cQuery += " AND TFG.TFG_MODPLA <> '1' "
	cQuery += " AND TFG.D_E_L_E_T_ = ' ' "

	cAliasCTR := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

	If !(cAliasCTR)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
		aCampos := FWSX3Util():GetAllFields( 'TFG' , .F. )
		While (cAliasCTR)->(!EOF())
			cCodRH := CodItRHPla( (cAliasCTR)->(TFF_COD) )
			If TFG->(MSSeek(xFilial("TFG")+(cAliasCTR)->(CODIGO)))
				For nX := 1 To Len(aCampos)
					If !(aCampos[nX] $ "TFG_COD|TFG_CODPAI|TFG_CONTRT|TFG_CONREV|TFG_CODREL") 
						If TFG->TFG_MODPLA != '1'
							TFG->(RecLock("TFG", .F.))
								If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
									TFG->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
									TFG->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
								EndIf
							TFG->(MsUnlock())
						EndIf
					ElseIf aCampos[nX] == "TFG_CODREL"
						TFG->(RecLock("TFG", .F.))
							TFG->TFG_CODREL := (cAliasCTR)->(TFG_COD)
						TFG->(MsUnlock())
					EndIf
				Next nX
			Else
				cCodAux := CriaVar("TFG_COD",.T.)
				If Empty(cItem)	
					cItem := Soma1(ItemMatPla( cCodRH, "TFG" ))
				Else
					cItem := Soma1(cItem)
				EndIf
				TFG->(RecLock("TFG", .T.))
					For nX := 1 To Len(aCampos)
						If !(aCampos[nX] $ "TFG_COD|TFG_CODPAI|TFG_CONTRT|TFG_CONREV|TFG_ITEM|TFG_CODREL") 
							If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
								TFG->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
								TFG->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
							EndIf
						ElseIf aCampos[nX] == "TFG_CODPAI"
							TFG->TFG_CODPAI := cCodRH
						ElseIf aCampos[nX] == "TFG_COD"
							TFG->TFG_COD := cCodAux
						ElseIf aCampos[nX] == "TFG_ITEM"
						 	TFG->TFG_ITEM := cItem
						ElseIf aCampos[nX] == "TFG_CODREL"
						 	TFG->TFG_CODREL := (cAliasCTR)->(TFG_COD)
						EndIf
					Next nX
				TFG->(MsUnlock())
			EndIf
			(cAliasCTR)->(DbSkip())
		EndDo
	EndIf

	(cAliasCTR)->(dbCloseArea())

	cItem := ""

	cQuery := ""
	cQuery += " SELECT TFF.TFF_COD, CASE WHEN TFH3.TFH_COD IS NOT NULL THEN TFH3.TFH_COD ELSE '' END CODIGO, "
	cQuery += " TFH.* "
	cQuery += " FROM " + RetSQLName("TFH") + " TFH "
	cQuery += " LEFT JOIN " + RetSQLName("TFH") + " TFH2 "
	cQuery += " ON TFH.TFH_COD = TFH2.TFH_CODSUB "
	cQuery += " AND TFH2.TFH_FILIAL = TFH.TFH_FILIAL "
	cQuery += " AND TFH2.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("TFH") + " TFH3 "
	cQuery += " ON TFH2.TFH_COD = TFH3.TFH_CODREL "
	cQuery += " AND TFH3.TFH_FILIAL = TFH.TFH_FILIAL "
	cQuery += " AND TFH3.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFH.TFH_CODPAI "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
	cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFL.TFL_CODPAI = '" + cNewCod + "' "
	cQuery += " WHERE "
	cQuery += " TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
	cQuery += " AND TFH.TFH_MODPLA <> '1' "
	cQuery += " AND TFH.D_E_L_E_T_ = ' ' "

	cAliasCTR := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

	If !(cAliasCTR)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
		aCampos := FWSX3Util():GetAllFields( 'TFH' , .F. )
		While (cAliasCTR)->(!EOF())
			cCodRH := CodItRHPla( (cAliasCTR)->(TFF_COD) )
			If TFH->(MSSeek(xFilial("TFH")+(cAliasCTR)->(CODIGO)))
				For nX := 1 To Len(aCampos)
					If !(aCampos[nX] $ "TFH_COD|TFH_CODPAI|TFH_CONTRT|TFH_CONREV|TFH_CODREL")
						If TFH->TFH_MODPLA != '1'
							TFH->(RecLock("TFH", .F.))
								If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
									TFH->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
									TFH->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
								EndIf
							TFH->(MsUnlock())
						EndIf
					ElseIf aCampos[nX] == "TFH_CODREL"
						TFH->(RecLock("TFH", .F.))
							TFH->TFH_CODREL := (cAliasCTR)->(TFH_COD)
						TFH->(MsUnlock())
					EndIf
				Next nX
			Else
				cCodAux := CriaVar("TFH_COD",.T.)
				If Empty(cItem)	
					cItem := Soma1(ItemMatPla( cCodRH, "TFH" ))
				Else
					cItem := Soma1(cItem)
				EndIf
				TFH->(RecLock("TFH", .T.))
					For nX := 1 To Len(aCampos)
						If !(aCampos[nX] $ "TFH_COD|TFH_CODPAI|TFH_CONTRT|TFH_CONREV|TFH_ITEM|TFH_CODREL") 
							If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
								TFH->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
								TFH->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
							EndIf
						ElseIf aCampos[nX] == "TFH_CODPAI"
							TFH->TFH_CODPAI := cCodRH
						ElseIf aCampos[nX] == "TFH_COD"
							TFH->TFH_COD := cCodAux
						ElseIf aCampos[nX] == "TFH_ITEM"
						 	TFH->TFH_ITEM := cItem
						ElseIf aCampos[nX] == "TFH_CODREL"
						 	TFH->TFH_CODREL := (cAliasCTR)->(TFH_COD)
						EndIf
					Next nX
				TFH->(MsUnlock())
			EndIf
			(cAliasCTR)->(DbSkip())
		EndDo
	EndIf

	(cAliasCTR)->(dbCloseArea())

	cItem := ""

	cQuery := ""
	cQuery += " SELECT TFF.TFF_COD, TFF.TFF_LOCAL, CASE WHEN TFU2.TFU_CODIGO IS NOT NULL THEN TFU2.TFU_CODIGO ELSE '' END CODIGO, "
	cQuery += " TFU.* "
	cQuery += " FROM " + RetSQLName("TFU") + " TFU "
	cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFU.TFU_CODTFF "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF2 "
	cQuery += " ON TFF.TFF_COD = TFF2.TFF_CODREL "
	cQuery += " AND TFF2.TFF_FILIAL = TFF.TFF_FILIAL "
	cQuery += " AND TFF2.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("TFU") + " TFU2 "
	cQuery += " ON TFU2.TFU_CODTFF = TFF2.TFF_COD "
	cQuery += " AND TFU2.TFU_FILIAL = TFU.TFU_FILIAL "
	cQuery += " AND TFU2.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
	cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFL.TFL_CODPAI = '" + cNewCod + "' "
	cQuery += " WHERE "
	cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
	cQuery += " AND TFU.TFU_MODPLA <> '1' "
	cQuery += " AND TFU.D_E_L_E_T_ = ' ' "

	cAliasCTR := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

	If !(cAliasCTR)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
		aCampos := FWSX3Util():GetAllFields( 'TFU' , .F. )
		While (cAliasCTR)->(!EOF())
			cCodRH := CodItRHPla( (cAliasCTR)->(TFF_COD) )
			If TFU->(MSSeek(xFilial("TFU")+(cAliasCTR)->(CODIGO)))
				For nX := 1 To Len(aCampos)
					If !(aCampos[nX] $ "TFU_CODIGO|TFU_CODREL") 
						If TFU->TFU_MODPLA != '1'
							TFU->(RecLock("TFU", .F.))
								If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
									TFU->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
								ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
									TFU->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
								EndIf
							TFU->(MsUnlock())
						EndIf
					ElseIf aCampos[nX] == "TFU_CODREL"
						TFU->(RecLock("TFU", .F.))
							TFU->TFU_CODREL := (cAliasCTR)->(TFU_CODIGO)
						TFU->(MsUnlock())
					EndIf
				Next nX
			Else
				cCodAux := CriaVar("TFU_CODIGO",.T.)
				TFU->(RecLock("TFU", .T.))
					For nX := 1 To Len(aCampos)
						If !(aCampos[nX] $ "TFU_CODIGO|TFF_LOCAL|TFU_CODREL") 
							If FWSX3Util():GetFieldType( aCampos[nX] ) == "D"
								TFU->&(aCampos[nX]) := SToD((cAliasCTR)->&(aCampos[nX]))
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) == "M" .AND. Type("(cAliasCTR)->&(aCampos[nX])") <> "UI"
									REPLACE &(aCampos[nX])		With (cAliasCTR)->&(aCampos[nX])
							ElseIf FWSX3Util():GetFieldType( aCampos[nX] ) $ "C|N"
								TFU->&(aCampos[nX]) := (cAliasCTR)->&(aCampos[nX])
							EndIf
						ElseIf aCampos[nX] == "TFF_LOCAL"
							TFU->TFF_LOCAL := (cAliasCTR)->(TFF_LOCAL)
						ElseIf aCampos[nX] == "TFU_CODTFF"
							TFU->TFU_CODTFF := cCodRH
						ElseIf aCampos[nX] == "TFU_CODIGO"
							TFU->TFU_CODIGO := cCodAux
						ElseIf aCampos[nX] == "TFU_CODREL"
						 	TFU->TFU_CODREL := (cAliasCTR)->(TFU_CODIGO)
						EndIf
					Next nX
				TFU->(MsUnlock())
			EndIf
			(cAliasCTR)->(DbSkip())
		EndDo
		(cAliasCTR)->(dbCloseArea())
	EndIf
EndIf

ConfirmSX8()

If !EMPTY(aTFLs)
	AtuVlTFLs(aTFLs)
EndIf

Return 

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870CtRev
@description Verifica se o contrato esta em processo de revisão planejada
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function AT870ItPla( cCodigo, cTabela )
Local cQuery	:= ""
Local cAliasTAB	:= GetNextAlias()
Local lRet		:= .T.

Default cTfjPla := ""

cQuery := ""
cQuery += " SELECT 1 FROM " + RetSQLName(cTabela) + " " + cTabela
cQuery += " WHERE " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' " 
cQuery += " AND " + cTabela + "_CODREL = '" + cCodigo + "' "
cQuery += " AND " + cTabela + ".D_E_L_E_T_ = ' ' "
cQuery += " AND " + cTabela + "_MODPLA = '1' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTAB, .F., .T.)

lRet := !(cAliasTAB)->(Eof())

(cAliasTAB)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ItemCtrPla
@description Retorna o valor maximo do item de RH
@author	augusto.albuquerque
@since	07/07/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function ItemCtrPla( cCodTFL )
Local cAliasTFF	:= GetNextAlias()
Local cQuery	:= ""
Local cRet 		:= "01" 

cQuery := ""
cQuery += " SELECT MAX(TFF.TFF_ITEM) ITEM "
cQuery += " FROM " + RetSQLName("TFF") + " TFF " 
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL"
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI"
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " AND TFL.TFL_CODIGO = '" + cCodTFL + "' "
cQuery += " WHERE "
cQuery += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFF,.T.,.T.)

If !(cAliasTFF)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
	cRet := (cAliasTFF)->(ITEM)
EndIf

(cAliasTFF)->(dbCloseArea())

Return cRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CodLocCtrP
@description Retorna o valor do codigo relacionado da tabela TFL
@author	augusto.albuquerque
@since	07/07/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function CodLocCtrP( cCodLocal )
Local cAliasTFL	:= GetNextAlias()
Local cQuery	:= ""
Local cRet		:= cCodLocal

cQuery := ""
cQuery += " SELECT CASE WHEN TFL4.TFL_CODIGO IS NOT NULL THEN TFL4.TFL_CODIGO ELSE '' END CODIG1, "
cQuery += " CASE WHEN TFL3.TFL_CODIGO IS NOT NULL THEN TFL3.TFL_CODIGO ELSE '' END CODIG2 " 
cQuery += " FROM " + RetSQLName("TFL") + " TFL "
cQuery += " LEFT JOIN " + RetSQLName("TFL") + " TFL2 "
cQuery += " ON TFL2.TFL_CODSUB = TFL.TFL_CODIGO "
cQuery += " AND TFL2.TFL_FILIAL = TFL.TFL_FILIAL "
cQuery += " AND TFL2.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName("TFL") + " TFL3 "
cQuery += " ON TFL3.TFL_CODREL = TFL2.TFL_CODIGO "
cQuery += " AND TFL3.TFL_FILIAL = TFL2.TFL_FILIAL "
cQuery += " AND TFL3.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName("TFL") + " TFL4 "
cQuery += " ON TFL4.TFL_CODREL = TFL.TFL_CODIGO "
cQuery += " AND TFL4.TFL_FILIAL = TFL.TFL_FILIAL "
cQuery += " AND TFL4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFL.TFL_CODIGO = '" + cCodLocal + "' "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFL,.T.,.T.)

If !(cAliasTFL)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
	If !Empty((cAliasTFL)->(CODIG2))
		cRet := (cAliasTFL)->(CODIG2)
	ElseIf !Empty((cAliasTFL)->(CODIG1))
		cRet := (cAliasTFL)->(CODIG1)
	EndIf
EndIf

(cAliasTFL)->(dbCloseArea())

Return cRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CodItRHPla
@description Retorna o valor do codigo relacionado da tabela TFF
@author	augusto.albuquerque
@since	07/07/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function CodItRHPla( cCodRH )
Local cRet		:= ""
Local cQuery	:= ""
Local cAliasTFF	:= GetNextAlias()

cQuery := ""
cQuery += " SELECT CASE WHEN TFF4.TFF_COD IS NOT NULL THEN TFF4.TFF_COD ELSE '' END CODIG1, "
cQuery += " CASE WHEN TFF3.TFF_COD IS NOT NULL THEN TFF3.TFF_COD ELSE '' END CODIG2 " 
cQuery += " FROM " + RetSQLName("TFF") + " TFF "
cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF2 "
cQuery += " ON TFF2.TFF_CODSUB = TFF.TFF_COD "
cQuery += " AND TFF2.TFF_FILIAL = TFF.TFF_FILIAL "
cQuery += " AND TFF2.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF3 "
cQuery += " ON TFF3.TFF_CODREL = TFF2.TFF_COD "
cQuery += " AND TFF3.TFF_FILIAL = TFF2.TFF_FILIAL "
cQuery += " AND TFF3.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF4 "
cQuery += " ON TFF4.TFF_CODREL = TFF.TFF_COD "
cQuery += " AND TFF4.TFF_FILIAL = TFF.TFF_FILIAL "
cQuery += " AND TFF4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFF.TFF_COD = '" + cCodRH + "' "
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFF,.T.,.T.)

If !(cAliasTFF)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
	If !Empty((cAliasTFF)->(CODIG2))
		cRet := (cAliasTFF)->(CODIG2)
	ElseIf !Empty((cAliasTFF)->(CODIG1))
		cRet := (cAliasTFF)->(CODIG1)
	EndIf
EndIf

(cAliasTFF)->(dbCloseArea())

Return cRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ItemMatPla
@description Retorna o valor maximo do xampo ITEM dos materiais de consumo e implantação
@author	augusto.albuquerque
@since	07/07/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function ItemMatPla( cCodRH, cTabela )
Local cAliasMAT	:= GetNextAlias()
Local cQuery	:= ""
Local cRet 		:= "01" 

cQuery := ""
cQuery += " SELECT MAX(" + cTabela + "." + cTabela + "_ITEM) ITEM "
cQuery += " FROM " + RetSQLName(cTabela) + " " + cTabela 
cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
cQuery += " ON TFF.TFF_COD = " + cTabela + "_CODPAI"
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " AND TFF.TFF_COD = '" + cCodRH + "' "
cQuery += " WHERE "
cQuery += cTabela + "." + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' "
cQuery += " AND " + cTabela + ".D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasMAT,.T.,.T.)

If !(cAliasMAT)->(Eof())//(cAliasTFJ)->(TFJ_CONTRT)
	cRet := (cAliasMAT)->(ITEM)
EndIf

(cAliasMAT)->(dbCloseArea())

Return cRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelMantPl
@description Faz a deleção dos itens conforme a revisão
@author	augusto.albuquerque
@since	07/07/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function DelMantPl( cCodAnt, cNewCod, cCodRevPla )
Local cAliasCTR	:= GetNextAlias()
Local cQuery	:= ""

DbSelectArea("TFL")
TFL->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFF")
TFF->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFG")
TFG->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFH")
TFH->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

DbSelectArea("TFU")
TFU->(DbSetOrder(1))//TFJ_FILIAL + TFJ_CODIGO

cQuery := ""
cQuery += " SELECT TFL2.TFL_CODIGO CODREL "
cQuery += " FROM " + RetSQLName("TFL") + " TFL "
cQuery += " LEFT JOIN " + RetSQLName("TFL") + " TFL2 "
cQuery += " ON TFL2.TFL_CODREL = TFL.TFL_CODIGO "
cQuery += " AND TFL2.TFL_FILIAL = TFL.TFL_FILIAL "
cQuery += " AND TFL2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.TFL_CODPAI = '" + cCodAnt + "' "
cQuery += " AND TFL.TFL_CODSUB = '" + Space(TamSX3("TFL_CODSUB")[1]) + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

If !(cAliasCTR)->(Eof())
	While (cAliasCTR)->(!EOF())
		If TFL->(MSSeek(xFilial("TFL")+(cAliasCTR)->(CODREL)))
			RecLock( "TFL", .F. )
				TFL->( dbDelete() )
			TFL->( MsUnlock() )
		EndIf
		(cAliasCTR)->(DbSkip())
	EndDo
EndIf
(cAliasCTR)->(dbCloseArea())

cQuery := ""
cQuery += " SELECT TFF2.TFF_COD CODREL "
cQuery += " FROM " + RetSQLName("TFF") + " TFF "
cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF2 "
cQuery += " ON TFF2.TFF_CODREL = TFF.TFF_COD "
cQuery += " AND TFF2.TFF_FILIAL = TFF.TFF_FILIAL "
cQuery += " AND TFF2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.TFL_CODPAI = '" + cCodAnt + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.TFF_CODSUB = '" + Space(TamSX3("TFF_CODSUB")[1]) + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "

cAliasCTR := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

If !(cAliasCTR)->(Eof())
	While (cAliasCTR)->(!EOF())
		If TFF->(MSSeek(xFilial("TFF")+(cAliasCTR)->(CODREL)))
			RecLock( "TFF", .F. )
				TFF->( dbDelete() )
			TFF->( MsUnlock() )
		EndIf
		(cAliasCTR)->(DbSkip())
	EndDo
EndIf

(cAliasCTR)->(dbCloseArea())

cQuery := ""
cQuery += " SELECT TFG2.TFG_COD CODREL "
cQuery += " FROM " + RetSQLName("TFG") + " TFG "
cQuery += " LEFT JOIN " + RetSQLName("TFG") + " TFG2 "
cQuery += " ON TFG2.TFG_CODREL = TFG.TFG_COD "
cQuery += " AND TFG2.TFG_FILIAL = TFG.TFG_FILIAL "
cQuery += " AND TFG2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
cQuery += " ON TFF.TFF_COD = TFG.TFG_CODPAI "
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.TFL_CODPAI = '" + cCodAnt + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
cQuery += " AND TFG.TFG_CODSUB = '" + Space(TamSX3("TFG_CODSUB")[1]) + "' "

cQuery += " AND TFG.D_E_L_E_T_ = ' ' "

cAliasCTR := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

If !(cAliasCTR)->(Eof())
	While (cAliasCTR)->(!EOF())
		If TFG->(MSSeek(xFilial("TFG")+(cAliasCTR)->(CODREL)))
			RecLock( "TFG", .F. )
				TFG->( dbDelete() )
			TFG->( MsUnlock() )
		EndIf
		(cAliasCTR)->(DbSkip())
	EndDo
EndIf

(cAliasCTR)->(dbCloseArea())

cQuery := ""
cQuery += " SELECT TFH2.TFH_COD CODREL "
cQuery += " FROM " + RetSQLName("TFH") + " TFH "
cQuery += " LEFT JOIN " + RetSQLName("TFH") + " TFH2 "
cQuery += " ON TFH2.TFH_CODREL = TFH.TFH_COD "
cQuery += " AND TFH2.TFH_FILIAL = TFH.TFH_FILIAL "
cQuery += " AND TFH2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
cQuery += " ON TFF.TFF_COD = TFH.TFH_CODPAI "
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.TFL_CODPAI = '" + cCodAnt + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
cQuery += " AND TFH.TFH_CODSUB = '" + Space(TamSX3("TFH_CODSUB")[1]) + "' "
cQuery += " AND TFH.D_E_L_E_T_ = ' ' "

cAliasCTR := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

If !(cAliasCTR)->(Eof())
	While (cAliasCTR)->(!EOF())
		If TFH->(MSSeek(xFilial("TFH")+(cAliasCTR)->(CODREL)))
			RecLock( "TFH", .F. )
				TFH->( dbDelete() )
			TFH->( MsUnlock() )
		EndIf
		(cAliasCTR)->(DbSkip())
	EndDo
EndIf

(cAliasCTR)->(dbCloseArea())

cQuery := ""
cQuery += " SELECT TFU2.TFU_CODIGO CODREL "
cQuery += " FROM " + RetSQLName("TFU") + " TFU "
cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
cQuery += " ON TFF.TFF_COD = TFU.TFU_CODTFF "
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.TFF_CODSUB = '" + Space(TamSX3("TFF_CODSUB")[1]) + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName("TFF") + " TFF2 "
cQuery += " ON TFF.TFF_COD = TFF2.TFF_CODREL "
cQuery += " AND TFF2.TFF_FILIAL = TFF.TFF_FILIAL "
cQuery += " AND TFF2.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName("TFU") + " TFU2 "
cQuery += " ON TFU2.TFU_CODTFF = TFF2.TFF_COD "
cQuery += " AND TFU2.TFU_FILIAL = TFU.TFU_FILIAL "
cQuery += " AND TFU2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " AND TFL.TFL_CODPAI = '" + cCodAnt + "' "
cQuery += " WHERE "
cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
cQuery += " AND TFU.TFU_MODPLA <> '1' "
cQuery += " AND TFU.D_E_L_E_T_ = ' ' "

cAliasCTR := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTR,.T.,.T.)

If !(cAliasCTR)->(Eof())
	While (cAliasCTR)->(!EOF())
		If TFU->(MSSeek(xFilial("TFU")+(cAliasCTR)->(CODREL)))
			RecLock( "TFU", .F. )
				TFU->( dbDelete() )
			TFU->( MsUnlock() )
		EndIf
		(cAliasCTR)->(DbSkip())
	EndDo
EndIf

(cAliasCTR)->(dbCloseArea())


Return
/*/{Protheus.doc} AtuVlTFLs

@description 	Ajusta os totalizadores da TFL da revisão planejada
@param			aTFLs, array, array com RECNOs das TFLs da Revisão Planejada
@since 			12/07/2021
@author		Mateus Boiani
/*/
Static Function AtuVlTFLs(aTFLs)
Local nX
Local cCodTFL
Local nTotTFF := 0
Local nTotTFH := 0
Local nTotTFG := 0
Local nTotPrxPr := 0
Local aArea := GetArea()
Local aAreaTFF := TFF->(GetArea())
Local aAreaTFL := TFL->(GetArea())
Local aAreaTFH := TFH->(GetArea())
Local aAreaTFG := TFG->(GetArea())

TFL->(DbGoTo(aTFLs[1]))

If POSICIONE("TFJ", 1, xFilial("TFJ") + TFL->TFL_CODPAI, "TFJ_STATUS") == '8'
	For nX := 1 To LEN(aTFLs)
		TFL->(DbGoTo(aTFLs[nX]))
		cCodTFL := TFL->TFL_CODIGO

		TFF->(DbSetOrder(3)) //TFF_FILIAL+TFF_CODPAI+TFF_ITEM
		TFF->(MsSeek(xFilial("TFF") + cCodTFL))
		While !(TFF->(EOF())) .AND. TFF->TFF_FILIAL == xFilial("TFF") .AND. TFF->TFF_CODPAI == cCodTFL
			If TFF->TFF_COBCTR != '2' 
				nTotTFF += At740PrxPa(/*cTipo*/, TFF->TFF_QTDVEN, TFF->TFF_PRCVEN, TFF->TFF_DESCON, TFF->TFF_TXLUCR, TFF->TFF_TXADM)
				nTotPrxPr += TFF->TFF_VLPRPA
			EndIf

			TFH->(DbSetOrder(3)) //TFH_FILIAL+TFH_CODPAI+TFH_ITEM
			TFH->(MsSeek(xFilial("TFH") + TFF->TFF_COD))
			While !(TFH->(EOF())) .AND. TFH->TFH_FILIAL == xFilial("TFH") .AND. TFH->TFH_CODPAI == TFF->TFF_COD
				If TFH->TFH_COBCTR != '2'
					nTotTFH := At740PrxPa(/*cTipo*/, TFH->TFH_QTDVEN, TFH->TFH_PRCVEN, TFH->TFH_DESCON, TFH->TFH_TXLUCR, TFH->TFH_TXADM)
					nTotPrxPr += TFH->TFH_VLPRPA
				EndIf
				TFH->(DbSkip())
			End

			TFG->(DbSetOrder(3)) //TFG_FILIAL+TFG_CODPAI+TFG_ITEM
			TFG->(MsSeek(xFilial("TFG") + TFF->TFF_COD))
			While !(TFG->(EOF())) .AND. TFG->TFG_FILIAL == xFilial("TFG") .AND. TFG->TFG_CODPAI == TFF->TFF_COD
				If TFG->TFG_COBCTR != '2'
					nTotTFG := At740PrxPa(/*cTipo*/, TFG->TFG_QTDVEN, TFG->TFG_PRCVEN, TFG->TFG_DESCON, TFG->TFG_TXLUCR, TFG->TFG_TXADM)
					nTotPrxPr += TFG->TFG_VLPRPA
				EndIf
				TFG->(DbSkip())
			End

			TFF->(DbSkip())
		End
		TFL->(RecLock("TFL", .F.))
			TFL->TFL_TOTRH := nTotTFF
			TFL->TFL_TOTMI := nTotTFG
			TFL->TFL_TOTMC := nTotTFH
			TFL->TFL_VLPRPA := nTotPrxPr
		TFL->(MsUnlock())
	Next nX

	RestArea(aAreaTFF)
	RestArea(aAreaTFL)
	RestArea(aAreaTFH)
	RestArea(aAreaTFG)
	RestArea(aArea)

EndIf

Return
/*/{Protheus.doc} AtuModPla

@description 	Atualiza o campo _MODPLA para '2' em contratos sem Revisão Planejada
@param			cCodTFJ, string, código da TFJ em aprovação
@since 			14/07/2021
@author		Mateus Boiani
/*/
Static Function AtuModPla(cCodTFJ)
Local aArea := GetArea()
Local aAreaTFF := TFF->(GetArea())
Local aAreaTFL := TFL->(GetArea())
Local aAreaTFH := TFH->(GetArea())
Local aAreaTFG := TFG->(GetArea())
Local cAliasQry	:= GetNextAlias()
Local cCodTFF := ""

DbSelectArea("TFL")
DbSetOrder(2) //TFL_FILIAL+TFL_CODPAI
If TFL->(DbSeek(xFilial("TFL")+cCodTFJ))
	While TFL->TFL_FILIAL == xFilial("TFL") .AND. !(TFL->(EOF())) .AND. TFL->TFL_CODPAI == cCodTFJ

		TFF->(DbSetOrder(3)) //TFF_FILIAL+TFF_CODPAI+TFF_ITEM
		TFF->(MsSeek(xFilial("TFF") + TFL->TFL_CODIGO))

		While !(TFF->(EOF())) .AND. TFF->TFF_FILIAL == xFilial("TFF") .AND. TFF->TFF_CODPAI == TFL->TFL_CODIGO

			TFH->(DbSetOrder(3)) //TFH_FILIAL+TFH_CODPAI+TFH_ITEM
			TFH->(MsSeek(xFilial("TFH") + TFF->TFF_COD))
			While !(TFH->(EOF())) .AND. TFH->TFH_FILIAL == xFilial("TFH") .AND. TFH->TFH_CODPAI == TFF->TFF_COD
				TFH->(RecLock("TFH", .F.))
					TFH->TFH_MODPLA := '2'
				TFH->(MsUnlock())
				TFH->(DbSkip())
			End

			TFG->(DbSetOrder(3)) //TFG_FILIAL+TFG_CODPAI+TFG_ITEM
			TFG->(MsSeek(xFilial("TFG") + TFF->TFF_COD))
			While !(TFG->(EOF())) .AND. TFG->TFG_FILIAL == xFilial("TFG") .AND. TFG->TFG_CODPAI == TFF->TFF_COD
				TFG->(RecLock("TFG", .F.))
					TFG->TFG_MODPLA := '2'
				TFG->(MsUnlock())
				TFG->(DbSkip())
			End
			cCodTFF := TFF->TFF_COD

			BeginSQL Alias cAliasQry 
				SELECT TFU.R_E_C_N_O_ REC 
				FROM %Table:TFU% TFU
			WHERE
				TFU.TFU_FILIAL = %xFilial:TFU% AND
				TFU.TFU_CODTFF = %Exp:cCodTFF% AND
				TFU.%notDel%
			EndSql
			While !(cAliasQry)->(EOF())
				DbSelectArea("TFU")
				
				TFU->(DbGoTo((cAliasQry)->REC))
				TFU->(RecLock("TFU", .F.))
					TFU->TFU_MODPLA := '2'
				TFU->(MsUnlock())

				(cAliasQry)->(DbSkip())
			End
			(cAliasQry)->(DbCloseArea())

			TFF->(RecLock("TFF", .F.))
				TFF->TFF_MODPLA := '2'
			TFF->(MsUnlock())
			TFF->(DbSkip())
		End
		TFL->(RecLock("TFL", .F.))
			TFL->TFL_MODPLA := '2'
		TFL->(MsUnlock())
		TFL->(DbSkip())
	End
EndIf

RestArea(aAreaTFF)
RestArea(aAreaTFL)
RestArea(aAreaTFH)
RestArea(aAreaTFG)
RestArea(aArea)

Return .T.

//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidTFFs 

@description Compara as TFFs do Orçamento Ativo (DEF_TFJ_ATIVO "1") com as TFFs do orçamento em aprovação (DEF_TFJ_AGDAPROVA "4"). 
@param cContr, character Numero do contrato
@param cRev, character Revisão do contrato
@param cStatus, character Status do contrato
@author	Natacha Romeiro
@since 29/07/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------
Static Function ValidTFFs(cContr,cRev,cStatus,lAutomato)

Local lRet 		 	:= .T.
Local cQry		 	:= ""
Local lFirst  	 	:= .T.
Local cQuery	 	:= ""
Local cTexMsg	 	:= ""
Local cAliasTFF	 	:= GetNextAlias()
Local cAliasAGD	 	:= GetNextAlias()
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local nMsgPer		:= 0

cQry += " SELECT TFF2.TFF_FILIAL FILIAL2, TFF2.TFF_COD COD2, TFF2.TFF_ESCALA ESCALA2,  "
cQry += " TFF.TFF_QTDVEN QTDVEN, TFF2.TFF_QTDVEN QTDVEN2, TFF.TFF_PERFIM PERFIM, TFF2.TFF_PERFIM PERFIM2, TFF.TFF_PERINI PERINI, TFF2.TFF_PERINI PERINI2 " 
cQry += " FROM " +RetSqlName("TFF") + " TFF "
cQry += " INNER JOIN " +RetSqlName("TFF") + " TFF2 "
cQry += " ON TFF2.TFF_CODSUB = TFF.TFF_COD "
cQry += " AND TFF2.TFF_FILIAL = TFF.TFF_FILIAL "
cQry += " AND TFF2.TFF_CONTRT = TFF.TFF_CONTRT "
cQry += " AND TFF2.TFF_COBCTR = '1' " 
cQry += " AND TFF2.D_E_L_E_T_ = ' ' " 
cQry += " WHERE TFF.TFF_CONTRT = '" +cContr+ "' "
cQry += " AND TFF.TFF_FILIAL = '" +xFilial("TFF")+ "' "
cQry += " AND TFF.TFF_CODSUB = '' "
cQry += " AND TFF.TFF_COBCTR = '1' " 
cQry += " AND (TFF.TFF_QTDVEN != TFF2.TFF_QTDVEN " 
cQry += " OR  TFF.TFF_PERFIM < TFF2.TFF_PERFIM " 
cQry += " OR  TFF.TFF_PERINI > TFF2.TFF_PERINI) "
cQry += " AND TFF.D_E_L_E_T_ = ' ' "
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFF,.T.,.T.)

While !(cAliasTFF)->(EOF()) 
	lFirst  	 := .T.
	cQuery := ""
	If (cAliasTFF)->QTDVEN < (cAliasTFF)->QTDVEN2 		 
		If At740VldQt((cAliasTFF)->COD2,(cAliasTFF)->QTDVEN,(cAliasTFF)->ESCALA2,dDataBase)  
		 	cTexMsg += STR0328+(cAliasTFF)->COD2+CRLF // "POSTO: "
		 	cTexMsg += STR0329+cValToChar((cAliasTFF)->QTDVEN2)+STR0330+cValToChar((cAliasTFF)->QTDVEN)+ ": "+CRLF // "Quantidade reduzida de " ## " para "
		 	cTexMsg += STR0333+CRLF+CRLF		 
		EndIf		
	EndIf	
		 
	If (cAliasTFF)->PERINI > (cAliasTFF)->PERINI2 .OR. (cAliasTFF)->PERFIM < (cAliasTFF)->PERFIM2
		cQuery += " SELECT AA1_NOMTEC NOMTEC"
		cQuery += " FROM " +RetSqlName('ABB')+ " ABB " 
		cQuery += " INNER JOIN " +RetSqlName('AA1')+ " AA1 "  
		cQuery += " ON AA1.AA1_CODTEC = ABB.ABB_CODTEC"
		cQuery += " AND AA1.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cQuery += " AA1.AA1_FILIAL = '" +xFilial("AA1")+ "' "
		Else
			cQuery += " " + FWJoinFilial("AA1" , "ABB" , "AA1", "ABB", .T.) + " "
		EndIf
		cQuery += " INNER JOIN " +RetSqlName('TDV')+ " TDV "  
		cQuery += " ON TDV_CODABB = ABB.ABB_CODIGO " 
		cQuery += " AND TDV.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cQuery += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
		Else
			cQuery += " " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " "
		EndIf	
		
		if (cAliasTFF)->PERINI > (cAliasTFF)->PERINI2 .AND. (cAliasTFF)->PERFIM < (cAliasTFF)->PERFIM2
			cQuery += " AND (TDV.TDV_DTREF < '" +(cAliasTFF)->PERINI+ "' "
			cQuery += "  OR TDV.TDV_DTREF > '" +(cAliasTFF)->PERFIM+ "') "
			nMsgPer := 1
		ElseIf (cAliasTFF)->PERINI > (cAliasTFF)->PERINI2
			cQuery += " AND TDV.TDV_DTREF < '" +(cAliasTFF)->PERINI+ "' "
			nMsgPer := 2
		ElseIf (cAliasTFF)->PERFIM < (cAliasTFF)->PERFIM2
			cQuery += " AND TDV.TDV_DTREF > '" +(cAliasTFF)->PERFIM+ "' " 
			nMsgPer := 3
		EndIf

		cQuery += " INNER JOIN " +RetSqlName('ABQ')+ " ABQ "
		cQuery += "  ON ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
		cQuery += " AND ABQ.ABQ_FILTFF = '" +(cAliasTFF)->FILIAL2+ "' "
		cQuery += " AND ABQ_CODTFF = '" +(cAliasTFF)->COD2+ "' "
		cQuery += " AND ABQ.D_E_L_E_T_ = ' ' "
		If !lMV_MultFil
			cQuery += " AND ABQ.ABQ_FILIAL = '" +xFilial("ABQ")+ "' "
		Else
			cQuery += " AND " + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + " "
		EndIf
		cQuery += " WHERE ABB.D_E_L_E_T_ = ' ' "
		If !lMV_MultFil
			cQuery += " AND ABB.ABB_FILIAL = '" +xFilial("ABB")+ "' "
		EndIf
		cQuery += " GROUP BY AA1.AA1_NOMTEC "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAGD,.T.,.T.)
		
		While !(cAliasAGD)->(EOF()) 
		    If lFirst
				lFirst := .F.
				cTexMsg += STR0328+(cAliasTFF)->COD2+CRLF
				If nMsgPer == 1
					cTexMsg += STR0337+DTOC(STOD((cAliasTFF)->PERINI2))+STR0330+DTOC(STOD((cAliasTFF)->PERINI))+ ": "+CRLF	// "Data de Inicio aumentada de " ## " para "
					cTexMsg += STR0331+DTOC(STOD((cAliasTFF)->PERFIM2))+STR0330+DTOC(STOD((cAliasTFF)->PERFIM))+ ": "+CRLF	// "Data de encerramento reduzida de " ## " para "	
				ElseIf nMsgPer == 2
					cTexMsg += STR0337+DTOC(STOD((cAliasTFF)->PERINI2))+STR0330+DTOC(STOD((cAliasTFF)->PERINI2))+ ": "+CRLF	// "Data de Inicio aumentada de " ## " para "	
				ElseIf nMsgPer == 3
					cTexMsg += STR0331+DTOC(STOD((cAliasTFF)->PERFIM2))+STR0330+DTOC(STOD((cAliasTFF)->PERFIM))+ ": "+CRLF	// "Data de encerramento reduzida de " ## " para "
				EndIf
				cTexMsg += STR0332+CRLF //"Existem agendas projetadas fora do novo período definido: "									
			EndIf			

			cTexMsg += STR0334+CRLF+(cAliasAGD)->NOMTEC+CRLF	//"Atendentes: "
		(cAliasAGD)->(dbSkip())
		End
	(cAliasAGD)->(dbCloseArea())
    EndIf
	(cAliasTFF)->(dbSkip())
End	
(cAliasTFF)->(dbCloseArea())

If !Empty(cTexMsg)
	AtShowLog(cTexMsg,STR0001,.T.,.T.,.T.,.F.) 	
	
	If At680Perm(NIL, __cUserId, "046", .T.)
		lRet := MsgYesNo(STR0335) //"Deseja aprovar a revisão mesmo com as inconsistências encontradas? Este processo não pode ser desfeito." 
	Else 
		Help(,,STR0001,, STR0336,1,0)  //"Usuário sem permissão para aprovar revisão com inconsistências"
		lRet = .F.
	Endif
EndIf 

Return lRet

//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT870Antco 

@description Antecipação do contrato possibilitando a alteracao na CN9
@param cContrato Numero do Contrato 
@param cRev Revisao
@param cCodorc Orcammento
@author	Vitor kwon
@since 26/08/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------
Static Function AT870Antco(cContrato,cRev,cCodorc,lAutomato,cDataINI,cDataFIM)

Local nX
Local nZ
local oFont  // Variavel Fonte
Local oSay1 
Local oSay2
Local oGet1
Local oGet2
Local oMdlCN301   := Nil // Model da CN9 
Local oMdlCNA   := Nil // Model da CN9 
Local aErrors	  := {}
Local aErroMVC	  := {}
Local cMsg		  := ""
Local cQry        := ""  // Query
Local cRevAnd     := ""  // Verifica se tem revisao Planejada
Local cAliasANT	  := ""  // Alias Temporario 
LOCAL cAliasTFG   := ""  // Alias Temporario TFG
Local cAliasTFF   := ""  // Alias Temporario TFF
Local cAliasTFH   := ""  // Alias Temporario TFH
Local cAliasTFL   := ""  // Alias Temporario TFL
Local cAliasTFJ   := ""  // Alias Temporario TFJ
Local nProxParc	  := 0
Local lHasButton  := .T. // Parametro oGet
Local lRet        := .F. //Variavel de Controle
Local lMsgRet	  := .F.
Local lOrcPrc 	  := SuperGetMv("MV_ORCPRC",,.F.) // Precificacao	
Local lPECronog	  := ExistBlock("AT870Ant")
Local lRecorre	  := !At740Recor(cContrato)
Local aSaveLines  := FWSaveRows()
Local dGet1       := CN9->CN9_DTINIC  // Data de Inicio
Local dGet2       := CN9->CN9_ASSINA // Data de Assinatura
local dChk01      := CN9->CN9_DTINIC // Data de Inicio
local dChk02      := CN9->CN9_ASSINA  // Data de Assinatura
Local aAreaTFF    := TFF->(GetArea()) // Salva area
Local aAreaTFH    := TFH->(GetArea()) // Salva area
Local aAreaTFG    := TFG->(GetArea()) // Salva area
Local aAreaTFL    := TFL->(GetArea()) // Salva area
Local aAreaTFJ    := TFJ->(GetArea()) // Salva area
Local aAreaCN9    := CN9->(GetArea()) // Salva area
Local cButton     := "QPushButton { background: #35ACCA; border: 1px solid #096A82;outline:0; border-radius: 5px; font: normal 10px Arial; padding: 6px;color: #ffffff;} QPushButton:pressed {background-color: #3AAECB;border-style: inset; border-color: #35ACCA; color: #ffffff; }"

Default lAutomato := .F.
Default cDataINI  := ""
Default cDataFIM  := ""

BEGIN TRANSACTION	

If CN240VldUsr(cContrato,DEF_TRARET,.T.) 
	cAliasANT := GetNextAlias()
	cRevAnd     := At580BSit(cContrato) 

	  cQry := " SELECT 1 "
	  cQry += " FROM "+RetSqlname("TFJ")+" TFJ
	  cQry += " WHERE  TFJ.D_E_L_E_T_ = ''
	  cQry += " AND TFJ.TFJ_CONTRT =  '"+cContrato+"'
	  cQry += " AND TFJ.TFJ_CONREV = ''   
 	If TFJ->(ColumnPos('TFJ_DTPLRV')) > 0  
	  cQry += " AND TFJ.TFJ_DTPLRV = ''  
	EndIf   
	  cQry += " AND TFJ.TFJ_CONTRT NOT IN  " 
	  cQry += " (SELECT TFV_CONTRT  FROM "+RetSqlname("TFV")+" TFV   "
	  cQry += " WHERE TFV.D_E_L_E_T_ = '' "
	  cQry += " AND TFV.TFV_FILIAL = TFJ.TFJ_FILIAL AND TFV.TFV_CONTRT = TFJ.TFJ_CONTRT "
	  cQry += " ) "
	  cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasANT,.T.,.T.)  

    If !(cAliasANT)->(Eof()) .And. (cRevAnd == "1")  

		iF !IsBlind()
			DEFINE MSDIALOG oDlg TITLE STR0338 FROM 000, 000  TO 180, 180 COLORS 0, 16777215 PIXEL // "Antecipação "

			oFont  := TFont():New('Arial',,-10,.T.)
			oSay1  := TSay():New(010,020,{||STR0339},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // 'Dt. Inicio'
			oGet1  := TGet():New(018,020, { | u | If( PCount() == 0, dGet1, dGet1 := u ) },oDlg, 060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGet1",,,,lHasButton  )
			oSay2  := TSay():New(038,020,{||STR0340},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // 'Dt. Assinatura'
			oGet2  := TGet():New(046,020, { | u | If( PCount() == 0, dGet2, dGet2 := u ) },oDlg, 060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGet2",,,,lHasButton  )
			oTButton1 := TButton():New( 070, 015, STR0005 ,oDlg,{||lRet := .F., oDlg:End()}, 25,12,,,.F.,.T.,.F.,,.F.,,,.F. )   // Sair 
			oTButton2 := TButton():New( 070, 045, STR0275 ,oDlg,{||lRet := .T., oDlg:End()}, 30,12,,,.F.,.T.,.F.,,.F.,,,.F. )   // Confirmar
			oTButton2:SetCss(cButton) 

			ACTIVATE MSDIALOG oDlg CENTERED
		else
		    lRet := .T.
            dGet1  := STod(cDataINI)  
			dGet2  := STod(cDataFIM) 			
		Endif	

        If lRet
			If dChk01 == dGet1 .and.  dChk02 == dGet2 // Verifica se houve alguma alteraçao na datas
				Help(,,"AT870ANTCO",,STR0341,1,0)  //"Nao houve alteracao nas datas"
		    	lRet = .F.
			EndIf

			iF Empty(dGet1) .or. Empty(dGet2) // Verifica se tem algum campo em Branco
		    	Help(,,"AT870ANTCO",,STR0342,1,0)  // "Existe algum campo não preenchido" 
		    	lRet = .F.
			EndIf 

			If dGet2 > dGet1 // Verifica se Data de Inicio seja anterior a data da Assinatura 
		        Help(,,"AT870ANTCO",, STR0343,1,0)  //"Nao é possivel que a Data de Inicio seja anterior a Data da Assinatura do Contrato"
		    	lRet = .F.
			EndIf 

			If dGet1 > dChk01 .OR. dGet2 > dChk02
				Help(,,"AT870ANTCO",, STR0366,1,0)  //"Não é possivel colocar uma data posterior a data inicial do contrato, somente antecipar."
		    	lRet = .F.
			EndIf
	
			If lRet
				CN9->(dbSetOrder(1))
			    
				If CN9->(MsSeek(xFilial("CN9")+cContrato+cRev))
					MsgRun(STR0345,STR0346,{||  CN100Situac("CN9",CN9->(RECNO()),"02")} )  // "Alterando Status para Contrato Em Elaboração" / ## "Aguarde o Processameento da Requisição"					
					
					oMdlCN301 := FWLoadModel("CNTA301")
					oMdlCN301:SetOperation(MODEL_OPERATION_UPDATE)  // Alteração
					lRet := oMdlCN301:Activate() // Ativa o modelo
					lRet := lRet .AND. oMdlCN301:SetValue('CN9MASTER','CN9_DTINIC',dGet1) // Altera a data para a selecionada no GET
					lRet := lRet .AND. oMdlCN301:SetValue('CN9MASTER','CN9_ASSINA',dGet2) // Altera a data para a selecionada no GET

					If lRet .And. (lMsgRet := MsgYesNo(STR0344)) // "Deseja replicar para os itens do contrato?"
						oMdlCNA := oMdlCN301:GetModel('CNADETAIL') 
						For nX := 1 To oMdlCNA:Length()	
							oMdlCNA:GoLine(nX)										
							lRet := lRet .AND. oMdlCNA:SetValue('CNA_PROMED',dGet1) 													
						Next
					EndIf
						
					If !lRet .OR. !(oMdlCN301:VldData() .And. oMdlCN301:CommitData())
						lRet := .F.
						aErroMVC := oMdlCN301:GetErrorMessage()
						If !Empty(aErroMVC[6])
							CargaErroM(@aErrors, aErroMVC)				
							For nX := 1 To LEN(aErrors)
								For nZ := 1 To LEN(aErrors[nX])
									cMsg += If(Empty(aErrors[nX][nZ]), aErrors[nX][nZ], aErrors[nX][nZ] + CRLF )
								Next
								cMsg += CRLF + REPLICATE("-",30) + CRLF
							Next
							If !ISBlind()
								AtShowLog(cMsg,STR0356,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Error"
							EndIf
						EndIf
						DisarmTransacation()
					EndIf	
						
					If  lRet 
						MsgRun( STR0347,STR0348,{||  CN100Situac("CN9",CN9->(RECNO()),"05")})  //"Alterando Status para Contrato para Vigente." ## "Aguarde o Processamento da Requisição"
					elseIf !Empty(cMsg)
						Help(,,"AT870ANTCO",,STR0349,1,0)  //Houve um problema na Atualização ou Usuario sem Permissao
						lRet := .F.
					EndIf
				Endif	
			Endif
			
	        If  lRet .AND. lMsgRet
			     //Atualizando a tabela TFL - Orçamento Servicos x Proposta com as datas Selecionadas 
			    cAliasTFL := GetNextAlias()  

			    cQry := " SELECT TFL.R_E_C_N_O_  TFLRECNO "
			    cQry += " FROM  "+RetSqlName("TFL")+" TFL  "
			    cQry += " INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFL_CODPAI = TFJ_CODIGO AND TFJ_FILIAL = '"+xFilial("TFL")+ "' "
			    cQry += " WHERE TFJ_CODIGO = '"+cCodorc+"' AND TFJ.D_E_L_E_T_ = '' AND  TFL.D_E_L_E_T_ = '' "
			    cQry := ChangeQuery(cQry)
			    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFL,.T.,.T.)

				While (cAliasTFL)->(!Eof()) 
				   TFL->(DbGoTo((cAliasTFL)->TFLRECNO))  // Atualiza a data de inicio da tabela TFL
					  RecLock("TFL",.F.) 
						TFL->TFL_DTINI := dGet1
					  TFL->(MsUnlock()) 
				   (cAliasTFL)->(DbSkip())
			 	EndDo  
				(cAliasTFL)->(DbCloseArea()) 
  
				//Atualizando a tabela TFF  - Recursos Humanos com as datas Selecionadas 
				cAliasTFF := GetNextAlias()

				cQry := "  SELECT TFF.R_E_C_N_O_ TFFRECNO "
				cQry += "  FROM  "+RetSqlName("TFF")+" TFF  "
				cQry += "  INNER JOIN "+RetSqlName("TFL")+" TFL  ON TFF_CODPAI = TFL_CODIGO  AND TFL_FILIAL = '"+xFilial("TFL")+ "' "
				cQry += "  INNER JOIN "+RetSqlName("TFJ")+" TFJ  ON TFL_CODPAI = TFJ_CODIGO  AND TFF_FILIAL = '"+xFilial("TFF")+ "' "
				cQry += "  WHERE TFJ_CODIGO = '"+cCodorc+"'"
				cQry += "  AND TFL.D_E_L_E_T_ = '' AND TFF.D_E_L_E_T_ = '' AND TFJ.D_E_L_E_T_ = '' "
				cQry := ChangeQuery(cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFF,.T.,.T.)

				While (cAliasTFF)->(!Eof()) 
					TFF->(DbGoTo((cAliasTFF)->TFFRECNO))  // Atualiza a data de inicio da tabela TFf
						If lPECronog .AND. (lRecorre .AND. TFF->TFF_COBCTR <> "2" )
							nProxParc := ExecBlock( "AT870Ant", .F., .F., { dGet1, TFF->TFF_PERFIM, cCodorc, TFF->TFF_PRCVEN, TFF->TFF_QTDVEN, TFF->TFF_PERINI, TFF->TFF_COD } )
						EndIf
						RecLock("TFF",.F.) 
							If lPECronog .AND. (lRecorre .AND. TFF->TFF_COBCTR <> "2" )
								TFF->TFF_VLPRPA := nProxParc
							EndIf
							TFF->TFF_PERINI := dGet1
						TFF->(MsUnlock()) 
					(cAliasTFF)->(DbSkip())
				EndDo  
				(cAliasTFF)->(DbCloseArea())

				//Atualizando a tabela TFG - Material de Implantacao com as datas Selecionadas
				cAliasTFG := GetNextAlias()

				cQry := " SELECT TFG.R_E_C_N_O_ AS  TFGRECNO "
				cQry += " FROM  "+RetSqlName("TFG")+" TFG  "

				If !lOrcPrc // MV_ORCPRC = .T.
					cQry += " INNER JOIN "+RetSqlName("TFF")+"  TFF ON TFF_COD    = TFG_CODPAI AND TFF_FILIAL    = '"+xFilial("TFF")+ "' AND TFF.D_E_L_E_T_ = '' "		 
					cQry += " INNER JOIN "+RetSqlName("TFL")+"  TFL ON TFL_CODIGO = TFF_CODPAI AND TFF_FILIAL    = '"+xFilial("TFL")+ "'"
					cQry += " INNER JOIN "+RetSqlName("TFJ")+"  TFJ ON TFL_CODPAI =  TFJ_CODIGO AND TFJ_FILIAL   = '"+xFilial("TFJ")+ "'" 
				Else
					cQry += " INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_CODIGO  =  TFG_CODPAI AND TFL_FILIAL   = '"+xFilial("TFL")+ "'"
					cQry += " INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFL_CODPAI  =  TFJ_CODIGO AND TFJ_FILIAL   = '"+xFilial("TFJ")+ "'"
				EndIf	 
					cQry += " WHERE TFJ_CODIGO = '"+cCodorc+"' AND TFG.D_E_L_E_T_ = '' AND TFG_FILIAL = '"+xFilial("TFG")+"' AND TFJ.D_E_L_E_T_ = '' AND TFL.D_E_L_E_T_ = '' "
					cQry := ChangeQuery(cQry)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFG,.T.,.T.)

				While (cAliasTFG)->(!Eof()) 
			    	TFG->(DbGoTo((cAliasTFG)->TFGRECNO))  // Atualiza a data de inicio da tabela TFG
					 RecLock("TFG",.F.) 
						TFG->TFG_PERINI := dGet1
					TFG->(MsUnlock()) 
				(cAliasTFG)->(DbSkip())
			    EndDo
			    (cAliasTFG)->(DbCloseArea())

			  	//Atualizando a tabela TFH - Material de Consumo com as datas Selecionadas  
				cAliasTFH := GetNextAlias()

				    cQry := " SELECT TFH.R_E_C_N_O_  TFHRECNO "
				    cQry += " FROM  "+RetSqlName("TFH")+" TFH  "
				If !lOrcPrc // MV_ORCPRC = .T.
					cQry += "  INNER JOIN "+RetSqlName("TFF")+"  TFF ON TFF_COD    = TFH_CODPAI AND TFF_FILIAL   = '"+xFilial("TFF")+  "' AND TFF.D_E_L_E_T_ = '' "		 
					cQry += "  INNER JOIN "+RetSqlName("TFL")+"  TFL ON TFL_CODIGO = TFF_CODPAI AND TFL_FILIAL   = '"+xFilial("TFL")+ "' "
					cQry += "  INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFL_CODPAI   = TFJ_CODIGO AND TFJ_FILIAL  = '"+xFilial("TFJ")+ "' "
				Else
					cQry += "  INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_CODIGO   =  TFH_CODPAI AND TFL_FILIAL  = '"+xFilial("TFL")+ "' "
					cQry += "  INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFL_CODPAI   = TFJ_CODIGO AND TFJ_FILIAL  = '"+xFilial("TFJ")+ "' "   
				EndIf
					cQry += " WHERE TFJ_CODIGO = '"+cCodorc+"' AND TFH.D_E_L_E_T_ = '' AND TFL.D_E_L_E_T_ = '' "
					cQry := ChangeQuery(cQry)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFH,.T.,.T.)

				While (cAliasTFH)->(!Eof()) 
					TFH->(DbGoTo((cAliasTFH)->TFHRECNO)) // Atualiza a data de inicio da tabela TFH
						RecLock("TFH",.F.) 
							TFH->TFH_PERINI := dGet1
						TFH->(MsUnlock()) 
					(cAliasTFH)->(DbSkip())
				EndDo  
				(cAliasTFH)->(DbCloseArea())
				
				//Atualizando a tabela TFJ - Orcamento de Serviços
			    cAliasTFJ := GetNextAlias()  

			    cQry := " SELECT TFJ.R_E_C_N_O_  TFJRECNO "
			    cQry += " FROM  "+RetSqlName("TFJ")+" TFJ  "
			    cQry += " WHERE TFJ_CODIGO = '"+cCodorc+"' AND TFJ.D_E_L_E_T_ = '' "
			    cQry := ChangeQuery(cQry)
			    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFJ,.T.,.T.)

				While (cAliasTFJ)->(!Eof()) 
				   TFJ->(DbGoTo((cAliasTFJ)->TFJRECNO))  // Atualiza a data de inicio da tabela TFJ
					  RecLock("TFJ",.F.) 
						TFJ->TFJ_DATA := dGet1
					  TFJ->(MsUnlock()) 
				   (cAliasTFJ)->(DbSkip())
			 	EndDo  
				(cAliasTFJ)->(DbCloseArea()) 

				MsgInfo(STR0352,STR0353)//"Data(s) Alterada com Sucesso" ## // "Alteração de datas"
            EndIf
			

		Else
		    Help(,,"AT870ANTCO",,STR0354,1,0)  //"Cancelado pelo Usuário"
		EndIf	
	Else
	    Help(,,"AT870ANTCO",,STR0350,1,0)  //Não é possivel Retroceder data em contratos Medidos/Apurados ou com Revisoes planejadas ou Revisões em Andamento. Favor verificar
    EndIf 
	(cAliasANT)->(DbCloseArea())
EndIf

END TRANSACTION

RestArea(aAreaTFF)
RestArea(aAreaTFH)
RestArea(aAreaTFG)
RestArea(aAreaTFL)
RestArea(aAreaTFJ)
RestArea(aAreaCN9)
FWRestRows(aSaveLines)

Return 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CargaErroM
@description Preencher o Array aErrors
@return lRet
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function CargaErroM(aErrors, aErroMVC)
AADD(aErrors, {	 STR0365  + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formulário de origem:"
									 STR0357 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
									 STR0358 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formulário de erro:"
									 STR0359 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
									 STR0360 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
									 STR0361 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
									 STR0362 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solução:"
									 STR0363 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribuído:"
									 STR0364 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
									 })
Return


