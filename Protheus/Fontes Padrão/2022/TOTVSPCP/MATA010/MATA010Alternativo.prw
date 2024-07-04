#include 'totvs.ch'
#include 'FWMVCDef.ch'
#include 'MATA010ALTERNATIVO.ch'

Static _RunCadMVC := .T.
Static slGIESTOQ

/*/{Protheus.doc} MATA010Alternativo
Evento usado pela rotina MATA010 para o relacionamento com produtos alternativos.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294
@type classe
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17

/*/
CLASS MATA010Alternativo FROM FWModelEvent

	DATA cIDSB1Model
	DATA cIDSGIModel

	METHOD New() CONSTRUCTOR

	METHOD GridLinePosVld()
	METHOD GridLinePreVld()
	METHOD BeforeTTS()
	METHOD AfterTTS()
	METHOD ModelPosVld(oSubModel, cModelId)

ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010Alternativo
	::cIDSB1Model := "SB1MASTER"
	::cIDSGIModel := "SGIDETAIL"
Return

/*/{Protheus.doc} GridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid

@type metodo

@version P12.1.17
/*/
METHOD GridLinePosVld(oGridModel, cModelID) CLASS MATA010Alternativo
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local cProduto
	Local cCodOri
	Local nOpc := oGridModel:GetOperation()

	If cModelID == ::cIDSGIModel

		If nOpc == MODEL_OPERATION_INSERT .Or. MODEL_OPERATION_UPDATE
			cProduto := oGridModel:GetValue("GI_PRODALT")
			cCodOri  := oGridModel:GetModel():GetValue(self:cIDSB1Model, "B1_COD")

			//Verifica se esta vazio
			If Empty(cProduto)
				oGridModel:DeleteLine()
			Else
				//Valida existencia e produtos bloqueados
				If lRet
					lRet := ExistCpo('SB1',cProduto)
				EndIf

				//Bloqueia alternativo dele mesmo
				If lRet .And. cProduto == cCodOri
					Help(" ",1,"ALTERSELF")
					lRet := .F.
				EndIf

				//Bloqueia produto fantasma
				If lRet
					If oGridModel:GetModel():GetValue(::cIDSB1Model, "B1_FANTASM") == "S"
						lRet := .F.
						Help(" ",1,"ALTERFAN")

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GridLinePreVld
Quando o campo de Ordem é alterado, tem que verificar se já existe algum outro produto cadastrado nessa ordem.
Se existir e possuir interface grafica, questiona o usuario se ele quer trocar a ordem dos dois produtos.
Se não existir interface, faz a troca sem questionar.

@type metodo

@author Juliane Venteu
@since 14/03/2017
@version P12.1.17

/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS MATA010Alternativo
Local nNewOrder := xValue
Local oView := FWViewActive()
Local lUI := oView <> NIL .And. oView:GetModel():GetId() == "MATA010"
Local lRet := .T.
Local nNewLine

	If cModelID == ::cIDSGIModel
		If cId == "GI_ORDEM" .and. cAction == 'SETVALUE'
			If oSubModel:SeekLine({{"GI_ORDEM",nNewOrder}})
				nNewLine := oSubModel:GetLine()
				If nNewLine <> nLine
					If lUI
						//Caso encontre mesma ordem, verifica se troca
						If Aviso(STR0001,STR0002+cValToChar(nNewOrder)+STR0003,{STR0004,STR0005}) == 1 //Ja existe um produto alternativo nesta ordem
							_lChangeLine := .T.
						Else
							lRet := .F.
							Help(" ",1,"MT010NOTROC") //Troca não efetuada
							_lChangeLine := .F.
						EndIf
					Else
						_lChangeLine := .T.
					EndIf

					If _lChangeLine
						_nAtuLine := nLine
						_nNewLine := nNewLine
						_cAtuOrder := xCurrentValue
						_cNewOrder := xValue
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type  METHOD
@author Lucas Konrad França
@since 22/03/2019
@version P12_1_23
@param oModel  , Object   , Modelo principal
@param cModelId, Character, Id do submodelo
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS MATA010ALTERNATIVO
	Local oMdlSGI    := oModel:GetModel("SGIMASTER")
	Local oMdlSGIDet := oModel:GetModel("SGIDETAIL")
	Local cProduto   := oModel:GetModel("SB1MASTER"):GetValue("B1_COD")

	If oMdlSGI != Nil .And. oMdlSGIDet != Nil .And. oModel:GetOperation() != MODEL_OPERATION_DELETE .And. !oMdlSGIDet:IsEmpty()
		oMdlSGI:LoadValue("GI_PRODORI", cProduto)
	EndIf
