#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRM980EVENTDEFLOJ.CH"                                                                                                                                                                                                                                             

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFLOJ
Classe responsável pelo evento das regras de negócio do 
Controle de Lojas.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFLOJ From FwModelEvent 
		
	Method New() CONSTRUCTOR
	
	//----------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//----------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de negócio depois transação do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
		
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFLOJ
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio do Controle de Lojas 
dentro da transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFLOJ

	Local lAmbOffLn	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline	
	Local lIntPOS 	:= ( SuperGetMV("MV_LJSYNT",,"0") == "1" )	//Integracao POS - Synthesis
	Local lCentPDV	:= LjGetCPDV()[1]									//É Central de PDV  - CENTRAL TOTVSPDV 
	Local nOperation	:= oModel:GetOperation()                                                        
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
		//------------------------------------------------------
		// Insere o registro na integração.
		//------------------------------------------------------	

		oModel:Activate() //recupera o último modelo ativo CRMA980

		If lAmbOffLn
			Ma030AltOk()
		Else
			Ma30IntFim(.F., nOperation)
			MA030OK(nOperation)	
		Endif
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT		
		
			
		//------------------------------------------------------
		// Gravacao no Log de Alteracoes do Front Loja.
		//------------------------------------------------------	
		FRTGeraSLH("SA1", "I")	

	ElseIf nOperation == MODEL_OPERATION_UPDATE		
		
		//------------------------------------------------------
		// Gravacao no Log de Alteracoes do Front Loja.
		//------------------------------------------------------	
		FRTGeraSLH("SA1", "A")	
		
		If ( nModulo == 12 .Or. nModulo == 72 ) 
			SAE->( DBSetOrder(2) )
			//--------------------------------------------------------------------
			// Se for SigaLoja e for um registro criado automaticamente a partir 
			// do cadastro de Adm.Cartões, deve atualizar o SAE.  
			//--------------------------------------------------------------------	
			If SAE->( DBSeek(xFilial("SAE")+SA1->A1_COD) )
				If SA1->A1_NOME <> SAE->AE_DESC
					RecLock("SAE", .F.)
					SAE->AE_DESC := SA1->A1_NOME
					SAE->( MsUnlock() )
				EndIf
			EndIf
		EndIf
				
		//------------------------------------------------------
		// Integracao com o POS - Synthesis.
		//------------------------------------------------------	
		If ( lIntPOS .And. SA1->A1_POSFLAG == "1" )
			RecLock("SA1",.F.)
			SA1->A1_POSDTEX := cTod("")
			SA1->( MsUnLock() )
		EndIf
		
		//------------------------------------------------------
		// Integracao Central PDV x Retaguarda.
		//------------------------------------------------------	
		If ( lCentPDV .And. nModulo == 12 )
			RecLock("SA1",.F.)
			SA1->A1_SITUA := "00"
			SA1->( MsUnLock() )
		EndIf
	
	ElseIf nOperation == MODEL_OPERATION_DELETE	
		
		//------------------------------------------------------
		// Processa a integração com Cliente.
		//------------------------------------------------------	
		Ma030Int(.F., MODEL_OPERATION_DELETE )  
		
		//------------------------------------------------------
		// Gravacao no Log de Alteracoes do Front Loja.
		//------------------------------------------------------	
		FRTGeraSLH("SA1", "D")	
		
		//----------------------------------------------------------------------
		// Se for SigaLoja e for um registro criado automaticamente a partir
		// do cadastro de Adm.Cartões, deve ser deletado do SAE.   
		//----------------------------------------------------------------------	
		If nModulo == 12 .Or. nModulo == 72 // SIGALOJA //SIGAPHOTO
			SAE->( DBSetOrder(2) )
			If SAE->( DBSeek( xFilial("SAE")+SA1->A1_COD) )	
				RecLock("SAE", .F.)
				SAE->( DBDelete() )
				SAE->( MsUnlock() )
			EndIf
		EndIf
		
		//------------------------------------------------------
		// Insere o registro na integração.
		//------------------------------------------------------	
		If lAmbOffLn
			Ma030AltOk()
		Endif
		
		//------------------------------------------------------
		// Finaliza o processamento da integração com Cliente.
		//------------------------------------------------------	
		Ma30IntFim(.F., MODEL_OPERATION_DELETE	)

	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método responsável por executar regras de negócio do Controle de Lojas
depois da transação do modelo de dados.


@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel,cID) Class CRM980EventDEFLOJ

	Local lCentPDV	:= LjGetCPDV()[1]									//É Central de PDV  - CENTRAL TOTVSPDV    
	Local lSendCli	:= .F. 											//Informa se o cliente foi gravado com sucesso na retaguarda quando se utiliza central de PDV - TOTVSPDV
	Local nSendOn	 	:= SuperGetMV("MV_LJSENDO",,0) 					//Retorno como sera a integracao do cliente para retaguarda - 0 - via job - 1 online - 2 startjob - CENTRAL TOTVSPDV 													 	
	Local nX 		 	:= 0
	Local nCampos    	:= 0
	Local aSA1       	:= {}
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT		

		//----------------------------------------------------------------------------------------
		// Tratamento para envio online do cliente para retaguarda quando utiliza central de PDV
		//----------------------------------------------------------------------------------------
		If ( lCentPDV .And. ( nSendOn == 1 .OR. nSendOn == 2 ) )
		
			nCampos := SA1->( FCount() )
			
			For nX := 1 To nCampos   		
				If AllTrim( SA1->( FieldName( nX ) ) ) == "A1_SITUA"
					AAdd( aSA1 , { SA1->( FieldName( nX ) ), " " } )
				Else
					AAdd( aSA1 , { SA1->( FieldName( nX ) ), SA1->( FieldGet( nX ) ) } )
				EndIf 
			Next nX   
		
			If Len(aSA1) > 0
				//--------------------------------------
				// Transmite o cliente para retaguarda
				//--------------------------------------
				If nSendOn == 1            	
					FWMsgRun(/*oComponent*/,{|| STDSendCli(aSA1,@lSendCli )},,STR0001) //"Transmitindo Cliente..."
				ElseIf nSendOn == 2
					StartJob("STDSendCli", GetEnvServer(), .F., aSA1,@lSendCli,.T.,cEmpAnt,cFilAnt)
				EndIf
			EndIf
		
		EndIf

	EndIf
		
Return Nil
