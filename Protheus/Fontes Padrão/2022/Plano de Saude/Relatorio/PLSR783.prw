#Include 'protheus.ch'
#Include 'fileio.ch'
#Include 'plsr783.ch'
#Define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSM783  บAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para leitura do arquivo CNX e criacao do arquivo de บฑฑ
ฑฑบ          ณ trabalho SIBCNX.(DBF/DTC). Baseado no CSV criado sera gera บฑฑ
ฑฑบ          ณ em formato CSV o relatorio de de/para das bases de dados   บฑฑ
ฑฑบ          ณ CNX(ANS) X PLS                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR783()
Local cBuild		:= GetBuild()
Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local cPerg			:= "PLR783"
Private cCadastro	:= STR0001//"Processamento do arquivo de confer๊ncia do SIB XML"
Private cDirPrcSib	:= GetNewPar("MV_SIBDIRP","SIB")//GetMV( "MV_SIBDIRP", ,"SIB" )
Private aDtReativ	:={}
Private oTempTRB
Private cArqTmp

If SubStr(cBuild,Len(cBuild)-7,Len(cBuild)) < "20120314"
	MsgInfo(STR0002 + CRLF + STR0003,STR0004) //"Rotina homologada a partir da build 7.00.111010P-20120314." + CRLF + "Atualize a versใo da build para executar a rotina.","Aviso"
	Return Nil
EndIf

Pergunte(cPerg,.F.)

aAdd(aSays,STR0005)//"Esta rotina irแ processar o arquivo de confer๊ncia (CNX) do SIB XML."
aAdd(aSays,STR0006)//"Ao t้rmino serแ gerado um arquivo de confer๊ncia em formato CSV."

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd(aButtons, { 1,.T.,{|| nOpca := 1, If( .T.,FechaBatch(),nOpca := 0)}})
aAdd(aButtons, { 2,.T.,{|| FechaBatch()}})

FormBatch(cCadastro, aSays, aButtons, , 160)

If nOpca == 1
	Processa({|| PLSR783PRO()},cCadastro,"Processando...",.T.)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR783PROบAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento do arquivo de conferencia do SIB             บฑฑ
ฑฑบ          ณ ArqConf0000000000000000.CNX                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLSR783PRO()
Local cError	:= "" //Erros encontrados ao ler o xml
Local cWarning	:= "" //Avisos encontrados ao ler o xml
Local cPathTag	:= "" //Caminho do node ou child a ser procurado no xml
Local cCodTit	:= GetNewPar("MV_PLCDTIT","T") // Codigo indicador do Titular do contrato no PLS
Local aTmp		:= {} //Matriz para uso temporario durante o processamento
Local aGraPar	:= {} //Grau de parentesco cadastrado n1o PLS - BRP
Local oXml		:= tXmlManager():NEW() //Instancia da classe tXmlManager
Local cArqLog	:= "PLSCNX_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" //Nome do arquivo de log a ser gerado durante o processamento
Local cArqCNX	:= AllTrim(mv_par01) //Arquico de conferencia no formato CNX que sera processado
Local lDigito	:= If(mv_par02 == 1,.T.,.F.) // Enviar matricula com digito ?
Local lMatAnt	:= If(mv_par03 == 1,.T.,.F.) // Usar matricula antiga ?
Local lAtuCNS	:= If(mv_par04 == 1,.T.,.F.) // Usar matricula antiga ?
Local nFor		:= 0 //Variavel para implementar FOR .. NEXT
Local cExtTab	:= Iif(RealRDD() == 'CTREE','DTC','DBF') //Extensao do arquivo a ser utilizado de acordo com o tipo de driver
Local cArqTab	:= If(IsSrvUnix(),"SIBCNX."+cExtTab,"SIBCNX."+cExtTab) //Nome do arquivo de trabalho mais a extensao
Local cNomeArq	:= cArqCNX
Local i			:= 0
Local nRegua	:= 1
Local bRegPro	:= {|| IIf( NoRound(nRegua / 100,0) == 0,.T.,.F.)}
Local cDrive, cDir, cNome, cExt  
Local nPosDirPt := 0

SplitPath(cArqCNX, @cDrive, @cDir, @cNome, @cExt )

PlsLogFil(DtTime() + STR0007 +  cArqCNX,cArqLog)//"Inicio do processamento do arquivo "

If !File(cArqCNX)
	MsgInfo(STR0008 + cArqCNX,STR0004)//"Arquivo nใo encontrado: ","Aviso"
	Return Nil
EndIf

PLSTRABCNX(cArqTab,cExtTab)//Cria a tabela temporaria SIBCNX.(DBF/DTC)

