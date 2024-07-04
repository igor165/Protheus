#Include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIAMATMP บAutor  ณCamila Januแrio      บ Data ณ 15/06/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo temporแrio de movimenta็๕es a serem apresenta- บฑฑ
ฑฑบ          ณdos na Declara็ใo de Ingressos no Amazonas - DIA            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณDIA - Amazonas                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DiamaTmp(aInfo)

Local aTemp 	 := StructTMP()
//Local aAreaAtu 	 := {}
Local aArea1     := {} 
Local cQuery     := ""
Local cAliasTmp  := "SB9"
Local cAliasF9	 := "SF9"
Local cAliasD1	 := "SD1"
Local cAliasB1	 := "SB1"
Local cAliasB5	 := "SB5"
Local cChaveD1	 := ""
Local lSd1		 := .F.
Local nX		 := 1
Local nSB9 		 := 0
Local nIndex     := 1 

Local lQuery		:= .F.  

#IFDEF TOP
	Local aStruTMP		:= {}
	nX			:= 0
#ELSE
	Local cArqInd		:= ""
	Local cChave		:= ""
	Local cFiltro		:= ""	
#ENDIF

Private aProduto	:= {}

dbSelectArea("SB9")
dbSetOrder(1)

#IFDEF TOP
  
    If TcSrvType()<>"AS/400"    
	    cAliasTMP	:= GetNextAlias()
	   	lQuery    	:= .T.
		aStruTMP  	:= SB9->(dbStruct()) 		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFaz a busca nas movimenta็๕es de saldo atualizado doณ
		//ณestoque SB9, trazendo informa็๕es do produto SB1    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		cQuery:= "SELECT DISTINCT B9_FILIAL, B9_COD, B9_DATA, B9_LOCAL, B1_DESC, B1_FILIAL, B1_TIPO, "
		cQuery+= "B1_POSIPI, B1_CODBAR, B5_FILIAL, B5_COD, B5_CODTRAM "
   		cQuery+= "FROM " +RetSqlName("SB9")+ " SB9 "
   		cQuery+= "JOIN " +RetSqlName("SB1")+ " SB1 ON "
   		cQuery+= "B9_COD = B1_COD JOIN " +RetSqlName("SB5")+ " SB5 ON "
   		cQuery+= "B9_COD = B5_COD WHERE B9_DATA = '"+aInfo[1][1]+"' AND " 	 		   
   		cQuery+= "B9_FILIAL = '"+xFilial("SB9")+"' AND "
   		cQuery+= "B1_FILIAL = '"+xFilial("SB1")+"' AND "
		cQuery+= "B5_FILIAL = '"+xFilial("SB5")+"' AND " 
		cQuery+= "B5_CODTRAM <> '' AND "      
   		cQuery+= "SB9.D_E_L_E_T_ = '' AND "
 		cQuery+= "SB1.D_E_L_E_T_ = '' AND "   
   		cQuery+= "SB5.D_E_L_E_T_ = '' "    		
		cQuery+= "ORDER BY "+SqlOrder(SB9->(IndexKey()))				
		cQuery 		:= ChangeQuery(cQuery)    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤomฟ
		//ณCria o arquivo temporแrio baseado nas caracterํsticas daณ
		//ณtabela (aStruTMP) e gerando os registros de acordo com  ณ
		//ณo resultado da query                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤomู
		For nSB9 := 1 To Len(aStruTMP)
			If aStruTMP[nSB9][2] <> "C" .and. FieldPos(aStruTMP[nSB9][1]) > 0
				TcSetField(cAliasTMP,aStruTMP[nSB9][1],aStruTMP[nSB9][2],aStruTMP[nSB9][3],aStruTMP[nSB9][4])
			EndIf
		Next nSB9
	Else                                        

#ENDIF                    
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFaz a busca nas movimenta็๕es de saldo atualizado doณ
		//ณestoque SB9  								       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	SB9->(IndexKey())
		cFiltro :=  "B9_FILIAL =='" +xFilial("SB9")+ "'.And. DtoS(B9_DATA) =='" +(aInfo[1][1])+"'"				
		IndRegua(cAliasTMP,cArqInd,cChave,,cFiltro,"Selecionando Registros")
	   	#IFNDEF TOP 
	   		nIndex := RetIndex("SB9")+1
			DbSetIndex(cArqInd+OrdBagExt())
			DbSelectArea("SB1")
			DbSetOrder(1)
	    	DbSelectArea("SB5")
			DbSetOrder(1)						
		#ENDIF              
		(cAliasTMP)->(dbGotop())		  
