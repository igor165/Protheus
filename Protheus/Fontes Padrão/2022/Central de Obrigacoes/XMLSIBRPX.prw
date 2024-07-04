//TODO Ajustar os cabeçalhos
#Include 'Protheus.ch'
#include 'Fileio.ch'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#Define F_BLOCK  512
#define MATRIPLS "@R !!!!.!!!!.!!!!!!.!!-!"
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
	#define barra "\"
#ELSE
	#define CRLF Chr(10)
	#define barra "/"
#ENDIF
//Status B3X
#DEFINE PDTE_VALID     "1" // Pendente Validação
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO       "3" // Inválido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado
#DEFINE JOB_VALID		"1" // Job Validacao

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIBRPX

Gera o arquivo XML para o SIB

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObr		Chave da obrigacao
@param cCodComp		Chave do compromisso
@param cAno			Ano do compromisso

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBRPX(cTipo,lInterface)
	Local lOk			:= .T.

	Default lInterface := .T.

	Private cArqLog := "PLSSIB_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao

	If cTipo = '2' //SIB
		If Pergunte("PLSSIBRPX",.T.)
			if lHabMetric .and. lLibSupFw .and. lVrsAppSw
				FWMetrics():addMetrics("Impor Arq Ret RPX", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
			endif
			Processa( {||lOk := ProRPX(lInterface) } , "Processando" , "Aguarde processamento do retorno do SIB" , .F. )

		EndIf

	Else
		Alert("Operação não disponível para este tipo de obrigação.")
	EndIf

Return lOk
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProRPX

Monta as mensagens do SIB XML

@param cSequen		Sequencial do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ProRPX(lInterface)

	Local cError      := ""  // Erro ao ler o arquivo xml
	Local cWarning    := ""  // Avisos ao ler o arquivo xml
	Local oXml        := Nil // Objeto XML a ser criado
	Local oTrbXml     := Nil // Objeto XML temporario
	Local cFileRPX    := ""  // Nome do arquivo RPX a ser lido
	Local iRegs       := 1   // Contador para os registros
	Local iCriticas   := 0   // Contador de criticas para o registro
	Local iQtRegs     := 0   // Quantidade de registros
	Local aCriticas   := {}  // {TipReg,CodErr,VlrEnv,CodBen} criticas do arquivo
	Local aCritsReg   := {}  // Criticas do registro que esta sendo processado
	Local aReturn     := {.T.,"Processamento concluído"}  // Criticas do registro que esta sendo processado
	Local aCabec      := { {"Tipo registro","@!",20},{"Matrícula/CCO","@!",17},{"Código erro","@!",04},{"Valor enviado","@!",100},{"Crítica","@!",250} } // Cabecalho das criticas
	Local oTrbCons    := Nil // Objeto XML temporario consolidado
	Local aResCons    := {} // Resultado consolidado do processamento do arquivo
	Local aCritAux    := {}
	local aCabCons    := { {"Tipo registro","@!",20},{"Qtde registros","@!",10},{"Qtde processado","@!",10},{"Qtde rejeitado","@!",10},{"% acerto","@!",10}} // Cabecalho do relatorio consolidado
	Local cDirSIB		:= barra + "sib" + barra
	Local lAlt := .T.
	Local cRegANS := ""
	Local cCodObr := ""
	Local cAno := ""
	Local cCodComp := ""

	cDatRef   	:= dtos(mv_par01)
	cFileRPX  	:= alltrim(mv_par02)
	lCriaLog 	:= mv_par03 == 1

	If lCriaLog // Cabecalho do log
		cMsg := "Processamento do RPX - Início: " + Dtos(dDatabase) + " " + Time() + CRLF
		cMsg += "Parâmetros informados para processamento: " + CRLF
		cMsg += "Data de referência: " + cDatRef + CRLF
		cMsg += "Arquivo RPX: " + cFileRPX + CRLF
		cMsg += "Gera arquivo log: " + If(lCrialog,"Sim","Não")
		PlsLogFil(cMsg,cArqLog)
	EndIf

	If !Substr(cFileRPX,1,1) $ "/\"//Verifica se o arquivo esta no cliente
		If !ExistDir(cDirSIB) //Verifica se existi o diretorio /sib/
			If MakeDir(cDirSIB) <> 0 //Tenta criar o diretorio
				aReturn[1] := .F.
				aReturn[2] := "Não foi possível criar o diretório " + cDirSIB + "." + CRLF + "Contate o administrador do sistema."
				MsgInfo(aReturn[2],"TOTVS")
				Return aReturn
			EndIf
			Sleep(2000)//Preciso aguardar o SO enchergar que o diretorio foi criado
		EndIf
		If !CpyT2S(cFileRPX,cDirSIB)//Tenta transferir o arquivo do cliente para o servidor

			aReturn[1] := .F.
			aReturn[2] := "Não foi possível transfeir o arquivo para o servidor." + CRLF + "Contate o administrador do sistema."
			MsgInfo(aReturn[2],"TOTVS")
			Return aReturn

		Else
			cFileRPX := cDirSIB + SubStr(cFileRPX,Rat("\",cFileRPX)+1,Len(cFileRPX))
		EndIf
	EndIf

	oXml := XmlParserFile(cFileRPX,"_",@cError,@cWarning)

	If Empty(cError) .And. Empty(cWarning) .And. oXml != Nil

		oTrbXml := XmlChildEx(oXml,"_MENSAGEMSIB") // Carrega o objeto XML com o conteudo do arquivo

		If ValType(XmlChildEx(oTrbXml:_MENSAGEM,"_ANSPARAOPERADORA")) != "O" // Verifica se o arquivo carrega e valido
			aReturn[1] := .F.
			aReturn[2] := "Arquivo selecionado é inválido!"
			If lCriaLog
				PlsLogFil(aReturn[2],cArqLog)
			EndIf
			MsgInfo(aReturn[2],"TOTVS")
			Return aReturn

		Else
			If lCriaLog
				PlsLogFil("Arquivo " + cFileRPX + " é válido!",cArqLog)
			EndIf
		EndIf

		//Verifica se o arquivo foi rejeitado pela ANS
		If ValType(XmlChildEx(oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO,"_ARQUIVOREJEITADO")) == "O"
			aReturn[1] := .F.
			aReturn[2] := "Arquivo rejeitado pela ANS." + CRLF + "Motivo: " + oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOREJEITADO:_MOTIVOREJEICAO:TEXT
			MsgInfo(aReturn[2],"TOTVS")
			Return aReturn
		EndIf
		//Retorna o registro da ANS que veio no arquivo.
		cRegANS := oTrbXml:_CABECALHO:_DESTINO:_REGISTROANS:TEXT
		//Atualiza o objeto com os dados consolidados
		oTrbCons := oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO:_CONSOLIDADO:_CONSOLIDADOPROCESSAMENTO

		//Atualiza o objeto com os registros rejeitados
		oTrbRej := XmlChildEx(oTrbxml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO,"_REGISTROSREJEITADOS")

		cNomArq := oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO:_PROTOCOLOPROCESSAMENTO:_NOMEARQUIVO:TEXT

		BEGIN TRANSACTION

			//Verifica se o arquivo existe
			B3R->(dbSetOrder(2))//
			If B3R->(MsSeek(xFilial("B3R")+cNomArq))

				cCodObr := B3R->B3R_CDOBRI
				cAno := B3R->B3R_ANO
				cCodComp := B3R->B3R_CDCOMP

				If oTrbRej == Nil //Posso ter um arquivo RPX sem nenhum registro rejeitado

					MsgInfo("Nao existem registros rejeitados para serem processados","TOTVS")
					If lCriaLog
						PlsLogFil("Nao existem registros rejeitados para serem processados",cArqLog)
					EndIf

				Else //Arquivo RPX possui registros rejeitados

					oTrbRej := oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO:_REGISTROSREJEITADOS:_REGISTROREJEITADO


					If ValType(oTrbRej) == "O"
						iQtRegs := 1 // So tenho um registro rejeitado
					Else
						iQtRegs := Len(oTrbRej) // Tenho varios registros rejeitados
					EndIf

					While iRegs <= iQtRegs // Vou percorrer todos os registros rejeitados
						aCritAux := {}
						// Armazeno as criticas na matriz
						If ValType(oTrbRej) == "A" // Mais de um registro com critica

							If ValType(oTrbRej[iRegs]:_CAMPOERRO) != "A"

								aCritsReg := ASIBGetCri(oTrbRej[iRegs]:_CAMPOERRO)
								ASibAddCri(aCriticas,oTrbRej[iRegs]:_TIPOMOVIMENTO:TEXT,;
									If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej[iRegs]:_CODIGOBENEFICIARIO:TEXT,oTrbRej[iRegs]:_CCO:TEXT),;
									aCritsReg[1],;
									aCritsReg[3],;
									aCritsReg[2],aCritAux)

							Else // Mais de uma critica no mesmo registro

								For iCriticas := 1 To Len(oTrbRej[iRegs]:_CAMPOERRO)

									aCritsReg := ASIBGetCri(oTrbRej[iRegs]:_CAMPOERRO[iCriticas])
									ASibAddCri(aCriticas,oTrbRej[iRegs]:_TIPOMOVIMENTO:TEXT,;
										If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej[iRegs]:_CODIGOBENEFICIARIO:TEXT,oTrbRej[iRegs]:_CCO:TEXT),;
										aCritsReg[1],;
										aCritsReg[3],;
										aCritsReg[2],aCritAux)

								Next iCriticas

							EndIf

						Else // Apenas um registro criticado

							If ValType(oTrbRej:_CAMPOERRO) == "A" // Mais de uma critica no registro

								For iCriticas := 1 To Len(oTrbRej:_CAMPOERRO)

									aCritsReg := ASIBGetCri(oTrbRej:_CAMPOERRO[iCriticas])
									ASibAddCri(aCriticas,oTrbRej:_TIPOMOVIMENTO:TEXT,;
										If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej:_CODIGOBENEFICIARIO:TEXT,oTrbRej:_CCO:TEXT),;
										aCritsReg[1],;
										aCritsReg[3],;
										aCritsReg[2],aCritAux)

								Next iCriticas

							Else // Apenas uma critica no registro
								aCritsReg := ASIBGetCri(oTrbRej:_CAMPOERRO)
								ASibAddCri(aCriticas,oTrbRej:_TIPOMOVIMENTO:TEXT,;
									If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej:_CODIGOBENEFICIARIO:TEXT,oTrbRej:_CCO:TEXT),;
									aCritsReg[1],;
									aCritsReg[3],;
									aCritsReg[2],aCritAux)
							EndIf

						EndIf //If ValType(oTrbXml) == "A"

						If ValType(oTrbRej) == "A" // Mais de um registro com critica

							ASIBAtuSib(If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej[iRegs]:_CODIGOBENEFICIARIO:TEXT,""),;
								.T.,;
								oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT,;
								If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1","",oTrbRej[iRegs]:_CCO:TEXT),;
								oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT,;
								cDatRef,;
								cRegANS,aCritAux,cCodObr,cAno,cCodComp,cNomArq)

						Else // Apenas um registro criticado

							ASIBAtuSib( If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej:_CODIGOBENEFICIARIO:TEXT,""),;
								.T.,;
								oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT,;
								If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1","",oTrbRej:_CCO:TEXT),;
								oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT,;
								cDatRef,;
								cRegANS,aCritAux,cCodObr,cAno,cCodComp,cNomArq)

						EndIf //ValType(oTrbRej) == "A"

						iRegs++

					EndDo //iRegs <= iQtRegs
				EndIf //If oTrbRej == Nil
				//Atualiza o objeto com os registros incluidos
				oTrbInc := XmlChildEx(oTrbxml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO,"_REGISTROSINCLUIDOS")

				If oTrbInc == Nil //Posso ter um arquivo RPX sem nenhum registro de inclusao rejeitado

					MsgInfo("Não existem registros incluÍdos para serem processados","TOTVS")
					If lCriaLog
						PlsLogFil("Não existem registros incluÍos para serem processados",cArqLog)
					EndIf

				Else //Arquivo RPX com registro de inclusao rejeitado

					oTrbInc := oTrbxml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO:_REGISTROSINCLUIDOS:_REGISTROINCLUIDO


					If ValType(oTrbInc) == "O"
						iQtRegs := 1 // So tenho um registro incluido
					Else
						iQtRegs := Len(oTrbInc) // Tenho varios registros incluidos
					EndIf

					iRegs := 1
					While iRegs <= iQtRegs // Vou percorrer todos os registros incluidos

						If ValType(oTrbInc) == "A" // Mais de um registro DE INCLUSÃO
							ASIBAtuSib( oTrbInc[iRegs]:_CODIGOBENEFICIARIO:TEXT,;
								.F.,;
								"1",;
								oTrbInc[iRegs]:_CCO:TEXT,;
								"1",cDatRef,;
								cRegANS,{},cCodObr,cAno,cCodComp,cNomArq,;
								oTrbInc[iRegs]:_NOMEBENEFICIARIO:TEXT) //alterado
							cMat := alltrim(oTrbInc[iRegs]:_CODIGOBENEFICIARIO:TEXT)
							lAlt := .F.
						Else // Apenas um registro DE INCLUSÃO

							ASIBAtuSib( oTrbInc:_CODIGOBENEFICIARIO:TEXT,;
								.F.,;
								"1",;
								oTrbInc:_CCO:TEXT,"1",cDatRef,;
								cRegANS,{},cCodObr,cAno,cCodComp,cNomArq,;
								oTrbInc:_NOMEBENEFICIARIO:TEXT) //alterado
							cMat := alltrim(oTrbInc:_CODIGOBENEFICIARIO:TEXT)
							lAlt := .F.
						EndIf
						iRegs++

					EndDo

				EndIf

				// Vou atualizar todos beneficiarios que nao foram criticados
				ASIBAtuOk(cNomArq)

			Else
				aReturn[1] := .F.
				aReturn[2] := "Não foi encontrado um arquivo válido para realizar a importação"
				Alert(aReturn[2],"TOTVS")
				Return aReturn

			EndIf //If B3R->(MsSeek(xFilial("B3R")+cNomArq))


		END TRANSACTION

		If oTrbCons == Nil //Vai que nao vem os registros de dados consolidados

			If lCriaLog
				PlsLogFil("Nao existem registros consolidados no arquivo para serem processados",cArqLog)
			EndIf

		Else // Vou testar todos os registros de informacoes consolidadas

			If ValType(oTrbCons:_CONSOLIDADOCANCELAMENTO) == "O"
				aAdd(aResCons,{"Cancelamento",oTrbCons:_CONSOLIDADOCANCELAMENTO:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADOCANCELAMENTO:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADOCANCELAMENTO:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADOCANCELAMENTO:_PERCENTUALACERTO:TEXT})
			EndIf

			If ValType(oTrbCons:_CONSOLIDADOINCLUSAO) == "O"
				aAdd(aResCons,{"Inclusão",oTrbCons:_CONSOLIDADOINCLUSAO:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADOINCLUSAO:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADOINCLUSAO:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADOINCLUSAO:_PERCENTUALACERTO:TEXT})
			EndIf

			If ValType(oTrbCons:_CONSOLIDADOMUDANCACONTRATUAL) == "O"
				aAdd(aResCons,{"Mud. contratual",oTrbCons:_CONSOLIDADOMUDANCACONTRATUAL:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADOMUDANCACONTRATUAL:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADOMUDANCACONTRATUAL:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADOMUDANCACONTRATUAL:_PERCENTUALACERTO:TEXT})
			EndIf

			If ValType(oTrbCons:_CONSOLIDADOREATIVACAO) == "O"
				aAdd(aResCons,{"Reativação",oTrbCons:_CONSOLIDADOREATIVACAO:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADOREATIVACAO:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADOREATIVACAO:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADOREATIVACAO:_PERCENTUALACERTO:TEXT})
			EndIf

			If ValType(oTrbCons:_CONSOLIDADORETIFICACAO) == "O"
				aAdd(aResCons,{"Retificação",oTrbCons:_CONSOLIDADORETIFICACAO:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADORETIFICACAO:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADORETIFICACAO:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADORETIFICACAO:_PERCENTUALACERTO:TEXT})
			EndIf

			If ValType(oTrbCons:_CONSOLIDADOSEMMOVIMENTACAO) == "O"
				aAdd(aResCons,{"Sem movimento",oTrbCons:_CONSOLIDADOSEMMOVIMENTACAO:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADOSEMMOVIMENTACAO:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADOSEMMOVIMENTACAO:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADOSEMMOVIMENTACAO:_PERCENTUALACERTO:TEXT})
			EndIf

			If ValType(oTrbCons:_CONSOLIDADOTOTAL) == "O"
				aAdd(aResCons,{"Total",oTrbCons:_CONSOLIDADOTOTAL:_QUANTIDADEREGISTROS:TEXT,;
					oTrbCons:_CONSOLIDADOTOTAL:_QUANTIDADEPROCESSADOS:TEXT,;
					oTrbCons:_CONSOLIDADOTOTAL:_QUANTIDADEREJEITADOS:TEXT,;
					oTrbCons:_CONSOLIDADOTOTAL:_PERCENTUALACERTO:TEXT})
			EndIf

		EndIf

	Else
		MsgInfo("Não foi possível ler o arquivo RPX" + CRLF + cError,"TOTVS")
		If lCriaLog
			PlsLogFil("Não foi possível ler o arquivo RPX",cArqlog)
			PlsLogFil("Avisos: " + cWarning,cArqlog)
			PlsLogFil("Erros: " + cError,cArqlog)
		EndIf
	EndIf

	If lInterface .AND. MsgYesNo("Deseja salvar o resultado das críticas em arquivo .CSV ?","TOTVS")

		cDirCsv := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
		nFileCsv := FCreate(cDirCsv+"RetornoSIB.csv",0,,.F.)
		If nFileCsv > 0
			FWrite(nFileCSV,"Tipo registro;Matricula/CCO;Cod. Erro;Valor Enviado;Critica"+CRLF)
			For iCriticas := 1 TO Len(aCriticas)
				FWrite(nFileCSV,aCriticas[iCriticas,1]+";"+aCriticas[iCriticas,2]+";"+aCriticas[iCriticas,3]+";"+aCriticas[iCriticas,4]+";"+aCriticas[iCriticas,5]+CRLF)
			Next iCriticas
			FClose(nFileCSV)
		Else
			MsgInfo("Não foi possível criar o arquivo " + cDirCsv+cFileRPX,"TOTVS")
		EndIf

	EndIf

	If lInterface .AND. Len(aCriticas) > 0 // Se teve criticas vou apresentar
		PlsCriGen(aCriticas,aCabec,"Relatório de críticas do retorno do SIB - " + Dtoc(mv_par01),,"Retorno do SIB",,,,,"G",220)
	EndIf

	If lInterface .AND. Len(aResCons) > 0 // Se tem informacoes consolidadas vou apresentar
		PlsCriGen(aResCons,aCabCons,"Relatório consolidado do retorno do SIB - " + Dtoc(mv_par01),,"Retorno do SIB",,,,,"G",220)
	EndIf

	If lCrialog
		cMsg := "Geração do arquivo do SIB - Término: " + Dtos(dDatabase) + " - " + Time()
		PlsLogFil(cMsg,cArqLog)
	EndIf


