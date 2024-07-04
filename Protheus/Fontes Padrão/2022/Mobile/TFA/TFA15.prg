#INCLUDE "TFA15.ch"
#include "eADVPL.ch"

//Validacao dos campos obrigatorios do Atendimento
Function VrfAtendOS(cNrOS,cSeq,dDataCheg,cHoraCheg,dDataSaida,cHoraSaida,dDataInicio,cHoraInicio,dDataTermino,cHoraTermino,cOcorrencia)

If Empty(cNrOS)
	MsgStop(STR0001,STR0002) //"Campo Nr. OS em branco"###"Aviso"
	return .F.
Endif

If Empty(cSeq)
	MsgStop(STR0003,STR0002) //"Campo Sequencia em branco"###"Aviso"
	return .F.
Endif

If Empty(dDataCheg)
	MsgStop(STR0004,STR0002) //"Campo Data Chegada em branco"###"Aviso"
	return .F.
Endif

If Empty(cHoraCheg)
	MsgStop(STR0005,STR0002) //"Campo Hora Chegada em branco"###"Aviso"
	return .F.
Endif

If Empty(dDataSaida)
	MsgStop(STR0006,STR0002) //"Campo Data Saída em branco"###"Aviso"
	return .F.
Endif

If Empty(cHoraSaida)
	MsgStop(STR0007,STR0002) //"Campo Hora Saída em branco"###"Aviso"
	return .F.
Endif

If Empty(dDataInicio)
	MsgStop(STR0008,STR0002) //"Campo Data Início em branco"###"Aviso"
	return .F.
Endif

If Empty(cHoraInicio)
	MsgStop(STR0009,STR0002) //"Campo Hora Início em branco"###"Aviso"
	return .F.
Endif               

If Empty(dDataTermino)
	MsgStop(STR0010,STR0002) //"Campo Data Término em branco"###"Aviso"
	return .F.
Endif                

If Empty(cHoraTermino)
	MsgStop(STR0011,STR0002) //"Campo Hora Término em branco"###"Aviso"
	return .F.
Endif                

//Alert(cCodOcorr)
If Empty(cOcorrencia)
	MsgStop(STR0012,STR0002) //"Campo Ocorrência em branco"###"Aviso"
	return .F.
Endif

Return .T.

/*************************************** NOVA OS *******************************************
 Qdo. for nova OS, gravar os arquivos: 												   
 OS (AB6), Itens da OS (AB7), Agenda (ABB), Tecnicos (AA1) e Datas (DTA)                  
*******************************************************************************************/
Function GrvNovaOS(lnova_os,cOSTmp,cDataIni,cCodTec,cHoraInicio,dDataTermino,cHoraTermino,cTotais,cCodCli,cLoja,dDataInicio,cNrOS,cCodpro,cNrSerie,cCodOcorr,nProximaOS)
If lnova_os	
	dbSelectArea("ABB")
	dbSetOrder(3)
	dbSeek(cOSTmp + cDataIni)
	If ABB->(!Found())
		dbappend()
		ABB->ABB_CODTEC := cCodTec
		ABB->ABB_NUMOS  := cOSTmp
		ABB->ABB_DTINI  := cDataIni
		ABB->ABB_HRINI  := cHoraInicio
		ABB->ABB_DTFIM  := Substr(DTOC(dDataTermino),7,4) + Substr(DTOC(dDataTermino),4,2) + Substr(DTOC(dDataTermino),1,2)
		ABB->ABB_HRFIM  := cHoraTermino
		ABB->ABB_HRTOT	:= cTotais
		ABB->ABB_OBSERV	:= "OS INCLUIDA EM CAMPO"
		dbcommit()
	Endif     	
	
	dbSelectArea("AB6")
	dbSetOrder(1)
	dbSeek(cOSTmp)
	If AB6->(!Found())
		dbappend()
		AB6->AB6_NUMOS 	:= cOSTmp
		AB6->AB6_CODCLI	:= cCodCli
		AB6->AB6_LOJA	:= cLoja
		AB6->AB6_EMISSA	:= dDataInicio
		AB6->AB6_MSG 	:= "OS NOVA"	
		dbcommit()
	EndIf
	    
	dbSelectArea("AB7")
	dbSetOrder(1)
	dbSeek(cNrOS)
	If AB7->(!Found())
		dbappend()
		AB7->AB7_NUMOS  := cOSTmp
		AB7->AB7_ITEM   := Substr(cNrOS,7,2)
		AB7->AB7_TIPO   := "1"	//Em atendimento/aberta
		AB7->AB7_CODPRO := cCodpro
		AB7->AB7_NUMSER := cNrSerie
		AB7->AB7_CODPRB := cCodOcorr
		AB7->AB7_MEMO3 	:= "NOVO"
		AB7->AB7_CODCLI := cCodCli
		AB7->AB7_LOJA   := cLoja
		dbcommit()	
	EndIf
	
	/*dbSelectArea("DTA")
	dbSetOrder(1)
	dbSeek(cDataIni)
	If DTA->(!Found())
		dbappend()
		DTA->DT_INI    := cDataIni
		DTA->NUMERO_OS := cOSTmp
		dbcommit()
	Endif*/
    
	nProximaOS := val(cOSTmp) + 1
	dbSelectArea("AA1")
	AA1->AA1_PROXOS := StrZero(nProximaOS,6)
	//Alert("Prox.: " + AA1->AA1_PROXOS)
