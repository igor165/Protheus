#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#include 'CTBI420.CH'

Static cMessage   := 'ExportOfAccountMovements'
Static cDirDiv    := If(IsSrvUnix(), "/", "\")
Static cStartPath := GetSrvProfString("STARTPATH", "")

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI420
Mensagem única de exportação TXT de movimentos contábeis - ExportOfAccountMovements

@param  cXml          Variável com conteúdo XML para envio/recebimento.
@param  cTypeTrans    Tipo de transação (Envio / Recebimento).
@param  cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param  cVersion      Versão da mensagem.
@param  cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Function CTBI420(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

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
			cXmlRet := '1.000|1.001|1.002|1.003'
		ElseIf (cTypeMsg == EAI_MESSAGE_RESPONSE)

		ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)
			If FindFunction("CFGA070INT")
				oXmlMsg := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
				If oXmlMsg <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
					oBContent := oXmlMsg:_TotvsMessage:_BusinessMessage:_BusinessContent
					If XmlChildEx(oBContent, '_FTPADRESS') != Nil
						If lower(oBContent:_FTPAdress:Text) = "file://"
							cAdress := AllTrim(oBContent:_FTPAdress:Text)
						Else
							nPonto := RAT(":", oBContent:_FTPAdress:Text) // IP:Porta
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
						Endif
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
						  	aAdd(aAutoCab,{"MV_PAR01", StoD(STRTran(oBContent:_InitialDate:Text,'-'))})
						EndIf

						// Data final
						If XmlChildEx(oBContent, '_FINALDATE') != Nil
						  	aAdd(aAutoCab,{"MV_PAR02", StoD(STRtran(oBContent:_FinalDate:Text,'-'))})
						EndIf

						// Tipo de exportação
						If XmlChildEx(oBContent, '_EXPOTYPE') != Nil
						  	aAdd(aAutoCab,{"MV_PAR03", Val(oBContent:_ExpoType:Text)})
						EndIf

						// Tipo de saldo
						If XmlChildEx(oBContent, '_SLDTYPE') != Nil
						  	aAdd(aAutoCab,{"MV_PAR04", oBContent:_SldType:Text})
						EndIf

						// Filial inicial
						If XmlChildEx(oBContent, '_INITIALBRANCHINTERNALID') != Nil
							If !Empty(oBContent:_InitialBranchInternalId:Text)
								cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', PAdr(oBContent:_InitialBranchInternalId:Text,Len(cFilAnt)))
								aAdd(aAutoCab,{"MV_PAR05", cAuxDePara})
							Else
							 	If XmlChildEx(oBContent, '_INITIALBRANCH') != Nil
							 		aAdd(aAutoCab,{"MV_PAR05", PAdr(oBContent:_InitialBranch:Text,Len(cFilAnt))})
							 	EndIf
							EndIf
						ElseIf XmlChildEx(oBContent, '_INITIALBRANCH') != Nil
						  	aAdd(aAutoCab,{"MV_PAR05", PAdr(oBContent:_InitialBranch:Text,Len(cFilAnt))})
						EndIf

						// Filial final
						If XmlChildEx(oBContent, '_FINALBRANCHINTERNALID') != Nil
							If !Empty(oBContent:_FinalBranchInternalId:Text)
								cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', PAdr(oBContent:_FinalBranchInternalId:Text,Len(cFilAnt)))
								aAdd(aAutoCab,{"MV_PAR06", cAuxDePara})
							Else
								If XmlChildEx(oBContent, '_FINALBRANCH') != Nil
						  			aAdd(aAutoCab,{"MV_PAR06", Padr(oBContent:_FinalBranch:Text,Len(cFilAnt))})
						  		EndIf
							EndIf
						ElseIf XmlChildEx(oBContent, '_FINALBRANCH') != Nil
						  	aAdd(aAutoCab,{"MV_PAR06", Padr(oBContent:_FinalBranch:Text,Len(cFilAnt))})
						EndIf

						// Conta contábil inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTINTERNALID') != Nil
							If !Empty(oBContent:_InitialAccountInternalId:Text)
								cAuxDePara := CFGA070Int(cMarca, 'CT1', 'CT1_CONTA', Padr(oBContent:_InitialAccountInternalId:Text,TamSX3("CT1_CONTA")[1]))
								aAdd(aAutoCab,{"MV_PAR07", cAuxDePara})
							Else
								If XmlChildEx(oBContent, '_INITIALACCOUNT') != Nil
									aAdd(aAutoCab,{"MV_PAR07", Padr(oBContent:_InitialAccount:Text,TamSX3("CT2_DEBITO")[1])})
								EndIf
							EndIf
						ElseIf XmlChildEx(oBContent, '_INITIALACCOUNT') != Nil
						  	aAdd(aAutoCab,{"MV_PAR07", Padr(oBContent:_InitialAccount:Text,TamSX3("CT2_DEBITO")[1])})
						EndIf

						// Conta contábil final
						If XmlChildEx(oBContent, '_FINALACCOUNTINTERNALID') != Nil
							If !Empty(oBContent:_FinalAccountInternalId:Text)
								cAuxDePara := CFGA070Int(cMarca, 'CT1', 'CT1_CONTA', Padr(oBContent:_FinalAccountInternalId:Text,TamSX3("CT1_CONTA")[1]))
								aAdd(aAutoCab,{"MV_PAR08", cAuxDePara})
							Else
								If XmlChildEx(oBContent, '_FINALACCOUNT') != Nil
						  			aAdd(aAutoCab,{"MV_PAR08", Padr(oBContent:_FinalAccount:Text,TamSX3("CT2_DEBITO")[1])})
						  		EndIf
							EndIf
						ElseIf XmlChildEx(oBContent, '_FINALACCOUNT') != Nil
						  	aAdd(aAutoCab,{"MV_PAR08", Padr(oBContent:_FinalAccount:Text,TamSX3("CT2_DEBITO")[1])})
						EndIf

						// Centro de custo inicial
						If XmlChildEx(oBContent, '_INITIALCOSTCENTERINTERNALID') != Nil
							If !Empty(oBContent:_InitialCostCenterInternalId:Text)
								cAuxDePara := CFGA070Int(cMarca, 'CTT', 'CTT_CUSTO', Padr(oBContent:_InitialCostCenterInternalId:Text,TamSX3("CTT_CUSTO")[1]))
								aAdd(aAutoCab,{"MV_PAR09", cAuxDePara})
							Else
								If XmlChildEx(oBContent, '_INITIALCOSTCENTER') != Nil
						  			aAdd(aAutoCab,{"MV_PAR09", PAdr(oBContent:_InitialCostCenter:Text,TamSX3("CT2_CCC")[1])})
						  		EndIf
							EndIf
						ElseIf XmlChildEx(oBContent, '_INITIALCOSTCENTER') != Nil
						  	aAdd(aAutoCab,{"MV_PAR09", PAdr(oBContent:_InitialCostCenter:Text,TamSX3("CT2_CCC")[1])})
						EndIf

						// Centro de custo final
						If XmlChildEx(oBContent, '_FINALCOSTCENTERINTERNALID') != Nil
							If !Empty(oBContent:_FinalCostCenterInternalId:Text)
								cAuxDePara := CFGA070Int(cMarca, 'CTT', 'CTT_CUSTO', Padr(oBContent:_FinalCostCenterInternalId:Text,TamSX3("CTT_CUSTO")[1]))
								aAdd(aAutoCab,{"MV_PAR10", cAuxDePara})
							Else
								If XmlChildEx(oBContent, '_FINALCOSTCENTER') != Nil
						  			aAdd(aAutoCab,{"MV_PAR10", Padr(oBContent:_FinalCostCenter:Text,TamSX3("CT2_CCC")[1])})
						  		EndIf
							EndIf
						ElseIf XmlChildEx(oBContent, '_FINALCOSTCENTER') != Nil
						  	aAdd(aAutoCab,{"MV_PAR10", Padr(oBContent:_FinalCostCenter:Text,TamSX3("CT2_CCC")[1])})
						EndIf

						// Item contábil inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTITEM') != Nil
						  	aAdd(aAutoCab,{"MV_PAR11", Padr(oBContent:_InitialAccountItem:Text,TamSX3("CT2_ITEMC")[1])})
						EndIf

						// Item contábil final
						If XmlChildEx(oBContent, '_FINALACCOUNTITEM') != Nil
					  		aAdd(aAutoCab,{"MV_PAR12", Padr(oBContent:_FinalAccountItem:Text,TamSX3("CT2_ITEMC")[1])})
						EndIf

						// Classe de valor inicial
						If XmlChildEx(oBContent, '_INITIALCLASSVALUE') != Nil
						  	aAdd(aAutoCab,{"MV_PAR13", Padr(oBContent:_InitialClassValue:Text,TamSX3("CT2_CLVLDB")[1])})
						EndIf

						// Classe de valor final
						If XmlChildEx(oBContent, '_FINALCLASSVALUE') != Nil
						  	aAdd(aAutoCab,{"MV_PAR14", Padr(oBContent:_FinalClassValue:Text,TamSX3("CT2_CLVLDB")[1])})
						EndIf

						// Nome do arquivo
						If XmlChildEx(oBContent, '_FILENAME') != Nil
						  	cFile := FileInteg(oBContent:_FileName:Text)//retiro o diretorio do arquivo
						  	aAdd(aAutoCab,{"MV_PAR15", cFile})
						EndIf

						// Conteúdo comprimido.
						If XmlChildEx(oBContent, '_COMPRESS') != Nil
						  	cCompress := (oBContent:_Compress:Text)
						EndIf

						// Livro contábil
						If XmlChildEx(oBContent, '_SETOFBOOKS') != Nil
						  	aAdd(aAutoCab,{"MV_PAR16", oBContent:_SetOfBooks:Text})
						EndIf

						// Se exibe contas sem saldo
						If XmlChildEx(oBContent, '_CLEAREDBALANCE') != Nil
						  	aAdd(aAutoCab,{"MV_PAR17", Val(oBContent:_ClearedBalance:Text)})
						EndIf

						// Entidade contábil 5 inicial
						If XmlChildEx(oBContent, '_INITIALACCOUNTENT5') != Nil
						  	aAdd(aAutoCab,{"ENTCONT05DE",oBContent:_InitialAccountEnt5:Text})
						EndIf

						// Entidade contábil 5 final
						If XmlChildEx(oBContent, '_FINALACCOUNTENT5') != Nil
						  	aAdd(aAutoCab,{"ENTCONT05ATE",oBContent:_FinalAccountEnt5:Text})
						EndIf

						If XmlChildEx(oBContent, '_INITIALACCOUNTENT6') != Nil
						  	aAdd(aAutoCab,{"ENTCONT06DE",oBContent:_InitialAccountEnt6:Text})
						EndIf

						If XmlChildEx(oBContent, '_FINALACCOUNTENT6') != Nil
						  	aAdd(aAutoCab,{"ENTCONT06ATE",oBContent:_FinalAccountEnt6:Text})
						EndIf

						If XmlChildEx(oBContent, '_INITIALACCOUNTENT7') != Nil
						  	aAdd(aAutoCab,{"ENTCONT07DE",oBContent:_InitialAccountEnt7:Text})
						EndIf

						If XmlChildEx(oBContent, '_FINALACCOUNTENT7') != Nil
						  	aAdd(aAutoCab,{"ENTCONT07ATE",oBContent:_FinalAccountEnt7:Text})
						EndIf

						If XmlChildEx(oBContent, '_INITIALACCOUNTENT8') != Nil
						  	aAdd(aAutoCab,{"ENTCONT08DE",oBContent:_InitialAccountEnt8:Text})
						EndIf

						If XmlChildEx(oBContent, '_FINALACCOUNTENT8') != Nil
						  	aAdd(aAutoCab,{"ENTCONT08ATE",oBContent:_FinalAccountEnt8:Text})
						EndIf

						If XmlChildEx(oBContent, '_INITIALACCOUNTENT9') != Nil
						  	aAdd(aAutoCab,{"ENTCONT09DE",oBContent:_InitialAccountEnt9:Text})
						EndIf

						If XmlChildEx(oBContent, '_FINALACCOUNTENT9') != Nil
						  	aAdd(aAutoCab,{"ENTCONT09ATE",oBContent:_FinalAccountEnt9:Text})
						EndIf

						MsExecAuto({|x| CTBA420(x)}, aAutoCab)
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
											cXmlRet += '<Message type="ERROR" code="c2">' + _NoTags(STR0004) + '</Message>'//Não foi possível a carga do arquivo no FTP. Verifique as permissões e tente novamente.
											lRet := .F.
										EndIf
										FTPDisconnect()
										FErase(cFile)  // Apaga o arquivo da system.

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
									cXmlRet+= "<File>" + _NoTags(cDestino) + "</File>"
									If Val(cVersion) > 1.002  // Da versão 1.003 em diante.
										cXmlRet += "<Structure>"
										aStruct := CTB420X3(.F.)
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
							EndIf
						Endif
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
Pega o nome do arquivo atraves do parametro informado e o devolve sem o diretorio

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
