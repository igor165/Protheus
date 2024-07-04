#INCLUDE "PROTHEUS.CH"
#INCLUDE "QNCA030.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

//----------------------------------------------------------------------
/*/{Protheus.doc} QNCA330EVDEF
Eventos padrão da rotina de cadastro de plano de ação.
@author Luiz Henrique Bourscheid
@since 23/05/2018
@version P12.1.17 
/*/
//----------------------------------------------------------------------

CLASS QNCA330EVDEF FROM FWModelEvent
	
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD GridLinePosVld()
	METHOD BeforeTTS()
	METHOD AfterTTS()
	METHOD AFter()
	METHOD GridLinePreVld()
	METHOD Activate()
	METHOD InTTS()
	
ENDCLASS

METHOD New() CLASS  QNCA330EVDEF
	
Return Nil

METHOD Activate(oModel, lCopy) Class QNCA330EVDEF
	Local lRet 		  := .T.
	Local nX 
	Local oModelQI3 := oModel:GetModel("QI3MASTER")
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")
	
	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf

	If lRevisao
		dbSelectArea("QI2")
		QI2->(dbSetOrder(5))
		If QI2->(dbSeek(QI9->QI9_FILIAL + QI9->QI9_CODIGO + QI9->QI9_REV ))
			If MsgYesNo(OemToAnsi(STR0057),OemToAnsi(STR0058))     //"Deseja reativar as Fichas de Ocorrencias/Nao-Conformidades relacionadas?" ### "AVISO"
				While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_CODACA+QI2->QI2_REVACA == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI9->QI9_REV
					RecLock("QI2",.F.)
					QI2->QI2_REVACA := QI3->QI3_REV
					QI2->QI2_CONREA := CTOD("  /  /  ")
					QI2->QI2_CONPRE := CTOD("  /  /  ")
					MsUnLock()
					FKCOMMIT()
					dbSkip()
				Enddo
			Endif
		Endif
		dbSelectArea("QI3")
  Endif

	If lRevisao .And. oModel:GetOperation() == 3
		oModelQI3:LoadValue("QI3_ABERTU", dDataBase)
		oModelQI3:LoadValue("QI3_ENCPRE", dDatabase+30)
		oModelQI3:LoadValue("QI3_ENCREA", Ctod("  /  /  ")) 
		oModelQI3:LoadValue("QI3_OBSOL" , "N")
		oModelQI3:LoadValue("QI3_STATUS", "1")
		
		If oModelQI5:Length() > 0
			For nX := 1 To oModelQI5:Length()
				oModelQI5:LoadValue("QI5_PRAZO" , CTOD(""))
				oModelQI5:LoadValue("QI5_REALIZ", CTOD(""))
				oModelQI5:LoadValue("QI5_STATUS", "0")
			Next nX
		EndIf
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Método de Pos validação do modelo
@author Luiz Henrique Bourscheid
@since 28/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) Class QNCA330EVDEF	
	Local lRet := .T.
	Local oModelQI3 := oModel:GetModel("QI3MASTER")

	If lRet .And. !Empty(oModelQI3:GetValue("QI3_ENCREA")) .And. oModelQI3:GetValue("QI3_STATUS") < "3"
		MsgAlert(STR0073) //"O Plano de Acao nao podera ser encerrado em status [Registrado/Em Analise]"
		lRet := .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se esta sendo Incluida/Alterada uma revisao com numeracao    ³
	//³ inferior a revisao atual.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI3")
	dbSetOrder(1)
	If lRet .And. dbSeek(xFILIAL("QI3")+oModelQI3:GetValue("QI3_CODIGO"))
		While !Eof() .And. xFILIAL("QI3")+oModelQI3:GetValue("QI3_CODIGO") == QI3->QI3_FILIAL+QI3->QI3_CODIGO
			If QI3->QI3_REV >= oModelQI3:GetValue("QI3_REV")
				MsgAlert(OemToAnsi(STR0055)+Chr(13)+;	// "Nao sera possivel a Inclusao/Alteracao de Plano de Acao com "
						OemToAnsi(STR0056))				// "numeracao inferior ao ultimo cadastrado."
				lRet := .F.
				Exit
			Endif
			dbSkip()
		Enddo
	Endif
	
	If !Empty(oModelQI3:GetValue("QI3_ENCREA")) .AND. (oModelQI3:GetValue("QI3_ENCREA") > dDataBase) // Caso a data de conclusao seja maior que a data base bloqueio
		MsgAlert(STR0084) // "Data de encerramento do Plano de Acao nao pode ser maior que a data base do sistema! "
		oModelQI3:SetValue("QI3_ENCREA", Ctod("  /  /  "))
		lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Pos validação das grids do modelo
