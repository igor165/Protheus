#INCLUDE "plsa629.ch"
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"

Static aRecSE1 := {}

/*/ {Protheus.doc} PLSA629
Exclusao de titulos no financeiro.

@author  PLS TEAM
@version P12
@since   29/04/04
/*/

Function PLSA629()
	LOCAL n
	LOCAL cFiltro
	Local cPerg		:= "PLSA629"
	Local aSize	   	:= FWGetDialogSize( oMainWnd )
	Local nTop		:= 0
	Local nLeft	   	:= 0


	PRIVATE aRotina     := MenuDef()
	PRIVATE cCadastro 	:= STR0001 //"Exclusao de titulos a receber"
	PRIVATE cMarcaE1
	PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.) // utilizado na FA040DELET()
	PRIVATE lF040Auto   := .T.


	// Ajustes no dicionario...
	// Caso o indice 19 da tabea BEAJ nao tenha cido criada nao deixa o sistema
	// processeguir, alteracao requisita e aprovado pelo Tulio.

	If ! CheckBEAIndex("BEAJ")
		Return .F.
	EndIf


	// Chama pergunte para pegar a data a ser usada no filtro
	If	!Pergunte(cPerg,.T.)
		Return
	EndIf


	// Chama funcao para pegar as marcas do mark browse...
	cMarcaE1 := GetMark()

	SE1->( dbGotop() )
	SE1->( dbSeek(xFilial("SE1")) )

	// Filtro do objeto MarkBrow...
	cFiltro := "E1_FILIAL == '" + xFilial("SE1") + "' .AND. E1_EMISSAO >= '" + DtoS(MV_PAR01)   + "' .AND. E1_EMISSAO <= '" + DtoS(MV_PAR02)   + "' .AND. E1_CODINT <> '" + Space(Len(SE1->E1_CODINT)) + "' .AND. (E1_ORIGEM == 'PLSA510' .OR. E1_ORIGEM == 'PLSMPAG' .OR. E1_ORIGEM == 'PLSA260' .OR. E1_ORIGEM == 'PLSA090')"



	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],"Seleção dos títulos para exclusão",,,,,,,,, .T.,,,, .F. )

	// Instanciamento do classe
	oMark := FWMarkBrowse():New()
	oMark:SetOwner( oDlg )

	// Definição da tabela a ser utilizada
	oMark:SetAlias('SE1')

	//Configuração de opções
	oMark:SetMenuDef( "PLSA629" )

	// Define a titulo do browse de marcacao
	oMark:SetDescription('Exclusão de Títulos no Financeiro')

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'E1_OK' )

	// Permite marcar apenas um registro
	oMark:SetCustomMarkRec({||A629Mark(oMark)})

	// Indica o Code-Block executado no clique do header da coluna de marca/desmarca
	oMark:SetAllMark( { || A629AllMark(oMark)})

	// Define a legenda
	oMark:AddLegend( "E1_SALDO < E1_VALOR 	.AND. E1_SALDO <> 0 ", "YELLOW" ,'Saldo a Baixar')
	oMark:AddLegend( "E1_SALDO = E1_VALOR", "GREEN"  ,'Em Aberto')
	oMark:AddLegend( "E1_SALDO = 0"       , "RED"    ,'Baixado'  )

	// Definição do filtro de aplicacao
	oMark:SetFilterDefault(cFiltro)

	// Ativacao da classe
	oMark:Activate()

	// Ativação do container
	oDlg:Activate()



	//???????????????????????????????????????????????????????????????????????????????????Ä¿
	//? Desmasca os registros caso a rotina seja abortada com titulos marcados...		  |
	//?????????????????????????????????????????????????????????????????????????????????????
	For n := 1 To Len(aRecSE1)
		If aRecSE1[n] > 0
			SE1->( dbGoto(aRecSE1[n]) )
			If !SE1->( Eof() )
				SE1->( RecLock("SE1", .F.) )
				SE1->E1_OK := Space(Len(SE1->E1_OK))
				SE1->( MsUnlock() )
			Endif
		Endif
	Next

Return Nil

