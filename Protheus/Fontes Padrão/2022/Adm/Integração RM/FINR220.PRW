#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "FINR220.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINR220  ³ Autor ³ Cesar Augusto Bianchi ³ Data ³ 18/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivos ³           RELATORIO MAPA RESUMO DE CAIXA               	  ³±±
±±³          ³Realiza a impressao do Mapa Resumo de Caixa a partir dos pa-³±±
±±³          ³rametros informados, utilizando as impressoras disponiveis  ³±±
±±³          ³na pasta "Impressoras" do sistema operacional ou atraves dos³±±
±±³          ³equipamentos ECF configurados na estacao em execucao.  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINR220()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function FINR220(cUser,cLote)
Local cTitulo 	:= STR0001
Local cPerg   	:= 'FIR220'   
Private aReturn := {"Zebrado", 1, "Administracao", 2, 2, 1,"",1}
Private m_pag   := 01   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a funcao seja chamada de dentro da rotina de fechamento de caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if FunName() == "FINA222" .and. valtype(cUser) == "C" .and. !Empty(cUser)
	SetMVValue(cPerg,"MV_PAR01",cUser)
	SetMVValue(cPerg,"MV_PAR02",cLote)
else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa os ultimos parametros utilizados para evitar a utilizacao de um lote com um outro usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetMVValue(cPerg,"MV_PAR01","")
	SetMVValue(cPerg,"MV_PAR02","")
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe interface do tipo "Pergunte"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
wnrel := SetPrint('FIB','FIR220',cPerg,@cTitulo,"","","",.F.,{},.F.,"P",,.F.,.F.,,,.F.,'COM1')

If nLastKey == 27
	Set Filter To
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,'FIB')
RptStatus({|lEnd| Fnr220Stp(MV_PAR01,MV_PAR02)},cTitulo)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNr220Stp ºAutor  ³Cesar A. Bianchi    º Data ³  29/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³          ³Realiza a impressao do Mapa Resumo de Caixa a partir dos pa-³±±
±±³          ³rametros informados, utilizando as impressoras disponiveis  ³±±
±±³          ³na pasta "Impressoras" do sistema operacional - SETPRINT    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FNr220Stp(cUser,cLote)
Local cCodCxa := Posicione('FID',1,xFilial('FID')+cUser,"FID_NCAIXA")                                                 
Local cEfeDN := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))
Local cEfeCH := alltrim(Transform(FN222Calc(cCodCxa,cLote,'2',.F.),"@E 999,999,999.99"))
Local cEfeCC := alltrim(Transform(FN222Calc(cCodCxa,cLote,'4',.F.),"@E 999,999,999.99"))
Local cEfeCD := alltrim(Transform(FN222Calc(cCodCxa,cLote,'3',.F.),"@E 999,999,999.99"))
Local cEfeNC := alltrim(Transform(FN222Calc(cCodCxa,cLote,'5',.F.),"@E 999,999,999.99"))
Local cEfeTt := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + FN222Calc(cCodCxa,cLote,'2',.F.) + FN222Calc(cCodCxa,cLote,'3',.F.) + FN222Calc(cCodCxa,cLote,'4',.F.)+ FN222Calc(cCodCxa,cLote,'5',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))

Local cReaDN := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"),"@E 999,999,999.99"))
Local cReaCH := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH"),"@E 999,999,999.99"))
Local cReaCC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC"),"@E 999,999,999.99"))
Local cReaCD := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD"),"@E 999,999,999.99"))
Local cReaNC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC"),"@E 999,999,999.99"))
Local cReaTt := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC"),"@E 999,999,999.99"))

