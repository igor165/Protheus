#INCLUDE "JURA108.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"

#DEFINE CAMPOSNAOCONFIG "NT9_CNOMEA|NT9_CNOMEP"

//--------------------------------------------------------------------
/*/{Protheus.doc} JURA108
Exportação personalizada

@param oLista   - Lista de registros que serão exportados
@param cTipoAs  - Tipo de assunto jurídico
@param aCampFil - Array de campos
@param lFila    - Indica se esta na fila de impressão

@author Juliana Iwayama Velho
@since 09/12/09
@version 1.0
/*/
//---------------------------------------------------------------------
Function JURA108(oLista, cTipoAs, aCampFil, lFila)
Local aListBox1  := {}
Local aListBox2  := {}
Local aCodPesq   := {}
Local oGrupList  := Nil
Local lTitNuz    := IIF(SUPERGETMV("MV_JEXPPTA", .T. , "2")=="1",.T.,.F.)
Local cAnoMes    := ""
Local aValores   := {}
Local lAnoMes    := (SuperGetMV('MV_JVLHIST',, '2') == '1')
Local lTemAnoMes := .F.
Local aAreaSX2   := SX2->( GetArea() )
Local aEspec     := {}
Local bLmpEsp    := {|| (aSize(aEspec,0), aSize(oGrupList:aCmpSel,0)) }
Local nQtMemo    := 0

Default cTipoAs  := ''
Default aCampFil := {}
Default lFila    := .F.

SX2->( dbSetOrder( 1 ) ) // X2_CHAVE
If SX2->( dbSeek( 'NYZ' ) )
	cAnoMes    := Space(TamSx3('NYZ_ANOMES')[1])
	lTemAnoMes := .T. // Caso tenha o campo no dicionário será liberado na tela para uso
EndIf

If oLista:getQtdReg() > 0

	DEFINE MSDIALOG oDlgExp TITLE STR0002 FROM 0,0 TO 500,785 PIXEL

	// Cria Componentes Padroes do Sistema
	@ 030,010 Say    STR0034 Size 115,007 COLOR CLR_BLACK PIXEL OF oDlgExp									// "Tabelas"
	@ 055,010 Say    STR0001 Size 115,007 COLOR CLR_BLACK PIXEL OF oDlgExp   								// Exportação personalizada
	@ 055,200 Say    STR0003 Size 106,008 COLOR CLR_BLACK PIXEL OF oDlgExp   								// Exportação
	@ 090,150 Button STR0004 Size 045,012 PIXEL OF oDlgExp Action oGrupList:AllToSel()  					// "Inc. Todos >>"
	@ 110,150 Button STR0005 Size 045,012 PIXEL OF oDlgExp Action oGrupList:OneToSel()						// "Incluir >>"
	@ 130,150 Button STR0007 Size 045,012 PIXEL OF oDlgExp Action oGrupList:OneToDisp () 					// "<< Remove "
	@ 150,150 Button STR0008 Size 045,012 PIXEL OF oDlgExp Action (oGrupList:AllToDisp(), Eval(bLmpEsp))	// "<< Rem. Todos"
	@ 105,340 Button STR0009 Size 050,012 PIXEL OF oDlgExp Action oGrupList:MoveUp()						// "Mover para cima"
	@ 125,340 Button STR0010 Size 050,012 PIXEL OF oDlgExp Action oGrupList:MoveDown()						// "Mover para baixo"

	If lTemAnoMes
		@ 160,340 Say    STR0062 Size 106,008 COLOR CLR_BLACK PIXEL OF oDlgExp  //"Ano-Mês Atualização:"
		@ 170,340 MsGet  oAnoMes Var cAnoMes WHEN JA108WaMes(aValores,oGrupList:aCmpSel,lAnoMes) VALID .T. Size 50,8 Pixel Of oDlgExp
		@ 234,282 Button STR0011 Size 050,012 PIXEL OF oDlgExp Action MsgRun(STR0044,STR0013,{|| IIF(JA108Vld(lAnoMes,cAnoMes,aValores, oGrupList),JA108GREXP(oLista,oGrupList:GetCmpSel(),oGrupList:GetConfig(),cAnoMes,aCampFil, lFila, aEspec),) })
	Else
		@ 234,282 Button STR0011 Size 050,012 PIXEL OF oDlgExp Action MsgRun(STR0044,STR0013,{|| JA108GREXP(oLista,oGrupList:GetCmpSel(),oGrupList:GetConfig(),,aCampFil, lFila, aEspec) })
	EndIf

	@ 234,340 Button STR0012 Size 050,012 PIXEL OF oDlgExp Action oDlgExp:End()

	@ 067,340 Button STR0070 Size 050,012 PIXEL OF oDlgExp Action J108FEXTR(@aEspec,@oGrupList:aCmpSel) //"Filt. Agrup."

	oGrupList := JurLstBoxD():New()
	//Habilita pesquisa por título dos campos disponíveis e renomear títulos dos campos selecionados
	oGrupList:SetEnabSch(.T.)
	oGrupList:SetEnabRen(.T.)

	oGrupList:befAdd := {|oObj1,oObj2,aOrigem,aDestino, lRem| J108FESPE(@aEspec,oObj1,oObj2,aOrigem,aDestino,lRem)}

	oGrupList:SetPosCmbTabela( {040,010,133,007} ) // combo tabelas
	oGrupList:SetCmbTabela(JA108Tabs(cTipoAs, lTitNuz))
	oGrupList:SetSelectTab( { |x|JA108Lista(x, cTipoAs) } )
	oGrupList:SetRemove( { |x|JA108Orig(x) } )

	//Habilita as opções de configuração
	oGrupList:SetEnabConfig(.T.)
	If oGrupList:GetEnabConfig()

		@ 006,010 Say    STR0033 Size 115,007 COLOR CLR_BLACK PIXEL OF oDlgExp //Configuração label

		If JA162AcRst('12',4)
			@ 015,150 Button STR0032 Size 045,012 PIXEL OF oDlgExp Action JA108NVCFG(oGrupList:GetCmpSel(),oGrupList,2,cTipoAs, aEspec) //Botão Atualizar
		EndIf
		If JA162AcRst('12',3)
			@ 015,340 Button STR0020 Size 050,012 PIXEL OF oDlgExp Action JA108NVCFG(oGrupList:GetCmpSel(),oGrupList,1,cTipoAs, aEspec) //Botão Salvar como
		EndIf

		//Coordenadas do combo e get da configuração
		oGrupList:SetPosCmbConfig( {016,010,133,007} ) // combo configurações
		oGrupList:SetCmbConfig(JA108Confg(cTipoAs, lTitNuz))
		oGrupList:SetPosGetNewConfig( {016,200,133,007} ) // Campos texto salvar como
		oGrupList:SetNewConfig(CriaVar('NQ5_DESC'))
		oGrupList:SetSelect( { |x| Eval(bLmpEsp), JA108AtCps(x) } )

	EndIf

	//Coordenadas do get e button da pesquisa
	oGrupList:SetPosGetSearch( {220,010,133,007} )
	oGrupList:SetPosBtnSearch( {219,150,045,012} )

	//Coordenadas do get e button de renomeio
	oGrupList:SetPosGetRename( {220,200,133,007} )
	oGrupList:SetPosBtnRename( {219,340,050,012} )

	//Array de campos disponíveis e coordenadas
	oGrupList:SetCmpDisp(aListBox1)
	oGrupList:SetPosCmpDisp( {068,010,133,140} ) // Lista campos disponiveis

	//Array de campos selecionados e coordenadas
	oGrupList:SetCmpSel(aListBox2)
	oGrupList:SetPosCmpSel( {068,200,133,140} ) //Lista campos selecionados
	oGrupList:SetDlgWin( oDlgExp )
	oGrupList:Activate(@nQtMemo)

	If NW8->(FieldPos('NW8_CAMPH')) > 0 .And. lAnoMes
		aValores := JA108NW8()
	Endif

	ACTIVATE MSDIALOG oDlgExp CENTERED

	//limpa arrays
	aSize(aListBox1,0)
	aSize(aListBox2,0)
	aSize(aCodPesq,0)
	aSize(aValores,0)

	//limpa memória da instancia do objeto criado.
	oGrupList:Deactivate()
	freeObj(oGrupList)

EndIf

RestArea( aAreaSX2 )

Return(.F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Lista
Atualiza o array de campos disponíveis para exportação
Uso Geral.

@param oGrupList    Objeto da lista
@param cTipoAs      Tipo de assunto jurídico
@return aLista	    Lista de campos

@author Juliana Iwayama Velho
@since 05/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA108Lista( oGrupList, cTipoAs )
Local nI, nJ, nCt, nPos
Local aLista   := {}
Local aTab     := {}
Local aCamps   := {}
Local aFormulas:= {}
Local aExporta := oGrupList:GetCmpSel()
Local cTabela  := oGrupList:GetTabela()
Local aArea    := GetArea()
Local aAreaNQ0 := NQ0->( GetArea() )
Local aAreaNQ2 := NQ2->( GetArea() )
Local cNQ2Cod  := ""

If !Empty(cTabela)

	NQ0->(DBSetOrder(1))

	If NQ0->(DBSeek(xFILIAL('NQ0') + cTabela))

		nCt := 0

		NQ2->( dbSetOrder( 2 ) )
		NQ2->( dbSeek( xFilial( 'NQ2' ) + NQ0->NQ0_TABELA) )

		While !NQ2->( EOF() ) .AND. xFilial( 'NQ2' ) + NQ0->NQ0_TABELA  == NQ2->NQ2_FILIAL + NQ2->NQ2_TABELA
			If NQ0->NQ0_APELID == NQ2->NQ2_APELID
				nCt := nCt + 1

				cNQ2Cod := NQ2->NQ2_COD
			Endif
			NQ2->( dbSkip() )
		End

		aCamps := JA108Camps( NQ0->NQ0_TABELA, NQ0->NQ0_APELID, nCt > 0 , cTipoAs, cNQ2Cod )

		aTab := aCamps[1]
		aFormulas := aCamps[2]

		// Copia o conteudo do Array aTab para o array aLista (Campos)
		For nI:= 1 to Len(aTab)
			 aAdd(aLista,aTab[nI])
		Next

		// Copia o conteudo do Array aFormulas para o array aLista (Formulas)
		For nI:= 1 to Len(aFormulas)
			aAdd(aLista,aFormulas[nI])
		Next

		//Exclui os campos selecionados da lista dos disponíveis
		If !Empty( aExporta )

			For nJ := 1 To Len (aExporta)

				//Campo
				If(Len (aExporta[nJ]) > 5)
					nPos := aScan( aLista, { |x| x[3] == aExporta[nJ][3] .AND. x[7] == aExporta[nJ][7]} )

				//Formula
				Else
					nPos := aScan( aLista, { |x| x[2] == aExporta[nJ][2] .AND. x[3] == aExporta[nJ][3] .AND. x[4] == aExporta[nJ][4]} )
				EndIf

				If nPos <> 0
					aDel(aLista, nPos)
					aSize(aLista, LEN(aLista)-1)
				EndIf
			Next nJ
		EndIf

	EndIf

EndIf

RestArea(aAreaNQ0)
RestArea(aAreaNQ2)
RestArea(aArea)

aSize(aTab,0)

Return aLista

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Camps
Gera a lista de campos disponíveis para exportação
Uso Geral.

@param  cTabela   Nome da tabela
@param  cNomeAp   Nome do apelido
@param  lApelido  Se o apelido será ou não usado
@param  cTipoAs   Tipo de assunto juridico
@param  cNQ2Cod   Código relação exportação

@return aCampos	    Lista de campos

@author Juliana Iwayama Velho
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA108Camps( cTabela, cNomeAp, lApelido, cTipoAs, cNQ2Cod )
Local lTitNuz    := SUPERGETMV("MV_JEXPPTA", .T. , "2") == "1"
Local cQuery     := ""
Local cQueryForm := ""
Local aCampos    := {}
Local aCampos2   := {}
Local aFormulas  := {}
Local cAlias     := GetNextAlias()
Local aArea      := GetArea()
Local aAreaNQ2   := NQ2->( GetArea() )
Local aAreaNQV   := NQV->( GetArea() )
Local aAreaSX3   := SX3->( GetArea() )
Local aRestNuz   := {}
Local cTitulo    := ''
Local lTabCfg    := J108CfgTab(cTabela, cTipoAs) //Configuração da tabela. Se uma tabela não é configurável, todos os campos devem ser exibidos
Local nCol       := 0
Local cFiltro    := ""
Local lNZJInDic  := FWAliasInDic("NZJ") //Verifica se existe a tabela NZJ - Fórmulas no Dicionário (Proteção)
Local cCposNPerm := "NTE_CFLWP/NTE_CPART/NSZ_COD"  //Campos que não podem aparecer nos campos disponiveis.

Default lApelido   := .F.
Default cNomeAp    := ''

	If lNZJInDic
		cQueryForm := JA108Formu(cTabela, cNomeAp, cNQ2Cod)
	EndIf

	If lTitNuz
		aRestNuz := J108NuzCpo(cTipoAs, cTabela)
	Endif

	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder( 1 ) )
	SX3->( dbSeek( cTabela ) )

	If lTitNuz .Or. cTabela == "NSZ"

		While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == cTabela
			//Valida se o campo pode ser usado. e se o parametro de tela simples de objeto está ativado, para que apareça apenas os campos resumidos
			If (X3USO(SX3->X3_USADO) .AND. SX3->X3_CONTEXT <> "V" .AND. ! AllTrim(SX3->X3_CAMPO) $ cCposNPerm)
				//Valida se o parâmetro de campos usando a NUZ esta ativo..
				If aScan(aRestNuz,{ |aX| AllTrim(aX[1]) == AllTrim(SX3->X3_CAMPO) }) > 0 .OR. x3Obrigat( SX3->X3_CAMPO ) .Or. !lTabCfg .Or. (cTabela == "NSZ" .And. !lTitNuz)  //valida parâmetro
					cFiltro := Posicione('NQ2', 3 , xFilial('NQ2') + cNomeAp , 'NQ2_FILTRO')

					//define o título do campo
					If lTitNuz .And. aScan(aRestNuz,{ |aX| aX[1] == SX3->X3_CAMPO }) > 0 .And. ( __Language == 'PORTUGUESE')
						cTitulo := aRestNuz[aScan(aRestNuz, { |aX| aX[1] == SX3->X3_CAMPO })][2]
					Else
						cTitulo := JA023X3Des(SX3->X3_CAMPO)
					Endif

					aAdd( aCampos2, JA108MtCps(SX3->X3_CAMPO  , SX3->X3_CAMPO, cNomeAp, cNomeAp, SX3->X3_ARQUIVO,;
					                           SX3->X3_ARQUIVO, cFiltro      , ''     , .F.    , cTitulo        ,;
					                           lTitNuz) )

					aAdd(aCampos,aCampos2[1][1])
					aSize(aCampos2,0)
				Endif
			EndIf
			SX3->(DbSkip())
		End

	Endif

	cQuery := JA108SQL(lApelido, cTabela, cNomeAp)
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		lTabCfg    := J108CfgTab((cAlias)->TABDETAIL, cTipoAs) //atualiza a informação se a tabela possui ou não configuração
	    //valida parâmetro e campos.
		If !lTitNuz .Or. ;
		   !lTabCfg .Or. ;
		   (lTitNuz .And.;
	       	((aScan(aRestNuz,{ |aX| aX[1] == (cAlias)->NQV_CAMPOT }) > 0)) .Or. ; // Verificar se está na lista de campos da NUZ
			    lTabCfg .And. (cAlias)->TABMASTER != "NSZ")                          // Ou se é uma tabela que existe na NUZ mas não é filha da NSZ

			cTitulo := ""
			If lTitNuz .And. aScan(aRestNuz,{ |aX| (aX[1] == (cAlias)->NQV_CAMPOT) }) > 0
				nCol := aScan(aRestNuz,{ |aX| (aX[1] == (cAlias)->NQV_CAMPOT) })
				cTitulo := aRestNuz[nCol][2]
			Else
				cTitulo := JA023X3Des(IIF(Empty((cAlias)->NQV_CAMPOT),(cAlias)->NQV_CAMPO,(cAlias)->NQV_CAMPOT))
			Endif
			If aScan(aCampos,{ |aX| AllTrim(aX[3]) == AllTrim(IIF(Empty((cAlias)->NQV_CAMPOT),(cAlias)->NQV_CAMPO,(cAlias)->NQV_CAMPOT)) }) == 0

				cFiltro := IIF(!EMPTY((cAlias)->FILTRO), (cAlias)->FILTRO, IIF(!Empty(aCampos), aCampos[1][10], '') )

				aAdd( aCampos2, JA108MtCps( (cAlias)->NQV_CAMPOT, (cAlias)->NQV_CAMPO, (cAlias)->NQ0_APELID, (cAlias)->NQ2_APELID, (cAlias)->TABMASTER,;
											(cAlias)->TABDETAIL , cFiltro            , ''                  , lApelido            , cTitulo            ,;
											lTitNuz) )

				aAdd(aCampos,aCampos2[1][1])
				aSize(aCampos2,0)

			Endif
		EndIf

		(cAlias)->( dbSkip() )
	end
	(cAlias)->( dbcloseArea() )

	//Ordena os campos conforme campo de ordem do dicionário
	aSort(aCampos, , , { |x,y| x[8] < y[8] } )

	//Formulas
	If lNZJInDic
		cAlias := GetNextAlias()

		cQueryForm := ChangeQuery(cQueryForm)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryForm),cAlias,.T.,.T.)

		(cAlias)->( dbGoTop() )

		While !(cAlias)->( EOF() )
			aAdd(aFormulas,{Alltrim((cAlias)->NZJ_DESC), '  -  ( ' + AllTrim((cAlias)->NZJ_FUNC) + ' ) ', (cAlias)->NZJ_PARAM, (cAlias)->NQ2_APELID, SubStr(aCampos[1][3],1,3) })
			(cAlias)->( dbSkip() )
		End

		(cAlias)->( dbcloseArea() )
	EndIf

	RestArea(aAreaSX3)
	RestArea(aAreaNQV)
	RestArea(aAreaNQ2)
	RestArea(aArea   )

	aSize(aRestNuz,0)
	aSize(aCampos2,0)

//Return aCampos e aFormulas
Return {aCampos, aFormulas}


//-------------------------------------------------------------------
/*/{Protheus.doc} JA108MtCps
Monta o array dos campos da exportação personalizada
Uso Geral.

@param cCampoTela	Campo de tela (para substituir no select)
@param cCampo		Campo disponível
@param cApelido1n	Apelido 1º Nível
@param cApelido2n	Apelido 2º Nível
@param cTab1n		Tabela 1º Nível
@param cTab2n		Tabela 2º Nível
@param cFiltro		Filtro
@param cOrdem		Ordem do campo nas colunas da exportação
@param lApelido		Se o título terá ou não apelido
@param cTitCampo	Título do campo
@param lTitNuz      Indica se o tírulo vem da NUZ
@param nPriult      Indica se é primeiro ou ultimo registro da tabela agrupadora
@param lFormula     Indica se é formula

@return aCampos	    Array com informações do campo

@author Juliana Iwayama Velho
@since 17/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108MtCps(cCampoTela, cCampo , cApelido1n, cApelido2n, cTab1n   ,;
                           cTab2n    , cFiltro, cOrdem    , lApelido  , cTitCampo,;
                           lTitNuz   , nPriult, lFormula  )

Local cMudaCampo := ''
Local cTab       := ''
Local cNomeTab   := ''
Local cTitulo    := ''
Local aCampos    := {}
Local lAgrupa    := .F.
Local cTipo      := ""
Local cCmpBox    := ""

Default cOrdem    := "00"
Default cTitCampo := ''
Default lTitNuz   := .F.
Default nPriUlt   := 0
Default lFormula  := .F.

If !lFormula
	cMudaCampo:= IIf( Empty( cCampoTela ), AllTrim( cCampo ), AllTrim( cCampoTela ) )
	cTab      := Left( cMudaCampo, J108RetUnd(cMudaCampo) - 1 )
	cTipo     := GetSx3Cache(cMudaCampo, "X3_TIPO")
	cOrdem    := GetSx3Cache(cMudaCampo, "X3_ORDEM")

	If __Language == 'PORTUGUESE'
		cCmpBox := GetSx3Cache(cCampo, 'X3_CBOX')
	ElseIf __Language == 'ENGLISH'
		cCmpBox := GetSx3Cache(cCampo, 'X3_CBOXENG')
	ElseIf __Language == 'SPANISH'
		cCmpBox := GetSx3Cache(cCampo, 'X3_CBOXSPA')
	EndIf

	// Chama a função do qual receberá a descrição do campo passado como parametro
	// Caso o título venha da NUZ, utilizar o que veio via parâmetro.
	If Empty( cTitCampo ) .Or. !lTitNuz
		cTitCampo :=  AllTrim( JA023X3Des( cMudaCampo ) )
	EndIF

	If Empty(JurGetDados('NQ0', 3 , xFilial('NQ0') + cApelido2n, 'NQ0_AGRUPA'))
		lAgrupa   := JurGetDados('NQ0', 3 , xFilial('NQ0') + cApelido1n, 'NQ0_AGRUPA') == '1'
	Else
		lAgrupa   := JurGetDados('NQ0', 3 , xFilial('NQ0') + cApelido2n, 'NQ0_AGRUPA') == '1'
	Endif


	cNomeTab  := AllTrim(JurGetDados('NQ0', 3 , xFilial('NQ0') + cApelido2n, 'NQ0_DTABEL')  )

	If Empty(cNomeTab)
		cNomeTab  :=  JA023TIT(cTab2n)
	Endif

	cTitulo  :=  '  -  ( ' + AllTrim(cNomeTab) + ' ) '

EndIf

If nPriUlt == 0
	If !lFormula
		aAdd( aCampos, {cTitCampo,;
						cTitulo,;
						AllTrim( cCampo ),;
						cTab1n,;
						cTab2n,;
						cApelido1n,;
						cApelido2n,;
						IIf ( Empty(cOrdem), (cOrdem), (cOrdem) ),;
						cTipo,;
						cFiltro,;
						cCampoTela,;
						lAgrupa,;
						"",; //Nome do campo no SELECT
						cCmpBox } ) //Informação de combo
	Else
		aAdd( aCampos, { cTitCampo,;
						cTitulo,;
						AllTrim( cCampo ),;
						cTab1n,;
						cTab2n,;
						cApelido1n,;
						cApelido2n,;
						IIf ( Empty(cOrdem), (cCampoTela), (cOrdem) ),;
						cTipo,;
						cFiltro,;
						cCampoTela,;
						lAgrupa } ) //Informação de combo
	EndIf
Else
	If !lFormula
		aAdd( aCampos, { cTitCampo,;
						cTitulo,;
						AllTrim( cCampo ),;
						cTab1n,;
						cTab2n,;
						cApelido1n,;
						cApelido2n,;
						IIf ( Empty(cOrdem), (cOrdem), (cOrdem) ),;
						cTipo,;
						cFiltro,;
						cCampoTela,;
						lAgrupa,;
						"",; //Nome do campo no SELECT
						cCmpBox,; // } ) //Informação de combo
						nPriUlt	} )
	Else
		aAdd( aCampos, { cTitCampo,;
						cTitulo,;
						AllTrim( cCampo ),;
						cTab1n,;
						cTab2n,;
						cApelido1n,;
						cApelido2n,;
						IIf ( Empty(cOrdem), (cCampoTela), (cOrdem) ),;
						cTipo,;
						cFiltro,;
						cCampoTela,;
						lAgrupa,;
						nPriUlt	} )
	EndIf
EndIf


// Desaloca o contéudo da memoria.
cMudaCampo := nil
cTab := nil
cTitCampo := nil

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108SQL(lApelido, cTabela, cNomeAp, nTipoComp)
Gera a query para montar a lista de campos disponíveis a partir de
cadastro.
Uso Geral.

@param lApelido  	- Utiliza o apelido da tabela
@param cTabela   	- Nome da tabela
@param cNomeAp    	- Apelido da tabela
@param nTipoComp 	- Qual o tipo de comparação
					0 = Verifica se é tabela pai e filho
					1 = Verifica se é tabela pai
					2 = Verifica se é tabela filha

@return cQuery	    Query montada

@author Juliana Iwayama Velho
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108SQL(lApelido, cTabela, cNomeAp, nTipoComp)
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryWhrCmp := ""
Local cTabelas   := ""
Local nI         := 0
Local aTabNiveis := {}

Default nTipoComp := 0

	// Clausula Select
	cQrySel := " SELECT NQV_CAMPO, "
	cQrySel +=        " NQV_CAMPOT, "
	cQrySel +=        " NQ2_TABELA TABDETAIL, "
	cQrySel +=        " NQ0_TABELA TABMASTER, "
	cQrySel +=        " NQ0_APELID, "
	cQrySel +=        " NQ2_APELID, "
	cQrySel +=        " NQ2_FILTRO FILTRO "

	// Clausula From
	cQryFrm += " FROM " + RetSqlName("NQV") + " NQV INNER JOIN " + RetSqlName("NQ2") + " NQ2 ON (NQ2.NQ2_COD = NQV.NQV_CRELAC "
	cQryFrm +=                                                                             " AND NQ2.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                                                             " AND NQ2.NQ2_FILIAL = '" + xFilial("NQ2") + "') "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NQ0") + " NQ0 ON (NQ0.NQ0_COD = NQ2.NQ2_CTABEL "
	cQryFrm +=                                                                             " AND NQ0.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                                                             " AND NQ0.NQ0_FILIAL = '" + xFilial("NQ0") + "') "

	// Clausula Where
	cQryWhr += " WHERE NQV.D_E_L_E_T_ = ' '
	cQryWhr +=   " AND NQV.NQV_FILIAL = '" + xFilial("NQV") + "'"

	If lApelido
		Do Case
			Case nTipoComp==1 // Apelido da pai
				cQryWhrCmp := " AND (NQ0_APELID='"+cNomeAp+"')"
			Case nTipoComp==2 // Apelido da Filha
				cQryWhrCmp := " AND (NQ2_APELID = '"+cNomeAp+"')"
			Otherwise         // Ambos
				cQryWhrCmp := " AND (NQ2_APELID = '"+cNomeAp+"' OR NQ0_APELID='"+cNomeAp+"')"
		EndCase

		cQryWhr += cQryWhrCmp

	Else
		cQryWhr += " AND NQ0_TABELA = '"+cTabela+"' AND NQ0_APELID='" + cNomeAp + "'"

		// Verifica se há tabelas de outros niveis
		aTabNiveis := JA108TabF(3)

		For nI:= 1 to Len( aTabNiveis )
			If HasRelNSZ( aTabNiveis[nI][1])
				cTabelas := cTabelas + "'"+aTabNiveis[nI][1]+"',"
			EndIf
		Next

		If Len( aTabNiveis ) > 0
			cQryWhr += " AND NQ2_TABELA NOT IN ("+SUBSTRING(cTabelas,1,Len(cTabelas)-1)+")  "
		Endif
	Endif

	// Monta a query
	cQuery := cQrySel + cQryFrm + cQryWhr

	aSize(aTabNiveis,0)
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108GSQL
Gera a query para montar a exportação personalizada
Uso Geral.

@param aCamposSel	Array de campos selecionados para exportação
			   		[1] - Título do campo
				    [2] - Título da Tabela
				    [3] - Campo
				    [4] - Tabela 1º Nível
				    [5] - Tabela 2º Nível
				    [6] - Apelido 1º Nível
				    [7] - Apelido 2º Nível
				    [8] - Ordem do campo no dicionário //se mudar esta posição, verificar rotinas de ordenação no código
				    [9] - Tipo do Campo
				    [10] - Filtro
				    [11] - Campo de tela (para substituir no select)

				    [12] - Nome do campo utilizado no SELECT
					[14] - Lista de opções do campo
@param lCamposAg  - Inica se irá agrupar
@param lIncrSQL   - Indica se terá incremento na query
@param aFiltro    - Filtros para incluir na query
@param lFila      - Indica se usa fila de impressão
@param aEspec     - Filtro especial
@param nAgrupa    - Indica se agrupa primero / último registro
@Param lFiltFili  - Verifica se ultiliza xfilial
@Param cEntFilial - Entidade para relacionar Filial.
@param cThread    - Thread utilizada na fila de impressão
@param cCmpsOrder - Campos a serem utilizados no order by da query

@return cQuery	    Query montada

@author Juliana Iwayama Velho
@since 17/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108GSQL(aCamposSel, lCamposAg, lIncrSQL, aFiltro, lFila, aEspec, nAgrupa, lFiltFili, cEntFilial, cThread, cCmpsOrder)
Local cQuery     := ""
Local aArea      := GetArea()
Local aExtra     := {}
Local cApProc    := JurGetDados('NQ0', 2 , xFilial('NQ0') + 'NSZ' , 'NQ0_APELID')
Local aTabsApl   := J108ArrApl(aCamposSel)
Local cCampos    := ""
Local nPosCam    := 0
Local cSelect    := ""
Local cFrom      := ""
Local cWhere     := ""

Default lIncrSQL   := .F.
Default cCmpsOrder := "NSZ_FILIAL,NSZ_COD"

	cCampos := J108SQLFld(aCamposSel, aEspec)

	nPosCam := Len(AllTrim(cCampos))

	If (!Empty(cCampos)) .Or. (Empty(cCampos) .And. (Len (aCamposSel[1]) == 5))

		cSelect := "SELECT "+AllTrim(cApProc)+"."+"NSZ_FILIAL, "+AllTrim(cApProc)+"."+"NSZ_COD"+ SUBSTRING(cCampos,1,nPosCam) + " "
		cSelect += J108SQLFor(aCamposSel, 'NT2_' $ cCampos)

		cFrom   := J108SQLFrm(aCamposSel, aFiltro, aEspec, lFila, lCamposAg, cThread)

		cWhere  := J108SQLWhr(lFila, aExtra, aFiltro, cFrom, aTabsApl, lFiltFili, cEntFilial)

		cQuery := cSelect + cFrom + cWhere

		If !lIncrSQL
			cQuery += J108OrderBy(cCmpsOrder)
		EndIf
	EndIf

	If Empty(cFrom) .OR. Empty(cSelect)
		cQuery := ""
	EndIf

	RestArea(aArea)

	aSize(aExtra,0)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J108SQLFld(aCamposSel)
Monta os campos para o Select, SEM AS FORMULAS

@param aCamposSel	Array de campos selecionados para exportação
			   		[1] - Título do campo
				    [2] - Título da Tabela
				    [3] - Campo
				    [4] - Tabela 1º Nível
				    [5] - Tabela 2º Nível
				    [6] - Apelido 1º Nível
				    [7] - Apelido 2º Nível
				    [8] - Ordem do campo no dicionário //se mudar esta posição, verificar rotinas de ordenação no código
				    [9] - Tipo do Campo
				    [10] - Filtro
				    [11] - Campo de tela (para substituir no select)

				    [12] - Nome do campo utilizado no SELECT
					[14] - Lista de opções do campo

@return cCampos	Campos concatenados

@author Willian Kazahaya
@since 03/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108SQLFld(aCamposSel, aEspec)
Local cCampos     := ''
Local nX          := 0
Local nTemp       := 0
Local cApProc     := JurGetDados('NQ0', 2 , xFilial('NQ0') + 'NSZ' , 'NQ0_APELID')

	//concatena os campos para o select
	//Apelido dos campos é composto a partir do caracter "_" concatenado com o número do loop
	For nX:= 1 to Len(aCamposSel)
		If(Len (aCamposSel[nX]) > 5) //Verifica se é uma formula
			If !(aCamposSel[nX][3] $ CAMPOSNAOCONFIG)
				// Verifica se o campo é da NTE para incluir a Filial e o Código obrigatóriamente
				If 'NTE_' $ aCamposSel[nX][3] .AND. !('NTE_' $ cCampos)
					If !(', NTA_FILIAL, NTA_COD' $ cCampos)
						cCampos += ", NTA_FILIAL, NTA_COD"
					EndIf
					Loop
				EndIf

				cApelCampo := J108VerUnd(AllTrim(aCamposSel[nX][3])) +AllTrim(Str(nX))
				aCamposSel[nX][13] := cApelCampo

				If (nTemp := aScan(aEspec,{|x| x[3] = aCamposSel[nX][3] .And. x[7] = aCamposSel[nX][7]} )) == 0
					If aCamposSel[nX][12] .or. !aCamposSel[nX][5] $ cApProc
						If Right(aCamposSel[nX][3],5) == "_HORA" .OR. Right(aCamposSel[nX][3],7) == "_DURACA" //se for hora, coloca a máscara na query
							cCampos += ", SUBSTRING("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+",1,2) || ':' || SUBSTRING("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+",3,2) "+ cApelCampo
						Else
							cCampos += ", "+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+" "+ cApelCampo

							If aCamposSel[nX][9] == 'M'
								cCampos += ", "+AllTrim(aCamposSel[nX][7])+".R_E_C_N_O_ "+AllTrim(aCamposSel[nX][7])+"RECNO"

								//Valida se é oracle para otimizar a utilização de campos MEMO
								If (Upper(TcGetDb())) == "ORACLE"
									cCampos += ", to_char(substr("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+",1,4000)) MEM_"+ cApelCampo
									cCampos += ", nvl(dbms_lob.getlength("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+"),0) SZ_"+ cApelCampo
								Elseif (Upper(TcGetDb())) == "MSSQL"
									cCampos += ", cast("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+" as varchar(4000)) MEM_"+ cApelCampo
									cCampos += ", datalength("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+") SZ_"+ cApelCampo
								Elseif (Upper(TcGetDb())) == "DB2"
									cCampos += ", cast(substr("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+",1,4000) as VARCHAR(4000)) MEM_"+ cApelCampo
									cCampos += ", nvl(length("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+"),0) SZ_"+ cApelCampo
								Endif
							EndIf
						EndIf
					Else
						cCampos += ", "+AllTrim(cApProc)+"."+AllTrim(aCamposSel[nX][3])+" "+ cApelCampo

						If aCamposSel[nX][9] == 'M'
							cCampos += ", "+AllTrim(cApProc)+".R_E_C_N_O_ "+AllTrim(cApProc)+"RECNO"

							//Valida se é oracle para otimizar a utilização de campos MEMO
							if (Upper(TcGetDb())) == "ORACLE"
								cCampos += ", to_char(substr("+AllTrim(cApProc)+"."+AllTrim(aCamposSel[nX][3])+",1,4000)) MEM_"+ cApelCampo
								cCampos += ", nvl(dbms_lob.getlength("+AllTrim(cApProc)+"."+AllTrim(aCamposSel[nX][3])+"),0) SZ_"+ cApelCampo
							Elseif (Upper(TcGetDb())) == "MSSQL"
								cCampos += ", cast("+AllTrim(cApProc)+"."+AllTrim(aCamposSel[nX][3])+" as varchar(4000)) MEM_"+ cApelCampo
								cCampos += ", datalength("+AllTrim(cApProc)+"."+AllTrim(aCamposSel[nX][3])+") SZ_"+ cApelCampo
							Elseif (Upper(TcGetDb())) == "DB2"
								cCampos += ", cast(substr("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+",1,4000) as VARCHAR(4000)) MEM_"+ cApelCampo
								cCampos += ", nvl(length("+AllTrim(aCamposSel[nX][7])+"."+AllTrim(aCamposSel[nX][3])+"),0) SZ_"+ cApelCampo
							Endif
						EndIf
					EndIf
				Else
					aEspec[nTemp][13] := cApelCampo
				Endif
			EndIf
		EndIf
	Next
Return cCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} J108SQLFor(aCamposSel, lHasNT2)
Monta os campos de formula para o Select

@param aCamposSel	Array de campos selecionados para exportação
			   		[1] - Título do campo
				    [2] - Título da Tabela
				    [3] - Campo
				    [4] - Tabela 1º Nível
				    [5] - Tabela 2º Nível
				    [6] - Apelido 1º Nível
				    [7] - Apelido 2º Nível
				    [8] - Ordem do campo no dicionário //se mudar esta posição, verificar rotinas de ordenação no código
				    [9] - Tipo do Campo
				    [10] - Filtro
				    [11] - Campo de tela (para substituir no select)

				    [12] - Nome do campo utilizado no SELECT
					[14] - Lista de opções do campo

@param lHasNT2 - Verificador se nos campos há os campos da NT2

@return cCampos	Campos concatenados

@author Willian Kazahaya
@since 03/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108SQLFor(aCamposSel, lHasNT2)
Local cSelect     := ''
Local nF, nC      := 0
Local cCampForm   := ''
Local aCampForm   := {}

Default lHasNT2 := .F.

	For nC:= 1 to Len(aCamposSel)//Adiciona na query da exportação, os campos utilizados como paramentros nas formulas
		If(Len (aCamposSel[nC]) < 6) //Verifica se é uma formula
			cCampForm := aCamposSel[nC][3]
			aCampForm := STRTOKARR(cCampForm, ",") //Cria o array com os paramentros da formula

			// Inclui a formula no Select
			For nF:= 1 to Len(aCampForm)
				If (Substr(aCampForm[nF],4,1) == "_") .AND. ((Substr(aCampForm[nF],1,3))->(FieldPos(aCampForm[nF]) > 0)) .AND.;
					!('CAJURI' $ aCampForm[nF]) .AND. !('FILIAL' $ aCampForm[nF])
					If !((aScan( aCamposSel, { |x| x[3] == Alltrim(aCampForm[nF]) } ) ) > 0)
						cSelect += "," + Substr(aCampForm[nF],1,3)+"."+aCampForm[nF]
					EndIf
				EndIf
			Next nF
		EndIf
	Next nC

	If lHasNT2
		cSelect += ",NT2_COD"
	EndIf

Return cSelect

//-------------------------------------------------------------------
/*/{Protheus.doc} J108SQLFrm(aCamposSel,aFiltro ,aEspec, lFila, lAgrup)
Monta a clausula From da Exp.Personalizada