/*/{Protheus.doc} PL629Mov
Rotina que ira exlcuir um titulo gerado pelo PLS no financeiro...

@author  PLS TEAM
@version P12
@since   29/04/04
/*/
function PL629Mov(cAlias, nReg, nOpc, cMark, lAutoma, aSE1recno)
	local nI		:= 0
	local nPos		:= 0
	local nRecSE1	:= 0
	local nRecEst   := 0
	local lErro		:= .f.
	local lConf     := .f.
	local lAsk      := .f.
	local aErro     := {}
	local bOrdem 	:= {|x,y| x>y}
	local aRetPto 	:= {}
	local aEstorno	:= {}
	local lPL629E1V := existBlock("PL629E1V")
	local lFirstSE1 := .T.
	local nX		:= 0
	local lExcComp	:= .T.
	local cChaveFK7
	local lBxCancel := GetNewPar("MV_PLBXCAN",.F.) // Baixa por cancelamento

	Default cMark		:= ''
	Default lAutoma		:= .F.
	Default aSE1recno	:= {}

	If lAutoma
		aRecSE1 := aSE1recno
	EndIf

	//Confirma a exclusao dos titulos marcados...
	if !lAutoma
		If ! msgYesNo('Atenção!' + CRLF + 'Exclusão do título e movimentação contábil!' + CRLF + '(Somente para título já contabilizado)' + CRLF + 'Obs.: Com o bloqueio do calendário contábil a operação não será executada!' + CRLF + CRLF + 'Confirma a exclusão dos titulos selecionados?')
			return(.f.)
		EndIf
	endIf

	//Ordena o conteudo do array de forma decrescente
	aSort(aRecSE1,,,bOrdem)

	//Processa os regsitros marcados...
	for nI := 1 to len(aRecSE1)

		//Inicializa variaveis
		lErro     	:= .f.
		aEstorno	:= {}

		//Posiciona registro marcado...
		SE1->(dbGoto(aRecSE1[nI]))

		If SE1->( eof() ) .or. SE1->(deleted())
			Loop
		EndIf

		nRecEst	  :=  SE1->(RecNo())

		//Antes de efetuar a exclução precisamos vericar se o titulo existe NCC e se esta compensado no titulo principal
		//Para isso precisamos da função do financeiro MaIntBxCR
		If Alltrim(SE1->E1_TIPO) <> "NCC"
			//Chave para ser recuperada na FK7.
			cChaveFK7 := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +SE1->E1_CLIENTE + "|" + SE1->E1_LOJA

			If CheckLancTit(cChaveFK7) // analisando se existe movimentações no financeiro
				aAdd(aErro, { STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0033, .t.} ) // "Título com movimentação feita pelo financeiro."
				lErro     := .T.
			Endif
		Endif

		//Verifica situacao do titulo
		aRet := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

		//[1]  - Calendario contabil (.T./.F.)
		//[2]  - Movimentado (.T./.F.)
		//[9]  - Indica que existe lote de cobrança posterior para mesmo ano e mes (.T./.F.)
		//[11] - Indica titulo em carteira (.T./.F.)

		// Bloqueio do Calendario Contabil
		if aRet[1]

			aadd(aErro, { STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), "O calendario contabil esta fechado!"}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"###"O calendario contabil esta fechado!"

			lErro     := .t.

		endIf

		// Titulo nao esta em carteira
		if aRet[11]

			aadd(aErro,{ STR0006, STR0007, SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO,STR0009}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"###"Titulo nao pode ser excluido porque nao esta em carteira"

			lErro   := .t.
		endIf

		// Titulo em TELECOBRANCA
		if aRet[12]

			aadd(aErro, { STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0031}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"###"Este t?tulo n?o pode ser excluido pois se encontra em cobran?a"

			lErro     := .t.

		endIf

		//movimentacao
		if aRet[2]

			//Verifica se o titulo foi baixado total ou parcialmente
			if SE1->E1_VALOR <> SE1->E1_SALDO .And. SE1->E1_SALDO > 0
				aAdd(aErro, { STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0034, .t.} ) // "Título baixado Parcialmente."
				lErro 	:= .T.
			Else

				If ! aRet[13]
					aAdd(aErro, { STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0035, .t.} ) // "Titulo baixado."
					lErro 	:= .T.
				Endif

			EndIf

			//compensacao NCC
			If aRet[13]
				aadd(aEstorno, SE1->(Recno()) )
				nRecSE1 := SE1->(RecNo())

				// Antes de Estornar a compensação do NCC, verifica se o Titulo teve baixa no Financeiro
				If CheckTitNCC(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM),aRecSE1)
					aAdd(aErro, { STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0036, .t.} ) // "Título principal com movimentação feita pelo financeiro."
					lErro	:= .T.
				EndIf

			EndIf
		Else
			If Alltrim(SE1->E1_TIPO) == "NCC"
				If CheckTitNCC(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM),aRecSE1)
					aAdd(aErro, {STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0036, .t.} ) // "Título principal com movimentação feita pelo financeiro."
					lErro := .T.
				EndIf
			EndIf
		EndIf

		if lPL629E1V

			nRecSE1 := SE1->(RecNo())

			aRetPto := execBlock("PL629E1V",.f.,.f., { SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,lErro,aErro,aRecSE1 } )

			lErro := aRetPto[1]
			aErro := aRetPto[2]

			SE1->(dbGoTo(nRecSE1))

		endIf

		If lErro
			loop
		EndIf

		//tratamento para retirar compensacao com NCC
		if nRecSE1 > 0 .and. Len(aEstorno) > 0

			if ! lAsk
				If !lAutoma
					lConf := msgYesNo(STR0037) // "Confirmar o estorno da compensação dos titulos?<br>Caso responda que <b>NÃO</b>, será feito a exclusão somente dos títulos que não possuam compensação."
				Else
					lConf := .T.
				EndIf
				lAsk  := .t.
			endIf

			if lConf

				aAreaSE1 	:= SE1->(GetArea())
				For nX := 1 to Len(aEstorno)
					SE1->( msGoTo( aEstorno[nX] ) )

					If lBxCancel
						// Verifica se será feito o estorno ou exclusão da compensação
						lExcComp := CheckExcTit(SE1->E1_PREFIXO,SE1->E1_NUM) // .F. = Estorno / .T. = Exclusão
					Endif

					//Se tenho titulo NCC para o titulo principal efetua o extorno da compensação.
					//Caso não esteja compensando o sistema irá fazer a exclusão normalmente
					if PLTITBXCR(.t.,lExcComp)
						SE1->( msGoTo( nRecEst) )
						nPos := aScan(aErro, {|x| x[3] == SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) } )

						if nPos > 0
							aDel( aErro, nPos )
							aSize( aErro, len(aErro) - 1 )
						endIf

					endIf
				Next nX
				aAreaSE1 	:= SE1->(GetArea())
			endIf

		endIf

		If Len(aEstorno) > 0 .And. !lConf
			aAdd(aErro, {STR0006, STR0007, SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO), STR0038}) // "Inconsistencia no estorno da compensação do titulo."
			Loop
		EndIf

		//Chama funcao generica para excluir o titulo...
		BBT->( dbSetorder(07) )
		if BBT->( dbSeek(xFilial("BBT")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO) )

			lErro := ! PLSA629SE1(	SE1->E1_PLNUCOB,;
				Iif(BBT->BBT_INTERC=='1',.t.,.f.),;
				SE1->E1_PREFIXO,;
				SE1->E1_NUM,;
				SE1->E1_PARCELA,;
				SE1->E1_TIPO,;
				BBT->BBT_NIVEL,;
				BBT->BBT_TIPINT)

			if lErro
				aadd(aErro,{STR0006,STR0007,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO,"Inconsistencia na exclusão do titulo"}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"
			else
				lFirstSE1 := .f.
			endIf

		elseIf allTrim(SE1->E1_ORIGEM) == 'PLSMPAG'

			// Tratamento da exclusao dos titulos de contestacao
			// Primeiro posiciono o BRJ, pois nessa tabela eu tenho as duas chaves
			// necessarias (do titulo a pagar e do titulo a receber).
			// Chave SE1 -> BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT
			// Chave SE2 -> BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2

			BRJ->(dbSetOrder(5))
			if BRJ->(msSeek(xFilial("BRJ") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))

				if ! P629ExcE1(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2))
					disarmTransaction()
					aadd(aErro,{STR0006,STR0007,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO,"Inconsistencia na exclusão do titulo"}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"
				endIf

			else
				aadd(aErro,{STR0006,STR0007,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO,"Inconsistencia - BRJ não encontrado"}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"###"Inconsistencia - BBT (Complemento do Contas a Receber) nao encontrado"
			endIf

		else

			if lFirstSE1
				aadd(aErro,{STR0006,STR0007,SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO,STR0010}) //"SE1-Contas a Receber"###"1 Prefixo+Numero+Parcela+Tipo"###"Inconsistencia - BBT (Complemento do Contas a Receber) nao encontrado"
			else
				aadd(aErro,{"","","",STR0010}) //"Inconsistencia - BBT (Complemento do Contas a Receber) nao encontrado"
			endIf

			lErro     := .t.
			lFirstSE1 := .f.

		endIf

	next nI

	if len(aErro) > 0
		PLSCRIGEN(aErro,{ {STR0011,"@C",60} , {STR0012,"@C",100 } , {STR0013,"@C",60 } , {STR0014,"@C",300 } } , STR0015) //"Tabela"###"Chave (composicao)"###"Chave (conteudo)"###"Mensagem"###"Ocorrencias na exclusao dos titulos selecionados"
	endIf

	If !lAutoma
		For nI := 1 to Len(aRecSE1)
			// Atualiza campo OK
			oMark:Goto(aRecSE1[nI],.T.)
			RecLock(oMark:Alias(),.F.)
			(oMark:Alias())->E1_OK  := ''
			(oMark:Alias())->(MsUnLock())
		Next nI

		oMark:Refresh(.T.)
	EndIf
	aSize(aRecSE1,0)

return()

/*/{Protheus.doc} PLSA629SE1
Analisa dados de um SE1 (Tit Receber)

@author  PLS TEAM
@version P11
@since   04.01.05
/*/
static Function PLSA629SE1(cNumCob,lInterC,cBBT_PREFIX,cBBT_NUMTIT,cBBT_PARCEL,cBBT_TIPTIT,cBBTNIV,cTIPINT)
	LOCAL cFor 		:= "BBT_NUMCOB = '" + cNumCob + "'"
	LOCAL cArea 	:= Alias()
	LOCAL cSqlCom	:= ""
	LOCAL cOrig		:= ""
	LOCAL cCpoBTV	:= ""
	LOCAL nBASE 	:= 0
	LOCAL n			:= 0
	LOCAL nCOMI 	:= 0,ncnt
	LOCAL nVALOR 	:= 0
	LOCAL nPos		:= 0
	LOCAL nForReg	:= 0
	LOCAL cBBTPRE   := "Nao"
	local lRet		:= .t.
	LOCAL aSE1TOBTV := {{"SE1_BASCOM1","BTV_BASCO1"},;
		{"SE1_BASCOM2","BTV_BASCO2"},;
		{"SE1_BASCOM3","BTV_BASCO3"},;
		{"SE1_BASCOM4","BTV_BASCO4"},;
		{"SE1_BASCOM5","BTV_BASCO5"},;
		{"SE1_VALCOM1","BTV_VALCO1"},;
		{"SE1_VALCOM2","BTV_VALCO2"},;
		{"SE1_VALCOM3","BTV_VALCO3"},;
		{"SE1_VALCOM4","BTV_VALCO4"},;
		{"SE1_VALCOM5","BTV_VALCO5"}}

	Begin Transaction

		//Atualiza informacoes do lote de cobranca...
		If cBBT_PREFIX # Nil .And. !lInterC

			//Diminuo as cobrancas a serem excluidas do resumo da cobranca
			cSqlCom := "SELECT BMZ_BASE, BMZ_COMIS FROM "+BMZ->(RetSQLName("BMZ")) + " BMZ WHERE "
			cSqlCom += "BMZ_FILIAL = '" + xFilial("BMZ") + "' AND "
			cSqlCom += "BMZ_PRESE1 = '" + cBBT_PREFIX + "' AND "
			cSqlCom += "BMZ_NUMSE1 = '" + cBBT_NUMTIT + "' AND "
			cSqlCom += "BMZ_PARSE1 = '" + cBBT_PARCEL + "' AND "
			cSqlCom += "BMZ_TIPSE1 = '" + cBBT_TIPTIT + "' AND "
			cSqlCom += "BMZ_PLNUCO = '" +   cNumCob   + "' AND "
			cSqlCom += "BMZ_NIVCOB = '"+cBBTNIV+"' AND "
			cSqlCom += "BMZ.D_E_L_E_T_ = ' ' "

			cSqlCom := ChangeQuery(cSqlCom)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cSqlCom), "TRBC", .F., .T.)

			TRBC->( dbEval({|| nBASE += BMZ_BASE, nCOMI += BMZ_COMIS}) )

			TRBC->( dbCloseArea() )

			//Diminuo as cobrancas a serem excluidas do resumo da cobranca
			cSqlCom := "SELECT BM1_VALOR VALOR , BM1_VALDES  VALDES, BM1_TIPO TIPO   FROM " + BM1->(RetSQLName("BM1")) + " BM1 "
			cSqlCom += "WHERE BM1_FILIAL = '"+xFilial("BM1")+"' "
			cSqlCom += "AND BM1_PREFIX = '" + cBBT_PREFIX + "' "
			cSqlCom += "AND BM1_NUMTIT = '" + cBBT_NUMTIT + "' "
			cSqlCom += "AND BM1_PARCEL = '" + cBBT_PARCEL + "' "
			cSqlCom += "AND BM1_TIPTIT = '" + cBBT_TIPTIT + "' "
			cSqlCom += "AND BM1_PLNUCO = '" +cNumCob      + "' "

			If !Empty(cBBTNIV)
				cSqlcom += "AND BM1_NIVCOB = '"+cBBTNIV+"' "
			Endif
			cSqlCom += "AND BM1.D_E_L_E_T_ = ' ' "

			cSqlCom := ChangeQuery(cSqlCom)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cSqlCom), "TRBC", .F., .T.)

			TCSETFIELD("TRBC","VALOR","N",nVlPrec,nVlDec)
			TRBC->( dbEval({|| Iif(TIPO =='1',nVALOR += VALOR,nVALOR -= VALOR )}) )

			TRBC->( dbCloseArea() )

			nVlrExt := 0
			nVlrCex := 0
			nVlrBse := 0

			// gerando um select para a soma dos valores e esses valores sera transferido para variaeis
			// e ser?o aplicadas nos updates seguintes

			cSql := "SELECT BDD_VLREXT VLREXT, BDD_BSECEX BSECEX, BDD_VLRCEX VLRCEX FROM " + RetSQLName("BDD") + " BDD "
			cSql += "WHERE BDD_FILIAL = '"+xFilial("BDD")+"' AND "
			cSql += "BDD_INTERC = '0' AND "
			cSql += "BDD_CODOPE = '"+Substr(cNumCob,1,4)+"' AND "
			cSql += "BDD_NUMERO = '"+Substr(cNumCob,5,8)+"' AND "
			cSql += "BDD_NIVEL = '"+cBBTNIV+"' AND "
			cSql += +" D_E_L_E_T_ = ' ' "

			cSql := ChangeQuery(cSql)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBC", .F., .T.)

			TCSETFIELD("TRBC","VLREXT","N",nVlPrec,nVlDec)
			TCSETFIELD("TRBC","BSECEX","N",nVlPrec,nVlDec)
			TCSETFIELD("TRBC","VLRCEX","N",nVlPrec,nVlDec)
			TRBC->( dbEval({|| nVlrExt += VLREXT }) )
			TRBC->( dbEval({|| nVlrBse += BSECEX }) )
			TRBC->( dbEval({|| nVlrCex += VLRCEX }) )
			TRBC->( dbCloseArea() )

			nVlrTotEst:=nVlrExt+nVALOR
			nVlrTotBse:=nVlrBse+nBASE
			nVlrTotCex:=nVlrCex+nCOMI
			cSql := "UPDATE "+BDD->(RetSQLName("BDD"))+" SET "
			cSql += "BDD_GERADO = (BDD_GERADO -1), "
			cSql += "BDD_VALOR  = (BDD_VALOR - "+Alltrim(Str(nVALOR))+"), "
			cSql += "BDD_VLREXT = ("+Alltrim(Str(nVlrTotEst))+"), "
			cSQL += "BDD_BSECEX = ("+Alltrim(Str(nVlrTotBse))+"), "
			cSQL += "BDD_VLRCEX = ("+Alltrim(Str(nVlrTotCex))+") "
			cSql += "WHERE BDD_FILIAL = '"+xFilial("BDD")+"' AND "
			cSql += "BDD_INTERC = '0' AND "
			cSql += "BDD_CODOPE = '"+Substr(cNumCob,1,4)+"' AND "
			cSql += "BDD_NUMERO = '"+Substr(cNumCob,5,8)+"' AND "
			cSql += "BDD_NIVEL = '"+cBBTNIV+"' AND "
			cSql += +BDD->(RetSQLName("BDD"))+".D_E_L_E_T_ = ' ' "

			TCSQLExec(cSql)

			//Marco as comissoes como cancelados... Nao alterado... testar!!
			cSQL := "UPDATE "+BDF->(RetSQLName("BDF"))+" SET "
			cSQL += "BDF_TIPO = '2'
			cSQL += "WHERE BDF_FILIAL = '"+xFilial("BDF")+"' AND "
			cSQL += "BDF_PREFIX = '" + cBBT_PREFIX + "' AND "
			cSQL += "BDF_NUMTIT = '" + cBBT_NUMTIT + "' AND "
			cSQL += "BDF_PARCEL = '" + cBBT_PARCEL + "' AND "
			cSQL += "BDF_TIPTIT = '" + cBBT_TIPTIT + "' AND "
			cSQL += "BDF_CODOPE = '"+Substr(cNumCob,1,4)+"' AND "
			cSQL += "BDF_NUMERO = '"+Substr(cNumCob,5,8)+"' AND "
			cSQL += "BDF_NIVEL  = '"+cBBTNIV       +"' AND "
			cSQL += "D_E_L_E_T_ = ' ' "
			cSQL += "AND EXISTS (SELECT BMZ.R_E_C_N_O_ "
			cSQL += "FROM " + BMZ->(RetSQLName("BMZ")) + " BMZ "
			cSQL += "WHERE BMZ_FILIAL = '"+xFilial("BMZ")+"' AND "
			cSQL += "BMZ_PREFIX = BDF_PREFIX AND "
			cSQL += "BMZ_NUMTIT = BDF_NUMTIT AND "
			cSQL += "BMZ_PARCEL = BDF_PARCEL AND "
			cSQL += "BMZ_TIPTIT = BDF_TIPTIT AND "
			If AllTrim( TCGetDB() ) == "ORACLE"
				cSQL += "BMZ_PLNUCO = BDF_CODOPE || BDF_NUMERO AND "
			Else
				cSQL += "BMZ_PLNUCO = BDF_CODOPE + BDF_NUMERO AND "
			Endif
			cSQL += "BMZ.D_E_L_E_T_ = ' ')

			TCSQLExec(cSQL)

			//Marco os titulos como cancelados
			cSQL := "UPDATE "+BDF->(RetSQLName("BDF"))+" SET "
			cSQL += "BDF_TIPO = '2' "
			cSQL += "WHERE BDF_FILIAL = '"+xFilial("BDF")+"' AND "
			cSQL += "BDF_PREFIX = '" + cBBT_PREFIX + "' AND "
			cSQL += "BDF_NUMTIT = '" + cBBT_NUMTIT + "' AND "
			cSQL += "BDF_PARCEL = '" + cBBT_PARCEL + "' AND "
			cSQL += "BDF_TIPTIT = '" + cBBT_TIPTIT + "' AND "
			cSQL += "BDF_CODOPE = '"+Substr(cNumCob,1,4)+"' AND "
			cSQL += "BDF_NUMERO = '"+Substr(cNumCob,5,8)+"' AND "
			cSql += "D_E_L_E_T_ = ' ' "

			TCSQLExec(cSQL)

			//Atualiza o lote de cobranca...
			BDC->( dbSetorder(01) )
			If BDC->( dbSeek(xFilial("BDC")+cNumCob) )
				BDC->(RecLock("BDC", .F.))
				BDC->BDC_CONGER -= 1
				BDC->BDC_VALOR  -= SE1->E1_VALOR
				BDC->( msUnlock() )
			Endif

		ElseIf cBBT_PREFIX # Nil .And. lInterC

			//Atualiza a linha do detalhe do faturamento de intercambio eventual..
			BTO->( dbSetorder(02) )
			If BTO->( dbSeek(xFilial("BTO")+cNumCob+cBBT_PREFIX+cBBT_NUMTIT+cBBT_PARCEL+cBBT_TIPTIT) )

				While !BTO->(RecLock("BTO",.F.)) // Aguarda liberacao do registro...
				Enddo

				BTO->BTO_STATUS := '4'  // Cancelado

				BTO->( MsUnlock() )

			EndIf

			//Atualiza o cabecalho do lote de intercambio eventual... diminui vlr.
			BTF->( dbSetorder(01) )
			If BTF->( dbSeek(xFilial("BTF")+cNumCob) )

				While !BTF->(RecLock("BTF",.F.)) // Aguarda liberacao do registro...
				Enddo

				BTF->BTF_OPECAN += 1
				BTF->BTF_OPEGER -= 1
				BTF->BTF_VLRCOP -= BTO->BTO_VLRCOP
				BTF->BTF_VLRCP2 -= BTO->BTO_VLRCP2
				BTF->BTF_VLRTAX -= BTO->BTO_VLRTAX
				BTF->BTF_CUSTOT -= BTO->BTO_CUSTOT

				BTF->( MsUnlock() )
			Endif

		EndIf

		//Seleciona BBT dos titulos selecionados...
		cFor := "SELECT * FROM " + RetSqlName("BBT")
		cFor += " WHERE BBT_FILIAL = '" + xFilial("BBT") + "' AND "
		cFor += " BBT_NUMCOB = '"+cNumCob+"' AND "

		If cBBT_PREFIX # Nil
			cFor += "BBT_PREFIX = '" + cBBT_PREFIX + "' AND "
			cFor += "BBT_NUMTIT = '" + cBBT_NUMTIT + "' AND "
			cFor += "BBT_PARCEL = '" + cBBT_PARCEL + "' AND "
			cFor += "BBT_TIPTIT = '" + cBBT_TIPTIT + "' AND "
		Endif
		cFor += "D_E_L_E_T_ = ' '"

		cFor := ChangeQuery(cFor)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFor), "BBTQRY", .F., .T.)

		//Inicializa analize dos titulos...
		While ! BBTQRY->( Eof() )

			If BBTQRY->BBT_RECPAG == "0"

				SE1->( DbSetOrder(1) )
				If SE1->(DbSeek(xFilial("SE1")+BBTQRY->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)))

					//Grava arquivo de historico de titulos excluidos pelo PLS
					If  PLSALIASEX("BTV")

						BTV->( RecLock("BTV", .T.) )

						For nCnt := 1 To SE1->( FCount() )

							cCampo := SE1->(Field(nCnt))
							cOrig  := cCampo

							If Len(Alltrim(cCampo)) == 10
								cCampo := Substr(cCampo,1,9)
							EndIf
							//Alguns campo do btv nao puderam ter o mesmo nome do SE1, foi criado
							//um array que servira como de/para para esses campos!
							//Neste pondo o DE/PARA e consultado!
							If (nPos := Ascan(aSE1TOBTV, {|x| Alltrim(x[1]) == Alltrim(cOrig)})) <> 0
								cCpoBTV := aSE1TOBTV[nPos][2]
							Else
								cCpoBTV := StrTran(cCampo,"E1","BTV")
							Endif

							If (nPosBTV := BTV->(FieldPos(cCpoBTV))) <> 0
								If  Alltrim(cCpoBTV) == 'BTV_OK'
								Elseif  Alltrim(cCpoBTV) == 'BTV_FILIAL'
									BTV->BTV_FILIAL := xFilial("BTV")
								Else
									BTV->( FieldPut(nPosBTV,SE1->(FieldGet(nCnt))) )
								endIf
							endIf

						Next

						//Trata intercambio...
						BTV->BTV_INTERC := BBTQRY->BBT_INTERC
						BTV->BTV_TIPINT := BBTQRY->BBT_TIPINT
						BTV->( MsUnlock() )

					endIf

					//exclui titulo ou cancela
					if ! P629ExcE1()
						disarmTransaction()
						lRet := .f.
						exit
					endIf

				endIf

			endIf

			//Deleta registro de complemento do titulo... o famoso BBT.
			BBT->( DbGoto(BBTQRY->R_E_C_N_O_) )

			BBT->(RecLock("BBT",.F.))
			BBT->(DbDelete())
			BBT->(MsUnLock())

			BBTQRY->(DbSkip())

		EndDo

		BBTQRY->(DbCloseArea())

		PLSLOGFIL("PLSA629 linha 664. Numero do Titulo: " + cBBT_NUMTIT + " Prefixo: "+cBBT_PREFIX+" Tipo: "+cBBT_TIPTIT+" Numero da Cobran?a: "+cNumCob+"." ,"LOGLOTCART.LOG")
		PLSLOGFIL("User: "+RetCodUsr()+" Data: "+ Time() + " Rotina Utilizada: " + FUNNAME() + " Vai acessar IF da linha 675: "+ cBBTPRE +   "." ,"LOGLOTCART.LOG")

		if lRet

			//Desmarco faturamento das taxas de identificacao de usuario...
			cSQL := "UPDATE "+BED->(RetSQLName("BED"))+" SET "
			cSQL += "BED_FATUR = '0', BED_ANMSFT = ' ', BED_NUMCOB = ' ',  "
			cSQL += "BED_PREFIX = ' ', BED_NUMTIT = ' ', BED_PARCEL = ' ', BED_TIPTIT = ' ' "
			cSQL += "WHERE BED_FILIAL = '"+xFilial("BED")+"' AND "
			cSQL += "BED_NUMCOB = '"+cNumCob+"' AND "

			If cBBT_PREFIX # Nil
				cSQL += "BED_PREFIX = '" + cBBT_PREFIX + "' AND "
				cSQL += "BED_NUMTIT = '" + cBBT_NUMTIT + "' AND "
				cSQL += "BED_PARCEL = '" + cBBT_PARCEL + "' AND "
				cSQL += "BED_TIPTIT = '" + cBBT_TIPTIT + "' AND "
			Else
				cSQL += "BED_INTERC "+Iif(lInterc, " = '1' "," <> '1' ")+" AND "
			Endif
			cSQL += "BED_FATUR  = '1' AND BED_COBRAR = '1' AND BED_VALOR > 0 AND D_E_L_E_T_ = ' '"

			TCSqlExec(cSQL)

			//Se for informado somente o lote de cobranca
			If cBBT_PREFIX # Nil

				//desmarco cobrança inicial e retroativa
				cSql := "SELECT DISTINCT BA1.R_E_C_N_O_ AS BA1REC "
				cSql += "FROM " + BA1->(RetSQLName("BA1")) + " BA1, " + BM1->(RetSQLName("BM1")) + " BM1 "
				cSql += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
				cSql += "AND BM1_FILIAL = '" + xFilial("BM1") + "' "
				cSql += "AND BM1_PREFIX = '" + cBBT_PREFIX + "' "
				cSql += "AND BM1_NUMTIT = '" + cBBT_NUMTIT + "' "
				cSql += "AND BM1_PARCEL = '" + cBBT_PARCEL + "' "
				cSql += "AND BM1_TIPTIT = '" + cBBT_TIPTIT + "' "
				cSql += "AND BM1_PLNUCO = '"+cNumCob+"' "
				cSql += "AND BM1_CODTIP     IN ('103','101','133','118') "
				cSql += "AND BA1_CODINT = BM1.BM1_CODINT "
				cSql += "AND BA1_CODEMP = BM1.BM1_CODEMP "
				cSql += "AND BA1_MATRIC = BM1.BM1_MATRIC "
				cSql += "AND BA1_TIPREG = BM1.BM1_TIPREG "
				cSql += "AND BA1_DIGITO = BM1.BM1_DIGITO "
				cSql += "AND BA1.D_E_L_E_T_ = ' '"
				cSql += "AND BM1.D_E_L_E_T_ = ' ' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBBA1", .F., .T.)

				While !TRBBA1->( Eof() )
					BA1->( dbGoto(TRBBA1->BA1REC) )
					If !BA1->( Eof() )
						BA1->( Reclock("BA1", .F.) )

						If BA1->BA1_COBINI == cNumCob
							BA1->BA1_JACOBR = '0'
							BA1->BA1_COBINI = ' '
							BA1->BA1_ANOMES = ' '
						Endif
						BA1->( MsUnlock() )
					Endif
					TRBBA1->( dbSkip() )
				Enddo
				TRBBA1->( dbCloseArea() )

				//Desmarco a taxa de inscricao do usuario...

				cSql := "SELECT DISTINCT BA1.R_E_C_N_O_ AS BA1REC "
				cSql += "FROM " + BA1->(RetSQLName("BA1")) + " BA1, " + BM1->(RetSQLName("BM1")) + " BM1 "
				cSql += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
				cSql += "AND BM1_FILIAL = '" + xFilial("BM1") + "' "
				cSql += "AND BM1_PREFIX = '" + cBBT_PREFIX + "' "
				cSql += "AND BM1_NUMTIT = '" + cBBT_NUMTIT + "' "
				cSql += "AND BM1_PARCEL = '" + cBBT_PARCEL + "' "
				cSql += "AND BM1_TIPTIT = '" + cBBT_TIPTIT + "' "
				cSql += "AND BM1_PLNUCO = '"+cNumCob+"' "
				cSql += "AND BM1_CODTIP     IN ('103','133') "
				cSql += "AND BA1_CODINT = BM1.BM1_CODINT "
				cSql += "AND BA1_CODEMP = BM1.BM1_CODEMP "
				cSql += "AND BA1_MATRIC = BM1.BM1_MATRIC "
				cSql += "AND BA1_TIPREG = BM1.BM1_TIPREG "
				cSql += "AND BA1_DIGITO = BM1.BM1_DIGITO "
				cSql += "AND BA1_NUMCOB = '"+cNumCob+"' "
				cSql += "AND BA1.D_E_L_E_T_ = ' '"
				cSql += "AND BM1.D_E_L_E_T_ = ' ' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBBA1", .F., .T.)

				While !TRBBA1->( Eof() )
					BA1->( dbGoto(TRBBA1->BA1REC) )
					If !BA1->( Eof() )
						BA1->( Reclock("BA1", .F.) )

						If PLCheckTxAds(cNumCob, cBBT_PREFIX, cBBT_NUMTIT, cBBT_PARCEL, cBBT_TIPTIT)
							BA1->BA1_CBTXAD := '0'
							BA1->BA1_VLTXAD := 0
						EndIf
						If PLChTxOp(cNumCob, cBBT_PREFIX, cBBT_NUMTIT, cBBT_PARCEL, cBBT_TIPTIT)
							BA1->BA1_TXADOP := ' '
							BA1->BA1_VLTXOP := 0
						EndIf
						BA1->( MsUnlock() )
					Endif
					TRBBA1->( dbSkip() )
				Enddo
				TRBBA1->( dbCloseArea() )

				//Desmarco as movimentacoes de debito / credito...
				aRegs := {}
				BSQ->( dbSetorder(03) )//BSQ_FILIAL + BSQ_PREFIX + BSQ_NUMTIT + BSQ_PARCEL + BSQ_TIPTIT + BSQ_SEQ

				If BSQ->( dbSeek( xFilial("BSQ")+cBBT_PREFIX + cBBT_NUMTIT + cBBT_PARCEL + cBBT_TIPTIT) )

					While !BSQ->( Eof() ) .And. BSQ->(BSQ_FILIAL+BSQ_PREFIX+BSQ_NUMTIT+BSQ_PARCEL+BSQ_TIPTIT) == xFilial("BSQ")+cBBT_PREFIX + cBBT_NUMTIT + cBBT_PARCEL + cBBT_TIPTIT

						Aadd( aRegs, BSQ->(Recno()) )

						BSQ->( dbSkip() )
					Enddo

				EndIf

				BSP->(DbSetOrder(1))

				//For de registros bsq
				For nCnt := 1 To Len(aRegs)

					BSQ->( dbGoto(aRegs[nCnt]) )

					If !BSQ->( Eof() )

						BSQ->( RecLock("BSQ", .F.) )

						If BSP->(MsSeek(xFilial("BSP")+BSQ->BSQ_CODLAN)) .And. BSP->BSP_CODLAN == "188"
							BSQ->(DbDelete())
						Else				
							BSQ->BSQ_NUMCOB := ''
							BSQ->BSQ_PREFIX := ''
							BSQ->BSQ_NUMTIT := ''
							BSQ->BSQ_PARCEL := ''
							BSQ->BSQ_TIPTIT := ''					
						EndIf

						BSQ->( MsUnlock() )

					Endif

				Next

				If PLSALIASEXI("B44")

					aRegs := {}

					B44->( dbSetorder(3) )
					If B44->( dbSeek(xFilial("B44")+cBBT_PREFIX + cBBT_NUMTIT + cBBT_PARCEL + cBBT_TIPTIT) )

						While !B44->( Eof() ) .and. B44->(B44_FILIAL+B44_PREFIX+B44_NUM+B44_PARCEL+B44_TIPO) ==;
								xFilial("B44")+cBBT_PREFIX + cBBT_NUMTIT + cBBT_PARCEL + cBBT_TIPTIT

							Aadd( aRegs, B44->(Recno()) )

							B44->( dbSkip() )
						Enddo

					Endif

					For nCnt := 1 To Len(aRegs)

						B44->( dbGoto(aRegs[nCnt]) )

						If !B44->( Eof() )
							B44->( RecLock("B44", .F.) )
							B44->B44_PREFIX := ''
							B44->B44_NUM := ''
							B44->B44_PARCEL := ''
							B44->B44_TIPO := ''
							B44->( MsUnlock() )
						Endif

					Next

				Endif

				//Desmarco as movimentacoes de co-participacao e custo operacional...
				aRegs := {}
				BDH->(DbSetOrder(8))
				If BDH->(DbSeek(xFilial("BDH")+cBBT_PREFIX + cBBT_NUMTIT + cBBT_PARCEL + cBBT_TIPTIT))

					While ! BDH->( Eof() ) .And. (cBBT_PREFIX + cBBT_NUMTIT + cBBT_PARCEL + cBBT_TIPTIT) == 	BDH->BDH_PREFIX+;
							BDH->BDH_NUMTIT+;
							BDH->BDH_PARCEL+;
							BDH->BDH_TIPTIT

						aadd(aRegs,BDH->(Recno()))

						BDH->(DbSkip())
					Enddo

				Endif

				For nForReg := 1 To Len(aRegs)

					BDH->(DbGoTo(aRegs[nForReg]))

					//nova funcao que alem de atualizar o bdh atualiza as notas e eventos. plsmctmd.prw
					If ! FindFunction("PLSNOTXBDH")

						BDH->(RecLock("BDH",.F.))
						BDH->BDH_STATUS := "1"
						BDH->BDH_OPEFAT := ""
						BDH->BDH_NUMFAT := ""
						BDH->BDH_NUMSE1 := ""
						BDH->(MsUnLock())

					Else
						PLSNOTXBDH("1","","",{"","","",""},.F.)
					Endif

				Next

				//guarda historico BM1
				PL627HSBM1(cBBT_PREFIX, cBBT_NUMTIT, cBBT_PARCEL, cBBT_TIPTIT)

				//Deleta o BM1 relacionado ao titulo...
				cSql := "UPDATE "+RetSQLName("BM1")+" SET D_E_L_E_T_ = '*' "
				cSql += "WHERE BM1_FILIAL = '" + xFilial("BM1") + "'"
				cSql += "AND BM1_PREFIX = '" + cBBT_PREFIX + "' "
				cSql += "AND BM1_NUMTIT = '" + cBBT_NUMTIT + "' "
				cSql += "AND BM1_PARCEL = '" + cBBT_PARCEL + "' "
				cSql += "AND BM1_TIPTIT = '" + cBBT_TIPTIT + "' "
				cSql += "AND BM1_PLNUCO = '" + cNumCob + "' "
				If !Empty(cNumCob)
					cSql += "AND BM1_PLNUCO = '" + cNumCob + "' "//DENNIS
				EndIf
				cSql += "AND D_E_L_E_T_ = ' '"

				TCSqlExec(cSql)

			Else

				//Desmarco a cobranca de taxa de adesao do usuario...
				cSql := "SELECT BA1.R_E_C_N_O_ AS BA1REC "
				cSql += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
				cSql += "AND BA1_NUMCOB = '"+cNumCob+"' "
				cSql += "AND D_E_L_E_T_ = ' '"

				cSql := ChangeQuery(cSql)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBBA1", .F., .T.)

				While !TRBBA1->( Eof() )

					BA1->( dbGoto(TRBBA1->BA1REC) )

					If !BA1->( Eof() )

						BA1->( Reclock("BA1", .F.) )
						BA1->BA1_CBTXAD := '0'
						BA1->BA1_VLTXAD := 0
						If BA1->BA1_COBINI == cNumCob
							BA1->BA1_JACOBR = '0'
							BA1->BA1_COBINI = ' '
						Endif
						BA1->( MsUnlock() )

					Endif

					TRBBA1->( dbSkip() )
				Enddo

				TRBBA1->( dbCloseArea() )

				//Desmarco as movimentacoes de debito / credito...
				cSql := "UPDATE "+RetSQLName("BSQ")+" SET BSQ_NUMCOB = ' ', BSQ_PREFIX = ' ', BSQ_NUMTIT = ' ', BSQ_PARCEL = ' ', BSQ_TIPTIT = ' ' "
				cSql += "WHERE BSQ_FILIAL = '" + xFilial("BSQ") + "' "
				cSql += "AND BSQ_NUMCOB = '"+cNumCob+"' "
				cSql += "AND D_E_L_E_T_ = ' '"
				TCSqlExec(cSql)

				//Desmarco os BDH
				cSql := "SELECT BDH.R_E_C_N_O_ AS BDHREC FROM " + BDH->(RetSQLName("BDH")) + " BDH, " + BM1->(RetSQLName("BM1")) + " BM1 "
				cSql += "WHERE BDH_FILIAL = '" + xFilial("BDH") + "' "
				cSql += "AND BM1_FILIAL = '" + xFilial("BM1") + "' "
				cSql += "AND BM1_PLNUCO = '" + cNumCob + "' "
				cSql += "AND BDH_CODINT = BM1_CODINT "
				cSql += "AND BDH_CODEMP = BM1_CODEMP "
				cSql += "AND BDH_MATRIC = BM1_MATRIC "
				cSql += "AND BDH_TIPREG = BM1_TIPREG "
				cSql += "AND BDH_NUMFAT = '" + cNumCob + "' "
				cSql += "AND BDH.D_E_L_E_T_ = ' ' "
				cSql += "AND BM1.D_E_L_E_T_ = ' ' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBBDH", .F., .T.)

				While !TRBBDH->( Eof() )

					BDH->( dbGoto(TRBBDH->BDHREC) )

					If !BDH->( Eof() )

						BDH->( RecLock('BDH',.F.) )

						//nova funcao que alem de atualizar o bdh atualiza as notas e eventos. plsmctmd.prw
						If ! FindFunction("PLSNOTXBDH")

							BDH->(RecLock("BDH",.F.))
							BDH->BDH_STATUS := "1"
							BDH->BDH_OPEFAT := ""
							BDH->BDH_NUMFAT := ""
							BDH->BDH_PREFIX := ""
							BDH->BDH_NUMTIT := ""
							BDH->BDH_PARCEL := ""
							BDH->BDH_TIPTIT := ""
							BDH->(MsUnLock())

						Else
							PLSNOTXBDH("1","","",{"","","",""},.F.)
						Endif

						BDH->( MsUnlock() )

					Endif

					TRBBDH->( dbSkip() )
				EndDo
				TRBBDH->( dbClosearea() )

				//Deleta o BQG relacionado ao LOTE...
				If BGQ->(FieldPos("BGQ_NUMCOB")) > 0
					cSql := "UPDATE "+RetSQLName("BGQ")+" SET D_E_L_E_T_ = '*' "
					cSql += "WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "'"
					cSql += "AND BGQ_NUMCOB = '" + cNumCob + "' "
					cSql += "AND BGQ_INTERC "+Iif(lInterc, " = '1' "," <> '1' ")+" "
					cSql += "AND D_E_L_E_T_ = ' '"
					TcSqlExec(cSql)
				Endif

				//guarda historico BM1
				PL627HSBM1(nil, nil, nil, nil, cNumCob)

				//Deleta o BM1 relacionado ao Lote...
				cSql := "UPDATE "+RetSQLName("BM1")+" SET D_E_L_E_T_ = '*' "
				cSql += "WHERE BM1_FILIAL = '" + xFilial("BM1") + "'"
				cSql += "AND BM1_PLNUCO = '" + cNumCob + "' "
				cSql += "AND BM1_INTERC "+Iif(lInterc, " = '1' "," <> '1' ")+" "
				cSql += "AND D_E_L_E_T_ = ' '"
				TcSqlExec(cSql)

			EndIf

			//Pessoa Juridica
			TcSqlExec("UPDATE "+RetSQLName("BQC")+" SET BQC_NUMCOB = ' ', BQC_ULTCOB = ' ' " +;
				"WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND " +;
				"BQC_NUMCOB = '"+cNumCob+"' AND D_E_L_E_T_ = ' '")

			//Pessoa Fisica
			TcSqlExec("UPDATE "+RetSQLName("BA3")+" SET BA3_NUMCOB = ' ', BA3_ULTCOB = ' ' " +;
				"WHERE BA3_FILIAL = '" + xFilial("BA3") + "' AND " +;
				"BA3_NUMCOB = '"+cNumCob+"' AND D_E_L_E_T_ = ' '")

			If ! Empty(cArea)
				DbSelectArea(cArea)
			Endif

		endIf

	End Transaction

	//Refresh nas tabelas
	TCREFRESH(RetSqlName("BDD"))
	TCREFRESH(RetSqlName("BDF"))
	TCREFRESH(RetSqlName("BED"))
	TCREFRESH(RetSqlName("BA1"))
	TCREFRESH(RetSqlName("BSQ"))
	TCREFRESH(RetSqlName("BDH"))
	TCREFRESH(RetSqlName("BGQ"))
	TCREFRESH(RetSqlName("BM1"))
	TCREFRESH(RetSqlName("BQC"))
	TCREFRESH(RetSqlName("BAE"))

