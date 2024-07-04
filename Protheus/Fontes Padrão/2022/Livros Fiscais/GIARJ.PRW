#INCLUDE "PROTHEUS.CH" 


Function GIARJ(dDataIni,dDataFim, cSelFiliais, aFilsCalc, nInscCent,cNrLivro)

Local aArea			:=  GetArea()
Local aApuICM 		:= {} 
Local aDadosApur	:= {}   
Local aDadosAp2 	:= {} 
Local aQryImport	:= {}
Local cMVEstado		:= Alltrim(Upper(GetNewPar("MV_ESTADO","")))
Local cAliasSF3 	:= "SF3" 
Local cIE    		:= ""
Local cInscPos		:= "" 
Local cFilAntOri	:= "" 
Local cFilPos		:= ""
Local cDtPer		:= ""
Local cAliasCDH	:=	"CDH" 	
Local cCodLan		:="00169#00170#00194#00207#00208#00209#00210#00274#00276" 	
Local cCodImp		:="00207#00209"  // Sequencial da Ocorrencia referentes a importacao 	
Local i				:= 0
Local x				:= 0
Local y				:= 0 
Local nCont	 		:=0  
Local nY	 		:=0  
Local lTop   		:= .F.
Local lGera			:= .F. 
Local lSair			:= .F.
Local lUsaSped		:= SuperGetMv("MV_USASPED",,.T.)   
Default cSelFiliais :=2 //Default NAO
Default aFilsCalc	:= {} //Default VAZIO
Default nInscCent	:= 1 //Default NAO   
Default cNrLivro	:= "*"  
 