#IFDEF TOP
	Endif    
#ENDIF    

dbSelectArea(cAliasTMP)
ProcRegua(LastRec())
(cAliasTMP)->(DbGoTop())

While (cAliasTMP)->(!Eof())                  
	IncProc()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravo no arquivo temporแrio o conte๚do dos campos que ณ
	//ณserใo usados na leitura do arquivo DIAMA.ini          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
    aProduto := {} // limpo  a variแvel para o novo SB9
	aArea1 := GetArea()
	If  lQuery
		
		If !(cAliasTMP)->B1_TIPO$"PA/AI" // excluindo produto acabado e ativo imobilizado ( nใo faria sentido ser um componente)
		   ProcAcabado((cAliasTMP)->B9_COD ,STOD(aInfo[1][1]),(cAliasTMP)->B9_COD)
		EndIf

    	RecLock("TMP",.T.)
        TMP->CODINT   := (cAliasTMP)->B9_COD
       	TMP->DESCINT  := (cAliasTMP)->B1_DESC
    	TMP->CODTPTRI := (cAliasTMP)->B5_CODTRAM

    	If !Empty((cAliasTMP)->B1_POSIPI)
			TMP->INDCODGE	:= 1
	  		TMP->CODGERAL	:= (cAliasTMP)->B1_POSIPI
		ElseIf !Empty((cAliasTMP)->B1_CODBAR) .And. Val((cAliasTMP)->B1_CODBAR)>0
			TMP->INDCODGE	:= 2
	  		TMP->CODGERAL	:= StrZero(Val((cAliasTMP)->B1_CODBAR))
		EndIf
    	MsUnLock()

	Else
		SB5->(DbSeek(xFilial("SB5")+(cAliasTMP)->B9_COD))
		If Empty(SB5->B5_CODTRAM)
			(cAliasTMP)->(dbSkip())
			loop
	  	Endif
	  	If SB1->(DbSeek(xFilial("SB1")+(cAliasTMP)->B9_COD))
	  		If !SB1->B1_TIPO$"PA/AI" // excluindo produto acabado e ativo imobilizado ( nใo faria sentido ser um componente)
		   		ProcAcabado((cAliasTMP)->B9_COD, STOD(aInfo[1][1]),(cAliasTMP)->B9_COD)
			EndIf
		  	RecLock("TMP",.T.)
      		TMP->CODINT  := SB1->B1_COD
	       	TMP->DESCINT := SB1->B1_DESC
	    	TMP->CODTPTRI := SB5->B5_CODTRAM

	    	If !Empty(SB1->B1_POSIPI)
				TMP->INDCODGE	:= 1
		  		TMP->CODGERAL	:= SB1->B1_POSIPI
			ElseIf !Empty(SB1->B1_CODBAR) .And. Val(SB1->B1_CODBAR)>0
				TMP->INDCODGE	:= 2
		  		TMP->CODGERAL	:= StrZero(Val(SB1->B1_CODBAR))
			EndIf

	    	MsUnLock()
    	EndIf
	Endif
	RestArea(aArea1)
	(cAliasTMP)->(dbSkip())
Enddo

If !lQuery
	RetIndex("SB9")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif	

// Abaixo preencho o temporแrio com o ativo permanente