Return

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
@author Douglas.Heydt
@since 24/10/2019
@version 1.0
@param 01 oModel  , Objeto  , Modelo principal
@param 02 cModelId, Caracter, Id do submodelo
@return lRet
/*/
METHOD ModelPosVld(oSubModel, cModelId) CLASS MATA010ALTERNATIVO

	Local cCodOri      := ""
	Local cProduto     := ""
	Local lRet         := .T.
	Local nIndex       := 0
	Local nLinPriAlt   := 0
	Local nTamAlt      := 0
	Local oGridModel   := oSubModel:GetModel("SGIDETAIL")

	nTamAlt := oGridModel:Length()

	//Proteção existência campo GI_ESTOQUE
	If fGIESTOQUE()

		If oSubModel:GetModel("SGIMASTER"):GetValue("GI_ESTOQUE") <> "1"

			//Valida a possível estrutura recursiva somente se for comprar o Alternativo
			//Descobre qual a linha possui a menor Ordem
			For nIndex := 1 To nTamAlt
				If !oGridModel:IsDeleted(nIndex)
					If nLinPriAlt == 0
						nLinPriAlt := nIndex
					ElseIf oGridModel:GetValue("GI_ORDEM", nIndex) < oGridModel:GetValue("GI_ORDEM", nLinPriAlt)
						nLinPriAlt := nIndex
					EndIf
				EndIf
			Next nIndex
			If nLinPriAlt > 0
				cProduto := oGridModel:GetValue("GI_PRODALT", nLinPriAlt)
				cCodOri  := oSubModel:GetModel("SB1MASTER"):GetValue("B1_COD")
				If !vldAltRec(cCodOri, cProduto)
					Help(" ",1,"ALTERREC")
					lRet := .F.
				EndIf
			EndIf

			//Valida possibilidade de Loop relacionada alternativos com regra do tipo 2 ou 3
			If lRet
				lRet := VldAltReg3(2, oSubModel:GetModel("SB1MASTER"):GetValue("B1_COD"), oGridModel)
			EndIf

		EndIf
	EndIf


Return lRet

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type  METHOD
@author Marcelo Neumann
@since 20/08/2019
@version P12
@param oModel  , Object   , Modelo principal
@param cModelId, Character, Id do submodelo
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA010ALTERNATIVO

	If oModel:GetModel("SGIDETAIL"):IsModified()
		IntProdMRP(oModel:GetModel(::cIDSB1Model):GetValue("B1_COD"))
	EndIf

Return

Static _nNewLine := 0 //Linha que possui o produto na mesma ordem escolhida
Static _nAtuLine := 0 //Linha atualmente posicionada no grid
Static _cAtuOrder := "" //Ordem atual da linha
Static _cNewOrder := "" //Nova ordem da linha
Static _lChangeLine := .F.

/*/{Protheus.doc} MTA010ChangeOrder
Gatilho para realizar a troca das linhas, caso a ordem digitada seja
igual a ordem de um produto já existente.

@protected

@author Juliane Venteu
@since 14/03/2017
@version P12.1.17