Return(lRet)

/*/{Protheus.doc} P629ExcE1
Exclui SE1-Contas a Receber

@author  PLS TEAM
@version P12
@since   03.03.05
/*/
Function P629ExcE1(cChave)
	local aRegSd2 	:= {}
	local aRegSe1	:= {}
	local aRegSe2 	:= {}
	local aTit		:= {}
	local lRet		:= .t.
	local lBxCancel := GetNewPar("MV_PLBXCAN",.F.) // Baixa por cancelamento
	local lFilX5PE	:= ExistBlock("CHGX5FIL")
	local cFilialX5 := xFilial("SX5")
	local cSql		:= ""
	local cNumNew	:= ""
	local aDadX5	:= {}

	private lMsErroAuto		:= .f. //Determina se houve algum tipo de erro durante a execucao do ExecAuto
	private lMsHelpAuto		:= .t. //Define se mostra ou n?o os erros na tela (T= Nao mostra; F=Mostra)
	private lAutoErrNoFile	:= .t. //Habilita a gravacao de erro da rotina automatica

	default cChave  := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

	BGQ->(dbSetOrder(7)) //BGQ_FILIAL+BGQ_PREFIX+BGQ_NUMTIT+BGQ_PARCEL+BGQ_TIPTIT
	if BGQ->( msSeek( xFilial("BGQ") + cChave ) )

		while ! BGQ->(eof()) .and. BGQ->(BGQ_FILIAL+BGQ_PREFIX+BGQ_NUMTIT+BGQ_PARCEL+BGQ_TIPTIT) ==  xFilial("BGQ") + cChave

			BGQ->(recLock("BGQ",.f.))
			BGQ->(dbDelete())
			BGQ->(msUnLock())

			BGQ->(dbSkip())
		endDo

	endIf

	// Se for o ultimo titulo, decrementa no SX5.
	if getNewPar("MV_PLSEQE1","0") == "1"

		If lFilX5PE
			cFilialX5 := ExecBlock("CHGX5FIL",.F.,.F.)
		Endif

		aDadX5 := FWGetSX5("BK", SE1->E1_PREFIXO)

		if len(aDadX5) > 0

			if strZero( val(aDadX5[1][4])-1, len(SE1->E1_NUM)) == SE1->E1_NUM

				// Só decrementa o SX5 quando tiver somente um registro
				If NumTitNCC(SE1->E1_PREFIXO, SE1->E1_NUM) == 1
					_nH := PLSAbreSem("PL627X5.SMF")
					cNumNew := Tira1( alltrim(aDadX5[1][4]) )
					cSql := " UPDATE " + RetSqlName("SX5") + " SET "
					cSql += "   X5_DESCRI  = '" + cNumNew + "', X5_DESCSPA = '" + cNumNew + "', X5_DESCENG = '" + cNumNew + "' "
					cSql += " WHERE "
					cSql += "   X5_FILIAL = '" + cFilialX5      + "' AND  X5_TABELA  = 'BK'  AND "
					cSql += "   X5_CHAVE = '" + SE1->E1_PREFIXO + "' AND  D_E_L_E_T_ = ' ' "
					TCSqlExec(cSql)

					PLSFechaSem(_nH,"PL627X5.SMF")
				EndIf
				// Sendo último titulo não posso baixar por cancelamento
				lBxCancel:= .F.

			endIf

		endIf

	endIf

	//Chama funcao generica para gerar e excluir movimentacoes...
	SE1->( dbClearFilter() )
	SE1->( dbSetorder(1) )

	//Exclui o titulo no financeiro
	SF2->(dbSetOrder(1))
	if SF2->(msSeek(xFilial("SF2") + SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) ) )

		if	lBxCancel

			PL627BXCAN(.f.)
		endIf

		//exclui movimento contabil
		lRet := PLSEXMCTB('R', SE1->( E1_PLNUCOB + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ), .t.)


		//se excluiu o movimento contabil
		if lRet	.And. !lBxCancel

			//exclui titulo
			if SE1->E1_TIPO == 'NCC'

				//exclui titulo
				aAdd(aTit , {"E1_PREFIXO"	,SE1->E1_PREFIXO	,NIL})
				aAdd(aTit , {"E1_NUM"		,SE1->E1_NUM		,NIL})
				aAdd(aTit , {"E1_PARCELA"	,SE1->E1_PARCELA	,NIL})
				aAdd(aTit , {"E1_TIPO"  	,SE1->E1_TIPO		,NIL})
				aAdd(aTit , {"E1_CLIENTE"	,SE1->E1_CLIENTE	,NIL})
				aAdd(aTit , {"E1_LOJA"  	,SE1->E1_LOJA		,NIL})

				MSExecAuto({|x, y| FINA040(x, y)}, aTit, 5)

				//Em caso de falha na exclusao dos titulos o processo ser? parado.
				if lMsErroAuto

					varInfo('Erro FINA040', getAutoGrLog())

					lRet := .f.
				endIf

			endIf

			//Estorna o documento de saida
			if maCanDelF2("SF2", SF2->( recno() ), @aRegSD2, @aRegSE1, @aRegSE2, SE1->E1_ORIGEM)

				aRegSE2	  := delSE2()
				lAnulaSF3 := getNewPar("MV_PLSCSF3", "1") == "1"

				SF2->( maDelNFS( aRegSD2, aRegSE1, aRegSE2, .f., .f., .f., .f. ) )

			else

				lRet := .f.

			endIf

		endIf

	else

		if 	lBxCancel
			PL627BXCAN(.f.)
		endIf

		//exclui movimento contabil
		lRet := PLSEXMCTB('R', SE1->( E1_PLNUCOB + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ), .t.)

		if lRet .And. !lBxCancel

			//exclui titulo
			aAdd(aTit , {"E1_PREFIXO"	,SE1->E1_PREFIXO	,NIL})
			aAdd(aTit , {"E1_NUM"		,SE1->E1_NUM		,NIL})
			aAdd(aTit , {"E1_PARCELA"	,SE1->E1_PARCELA	,NIL})
			aAdd(aTit , {"E1_TIPO"  	,SE1->E1_TIPO		,NIL})
			aAdd(aTit , {"E1_CLIENTE"	,SE1->E1_CLIENTE	,NIL})
			aAdd(aTit , {"E1_LOJA"  	,SE1->E1_LOJA		,NIL})

			MSExecAuto({|x, y| FINA040(x, y)}, aTit, 5)

			//Em caso de falha na exclusao dos titulos o processo ser? parado.
			if lMsErroAuto

				varInfo('Erro FINA040', getAutoGrLog())

				lRet := .f.

			endIf

		endIf

	endIf

	//filtra tabela...
	dbSelectarea("SE1")
	SE1->(dbSetorder(1))

