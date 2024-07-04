#INCLUDE "TBICONN.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PONI080.CH"

#DEFINE PONTO_JORNADA		"1"
#DEFINE PONTO_INTERVALO	"2"
#DEFINE PONTO_LANCHE		"3"
#DEFINE POSICAO_TIPO	1
#DEFINE POSICAO_INI 	2
#DEFINE POSICAO_FIM 	3

#DEFINE SEND_SCHEDULE_SEQUENCIA  	1
#DEFINE SEND_SCHEDULE_TIPODIA  	2
#DEFINE SEND_SCHEDULE_HORARIOS  	3

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Integdef  ∫Autor  ≥Microsiga           ∫ Data ≥  27/03/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Mensagem ⁄Nica cadastro de Hor·rio Padr„o  				    ∫±±
±±∫          ≥                                             				    ∫±±
±±∫          ≥                                                		  	    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PONI080                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function PONI080( cXML, nTypeTrans, cTypeMessage, cVersao )

Local cVerTratadas 	:= "1.000|"
Local lRet			:= .T.

Local cDesc		  	:= ""           //DescriÁ„o

Local cTurnExt		:= ""           //Codigo Externo do Turno de Trabalho
Local nHorDes		:= ""           //Hora de Descanso
Local nHorReg		:= ""           //Hora Regular
Local nComSeq		:= ""           //Dia da Semana de Inicio da Sequencia
Local nCoSequen		:= ""			//Dia da Semana de Inicio da Sequencia para de/para
Local nFimSeq		:= ""           //Dia da Semana de Fim da Sequencia
Local cTipoDia		:= ""           //Tipo de Dia se eh Trabalhada, Compensada ou DSR
Local cTipoHora		:= ""           //Tipo de Hora se eh Intervalo, Jornada ou AlmoÁo
Local nComHora		:= ""           //Hora Inicial de Apontamento
Local nFimHora		:= ""           //Hora Final de Apontamento
Local dDtIniSeq		:= ""			//Data de Inicio da Sequencia
Local cValExt		:= ""
Local cValInt		:= ""
Local cDeParaTemp 	:= ""
Local cKeySPJ		:= ""
Local cXMLRet	  	:= ""
Local cEvento		:= "upsert"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local xAux 			:= Nil
Local aDeParaDias 	:= {}

Local aSchedule		:= {}
Local aHorarios		:= {}
Local aCab			:= {}
Local aCabAlt		:= {}
Local aItem			:= {}
Local aHorasXml 	:= {}

Local nCount		:= 0
Local nI			:= 0
Local nSequencias 	:= 1
Local nOpcx			:= 3

Local oXmlMvInt		:= Nil
Local oXmlBusin		:= Nil
Local oArrSchedule 	:= Nil
Local cChave	:= ''

Static cTurno		:= ""           //Codigo Interno do Turno de Trabalho

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

