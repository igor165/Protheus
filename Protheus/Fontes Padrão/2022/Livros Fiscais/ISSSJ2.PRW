#Include "Protheus.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISSSJTMP  บAutor  ณRodrigo Zatt        บ Data ณ 11/12/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a estrutura das notas fiscais a serem apresentadas    บฑฑ
ฑฑบ          ณcabecalho								                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA950                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ISSSJTMP(dDataIni,dDataFin,cTomPres)
     
Local aTemp 		:= SJGeraTmp(dDataIni,dDataFin)
Local cAliasSF3		:= "SF3"
Local cISSRet		:= ""
Local cMunic		:= GetNewPar("MV_CIDADE","")
Local cMun			:= ""
Local cTipo			:= ""    
Local cNome         := ""
Local cCodCid       := ""
Local cMvMunCli     := GetNewPar("MV_CMUNCLI","")
Local cMvMunFor     := GetNewPar("MV_CMUNFOR","")
Local cMvEstCli     := GetNewPar("MV_SCESTC","")
Local cMvEstFor     := GetNewPar("MV_SCESTF","")

Local lQuery		:= .F.
Local lMvF3rec      := GetNewPar("MV_F3RECIS",.F.)

Local nId			:= 0

#IFDEF TOP

	Local aCamposSF3	:= {}
	Local aStruSF3		:= {}
	
	Local cQuery		:= ""
	Local cCmpQry		:= ""
	
	Local nX			:= 0

#ELSE

	Local cArqInd		:= ""
	Local cChave		:= ""
	Local cFiltro		:= ""
	
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessamento dos documentos Fiscais                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP
  
    If TcSrvType()<>"AS/400"
   
		aAdd(aCamposSF3,"F3_FILIAL")
		aAdd(aCamposSF3,"F3_ENTRADA")
		aAdd(aCamposSF3,"F3_NFISCAL")
		aAdd(aCamposSF3,"F3_SERIE")
		aAdd(aCamposSF3,"F3_CLIEFOR")
		aAdd(aCamposSF3,"F3_LOJA")
		aAdd(aCamposSF3,"F3_ALIQICM")
		aAdd(aCamposSF3,"F3_ESPECIE")
		aAdd(aCamposSF3,"F3_ISENICM")
		aAdd(aCamposSF3,"F3_VALCONT")
		aAdd(aCamposSF3,"F3_TIPO")
		aAdd(aCamposSF3,"F3_CFO")
		aAdd(aCamposSF3,"F3_VALICM")
		aAdd(aCamposSF3,"F3_DOCOR")
		aAdd(aCamposSF3,"F3_EMISSAO")
		aAdd(aCamposSF3,"F3_CODISS")
		aAdd(aCamposSF3,"F3_DTCANC")
		aAdd(aCamposSF3,"F3_RECISS")
		aAdd(aCamposSF3,"F3_CNAE")		
		
		If SerieNfId("SF3",3,"F3_SERIE") == "F3_SDOC"	
     		aAdd(aCamposSF3,"F3_SDOC")       
      EndIf
               
    	aStruSF3  := SF3->(SJStr(aCamposSF3,@cCmpQry))
    	SF3->(dbCloseArea())

		lQuery    := .T.
		cAliasSF3 := "SF3"
		
		cQuery    := "SELECT "
		cQuery    += cCmpQry
		cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
		cQuery    += "WHERE "
		cQuery    += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery    += "F3_ENTRADA >= '" + Dtos(dDataIni) + "' AND "
		cQuery    += "F3_ENTRADA <= '" + Dtos(dDataFin) + "' AND "
		If cTomPres == "P"
			cQuery    += "F3_CFO >= '5' AND "
		Else
			cQuery    += "F3_CFO < '5' AND "
		Endif
		cQuery    += "(F3_TIPO = 'S' OR "
	 	cQuery    += "(F3_TIPO = 'L' AND F3_CODISS <> '')) "
		cQuery    += "ORDER BY F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
	
	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" 
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSF3)	
	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
		cFiltro :=  "F3_FILIAL == '" + xFilial("SF3") + "' .And. 
		cFiltro	+=	"DtoS(F3_ENTRADA) >= '" + DtoS(dDataIni) + "' .And. DtoS(F3_ENTRADA) <= '" + DtoS(dDataFin) + "' .And. "
		If cTomPres == "P"
			cFiltro   += "F3_CFO >= '5' .And. "
		Else
			cFiltro   += "F3_CFO < '5' .And. "
		Endif
		cFiltro	+=	"(F3_TIPO == 'S' .Or. "
		cFiltro	+=	"(F3_TIPO == 'L' .And. !EMPTY(F3_CODISS))) "
			
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros")
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF3)->(dbGotop())

