#Include 'PROTHEUS.ch'
#Include 'FWMVCDef.ch'
#Include 'GCPA102.CH'

/*
	Descrição: Esta rotina permite alterar uma Análise de Mercado feita
	inicialmente com o método de avaliação por ITEM para LOTE.
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
Local oStrCOM		:= FWFormStruct(1,'COM')
Local oStrCOQ		:= FWFormStruct(1,'COQ')
Local oStrCON		:= FWFormStruct(1,'CON')
Local oStrCOP 		:= FWFormStruct(1,'COP')
Local oStrCOY		:= FWFormStruct(1,'COY')
Local oStruCOO 	:= FWFormStruct(1,'COO')  

oModel := MPFormModel():New('GCPA102', ,{|oModel|A102PVLD(oModel)} ,{|oModel|A102Commit(oModel)})

oModel:SetDescription(STR0006) // 'Manutenção de Lote'
oModel:addFields('COMMASTER',,oStrCOM)
oModel:addGrid('COQDETAIL','COMMASTER',oStrCOQ)
oModel:addGrid('CONDETAIL','COMMASTER',oStrCON)
oModel:addGrid('COPDETAIL','CONDETAIL',oStrCOP)

oModel:addGrid('COYDETAIL','COMMASTER',oStrCOY)
oModel:AddGrid('COODETAIL', 'CONDETAIL', oStruCOO,{|oModelGrid, nLine,cAction,cField|PreValCOO(oModelGrid, nLine, cAction, cField)}) //-- Solicitações

oModel:SetRelation('CONDETAIL', { { 'CON_FILIAL', 'xFilial("CON")' }, { 'CON_CODIGO', 'COM_CODIGO' } }, CON->(IndexKey(1)) )
oModel:SetRelation('COQDETAIL', { { 'COQ_FILIAL', 'xFilial("COQ")' }, { 'COQ_CODIGO', 'COM_CODIGO' } }, COQ->(IndexKey(1)) )
oModel:SetRelation('COPDETAIL', { { 'COP_FILIAL', 'xFilial("COP")' }, { 'COP_CODIGO', 'COM_CODIGO' },  { 'COP_CODPRO', 'CON_CODPRO' }}, COP->(IndexKey(1)) )
oModel:SetRelation('COYDETAIL', { {'COY_FILIAL',	'xFilial("COY")' }, {'COY_CODIGO', 'COM_CODIGO'}} ,COY->(IndexKey(1)))
oModel:SetRelation('COODETAIL', { {'COO_FILIAL',	'xFilial("COO")'  }, {'COO_CODIGO', 'COM_CODIGO'},{'COO_CODPRO','CON_CODPRO'} },COO->(IndexKey(1)))

oModel:getModel('COMMASTER'):SetDescription(STR0001)//('Cabeçalho')
oModel:getModel('COQDETAIL'):SetDescription(STR0002)//('Lotes')
oModel:getModel('CONDETAIL'):SetDescription(STR0003)//('Produtos')
oModel:getModel('COPDETAIL'):SetDescription(STR0004)//('Fornecedores')
oModel:getModel('COYDETAIL'):SetDescription(STR0005)//('AnáliseXLoteXPrdXFrn')
oModel:GetModel('COODETAIL'):SetDescription(STR0009)//"Solicitações"

oModel:getModel('CONDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('CONDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('COYDETAIL'):SetOptional(.T.)
oModel:GetModel('COPDETAIL'):SetOptional(.T.)
oModel:GetModel('COQDETAIL'):SetOptional(.T.)
oModel:GetModel('COODETAIL'):SetOptional(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} A102MANUTE()
Rotina que realiza validação e a chamada da manutenção do lote.
@author antenor.silva
@return Nil
@since 26/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A102MANUTE()
Local lRet	:= .T.

//Verifica se a análise de mercado foi gerada manualmente e se está aberta.
If COM->COM_STATUS  <> '1'
	Help(" " ,1, "A102MNTLOTE") // "Análise de Mercado não habilitada para manutenção de lote." 
	lRet := .F.
EndIf

If lRet
	If COM->COM_AVAL == '1' // De Item para Lote
		FWExecView (STR0006, "GCPA102", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*{ ||}*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)
	ElseIf COM->COM_AVAL == '2'// De Lote para Item
		FWExecView (STR0006, "GCPA103", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*{ ||}*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A102PopCOQ(oModel)
Rotina para popular a tabela COQ com o número de lote da CON.
@author antenor.silva	
@since 26/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A102PopCOQ(oModel)
Local oModCON		:= oModel:GetModel('CONDETAIL')
Local oModCOQ		:= oModel:GetModel('COQDETAIL')
Local oModCOP		:= oModel:GetModel('COPDETAIL')
Local oModCOY		:= oModel:GetModel('COYDETAIL')
Local oModCOM		:= oModel:GetModel('COMMASTER')
Local aSaveLines 	:= FWSaveRows()
Local nVlrTot		:= 0
Local nSumLte		:= 0
Local nSumPrUn		:= 0
Local nQtde		:= 0
Local nVlrEstC		:= 0
Local nP			:= 0
Local nY			:= 0
Local nQ			:= 0
Local nN			:= 0
Local cLote			:= ""
Local aProds		:= {}
Local lAtualiza		:= .F.	
	
For nP := 1 To oModCON:length()
	oModCON:GoLine(nP)
	If aScan(aProds, {|x| x == oModCON:GetValue('CON_LOTE')}) == 0 			
		aadd(aProds, oModCON:GetValue('CON_LOTE'))
	EndIf	
Next nP

For nP := 1 To Len(aProds)
	If nP <> 1
		oModCOQ:AddLine()
	EndIf	
	oModCOQ:LoadValue('COQ_LOTE',aProds[nP])
Next nP

For nQ := 1 To oModCON:length()
	 oModCON:GoLine(nQ)
	 If cLote <> oModCON:GetValue('CON_LOTE')
		cLote := oModCON:GetValue('CON_LOTE')
	EndIf
	For nP := 1 To oModCOP:length()
		oModCOP:GoLine(nP)
		If !oModCOP:IsDeleted()
			nVlrTot := 0
			For nY := 1 To oModCOY:length()
				oModCOY:GoLine(nY)
				If	oModCOP:GetValue('COP_TIPO') == oModCOY:GetValue('COY_TIPO') .And.;
					oModCOP:GetValue('COP_CODFOR') == oModCOY:GetValue('COY_CODFOR') .And.;
				   	oModCOP:GetValue('COP_LOJFOR') == oModCOY:GetValue('COY_LOJFOR') .And.;
				   	oModCOP:GetValue('COP_LOTE')	== oModCOY:GetValue('COY_LOTE')
					nVlrTot += oModCOY:GetValue('COY_VLRTOT')
				EndIf				
			Next nY
			oModCOP:LoadValue('COP_PRCUN',nVlrTot)
			oModCOP:LoadValue('COP_VALTOT',nVlrTot)
		EndIf			
	Next nP
Next nQ

For nN := 1 To oModCON:Length()
	oModCON:GoLine(nN)
	nQtde 	 := 0
	nSumLte  := 0
	nSumPrUn := 0
	cLote := oModCON:GetValue('CON_LOTE')
			
	lAtualiza := .F.
	For nP := 1 To oModCOP:length()
		oModCOP:GoLine(nP)
		If !oModCOP:IsDeleted()
			If oModCON:GetValue('CON_LOTE') == oModCOP:GetValue('COP_LOTE')
				lAtualiza := .T.
				nQtde := oModCOP:length()
				nSumPrUn += oModCOP:GetValue('COP_PRCUN')
			EndIf	
		EndIf			
	Next nP
		
	If lAtualiza 
		For nQ := 1 To oModCOQ:length()
			oModCOQ:GoLine(nQ)
			If oModCON:GetValue('CON_LOTE') == oModCOQ:GetValue('COQ_LOTE') 							
				nSumLte := nSumPrUn / nQtde
				oModCOQ:LoadValue('COQ_VLRTOT',nSumLte)
			EndIf
		Next nQ
	EndIf													
Next nN	

// -- Atualizando o Valor estimado da Análise
For nQ := 1 To oModCOQ:length()
	oModCOQ:GoLine(nQ)
	nVlrEstC += oModCOQ:GetValue('COQ_VLRTOT')
Next nN
oModCOM:LoadValue('COM_VALEST',nVlrEstC)

FWRestRows(aSaveLines)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A102PopCOP(oModel)
Rotina para popular a tabela COP com o número de lote da CON.
@author antenor.silva	
@since 26/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A102PopCOP(oModel)
Local oModCON		:= oModel:GetModel('CONDETAIL')
Local oModCOP		:= oModel:GetModel('COPDETAIL')
Local aSaveLines 	:= FWSaveRows()
Local nP			:= 0
Local nX			:= 0

For nP := 1 To oModCON:Length()
	oModCON:GoLine(nP)
	For nX := 1 To oModCOP:Length()
		oModCOP:GoLine(nX)		
		oModCOP:LoadValue('COP_LOTE',oModCON:GetValue('CON_LOTE'))		
	Next nX
Next nP

FWRestRows(aSaveLines)
                                     
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A102PopCOO(oModel)
Rotina para popular a tabela COP com o número de lote da CON.
@author antenor.silva	
@since 10/02/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function A102PopCOO(oModel)
Local oModCON	:= oModel:GetModel('CONDETAIL')
Local oModCOO	:= oModel:GetModel('COODETAIL')
Local aSaveLines	:= FWSaveRows()
Local nN			:= 0
Local nO			:= 0

For nN := 1 To oModCON:Length()
	oModCON:GoLine(nN)
	For nO := 1 To oModCOO:Length()
		oModCOO:GoLine(nO)
		oModCOO:LoadValue('COO_LOTE',oModCON:GetValue('CON_LOTE') )
	Next nO
Next nN

FWRestRows(aSaveLines)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A102PopCOY(oModel)
Rotina para popular a composição do lote.
@author antenor.silva	
@since 03/01/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function A102PopCOY(oModel)
Local oModCOY 		:= oModel:GetModel('COYDETAIL')
Local oModCOP 		:= oModel:GetModel('COPDETAIL')
Local oModCON		:= oModel:GetModel('CONDETAIL')	
Local aSaveLines 	:= FWSaveRows()
Local nI 			:= 0
Local nProds		:= 0
Local cLote 		:= ""

For nProds := 1 To oModCON:Length()
	oModCON:GoLine(nProds)
	If cLote <> oModCON:GetValue('CON_LOTE')
		cLote := oModCON:GetValue('CON_LOTE')
	EndIf					
					
	For nI := 1 To oModCOP:Length()
		oModCOP:GoLine(nI)
		If cLote == oModCON:GetValue('CON_LOTE') 
			If !Empty(oModCOY:GetValue('COY_LOTE'))  
				oModCOY:AddLine()
			EndIf
			oModCOY:LoadValue('COY_LOTE'	,cLote)	
			oModCOY:LoadValue('COY_CODFOR'	,oModCOP:GetValue('COP_CODFOR'))	
			oModCOY:LoadValue('COY_LOJFOR'	,oModCOP:GetValue('COP_LOJFOR'))	
			oModCOY:LoadValue('COY_PRCUN' 	,oModCOP:GetValue('COP_PRCUN'))
			oModCOY:LoadValue('COY_QUANT' 	,oModCON:GetValue('CON_QUANT'))	
			oModCOY:LoadValue('COY_VLRTOT'	,oModCOP:GetValue('COP_PRCUN') * oModCON:GetValue('CON_QUANT'))
			oModCOY:LoadValue('COY_CODPRO'	,oModCON:GetValue('CON_CODPRO'))
			oModCOY:LoadValue('COY_TIPO'	,oModCOP:GetValue('COP_TIPO'))					
		EndIf														
	Next nI	
Next nProds			

FWRestRows(aSaveLines)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A102Commit(oModel)
Rotina para realizar a persistência do modelo.
@author antenor.silva	
@since 30/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A102Commit(oModel)
Local oModCOM		:= oModel:GetModel('COMMASTER')
Local oModCOP		:= oModel:GetModel('COPDETAIL')
Local oModCON		:= oModel:GetModel('CONDETAIL')
Local lRet 		:= .T.
Local cSeekCOP 	:= ""
Local cLote		:= ""
Local nY			:= 0
Local nX			:= 0
Local nZ			:= 0
Local nW			:= 0
Local nLinha    	:= 0
Local aLotes    	:= {}
Local lDeleta  	:= .F. 

For nX := 1 to oModCON:length()
	oModCON:GoLine(nX)	
	nLinha := aScan(aLotes, {|x| x[1] == oModCON:GetValue('CON_LOTE')}) 
	If nLinha == 0
		Aadd(aLotes, {oModCON:GetValue('CON_LOTE'), {oModCON:nLine}})
	else
		Aadd(aLotes[nLinha, 2], oModCON:nLine) 									
	EndIf
Next nX		
	
For nX := 1 To Len(aLotes)
	For nZ := 1 To Len(aLotes[nX, 2]) - 1
		oModCON:GoLine(aLotes[nX, 2][nZ])						
		For nW := 1 to oModCOP:length()
			oModCOP:GoLine(nW) 					
			oModCOP:DeleteLine()																												
		Next nW
	Next nZ
Next nX		
	
oModel:LoadValue('COMMASTER','COM_AVAL','2')
A102PopCOP(oModel)
A102PopCOY(oModel)
A102PopCOQ(oModel)
A102PopCOO(oModel)

If lRet
	FwFormCommit(oModel)
	If COP->(dbSeek(cSeekCOP := xFilial("COP")+COM->COM_CODIGO))
		While COP->(!EOF()) .And. COP->( COP_FILIAL+COP->COP_CODIGO) == cSeekCOP						
			RecLock("COP",.F.)
			COP->COP_CODPRO := ""
			COP->(MsUnLock())			
			COP->(dbSkip())								
		EndDo	
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A102PVLD(oModel)
Verifica se o fornecedor deu lance a todos os itens que compõem o lote.
@author antenor.silva	
@since 26/12/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A102PVLD(oModel)
Local oModCON		:= oModel:GetModel('CONDETAIL')
Local oModCOP		:= oModel:GetModel('COPDETAIL')
Local aSaveLines 	:= FWSaveRows()
Local aForn		:= {}
Local aLote		:= {}
Local aProds		:= {}
Local nF			:= 0
Local nL			:= 0
Local nX			:= 0
Local nY 			:= 0
Local lRet			:= .T.
Local cLote		:= ""
Local nLinha		:= 0

For nX :=1 To oModCON:Length()
	oModCON:GoLine(nX)
	If Empty(oModCON:GetValue('CON_LOTE'))
		Help(" " ,1, "A102SEMLTE") //'Um ou mais lotes não foram informados.'
		lRet := .F.
		Exit		
	EndIf
Next nX

If lRet
	For nX := 1 to oModCON:length()
		If !lRet
			Exit
		EndIf
		oModCON:GoLine(nX)
		If cLote <> oModCON:GetValue('CON_LOTE') 
			cLote := oModCON:GetValue('CON_LOTE')
		EndIf		
		
		//Armazena os fornecedores do produto selecionado.
		aForn := {}
		For nY := 1 To oModCOP:length()
			oModCOP:GoLine(nY)
			aadd(aForn, {oModCOP:GetValue('COP_TIPO'), oModCOP:GetValue('COP_CODFOR'), oModCOP:GetValue('COP_LOJFOR')})		
		Next nY
		
		//Procura os fornecedores nos demais produtos.
		For nL := 1 to oModCON:length()
			If !lRet
				Exit
			EndIf				
			oModCON:GoLine(nL)
			If cLote == oModCON:GetValue('CON_LOTE')
				For nY := 1 To oModCOP:length()
					oModCOP:GoLine(nY)						
					If aScan(aForn, {|x| Alltrim(x[1]) + Alltrim(x[2]) + Alltrim(x[3]) == Alltrim(oModCOP:GetValue('COP_TIPO')) + Alltrim(oModCOP:GetValue('COP_CODFOR')) + Alltrim(oModCOP:GetValue('COP_LOJFOR'))}) == 0				
						Help(" " ,1, "A102FORPRD")	
						lRet := .F.
						Exit
					EndIf
				Next nY
			Endif					
		Next nL
	Next nX
	
	FWRestRows(aSaveLines)
EndIf

Return lRet