DbSelectArea(cAliasF9)
(cAliasF9)->(DbSetOrder(1))
DbSelectArea(cAliasD1)
(cAliasD1)->(DbSetOrder(1))
DbSelectArea(cAliasB1)
(cAliasB1)->(DbSetOrder(1))
DbSelectArea(cAliasB5)
(cAliasB5)->(DbSetOrder(1))

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
		lQuery 	:= .T.
		cAliasF9 := GetNextAlias()

		BeginSql Alias cAliasF9
			
			SELECT			    
				SF9.F9_CODIGO,
				SD1.D1_COD,
				SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_CODBAR,
				SB5.B5_CODTRAM 
			FROM 
				%Table:SF9% SF9
				JOIN %Table:SD1% SD1 ON(SD1.D1_FILIAL=%xFilial:SD1% AND SD1.D1_SERIE=SF9.F9_SERNFE AND SD1.D1_DOC=SF9.F9_DOCNFE AND SD1.D1_FORNECE=SF9.F9_FORNECE AND SD1.D1_LOJA=SF9.F9_LOJAFOR AND SD1.D1_ITEM=SF9.F9_ITEMNFE AND SD1.%NotDel%)
				JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1% AND SB1.B1_COD=SD1.D1_COD AND SB1.%NotDel%)
				JOIN %Table:SB5% SB5 ON(SB5.B5_FILIAL=%xFilial:SB5% AND SB5.B5_COD=SB1.B1_COD AND SB5.B5_CODTRAM <>' ' AND SB5.%NotDel%)
			WHERE
				SF9.F9_FILIAL=%xFilial:SF9% AND
				NOT (SF9.F9_BXICMS <> 0 AND SF9.F9_MOTIVO <> '3' AND SF9.F9_BAIXAPR = ' ') 	AND
				NOT (SF9.F9_BXICMS <> 0 AND SF9.F9_MOTIVO = '3') 							AND
				NOT (SF9.F9_SLDPARC = 0 AND SF9.F9_MOTIVO = ' ' AND SF9.F9_QTDPARC <> 0) 	AND
				SF9.%NotDel%
		EndSql
	Else
#ENDIF 
	cArqInd	:= CriaTrab(NIL,.F.)
    cFiltro	:= 'F9_FILIAL=="'+xFilial("SF9")+'" .And. '
	cFiltro += '!(F9_BXICMS<>0.AND.F9_MOTIVO<>"3".AND.Empty(F9_BAIXAPR)) .And.'
	cFiltro += '!(F9_BXICMS<>0.AND.F9_MOTIVO=="3") .And.'
	cFiltro += '!(EMPTY(F9_MOTIVO).AND.F9_SLDPARC==0.AND.F9_QTDPARC<>0)'

    IndRegua(cAliasF9, cArqInd, SF9->(IndexKey()),, cFiltro)
    nIndex := RetIndex(cAliasF9)

	#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
	#ENDIF

	DbSelectArea(cAliasF9)
    DbSetOrder(nIndex+1)
    (cAliasF9)->(dbGoTop())
#IFDEF TOP
	Endif
#ENDIF  

DbSelectArea(cAliasF9)

If lQuery
	cAliasB5 := cAliasB1 := cAliasD1 := cAliasF9
Else
	DbSelectArea(cAliasD1)
	DbSelectArea(cAliasB1)
	DbSelectArea(cAliasB5)
EndIf

Do While (cAliasF9)->( !Eof() )
    
	If !lQuery
		cChaveD1 := xFilial("SD1")+(cAliasF9)->F9_DOCNFE+(cAliasF9)->F9_SERNFE+(cAliasF9)->F9_FORNECE+(cAliasF9)->F9_LOJAFOR
		lSd1 := .F.
		If (cAliasD1)->(MsSeek( cChaveD1 ))
			
			While (cAliasD1)->( !EoF() ) .And. cChaveD1 == (cAliasD1)->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)
				If (cAliasF9)->F9_ITEMNFE == (cAliasD1)->D1_ITEM
					lSd1 := .T.
					Exit
				EndIf
				(cAliasD1)->( DbSkip() )
			EndDo
			
			If lSd1
				If 	(cAliasB1)->(!MsSeek(xFilial("SB1")+(cAliasD1)->D1_COD)) .Or.;
					(cAliasB5)->(!MsSeek(xFilial("SB5")+(cAliasB1)->B1_COD)) .Or.;
					Empty((cAliasB5)->B5_CODTRAM)
					
					(cAliasF9)->(DbSkip())
					Loop
					
				EndIf
			Else
				(cAliasF9)->(DbSkip())
				Loop
			EndIf
		Else
			(cAliasF9)->(DbSkip())
			Loop
		EndIf
	EndIf
	
	If TMP->(!MsSeek((cAliasB1)->B1_COD))
		RecLock("TMP",.T.)
	 	TMP->CODINT  	:= (cAliasB1)->B1_COD
	 	TMP->DESCINT 	:= (cAliasB1)->B1_DESC
	  	TMP->CODTPTRI 	:= (cAliasB5)->B5_CODTRAM
    	If !Empty((cAliasB1)->B1_POSIPI)
			TMP->INDCODGE	:= 1
	  		TMP->CODGERAL	:= (cAliasB1)->B1_POSIPI
		ElseIf !Empty((cAliasB1)->B1_CODBAR) .And. Val((cAliasB1)->B1_CODBAR)>0
			TMP->INDCODGE	:= 2
	  		TMP->CODGERAL	:= StrZero(Val((cAliasB1)->B1_CODBAR))
		EndIf	  	
	   	MsUnLock()
    EndIf
    
	(cAliasF9)->(DbSkip())