/*/
Function MTA010ChangeOrder()
Local oModel := FWModelActive()
Local oSubModel := oModel:GetModel("SGIDETAIL")
Local cRet := oSubModel:GetValue("GI_FATOR")
Local oView := FWViewActive()

	If _lChangeLine
		cNewOrder := oSubModel:GetValue("GI_ORDEM")

		oSubModel:LineShift(_nAtuLine, _nNewLine)
		oSubModel:LoadValue("GI_ORDEM",_cAtuOrder)

		oSubModel:GoLine(_nNewLine)
		oSubModel:LoadValue("GI_ORDEM",_cNewOrder)

		oSubModel:GoLine(_nAtuLine)

		oView := FWViewActive()
		If oView <> NIL
			oView:Refresh()
		EndIf

		_lChangeLine := .F.
	EndIf

Return cRet

/*/{Protheus.doc} A010AltPCP
Interface para cadastramento dos produtos alternativos (Antiga A010ProdAl)
@type  Function
@author Lucas Konrad França
@since 21/03/2019
@version P12_1_23
@param cAlias, Character, Alias do arquivo
@param nReg  , Numeric  , Número do registro
@param nOpc  , Numeric  , Número da opção selecionada
@return Nil
/*/
Function A010AltPCP(cAlias,nReg,nOpc)
	// Variaveis p/ processamento
	Local aArea 	:= GetArea()
	Local aAreaSB1 	:= SB1->(GetArea())
	Local lOk 		:= .F.
	Local nX 		:= 0
	Local nY 		:= 0
	Local lContinua := .T.

	// Variaveis p/ objetos da tela
	Local aNoFields := {"GI_FILIAL","GI_PRODORI"}
	Local aButtons 	:= {}
	Local oSize
	Local oTela, oProdOri ,	oEstoque, oTelaNew
	Local cSeek 	:= xFilial("SGI")+SB1->B1_COD
	Local bWhile 	:= {|| SGI->(GI_FILIAL+GI_PRODORI)}
	Local bFor	 	:= {|| .T.}
	Local aItemsEst := {'1='+STR0006, ; // "Valida Original; Valida Alternativo; Compra Original."
	                    '2='+STR0007, ; // "Valida Original; Valida Alternativo; Compra Alternativo."
	                    '3='+STR0008}   // "Valida Alternativo; Compra Alternativo."
	Private aHeader := {}
	Private aCols 	:= {}
	Private cProdOri:= SB1->B1_COD
	Private cComboEst := "1"
	Private aRotina	:= M010MenuX()

	_RunCadMVC := .F.

	//Verifica se e fantasma
	If RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S"
		Help(" ",1,"ALTERFAN")
		lContinua := .F.
	EndIf

	If lContinua
		//Proteção para campos novos
		dbSelectArea("SGI")
		If fGIESTOQUE()
			aAdd(aNoFields,"GI_ESTOQUE")
		EndIf

		FillGetDados(4,"SGI",1,cSeek,bWhile,bFor,aNoFields)
		If Empty(GDFieldGet("GI_ORDEM",1))
			//Se nao ha alternativos prepara para inclusao
			GDFieldPut("GI_ORDEM",StrZero(1,Len(SGI->GI_ORDEM)),1)
		Else
			//Se houver alternativos, ordena pela ordem
			aSort(aCols,,,{|x,y| x[GDFieldPos("GI_ORDEM")] < y[GDFieldPos("GI_ORDEM")]})
		EndIf

		//Calcula dimensões
		oSize := FwDefSize():New()
		oSize:AddObject( "CABECALHO",  100, 05, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "GETDADOS" ,  100, 95, .T., .T. ) // Totalmente dimensionavel

		//P.E. utilizado para calcular dimensões de percentual de tela do Cabeçalho/GetDados
		If ExistBlock("MT010SIZ")
			oSizeNew:=ExecBlock("MT010SIZ",.f.,.f.,{oSize})
			If ValType(oSizeNew) == "A"
				oSize:= aClone(oSizeNew)
			EndIf
		EndIf

		oSize:lProp 	:= .T. // Proporcional
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

		oSize:Process() 	   // Dispara os calculos

		SGI->(dbSetOrder(1))
		SGI->(dbSeek(xFilial("SGI")+cProdOri))

		If fGIESTOQUE()
			cComboEst := SGI->GI_ESTOQUE
		EndIf

		Define MSDialog oTela Title OemToAnsi(STR0009)+Space(1)+AllTrim(cProdOri); //Produto Alternativo\
		FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
		oProdOri := tSay():New(oSize:GetDimension("CABECALHO","LININI")+3 ,oSize:GetDimension("CABECALHO","COLINI"),{|| RetTitle("GI_PRODORI")},oTela,,,,,,.T.,,,110,20)
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+36 MsGet cProdOri Size 100,10 When .F. Of oTela Pixel

		If fGIESTOQUE()
			oEstoque := tSay():New(oSize:GetDimension("CABECALHO","LININI")+3 ,oSize:GetDimension("CABECALHO","COLINI")+155,{|| AllTrim(RetTitle("GI_ESTOQUE")) + ":"},oTela,,,,,,.T.,,,40,20)
			oComboEst := TComboBox():New(oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+200,{|u|if(PCount()>0,cComboEst:=u,cComboEst)},aItemsEst,160,14,oTela,,,,,,.T.,,,,,,,,,'cComboEst')
			oEstoque:SetTextAlign(1,0)
		EndIf

		//P.E. utilizado para Adicionar novos campos na getdados
		If ExistBlock("MT010GETD")
			oTelaNew:=ExecBlock("MT010GETD",.f.,.f.,{oTela})
			If ValType(oTelaNew) == "A"
				oTela := aClone(oTelaNew)
			EndIf
		EndIf

		oGetD := MsGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
			oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
			4,"PCPAltLiOK","PCPAltTuOK","+GI_ORDEM",.T.,,1,,999,"PCPAltVlFd")

		Activate MSDialog oTela On Init EnchoiceBar(oTela,{||lOk:=.T.,If(oGetD:TudoOk(),oTela:End(),lOk:=.F.)},{||oTela:End()},,aButtons)

		//Processa gravação se clicou no OK e tem linha preenchida
		If lOk .And. !Empty(GDFieldGet("GI_PRODALT",1))
			dbSelectArea("SGI")
			For nX := 1 To Len(aCols)
				If !aCols[nX,Len(aHeader)+1]
					//Grava
					If !Empty(aCols[nX,Len(aHeader)])
						//Alteracao
						msGoTo(aCols[nX,Len(aHeader)])
						RecLock("SGI",.F.)
						Replace GI_ORDEM With aCols[nX,1]
						If fGIESTOQUE()
							Replace GI_ESTOQUE With cComboEst
						EndIf
					Else
						//Inclusao
						RecLock("SGI",.T.)
						Replace GI_FILIAL  With xFilial("SGI")
						Replace GI_PRODORI With cProdOri
						Replace GI_ORDEM With aCols[nX,1] 
						If fGIESTOQUE()
							Replace GI_ESTOQUE With cComboEst
						EndIf
					EndIf
					For nY := 1 To Len(aHeader)-2
						If AllTrim(aHeader[nY,2]) # "GI_ORDEM"
							Replace &(aHeader[nY,2]) With aCols[nX,nY]
						EndIf
					Next nY
					MsUnLock()
				ElseIf !Empty(aCols[nX,Len(aHeader)])
					//Exclui
					msGoTo(aCols[nX,Len(aHeader)])
					RecLock("SGI",.F.,.T.)
					dbDelete()
					MsUnLock()
				EndIf
			Next nX

			IntProdMRP(cProdOri)
		EndIf
	EndIf

	_RunCadMVC := .T.

	RestArea(aAreaSB1)
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} PCPAltLiOK
Função de validação de linha do produto alternativo (Antiga AlterLinOk)
@type  Function
@author Lucas Konrad França
@since 21/03/2019
@version P12_1_23
@return lRet, Logical, Identifica se a linha está válida ou não.
/*/
Function PCPAltLiOK()
	Local lRet     := .T.
	Local lMT010LIN:= ExistBlock("MT010LIN")
	Local nIndex := 0
	Local cProduto := ""

	Private nEstru := 0

	//Alternativo obrigatorio
	If !aCols[n,Len(aHeader)+1] .And. Empty(GDFieldGet("GI_PRODALT",n))
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("GI_PRODALT")),3,0)
		lRet := .F.
	EndIf

	If  lMT010LIN .And. lRet
		lRet := ExecBlock("MT010LIN",.F.,.F.)
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf
	EndIf

	If lRet .And. cComboEst <> "1"
		//Analisa possivel recursividade
		For nIndex := 1 To Len(aCols)
			If aCols[nIndex][Len(aHeader)+1] == .F.
				cProduto := aCols[nIndex][2]
				Exit
			EndIf
		Next nIndex

		If !vldAltRec(cProdOri, cProduto)
			Help(" ",1,"ALTERREC")
			lRet := .F.
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} PCPAltTuOK
Função de validação de alternativos
@type  Function
@author brunno.costa
@since 10/01/2020
@version P12_1_27
@return lRet, Logical, Identifica se a alteração está válida ou não.
/*/
Function PCPAltTuOK()
	Local lRet     := .T.

	//Valida possibilidade de Loop relacionada alternativos com regra do tipo 2 ou 3
	If lRet .AND. fGIESTOQUE() .AND. cComboEst <> "1"
		lRet := VldAltReg3(1, cProdOri)
	EndIf

Return lRet

/*/{Protheus.doc} VldAltReg3
Função de validação de linha do produto alternativo (Antiga AlterLinOk)
@type  Function
@author brunno.costa
@since 08/01/2020
@version P12_1_27
@param 01 - nOpcao    , numero, indica a opcao de utilizacao.
					     		1 - Tela com aCols e aHeader
					     		2 - ModelPosVld
