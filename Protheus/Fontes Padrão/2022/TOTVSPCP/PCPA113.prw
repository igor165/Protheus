#INCLUDE "PROTHEUS.CH"
#Include "PCPA113.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113TipApo

Função para verificar se o produto aponta por produto SB1-B1_APOPRO = 1

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//------------------------------------------------------------------------------------------------
Function A113TipApo(cProduto)
	Local aAreaAnt	:= GetArea()
	Local lRet		:= .F. 

	dbSelectArea("SB1")
	If dbSeek(xFilial("SB1")+cProduto) 
		If SB1->(ColumnPos("B1_APOPRO")) .And. SB1->B1_APOPRO == "1"		
			lRet := .T.
		EndIF
	Endif

	RestArea(aAreaAnt)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} a113ApoPro

Função para efetuar o apontamento por produto pelo MATA250

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Function a113ApoPro(cProduto, nQtdApont, aAcho)
	Local lRet          := .T. 

	Private aArray113   := {}
	Private aNumSeq     := {}
	Private aOrdensSel  := {}
	Private lMsErroAuto := .F.
	Private nSaldoOP    := 0
	Private nSaldoTot   := 0

	PRIVATE cOPAPOPR := SuperGetMV("MV_OPAPOPR",.F.,'1')
	// 1 - Nunca irá abrir OP - utilizará as OPs que já existem
	// 2 - Sempre irá abrir OP - mesmo já existindo OP em aberto, sempre irá abrir uma nova OP.
	// 3 - Primeiro irá utilizar as OPs que já existem em aberto e caso não existir criará uma nova.

	//Buscar as OPs disponíveis para o apontamento
	If cOPAPOPR == '1' .Or. cOPAPOPR == '3'
		A113BuscOP(cProduto)
	Endif

	//Verificar se a quantidade total das OPs disponível atendem a qtd apontada
	If nSaldoTot < nQtdApont
		If cOPAPOPR == '1'
			Aviso('PCPA113',STR0001,{'Ok'}) //Saldo total das OPs disponíveis para apontamento não atende a quantidade a ser produzida.
			lRet := .F.
		Endif
	EndIF

	If lRet
		BeginTran()

			If cOPAPOPR == '2'
				lRet := A113VldSFC(cProduto)
				
				If lRet
					lRet := A113GeraOP(cProduto, nQtdApont)
				EndIf
			Else
				If cOPAPOPR == '3' .And. (nSaldoTot < nQtdApont)
					lRet := A113VldSFC(cProduto)
					
					If lRet
						lRet := A113GeraOP(cProduto, (nQtdApont-nSaldoTot))
					EndIf
				EndIf
			EndIf
			
			If lRet
				lRet := A113ProcApo(cProduto, nQtdApont)
			EndIf

			If !lRet
				DisarmTransaction()
			Endif
		EndTran()
	Endif

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113GeraOP

Função Gerar OP Automática