Endif
Return nil


Function Agenda()
Local oDlg, oBrw, oCol, oBtFechar
Local aAgenda := {}
Local cDataIni:="", cDataFim:=""

MsgStatus(STR0013) //"Por favor, aguarde..."

dbSelectArea("ABB")
dbSetOrder(1)
dbGoTop()

While !ABB->(Eof())
	cDataIni := Substr(ABB->ABB_DTINI,7,2) + "/" +  Substr(ABB->ABB_DTINI,5,2) + "/" + Substr(ABB->ABB_DTINI,1,4)
	cDataFim := Substr(ABB->ABB_DTFIM,7,2) + "/" +  Substr(ABB->ABB_DTFIM,5,2) + "/" + Substr(ABB->ABB_DTFIM,1,4)
	//Carregar dados no array
	AADD(aAgenda,{ABB->ABB_NUMOS, cDataIni, ABB->ABB_HRINI, cDataFim, ABB->ABB_HRFIM, ABB->ABB_OBSERV })
	ABB->(dbSkip())
Enddo

ClearStatus()

DEFINE DIALOG oDlg TITLE STR0014 //"Agenda do Técnico"

@ 22,02 BROWSE oBrw SIZE 155,105 ACTION AbreObs(oBrw,aAgenda) OF oDlg
SET BROWSE oBrw ARRAY aAgenda
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0015 WIDTH 35 //"O.S."
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0016 WIDTH 60 //"Dt.Inicio"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0017 WIDTH 37 //"Hr.Inicio"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0018 WIDTH 60 //"Dt.Fim"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 5 HEADER STR0019 WIDTH 37 //"Hr.Fim"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6 HEADER STR0020 WIDTH 90 //"Observ."

@ 138,48 BUTTON oBtFechar CAPTION STR0021 ACTION CloseDialog() SIZE 60,14 of oDlg //"Fechar"

ACTIVATE DIALOG oDlg

Return nil


Function AbreObs(oBrw,aAgenda)

Local oDlgObs,oBtFechar   
Local nColuna := GridCol(oBrw)
Local nLinha  := GridRow(oBrw) 
Local cObs := ""

If nLinha == 0 
	return nil	
ElseIf nColuna <> 6
	return nil
Else
	cObs := aAgenda[nLinha,6]
Endif         

DEFINE DIALOG oDlgObs TITLE "Agenda/Obs."

@ 23,03 TO 120,156 CAPTION "Observacao" OF oDlgObs
@ 30,05 GET oGet VAR cObs READONLY MULTILINE VSCROLL SIZE 140,80 of oDlgObs
@ 138,48 BUTTON oBtFechar CAPTION STR0021 ACTION CloseDialog() SIZE 60,14 of oDlgObs //"Fechar"

ACTIVATE DIALOG oDlgObs

Return nil