If nTypeTrans == TRANS_RECEIVE
	
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		If !( cVersao $ cVerTratadas )
		
			lRet := .F.
			cXmlRet := STR0001 // "vers„o n„o tratada pelo adapter"
		
		Else 
			oXmlMvInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
						
				cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				
				oXmlBusin := oXmlMvInt:_TotvsMessage:_BusinessMessage
				
				If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil   
				
					cEvento := Upper( oXmlBusin:_BusinessEvent:_Event:Text )
					
					If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And.;
						XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
						
						cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
					EndIf				
					
					If FindFunction("CFGA070INT")
					
						DbSelectArea('SR6')
						SR6->( DbSetOrder( 1 ) ) // R6_FILIAL+R6_TURNO
						
						DbSelectArea("SPJ")
						SPJ-> (DbSetOrder(1)) // PJ_FILIAL+PJ_TURNO+PJ_SEMANA+PJ_DIA
	 
						If XmlChildEx(oXmlBusin:_BusinessContent, '_WORKSHIFTINTERNALID') <> NIL .And. ;
							!Empty( oXmlBusin:_BusinessContent:_WorkShiftInternalId:Text )
							
							cTurnExt	:= oXmlBusin:_BusinessContent:_WorkShiftInternalId:Text
							cTurno		:= GPEI080Rcv( CFGA070INT( cMarca, 'SR6', 'R6_TURNO', cTurnExt ), { "R6_FILIAL", "R6_TURNO" } ) 
							
							If !Empty( cTurno ) .AND. SR6->( DbSeek( cTurno ) )
								cTurno		:= SR6->R6_TURNO
								Aadd( aCab, { "R6_TURNO", cTurno, NIL })
							Else
								lRet := .F.
								cXMLRet += STR0002 // 'N„o encontrado o codigo do Turno de Trabalho'
							EndIf 
							
							If Empty( cValExt )
								cValExt := cTurnExt
							EndIf
						ElseIf XmlChildEx(oXmlBusin:_BusinessContent, '_WORKSHIFTCODE') <> NIL .And. ;
							!Empty( oXmlBusin:_BusinessContent:_WorkShiftCode:Text )
						
							cTurnExt	:= oXmlBusin:_BusinessContent:_WorkShiftCode:Text
							cTurno		:= GPEI080Rcv( CFGA070INT( cMarca, 'SR6', 'R6_TURNO', cTurnExt ), { "R6_FILIAL", "R6_TURNO" } ) 
							
							If !Empty( cTurno ) .AND. SR6->( DbSeek( cTurno ) )
								cTurno		:= SR6->R6_TURNO
								Aadd( aCab, { "R6_TURNO", cTurno, NIL })
							Else
								lRet := .F.
								cXMLRet += STR0002 // 'N„o encontrado o codigo do Turno de Trabalho'
							EndIf 
							
							If Empty( cValExt )
								cValExt := cTurnExt
							EndIf
						Else
							lRet := .F.
							cXMLRet += STR0003 // 'N„o existe a tag para o turno de trabalho'
						EndIf
						
						If lRet .And. cEvento == "UPSERT"

							If lRet .And. XmlChildEx(oXmlBusin:_BusinessContent, '_STARTDATESCHEDULEWORK') <> NIL
								dDtIniSeq :=  StoD( StrTran( oXmlBusin:_BusinessContent:_StartDateScheduleWork:Text, "-", "" ) )
							Else
								lRet := .F.
								cXmlRet += STR0004 // "Data inicial do horario padr„o deve ser enviado"
							EndIf
							
		  					If lRet .And. XmlChildEx( oXmlBusin:_BusinessContent, "_LISTOFSCHEDULE" ) <> Nil .And. ;
		  						XmlChildEx( oXmlBusin:_BusinessContent:_ListOfSchedule, "_SCHEDULE" ) <> Nil
		  						 
								If ValType(oXmlBusin:_BusinessContent:_ListOfSchedule:_Schedule) <> "A"
									XmlNode2Arr(oXmlBusin:_BusinessContent:_ListOfSchedule:_Schedule, "_Schedule")
								EndIf
								
								oArrSchedule := oXmlBusin:_BusinessContent:_ListOfSchedule:_Schedule
								
								For nCount := 1 To Len(oArrSchedule)
									
									If XmlChildEx( oArrSchedule[nCount], "_STARTSEQUENCE") <> Nil
										nComSeq := Val(oArrSchedule[nCount]:_StartSequence:Text)
										If nCount == 1
											nCoSequen := nComSeq
										EndIf
									Else
										lRet := .F.
										cXMLRet += STR0005 + 'StartSequence' + STR0006 + cValToChar(nCount) // 'N„o existe a Tag ' #### ' no item ' 
										Exit
									EndIf
					
									If XmlChildEx( oArrSchedule[nCount], "_ENDSEQUENCE") <> Nil
										nFimSeq :=  Val(oArrSchedule[nCount]:_EndSequence:Text)
									Else
										nFimSeq := nComSeq
									EndIf
					                    
									If XmlChildEx( oArrSchedule[nCount], "_TYPEOFDAY") <> Nil
										cTipoDia :=  oArrSchedule[nCount]:_TypeofDay:Text
										If cTipoDia == "1"
											cTipoDia := "S"
										ElseIf cTipoDia == "2"
											cTipoDia := "C"
										ElseIf cTipoDia == "3"
											cTipoDia := "D"
										EndIf
									Else
										lRet := .F.
										cXMLRet += STR0005 + 'TypeOfDay' + STR0006 + cValToChar(nCount) // 'N„o existe a Tag ' #### ' no item ' 
										Exit
									EndIf
		
									If XmlChildEx( oArrSchedule[nCount], "_LISTOFSCHEDULEHOUR" ) <> Nil .And. ;
										XmlChildEx( oArrSchedule[nCount]:_ListOfScheduleHour, "_SCHEDULEHOUR" ) <> Nil
		
										If ValType(oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour) <> "A"
											XmlNode2Arr(oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour, "_SCHEDULEHOUR")
										EndIf
									
										For nI:= 1 To Len( oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour )
										
											If XmlChildEx( oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour[nI], "_HOURTYPE" ) <> Nil
												cTipoHora := oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour[nI]:_HourType:Text
											Else
												lRet := .F.
												cXMLRet += STR0005 + ' HourType' + STR0006 + cValToChar(nCount) + "," + cValToChar(nI) // 'N„o existe a Tag ' #### ' no item ' 
												Exit
											EndIf 
												
											If XmlChildEx( oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour[nI], "_STARTHOUR") <> Nil
												nComHora := Val( StrTran( oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour[nI]:_StartHour:Text, ":", "." ) )
											Else
												lRet := .F.
												cXMLRet += STR0005 + ' StartHour' + STR0006 + cValToChar(nCount) + "," + cValToChar(nI) // 'N„o existe a Tag ' #### ' no item '
												Exit
											EndIf         
												
											If XmlChildEx( oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour[nI], "_ENDHOUR") <> Nil
												nFimHora := Val( StrTran( oArrSchedule[nCount]:_ListOfScheduleHour:_ScheduleHour[nI]:_EndHour:Text, ":", "." ) )
											Else
												lRet := .F.
												cXMLRet += STR0005 +' EndHour' + STR0006 + cValToChar(nCount) + "," + cValToChar(nI) // 'N„o existe a Tag ' #### ' no item ' 
												Exit
											EndIf	
											
											If !Empty(cTipoHora) .AND. ; // tipo da hora deve estar preenchido
												( ( !Empty(nComHora) .AND. !Empty(nFimHora) ) .Or. ; // entrada e saÌda diferentes de zero
												  ( Empty(nComHora)  .AND. !Empty(nFimHora) ) .Or. ; // entrada 00h e saÌda diferentes de zero
												  ( !Empty(nComHora) .AND. Empty(nFimHora) ) ) // entrada diferentes de zero e saÌda 00h
												
										    	Aadd ( aHorasXml, { cTipoHora, nComHora, nFimHora } )
											Else
												lRet := .F.
												cXMLRet += STR0007 // 'Houve erro na montagem das Horas de Entrada e Saida'
												Exit
											EndIf
		
										Next nI
									Else
										lRet := .F.
										cXmlRet += STR0008 + "_LISTOFSCHEDULEHOUR/SCHEDULEHOUR " // 'N„o existem as Tags '
										Exit
									EndIf
									
									// Adiciona o n˙mero de estruturas conforme o de-atÈ das sequÍncias
									For nI := nComSeq To nFimSeq
										
										Aadd( aSchedule, { nSequencias, cTipoDia, aClone( aHorasXml ) } )
										nSequencias++
									Next nI
									
									aSize( aHorasXml, 0 )
									
								Next nCount
								
								If lRet .And. !Empty( aSchedule ) 
									
									//-------------------------------------------------------------------
									//  Monta o array para execauto considerando a estrutura lida do Xml
									HorPadrao( dDtIniSeq, aSchedule, @aItem, @lRet, @aDeParaDias )
									
									If Len( aItem ) == 0
										lRet := .F.
										cXmlRet := STR0009 // "Preenchimento dos itens n„o ocorreu com sucesso"
									EndIf 
									
								EndIf
							Else
								lRet := .F.
								cXmlRet := STR0008 + "_LISTOFSCHEDULE/SCHEDULE" // " N„o existem as tags "
							EndIf
						
						EndIf // Fim do teste < cEvent == "UPSERT" >

						If lRet
							
							cValInt := PONI080Rcv( CFGA070INT( cMarca, "SPJ", "PJ_TURNO", cValExt ), { "PJ_FILIAL", "PJ_TURNO", "PJ_SEMANA" } )
			     			
			     			//-----------------------------------------------------------------------
			     			//  Abre a transaÁ„o no Banco antes de realizar a gravaÁ„o e exclus„o 
			     			// dos de-para e dos itens associados aos turno (caso seja alteraÁ„o)
			     			BeginTran()
							
							If ( cEvento == "UPSERT" )
								
								If Empty( cValInt )
								
									nOpcx := 3
				  					AAdd( aCab, { "R6_TURNO" , cTurno, NIL } )
				  					AAdd( aCab, { "PJ_TURNO" , cTurno, NIL } )
				  					
				  					// remove as sequÍncias caso j· exista e n„o tenha de/para
				  					If SPJ->( DbSeek( xFilial("SPJ") + cTurno ) )
				  					
				  						cValInt := SPJ->( PJ_FILIAL + PJ_TURNO )
				  						DelSeqs( @lRet, cValInt, @cXmlRet )
				  						
				  					EndIf
								
								ElseIf ( !Empty( cValInt ) .And. SPJ->( DbSeek( cValInt  ) ) )
					  				
					  				//-----------------------------------------------------
					  				//  Quando È alteraÁaı remove todos os registros anteriores
					  				// para realizar a inclus„o dos recebidos no XML
					  				cValInt := SPJ->( PJ_FILIAL + PJ_TURNO )
					  				
									DelSeqs( @lRet, cValInt, @cXmlRet )
									
									nOpcx	:= 3
				  					AAdd( aCab, { "R6_TURNO", cTurno, NIL } )
				  					AAdd( aCab, { "PJ_TURNO", cTurno, NIL } )
									
								Else
									
									lRet := .F.
									cXmlRet += STR0010 // "CombinaÁ„o de operaÁ„o e chave do registro inv·lidos"
																
								EndIf
							ElseIf !Empty(cValInt) .And. SPJ->( DbSeek( cValInt ) )
								
								nOpcx := 5
				  				//-------------------------------------------------------
				  				//  Remove todas as sequÍncias criadas para aquele turno
				  				cValInt := SPJ->( PJ_FILIAL + PJ_TURNO )
				  				
								DelSeqs( @lRet, cValInt, @cXmlRet )
								
							Else 
							
								lRet := .F.
								cXmlRet += STR0010 // "CombinaÁ„o de operaÁ„o e chave do registro inv·lidos"
													
							EndIf
						Else
						
							lRet := .F.
							cXmlRet += STR0011 // "Processamento n„o ocorreu com sucesso, verifique a mensagem"
						
						EndIf
						
					Else
						lRet   := .F.
						cXMLRet := STR0012 // "Atualize EAI"
					EndIf
				EndIf

				If lRet
					
					If nOpcx <> 5 .And. !Empty(aCab) .AND. !Empty(aItem)
			            
			            // executa sequÍncia a sequÍncia a ser inserida no Protheus
			            For nCount := 1 To Len(aItem)
							
							lMsErroAuto := .F.
							
							MsExecAuto({|x,y,z| PONA080(x,y,z)}, aCab, aItem[nCount], nOpcx)
							
							If lMsErroAuto
								Exit
							EndIf
							
						Next nCount
					EndIf
					
					If lMsErroAuto
						//-----------------------------
						// aborta a transaÁ„o no banco
						DisarmTransaction()
						aErroAuto := GetAutoGRLog()
						
						For nI := 1 To Len( aErroAuto )
						
							xAux := StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nI], CHR(13), ""), CHR(10), ""), "/", ""), ">", ""), "<", "") + "|"
						
						Next nI
		
					Else
						
						// Como a Exclus„o ocorre no geral, envia como chave interna a primeira sequÍncia do turno
						cValInt := PONI080Snd( { cEmpAnt, xFilial("SPJ"), cTurno, "01" } )
						
						If nOpcx <> 5
							
							//----------------------------------------------------------------
							//  Dados ok para gravaÁ„o
							//----------------------------------------------------------------
							cXMLRet := '<ListOfInternalId>'
								cXMLRet += '<InternalId>'
									cXMLRet += '<Name>'+ "SCHEDULEWORK" +'</Name>'
									cXMLRet += '<Origin>'+ cValExt +'</Origin>'
									cXMLRet += '<Destination>'+ cValInt +'</Destination>'
								cXMLRet += '</InternalId>'
							cXMLRet += '</ListOfInternalId>'
							
							CFGA070Mnt( cMarca, "SPJ", "PJ_TURNO", cValExt, cValInt )

							For nCount:= 1 To Len( aDeParaDias )

								cValInt := PI080SndDia( { cEmpAnt, xFilial("SPJ"), cTurno, aDeParaDias[nCount, 1] } )	// Cod. Interno do Turno | Semana | Dia da Semana
								cValExt := cTurnExt  +"|"+ aDeParaDias[nCount, 2] 	// Cod. Externo do Turno | Escala | Dia da Semana

								CFGA070Mnt( cMarca, "SPJ", "PJ_DIA", cValExt, cValInt )
									
							Next nCount
						
						EndIf
					EndIf
					
					//--------------------------
					// Fecha a transaÁ„o no banco
					EndTran()
				EndIf	

			Else
				lRet := .F.
				cXMLRet := STR0013 + cXmlErro + ' | ' + cXmlWarn // 'Xml mal formatado '
			EndIf
		
		EndIf
		
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
		//-----------------------------------------
		//  Trata o retorno da mensagem
		TrataResp( @lRet, @cXmlRet, cXml )
		
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVerTratadas
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND
	
	cValInt := PONI080Snd( { cEmpAnt, xFilial("SPJ"), SPJ->PJ_TURNO, StrZero( 1, TamSX3('PJ_SEMANA')[1] ) } )
	
	If !Inclui .AND. !Altera
		cEvento	:=	"delete"
		
		//-----------------------------------------------
		//  Remove do de/para o principal registro
		CFGA070Mnt( , "SPJ", "PJ_TURNO", , cValInt, .T. )
		
	EndIf
	
	// identifica o segunda-feira da semana atual 
	dDtIniSeq := dDatabase - ( DOW( dDataBase ) - 2 )
	
	//Monta XML de envio de mensagem unica
	cXMLRet := ' <BusinessEvent>'
	cXMLRet +=     '<Entity>ScheduleWork</Entity>'
	cXMLRet +=     '<Event>' + cEvento + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + cValInt + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += ' </BusinessEvent>'
    
	cXMLRet += '<BusinessContent>'
	cXMLRet += '<CompanyId>' + cEmpAnt + '</CompanyId>'
	//cXMLRet += '<BranchId>' + xFilial("SPJ") + '</BranchId>'
	cXMLRet += '<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet += '<WorkShiftCode>' + SPJ->PJ_TURNO + '</WorkShiftCode>'
	cXMLRet += '<WorkShiftInternalId>' + GPEI080Snd( { cEmpAnt, xFilial("SR6"), SPJ->PJ_TURNO } ) + '</WorkShiftInternalId>'
	cXMLRet += '<Description>' + HtmlNoTags(Alltrim( SR6->R6_DESC )) + '</Description>'
	cXMLRet += '<RegularHour>' + cValToChar( SR6->R6_HRNORMA ) + '</RegularHour>'
	cXMLRet += '<RestHour>' + cValToChar( SR6->R6_HRDESC ) + '</RestHour>'
	cXMLRet += '<StartDateScheduleWork>'+ Transform( DTOS( dDtIniSeq ), "@R 9999-99-99" ) +'</StartDateScheduleWork>'
	cXMLRet += '<ListOfSchedule>'

	DbSelectArea("SPJ")
	SPJ->( DbSetOrder( 1 ) ) // PJ_FILIAL+PJ_TURNO+PJ_SEMANA+PJ_DIA
    
    if(cEvento == "delete")    
    	cKeySPJ := SPJ->( xFilial("SPJ")+PJ_TURNO+PJ_SEMANA)
    	SPJ->( DbSeek( cKeySPJ + '1' ) )/*Se posiciona no primeiro dia da sequÍncia*/
    	cChave := 'PJ_TURNO+PJ_SEMANA'	
    Else    	
		cKeySPJ := SPJ->( xFilial("SPJ")+PJ_TURNO)
		SPJ->(DbSeek(cKeySPJ))
		cChave := 'PJ_TURNO'		
    EndIf
    
	nSequencias := 0
	
	While cKeySPJ == SPJ->( xFilial("SPJ")+&(cChave))
		
		aAdd( aSchedule, {} )  // adiciona a estrutura para conter as informaÁıes
		nSequencias++ 
		
		//  identifica o n˙mero do dia que ira representar um item da sequÍncia
		// cria de forma sequencial, conforme os dias da semana sempre comeÁando com o domingo
		// Na primeira semana ser· de 1 a 7...
		// Na segunda semana 8 a 14, pois ( ( ( 02 - 1 ) * 7 ) + 1..7 )
		// transforma a segunda feira no primeiro dia da semana (dia 1 = SEG, dia 7 = DOM)
		xAux := IIF( Val(SPJ->PJ_DIA)-1 == 0, 7, Val(SPJ->PJ_DIA)-1 )
		xAux := ( ( ( Val( SPJ->PJ_SEMANA ) - 1 ) * 7 ) + xAux )
		
		aAdd( aSchedule[ nSequencias ], xAux ) // Adiciona a SequÍncia inicia e final
		
		If SPJ->PJ_TPDIA == "D" // DSR
			xAux := "3"
		ElseIf SPJ->PJ_TPDIA $ "C# #N" // considera compensado "C", n„o trabalhado "N"  e n„o preenchido " "
			xAux := "2"
		Else // Trabalhado
			xAux := "1"
		EndIf
		
		aAdd( aSchedule[ nSequencias ], xAux ) // Adiciona o tipo do dia
		
		// --------------------------------------------
		//  Converte os valores para o formato de saÌda
		aSize( aHorarios, 0 )
		PONExt( aHorarios )
		
		aAdd( aSchedule[ nSequencias ], {} )
		
    		For nI:= 1 To Len(aHorarios)
   				aAdd( aSchedule[ nSequencias, SEND_SCHEDULE_HORARIOS ], ;
   						{ aHorarios[nI][1], ;  // HourType
   						STR( aHorarios[nI][2], 5, 2), ;  // StartHour
   						STR( aHorarios[nI][3], 5, 2) } )  // EndHour
			Next nI

		SPJ->( dbSkip() )

	EndDo
	
	//  ordena pelo numeraÁ„o do dia
	// para que fique de seg(1) a dom(7)
	aSchedule := aSort( aSchedule, , ,{ |x,y| x[1] < y[1] } )
	nSequencias := 0
	
	For nSequencias := 1 To Len ( aSchedule )
	
		cXMLRet += '<Schedule>'
			
			cXMLRet += '<StartSequence>' + cValToChar( aSchedule[ nSequencias, SEND_SCHEDULE_SEQUENCIA ] ) + '</StartSequence>'
			cXMLRet += '<EndSequence>' + cValToChar( aSchedule[ nSequencias, SEND_SCHEDULE_SEQUENCIA ] ) + '</EndSequence>'
			
			cXMLRet += '<TypeOfDay>' + aSchedule[ nSequencias, SEND_SCHEDULE_TIPODIA ] + '</TypeOfDay>'
			cXMLRet += '<ListOfScheduleHour>'

    		For nI:= 1 To Len( aSchedule[ nSequencias, SEND_SCHEDULE_HORARIOS ] ) 
				cXMLRet += '<ScheduleHour>'
					cXMLRet += '<HourType>' + aSchedule[ nSequencias, SEND_SCHEDULE_HORARIOS ][nI][1] +'</HourType>' 
					cXMLRet += '<StartHour>'+ aSchedule[ nSequencias, SEND_SCHEDULE_HORARIOS ][nI][2] +'</StartHour>' 
					cXMLRet += '<EndHour>'  + aSchedule[ nSequencias, SEND_SCHEDULE_HORARIOS ][nI][3] +'</EndHour>' 
				cXMLRet += '</ScheduleHour>'
			Next nI
			
			cXMLRet += '</ListOfScheduleHour>'
		
		cXMLRet += '</Schedule>'
	
	Next nI

	cXMLRet += ' </ListOfSchedule>'
	cXMLRet += '</BusinessContent>'
	
