#include "PROTHEUS.CH"
#define MATRIPLS "@R !!!!.!!!!.!!!!!!.!!-!"
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
	#define barra "\"
#ELSE
	#define CRLF Chr(10)
	#define barra "/"
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSA783  บAutor  ณ TOTVS S/A          บ Data ณ 06/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento do arquivo de retorno do SIB XML ( RPX )     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA783()
Local aSays      := {}
Local aButtons   := {}
Local nOpca	     := 0
Local cCadastro  := "Processamento do arquivo de retorno do SIB XML"
Private cPerg    := "PLSA783"
Private cArqLog  := cPerg + "_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao
Private lCriaLog := .F. // Gerar aquivo log
Private nIdxCCO  := A783OrdCCO() // Indice BA1J - BA1_FILIAL+BA1_CODCCO

PlsAtuHlp()

dbSelectArea("BA1")

aAdd(aSays,"Esta rotina irแ processar o arquivo de retorno (RPX) do SIB XML.")

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.,cCadastro,.F.,,.F.)}})
aAdd(aButtons, { 1,.T.,{|| nOpca := 1, If( VldPerg(),FechaBatch(),nOpca := 0)}})
aAdd(aButtons, { 2,.T.,{|| FechaBatch()}})

FormBatch(cCadastro, aSays, aButtons, , 160, 450)

If nOpca == 1
	Processa({||A783Pro(cPerg)},cCadastro,"Processando...",.T.)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A783Pro  บAutor  ณ TOTVS S/A          บ Data ณ 06/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento do arquivo RPX                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A783Pro()
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
Local aCabec      := { {"Tipo registro","@!",20},{"Matrํcula/CCO","@!",17},{"C๓digo erro","@!",04},{"Valor enviado","@!",100},{"Crํtica","@!",250} } // Cabecalho das criticas
Local oTrbCons    := Nil // Objeto XML temporario consolidado
Local aResCons    := {} // Resultado consolidado do processamento do arquivo
local aCabCons    := { {"Tipo registro","@!",20},{"Qtde registros","@!",10},{"Qtde processado","@!",10},{"Qtde rejeitado","@!",10},{"% acerto","@!",10}} // Cabecalho do relatorio consolidado
Local lBA1_DTRSIB	:= BA1->(FieldPos("BA1_DTRSIB")) > 0
Local cDirSIB		:= barra + "sib" + barra
Local lAlt := .T.
cDatRef  := Dtos(mv_par01)
cFileRPX := AllTrim(mv_par02)
lAtuSIB  := If(mv_par03 == 1,.T.,.F.)
lCriaLog := If(mv_par04 == 1,.T.,.F.)

If lAtuSIB .And. !CheckBEAIndex("BA1J")
	lAtuSIB := .F.
	MsgInfo("A atualiza็ใo dos registros nใo serแ executada!" + CRLF + "Falta ํndice. Execute o compatibilizador UPDPLSIB.","TOTVS")
EndIf

If lCriaLog // Cabecalho do log
	cMsg := "Processamento do RPX - Inํcio: " + Dtos(dDatabase) + " " + Time() + CRLF
	cMsg += "Parโmetros informados para processamento: " + CRLF
	cMsg += "Data de refer๊ncia: " + cDatRef + CRLF
	cMsg += "Arquivo RPX: " + cFileRPX + CRLF
	cMsg += "Atualiza SIB: " + If(lAtuSIB,"Sim","Nใo") + CRLF
	cMsg += "Gera arquivo log: " + If(lCrialog,"Sim","Nใo")
	PlsLogFil(cMsg,cArqLog)
EndIf

