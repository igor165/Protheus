#INCLUDE "PROTHEUS.CH"       
#INCLUDE "TMKA510K.CH"

Static aResultado:= {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA510K      ºAutor³Vendas Clientes   º Data ³  25/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Reprogramação da data de prazo do SLA, influenciando no    º±±
±±º          ³Call Center, Controle de não conformidades e Gestao de Proj.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function TK510kReclass(cCodChamado) 
Local aAreaADE 	:= ADE->(GetArea())
Local aArea		:= GetArea()
Local lRestM	:= .F.    
Local lRet		:= .F.
Local dUltPrazo := Date()
Local cUltHr	:= "00:00"

If !Empty(cCodChamado)
	DbSelectArea("ADE")
	DbSetOrder(1)
	If DbSeek( xFilial("ADE")+cCodChamado ) .AND. !Empty(ADE->ADE_REGSLA)
		If 	Type("M->ADE_CODIGO") == "U" .OR.; 
			(Type("M->ADE_CODIGO") <> "U" .AND. M->ADE_CODIGO <> cCodChamado)		
	
			If 	Type("M->ADE_CODIGO") <> "U" .AND.; 
				M->ADE_CODIGO <> cCodChamado
				
				lRestM := .T.
			EndIf
			RegToMemory("ADE", .F.)		                                     		
		EndIf           
		aResultado := {}
		If TMKA510Dialog(@aResultado)          

			dUltPrazo := ADE->ADE_DTEXPI
			cUltHr := ADE->ADE_HREXPI

			If	IsInCallStack("TMKA503A") .OR.;
				IsInCallStack("TMKA510A") 						

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui uma nova interação no chamado    ³
				//³e aguarda que o usuário grave o chamado ³
				//³para realizar a reprogramação do prazo. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk510IncAcols("TMK006", STR0001 + CRLF + STR0002 + DtoC(dUltPrazo) + " " + cUltHr + CRLF + STR0003 + DtoC(aResultado[1]) + " " + cUltHr, "") // "Reprogramação do prazo de SLA. " # " Prazo anterior:" # " Novo Prazo:"
			Else                                            			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui a nova interação no chamado   ³
				//³e grava imediatamente a reprogramação³
				//³do prazo.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TkUpdCall(	/*cFil*/,;
							""/*cCodAction*/,;
							/*cCodReview*/,;	
							STR0001 + CRLF + STR0002 + DtoC(dUltPrazo) + " " + cUltHr + CRLF + STR0003 + DtoC(aResultado[1]) + " " + cUltHr,; // "Reprogramação do prazo de SLA. " # " Prazo anterior:" #  " Novo Prazo:"
							/*cTPACAO*/,;	
							TkOperador(),;	
							Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;		
							"",;
							/*dPrazo*/,;		
							Date(),;		
							cCodChamado,;
							"TMK006")				
			EndIf
			lRet := .T.
		Else
			aResultado := {}	
		EndIf
	Else
		If Empty(ADE->ADE_REGSLA)
			MsgInfo(STR0004) // "Este chamado não possui um prazo de SLA definido, não podendo ser reprogramado."
		EndIf
	EndIf
EndIf
     
RestArea(aAreaADE) 
If lRestM
	RegToMemory("ADE", .F.)		                                     		
EndIf
RestArea(aArea)
Return lRet          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA510Dialog ºAutor³Vendas Clientes   º Data ³  25/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a interface para seleçao dos novos dados.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Static Function TMKA510Dialog(aInfo)
Local lRet := .T.   
Local dNewDate	 := Date()    
Local nOpcSev	 := 1                 
Local aComboBx1	 := TkSx3Box("ADE_SEVCOD")
Local cComboBx1
Local cTimeSLA	 := "00:00"
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local nSizeSev	:= TamSx3("ADE_SEVCOD")[1]
Local bValidOri := Posicione("SX3", 2, "ADE_CODORI", "X3_VALID") + " .OR. VAZIO()"
Local bValidEfe := Posicione("SX3", 2, "ADE_CODEFE", "X3_VALID") + " .OR. VAZIO()"
Local bValidCau := Posicione("SX3", 2, "ADE_CODCAU", "X3_VALID") + " .OR. VAZIO()"
Local bValidCat := Posicione("SX3", 2, "ADE_CODCAT", "X3_VALID") + " .OR. VAZIO()"

