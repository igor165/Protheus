#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include "topconn.ch"
#Include "APWIZARD.CH"    
#Include "FWBROWSE.CH"
#Include "plsatbpr.ch"
 
#define nLinMax	1430								//-- Numero maximo de Linhas
#define nColMax	2450								//-- Numero maximo de Colunas
#define nColIni	020                                  //-- Coluna Lateral (inicial) Esquerda
#define nCol001	065  
#define nCol002	425		
#define nCol003	475	
#DEFINE nLocal (GetNewPar("MV_PLSDRDA", "")) 

Static lAutoSt := .F.

/*INFORMA��ES IMPORTANTES
1) Este fonte utiliza FwTemporaryTable, para grava��o de dados tempor�rios e posterior uso em relat�rio.
2) Fun��o multithread, de acordo com a demanda dos dados encontrados para gera��o do relat�rio:
   2.1) Se for encontrado at� 3 mil procedimentos, � feito numa �nica thread;
   2.3) Acima de 3 mil procedimentos, � divido em 3 threads, para aumentar a perfgmance e diminui o tempo de processamento.
3) Quando a solicita��o do relat�rio de pre�os for solicitado via remote (PLSA731), a primeira fun��o a ser chamada � 
"PlsChJRPr", fun��o que inicia um Job, para que possa liberar o uso do sistema pelo usu�rio, visto que o processamento 
do relat�rio pode demorar algumas horas. Ap�s a chamada da fun��o "PlsChJRPr", � chamada a fun��o "PLSATBPR", que
faz algumas verifica��es e depois chama a "PlsMtJRPP", fun��o respons�vel em criar e popular a tabela tempor�ria,
com os procedimentos encontrados e nela temos a divis�o das threads, de acordo com o item 2 acima. Por fim, chama a fun��o
"PlsCttRpp", que atualiza a tabela tempor�ria com o valor e unidades do procedimentos, ap�s o c�lculo com o CALCEVE.
4) Ap�s atualiza��o das threads "PlsCttRpp", � chamado o relat�rio em pdf ou excel e demais processo de envio de e-mail.
5) Foi necess�rio um Job chamar outros jobs nesta fun��o para que no remote fosse liberada a tela para o usu�rio.
Logo, MANTER DESTA FORMA, para que o usu�rio possa fazer outros processos, pois � avisado que o processo � demorado
e o sistema encarrrega de atualizar demais refer�ncias ap�s atualzia��es, sem a necessidade de interven��o do usu�rio
*/


//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSATBPR
Query para retornar os dados dos niveis ap�s escolha da RDA - Painel de Sele��o de Nivel

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: 
@Obs: cCodRDA -> C�digo da RDA / cCodOpe -> C�digo da Operadora / cCodLoc -> C�digo do Local cCodEsp -> C�digo da Especialidade /
@Obs: lExbNel -> Informe se deve exibir os prodedimentos n�o autorizados / cMensagem -> Se exibe n�o autorizados, qual informa��o deve aparecer (16 carac) /
@Obs: lGerRel -> Informe se deve gerar relat�rio / lEnvMail -> Informe se deve enviar e-mail com relat�rio 
@Obs: cEndmail -> Informe os endere�os de e-mail / 
@Obs: cTpBusca -> Use somente se houver  necessidade, pois passando este c�digo, tem prioridade acima do par�metro MV_TPPQRPP,
@Obs: que � o par�metro onde o cliente informa como deseja que seja o relat�rio (se por especialidade, todos procedimentos da BR8 ou tabelas de reajuste)
@Obs: aJob -> se a fun��o por Job, � necess�rio informar os par�metros para iniciar o ambiente corretamente
@Obs: corigem -> Informe se o relat�rio est� sendo chamado do remote (valor "1") ou portal (valor "2")
@Obs: cCodTab -> C�digo da tabela informada pelo usu�rio (via portal)
@Obs: cFormRel -> Informe se � formato PDF (valor "1") ou Excel (valor "2"). Default do campo � PDF = "1"
@obs: RETORNO: {Se foi valorado; Array com os Dados do PLSCALCEVE; Nome do Arquivo gerado}
/*/
//---------------------------------------------------------------------------------                  
Function PLSATBPR(cCodRDA, cCodOpe, cCodLoc, cCodEsp, lExbNel, cMensagem, lGerRel, lEnvMail, cEndMail, cTpBusca, aJob, cOrigem, cCodTab, cFormRel, lAuto)
Local aValPro		:= {}  //Procedimentos autorizados ap�s CalcEve
Local aRetCal		:= {}

Local cSql			:= ""
Local cTabB23		:= ""
Local cAno			:= Alltrim(Str(Year(date())))
Local cMes			:= Alltrim(Str(month(date())))
Local cNomArq		:= ""
Local cTeste		:= "1"

Local nReg			:= 0
Local nI			:= 0 

Default cCodLoc	:= ""
Default cCodEsp	:= ""
Default cMensagem	:= STR0001
Default cOrigem	:= "2" //Web, para n�o gravar registro na B2H
Default cFormRel	:= "1"

Default lExbNel	:= .F.
Default lGerRel	:= .T.
Default lEnvMail	:= .F.
Default lauto := .F.

lAutoSt  := lAuto

//Verifica se � Job, para iniciar o ambiente correto.
If (!Empty(aJob) .AND. aJob[1])
	RpcSetType(3)
	rpcSetEnv(aJob[2], aJob[3],,,'PLS',, )
EndIf


//Verifico se o e-mail foi passado. Se n��o, busco na RDA
If ( lEnvMail .AND.  Empty(cEndMail) )
	BAU->(DbSetorder(1))
	If BAU->(DbSeek(xFilial("BAU")+cCodRda))
		cEndMail := BAU->BAU_EMAIL
	Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0002 , 0, 0, {})
	EndIf
EndIf	


//Verifico as variaveis dependentes de par�metros
cTpBusca	:= IIF (Empty(cTpBusca), GetNewPar("MV_TPPQRPP", "1"), cTpBusca ) // 1 - Pelas tabelasd de Pre�o; 2 - Procedimentos autorizados por Especialidade; 3 - Tabela Padr�o
cCodOpe	:= IIF (Empty(cCodOpe), PlsIntPad(), cCodOpe) 	

//Conout da Etapa
FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "2) "+STR0022 , 0, 0, {}) //" PlsChJRPr -> Job Iniciado!"

//Chamo a fun��o de escalonamento
cNomArq := PlsMtJRPP (cCodRda, cCodEsp, cCodOpe, cCodTab, cTpBusca, cMes, cAno, cTpBusca, cCodLoc, cMensagem, lGerRel, cFormRel, lEnvMail, cEndMail, cOrigem, lExbNel)


If (Len(cNomArq) > 0)
	aRetCal := {.T., aValPro, cNomArq}
Else
	aRetCal := {.F., aValPro, cNomArq}	
EndIf	
Return (aRetCal)



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSGREPRE
Query para retornar os dados dos niveis ap�s escolha da RDA - Painel de Sele��o de Nivel

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: C�d. da RDA; C�digo da Operadora; C�d. Local de Atendimento; C�d. Especialidade; Se exibe Mensagem
@Obs: para os procedimentos n�o valoriados, Mensagem personalizada quando n�o valorado.
@obs: Retorno da Fun��o � um array, conforme estrutura abaixo: 
@obs: {Indica se foi valorado ou n�o, Alias da Tabela, C�digo da Tabela, C�digo do Procedimento, Retorno do CalcEve, Texto caso esteja para exibir;
@Obs: alguma informa��o quando n�o valorizado} = {.T., "01","10101020",{ret CalcEve}, ""})
/*/
//---------------------------------------------------------------------------------

Function PLSGREPRE(cCodRDA, cCodOpe, cCodLoc, cCodEsp, cAno, cMes, lEnvMail, cEndMail, cOrigem, cNomTtDad)
Local aDadRDA	
Local aDadUsr		:= {}
Local aRetDaD
Local aPlsVal
Local aResult		:= {}
Local aArea		:= GetArea()
Local aUnidade	:= {}

