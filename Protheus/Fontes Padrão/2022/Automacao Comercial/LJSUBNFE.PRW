#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "LJSUBNFE.CH"

/*/{Protheus.doc} LJSubNFe
Funcao que realiza a substituicao de uma NF-e emitida pelo SIGALOJA
Essa funcao é responsavel pela montagem do mBrowse e suas opcoes
@type		function
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return		Nil
/*/
Function LJSubNFe()	//Substituicao NF-e

Local oBrowse
Local cQuery	:= ""
Local cAliasTmp	:= GetNextAlias()
Local aColumns	:= []

/*
Por causa de performance no carregamento do mBrowse,
somente os registros condicionados pela query serao exibidos
*/
aFiltro := GetFiltro()
If aFiltro[1]

	/*
	Os campos da mBrowse serão preenchidos pelos campos retornados do result set,
	ou seja, todos os campos da mBrowse deverao estar presente na query
	[1] campos presentes no mBrowse (A)rray
	[2] campos retornados na query	(C)aracter
	*/
	aColumns := fColumns()
	
	//passamos os campos utilizados no mBrowse para obter a query que sera realizada
	cQuery := fQuery( aColumns[2], aFiltro[2] )
	
	//
	// Instanciamento da Classe de FWBrowse
	//
	oBrowse := FWMBrowse():New()
	
	// Definição da legenda
	oBrowse:AddLegend( "F2_FIMP == ' '", "RED"	, STR0001) //"NF não transmitida"
	oBrowse:AddLegend( "F2_FIMP == 'S'", "GREEN", STR0002) //"NF Autorizada"
	oBrowse:AddLegend( "F2_FIMP == 'T'", "BLUE"	, STR0003)//"NF Transmitida"
	oBrowse:AddLegend( "F2_FIMP == 'D'", "GRAY"	, STR0004) //"NF Uso Denegado"
	oBrowse:AddLegend( "F2_FIMP == 'N'", "BLACK", STR0005)//"NF Não Autorizado"
	
	oBrowse:SetColumns( aColumns[1] )
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery( cQuery )
	oBrowse:SetAlias( cAliasTmp )	

	oBrowse:SetUseFilter(.F.)
	
	// Titulo da Browse
	oBrowse:SetDescription(STR0006)//"Substituição de NF-e emitidas pelo Controle de Lojas"
	
	// Opcionalmente pode ser desligado a exibição dos detalhes
	oBrowse:DisableDetails() 
	
	// Ativação da Classe
	oBrowse:Activate()

EndIf

Return NIL


Static Function MenuDef()

Local aRotina := {}

//usamos o campo XX_F2RECNO (obtida na query) para que seja feito o posicionamento sobre o registro original da SF2
ADD OPTION aRotina TITLE STR0007 ACTION "LjSubNFeP(XX_F2RECNO)" OPERATION 3 ACCESS 0 //"Substituição de NF-e"

Return aRotina


/*/{Protheus.doc} LjSubNFeP
Funcao macro que realiza a substituicao da NF-e.
Se realizada com sucesso, tambem é feito a sua transmissao.
@type		function
@param		nF2Recno, R_E_C_N_O_ do documento original
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return		Nil
/*/
Function LjSubNFeP(nRecnoSF2)

Local aRetERP := {}	//[1]executado com sucesso [2]nota antiga [3]nova nota

Default nRecnoSF2 := 0	//SF2.R_E_C_N_O_

//a query retorna o R_E_C_N_O_ da SF2, entao utilizamos ele para fazer o posicionamos
SF2->( DbGoTo(nRecnoSF2) )

// verifica se pode realizar a substituicao do documento
If CanSubNFe( {SF2->F2_SERIE + SF2->F2_DOC}, "55" )

	LjMsgRun( STR0008 + AllTrim(SF2->F2_DOC), STR0007, {|| aRetERP := LjSubNFeD()} ) //"Executando a substituição do documento: "##"Substituição de NF-e"

	// se foi executado com sucesso no ERP
	If aRetERP[1]
		// se no ERP foi bem sucedido, informamos qual a venda antiga e nova
		MsgInfo( STR0009 + CRLF + STR0010 + " [" + aRetERP[2] + "] " + STR0011 + ": [" + aRetERP[3] + "]") //"Substituição de documento realizado com sucesso." ##"A nota"##"foi substituida pela nota"

		// Verifica se realiza a transmissão do novo documento
		// O tratamento de mensagens sobre transmissao da NF-e esta centralizado no LjAutoNFe e suas funcoes filhos
		LjMsgRun( STR0012 + AllTrim(SF2->F2_DOC), STR0007, {|| LjAutoNFe(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)}) //"Transmitindo o novo documento: "##"Substituição de NF-e"
	Else
		MsgStop( STR0013 + CRLF + STR0014, "ERR_SUBNFE") //"Ocorreu um erro ao realizar a substituição do documento."##"Por favor, tente novamente."
	EndIf

