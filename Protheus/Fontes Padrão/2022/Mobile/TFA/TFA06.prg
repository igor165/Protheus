#INCLUDE "TFA06.ch"
#include "eADVPL.ch"

/*********************************** ATENDIMENTO *****************************************/
Function Atendimento(aOS, nOS, dDataBase, oData, oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem, lnova_os)

Local oDlg, oSay, oGet, oFld1, oFld2, oFld3
Local cSeq := "01 ", cNrOS := "", nOStemp := 0
Local dDataCheg := Date(), dDataSaida := Date(), dDataInicio := Date(), dDataTermino := Date() 
Local cHoraCheg := Substr(Time(),1,5), cHoraSaida := Substr(Time(),1,5), cHoraInicio := Substr(Time(),1,5), cHoraTermino := Substr(Time(),1,5)
Local oCancelarBt, oDtChegBt, oDtSaidaBt, oDtInicioBt, oDtTerminoBt
Local oBtHrCheg, oBtHrSai, oGetHrCheg, oGetHrSai
Local oBtHrIni, oGetHrIni, oBtHrTerm, oGetHrTerm
Local cLaudo := space(400), cGarantia := "", oClienteBt, oClienteLb
Local oOcorrenciaBt, oOcorrLb, cOcorrencia := "", cCliente := space(1)

Local cNrSerie := space(18), cTotais := space(10), oSerieTx
Local aStatus := {STR0001,STR0002}, nStatus := 1, lGarantia := .f. //"1 - Encerrada"###"2 - Em aberto"
Local oGravarBt, oSerieBt, oTrasladoBt, oStatus, oGarantia, oTrasladoTx
Local oDtChegTx, oDtSaidaTx, oDtInicioTx, oDtTermTx, oGetLaudo, oLaudoBt
Local cTraslado := space(10), oTotalTx, oTotalBt
Local aCmpCli:={}, aIndCli:={}, aCmpOco:={}, aIndOco:={}

If Len(aOS) == 0 .And. !lnova_os
	return nil
EndIf                            

Set(_SET_DATEFORMAT,"dd/mm/yyyy")

//Consulta Padrao de Clientes
Aadd(aCmpCli,{STR0003,SA1->(FieldPos("A1_COD")),40}) //"Código"
Aadd(aCmpCli,{STR0004, SA1->(FieldPos("A1_NOME")),90}) //"Nome"
Aadd(aIndCli,{STR0003,1}) //"Código"
Aadd(aIndCli,{STR0004,2}) //"Nome"
                        
//Consulta Padrao de Ocorrencias
Aadd(aCmpOco,{STR0003,AAG->(FieldPos("AAG_CODPRB")),40}) //"Código"
Aadd(aCmpOco,{STR0005,AAG->(FieldPos("AAG_DESCRI")),90}) //"Descrição"
Aadd(aIndOco,{STR0003,1}) //"Código"
Aadd(aIndOco,{STR0005,2}) //"Descrição"

MsgStatus(STR0006) //"Por favor, aguarde..."

//Nova OS (buscar o prox. nr. de OS)
If lnova_os 
	nOStemp := 0 
	cNrItem := "01"
	dbSelectArea("AA1")
	cOS := AA1->AA1_PROXOS	
	If Empty(cOS)
		cOS := "000001"
	EndIf
	
	dbSelectArea("AB6")
	dbSetOrder(1)
	dbSeek(cOS)
	If AB6->(Found())
		//Alert("Achou...")
		While !Eof() .And. AB6->(Found())
			nOStemp := Val(Substr(cOS,1,6)) + 1			
			cOS 	:= StrZero(nOStemp,6)
			//Alert("Nr. OS: " + cOS)
		
			dbSelectArea("AB6")
			dbSetOrder(1)
			dbSeek(cOS)
		Enddo	         
	EndIf

EndIf

If !lnova_os
	cTraslado := SA1->A1_TMPSTD     	
Endif

cNrOS := cOS + cNrItem	

//Verificar se ja existe atendimento p/ esta OS (e carregar dados)
dbSelectArea("AB9")
dbSetOrder(2)
dbSeek(cNrOS+cSeq)
If AB9->(Found())

	dDataCheg 	:= AB9->AB9_DTCHEG 
	cHoraCheg 	:= AB9->AB9_HRCHEG 
	dDataSaida 	:= AB9->AB9_DTSAID 
	cHoraSaida 	:= AB9->AB9_HRSAID 
	dDataInicio := AB9->AB9_DTINI
	cHoraInicio := AB9->AB9_HRINI
	dDataTermino:= AB9->AB9_DTFIM
	cHoraTermino:= AB9->AB9_HRFIM
	cTraslado 	:= AB9->AB9_TRASLA
	cOcorrencia := AB9->AB9_CODPRB
	cGarantia 	:= AB9->AB9_GARANT
	If cGarantia == "S"
		lGarantia := .t.
	Else                
		lGarantia := .f.
	Endif	