@author  Michele Lais Girardi
@version P12
@since   25/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113GeraOP(cProduto, nQtdApont)
	Local a650         := {}
	Local cItemGrd     := CriaVar("C2_ITEMGRD")
	Local lApontAut    := SuperGetMv("MV_PRODAUT",.F.,.F.)
	Local lPCPREVATU   := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
	Local lRet         := .T.

	Default lAutoMacao := .F.

	cNumOP := GETNUMSC2() 

	If aScan(aAcho,"D3_LOCAL")
		lLocal := M->D3_LOCAL
	Endif
	If aScan(aAcho,"D3_EMISSAO")
		dDataApo := M->D3_EMISSAO
	Endif
	If aScan(aAcho,"D3_CC")
		cCC := M->D3_CC
	Endif

	aAreaAnt := GetArea()
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
	cUM := SB1->B1_UM
	cRevisao := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ) //SB1->B1_REVATU
	RestArea(aAreaAnt)

	AADD(a650, {'C2_NUM'	 , cNumOP    ,Nil})
	AADD(a650, {'C2_ITEM'	 , '01'	     ,Nil})
	AADD(a650, {'C2_SEQUEN'  , '001'	 ,Nil})
	AADD(a650, {'C2_PRODUTO' , cProduto	 ,Nil})
	AADD(a650, {'C2_QUANT'   , nQtdApont ,Nil})
	AADD(a650, {'C2_LOCAL'   , lLocal	 ,Nil})
	AADD(a650, {'C2_DATPRI'  , dDataApo  ,Nil})
	AADD(a650, {'C2_DATPRF'  , dDataApo  ,Nil})
	AADD(a650, {'C2_EMISSAO' , dDataApo  ,Nil})
	AADD(a650, {'C2_UM'      , cUM       ,Nil})
	AADD(a650, {'C2_CC'      , cCC       ,Nil})
	AADD(a650, {'C2_REVISAO' , cRevisao  ,Nil})
	AADD(a650, {'C2_TPOP'    , 'F'       ,Nil})
	AADD(a650, {'C2_BLQAPON' , '1'       ,Nil})
	AADD(a650, {'AUTEXPLODE' , 'S'	     ,Nil})

	//Se não utiliza apontamento automático, não é necessário criar OPs intermediárias.
	If !lApontAut 
		AADD(a650, {'GERASC'  , 'N'	     ,Nil})
		AADD(a650, {'GERAOPI' , 'N'	     ,Nil})
	EndIf

	msExecAuto({|x,Y| Mata650(x,Y)},a650,3)

	If lMsErroAuto
		lRet := .F.
		IF !lAutoMacao
			Mostraerro()
		ENDIF
	Endif

	Aadd(aOrdensSel, {cNumOP+'01'+'001'+cItemGrd , nQtdApont, nQtdApont,.T.})

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113RetArray

Função para retornar array com os campos que foram informados em tela

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113RetArray()

	aArray113 := {}
	aArray113 := A113Campos()

Return aArray113

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113Perda

Função para efetuar o apontamento por produto

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113Perda(nPERDA)
	Local lRet := .T.

	If nPERDA > 0
		Aviso('PCPA113',STR0002,{'Ok'}) //Não é permitido apontar perda para apontamento por produto.
		lRet = .F.
	Endif

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113ProcApo

Função para efetuar o apontamento por produto

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Static function A113ProcApo(cProduto, nQtdApont)

	Local aMata250  := {}
	Local cOp
	Local cTotParc  := ""
	Local lOpAuto   := .F. 
	Local lRet	    := .T.
	Local nI
	Local nQuant
	Local nQtdAPO   := 0
	Local nQtdFalta := nQtdApont
	Local nSalop

	aNumSeq := {}

	For nI = 1 to len(aOrdensSel)
		
		aArray113 := {}
		aArray113 := A113Campos()
		aMata250  := aArray113		
			
		cOp := aOrdensSel[nI,1]
		nQuant := aOrdensSel[nI,2]
		lOpAuto := aOrdensSel[nI,4]

		nSaldoOP := 0
		A113BuscOP(cProduto, cOp)
		nSalop := nSaldoOP
		
		If nSalop > 0
			If nSalop >= nQtdFalta
				nQtdAPO := nQtdFalta
				nQtdFalta := 0
			Else
				nQtdAPO := nSalop
				nQtdFalta -= nQtdAPO
			EndIf

			cTotParc := Iif (nQtdAPO == nSalop, 'T','P')			

			AADD (aMata250, {"D3_PARCTOT", cTotParc, nil})
			AADD (aMata250, {"D3_QUANT", nQtdAPO, nil})
			AADD (aMata250, {"D3_OP", cOp, nil})

			//Chamar EXECAUTO
			msExecAuto({|x,y| MATA250(x,y)},aMata250,3)

			If lMsErroAuto
				lRet := .F.
				Mostraerro()
				Exit
			Endif

			If nQtdFalta == 0 
				Exit
			Endif		
		EndIf
	Next nI

	If nQtdFalta > 0  .And. lRet
		If cOPAPOPR == '1'
			Aviso('PCPA113',STR0001,{'Ok'}) //Saldo total das OPs disponíveis para apontamento não atende a quantidade a ser produzida.
			lRet := .F.
		Else
			//CRIA OP
			aArray113 := {}
			aArray113 := A113Campos()
			aMata250  := aArray113
			
			aOrdensSel := {}
			lRet := A113GeraOP(cProduto, (nQtdFalta))

			//APONTA OP
			If lRet
				AADD (aMata250, {"D3_PARCTOT", 'T', nil})
				AADD (aMata250, {"D3_QUANT", nQtdFalta, nil})
				AADD (aMata250, {"D3_OP", aOrdensSel[1,1], nil})

				//Chamar EXECAUTO
				msExecAuto({|x,y| MATA250(x,y)},aMata250,3)

				If lMsErroAuto
					lRet := .F.
					Mostraerro()
				Endif
			Endif
		Endif
	Endif
		
	If lRet
		A113GrRast()
	EndIf 

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113DelSD3

