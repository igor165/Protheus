#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __nDecPeso	:= SuperGetMV("MV_OGDECPS",,0)

//===================================================================================
/*****  Funções relacionadas a classificação - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} AGRX500TTD
//Cria tabela temporaria para NJK
@author carlos.augusto
@since 09/02/2018
@version undefined
@param cNJKAux, characters, descricao
@type function
/*/
Function AGRX500TTD(cNJKAux)
	Local oNJKTEMP
	Local aStrColh	:= AGRX500TTK() //Estrutura da TT
	
	cNJKAux := GetNextAlias()
	oNJKTEMP := FwTemporaryTable():New(cNJKAux)
	oNJKTEMP:SetFields(aStrColh)
	oNJKTEMP:AddIndex("1",{"NJK_FILIAL","NJK_ITEM"})
	oNJKTEMP:Create()
		
Return cNJKAux


/*/{Protheus.doc} AGRX500TTK
//Gera estrutura de tabela temporaria semelhante a NJK
@author carlos.augusto
@since 09/02/2018
@version undefined

@type function
/*/
Function AGRX500TTK()
	Local aNJKTEMP := {}
	Local nY
	Local oModel := FwModelActive()
	Local aCpoNJK := oModel:GetModel("AGRA500_NJK"):GetStruct():GetFields()

	For nY := 1 to Len(aCpoNJK)
		If aCpoNJK[nY][3] == "NJK_TPCLAS"		//Tipo Classificação
			aAdd(aNJKTEMP,{ aCpoNJK[nY][3], aCpoNJK[nY][4], 10, aCpoNJK[nY][6], aCpoNJK[nY][1] , PesqPict("NJK", aCpoNJK[nY][3])})
		ElseIf aCpoNJK[nY][3] == "NJK_OBRGT"	//Desconto Obrigatório
			aAdd(aNJKTEMP,{ aCpoNJK[nY][3], aCpoNJK[nY][4], 4, aCpoNJK[nY][6], aCpoNJK[nY][1] , PesqPict("NJK", aCpoNJK[nY][3])})
		ElseIf aCpoNJK[nY][3] == "NJK_RESINF"	//Resultado Informado?
			aAdd(aNJKTEMP,{ aCpoNJK[nY][3], aCpoNJK[nY][4], 16, aCpoNJK[nY][6], aCpoNJK[nY][1] , PesqPict("NJK", aCpoNJK[nY][3])})
		Else
			aAdd(aNJKTEMP,{ aCpoNJK[nY][3], aCpoNJK[nY][4], aCpoNJK[nY][5], aCpoNJK[nY][6], aCpoNJK[nY][1] , PesqPict("NJK", aCpoNJK[nY][3])})
		End
	Next nY

Return aNJKTEMP


/*/{Protheus.doc} AGRX500TTC
//Realiza a carga da tabela temporaria de acordo com o modelo da NJK
@author carlos.augusto
@since 09/02/2018
@version undefined

@type function
/*/
Function AGRX500TTC(_cNJKTEMP)
	Local oModel	 := FwModelActive()
	Local oNJKActive := oModel:GetModel( "AGRA500_NJK" )
	Local nX, nY
	Local aCpoNJK 	 := oModel:GetModel("AGRA500_NJK"):GetStruct():GetFields()

	For nX := 1 to oNJKActive:Length()
		oNJKActive:GoLine( nX )
		If RecLock(_cNJKTEMP, .T.) //Cria registro vinculando o fardinho ao bloco
		For nY := 1 to Len(aCpoNJK)
			If aCpoNJK[nY][3] == "NJK_TPCLAS"		//Tipo Classificação
				&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nY][3])) := If( oNJKActive:GetValue( ALLTRIM(aCpoNJK[nY][3]) ) == '1', STR0054, STR0055) //'Origem', 'Destino'
			ElseIf aCpoNJK[nY][3] == "NJK_OBRGT"	//Desconto Obrigatório
				&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nY][3])) := If( oNJKActive:GetValue( ALLTRIM(aCpoNJK[nY][3]) ) == '1', STR0056, STR0057) //'Sim', 'Não'
			ElseIf aCpoNJK[nY][3] == "NJK_RESINF"	//Resultado Informado?
				&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nY][3])) := If( oNJKActive:GetValue( ALLTRIM(aCpoNJK[nY][3]) ) == '1', STR0058, STR0058) //'Informativo', 'Não Informativo'
			Else
				&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nY][3])) := oNJKActive:GetValue( ALLTRIM(aCpoNJK[nY][3]) )
			EndIf
		Next nY
			(_cNJKTEMP)->(MsUnlock())
		Endif				
	Next nX
Return _cNJKTEMP


