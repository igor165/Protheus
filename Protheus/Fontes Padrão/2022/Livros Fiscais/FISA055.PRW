#Include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFISA055 บAutor  ณCamila Januแrio      บ Data ณ 24/09/2012   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo temporแrio de movimenta็๕es a serem apresenta- บฑฑ
ฑฑบ          ณdos no CPOM-Cadastro de Prestadores de Outros do Municํpios บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPrefeitura de SP-Cadastro de Prestadores de Servicos Outros บฑฑ
ฑฑบ          ณmunicํpios 												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fisa055(dDataIni,dDataAte,aInfo)

Local aTemp 	 := StructTMP()
Local aAreaAtu 	 := {}
Local aArea1     := {}
Local aCod 		 := {} 
Local cQuery     := ""
Local cAliasTmp  := "SF3"
Local cMunicip   := "50308" //Sใo Paulo 
Local nX		 := 1
Local nSF3 		 := 0
Local nIndex     := 1
Local lQuery	 := .F.
Local lGrava     := .F.
  

#IFDEF TOP
	Local aStruTMP	:= {}
	nX          	:= 0
#ELSE
	Local cArqInd	:= ""
	Local cChave	:= ""
	Local cFiltro	:= ""	
#ENDIF

dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP  
    If TcSrvType()<>"AS/400"    
	    cAliasTMP	:= GetNextAlias()
	   	lQuery    	:= .T.
		aStruTMP  	:= SF3->(dbStruct())
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFaz a busca no livro fiscal SF3 juntamente com o SA2 para    ณ
		//ณtrazer as informa็๕es dos fornecedores que prestaram servicosณ
		//ณno periodo informado nos parametros                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery:= "SELECT DISTINCT F3_FILIAL, F3_ENTRADA, F3_TIPO, F3_CLIEFOR, "
		cQuery+= "F3_LOJA, F3_CODISS, F3_ESTADO, A2_COD, A2_LOJA, A2_EST, A2_CGC, "
		cQuery+= "A2_FILIAL, A2_NOME, A2_NR_END, A2_BAIRRO, A2_END, "
		cQuery+= "A2_COD_MUN, A2_MUN, A2_CEP, A2_COMPLEM"
		cQuery+= " , A2_TPLOGR, A2_CPOMSP"
   		cQuery+= " FROM " +RetSqlName("SF3")+ " SF3 "
   		cQuery+= "LEFT JOIN " +RetSqlName("SA2")+ " SA2 ON "
   		cQuery+= "F3_CLIEFOR = A2_COD AND F3_LOJA = A2_LOJA WHERE "	   		
   		cQuery+= "F3_FILIAL = '"+xFilial("SF3")+"' AND "
   		cQuery+= "A2_FILIAL = '"+xFilial("SA2")+"' AND " 
   		cQuery+= "A2_COD_MUN <> '"+cMunicip+"' AND "    		
   		cQuery+= "F3_ENTRADA >= '"+DTOS(dDataIni)+"' AND " 
   		cQuery+= "F3_ENTRADA <= '"+DTOS(dDataFim)+"' AND "
		cQuery+= "F3_CLIEFOR >= '"+aInfo[1][1]+"' AND "             
   		cQuery+= "F3_CLIEFOR <= '"+aInfo[1][2]+"' AND "             
		cQuery+= "F3_LOJA >= '"+aInfo[1][3]+"' AND " 
   		cQuery+= "F3_LOJA <= '"+aInfo[1][4]+"' AND "  
   		cQuery+= "F3_TIPO = 'S' AND "
	   	cQuery+= "A2_CPOMSP <> '1' AND "
   		cQuery+= "SF3.D_E_L_E_T_ = '' AND "
 		cQuery+= "SA2.D_E_L_E_T_ = '' "   
		cQuery+= "ORDER BY F3_FILIAL, F3_ENTRADA"
					
		cQuery	:= ChangeQuery(cQuery)    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤomฟ
		//ณCria o arquivo temporแrio baseado nas caracterํsticas daณ
		//ณtabela (aStruTMP) e gerando os registros de acordo com  ณ
		//ณo resultado da query                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤomู
		For nSF3 := 1 To Len(aStruTMP)
			If aStruTMP[nSF3][2] <> "C" .and. FieldPos(aStruTMP[nSF3][1]) > 0
				TcSetField(cAliasTMP,aStruTMP[nSF3][1],aStruTMP[nSF3][2],aStruTMP[nSF3][3],aStruTMP[nSF3][4])
			EndIf
		Next nSF3
	Else                                        