return(lRet)


/*/{Protheus.doc} PLSA629Vis

@author  PLS TEAM
@version P12
@since   03.03.05
/*/
Function PLSA629Vis()
	LOCAL cOldCad := cCadastro

	cCadastro := STR0016  //"Visualizacao do Titulo a Receber"

	FA280Visua("SE1",SE1->(Recno()),K_Visualizar)

	cCadastro := cOldCad

Return

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Í»??
???Programa  ?PLSA629   ?Autor  ?Microsiga           ? Data ?  05/23/04   ???
?????????????????????????????????????????????????????????????????????????Í¹??
???Desc.     ?                                                            ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????Í¹??
???Uso       ? AP         	                                              ???
?????????????????????????????????????????????????????????????????????????Í¼??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
Function PLSA629COM()

	PLSCOMPFIN(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_PLNUCOB, .F., .F.)

Return()



/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Í»??
???Programa  ?PLSA629BOL?Autor  ?Geraldo Felix Jr.   ? Data ?  11/01/04   ???
?????????????????????????????????????????????????????????????????????????Í¹??
???Desc.     ? Impressao do boleto.                                       ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????Í¹??
???Uso       ? AP                                                        ???
?????????????????????????????????????????????????????????????????????????Í¼??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
Function PLSA629BOL(SE1Rec)
	PRIVATE aRet		 :={}

	DEFAULT SE1Rec := SE1->( Recno() )

	If SE1->E1_SITUACA == '0'
		MsgInfo(STR0017) //"Nao sera possivel imprimir o boleto... Titulo em carteira!"
		Return(.F.)
	Endif

	If MsgYesNo(STR0018) //"Deseja imprimir o boleto ?"

		If ParamBox({ {2,STR0019     ,STR0020,{STR0020,STR0021,STR0022},50,,.T.} ,;				// Tipo //"Detalha Cob."###"Por Usuario"###"Por Usuario"###"Tipo de Cobranca"###"Faixa Etaria"
				{2,STR0023,STR0005        ,{STR0005,STR0004}                                    ,30,,.T.}},; //"Cobra segunda via"###"Nao"###"Nao"###"Sim"
				STR0024,@aRet ) //"Emissao do boleto"

			If Existblock("PLSBOL")

				U_PLSBOL(SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_CLIENTE, SE1->E1_LOJA,;
					SE1->E1_CODINT , SE1->E1_CODINT , SE1->E1_CODEMP , SE1->E1_CODEMP ,;
					Space(Len(BA3->BA3_CONEMP)), Replicate("Z", Len(BA3->BA3_CONEMP))  ,;
					Space(Len(BA3->BA3_SUBCON)), Replicate("Z", Len(BA3->BA3_SUBCON))  ,;
					SE1->E1_MATRIC  , SE1->E1_MATRIC , SE1->E1_MESBASE, SE1->E1_ANOBASE,;
					SE1->E1_MESBASE , SE1->E1_ANOBASE, Iif(Alltrim(aRet[1])==STR0020,1,Iif(Alltrim(aRet[1])==STR0021,2,3)),; //"Por Usuario"###"Tipo de Cobranca"
					Iif(Alltrim(aRet[2]) == STR0005,1,2)) //"Nao"
			Else
				PLSR580(SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_CLIENTE, SE1->E1_LOJA,;
					SE1->E1_CODINT , SE1->E1_CODINT , SE1->E1_CODEMP , SE1->E1_CODEMP ,;
					Space(Len(BA3->BA3_CONEMP)), Replicate("Z", Len(BA3->BA3_CONEMP))  ,;
					Space(Len(BA3->BA3_SUBCON)), Replicate("Z", Len(BA3->BA3_SUBCON))  ,;
					SE1->E1_MATRIC  , SE1->E1_MATRIC , SE1->E1_MESBASE, SE1->E1_ANOBASE ,;
					SE1->E1_MESBASE , SE1->E1_ANOBASE, Iif(Alltrim(aRet[1])==STR0020,1,Iif(Alltrim(aRet[1])==STR0021,2,3)),; //"Por Usuario"###"Tipo de Cobranca"
					Iif(Alltrim(aRet[2]) == STR0005,1,2)) //"Nao"
			Endif
		Endif
	Endif

