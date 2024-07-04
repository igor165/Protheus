#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "APWEBEX.CH"   

#DEFINE cAviso	'Não Possui'

/*******************************************************************
* Funcao: PWES01
* Autor: RECURSOS HUMANOS
* Data: 25/09/2015
* Solicitacao de Alteração Cadastral E-Social 2.1
/*******************************************************************/

Web Function PWES01()

	Local cHtml   	:= ""
	Local nIndice 	:= 0
	Local nTam 		:= 0
	Local nI 			:= 0
	
	if(valtype(HttpGet->nIndice) != "U")
   		nIndice := val(HttpGet->nIndice) 
	endif
	
	WEB EXTENDED INIT cHtml START "InSite"	 // Garante que existe uma sessão válida.             
		
		HttpSession->cTypeRequest := "2" // Alteração Cadastral.
		HttpSession->aStructure   := {}		           
		HttpSession->cMatUsr := ""
		HttpSession->cCodDep := ""
		HttpSession->lVldUSr := .F.
		HttpSession->cAuxMsg := ""
		HttpGet->lEx := .T.
		HttpGet->lResideExt := .T.
		
		/*******************************
		 - PROPIEDADES DADOS PRINCIPAIS.
		********************************/
		HttpPost->valueCpf 	:= ""
		HttpPost->valuePis 	:= ""
		HttpPost->nomMae	  	:= ""
		HttpPost->nomPai		:= ""
		HttpPost->nomComp		:= ""

		oWSFunc := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHEMPLOYEEREGISTRATION"), WsRHEMPLOYEEREGISTRATION():New())
		WsChgURL(@oWSFunc, "RHEMPLOYEEREGISTRATION.apw")
   		oWSFunc:cEmployeeFil 	:= HttpSession->aUser[2] //Filial
		oWSFunc:cRegistration	:= HttpSession->aUser[3] // Matricula
		
		/*********************************************
		- INCLUIDO TRATAMENTO PARA VERIFICAR SE JÁ
		- EXISTEM ALTERAÇÕES PENDENTES.
		/*********************************************/
		oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
     
		oOrg2:cParticipantID 	:= HttpSession->cParticipantID
		oOrg2:cTypeOrg       	:= ""
		If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
			oOrg2:cRegistration	:= HttpSession->RHMat
		EndIf	
		
		oOrg2:cRequestType := HttpSession->cTypeRequest
		If oOrg2:GetStructure()
			HttpSession->aStructure  := aClone(oOrg2:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
			nTam := Len(HttpSession->aStructure)
			For nI := 1 To nTam
				If Alltrim(HttpSession->aStructure[nI]:cRegistration) == Alltrim(HttpSession->aUser[3]) .AND.;
				    AllTrim(HttpSession->aStructure[nI]:cEmployeeFilial) == AllTrim(HttpSession->aUser[2])  		
	        		HttpGet->nIndice	:= str(nI)
	        		HttpGet->nOperacao	:= "1"
	        		HttpSession->lSolicit := HttpSession->aStructure[nI]:lPossuiSolic
	        	EndIf
	        Next nI
		EndIF
				
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oOrg,"RHREQUEST.APW")
     	/************************************
		- VERIFICA SE FUNCIONÁRIO POSSUI
		- POSSUI RA_RESEXT (Reside Exterior)
		************************************/
		oOrg:cEnrolmentId := oWSFunc:cRegistration
		oOrg:cBranch := oWSFunc:cEmployeefil
		If oOrg:GETRECEXT()
			HttpGet->lResideExt := .T.
		Else 
			HttpGet->lResideExt := .F.
		EndIF
			
    		
    	/************************************
		- VERIFICA SE FUNCIONÁRIO POSSUI
		- ESTRANGEIRO, PARA BLOQUEAR ABA DE 
		- CADASTRO ESTRANGEIRO.
		************************************/
		oOrg:cEnrolmentId := oWSFunc:cRegistration
		HttpSession->cMatUsr := oOrg:cEnrolmentId 
			If oOrg:GetForeign()
				HttpGet->lEx := .T.
				HttpSession->lVldUSr := .T.
			Else 
				HttpGet->lEx := .F.
				HttpSession->lVldUSr := .F.
			EndIF
			
		/************************************
		- LISTAGEM DOS DADOS NA PRIMEIRA ABA
		- ( DADOS PRINCIPAIS ).
		************************************/	
		If oOrg:GetParticipanteSoc()
	 	If !Empty(oOrg:oWSGETPARTICIPANTESOCRESULT:cCPF)
	 		HttpPost->valueCpf 	:= oOrg:oWSGETPARTICIPANTESOCRESULT:cCPF
	 	Else
	 		HttpPost->valueCpf 	:= cAviso
	 	EndIF
	 	
	 	If !Empty(oOrg:oWSGETPARTICIPANTESOCRESULT:cPIS) 
	 		 HttpPost->valuePis 	:= oOrg:oWSGETPARTICIPANTESOCRESULT:cPIS
	 	Else		
			HttpPost->valuePis  	:= cAviso
		EndIF
		
		If !Empty(oOrg:oWSGETPARTICIPANTESOCRESULT:cNOMMAE)
			HttpPost->nomMae	  	:= oOrg:oWSGETPARTICIPANTESOCRESULT:cNOMMAE
		Else 
			HttpPost->nomMae		:= cAviso
		EndIF
		
		If !Empty(oOrg:oWSGETPARTICIPANTESOCRESULT:cNOMPAI)
			HttpPost->nomPai		:= oOrg:oWSGETPARTICIPANTESOCRESULT:cNOMPAI
		Else
			HttpPost->nomPai 		:= cAviso
		EndIF	
		
		If !Empty(oOrg:oWSGETPARTICIPANTESOCRESULT:cNOMCOMP)
			HttpPost->nomComp		:= oOrg:oWSGETPARTICIPANTESOCRESULT:cNOMCOMP
		Else
			HttpPost->nomComp  	:= cAviso
		EndIF	
	 Else
	 	Conout("Erro: " + GetWSCError(3) )	
	 EndIF	
	 
	 /******************************************
	 - LISTAGEM DOS DEPENDENTES DO FUNCIONÁRIO.
	 - FUTURA IMPLEMENTAÇÃO.
	 ******************************************/
		oWSDependents := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHDependents"), WSRHDependents():New())
		WsChgURL(@oWSDependents, "RHDEPENDENTS.APW")
	    
		oWSDependents:cBranch 	        := HttpSession->aUser[2] //Filial
 		oWSDependents:cRegistration    	 := HttpSession->aUser[3] // Matricula

		If oWSDependents:BrowseDependents()	
			oEmployee		:=    oWSDependents:oWSBrowseDependentsResult:oWSEmployee
			aDependents	:=    oWSDependents:oWSBrowseDependentsResult:oWSDependents:oWSTDependent 
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "" }
			Return ExecInPage("PWSAMSG" )
		EndIf
	 
	 /*************************************
	 - LISTAGEM DOS DADOS NAS DEMAIS ABAS.
	 *************************************/
	 If oOrg:GETFIELDSESOC()
	 		HttpPost->cel := oOrg:oWSGETFIELDSESOCRESULT:cCELULAR
	 		HttpPost->nrRNE	:= oOrg:oWSGETFIELDSESOCRESULT:cRNE 
			HttpPost->orgEmisRNE :=	oOrg:oWSGETFIELDSESOCRESULT:cRNEORG    	
			HttpPost->dtExpedRNE := 	oOrg:oWSGETFIELDSESOCRESULT:dRNEDEXP    
			HttpPost->casadoCBr	:= oOrg:oWSGETFIELDSESOCRESULT:cCASADBR
			HttpPost->filhosBr   :=	oOrg:oWSGETFIELDSESOCRESULT:cFILHOBR 		
			HttpPost->dtDeCheg 	:=	oOrg:oWSGETFIELDSESOCRESULT:dDATCHEG		 
			HttpPost->classEst	:= oOrg:oWSGETFIELDSESOCRESULT:cCLASEEST		

			//HttpPost->cartorio 	:= oOrg:oWSGETFIELDSESOCRESULT:cCARTORI 			
			HttpPost->catCnh   	:= oOrg:oWSGETFIELDSESOCRESULT:cCATEGORIACNH		
			HttpPost->txtMunRic 	:= oOrg:oWSGETFIELDSESOCRESULT:cCDMURIC					
			HttpPost->cep 		:= oOrg:oWSGETFIELDSESOCRESULT:cCEP				
			//HttpPost->cpfDep     := oOrg:oWSGETFIELDSESOCRESULT:cCIC			 
			HttpPost->cnhOrg 		:= oOrg:oWSGETFIELDSESOCRESULT:cCNHORG				
			HttpPost->cdClass    := oOrg:oWSGETFIELDSESOCRESULT:cCODIGOINSC		
			HttpPost->txtMunic	:= oOrg:oWSGETFIELDSESOCRESULT:cCODMUN
			HttpPost->txtMunCad  := oOrg:oWSGETFIELDSESOCRESULT:cCODMUNCAD
			HttpPost->dddCel		:= oOrg:oWSGETFIELDSESOCRESULT:cDDDCEL				
			HttpPost->dddTel    := oOrg:oWSGETFIELDSESOCRESULT:cDDDFONE			
			HttpPost->dtEmisRic  := oOrg:oWSGETFIELDSESOCRESULT:dDEXPRIC			
			//HttpPost->dtDataBaixa := oOrg:oWSGETFIELDSESOCRESULT:dDTBAIXA			
			HttpPost->dataEmiss := oOrg:oWSGETFIELDSESOCRESULT:dDTEMCNH		
			//HttpPost->dtEntDoc  := oOrg:oWSGETFIELDSESOCRESULT:dDTENTRA			
			//HttpPost->dtNascDep := oOrg:oWSGETFIELDSESOCRESULT:dDTNASC				
			HttpPost->dataVenc  := oOrg:oWSGETFIELDSESOCRESULT:dDTVCCNH			
			HttpPost->emailTit  := oOrg:oWSGETFIELDSESOCRESULT:cEMAIL				
			HttpPost->emailAlt   := oOrg:oWSGETFIELDSESOCRESULT:cEMAILALT			
			HttpPost->orgEmis    := oOrg:oWSGETFIELDSESOCRESULT:cEMISRIC 			             
	   		HttpPost->txtEstCiv := oOrg:oWSGETFIELDSESOCRESULT:cESTCIV 			                              
	   		HttpPost->txtGrInstr := oOrg:oWSGETFIELDSESOCRESULT:cGRAUINST 		              
	   		//HttpPost->grParent   := oOrg:oWSGETFIELDSESOCRESULT:cGRAUPAR  			               
	   		HttpPost->nrCnh 		:= oOrg:oWSGETFIELDSESOCRESULT:cHABILIT   		           
	   		//HttpPost->localNasc  := oOrg:oWSGETFIELDSESOCRESULT:cLOCNASC   		               
	   		HttpPost->txtPaisCad := oOrg:oWSGETFIELDSESOCRESULT:cNACIONALIDADE  	         
	   		//HttpPost->nomeDep    := oOrg:oWSGETFIELDSESOCRESULT:cNOME   			                  
	   		//HttpPost->nRegCart   := oOrg:oWSGETFIELDSESOCRESULT:cNREGCAR 			               
	   		//HttpPost->certCiv    := oOrg:oWSGETFIELDSESOCRESULT:cNUMAT 				               
	   		HttpPost->nrCtps     := oOrg:oWSGETFIELDSESOCRESULT:cNUMCP   			                 
	   		//HttpPost->nFol       := oOrg:oWSGETFIELDSESOCRESULT:cNUMFOLH 			              
	   		//HttpPost->nLivro     := oOrg:oWSGETFIELDSESOCRESULT:cNUMLIVR  			             
	   		HttpPost->nrLogr     := oOrg:oWSGETFIELDSESOCRESULT:cNUMLOGRADOURO 	
	   		HttpPost->logrDsc    := oOrg:oWSGETFIELDSESOCRESULT:cLOGRDESC
	   		HttpPost->est	 	 := oOrg:oWSGETFIELDSESOCRESULT:cEST   
			HttpPost->Bairro	 := oOrg:oWSGETFIELDSESOCRESULT:cBAIRRO         
			HttpPost->complemento := oOrg:oWSGETFIELDSESOCRESULT:cCOMPLEMENTO
	   		HttpPost->nrMenor    := oOrg:oWSGETFIELDSESOCRESULT:cNUMPROCMENOR  	          
	   		HttpPost->nrRic      := oOrg:oWSGETFIELDSESOCRESULT:cNUMRIC      		            
	   		HttpPost->obsDef01	:= oOrg:oWSGETFIELDSESOCRESULT:cOBSDEF      		             
	   		HttpPost->dtEmissao  := oOrg:oWSGETFIELDSESOCRESULT:dOCDTEXP    		          
	   		HttpPost->dtValid    := oOrg:oWSGETFIELDSESOCRESULT:dOCDTVAL    		         
	   		HttpPost->orgClassEmi := oOrg:oWSGETFIELDSESOCRESULT:cOCEMIS      		             
	   		HttpPost->txtPais    := oOrg:oWSGETFIELDSESOCRESULT:cPAISEXT    		              
	   		HttpPost->txtPaisOr  := oOrg:oWSGETFIELDSESOCRESULT:cPAISORIGEM                        
	   		HttpPost->aposen := oOrg:oWSGETFIELDSESOCRESULT:cRECAPOSEN     	                      
	   		HttpPost->serieCTPS  := oOrg:oWSGETFIELDSESOCRESULT:cSERCP     		             
	   		//HttpPost->gen  := oOrg:oWSGETFIELDSESOCRESULT:cSEXO      		             
	   		HttpPost->tel := oOrg:oWSGETFIELDSESOCRESULT:cTELEFONE    		            
	   		//HttpPost->tpDepIR := oOrg:oWSGETFIELDSESOCRESULT:cTIPIR         	          
	   		HttpPost->selectTpLogr := oOrg:oWSGETFIELDSESOCRESULT:cTIPOLOGRADOURO 	          
	   		//HttpPost->tpDepSF := oOrg:oWSGETFIELDSESOCRESULT:cTIPSF        		          
	   		//HttpPost->tipoDep := oOrg:oWSGETFIELDSESOCRESULT:cTPDEP        		           
	   		HttpPost->txtUfCnh  := oOrg:oWSGETFIELDSESOCRESULT:cUFCNH          	       
	   		HttpPost->txtCTPS := oOrg:oWSGETFIELDSESOCRESULT:cUFCP         		            
	   		HttpPost->txtRic := oOrg:oWSGETFIELDSESOCRESULT:cUFRIC  			
	 Else
	 	Conout("Erro: " + GetWSCError(3) )
	 EndIF
		HttpCTType("text/html; charset=ISO-8859-1")		
		
		/******************************
		- Verifica Mnemonico do eSocial
		- ESOCIALVRS.
		******************************/
			If oOrg:GETMNEMONIC() .AND. oOrg:GetXBAux()
				cHtml := ExecInPage("PWES01")
			Else
				HttpSession->_HTMLERRO := { 'Incompatibilidade.', 'Página indisponível. Entre em contato com o RH', "" }	//"FALTA O MNEMONICO ESOCIALVRS"
				Return ExecInPage("PWSAMSG" )
			EndIF
		
	WEB EXTENDED END
