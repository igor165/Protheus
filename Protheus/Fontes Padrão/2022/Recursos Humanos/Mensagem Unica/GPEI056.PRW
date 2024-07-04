#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEI056.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIntegDef   บAutor  ณMicrosiga           บ Data ณ  18/02/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de integracao com o adapter EAI para recebimento e   บฑฑ
ฑฑบ          ณ envio de informacoes da programacao de rateios              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA370                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GPEI056(cXML, nTypeTrans, cTypeMessage)

Local lRet     	:= .T.
Local cXMLRet  	:= ""  
Local oMdl056	:= Nil
Local oXmlBus	:= Nil
Local cXmlErro	:= ""
Local cXmlWarn	:= ""	
Local cEvento	:= "upsert"
Local cValExt	:= ""
Local cValInt 	:= ""
Local cValFunc 	:= ""
Local cValFuncExt := ""
Local lEmployee := .F.

Local cAux   	:= ""
Local nLinhas 	:= 0

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_BUSINESS  

		Inclui := .F.
		Altera := .F.
	
		oXmlFunc := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
	      
	    If oXmlFunc <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
	    
	    	cMarca := oXmlFunc:_TotvsMessage:_MessageInformation:_Product:_Name:Text
	    
	    	oMdl056		:= FwLoadModel("GPEA056")
	    	oXmlBus 	:= oXMlFunc:_TotvsMessage:_BusinessMessage
        
        	If XmlChildEx(oXmlBus, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBus:_BusinessEvent, '_EVENT' ) <> Nil
				
				cEvento := oXmlBus:_BusinessEvent:_Event:Text

				DbSelectArea("RHQ")
				RHQ->( DbSetOrder( 1 ) ) //RHQ_FILIAL+RHQ_MAT+RHQ_DEMES+RHQ_CC+RHQ_ITEM+RHQ_CLVL+RHQ_ORIGEM
				
				DbSelectArea("SRA")
				SRA->( DbSetOrder( 1 ) ) //RA_FILIAL+RA_MAT

				//-----------------------------------------------------
				//  Verifica a exist๊ncia das tags 
				// 	 < BusinessContent/InternalId > ou < Identification/Key >
				// pra saber como gravar o de/para e identificar se hแ 
				// programa็ใo de rateio cadastrada para o funcionแrio
				If XmlChildEx(oXmlBus:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
					 XmlChildEx(oXmlBus:_BusinessEvent:_Identification, '_KEY') <> Nil .And. ;
					 !Empty( oXmlBus:_BusinessEvent:_Identification:_Key:Text )
				
					cValExt	:= oXmlBus:_BusinessEvent:_Identification:_Key:Text
					
					cValInt := GPEI056Rcv( CFGA070INT( cMarca, "RHQ", "RHQ_MAT", cValExt ), { "RHQ_FILIAL", "RHQ_MAT" } )
					
				ElseIf Empty( cValExt ) .And. XmlChildEx( oXmlBus, "_BUSINESSCONTENT" ) <> Nil .And. ;
					XmlChildEx( oXmlBus:_BusinessContent, "_INTERNALID" ) <> Nil .And. ;
					!Empty( oXmlBus:_BusinessContent:_InternalId:Text )
					
					cValExt	:= oXmlBus:_BusinessContent:_InternalId:Text
					
					cValInt := GPEI056Rcv( CFGA070INT( cMarca, "RHQ", "RHQ_MAT", cValExt ), { "RHQ_FILIAL", "RHQ_MAT" } )

				Else 
					lRet := .F.
					cXmlRet := STR0001 // "Nใo foi enviada chave para grava็ใo de de-para"
				EndIf

				If lRet .And. XmlChildEx( oXmlBus:_BusinessContent, "_EMPLOYEECODE" ) <> Nil .And. ;
					!Empty( oXmlBus:_BusinessContent:_EmployeeCode:Text )
				
					lEmployee 	:= .T.
					cValFuncExt 	:= oXmlBus:_BusinessContent:_EmployeeCode:Text
					
					cAux := IntFunInt( cValFuncExt, cMarca, "2.003")
					
					If cAux[1]
						cValFunc := cAux[2][2]+cAux[2][3]
				    Else
				    	lRet := .F.
				    	cXmlRet += STR0002 + " | " // "C๓digo do funcionแrio nใo identificado "
					EndIf
				EndIf
				
				If lRet
				                        
				    If Upper(cEvento) == "UPSERT" .And. lEmployee

						//---------------------------------------------
						// Posiciona no funcionแrio para entrar como altera็ใo
						If lEmployee .And. SRA->( DbSeek( cValFunc ) )
							
					    	Altera	:= .T.
					    	oMdl056:SetOperation( MODEL_OPERATION_UPDATE)
					    	lRet := oMdl056:Activate()
					    EndIf
			    
				    ElseIf lRet .And. !Empty(cValInt) .And. Upper(cEvento) == "UPSERT" .And. ;
				    	 RHQ->( DbSeek( cValInt ) ) .And. SRA->( DbSeek( xFilial("SRA")+ RHQ->RHQ_MAT ) ) 
				    	
				    	Altera	:= .T.
				    	oMdl056:SetOperation( MODEL_OPERATION_UPDATE)
				    	lRet := oMdl056:Activate()
				    
				    ElseIf lRet .And. !Empty(cValInt) .And. Upper(cEvento) == "DELETE" .And. ;
				    	 RHQ->( DbSeek( cValInt ) ) .And. SRA->( DbSeek( xFilial("SRA")+ RHQ->RHQ_MAT ) )
				    	
				    	oMdl056:SetOperation( MODEL_OPERATION_DELETE)
				    	lRet := oMdl056:Activate()
				    
				    ElseIf lRet .And. lEmployee .And. SRA->( DbSeek( cValInt ) )
				    
				    	oMdl056:SetOperation( MODEL_OPERATION_DELETE)
				    	lRet := oMdl056:Activate()
				    
				    Else
				    	lRet := .F.
				    	cXMLRet += STR0003 + " | " // "Combina็ใo de opera็ใo e chave do registro estใo invแlidos"
				    EndIf
				    
				    If lRet
				    
				    	PEI056( @lRet, @cXmlRet, @oMdl056, oXmlBus, cMarca, cValExt )
				    ElseIf Empty( cXmlRet )
				    
				    	cXmlRet += ApErroMvc( oMdl056 )
				    EndIf
    				
    				oMdl056:DeActivate()
    				
				Else
					lRet := .F.
					cXMLRet += STR0004 // 'Chave do registro nใo enviada, ้ necessแria para cadastrar o de-para'
				EndIf
    				
    		Else
	        	lRet := .F.
	        	cXMLRet := STR0005 // 'Tag de opera็ใo "Event" inexistente'
	        EndIf
	        
        Else
        	lRet := .F.
        	cXMLRet	:= STR0006 + cXmlErro + "|" + cXmlWarn // "Xml mal formatado"
        EndIf
    
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//------------------------------------------------
		//  Trata a resposta ao envio da mensagem
		TrataResp( @lRet, @cXmlRet, cXml )
		 
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	EndIf

ElseIf nTypeTrans == TRANS_SEND

	oMdl056 := FwModelActive()
	
	If Upper( oMdl056:GetId() ) == "GPEA056"
		
		cAux := oMdl056:GetModel("SRAMASTER"):GetValue( "RA_MAT")
		cValInt := GPEI056Snd( { cEmpAnt, xFilial("RHQ"), cAux } )
		
	    If !Inclui .And. !Altera
	       cEvento := "delete"
	       
	       //---------------------------------------------
	       // remover De/Para
	       CFGA070Mnt(    Nil, 'RHQ', 'RHQ_MAT',  Nil, cValInt, .T. )	// remove do de/para
	    EndIf
	
		cXMLRet += '<BusinessEvent>'
		cXMLRet +=     '<Entity>ProrationProgramming</Entity>'
	    cXMLRet += '<Event>'+ cEvento + '</Event>'
		cXMLRet +=  	'<Identification>'
		cXMLRet += 			'<key name="Code">' + cValInt + '</key>'
		cXMLRet += 		'</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += 	'<CompanyId>'+ cEmpAnt +'</CompanyId>'
		//cXMLRet += 	'<BranchId>'+ xFilial('RHQ') +'</BranchId>'
		cXMLRet += 	'<BranchId>'+ cFilAnt +'</BranchId>'
		cXMLRet += 	'<EmployeeCode>'+ IntFunExt( , , cAux, "2.003" )[2] +'</EmployeeCode>'
		cXMLRet += 	'<InternalId>' + cValInt + '</InternalId>'
		cXMLRet +=	'<ListOfProgramming>'
	
		aSave := FwSaveRows( oMdl056 )

		For nLinhas := 1 To oMdl056:GetModel( "RHQDETAIL" ):Length()
		
			oMdl056:GetModel( "RHQDETAIL" ):GoLine( nLinhas )
			
			If !oMdl056:GetModel( "RHQDETAIL" ):IsDeleted()
				cXMLRet +=	'<Proration>'
				
					cAux := CTOD( Transform( "01"+ oMdl056:GetModel("RHQDETAIL"):GetValue( "RHQ_DEMES"), "@R 99/99/9999" ) )
					cAux := Transform( DTOS( cAux ), "@R 9999-99-99" )
				cXMLRet +=		'<FromMonthYear>'+ cAux +'</FromMonthYear>'
				
				If !Empty( oMdl056:GetModel("RHQDETAIL"):GetValue( "RHQ_AMES") )
						cAux := CTOD( Transform( "01"+ oMdl056:GetModel("RHQDETAIL"):GetValue( "RHQ_AMES"), "@R 99/99/9999" ) )
						cAux := Transform( DTOS( cAux ), "@R 9999-99-99" )
					cXMLRet +=		 '<ToMonthYear>'+ cAux +'</ToMonthYear>'
				EndIf

					cAux := oMdl056:GetModel("RHQDETAIL"):GetValue( "RHQ_CC")
				cXMLRet +=		 '<CostCenter>'+ cAux +'</CostCenter>'
				cXMLRet +=		 '<CostCenterInternalId>' + IntCusExt( , xFilial("CTT"), cAux, '2.000')[2] + '</CostCenterInternalId>'
					
					cAux := oMdl056:GetModel("RHQDETAIL"):GetValue( "RHQ_PERC")
					If cAux==99.99999999
						cAux := "100"
					Else
						cAux := cValToChar( cAux )
					EndIf
				cXMLRet +=		 '<ProrationPercentage>'+ cAux +'</ProrationPercentage>'
				cXMLRet +=	'</Proration>'
	    	EndIf
	    
	    Next nLinhas
	    
	    FwRestRows( aSave )
	    
		cXMLRet += 	'</ListOfProgramming>'
		cXMLRet +=	'</BusinessContent>'
	EndIf

EndIf  

cXmlRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณIntegDef  บAutor  ณ 					   บ Data ณ  18/02/13         	     บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem Unica											          	     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGPEA370		                                            	      	     บฑฑ 
ฑฑบ		     ณ@params	lStatus    - indica็ใo do status do processamento 	      	     บฑฑ
ฑฑบ		     ณ@params	cXmlStatus - conte๚do de retorno					      	     บฑฑ
ฑฑบ		     ณ@params	oMdlOper   - modelo de dados para rotina automแtica      	     บฑฑ
ฑฑบ		     ณ@params	oXmlOper   - conte๚do para processamento      	     			 บฑฑ
ฑฑบ		     ณ@params	cMarca     - sistema com o qual a integra็ใo estแ sendo realizadaบฑฑ
ฑฑบ		     ณ@params	cValExtern - chave do registro na aplica็ใo de origem da mensagemบฑฑ
ฑฑบ		     ณ@return	Posicao 1  - LOGICAL - indica o status do processamento			 บฑฑ
ฑฑบ		     ณ@return	Posicao 2  - CHAR    - Xml/Conte๚do de retorno do processamento  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PEI056( lStatus, cXmlStatus, oMdlOper, oXmlOper, cMarca, cValExtern ) 

Local oMdlDet	:= oMdlOper:GetModel("RHQDETAIL")

Local lDel		:= oMdlOper:GetOperation() == MODEL_OPERATION_DELETE

Local cVlInt	:= ""
Local cCodFunEx	:= ""
Local cCodFun	:= ""
Local cCusto	:= ""
Local xCustoEx	:= ""
Local cDeMesAno	:= ""
Local cAteMesAno:= ""
Local nPercen	:= ""
Local cMesDe	:= ""
Local cAnoDe	:= ""
Local cMesAte	:= ""
Local cAnoAte	:= ""

Local dDataDe 	:= CTOD("")
Local dDataAte 	:= CTOD("")

Local nPosDtDe 	:= 0
Local nPosDtAt 	:= 0
Local nPosCC 	:= 0
Local nPos 		:= 0

Local nI 		:= 0
Local aAux 		:= {}
Local aLinha 	:= {}

DEFAULT lStatus := .T.
DEFAULT cXmlStatus := ""

If !lDel

	If ValType(oXmlOper:_BusinessContent:_ListOfProgramming:_Proration) <> "A"
		XmlNode2Arr(oXmlOper:_BusinessContent:_ListOfProgramming:_Proration, '_PRORATION')
	EndIf
	
	aAux := oMdlOper:GetModel("RHQDETAIL"):GetOldData()

	nPosDtDe := aScan( aAux[1], {|x| Alltrim(x[2])=="RHQ_DEMES" } )
	nPosDtAt := aScan( aAux[1], {|x| Alltrim(x[2])=="RHQ_AMES" } )
	nPosCC := aScan( aAux[1], {|x| Alltrim(x[2])=="RHQ_CC" } )
	
	If Len(oXmlOper:_BusinessContent:_ListOfProgramming:_Proration) == 0
	
		lStatus := .F.
		cXmlStatus += STR0007 // "Nใo hแ itens para cria็a๕ do rateio"
	
	Else
	
		For nI:= 1 To Len(oXmlOper:_BusinessContent:_ListOfProgramming:_Proration)
															
			If lStatus 
				If XmlChildEx( oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI], "_FROMMONTHYEAR" ) <> Nil
				
					dDataDe 	:= STOD( StrTran( SubStr( oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI]:_FromMonthYear:Text, 1, 10 ), "-", "") )
					cMesDe 		:= StrZero( Month(dDataDe), 2 )
					
					cAnoDe		:= CValToChar(Year(dDataDe))
					cDeMesAno	:= cMesDe+cAnoDe
				
				Else
					lStatus := .F.
					cXmlStatus += STR0008 + '_FromMonthYear ' + STR0009 + 'Proration[' + cValToChar( nI ) + ']' // 'Nใo encontrada a Tag ' #### ' no item ' #### 
				EndIf
			EndIf
	
			If lStatus 
				If XmlChildEx( oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI], "_TOMONTHYEAR" ) <> Nil
			   	
				   	dDataAte	:= STOD( StrTran( SubStr( oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI]:_ToMonthYear:Text, 1, 10), "-", "" ) )
					cMesAte		:= StrZero( Month(dDataAte), 2 )
					
					cAnoAte		:= CValToChar(Year(dDataAte))
					cAteMesAno	:= cMesAte+cAnoAte
			   	
				EndIf
			EndIf		
			
			If lStatus 
				If XmlChildEx( oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI], "_PRORATIONPERCENTAGE" ) <> Nil
					nPercen := Val(oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI]:_ProrationPercentage:Text)
		
					If nPercen == 100.00
						nPercen := 99.99999999  // #define com o valor para 100%
					EndIf
		
				Else
					lStatus := .F.
					cXmlStatus += STR0008 + '_ProrationPercentage ' + STR0009 + 'Proration[' + cValToChar( nI ) + ']' // 'Nใo encontrada a Tag ' #### ' no item ' ####
				EndIf
			EndIf
			
			If lStatus 
				If XmlChildEx( oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI], "_COSTCENTERINTERNALID" ) <> Nil
				
					xCustoEx	:= oXmlOper:_BusinessContent:_ListOfProgramming:_Proration[nI]:_CostCenterInternalId:Text
					xCustoEx 	:= IntCusInt( xCustoEx, cMarca, '2.000')
					
					If xCustoEx[1]
						
						cCusto := xCustoEx[2][2]+xCustoEx[2][3]
						
						DbSelectArea('CTT')
						CTT->( DbSetOrder( 1 ) )
						
						If !Empty(cCusto) .AND. CTT->( DbSeek( cCusto ) )
							cCusto := CTT->CTT_CUSTO
						Else
							lStatus := .F.
							cXmlStatus += STR0010 + '|' // 'Nใo encontrado o Codigo de Centro de Custo'
						EndIf
					Else
						lStatus := .F.
						cXmlStatus += xCustoEx[2] + "|"
					EndIf
		                                         
				Else
					lStatus := .F.
					cXmlStatus += STR0008 + '_CostCenterInternalId ' + STR0009 + 'Proration[' + cValToChar( nI ) + ']'+ "|"
				EndIf
			EndIf
	    	
	    	If lStatus
	    		//-----------------------------------------------
	    		//  Se ocorreu altera็ใo de uma linha do rateio 
	    		// DE - ATE - CC como chave
	    		If ( ( nPos := aScan( aAux[2], {|pos| pos[nPosDtDe]==cDeMesAno .And. pos[nPosDtAt]==cAteMesAno .And. pos[nPosCC]==cCusto } ) ) > 0 )
	    	
		    		oMdlDet:GoLine( nPos )
		    		lStatus := oMdlDet:SetValue( "RHQ_PERC", nPercen )
	    		
	    		Else
	    		
	    			If Empty( oMdlDet:GetValue("RHQ_DEMES") ) .And. Empty( oMdlDet:GetValue("RHQ_CC") )
	    				nPos := oMdlDet:GetLine()
	    			Else
	    				nPos := oMdlDet:AddLine()
	    			EndIf
	    			
	    			If nPos > 0
	    				
	    				lStatus := lStatus .And. oMdlDet:SetValue( "RHQ_DEMES", cDeMesAno )
	    				lStatus := lStatus .And. oMdlDet:SetValue( "RHQ_AMES" , cAteMesAno )
	    				lStatus := lStatus .And. oMdlDet:SetValue( "RHQ_CC"   , cCusto )
	    				lStatus := lStatus .And. oMdlDet:SetValue( "RHQ_PERC" , nPercen )
	    				
	    				lStatus := oMdlDet:VldLineData()
	    				
	    				If !lStatus 
	    					Exit
	    				EndIf
	    				
	    			Else 
	    				lStatus := .F.
	    				cXmlStatus += STR0011 // "Linha nใo p๔de ser inserida" 
	    			EndIf
	    		EndIf
	    		
	    		//----------------------------------------------------------
	    		//  Adiciona ao array para controle das linhas alteradas
	    		aAdd( aLinha, nPos )
	    	
	    	Else
	    		lStatus := .F.
	    		cXmlStatus += STR0012 + "-" + cValToChar(nI) + " |" // "Linha do rateio nใo ้ vแlida "
	    	EndIf
	    	
		Next nI
	EndIf
	
	//-------------------------------------------------
	//  Remove as linhas do grid
	// que nใo sofreram atualiza็ใo pela msg, ou seja
	// foram excluํdas do rateio pela outra aplica็ใo
	If lStatus
		For nI := 1 To oMdlDet:Length()
		
			If aScan( aLinha, {|x| x==nI } ) == 0
			
				oMdlDet:GoLine( nI )
				If !oMdlDet:DeleteLine()
					lStatus := .F.
					cXmlStatus += STR0013 + "|" // "Erro na exclusใo de rateio "
				EndIf
			
			EndIf
		
		Next nI
	EndIf