EndIf

Return Nil


/*/{Protheus.doc} LjSubNFeD
Executa a substituição do documento fiscal. A substituição consiste em
criar um clone do documento de origem com uma nova numeracao e 
exclusao do documento original.
@type		function
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return		aRet, [1] se sucesso [2] numero antigo de DOC [3] numero novo de DOC
/*/
Function LjSubNFeD()

Local cChave	 := ""	//chave de indice
Local cOldDoc	 := ""	//numero da nota atual
Local cNewDoc	 := ""	//numero da nova nota

Local nI		 := 0
Local nPos		 := 0
Local nF2Filial	 := 0	//posicao do campo F2_FILIAL no aSF2
Local nF2Doc	 := 0	//posicao do campo F2_DOC no aSF2
Local nF2Serie	 := 0	//posicao do campo F2_SERIE no aSF2
Local nF2Cliente := 0	//posicao do campo F2_CLIENTE no aSF2
Local nF2Loja	 := 0	//posicao do campo F2_LOJA no aSF2
Local nD2Item	 := 0	//posicao do campo D2_ITEM no aSD2
Local nF2Emissao := 0	//posicao do campo F2_EMISSAO no aSF2
Local nF2Hora 	 := 0	//posicao do campo F2_HORA no aSF2
Local lRetAux	 := .T.	//retorno auxiliar
Local xValor	 := Nil	//valor do campo
Local aSF2Struct := {}	//estrutura da tabela SF2
Local aSD2Struct := {}	//estrutura da tabela SD2
Local aSD2Recno  := {}	//array com os R_E_C_N_O_S
Local aSF2		 := {}	//array com o cabecalho da nota fiscal
Local aSD2		 := {}	//array com os cabecalhos da nota fiscal
Local aSD2Aux	 := {}	//array com os itens da nota fiscal
Local aNota		 := {}	//retorno com a SERIE e o novo numero de DOC
Local aRetorno	 := {}	//retorno [1] se sucesso [2] numero antigo de DOC [3] numero novo de DOC
Local nPrcVen	 := 0   //Preço Unitário
Local nTotal	:= 0    //Total do Item
Local aTimeUF	:= {} //Data/Hora da Nota
Local cHoraRMT	:=  ""
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cDocAnt	:= ""//Pedido Anterior
Local cFilSC6 := xFilial("SC6")
Local cFilSC5 := xFilial("SC5")
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSC5 := SC5->(GetArea())

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

aSF2Struct := SF2->( DbStruct() )
aSD2Struct := SD2->( DbStruct() )

//pegamos a posicao dos campos que serao usados
nF2Filial 	:= Ascan( aSF2Struct, {|x| x[1] == "F2_FILIAL"} )
nF2Serie	:= Ascan( aSF2Struct, {|x| x[1] == "F2_SERIE"} )
nF2Doc		:= Ascan( aSF2Struct, {|x| x[1] == "F2_DOC"} )
nF2Cliente	:= Ascan( aSF2Struct, {|x| x[1] == "F2_CLIENTE"} )
nF2Loja		:= Ascan( aSF2Struct, {|x| x[1] == "F2_LOJA"} )
nF2Emissao	:= Ascan( aSF2Struct, {|x| x[1] == "F2_EMISSAO"} )
nF2Hora		:= Ascan( aSF2Struct, {|x| x[1] == "F2_HORA"} )

//
// SF2 - carrega o cabecalho do documento original
//
For nI := 1 to Len( aSF2Struct )
	//nome do campo | valor do campo | nulo
	xValor := &("SF2->" + aSF2Struct[nI][1])
	Aadd( aSF2, {aSF2Struct[nI][1], xValor, Nil} )
Next

cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")
If ValType(cHoraRMT) == "L"
	If cHoraRMT
		cHoraRMT := "1"
	Else
		cHoraRMT := "2"
	EndIf
Else
	If cHoraRMT == NIL
		cHoraRMT := "2"
	EndIf
EndIf


