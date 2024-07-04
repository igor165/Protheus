#INCLUDE "PROTHEUS.CH"
#INCLUDE "QNCA040.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

//----------------------------------------------------------------------
/*/{Protheus.doc} QNCA340EVDEF
Eventos padrão da rotina de cadastro de cadastro de não conformidade.
@author Gustavo Della Giustina
@since 29/05/2018
@version P12.1.17 
/*/
//----------------------------------------------------------------------
CLASS QNCA340EVDEF FROM FWModelEvent
	
	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()
	METHOD After()
	METHOD Activate()
	METHOD ModelPosVld()
	METHOD BeforeTTS()
	METHOD InTTS()

ENDCLASS

METHOD New() CLASS  QNCA340EVDEF
	
Return Nil



//----------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Método de Antes do Commit, após a validação
@author Luiz Henrique Bourscheid
@since 28/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) Class QNCA340EVDEF
	Local lRet := .T.
	Local oModelQI2 := oModel:GetModel("QI2MASTER")
	
	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf

	If Type("lModFNC") != "L"
		Private lModFNC := .F.
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and. lRevisao
		 oModelQI2:SetValue("QI2_MEMO4", cMemo4)
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !IsBlind()
		cCodSeq := GETNEXTNUM(M->QI2_ANO)
		IF !(cCodSeq == oModelQI2:GetValue("QI2_FNC")) 
			oModelQI2:SetValue("QI2_FNC", cCodSeq)
			lModFNC := .T.
		Endif
	Endif
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
METHOD ModelPosVld(oModel, cModelId) Class QNCA340EVDEF
	Local lRet 	 	:= .T.
	Local oModelQI2 := oModel:GetModel("QI2MASTER")
	Local lMvFNCPLN := If(GetMv("MV_QFNCPLN",.F.,"2")=="1",.T.,.F.)
	Local lTmkPms   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
	Local oModel  := FWModelActive() 
	Local oModelQI2 := oModel:GetModel("QI2MASTER")
	
	If !(oModelQI2:GetValue("QI2_ORIGEM") $ "QNC|QAD") .and. cModulo == "QNC" .And. oModelQI2:GetOperation() == 5
		MsgAlert(STR0100+Alltrim(QI2->QI2_ORIGEM))//Nao e possivel a delecao da Nao-Conformidade, porque a origem da mesma pertence ao ambiente "			
		lRet := .F.
	Else
		lRet := .T.
	Endif
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	If !Empty(oModelQI2:GetValue("QI2_CODFOR")) .And. dbSeek(xFilial("SA2")+oModelQI2:GetValue("QI2_CODFOR")+oModelQI2:GetValue("QI2_LOJFOR"))
		If SA2->A2_MSBLQL == "1"
			lRet:=.F.
			MessageDlg(STR0103) //"Fornecedor selecionado está inativo" 
		Endif
	Endif
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	If !Empty(oModelQI2:GetValue("QI2_CODCLI")) .And. dbSeek(xFilial("SA1")+oModelQI2:GetValue("QI2_CODCLI")+oModelQI2:GetValue("QI2_LOJCLI"))
		If SA1->A1_MSBLQL == "1"
			lRet:=.F.          
			MessageDlg(STR0102)//"Cliente selecionado está inativo"
		Endif
	Endif  
	
	If !Empty(oModelQI2:GetValue("QI2_CODDOC"))
		dbSelectArea("QDH")
		dbSetOrder(1)
		if !dbSeek(xFilial("QDH")+oModelQI2:GetValue("QI2_CODDOC"))
			lRet:=.F.          
			MessageDlg("Documento inexistente no cadastro de documentos")
		Endif
	Endif  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se filial/usuario do responsavel estao validos               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(oModelQI2:GetValue("QI2_FILRES")) .And. !Empty(oModelQI2:GetValue("QI2_MATRES"))
		If !QA_CHKMAT(oModelQI2:GetValue("QI2_FILRES"),oModelQI2:GetValue("QI2_MATRES"))
			lRet := .F.
		Endif
	Endif

	If oModelQI2:GetOperation() <> 4 .And. !Empty(oModelQI2:GetValue("QI2_FILMAT")) .And. !Empty(oModelQI2:GetValue("QI2_MAT"))
		If !QA_CHKMAT(oModelQI2:GetValue("QI2_FILMAT"),oModelQI2:GetValue("QI2_MAT"))
			lRet := .F.
		Endif
	Endif

	If lRet .And. ! Empty(oModelQI2:GetValue("QI2_CONREA")) .And. oModelQI2:GetValue("QI2_STATUS") < "3"
		MsgAlert(STR0093) //"A FNC nao podera ser encerrada em status [Registrada/Em Analise]"
		lRet := .F.
	Endif
	
	If lRet .And. oModelQI2:GetValue("QI2_STATUS") <> "5" .And. oModelQI2:GetValue("QI2_STATUS") <> "4" .And. ! Empty(oModelQI2:GetValue("QI2_CONREA")) 
		If ! Empty(oModelQI2:GetValue("QI2_CODACA")+oModelQI2:GetValue("QI2_REVACA"))
			QI3->(DbSetOrder(2))
			If 	QI3->(DbSeek(xFilial() + oModelQI2:GetValue("QI2_CODACA")+oModelQI2:GetValue("QI2_REVACA"))) .And.;
				Empty(QI3->QI3_ENCREA)
				ApMsgAlert(STR0092) //"Atencao e necessario finalizar o plano de acao para finalizacao da FNC !"
				lRet := .F.
			Endif
		Endif
	Endif
	
	IF lRet  .And. lMvFNCPLN .AND. oModelQI2:GetValue("QI2_STATUS") == "3" .AND. Empty(oModelQI2:GetValue("QI2_CODACA")+oModelQI2:GetValue("QI2_REVACA")) //Procede
		MsgAlert(OemtoAnsi(STR0097))  //"A FNC não podera ser encerrada em status [Procede] sem a Criaçaõ do Plano de Açao, Conforme parametro MV_QFNCPLN"
		lRet := .F.
	Endif		
	
	IF lRet  .AND. !Empty(oModelQI2:GetValue("QI2_CONREA"))
		If oModelQI2:GetValue("QI2_CONREA") > dDataBase // Caso a data de conclusao seja maior que a data base bloqueio
			MsgAlert(STR0101) //"Data de encerramento da FNC nao pode ser maior que a data  base do sistema! "
			lRet := .F.
		EndIf
	Endif
	
	If oModelQI2:GetValue("QI2_STATUS") == "5" .And. Empty(oModelQI2:GetValue("QI2_CONREA"))
		MsgAlert(Left(OemToAnsi(STR0104),17)+'"'+RTrim(RetTitle("QI2_CONREA"))+'"'+Substr(OemToAnsi(STR0104),17),OemToAnsi(STR0105))
		lRet := .F.
	Endif

	If oModelQI2:GetValue("QI2_STATUS") == "4" .And. Empty(oModelQI2:GetValue("QI2_MEMO5")) .And. !IsBlind()
		Help( " ", 1, "QNCJUSTHELP")
		lRet := .F.
	EndIf