EndIf

lStatus := ( lStatus .And. oMdlOper:VldData() .And. oMdlOper:CommitData() )

If lStatus
    
	cVlInt := GPEI056Snd( { cEmpAnt, xFilial("RHQ"), oMdlOper:GetValue("SRAMASTER", "RA_MAT") } )
			
	//---------//
	// De/Para //
	//---------//
	If lDel
		CFGA070Mnt( Nil, 'RHQ', 'RHQ_MAT',  Nil, cVlInt, .T. )	// remove do de/para
	Else
		//-------------------------//
		//  Dados ok para grava็ใo //
		//-------------------------//
		cXmlStatus := '<ListOfInternalId>'
		cXmlStatus += 	'<InternalId>'
		cXmlStatus += 		'<Name>ProrationProgramming</Name>'
		cXmlStatus += 		'<Origin>'+ cValExtern +'</Origin>'
		cXmlStatus += 		'<Destination>'+ cVlInt +'</Destination>'
		cXmlStatus += 	'</InternalId>'
		cXmlStatus += '</ListOfInternalId>'
	
		CFGA070Mnt( cMarca, 'RHQ', 'RHQ_MAT', cValExtern, cVlInt )
	EndIf
	
Else
	//------------------------------------------//
	//  Identificar erro do modelo para retorno //
	//------------------------------------------//
	cXmlStatus += ApErroMvc( oMdlOper )