//	aStatus[nStatus]:= AB9->AB9_TIPO
	cNrSerie 		:= AB9->AB9_NUMSER
	cLaudo 			:= AB9->AB9_MEMO2
	cTotais 		:= AB9->AB9_TOTFAT
    
	/*dbSelectArea("AAG")
	dbSetOrder(1)
	dbSeek(cOcorrencia)
	If AAG->(Found())
		cOcorrencia := AAG->AAG_DESCRI	
	Endif*/
EndIf


DEFINE DIALOG oDlg TITLE STR0007 //"Atendimento"

//Primeiro folder de Atendimento
ADD FOLDER oFld1 CAPTION STR0008 OF oDlg  //"Atend1"
         
#ifdef __PALM__
	@ 18,02 SAY oSay PROMPT STR0009 BOLD of oFld1 //"Nr. OS:"
#else
	@ 18,02 SAY oSay PROMPT STR0009 of oFld1 //"Nr. OS:"
#endif

@ 18,40 GET oGet VAR cNrOS READONLY NO UNDERLINE of oFld1
@ 18,110 SAY oSay PROMPT STR0010 of oFld1 //"Seq.:"
@ 18,130 GET oGet VAR cSeq of oFld1
@ 33,02 BUTTON oDtChegBt CAPTION STR0011 SIZE 70,12 ACTION DtChegada(oDtChegTx,dDataCheg) of oFld1 //"Data Chegada:"
@ 33,80 BUTTON oDtSaidaBt CAPTION STR0012 SIZE 70,12 ACTION DtSaida(oDtSaidaTx, dDataSaida) of oFld1 //"Data Saída:"

#ifdef __PALM__
	@ 48,15 GET oDtChegTx VAR dDataCheg of oFld1
	@ 48,95 GET oDtSaidaTx VAR dDataSaida of oFld1
#else
	@ 48,05 GET oDtChegTx VAR dDataCheg of oFld1
	@ 48,85 GET oDtSaidaTx VAR dDataSaida of oFld1
#endif

//@ 60,02 SAY oSay PROMPT "Hora Chegada/Saída:" of oFld1
@ 60,02 BUTTON oBtHrCheg CAPTION STR0013 ACTION Keyb_Alfa(oGetHrCheg) of oFld1 //"Hr.Cheg"
#ifdef __PALM__
	@ 60,44 GET oGetHrCheg VAR cHoraCheg of oFld1
#else
	@ 60,41 GET oGetHrCheg VAR cHoraCheg of oFld1
#endif

@ 60,80 BUTTON oBtHrSai CAPTION STR0014 ACTION Keyb_Alfa(oGetHrSai) of oFld1 //"Hr.Saida"
@ 60,128 GET oGetHrSai VAR cHoraSaida of oFld1

@ 75,02 BUTTON oDtInicioBt CAPTION STR0015 SIZE 70,12 ACTION DtInicio(oDtInicioTx,dDataInicio) of oFld1 //"Data Início:"
@ 75,80 BUTTON oDtTerminoBt CAPTION STR0016 SIZE 70,12 ACTION DtTermino(oDtTermTx,dDataTermino) of oFld1 //"Data Término:"

#ifdef __PALM__
	@ 90,15 GET oDtInicioTx VAR dDataInicio of oFld1
	@ 90,95 GET oDtTermTx VAR dDataTermino of oFld1
#else
	@ 90,05 GET oDtInicioTx VAR dDataInicio of oFld1
	@ 90,85 GET oDtTermTx VAR dDataTermino of oFld1
#endif

@ 105,02 BUTTON oBtHrIni CAPTION STR0017 ACTION Keyb_Alfa(oGetHrIni) of oFld1 //"Hr.Inic"
#ifdef __PALM__
	@ 105,44 GET oGetHrIni VAR cHoraInicio of oFld1
#else
	@ 105,41 GET oGetHrIni VAR cHoraInicio of oFld1
#endif                                                                        

@ 105,080 BUTTON oBtHrTerm CAPTION STR0018 ACTION Keyb_Alfa(oGetHrTerm) of oFld1 //"Hr.Térm"
@ 105,128 GET oGetHrTerm VAR cHoraTermino of oFld1