Função para excluir o registro criado na SD3 - MATA250

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113DelSD3()
	Local cQuery := ""
	Local nX

	cQuery := "DELETE FROM "
	cQuery += RetSqlName("SD3")+" "
	cQuery += " WHERE D3_FILIAL = '" + xFilial('SD3')+ "'"
	cQuery += " AND D3_CF = ' ' "
	cQuery += " AND D3_OP = ' ' "

	For nX = 1 to 6
		cQuery += " AND  "+aArray113[nX,1]+"  = '" +aArray113[nX,2]+ "' "	
	Next nX

	cQuery += " AND D_E_L_E_T_ = ' ' "
			
	TcSqlExec(cQuery)

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113Campos

Função para carregar os valores informados em tela - MATA250

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function A113Campos()

	If aScan(aAcho,"D3_TM")
		AADD (aArray113, {"D3_TM", M->D3_TM, nil})
	Endif

	If aScan(aAcho,"D3_COD")
		AADD (aArray113, {"D3_COD", M->D3_COD, nil})
	Endif

	If aScan(aAcho,"D3_UM")
		AADD (aArray113, {"D3_UM", M->D3_UM, nil})
	Endif	

	If aScan(aAcho,"D3_CONTA")
		AADD (aArray113, {"D3_CONTA", M->D3_CONTA, nil})
	Endif

	If aScan(aAcho,"D3_LOCAL")
		AADD (aArray113, {"D3_LOCAL", M->D3_LOCAL, nil})
	Endif

	If aScan(aAcho,"D3_DOC")
		AADD (aArray113, {"D3_DOC", M->D3_DOC, nil})
	Endif

	If aScan(aAcho,"D3_EMISSAO")
		AADD (aArray113, {"D3_EMISSAO", M->D3_EMISSAO, nil})
	Endif

	If aScan(aAcho,"D3_CC")
		AADD (aArray113, {"D3_CC", M->D3_CC, nil})
	Endif

	If aScan(aAcho,"D3_SEGUM")
		AADD (aArray113, {"D3_SEGUM", M->D3_SEGUM, nil})
	Endif

	If aScan(aAcho,"D3_QTSEGUM")
		AADD (aArray113, {"D3_QTSEGUM", M->D3_QTSEGUM, nil})
	Endif

	If aScan(aAcho,"D3_PERDA")
		AADD (aArray113, {"D3_PERDA", M->D3_PERDA, nil})
	Endif

	If aScan(aAcho,"D3_LOTECTL")
		AADD (aArray113, {"D3_LOTECTL", M->D3_LOTECTL, nil})
	Endif

	If aScan(aAcho,"D3_NUMLOTE")
		AADD (aArray113, {"D3_NUMLOTE", M->D3_NUMLOTE, nil})
	Endif

	If aScan(aAcho,"D3_DTVALID")
		AADD (aArray113, {"D3_DTVALID", M->D3_DTVALID, nil})
	Endif

	If aScan(aAcho,"D3_LOCALIZ")
		AADD (aArray113, {"D3_LOCALIZ", M->D3_LOCALIZ, nil})
	Endif

	If aScan(aAcho,"D3_NUMSERI")
		AADD (aArray113, {"D3_NUMSERI", M->D3_NUMSERI, nil})
	Endif

	If aScan(aAcho,"D3_SERVIC")
		AADD (aArray113, {"D3_SERVIC", M->D3_SERVIC, nil})
	Endif

	If aScan(aAcho,"D3_POTENCI")
		AADD (aArray113, {"D3_POTENCI", M->D3_POTENCI, nil})
	Endif

	If aScan(aAcho,"D3_NODIA")
		AADD (aArray113, {"D3_NODIA", M->D3_NODIA, nil})
	Endif

	If aScan(aAcho,"D3_QTGANHO")
		AADD (aArray113, {"D3_QTGANHO", M->D3_QTGANHO, nil})
	Endif

	If aScan(aAcho,"D3_QTMAIOR")
		AADD (aArray113, {"D3_QTMAIOR", M->D3_QTMAIOR, nil})
	Endif

	If aScan(aAcho,"D3_PERIMP")
		AADD (aArray113, {"D3_PERIMP", M->D3_PERIMP, nil})
	Endif

	If aScan(aAcho,"D3_CODLAN")
		AADD (aArray113, {"D3_CODLAN", M->D3_CODLAN, nil})
	Endif

