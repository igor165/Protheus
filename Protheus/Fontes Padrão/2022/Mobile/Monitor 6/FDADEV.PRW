/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IMPDEV1   ³ Autor ³ Marcelo Vieira        ³ Data ³03.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de teste da rotina automatica do programa MATA103     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar testes na rotina de    ³±±
±±³          ³documento de entrada                                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpDev()

Local aArquivos:={}
Local aMata103Cab := {}
Local aMata103Item:= {}
Local cPathPalm   := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cFileDevC   :="HF1" + cEmpAnt + "0" // Cabecalho da devolucao
Local cFileDevI   :="HD1" + cEmpAnt + "0" // Itens da devolucao 
Local cCtrlLote   := GetNewPar( "MV_RASTRO","N")

PRIVATE lMsErroAuto := .F.,  aCabec   := {},  aItens   := {}

aAdd(aArquivos, {cFileDevC, "HF1", "F1_DOC"})
aAdd(aArquivos, {cFileDevI, "HD1", "D1_DOC+D1_ITEM"})

//array do cabecalho
aAdd(aMATA103Cab,{"F1_TIPO"   ,"C", 1,0 })
aAdd(aMATA103Cab,{"F1_FORMUL" ,"C", 1,0 })
aAdd(aMATA103Cab,{"F1_DOC"    ,"C", 1,0 })
aAdd(aMATA103Cab,{"F1_SERIE"  ,"C", 1,0 })
aAdd(aMATA103Cab,{"F1_EMISSAO","D", 8,0 })
aAdd(aMATA103Cab,{"F1_FORNECE","C", 6,0 })
aAdd(aMATA103Cab,{"F1_LOJA"   ,"C", 1,0 })
aAdd(aMATA103Cab,{"F1_ESPECIE","C", 3,0 })
aAdd(aMATA103Cab,{"F1_COND"   ,"C", 3,0 })
aAdd(aMATA103Cab,{"F1_TIPODOC","C", 2,0 })		

//Array dos items                          
aAdd(aMATA103Item,{"D1_TIPO"  ,"C", 1,0 })
aAdd(aMATA103Item,{"D1_DOC"   ,"C", 6,0 })
aAdd(aMATA103Item,{"D1_SERIE" ,"C", 3,0 })
aAdd(aMATA103Item,{"D1_COD"   ,"C",15,0 })
aAdd(aMATA103Item,{"D1_QUANT" ,"N", 5,0 })
aAdd(aMATA103Item,{"D1_VUNIT" ,"N",14,2 })
aAdd(aMATA103Item,{"D1_TOTAL" ,"N",14,2 })
aAdd(aMATA103Item,{"D1_TES"   ,"C", 3,0 })

//aAdd(aMATA103Item,{"D1_TIPODOC","C",2,0 })
// Se o Produto tem controle de Lote 
If cCtrlLote=="S"
  aAdd(aMATA103Item,{"D1_LOTECTL","C",10,0 })     
  aAdd(aMATA103Item,{"D1_DTVALID","D",8,0 })
endif  

aAdd(aMATA103Item,{"D1_NFORI" ,"C", 6,2 })
aAdd(aMATA103Item,{"D1_SERIORI","C", 3,0 })     
aAdd(aMATA103Item,{"D1_ITEMORI","C",4,0 })     

//ConOut("PALMJOB: Importando devolucoes para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	U_MontaDev(aMata103Cab, aMata103Item, @aCabec, @aItens, cPathPalm)
Else
	ConOut("PALMJOB: Arquivo de notas de entrada nao encontrado.")
EndIf
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ MontaDev   ³ Autor ³ Marcelo Vieira      ³ Data ³ 03/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MontaDev(aMATA103Cab,aMATA103Item,aCabec,aItens)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMata103Cab : Estrutura do arquivo do HF1     (Cabecalho)  ³±±
±±³          ³ aMata103Item: Estrutura do arquivo do HD1     (Item)       ³±±
±±³          ³ aCabec      : Array com os Dados do Arquivo CDB (Cabecalho)³±±
±±³          ³ aItens      : Array com os Dados do Arquivo CDB (Item)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MontaDev(aMata103Cab, aMata103Item, aCabec, aItens, cPathPalm)