/*/{Protheus.doc} AGRX500CLA
//Apresenta a dialog de classificacao
@author carlos.augusto
@since 09/02/2018
@version undefined
@param cNJKTEMP, characters, descricao
@type function
/*/
Function AGRX500CLA(_cNJKTEMP)
	Local aArea       	:= GetArea()
	Local oDlgNJK     	:= Nil
	Local oFwLayer    	:= Nil
	Local oPnFardinho 	:= Nil
	Local oSize       	:= Nil
	Local nx
	Local aStruDXK    	:= AGRX500TTK()
	Local aColunaMala 	:= {}
	Local nCol
	Local nColEdit
	Private _oBrwClass  := Nil
		  
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlgNJK := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] * 0.65, oSize:aWindSize[4] * 0.65,;
	STR0022 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlgNJK, .f., .t. )

	oFWLayer:AddLine( 'GRID', 100, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'GRID' )
	oPnFardinho := oFWLayer:GetColPanel( 'ALL', 'GRID' )

	//Criação e instância do browse de fardos de malas
	_oBrwClass := FWFormBrowse():New()
	_oBrwClass:SetOwner(oPnFardinho)
	_oBrwClass:SetDataTable(.T.)
	_oBrwClass:SetTemporary(.T.)
	_oBrwClass:SetAlias(_cNJKTEMP)
	_oBrwClass:SetDescription(STR0022)  /*"Itens de Classificação"  */
	_oBrwClass:SetProfileID("_oBrwClass")
	
	_oBrwClass:SetDBFFilter(.T.)
	
	//Monta as colunas desconsiderando os campos abaixo
	nCol := 1
	For nX := 1 to Len(aStruDXK)
		If !(aStruDXK[nX,1] $ "NJK_FILIAL,NJK_RESINF")
			aAdd(aColunaMala,FWBrwColumn():New())
			aColunaMala[nCol]:SetData(&("{||"+aStruDXK[nX,1]+"}"))
			aColunaMala[nCol]:SetTitle(aStruDXK[nX,5])
			aColunaMala[nCol]:SetPicture(aStruDXK[nX,6])
			aColunaMala[nCol]:SetType(aStruDXK[nX,2])
			If aStruDXK[nX,1] == "NJK_TPCLAS"		//Tipo Classificação
				aColunaMala[nCol]:SetSize(10)
			ElseIf aStruDXK[nX,1] == "NJK_OBRGT"	//Desconto Obrigatório
				aColunaMala[nCol]:SetSize(4)	
			ElseIf aStruDXK[nX,1] == "NJK_RESINF"	//Resultado Informado?
				aColunaMala[nCol]:SetSize(16)
			Else
				aColunaMala[nCol]:SetSize(aStruDXK[nX,3])
			EndIf
			aColunaMala[nCol]:SetReadVar(aStruDXK[nX,1])
			If aStruDXK[nX,1] == "NJK_PERDES"
				nColEdit := nCol
			EndIf
			nCol++
		EndIf	
	Next nX
    
	_oBrwClass:SetColumns(aColunaMala)
	_oBrwClass:AddButton(STR0021 /* Ok */,{|| AlteraStatus(), oDlgNJK:End() })	
	_oBrwClass:DisableDetails()
	_oBrwClass:SetDoubleClick({|| AGRX500NNK(_cNJKTEMP,(_cNJKTEMP)->NJK_ITEM, FwFldGet('NJJ_TABELA'), (_cNJKTEMP)->NJK_CODDES)/* ,_oBrwClass:Refresh()*/ })			
	_oBrwClass:Activate()

	_oBrwClass:SetEditCell(.T.) 						//indica que o grid e editavel
	_oBrwClass:acolumns[nColEdit]:ledit := .t.
	_oBrwClass:acolumns[nColEdit]:bValid := {|| IIF(ValidRes(_cNJKTEMP,(_cNJKTEMP)->NJK_ITEM, (_cNJKTEMP)->NJK_CODDES, (_cNJKTEMP)->NJK_PERDES) ,_oBrwClass:Refresh(),.F.)}

	oDlgNJK:Activate( , , , .t., { || .t. }, ,  )

	RestArea(aArea)
Return .T.


/*/{Protheus.doc} ValidRes
//Valida campo resultado digitado na tela de classificacao
@author carlos.augusto
@since 09/02/2018
@version undefined
@param cItem, characters, descricao
@param cCodDes, characters, descricao
@param nPerDesc, numeric, descricao
@type function
/*/
Static Function ValidRes(_cNJKTEMP, cItem, cCodDes, nPerDesc)
	//Local aRows := FwSaveRows()
	Local lRet 	:= .T.

	lRet := AGX500DES(cCodDes, nPerDesc)
	If lRet
		lRet := AGRX500UPN(_cNJKTEMP, cItem, nPerDesc)
	EndIf
	
	//FwRestRows(aRows)
	(_cNJKTEMP)->(dbGoTop())
	_oBrwClass:Refresh()
	
	AlteraStatus()
Return lRet


/*{Protheus.doc} OGA250DES/AGX500DES
Função para tratar quando o tipo for Faixa ou Percentual 
da tabela de classificação/descontos
Função validação do campo NJK_PERDES

@author 	ana.olegini
@since 		23/06/2016
@version 	1.0
@return 	lContinua, Lógico [.T. = True - .F. = Falso]
*/
Function AGX500DES(cCodDes, nPerDesc)
	Local lContinua := .T.
	Local oModel	:= FwModelActive()
	Local oNJJ 		:= oModel:GetModel( "AGRA500_NJJ" )

	Local cTabela	:= oNJJ:GetValue("NJJ_TABELA")
	Local cDescon	:= cCodDes
	Local nPerDes	:= nPerDesc

	Local cTipoRes	:= Posicione( "NNJ", 1, xFilial("NNJ") + cTabela + cDescon, "NNJ_TIPRES" )

	//-- Se o Tipo do Resultado for Percentual [P]
	If cTipoRes == "P"
		//-- Se o Percentual Inicial OU Final for maior que 99.99 - retorna Falso
		If nPerDes > 99.99 
			lContinua := .F.
			Help('' ,1,".AGRX50000001.", , ,1,0) //"O tipo de resultado é percentual."#"Por Favor, informe um valor até 99,99"
		EndIf 		
	EndIf 

	//-- Se o Tipo do Resultado for Faixa [F]
	If cTipoRes == "F"
		//-- Se a Faixa Inicial OU Final for maior que 99999.99 - retorna Falso
		If nPerDes > 99999.99 
			lContinua := .F.
			Help('' ,1,".AGRX50000002.", , ,1,0) //"O tipo de resultado é faixa."#"Por Favor, informe um valor até 99999,99"
		EndIf 		
	EndIf 

Return(lContinua)


