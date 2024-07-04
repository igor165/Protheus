#INCLUDE "TFA07.ch"
#include "eADVPL.ch"

//Teclado Alfanumerico       
Function Keyb_Alfa(oObj)  
	Keyboard(0,oObj) 	         
Return nil

//Teclado Numerico
Function Keyb_Num(oObj)
	Keyboard(1,oObj) 
Return nil

Function GravaOS(lnova_os, cNrOs, cSeq, dDataBase, cHoraCheg, cHoraSaida, dDataCheg, dDataSaida, cHoraInicio, cHoraTermino, dDataInicio, dDataTermino, cOcorrencia, cLaudo, cCliente, lGarantia, cNrSerie, aStatus, cTraslado, cTotais)

Local cCodTec := "", cGarantia := "", cCodOcorr := "", cCodcli := "", cLoja := "", cCodpro := ""
Local cDataIni := Substr(DTOC(dDataInicio),7,4) + Substr(DTOC(dDataInicio),4,2) + Substr(DTOC(dDataInicio),1,2)
Local nProximaOS := "", cOSTmp := Substr(cNrOS,1,6)

If !VrfAtendOS(cNrOS,cSeq,dDataCheg,cHoraCheg,dDataSaida,cHoraSaida,dDataInicio,cHoraInicio,dDataTermino,cHoraTermino,cOcorrencia)
	return nil
Endif

dbSelectArea("AA1")
cCodTec := AA1->AA1_CODTEC

cCodOcorr := cOcorrencia
/*dbSelectArea("AAG")
dbSetOrder(2)
dbSeek(cOcorrencia)
If AAG->(Found())
	//Alert("Achou: " + cOcorrencia)
	cCodOcorr := AAG->AAG_CODPRB
	//Alert(cCodOcorr)
EndIf*/

If lnova_os		//Qdo. for uma nova OS buscar o cod. do cliente no SA1
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cCliente)	  	  
	cCodcli := SA1->A1_COD
	cLoja	:= SA1->A1_LOJA		
	//Atualizar data base
	dDataBase := dDataInicio 
Else		//Senao buscar o cod. do cliente no arq. de OS (AB6)
	dbSelectArea("AB6")
	dbSetOrder(1)
	dbSeek(cOSTmp)
	If AB6->(Found())
		//Alert("Achou: " + cOSTmp)
		cCodcli := AB6->AB6_CODCLI
		cLoja	:= AB6->AB6_LOJA
		//Alert("Cliente: " + cCodcli)	
	EndIf
	
	dbSelectArea("AB7")
	dbSetOrder(1)
	dbSeek(cNrOS)
	If AB7->(Found())
		cCodpro := AB7->AB7_CODPRO			
	EndIf
EndIf	             

If lGarantia
	cGarantia := "S"	
Else                
	cGarantia := "N"		
Endif

dbSelectArea("AB9")
dbSetOrder(2)
dbSeek(cNrOS+cSeq)

If AB9->(!Found())		//Inclusao
	dbappend()
	AB9->AB9_NUMOS	:= cNrOS
	//Alert("OS: " + AB9->AB9_NUMOS) 
	AB9->AB9_CODTEC	:= cCodTec
	AB9->AB9_SEQ	:= cSeq
	AB9->AB9_DTCHEG	:= dDataCheg
	AB9->AB9_HRCHEG	:= cHoraCheg
	AB9->AB9_DTSAID	:= dDataSaida
	//Alert("Dt. Saida: " + dtoc(AB9->AB9_DTSAID))
	AB9->AB9_HRSAID	:= cHoraSaida
	AB9->AB9_DTINI	:= dDataInicio
	AB9->AB9_HRINI	:= cHoraInicio
	AB9->AB9_DTFIM	:= dDataTermino
	//Alert("Dt. Fim: " + dtoc(AB9->AB9_DTFIM))
	AB9->AB9_HRFIM	:= cHoraTermino
	AB9->AB9_TRASLA	:= cTraslado
	//AB9->AB9_RATEIO	:= "S"
	AB9->AB9_CODPRB	:= cCodOcorr
	AB9->AB9_GARANT	:= cGarantia
	AB9->AB9_OBSOL	:= ""
	AB9->AB9_ACUMUL	:= 0
	AB9->AB9_TIPO	:= Substr(aStatus,1,1)
	AB9->AB9_ATUPRE	:= ""
	AB9->AB9_ATUOBS	:= ""
	AB9->AB9_NUMSER	:= cNrSerie
	AB9->AB9_CODCLI	:= cCodcli          
	AB9->AB9_LOJA	:= cLoja                 
	AB9->AB9_CODPRO	:= cCodpro
	If lnova_os
		//Alert("Nova")
		AB9->AB9_MEMO1	:= "NOVA"
	Else             
		AB9->AB9_MEMO1	:= ""
	Endif
	AB9->AB9_MEMO2	:= cLaudo
	AB9->AB9_TOTFAT	:= cTotais
	AB9->AB9_NUMORC	:= ""
	AB9->AB9_CUSTO	:= 0
	dbcommit()
	//Alert("Gravou!")
Else	//Alteracao
	If MsgYesOrNo(STR0001,STR0002) //"Atendimento já existente, deseja alterar?"###"Atenção"
		AB9->AB9_NUMOS	:= cNrOS
		AB9->AB9_CODTEC	:= cCodTec
		AB9->AB9_SEQ	:= cSeq
		AB9->AB9_DTCHEG	:= dDataCheg
		AB9->AB9_HRCHEG	:= cHoraCheg
		AB9->AB9_DTSAID	:= dDataSaida
		AB9->AB9_HRSAID	:= cHoraSaida
		AB9->AB9_DTINI	:= dDataInicio
		AB9->AB9_HRINI	:= cHoraInicio
		AB9->AB9_DTFIM	:= dDataTermino
		AB9->AB9_HRFIM	:= cHoraTermino
		AB9->AB9_TRASLA	:= cTraslado
		//AB9->AB9_RATEIO	:= "S"
		AB9->AB9_CODPRB	:= cCodOcorr
		AB9->AB9_GARANT	:= cGarantia
		AB9->AB9_OBSOL	:= ""
		AB9->AB9_ACUMUL	:= 0
		AB9->AB9_TIPO	:= Substr(aStatus,1,1)
		AB9->AB9_ATUPRE	:= ""
		AB9->AB9_ATUOBS	:= ""
		AB9->AB9_NUMSER	:= cNrSerie
		AB9->AB9_CODCLI	:= cCodcli          
		AB9->AB9_LOJA	:= cLoja                 
		AB9->AB9_CODPRO	:= cCodpro
/*		If lnova_os
			AB9->AB9_MEMO1	:= "NOVA"
		Else
			AB9->AB9_MEMO1	:= ""
		Endif	*/
		AB9->AB9_MEMO2	:= cLaudo
		AB9->AB9_TOTFAT	:= cTotais
		AB9->AB9_NUMORC	:= ""
		AB9->AB9_CUSTO	:= 0		
		//Alert("Alterou!")
	EndIf
EndIf

GrvNovaOS(lnova_os,cOSTmp,cDataIni,cCodTec,cHoraInicio,dDataTermino,cHoraTermino,cTotais,cCodCli,cLoja,dDataInicio,cNrOS,cCodpro,cNrSerie,cCodOcorr,nProximaOS)
CloseDialog() 

Return nil