Return aReturn

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ASIBAtuSib

Atualiza o registro do beneficiario de acordo com o arquivo de retorno RPX.

@param cMatUsr		Matrícula do beneficiário
@param lCritica	Informa se o registro foi criticado
@param cTipReg
@param cCodCCO		CCO do beneficiário
@param cTipMov		Tipo da operação que foi enviada para a ANS: 1=Incluir;2=Retificar;3=Mud.Contrat;4=Cancelar;5=Reativar;6=Atualizado ANS
@param cDatRef		Data de referência
@param cRegANS		Registro da Operadora na ANS
@param aCriticas	Array com as críticas encontradas
@param cCodObr		Código Obrigação
@param cAno		Ano da Obrigação
@param cCodComp	Código do compromisso
@param cNomArq		Nome do arquivo processado

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ASIBAtuSib(cMatUsr,lCritica,cTipReg,cCodCCO,cTipMov,;
		cDatRef,cRegANS,aCriticas,cCodObr,cAno,;
		cCodComp, cNomArq,cNomBen)
	Local cLocSib := ""
	Local cLogSib := ""
	Local nI
	Local nRec    := 0
	Local lUsnRec := .F.
	Default cNomBen := ""

	cLogSib := "Tipo de registro: " + cTipReg + " - " + Iif(!Empty(cMatUsr),"Matrícula: " + cMatUsr,"CCO: " + cCodCCO) + " - Crítica?: " + Iif(lCritica,"Não","Sim")

	B3X->(dbSetOrder(2))
	B3K->(dbSetOrder(1))
	B3F->(DbSetOrder(7))

	// Adiciono as críticas no registro do arquivo
	For nI := 1 to Len(aCriticas)
		//Registro a crítica no arquivo
		PLOBINCRIT(cRegANS,cCodObr,cAno,cCodComp,"B3R",;
			PADL(AllTrim(Str(B3R->(Recno()))),10),aCriticas[nI][3],aCriticas[nI][5]/*cDesCrit*/,;
			""/*cSolucao*/,"","3",aCriticas[nI][3],aCriticas[nI][2],,"2",B3R->B3R_ARQUIV)
	Next nI
	//Seleciona Beneficiário
	If SelecBenef(cCodCCO,cRegANS,cMatUsr,cNomBen,cTipMov)
		// Se for mudanca contratual, nao posso deixar atualizar
		// o registro enviado como alteracao que tem o mesmo cco
		If cTipMov == "3"
			While !B3K->(Eof()) .And. B3K->B3K_CODCCO == cCodCCO

				nRec:=B3K->(RECNO())

				If B3X->(MsSeek(xFilial("B3X")+PADL(B3K->(Recno()),10)+cNomArq+cTipMov))
					Exit
				Else
					lUsnRec:=.T.
				Endif

				B3K->(dbSkip())
			EndDo

			If lUsnRec
				B3K->(DbGoTo(nRec))
			Endif

			If lCriaLog
				PlsLogFil(cLogSib + " - NÃO ENCONTRADO",cArqLog)
			EndIf
		EndIf

		//Incluo a crítica na movimentação
		If lCritica

			For nI := 1 to Len(aCriticas)

				If cTipMov=="2"
					cCampo = RetCmpANS(SubStr(aCriticas[nI,3],1,2))
				Else
					cCampo := ""
				EndIf

				If SelecMov(cTipMov,cCampo,cNomArq)
					//Incluo a crítica
					PLOBINCRIT(cRegANS,cCodObr,cAno,cCodComp,"B3X",;
						PADL(AllTrim(Str(B3X->(Recno()))),10),aCriticas[nI][3]/*codcri*/,aCriticas[nI][5]/*cDesCrit*/,;
						""/*cSolucao*/,cCampo,"3",aCriticas[nI][3]/*codcri*/,B3K->B3K_MATRIC,B3K->B3K_NOMBEN,,B3K->B3K_CODCCO+B3K->B3K_MATRIC)
					B3X->(RecLock("B3X",.F.))
					B3X->B3X_STATUS := CRIT_ANS
					B3X->(msUnlock())
				EndIf
			Next nI

			//Atualizo CCO somente na inclusão
		ElseIf !B3K->(Eof())
			If cTipReg == "1"
				B3K->(RecLock("B3K",.F.))
				B3K->B3K_CODCCO := cCodCCO
				B3K->(msUnlock())
			EndIf
			//Revalida as movimentações
			CnMvtoPdte(B3K->(Recno()))
			PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),cRegAns,cEmpAnt,Nil,JOB_VALID,{},,,B3K->(Recno()))

			//Envio o Beneficiário para o espelho da ANS
			//BenToEspANS()
			//Atualizo o CCO no PLS
			BA1->(DbSetOrder(2))
			If BA1->(MsSeek(xFilial("BA1")+B3K->B3K_MATRIC))
				BA1->(RecLock("BA1",.F.))
				BA1->BA1_CODCCO := cCodCCO
				BA1->(msUnlock())
			EndIf
			//Se na validação do espelho foi criticado (E029), corrige a critica
			PlObCorCri(cRegANS,cCodObr,cAno,cCodComp,"B3K",PADL(AllTrim(Str(B3K->(Recno()))),10),"E029","2")
		EndIf

		If lCriaLog
			PlsLogFil(Transform(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) + " - " + Iif(!lCritica,"Ok","Err") + " - Status ANS atualizado de " + cLocSib + " para " + BA1->BA1_LOCSIB,cArqLog)
		EndIf

	Else

		If lCriaLog
			PlsLogFil(cLogSib + " - NÃO ENCONTRADO",cArqLog)
		EndIf

	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelecMov

Seleciona a movimentação

@return lRet		.T. se encontrou a movimentação

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SelecMov(cTipMov,cCampo,cNomArq)
	Local lRet := .F.

	If Select("TRBMOV") > 0
		TRBMOV->(dbCloseArea())
	EndIf

	//Copio os dados do Beneficiário para o espelho da ANS
	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("B3X")
	cSql += " WHERE "
	cSql += " B3X_BENEF ='" + PADL(B3K->(Recno()),10) + "' "
	cSql += " AND B3X_ARQUIV = '" + PADR(cNomArq,tamSX3("B3X_ARQUIV")[1]) + "'"
	cSql += " AND B3X_OPERA = '" + cTipMov + "'"
	If !Empty(cCampo)
		cSql += " AND B3X_CAMPO = '" + cCampo + "'"
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMOV",.F.,.T.)
	lRet := !TRBMOV->(Eof())
	If lRet
		B3X->(DbGoto(TRBMOV->RECNO))
	EndIf
	TRBMOV->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelecBenef

Seleciona o beneficiário

@param aObj		Array com os dados da crítica

@return aRet		Críticas encontradas e formatadas para uso

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SelecBenef(cCodCCO,cRegANS,cMatUsr,cNomBen,cTipMov)
	Local lRet := .F.

	If Empty(cCodCCO) .OR. cTipMov == "1"
		B3K->(dbSetOrder(10))     //Busca Pela Matricula
		lRet := B3K->(MsSeek(xFilial("B3K")+cRegANS+PADR(cMatUsr,tamSX3("B3K_MATRIC")[1]))) //matricula
		If !lRet
			B3K->(dbSetOrder(9))     //Busca Pela Matricula Antiga
			lRet := B3K->(dbSeek(xFilial("B3K")+cRegANS+PADR(cMatUsr,tamSX3("B3K_MATRIC")[1])))
			If !lRet .AND. !Empty(cNomBen)
				B3K->(dbSetOrder(6))     //Busca Pelo Nome
				lRet := B3K->(dbSeek(xFilial("B3K")+AllTrim(cNomBen)))
			EndIf
		Endif
	Else
		B3K->(dbSetOrder(2))     //Busca Pelo CCO
		lRet := B3K->(dbSeek(xFilial("BA1")+cRegANS+cCodCCO))
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCmpANS

Retorna o campo da tabela B3K de acordo com o código da ANS

@param cCodCmp		Código do campo na ANS

@return cCampo		Campo da tabela B3K

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetCmpANS(cCodCmp)
	Local cRet := ""
	Local aCmpANS := {}
	Local nPos	:= 0

	aAdd(aCmpANS,{"B3K_NOMBEN"	,"01"})
	aAdd(aCmpANS,{"B3K_DATNAS"	,"02"})
	aAdd(aCmpANS,{"B3K_SEXO"		,"03"})
	aAdd(aCmpANS,{"B3K_CPF"		,"04"})
	aAdd(aCmpANS,{"B3K_PISPAS"	,"05"})
	aAdd(aCmpANS,{"B3K_NOMMAE"	,"06"})
	aAdd(aCmpANS,{"B3K_CNS"		,"07"})
	aAdd(aCmpANS,{"B3K_MATRIC"	,"08"})
	aAdd(aCmpANS,{"B3K_SUSEP"	,"09"})
	aAdd(aCmpANS,{"B3K_SCPA"		,"10"})
	aAdd(aCmpANS,{"B3K_PLAORI"	,"11"})
	aAdd(aCmpANS,{"B3K_DATINC"	,"12"})
	aAdd(aCmpANS,{"B3K_TIPDEP"	,"13"})
	aAdd(aCmpANS,{"B3K_COBPAR"	,"14"})
	aAdd(aCmpANS,{"B3K_ITEEXC"	,"15"})
	aAdd(aCmpANS,{"B3K_CNPJCO"	,"16"})
	aAdd(aCmpANS,{"B3K_CEICON"	,"17"})
	aAdd(aCmpANS,{"B3K_CODTIT"	,"18"})
	aAdd(aCmpANS,{"B3K_DATREA"	,"20"})
	aAdd(aCmpANS,{"B3K_TIPEND"	,"21"})
	aAdd(aCmpANS,{"B3K_ENDERE"	,"22"})
	aAdd(aCmpANS,{"B3K_NR_END"	,"23"})
	aAdd(aCmpANS,{"B3K_COMEND"	,"24"})
	aAdd(aCmpANS,{"B3K_BAIRRO"	,"25"})
	aAdd(aCmpANS,{"B3K_CODMUN"	,"26"})
	aAdd(aCmpANS,{"B3K_CEPUSR"	,"27"})
	aAdd(aCmpANS,{"B3K_RESEXT"	,"28"})
	aAdd(aCmpANS,{"B3K_MUNICI"	,"29"})
	aAdd(aCmpANS,{"B3K_CODCCO"	,"30"})
	aAdd(aCmpANS,{"B3K_MOTBLO"	,"31"})
	aAdd(aCmpANS,{"B3K_DATBLO"	,"32"})
	aAdd(aCmpANS,{"B3K_DN"		,"41"})

	nPos := aScan(aCmpANS,{|x|x[2] == cCodCmp })
	If nPos > 0
		cRet := aCmpANS[nPos][1]
	EndIf