Local cNomArq		:= ""
Local cGeracRel	:= cMes + '_' + cAno +  '_' + Substr(Time(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2)
Local cNomRotina	:= "PLSATBPR" +Space((TamSX3("BMV_ROTINA")[1]-Len(Alltrim("PLSATBPR")))) 
Local cTemp		:= ""
Local cNomTab		:= ""
Local cTextQb		:= ""
Local cCamArq		:= ""

Local lFlagZ 		:= .F.
Local lFlgEml		:= .T.

Local nI			:= 0
Local nY			:= 0

Local oFont08		:= ""
Local oFont10		:= ""
Local oFont10n	:= ""
Local oFont12		:= ""
Local oPrint  

PRIVATE cRel    	:= "plstarq"
PRIVATE cPathRelW	:= nLocal
PRIVATE cCodInt	:= PlsIntPad()

PRIVATE lWeb 		:= .T.
Private li 			:= 0

Private nPage 		:= 1

//Para acompanhamento do processo via Job
FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "4) " + STR0026 , 0, 0, {})

//Tamanho das fontes para o relat�rio
oFont08 		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont08n 		:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont10n 		:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont10  		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont12n		:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)		

//Dados para o relat�rio
BMV->(DbSetOrder(3))  //Filial + Tipo Portal + Descricao + Rotina
If BMV->(DbSeek(xFilial("BMV") + "2" + "NOMEREL"+Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim("NOMEREL")))) + cNomRotina ))
	cTemp := Alltrim(BMV->BMV_MSGPOR)
	cNomArq := IIF(Len(cTemp) > 20, SubStr(cTemp,1,20) + '_' + cCodRda + '_' + cGeracRel, cTemp + '_' + cCodRda + '_' + cGeracRel )
Else
	cNomArq := cCodRDA + '_' + cGeracRel
EndIf

cCamArq := nLocal + cNomArq + ".pdf"

oPrint := FWMSPrinter():New (cNomArq,6,.F.,,.T.,.F.,,"PDF",.T., .F., .F.,.F.)
//Inicializa��o do relat�rio
cPathSrvJ 	:= cPathRelW 
SetPrintFile(cRel)

oPrint:lInJob  := lWeb 
oPrint:lServer := lWeb	
oPrint:cPathPDF := nLocal
oPrint:SetPortrait()					    
oPrint:SetPaperSize(9)
oPrint:StartPage() 						
oPrint:SetViewPDF(.F.)

//Criar o cabe�alho do Relat�rio
fImpCbl(@li, @nPage, oPrint, cCodRDA, cCodLoc, cCodEsp, oFont08n, oFont10n, oFont10, oFont12, .F.)

//Posiciono a tabela criada na primeira posi��o
(cNomTtDad)->(DbGoTop())

//Percorrer o Array para gerar o relat�rio     
If (!(cNomTtDad)->(EOF())) 
	While ( !(cNomTtDad)->(EOF()) )
		//Procuro na BMV a descri��o que deve ser carregada no relat�rio para cada grupo
		If cNomTab <> (cNomTtDad)->NIVEL
			BMV->(DbSeek(xFilial("BMV") + "2" + cNomRotina + (cNomTtDad)->NIVEL + Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim((cNomTtDad)->NIVEL))))) )
			cTemp := Alltrim(BMV->BMV_MSGPOR)
			cNomTab := (cNomTtDad)->NIVEL
			//criar fun��o para o subt�tulo de acordo com alias da tabela
			fCabNvTab(@li, @nPage, oPrint, oFont10n, AllTrim(cNomTab), oFont10, .F.)
		EndIf
		
	   	If ( !Empty((cNomTtDad)->IDENT) ) 
			lFlagZ := .T. 
			If li > 780
				oPrint:EndPage() // Finaliza a pagina
	        	oPrint:StartPage()
		      	nPage++
		      	fImpCbl(@li,@nPage, oPrint, cCodRDA, cCodLoc, cCodEsp, oFont08n, oFont10n, oFont10, oFont12, .T.)
	       EndIF
	       li += 15 	
	       //Impress�o do C�digo do procedimento
	       oPrint:say(li, nColIni, Alltrim((cNomTtDad)->PROCEDIM), oFont08)  //C�d. Procedimento
	       
	       //Impress�o do Nome do procedimento
	       If ( Len(Alltrim((cNomTtDad)->DESCRICAO)) > 75 )  //Descri��o
	       	cTextQb := PlscUnidV("2", nil, Alltrim((cNomTtDad)->DESCRICAO), 1, 75 ) 
	       	If (cTextQb[3] >= 1) //quantidade de posi��es
	       		For nY := 1 To (cTextQb[3])
	       			oPrint:say(li, nColIni+nCol001, AllTrim(cTextQb[2,nY]), oFont08)
	       			li += 15
	       		Next nY++	
	       		li -= 15
	       	EndIf
	       Else
	       	oPrint:say(li, nColIni+nCol001, AllTrim((cNomTtDad)->DESCRICAO), oFont08)		
	       Endif	
	
	       //Impress�o do valor do procedimento
	       If ( (cNomTtDad)->VALOR > 1 )  //Significa que houve valora��o
	       	oPrint:say(li, nColIni+nCol002, AllTrim(cValtochar(transform((cNomTtDad)->VALOR, "@E 999,999,999.99"))), oFont08)  //Valor
	       Else
	       	oPrint:say(li, nColIni+nCol002, AllTrim("0.00"), oFont08)  //Valor
	       EndIf	
	       	
	       //Impress�o da unidades de Medida
	       If ( Len((cNomTtDad)->UNIDADE) > 16 ) 
	       	cTextQb := PlscUnidV("2", nil, Alltrim((cNomTtDad)->UNIDADE), 1, 16 ) 
	       	If (cTextQb[3] >= 1) //quantidade de posi��es
	       		For nY := 1 To (cTextQb[3])
	       			oPrint:say(li, nColIni+nCol003, AllTrim(cTextQb[2,nY]), oFont08)
	       			li += 15
	       		Next nY++	
	       		li -= 15
	       	EndIf
	       Else
   	       	oPrint:say(li, nColIni+nCol003, AllTrim((cNomTtDad)->UNIDADE), oFont08)		
	   		EndIF	
	   	EndIf	 
	(cNomTtDad)->(DbSkip())   	
	EndDo    

ELSE  //N�o foram encontrados dados. Imprime no relat�rio essa informa��o
	li += 50
	oPrint:say(li, nColIni, STR0003, oFont10n)  	
ENDIF


//P�gina com as Legendas das Unidades de Sa�de
aResult := PlsQrUndRl()
oPrint:EndPage() // Finaliza a pagina
oPrint:StartPage()
nPage++

fImpCbl(@li,@nPage, oPrint, cCodRDA, cCodLoc, cCodEsp, oFont08n, oFont10n, oFont10, oFont12, .F.)
fCabNvTab(@li, @nPage, oPrint, oFont10n, "TITULOLEGENDAUNI", oFont10, .T.)
If ( Len(aResult) > 0)
	For nI := 1 To Len(aResult)
		If li > 780
			oPrint:EndPage() // Finaliza a pagina
			oPrint:StartPage()
			nPage++
			fImpCbl(@li,@nPage, oPrint, cCodRDA, cCodLoc, cCodEsp, oFont08n, oFont10n, oFont10, oFont12, .T.)
		EndIf
		li += 15 
		//Impress�o do C�digo da Unidade
		oPrint:say(li, nColIni, Alltrim(aResult[nI,1]), oFont08)  
		
		//Nome da Unidade
		oPrint:say(li, nColIni+nCol001, AllTrim(aResult[nI,2]), oFont08)	
	Next		
EndIF 



//Grava o Documento em PDF
PLSGrvRPP(oPrint, lEnvMail, cEndMail, cCamArq, cOrigem, cCodOpe, cCodRda)	

Return cNomArq

//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlscUnidV
Retornar os dados das unidades do procedimento em formato de array controlado, 3 por posi��o ou string

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
Function PlscUnidV(cTipo, aDadUni, cTexto, nInicial, nIncreTam)
Local aDadTmp		:= {}

Local cUnid 		:= ""
Local cTemp		:= ""

Local nI 			:= 0
Local nY			:= 0
Local nQtd			:= 0
Local nTamStr		:= nIncreTam
Local nTamIni		:= nInicial

Default cTipo 	:= "1" //1-Array / 2 - string

Default nInicial	:= 1
Default nIncreTam	:= 12