Return aArray113

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113BuscOP

Função para buscar as ordens que podem ser apontadas por produto

@author  Michele Lais Girardi
@version P12
@since   09/08/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function A113BuscOP(cProduto, cOpPar)
	
	Local aAreaAnt   := {}
	Local cAlias     := ""
	Local cItem      := ""
	Local cItemGrd   := ""	
	Local cNum       := ""
	Local cQuery     := ""
	Local cSequen    := ""
	Local cOp        := ""
	Local nSaldo     := 0
	Local nQuant     := 0
	Local nDecs      := TamSX3("C2_QUANT")[2]
	Local nSalop     := NoRound(0, nDecs) // Forçar valor zero com casa decimais do SX3
	Local lIntSFC	 := IntegraSFC()
	Local lPerdInf   := SuperGetMV("MV_PERDINF",.F.,.F.)
	Local lRet       := .T.

		If Empty(cOpPar)
			aOrdensSel := {}
			nSaldoTot  := 0
		EndIf

		cAlias  := GetNextAlias()

		cQuery := " SELECT SC2.C2_NUM     NUM, "
		cQuery += "        SC2.C2_ITEM    ITEM, "
		cQuery += "        SC2.C2_SEQUEN  SEQUEN, "
		cQuery += "        SC2.C2_ITEMGRD ITEMGRD, "
		cQuery += "        SC2.C2_QUANT   QUANTIDADE, "

		If lPerdInf
			cQuery += "	(SC2.C2_QUANT - SC2.C2_QUJE - SC2.C2_PERDA) SALDO "
		Else
			cQuery += "	(SC2.C2_QUANT - SC2.C2_QUJE) SALDO "
		EndIf	
	
		cQuery += "   FROM " + RetSqlName("SC2") + " SC2 "
		cQuery += "  WHERE SC2.C2_FILIAL  = '" + xFilial( "SC2" ) + "'"
		cQuery += "    AND SC2.C2_PRODUTO = '" +cProduto+ "'"
		cQuery += "    AND SC2.C2_BATCH   = 'S' "
		cQuery += "    AND SC2.C2_TPOP    = 'F' "
		
		If Empty(cOpPar) .And. SC2->(ColumnPos("C2_BLQAPON"))
			cQuery += "    AND SC2.C2_BLQAPON <> '1' "
		EndIf
		
		cQuery += "    AND SC2.C2_DATRF   = ' ' "
		cQuery += "    AND SC2.D_E_L_E_T_ = ' ' "
		cQuery += "  ORDER BY SC2.C2_DATPRF, SC2.C2_NUM "
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		While (cAlias)->(!Eof())
		
			cNum     := (cAlias)->(NUM)
			cItem    := (cAlias)->(ITEM)
			cSequen  := (cAlias)->(SEQUEN)
			cItemGrd := (cAlias)->(ITEMGRD)
			nQuant   := (cAlias)->(QUANTIDADE)
			nSaldo   := (cAlias)->(SALDO)

			cOp := cNum+cItem+cSequen+cItemGrd

			If !Empty(cOpPar)
				If cOp == cOpPar
					nSaldoOP := Max(0,NoRound(nSaldo))
					Exit
				Endif
			Else
				//Se existir na SH6 não deverá considerar a ordem para apontamento
				//OP apontada por operação.
				aAreaAnt	:= GetArea()
				lRet := .T.
				dbSelectArea("SH6")
				dbSetOrder(2)		
				If dbSeek(xFilial("SH6")+cProduto+cOp) 
					lRet := .F.
				Endif
				RestArea(aAreaAnt)
				
				//Se a OP estiver integrada no SFC não deverá considerar para o apontamento por produto
				If lRet .And. lIntSFC
					CYQ->(dbSetOrder(1))
					lRet:= !CYQ->(dbSeek(xFilial("CYQ")+cOp))
				EndIf

				If lRet
					nSalop := Max(0,NoRound(nSaldo))

					If nSalop > 0
						nSaldoTot += nSalop      	
						Aadd(aOrdensSel, {cOp , nQuant, nSalop,.F.})
					EndIf
				EndIf			
			Endif
			(cAlias)->(dbSkip())      	
		End