@param aCamposSel	Array de campos selecionados para exportação
			   		[1] - Título do campo
				    [2] - Título da Tabela
				    [3] - Campo
				    [4] - Tabela 1º Nível
				    [5] - Tabela 2º Nível
				    [6] - Apelido 1º Nível
				    [7] - Apelido 2º Nível
				    [8] - Ordem do campo no dicionário //se mudar esta posição, verificar rotinas de ordenação no código
				    [9] - Tipo do Campo
				    [10] - Filtro
				    [11] - Campo de tela (para substituir no select)

				    [12] - Nome do campo utilizado no SELECT
				    [13] - Alias do campo no Select
					[14] - Lista de opções do campo
					[15] - Somente para a Tabela Agrupadora. 1 - Ultimo Registro | 2 - Primeiro Registro

@param aFiltro   - Filtros adicionais
@param aEspec    - Campos que serão agrupados no From. Gerará o Sub-select no From
@param lFila     - Indica se a chamada tem a Fila de impressão para relacionar a NQ3 no From

@return cCampos	Campos concatenados

@author Willian Kazahaya
@since 03/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108SQLFrm(aCamposSel,aFiltro ,aEspec, lFila, lAgrup, cThread)
Local cSqlFrm   := ''
Local cApProc   := JurGetDados('NQ0', 2 , xFilial('NQ0') + 'NSZ' , 'NQ0_APELID')
Local nPosAp    := 0
Local nPosTab   := 0
Local nI        := 0
Local nY        := 0
Local nJ        := 0
Local nTit      := 0
Local nAgrupa   := 0
Local aExtra    := {}
Local aTabelas  := {}
Local lInsere   := .F.
Local lResp     := .F.
Local cJoin     := ''
Local nIndTabPai:= aScan(aFiltro, {|x| x[2] = 'AND 1 = 1'})
Local aJoins    := {}
Local nContJoin := 1
Local nMaxWhile := 0
Local lCont     := .T.
Local aAuxPar   := {} //--Array auxiliar para passagem de parametros

Default lAgrup := .F.

	// Caso a tabela seja a tabela da tela (Por exemplo, NTA é a tabela da JURA106)
	// irá incluir o inner join para filtrar os assuntos juridicos
	If nIndTabPai > 0 .AND. Len(aCamposSel[1]) > 5 .AND. Substring(aFiltro[nIndTabPai][1],1,3) == Substring(aCamposSel[1][7] ,1,3)
		cJoin := 'INNER'
	Else
		cJoin := 'LEFT'
	EndIf

	cSqlFrm := "  FROM "+ RetSqlname('NSZ') +" "+AllTrim(cApProc)

	aTabelas := JA108TabF()

	//monta a query com as tabelas relacionadas a processo
	For nY := 1 to Len(aCamposSel)
		If(Len (aCamposSel[nY]) > 5) //Verifica se é uma formula
			If ( nPos := aScan( aTabelas, { |x| x[1] == aCamposSel[nY][4] } ) ) > 0
				nPosAp   := 6    //Apelido 1º nível
				nPosTab  := 4    //Tabela 1º nível
			ElseIf ( nPos := aScan( aTabelas, { |x| x[1] == aCamposSel[nY][5] } ) ) > 0
				nPosAp   := 7    //Apelido 2º nível
				nPosTab  := 5    //Tabela 2º nível
			EndIf

			If nPosAp > 0 .And. nPosTab > 0

				// Caso a tabela seja a tabela da tela (Por exemplo, NTA é a tabela da JURA106)
				// irá incluir o inner join para filtrar os assuntos juridicos
				If nIndTabPai > 0 .AND. Substring(aFiltro[nIndTabPai][1],1,3) == Substring(aCamposSel[nY][7] ,1,3)
					cJoin := 'INNER'
				Else
					cJoin := 'LEFT'
				EndIf

				lInsere    := At( ' JOIN '+RetSqlname(aCamposSel[nY][nPosTab])+' '+aCamposSel[nY][nPosAp], cSqlFrm ) == 0

				aAuxPar := aClone(aCamposSel[nY])

				// Cria os relacionamentos da tabelas que são filhas da NSZ
				JA108Cond(aAuxPar, 'NSZ'    , AllTrim(cApProc) ,;
				          /*lExecuta*/  , lInsere  , cSqlFrm          ,;
				          cJoin         , @aJoins  , lAgrup             )

				aSize(aAuxPar, 0)

			EndIf
		EndIf

		If Empty(aExtra) .And. (len(aCamposSel[nY])==15 .And. !Empty(aCamposSel[nY][15]) .And. lAgrup)
			aAdd( aExtra,aClone(aCamposSel[nY]) )
		Endif
	Next

	//monta o restante dos relacionamentos
	For nJ:= 1 to Len(aCamposSel)
		If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
			// Caso a tabela seja a tabela da tela (Por exemplo, NTA é a tabela da JURA106)
			// irá incluir o inner join para filtrar os assuntos juridicos
			If nIndTabPai > 0 .AND. Substring(aFiltro[nIndTabPai][1],1,3) == Substring(aCamposSel[nJ][7] ,1,3)
				cJoin := 'INNER'
			Else
				cJoin := 'LEFT'
			EndIf

			lExecuta:= aCamposSel[nJ][4] <> aCamposSel[nJ][5]
			lInsere	:= At( ' JOIN '+RetSqlname(aCamposSel[nJ][5])+' '+aCamposSel[nJ][7], cSqlFrm ) == 0

			aAuxPar := aClone(aCamposSel[nJ])

			// Cria os relacionamentos das tabelas que não relacionam com a NSZ
			JA108Cond(aAuxPar, aCamposSel[nJ][4], aCamposSel[nJ][6] ,;
			          lExecuta      , lInsere          , cSqlFrm           ,;
			          cJoin         , @aJoins          , lAgrup             )

			aSize(aAuxPar, 0)
		EndIf
	Next

	// Chamada para incluir o relacionamento da Tabela Agrupadora
	// Para relacionar a Tabela Agrupadora à NSZ
	If lAgrup
		aAuxPar := aClone(aCamposSel[1])

		JA108Cond(aAuxPar, 'ESPEC' , 'NSZ001' ,;
		          lExecuta      , lInsere , cSqlFrm  ,;
		          cJoin         , @aJoins , lAgrup    )
		aSize(aAuxPar, 0)
	EndIf

	aSort(aJoins, , , {|x,y| x[6] < y[6] })

	// Monta os relacionamentos verificando se a tabela já está no From.
	// Caso não esteja, passa para o próximo e vai rodando até encontrar
	// Essa regra obriga que a configuração tenha pelo menos 1 campo que intermedie o
	// relacionamento entre as tabelas. Por exemplo, se o usuário deseja ver o Nome do
	// Envolvido da Garantia, ele precisa ter pelo menos 1 campo da Garantia, para
	// Relacionar o Envolvido da Garantia à NSZ
	While aScan(aJoins, {|x| x[6] != 0}) > 0
		If nContJoin > Len(aJoins)
			nContJoin := 1
			nMaxWhile += 1
		EndIf

		// Para evitar o Loop "infinito", caso haja a tentativa 100 vezes
		// Significa que está faltando alguma tabela para validação.
		If nMaxWhile = 100
			Exit
		EndIf

		// Os Joins com a posição 6 igual a Zero já foram inseridos no From
		// Ou não deveriam ser inseridos (Essa regra se aplica a campos da NSZ)
		If aJoins[nContJoin][6] != 0
			// Verifica se o Pai está no From e se o Filho não está
			If (aJoins[nContJoin][2] $ cSqlFrm) .And. !(aJoins[nContJoin][4] $ cSqlFrm)
				cSqlFrm += aJoins[nContJoin][5]

				// Transforma o Sort em Zero para não inserir novamente
				aJoins[nContJoin][6] := 0
			EndIf
		EndIf

		nContJoin += 1
	End

	// Caso não consiga relacionar todos os campos, irá gerar uma mensagem para revisar a configuração
	If nMaxWhile >= 100
		JurMsgErro(STR0079)
		lCont := .F.
		// "A configuração não relaciona todas as tabelas" "Exportação Personalizada" "Revisar os campos selecionados. É necessário ter pelo menos um campo relacionando as tabelas"
	EndIf

	//
	If lCont
		// Inclui o relacionamento com a NTA caso não tenha Campos da NTA para fazer o relacionamento
		If lResp .And. aScan(aCamposSel, { |x| x[4] == "NTA" .or. x[5] == "NTA"}) == 0
			cSqlFrm += " LEFT JOIN "+RetSqlname('NTA')+" "+RetSqlname('NTA')+" "
			cSqlFrm += " ON "+RetSqlname('NTA')+".NTA_FILIAL = '"+xFilial("NTA")+"' "
			cSqlFrm += " AND "+RetSqlname('NTA')+".D_E_L_E_T_ = ' ' "
			cSqlFrm += " AND "+AllTrim(cApProc)+".NSZ_COD = "+RetSqlname('NTA')+".NTA_CAJURI "

			If nAgrupa == 0
				nAgrupa := 1
			EndIf
		EndIf

		nTit := 0

		// Inclusão do Join com a NQ3
		If lFila
			cSqlFrm += J108FrmFil(cApProc, cThread)
		EndIf

		For nI:= 1 to Len(aCamposSel)//Adiciona na query da exportação, os campos utilizados como paramentros nas formulas
			If (Len (aCamposSel[nI]) < 6) //Verifica se é uma formula
				cCampForm := aCamposSel[nI][3]
				aCampForm := STRTOKARR(cCampForm, ",") //Array com os paramentros da formula

				For nY:= 1 to Len(aCampForm)
					If (Substr(aCampForm[nY],4,1) == "_") .AND. ((Substr(aCampForm[nY],1,3))->(FieldPos(aCampForm[nY]) > 0)) .AND. ;
						!('CAJURI' $ aCampForm[nY]) .AND. !('FILIAL' $ aCampForm[nY])
						
						If !((aScan( aCamposSel, { |x| x[3] == Alltrim(aCampForm[nY]) } ) ) > 0)
							If !("," + RetSqlname(Substr(aCampForm[nY],1,3)) $ cSqlFrm)
								cSqlFrm += "," + RetSqlname(Substr(aCampForm[nY],1,3)) + " " + SubStr(aCampForm[nY],1,3)
							EndIf
						EndIF
					EndIf
				Next nY
			EndIf
		Next nI

		//Trata filtros extras
		If Len(aExtra) > 0
			cSqlFrm += J108FltExt(aExtra,aFiltro,AllTrim(cApProc))
		EndIf
	EndIf

	// Caso deu erro na
	If !lCont
		cSqlFrm := ""
	EndIf
Return cSqlFrm

//-------------------------------------------------------------------
/*/{Protheus.doc} J108FrmFil(cApProc, cThread)
Cria a clausula Where

@param cApProc - Alias da NSZ

@return cJoin - Join da Fila (NQ3)

@author Willian Kazahaya
@since 04/04/2018
@version 1.0
/*/
//------------------------------------------------------------------	
Function J108FrmFil(cApProc, cThread)
Local cJoin := ''

Default cThread := SubStr(AllTrim(Str(ThreadId())),1,4)

	cJoin += " INNER JOIN "+RetSqlname('NQ3')+" "+RetSqlname('NQ3')+ " "
	cJoin += "         ON "+RetSqlname('NQ3')+".NQ3_FILIAL = '"+xFilial("NQ3")+"' "
	cJoin += "        AND "+RetSqlname('NQ3')+".D_E_L_E_T_ = ' ' "
	cJoin += "        AND "+RetSqlname('NQ3')+".NQ3_FILORI = "+AllTrim(cApProc)+".NSZ_FILIAL "
	cJoin += "        AND "+RetSqlname('NQ3')+".NQ3_CAJURI = "+AllTrim(cApProc)+".NSZ_COD "
	cJoin += "        AND "+RetSqlname('NQ3')+".NQ3_CUSER  = '"+__CUSERID+"' "
	cJoin += "        AND "+RetSqlname('NQ3')+".NQ3_SECAO  = '"+cThread+"'"
Return cJoin

//-------------------------------------------------------------------
/*/{Protheus.doc} J108SQLWhr(lFila, aExtra, aFiltro, cFrom, aTabsApl )
Cria a clausula Where

@param aExtra
@param aFiltro
@param lFila
@Param lFiltFili Verifica se ultiliza xfilial
@Param cEntFilial Entidade para relacionar Filial.

@return cWhere	 - Clausula Where montada

@author Willian Kazahaya
@since 04/04/2018
@version 1.0
/*/
//------------------------------------------------------------------
Function J108SQLWhr(lFila, aExtra, aFiltro, cFrom, aTabsApl, lFiltFili, cEntFilial)
Local cWhere     := ''
Local cApProc	 := AllTrim(JurGetDados('NQ0', 2 , xFilial('NQ0') + 'NSZ' , 'NQ0_APELID'))
Local aSQLRest 	 := {}

Default aExtra     := {}
Default aFiltro    := {}
Default cFrom      := ''
Default aTabsApl   := {}
Default lFiltFili  := .T.
Default cEntFilial := ""

	cWhere += " WHERE " + cApProc + ".D_E_L_E_T_ = ' ' "
	
	If !lFila .And. lFiltFili
		cWhere += " AND " + cApProc + ".NSZ_FILIAL = '" + xFilial("NSZ") + "' "
	Endif

	If Len(aExtra) > 0	//Possui campos para Filtro
		cWhere += ' AND (' + aExtra[1][6] +'.R_E_C_N_O_ = A.R_E_C_N_O_ OR '+ aExtra[1][6] + ".R_E_C_N_O_ IS NULL)"
	EndIf

	If !lFila //Exportação que não tem fila de impressão (Fup, Andamento, Garantia e Despesa)
		cWhere += CRLF + VerRestricao(cApProc)
		cWhere += getCondicao(aFiltro,cApProc, cFrom, aTabsApl, cEntFilial)

		//Restrição de Cliente/Correspondente
		aSQLRest := Ja162RstUs()

		If len(aSQLRest) > 0
			cWhere += " AND (" + Ja162SQLRt(aSQLRest, , , , , , , , , ) + ")"	//(aRestricao, cCliente, cLoja, cCorresp, cLojaCor, cpCorresp, cpLojaCor, cFwCdCorre, cFwLjCorre, cTpAJ, cCodPart, cPesq, cTabela)
		Endif
	Endif

aSize(aSQLRest,0)

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Cond
Atualiza a query com as condições
Uso Geral.

@param aCamposSel Array de Campos
@param cTabela	    Tabela a verificar o relacionamento na SX9
@param cApelido	Apelido de 1º nível
@param lExecuta	Indica se o bloco de relacionamento deve ser feito ou não
@param lInsere	    Indica se o bloco de relacionamento já foi inserido ou não
@param cSQL	    Query atualizada para verificar as condições a serem inseridas
@param cJoin     	Tipo de Join a ser feito com as outras tabelas (Left/Inner)
@param aJoins     	Array com todos os Joins a serem realizados na Query
		[1] - Alias da tabela Pai
		[2] - Apelido da tabela Pai
		[3] - Alias da tabela Filho
		[4] - Apelido da tabela Filho
		[5] - Regra do Join
		[6] - Código que valida se há Join a ser implementado.
		       0: Não irá incluir Join ao From
		       1: Irá incluir Join ao From. Tabela é filha da NSZ
		       2: Irá incluir Join ao From. Tabela não é filha da NSZ
		[7] - Caso tenha filtro, inclui o apelido das tabelas envolvidas.

@param lAgrup    	Verifica se a chamada é de agrupamento

@return aJoins	    Array com Joins

@author Juliana Iwayama Velho
@since 28/12/09
@version 1.0

@author Willian Kazahaya
@since 17/10/2018
@version 2.0
/*/
//------------------------------------------------------------------
Static Function JA108Cond(aCamposSel, cTabela , cApelido ,;
                          lExecuta  , lInsere , cSQL     ,;
                          cJoin     , aJoins  , lAgrup	  )
Local cQuery    := ''
Local aRelac    := {}
Local aRelac1   := {}
Local aRelac2   := {}
Local nK
Local nIndice   := 0
Local cFilp     := ''
Local nJoinIns  := 0
Local lCmpAgrup := .F.
Local nSort     := 0
Local cTabPos   := ""
Local cTabApel  := ""
Local aFiltro   := {}
Local cAliRel   := ""
Local cQryRel   := ""

Default lExecuta  := .T.
Default cJoin     := 'LEFT'
Default lAgrup    := .F.

	// Verifica se é agrupadora
	lCmpAgrup := Len(aCamposSel) > 14

	If Empty(cJoin)
		cJoin := 'LEFT'
	EndIf

	cTabPos  := aCamposSel[5] // Tabela posicionada
	cTabApel := aCamposSel[7] // Apelido da tabela

	// Se a tabela for Pai e Filha, ela é filha da NSZ
	// Logo, para montar o relacionamento, alteramos o CampoSel
	// Para que o pai seja a NSZ. As alterações de posições NÃO podem
	// ser devolvidas para a função principal.
	If aCamposSel[4] == aCamposSel[5] .And. aCamposSel[6] == aCamposSel[7]
		If !aCamposSel[4] == 'NSZ'
			cAliRel := GetNextAlias()

			cQryRel := JA108SQL(.T., aCamposSel[5], aCamposSel[7], 2)
			cQryRel := ChangeQuery(cQryRel)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRel),cAliRel,.T.,.T.)

			aCamposSel[4]:= (cAliRel)->(TABMASTER)
			aCamposSel[6]:= (cAliRel)->(NQ0_APELID)

			cTabela      := aCamposSel[4]
			cApelido     := aCamposSel[6]

			(cAliRel)->(dbCloseArea())
		EndIf
	ElseIf cTabela == 'ESPEC' .And. lAgrup
		// Verifica se é a ultima chamada para que faça o vinculo da tabela que irá agrupar dados com a NSZ
		// Irá movimentar os dados do campo principal com os dados da tabela Filha
		// Incluindo os da NSZ no inicio
		aCamposSel[5] := aCamposSel[4]
		aCamposSel[7] := aCamposSel[6]
		aCamposSel[4] := 'NSZ'
		aCamposSel[6] := 'NSZ001'
		cTabela       := 'NSZ'
		cApelido      := aCamposSel[6]
		cTabPos       := aCamposSel[5]
		cTabApel      := aCamposSel[7]
	EndIf


	//verifica os relacionamentos na SX9
	If ( cTabPos =='NTE' .AND. (cTabela == 'NSZ' .OR. cTabela == 'NTA')) .OR. (cTabela != aCamposSel[4] .And. cTabela == 'NSZ') // No caso da NTE é realizado o relacionamento em uma função pronta para ela
		aRelac := {}
	ElseIf (cTabela == 'NSZ' .And. (aCamposSel[12] .OR. aCamposSel[4] == 'NSZ' )) // Verificação se é filho da NSZ
		aRelac := JURSX9(cTabPos, cTabela)
	ElseIf (aCamposSel[4] != aCamposSel[5] .And. cTabela != 'NSZ') // Demais relacionamentos. Tabelas que não são filhas da NSZ
		aRelac := JURSX9(cTabPos, cTabela)
	EndIf


	If cTabela == aCamposSel[4] .And. cTabela == aCamposSel[5] 	// Verifica se é Pai/Filho.
		nSort := 0                                             	// Essa situação remove os campos da NSZ do Loop de Joins
	ElseIf cTabela == 'NSZ'
		nSort := 1
	Else
		nSort := 2
	EndIf

	// Verifica se o cara existe no Array de Join
	nJoinIns := aScan(aJoins, {|x| x[1] == aCamposSel[4] .And. x[2] == aCamposSel[6] .And. x[3] == aCamposSel[5] .And. x[4] == aCamposSel[7]})
	If nJoinIns == 0
		aAdd(aJoins, {aCamposSel[4],aCamposSel[6],aCamposSel[5],aCamposSel[7],'', nSort, {}} )
		nJoinIns = Len(aJoins)
	EndIf

	// Verifica se é a primeira inserção. Se for, montará todo o relacionamento
	// com o Join
	If !Empty (aRelac) .And. Empty(aJoins[nJoinIns][5])

		aRelac1 := StrToArray(aRelac[1][1],'+')
		aRelac2 := StrToArray(aRelac[1][2],'+')
		nIndice := aRelac[1][3]

		// monta as condições
		// Tabela - Apelido
		// Apelido - Filial
		// Apelido - Delete
		If lExecuta .And. lInsere

			//Em caso de agrupamento, fazer inner join
			//Quando nao for chamado da tela de pesquisa de processo e for uma das tabela principais
			cQuery += " " + cJoin + " JOIN "+RetSqlname(cTabPos)+" "+AllTrim(cTabApel)+" "

			cQuery += " ON " + JQryFilial(cTabela, cTabPos, cApelido, cTabApel)   //-- cTabPai, cTabFilha, cApPai, cApFilha

			cQuery += "  AND "+AllTrim(cTabApel)+".D_E_L_E_T_ = ' ' "

			// Verificação do Polo Ativo
			If PrefixoCpo(cTabPos) == 'NT9' .And. aCamposSel[6] == 'NT9001'
				cFilP := "AND "+AllTrim(cTabApel)+".NT9_TIPOEN = '1' AND "+AllTrim(cTabApel)+".NT9_PRINCI = '1'"
				If At( cFilP, cSql ) == 0
					cQuery += cFilp
				EndIf
			Endif

			// Validação do Polo Passivo
			If PrefixoCpo(cTabPos) == 'NT9' .And. aCamposSel[6] == 'NT9002'
				cFilP := "AND "+AllTrim(cTabApel)+".NT9_TIPOEN = '2' AND "+AllTrim(cTabApel)+".NT9_PRINCI = '1'"
				If At( cFilP, cSql ) == 0
					cQuery += cFilP
				EndIf
			Endif

		EndIf

		//Verifica se há filtro a ser inserido e se o mesmo já existe
		If !Empty(aCamposSel[10])
			cQuery  += " AND "+AllTrim(aCamposSel[10])
			aJoins[nJoinIns][7] := DesmembFil(aCamposSel[10], aJoins[nJoinIns][7])
		EndIf

		If Len(aRelac) == 1 .And. !Empty ( aRelac1 ) .And. !Empty ( aRelac2 )
		   //Verifica se há relacionamento da SX9 a ser inserido e se o mesmo já existe. Aqui é gerado o relacionamento padrão das tabelas.
			For nK := 1 to Len(aRelac1)

				If nIndice == 1
					If At( 'AND '+AllTrim(cTabApel)+"."+aRelac1[nK]+" = "+cApelido+"."+aRelac2[nK], cQuery ) == 0
						cQuery += "  AND "+AllTrim(cTabApel)+"."+aRelac1[nK]+" = "+cApelido+"."+aRelac2[nK]
					EndIf

				Else
					If At( 'AND '+cApelido+"."+aRelac1[nK]+" = "+AllTrim(cTabApel)+"."+aRelac2[nK], cQuery ) == 0
						cQuery += "  AND "+cApelido+"."+aRelac1[nK]+" = "+AllTrim(cTabApel)+"."+aRelac2[nK]
					EndIf
				EndIf
			Next nK
		EndIf

		// Verifica se a Query não estiver preenchida
		If !Empty(cQuery)
			aJoins[nJoinIns][5] := cQuery

			If aJoins[nJoinIns][6] > 0
				aJoins[nJoinIns][6] := nSort
			EndIf

			// Se for um campo que depende de uma tabela Agrupadora
			// E não for chamada da J108GEXTR, inclui o 1 = 2 para não
			// gerar cartesiano por conta do relacionamento
			If lCmpAgrup .and. !lAgrup
				aJoins[nJoinIns][5] += ' AND 1 = 2 '
			EndIf
		EndIf
	// Se houve condições a mais e a posição 5 já tiver um Join implementado
	// Irá acrescentar o Join do campo.
	ElseIf !Empty(aCamposSel[10]) .And. ('JOIN' $ aJoins[nJoinIns][5]) .And.;
			At(Trim(aCamposSel[10]), aJoins[nJoinIns][5]) == 0

		aJoins[nJoinIns][5] += " AND " + aCamposSel[10]
		aFiltro := DesmembFil(aCamposSel[10], aJoins[nJoinIns][7])

		aJoins[nJoinIns][7] := aFiltro

		If aJoins[nJoinIns][6] > 0
			aJoins[nJoinIns][6] := nSort
		EndIf

		// Se for um campo que depende de uma tabela Agrupadora
		// E não for chamada da J108GEXTR, inclui o 1 = 2 para não
		// gerar cartesiano por conta do relacionamento
		If lCmpAgrup .And. At(Trim(' 1 = 2 '), aJoins[nJoinIns][5]) == 0 .And. !lAgrup
			aJoins[nJoinIns][5] += ' AND 1 = 2 '
		EndIf
	EndIf

	aSize(aRelac,0)
	aSize(aRelac1,0)
	aSize(aRelac2,0)

Return aJoins


//-------------------------------------------------------------------
/*/{Protheus.doc} JA108TabF
Verifica as tabelas que são de 1º nível e possuem também 2º nível de campos
Uso Geral.