For i:=1 to Len(Alltrim(cArqCNX))
	If (nPos := RAT(If(GETREMOTETYPE()==2,"/","\"), cArqCNX)) != 0
		nPosDirPt:=nPos
	Endif
Next i

If nPosDirPt > 0
	cNomeArq := Substr(cArqCNX,(nPosDirPt+1),(Len(Alltrim(cArqCNX))-nPosDirPt))
Endif

aDir := DIRECTORY(If(lLinux,"/"+cDirPrcSib,"\"+cDirPrcSib),"D")
IF LEN(aDir)=0
	nResult := MAKEDIR(If(lLinux,GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())+"/"+cDirPrcSib,GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())+"\"+cDirPrcSib)) // Cria um diret๓rio na estacao
ENDIF

If File(cArqCNX) .And. !Empty(AllTrim(cDirPrcSib))
	If Empty (cDrive)
		lCopied := CpyT2S(If(lLinux,GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())+"/"+cDirPrcSib + alltrim(cArqCNX),GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())+"\"+cDirPrcSib + alltrim(cArqCNX)), If(lLinux,"/"+cDirPrcSib,"\"+cDirPrcSib),.F.)
    Else
		lCopied := CpyT2S(alltrim(cArqCNX), If(lLinux,"/"+cDirPrcSib,"\"+cDirPrcSib),.F.)
    EndIf 	    	
EndIf
cFormacArq:=If(lLinux,"/"+cDirPrcSib,"\"+cDirPrcSib)+If(lLinux,"/"+cDirPrcSib,"\")+cNomeArq

If !Empty(AllTrim(cDirPrcSib+"\"+cNomeArq))
	cNomeArq := cDirPrcSib+"\"+cNomeArq
EndIf

/* Este metodo realiza o parser XML, atraves do parametro recebido contendo o xml e constroi o tree  */
If oXml:ReadFile(IIf (Empty(cDrive),alltrim(cArqCNX),alltrim(cNomeArq)),,oXml:Parse_noblanks)
	PlsLogFil(DtTime() + "ReadFile realizado com sucesso",cArqLog)
Else
	cError := oXml:Error()
	cWarning := oXml:Warning()
	If !Empty(cWarning) .Or. !Empty(cError)
		MsgInfo(STR0009 + CRLF + STR0004 + AllTrim(cWarning) + CRLF + "Erro: " + AllTrim(cError),STR0010)//"Nao foi possivel realizar a leitura do arquivo de confer๊ncia." + CRLF + "Aviso: " + cWarning,"Encerramento"
	Else
		MsgInfo(STR0009,STR0010)//"Nao foi possivel realizar a leitura do arquivo de confer๊ncia." + CRLF + "Aviso: " + cWarning,"Encerramento"
	Endif
	PlsLogFil(DtTime() + "Aviso: " + cWarning,cArqLog)
	PlsLogFil(DtTime() + "Erros: " + cError,cArqLog)
	Return Nil
EndIf

/* Informacoes da mensagem */
cPathTag := "//mensagemSIB/mensagem/ansParaOperadora/conferencia"
If oXml:XPathHasNode(cPathTag)
	aTmp := oXml:XPathGetChildArray(cPathTag)

	nRegua := Len(aTmp)
	ProcRegua(nRegua)

	If Len(aTmp) > 0

		PlsLogFil(DtTime() + "Mensagem do arquivo encontrado em: " + cPathTag,cArqLog)

		For nFor := 1 To Len(aTmp)
			PLSINCTRAB(PLBENCNX(oXml,aTmp[nFor],cArqLog),cArqTab,cExtTab,lAtuCNS,aGraPar,lMatAnt,lDigito,cCodTit,Eval(bRegPro),cArqLog)
		Next nFor

		PlsLogFil(DtTime() + AllTrim(Str(nFor)) + " registros lidos no arquivo CNX. ",cArqLog)

	Else
		aTmp := {}
	EndIf
Else
	MsgInfo(STR0011,STR0010)//"Mensagem do arquivo nao encontrada!","Encerramento"
	PlsLogFil(DtTime() + "Nao foi possivel encontrar a mensagem do arquivo em: " + cPathTag,cArqlog)
	Return Nil
EndIf

PlsLogFil(DtTime() + "T้rmino do processamento do arquivo. " + cArqCNX,cArqLog)

PLCNXTOCSV(cArqLog,cArqTab,cExtTab) //Escrevo o arquivo temporario em CSV

if( select( cArqTmp ) > 0 )
	oTempTRB:delete()
endIf

MsgInfo(STR0012,STR0004)//"T้rmino do processamento do arquivo CNX!","Aviso"

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLBENCNX บAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para retornar numa matriz os dados do usuarioบฑฑ
ฑฑบ          ณ posicionado no arquivo CNX                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLBENCNX(oXml,aTmp,cArqLog)
Local aBen := {} //dados temporario do usuario no arquivo
Local aRet := {} //registro completo do usuario no arquivo
Local nBen := 0  //contador para FOR...NEXT
Local cStr := ""

/* Get dos atributos cco, situacao e dataatualizacao */
If oXml:XPathChildCount(aTmp[2]) > 0

	aBen := oXml:XPathGetAttArray(aTmp[2])

	For nBen := 1 To Len(aBen)
		If	aBen[nBen,1]<>"dataAtualizacao"
			aAdd(aRet,aBen[nBen])
		Endif
	Next nBen

Else
	nBen := 0
	aBen := {}
	PlsLogFil(DtTime() + "Nao foi possivel identificar cco, situacao e data de atualizacao" + aTmp[2],cArqLog)
EndIf

/* Identificacao do beneficiario  */
cStr := "/identificacao"
If oXml:XPathChildCount(aTmp[2]+cStr) > 0

	aBen := oXml:XPathGetChildArray(aTmp[2]+cStr)

	For nBen := 1 To Len(aBen)
		aAdd(aRet,{aBen[nBen,1],aBen[nBen,3]})
	Next nBen

Else
	nBen := 0
	aBen := {}
	PlsLogFil(DtTime() + "Nao foi possivel identificar o beneficiario" + aTmp[2] + cStr,cArqLog)
EndIf

cStr := "/endereco"
If oXml:XPathChildCount(aTmp[2]+cStr) > 0

	aBen := oXml:XPathGetChildArray(aTmp[2]+cStr)

	For nBen := 1 To Len(aBen)
		aAdd(aRet,{aBen[nBen,1],aBen[nBen,3]})
	Next nBen

Else
	nBen := 0
	aBen := {}
	PlsLogFil(DtTime() + "Nao foi possivel identificar o endereco do beneficiario" + aTmp[2] + cStr,cArqLog)
EndIf

cStr := "/vinculo"
If oXml:XPathChildCount(aTmp[2]+cStr) > 0

	aBen := oXml:XPathGetChildArray(aTmp[2]+cStr)

	For nBen := 1 To Len(aBen)
		aAdd(aRet,{aBen[nBen,1],aBen[nBen,3]})
	Next nBen

Else
	nBen := 0
	aBen := {}
	PlsLogFil(DtTime() + "Nao foi possivel identificar o vinculo do beneficiario" + aTmp[2] + cStr,cArqLog)
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DtTime   บAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Data e hora formatada para escrever do log de processamentoบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DtTime()
Return(Dtos(dDataBase) + "_" + Time() + ": ")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSTRABCNXบAutor  | TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria tabela em arquivo para conferencia do SIB             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLSTRABCNX(cArqTab,cExtTab)
Local aStru   := {} //Estrutura do arquivo a ser criado de acordo com XSD de conferencia. TRF = CNX; TRB = Base de dados PLS
Local cIndCCO := "TRF_CODCCO" //Campo a ser utilizado no indice do arquivo

If File(cArqTab) //Se existe, vou apagar a tabela temporaria e se arquivo de indice
	If FErase(cArqTab) == -1
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', Str(FError()) , 0, 0, {})
	EndIf
	If FErase(SubStr(cArqTab,1,Len(cArqTab)-3)+"CDX") == -1
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', Str(FError()) , 0, 0, {})
	EndIf
	Sleep(2000)
EndIf

/* Atributos */
aAdd(aStru,{"TRF_CODCCO",'C',12,0})
aAdd(aStru,{"TRB_CODCCO",'C',12,0})
aAdd(aStru,{"TRF_DIF1"	,'C',03,0})

aAdd(aStru,{"TRF_SITUAC",'C',07,0})
aAdd(aStru,{"TRB_SITUAC",'C',07,0})
aAdd(aStru,{"TRF_DIF2"	,'C',03,0})

/* Identificacao */
aAdd(aStru,{"TRF_CPFUSR",'C',11,0})
aAdd(aStru,{"TRB_CPFUSR",'C',11,0})
aAdd(aStru,{"TRF_DIF3"	,'C',03,0})

aAdd(aStru,{"TRF_DENAVI",'C',11,0})
aAdd(aStru,{"TRB_DENAVI",'C',11,0})
aAdd(aStru,{"TRF_DIF4"	,'C',03,0})

aAdd(aStru,{"TRF_PISPAS",'C',11,0})
aAdd(aStru,{"TRB_PISPAS",'C',11,0})
aAdd(aStru,{"TRF_DIF5"	,'C',03,0})

aAdd(aStru,{"TRF_NRCRNA",'C',15,0})
aAdd(aStru,{"TRB_NRCRNA",'C',15,0})
aAdd(aStru,{"TRF_DIF6"	,'C',03,0})

aAdd(aStru,{"TRF_NOMUSR",'C',70,0})
aAdd(aStru,{"TRB_NOMUSR",'C',70,0})
aAdd(aStru,{"TRF_DIF7"	,'C',03,0})

aAdd(aStru,{"TRF_SEXO"  ,'C',01,0})
aAdd(aStru,{"TRB_SEXO"  ,'C',01,0})
aAdd(aStru,{"TRF_DIF8"	,'C',03,0})

aAdd(aStru,{"TRF_DATNAS",'C',08,0})
aAdd(aStru,{"TRB_DATNAS",'C',08,0})
aAdd(aStru,{"TRF_DIF9"	,'C',03,0})

aAdd(aStru,{"TRF_MAE"   ,'C',70,0})
aAdd(aStru,{"TRB_MAE"   ,'C',70,0})
aAdd(aStru,{"TRF_DIF10"	,'C',03,0})

/* Endereco */
aAdd(aStru,{"TRF_ENDERE",'C',50,0})
aAdd(aStru,{"TRB_ENDERE",'C',50,0})
aAdd(aStru,{"TRF_DIF11"	,'C',03,0})

aAdd(aStru,{"TRF_NR_END",'C',05,0})
aAdd(aStru,{"TRB_NR_END",'C',05,0})
aAdd(aStru,{"TRF_DIF12"	,'C',03,0})

aAdd(aStru,{"TRF_COMEND",'C',15,0})
aAdd(aStru,{"TRB_COMEND",'C',15,0})
aAdd(aStru,{"TRF_DIF13"	,'C',03,0})

aAdd(aStru,{"TRF_BAIRRO",'C',30,0})
aAdd(aStru,{"TRB_BAIRRO",'C',30,0})
aAdd(aStru,{"TRF_DIF14"	,'C',03,0})

aAdd(aStru,{"TRF_CODMUN",'C',06,0})
aAdd(aStru,{"TRB_CODMUN",'C',06,0})
aAdd(aStru,{"TRF_DIF15"	,'C',03,0})

aAdd(aStru,{"TRF_CDMUNR",'C',06,0})
aAdd(aStru,{"TRB_CDMUNR",'C',06,0})
aAdd(aStru,{"TRF_DIF16"	,'C',03,0})

aAdd(aStru,{"TRF_CEPUSR",'C',08,0})
aAdd(aStru,{"TRB_CEPUSR",'C',08,0})
aAdd(aStru,{"TRF_DIF17"	,'C',03,0})

aAdd(aStru,{"TRF_TIPEND",'C',01,0})
aAdd(aStru,{"TRB_TIPEND",'C',01,0})
aAdd(aStru,{"TRF_DIF18"	,'C',03,0})

aAdd(aStru,{"TRF_RESEXT",'C',01,0})
aAdd(aStru,{"TRB_RESEXT",'C',01,0})
aAdd(aStru,{"TRF_DIF19"	,'C',03,0})

/* Vinculo */
aAdd(aStru,{"TRF_MATRIC",'C',30,0})
aAdd(aStru,{"TRB_MATRIC",'C',30,0})
aAdd(aStru,{"TRF_DIF20"	,'C',03,0})

aAdd(aStru,{"TRF_GRAUPA",'C',02,0})
aAdd(aStru,{"TRB_GRAUPA",'C',02,0})
aAdd(aStru,{"TRF_DIF21"	,'C',03,0})

aAdd(aStru,{"TRF_CCOTIT",'C',12,0})
aAdd(aStru,{"TRB_CCOTIT",'C',12,0})
aAdd(aStru,{"TRF_DIF22"	,'C',03,0})

aAdd(aStru,{"TRF_DATINC",'C',08,0})
aAdd(aStru,{"TRB_DATINC",'C',08,0})
aAdd(aStru,{"TRF_DIF23"	,'C',03,0})

aAdd(aStru,{"TRF_DATREA",'C',08,0})
aAdd(aStru,{"TRB_DATREA",'C',08,0})
aAdd(aStru,{"TRF_DIF24"	,'C',03,0})

aAdd(aStru,{"TRF_DATBLO",'C',08,0})
aAdd(aStru,{"TRB_DATBLO",'C',08,0})
aAdd(aStru,{"TRF_DIF25"	,'C',03,0})

aAdd(aStru,{"TRF_MOTBLO",'C',02,0})
aAdd(aStru,{"TRB_MOTBLO",'C',02,0})
aAdd(aStru,{"TRF_DIF26"	,'C',03,0})

aAdd(aStru,{"TRF_NUMPLA",'C',09,0})
aAdd(aStru,{"TRB_NUMPLA",'C',09,0})
aAdd(aStru,{"TRF_DIF27"	,'C',03,0})

aAdd(aStru,{"TRF_NPLPOR",'C',09,0})
aAdd(aStru,{"TRB_NPLPOR",'C',09,0})
aAdd(aStru,{"TRF_DIF28"	,'C',03,0})

aAdd(aStru,{"TRF_CODPLA",'C',20,0})
aAdd(aStru,{"TRB_CODPLA",'C',20,0})
aAdd(aStru,{"TRF_DIF29"	,'C',03,0})

aAdd(aStru,{"TRF_COBPAR",'C',01,0})
aAdd(aStru,{"TRB_COBPAR",'C',01,0})
aAdd(aStru,{"TRF_DIF30"	,'C',03,0})

aAdd(aStru,{"TRF_ITEEXC",'C',01,0})
aAdd(aStru,{"TRB_ITEEXC",'C',01,0})
aAdd(aStru,{"TRF_DIF31"	,'C',03,0})


aAdd(aStru,{"TRF_CNPJ"  ,'C',14,0})
aAdd(aStru,{"TRB_CNPJ"  ,'C',14,0})
aAdd(aStru,{"TRF_DIF32"	,'C',03,0})

aAdd(aStru,{"TRF_CEICON",'C',12,0})
aAdd(aStru,{"TRB_CEICON",'C',12,0})
aAdd(aStru,{"TRF_DIF33"	,'C',03,0})

//--< Cria็ใo do objeto FWTemporaryTable >---
cArqTmp := StrTran(cArqTab,"."+cExtTab,"")
oTempTRB := FWTemporaryTable():New( cArqTmp )
oTempTRB:SetFields( aStru )
oTempTRB:AddIndex( "INDTRB",{ cIndCCO } )
	
if( select( cArqTmp ) > 0 )
	cArqTmp->( dbCloseArea() )
endIf
	
oTempTRB:Create()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLINCTRAB บAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui dados do beneficiario do CNX e PLS no temporario    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLSINCTRAB(aBen,cArqTab,cExtTab,lAtuCNS,aGraPar,lMatAnt,lDigito,cCodTit,lAtuReg,cArqLog)
Local aUsr := {} //Dados do usuario no PLS
Local j    := 0

SIBCNX->(RecLock("SIBCNX",.T.))

/* DADOS DO XML */

/* Atributos */
SIBCNX->TRF_CODCCO := GetValor("cco",aBen)
SIBCNX->TRF_SITUAC := GetValor("situacao",aBen)

/* Identificacao */
SIBCNX->TRF_CPFUSR := GetValor("cpf",aBen)
SIBCNX->TRF_DENAVI := GetValor("dn",aBen)
SIBCNX->TRF_PISPAS := GetValor("pisPasep",aBen)
SIBCNX->TRF_NRCRNA := GetValor("cns",aBen)
SIBCNX->TRF_NOMUSR := GetValor("nome",aBen)
SIBCNX->TRF_SEXO   := GetValor("sexo",aBen)
SIBCNX->TRF_DATNAS := GetValor("dataNascimento",aBen,'D')
SIBCNX->TRF_MAE    := GetValor("nomeMae",aBen)

/* Endereco */
SIBCNX->TRF_ENDERE := GetValor("logradouro",aBen)
SIBCNX->TRF_NR_END := GetValor("numero",aBen)
SIBCNX->TRF_COMEND := GetValor("complemento",aBen)
SIBCNX->TRF_BAIRRO := GetValor("bairro",aBen)
SIBCNX->TRF_CODMUN := GetValor("codigoMunicipio",aBen)
SIBCNX->TRF_CDMUNR := GetValor("codigoMunicipioResidencia",aBen)
SIBCNX->TRF_CEPUSR := GetValor("cep",aBen)
SIBCNX->TRF_TIPEND := GetValor("tipoEndereco",aBen)
SIBCNX->TRF_RESEXT := GetValor("resideExterior",aBen)

/* Vinculo */
SIBCNX->TRF_MATRIC := GetValor("codigoBeneficiario",aBen)
SIBCNX->TRF_GRAUPA := GetValor("relacaoDependencia",aBen)
SIBCNX->TRF_CCOTIT := GetValor("ccoBeneficiarioTitular",aBen)
SIBCNX->TRF_DATINC := GetValor("dataContratacao",aBen,'D')
SIBCNX->TRF_DATREA := GetValor("dataReativacao",aBen,'D')
SIBCNX->TRF_DATBLO := GetValor("dataCancelamento",aBen,'D')
SIBCNX->TRF_MOTBLO := GetValor("motivoCancelamento",aBen)
SIBCNX->TRF_NUMPLA := GetValor("numeroPlanoANS",aBen)
SIBCNX->TRF_NPLPOR := GetValor("numeroPlanoPortabilidade",aBen)
SIBCNX->TRF_CODPLA := GetValor("numeroPlanoOperadora",aBen)
SIBCNX->TRF_COBPAR := GetValor("coberturaParcialTemporaria",aBen)
SIBCNX->TRF_ITEEXC := GetValor("itensExcluidosCobertura",aBen)
SIBCNX->TRF_CNPJ   := GetValor("cnpjEmpresaContratante",aBen)
SIBCNX->TRF_CEICON := GetValor("ceiEmpresaContratante",aBen)

If lAtuReg
	IncProc("CCO / Usuแrio: " + AllTrim(SIBCNX->TRF_CODCCO) + " / " + AllTrim(SIBCNX->TRF_NOMUSR))
EndIf

/* DADOS DO PLS */
If lAtuCNS .And. !Empty(SIBCNX->TRF_NRCRNA)//Atualiza CNS da vida com o CNS do CNX
	PLCNXTOCNS(SIBCNX->TRF_CODCCO,SIBCNX->TRF_NRCRNA,cArqLog)
EndIf

aUsr := PLBENPLS(,,SIBCNX->TRF_CODCCO,aGraPar,lMatAnt,lDigito,cCodTit)

/* Atributos */
SIBCNX->TRB_CODCCO := GetValor("cco",aUsr)
SIBCNX->TRB_SITUAC := GetValor("situacao",aUsr)

/* Identificacao */
SIBCNX->TRB_CPFUSR := GetValor("cpf",aUsr)
SIBCNX->TRB_DENAVI := GetValor("dn",aUsr)
SIBCNX->TRB_PISPAS := GetValor("pisPasep",aUsr)
SIBCNX->TRB_NRCRNA := GetValor("cns",aUsr)
SIBCNX->TRB_NOMUSR := GetValor("nome",aUsr)
SIBCNX->TRB_SEXO   := GetValor("sexo",aUsr)
SIBCNX->TRB_DATNAS := GetValor("dataNascimento",aUsr,'D')
SIBCNX->TRB_MAE    := GetValor("nomeMae",aUsr)

/* Endereco */
SIBCNX->TRB_ENDERE := GetValor("logradouro",aUsr)
SIBCNX->TRB_NR_END := GetValor("numero",aUsr)
SIBCNX->TRB_COMEND := GetValor("complemento",aUsr)
SIBCNX->TRB_BAIRRO := GetValor("bairro",aUsr)
SIBCNX->TRB_CODMUN := GetValor("codigoMunicipio",aUsr)
SIBCNX->TRB_CDMUNR := GetValor("codigoMunicipioResidencia",aUsr)
SIBCNX->TRB_CEPUSR := GetValor("cep",aUsr)
SIBCNX->TRB_TIPEND := GetValor("tipoEndereco",aUsr)
SIBCNX->TRB_RESEXT := GetValor("resideExterior",aUsr)

/* Vinculo */
SIBCNX->TRB_MATRIC := GetValor("codigoBeneficiario",aUsr)
SIBCNX->TRB_GRAUPA := GetValor("relacaoDependencia",aUsr)
SIBCNX->TRB_CCOTIT := GetValor("ccoBeneficiarioTitular",aUsr)
SIBCNX->TRB_DATINC := GetValor("dataContratacao",aUsr,'D')
SIBCNX->TRB_DATBLO := GetValor("dataCancelamento",aUsr,'D')
SIBCNX->TRB_MOTBLO := GetValor("motivoCancelamento",aUsr)
SIBCNX->TRB_NUMPLA := GetValor("numeroPlanoANS",aUsr)
SIBCNX->TRB_NPLPOR := GetValor("numeroPlanoPortabilidade",aUsr)
SIBCNX->TRB_CODPLA := GetValor("numeroPlanoOperadora",aUsr)
SIBCNX->TRB_COBPAR := GetValor("coberturaParcialTemporaria",aUsr)
SIBCNX->TRB_ITEEXC := GetValor("itensExcluidosCobertura",aUsr)
SIBCNX->TRB_CNPJ   := GetValor("cnpjEmpresaContratante",aUsr)
SIBCNX->TRB_CEICON := GetValor("ceiEmpresaContratante",aUsr)

SIBCNX->(MsUnLock())

SIBCNX->(RecLock("SIBCNX",.F.))
If !Empty(SIBCNX->TRF_DATREA)

	nPos := aScan(aUsr, {|x| Upper(x[1]) == Upper("dataReativacao")})
    If npos > 0
       For j:=1 to Len(aUsr[npos,3])
           If aUsr[npos,3,j] = SIBCNX->TRF_DATREA
    	   		SIBCNX->TRB_DATREA := aUsr[npos,3,j]
    	   		Exit
    	   Else
				SIBCNX->TRB_DATREA := aUsr[npos,3,j]
           Endif
       Next j
    Endif
Else
	SIBCNX->TRB_DATREA := GetValor("dataReativacao",aUsr,'D')
Endif
SIBCNX->(MsUnLock())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GetValor บAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o valor de uma matriz pelo nome do campo           บฑฑ
ฑฑบ          ณ aAdd(aMatriz,"num",1); GetValor("num",aMatriz) == 1        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetValor(cCampo,aDados,cTipo)
Local cValor  := ""
Local nPos    := 0
Default cTipo := ""

nPos := aScan(aDados, {|x| Upper(x[1]) == Upper(cCampo)})

If nPos > 0
	cValor := aDados[nPos,2]
EndIf

Do Case
	Case cTipo == 'D'
		cValor := StrTran(cValor,"-","")
EndCase

Return cValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLBENPLS บAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os dados do usuario no PLS para conferencia do SIB  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLBENPLS(cMatric,cOldMat,cCodCCO,aGraPar,lMatAnt,lDigito,cCodTit)
Local aRetUsr			:= {} //Registro do usuario no PLS
Local aRetBlq			:= {} //Historico de bloqueio/desbloqueio do usuario
Local cSqlUsr			:= "" //Query para retornar o registro do usuario
Local cDtBlq  			:= "" //Auxiliar para data de bloqueio/desbloqueio
Local cMtBlq			:= "" //Auxiliar para motivo de bloqueio/desbloqueio
Local nPos				:= 0 //Contador para FOR...NEXT
Local aRetPla 			:= {"","",""}
Local lCodPla 			:= .T.
Local lTemDtReat		:= .F.
Local cDataReaT 		:= ""
Local cTipEnd			:= ""

cSqlUsr := "SELECT BA1.BA1_CODCCO, BA1.BA1_LOCSIB, BA1.BA1_EXCANS, BA1.BA1_INCANS, BA1.BA1_CPFUSR, BA1.BA1_CPFMAE, BTS.BTS_DENAVI, BTS.BTS_PISPAS, BTS.BTS_NRCRNA, BTS.BTS_TIPEND, "
cSqlUsr += "BA1.BA1_NOMUSR, BA1.BA1_SEXO, BA1.BA1_DATNAS, BA1.BA1_MAE, BA1.BA1_ENDERE, BA1.BA1_NR_END, BA1.BA1_COMEND, BA1.BA1_BAIRRO, BA1.BA1_CODMUN, BA1.BA1_CEPUSR, "
cSqlUsr += "BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_MATANT, BA1.BA1_GRAUPA, BA1.BA1_DATINC, BA1.BA1_PLPOR, BA3.BA3_PLPOR, "
cSqlUsr += "BA1.BA1_CODPLA, BA1.BA1_VERSAO, BA3.BA3_CODPLA, BA3.BA3_VERSAO, '0' BA1_ITEEXC, ' ' BA1_SITTRA, BA3.BA3_TIPOUS, BA3.BA3_CODCLI, BA3.BA3_LOJA, BA3.BA3_COBNIV, "
cSqlUsr += "BA1.BA1_DATBLO, BA1.BA1_CPFPRE, BA1.BA1_MATUSB, BA1.BA1_TIPUSU, BA1.BA1_OPEORI, BA1.R_E_C_N_O_  AS BA1REC, BA3.R_E_C_N_O_ AS BA3REC, BA1.BA1_TIPEND"
cSqlUsr += "FROM " + RetSqlName("BA1") + " BA1, " + RetSqlName("BTS") + " BTS, " + RetSqlName("BA3") + " BA3 "
cSqlUsr += "WHERE BA1.BA1_FILIAL='" +xFilial("BA1")+ "' AND BTS.BTS_FILIAL='" +xFilial("BTS")+ "' AND BA3.BA3_FILIAL='" +xFilial("BA3")+ "' "
cSqlUsr += "AND BA1_MATVID = BTS_MATVID AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
cSqlUsr += "AND BA1.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BA1.BA1_CODCCO='" +cCodCCO+ "' "
cSqlUsr += "ORDER BY BA1.R_E_C_N_O_ DESC"

cSqlUsr := ChangeQuery(cSqlUsr)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlUsr),"TUSR",.F.,.T.)

If !TUSR->(Eof())

	If Len(aGraPar) == 0
		A783Ini(aGraPar)//Inicializo a matriz aGraPar com os grau de parentesco cadastrado
	EndIf
	
	cTipEnd := TUSR->BTS_TIPEND
	If Empty(cTipEnd)
		cTipEnd := TUSR->BA1_TIPEND
	EndIf

	/* Atributos */
	aAdd(aRetUsr,{"cco",TUSR->BA1_CODCCO})
	aAdd(aRetUsr,{"situacao",DecLocSib(TUSR->BA1_LOCSIB)})

	/* Identificacao */
	If !Empty(AllTrim(TUSR->BA1_CPFUSR))
		aAdd(aRetUsr,{"cpf",TUSR->BA1_CPFUSR})
	Else
		If Calc_Idade( dDataBase,stod(TUSR->BA1_DATNAS) ) < 18 .And. TUSR->BA1_TIPUSU <> cCodTit
			aAdd(aRetUsr,{"cpf",""})
		Else
			If !Empty(TUSR->BA1_CPFMAE)
				aAdd(aRetUsr,{"cpf",TUSR->BA1_CPFMAE})
			Else
				If !Empty(TUSR->BA1_CPFPRE)
					aAdd(aRetUsr,{"cpf",TUSR->BA1_CPFPRE})
				Else
					aAdd(aRetUsr,{"cpf",""})
				EndIf
			EndIf
		EndIf
	EndIf
	aAdd(aRetUsr,{"dn",TUSR->BTS_DENAVI})
	aAdd(aRetUsr,{"pisPasep",AllTrim(TUSR->BTS_PISPAS)})
	aAdd(aRetUsr,{"cns",TUSR->BTS_NRCRNA})
	aAdd(aRetUsr,{"nome",AllTrim(SubStr(PLSXMLTACE(TUSR->BA1_NOMUSR)+Space(70),1,70))})
	aAdd(aRetUsr,{"sexo",Iif(TUSR->BA1_SEXO == '1','1','3')})
	aAdd(aRetUsr,{"dataNascimento",TUSR->BA1_DATNAS})
	aAdd(aRetUsr,{"nomeMae",AllTrim(SubStr(PLSXMLTACE(TUSR->BA1_MAE)+Space(70),1,70))})

	/* Endereco */
	aAdd(aRetUsr,{"logradouro",AllTrim(SubStr(TUSR->BA1_ENDERE + Space(50),1,50))})
	aAdd(aRetUsr,{"numero",AllTrim(SubStr(TUSR->BA1_NR_END + Space(05),1,05))})
	aAdd(aRetUsr,{"complemento",AllTrim(SubStr(TUSR->BA1_COMEND + Space(15),1,15))})
	aAdd(aRetUsr,{"bairro",AllTrim(SubStr(TUSR->BA1_BAIRRO + Space(30),1,30))})
	aAdd(aRetUsr,{"codigoMunicipio",A783TamCmp(6,AllTrim(TUSR->BA1_CODMUN))})
	aAdd(aRetUsr,{"codigoMunicipioResidencia",""})
	aAdd(aRetUsr,{"cep",AcerCEP(TUSR->BA1_CEPUSR)})
	aAdd(aRetUsr,{"tipoEndereco",cTipEnd})
	aAdd(aRetUsr,{"resideExterior","0"})

	/* vinculo */
	If lMatAnt // Enviar matricula antiga
		If Empty(TUSR->BA1_MATANT) .And. !Empty(TUSR->BA1_MATUSB)
			aAdd(aRetUsr,{"codigoBeneficiario",TUSR->BA1_MATUSB})
		Else
			If !Empty(TUSR->BA1_MATANT)
				aAdd(aRetUsr,{"codigoBeneficiario",TUSR->BA1_MATANT})
			Else
				If !lDigito // Enviar matricula sem o digito
					aAdd(aRetUsr,{"codigoBeneficiario",AllTrim(TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))})
				Else
					aAdd(aRetUsr,{"codigoBeneficiario",AllTrim(TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))})
				EndIf
			EndIf
		EndIf
	Else
		If !lDigito // Enviar matricula sem o digito
			aAdd(aRetUsr,{"codigoBeneficiario",AllTrim(TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))})
		Else
			aAdd(aRetUsr,{"codigoBeneficiario",AllTrim(TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))})
		EndIf
	EndIf

	nPos := aScan(aGraPar,{|x| x[1] == TUSR->BA1_GRAUPA})
	If nPos > 0
		aAdd(aRetUsr,{"relacaoDependencia",aGraPar[nPos,2]})
	Else
		aAdd(aRetUsr,{"relacaoDependencia","10"})
	EndIf

	aAdd(aRetUsr,{"ccoBeneficiarioTitular",Iif(TUSR->BA1_TIPUSU <> cCodTit,A783Tit(TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),cCodTit),"")})
	aAdd(aRetUsr,{"dataContratacao",TUSR->BA1_DATINC})

	aRetBlq := PLSIBBLQ(DToS(dDatabase-90),DToS(dDatabase),aRetBlq,TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),TUSR->BA1_TIPREG,TUSR->BA1_LOCSIB,TUSR->BA1_EXCANS)
	lTemDtReat	:=.F.
	aDtReativ	:={}
	For nPos := 1 To Len(aRetBlq)
		If Len(aRetBlq[nPos]) > 1
			// E um desbloqueio, encontrou a data de desbloqueio, ultima data de desbloqueio
			If aRetBlq[nPos-1] == "1" .And. aRetBlq[nPos,4] != "00000000" .And. (Empty(cDtBlq) .Or. cDtBlq < aRetBlq[nPos,4])
		   //		aAdd(aRetUsr,{"dataReativacao",aRetBlq[nPos,4]})
				    cDataReaT :=aRetBlq[nPos,4]
		   			lTemDtReat:=.t.
		   			Aadd(aDtReativ,cDataReaT)
			EndIf
		EndIf
	Next

	If lTemDtReat
		aAdd(aRetUsr,{"dataReativacao",cDataReaT,aDtReativ})
	Endif

	cDtBlq := ""
	cMtBlq := ""

	For nPos := 1 To Len(aRetBlq)
		If Len(aRetBlq[nPos]) > 1
			// E do tipo bloqueio, interessa a ANS
			If aRetBlq[nPos-1] = "0"
   				cDtBlq := aRetBlq[nPos,5]
				cMtBlq := aRetBlq[nPos,1]
			EndIf
		EndIf
	Next nPos

	aAdd(aRetUsr,{"dataCancelamento",If(Empty(TUSR->BA1_DATBLO),cDtBlq,TUSR->BA1_DATBLO)})
	aAdd(aRetUsr,{"motivoCancelamento",cMtBlq})

	BA1->(DbGoTo(TUSR->BA1REC))
	BA3->(DbGoTo(TUSR->BA3REC))

	If !BI3->(dbSeek(xFilial("BI3")+(BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))) // Produto no usuario
		If !BI3->(dbSeek(xFilial("BI3")+(BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))) // Produto na familia
			If BA3->BA3_TIPOUS <> "1" // Beneficiario PJ
				BQC->(dbSeek((BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))) // Posicona o BQC
				If !BT6->(dbSeek(xFilial("BT6")+BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB))) // Produto no Sub-contrato
					lCodPla := .F.
				Else
					If !BI3->(dbSeek(xFilial("BI3")+BT6->(BT6_CODINT+BT6_CODPRO+BT6_VERSAO)))
						lCodPla := .F.
					EndIf
				EndIf
			EndIf
		Else
			lCodPla	:=.T.
		EndIf
	Else
		BQC->(dbSeek((BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))))
	EndIf

	If lCodPla
		cSUSEP := If(BI3->BI3_APOSRG == "1",AllTrim(BI3->BI3_SUSEP),"")
		cSCPA  := If(BI3->BI3_APOSRG == "1","",AllTrim(BI3->BI3_SCPA))
		cNatJur := BI3->BI3_NATJCO
		aRetPla:={cSUSEP,cSCPA,cNatJur}
	EndIf
	aAdd(aRetUsr,{"numeroPlanoANS",aRetPla[1]})
	aAdd(aRetUsr,{"numeroPlanoPortabilidade", AllTrim(If( !Empty(TUSR->BA3_PLPOR) .Or. !Empty(TUSR->BA1_PLPOR),If(!Empty(TUSR->BA1_PLPOR),TUSR->BA1_PLPOR,TUSR->BA3_PLPOR),''))})
	aAdd(aRetUsr,{"numeroPlanoOperadora",aRetPla[2]})
	aAdd(aRetUsr,{"coberturaParcialTemporaria",PLSIBCPT(DToC(dDataBase),TUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))})
	aAdd(aRetUsr,{"itensExcluidosCobertura","0"})

	If TUSR->BA3_TIPOUS <> "1" //Beneficiario PJ
		If !Empty(BQC->BQC_CNPJ)
			aAdd(aRetUsr,{"cnpjEmpresaContratante",BQC->BQC_CNPJ})
		Else
			If SA1->(dbSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA)))
				aAdd(aRetUsr,{"cnpjEmpresaContratante",SA1->A1_CGC})
			Else
				aRetCli := PLSRETNCB(TUSR->BA1_CODINT,TUSR->BA1_CODEMP,TUSR->BA1_MATRIC,TUSR->BA1_OPEORI)
				If aRetCli[1]
					If SA1->(msSeek(xFilial("SA1")+TUSR->(BA3_CODCLI+BA3_LOJA)))
						aAdd(aRetUsr,{"cnpjEmpresaContratante",SA1->A1_CGC})
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		aAdd(aRetUsr,{"cnpjEmpresaContratante",""})
	EndIf

	If TUSR->BA3_TIPOUS <> "1" .And. aRetPla[3] $ "3,4" .And. Empty(BQC->BQC_CNPJ)
		If !Empty(BQC->BQC_CEINSS)
			aAdd(aRetUsr,{"ceiEmpresaContratante",AllTrim(BQC->BQC_CEINSS)})
		ElseIf !Empty(SA1->A1_CEINSS)
			aAdd(aRetUsr,{"ceiEmpresaContratante",AllTrim(SA1->A1_CEINSS)})
		EndIf
		PutValor("cnpjEmpresaContratante",aRetUsr,"")
	Else
		aAdd(aRetUsr,{"ceiEmpresaContratante",""})
	EndIf