EndIf

cXmlRet:=FWNoAccent(cXmlRet)
cXMLRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet,'SCHEDULEWORK'}

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PONInt    ∫Autor  ≥Microsiga           ∫ Data ≥  08/03/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥FunÁ„o Auxilar para construÁ„o e retirada dos dados do XML  ∫±±
±±∫          ≥ 					  										  ∫±±
±±∫          ≥Passa aCampos e cErroMsg por referencia. lRet .F. quando    ∫±±
±±∫          ≥ houver erro e em cErroMsg a msg de erro.                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PONI090                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function PONInt( aHrs, aHorario, cErroMsg )

Local aBatidas		:= {}
Local aCampos		:= {}

Local nJornada		:= 0
Local nLanche		:= 0
Local nIntervalo	:= 0
Local nI			:= 1
Local nPos  		:= 1
Local nMaxBatidas 	:= 0

Local nHrEntr		:= ""			// Hora de Entrada

Local lRet			:= .T.

DEFAULT cErroMsg := ""

For nI := 1 To Len(aHrs)
	
	If aHrs[nI][POSICAO_TIPO] == PONTO_JORNADA
		nJornada++
		nHrEntr := aHrs[nI][POSICAO_INI]				//Horario de Entrada
		AAdd(aBatidas,{aHrs[nI][POSICAO_INI],"N" } )
		AAdd(aBatidas,{aHrs[nI][POSICAO_FIM],"N" } )

	ElseIf aHrs[nI][POSICAO_TIPO] == PONTO_LANCHE
		nLanche++				
		AAdd(aBatidas,{aHrs[nI][POSICAO_INI],"N" } )
		AAdd(aBatidas,{aHrs[nI][POSICAO_FIM],"N" } )

	ElseIf aHrs[nI][POSICAO_TIPO] == PONTO_INTERVALO
		nIntervalo++
		AAdd(aBatidas,{aHrs[nI][POSICAO_INI],"S" } )
		AAdd(aBatidas,{aHrs[nI][POSICAO_FIM],"N" } )

	EndIf