Return()

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ä¿??
???Programa  ?MenuDef   ? Autor ? Darcio R. Sporl       ? Data ?05/01/2007???
?????????????????????????????????????????????????????????????????????????Ä´??
???Descri??o ? Utilizacao de menu Funcional                               ???
???          ?                                                            ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????Ä´??
???Retorno   ?Array com opcoes da rotina.                                 ???
?????????????????????????????????????????????????????????????????????????Ä´??
???Parametros?Parametros do array a Rotina:                               ???
???          ?1. Nome a aparecer no cabecalho                             ???
???          ?2. Nome da Rotina associada                                 ???
???          ?3. Reservado                                                ???
???          ?4. Tipo de Transa??o a ser efetuada:                        ???
???          ?		1 - Pesquisa e Posiciona em um Banco de Dados           ???
???          ?    2 - Simplesmente Mostra os Campos                       ???
???          ?    3 - Inclui registros no Bancos de Dados                 ???
???          ?    4 - Altera o registro corrente                          ???
???          ?    5 - Remove o registro corrente do Banco de Dados        ???
???          ?5. Nivel de acesso                                          ???
???          ?6. Habilita Menu Funcional                                  ???
?????????????????????????????????????????????????????????????????????????Ä´??
???   DATA   ? Programador   ?Manutencao efetuada                         ???
?????????????????????????????????????????????????????????????????????????Ä´??
???          ?               ?                                            ???
??????????????????????????????????????????????????????????????????????????Ù±?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
Static Function MenuDef()
	Private aRotina := { 	{ STRPL01  ,'AxPesqui'		, 0 ,K_Pesquisar   , 0, .F.},; // Pesquisar
		{ STR0025  ,'PLSA629VIS'	, 0 ,K_Visualizar  , 0, Nil},; //"Visualizar"
		{ STR0026  ,'PLSA629COM'	, 0 ,K_Visualizar  , 0, Nil},; //"Composicao"
		{ STR0027  ,'PLSA629BOL'	, 0 ,K_Visualizar  , 0, Nil},; //"Boleto"
		{ STR0028  ,'PL629Mov'   	, 0 ,K_Excluir     , 0, Nil} } //"Excluir"