/*/{Protheus.doc} AGRX500UPN
//Atualiza a dialog de classificacao quando eh realizada alguma alteracao
@author carlos.augusto
@since 09/02/2018
@version undefined
@param cItem, characters, descricao
@param nResCons, numeric, descricao
@param cDesCons, characters, descricao
@type function
/*/
Function AGRX500UPN(_cNJKTEMP, cItem, nResCons, cDesCons)
	Local oModel	 := FwModelActive()
	Local oNJKActive := oModel:GetModel( "AGRA500_NJK" )
	Local lValid
	Local nX
	Local aCpoNJK 	 := oModel:GetModel("AGRA500_NJK"):GetStruct():GetFields()
	
	//Alterar o resultado no modelo
	For nX := 1 to oNJKActive:Length()
		oNJKActive:GoLine( nX )
		If oNJKActive:GetValue( "NJK_ITEM") == cItem
			lValid := oNJKActive:SetValue( "NJK_PERDES", nResCons) //dispara valid do campo OGA250DES()  .AND. AGRX500Recalcula(.F.)
			If cDesCons != Nil .And. lValid
				oNJKActive:SetValue( "NJK_DESRES", cDesCons)
				oNJKActive:SetValue( "NJK_RESINF", "1")
			EndIf
			exit
		EndIf
	Next nX
	
	If lValid //Altera somente a linha
		If (_cNJKTEMP)->(MsSeek(FwXFilial("NJK") + StrZero( _oBrwClass:At(), TamSX3( "NJK_ITEM" )[1], 0 )))
			If RecLock(_cNJKTEMP, .F.) 
				For nX := 1 to Len(aCpoNJK)
					//&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nX][3])) := oNJKActive:GetValue( ALLTRIM(aCpoNJK[nX][3]) )
					If aCpoNJK[nX][3] == "NJK_TPCLAS"		//Tipo Classificação
						&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nX][3])) := If( oNJKActive:GetValue( ALLTRIM(aCpoNJK[nX][3]) ) == '1', STR0054, STR0055) //'Origem', 'Destino'
					ElseIf aCpoNJK[nX][3] == "NJK_OBRGT"	//Desconto Obrigatório
						&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nX][3])) := If( oNJKActive:GetValue( ALLTRIM(aCpoNJK[nX][3]) ) == '1', STR0056, STR0057) //'Sim', 'Não'
					ElseIf aCpoNJK[nX][3] == "NJK_RESINF"	//Resultado Informado?
						&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nX][3])) := If( oNJKActive:GetValue( ALLTRIM(aCpoNJK[nX][3]) ) == '1', STR0058, STR0058) //'Informativo', 'Não Informativo'
					Else
						&('(_cNJKTEMP)->' + ALLTRIM(aCpoNJK[nX][3])) := oNJKActive:GetValue( ALLTRIM(aCpoNJK[nX][3]) )
					EndIf				
				Next nX
					(_cNJKTEMP)->NJK_RESINF := "1"
					(_cNJKTEMP)->(MsUnlock())
			Endif
		EndIf
	EndIf
	
Return lValid


/** {Protheus.doc} OGA250NNKF3/AGRX500NNK
Consulta customizada para os itens de classificação

@param:	Nil
@author: 	Bruna Rocio
@since: 	25/06/2014
@Uso: 		OGA250 - Romaneio
*/
Function AGRX500NNK(_cNJKTEMP, cItem, cTabela, cCodDes)
//	Local aAreaAtu	:= GetArea()
	Local nOpcX		:= 0
	Local nOpcao		:= 0
	Local aButtons	:= {}
	Local nTamH 		:= ( GetScreenRes()[1] - 400 )
	Local nTamV 		:= ( GetScreenRes()[2] - 400 )
	Local aItens	    := {}

	Private _oDlg		:= Nil
	Private _oBrowse	:= Nil
	Private _aColunas	:= { STR0013, STR0014, STR0015, STR0016, STR0017, STR0018, STR0019, STR0020 }  

	BeginSql Alias "NNKPes"

	Select *
	From %Table:NNK% NNK 
	Where
	NNK.NNK_FILIAL  = %xFilial:NNK%  And
	NNK.NNK_CODTAB  = %Exp:cTabela%  And
	NNK.NNK_CODDES  = %Exp:cCodDes%  And
	NNK.%notDel%
	EndSql 

	While .Not. NNKPes->( Eof() )
		aAdd(aItens , { NNKPes->( NNK_SEQ ), NNKPes->( NNK_PERINI), NNKPes->( NNK_PERFIM ), NNKPes->( NNK_DESRES ), NNKPes->( NNK_PERDES ), NNKPes->( NNK_TABALT ), NNKPes->( NNK_PROALT )})
		NNKPes->( dbSkip() )
	EndDo 
	NNKPes->(dbCloseArea())

	If Len( aItens ) > 0
		_oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0012, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Consulta Itens de Classificação"
		_oDlg:lEscClose := .f.

		oPnlT := TPanel():New( 1, 1, , _oDlg, , , , , , 0, 0, .f., .t. )
		oPnlT:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlB := TPanel():New( 0, 0, , oPnlT, , , , , RGB(67,70,87), 15, 15, .f., .f. )
		oPnlB:Align := CONTROL_ALIGN_LEFT

		_oBrowse := TCBrowse():New( 1, 1, 260, 156, , , , oPnlT, , , , {|| nOpcao := _oBrowse:nAt }, {|| nOpcao := _oBrowse:nAt, nOpcX := 1, _oDlg:End() }, , , , , , , .f., ,.t., ,.f., , , )
		_oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		_oBrowse:AddColumn( TCColumn():New( _aColunas[1], { || aItens[_oBrowse:nAt,1] }, , , , "LEFT" , , .f., .t., , , ,.f., ) )
		_oBrowse:AddColumn( TCColumn():New( _aColunas[2], { || aItens[_oBrowse:nAt,2] }, , , , "RIGHT" , , .f., .t., , , ,.f., ) )
		_oBrowse:AddColumn( TCColumn():New( _aColunas[3], { || aItens[_oBrowse:nAt,3] }, , , , "RIGHT" , , .f., .t., , , ,.f., ) )
		_oBrowse:AddColumn( TCColumn():New( _aColunas[4], { || aItens[_oBrowse:nAt,4] }, , , , "LEFT", , .f., .t., , , ,.f., ) )
		_oBrowse:AddColumn( TCColumn():New( _aColunas[5], { || aItens[_oBrowse:nAt,5] }, , , , "RIGHT" , , .f., .t., , , ,.f., ) )
		_oBrowse:AddColumn( TCColumn():New( _aColunas[6], { || aItens[_oBrowse:nAt,6] }, , , , "LEFT" , , .f., .t., , , ,.f., ) )
		_oBrowse:AddColumn( TCColumn():New( _aColunas[7], { || aItens[_oBrowse:nAt,7] }, , , , "LEFT" , , .f., .t., , , ,.f., ) )

		_oBrowse:SetArray( aItens )

		_oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( _oDlg, {|| nOpcX := 1, _oDlg:End() },{|| nOpcX := 0, _oDlg:End() },, @aButtons ) } )

		If nOpcX > 0 .And. Len( aItens ) > 0
			AGRX500UPN(_cNJKTEMP, cItem, aItens[ nOpcao, 3 ], aItens[ nOpcao, 4 ])
		EndIf
	End
	(_cNJKTEMP)->(dbGoTop())
	_oBrwClass:Refresh()
