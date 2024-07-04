#INCLUDE "TMKA520A.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFAuthorizบAutor  ณVendas Clientes     บ Data ณ  06/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel pelo processo de execucao e controle de  บฑฑ
ฑฑบ          ณWorkFlow de Autorizacao                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class WFAuthorization From WFInformation
Data wfIsAuthorized		// Depreciado, utilizar a classe WFTemplate atrav้s do m้todo authStatus para saber o status do workflow
Data wfIsWaiting		// Depreciado, utilizar a classe WFTemplate atrav้s do m้todo authStatus para saber o status do workflow

Method New() Constructor
Method prepare(codProtheusUser, emailUser, subject, Body, HtmlFile, cCC, cBCC, authorized)

EndClass


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณNew          บAutor  ณ Vendas Clientes บ Data ณ  06/12/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe WFAuthorization.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class WFAuthorization
Self:wfIsAuthorized		:= .F. 
Self:wfIsWaiting		:= .F.

//Executa o construtor da classe base
Self:Initialize()

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณprepare      บAutor  ณ Vendas Clientes บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por preparar/criar os objetos utilizados บฑฑ
ฑฑบ          ณno envio do Workflow de Autorizacao.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method prepare(codProtheusUser, emailUser, subject, Body, HtmlFile, cCC, cBCC, authorized) Class WFAuthorization
Local cTableHeader 		:= ""
Local cTableItens		:= ""
Local cPasta			:= "aprovador"
Local nFields			:= 0
Local nI				:= 0

