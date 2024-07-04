#Include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTaxTable บAutor  ณWilliam Palma Alves  บ Data ณ 30/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a estrutura da tabela temporแria para uso da SAFT de  บฑฑ
ฑฑบ          ณPortugal.                               			          บฑฑ
ฑฑบ          ณAliquotas - Regiใo                               			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSAFT - Portugal                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TAXTABLE(cTpSaft)

Local lContab	    := Iif(cTpSaft=="C",.T.,.F.)

Local aTemp 		:= TaxTableTmp(lContab)

Local lQuery		:= .F.
Local aTabela		:={}
Local cDescr		:= ""  
Local nAliq  		:=0
Local nX		    :=1
Local nSFF 			:= 0

Local cTipoImp      := ""
Local cCodTpImp		:= ""
Local cImposto 		:= ""
Local dDatafim		:= dDataBase
Local cDescIS		:= ""
Local nMontante     := 0		
Local cClasiva		:= ""
Local cClasIS		:= ""
Local aAreaAtu 		:= {}
Local cPais			:= ""
Local aInfoTmp      := {}
Local lVldOk		:= .F.


#IFDEF TOP
	//Local aCamposSFF	:= {}
	Local aStruSFF		:= {}
	nX			:= 0
#ELSE
	Local cArqInd		:= ""
	Local cChave		:= ""
	Local cFiltro		:= ""	
#ENDIF

Private oTmpTable

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessamento dos documentos Fiscais                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SFF")
dbSetOrder(1)

#IFDEF TOP
  
    If TcSrvType()<>"AS/400"
    
	    cAliasSFF	:= "POR"
	   	lQuery    	:= .T.
		aStruSFF  	:= SFF->(dbStruct())		
		
		cQuery:= "SELECT * "
   		cQuery+= " FROM " + RetSqlName("SFF") + xFilial("SFF")
   		cQuery+= " WHERE D_E_L_E_T_ = ''"
				
		cQuery 		:= ChangeQuery(cQuery)
    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFF,.T.,.T.)

		For nSFF := 1 To Len(aStruSFF)
			If aStruSFF[nSFF][2] <> "C" .and. FieldPos(aStruSFF[nSFF][1]) > 0
				TcSetField(cAliasSFF,aStruSFF[nSFF][1],aStruSFF[nSFF][2],aStruSFF[nSFF][3],aStruSFF[nSFF][4])
			EndIf
		Next nSFF
	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"FF_ALIQ+FF_REGIAO"
		cFiltro :=  "FF_FILIAL == '" + xFilial("SFF") 
			
		IndRegua(cAliasSFF,cArqInd,cChave,,cFiltro,"Selecionando Registros")
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSFF)->(dbGotop())

#IFDEF TOP
	Endif    
#ENDIF

dbSelectArea(cAliasSFF)
ProcRegua(LastRec())
(cAliasSFF)->(DbGoTop())

