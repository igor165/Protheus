#Include "CTBA415.Ch"
#Include "PROTHEUS.Ch"


/*/ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³ CTB415     ³ Autor ³ TOTVS                ³ Data ³ 30/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para numerar sequencialmente os os lancamentos       ±±
±±³            contabeis para que seja possivel fazer a impressao no       ±±
±±³            diario e mayor contabil                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe ³ CTB415(void) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno ³ Generico ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso ³ Paraguai ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function CTBA415()

Local   cCombo := ""
Local   aCombo := {}
Local   oDlg   := Nil
Local   oFld   := Nil
Private cMes   := StrZero(Month(dDataBase),2)
Private cAno   := StrZero(Year(dDataBase),4)
Private dDataIni:=GETMV("MV_ULTANC") +1
Private dDataFim:=dDataBase     
Private cUserEx:= Alltrim(UsrRetName(__CUSERID))
Private dDataEx:= dDataBase
Private cTimeEx:= Time()
Private cObs:= cUserEx +"-"+dtoc(dDataEx)+"-" + cTimeEx

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 350,500 OF oDlg PIXEL //"Resolucao 70/07 para IIBB - Buenos Aires "
	 
	@ 006,006 TO 130,240 LABEL STR0002 OF oDlg PIXEL //"Info. Preliminar"

	@ 015,015 SAY STR0003 SIZE 250,008 PIXEL OF oFld 
	@ 025,015 SAY STR0004 SIZE 250,008 PIXEL OF oFld //"Fornecedor / Cliente  x Imposto segundo arquivo TXT  "
	@ 035,015 SAY STR0005 SIZE 250,008 PIXEL OF oFld //"disponibilizado pelo governo                         "
	@ 045,015 SAY STR0006 SIZE 250,008 PIXEL OF oFld 
    	@ 055,015 SAY STR0007 SIZE 250,008 PIXEL OF oFld 
    	@ 065,015 SAY STR0008 SIZE 250,008 PIXEL OF oFld   
	@ 075,015 SAY STR0024 SIZE 250,008 PIXEL OF oFld //"Informe o periodo:"
	@ 085,015 SAY STR0009  SIZE 250,008 PIXEL OF oFld 
	@ 095,015 SAY cUserEx +"-"+dtoc(dDataEx)+"-" + cTimeEx SIZE 250,008 PIXEL OF oFld
	@ 115,015 SAY STR0010  + Dtoc(dDataIni)SIZE 150,008 PIXEL OF oFld //"Informe o periodo:"
	@ 140,015 SAY STR0011 SIZE 150,008 PIXEL OF oFld //"Informe o periodo:"
	@ 140,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld                                         
	@ 140,070 SAY "/" SIZE  150, 8 PIXEL OF oFld
	@ 140,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 145,160 BUTTON STR0012 SIZE 036,016 PIXEL ACTION CTB415AT(aCombo,cCombo) //"&Importar"
	@ 145,200 BUTTON STR0013 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³ CTB415     ³ Autor ³ TOTVS                ³ Data ³ 30/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ verifica se o periodo contabil esta em aberto              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe ³ CTB415AT(void) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno ³ Generico ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso ³ Generico ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/



Function CTB415AT()   
Local lExecute:=.T.
Local lData:=.T.
dDtAtu:=dDataIni
dDataFim:= Lastday(CTOD("01/"+ cMes+"/"+ cAno),0)          

If dDataIni>dDataFim
	lExecute:=.F.
	lData:= .F.                                                                                                                                                                                                                                                                                             
	MsgAlert(STR0014,STR0015)
EndIf
 
IF lExecute
	
    While dDtAtu <= dDataFim .AND.   lExecute
    	If VlDtCal(dDtAtu,dDtAtu,1,"","234",.F.,"" )    
    		 lExecute:=.f. 
   		Else
   			dDtAtu:=(dDtAtu)+1
   		EndIf
    EndDo                            
 EndIf   
 
If  lExecute
 	Processa( {||CTB415RENU()}, STR0016,STR0017,.T.) 	
ElseIf lData
	MSGSTOP(STR0018 + Dtoc(dDtAtu)+ STR0019,STR0020)

 EndIf
 

/*/ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³ CTB415     ³ Autor ³ TOTVS                ³ Data ³ 30/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RENUMERADOR  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe ³ CTB415RENU(void) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno ³ Generico ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso ³ Generico ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function CTB415RENU()

Local nNumero := 0 

Local dData 	:= dDataIni
Local cNumero	:="0"
Local cDoc 		:= ""
Local cLote 	:= ""
Local cSubLote 	:= ""
Local cFecha 	:= ""
Local cFilialCt	:=""

DbSelectArea("CT2")

DbSetOrder(1)

nQtd:=0
If Select("CT2R")>0 
	CT2R->(dbCloseArea())
EndIf

cQuery:= "SELECT * FROM " +RetSqlName("CT2") + " CT2"
cQuery+= " WHERE "
cQuery+=" CT2_DATA>='"+Dtos(dData)+"'"
cQuery+=" AND CT2_DATA<='"+Dtos(dDataFim)+"'"  
cQuery+=" AND CT2.D_E_L_E_T_=' '  "                                    
If Upper(Alltrim(TcGetDB()))=="ORACLE"                
	cQuery+= "ORDER BY CT2_DATA,CT2_FILIAL,CT2_DOC,CT2_LOTE,CT2_SBLOTE"
Else
	cQuery+= "ORDER BY CT2_DATA+CT2_FILIAL+CT2_DOC+CT2_LOTE+CT2_SBLOTE"
EndIf
cQuery:=ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery ),"CT2R",.T.,.T.)
TCSetField("CT2R","CT2_DATA","D")
Count to nNumRegs
DbSelectArea("CT2R")
CT2R->(DbGoTop())
ProcRegua(nNumRegs)

While CT2R->(!Eof()) 
	nQtd:=nQTd+1
	nRecnoCT2:=CT2R->R_E_C_N_O_
	IncProc(STR0023+AllTrim(Str(nQtd)))
		If cFecha+cFilialCt+cDoc+cLote+cSubLote <> Dtos(CT2R->CT2_DATA)+CT2R->CT2_FILIAL+CT2R->CT2_DOC+CT2R->CT2_LOTE+CT2R->CT2_SBLOTE
			cFilialCt :=CT2R->CT2_FILIAL
			cDoc := CT2R->CT2_DOC
			cLote := CT2R->CT2_LOTE
			cSubLote := CT2R->CT2_SBLOTE
			cFecha := Dtos(CT2R->CT2_DATA)
			nNumero := nNumero+1
			cNumero	:= ALLtrim(str(nNumero))		
		EndIf
		CT2->(DbGoto(nRecnoCT2))
		RecLock("CT2" ,.F.)
	
		CT2->CT2_NACSEQ := cNumero
		CT2->CT2_NACUSR	:= cUserEx
		CT2->CT2_NACFEC	:= dDataEx
		CT2->CT2_NACHOR	:= cTimeEx
		CT2->(MsUnLock()    )

	CT2R->(DbSkip() )

End  
If Select("CT2R")>0 
	CT2R->(dbCloseArea())
EndIf

PutMv ("MV_ULTANC",dDataFim)
dDataIni:=dDataFim+1
MsgAlert(STR0021+ str(nQtd) + STR0022 +Alltrim(cNumero))

Return(.T.)