If !Substr(cFileRPX,1,1) $ "/\"//Verifica se o arquivo esta no cliente
	If !ExistDir(cDirSIB) //Verifica se existi o diretorio /sib/
		If MakeDir(cDirSIB) <> 0 //Tenta criar o diretorio
			MsgInfo("Nใo foi possํvel criar o diret๓rio " + cDirSIB + "." + CRLF + "Contate o administrador do sistema.")
			Return .F.
		EndIf
		Sleep(2000)//Preciso aguardar o SO enchergar que o diretorio foi criado
	EndIf
	If !CpyT2S(cFileRPX,cDirSIB)//Tenta transferir o arquivo do cliente para o servidor
		MsgInfo("Nใo foi possํvel transfeir o arquivo para o servidor." + CRLF + "Contate o administrador do sistema.")
		Return .F.
	Else
		cFileRPX := cDirSIB + SubStr(cFileRPX,Rat("\",cFileRPX)+1,Len(cFileRPX))
	EndIf
EndIf

oXml := XmlParserFile(cFileRPX,"_",@cError,@cWarning)

If Empty(cError) .And. Empty(cWarning) .And. oXml != Nil

	oTrbXml := XmlChildEx(oXml,"_MENSAGEMSIB") // Carrega o objeto XML com o conteudo do arquivo

	If ValType(XmlChildEx(oTrbXml:_MENSAGEM,"_ANSPARAOPERADORA")) != "O" // Verifica se o arquivo carrega e valido

		MsgInfo("Arquivo selecionado ้ invแlido!","TOTVS")
		If lCriaLog
			PlsLogFil("Arquivo selecionado ้ invแlido!",cArqLog)
		EndIf
		Return .F.

	Else
		If lCriaLog
			PlsLogFil("Arquivo " + cFileRPX + " ้ vแlido!",cArqLog)
		EndIf
	EndIf
	
	//Verifica se o arquivo foi rejeitado pela ANS
	If ValType(XmlChildEx(oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO,"_ARQUIVOREJEITADO")) == "O"
		MsgInfo("Arquivo rejeitado pela ANS." + CRLF + "Motivo: " + oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOREJEITADO:_MOTIVOREJEICAO:TEXT,"TOTVS")
		Return .F.
	EndIf

	//Atualiza o objeto com os dados consolidados
	oTrbCons := oTrbXml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO:_CONSOLIDADO:_CONSOLIDADOPROCESSAMENTO

	//Atualiza o objeto com os registros rejeitados
	oTrbRej := XmlChildEx(oTrbxml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO,"_REGISTROSREJEITADOS")

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

			// Armazeno as criticas na matriz
			If ValType(oTrbRej) == "A" // Mais de um registro com critica

  				If ValType(oTrbRej[iRegs]:_CAMPOERRO) != "A"

		            aCritsReg := A783GetCri(oTrbRej[iRegs]:_CAMPOERRO)
					A783AddCri(aCriticas,oTrbRej[iRegs]:_TIPOMOVIMENTO:TEXT,;
						If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej[iRegs]:_CODIGOBENEFICIARIO:TEXT,oTrbRej[iRegs]:_CCO:TEXT),;
						aCritsReg[1],;
						aCritsReg[3],;
						aCritsReg[2])

				Else // Mais de uma critica no mesmo registro

					For iCriticas := 1 To Len(oTrbRej[iRegs]:_CAMPOERRO)

						aCritsReg := A783GetCri(oTrbRej[iRegs]:_CAMPOERRO[iCriticas])
						A783AddCri(aCriticas,oTrbRej[iRegs]:_TIPOMOVIMENTO:TEXT,;
							If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej[iRegs]:_CODIGOBENEFICIARIO:TEXT,oTrbRej[iRegs]:_CCO:TEXT),;
							aCritsReg[1],;
							aCritsReg[3],;
							aCritsReg[2])

					Next iCriticas

				EndIf

			Else // Apenas um registro criticado

				If ValType(oTrbRej:_CAMPOERRO) == "A" // Mais de uma critica no registro

					For iCriticas := 1 To Len(oTrbRej:_CAMPOERRO)

						aCritsReg := A783GetCri(oTrbRej:_CAMPOERRO[iCriticas])
						A783AddCri(aCriticas,oTrbRej:_TIPOMOVIMENTO:TEXT,;
							If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej:_CODIGOBENEFICIARIO:TEXT,oTrbRej:_CCO:TEXT),;
							aCritsReg[1],;
							aCritsReg[3],;
							aCritsReg[2])

					Next iCriticas

				Else // Apenas uma critica no registro
						aCritsReg := A783GetCri(oTrbRej:_CAMPOERRO)
						A783AddCri(aCriticas,oTrbRej:_TIPOMOVIMENTO:TEXT,;
							If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej:_CODIGOBENEFICIARIO:TEXT,oTrbRej:_CCO:TEXT),;
							aCritsReg[1],;
							aCritsReg[3],;
							aCritsReg[2])
				EndIf

			EndIf //If ValType(oTrbXml) == "A"

			If lAtuSIB // Vou atualizar o beneficiario da critica

				If ValType(oTrbRej) == "A" // Mais de um registro com critica

					A783AtuSib( If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej[iRegs]:_CODIGOBENEFICIARIO:TEXT,""),;
							.T.,;
							oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT,;
							If(oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT == "1","",oTrbRej[iRegs]:_CCO:TEXT),oTrbRej[iRegs]:_CODIGOTIPOMOVIMENTO:TEXT,;
							cDatRef,lBA1_DTRSIB)

				Else // Apenas um registro criticado

					A783AtuSib( If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1",oTrbRej:_CODIGOBENEFICIARIO:TEXT,""),;
							.T.,;
							oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT,;
							If(oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT == "1","",oTrbRej:_CCO:TEXT),oTrbRej:_CODIGOTIPOMOVIMENTO:TEXT,;
							cDatRef,lBA1_DTRSIB)

				EndIf

			EndIf //If lAtuSIB

			iRegs++

		EndDo

	EndIf

	//Atualiza o objeto com os registros incluidos
	oTrbInc := XmlChildEx(oTrbxml:_MENSAGEM:_ANSPARAOPERADORA:_RESULTADOPROCESSAMENTO:_ARQUIVOPROCESSADO,"_REGISTROSINCLUIDOS")

	If oTrbInc == Nil //Posso ter um arquivo RPX sem nenhum registro de inclusao rejeitado

		MsgInfo("Nใo existem registros incluอdos para serem processados","TOTVS")
		If lCriaLog
			PlsLogFil("Nใo existem registros incluอos para serem processados",cArqLog)
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
	
				If lAtuSIB // Vou atualizar o beneficiario da INCLUSรO
	
					If ValType(oTrbInc) == "A" // Mais de um registro DE INCLUSรO
						A783AtuSib( oTrbInc[iRegs]:_CODIGOBENEFICIARIO:TEXT,;
						.F.,;
						"1",;
						oTrbInc[iRegs]:_CCO:TEXT,"1",cDatRef,lBA1_DTRSIB) //alterado
						cMat := SUBSTR(oTrbInc[iRegs]:_CODIGOBENEFICIARIO:TEXT, 9, 6)//atribui a matricula do usuแrio na BA1
						lAlt := .F.	
					Else // Apenas um registro DE INCLUSรO
	
						A783AtuSib( oTrbInc:_CODIGOBENEFICIARIO:TEXT,;
						.F.,;
						"1",;
						oTrbInc:_CCO:TEXT,"1",cDatRef,lBA1_DTRSIB) //alterado
						cMat := SUBSTR(oTrbInc:_CODIGOBENEFICIARIO:TEXT, 9, 6)//atribui a matricula do usuแrio na BA1
						lAlt := .F.
					EndIf
					A783AtuOk(cDatRef,lBA1_DTRSIB, cMat,,)
				EndIf //If lAtuSIB
	
				iRegs++
	
			EndDo

	EndIf

	If lAlt//se for altera็ใo entra na fun็ใo e atualizo tudo
		If lAtuSIB // Vou atualizar todos beneficiarios que nao foram criticados
			A783AtuOk(cDatRef,lBA1_DTRSIB, , lAlt)
		EndIf
	Endif
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
			aAdd(aResCons,{"Inclusใo",oTrbCons:_CONSOLIDADOINCLUSAO:_QUANTIDADEREGISTROS:TEXT,;
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
			aAdd(aResCons,{"Reativa็ใo",oTrbCons:_CONSOLIDADOREATIVACAO:_QUANTIDADEREGISTROS:TEXT,;
				oTrbCons:_CONSOLIDADOREATIVACAO:_QUANTIDADEPROCESSADOS:TEXT,;
				oTrbCons:_CONSOLIDADOREATIVACAO:_QUANTIDADEREJEITADOS:TEXT,;
				oTrbCons:_CONSOLIDADOREATIVACAO:_PERCENTUALACERTO:TEXT})
		EndIf

		If ValType(oTrbCons:_CONSOLIDADORETIFICACAO) == "O"
			aAdd(aResCons,{"Retifica็ใo",oTrbCons:_CONSOLIDADORETIFICACAO:_QUANTIDADEREGISTROS:TEXT,;
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
	MsgInfo("Nใo foi possํvel ler o arquivo RPX" + CRLF + cError,"TOTVS")
	If lCriaLog
		PlsLogFil("Nใo foi possํvel ler o arquivo RPX",cArqlog)
		PlsLogFil("Avisos: " + cWarning,cArqlog)
		PlsLogFil("Erros: " + cError,cArqlog)
	EndIf
EndIf

If MsgYesNo("Deseja salvar o resultado das crํticas em arquivo .CSV ?","TOTVS")

	cDirCsv := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
	nFileCsv := FCreate(cDirCsv+"RetornoSIB.csv",0,,.F.)
	If nFileCsv > 0
		FWrite(nFileCSV,"Tipo registro;Matricula/CCO;Cod. Erro;Valor Enviado;Critica"+CRLF)
		For iCriticas := 1 TO Len(aCriticas)
			FWrite(nFileCSV,aCriticas[iCriticas,1]+";"+aCriticas[iCriticas,2]+";"+aCriticas[iCriticas,3]+";"+aCriticas[iCriticas,4]+";"+aCriticas[iCriticas,5]+CRLF)
		Next iCriticas
		FClose(nFileCSV)
	Else
		MsgInfo("Nใo foi possํvel criar o arquivo " + cDirCsv+cFileRPX,"TOTVS")
	EndIf

EndIf

If Len(aCriticas) > 0 // Se teve criticas vou apresentar
	PlsCriGen(aCriticas,aCabec,"Relat๓rio de crํticas do retorno do SIB - " + Dtoc(mv_par01),,"Retorno do SIB",,,,,"G",220)
EndIf

If Len(aResCons) > 0 // Se tem informacoes consolidadas vou apresentar
	PlsCriGen(aResCons,aCabCons,"Relat๓rio consolidado do retorno do SIB - " + Dtoc(mv_par01),,"Retorno do SIB",,,,,"G",220)
EndIf

If lCrialog
	cMsg := "Gera็ใo do arquivo do SIB - T้rmino: " + Dtos(dDatabase) + " - " + Time()
	PlsLogFil(cMsg,cArqLog)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VlrPerg  บ Autor ณ TOTVS S/A          บ Data ณ 07/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o preenchimento das perguntas de execucao da rotina บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldPerg()
Local lRet := .T.
Local cMsg := ""

If Empty(mv_par01)
	lRet := .F.
	cMsg := "Informe a Data de refer๊ncia" + CRLF
EndIf

If Empty(mv_par02)
	lRet := .F.
	cMsg += "Selecione o arquivo RPX" + CRLF
EndIf

If !lRet
	MsgInfo(cMsg,"TOTVS")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA783AtuSibบAutor  ณ TOTVS S/A          บ Data ณ 06/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o registro do beneficiario de acordo com o arqui  บฑฑ
ฑฑบ          ณ vo de retorno RPX.                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Se o registro foi rejeitado (lCritica == .T.) vou atualizarบฑฑ
ฑฑบ          ณ o status com codigo de critica:                            บฑฑ
ฑฑบ          ณ 6=Criticado na inclusao,7=Criticado na alteracao,8=Critica บฑฑ
ฑฑบ          ณ do na exclusao, B=Criticado na mudanca contratual, C=Criti บฑฑ
ฑฑบ          ณ cado na reativaca.                                         บฑฑ
ฑฑบ          ณ Se o arquivo de retorno mandou o CCO (!Empty(cCodCCO), atu บฑฑ
ฑฑบ          ณ alizo no beneficiario                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783AtuSib(cMatUsr,lCritica,cTipReg,cCodCCO,cTipMov,cDatRef,lBA1_DTRSIB)
Local cLocSib := ""
Local cLogSib := ""
Default lBA1_DTRSIB := .F.

cLogSib := "Tipo de registro: " + cTipReg + " - " + Iif(!Empty(cMatUsr),"Matrํcula: " + cMatUsr,"CCO: " + cCodCCO) + " - Crํtica?: " + Iif(lCritica,"Nใo","Sim")

BA1->(dbSetOrder(Iif(!Empty(cMatUsr),2,nIdxCCO)))

If BA1->(dbSeek(xFilial("BA1")+Iif(!Empty(cMatUsr),cMatUsr,cCodCCO))) // Se for inclusao procuro pela matricula, senao pelo CCO

	If cTipMov == "3" .And. Empty(cMatUsr) // Se for mudanca contratual, nao posso deixar atualizar o registro enviado como alteracao que tem o mesmo cco
		While !BA1->(Eof()) .And. BA1->BA1_CODCCO == cCodCCO
			If BA1->BA1_LOCSIB == "9" // So posso alterar o registro do BA1 com mesmo CCO e que esteja enviado a mudanca contratual
				Exit
			EndIf
			BA1->(dbSkip())
		EndDo

		If lCriaLog
			PlsLogFil(cLogSib + " - NรO ENCONTRADO",cArqLog)
		EndIf
	EndIf

	If !BA1->(Eof())
		cLocSib := BA1->BA1_LOCSIB
		BA1->(RecLock("BA1",.F.))
		BA1->BA1_LOCSIB := RetLocSib(lCritica,BA1->BA1_DATBLO,BA1->BA1_LOCSIB)
		If Empty(BA1->BA1_CODCCO) .And. cTipReg == "1"
			BA1->BA1_CODCCO := cCodCCO
		EndIf
		If lBA1_DTRSIB
			BA1->BA1_DTRSIB	:= STOD(cDatRef)
		EndIf
		BA1->(msUnlock())
	EndIf

	If lCriaLog
		PlsLogFil(Transform(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) + " - " + Iif(!lCritica,"Ok","Err") + " - Status ANS atualizado de " + cLocSib + " para " + BA1->BA1_LOCSIB,cArqLog)
	EndIf

Else

	If lCriaLog
		PlsLogFil(cLogSib + " - NรO ENCONTRADO",cArqLog)
	EndIf

EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA783GetCriบ Autor ณ TOTVS S/A          บ Data ณ 08/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a critica do registro enviado                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783GetCri(aObj)
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |A783AddCriบ Autor ณ TOTVS S/A          บ Data ณ 08/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona a critica na matriz para o relatorio              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783AddCri(aCriticas,cTipo,cCodTip,cCodErr,cVlrEnv,cDesCri)

aAdd(aCriticas,{cTipo,cCodTip,cCodErr,cVlrEnv,cDesCri})

If lCrialog
	PlsLogFil(cTipo +" - "+ cCodTip +" - "+ cCodErr +" - "+ cVlrEnv +" - "+ cDesCri,cArqlog)
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |A783AtuOk บ Autor ณ TOTVS S/A          บ Data ณ 11/07/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza todos os beneficiarios enviados e nao criticados  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783AtuOk(cDatRef,lBA1_DTRSIB, cMatUsr, lAlt)
Local cSqlSIB := ""
Local cLocSib := ""

If !lAlt
	cSqlSIB := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_CODCCO, BA1_LOCSIB, BA1_DATBLO "
	cSqlSIB += "FROM " + RetSqlName("BA1") + " "
	cSqlSIB += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND D_E_L_E_T_ = ' ' AND BA1_MATRIC =  '" + ALLTRIM(cMatUsr) + "' "
	cSqlSIB += "AND BA1_INFANS <> '0' AND BA1_ATUSIB <> '0' AND BA1_INFSIB <> '0' AND BA1_LOCSIB IN ('3','4','5','9','A')" // 3=Enviado incl;4=Enviado alt;5=Enviado excl, 9=Enviado mudanca contratual, B=Enviado reativacao
Else
	cSqlSIB := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_CODCCO, BA1_LOCSIB, BA1_DATBLO "
	cSqlSIB += "FROM " + RetSqlName("BA1") + " "
	cSqlSIB += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND D_E_L_E_T_ = ' ' "
	cSqlSIB += "AND BA1_INFANS <> '0' AND BA1_ATUSIB <> '0' AND BA1_INFSIB <> '0' AND BA1_LOCSIB IN ('3','4','5','9','A')" // 3=Enviado incl;4=Enviado alt;5=Enviado excl, 9=Enviado mudanca contratual, B=Enviado reativacao
Endif
cSqlSIB := ChangeQuery(cSqlSIB)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlSIB),"TRBSIB",.F.,.T.)

TCSETFIELD("TRBSIB","BA1_DATBLO","D",8,0)

If lCrialog
	PlsLogFil("Carga SIB: " + cSqlSIB,cArqlog)
EndIf

While !TRBSIB->(Eof())

	BA1->(dbSetOrder(2))

	If BA1->(dbSeek(xFilial("BA1")+TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)))

		cLocSib := BA1->BA1_LOCSIB
		BA1->(RecLock("BA1",.F.))
		BA1->BA1_LOCSIB := RetLocSib(.F.,TRBSIB->BA1_DATBLO,TRBSIB->BA1_LOCSIB)
		If lBA1_DTRSIB
			BA1->BA1_DTRSIB := STOD(cDatRef)
		EndIf
		BA1->(msUnlock())

		If lCriaLog
			PlsLogFil(Transform(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) + " - Ok - Status ANS atualizado de " + cLocSib + " para " + BA1->BA1_LOCSIB,cArqLog)
		EndIf

	EndIf

	TRBSIB->(dbSkip())

EndDo

TRBSIB->(dbCloseArea())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA783OrdCCOบAutor  ณMicrosiga           บ Data ณ  27/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a ordem do indice do CCO                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783OrdCCO()
Local nOrd := 1

If SIX->(dbSeek("BA1A"))
	nOrd := 10
	While SIX->INDICE == "BA1" .And. SIX->(INDICE+ORDEM) != "BA1J"
		nOrd++
		SIX->(dbSkip())
	EndDo
EndIf

Return nOrd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlsAtuHlp บAutor  ณMicrosiga           บ Data ณ  27/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os helps do parametros da rotina                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PlsAtuHlp()

PutSx1Help("P."+cPerg+"01.",{"Data de processamento do arquivo"}, {},{})
PutSx1Help("P."+cPerg+"02.",{"Selecione no servidor o arquivo"," RPX a ser processado"}, {},{})
PutSx1Help("P."+cPerg+"03.",{"Informe se deseja atualizar o ","status do usuแrio"}, {},{})
PutSx1Help("P."+cPerg+"04.",{"Informe se deseja gerar um log","da execu็ใo do processamento"}, {},{})

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetLocSib บAutor  ณMicrosiga           บ Data ณ  17/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o proximo status do BA1_LOCSIB que esta sendo atua  บฑฑ
ฑฑบ          ณlizado                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetLocSib(lCritica,dDatBlo,cLocSib)
Local cStaSib := "0" // Nao enviado

If !lCritica // Sem critica

	Do Case
		Case cLocSib == "3" // Enviado inclusao
			cStaSib := "1" // Ativo
		Case cLocSib == "4" // Enviado retificao
			cStaSib := Iif(Empty(dDatBlo),"1","2") // Se nao estiver bloqueado: Ativo, senao Cancelado
		Case cLocSib == "5" // Enviado cancelamento
			cStaSib := "2" // Cancelado
		Case cLocSib == "A" // Enviado reativacao
			cStaSib := "1" // Ativo
		Case cLocSib == "9" // Enviado mudanca contratual
			cStaSib := "1" // Ativo
	EndCase

Else // Com critica

	Do Case
		Case cLocSib == "3" // Enviado inclusao
			cStaSib := "6" // Criticado inclusao
		Case cLocSib == "4" // Enviado retificacao
			cStaSib := "7" // Criticado retificacao
		Case cLocSib == "5" // Enviado cancelamento
			cStaSib := "8" // Criticado cancelamento
		Case cLocSib == "A" // Enviado reativacao
			cStaSib := "C" // Criticado reativacao
		Case cLocSib == "9" // Enviado mudanca contratual
			cStaSib := "B" // Criticado mudanca contratual
	EndCase

EndIf

Return cStaSib