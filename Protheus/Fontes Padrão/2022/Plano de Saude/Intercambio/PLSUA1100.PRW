#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA1100
Realiza solicitacao/importacao das guias autorizadas automaticamente pelo WSD

@author  PLS TEAM
@version P11
@since   03.10.16
/*/
//-------------------------------------------------------------------
Function PLSUA1100()
Local cPerg      := padr("PLSUA1100",10)
                 
If Pergunte(cPerg,.T.)  
	cRet := Processa({||Pls1100Pro()},"Processando PTU A1110","Processando...",.T.)
EndIf                 

Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA1100
Realiza solicitacao/importacao das guias autorizadas automaticamente pelo WSD

@author  PLS TEAM
@version P11
@since   03.10.16
/*/
//-------------------------------------------------------------------
Function Pls1100Pro()

	Local cData                     
	Local cNameSpace := GetNewPar("MV_PTONNAM","v60")       
	Local cVersion := GetNewPar("MV_PTONVER","V60_00")
	Local cSchema := GetNewPar("MV_PTONXSD","ptu_Transacoes-V60_00.xsd")  
	Local cRet := ""
	Local cHash := "" 
	Local cXml := ""
	Local cSoap := ""        
	Local cErro := ""
	Local cAviso := ""    
	Local aRet := {}     
	Local aRetObj := {}  
	Local aIte := {}
	Local aResumo := {}
	Local nGuias := 0
	Local nItens := 0                      
	Local nI := 0
	Local nJ := 0
	Local bBlGuia := {||IIf(nGuias>1,"["+cValtoChar(nI)+"]","")}
	Local bBlItens := {||IIf(nItens>1,"["+cValtoChar(nJ)+"]","")}
	Local lPLSTRTPTU := ExistBlock("PLSTRTPTU")
	Local cVerPTU := "0"+GetNewPar("MV_PTUVEON","80")
	Local lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
	
	cData := Substr(Dtos(mv_par01),1,4)+"-"+Substr(Dtos(mv_par01),5,2)+"-"+Substr(Dtos(mv_par01),7,2)

	// Monta Corpo do Arquivo                  							   
	cXml := PLMntTagPT(cXml,'cabecalho',nil,.T.,nil,.T.,,cNameSpace+":")
	cXml := PLMntTagPT(cXml,'codigoTransacao',"01100",nil,nil,.T.,@cHash,cNameSpace+":")

	If !lPTUOn90
		cXml := PLMntTagPT(cXml,'tipoCliente',"UNIMED",nil,nil,.T.,@cHash,cNameSpace+":")
	EndIf

	cXml := PLMntTagPT(cXml,'codigoUnimedSolicitante',cValtoChar(Val(PlsIntPad())),nil,nil,.T.,@cHash,cNameSpace+":")
	cXml := PLMntTagPT(cXml,'cabecalho',nil,nil,.T.,.T.,,cNameSpace+":")

	cXml := PLMntTagPT(cXml,'consultaA1100',nil,.T.,nil,.T.,,cNameSpace+":")
	cXml := PLMntTagPT(cXml,'dataDiaSolicitado',cData,nil,nil,.T.,@cHash,cNameSpace+":")
	cXml := PLMntTagPT(cXml,'numeroVersaoPTU',cVerPTU,nil,nil,.T.,@cHash,cNameSpace+":")
	cXml := PLMntTagPT(cXml,'consultaA1100',nil,nil,.T.,.T.,,cNameSpace+":")

	cHash := Upper( MD5(cHash,2) )
	cXml := PLMntTagPT(cXml,'hash',cHash,nil,nil,.T.,,cNameSpace+":")
	cXml := PLMntTagPT(cXml,'consultaA1100WS',nil,nil,.T.,.T.,,cNameSpace+":")

	// Monta Soap de Envio                  								   
	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:'+cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+cVersion+'">'+Chr(10)
	cSoap += '<soapenv:Header/>'+Chr(10)
	cSoap += '<soapenv:Body>'+Chr(10)
	cSoap += '<'+cNameSpace+':consultaA1100WS>'
	cSoap += cXml+Chr(10)
	cSoap += '</soapenv:Body>'+Chr(10)
	cSoap += '</soapenv:Envelope>'+Chr(10)

	// Gera arquivo fisico                                 				     
	cXml := '<'+cNameSpace+':consultaA1100WS xmlns:'+cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+cVersion+'">'+Chr(10) + cXml

	// Faz a validação do XML gerado pelo TranXml com o XSD 				     
	If (!XmlSVldSch( cXml, "\ptuonweb\schemas\"+cSchema, @cErro,@cAviso))
		cRet := "Não foi possível gerar a mensagem de solicitação: "+ cErro
	Else
		
		If ExistBlock( "PLWSDPTU" )
			aRet := ExecBlock( "PLWSDPTU", .F., .F., {'consultaA1100WS',cSoap} )
		Else
			aRet := PLPtOnWsdl('consultaA1100WS',cSoap)   
	EndIf
		
		If aRet[1]

			// Valida estrutura do arquivo de resposta                                  
			aRetObj := PLVldXmlPT(@cErro,@cAviso,aRet[2])

			If aRetObj[1]
				lRet  := .T.
				oObjXml    := aRetObj[2]
				cNameSpace := aRetObj[3]
				
				If PLTagXMLPT(oObjXml,cNameSpace,"cabecalho","codigoTransacao") == "00310"
					cRet := "Foi apresentado um erro inesperado na resposta."
				// Processado OK                                                            
				Else
					If Type("oObjXml:"+cNameSpace+"respostaA1100") == "O"
						nGuias := 1
					ElseIf Type("oObjXml:"+cNameSpace+"respostaA1100") <> "U"
						nGuias := len( &("oObjXml:"+cNameSpace+"respostaA1100") )
					EndIf
					
					For nI := 1 to nGuias

						cCodUniExe := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\codigoUnimedExecutora")
						cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\codigoUnimedOrigem")
						cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\numeroTransacaoPrestadora")
						cNumTraOri := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\numeroTransacaoOrigemBeneficiario")
						cNumTraRef := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\numeroTransacaoReferencia")
						cMatric    := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\identificacaoBeneficiario\codigoUnimed") + ;
						PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\identificacaoBeneficiario\codigoIdentificacao\")
						cIdBenef   := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\identificacaoBeneficiario\codigoIdentificacao\")

						If !lPTUOn90
							dDataSol   := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\dataSolicitacao","D")
						EndIf

						dDataWsd   := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\dataRespWsd","D")
						cIdStBenef := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\IdStBenef")
		
						// Monta o cabecalho aDados                                                 
						aDados   := {}
						aDadUsr  := PLSDADUSR(cMatric,'1',.F.,dDatabase,,,)

						If Empty(cNumTraRef)  
							Aadd(aDados,{"CD_TRANS","00600"})
						Else
							Aadd(aDados,{"CD_TRANS","00605"})  
							Aadd(aDados,{"NR_TRANS_R",cNumTraRef}) 
						EndIf

						Aadd(aDados,{"TP_CLIENTE","A1100"})
						Aadd(aDados,{"CD_UNI_ORI",cCodUniExe})
						Aadd(aDados,{"NR_IDENT_O",cNumTraPre})
						Aadd(aDados,{"NR_IDENT_D",cNumTraOri})
						Aadd(aDados,{"CD_UNI",PlsIntPad()})
						Aadd(aDados,{"ID_BENEF",cIdBenef})

						If !lPTUOn90
							Aadd(aDados,{"DT_ATENDIM",dDataSol})
						EndIf

						If len(aDadUsr) > 52
							Aadd(aDados,{"NR_VIA_CAR",cValToChar(aDadUsr[53])})
						EndIf
						
						// Carrega os itens                                                         
						If Type("oObjXml:"+cNameSpace+"respostaA1100"+Eval(bBlGuia)+":"+cNameSpace+"blocoServicos") == "O"
							nItens := 1
						ElseIf Type("oObjXml:"+cNameSpace+"respostaA1100"+Eval(bBlGuia)+":"+cNameSpace+"blocoServicos") <> "U"
							nItens := len( &("oObjXml:"+cNameSpace+"respostaA1100"+Eval(bBlGuia)+":"+cNameSpace+"blocoServicos") )
						Endif
						
						aItens := {}

						For nJ := 1 to nItens

							cSeqItem  := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\servico\sqitem")
							cTpTabela := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\servico\tipoTabela")
							cCodServ  := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\servico\codigoServico")
							cQtdServ  := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\quantidadeServico")
							
							If !lPTUOn90
								cDescServ := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\descricaoServico")
							EndIf

							cIdResp   := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\idRespostaWsd")
							cCodMens  := PLRetTagWB(oObjXml,cNameSpace,"respostaA1100"+Eval(bBlGuia)+"\blocoServicos"+Eval(bBlItens)+"\codigoMensagemEspecifica")
							
							aIte := {}

							Aadd(aIte,{"SQ_ITEM",cSeqItem})
							Aadd(aIte,{"TP_TABELA",cTpTabela})
							Aadd(aIte,{"CD_SERVICO",cCodServ})
							Aadd(aIte,{"QT_SERVICO",cQtdServ})
							Aadd(aIte,{"DS_OPME",""})//PLSA1100GCF("R1103","DS_SERVICO")
							Aadd(aIte,{"VL_SERVICO","00000000000000"})
							Aadd(aIte,{"ID_RESPWSD",cIdResp})
							Aadd(aIte,{"CD_MENS_ER",cCodMens})
							Aadd(aItens,aIte)

						Next
		
						// Se aDados preenchido, gera a guia                                        
						If len(aDados) > 0 .And. len(aItens) > 0
							If lPLSTRTPTU
								aRet := ExecBlock("PLSTRTPTU",.F.,.F., {.T.})
								If ValType(aRet) <> 'U' .And. len(aRet) > 0
									aRetProc := aRet[1]
									If len(aRetProc) > 0
										aadd(aResumo,{Strzero(Val(cCodUniExe),4), cNumTraPre, IIF(!Empty(cNumTraRef),"Complemento de Autorização",aRetProc[1][1]),aRetProc[1][2]})
									Else
										aadd(aResumo,{Strzero(Val(cCodUniExe),4), cNumTraPre,"","Registro já Processado"})
									EndIf	
								Else
									aadd(aResumo,{Strzero(Val(cCodUniExe),4), cNumTraPre,"","Registro já Processado"})
								EndIf
							EndIf
						EndIf
						
						aDados := {}
						aItens := {}
					Next
					
					If len(aResumo) > 0
						PLSCRIGEN(aResumo,{ {"Operadora","@C",40} , {"Num Transacao","@C",50}, {"Guia","@C",90} , {"Status da Guia","@C",80 } },"Resumo da Comunicacao")
					ElseIf nGuias == 0
						cRet := "Não foram encontradas guias para o período informado."
					EndIf
				
				EndIf
		
				// Criticas na validacao de estrutura do arquivo resposta                   
			Else
				cRet := "Não foi possível ler o arquivo de resposta: "+cErro + " " +cAviso
			EndIf
		Else
			cRet := aRet[3]
		EndIf
	EndIf

	If !Empty(cRet)
		MsgInfo(cRet)	
	EndIf

Return