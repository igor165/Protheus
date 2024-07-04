#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153D.ch'

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153D
Controle Detalhado de Metas
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/ 
//-------------------------------------------------------------------------------------------------
Function TMSA153D()
	//Funcionalidades de Controle Detalhado de Metas
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menudef
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

	aAdd(aRotina, {STR0001,'TMS153F()', 0, 3, 0, NIL}) //Cadastrar Meta 
	aAdd(aRotina, {STR0002,'VIEWDEF.TMSA153D', 0, 4, 0, NIL}) //Alterar
	aAdd(aRotina, {STR0003,'VIEWDEF.TMSA153D', 0, 2, 0, NIL}) //Visualizar
	aAdd(aRotina, {STR0004,'VIEWDEF.TMSA153D', 0, 5, 0, NIL}) //Excluir
	aAdd(aRotina, {STR0005,'TMCONDEM()', 0, 4, 0, NIL}) //Gerar Demandas
	
Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruDL7 := FWFormStruct(1, "DL7",{|cCampo| AllTrim(cCampo) $ "DL7_COD,DL7_CLIDEV,DL7_LOJDEV,DL7_NOMDEV,DL7_TIPCTR,DL7_NOMTIP,DL7_INIVIG,DL7_FIMVIG,DL7_UM"})
Local oStruDLE := FWFormStruct(1, "DLE",{|cCampo| AllTrim(cCampo) $ "DLE_CRTDMD,DLE_CODGRD,DLE_DESGRD,DLE_QTD"})
Local aCamposDLE := aClone(oStruDLE:GetFields())
Local aStruDLG := {}
Local aTipVei := {}
Local oModel
Local nX := 1
	
	//Adiciona campos à estrutura
	For nX := 1 to Len(aCamposDLE)
		//Para os campos exibidos na seção superior da tel foi feita essa ""adaptação"" de campo virtual pois na operação de exclusão o setload após exibir a view ocasionava erro.
		If aCamposDLE[nX][3] == 'DLE_CODGRD'
			aCamposDLE[nX][11] := {|| &('DLE->DLE_CODGRD')} 
			aCamposDLE[nX][14] := .T.
		ElseIf aCamposDLE[nX][3] == 'DLE_QTD'
			aCamposDLE[nX][11] := {|| &('DLE->DLE_QTD')} 
			aCamposDLE[nX][14] := .T.
		EndIf		

		oStruDL7:AddField(aCamposDLE[nX][1],aCamposDLE[nX][2],aCamposDLE[nX][3],aCamposDLE[nX][4],aCamposDLE[nX][5],aCamposDLE[nX][6],aCamposDLE[nX][7],aCamposDLE[nX][8],aCamposDLE[nX][9],aCamposDLE[nX][10],aCamposDLE[nX][11],aCamposDLE[nX][12],aCamposDLE[nX][13],aCamposDLE[nX][14],aCamposDLE[nX][15])
	Next nX
	
	oModel := MPFormModel():New("TMSA153D", , {|oModel| TM153DVld(oModel, aTipVei)}, {|oModel| TM153DGrav(oModel, aTipVei)}, {|oModel| T153DCanc(oModel)} )
	 
	oModel:AddFields('MASTER_DLE',nil,oStruDL7)
	
	oModel:SetDescription(STR0010) //Controle Detalhado de Metas	
		
	oModel:SetPrimaryKey({"DLE_FILIAL","DLE_CRTDMD","DLE_CODGRD"})
	
	//Se meta utiliza tipo de veiculos, cria um grid para cada tipo de veiculo
	If DLF->(DbSeek(xFilial('DLF')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD))
		//Cria array de estrura e tipos de veiculos
		nX := 1
		While DLF->(!Eof()) .And. DLF->DLF_CRTDMD == DLE->DLE_CRTDMD .And. DLF->DLF_CODGRD == DLE->DLE_CODGRD
			aadd(aStruDLG, FWFormStruct(1, "DLG",{|cCampo| AllTrim(cCampo) $ "DLG_TIPVEI,DLG_SEQ,DLG_DATINI,DLG_DATFIM,DLG_QTD,DLG_SALDO,DLG_QTDDEM,DLG_QTDPLN,DLG_QTDPRG,DLG_QTDVIA,DLG_QTDREC,DLG_QTDRCL,DLG_QTDDEX,DLG_QTDENC,DLG_QTDCAN,DLG_QTDBLQ,DLG_QTDREP"}))
			aadd(aTipVei, DLF->DLF_TIPVEI)
			
			//Altera Inic. Padrao do campo DLG_TIPVEI
			aStruDLG[nX]:SetProperty('DLG_TIPVEI',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'"+aTipVei[nX]+"'"))
			
			//Cria grid por tipo de veiculo
			oModel:AddGrid('GRID_TPV'+aTipVei[nX],'MASTER_DLE',aStruDLG[nX],,,{ | oModel,nLine,cOpera | T153DPREVL( oModel, nLine, cOpera) },/*bPosVal*/ )
			oModel:GetModel('GRID_TPV'+aTipVei[nX]):SetOptional(.T.)
			oModel:GetModel('GRID_TPV'+aTipVei[nX]):SetMaxLine(999999)
			oModel:SetRelation('GRID_TPV'+aTipVei[nX], { { 'DLG_FILIAL', 'xFilial( "DLG" ) ' } , { 'DLG_CODCRT', 'DLE->DLE_CRTDMD' } , {'DLG_CODGRD', 'DLE->DLE_CODGRD'}, {'DLG_TIPVEI', "'"+AllTrim(aTipVei[nX])+"'"}}, DLG->( IndexKey( 2 ) ) )
			
			aStruDLG[nX]:AddTrigger("DLG_QTD", "DLG_QTD", {||.T.}, {|oModel|LoadSaldo(oModel)})
			
			DLF->(DbSkip())
			nX++
		EndDo 	
	Else
		//Meta sem tipo de veiculo
		aadd(aStruDLG, FWFormStruct(1, "DLG",{|cCampo| AllTrim(cCampo) $ "DLG_TIPVEI,DLG_SEQ,DLG_DATINI,DLG_DATFIM,DLG_QTD,DLG_SALDO,DLG_QTDDEM,DLG_QTDPLN,DLG_QTDPRG,DLG_QTDVIA,DLG_QTDREC,DLG_QTDRCL,DLG_QTDDEX,DLG_QTDENC,DLG_QTDCAN,DLG_QTDBLQ,DLG_QTDREP"}))
		
		oModel:AddGrid('GRID_META','MASTER_DLE',aStruDLG[1], { | oModel | T153DPrLin( oModel) } , { | oModel | T153DLNPOS( oModel) }, { | oModel,nLine,cOpera | T153DPREVL( oModel, nLine, cOpera) } , /*bPosVal*/ )
		oModel:GetModel('GRID_META'):SetOptional(.T.)
		oModel:GetModel('GRID_META'):SetMaxLine(999999)
		oModel:SetRelation( 'GRID_META', { { 'DLG_FILIAL', 'xFilial( "DLG" ) ' } , { 'DLG_CODCRT', 'DLE->DLE_CRTDMD' } , {'DLG_CODGRD', 'DLE->DLE_CODGRD'}}, DLG->( IndexKey( 2 ) ) )
		
		
		aStruDLG[1]:AddTrigger("DLG_QTD", "DLG_QTD", {||.T.}, {|oModel|LoadSaldo(oModel)})
		
	EndIf
	
	oStruDL7:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	
	oModel:SetVldActivate ( { |oModel, nLine, cAction| TMSA153DVL(oModel,nLine, cAction) } )

Return oModel

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('TMSA153D')
Local oStruDLG := FWFormStruct(2,"DLG",{|cCampo| AllTrim(cCampo) $ "DLG_DATINI,DLG_DATFIM,DLG_QTD,DLG_SALDO,DLG_QTDDEM,DLG_QTDPLN,DLG_QTDPRG,DLG_QTDVIA,DLG_QTDREC,DLG_QTDRCL,DLG_QTDDEX,DLG_QTDENC,DLG_QTDCAN,DLG_QTDBLQ,DLG_QTDREP"})
Local oStruDL7 := FWFormStruct(2,"DL7",{|cCampo| AllTrim(cCampo) $ "DL7_COD,DL7_CLIDEV,DL7_LOJDEV,DL7_NOMDEV,DL7_TIPCTR,DL7_NOMTIP,DL7_INIVIG,DL7_FIMVIG,DL7_UM"})
Local oStruDLE := FWFormStruct(2,"DLE",{|cCampo| AllTrim(cCampo) $ "DLE_CODGRD,DLE_DESGRD,DLE_QTD"})
Local aCamposDLE := aClone(oStruDLE:GetFields())
Local nPos := Len(oStruDL7:GetFields())+1
Local aTipVei := {}
Local nX := 1
Local nI := 1

Local cFunction := "TMSA153D"

	IIf(ExistFunc('FwPdLogUser'),FwPdLogUser(cFunction),)

	//Adiciona campos a estrutura
	For nX := 1 to Len(aCamposDLE)
		nPos++
		oStruDL7:AddField(aCamposDLE[nX][1],cValToChar(nPos),aCamposDLE[nX][3],aCamposDLE[nX][4],aCamposDLE[nX][5],aCamposDLE[nX][6],aCamposDLE[nX][7],aCamposDLE[nX][8],aCamposDLE[nX][9],aCamposDLE[nX][10],aCamposDLE[nX][11],aCamposDLE[nX][12],aCamposDLE[nX][13],aCamposDLE[nX][14],aCamposDLE[nX][15],aCamposDLE[nX][16],aCamposDLE[nX][17],aCamposDLE[nX][18])
	Next nX
	
	oView := FWFormView():New()

	oView:SetModel( oModel )
	
	oStruDL7:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	
	oView:AddField( 'VIEW_TOP', oStruDL7, 'MASTER_DLE' )
			
	oView:CreateHorizontalBox('BOX_TOPO',30)
	oView:CreateHorizontalBox('BOX_DOWN',70)
		
	//Se meta utiliza tipo de veiculos, cria uma aba para cada tipo de veiculo
	If DLF->(DbSeek(xFilial('DLF')+DLE->DLE_CRTDMD+DLE->DLE_CODGRD))
		oView:CreateFolder('META', 'BOX_DOWN')
		While DLF->(!Eof()) .And. DLF->DLF_CRTDMD == DLE->DLE_CRTDMD .And. DLF->DLF_CODGRD == DLE->DLE_CODGRD
			aadd(aTipVei, DLF->DLF_TIPVEI)
			
			//Adiciona a aba por tipo de veiculo
			oView:AddSheet('META','SHTTPV'+aTipVei[nI], Posicione('DUT', 1, xFilial('DUT')+aTipVei[nI], 'DUT_DESCRI'))
			oView:CreateHorizontalBox('BOX_TPV'+aTipVei[nI], 100,,/*lPixel*/, 'META', 'SHTTPV'+aTipVei[nI])	
			oView:AddGrid('GRID_TPV'+aTipVei[nI], oStruDLG, 'GRID_TPV'+aTipVei[nI])
			oView:SetOwnerView( 'GRID_TPV'+aTipVei[nI],'BOX_TPV'+aTipVei[nI])
						
			DLF->(DbSkip())
			nI++
		EndDo 	
	Else	
		//Meta sem tipo de veiculo
		oView:AddGrid('GRID_META', oStruDLG, 'GRID_META')
		oView:SetOwnerView( 'GRID_META','BOX_DOWN')
	EndIf
	
	oView:SetOwnerView( 'VIEW_TOP', 'BOX_TOPO')
	//oView:SetAfterViewActivate({|oView| AfterVwAct(oView) })
		
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterVwAct
Validação para mudar a máscara do campo "Quantidade". Altera a propriedade da picture, porém, não está refletindo na tela.
Futuramente, verificar se esta função é necessária ou não. Se não for, removê-la. 
@type function
@author Aluizio Fernando Habizenreuter
@version 12.1.17
@since 09/07/2018
/*/
//-------------------------------------------------------------------
Static Function AfterVwAct(oView) 	
Local oModel 	 := Nil         	// Recebe o Model 
Local oModelDLE  := Nil 			// Recebe o Model 
Local nOperation := oView:GetOperation()
Local lRet 		 := .T.	
Local aAreaDLG   := {}

    //Bloqueia ou não a adição de linha quando utiliza meta detalhada e possui meta cadastrada no primeiro registro. Tratativa de desbloqueio é realizada na View na função ChangeLine().
	oModel	   := oView:GetModel()
	oModelDLE  := oModel:GetModel('MASTER_DLE')  
	If oModelDLE:GetValue('DL7_UM') == "2" //Quantidade de veículo	
		//oModelDLE:SetProperty("DLE_QTD",MVC_VIEW_PICT,"@E 999,999,999")
		oModelDLE:GetStruct():SetProperty("DLE_QTD", MVC_VIEW_PICT,"@E 999,999,999")
		//oModelDLE:GetStruct():SetProperty("DLE_QTD", MVC_VIEW_PICTVAR,"@E 999,999,999")
	Else
		//oModelDLE:SetProperty("DLE_QTD",MVC_VIEW_PICT,"@E 999,999,999.9999")			
		oModelDLE:GetStruct():SetProperty("DLE_QTD", MVC_VIEW_PICT,"@E 999,999,999.9999")
		//oModelDLE:GetStruct():SetProperty("DLE_QTD", MVC_VIEW_PICTVAR,"@E 999,999,999.9999")
	EndIf
	
	oView:Refresh('MASTER_DLE')
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153DVld
Usado para validação dos dados da tela, antes da gravação efetiva no banco de dados.
@type function
@author Aluizio Fernando Habizenreuter
@version 12.1.17
@since 22/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM153DVld(oModel, aTipVei) 
Local oModelDLG 
Local oModelDLE  := oModel:GetModel('MASTER_DLE')
Local nOperation := oModel:GetOperation()
Local nX		 := 0
Local nI         := 0
Local lRet 		 := .T.
Local nQtdMetas  := 0
Local nQtdDLE    := 0
Local aAreaDL7 
Local aAreaDLE
Local nY         := 0
Local dDatIni    
Local dDatFim
Local lAutoma	 := IsBlind() //--IsBlind = trava para execucoes sem interface (automacao)
Local cCodCrt	 := If( lAutoma , DL7->DL7_COD   , oModelDLE:GetValue('DL7_COD') )
Local cCodGrd	 := If( lAutoma , DLE->DLE_CODGRD, oModelDLE:GetValue('DLE_CODGRD') )                                                      

//Somar a quantidade das Metas, comparar com a quantidade da Região, e emitir pergunta ao usuário para confirmação do cadastro das Metas.
//Caso seja escolhido "SIM", atualizar a quantidade da Região e do Contrato.
If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	If !Empty(aTipVei)
		For nI := 1 to Len(aTipVei)
			oModelDLG := oModel:GetModel('GRID_TPV'+aTipVei[nI])
			For nX := 1 to oModelDLG:GetQtdLine()
				oModelDLG:GoLine(nX)
				If !oModelDLG:IsDeleted(nX)
					nQtdMetas += oModelDLG:GetValue('DLG_QTD')
				
					//Validação das datas das metas, visando não existir conflito entre elas.
					dDatIni  := oModelDLG:GetValue('DLG_DATINI')
					dDatFim  := oModelDLG:GetValue('DLG_DATFIM')
					For nY := 1 to oModelDLG:GetQtdLine()
						If nX <> nY
							oModelDLG:GoLine(nY)
							If !oModelDLG:IsDeleted(nY)
								If (oModelDLG:GetValue('DLG_DATINI') >= dDatIni .And. oModelDLG:GetValue('DLG_DATINI') <= dDatFim) .Or.;   
								   (oModelDLG:GetValue('DLG_DATFIM') >= dDatIni .And. oModelDLG:GetValue('DLG_DATFIM') <= dDatFim)
								   //"As metas das linhas abaixo possuem data(s) conflitante(s) para o tipo de veículo XXXXXXXXX:
								   //"nY - Inicio DD/MM/YYYY - Fim DD/MM/YYYY"
								   //"nX - Inicio DD/MM/YYYY - Fim DD/MM/YYYY"
								   MsgAlert(STR0024 + STR0025 + Alltrim(Posicione('DUT', 1, xFilial('DUT')+aTipVei[nI], 'DUT_DESCRI')) + ":" + Chr(13) + Chr(10);
								    + cValToChar(nX) + STR0026 + dtoc(dDatIni) + STR0027 + dtoc(dDatFim) + Chr(13) + Chr(10);
								    + cValToChar(nY) + STR0026 + dtoc(oModelDLG:GetValue('DLG_DATINI')) + STR0027 + dtoc(oModelDLG:GetValue('DLG_DATFIM')))
								   FwClearHLP()
								   oModel:SetErrorMessage('TMSA153D',,,,,STR0011,'', nil, nil) //"Metas não cadastradas/atualizadas."
								   lRet := .F.		
								   Exit				   
								EndIf
							EndIf
						EndIf
					Next nY			
					If !lRet
						Exit
					EndIf				
				EndIf
			Next nX	
			If !lRet
				Exit
			EndIf			
		Next nI
	Else	
		oModelDLG := oModel:GetModel('GRID_META')
		For nX := 1 to oModelDLG:GetQtdLine()
			oModelDLG:GoLine(nX)
			If !oModelDLG:IsDeleted(nX)
				nQtdMetas += oModelDLG:GetValue('DLG_QTD')
			
				//Validação das datas das metas, visando não existir conflito entre elas.
				dDatIni  := oModelDLG:GetValue('DLG_DATINI')
				dDatFim  := oModelDLG:GetValue('DLG_DATFIM')
				For nY := 1 to oModelDLG:GetQtdLine()
					If nX <> nY
						oModelDLG:GoLine(nY)
						If !oModelDLG:IsDeleted(nY)
							If (oModelDLG:GetValue('DLG_DATINI') >= dDatIni .And. oModelDLG:GetValue('DLG_DATINI') <= dDatFim) .Or.;   
							   (oModelDLG:GetValue('DLG_DATFIM') >= dDatIni .And. oModelDLG:GetValue('DLG_DATFIM') <= dDatFim)
							   //"As metas das linhas abaixo possuem data(s) conflitante(s):
							   //"nY - Inicio DD/MM/YYYY - Fim DD/MM/YYYY"
							   //"nX - Inicio DD/MM/YYYY - Fim DD/MM/YYYY"
							   MsgAlert(STR0024 + ":" + Chr(13) + Chr(10);
							   + cValToChar(nX) + STR0026 + dtoc(dDatIni) + STR0027 + dtoc(dDatFim) + Chr(13) + Chr(10);
							   + cValToChar(nY) + STR0026 + dtoc(oModelDLG:GetValue('DLG_DATINI')) + STR0027 + dtoc(oModelDLG:GetValue('DLG_DATFIM')))							   							   
							   FwClearHLP()
							   oModel:SetErrorMessage('TMSA153D',,,,,STR0011,'', nil, nil) //"Metas não cadastradas/atualizadas."
							   lRet := .F.		
							   Exit				   
							EndIf
						EndIf
					EndIf
				Next nY			
				If !lRet
					Exit
				EndIf
			EndIf
		Next nX
	EndIf	

	If lRet .And. nQtdMetas <> oModelDLE:GetValue('DLE_QTD')
		//-- Automacao
		If !lAutoma
			//"O valor total informado na meta (999) é diferente do valor informado no grupo de regiões do contrato de demandas (888). Confirma a atualização dos valores informados no contrato de demandas?"
			lRet := MSGYESNO(STR0006 + cValToChar(nQtdMetas) + STR0007 + cValToChar(oModelDLE:GetValue('DLE_QTD')) + STR0008,STR0009)
		EndIf 

		If lRet 
			aAreaDL7 := DL7->(GetArea())
			dbSelectArea("DL7")
			DL7->(dbSetOrder(1))
			If DL7->(dbSeek(xFilial('DL7')+oModelDLE:GetValue('DL7_COD')))
				//Se a Unidade de Medida do Contrato for Peso, abrir tela para informação das quantidades para cada Região, 
				If DL7->DL7_UM == "1" .AND. !lAutoma 
					lRet := TM153DIQR(oModelDLE:GetValue('DL7_COD'), oModelDLE:GetValue('DLE_CODGRD'), nQtdMetas)
					If !lRet
						FwClearHLP()
						oModel:SetErrorMessage('TMSA153D',,,,,STR0011,'', nil, nil) //"Metas não cadastradas/atualizadas."
						lRet := .F.
					EndIf
				EndIf
				
				If lRet
					//Para ambas unidades de medida, atualizar a quantidade do Contrato e do Grupo de Regiões.
					aAreaDLE := DLE->(GetArea())
					dbSelectArea("DLE")
					DLE->(dbSetOrder(2))
					If DLE->(dbSeek(xFilial('DLE')+cCodCrt+cCodGrd))
						nQtdDLE := DLE->DLE_QTD 
						
						//Atualização da Quantidade do Grupo de Regiões
						RecLock("DLE",.F.)
						DLE->DLE_QTD := nQtdMetas
						MsUnlock("DLE")
						
						//Atualização da Quantidade do Contrato. Desconta a quantidade antiga do Grupo de Regiões, e acrescenta a nova.
						RecLock("DL7",.F.)
						DL7->DL7_QTDTOT := (DL7->DL7_QTDTOT - nQtdDLE) + nQtdMetas
						MsUnlock("DL7")																		
					EndIf
					RestArea(aAreaDLE)
				EndIf
			EndIf
			RestArea(aAreaDL7)
		Else
			FwClearHLP()
			oModel:SetErrorMessage('TMSA153D',,,,,STR0011,'', nil, nil) //"Metas não cadastradas/atualizadas."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153DIQR
Usado para informar a quantidade para cada região, quando o Contrato tiver unidade de medida igual a Peso.
@type function
@author Aluizio Fernando Habizenreuter
@version 12.1.17
@since 25/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM153DIQR(cContr, cCodGrd, nQtdMetas)
Local oDlg
Local cSeekDLM := ''
Local lRet     := .F.
Local aAreaDLM
Local aAreaDLM2
Local aAltera    := {}
Local nX := 0
Private aCols    := {}
Private aHeadDLM := {}

cSeekDLM := xFilial('DLM')+cContr+cCodGrd

aAreaDLM := DLM->(GetArea())
DLM->(dbSetOrder(1))
If DLM->(MsSeek(cSeekDLM))
	Do While !DLM->(Eof()) .And. DLM->(DLM_FILIAL+DLM_CRTDMD+DLM_CODGRD) == cSeekDLM
		AAdd(aCols,  {DLM->DLM_SEQREG, DLM->DLM_CODREG, Posicione('DUY',1,xFilial('DUY')+DLM->DLM_CODREG,'DUY_DESCRI'), DLM->DLM_QTD, .F.})
		DLM->(dbSkip())
	EndDo
	
	If Len(aCols) > 0
		SaveInter()
		
		aadd(aHeadDLM, {STR0012, 'DLM_SEQREG', '@!', TAMSX3("DLM_SEQREG")[1], 0, Nil, Nil , 'C', Nil, 'V'} ) //Sequencia
		aadd(aHeadDLM, {STR0013, 'DLM_CODREG', '@!', TAMSX3("DLM_CODREG")[1], 0, Nil, Nil , 'C', Nil, 'V'} ) //Código
		aadd(aHeadDLM, {STR0014, 'DUY_DESCRI', '@!', TAMSX3("DUY_DESCRI")[1], 0, Nil, Nil , 'C', Nil, 'V'} ) //Descrição 
		aadd(aHeadDLM, {STR0015, 'XXX_QTD', PesqPict('DLM','DLM_QTD'), TAMSX3("DLM_QTD")[1], 0, Nil, Nil , 'N', Nil, Nil} ) //Quantidade
		
		aadd(aAltera, "XXX_QTD")
		
		//Monta o Dialog tela de fracionamento de demanda 
		DEFINE MSDIALOG oDlg FROM 000,000 TO 500,530 TITLE STR0016 Of oMainWnd PIXEL //"Distribua a quantidade das metas entre as regiões abaixo"
		
			//Calcula as dimensoes
			oSize := FwDefSize():New(.T.,,,oDlg)        
		
			oSize:AddObject( "CABECALHO",  100, 10, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "GETDADOS" ,  100, 90, .T., .T. ) // Totalmente dimensionavel 
			
			oSize:lProp 	:= .T. // Proporcional             
			oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
				
			oSize:Process() 	   // Dispara os calculos 
			
			@ oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI")        SAY STR0017 Of oDlg PIXEL SIZE 56 ,9 //Contrato: 
			@ oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI")+26     SAY cContr  Of oDlg PIXEL SIZE 24 ,9 //Código do Contrato						
			
			@ oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI")+80    SAY STR0018   Of oDlg PIXEL SIZE 60 ,9 //Qtd. total das metas: 
			@ oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI")+132    SAY cValtoChar(nQtdMetas) Of oDlg PIXEL SIZE 42 ,9

			@ oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")     SAY STR0019 Of oDlg PIXEL SIZE 60 ,9 //Grupo de Regiões:
			@ oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+48  SAY cCodGrd Of oDlg PIXEL SIZE 24 ,9 //Código do Grupo de Regiões

			@ oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+80 SAY STR0020 Of oDlg PIXEL SIZE 60 ,9 //Descrição:
			@ oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+110 SAY Posicione('DLC',1,xFilial('DLC')+cCodGrd,'DLC_DESCRI') Of oDlg PIXEL SIZE 100 ,9 //Descrição do Grupo de Regiões
	
			oGetDad := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
		     							   oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
											GD_UPDATE,/*cLinhaOk*/,/*cTudoOk*/,/*cIniCpos*/,aAltera,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*superdel*/,/*cDelOk*/,oDlg,aHeadDLM,aCols)
											
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(TM153DVlRg(nQtdMetas, oGetDad:aCols),(lRet := .T., oDlg:End()),.F.)},{||(lRet := .F., oDlg:End())},,/*aButtons*/)
	
		RestInter()
		
		//Se as quantidades estiverem iguais, atualizá-las na tabela DLM.
		If lRet
			aAreaDLM2 := DLM->(GetArea())
			DLM->(dbSetOrder(1))
			For nX := 1 to Len(oGetDad:aCols)
				If DLM->(MsSeek(cSeekDLM+oGetDad:aCols[nX][1]+oGetDad:aCols[nX][2]))
					RecLock("DLM",.F.)
					DLM->DLM_QTD := oGetDad:aCols[nX][4]
					MsUnlock("DLM")
				EndIf		
			Next nX
			RestArea(aAreaDLM2)
		EndIf
	EndIf
