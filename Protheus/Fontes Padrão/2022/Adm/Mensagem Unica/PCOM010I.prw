#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#include 'PCOM010I.CH'

Static cMessage := "ExportOfBudgetMovements"
Static cDirDiv  := If(IsSrvUnix(), "/", "\")
Static cStartPath := GetSrvProfString("STARTPATH", "")

/*/{Protheus.doc} PCOM010I
Mensagem única de exportação TXT de movimentos orçamentários - ExportOfBudgetMovements

@param  cXml          Variável com conteúdo XML para envio/recebimento.
@param  cTypeTrans    Tipo de transação (Envio / Recebimento).
@param  cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param  cVersion      Versão da mensagem.
@param  cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author Alison Kaique
@since 22/05/2018
@version MP12.1.17
/*/
Function PCOM010I(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local lRet       := .T.
Local cXmlRet    := ""
Local cErroXml   := ""
Local cWarnXml   := ""
Local aAutoCab   := {}
Local aErroAuto  := {}
Local oXmlMsg    := nil
Local oBContent  := nil
Local nPorta     := 0
Local nPonto     := 0
Local cAdress    := ""
Local cUser, cPassw
Local cFile      := ""
Local cCompress  := ""
Local cDestino   := ""
Local cMarca     := ""
Local cAuxDePara := ""
Local aStruct    := {}
Local nPosIni    := 0
Local nX

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

Do Case
	// Verificação do tipo de transação: recebimento ou envio.
	Case  cTypeTrans == TRANS_SEND  //Nesta mensagem nao sera tratado o envio, apenas o recebimento.

	Case  cTypeTrans == TRANS_RECEIVE
		If (cTypeMsg == EAI_MESSAGE_WHOIS)
			cXmlRet := '2.000|2.001'
		ElseIF (cTypeMsg == EAI_MESSAGE_RESPONSE)

		ElseIF (cTypeMsg == EAI_MESSAGE_BUSINESS)
			If FindFunction("CFGA070INT")
				oXmlMsg := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
				If oXmlMsg <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
					oBContent := oXmlMsg:_TotvsMessage:_BusinessMessage:_BusinessContent
					If XmlChildEx(oBContent, '_FTPADRESS') != Nil
						If lower(oBContent:_FTPAdress:Text) = "file://"
							cAdress := AllTrim(oBContent:_FTPAdress:Text)
						Else
							nPonto  := RAT(":", oBContent:_FTPAdress:Text) // IP:Porta
							If nPonto > 0
								cAdress := AllTrim(SubStr(oBContent:_FTPAdress:Text, 1, nPonto - 1))
								nPorta  := Val(SubStr(oBContent:_FTPAdress:Text, nPonto + 1))
							Else
								cAdress := AllTrim(oBContent:_FTPAdress:Text)
								nPorta  := 21
							Endif

							If XmlChildEx(oBContent, '_FTPUSER') != Nil
								cUser := oBContent:_FTPUser:Text
							EndIf
							If XmlChildEx(oBContent, '_FTPPASSWORD') != Nil
								cPassw := oBContent:_FTPPassWord:Text
							EndIf
						EndIf
					Else
						cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0003) + '</Message>' // É obrigatório informar o endereço FTP para gravação do arquivo TXT.
						lRet := .F.
					EndIf

					If lRet
						If Type("oXmlMsg:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
							cMarca := oXmlMsg:_TotvsMessage:_MessageInformation:_Product:_Name:Text
						EndIf

						// Data inicial
						If XmlChildEx(oBContent, '_INITIALDATE') != Nil
						  	aAdd(aAutoCab, {"MV_PAR01", StoD(STRTran(oBContent:_InitialDate:Text,'-'))})
						EndIf

						// Data final
						If XmlChildEx(oBContent, '_FINALDATE') != Nil
						  	aAdd(aAutoCab, {"MV_PAR02", StoD(STRtran(oBContent:_FinalDate:Text,'-'))})
						EndIf

						// Tipo de saldo
						If XmlChildEx(oBContent, '_SLDTYPE') != Nil
						  	aAdd(aAutoCab, {"MV_PAR03", oBContent:_SldType:Text})
						EndIf

						// Filial inicial
						If XmlChildEx(oBContent, '_INITIALBRANCHINTERNALID') != Nil .and. !Empty(oBContent:_InitialBranchInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', oBContent:_InitialBranchInternalId:Text)
							aAdd(aAutoCab, {"MV_PAR04", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALBRANCH') != Nil
							aAdd(aAutoCab, {"MV_PAR04", Padr(oBContent:_InitialBranch:Text, Len(cFilAnt))})
						EndIf

						// Filial final
						If XmlChildEx(oBContent, '_FINALBRANCHINTERNALID') != Nil .and. !Empty(oBContent:_FinalBranchInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', oBContent:_FinalBranchInternalId:Text)
							aAdd(aAutoCab, {"MV_PAR05", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALBRANCH') != Nil
							aAdd(aAutoCab, {"MV_PAR05", Padr(oBContent:_FinalBranch:Text,Len(cFilAnt))})
						EndIf

						// Conta orçamentária inicial
						If XmlChildEx(oBContent, '_INITIALBUDGETACCOUNTINTERNALID') != Nil .and. !Empty(oBContent:_InitialBudgetAccountInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AK5', 'AK5_CODIGO', oBContent:_InitialBudgetAccountInternalId:Text)
							aAdd(aAutoCab, {"MV_PAR06", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALBUDGETACCOUNT') != Nil
							aAdd(aAutoCab, {"MV_PAR06", Padr(oBContent:_InitialBudgetAccount:Text,TamSX3("AK5_CODIGO")[1])})
						EndIf

						// Conta orçamentária final
						If XmlChildEx(oBContent, '_FINALBUDGETACCOUNTINTERNALID') != Nil .and. !Empty(oBContent:_FinalBudgetAccountInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AK5', 'AK5_CODIGO', oBContent:_FinalBudgetAccountInternalId:Text)
							aAdd(aAutoCab, {"MV_PAR07", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALBUDGETACCOUNT') != Nil
							aAdd(aAutoCab, {"MV_PAR07", Padr(oBContent:_FinalBudgetAccount:Text,TamSX3("AK5_CODIGO")[1])})
						EndIf

						// Classe orçamentária inicial
						If XmlChildEx(oBContent, '_INITIALBUDGETCLASSINTERNALID') != Nil .and. !Empty(oBContent:_InitialBudgetClassInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AK6', 'AK6_CODIGO', oBContent:_InitialBudgetClassInternalId:Text)
							aAdd(aAutoCab, {"MV_PAR08", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALBUDGETCLASS') != Nil
							aAdd(aAutoCab, {"MV_PAR08", Padr(oBContent:_InitialBudgetClass:Text,TamSX3("AK6_CODIGO")[1])})
						EndIf

						// Classe oramentária final
						If XmlChildEx(oBContent, '_FINALBUDGETCLASSINTERNALID') != Nil .and. !Empty(oBContent:_FinalBudgetClassInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AK6', 'AK6_CODIGO', oBContent:_FinalBudgetClassInternalId:Text)
							aAdd(aAutoCab, {"MV_PAR09", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALBUDGETCLASS') != Nil
							aAdd(aAutoCab, {"MV_PAR09",Padr(oBContent:_FinalBudgetClass:Text,TamSX3("AK6_CODIGO")[1])})
						EndIf

						// Operação orçamentária inicial
						If XmlChildEx(oBContent, '_INITIALBUDGETOPERATIONINTERNALID') != Nil .and. !Empty(oBContent:_InitialBudgetOperationInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AKF', 'AKF_CODIGO', oBContent:_InitialBudgetOperationInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR10", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALBUDGETOPERATION') != Nil
							aAdd(aAutoCab,{"MV_PAR10", Padr(oBContent:_InitialBudgetOperation:Text,TamSX3("AKF_CODIGO")[1])})
						EndIf

						// Operação orçamentária final
						If XmlChildEx(oBContent, '_FINALBUDGETOPERATIONINTERNALID') != Nil .and. !Empty(oBContent:_FinalBudgetOperationInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AKF', 'AKF_CODIGO', oBContent:_FinalBudgetOperationInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR11", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALBUDGETOPERATION') != Nil
							aAdd(aAutoCab,{"MV_PAR11", Padr(oBContent:_FinalBudgetOperation:Text,TamSX3("AKF_CODIGO")[1])})
						EndIf

						// Unidade orçamentária inicial
						If XmlChildEx(oBContent, '_INITIALBUDGETUNITYINTERNALID') != Nil .and. !Empty(oBContent:_InitialBudgetUnityInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AMF', 'AMF_CODIGO', oBContent:_InitialBudgetUnityInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR12", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALBUDGETUNITY') != Nil
							aAdd(aAutoCab,{"MV_PAR12", Padr(oBContent:_InitialBudgetUnity:Text,TamSX3("AMF_CODIGO")[1])})
						EndIf

						// Unidade orçamentária final
						If XmlChildEx(oBContent, '_FINALBUDGETUNITYINTERNALID') != Nil .and. !Empty(oBContent:_FinalBudgetUnityInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'AMF', 'AMF_CODIGO', oBContent:_FinalBudgetUnityInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR13", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALBUDGETUNITY') != Nil
							aAdd(aAutoCab,{"MV_PAR13", Padr(oBContent:_FinalBudgetUnity:Text,TamSX3("AMF_CODIGO")[1])})
						EndIf

						// Centro de custo inicial
						If XmlChildEx(oBContent, '_INITIALCOSTCENTERINTERNALID') != Nil .and. !Empty(oBContent:_InitialCostCenterInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'CTT', 'CTT_CUSTO', oBContent:_InitialCostCenterInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR14", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALCOSTCENTER') != Nil
							aAdd(aAutoCab,{"MV_PAR14", Padr(oBContent:_InitialCostCenter:Text,TamSX3("CTT_CUSTO")[1])})
						EndIf

						// Centro de custo final
						If XmlChildEx(oBContent, '_FINALCOSTCENTERINTERNALID') != Nil .and. !Empty(oBContent:_FinalCostCenterInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'CTT', 'CTT_CUSTO', oBContent:_FinalCostCenterInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR15", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALCOSTCENTER') != Nil
							aAdd(aAutoCab,{"MV_PAR15", Padr(oBContent:_FinalCostCenter:Text,TamSX3("CTT_CUSTO")[1])})
						EndIf

						// Item contábil inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTITEMINTERNALID') != Nil .and. !Empty(oBContent:_InitialAccountItemInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'CTD', 'CTD_ITEM', oBContent:_InitialAccountItemInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR16", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNTITEM') != Nil
							aAdd(aAutoCab,{"MV_PAR16", Padr(oBContent:_InitialAccountItem:Text,TamSX3("CTD_ITEM")[1])})
						EndIf

						// Item contábil final
						If XmlChildEx(oBContent, '_FINALACCOUNTITEMINTERNALID') != Nil .and. !Empty(oBContent:_FinalAccountItemInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'CTD', 'CTD_ITEM', oBContent:_FinalAccountItemInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR17", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNTITEM') != Nil
							aAdd(aAutoCab,{"MV_PAR17", Padr(oBContent:_FinalAccountItem:Text,TamSX3("CTD_ITEM")[1])})
						EndIf

						// Classe de valor inicial
						If XmlChildEx(oBContent, '_INITIALCLASSVALUEINTERNALID') != Nil .and. !Empty(oBContent:_InitialClassValueInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'CTH', 'CTH_CLVL', oBContent:_InitialClassValueInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR18", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALCLASSVALUE') != Nil
							aAdd(aAutoCab,{"MV_PAR18", Padr(oBContent:_InitialClassValue:Text,TamSX3("CTH_CLVL")[1])})
						EndIf

						// Classe de valor final
						If XmlChildEx(oBContent, '_FINALCLASSVALUEINTERNALID') != Nil .and. !Empty(oBContent:_FinalClassValueInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'CTH', 'CTH_CLVL', oBContent:_FinalClassValueInternalId:Text)
							aAdd(aAutoCab,{"MV_PAR19", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALCLASSVALUE') != Nil
							aAdd(aAutoCab,{"MV_PAR19", Padr(oBContent:_FinalClassValue:Text,TamSX3("CTH_CLVL")[1])})
						EndIf

						// Nome do arquivo
						If XmlChildEx(oBContent, '_FILENAME') != Nil
						  	cFile:=FileInteg(oBContent:_FileName:Text) // Retira o diretório do nome do arquivo.
						  	aAdd(aAutoCab,{"MV_PAR20", cFile})
						EndIf

						// Conteúdo comprimido.
						If XmlChildEx(oBContent, '_COMPRESS') != Nil
						  	cCompress := (oBContent:_Compress:Text)
						EndIf

						// Entidade contábil 5 inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTENT5INTERNALID') != Nil .and. !Empty(oBContent:_InitialAccountEnt5InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_InitialAccountEnt5InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT05DE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNTENT5') != Nil
							aAdd(aAutoCab,{"ENTCONT05DE", Padr(oBContent:_InitialAccountEnt5:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 5 final
						If XmlChildEx(oBContent, '_FINALACCOUNTENT5INTERNALID') != Nil .and. !Empty(oBContent:_FinalAccountEnt5InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_FinalAccountEnt5InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT05ATE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNTENT5') != Nil
							aAdd(aAutoCab,{"ENTCONT05ATE", Padr(oBContent:_FinalAccountEnt5:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 6 inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTENT6INTERNALID') != Nil .and. !Empty(oBContent:_InitialAccountEnt6InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_InitialAccountEnt6InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT06DE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNTENT6') != Nil
							aAdd(aAutoCab,{"ENTCONT06DE", Padr(oBContent:_InitialAccountEnt6:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 6 final
						If XmlChildEx(oBContent, '_FINALACCOUNTENT6INTERNALID') != Nil .and. !Empty(oBContent:_FinalAccountEnt6InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_FinalAccountEnt6InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT06ATE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNTENT6') != Nil
							aAdd(aAutoCab,{"ENTCONT06ATE", Padr(oBContent:_FinalAccountEnt6:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 7 inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTENT7INTERNALID') != Nil .and. !Empty(oBContent:_InitialAccountEnt7InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_InitialAccountEnt7InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT07DE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNTENT7') != Nil
							aAdd(aAutoCab,{"ENTCONT07DE", Padr(oBContent:_InitialAccountEnt7:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 7 final
						If XmlChildEx(oBContent, '_FINALACCOUNTENT7INTERNALID') != Nil .and. !Empty(oBContent:_FinalAccountEnt7InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_FinalAccountEnt7InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT07ATE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNTENT7') != Nil
							aAdd(aAutoCab,{"ENTCONT07ATE", Padr(oBContent:_FinalAccountEnt7:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 8 inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTENT8INTERNALID') != Nil .and. !Empty(oBContent:_InitialAccountEnt8InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_InitialAccountEnt8InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT08DE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNTENT8') != Nil
							aAdd(aAutoCab,{"ENTCONT08DE", Padr(oBContent:_InitialAccountEnt8:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 8 final
						If XmlChildEx(oBContent, '_FINALACCOUNTENT8INTERNALID') != Nil .and. !Empty(oBContent:_FinalAccountEnt8InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_FinalAccountEnt8InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT08ATE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNTENT8') != Nil
							aAdd(aAutoCab,{"ENTCONT08ATE", Padr(oBContent:_FinalAccountEnt8:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 9 inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTENT9INTERNALID') != Nil .and. !Empty(oBContent:_InitialAccountEnt9InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_InitialAccountEnt9InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT09DE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNTENT9') != Nil
							aAdd(aAutoCab,{"ENTCONT09DE", Padr(oBContent:_InitialAccountEnt9:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						// Entidade contábil 9 final
						If XmlChildEx(oBContent, '_FINALACCOUNTENT9INTERNALID') != Nil .and. !Empty(oBContent:_FinalAccountEnt9InternalId:Text)
							cAuxDePara := IntGerInt(oBContent:_FinalAccountEnt9InternalId:Text, cMarca)[2, 4]
							aAdd(aAutoCab,{"ENTCONT09ATE", cAuxDePara})
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNTENT9') != Nil
							aAdd(aAutoCab,{"ENTCONT09ATE", Padr(oBContent:_FinalAccountEnt9:Text, TamSX3("CV0_CODIGO")[1])})
						EndIf

						MsExecAuto({|x| PCOM010(x)}, aAutoCab)
						If lMsErroAuto
							lRet := .F.
							aErroAuto := GetAutoGRLog()
							For nX := 1 To Len(aErroAuto)
								cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(AllTrim(aErroAuto[nX])) + '</Message>'
							Next nX
						Else
							lRet := .T.

							// Comprime o arquivo, se solicitado pelo cliente.
							If lower(cCompress) = "zip"
								If FZip(cFile + ".zip", {cFile}, cDirDiv) = 0
									FErase(cFile)  // Apaga o arquivo da system.
									cFile += ".zip"
								Else
									cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0008) + cValtoChar(FError()) + '</Message>' // "Não foi possível comprimir o arquivo. Erro "
									lRet := .F.
								Endif
							ElseIf lower(cCompress) = "gz"
								If GzCompress(cFile, cFile + ".gz", .F.)
									FErase(cFile)  // Apaga o arquivo da system.
									cFile += ".gz"
								Else
									cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0008) + cValtoChar(FError()) + '</Message>' // "Não foi possível comprimir o arquivo. Erro "
									lRet := .F.
								Endif
							ElseIf !empty(cCompress)
								cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0008) + cCompress + '</Message>' // "Não foi possível comprimir o arquivo. Erro "
								lRet := .F.
							Endif

							If lRet
								If at("://", cAdress) = 0
									cAdress := "ftp://" + cAdress
								Endif

								If lower(cAdress) = "file://"
									// Monta o nome da pasta de destino.
									cDestino := StrTran(SubStr(cAdress, 8), "/", cDirDiv)
									If (at(":", cDestino) = 0 .and. cDestino != cDirDiv + cDirDiv)
										cDestino := cDirDiv + cDirDiv + cDestino
									Endif
									cDestino += If(right(cDestino, 1) = cDirDiv, "", cDirDiv) + cFile

									If FRenameEx(cFile, cDestino) < 0
										FErase(cFile)  // Apaga o arquivo da system.
										cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0004) + '</Message>'//Não foi possível a carga do arquivo no FTP. Verifique as permissões e tente novamente.
										lRet := .F.
									Endif
									cDestino := StrTran(cDestino, "\", "/")
									cDestino := If(cDestino = "//", "file:", "file://") + cDestino

								ElseIf lower(cAdress) = "ftp://"
									cAdress := SubStr(cAdress, 7)

									If FTPCONNECT(cAdress, nPorta, cUser, cPassw)
										FTPSETPASV(.F.)

										// Para o upload, é necessario informar o caminho inteiro do servidor (\SYSTEM\).
										If right(cStartPath, 1) <> cDirDiv
											cStartPath += cDirDiv
										Endif

										// Forço a entrada, tentando duas vezes
										IF !FTPUPLOAD(cStartPath + cFile, cFile) .and. !FTPUPLOAD(cStartPath + cFile, cFile)
											cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0004) + '</Message>' // Não foi possível a carga do arquivo no FTP. Verifique as permissões e tente novamente.
											lRet := .F.
										EndIf
										FTPDisconnect()
										FErase(cFile)

										// Nome absoluto do arquivo enviado para o FTP.
										cDestino := "ftp://" + cAdress + ":" + cValtoChar(nPorta) + "/" + cFile
									Else
										cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0005) + '</Message>' // Não foi possível a conexão com o servidor FTP informado. Verifique.
										lRet := .F.
									EndIf
								Else
									cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0004) + '</Message>'//Não foi possível a carga do arquivo no FTP. Verifique as permissões e tente novamente.
									lRet := .F.
								Endif

								If lRet
									cXmlRet += "<File>" + _NoTags(cDestino) + "</File>"
									If Val(cVersion) > 2  // Da versão 2.001 em diante.
										cXmlRet += "<Structure>"
										aStruct := PCO010X3(.F.)
										nPosIni := 1
										For nX := 1 to len(aStruct)
											cXmlRet += "<Field>"
											cXmlRet +=  "<Order>" + cValtoChar(nX) + "</Order>"
											cXmlRet +=  "<Field>" + AllTrim(aStruct[nX, 2]) + "</Field>"
											cXmlRet +=  "<Description>" + _NoTags(AllTrim(aStruct[nX, 3])) + "</Description>"
											cXmlRet +=  "<Type>" + aStruct[nX, 4] + "</Type>"
											cXmlRet +=  "<Length>"  + cValtoChar(aStruct[nX, 5]) + "</Length>"
											cXmlRet +=  "<Decimal>" + cValtoChar(aStruct[nX, 6]) + "</Decimal>"
											cXmlRet +=  "<InitialPosition>" + cValtoChar(nPosIni) + "</InitialPosition>"
											cXmlRet += "</Field>"
											nPosIni += aStruct[nX, 5]
										Next nX
										cXmlRet += "</Structure>"
									Endif
								Endif
							Endif
						EndIf
					EndIf
				Else
					cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0006) + '</Message>' // Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
					lRet := .F.
				EndIf
			Else
				cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0007) + '</Message>' // Para o funcionamento do EAI é necessário a última atualização da lib Protheus. Acione o Suporte Totvs.
				lRet := .F.
			EndIf
		EndIf
EndCase

Return {lRet, cXmlRet, cMessage}

/*/{Protheus.doc} FileInteg
Pega o nome do arquivo atraves do parâmetro informado e o devolve sem o diretório.

@param cFile nome do arquivo
@return cFile arquivo sem o diretorio

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
Static Function FileInteg(cFile)

Local nX

// Retira a barra no final do parâmetro, se houver.
cFile := AllTrim(cFile)
If Right(cFile, 1) == cDirDiv
	cFile := left(cFile, len(cFile) - 1)
EndIf

// Retira todo o driver e diretório do nome do arquivo.
nX := RAT(cDirDiv, cFile)
If nX > 0
	cFile := SubStr(cFile, nX + 1)
EndIf

Return cFile