Next nI

//ValidaÁıes
If nJornada != 1
	lRet := .F.
	cErroMsg := STR0014 + "|" // "Deve ser informado sempre apenas um registro do tipo Jornada."	
EndIf

If nLanche+nIntervalo > 3
	lRet := .F.
	cErroMsg := STR0015 + "|" // "O Microsiga Protheus aceita apenas 4 entradas e saÌdas."
EndIf

If lRet
	// identifica o n˙mero de marcaÁıes para otimizar a iteraÁ„o de indicaÁ„o das entradas e saÌdas
	nMaxBatidas := Len( aBatidas )
	
	// Ordena pelos hor·rios e identifica a primeira entrada
	aBatidas := aSort( aBatidas, , ,{ |x,y| x[1] < y[1] } )
	nPos := aScan( aBatidas, { |x| x[1]==nHrEntr } )

	// percorre a lista
	nI := 1 
	While nI <= ( nMaxBatidas / 2 )
		
		AAdd(aCampos,{ /*1-Entrada*/, /*2-SaÌda*/, /*3-Intervalo*/ } )
	
		aCampos[nI, 1] := aBatidas[nPos][1] //1-Entrada 
		
		If ++nPos > nMaxBatidas
			nPos := 1
		EndIf
		
		aCampos[nI, 2] := aBatidas[nPos][1] //SaÌda
		aCampos[nI, 3] := aBatidas[nPos][2] //Intervalo
		
		If ++nPos > nMaxBatidas
			nPos := 1
		EndIf
		
		nI++
	End 

	For nI := 1 To Len(aCampos)
	
		If nI == 1
			Aadd( aHorario, { "PJ_INTERV1",aCampos[nI][3], Nil })
			Aadd( aHorario, { "PJ_ENTRA1" ,aCampos[nI][1], Nil })
			Aadd( aHorario, { "PJ_SAIDA1" ,aCampos[nI][2], Nil })
		EndIf
		
		If nI == 2
			Aadd( aHorario, { "PJ_INTERV2",aCampos[nI][3], Nil })
			Aadd( aHorario, { "PJ_ENTRA2" ,aCampos[nI][1], Nil })
			Aadd( aHorario, { "PJ_SAIDA2" ,aCampos[nI][2], Nil })
		EndIf
		
		If nI == 3
			Aadd( aHorario, { "PJ_INTERV3",aCampos[nI][3], Nil })
			Aadd( aHorario, { "PJ_ENTRA3" ,aCampos[nI][1], Nil })
			Aadd( aHorario, { "PJ_SAIDA3" ,aCampos[nI][2], Nil })
		EndIf
	
		If nI == 4
			Aadd( aHorario, { "PJ_ENTRA4" ,aCampos[nI][1], Nil })
			Aadd( aHorario, { "PJ_SAIDA4" ,aCampos[nI][2], Nil })
		EndIf
	
	Next nI

