#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "GPEI050.CH"
#INCLUDE "FWMVCDEF.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MATI240   ∫Autor  ≥Microsiga           ∫ Data ≥  09/11/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao de integracao com o adapter EAI para recebimento e  ∫±±
±±∫          ≥ envio de informaÁıes do cadastro de Provisıes			  ∫±±
±±∫          ≥ (SRF) utilizando o conceito de mensagem unica. 		      ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEA050                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function GPEI050( cXML, nTypeTrans, cTypeMessage, cVersao )

Local lRet			:= .T.
Local cXMLRet	  	:= ""
Local cEvento		:= "UPSERT"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local cValExt		:= ""
Local cValInt		:= ""
 			
Local cCodFunEx		:= "" 
Local cCodFun	  	:= "" 
Local cDtBaFe	  	:= "" 
Local cDaComFe1	  	:= "" 
Local cDiaFer1	  	:= ""  
Local cBonFer1	  	:= ""  
Local cDaComFe2	  	:= "" 
Local cDiaFer2	  	:= ""  
Local cBonFer2	  	:= ""  
Local cDaComFe3	  	:= "" 
Local cDiaFer3	  	:= ""  
Local cBonFer3	  	:= ""  
Local cLogErro  	:= ""

Local aErroAuto		:= {}
Local aFerias		:= {}
Local aArea			:= GetArea()
Local aAux  		:= {}

Local nCount		:= 0
Local nOpcx			:= 0

Local oXmlTMess	:= Nil
Local oXmlBusin	:= Nil
Local cVersoesOk	:= "1.000|2.000"
Local oActModel	:= Nil
Local oObjTemp	:= Nil
Local nI := 0
Local aLinha	:= {}
Local aHead	:= {} 
Local aCodFol	:= {}
Local lIsDelete:= .F.
Local nDelLines := 0
Default cVersao := "1.000"
Private lMsErroAuto 	:= .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