@param nAgrupa   Indica o filtro de agrupamento
				 1 - Tabela com agrupamento de campos
 				 2 - Tabela sem agrupamento de campos
				 3 - Todas

@return aTabelas   Array de Tabelas

@author Juliana Iwayama Velho
@since 28/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108TabF(nAgrupa)
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local aArea     := GetArea()
Local aTabelas  := {}

Default nAgrupa := 0

cQuery += "SELECT NQ0_TABELA TABELA, NQ0_APELID APELIDO "
cQuery +=  " FROM "+RetSqlName("NQ0")+" NQ0 "
cQuery += " WHERE NQ0_FILIAL     = '"+xFilial("NQ0")+"' "
cQuery +=   " AND NQ0.D_E_L_E_T_ = ' ' AND NQ0_TABELA IN "
cQuery +=       " (SELECT NQ2_TABELA FROM "+RetSqlName("NQ2")+" NQ2 "
cQuery +=        " WHERE NQ2_FILIAL     = '"+xFilial("NQ2")+"' AND NQ2.D_E_L_E_T_ = ' ' ) "

If nAgrupa == 0
	cQuery += " AND NQ0_AGRUPA = '1' or NQ0_AGRUPA = '2' "
ElseIf nAgrupa < 3
	cQuery += " AND NQ0_AGRUPA = '"+AllTrim(Str(nAgrupa))+"'"
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )

	If (cAlias)->TABELA <> 'NTE'
		aAdd(aTabelas,{(cAlias)->TABELA, (cAlias)->APELIDO})
	EndIf
	(cAlias)->( dbSkip() )

End

(cAlias)->( dbcloseArea() )

RestArea(aArea)

Return aTabelas

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108GREXP
Gera o arquivo em excel da exportação personalizada
Uso Geral.

@param oLista       Lista de registros que serão exportados
@param aCamposSel	Array de campos selecionados para exportação
@param cConfig		Configuração
@param cAnomes		Campo texto que indica o ano-mes que será considerado na atualização de valores
@param aFiltro		Array com os campos da tela que tiveram filtros realizados
@param lFila        Indica se vem da fila de impressão
@param aEspec       Array de campos filtro especial

@author Juliana Iwayama Velho
@since 17/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108GREXP(oLista,aCamposSel,cConfig, cAnoMes, aFiltro, lFila, aEspec)
Local aCamposV   := {}
Local aTabAgrupa := {}
Local aAgrupam   := {}
Local aFormulas  := {}
Local aOrdena    := {}
Local lContinua  := .T.
Local lGar1      := .F.
Local lSoma      := .F.
Local nAgrupa    := 0
Local nSGaran    := 0 //Envolve garantia
Local nCont      := 0 //Contador de campos tipo numérico
Local nJ         := 0
Local nI         := 0

Default cAnoMes := ""

aTabAgrupa := JA108TabF(1)

//Esse mesmo trecho abaixo tambem existe na funcao JA108NVCFG, os 2 pontos devem ter as mesmas condicoes
For nI:= 1 to Len(aTabAgrupa)
	For nJ:= 1 to Len(aCamposSel)
		If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
			If ( aScan( aTabAgrupa, { |x| x[2] == aCamposSel[nJ][7] } ) ) > 0
				If ( aScan( aAgrupam, { |y| y == aCamposSel[nJ][7] } ) ) == 0 .And. aScan(aEspec,{|x| x[5] = aCamposSel[nJ][5] .And. x[7] = aCamposSel[nJ][7]}) == 0
					aAdd(aAgrupam,aCamposSel[nJ][7])
					nAgrupa := nAgrupa + 1
					Exit
				EndIf
			EndIf
		EndIf
	Next
Next

For nJ:= 1 to Len(aCamposSel)
	If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
		If aCamposSel[nJ][9] == 'N'
			If ( aScan( aCamposV, { |y| y == aCamposSel[nJ][3] } ) ) == 0
				aAdd(aCamposV,aCamposSel[nJ][3])
			EndIf
			nCont := nCont + 1
		EndIf

		If (aCamposSel[nJ][4] == 'NT2' .OR. aCamposSel[nJ][5] == 'NT2')
			nSGaran := nSGaran + 1
		EndIf
	EndIf
Next

If !Empty( aCamposSel )

	If !(nAgrupa > 1)

		If nCont > 0
			If ApMsgYesNo(STR0055) //"Deseja incluir a somatória dos valores na exportação?"
				lSoma := .T.
			EndIf
		EndIf

		If (nSGaran > 0)
			If ApMsgYesNo(STR0054) //"Deseja incluir os saldos das garantias na exportação?"
				lGar1 := .T.
			EndIf
		EndIf

		If nSGaran > 0

			For nJ := 1 to Len(aCamposSel)
				If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
					If !(aCamposSel[nJ][12])
						aAdd(aOrdena, aCamposSel[nJ])
					EndIf
				Else
					aAdd(aFormulas, aCamposSel[nJ])
				EndIf
			Next

	 		For nJ := 1 to Len(aCamposSel)
				If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
					If (aCamposSel[nJ][12])
						aAdd(aOrdena, aCamposSel[nJ])
					EndIf
				EndIf
			Next

			If Len(aFormulas) > 0
				For nJ := 1 to Len(aFormulas)
					aAdd(aOrdena, aFormulas[nJ])
				Next
			EndIf

			aCamposSel := aOrdena

		EndIf

		If lContinua
			Processa( { || J108ExpPer(oLista:getQtdReg(),aCamposSel,cConfig, lGar1, lSoma, cAnoMes, aFiltro, lFila, aEspec, nAgrupa) } , STR0013,STR0043, .F. ) //"Aguarde"  //"Exportando..."
		EndIf
	Else
		JurMsgErro(STR0053) //"Não é permitido exportar campos de mais de uma configuração de tabela com agrupamento, verificar!"
	EndIf

Else
	JurMsgErro(STR0031) //"É necessário selecionar algum campo"
EndIf