Private cCODOri	 := Space(25)
Private cCODEfe	 := Space(25)
Private cCODCau	 := Space(25)
Private cCodCat	 := Space(25)  

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

If !Empty(ADE->ADE_CODORI)
	cCODOri := ADE->ADE_CODORI
EndIf  
If !Empty(ADE->ADE_CODEFE)  
	cCODEfe := ADE->ADE_CODEFE
EndIf     
If !Empty(ADE->ADE_CODCAU)
	cCODCau := ADE->ADE_CODCAU
EndIf   
If !Empty(ADE->ADE_CODCAT)
	cCodCat := ADE->ADE_CODCAT
EndIf       
If !Empty(ADE_HREXPI)
	cTimeSLA  := ADE->ADE_HREXPI
EndIf

DEFINE MSDIALOG oDlg TITLE STR0005 FROM C(178),C(181) TO C(590),C(432) PIXEL // "Reprogramação do prazo de SLA"

	oDlg:lEscClose := .F.

	// Cria Componentes Padroes do Sistema
	@ C(005),C(007) Say STR0006 Size C(075),C(121) COLOR CLR_BLACK PIXEL OF oDlg // "Selecione um novo prazo para o SLA:"
	
	@C(013),C(007) SCROLLBOX oScr1 SIZE C(059),C(118)
	
	oCalend1:=MsCalend():New(02,02,oScr1)
	oCalend1:dDiaAtu := dDataBase + 1		
	
	@ C(073),C(007) MSGET oGetTime Var cTimeSLA SIZE C(060),C(009) COLOR CLR_BLACK PICTURE PesqPict("ADE", "ADE_HREXPI") 	OF oDlg Pixel VALID AtVldHora(cTimeSLA) WHEN .F. 
	
	@ C(085),C(007) Say STR0007 Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg // "Criticidade:"
	@ C(090),C(007) ComboBox oCritic Var cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
	oCritic:nAt := aScan(aComboBx1, {|x| Left(x, nSizeSev)==ADE->ADE_SEVCOD})	
	
	@ C(100),C(007) Say STR0008 Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg // "Origem:"
	@ C(108),C(007) MSGET oGet1 Var cCODOri SIZE C(060),C(009) COLOR CLR_BLACK PICTURE PesqPict("ADE", "ADE_CODORI") 	OF oDlg Pixel F3 X3F3("ADE_CODORI")		VALID &(bValidOri) 
	
	@ C(120),C(007) Say STR0009 Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg // "Efeitos:"
	@ C(128),C(007) MSGET oGet2	 Var cCODEfe SIZE C(060),C(009) COLOR CLR_BLACK PICTURE PesqPict("ADE", "ADE_CODEFE") 	OF oDlg Pixel F3 X3F3("ADE_CODEFE") 		VALID &(bValidEfe)

	@ C(140),C(007) Say STR0010 Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg // "Categoria:"
	@ C(148),C(007) MSGET oGet3 Var cCodCat	 SIZE C(060),C(009) COLOR CLR_BLACK PICTURE PesqPict("ADE", "ADE_CODCAT") 	OF oDlg Pixel F3 X3F3("ADE_CODCAT") 		VALID &(bValidCat)

	@ C(160),C(007) Say STR0011 Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg // "Causa:"
	@ C(168),C(007) MSGET oGet4 Var cCODCau		SIZE C(060),C(009) COLOR CLR_BLACK PICTURE PesqPict("ADE", "ADE_CODCAU") 	OF oDlg Pixel F3 X3F3("ADE_CODCAU") 		VALID &(bValidCau)

	@ C(190),C(037) Button STR0012 Size C(037),C(012) PIXEL OF oDlg ACTION (lRet:= IIf(oCalend1:dDiaAtu > ddatabase,(oDlg:End(),nOpcSev:=oCritic:nAt,dNewDate:=oCalend1:dDiaAtu,.T.),(MsgInfo(STR0014),.F.))) // "OK" # "Selecione uma data superior a data atual."
	@ C(190),C(077) Button STR0013 Size C(037),C(012) PIXEL OF oDlg ACTION (lRet:= .F.,oDlg:End()) // "Cancela"


ACTIVATE MSDIALOG oDlg CENTERED  

If lRet
	
	aAdd(aInfo, dNewDate)
	aAdd(aInfo, Left(aComboBx1[nOpcSev], nSizeSev))
	aAdd(aInfo, cCODOri)
	aAdd(aInfo, cCODEfe)
	aAdd(aInfo, cCodCat)
	aAdd(aInfo, cCODCau)