Local cNumDoc		:= ""
Local cNumDocPalm   := ""
Local nPosR			:= 0 , i
Local cItemNovo     := "00"
Local aItemTmp		:= {}
Local nPreco		:= 0 , j
Local aPvlNfs       := {} // Valdir
Local lCtbOnline    := Iif(GetMv("MV_ATUSI2")="C",.F.,.T.)
Local cHrIni        := Time() // Hora de Inicio para a gravacao do Log
Local cResp         := ""     // Mensagem do no Console do Server e no Log
Local cCliente      := ""
Local cLoja         := ""

Local cSerieRet     := GetMV("MV_FDARET" ,,"RUA")
Local cTipoDev      := GetMV("MV_FDATPDV",,"D")
Local cFormul       := GetMV("MV_FDAFORM",,"S")       
Local cEspecie      := GetMV("MV_FDAESPC",,"NFE")       
Local nDel          := 0

//Seleciona notas de saida par achar o nr do Lote 
DbSelectArea("SD2")
dbSetOrder(3)

DbSelectArea("HD1")
DbGoTop()
While !Eof()

	cNumDoc   := HF1->F1_DOC
	cFornece  := HF1->F1_FORNECE    // CLIENTE  
	cLoja     := HF1->F1_LOJA       // LOJA
	nNumItem  := HF1->F1_QTDITE     // QTDE DE ITENS DA DEVOLUCAO
	
	cSerieRet := HF1->F1_SERIE
    cTipoDev  := HF1->F1_TIPO
    cFormul   := HF1->F1_FORMUL
    cEspecie  := HF1->F1_ESPECIE
	
	If AllTrim(HF1->F1_STATUS) = "N" //.OR. AllTrim(HF1->F1_STATUS) = "C"  ( se houver diferenciacao para Devolucao )
	   dbSelectArea("HF1")
	   For i:=1 to Len(aMATA103Cab)
			/*If aMata103Cab[i,1] = "F1_TIPO"
				aAdd(aCabec,{aMATA103Cab[i,1],cTipoDev,Nil})
			ElseIf aMata103Cab[i,1] = "F1_FORMUL"
				aAdd(aCabec,{aMATA103Cab[i,1],cFormul,Nil})
			ElseIf aMata103Cab[i,1] = "F1_SERIE"
				aAdd(aCabec,{aMATA103Cab[i,1],cSerieRet,Nil})
			ElseIf aMata103Cab[i,1] = "F1_ESPECIE"
				aAdd(aCabec,{aMATA103Cab[i,1],cEspecie,Nil})
			*/	
			If aMata103Cab[i,1] = "F1_TIPODOC"
				aAdd(aCabec,{aMATA103Cab[i,1],"  ",Nil})
			Else
				aAdd(aCabec,{aMATA103Cab[i,1],&("HF1->"+aMATA103Cab[i,1]),Nil})
			Endif
	   Next
	
	   DbSelectArea("HD1")
	   DbGoTop()
       DbSeek(cNumDoc)
	      While !Eof() .And. D1_DOC = cNumDoc                     
	      
                // Quando for devolucao de cliente nao precisa dos campos abaixo  
	            /* Se precisar basta tirar o comentario 
	            if  AllTrim(HF1->F1_STATUS) = "C" 
	               //1o para Devolucao de cliente nao precisa D1_nfori 
	               nDel := aScan(aMATA103Item, { |x| x[1] == "D1_NFORI" })		
				   aDel(aMATA103Item,nDel)
         		   aSize(aMATA103Item,Len(aMATA103Item)-1)
         		   
	               //2o para Devolucao de cliente nao precisa D1_SERIORI
	               nDel := aScan(aMATA103Item, { |x| x[1] == "D1_SERIORI" })		
				   aDel(aMATA103Item,nDel)
         		   aSize(aMATA103Item,Len(aMATA103Item)-1)

	               //3o para Devolucao de cliente nao precisa D1_ITEM
	               nDel := aScan(aMATA103Item, { |x| x[1] == "D1_ITEMORI" })		
				   aDel(aMATA103Item,nDel)
         		   aSize(aMATA103Item,Len(aMATA103Item)-1)

	            endif
	            */
	            
		    	For j := 1 To Len(aMATA103Item)
					If aMata103Item[j,1] = "D1_TIPO"
		        		aAdd(aItemTmp,{aMata103Item[j,1],cTipoDev,Nil})
					ElseIf aMata103Item[j,1] = "D1_FORMUL"
						aAdd(aItemTmp,{aMata103Item[j,1],cFormul,Nil})
					ElseIf aMata103Item[j,1] = "D1_SERIE"
						aAdd(aItemTmp,{aMata103Item[j,1],cSerieRet,Nil})
					ElseIf aMata103Item[j,1] = "D1_TIPODOC"
		        		aAdd(aItemTmp,{aMata103Item[j,1]," ",Nil})
					ElseIf aMata103Item[j,1] = "D1_NFORI" .And. AllTrim(HF1->F1_STATUS) = "N" 
		        		aAdd(aItemTmp,{aMata103Item[j,1],HD1->D1_NFORI , Nil})
					ElseIf aMata103Item[j,1] = "D1_SERIORI" .And. AllTrim(HF1->F1_STATUS) = "N" 
		        		aAdd(aItemTmp,{aMata103Item[j,1],HD1->D1_SERIORI,Nil})
                	Else
		        		aAdd(aItemTmp,{aMata103Item[j,1],&("HD1->"+aMata103Item[j,1]),Nil})
		        	Endif
				Next
			    dbSkip()
                If Len(aItemTmp) > 0
		            aAdd(aItens, aClone(aItemTmp))
                EndIf
				aItemTmp   := {}
		  EndDo
		  cItemNovo := "00"
		
		If nNumItem != Len(aItens)
			ConOut("Devolucao " + cNumDoc + " nao Importada, Devolucao nao transmitida completamente.")
			aCabec := {}
			aItens := {}
		EndIf

	Endif

    If Len(aCabec) > 0 .And. Len(aItens) > 0

	    lMsHelpAuto := .T.
	    lMsErroAuto := .F.   
	    
	    cFuncao:=IF( cPaisloc=="BRA", "MATA103" , "MATA465N" )
	    GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Inicio "+cFuncao+"  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
      
        //GRAVA DEVOLUCAO 

        IF cPaisLoc=="BRA"
           MATA103(aCabec,aItens)
        Else 		
 		   MATA465N(aCabec,aItens,3)
		Endif
		        
	    GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Fim "+cFuncao+" - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))

	    cNumDoc := SF1->F1_DOC
		ConOut("PALMJOB: Importacao de arquivos - Devolucao: " + cNumDoc) //"Importacao de arquivos - Devolucao: "
			    
		cItemNovo := "00"
                                                        
		If !lMsErroAuto
		    cResp := "PALMJOB: Devolucion " + cNumDoc + " importado com sucesso."
			GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Fim Importacao Devolucion = " + cNumDoc + "  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
		    dbSelectArea("HF1")	
		    RecLock("HF1",.F.)			// Altera o FLag para 0
		    HF1->F1_STATUS := "P"
		    MsUnlock()
		Else
			// devolucao nao Incluido
			cResp := "PALMJOB: Devolucao nao Incluida"
		   
			MostraErro(cPathPalm)
		EndIf
		ConOut(cResp)
		PSaveLog(PALMUSER->P_SERIE,PALMUSER->P_USERID,MsDate(),cHrIni,Time(),cResp)		

    EndIf
	aCabec := {}
    aItens := {}
    cNumDoc:= ""
  
    dbSelectArea("HF1") // cabecalho da nota
	dbSkip()
EndDo

dbSelectArea("HF1")
HF1->( dbCloseArea() )
dbSelectArea("HD1")
HD1->( dbCloseArea() )

Return Nil