DbSelectArea("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek(cEmpAnt + cFilAnt))

cInscPos:= SM0->M0_INSC //Inscrição estadual da filial original

If lUsaSped
	//Com base na CHD
	ApuICMSCDH("CDH",@cAliasCDH,{"IC","3","1",DTOS(dDataIni),DTOS(dDataFim),cNrLivro})  
	While !(cAliasCDH)->(EOF())
		AADD(aApuICM,{AllTrim((cAliasCDH)->CDH_LINHA),(cAliasCDH)->CDH_DESC,(cAliasCDH)->CDH_VALOR,AllTrim((cAliasCDH)->CDH_SUBITEM),(cAliasCDH)->CDH_GNRE,(cAliasCDH)->CDH_CODLAN})
		(cAliasCDH)->(DbSkip())
	Enddo
Else   
	aApuICM     := FisApur("IC",val(Substr(DTOS(dDataFim),1,4)),val(Substr(DTOS(dDataFim),5,2)),2,0,"*",.F.,{},1,.T.,,"")  //PUR
Endif

For y:=1 to Len(aApuICM)  
  IF 	aApuICM[y,01]=="002" .And. Alltrim(aApuICM[y,04])<>"002.00" .And. aApuICM[y,03] >0
  		RecLock("PUR",.T.) 
  		PUR->CODIGO :="002"
  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
  		PUR->VALOR	:= aApuICM[y,03] 
  		PUR->(MSunlock())	 
  EndIf
  
  //ESTORNO DE CREDITOS
  IF aApuICM[y,01] == "003" .And. Alltrim(aApuICM[y,04])<>"003.00"  .And. aApuICM[y,03] >0 
  		RecLock("PUR",.T.)
  		PUR->CODIGO :="003"
  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
  		PUR->VALOR	:= aApuICM[y,03]
  		PUR->(MSunlock()) 
  EndIf  
  
  //OUTROS CREDITOS
  IF aApuICM[y,01] == "006" .And. Alltrim(aApuICM[y,04])<>"006.00"  .And. aApuICM[y,03] >0
  		RecLock("PUR",.T.)
  		PUR->CODIGO := "006"
  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
  		PUR->VALOR	:= aApuICM[y,03]
  		PUR->(MSunlock()) 	
  EndIf  
  
  //ESTORNO DE DEBITOS
  IF aApuICM[y,01] == "007" .And. Alltrim(aApuICM[y,04])<>"007.00"  .And. aApuICM[y,03] >0
  		RecLock("PUR",.T.)
  		PUR->CODIGO := "007"
  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
  		PUR->VALOR	:= aApuICM[y,03]
  		PUR->(MSunlock())	
  EndIf  
   
  //DEDUCOES OU MOVIMENTACOES COM PRAZO ESPECIAL
  IF aApuICM[y,01] == "012" .And. Alltrim(aApuICM[y,04])<>"012.00" .And. aApuICM[y,03] >0 
  		RecLock("PUR",.T.)  
  		PUR->CODIGO := "012"
  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
  		PUR->VALOR	:= aApuICM[y,03] 
  		PUR->(MSunlock())	
  EndIf
 
  //MOVIMENTACOES DE OUTROS ICMS DEVIDO
  /* Obs. Incluso tratamento para o Código 064 - FEEF-RJ    */
  
  IF (aApuICM[y,01]$"19|20|064") .Or. (aApuICM[y,01]=="900" .And. Alltrim(aApuICM[y,04])$cCodLan)  	 		
  		
  		
  		//Tratamento para preenchimento das informações complementares para os códigos de lançamentos RJ70000001 e RJ70000005
	 	If aApuICM[y,01]=="900" .And. Alltrim(aApuICM[y,04])$cCodImp
	  		aQryImport:= ComplImp(Alltrim(aApuICM[y,06]),dDataIni,dDataFim,Iif(Alltrim(aApuICM[y,04])$cCodImp, .T., .F.))
	  		If Alltrim(aApuICM[y,04])$cCodImp  
		  		For nY:=1 to len(aQryImport) 
		  			cDtDsmb:= SubStr(aQryImport[nY,01],7,2)+SubStr(aQryImport[nY,01],5,2)+SubStr(aQryImport[nY,01],1,4)
		  		
					RecLock("PUR",.T.) 
			  	    PUR->CODIGO := Alltrim(aApuICM[y,01]) 
			  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
			  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
			  		PUR->VALOR	:= aQryImport[nY,04]
			  		PUR->CODLAN := Alltrim(aApuICM[y,06])
			  		PUR->COMPL1 := Alltrim(cDtDsmb)
			  		PUR->COMPL2 := Iif(Alltrim(aQryImport[nY,02])=="0","D","O")
			  		PUR->COMPL3 := Alltrim(aQryImport[nY,03])
			  		PUR->(MSunlock())
			  	Next
			Else
				For nY:=1 to len(aQryImport) 
			  		RecLock("PUR",.T.) 
		  	    	PUR->CODIGO := aApuICM[y,01] 
			  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
			  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
			  		PUR->VALOR	:= aApuICM[y,03]
			  		PUR->(MSunlock())
			 	 Next
			EndIf	   			  				
	  	ElseIf aApuICM[y,01]=="064" .And. 'FEEF'$ Alltrim(UPPER(aApuICM[y,02])) //Tratamento para atender o FEEF-RJ
	  		If aApuICM[y,03]>0
		  		RecLock("PUR",.T.) 
	  	    	PUR->CODIGO := '064' 
		  		PUR->SUBCOD := '00276'
		  		PUR->DESCR	:= 'FEEF RJ'
		  		PUR->VALOR	:= aApuICM[y,03]
		  		PUR->(MSunlock())
	  		EndIf 
	  	Else	
	  		RecLock("PUR",.T.) 
 	    	PUR->CODIGO := aApuICM[y,01] 
	  		PUR->SUBCOD := Alltrim(aApuICM[y,04])
	  		PUR->DESCR	:= Alltrim(aApuICM[y,02])
	  		PUR->VALOR	:= aApuICM[y,03]
	  		PUR->(MSunlock()) 
	  	EndIf	   		
  EndIf
Next
	
If AliasIndic("F0I")
	DbSelectArea("F0I")
	DbSetOrder(1)
	//MOVIMENTACOES DE OUTROS ICMS DEVIDO (Imposto pela proporção devido ao RJ EC 87/15)
	If DbSeek(xFilial("F0I")+DTOS(dDataIni)+"RJ"+cNrLivro)
		While !F0I->(Eof()) .And. F0I->F0I_FILIAL+Dtos(F0I->F0I_PER)+F0I->F0I_UF+F0I->F0I_LIVRO == xFilial("F0I")+DTOS(dDataIni)+"RJ"+cNrLivro
			If F0I->F0I_DIFREC+F0I->F0I_FCPREC > 0
				cDtPer := DTOS(F0I->F0I_PER)
				RecLock("PUR",.T.)
				PUR->CODIGO := "010"
				PUR->SUBCOD := "00274"
				PUR->DESCR  := "Valor Recolher Difal RJ"
				PUR->VALOR  := F0I->F0I_DIFREC+F0I->F0I_FCPREC
				PUR->CODLAN := ""
				PUR->COMPL1 := SubStr(cDtPer,7,2)+ SubStr(cDtPer,5,2)+SubStr(cDtPer,1,4)
				PUR->COMPL2 := "1" //Mensal
				PUR->COMPL3 := ""
				PUR->(MSunlock())
			EndIf
			F0I->(DbSkip())
		EndDo
	EndIf
EndIf

Do While !SM0->(Eof()) .And. cEmpAnt==SM0->M0_CODIGO
	
	//Quando seleciona filiais estiver igual a SIM. tiver filiais selecionadas e a opção Incrição Centralizada for 1
	// Tem que gerar 1 arquivo com todas as filiais selecionas, desde que possuam a mesma inscrição estadual
	 IF cSelFiliais == 1 .And.  Len(aFilsCalc) > 0 .And. nInscCent == "2"
	    	cFilAnt := FWGETCODFILIAL  //Retorna o código da filial posicionada
	    	nPosFil := aScan(aFilsCalc,{|x| Alltrim(x[2]) == Alltrim(cFilAnt)})
	    	lGera   := (nPosFil>0 .And. aFilsCalc[nPosFil,1] .And. cInscPos == SM0->M0_INSC)
	  Else
	        lGera := .T.
	        lSair := .T.
	  EndIf		
	  			
    IF lGera
		aDadosApur  := ResumeF3("IC",dDataIni,dDataFim,"*",.F.,.T.,1,.F.,1,cFilAnt,cFilAnt,{},{},"",.F.,,,,) //ICM				   
		aDadosAp2   := ResumeF3("IC",dDataIni,dDataFim,"*",.F.,.F.,1,.F.,1,cFilAnt,cFilAnt,{},{},"",.F.,,.T.) //IUF quebra por UF 
		    
		For i:=1 to Len(aDadosApur)
		 	IF Substr(aDadosApur[i,1],1,1) < "5" // Se o CFOP for menor que 5
		 		IF	ICM->(MsSeek(aDadosApur[i,01]))  
		 		  		RecLock("ICM",.F.)
						ICM->VALCONT	+= aDadosApur[i,11]	
						ICM->BASEICM	+= aDadosApur[i,03]
						ICM->VALICM		+= aDadosApur[i,04]		
						ICM->ISENICM	+= aDadosApur[i,05]	
						ICM->OUTRICM	+= aDadosApur[i,06]
						ICM->BASERET	+= aDadosApur[i,07]
						ICM->ICMSRET	+= aDadosApur[i,08]
						ICM->(MSunlock())
		 		Else
		 				RecLock("ICM",.T.)
						ICM->CFOP		:= aDadosApur[i,01]	
						ICM->VALCONT	:= aDadosApur[i,11]	
						ICM->BASEICM	:= aDadosApur[i,03]
						ICM->VALICM		:= aDadosApur[i,04]		
						ICM->ISENICM	:= aDadosApur[i,05]	
						ICM->OUTRICM	:= aDadosApur[i,06]
						ICM->BASERET	:= aDadosApur[i,07]
						ICM->ICMSRET	:= aDadosApur[i,08]
						ICM->(MSunlock())
		 		EndIf				 	    
		 	EndIf 
	    
	        // ICM MOVIMENTOS DE SAIDAS
		 	IF Substr(aDadosApur[i,1],1,1) >= "5" // Se o CFOP for maior que 5
				IF	ICM->(MsSeek(aDadosApur[i,01]))
				    	RecLock("ICM",.F.)
						ICM->VALCONT	+= aDadosApur[i,11]	
						ICM->BASEICM	+= aDadosApur[i,03]
						ICM->VALICM		+= aDadosApur[i,04]		
						ICM->ISENICM	+= aDadosApur[i,05]	
						ICM->OUTRICM	+= aDadosApur[i,06]
						ICM->BASERET	+= aDadosApur[i,07]
						ICM->ICMSRET	+= aDadosApur[i,08]
						ICM->(MSunlock())
				Else
						RecLock("ICM",.T.)
						ICM->CFOP		:= aDadosApur[i,01]	
						ICM->VALCONT	:= aDadosApur[i,11]	
						ICM->BASEICM	:= aDadosApur[i,03]
						ICM->VALICM		:= aDadosApur[i,04]		
						ICM->ISENICM	:= aDadosApur[i,05]	
						ICM->OUTRICM	:= aDadosApur[i,06]
						ICM->BASERET	:= aDadosApur[i,07]
						ICM->ICMSRET	:= aDadosApur[i,08]
						ICM->(MSunlock())
				EndIf		 	   		 
		 	EndIf
		Next
		
		//MOVIMENTACOES DE ENTRADAS INTERESTADUAIS
		For x:=1 to Len(aDadosAp2)
		   IF cMVEstado <> aDadosAp2[x,19] .And. aDadosAp2[x,01] == "ENTR"
		   		IF  IUF->(MsSeek(aDadosAp2[x,19]+aDadosAp2[x,01]))
		   			RecLock("IUF",.F.)
					IUF->VALCONT += aDadosAp2[x,11]
					IUF->BASEICM += aDadosAp2[x,03]
					IUF->OUTRICM += aDadosAp2[x,06]
					IUF->ISENICM += aDadosAp2[x,05]
					IUF->ICMSRET += aDadosAp2[x,08]
					IUF->(MSunlock())   
		   		Else
		   			RecLock("IUF",.T.)
					IUF->UF		 :=	aDadosAp2[x,19]	
					IUF->CFOP	 :=	aDadosAp2[x,01]	
					IUF->VALCONT := aDadosAp2[x,11]
					IUF->BASEICM := aDadosAp2[x,03]
					IUF->OUTRICM := aDadosAp2[x,06]
					IUF->ISENICM := aDadosAp2[x,05]
					IUF->ICMSRET := aDadosAp2[x,08]
					IUF->(MSunlock())   
		   		EndIf	 
		   EndIf 
	
		   //MOVIMENTACOES DE SAIDAS INTERESTADUAIS
		   IF cMVEstado <> aDadosAp2[x,19] .And. aDadosAp2[x,01] == "SAID"  
		   		IF  IUF->(MsSeek(aDadosAp2[x,19]+aDadosAp2[x,01]))
		   			RecLock("IUF",.F.)	
			     	IUF->VALCONNC += aDadosAp2[x,25]
			     	IUF->VALCONC  += aDadosAp2[x,27]
			     	IUF->BASEICNC += aDadosAp2[x,26]
			     	IUF->BASEICC  += aDadosAp2[x,28]
			     	IUF->OUTRICM  += aDadosAp2[x,06]
			     	IUF->ISENICM  += aDadosAp2[x,05]
			     	IUF->ICMSRET  += aDadosAp2[x,08]
			     	IUF->(MSunlock())   
		   		Else
			   		RecLock("IUF",.T.)	
			   		IUF->UF		  :=	aDadosAp2[x,19]	
			   	    IUF->CFOP	  :=	aDadosAp2[x,01]
			     	IUF->VALCONNC := aDadosAp2[x,25]
			     	IUF->VALCONC  := aDadosAp2[x,27]
			     	IUF->BASEICNC := aDadosAp2[x,26]
			     	IUF->BASEICC  := aDadosAp2[x,28]
			     	IUF->OUTRICM  := aDadosAp2[x,06]
			     	IUF->ISENICM  := aDadosAp2[x,05]
			     	IUF->ICMSRET  := aDadosAp2[x,08]
			     	IUF->(MSunlock())   
		   		EndIf
		   EndIf 
		   
		Next
		
	 //Movimentacao de Saidas para ZFM/ALC	
	#IFDEF TOP
    	If (TcSrvType ()<>"AS/400")	  
     	lTop	:= .T.
     	cAliasSF3	:=	GetNextAlias()
      
	    	 BeginSql Alias cAliasSF3    
	    	
				COLUMN F3_EMISSAO AS DATE
				
				SELECT SF3.F3_FILIAL,
					SF3.F3_ENTRADA, 
					SF3.F3_EMISSAO,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_CFO,
					SF3.F3_ALIQICM,
					SF3.F3_TIPO,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_VALCONT,
					SF3.F3_ISENICM
				FROM 
				    %TABLE:SF3% SF3
				WHERE
				SF3.F3_FILIAL = %xfilial:SF3%	 
				AND SF3.F3_EMISSAO >= %EXP:DTOS(dDataIni)% 
				AND SF3.F3_EMISSAO <= %EXP:DTOS(dDataFim)%
				AND SF3.%NOTDEL% 
				AND SF3.F3_TIPO <> "S"
				AND SF3.F3_DTCANC = " "
				ORDER BY SF3.F3_FILIAL, SF3.F3_ENTRADA, SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_CFO, SF3.F3_ALIQICM 
		     EndSql 
				
		 	DbSelectArea (cAliasSF3)
	     	(cAliasSF3)->(DbGoTop())
		Else
	#ENDIF       
	   cIndex	:= CriaTrab(NIL,.F.)
	   cFiltro := 'DTOS (F3_EMISSAO)>="'+DTOS(dDataIni)+'" .And. ' 
	   cFiltro += 'DTOS (F3_EMISSAO)<="'+DTOS(dDataFim)+'" .And. ' 
	   cFiltro += 'DTOS (F3_TIPO)<>"S"'                   
	      
	   IndRegua (cAliasSF3, cIndex, SF3->(IndexKey ()),, cFiltro)
	   nIndex := RetIndex(cAliasSF3)
	   #IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ()) 
			dbSelectArea(cAliasSF3)
			dbCloseArea()
	   #ENDIF
		DbSelectArea (cAliasSF3)
	    DbSetOrder (nIndex+1)        
		
		#IFDEF TOP
			Endif
		#ENDIF 

		If lTop
			cAliasSF3	:= cAliasSF3				 				 
		EndIf
			    
		DbSelectArea (cAliasSF3)
		(cAliasSF3)->(DbGoTop())  
		
		dbSelectArea("SA1")	
		SA1->(dbSetOrder(1))
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))		
		
		//Movimentacao de Saidas para ZFM/ALC
		While (cAliasSF3)->(!Eof())
			IF !lTop  
		   		(cAliasSF3)->(MsSeek(xFilial("SF3")+(cAliasSF3)->F3_EMISSAO))   
			ENDIF
	        
	        IF Subs((cAliasSF3)->F3_CFO,1,1)="6" .And.;        
	        ((cAliasSF3)->F3_TIPO$"DB",SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)),SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))) .And.;
	        IIF(SA2->(FieldPos("A2_CODLOC"))>0,((cAliasSF3)->F3_TIPO$"DB",!Empty(SA2->A2_CODLOC),!Empty(SA1->A1_CODLOC)),.F.) .And.;
	        ((cAliasSF3)->F3_TIPO$"DB",!Empty(SA2->A2_CODMUN),!Empty(SA1->A1_SUFRAMA)) .And. ;
	        SX5->(MsSeek(xFilial("SX5")+"AB"+IIf((cAliasSF3)->F3_TIPO$"DB",Subs(SA2->A2_CODLOC,5,4),Subs(SA1->A1_CODLOC,5,4))))
	        	RecLock("ZFM",.T.)
	        	ZFM->SERIE 		    :=(cAliasSF3)->F3_SERIE
	        	ZFM->NFISCAL		:=RetNf((cAliasSF3)->F3_NFISCAL,6,"C") 	
	        	ZFM->EMISSAO		:=Dtos((cAliasSF3)->F3_EMISSAO)+StrTran(Time(),":","")
	        	ZFM->VALCONT		:=(cAliasSF3)->F3_VALCONT
	        	ZFM->ISENICM		:=(cAliasSF3)->F3_ISENICM
	            ZFM->CNPJ			:=Iif((cAliasSF3)->F3_TIPO$"DB",SA2->A2_CGC,SA1->A1_CGC)
	            ZFM->SUFRAMA		:=Iif((cAliasSF3)->F3_TIPO$"DB",SPACE(09),SA1->A1_SUFRAMA)
	            ZFM->LOCALIDADE     := IIf((cAliasSF3)->F3_TIPO$"DB",Subs(SA2->A2_CODLOC,5,4),Subs(SA1->A1_CODLOC,5,4))
	            ZFM->(MSunlock()) 
	        EndIf
		(cAliasSF3)->(dbSkip()) 
	 	Enddo
		IF lSair // Se for para gerar apenas para filial logada
		 	Exit
		EndIf 	
	EndIf
	SM0->(DbSkip ())