If (cTipo == "1")
	For nI := 1 To Len(aDadUni)
		cUnid += aDadUni[nI,1] + ","
	Next
	cUnid := AllTrim(SUBSTR(cUnid, 1, (Len(cUnid)-1)))
	
	If (Len(cUnid) > nTamStr)
		nQtd := Ceiling(Len(cUnid) / nTamStr)
		For nY := 1 To nQtd		
			aAdd(aDadTmp, SUBSTR(cUnid, nTamIni, nTamStr)) //Separa(SUBSTR(cUnid, 1, nTamStr), ',',.F.) )
			nTamIni := nTamIni + nTamStr
		Next nY++
	EndIf
Else
	cUnid := cTexto
	nQtd := Ceiling(Len(cTexto) / nTamStr)
	For nY := 1 To nQtd		
		aAdd(aDadTmp, SUBSTR(cTexto, nTamIni, nTamStr)) //Separa(SUBSTR(cUnid, 1, nTamStr), ',',.F.) )
		nTamIni := nTamIni + nTamStr
	Next nY++
EndIf

Return {cUnid, aDadTmp, nQtd}



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSGrvRPP
Grava o documento no servidor e limpa fila de impress�o

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
Function PLSGrvRPP(oPrint, lEnvMail, cEndMail, cCamArq, cOrigem, cCodOpe, cCodRDA, lExcel)
Local cArqRen		:= ""
Local lComprss	:= .F.

Default lExcel	:= .F.

If !lExcel
	oPrint:Print()
	//MS_FLUSH()             // Libera fila de relatorios   
Endif


//A parte de compacta��o ficar� em standby - Details sprint 
/*
//Compacta��o do Arquivo, pois pode ficar muito grande para envio por e-mail
cArqRen	:= IIF ( !lExcel, strTran(cCamArq,'pdf','rar'), strTran(cCamArq,'xls','rar') )
lComprss 	:= GzCompress (cCamArq, cArqRen)

If lComprss  //Ocorreu a compacta��o com sucesso, procede com a exclus�o do arquivo e deixo apenas o compactado
	Conout(STR0029)  //PLSGrvRPP -> Compactacao com sucesso do relatorio! Sera enviado o relatorio compactado! 
	fErase(cCamArq)  //apago o arquivo original .pdf ou .xls, para economia de espa�o
	cCamArq := cArqRen
Else
	Conout(STR0030) //PLSGrvRPP -> Problemas com a compactacao do relat�rio. Sera enviado o relatorio original! "		
EndIf			
*/

//fun��o de e-mail e sinalizador
If lEnvMail
	If ( Empty(cEndMail) )
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0004 , 0, 0, {})
	Else
		BOJ->(DbSelectArea("BOJ"))
		BOJ->(DbSetOrder(3))
		If ( BOJ->(MsSeek(xFilial("BOJ") + "PLSATBPR" + (Space(TamSx3("BOJ_ROTINA")[1] - 8))  + "01" + (Space(TamSx3("BOJ_VERSAO")[1] - 2 )))) )
			//Colocar anexos com o Pdf gerado
			PLSinaliza(BOJ->BOJ_CODSIN, nil, nil, cEndMail, "Tabelas Contratuais", nil, nil, nil, cCamArq, nil, .F.,,,,)
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0005 , 0, 0, {})	
		EndIf
	EndIf
EndIf

If ( cOrigem == "1" )
	PlsGrTb2H(cCodRDA, cCamArq, cCodOpe)
EndIf	
Return 



//---------------------------------------------------------------------------------
/*/{Protheus.doc} fImpCbl
Cabe�alho do relat�rio

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
Static Function fImpCbl(li, nPage, oPrint, cCodRDA, cCodLoc, cCodEsp, oFont08n, oFont10n, oFont10, oFont12, lCabDesc)
Local cNomRotina	:= "PLSATBPR" +Space((TamSX3("BMV_ROTINA")[1]-Len(Alltrim("PLSATBPR"))))
Local cNomRel		:= STR0006
Local cCodOpe		:= PlsIntPad()

Default lCabDesc	:= .F.

li := 25

//Informa data e n�mero da P�gina
oPrint:say(li, 30, OemToAnsi(STR0007 + DtoC(date()) + STR0008 + Alltrim(Str(nPage))), oFont08n)  //"Data"+"Pagina N�"

li+=15

//Nome do Relat�rio
BMV->(DbSetorder(3))  //Filial + Tipo de Portal + Descri��o + Rotina
If ( BMV->(DbSeek(xFilial("BMV") + "2" + "TITULOREL" + Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim("TITULOREL")))) + cNomRotina )) )
	cNomRel := Alltrim(BMV->BMV_MSGPOR)
	cNomRel := IIF ( Len(cNomRel) > 110, SUBSTR(cNomRel, 1, 110), cNomRel)
EndIf
oPrint:say(li+15, 30, OemToAnsi(cNomRel), oFont12n)  //"RELAT�RIO DE PROCEDIMENTOS AUTORIZADOS RDA"

li+=15

//Nome da RDA
oPrint:say(li+15, 30, OemToAnsi(STR0009 + Posicione("BAU",1,xFilial("BAU")+ AllTrim(cCodRDA),"BAU_NOME")), oFont08n)  //Prestador:

li+=15

//C�digo da Especialidade e Local de Atendimento
If (!Empty(cCodEsp))
	li+=15
	oPrint:say(li+15, 30, OemToAnsi(STR0010 + Posicione("BAQ",1,xFilial("BAQ")+ cCodOpe + AllTrim(cCodEsp),"BAQ_DESCRI") ), oFont08n) //Especialidade	 
EndIf
If (!Empty(cCodLoc))
	li+=15
	oPrint:say(li+15, 30, OemToAnsi(STR0011 + Posicione("BB8",1,xFilial("BB8")+ cCodRda + cCodOpe + AllTrim(cCodLoc),"BB8_DESLOC") ), oFont08n)  //Local de Atendimento
EndIf

li+=15

If lCabDesc
	//Cabe�alho das Colunas
	oPrint:say(li+=20, nColIni, STR0012 	, oFont10)  	//"C�d. Proced. "
	oPrint:say(li, nCol001+20,  STR0013	, oFont10)   	//"Descri��o"
	oPrint:say(li, nCol002+20,  STR0014 	, oFont10)	//"Valor"
	oPrint:say(li, nCol003+20,  STR0015 	, oFont10)	//"Unidades/Obs"
	
	oPrint:line(li+=10,nColIni,li,nColIni+540)
EndIf	
Return()



//---------------------------------------------------------------------------------
/*/{Protheus.doc} fCabNvTab
Cabe�alho dos n�veis da tabela de pre�os

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
Static Function fCabNvTab(li, nPage, oPrint, oFont10n, cNivel, oFont10, lLegUni)
Local cNomRotina	:= "PLSATBPR" +Space((TamSX3("BMV_ROTINA")[1]-Len(Alltrim("PLSATBPR"))))
Local cNomNiv		:= ""

Local nY			:= 0

Default lLegUni	:= .F.

li+=35

//Nome do cabe�alho de n�vel
BMV->(DbSetorder(3))  //Filial + Tipo de Portal + Descri��o + Rotina
If ( BMV->(DbSeek(xFilial("BMV") + "2" + cNivel + Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim(cNivel)))) + cNomRotina )) )
	cNomNiv := Alltrim(BMV->BMV_MSGPOR)
	If !Empty(cNomNiv)
		cNomNiv := IIF (Len(cNomNiv) > 260, SUBSTR(cNomNiv, 1, 260), cNomNiv)
		cTextQb := PlscUnidV("2", nil, Alltrim(cNomNiv), 1, 130 )	
		If (cTextQb[3] >= 1) //quantidade de posi��es
       	For nY := 1 To (cTextQb[3])
       		oPrint:say(li, nColIni, AllTrim(cTextQb[2,nY]), oFont10n)
       		li += 15
       	Next nY++	
       	li -= 15
       EndIf
	Else
		oPrint:say(li, 30, AllTrim(cNivel), oFont10n)	
	EndIf
Else
	oPrint:say(li, 30, AllTrim(cNivel), oFont10n)	
EndIf