//limpa arrays
aSize(aCamposV,0)
aSize(aTabAgrupa,0)
aSize(aAgrupam,0)
aSize(aOrdena,0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J108ExpPer
Gera a exportação personalizada
Uso Geral.

@param nNQ3        Quantidade total de registros da fila de impressão
@param aCamposSel  Array de campos selecionados para exportação
@param cConfig     Configuração
@param lGar1       Se tem saldo de garantia ou não
@param lSoma       Se tem somatorio
@param cAnoMes     informa o ano e mes
@param aFiltro     Filtros a serem incrementados
@param lFila       Verifica se a chamada é originaria na Fila de Impressão
@param aEspec      Array de campos filtro especial
@param nAgrupa     Numero de agrupamentos
@param cArq        Local do arquivo a ser gravado
@param lAutomato   Se veio da automação
@Param lFiltFili   Verifica se ultiliza xfilial
@Param cEntFilial  Entidade para relacionar Filial.
@param lCorrige    Se corrige os valores
@param oJsonRel    Objeto json contendo os dados da Gestão de relatórios (O17)
@param cThread     Conteúdo da thread utilizada na gravação da fila de impressão
@param cCmpsOrder Campos a serem utilizados no order by da query
@since 19/01/2021
/*/
//-------------------------------------------------------------------
Function J108ExpPer( nNQ3, aCamposSel, cConfig, lGar1, lSoma, cAnoMes, aFiltro, lFila, aEspec, nAgrupa, cArq, lAutomato, lFiltFili, cEntFilial, lCorrige, oJsonRel, cThread, cCmpsOrder)
    If JVldPrinter()
        // XLSX
        JA108EXLSX(nNQ3,aCamposSel,cConfig, lGar1, lSoma, cAnoMes, aFiltro, lFila, aEspec, nAgrupa, cArq, lAutomato, lFiltFili, cEntFilial, lCorrige, oJsonRel, cThread, cCmpsOrder)
    Else
        JA108EXPOR(nNQ3,aCamposSel,cConfig, lGar1, lSoma, cAnoMes, aFiltro, lFila, aEspec, nAgrupa, cArq, lAutomato, lFiltFili, cEntFilial, lCorrige, oJsonRel, cThread, cCmpsOrder)
    EndIf
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JA108EXPOR
Gera a exportação personalizada
Uso Geral.

@param nNQ3        Quantidade total de registros da fila de impressão
@param aCamposSel  Array de campos selecionados para exportação
@param cConfig     Configuração
@param lGar1       Se tem saldo de garantia ou não
@param lSoma       Se tem somatorio
@param cAnoMes     informa o ano e mes
@param aFiltro     Filtros a serem incrementados
@param lFila       Verifica se a chamada é originaria na Fila de Impressão
@param aEspec      Array de campos filtro especial
@param nAgrupa     numero de agrupamentos
@param cArq        Loca do arquivo a ser gravado
@param lAutomato   Se veio da automação
@Param lFiltFili   Verifica se ultiliza xfilial
@Param cEntFilial  Entidade para relacionar Filial.
@param lCorrige    Se corrige os valores
@param oJsonRel    Objeto json contendo os dados da Gestão de relatórios (O17)
@param cThread     Numero da thread de geração do relatório
@param cCmpsOrder Campos a serem utilizados no order by da query

@author Juliana Iwayama Velho
@since 17/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA108EXPOR(nNQ3,aCamposSel,cConfig, lGar1, lSoma, cAnoMes, aFiltro, lFila, aEspec, nAgrupa, cArq, lAutomato, lFiltFili, cEntFilial, lCorrige, oJsonRel, cThread, cCmpsOrder)
Local nHdl, nJ, nI, nG, nN 
Local cLinha, cCabec
Local nA           := 0
Local cSQL         := ""
Local cAlias       := GetNextAlias()
Local aArea        := GetArea()
Local aSoma        := {}
Local aSomPr       := {} //array com a soma das linhas principais, onde não precisamos quebrar por processo.
Local nSomPt       := 0  //guarda temporariamente a posição dos valores do array
Local aSaldo       := {}
Local nCt          := 2  // inicia com dois devido as linhas de título da planilha
Local nSeq         := 0
Local cExtens      := "Arquivo XLS | *.xls"
Local cCodigo      := ''
Local cClasse      := ''
Local cRec         := "RECNO"
Local cTab         := ''
Local cCampo       := ''
Local cTexto       := ''
Local cTd          := ''
Local nCampos      := 0
Local nSoma        := 0
Local nRecno       := 0
Local nJurosG      := 0
Local nLevanG      := 0
Local nSaldoFG     := 0
Local nValor       := 0
Local nCampovlr    := 0
Local nTJuros      := 0
Local nTLevan      := 0
Local nTSaldoF     := 0
Local cDesConfig   := ""
Local cEnvolvs     := ''
Local lEnvolConc   := .F.
Local cFinal       := ""
Local cVlrCampo    := ''
Local nRet         := 0
LOcal cTitCampo    := ""
Local lEspec       := .F.
Local lPagrup      := .F.
Local lHtml        := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
Local cFunction    := "CpyS2TW"
Local cPathS       := "\spool\" //caminho onde o arquivo será gerado no servidor
Local cNome        := "" //Nome do arquivo que o usuário escolheu
Local cNomeTmp     := "" //Nome temporário do arquivo que será utilizado no server
Local cDirDest     := "" //Diretório do destino, no caso de smartclient local.
Local nArq         := 2
Local lTemNQ3      := .F. //Controla se exite NQ3 - Fila de Impressao
Local cFormula     := ""
Local cParams      := ""
Local aParams      := {}
Local aParamQry    := {}
Local cParamQry    := ''
Local nP           := 0
Local nPos         := 0
Local aAux         := {}
Local nLinhas      := 0
Local aCampNum     := {}
Local lPriLinha    := .T.
Local lAgrupVlr    := .F.
Local lDbSeek      := .T.
Local aGar1        := {}
Local aMemo        := {}
Local nMemo        := 0
Local cCpoMem      := ""  //nome do campo com o conteúdo do memo convertido em caracter
Local cSzMem       := ""  //nome do campo com o tamanho do campo memo para validação de existe informação
Local nAi          := 1
Local nPosSoma     := 1
Local lIncRd0Sig   := .F.
Local nQtdColSpn   := 0  // Quantidade de colunas para o merge do titulo
Local aResp        := {}
Local cApProc      := JurGetDados('NQ0', 2 , xFilial('NQ0') + 'NSZ' , 'NQ0_APELID')
Local cFilOri      := '' //--Filial de Origem da NSZ
Local naTemp       := 1
Local nPosSomaTemp := 1
Local lLinux       := "Linux" $ GetSrvInfo()[2]
Local cCabecCorre  := " "
Local nQtdColTit   := 0
Local lO17         := ValType(oJsonRel) == 'J'
Local lCheckAgru   := .F.
Local aValCmpAgr   := {}
Local nPosValAgr   := 0
Local nPosCmpEsp   := 0
Local nPosEsp      := 0
Local nPosValEsp   := 0
Local nE           := 1
Local lRelOk       := .T.
Local cMsgErroRel  := ""

Default cArq       := ""
Default lAutomato  := .F.
Default lCorrige   := .F.

	cSQL := JA108GSQL(aCamposSel,.F. /*lCamposAg*/,.F. /*lIncrSQL*/, aFiltro, lFila, @aEspec, @nAgrupa, lFiltFili, cEntFilial,cThread, cCmpsOrder )

	// Ajuste para título do relatório padrão do TOTVS Legal
	If !Empty( cConfig )
		cDesConfig := Posicione('NQ5', 1 , xFilial('NQ5') + cConfig , 'NQ5_DESC')//NQ5_FILIAL+NQ5_COD
	Else
		cDesConfig := STR0081 // "TOTVS Jurídico"
	EndIf

	//Valida se o campo de ano-mes foi preenchido e se a query faz referência ao mesmo.
	If !Empty(cAnoMes)
		cSQL := Replace(cSQL,":ANOMES",cAnoMes)
	Endif

	//Escolha o local para salvar o arquivo
	//Se for o html, não precisa escolher o arquivo
	If !lHtml .AND. EMPTY(cArq) .And. !Empty(cSQL)
		cArq := cGetFile(cExtens,STR0020,,'C:\',.F.,nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE),.F.)
	ElseIF lHtml .And. !Empty(cSQL)
		cArq := "\" + STR0075 + "_" + RetCodUsr()
	Endif

	If At(".xls",cArq) == 0
		cArq += ".xls"
	Endif

	// Tratamento para S.O Linux
	If lLinux
		cArq := StrTran(cArq,"\","/")
		cPathS := StrTran(cPathS,"\","/")
	Endif

	If cArq <> ".xls" .And. ExistDir(cPathS) .And. !Empty(cSQL)//valida se o arquivo tem nome e se o diretório existe.

		//Separa o nome do arquivo do caminho completo
		cNome := SubStr(cArq,Rat(IF(!lLinux,"\","/"),cArq)+1)
		//remove a extenção do nome do arquivo
		if At(".xls",cNome)
			cNome := Left(cNome,length(cNome)-4)
		Endif

		//nome do arquivo criado no servidor, temporariamente
		cNomeTmp := JurTimeStamp(1) + "_" + cNome + ".xls"
		cPathS := cPathS + cNomeTmp

		//Separa o diretório de destino da máquina do usuário
		cDirDest := SubStr(cArq,1,Rat(IF(!lLinux,"\","/"),cArq))

		nHdl := FCreate(cPathS)

		If nHdl < 0
			//STR0014 - "O arquivo " 
			//STR0015 - "Erro ao gerar cabeçalho do arquivo" 
			JurMsgErro(STR0014 + cPathS + STR0015)
			lRelOk := .F.
			cMsgErroRel := STR0014 + cPathS + STR0015
		Endif

		If lRelOk

			If lO17
				oJsonRel['O17_DESC']   := STR0083 //"Preparando os dados do relatório"
				J288GestRel(oJsonRel)
			Endif

			cSQL := ChangeQuery(cSQL)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAlias,.T.,.T.)

			If !EMPTY(cSQL)//Guarda o valor dos parametros que serão utilizados nas formulas
				cParamQry := cSQL
				cParamQry := Alltrim(SUBSTR(cParamQry,AT("NSZ_COD", cParamQry)+8,Len(cParamQry)-AT(",",cParamQry)+1))
				cParamQry := Alltrim(SUBSTR(cParamQry,1,AT("FROM",cParamQry)-1))

				aParamQry := STRTOKARR(cParamQry, ",")

			EndIf

			aParamQry := Aclone(aAux)

			nCampovlr := 0
			lTemNQ3   := lFila	//Salva o conteudo da variavel lFila para ser utilizado nas consultas na funcao JA108GSQL

			//Ajusta formato dos campos de data.
			For nN:=1 to Len(aCamposSel)
				If len(aCamposSel[nN]) > 5 .And. aCamposSel[nN][9] == 'D' //Verifica se é uma formula e se o tipo do cmapo é data
					cTitCampo:= aCamposSel[nN][13]
					TcSetField( cAlias, (cAlias)->(cTitCampo), 'D', 8, 0 )
				EndIf
			Next

			//Determnina quais campos são numéricos
			if (lSoma)
				For nN:=1 to Len(aCamposSel)
					//verifica os campos que são valores, para realizar a somatória
					If(Len (aCamposSel[nN]) > 5) //Verifica se é uma formula
						If aCamposSel[nN][9] == 'N'
							aAdd(aCampNum,{AllTrim(aCamposSel[nN][13]),aCamposSel[nN][12]})
							If aCamposSel[nN][12] .and. Len(aCamposSel) < nN
								lAgrupVlr		:= .T.
							EndIf
							//quantidade de campos com valores
							If aCamposSel[nN][3] == 'NT2_VALOR'
								nCampovlr := nCampovlr + 1
							EndIf
						EndIf
					Endif
				Next
			Endif

			lPriLinha := .T.

			//CARREGA RESPONSAVEIS
			If aScan(aCamposSel, {|x| 'NTE_' $ x[3]}) > 0
				aResp := J108QryRsp(lFila, aFiltro, cApProc, aCamposSel)
			EndIf

			//Quantidade de registros a serem exportados
			While !(cAlias)->( Eof() )

				If lSoma
					For nN:=1 to Len(aCampNum)
						//verifica os campos que são valores, para realizar a somatória
						If !aCampNum[nN][2]
							cTitCampo:= aCampNum[nN][1]
							if (cAlias)->(FieldPos(cTitCampo)) > 0 .And. (cAlias)->(FieldGet(FieldPos(cTitCampo))) != 0
								nSomPt := aScan(aSomPr,{|x| x[1] == cTitCampo})
								if nSomPt > 0
									aSomPr[nSomPt][2] += (cAlias)->(FieldGet(FieldPos(cTitCampo)))
								Else
									aAdd(aSomPr,{cTitCampo,(cAlias)->(FieldGet(FieldPos(cTitCampo)))})
								Endif
							Endif
						EndIf
					Next
				Endif

				//Quantidade de registros agrupados a serem exportados

				if len(aSoma)>0
					nPosSomaTemp := len(aSoma)
				Endif

				cFilOri := (cAlias)->NSZ_FILIAL
				cCodigo	:= (cAlias)->NSZ_COD
				If lSoma
					While !(cAlias)->( Eof() ) .AND. cFilOri == (cAlias)->NSZ_FILIAL .and. cCodigo == (cAlias)->NSZ_COD

						nLinhas++

						For nJ:=1 to Len(aCampNum)
							//verifica os campos que são valores, para realizar a somatória
							If aCampNum[nJ][2]
								cTitCampo:= aCampNum[nJ][1]

								//valida se o valor é diferente de 0.
								if (cAlias)->(FieldPos(cTitCampo)) > 0 .And. (cAlias)->(FieldGet(FieldPos(cTitCampo))) != 0

									//Verifica se ja existe o campo de valor para o processo
									If ( nPosSoma := aScan(aSoma, {|x| x[1] == ((cAlias)->NSZ_FILIAL + (cAlias)->NSZ_COD) .And. x[2] == (cAlias)->(cTitCampo)},nPosSomaTemp) ) > 0
										aSoma[nPosSoma][3] := aSoma[nPosSoma][3] + (cAlias)->( FieldGet( FieldPos(cTitCampo) ) )
									Else
										aAdd(aSoma,{ (cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD, (cAlias)->(cTitCampo),(cAlias)->(FieldGet(FieldPos(cTitCampo)))})
									EndIf
								Endif
							EndIf
						Next
						(cAlias)->( dbSkip() )
					End
				Else
					(cAlias)->( dbSkip() )
				Endif
			End

			//Deixa o proprio excel definir a area de impressão, sem passar linhas ou colunas
			cCabec := JA108Formt()

			If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
				JurMsgErro(STR0016)
				lRelOk := .F.
				cMsgErroRel   := STR0016  // "Erro ao gerar cabeçalho do arquivo"
			EndIf

			If lGar1
				nQtdColSpn := 5
			Else
				nQtdColSpn := 2
			EndIf

			If lCorrige
				cCabecCorre += "<td colspan = '"+AllTrim(Str(nQtdColSpn + 1))+"' "
				cCabecCorre += " class=xl38 style='border-right:.5pt solid black'> "
				cCabecCorre += "<a name='Print_Area1'>" + STR0082 + DTOC(Date()) + "</a></td>" // " * Valores atualizados em "
				nQtdColTit := Len(aCamposSel) - 1 
			Else
				nQtdColTit := Len(aCamposSel) + nQtdColSpn
			EndIf

			cTd := "<td colspan = '"+AllTrim(Str(nQtdColTit))+"' "

			//Cabeçalho com campos fixos
			// 4 colunas fixas: Linhas / Linhas de Processo / Seqüência / Código
			cCabec := "<col style='mso-width-source:userset'>"
			cCabec += "<tr height=21 style='height:15.75pt'>"
			cCabec += "<td height=21 style='height:15.75pt'>"+STR0039+"</td>" //linhas
			cCabec += "<td>"+STR0040+"</td>" // "Linhas do Assunto"
			cCabec += cCabecCorre
			cCabec += cTd
			cCabec += "class=xl38 style='border-right:.5pt solid black'>"
			cCabec += "<a name='Print_Area2'>"+AllTrim(cDesConfig)+"</a></td>" //nome da configuração
			cCabec += "</tr> "

			If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
				JurMsgErro(STR0016)
				lRelOk := .F.
				cMsgErroRel   := STR0016  // "Erro ao gerar cabeçalho do arquivo"
			EndIf

			cCabec:= "<tr>"+;
			"<td class=xl26>T</td>"+;
			"<td class=xl26></td>"+;
			"<td class=xl28 x:str='"+STR0041+"'></td>"+; // "Sequência"
			"<td class=xl27>"+STR0042+"</td>" // "Código interno"

			If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
				JurMsgErro(STR0016)
				lRelOk := .F.
				cMsgErroRel   := STR0016  // "Erro ao gerar cabeçalho do arquivo"
			EndIf

			//Títulos das colunas
			For nJ:=1 to Len(aCamposSel)

				// Inclusão da Coluna de Saldo
				cCabec:= " <td class=xl28 x:str='" +AllTrim(aCamposSel[nJ][1]) +"'></td>"

				If !Empty(cCabec) .AND. FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
					If !JurMsgErro(STR0016)
						lRelOk := .F.
						cMsgErroRel   := STR0016  // "Erro ao gerar cabeçalho do arquivo"
						Exit
					EndIf
				EndIf

				If lGar1 //Verifica se foi solicitado inclusão de saldos das garantias na exportação, para criar as novas colunas de valores.

					If (aCamposSel[nJ][3] == 'NT2_VALOR') .Or. ;
						((nCampovlr == 0) .And. (Len(aCamposSel) == nJ) .And. (aScan(aCamposSel,{|x| x[3] == 'NT2_VALOR'}) == 0))

						For nG:=1 to 3
							Do Case
								Case nG==1
									cTexto := STR0057 //'Total de Juros'
								Case nG==2
									cTexto := STR0058 //'Total de Levantamentos'
								Case nG==3
									cTexto := STR0059 //'Saldo Atual'
							EndCase

							cCabec:= " <td class=xl28 x:str='" +cTexto+"'> </td>"

							If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
								JurMsgErro(STR0016)
								lRelOk := .F.
								cMsgErroRel   := STR0016  // "Erro ao gerar cabeçalho do arquivo"
								Exit
							EndIf

						Next

					EndIf
				EndIf

				If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
					//Conta quantos campos não são de agrupamento
					If !aCamposSel[nJ][12]
						nCampos := nCampos + 1
					EndIf
				Else
					nCampos++
				EndIf

			Next

			dbSelectArea(cAlias)

			(cAlias)->(dbGoTop())

			nCt := 1
			nSeq:= 0
			
			// Preenche o registro da rotina de gestão de relatórios do Totvs Legal
			If lO17
				oJsonRel['O17_MAX']   := If(nNQ3>nLinhas,nNQ3,nLinhas)
				J288GestRel(oJsonRel)
			Endif

			ProcRegua( If(nNQ3>nLinhas,nNQ3,nLinhas) )
			cFilOri     := ""
			cCodigo 	:= ""
			lPriLinha 	:= .T.
			IncProc()
			IncProc()

			//Dados da exportação - tabelas sem agrupamento de campos
			While !(cAlias)->( Eof() ) //if lFila

				lEspec := .F.

				If (cFilOri+cCodigo) <> ( (cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD )
					cFilOri   := (cAlias)->NSZ_FILIAL
					cCodigo   := (cAlias)->NSZ_COD
					lPriLinha := .T.
					nSeq 	  := nSeq + 1
					lDbSeek := .T.

					if lGar1 .And. ((cAlias)->(FieldPos('NT2_COD')) > 0) .and. !Empty((cAlias)->NT2_COD) //cria o saldo apenas se houver código na tabela de agrupamento NT2
						aSaldo := JA098CriaS(cCodigo, cFilOri)
					else
						aSaldo := {}
					Endif
				Else
					lPriLinha := .F.
				EndIf

				//Linhas fixas - linhas de processo / sequencia / código interno
				If lPriLinha
					cLinha := "<tr>" +;
					"<td class=xl26>D</td>"
				Else
					cLinha := "<tr>" +;
					"<td class=xl26></td>"
				EndIf

				cLinha += "<td class=xl26>" + AllTrim(Str(nCt)) + "</td>" +;
						"<td class=xl30>" + AllTrim(Str(nSeq)) + "</td>" +;
						"<td class=xl31>" + (cAlias)->NSZ_COD + "</td>"

				If FWrite(nHdl, cLinha, Len(cLinha) ) <> Len(cLinha)
					If !JurMsgErro(STR0017)   // "Erro ao gerar linha do arquivo"
						lRelOk := .F.
						cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
						Exit
					EndIf
				EndIf

				lIncRd0Sig := .F.
				cLinha := ''

				For nI:=1 to Len(aCamposSel)
					cLinha := ''

					If 'NTE_' $ aCamposSel[nI][3] .And. !Empty((cAlias)->NTA_COD) .AND. Len(aCamposSel[nI]) > 5
						cLinha := J108GetNTE(@aResp, (cAlias)->NTA_COD, aCamposSel[nI][3] )

						If lPriLinha .And. lSoma .And. Len(aCamposSel[nI]) > 5 .And. aCamposSel[nI][12]
							cLinha  := "<td class=xl31> - </td>"
						EndIf

						If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
							If !JurMsgErro(STR0017)
								lRelOk := .F.
								cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
								Exit
							EndIf
						EndIf

						cLinha := "" //zera a linha
						Loop //pula para o próximo campo

					EndIf

					If len(aCamposSel[nI]) > 5 .And. aScan(aEspec,{|x| x[13] == aCamposSel[nI][13]}) > 0 //valida se é um campo de filtro especial para já executar, valida pelo posicao 13 porque a 3 pode ser igual se for um campo de descricao

						lEspec := .T.
						If lPriLinha
							If !lCheckAgru
								aValCmpAgr := J108ValCmpAg(aEspec, 1, lTemNQ3, cThread, aFiltro )
								lCheckAgru := .T.
							EndIf
							
							nPosValAgr := aScan(aValCmpAgr, {|x| x[1] == cFilOri .And. x[2] == cCodigo}) // Posição do cajuri da vez no array de cache de agrupamento
							nPosCmpEsp := aScan(aEspec, {|x| x[13] == aCamposSel[nI][13]}) // Posição do campo atual no array de campos especiais
							If nPosValAgr > 0
								nE := 0
								For nPosEsp := 3 To Len(aValCmpAgr[nPosValAgr])
									If AllTrim(aValCmpAgr[nPosValAgr][nPosEsp][4]) == aCamposSel[nI][3]
										nPosValEsp := nPosEsp // Posição do valor do campo especial no item correspondente ao cajuri da vez do array de cache de agrupamento
										Exit
									EndIf
								Next nPosEsp

								// Adiciona os campos de agrupamento no relatório
								If !Empty(nPosValEsp) .And. nPosValEsp > 0
									J108GEXTR(aEspec[nPosCmpEsp], 1, cCodigo, lTemNQ3, nHdl, @aSoma, lSoma, lGar1, @aGar1, cFilOri, cThread, aValCmpAgr[nPosValAgr][nPosValEsp], @lRelOk, @cMsgErroRel)
									aDel(aValCmpAgr[nPosValAgr], nPosValEsp)
									aSize(aValCmpAgr[nPosValAgr],Len(aValCmpAgr[nPosValAgr])-1)
									If Len(aValCmpAgr[nPosValAgr]) < 3
										aDel(aValCmpAgr, nPosValAgr)
										aSize(aValCmpAgr,Len(aValCmpAgr)-1)
									EndIf
								EndIf
							EndIf
							cLinha := ""
							lPagrup := .T.
							Loop
						Else
							if lPriLinha
								Loop //pula para o próximo campo se estiver na primeira linha
							Else	//se não estiver na primeira linha tem que gravar - para dar espaçamento nas células
								cLinha  := "<td class=xl31> - </td>"
								If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
									If !JurMsgErro(STR0017)
										lRelOk := .F.
										cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
										Exit
									EndIf
								EndIf
								cLinha := ""
								Loop //pula para o próximo campo
							Endif
						Endif
					Endif

					//Verifica se é a primeira linha do assunto juridico, vai somar os valores, não é formula e se o campo é de agrupamento
					If lPriLinha .And. lSoma .And. Len(aCamposSel[nI]) > 5 .And. aCamposSel[nI][12]

						//Não passa para o proximo registro, para poder imprimir a primeira linha depois da linha de detalhe
						If lDbSeek
							lDbSeek := .F.
							nRecno := (cAlias)->( Recno() )
						Endif

						//Se não for numérico, escrever o traço e passa para o proximo campo
						If aCamposSel[nI][9] != 'N'

							cLinha  := "<td class=xl31> - </td>"

							If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
								If !JurMsgErro(STR0017)
									lRelOk := .F.
									cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
									Exit
								EndIf
							EndIf

							//pula para o próximo campo
							Loop
						Endif
					EndIf

					cVlrCampo := ""
					cTitCampo := ""

					If(Len (aCamposSel[nI]) > 5) //Verifica se é uma formula

						cTitCampo:= ALLTRIM( aCamposSel[nI][13] )

						If aCamposSel[nI][9] == 'D'
							cClasse  := " <td class=x144>"
						ElseIf aCamposSel[nI][9] == 'N' .And. aScan(aEspec,{|x| x[3] == aCamposSel[nI][3]}) == 0 .And. lPriLinha
							If lSoma
								If aCamposSel[nI][12] //valida se é uma tabela de agrupamento

									//Busca a primeira ocorrencia do campo para o assunto juridico, para processar o array aSoma a partir desta posição
									nAi := aScan(aSoma, {|x| x[1] == ((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD) .And. (cAlias)->(cTitCampo) == x[2]},naTemp )
									If nAi > 0
										For nA:= nAi  to Len(aSoma)
											If ( (cAlias)->(cTitCampo) == aSoma[nA][2] ) .And. ((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD == aSoma[nA][1])
												nSoma := nSoma + aSoma[nA][3]
											Elseif ((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD <> aSoma[nA][1] )
												Exit
											EndIf
										Next nA
										naTemp := nAi
									EndIf
								Else
									nSoma := (cAlias)->(FieldGet(FieldPos(cTitCampo)))
								Endif

								cLinha  := " <td class=xl41 x:num=" + AllTrim(Str(nSoma))+"></td>"

								If nSoma != 0
									nSoma   := 0
								EndIf
							Else
								cClasse := " <td class=xl41 x:num="
							EndIf
						ElseIf aCamposSel[nI][9] == 'N'
							cClasse := " <td class=xl41 x:num="
						Else
							cClasse := " <td class=xl31>"
						EndIf

						If aCamposSel[nI][3] $ CAMPOSNAOCONFIG
							cEnvolvs := JA108ENVOL((cAlias)->NSZ_COD, aCamposSel[nI][3])
							lEnvolConc := .T.
						Else
							cEnvolvs := ''
							lEnvolConc := .F.
						Endif

						//Define o valor do campo
						If aCamposSel[nI][9] == 'M'
							cTab   := AllTrim(aCamposSel[nI][5])
							cCampo := AllTrim(aCamposSel[nI][3])

							nRecno := (cAlias)->(FieldGet(FieldPos(aCamposSel[nI][7]+cRec)))

							//informações memo
							cCpoMem := ("MEM_"+AllTrim(aCamposSel[nI][13]))
							cSzMem := ("SZ_"+AllTrim(aCamposSel[nI][13]))

							If  nRecno > 0 //valida se o existe recno
								if aCamposSel[nI][12] //se for agrupamento, não tem cache
									if (cAlias)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
										//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
										if (cAlias)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cAlias)->(FieldGet(FieldPos(cSzMem))) <= 4000
											cVlrCampo := (cAlias)->(FieldGet(FieldPos(cCpoMem)))
										Elseif (cAlias)->(FieldGet(FieldPos(cSzMem))) == 0
											cVlrCampo := ""
										Else
											&(cTab)->( dbGoTo( nRecno ))
											cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
										Endif
									Else
										&(cTab)->( dbGoTo( nRecno ))
										cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
									Endif
								Elseif aScan(aMemo,{|x| x[1] == cFilOri+cCodigo}) > 0 //valida se filial + código da nsz ja existe
									if (nMemo := aScan(aMemo,{|x| x[2] = aCamposSel[nI][13]+cRec })) == 0	 //valida se o cache do campo ja existe
										//não existe, então busca na tabela
										if (cAlias)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
											//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
											if (cAlias)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cAlias)->(FieldGet(FieldPos(cSzMem))) <= 4000
												cVlrCampo := (cAlias)->(FieldGet(FieldPos(cCpoMem)))
											Elseif (cAlias)->(FieldGet(FieldPos(cSzMem))) == 0
												cVlrCampo := ""
											Else
												&(cTab)->( dbGoTo( nRecno ))
												cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
											Endif
										Else
											&(cTab)->( dbGoTo( nRecno ))
											cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
										Endif
										aAdd(aMemo,{cFilOri+cCodigo,(aCamposSel[nI][13]+cRec),cVlrCampo}) //grava o cache
									Else
										//ja existe, usa o array
										cVlrCampo := aMemo[nMemo][3]
									Endif
								Else
									aSize(aMemo,0)
									if (cAlias)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
										//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
										if (cAlias)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cAlias)->(FieldGet(FieldPos(cSzMem))) <= 4000
											cVlrCampo := (cAlias)->(FieldGet(FieldPos(cCpoMem)))
										Elseif (cAlias)->(FieldGet(FieldPos(cSzMem))) == 0
											cVlrCampo := ""
										Else
											&(cTab)->( dbGoTo( nRecno ))
											cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
										Endif
									Else
										&(cTab)->( dbGoTo( nRecno ))
										cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
									Endif
									aAdd(aMemo,{cFilOri+cCodigo,aCamposSel[nI][13]+cRec,cVlrCampo})
								Endif
							Else
								cVlrCampo := "-"
							EndIf
						Else
							if lEnvolConc
								cVlrCampo := cEnvolvs
							Else
								If (!Empty(aCamposSel[nI][14])) //Valida se existe opções
									cVlrCampo := JCboxValue(AllTrim(aCamposSel[nI][14]),(cAlias)->(FieldGet(FieldPos(cTitCampo)) ))
								Else
									cVlrCampo := cValToChar( (cAlias)->(FieldGet(FieldPos(cTitCampo)) ))
								Endif
							Endif
						EndIf

						//valida se a linha esta vazia para preencher da forma padrão.
						if Empty(cLinha)
							cLinha := cClasse + AllTrim ( cVlrCampo )+ "</td>"
						Endif

						If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
							If !JurMsgErro(STR0017)
								lRelOk := .F.
								cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
								Exit
							EndIf
						EndIf

						cLinha := "" //zera a linha

					Else //Caso seja uma formula

						cParams := AllTrim(aCamposSel[nI][3])

						aParams := STRTOKARR(cParams, ",")

						If Len(aParams) > 0

							For nP:= 1 to Len(aParams)
								aParams[nP] := AllTrim(aParams[nP])

								If (At("CAJURI",aParams[nP]) > 0)
									aParams[nP] := (cAlias)->NSZ_COD
								ElseIf (At("FILIAL",aParams[nP]) > 0)
									aParams[nP] := (cAlias)->NSZ_FILIAL
								ElseIf (Substr(aParams[nP],4,1) == "_") .AND. (SubStr(aParams[nP],1,3))->(FieldPos(aParams[nP])) > 0

									nPos := (aScan( aParamQry, {|aX| aX[1] == Alltrim(aParams[nP]) } ) )
									If nPos > 0
										aParams[nP] := aParamQry[nPos][2]
									EndIf
								EndIf
							Next nP
						EndIf

						Eval(&("{|| cFormula := "+ Alltrim(Strtran(JurLmpCpo(aCamposSel[nI][2]),"#",""))  +"(aParams)}"))
						
						If valType(cFormula) == 'D'
							cClasse  := " <td class=x144>"
							cLinha  := cClasse + cValtoChar(cFormula) + "</td>"
						ElseIf valType(cFormula) == 'N'
							cClasse := " <td class=xl41 x:num=" 
							cLinha  := cClasse + AllTrim(Str(cFormula)) + ">" + "</td>"
						Else
							cClasse := " <td class=xl31>"
							cLinha  := cClasse + AllTrim(cFormula) + "</td>"
						EndIf
							
						If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
							If !JurMsgErro(STR0017)
								lRelOk := .F.
								cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
								Exit
							EndIf
						EndIf

						cLinha := "" //zera a linha
					EndIf
					//Se foi escolhida a opção de mostrar os valores das garantias
					If lGar1

						If (aCamposSel[nI][3] == 'NT2_VALOR') .Or. ;
							((nCampovlr == 0) .And. (Len(aCamposSel) == nI) .And. (aScan(aCamposSel,{|x| x[3] == 'NT2_VALOR'}) == 0))

							For nG := 1 to Len(aSaldo)
								If Len(aSaldo[nG]) >= 7
									If (cAlias)->NSZ_FILIAL == cFilOri .AND. (cAlias)->NSZ_COD == cCodigo;
											.And. IIF(lPriLinha, .T., (cAlias)->NT2_COD == aSaldo[nG][7])	//Validacao para pegar o saldo da garantia posicionada
										If aSaldo[nG][4] == 'J'
											nJurosG := nJurosG + aSaldo[nG][5]
										ElseIf aSaldo[nG][4] == 'A'
											nLevanG 	:= nLevanG + aSaldo[nG][6]
										ElseIf aSaldo[nG][4] == 'SF'
											nSaldoFG	:= nSaldoFG + aSaldo[nG][5]
										EndIf
									EndIf
								EndIf
							Next

							cClasse := " <td class=xl41 x:num="

							cLinha  := cClasse + AllTrim(Str(nJurosG))+"></td>"
							cLinha  += cClasse + AllTrim(Str(nLevanG))+"></td>"
							cLinha  += cClasse + AllTrim(Str(nSaldoFG))+"></td>"

							If aScan(aGar1,{|x| x[1] == cCodigo}) == 0
								aAdd(aGar1,{cCodigo, nJurosG, nLevanG, nSaldoFG})
							EndIf

							nJurosG  	:= 0
							nLevanG  	:= 0
							nSaldoFG 	:= 0

							If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
								If !JurMsgErro(STR0017)
									lRelOk := .F.
									cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
									Exit
								EndIf
							EndIf

							cLinha := "" //zera a linha
						EndIf
					EndIf
				Next nI

				If lFila .Or. (lGar1 .Or. lSoma)
					cLinha := "</tr>"

					If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
						If !JurMsgErro(STR0017)
							lRelOk := .F.
							cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
							Exit
						EndIf
					EndIf
				Endif

				cLinha := ''

				nCt := nCt + 1

				IncProc()

				If lDbSeek .or. !lPriLinha
					(cAlias)->( dbSkip() )
				
					// Preenche o registro da rotina de gestão de relatórios do Totvs Legal
					If lO17
						oJsonRel['O17_DESC'] := STR0084 //"Gravando dados do relatório"
						oJsonRel['O17_MIN']  := oJsonRel['O17_MIN']+1
						oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN']*100/oJsonRel['O17_MAX'],0)
						J288GestRel(oJsonRel)
					Endif
					
					If !(cAlias)->( eof() )
						nRecno := (cAlias)->( Recno() )
					EndIf
				EndIf

			EndDo

			cLinha := "</tr>"

			If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
				JurMsgErro(STR0017)
				lRelOk := .F.
				cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
			EndIf

			If lSoma

				cLinha := "<tr>" +;
				"<td class=xl26>TOT</td>" +;
				"<td class=xl26>" + AllTrim(Str(nCt)) + "</td>" +;
				"<td class=xl28>TOTAL</td>" +;
				"<td class=xl48></td>"

				If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
					JurMsgErro(STR0017)
					lRelOk := .F.
					cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
				EndIf

				For nI:=1 to Len(aCamposSel)

					cTitCampo:= ""
					cLinha	 := "<td class=xl48></td>"

					If(Len (aCamposSel[nI]) > 5) //Verifica se é uma formula

						cTitCampo:= ALLTRIM( aCamposSel[nI][13] )

						//se o campo for númerico, soma os valores e formata o campo
						If aCamposSel[nI][9] == 'N'
							cClasse := 	" <td class=xl48 x:num="
							nSoma   := 0

							if aCamposSel[nI][12] //valida se é uma tabela de agrupamento
								For nA:= 1 to Len(aSoma)
									if nA > Len(aSoma) .Or. aSoma[nA] == Nil
										Exit
									Endif

									If ( (cAlias)->(cTitCampo) == aSoma[nA][2] .Or. ;
										(Len(aSoma[nA]) > 3 .And. aSoma[nA][4] == aCamposSel[nI][3])) //Para campos especiais preenchidos na J108GEXLS()
										nSoma := nSoma + aSoma[nA][3]
										aDel(aSoma,nA)
										aSize(aSoma,Len(aSoma)-1)
										nA--
									EndIf
								Next
							Else
								//se não for agrupamento, usa o total calculado para linhas principais de processos.
								nSomPt := aScan(aSomPr,{|x| x[1] == cTitCampo})
								if (nSomPt > 0)
									nSoma := aSomPr[nSomPt][2]
								Endif
							Endif

							cLinha  := cClasse + AllTrim(Str(nSoma))+"></td>"
						Else
							cLinha  := "<td class=xl48></td>"
						EndIf
					EndIf

					If lGar1
						If aCamposSel[nI][3] == 'NT2_VALOR' .OR. (nCampovlr == 0 .AND. Len(aCamposSel) == nI)
							For nG := 1 to Len(aGar1)
								nTJuros 	+= aGar1[nG][2]
								nTLevan 	+= aGar1[nG][3]
								nTSaldoF 	+= aGar1[nG][4]
							Next

							For nG := 1 to 3
								Do Case
									Case nG==1
										nValor := nTJuros
									Case nG==2
										nValor := nTLevan
									Case nG==3
										nValor := nTSaldoF
								EndCase

								If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
									If !JurMsgErro(STR0017)
										lRelOk := .F.
										cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
										Exit
									EndIf
								EndIf

									cLinha  := cClasse + AllTrim(Str(nValor))+"></td>"
							Next
						EndIF
					EndIf

					If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
						If !JurMsgErro(STR0017)
							lRelOk := .F.
							cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
							Exit
						EndIf
					EndIf

				Next nI

				cLinha := "</tr>"

				If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
					JurMsgErro(STR0017)
					lRelOk := .F.
					cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
				EndIf
			EndIf

			(cAlias)->( dbcloseArea() )

			RestArea(aArea)

			FClose(nHdl)

			//Se não for html, copia para o sistema de arquivos local do usuário
			If !lHtml
				If cPathS <> ( cDirDest + cNomeTmp )
					if !lAutomato
						CpyS2T( cPathS, cDirDest ) //copia o arquivo local
					Else
						__copyfile( cPathS, cDirDest + cNomeTmp ) //copia o arquivo local
					Endif
				Endif
				
				If File(cArq,0) //valida se já existe um arquivo com o mesmo nome.
					if FErase(cArq) < 0
						cNome := cNome + "_2"
						cArq := cDirDest + cNome + ".xls"
						While (File(cArq,0))
							nArq := 3
							cNome := cNome + "_" + AllTrim(str(nArq))
							cArq := cDirDest + cNome + ".xls"
							nArq := nArq + 1
						End
					Endif
				Endif
				
				FRename(cDirDest + cNomeTmp,cArq)
				FErase(cPathS)
				
			ElseIf FindFunction(cFunction)
				//Executa o download no navegador do cliente
				&(cFunction+'("'+cPathS+'")')
			Endif

			//<------------------- Verifica se o usuário quer abrir o arquivo -------------->//
			If !lHtml .And. !lAutomato .AND. ApMsgYesNo(STR0018 + cArq + STR0019)
				If !File(cArq)
					JurMsgErro(STR0014 + cArq + STR0021)
					Return
				Else
					nRet := ShellExecute( 'open', cArq , '', "C:\", 1 )

					If nRet <= 32
						Do Case
							Case nRet == 2;	JurMsgErro(STR0022)
							Case nRet == 5 .Or. nRet == 55; JurMsgErro(STR0023)
							Case nRet == 15; JurMsgErro(STR0024)
							Case nRet == 31; JurMsgErro(STR0025)
							Case nRet == 32; JurMsgErro(STR0026)
							Case nRet == 72; JurMsgErro(STR0027)
							OTHERWISE
							JurMsgErro(STR0028)
						EndCase
					EndIf

				EndIf

			EndIf
		EndIf
	Else
		If !ExistDir(cPathS)
			JurMsgErro(STR0076) //"Não foi possíveç gerar a exportação personalizada. Verifique junto a equipe técnica se a pasta SPOOL existe no diretório Protheus_Data."
				lRelOk := .F.
				cMsgErroRel := STR0076 //"Não foi possíveç gerar a exportação personalizada. Verifique junto a equipe técnica se a pasta SPOOL existe no diretório Protheus_Data."

		EndIf
	EndIf

	If lO17 .AND. !lRelOk
		oJsonRel['O17_DESC']   := cMsgErroRel
		oJsonRel['O17_STATUS'] := "1" // Erro
		J288GestRel(oJsonRel)
	Endif

	cLinha  := ''
	cClasse := ''
	cCabec  := ''
	cSQL    := ''
	cTd     := ''
	cFinal  := ''

	aSize(aSoma,0)
	aSize(aSaldo,0)
	aSize(aCampNum,0)
	aSize(aParams,0)
	aSize(aParamQry,0)
	aSize(aAux,0)
	aSize(aMemo,0)
	aSize(aGar1,0)
	aSize(aSomPr,0)
	aSize(aResp,0)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108EXLSX
Gera a exportação personalizada em xlsx
Uso Geral.

@param nNQ3        Quantidade total de registros da fila de impressão
@param aCamposSel  Array de campos selecionados para exportação
@param cConfig     Configuração
@param lGar1       Se tem saldo de garantia ou não
@param lSoma       Se tem somatorio
@param cAnoMes     informa o ano e mes
@param aFiltro     Filtros a serem incrementados
@param lFila       Verifica se a chamada é originaria na Fila de Impressão
@param aEspec      Array de campos filtro especial
@param nAgrupa     numero de agrupamentos
@param cArq        Loca do arquivo a ser gravado
@param lAutomato   Se veio da automação
@Param lFiltFili   Verifica se ultiliza xfilial
@Param cEntFilial  Entidade para relacionar Filial.
@param lCorrige    Se corrige os valores
@param oJsonRel    Objeto json contendo os dados da Gestão de relatórios (O17)
@param cthread     Nome da thread
@param cCmpsOrder  Campos a serem utilizados no order by da query

@since 09/01/2021
/*/
//-------------------------------------------------------------------
Function JA108EXLSX(nNQ3,aCamposSel,cConfig, lGar1, lSoma, cAnoMes, aFiltro, lFila, aEspec, nAgrupa, cArq, lAutomato, lFiltFili, cEntFilial, lCorrige, oJsonRel, cThread, cCmpsOrder)
Local aArea        := GetArea()
Local aAux         := {}
Local aCampNum     := {}
Local aFormulas    := {}
Local aGar1        := {}
Local aMemo        := {}
Local aParamQry    := {}
Local aParams      := {}
Local aResp        := {}
Local aSaldo       := {}
Local aSoma        := {}
Local aSomPr       := {} //array com a soma das linhas principais, onde não precisamos quebrar por processo.
Local aValCmpAgr   := {}
Local cAlias       := GetNextAlias()
Local cApProc      := JurGetDados('NQ0', 2 , xFilial('NQ0') + 'NSZ' , 'NQ0_APELID')
Local cCajuri      := ""
Local cCampo       := ""
Local cClasse      := ""
Local cCodigo      := ""
Local cCpoMem      := ""  //nome do campo com o conteúdo do memo convertido em caracter
Local cDesConfig   := ""
Local cDirDest     := "" //Diretório do destino, no caso de smartclient local.
Local cEnvolvs     := ""
Local cExtens      := "Arquivo XLSX | *.xlsx"
Local cFilOri      := "" //--Filial de Origem da NSZ
Local cFinal       := ""
Local cFormula     := ""
Local cFunction    := "CpyS2TW"
Local cMsgErroRel  := ""
Local cNome        := "" //Nome do arquivo que o usuário escolheu
Local cNomeTmp     := "" //Nome temporário do arquivo que será utilizado no server
Local cParamQry    := ""
Local cParams      := ""
Local cPathS       := "\spool\" //caminho onde o arquivo será gerado no servidor
Local cRec         := "RECNO"
Local cSQL         := ""
Local cSzMem       := ""  //nome do campo com o tamanho do campo memo para validação de existe informação
Local cTab         := ""
Local cTd          := ""
Local cTexto       := ""
LOcal cTitCampo    := ""
Local cVlrCampo    := ""
Local lAgrupVlr    := .F.
Local lCheckAgru   := .F.
Local lDbSeek      := .T.
Local lEnvolConc   := .F.
Local lEspec       := .F.
Local lGarConteu   := .F.
Local lHtml        := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
Local lIncRd0Sig   := .F.
Local lLinux       := "Linux" $ GetSrvInfo()[2]
Local lO17         := ValType(oJsonRel) == 'J'
Local lPagrup      := .F.
Local lPriLinha    := .T.
Local lRelOk       := .T.
Local lRet         := .T.
Local lTemNQ3      := .F. //Controla se exite NQ3 - Fila de Impressao
Local lValGar      := .F.
Local nA           := 0
Local nAi          := 1
Local nCampos      := 0
Local nCampovlr    := 0
Local nColConteu   := 0 // número da coluna do conteúdo da planilha
Local nColGar      := 0
Local nColTit      := 0
Local nColTot      := 0 // número da coluna do total da planilha
Local nCt          := 2  // inicia com dois devido as linhas de título da planilha
Local nE           := 1
Local nG           := 1
Local nI           := 1
Local nJ           := 1
Local nJurosG      := 0
Local nLevanG      := 0
Local nLinhas      := 0
Local nMemo        := 0
Local nN           := 1
Local nP           := 0
Local nPos         := 0
Local nPosCmpEsp   := 0
Local nPosEsp      := 0
Local nPosSoma     := 1
Local nPosSomaTemp := 1
Local nPosValAgr   := 0
Local nPosValEsp   := 0
Local nQtdColSpn   := 0  // Quantidade de colunas para o merge do titulo
Local nQtdLinha    := 0
Local nRecno       := 0
Local nRet         := 0
Local nRowFromTi   := 0
Local nSaldoFG     := 0
Local nSeq         := 0
Local nSleep       := 0
Local nSoma        := 0
Local nSomPt       := 0  //guarda temporariamente a posição dos valores do array
Local nTJuros      := 0
Local nTLevan      := 0
Local nTSaldoF     := 0
Local nValor       := 0
Local oPrtXlsx     := FwPrinterXlsx():New()

Default cArq       := ""
Default cThread    := SubStr(AllTrim(Str(ThreadId())),1,4)
Default lAutomato  := .F.
Default lCorrige   := .F.

	cSQL := JA108GSQL(aCamposSel,.F. /*lCamposAg*/,.F./*lIncrSQL*/, aFiltro, lFila, @aEspec, @nAgrupa, lFiltFili, cEntFilial, cThread, cCmpsOrder )

	// Ajuste para título do relatório padrão do TOTVS Legal
	If !Empty( cConfig )
		cDesConfig := Posicione('NQ5', 1 , xFilial('NQ5') + cConfig , 'NQ5_DESC')//NQ5_FILIAL+NQ5_COD
	Else
		cDesConfig := STR0081 // "TOTVS Jurídico"
	EndIf

	//Valida se o campo de ano-mes foi preenchido e se a query faz referência ao mesmo.
	If !Empty(cAnoMes)
		cSQL := Replace(cSQL,":ANOMES",cAnoMes)
	Endif

	//Escolha o local para salvar o arquivo
	//Se for o html, não precisa escolher o arquivo
	If !lHtml .AND. EMPTY(cArq) .And. !Empty(cSQL)
		cArq := cGetFile(cExtens,STR0020,,'C:\',.F.,nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE),.F.)
	ElseIF lHtml .And. !Empty(cSQL)
		cArq := "\" + STR0075 + "_" + RetCodUsr()
	Endif

	If At(".xlsx",cArq) > 0
		cArq := StrTran(cArq, ".xlsx", ".rel")
	ElseIf At(".xls",cArq) > 0
		cArq := StrTran(cArq, ".xls", ".rel")
	ElseIf At(".rel",cArq) == 0
		cArq += ".rel"
	Endif

	// Tratamento para S.O Linux
	If lLinux
		cArq := StrTran(cArq,"\","/")
		cPathS := StrTran(cPathS,"\","/")
	Endif

	If cArq <> ".rel" .And. ExistDir(cPathS) .And. !Empty(cSQL)//valida se o arquivo tem nome e se o diretório existe.

		//Separa o nome do arquivo do caminho completo
		cNome := SubStr(cArq,Rat(IF(!lLinux,"\","/"),cArq)+1)

		//nome do arquivo criado no servidor, temporariamente
		cNomeTmp := JurTimeStamp(1) + "_" + cNome
		cPathS := cPathS + cNomeTmp

		//Separa o diretório de destino da máquina do usuário
		cDirDest := SubStr(cArq,1,Rat(IF(!lLinux,"\","/"),cArq))

		If lO17
			oJsonRel['O17_DESC']   := STR0083 //"Preparando os dados do relatório"
			J288GestRel(oJsonRel)
		Endif

		cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAlias,.T.,.T.)

		If !EMPTY(cSQL)//Guarda o valor dos parametros que serão utilizados nas formulas
			cParamQry := cSQL
			cParamQry := Alltrim(SUBSTR(cParamQry,AT("NSZ_COD", cParamQry)+8,Len(cParamQry)-AT(",",cParamQry)+1))
			cParamQry := Alltrim(SUBSTR(cParamQry,1,AT("FROM",cParamQry)-1))

			aParamQry := STRTOKARR(cParamQry, ",")

		EndIf

		aParamQry := Aclone(aAux)

		nCampovlr := 0
		lTemNQ3   := lFila	//Salva o conteudo da variavel lFila para ser utilizado nas consultas na funcao JA108GSQL

		//Ajusta formato dos campos de data.
		For nN:=1 to Len(aCamposSel)
			If len(aCamposSel[nN]) > 5 .And. aCamposSel[nN][9] == 'D' //Verifica se é uma formula e se o tipo do cmapo é data
				cTitCampo:= aCamposSel[nN][13]
			EndIf
		Next

		//Determnina quais campos são numéricos
		If (lSoma)
			For nN:=1 to Len(aCamposSel)
				//verifica os campos que são valores, para realizar a somatória
				If(Len (aCamposSel[nN]) > 5) //Verifica se é uma formula
					If aCamposSel[nN][9] == 'N'
						aAdd(aCampNum,{AllTrim(aCamposSel[nN][13]),aCamposSel[nN][12]})
						If aCamposSel[nN][12] .and. Len(aCamposSel) < nN
							lAgrupVlr := .T.
						EndIf
						//quantidade de campos com valores
						If aCamposSel[nN][3] == 'NT2_VALOR'
							nCampovlr := nCampovlr + 1
						EndIf
					EndIf
				Endif
			Next
		Endif

		lPriLinha := .T.

		//CARREGA RESPONSAVEIS
		If aScan(aCamposSel, {|x| 'NTE_' $ x[3]}) > 0
			aResp := J108QryRsp(lFila, aFiltro, cApProc, aCamposSel, cThread)
		EndIf

		//Quantidade de registros a serem exportados
		While !(cAlias)->( Eof() )

			If lSoma
				For nN:=1 to Len(aCampNum)
					//verifica os campos que são valores, para realizar a somatória
					If !aCampNum[nN][2]
						cTitCampo:= aCampNum[nN][1]
						if (cAlias)->(FieldPos(cTitCampo)) > 0 .And. (cAlias)->(FieldGet(FieldPos(cTitCampo))) != 0
							nSomPt := aScan(aSomPr,{|x| x[1] == cTitCampo})
							if nSomPt > 0
								aSomPr[nSomPt][2] += (cAlias)->(FieldGet(FieldPos(cTitCampo)))
							Else
								aAdd(aSomPr,{cTitCampo,(cAlias)->(FieldGet(FieldPos(cTitCampo)))})
							Endif
						Endif
					EndIf
				Next
			Endif

			//Quantidade de registros agrupados a serem exportados

			if len(aSoma)>0
				nPosSomaTemp := len(aSoma)
			Endif

			cFilOri := (cAlias)->NSZ_FILIAL
			cCodigo	:= (cAlias)->NSZ_COD
			If lSoma
				While !(cAlias)->( Eof() ) .AND. cFilOri == (cAlias)->NSZ_FILIAL .and. cCodigo == (cAlias)->NSZ_COD

					nLinhas++
					
						For nJ:=1 to Len(aCampNum)
							//verifica os campos que são valores, para realizar a somatória
							If aCampNum[nJ][2]
								cTitCampo:= aCampNum[nJ][1]

								//valida se o valor é diferente de 0.
								If (cAlias)->(FieldPos(cTitCampo)) > 0 .And. (cAlias)->(FieldGet(FieldPos(cTitCampo))) != 0

									//Verifica se ja existe o campo de valor para o processo
									If ( nPosSoma := aScan(aSoma, {|x| x[1] == ((cAlias)->NSZ_FILIAL + (cAlias)->NSZ_COD) .And. x[2] == (cAlias)->(cTitCampo)},nPosSomaTemp) ) > 0
										aSoma[nPosSoma][3] := aSoma[nPosSoma][3] + (cAlias)->( FieldGet( FieldPos(cTitCampo) ) )
									Else
										aAdd(aSoma,{ (cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD, (cAlias)->(cTitCampo),(cAlias)->(FieldGet(FieldPos(cTitCampo)))})
									EndIf
								EndIf
							EndIf
						Next
					(cAlias)->( dbSkip() )
				End
			Else
				(cAlias)->( dbSkip() )
			EndIf
		End
		
		If lRet := oPrtXlsx:Activate(cPathS)
			oPrtXlsx:AddSheet(STR0085) //"Exportação"

			If lGar1
				nQtdColSpn := 7 //colunas fixas + colunas da garantia
			Else
				nQtdColSpn := 4 //colunas fixas
			EndIf

			// Cabeçalho Linhas
			JurRowSize(@oPrtXlsx, 1, 1, "C", , Len(STR0039))
			oPrtXlsx:setText(1, 1, STR0039) // "Linhas"
			JurRowSize(@oPrtXlsx, 2, 2, "C", , Len(STR0040))
			oPrtXlsx:setText(1, 2, STR0040) // "Linhas do Assunto"

			If lCorrige
				JurCellFmt(@oPrtXlsx, , "TITULO")
				oPrtXlsx:setText(1, 3,  STR0082 + DTOC(Date()) ) // " * Valores atualizados em "
				nRowFromTi := 4
			Else
				nRowFromTi := 3
			EndIf
	
			// Titulo da planilha
			oPrtXlsx:MergeCells(1, nRowFromTi, 1, Len(aCamposSel) + nQtdColSpn)
			JurCellFmt(@oPrtXlsx, , "TITULO")
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 12, .F., .T., .F.)
			oPrtXlsx:setText(1, nRowFromTi, AllTrim(cDesConfig)) 

			// Conteúdo colunas Linhas
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F. /*lItalic*/, .F. /* lBold*/, .F./*lUnderlined*/)
			JurCellFmt(@oPrtXlsx)
			oPrtXlsx:SetBorder(.F./*lLeft*/, .F./*lTop*/, .F./*lRight*/, .F./*lBottom*/, FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:setText(2, 1, "T") // "Linhas"
			oPrtXlsx:setText(2, 2, "") // "Linhas do Assunto"
			
			// Cabeçalho fixo 
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F., .T., .F.)
			JurCellFmt(@oPrtXlsx, ,"CABECALHO")
			oPrtXlsx:SetBorder(.T./*lLeft*/, .T./*lTop*/, .T./*lRight*/, .T./*lBottom*/, FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			
			JurRowSize(@oPrtXlsx, 3, 3, "C", , Len(STR0041)+1)
			oPrtXlsx:setText(2, 3, STR0041) // "Sequência"
			JurRowSize(@oPrtXlsx, 4, 4, "C", , Len(STR0042))
			oPrtXlsx:setText(2, 4, STR0042) // "Código interno"

			//Títulos das colunas
			For nJ:=1 to Len(aCamposSel)

				// Cabeçalho dos campos selecionados
				oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F., .T., .F.)
				JurCellFmt(@oPrtXlsx, ,"CABECALHO")
				
				nColTit := Iif(lValGar, nJ+4+3, nJ+4)
				JurRowSize(@oPrtXlsx, nColTit, nColTit, ;
				            Iif(Len(aCamposSel[nJ]) > 5, aCamposSel[nJ][9], ""), /*cTpConteud*/;
				            Iif(Len(aCamposSel[nJ]) > 5, aCamposSel[nJ][3], ""), /*cCampo*/; 
				            Len(AllTrim(aCamposSel[nJ][1])) /*nLenDescCab*/, ;
				            Len(aCamposSel[nJ]) <= 5 /*lFormula*/)
				oPrtXlsx:setText(2, nColTit, AllTrim(aCamposSel[nJ][1]))

				If lGar1 //Verifica se foi solicitado inclusão de saldos das garantias na exportação, para criar as novas colunas de valores.

					If (aCamposSel[nJ][3] == 'NT2_VALOR') .Or. ;
						((nCampovlr == 0) .And. (Len(aCamposSel) == nJ) .And. (aScan(aCamposSel,{|x| x[3] == 'NT2_VALOR'}) == 0))
						JurCellFmt(@oPrtXlsx, "N","CABECALHO")

						For nG:=1 to 3
							Do Case
								Case nG==1
									JurRowSize(@oPrtXlsx, nG+nJ+4, nG+nJ+4, "C", 'NT2_VALOR', Len(STR0057))
									cTexto := STR0057 //'Total de Juros'
									nColGar := nJ
								Case nG==2
									JurRowSize(@oPrtXlsx, nG+nJ+4, nG+nJ+4, "C", 'NT2_VALOR', Len(STR0058))
									cTexto := STR0058 //'Total de Levantamentos'
								Case nG==3
									JurRowSize(@oPrtXlsx, nG+nJ+4, nG+nJ+4, "C", 'NT2_VALOR', Len(STR0059))
									cTexto := STR0059 //'Saldo Atual'
							EndCase
							
							oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F., .T., .F.)
							oPrtXlsx:SetText(2, nG+nJ+4, cTexto)
							lValGar := .T.

						Next

					EndIf
				EndIf

				If(Len (aCamposSel[nJ]) > 5) //Verifica se é uma formula
					//Conta quantos campos não são de agrupamento
					If !aCamposSel[nJ][12]
						nCampos := nCampos + 1
					EndIf
				Else
					nCampos++
				EndIf

			Next

			dbSelectArea(cAlias)

			(cAlias)->(dbGoTop())

			nCt := 1
			nSeq:= 0
			
			// Preenche o registro da rotina de gestão de relatórios do Totvs Legal
			If lO17
				oJsonRel['O17_MAX']   := If(nNQ3>nLinhas,nNQ3,nLinhas)
				J288GestRel(oJsonRel)
			Endif

			ProcRegua( If(nNQ3>nLinhas,nNQ3,nLinhas) )
			cFilOri     := ""
			cCodigo 	:= ""
			lPriLinha 	:= .T.
			IncProc()
			IncProc()

			//Dados da exportação - tabelas sem agrupamento de campos
			While !(cAlias)->( Eof() )

				lEspec := .F.

				If (cFilOri+cCodigo) <> ( (cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD )
					cFilOri   := (cAlias)->NSZ_FILIAL
					cCodigo   := (cAlias)->NSZ_COD
					lPriLinha := .T.
					nSeq 	  := nSeq + 1
					lDbSeek := .T.

					if lGar1 .And. ((cAlias)->(FieldPos('NT2_COD')) > 0) .and. !Empty((cAlias)->NT2_COD) //cria o saldo apenas se houver código na tabela de agrupamento NT2
						aSaldo := JA098CriaS(cCodigo, cFilOri)
					else
						aSaldo := {}
					Endif
				Else
					lPriLinha := .F.
				EndIf

				//Linhas fixas - linhas de processo / sequencia / código interno
				oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F. /*lItalic*/, .F. /* lBold*/, .F./*lUnderlined*/)
				JurCellFmt(@oPrtXlsx)
				oPrtXlsx:SetBorder(.F./*lLeft*/, .F./*lTop*/, .F./*lRight*/, .F./*lBottom*/, FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)

				If lPriLinha
					oPrtXlsx:SetText(nCt+2, 1, "D") 
				Else
					oPrtXlsx:SetText(nCt+2, 1, "") 
				EndIf
				
				oPrtXlsx:SetText(nCt+2, 2, AllTrim(Str(nCt))) 
				
				oPrtXlsx:SetBorder(.T./*lLeft*/, .T./*lTop*/, .T./*lRight*/, .T./*lBottom*/, FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
				oPrtXlsx:SetText(nCt+2, 3, AllTrim(Str(nSeq))) 
				oPrtXlsx:SetText(nCt+2, 4, (cAlias)->NSZ_COD)

				lIncRd0Sig := .F.

				// Conteúdo das linhas
				For nI:=1 to Len(aCamposSel)
					JurCellFmt(@oPrtXlsx, Iif( Len(aCamposSel[nI]) > 5, aCamposSel[nI][9], ""))
					If lValGar .And. nI > nColGar
						nColConteu := nI+7
					Else
						nColConteu := nI+4
					EndIf

					lGarConteu := .F.

					If 'NTE_' $ aCamposSel[nI][3] .And. !Empty((cAlias)->NTA_COD) .AND. Len(aCamposSel[nI]) > 5
						J108GetNTE(@aResp, (cAlias)->NTA_COD, aCamposSel[nI][3], @oPrtXlsx, nCt+2, nI+4)

						If lPriLinha .And. lSoma .And. Len(aCamposSel[nI]) > 5 .And. aCamposSel[nI][12]
							oPrtXlsx:SetText(nCt+2, nColConteu, "-")
						EndIf

						Loop //pula para o próximo campo

					EndIf

					If len(aCamposSel[nI]) > 5 .And. aScan(aEspec,{|x| x[13] == aCamposSel[nI][13]}) > 0 //valida se é um campo de filtro especial para já executar, valida pelo posicao 13 porque a 3 pode ser igual se for um campo de descricao
						lEspec := .T.
						If lPriLinha
							lEspec := .T.
							If !lCheckAgru
								aValCmpAgr := J108ValCmpAg(aEspec, 1, lTemNQ3, cThread, aFiltro )
								lCheckAgru := .T.
							EndIf
							
							nPosValAgr := aScan(aValCmpAgr, {|x| x[1] == cFilOri .And. x[2] == cCodigo}) // Posição do cajuri da vez no array de cache de agrupamento
							nPosCmpEsp := aScan(aEspec, {|x| x[13] == aCamposSel[nI][13]}) // Posição do campo atual no array de campos especiais
							If nPosValAgr > 0
								nE := 0
								For nPosEsp := 3 To Len(aValCmpAgr[nPosValAgr])
									If AllTrim(aValCmpAgr[nPosValAgr][nPosEsp][4]) == aCamposSel[nI][3]
										nPosValEsp := nPosEsp // Posição do valor do campo especial no item correspondente ao cajuri da vez do array de cache de agrupamento
										Exit
									EndIf
								Next nPosEsp

								// Adiciona os campos de agrupamento no relatório
								If !Empty(nPosValEsp) .And. nPosValEsp > 0
									J108GEXLS(aEspec[nPosCmpEsp], 1, cCodigo, @aSoma, lSoma, lGar1, @aGar1, cFilOri, @oPrtXlsx, nCt+2, nColConteu, aValCmpAgr[nPosValAgr][nPosValEsp])
									aDel(aValCmpAgr[nPosValAgr], nPosValEsp)
									aSize(aValCmpAgr[nPosValAgr],Len(aValCmpAgr[nPosValAgr])-1)
									If Len(aValCmpAgr[nPosValAgr]) < 3
										aDel(aValCmpAgr, nPosValAgr)
										aSize(aValCmpAgr,Len(aValCmpAgr)-1)
									EndIf
								EndIf
							Else
								J108GEXLS(aEspec[nPosCmpEsp], 1, cCodigo, @aSoma, lSoma, lGar1, @aGar1, cFilOri, @oPrtXlsx, nCt+2, nColConteu)
							EndIf
							lPagrup := .T.
							Loop
						Else
							oPrtXlsx:SetText(nCt+2, nColConteu, "-")
							Loop //pula para o próximo campo
						EndIf
					Endif

					//Verifica se é a primeira linha do assunto juridico, vai somar os valores, não é formula e se o campo é de agrupamento
					If lPriLinha .And. lSoma .And. Len(aCamposSel[nI]) > 5 .And. aCamposSel[nI][12]

						//Não passa para o proximo registro, para poder imprimir a primeira linha depois da linha de detalhe
						If lDbSeek
							lDbSeek := .F.
							nRecno := (cAlias)->( Recno() )
						Endif

						//Se não for numérico, escrever o traço e passa para o proximo campo
						If aCamposSel[nI][9] != 'N'
							oPrtXlsx:SetText(nCt+2, nColConteu, "-")
							//pula para o próximo campo
							Loop
						Endif
					EndIf

					cVlrCampo := ""
					cTitCampo := ""

					If(Len (aCamposSel[nI]) > 5) //Verifica se é uma formula

						cTitCampo:= ALLTRIM( aCamposSel[nI][13] )

						If aCamposSel[nI][3] $ CAMPOSNAOCONFIG
							cEnvolvs := JA108ENVOL((cAlias)->NSZ_COD, aCamposSel[nI][3])
							lEnvolConc := .T.
						Else
							cEnvolvs := ''
							lEnvolConc := .F.
						Endif

						//Define o valor do campo
						If aCamposSel[nI][9] == 'M'
							cTab   := AllTrim(aCamposSel[nI][5])
							cCampo := AllTrim(aCamposSel[nI][3])

							nRecno := (cAlias)->(FieldGet(FieldPos(aCamposSel[nI][7]+cRec)))

							//informações memo
							cCpoMem := ("MEM_"+AllTrim(aCamposSel[nI][13]))
							cSzMem := ("SZ_"+AllTrim(aCamposSel[nI][13]))

							If  nRecno > 0 //valida se o existe recno
								if aCamposSel[nI][12] //se for agrupamento, não tem cache
									if (cAlias)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
										//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
										if (cAlias)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cAlias)->(FieldGet(FieldPos(cSzMem))) <= 4000
											cVlrCampo := (cAlias)->(FieldGet(FieldPos(cCpoMem)))
										Elseif (cAlias)->(FieldGet(FieldPos(cSzMem))) == 0
											cVlrCampo := ""
										Else
											&(cTab)->( dbGoTo( nRecno ))
											cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
										Endif
									Else
										&(cTab)->( dbGoTo( nRecno ))
										cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
									Endif
								Elseif aScan(aMemo,{|x| x[1] == cFilOri+cCodigo}) > 0 //valida se filial + código da nsz ja existe
									if (nMemo := aScan(aMemo,{|x| x[2] = aCamposSel[nI][13]+cRec })) == 0	 //valida se o cache do campo ja existe
										//não existe, então busca na tabela
										if (cAlias)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
											//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
											if (cAlias)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cAlias)->(FieldGet(FieldPos(cSzMem))) <= 4000
												cVlrCampo := (cAlias)->(FieldGet(FieldPos(cCpoMem)))
											Elseif (cAlias)->(FieldGet(FieldPos(cSzMem))) == 0
												cVlrCampo := ""
											Else
												&(cTab)->( dbGoTo( nRecno ))
												cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
											Endif
										Else
											&(cTab)->( dbGoTo( nRecno ))
											cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
										Endif
										aAdd(aMemo,{cFilOri+cCodigo,(aCamposSel[nI][13]+cRec),cVlrCampo}) //grava o cache
									Else
										//ja existe, usa o array
										cVlrCampo := aMemo[nMemo][3]
									Endif
								Else
									aSize(aMemo,0)
									if (cAlias)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
										//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
										if (cAlias)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cAlias)->(FieldGet(FieldPos(cSzMem))) <= 4000
											cVlrCampo := (cAlias)->(FieldGet(FieldPos(cCpoMem)))
										Elseif (cAlias)->(FieldGet(FieldPos(cSzMem))) == 0
											cVlrCampo := ""
										Else
											&(cTab)->( dbGoTo( nRecno ))
											cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
										Endif
									Else
										&(cTab)->( dbGoTo( nRecno ))
										cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
									Endif
									aAdd(aMemo,{cFilOri+cCodigo,aCamposSel[nI][13]+cRec,cVlrCampo})
								Endif
							Else
								cVlrCampo := "-"
							EndIf
						Else
							if lEnvolConc
								cVlrCampo := cEnvolvs
							Else
								If (!Empty(aCamposSel[nI][14])) //Valida se existe opções
									cVlrCampo := JCboxValue(AllTrim(aCamposSel[nI][14]),(cAlias)->(FieldGet(FieldPos(cTitCampo)) ))
								Else
									cVlrCampo := cValToChar( (cAlias)->(FieldGet(FieldPos(cTitCampo)) ))
								Endif
							Endif
						EndIf


						If aCamposSel[nI][9] == 'D'
							If Empty(cVlrCampo)
								oPrtXlsx:SetValue(nCt+2, nColConteu, "-")
							Else
								oPrtXlsx:SetDate(nCt+2, nColConteu, SToD(AllTrim( cVlrCampo )))
							EndIf
						ElseIf aCamposSel[nI][9] == 'N' .And. aScan(aEspec,{|x| x[3] == aCamposSel[nI][3]}) == 0  .And. lPriLinha
							If lSoma
								If aCamposSel[nI][12] //valida se é uma tabela de agrupamento

									//Busca a primeira ocorrencia do campo para o assunto juridico, para processar o array aSoma a partir desta posição
									nAi := aScan(aSoma, {|x| x[1] == ((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD) .And. (cAlias)->(cTitCampo) == x[2]} )
									If nAi > 0
										For nA:= nAi  to Len(aSoma)
											If ( (cAlias)->(cTitCampo) == aSoma[nA][2] ) .And. ((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD == aSoma[nA][1])
												nSoma := nSoma + aSoma[nA][3]
											Elseif ((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD <> aSoma[nA][1] )
												Exit
											EndIf
										Next nA
									EndIf
								Else
									nSoma := (cAlias)->(FieldGet(FieldPos(cTitCampo)))
								Endif
								oPrtXlsx:SetNumber(nCt+2, nColConteu, nSoma)

								If nSoma != 0
									nSoma   := 0
								EndIf
							Else
								oPrtXlsx:SetNumber(nCt+2, nColConteu, Val( cVlrCampo ))
							EndIf
						ElseIf aCamposSel[nI][9] == 'N'
							oPrtXlsx:SetNumber(nCt+2, nColConteu, Val( cVlrCampo ))
						Else
							oPrtXlsx:SetValue(nCt+2, nColConteu, AllTrim( cVlrCampo ))
						EndIf

					Else //Caso seja uma formula

						cParams := AllTrim(aCamposSel[nI][3])

						aParams := STRTOKARR(cParams, ",")

						If Len(aParams) > 0
							cFilProc := ''
							For nP:= 1 to Len(aParams)
								aParams[nP] := AllTrim(aParams[nP])

								If ((At("CAJURI",aParams[nP]) > 0) .Or. (aParams[nP] = 'NSZ_COD'))
									aParams[nP] := (cAlias)->NSZ_COD
									cCajuri := aParams[nP]
								ElseIf (At("FILIAL",aParams[nP]) > 0)
									aParams[nP] := (cAlias)->NSZ_FILIAL
									cFilProc := aParams[nP]
								ElseIf (Substr(aParams[nP],4,1) == "_") .AND. (SubStr(aParams[nP],1,3))->(FieldPos(aParams[nP])) > 0

									nPos := (aScan( aParamQry, {|aX| aX[1] == Alltrim(aParams[nP]) } ) )
									If nPos > 0
										aParams[nP] := aParamQry[nPos][2]
									EndIf
								EndIf
							Next nP
						EndIf

						If Empty(cFilProc)
							cFilProc := cFilOri
						EndIf

						cFormula := vldFormula(@aFormulas,aCamposSel[nI][2], aCamposSel[nI][3], aParams, cFilProc, cCajuri, cThread)

						JurCellFmt(@oPrtXlsx, valType(cFormula))
						If valType(cFormula) == 'D'
							If Empty(cFormula)
								oPrtXlsx:SetValue(nCt+2, nColConteu, "-")
							Else
								oPrtXlsx:SetDate(nCt+2, nColConteu, SToD(AllTrim( cFormula )))
							EndIf
						ElseIf valType(cFormula) == 'N'
							oPrtXlsx:SetValue(nCt+2, nColConteu, Val(AllTrim(Str(cFormula))))
						Else
							oPrtXlsx:SetValue(nCt+2, nColConteu, AllTrim(cFormula))
						EndIf

					EndIf

					//Se foi escolhida a opção de mostrar os valores das garantias
					If lGar1

						If (aCamposSel[nI][3] == 'NT2_VALOR') .Or. ;
							((nCampovlr == 0) .And. (Len(aCamposSel) == nI) .And. (aScan(aCamposSel,{|x| x[3] == 'NT2_VALOR'}) == 0))

							For nG := 1 to Len(aSaldo)
								If Len(aSaldo[nG]) >= 7
									If (cAlias)->NSZ_FILIAL == cFilOri .AND. (cAlias)->NSZ_COD == cCodigo;
											.And. IIF(lPriLinha, .T., (cAlias)->NT2_COD == aSaldo[nG][7])	//Validacao para pegar o saldo da garantia posicionada
										
										If aSaldo[nG][4] == 'J'
											nJurosG := nJurosG + aSaldo[nG][5]
										ElseIf aSaldo[nG][4] == 'A'
											nLevanG 	:= nLevanG + aSaldo[nG][6]
										ElseIf aSaldo[nG][4] == 'SF'
											nSaldoFG	:= nSaldoFG + aSaldo[nG][5]
										EndIf
									EndIf
								EndIf
							Next
							
							JurCellFmt(@oPrtXlsx, "N")
							oPrtXlsx:SetNumber(nCt+2, nI+5, nJurosG)
							oPrtXlsx:SetNumber(nCt+2, nI+6, nLevanG)
							oPrtXlsx:SetNumber(nCt+2, nI+7, nSaldoFG)
							If aScan(aGar1,{|x| x[1] == cCodigo}) == 0
								aAdd(aGar1,{cCodigo, nJurosG, nLevanG, nSaldoFG})
							EndIf

							lGarConteu := .T.

							nJurosG  	:= 0
							nLevanG  	:= 0
							nSaldoFG 	:= 0
						EndIf
					EndIf
					nQtdLinha := nI
				Next nI

				nCt := nCt + 1

				IncProc()

				If lDbSeek .or. !lPriLinha
					(cAlias)->( dbSkip() )
				
					// Preenche o registro da rotina de gestão de relatórios do Totvs Legal
					If lO17
						oJsonRel['O17_DESC'] := STR0084 //"Gravando dados do relatório"
						oJsonRel['O17_MIN']  := oJsonRel['O17_MIN']+1
						oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN']*100/oJsonRel['O17_MAX'],0)
						J288GestRel(oJsonRel)
					Endif
					
					If !(cAlias)->( eof() )
						nRecno := (cAlias)->( Recno() )
					EndIf
				EndIf

			EndDo

			If lSoma
				JurCellFmt(@oPrtXlsx)
				oPrtXlsx:SetText(nCt+2, 1, "TOT")
				oPrtXlsx:SetText(nCt+2, 2, AllTrim(Str(nCt)))
				
				oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F., .T., .F.)
				JurCellFmt(@oPrtXlsx, ,"TOTAL")
				oPrtXlsx:SetText(nCt+2, 3, STR0086 ) //"TOTAL"
				oPrtXlsx:SetText(nCt+2, 4, "")

				For nI:=1 to Len(aCamposSel)
					If lValGar .And. nI > nColGar
						nColTot := nI+7
					Else
						nColTot := nI+4
					EndIf

					cTitCampo:= ""
					JurCellFmt(@oPrtXlsx, Iif(Len(aCamposSel[nI]) > 5, aCamposSel[nI][9], ""), "TOTAL")
					oPrtXlsx:SetText(nCt+2, nColTot, "")

					If(Len (aCamposSel[nI]) > 5) //Verifica se é uma formula

						cTitCampo:= ALLTRIM( aCamposSel[nI][13] )

						//se o campo for númerico, soma os valores e formata o campo
						If aCamposSel[nI][9] == 'N'
							nSoma   := 0

							if aCamposSel[nI][12] //valida se é uma tabela de agrupamento
								For nA:= 1 to Len(aSoma)
									If nA > Len(aSoma) .Or. aSoma[nA] == Nil
										Exit
									Endif
									If (cAlias)->(cTitCampo) == aSoma[nA][2] .Or. ;
									   (Len(aSoma[nA]) > 3 .And. aSoma[nA][4] == aCamposSel[nI][3]) //Para campos especiais preenchidos na J108GEXLS()
										nSoma := nSoma + aSoma[nA][3]
										aDel(aSoma,nA)
										aSize(aSoma,Len(aSoma)-1)
										nA--
									EndIf
								Next nA
							Else
								//se não for agrupamento, usa o total calculado para linhas principais de processos.
								nSomPt := aScan(aSomPr,{|x| x[1] == cTitCampo})
								if (nSomPt > 0)
									nSoma := aSomPr[nSomPt][2]
								Endif
							Endif
							oPrtXlsx:SetNumber(nCt+2, nColTot, nSoma)
						Else
							oPrtXlsx:SetText(nCt+2, nColTot, "")
						EndIf
					EndIf

					If lGar1
						If aCamposSel[nI][3] == 'NT2_VALOR' .OR. (nCampovlr == 0 .AND. Len(aCamposSel) == nI)
							For nG := 1 to Len(aGar1)
								nTJuros 	+= aGar1[nG][2]
								nTLevan 	+= aGar1[nG][3]
								nTSaldoF 	+= aGar1[nG][4]
							Next

							For nG := 1 to 3
								Do Case
									Case nG==1
										nValor := nTJuros
									Case nG==2
										nValor := nTLevan
									Case nG==3
										nValor := nTSaldoF
								EndCase

								JurCellFmt(@oPrtXlsx, "N", "TOTAL")
								oPrtXlsx:SetNumber(nCt+2, nG+nI+4, nValor)
							Next
						EndIF
					EndIf

				Next nI

			EndIf

			(cAlias)->( dbcloseArea() )

			RestArea(aArea)

			oPrtXlsx:toXlsx()

			While !File(StrTran(cPathS, ".rel", ".xlsx")) .And. nSleep < 10 //aguarda a geração do .xlsx
				nSleep++
				Sleep(1000)
			EndDo

			oPrtXlsx:DeActivate()

			If File(StrTran(cPathS, ".rel", ".xlsx"))

				FErase(cPathS) // Deleta o arquivo .rel da spool
				
				cPathS := StrTran(cPathS, ".rel", ".xlsx")
				cNomeTmp := StrTran(cNomeTmp, ".rel", ".xlsx")
				cArq  := StrTran(cArq, ".rel", ".xlsx")

				//Se não for html, copia para o sistema de arquivos local do usuário
				If !lHtml

					If cPathS <> ( cDirDest + cNomeTmp )
						If !lAutomato
							CpyS2T( cPathS, cDirDest )
						Else
							__copyfile( cPathS, cDirDest + cNomeTmp )
						EndIf

					EndIf

					FRename(cDirDest + cNomeTmp,cArq)

					If !IsInCallStack('JLPEXPREL') //Se for pelo totvslegal, não deleta 
						FErase(cPathS) // Deleta o arquivo .xlsx da spool
					EndIf
					
				ElseIf FindFunction(cFunction)
					//Executa o download no navegador do cliente
					&(cFunction+'("'+cPathS+'")')
				Endif
				
				//<------------------- Verifica se o usuário quer abrir o arquivo -------------->//
				If !lHtml .And. !lAutomato .AND. ApMsgYesNo(STR0018 + cArq + STR0019)
					If !File(cArq)
						JurMsgErro(STR0014 + cArq + STR0021)
						Return
					Else
						nRet := ShellExecute( 'open', cArq , '', "C:\", 1 )
						If nRet <= 32
							Do Case
								Case nRet == 2;	JurMsgErro(STR0022)
								Case nRet == 5 .Or. nRet == 55; JurMsgErro(STR0023)
								Case nRet == 15; JurMsgErro(STR0024)
								Case nRet == 31; JurMsgErro(STR0025)
								Case nRet == 32; JurMsgErro(STR0026)
								Case nRet == 72; JurMsgErro(STR0027)
								OTHERWISE
								JurMsgErro(STR0028)
							EndCase
						EndIf
					EndIf
				EndIf
			Else
				JurMsgErro(STR0014 + StrTran(cPathS, ".rel", ".xlsx") + STR0015) // "O arquivo " #1 " não pode ser criado"
				lRelOk := .F.
				lRet := .F.
				cMsgErroRel := STR0014 + cPathS + STR0015 // "O arquivo " + cPathS + "Erro ao gerar cabeçalho do arquivo"
			EndIf
		EndIf
	Else
		If !ExistDir(cPathS)
			JurMsgErro(STR0076) //"Não foi possível gerar a exportação personalizada. Verifique junto a equipe técnica se a pasta SPOOL existe no diretório Protheus_Data."
			lRelOk := .F.
			cMsgErroRel := STR0076
		EndIf
		lRet := .F.
	EndIf
	
	If !lRet
		//STR0014 - "O arquivo "
		//STR0015 - "Erro ao gerar cabeçalho do arquivo" 
		JurMsgErro(STR0014 + cPathS + STR0015)
		lRelOk := .F.
		cMsgErroRel := STR0014 + cPathS + STR0015 // "O arquivo " + cPathS + "Erro ao gerar cabeçalho do arquivo"
	EndIf

	If lO17 .AND. !lRelOk
		oJsonRel['O17_DESC']   := cMsgErroRel
		oJsonRel['O17_STATUS'] := "1" // Erro
		J288GestRel(oJsonRel)
	Endif

	cClasse := ''
	cSQL    := ''
	cTd     := ''
	cFinal  := ''

	aSize(aSoma,0)
	aSize(aSaldo,0)
	aSize(aCampNum,0)
	aSize(aParams,0)
	aSize(aParamQry,0)
	aSize(aAux,0)
	aSize(aMemo,0)
	aSize(aGar1,0)
	aSize(aSomPr,0)
	aSize(aResp,0)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Confg
Monta a lista de configurações a serem utilizadas
Uso Geral.

@return aRet     Array de configurações

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108Confg(cTipoAs, lTitNuz)
Local aRet    := {}
Local aArea   := GetArea()
Local cUser   := __CUSERID
Local nIndice := 1
Local cChave  := xFILIAL('NQ5')
Local cCampos := "NQ5_FILIAL"

Default cTipoAs := ''
Default lTitNuz := .F.

	//Mudar o índice caso o parametro de filtro pela nuz estiver habilitado.
	If lTitNuz
		nIndice := 2
		cChave := xFILIAL('NQ5') + cTipoAs
		cCampos := "NQ5_FILIAL + NQ5_CTPASJ"
	Endif

	NQ5->(dbGoTop())
	NQ5->(DBSetOrder(nIndice))
	NQ5->(DBSeek(cChave))

	aAdd(aRet,{'',''})

	While !NQ5->( EOF() ) .AND. NQ5->(&cCampos) == cChave
	  If NQ5->NQ5_TIPO == '2'
	  	aAdd(aRet,{ NQ5->NQ5_COD+"=", NQ5->NQ5_DESC })
	  Elseif NQ5->NQ5_USER == cUser
	    aAdd(aRet,{ NQ5->NQ5_COD+"=", NQ5->NQ5_DESC })
	  Endif
		NQ5->(dbSkip())
	End

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108NVCFG
Salva a lista de campos selecionados para uma configuração de
exportação
Uso Geral.

@param aCampos     Array de campos selecionados
@param cCfg		   Configuração
@param nTipo	   Indica o tipo de operação
				   1=Salvar nova configuração / 2= Atualizar já existente

@author Juliana Iwayama Velho
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108NVCFG(aCampos, oGrupList, nTipo, cTipoAs, aEspec)
Local nI
Local cConfig  := ''
Local aArea    := GetArea()
Local aAreaNQ5 := NQ5->(GetArea())
Local aAreaNQ8 := NQ8->(GetArea())
Local lOk      := .F.
Local cCfg     := IIf( nTipo == 1, oGrupList:GetNewConfig(), oGrupList:GetConfig() )
Local cUserCfg := IIF(oGrupList:CCMBCONFIG <> nil, Posicione('NQ5', 1, xFilial('NQ5') + oGrupList:CCMBCONFIG, 'NQ5_USER'),'')
Local cTipo    := ''
Local cUser    := __CUSERID
Local lTitNuz  := IIF(SUPERGETMV("MV_JEXPPTA", .T. , "2")=="1",.T.,.F.)		//12.1.5

If !Empty( cCfg ) .And. !Empty( aCampos )

	If cUser <> cUserCfg .And. oGrupList:CCMBCONFIG <> nil .And. !Empty(oGrupList:CCMBCONFIG) .And. nTipo == 2
		JurMsgErro(STR0045 + UsrFullName(cUserCfg))		//12.1.5
	Else
		cTipo := JA108TipoConf()

		If cTipo <> '0'

			If nTipo == 1
				cConfig         := GetSXENum("NQ5","NQ5_COD")
				RecLock('NQ5', .T.)
				NQ5->NQ5_FILIAL := xFilial('NQ5')
				NQ5->NQ5_COD    := cConfig
				NQ5->NQ5_DESC   := AllTrim(cCfg)
				NQ5->NQ5_USER   := cUser
				NQ5->NQ5_TIPO   := cTipo

				If NQ5->(FieldPos('NQ5_CTPASJ')) > 0
					NQ5->NQ5_CTPASJ := cTipoAs
				EndIf

				MsUnlock()

				If __lSX8
					ConFirmSX8()
					lOk := .T.
				EndIf

			Else

				If ApMsgYesNo(STR0037)

					cConfig := cCfg

					If NQ5->(FieldPos('NQ5_CTPASJ')) > 0

						NQ5->( dbSetOrder( 1 ) )
						NQ5->( dbSeek( xFilial('NQ5') + cConfig ) )

						While !NQ5->( EOF() ) .AND. NQ5->(NQ5_FILIAL + NQ5_COD) == xFilial( 'NQ5' ) + cConfig

							Reclock( 'NQ5', .F. )
							NQ5->NQ5_CTPASJ := cTipoAs
							NQ5->NQ5_TIPO   := cTipo
							MsUnlock()
							NQ5->( dbSkip() )

						End

						If __lSX8
								ConFirmSX8()
								lOk := .T.
						EndIf

					Endif

					NQ8->( dbSetOrder( 1 ) )
					NQ8->( dbSeek( xFilial('NQ8') + cConfig ) )

					While !NQ8->( EOF() ) .AND. NQ8->(NQ8_FILIAL + NQ8_CCONFG) == xFilial( 'NQ8' ) + cConfig
						Reclock( 'NQ8', .F. )
						dbDelete()
						MsUnlock()
						If Deleted()
							lOk := .T.
						Else
							lOk := .F.
							JurMsgErro(STR0038)
							Exit
						EndIf

						NQ8->( dbSkip() )
					End

				Else
					lOk := .F.
				EndIf

			EndIf

			If lOk
				For nI:= 1 to Len(aCampos)
					RecLock('NQ8', .T.)
						NQ8->NQ8_FILIAL := xFilial('NQ8')
						NQ8->NQ8_CCONFG := cConfig
						NQ8->NQ8_ORDEM  := StrZero(nI,4)

						If(Len (aCampos[nI]) > 5) //Verifica se é uma formula

							If !Empty (AllTrim(aCampos[nI][11]))
								If !( AllTrim(rettitle(aCampos[nI][11])) == AllTrim(aCampos[nI][1]) )
									NQ8->NQ8_TITCAM := AllTrim(aCampos[nI][1])
								EndIf
								If !( AllTrim(aCampos[nI][11]) == AllTrim(aCampos[nI][3]) )
									NQ8->NQ8_CAMPOT := AllTrim(aCampos[nI][11])
								EndIf
							 Else
								NQ8->NQ8_TITCAM := AllTrim(aCampos[nI][1])
							 EndIf

							 NQ8->NQ8_CAMPO  := AllTrim(aCampos[nI][3])
							 NQ8->NQ8_TAB1NV := AllTrim(aCampos[nI][4])
							 NQ8->NQ8_TAB2NV := AllTrim(aCampos[nI][5])
							 NQ8->NQ8_APE1NV := AllTrim(aCampos[nI][6])
							 NQ8->NQ8_APE2NV := AllTrim(aCampos[nI][7])
							 NQ8->NQ8_FILTRO := AllTrim(aCampos[nI][10])
							 If NQ8->(FieldPos( 'NQ8_PRIULT' )) > 0
								NQ8->NQ8_PRIULT := If(len(aCampos[nI])==15,aCampos[nI][15],)
							 EndIf
						Else
							If !Empty(AllTrim(aCampos[nI][2]))
								NQ8->NQ8_CAMPO  := AllTrim(StrTran(SubStr(AllTrim(aCampos[nI][2]),6),')',''))//Campos
								NQ8->NQ8_TITCAM := AllTrim(aCampos[nI][1])//Descrição
								NQ8->NQ8_APE1NV := AllTrim(aCampos[nI][4])//Apelido
								NQ8->NQ8_TAB2NV := AllTrim(aCampos[nI][5])//Alias
								NQ8->NQ8_FILTRO := AllTrim(aCampos[nI][3])//Parametros
							EndIf
						EndIf

					NQ8->(MsUnlock())

				Next

				If __lSX8
					ConFirmSX8()

					If nTipo == 1
						oGrupList:SetCmbConfig(JA108Confg())
						oGrupList:oCmbConfig:SetItems(oGrupList:GetItemsAry(oGrupList:GetCmbConfig()))
						oGrupList:oCmbConfig:Refresh()
						oGrupList:SetNewConfig(CriaVar('NQ5_DESC'))
						oGrupList:SetConfig(cConfig)
						oGrupList:RefreshConfig()
					EndIf
				EndIf

				ApMsgAlert(STR0035)
				oGrupList:SetConfig('')
				oGrupList:SetCmbConfig( JA108Confg(cTipoAs,lTitNuz) )
				oGrupList:oCmbConfig:SetItems( oGrupList:GetItemsAry( oGrupList:GetCmbConfig() ) )
				oGrupList:oCmbConfig:Refresh()
				oGrupList:RefreshConfig()


			EndIf
		Endif

	Endif

ElseIf Empty( aCampos ) .And. nTipo == 2

	If cUser <> cUserCfg

		JurMsgErro(STR0045 + UsrFullName(cUserCfg)) //Configurações publicas apenas o autor pode alterar. //12.1.5

	Else
		If JA162AcRst('12',5)
			If ApMsgYesNo(STR0029)

				NQ8->( dbSetOrder( 1 ) )
				NQ8->( dbSeek( xFilial('NQ8') + cCfg ) )

				While !NQ8->( EOF() ) .AND. NQ8->(NQ8_FILIAL + NQ8_CCONFG) == xFilial( 'NQ8' ) + cCfg
					Reclock( 'NQ8', .F. )
					 NQ8->( dbDelete() )
					NQ8->( MsUnlock() )

					NQ8->( dbSkip() )
				End

				NQ5->( dbSetOrder( 1 ) )

				If NQ5->( dbSeek( xFilial('NQ5') + cCfg ) )
					Reclock( 'NQ5', .F. )
					 NQ5->( dbDelete() )
					NQ5->( MsUnlock() )

					If Deleted()
							oGrupList:SetConfig('')
							oGrupList:SetCmbConfig( JA108Confg(cTipoAs,lTitNuz) )
							oGrupList:oCmbConfig:SetItems( oGrupList:GetItemsAry( oGrupList:GetCmbConfig() ) )
							oGrupList:oCmbConfig:Refresh()
							oGrupList:RefreshConfig()
							ApMsgInfo(STR0030)	// "Configuração excluída"
					EndIf
				EndIf

			EndIf
		Else
			JurMsgErro(STR0052)
		EndIf
	Endif
Else
	JurMsgErro(STR0036)
EndIf

RestArea(aAreaNQ8)
RestArea(aAreaNQ5)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108AtCps
Gera o array de campos de uma configuração já existente
cadastro.
Uso Geral.

@param  oGrupList   Objeto de lista
@param  cCodModelo  Código do Modelo de Config. de campos
@return aCampos	    Array de Campos

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA108AtCps( oGrupList, cCodModelo)
Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local aArea    := GetArea()
Local aCampos  := {}
Local aCampos2 := {}
Local aFormula := {}
Local lApelido := .T.
Local cConfig  := ""
Local nPriult  := 0

Default cCodModelo := ""

cConfig := IIF( !Empty(cCodModelo), cCodModelo, oGrupList:GetConfig() ) // Valida se é TOTVS Legal

If !Empty (cConfig)

	cQuery += "SELECT NQ8_CAMPO, NQ8_CAMPOT, NQ8_TAB1NV, NQ8_TAB2NV, NQ8_APE1NV, NQ8_APE2NV,"
	cQuery +=       " NQ8_FILTRO, NQ8_TITCAM, NQ8_ORDEM "
	If NQ8->(FieldPos( 'NQ8_PRIULT' )) > 0
		cQuery += ", NQ8_PRIULT "
	EndIf
	cQuery +=  " FROM "+RetSqlName("NQ8")+" NQ8, "+RetSqlName("NQ5")+" NQ5 "
	cQuery += " WHERE NQ8_FILIAL = '"+xFilial("NQ8")+"' AND NQ5_FILIAL = '"+xFilial("NQ5")+"' "
	cQuery +=   " AND NQ8_CCONFG = NQ5_COD AND NQ8_CCONFG = '"+cConfig+"' "
	cQuery +=   " AND NQ8.D_E_L_E_T_ = ' ' AND NQ5.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NQ8_ORDEM "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

	While !(cAlias)->( EOF() )

		nPriult := IIF( NQ8->( FieldPos('NQ8_PRIULT') ) > 0, (cAlias)->NQ8_PRIULT, 0 )

		//Carrega campos
		If !Empty( (cAlias)->NQ8_APE2NV ) .AND. !Empty( (cAlias)->NQ8_APE1NV )

			Aadd( aCampos2, JA108MtCps( (cAlias)->NQ8_CAMPOT	,;	//cCampoTela
											(cAlias)->NQ8_CAMPO	,;	//cCampo
											(cAlias)->NQ8_APE1NV	,;	//cApelido1n
											(cAlias)->NQ8_APE2NV	,;	//cApelido2n
											(cAlias)->NQ8_TAB1NV	,;	//cTab1n
											(cAlias)->NQ8_TAB2NV	,;	//cTab2n
											(cAlias)->NQ8_FILTRO	,;	//cFiltro
											(cAlias)->NQ8_ORDEM	,;	//cOrdem
											lApelido				,;	//lApelido
											(cAlias)->NQ8_TITCAM	,;	//cTitCampo
											.T.  					,;	//lTitNuz
											nPriult				,;	//nPriult
											.F.	)					)	//lFormula
		//Carrega formulas
		Else
			Aadd(aFormula, {(cAlias)->NQ8_TITCAM, '  -  ( ' + AllTrim((cAlias)->NQ8_CAMPO) + ' ) ', (cAlias)->NQ8_FILTRO, (cAlias)->NQ8_APE1NV, (cAlias)->NQ8_TAB2NV} )
		EndIf

		If Len(aCampos2) > 0
			aAdd(aCampos,aCampos2[1][1])
		EndIf

		If Len(aFormula) > 0
			aAdd(aCampos,aFormula[1])
		EndIf

		aSize(aCampos2,0)
		aSize(aFormula,0)

		(cAlias)->( dbSkip() )

	End

	(cAlias)->( dbcloseArea() )

EndIf

RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Tabs
Gera o array de campos de tabelas
Uso Geral.

@Param cTipoAs Código do tipo de assunto jurídico.
@param lTitNuz Valida se o parametro MV_JEXPPTA = 1 (Utiliza NUZ)

@return aRet	    Array de tabelas

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA108Tabs(cTipoAs,lTitNuz)
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaNQ0 := NQ0->( GetArea() )
Local cQryAbas := ''
Local aAbas    := {}
Local lInclui  := .T.
Local cTitulo  := ''

Default lTitNuz := .F.

//Valida se a preferência de utilizar dados da NUZ está habilitada. Se sim, as tabelas que aparecem serão limitadas de acordo com a NYC.
If lTitNuz
	cQryAbas := "SELECT NYC_TABELA FROM " + RetSqlName("NYC") + " WHERE NYC_CTPASJ='" + cTipoAs + "' AND D_E_L_E_T_ = ' ' AND NYC_FILIAL = '" + xFilial('NYC') + "'"
	aAbas := JurSql(cQryAbas,{"NYC_TABELA"})
Endif

//Abas NUQ, NT9, NXY, NYJ, NYP

NQ0->(DBSetOrder(1))
NQ0->(DBSeek(xFILIAL('NQ0')))
NQ0->(dbGoTop())

aAdd(aRet,{'','','',''})

While !NQ0->(EOF())

	lInclui := .T.

	// cTitulo := AllTrim( INFOSX2( NQ0->NQ0_TABELA, 'X2_NOME' ) ) + " ("+NQ0->NQ0_APELID+")"
	cTitulo := Alltrim( NQ0 -> NQ0_DTABEL) + " ("+NQ0->NQ0_APELID+")"


	//Validação em vários níveis para avaliar se a tabela deve ou não aparecer.
	If (NQ0->NQ0_TABELA $ "NUQ/NT9/NYJ/NYP/NXY") .And. lTitNuz .And. ( aScan(aAbas,{|aX| aX[1] = NQ0->NQ0_TABELA}) == 0 ) //"NSZ/NUQ/NT9/NT4/NTA/NSY/NT2/NT3/NSU/NYJ/NYP"
		lInclui := .F.
	Endif

	//A restrição é a validação maios restritiva. Mesmo habilitada no assunto jurídico ela não aparece caso o usuário não tenha acesso.
	if lInclui .And. NQ0->NQ0_TABELA $ "NSZ/NUQ/NT9/NYJ/NYP/NXY/NT4/NSY/NTA/NT2/NSU/O0M/O0N/NTE/NT3"
		If ( NQ0->NQ0_TABELA == 'NSZ' .And. JA162AcRst('14') ) .Or. ( NQ0->NQ0_TABELA == 'NUQ' .And. JA162AcRst('14') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'NT9' .And. JA162AcRst('14') ) .Or. ( NQ0->NQ0_TABELA == 'NYJ' .And. JA162AcRst('14') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'NYP' .And. JA162AcRst('14') ) .Or. ( NQ0->NQ0_TABELA == 'NXY' .And. JA162AcRst('14') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'NT4' .And. JA162AcRst('04') ) .Or. ( NQ0->NQ0_TABELA == 'NTA' .And. JA162AcRst('05') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'NSY' .And. JA162AcRst('06') ) .Or. ( NQ0->NQ0_TABELA == 'NT2' .And. JA162AcRst('07') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'NT3' .And. JA162AcRst('08') ) .Or. ( NQ0->NQ0_TABELA == 'NSU' .And. JA162AcRst('09') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'NTE' .And. JA162AcRst('14') ) .Or. ( NQ0->NQ0_TABELA == 'O0M' .And. JA162AcRst('19') ) .Or.;
		   ( NQ0->NQ0_TABELA == 'O0N' .And. JA162AcRst('19') )
		//
		Else
			lInclui := .F.
		Endif
	ElseIf lInclui
		If ( HasRelNSZ(NQ0->NQ0_TABELA) .And. JA162AcRst('14') )

		Else
			lInclui := .F.
		EndIf
	EndIf

	If lInclui
		aAdd(aRet,{ NQ0->NQ0_COD+"=", cTitulo, NQ0->NQ0_APELID, NQ0->NQ0_TABELA })
	Endif

	NQ0->(dbSkip())
End

RestArea(aAreaNQ0)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Orig
Gera o array de campos a remover da exportação e inserir na lista de
campos disponíveis
Uso Geral.

@param  oGrupList   Objeto de lista
@return aRemover    Array de tabelas

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA108Orig( oGrupList)
Local aArea      := GetArea()
Local aAreaNQ0   := NQ0->( GetArea() )
Local aAreaNQ2   := NQ2->( GetArea() )
Local aRemover   := {}
Local aCampos    := oGrupList:GetCmpSel()
Local cTabOrigem := ''
Local cTab       := oGrupList:GetTabela()
Local cApelido   := ''
Local nI         := 0
Local cRelac     := ""

If !Empty( aCampos )

	For nI :=1 to Len(aCampos)

		If(Len (aCampos[nI]) > 5) //Verifica se é uma formula
			cTabOrigem := Left( aCampos[nI][3], J108RetUnd(aCampos[nI][3] ) -1 )
		Else
			cTabOrigem := aCampos[nI][5]
		EndIf

		//Verifica se o nome da tabela vem do campo inicial ou de tela
		If(Len (aCampos[nI]) > 5) //Verifica se é uma formula
			If !(aCampos[nI][4] == aCampos[nI][5])
				If !Empty( aCampos[nI][11] )
					cTabOrigem := Left( aCampos[nI][11], J108RetUnd( aCampos[nI][11] ) - 1 )
				EndIf
			EndIf
		EndIf

		//Verifica se o campo de tela está preenchido, para utilizar o apelido de 2º nível
		If(Len (aCampos[nI]) > 5) //Verifica se é uma formula
			If Empty( aCampos[nI][11] )
				cApelido :=	aCampos[nI][7]
			Else
				cApelido := aCampos[nI][6]
			EndIf
		Else
			cRelac := aCampos[nI][4]
		EndIf

		NQ0->(DBSetOrder(2))    //NQ0_FILIAL+NQ0_TABELA

		IF NQ0->(DBSeek(xFILIAL('NQ0') + cTabOrigem ) )
			While !NQ0->( EOF() ) .AND. NQ0->NQ0_FILIAL + NQ0->NQ0_TABELA == xFilial( 'NQ0' ) + cTabOrigem

				If(Len (aCampos[nI]) > 5)

					If ( NQ0->NQ0_COD == cTab .Or. Empty(cTab) )  .And. NQ0->NQ0_APELID == cApelido .And. ( aScan( aRemover, {|x| x == aCampos[nI]} ) == 0 )
						aAdd(aRemover,aCampos[nI])
					EndIf
				Else

					If ( NQ0->NQ0_COD == cTab .Or. Empty(cTab) ) .And. ( aScan( aRemover, {|x| x == aCampos[nI]} ) == 0 )
						aAdd(aRemover,aCampos[nI])
					EndIf
				EndIf

				NQ0->( dbSkip() )
			End
		Endif

		NQ2->(DBSetOrder(2))   //FILIAL + tabela

		IF NQ2->( dbSeek( xFilial( 'NQ2' ) + 'NYZ' ))
			While !NQ2->( EOF() )
	     		If(Len (aCampos[nI]) > 5)
					aAdd(aRemover,aCampos[nI])
				Endif
				NQ2->( dbSkip() )
		    End
		Endif

	Next nI

EndIf

RestArea(aAreaNQ2)
RestArea(aAreaNQ0)
RestArea(aArea)

Return aRemover

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Formt
Monta a formatação da planilha em excel
Uso Geral.

@author Juliana Iwayama Velho
@since 17/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108Formt()
Local cFormato := ''
cFormato := "<html xmlns:v='urn:schemas-microsoft-com:vml'"+;
"xmlns:o='urn:schemas-microsoft-com:office:office'"+;
"xmlns:x='urn:schemas-microsoft-com:office:excel'"+;
"xmlns='http://www.w3.org/TR/REC-html40'>"+;
"<head>"+;
"<meta http-equiv=Content-Type content='text/html; charset=windows-1252'>"+;
"<meta name=ProgId content=Excel.Sheet>"+;
"<meta name=Generator content='Microsoft Excel 9'>"+;
"<link rel=File-List href='./pagina_arquivos/filelist.xml'>"+;
"<link rel=Edit-Time-Data href='./pagina_arquivos/editdata.mso'>"+;
"<link rel=OLE-Object-Data href='./pagina_arquivos/oledata.mso'>"+;
"<!--[if gte mso 9]><xml>"+;
" <o:DocumentProperties>"+;
"  <o:LastAuthor>BCS</o:LastAuthor>"+;
"  <o:LastPrinted>2005-10-14T18:08:09Z</o:LastPrinted>"+;
"  <o:Created>2003-05-28T19:01:01Z</o:Created>"+;
"  <o:LastSaved>2005-10-21T17:33:16Z</o:LastSaved>"+;
"  <o:Version>9.2812</o:Version>"+;
" </o:DocumentProperties>"+;
" <o:OfficeDocumentSettings>"+;
"  <o:DownloadComponents/>"+;
"  <o:LocationOfComponents HRef='file://Mailhost/DRIVERS/suporte/OFFICE/Msoffice2000/msowc.cab'/>"+;
" </o:OfficeDocumentSettings>"+;
"</xml><![endif]-->"+;
"<style>"+;
"<!--"+;
".style18mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"mso-style-name:Moeda;"+;
"mso-style-id:4;"+;
"table"+;
"	{mso-displayed-decimal-separator:'\.';"+;
"    mso-displayed-thousand-separator:'\,';}"+;
"@page"+;
"	{margin:.39in .39in .39in .39in;"+;
"	mso-header-margin:.51in;"+;
"	mso-footer-margin:.51in;"+;
"	mso-page-orientation:landscape;"+;
"	mso-horizontal-page-align:center;}"+;
"tr"+;
"	{mso-height-source:auto;"+;
"   mso-height-source:"+;
"   userset;height:25.5pt}"+;
"col"+;
"	{mso-width-source:auto;}"+;
"br"+;
"	{mso-data-placement:same-cell;}"+;
".style0"+;
"	{mso-number-format:General;"+;
"	text-align:general;"+;
"	vertical-align:bottom;"+;
"	mso-rotate:0;"+;
"	font-size:10.0pt;"+;
"	font-weight:400;"+;
"	font-style:normal;"+;
"	font-family:Arial;"+;
"	mso-protection:locked visible;"+;
"	mso-style-id:0;}"+;
"td"+;
"	{mso-style-parent:style0;"+;
"	padding-top:1px;"+;
"	padding-right:1px;"+;
"	padding-left:1px;"+;
"	mso-ignore:padding;"+;
"	color:windowtext;"+;
"	font-size:10.0pt;"+;
"	font-weight:400;"+;
"	font-style:normal;"+;
"	text-decoration:none;"+;
"	font-family:Arial;"+;
"	text-align:general;"+;
"	vertical-align:bottom;"+;
"	border:none;"+;
"	mso-protection:locked visible;"+;
"	mso-rotate:0;}"+;
"span"+;
"  {mso-spacerun: yes;}"+;
".xl26"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\@';"+;
"   text-align:center;"+;
"   vertical-align:middle;}"+;
".xl27"+;
"   {mso-style-parent:style0;"+;
"   font-weight:700;"+;
"   font-family:Arial, sans-serif;"+;
"   mso-font-charset:0;"+;
"   mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"   text-align:center;"+;
"   vertical-align:middle;"+;
"   border-top:.5pt solid windowtext;"+;
"   border-right:.5pt solid windowtext;"+;
"   border-bottom:.5pt solid windowtext;"+;
"   border-left:.5pt solid windowtext;"+;
"   background:silver;"+;
"   mso-pattern:auto none;}"+;
".xl28"+;
"   {mso-style-parent:style0;"+;
"	font-weight:700;"+;
"	font-family:Arial, sans-serif;"+;
"   mso-font-charset:0;"+;
"	mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"	text-align:center;"+;
"	vertical-align:middle;"+;
"	border-top:.5pt solid black;"+;
"	border-right:.5pt solid black;"+;
"	border-bottom:.5pt solid black;"+;
"   border-left:.5pt solid black;"+;
"	background:silver;"+;
"   mso-pattern:auto none;}"+;
".xl30"+;
"	  {mso-style-parent:style0;"+;
"     mso-number-format:0;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"   border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl31"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\@';"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl38"+;
"	  {mso-style-parent:style0;"+;
"	  color:white;"+;
"	  font-size:12.0pt;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  text-align:center;"+;
"	  border-top:.5pt solid windowtext;"+;
"	  border-right:none;"+;
"	  border-bottom:.5pt solid windowtext;"+;
"	  border-left:.5pt solid windowtext;"+;
"	  background:blue;"+;
"	  mso-pattern:auto none;}"+;
".xl41"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\#\,\#\#0\.00';"+;
"     text-align:right;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".x144"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'Short Date';"+;
"	  text-align:left;"+;
"	  vertical-align:middle;"+;
"     border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl48"+;
"   {mso-style-parent:style0;"+;
"	font-weight:700;"+;
"	font-family:Arial, sans-serif;"+;
"	mso-font-charset:0;"+;
"	mso-number-format:'\#\,\#\#0\.00';"+;
"	text-align:right;"+;
"	vertical-align:middle;"+;
"	border-top:.5pt solid black;"+;
"	border-right:.5pt solid black;"+;
"	border-bottom:.5pt solid black;"+;
"	border-left:.5pt solid black;"+;
"	background:silver;"+;
"	mso-pattern:auto none;}"+;
".xl49 .xl26"+;  //Seção da linha em destaque
"   {mso-style-parent:xl26;"+;
"    background: silver;}"+;
".xl49 .xl27"+;
"   {mso-style-parent:xl27;"+;
"	 background: silver;}"+;
".xl49 .xl28"+;
"   {mso-style-parent:xl28;"+;
"    background: silver;}"+;
".xl49 .xl30"+;
"	{mso-style-parent:xl30;"+;
"    background: silver;}"+;
".xl49 .xl31"+;
"	{mso-style-parent:xl31;"+;
"    background: silver;}"+;
".xl49 .xl38"+;
"	{mso-style-parent:xl38;"+;
"    background: silver;}"+;
".xl49 .xl41"+;
"	{mso-style-parent:xl41;"+;
"    background: silver;}"+;
".xl49 .x144"+;
"	{mso-style-parent:x144;"+;
"    background: silver;}"+;
".xl49 .xl48"+;
"   {mso-style-parent:xl48;"+;
"    background: silver;}"+;
".xl49 .xl49"+;
"	{mso-style-parent:xl49;"+;
"    background: silver}"+;
".dl26"+;
"   {mso-style-parent:xl26;"+;
"    background: silver;}"+;
".dl27"+;
"   {mso-style-parent:xl27;"+;
"	 background: silver;}"+;
".dl28"+;
"   {mso-style-parent:xl28;"+;
"    background: silver;}"+;
".dl30"+;
"	{mso-style-parent:xl30;"+;
"    background: silver;}"+;
".dl31"+;
"	{mso-style-parent:xl31;"+;
"    background: silver;}"+;
".dl38"+;
"	{mso-style-parent:xl38;"+;
"    background: silver;}"+;
".dl41"+;
"	{mso-style-parent:xl41;"+;
"    background: silver;}"+;
".d144"+;
"	{mso-style-parent:x144;"+;
"    background: silver;}"+;
".dl48"+;
"   {mso-style-parent:xl48;"+;
"    background: silver;}"+;
".dl49"+;
"	{mso-style-parent:xl49;"+;
"    background:silver}"+;
"</style><!--[if gte mso 9]>"+;
"   <xml> <x:ExcelWorkbook>"+;
"  <x:ExcelWorksheets>"+;
"   <x:ExcelWorksheet>"+;
"    <x:Name>Exportação</x:Name>"+;
"    <x:WorksheetOptions>"+;
"     <x:FitToPage/>"+;
"     <x:Print>"+;
"     <x:FitHeight>30</x:FitHeight>"+;
"     <x:ValidPrinterInfo/>"+;
"     <x:Scale>10</x:Scale>"+;
"      <x:HorizontalResolution>600</x:HorizontalResolution>"+;
"      <x:VerticalResolution>600</x:VerticalResolution>"+;
"     </x:Print>"+;
"     <x:ShowPageBreakZoom/>"+;
"     <x:PageBreakZoom>100</x:PageBreakZoom>"+;
"     <x:Selected/>"+;
"     <x:DoNotDisplayGridlines/>"+;
"     <x:ProtectContents>False</x:ProtectContents>"+;
"     <x:ProtectObjects>False</x:ProtectObjects>"+;
"     <x:ProtectScenarios>False</x:ProtectScenarios>"+;
"    </x:WorksheetOptions>"+;
"   </x:ExcelWorksheet>"+;
"  </x:ExcelWorksheets>"+;
"  <x:WindowHeight>8190</x:WindowHeight>"+;
"  <x:WindowWidth>14700</x:WindowWidth>"+;
"  <x:WindowTopX>600</x:WindowTopX>"+;
"  <x:WindowTopY>435</x:WindowTopY>"+;
"  <x:ProtectStructure>False</x:ProtectStructure>"+;
"  <x:ProtectWindows>False</x:ProtectWindows>"+;
" </x:ExcelWorkbook> <x:ExcelName> <x:Name>Print_Titles</x:Name>"+;
"  <x:SheetIndex>1</x:SheetIndex>"+;
"  <x:Formula>=Exportação!$1:$2</x:Formula>"+;
" </x:ExcelName></xml><![endif]--><!--[if gte mso 9]>"+;
"<xml> <o:shapedefaults v:ext='edit' spidmax='1030'/></xml><![endif]-->"+;
"</head><body link=blue vlink=purple>"+;
"<table border=0 cellpaddin g=0 cellspacing=0 style='border-collapse:collapse;table-layout:fixed'>"+Chr(13)+Chr(10)

Return cFormato

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108TipoConf()
Seleção do tipo d configuração
Uso Geral.
@author Clóvis Eduardo Teixeira
@since 11/04/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108TipoConf()
Local cTipo     := ''
Local aItems    := {STR0046,STR0047}
Local oCmbTipo, oDlg

	Define MsDialog oDlg Title STR0048 FROM 176, 188  To 320, 500 Pixel STYLE DS_MODALFRAME //Tipo de Configuração
	oDlg:lEscClose  := .F.
  	oCmbTipo := TJurCmbBox():New(020,050,060,010, oDlg, aItems,{|| })

		@ 010, 050 Say STR0049 Size 080, 008 Pixel Of oDlg // "Gravar configuração como:"

		@ 050, 035 BUTTON oBntConf Prompt STR0050    Size 28, 10 Of oDlg Pixel Action (cTipo := SubStr(oCmbTipo:cValor,1,1), oDlg:End()) //Confirmar
		@ 050, 095 BUTTON oBntConf Prompt STR0051 Size 28, 10 Of oDlg Pixel Action (cTipo := '0', oDlg:End()) //Cancelar

	Activate MsDialog oDlg Centered

Return cTipo


//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Envol(cAssJur)
Função para concatenar os envolvidos do processo.
Uso Geral.
@author Clóvis Eduardo Teixeira
@since 24/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108Envol(cAssJur, cCampo)
Local aAreaNT9   := NT9->(GetArea())
Local cCampoNome := "NT9_NOME"
Local cNomeEnvol := ''

If Existblock("JA108NomeE")
	cCampoNome := ExecBlock("JA108NomeE",.F.,.F.,{cCampoNome})
Endif

NT9->( dbSetOrder( 2 ) )
if NT9->( dbSeek( xFilial( 'NT9' ) + cAssJur) )

	While !NT9->(EOF()) .AND. xFilial( 'NT9' ) + cAssJur == NT9->NT9_FILIAL + NT9->NT9_CAJURI

		if Empty(cNomeEnvol)
			if cCampo == 'NT9_CNOMEA' .And. NT9->NT9_TIPOEN == '1'
				cNomeEnvol := AllTrim(NT9->&(cCampoNome))
			Elseif cCampo == 'NT9_CNOMEP' .And. NT9->NT9_TIPOEN == '2'
				cNomeEnvol := AllTrim(NT9->&(cCampoNome))
			Endif
		Else
			if cCampo == 'NT9_CNOMEA' .And. NT9->NT9_TIPOEN == '1'
				cNomeEnvol := cNomeEnvol +' / '+ AllTrim(NT9->&(cCampoNome))
			Elseif cCampo == 'NT9_CNOMEP' .And. NT9->NT9_TIPOEN == '2'
				cNomeEnvol := cNomeEnvol +' / '+ AllTrim(NT9->&(cCampoNome))
			Endif
		Endif

		NT9->( dbSkip() )

	End

Endif

RestArea( aAreaNT9 )

Return cNomeEnvol


//-------------------------------------------------------------------
/*/{Protheus.doc} J108VerUnd(cAssJur)
Função para verificar se há underlines duplicados apos o nome da tabela
Caso haja, será retirado

Uso Geral.
@author Rafael Rezende Costa
@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108VerUnd(cCmp)
local cRet    := ''
Local nCarac  := 0
Local nTmpNum := 0
Local lCont   := .T.

Default cCmp := ''

If cCmp <> ''

	cCmp	:= Alltrim(cCmp)
	nTmpNum:= Len(cCmp)
	nCarac	:= J108RetUnd(cCmp)

	If nCarac > 0

		cRet := RIGHT( cCmp,(nTmpNum - nCarac))

		IF left( cRet, 1) == '_'
			lCont := .T.
		Else
			lCont := .F.
		EndIF

		WHILE lCont
			cRet := RIGHT( cCmp,(nTmpNum - nCarac) - 1 )

			IF left( cRet, 1) <> '_'
				lCont := .F.
			EndIF
		End
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J108RetUnd(cConteud)
Função para verificar a quantidade de underlines na expressão
passada como parametro

Uso Geral.
@author Rafael Rezende Costa
@since 02/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108RetUnd(cConteud)
Local nRet := 0

Default cConteud := ''

	If cConteud <> ''
		If ( nRet := AT("_", cConteud, 5) ) == 0
			nRet := 4
		EndIf
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J108Extrat(cConteud)

Função para verificar a existência de algum registro na NV3 (Extrato)
de acordo com os parametros.

Uso Geral.

@author Rafael Rezende Costa
@since 15/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108Extrat()
Local lRet   := .F.
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

	cSQL  := "SELECT COUNT(*) QTD FROM "+ RetSqlname('NV3') +" NV3 "
	cSQL  += " WHERE NV3.D_E_L_E_T_ = ' ' "
	cSQL  += " AND NV3.NV3_FILIAL = '" + xFilial('NV3') + "'"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .T.)

	If !(cAlias)->( EOF() )
		If (cAlias)->QTD > 0
			lRet := .T.
		EndIf
	EndIf

	(cAlias)->( dbcloseArea() )

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J108NuzCpo(cTipoAs, cTabela)

Função que retorna um array com todos os campos disponíveis na tela
de acordo com o assunto jurídico.

Uso Geral.

@param  cTipoAs Código do tipo de assunto jurídico
@param  cTabela Nome da tabela

@return aRet Array com os campos

@author André Spirigoni Pinto
@since 15/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108NuzCpo(cTipoAs, cTabela )
Local aRet   := {}
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

	cSQL  := " SELECT NUZ.NUZ_CAMPO, "
	cSQL  +=        " NUZ.NUZ_DESCPO "
	cSQL  += " FROM " + RetSqlname('NUZ') + " NUZ "
	cSQL  += " WHERE  NUZ.D_E_L_E_T_ = ' ' "
	cSQL  +=        " AND NUZ.NUZ_CTAJUR = '" + cTipoAs + "' "
	cSQL  +=        " AND NUZ.NUZ_FILIAL = '" + xFilial('NUZ') + "' "
	cSQL  += " UNION "
	cSQL  += " SELECT NUZ.NUZ_CAMPO, "
	cSQL  +=        " NUZ.NUZ_DESCPO "
	cSQL  += " FROM "+ RetSqlname('NUZ') +" NUZ INNER JOIN "+RetSqlname('NYB')+" NYB ON ( NUZ.NUZ_CTAJUR = NYB.NYB_CORIG "
	cSQL  +=                                                                        " AND NYB.NYB_COD = '"+cTipoAs+"' ) "
	cSQL  += " WHERE  NUZ.D_E_L_E_T_ = ' ' "
	cSQL  +=        " AND NUZ.NUZ_FILIAL = '" + xFilial('NUZ') + "' "
	cSQL  +=        " AND NYB.NYB_FILIAL = '" + xFilial('NYB') + "' "
	cSQL  +=        " AND NOT EXISTS (SELECT 1 "
	cSQL  +=                        " FROM "+RetSqlName("NYD")+" NYD "
	cSQL  +=                        " WHERE NYD_CTPASJ = '"+ cTipoAs + "' "
	cSQL  +=                          " AND NYD_CAMPO = NUZ.NUZ_CAMPO "
	cSQL  +=                          " AND NYD.D_E_L_E_T_ = ' ') "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .T.)

	While !(cAlias)->( EOF() )
		aAdd(aRet,{(cAlias)->NUZ_CAMPO,(cAlias)->NUZ_DESCPO})
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J108CfgTab(cTabela, cTipoAs)

Função que verifica se a tabela recebida como parâmetro possui configuração de campos ou não.

Uso Geral.

@param cTabela Nome da Tabela
@param cTipoAs Código do tipo de assunto jurídico

@return lRet .T. - Configuração, .F. - Não possui configuração

@author André Spirigoni Pinto
@since 25/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108CfgTab(cTabela, cTipoAs)
Local lRet   := .F.
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := ""

cSQL  := "SELECT NYC.NYC_TABELA FROM "+ RetSqlname('NYC') +" NYC "
cSQL  += " WHERE NYC.D_E_L_E_T_ = ' ' "
cSQL  +=   " AND NYC.NYC_TABELA = '" + cTabela + "'"
cSQL  +=   " AND NYC.NYC_FILIAL = '" + xFilial('NYC') + "'"

If cTabela $ "NSZ/NTA/NT4"
	lRet := .T.
Else
	cAlias := GetNextAlias()
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .T.)

	While !(cAlias)->( EOF() )
		lRet := .T.
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108NW8()
Função utilizada para pegar a lista de todos os valores históricos
dos valores atualizáveis
Uso Geral.
@Return 	Array com os campos da NW8
@author André Spirigoni Pinto
@since 20/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108NW8()
Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local aArea   := GetArea()
Local aCampos := {}

cQuery := "SELECT DISTINCT NW8_CAMPH CAMPH FROM "+RetSqlName("NW8")+" NW8 "+ CRLF
cQuery += " WHERE NW8_FILIAL = '"+xFilial("NW8")+"' AND NW8.D_E_L_E_T_ = ' ' AND NW8.NW8_CAMPH <> ''"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )

	aAdd(aCampos,Substr(AllTrim( (cAlias)->CAMPH ),1,At('_',AllTrim( (cAlias)->CAMPH ))))
	(cAlias)->( dbSkip() )

End

(cAlias)->( dbcloseArea() )

RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108WaMes()
Função utilizada para determinar se o campo de ano mes deve estar habilitado ou não.
Uso Geral.
@Return 	Array com os campos da NW8
@author André Spirigoni Pinto
@since 20/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108WaMes(aValores, aCampos, lAnoMes)
Local lRet := .F.
Local nI

If lAnoMes
	For  nI := 1 to len(aCampos)
		If (aScan(aValores,{|x| At(x,aCampos[nI][3])>0}) > 0)
			lRet := .T.
			Exit
		Endif
	Next nI
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Vld()
Função utilizada para validar se a exportação pode prosseguir ou não.
Uso Geral.
@Return 	Array com os campos da NW8
@author André Spirigoni Pinto
@since 20/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA108Vld(lAnoMes,cAnoMes, aValores, oGrupList)
Local lRet       := .T.
Local lCmpAnoMes := JA108WaMes(aValores,oGrupList:aCmpSel,lAnoMes)

If lRet .And. lAnoMes
	lRet := ((lCmpAnoMes .And. !Empty(cAnoMes)) .Or. (!lCmpAnoMes))
	If !lRet
		alert(STR0061) //"É obrigatório informar um ano-mês de referência quando uma tabela de histórico de valores é escolhida. Verificar."
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCondicao(aSQL, cNSZName, cFrom, aTabApl)
Função utilizada para pegar todas as condições refernte a tabela a
ser utilizada para a montagem do SQL da pesquisa.
Uso Geral.

@Param	aSQL	  - Array com todas as condições dos campso a serem
			        utilizados no filtro.
@Param cNSZName - Nome da tabela NSZ.
@Param cFrom	  - Clausula From para evitar a inclusão de Exists desnecessários
@Param cEntFilial Entidade para relacionar Filial.
@Return cCondicao	todas as condições referente a tabela.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetCondicao(aSQL, cNSZName, cFrom, aTabsApl, cEntFilial)
Local cCondicao  := " "
Local nI         := 0
Local nA         := 0
Local nFound     := 0
Local nQtd, aAux := {}

Default cFrom := ''

	nQtd := LEN(aSQL)
	For nI := 1 to nQtd

		If nI == 1
			aAdd(aAux, {aSQL[nI][1], aSQL[nI][2]} )
		Else
			nFound := aScan(aAux, { |aX| ALLTRIM(aX[1]) == ALLTRIM(aSQL[nI][1]) })

			If nFound > 0
				aAux[nFound][2] += " " + aSQL[nI][2] + " "
			Else
				aAdd(aAux, {aSQL[nI][1], aSQL[nI][2]})
			EndIf
		EndIf
	Next

	nQtd := LEN(aAux)
	For nI := 1 to nQtd
		IF aAux[nI][1] == cNSZName .OR. aAux[nI][1] $ cFrom
			nA := JArrIndex(aTabsApl, aAux[nI][1])

			If nA > 0
				If "SELECT" $ UPPER(aAux[nI][2])
					cCondicao += aAux[nI][2]
				Else
					cCondicao += StrTran(aAux[nI][2],aTabsApl[nA][1], aTabsApl[nA][2])
				EndIf
			Else
				cCondicao += aAux[nI][2] +" "
			EndIf

		Else
			cCondicao += JurGtExist(aAux[nI][1], aAux[nI][2],cEntFilial, .T.)
		EndIf
	Next

	aSize(aAux,0)

Return cCondicao


//-------------------------------------------------------------------
/*/{Protheus.doc} VerRestricao(cApelido)
Inclusão da restrição de escritório

@param cApelido  Apelido da tabela NSZ

@author SIGAJURI
@since
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VerRestricao(cApelido)
Local cSQL       := ''
Local cRestEscr  := ''
Local cRestArea  := ''

//Restricao de escritorio
cRestEscr := JurSetESC()
If  !( Empty(cRestEscr) )
  cSQL += " AND " + cApelido + ".NSZ_CESCRI IN (" + cRestEscr + ")" + CRLF
EndIf

//Restricao de area
cRestArea := JurSetAREA()
If  !( Empty(cRestArea) )
	cSQL += " AND " + cApelido + ".NSZ_CAREAJ IN (" + cRestArea + ")" + CRLF
EndIf

Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} J108FESPE
Função que valida se já existem tabelas de agrupamento na fila e sugere
ao usuário se ele quer trazer apenas o último registro ou o primeiro.

@param oGrupList    Objeto que representa o listbox

@author Juliana Iwayama Velho
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108FESPE(aEspec,oObj1,oObj2,aOrigem,aDestino, lRem)
Local oDlgFil, oRadio
Local oItem    := Nil
Local lRet     := .T.
Local nRadio   := 1
Local aItems   := {STR0063,STR0064} //'Último Registro'/"Primeiro Registro"
Local nItem    := 0
Local cTabela  := ''
Local nPosFilt := 0
Local aDestDist:= {}

//valida se o método está sendo chamado na configuração de exportação ou item a item
If valtype(oObj1) == "O"
	If oObj1:nAT <= Len(aOrigem)
		oItem := aOrigem[oObj1:nAT]
	EndIf
ElseIf valtype(oObj1) == "A"
	oItem := oObj1
Endif

If aScan(aDestino, {|x| Len(x) == 15  }) == 0 .And. Len(aEspec) > 0
	aEspec := {}
EndIf

aDestDist := JArrayDist(aDestino)

If(Len (oItem) > 5) //Verifica se é uma formula
	//Valida se o campo está sendo removido da lista.
	if (nItem := aScan(aEspec,{|x| x[3] == oItem[3] .And. x[7] == oItem[7]})) > 0
		lRet := .T.
		aDel(aEspec,nItem)
		aSize(aEspec,Len(aEspec)-1)
	Else
		//Ajusta o nome da tabela
		if oItem[4] == "NSZ"
			cTabela := oItem[5]
		Else
			cTabela := oItem[4]
		Endif
		//valida se já existe itens nos filtros especiais e se a tabela é a mesma
		If lRet .And. ;
		  !lRem .And. ;
		  oItem[12] == .T. .And. ;
		  Len(aDestDist) == 1 .And. ;
		  !(aScan(aDestDist, oItem[4]) > 0 .OR. aScan(aDestDist, oItem[5]) > 0)
			nPosFilt := aScan(aDestino, {|x| Len(x) == 15  }) //Verifica se já existe agrupamento filtrado e indica qual item foi
			//
			If Empty(aEspec)
				If Len(oItem) == 15
					aAdd(aEspec,oItem)
				ElseIf nPosFilt > 0
					aAdd(aEspec,aDestino[nPosFilt])
				Else
					//Verfica se não está salvando configura, para emitir está pergunta
					If !IsInCallStack("JA108NVCFG") .And. ApMsgYesNo(I18N(STR0065,{JurX2Nome(cTabela)})) //"Já existe outra tabela com agrupamento na lista. Deseja usar funções de agrupamento para a tabela de #1 ?"

						oDlgFil := MSDialog():New(180,180,300,580, STR0066,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Agrupamento"
						oRadio := TRadMenu():New(10,10,aItems,{|u|Iif (PCount()==0,nRadio,nRadio:=u)},oDlgFil,,,,,,,,100,12,,,,.T.)

						Define SButton From 40, 155 Type 2 Enable Of oDlgFil Action (lRet:= .F., oDlgFil:End())
						Define SButton From 40, 110 Type 1 Enable Of oDlgFil Action (aAdd(oItem,nRadio), aAdd(aEspec,oItem), oDlgFil:End())

						oDlgFil:Activate()
					Else
						lRet := .F.
					Endif
				EndIf
			EndIf
		Else
			If Len(oItem) == 15
				aAdd(aEspec,oItem)
			ElseIf lRet .And. !lRem .And. oItem[12] .AND. ;
				aScan(aEspec,{|x| (x[5] != oItem[5] .AND. (x[4] == oItem[5] .OR. x[5] == oItem[4])) .OR. ;
				                  (x[5] == oItem[5] .AND. x[4] == oItem[4]) }) > 0
				//aScan(aEspec,{|x| (x[4] == oItem[5] .And. x[6] == oItem[7]) .Or. (x[5] == oItem[5] .And. x[7] == oItem[7]) .Or. (x[7] == oItem[6] .And. x[5] == oItem[4]) .Or. (x[4] == oItem[6] .And. x[4] == oItem[4])  }) > 0 .And. aScan(aEspec,{|x| x[3] == oItem[3] .And. x[7] == oItem[7] }) == 0
				aAdd(oItem,aEspec[1][15])
				aAdd(aEspec,oItem)
			ElseIf !lRem .And. oItem[12] == .T. .And. !Empty(aEspec)
				If !(aEspec[1][5] == oItem[5] .Or. aEspec[1][5] == oItem[4]) .AND. (aScan(aDestDist, oItem[4]) == 0 .AND. aScan(aDestDist, oItem[5]) == 0)
					lRet := .F.
					Alert(STR0067) //"Você não pode utilizar funções de agrupamento para mais de uma tabela ao mesmo tempo !"
				EndIf
			Endif
		EndIf
	Endif
Else
	if (nItem := aScan(aEspec,{|x| x[2] == oItem[2] })) > 0 ////Valida se a formula está sendo removido da lista.
		lRet := .T.
		aDel(aEspec,nItem)
		aSize(aEspec,Len(aEspec)-1)
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J108FEXTR
Função que habilita filtros extras para tabelas com agrupamento.

@param aEspec    Array com os campos de filtros especiais
@param aDestino  Array com os campos escolhidos para aparecer na exportação

@author André Spirigoni Pinto
@since 04/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108FEXTR(aEspec,aCamposSel)
Local oDlgFil, oRadio
Local lRet    := .T.
Local nRadio  := 1
Local nItem   := 0
Local cTabela := ''
Local aItems  := {STR0063,STR0064} //'Último Registro'/"Primeiro Registro"
Local nCt

For nCt := 1 to len(aCamposSel)
	If(Len (aCamposSel[nCt]) > 5) //Verifica se é uma formula
		if aCamposSel[nCt][12] == .T.
			if (nItem := aScan(aEspec,{|x| x[3] == aCamposSel[nCt][3] })) == 0
				nItem := nCt
				Exit
			Endif
		Endif
	EndIf
Next

lRet := (nItem > 0)

if lRet .And. aScan(aCamposSel, {|x| Len(x) == 15  }) > 0
	lRet := .F.
Endif

if nItem == 0 .Or. !lRet
	lRet := .F.
Else
	cTabela := aCamposSel[nItem][5]
Endif

if (lRet)
	oDlgFil := MSDialog():New(180,180,300,580, STR0068 + JurX2Nome(cTabela),,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Filtro Agrupamento: "
	oRadio := TRadMenu():New(10,10,aItems,{|u|Iif (PCount()==0,nRadio,nRadio:=u)},oDlgFil,,,,,,,,100,12,,,,.T.)

	Define SButton From 40, 155 Type 2 Enable Of oDlgFil Action (lRet:= .F., oDlgFil:End())
	Define SButton From 40, 110 Type 1 Enable Of oDlgFil Action (JAtuPriUlt(cTabela, @aCamposSel, @aEspec, nRadio) , oDlgFil:End())
	oDlgFil:Activate()
Else
	Alert(STR0069) //"Já existe um filtro no agrupamento configurado ou não existe campo com agrupamento selecionado."
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J108ValCmpAg 
Função que avalia os campos com filtros de agrupamento.

@param aEspec    Array com os campos de filtros especiais
@param nContF    Número da linha
@param lFila     Indica se vem da fila de impressão	
@param cThread   Conteúdo da thread utilizada na gravação da fila de impressão
@param aFiltro   Filtros a serem incrementados

@since 16/07/2021
/*/
//-------------------------------------------------------------------
Function J108ValCmpAg(aEspec, nContF, lFila, cThread, aFiltro )
Local cQueryM    := ""
Local cEspec     := GetNextAlias()
Local cVlrCampo  := ''
Local cTitCampo  := ''
Local nE         := 0
Local cRec       := "RECNO"
Local cTab       := ""
Local cCampo     := ""
Local cLinha     := ""
Local aCEspec    := aClone(aEspec)
Local cCpoMem    := "" //nome do campo com o conteúdo do memo convertido em caracter
Local cSzMem     := "" //nome do campo com o tamanho do campo memo para validação de existe informação
Local aValCmpAgr := {}

Default aFiltro := {}
 
	If !Empty(aEspec) .And. nContF == 1 //valida se existe campos especiais e se estamos na primeira linha

		cLinha  := ''
		cQueryM := JA108GSQL(aCEspec,.T. /*lCamposAg*/,.T. /*lIncrSQL*/, aFiltro, lFila, {} /*aEspec*/,;
		                    /*nAgrupa*/, /*lFiltFili*/, /*cEntFilial*/, cThread)

		cQueryM := ChangeQuery(cQueryM)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryM),cEspec,.T.,.T.)

		Do While !(cEspec)->(EOF())
			For nE := 1 to len(aEspec)
				cVlrCampo := ''
				cTitCampo := AllTrim(SubStr( AllTrim(aEspec[nE][3]), J108RetUnd( AllTrim(aEspec[nE][3]) )+1, 6 )+AllTrim(Str(nE)))

				//Formata campo de data
				If aEspec[nE][9] == 'D'
					TcSetField( cEspec, (cEspec)->(cTitCampo), 'D', 8, 0 )
				EndIf

				If aEspec[nE][9] == 'M'
					cTab   := AllTrim(aEspec[nE][5])
					cCampo := AllTrim(aEspec[nE][3])

					nRecno := (cEspec)->(&(aEspec[nE][7]+cRec))

					//informações memo
					cCpoMem := ("MEM_"+cTitCampo)
					cSzMem := ("SZ_"+cTitCampo)

					If  nRecno > 0
						if (cEspec)->(FieldPos(cSzMem)) > 0 //valida se existe o campo de tamanho do CLOB do Oracle
							//valida se o tamanho do campo é maior que 0 e menor que 4000 para não precisar obter o memo
							if (cEspec)->(FieldGet(FieldPos(cSzMem))) > 0 .And. (cEspec)->(FieldGet(FieldPos(cSzMem))) <= 4000
								cVlrCampo := (cEspec)->(FieldGet(FieldPos(cCpoMem)))
							Elseif (cEspec)->(FieldGet(FieldPos(cSzMem))) == 0
								cVlrCampo := ""
							Else
								&(cTab)->( dbGoTo( nRecno ))
								cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
							Endif
						Else
							//se não existe o campo do oracle, fazer a busca via dbgoto
							&(cTab)->( dbGoTo( nRecno ))
							cVlrCampo := &(cTab)->(FieldGet(FieldPos(cCampo)))
						Endif
					Else
						cVlrCampo := "-"
					EndIf
				Else
					If aEspec[nE][9] == 'N'
						cVlrCampo := AllTrim(cValToChar( (cEspec)->(FieldGet(FieldPos(cTitCampo))))) +">"
					ElseIf (!Empty(aEspec[nE][14])) //Valida se tem lista de opções
						cVlrCampo := JCboxValue(AllTrim(aEspec[nE][14]),(cEspec)->(FieldGet(FieldPos(cTitCampo)) ))
					Else
						cVlrCampo := cValToChar( (cEspec)->(FieldGet(FieldPos(cTitCampo))) )
					Endif
				EndIf

				nPos := aScan(aValCmpAgr, {|x| x[1] == (cEspec)->(NSZ_FILIAL) .And. x[2] == (cEspec)->(NSZ_COD)})
				If nPos > 0
					aAdd(aValCmpAgr[nPos],{cTitCampo, aEspec[nE][9], cVlrCampo, aEspec[nE][3]})
				Else 
					aAdd(aValCmpAgr,{(cEspec)->(NSZ_FILIAL), (cEspec)->(NSZ_COD),{cTitCampo, aEspec[nE][9], cVlrCampo, aEspec[nE][3]}})
				EndIf
				
			Next
			(cEspec)->( DbSkip() )
		EndDo

		(cEspec)->( dbCloseArea() )
	EndIf
	

	aSize(aCEspec,0)
Return aValCmpAgr


//-------------------------------------------------------------------
/*/{Protheus.doc} J108GEXLS
Função que monta as linhas e colunas dos campos com agrupamento

@param aEspec     Array com os campos de filtros especiais
@param nContF     Número da linha
@param cCodigo    Código do assunto jurídico
@param aSoma      Array de campos de valores a serem somados no agrupamento
@param lSoma      Somatoria do agrupamento?
@param lGar1      Mostrar os valores das garantias?
@param aGar1      Array com os valores de garantia
@param cFilOri    Filial de origem
@param oPrtXlsx   Objeto FwPrinterXlsx da exportação
@param nLinha     Número da linha a ser adicionada
@param nCol       Número da coluna a ser adicionada
@param cThread    Conteúdo da thread utilizada na gravação da fila de impressão
@param aValCmpAgr Array com o conteúdo dos campos de agrupamento 
                  aValCmpAgr[1][1] filial
                  aValCmpAgr[1][2] cajuri
                  aValCmpAgr[1][3] 
                  aValCmpAgr[1][3][1] nome campo -> DESC3
                  aValCmpAgr[1][3][2] tipo campo -> "C"
                  aValCmpAgr[1][3][3] conteúdo -> "exemplo"

@since 16/07/2021
/*/
//-------------------------------------------------------------------
Function J108GEXLS(aEspec, nContF, cCodigo, aSoma, lSoma, lGar1, aGar1, cFilOri, oPrtXlsx, nLinha, nCol, aValCmpAgr )

Local nJurosG    := 0
Local nLevanG    := 0
Local nSaldoFG   := 0
Local aSaldo     := {}
Local nG         := 0
Local cVlrCampo  := ""
Local lRet       := .T.

Default aValCmpAgr := {}

	oPrtXlsx:SetBorder(.T./*lLeft*/, .T./*lTop*/, .T./*lRight*/, .T./*lBottom*/, FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)

	If !Empty(aValCmpAgr)
		cVlrCampo := aValCmpAgr[3]
	EndIf
	JurCellFmt(@oPrtXlsx, aEspec[9])
	If aEspec[9] == 'N'
		oPrtXlsx:SetNumber(nLinha, nCol, Val(cVlrCampo))
	Else
		If Empty(cVlrCampo)
			oPrtXlsx:SetValue(nLinha, nCol, "-")
		Else
			oPrtXlsx:SetValue(nLinha, nCol, AllTrim( cVlrCampo ))
		EndIf
	EndIf

	If aEspec[9] == 'N' .And. !Empty(aValCmpAgr)
		If (lSoma)
			aAdd(aSoma,{cFilOri+cCodigo, aValCmpAgr[1] ,IIF(!Empty(cVlrCampo),val(cVlrCampo),0 ),aEspec[3]})
		EndIf
	EndIf

	//Se foi escolhida a opção de mostrar os valores das garantias, gera levantamento
	If lGar1 .And. aEspec[3] == 'NT2_VALOR'

		aSaldo := JA098CriaS(cCodigo, cFilOri)

		JurCellFmt(@oPrtXlsx, "N")
		For nG := 1 to Len(aSaldo)
			If Len(aSaldo[nG]) >= 7
				If aSaldo[nG][4] == 'J'
					nJurosG	:= nJurosG + aSaldo[nG][5]
				ElseIf aSaldo[nG][4] == 'A'
					nLevanG	:= nLevanG + aSaldo[nG][6]
				ElseIf aSaldo[nG][4] == 'SF'
					nSaldoFG:= nSaldoFG + aSaldo[nG][5]
				EndIf
			EndIf
		Next nG

		oPrtXlsx:SetNumber(nLinha, nCol+1, nJurosG)
		oPrtXlsx:SetNumber(nLinha, nCol+2, nLevanG)
		oPrtXlsx:SetNumber(nLinha, nCol+3, nSaldoFG)

		If aScan(aGar1,{|x| x[1] == cCodigo}) == 0
			aAdd(aGar1,{cCodigo, nJurosG, nLevanG, nSaldoFG})
		EndIf
	EndIf

	//valida se é preciso preencher o espaço dos campos especiais com espaços em branco
	If nContF > 1 .And. !Empty(aEspec)
		
		JurCellFmt(@oPrtXlsx)
		oPrtXlsx:SetValue(nLinha, nCol, "")
	EndIf

	aSize(aSaldo,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J108GEXTR
Função que avalia os campos com filtros de agrupamento.

@param aEspec     Array com os campos de filtros especiais
@param nContF     Número da linha
@param cCodigo    Código do assunto jurídico
@param lFila      Número da linha
@param nHdl       Número do cabeçalho
@param aSoma      Array de campos de valores a serem somados no agrupamento
@param lSoma      Somatoria do agrupamento?
@param lGar1      Mostrar os valores das garantias?
@param aGar1      Array com os valores de garantia
@param cFilOri    Filial de origem
@param cThread    Conteúdo da thread utilizada na gravação da fila de impressão
@param aValCmpAgr Array com o conteúdo dos campos de agrupamento 
                  aValCmpAgr[1][1] filial
                  aValCmpAgr[1][2] cajuri
                  aValCmpAgr[1][3] 
                  aValCmpAgr[1][3][1] nome campo -> DESC3
                  aValCmpAgr[1][3][2] tipo campo -> "C"
                  aValCmpAgr[1][3][3] conteúdo -> "exemplo"

@since 10/01/2020
/*/
//-------------------------------------------------------------------
Function J108GEXTR(aEspec, nContF, cCodigo, lFila, nHdl, aSoma, lSoma, lGar1, aGar1, cFilOri, cThread, aValCmpAgr, lRelOk, cMsgErroRel )
Local cFinal    := ""
Local cLinha    := ""
Local lRet      := .T.
Local aSaldo    := {}
Local nG        := 0
Local nJurosG   := 0
Local nLevanG   := 0
Local nSaldoFG  := 0

Default cFilOri     := ''
Default aValCmpAgr  := {}
Default lRelOk      := .T.
Default cMsgErroRel := ""

	If !Empty(aEspec) .And. nContF == 1 //valida se existe campos especiais e se estamos na primeira linha

		cLinha  := ''

		If !Empty(aValCmpAgr)
			cVlrCampo := aValCmpAgr[3]
		EndIf
		//Formata campo de data
		If aEspec[9] == 'D'
			cClasse  := "  <td class=x144>"
		ElseIf aEspec[9] == 'N'
			cClasse := 	" <td class=xl41 x:num="
		Else
			cClasse  := " <td class=xl31>"
		EndIf

		cLinha := cClasse + AllTrim ( cVlrCampo )+ "</td>"

		If aEspec[9] == 'N' .And. Len(aValCmpAgr) > 0
			if (lSoma)
				aAdd(aSoma,{cFilOri+cCodigo, aValCmpAgr[1], IIF(!Empty(cVlrCampo), val(cVlrCampo), 0 ), aEspec[3]})
			Endif
		Endif

		If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
			If !JurMsgErro(STR0017) //"Erro ao gerar linha do arquivo"
				lRet := .F.
				lRelOk := .F.
				cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
			EndIf
		EndIf

		cLinha := ""

		//Se foi escolhida a opção de mostrar os valores das garantias, gera levantamento
		If lGar1 .And. aEspec[3] == 'NT2_VALOR'

			aSaldo := JA098CriaS(cCodigo, cFilOri)

			For nG := 1 to Len(aSaldo)
				If Len(aSaldo[nG]) >= 7
					If aSaldo[nG][4] == 'J'
						nJurosG	:= nJurosG + aSaldo[nG][5]
					ElseIf aSaldo[nG][4] == 'A'
						nLevanG	:= nLevanG + aSaldo[nG][6]
					ElseIf aSaldo[nG][4] == 'SF'
						nSaldoFG:= nSaldoFG + aSaldo[nG][5]
					EndIf
				EndIf
			Next nG

			cClasse := 	" <td class=xl41 x:num="

			cLinha  := cClasse + AllTrim(Str(nJurosG))+"></td>"
			cLinha  += cClasse + AllTrim(Str(nLevanG))+"></td>"
			cLinha  += cClasse + AllTrim(Str(nSaldoFG))+"></td>"

			If aScan(aGar1,{|x| x[1] == cCodigo}) == 0
				aAdd(aGar1,{cCodigo, nJurosG, nLevanG, nSaldoFG})
			EndIf

			If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
				JurMsgErro(STR0017) //"Erro ao gerar linha do arquivo"
				lRet := .F.
				lRelOk := .F.
				cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
			EndIf
		EndIf
	Endif

	//valida se é preciso preencher o espaço dos campos especiais com espaços em branco
	if nContF > 1 .And. !Empty(aEspec)
		cClasse  := " <td class=xl31>"
		cLinha := cClasse + '' + "</td>"
		cFinal := ''
		aEval(aEspec,{|| cFinal += cLinha})

		If FWrite(nHdl, cFinal, Len(cFinal)) <> Len(cFinal)
			If !JurMsgErro(STR0017) //"Erro ao gerar linha do arquivo"
				lRet := .F.
				lRelOk := .F.
				cMsgErroRel   := STR0017  //"Erro ao gerar linha do arquivo"
			EndIf
		EndIf
	Endif

	aSize(aSaldo,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA108Formu
Função para as formulas na tabela cadastradas para a tabela
Uso Geral.
@param  cTabela   Nome da tabela
@param  cNomeAp   Nome do apelido
@param  cNQ2Cod   Código relação exportação

@return cQueryForm  Lista de formulas

@author Wellington Coelho
@since 03/06/15
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function JA108Formu(cTabela,cNomeAp,cNQ2Cod)
Local cQueryFrm := ""

	cQueryFrm += " SELECT NZJ_DESC "
	cQueryFrm +=       ", NZJ_FUNC "
	cQueryFrm +=       ", NZJ_PARAM "
	cQueryFrm +=       ", NQ2_APELID "

	cQueryFrm +=   " FROM " + RetSqlName("NZJ") + " NZJ "

	cQueryFrm += " INNER JOIN " + RetSqlName("NQ2") + " NQ2 "
	cQueryFrm +=    " ON (NQ2.NQ2_COD = NZJ.NZJ_CRELAC "
	cQueryFrm +=         " AND NQ2.NQ2_FILIAL = '"+xFilial("NQ2")+"' "
	cQueryFrm +=         " AND NQ2.D_E_L_E_T_ = ' ') "

	cQueryFrm += " WHERE NZJ.NZJ_FILIAL = '" + xFilial("NZJ") + "' "
	cQueryFrm +=   " AND NZJ.D_E_L_E_T_ = ' ' "
	cQueryFrm +=   " AND NZJ.NZJ_CRELAC = '" + cNQ2Cod + "' "
	cQueryFrm +=   " AND NQ2.NQ2_TABELA = '" + cTabela + "' "
	cQueryFrm +=   " AND NQ2.NQ2_APELID = '" + cNomeAp + "' "

Return cQueryFrm
//-------------------------------------------------------------------
/*/{Protheus.doc} setCboxValue()
Trata o valor das colunas quando são do tipo lista de opções.

@param cCbox lista de opções
@param cValue Valor preenchido.

@return cValor Retorna a descrição do valor da lista de opções.

@author André Spirigoni Pinto
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCboxValue(cCbox, cValue)
Local cValor := ''
Local aTemp  := {}
Local nCti

If ( !Empty(cCbox) )

	aTemp := StrTokArr(cCbox,';')

	if (Len(aTemp) > 0)
		For nCti := 1 To Len(aTemp)
			aTemp[nCti] := StrTokArr(aTemp[nCti],'=')
		Next

		nI:= aScan( aTemp, { |aX| aX[1] == cValue } ) // Resgata a informação de campos combo

		If nI > 0
			cValor := aTemp[nI][2]
		Else
			cValor := cValue
		Endif
	Endif

EndIf

//Limpa o array
aSize(aTemp,0)

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J108FltExt(aExtra, aFiltro)
Trata os filtros extras

@param aExtra array de campos para o filtro
@param aFiltro array de filtro

@return cQuery retorno do filtro em query

@author Beatriz Gomes
@since 01/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J108FltExt(aExtra, aFiltro, cApelido)

Local nY       := 0
Local nPosTab  := 0
Local nPosApl  := 0
Local nFiltro  := 0
Local cQuery   := ''
Local cTabNSZ  := ''
Local cTabAgr  := ''
Local cTabApl  := ""
Local cMinMax  := ""

Default cApelido := ''

For nY := 1 to len(aExtra)

		// valida se a tabela possui relação com a NSZ
		if (aExtra[nY][4] == "NSZ")
			nPosTab := 5
			nPosApl	:= 7
		Else
			nPosTab := 4
			nPosApl	:= 6
		Endif

		If aExtra[nY][15]==1 //Verifica se o filtro é por ultimo ou primeiro registro
			cMinMax := 'MAX'
		Else
			cMinMax := 'MIN'
		EndIf

		if !Empty( JURSX9(aExtra[nY][nPosTab], "NSZ") )
			cTabAgr := aExtra[nY][nPosTab]
			cTabApl := aExtra[nY][nPosApl]
			cTabNSZ := RetSqlName("NSZ")

			//Deve filtrar quando tiver MAX\MIN com a mesma condição do JOIN, para trazer o valor de garantia
			cQuery += " INNER JOIN (  SELECT " + RetSqlName("NSZ") + ".NSZ_COD , " + cTabNSZ + ".NSZ_FILIAL , "
			cQuery +=                        cMinMax + "(" + RetSqlName(cTabAgr) + ".R_E_C_N_O_) R_E_C_N_O_ "
			cQuery +=               " FROM " + cTabNSZ + " LEFT JOIN " + RetSqlName(cTabAgr)
			cQuery +=               " ON " + cTabNSZ + ".NSZ_COD = " + RetSqlName(cTabAgr) + "." + cTabAgr + "_CAJURI"
			cQuery +=                   " AND " + cTabNSZ + ".NSZ_FILIAL = " + RetSqlName(cTabAgr) + "." + cTabAgr + "_FILIAL"
			cQuery +=                   " AND " + RetSqlName(cTabAgr) + ".D_E_L_E_T_ = ' '"
			cQuery +=               " WHERE " + J108DtaFlt(RetSqlName(cTabAgr),.T.) + " = ( SELECT " + cMinMax + "(SUB." + J108DtaFlt(RetSqlName(cTabAgr)) + ")"
			cQuery +=                                                                     " FROM " + RetSqlName(cTabAgr) + " SUB"
			cQuery +=                                                                     " WHERE SUB." + cTabAgr + "_CAJURI = " + cTabNSZ + ".NSZ_COD"
			cQuery +=                                                                     " AND SUB." + cTabAgr + "_FILIAL = " + cTabNSZ + ".NSZ_FILIAL"
			cQuery +=                                                                     " AND SUB.D_E_L_E_T_ = ' ' "
			If cTabAgr == "NT2"
				cQuery +=                                                                     " AND SUB.NT2_MOVFIN = '1'"
			EndIf
			cQuery +=                                                                     " )"

			If cTabAgr == "NT2"
				cQuery += 				" AND " + RetSqlName(cTabAgr) + ".NT2_MOVFIN = '1'"
			EndIf

			nFiltro := 0
			While (nFiltro := aScan(aFiltro,{|x| Left(x[1],3) == cTabAgr },nFiltro+1)) > 0
				if At(aFiltro[nFiltro][2],cQuery) == 0
					cQuery += CRLF + aFiltro[nFiltro][2]
				Endif
			End

			cQuery +=            	" GROUP BY " + cTabNSZ + ".NSZ_COD, " + cTabNSZ + ".NSZ_FILIAL, " + J108DtaFlt(RetSqlName(cTabAgr),.T.)
			cQuery +=			 " ) MIN_MAX"

			cQuery += " ON " + cApelido + ".NSZ_COD = MIN_MAX.NSZ_COD AND " + cApelido + ".NSZ_FILIAL = MIN_MAX.NSZ_FILIAL"
			cQuery += 		" AND (MIN_MAX.R_E_C_N_O_ = " + cTabApl + ".R_E_C_N_O_ OR " + cTabApl + ".R_E_C_N_O_ IS NULL)"

			cQuery += CRLF
		Endif
	Next


Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J108DtaFlt(cTabela,lApelido)
Função que retorna o campo de data referente a tabela de agrupamento

@param cTabela Tabela para filtro
@param lApelido Retorna o campo com a tabela ?  .T. - Sim / .F. - Não

@return cData Campo de data referente a tabela

@author Beatriz Gomes
@since 26/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J108DtaFlt(cTabela,lApelido)
Local cData      := ''
Default lApelido := .F.

	If lApelido
		cData := cTabela + "."
	EndIF

	If 'NT2' $ cTabela//GARANTIA
		cData += 'NT2_DATA'
	ElseIf 'NT3' $ cTabela//DESPESA
		cData += 'NT3_DATA'
	ElseIf 'NT4' $ cTabela//ANDAMENTO
		cData += 'NT4_DTANDA'
	ElseIf 'NTA' $ cTabela//FOLLOW-UP
		cData += 'NTA_DTFLWP'
	ElseIf 'NYP' $ cTabela//ACORDOS
		cData += 'NYP_DATA'
	Else
		cData += 'R_E_C_N_O_'
	EndIf

Return cData

//-------------------------------------------------------------------
/*/{Protheus.doc} J108QryRsp(lFila)
Função para pegar todos os responsáveis dos fups filtrados.

@param lFila      - Verifica se a chamada é originaria na Fila de Impressão
@param aFiltro    - Lista de filtros a serem aplicados no relatório
@param cApProc    - Apelido da tabela NSZ (Utiliza da configuração de exportação personalizada)
@param aCamposSel - Campos selecionados para exportação
@param cThread    - Número da thread de execução do relatório na fila de impressão

@return aReturn Array com as informações do Select
                  [1] - Código do Responsável
                  [2] - Sigla do Responsável
                  [3] - Nome do Responsável
                  [4] - Código do Assunto Jurídico
                  [5] - Código do Follow-up

@author Willian Kazahaya
@since 04/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108QryRsp(lFila, aFiltro, cApProc, aCamposSel, cThread)
Local cAlResp  := GetNextAlias()
Local aReturn    := {}
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cChave     := ""
Local cPart      := ""
Local cNome      := ""
Local cSigla     := ""
Local cCajuri    := ""
Local cFup       := ""
Local aTabsApl   := J108ArrApl(aCamposSel)
Local nIdxNTA    := JArrIndex(aTabsApl, RetSqlName("NTA"))
Local cAplNTA    := aTabsApl[nIdxNTA][2]

	cQrySel := " SELECT RD0.RD0_CODIGO RspCod "
	cQrySel +=       " ,RD0.RD0_SIGLA  RspSig "
	cQrySel +=       " ,RD0.RD0_NOME   RspNom "
	cQrySel +=       " ," + cAplNTA + ".NTA_CAJURI AssJur "
	cQrySel +=       " ," + cAplNTA + ".NTA_COD    CodFup "

	cQryFrm := " FROM " + RetSqlName('NTE') + " NTE "
	cQryFrm +=        "INNER JOIN " + RetSqlName('RD0') + " RD0 ON (RD0.RD0_CODIGO = NTE.NTE_CPART "
	cQryFrm +=                                                " AND RD0.RD0_FILIAL = '" + xFilial('RD0') + "' "
	cQryFrm +=                                                " AND RD0.D_E_L_E_T_ = ' ' "
	cQryFrm +=                                                " AND NTE.D_E_L_E_T_ = ' ') "
	cQryFrm +=        " INNER JOIN " + RetSqlName('NTA') + " " + cAplNTA + " ON (" + cAplNTA + ".NTA_COD = NTE.NTE_CFLWP "
	cQryFrm +=                                                 " AND " + cAplNTA + ".NTA_FILIAL = '" + xFilial('NTA') + "' "
	cQryFrm +=                                                 " AND " + cAplNTA + ".D_E_L_E_T_ = ' ') "
	cQryFrm +=        " INNER JOIN " + RetSqlName('NSZ') + " "+ AllTrim(cApProc) + " ON ("+ AllTrim(cApProc) + ".NSZ_COD = " + cAplNTA + ".NTA_CAJURI "
	cQryFrm +=                                                                     " AND "+ AllTrim(cApProc) + ".NSZ_FILIAL = '" + xFilial('NSZ') + "' "
	cQryFrm +=                                                                     " AND "+ AllTrim(cApProc) + ".D_E_L_E_T_ = ' ') "
	cQryFrm +=         " LEFT  JOIN " + RetSqlName('NQN') + " NQN001 "
	cQryFrm +=                       " ON ( NQN001.NQN_FILIAL = '" + xFilial("NQN") + "' "
	cQryFrm +=                            " AND NQN001.NQN_COD = NTA001.NTA_CRESUL AND NQN001.D_E_L_E_T_ = ' ' ) "

	If lFila
		cQryFrm += J108FrmFil(cApProc, cThread)
	EndIf

	cQryWhr := J108SQLWhr(lFila,,aFiltro,cQryFrm,aTabsApl)

	cQuery := cQrySel + cQryFrm + cQryWhr

	cQuery := cQuery + " ORDER BY " + cAplNTA + ".NTA_CAJURI," + cAplNTA + ".NTA_COD"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlResp, .T., .T.)

	While !(cAlResp)->( EOF() )
		if Empty(cChave) .or. cChave != ((cAlResp)->AssJur + (cAlResp)->CodFup)

			if !Empty(cChave)
				aAdd( aReturn, { cPart, cSigla, cNome,cCajuri,cFup })
			Endif

			cChave   := ((cAlResp)->AssJur + (cAlResp)->CodFup)
			cPart    := AllTrim((cAlResp)->RspCod)
			cNome    := AllTrim((cAlResp)->RspNom)
			cSigla   := AllTrim((cAlResp)->RspSig)
			cCajuri  := AllTrim((cAlResp)->AssJur)
			cFup     := AllTrim((cAlResp)->CodFup)
		Else
			cPart    += " / " + AllTrim((cAlResp)->RspCod)
			cNome    += " / " + AllTrim((cAlResp)->RspNom)
			cSigla   += " / " + AllTrim((cAlResp)->RspSig)
		Endif

		(cAlResp)->( dbSkip() )

		if (cAlResp)->( EOF() ) //se for o último
			aAdd( aReturn, { cPart, cSigla, cNome,cCajuri,cFup} )
		Endif
	End

	((cAlResp)->( dbcloseArea() ))

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} J108GetNTE(aResp, cNtaCod, cField, oPrtXlsx, nLinha, nCol)
Função que concatena os dados do responsável

@param aResp - Array com os responsáveis
@param cNtaCod - Código do Follow-up
@param cField - Campo de retorno
                  [1] - Código do Participante (NTE_CPART/RDO_CODIGO)
                  [2] - Sigla do Participante (NTE_SIGLA/RD0_SIGLA)
                  [3] - Descrição do Participante (NTE_DPART/RD0_NOME)
@param oPrtXlsx  Objeto FwPrinterXlsx da exportação
@param nLinha    Número da linha a ser adicionada
@param nCol      Número da coluna a ser adicionada

@return aReturn Array com as informações do Select
                  [1] - Código do Responsável
                  [2] - Sigla do Responsável
                  [3] - Nome do Responsável
                  [4] - Código do Assunto Jurídico
                  [5] - Código do Follow-up

@author Willian Kazahaya
@since 04/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108GetNTE(aResp, cNtaCod, cField, oPrtXlsx, nLinha, nCol)
Local cLinha   := ''
Local cConcat  := ''
Local nField   := 0
Local nPos     := aScan(aResp, { |aX| cNtaCod == aX[5]})

Default oPrtXlsx  := Nil
Default nLinha := 0
Default nCol := 0

	If nPos > 0
		// Valida o campo
		Do Case
			Case cField == 'NTE_CPART'
				nField := 1
			Case cField == 'NTE_SIGLA'
				nField := 2
			Otherwise
				nField := 3
		End Case

		// Pega o valor do campo
		cConcat := aResp[nPos][nField]

	EndIf

	cLinha  += " <td class=xl31>" + SubString(cConcat,1,Len(cConcat)) +"</td>"

	If oPrtXlsx <> Nil
		JurCellFmt(@oPrtXlsx)
		oPrtXlsx:SetText(nLinha, nCol, SubString(cConcat,1,Len(cConcat)))
	EndIf

	// Limpa o Array
	If nPos > 1
		aDel(aResp, nPos)
		aSize(aResp, Len(aResp) -1)
	EndIf

Return cLinha

//-------------------------------------------------------------------
/*/{Protheus.doc} J108ArrApl(aCamposSel)
Monta um array com os apelidos das tabelas.

@param aCamposSel - Campos que foram selecionados

@return aReturn Array com as tabelas e seus apelidos
				  [1] - Nome original da tabela
				  [2] - Apelido da tabela

@author Willian Kazahaya
@since 12/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J108ArrApl(aCamposSel)
Local aReturn  := {}
Local aTabsIns := {}
Local nI       := 0
Local aTabelas := JA108TabF()
Local nPosAp   := 0
Local nPosTab  := 0

	For nI := 1 to Len(aCamposSel)
		If Len(aCamposSel[nI]) > 5
			If ( nPos := aScan( aTabelas, { |x| x[1] == aCamposSel[nI][4] } ) ) > 0
				nPosAp   := 6    //Apelido 1º nível
				nPosTab  := 4    //Tabela 1º nível
			ElseIf ( nPos := aScan( aTabelas, { |x| x[1] == aCamposSel[nI][5] } ) ) > 0
				nPosAp   := 7    //Apelido 2º nível
				nPosTab  := 5    //Tabela 2º nível
			EndIf

			If !aScan(aTabsIns, aCamposSel[nI][nPosTab])
				aAdd(aTabsIns, aCamposSel[nI][nPosTab])
				aAdd(aReturn, {RetSqlName(aCamposSel[nI][nPosTab]),aCamposSel[nI][nPosAp]})
			EndIf
		EndIf
	Next

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} JArrIndex
Retorna o index de um valor em um array

@param aFind  - Array que será percorrido
@param cTexto - Valor a ser encontrado

@return nRet - Index do valor encontrado

@author Abner Fogaça de Oliveira
@since 13/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JArrIndex(aFind, cTexto)
Local nRet := 0
Local nA   := 0

	For nA := 1 To Len(aFind)
		If aScan(aFind[nA],cTexto)
			nRet := nA
			Exit
		EndIf
	Next
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JArrayDist(aArr, nCond)
Varre o Array de campos para verificação dos agrupadores

@param aArr - Array com os campos (aCamposSel)
@Return aRet - Array com somente as tabelas

@author Willian.Kazahaya
@since 17/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JArrayDist(aArr, nCond)
Local aRet  := {}
Local nI    := 0

Default nCond := 1

	For nI := 1 To Len(aArr)
		If Len(aArr[nI]) > 5
			If nCond == 1 .AND. aArr[nI][12]
				If aArr[nI][4] == "NSZ" .And. aScan(aRet, aArr[nI][5]) == 0
					aAdd(aRet, aArr[nI][5])
				ElseIf aArr[nI][4] != "NSZ" .And. aScan(aRet, aArr[nI][4]) == 0
					aAdd(aRet, aArr[nI][4])
				EndIf
			EndIf
		EndIf
	Next

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAtuPriUlt(cTab, aCamposSel, aEspec, nOpc )
Atualiza a Agrupadora de todas as colunas dependentes da tabela alterada

@param cTab - Tabela a ser atualizada
@param aCamposSel - Array de campos do Destino
@param aEspec - Array dos Agrupadores
@param nOpc - Opção do Radio button

@Return lRet - Retorna se houve erro ao atribuir

@author Willian.Kazahaya
@since 17/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JAtuPriUlt(cTab, aCamposSel, aEspec, nOpc)
Local lRet := Empty(aEspec)
Local nI   := 0

	If lRet
		For nI := 1 To Len(aCamposSel)
			// Verifica se está agrupada e se a tabela é a tabela pai ou filha
			If (aCamposSel[nI][12]) .AND.;
				((aCamposSel[nI][4] == cTab) .OR. (aCamposSel[nI][5] == cTab))
				aAdd(aCamposSel[nI],nOpc)
				aAdd(aEspec, aCamposSel[nI])
			EndIf
		Next
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} HasRelNSZ(cTabela)
Verifica se a tabela tem relacionamento com a NSZ

@param cTabela - Tabela que irá retornar os relacionamentos

@Return lRet - Retorna se encontrou relacionamento com a NSZ

@author Willian.Kazahaya
@since 23/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function HasRelNSZ(cTabela)
Local lRet   := .F.
Local aRelac := {}

	aRelac := JURRELASX9(cTabela, .F., 2)

	lRet := aScan(aRelac, "NSZ") > 0

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DesmembFil(cFiltro)
Desmembra o filtro para pegar o apelido das tabelas

@param cFiltro - Filtro a ser incluido no Join

@Return aRet - Filtros desmembrados

@author Willian.Kazahaya
@since 23/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function DesmembFil(cFiltro, aFiltros)
Local aRet     := {}
Local nI       := 0
Local cApel    := ""

	cFiltro := StrTran(cFiltro," AND ","|")
	cFiltro := StrTran(cFiltro," OR ","|")

	aFiltros := JStrArrDst(cFiltro,"|")

	For nI := 1 to Len(aFiltros)
		cApel := SubStr(aFiltros[nI],1,At(".",aFiltros[nI])-1)
		If aScan(aRet,cApel) == 0
			aAdd(aRet, cApel)
		EndIf
	Next
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRowSize
Seta a largura da celula de acordo com o tipo do dado.

@param  oPrtXlsx    Objeto FwPrinterXlsx da exportação
@param  nColFrom    Coluna inicial a receber a formatação
@param  nColTo      Coluna final a receber a formatação
@param  cTpConteud  Tipo do dado
@param  cCampo      Nome do campo para obter o tamanho do X3
@param  nLenDescCab Quantidade de letras do titulo da celula
@param  lFormula    Indica se o campo é uma formula

@return lRet        Indica que a formatação foi setada

@since 19/01/2021
/*/
//-------------------------------------------------------------------
Function JurRowSize(oPrtXlsx, nColFrom, nColTo, cTpConteud, cCampo, nLenDescCab, lFormula)
Local lRet      := .F.
Local nWidth    := 0
Local nTamSx3   := 0

Default cCampo := ""
Default lFormula := .F.

	If !Empty(cCampo)
		nTamSx3 := TamSx3(cCampo)[1]
	EndIf

	If cTpConteud == "M"
		nWidth := 70
	Else
		If nLenDescCab > nTamSx3 
			//se o titulo do cabeçalho for maior que o X3_TAMANHO do campo, prevalesce o tamanho do titulo
			nWidth := nLenDescCab
		Else
			Do Case
				Case cTpConteud == "D"
					nWidth := 11
				Case cTpConteud == "N"
					nWidth := 18
				Otherwise // caso seja C
					nWidth := 40
					If nTamSx3 > 0 .And. nTamSx3 <= nWidth
						nWidth := nTamSx3
					EndIf
			EndCase
		EndIf
	EndIf

	If lFormula
		nWidth := 40
	EndIf

	lRet := oPrtXlsx:SetColumnsWidth(nColFrom, nColTo, nWidth)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCellFmt
Seta a formatação da célula de acordo com o tipo do dado.

@param  oPrtXlsx    Objeto FwPrinterXlsx da exportação
@param  cTpConteud  Tipo do dado
@param  cRowTipo    Indica o tipo de linha:
                    CONTEUDO
                    TITULO
                    TOTAL
                    CABECALHO

@return lRet        Indica que a formatação foi setada

@since 19/01/2021
/*/
//-------------------------------------------------------------------
Function JurCellFmt(oPrtXlsx, cTpConteud, cRowTipo)
Local lRet         := .F.
Local cFormat      := ""
Local oCellHorAl   := FwXlsxCellAlignment():Horizontal()
Local oCellVerAl   := FwXlsxCellAlignment():Vertical()
Local cHorAlign    := oCellHorAl:Center()
Local cVertAlign   := oCellVerAl:Center()
Local cTextColor   := "000000" /*preto*/
Local cBgColor     := "FFFFFF"/*branco*/
Local lTextWrap    := .F.

Default cTpConteud := ""
Default cRowTipo   := "CONTEUDO"

	Do Case
		Case cTpConteud == "D"
			cFormat := "dd/mm/yyyy"
		Case cTpConteud == "N"
			cFormat := "#,##0.00"
		Case cTpConteud == "M"
			cHorAlign := oCellHorAl:Left()
		Otherwise 
			cFormat := ""
	EndCase

	If cRowTipo == "TITULO"
		cTextColor := "FFFFFF"/*branco*/
		cBgColor := "0000FF"/*azul*/
	ElseIf cRowTipo == "CABECALHO" .Or. cRowTipo == "TOTAL"
		cTextColor := "000000" /*preto*/
		cBgColor := "A0A0A0" /*cinza*/
		lTextWrap := .T.
	EndIf

	lRet := oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, lTextWrap, 0, cTextColor, cBgColor, cFormat)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} vldFormula
Valida se a Formula usa cache ou não e retorna o valor do registro

@param  aFormulas:  Array contendo as fórmulas que já foram executadas na Rotina
			aFormulas[1]: Formula com parâmetros
			aFormulas[2]: Boolean que indica Verdadeiro para cache
			aFormulas[3]: Array com chave e valores da fórmula
@param  cFormula:   Descrição da fórmula
@param  cParams:    Descrição dos parâmetros
@param  aParams:    Array com parâmetros tratados 
@param  cFilProc:   Filial do registro posicionado
@param  cCajuri:    Código do assunto Jurídico
@param  cThread:    Número da thread

@return xValor:     resultado da execução da fórumula

@since 19/01/2021
/*/
//-------------------------------------------------------------------
Static Function vldFormula(aFormulas,cFormula, cParams, aParams, cFilProc, cCajuri, cThread)
Local xValor     := ""
Local nIdFormula := 0
Default cThread  := SubStr(AllTrim(Str(ThreadId())),1,4)

	// Valida se a fórmula á está no array e inclui se necessário
	nIdFormula := aScan(aFormulas, {|x| x[1] == cFormula + cParams} )

	If nIdFormula == 0
		aAdd(aFormulas, {cFormula + cParams,.F.,{}})
		nIdFormula := aScan(aFormulas, {|x| cValToChar(x[1]) == cFormula + cParams} )
		aAdd(aParams, 'All')
		aAdd(aParams, cThread)

		Eval(&("{|| xValor := "+ Alltrim(Strtran(JurLmpCpo(cFormula),"#",""))  +"(aParams)}"))
		aFormulas[nIdFormula][2] := ValType(xValor) == "A"

		If aFormulas[nIdFormula][2]
			aFormulas[nIdFormula][3] := xValor
		EndIf
	EndIf

	// Usa cache
	If aFormulas[nIdFormula][2]
		
		nPos := aScan(aFormulas[nIdFormula][3], {|x| x[1] == cFilProc + cCajuri  } )
		if nPos > 0
			xValor := aFormulas[nIdFormula][3][nPos][2]
			aDel(aFormulas[nIdFormula][3],nPos)
			aSize(aFormulas[nIdFormula][3], len(aFormulas[nIdFormula][3]) -1)
		else
			xValor := ' - '
		EndIf
	else
		xValor := Alltrim(Strtran(JurLmpCpo(cFormula),"#",""))
		Eval(&("{|| xValor := "+ Alltrim(Strtran(JurLmpCpo(cFormula),"#",""))  +"(aParams)}"))
	EndIf

Return xValor


//-------------------------------------------------------------------
/*/{Protheus.doc} J108OrderBy
Responsável por montar o order by, utilizando o apelido das tabelas
de acordo com a configuração da exportação personalidaza, para cada
campo recebido

@param  cFields - Campos que irão compor o order by
            (Ex.: "NTA_DTFLWP DESC,NTA_HORA DESC")

@return cRet - String com o order by dos campos recebidos
               (Ex.: "  ORDER BY NTA_DTFLWP DESC,NTA_HORA DESC")

@since 13/05/2022
/*/
//-------------------------------------------------------------------
Function J108OrderBy( cFields )

Local aFields  := STRTOKARR( cFields, ',' )
Local cApelido := ""
Local cTable   := ""
Local cRet     := ""
Local nI       := 0

	For nI := 1 to Len(aFields)

		If At(".", aFields[nI]) > 0
			cRet += ", " + aFields[nI]

		Else
			cTable := SubStr( aFields[nI], 1, At("_", aFields[nI]) -1 )

			If Len(cTable) == 2
				cTable := "S" + cTable
			EndIf

			cApelido := JurGetDados('NQ0', 2 , xFilial('NQ0') + cTable , 'NQ0_APELID')

			If Empty(cApelido)
				cApelido := cTable
			EndIf

			cRet += ", " + cApelido + "." + aFields[nI]
		EndIf

	Next nI

	If !Empty(cRet)
		cRet := " ORDER BY " + SubStr(cRet,2)
	EndIf

Return cRet