//	RestArea( aAreaAtu )
Return( .t. )


/*/{Protheus.doc} AGRX500Recalcula
//Ao alterar pesos da NJJ ou informar qual é a tabela de classificacao (NJJ_TABELA)
//este metodo atualiza os pesos e preenche as tabelas NJK - Classificacao e 
//NJM - Comercializacao

@author carlos.augusto
@since 06/02/2018
@version undefined
@param lTabela informa se foi informada a tabela. Quando esta sendo informada a tabela este metodo vai gatilhar as tabelas NJK e NJM.
Caso contrario, vai atualizar todas as informacoes, porque um valor de classificacao foi digitado na tabela NJK!
@type function
/*/
Function AGRX500Recalcula(lTabela)
	Local nX
	Local oNJM		 	:= Nil
	Local oNJK        	:= Nil
	Local oNJJ        	:= Nil
	Local nLinha	 	:= 0
	Local nPerDiv    	:= 0//Soma das porcentagens
	Local nQtdFco	 	:= 0//Soma dos pesos do grid NJM
	Local lRetorno		:= .T.
	Local cClassCtr 	:= cDefClasDesc(NJJ->( NJJ_TIPO)) //Obtem o mandante da classificação para calculo dos descontos - DAGROGAP-514
	Local aDesconAux 	:= {}
	Local aProcess		:= {}
	
	//Para NJJ
	Local nPsEmba		:= 0
	Local nPsSubt		:= 0
	Local nPsDesc		:= 0
	Local nPsBase		:= 0
	Local nPsExtr		:= 0
	Local nPsLiqu		:= 0
	
	Local cDescNNK	
	Local oModel 		:= FwModelActive()
	Local lAlgodao 		:= If(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	
	Default lTabela		:= .T.
	
	If !Empty(oModel)
		oNJJ := oModel:GetModel( "AGRA500_NJJ" )
		
		cTrans		:= IF( oNJJ:GetValue( "NJJ_TIPO" ) $ "1|2|3|4|5", "1" /*Entrega*/, "2"/*Devolução*/)	//--Referente ao campo Transação NJM_TRANS
		nPsEmba		:= oNJJ:GetValue( "NJJ_PESEMB" )	//Peso da Embalagem
		nPsDesc		:= oNJJ:GetValue( "NJJ_PSDESC" )	//Peso Descontado
		nPsBase		:= oNJJ:GetValue( "NJJ_PSBASE" )	//Peso Base para Descontos Extras
		nPsExtr		:= oNJJ:GetValue( "NJJ_PSEXTR" )	//Peso Descontos Extras
		nPsLiqu		:= oNJJ:GetValue( "NJJ_PSLIQU" )	//Peso Liquido
		
		//COMERCIALIZACAO
		oNJM   :=	 oModel:GetModel( "AGRA500_NJM" )
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			If .Not. oNJM:IsDeleted()
				cCondPgt	:= SuperGetMV( "MV_CONDPAD", .F., "001" )
				cClassVlr	:= Posicione("NJR",1,FWxFilial("NJR")+oNJJ:GetValue( "NJJ_CODCTR" ),"NJR_CLVL")
				nVlrBase	:= Posicione("NJR",1,FWxFilial("NJR")+oNJJ:GetValue( "NJJ_CODCTR" ),"NJR_VLRBAS")
				
				//--Caso a quantidade de linhas seja maior que 1
				//--Realiza a divisão da qtde fisica e o percentual de divisão
				//--Sempre porpocional a qntde de linhas
				If oNJM:Length() > 1
					nQtdAux  :=  ( oNJJ:GetValue( "NJJ_PESO3" ) / oNJM:Length() )
					oNJM:LoadValue( "NJM_QTDFCO", Round( nQtdAux, __nDecPeso ) )
					oNJM:LoadValue( "NJM_PERDIV",  (100 / oNJM:Length())       )
					nVlrBase := nVlrBase / oNJM:Length()
				Else
					//Quantidade fisica = Qtd. Fisica * Perc. Div.
					nQtdAux :=  ( oNJJ:GetValue( "NJJ_PESO3" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) )
					oNJM:LoadValue( "NJM_PERDIV",  100)
					oNJM:LoadValue( "NJM_QTDFCO", Round( nQtdAux, __nDecPeso ) )
				EndIf
				nQtdFco += nQtdAux
				nPerDiv += oNJM:GetValue( "NJM_PERDIV" )
				
				oNJM:LoadValue( "NJM_ITEROM",  StrZero( nX, TamSX3( "NJM_ITEROM" )[1], 0 ) )
				oNJM:LoadValue( "NJM_FILIAL",  FwxFilial("NJM") )
				oNJM:LoadValue( "NJM_TIPO",	   oNJJ:GetValue( "NJJ_TIPO" ) )
				oNJM:LoadValue( "NJM_CODENT",  oNJJ:GetValue( "NJJ_CODENT" ) )
				oNJM:LoadValue( "NJM_LOJENT",  oNJJ:GetValue( "NJJ_LOJENT" ))
				
				oNJM:LoadValue( "NJM_TRANS",   cTrans ) //--1=Entrega;2=Devolucao
				
				oNJM:LoadValue( "NJM_CODSAF",  oNJJ:GetValue( "NJJ_CODSAF" ))
				oNJM:LoadValue( "NJM_CODPRO",  oNJJ:GetValue( "NJJ_CODPRO" ))
				
				oNJM:LoadValue( "NJM_CONDPG",  cCondPgt )		//Condição de Pagamento
				oNJM:LoadValue( "NJM_CLVL",	   cClassVlr )		//Classe de Valor
				oNJM:LoadValue( "NJM_QTDFIS",  oNJM:GetValue( "NJM_QTDFCO" ))
				oNJM:LoadValue( "NJM_VLRUNI",  Round( nVlrBase, TamSX3( "NJM_VLRUNI" )[2] ) )
				oNJM:LoadValue( "NJM_VLRTOT",  oNJM:GetValue( "NJM_QTDFIS" ) * oNJM:GetValue( "NJM_VLRUNI" ) )

				oNJM:LoadValue( "NJM_TPFORM",  oNJJ:GetValue( "NJJ_TPFORM" ))
				oNJM:LoadValue( "NJM_DOCSER",  oNJJ:GetValue( "NJJ_DOCSER" ))
				oNJM:LoadValue( "NJM_DOCNUM",  oNJJ:GetValue( "NJJ_DOCNUM" ))
				oNJM:LoadValue( "NJM_DOCEMI",  oNJJ:GetValue( "NJJ_DOCEMI" ))
				oNJM:LoadValue( "NJM_DOCESP",  oNJJ:GetValue( "NJJ_DOCESP" ))
				oNJM:LoadValue( "NJM_CHVNFE",  oNJJ:GetValue( "NJJ_CHVNFE" ))
				
			EndIf
		Next nX
		
		If .Not. lAlgodao
			//Classificacao
			oNJK := oModel:GetModel( "AGRA500_NJK" )
			nLinha := oNJK:GetLine()
			For nX := 1 to oNJK:Length()
				oNJK:GoLine( nX )
				If .Not. oNJK:IsDeleted() .And. oNJK:GetValue("NJK_TPCLAS") = cClassCtr
					aAdd( aDesconAux, { oNJK:GetValue( "NJK_CODDES" ), oNJK:GetValue( "NJK_PERDES" ) } )
				EndIf
			Next nX
			oNJK:GoLine( nLinha )
		
			nPsSubt	:= oNJJ:GetValue( "NJJ_PSSUBT" )
		
			//aProcess := OGX004DESC( oNJJ:GetValue( "NJJ_TABELA" ), nPsSubt, aDesconAux)
			aProcess := OGX004DESC( oNJJ:GetValue( "NJJ_TABELA" ), oNJJ:GetValue( "NJJ_PSSUBT" ), aDesconAux)
			
			//@return:	aRetorno[ x, 1 ] - Codigo do Desconto
			//@return:	aRetorno[ x, 2 ] - Peso base para o Calculo
			//@return:	aRetorno[ x, 3 ] - Percentual de Avaliação
			//@return:	aRetorno[ x, 4 ] - Percentual de Desconto
			//@return:	aRetorno[ x, 5 ] - Quantidade a ser Descontada/Retida
			//@return:	aRetorno[ x, 6 ] - Nova Espécie
			//@return:	aRetorno[ x, 7 ] - Tabela alternativa		
			
			If Len( aProcess ) > 0
		
				nPsDesc := 0
				nLinha := oNJK:GetLine()
				For nX := 1 to oNJK:Length()
					oNJK:GoLine( nX )
					If .Not. oNJK:IsDeleted()
						nY := aScan( aProcess, { | x | AllTrim( x[ 1 ] ) = AllTrim( oNJK:GetValue( "NJK_CODDES" ) ) } )
						//Mostra somente os descontos do mandante - DAGROGAP-446
						If oNJK:GetValue("NJK_TPCLAS") = cClassCtr 
							oNJK:LoadValue( "NJK_BASDES", aProcess[ nY, 2 ] )
							oNJK:LoadValue( "NJK_PERDES", aProcess[ nY, 3 ] )
							oNJK:LoadValue( "NJK_READES", aProcess[ nY, 4 ] )
							oNJK:LoadValue( "NJK_QTDDES", aProcess[ nY, 5 ] )
							nPsDesc += aProcess[ nY, 5 ]
						Else
							oNJK:LoadValue( "NJK_READES", 0 )
							oNJK:LoadValue( "NJK_QTDDES", 0 )
						EndIf
						
						If !lTabela .And. (nLinha == nX) //Se esta rodando por alteracao de item. Atualizou valor
							oNJK:LoadValue( "NJK_RESINF", "1" )
						EndIf
						
						cDescNNK := AGRDESCRINNK(oNJJ:GetValue("NJJ_TABELA"),oNJK:GetValue("NJK_CODDES"),oNJK:GetValue("NJK_PERDES"))
						oNJK:LoadValue( "NJK_DESRES", cDescNNK )
						
					EndIf
				Next nX
				oNJK:GoLine( nLinha )
			EndIf
		EndIf
		//Romaneio
		oNJJ:LoadValue( "NJJ_PSDESC", nPsDesc ) 
		oNJJ:LoadValue( "NJJ_PSBASE", oNJJ:GetValue( "NJJ_PSSUBT" ) - nPsDesc) 
		oNJJ:LoadValue( "NJJ_PSEXTR", nPsExtr )
		oNJJ:LoadValue( "NJJ_PSLIQU", oNJJ:GetValue( "NJJ_PSSUBT" ) - ( nPsDesc + nPsExtr + nPsEmba) )

		//Sugerir o valor do novo campo NJJ_PESO3 com base no NJJ_PSLIQU - DAGROGAP-446
//		If !lEntrAtual .and. !lExecAgoClas
			oNJJ:LoadValue( "NJJ_PESO3", oNJJ:GetValue( "NJJ_PSLIQU" ))
//		EndIf
	
	EndIf
	
	If lRetorno .And. !lTabela
		If .Not. Empty(oNJJ:GetValue("NJJ_TABELA")) .And. oNJJ:GetValue("NJJ_STSCLA") = '1'
			AGRX500DClassificado()
		EndIf
	EndIf

Return lRetorno


/** {Protheus.doc} AGRX500TAB/OGA250VTAB
Função para validação do código da tabela de descontos e carregar o gride de classificação
Chamada do valid do campo NJJ_TABELA
//Metodo importado porque estava disparando funcoes do modelo NJJUNICO do OGA250
@param: 	Nil
@return:	lRetorno - .T. ou .F.
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		OGA250 - Romaneio
*/
Function AGRX500TAB( )
	Local lRetorno 		:= .t.
	Local aAreaAtu 		:= GetArea()
	Local oModel		:= FwModelActive()
	Local oFldNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local oGrdNJK		:= oModel:GetModel( "AGRA500_NJK" )
	Local cProduto		:= oFldNJJ:GetValue( 'NJJ_CODPRO' )
	Local cTabela		:= oFldNJJ:GetValue( "NJJ_TABELA" )
	Local nX			:= 0
	Local cRomaneio  	:= oFldNJJ:GetValue( "NJJ_CODROM" )
	Local nSequencia 	:= 0
	Local aDescont		:= {}   // Array que Irá conter : { Cod.Classificação,Resultado Classif,Se foi informado ou não }
	Local nOperation	:= oModel:GetOperation()

	////////////////////
	// Popula o array de histórico de classificações do romaneio (aNK4)
	////////////////////
	aVetNK4 := {}

	//Validação para alteração [Parecer Qualidade]
	If nOperation == MODEL_OPERATION_UPDATE 
		If !Empty(oFldNJJ:Getvalue('NJJ_QPAREC'))
			DbSelectArea( 'NKJ' )
			DbSetOrder( 1 )
			If dbSeek( xFilial('NKJ')+oFldNJJ:Getvalue('NJJ_QPAREC'))
				If NKJ->NKJ_LIBQLD == '1'	//1=SIM 
					Help(, , STR0007, , STR0008, 1, 0 )	//"AJUDA"###"Esse romaneio esta aprovado pelo parecer da qualidade. Não pode ser alterada a tabela e/ou classificação." 
					lRetorno := .F.	
				EndIf 
			EndIf 
		EndIf
	EndIf

	dbSelectArea( 'NK4' )
	dbSetOrder( 1 )
	If dbSeek( xFilial('NK4') + cRomaneio )
		While !NK4->(Eof()) .And. NK4->NK4_FILIAL + NK4->NK4_CODROM == xFilial('NK4') + cRomaneio
			nSequencia := NK4->( NK4_SEQCLA )
			NK4->(DbSkip())
		EndDo		
	EndIf

	/**
	Se já existem descontos anteriormente cadastrados para o romaneio
	**/

	oGrdNJK:SetNoInsert( .f. )
	oGrdNJK:SetNoDelete( .f. )

	nSequencia += 1	

	dbSelectArea( 'NNI' ) // Tabelas de descontos
	dbSetOrder( 1 )
	If dbSeek( xFilial( 'NNI' ) + cTabela )
		If !Empty( NNI->( NNI_CODPRO ) )
			If cProduto <> NNI->( NNI_CODPRO )
				Help(, , STR0007, , STR0009, 1, 0 )	//"Produto não compatível com produto da tabela."##"Favor informar um produto válido."##"AJUDA"
				lRetorno := .F.
			EndIf
			If NNI->(NNI_QLDANA) == '1'
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "0" )
			ElseIf NNI->(NNI_QLDANA) $ "2|3|4"
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "3" )
			EndIf
		Else	
			//verifica na tabela de produto pelo grupo se o grupo é existente
			//se grupo não existir apresenta mensagem para informar o grupo
			cGrupo := ''
			dbSelectArea( 'SB1' )
			dbSetOrder( 1 )
			dbSeek( xFilial('SB1') + cProduto)
			cGrupo := SB1->( B1_GRUPO )
			If NNI->( NNI_PRODGR ) <> cGrupo
				Help(, , STR0007, , STR0010 , 1, 0 )	//"Produto não faz parte do grupo informado na tabela."##"Favor informar um produto válido."##"AJUDA"
				lRetorno := .F.
			EndIf 
			If NNI->(NNI_QLDANA) == '1'
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "0" )
			ElseIf NNI->(NNI_QLDANA) $ "2|3|4"
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "3" )
			EndIf
		EndIf 
		IF lRetorno
			// Apos Validar a Tabela, Limpo o Grid Caso já tenha descontos ref. a uma outra tabela //
			//oGrdNJK:ClearData()  comentado 18/01/16, pois ao trocar tabela de descontos, ocorre erro.
			For nX := 1 to oGrdNJK:Length()
				oGrdNJK:GoLine( nX )
				If !oGrdNJK:IsDeleted()
					// ADescont Utilizado na Troca de tabela para aproveitar o resultado, e se o resultado foi informado par aum item do desconto
					aAdd( aDescont, { oGrdNJK:GetValue( "NJK_CODDES" ), oGrdNJK:GetValue( "NJK_PERDES" ), oGrdNJK:GetValue( "NJK_RESINF") } )
					aAdd( aVetNK4, { xFilial('NJK'), cRomaneio, nSequencia, oGrdNJK:GetValue( "NJK_ITEM" ), ;
					oGrdNJK:GetValue( "NJK_CODDES" ), " " , oGrdNJK:GetValue( "NJK_BASDES" ),  ; 
					oGrdNJK:GetValue( "NJK_PERDES" ), oGrdNJK:GetValue( "NJK_READES" ), oGrdNJK:GetValue( "NJK_QTDDES" ),  ;
					oGrdNJK:GetValue( "NJK_DESRES" ), cTabela, ;
					oFldNJJ:GetValue( 'NJJ_CODPRO' )})

					oGrdNJK:LoadValue( "NJK_PERDES", 0 )		
					oGrdNJK:DeleteLine()
				EndIf	
			Next nX

			ItensClass(aDescont)
			
		
		EndIF
	Else
		Help(, , STR0007, , STR0011, 1, 0 ) //"Ajuda"###"Não existe -Tabela de Descontos- cadastrada!!!"
		lRetorno := .f.
	EndIf

	oGrdNJK:SetNoInsert( .t. )
	oGrdNJK:SetNoDelete( .t. )
	oGrdNJK:GoLine( 1 )

	RestArea( aAreaAtu )