While (cAliasSFF)->(!Eof())                  
	IncProc()
	aTabela		:=PtgAliq((cAliasSFF)->FF_ALIQ,(cAliasSFF)->FF_REGIAO)	
	RecLock("TMP",.T.)   
    
    cRegiao	  :=""
    cPrefixo  :=""
    cTipoImp  := ""
    cCodTpImp := ""
    cImposto  := ""      
    dDatafim  := dDataBase
    cDescIS	  := ""
    nMontante := 0		
    cClasiva  := ""
    cClasIS	  := ""
    cPais	  := (cAliasSFF)->FF_PAIS	
    
    aAreaAtu := GetArea()
    
    DbSelectArea("SYA")
    DbSetOrder(1)
    If (DbSeek(xFilial("SYA")+cPais))
		If SYA->(FieldPos("YA_SGLLOC")) > 0
			cPais := SYA->YA_SGLLOC
		EndIf
	EndIf	 	
                         
    RestArea(aAreaAtu)
   
	If aTabela[02]=="1"
	   cRegiao :="IVACON"	   
	ElseIf aTabela[02]=="2"
	   cRegiao := "IVARAM"
	   cPais := "PT-MA" //MADEIRA                          // SAFT 25.12 (PREFIXO DA REGIAO)
	ElseIf aTabela[02]=="3"
	   cRegiao :="IVARAA"
   	   cPais := "PT-AC" //ACORES                           // SAFT 25.12 (PREFIXO DA REGIAO)
	ElseiF aTabela[02]=="4"
	   cRegiao := "IVAINT"	   
	ElseiF aTabela[02]=="5"
	   cRegiao := "IVAEXT"	   
	Else
		(cAliasSFF)->(dbSkip())
		Loop
	Endif 
	
	cDescr	:=""
	nAliq := (cAliasSFF)->FF_ALIQ
    cImposto := (cAliasSFF)->FF_IMPOSTO	
	
	
	If Alltrim((cAliasSFF)->FF_CLASIVA) == '1'                                 
	   cClasiva := "RED"
	ElseIf Alltrim((cAliasSFF)->FF_CLASIVA) == '2'
	   cClasiva := "INT"
	ElseIf Alltrim((cAliasSFF)->FF_CLASIVA) == '3'
	   cClasiva := "NOR"
	ElseIf Alltrim((cAliasSFF)->FF_CLASIVA) == '4'
	   cClasiva := "ISE"	
	ElseIf Alltrim((cAliasSFF)->FF_CLASIVA) == '5'	
	   cClasiva := "OUT"			
	EndIf  
     
    
    If ((cAliasSFF)->(FieldPos("FF_CLASIS"))) > 0 .And. ((cAliasSFF)->(FieldPos("FF_DESCIS"))) > 0
    	cClasIS := (cAliasSFF)->FF_CLASIS
    EndIF	               
    
    DbSelectArea("SFB")
 	DbSetOrder(1) 	
   	
 	If (DbSeek(xFilial("SFB")+cImposto))
		If SFB->(FieldPos("FB_CLASIMP")) > 0 					
			If !Empty(SFB->FB_CLASIMP)
	 			cTipoImp := IIf(SFB->FB_CLASIMP == '1',"IVA","IS")         
	 	   		cCodTpImp := IIf(cTipoImp == 'IVA',cClasiva,cClasIS)       	 	   		                  										   
	 	   	EndIf	
	 	EndIf   	 	     		 	   		 
	 	If SFB->(FieldPos("FB_DATAFIM")) > 0	                             
	 		dDataFim := SFB->FB_DATAFIM	         		                    
	 	EndIf
 	EndIF 	
    
    RestArea(aAreaAtu)	
    
    If ((cAliasSFF)->(FieldPos("FF_DATAFIM"))) > 0 .And. ((cAliasSFF)->(FieldPos("FF_MONTAN"))) > 0
    	dDataFim := (cAliasSFF)->FF_DATAFIM	
	    
	    If Empty((cAliasSFF)->FF_ALIQ)			
			nMontante := (cAliasSFF)->FF_MONTAN                             				
		Else
			nAliq := (cAliasSFF)->FF_ALIQ			            			                             
		EndIF
	EndIF
		    
    //grava no arquivo temporario
    
    TMP->CLASSIF := cTipoImp       			//25.11
    TMP->REGIAO	:= cRegiao
   	TMP->DATAFIM := IIF(!Empty(dDataFim),Str(Year(dDataFim),4)+"-"+SubStr(DToC(dDataFim),4,2)+"-"+SubStr(DToC(dDataFim),1,2)," ") 			//25.15
	TMP->ALIQ := nAliq             			//25.16	
	TMP->MONTAN := nMontante       			//25.17
	TMP->PAIS := cPais             			//25.12
	TMP->CODTPIMP := cCodTpImp     	   		//25.13
    TMP->DESCR := (cAliasSFF)->FF_CONCEPT   //25.14   
    
	MsUnLock()				
	(cAliasSFF)->(dbSkip())
Enddo 

         

If !lQuery
	RetIndex("SFF")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSFF)
	dbCloseArea()
Endif	
Return(aTemp)                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTaxTableTmp บAutor  ณWilliam Palma Alves บ Data ณ 30/05/2008บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria as tabelas temporarias                                 บฑฑ
ฑฑบ          ณAliquotas - Regiใo                          				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSAFT - Portugal                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TaxTableTmp(lCtb)

Local aTemp 	:= {}
Local aCab		:= {}
Local cPicAliq  := IIf (lCtb,999,((TamSX3("FF_ALIQ")[01])))
Local cPicMon   := IIf (lCtb,999,((TamSX3("FF_MONTAN")[01])))
Local cArqCab	:= ""
Local cTmp := GetNextAlias()   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCabecalho do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                                      
AADD(aCab,{"REGIAO"		,"C",015,0})
AADD(aCab,{"ALIQ"  		,"N",cPicAliq,0})
AADD(aCab,{"DESCR"		,"C",255,0})
AADD(aCab,{"TIPO"		,"C",001,0})
AADD(aCab,{"CLASSIF"  	,"C",003,0})
AADD(aCab,{"DATAFIM"	,"C",010,0})
AADD(aCab,{"CODTPIMP"	,"C",010,0})
AADD(aCab,{"MONTAN"	    ,"N",cPicMon,0})
AADD(aCab,{"PAIS"   	,"C",005,0})


oTmpTable := FWTemporaryTable():New("TMP",aCab)
oTmpTable:AddIndex("IN1", {"REGIAO"})
oTmpTable:Create()

aTemp	:=	{{cArqCab,"TMP"}}

Return(oTmpTable)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณTaxTableDel บAutor ณ William Palma Alves บ Data ณ 18/10/2007 บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณApaga arquivos temporarios criados para gerar o arquivo XML. บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณSAFT - Portugal                                              บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TaxTableDel(aDelArqs)

Local aAreaDel	:= GetArea()

Local nI 		:= 0

For nI := 1 To Len(aDelArqs)

	If File(aDelArqs[ni,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,1]+GetDBExtension())
		Ferase(aDelArqs[ni,1]+OrdBagExt())
	Endif	

Next

RestArea(aAreaDel)

Return