Return(aRotina)

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Í»??
???Programa  ?A629Mark()?Autor  ?Geraldo Felix Junior? Data ?  10/30/07   ???
?????????????????????????????????????????????????????????????????????????Í¹??
???Desc.     ?Valida o titulo selecionado...                              ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????Í¹??
???Uso       ? AP                                                         ???
?????????????????????????????????????????????????????????????????????????Í¼??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
Function A629Mark(oMark)

	Local lRet := .T.
	Local aAreaSE1 := SE1->(GetArea())
	Local cCodTit := SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
	Local nRecMark := oMark:oBrowse:nat
	Local cNumCobranca := SE1->E1_PLNUCOB
	Local cPrefixo := SE1->E1_PREFIXO
	Local cNumTitulo := SE1->E1_NUM
	Local cParcela := SE1->E1_PARCELA

	SE1->(DbSetOrder(2))

	If (!oMark:IsMark())

		If SE1->(DbSeek(cCodTit))
			While SE1->(!Eof() ).And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA) == cCodTit

				// Atualiza campo OK
				RecLock(oMark:Alias(),.F.)
				(oMark:Alias())->E1_OK  := oMark:Mark()
				(oMark:Alias())->(MsUnLock())

				// Atualiza matriz para desmarcar os registros caso seja necessario.
				If (nPos := Ascan(aRecSE1, SE1->( Recno() ))) == 0
					Aadd(aRecSE1, SE1->( Recno() ))
				Endif

				SE1->(Dbskip())
			EndDo

			// Marca os títulos associados pelo Reembolso Patronal
			MarkTitReembPatronal(.T., @oMark, @aRecSE1, cNumCobranca, cPrefixo, cNumTitulo, cParcela)
		Endif
	Else
		If SE1->(DbSeek(cCodTit))
			While SE1->(!Eof() ).And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA) == cCodTit
				// Libera campo OK
				RecLock(oMark:Alias(),.F.)
				(oMark:Alias())->E1_OK  := ""
				(oMark:Alias())->(MsUnLock())
				// Remove registro da matriz
				If (nPos := Ascan(aRecSE1, SE1->( Recno() ))) # 0
					Adel(aRecSE1, nPos)

					If Len(aRecSE1) > 1
						ASize(aRecSE1, (Len(aRecSE1)-1))
					Else
						aRecSE1 := {}
					Endif
				Endif
				SE1->(Dbskip())
			EndDo

			// Desmarca os títulos associados pelo Reembolso Patronal
			MarkTitReembPatronal(.F., @oMark, @aRecSE1, cNumCobranca, cPrefixo, cNumTitulo, cParcela)
		Endif

	Endif

	RestArea(aAreaSE1)
	oMark:Goto(nRecMark,.T.)