EndIf

TUSR->(dbCloseArea())

Return aRetUsr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DecLocSibบAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Decode do status do SIB no PLS - BA1_LOCSIB                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DecLocSib(cStatus)

Do Case

	Case cStatus == "0" //"N ENV"
		cStatus := "INATIVO"
	Case cStatus == "1" //"ATV"
		cStatus := "ATIVO"
	Case cStatus == "2" //"EXC"
		cStatus := "INATIVO"
	Case cStatus == "3" //"ENV INC"
		cStatus := "INATIVO"
	Case cStatus == "4" //"ENV ALT"
		cStatus := "ATIVO"
	Case cStatus == "5" //"ENV EXC"
		cStatus := "ATIVO"
	Case cStatus == "6" //"CRI INC"
		cStatus := "INATIVO"
	Case cStatus == "7" //"CRI ALT"
		cStatus := "ATIVO"
	Case cStatus == "8" //"CRI EXC"
		cStatus := "ATIVO"
	Case cStatus == "9" //"ENV MC"
		cStatus := "ATIVO"
	Case cStatus == "A" //"ENV REA"
		cStatus := "INATIVO"
	Case cStatus == "B" //"CRI MC"
		cStatus := "ATIVO"
	Case cStatus == "C" //"CRI REA"
		cStatus := "INATIVO"
	OtherWise
		cStatus := "Outro"