@param 02 - cProduto  , caracter, código do produto original
@param 03 - oGridModel, caracter, modelo da grid MVC dos itens
@return lRet, Logical, Identifica se a linha está válida ou não.
/*/

Function VldAltReg3(nOpcao, cProduto, oGridModel)

	Local aArea         := GetArea()
	Local cAlias
	Local cWhereIn      := ""
	Local cQuery        := ""
	Local nInd          := 0
	Local nIndAltern    := 0
	Local nTotal        := 0
	Local lRet          := .T.
	Local nPosDel       := 0

	//Tela com aCols e aHeader
	If nOpcao == 1
		nIndAltern := aScan(aHeader,{|x| x[2] == "GI_PRODALT"})
		nTotal     := Len(aCols)
		If nTotal > 0
			nPosDel := Len(aCols[1])
		EndIf
		For nInd := 1 to nTotal
			If !aCols[nInd][nPosDel]
				If Empty(cWhereIn)
					cWhereIn := "'" + aCols[nInd][nIndAltern] + "'"
				Else
					cWhereIn += ",'" + aCols[nInd][nIndAltern] + "'"
				EndIf
			EndIf
		Next

	//Tela MVC
	ElseIf nOpcao == 2
		nTotal := oGridModel:Length()
		For nInd := 1 to nTotal
			If !oGridModel:IsDeleted(nInd)
				If Empty(cWhereIn)
					cWhereIn := "'" + oGridModel:GetValue("GI_PRODALT", nInd) + "'"
				Else
					cWhereIn += ",'" + oGridModel:GetValue("GI_PRODALT", nInd) + "'"
				EndIf
			EndIf
		Next

	EndIf

	If !Empty(cWhereIn)
		cAlias := GetNextAlias()
		cQuery += " SELECT GI_PRODORI, GI_PRODALT, GI_ESTOQUE "
		cQuery += "   FROM " + RetSqlName( "SGI" )
		cQuery += "  WHERE GI_FILIAL  = '" + xFilial("SGI") + "'"
        cQuery += "  AND GI_PRODALT = '" + cProduto + "' "
	    cQuery += "  AND GI_PRODORI IN (" + cWhereIn + ") "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		cQuery += "    AND GI_ESTOQUE IN ('2','3') "

		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T. )

		If !(cAlias)->(Eof())
			//"Não é possível utilizar o produto '' como alternativo devido este ser Prod.Origem do alternativo '' com regra do tipo '."
			//"Utilize regra de estoque do tipo 1 ou ajuste o relacionamento do Prod.Origem '' com o alternativo ''."
			Help( ,  , "Help", ,  STR0012 + "'" + AllTrim((cAlias)->GI_PRODORI) + "'" + STR0013 + "'" + AllTrim(cProduto) + "'" + STR0014 + "'" + AllTrim((cAlias)->GI_ESTOQUE) + "'.", 1, 0, , , , , , {STR0015 + "'" + AllTrim((cAlias)->GI_PRODORI) + "'" + STR0016 + "'" + AllTrim(cProduto) + "'."} )
			lRet := .F.
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} PCPAltVlFd
Função de validação dos campos do produto alternativo (Antiga A010FldOk)
@type  Function
@author Lucas Konrad França
@since 21/03/2019
@version P12_1_23
@return lRet, Logical, Identifica se o campo digitado está válido.
/*/
Function PCPAltVlFd()
	Local lRet    := .T.
	Local cCampo  := AllTrim(Substr(ReadVar(),4))
	Local nCont   := &(ReadVar())
	Local nLinScn := aScan(aCols,{|x| x[GDFieldPos(cCampo)] == nCont })

	If cCampo == "GI_ORDEM"
		If !Empty(nLinScn) .And. nLinScn # n
			If Empty(GDFieldGet("GI_PRODALT",n))
				Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("GI_PRODALT")),3,0)
				&(ReadVar()) := GDFieldGet("GI_ORDEM",n)
				lRet := .F.
			ElseIf Aviso(STR0001,STR0002+AllTrim(GDFieldGet("GI_PRODALT",nLinScn))+STR0003,{STR0004,STR0005}) == 1 //"Atenção" - "Já existe um produto alternativo nesta ordem: " - ". Como proceder?" "Trocar" - "Abortar"
				//Caso encontre mesma ordem, verifica se troca
				aCols[nLinScn,GDFieldPos(cCampo)] := GDFieldGet(cCampo,n)
				aCols[n,GDFieldPos(cCampo)] := nCont
				M->GI_ORDEM := GDFieldGet(cCampo,nLinScn)
			Else
				//Se nao trocar retorna conteudo da memoria para o original
				&(ReadVar()) := GDFieldGet(cCampo,n)
				lRet := .F.
			EndIf
		Else
			&(ReadVar()) := GDFieldGet(cCampo,n)
		EndIf
		//Caso tenha trocado ordem, reordena
		If lRet	.And. !Empty(nLinScn)
			aSort(aCols,,,{|x,y| x[GDFieldPos(cCampo)] < y[GDFieldPos(cCampo)]})
		EndIf
	ElseIf cCampo == "GI_PRODALT" .And. A010IsMvc()
		lRet := PCPAltVld()
	EndIf

