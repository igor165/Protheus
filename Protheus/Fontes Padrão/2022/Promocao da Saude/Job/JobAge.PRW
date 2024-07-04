#INCLUDE "JobAge.ch"
#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "TBICONN.CH" 
     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ JOBAG5 	บ Autor ณ Andreia Silva      บ Data ณ  28/10/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a tabela de alertas quando o paciente faltar a   บฑฑ
ฑฑบ          ณ consulta que estava agendada - chamada do JOB			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE		                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ        
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function JOBAGE( aParams )

Local cJobName := GetWebJob()		//Nome do Job (Working Thread) em execucao
Local cCodEmp  := aParams[1]//GetPvProfString(cJobName,"EMPRESA","",GetAdv97())//99
Local cCodFil  := aParams[2]//GetPvProfString(cJobName,"FILIAL","",GetAdv97())//01

Default aParams  := {}

RPCSetType(3) //nใo consome licen็a. 
If len(aParams)>0
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
Endif

// Trava para nใo executar o JOB se ja estiver em execucao

If !MayIUseCode( 'PLSJOBAGE' + cCodEmp )
	U_MsgConMon( STR0001 + cCodEmp + STR0002 ,, .F. ) //"JobAGE - Consulta Agendada"###' - Ja Esta Em Andamento'
	Return NIL
EndIf

// conout(STR0003 + "/Falta nos exames/proced. ") //"Iniciou o JOB - Faltou na consulta"

JobFaltCon()
JobFaltExa()

// conout(STR0005) //"Terminou a atualiza็ใo da BOS - Tabela de Alerta para a Promo็ใo"

FreeUsedCode()

If len(aParams)>0
	// conout(STR0006) //" Job Processado com Sucesso"
	RESET ENVIRONMENT	
Endif

Return(Nil)   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ JOBAGE    บAutor  ณMicrosiga          บ Data ณ  11/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alertar a promo็ao quando o paciente faltar na บฑฑ
ฑฑบ          ณ consulta agendada - executada por job.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function JobFaltCon()  

Local dData    := DTOS(dDataBase) 
Local dDataOnt := (dDataBase - 1)    // DE ONTEM PRA HOJE O JOB DEVE SER CONFIGURADO DIARIAMENTE
Local cSQL     := ""                                                                                      	
Local cResumo  := STR0007 //"Nใo Compareceu เ Consulta "
Local cTexto   := ""
Local cMatVid  := ""  
Local cTxtAca  := ""
Local cDestin  := ""
Local cCodPro  := ""
Local cVida    := ""
Local cElegib	 := ""
Local cCodLoc	 := ""
Local cItenEle	 := ""
Local cProgra	 := ""

cSQL := "SELECT GM8_PROMO, GM8_DATAGE, GM8_REGGER, GM8_PROGRA "
cSQL += "	FROM "
cSQL += 		RetSQLName("GM8")
cSQL += "		WHERE "     
cSQL += "		    GM8_FILIAL = '"+xFilial("GM8")+"' AND "
cSQL += "			GM8_PROMO  = '1'   AND "
cSQL += "			GM8_DATAGE < '"+dData+"' AND GM8_DATAGE >= '" + DTOS(dDataOnt) + "' AND " 
cSQL +=  			RetSQLName("GM8")+".D_E_L_E_T_ = ' ' AND GM8_STATUS = '1' "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYGM8",.F.,.T.)   

TCSETFIELD("QRYGM8","GM8_DATAGE","D",17,2)