#ENDIF            
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFaz a busca na movimentacao do livro fiscal e traz as notas deณ
		//ณservico dos fornecedores e periodo informado                  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	SF3->(IndexKey())                                     
		cFiltro :=  "F3_FILIAL =='"+xFilial("SF3")+ "'.And. F3_ENTRADA >='"+DTOS(dDataIni)+"' .AND. F3_ENTRADA <='"+DTOS(dDataFim)+"' .And. "
		cFiltro +=  "F3_CLIEFOR >='"+aInfo[1][1]+"' .And. F3_CLIEFOR <='"+aInfo[1][2]+"' .AND. F3_LOJA >='"+aInfo[1][3]+"' .And. "
		cFiltro +=  "F3_LOJA <='"+aInfo[1][4]+"' .And. F3_TIPO == 'S' "
		IndRegua(cAliasTMP,cArqInd,cChave,,cFiltro,"Selecionando Registros")
	   	#IFNDEF TOP 
	   		nIndex := RetIndex("SF3")+1
			DbSetIndex(cArqInd+OrdBagExt())
			DbSelectArea("SF3")
			DbSetOrder(1)
	    	DbSelectArea("SA2")
			DbSetOrder(1)						
		#ENDIF              
		(cAliasTMP)->(dbGotop())		  
#IFDEF TOP
	Endif    
#ENDIF    