EndCase

Return cStatus

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA783TamCmpบAutor  ณTOTVS S/A           บ Data ณ  27/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o tamanho da string retornada para o tamanho que de-บฑฑ
ฑฑบ          ณ ve ser enviado no arquivo                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783TamCmp(nTam,cVal,lZero)
Local cRet := ""
Default lZero = .F.

If Len(cVal) > nTam
	cRet := SubStr(cVal,1,nTam)
Else
	cRet := cVal
EndIf

If lZero // vou completar com zeros
	If ValType(cRet) == "N"
		cRet := StrZero(cRet,nTam)
	Else
		cRet := StrZero(Val(cRet),nTam)
	EndIf
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ AcerCep ณ Autor ณ Tulio Cesar            ณ Data ณ 02.10.00 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Exportacao de dados para o Ministerio da Saude.            ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AcerCep(cCep)
cRet := StrTran(cCep,"-","")
cRet := StrTran(cCep,".","")
cCep := AllTrim(Str(Val(cRet)))
nLen := Len(cCep)

If nLen < 8
	nRes := 8-nLen
	cRes := Replicate("0",nRes)
	cRet := cCep+cRes
	cCep := cRet
EndIf

Return(cCep)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA783Tit   บAutor  ณTOTVS S/A           บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a matricula antiga do titular da familia se existir บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783Tit(cMatFam,cCodTit)