EndDo
				

RestArea(aArea)
Return

Function TrabGIARJ(nTipo)
Local aICM 	:= {}
Local aPur	:= {}
Local aIUF	:= {}
Local aZFM  := {} 
Local aArq	:= {}  
Local nI	:= 0
DEFAULT aArq := {}

If nTipo == 1 // Cria Tabelas Temporárias		
		//VETOR COM A ESTRUTURA DA TABELA TEMPORARIA -ICM
		aadd(aICM,{"CFOP",  'C',04,0})
		aadd(aICM,{"VALCONT",'N',15,2})    
		aadd(aICM,{"BASEICM",'N',15,2})  
		aadd(aICM,{"VALICM", 'N',15,2})
		aadd(aICM,{"ISENICM",'N',15,2})
		aadd(aICM,{"OUTRICM",'N',15,2})
		aadd(aICM,{"BASERET",'N',15,2}) 
		aadd(aICM,{"ICMSRET",'N',15,2})   
		
		//CRIA TABELA TEMPORARIA E INDICE
		cArqTrab :=CriaTrab(aICM,.T.)
		dbUseArea(.T.,,cArqTrab,"ICM",.F.,.F.)				
		IndRegua( "ICM", cArqTrab,"CFOP")
		aAdd (aArq, {cArqTrab}) 	 
		dbSelectArea("ICM")
		
		//VETOR COM A ESTRUTURA DA TABELA TEMPORARIA PUR
		aadd(aPur,{"CODIGO",'C',3,0})
		aadd(aPur,{"SUBCOD",'C',6,0})
		aadd(aPur,{"DESCR",'C',150,0})
		aadd(aPur,{"VALOR",'N',15,2})  
		aadd(aPur,{"CODLAN",'C',10,0})
		aadd(aPur,{"COMPL1",'C',08,0})
		aadd(aPur,{"COMPL2",'C',1,0})
		aadd(aPur,{"COMPL3",'C',12,0})
		
		//CRIA TABELA TEMPORARIA E INDICE
		cArqTrab :=CriaTrab(aPur,.T.)
		dbUseArea(.T.,,cArqTrab,"PUR",.F.,.F.)				
		IndRegua( "PUR", cArqTrab,"CODIGO+SUBCOD")
		aAdd (aArq, {cArqTrab}) 	 
		dbSelectArea("PUR")
		 
		//VETOR COM A ESTRUTURA DA TABELA TEMPORARIA IUF
		aadd(aIUF,{"UF",    'C',02,0})
		aadd(aIUF,{"CFOP",  'C',04,0})
		aadd(aIUF,{"VALCONT",'N',15,2})    
		aadd(aIUF,{"BASEICM",'N',15,2})  
		aadd(aIUF,{"VALICM", 'N',15,2})
		aadd(aIUF,{"ISENICM",'N',15,2})
		aadd(aIUF,{"OUTRICM",'N',15,2})
		aadd(aIUF,{"BASERET",'N',15,2}) 
		aadd(aIUF,{"ICMSRET",'N',15,2}) 
		aadd(aIUF,{"VALCONNC",'N',15,2})  
		aadd(aIUF,{"VALCONC",'N',15,2})  
		aadd(aIUF,{"BASEICNC",'N',15,2})  
		aadd(aIUF,{"BASEICC",'N',15,2})                                       
		
		//CRIA TABELA TEMPORARIA E INDICE
		cArqTrab :=CriaTrab(aIUF,.T.)
		dbUseArea(.T.,,cArqTrab,"IUF",.F.,.F.)				
		IndRegua( "IUF", cArqTrab,"UF+CFOP") 
		aAdd (aArq, {cArqTrab})	 
		dbSelectArea("IUF") 
		
		//VETOR COM A ESTRUTURA DA TABELA TEMPORARIA ZFM-ZONA FRANCA DE MANAUS
		aadd(aZFM,{"NFISCAL",'C',06,0})
		aadd(aZFM,{"SERIE",  'C',03,0})
		aadd(aZFM,{"EMISSAO",'C',14,0})    
		aadd(aZFM,{"VALCONT",'N',15,2})  
		aadd(aZFM,{"ISENICM",'N',15,2})
		aadd(aZFM,{"CNPJ",   'C',14,0})
		aadd(aZFM,{"SUFRAMA",'C',09,0})
		aadd(aZFM,{"LOCALIDADE",'C',08,0})
		
		//CRIA TABELA TEMPORARIA E INDICE
		cArqTrab :=CriaTrab(aZFM,.T.)
		dbUseArea(.T.,,cArqTrab,"ZFM",.F.,.F.)	
		IndRegua( "ZFM", cArqTrab,"NFISCAL+SERIE") 
		aAdd (aArq, {cArqTrab})	 
		dbSelectArea("ZFM")