EndIf

Return lRet               

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510KRepro   ºAutor³Vendas Clientes   º Data ³  25/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Reprograma a nova data do SLA.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Static Function TK510KRepro(aResult)      
Local cGrupo 		:= ""
Local oSLARegist	:= SLARegister():New()	// Objeto SLARegister
Local cTimeShift	:= ""					// Turno de trabalho do grupo de atendimento
Local nTimeElapsed	:= 0 
Local aChamRel		:= {}
Local lCompSLA		:= SuperGetMV("MV_TMKASLA",,0) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Utiliza o Grupo atual do chamado, caso não exista ³
//³utiliza do operador atual.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(ADE->ADE_GRUPO)
	cGrupo := ADE->ADE_GRUPO
Else	
	cGrupo := Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO") 
EndIf         

DbSelectArea("SU0")
DbSetOrder(1) 
If DbSeek( xFilial("SU0") + cGrupo)
	If !Empty(SU0->U0_TURNO)
		cTimeShift 	:= SU0->U0_TURNO
	EndIf		
EndIf

If oSLARegist:load(ADE->ADE_REGSLA)
	If cTimeShift == Nil .Or. Empty(cTimeShift)
	 	cTimeShift := oSLARegist:getTimeShift(oSLARegist:SlaFound)	
	EndIf	
	
	oDTStart 		:= TMKDateTime():this(oSLARegist:dateToExpire, oSLARegist:hourToExpire)
	oDTFinished 	:= TMKDateTime():this(aResult[1], oSLARegist:hourToExpire) 
	nTimeElapsed 	:= oSLARegist:getTimeElapsed(oDTStart, oDTFinished, cTimeShift)

	oSLARegist:dateToExpire := aResult[1]
	oSLARegist:save()
EndIf 

DbSelectArea("ADE")
BEGIN TRANSACTION
	RecLock("ADE", .F.)
	REPLACE ADE_DTEXPI WITH oSLARegist:dateToExpire 
	REPLACE ADE_SEVCOD WITH aResult[2]
	REPLACE ADE_CODORI WITH aResult[3]
	REPLACE ADE_CODEFE WITH aResult[4]
	REPLACE ADE_CODCAT WITH aResult[5]
	REPLACE ADE_CODCAU WITH aResult[6]
	MsUnlock()      
END TRANSACTION	