Return cHtml

/*******************************************************************
 - MÉTODO DE VISUALIZAÇÃO DO DEPENDENTE.
 - PARA ABRIR A TELA DE ALTERAÇÃO DO DEPENDENTE ESCOLHIDO.
 - MANUTENÇÃO RH. 
********************************************************************/

Web Function PWES02()
Local cHtml 		:= ""

	WEB EXTENDED INIT cHtml 
	
	HttpSession->cCodDpAux := ''
	/******************************************
	 - LISTAGEM DOS DEPENDENTES DO FUNCIONÁRIO.
	 - FUTURA IMPLEMENTAÇÃO.
	 ******************************************/
		oWSDependents := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHDependents"), WSRHDependents():New())
		WsChgURL(@oWSDependents, "RHDEPENDENTS.APW")
	    	    
		oWSDependents:cBranch 	        := HttpSession->aUser[2] // Filial
 		oWSDependents:cRegistration    	 := HttpSession->aUser[3] // Matricula
 		oWSDependents:cCODDEPENDENT		 := HttpGet->cCodDep		 // Código do Dependente
		HttpSession->cCodDpAux 			 := HttpGet->cCodDep
		oWSDependents:oWSDADOSDEPENDENT:cTPDEP  := HttpPost->tipoDep
		
		If oWSDependents:GETDEPESOC()	
			oEmployee		:= oWSDependents:oWSGETDEPESOCRESULT:oWSEmployee
			aDependents	:= oWSDependents:oWSGETDEPESOCRESULT:oWSDependents:oWSTDependent             
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "" }
			Return ExecInPage("PWSAMSG" )
		EndIf	
						
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "PWES02" )
	WEB EXTENDED END			