Else //Apaga tabelas temporarias
		For nI := 1 To Len(aArq)
			DbSelectArea(aArq[nI][1])
			(aArq[nI][1])->(DbCloseArea())
			Ferase(aArq[nI][2]+GetDBExtension())
			Ferase(aArq[nI][2]+OrdBagExt())	
   		Next nI	                       
EndIf
Return(aArq)

//-----------------------------------------------------------------------
/*/{Protheus.doc}	ApuICMSCDH()
Funcao que le a tabela CDH apuracao de icms quando MV_USASPED=.T.
         
@author Simone Oliveira       
@since 07.04.2014
@version 1.0 

@param		cTabela	Para uso em DBF
@param		cAlias	Para uso no select
@param		aPar	Parametros para selecao
			
@return		
/*/
//-----------------------------------------------------------------------
Static Function ApuICMSCDH(cTabela,cAlias,aPar)
Local nIndex	:= 1
Local cFiltro	:= ""
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""

	DbSelectArea("CDH")
	CDH->(DbSetOrder(1))
		
	#IFDEF TOP
    	If (TcSrvType()<>"AS/400")
			cSelect :=	"%A.*%"
			cFrom	:=	"%"+RetSqlName("CDH")+" A %" 
 		   	cWhere	:=	"%A.CDH_FILIAL='"+xFilial("CDH")+"' AND "
			cWhere	+=	"A.CDH_TIPOIP='"+aPar[1]+"' AND "
			cWhere	+=	"A.CDH_TIPOPR='"+aPar[2]+"' AND "
			cWhere	+=	"A.CDH_PERIOD='"+aPar[3]+"' AND "
			cWhere	+=	"A.CDH_DTINI='"	+aPar[4]+"' AND "
			cWhere	+=	"A.CDH_DTFIM='"	+aPar[5]+"' AND "
			If aPar[6] <> "*"
			 	cWhere	+=	"A.CDH_LIVRO='"	+aPar[6]+"' AND "
			 EndIf
			cWhere	+=	"A.CDH_SEQUEN=(SELECT MAX(CDH_SEQUEN) FROM "+RetSqlName("CDH")+" WHERE CDH_FILIAL=A.CDH_FILIAL AND CDH_TIPOIP=A.CDH_TIPOIP AND CDH_TIPOPR=A.CDH_TIPOPR AND CDH_PERIOD=A.CDH_PERIOD AND CDH_DTINI=A.CDH_DTINI AND CDH_LIVRO=A.CDH_LIVRO AND D_E_L_E_T_='') AND "
			cWhere	+=	"A.D_E_L_E_T_=''%"  

    		cAlias	:=	GetNextAlias()

			BeginSql Alias cAlias			
				SELECT 
					%Exp:cSelect%			
				FROM 
					%Exp:cFrom%			
				WHERE 
					%Exp:cWhere%
			EndSql
		Else
	#ENDIF	
			 cFiltro	:=	"CDH_FILIAL=='"+xFilial("CDH")+"' .AND. "
			 cFiltro	+=	"CDH_TIPOIP=='"+aPar[1]+"' .AND. "
			 cFiltro	+=	"CDH_TIPOPR=='"+aPar[2]+"' .AND. "
			 cFiltro	+=	"CDH_PERIOD=='"+aPar[3]+"' .AND. "
			 cFiltro	+=	"DToS(CDH_DTINI)=='"+aPar[4]+"' .AND. "
			 cFiltro	+=	"DToS(CDH_DTFIM)=='"+aPar[5]
			 If aPar[6] <> "*"
			 	cFiltro	+=	"' .AND. CDH_LIVRO=='"+aPar[6]
			 EndIf

		    cIndex	:= CriaTrab(Nil,.F.)
		    cTabela	:=	SubStr(cTabela,1,3)
		
		    IndRegua (cAlias,cIndex,CDH->(IndexKey()),,cFiltro,"Selecionando Registros",.F.)
		    nIndex := RetIndex(cAlias)
		
			 DbSelectArea(cAlias)
			(cAlias)->(DbGoTop())		    
	#IFDEF TOP
		EndIf
	#ENDIF