If nTypeTrans == TRANS_RECEIVE
	
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		Altera	:= .F.
		Inclui	:= .F.
		
		oXmlTMess	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
		
		If oXmlTMess <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)					
			
			cMarca := Upper(AllTrim(oXmlTMess:_TotvsMessage:_MessageInformation:_Product:_Name:Text)) 
			
			oXmlBusin := oXmlTMess:_TotvsMessage:_BusinessMessage
			
			If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil  
				
				cEvento := Upper(AllTrim(oXmlBusin:_BusinessEvent:_Event:Text))
				
				If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. ;
					 XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
					
					cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
					
				ElseIf XmlChildEx(oXmlBusin:_BusinessContent, '_INTERNALID') <> Nil
					
					cValExt := oXmlBusin:_BusinessContent:_InternalId:Text
					
				Else
					lRet := .F.
					cXmlRet := STR0001 // "Chave do registro n„o enviada"
				EndIf
				
				If lRet .And. !Empty( cValExt )
					if(cVersao == '1.000')		
						cValInt := GPEI050Rcv( CFGA070INT( cMarca, "SRF", "RF_MAT", cValExt ), { "RF_FILIAL", "RF_MAT", "RF_DATABAS" } )
					ElseIf (cVersao == '2.000')
						cValInt := GPEI050Rcv( CFGA070INT( cMarca, "SRF", "RF_MAT", cValExt ), { "RF_FILIAL", "RF_MAT"} )
					EndIf					
					
					If ( Upper( cEvento ) == "UPSERT" )				
						If ( !Empty(cValInt) .And. SRF->( DbSeek( cValInt  ) ) ) 
							nOpcx	:= 4 
							Altera	:= .T.
						Else
							nOpcx	:= 3
							Inclui	:= .T.													
						EndIf    
					ElseIf  (cEvento == "DELETE" )  
						Return { .F., STR0011 } //N„o permitida a exclus„o da programaÁ„o de fÈrias via mensagem ˙nica.					
					EndIf
				
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_INTERNALID') <> NIL
						cCodFunEx	:= oXmlBusin:_BusinessContent:_InternalId:Text
						aAux 	:= IntFunInt( cCodFunEx, cMarca, "2.003")
						
						If aAux[1]
							cCodFun := aAux[2][2]+aAux[2][3]
							
							DbSelectArea('SRA')
							SRA->( DbSetOrder( 1 ) )
							
							If !Empty( cCodFun ) .AND. SRA->(DbSeek( cCodFun ) )
								cCodFun := SRA->RA_MAT 
								AAdd( aFerias, { "RF_FILIAL", xFilial('SRF')	, Nil } )
								AAdd( aFerias, { "RF_MAT"	, cCodFun			, Nil } )
								
								If (Fp_CodFol(@aCodFol,xFilial('SRV')))									
									AAdd( aFerias, { "RF_PD"		, aCodFol[72,1]	, Nil } )
								Else
									AAdd( aFerias, { "RF_PD"		, Space(TamSx3('RF_PD')[1])	, Nil } )
								EndIf								
							Else
								lRet := .F.
								cXmlRet := STR0003 + cCodFun // "Codigo do funcionario n„o cadastrado " 
							EndIf
						Else
							lRet := .F.
							cXmlRet := aAux[2]
						EndIf
						
					Else
						lRet := .F.
						cXMLRet := STR0004 + "InternalId" // "N„o existe a Tag "
					EndIf
				EndIf
									                                				
				If lRet
					
					if(cVersao == '1.000')
						
						If XmlChildEx(oXmlBusin:_BusinessContent, '_VACATIONBASEDATE') <> NIL
							cDtBaFe := STOD( StrTran( SubStr( oXmlBusin:_BusinessContent:_VacationBaseDate:Text, 1, 10), "-", "" ) )
							AAdd( aFerias, { "RF_DATABAS", cDtBaFe, Nil })
							AAdd( aFerias, { "RF_DATAFIM", cDtBaFe+ 365, Nil })
						Else
							lRet := .F.
							cXMLRet := STR0004 + "VacationBaseDate" // "N„o existe a Tag "
						EndIf	
						
						lRet := (XmlChildEx(oXmlBusin:_BusinessContent, '_STARTDATEOFVACATION1') <> NIL)				 
						If lRet 
							cDaComFe1 := STOD( StrTran( SubStr( oXmlBusin:_BusinessContent:_StartDateofVacation1:Text, 1, 10), "-", "" ) )
							AAdd( aFerias, { "RF_DATAINI", cDaComFe1, Nil })
						Else							
							cXMLRet := STR0004 + "StartDateofVacation1" // "N„o existe a Tag "
						EndIf
						
						lRet := (XmlChildEx(oXmlBusin:_BusinessContent, '_VACTIONDAY1') <> NIL)
						If lRet 
							cDiaFer1 := oXmlBusin:_BusinessContent:_VactionDay1:Text
							  // Atribui para n„o ter problema quando for ocorrer validaÁ„o de conte˙do
							AAdd( aFerias, { "RF_DFEPRO1", Val( cDiaFer1 ), Nil })
						Else							
							cXMLRet := STR0004 + "VactionDay1" // "N„o existe a Tag "
						EndIf						
						
						lRet := (XmlChildEx(oXmlBusin:_BusinessContent, '_VACATIONBONUSDAYS1') <> NIL)
						If lRet
							cBonFer1	:= oXmlBusin:_BusinessContent:_VacationBonusDays1:Text
							AAdd( aFerias, { "RF_DABPRO1", Val( cBonFer1 ), Nil })
						Else
							lRet := .F.
							cXMLRet := STR0004 + "VacationBonusDays1" // "N„o existe a Tag "
						EndIf						
						
						If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_STARTDATEOFVACATION2') <> NIL
							cDaComFe2	:= STOD( StrTran( SubStr( oXmlBusin:_BusinessContent:_StartDateofVacation2:Text, 1, 10), "-", "" ) ) 
						EndIf
		
						If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_VACTIONDAY2') <> NIL
							cDiaFer2	:= oXmlBusin:_BusinessContent:_VactionDay2:Text 
						EndIf
						If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_VACATIONBONUSDAYS2') <> NIL
							cBonFer2	:= oXmlBusin:_BusinessContent:_VacationBonusDays2:Text 
						EndIf
						
						If !( Empty( cDaComFe2 ) .And. Empty( cDiaFer2 ) .And. Empty( cBonFer2 ) )
							AAdd( aFerias, { "RF_DATINI2", cDaComFe2, Nil })
							AAdd( aFerias, { "RF_DFEPRO2", Val(cDiaFer2), Nil })
							AAdd( aFerias, { "RF_DABPRO2", Val(cBonFer2), Nil })
						EndIf
						//----------- TERCEIRA PROGRAMA«√O -----------------------
						If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_STARTDATEOFVACATION3') <> NIL
							cDaComFe3	:= STOD( StrTran( SubStr( oXmlBusin:_BusinessContent:_StartDateofVacation3:Text, 1, 10), "-", "" ) ) 
						EndIf
						If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_VACTIONDAY3') <> NIL
							cDiaFer3	:= oXmlBusin:_BusinessContent:_VactionDay3:Text 
						EndIf
						If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_VACATIONBONUSDAYS3') <> NIL
							cBonFer3	:= oXmlBusin:_BusinessContent:_VacationBonusDays3:Text 
						EndIf
						If !( Empty( cDaComFe3 ) .And. Empty( cDiaFer3 ) .And. Empty( cBonFer3 ) )
							AAdd( aFerias, { "RF_DATINI3", cDaComFe3, Nil })
							AAdd( aFerias, { "RF_DFEPRO3", Val(cDiaFer3), Nil })
							AAdd( aFerias, { "RF_DABPRO3", Val(cBonFer3), Nil })
						EndIf
						aLinha	:= aClone(aFerias)
						aFerias:= {}
						aAdd(aFerias,aLinha)					
					ElseIf (cVersao == '2.000')
						lRet := XmlChildEx( oXmlBusin:_BusinessContent, "_LISTOFVACATIONSCHEDULE" ) <> Nil			
						
						if(lRet)						
							lRet := XmlChildEx(oXmlBusin:_BusinessContent:_ListOfVacationSchedule,"_VACATIONID") <> Nil
							
							if(lRet)
								If ValType(oXmlBusin:_BusinessContent:_ListOfVacationSchedule:_VacationId) <> "A"
									XmlNode2Arr(oXmlBusin:_BusinessContent:_ListOfVacationSchedule:_VacationId, "_VACATIONID")
								EndIf
								
								oObjTemp := oXmlBusin:_BusinessContent:_ListOfVacationSchedule:_VacationId							
								
								aHead	:= aClone(aFerias)
								aFerias:= {}
								for nI:= 1 to Len(oObjTemp)									
									aLinha := aClone(aHead)									
									
									lRet := XmlChildEx(oObjTemp[nI], '_VACATIONBASEDATE') <> NIL									
									If lRet										
										cDtBaFe := SubStr(oObjTemp[nI]:_VacationBaseDate:Text, 1, 10)
										cDtBaFe := StrTran(cDtBaFe, "-", "")
										cDtBaFe := StoD(cDtBaFe)
										AAdd(aLinha,{ "RF_DATAFIM"	, cDtBaFe + 364 	, Nil })
										AAdd(aLinha,{"RF_DATABAS"	, cDtBaFe			, Nil })										
									Else										
										cXMLRet := STR0004 + "VacationBaseDate" // "N„o existe a Tag "
									EndIf								
												 
									If lRet .And. XmlChildEx(oObjTemp[nI], '_STARTDATEOFVACATION1') <> NIL
										cDaComFe1 := SubStr( oObjTemp[nI]:_StartDateofVacation1:Text, 1, 10)
										cDaComFe1 := StrTran(cDaComFe1 , "-", "" )
										cDaComFe1 := StoD(cDaComFe1)
										AAdd(aLinha, {"RF_DATAINI", cDaComFe1, Nil})
									Else
										lRet := .F.
										cXMLRet := STR0004 + "StartDateofVacation1" // "N„o existe a Tag "
									EndIf
									
									If lRet .And. XmlChildEx(oObjTemp[nI], '_VACTIONDAY1') <> NIL
										cDiaFer1 := oObjTemp[nI]:_VactionDay1:Text									
										AAdd(aLinha, { "RF_DFEPRO1", Val( cDiaFer1 ), Nil })
									Else
										lRet := .F.
										cXMLRet := STR0004 + "VactionDay1" // "N„o existe a Tag "
									EndIf
									If lRet .And. XmlChildEx(oObjTemp[nI], '_VACATIONBONUSDAYS1') <> NIL
										cBonFer1	:= oObjTemp[nI]:_VacationBonusDays1:Text
										AAdd(aLinha, { "RF_DABPRO1", Val( cBonFer1 ), Nil })
									Else
										lRet := .F.
										cXMLRet := STR0004 + "VacationBonusDays1" // "N„o existe a Tag "
									EndIf
									
									If lRet .And. XmlChildEx(oObjTemp[nI], '_STARTDATEOFVACATION2') <> NIL
										cDaComFe2	:= SubStr(oObjTemp[nI]:_StartDateofVacation2:Text, 1, 10)
										cDaComFe2	:= StrTran(cDaComFe2, "-", "" )
										cDaComFe2	:= StoD(cDaComFe2) 
									EndIf
					
									If lRet .And. XmlChildEx(oObjTemp[nI], '_VACTIONDAY2') <> NIL
										cDiaFer2	:= oObjTemp[nI]:_VactionDay2:Text 
									EndIf
									
									If lRet .And. XmlChildEx(oObjTemp[nI], '_VACATIONBONUSDAYS2') <> NIL
										cBonFer2	:= oObjTemp[nI]:_VacationBonusDays2:Text 
									EndIf
									
									If !( Empty( cDaComFe2 ) .And. Empty( cDiaFer2 ) .And. Empty( cBonFer2 ) )
										AAdd( aLinha, { "RF_DATINI2", cDaComFe2		, Nil })
										AAdd( aLinha, { "RF_DFEPRO2", Val(cDiaFer2)	, Nil })
										AAdd( aLinha, { "RF_DABPRO2", Val(cBonFer2)	, Nil })
									EndIf
									
									If lRet .And. XmlChildEx(oObjTemp[nI], '_STARTDATEOFVACATION3') <> NIL
										cDaComFe3	:= SubStr(oObjTemp[nI]:_StartDateofVacation3:Text, 1, 10)
										cDaComFe3	:= StrTran(cDaComFe3, "-", "")
										cDaComFe3	:= StoD(cDaComFe3) 
									EndIf
									If lRet .And. XmlChildEx(oObjTemp[nI], '_VACTIONDAY3') <> NIL
										cDiaFer3	:= oObjTemp[nI]:_VactionDay3:Text 
									EndIf									
									If lRet .And. XmlChildEx(oObjTemp[nI], '_VACATIONBONUSDAYS3') <> NIL
										cBonFer3	:= oObjTemp[nI]:_VacationBonusDays3:Text 
									EndIf
									
									If !( Empty( cDaComFe3 ) .And. Empty( cDiaFer3 ) .And. Empty( cBonFer3 ) )
										AAdd( aLinha, { "RF_DATINI3", cDaComFe3		, Nil })
										AAdd( aLinha, { "RF_DFEPRO3", Val(cDiaFer3)	, Nil })
										AAdd( aLinha, { "RF_DABPRO3", Val(cBonFer3)	, Nil })
									EndIf
									
									if !(lRet)
										EXIT
									endIf
									
									aAdd(aFerias,aLinha)									
									aLinha := {}
								next nI								
							Else								
								cXMLRet := STR0004 + "VacationId"
							endIf							
						Else
							cXMLRet := STR0004 + "ListOfVacationSchedule"					
						endIf						
					EndIf					
				EndIf			
			EndIf
						
			If lRet
				BeginTran()
								
				GPEI050Cad(aFerias,nOpcx)			

				If lMsErroAuto
					DisarmTransaction()
					aErroAuto := GetAutoGRLog()
					
					For nCount := 1 To Len(aErroAuto)
						cLogErro += StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ) + ("|")
					Next nCount
					
					lRet	 := .F.
					cXMLRet := EncodeUTF8( cLogErro )
	
				Else
					
     				cValInt := GPEI050Snd( { cEmpAnt, xFilial("SRF"), cCodFun, cDtBaFe } )
				
					If nOpcx <> 5 
						
						CFGA070Mnt( cMarca, "SRF", "RF_MAT", cValExt, cValInt )
						
						//----------------------------------------------------------------
						//  Dados ok para gravaÁ„o
						//----------------------------------------------------------------
						cXMLRet := '<ListOfInternalId>'
						cXMLRet += 	'<InternalId>'
						cXMLRet += 		'<Name>'+ "VACATIONSCHEDULE" +'</Name>'
						cXMLRet += 		'<Origin>'+ cValExt +'</Origin>'
						cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
						cXMLRet += 	'</InternalId>'
						cXMLRet += '</ListOfInternalId>'
						
					Else
						CFGA070Mnt( , "SRF", "RF_MAT", , cValInt, .T. )
					EndIf                     
					
					EndTran()
				EndIf
			EndIf
		Else
			lRet := .F.
			cXMLRet := STR0010 + cXmlErro + '| ' + cXmlWarn  // 'Xml mal formatado '
		EndIf
		
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		
		If FindFunction("CFGA070Mnt")
			
			//-------------------------------------------------------------
			//   Trata o retorno da response para gravaÁ„o do de/para
			TrataResp( @lRet, @cXmlRet, cXml )
			
		EndIf
		
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVersoesOk
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND
	
	if(cVersao == '1.000')		
		cValInt := GPEI050Snd( { cEmpAnt, xFilial("SRF"), SRF->RF_MAT, DTOS(SRF->RF_DATABAS) } )
	ElseIf (cVersao == '2.000')
		cValInt := GPEI050Snd( { cEmpAnt, xFilial("SRF"), SRF->RF_MAT } )
	EndIf	
	
	If !Inclui .AND. !Altera
		cEvento	:=	"Delete"	
		// Remove o De/Para quando È exclus„o
		CFGA070Mnt( , "SRF", "RF_MAT", , cValInt, .T. )		
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>VacationSchedule</Entity>'
	cXMLRet +=     '<Event>' + cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet += 		'<CompanyId>'+ cEmpAnt +'</CompanyId>'
	//cXMLRet += 		'<BranchId>'+ xFilial("SRF") +'</BranchId>'
	cXMLRet += 		'<BranchId>'+ cFilAnt +'</BranchId>'
	cXMLRet += 		'<CompanyInternalId></CompanyInternalId>' 

	cXMLRet += 		'<EmployeeCode>'+ SRF->RF_MAT +'</EmployeeCode>'
	cXMLRet += 		'<InternalId>'+ IntFunExt( , , SRF->RF_MAT, "2.000")[2] +'</InternalId>'
	if(cVersao == '1.000')		
		If !Empty( SRF->RF_DATABAS )
			cXMLRet += 	'<VacationBaseDate>'+ Transform( DtoS(SRF->RF_DATABAS), "@R 9999-99-99") +'</VacationBaseDate>'
		Else
			cXMLRet += '<VacationBaseDate></VacationBaseDate>'
		EndIf

		If !Empty( SRF->RF_DATAINI )
			cXMLRet += '<StartDateofVacation1>'+ Transform( DtoS(SRF->RF_DATAINI), "@R 9999-99-99") +'</StartDateofVacation1>'  
			cXMLRet += '<VactionDay1>'+ CValToChar(SRF->RF_DFEPRO1) +'</VactionDay1>'         
			cXMLRet += '<VacationBonusDays1>'+ CValToChar(SRF->RF_DABPRO1) +'</VacationBonusDays1>'
		EndIf        
		
		If !Empty( SRF->RF_DATINI2 )
			cXMLRet += '<StartDateofVacation2>'+ Transform( DtoS(SRF->RF_DATINI2), "@R 9999-99-99") +'</StartDateofVacation2>'
			cXMLRet += '<VactionDay2>'+ CValToChar(SRF->RF_DFEPRO2) +'</VactionDay2>'	
			cXMLRet += '<VacationBonusDays2>'+ CValToChar(SRF->RF_DABPRO2) +'</VacationBonusDays2>'
		EndIf		
		
		If !Empty( SRF->RF_DATINI3 )
			cXMLRet += '<StartDateofVacation3>'+ Transform( DtoS(SRF->RF_DATINI3), "@R 9999-99-99") +'</StartDateofVacation3>'
			cXMLRet += '<VactionDay3>'+ CValToChar(SRF->RF_DFEPRO3) +'</VactionDay3>'
			cXMLRet += '<VacationBonusDays3>'+ CValToChar(SRF->RF_DABPRO3) +'</VacationBonusDays3>'
		EndIf
	ElseIf(cVersao == '2.000')
		
		cXMLRet += '<ListOfVacationSchedule>'
		
		if(IsInCallStack("GPEA050"))
			oActModel	:=	FWModelActive()
		Else
			oActModel := FwLoadModel("GPEA050")
			oActModel:SetOperation(MODEL_OPERATION_UPDATE)
			oActModel:Activate()
		endIf		
		
		oActModel	:=	oActModel:GetModel("GPEA050_SRF")
		
		For nI := 1 To oActModel:Length()
			oActModel:GoLine(nI)				
			
			If !oActModel:IsDeleted()	
				cXMLRet += '<VacationId>'				
				
				If !Empty( oActModel:GetValue("RF_DATABAS") )
					cXMLRet += 	'<VacationBaseDate>'+ Transform( DtoS(oActModel:GetValue("RF_DATABAS")), "@R 9999-99-99") +'</VacationBaseDate>'
				Else
					cXMLRet += '<VacationBaseDate></VacationBaseDate>'
				EndIf
								
				If !Empty( oActModel:GetValue("RF_DATAINI") )
					cXMLRet += '<StartDateofVacation1>'+ Transform( DtoS(oActModel:GetValue("RF_DATAINI")), "@R 9999-99-99") +'</StartDateofVacation1>'					
					cXMLRet += '<VactionDay1>'+ CValToChar(oActModel:GetValue("RF_DFEPRO1")) +'</VactionDay1>'					
					cXMLRet += '<VacationBonusDays1>'+ CValToChar(oActModel:GetValue("RF_DABPRO1")) +'</VacationBonusDays1>'
				EndIf        
				
				If !Empty(oActModel:GetValue("RF_DATINI2"))
					cXMLRet += '<StartDateofVacation2>'+ Transform( DtoS(oActModel:GetValue("RF_DATINI2")), "@R 9999-99-99") +'</StartDateofVacation2>'					
					cXMLRet += '<VactionDay2>'+ CValToChar(oActModel:GetValue("RF_DFEPRO2")) +'</VactionDay2>'					
					cXMLRet += '<VacationBonusDays2>'+ CValToChar(oActModel:GetValue("RF_DABPRO2")) +'</VacationBonusDays2>'
				EndIf		
				
				If !Empty( oActModel:GetValue("RF_DATINI3"))					
					cXMLRet += '<StartDateofVacation3>'+ Transform( DtoS(oActModel:GetValue("RF_DATINI3")), "@R 9999-99-99") +'</StartDateofVacation3>'					
					cXMLRet += '<VactionDay3>'+ CValToChar(oActModel:GetValue("RF_DFEPRO3")) +'</VactionDay3>'					
					cXMLRet += '<VacationBonusDays3>'+ CValToChar(oActModel:GetValue("RF_DABPRO3")) +'</VacationBonusDays3>'
				EndIf
				
				cXMLRet += '</VacationId>'			
			Else
				nDelLines++
			EndIf
		Next nI		
		
		lIsDelete := (nDelLines == oActModel:Length())
		
		if(lIsDelete)
			cXMLRet:= strTran(cXMLRet, '<ListOfVacationSchedule>', '<ListOfVacationSchedule/>')
			cXMLRet:= strTran(cXMLRet, cEvento, 'DELETE')			
		Else		
			cXMLRet += '</ListOfVacationSchedule>'		
		endIf
		
	endIf
	 	    
	cXMLRet += '</BusinessContent>'
	