dbSelectArea(cAliasTMP)
ProcRegua(LastRec())
(cAliasTMP)->(DbGoTop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravo no arquivo temporแrio o conte๚do dos campos que ณ
//ณserใo usados na leitura do arquivo CPOMSP.ini          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While (cAliasTMP)->(!Eof())                  
	IncProc()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o servico esta entre os que devem gerar CPOM.ณ
	//ณA definicao dos servicos estao no paramentro MV_CODSERV  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If GetCodIss((cAliasTMP)->F3_CODISS) 
		lGrava := .T.
	Else
		lGrava := .F.
	Endif			
	If lGrava                      
		If lQuery
			RecLock("TMP",.T.)	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava o temporแrio TMP quando utilizado queryณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			TMP->CNPJ      := (cAliasTMP)->A2_CGC
			TMP->NOME      := (cAliasTMP)->A2_NOME
			TMP->TPLOGR    := IIF(lTPLOGR,(cAliasTMP)->A2_TPLOGR,"")			
			TMP->NOMELOG   := (cAliasTMP)->A2_END 
			TMP->NUMIMOV   := (cAliasTMP)->A2_NR_END
			TMP->COMPLEM   := (cAliasTMP)->A2_COMPLEM
			TMP->BAIRRO    := (cAliasTMP)->A2_BAIRRO
			TMP->MUNICIP   := (cAliasTMP)->A2_MUN
			TMP->ESTADO    := (cAliasTMP)->A2_EST
			TMP->CEP       := (cAliasTMP)->A2_CEP
			TMP->SERVICO   := (cAliasTMP)->F3_CODISS						
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava o temporแrio TMP quando utilizado dbf  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aArea1 := GetArea()
		    If SA2->(DbSeek(xFilial("SA2")+(cAliasTMP)->F3_CLIEFOR+(cAliasTMP)->F3_LOJA)) 
		    	If SA2->A2_CPOMSP <> "1" .AND. SA2->A2_COD_MUN <> cMunicip
	    			RecLock("TMP",.T.)
			    	TMP->CNPJ      := SA2->A2_CGC
					TMP->NOME      := SA2->A2_NOME
			   		TMP->TPLOGR    := IIF(lTPLOGR,SA2->A2_TPLOGR,"")
					TMP->NOMELOG   := SA2->A2_END 
					TMP->NUMIMOV   := SA2->A2_NR_END
					TMP->COMPLEM   := SA2->A2_COMPLEM
			   		TMP->BAIRRO    := SA2->A2_BAIRRO
			   		TMP->MUNICIP   := SA2->A2_MUN
			   		TMP->ESTADO    := SA2->A2_EST
			   		TMP->CEP       := SA2->A2_CEP
			   		TMP->SERVICO   := SF3->F3_CODISS 
			   	Endif			    
		    Endif       
		   	RestArea(aArea1) 	    	
		Endif       
		MsUnLock()
	Endif					
	(cAliasTMP)->(dbSkip())
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ       
//ณRetira os elementos de fornecedor repetidos caso tenhaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("TMP") 
("TMP")->(DbGoTop())
While ("TMP")->(!Eof())
	If AScan(aCod,TMP->CNPJ) == 0
   		AAdd(aCod,TMP->CNPJ)
   	Else
   		Reclock("TMP",.F.)
		("TMP")->(dbDelete())
		MsUnlock()
   	Endif   		
	("TMP")->(dbSkip())	
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFecha os alias e limpa os filtros dos alias utilizadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif	

Return(aTemp)                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณStructTMP บAutor  ณCamila Januแrio       บ Data ณ 24/09/2012บฑฑ
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a estrutura TMP da tabela temporaria, com suas respectivasณ
//ณcaracterํsticas de tipo, tamanho, picture                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                     
AADD(aCab,{"CNPJ"  	    ,"C",14,0})
AADD(aCab,{"NOME"  	    ,"C",40,0})
AADD(aCab,{"TPLOGR"	    ,"C",03,0})
AADD(aCab,{"NOMELOG"	,"C",40,0})      
AADD(aCab,{"NUMIMOV"	,"C",05,0})
AADD(aCab,{"COMPLEM"    ,"C",22,0})      
AADD(aCab,{"BAIRRO"	    ,"C",22,0})
AADD(aCab,{"MUNICIP"    ,"C",30,0})
AADD(aCab,{"ESTADO"  	,"C",02,0})
AADD(aCab,{"CEP"  		,"C",08,0})
AADD(aCab,{"SERVICO"	,"C",05,0})
AADD(aCab,{"OK"     	,"C",01,0})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCria o arquivo de trabalho logicamente e define o indice  ณ
//ณprocessamento                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cArqCab	:=	CriaTrab(aCab)
dbUseArea(.T.,__LocalDriver,cArqCab,"TMP")
IndRegua("TMP",cArqCab,"CNPJ")

aTemp	:=	{{cArqCab,"TMP"}}

Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณFis55Del บAutor ณ Camila Januแrio    บ Data ณ 24/09/2012     บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณApaga arquivos temporarios criados para gerar o arquivo XML. บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณCPOM-SP                                                      บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fis55Del(aDelArqs)

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
ฑฑบPrograma  ณFis55NoAc  บAutor  ณCamila Januแrio   บ Data ณ  24/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata o M0_CGC / CEP                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CPOM - SP	                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fis55NoAc(cParam)

Local cChar := ""
Local cSimb := ".-_/"
Local nX    := 1
Local nY    := 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ€
//ณFaz a busca de caracteres e simbolos como . - _ / e suprimeณ
//ณgerando nova string sem simbolos.                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ€ 
For nX := 1 To Len(cParam)
	cChar:=SubStr(cParam, nX, 1)
	IF cChar<> " "
		nY := At(cChar, cSimb)
		If nY > 0
			cParam:=StrTran(cParam,cChar,SubStr("", nY % 11,1))
		Endif
	Endif	
Next nX 

Return cParam


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCodISS   บAutor  ณCamila Januแrio     บ Data ณ  24/09/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o c๓digo de ISS estแ contido nos permitidos peloฑฑ
ฑฑบ          ณ parametro MV_CODSERV                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CPOMSP                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetCodIss(cCod)
Local lRet      := .F. 
Local lExiste   := GetMV("MV_CODSERV",.T.)

If lExiste
	If Alltrim(cCod) $ GetMV("MV_CODSERV")
		lRet :=.T.
	Endif
Endif

Return lRet