Return lRet

/*/{Protheus.doc} PCPAltVld
Função de validação do produto alternativo digitado (Antiga A010VldAlt)
@type  Function
@author Lucas Konrad França
@since 21/03/2019
@version P12_1_23
@return lRet, Logical, Identifica se o produto alternativo digitado está válido
/*/
Function PCPAltVld()
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local cProduto := ""
	Local cOrdem   := ""
	Local nPos 	   := 0
	Local cCodOri  := ""
	Local oModel   := NIL
	Local cEstoque := ""
	Local nIndex   := 0
	Local nPosDel  := Iif(Type("aHeader") == "A", Len(aHeader)+1, 0)
	Local cPrdCmpr := ""

	Private nEstru :=0

	If IsInCallStack("A381Subst")
		oModel   := FWModelActive()
		cCodOri  := oModel:getModel("SD4_MODAL"):GetValue("D4_COD")
		cProduto := oModel:GetModel('SGI_MODAL'):GetValue("GI_PRODALT")
	ElseIf _RunCadMVC
		oModel   := FWModelActive()
		cCodOri  := oModel:GetModel("SB1MASTER"):GetValue("B1_COD")
		cProduto := oModel:GetModel("SGIDETAIL"):GetValue("GI_PRODALT")
		cOrdem   := oModel:GetModel("SGIDETAIL"):GetValue("GI_ORDEM")
		If fGIESTOQUE()
			cEstoque := oModel:GetModel("SGIDETAIL"):GetValue("GI_ESTOQUE")
		EndIf
	Else
		cCodOri  := If(Type('cProdOri') == 'C',cProdOri,If(Type('M->GI_PRODORI') == 'C',M->GI_PRODORI,SGI->GI_PRODORI))
		cProduto := &(ReadVar())
	EndIf

	//Verifica se esta vazio
	If Empty(cProduto)
		Help(" ",1,"NVAZIO")
		lRet := .F.
	EndIf

	//Valida existencia e produtos bloqueados
	If lRet
		lRet := ExistCpo('SB1',cProduto)
	EndIf

	//Bloqueia alternativo dele mesmo
	If lRet .And. cProduto == cCodOri
		Help(" ",1,"ALTERSELF")
		lRet := .F.
	EndIf

	//Bloqueia produto fantasma
	If lRet
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		If RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S"
			Help(" ",1,"ALTERFAN")
			lRet := .F.
		EndIf
	EndIf

	If !Empty(oModel)
		If lRet .And. cEstoque <> "1" .And. cOrdem == "1"
			If !vldAltRec(cCodOri, cProduto)
				Help(" ",1,"ALTERREC")
				lRet := .F.
			EndIf
		EndIf
	Else

		If lRet .And. cComboEst <> "1"
			//Analisa possivel recursividade
			For nIndex := 1 To Len(aCols)
				If aCols[nIndex][nPosDel] == .F.
					cPrdCmpr := aCols[nIndex][2]
					Exit
				EndIf
			Next nIndex
			/*verifica se o produto é o primeiro registro nao deletado da grid*/
			If cProduto == cPrdCmpr
				If !vldAltRec(cCodOri, cProduto)
					Help(" ",1,"ALTERREC")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Endif

	//Verifica duplicidade
	If lRet .And. Type("aCols") == "A"
		nPos := aScan(aCols,{|x| x[GDFieldPos("GI_PRODALT")] == cProduto .And. x[nPosDel] <> .T.})
		If nPos > 0 .And. nPos # n
			Help(" ",1,"JAGRAVADO")
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} PCPAltVlDe
Identifica se será permitido excluir o produto de acordo com seus alternativos.
@type  Function
@author lucas.franca
@since 21/03/2019
@version P12
@param cProduto, Character, Código do produto que está sendo excluído
@return aRet, Array, Retorna se é permitido apagar o produto [1], e a mensagem de erro caso não seja permitido [2]
/*/
Function PCPAltVlDe(cProduto, lVldAlt)
	Local aArea     := GetArea()
	Local cAliasSGI := ""
	Local cMsg      := ""
	Local cProdSGI  := ""
	Local cQuery    := ""
	Local lApagar   := .T.

	Default lVldAlt := .T.

	If lVldAlt
		cAliasSGI := GetNextAlias()
		cQuery := ""
		cQuery += " SELECT COUNT(*) QTDREG "
		cQuery += "   FROM " + RetSqlName( "SGI" )
		cQuery += "  WHERE GI_FILIAL  = '"+xFilial("SGI") + "'"
		cQuery += "    AND GI_PRODORI = '"+cProduto+ "'"
		cQuery += "    AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSGI,.F.,.T. )

		If (cAliasSGI)->QTDREG > 0
			cMsg    := STR0010 //"Este produto possui Alternativos Vinculados"
			lApagar := .F.
		EndIf
		(cAliasSGI)->(dbCloseArea())
	EndIf
	If lApagar
		cAliasSGI := GetNextAlias()
		cQuery := ""
		cQuery += " SELECT GI_PRODORI "
		cQuery += "   FROM " + RetSqlName( "SGI" )
		cQuery += "  WHERE GI_FILIAL  = '"+xFilial("SGI") + "'"
		cQuery += "    AND GI_PRODALT = '"+cProduto+ "'"
		cQuery += "    AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSGI,.F.,.T. )

		While !(cAliasSGI)->(Eof())
			cProdSGI+= Iif(Len(cProdSGI)>0,"/","")+(cAliasSGI)->GI_PRODORI
			dbSkip()
		EndDo
		If Len(cProdSGI) > 0
			cMsg    := STR0011 + cProdSGI //"Produto Alternativo vinculado ao produto Original: "
			lApagar := .F.
		EndIf
		(cAliasSGI)->(dbCloseArea())
	Endif
	RestArea(aArea)
Return {lApagar, cMsg}

//---------------------------------------------------------
/*/{Protheus.doc} MdlSGIPCP (Antiga ModelSGI)
Função para complementar os submodelos do Model.
É necessario obter a operação do modelo, para verificar
se o usuario tem acesso a rotina nessa operação.