// coNout("Inicio da busca de consulta nao realizados do planejamento" + Time() )
While QRYGM8->(!EOF())
	
	cMatVid := PLSRTVID(QRYGM8->GM8_REGGER)
	cItenEle:= QRYGM8->GM8_PROGRA

	dbSelectArea("BOQ")
	dbSetOrder(1)// BOQ_FILIAL, BOQ_ITEM, BOQ_VIDA, BOQ_ELEGIB, BOQ_CODTAB, BOQ_PROCED, BOQ_DATSUG, BOQ_CODAGE
	
	If dbSeek( xFilial("BOQ") + cItenEle )
		cProgra:= BOQ->BOQ_PROGRA
	Endif
	
	dbSelectArea("BOM")
	BOM->(DbGoTop())
	dbSetOrder(1)//BOM_FILIAL+BOM_CODPRO+BOM_VIDA+BOM_STATUS
	If BOM->(MsSeek(xFilial("BOM")+cProgra+cMatVid+"1"))
		RecLock("BOM",.F.)
		BOM->BOM_STATUS := '3'
		BOM->(MsUnLock())  
		
		cCodPro := BOM->BOM_CODPRO
		cElegib := BOM->BOM_NROSEQ   
		cCodLoc := BOM->BOM_CODLOC 
	EndIf
	
	cCodSin := Posicione("BOD", 1, xFilial("BOD") + BOM->BOM_CODPRO, "BOD_CODSIN")
	
	dbSelectArea("BOJ")
	dbSetOrder(1)//BOS_FILIAL, BOS_VIDA, BOS_CODPRO
	If BOJ->(MsSeek(xFilial("BOJ")+cCodSin))
		cTxtAca  := BOJ->BOJ_TXTACA
		cDestin  := BOJ->BOJ_DESTIN
	EndIf
	
	dbSelectArea("BOS")
	dbSetOrder(3)//BOS_FILIAL, BOS_VIDA, BOS_CODPRO  
	
	cNomPac := Posicione("BA1", 7, xFilial("BA1") + cMatVid, "BA1_NOMUSR") 
	cTexto  := "O paciente "+cMatVid+" - "+cNomPac+STR0008+cProgra+STR0009+; //", participante do programa "###" nใo compareceu a consulta agendada para o dia "
				DTOC(QRYGM8->GM8_DATAGE)
	
	If cVida <> cMatVid //!BOS->(MsSeek(xFilial("BOS")+cMatVid))
		BOS->(RecLock("BOS",.T.))
		BOS->BOS_FILIAL	:= xFilial("BOS")
		BOS->BOS_NROSEQ	:= GETSXENUM('BOS','BOS_NROSEQ')
		BOS->BOS_RESUMO	:= cResumo
		BOS->BOS_DATSIN := dDataBase
		BOS->BOS_HORAIN	:= Time()
		BOS->BOS_TEXTO	:= cTexto
		BOS->BOS_ACAO   := cTxtAca
		BOS->BOS_ORIGEM	:= FUNNAME()
		BOS->BOS_DESTIN	:= cDestin
		BOS->BOS_CODSIN	:= cCodSin
		BOS->BOS_AUTOMA	:= '1'
		BOS->BOS_VIDA   := cMatVid
		BOS->BOS_STATUS := "0"
		BOS->BOS_CODPRO := cProgra
		BOS->BOS_TPALER := '1'//AGENDA
		BOS->BOS_CODLOC := cCodLoc
  		ConfirmSx8()
     	BOS->(MsUnLock())  
		cVida := cMatVid 
	EndIf
	
	//-------------------------------------------------|
	// Atualiza Status na tabela de Planejamento, BOQ  |
	//-------------------------------------------------|

	dbSelectArea("BOQ")
	//BOQ->(DbGoTOP())
	dbSetOrder(1)//BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB
	//If BOQ->(MsSeek(xFilial("BOQ")+cMatVid+cElegib)) .AND. !Empty(cElegib)
	If MsSeek( xFilial("BOQ") + cItenEle )
		///While BOQ->(!EOF()) .And. BOQ->BOQ_VIDA == cMatVid  .and.  BOQ->BOQ_STATUS == '2'//0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
		IF BOQ->BOQ_VIDA == cMatVid  .and.  BOQ->BOQ_STATUS == '2'//0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
			If (BOQ->BOQ_DATAGE == dDataOnt .OR. cItenEle==BOQ->BOQ_ITEM)
				BOQ->(RecLock("BOQ",.F.))
				BOQ->BOQ_STATUS := "4"
				BOQ->(MsUnlock())
		//		BOQ->(dbSkip())
			EndIf
	//	EndDo
	Endif 
	EndIf
	
	QRYGM8->(dbSkip())