Return( lRetorno )


/*/{Protheus.doc} ItensClass
//A funcao esta static no OGA250, metodo importado pois executa em AGRX500TAB/OGA250VTAB
@author rafael.kleestadt
@since 05/04/2017
@version undefined
@param aDescont, array, descricao
@type function
/*/
Static Function ItensClass(aDescont)
	Local oModel    := FwModelActive()
	Local oGrdNJK   := oModel:GetModel( "AGRA500_NJK" )
	Local nCount    := 0
	Local nCount2   := 1
	Local nX

	If SuperGetMV( "MV_AGOCLAS",, .F. )
		nCount2 := 2
	EndIf

	For nX := 1 To nCount2  

		dbSelectArea( 'NNJ' ) // Itens da tabela de classificação 
		dbSetOrder( 2 )
		dbGoTop()
		If dbSeek( xFilial( 'NNJ' ) + NNI->( NNI_CODIGO ) )

			While .Not. Eof() .And. NNJ->( NNJ_FILIAL ) = xFilial('NNJ') .And. NNJ->( NNJ_CODTAB ) = NNI->( NNI_CODIGO )

				nCount++
				cItem := StrZero( nCount, TamSX3( "NJK_ITEM" )[1] )
				if nCount <= oGrdNJK:Length() 
					oGrdNJK:GoLine( nCount )
					oGrdNJK:UnDeleteLine()
				Else
					oGrdNJK:AddLine()
				EndIf

				oGrdNJK:SetValue( "NJK_ITEM" 	, cItem 	)
				oGrdNJK:SetValue( "NJK_CODDES"	, NNJ_CODDES)
				oGrdNJK:LoadValue( "NJK_OBRGT"	, NNJ_OBRGT )
				oGrdNJK:SetValue( "NJK_RESINF"	, '2' )	//gravar como "2=Não Informado" - campo é tratado na função sfPreValLin

				/** Carrega matriz de melhoramento de descontos */
				If NNJ->( NNJ_MATRIZ ) = "1"; aMtzDes[ 1, 1 ] := NNJ->( NNJ_CODDES ); EndIf
				If NNJ->( NNJ_MATRIZ ) = "2"; aMtzDes[ 2, 1 ] := NNJ->( NNJ_CODDES ); EndIf
				If NNJ->( NNJ_MATRIZ ) = "3"; aMtzDes[ 3, 1 ] := NNJ->( NNJ_CODDES );	EndIf

				//				If !Empty(aDescont)
				//					nY := aScan( aDescont, { | x | AllTrim( x[ 1 ] ) = AllTrim( NNJ->( NNJ_CODDES ) ) } )
				//					If nY != 0
				//						If !empty(aDescont[ nY, 2 ])
				//							oGrdNJK:LoadValue( "NJK_PERDES", aDescont[ nY, 2 ] )
				//							oGrdNJK:LoadValue( "NJK_RESINF", aDescont[ nY, 3 ] )
				//						EndIf
				//					EndIf
				//				EndIf

				If nX != 1
					oGrdNJK:LoadValue( "NJK_TPCLAS", "2" )
				Else
					oGrdNJK:LoadValue( "NJK_TPCLAS", "1" )	
				EndIf

				dbSkip()
			EndDo

		EndIf
	Next nX 