Return cRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ASIBGetCri

Retorna a crítica do XML

@param aObj		Array com os dados da crítica

@return aRet		Críticas encontradas e formatadas para uso

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ASIBGetCri(aObj)
	Local aRet := {} // Matriz de retorno da critica
	Local nFor := 0 // Contador de criticas

	If ValType(aObj:_ERRO) != "A"

		aAdd(aRet,aObj:_ERRO:_CODIGOERRO:TEXT) // Codigo erro
		aAdd(aRet,aObj:_ERRO:_MENSAGEMERRO:TEXT) // Descricao

	Else

		For nFor := 1 To Len(aObj:_ERRO) // Mais de uma critica no mesmo campo

			aAdd(aRet,aObj:_ERRO[nFor]:_CODIGOERRO:TEXT) // Codigo erro
			aAdd(aRet,aObj:_ERRO[nFor]:_MENSAGEMERRO:TEXT) // Descricao

		Next nFor

	EndIf

	If XmlChildEx(aObj,"_VALORCAMPO") != Nil // Valor enviado no campo
		aAdd(aRet,aObj:_VALORCAMPO:TEXT)
	Else
		aAdd(aRet,"NAO INFORMADO")
	EndIf

Return aRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ASibAddCri

Adiciona a critica na matriz para o relatorio