EndDo

QRYGM8->(DbCloseArea())

// coNout("Fim da busca de consulta nao realizados do planejamento" + Time() )
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ JobFaltExaบAutor  ณMicrosiga          บ Data ณ  11/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alertar a promo็ao quando o paciente faltar na บฑฑ
ฑฑบ          ณ exame feito atraves de guia dp plano - executada por job.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function JobFaltExa()  

Local nDiaTol  := GETNEWPAR("MV_NDIAFEX",30)
Local cSQL     := ""                                                                                      	
Local cTexto   := ""
Local cMatVid  := ""  
Local cCodPro  := ""
Local cVida    := ""
Local cElegib	 := ""
Local dDataPos := (dDataBase - nDiaTol) 
Local dDataAnt := (dDataBase - (nDiaTol*2)) 
Local cChaveBD6  := ""
Local cItemBOQ  := ""

// coNout("Inicio da busca de exames nao realizados do planejamento" + Time() )           

If BOQ->( FieldPos('BOQ_CHVEXA') ) == 0
	// coNout("Campo BOQ_CHVEXA nao esta contido no dicionario" )           	
	Return()
EndIf

cSQL := " SELECT BOQ_ITEM, BOQ_VIDA, BOQ_PROCED, BOQ_DATSUG, BOQ_ELEGIB, BOQ_PROGRA, BOQ_CODLOC FROM " + RetSQLName("BOQ") + " BOQ "
cSQL += " WHERE BOQ_PREAGE = '1' AND BOQ_STATUS = '1' AND BOQ_DATSUG BETWEEN '" + DTOS(dDataAnt) + "' AND '" + DTOS(dDataPos) + "' "
cSQL += " AND BOQ_CHVEXA = '" + SPace(TamSx3("BOQ_CHVEXA")[1]) + "' AND BOQ.D_E_L_E_T_ = ' ' AND BOQ_FILIAL = '"+xFilial("BOQ")+"'"

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYBOQ",.F.,.T.)   

TCSETFIELD("QRYBOQ","BOQ_DATSUG","D",17,2)