Return(lRet)


/*/{Protheus.doc} DelSE2
retorna recno SE2 ligada a SE1

@author  PLS TEAM
@version P11
@since   04.01.05
/*/
static function DelSE2()
	local aRetorno	:= {}
	local cMunic    := padR(getNewPar("MV_MUNIC"),len(SE2->E2_FORNECE))
	local cLojaZero := padR("00",Len( SE2->E2_LOJA ) , "0" )
	local cForINSS 	:= padR(getNewPar("MV_FORINSS"),len(SE2->E2_FORNECE))
	local cMvIss	:= getNewPar("MV_ISS")
	local cMvInss	:= getNewPar("MV_INSS")

	if SE1->E1_ISS <> 0 .or. SE1->E1_INSS <> 0

		SE2->(dbSetOrder(1))
		if SE2->( msSeek( xFilial("SE2") + SE1->( E1_PREFIXO + E1_NUM + E1_PARCELA ) ) )

			while ! SE2->(Eof()) .and. xFilial("SE2") == SE2->E2_FILIAL .and.;
					SE1->E1_PREFIXO == SE2->E2_PREFIXO .and.;
					SE1->E1_NUM     == SE2->E2_NUM     .and.;
					SE1->E1_PARCELA == SE2->E2_PARCELA

				if allTrim(SE2->E2_NATUREZ) == alltrim( &(cMvInss) ) .and. SE2->E2_FORNECE == cForINSS .and. SE2->E2_LOJA == cLojaZero

					aadd(aRetorno, SE2->(recno()) )

				elseIf allTrim(SE2->E2_NATUREZ) == alltrim( &(cMvIss) ) .and. SE2->E2_FORNECE == cMunic .and. SE2->E2_LOJA == cLojaZero

					aadd(aRetorno, SE2->(recno()) )

				endIf

				SE2->(dbSkip())
			endDo

		endIf

	endIf

return(aRetorno)

/*/{Protheus.doc} CheckTitNCC

Verifica se o titulo utilizado na compensação do NCC teve
alguma movimentação feito pelo modulo do Financeiro

@author  Vinicius Queiros Teixeira
@since   15/01/2021
@version Protheus 12
/*/
Static Function CheckTitNCC(cChaveNCC,aRecSE1)

	Local lErro,aErro
	Local lRetorno 	:= .F.
	Local lPL629E1V := ExistBlock("PL629E1V")
	Local aSituTit
	Local aRetorPE
	Local aAreaPE
	Local cChaveFK7
	Local aAreaSE1 	:= SE1->(GetArea())

	Default aRecSE1 := {}

	SE1->(DbSetOrder(1))
	If SE1->(MsSeek( cChaveNCC ) )
		While SE1->(!Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == cChaveNCC
			If Alltrim(SE1->E1_TIPO) <> "NCC"

				lErro   := .F.
				aErro	:= {}

				//Chave para ser recuperada na FK7.
				cChaveFK7 := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +SE1->E1_CLIENTE + "|" + SE1->E1_LOJA

				lErro := CheckLancTit(cChaveFK7)

				If !lErro
					// Situação do título
					aSituTit := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)
					// Bloqueio do Calendario Contabil
					If aSituTit[1]
						lErro := .T.
					EndIf
					// TÍtulo não esta em carteira
					If aSituTit[11]
						lErro := .T.
					EndIf
					// TÍtulo em Telecobrança
					If aSituTit[12]
						lErro := .T.
					EndIf
					// Movimentação
					If aSituTit[2]
						//Verifica se o titulo foi baixado Parcialmente
						If SE1->E1_VALOR <> SE1->E1_SALDO .And. SE1->E1_SALDO > 0 .And. !aSituTit[13]
							lErro := .T.
						Else
							If !aSituTit[13] // TÍtulo Baixado
								lErro := .T.
							Endif
						EndIf
					EndIf
				EndIf

				If lPL629E1V
					aAreaPE := SE1->(GetArea())
					aRetorPE := ExecBlock("PL629E1V",.F.,.F., { SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,lErro,aErro,aRecSE1 } )
					lErro := aRetorPE[1]
					aErro := aRetorPE[2]
					RestArea(aAreaPE)
				EndIf

				If lErro // Titulo com Movimentação realizada pelo modulo do Financeiro
					lRetorno := .T.
				EndIf

			EndIf
			SE1->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSE1)

Return lRetorno

/*/{Protheus.doc} NumTitNCC

Quantidade de titulos e NCC's com a mesma numeração (Prefixo + Numero)

@author  Vinicius Queiros Teixeira
@since   15/01/2021
@version Protheus 12
/*/
Static Function NumTitNCC(cPrefixo, cNumero)

	Local nQuant	:= 1
	Local cQuery
	Local aAreaSE1 	:= SE1->(GetArea())

	cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("SE1") + " SE1 "
	cQuery += " WHERE SE1.E1_FILIAL = '"  + xFilial("SE1") + "' "
	cQuery += "   AND SE1.E1_PREFIXO = '" + cPrefixo + "' "
	cQuery += "   AND SE1.E1_NUM = '"     + cNumero + "' "
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cQuery, "CONTADOR")

	RestArea(aAreaSE1)

Return nQuant

/*/{Protheus.doc} CheckExcTit

Verifica o ultimo Titulo do SE1 gravado no SX5 para excluir

@author  Vinicius Queiros Teixeira
@since   18/01/2021
@version Protheus 12
/*/
Function CheckExcTit(cPrefixo, cNumero)

	Local lRetorno		:= .F.
	Local cFilialX5		:= xFilial("SX5")
	Local aAreaSX5		:= SX5->(GetArea())
	Local lFilX5PE		:= ExistBlock("CHGX5FIL")
	local aDadX5		:= {}

	IF lFilX5PE
		cFilialX5 := ExecBlock("CHGX5FIL",.F.,.F.)
	Endif

	aDadX5 := FWGetSX5("BK", cPrefixo)
	If len(aDadX5) > 0
		If StrZero( Val(aDadX5[1][4])-1, Len(cNumero)) == cNumero
			lRetorno := .T.
		EndIf
	EndIf

	RestArea(aAreaSX5)

