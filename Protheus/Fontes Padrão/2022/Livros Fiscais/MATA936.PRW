#Include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัอออออออออออออออออออออออัออออออออออออออออออปฑฑ
ฑฑบPrograma  ณSIMPLES NACIONAL  บAutor  ณFlแvio Fernandes Neves บData ณ04/06/08    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯอออออออออออออออออออออออฯออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ		Declara็ใo do Simples Nacional -SP vs 0300   		   		   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera็ใo do Arquivo Magn้tico para declara็ใo do simples Nacional    บฑฑ                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                               
Function Mata936(cAls,aFilsCalc)
  
Local lRet := .T. 
Private lEnd	:=	.F.
Private	nHandle
Private cIndSF3	:= ""   
Default aFilsCalc:= { { .T., cFilAnt } }
  
If MontPainel()
	Processa({||a_Processa(@cAls,aFilsCalc)})
Else
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao	 ณa_Processa  บAutor  ณFlแvio Fernandes Neves บ Data ณ  04/06/08 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Faz o processamento de forma a montar os arquivos temporarios บฑฑ
ฑฑบ          ณpara carregar os Registros do Arquivo.                     	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Mata936                                                  	 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a_Processa(cAls, aFilsCalc)  

Local nForFilial:= 0
Local cFilOrig	:= cFilAnt
Local lFirst	:= .T.

Private aCfp := {}
Private cIndSF3	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Wizard com as perguntas                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
xMagLeWiz("Mata936",@aCfp,.T.)   
        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria arquivos temporarios       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaTmpa(@cAls)

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Monta arquivo de Trabalho                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Mont_Trab(lFirst)
		lFirst := .F.
	EndIf
Next
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava arquivo texto                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GerArquivo()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fecha arquivo texto                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
If nHandle >= 0
	FClose(nHandle)   
	//Apaga arquivos temporarios criados anteriormente
Endif

//ApagTrba(@cAls)      
cFilAnt := cFilOrig

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณAPAGTRBa   บAutor  ณ Flแvio Fernandes neves บ Data ณ  04/06/08   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Apaga arquivos temporarios criados para gerar o arquivo         บฑฑ
ฑฑบ         ณ Magnetico                                                       บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Mata936                                                         บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Function APAGTRBa(cAls)

If File(cAls+GetDBExtension())
	dbSelectArea("R55")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif  

If File(cAls+GetDBExtension())
	dbSelectArea("R01")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("R58")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("R60")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cals+GetDBExtension())
	dbSelectArea("R65")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif  

If File(cals+GetDBExtension())
	dbSelectArea("R70")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif 

If File(cAls+GetDBExtension())
	dbSelectArea("R75")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif 

If File(cAls+GetDBExtension())
	dbSelectArea("R76")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("R78")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif         

If File(cAls+GetDBExtension())
	dbSelectArea("R80")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif

If File(cAls+GetDBExtension())
	dbSelectArea("ARQ")
	dbCloseArea()
	Ferase(cAls+GetDBExtension())
	Ferase(cAls+OrdBagExt())
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFunctionณ Mont_Trab  บAutor  ณFlแvio Fernandes Neves บ Data ณ 04/06/08 บฑฑ
ฑฑฬออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.   ณArmazena as informacoes nos arquivos temporarios para depois  บฑฑ
ฑฑบ        ณgerar arquivo texto.                                          บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Mata936                                                     บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Mont_Trab(lFirst)
LOCAL cCodMun		:=	""  
LOCAL cCGC			:=	""
Local lQuery   		:= .F.
Local cAliasSF3 	:= "SF3"  
Local cMesAnt		:= ""    
Local cMesRef		:= ""    
Local cMvUF     	:= SuperGetMv("MV_ESTADO")
Local cCodUf    	:= "09#11#26"
Local aApuICM   	:= {}
Local aApuST    	:= {} 
Local aSumario  	:= {{0,0,0,0,0,0,0,0,0,0,0,0}}
Local cSumario 		:=""
Local nX        	:= 0
Local nY        	:= 0       
Local cSubCod   	:= "" 
Local cAnoBase 		:= Alltrim(aCfp[1][01])
Local lTms	   		:= .F.
Local cCNAE    		:= "" 
Local cUF      		:= ""
Local cMesCorr 		:= ""  
Local cDip11	:= GetNewPar("MV_DIP11","")
Local cDip13	:= GetNewPar("MV_DIP13","")

#IFDEF TOP
	Local nSF3	   	:= 0
#ENDIF	
	
Private cRegime  	:= "09" // Regime Padrao e unico para o Simples Nacional

Default lFirst		:= .T.

#IFDEF TOP
	If TcSrvType() <> "AS/400"
	    cAliasSF3:= "aMontTrab"
	   	lQuery    := .T.
		aStruSF3  := SF3->(dbStruct())		
		cQuery := "SELECT SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_DTCANC,SF3.F3_ESPECIE, "
		cQuery += "SF3.F3_TIPO,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_VALCONT,SF3.F3_BASEICM, "
		cQuery += "SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_ICMSRET, "
		cQuery += "SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_NFISCAL,SF3.F3_EMISSAO, "
		cQuery += "SF3.F3_SERIE,SF3.F3_TRFICM "
		cQuery += "FROM "
		cQuery += RetSqlName("SF3") + " SF3 "
		cQuery += "WHERE "
		cQuery += "SF3.F3_FILIAL = '"+xFilial("SF3")+"' AND "		
		cQuery += "SF3.F3_ENTRADA >= '"+DTOS(mv_par01)+"' AND "
		cQuery += "SF3.F3_ENTRADA <= '"+DTOS(mv_par02)+"' AND "
		cQuery += "SF3.F3_DTCANC =  '" +Dtos(Ctod("")) +"' AND "
		cQuery += "SF3.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)

		For nSF3 := 1 To Len(aStruSF3)
			If aStruSF3[nSF3][2] <> "C" 
				TcSetField(cAliasSF3,aStruSF3[nSF3][1],aStruSF3[nSF3][2],aStruSF3[nSF3][3],aStruSF3[nSF3][4])
			EndIf
		Next nSF3
	    
	Else
#ENDIF	 
		dbSelectArea(cAliasSF3)
		
		cIndSF3	:=	CriaTrab(NIL,.F.)
		cChave	:=	IndexKey()
		cFiltro	:=	"F3_FILIAL=='"+xFilial("SF3")+"'"
		cFiltro	+=	".And. DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"'"
        
		IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro,"DTREF")
#IFDEF TOP
	Endif
#ENDIF	

		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCabecalho do documento Fiscal - CR=55 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lFirst
	Cab55a() 
	MESTREa()
EndIf