If !lLegUni
	//Cabe�alho das Colunas
	oPrint:say(li+=20, nColIni, STR0012 	, oFont10)  	//"C�d. Proced. "
	oPrint:say(li, nCol001+20,  STR0013	, oFont10)   	//"Descri��o"
	oPrint:say(li, nCol002+20,  STR0014 	, oFont10)	//"Valor"
	oPrint:say(li, nCol003+20,  STR0015 	, oFont10)	//"Unidades/Obs"
	
	oPrint:line(li+=10,nColIni,li,nColIni+540)

Else
	//Cabe�alho das Colunas
	oPrint:say(li+=20, nColIni, STR0020 	, oFont10) //"C�d. Unidade. "
	oPrint:say(li, nCol001+20,  STR0013	, oFont10) //"Descri��o"
	
	oPrint:line(li+=10,nColIni,li,nColIni+540)
EndIf		

Return ()



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsChJRPr
Chama a fun��o Job para processar o relat�rio

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
Function PlsChJRPr (cCodRDA, cCodOpe, cCodLoc, cCodEsp, lExbNel, cMensagem, lGerRel, lEnvmail, cEndMail, cTpBusca, cOrigem, cCodTab, cFormRel)
LOCAL aDadosJo		:= {}

Local cRpcServer	:= GetNewPar("MV_PLSSRV", "")  //Server de conex�o
Local nRPCPort 	:= GetNewPar("MV_PLSPRT", 0)	//Porta de Conex�o
Local cRPCEnv 	:= GetNewPar("MV_PLSENV", GetEnvServer())	//Environment
LOCAL cEmpPls		:= GetNewPar("MV_EMPRPLS", "99")	// Pega a empresa de trabalho do PLS
LOCAL cFilPls		:= PADR(GetNewPar("MV_FILIPLS", "01"),FWSizeFilial())	// Pega a filial de trabalho do PLS

Default cCodOpe	:= PlsIntPad()

aDadosJo := {.T., cEmpPls, cFilPls}
//Verifico se cCodRDA esta preenchido. Se n�o, interrompo processamento
IF ( Empty(cCodRDA) )
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0016 , 0, 0, {}) //PlsChJRPr -> C�digo da RDA n�o informada. Processo interrompido
	Return
ENDIF

// Chamar JOB para processamento do relat�rio
If empty(cRpcServer)
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "1) " + STR0017 , 0, 0, {}) //" PlsChJRPr -> Job Iniciado!"
	StartJob("PLSATBPR", GetEnvServer(), .F., cCodRDA, cCodOpe, cCodLoc, cCodEsp, lExbNel, cMensagem, lGerRel, lEnvMail, cEndMail, cTpBusca, aDadosJo, cOrigem, cCodTab, cFormRel)
Else												
	oServer := TRPC():New( cRPCEnv )
	If oServer:Connect( cRpcServer, nRPCPort )
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "1) " + STR0017 , 0, 0, {}) //" PlsChJRPr -> Job Iniciado!"
		oServer:StartJob("PLSATBPR", GetEnvServer(), .F., cCodRDA, cCodOpe, cCodLoc, cCodEsp, lExbNel, cMensagem, lGerRel, lEnvMail, cEndMail, cTpBusca, aDadosJo, cOrigem, cCodTab, cFormRel)
		oServer:Disconnect()									 
	Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0018 + cRPCServer , 0, 0, {}) //" PlsChJRPr -> Conexao indisponivel com o servidor: " 
	EndIf
EndIf

Return



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsTpQrRP
Query para retornar os dados dos niveis ap�s escolha da RDA - Painel de Sele��o de Nivel

