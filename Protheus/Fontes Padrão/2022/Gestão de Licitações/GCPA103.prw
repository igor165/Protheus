#Include 'PROTHEUS.ch'
#Include 'FWMVCDEF.ch'
#Include 'GCPA103.ch'

/*
	Descrição: Esta rotina permite alterar uma Análise de Mercado feita
	inicialmente com o método de avaliação por LOTE para ITEM.
*/

//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := ModelDef()
Local oStrCOQ := FWFormStruct(2, 'COQ', {|cCampo| !AllTrim(cCampo) $ "COQ_CODIGO, COQ_METODO, COQ_REVISA"})
Local oStrCON := FWFormStruct(2, 'CON', {|cCampo| !AllTrim(cCampo) $ "CON_CODIGO, CON_REVISA, CON_METODO, CON_VALEST"})
Local oStrCOY := FWFormStruct(2, 'COY')
Local oStrCOP := FWFormStruct(2, 'COP')
 
oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddGrid('oViewCON' , oStrCON,'CONDETAIL')

oView:EnableTitleView('oViewCON')

oStrCON:SetProperty('CON_QUANT', MVC_VIEW_CANCHANGE, .F.)
oStrCON:SetProperty('CON_CODPRO', MVC_VIEW_CANCHANGE, .F.)

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author antenor.silva
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 
Local oStrCOM	:= FWFormStruct(1,'COM')
Local oStrCOQ	:= FWFormStruct(1,'COQ')
Local oStrCON	:= FWFormStruct(1,'CON')
Local oStrCOP := FWFormStruct(1,'COP')
Local oStrCOY := FWFormStruct(1,'COY')
Local oStruCOO := FWFormStruct(1,'COO') 

oModel := MPFormModel():New('GCPA103', ,{|oModel|A103PVLD(oModel)} ,{|oModel|A103Commit(oModel)})

oModel:SetDescription(STR0001) //Manutenção do Lote'
oModel:addFields('COMMASTER',,oStrCOM)
oModel:addGrid('COQDETAIL','COMMASTER',oStrCOQ)
oModel:addGrid('CONDETAIL','COMMASTER',oStrCON)
oModel:addGrid('COPDETAIL','CONDETAIL',oStrCOP)

oModel:addGrid('COYDETAIL','COMMASTER',oStrCOY)
oModel:AddGrid('COODETAIL', 'CONDETAIL', oStruCOO,{|oModelGrid, nLine,cAction,cField|PreValCOO(oModelGrid, nLine, cAction, cField)}) //-- Solicitações

oModel:SetRelation('CONDETAIL', { { 'CON_FILIAL', 'xFilial("CON")' }, { 'CON_CODIGO', 'COM_CODIGO' } }, CON->(IndexKey(1)) )
oModel:SetRelation('COQDETAIL', { { 'COQ_FILIAL', 'xFilial("COQ")' }, { 'COQ_CODIGO', 'COM_CODIGO' } }, COQ->(IndexKey(1)) )
oModel:SetRelation('COPDETAIL', { { 'COP_FILIAL', 'xFilial("COP")' }, { 'COP_CODIGO', 'COM_CODIGO' } }, COP->(IndexKey(1)) )	
oModel:SetRelation('COYDETAIL', { {'COY_FILIAL','xFilial("COY")'   }, {'COY_CODIGO', 'COM_CODIGO'}} ,COY->(IndexKey(1)))
oModel:SetRelation('COODETAIL', { {'COO_FILIAL',	'xFilial("COO")'  }, {'COO_CODIGO', 'COM_CODIGO'},{'COO_CODPRO','CON_CODPRO'} },COO->(IndexKey(1)))

oModel:getModel('COMMASTER'):SetDescription(STR0002)//('Cabeçalho')
oModel:getModel('COQDETAIL'):SetDescription(STR0003)//('Lotes')
oModel:getModel('CONDETAIL'):SetDescription(STR0004)//('Produtos')
oModel:getModel('COPDETAIL'):SetDescription(STR0005)//('Fornecedores')
oModel:getModel('COYDETAIL'):SetDescription(STR0006)//('AnáliseXLoteXPrdXFrn')
oModel:GetModel('COODETAIL'):SetDescription(STR0007)//"Solicitações"

