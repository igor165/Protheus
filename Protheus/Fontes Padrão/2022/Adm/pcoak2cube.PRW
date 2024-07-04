#include "protheus.ch"

Function PcoAk2Cube(cPlanilha, cVersao)
Local nx   ,nt
Local aRecAK3	:= {}
Local aNiveis := {}
Local ny
Local nz
Local lRet 	:= .F.
Local aCampos := {}
Local nPos	:= 1
Local nPosPer	:= 0
Local nPosConta	:= 0
Local  aPeriodProc	:=	{}
Private  aPeriodGet :=	{}
Private  aConfig 	:= 	{}
dbSelectArea("AK1")
dbSetOrder(1)
MsSeek(xFilial()+cPlanilha)
aPerPlnAtu := PcoRetPer()
aParam	:= { { 1 ,"Cubo",Space(LEN(AL1->AL1_CONFIG))		  ,"@!" 	 ,""  ,"AL1" ,"" ,25 ,.T. },; 
					{ 1 ,"Configuração",Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,""  ,"AL3" ,"" ,25 ,.F. },; 
					{3,"Exibe Configurações ",1,{"Sim","Nao"},40,,.F.},;
					{3,"Inverter Valores Negativos",1,{"Sim","Nao"},40,,.F.},;
					{2 ,"Moeda",1,{"1=Moeda 1","2=Moeda 2","3=Moeda 3","4=Moeda 4","5=Moeda 5"},80,"",.T.}						 }

For nx := 1 to Len(aPerPlnAtu)
	aAdd(aParam,{5,aPerPlnAtu[nx],.F.,90,,.F.}  ) //"Processar resultados de valores zerados "
	aAdd(aParam,{1 ,"Data de",CTOD("  /  /  "),"" 	 ,""  ,"" ,"" ,55 ,.F. }   ) 
	aAdd(aParam,{1 ,"Data Ate",CTOD("  /  /  "),"" 	 ,""  ,"" ,"" ,55 ,.F. }   ) 
Next
If ParamBox(aParam,"Parametros",aConfig)
	aPeriodProc	:=	{}
	aPeriodGet 	:=	{}
	For nX:=6 To Len(aConfig) STEP 3  
		nPosPer++
		If aConfig[nX]
			Aadd(aPeriodProc,aPerPlnAtu[nPosPer])
			Aadd(aPeriodGet ,{aConfig[nX+1],aConfig[nX+2]})
		Endif		
	Next
	dbSelectArea("AKW")
	dbSetOrder(1)
	MsSeek(xFilial()+aConfig[1])
	While !Eof() .And. 	xFilial()+aConfig[1] == AKW->AKW_FILIAL+AKW->AKW_COD
		cCampo := StrTran(StrTran(AllTrim(UPPER(AKW->AKW_CHAVER)),"AKD","AK2"),"AK2->","")
		aAdd(aCampos,{cCampo,nPos,AKW->AKW_TAMANH})
		If Alltrim(cCampo) == "AK2_CO"
			nPosConta := Len(aCampos)
		EndIf
		nPos += AKW->AKW_TAMANH
		dbSelectArea("AKW")
		dbSkip()
	EndDo
	If nPosConta > 0
		PcoIniLan("000252")
		aProcessa := PcoRunCube(aConfig[1],Len(aPeriodProc),"PcoAK2SldC",aConfig[2] ,aConfig[3],.F.,aNiveis,,,,,,.T.,.T.)
		Begin Transaction 
		Processa({|| GravaAK2(aPeriodProc,aProcessa,aNiveis,cPlanilha,cVersao,aCampos)	},'Gerando items...')
		End Transaction
		PcoFinLan("000252")
	Else
		Aviso("Cubo Invalido","O cubo selecionado não possui a conta orçamentária na estrutura. Seleciona um cubo que possua conta orçamentaria ns estrutura.",{"Fechar"},2)
	EndIf
EndIf


Return lRet

Static Function GravaAK3(cOrcame,cVersao,cCO,aRecAK3,cNivel)
Local aArea := GetArea()
dbSelectArea("AK5")
dbSetOrder(1)
If MsSeek(xFilial()+cCO)
	PmsNewRec("AK3")
	AK3->AK3_FILIAL := xFilial("AK3")
	AK3->AK3_ORCAME	:= cOrcame
	AK3->AK3_VERSAO	:= cVersao
	AK3->AK3_CO			:= cCO
	AK3->AK3_PAI		:= If(Empty(AK5->AK5_COSUP),cOrcame,AK5->AK5_COSUP)
	AK3->AK3_TIPO		:= AK5->AK5_TIPO
	AK3->AK3_DESCRI	:= AK5->AK5_DESCRI
	MsUnlock()
	aAdd(aRecAK3,AK3->(RecNo()))
	dbSelectArea("AK3")
	dbSetOrder(1)
	If !Empty(AK5->AK5_COSUP)
		If !dbSeek(xFilial('AK3')+cOrcame+cVersao+AK5->AK5_COSUP)
			GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK5->AK5_COSUP,aRecAK3,@cNivel)
		Else
			cNivel := AK3->AK3_NIVEL
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return