Self:codProtheusUser	:= codProtheusUser
Self:emailUser			:= emailUser
Self:subject			:= subject
Self:Body				:= IIf(!Empty(Body),Body,"")
Self:HtmlFile			:= IIf(!Empty(HtmlFile), HtmlFile, "WFW520A.htm")
Self:cCC				:= cCC
Self:cBCC				:= cBCC
Self:wfIsAuthorized		:= IIf(authorized<>NIL, authorized, .F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Utiliza o componente padrao TWFProcess  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Self:oProcess	:= TWFProcess():New(/*cCodProcess*/,/*cDescrProcess*/)
Self:oProcess	:= TWFProcess():New('000001', STR0001)			//'Workflow de Autorizacao'
Self:oProcess:NewTask(STR0002, "\workflow\"+Self:HtmlFile)		//"Preparando WorkFlow de Autorizacao"

Self:oProcess:cTo		:= cPasta 
Self:oProcess:cSubject	:= Self:subject
Self:oProcess:cBody		:= Self:Body
Self:oProcess:cCC 		:= Self:cCC
Self:oProcess:cBCC 		:= Self:cBCC

//Objeto HTML do WF
oHtml 		:= Self:oProcess:oHTML

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Preenche a tabela do HTML com os dados do Header ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nFields := 1 To Len(Self:Header:Fields)
	cName 	:= Self:Header:Fields[nFields]:name
	cValue	:= Self:Header:Fields[nFields]:value
	If ValType(cValue) == "D"
		cValue := DTOC(cValue)
	EndIf
	If ValType(cValue) == "C"
	    cTableHeader+= '<tr>'+Chr(13)+Chr(10)
	    cTableHeader+= '<td width="12%" class="TituloMenor"><b>'+HTMLEnc(cName)+'</b></td>'+Chr(13)+Chr(10)
		cTableHeader+= '<td width="88%" class="texto" colspan="3">'+HTMLEnc(cValue)+'</td>'+Chr(13)+Chr(10)
	    cTableHeader+= '</tr>'+Chr(13)+Chr(10)
	EndIf
Next nFields              

//Finalizacao do Header do HTML
cTableHeader+= '<tr>'+Chr(13)+Chr(10)
cTableHeader+= '<td colspan="4" class="TituloMenor" background="pontilhado.gif">'+Chr(13)+Chr(10)
cTableHeader+= '<img src="transSelfe.gif" width="10" height="3"></td>'+Chr(13)+Chr(10)
cTableHeader+= '</tr>'+Chr(13)+Chr(10)
cTableHeader+= '<tr>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="TituloMenor">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="texto">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="TituloMenor">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="texto">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '</tr>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o cabecalho com os campos dos itens da tabela			ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(Self:Itens) > 0
	cTableItens += '<tr class="TituloMenor">'+Chr(13)+Chr(10)
	For nFields := 1 To Len( Self:Itens[1]:fields )
		cName := Self:Itens[1]:fields[nFields]:name
		cTableItens += '<td height="14" class="TituloMenor"><div align="center">'+HTMLEnc(cName)+'</div></td>'+Chr(13)+Chr(10)
	Next nFields
	cTableItens += '</tr>'+Chr(13)+Chr(10)
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Preenche a tabela do HTML com os dados dos Itens ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI := 1 To Len(Self:Itens)
	cTableItens += '<tr class="texto">'+Chr(13)+Chr(10)
	
	For nFields := 1 to Len( Self:Itens[nI]:fields )
		cValue	:= Self:Itens[nI]:fields[nFields]:value
		If ValType(cValue) == "D"
			cValue := DTOC(cValue)
		EndIf
		If ValType(cValue) == "C"
			cTableItens += '<td height="14" class="texto"><div align="center">'+HTMLEnc(cValue)+'</div></td>'+Chr(13)+Chr(10)
		EndIf
	Next nFields
	
	cTableItens += '</tr>'+Chr(13)+Chr(10)
Next nI

cTableItens += '<tr>'+Chr(13)+Chr(10)
cTableItens += '<td colspan="8" class="texto" background="pontilhado.gif" height="1">&nbsp;</td>'+Chr(13)+Chr(10)
cTableItens += '</tr>'+Chr(13)+Chr(10)
	
If oHtml:ExistField(1, "CABEC")
	oHtml:ValByName("CABEC",  Self:Body	)
EndIf
If oHtml:ExistField(1, "HEADER")
	oHtml:ValByName("HEADER", cTableHeader)
EndIf
If oHtml:ExistField(1, "ITENS")	
	oHtml:ValByName("ITENS",  cTableItens)
EndIf
Self:oProcess:bReturn := "RetWFAuth"
Self:internalID	:= Self:oProcess:fProcessID + Self:oProcess:fTaskID

Return                                                                                


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRetWFAuth     บAutor  ณVendas Clientes บ Data ณ  26/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de tratamento do retorno do WF quando o aprovador   บฑฑ
ฑฑบ          ณ responde a mensagem atraves do HTML                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetWFAuth(oProcess)
Local cInternalId	:= oProcess:fProcessID + oProcess:fTaskID
Local cCodWF		:= ""		
Local cResp			:= "1"
Local cObs			:= ""
Local nPos1 		:= nPos2 := 0
Local cCodADE 		:= ""
Local aAreaSKW		:= {}


ConOut(STR0003 + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )		//"(RETORNO) Processo: "
If oProcess:oHtml:ExistField(2, "OPC")
	ConOut(STR0004 + Upper(oProcess:oHtml:RetByName("OPC")))					//"Resposta do Aprovador: "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica a resposta do Aprovador ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oProcess:oHtml:ExistField(2, "OPC")
	If Upper(oProcess:oHtml:RetByName("OPC")) <> "S"
		cResp := "2"	//Nao
	Else
		cResp := "1"	//Sim
	EndIf
EndIf

If oProcess:oHtml:ExistField(2, "OBS")
	cObs := oProcess:oHtml:RetByName("OBS")
EndIf
ConOut(STR0005 + cObs)		//"Obs: "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a resposta de autorizacao na tabela SKW ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SKW")
DbSetOrder(2)
If DbSeek( xFilial("SKW") + cInternalId )
	nPos1 		:= At ("'" , SKW->KW_CODEBLK)
	nPos2 		:= RAt("'" , SKW->KW_CODEBLK)
	cCodADE 	:= Subs(SKW->KW_CODEBLK, nPos1+1 , (nPos2 - nPos1) - 1)
	aAreaSKW	:= SKW->(GetArea())
	
	If Select("_ADE") == 0
		ChkFile("ADE",.F.,"_ADE") 
	Else
		DbSelectArea("_ADE")
	EndIf
	RestArea(aAreaSKW)
	
	If Posicione("_ADE",1,xFilial("ADE")+cCodADE,"ADE_WFASTA") != "4" //--Se o chamado foi Reprovado ignoro a resposta do Workflow. 
		RecLock("SKW",.F.)
		REPLACE SKW->KW_AUTORIZ WITH cResp
		REPLACE SKW->KW_OBS 	WITH cObs
		SKW->(MsUnlock())
		cCodWF := SKW->KW_CODIGO
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega o objeto de WF                           ณ
//ณ Chama a funcao de usuario (CodeBlockWhenReplied) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjWF := WFAuthorization():New()
If oObjWF:load(cCodWF) 
	//Passa o objeto WFAuthorization como parametro
	oObjWF:CodeBlockWhenReplied:execute({oObjWF, Upper(oProcess:oHtml:RetByName("OPC"))})
Else
	ConOut(STR0006 + cCodWF)	//"Nao foi possivel encontrar o registro de WF: " ######
EndIf

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_TMKA520A     บAutor  ณVendas Clientes บ Data ณ  06/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao dummy apenas para o programa aparecer no inspetor de บฑฑ
ฑฑบ          ณobjetos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
FUNCTION _TMKA520A()
RETURN NIL