Foi definido para ser executado antes do activate, pois
no momento da execução da função ModelDef, não existe operação
ainda.
@author Lucas Konrad França
@since 22/03/2019
@version 1.0
/*/
//---------------------------------------------------------
Function MdlSGIPCP(oModel)
	Local aAux       := {}
	Local nPos       := aScan(oModel:aAllSubModels, {|x| x:CID == "SGIDETAIL" })
	Local oStrSGICab := NIL
	Local oStrSGIDet := NIL

	If X3Uso(GetSx3Cache("GI_ORDEM","X3_USADO"))
		If lM010Alter .And. nPos == 0
			oStrSGIDet := FWFormStruct(1, 'SGI')
			If fGIESTOQUE()
				oStrSGICab := FWFormStruct(1, 'SGI', {|cField| (AllTrim(Upper(cField)) $ "GI_PRODORI|GI_ESTOQUE") })

				oStrSGICab:SetProperty("GI_PRODORI", MODEL_FIELD_OBRIGAT, .F.)
				oStrSGICab:SetProperty("GI_ESTOQUE", MODEL_FIELD_OBRIGAT, .T.)

				//Gatilho para replicar o valor do GI_ESTOQUE para todos os alternativos.
				oStrSGICab:AddTrigger("GI_ESTOQUE", "GI_ESTOQUE",,{||ReplEstoqe()})

				oModel:AddFields("SGIMASTER","SB1MASTER",oStrSGICab)
				oModel:SetRelation('SGIMASTER', { { 'GI_FILIAL', 'xFilial("SGI")' }, { 'GI_PRODORI', 'B1_COD' } }, SGI->(IndexKey(1)) )
				oModel:GetModel('SGIMASTER'):SetOptional(.T.)
				oModel:GetModel('SGIMASTER'):SetOnlyQuery(.T.) //O modelo DETALHE que irá gravar todos os dados.
			EndIf

			aAux :=	FwStruTrigger("GI_ORDEM","GI_FATOR","MTA010ChangeOrder()")
			oStrSGIDet:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
			oStrSGIDet:SetProperty("GI_PRODORI", MODEL_FIELD_OBRIGAT, .F.)
			oStrSGIDet:SetProperty("GI_PRODALT", MODEL_FIELD_OBRIGAT, .F.)

			oModel:AddGrid("SGIDETAIL","SB1MASTER",oStrSGIDet)
			oModel:SetRelation('SGIDETAIL', { { 'GI_FILIAL', 'xFilial("SGI")' }, { 'GI_PRODORI', 'B1_COD' } }, SGI->(IndexKey(1)) )

			oModel:GetModel('SGIDETAIL'):SetOptional(.T.)
			oModel:GetModel('SGIDETAIL'):SetUniqueLine({"GI_PRODALT"})
			oModel:GetModel('SGIDETAIL'):SetUseOldGrid(.T.)

			oModel:InstallEvent("SGI.TABLE",,MATA010Alternativo():New())
		EndIf
	EndIf
Return

/*/{Protheus.doc} ViewSGIPCP (Antiga ViewAlt do MATA010M)
Função para complementar os formulários da View do MATA010.
Se o submodelo foi carregado para o model, então cria
o formulário na View.

