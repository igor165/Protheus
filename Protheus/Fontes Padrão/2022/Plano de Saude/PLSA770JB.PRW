#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA770JB ³ Autor ³ Thiago GUilherme     ³ Data ³ 29.01.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ executa a rotina de bloqueio automático		              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA770JB(aJob)

Local cCodEmp  := aJob[1]
Local cCodFil  := aJob[2]
Local cParent  := '01,03,04,05,06,07,08,09,10'

RpcSetEnv( cCodEmp, cCodFil ,,,'PLS',, )

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Inicio da execucao JOB PLSA770JB" , 0, 0, {})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de bloqueio de familia e grupo familiar                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSA770("","ZZZZ","","ZZZZ","","ZZZZZZ",1/*bloqueio financeiro*/,;
		GetNewPar("MV_JB7701","") /*data ref. financ.*/, GetNewPar("MV_JB7702","")/*mot. bloq. financ.*/, GetNewPar("MV_JB7703",2),/*Consid. data limite*/;
		GetNewPar("MV_JB7704","") /*mot. bloq. limite*/, GetNewPar("MV_JB7705",2) /*Bloq. por maiori*/, GetNewPar("MV_JB7706","")/*mot. bloq. maioridade*/,;
		cParent, GetNewPar("MV_JB7707",18)/*idade bloq maiori*/, GetNewPar("MV_JB7708",2)/*idade universitaria*/, GetNewPar("MV_JB7709","")/*data de*/,;
		dDataBase, dDataBase /*data do bloq.*/, 2 /*acao do processo*/,GetNewPar("MV_JB77010",2) /*Bloq. por casamento*/,GetNewPar("MV_JB77011",""),/*Mot. bloq. casamento*/;
		.T.)

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Fim da execucao JOB PLSA770JB" , 0, 0, {})
Return
