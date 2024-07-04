#Include "Totvs.Ch"
#Include "EICAT410.Ch"
/*
Programa   : EICAT410
Objetivo   : Faz a integração dos atibutos do catalogo de produtos
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Function EICAT410()
Local lRet
Local cMsgRet := ""
If MsgYesNo(STR0002,STR0001) //"Esta opção ira realizar o download e integração para o sistema do cadastro de atributos do Portal Unico. Deseja prosseguir?"###"Atenção"
	
	lRet := ProcArquiv(@cMsgRet)
	If lRet
		MsgInfo(STR0003,STR0001) //"Integração de atributos realizada com sucesso!"###"Atenção"
	Else
		EasyHelp(STR0004+CHR(13)+CHR(10)+cMsgRet,STR0001) //"Falha na integração de atributos."###"Atenção"
	EndIf
EndIf

Return

/*
Programa   : ProcArquiv
Objetivo   : Faz a integração dos atibutos do catalogo de produtos
Parâmetros : cMsgRet - Mensagem de retorno no caso de ocorrer algum erro
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function ProcArquiv(cMsgRet)
Local lRet := .T.
Local aArquivos := {}
Local cDirComex   := "\comex"
Local cCaminho := cDirComex+"\atributos\"

Local oProgress := EasyProgress():New(.F.)

//Verifica estrutura de pastas
lRet := ExisteComex(cDirComex,cCaminho,@cMsgRet)

//JAVASCRIPT - Download, ordenação e quebra do arquivo json
If lRet
	LimpaPasta(cCaminho)
	MsAguarde({|| lRet := TrataArqs(@cMsgRet,cDirComex,cCaminho)},STR0005,STR0006) //"Integração de Atributos"###"Aguarde...")
	If lRet
		aArquivos := getJsonFiles(cDirComex,cCaminho)
		If !Empty(aArquivos)
			oProgress:SetProcess({|| lRet := MontaThread(aArquivos,oProgress,@cMsgRet), STR0007 }) //'Iniciando integração...'
			oProgress:Init()
			LimpaPasta(cCaminho)
		Else
			cMsgRet := STR0008 //"Não foi encontrado nenhum arquivo para integração."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
Programa   : MontaThread
Objetivo   : Thread Pai, onde será feito o controle das Threads filhas que serão responsáveis pela integração
Parâmetros : aArquivos 	- Array com os arquivos Json que serão integrados
				 oProgress 	- Objeto de barra de progresso
				 cMsgRet		- Mensagem de retorno no caso de ocorrer algum erro
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function MontaThread(aArquivos,oProgress,cMsgRet)
Local nTotThread:= 4 //Foi definida a utilização de 4 Threads
Local nMaxThread //Maximo de arquivos a serem processados por cada Thread
Local nTot
Local nThread
Local aProc
Local nI
Local nTotNcm := 0
Local nCtrJob := 0
Local nRetThread
Local lRet := .T.
Local lRetFilha
Local nThreadFim := 0
Local cError
Local aChaveBloq
Local nFilha := 0
Local cNcmIni := ""
Local cAtribIni:= ""
Local cNcmFim := ""
Local cAtribFim := ""

Begin Sequence

nMaxThread := int(Len(aArquivos)/nTotThread)
nTot := 1
nThread := 0
aProc := {}
Do While nTot <= Len(aArquivos)
aAdd(aProc,aArquivos[nTot])
	if nTot == Len(aArquivos) .OR. (nMaxThread == Len(aProc) .And. nThread+1 < nTotThread)
		nThread++
		StartJob("AT410JOBS",GetEnvServer(),.F.,"AT410JOBS"+AllTrim(Str(ThreadId()))+"_"+AllTrim(Str(nThread)),aProc,oProgress,cEmpAnt,cFilAnt,"AT410JOBS"+AllTrim(Str(ThreadId())),nThread)
		aProc := {}
	ENdif
	nTot++
EndDo

//Captura a quantidade total de registros a serem processados
For nI:= 1 To nThread
	nRetThread := 0
	While !killApp()
		lRetFilha := IpcWaitEx("AT410JOBS"+AllTrim(Str(ThreadId()))+"_"+AllTrim(Str(nI)),5000,@nRetThread)
		If lRetFilha
				Exit
		Endif
	End
	If !Empty(nRetThread)
		nTotNcm += nRetThread
	EndIf
Next
oProgress:SetRegua(nTotNcm)
aChaveBloq := Array(nThread,0)
nTot := 0
//Recebe uma reposta a cada registro processado para incrementar o Progress
While !killapp() .And. (nTotNcm != nCtrJob .Or. nTot != Len(aArquivos))
	lRetFilha := IpcWaitEx("AT410JOBS"+AllTrim(Str(ThreadId())),100,@nFilha,@cNcmIni,@cAtribIni,@cNcmFim,@cAtribFim,@cError)
	If lRetFilha
		If Empty(cError)
			If Empty(nFilha)
				nCtrJob++
				oProgress:IncRegua()
			Else
				aAdd(aChaveBloq[nFilha],{cNcmIni,cAtribIni,cNcmFim,cAtribFim})
				nTot++
			EndIf
		Else
			cMsgRet := cError
			lRet := .F.
			Break
		EndIf
	EndIf
End

//Recebe uma resposta de fim do processamento das Threads filhas
For nI:= 1 To nThread
	While !killApp()
		lRetFilha := IpcWaitEx("AT410JOBS"+AllTrim(Str(ThreadId()))+"_"+AllTrim(Str(nI)),5000)
		If lRetFilha
			nThreadFim++
			Exit
		Endif
	End
Next

//Efetua o bloqueio das NCMs que bão foram atualizadas pelo arquivo
lRet := AtuBloqNcm(aChaveBloq,@cMsgRet)

//Grava data e hora de atualização
If lRet
	PutMv("MV_EIC0071", FWTimeStamp(2))
EndIf

End Sequence

Return lRet

/*
Programa   : AT410JOBS
Objetivo   : Threads filhas respinsáveis por processar os arquivos json e gravar no protheus
Parâmetros : cID 			- Código que identifica a Thread em execução
				 aArquivos	- Array que contém os arquivos a serem processados pela Thread
				 oProgress 	- Objeto de barra de progresso
				 cEmp			- Código da empresa para abertura do ambiente
				 cFil			- Código da filial para abertura do ambiente
				 cIdPai		- Código que identifica a Thread Pai
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Function AT410JOBS(cID,aArquivos,oProgress,cEmp,cFil,cIdPai,nFilha)
Local lRet := .T.
Local nI
Local nY
Local nOrg
Local nDom
Local nObj
Local oAtributo
Local cNcm
Local aNcmAtrib
Local oNcmDados
Local lInsere
Local cForma
Local xOrgao
Local xDominio
Local xObjetivos
Local cCodObj 	:= ''
Local cOrgao	:= ''
Local oDominio
Local aObjJson := Array(Len(aArquivos))
Local xArqJson
Local oJson
Local nTotNCM := 0
Local nK
Local cAtributo
Local lBloqNCM := .F.
Local cNcmIni
Local cAtribIni
local cFiles := ""

//Tratamento de erro para as Threads filha
SysErrorBlock({|oErr| JobIncRegua(cIDPai,,,,,,oErr:description) })

For nI := 1 To Len(aArquivos)
	cFiles += aArquivos[nI] + " - "
	aObjJson[nI] := EasyMemoRead(aArquivos[nI])
	oJson := JsonObject():New()
	xArqJson := oJson:FromJson(aObjJson[nI])
	If ValType(xArqJson) == "U"
		aObjJson[nI] := oJson:GetJsonObject("listaNcm")
		nTotNCM += Len(aObjJson[nI])
		FreeObj(oJson)
	Else
		UserException(STR0009 + " ("+aArquivos[nI]+"). "+STR0010 + xArqJson) //"Houve uma falha ao ler o arquivo JSON###"Erro: "
	EndIf
Next

if(ExistFunc("FWMonitorMsg"),FWMonitorMsg( "Processando os arquivos: " + substr( alltrim(cFiles), 1, len(alltrim(cFiles)) - 1 ) ) ,nil)

RpcSetType(3)
RpcSetEnv(cEmp,cFil)

//Informa a quantidade de NCM pra Thread pai iniciar o Progress
JobInicio(cID,nTotNCM)

EKG->(dbSetOrder(1))//EKG_FILIAL, EKG_NCM, EKG_COD_I
EKH->(dbSetOrder(1))//EKH_FILIAL, EKH_NCM, EKH_COD_I, EKH_CODDOM
For nK := 1 To Len(aObjJson)
	aJson := aObjJson[nK]
	For nI := 1 To Len(aJson)

		oAtributo := aJson[nI]
		cNcm := AvKey(StrTran(oAtributo:getJsonText('codigoNcm'),'.',''),"EKG_NCM")
		
		EKG->(dbSeek(xFilial("EKG") + cNcm))

		aNcmAtrib := oAtributo:getJsonObject('listaAtributos')
		IIF(Empty(cNcmIni),cNcmIni := cNcm,)

		nY := 1
		While nY <= Len(aNcmAtrib)
			oNcmDados 	:= aNcmAtrib[nY]
			cAtributo := AvKey(oNcmDados:GetJsonText('codigo'),"EKG_COD_I")
			IIF(Empty(cAtribIni),cAtribIni := cAtributo,)

			If EKG->(EOF()) .Or. xFilial("EKG")+Alltrim(cNCM)+AllTrim(cAtributo) < EKG->EKG_FILIAL+Alltrim(EKG->EKG_NCM)+AllTrim(EKG->EKG_COD_I)
				lInsere := .T.
				lBloqNCM:= .F.
				nY++
			ElseIf xFilial("EKG")+Alltrim(cNCM)+AllTrim(cAtributo) == EKG->EKG_FILIAL+Alltrim(EKG->EKG_NCM)+AllTrim(EKG->EKG_COD_I)
				lInsere := .F.
				lBloqNCM:= .F.
				nY++
			ElseIf xFilial("EKG")+Alltrim(cNCM)+AllTrim(cAtributo) > EKG->EKG_FILIAL+Alltrim(EKG->EKG_NCM)+AllTrim(EKG->EKG_COD_I)
				lInsere	:= .F.
				lBloqNCM := .T.
			EndIf
			
			xOrgao		:= oNcmDados:getJsonObject('orgaos')
			xDominio		:= oNcmDados:getJsonObject('dominio')
			xObjetivos	:= oNcmDados:getJsonObject('objetivos')

			RecLock('EKG',lInsere)
			If !lBloqNCM
				EKG->EKG_FILIAL := xFilial("EKG")
				EKG->EKG_NCM	:= cNcm
				EKG->EKG_COD_I	:= cAtributo
				EKG->EKG_NOME	:= GetJsonCpo(oNcmDados,'nomeApresentacao') //DecodeUTF8(oNcmDados:GetJsonText('nomeApresentacao'))
				//Objetivos
				cCodObj := ''
				For nObj := 1 To Len(xObjetivos)
					cCodObj += GetJsonCpo(xObjetivos[nObj],'codigo')//xObjetivos[nObj]:GetJsonText('codigo')
					If nObj < Len(xObjetivos)
						cCodObj += ';'
					EndIf
				Next
				EKG->EKG_CODOBJ:= cCodObj
				EKG->EKG_ORIENT:= GetJsonCpo(oNcmDados,'orientacaoPreenchimento')//DecodeUTF8(oNcmDados:GetJsonText('orientacaoPreenchimento'))
				cForma := GetJsonCpo(oNcmDados,'formaPreenchimento')//DecodeUTF8(oNcmDados:GetJsonText('formaPreenchimento'))
				EKG->EKG_FORMA	:= cForma
				EKG->EKG_MODALI:= GetModalidade(oNcmDados:GetJsonText('modalidade'))
				EKG->EKG_OBRIGA:= IIF(Lower(oNcmDados:GetJsonText('obrigatorio'))=='true','1','2')
				EKG->EKG_INIVIG:= SToD(StrTran(oNcmDados:GetJsonText('dataInicioVigencia'),'-',''))
				If !Empty(oNcmDados:GetJsonText('dataFimVigencia'))
					EKG->EKG_FIMVIG := SToD(StrTran(oNcmDados:GetJsonText('dataFimVigencia'),'-',''))
				Else
					EKG->EKG_FIMVIG := CToD("  /  /    ")
				EndIf
				//Orgao
				cOrgao := ''
				For nOrg := 1 To Len(xOrgao)
					cOrgao += xOrgao[nOrg]
					If nOrg < Len(xOrgao)
						cOrgao += ';'
					EndIf
				Next
				EKG->EKG_ORGAO := cOrgao
				If Upper(cForma) $ "TEXTO|NÚMERO REAL"
					EKG->EKG_TAMAXI := Val(oNcmDados:GetJsonText('tamanhoMaximo'))
					If Upper(cForma) == "NÚMERO REAL"
						EKG->EKG_DECATR := Val(oNcmDados:GetJsonText('casasDecimais'))
					Else
						EKG->EKG_DECATR := 0
					EndIf
				Else
					EKG->EKG_TAMAXI := 0
					EKG->EKG_DECATR := 0
				EndIf
				EKG->EKG_INFADC := GetJsonCpo(oNcmDados,'informacaoAdicional') //DecodeUTF8(oNcmDados:GetJsonText('informacaoAdicional'))
				EKG->EKG_BRIDAT := GetJsonCpo(oNcmDados,'brid') //DecodeUTF8(oNcmDados:GetJsonText('brid'))
				EKG->EKG_MSBLQL := "2" //Não Bloqueado
				//Dominios
				If ValType(xDominio) != "U"
					AtuBloqAtt(EKG->EKG_NCM,EKG->EKG_COD_I) //Efetua o bloqueio de todos os atributos para liberar apenas os que forem alterados ou inseridos pelo arquivo
					For nDom := 1 To Len(xDominio)
						oDominio := xDominio[nDom]
						lInsere := EKH->(!dbSeek(xFilial("EKH") + EKG->EKG_NCM + EKG->EKG_COD_I + oDominio:GetJsonText('codigo'))) //EKH_FILIAL, EKH_NCM, EKH_COD_I, EKH_CODDOM
						
						RecLock("EKH",lInsere)
						EKH->EKH_FILIAL := xFilial("EKH")
						EKH->EKH_NCM 	:= EKG->EKG_NCM
						EKH->EKH_COD_I	:= EKG->EKG_COD_I
						EKH->EKH_CODDOM:= oDominio:GetJsonText('codigo')
						EKH->EKH_DESCRE:= DecodeUTF8(oDominio:GetJsonText('descricao'))
						EKH->EKH_MSBLQL:= "2" //Liberado
						EKH->(MsUnlock())
					Next
				EndIf
			EndIf
			If lBloqNCM
				EKG->EKG_MSBLQL := "1" //Bloqueado				
			EndIf
			EKG->(MsUnlock())
			EKG->(dbSkip())
		//Next
		End
		JobIncRegua(cIdPai) //Informa Thread pai que o registro foi processado
	Next
	JobIncRegua(cIdPai,nFilha,cNcmIni,cAtribIni,cNcm,cAtributo)
	cNcmIni 	:= ""
	cAtribIni:= ""
Next
RpcClearEnv()
JobFim(cID) //Informa Thread pai que o processo foi finalizado

Return lRet

/*
Programa   : JobInicio, JobIncRegua e JobFim
Objetivo   : Funções que fazem a comunicação com a Thread Pai
Parâmetros : cID		- Código da Thread
				 nRet 	- Informa a quantidade de NCMs a serem processadas para informar a barra de progresso
				 cError	- Informa erro para a Thread Pai
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function JobInicio(cID,nRet)
While !killapp() .And. !IPCGo(cID,nRet)
    Sleep(100)
End
Return .T.

Static Function JobIncRegua(cID,nFilha,cIniFim,cAtribFim,cNcm,cAtributo,cError)
While !killapp() .And. !IPCGo(cID,nFilha,cIniFim,cAtribFim,cNcm,cAtributo,cError)
    Sleep(100)
End
Return .T.

Static Function JobFim(cID)
While !killapp() .And. !IPCGo(cID)
    Sleep(100)
End
Return .T.


/*
Programa   : GetJsonCpo
Objetivo   : Retornar uma Tag do Json
Parâmetros : oObj		- Objeto Json
				 cTag 	- Tag da informação a ser obtida
Retorno    : cInfo - Informação a ser gravada no campo
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function GetJsonCpo(oObj,cTag)
Local cRet
Local cInfo

cInfo := oObj:GetJsonText(cTag)
If Alltrim(cInfo) == 'null' .Or. Empty(cInfo)
	cRet := " "
Else
	cRet := DecodeUTF8(cInfo)
EndIf
Return cRet

/*
Programa   : getJsonFiles
Objetivo   : Verifica na pasta os arquivos json que serão integrados
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cDir 		- Pasta onde deve conter os arquivos json no servidor
Retorno    : aFiles - Retorna os arquivos json encontrados no caminho especificado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function getJsonFiles(cDirComex,cDir)
Local i, aDir, aFiles := {}

aDir := Directory(cDir+"/*.json")
For i := 1 To Len(aDir)
	If aDir[i][1] <> "." .AND. aDir[i][1] <> ".."
		If At(".JSON",upper(aDir[i][1])) > 0
			aAdd(aFiles,cDir+aDir[i][1])
		EndIf
	EndIf
Next i

Return aSort(aFiles)

/*
Programa   : UnzipJson
Objetivo   : Desconpacta um arquivo .Zip
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cCaminho	- Pasta onde deve conter os arquivos json no servidor
				 cMsgRet		- retorna uma mensagem caso ocorra falha ao descompactar o arquivo .Zip
Retorno    : lRet - Retorna se descompactou com sucesso ou não
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function UnzipJson(cDirComex,cCaminho,cMsgRet)
Local lRet := .T.
Local nRetZip

IF File(cCaminho+"atributos.zip")
	nRetZip := FUnZip(cCaminho+"atributos.zip",cCaminho)
	If nRetZip != 0
		cMsgRet := STR0011//"Falha ao descompactar o arquivo."
		lRet := .F.
	EndIf
Else
	cMsgRet := STR0012 + cCaminho + "atributos.zip" //"Não foi encontrado a arquivo de atributos em: "
	lRet := .F.
EndIf

Return lRet

/*
Programa   : TrataArqs
Objetivo   : Baixa arquivo pelo javascript e descompacta o retorno pro protheus processar
Parâmetros : cMsgRet		- retorna uma mensagem caso ocorra falha na criação da pasta quando ela não existir
				 cDirComex 	- Caminho principal no servidor
				 cCaminho	- Pasta onde deve conter os arquivos json no servidor
Retorno    : lRet - Retorna se tudo foi efetuado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function TrataArqs(cMsgRet,cDirComex,cCaminho)
Local lRet := .T.

MsProcTxt(STR0013) //"Iniciando o download do arquivo de atributos... "
lRet :=  BaixaJson(@cMsgRet,cCaminho)
If lRet
	//Extrai os arquivos compactados
	MsProcTxt(STR0014)//"Descompactando arquivos baixados... "
	lRet := UnzipJson(cDirComex,cCaminho,@cMsgRet)
EndIf

Return lRet

/*
Programa   : ExisteComex
Objetivo   : Verifica a estrutuda de pastas necessárias para o correto funcionamento da rotina
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cDir			- Pasta onde deve conter os arquivos json no servidor
				 cMsgRet		- retorna uma mensagem caso ocorra falha na criação da pasta quando ela não existir
Retorno    : lRet - Retorna se a estrutura de pastas esntão corretas
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function ExisteComex(cDirComex,cDir,cMsgRet)
Local lRet := .T.
Begin Sequence
//Verifica se exsite a pasta comex dentro da Protheus_data
If !ExistDir(cDirComex)
	If MakeDir(cDirComex) <> 0
		cMsgRet := STR0015 + cValToChar( FError() ) //"Não foi possível criar os diretórios necessários para a geração do arquivo de integração. Erro: "
		lRet := .F.
		Break
	EndIf
EndIf

If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsgRet := STR0015 + cValToChar( FError() ) //"Não foi possível criar os diretórios necessários para a geração do arquivo de integração. Erro: "
		lRet := .F.
		Break
	EndIf
EndIf
End Sequence
Return lRet

/*
Programa   : GetModalidade
Objetivo   : Recebe a modalidade enviada pelo Json e retorna o código a ser gravado na tabela
Parâmetros : cModalidade - Nome da Modalidade
Retorno    : cRet - Retorna o código da modalidade (1=Importação; 2=Exportação; 3=Ambos)
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function GetModalidade(cModalidade)
Local cRet
cModalidade := DecodeUTF8(cModalidade)
If Upper(cModalidade) == 'EXPORTAÇÃO'
	cRet := '2'
ElseIf Upper(cModalidade) == 'IMPORTAÇÃO'
	cRet := '1'
Else
	cRet := '3'
EndIf
Return cRet

/*
Programa   : EasyMemoRead
Objetivo   : Faz a leitura do arquivo do disco para a memória
Parâmetros : cFile - Arquivo a ser lido
Retorno    : cText - Retorna o conteúdo do arquivo no formato texto
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function EasyMemoRead(cFile)
Local cText := ""
Local nHdl  := FOpen(cFile,64)
 
If nHDL >= 0
    FRead(nHdl,@cText,1024*8192)
    FClose(nHdl)
EndIf
 
Return cText

/*
Programa   : LimpaPasta
Objetivo   : Exclui todos os arquivos da pasta informada
Parâmetros : cCaminho - Caminho que devem ser excluídos os arquivos
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function LimpaPasta(cCaminho)
AEval(Directory(cCaminho+"\*.*"), { |aFile| FErase(cCaminho+"\"+aFile[1]) })
Return

/*
Programa   : AtuBloqNcm
Objetivo   : Realizar um update bloqueando os registros que não foram processados pelo arquivo
Parâmetros : aChaveBloq - Array com a chave de ncm e atributo iniciais e finais de cada arquivo processado
				 cMsgRet - Mensagem de erro caso ocorra
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function AtuBloqNcm(aChaveBloq,cMsgRet)
Local lRet := .T.
Local nI
Local nJ
Local cQuery := ""
Local cQryNcm
Local cQryAtt

//cQuery := " SELECT * "
//cQuery += " FROM " + RetSqlName("EKG") + " "

cQuery := " UPDATE  " + RetSqlName("EKG") + " "
cQuery += " SET EKG_MSBLQL = '1' "
cQuery += " WHERE  EKG_FILIAL = '" + xFilial("EKG") +"' "

For nI := 1 To Len(aChaveBloq)
	For nJ := 1 To Len(aChaveBloq[nI])
		If nI == 1 .And. nJ == 1
			cQuery += " AND (EKG_NCM < '" + aChaveBloq[nI][nJ][1] + "' OR (EKG_NCM = '" + aChaveBloq[nI][nJ][1] + "' AND EKG_COD_I < '" + aChaveBloq[nI][nJ][2] + "') "
			cQryNcm:= " EKG_NCM > '" + aChaveBloq[nI][nJ][3] + "' "
			cQryAtt:= " EKG_NCM = '" + aChaveBloq[nI][nJ][3] + "' AND EKG_COD_I > '" + aChaveBloq[nI][nJ][4] + "' "
		ElseIf nI == Len(aChaveBloq) .And. nJ == Len(aChaveBloq[nI])
			cQuery += " OR ( "+cQryNcm+" AND EKG_NCM < '" + aChaveBloq[nI][nJ][1] + "') OR (( " + cQryAtt + " ) OR (EKG_NCM = '" + aChaveBloq[nI][nJ][1] + "' AND EKG_COD_I < '" + aChaveBloq[nI][nJ][2] + "')) "
			cQuery += " OR EKG_NCM > '" + aChaveBloq[nI][nJ][3] + "' OR (EKG_NCM = '" + aChaveBloq[nI][nJ][3] + "' AND EKG_COD_I > '" + aChaveBloq[nI][nJ][4] + "')) "
		Else
			cQuery += " OR ( "+cQryNcm+" AND EKG_NCM < '" + aChaveBloq[nI][nJ][1] + "') OR (( " + cQryAtt + " ) OR (EKG_NCM = '" + aChaveBloq[nI][nJ][1] + "' AND EKG_COD_I < '" + aChaveBloq[nI][nJ][2] + "')) "
			cQryNcm:= " EKG_NCM > '" + aChaveBloq[nI][nJ][3] + "' "
			cQryAtt:= " EKG_NCM = '" + aChaveBloq[nI][nJ][3] + "' AND EKG_COD_I > '" + aChaveBloq[nI][nJ][4] + "'
		EndIf
	Next
Next
cQuery += " AND EKG_MSBLQL = '2' AND D_E_L_E_T_ = ' ' "

If TcSQLExec(cQuery) < 0
   lRet := .F.
	cMsgRet := "TCSQLError() " + TCSQLError()
EndIf

Return lRet

/*
Programa   : AtuBloqAtt
Objetivo   : Realizar um update bloqueando os registros que não foram processados pelo arquivo
Parâmetros : cNcm - Código do NCM
				 cDominio - Código do Dominio
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function AtuBloqAtt(cNcm,cDominio,cMsgRet)
Local cQuery

cQuery := " UPDATE  " + RetSqlName("EKH") + " "
cQuery += " SET EKH_MSBLQL = '1' "
cQuery += " WHERE  EKH_FILIAL = '" + xFilial("EKH") +"' "
cQuery += " AND EKH_NCM 	= '" + cNcm + "' "
cQuery += " AND EKH_COD_I 	= '" + cDominio + "' "
cQuery += " AND EKH_MSBLQL = '2' AND D_E_L_E_T_ = ' ' "

If TcSQLExec(cQuery) < 0
	UserException("TCSQLError() " + TCSQLError())
EndIf

Return

/*
Programa   : BaixaJson
Objetivo   : Efetuar o acesso ao portal unico, baixar o arquivo json, organizar e efetuar a quebra em arquivos menores. Será gerado um .zip destes arquivos para o Protheus Processar.
Parâmetros : -
Retorno    : -
Autor      : AAF - Alessandro Alves Ferreira
Data/Hora  : 04/05/2020
Obs.       :
*/
Static Function BaixaJson(cMsgRet,cCaminho)
Local oJS
Local h
Local cLib
Local lRet 	      := .T.
Local nRemoteType	:= GetRemoteType( @cLib )
Local cFetch      := iif( nRemoteType <> 1 .and. "HTML" $ cLib , "advplFetch" , "fetch" )
    
	oJS := EasyJS():New()
	oJS:cUrl := 'https://portalunico.siscomex.gov.br/cadatributos/api'
	oJS:setTimeOut(30)
	oJS:AddLib(TEGetJSZip())
	lRet := oJS:Activate(.T.)
	if lRet
		begincontent var cscript
			%Exp:cFetch%('https://portalunico.siscomex.gov.br/cadatributos/api/atributo-ncm/download/json').then(
				(a) => { return a.blob(); }) //dowload do binário do zip
				.then(
				(blob)=> { return JSZip.loadAsync(blob) }) //interpreta o zip
				.then(
				(zip) => { return Object.values(zip.files)[0].async('string') }) //abre o primeiro arquivo como texto
				.then( (text) => { return new Promise((accept,reject)=>{
							try {
							let obj = JSON.parse(text) //parse do texto como JSON

							//Ordena a lista de NCM em ordem crescente, cada lista de atributos em ordem crescente
							//e filtra as ncms que nao possuem atributos 
							obj.listaNcm = obj.listaNcm.filter((a)=>{
								a.listaAtributos.sort((a, b) =>{return a.codigo.localeCompare(b.codigo)});
								a.listaAtributos.forEach((at)=>{ if(at.dominio){at.dominio.sort((a, b) =>{return a.codigo.localeCompare(b.codigo)})} })
								return a.listaAtributos.length > 0;
							}).sort((a, b)=>{return a.codigoNcm.localeCompare(b.codigoNcm)})
							
							let nQtdNcms = 500;
							let nro_arquivos = Math.trunc(obj.listaNcm.length / nQtdNcms) + (obj.listaNcm.length / nQtdNcms == Math.trunc(obj.listaNcm.length / nQtdNcms) ? 0 : 1);

							let partes = Array.from(Array(nro_arquivos).keys());//Math.min(obj.listaNcm.length,100)

							let zip_result = new JSZip();
							partes.forEach((n)=>{
								//let nSize = Math.trunc(obj.listaNcm.length / partes.length)+1; 
								zip_result.file("parte_"+(("00000").substring((n+1).toString().length)+(n+1))+".json",JSON.stringify({ listaNcm : obj.listaNcm.slice(n*nQtdNcms, Math.min((n+1)*nQtdNcms,obj.listaNcm.length)) })); 
							})

							accept(zip_result.generateAsync({type:"base64", compression: "DEFLATE"}));

						} catch (e) {
							reject(e);
						}
					})
				})
			.then((base64zip)=>{ retAdvpl(base64zip) })
			.catch((e) => { retAdvplError(e) })
		endcontent

		h := fcreate(cCaminho + 'atributos.zip')
		oJS:runJSSync(cScript,{|x| fwrite(h,Decode64(x)) },{|e| lRet := .F.,cMsgRet := STR0016 + e}) //"Falha no download do arquivo no portal único: "

		fclose(h)

	endif

Return lRet
