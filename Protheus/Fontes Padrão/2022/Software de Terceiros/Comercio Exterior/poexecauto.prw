#Include 'Protheus.ch'

*-------------------------*
User Function POExecAuto()
*-------------------------*
Local aCab := {} 
Local aItem := {} 

Private lMsErroAuto := .F.

cPO := Left(AllTrim(Str(Seconds())), 6)

AADD(aCab,{"W2_PO_NUM" , cPO ,NIL})
AADD(aCab,{"W2_PO_DT" ,dDatabase ,NIL})
AADD(aCab,{"W2_FORN" ,"000004" ,NIL})
AADD(aCab,{"W2_FORLOJ" ,"01" ,NIL})
AADD(aCab,{"W2_COMPRA" ,"002 " ,NIL})
AADD(aCab,{"W2_IMPORT" ,"03" ,NIL})
AADD(aCab,{"W2_AGENTE" ,"002" ,NIL})
AADD(aCab,{"W2_TIPO_EM" ,"01" ,NIL})
AADD(aCab,{"W2_ORIGEM" ,"SSZ" ,NIL})
AADD(aCab,{"W2_DEST" ,"BLM" ,NIL})
AADD(aCab,{"W2_INCOTER" ,"FOB" ,NIL})
AADD(aCab,{"W2_FREPPCC" ,"CC" ,NIL})
AADD(aCab,{"W2_COND_PA" ,"ANT01" ,NIL})
AADD(aCab,{"W2_MOEDA" ,"US$" ,NIL})
AADD(aCab,{"W2_DT_PAR" ,dDatabase ,NIL}) 
AADD(aCab,{"W2_PARID_U" ,1,000000 ,NIL})
AADD(aCab,{"W2_E_LC" ,"2" ,NIL})


aAdd(aItem,{ {"W3_COD_I" , "MOUSE-001",NIL},;
{"W3_CC" , "01 " ,NIL},;
{"W3_REG" , 1 ,NIL},;
{"W3_PRECO" , 1,00000 ,NIL},; 
{"W3_FABR" , "000002" ,NIL},;
{"W3_FABLOJ" , "01" ,NIL},;
{"W3_FORN" , "000004" ,NIL},;
{"W3_FORLOJ" , "01" ,NIL},;
{"W3_QTDE" , 1000,00000 ,NIL},;
{"W3_SALDO_Q" , 1000,00000 ,NIL},;
{"W3_DT_EMB" , dDatabase + 40,NIL},;
{"W3_DT_ENTR" , dDatabase + 50,NIL}}) 

aAdd(aItem,{ {"W3_COD_I" , "PLA-001",NIL},;
{"W3_CC" , "01 " ,NIL},;
{"W3_REG" , 2 ,NIL},;
{"W3_PRECO" , 1,00000 ,NIL},; 
{"W3_FABR" , "000002" ,NIL},;
{"W3_FABLOJ" , "01" ,NIL},;
{"W3_FORN" , "000004" ,NIL},;
{"W3_FORLOJ" , "01" ,NIL},;
{"W3_QTDE" , 200,00000 ,NIL},;
{"W3_SALDO_Q" , 200,00000 ,NIL},;
{"W3_DT_EMB" , dDatabase +40 ,NIL},;
{"W3_DT_ENTR" , dDatabase +50,NIL}}) 


MSExecAuto({|a,b,c,d| EICPO400(a,b,c,d)},NIL,aCab,aItem,3)

If lMsErroAuto
MOSTRAERRO()
EndIf 
MsgInfo(cPO)
Return Nil