//
// SD2 - carrega os itens do documento original
//
SD2->( DbSetOrder(3) )	//D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA
If SD2->( DbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA) )
	
	While SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)

		//zeramos o vetor auxiliar que contem os campos do item da nota
		Asize(aSD2Aux, 0)
			
		nTotal := SD2->D2_TOTAL + SD2->D2_DESCON
		
		nPrcVen := A410Arred( nTotal / SD2->D2_QUANT, "D2_PRCVEN")

		//alimentamos o array da linha com os dados da linha
		For nI := 1 to Len( aSD2Struct )
		
			
			If aSD2Struct[nI][1] == "D2_PRCVEN"
				xValor := nPrcVen
			ElseIf aSD2Struct[nI][1] == "D2_TOTAL"
				xValor := nTotal
			Else
				xValor := &("SD2->" + aSD2Struct[nI][1])
			EndIf
			
			If aSD2Struct[nI][2] $ "C|D" .AND. Empty(xValor)
				Loop
			ElseIf aSD2Struct[nI][2] == "N" .AND. xValor == 0
				Loop
			//numero de DOC e SERIE sao gerados atraves do cabecalho
			ElseIf aSD2Struct[nI][1] $ "D2_DOC|D2_SERIE"
				Loop
			Else
				//nome do campo | valor do campo | nulo
				Aadd( aSD2Aux, {aSD2Struct[nI][1], xValor, Nil} )
			EndIf
		Next

		//adicionamos a linha ao vetor de linhas
		Aadd(aSD2, Aclone(aSD2Aux) )
	
		//armazenamos o R_E_C_N_O_ para atualizar o campo D2_ORIGLAN
		Aadd( aSD2Recno, SD2->(Recno()) )
	
		SD2->( DbSkip() )
	EndDo
	//Ordeno o Array pelo campo D2_ITEM
	aSort(aSD2,,,{|a,b| a[2][2]<b[2][2]})
	
Else
	lRetAux := .F.
	Help(" ",1,"HELP" ,NIL, STR0015, 1, 0 ) //"Itens da Venda (SD2) original não encontrados"
EndIf