@author  Renan Martins	
@version P12
@since   10/2016
/*/
//---------------------------------------------------------------------------------
Function PlsTpQrRP(cTipo, cCodRda, cCodEsp, cCodOpe, cCodTab)
Local aTabB22		:= {}

Local cSql			:= ""
Local cTabB23		:= ""

Local nI			:= 0 


If (cTipo == "1") //Buscar todas as tabelas de rpe�o do prestador
	cSql += " SELECT 'BC6' TABELA, BC6_CODPAD CODPAD, BC6_CODPRO CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN "
	cSql += " FROM " + RetSQLName ("BC6")  
	cSql += " INNER JOIN " + RetSQLName ("BR8") + " ON BR8_CODPAD = BC6_CODPAD AND BR8_CODPSA = BC6_CODPRO "
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " WHERE BC6_CODRDA = '" + cCodRDA + "' AND "+ RetSQLName("BC6") + ".D_E_L_E_T_ = '' "
	If !Empty(cCodTab)
		cSql += " AND BC6_CODPAD ='" + cCodTab + "' "
	EndIf
	cSQL += " AND ( '"+dtos(dDataBase)+"' >= BC6_VIGINI ) AND "
	cSQL += "     (( '"+dtos(dDataBase)+"' <= BC6_VIGFIM OR BC6_VIGFIM = '' ) OR ( BC6_VIGINI = '' AND BC6_VIGFIM = '' )) "
	
	cSql += " UNION ALL "
	
	
	cSql += " SELECT 'BE9' TABELA, BE9_CODPAD CODPAD, BE9_CODPRO CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN  "
	cSql += " FROM " + RetSQLName ("BE9") 
	cSql += " INNER JOIN " + RetSQLName ("BR8") + " ON BR8_CODPAD = BE9_CODPAD AND BR8_CODPSA = BE9_CODPRO "
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " WHERE BE9_CODIGO = '" + cCodRDA + "' AND " + RetSQLName("BE9") + ".D_E_L_E_T_ = '' "
	If !Empty(cCodTab)
		cSql += " AND BE9_CODPAD ='" + cCodTab + "' "
	EndIf
	cSQL += "  AND ( '"+dtos(dDataBase)+"' >= BE9_VIGDE ) AND "
	cSQL += "      (( '"+dtos(dDataBase)+"' <= BE9_VIGATE OR BE9_VIGATE = '' ) OR ( BE9_VIGDE = '' AND BE9_VIGATE = '' )) "
	
	cSql += " UNION ALL "
	
	
	cSql += " SELECT 'BC0' TABELA, BC0_CODPAD CODPAD, BC0_CODOPC CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN  "
	cSql += " FROM " + RetSQLName ("BC0") 
	cSql += " INNER JOIN " + RetSQLName ("BR8") + " ON BR8_CODPAD = BC0_CODPAD AND BR8_CODPSA = BC0_CODOPC  "
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " WHERE BC0_CODIGO = '" + cCodRDA + "' AND " + RetSQLName("BC0") + ".D_E_L_E_T_ = '' "
	If !Empty(cCodTab)
		cSql += " AND BC0_CODPAD ='" + cCodTab + "' "
	EndIf	
	cSQL += "  AND ( '"+dtos(dDataBase)+"' >= BC0_VIGDE ) AND "
	cSQL += "      (( '"+dtos(dDataBase)+"' <= BC0_VIGATE OR BC0_VIGATE = '' ) OR ( BC0_VIGDE = '' AND BC0_VIGATE = '' )) "
	
	cSql += " UNION ALL "
	
	
	cSql += " SELECT 'BMI' TABELA, BMI_CODPAD CODPAD, BMI_CODPSA CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN  "
	cSql += " FROM " + RetSQLName ("BMI")
	cSql += " INNER JOIN " + RetSQLName ("BR8") + "  ON BR8_CODPAD = BMI_CODPAD AND BR8_CODPSA = BMI_CODPSA "
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " WHERE BMI_CODRDA = '" + cCodRDA + "' AND " + RetSQLName("BMI") + ".D_E_L_E_T_ = '' "
	If !Empty(cCodTab)
		cSql += " AND BMI_CODPAD ='" + cCodTab + "' "
	EndIf
	cSQL += "  AND (( '"+dtos(dDataBase)+"' >= BMI_DATDE ) or (BMI_DATDE = '')) "
	
	cSql += " UNION ALL "
	
	
	cSql += " SELECT 'BLY' TABELA, BLY_CODPAD CODPAD, BLY_CODOPC CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN  "
	cSql += " FROM " + RetSQLName ("BLY") 
	cSql += " INNER JOIN " + RetSQLName ("BR8") + " ON BR8_CODPAD = BLY_CODPAD AND BR8_CODPSA = BLY_CODOPC "
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " WHERE BLY_CODRDA = '" + cCodRDA + "' AND " + RetSQLName("BLY") + ".D_E_L_E_T_ = '' "
	If !Empty(cCodTab)
		cSql += " AND BLY_CODPAD ='" + cCodTab + "' "
	EndIf
	cSQL += "  AND ( '"+dtos(dDataBase)+"' >= BLY_VIGDE ) AND "
	cSQL += "      (( '"+dtos(dDataBase)+"' <= BLY_VIGATE OR BLY_VIGATE = '' ) OR ( BLY_VIGDE = '' AND BLY_VIGATE = '' )) "
	
	cSql += " UNION ALL "
	
	//Irei verificar as tabelas no nivel gen�rico - Verifico agora a B29, para descobrir quais tabelas gen�ricas est�o relacionadas.
	B29->(DbSetOrder(1))
	B22->(DbSetOrder(1))
	B23->(DbSetOrder(1))
	IF ( B29->(DbSeek(xFilial("B29") + cCodRDA + cCodOpe)) .AND. ( IIF(Empty(B29->B29_VIGINI), .T., dDataBase >= B29->B29_VIGINI ) ) .AND.;
		( IIF (Empty(B29->B29_VIGFIN),.T.,  dDataBase <= B29->B29_VIGFIN)) ) 
		While !(B29->(EOF())) .AND. B29->(B29_CODIGO + B29_CODINT) == (cCodRDA + cCodOpe)
			aAdd(aTabB22, B29->B29_TABPRE)
			B29->(DbSkip())
		ENDDO
		For nI := 1 TO Len(aTabB22)	
			IF ( B22->(DbSeek(xFilial("B22") + cCodOpe + aTabB22[nI])) .AND. ( IIF(Empty(B22->B22_DATINI), .T., dDataBase >= B22->B22_DATINI )) .AND.;
				( IIF(Empty(B22->B22_DATFIM), .T., dDataBase <= B22->B22_DATFIM)))
				cTabB23 += "'" + aTabB22[nI] + "'," 
			ENDIF
		Next
		cTabB23 := Substr(cTabB23,1, (Len(cTabB23)-1))
		//Monto query ap�s essa verifica��es de tabelas e vig�ncias...
		cSql += " SELECT 'B23' TABELA, B23_CODPAD CODPAD, B23_CODPRO CODPRO, BR8_DESCRI DESCRI, B23_CODTAB TBB23GEN  "
		cSql += " FROM " + RetSQLName ("B23") 
		cSql += " INNER JOIN " + RetSQLName ("BR8") + " ON BR8_CODPAD = B23_CODPAD AND BR8_CODPSA = B23_CODPRO "
		If lautoSt
			cSql += " AND BR8_CODPSA = '10101012' "
		endIf
		cSql += " WHERE B23_CODTAB IN (" + cTabB23 + ") AND " + RetSQLName("B23") + ".D_E_L_E_T_ = '' "
		If !Empty(cCodTab)
			cSql += " AND B23_CODPAD ='" + cCodTab + "' "
		EndIf
		cSQL += " AND ( '"+dtos(dDataBase)+"' >= B23_VIGINI ) AND "
		cSQL += "      (( '"+dtos(dDataBase)+"' <= B23_VIGFIM OR B23_VIGFIM = '' )) "
	
	ENDIF
	
ElseIf (cTipo == "2")  //Delimito a Busca pelos procedimentos autorizados conforme cadastro de especialidades da Rede
	cSql += " SELECT DISTINCT BAQ_DESCRI TABELA, BBM_CODPAD CODPAD, BBM_CODPSA CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN "
	cSql += " FROM "  + RetSQLName ("BBF")
	cSql += " INNER JOIN "  + RetSQLName ("BBM")
	cSql += " ON BBF_FILIAL = BBM_FILIAL AND BBF_CDESP = BBM_CODESP AND BBF_CODINT = BBM_CODINT "
	cSql += " INNER JOIN " + RetSQLName ("BR8")
	cSql += " ON BBM_FILIAL = BR8_FILIAL AND BBM_CODPAD = BR8_CODPAD AND BBM_CODPSA = BR8_CODPSA "
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " INNER JOIN "   + RetSQLName ("BAQ")
	cSql += " ON BBF_FILIAL = BAQ_FILIAL AND BBF_CDESP = BAQ_CODESP AND BBF_CODINT = BAQ_CODINT "
	cSql += " WHERE BBF_FILIAL = '" + xFilial("BB8") + "' AND BBF_CODINT = '" + cCodOpe + "' "
	cSql += " AND BBF_CODIGO = '" + cCodRDA + "' "
	If !Empty(cCodEsp)
		cSql += " AND BBF_CDESP = '" + cCodEsp + "' "
	EndIf	
	If !Empty(cCodTab)
		cSql += " AND BBM_CODPAD ='" + cCodTab + "' "
	EndIf 
	cSql += " AND ( '"+dtos(dDataBase)+"' >= BBF_DATINC ) AND (('"+dtos(dDataBase)+"' <= BBF_DATBLO OR BBF_DATBLO = ' ' )) "
	cSql += " AND BBM_ATIVO = '1' AND " + RetSQLName("BBF") + ".D_E_L_E_T_ = '' "

ElseIf (cTipo == "3")  //Se for apenas pela Tabela Padr�o -> BR8
	cSql += " SELECT DISTINCT 'BR8' TABELA, BR8_CODPAD CODPAD, BR8_CODPSA CODPRO, BR8_DESCRI DESCRI, '' TBB23GEN "
	cSql += " FROM " +RetSqlName("BR8") + " BR8 "
	cSql += " WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
	If !Empty(cCodTab)
		cSql += " AND BR8_CODPAD = '" + cCodTab + "' "
	EndIf
	If lautoSt
		cSql += " AND BR8_CODPSA = '10101012' "
	endIf
	cSql += " AND BR8.D_E_L_E_T_ = '' "
ENDIF

//Tirar UNION caso exista na �ltima posi��o
IIF (RIGHT(cSql, 6) $ "N ALL ", cSql := LEFT(cSql, LEN(cSQL)-10), "")
 
//ORDER BY por Tabela e C�digo do procedimento
IIF (cTipo $ '1,3', cSql += " ORDER BY TABELA, CODPRO ", cSql += " ORDER BY TABELA, CODPRO ")	

Return cSql



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsQrUndRl
Query para retornar unidades na parte de legenda

@author  Renan Martins	
@version P12
@since   10/2016
/*/
//---------------------------------------------------------------------------------
Function PlsQrUndRl()
Local aUnidV	:= {}

Local cSql 	:= ""

cSql += " SELECT BD3_CODIGO CODIGO, BD3_DESCRI DESCRI "
cSql += " FROM " + RetSqlname("BD3")
cSql += " WHERE BD3_FILIAL = '" + xFilial("BD3") + "' "

cSql	:= ChangeQuery(cSql)
TcQuery cSql New Alias "ProcUnid"

While !ProcUnid->(Eof())
	aAdd(aUnidV, {ProcUnid->CODIGO, ProcUnid->DESCRI} )		//2 - Verifico se o exame est� autorizado para a RDA.
	ProcUnid->(DbSkip())		
Enddo

ProcUnid->(DBCLOSEAREA())

Return aUnidV



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsGrTb2H
Gravar registro

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
Function PlsGrTb2H (cCodRda, cCamArq, cCodOpe)
Local cSeq		:= "000"
Local cRev		:= ""
Local cCodTb	:= (GetNewPar("MV_PLCDOCC", "")) 
Local cNomArq	:= ""

B2H->(DbSetOrder(1))
If B2H->(DbSeek(xFilial("B2H")+cCodRda))
	While !(B2H->(EOF())) .AND. B2H->(B2H_RDA) == (cCodRDA)
		cSeq := B2H->B2H_SEQ
		B2H->(DbSkip())
	ENDDO
ENDIF

//Incrementar o n�mero
cSeq := Soma1(cSeq)	


//Localizar na B2L o Documento para gravara a revis�o na B2H
B2L->(DbSetOrder(1))
If B2L->(DbSeek(xFilial("B2L")+cCodTb))
	cRev := B2L->B2L_REV
EndIf	

//Realizar a grava��o
B2H->(RecLock("B2H", .T.))
	B2H->B2H_FILIAL	:= xFilial("B2H")
	B2H->B2H_RDA		:= cCodRda
	B2H->B2H_SEQ		:= cSeq
	B2H->B2H_DOC		:= cCodTb
	B2H->B2H_REV		:= cRev
	B2H->B2H_DTINC	:= dDataBase
	B2H->B2H_PATH		:= cCamArq