EndDo

If !lQuery
	RetIndex("SF9")	
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasF9)
	dbCloseArea()
Endif

Return(aTemp)                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณStructTMP บAutor  ณCamila Januแrio       บ Data ณ 15/06/2012บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a estrutura da tabela temporaria                       บฑฑ
ฑฑบ          ณ					                         				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณDIA - Amazonas                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function StructTMP()

Local aTemp 	:= {}
Local aCab		:= {}
Local cArqCab	:= "" 
Local aAcabado	:= {}
Local cArqAca	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a estrutura TMP da tabela temporaria, com suas respectivasณ
//ณcaracterํsticas de tipo, tamanho, picture                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                     
AADD(aCab,{"CODINT"  	,"C",15,0})
AADD(aCab,{"DESCINT"	,"C",40,0})
AADD(aCab,{"CODTPTRI"	,"C",4,0})
AADD(aCab,{"INDCODGE"	,"N",1,0})
AADD(aCab,{"CODGERAL"	,"C",20,0})

cArqCab	:=	CriaTrab(aCab)
dbUseArea(.T.,__LocalDriver,cArqCab,"TMP")
IndRegua("TMP",cArqCab,"CODINT")

AADD(aAcabado,{"CODPROD"  	,"C",15,0})
AADD(aAcabado,{"CODACAB"	,"C",15,0})

cArqAca	:=	CriaTrab(aAcabado)
dbUseArea(.T.,__LocalDriver,cArqAca,"ACA")
IndRegua("ACA",cArqAca,"CODPROD+CODACAB")

aTemp	:=	{{cArqCab,"TMP"},{cArqAca,"ACA"}}

Return(aTemp)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณDIAMATMPDEL บAutor ณ Camila Januแrio    บ Data ณ 15/06/2012 บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณApaga arquivos temporarios criados para gerar o arquivo XML. บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณDIA - Amazonas                                               บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DiamaTmpDel(aDelArqs)

Local aAreaDel	:= GetArea()
Local nI 		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApaga o arquivo logicamente e limpa a แrea selecionadaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetInscEmp  บAutor  ณCamila Januแrio   บ Data ณ  03/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata o M0_INSC                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIA - Amazonas                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetInscEmp(cArg1)

Local cChar := ""
Local cSimb := ".-_/"
Local nX    := 1
Local nY    := 1
 
For nX := 1 To Len(cArg1)
	cChar:=SubStr(cArg1, nX, 1)
	IF cChar<> " "
		nY := At(cChar, cSimb)
		If nY > 0
			cArg1:=StrTran(cArg1,cChar,SubStr("", nY % 11,1))
		Endif
	Endif	
Next nX

Return cArg1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcAcabado  บAutor  ณCaio Oliveira    บ Data ณ  19/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mota arquivo de produtos acabados                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIA - Amazonas                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProcAcabado(cProdOri, dDtInv, cProd)
Local lTop		:= .F.
Local cAliasG1	:= "SG1"
Local cAliasB1	:= "SB1"
Local cFiltro	:= ""
Local cArqInd	:= ""
Local nIndex	:= 0

//select na sg1 com cprod buscando o PRODUTO_FINAL
// se tem resultado -- loop no resultado
	// verifico se cProdFinal ้ PA ou ATIVO
		//se for gravo no ACA->
	// else
		// procacabado (cProdOri, dDtIncv, PRODUTO_FINAL)
	// acabou
//Else
	// se nใo achou resulado, logo ้ o topo da estrutura, mesmo que B1_TIPO <> "PA", entใo gravo no ACA->
// acabou

