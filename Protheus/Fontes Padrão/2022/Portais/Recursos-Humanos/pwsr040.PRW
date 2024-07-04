#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PWSR040.CH"

#DEFINE PAGE_LENGTH 10
/*************************************************************/


/*************************************************************/
/* Agenda do Candidato - Tela de Login			    		 */
/*************************************************************/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ PWSR040  ³ Autor ³ Emerson Campos                    ³ Data ³ 08/01/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Anexos do candidato Campos Portal                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PWSR040()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Cam.³08/01/2014³                ³ Criacao do cadastro Anexos Campos Portal.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³                ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PWSR040()	//RHCurriculum -> GetSchedule

	Local cHtml := ""
	Local oObj   
	Local oObjCfg                                            

	Private	cTtlLogin	:= STR0003 //'Documentos Anexos do Candidato'
	Private nCurrentPage
		   
	If Empty(HttpSession->GetCurriculum) .OR. Empty(HttpSession->GetCurriculum[1]:cCurriculum)
		WEB EXTENDED INIT cHtml
			oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())

			WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")
			oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
			cPaisLoc:=oObjCfg:cGETPARAMRESULT
			
			oObj := WSRHCURRICULUM():New()
			WsChgURL(@oObj,"RHCURRICULUM.APW")     
			
			// NÃO É NECESSÁRIO A CRIPTOGRAFIA POIS O CPF E SENHA AINDA NÃO FORAM DIGITADOS.
			HttpSession->cCurricCpf 	:= Iif(Empty(HttpSession->cCurricCpf), DECODE64(""), DECODE64(HttpSession->cCurricCpf))
			HttpSession->cCurricPass 	:= Iif(Empty(HttpSession->cCurricPass), DECODE64(""), DECODE64(HttpSession->cCurricPass))
			
			cHtml += ExecInPage( "PWSR040" )
		WEB EXTENDED END
	Else
		W_PWSR040A()	
	EndIf	

Return cHtml