B2H->(MsUnlock())

//Gravar no banco de Conhecimento
cNomArq := xFilial("B2H")+cCodRda+cCodTb+cRev+cSeq
If ( !Empty(cNomArq) .AND. !Empty(cCamArq) )
	//Signifca que veio da tabela de pre�o e fa�o a inclus�o direta, pois � por JOB
	PLSINCONH(cCamArq, "B2H", cNomArq, .T.)
EndIf
	
Return



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsGrExcRPP
Gravar registro

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: 
//---------------------------------------------------------------------------------
/*/
Function PlsGrExcRPP(cCodRDA, cCodOpe, cCodLoc, cCodEsp, cAno, cMes, lEnvMail, cEndMail, cOrigem, cNomTtDad)
Local aUnidade	:= {}

Local cNumTab		:= ""
Local cNomNiv		:= ""
Local cGeracRel	:= cMes + '_' + cAno+  '_' + Substr(Time(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2)
Local cNomRotina	:= "PLSATBPR" +Space((TamSX3("BMV_ROTINA")[1]-Len(Alltrim("PLSATBPR")))) 
Local cTemp		:= ""
Local cNomTab		:= ""
Local cJuntLcEp	:= ""

Local nI 			:= 0

Local oPlan 		:= Nil

//Para acompanhamento do processo via Job
FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "4) " + STR0027 , 0, 0, {})

//Crio objeto Excel
oPlan := FWMSEXCEL():New()

//Dados para o relat�rio
BMV->(DbSetOrder(3))  //Filial + Tipo Portal + Rotina
If BMV->(DbSeek(xFilial("BMV") + "2" + "NOMEREL"+Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim("NOMEREL")))) + cNomRotina ))
	cTemp := Alltrim(BMV->BMV_MSGPOR)
	cNomArq := IIF(Len(cTemp) > 20, SubStr(cTemp,1,20) + '_' + cCodRda + '_' + cGeracRel, cTemp + '_' + cCodRda + '_' + cGeracRel )
Else
	cNomArq := cCodRDA + '_' + cGeracRel
EndIf
//caminho do arquivo
cCamArq := nLocal + cNomArq + ".xls"


//T�tulo do Relat�rio
BMV->(DbSetorder(3))
If ( BMV->(DbSeek(xFilial("BMV") + "2" + "TITULOREL" + Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim("TITULOREL")))) + cNomRotina )) )
	cNomRel := Alltrim(BMV->BMV_MSGPOR)
	cNomRel := IIF ( Len(cNomRel) > 110, SUBSTR(cNomRel, 1, 110), cNomRel)
	//cNomRel := SUBSTR(cNomRel,1,20)
EndIf
 
oPlan:AddworkSheet(cNomRel)
oPlan:AddTable (cNomRel, cNomRel)//aDadRel[1])
  
   
//Nome da RDA , Adiciono as colunas de cod, descri��o, valor e unidade
oPlan:AddColumn(cNomRel, cNomRel, "Nome do Prestador / Especialidade / Local: ",1, 1)
oPlan:AddColumn(cNomRel, cNomRel, "N�vel:",1, 1)
oPlan:AddColumn(cNomRel, cNomRel, STR0012,1, 1)
oPlan:AddColumn(cNomRel, cNomRel, STR0013,1, 1)
oPlan:AddColumn(cNomRel, cNomRel, STR0014,1, 3)
oPlan:AddColumn(cNomRel, cNomRel, STR0015,1, 1)


If ( !Empty(cCodEsp) .AND. (!Empty(cCodLoc)) )
	cJuntLcEp := AllTrim( STR0010 + OemToAnsi(Posicione("BAQ",1,xFilial("BAQ")+ cCodOpe + AllTrim(cCodEsp),"BAQ_DESCRI")) + " / " + STR0011 + OemToAnsi(Posicione("BB8",1,xFilial("BB8")+ cCodRda + cCodOpe + AllTrim(cCodLoc),"BB8_DESLOC")) ) 
Elseif ( !Empty(cCodEsp) )
	cJuntLcEp := AllTrim( STR0010 + OemToAnsi(Posicione("BAQ",1,xFilial("BAQ")+ cCodOpe + AllTrim(cCodEsp),"BAQ_DESCRI")) )
Elseif( !Empty(cCodLoc) )
	cJuntLcEp := AllTrim( STR0011 + OemToAnsi(Posicione("BB8",1,xFilial("BB8")+ cCodRda + cCodOpe + AllTrim(cCodLoc),"BB8_DESLOC")) )	
EndIf
 
oPlan:AddRow(cNomRel, cNomRel, {AllTrim(OemToAnsi(Posicione("BAU",1,xFilial("BAU")+ AllTrim(cCodRDA),"BAU_NOME"))) + " / " + cJuntLcEp , "","","","",""} )  //Presatdor:

//Posiciono a tabela criada na primeira posi��o
(cNomTtDad)->(DbGoTop())


//Coluna do nome do nivel
If ( !(cNomTtDad)->(EOF()) )
	While !(cNomTtDad)->(EOF()) 
		If cNomTab <> (cNomTtDad)->NIVEL
			cNomNiv := ""
			cNomTab := (cNomTtDad)->NIVEL
			If ( BMV->(DbSeek(xFilial("BMV") + "2" + AllTrim((cNomTtDad)->NIVEL) + Space((TamSX3("BMV_DESCRI")[1]-Len(Alltrim((cNomTtDad)->NIVEL)))) + cNomRotina )) )
				cNomNiv	:= Alltrim(BMV->BMV_MSGPOR)
			Else
				cNomNiv := IIF (!Empty(cNomNiv), SUBSTR(cNomNiv, 1, 260), cNomTab)
			EndIf	
					
		EndIf
		
		
		//Ajuste para exibi��o dos valroes
		If ( (cNomTtDad)->VALOR > 1)  //Significa que houve valora��o
			cValor := AllTrim(cValtochar(transform((cNomTtDad)->VALOR, "@E 999,999,999.99")))
		Else
			cValor := AllTrim("0.00")
		EndIf	
		
		//Ajuste para as unidade de medidas
		aUnidade := PlscUnidV("2", nil, Alltrim((cNomTtDad)->UNIDADE), 1, 16 ) 	
		
		//Imprime as linhas
		oPlan:AddRow(cNomRel, cNomRel, {"",cNomNiv,Alltrim((cNomTtDad)->PROCEDIM), AllTrim((cNomTtDad)->DESCRICAO), cValor, aUnidade[1]})
	(cNomTtDad)->(DbSkip())
	EndDo
	
//Sem dados - N�o foram encontrados dados. Imprime no relat�rio essa informa��o
Else	
	oPlan:AddRow(cNomRel, cNomRel, {"","",STR0003, "", "", ""})	
EndIf


//Query para buscar as legendas
aResult := PlsQrUndRl()

//Nova aba de legenda de Unidades
cLeguni	:= STR0021  //"Legenda Unidades"
oPlan:AddworkSheet(cLegUni)
oPlan:AddTable (cLegUni, cLegUni)//aDadRel[1])

//Colunas Legenda das Unidades
oPlan:AddColumn(cLegUni, cLegUni, STR0020,1, 1)
oPlan:AddColumn(cLegUni, cLegUni, STR0013,1, 1)


If ( Len(aResult) > 0)
	For nI := 1 To Len(aResult)
		//Impress�o das Legendas
		oPlan:AddRow(cLegUni, cLegUni, {AllTrim(aResult[nI,1]), Alltrim(aResult[nI,2])} )  
	Next		
EndIF 

//Gerar o XLS
oPlan:Activate()
oPlan:GetXMLFile(cCamArq)

//Envia E-mail
PLSGrvRPP(nil, lEnvMail, cEndMail, cCamArq, cOrigem, cCodOpe, cCodRda, .T.)	

Return cNomArq



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsMtJRPP
MultiThread e grava��o em tabela tempor�ria

@author  Renan Martins	
@version P12
@since   10/2016
@Obs: Par�metros da fun��o: aDados
//---------------------------------------------------------------------------------
/*/
           		
