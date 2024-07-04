#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'OMSI010.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMSI010O   ºAutor  ³Totvs Cascavel     º Data ³  14/06/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações das Tabelas de precos 		          º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.        	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OMSI010O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMSI010O( oEAIObEt, nTypeTrans, cTypeMessage )
	
	Local aArea			:= GetArea()		//Salva contexto do alias atual
	Local aAreaDA0		:= DA0->(GetArea())	//Salva contexto do alias DA0
	Local aHeader		:= {}				//Dados da Master
	Local aItens		:= {}				//Dados da Detail
	Local aJsonItens	:= {}
	Local aMsgErro		:= {}				//Mensagem de erro na gravação do Model	
	Local aRet			:= {.T.,""} 		//Array de retorno da execucao da versao
	Local aSaveLine		:= FWSaveRows()		//Salva contexto do model ativo		
	Local cCodTab		:= ""				//Codigo da tabela de preços
	Local cEvent		:= "upsert"			//Operação realizada na master e na detail ( upsert ou delete )
	Local cEvntItem		:= ""
	Local cDataAte		:= ""				//Data final da tabela de preços
	Local cDataDe		:= ""				//Data inicial da tabela de preços	
	Local cDataVig		:= ""				//Data de vigência do item na tabela de preços	
	Local cEntity		:= "PriceListHeaderItem"
	Local cFilDA0		:= xFilial('DA0')	// Filial Header
	Local cFilDA1		:= xFilial('DA1')	// filial Itens
	Local cLogErro		:= ""				//Log de erro da execução da rotina
	Local cMarca		:= ""				//Indica a marca integrada	
	Local cMaxItem		:= StrZero( 0, TamSx3('DA1_ITEM')[1] )
	Local cTabPrcItm	:= ""				//item da tabela de preço
	Local lCargaIni		:= .F.				//Controla chamada de carga inicial
	Local lFound		:= .F.				//Indica se encontrou o registro
	Local lNewItem		:= .T.				//Indica se é a primeira linha de DA1 nova durante alteração
	Local lRet 			:= .T.				//Indica o resultado da execução da função
	Local lTippre		:= DA1->(ColumnPos("DA1_TIPPRE") > 0)	
	Local nContReg		:= 0
	Local nControl		:= 0				//Contador	
	Local nErrSize		:= 0				//Len do array de erros
	Local nLen			:= 0				//Quantidade de itens da Tabela de Preço
	Local nLength		:= 0				//Grid de Itens
	Local nI			:= 0				//Contador de uso geral
	Local nOpcx 		:= 3				//Tipo de operação	
	Local nR 			:= 0				//Contador erro
	Local nTamCodPro	:= DA1->(TamSx3("DA1_CODPRO")[1])
	Local nTamCodTab	:= DA0->(TamSx3("DA0_CODTAB")[1])
	Local nX			:= 0				//Contador de uso geral	
	Local oFwEAIObj		:= FwEAIObj():New()	
	Local oHashJSON		:= Nil 				//Hash com a carga dos itens usado durante a Alteração para determinar se o item é novo
	Local oModel 		:= Nil 				//Objeto com o model da tabela de preços
	Local oModelDA0		:= Nil				//Objeto com o model da master apenas
	Local oModelDA1		:= Nil				//Objeto com o model da detail apenas
	Local oIteTbPri		:= Nil

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	
	Default cTypeMessage 	:= ""
	Default nTypeTrans 		:= 0
	
	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	If ( nTypeTrans == TRANS_RECEIVE ) .And. ValType( oEAIObEt ) == 'O' 
	
		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
		
			//Guarda o código da tabela recebido na mensagem.
			//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
			If oEAIObEt:getPropValue("Code") != nil 
				cCodTab := PadR( AllTRim(oEAIObEt:getPropValue("Code")), nTamCodTab)
			EndIf		
			
			//Posiciona tabela DA0
			DbSelectArea('DA0')
			DA0->( dbSetOrder(1) )	//Filial + Codigo da Tabela | DB0_FILIAL + DB0_CODTAB
			lFound := DA0->( MSSeek( cFilDA0 + cCodTab ) )
					
			//Verifica a operação realizada
			If ( Upper( AllTrim( oEAIObEt:getEvent() ) ) == 'UPSERT' ) .Or. ( Upper( AllTrim( oEAIObEt:getEvent() ) ) == 'REQUEST' ) 
				
				If ( lFound )
					nOpcx := 4
					
					//Em caso de alteração, grava os itens já gravados para uso posterior
					oModel 		:= FwLoadModel( 'OMSA010')
					oModelDA1 	:= oModel:GetModel('DA1DETAIL')
					oModel:Activate()
					nLength 	:= oModelDA1:Length()
					oModelDA1:SeekLine( {{'DA1_CODTAB', cCodTab}} )
					
					//Hash com a lista de itens da DA1 que já existem na base
					oHashJSON := THashMap():New() 
	
					For nI := 1 To nLength
						oModelDA1:GoLine(nI)
						oHashJSON:Set( Alltrim(oModelDA1:GetValue('DA1_CODPRO')) + DtoC(oModelDA1:GetValue('DA1_DATVIG') ), { oModelDA1:GetValue('DA1_ITEM') }  )
						If nI == nLength
							cMaxItem := oModelDA1:GetValue('DA1_ITEM')
						EndIf
						
					Next nI
				EndIf
				
			Else
				//Exclusão
				If ( !lFound )
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := EncodeUTF8(STR0001)	//'Registro não encontrado!'
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																
				Else
					nOpcx := 5
				EndIf
			EndIf
			
			If lRet 
				//Monta array com dados da tabela Master
				aAdd( aHeader, {'DA0_CODTAB', cCodTab, Nil } )	
				If oEAIObEt:getPropValue("Name") != nil		
					aAdd( aHeader, {'DA0_DESCRI', oEAIObEt:getPropValue("Name"), Nil } )	
				Endif		
				
				If oEAIObEt:getPropValue("InitialDate") != nil
					aAdd( aHeader, {'DA0_DATDE', CToD( oEAIObEt:getPropValue("InitialDate") ), Nil } )	
				Endif	
					
				If oEAIObEt:getPropValue("FinalDate") != nil 
					aAdd( aHeader, {'DA0_DATATE', CToD( oEAIObEt:getPropValue("FinalDate") ), Nil } )	
				Endif	
				
				If oEAIObEt:getPropValue("InitialHour") != nil	
					aAdd( aHeader, {'DA0_HORADE', SubStr( oEAIObEt:getPropValue("InitialHour"), 1, 5 ), Nil } )	
				Endif
				
				If oEAIObEt:getPropValue("FinalHour") != nil 
					aAdd( aHeader, {'DA0_HORATE', SubStr( oEAIObEt:getPropValue("FinalHour"), 1, 5 ), Nil } )
				Endif
				
				If oEAIObEt:getPropValue("ActiveTablePrice") != nil  
					aAdd( aHeader, {'DA0_ATIVO',  oEAIObEt:getPropValue("ActiveTablePrice"), Nil } )
				EndIf
				
				If oEAIObEt:getPropValue("ItensTablePrice") != nil  .AND. oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item") <> NIL
				
					oIteTbPri := oEAIObEt:getPropValue("ItensTablePrice"):getPropValue("Item")
					nLen := Len( oIteTbPri )
					
				Endif
				 

				aItens 	:= {}
				
				//Monta array com dados da tabela detail
				For nI := 1 To nLen
					aAdd( aItens, {} )	
					
					aAdd( aItens[nI], { 'DA1_FILIAL', cFilDA1 , Nil } )
					
					aAdd( aItens[nI], { 'DA1_CODPRO', PadR(AllTRim(oIteTbPri[nI]:getPropValue("ItemCode")), nTamCodPro), Nil } )
					aAdd( aItens[nI], { 'DA1_PRCVEN', oIteTbPri[nI]:getPropValue("MinimumSalesPrice"), Nil  } )
					aAdd( aItens[nI], { 'DA1_VLRDES', oIteTbPri[nI]:getPropValue("DiscountValue"), Nil} )
					aAdd( aItens[nI], { 'DA1_PERDES', oIteTbPri[nI]:getPropValue("DiscountFactor"), Nil } )
					aAdd( aItens[nI], { 'DA1_DATVIG', CToD( oIteTbPri[nI]:getPropValue("ItemValidity") ), Nil } )

					If nOpcx == 4 .And. oHashJSON:Get( Alltrim(aItens[nI][2][2])  + DtoC(aItens[nI][6][2]), @aJsonItens )					
						aAdd( aItens[nI], { 'LINPOS','DA1_ITEM', aJsonItens[1] } )
					
					ElseIf nOpcx <> 5
						If lNewItem
							cTabPrcItm := Soma1( cMaxItem )
							lNewItem := .F.
						Else
							cTabPrcItm := Soma1(cTabPrcItm)
						EndIf
	
						aAdd( aItens[nI], { 'DA1_ITEM', cTabPrcItm, Nil } )
					EndIf
				
					If oIteTbPri[nI]:getPropValue("ActiveItemPrice") != nil 
						aAdd( aItens[nI], { 'DA1_ATIVO', oIteTbPri[nI]:getPropValue("ActiveItemPrice"), Nil } )  
					EndIf   
					
					If nOpcx <> 5 .And. oIteTbPri[nI]:getPropValue("Event") != NIL .AND. Upper(AllTrim(oIteTbPri[nI]:getPropValue("Event"))) == 'DELETE'
						aAdd( aItens[nI], { 'AUTDELETA', 'S', Nil } )
					EndIf					
	
				Next nI
	
				If nOpcx == 4
					oModel:DeActivate()
					oModel:Destroy()
					oHashJSON:Clean()
				EndIf
				
				//Atualiza model com dados recebidos 
				MSExecAuto({|x, y, z| OMSA010(x, y, z)}, aHeader, aItens, nOpcx)
				
				If lMsErroAuto
					aMsgErro := GetAutoGRLog()
					nErrSize := Len(aMsgErro)
					lRet := .F.
					
					cLogErro := ""
					For nR := 1 To nErrSize
						cLogErro += aMsgErro[nR]  
					Next nCount
	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
				  	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
					
					//Monta de Erro de execução da rotina automatica.
					DisarmTransaction()
					MsUnlockAll()
				
				Else
					Return {lRet, STR0008, cEntity} //'operação realizado com sucesso!'
				EndIf
			EndIf		
			
		//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------	
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )
		
			If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )   
				cMarca := oEAIObEt:getHeaderValue("ProductName")
			Endif
			
			// Identifica se o processamento pelo parceiro ocorreu com sucesso.
			If 	Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) != nil .And. ;
				Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"
				
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID") !=  nil 
					oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")
					If oObLisOfIt[1]:getPropValue('Origin') != nil .And. oObLisOfIt[1]:getPropValue('Destination') != nil .And. oObLisOfIt[1]:getPropValue('Name') != nil
						If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT"
							CFGA070Mnt( cMarca, 'DA0', 'DA0_CODTAB', oObLisOfIt[1]:getPropValue('Destination'), oObLisOfIt[1]:getPropValue('Origin'), .F. )	
						Elseif Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "DELETE"
							CFGA070Mnt( cMarca, 'DA0', 'DA0_CODTAB', oObLisOfIt[1]:getPropValue('Destination'), oObLisOfIt[1]:getPropValue('Origin'), .T. )
						Endif				
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0003 //"De-Para não pode ser gravado a integração poderá ter falhas"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																
					Endif
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0003 //"De-Para não pode ser gravado a integração poderá ter falhas"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
															
				Endif
		
			Else
				lRet    := .F.
				If Empty( cLogErro )
					cLogErro := STR0004 + CRLF //"Processamento pela outra aplicação não teve sucesso"
					
					If oEAIObEt:getpropvalue('ProcessingInformation') != nil
						If ( oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("Details") ) != Nil
							For nX := 1 To Len( oMsgError )
								If oMsgError[nX]:getpropvalue('DetailedMessage') != Nil
									cLogErro += oMsgError[nX]:getpropvalue('DetailedMessage') + CRLF
								EndIf
							Next nX
						EndIf
					Endif
		
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)		
				Endif		
			EndIf
		EndIf
	
	//--------------------------------------
	//envio mensagem
	//--------------------------------------          
	ElseIf ( nTypeTrans == TRANS_SEND )
	
		oModel 	:= FWModelActive()						//Instancia objeto com o model completo da tabela de preços
		oModelDA0	:= oModel:GetModel( 'DA0MASTER' )	//Instancia objeto com model da master apenas
		oModelDA1	:= oModel:GetModel( 'DA1DETAIL' )	//Instancia objeto com model da detail apenas
	
		//Verifica se a tabela está sendo excluída
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf
		
		//Carrega os campos data, deixando em branco se não tiverem sido preenchidos
		cDataDe	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATDE') ), cValToChar( oModelDA0:GetValue('DA0_DATDE') ), '' )
		cDataAte	:= IIf( !Empty( oModelDA0:GetValue('DA0_DATATE') ), cValToChar( oModelDA0:GetValue('DA0_DATATE') ), '' )

		lCargaIni := ( IsInCallStack( 'OMSM010' ) .Or. IsInCallStack( 'CFG020ASINC' ) .Or. IsInCallStack( 'OMS010CPY' ) )
		
		//Montagem da mensagem
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)
		

		ofwEAIObj:SetProp("CompanyID"	,cEmpAnt)
		ofwEAIObj:SetProp("BranchId"         	,cFilAnt)
		ofwEAIObj:SetProp("CompanyInternalID"	,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setprop("InternalId", cEmpAnt + "|" + RTrim(xFilial("DA0")) + "|" + oModelDA0:GetValue('DA0_CODTAB') )
		ofwEAIObj:setprop("Code", oModelDA0:GetValue('DA0_CODTAB') )
		ofwEAIObj:setprop("Name", oModelDA0:GetValue('DA0_DESCRI') )
		ofwEAIObj:setprop("InitialDate", cDataDe )
		ofwEAIObj:setprop("FinalDate", cDataAte )
		ofwEAIObj:setprop("InitialHour", oModelDA0:GetValue('DA0_HORADE') + ':00' )
		ofwEAIObj:setprop("FinalHour", oModelDA0:GetValue('DA0_HORATE') + ':00' )
		ofwEAIObj:setprop("ActiveTablePrice", oModelDA0:GetValue('DA0_ATIVO') )	
		
		ofwEAIObj:setprop("ItensTablePrice")
		
		//Monta os itens da tabela de preços (DA1)
		For nI := 1 To oModelDA1:Length()
		
			nControl += 1
			oModelDA1:GoLine(nI)
			
			//Carrega o campo data, deixando em branco se não tiver sido preenchido
			cDataVig := IIf( !Empty( oModelDA1:GetValue('DA1_DATVIG') ), cValToChar( oModelDA1:GetValue('DA1_DATVIG') ), '' )
			
			//Somente adiciona o item na mensagem se ele sofreu alguma modificação
			//Se o item foi inserido e deletado não envia
			//No caso de exclusão da tabela de preços, os itens não serão enviados, pois não sofreram alterações
			//Se a rotina foi acionada pela carga inicial envia tudo
			If 	( oModelDA1:IsDeleted() .And. !oModelDA1:IsInserted() ) .Or.;
				( oModelDA1:IsUpdated() .And. !oModelDA1:IsDeleted() ) .Or.	lCargaIni
				
				ofwEAIObj:getPropValue("ItensTablePrice"):setProp("Item",{})
				nContReg := Len( ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item") )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ItemCode", oModelDA1:GetValue('DA1_CODPRO')	)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ItemInternalId", cEmpAnt + "|" + RTrim(xFilial("SB1")) + "|" + oModelDA1:GetValue('DA1_CODPRO')	)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("MinimumSalesPrice", oModelDA1:GetValue('DA1_PRCVEN') )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("DiscountValue", oModelDA1:GetValue('DA1_VLRDES') )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("DiscountFactor", oModelDA1:GetValue('DA1_PERDES') )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ItemValidity", cDataVig )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("ActiveItemPrice", oModelDA1:GetValue('DA1_ATIVO ') )
				
				If lTippre
					ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("TypePrice", cValToChar( oModelDA1:GetValue('DA1_TIPPRE') ) )
				EndIf
	
				//Define a operação no item
				If ( oModelDA1:IsDeleted() )
					cEvntItem := 'delete' 	
				Else
					cEvntItem := 'upsert'
				EndIf	
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nContReg]:setProp("Event", cEvntItem )		
				
			EndIf
			
		Next nI
		
		IIF( ( nControl > oModelDA1:Length() ), nControl := -1, )

		
	EndIf
	
	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aAreaDA0)
	RestArea(aArea)

	aSize(aArea,0)
	aArea	:= {}
	
	aSize(aAreaDA0,0)
	aAreaDA0	:= {}
	
	aSize(aSaveLine,0)
	aSaveLine := {}
	
	aSize(aHeader,0)
	aHeader	:= {}
	
	aSize(aItens,0)
	aItens	:= {}
	
	aSize(aMsgErro,0)
	aMsgErro	:= {}	
	
	aSize(aRet,0)
	aMsgErro	:= {}	

Return {lRet, ofwEAIObj, cEntity}