Local cDifDN := alltrim(Transform( -1 * (iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0) + (FN222Calc(cCodCxa,cLote,'1',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"))) , "@E 999,999,999.99"))
Local cDifCH := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'2',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")) ,"@E 999,999,999.99"))
Local cDifCC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'4',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")) ,"@E 999,999,999.99"))
Local cDifCD := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'3',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD")) ,"@E 999,999,999.99"))
Local cDifNC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'5',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC")) ,"@E 999,999,999.99"))

Local cDtAbre := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTABR"))
Local cHrAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRABR")
Local cDtFech := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTFCH"))
Local cHrFech := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRFCH")    

Local cTpAbre := iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPABRE") == "S",STR0002,STR0003) 
Local cUsAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USABRE")
Local cTpFecha:= iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPFECH") == "S",STR0002,STR0003) 
Local cUsFecha:= Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USFECH") 

Local cVlrIni := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR") ,"@E 999,999,999.99"))
Local cTotCxa := cReaTt

Private Li     := 01  
Private ColA   := 01 
Private ColB   := 26

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Nome dos usuarios Abre. Caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cUsAbre  := substr( alltrim(cUsAbre)  + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsAbre,"FID_NOME")),1,22)
cUsFecha := substr( alltrim(cUsFecha) + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsFecha,"FID_NOME")),1,20)
cCodCxa  := alltrim(cCodCxa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o Cabecalho Inicial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ Li++,ColA PSAY Replicate('#',40)
@ Li++,ColA PSAY STR0004 					//MAPA RESUMO DE CAIXA"
@ Li++,ColA PSAY Replicate('#',40)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados iniciais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FNR220Conv(STR0005,cCodCxa,.F.)	 			//Caixa
FNR220Conv(STR0006,cUser,.F.) 				//Usuario
FNR220Conv(STR0007,cLote,.F.) 				//Lote                          '
FNR220Conv(STR0008,cDtAbre,.F.) 			//Data Abertura
FNR220Conv(STR0009,cHrAbre,.F.) 			//Hora Abertura
FNR220Conv(STR0010,cDtFech,.F.) 			//Data Fechamento
FNR220Conv(STR0011,cHrFech,.F.) 			//Hora Fechamento
FNR220Conv(STR0012,cTotCxa,.F.)			 	//Total em Caixa
FNR220Conv(STR0013,cTpAbre,.F.) 			//Tipo de Abertura
FNR220Conv(STR0014,cUsAbre,.F.) 			//Usuario Abertura
FNR220Conv(STR0015,cTpFecha,.F.)			//Tipo de Fechamento:
FNR220Conv(STR0016,cUsFecha,.F.)			//Usuario Fechamento:
If GetNewPar('MV_FINTRC',.F.)
	FNR220Conv(STR0017,cVlrIni,.F.)				//Valor Inicial:
EndIf
FNR220Conv(STR0018,dtoc(dDatabase),.F.)	//Data Impressao:
FNR220Conv(STR0019,Time(),.F.)        		//Hora Impressao:
                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os "Valores Efetivados'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ Li++ ,ColA PSAY Replicate('_',40)
@ Li++ ,ColA PSAY STR0020					//VALORES EFETIVADOS EM CAIXA
@ Li++ ,ColA PSAY Replicate('_',40) 
FNR220Conv(STR0021,cEfeDN,.F.)           	//Total Dinheiro
FNR220Conv(STR0022,cEfeCH,.F.)             //Total Cheques
FNR220Conv(STR0023,cEfeCC,.F.)             //Total Cartao Credito
FNR220Conv(STR0024,cEfeCD,.F.)             //Total Cartao Debito
FNR220Conv(STR0034,cEfeNC,.F.)             //Total NCC
FNR220Conv(STR0025,cEfeTt,.F.)             //Total Geral Efetivado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os "Valores Reais'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ Li++ ,ColA PSAY Replicate('_',40)
@ Li++ ,ColA PSAY STR0027 					//VALORES REAIS EM CAIXA
@ Li++ ,ColA PSAY Replicate('_',40)
FNR220Conv(STR0021,cReaDN,.F.)				//Total Dinheiro
FNR220Conv(STR0022,cReaCH,.F.)				//Total Cheques
FNR220Conv(STR0023,cReaCC,.F.)				//Total Cartao Credito
FNR220Conv(STR0024,cReaCD,.F.)				//Total Cartao Debito
FNR220Conv(STR0034,cReaNC,.F.)             //Total NCC
FNR220Conv(STR0026,cReaTt,.F.)				//Total Geral Real

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as "Diferencas'   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ Li++ ,ColA PSAY Replicate('_',40)
@ Li++ ,ColA PSAY STR0028 					//DIFERENCAS EM CAIXA
@ Li++ ,ColA PSAY Replicate('_',40)
FNR220Conv(STR0029,cDifDN,.F.)				//Dinheiro:
FNR220Conv(STR0030,cDifCH,.F.)				//Cheques:
FNR220Conv(STR0031,cDifCC,.F.)				//Cartao Credito
FNR220Conv(STR0035,cDifNC,.F.)             //NCC:
FNR220Conv(STR0032,cDifCD,.F.)				//Cartao Debito

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o Rodape³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Li++
Li++
@ Li++ ,ColA PSAY Replicate('-',40)
@ Li++ ,ColA PSAY Replicate('#',16) + STR0033 + Replicate('#',17) //Final

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe o relatorio em tela caso a impressao seja em disco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] = 1
   	Set Device to Screen
   	Set Printer To 
   	dbCommitAll()
   	OurSpool(wnrel)