@author Luiz Henrique Bourscheid
@since 28/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) Class QNCA330EVDEF	
	Local lRet 		   := .T.
	Local lACoB	     := GetMV("MV_QNCACOB") == "1" // 1=Sim, 2=Nao
	Local nX
	Local oModelQI3  := FWModelActive()
	Local cQncPrz  	 := GetMV("MV_QNCPRZ",.F.,"2")		// 1=Sim, 2=Nao
	Local cMvValid 	 := GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
	Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local lAltDeta   := If(GetMv("MV_QNCADET",.F.,"1")=="1",.T.,.F.) // 1=SIM 2=NAO - ALTERACAO DO CAMPO DESCRICAO DETALHADA
	Local lVcausa	   := GetMv('MV_VCAUSA',.F.,.F.)
	Local aStruQI5   := FWFormStruct(3,'QI5')[1]
	Local nPosPrazo  := Ascan(aStruQI5,{ |X| UPPER(ALLTRIM(X[3])) == "QI5_PRAZO" })
	Local nPosStatus := Ascan(aStruQI5,{ |X| UPPER(ALLTRIM(X[3])) == "QI5_STATUS" })  
	Local oModelQI5  := oModelQI3:GetModel("QI5DETAIL")
	Local oModelQI6  := oModelQI3:GetModel("QI6DETAIL")
	Local oModelQI9  := oModelQI3:GetModel("QI9DETAIL")
	Local lBaixaAle  := If(GetMv("MV_QNCBALE",.f.,"2") == "1",.T.,.F.) // Baixa Aleatoria de Etapas

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os Usuarios das Etapas/Passos sao validos               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cID == "QI5DETAIL"
		QAA->(dbSetOrder(1))
		If oModelQI5:GetValue("QI5_STATUS") <> "4"
			If QAA->(dbSeek(oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT"))) .And. ! QA_SitFolh()
				Help( " ", 1, "A090DEMITI" )
				lRet := .F.
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³no STATUS 100% sera obrigatorio o Preechimento das                 ³
		//³Prazo, Realizacao , Descr Resumida e Descri Compl.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		IF oModelQI5:GetValue("QI5_STATUS") == "4"
			DO Case
			Case Empty(oModelQI5:GetValue("QI5_PRAZO"))
				HELP("  ",1,"OBRIGAT",,RetTitle("QI5_PRAZO")+Space(30),3,0)
				lRet := .F.
			Case Empty(oModelQI5:GetValue("QI5_REALIZ"))
				HELP("  ",1,"OBRIGAT",,RetTitle("QI5_REALIZ")+Space(30),3,0)
				lRet := .F.
			Case Empty(oModelQI5:GetValue("QI5_DESCRE"))
				HELP("  ",1,"OBRIGAT",,RetTitle("QI5_DESCRE")+Space(30),3,0)
				lRet := .F.
			Case Empty(oModelQI5:GetValue("QI5_MEMO1"))
				If lAltDeta 
					HELP("  ",1,"OBRIGAT",,RetTitle("QI5_MEMO1")+Space(30),3,0)
					lRet := .F.
				EndIf
		EndCase
			// Se o parametro mv_vcausa estiver ativo e o status 100% será obrigatorio ao menos uma causa no 
			// plano de ação para efetuar a baixa.
			If lVcausa .and. oModelQI6:Length() == 0
				msgAlert("Para Baixa total é necessario ao menos uma causa cadastrada no plano de ação")
				lRet := .F.
			EndIf
		Endif
		
		If oModelQI5:Length(.T.) > 0 .And. lRet
			dbSelectArea("QAA")
			dbSetOrder(1)
	
			For nX := 1 To oModelQI5:Length(.T.)
				If oModelQI5:GetValue("QI5_STATUS") <> "4"
			  	If QAA->(dbSeek(oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT"))) .And. !QA_SitFolh()
						Help( " ", 1, "A090DEMITI" )
						lRet := .F.
					Endif
		    Endif
		    If lRet .AND. !Empty(M->QI3_ENCREA) .AND. oModelQI5:GetValue("QI5_STATUS") < "4" 	
					Help(" ",1,"QNCEXILCPD")	// Existe(m) Lancamento(s) Pendente(s) de Etapas das Acoes Corretivas,
					lRet := .F.					// nao sera possivel a Baixa. 
					Exit
		   	Endif
			Next nX
		Else
			If lACoB .AND. lRet
				Help(" ", 1, "QN030NEETA") // "Nao e possivel finalizar o plano sem cadastrar as Acoes/Etapas, Conforme Parametro MV_QNCACOB"
				lRet:= .F.
			EndIf
		Endif
	
		If !lBaixaAle
			If !Empty(oModelQI5:GetValue("QI5_PRAZO")) .and. cQncPrz == "2"
				If oModelQI5:Length() > 1
					If oModelQI5:GetValueByPos(nPosPrazo, oModelQI5:GetLine()) < oModelQI5:GetValueByPos(nPosPrazo, (oModelQI5:GetLine()-1))
						Help(" ",1,"QNCDTMENOR")	// Data menor que o Lacto anterior
						lRet := .F.
					Endif
				Endif
			Endif    
			
			If oModelQI5:GetOperation() == 4 .And. oModelQI5:GetValue("QI5_PRAZO") < QI3->QI3_ABERTU
				 Help(NIL, NIL, "Prazo de Execução", NIL, "Data do prazo de execução menor que a data de abertura do plano de ação.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe um prazo de execução maior ou igual a data de abertura do plano de ação."})
			   lRet := .F.
			EndIf

			If oModelQI5:Length() > 1
				If oModelQI5:GetValue("QI5_STATUS") <> "0"
					for nX := 1 to oModelQI5:GetLine()-1
						if nPosStatus > 0 .And. oModelQI5:GetValueByPos(nPosStatus, nX) <> "4"
							Help(NIL, NIL, "Baixa sequencial", NIL, "Etapa anterior não Concluida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Conclua as etapas anteriores a esta."})
							lRet := .F.
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .And. cID == "QI9DETAIL" .And. cMvValid == "1"
		QI9->(DbSetOrder(2))
		If QI9->(DbSeek(xFilial("QI9") + oModelQI9:GetValue("QI9_FNC") + oModelQI9:GetValue("QI9_REVFNC"))) .And.;
			QI9->QI9_CODIGO <> oModelQI3:GetValue("QI3_CODIGO")
			If !lTMKPMS //Na integracao do QNC com o TMK uma FNC podera estar associada a mais de um Plano.
				Help(" ",1,"QALCTOJAEX",, STR0036 + TransForm(QI9->QI9_CODIGO,PesqPict("QI9","QI9_CODIGO") ),3,1)	// "Plano de Acao No. "
				lRet := .F.
			Endif	
		Endif
		QI9->(DbSetOrder(1))

		// Verifica se FNC PROCEDE E/OU OBSOLETA
		If !Q330ChkFnc()
			lRet := .F.
		Endif
	Endif	

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS()
Método executado antes do commit porém dentro da transação.
@author Luiz Henrique Bourscheid
@since 29/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) Class QNCA330EVDEF
	Local lRet       := .T.
	Local dPrazoAnt  := CTOD("  /  /  ")
	Local cAlias
	Local cCod
	Local cMvValid   := GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
	Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS
	Local lMvPlPrc	 := GetMv("MV_QPLPRC", .F., "N") = "S"
	Local lAtuPend   := .T.
	Local nX
	Local nMVQTMKPMS := GetMv("MV_QTMKPMS",.F.,1)
	Local oModelQI3  := oModel:GetModel("QI3MASTER")
	Local oModelQI5  := oModel:GetModel("QI5DETAIL")
	Local oModelQI6  := oModel:GetModel("QI6DETAIL")
	Local oModelQI9  := oModel:GetModel("QI9DETAIL")
	Local lBaixaAle  := If(GetMv("MV_QNCBALE",.f.,"2") == "1",.T.,.F.) // Baixa Aleatoria de Etapas
	Local aUsrMat    := QNCUSUARIO()
	Local cMatFil    := aUsrMat[2]
	Local cMatCod    := aUsrMat[3]
	Local cMatDep    := aUsrMat[4]
    Local aUsuarios  := {}
	Local dDTQI5     := CTOD("  /  /  ")
	Local dNewPrazo  := CTOD("  /  /  ") 
	Local nHrAcum    := 0
	Local cDurPLAN   := 0
	Local lQNCCACAO  := ExistBlock( "QNCCACAO" )

	If Type("lFNC") != "L"
		Private lFNC := .F.
	EndIf

	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf

	If Type("lModFNC") != "L"
		Private lModFNC := .F.
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamada via FNC o plano Procede.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFNC
			oModelQI3:SetValue("QI3_STATUS", "3")
		EndIf
		
		If lRevisao
		    dPrazoAnt := oModelQI5:GetValue("QI5_PRAZO")
				oModelQI3:SetValue("QI3_MEMO7", cMotivo)
		Endif    
		
		//oModelQI5:LoadValue("QI5_PLAGR", Space(TamSX3("QI5_PLAGR")[1]))
		//oModelQI5:LoadValue("QI5_AGREG", Space(TamSX3("QI5_AGREG")[1]))
		
	  If oModelQI9:Length() > 0
			DbSelectArea("QI9")
			cAlias := "QI9"
			cCod   := cAlias+"->"+cAlias+"_FILIAL+"+cAlias+"->"+cAlias+"_CODIGO+"+cAlias+"->"+cAlias+"_REV"
			If (oModel:GetOperation() == 3 .And. DbSeek( M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV )) .Or. ;
			   (oModel:GetOperation() == 4 .And. DbSeek( QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
				While !Eof() .And. ((oModel:GetOperation() == 3 .And. &(cCod) == M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV) .Or.;
					  (oModel:GetOperation() == 4 .And. &(cCod) == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV))
					
						QI2->(DbSetOrder(2))
						If oModelQI9:SeekLine({{"QI9_FNC", QI9->QI9_FNC}}) .And. ;
						   oModelQI9:SeekLine({{"QI9_REVFNC", QI9->QI9_REVFNC}}) .And. ;
						   QI2->(DbSeek( QI9->QI9_FILIAL + QI9->QI9_FNC + QI9->QI9_REVFNC ))
							If Empty(QI2->QI2_CODACA) .Or. cMvValid == "1"
								DbSelectArea("QI2")
								RecLock("QI2")
								Replace	QI2_CODACA With Space(Len(QI9->QI9_FNC)), ;
										QI2_REVACA With Space(Len(QI9->QI9_REV)), ;
										QI2_CONREA With Ctod("")
								MsUnLock()
							Endif
						Endif
						QI2->(DbSetOrder(1))
					
					DbSkip()
				Enddo
			EndIf
			
			For nX := 1 To oModelQI9:Length() 
				QI2->(DbSetOrder(2)) // Procuro pela ficha e indico o plano de acao
				If QI2->(DbSeek( QI9->QI9_FILIAL + QI9->QI9_FNC + QI9->QI9_REVFNC ))
					If Empty(QI2->QI2_CODACA) .Or. cMvValid == "1"
						DbSelectArea("QI2")
						RecLock("QI2")
						Replace	QI2_CODACA With oModelQI3:GetValue("QI3_CODIGO"),;
								QI2_REVACA With oModelQI3:GetValue("QI3_REV")
						If QI2->QI2_STATUS == "1"
			                Replace QI2_STATUS With "3"
						Endif
						MsUnLock()
					Endif
				Endif
				QI2->(DbSetOrder(1))
			Next nX
		Endif
		
		If oModelQI5:Length() > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o campo de Pendencia S/N                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To oModelQI5:Length()
				If If(lMvPlPrc, oModelQI3:GetValue("QI3_STATUS") == "3", .T.) .And. (lAtuPend .Or. lBaixaAle)
					If (oModelQI5:GetValue("QI5_SEQ") == "01" .And. oModelQI5:GetValue("QI5_STATUS") <> "4") .Or. ;
						(nX > 1 .And.  oModelQI5:GetValue("QI5_STATUS") <> "4") 
						oModelQI5:LoadValue("QI5_PEND", "S")
						lAtuPend := .F.
					Else
						If oModelQI5:GetValue("QI5_STATUS") == "4" 
							If Empty(oModelQI5:GetValue("QI5_PRAZO"))
								oModelQI5:LoadValue("QI5_PRAZO", oModelQI3:GetValue("QI3_ENCREA"))
							EndIf
							If Empty(oModelQI5:GetValue("QI5_REALIZ"))
								oModelQI5:LoadValue("QI5_REALIZ", oModelQI3:GetValue("QI3_ENCREA"))
							EndIf
							oModelQI5:LoadValue("QI5_PEND", "N")
						EndIf 
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Baixa das Etapas quando Plano de Acao for Cancelado          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oModelQI3:GetValue("QI3_STATUS") == "5" .And. oModelQI5:Length() > 0 		// Plano de Acao Cancelado
		For nX := 1 To oModelQI5:Length()
			If oModelQI5:GetValue("QI5_PEND") == "S" .Or. oModelQI5:GetValue("QI5_STATUS") < "4" .Or. Empty(oModelQI5:GetValue("QI5_REALIZ"))
				If Empty(oModelQI5:GetValue("QI5_PRAZO"))
					oModelQI5:SetValue("QI5_PRAZO", oModelQI3:GetValue("QI3_ENCREA"))
				Endif
				
				If Empty(oModelQI5:GetValue("QI5_REALIZ"))
					oModelQI5:SetValue("QI5_REALIZ", oModelQI3:GetValue("QI3_ENCREA"))
				Endif
				
				oModelQI5:SetValue("QI5_PEND"  , "N")
				oModelQI5:SetValue("QI5_STATUS", "4") 
				oModelQI5:SetValue("QI5_DESCRE", OemToAnsi(STR0039))// "Plano de Acao Cancelado"
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia e-mail para os responsaveis das Etapas                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cMatFil) .And. !Empty(cMatCod) .And. cMatFil+cMatCod <> oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT")
				If QAA->(dbSeek(oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT"))) .And. QAA->QAA_RECMAI == "1"
					cMail := AllTrim(QAA->QAA_EMAIL)			
					If !Empty(cMail)
						If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0
							cTpMail:= QAA->QAA_TPMAIL
							// Plano de Acao
							If cTpMail == "1"
								cMsg := QNCSENDMAIL(2,OemToAnsi(STR0040)+DtoC(oModelQI3:GetVaue("QI3_ENCREA"))+Space(2)+OemToAnsi(STR0041))  // "Plano de Acao Cancelado em " ### "pelo Responsavel."
							Else
								cMsg := OemToAnsi(STR0040)+DtoC(oModelQI3:GetVaue("QI3_ENCREA"))+Space(2)+OemToAnsi(STR0041)+CHR(13)+CHR(10)	 // "Plano de Acao Cancelado em " ### "pelo Responsavel."
								cMsg += CHR(13)+CHR(10)
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
								cMsg += oModelQI3:GetVaue("QI3_NUSR")+CHR(13)+CHR(10)
								cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
							Endif
							
							cAttach := ""
							aMsg:={{OemToAnsi(STR0036)+" "+TransForm(oModelQI3:GetVaue("QI3_CODIGO"),PesqPict("QI3","QI3_CODIGO"))+"-"+oModelQI3:GetVaue("QI3_REV")+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
	
							// Geracao de Mensagem para o Responsavel da Etapa do Plano de Acao
							IF lQNCCACAO
								aMsg := ExecBlock( "QNCCACAO", .f., .f. )
							Endif

							aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX

		If lTMKPMS 
			DbselectArea("QUO")
			QUO->(dbSetOrder(1))	
			IF QUO->(MsSeek(xFilial("QUO")+oModelQI3:GetValue("QI3_MODELO")))			
				cDurPLAN := QUO->QUO_PRZHR	
			Endif		
		Endif

		If lTMKPMS
			If nMVQTMKPMS > 2
				If oModelQI5:Length() > 0 .And. oModel:GetOperation() == 4
					For nX := 1 To oModelQI5:Length()
						//Tratamento da alteracao da data
						If QI5->QI5_PRAZO <> oModelQI5:GetValue("QI5_PRAZO") .Or.;  //Se as datas forem diferentes prevale a data alterada
								QI5->QI5_PRZHR <> oModelQI5:GetValue("QI5_PRZHR")
									dDTQI5 := oModelQI5:GetValue("QI5_PRAZO")
									lNFz := .F.
						Endif
						If lNFz
							If !Empty(dDTQI5)//Se as datas forem iguais prevalecera o ultimo prazo alterado
								If Empty(oModelQI5:GetValue("QI5_REALIZ"))
									dNewPrazo := QN5CalPrz(dDTQI5, @nHrAcum, oModelQI3:GetValue("QI3_ENCPRE"), oModelQI5:GetValue("QI5_PRZHR"), cDurPLAN)
									If Empty(dNewPrazo) .and. Empty(oModelQI5:GetValue("QI5_PRAZO"))
										oModelQI5:SetValue("QI5_PRAZO") := dDataBase
									Else
										oModelQI5:SetValue("QI5_PRAZO") := dNewPrazo
									EndIf
									QI5->(MsUnLock())
									dDTQI5 := QI5->QI5_PRAZO
								Endif
							Endif
						Endif
					Next
				Endif
			Endif
		Endif

	Endif

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !IsBlind()
		cCodSeq := GETNEXTNUM(M->QI3_ANO)
		IF !(cCodSeq == oModelQI3:GetValue("QI3_CODIGO")) 
			oModelQI3:SetValue("QI3_CODIGO", cCodSeq)
			lModFNC := .T.
		Endif
	Endif

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS()
Método executado após o commit porém dentro da transação.
@author Luiz Henrique Bourscheid
@since 29/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) Class QNCA330EVDEF
	Local lRet    := .T.
	Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local nMVQTMKPMS := GetMv("MV_QTMKPMS",.F.,1)
	Local oModelQI5  := oModel:GetModel("QI5DETAIL")
	Local oModelQI3  := oModel:GetModel("QI3MASTER")
	Local nX

	If Type("__lQNSX8") != "L"
		Private __lQNSX8 := .F.
	EndIf
	
	If Type("aQNQI3") != "A"
		Private aQNQI3 := {}
	EndIf

	If oModel:GetOperation() == 3 .And. __lQNSX8
		ConfirmeQE(aQNQI3)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baixa as Fichas de Nao-Conformidades relacionadas ao Plano.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oModel:GetOperation() == 4 .And. !Empty(QI3->QI3_ENCREA)
		QN330BxFNC()
	EndIf

	If oModel:GetOperation() <> 1 .And. oModel:GetOperation() <> 5 //-- Se nao for Visualizacao ou Exclusao
		For nX := 1 To oModelQI5:Length()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta as habilidades(QUR) amarradas as Etapas. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			DbSelectArea("QUR")
			QUR->(DbSetOrder(1))
			If QUR->(DbSeek(xFilial("QI5")+ oModelQI5:GetValue("QI5_CODIGO") + oModelQI5:GetValue("QI5_TPACAO")))
				While QUR->(!Eof()) .And. QUR->QUR_FILIAL+QUR->QUR_CODIGO+QUR->QUR_TPACAO == xFilial("QI5")+oModelQI5:GetValue("QI5_CODIGO")+oModelQI5:GetValue("QI5_TPACAO")
					RecLock("QUR",.F.)
					QUR->(dbDelete())
					QUR->(MsUnlock())
					QUR->(dbSkip())
				Enddo
			Endif
		Next nX
	ElseIf oModel:GetOperation() == 5
		//Caso tenha cancelado o plano de acao, verifica se existe Etapa x Habilidades cadastradas e realiza a delecao...
		If lTMKPMS
			dbSelectArea("QUR")
			QUR->(dbSetOrder(1))
			If QUR->(DbSeek(xFilial("QUR")+oModelQI3:GetValue("QI3_CODIGO")))
				While !Eof() .and. QUR->QUR_FILIAL+QUR->QUR_CODIGO == oModelQI3:GetValue("QI3_FILIAL")+oModelQI3:GetValue("QI3_CODIGO")
					RecLock("QUR",.F.)
					QUR->(dbDelete())
					QUR->(MsUnlock())
					QUR->(dbSkip())
				Enddo			
			Endif		
		Endif	
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} After()
Método executado após o commit porém fora da transação.
@author Luiz Henrique Bourscheid
@since 29/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD After(oSubModel, cModelId, cAlias, lNewRecord) Class QNCA330EVDEF
	Local lRet 			 := .T.
	Local cEncAutPla := AllTrim(GetMv("MV_QNEAPLA",.F.,"1")) // Encerramento Automatico de Plano
	Local lErase 		 := .T.
	Local cDelAnexo  := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
	Local cQPathFNC  := QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
	Local aQPath     := QDOPATH()
	Local cQPathTrm  := aQPath[3]
	Local aArqFNC    := {}
	Local nT
	Local aUsrMat    := QNCUSUARIO()
	Local cMatFil    := aUsrMat[2]
	Local cMatCod    := aUsrMat[3]
	Local oModel     := FWModelActive()
	Local oModelQI5  := oModel:GetModel("QI5DETAIL")
	Local lMvPlPrc	 := GetMv("MV_QPLPRC", .F., "N") = "S"
	Local lQNCEACAO  := ExistBlock( "QNCEACAO" )
	Local lMvQNCEMTA := IF(GetMv("MV_QNCEMTA",.F.,"2") == "1", .T., .F.) //Define se Envia e-mail para todas as Etapas do Plano na Inclusao e Alteracao.
	Local lTMKPMS 	 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
    Local cMail	     := ""
	Local aUsuarios  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foram baixadas todas etapas para baixar o Plano  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEncAutPla == '1'
		QN330BxPla()
	Endif

	If cModelId == "QI3MASTER"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                 
		//³ Integracao com o PMS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realizado bloqueio de geracao de tarefa no PMS na opção  ³
		//³de inclusão para evitar que o Plano seja cancelado quando³
		//³ele estiver sendo criado via Ficha de Não conformidade   ³
		//³ocorrendo inconsistencia na base do tipo:                ³
		//³- gerou tarefa no PMS e o Plano e a Ficha foi cancelado  ³
		//³enquanto ambas estava sendo aberta. 28/01/2009           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 If lTMKPMS //.And. nOpc == 4 
		    If (GetMv("MV_QTMKPMS",.F.,1) == 3)  .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³aHabilidades = Array com as habilidades para executar a tarefa.                    ³                          ³
				//³dDTEncer     = Dt de Encerramento                                                  ³			  
				//³cHRParcial   = HR ref a Porcentagem p/ executar a etapa, cadastrada no arquivo QUP ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				aAreaQI3 := QI3->(GetArea())
				ProcessaDoc({||Q030GeraTarefa()})        
		        RestArea(aAreaQI3)                         
			Endif
		Endif


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel do Plano de Acao e da Etapa vigente   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMatFil+cMatCod <> oSubModel:GetValue("QI3_FILMAT")+oSubModel:GetValue("QI3_MAT") .And. !Q330AltEta()
			QAA->(dbSetOrder(1))
			If QAA->(dbSeek(QI3->QI3_FILMAT + QI3->QI3_MAT )) .And. QAA->QAA_RECMAI == "1"
				cMail := AllTrim(QAA->QAA_EMAIL)
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel do Plano de Acao                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMail)

			cTpMail:= QAA->QAA_TPMAIL

			// Plano de Acao
			If cTpMail == "1"
				cMsg := QNCSENDMAIL(2,OemToAnsi(STR0034),.T.)	// "Plano de Acao iniciado."
			Else
				cMsg := OemToAnsi(STR0037)+DtoC(oSubModel:GetValue("QI3_ABERTU"))+Space(10)+OemToAnsi(STR0038)+DtoC(oSubModel:GetValue("QI3_ENCPRE"))+CHR(13)+CHR(10)	 // "Plano de Acao Iniciado em " ### " Data Prevista p/ Conclusao: "
				cMsg += CHR(13)+CHR(10)
				cMsg += OemToAnsi(STR0051)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
				cMsg += oSubModel:GetValue("QI3_MEMO1")+CHR(13)+CHR(10)
				cMsg += CHR(13)+CHR(10)
				cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
				cMsg += oSubModel:GetValue("QI3_NUSR")+CHR(13)+CHR(10)
				cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
				cMsg += CHR(13)+CHR(10)
				cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
			Endif
			
			cAttach := ""
			aMsg:={{OemToAnsi(STR0036)+" "+TransForm(oSubModel:GetValue("QI3_CODIGO"),PesqPict("QI3","QI3_CODIGO"))+"-"+oSubModel:GetValue("QI3_REV")+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "

			// Geracao de Mensagem para o Responsavel do Plano de Acao 
			IF ExistBlock( "QNCRACAO" )
				aMsg := ExecBlock( "QNCRACAO", .f., .f., { OemToAnsi(STR0034),.T. } )
			Endif

			aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )

		Endif
						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel da Etapa vigente                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMail := ""
		If 	If(lMvPlPrc, oSubModel:GetValue("QI3_STATUS") == "3", .T.) .And.;
			(oSubModel:GetOperation() == 3 .Or. oSubModel:GetOperation() == 4) .And. Empty(oSubModel:GetValue("QI3_ENCREA"))
			dbSelectArea("QI5")
			dbSetOrder(1)
			If oModelQI5:Length() > 0
				For nT := 1 To oModelQI5:Length()
					If oModelQI5:GetValue("QI5_PEND") == "S" .OR. lMvQNCEMTA
						If cMatFil+cMatCod <> oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT")
							If QAA->(dbSeek(oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT"))) .And. QAA->QAA_RECMAI == "1"
								cMail := AllTrim(QAA->QAA_EMAIL)
							EndIf
						EndIf

						If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0						

							If !Empty(cMail)

								cTpMail:= QAA->QAA_TPMAIL

								// Etapa do Plano de Acao
								If cTpMail == "1"
									cMsg := QNCSENDMAIL(3,OemToAnsi(STR0035),.T.)	// "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado."
								Else
									cMsg := OemToAnsi(STR0037)+DtoC(oSubModel:GetValue("QI3_ABERTU"))+Space(10)+OemToAnsi(STR0038)+DtoC(oModelQI5:GetValue("QI5_PRAZO"))+CHR(13)+CHR(10)	 // "Plano de Acao Iniciado em " ### " Data Prevista p/ Conclusao: "
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0060)+QI5->QI5_TPACAO+"-"+FQNCDSX5("QD",oModelQI5:GetValue("QI5_TPACAO"))+CHR(13)+CHR(10)	// "Tipo Acao/Etapa: "
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0051)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
									cMsg += oSubModel:GetValue("QI3_MEMO1")+CHR(13)+CHR(10)
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
									cMsg += oSubModel:GetValue("QI3_NUSR")+CHR(13)+CHR(10)
									cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
								Endif
								
								cAttach := ""
								aMsg:={{OemToAnsi(STR0036)+" "+TransForm(oSubModel:GetValue("QI3_CODIGO"),PesqPict("QI3","QI3_CODIGO"))+"-"+oSubModel:GetValue("QI3_REV")+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
		
								// Geracao de Mensagem para o Responsavel da Etapa do Plano de Acao 
								IF lQNCEACAO
									aMsg := ExecBlock( "QNCEACAO", .f., .f., { OemToAnsi(STR0035) } ) // "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado."
								Endif

								aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
							EndIf
						EndIf
					EndIf						
				Next nT
			EndIf
		EndIf

		If oSubModel:GetOperation() == 3 .Or. oSubModel:GetOperation() == 4	// Inclusao ou Alteracao
			If QIE->(DbSeek(QI3->QI3_FILIAL+oSubModel:GetValue("QI3_CODIGO")+oSubModel:GetValue("QI3_REV")))
				While QIE->(!Eof()) .And. QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV == QI3->QI3_FILIAL+oSubModel:GetValue("QI3_CODIGO")+oSubModel:GetValue("QI3_REV")
					cFileTrm:= AllTrim(QIE->QIE_ANEXO)
					If !File(cQPathFNC+cFileTrm)
						If File(cQPathTrm+cFileTrm)
								If !CpyT2S(cQPathTrm+cFileTrm,cQPathFNC,.T.)
									Help(" ",1,"QNAOCOPIOU")
								Endif
						Else
							If File(cQPathFNC+cFileTrm)
								FErase(cQPathFNC+cFileTrm)
							Endif
						Endif
					EndIf
					QIE->(DbSkip())
				EndDo
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variavel de flag para identificar se pode apagar os anexos da FNC ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lErase
			If cDelAnexo == "1"	
				aArqFNC := DIRECTORY(cQPathTrm+"*.*")
				For nT:= 1 to Len(aArqFNC)
					If oSubModel:GetValue("QI3_CODIGO") + "_" + oSubModel:GetValue("QI3_REV") + "_" =;
						Left(aArqFNC[nT,1], Len(oSubModel:GetValue("QI3_CODIGO") + "_" + oSubModel:GetValue("QI3_REV") + "_")) .And.;
						File(cQPathTrm+AllTrim(aArqFNC[nT,1]))
						FErase(cQPathTrm+AllTrim(aArqFNC[nT,1]))
					Endif
				Next
			EndIf
		Endif
	
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld()
Método executado durante as alterações das linhas das grids do modelo.
@author Luiz Henrique Bourscheid
@since 29/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class QNCA330EVDEF
	Local lRet  		 := .T. 
	Local cMvValid 	 := GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
	Local cStatPlano := AllTrim(GetMv("MV_QNCSFNC",.F.,"3"))
	Local cChave
	
	If cModelID == "QI9DETAIL"
		If cAction == "ADDLINE" .Or. cAction == "DELETE"
				If GetMv("MV_QTMKPMS",.F.,1) == 2
					lAltEta := .F.
				Endif			
			lRet := !lAltEta

		ElseIf cAction == "SETVALUE"
			cCodFNC = oSubModel:GetValue("QI9_FNC")
			cCodRev = oSubModel:GetValue("QI9_REVFNC")

			If cId == "QI9_FNC"
				cCodFNC := xValue
			ElseIf cId == "QI9_REVFNC"
				cCodRev := xValue
			EndIf

			cChave := AllTrim(Right(cCodFNC,4)) + cCodFNC + If(!Empty(cCodRev), cCodRev, "")
			lRet   := .F.

			dbSelectArea("QI2")
			QI2->(dBSetOrder(1))
			If QI2->(dbSeek(xFilial("QI2")+cChave))
				If cMvValid == "1"
					If !Empty(cCodRev)
						If QI2->QI2_STATUS $ cStatPlano .And. QI2->QI2_OBSOL == "N"
							lRet := .T.
						Endif
					Else
						lRet := .T.	
					Endif
				Else
					lRet := .T.	
				Endif
			Endif

			If !lRet
				Help(" ",2,"QNC040NCAC")
				oSubModel:LoadValue("QI9_FNC", "")
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QnC330VLETP()
Valida se e permitido alterar o campo modelo
@author Luiz Henrique Bourscheid
@since 23/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QNC330VLETP(cCampo) 
	Local cCoCpo    := cCampo
	Local lRet      := .T.
	Local nPosCC    := ""
	Local lTMKPMS 	:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.) //Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local oModel    := FWModelActive()
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")

	If lTMKPMS
		If (GetMv("MV_QTMKPMS",.F.,1) == 3)  .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4) 
			nPosCC := At(">",cCampo) 
			If nPosCC > 0	
				cCampo := SubStr(cCampo,nPosCC+1,Len(cCampo))
			Endif 
			
			If Alltrim(cCoCpo) == Alltrim(readvar())
				If !Empty(oModel:GetValue("QI5_TAREFA"))
					lRet :=  .F.   
					Aviso(STR0094,STR0096, {"ok"}) //"Atencao"##"Devido a tarefa gerada no PMS, esse campo nao pode ser alterado."
					oModelQI5:SetValue(cCampo, CriaVar(cCampo,.f.))
				Endif	
			Endif
		Endif	
	Endif	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330VlPJ() 
Valida se tem integração e conteúdo inserido no campo.
@author Luiz Henrique Bourscheid
@since 23/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QNC330VlPJ() 
	Local cCampo    := AllTrim(ReadVar()) 
	Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
	Local oModel    := FWModelActive()
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")
	Local lRet      := .T.

	If lTMKPMS
		If cCampo = 'M->QI5_PROJET'
			lRet := ExistCpo('AF8')				
		ElseIf cCampo = 'M->QI5_PRJEDT'
			lRet := Q_CHKEDT(oModelQI5:GetValue("QI5_PROJET"), oModelQI5:GetValue("QI5_PRJEDT"))
		EndIf	
	EndIf			

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QN330AEtap() 
Valida se Usuario pode alterar o Plano/Etapas.
@author Luiz Henrique Bourscheid
@since 23/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QN330AEtap()
	Local oModel    := FWModelActive()
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")
	Local lRet      := .F.
	
	If !Empty(oModelQI5:GetValue("QI5_FILMAT")) .AND. !Empty(oModelQI5:GetValue("QI5_MAT"))
		If cMatFil+cMatCod == oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT") .Or. Q330AltPla()
			lRet:= .T.
		EndIf
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330VLEG() 
Altera a legenda dos itens da tela de Acoes X Etapas quando é alterado.
@author Luiz Henrique Bourscheid
@since 30/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------     
Function QNC330VLEG()
	Local cStatus   := &(ReadVar())
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")
	
	lTAREFA := If(SuperGetMV("MV_QTMKPMS",.F.,1) > 2, .T.,.F.)  //QI5_TAREFA
	 
	Do Case 
		Case AllTrim(cStatus) == '5' 			//-- Rejeitado
			oModelQI5:LoadValue("QI5_OK", "BR_PRETO")
		Case AllTrim(cStatus) == '4' 			//-- Finalizado
			oModelQI5:LoadValue("QI5_OK", "BR_VERDE")
		Case AllTrim(cStatus) $ '1*2*3' 		//-- Em execucao
			oModelQI5:LoadValue("QI5_OK", "BR_AMARELO")
		Case lTAREFA .And. Empty(oModelQI5:GetValue("QI5_TAREFA")) 	//-- Não Gerada
			oModelQI5:LoadValue("QI5_OK", "BR_BRANCO")
		Otherwise  											//-- Nao iniciado
			oModelQI5:LoadValue("QI5_OK", "BR_LARANJA")
	EndCase   

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330St() 
Validas Status Informado Caso seja 5-"Reprovado", será aceito somente se 
Tiver integração com TMK ou PMS
@author Luiz Henrique Bourscheid
@since 30/05/2018
@version P12
/*/
//-------------------------------------------------------------------
Function QNC330St() 
	Local cStatus := &(ReadVar())
	Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
	Local lRet    := .T.
	Local oModel    := FWModelActive()
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")
	
	IF Empty(cStatus)
		cStatus:= oModelQI5:GetValue("QI5_STATUS") 
	EndIf
	
	If AllTrim(cStatus) == '5' .And. !lTMKPMS	//-- Rejeitado
		MsgAlert(STR0114)
		lRet := .F.
	EndIf		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330NCAU()
Inicializador do campo QI6_NCAUSA
@author Luiz Henrique Bourscheid
@since 22/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330NCAU()
	Local cDesc
	Local oModel    := FWModelActive()
	Local oModelQI6 := oModel:GetModel("QI6DETAIL")

	IF oModel:GetOperation() <> MODEL_OPERATION_INSERT
			cDesc := POSICIONE("QI0", 1, XFILIAL("QI0")+"1"+QI6->QI6_CAUSA, "QI0_DESC")
	Else
			cDesc := ""    
	Endif

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330ChkAca()
Programa para validacao dos codigo de Planos de Acao
@author Luiz Henrique Bourscheid
@since 25/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330ChkAca()
	Local lRet   		:= .F.
	Local oModel 		:= FWModelActive()
	Local oModelQI3 := oModel:GetModel("QI3MASTER")
	Local cChave 		:= Right(oModelQI3:GetValue("QI3_CODIGO"),4) + oModelQI3:GetValue("QI3_CODIGO")	

	If !Empty(oModelQI3:GetValue("QI3_REV"))
		cChave := cChave + oModelQI3:GetValue("QI3_REV")
	EndIf

	If Empty(cChave)
		lRet := .T.
	Else
		If QI3->(dbSeek(xFilial("QI3")+cChave))
			lRet := .T.    
			IF !Empty(oModelQI3:GetValue("QI3_REV"))
				IF oModelQI3:GetValue("QI3_OBSOL") == "N"
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
	If ExistBlock('QN040AUT')
		lRet := ExecBlock('QN040AUT',.F., .F.,{QNCUSUARIO()[2], QNCUSUARIO()[3]})
	EndIf

	IF !lRet
		Help(" ",1,"QNC040NCAC")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330ChkAca()
Programa para validacao dos codigo de não conformidade
@author Luiz Henrique Bourscheid
@since 25/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330ChkFnc()
	Local lRet  		 := .F. 
	Local cMvValid 	 := GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
	Local cStatPlano := AllTrim(GetMv("MV_QNCSFNC",.F.,"3"))
	Local oModel 		 := FWModelActive()
	Local oModelQI9  := oModel:GetModel("QI9DETAIL")
	Local cChave
	
	If !Empty(oModelQI9:GetValue("QI9_CODIGO")) .AND. !Empty(oModelQI9:GetValue("QI9_REV")) .AND. !Empty(oModelQI9:GetValue("QI9_FNC")) .AND. !Empty(oModelQI9:GetValue("QI9_REVFNC"))

		cCodFNC = oModelQI9:GetValue("QI9_FNC")
		cCodRev = oModelQI9:GetValue("QI9_REVFNC")

		cChave := AllTrim(Right(cCodFNC,4)) + cCodFNC + If(!Empty(cCodRev), cCodRev, "")

		dbSelectArea("QI2")
		QI2->(dBSetOrder(1))
		If QI2->(dbSeek(xFilial("QI2")+cChave))
			If cMvValid == "1"
				If !Empty(cCodRev)
					If QI2->QI2_STATUS $ cStatPlano .And. QI2->QI2_OBSOL == "N"
						lRet := .T.
					Endif
				Else 
					lRet := .T.	
				Endif
			Else 
				lRet := .T.	
			Endif
		Endif

		If !lRet
			Help(" ",2,"QNC040NCAC")
			oModelQI9:LoadValue("QI9_FNC", "")
		EndIf
	Else
		lRet := .T.	
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330DesQIB()
Programa para buscar a descricao do Cad.de Modelos
@author Luiz Henrique Bourscheid
@since 26/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330DesQIB()
	Local cRet 			:= Space(1)
	Local oModel 		:= FWModelActive()
	Local oModelQI3 := oModel:GetModel("QI3MASTER")

	cRet := FQNCDQIB(oModelQI3:GetValue("QI3_MODELO"))                                                                              

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330DesCli()
Programa para Buscar Nome/Nome Reduzido Cliente
@author Luiz Henrique Bourscheid
@since 26/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330DesCli()
	Local cRet 			:= ""
	Local oModel 		:= FWModelActive()
	Local oModelQI3 := oModel:GetModel("QI3MASTER")

	cRet := FQncDesCli(oModelQI3:GetValue("QI3_CODCLI"), oModelQI3:GetValue("QI3_LOJCLI"), "1")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330VldAlt()
Valida se Usuario pode alterar o Plano/Etapas
@author Luiz Henrique Bourscheid
@since 26/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330VldAlt()
	Local lRet 			:= .T.
	Local oModel 		:= FWModelActive()
	Local oModelQI3 := oModel:GetModel("QI3MASTER")

	If Q330AltEta() .Or. Q330AltPla()
		lRet := QN330AETAP()
	Else
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330AltEta()
Verifica se o usuário pode alterar as etapas.
@author Luiz Henrique Bourscheid
@since 26/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330AltEta()
	Local lRet 			 := .F.
	Local lMvQncAEta := If(GetMv("MV_QNCAETA",.F.,"2") == "1",.T.,.F.) // Define se usuario pode alterar a etapa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o usuario corrente podera alterar descricoes das etapas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QI3->QI3_OBSOL <> "S" .And. lMvQncAEta
		If !Q330AltPla()
			If QN030VdAlt(QI3->QI3_FILIAL, QI3->QI3_CODIGO, QI3->QI3_REV)
				lRet := .T.
			EndIf
		EndIf
  EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330AltPla()
Verifica se o usuário pode alterar os planos.
@author Luiz Henrique Bourscheid
@since 26/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330AltPla()
	Local cChaveQI3		:= QI3->QI3_FILIAL+QI3->QI3_CODIGO
	Local cMvQnAltPla := GetMv("MV_QNCAPLA",.F.,"1")
	Local aUsrMat  	  := QNCUSUARIO()
	Local cMatFil  	  := aUsrMat[2]
	Local cMatCod     := aUsrMat[3]
	Local lRet 				:= .T.
	Local nOrdQI3
	Local nRegQI3

	nOrdQI3 := QI3->(IndexOrd())
	nRegQI3 := QI3->(Recno())

	QI3->(dbSetOrder(2))
	If QI3->(dbSeek(cChaveQI3+QI3->QI3_REV))
		QI3->(dbSkip())
		While QI3->(!Eof()) .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
			lRet := .F.
			QI3->(dbSkip())
		Enddo
	EndIf

	QI3->(dbSetOrder(nOrdQI3))
	QI3->(dbGoTo(nRegQI3))

	If QI3->QI3_OBSOL == "S"
		If !Empty(QI3->QI3_ENCREA) .OR. (cMvQnAltPla == "1"  .AND. cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT)
			If GetMv("MV_QTMKPMS",.F.,1) == 2
				lRet := .T.
			Else
				lRet := .F.
			EndIf
    EndIf
  
		// Ponto de entrada para liberar alteracao e inclusao  por usuarios que nao sejam o Responsavel
		If ExistBlock('QNC030USU')
			lRetPE := ExecBlock('QNC030USU',.F., .F.,{cMatFil,cMatCod})
			If ValType(lRetPE) == "L"
				lRet := lRetPE
			EndIf
		EndIf
  EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
Método que é chamado pelo MVC quando ocorrer as ações do commit 
Após as gravações porém antes do final da transação.
@author thiago.rover
@since 29/04/2021
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) Class QNCA330EVDEF

Local lRet := .T.

If !IsBlind()
	If lModFNC
		Help(,, "ATENÇÃO", NIL, "O número sequencial do Plano de Ação foi alterado, pois outro usuário acaba de gravá-lo. Novo número "+oModel:GetValue("QI3MASTER","QI3_CODIGO"), 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifica o número, pois será gerado um novo número."})
	Endif
Endif

Return lRet
