#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWADAPTEREAI.CH"
#Include "FINI024.CH"

/*/{Protheus.doc} FINI024
Mensagem unica de integração com RM x TOP para importação da linha saldo e base.
@param cXml Xml de importação
@param nType Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao
@author William Matos
@since 14/03/2014
@version P12
/*/
Function FINI024(cXml, nType, cTypeMessage)	
Local lRet		:= .T.
Local cXMLRet	:= ''
Local cErroXml	:= ''
Local cWarnXml	:= ''
Local cPathBalance:= '/TOTVSMessage/BusinessMessage/BusinessContent/ListOfBalanceBaselineEntry' 
Local cCaminho		:= "/ListOfApportionBalanceBaselineEntry"
Local cEvent		:= ''
Local aNatureza	:= {}
Local cMarca		:= ''
Local cClassi		:= ''
Local aFJ0			:= {}
Local aItensBal	:= {}
Local aCustos 		:= {}
Local aItensAppor := {}
Local aListBalance:= {}
Local aListAppor 	:= {}
Local aAuxCusto	:= {}
Local nQtBalance	:= 0  // Quantidade de lançamentos
Local nQtAppor  	:= 0  // Quantidade dos centro de custos por lançamento
Local nX			:= 1
Local nY			:= 0
Local nPos			:= 0
Local lCodif 		:= .F.
Local aMov			:= {}
Local oXML 		:= tXMLManager():New()
Local oModel 		:= FWLoadModel('FINI024')

dbSelectArea('FJ0')

Do Case
	//Apenas recebimento.
	Case  nType == TRANS_RECEIVE 
		If (cTypeMessage == EAI_MESSAGE_WHOIS )
			cXmlRet := '1.000'
		ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )
			
			If oXml:Parse( cXml)
						
				cEvent := oXml:XPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event')
				cMarca := oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				lCodif := oXml:bDecodeUtf8
			
				oModel:SetOperation(MODEL_OPERATION_INSERT)  	
				oModel:Activate()
				
				//Quantidade de filhos da ListOfBalanceBaselineEntry.
				nQtBalance := oXml:XPAthChildCount(cPathBalance)
				//--------------------------------------------										
				aListBalance := oXml:XPathGetChildArray(cPathBalance)
				
				While nX <= nQtBalance .AND. lRet
					
					aItensBal 	:= oXml:XPathGetChildArray(aListBalance[nX,2])  //Gera Array com os filhos.
					
					//Código do Movimento.
					nPos := aScan(aItensBal,{|x| AllTrim( x[1] )== 'InternalId' } ) 
					If nPos > 0
						aMov := Separa(aItensBal[nPos,3],'|')
						cCodMov := aMov[2]
						aAdd(aFJ0, {"FJ0_CODIGO", cCodMov})
					EndIf
									
					//Classificação.
					nPos := aScan(aItensBal,{|x| AllTrim( x[1] )== 'Classification' } )  
					If nPos > 0
						cClassi := aItensBal[nPos,3]
						aAdd(aFJ0, {"FJ0_CLASSI", aItensBal[nPos,3]})
					EndIf
					
					//Data do Vencimento.
					nPos := aScan(aItensBal,{|x| AllTrim( x[1] )== 'Date' } )
					If nPos > 0
						aAdd(aFJ0, {"FJ0_DATA", StoD(STRTRAN(aItensBal[nPos,3],'-',''))})
					EndIf
										 
					//Quantidade de filhos da ListOfApportionBalanceBaselineEntry.
					nQtAppor := oXml:XPAthChildCount(aListBalance[nX,2] + cCaminho) 
					//---------------------------------------------------------------------
					aListAppor := oXml:XPathGetChildArray(aListBalance[nX,2] + cCaminho)
					
					For nY := 1 To nQtAppor
					
						aItensAppor := oXml:XPathGetChildArray(aListAppor[nY,2])  //Gera array com os itens de centro de custo.
											
						//Código da natureza.
						nPos := aScan(aItensAppor,{|x| AllTrim( x[1] )== 'FinancialInternalId' } ) 
						If nPos > 0
							//Recebe um codigo, busca seu internalId e faz a quebra da chave para gravar o código interno do protheus.
							aNatureza := F10GetInt(aItensAppor[nPos,3], cMarca)
							If aNatureza[1]
								aAdd(aAuxCusto, {"FJ0_NATURE", SubStr(aNatureza[2][3],1,TamSx3("ED_CODIGO")[1])})
							EndIf					
					    EndIf
					    
					    //Código do centro de custo.
					    nPos := aScan(aItensAppor,{|x| AllTrim( x[1] )== 'CostCenterInternalId' } ) 
						If nPos > 0
							aCusto := IntCusInt( aItensAppor[nPos,3], cMarca)
							If aCusto[1]
								aAdd(aAuxCusto, {"FJ0_CCUSTO", SubStr(aCusto[2][3],1,TamSx3("CTT_CUSTO")[1])})
							EndIf
						EndIf	
										    
					    //Valor do lançamento.
					    nPos := aScan(aItensAppor,{|x| AllTrim( x[1] )== 'Value'}) 
						If nPos > 0
							aAdd(aAuxCusto, {"FJ0_VALOR", Val(aItensAppor[nPos,3])})
					    EndIf	    
					    				   					      
					    aAdd(aCustos, aClone(aAuxCusto))
					    
					    aSize(aNatureza, 0)
					    aSize(aItensAppor, 0)
					    aSize(aAuxCusto, 0)
					    aNatureza 	  := {}
					    aAuxCusto	  := {} 	
					    aItensAppor := {}
					    
					Next nY
					
					//Procura pelos registros na tabela FJ0 e exclui os dados.
					If Upper(cEvent) == 'DELETE'
					   		 				   		 
						 FJ0->(dbSetOrder(1))
						 If FJ0->(dbSeek( xFilial('FJ0') + PadR(cCodMov,TamSx3("FJ0_CODIGO")[1]))) 
							RecLock('FJ0', .F.)
							dbDelete()
							MsUnlock()
						 Else
							cXmlRet += STR0001 + cValToChar(cCodMov) + ' - '
							lRet := .F.	
						 EndIf	
				    EndIf
					
					//----------------------------------------------------------------------------
					
					aSize(aItensBal, 0)
					aItensBal := {}
					aSize(aMov,0)
					aMov := {}
					
					//Faz gravação dos dados na FJ0
					If Upper(cEvent) == 'UPSERT'
						FINGravaFJ0(aFJ0,aCustos,cCodMov,cClassi)				
						lRet := oModel:VldData()
					EndIf
				
					nX++
				EndDo	
		
			EndIf
			
			If Upper(cEvent) == 'UPSERT'
			
				lRet := oModel:VldData()
				If !lRet 
				
						cXmlRet :=  cValToChar(oModel:GetErrorMessage()[1]) + ' - ' + ;
						cValToChar(oModel:GetErrorMessage()[2]) +' - ' + ;
						cValToChar(oModel:GetErrorMessage()[3]) +' - '+ ;
						cValToChar(oModel:GetErrorMessage()[4]) +' - '+ ;
						cValToChar(oModel:GetErrorMessage()[5]) +' - '+ ;
						cValToChar(oModel:GetErrorMessage()[6]) + ' - ' + cValToChar(oModel:GetErrorMessage()[7])+ ' - ' + ;
						cValToChar(oModel:GetErrorMessage()[8]) +' - '+ ;
						cValToChar(oModel:GetErrorMessage()[9]) 
						
				Else		
					oModel:CommitData()
				EndIf
				//
				oModel:DeActivate()
			EndIf	
			//
			aSize(aListAppor, 0)
			aListAppor := Nil
			aSize(aListBalance, 0)
			aListBalance := Nil
		
		EndIf	