Return lRet 

//----------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Método de Ativação do modelo
@author Luiz Henrique Bourscheid
@since 28/05/2018
@version 1.0
@return lRet
/*/
//----------------------------------------------------------------------
METHOD Activate(oModel, lCopy) CLASS  QNCA340EVDEF
	Local aUsrMat     := QNCUSUARIO()
	Private cQPathFNC := Alltrim(GetMv("MV_QNCPDOC"))
	Private aQPath    := QDOPATH()
	Private cQPathTrm := aQPath[3]
	Private cFileTrm  := Space(1)

	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf

	If !Right( cQPathFNC,1 ) == "\"
		cQPathFNC := cQPathFNC + "\"
	Endif
	
	If !Right( cQPathTrm,1 ) == "\"
		cQPathTrm := cQPathTrm + "\"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o diretorio para gravacao do Docto Anexo Existe. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4 .Or. oModel:GetOperation() == 6
		nHandle := fCreate(cQPathFNC+"SIGATST.CEL")
		If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
			fClose(nHandle)
			fErase(cQPathFNC+"SIGATST.CEL")
		Else
		  Help("",1,"QNCDIRDCNE") // "O Diretorio definido no parametro MV_QNCPDOC" ### "para o Documento Anexo nao existe."
		  Return 3
		EndIf
	EndIf
	
	If lRevisao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os registros dos sub-Cadastros               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:LoadValue("QI2MASTER","QI2_FILMAT", aUsrMat[2])
		oModel:LoadValue("QI2MASTER","QI2_MAT",    aUsrMat[3])
		oModel:LoadValue("QI2MASTER","QI2_MATDEP", aUsrMat[4])
		oModel:LoadValue("QI2MASTER","QI2_REV",    StrZero(Val(M->QI2_REV)+1,2))
		oModel:LoadValue("QI2MASTER","QI2_REGIST", dDataBase)
		oModel:LoadValue("QI2MASTER","QI2_OCORRE", dDataBase)
		oModel:LoadValue("QI2MASTER","QI2_CONPRE", dDatabase+30)
		oModel:LoadValue("QI2MASTER","QI2_CONREA", Ctod("  /  /  "))
		oModel:LoadValue("QI2MASTER","QI2_OBSOL",  "N")
		oModel:LoadValue("QI2MASTER","QI2_STATUS", "1")
		oModel:LoadValue("QI2MASTER","QI2_CODACA", TamSX3("QI2_CODACA")[1])
		oModel:LoadValue("QI2MASTER","QI2_REVACA", TamSX3("QI2_REVACA")[1])
	Endif


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS()
Método executado depois do commit durante a trasação.
@author Gustavo Della Giustina
@since 07/06/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) Class QNCA340EVDEF
	Local lRet      := .T.
	Local cDelAnexo := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
	
	If Type("aQNQI2") != "A"
		Private aQNQI2 := {}
	EndIf
	
	If Type("__lQNSX8") != "L"
		Private __lQNSX8 := .F.
	EndIf
	
	If oModel:GetOperation() == 3 .And. __lQNSX8 .And. Type("aQNQI2[1][1]") <> "U"
		ConfirmeQE(aQNQI2)
	Endif
	
	If isBlind()
		RecLock("QI2", .F.)
		If Empty(oModel:GetValue("QI2MASTER", "QI2_ORIGEM"))
			QI2->QI2_ORIGEM := "QNC"
		EndIf
		If Empty(oModel:GetValue("QI2MASTER", "QI2_DOCUME"))
			QI2->QI2_DOCUME := "S"
		EndIf
		If Empty(oModel:GetValue("QI2MASTER", "QI2_OBSOL"))
			QI2->QI2_OBSOL  := "N"
		EndIf
		QI2->(MsUnLock())
	EndIf

	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4	// Inclusao ou Alteracao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se FNC nao procede ou Cancelado, Finaliza o Plano.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->QI2_STATUS $ "4,5" .And. !Empty(M->QI2_CONREA)         
			QNC040FinPl()
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} After()
Método executado depois do commit fora da trasação.
@author Luiz Henrique Bourscheid
@since 27/06/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
METHOD After(oSubModel, cModelId, cAlias, lNewRecord) Class QNCA340EVDEF
	Local lErase     := .T.
	Local cDelAnexo  := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
	Local aArqFNC    := {}
	Local nT
	Local lRet 		 := .T.
	Local aUsuarios	 := {}
	Local cMsg       := ""
	Local cMensag	 := ""
	Local aUsrMat    := QNCUSUARIO()
	Local cTpMail    := "1"     
	Local nI         :=0
	Local cMailAdd   := GetMv("MV_QQUAEMA")
	Local lVQuaEma   := IIf(SuperGetMv( "MV_QQUAEMA" , .F. ,'') <> '',.T.,.F.)
	Local lenvcpy    := iif(getMv("MV_QQUAEMA") <> ' ',.T.,.F.)
	Local nAtConta   := 0
	Local cAttach 	 := ""
	Local cMail		 := ""
	Local cMatFil	 := aUsrMat[2]
	Local cMatCod    := aUsrMat[3]
	Local cEncAutPla := AllTrim(GetMv("MV_QNEAPLA",.F.,"1")) // Encerramento Automatico de Plano

	If Type("cQPathFNC") != "C"
		Private cQPathFNC := Alltrim(GetMv("MV_QNCPDOC"))
	EndIf
	
	If Type("aQPath") != "A"
		Private aQPath    := QDOPATH()
		Private cQPathTrm := aQPath[3]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foram baixadas todas etapas para baixar o Plano ³
	//³ Function chamada novamente pela falta do registro no QI9    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModelId == "QI2MASTER"  
		If cEncAutPla == "1" .And. oSubModel:GetValue("QI2_STATUS") == "3" .And. !Empty( oSubModel:GetValue("QI2_CODACA") ) .And.;
		!Empty( oSubModel:GetValue("QI2_REVACA") ) .And. Empty( oSubModel:GetValue("QI2_CONREA") ) 
			QN030BxPla( , oSubModel:GetValue("QI2_CODACA") , oSubModel:GetValue("QI2_REVACA") )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava ou Exclui o Documento anexo                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModelId == "QIFDETAIL"
		If oSubModel:GetOperation() == 3 .Or. oSubModel:GetOperation() == 4	// Inclusao ou Alteracao
			If QIF->(DbSeek(M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV))
				While QIF->(!Eof()) .And. QIF->QIF_FILIAL+QIF->QIF_FNC+QIF->QIF_REV == M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV
					cFileTrm:= AllTrim(QIF->QIF_ANEXO)
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
					QIF->(DbSkip())
				EndDo
			EndIf
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variavel de flag para identificar se pode apagar os anexos da FNC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lErase
		If cDelAnexo == "1"	
			aArqFNC := DIRECTORY(cQPathTrm+"*.*")
			For nT:= 1 to Len(aArqFNC)
				If 	M->QI2_FNC + "_" + M->QI2_REV + "_" =;
					Left(aArqFNC[nT,1], Len(M->QI2_FNC + "_" + M->QI2_REV + "_")) .And.;
					File(cQPathTrm+AllTrim(aArqFNC[nT,1]))
					FErase(cQPathTrm+AllTrim(aArqFNC[nT,1]))
			   Endif
			Next
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com SIGASGA - NG Informatica                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->QI2_CONREA) .and. SuperGetMV("MV_NGSGAQN",.F.,"2") == "1"
		SG510RQNC(M->QI2_FNC)
	Endif

	QAD->(dbSetOrder(1))
	QAA->(dbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Geracao de mensagens via e-mail para o responsavel da FNC    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModelId == "QI2MASTER"
		If oSubModel:GetOperation() == 3 .Or. oSubModel:GetOperation() == 4
			aUsuarios := {}
			If M->QI2_STATUS == "4" .Or. M->QI2_STATUS == "5"// Nao Procede ### Cancelada
				If !Empty(M->QI2_CONREA)
					If QAA->(dbSeek(M->QI2_FILRES + M->QI2_MATRES)) .And. QAA->QAA_RECMAI == "1"
						If QAA->QAA_FILIAL+QAA->QAA_MAT <> cMatFil+cMatCod
							cMail  := AllTrim(QAA->QAA_EMAIL)
							If M->QI2_STATUS == "4"
								cMensag:= OemToAnsi(STR0080) // "Ficha de Ocorrencia/Nao-Conformidade Nao Procede."
							ElseIf M->QI2_STATUS == "5"
								cMensag:= OemToAnsi(STR0081) // "Ficha de Ocorrencia/Nao-Conformidade Cancelada."
							EndIf
						Endif		
					Endif
				EndIf
				If M->QI2_STATUS == "4" .And. ( lVquaEma .or. cMatFil+cMatCod <> M->QI2_FILMAT+M->QI2_MAT) // Aviso de nao-procede para digitador
					If QAA->(dbSeek(M->QI2_FILMAT + M->QI2_MAT)) .And. QAA->QAA_RECMAI == "1"
						cMail   := AllTrim(QAA->QAA_EMAIL)
						cMensag := Iif(M->QI2_TPFIC = '3',STR0118,STR0119) // "Oportunidade de Melhoria" ## "Ficha de Ocorrencia/Nao-Conformidade"
						cMensag += " " + STR0120 //"Finalizada - Motivo: Considerada NAO PROCEDE pelo destinatário."
						If oSubModel:GetOperation() <> 3 
							RecLock( "QI2", .F. )
							QI2->QI2_CONREA := dDataBase // Encerra a FNC quando o Status for Nao Procede
							QI2->(MsUnlock())
						Endif
					Endif
				Endif
			Else

				If QAA->(dbSeek(M->QI2_FILRES + M->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
					If QAA->QAA_FILIAL+QAA->QAA_MAT <> cMatFil+cMatCod
						cMail := AllTrim(QAA->QAA_EMAIL)
						cMensag:= OemToAnsi(STR0042) // "Ficha de Ocorrencia/Nao-Conformidade iniciada."
					Endif
				Endif

			EndIf
			
			// Ponto de Entrada para incluir novos destinatarios nos e-mails de inclusao/alteracao de FNC
			If Existblock("QN40ADMAIL")
				If !Empty(cMail)
					cMail += ';' + Execblock("QN40ADMAIL",.F.,.F.,{M->QI2_FILRES,M->QI2_MATRES})
				Else
					cMail := Execblock("QN40ADMAIL",.F.,.F.,{M->QI2_FILRES,M->QI2_MATRES})
				Endif
			Endif

			If !Empty(cMail)

				cTpMail:= QAA->QAA_TPMAIL

				// FNC
				If cTpMail == "1"
					cMsg := QNCSENDMAIL(1,cMensag)
				Else
					cMsg += cMensag+CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0024)+DtoC(M->QI2_OCORRE)+OemToAnsi(STR0025)+DtoC(M->QI2_CONPRE)+CHR(13)+CHR(10)	 // "Ocorrencia/Nao-conformidade em " ### " Data Prevista p/ Conclusao: "
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0026)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
					cMsg += M->QI2_MEMO1+CHR(13)+CHR(10)
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0027)+CHR(13)+CHR(10)	// "Atenciosamente "
					cMsg += PADR(QA_NUSR(cMatFil,cMatCod),40)+CHR(13)+CHR(10)
					cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
					cMsg += CHR(13)+CHR(10)
					cMsg += OemToAnsi(STR0028) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
				Endif
				
				cAttach := ""
				aMsg:= {{OemToAnsi(Iif(M->QI2_TPFIC = '3',STR0118,STR0023))+" "+;
				TransForm(M->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+M->QI2_REV+Space(10)+DTOC(Date())+"-"+;
				SubStr(TIME(),1,5)+Iif(M->QI2_STATUS = '4'," "+STR0121,'') , cMsg, cAttach } }	//"Oportunidade de Melhoria" ## "Ocorrencia/Nao-conformidade No. " ## "Finalizada"
			
				// Geracao de Mensagem
				IF ExistBlock( "QNCFICHA" )
					aMsg := ExecBlock( "QNCFICHA", .f., .f. )
				Endif

				aUsuarios := {{QAA->QAA_LOGIN, cMail, aMsg} }
				if lenvcpy
					If "@" $ cmailAdd
						If ";" $ cMailAdd 
							if SubStr(cMailAdd,Len(cMailAdd)-1,1) <> ";"
								cmailAdd:= Alltrim(cMailAdd)+";"
							Endif
							for nI := 1 to len(alltrim(cMailAdd))
								nAtConta  := AT(";",cMailAdd)
								if SubStr(cMailAdd,1,nAtConta-1) <> ' ' .and. "@" $ SubStr(cMailAdd,1,nAtConta-1)	
									aAdd (aUsuarios,{QAA->QAA_LOGIN, SubStr(cMailAdd,1,nAtConta-1), aMsg})	
								Endif
								cMailAdd  := Substr(cMailAdd,nAtConta+1,len(cMailAdd))
								if nAtConta < 2 	
									Exit
								Endif
								nI := len(alltrim(cMailAdd))
							Next nI
						else
							aAdd (aUsuarios,{QAA->QAA_LOGIN,alltrim(cMailAdd), aMsg})
						Endif
					Endif
				Endif		
					
				QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
			
			Endif
		Endif
	EndIf

	IF ExistBlock( "QNCNCFIM" )
		ExecBlock( "QNCNCFIM", .f., .f., {oSubModel:GetOperation(), M->QI2_FNC, M->QI2_REV, 1})
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q340VTPMS()
Verifica se ja existe FNC no PMS. Em caso afirmativo, não permite a cancelar a FNC.
@author Luiz Henrique Bourscheid
@since 27/06/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q340VTPMS()
	Local lRet	  	:= .T.
	Local lTmkPms 	:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
	Local oModel  	:= FWModelActive()
	Local oModelQI2 := oModel:GetModel("QI2MASTER")

	If oModel:GetOperation() <> MODEL_OPERATION_VIEW .And. lTmkPms
		If GetMv("MV_QTMKPMS",.F.,1) == 3 .or. GetMv("MV_QTMKPMS",.F.,1) == 4
			DbselectArea("AF9")
			AF9->(dbSetOrder(6))
			If AF9->(MsSeek(xFilial("AF9")+oModelQI2:GetValue("QI2_FNC")+oModelQI2:GetValue("QI2_REV")))
			MessageDlg(STR0114) //"Esta FNC e/ou Plano ja esta/estao amarrado(s) na(s) tarefa(s) - Monitor PMS. Deve-se salvar a FNC, executar a tarefa rejeitando-a."
			lRet := .F.			
			Endif                         
		Endif
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
METHOD InTTS(oModel, cModelId) Class QNCA340EVDEF

Local lRet := .T.

If !IsBlind()
	If lModFNC
		Help(,, "ATENÇÃO", NIL, "O número sequencial dessa Não Conformidade foi alterado, pois outro usuário acaba de gravá-lo. Novo número "+oModel:GetValue("QI2MASTER","QI2_FNC"), 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifica o número, pois será gerado um novo número."})
	Endif
Endif

Return lRet