Function PcoAK2SldC(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny

For nY := 1 to Len(aPeriodGet)
	nSldIni := 0
	
   // PROCESSA CUBO SALDO INICIAL 
	dIni := aPeriodGet[nY,1]
	aRetIni := PcoRetSld(cConfig,cChave,dIni)
	nCrdIni := aRetIni[1, If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))]
	nDebIni := aRetIni[2, If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))]
	nSldIni := nCrdIni-nDebIni
   
   	// PROCESSA CUBO SALDO FINAL
	dFim := aPeriodGet[nY,2]
	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))]
	nDebFim := aRetFim[2, If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))]

	nSldFim := nCrdFim-nDebFim

	//retorna saldo final - saldo inicial
	aAdd(aRetorno,nSldFim-nSldIni)
Next

Return aRetorno


Static Function GravaAK2(aPeriodProc,aProcessa,aNiveis,cPlanilha,cVersao,aCampos)
Local nX	:=	0
Local nY	:=	0
Local nT	:=	0
Local cItem	:=	""
Local cNivel:= "001"
Local aRecAK3:={}
Procregua(Len(aPeriodProc)*Len(aProcessa))
For nx := 1 to Len(aPeriodProc)
	For ny := 1 to Len(aProcessa)         
		IncProc()
		If aProcessa[ny,8] == aNiveis[Len(aNiveis)]
			dbSelectArea("AK2") 
			dbSetOrder(1)
			dbSeek(xFilial()+cPlanilha+cVersao+Substr(aProcessa[ny,9],aCampos[nPosConta,2],aCampos[nPosConta,3])+DTOS(CTOD(Substr(aPeriodProc[nx],1,10)))+"ZZZZ",.T.)
			dbSkip(-1)
			If xFilial("AK2")+cPlanilha+cVersao+Substr(aProcessa[ny,9],aCampos[nPosConta,2],aCampos[nPosConta,3])+DTOS(CTOD(Substr(aPeriodProc[nx],1,10)))==;
				AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)
				cItem := Soma1(AK2->AK2_ID)
			Else
				cItem := "0001"
			EndIf
			RecLock("AK2",.T.)
			For nz := 1 to Len(aCampos)
				If FieldPos(aCampos[nz,1])>0
					FieldPut(FieldPos(aCampos[nz,1]),Substr(aProcessa[nY,9],aCampos[nz,2],aCampos[nz,3]))
				EndIf
			Next
			AK2->AK2_FILIAL := xFilial("AK2")
			AK2->AK2_ORCAME := cPlanilha
			AK2->AK2_VERSAO := cVersao
			AK2->AK2_MOEDA	:= If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
			AK2->AK2_PERIOD	:= CTOD(Substr(aPeriodProc[nx],1,10))
			AK2->AK2_DATAI	:= CTOD(Substr(aPeriodProc[nx],1,10))
			AK2->AK2_DATAF	:= CTOD(Substr(aPeriodProc[nx],14,16))
			AK2->AK2_ID		:= cItem
			AK2->AK2_VALOR	:= Abs(aProcessa[nY,2,nX])					
//Inicio especifico MS
			If (aProcessa[nY,2,nX]) > 0
				AK2->AK2_OPER := '1'
				AK2->AK2_VALOR:= Abs(aProcessa[nY,2,nX])					
			Else                      
				If aConfig[4] == 1
					AK2->AK2_OPER := '2'
					AK2->AK2_VALOR:= Abs(aProcessa[nY,2,nX])					
				Else
					AK2->AK2_OPER := '1'
					AK2->AK2_VALOR:= aProcessa[nY,2,nX]
				Endif
			Endif
       				AK2->AK2_CLASSE :=	"000001"
//Fim especifico MS
			MsUnlock() 


			dbSelectArea("AK3")
			dbSetOrder(1)
			If !dbSeek(xFilial('AK3')+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO)
				cNivel := "001"
				GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK2->AK2_CO,aRecAK3,@cNivel)
				For nt := Len(aRecAK3) to 1 Step -1
					cNivel := Soma1(cNivel)
					AK3->(dbGoto(aRecAK3[nt]))
					RecLock("AK3",.F.)
						AK3->AK3_NIVEL := cNivel
					MsUnlock()
				Next nt
			EndIf
			dbSelectArea("AK2")
			If lSimulac
				PcoDetLan("000252","03","PCOA100")
			ElseIf lRevisao
				PcoDetLan("000252","02","PCOA100")
			Else
				PcoDetLan("000252","01","PCOA100")
			EndIf
		EndIf
	Next
Next