While QRYBOQ->(!EOF())
	
	cMatVid := QRYBOQ->BOQ_VIDA    
	cItemBOQ:= QRYBOQ->BOQ_ITEM    
	cCodPro:= QRYBOQ->BOQ_PROGRA    
	cChaveBD6 := PlsChkExa(QRYBOQ->BOQ_VIDA, QRYBOQ->BOQ_PROCED,QRYBOQ->BOQ_DATSUG - nDiaTol)
	 
	If Empty(cChaveBD6)	.AND. (QRYBOQ->BOQ_DATSUG +  nDiaTol) < dDataBase // Nao realizou o exame dentro do periodo de tolerancia	
		dbSelectArea("BOM")
		BOM->(DbGoTop())
		dbSetOrder(2)//BOM_FILIAL, BOM_VIDA, BOM_STATUS
		If BOM->(MsSeek(xFilial("BOM")+QRYBOQ->BOQ_ELEGIB))
			RecLock("BOM",.F.)
			BOM->BOM_STATUS := '3'
			BOM->(MsUnLock())  
		EndIf
	
		cNomPac := Posicione("BA1", 7, xFilial("BA1") + cMatVid, "BA1_NOMUSR") 
		cTexto  := "O paciente "+cMatVid+" - "+cNomPac+STR0008+cCodPro+"nao realizou o exame/procedimento [" + QRYBOQ->BOQ_PROCED + "] sugerido para o dia" +; //", participante do programa "###" nใo compareceu a consulta agendada para o dia "
					DTOC(QRYBOQ->BOQ_DATSUG)
		
		If cVida <> cMatVid //!BOS->(MsSeek(xFilial("BOS")+cMatVid))
			BOS->(RecLock("BOS",.T.))
			BOS->BOS_FILIAL	:= xFilial("BOS")
			BOS->BOS_NROSEQ	:= GETSXENUM('BOS','BOS_NROSEQ')
			BOS->BOS_RESUMO	:= "Nใo realizou o exame/proced. do planejamento! "
			BOS->BOS_DATSIN := dDataBase
			BOS->BOS_HORAIN	:= Time()
			BOS->BOS_TEXTO	:= cTexto
			BOS->BOS_ACAO   := ''
			BOS->BOS_ORIGEM	:= FUNNAME()
			BOS->BOS_DESTIN	:= '2'
			BOS->BOS_CODSIN	:= ''
			BOS->BOS_AUTOMA	:= '1'
			BOS->BOS_VIDA   := cMatVid
			BOS->BOS_STATUS := "0"
			BOS->BOS_CODPRO := QRYBOQ->BOQ_PROGRA
			BOS->BOS_TPALER := '1'//AGENDA
			BOS->BOS_CODLOC := QRYBOQ->BOQ_CODLOC
	  		ConfirmSx8()
	     	BOS->(MsUnLock())  
		EndIf
		
		//-------------------------------------------------|
		// Atualiza Status na tabela de Planejamento, BOQ  |
		//-------------------------------------------------|
	
		dbSelectArea("BOQ")
		BOQ->(DbGoTOP())
		dbSetOrder(1)//BOQ_FILIAL, BOQ_ITEM
		If BOQ->(MsSeek(xFilial("BOQ")+cItemBOQ))
			BOQ->(RecLock("BOQ",.F.))
			BOQ->BOQ_STATUS := "4"
			BOQ->(MsUnlock())
		EndIf
	
	ElseIf !Empty(cChaveBD6)  //atualiza como realizado   
		//-------------------------------------------------|
		// Atualiza Status na tabela de Planejamento, BOQ  |
		//-------------------------------------------------|
	
		dbSelectArea("BOQ")
		BOQ->(DbGoTOP())
		dbSetOrder(1)//BOQ_FILIAL, BOQ_ITEM
		If BOQ->(MsSeek(xFilial("BOQ")+cItemBOQ))
			BOQ->(RecLock("BOQ",.F.))
			BOQ->BOQ_STATUS := "3"
			BOQ->BOQ_CHVEXA := cChaveBD6
			BOQ->(MsUnlock())
		EndIf
		
	EndIf
	QRYBOQ->(dbSkip())
EndDo

QRYBOQ->(DbCloseArea())
// coNout("Fim da busca de exames nao realizados do planejamento" + Time() )
Return
////////////////////////////////////////////
//retorna o procedimento realizado no plano 
////////////////////////////////////////////
Static Function PlsChkExa(cCodVida, cCodPsa,dDatIniFil)  
Local cChave 	:= ""
Local aArea 	:= GetArea()
Local cSql 		:= ""

cSql := " SELECT BD6_FILIAL,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO FROM " + RetSQLName("BD6") + " BD6 "
cSQL += " WHERE BD6_MATVID = '"+ cCodVIda +"' AND BD6_CODPRO = '" + cCodPsa + "' AND BD6_DATPRO >= '" + DTOS(dDatIniFil) + "' "
cSQL += " AND BD6.D_E_L_E_T_ = ' ' AND BD6_FILIAL = '"+xFilial("BD6")+"'"

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYBD6",.F.,.T.)   
                                                                                                                                                                          
While !QRYBD6->(Eof())
	cChave := QRYBD6->BD6_FILIAL+QRYBD6->BD6_CODOPE+QRYBD6->BD6_CODLDP+QRYBD6->BD6_CODPEG+QRYBD6->BD6_NUMERO+QRYBD6->BD6_ORIMOV+QRYBD6->BD6_SEQUEN+QRYBD6->BD6_CODPAD+QRYBD6->BD6_CODPRO 
	DbSelectArea("BOQ")
	DbSetOrder(5)  // BOQ_FILIAL + BOQ_CHVEXA
	If !MsSeek(xFilial("BOQ") + Alltrim(cChave))       
		Return(cChave)  
	Else
		cChave 	:= ""
	EndIf

EndDo
QRYBD6->(DbCloseArea())
RestArea(aArea)
Return(cChave)