Web Function PWSR040A()	//RHCurriculum -> GetSchedule

	Local cHtml := ""
	Local oObj
	Local oObjCurr
	Local lLoginOk	:= .F. 	

	HttpSession->nPageLength	:= PAGE_LENGTH
	HttpSession->FiltroAnexo	:= ''
	HttpSession->FiltroField	:= ''
	HttpSession->aAnexos		:= {}

	WEB EXTENDED INIT cHtml
			
		oObjCurr := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oObjCurr,"RHCURRICULUM.APW")
			
		If Empty(HttpSession->GetCurriculum) .OR. Empty(HttpSession->GetCurriculum[1]:cCurriculum) 
			If !Empty(HttpPost->cCurricCpf) 
		 
				HttpSession->cCurricCpf 	:= ENCODE64(HttpPost->cCurricCpf)
				HttpSession->cCurricPass 	:= ENCODE64(HttpPost->cCurricPass)
				
				If oObjCurr:GetCurriculum( "MSALPHA", HttpPost->cCurricCpf, HttpPost->cCurricPass, 2 )
					HttpSession->GetCurriculum 	:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC1}
					HttpSession->GetTables 		:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC2}
					lLoginOk	:= .T.
				Else
					lLoginOk	:= .F.
					HttpSession->cCurricCpf		:= ''
					HttpSession->cCurricPass	:= ''
					HttpSession->GetCurriculum	:= {}
					HttpSession->ShowVacancy	:= {}
					HttpSession->oRequests 		:= {}
					
					Return RHALERT( "", STR0003, STR0021, "W_PWSR000.APW" ) //"Lista de anexos"###"Curric. invalido"
				EndIf		
			Else
				lLoginOk	:= .F.
				Return RHALERT( " ", STR0003, STR0038, "W_PWSR040.APW" ) //"Lista de anexos"###"CPF deve ser informado."
			EndIf
		Else
			lLoginOk	:= .T.
		EndIf
			
			                      	
		If lLoginOk				
			oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
			WsChgURL(@oObj,"RHCURRICULUM.APW")
		    
			Default HttpSession->aAnexos := {}
						
			oObj:cBranch	 	:= HttpSession->GetCurriculum[1]:cBranch
			oObj:cCurricCode	:= HttpSession->GetCurriculum[1]:cCurriculum
			oObj:nCurrentPage 	:= If(type("HttpPost->cCurrentPage") =="U", 1, val(HttpPost->cCurrentPage) )
			
			If !Empty(HttpPost->cFilterValue)
				oObj:cFilterValue			:= HttpPost->cFilterValue
				oObj:cFilterField			:= HttpPost->cFilterField
				HttpSession->FiltroAnexo	:= HttpPost->cFilterValue
				HttpSession->FiltroField	:= HttpPost->cFilterField 
			EndIf
			
			If oObj:GetInfoAnexo()				
				HttpSession->aAnexos	:= oObj:OWSGETINFOANEXORESULT:OWSITENS:OWSTOBJECTLIST				
				HttpSession->nPageTotal	:= oObj:OWSGETINFOANEXORESULT:NPAGESTOTAL				
				HttpSession->cPatch		:= oObj:OWSGETINFOANEXORESULT:CPATHANEXO
				HttpSession->cExtPer	:= oObj:OWSGETINFOANEXORESULT:cExtPer 
				
				
				If !Empty(HttpPost->cCurrentPage)
					If Val(HttpPost->cCurrentPage) > 0 .AND. Val(HttpPost->cCurrentPage) <= HttpSession->nPageTotal 
						HttpSession->nCurrentPage	:= Val(HttpPost->cCurrentPage)
						HttpSession->CurrentPage	:= HttpSession->nCurrentPage
					Else
						HttpSession->nCurrentPage	:= HttpSession->CurrentPage
					EndIf
				Else
					HttpSession->nCurrentPage	:= 1	
				EndIf
				
			Else
				HttpSession->_HTMLERRO := { STR0022, PWSGetWSError(), "W_PWSR040.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf				
	
			cHtml := ExecInPage( "PWSR040A" )
		Else
			conout( PWSGetWSError() )			
		EndIf
	WEB EXTENDED END			
Return cHtml  


Web Function PWSR040B()
Local cHtml 	:= ""
Local oObjCurr
Private cNewNameFile	:= ''
	WEB EXTENDED INIT cHtml  
	                       
		oObjCurr := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oObjCurr,"RHCURRICULUM.APW") 
		oObjCurr:cCurricCode		:= httpPost->CodCurric
		oObjCurr:cPatchObject		:= httpPost->txtFile
		oObjCurr:cDescObject		:= httpPost->tpDescObject
		
		If oObjCurr:SetAnexo( )
			cNewNameFile	:= oObjCurr:CSETANEXORESULT
			W_PWSR040A()
		Else
			conout( PWSGetWSError() )
			HttpSession->_HTMLERRO := { STR0022, PWSGetWSError(), "W_PWSR040A.APW" }			//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
		
	WEB EXTENDED END			
Return cHtml

Web Function PWSR040C()
Local cHtml 	:= ""
Local oObjCurr
Private cFileDel	:= ''
	WEB EXTENDED INIT cHtml  
		oObjCurr := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oObjCurr,"RHCURRICULUM.APW") 
		oObjCurr:cBranch		:= httpPost->cBranch
		oObjCurr:cCodObj		:= httpPost->cCodObj
		oObjCurr:cFilEnt		:= httpPost->cFilEnt
		oObjCurr:cCodEnt		:= httpPost->cCodEnt
		
		If oObjCurr:DelAnexo( )
			cFileDel	:= httpPost->cObject 
			W_PWSR040A()
		Else
			conout( PWSGetWSError() )
			HttpSession->_HTMLERRO := { STR0022, PWSGetWSError(), "W_PWSR040A.APW" }			//"Erro"
			Return ExecInPage("PWSAMSG" )		
		EndIf
		
	WEB EXTENDED END
Return cHtml
