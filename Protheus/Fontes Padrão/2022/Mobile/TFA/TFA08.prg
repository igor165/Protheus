#INCLUDE "TFA08.ch"
#include "eADVPL.ch"

Function CalculaHoras(cHoraInicio, cHoraTermino, dDataInicio, dDataTermino, cTraslado, cTotais, oTotalTx) 

Local nHoras_faturadas 	:= val(Substr(cHoraTermino,1,2)) - val(Substr(cHoraInicio,1,2)) 
Local nMinutos_faturados:= val(Substr(cHoraTermino,4,2)) - val(Substr(cHoraInicio,4,2)) 
Local nHoras_traslado 	:= val(Substr(cTraslado,1,2))
Local nMinutos_traslado	:= val(Substr(cTraslado,4,2))
Local nData_ini		 	:= val(Dtoc(dDataInicio))
Local nData_term 		:= val(Dtoc(dDataTermino))
Local nDias 			:= nData_term - nData_ini 	//Qtde. de dias 
Local cTmpTotais		:= ""
//Alert("Data Inic.: " + Dtoc(dDataInicio))
//Alert("Data Term.: " + Dtoc(dDataTermino))

nHoras_faturadas 	:= nHoras_faturadas + nHoras_traslado
nMinutos_faturados  := nMinutos_faturados + nMinutos_traslado

If nDias > 0
	nHoras_faturadas := nHoras_faturadas + (nDias * 24)
EndIf

If nDias < 0  				//ocorre qdo. a data termino esta no inicio do prox. mes 
	nDias := 31 - (nDias * -1)
	nHoras_faturadas := nHoras_faturadas + (nDias * 24)
EndIf

If nMinutos_faturados < 0  //ocorre qdo. hora final esta no inicio da prox. hora 
	nHoras_faturadas   := nHoras_faturadas - 1
	nMinutos_faturados := nMinutos_faturados + 60	
EndIf
                                                 
If nMinutos_faturados > 59
	nMinutos_faturados := nMinutos_faturados - 60
	nHoras_faturadas   := nHoras_faturadas + 1     	
EndIf                                         

cTotais := StrZero(nHoras_faturadas,2) + ":" + StrZero(nMinutos_faturados,2)
cTmpTotais := cTotais

SetText(oTotalTx, cTmpTotais)

Return nil

          
Function DtChegada(oDtChegTx, dDataCheg)
	Local dData := date()
	If !Empty(dDataCheg)
		dDataCheg := SelectDate(STR0001,dDataCheg) //"Sel. Data Chegada"
	Else
		dDataCheg := SelectDate(STR0001,dData) //"Sel. Data Chegada"
	EndIf
	SetText(oDtChegTx, dDataCheg)
Return nil
          

Function DtSaida(oDtSaidaTx, dDataSaida)
	Local dData := date()
	If !Empty(dDataSaida)
		dDataSaida := SelectDate(STR0002,dDataSaida)			 //"Sel. Data Saída"
	Else
		dDataSaida := SelectDate(STR0002,dData)	 //"Sel. Data Saída"
	EndIf                  
	SetText(oDtSaidaTx,dDataSaida)	
Return nil


Function DtInicio(oDtInicioTx,dDataInicio)
	Local dData := date()
	If !Empty(dDataInicio)
		dDataInicio := SelectDate(STR0003,dDataInicio) //"Sel. Data Início"
	Else
		dDataInicio := SelectDate(STR0003,dData)	 //"Sel. Data Início"
	EndIf                  
	SetText(oDtInicioTx,dDataInicio)
Return nil
          

Function DtTermino(oDtTermTx,dDataTermino)
	Local dData := date()
	If !Empty(dDataTermino)
		dDataTermino := SelectDate(STR0004,dDataTermino)			 //"Sel. Data Término"
	Else
		dDataTermino := SelectDate(STR0004,dData)	 //"Sel. Data Término"
	EndIf                  
	SetText(oDtTermTx,dDataTermino)	
Return nil


/*Function Traslado(cCliente, cTraslado, lnova_os)
Alert(cCliente)
Alert(lnova_os)

If lnova_os
	dbSelectArea("SA1")
	dbSetOrder(2)
	dbSeek(cCliente)
	If SA1->(Found())
		Alert("Achou cli..")
		cTraslado := SA1->A1_TMPSTD
	Else
		Alert("Nao achou cli..")
	EndIf  
EndIf

Return nil	*/


/* Precisa do aScan() => Futuramente
If !lnova_os
    nPos := aScan(aOS, )
	If nPos > 0
		Alert("Achou...")
		aOS[nPos] := Substr(cNrOS,1,6) + " - " + Substr(cNrOS,10,2) + " - OK"
		SetArray(oLbx, aOS)
	EndIf
EndIf 
*/