EndIf
RestArea(aAreaDLM)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153DVlRg
Usado para Validação do total das Regiões, de acordo com o total das metas.
@type function
@author Aluizio Fernando Habizenreuter
@version 12.1.17
@since 26/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM153DVlRg(nQtdMetas, aAux)
Local lRet := .F.
Local nQtdRegs := 0 //Totalizador das quantidades informadas na tela desta função.
Local nX := 0 

For nX := 1 to Len(aAux)
	nQtdRegs += aAux[nX][4]
Next nX

If nQtdRegs == nQtdMetas
	lRet := .T.
Else
	//"O valor total informado nas regiões (999) é diferente do valor total informado nas metas (888)."
	MsgAlert(STR0021 + cValToChar(nQtdRegs) + STR0022 + cValToChar(nQtdMetas) + ").") 
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153DGrav
Usado para gravação dos registros no banco de dados
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM153DGrav(oModel, aTipVei) 
Local nOperation:= oModel:GetOperation()
Local nSequencia:= '000' 
Local oModelDLG := Nil
Local aLinAlter := Nil
Local oModelDLE := oModel:GetModel('MASTER_DLE')
Local lRet := .T.
Local nX := 0
Local nI := 0

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		If !Empty(aTipVei)
			For nI := 1 to Len(aTipVei)
				oModelDLG := oModel:GetModel('GRID_TPV'+aTipVei[nI])
				aLinAlter := oModelDLG:GetLinesChanged(2)
				nSequencia := Iif(!Empty(oModelDLG:MaxValueField('DLG_SEQ')), oModelDLG:MaxValueField('DLG_SEQ'), '000')
	
				For nX := 1 to Len(aLinAlter)
					oModelDLG:SetLine(aLinAlter[nX]) 
					If !oModelDLG:IsDeleted() .AND. Empty(oModelDLG:GetValue('DLG_SEQ',aLinAlter[nX])) .AND. oModelDLG:IsInserted(aLinAlter[nX])						
						nSequencia := Soma1(nSequencia)
						oModelDLG:SetValue('DLG_SEQ',nSequencia)	
					EndIf
				Next nX	
			Next nI  
		Else
			oModelDLG := oModel:GetModel('GRID_META')
			aLinAlter := oModelDLG:GetLinesChanged(2)
			nSequencia := Iif(!Empty(oModelDLG:MaxValueField('DLG_SEQ')), oModelDLG:MaxValueField('DLG_SEQ'), '000')  
			For nX := 1 to Len(aLinAlter)
				oModelDLG:SetLine(aLinAlter[nX]) 
				If !oModelDLG:IsDeleted() .AND. Empty(oModelDLG:GetValue('DLG_SEQ',aLinAlter[nX])) .AND. oModelDLG:IsInserted(aLinAlter[nX])
					nSequencia := Soma1(nSequencia) 
					oModelDLG:SetValue('DLG_SEQ',nSequencia)	
				EndIf
			Next nX	
		EndIf
	EndIf
	
	If lRet
		
		If nOperation == MODEL_OPERATION_INSERT
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf 
	
		If nOperation == MODEL_OPERATION_DELETE //O delete é feito apenas na DLG (metas), portanto não pode haver o commit do model
			lRet := TmDelMeta(oModelDLE:GetValue('DL7_COD'), oModelDLE:GetValue('DLE_CODGRD'))
		Else
			lRet := FwFormCommit(oModel)
		EndIf
		
		If !lRet
			DisarmTransaction()
			Break
		EndIf		
	EndIf