Return(.T.)	 

//-----------------------------------------------------------------------

/*/{Protheus.doc}	ComplImp()
Funcao que busca dados da tabela CD5 para preencher as informações complementares
referente a importação.
         
@author Simone Oliveira       
@since 07.04.2014
@version 1.0 

@param		cCodLan	  Código do Lançamento apresentado na CDH
@param		dDataIni  Data inicial do período
@param		dDataFim  Data final do período
			
@return		aRet	 		
/*/
//-----------------------------------------------------------------------
Static Function ComplImp(cCodLan,dDataIni,dDataFim,cCodImp)

Local aRet		:= {}
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= "" 
Local cAlias	:= "" 

                         
#IFDEF TOP
	If cCodImp
    	If (TcSrvType()<>"AS/400")
			cSelect :=	"%CD5.CD5_DTDES, CD5.CD5_TPIMP ,CD5.CD5_NDI, CDA.CDA_VALOR%"
			cFrom	:=	"%"+RetSqlName("CDA")+" CDA " 
			cFrom	+=	" JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=CDA.CDA_NUMERO AND SD1.D1_SERIE=CDA.CDA_SERIE "
			cFrom	+=	" AND SD1.D1_FORNECE=CDA.CDA_CLIFOR AND SD1.D1_LOJA=CDA.CDA_LOJA AND SD1.D1_ITEM=CDA.CDA_NUMITE AND SD1.D1_EMISSAO BETWEEN "+DtoS(dDataIni)+" AND "+DtoS(dDataFim)+"AND SD1.D_E_L_E_T_=' '"
	 		cFrom	+=	" JOIN "+RetSqlName("CD5")+" CD5 ON CD5.CD5_FILIAL='"+xFilial("CD5")+"' AND CD5.CD5_DOC=SD1.D1_DOC AND CD5.CD5_SERIE=SD1.D1_SERIE AND CD5.CD5_FORNEC=SD1.D1_FORNECE  "
	 		cFrom	+=	" AND CD5.CD5_LOJA=SD1.D1_LOJA AND CD5.CD5_ITEM=SD1.D1_ITEM AND CD5.D_E_L_E_T_=' '%"
	 		cWhere	:=	"%CDA.CDA_FILIAL='"+xFilial("CDA")+"' AND "
			cWhere	+=	"CDA.CDA_CODLAN='"+cCodLan+"' AND "
			cWhere	+=	"CDA.D_E_L_E_T_=''%"  
	
			cAlias	:=	GetNextAlias()
	
			BeginSql Alias cAlias			
				SELECT 
					%Exp:cSelect%			
				FROM 
					%Exp:cFrom%			
				WHERE 
					%Exp:cWhere%
			EndSql
		EndIf
	
		While !EOF()
			Aadd(aRet,{CD5_DTDES,CD5_TPIMP,CD5_NDI,CDA_VALOR})
			DbSkip()	
		EndDo
	Else
		If (TcSrvType()<>"AS/400")
			cSelect :=	"%CDA.CDA_VALOR%"
			cFrom	:=	"%"+RetSqlName("CDA")+" CDA " 
			cFrom	+=	" JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=CDA.CDA_NUMERO AND SD1.D1_SERIE=CDA.CDA_SERIE "
			cFrom	+=	" AND SD1.D1_FORNECE=CDA.CDA_CLIFOR AND SD1.D1_LOJA=CDA.CDA_LOJA AND SD1.D1_ITEM=CDA.CDA_NUMITE AND SD1.D1_EMISSAO BETWEEN "+DtoS(dDataIni)+" AND "+DtoS(dDataFim)+" AND SD1.D_E_L_E_T_=' '%"
	 		cWhere	:=	"%CDA.CDA_FILIAL='"+xFilial("CDA")+"' AND "
			cWhere	+=	"CDA.CDA_CODLAN='"+cCodLan+"' AND "
			cWhere	+=	"CDA.D_E_L_E_T_=''%"  
	
			cAlias	:=	GetNextAlias()
	
			BeginSql Alias cAlias			
				SELECT 
					%Exp:cSelect%			
				FROM 
					%Exp:cFrom%			
				WHERE 
					%Exp:cWhere%
			EndSql
		EndIf		
	    While !EOF()
	    	Aadd(aRet,{CDA_VALOR})
	      	DbSkip()	
	    EndDo	
	EndIf     
#ENDIF	


Return aRet