EndIf

RestArea(aArea)

cXMLRet := EncodeUTF8(cXMLRet)

Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI050Snd
Rotina para integraÁ„o por EAI 

@since 26/06/2013
@version P11
@param	aTempDados - valor para realizar o tratamento, inserindo pipes	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function GPEI050Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := { cEmpAnt, RF_FILIAL, RF_MAT, RF_DATABAS }

For nZ := 1 To Len( aTempDados )

	If ValType(aTempDados[nZ])=="D"
		cTempKey += DtoS( aTempDados[nZ] ) + "|"
	Else
		cTempKey += RTrim( aTempDados[nZ] ) + "|"
	EndIf

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey )-1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEI050Rcv
Rotina para realizar a separaÁ„o da chave da tabela do conte˙do gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos
@since 26/06/2013
@version P11
@param	cTmpKeyInt, valor para realizar o tratamento, array para inserir pipes e string para remover pipes
@param aCposChave, array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes
/*/
//-------------------------------------------------------------------
Function GPEI050Rcv( cTmpKeyInt, aCposChave )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

Default cTmpKeyInt := ""
Default aCposChave := { "RF_FILIAL", "RF_MAT", "RF_DATABAS" }

xAuxKey := Separa( cTmpKeyInt, "|" )

If ( Len( xAuxKey ) - 1) == Len( aCposChave )
	
	For nZ := 2 To Len( xAuxKey )
	
		cTempKey += PadR( xAuxKey[nZ], TamSX3( aCposChave[nZ-1] )[1] )
	
	Next nZ
EndIf

xAuxKey := aSize( xAuxKey, 0 )

Return cTempKey 

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplicaÁ„o destino para gravaÁ„o do De/Para 

@since 26/06/2013
@version P11
@param 	lProcOk, 	Status do processamento (referÍncia)
@param 	cMsgRet, 	Mensagem de retorno do processamento (referÍncia)
@param 	cXml,   	Mensagem da response para tratamento
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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "VACATIONSCHEDULE" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SRF', 'RF_MAT', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0005 // "N„o enviado conte˙do de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0006 // "N„o È possÌvel gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0007 + "|" // "Erro no processamento pela outra aplicaÁ„o"
		
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
				cMsgRet := STR0008 // "Erro no processamento, mas sem detalhes do erro pela outra aplicaÁ„o"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0009 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para n„o ser· gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return

/*/{Protheus.doc} GPEI050Cad
	Chama o ExecAuto da GPEA050