Function PlsMtJRPP (cCodRda, cCodEsp, cCodOpe, cCodTab, cTpBusca, cMes, cAno, cTpBusca, cCodLoc, cMensagem, lGeraRel, cFormRel, lEnvMail, cEndMail, cOrigem, lExbNel)

Local aInterval	:= {}
Local aFields 	:= {}
Local aValAtu		:= {}

Local cIdent		:= ""	
Local cEmpPls		:= GetNewPar("MV_EMPRPLS", "99")	// Pega a empresa de trabalho do PLS
Local cFilPls		:= PADR(GetNewPar("MV_FILIPLS", "01"),FWSizeFilial())	// Pega a filial de trabalho do PLS
Local cQuery		:= ""
Local cMensag		:= ""
Local cArqLog		:= "PlsMtJRPP_Erro_Atualizacao_Tab_tem_" + Replace(Time(),":","") + ".log"

Local lAtu			:= .F.
Local lExit		:= .F.

Local nQtd			:= 0
Local nQtdS		:= 0
Local nThreads 	:= 0
Local nCont		:= 0
Local nTime		:= 1
Local nDados		:= 0
Local nI			:= 1
Local nRec			:= 1

Local oTempTable	:= nil	

PRIVATE aThreads := {}
Private cRandVar := alltrim(STR(Randomize(1,32000)))

//Select para verificar os dados retornados
cSql := PlsTpQrRP(cTpBusca, cCodRda, cCodEsp, cCodOpe, cCodTab) 	       

//Chamo Fun��o de Query
cQuery	:= ChangeQuery(cSql)
TcQuery cQuery New Alias "ProcEnc"
Count To nReg
ProcEnc->(DbGoTop()) //posicionar de novo no primeiro

If nReg < 3000
  nThreads := 1
  nDados	:= nReg
  aInterval := {{1, nDados}}
Else 
	//tr�s threads 
	nThreads := 3 
	nDados := Ceiling(nReg / nThreads) 
	aAdd(aInterval, {1,nDados})
	aAdd(aInterval, {(nDados+1), (nDados*2)})
	aAdd(aInterval, {((nDados*2)+1),(nDados*3)})
EndIf

cIdent := cCodRDA+cRandVar

//Cria��o da Tabela Tempor�ria
cNomeL := CriaTrab(Nil, .F.)
oTempTable := FWTemporaryTable():New( cNomeL )

//--------------------------
//Monta os campos da tabela
//--------------------------
aadd(aFields,{"IDENT","C",11,0})
aadd(aFields,{"NIVEL","C",230,0})
aadd(aFields,{"TABELA","C",16,0})
aadd(aFields,{"PROCEDIM","C",16,0})
aadd(aFields,{"DESCRICAO","C",230,1})
aadd(aFields,{"VALOR","N",16,2})
aadd(aFields,{"UNIDADE","C",230,0})
aadd(aFields,{"TABGEN","C",3,0})


oTemptable:SetFields( aFields )
oTempTable:AddIndex("indice1", {"IDENT"} )
oTempTable:Create()

//Recuperar o nome f�sico da tabela tempor�ria criada no Banco de Dados
cNomTab := oTempTable:GetRealName()

While !ProcEnc->(Eof())
	cSql := " INSERT INTO " + cNomTab + " (IDENT, NIVEL, TABELA, PROCEDIM, DESCRICAO, TABGEN) "
	cSql += " VALUES ('" + cIdent +"','" + ProcEnc->TABELA + "','" + ProcEnc->CODPAD + "','" + ProcEnc->CODPRO + "','" + ProcEnc->DESCRI + "','" + ProcEnc->TBB23GEN+ "')" 
	TcSQLExec(cSql)
	ProcEnc->(DbSkip())
EndDo

ProcEnc ->(DbCloseArea())

//Percorro as Threads
For nCont := 1 To nThreads

	aadd(aThreads,{nThreads,;           				//Array com os dados de procedimentos e outras informa��es
	nDados,;
	"N",;													//Conclu�do
	aInterval[nCont,1],;                         		//de
	aInterval[nCont,2],;									//at�
	cIdent})

	//Criar vari�vel global para armazenar o status do processamento
	PutGlbValue("THR"+cIdent+STR(nCont), "N" )
	GlbUnLock()
	
Next

//Chamo jobs para processamento
For nCont := 1 To  Len(aThreads)
	//Conout de Acompanhamento
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "3) " + STR0023 , 0, 0, {})
	If !lautoSt .AND. aThreads[nCont,4] > 0		
       StartJob("PlsCttRpp",GetEnvServer(),.F., cEmpPls, cFilPls, nCont,  aThreads[nCont],  cCodRDA, cCodEsp, cCodOpe, cCodTab, cTpBusca, cMes, cAno, cIdent, cNomTab, cCodLoc, cMensagem, lExbNel)		
	elseIf lautoSt
		PlsCttRpp ("", "", nCont,  aThreads[nCont],  cCodRDA, cCodEsp, cCodOpe, cCodTab, cTpBusca, cMes, cAno, cIdent, cNomTab, cCodLoc, cMensagem, lExbNel)
	Endif
Next

//Verifica��o enquanto todas as threads n�o terminam o processamento
For nCont := 1 To nThreads
	nQtd := PlsEvlpIRPP (cNomTab, cIdent)
	While aThreads[nCont,3] <> "S"
		aThreads[nCont,3] := GetGlbValue("THR"+cIdent+STR(nCont))
		
		//Retorno de query na tabela tempor�ria. Se ap�s 4 minutos n�o houver atualiza��o nas tabelas, paro processamento, pois pode ocorrer erro e ficar em loop infinito	
		If ( (Mod(nTime, 4)) == 0 ) // a cada 4 minutos verifico resultados 
			nQtdS := PlsEvlpIRPP (cNomTab, cIdent, "1")
			If ( (nQtd > 0) .AND. (nQtd <> nQtdS) ) //Indica que est� atualizando. Se nQtd for 0, significa que a tabela toda foi atualizada
				nQtd := nQtdS
			Elseif ( (nQtd > 0) .AND. (nQtd == nQtdS) .AND. nTime > 4)
				//Quer dizer que em 4 minutos n�o houve atualiza��o. Pode ter ocorrido algum erro e finalizamos o processo.
				lExit	  := .T.
				Exit
				//lGeraRel := .F.
				//oTempTable:Delete()
				//cMensag := STR0024 + AllTrim(STR(nQtdS)) + STR0025
				//PlsLogFil(cMensag,cArqLog)
				//ConOut(STR0028)
				
			EndIf	
		EndIf
		
		sleep(60000)  // Sleep de 1 minuto
		nTime++
	EndDo
	//Sair do la�o do for, quando ocorrer algum erro e tabela tempor�ria for derrubada.
	If lExit
		Exit
	EndIf	
next


//Derrubar a tabela tempor�ria
If lExit
	oTempTable:Delete()
	lGeraRel := .F.
	cMensag := STR0024 + AllTrim(STR(nQtdS)) + STR0025
	PlsLogFil(cMensag,cArqLog)
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0028 , 0, 0, {})
EndIf	


//Chama gera��o de Relat�rio
If lGeraRel
	If (cFormRel == "1") 
		cNomArq := PLSGREPRE (cCodRDA, cCodOpe, cCodLoc, cCodEsp, cAno, cMes, lEnvMail, cEndMail, cOrigem, cNomeL)
	Else
		cNomArq := PlsGrExcRPP (cCodRDA, cCodOpe, cCodLoc, cCodEsp, cAno, cMes, lEnvMail, cEndMail, cOrigem, cNomeL)
	EndIf
Endif	
Return cNomArq



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsCttRpp
Atualiza��o da Tabela Tempor�ria