#IFDEF TOP
	Endif    
#ENDIF

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SF2->(dbSetOrder(1))
SF1->(dbSetOrder(1))

dbSelectArea(cAliasSF3)
ProcRegua(LastRec())
(cAliasSF3)->(DbGoTop())

While (cAliasSF3)->(!Eof())                  

	IncProc()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica o cliente do movimentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cCNPJ		:= ""
	If SubStr((cAliasSF3)->F3_CFO,1,1) $ "567"
		If !(SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)))
			(cAliasSF3)->(dbSkip())
			Loop
		Endif 
		cCNPJ		:= SA1->A1_CGC
		cISSRet 	:= SA1->A1_RECISS
		If Empty(cISSRet)
			cISSRet := "2"
		Endif
		cNome       := SA1->A1_NOME
		cMun		:= SA1->A1_MUN
		cTipo		:= RetPessoa(SA1->A1_CGC)
		cCodCid		:= (&(cMvEstCli))+(&(cMvMunCli))
		cMunServ    := (&(cMvEstCli))+(&(cMvMunCli))
		cTpNota		:= "S"

		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
	    	cPrefixo	:= 	Iif (Empty (SF2->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal de Entrada
        	SE2->(dbSetOrder(1))
        	If SE2->(dbSeek(xFilial("SE2")+cPrefixo+SF2->F2_DUPL)) .And. AllTrim(SE2->E2_NATUREZ) == Alltrim(&(SuperGetMv("MV_ISS"))) .And. SE2->E2_TIPO==MVTAXA
	        	SA2->(dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
				cMunServ := (&(cMvEstCli))+(&(cMvMunCli))
        	Endif
    	EndIf
	Else
		If !(SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)))
			(cAliasSF3)->(dbSkip())
			Loop
		Endif 
		cCNPJ		:= SA2->A2_CGC
		cISSRet 	:= SA2->A2_RECISS
		If Empty(cISSRet)
			cISSRet := "1"
		Endif
		cNome       := SA2->A2_NOME
		cMun		:= SA2->A2_MUN
		cTipo		:= RetPessoa(SA2->A2_CGC)
		cCodCid		:= (&(cMvEstFor))+(&(cMvMunFor))
		cMunServ    := (&(cMvEstFor))+(&(cMvMunFor))
		cTpNota		:= "E"
		
		If SF1->(dbSeek(xFilial("SF1")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
		    cPrefixo	:= 	Iif (Empty (SF1->F1_PREFIXO), &(SuperGetMV ("MV_2DUPREF")), SF1->F1_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal de Entrada
		    SE2->(dbSetOrder(1))
	        If SE2->(dbSeek(xFilial("SE2")+cPrefixo+SF1->F1_DUPL))
	        	cChavSe2	:=	xFilial("SE2")+cPrefixo+SF1->F1_DUPL
	        	While !SE2->(Eof()) .And. cChavSe2==xFilial("SE2")+cPrefixo+SF1->F1_DUPL
        	    	If AllTrim(SE2->E2_NATUREZ) == Alltrim(&(SuperGetMv("MV_ISS")))
	        	    	SA2->(dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
        	    		cMunServ := (&(cMvEstFor))+(&(cMvMunFor))
        	    		Exit
        	    	EndIf
        	    	SE2->(dbSkip())
        	 	End
	        Endif 
		EndIf
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCabecalho do documentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !SJ2->(dbSeek(DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+cTomPres))

		RecLock("SJ2",.T.)
		
		nId += 1

	   	SJ2->ID_CAB		:= StrZero(nId,10)	    
        SJ2->IDENTRE	:= cTomPres
        SJ2->INSCR		:= cCNPJ
        SJ2->NOME		:= cNome
        SJ2->SERIE		:= (cAliasSF3)->F3_SERIE
        SJ2->SDOC		:= SerieNfId(cAliasSF3,2,"F3_SERIE")
        SJ2->NFINI		:= (cAliasSF3)->F3_NFISCAL
        SJ2->NFFIM		:= (cAliasSF3)->F3_NFISCAL
        SJ2->EMISSAO	:= (cAliasSF3)->F3_EMISSAO
        SJ2->TIPOREC	:= "N"
       	If !Empty ((cAliasSF3)->F3_DTCANC)                 // Notas canceladas
       		SJ2->SITUACAO	:= "C"
        Else
        	If lMvF3rec .And.(cAliasSF3)->F3_RECISS$"1,S"  // Verifica pela Tabela SF3
	            	SJ2->SITUACAO	:= "R"
	        	ElseIf !lMvF3rec .And. cISSRet$"1,S" 
	        		SJ2->SITUACAO	:= "R"                  // Verifica pela tabela SA1 e SA2 
	        	ElseIf (cAliasSF3)->F3_ISENICM<>0          // Isento 
	        		SJ2->SITUACAO	:= "I"	
	        	Else
					SJ2->SITUACAO	:= "N"                  // Normal Recolhe 
		  	Endif	
		Endif    
        SJ2->VLRBRUTO	:= (cAliasSF3)->F3_VALCONT
        If Alltrim(cMunic)==Alltrim(cMun)
        	SJ2->LOCALIZA	:="D"
        Else
        	SJ2->LOCALIZA	:="F"
        Endif        
        SJ2->CIDADE		:= cCodCid   
 
		MsUnLock()
		
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCnae + Valor do Servico do movimentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("SJ3",.T.)
	
	SJ3->ID_CAB		:= StrZero(nId,10)                                     
 
		SJ3->ATIVID		:= (cAliasSF3)->F3_CNAE
     	SJ3->VALSERV	:= (cAliasSF3)->F3_VALCONT 
        SJ3->CODCID  	:= cMunServ
	
	MsUnLock()
	
	(cAliasSF3)->(dbSkip())

Enddo          

If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

Return(aTemp)                       
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSJGeraTmp บAutor  ณRodrigo Zatt        บ Data ณ 11/12/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria as tabelas temporarias                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaTemp: [01] Alias do temporario                             บฑฑ
ฑฑบ          ณ       [02] Nome fisico da tabela temporaria                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA950			    			                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SJGeraTmp()

Local aTemp 	:= {}
Local aCab		:= {}
Local aAliq		:= {}

Local cArqCab	:= ""
Local cArqAliq	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCabecalho do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aCab,{"ID_CAB"		,"C",010,0})
AADD(aCab,{"IDENTRE"	,"C",001,0})
AADD(aCab,{"INSCR"		,"C",014,0})
AADD(aCab,{"NOME"		,"C",050,0})
AADD(aCab,{"SERIE"  	,"C",TamSx3("F3_SERIE")[1],0})
AADD(aCab,{"NFINI"		,"C",009,0})
AADD(aCab,{"NFFIM"		,"C",009,0})
AADD(aCab,{"EMISSAO"	,"D",008,0})
AADD(aCab,{"TIPOREC"	,"C",001,0})
AADD(aCab,{"SITUACAO"	,"C",001,0})
AADD(aCab,{"VLRBRUTO"	,"N",015,2})
AADD(aCab,{"LOCALIZA"	,"C",001,0})
AADD(aCab,{"CIDADE" 	,"C",007,0})
AADD(aCab,{"SDOC"  	,"C",006,0})

cArqCab	:=	CriaTrab(aCab)
dbUseArea(.T.,__LocalDriver,cArqCab,"SJ2")
IndRegua("SJ2",cArqCab,"DTOS(EMISSAO)+NFINI+SERIE+IDENTRE")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCod CNAE e Valor             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aAliq,{"ID_CAB"	,"C",010,0})
AADD(aAliq,{"ATIVID"	,"C",009,0})
AADD(aAliq,{"VALSERV"	,"N",015,2})
AADD(aAliq,{"CODCID"	,"C",007,0})
cArqAliq	:=	CriaTrab(aAliq)
dbUseArea(.T.,__LocalDriver,cArqAliq,"SJ3")
IndRegua("SJ3",cArqAliq,"ID_CAB")

aTemp	:=	{{cArqCab,"SJ3"},{cArqAliq,"SJ3"}}

Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณSJDelArq   บAutor  ณ Rodrigo Zatt       บ Data ณ 11/12/2007  บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณApaga arquivos temporarios criados para gerar o arquivo      บฑฑ
ฑฑบ         ณMagnetico                                                    บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณMATA950			                                          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SJDelArq(aDelArqs)

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSJStr     บAutor  ณRodrigo Zatt        บ Data ณ 11/12/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontar um array apenas com os campos utiLizados na query    บฑฑ
ฑฑบ          ณpara passagem na funcao ISSSJTMP                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณArray com os campos da query                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaCampos: campos a serem tratados na query                   บฑฑ
ฑฑบ          ณcCmpQry: string contendo os campos para select na query     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA950                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
#IFDEF TOP

	Static Function SJStr(aCampos,cCmpQry)
	
	Local	aRet	:=	{}
	Local	nX		:=	0
	Local	aTamSx3	:=	{}
	
	For nX := 1 To Len(aCampos)

		aTamSx3 := TamSX3(aCampos[nX])
		aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
		cCmpQry	+=	aCampos[nX]+", "

	Next(nX)
	
	If(Len(cCmpQry)>0)
		cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
	EndIf 
		
	Return(aRet)        
	
#ENDIF