EndIf

aSize( aAux, 0 )
aAux := Nil

aSize( aLinha, 0 )
aLinha := Nil

Return{ lStatus, cXmlStatus } 

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI080Snd
Rotina para integra็ใo por EAI 

@since 26/06/2013
@version P11
@params	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI056Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := { cEmpAnt, xFilial("RHQ"), RHQ_MAT }

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI080Rcv
Rotina para realizar a separa็ใo da chave da tabela do conte๚do gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos 

@since 26/06/2013
@version P11
@params	cTmpKeyInt - valor para realizar o tratamento, array para inserir pipes e string
	para remover pipes
@params aCposChave - array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI056Rcv( cTmpKeyInt, aCposChave )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

Default cTmpKeyInt := ""
Default aCposChave := { "RHQ_FILIAL", "RHQ_MAT" }

xAuxKey := StrToKarr( cTmpKeyInt, "|" )

If ( Len( xAuxKey ) - 1) == Len( aCposChave )
	
	For nZ := 2 To Len( xAuxKey )
	
		cTempKey += PadR( xAuxKey[nZ], TamSX3( aCposChave[nZ-1] )[1] )
	
	Next nZ
EndIf

xAuxKey := aSize( xAuxKey, 0 )

Return cTempKey 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณApErroMvc บAutor  ณ 					   บ Data ณ  18/02/13         	     บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ Apura o erro do mvc retornando uma string 				          	     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGPEA370		                                            	      	     บฑฑ 
ฑฑบ		     ณ@params	oModel     - modelo de dados para rotina automแtica     	     บฑฑ
ฑฑบ		     ณ@return	cErro      - erro apurado no modelo					      	     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ApErroMvc( oModel )