oModel:getModel('CONDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('CONDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('COYDETAIL'):SetOptional(.T.)
oModel:GetModel('COPDETAIL'):SetOptional(.T.)
oModel:GetModel('COQDETAIL'):SetOptional(.T.)
oModel:GetModel('COODETAIL'):SetOptional(.T.)

oModel:GetModel('COPDETAIL'):SetOnlyQuery(.T.)

Return oModel

//------------------------------------------------------------------
/*/{Protheus.doc} A103PVLD(oModel)
Verifica se o fornecedor deu lance a todos os itens que compõem o lote.
@author antenor.silva	
@since 26/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A103PVLD(oModel)
Local oModCON		:= oModel:GetModel('CONDETAIL')
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local lRet			:= .T.

For nX := 1 to oModCON:length()
	oModCON:GoLine(nX)
	If !Empty(oModCON:GetValue('CON_LOTE'))
		Help(' ', 1,'A103DELLTE') //'Todos os números de lotes precisam ser apagados.'
		lRet := .F.
		Exit
	EndIf
Next nX	

FWRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A103Commit(oModel)
Rotina para realizar a persistência do modelo.
@author antenor.silva	
@since 30/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A103Commit()
Local nPos			:= 0
Local nPos2		:= 0
Local nVlrEst		:= 0
Local nVlrEstCOM  := 0
Local nQtdForn		:= 0
Local aProds		:= {}
Local aCOP			:= {}
Local aForns		:= {}
Local aStruct 		:= COP->(DbStruct())

Begin Transaction

//Armazenando os produtos e somando os produtos repetidos
//CON_FILIAL+CON_CODIGO+CON_CODPRO+CON_LOTE
CON->(DbSetOrder(1))
If CON->(DbSeek(xFilial("CON")+COM->COM_CODIGO))
	While CON->(!Eof()) .And. CON->CON_FILIAL == xFilial("CON") .And. CON->CON_CODIGO == COM->COM_CODIGO
		If (nPos := Ascan( aProds, { |x| x[1] == CON->CON_CODPRO })) == 0
			Aadd( aProds, {  CON->CON_CODPRO, CON->CON_QUANT } )
		Else  
			aProds[nPos,2] += CON->CON_QUANT
			RecLock("CON",.F.)
			CON->(DbDelete())
			CON->(MsUnlock())
		EndIf
		CON->(DbSkip())
	EndDo
	//-- Atualiza quantidade por produto
	For nPos := 1 To Len(aProds)
		If CON->(DbSeek(xFilial("CON")+COM->COM_CODIGO+aProds[nPos,1]))
			RecLock("CON",.F.)
			CON->CON_QUANT := aProds[nPos,2]
			CON->(MsUnlock())
		EndIf
	Next nPos
EndIf

//-- COY_FILIAL+COY_CODIGO+COY_LOTE+COY_CODPRO+COY_CODFOR+COY_LOJFOR+COY_TIPO
COY->(DbSetOrder(1))
If COY->(DbSeek(xFilial("COY")+COM->COM_CODIGO))
	While COY->(!Eof()) .And. COY->COY_FILIAL == xFilial("COY") .And. COY->COY_CODIGO == COM->COM_CODIGO
		//-- Armazena fornecedores da analise
		If Ascan( aForns, { |x| x[1]+x[2]+x[3]+x[4] == COY->COY_CODPRO+COY->COY_CODFOR+COY->COY_LOJFOR+COY->COY_TIPO } ) == 0
			Aadd(aForns, { COY->COY_CODPRO, COY->COY_CODFOR, COY->COY_LOJFOR, COY->COY_TIPO } )
		EndIf  
		//-- Armazena dados da COP
		If (nPos := Ascan( aCOP, { |x| x[1]+x[2]+x[3]+x[4] == COY->COY_CODPRO+COY->COY_CODFOR+COY->COY_LOJFOR+COY->COY_TIPO })) == 0
			//Aeval(aStruct, { |e,i| Aadd(aRatSez[Len(aRatSez)], { e[1], SEZ->(FieldGet(i)) } ) } )
			Aadd( aCOP, {  COY->COY_CODPRO, COY->COY_CODFOR, COY->COY_LOJFOR, COY->COY_TIPO, COY->COY_PRCUN,0,.T. } )
		Else  
			aCOP[nPos,5] := Iif(COY->COY_PRCUN>aCOP[nPos,5],COY->COY_PRCUN,aCOP[nPos,5])
		EndIf
		RecLock("COY",.F.)
		COY->(DbDelete())
		COY->(MsUnlock())
		COY->(DbSkip())
	EndDo
EndIf	

// Limpeza do número do lote
//COP_FILIAL+COP_CODIGO+COP_LOTE
COP->(DbSetOrder(2))
If COP->(DbSeek(xFilial("COP")+COM->COM_CODIGO))
	While COP->(!Eof()) .And. COP->COP_FILIAL == xFilial("COP") .And. COP->COP_CODIGO == COM->COM_CODIGO
		RecLock("COP",.F.)
		COP->(DbDelete())
		COP->(MsUnlock())
		COP->(DbSkip())
	EndDo
EndIf

//Atualizando os fornecedores e somando preço e valor total
For nPos := 1 To Len(aCOP)
	If (nPos2 := Ascan(aProds, { |x| x[1] == aCOP[nPos,1] })) > 0
		aCOP[nPos,6] := aProds[nPos2,2]*aCOP[nPos,5] 
	EndIf
	// VER COMO GRAVAR TODOS OS CAMPOS
	RecLock("COP",.T.)
	COP->COP_FILIAL	:= xFilial("COP")
	COP->COP_CODIGO   := COM->COM_CODIGO
	COP->COP_CODPRO	:= aCOP[nPos,1] 
	COP->COP_TIPO		:= aCOP[nPos,4]
	COP->COP_CODFOR	:= aCOP[nPos,2]
	COP->COP_LOJFOR	:= aCOP[nPos,3]
	COP->COP_PRCUN	:= aCOP[nPos,5]
	COP->COP_VALTOT 	:= aCOP[nPos,6]
	COP->COP_OK		:= aCOP[nPos,7]
	COP->(MsUnlock())
Next nPos

// Limpeza do número do lote
//COQ_FILIAL+COQ_CODIGO+COQ_LOTE
COQ->(DbSetOrder(1))
If COQ->(DbSeek(xFilial("COQ")+COM->COM_CODIGO))
	While COQ->(!Eof()) .And. COQ->COQ_FILIAL == xFilial("COP") .And. COQ->COQ_CODIGO == COM->COM_CODIGO
		RecLock("COQ",.F.)
		COQ->(DbDelete())
		COQ->(MsUnlock())
		COQ->(DbSkip())
	EndDo
EndIf

// Limpeza do número do lote da solicitação
COO->(DbSetOrder(1))//COO_FILIAL+COO_CODIGO+COO_CODPRO+COO_NUMSC+COO_ITEMSC
If COO->(DbSeek(xFilial("COO")+COM->COM_CODIGO))
	While COO->(!Eof()) .And. COO->COO_FILIAL == xFilial("COO") .And. COO->COO_CODIGO == COM->COM_CODIGO
		RecLock("COO",.F.)
		COO->COO_LOTE := ''
		COO->(MsUnlock())
		COO->(DbSkip())
	EndDo
EndIf

//-- Atualização do valor estimado do produto 
//CON_FILIAL+CON_CODIGO+CON_CODPRO+CON_LOTE
CON->(DbSetOrder(1))
For nPos := 1 To Len(aProds)
	//-- Retorna a quantidade de fornecedores por produto
	nQtdForn := 0	
	aEval( aForns, { |x| nQtdForn += iif( x[1] == aProds[nPos,1], 1, 0 ) } )
	
	//-- Retorna o valor estimado por produto
	nVlrEst := 0
	aEval( aCOP, { |x| nVlrEst += iif( x[1] == aProds[nPos,1], x[6], 0 ) } )
	//-- Atualiza valor estimado	
	If CON->(DbSeek(xFilial("CON")+COM->COM_CODIGO+aProds[nPos,1]))
		RecLock("CON",.F.)
		CON->CON_METODO 	:= "1"
		CON->CON_LOTE		:= ""
		CON->CON_VALEST	:= nVlrEst/nQtdForn
		CON->(MsUnlock())
	EndIf
	nVlrEstCOM += CON->CON_VALEST
Next nPos

//-- Atualizando a avaliação e o valor estimado da análise.
RecLock("COM",.F.)
COM->COM_VALEST := nVlrEstCOM
COM->COM_AVAL   := "1" 
COM->(MsUnlock())

End Transaction	

Return .T.