Return lRetorno

/*/{Protheus.doc} CheckLancTit

Verifica se o título tem lançamentos que não seja de origem
do PLS (PLSA627)

@author  Vinicius Queiros Teixeira
@since   19/01/2021
@version Protheus 12
/*/
Function CheckLancTit(cChaveFK7,cOrigem)

	Local lRetorno	:= .F.
	Local nQuant	:= 0
	Local cIdDoc	:= ""
	Local cQuery

	Default cOrigem	:= "PLSA627"

	//Recupera o Id da FK7
	cIdDoc := FinBuscaFK7(cChaveFK7,"SE1")

	If !Empty(cIdDoc)
		cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("FK1") + " FK1 "
		cQuery += " WHERE FK1.FK1_FILIAL = '"  + xFilial("FK1") + "' "
		cQuery += "   AND FK1.FK1_IDDOC  = '" + cIdDoc + "' "
		cQuery += "   AND FK1.FK1_ORIGEM <> '" + cOrigem + "' "
		cQuery += " AND NOT EXISTS (SELECT ES.FK1_IDDOC FROM " + RetSQLName("FK1") + " ES"
		cQuery += "  WHERE FK1.FK1_FILIAL = ES.FK1_FILIAL"
		cQuery += "    AND FK1.FK1_IDDOC = ES.FK1_IDDOC"
		cQuery += "    AND FK1.FK1_SEQ = ES.FK1_SEQ"
		cQuery += "    AND ES.FK1_TPDOC = 'ES'"
		cQuery += "    AND ES.FK1_RECPAG <> 'R'"
		cQuery += "    AND ES.D_E_L_E_T_ = ' ') "
		cQuery += " AND FK1.D_E_L_E_T_ = ' ' "

		nQuant := MPSysExecScalar(cQuery, "CONTADOR")

		lRetorno := IIF(nQuant > 0, .T., .F.)
	EndIf

Return lRetorno

/*/{Protheus.doc} A629AllMark

Função para marcar/desmarcar todos os registros do browser

@author  Vinicius Queiros Teixeira
@since   20/01/2021
@version Protheus 12
/*/
Static Function A629AllMark(oMark)

	Local aAreaSE1 	:= SE1->(GetArea())
	Local nRecMark	:= oMark:oBrowse:nat
	Local nPos
	Local lRetorno	:= .T.

	SE1->(DbGoTop())
	While SE1->(!Eof())
		lMarca := !oMark:IsMark()

		RecLock(oMark:Alias(),.F.)
		(oMark:Alias())->E1_OK := IIF(lMarca,oMark:Mark(), "")
		(oMark:Alias())->(MsUnLock())

		If lMarca
			// Adiciona registro na matriz
			If (nPos := Ascan(aRecSE1, SE1->( Recno() ))) == 0
				Aadd(aRecSE1, SE1->( Recno() ))
			Endif
		Else
			// Remove registro da matriz
			If (nPos := Ascan(aRecSE1, SE1->( Recno() ))) <> 0
				Adel(aRecSE1, nPos)

				If Len(aRecSE1) > 1
					ASize(aRecSE1, (Len(aRecSE1)-1))
				Else
					aRecSE1 := {}
				Endif
			Endif
		EndIf

		SE1->(Dbskip())
	EndDo

	RestArea(aAreaSE1)
	oMark:Goto(nRecMark,.T.)

Return lRetorno

/*/{Protheus.doc} PLCheckTxAds

Verifica se o título a ser excluído tem taxa de adesão inclusa

@author  Guilherme Carreiro da Silva
@since   15/03/2022
@version Protheus 12
/*/
Static Function PLCheckTxAds(cNumCob, cBBT_PREFIX, cBBT_NUMTIT, cBBT_PARCEL, cBBT_TIPTIT)
	Local lRetorno := .F.
	Local cSql := ""
	Local nQuant := 0

	Default cNumCob := ""
	Default cBBT_PREFIX := ""
	Default cBBT_NUMTIT := ""
	Default cBBT_PARCEL := ""
	Default cBBT_TIPTIT := ""


	cSql := "SELECT COUNT(R_E_C_N_O_) CONTADOR "
	cSql += "FROM " + BM1->(RetSQLName("BM1")) + " BM1 "
	cSql += "WHERE BM1_FILIAL = '" + xFilial("BM1") + "' "
	cSql += "AND BM1_PLNUCO = '" + cNumCob + "' "
	cSql += "AND BM1_PREFIX = '" + cBBT_PREFIX + "' "
	cSql += "AND BM1_NUMTIT = '" + cBBT_NUMTIT + "' "
	cSql += "AND BM1_PARCEL = '" + cBBT_PARCEL + "' "
	cSql += "AND BM1_TIPTIT = '" + cBBT_TIPTIT + "' "
	cSql += "AND BM1_CODTIP = '103' "
	cSql += "AND BM1.D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cSql, "CONTADOR")

	lRetorno := IIF(nQuant > 0, .T., .F.)

Return lRetorno


/*/{Protheus.doc} PLChTxOp

Verifica se o título a ser excluído tem taxa de opcional

@author  José Paulo de Azevedo
@since   02/06/2022
@version Protheus 12
/*/
Static Function PLChTxOp(cNumCob, cBBT_PREFIX, cBBT_NUMTIT, cBBT_PARCEL, cBBT_TIPTIT)
	Local lRetorno := .F.
	Local cSql := ""
	Local nQuant := 0

	Default cNumCob := ""
	Default cBBT_PREFIX := ""
	Default cBBT_NUMTIT := ""
	Default cBBT_PARCEL := ""
	Default cBBT_TIPTIT := ""

	cSql := "SELECT COUNT(R_E_C_N_O_) CONTADOR "
	cSql += "FROM " + BM1->(RetSQLName("BM1")) + " BM1 "
	cSql += "WHERE BM1_FILIAL = '" + xFilial("BM1") + "' "
	cSql += "AND BM1_PLNUCO = '" + cNumCob + "' "
	cSql += "AND BM1_PREFIX = '" + cBBT_PREFIX + "' "
	cSql += "AND BM1_NUMTIT = '" + cBBT_NUMTIT + "' "
	cSql += "AND BM1_PARCEL = '" + cBBT_PARCEL + "' "
	cSql += "AND BM1_TIPTIT = '" + cBBT_TIPTIT + "' "
	cSql += "AND BM1_CODTIP = '133' "
	cSql += "AND BM1.D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cSql, "CONTADOR")

	lRetorno := IIF(nQuant > 0, .T., .F.)

Return lRetorno


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MarkTitReembPatronal
Marca/Desmarca os títulos de reembolso patronal associados 

@author Vinicius Queiros Teixeira
@since 18/08/2022
@version Protheus 12
/*/
//---------------------------------------------------------------------------------------
Static Function MarkTitReembPatronal(lMark, oMark, aRecnoSE1, cNumCobranca, cPrefixo, cNumTitulo, cParcela)

	Local nPos := 0
	Local cAliasTemp := ""
	Local cOperadora := ""
	Local cEmpresa := ""
	Local cMatricula := ""
	Local cAno := ""
	Local cMes := ""
	Local aAreaSE1 := SE1->(GetArea())

	BM1->(DbSetOrder(8))
	If BM1->(MsSeek(xFilial("BM1")+cNumCobranca+cPrefixo+cNumTitulo+cParcela))

		cOperadora := BM1->BM1_CODINT
		cEmpresa := BM1->BM1_CODEMP
		cMatricula := BM1->BM1_MATRIC
		cAno := BM1->BM1_ANO
		cMes := BM1->BM1_MES

		cAliasTemp := GetNextAlias()

		BeginSQL Alias cAliasTemp
			SELECT DISTINCT BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL FROM %Table:BM1% BM1				
				WHERE BM1.BM1_FILIAL = %XFilial:BM1% 
				  AND BM1.BM1_CODINT = %Exp:cOperadora%
				  AND BM1.BM1_CODEMP = %Exp:cEmpresa%
				  AND BM1.BM1_MATRIC = %Exp:cMatricula%
				  AND BM1.BM1_ANO = %Exp:cAno%
				  AND BM1.BM1_MES = %Exp:cMes%
				  AND BM1.BM1_PLNUCO = %Exp:cNumCobranca%
				  AND BM1.BM1_CODTIP IN ('186', '188') // Lançamentos: Reembolso patronal
				  AND BM1.BM1_NUMTIT <> %Exp:cNumTitulo%
				  AND BM1.%notDel%			
		EndSQL

		If (cAliasTemp)->(!EoF())

			SE1->(DbSetOrder(1))
			While (cAliasTemp)->(!EoF())

				If SE1->(MsSeek(xFilial("SE1")+(cAliasTemp)->(BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL)))

					While SE1->(!Eof()).And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == xFilial("SE1")+(cAliasTemp)->(BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL)

						If lMark
							RecLock(oMark:Alias(), .F.)
							(oMark:Alias())->E1_OK := oMark:Mark()
							(oMark:Alias())->(MsUnLock())
					
							nPos := Ascan(aRecnoSE1, SE1->(Recno()))

							If nPos == 0
								aAdd(aRecnoSE1, SE1->(Recno()))
							Endif
						Else
							RecLock(oMark:Alias(), .F.)
							(oMark:Alias())->E1_OK := ""
							(oMark:Alias())->(MsUnLock())

							nPos := Ascan(aRecnoSE1, SE1->(Recno()))

							If nPos <> 0
								aDel(aRecnoSE1, nPos)

								If Len(aRecnoSE1) > 1
									aSize(aRecnoSE1, (Len(aRecnoSE1)-1))
								Else
									aRecnoSE1 := {}
								Endif
							Endif	
						EndIf

						SE1->(DbSkip())
					EndDo

				EndIf

				(cAliasTemp)->(DbSkip())
			EndDo
		EndIf

		(cAliasTemp)->(DbCloseArea())

	EndIf

	RestArea(aAreaSE1)

Return