Return cHtml

/*******************************************************************
 - MÉTODO DE GRAVAÇÃO DA ALTERAÇÃO DO DEPENDENTE.
 - MANUTENÇÃO RH. 
********************************************************************/

Web Function PWES03()
Local cHtml 		:= ""
	WEB EXTENDED INIT cHtml 
	     
		HttpSession->lVlrDif   := .F.                       
	/******************************************
	 - LISTAGEM DOS DEPENDENTES DO FUNCIONÁRIO.
	 - FUTURA IMPLEMENTAÇÃO.
	 ******************************************/
		oWSDependents := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHDependents"), WSRHDependents():New())
		WsChgURL(@oWSDependents, "RHDEPENDENTS.APW")
	    	    
		oWSDependents:cBranch 	        := HttpSession->aUser[2] 		// Filial
 		oWSDependents:cRegistration    	 := HttpSession->aUser[3] 		// Matricula
 		oWSDependents:cCODIGODEP		 	 := HttpSession->cCodDpAux      // Código do Dependente
 	
 		If oWSDependents:oWSDADOSDEPENDENT:cCICAUX == HttpPost->tpCpfDep
 			HttpSession->lVlrDif := .T.
 		EndIF
 		
 		If oWSDependents:oWSDADOSDEPENDENT:cTPDEPAUX == HttpPost->tipoDep
 			HttpSession->lVlrDif := .T.
 		EndIF
 		
		oWSDependents:oWSDADOSDEPENDENT:cCICDEP := HttpPost->tpCpfDep
		oWSDependents:oWSDADOSDEPENDENT:cTPDEP  := HttpPost->tipoDep
		
		If oWSDependents:ADDALTERACAODEPENDENT()	
			HttpSession->cResult := oWSDependents:cADDALTERACAODEPENDENTRESULT
			HttpSession->cAuxMsg := "D" 
			Return ExecInPage("PWESF")          
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "" }
			Return ExecInPage("PWSAMSG" )
		EndIf	
			
		HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED END			