@author philipe.pompeu
@since 23/04/2015
@version P12
@param aFerias, Vetor, vetor com os dados das fÈrias
@param nOpcx, numÈrico, OperaÁ„o ‡ ser feita
@return Nil, valor nulo
/*/
Function GPEI050Cad(aFerias,nOpcx)
	Local aAreas	:= {SRF->(GetArea()),SRA->(GetArea())}
	Local oModel		:= Nil
	Local oSubModel	:= Nil
	Local nI 	:= 0
	Local nJ 	:= 0
	Local nK	:= 0
	Local nPos		:= 0
	Local cCampo	:= ''
	Local xValor	:= Nil
	Local cFil	:= ''
	Local cMat	:= '' 
	Local oStruct	:= Nil
	Local aCampos	:= {}
	Local lEdicao	:= .F.
	Private aRotina		:= FWLoadMenuDef( "GPEA050")
	Private lInitDesc		:= .F.
	Private lGp050Auto 	:= .T.
	
	If Type("lMsErroAuto") == "U"
		Private lMsErroAuto:= .F.
	EndIf	
			
	if (Len(aFerias) > 0)
		nPos := AScan (aFerias[1], {|x|x[1]=='RF_FILIAL'})		
		if(nPos > 0)
			cFil := aFerias[1,nPos,2]
			
		endIf
		nPos := aScan (aFerias[1], {|x|x[1]=='RF_MAT'})		
		if(nPos > 0)
			cMat := aFerias[1,nPos,2]			
		endIf
		
		if !(Empty(cFil) .And. Empty(cMat))
			
			dbSelectArea("SRA")
			SRA->(dbSetOrder(1))
			
			if(SRA->(dbSeek(cFil + cMat)))				
				oModel 	:= FWLoadModel("GPEA050")
				oModel:SetOperation(4)
				oModel:Activate()
				oSubModel	:= oModel:GetModel("GPEA050_SRF")
				oStruct	:= oSubModel:GetStruct()	
				aCampos	:= oStruct:GetFields()
				
				//DELETO TODOS OS CAMPOS QUE N√O ESTIVEREM NA ESTRUTURA
				//PREVENINDO QUALQUER TIPO DE ERRO
				for nI:= 1 to Len(aFerias)					
					for nJ:= 1 to Len(aFerias[nI])							
						nPos := AScan (aCampos, {|x|x[3] == aFerias[nI,nJ,1]})							
						if !(nPos > 0)
							aDel(aFerias[nI],nJ)
							aSize(aFerias[nI],Len(aFerias[nI]) - 1)
						endIf				
					next nJ					
				next nI				
				
				lMsErroAuto := .F.
								
				for nJ:= 1 to Len(aFerias)							
					nPos  := AScan (aFerias[nJ], {|x|x[1] == 'RF_DATABAS' })										
													
					if(nPos > 0)						
						
						lEdicao := (oSubModel:SeekLine({{'RF_DATABAS',aFerias[nJ,nPos,2]}})) 
						
						if(!lEdicao)
							oSubModel:AddLine()																
						EndIf
												
						for nK:= 1 to Len(aFerias[nJ])										
							cCampo := aFerias[nJ,nK,1]
							xValor := aFerias[nJ,nK,2]																			
							
							if(lEdicao)
								if!(cCampo $"RF_FILIAL|RF_MAT|RF_PD|RF_DATABAS")
									oSubModel:LoadValue(cCampo,xValor)	
								endIf									
							Else
								oSubModel:LoadValue(cCampo,xValor)	
							endIf							
															
						next nK
																					
					endIf											
				next nJ					
							
				FWFormCommit(oModel)							
			endIf			
		endIf		
	endIf
		
	aEval(aAreas,{|x|RestArea(x)})
Return nil