Local cErro  := ' '
Local aErros := oModel:GetErrorMessage()
Local nX     := 0 

For nX := 1 To Len(aErros)
	If Valtype(aErros[nX])=='C'
		
		cErro += StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(aErros[nX],CHR(10),""),CHR(13),""),"<",""),"\",""),">",""),"/", "") + ("|")
		
	ElseIf Valtype(aErros[nX])=='N'
		
		cErro += cValToChar( aErros[nX] )
		
	ElseIf Valtype(aErros[nX])=='D'
		
		cErro += DTOC( aErros[nX] )
		
	EndIf
Next nX

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplica็ใo destino para grava็ใo do De/Para 

@since 26/06/2013
@version P11
@params 	lProcOk 	Status do processamento (refer๊ncia)
@params 	cMsgRet 	Mensagem de retorno do processamento (refer๊ncia)
@params 	cXml    	Mensagem da response para tratamento

/*/
//-------------------------------------------------------------------
Static Function TrataResp( lProcOk, cMsgRet, cXml )

Local oObjXml 	:= Nil
Local cXmlErro 	:= ""
Local cXmlWarn 	:= ""
Local nZ 		:= 0
Local cMarca 	:= ""

oObjXml := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )

If oObjXml <> Nil .And. Empty( cXmlErro ) .And. Empty( cXmlWarn )

	cMarca := oObjXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text

	If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_STATUS" ) <> Nil .And. ;
		Upper( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"
	
		oObjXml := XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID" )  
		
		If oObjXml <> Nil
			
			If XmlChildEx( oObjXml, "_INTERNALID" ) <> Nil 
				
				If Valtype( oObjXml:_InternalId ) <> "A"
					XmlNode2Arr( oObjXml:_InternalId, "_InternalId" )
				EndIf
				
				For nZ := 1 To Len( oObjXml:_InternalId )
				
					If XmlChildEx( oObjXml:_InternalId[nZ], "_NAME" ) <> Nil .And. ;
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "PRORATIONPROGRAMMING" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'RHQ', 'RHQ_MAT', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0014 // "Nใo enviado conte๚do de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0015 // "Nใo ้ possํvel gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0016 + "|" // "Erro no processamento pela outra aplica็ใo"
		
		If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_LISTOFMESSAGES" ) <> Nil
			oObjXml := oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages
			
			If XmlChildEx( oObjXml, "_MESSAGE" ) <> Nil 
				
				If Valtype( oObjXml:_Message ) <> "A"
					XmlNode2Arr( oObjXml:_Message, "_Message" )
				EndIf
				
				For nZ := 1 To Len( oObjXml:_Message )
				
					cMsgRet += Alltrim( oObjXml:_Message[nZ]:Text ) + "|"
				
				Next nZ
			Else
				
				lProcOk := .F.
				cMsgRet := STR0017 // "Erro no processamento, mas sem detalhes do erro pela outra aplica็ใo"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0018 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para nใo serแ gravado" ####
EndIf

oObjXml := Nil
DelClassIntF()

Return