Return cHtml

/*******************************************************************
 - MÉTODO DE GRAVAÇÃO DA REQUISIÇÃO.
 - NÃO UTILIZA APROVAÇÃO VIA PORTAL E SIM APROVAÇÃO VIA RESPONSÁVEL 
 - PELO RH QUE IRÁ VERIFICAR E APROVAR A REQUISIÇÃO DE APROVAÇÃO PELO 
 - ERP.
/*******************************************************************/

Web Function PWES05()

Local cHtml   	:= ""
Local oOrg    	:= Nil
Local cRetorno	:= ""
Local cNewNameFile	:= ''
Local oObjFunc


WEB EXTENDED INIT cHtml START "InSite"

   	fGetInfRotina("W_PWES01.APW")
	GetMat() 


	//ANEXO ARQUIVO
	oObjFunc := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
	WsChgURL(@oObjFunc,"RHREQUEST.APW")
	
	If HttpPost->txtFile != ""
		oObjFunc:cBranch		   := HttpSession->aUser[2] // FILIAL DO FUNCIONÁRIO.
		oObjFunc:cEnrolmentId	:= HttpSession->cMatUsr // MATRÍCULA DO FUNCIONÁRIO.
		oObjFunc:cPatchObject	:= HttpPost->txtFile // ARQUIVO.
		oObjFunc:cDescObject		:= 'eSocial' 			// DESCRIÇÃO INCREMENTAL EX: ESOCIAL00000001.
		oObjFunc:nCurrentPage 	:= If(type("HttpPost->cCurrentPage") =="U", 1, val(HttpPost->cCurrentPage) )
	
		/*************************
		- GRAVAÇÃO DO ARQUIVO
		- NA BASE DE CONHECIMENTO.
		**************************/		
		If oObjFunc:SetAnexoESoc()
			cNewNameFile	:= oObjFunc:cSETANEXOESOCRESULT
			HttpSession->cAuxMsg := "A"
		Else
			Conout( PWSGetWSError() )
			HttpSession->_HTMLERRO := { 'Erro', PWSGetWSError(), "" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	Endif
	
	//---------------------------------------------------------------------------------------------------------------
      
	               
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
	WsChgURL(@oOrg,"RHREQUEST.APW")
    
	oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
     
	oOrg2:cParticipantID 	:= HttpSession->cParticipantID
	oOrg2:cTypeOrg       	:= ""
	If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
		oOrg2:cRegistration	:= HttpSession->RHMat
	EndIf	

	If oOrg2:GetStructure()
	    //Pega filial e matricula do participante
	    GetMat() 

		oOrg:oWSREQUEST:cSTARTERREGISTRATION 		:= HttpSession->aUser[3] //Filial do solicitante
		oOrg:oWSREQUEST:cStarterBranch				:= HttpSession->aUser[2] //matricula do solicitante
		oOrg:oWSREQUEST:cBRANCH                   := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		oOrg:oWSREQUEST:cREGISTRATION             := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oOrg:cENROLMENTID								:= HttpSession->cMatUsr
		oOrg:oWSREQUEST:cOBSERVATION    			:= 'Alteracao Cadastral eSocial 2.1' 

		/****************************************
		- Se o funcionário possuir acesso
		- a Aba Estrangeiro, permite a alteração.
		****************************************/
		If HttpSession->cTypeRequest == "2"	
			If HttpSession->lVldUSr
				oOrg:oWSFIELDSINPUTESOC:cRNE       	:= ''
				oOrg:oWSFIELDSINPUTESOC:cRNEORG    	:= ''
				If !Empty(HttpPost->dtExpedRNE)
					oOrg:oWSFIELDSINPUTESOC:dRNEDEXP    	:= CTOD(HttpPost->dtExpedRNE)
				Else
					oOrg:oWSFIELDSINPUTESOC:dRNEDEXP    	:= CTOD(" / / ")
				EndIF
				If !Empty(HttpPost->dtDeCheg)
					oOrg:oWSFIELDSINPUTESOC:dDATCHEG		:= CTOD(HttpPost->dtDeCheg)
				Else
					oOrg:oWSFIELDSINPUTESOC:dDATCHEG    	:= CTOD(" / / ")
				EndIF
				
				oOrg:oWSFIELDSINPUTESOC:cCASADBR		:= ''
				oOrg:oWSFIELDSINPUTESOC:cFILHOBR 		:= '' 
				oOrg:oWSFIELDSINPUTESOC:cCLASEEST		:= ''
			Else
				If !Empty(HttpPost->dtExpedRNE)
					oOrg:oWSFIELDSINPUTESOC:dRNEDEXP    	:= CTOD(HttpPost->dtExpedRNE)
				Else
					oOrg:oWSFIELDSINPUTESOC:dRNEDEXP    	:= CTOD(" / / ")
				EndIF
				If !Empty(HttpPost->dtDeCheg)
					oOrg:oWSFIELDSINPUTESOC:dDATCHEG		:= CTOD(HttpPost->dtDeCheg)
				Else
					oOrg:oWSFIELDSINPUTESOC:dDATCHEG    	:= CTOD(" / / ")
				EndIF
				If !Empty(HttpPost->nrRNE)
					oOrg:oWSFIELDSINPUTESOC:cRNE       	:= HttpPost->nrRNE
				EndIF
				If !Empty(HttpPost->orgEmisRNE)
					oOrg:oWSFIELDSINPUTESOC:cRNEORG    	:= HttpPost->orgEmisRNE 
				EndIF
				If !Empty(HttpPost->casadoCBr)
					oOrg:oWSFIELDSINPUTESOC:cCASADBR		:= HttpPost->casadoCBr
				EndIF
				If !Empty(HttpPost->filhosBr)
					oOrg:oWSFIELDSINPUTESOC:cFILHOBR 		:= HttpPost->filhosBr
				EndIF
				If !Empty(HttpPost->classEst) 
					oOrg:oWSFIELDSINPUTESOC:cCLASEEST		:= HttpPost->classEst
				EndIF
			EndIF
			
			/*************************************
			- Verifica se os campos de datas estão
			- preenchidos, para não enviar sem 
			- conteúdo gerando inconsistência
			- na EXECAUTO.
			**************************************/
			If !Empty(HttpPost->dtEmisRic)
				oOrg:oWSFIELDSINPUTESOC:dDEXPRIC			:= CTOD(HttpPost->dtEmisRic)
			Else
				oOrg:oWSFIELDSINPUTESOC:dDEXPRIC			:= CTOD(" / / ")
			EndIF 
			
			If !Empty(HttpPost->dataEmiss) 
				oOrg:oWSFIELDSINPUTESOC:dDTEMCNH			:= CTOD(HttpPost->dataEmiss)
			Else
				oOrg:oWSFIELDSINPUTESOC:dDTEMCNH			:= CTOD(" / / ")
			EndIF
			
			If !Empty(HttpPost->dataVenc)
				oOrg:oWSFIELDSINPUTESOC:dDTVCCNH			:= CTOD(HttpPost->dataVenc)
			Else
				oOrg:oWSFIELDSINPUTESOC:dDTVCCNH			:= CTOD(" / / ")
			EndIF
			
			If !Empty(HttpPost->dtEmissao)
				oOrg:oWSFIELDSINPUTESOC:dOCDTEXP    		:= CTOD(HttpPost->dtEmissao)
			Else
				oOrg:oWSFIELDSINPUTESOC:dOCDTEXP			:= CTOD(" / / ")
			EndIF
			
			If !Empty(HttpPost->dtValid)
				oOrg:oWSFIELDSINPUTESOC:dOCDTVAL    		:= CTOD(HttpPost->dtValid)
			Else
				oOrg:oWSFIELDSINPUTESOC:dOCDTVAL			:= CTOD(" / / ")
			EndIF
						
			/*************************************
			- Recebendo os valores e enviando
			- para as propiedades do ws.
			**************************************/ 
			If !Empty(HttpPost->catCnh)
				oOrg:oWSFIELDSINPUTESOC:cCATEGORIACNH		:= HttpPost->catCnh
			EndIF
			If !Empty(HttpPost->txtMunRic)
				oOrg:oWSFIELDSINPUTESOC:cCDMURIC			:= HttpPost->txtMunRic
			EndIF
			If !Empty(HttpPost->cel)
				oOrg:oWSFIELDSINPUTESOC:cCELULAR			:= HttpPost->cel
			EndIF
			If !Empty(HttpPost->cep)
				oOrg:oWSFIELDSINPUTESOC:cCEP				:= HttpPost->cep
			EndIF
			If !Empty(HttpPost->cnhOrg)
				oOrg:oWSFIELDSINPUTESOC:cCNHORG				:= HttpPost->cnhOrg
			EndIF
			If !Empty(HttpPost->cdClass)
				oOrg:oWSFIELDSINPUTESOC:cCODIGOINSC		:= HttpPost->cdClass
			EndIF
			If !Empty(HttpPost->txtMunic)
				oOrg:oWSFIELDSINPUTESOC:cCODMUN				:= HttpPost->txtMunic
			EndIF
			If !Empty(HttpPost->txtMunCad)
				oOrg:oWSFIELDSINPUTESOC:cCODMUNCAD			:= HttpPost->txtMunCad
			EndIF
			If !Empty(HttpPost->dddCel)
				oOrg:oWSFIELDSINPUTESOC:cDDDCEL				:= HttpPost->dddCel
			EndIF
			If !Empty(HttpPost->dddTel)
				oOrg:oWSFIELDSINPUTESOC:cDDDFONE			:= HttpPost->dddTel
			EndIF
			If !Empty(HttpPost->emailTit)
				oOrg:oWSFIELDSINPUTESOC:cEMAIL				:= HttpPost->emailTit
			EndIF
			If !Empty(HttpPost->emailAlt)
				oOrg:oWSFIELDSINPUTESOC:cEMAILALT			:= HttpPost->emailAlt
			EndIF
			If !Empty(HttpPost->orgEmis)
				oOrg:oWSFIELDSINPUTESOC:cEMISRIC 			:= HttpPost->orgEmis 
			EndIF 
			If !Empty(HttpPost->txtEstCiv)            
	   			oOrg:oWSFIELDSINPUTESOC:cESTCIV 			:= HttpPost->txtEstCiv
	   		EndIF
	   		If !Empty(HttpPost->txtGrInstr)                               
	   			oOrg:oWSFIELDSINPUTESOC:cGRAUINST 			:= HttpPost->txtGrInstr 
	   		EndIF 
	   		If !Empty(HttpPost->nrCnh)                     
	   			oOrg:oWSFIELDSINPUTESOC:cHABILIT   		:= HttpPost->nrCnh   
	   		EndIF
	   		If !Empty(HttpPost->txtPaisCad)                       
	   			oOrg:oWSFIELDSINPUTESOC:cNACIONALIDADE  	:= HttpPost->txtPaisCad 
	   		EndIF
	   		If !Empty(HttpPost->nrCtps)                         
	   			oOrg:oWSFIELDSINPUTESOC:cNUMCP   			:= HttpPost->nrCtps
	   		EndIF
	   		If !Empty(HttpPost->nrLogr)                             
	   			oOrg:oWSFIELDSINPUTESOC:cNUMLOGRADOURO 	:= HttpPost->nrLogr          
	   		EndIF
	   		If !Empty(HttpPost->complemento)                             
	   			oOrg:oWSFIELDSINPUTESOC:cCOMPLEMENTO 	:= HttpPost->complemento          
	   		EndIF
	   		If !Empty(HttpPost->logrDsc)                             
	   			oOrg:oWSFIELDSINPUTESOC:cLOGRDESC 			:= HttpPost->logrDsc          
	   		EndIF	   		
	   		If !Empty(HttpPost->est)                             
	   			oOrg:oWSFIELDSINPUTESOC:cEST			:= HttpPost->est         
	   		EndIF
			If !Empty(HttpPost->bairro)                             
	   			oOrg:oWSFIELDSINPUTESOC:cBAIRRO			:= HttpPost->bairro         
	   		EndIF 		
	   		If !Empty(HttpPost->nrMenor)
	   			oOrg:oWSFIELDSINPUTESOC:cNUMPROCMENOR  	:= HttpPost->nrMenor          
	   		EndIF
	   		If !Empty(HttpPost->nrRic)
	   			oOrg:oWSFIELDSINPUTESOC:cNUMRIC      		:= HttpPost->nrRic            
	   		EndIF
	   		If !Empty(HttpPost->obsDef01)
	   			oOrg:oWSFIELDSINPUTESOC:cOBSDEF      		:= HttpPost->obsDef01                     
	   		EndIF
	   		If !Empty(HttpPost->orgClassEmi)
	   			oOrg:oWSFIELDSINPUTESOC:cOCEMIS      		:= HttpPost->orgClassEmi            
	   		EndIF
	   		If !Empty(HttpPost->txtPais)
	   			oOrg:oWSFIELDSINPUTESOC:cPAISEXT    		:= HttpPost->txtPais             
	   		EndIF
	   		If !Empty(HttpPost->txtPaisOr)
	   			oOrg:oWSFIELDSINPUTESOC:cPAISORIGEM    	:= HttpPost->txtPaisOr          
	   		EndIF
	   		If !Empty(HttpPost->hd)
	   			oOrg:oWSFIELDSINPUTESOC:cPORTDEF       	:= HttpPost->hd        
	   		EndIF
	   		If !Empty(HttpPost->aposen)
	   			oOrg:oWSFIELDSINPUTESOC:cRECAPOSEN     	:= HttpPost->aposen 
	   		EndIF                     
	   		If !Empty(HttpPost->serieCTPS)
	   			oOrg:oWSFIELDSINPUTESOC:cSERCP     		:= HttpPost->serieCTPS                         
	   		EndIF
	   		If !Empty(HttpPost->tel)
	   			oOrg:oWSFIELDSINPUTESOC:cTELEFONE    		:= HttpPost->tel
	   		EndIF
	   		If !Empty(HttpPost->selectTpLogr)                     
	   			oOrg:oWSFIELDSINPUTESOC:cTIPOLOGRADOURO 	:= HttpPost->selectTpLogr 
	   		EndIF
	   		If !Empty(HttpPost->txtUfCnh)               
	   			oOrg:oWSFIELDSINPUTESOC:cUFCNH          	:= HttpPost->txtUfCnh
	   		EndIF
	   		If !Empty(HttpPost->txtCTPS)         
	   			oOrg:oWSFIELDSINPUTESOC:cUFCP         		:= HttpPost->txtCTPS
	   		EndIF
	   		If !Empty(HttpPost->txtRic)           
	   			oOrg:oWSFIELDSINPUTESOC:cUFRIC  			:= HttpPost->txtRic
			EndIF
					
			If !Empty(cNewNameFile)
				oOrg:oWSFIELDSINPUTESOC:cAnexo  			:= cNewNameFile
			EndIf
			/*******************************************
			- MÉTODO DA GRAVAÇÃO.
			*******************************************/
			If oOrg:ADDALTERACAOESOCIAL()
				cRetorno := oOrg:cADDALTERACAOESOCIALRESULT
				HttpGet->msg := 'Operacao realizada com sucesso' 
			   	W_PWSA115() // Solicitações
			Else
				HttpSession->_HTMLERRO := { 'Erro', PWSGetWSError(), "" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		EndIf
	Else
		HttpSession->_HTMLERRO := { 'Erro', PWSGetWSError(), "" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf
	


WEB EXTENDED END
Return cHtml