Endif

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNR220Ecf ºAutor  ³Cesar A. Bianchi    º Data ³  29/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Desc.     ³Realiza a impressao do Mapa Resumo de Caixa a partir dos pa-º±±
±±³          ³rametros informados, utilizando os equipamentos perifericos º±±
±±³          ³ECF configurados na estacao em execucao.		 	          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Observac. ³Por motivos de seguranca, a cada 10 linhas impressas atravesº±±
±±³          ³do equipamento ECF, automaticamente sera impressa uma linha º±±
±±³          ³com os dizeres "NAO E DOCUMENTO FISCAL" ou outra frase seme-º±±
±±³          ³lhante, dependendo da marca do ECF utilizado. Esta acao eh  º±±
±±³          ³realizada automaticamente pela ECF, conforme legislacoes em º±±
±±³          ³vigor, para nao permitir a impressao de documentos nao-fiscaº±±
±±³          ³is atraves do ECF. Maiores informacoes consultar suporte da º±±
±±³          ³celula de automacao comercial. (GDP SIGALOJA)			      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fnr220Ecf(cUser,cLote)
Local cImprime := "" 
Local cPulaLin := Chr(13) + Chr(10)
Local cCodCxa := Posicione('FID',1,xFilial('FID')+cUser,"FID_NCAIXA")                                                 

Local cEfeDN := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))
Local cEfeCH := alltrim(Transform(FN222Calc(cCodCxa,cLote,'2',.F.),"@E 999,999,999.99"))
Local cEfeCC := alltrim(Transform(FN222Calc(cCodCxa,cLote,'4',.F.),"@E 999,999,999.99"))
Local cEfeCD := alltrim(Transform(FN222Calc(cCodCxa,cLote,'3',.F.),"@E 999,999,999.99"))
Local cEfeNc := alltrim(Transform(FN222Calc(cCodCxa,cLote,'5',.F.),"@E 999,999,999.99"))
Local cEfeTt := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + FN222Calc(cCodCxa,cLote,'2',.F.) + FN222Calc(cCodCxa,cLote,'3',.F.) + FN222Calc(cCodCxa,cLote,'4',.F.) + FN222Calc(cCodCxa,cLote,'5',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))

Local cReaDN := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"),"@E 999,999,999.99"))
Local cReaCH := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH"),"@E 999,999,999.99"))
Local cReaCC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC"),"@E 999,999,999.99"))
Local cReaCD := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD"),"@E 999,999,999.99"))
Local cReaNC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC"),"@E 999,999,999.99"))
Local cReaTt := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD"),"@E 999,999,999.99"))