Esse formulário não é criado na ViewDef, pois no momento
que a ViewDef é executada, não há como saber se o modelo
foi criado, uma vez que a criação desse modelo depende da
operação.

@author Lucas Konrad França
@since 22/03/2019
@version P12.1.23
/*/
Function ViewSGIPCP(oView)
	Local oStrSGIDet
	Local nPos := aScan(oView:aViews, {|x| x[VIEWS_VIEW_ID] == "FORMSGI" })

	If X3Uso(GetSx3Cache("GI_ORDEM","X3_USADO"))
		If oView:GetModel():GetModel("SGIDETAIL") <> NIL .And. nPos == 0
			oStrSGIDet:= FWFormStruct(2, 'SGI', {|cField| !(AllTrim(Upper(cField)) $ "GI_PRODORI|GI_FILIAL|GI_ESTOQUE") } )
			
			If fGIESTOQUE()
				oView:CreateHorizontalBox( 'BOXCABSGI', 10)
				oView:SetOwnerView('FORMSGICAB','BOXCABSGI')
				oView:EnableTitleView("FORMSGICAB", FwX2Nome("SGI"))
			EndIf

			oView:CreateHorizontalBox( 'BOXFORMSGI', 10)
			oView:AddGrid('FORMSGI' , oStrSGIDet,'SGIDETAIL')
			oView:SetOwnerView('FORMSGI','BOXFORMSGI')
			If !fGIESTOQUE()
				oView:EnableTitleView("FORMSGI", FwX2Nome("SGI"))
			EndIf
			oView:addIncrementField("FORMSGI", "GI_ORDEM")
		ElseIf fGIESTOQUE() .And. oView:GetModel():GetModel("SGIMASTER") == NIL
			nPos := aScan(oView:aViews, {|x| x[VIEWS_VIEW_ID] == "FORMSGICAB" })
			If nPos > 0
				aDel(oView:aViews, nPos)
				aSize(oView:aViews, Len(oView:aViews)-1)
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} ReplEstoqe
Gatilho do campo GI_ESTOQUE. Utilizado no modelo MASTER para replicar os dados para todos os alternativos.

@type Static Function
@author lucas.franca
@since 22/03/2019
@version P12
@return Nil
/*/
Static Function ReplEstoqe()
	Local oModel  := FWModelActive()
	Local oMdlSGI := oModel:GetModel("SGIDETAIL")
	Local nIndex  := 0
	Local nLine   := oMdlSGI:GetLine()

	If fGIESTOQUE()
		For nIndex := 1 To oMdlSGI:Length()
			oMdlSGI:GoLine(nIndex)
			oMdlSGI:SetValue("GI_ESTOQUE",oModel:GetModel("SGIMASTER"):GetValue("GI_ESTOQUE"))
		Next nIndex
	EndIf

	//Restaura para a linha anterior
	oMdlSGI:GoLine(nLine)