Return 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113BlqApo

Função que verifica se a OP está Bloqueada para Apontamento

@author  Michele Lais Girardi
@version P12
@since   27/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113BlqApo(cOp)
	Local lRet     := .T.
	Local aAreaAnt := GetArea()

	If Type('aOrdensSel') == 'A'

	Else
		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek(xFilial("SC2")+cOp) .And. SC2->(ColumnPos("C2_BLQAPON"))
			If SC2->C2_BLQAPON == '1'
				Aviso('PCPA113',STR0003,{'Ok'}) //Não é permitido apontar uma Ordem de Produção criada automaticamente para o Apontamento por Produto.
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaAnt)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113GetSeq

Retorna a próxima sequência a ser usada para gerar a rastreabilidade dos apontamento pro produto

@author  Michele Lais Girardi
@version P12
@since   29/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113GetSeq()

	Local aArea    := GetArea()
	Local cSeqRast := ""

	If TableInDic("SOI",.F.)
		cSeqRast:=GetSxENum("SOI","OI_SEQRAST")

		dbSelectArea("SOI")
		dbSetOrder(1)
		While SOI->(dbSeek(xFilial("SOI")+cSeqRast))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cNumOp := GetSxENum("SOI","OI_SEQRAST")
		EndDo

		ConfirmSX8()
	EndIf

	RestArea(aArea)

Return(cSeqRast)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113GrRast

Grava rastreabilidade dos apontamentos efetuados.

@author  Michele Lais Girardi
@version P12
@since   29/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113GrRast()

	Local aArea    := GetArea()
	Local cSeqRast := A113GetSeq()
	Local nI := 0

	If TableInDic("SOI",.F.)
		For nI = 1 to LEN(aNumSeq)	
			RecLock("SOI",.T.)	
			Replace	OI_FILIAL	With xFilial("SOI")
			Replace OI_SEQRAST  With cSeqRast
			Replace OI_SEQAPON  With aNumSeq[nI,1]
			MsUnLock()
		Next nI
	EndIf

	RestArea(aArea)

Return nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113SetD3

Retorna as sequências apontadas pelo apontamento de produto

@author  Michele Lais Girardi
@version P12
@since   29/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Function A113SetD3(cNumSeq)

	If Type('aNumSeq') == 'A'
		Aadd (aNumSeq , {cNumSeq} )
	Endif

Return nil


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A113VldSFC

Valida de possuir integração com o SFC, se possuir não pode criar OP automática

@author  Michele Lais Girardi
@version P12
@since   29/09/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function A113VldSFC(cProduto)
	Local cRoteiro := StrZero(1,TamSX3("G2_CODIGO")[1])
	Local lRet     := .T.
	Local lIntSFC  := IntegraSFC()

	If lIntSFC
		SG2->(dbSetOrder(1))
		If SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))
			Aviso('PCPA113',STR0004,{'Ok'}) //'Não é possível criar OP automaticamente para produtos que possuem integração com o Chão de Fábrica.'
			lRet := .F.
		EndIf
	EndIf

Return lRet