Return()


/*/{Protheus.doc} AGRA500Classificado
//Verifica se o Romaneio foi classificado
@author carlos.augusto
@since 05/04/2018
@version undefined
@type function
/*/
Static Function AGRX500DClassificado()
	Local lRet		:= .T.
	Local aLines	:= FWSaveRows()
	Local aArea   	:= GetArea()
	Local oModel	:= FwModelActive()
	Local nX
	Local oNJK		:= oModel:GetModel( "AGRA500_NJK" )
	Local oMldNJJ 	:= oModel:GetModel('AGRA500_NJJ')
	
	For nX := 1 to oNJK:Length()
		oNJK:GoLine( nX )
		If .Not. oNJK:IsDeleted()
			IF oNJK:GetValue( "NJK_RESINF" ) == '2' .AND. oNJK:GetValue( "NJK_PERDES" ) > 0
				oNJK:SetValue( "NJK_RESINF" , '1' )
			EndIF

			//Comparacao com vazio para manter o legado onde o campo NJK_OBRGT pode estar vazio
			If (oNJK:GetValue( "NJK_OBRGT" ) == '1' .Or. oNJK:GetValue( "NJK_OBRGT" ) == " ") .AND. ; 
				oNJK:GetValue( "NJK_RESINF" ) == '2'
				lRet := .F.
				exit
			EndIf    
		EndIf
	Next nX
	
	If lRet
		oMldNJJ:LoadValue("NJJ_STSCLA",  "1")
	EndIf
	
	RestArea(aArea)
	FwRestRows(aLines)