EndIf

Return (lRet,aHorario)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PONExt    ∫Autor  ≥Microsiga           ∫ Data ≥  08/03/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥FunÁ„o Auxilar para construÁ„o e retirada dos dados do XML  ∫±±
±±∫          ≥ 					  										  ∫±±
±±∫          ≥Passa aCampos e cErroMsg por referencia. lRet .F. quando    ∫±±
±±∫          ≥ houver erro e em cErroMsg a msg de erro.                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PONI090                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function PONExt( aRet )

Local aHrs := {}

Local nI      := 0
Local nEntra  := 0
Local nSaida  := 0
Local nUltimoInt := 0

Local cInter
Local cTipo := ""

For nI := 1 To 4

	nEntra := SPJ->&("PJ_ENTRA"+cValToChar(nI))
	nSaida := SPJ->&("PJ_SAIDA"+cValToChar(nI))
	
	If nI < 4
		cInter := SPJ->&("PJ_INTERV"+cValToChar(nI))
	Else
		cInter := "N"
	EndIf

	AAdd(aHrs,{nEntra,"N"})
	AAdd(aHrs,{nSaida,cInter})
	
	If ( nSaida <> 0 ) .OR. ( nEntra <> 0 )
		nUltimoInt := Len( aHrs )
	EndIf