BA1->(dbSetOrder(2)) // BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
If BA1->(dbSeek(xFilial("BA1")+cMatFam)) // Posiciono na familia

	While cMatFam == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

		If BA1->BA1_TIPUSU == cCodTit // Verifico se e titular de acordo com o parametro MV_PLCDTIT
			Return BA1->BA1_CODCCO
		EndIf

		BA1->(dbSkip())

	EndDo

EndIf

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | A783Ini  บAutor  ณTOTVS S/A           บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Algumas inicializacoes necessarias                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A783Ini(aGraPar)

BQC->(DbSetOrder(1))//Subcontrato
SA1->(DbSetOrder(1))//Clientes
BRP->(DbSetOrder(1))//Grau de parentesco
BRP->(DbSeek(xFilial("BRP")))
While !BRP->(Eof()) .And. BRP->BRP_FILIAL == xFilial("BRP")
	If !Empty(BRP->BRP_CODSIB)
		aAdd(aGraPar,{BRP->BRP_CODIGO,BRP->BRP_CODSIB})
	EndIf
	BRP->(dbSkip())
EndDo

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |PLCNXTOCNSบAutor  ณ TOTVS S/A          บ Data ณ 15/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a vida com a informacao de CNS vinda do CNX       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLCNXTOCNS(cCodCCO,cNumCNS,cArqLog)