Return lRet


/*/{Protheus.doc} AGRX500CBW
//-- Recalcula as quantidades e descontos quando a pesagem é realizada no Browser
//-- Função CalcDescBrw() do fonte OGA250.
  
@author 	ana.olegini
@since 		06/04/2018
/*/
Function AGRX500CBW()
	Local oModel	:= FwModelActive()
	Local nY		:= 0
	Local cTabela 	:= ""
	Local aDescont	:= {}
	Local aDesconAux:= {}
	Local aProcess	:= {}
	
	Local nPsEmba	:= If( NJJ->( NJJ_PESEMB ) = 0, A500FPSEMB(oModel), NJJ->( NJJ_PESEMB ) )
	Local nPsSubt	:= NJJ->( NJJ_PSSUBT )
	Local nPsDesc	:= 0
	Local nPsExtr	:= 0
	Local nSomaNJM  := 0
	Local nNJMRECNO := 0
	
	Local cClassCtr := cDefClasDesc(NJJ->( NJJ_TIPO)) //Obtem o mandante da classificação para calculo dos descontos - DAGROGAP-514
	Local aAreaAtu  := GetArea()

	DbSelectArea( "NJK" ) 	//--Classificaçõe do romaneio
	NJK->(DbSetOrder( 1 ))  //NJK_FILIAL+NJK_CODROM+NJK_ITEM
	If NJK->(dbSeek( FWxFilial( "NJK" ) + NJJ->( NJJ_CODROM ) ))
		While .NOT. ( NJK->( Eof() ) ) .AND. NJK->( NJK_FILIAL ) + NJK->( NJK_CODROM ) == FWxFilial( "NJK" ) + NJJ->( NJJ_CODROM )

			aAdd( aDescont, { NJK->( NJK_CODDES ), NJK->( NJK_PERDES ) } )

			If cClassCtr = NJK->(NJK_TPCLAS)	//aDesconAux - contem somente os dados do mandante
				aAdd(aDesconAux,{ NJK->( NJK_CODDES ), NJK->( NJK_PERDES ) } )
			EndIf
			NJK->( DbSkip())	
		EndDo 
		
		//--Função do fonte OGX004 - calculo dos descontos da tabela
		aProcess := OGX004DESC( NJJ->( NJJ_TABELA ), nPsSubt, aDesconAux)

		If Len( aProcess ) > 0
			dbSeek( xFilial( "NJK" ) + NJJ->( NJJ_CODROM ) )	//NJK_FILIAL+NJK_CODROM+NJK_ITEM
			While .NOT. ( NJK->( Eof() ) ) .AND. NJK->( NJK_FILIAL ) + NJK->( NJK_CODROM ) == xFilial( "NJK" ) + NJJ->( NJJ_CODROM )

				nY := aScan( aProcess, { | x | AllTrim( x[ 1 ] ) = AllTrim( NJK->( NJK_CODDES ) ) } )
				If nY > 0
					If RecLock( "NJK", .F. )
						If cClassCtr = NJK->(NJK_TPCLAS)// Grava na base somente calculo do mandante - DAGROGAP-446
							NJK->( NJK_BASDES ) := aProcess[ nY, 2 ] 
							NJK->( NJK_PERDES ) := aProcess[ nY, 3 ] 
							NJK->( NJK_READES ) := aProcess[ nY, 4 ]
							NJK->( NJK_QTDDES ) := aProcess[ nY, 5 ] 
							nPsDesc += aProcess[ nY, 5 ]
						Else
							NJK->( NJK_QTDDES ) := 0 
						EndIf
						//--Realiza a busca da descrição do resultado do desconto - Função no fonte AGRUTIL01   
						__nDesOGA250 := AGRDESCRINNK( NJJ->( NJJ_TABELA ), NJK->( NJK_CODDES ), NJK->( NJK_PERDES ) )
						NJK->( NJK_DESRES ) := __nDesOGA250

						If .Not. Empty( aProcess[ nY, 7 ] ) .and. NJJ->( NJJ_TABELA ) <> aProcess[ nY, 7 ]
							cTabela  := aProcess[ nY, 7 ]
						EndIf	
						NJK->( MsUnLock() )
					EndIf
				EndIf
				NJK->( DbSkip() )
			EndDo
		EndIf
	Endif	

	If RecLock( "NJJ", .F. )
		NJJ->( NJJ_PSDESC ) := nPsDesc 
		NJJ->( NJJ_PSBASE ) := nPsSubt - nPsDesc 
		NJJ->( NJJ_PSEXTR ) := nPsExtr 
		NJJ->( NJJ_PSLIQU ) := nPsSubt - ( nPsDesc + nPsExtr + nPsEmba) 
		NJJ->( NJJ_PESO3 )  := NJJ->( NJJ_PSLIQU ) 
		NJJ->( MsUnLock() )
	EndIf

	//Salva a area atual
	aAreaAtu := NJM->(GetArea())

	nSomaNJM := 0
	DbSelectArea( "NJM" )  //--Comercializações do romaneio
	NJM->(DbSetOrder( 1 )) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If NJM->(dbSeek( FWxFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ))
		While .NOT. ( NJM->( Eof() ) ) .AND. NJM->( NJM_FILIAL ) + NJM->( NJM_CODROM ) == FWxFilial( "NJK" ) + NJJ->( NJJ_CODROM )

			If RecLock( "NJM", .F. )
				//Utiliza o valor do novo campo NJJ_PESO3 para realizar os calculos - DAGROGAP-446
				NJM->( NJM_QTDFCO ) := Round( ( NJJ->( NJJ_PESO3 ) * ( NJM->( NJM_PERDIV ) / 100 ) ), __nDecPeso )
				nSomaNJM += NJM->( NJM_QTDFCO )
				NJM->( MsUnLock() )
				nNJMRECNO := NJM->( Recno() )
			EndIf

			NJM->( DbSkip() )					
		EndDo

		//--Se deu alguma diferença no total por conta de arredondamento
		//--Utiliza o novo campo NJJ_PESO3 para os calculos - DAGROGAP-446
		If nSomaNJM <> NJJ->( NJJ_PESO3 )
			NJM->( DbGoTo( nNJMRECNO ) )
			If RecLock( "NJM", .F. )
				NJM->( NJM_QTDFCO ) += ( NJJ->( NJJ_PESO3 ) - nSomaNJM ) // Ajusta a diferença no último item do romaneio
				NJM->( MsUnLock() )
			EndIf
		EndIf
	EndIf
	//Restaura a area salva anteriormente - DAGROGAP-446
	RestArea(aAreaAtu)
Return()


/*/{Protheus.doc} AlteraStatus
//Altera o romaneio para o status de classificado
@author carlos.augusto
@since 13/08/2018
@version undefined

@type function
/*/
Static Function AlteraStatus()
	Local oModel	 := FwModelActive()
	Local oNJKActive := oModel:GetModel( "AGRA500_NJK" )
	Local oNJJ 		 := oModel:GetModel( "AGRA500_NJJ" )
	Local nX		 := 0
	Local lClass	 := .T.

	For nX := 1 to oNJKActive:Length()
		oNJKActive:GoLine( nX )
		If oNJKActive:GetValue( "NJK_OBRGT") = '1' .And. oNJKActive:GetValue( "NJK_RESINF") != '1'
			lClass	:= .F.
			exit
		EndIf
	Next nX
	
	If lClass
		oNJJ:LoadValue("NJJ_STSCLA","1")
	EndIf
	
Return