Next nI

//----------------------------------------------------------

//  Verifica se houve a configuraÁ„o com intervalos
If nUltimoInt > 0
	//Adiciona a Jornada
	AAdd(aRet,{"1",aHrs[1][1],aHrs[nUltimoInt][1] } )

	For nI := 2 To Len(aHrs)-1 Step 2	

		If aHrs[nI][2] == "S"
			cTipo := "2"
		Else
			cTipo := "3"
		EndIf

		If (aHrs[nI][1] <> 0 .OR. aHrs[nI+1][1] <> 0) .AND. (nI < nUltimoInt)
			AAdd( aRet, { cTipo, aHrs[nI][1], aHrs[nI+1][1] } )
		EndIf
		
	Next nI
Else
	AAdd(aRet,{"1",aHrs[1][1],aHrs[2][1] } )
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} HorPadrao
	Tratamento das sequencias e combinaÁ„o de data do hor·rio padr„o
recebido por xml para o formato de semanas utilizado no protheus 

@since  	16/07/2013
@version  	P11.8
@param  	cDtIni 		- Dia Inicial da sequencia de trabalho
@param  	aSchedule 	- Lista com os dados gerais das sequÍncias
@param  	aItem   	- Array para inclus„o dos dados pela ExecAuto (referÍncia)
@param  	lRet    	- Status do processamento (referÍncia)
/*/
//-------------------------------------------------------------------
Function HorPadrao( dDtIni, aSchedule, aItem, lRet, aDeParaDias )

// vari·veis controle do processamento
Local nX               := 0
Local nY               := 0
Local nZ               := 0
Local nProc            := 0
Local lContinua        := .T.
Local cErroHorarios    := ""

// vari·veis para execuÁ„o da lÛgica
Local nMaxSchedule     := Len( aSchedule )
Local nDiaSemana       := DOW( dDtIni ) 	// dia referÍncia para inclus„o da tab. hor·rio
Local aHorasDia        := {} 	// estrutura com os valores de intervalo e horarios de entrada e saÌda da ExecAuto
Local cSemana          := "" 	// semana em preenchimento no array da ExecAuto

// Identifica o n˙mero de sequÍncia, caso seja m˙ltiplo de 7 gera a qtde multipla
Local nSeq             := If( nMaxSchedule % 7 == 0, nMaxSchedule / 7, nMaxSchedule )

//----------------------------------------------------------------------
//  o formato do aCalend corresponde ao preenchimento dos Ìndices para cada dia da semana
// a definiÁ„o dos dias da semana no calend·rio È na forma natural DOM (coluna 1) a SAB (coluna 7) do array
// mas o preenchimento dos conte˙dos ocorre no formato utilizado pelo ponto eletrÙnico
// considerando o inÌcio na SEG (coluna 2) e fim da semana no DOM (coluna 1)
// Um exemplo para escala com o formato de trabalha e folga, seria o seguinte:
// 1 = trabalho, 2 = folga
//  	S	T	Q	Q	S	S	D
//01	1	2	1	2	1	2	1
//02	2	1	2	1	2	1	2

Local aCalend          := Array( nSeq ) 	// conter· a ordem dos Ìndices/sequÍncias na mensagem e quais dias ser„o no Protheus

Default aItem          := {}

//Monta os hor·rios para inclus„o direta no array dos itens para a ExecAuto, vinculando com o Ìndice do aSchedule
For nY := 1 To Len( aSchedule )

	// Adiciona posiÁıes para amarraÁ„o com o Ìndice lido do XML e 
	// array para divis„o dos hor·rios conforme ser„o adicionados ao Protheus
	aAdd( aHorasDia, { aSchedule[nY, 1], {} } )
	
	// realiza a quabra dos hor·rios conforme os campos
	PONInt( aSchedule[nY, 3], aHorasDia[nY,2], @cErroHorarios )
	
	// verifica se houve erro no processo de divis„o dos hor·rios
	If !Empty( cErroHorarios )
		lRet := .F.
		Exit
	EndIf
	
Next nY

If lRet 
	// Cria calend·rio para as semanas
	For nX := 1 To nSeq
		aCalend[nX] := Array( 7 ) 
	Next nX
	
	//  Preenche o calend·rio com o Ìndice da sequÍncia que deve ser utilizado, 
	//conforme o dia da semana em cada semana/sequencia para o Protheus
	nProc := 1
	nZ := 1
	
	While lContinua
	
		For nY := 1 To 7
			
			aCalend[nProc, nDiaSemana] := aSchedule[nZ, 1] // adiciona o cÛdigo do Ìndice da sequencia ao calend·rio
			
			// caso tenha preenchido o domingo, muda a semana de preenchimento
			// caso a semana ultrapasse o limite de sequÍncias volta para a primeira semana
			If nDiaSemana == 1 .And. ++nProc > nSeq
				nProc := 1
			EndIf
			
			// passa ao proximo dia da semana
			If ++nDiaSemana > 7
				nDiaSemana := 1
			EndIf
			
			// identifica qual item do xml usa como identificador
			If ++nZ > nMaxSchedule
				nZ := 1
			EndIf
			
		Next nY
		
		// Adiciona mais uma sequÍncia ou finaliza o preenchimento da primeira
		lContinua := ( Empty( aCalend[nProc, nDiaSemana] ) .Or. aCalend[nProc, nDiaSemana]==Nil )
		
	End

	nProc := 0
	//Itera sobre o calend·rio preenchendo o array com os itens para a execauto
	For nX := 1 To nSeq
	
		// o array ser· montado com cada semana separada
		// pois a inclus„o ocorre semana a semana
		aAdd( aItem, {} )
		nProc++
		
		cSemana := StrZero( nX, 2 )
		
		// adiciona as informaÁıes relacionadas com os dias da semana
		For nY := 1 To 7
			
			aAdd( aItem[nProc], {} )
			
			aAdd( aItem[nProc, nY], { "PJ_SEMANA" , cSemana                       , Nil } ) // semana da iteraÁ„o
			aAdd( aItem[nProc, nY], { "PJ_DIA"    , cValToChar( nY )              , Nil } ) // Dia da sequencia
			aAdd( aItem[nProc, nY], { "PJ_TPDIA"  , aSchedule[ aCalend[nX, nY], 2 ] , Nil } ) // Tipo do dia da sequencia (Trabalhado, Compensado, DSR)
			
			// Copia as informaÁıes dos intervalos e hor·rios
			For nZ := 1 To Len( aHorasDia[aCalend[nX, nY],2] )
			
				aAdd( aItem[nProc, nY], aClone( aHorasDia[ aCalend[nX, nY], 2, nZ] ) )
			
			Next nZ
			
		Next nY
	Next nX
	
	aDeParaDias := MontaDePara( aCalend )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI080Snd
Rotina para integraÁ„o por EAI 

@since 26/06/2013
@version P11
@param	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PONI080Snd( aTempDados )

Local nZ       := 1
Local cTempKey := ""

Default aTempDados := {}

For nZ := 1 To Len( aTempDados )

	cTempKey += RTrim( aTempDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI080Snd
Rotina para integraÁ„o por EAI 

@since 26/06/2013
@version P11
@param	aTempDados - valor para realizar o tratamento, inserindo pipes 
	na string de retorno
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PI080SndDia( aDados )

Local nZ       := 1
Local cTempKey := ""

DEFAULT aDados := { cEmpAnt, PJ_FILIAL, PJ_TURNO, PJ_SEMANA, PJ_DIA }

For nZ := 1 To Len( aDados )

	cTempKey += RTrim( aDados[nZ] ) + "|"

Next nZ

cTempKey := SubStr( cTempKey, 1, Len( cTempKey ) -1 )
	
Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} PONI080Rcv
Rotina para realizar a separaÁ„o da chave da tabela do conte˙do gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos 

@since 26/06/2013
@version P11
@param	cTmpKeyInt - valor para realizar o tratamento, array para inserir pipes e string
	para remover pipes
@param aCposChave - array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PONI080Rcv( cTmpKeyInt, aCposChave )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

Default cTmpKeyInt := ""
Default aCposChave := {}

xAuxKey := Separa( cTmpKeyInt, "|" )

If ( Len( xAuxKey ) - 1) == Len( aCposChave )
	
	For nZ := 2 To Len( xAuxKey )
	
		cTempKey += PadR( xAuxKey[nZ], TamSX3( aCposChave[nZ-1] )[1] )
	
	Next nZ
EndIf

xAuxKey := aSize( xAuxKey, 0 )

Return cTempKey 

//-------------------------------------------------------------------
/*/{Protheus.doc} PI080RcvDia
Rotina para realizar a separaÁ„o da chave da tabela do conte˙do gravado 
no de/para, removendo os pipes e identificando o tamanho dos campos 