@param aCriticas	Array com as críticas encontradas. Utilizado no CSV
@param cTipo		Tipo da critica
@param cCodTip		Codigo do tipo da crítica
@param cCodErr		Codigo do Erro
@param cVlrEnv		Valor enviado para a ANS
@param cDesCri		Descrição da Crítica
@param aCritAux	Críticas que serão incluídas na central de obrigações

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ASibAddCri(aCriticas,cTipo,cCodTip,cCodErr,cVlrEnv,;
		cDesCri,aCritAux)

	aAdd(aCriticas,{cTipo,cCodTip,cCodErr,cVlrEnv,cDesCri})
	aAdd(aCritAux,{cTipo,cCodTip,cCodErr,cVlrEnv,cDesCri})

	If lCrialog
		PlsLogFil(cTipo +" - "+ cCodTip +" - "+ cCodErr +" - "+ cVlrEnv +" - "+ cDesCri,cArqlog)
	EndIf

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ASibAddCri

Atualiza o espelho da ANS com os dados que não foram criticados.
Deleta do histórico de alterações o que a ANS aceitou.

@param cNomArq		Nome do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ASIBAtuOk(cNomArq)

	Local nRet	  := 0
	Local aArea	:= B3K->(GetArea())

	//Copio os dados do Beneficiário para o espelho da ANS
	cSql := " SELECT B3X_BENEF,B3X_CAMPO FROM " + RetSqlName("B3X")
	cSql += " WHERE "
	cSql += " B3X_ARQUIV ='" + cNomArq + "' "
	cSql += " AND B3X_STATUS = '" + ENV_ANS + "'"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBESP",.F.,.T.)
	If !TRBESP->(Eof())
		Do While !TRBESP->(Eof())
			If TRBESP->B3X_BENEF > 0
				B3K->(DbGoto(TRBESP->B3X_BENEF))
				BenToEspANS(AllTrim(TRBESP->B3X_CAMPO))
			EndIf
			TRBESP->(DbSkip())
		EndDo
		BenToEspANS("B3K_SITANS")
	EndIf
	TRBESP->(dbCloseArea())

	//Limpo os B3X (Hist. de Operações)
	cSql := " UPDATE " + RetSqlName('B3X') + " SET "
	cSql += " B3X_STATUS = '" + ACAT_ANS + "' "
	cSql += " WHERE "
	cSql += " B3X_ARQUIV ='" + cNomArq + "' "
	cSql += " AND B3X_STATUS = '" + ENV_ANS + "'"

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	RestArea(aArea)

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ASibAddCri