End Transaction

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153DCanc
Usado para cancelamento do processo de edição/exclusão/inclusão
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
Static Function T153DCanc(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()

	If lRet .AND. (nOperation == MODEL_OPERATION_UPDATE) .Or. (nOperation == MODEL_OPERATION_DELETE)

	EndIf
  	
	FWFormCancel(oModel)
	
	If __lSX8
		RollBackSX8()
	EndIf	
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153DPrLin
Pré validação da linha das grids de Meta.
@param oModelGrid: Model que contém as informações a serem validadas.
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153DPrLin (oModelGrid) 
Local nOperation := oModelGrid:GetOperation()
Local lRet	     := .T.

	If lRet .AND. nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
			
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153DPreVl()
Função de pré-validação do submodelo, é invocado na deleção de linha, no undelete da linha, 
na inserção de uma linha e nas tentativas de atribuição de valor.
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------
Static Function T153DPreVl( oModelGrid, nLine, cOpera) 	
Local lRet       := .T.
Local aRet       := {.T., ''}
Local nOperation := oModelGrid:GetOperation()
Local oModelDLG
Local oModelDL7
Local cSeqMeta   := ''
Local cTipVei    := ''
Local dDtInMt, dDtFiMt, dDtInCt, dDtFiCt

	//Obtenção das vigências do Contrato para comparativo com as datas das metas.
	oModelDL7 := oModelGrid:GetModel("MASTER_DLE")		
	dDtInCt   := oModelDL7:GetValue("MASTER_DLE","DL7_INIVIG")
	dDtFiCt   := oModelDL7:GetValue("MASTER_DLE","DL7_FIMVIG")

	If oModelGrid:cid == "GRID_META"
		oModelDLG := oModelGrid:GetModel("GRID_META")
		cSeqMeta  := oModelDLG:GetValue("GRID_META","DLG_SEQ")
		dDtInMt   := oModelDLG:GetValue("GRID_META","DLG_DATINI")
		dDtFiMt   := oModelDLG:GetValue("GRID_META","DLG_DATFIM")
	Else	
		oModelDLG := oModelGrid:GetModel(oModelGrid:cid)
		cTipVei   := SUBSTR(oModelGrid:cid, 9, TamSX3("DUT_TIPVEI")[1])
		cSeqMeta  := oModelDLG:GetValue(oModelGrid:cid,"DLG_SEQ")
		dDtInMt   := oModelDLG:GetValue(oModelGrid:cid,"DLG_DATINI")
		dDtFiMt   := oModelDLG:GetValue(oModelGrid:cid,"DLG_DATFIM")
	EndIf
	
	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND. (cOpera == "CANSETVALUE" .Or. cOpera == "DELETE" .Or. cOpera == "SETVALUE")
		//DLOGTMS01-2553 - Não deve permitir a exclusão / Alteração de linha do grid, caso já exista consumo de meta para aquela linha (Demanda gerada).
		If !Vazio(cSeqMeta)
			aRet := TVldDelMet(DLE->DLE_CRTDMD, DLE->DLE_CODGRD, cTipVei, cSeqMeta)
			If !aRet[1] 
				FwClearHLP()
				If cOpera == "CANSETVALUE"
					MsgInfo(aRet[2])
				Else
					oModelDLG:SetErrorMessage('TMSA153D',,,,,aRet[2],'', nil, nil) //Não é possível excluir/alterar metas já consumidas.
				EndIf
			EndIf
			lRet := aRet[1]
		EndIf
		
		If lRet .And. cOpera == "SETVALUE"
			//DLOGTMS01-2553 - Não deve permitir informar data fora do período de vigência do contrato.
			//DLOGTMS01-2553 - Não permitir que a data final seja menor que a data inicial.
			FwClearHLP()
			If !Empty(M->DLG_DATINI) 
				IF M->DLG_DATINI < dDtInCt
					oModelDLG:SetErrorMessage('TMSA153D',,,,,STR0029,'', nil, nil) //A data inicial da meta não pode ser menor que a data inicial de vigência do contrato.
					lRet := .F.
				ElseIf !Empty(dDtFiMt) .And. M->DLG_DATINI > dDtFiMt
			 		oModelDLG:SetErrorMessage('TMSA153D',,,,,STR0028,'', nil, nil) //A data inicial da meta não pode ser superior a data final da meta.
			 		lRet := .F.
				EndIf
			ElseIf !Empty(M->DLG_DATFIM) 
				If M->DLG_DATFIM > dDtFiCt
					oModelDLG:SetErrorMessage('TMSA153D',,,,,STR0030,'', nil, nil) //A data final da meta não pode ser maior que a data final de vigência do contrato.
					lRet := .F.
				ElseIf !Empty(dDtInMt) .And. M->DLG_DATFIM < dDtInMt
			 		oModelDLG:SetErrorMessage('TMSA153D',,,,,STR0031,'', nil, nil) //A data final da meta não pode ser anterior a data inicial da meta.
			 		lRet := .F.
				EndIf			
			EndIf									
		EndIf
	EndIf	
	
Return lRet                    
      
//-------------------------------------------------------------------	
/*/{Protheus.doc} T153DLNPOS()
Realiza pós validação das linhas do Grid de Metas
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------
Static Function T153DLNPOS( oModelGrid)
Local lRet       := .T.
Local nOperation := oModelGrid:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	EndIf
	
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA153DVL
Realiza a pré validação ao ativar o model (clicar em incluir, alterar ou excluir) 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------
Static Function TMSA153DVL(oModel,nLine, cAction) 	
	Local aRet 			:= {.T., ''}	
	Local aRtLock 		:= {}
	Local nOperation	:= oModel:GetOperation()

	//--Realiza o LOCK do registro posicionado em tela - Filial + Contrato + Grupo Regiao
	aRtLock := TMLockDmd("TMSA153D_"+FwxFilial("DLE")+DLE->DLE_CRTDMD+DLE->DLE_CODGRD)
	//--aRet[1] - Retorno da função podendo ser .T. ou .F.
	If aRtLock[1]	
		If nOperation == MODEL_OPERATION_UPDATE 
			If DL7->DL7_META = '2'
				Help( ,, 'HELP',, STR0023, 1, 0 ) //Operação disponivel apenas para contrato que utiliza Meta Detalhada.
				aRet[1] := .F.
			EndIf
		EndIf
	
		If nOperation == MODEL_OPERATION_DELETE 
			aRet := TVldDelMet(DLE->DLE_CRTDMD, DLE->DLE_CODGRD)
			If !aRet[1] 
				Help( ,, 'HELP',, aRet[2], 1, 0 ) 
			EndIf
			
			If DL7->DL7_META = '2'
				Help( ,, 'HELP',, STR0023, 1, 0 ) //Operação disponivel apenas para contrato que utiliza Meta Detalhada.
				aRet[1] := .F.
			EndIf
		EndIf

		If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE 
			IF DL7->DL7_STATUS == '2'
				Help( ,, 'HELP',, STR0032, 1, 0 ) //"O contrato da meta está suspenso."
				aRet[1] := .F.
			ElseIf DL7->DL7_STATUS == '3'
				Help( ,, 'HELP',, STR0033, 1, 0 ) //"O contrato da meta está encerrado."
				aRet[1] := .F.
			EndIf
		EndIf
	Else
		aRet[1] := .F.
		//--Caso o Retorno da função de LOCK for .F. apresenta MSG do Retorno. 
		Help( ,, 'HELP',, aRtLock[2], 1, 0 )	//--Registro bloqueado pelo usuário XXXX.
	EndIf
	
Return aRet[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS153DPIC
Alterar a máscara do campo "Quantidade" das metas, de acordo com a Unidade de Medida do Contrato. 
@type function
@author Aluizio Fernando Habizenreuter
@version 12.1.17
@since 09/07/2018
/*/
//-------------------------------------------------------------------
Function TMS153DPIC()
Local cPic := ''
Local aAreaDL7
Local cUM  := ''

If !Empty(M->DL7_UM)
	cUM := M->DL7_UM
Else
	If !Empty(DLE->DLE_CRTDMD)
		aAreaDL7 := DL7->(GetArea())
		DL7->(dbSetOrder(1))
		If DL7->(MsSeek(xFilial('DL7')+DLE->DLE_CRTDMD))
			cUM := DL7->DL7_UM
		EndIf		
		RestArea(aAreaDL7)
	EndIf
EndIf

If cUM = '2'
	cPic := '@E 999,999,999'
Else
	cPic := '@E 999,999,999.9999'
EndIF

Return cPic


/*/{Protheus.doc} LoadSaldo
//Gatilhar campo de qtd para o saldo.
@author gustavo.baptista
@since 08/08/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
static function LoadSaldo(oModel)

	Local lRet := .T.

	oModel:LoadValue("DLG_SALDO",oModel:GetValue('DLG_QTD'))

return lRet