@since 26/06/2013
@version P11
@param	cTmpKeyInt - valor para realizar o tratamento, array para inserir pipes e string
	para remover pipes
@param aCposChave - array contendo os campos para ajuste de tamanho
@return	cTempKey   - chave interna do de/para dividida em pipes

/*/
//-------------------------------------------------------------------
Function PI080RcvDia( cVal, aCampos )

Local cTempKey  := ""
Local xAuxKey   := {}
Local nZ        := 0

DEFAULT cVal := ""
DEFAULT aCampos := { "PJ_FILIAL", "PJ_TURNO", "PJ_SEMANA", "PJ_DIA" }

xAuxKey := StrToKarr( cVal, "|" )

If ( Len( xAuxKey ) - 1) == Len( aCampos )
	
	For nZ := 2 To Len( xAuxKey )
	
		cTempKey += PadR( xAuxKey[nZ], TamSX3( aCampos[nZ-1] )[1] )
	
	Next nZ
EndIf

xAuxKey := aSize( xAuxKey, 0 )

Return cTempKey

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplicaÁ„o destino para gravaÁ„o do De/Para 

@since 26/06/2013
@version P11
@param 	lProcOk 	Status do processamento (referÍncia)
@param 	cMsgRet 	Mensagem de retorno do processamento (referÍncia)
@param 	cXml    	Mensagem da response para tratamento

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
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "SCHEDULEWORK" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil
					
						CFGA070Mnt( cMarca, 'SPJ', 'PJ_TURNO', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )
						
						Exit
					EndIf
				Next nZ
			
			Else
			
				lProcOk := .F.
				cMsgRet := STR0016 // "N„o enviado conte˙do de retorno para cadastro de de-para"
			
			EndIf
			
		Else
			
			lProcOk := .F.
			cMsgRet := STR0017 // "N„o È possÌvel gravar de-para por causa de erro na leitura do retorno"
		
		EndIf
		
	Else
	
		lProcOk 	:= .F.
		cMsgRet 	:= STR0018 + "|" // "Erro no processamento pela outra aplicaÁ„o"
		
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
				cMsgRet := STR0019 // "Erro no processamento, mas sem detalhes do erro pela outra aplicaÁ„o"
				
			EndIf
			
		EndIf
		
	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0020 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para n„o ser· gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaDePara
	Cria array para inserÁ„o no De/Para relacionando a combinaÁ„o de
Ìndice e dia da semana da outra aplicaÁ„o com semana e dia da semana do Protheus 

@since  	26/06/2013
@version 	P11
@param 	aCalendSeqs 	array no formato de calend·rio com os Ìndices recebidos no XML
@return 	aDados  	Lista de array com 2 posiÁıes sendo: 
				1 -> Valor de Semana e Dia no Protheus
				2 -> Õndice/SequÍncia e Dia da Semana do XML
/*/
//-------------------------------------------------------------------
Static Function MontaDePara( aCalendSeqs )