BA1->(dbSetOrder(18))

If BA1->(dbSeek(xFilial("BA1")+cCodCCO))

	BTS->(dbSetOrder(1))

	If BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID)) .And. Empty(BTS->BTS_NRCRNA)
		BTS->(RecLock("BTS",.F.))
		BTS->BTS_NRCRNA := cNumCNS
		BTS->(msUnLock())
		PlsLogFil(DtTime() + " Atualizada a vida " + BA1->BA1_MATVID + " com o numero do CNS do arquivo CNX.",cArqLog)
	EndIf

EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |PLCNXTOCSVบ Autor ณTOTVS S/A           บ Data ณ  04/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para exportar os registros da tabela tempora-บฑฑ
ฑฑบ          ณ ria para arquivo CSV                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLCNXTOCSV(cArqLog,cArqTab,cExtTab)
Local nFileCsv := 0 //Handle do arquivo
Local cFileCsv := "SIBCNX.CSV" //Nome do arquivo
Local nForStru := 0 //Contador para FOR...NEXT
Local aStruCNX := {} //Estrutura do arquivo temporario
Local cLinCSV  := "" //Conteudo do registro/linha do usuario a ser gravado no arquivo
Local lTitulo  := .T. //Testa se ja imprimiu a primeira linha/titulo do arquivo csv
Local lTemDif  := .F. //Indicador de diferenca entro o registro do arquivo e do PLS

