#INCLUDE "QADA280.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 

//----------------------------------------------------------------
/*/{Protheus.doc} QADA280
Encerramento de Auditorias
@author Geovani.Figueira
@since 23/08/2017
@version 1.0
@return NIL
/*/
//----------------------------------------------------------------
FUNCTION QADA280()
	LOCAL aArea   := GetArea()
	LOCAL oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("QUB")
	oBrowse:SetDescription(STR0001) // Encerramento de Auditorias
	oBrowse:AddLegend( "QUB_STATUS=='1'", "GREEN" , STR0004 ) // Sem Resultado
	oBrowse:AddLegend( "QUB_STATUS=='2'", "YELLOW", STR0005 ) // Resultados Parcialmente Respondido
	oBrowse:AddLegend( "QUB_STATUS=='3'", "BLACK" , STR0006 ) // Liberada para Encerramento
	oBrowse:AddLegend( "QUB_STATUS=='4'", "RED"   , STR0007 ) // Encerrada
	oBrowse:Activate()
	
	RestArea(aArea)
	
RETURN Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Geovani.Figueira
@since 23/08/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
STATIC FUNCTION MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'QADA280VIS' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'QADA280ENC' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Encerrar
RETURN aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Geovani.Figueira
@since 23/08/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
STATIC FUNCTION ModelDef()
	LOCAL oStruQUB := FWFormStruct(1,"QUB")
	LOCAL oModel   := NIL
	
	oStruQUB:SetProperty( 'QUB_ENCREA', MODEL_FIELD_OBRIGAT, .T. )
	oStruQUB:SetProperty( 'QUB_CONCLU', MODEL_FIELD_OBRIGAT, .T. )
	
	// Alterações de dicionário necessárias para que a tela normal e a MVC rodem ao mesmo tempo.
	oStruQUB:SetProperty("QUB_NUMAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_NUMAUD" , "ExistChav('QUB',M->QUB_NUMAUD,1,'AUDJAEXIST') .And. QA250chkAg() .And. FreeForUse('QUB',M->QUB_NUMAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_INIAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_INIAUD" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_ENCAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_ENCAUD" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_ENCREA" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_ENCREA" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCREA)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_FILMAT" , "QVldUsuQUB()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_AUDLID" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_AUDLID" , "QVldUsuQUB()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_CODFOR" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_CODFOR" , "Q250VldCpo()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_LOJA"   , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_LOJA"   , "Q250VldCpo()",.F.,.F. ))
	
	oStruQUB:SetProperty("QUB_ENCREA", MODEL_FIELD_INIT, Nil)
	//-----------------------------
	
	FWMemoVirtual( oStruQUB,{ { 'QUB_DESCHV' , 'QUB_DESCR1' } , { 'QUB_CHAVE' , 'QUB_CONCLU' }, { 'QUB_SUGCHV' , 'QUB_SUGOBS' }  } )
	
	oModel := MPFormModel():New( 'QADA280', , ,{|oModel|QADA280GRV(oModel)} )
	oModel:SetDescription(STR0001)
	oModel:AddFields( 'QUBMASTER', /*cOwner*/, oStruQUB )
	oModel:GetModel( 'QUBMASTER' ):SetDescription(STR0001)
		
RETURN oModel


//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Geovani.Figueira
@since 23/08/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
STATIC FUNCTION ViewDef()
	LOCAL oModel   := FWLoadModel('QADA280')
	LOCAL oStruQUB := FWFormStruct(2,'QUB',{|cCampo| !ALLTRIM(cCampo) $ "QUB_FILIAL|QUB_DESCHV|QUB_CHAVE|QUB_SUGCHV|QUB_OK|QUB_STATUS"})
	LOCAL oView	
	
	oStruQUB:SetProperty( 'QUB_ENCREA', MVC_VIEW_ORDEM , '11' )	
	oStruQUB:SetProperty( '*'         , MVC_VIEW_CANCHANGE, .F. )
	oStruQUB:SetProperty( 'QUB_ENCREA', MVC_VIEW_CANCHANGE, .T. )
	oStruQUB:SetProperty( 'QUB_CONCLU', MVC_VIEW_CANCHANGE, .T. )
	oStruQUB:SetProperty( 'QUB_SUGOBS', MVC_VIEW_CANCHANGE, .T. )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_QUB', oStruQUB, 'QUBMASTER' )
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView( 'VIEW_QUB', 'TELA' )
	
RETURN oView


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA280VIS()
Visualizar 
@author Geovani.Figueira
@since 24/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA280VIS()	
	
	IF EMPTY(QUB->QUB_ENCREA)
		IF !QADCkAudit(QUB->QUB_NUMAUD)
			RETURN NIL
		ENDIF
	ENDIF
	
	FWExecView(STR0002,'QADA280',MODEL_OPERATION_VIEW,,{ || .T. }) // Visualizar
	
RETURN


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA280ENC()
Encerrar Auditoria
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
FUNCTION QADA280ENC()
	LOCAL oModel
	LOCAL nMin       := 0
	LOCAL nMax       := 0
	LOCAL nPeso      := 0
	LOCAL nNota      := 0
	LOCAL nPonObt    := 0
	LOCAL nPontos    := 0
	LOCAL nSemAval   := 0
	LOCAL nPesoTotal := 0
	LOCAL cSeek      := ""
	LOCAL cTxtEvi    := ""
	LOCAL cChave     := ""
	LOCAL lAltern    := .F.
	LOCAL lContinua  := .T.
	LOCAL lVerEvid   := GetMv("MV_QADEVI") //Indica se as Evidencias devem ser obrigatorias
	LOCAL lQstZer    := GetMv("MV_QADQZER",.T.,.T.)
	PRIVATE lIntQNC  := GetMv("MV_QADQNC") //Integracao com o QNC
	
	IF !QADCkAudit(QUB->QUB_NUMAUD)
		RETURN .F.
	ENDIF
	
	IF !EMPTY(QUB->QUB_ENCREA)
		HELP(" ",1,"AUDITENC") // A auditoria selecionada encontra-se encerrada
		RETURN .F.
	ENDIF
	
	// Verifica os Parametros de Integracao QNC
	IF lIntQNC .AND. !QNCMSGERA(STR0008) //"no Parametro MV_QADQNC"
		RETURN .F.
	ENDIF
	
	QAA->(dbSetOrder(1))
	QAA->(dbSeek(QUB->QUB_FILMAT+QUB->QUB_AUDLID))
	IF QAA->(!Eof())
		IF UPPER(QAA->QAA_LOGIN) # UPPER(cUserName)
			HELP("",1,"Q140AUDLID")
			RETURN .F.
		ENDIF
	ENDIF
	
	IF ExistBlock("QAD140AT")
		IF !ExecBlock("QAD140AT",.F.,.F.)
			RETURN .F.
		ENDIF
	ENDIF
	
	dbSelectArea("QUD")
	dbSeek(cSeek := xFilial("QUD") + QUB->QUB_NUMAUD)
	While !Eof() .and. (QUD->QUD_FILIAL + QUD->QUD_NUMAUD) == cSeek

		// Verifica se a questao foi considerada 1=SIM 2=NAO
		IF QUD->QUD_APLICA == "2"
			dbSkip()
			Loop
		ENDIF
		
		IF lVerEvid
			cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
			IF Empty(cTxtEvi)
				Help("",1,"QEVIDENCIA")	 
				lContinua := .F.
				Exit
		    ENDIF
		ENDIF
	        
		cChave := QUD->QUD_CHKLST + QUD->QUD_REVIS + QUD->QUD_CHKITE + QUD->QUD_QSTITE
	
		// QUD_TIPO = 1 Padrao - 2 Adicional - 3 Unica
		IF QUD->QUD_TIPO = "2"    
			QUE->(dbSeek(xFilial("QUE") + QUD->QUD_NUMAUD + cChave))
			nMin    := QUE->QUE_FAIXIN
			nMax    := QUE->QUE_FAIXFI
			nPeso   := IF(QUE->QUE_PESO==0,1,QUE->QUE_PESO)
			lAltern := IF(QUE->QUE_USAALT=="1",.T.,.F.)
		Else
			QU4->(dbSeek(xFilial("QU4") + cChave))
			nMin    := QU4->QU4_FAIXIN
			nMax    := QU4->QU4_FAIXFI
			nPeso   := IF(QU4->QU4_PESO==0,1,QU4->QU4_PESO)
			lAltern := IF(QU4->QU4_USAALT=="1",.T.,.F.)
		ENDIF	                                       
           
		// Verifica se a nota informada na questao Alternativa e igual a Faixa Inicial
		// se o MV_QADQZER for igual a .T. a nota da questao sera sugerida como Zero para efeito de calculo.
	    nNota := QUD->QUD_NOTA 
		IF lQstZer .And. lAltern
			IF nNota == nMin
				nNota := 0
			ENDIF	
		ENDIF
		
		nSemAval   += IF(Empty(QUD->QUD_DTAVAL), 1, 0)
		nPontos	   += (((nNota * nPeso)*100)/nMax)
		nPesoTotal += (nPeso)
		dbselectarea("QUD")
		dbSkip()
	Enddo
	
	IF lContinua 
		nPonObt := nPontos / nPesoTotal
		
		IF nSemAval > 0
			Help(" ",1,"QUDDTAVAL")	
			RETURN .F.
		ENDIF	
	ELSE
		RETURN .F.
	ENDIF
	
	oModel := FWLoadModel('QADA280')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	
	IF nPonObt > 0
		oModel:SetValue('QUBMASTER','QUB_PONOBT',nPonObt)
	ENDIF
	
	FWExecView(STR0003,'QADA280',MODEL_OPERATION_UPDATE,,{ || .T. },,,,,,,oModel ) // Encerrar
	
	oModel:DeActivate()
	
RETURN


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA280GRV(oModel)
Gravacao Commit
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
FUNCTION QADA280GRV(oModel)
	LOCAL lRet     := .T.
	LOCAL lGeraFNC := .T.
	
	Default lIntQNC  := GetMv("MV_QADQNC") //Integracao com o QNC
	
	oModel:LoadValue('QUBMASTER','QUB_STATUS','4') // Auditoria Encerrada
	
	lRet := FwFormCommit(oModel)
	
	// Realiza a Integracao com o Modulo de Nao-Conformidades
	IF lIntQNC
		IF ExistBlock("QDAGRFNC") // Ponto de Entrada Gerar ou Nao a FNC
			lGeraFNC := ExecBlock("QDAGRFNC", .F., .F.)
	  	ENDIF
	  	IF lGeraFNC
			QADA280GNC(oModel:GetValue('QUBMASTER','QUB_NUMAUD'))
		ENDIF
	ENDIF
	
	IF GetMV("MV_QADENAE",.F.,"1") == "1"
		QADA280Mail(oModel)
	ENDIF
	
	// Ponto de Entrada criado para atualizar outras tabelas
	IF ExistBlock("QADENCAU")
		ExecBlock("QADENCAU",.F.,.F.)
	ENDIF

	// Chama ponto de antrada apos todas as atualizacoes - Unimed
    IF ExistBlock("QAD140FI")
	    ExecBlock("QAD140FI",.F.,.F.)
	ENDIF
	
RETURN lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA280Mail(oModel)
Envio de e-mail comunicando as areas envolvidas
@author Geovani.Figueira
@since 24/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
FUNCTION QADA280Mail(oModel)
	LOCAL cSeekNC
	LOCAL cEmail
	LOCAL cNumAud   := oModel:GetValue('QUBMASTER','QUB_NUMAUD')
	LOCAL cSubject  := OemToAnsi(STR0009) // "Encerramento da Auditoria"
	LOCAL aUserMail := {}
	LOCAL cCpyUsr   := ""
	LOCAL lQ140MAIL := ExistBlock("Q140MAIL")
	LOCAL aText     := {}
	LOCAL cMail     := AllTrim(Posicione("QAA", 1, oModel:GetValue('QUBMASTER','QUB_FILMAT')+oModel:GetValue('QUBMASTER','QUB_AUDLID'),"QAA_EMAIL")) // E-Mail Auditor Lider
	LOCAL nCont		:= 0
	
	// Envia copia para os envolvidos na Auditoria
	QUI->(dbSetOrder(1))
	QUI->(dbSeek(xFilial("QUI")+cNumAud))
	While QUI->(!Eof()) .And. QUI->QUI_FILIAL == xFilial("QUI") .And. QUI->QUI_NUMAUD == cNumAud
		// Caso haja o mesmo endereco, este nao sera considerado
		If At(Upper(AllTrim(QUI->QUI_EMAIL)),cCpyUsr) == 0
			cCpyUsr := AllTrim(cCpyUsr)+AllTrim(QUI->QUI_EMAIL)+";"
		EndIf
		QUI->(dbSkip())		
	EndDo	
	
	// Envia copia para os auditores envolvidos na Auditoria
	QUC->(dbSetOrder(1))
	QUC->(dbSeek(xFilial("QUC")+cNumAud))
	While QUC->(!Eof()) .And. QUC->QUC_FILIAL == xFilial("QUC") .And. QUC->QUC_NUMAUD == cNumAud   
		// Caso haja o mesmo endereco, este nao sera considerado
		If At(Upper(AllTrim(QUI->QUI_EMAIL)),cCpyUsr)	== 0
			cCpyUsr := AllTrim(cCpyUsr)+AllTrim(QUC->QUC_EMAIL)+";"
		EndIf		
		QUC->(dbSkip())
	EndDo
	If SubStr(cCpyUsr,Len(cCpyUsr),1)==";"
		cCpyUsr := SubStr(cCpyUsr,1,Len(cCpyUsr)-1)
	EndIf
	
	// Envia os emails referentes as areas auditadas e para os auditores
	QUH->(dbSetOrder(1))
	QUH->(dbSeek(xFilial("QUH")+cNumAud))
	While QUH->(!Eof()) .And. QUH->QUH_FILIAL == xFilial("QUH") .And. QUH->QUH_NUMAUD == cNumAud
		
		cSeekNC  := QUH->(QUH_NUMAUD+QUH_SEQ)
		
		FOR nCont:=1 TO 2
			IF nCont == 1
				// E-mail da Area Auditada
				cEmail:= QUH->QUH_EMAIL
			ElseIF nCont == 2
				// E-mail do Auditor
				cEmail:=""
				QAA->(dbSetOrder(1))
				If QAA->(MsSeek(QUH->QUH_FILMAT+QUH->QUH_CODAUD))
					If !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
						cEmail:=QAA->QAA_EMAIL
					Endif
				Endif
			ENDIF
			// Monta e-mail do Encerramento da Auditoria em Html.
			cMsg:= Q250AudMail(2,cSubject)
			
			// Executa o Ponto de Entrada Q140MAIL, dever ser retornado o texto
			If lQ140MAIL
				aText := ExecBlock("Q140MAIL",.F.,.F.,{cSeekNC,cSubject})
				
				If aText[1] # NIL
					cMsg:= aText[1]
				EndIf
				
				If aText[3] # NIL
					cSubject += aText[3]
				EndIf
			EndIf
			
			If !Empty(cEmail)
				Aadd(aUserMail,{cEmail,cSubject,cMsg,""})
			EndIf
		Next
		
		QUH->(dbSkip())
	EndDo
	
	If 	At(cMail,cCpyUsr) == 0 .And.;	// Verifica se o auditor lider
		Ascan(aUserMail, { |x| Upper(Trim(x[1])) == Upper(cMail) }) = 0	// ja teve o e-mail incluido
		cCpyUsr := AllTrim(cCpyUsr)+";"+cMail
	EndIf		
	
	If !Empty(cCpyUsr)
		Aadd(aUserMail,{cCpyUsr,cSubject,cMsg,""})
	EndIf
	
	// Realiza a conexao e o envio dos emails
	bSendMail := {||QaudEnvMail(aUserMail,,,,.T.)}
	cTitle    := STR0010 // "Envio de e-mail"
	cMessage  := STR0011 // "Enviando e-mail comunicando o encerramento da Auditoria."
	MsgRun(cMessage,cTitle,bSendMail)

RETURN NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA280GNC(cNumAud)
Realiza a integracao das NC,s com o QNC
@author Geovani.Figueira
@since 24/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA280GNC(cNumAud)
	LOCAL aCpoQNC 
	LOCAL aRetQNC
	LOCAL cSeek  
	LOCAL aMatCod   := QA_Usuario()
	LOCAL cResFil   := AllTrim(GetNewPar("MV_QNCFRES",""))	// Filial do Responsavel
	LOCAL cResMat   := AllTrim(GetNewPar("MV_QNCMRES",""))	// Matricula do Responsavel 
	LOCAL lQADGRFNC := ExistBlock("QADGRFNC")
	LOCAL aRetrQNC  := {}
	
	dbSelectArea("QUG")
	dbSetOrder(2)
	cSeek:=xFilial("QUG")+cNumAud                                                                      
	dbSeek(cSeek)
	WHILE QUG->(!Eof()) .And. (QUG->QUG_FILIAL+QUG->QUG_NUMAUD) == cSeek .And. QUG->QUG_ACACOR == '1'
		aCpoQNC := {}
		Aadd(aCpoQNC,{"QI2_MEMO1",MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])})
		Aadd(aCpoQNC,{"QI2_OCORRE",QUG->QUG_OCORNC})
		Aadd(aCpoQNC,{"QI2_CONPRE",QUG->QUG_OCORNC+QUG->QUG_PRAZO})
		Aadd(aCpoQNC,{"QI2_DESCR" ,STR0018+AllTrim(QUG->QUG_NUMAUD)+" - "+QUG->QUG_SEQ}) // NAO-CONFORMIDADE REFERENTE AUDITORIA
		Aadd(aCpoQNC,{"QI2_TPFIC" ,"2"})
		Aadd(aCpoQNC,{"QI2_PRIORI",QUG->QUG_CATEG})
		Aadd(aCpoQNC,{"QI2_MEMO2" ,"CHECK LIST "+QUG->QUG_CHKLST+" - "+QUG->QUG_REVIS+" - "+QUG->QUG_CHKITE+" - "+QUG->QUG_QSTITE})
		Aadd(aCpoQNC,{"QI2_ORIGEM","QAD"})
		Aadd(aCpoQNC,{"QI2_CODFOR",QUB->QUB_CODFOR})
		Aadd(aCpoQNC,{"QI2_LOJFOR",QUB->QUB_LOJA})
		Aadd(aCpoQNC,{"QI2_FILMAT",aMatCod[2]})
		Aadd(aCpoQNC,{"QI2_MAT"   ,aMatCod[3]})      
		Aadd(aCpoQNC,{"QI2_MATDEP",aMatCod[4]})
		Aadd(aCpoQNC,{"QI2_FILRES",IIf(Empty(cResFil),aMatCod[2],cResFil)})	// Filial do Responsavel
		Aadd(aCpoQNC,{"QI2_MATRES",IIf(Empty(cResMat),aMatCod[3],cResMat)})	// Matricula do Responsavel
		Aadd(aCpoQNC,{"QI2_ORIDEP",aMatCod[4]})
	
		IF lQADGRFNC
			aRetrQNC := ExecBlock("QADGRFNC", .F., .F.,{aCpoQNC}) 
			IF ValType(aRetrQNC)=="A" .And. !Empty(aRetrQNC) 
			    aCpoQNC := aRetrQNC
			ENDIF
		ENDIF
		
		aRetQNC := QNCGERA(1,aCpoQNC)
	    
		// Grava o Codigo+Revisao da NC
		RecLock("QUG",.F.)
		QUG->QUG_CODNC := aRetQNC[2] // Codigo da Nao-conformidade
		QUG->QUG_REVNC := aRetQNC[3] // Revisao da Nao-conformidade				
		MsUnLock()    
		FKCOMMIT()
	    QUG->(dbSkip())
	ENDDO
	
RETURN NIL