If lRetAux

	/*
		ABERTURA DA TRANSACAO
	*/
	BEGIN TRANSACTION

	/*
		EXCLUSAO DA NOTA
	*/
	//alteramos o campo D2_ORIGLAN para "LF", pois senao o sistema nao permite a exclusao do livro fiscal atraves do ExecAuto do MATA920
	For nI := 1 to Len( aSD2Recno )
		SD2->( DbGoTo(aSD2Recno[nI]) )

		RecLock("SD2", .F.)
		Replace SD2->D2_ORIGLAN with "LF"
		SD2->( MsUnlock() )
	Next

	// realiza a EXCLUSAO(5) da nota via ExecAuto
	MsExecAuto( {|x,y,z| MATA920(x,y,z)}, aSF2, aSD2, 5 )
	If lMsErroAuto
		lRetAux := .F.

		If isBlind()
			LjGrvLog(SF2->(F2_DOC+F2_SERIE),MostraErro("\"))
		Else
			MostraErro()
		EndIf
	EndIf

	/*
		INCLUSAO DA NOVA NOTA
	*/
	If lRetAux
	
		//obtemos a chave do indice 2 da tabela SL1, pois substituiremos os campos _DOC do orcamento
		cChave := aSF2[nF2Filial][2] + aSF2[nF2Serie][2] + aSF2[nF2Doc][2]
	
		//obtemos uma nova numeracao com base na SERIE que esta no cabecalho da nota
		LjxDNota(aSF2[nF2Serie][2], 3, .F., 1, @aNota)

		//armazena o numero antigo e novo do DOC
		cOldDoc := aSF2[nF2Doc][2]
		cNewDoc := aNota[1][2]
	
		//troca o numero da nota F2_DOC geracao de uma nova nota
		aSF2[nF2Doc][2] := cNewDoc	//[][1]SERIE [][2]NUMERO NOTA
	
		//trocamos a data e hora de emissao, pois a nota pode ser substituida em um dia diferente da data de emissao original
		aTimeUf := { dDataBase, Time()}

		If cPaisLoc == "BRA"
			If cHoraRMT == "3" 
				aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
				aTimeUf[1] := StoD(aTimeUf[1])
			ElseIf cHoraRMT == "1" .AND. !IsBlind() 
				aTimeUf := { GetRmtDate(), GetRmtTime()}
			EndIf

		EndIf

		aSF2[nF2Emissao][2]	:= aTimeUf[1]
		aSF2[nF2Hora][2] 	:= aTimeUf[2]

		// realiza a INCLUSAO (3) da nova nota via ExecAuto
		MsExecAuto( {|x,y,z| MATA920(x,y,z)}, aSF2, aSD2, 3 )
		If lMsErroAuto
			lRetAux := .F.

			If isBlind()
				LjGrvLog(SF2->(F2_DOC+F2_SERIE),MostraErro("\"))
			Else
				MostraErro()
			EndIf
		EndIf

		/*
			ATUALIZA OS CAMPOS L1_DOC e L2_DOC NO ORCAMENTO
		*/
		If lRetAux
			// atualiza SL1
			SL1->( DbSetOrder(2) )	//L1_FILIAL + L1_SERIE + L1_DOC + L1_PDV (to do - passar em branco?)
			If SL1->( DbSeek(cChave) )
				RecLock("SL1", .F.)
				Replace SL1->L1_DOC with cNewDoc
				SL1->( MsUnlock() )
			Else
				lRetAux := .F.
				Help(" ",1,"HELP" ,NIL, STR0016, 1, 0 )//"Cabeçalho do orçamento (SL1) não encontrado"
			EndIf
		EndIf

		If lRetAux
			// atualiza SL2
			SL2->( DbSetOrder(1) )	//L2_FILIAL + L2_NUM |L2_ITEM, L2_PRODUTO|
			If SL2->( DbSeek(SL1->L1_FILIAL + SL1->L1_NUM) )

				While SL2->(!Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM
					RecLock("SL2", .F.)
					Replace SL2->L2_DOC with cNewDoc
					SL2->( MsUnlock() )

					SL2->( DbSkip() )
				EndDo
			Else
				lRetAux := .F.
				Help(" ",1,"HELP" ,NIL, STR0017, 1, 0 ) //"Itens do orçamento (SL2) não encontrado"
			EndIf
		EndIf

		/*
			ATUALIZAR OS DADOS DA NOTA GERADA COM AS INFORMACOES DA NOTA ORIGINAL
		*/
		If lRetAux
			SF2->( DbSetOrder(1) )	//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA |F2_FORMUL + F2_TIPO|
			If SF2->( DbSeek( aSF2[nF2Filial][2] + aSF2[nF2Doc][2] + aSF2[nF2Serie][2] + aSF2[nF2Cliente][2] + aSF2[nF2Loja][2] + " N") )
				RecLock("SF2", .F.)
				For nI := 1 to Len( aSF2 )
					If aSF2[nI][1] <> "F2_FIMP"	//nao atualiza o campo F2_FIMP
						xValor := &("SF2->" + aSF2[nI][1])
						
						// compara cos valores entre a venda original e a nova venda
						If aSF2[nI][2] <> xValor
							Replace &( aSF2[nI][1] ) with aSF2[nI][2]
						EndIf
					EndIf
				Next
				SF2->( MsUnlock() )
			Else
				lRetAux := .F.
				Help(" ",1,"HELP" ,NIL, STR0018, 1, 0 ) //"Cabeçalho da nova Nota Fiscal (SF2) não encontrado"
			EndIf
		EndIf
	
		If lRetAux

			// obtemos a posicao do campo D2_ITEM no array aSD2
			nD2Item := Ascan( aSD2[1], {|x| x[1] == "D2_ITEM"} )

			SD2->( DbSetOrder(3) )
			If SD2->( DbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA) )
			
				aAreaSC6 := SC6->(GetArea())
				aAreaSC5 := SC5->(GetArea())
				
				SC6->(DbSetOrder(1)) //C6_FILIAL + C6_NUM + C6_ITEM
				SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
				
				While SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
				
					nPos := Ascan( aSD2, {|x| x[nD2Item][2] == SD2->D2_ITEM} )
				
					RecLock("SD2", .F.)
					For nI := 1 to Len( aSD2[nPos] )
						//Nao atualiza os campos D2_PRCVEN e D2_TOTAL, porque no array está incluído o desconto nesses valores, pois 
						//a rotina MATA920 espera que esses valores contenham o desconto, pois no gatilho do desconto o mesmo é
						//abatido nestes campos
						If ! (aSD2[nPos][nI][1] $  "D2_EMISSAO|D2_PRCVEN|D2_TOTAL")  //Nao atualiza o campo D2_EMISSAO|D2_PRCVEN|D2_TOTAL
							xValor := &( "SD2->" + aSD2[nPos][nI][1] )
							If aSD2[nPos][nI][2] <> xValor
								Replace &( aSD2[nPos][nI][1] ) with aSD2[nPos][nI][2]
							EndIf
						EndIf
					Next
					SD2->( MsUnlock() )
					If !Empty(SD2->D2_PEDIDO) .AND. !Empty(SD2->D2_ITEMPV)	
						If SC6->(DbSeek(cFilSC6 + SD2->(D2_PEDIDO +D2_ITEMPV)))
							If Empty(cDocAnt)
								cDocAnt := SC6->C6_NOTA
								If SC5->(DbSeek(cFilSC5+SC6->C6_NUM)) 
									If SC6->C6_NOTA == SC5->C5_NOTA .AND.  SC6->C6_SERIE  == SC5->C5_SERIE
										RecLock("SC5", .F.)
										SC5->C5_NOTA  := SD2->D2_DOC
										SC5->C5_SERIE := SD2->D2_SERIE
										SC5->( MsUnlock() )
									EndIf
								Else
									lRetAux := .F.
									Help(" ",1,"HELP" ,NIL, STR0019, 1, 0 ) //"Cabeçalho do Pedido de Venda (SC5) não encontrado"
									Exit
								EndIf
							EndIf
							RecLock("SC6", .F.)
							SC6->C6_NOTA  := SD2->D2_DOC
							SC6->C6_SERIE := SD2->D2_SERIE
							SC6->C6_DATFAT := SD2->D2_EMISSAO
							SC6->( MsUnlock() )
						Else
									
							lRetAux := .F.
							Help(" ",1,"HELP" ,NIL, STR0020, 1, 0 ) //"Itens do Pedido de Venda (SC6) não encontrado"
							Exit
						EndIf

					EndIf
				
					SD2->( DbSkip() )
				EndDo
				
				RestArea(aAreaSC6)
				RestArea(aAreaSC5)
			Else
				lRetAux := .F.
				Help(" ",1,"HELP" ,NIL, STR0021, 1, 0 ) //"Itens da nova Nota Fiscal (SD2) não encontrados"
			EndIf
		EndIf

	EndIf

	//Se houve erro, DISARMA A TRANSACAO
	If !lRetAux
		DISARMTRANSACTION()
	EndIf

	END TRANSACTION

	// PONTO DE ENTRADA na finalização da substituição da Nota Fiscal (SF2 já está posicionado sobre o novo documento)
	If lRetAux .AND. ExistBlock("LJSubFim")
		ExecBlock( "LJSubFim", .F., .F., {cOldDoc,cNewDoc} )
	EndIf
	
EndIf

Aadd( aRetorno, lRetAux)
Aadd( aRetorno, cOldDoc)
Aadd( aRetorno, cNewDoc)

//zeramos os vetores
Asize(aSF2,0)
Asize(aSD2,0)
Asize(aSD2Aux,0)
Asize(aSF2Struct, 0)
Asize(aSD2Struct, 0)
Asize(aNota, 0)

Return aRetorno


/*/{Protheus.doc} fQuery
Retorna uma string no formato SQL.
Essa query sera utilizada para montagem do mBrowse.
@type		function
@param		cColumns, campos do result set da query
@param		cCondition, filtro que sera utilizado na query
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return		cQuery, query que sera utilizada na montagem do mBrowse
/*/
Static Function fQuery(cColumns, cCondition)

Local cQuery		:= ""

Default cColumns	:= ""
Default cCondition	:= ""

cQuery += "SELECT "
cQuery += 	"F2_FIMP, F2.R_E_C_N_O_ AS XX_F2RECNO, "
cQuery += cColumns
cQuery += "FROM "
cQuery += 	RetSqlName("SF2") + " F2 "
cQuery += "INNER JOIN "
cQuery += 	RetSqlName("SL1") + " L1 "
/* a condicao do inner join é baseada sobre o Indice 2 da SL1 para aumento de performance */
cQuery += "ON F2_FILIAL = L1_FILIAL "
cQuery += 	"AND F2_DOC = L1_DOC "
cQuery += 	"AND F2_SERIE = L1_SERIE "
cQuery += 	"AND F2_PDV = L1_PDV "
cQuery += 	"AND F2.D_E_L_E_T_ = L1.D_E_L_E_T_ "
cQuery += "WHERE F2.D_E_L_E_T_ = ' ' "
cQuery += 	"AND F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += 	"AND F2.F2_ESPECIE = 'SPED' "
cQuery += 	cCondition

cQuery := ChangeQuery(cQuery)

Return cQuery


/*/{Protheus.doc} fColumns
Retorna um array, onde a primeira posicao é um vetor de objetos da classe
FWBrwColumn, esses serao responsaveis pelos campos exibidos no mBrowse.
Já a segunda posicao, retorna os campos que serao retornados na query.
@type		function
@return		aRet [1] array com os campos do mBrowse [2] string com os campos que serao retornados na query
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return  	Nil
/*/
Static Function fColumns()

Local cColumns	:= ""
Local aRet 		:= {}
Local aColumns	:= {}
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )

DbSelectArea('SX3')
SX3->( DbSetOrder(1) )	//X3_ARQUIVO + X3_ORDEM
SX3->( DbSeek("SF2") )

While SX3->( !EoF() ) .AND. SX3->X3_ARQUIVO == "SF2"

	//TODO: o que é mais rapido, usar um filtro ou usar um loop?
	If SX3->X3_BROWSE == "S"
		//cria uma instancia da classe FWBrwColum
		Aadd( aColumns, FWBrwColumn():New() )

		//se for do tipo [D]ata, faz a conversao para o formato DD/MM/AAAA
		cX3Campo := AllTrim(SX3->X3_CAMPO)
		cColumns += (cX3Campo + ",")

		If SX3->X3_TIPO == "D"
			Atail(aColumns):SetData( &("{||StoD(" + cX3Campo + ")}") )
		Else
			Atail(aColumns):SetData( &("{||" + cX3Campo + "}") )
		EndIf

		Atail(aColumns):SetSize( SX3->X3_TAMANHO )
		Atail(aColumns):SetDecimal( SX3->X3_DECIMAL )
		Atail(aColumns):SetTitle( X3Titulo() )
		Atail(aColumns):SetPicture( SX3->X3_PICTURE )

		If SX3->X3_TIPO == "N"
			Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
		Else
			Atail(aColumns):SetAlign( CONTROL_ALIGN_LEFT )
		EndIf
	EndIf
	
	SX3->( DbSkip() )
End	

RestArea(aAreaSX3)
RestArea(aArea)

//retira a ultima virgula dos campos da query
cColumns := Substr(cColumns, 1, Len(cColumns)-1)

Aadd(aRet, Aclone(aColumns) )	//campos presentes na mBrowse (cada campo é um objeto da classe FWBrwColumn)
Aadd(aRet, cColumns )			//campos que serao retornados na query

//destroi o aColumns
aSize( aColumns,0 )
aColumns := Nil

Return aRet


/*/{Protheus.doc} GetFiltro
Apresenta uma tela com os parametros Periodo de Emissão, Doc e Serie. Esses campos
serao utilizados para a construção de um filtro SQL. Isso é necessário, pois o FwMBrowse
somente suporta 4096 registros quando a origem dos dados é uma query.
Além disso, há um ponto de entrada que pode omplementar essa condição.
@type		function
@return		aRet, [1] se continua a execucao [2] filtro no formato SQL
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return  	Nil
/*/
Static Function GetFiltro()

Local oFont		:= TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Local oFontNota := TFont():New("Arial",,012,,.F.,,,,,.F.,.F.)
Local oDlg
//PAINEL 1
Local oPanel1
Local oGetP1De
Local dGetP1De	:= Date()-7	//o campo 'De:' ja sugere as notas dos ultimos 7 dias
Local oGetP1Ate
Local dGetP1Ate := Date()
Local oSayP1
Local oSayP1De
Local oSayP1Ate
//PANEL 2
Local oPanel2
Local oGetP2De
Local cGetP2De	:= Space( TamSX3("F2_DOC")[1] )
Local oGetP2Ate
Local cGetP2Ate	:= Space( TamSX3("F2_DOC")[1] )
Local oGetSerie
Local cGetSerie := Space( TamSX3("F2_SERIE")[1] )
Local oSayP2
Local oSayP2De
Local oSayP2Ate
Local oSayNota
//PANEL 3
Local oPanel3
Local oBtnOk
Local oBtnNo
//
Local lRetAux		:= .F.
Local cFiltro		:= ''	// Filtro padrao baseado na Emissao, Documento e Serie
Local cFiltroUsr	:= ''	// Retorno do ponto de entrada LJFLTNFE. Deve ser no formato SQL
Local aRet			:= {}	//[1] Continua a execucao da rotina [2] Filtro no formato SQL

DEFINE MSDIALOG oDlg TITLE STR0022 FROM 000, 000  TO 310, 370 COLORS 0, 16777215 PIXEL //"Filtro para Exibição dos Documentos Fiscais"

	@ 005, 005 MSPANEL oPanel1 PROMPT "" SIZE 175, 040 OF oDlg COLORS 0, 16766935 CENTERED RAISED	
		@ 008, 010 SAY oSayP1 PROMPT STR0023 SIZE 070, 007 OF oPanel1 FONT oFont COLORS 0, 16766935 PIXEL //"* Período de Emissão"

		@ 021, 010 SAY oSayP1De PROMPT STR0024 SIZE 009, 007 OF oPanel1 FONT oFont COLORS 0, 16766935 PIXEL //"De:"
		@ 019, 025 MSGET oGetP1De VAR dGetP1De SIZE 060, 010 OF oPanel1 VALID IIf(Empty(dGetP1De),(MsgAlert(STR0026,"ERR_DE"),.F.),.T.); //"Informe o Período Inicial"
		  FONT oFont COLORS 0, 16777215 HASBUTTON PIXEL
		
		@ 021, 090 SAY oSayP1Ate PROMPT STR0025 SIZE 014, 007 OF oPanel1 FONT oFont COLORS 0, 16766935 PIXEL //"Até:"
		@ 019, 105 MSGET oGetP1Ate VAR dGetP1Ate SIZE 060, 010 OF oPanel1 VALID IIf(Empty(dGetP1Ate),(MsgAlert(STR0027,"ERR_ATE"),.F.),.T.); //"Informe o Período Final"
		  FONT oFont COLORS 0, 16777215 HASBUTTON PIXEL

	@ 050, 005 MSPANEL oPanel2 SIZE 175, 070 OF oDlg COLORS 0, 16766935 CENTERED RAISED
		@ 008, 010 SAY oSayP2 PROMPT STR0028 SIZE 060, 007 OF oPanel2 FONT oFont COLORS 0, 16766935 PIXEL //"Documento Fiscal"

		@ 021, 010 SAY oSayP2De PROMPT STR0024 SIZE 010, 007 OF oPanel2 FONT oFont COLORS 0, 16766935 PIXEL //"De:"
		@ 019, 025 MSGET oGetP2De VAR cGetP2De SIZE 060, 010 OF oPanel2 FONT oFont PICTURE "@E 999999999" COLORS 0, 16777215 PIXEL
		
		@ 021, 090 SAY oSayP2Ate PROMPT STR0025 SIZE 014, 007 OF oPanel2 FONT oFont COLORS 0, 16766935 PIXEL //"Até:"
		@ 019, 105 MSGET oGetP2Ate VAR cGetP2Ate SIZE 060, 010 OF oPanel2 FONT oFont PICTURE "@E 999999999" COLORS 0, 16777215 PIXEL
		
		@ 038, 010 SAY oSaySerie PROMPT STR0029 SIZE 014, 007 OF oPanel2 FONT oFont COLORS 0, 16766935 PIXEL //"Série"
		@ 036, 025 MSGET oGetSerie VAR cGetSerie SIZE 025, 010 OF oPanel2 FONT oFont PICTURE "@E 999" COLORS 0, 16777215 PIXEL
		
		@ 055, 010 SAY oSayNota PROMPT STR0030; //"Nota: Se não for informado um intervalo de Documentos Fiscais OU Série,"
		SIZE 300, 007 OF oPanel2 FONT oFontNota COLORS 0, 16766935 PIXEL
		@ 060, 010 SAY oSayNota PROMPT STR0031; //"serão considerados todos os documentos dentro do Período de Emissão."
		SIZE 300, 007 OF oPanel2 FONT oFontNota COLORS 0, 16766935 PIXEL

	@ 125, 005 MSPANEL oPanel3 SIZE 175, 25 OF oDlg COLORS 0, 16766935 CENTERED RAISED	
		DEFINE SBUTTON oBtnOk FROM 006, 010 TYPE 01 OF oPanel3 ACTION (lRetAux := .T.,oDlg:End()) ONSTOP STR0032 ENABLE //"Exibir" 
		DEFINE SBUTTON oBtnNo FROM 006, 050 TYPE 02 OF oPanel3 ACTION (lRetAux := .F.,oDlg:End()) ONSTOP STR0033 ENABLE  //"Cancelar"
	
	//texto que aparece no Get, caso esteja vazio
	oGetP2De:cPlaceHold	:= STR0034 //"Nro. Doc. Fiscal"
	oGetP2Ate:cPlaceHold:= STR0034 //"Nro. Doc. Fiscal" 
	oGetSerie:cPlaceHold:= STR0029 //"Série"
	
	//coloca o foco no botão Exibir
	oBtnOk:SetFocus()

ACTIVATE MSDIALOG oDlg CENTERED

//
//Faz a conversao do filtro para sintaxe SQL
//
If lRetAux
	//filtro do Periodo de Emissao
	cFiltro += "AND F2_EMISSAO BETWEEN '" + DtoS(dGetP1De) + "' AND '" + DtoS(dGetP1Ate) + "' "
	
	//filtro para o intervalo de Notas
	If !Empty(cGetP2Ate)
		cFiltro += "AND F2_DOC BETWEEN '" + cGetP2De + "' AND '" + cGetP2Ate + "' "
	EndIf
	
	//filtro para a serie
	If !Empty(cGetSerie)
		cFiltro += "AND F2_SERIE = '" + cGetSerie + "' "
	EndIf
	
	//PONTO DE ENTRADA usado para adicionar novas condicoes a query, para isso usamos as usando as tabelas SF2 e/ou SL1
	//Seu retorno devera ser no formato SQL e a partir da clausula WHERE, por exemplo: "AND F2_FIMP = 'N'"
	If ExistBlock("LJFLTNFE")
		cFiltroUsr := ExecBlock("LJFLTNFE",.F.,.F.)
		If ValType(cFiltroUsr) == "C"
			cFiltro += cFiltroUsr
		EndIf
	EndIf

EndIf

Aadd(aRet, lRetAux)
Aadd(aRet, cFiltro)

Return aRet


/*/{Protheus.doc} CanSubNFe
Em alguns cenarios, nao será possivel realizar a substituicao da NF-e
Exemplo: se ela foi emitida na modalidade DPEC.
@type		function
@param		aNFeID - Serie e Numero da Nota concatenados
@param		cModDoc - Modelo do documento eletronico
@return		lRet - indica se pode continuar com a Substituicao da NF-e
@author  	Varejo
@version 	P11
@since   	18/07/2017AD
@return  	Nil
/*/
Static Function CanSubNFe(aNFeID, cModDoc)

Local aSPED050		:= {}	//retorno da tabela SPED050
Local lRet			:= .T.	//indica se pode continuar com a substituicao

Default aNFeID	:= {}	//{SERIE+DOC}
Default cModDoc := "55"	//NF-e

If FindFunction( "LJNFCeGtID")	//LOJNFCE.PRW
	
	LjNFCeClr(1)

	aSPED050 := LjNFCeGtID( aNFeID, cModDoc )

	If Len(aSPED050) > 0
		If Len( aSPED050[1] ) > 5	//contém a posicao do STATUSDPEC
			// se a 050.MODALIDADE for [5]DPEC E o 050.STATUSDPEC = [6]autorizado E 050.STATUS <> [6]autorizado
			If aSPED050[1][3] == "5" .AND. aSPED050[1][6] == "6" .AND. aSPED050[1][4] <> "6"
				lRet := .F.
				LjGrvLog( aNFeID[1], STR0035) //"Não é possível substituir uma NF-e emitida na modalidade DPEC que não tenha sido autorizada pela SEFAZ local"

				Help(" ",1,"HELP" ,NIL, STR0036 + CRLF +; //"Não é possível substituir uma NF-e emitida na modalidade DPEC"
						STR0037 + CRLF +; //"que ainda não foi autorizada pela SEFAZ local."
						STR0038, 1, 0 ) //"Por favor, aguarde a autorização da NF-e."
			EndIf
		Else
			LjGrvLog( aNFeID[1], STR0039) //"Validacao nao realizada, pois o STATUSDPEC nao foi retornado. Por favor, atualize o programa LOJNFCE.PRW"
		EndIf
	Else
		lRet := .F.

		Help(" ",1,"HELP" ,NIL, STR0040 + CRLF +; //"Não foi retornado nenhuma informação sobre essa NF-e."
										STR0041, 1, 0 ) //"Verifique seu status no Monitor da NF-e"

		LjGrvLog( aNFeID[1], STR0042) //"Não foi retornado nenhuma informação sobre essa NF-e."
	EndIf

	//destroi os vetores
	aSize(aSPED050,0)
	aSPED050 := Nil
Else
	LjGrvLog( aNFeID[1], STR0043) //"Validacao nao realizada, pois a função LJNFCEGTID (LOJNFCE.PRW) não esta existe no repositorio"
EndIf 

aSize(aNFeID,0)
aNFeID := Nil

Return lRet