If lCompSLA
	aChamRel := Tk510ChFilho(ADE->ADE_CODIGO)
	Tk510UpdFilho(aChamRel,ADE->ADE_REGSLA,.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza FNC e Tarefas (Se houver)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(ADE->ADE_FNC)
	TK510KQNC(aResult, nTimeElapsed, oSLARegist, cTimeShift)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510KQNC     ºAutor³Vendas Clientes   º Data ³  25/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Reprograma a nova data do SLA para ficha de não conformida-º±±
±±º          ³-de do QNC e tarefas do PMS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Static Function TK510KQNC(aResult, nTimeElapsed, oSLARegist, cTimeShift)
Local aAreaQI2 	:= QI2->(GetArea()) 
Local aAreaQI3	:= QI3->(GetArea()) 
Local aAreaQI5	:= QI5->(GetArea()) 
Local aAreaAF9	:= AF9->(GetArea()) 
Local aAreaAFA	:= AFA->(GetArea()) 
Local dPrazo 	:= Date()				// Novo prazo de execução
Local nQTMKPMS  := SuperGetMv("MV_QTMKPMS",.F.,1) // Integração TMK x QNC x PMS
Local oDTStart

If nQTMKPMS >= 2
	DbSelectArea("QI2")
	DbSetOrder(2)	// QI2_FILIAL+QI2_FNC+QI2_REV
	If 	DbSeek( ADE->ADE_FNCFIL + ADE->ADE_FNC + ADE->ADE_FNCREV ) .AND.;
		QI2->QI2_STATUS $ "123"	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o prazo da Ficha de não-conformidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BEGIN TRANSACTION
			RecLock("QI2", .F.) 
			REPLACE QI2_CONPRE WITH aResult[1]
			REPLACE QI2_CODORI WITH aResult[3]
			REPLACE QI2_CODEFE WITH aResult[4]
			REPLACE QI2_CODCAT WITH aResult[5]
			REPLACE QI2_CODCAU WITH aResult[6]		
			MsUnlock()      
		END TRANSACTION	
	
		DbSelectArea("QI3")	
		DbSetOrder(2)
		If DbSeek( xFilial("QI3") + QI2->QI2_CODACA + QI2->QI2_REVACA )	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o prazo do Plano de Ação da FNC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BEGIN TRANSACTION
				RecLock("QI3", .F.) 
				REPLACE QI3_ENCPRE WITH aResult[1]	
				MsUnlock()      
			END TRANSACTION
			
			DbSelectArea("QI5")
			DbSetOrder(1) // QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ
			If DbSeek( xFilial("QI5") + QI3->QI3_CODIGO + QI3->QI3_REV )
				While 	QI5->(!Eof()) .AND.;          
						QI5->QI5_FILIAL == 	xFilial("QI5") .AND.;
						QI5->QI5_CODIGO == 	QI3->QI3_CODIGO .AND.;
						QI5->QI5_REV	== 	QI3->QI3_REV  
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o prazo de cada etapa do Plano de Ação³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oDTStart 	:= TMKDateTime():this(QI5->QI5_PRAZO, oSLARegist:hourToExpire)
					dPrazo 		:= oSLARegist:getExpireDateTime(oDTStart, cTimeShift, nTimeElapsed) 					
					BEGIN TRANSACTION					
				        RecLock("QI5", .F.)
				   		REPLACE QI5->QI5_PRAZO WITH dPrazo:getDate()
						MsUnlock()      
					END TRANSACTION			   		
					
					If nQTMKPMS > 3
						DbSelectArea("AF9")
						DbSetOrder(6) // AF9_FILIAL+AF9_FNC+AF9_REVFNC+AF9_TPACAO				
						If DbSeek( xFilial("AF9") +  ADE->ADE_FNC + ADE->ADE_FNCREV + QI5->QI5_TPACAO)
							 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualiza a tarefa do Projeto³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							BEGIN TRANSACTION					
						        RecLock("AF9", .F.)    
								oDTStart 	:= TMKDateTime():this(AF9->AF9_START, oSLARegist:hourToExpire)
								dPrazo 		:= oSLARegist:getExpireDateTime(oDTStart, cTimeShift, nTimeElapsed) 							
						   		REPLACE AF9->AF9_START WITH dPrazo:getDate()
								oDTStart 	:= TMKDateTime():this(AF9->AF9_FINISH, oSLARegist:hourToExpire)
								dPrazo 		:= oSLARegist:getExpireDateTime(oDTStart, cTimeShift, nTimeElapsed) 																					   		
						   		REPLACE AF9->AF9_FINISH WITH dPrazo:getDate()				   		
								MsUnlock()      
							END TRANSACTION
							
							DbSelectArea("AFA")
							DbSetOrder(1)
							DbSeek( xFilial("AFA") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA )
							While 	AFA->(!Eof()) .AND.; 
									AFA->AFA_FILIAL == xFilial("AFA") .AND.;
									AFA->AFA_PROJET == AF9->AF9_PROJET .AND.;
									AFA->AFA_REVISA == AF9->AF9_REVISA .AND.;
									AFA->AFA_TAREFA == AF9->AF9_TAREFA
			
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Atualiza os recursos da tarefa do Projeto (SIGAPMS)³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								BEGIN TRANSACTION					
							        RecLock("AFA", .F.)   							        
									oDTStart 	:= TMKDateTime():this(AFA->AFA_DATPRF, oSLARegist:hourToExpire)
									dPrazo 		:= oSLARegist:getExpireDateTime(oDTStart, cTimeShift, nTimeElapsed) 																					   		
							   		REPLACE AFA->AFA_DATPRF WITH dPrazo:getDate()				   		
									MsUnlock()      
								END TRANSACTION						
								AFA->(DbSkip())		
							End										   						
						EndIf 
					EndIf     				
					QI5->(DbSkip())		
				End		
			EndIf
		EndIf    	
	EndIf 
EndIf

RestArea(aAreaQI2)
RestArea(aAreaQI3)
RestArea(aAreaQI5)
RestArea(aAreaAF9)
RestArea(aAreaAFA)
Return .T.                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510kSave    ºAutor³Vendas Clientes   º Data ³  30/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a gravação dos novos dados do SLA do chamado.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function TK510kSave()
If Len(aResultado) >= 6 
	TK510KRepro(aResultado)
	aResultado := {}
EndIf
Return .T.