DbSelectArea(cAliasG1)
(cAliasG1)->(DbSetOrder(1))
#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
		lTop 	:= .T.
		cAliasG1 := GetNextAlias()

		BeginSql Alias cAliasG1
			
			COLUMN G1_FIM AS DATE
			
			SELECT			    
				SG1.G1_COD, SG1.G1_COMP, SG1.G1_FIM,
				SB1.B1_COD, SB1.B1_TIPO
			FROM 
				%Table:SG1% SG1
				JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1% AND SB1.B1_COD=SG1.G1_COD AND SB1.%NotDel%)
			WHERE
				SG1.G1_FILIAL=%xFilial:SG1% 				AND 
				SG1.G1_COMP	= %Exp:cProd%	 				AND
				SG1.G1_FIM  > %Exp:DToS(dDtInv)%		 	AND
				SG1.%NotDel%
		EndSql

	Else
#ENDIF 
	cArqInd	:= CriaTrab(NIL,.F.)
    cFiltro	:= 'G1_FILIAL=="'+xFilial("SG1")+'" .And. '
   	cFiltro += 'G1_COMP=="'+cProd+'" .And. DToS(G1_FIM)>"'+DToS(dDtInv)+'"
	
    IndRegua(cAliasG1, cArqInd, SG1->(IndexKey()),, cFiltro)
    nIndex := RetIndex(cAliasG1)

	#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
	#ENDIF
	
	DbSelectArea(cAliasG1)
    DbSetOrder(nIndex+1)
    (cAliasG1)->(dbGoTop())
#IFDEF TOP
	Endif
#ENDIF  

DbSelectArea(cAliasG1)
If lTop
	cAliasB1 := cAliasG1
Else
	DbSelectArea(cAliasB1)
EndIf

If (cAliasG1)->( !Eof() )
	While (cAliasG1)->( !Eof() )
        
        If !lTop
        	(cAliasB1)->( MsSeek(xFilial("SB1")+(cAliasG1)->G1_COD ))
        EndIf
		If (cAliasB1)->B1_TIPO$"PA/AI"
			If ACA->( !MsSeek(cProdOri+(cAliasG1)->G1_COD) )
				RecLock("ACA",.T.)
			 	ACA->CODPROD  	:= cProdOri
			 	ACA->CODACAB 	:= (cAliasG1)->G1_COD
			   	MsUnLock()
			EndIf
		Else
			//uso o aScan em uma variแvel private apenas para economizar processamento,pois o mesmo produto pode 
			// estar mais de uma estrutura, e nใo precisarei pesquisar mais de uma vez
			If aScan(aProduto, (cAliasG1)->G1_COD )==0 
				Aadd(aProduto, (cAliasG1)->G1_COD )
				ProcAcabado(cProdOri, dDtInv, (cAliasG1)->G1_COD)
			EndIf
		Endif

		(cAliasG1)->( dbSkip() )
	EndDo
Else
	If ACA->( !MsSeek(cProdOri+cProd) )
		RecLock("ACA",.T.)
	 	ACA->CODPROD  	:= cProdOri
	 	ACA->CODACAB 	:= cProd
	   	MsUnLock()
	EndIf
EndIf

If !lTop
	RetIndex("SG1")
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasG1)
	dbCloseArea()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXmlProdAca   บAutor  ณCaio Oliveira    บ Data ณ  19/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mota arquivo de produtos acabados                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIA - Amazonas                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function XmlProdAca(cProd)
Local cXml 	:= ""
Local nX	:= 0
//seek em ACA com cProd
//loop enquanto ACA->CODPROD == cProd
	// cXml += "<codProdutoAcabado>"+Alltrim(ACA->CODACAB)+"</codProdutoAcabado>"
	// cXml += MontaXML("codProdutoAcabado",Alltrim(ACA->CODACAB),"C",15 ,,,,.T.,.T.,.T.)
// final do Loop
If ACA->(MsSeek(cProd))
	While ACA->( !EoF() ) .And. ACA->CODPROD==cProd
		cXml += MontaXML("codProdutoAcabado",Alltrim(ACA->CODACAB),"C",15 ,,,,.T.,.T.,.T.)
		nX++
		If nX == 999 //limite xml da tag codProdutoAcabado por produto
			Exit
		EndIf
		ACA->( DbSkip() )
	EndDo
EndIf

Return cXml