Return Nil

/*/{Protheus.doc} fGIESTOQUE()
Protecao de existencia do campo GI_ESTOQUE

@type Static Function
@author brunno.costa
@since 22/05/2019
@version P12
@return slGIESTOQ, logico, indica a existencia do campo GI_ESTOQUE
/*/
Static Function fGIESTOQUE()
	Local aArea
	If slGIESTOQ == Nil
		aArea := GetArea()
		dbSelectArea("SGI")
		If SGI->(FieldPos("GI_ESTOQUE")) > 0
			slGIESTOQ := .T.
		Else
			slGIESTOQ := .F.
		EndIf
		RestArea(aArea)
	EndIf
Return slGIESTOQ

/*/{Protheus.doc} IntProdMRP
Função para integrar o produto (estrutura - alternativos) ao MRP

@type  Function
@author marcelo.neumann
@since 21/08/2019
@version P12
@param cProduto, Character, Código do produto
@return Nil
/*/
Static Function IntProdMRP(cProduto)
	Local lx010Auto    := Iif(Type("l010Auto") == "L", l010Auto, .F.)

	//Abre uma thread para fazer a integração dos alternativos com o MRP (MTA010IEST)
	If lx010Auto
		StaticCall(MATA010PCP, IntegSG1, cProduto, .F.)
	else
		StartJob("MTA010IEST", GetEnvServer(), .F., cEmpAnt, cFilAnt, cProduto, .F.)
	EndIf

Return


/*/{Protheus.doc} vldAltRec
Verifica se a estrutura se tornará recursiva considerando os produtos alternativos.

@type  Static Function
@author lucas.franca
@since 04/03/2020
@version P12.1.30
@param cProdOri, Character, Produto original
@param cAlter  , Character, Produto alternativo
@return lValido, Logic, Indica se a estrutura se tornará recursiva
/*/
Static Function vldAltRec(cProdOri, cAlter)
	Local aEstru    := {}
	Local cAltFilho := ""
	Local nIndex    := 0
	Local nTotal    := 0
	Local lValido   := .T.

	Private aEstrutura := {}
	Private nEstru     := 0

	aEstru := aClone(Estrut(cAlter,1))
	
	nTotal := Len(aEstru)
	For nIndex := 1 To nTotal
		If aEstru[nIndex][3] == cProdOri
			lValido := .F.
			Exit
		EndIf

		If fGIESTOQUE() 
			cAltFilho := produzAlt(aEstru[nIndex][3])
			If !Empty(cAltFilho)
				If cAltFilho == cProdOri
					lValido := .F.
					Exit
				Else
					lValido := vldAltRec(cProdOri, cAltFilho)
					If !lValido
						Exit
					EndIf
				EndIf
			EndIf
		EndIf

	Next nIndex
	
	aSize(aEstru, 0)
Return lValido

/*/{Protheus.doc} produzAlt
Verifica se um produto possui alternativos configurados com 
regra do tipo 2 ou 3, onde ocorrerá a produção do produto alternativo.

@type  Static Function
@author lucas.franca
@since 26/02/2020
@version P12.1.30
@param cProduto, Character, Código do produto original para pesquisa
@return cAlterna, Character, Código do produto alternativo que será produzido
/*/
Static Function produzAlt(cProduto)
	Local cAlterna := ""
	
	SGI->(dbSetOrder(1))
	If SGI->(dbSeek(xFilial("SGI")+cProduto))
		If SGI->GI_ESTOQUE $ "2|3"
			cAlterna := SGI->GI_PRODALT
		EndIf
	EndIf
Return cAlterna

/*/{Protheus.doc} AlterTrigg
	(long_description)
	@type  Static Function
	@author christopher.miranda
	@since 15/06/2020
	@version 1.0
	@param cDescri, Char, descrição
	@return cDescri
	/*/
Function AlterTrigg(lIni)
	Local cDescri := ""
	Local aAreaSB1 := SB1->(GetArea())	

	If lIni
		cDescri := Posicione("SB1",1,xFilial("SB1")+M->GI_PRODALT,"B1_DESC")
	Else 
		cDescri := Posicione("SB1",1,xFilial("SB1")+SGI->GI_PRODALT,"B1_DESC")		
	EndIf

	RestArea( aAreaSB1 )

Return cDescri