Local aDados := {}
Local nY     := 0
Local nX     := 0
Local cDia   := ""

For nY := 1 To Len( aCalendSeqs )

	For nX := 1 To 7
	
		cDia := cValToChar(nX)
		aAdd( aDados, { StrZero( nY, 2)                   + "|" + cDia , ;  //-->> Valor do Protheus
						cValToChar( aCalendSeqs[nY, nx] ) + "|" + cDia  } ) //-->> Valor da outra aplicaÁ„o
	
	Next nX 

Next nX


Return aClone( aDados )

//-------------------------------------------------------------------
/*/{Protheus.doc} DelSeqs
	Cria array para inserÁ„o no De/Para relacionando a combinaÁ„o de
Ìndice e dia da semana da outra aplicaÁ„o com semana e dia da semana do Protheus 

@since  	26/06/2013
@version 	P11
@param  	lStatus 	situaÁ„o do processamento
@param  	cSPJChave 	chave atÈ semana para exclus„o de todas as semanas
@return 	lStatus 	situaÁ„o final do processamento
/*/
//-------------------------------------------------------------------
Static Function DelSeqs( lStatus, cSPJChave, cXmlRet )

Local aCab          := {}
Local aItem         := {}
Local cDeParaTemp   := ""
Local nItem         := 0
Local cSPJChaveItem := ""
Local aRemoveDePara := {}
Local aErroAuto     := {}
Local nI            := 0

SPJ->( DbSeek( cSPJChave ) )

SR6->( DbSeek( xFilial("SR6")+SPJ->PJ_TURNO ) )

While SPJ->( DbSeek( cSPJChave ) )
	AAdd( aCab, { "R6_FILIAL", SR6->R6_FILIAL, NIL } )
	AAdd( aCab, { "R6_TURNO" , SR6->R6_TURNO , NIL } )

	AAdd( aCab, { "PJ_FILIAL", SPJ->PJ_FILIAL, NIL } )
	AAdd( aCab, { "PJ_TURNO" , SPJ->PJ_TURNO , NIL } )
	AAdd( aCab, { "PJ_SEMANA", SPJ->PJ_SEMANA, NIL } )
	
	// constroi o de/para do registro para realizar a remoÁ„o
	cDeParaTemp := PI080SndDia( { cEmpAnt, SPJ->PJ_FILIAL, SPJ->PJ_TURNO, SPJ->PJ_SEMANA, SPJ->PJ_DIA } )
	
	While SPJ->( PJ_FILIAL + PJ_TURNO ) == cSPJChave
		aAdd( aItem, {} )
		nItem++
		
		AAdd( aItem[nItem],{ "PJ_FILIAL", SPJ->PJ_FILIAL, NIL } )
		AAdd( aItem[nItem],{ "PJ_TURNO" , SPJ->PJ_TURNO , NIL } )
		AAdd( aItem[nItem],{ "PJ_SEMANA", SPJ->PJ_SEMANA, NIL } )
		AAdd( aItem[nItem],{ "PJ_DIA"   , SPJ->PJ_DIA   , NIL } )
		AAdd( aItem[nItem],{ "PJ_TPDIA" , SPJ->PJ_TPDIA , NIL } )
		
		SPJ->( DbSkip() )
	End
  	
	MsExecAuto( { |x, y, z| PONA080(x, y, z)}, aCab, aItem, 5 )
	
	If lMsErroAuto
		lStatus := .F.
		DisarmTransaction()
		
		aErroAuto := GetAutoGRLog()
		
		For nI := 1 To Len( aErroAuto )
			cXmlRet := StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nI], CHR(13), ""), CHR(10), ""), "/", ""), ">", ""), "<", "") + "|"
		Next nI
		
		cXmlRet += STR0021 + "|" // "N„o foi possÌvel excluir os registros j· existentes no hor·rio padr„o"
		Exit
	EndIf
	
	For nItem := 1 To Len( aItem )
		
		cDeParaTemp := PI080SndDia( { cEmpAnt, aItem[nItem, 1, 2], aItem[nItem, 2, 2], aItem[nItem, 3, 2], aItem[nItem, 4, 2] } )
		
		// Remove do de/para valor relacionado com o dia
		CFGA070Mnt( , "SPJ", "PJ_DIA", , cDeParaTemp, .T. )
	Next nItem
	
	// remove do de/para valor relacionado com o turno
	cDeParaTemp := PONI080Snd( { cEmpAnt, aCab[3, 2], aCab[4, 2], aCab[5, 2] } )
	CFGA070Mnt( , "SPJ", "PJ_TURNO", , cDeParaTemp, .T. )
	
	SPJ->( DbSkip( ) )
	
	aSize( aCab , 0 )
	aSize( aItem, 0 )
	nItem := 0
End

Return lStatus