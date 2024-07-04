#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#include 'OGA710C.ch'

/*/{Protheus.doc} OG710CTSRG
//TODO Tela de seleção dos itens para rolagem do grão
@obs Necessario função chamadora criar variavel private _aRolItGrao para armazenar os dados da tela
@author claudineia.reinert
@since 05/07/2018
@version undefined
@param oModel, object, modelo de dados
@type function
/*/
Function OG710CTSRG(oModel)
	Local lRet := .F.
	Private _nQtIEOrig := N7Q->N7Q_TOTLIQ //quantidade total instruida na IE de origem

	lRet := CriaBrowser(oModel)

Return lRet

/*/{Protheus.doc} CriaBrowser
//TODO Função cria o browser com os dados para selecionar os itens que serão rolados
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param oModel, object, modelo de dados
@type function
/*/
Static Function CriaBrowser(oModel)
	Local oSize         := Nil
	Local oDlg          := Nil
	Local aColBrw1		:= {}
	Local aColBrw2		:= {}
	Local lMarcAll		:= .F. //iniical .f. pois é para vir tudo marcado

	Private _nQtdTotRol	:= 0
	Private _nQtdCnt 	:= 0
	Private _oBrowse1    := Nil
	Private _aAux1       := {}
	Private _oBrowse2    := Nil
	Private _aAux2       := {}
	Private _oGet1		:= Nil
	Private _oGet2		:= Nil
	Private _nValAntBr1 := 0

	If Len(_aRolItGrao) = 0 //variavel private criada no OGA710
		_aRolItGrao := ItensRolGrao(oModel) //carrega os itens de grão para seleção e rolagem
	EndIf

	_aAux1 		:= _aRolItGrao[1] //N7S sem estufagem para rolagem
	_aAux2 		:= _aRolItGrao[2] //containers para rolagem
	_nQtdTotRol := _aRolItGrao[3] //qtd total para rolagem
	_nQtdCnt 	:= GetQtdCnt(_aAux2) //qtd container para rolagem

	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 100, 15, .t., .t., .t. )
	oSize:AddObject( "P2", 100, 35, .t., .t., .t. )
	oSize:AddObject( "P3", 100, 55, .t., .t., .t. )
	oSize:lProp     := .t.
	oSize:aMargins  := { 5, 5, 5, 5 }
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0001 ,,,,,CLR_BLACK,CLR_WHITE,,,.t.)

	oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ),oSize:GetDimension( "P1", "YSIZE" ) )
	oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ),oSize:GetDimension( "P2", "YSIZE" ))
	oPnTres := tPanel():New( oSize:GetDimension( "P3", "LININI" ), oSize:GetDimension( "P3", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P3", "XSIZE" ),oSize:GetDimension( "P3", "YSIZE" ) )

	TSay():New( 005, 200, {|| OemToAnsi( STR0002 ) }		, oPnUm, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 030 )
	_oGet1 := TGet():New( 015, 200,bSetGet(_nQtdTotRol), oPnUm,096,010,PesqPict( "N7Q", "N7Q_TOTLIQ" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"nQtdTotRol")
	TSay():New( 005, 350, {|| OemToAnsi( STR0003 ) }		, oPnUm, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 030 )
	_oGet2 := TGet():New( 015, 350,bSetGet(_nQtdCnt), oPnUm,096,010,PesqPict( "N7Q", "N7Q_QTDCOR" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"nQtdCnt")

	_oBrowse1 := FWBrowse():New()
	//Colunas _oBrowse1
	aAdd(aColBrw1, {STR0004		,{||IIF(Len(_aAux1) > 0 , _aAux1[_oBrowse1:NAT,01], Nil)} , 'C'   ,'@!' 							, 1    ,30     					,0  })
	aAdd(aColBrw1, {STR0005		,{||IIF(Len(_aAux1) > 0 , _aAux1[_oBrowse1:NAT,02], Nil)} , 'C'   ,'@!' 							, 1    ,09						,0  })
	aAdd(aColBrw1, {STR0006		,{||IIF(Len(_aAux1) > 0 , _aAux1[_oBrowse1:NAT,03], NIL)} , 'C'   ,'@!'							, 1    ,03     					,0  })
	aAdd(aColBrw1, {STR0007 	,{||IIF(Len(_aAux1) > 0 , _aAux1[_oBrowse1:NAT,04], NIL)} , 'C'   ,'@!' 							, 1    ,03     					,0  })
	aAdd(aColBrw1, {STR0008 		,{||IIF(Len(_aAux1) > 0 , _aAux1[_oBrowse1:NAT,05], NIL)} , 'N'   ,PesqPict( "N7S", "N7S_QTDVIN" ) , 2    ,TamSx3("N7S_QTDVIN")[1]	,TamSx3("N7S_QTDVIN")[2] })
	aAdd(aColBrw1, {STR0009 	,{||IIF(Len(_aAux1) > 0 , _aAux1[_oBrowse1:NAT,06], NIL)} , 'N'   ,PesqPict( "N7S", "N7S_QTDVIN" )	, 2    ,TamSx3("N7S_QTDVIN")[1]	,TamSx3("N7S_QTDVIN")[2] })

	_oBrowse1:setcolumns( aColBrw1 )
	_oBrowse1:acolumns[6]:ledit		:= .t. 
	_oBrowse1:acolumns[6]:cReadVar	:= '_aAux1[_oBrowse1:NAT,06]'
	_oBrowse1:setDataArray()  	
	_oBrowse1:setArray(_aAux1)
	_oBrowse1:DisableReport()
	_oBrowse1:DisableConfig()
	_oBrowse1:DisableLocate()
	_oBrowse1:SetOwner(oPnDois)
	_oBrowse1:lheaderclick := .f.
	_oBrowse1:SetLineHeight(15) 
	_oBrowse1:SetEditCell( .T., { || VPosEdtBr1(_oBrowse1:NAT) } ) // Permite edição na grid
	_oBrowse1:SetPreEditCell( { || VPreEdtBr1(_oBrowse1:NAT) } ) //pre validação da edição
	_oBrowse1:Activate()		


	//_oBrowse2 := FWMarkBrowse():New()
	_oBrowse2 := FWBrowse():New()
	//Colunas _oBrowse2
	aAdd(aColBrw2, {STR0010		,{||IIF(Len(_aAux2) > 0 , _aAux2[_oBrowse2:NAT,02], Nil)} , 'C'   ,'@!' 					, 1    ,30     	,0  })
	aAdd(aColBrw2, {STR0011		,{||IIF(Len(_aAux2) > 0 , _aAux2[_oBrowse2:NAT,03], Nil)} , 'N'   ,'@E 999,999.999'		, 2    ,11		,3  })
	aAdd(aColBrw2, {STR0012		,{||IIF(Len(_aAux2) > 0 , X3CboxDesc( "N91_STATUS", _aAux2[_oBrowse2:NAT,04]), NIL)} , 'C'   ,'@!'					, 1    ,03     	,0  })

	_oBrowse2:setDataArray()  	
	_oBrowse2:setArray(_aAux2)
	_oBrowse2:AddMarkColumns({|| Iif(_aAux2[_oBrowse2:NAT,01] == "2", "LBOK", "LBNO") },{ || MarcaUm(_oBrowse2:NAT)},{|| MarcaTudo(@lMarcAll)})
	_oBrowse2:bLDblClick := {|| MarcaUm(_oBrowse2:NAT) } //ao dar duplo clique na linha
	_oBrowse2:setcolumns( aColBrw2 )
	_oBrowse2:DisableReport()
	_oBrowse2:DisableConfig()
	_oBrowse2:DisableLocate()
	_oBrowse2:SetOwner(oPnTres)
	_oBrowse2:SetLineHeight(15) 
	_oBrowse2:Activate()	

	oDlg:Activate( , , , .t., {||.T.}, , { || EnchoiceBar( oDlg, {|| ExecGrav(oModel,@oDlg) },{|| ExecSair(@oDlg) },, ) } )

Return .T.

/*/{Protheus.doc} ExecGrav
//TODO Função grava os itens no array _aRolItGrao e atualiza dados no modelo N7Q e N7S
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param oModel, object, modelo de dados
@param oDlg, object, objeto da janela
@type function
/*/
Static Function ExecGrav(oModel,oDlg)
	Local oN7Q	:= oModel:GetModel( "N7QUNICO" )
	Local oN7S	:= oModel:GetModel( "N7SUNICO" )
	Local nX 	:= 0
	Local nLinN7S	:= oN7S:GetLine()
	Local oView     := FwViewActive()
	Local nQtdCert := 0

	If _nQtdTotRol <= 0 .OR. _nQtdTotRol >= _nQtIEOrig
		Help( ,,STR0013,, STR0014 + cValToChar(_nQtIEOrig) , 1, 0 )
		Return .F. 
	EndIf

	QtdRemN7SRol(@_aAux1, _aAux2, oModel) //ajusta _aAux1 com a qtd remetida, qtd vinculada e notas de remessa por regra fiscal

	_aRolItGrao := {_aAux1,_aAux2,_nQtdTotRol} //armazena os itens da tela na variavel para ao salvar a rolagem tratar a rolagem dos container e remessas

	//seta valor na N7S
	For nX := 1 to oN7S:Length() 
		oN7S:GoLine(nX)
		nPos := aScan( _aAux1, { |x| AllTrim( x[1]+x[2]+x[3]+x[4] ) == oN7S:GetValue('N7S_FILORG')+oN7S:GetValue('N7S_CODCTR')+oN7S:GetValue('N7S_ITEM')+oN7S:GetValue('N7S_SEQPRI') } )
		If nPos > 0 
			oN7S:LoadValue('N7S_QTDVIN',_aAux1[nPos][8]) //Seta Qtd instruida na N7S
			oN7S:LoadValue('N7S_QTDREM',_aAux1[nPos][7]) //Seta Qtd remetida na N7S
			OGA710VALQ(_aAux1[nPos][8],1) //para validar a qtd instruida, ja que esta sendo usao o loadValue, pois o setValue não aceita
		EndIf		
	Next nX
	oN7S:GoLine(nLinN7S)

	For nX := 1 to Len(_aAux2) //lê os container  
		If _aAux2[nX][1] == "2" .AND. _aAux2[nX][4] $ "4|5|6" //se container marcado para rolagem e status de certificação
			nQtdCert += _aAux2[nX][3]
		EndIf		
	Next nX
	nPcrMce := IIF(nQtdCert > 0 , round(((( nQtdCert / _nQtdTotRol ) - 1) * 100),2), 0)

	oN7Q:LoadValue('N7Q_QTDREM', _nQtdTotRol) //seta qtd remetida na N7Q
	oN7Q:LoadValue('N7Q_QTDCOR', _nQtdCnt) //seta qtd container reservados na N7Q
	oN7Q:LoadValue('N7Q_QTDCON', _nQtdCnt) //seta qtd container solicitado na N7Q
	oN7Q:LoadValue('N7Q_QTDCER', nQtdCert) //seta qtd certificada na N7Q
	oN7Q:LoadValue('N7Q_PCRMCE', nPcrMce) //seta % qtd Remetida X qtd certificada na N7Q

	If valType(oView) == 'O'
		oView:Refresh("VIEW_N7S")
		oView:Refresh("VIEW_N7Q02")
	EndIf

	oDlg:End() //fecha tela

Return .T.

Static Function ExecSair(oDlg)
	oDlg:End() //fecha tela
Return .F.

/*/{Protheus.doc} MarcaUm
//TODO Função para marcar/desmarcar um item do browser, 
e atualizar a quantidade de container e a quantidade total da rolagem
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param nLinha, numeric, numero da linha que foi executado a ação de marcar/desmacar
@type function
/*/
Static Function MarcaUm( nLinha)

	If _aAux2[nLinha,1] == "1"
		_aAux2[nLinha,1] := "2" //marca
		_nQtdTotRol += _aAux2[nLinha,3]
		_nQtdCnt += 1
	ElseIF _aAux2[nLinha,1] == "2"
		_aAux2[nLinha,1] := "1" //desmarca
		_nQtdTotRol -= _aAux2[nLinha,3]
		_nQtdCnt -= 1
	EndIf

	_oGet1:CtrlRefresh() //refresh campo qtd total rolagem
	_oGet2:CtrlRefresh() //refresh campo qtd container rolagem

Return(.T.)


/*/{Protheus.doc} MarcaTudo
//TODO Função para marcar/desmarcar todos os itens do browser,
e atualizar a quantidade de container e a quantidade total da rolagem
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param lMark, logical, variavel logica para indicar se deve marcar(.T.)/desmarcar(.F.) os registros
@type function
/*/
Static Function MarcaTudo( lMark )
	Local nX	:= 0

	For nX := 1 to Len( _aAux2 )                 
		If lMark
			If _aAux2[ nX, 1 ] == "1" //esta desmarcado
				_nQtdTotRol += _aAux2[ nX, 3 ]
				_nQtdCnt += 1
			EndIf
			_aAux2[ nX, 1 ] := "2" //coloca como marcado
		Else
			If _aAux2[ nX, 1 ] == "2" //esta marcado
				_nQtdTotRol -= _aAux2[ nX, 3 ]
				_nQtdCnt -= 1
			EndIf
			_aAux2[ nX, 1 ] := "1" //coloca como desmarcado
		EndIf
	Next nX

	lMark := !lMark
	_oBrowse2:Refresh(.T.) //atualiza browser de containers
	_oGet1:CtrlRefresh() //refresh campo qtd total rolagem
	_oGet2:CtrlRefresh() //refresh campo qtd container rolagem

Return(.T.)

/*/{Protheus.doc} ItensRolGrao
//TODO Função para carregamento inicial dos itens de grão para a tela de seleção dos itens de grãos para rolagem
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param oModel, object, modelo de dados
@type function
/*/
Static Function ItensRolGrao(oModel)
	Local aAreaN9I	:= N9I->(GetArea())
	Local aCnt		:= {}
	Local aN7S		:= {}
	Local oN7S		:= oModel:GetModel( "N7SUNICO" )
	Local nX		:= 0
	Local nLinha	:= 0
	Local cSeek		:= ''
	Local aItens := {}
	Local cQuery := ""
	Local cAliasQry:= GetNextAlias()
	Local nQtdLivre := 0
	Local nQtdTotRol := 0
	Local cIEOrig := N7Q->N7Q_CODINE //IE POSICIONADA NA TELA

	//busca a quantidade da N7S total das N7S para rolagem
	nLinha := oN7S:GetLine()
	DbSelectArea("N9I")
	N9I->(DbSetOrder(6)) //N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
	For nX := 1 To oN7S:Length() 
		oN7S:GoLine(nX)		
		nQtdLivre := oN7S:GetValue("N7S_QTDVIN")
		cSeek := '2'+oN7S:GetValue('N7S_FILIAL')+cIEOrig+oN7S:GetValue('N7S_CODCTR')+oN7S:GetValue('N7S_ITEM')+oN7S:GetValue('N7S_SEQPRI')
		If N9I->(DbSeek(cSeek))
			While N9I->(!Eof()) .AND. N9I->(N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI) == cSeek 
				If N9I->N9I_INDSLD == "2" //vinculado a container
					nQtdLivre -=  N9I->N9I_QTDFIS
				EndIf
				N9I->(DbSkip())
			EndDo
		EndIf
		nQtdTotRol += oN7S:GetValue("N7S_QTDVIN")
		//aN7S --> FILIAL ORIG, CONTRATO, ENTREGA, REGRA FISCAL, QTD SEM ESTUFAGEM, QTD PARA ROLAR, QTD REMETIDA, ARRAY NOTAS DE REMESSA PARA ROLAR
		AADD(aN7S,{oN7S:GetValue("N7S_FILORG"),oN7S:GetValue("N7S_CODCTR"),oN7S:GetValue("N7S_ITEM"),oN7S:GetValue("N7S_SEQPRI"), nQtdLivre, nQtdLivre,oN7S:GetValue("N7S_QTDREM"),oN7S:GetValue("N7S_QTDVIN"),{} })

	Next nX	
	oN7S:GoLine(nLinha)

	//busca os container para rolagem
	cQuery := " SELECT N91_CONTNR AS CTN, N91_QTDCER AS QTD, N91.N91_STATUS AS STATUS, N91_QTDCER AS QTDANT "
	cQuery += " FROM "  + RetSqlName("N91") + " N91 "
	cQuery += " WHERE N91.N91_FILIAL = '"+FWxFilial("N91")+"'  "
	cQuery += " AND N91_CODINE = '"+cIEOrig+"'  "
	cQuery += " AND N91.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

	While (cAliasQry)->(!EoF())
		//cStatus := X3CboxDesc( "N91_STATUS", (cAliasQry)->STATUS )
		AADD(aCnt, {"2",(cAliasQry)->(CTN), (cAliasQry)->(QTD), (cAliasQry)->STATUS}) //padrão 2-marcado tudo
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	//Define a qtd remetida da regra fiscal e as notas de remessa para a regra fiscal adicionando na aN7S
	QtdRemN7SRol(@aN7S, aCnt, oModel)

	aItens := {aN7S,aCnt, nQtdTotRol}

	RestArea(aAreaN9I)

Return aItens

/*/{Protheus.doc} VPosEdtBr1
//TODO Pós-Validação da Edição do campo
@author claudineia.reinert
@since 06/07/2018
@version undefined
@param nLinha, numeric, descricao
@type function
/*/
Static Function VPosEdtBr1(nLinha)
	Local lRet := .T.

	//valida se o valor informado é validado
	If nLinha != Nil 
		If (_aAux1[ nLinha, 6 ] < 0 .OR. _aAux1[ nLinha, 6 ] > _aAux1[ nLinha, 5 ])
			lRet := .F.
			MsgStop(STR0015 + cValToChar(_aAux1[ nLinha, 5 ]) ,STR0016)
		Else
			_nQtdTotRol := ( _nQtdTotRol - _nValAntBr1 ) + _aAux1[ nLinha, 6 ] 
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VPreEdtBr1
//TODO Pre-Validação da Edição do campo 
@author claudineia.reinert
@since 06/07/2018
@version undefined
@param nLinha, numeric, descricao
@type function
/*/
Static Function VPreEdtBr1(nLinha)
	Local lRet := .T.

	_nValAntBr1 := _aAux1[ nLinha, 6 ] //armazena na variação o valor antes da alteração

Return lRet

/*/{Protheus.doc} QtdRemN7SRol
//TODO Atauliza posições no array aN7S com a qtd remetida por N7S,
a quantidade vinculada/instruida por N7S e o array com as Remessa que serão roladas por N7S
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param aN7S, array, descricao
@param aCnt, array, descricao
@param oModel, object, descricao
@return aN7S, array, retorna o array aN7S atualizado
@type function
/*/
Static Function QtdRemN7SRol(aN7S, aCnt, oModel)
	Local cQuery   := ""	
	Local cAliasQry := ""
	Local nRemTotN7S := 0 //armazena a qtd total remetida da N7S(em container _ sem estufagem)
	Local nRemN7S := 0 //armazena a qtd remetida na N9I com indice 1-vinculada a IE
	Local nVincN7S := 0 //armazena a qtd vinculada para a N7S
	Local nPos	:= 0
	Local aItemRem := {}  //armazena as remessas para rolagem(R_E_C_N_O , QTD, Container)
	Local nX := 0

	For nX := 1 To Len(aN7S)
		nVincN7S := aN7S[nX][6]
		cAliasQry := GetNextAlias()
		//lê na N9I as remessa ordenando pelas mais recentes para poder rolar as mais recentes
		cQuery := " SELECT N9I.R_E_C_N_O_,N9I_FILIAL,N9I_DOC,N9I_SERIE,N9I_CLIFOR,N9I_LOJA,N9I_ITEDOC,N9I_ITEFLO, N9I_INDSLD, N9I_QTDFIS, N9I_CONTNR "
		cQuery += " FROM "  + RetSqlName("N9I") + " N9I "
		cQuery += " INNER JOIN "+  RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_ = ' ' AND SF2.F2_DOC = N9I_DOC AND SF2.F2_SERIE = N9I.N9I_SERIE " 
		cQuery += " WHERE N9I.D_E_L_E_T_ = ' ' AND N9I_FILIAL = '"+ aN7S[nX][1] +"' AND N9I_CODCTR = '"+ aN7S[nX][2] +"' " 
		cQuery += " AND N9I.N9I_ITEM = '"+ aN7S[nX][3] +"' AND N9I_SEQPRI = '"+ aN7S[nX][4] +"' " 
		cQuery += " ORDER BY N9I_INDSLD,SF2.F2_EMISSAO,N9I_FILIAL, N9I_DOC,N9I_SERIE, N9I_ITEDOC, N9I_ITEFLO " //ordena pela nota mais atual para rolagem
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		nRemTotN7S := 0
		DbSelectArea(cAliasQry)
		While (cAliasQry)->(!EoF()) 
			If (cAliasQry)->N9I_INDSLD == "1" .AND. aN7S[nX][6] > 0 //1=Vinculado IE //aN7S[nX][6] --> qtd sem estufagem selecionada para rolagem
				If nRemTotN7S < aN7S[nX][6] 
					//a qtd sem estufagem pode ser maior que a remetida, pois pode instruir mais que a remetida, assim como pode ser menor conforme informado para rolagem
					If (nRemTotN7S + (cAliasQry)->N9I_QTDFIS) <= aN7S[nX][6]  
						nRemN7S := (cAliasQry)->N9I_QTDFIS
					Else
						nRemN7S := aN7S[nX][6] - nRemTotN7S 
					EndIf
					nRemTotN7S += nRemN7S
					AADD(aItemRem, {(cAliasQry)->R_E_C_N_O_ , nRemN7S , (cAliasQry)->N9I_CONTNR })
				EndIf
			ElseIf (cAliasQry)->N9I_INDSLD == "2" //2=Vinculado Contêiner
				nPos := aScan( aCnt, { |x|  Alltrim(x[2]) == Alltrim((cAliasQry)->N9I_CONTNR ) } )
				If nPos > 0 .AND. aCnt[nPos][1] == "2" //SE para regra fiscal tem remessa com o container e o container esta marcado para rolagem
					nVincN7S += (cAliasQry)->N9I_QTDFIS
					nRemTotN7S += (cAliasQry)->N9I_QTDFIS
					AADD(aItemRem, { (cAliasQry)->R_E_C_N_O_ ,(cAliasQry)->N9I_QTDFIS ,(cAliasQry)->N9I_CONTNR }) 
				EndIf
			EndIf
			//N9I_INDSLD=3 NÃO SERÁ ROLADO
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		aN7S[nX][7] := nRemTotN7S //qtd remetida da N7S
		aN7S[nX][8] := nVincN7S //Quantidade vinculada na N7S
		aN7S[nX][9] := aItemRem //remessas da regra fiscal para rolagem
	Next nX

Return aN7S

/*/{Protheus.doc} GetQtdCnt
//TODO verifica a quantidade de containers marcado/selecionados para rolagem
@author claudineia.reinert
@since 09/07/2018
@version undefined
@param aCnt, array, descricao
@type function
/*/
Static Function GetQtdCnt(aCnt)
	Local nQtd 	:= 0 
	Local nX 	:= 0

	For nX := 1 to Len(aCnt)
		If aCnt[nX][1] == "2" //marcado
			nQtd += 1
		EndIf
	Next nX

Return nQtd