While (cAliasSF3)->(!Eof()).and. xFilial("SF3")==(cAliasSF3)->F3_FILIAL
    
    If Substr((cAliasSF3)->F3_CFO,1,1)<"5"
	    SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
	Else
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
	EndIf

	cMesRef := SUBSTR(Dtos((cAliasSF3)->F3_ENTRADA),5,2)  //verifica o m๊s corrente
	nX:=0
    
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDetalhamento de Saidas - CR=58 ณ                
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF !R58->(dbSeek(cMesRef))
			RecLocK("R55",.F.)	
 			R55->Q58	+=	1						//Quantidade de Registros CR=58
			MsUnlock()
					
			RecLock("R58",.T.)                              
			R58->REF	:=	cMesRef						
		ELSE
			RecLock("R58",.F.) 		
		END IF
              
		R58->REGTRIB := cRegime 					//REGIME TRIBUTARIO	
       	MsUnlock()
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDetalhamento de Entradas - CR=60 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Substr((cAliasSF3)->F3_CFO,1,1)$"12"
	    	cInscr	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
	   	    cTipo  	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
				
			IF !R60->(dbSeek(cMesRef))
				IF R58->(dbSeek(cMesRef))
 					RecLocK("R58",.F.)	
 					R58->Q60	+=	1						//Quantidade de Registros CR=60
					MsUnlock()
				EndIf                                                                      
		
				RecLock("R60",.T.)
				R60->REF	:=	cMesRef  					               
				R60->CFOP	:=	(cAliasSF3)->F3_CFO		
			Else
				RecLock("R60",.F.)	
			EndIf 
							
			If Substr((cAliasSF3)->F3_CFO,1,1)=="1"		
				R60->VINTERNA	+= (cAliasSF3)->F3_VALCONT 			
			END IF
									 
			MsUnlock()		
		EndIf
	                                                                
	
		If !(cAnoBase<'2007') .Or. !(cAnoBase <'2001')
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDetalhes Interestaduais de Saidas CR=65ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cUF	:= aCodUFa((cAliasSF3)->F3_ESTADO)
			If (Substr((cAliasSF3)->F3_CFO,1,1)=="2" .and. cMvUF <> "SP") .or. (Substr((cAliasSF3)->F3_CFO,1,1)=="2" .and. !(cUF$cCodUf) .and. cMvUF == "SP")
		   		cInscr	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
	   	     	cTipo  	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
	          
	            IF !R65->(dbSeek(cMesRef+cUF))
    				IF R60->(dbSeek(cMesRef))
	 					RecLocK("R60",.F.)		 					
	 					R60->Q65	+=	1						//Quantidade de Registros CR=65
						MsUnlock()
					EndIf
        			RecLock("R65",.T.) 
        			R65->REF	:=	cMesRef  					               
					R65->CFOP	:=	(cAliasSF3)->F3_CFO	
        			R65->UF	 :=	cUF    							//Unidade Federacao	               				
				Else
					RecLock("R65",.F.)	
				EndIf		
																	
				R65->VALCONT	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil de Contribuinte
				R65->BASECAL	+=	(cAliasSF3)->F3_BASEICM   	//Base de Calculo de Contribuinte  
				R65->IMPOSTO	+=	(cAliasSF3)->F3_VALICM      //Imposto 
				R65->OUTRAS		+=	(cAliasSF3)->F3_OUTRICM     //Outras operacoes
                R65->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
		   		R65->PETROL	+= IIF(	Upper((cAliasSF3)->F3_ESPECIE)$"NFCEE",(cAliasSF3)->F3_ICMSRET,0)		//Petroleo e Energia quando Substituicao Tributaria  

				IF R60->(dbSeek(cMesRef))
		  			RecLocK("R60",.F.)
			  		R60->VINTER +=	iif((cAnoBase >='2007' .Or. (cAnoBase>='2001' .And. cAnoBase <='2005')),(cAliasSF3)->F3_VALCONT,0)			//Quantidade Entradas Interestaduais
		 			R60->IMPAQUIS += iif(!(cAnoBase <'2001'),(cAliasSF3)->F3_VALICM,0)	//Quantidade de Registros CR=65
		 			MsUnlock()
		        ENDIF
		
				MsUnlock()	
			ENDIF
		ENDIF
				
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDetalhamento de Saidas - CR=70 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Substr((cAliasSF3)->F3_CFO,1,1)$"56" 
	    	cInscr	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
	   	    cTipo  	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
				      				
			IF !R70->(dbSeek(cMesRef))  
				IF R58->(dbSeek(cMesRef))
 					RecLocK("R58",.f.)	
 					R58->Q70	+=	1						//Quantidade de Registros CR=70
					MsUnlock()
				EndIf       
				
				RecLock("R70",.T.)
				R70->REF	:=	cMesRef  					               
				R70->CFOP	:=	(cAliasSF3)->F3_CFO	                
			Else
				RecLock("R70",.F.)	
			EndIf 
           
			If substr((cAliasSF3)->F3_CFO,1,1)=="5"
				IF "ISENT" $Upper(cInscr)  .Or. (cAliasSF3)->F3_ISENICM >0
					R70->SINTRIB  +=  (cAliasSF3)->F3_VALCONT	//Saidas Internas Nใo Tributaveis
				Else
				    R70->VINTERNA +=   IIF(cRegime<>"05",(cAliasSF3)->F3_VALCONT,0)	//Saidas Tributaveis Internas 
	            EndIf
            EndIf
			R70->SEXPORT +=	IIF(substr((cAliasSF3)->F3_CFO,1,1)=="7",(cAliasSF3)->F3_VALCONT,0)	     //Saida Exportacao
		   	R70->TRIBISS += IIF((SubStr ((cAliasSF3)->F3_TIPO, 1, 1)=="S") ,(cAliasSF3)->F3_VALICM,0)    // OPERACOES TRIBUTADAS PELO ISS
		
			MsUnlock()			
			
		EndIf
		 
	 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIndica se Houve Movimento no Mes - CR=58 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF R58->(dbSeek(cMesRef))
				RecLocK("R58",.F.)	
				R58->MOVIMEN := IF(R58->Q60 >0 .Or. R58->Q70 >0,1,0) 	//MOVIMENTO				   
				MsUnlock()		
		ENDIF 
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDetalhamento do Sumario do Registro - CR=55 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 		
		If R55->(dbSeek(cAnoBase)) 	
            If cMesAnt<>cMesRef .And. !substr((cAliasSF3)->F3_CFO,1,1)$"37"  
                
	            	for nX:= 1 to 12
						If nX==val(cMesref)
							If R58->MOVIMEN==0
							 aSumario[1][nX] := 3
							elseIf R58->MOVIMEN>0 
								aSumario[1][nX] := 4 		
							end if				
						end if  
				   		cSumario +=AllTrim(str(aSumario[1][nX]))
					Next nX 
				  	cMesAnt :=cMesRef 			
				
			  	RecLocK("R55",.F.) 
            		R55->SUMARIO:= cSumario
            		cSUMARIO:=""
	            MsUnlock() 
          Endif             
	 ENDIF 	 					 						

		 
		If (!(cAnoBase <'2007')) .And. !(cAnoBase <'2001')  
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDetalhes Interestaduais de Saidas CR=75ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
			cUF	:= aCodUFa((cAliasSF3)->F3_ESTADO)
			If (Substr((cAliasSF3)->F3_CFO,1,1)=="6" .and. cMvUF <> "SP") .or. (Substr((cAliasSF3)->F3_CFO,1,1)=="6" .and. !(cUF$cCodUf) .and. cMvUF == "SP")
		   		
		   		cInscr	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
	   	     	cTipo  	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
	
				IF !R75->(dbSeek(cMesRef+cUF))
					IF R70->(dbSeek(cMesRef))
	 					RecLocK("R70",.F.)	
	 					R70->Q75	+=	1						//Quantidade de Registros CR=75
						MsUnlock()
					EndIf
		  
					RecLock("R75",.T.) 
					R75->REF	:=	cMesRef		
					R75->UF	 :=	cUF								//Unidade da Federacao
				Else
					RecLock("R75",.F.)	
				EndIf		
				   
									
				IF (Subs(ALLTRIM((cAliasSF3)->F3_CFO),1,3)$"618/619/645/653") .Or. (Subs(ALLTRIM((cAliasSF3)->F3_CFO),1,4)$"6107/6108/5307/6307") .or."ISENT" $Upper(cInscr) .or. (empty(cInscr) .and. cTipo != "L" .and. substr((cAliasSF3)->F3_CFO,1,1)=="6") .Or. (cAliasSF3)->F3_ISENICM >0
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณNao Contribuinteณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   								
					R75->VALCONT2	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil de NAO Contribuinte
					R75->BASECAL2	+=	(cAliasSF3)->F3_BASEICM 		//Base de Calculo de NAO Contribuinte
				Else
					R75->VALCONT1	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil de Contribuinte
					R75->BASECAL1	+=	(cAliasSF3)->F3_BASEICM   	//Base de Calculo de Contribuinte
				EndIf
			    
				R75->IMPOSTO	+=	(cAliasSF3)->F3_VALICM      //Imposto Creditado e Debitado
				R75->OUTRAS		+=	(cAliasSF3)->F3_OUTRICM     //Outras operacoes   
		   	   	R75->ICMCOBRST	+= iif(SubStr ((cAliasSF3)->F3_CFO, 1, 1)=="6",(cAliasSF3)->F3_ICMSRET,0)	 	//ICMS cobrado por Substituicao Tributaria	    		
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณValor SaidaS Interestaduaisณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF R70->(dbSeek(cMesRef))				
				   	RecLocK("R70",.F.)  
				IF "ISENT" $Upper(cInscr)  .Or. (cAliasSF3)->F3_ISENICM >0
					IF cAnoBase >= "2007"  
					   	R70->SENTRIB	+= (cAliasSF3)->F3_VALCONT	 	//SOMA DOS VALORES DAS SAIDAS NAO TRIBUTADAS INTER
				    ENDIF 
				Else
			   		//SAIDA tributadas INTERESTADUAL (SOMA DE VALOR CONTABIL1 + VALOR CONTABIL2 DE CR=75)
					R70->VINTER	+= IIF(cAnoBase > "2001" , (cAliasSF3)->F3_VALCONT,0)									  
	            EndIf
				    MsUnlock() 
				EndIf  				
			    
				MsUnlock()	
			END IF
		END IF    
	                                                             
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValor do Imposto para Saidasณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    If (Substr((cAliasSF3)->F3_CFO,1,1)$"56" .And.	R70->VINTERNA >0) .Or. (Substr((cAliasSF3)->F3_CFO,1,1)$"56" .And. R70->VINTER >0)
			IF R70->(dbSeek(cMesRef))				
			   	RecLocK("R70",.F.)
				R70->IMPDEV	+= (cAliasSF3)->F3_VALICM  //ICMS DEVIDO	
				MsUnlock() 
			Endif			
		Endif
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณZona Franca de Manaus /Areas de Livre Comercio CR=76ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Substr((cAliasSF3)->F3_CFO,1,1)=="6" .And. (cAliasSF3)->F3_ESTADO $"AC/AP/AM/RO/RR" .And. R70->SENTRIB > 0 .And. cAnoBase >='2007' 
		
		cCGC		:=	""
		cCodMun		:=	""
		lZFranca	:= .T.
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se Cliente X Fornecedor e pega Insc. Estadual       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (cAliasSF3)->F3_TIPO$"BD"
			If SA2->(dbSeek(xFilial()+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
				cCGC	:=	SA2->A2_CGC
				cCodMun	:=	SA2->A2_CODMUN
			Endif
		Else
			If lTms
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			    //ณ Integracao com TMS                                 ณ
			    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				PosTms ((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)
				//
				If Empty (SA1->A1_SUFRAMA) .Or. SA1->A1_CALCSUF=="N"
					lZFranca	:= .F.
			 	Endif
			 	//
				cCGC	:=	SA1->A1_CGC
				cCodMun	:=	SA1->A1_CODMUN
			Else
				If SA1->(dbSeek(xFilial()+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
	   	    		 If Empty(SA1->A1_SUFRAMA) .Or. SA1->A1_CALCSUF=="N"
						lZFranca	:= .F.
					 Endif
					 cCGC	:=	SA1->A1_CGC
					cCodMun:=SA1->A1_CODMUN
				Endif
			EndIf
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Valida codigo do municipio                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SX5->(!dbSeek(xFilial()+"S1"+cCodMun))
			lZFranca	:= .F.
		EndIf
		If lZFranca
			//aZFManaus()	
			If !R76->(dbSeek(cMesRef+cSubCod))
				RECLOCK("R76",.T.)  
				R76->REF    	:=	cMesRef						
				R76->CFOP		:=	(cAliasSF3)->F3_CFO	 // CODIGO PARA IDENTIFICAR SE E UMA SAIDA INTERESTADUAL
				R76->UF		:=	cUF 	//Unidade de Federacao PARA SABER O ESTADO DE SAIDA 
				R76->NFISCAL	:=	(cAliasSF3)->F3_NFISCAL	//Nota Fiscal
				R76->EMISSAO	:=	Dtos((cAliasSF3)->F3_EMISSAO)	//Data da Emissao
				R76->VALOR	    +=(cAliasSF3)->F3_VALCONT
				R76->CNPJDES	:=	cCGC	//CGC do destinatario
				R76->MUNICIP	:=	cCodMun	//Codigo do Municipio  
				MSUnlock()
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณIndica no Registro Detalhes Interestaduais que existeณ
				//ณoperacoes beneficiadas por Isencao do ICMS.          ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			   IF (cAnoBase >= "2007" .Or. (cAliasSF3)->F3_ESTADO $"AC/AP/AM/RO/RR") .Or. R70->SENTRIB >0
					if R75->(dbSeek(cMesRef+cUF))	
						RecLock("R75",.F.)
						R75->Q76	+=	1
						MsUnlock()
					end if
				EndIf	
			EndIf
		EndIf	
	EndIf //Zona Franca	

 
	IF !(cRegime=="05") .And. !(cAnoBase <="2001") .And.!(cAnoBase=="2002" .And. R58->REF <=11)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDetalhes Deducoes CR=78ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                   
		If 	cMesCorr <> cMesRef			
			aApuICM := FisApur("IC",val(cAnoBase),val(cMesRef),2,0,"*",.F.,{},1,.F.,"")
			aApuST  := FisApur("ST",val(cAnoBase),val(cMesRef),2,0,"*",.F.,{},1,.F.,"")
			
			For nX := 1 to len(aApuICM)
				If alltrim(aApuICM[nX][1])$"012" .and. aApuICM[nX][3] > 0
					cSubCod := RetChar(alltrim(aApuICM[nX][4]),.T.,.F.,.F.,.T.,.F.,5,.F.)
					If !(cSubCod$"01200")
						dbSelectArea("R78")				
						RecLock("R78",.T.)          		 
						R78->REF := cMesRef          					    			    
				    					    	
				    	If R58->(dbSeek(cMesRef))	
				    		RecLock("R58",.F.)
							R58->Q78	+=	1 
						    MsUnlock()	
					    EndIf
					    
					    R78->SUBITEM := cSubCod
					    If Substr(cSubCod,1,5) == "99999"
					    	R78->FLEGAL  := If(!Empty(alltrim(aApuICM[nX][2])),alltrim(aApuICM[nX][2]),"OUTRAS HIPOTESES")
							R78->OCORREN := If(!Empty(alltrim(aApuICM[nX][2])),alltrim(aApuICM[nX][2]),"OUTRAS HIPOTESES")
						EndIf
							    
					    R78->VALOR   := aApuICM[nX][3]
					    
						MsUnlock()
					EndIf	    						
				EndIf	
			Next nX                               
			
			For nY := 1 to len(aApuST)
				If alltrim(aApuST[nY][1])$"014" .and. aApuST[nY][3] > 0
					cSubCod := RetChar(alltrim(aApuST[nY][4]),.T.,.F.,.F.,.T.,.F.,5,.F.)	    
					If !(cSubCod$"01400")
						dbSelectArea("R78")
						RecLock("R78",.T.)
						R78->REF := cMesRef          					    
												
						If R58->(dbSeek(cMesRef))	
							RecLock("R58",.F.)
							R58->Q78	+=	1 
						    MsUnlock()	
				        EndIf				
					
                        R78->SUBITEM := cSubCod
						If Substr(cSubCod,1,5) == "99999"
					    	R78->FLEGAL  := If(!Empty(alltrim(aApuST[nY][2])),alltrim(aApuST[nY][2]),"OUTRAS HIPOTESES")
							R78->OCORREN := If(!Empty(alltrim(aApuST[nY][2])),alltrim(aApuST[nY][2]),"OUTRAS HIPOTESES")
						Else
							R78->FLEGAL  := Space(100)
							R78->OCORREN := Space(300)
						EndIf   
						
						R78->VALOR   += aApuST[nY][3]
								
					    MsUnlock()
					EndIf	        
				EndIf	
			Next nY
			cMesCorr:= cMesRef
		End if
	END IF
	
	If cAnoBase > "2001"	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDIPAM  CR=80ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤู                                               
		cCod_Mun :=	A936RetMun (cAliasSf3, lTms)
	   	cCodMunDp := StrZero(val(Alltrim(cCod_Mun)),5,0)		   
		Do Case
			Case (cCnae$"5131400/5146201/5241804/5524701") .Or. ( (Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"511/512/514/515") .Or. (Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5101/5102/5103/5104") ) .And. (R70->VINTERNA+R70->VINTER+R70->SINTRIB+R70->SENTRIB)>0
				If ( (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM > 0 )
					dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("22"+cCodMunDp)
						RecLock("R80",.F.)
					Else
						If R55->(dbSeek(cAnoBase))
							RecLock("R55",.F.)
							R55->Q80	+=	1
							MsUnLock()
    	                    Endif
						RecLock("R80",.T.)
					EndIf
					CODDIP := "22"
					MUNICIP:= cCodMunDp
					VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM
					MsUnLock()
				EndIf
			Case (Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"561/562/563/661/662/663/761" .Or. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5351/5352/5353/5354/5355/5356/5357/6351/6352/6353/6354/6355/6356/6357/7358") .And. (R70->VINTERNA+R70->VINTER+R70->SINTRIB+R70->SENTRIB)>0
				If ( (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM > 0 )
					dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("23"+cCodMunDp)
						RecLock("R80",.F.)
					Else
						If R55->(dbSeek(cAnoBase))
							RecLock("R55",.F.)
							R55->Q80	+=	1
							MsUnLock()
                        	Endif
						RecLock("R80",.T.)
					EndIf
					CODDIP := "23"
					MUNICIP:= cCodMunDp
					VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM 
					MsUnLock()
				EndIf
			Case (Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"551/552/553" .Or. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5301/5302/5303/5304/5305/5306/5307/6301/6302/6303/6304/6305/6306/6307/7301" ) .And. (R70->VINTERNA+R70->VINTER+R70->SINTRIB+R70->SENTRIB)>0
					dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("24"+cCodMunDp)
						RecLock("R80",.F.)
					Else
						If R55->(dbSeek(cAnoBase))
							RecLock("R55",.F.)
							R55->Q80	+=	1
							MsUnLock()
                        	Endif
						
						RecLock("R80",.T.)
					EndIf
					CODDIP := "24"
					MUNICIP:= cCodMunDp
					VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM 
					MsUnLock()
			Case (Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"541/542/543/544/545/546/641/642/643/644/645/646" .Or. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5251/5252/5253/5254/5255/5256/5257/5258/6251/6252/6253/6254/6255/6256/6257/6258/7251") .And. (R70->VINTERNA+R70->VINTER+R70->SINTRIB+R70->SENTRIB)>0
					dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("25"+cCodMunDp)
						RecLock("R80",.F.)
					Else
						If R55->(dbSeek(cAnoBase))
							RecLock("R55",.F.)
							R55->Q80	+=	1
							MsUnLock()
                        Endif
					
						RecLock("R80",.T.)
					EndIf
					CODDIP := "25"
					MUNICIP:= cCodMunDp
					VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM 
					MsUnLock()
			//Compra Escriturada de Mercadorias de Produtores Agropecuarios
			Case SubStr(AllTrim((cAliasSF3)->F3_CFO),1,1)=="1" .And. !Empty(SA2->A2_TIPORUR) .And. Alltrim((cAliasSF3)->F3_CFO)$cDip11 .And. R60->VINTERNA>0
					dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("11"+cCodMunDp)
						RecLock("R80",.F.)
					Else
						RecLock("R55",.F.)
						R55->Q80	+=	1
						MsUnLock()
						RecLock("R80",.T.)
					EndIf
					CODDIP := "11"
					MUNICIP:= cCodMunDp
					VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM 
					MsUnLock()
			//Recebimento por Cooperativa de Mercadoria remetida por Produtores Agropecuarios
			Case SubStr(AllTrim((cAliasSF3)->F3_CFO),1,1)=="1" .And. !Empty(SA2->A2_TIPORUR) .And. Alltrim((cAliasSF3)->F3_CFO)$cDip13 .And. R60->VINTERNA>0
					dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("13"+cCodMunDp)
						RecLock("R80",.F.)
					Else
						If R55->(dbSeek(cAnoBase))
							RecLock("R55",.F.)
							R55->Q80	+=	1
							MsUnLock()
                        Endif
						RecLock("R80",.T.)
					EndIf
					CODDIP := "13"
					MUNICIP:= cCodMunDp
					VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM 
					MsUnLock()   
			Case (Alltrim(aCfp[1][06]))<>"000000000000000.00"
			    	dbSelectArea("R80")
					dbSetOrder(1)
					If dbSeek("33"+"00000")
						RecLock("R80",.F.)
					Else 
						If R55->(dbSeek(cAnoBase))
							RecLock("R55",.F.)
							R55->Q80	+=	1
							MsUnLock()
                        	Endif
						
						RecLock("R80",.T.)
					EndIf
					CODDIP := "33"
					MUNICIP:= "00000"
					VALOR  := val(aCfp[1][06])
					MsUnLock()
			Case (cAliasSF3)->F3_ICMSRET >0
				dbSelectArea("R80")
				dbSetOrder(1)
				If dbSeek("34"+"00000")
					RecLock("R80",.F.)
				Else
					If R55->(dbSeek(cAnoBase))
						RecLock("R55",.F.)
						R55->Q80	+=	1
						MsUnLock()
                        Endif
					RecLock("R80",.T.)
				EndIf
				CODDIP := "34"
				MUNICIP:= "00000"
				VALOR  += (cAliasSF3)->F3_ICMSRET
				MsUnLock()
			EndCase 		
		
	Endif
	(cAliasSF3)->( dbSkip() )          
End

If lQuery
    dbSelectArea(cAliasSF3)
	dbCloseArea()
 	Ferase(cIndSF3+OrdBagExt())
	dbSelectArea("SF3")
	RetIndex("SF3")
Endif	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFunctionณGerArquivo    บAutor  ณFlแvio Fernandes Neve  บ Data ณ  04.06.08 บฑฑ
ฑฑฬออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.   ณGera Arquivo texto                                               บฑฑ
ฑฑฬออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Mata936                                                        บฑฑ
ฑฑศออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GerArquivo()
Local cRegistro := ""
Local cNomeArq	:= Alltrim(aCfp[1][09])
Local cDisco	:= Alltrim(aCfp[1][10])
Local cPath	:=	""

If !Empty(cDisco)
	cPath	:=	Alltrim(cDisco)
Else
	cPath:=""
Endif   

cNomeArq := cPath+cNomeArq

If File(cNomeArq)
	Ferase(cNomeArq)
Endif

nHandle	 :=	MsFCreate(cNomeArq)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRegistro Mestre CR=01
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู    
R01->(dbGoTop())
cRegistro := "01"
cRegistro += R01->TPDOCTO 
cRegistro += R01->DTGERACAO
cRegistro += R01->HRGERACAO
cRegistro += R01->VSFRONTEND
cRegistro += "0300"
//cRegistro += R01->VSPREF
cRegistro += strzero(R01->Q55,4) 
a_Grava(cRegistro)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCabecalho do documento Fiscal - CR=05 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
R55->(dbGoTop())
cRegistro := "55"
cRegistro += R55->IE
cRegistro += R55->CNPJ		
cRegistro += R55->CNAE		
cRegistro += R55->ANOBASE 
cRegistro += R55->SUMARIO	
cRegistro += R55->DACORDO	
cRegistro += R55->TIPO	 	
cRegistro += R55->TRANSMI	
cRegistro += R55->ORIGSOF	
cRegistro += R55->ORIGARQ	
cRegistro += R55->CHAVINT
cRegistro += Strzero(R55->Q58,4)
cRegistro += Strzero(R55->Q80,4) 	
a_Grava(cRegistro)
	
dbSelectArea("R58")
R58->(dbGoTop())
While R58->(!eof()) 
	
	IF R58->(dbSeek(R58->REF))	
		IF !Arq->(dbSeek(R58->REF))  
				RecLocK("Arq",.T.)
 			   	ARQ->REF	:=R58->REF						
                ARQ->CAMPO	:="58"+R58->REF+R58->REGTRIB+ALLTRIM(STR(R58->MOVIMEN))+STRZERO(R58->Q60,4)+STRZERO(R58->Q70,4)+STRZERO(R58->Q78,4)
				cRegistro   := SUBSTR(ARQ->CAMPO,1,19)
				a_Grava(cRegistro)
	    	    IF R60->(dbseek(R58->REF)) 
		           While R60->(!eof()) .and.R58->REF == R60->REF
					     RecLocK("Arq",.T.)	
   				         ARQ->REF	:=R58->REF
    	                 ARQ->CAMPO	:="60"+NUM2CHR(R60->VINTERNA,15,2)+NUM2CHR(R60->VINTER,15,2)+NUM2CHR(R60->IMPAQUIS,15,2)+STRZERO(R60->Q65,4)
					     cRegistro  := SUBSTR(ARQ->CAMPO,1,51)
			             a_Grava(cRegistro)
					     R60->(dbSkip())		            
				   EndDo 
				Endif
				IF R65->(dbseek(R58->REF)) 
				   	While R65->(!eof()) .and.R58->REF == R65->REF
						RecLocK("Arq",.T.)	
						ARQ->REF	:=R58->REF
   	                    ARQ->CAMPO	:="65"+R65->UF+NUM2CHR(R65->VALCONT,15,2)+NUM2CHR(R65->BASECAL,15,2)+NUM2CHR(R65->IMPOSTO,15,2)+NUM2CHR(R65->OUTRAS,15,2)+NUM2CHR(R65->PETROL,15,2)+NUM2CHR(R65->OUTPROD,15,2)
						cRegistro   := SUBSTR(ARQ->CAMPO,1,94)
						a_Grava(cRegistro)
						R65->(dbSkip())		            
					EndDo
				EndIf	
	
	            IF R70->(dbseek(R58->REF)) 
		        While R70->(!eof()) .and. R58->REF == R70->REF
					RecLocK("Arq",.T.)	                                                                                                                                                                                                                       
					ARQ->REF	:=R58->REF
 		 			Arq->CAMPO	:= "70"+NUM2CHR(R70->VINTERNA,15,2)+NUM2CHR(R70->VINTER,15,2)+NUM2CHR(R70->IMPDEV,15,2)+NUM2CHR(R70->SINTRIB,15,2)+NUM2CHR(R70->SENTRIB,15,2)+NUM2CHR(R70->SEXPORT,15,2)+NUM2CHR(R70->TRIBISS,15,2)+STRZERO(R70->Q75,4)
					cRegistro   := SUBSTR(ARQ->CAMPO,1,111)
					a_Grava(cRegistro)
					R70->(dbSkip())		            
				EndDo   	
  
			  	IF R75->(dbseek(R58->REF)) 
		           	While R75->(!eof()) .and.R58->REF == R75->REF
					   	RecLocK("Arq",.T.)	
					   	ARQ->REF	:=R58->REF
						Arq->CAMPO	:= "75"+R75->UF+NUM2CHR(R75->VALCONT1,15,2)+NUM2CHR(R75->BASECAL1,15,2)+NUM2CHR(R75->VALCONT2,15,2)+NUM2CHR(R75->BASECAL2,15,2)+NUM2CHR(R75->IMPOSTO,15,2)+NUM2CHR(R75->OUTRAS,15,2)+NUM2CHR(R75->ICMCOBRST,15,2)+STRZERO(R75->Q76,4)
						cRegistro   := SUBSTR(ARQ->CAMPO,1,113)
						a_Grava(cRegistro)						
						IF R76->(dbseek(R58->REF)) 
			    		   	While R76->(!eof()) .and. R58->REF+R75->UF == R76->REF+R76->UF
								RecLocK("Arq",.T.)	
								ARQ->REF	:=R58->REF
								Arq->CAMPO	:= "76"+(RetNf(R76->NFISCAL,6,"C")+Space((6-Len(RetNf(R76->NFISCAL,6,"C")))))+R76->EMISSAO+NUM2CHR(R76->VALOR,15,2)+R76->CNPJDES+R76->MUNICIP
								cRegistro   := SUBSTR(ARQ->CAMPO,1,50)
								a_Grava(cRegistro)
								R76->(dbSkip())		            
							EndDo
						EndIf	                   
						R75->(dbSkip())		            
					EndDo
				EndIf	
			ENDIF
    		//IF R78->(dbseek(R58->REF)) 
	          // 	While R78->(!eof()) .and.R58->REF == R78->REF
				//	RecLocK("Arq",.T.)	
				//	ARQ->REF	:=R58->REF
				//	Arq->CAMPO	:= "78"+R78->SUBITEM+NUM2CHR(R78->VALOR,15,2)+R78->FLEGAL+R78->OCORREN
				//	cRegistro   := SUBSTR(ARQ->CAMPO,1,422)
				//	a_Grava(cRegistro)
				//	R78->(dbSkip())		            
			//	EndDo
			//EndIf
			
		ENDIF   
	ENDIF
   	MsUnlock() 
	R58->(dbSkip())    
EndDo

R80->(dbGoTop())
While R80->(!eof()) 
   cRegistro:= "80"
   cRegistro+= R80->CODDIP
   cRegistro+= R80->MUNICIP
   cRegistro+= SUBSTR(Num2Chr(R80->VALOR,15,2),1,15)
   a_Grava(cRegistro) 
   R80->(dbSkip()) 
EndDo


return

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao  ณCRIATMPa    บAutor  ณFlแvio Fernandes Neves บ Data ณ  18/04/06 บฑฑ
ฑฑฬออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.   ณCria todos os arquivos temporarios necessarios a geracao da    บฑฑ
ฑฑบ        ณDS                                                             บฑฑ
ฑฑฬออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Mata936                                                      บฑฑ
ฑฑศออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CRIATMPa(cals)                        

LOCAL aCampos	:=	{}
LOCAL cAlias	:=	Alias()
LOCAL aTam		:= TAMSX3("F3_CFO")    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ       	
//ณArquivo do Registro MESTREa CR=01       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aCampos,{"TPDOCTO"   ,"C", 002, 0})
AADD(aCampos,{"DTGERACAO" ,"C", 008, 0})
AADD(aCampos,{"HRGERACAO" ,"C", 006, 0})
AADD(aCampos,{"VSFRONTEND","C", 004, 0})
AADD(aCampos,{"VSPREF"    ,"C", 004, 0})
AADD(aCampos,{"Q55"       ,"N", 004, 0})
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R01")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ       	
//ณArquivo do Cabecalho do Doc.Fiscal CR=55ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{}
AADD(aCampos,{"IE"		,"C"	,012,0})
AADD(aCampos,{"CNPJ"	,"C"	,014,0}) 
AADD(aCampos,{"CNAE"	,"C"	,007,0})
AADD(aCampos,{"ANOBASE"	,"C"	,004,0})
AADD(aCampos,{"SUMARIO"	,"C"	,012,0})
AADD(aCampos,{"DACORDO"	,"C"	,001,0})
AADD(aCampos,{"REFINIC"	,"C"	,006,0})
AADD(aCampos,{"TIPO"	,"C"	,002,0})
AADD(aCampos,{"TRANSMI"	,"C"	,001,0})
AADD(aCampos,{"ORIGSOF"	,"C"	,014,0})
AADD(aCampos,{"ORIGARQ"	,"C"	,001,0})
AADD(aCampos,{"CHAVINT"	,"C"	,032,0})
AADD(aCampos,{"Q58"		,"N"	,004,0})
AADD(aCampos,{"Q80"		,"N"	,004,0})          	

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R55")
IndRegua("R55",cAls,"ANOBASE")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo Detalhes Mensal CR=58ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{}
AADD(aCampos,{"REF"     ,"C"	,002,0})
AADD(aCampos,{"REGTRIB" ,"C"	,002,0})
AADD(aCampos,{"MOVIMEN"	,"N"	,001,0})
AADD(aCampos,{"Q60"		,"N"	,004,0})
AADD(aCampos,{"Q70"		,"N"	,004,0})
AADD(aCampos,{"Q78"		,"N"	,004,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R58")
IndRegua("R58",cAls,"REF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo Detalhes de Entadas  CR=60ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{}
AADD(aCampos,{"CFOP"    ,"C"	,aTam[1],0}) 
AADD(aCampos,{"REF"     ,"C"	,002,0})
AADD(aCampos,{"VINTERNA","N"	,015,2}) //ENTRADA INTERNA
AADD(aCampos,{"VINTER"  ,"N"	,015,2}) //ENTRADA INTERESTADUAIS
AADD(aCampos,{"IMPAQUIS","N"	,015,2}) //VALOR DO IMPOSTO DEV PELAS AQUISICOES INTERESTADUAIS
AADD(aCampos,{"Q65"		,"N"	,004,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R60")
IndRegua("R60",cAls,"REF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo Detalhes Interestaduais de EntradaS CR=65ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{}
AADD(aCampos,{"CFOP"    ,"C"	,aTam[1],0})
AADD(aCampos,{"REF"     ,"C"	,002,0})
AADD(aCampos,{"UF"   	,"C"	,002,0})
AADD(aCampos,{"VALCONT" ,"N"	,015,2})
AADD(aCampos,{"BASECAL"	,"N"	,015,2})
AADD(aCampos,{"IMPOSTO"	,"N"	,015,2}) //IMPOSTO DESTACADO NA NOTA
AADD(aCampos,{"OUTRAS"	,"N"	,015,2})
AADD(aCampos,{"PETROL"	,"N"	,015,2}) //PETROLIO E ENERGIA QDO COBRADO ICMS
AADD(aCampos,{"OUTPROD"	,"N"	,015,2})

	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R65")
IndRegua("R65",cAls,"REF+UF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo Detalhes de Saidas  CR=70ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

aCampos	:=	{}
AADD(aCampos,{"CFOP"    ,"C"	,aTam[1],0})
AADD(aCampos,{"REF"     ,"C"	,002,0})
AADD(aCampos,{"VINTERNA","N"	,015,2}) //Saidas Tributadas Internas 
AADD(aCampos,{"VINTER"  ,"N"	,015,2}) //Saidas Tributadas Interestaduais
AADD(aCampos,{"IMPDEV"  ,"N"	,015,2}) //Imposto Devido
AADD(aCampos,{"SINTRIB" ,"N"	,015,2}) //Saidas Nao Tributadas Internas
AADD(aCampos,{"SENTRIB" ,"N"	,015,2}) //Saidas Nใo Tributadas Interestaduais
AADD(aCampos,{"SEXPORT" ,"N"	,015,2}) //Saidas Exportacoes
AADD(aCampos,{"TRIBISS"	,"N"	,015,2}) //Operacoes Tributadas pelo ISS
AADD(aCampos,{"Q75"     ,"N" 	,004,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R70")
IndRegua("R70",cAls,"REF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo Detalhes Interestaduais de Saidas CR=75ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{}
AADD(aCampos,{"CFOP"       ,"C"	,aTam[1],0})
AADD(aCampos,{"REF"         ,"C"	,002,0})
AADD(aCampos,{"UF"   		,"C"	,002,0})
AADD(aCampos,{"VALCONT1" 	,"N"	,015,2})
AADD(aCampos,{"BASECAL1"	,"N"	,015,2})
AADD(aCampos,{"VALCONT2" 	,"N"	,015,2})
AADD(aCampos,{"BASECAL2"	,"N"	,015,2})
AADD(aCampos,{"IMPOSTO"		,"N"	,015,2}) //IMPOSTO DESTACADO NA NOTA
AADD(aCampos,{"OUTRAS"		,"N"	,015,2})
AADD(aCampos,{"ICMCOBRST"	,"N"	,015,2}) //ICMS COBRADO POR SUBSTITUICAO TRIBUTARIA
AADD(aCampos,{"Q76"			,"N"	,004,0})
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R75")  
IndRegua("R75",cAls,"REF+UF")


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo ZFM/ALC CR=76ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{} 
AADD(aCampos,{"CFOP"    ,"C"	,aTam[1],0})
AADD(aCampos,{"REF"     ,"C"	,002,0})
AADD(aCampos,{"UF"   	,"C"	,002,0})
AADD(aCampos,{"NFISCAL" ,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"EMISSAO" ,"C"	,008,0})
AADD(aCampos,{"VALOR"	,"N"	,015,2})
AADD(aCampos,{"CNPJDES"	,"C"	,014,0}) //CNPJ DO DESTINATARIO
AADD(aCampos,{"MUNICIP"	,"C"	,005,0}) // MUN DESTINO
	
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R76")
IndRegua("R76",cAls,"REF+UF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo de Detalhes Deducoes CR=78ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos	:=	{}
AADD(aCampos,{"REF"     ,"C"	,002,0})
AADD(aCampos,{"SUBITEM" ,"C"	,005,0})
AADD(aCampos,{"VALOR"	,"N"	,015,2})
AADD(aCampos,{"FLEGAL"	,"C"	,100,0})
AADD(aCampos,{"OCORREN"	,"C"	,300,0})
	                                    
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R78")
IndRegua("R78",cAls,"REF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArquivo DIPAM   CR=80ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aCampos	:=	{}
AADD(aCampos,{"CODDIP"	,"C"	,002,0})
AADD(aCampos,{"MUNICIP"	,"C"	,005,0})
AADD(aCampos,{"VALOR"	,"N"	,015,2})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"R80")
IndRegua("R80",cAls,"CODDIP+MUNICIP")
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฟ       	
//ณArquivo TXTณ
//ภฤฤฤฤฤฤฤฤฤฤฤู 
aCampos	:=	{}
AADD(aCampos,{"REF" ,"C"	,002,0})
AADD(aCampos,{"CAMPO","C"	,422,0})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"Arq")
IndRegua("Arq",cAls,"REF") 

dbSelectArea(cAlias)
Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMontPainelณ Autor ณFlแvio Fernandes Neves ณ Data ณ18.04.2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPreparacao do wizard para auxilio das informacoes necessa-  ณฑฑ
ฑฑณ          ณ rias na composicao do meio-magnetico.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณaWizard -> Array contendo as informacoes do wizard.         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MontPainel()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao das variaveisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aTxtPre 		:= {}
Local aPaineis 		:= {}
Local cTitObj1		:= ""
Local cTitObj2		:= ""       
Local nPos			:= 0


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta wizard com as perguntas necessariasณ   
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aTxtPre,"Processamento do Simples Nacional - DSN - SP")
AADD(aTxtPre,"")
AADD(aTxtPre,"Preencha Corretamente as Informa็๕es Solicitadas.")
AADD(aTxtPre,"Informa็๕es Necessarias para o Preenchimento Automแtico do                Simples Nacional.")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPainel com as informacoes necessarias   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู       
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],"Processamento do Simples Nacional")
aAdd(aPaineis[nPos],"Dados de Identifica็ใo dos Registros Cabe็alho e Detalhamento Mensal.")
aAdd(aPaineis[nPos],{})
 
cTitObj1 :=	"Ano de Referencia ?" 		//Cfp[1][01]
cTitObj2 :=	"Regime Tributario ?"   	//Cfp[1][02]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"XXXX", 1,,,,4}) 
aAdd(aPaineis[nPos][3],{3,,,,,{"SIMPLES NACIONAL"},,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Tipo de Declara็ใo ?" 				//Cfp[1][03]
cTitObj2 :=	"De Acordo com a Decl Enquadr Prev na Legisl?"   	//Cfp[1][04]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Normal","Substitutiva","Coligida"},,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Sim", "Nใo"},,}) 
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Documento ja foi Transmitido ?"		//Cfp[1][05]  
cTitObj2 :=	"Vl Said Merc ou Prest Serv n Escr e Out Serv" 	//Cfp[1][06]  
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})   
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Sim", "Nใo"},,})
aAdd(aPaineis[nPos][3],{2,,"@E 999,999,999.99",2,2,,,15})  
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
 
cTitObj1 :=	"Versใo do Sistema da DS?"		//Cfp[1][07]  
cTitObj2 :=	"Versใo do Layout da DS?" 	//Cfp[1][08]  
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})   
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,"9999",1,,,,4})
aAdd(aPaineis[nPos][3],{2,,"9999",1,,,,4})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

cTitObj1 :=	"Nome Arquivo"		//Cfp[1][09]  
cTitObj2 :=	"Diret๓rio" 		//Cfp[1][10]  
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})   
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2, ,Repl("X",30), 1,,,,30}) 
aAdd(aPaineis[nPos][3],{2, ,Repl("X",50), 1,,,,50}) 

Return(xMagWizard(aTxtPre,aPaineis,"Mata936"))
                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao  	 ณaCodUFa   บAutor  ณFlแvio Fernandes Neves บ Data ณ  04/06/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณConverte as unidades de federacao para um codigo aceito no   บฑฑ
ฑฑบ          ณprograma NOVA GIA da Secretaria da fazenda                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ mata936                                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function aCodUFa(cUF)
cCOD := "01"
             
Do Case
	Case cUF == "AC"
		cCOD	:= "01"
	Case cUF == "AL"
		cCOD	:= "02"
	Case cUF == "AP"
		cCOD	:= "03"
	Case cUF == "AM"
		cCOD	:= "04"
	Case cUF == "BA"
		cCOD	:= "05"
	Case cUF == "CE"
		cCOD	:= "06"
	Case cUF == "DF"
		cCOD	:= "07"
	Case cUF == "ES"
		cCOD	:= "08"
	Case cUF == "GO"
		cCOD	:= "10"
	Case cUF == "MA"
		cCOD	:= "12"
	Case cUF == "MT"
		cCOD	:= "13"
	Case cUF == "MS"
		cCOD	:= "28"
	Case cUF == "MG"
		cCOD	:= "14"
	Case cUF == "PA"                                                        
		cCOD	:= "15"
	Case cUF == "PB"
		cCOD	:= "16"
	Case cUF == "PR"
		cCOD	:= "17"
	Case cUF == "PE"
		cCOD	:= "18"
	Case cUF == "PI"
		cCOD	:= "19"
	Case cUF == "RJ"
		cCOD	:= "22"
	Case cUF == "RN"
		cCOD	:= "20"
	Case cUF == "RS"
		cCOD	:= "21"
	Case cUF == "RO"
		cCOD	:= "23"
	Case cUF == "RR"
		cCOD	:= "24"
	Case cUF == "SC"
		cCOD	:= "25"
	Case cUF == "SP"
		cCOD	:= "26"
	Case cUF == "SE"
		cCOD	:= "27"
	Case cUF == "TO"
		cCOD	:= "29"
EndCase

Return(cCOD )  

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณA936RetMun  บAutor  ณGustavo G. Rueda    บ Data ณ  28/09/2004 บฑฑ
ฑฑฬออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณVerifica se existe integracao com o TMS, e caso exista retornaบฑฑ
ฑฑบ        ณ o codigo do municipio da tabela DUE ou DUL. Caso contrario   บฑฑ
ฑฑบ        ณ retorno do cadastro de cliente posicionado anteriormente.    บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParamet.ณExpC -> Indica o alias da tabela SF3 a ser utilizada.         บฑฑ
ฑฑบ        ณExpL -> Integracao com o TMS.                                 บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ MATA936                                                      บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A936RetMun (cAliasSf3, lTms)
	Local	cCod_Mun:=	""
	Local	aArea	:=	GetArea ()                         
	//
	If lTms
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	    //ณ Integracao com TMS                                 ณ
	    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DTC->(DbSetOrder (3))
		If DTC->(MsSeek (xFilial ("DTC")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE)) 
			If !Empty(DTC->DTC_NUMSOL)
				//
			   	//-- Posiciona na Ordem de Coleta
			   	DT5->(DbSetOrder (1)) 
			   	If DT5->(MsSeek (xFilial ("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
					//
				   	If Empty (DT5->DT5_SEQEND)
						DUE->(dbSetOrder(1))
						DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
						cCod_Mun	:=	DUE->DUE_CODMUN		//(Cod. Municipio para imprimir no DIPAM)
				  	Else                                                
						DUL->(dbSetOrder(3))
						DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
						cCod_Mun	:=	DUL->DUL_CODMUN		//(Cod. Municipio para imprimir no DIPAM)
				  	EndIf
				EndIf
			EndIf
		EndIf 
		
		If Empty(cCod_Mun)
			DT6->(dbSetOrder(1))
			If (DT6->(MsSeek (xFilial ("DT6")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE)))
				SA1->(DbSetOrder (1))
				If SA1->(MsSeek (xFilial ("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM))) .And. SA1->A1_EST==SuperGetMV("MV_ESTADO")
					cCod_Mun := SA1->A1_COD_MUN
				Else
					cCod_Mun := StrZero(val(Alltrim(SuperGetMv("MV_CODDP"))),5,0)
				EndIf
			Else
				cCod_Mun := StrZero(val(Alltrim(SuperGetMv("MV_CODDP"))),5,0)
			EndIf
		EndIf
	Else
		If (SuperGetMv("MV_CODMUN")<>"X") .And. !(SA1->(Eof ()))
			If (SA1->(FieldPos(AllTrim (SuperGetMv("MV_CODMUN"))))>0)
				cCod_Mun	:=	SA1->(FieldGet (FieldPos (SuperGetMv ("MV_CODMUN"))))
			Else
				cCod_Mun	:=	""
			EndIf		
		Else
			cCod_Mun	:=	""
		EndIf
		//
		If Empty(cCod_Mun) .And. !(SA1->(Eof()))
			cCod_Mun	:=	SA1->A1_COD_MUN
		EndIf
	EndIf
	RestArea (aArea)
Return (cCod_Mun)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuncao    ณa_Grava   บAutor  ณFlแvio Fernandes Neves บ Data ณ 26/06/00 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณGrava Registro no arquivo texto e acrescenta marca de final บฑฑ
ฑฑบ          ณde registro                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿                  
*/
Function a_Grava(cConteudo)

cConteudo += Chr(13)+Chr(10)                                 	

If !lEnd
	FWrite(nHandle,cConteudo,Len(cConteudo))
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFunction  ณMESTREa   บAutor  ณFlแvio Fernandes neves บ Data ณ 04.06.08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณArmazena informacoes no arquivo texto para armazenar infor- บฑฑ
ฑฑบ          ณmacoes do registro MESTREa. CR=01                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTamanho   ณ 32 Bytes                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MESTREa()

RecLock("R01",.T.)
R01->TPDOCTO 	:=	"02"						//02.Tipo do documento
R01->DTGERACAO 	:=	dtos(dDataBase)		     	//03.Data de geracao do Arq.Pre-formatado
R01->HRGERACAO	:=	substr(Time(),1,2)+substr(Time(),4,2)+substr(Time(),7,2) //04. Hora da Geracao
R01->VSFRONTEND	:=	aCfp[1][07]					//05.Versao do sistema 
R01->VSPREF 	:=	aCfp[1][08]					//06.Versao do Layout do pre-formatado
R01->Q55 		:=	1							//07.Quantidade de registro CR=05
MSUnlock()

Return                                                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFunction  ณ   Cab55a     บ Autor ณFlแvio Fernandes Neves บ Data ณ 04/06/2008 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณCabecalho do documento fiscal.							        บฑฑ
ฑฑบ          ณContem informacoes sobre o contribuinte e informacoes gerais      บฑฑ
ฑฑบ          ณsobre o documento fiscal. CR=55						            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Mata936                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTamanho   ณ 127 Bytes                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Cab55a()                     
 
cCNAE:=	if(len(alltrim(SM0->M0_CNAE))==7,SM0->M0_CNAE,alltrim(SM0->M0_CNAE)+replicate("00",7-len(alltrim(SM0->M0_CNAE))))
cAnoBase:=Alltrim(aCfp[1][01])

RecLock("R55",.T.) 
R55->IE		    := Substr(SM0->M0_INSC,1,12)					//Inscricao Estadual                
R55->CNPJ		:= Substr(SM0->M0_CGC,1,14)					//CNPJ
R55->CNAE		:= "0000000"                                   	//Cnae
R55->ANOBASE	:= cAnoBase										//ANO BASE 
R55->DACORDO	:= "1" 												//If(Alltrim(aCfp[1][04])=="Sim","1","0") 
R55->TIPO		:= If(Alltrim(aCfp[1][03])=="Normal","01",If(Alltrim(aCfp[1][03])=="Substitutiva","02","03"))
R55->TRANSMI	:= If(Alltrim(aCfp[1][05])=="Sim","1","0")	
R55->ORIGSOF	:= "53113791000122" 							//CNPJ do Fabricande do sofwtare( Microsiga )
R55->ORIGARQ	:= "0"											//0-Gerado pelo sistama de informacao contabil
R55->CHAVINT	:= Replicate("0",32)
MSUnlock()

Return