if( select( cArqTmp ) == 0 )
	MsgInfo(STR0013 + cArqTab + STR0014,STR0010) //"Nใo foi possํvel encontrar o arquivo " "O gera็ใo do arquivo CSV serแ interrompida.","Encerramento"
	PlsLogFil("Nใo foi possํvel encontrar o arquivo " + cArqTab,cArqLog)
	Return Nil
endIf

aStruCNX := SIBCNX->(dbStruct())
If lLinux
	nFileCsv := FCreate(GetSrvProfString("RootPath","")+IIF(IsSrvUnix(),"/","\")+cDirPrcSib+IIF(IsSrvUnix(),"/","\")+IIF(IsSrvUnix(),Lower(cFileCsv),cFileCsv),0,,.F.)
	If nFileCsv < 0
		MsgInfo(STR0016,STR0010) //"Nใo foi possํvel gravar o arquivo de saํda do relat๓rio","Encerramento"
		Return Nil
	EndIf
Else
	nFileCsv := FCreate(cFileCsv)
	If nFileCsv < 0
		MsgInfo(STR0016,STR0010) //"Nใo foi possํvel gravar o arquivo de saํda do relat๓rio","Encerramento"
		Return Nil
	EndIf
EndIf
SIBCNX->(dbGoTop())

While !SIBCNX->(Eof())

	cLinCSV := ""
	lTemDif := .F.

	If lTitulo

		For nForStru := 1 TO Len(aStruCNX)
			cLinCSV += RetTitulo(SIBCNX->(aStruCNX[nForStru,1])) + Iif(SubStr(aStruCNX[nForStru,1],1,3) == "TRB"," PLS;"," CNX;")
		Next nForStru

		FWrite(nFileCsv,cLinCSV+"Diferenca?"+CRLF)
		cLinCSV := ""
		lTitulo := .F.

	EndIf

	For nForStru := 1 To Len(aStruCNX)-1

		If Substr(aStruCNX[nForStru,1],1,3)=="TRF"  .and. Substr(aStruCNX[nForStru,1],1,7)<>"TRF_DIF" .and. aStruCNX[nForStru,1]<>"TRF_SITTRA" // .and.  aStruCNX[nForStru,1]<>"TRF_GRAUPA"

			If aStruCNX[nForStru,1]<>"TRF_GRAUPA"
				If !(Alltrim(&("SIBCNX->" + (aStruCNX[nForStru,1]))) == Alltrim(&("SIBCNX->" + (aStruCNX[nForStru+1,1]))))
					lTemDif := .T. //Encontrada diferenca entre o registro do arquivo e o registro do PLS
					cCampoVer:=Substr(aStruCNX[nForStru+2,1],5,6)
					SIBCNX->(RecLock("SIBCNX",.F.))
					FIELDPUT(FieldPos(aStruCNX[nForStru+2,1]), "SIM")              // Estabelece valor do campo
					SIBCNX->(MsUnLock())
				Else
					SIBCNX->(RecLock("SIBCNX",.F.))
					FIELDPUT(FieldPos(aStruCNX[nForStru+2,1]), "NAO")              // Estabelece valor do campo
					SIBCNX->(MsUnLock())
				EndIf
			Else

				If Val(Alltrim(&("SIBCNX->" + (aStruCNX[nForStru,1])))) != Val(Alltrim(&("SIBCNX->" + (aStruCNX[nForStru+1,1]))))
					lTemDif := .T. //Encontrada diferenca entre o registro do arquivo e o registro do PLS
					cCampoVer:=Substr(aStruCNX[nForStru+2,1],5,6)
					SIBCNX->(RecLock("SIBCNX",.F.))
					FIELDPUT(FieldPos(aStruCNX[nForStru+2,1]), "SIM")              // Estabelece valor do campo
					SIBCNX->(MsUnLock())
				Else
					SIBCNX->(RecLock("SIBCNX",.F.))
					FIELDPUT(FieldPos(aStruCNX[nForStru+2,1]), "NAO")              // Estabelece valor do campo
					SIBCNX->(MsUnLock())
				EndIf

			Endif
		Endif

		cLinCSV += &("SIBCNX->" + (aStruCNX[nForStru,1])) + ";" + Iif(nForStru == Len(aStruCNX)-1,&("SIBCNX->" + (aStruCNX[nForStru+1,1])),"")

	Next nForStru

	FWrite(nFileCsv,cLinCSV + Iif(lTemDif,";Sim",";Nao") + CRLF)
	SIBCNX->(dbSkip())

EndDo

//SIBCNX->(dbCloseArea())
FClose(nFileCsv)

If MsgNoYes(STR0017 + CRLF + STR0018) //"Gerado o arquivo de confer๊ncia SIBCNX.CSV no servidor." "Deseja informar um local para gravar o arquivo ?"
	cDestino := cGetFile("","Selecione um diret๓rio",0,"*.*",.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.,.T.)
	If !Empty(cDestino)
		If lLinux
			If !CpyS2T((GetSrvProfString("RootPath","") + cDirPrcSib + "/" + lower(cFileCsv)),cDestino,.F.)
				MsgInfo(STR0019,STR0004)//"Nใo foi possํvel salvar o arquivo no diret๓rio destino.","Aviso"
			EndIf
		Else
			If !CpyS2T(cFileCsv,cDestino,.F.)
				MsgInfo(STR0019,STR0004)//"Nใo foi possํvel salvar o arquivo no diret๓rio destino.","Aviso"
			EndIf
		Endif
	EndIf
EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |RetTitulo บ Autor ณTOTVS S/A           บ Data ณ  04/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para retornar o titulo da coluna do arquivo  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetTitulo(cCampo)
Local cTitulo := "" //Titulo a ser retornado
Local aAreas  := GetArea() //Backup da area de trabalho
Local aAlias  := {"BA1_","BA3_","BTS_"} //Prefixo a ser utilizado na busca dos nomes dos campos
Local nFor    := 0 //Contador para FOR...NEXT
Local lSeek   := .T. //Testa se ja encontrou o titulo no SX3

cCampo := SubStr(cCampo,5,Len(cCampo))

Do Case
	Case cCampo == "SITUAC"
		cTitulo := "Situa็ใo"
		lSeek   := .F.
	Case cCampo == "DTATUA"
		cTitulo := "Dt Atualiza็ใo"
		lSeek   := .F.
	Case cCampo == "TIPEND"
		cTitulo := "Tipo End."
		lSeek   := .F.
	Case cCampo == "NUMPLA"
		cTitulo := "N. Pla. ANS"
		lSeek   := .F.
	Case cCampo == "CCOTIT"
		cTitulo := "Cod CCO Tit"
		lSeek   := .F.
	Case cCampo == "ITEEXC"
		cTitulo := "Itens Exc. Cob"
		lSeek   := .F.
	Case cCampo == "COBPAR"
		cTitulo := "Cob Parc Tmp"
		lSeek   := .F.
	Case cCampo == "CDMUNR"
		cTitulo := "Cod Mun Res"
		lSeek   := .F.
	Case cCampo == "RESEXT"
		cTitulo := "Resid Ext"
		lSeek   := .F.
	Case cCampo == "DATREA"
		cTitulo := "Dt Reativa็ใo"
		lSeek   := .F.
	Case cCampo == "NPLPOR"
		cTitulo := "Num. Pla. Port."
		lSeek   := .F.
	Case cCampo == "CEICON"
		cTitulo := "CEI Contrat"
		lSeek   := .F.
	Case cCampo == "SITTRA"
		cTitulo := "Sit. transf."
		lSeek   := .F.
EndCase

If lSeek

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	For nFor := 1 TO Len(aAlias)
		If SX3->(dbSeek(aAlias[nFor]+cCampo))
			cTitulo := SX3->X3_TITULO
			Exit
		EndIf
	Next nFor

EndIf

RestArea(aAreas)

Return IIf(!Empty(cTitulo),cTitulo,cCampo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR992DirectบAutor  ณ TOTVS S/A          บ Data ณ  08/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para a consulta padrao que seleciona o CNX    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function R992Direct(cCPO)
Local cRet := ""

If Empty(AllTrim(GetNewPar("MV_SIBDIRP","")))
	cRet := cGetFile(,"Selecione o diretorio",,"",.T.,GETF_NETWORKDRIVE+GETF_RETDIRECTORY+128)
Else
	cRet :=cGetFile('*.CNX*', 'Selecione o Arquivo',,"C:\",.T.)
EndIf

&(cCPO)	:= cRet
Iif( 1 < 0,R992Direct("XX"),"")//Retira o Warning de compilacao

Return (!Empty(cRet))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PutValor บAutor  ณ TOTVS S/A          บ Data ณ  06/10/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atribuiu um valor a posicao da matriz          			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PutValor(cCampo,aDados,cValor)
Local nPos		:= 0
Default cCampo	:= ""
Default aDados	:= ""
Default cValor	:= ""

nPos := aScan(aDados, {|x| Upper(x[1]) == Upper(cCampo)})

If nPos > 0
	aDados[nPos,2] := cValor
EndIf

Return