Local cDifDN := alltrim(Transform( -1 * ( iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0) + (FN222Calc(cCodCxa,cLote,'1',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"))) , "@E 999,999,999.99"))
Local cDifCH := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'2',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")) ,"@E 999,999,999.99"))
Local cDifCC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'4',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")) ,"@E 999,999,999.99"))
Local cDifCD := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'3',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD")) ,"@E 999,999,999.99"))
Local cDifNC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'5',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC")) ,"@E 999,999,999.99"))

Local cDtAbre := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTABR"))
Local cHrAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRABR")
Local cDtFech := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTFCH"))
Local cHrFech := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRFCH")    

Local cTpAbre := iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPABRE") == "S","SUPERVISOR","OPERADOR") 
Local cUsAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USABRE") 
Local cTpFecha:= iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPFECH") == "S","SUPERVISOR","OPERADOR") 
Local cUsFecha:= Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USFECH") 

Local cVlrIni := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR") ,"@E 999,999,999.99"))
Local cTotCxa := cReaTt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Nome dos usuarios Abre. Caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cUsAbre  := substr( alltrim(cUsAbre)  + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsAbre,"FID_NOME")),1,22)
cUsFecha := substr( alltrim(cUsFecha) + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsFecha,"FID_NOME")),1,20)
cCodCxa  := alltrim(cCodCxa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o Cabecalho Inicial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprime := Replicate('#',40) + cPulaLin
cImprime += STR0004  + cPulaLin //MAPA RESUMO DE CAIXA"
cImprime +=  Replicate('#',40) + cPulaLin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados iniciais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprime += FNR220Conv(STR0005,cCodCxa,.T.)	 		//Caixa
cImprime += FNR220Conv(STR0006,cUser,.T.) 				//Usuario
cImprime += FNR220Conv(STR0007,cLote,.T.) 				//Lote
cImprime += FNR220Conv(STR0008,cDtAbre,.T.) 			//Data Abertura
cImprime += FNR220Conv(STR0009,cHrAbre,.T.) 			//Hora Abertura
cImprime += FNR220Conv(STR0010,cDtFech,.T.) 			//Data Fechamento
cImprime += FNR220Conv(STR0011,cHrFech,.T.) 			//Hora Fechamento
cImprime += FNR220Conv(STR0012,cTotCxa,.T.)			//Total em Caixa
cImprime += FNR220Conv(STR0013,cTpAbre,.T.) 			//Tipo de Abertura
cImprime += FNR220Conv(STR0014,cUsAbre,.T.) 			//Usuario Abertura
cImprime += FNR220Conv(STR0015,cTpFecha,.T.)			//Tipo de Fechamento:
cImprime += FNR220Conv(STR0016,cUsFecha,.T.)			//Usuario Fechamento:
cImprime += FNR220Conv(STR0017,cVlrIni,.T.)			//Valor Inicial:
cImprime += FNR220Conv(STR0018,dtoc(dDatabase),.T.)	//Data Impressao:
cImprime += FNR220Conv(STR0019,Time(),.T.)        		//Hora Impressao:
                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os "Valores Efetivados'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprime += Replicate('_',40) + cPulaLin
cImprime += STR0020 + cPulaLin 							//VALORES EFETIVADOS EM CAIXA
cImprime += Replicate('_',40)  + cPulaLin
cImprime += FNR220Conv(STR0021,cEfeDN,.T.)           	//Total Dinheiro
cImprime += FNR220Conv(STR0022,cEfeCH,.T.)             //Total Cheques
cImprime += FNR220Conv(STR0023,cEfeCC,.T.)             //Total Cartao Credito
cImprime += FNR220Conv(STR0024,cEfeCD,.T.)             //Total Cartao Debito
cImprime += FNR220Conv(STR0034,cEfeNC,.T.)             //Total NCC
cImprime += FNR220Conv(STR0025,cEfeTt,.T.)             //Total Geral Efetivado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os "Valores Reais'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprime += Replicate('_',40) + cPulaLin
cImprime += STR0027  + cPulaLin							//VALORES REAIS EM CAIXA
cImprime += Replicate('_',40) + cPulaLin
cImprime += FNR220Conv(STR0021,cReaDN,.T.)				//Total Dinheiro
cImprime += FNR220Conv(STR0022,cReaCH,.T.)				//Total Cheques
cImprime += FNR220Conv(STR0023,cReaCC,.T.)				//Total Cartao Credito
cImprime += FNR220Conv(STR0024,cReaCD,.T.)				//Total Cartao Debito
cImprime += FNR220Conv(STR0034,cReaNC,.T.)             //Total NCC
cImprime += FNR220Conv(STR0026,cReaTt,.T.)				//Total Geral Real

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as "Diferencas'   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprime += Replicate('_',40) + cPulaLin
cImprime += STR0028  + cPulaLin							//DIFERENCAS EM CAIXA
cImprime += Replicate('_',40) + cPulaLin
cImprime += FNR220Conv(STR0029,cDifDN,.T.)				//Dinheiro:
cImprime += FNR220Conv(STR0030,cDifCH,.T.)				//Cheques:
cImprime += FNR220Conv(STR0031,cDifCC,.T.)				//Cartao Credito
cImprime += FNR220Conv(STR0032,cDifCD,.T.)				//Cartao Debito
cImprime += FNR220Conv(STR0035,cDifNC,.T.)             //Total Cartao Debito

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o Rodape³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprime += Replicate('-',40) + cPulaLin
cImprime += Replicate('#',16) + STR0033 + Replicate('#',17)  + cPulaLin //Final

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao via funcao de Relatorio Nao-Gerencial - SIGALOJA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IFRelGer( nHdlECF, cImprime ,1)
                                   
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNR220ConvºAutor  ³Cesar A. Bianchi    º Data ³  07/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a conversao e impressao dos textos + dados de uma   º±±
±±º          ³linha no relatorio SetPrint. Realiza o controle de alinhamenº±±
±±º          ³mento a direita.											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FNR220Conv(cItem,cValor,lRet)

Local cRet := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro cValor nao pode ter mais que 15 caracteres³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cValor := substr(cValor,1,15)  

if !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a funcao seja utilizada para o Relatorio SetPrint³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ Li ,ColA PSAY cItem + Replicate(" ",25-len(cItem))
	@ Li ,ColB PSAY Replicate(" ",15-len(cValor)) + cValor
	Li++
	Return
else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a funcao seja utilizada para o Relatorio ECF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := cItem + Replicate(" ",25-len(cItem))
	cRet += Replicate(" ",15-len(cValor)) + cValor	
	cRet += Chr(13) + Chr(10)
	Return cRet
endif

Return