End Case	 	

oXML 	 := Nil
DelClassIntF()
cXmlRet := EncodeUTF8(cXmlRet)

Return {lRet,cXmlRet}

/*/{Protheus.doc}FINGravaFJ0
Função para gravação dos daddos na FJ0
@param aFJ0	 Array com os dados da FJ0.
@param aCustos Array com os dados dos centro de custos. ( Campo | Valor )
@param cEvent Tipo de operação. (upsert | delete) 
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Function FINGravaFJ0(aFJ0,aCustos,cCodMov,cClassi)
Local lRet 	:= .F.
Local nX,nY 	:= 0
Local oModel	:= FWModelActive()
Local oAuxFJ0	:= oModel:GetModel('FJ0DETAIL')
Local aAux 	:= {}
Default cClassi := ''
Default cCodMov := ''
Default aFJ0 	:= {}
Default aCustos := {}

dbSelectArea('FJ0')
dbSetOrder(1)

If Len(aFJ0) > 0
				
	oModel:SetValue('FJ0MASTER','FJ0_CAMPO', '1')
					
	For nX := 1 To Len(aCustos) 
				
		//Array auxiliar para alimentar FJ0.
		aAux := aCustos[nX]  
					
		If !oAuxFJ0:IsEmpty()
			oAuxFJ0:AddLine()
		EndIf 
		
		For nY := 1 To Len(aAux)
			oAuxFJ0:SetValue(aAux[nY,1], aAux[nY,2])
		Next nY
		
		//Gera um registro na FJ0 para cada centro de custo.
		For nY := 1 To Len(aFJ0)
			oAuxFJ0:SetValue(aFJ0[nY,1], aFJ0[nY,2]) 
		Next nY
															
	Next nX	
	
EndIf

aSize(aAux, 0)
aSize(aFJ0, 0)
aSize(aCustos,0)
aAux 	 := {}
aFJ0 	 := {}
aCustos := {}
oModel  := Nil

Return lRet 

/*/{Protheus.doc}ModelDef
Criação do Modelo de dados da FJ0
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Static Function ModelDef()
Local oModel :=  MPFormModel():New('FINI024')
Local nX := 0
Local oCab		:= FWFormModelStruct():New()
Local oStruFJ0:= FWFormStruct(1,'FJ0')

//Criado falso field, para alimentar a FJ0 de uma unica vez pelo Detail
oCab:AddTable('FJ0',,'FJ0')
oCab:AddField("Id","","FJ0_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)
//
oModel:AddFields('FJ0MASTER', /*cOwner*/, oCab , , ,{|o|{}} )
oModel:AddGrid('FJ0DETAIL','FJ0MASTER',oStruFJ0)
oModel:GetModel('FJ0MASTER' ):SetPrimaryKey( {} )
oModel:SetDescription('Integração TOP')                          
oModel:GetModel('FJ0MASTER'):SetDescription(STR0002) //Integração top 
oModel:GetModel('FJ0DETAIL'):SetDescription(STR0002) 

Return oModel