@ 120,02 BUTTON oCancelarBt CAPTION STR0019 SIZE 40,12 ACTION CloseDialog() of oFld1 //"Cancelar"
                               

//Segundo folder de Atendimento
ADD FOLDER oFld2 CAPTION STR0020 OF oDlg  //"Atend2"

@ 18,60 GET oOcorrLb VAR cOcorrencia READONLY SIZE 90,12 of oFld2
@ 18,02 BUTTON oOcorrenciaBt CAPTION STR0021 SIZE 50,12 ACTION SFConsPadrao("AAG",cOcorrencia,oOcorrLb,aCmpOco,aIndOco,) Of oFld2 //"Ocorrência"
//ConsOcorrencia(cOcorrencia, oOcorrLb)

If lnova_os
	@ 33,02 BUTTON oClienteBt CAPTION STR0022 SIZE 40,12 ACTION SFConsPadrao("SA1",cCliente,oClienteLb,aCmpCli,aIndCli,) of oFld2 //"Cliente"
	//ConsCliente(cCliente, oClienteLb, cTraslado, oTrasladoTx)
	@ 33,50 GET oClienteLb VAR cCliente READONLY SIZE 100,12 of oFld2
EndIf

@ 50,02 BUTTON oLaudoBt CAPTION STR0023 ACTION Keyb_Alfa(oGetLaudo) of oFld2 //"Laudo"
#ifdef __PALM__
	@ 63,02 GET oGetLaudo VAR cLaudo MULTILINE VSCROLL SIZE 152,55 of oFld2
#else
	@ 63,02 GET oGetLaudo VAR cLaudo MULTILINE VSCROLL SIZE 152,55 of oFld2
#endif


//Terceiro Folder de Atendimento
ADD FOLDER oFld3 CAPTION STR0024 ON ACTIVATE ExibeTraslado(lnova_os,cCliente,cTraslado,oTrasladoTx) OF oDlg //"Atend3"

@ 18,02 CHECKBOX oGarantia VAR lGarantia CAPTION STR0025 of oFld3 //"Garantia"
@ 38,53 GET oSerieTx VAR cNrSerie of oFld3
@ 38,02 BUTTON oSerieBt CAPTION STR0026 SIZE 45,12 ACTION Keyb_Num(oSerieTx) of oFld3 //"Nr Série"
@ 58,02 SAY oSay PROMPT STR0027 of oFld3 //"Status:"
@ 58,45 COMBOBOX oStatus VAR nStatus ITEMS aStatus SIZE 75,30 of oFld3
@ 78,02 BUTTON oTrasladoBt CAPTION STR0028 ACTION Keyb_Alfa(oTrasladoTx) of oFld3 //"Traslado"
#ifdef __PALM__
	@ 78,56 GET oTrasladoTx VAR cTraslado of oFld3
#else   
	If Empty(cTraslado)
		cTraslado := space(10)	
	Endif
	@ 78,56 GET oTrasladoTx VAR cTraslado of oFld3
#endif

@ 98,02 BUTTON oTotalBt CAPTION STR0029 SIZE 48,12 ACTION CalculaHoras(cHoraInicio, cHoraTermino, dDataInicio, dDataTermino, cTraslado, cTotais, oTotalTx) of oFld3 //"Hrs Totais:"
@ 98,56 GET oTotalTx VAR cTotais of oFld3
@ 118,02 BUTTON oGravarBt CAPTION STR0030 SIZE 35,12 ACTION GravaOS(lnova_os, cNrOs, cSeq, @dDataBase, cHoraCheg, cHoraSaida, dDataCheg, dDataSaida, cHoraInicio, cHoraTermino, dDataInicio, dDataTermino, cOcorrencia, cLaudo, cCliente, lGarantia, cNrSerie, aStatus[nStatus], cTraslado, cTotais) of oFld3 //"Gravar"

CalculaHoras(cHoraInicio, cHoraTermino, dDataInicio, dDataTermino, cTraslado, cTotais, oTotalTx) 
ClearStatus()

ACTIVATE DIALOG oDlg

//Recarrega/atualiza browse de O.S. (ao sair da tela de Atendimento)
If lnova_os
	SetText(oData,dDataBase)
Endif
SelectData(aOS, nOS, dDataBase, oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem)

Return nil


Function ExibeTraslado(lnova_os,cCliente,cTraslado,oTrasladoTx)
//Busca o traslado padrão do cliente selecionado
If lnova_os
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cCliente)
	//If SA1->(Found())
		cTraslado := SA1->A1_TMPSTD
		SetText(oTrasladoTx, cTraslado)
	//EndIf  
Endif
Return nil