@author  Renan Martins	
@version P12
@since   10/2016
//---------------------------------------------------------------------------------
/*/
Function PlsCttRpp (cEmp, cFil, nNumThr, aThreadES, cCodRda, cCodEsp, cCodOpe, cCodTab, cTpBusca, cMes, cAno, cIdent, oTempTable, cCodLoc, cMensagem, lExbNel)
Local aFields := {}
Local aRetDad		:= {}	//Procedimentos que podem ser executados PlsAutP
Local aDadUsr 	:= {}	
Local aDadRDA 	:= {}
Local aPlsVal		:= {}	//Recebe o CalcEve ap�s autoriza��o do PlsAutP
Local aRetCal		:= {}
Local lPLSCTRPFI := ExistBlock("PLSCTRPFIM")

Local cQuery

Local nI			:= 0
Local nValor		:= 0

//Verifica se � Job, para iniciar o ambiente correto.
If (!Empty(cEmp))
	RpcSetType(3)
	rpcSetEnv(cEmp, cFil,,,'PLS',, )
EndIf
//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := " SELECT TABELA, PROCEDIM, DESCRICAO, NIVEL, TABGEN, R_E_C_N_O_ RECNO FROM " + oTempTable
cQuery += " WHERE R_E_C_N_O_ BETWEEN " + STR(aThreadES[4]) + " AND " + STR(aThreadES[5])
cQuery += " AND IDENT = '" + aThreadES[6] + "' "
MPSysOpenQuery( ChangeQuery(cQuery), 'QRYATU' )

aDadRDA := PLSDADRDA(cCodOpe, cCodRDA,'1',date(),cCodLoc,cCodEsp,,,,,,,) //locate e codesp nil

while !QRYATU->(eof())

	//C�lculo do CalcEve
	IF ( (AllTrim(QRYATU->TABELA) != ("-")) .AND. (AllTrim(QRYATU->PROCEDIM) != ("-")) )
		
		//2 - Verifico se o exame est� autorizado para a RDA.
		aRetDad := PLSAUTP(date(),,AllTrim(QRYATU->TABELA),AllTrim(QRYATU->PROCEDIM),1,aDadUsr,,aDadRDA,,.T.,,.F.,,,,,,,,,,,,,,,,,,,,,,'2')
	
		//3 - Se sim, posso chamaRplsvlr PLSCALCEVE. Se n�o, ficar� como n�o eleg�vel    
		If aRetDaD[1] // Se verdadeiro, faz valoriza��o  	
			
			aPlsVal := PLSCALCEVE (AllTrim(QRYATU->TABELA), Alltrim(QRYATU->PROCEDIM), cMes, cAno, cCodOpe,cCodRDA, cCodEsp, "",cCodLoc,1,date(),"",,,,aDadUsr)	     
		
			//Ajuste para exibi��o dos valroes
			If (aPlsVal[2] > 1)  //Significa que houve valora��o
				nValor := aPlsVal[2]
			Else
				nValor := 0
			EndIf	
			
			//Ajuste para as unidade de medidas
			aUnidade := PlscUnidV("1", aPlsVal[1], nil, 1, 16)	

			cSql := " UPDATE " + oTempTable + " SET VALOR = " + STR(nValor) + ", "
			cSql += " UNIDADE = '" + aUnidade[1] + "' " 
			cSql += " WHERE R_E_C_N_O_ = '" + STR(QRYATU->RECNO) + "'"
			TcSQLExec(cSql)
			
			//Grava a valoracao na tabela fisica - B4Z
			PlsGrvTf(cCodOpe,cCodRda,cIdent,Alltrim(QRYATU->NIVEL),AllTrim(QRYATU->TABELA),AllTrim(QRYATU->PROCEDIM),AllTrim(QRYATU->DESCRICAO),aPlsVal,nValor,QRYATU->TABGEN)
			
			//��������������������������������������������������������������Ŀ
			//�Ponto de entrada executado apos a gravacao da tabela fisica
			//����������������������������������������������������������������
			If lPLSCTRPFI 
				ExecBlock("PLSCTRPFIM",.F.,.F., {cCodOpe,cCodRda,cIdent,aPlsVal,nValor})
			EndIf		
			
		Elseif (lExbNel)  //Se deseja que saia mensagem nos n�o autorizados.
			cSql := " UPDATE " + oTempTable + " SET VALOR = " + STR(nValor) + ", "
			cSql += " UNIDADE = '" + cMensagem + "' " 
			cSql += " WHERE RECNO = '" + STR(QRYATU->RECNO) + "'"
			TcSQLExec(cSql)
			
		Endif	
	EndIf

	QRYATU->(dbskip())
Enddo

//Atualizo vari�vel global, afirmando que foi feito o processamento.
ClearGlbValue("THR"+cIdent+STR(nNumThr))
PutGlbValue("THR"+cIdent+STR(nNumThr), "S" )
GlbUnLock()

Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsEvlpIRPP
Atualiza��o da Tabela Tempor�ria

@author  Renan Martins	
@version P12
@since   11/2016
//---------------------------------------------------------------------------------
/*/
Function PlsEvlpIRPP (cNomTab, cIdentif)
Local cSql		:= ""
Local cTmpNom	:= CriaTrab(Nil, .F.)

Local nQtdTot	:= 0

//Query para verificar e contar quantos registros est�o com as unidades vazias, ou seja, ainda n�o foram calculadas
cSql := " SELECT Count(UNIDADE) TOTAL FROM " + cNomTab 
cSql += " WHERE UNIDADE = '' AND IDENT = '" + cIdentif + "' "

cSql := ChangeQuery(cSql)
TcQuery cSql New Alias cTmpNom

nQtdTot := cTmpNom->TOTAL

cTmpNom ->(DbCloseArea())

Return nQtdTot


//-------------------------------------------------------------------------------
/*/{Protheus.doc} PlsGrvTf
Grava na tabela B4Z a valora��o do procedimento
        
@author 	Leandro de Faria
@since 		24/11/2016
@version 	P12

@param		cCodOpe, string, 	Codigo da Operadora
@param		cCodRda, string, 	Codigo do RDA
@param		cIdent	, string, 	ID de execucao do JOB
@param		cNivel , string, 	Descricao Especifica para o procedimento
@param		cCodTab, string, 	Tabela
@param		cCodPro, string, 	Codigo do Procedimento
@param		cDesPro, string, 	Descricao do Procedimento
@param		aPlsVal, array,	Array contendo o retorno do PLSCALCEVE
@param		nVlrPro, string, 	Valor Procedimento
@param		cTabPrc, string, 	Tabela de preco

@return	Nil
/*/ 
//-------------------------------------------------------------------------------
Static Function PlsGrvTf(cCodOpe,cCodRda,cIdent,cNivel,cCodTab,cCodPro,cDesPro,aPlsVal,nVlrPro,cTabPrc)

Local nXi := 0 

Default cCodOpe 	:= PlsIntPad()
Default cCodRda	:= ""
Default cIdent	:= cCodRDA+alltrim(STR(Randomize(1,32000)))
Default cNivel	:= ""

//Atualiza a tabela fisica
For nXi := 1 To Len(aPlsVal[1])
		
	B4Z->(dbSetOrder(3))
	lGrv := Iif(B4Z->(dbSeek(FwFilial("B4Z")+AllTrim(cCodTab)+PadR(cCodPro,TamSx3("B4Z_CODPRO")[1])+aPlsVal[1][nXi][1]+cTabPrc+cCodOpe+cCodRda)),.F.,.T.)
			
	B4Z->(RecLock("B4Z",lGrv))
		B4Z->B4Z_FILIAL 	:= FwFilial("B4Z")
		B4Z->B4Z_CODOPE 	:= cCodOpe
		B4Z->B4Z_CODRDA 	:= cCodRda
		B4Z->B4Z_IDENT  	:= cIdent
		B4Z->B4Z_NIVEL  	:= cNivel
		B4Z->B4Z_TABELA	:= cCodTab
		B4Z->B4Z_CODPRO	:= cCodPro
		B4Z->B4Z_DESPRO	:= cDesPro
		B4Z->B4Z_TABPRE	:= cTabPrc
		B4Z->B4Z_UNIDAD	:= aPlsVal[1][nXi][1]
		B4Z->B4Z_VLRREF	:= aPlsVal[1][nXi][9]	
		B4Z->B4Z_PORTE	:= aPlsVal[1][nXi][12]
		B4Z->B4Z_VLRPRO	:= nVlrPro
		B4Z->B4Z_VLRUCO	:= Iif(Len(aPlsVal[1][nXi]) > 0 .And. aPlsVal[1][nXi][1] == "UCO",aPlsVal[1][nXi][5][1][4],0)
		B4Z->B4Z_DATA		:= dDataBase
		B4Z->B4Z_HORA		:= SubStr(Time(),1,2)+SubStr(Time(),4,2)
	B4Z->(MsUnLock())
	
Next nXi
		
Return Nil