Atualiza o espelho da ANS com os dados que não foram criticados.

@param cCampo		Campo específico que deve ser atualizado

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenToEspANS(cCampo)

	Local lInclui := .F.

	Default cCampo := ""

	B3W->(DbSetOrder(1))
	lInclui := !B3W->(MsSeek(xFilial("B3W")+B3K->(B3K_CODOPE+B3K_CODCCO)))

	If lInclui .OR. Empty(cCampo)//Inclui/Atualiza o registro inteiro

		B3W->(RecLock("B3W",lInclui))

		/* Atributos */
		B3W->B3W_FILIAL := B3K->B3K_FILIAL
		B3W->B3W_CODOPE := B3K->B3K_CODOPE
		B3W->B3W_CODCCO := B3K->B3K_CODCCO
		B3W->B3W_SITANS := B3K->B3K_SITANS

		/* Identificacao */
		B3W->B3W_CPF 		:= B3K->B3K_CPF
		B3W->B3W_DN 		:= B3K->B3K_DN
		B3W->B3W_PISPAS 	:= B3K->B3K_PISPAS
		B3W->B3W_CNS 		:= B3K->B3K_CNS
		B3W->B3W_NOMBEN 	:= B3K->B3K_NOMBEN
		B3W->B3W_SEXO   	:= B3K->B3K_SEXO
		B3W->B3W_DATNAS 	:= B3K->B3K_DATNAS
		B3W->B3W_NOMMAE	:= B3K->B3K_NOMMAE

		/* Endereco */
		B3W->B3W_ENDERE := B3K->B3K_ENDERE
		B3W->B3W_NR_END := B3K->B3K_NR_END
		B3W->B3W_COMEND := B3K->B3K_COMEND
		B3W->B3W_BAIRRO := B3K->B3K_BAIRRO
		B3W->B3W_CODMUN := B3K->B3K_CODMUN
		B3W->B3W_MUNICI := B3K->B3K_MUNICI
		B3W->B3W_CEPUSR := B3K->B3K_CEPUSR
		B3W->B3W_TIPEND := B3K->B3K_TIPEND
		B3W->B3W_RESEXT := B3K->B3K_RESEXT

		/* Vinculo */
		If GetNewPar("MV_PLMATAN",.F.)
			If Empty(B3K->B3K_MATANT)
				B3W->B3W_MATRIC := B3K->B3K_MATRIC
			Else
				B3W->B3W_MATRIC := B3K->B3K_MATANT
			EndIf
		Else
			B3W->B3W_MATRIC := B3K->B3K_MATRIC
		EndIf

		B3W->B3W_TIPDEP := B3K->B3K_TIPDEP
		B3W->B3W_CODTIT := B3K->B3K_CODTIT
		B3W->B3W_DATINC := B3K->B3K_DATINC
		B3W->B3W_DATREA := B3K->B3K_DATREA
		B3W->B3W_DATBLO := B3K->B3K_DATBLO
		B3W->B3W_MOTBLO := B3K->B3K_MOTBLO
		B3W->B3W_SUSEP  := B3K->B3K_SUSEP
		B3W->B3W_PLAORI := B3K->B3K_PLAORI
		B3W->B3W_SCPA   := B3K->B3K_SCPA
		B3W->B3W_COBPAR := B3K->B3K_COBPAR
		B3W->B3W_ITEEXC := B3K->B3K_ITEEXC
		B3W->B3W_CNPJCO := B3K->B3K_CNPJCO
		B3W->B3W_CEICON := B3K->B3K_CEICON

		B3W->(MsUnlock())

	Else //Atualiza apenas um campo
		If B3W->( FieldPos(cCampo) ) > 0
			B3W->(RecLock("B3W",.F.))
			&("B3W->B3W_"+ SubStr(cCampo,5,6) +" := B3K->" + cCampo)
			B3W->(MsUnlock())
		EndIf
	EndIf

Return Nil