#Include "VEIVR080.CH"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVR080 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 11/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Resumo das Vendas de Veiculos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Luis - Inclusao de relatorio para FATDIR - 03/03/04        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR080

Local cDesc1	 := STR0001
Local cDesc2	 := ""                
Local cDesc3	 := ""
Local cAlias	 := "VV0"                        
Private nLin 	 := 1
Private aReturn := { STR0056, 1,STR0057, 2, 2, 1, "",1 } //Zebrado # Administracao
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0001
Private cNomProg:= "VEIVR080"
Private cNomeRel:= "VEIVR080"
Private nLastKey:= 0                       
Private cPerg   := "VER080"
Private nTotNNov := 0
Private nTotNUsa := 0
Private nTotINov := 0
Private nTotIUsa := 0
Private aResumo  := {}
Private aResAgr  := {}
Private nPerc    := 0 
cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
	Return
EndIf     

PERGUNTE("VER080",.f.)

SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| ImpVR080(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpVR080  ºAutor  ³Andre Luis Almeida  º Data ³  11/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Resumo das Vendas de Veiculos                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpVR080(lEnd,wNRel,cAlias)

Local ni
Local cFAZER , cPrimVez , nTotFisN := 0 , nTotFisU := 0 , nTotTraN := 0 , nTotTraU := 0 , nTotSVda := 0
Local nVfattot :=0 , nVtotimp:=0 , nVtotcus:=0 , nVjurest:=0 , nVlucbru:=0 , nVtotdes:=0 , nVluclq1:=0 , nVdesfix:=0 , nVluclq2:=0
Local aTotal   := {} //vetor Total dos Veiculos
Local aTotCon  := {} //vetor Total dos Veiculos por Condicao de Pagamento
Local aTotVei  := {} //vetor Total dos Veiculos Nacionais/Importados Novos/Usados 
Local aGrpVei  := {} //vetor Total dos Veiculos por Modelo
Local aNumVei  := {} //vetor dos Veiculos
Local aEstoque := {} //vetor de Estoques
Private nLin   := 1 , nCont := 0 , nPos := 0 , nPos2 := 0
Private cTitulo , cabec1 , cabec2 , nomeprog , tamanho , nCaracter , cCabTot , cMudou1 , cMudou2 , cMudou3 , cTipo
Private cbTxt   	:= Space(10)
Private cbCont  	:= 0
Private cString 	:= "VV0"
Private Li      	:= 220
Private m_Pag   	:= 1
Private lAbortPrint := .f.  
Private cSitVei 	:= ""

If MV_PAR09 == 1 // Estoque Outros considera (SITVEI == "2" - Em Transito)
	cSitVei += "2/"
EndIf
If MV_PAR10 == 1 // Estoque Outros considera (SITVEI == "3" - Remessa)
	cSitVei += "3/"
EndIf
If MV_PAR11 == 1 // Estoque Outros considera (SITVEI == "4" - Consignado)
	cSitVei += "4/"
EndIf
If MV_PAR12 == 1 // Estoque Outros considera (SITVEI == "5" - Transferido)
	cSitVei += "5/"
EndIf
If MV_PAR13 == 1 // Estoque Outros considera (SITVEI == "6" - Reservado)
	cSitVei += "6/"
EndIf

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

cTitulo:= STR0015 + Transform(MV_PAR01,"@D") + STR0016 + Transform(MV_PAR02,"@D") 
cabec1 := ""
cabec2 := ""
nomeprog:="VEIVR080"
tamanho:="G"
nCaracter:=15
cCabTot := STR0002

nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      

aTotal  := {} //zera vetor de Totais
aAdd(aTotal,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) 

DbSelectArea( "VV0" )
DbSetOrder(2)
DbSeek( xFilial("VV0") + "0" + Dtos(MV_PAR01) , .t. )

SetRegua( RecCount() )       

While !Eof() .and. VV0->VV0_FILIAL == xFilial("VV0") .and. (Empty(MV_PAR02) .or. (VV0->VV0_DATMOV <= MV_PAR02)) .and. VV0->VV0_OPEMOV == "0"
	IncRegua()
	If lAbortPrint
		nLin++
		@nLin++,30 PSAY STR0009 //* * *  C A N C E L A D O   P E L O   O P E R A D O R  * * *
		Exit
	EndIf
	If (!Empty(MV_PAR01) .and. (VV0->VV0_DATMOV < MV_PAR01) .or. (VV0->VV0_TIPFAT=="2" .and. !Empty(VV0->VV0_NUMNFI)))
		DbSelectArea("VV0")
		Dbskip()
		loop
	EndIf  

 	DbSelectArea( "VVA" )
	DbSetOrder(1)
	DbSeek( xFilial("VVA") + VV0->VV0_NUMTRA )    

 	DbSelectArea( "SF4" )
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + VVA->VVA_CODTES )    

	If ((Alltrim(SF4->F4_DUPLIC) == "N" .or. Alltrim(SF4->F4_ATUATF) == "S") .and. !(Empty(VV0->VV0_NUMNFI)))
		DbSelectArea("VV0")
		Dbskip()
		loop
	EndIf

   nVfattot := If( MV_PAR03 == 1 , VVA->VVA_FATTOT , If( MV_PAR03 == 2 , VVA->VVA_FMFTOT , xmoeda(VVA->VVA_FATTOT,1,MV_PAR03,DDataBase)))
  	nVtotimp := If( MV_PAR03 == 1 , VVA->VVA_TOTIMP , If( MV_PAR03 == 2 , VVA->VVA_TMFIMP , xmoeda(VVA->VVA_TOTIMP,1,MV_PAR03,DDataBase)))
   nVtotcus := If( MV_PAR03 == 1 , VVA->VVA_TOTCUS , If( MV_PAR03 == 2 , VVA->VVA_TMFCUS , xmoeda(VVA->VVA_TOTCUS,1,MV_PAR03,DDataBase)))
   nVjurest := If( MV_PAR03 == 1 , VVA->VVA_JUREST , If( MV_PAR03 == 2 , VVA->VVA_JMFEST , xmoeda(VVA->VVA_JUREST,1,MV_PAR03,DDataBase)))
  	nVtotcus := (nVtotcus - nVjurest)
	nVlucbru := If( MV_PAR03 == 1 , VVA->VVA_LUCBRU , If( MV_PAR03 == 2 , VVA->VVA_LMFBRU , xmoeda(VVA->VVA_LUCBRU,1,MV_PAR03,DDataBase)))
   nVtotdes := If( MV_PAR03 == 1 , VVA->VVA_TOTDES , If( MV_PAR03 == 2 , VVA->VVA_TMFDES , xmoeda(VVA->VVA_TOTDES,1,MV_PAR03,DDataBase)))
   nVluclq1 := If( MV_PAR03 == 1 , VVA->VVA_LUCLQ1 , If( MV_PAR03 == 2 , VVA->VVA_LMFLQ1 , xmoeda(VVA->VVA_LUCLQ1,1,MV_PAR03,DDataBase)))
   nVdesfix := If( MV_PAR03 == 1 , VVA->VVA_DESFIX , If( MV_PAR03 == 2 , VVA->VVA_DMFFIX , xmoeda(VVA->VVA_DESFIX,1,MV_PAR03,DDataBase)))
   nVluclq2 := If( MV_PAR03 == 1 , VVA->VVA_LUCLQ2 , If( MV_PAR03 == 2 , VVA->VVA_LMFLQ2 , xmoeda(VVA->VVA_LUCLQ2,1,MV_PAR03,DDataBase)))

 	DbSelectArea( "VV1" )
	DbSetOrder(2)
	DbSeek( xFilial("VV1") + VVA->VVA_CHASSI )    

	DbSelectArea("VV2") 
	DbSetOrder(1)
	DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

	DbSelectArea( "SF2" )
	DbSetOrder(1)
	DbSeek( xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )

	DbSelectArea( "SA1" )
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )

	If MV_PAR06 == 1 .or. Alltrim(VV1->VV1_ESTVEI) == Alltrim(str(MV_PAR06-2))

		If (Empty(Alltrim(VV0->VV0_NUMNFI + VV0->VV0_SERNFI)) .and. VV0->VV0_AUTFAT == "1")
	  		If Alltrim(VV1->VV1_ESTVEI) == "0"         		// Novos
				aAdd(aNumVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , VVA->VVA_CHASSI , "x" , " " , " " , " " , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , "" , STR0018 , VV1->VV1_CODMAR + VV1->VV1_MODVEI , VV0->VV0_CATVEN }) 
	  		Else                                     		// Usados
				aAdd(aNumVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , VVA->VVA_CHASSI , " " , " " , "x" , " " , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , "" , STR0018 , VV1->VV1_CODMAR + VV1->VV1_MODVEI , VV0->VV0_CATVEN }) 
			EndIf
      Else     
			If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					aAdd(aNumVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , VVA->VVA_CHASSI , "x" , " " , " " , " " , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , SF2->F2_EMISSAO , SF2->F2_DOC + If(!Empty(SF2->F2_SERIE),"-" + SF2->F2_SERIE + " " + left(SA1->A1_NOME,13), " " + left(SA1->A1_NOME,17)) , VV1->VV1_CODMAR + VV1->VV1_MODVEI , VV0->VV0_CATVEN }) 
	  			Else                                     	// Usados
					aAdd(aNumVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , VVA->VVA_CHASSI , " " , " " , "x" , " " , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , SF2->F2_EMISSAO , SF2->F2_DOC + If(!Empty(SF2->F2_SERIE),"-" + SF2->F2_SERIE + " " + left(SA1->A1_NOME,13), " " + left(SA1->A1_NOME,17)) , VV1->VV1_CODMAR + VV1->VV1_MODVEI , VV0->VV0_CATVEN }) 
				EndIf
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      // Novos
					aAdd(aNumVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , VVA->VVA_CHASSI , " " , "x" , " " , " " , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , SF2->F2_EMISSAO , SF2->F2_DOC + If(!Empty(SF2->F2_SERIE),"-" + SF2->F2_SERIE + " " + left(SA1->A1_NOME,13), " " + left(SA1->A1_NOME,17)) , VV1->VV1_CODMAR + VV1->VV1_MODVEI , VV0->VV0_CATVEN }) 
	  			Else                                     // Usados
					aAdd(aNumVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , VVA->VVA_CHASSI , " " , " " , " " , "x" , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , SF2->F2_EMISSAO , SF2->F2_DOC + If(!Empty(SF2->F2_SERIE),"-" + SF2->F2_SERIE + " " + left(SA1->A1_NOME,13), " " + left(SA1->A1_NOME,17)) , VV1->VV1_CODMAR + VV1->VV1_MODVEI , VV0->VV0_CATVEN }) 
				EndIf
			EndIf                                           
		EndIf
		
	   nPos := 0
		nPos := aScan(aGrpVei,{|x| x[1] + x[2] + x[3] + x[4] ==  If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") + Alltrim(VV1->VV1_PROVEI) + Alltrim(VV1->VV1_ESTVEI) + VV2->VV2_DESMOD })
		If nPos == 0
	  		If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
	  				aAdd(aGrpVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , 1 , 0 , 0 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI })
	  			Else                                     	// Usados
	  				aAdd(aGrpVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , 0 , 0 , 1 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI })
	  			EndIf	  			
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					aAdd(aGrpVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , 0 , 1 , 0 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI })
	  			Else                                     	// Usados
					aAdd(aGrpVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , 0 , 0 , 0 , 1 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI })
	  			EndIf	  			
			EndIf
		Else
	  		If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					aGrpVei[nPos,5]++
	  			Else                                     	// Usados
					aGrpVei[nPos,7]++
	  			EndIf
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					aGrpVei[nPos,6]++
	  			Else                                     	// Usados
					aGrpVei[nPos,8]++
	  			EndIf
	      EndIf
		 	aGrpVei[nPos,9] += nVfattot
		 	aGrpVei[nPos,10]+= nVtotimp
		 	aGrpVei[nPos,11]+= nVtotcus
		 	aGrpVei[nPos,12]+= nVlucbru
		 	aGrpVei[nPos,13]+= nVtotdes
		 	aGrpVei[nPos,14]+= nVluclq1
		 	aGrpVei[nPos,15]+= nVdesfix
		 	aGrpVei[nPos,16]+= nVluclq2
		EndIf
	
	   nPos := 0
		nPos := aScan(aTotVei,{|x| x[1] + x[2] + x[3] ==  If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") + Alltrim(VV1->VV1_PROVEI) + Alltrim(VV1->VV1_ESTVEI) })
		If nPos == 0
	  		If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aAdd(aTotVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , 1 , 0 , 0 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
		 		Else                                     		// Usados
					aAdd(aTotVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , 0 , 0 , 1 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			EndIf	  			
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aAdd(aTotVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , 0 , 1 , 0 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			Else                                     		// Usados
					aAdd(aTotVei,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , 0 , 0 , 0 , 1 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			EndIf	  			
			EndIf
		Else
	  		If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aTotVei[nPos,4]++
	  			Else                                     		// Usados
					aTotVei[nPos,6]++
	  			EndIf	  			
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aTotVei[nPos,5]++
	  			Else                                     		// Usados
					aTotVei[nPos,7]++
	  			EndIf	  			
	      EndIf                                           
		 	aTotVei[nPos,8] += nVfattot
		 	aTotVei[nPos,9] += nVtotimp
		 	aTotVei[nPos,10]+= nVtotcus
		 	aTotVei[nPos,11]+= nVlucbru
		 	aTotVei[nPos,12]+= nVtotdes
		 	aTotVei[nPos,13]+= nVluclq1
		 	aTotVei[nPos,14]+= nVdesfix
		 	aTotVei[nPos,15]+= nVluclq2
		EndIf
	
	   nPos := 0
		nPos := aScan(aTotCon,{|x| x[1] ==  If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") })
		If nPos == 0
			DbSelectArea( "SE4" )
			DbSetOrder(1)
			DbSeek( xFilial("SE4") + SF2->F2_COND )
	  		If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aAdd(aTotCon,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , SE4->E4_DESCRI , 1 , 0 , 0 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			Else                                     		// Usados
					aAdd(aTotCon,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , SE4->E4_DESCRI , 0 , 0 , 1 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			EndIf	  			
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aAdd(aTotCon,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , SE4->E4_DESCRI , 0 , 1 , 0 , 0 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			Else                                     		// Usados
					aAdd(aTotCon,{ If(MV_PAR05 == 1 .or. Empty(SF2->F2_COND),If(Empty(SF2->F2_COND),if(Empty(VV0->VV0_NUMNFI),"ZZZ","ZXZ"),SF2->F2_COND),"WXZ") , SE4->E4_DESCRI , 0 , 0 , 0 , 1 , nVfattot , nVtotimp , nVtotcus , nVlucbru , nVtotdes , nVluclq1 , nVdesfix , nVluclq2 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
	  			EndIf	  			
	 		EndIf
		Else
	  		If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aTotCon[nPos,3]++
	  			Else                                     		// Usados
					aTotCon[nPos,5]++
	  			EndIf	  			
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aTotCon[nPos,4]++
	  			Else                                     		// Usados
					aTotCon[nPos,6]++
	  			EndIf	  			
	      EndIf                                           
		 	aTotCon[nPos,7] += nVfattot
		 	aTotCon[nPos,8] += nVtotimp
		 	aTotCon[nPos,9] += nVtotcus
		 	aTotCon[nPos,10]+= nVlucbru
		 	aTotCon[nPos,11]+= nVtotdes
		 	aTotCon[nPos,12]+= nVluclq1
		 	aTotCon[nPos,13]+= nVdesfix
		 	aTotCon[nPos,14]+= nVluclq2
		EndIf
	
		If !Empty(Alltrim(VV0->VV0_NUMNFI + VV0->VV0_SERNFI))
			If (Len(Alltrim(SA1->A1_CGC)) # 14)    //  -->   Fisica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aTotal[1,1]++
	  			Else                                     		// Usados
					aTotal[1,3]++
	  			EndIf	  			
			Else //(Len(Alltrim(SA1->A1_CGC)) == 14) //  -->   Juridica
	  			If Alltrim(VV1->VV1_ESTVEI) == "0"      		// Novos
					aTotal[1,2]++
	  			Else                                     		// Usados
					aTotal[1,4]++
	  			EndIf	  			
			EndIf
			aTotal[1,5] += nVfattot
		 	aTotal[1,6] += nVtotimp
		 	aTotal[1,7] += nVtotcus
	 		aTotal[1,8] += nVlucbru
		 	aTotal[1,9] += nVtotdes
		 	aTotal[1,10]+= nVluclq1
	 		aTotal[1,11]+= nVdesfix
		 	aTotal[1,12]+= nVluclq2
		EndIf                                           

	EndIf                                           
		
	DbSelectArea("VV0")
	Dbskip()
	
EndDo


DbSelectArea( "VV1" )
DbSetOrder(1)
DbSeek( xFilial("VV1") )

nTotFisN := 0
nTotFisU := 0
nTotTraN := 0
nTotTraU := 0

nTotFis10:= 0
nTotFis20:= 0
nTotFis11:= 0
nTotFis21:= 0
nTotTra10:= 0
nTotTra20:= 0
nTotTra11:= 0
nTotTra21:= 0

nTotSVda := 0

While !Eof() .and. VV1->VV1_FILIAL == xFilial("VV1")
	cFAZER := "SIM"
	
	If (Alltrim(VV1->VV1_CHASSI) # "1") // SO PARA ORCAMENTOS

		nPos := aScan(aEstoque,{|x| x[1] + x[2] == VV1->VV1_CODMAR + VV1->VV1_MODVEI })
		If nPos == 0
			If Alltrim(VV1->VV1_SITVEI) == "0" .and. MV_PAR08 == 1 	// Estoque Fisico
  				If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
  					aAdd(aEstoque,{ VV1->VV1_CODMAR , VV1->VV1_MODVEI , 1 , 0 , 0 , 0  }) 
  				Else                                     	// Usados
  					aAdd(aEstoque,{ VV1->VV1_CODMAR , VV1->VV1_MODVEI , 0 , 0 , 1 , 0  }) 
  				EndIf	  			
			EndIf
			If Alltrim(VV1->VV1_SITVEI)$cSitVei	 					// Estoque Outros
  				If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
  					aAdd(aEstoque,{ VV1->VV1_CODMAR , VV1->VV1_MODVEI , 0 , 1 , 0 , 0  }) 
  				Else                                     	// Usados
  					aAdd(aEstoque,{ VV1->VV1_CODMAR , VV1->VV1_MODVEI , 0 , 0 , 0 , 1  }) 
  				EndIf	  			
			EndIf	  			
		Else
			If Alltrim(VV1->VV1_SITVEI) == "0" .and. MV_PAR08 == 1 	// Estoque Fisico
  				If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					aEstoque[nPos,3]++
  				Else                                     	// Usados
					aEstoque[nPos,5]++
  				EndIf	  			
			ElseIf Alltrim(VV1->VV1_SITVEI)$cSitVei	// Estoque Outros
  				If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					aEstoque[nPos,4]++
  				Else                                     	// Usados
					aEstoque[nPos,6]++
  				EndIf	  			
			EndIf	  			
		EndIf
	
	  If ((Alltrim(VV1->VV1_SITVEI) == "0" .and. MV_PAR08 == 1 	)	.or. Alltrim(VV1->VV1_SITVEI)$cSitVei)
	
			nPos := aScan(aGrpVei,{|x| x[17] == VV1->VV1_CODMAR + VV1->VV1_MODVEI })
			If nPos == 0
				DbSelectArea("VV2") 
				DbSetOrder(1)
				DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
				aAdd(aGrpVei,{ "YXZ" , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , VV1->VV1_CODMAR + VV1->VV1_MODVEI }) 
				aAdd(aNumVei,{ "YXZ" , Alltrim(VV1->VV1_PROVEI) , Alltrim(VV1->VV1_ESTVEI) , VV2->VV2_DESMOD , "NAO_EXISTE" , " " , " " , " " , " " , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "" , "" , VV1->VV1_CODMAR + VV1->VV1_MODVEI , "" }) 
				nTotSVda++  
	   	EndIf

			If Alltrim(VV1->VV1_SITVEI) == "0" .and. MV_PAR08 == 1 	// Estoque Fisico
				If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					nTotFisN++ 
					If Alltrim(VV1->VV1_PROVEI) == "1"
						nTotFis10++ 
					Else
						nTotFis20++ 
					EndIf
				Else                                     	// Usados
					nTotFisU++
					If Alltrim(VV1->VV1_PROVEI) == "1"
						nTotFis11++ 
					Else
						nTotFis21++ 
					EndIf
			 	EndIf	  			
			EndIf
			If Alltrim(VV1->VV1_SITVEI)$cSitVei	// Estoque Fiscal
				If Alltrim(VV1->VV1_ESTVEI) == "0"      	// Novos
					nTotTraN++ 
					If Alltrim(VV1->VV1_PROVEI) == "1"
						nTotTra10++ 
					Else
						nTotTra20++ 
					EndIf
				Else                                     	// Usados
					nTotTraU++
					If Alltrim(VV1->VV1_PROVEI) == "1"
						nTotTra11++ 
					Else
						nTotTra21++ 
					EndIf
			  	EndIf	  			
			EndIf

		EndIf

	EndIf

	DbSelectArea("VV1")
	Dbskip()
EndDo


	///////////////////////////////////////////////////////////
	//                                                       //
	//          I   M   P   R   E   S   S   A   O            //
	//                                                       //
	///////////////////////////////////////////////////////////

nLin++
@ nLin++ , 00 psay Repl("*",220)
@ nLin++ , 00 psay STR0010 + STR0013 
@ nLin++ , 00 psay STR0014 + cCabTot
@ nLin++ , 00 psay STR0011 + Transform(aTotal[1,1] ,"@E 9999") + Transform(aTotal[1,2],"@E 9999") + Transform(aTotal[1,3] ,"@E 9999") + Transform(aTotal[1,4],"@E 9999") ;
						+ Transform(aTotal[1,5] ,"@E 9999999,999.99") ;
						+ Transform(aTotal[1,6] ,"@E 9999,999.99")  + Transform(((aTotal[1,6]/aTotal[1,5])*100) ,"@E 999.9") ;
						+ Transform(aTotal[1,7] ,"@E 999999,999.99")+ Transform(((aTotal[1,7]/aTotal[1,5])*100) ,"@E 999.9") ;
						+ Transform(aTotal[1,8] ,"@E 99999,999.99") + Transform(((aTotal[1,8]/aTotal[1,5])*100) ,"@E 999.9") ;
						+ Transform(aTotal[1,9] ,"@E 999,999.99")   + Transform(((aTotal[1,9]/aTotal[1,5])*100) ,"@E 99.9") ;
						+ Transform(aTotal[1,10],"@E 99999,999.99") + Transform(((aTotal[1,10]/aTotal[1,5])*100),"@E 999.9") ;
						+ Transform(aTotal[1,11],"@E 999999.99")    + Transform(((aTotal[1,11]/aTotal[1,5])*100),"@E 99.9") ;
						+ Transform(aTotal[1,12],"@E 99999,999.99") + Transform(((aTotal[1,12]/aTotal[1,5])*100),"@E 999.9") + " " ;
						+ Transform(nTotFisN,"@E 99999") + Transform(nTotTraN,"@E 9999") + Transform(nTotFisN+nTotTraN,"@E 9999") ;
						+ Transform(nTotFisU,"@E 99999") + Transform(nTotTraU,"@E 9999") + Transform(nTotFisU+nTotTraU,"@E 9999") ;
						+ Transform( nTotFisN + nTotTraN + nTotFisU + nTotTraU ,"@E 9999999") 
@ nLin++ , 00 psay Repl("*",220) 

cMudou1 := "INICIAL"
cMudou2 := "INICIAL"
cMudou3 := "INICIAL"
cCatVen := "INICIAL"
cCategV := "INICIAL"
cPrimVez:= "SIM"
cCategVen := ""
If MV_PAR05 == 1
	aSort(aNumVei,1,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5]})
Else
	aSort(aNumVei,1,,{|x,y| x[1]+x[3]+x[2]+x[4]+x[5] < y[1]+y[3]+y[2]+y[4]+y[5]})
EndIf

For ni:=1 to Len(aNumVei) 
	cFAZER := "SIM"
	If lAbortPrint
		nLin++
		@nLin++,30 PSAY STR0009 //"* * *  C A N C E L A D O   P E L O   O P E R A D O R  * * *"
		Exit
	EndIf

	If Alltrim(aNumVei[ni,5]) == "NAO_EXISTE" .and. cPrimVez == "SIM"
		cPrimVez := "NAO"
  		nLin++
  		nLin++
  		@ nLin++ , 00 psay Repl("*",220) 
  		nLin++
		nLin++
		@ nLin++ , 00 psay STR0017 + Transform(nTotSVda,"@E 999999")
	EndIf
	
	If MV_PAR07 == 1 .or. aNumVei[ni,1] # "ZXZ"

		If cMudou1 # aNumVei[ni,1] .and. aNumVei[ni,1] # "WXZ"
			cMudou1 := aNumVei[ni,1]
			nLin++ 
			cCond := ""
			nPos := aScan(aTotCon,{|x| x[1] == cMudou1 })
			If nPos > 0
				If nLin >= 51
   		 		nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
					@ nLin++ , 24 psay STR0013 
					@ nLin++ , 24 psay cCabTot
		   	 	nLin++ 
				EndIf  
	   	 	nLin++
	   	 	If Alltrim(aTotCon[nPos,1]) == "ZXZ" .or. Alltrim(aTotCon[nPos,1]) == "ZZZ"
	    			@ nLin++ , 00 psay Repl("*",220) 
		    		nLin++
	    			nLin++
	    			if Alltrim(aTotCon[nPos,1]) == "ZXZ"
			    		cCond := STR0012
			    	else
		    	   	cCond := STR0031
		    	   endif
			    	
				Else
					cCond := aTotCon[nPos,1] + " " + left(aTotCon[nPos,2],19)
				EndIf
				@ nLin++ , 00 psay cCond ;
						+ Transform(aTotCon[nPos,3] ,"@E 9999") + Transform(aTotCon[nPos,4],"@E 9999") + Transform(aTotCon[nPos,5] ,"@E 9999") + Transform(aTotCon[nPos,6],"@E 9999") ;
						+ Transform(aTotCon[nPos,7] ,"@E 9999999,999.99") ;
						+ Transform(aTotCon[nPos,8] ,"@E 9999,999.99")  + Transform(((aTotCon[nPos,8]/aTotCon[nPos,7]) *100),"@E 999.9") ;
						+ Transform(aTotCon[nPos,9] ,"@E 999999,999.99")+ Transform(((aTotCon[nPos,9]/aTotCon[nPos,7]) *100),"@E 999.9") ;
						+ Transform(aTotCon[nPos,10],"@E 99999,999.99") + Transform(((aTotCon[nPos,10]/aTotCon[nPos,7])*100),"@E 999.9") ;
						+ Transform(aTotCon[nPos,11],"@E 999,999.99")   + Transform(((aTotCon[nPos,11]/aTotCon[nPos,7])*100),"@E 99.9") ;
						+ Transform(aTotCon[nPos,12],"@E 99999,999.99") + Transform(((aTotCon[nPos,12]/aTotCon[nPos,7])*100),"@E 999.9") ;
						+ Transform(aTotCon[nPos,13],"@E 999999.99")    + Transform(((aTotCon[nPos,13]/aTotCon[nPos,7])*100),"@E 99.9") ;
						+ Transform(aTotCon[nPos,14],"@E 99999,999.99") + Transform(((aTotCon[nPos,14]/aTotCon[nPos,7])*100),"@E 999.9")
			EndIf
  		EndIf     
   
	  	If MV_PAR04 >= 2
			If MV_PAR05 == 1
			   cQuebra := aNumVei[ni,1]+aNumVei[ni,2]+aNumVei[ni,3]
			Else
			   cQuebra := aNumVei[ni,1]+aNumVei[ni,3]+aNumVei[ni,2]
			EndIf
			If cMudou2 # cQuebra
				cMudou2 := cQuebra
				If MV_PAR05 == 1
					nPos  := aScan(aTotVei,{|x| x[1]+x[2]+x[3] == cMudou2 })
				Else
					nPos  := aScan(aTotVei,{|x| x[1]+x[3]+x[2] == cMudou2 })
				EndIf
				cTipo := ""
				If nPos > 0
					If aNumVei[ni,2] == "1" .and. aNumVei[ni,3] == "0"  		// Nacional Novo
					   cTipo := STR0004
					ElseIf  aNumVei[ni,2] == "1" .and. aNumVei[ni,3] == "1" 	// Nacional Usado
				  		cTipo := STR0005
					ElseIf  aNumVei[ni,2] == "2" .and. aNumVei[ni,3] == "0" 	// Importado Novo
						cTipo := STR0006
					ElseIf  aNumVei[ni,2] == "2" .and. aNumVei[ni,3] == "1"		// Importado Usado
						cTipo := STR0007
					Else
						cTipo := STR0008
					EndIf    
					If nLin >= 54
		  	 			nLin := 1
						nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
						@ nLin++ , 24 psay STR0013 
						@ nLin++ , 24 psay cCabTot
		   		 	nLin++ 
					EndIf  
		    		nLin++ 
					@ nLin++ , 02 psay cTipo ;
						+ Transform(aTotVei[nPos,4] ,"@E 9999") + Transform(aTotVei[nPos,5],"@E 9999") + Transform(aTotVei[nPos,6] ,"@E 9999") + Transform(aTotVei[nPos,7],"@E 9999")  ;
						+ Transform(aTotVei[nPos,8] ,"@E 9999999,999.99") ;
						+ Transform(aTotVei[nPos,9] ,"@E 9999,999.99")  + Transform(((aTotVei[nPos,9]/aTotVei[nPos,8]) *100),"@E 999.9") ;
						+ Transform(aTotVei[nPos,10],"@E 999999,999.99")+ Transform(((aTotVei[nPos,10]/aTotVei[nPos,8])*100),"@E 999.9") ;
						+ Transform(aTotVei[nPos,11],"@E 99999,999.99") + Transform(((aTotVei[nPos,11]/aTotVei[nPos,8])*100),"@E 999.9") ;
						+ Transform(aTotVei[nPos,12],"@E 999,999.99")   + Transform(((aTotVei[nPos,12]/aTotVei[nPos,8])*100),"@E 99.9") ;
						+ Transform(aTotVei[nPos,13],"@E 99999,999.99") + Transform(((aTotVei[nPos,13]/aTotVei[nPos,8])*100),"@E 999.9") ;
						+ Transform(aTotVei[nPos,14],"@E 999999.99")    + Transform(((aTotVei[nPos,14]/aTotVei[nPos,8])*100),"@E 99.9") ;
						+ Transform(aTotVei[nPos,15],"@E 99999,999.99") + Transform(((aTotVei[nPos,15]/aTotVei[nPos,8])*100),"@E 999.9") + " " ;
						+ If(( MV_PAR04 >= 2 .and. !aNumVei[ni,1]$"ZXZ|YXZ" ),Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotFis10,nTotFis20),"@E 99999");
							+ Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotTra10,nTotTra20),"@E 9999");
							+ Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotFis10+nTotTra10,nTotFis20+nTotTra20),"@E 9999");
							+ Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotFis11,nTotFis21),"@E 99999");
							+ Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotTra11,nTotTra21),"@E 9999");
							+ Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotFis11+nTotTra11,nTotFis21+nTotTra21),"@E 9999");
							+ Transform( If(Alltrim(aNumVei[ni,2])=="1",nTotFis10+nTotTra10+nTotFis11+nTotTra11,nTotFis20+nTotTra20+nTotFis21+nTotTra21),"@E 9999999"),"")
				EndIf
 			EndIf     
			If MV_PAR05 == 1
			   cQuebra := aNumVei[ni,1]+aNumVei[ni,2]+aNumVei[ni,3]+aNumVei[ni,4]
			Else
			   cQuebra := aNumVei[ni,1]+aNumVei[ni,3]+aNumVei[ni,2]+aNumVei[ni,4]
			EndIf
			If cMudou3 # cQuebra
				cMudou3 := cQuebra
				If MV_PAR05 == 1
					nPos := aScan(aGrpVei,{|x| x[1]+x[2]+x[3]+x[4] == cMudou3 })
				Else
					nPos := aScan(aGrpVei,{|x| x[1]+x[3]+x[2]+x[4] == cMudou3 })
				EndIf
				If nPos > 0
					If nLin >= 57
   			 		nLin := 1
						nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
						@ nLin++ , 24 psay STR0013 
						@ nLin++ , 24 psay cCabTot
		    			nLin++ 
					EndIf 	 
					
					nPos2 := 0
					nPos2 := aScan(aEstoque,{|x| x[1] + x[2] == aGrpVei[nPos,17] })

					If MV_PAR04 == 3 .and. aNumVei[ni,1] # "YXZ"
				    	nLin++          
		   	 	EndIf
		   	 	
					@ nLin++ , 04 psay left(aGrpVei[nPos,4],19) ;
						+ Transform(aGrpVei[nPos,5] ,"@E 9999") + Transform(aGrpVei[nPos,6],"@E 9999") + Transform(aGrpVei[nPos,7] ,"@E 9999") + Transform(aGrpVei[nPos,8],"@E 9999") ;
						+ Transform(aGrpVei[nPos,9] ,"@E 9999999,999.99") ;
						+ Transform(aGrpVei[nPos,10],"@E 9999,999.99")  + Transform(((aGrpVei[nPos,10]/aGrpVei[nPos,9])*100),"@E 999.9") ;
						+ Transform(aGrpVei[nPos,11],"@E 999999,999.99")+ Transform(((aGrpVei[nPos,11]/aGrpVei[nPos,9])*100),"@E 999.9") ;
						+ Transform(aGrpVei[nPos,12],"@E 99999,999.99") + Transform(((aGrpVei[nPos,12]/aGrpVei[nPos,9])*100),"@E 999.9") ;
						+ Transform(aGrpVei[nPos,13],"@E 999,999.99")   + Transform(((aGrpVei[nPos,13]/aGrpVei[nPos,9])*100),"@E 99.9") ;
						+ Transform(aGrpVei[nPos,14],"@E 99999,999.99") + Transform(((aGrpVei[nPos,14]/aGrpVei[nPos,9])*100),"@E 999.9") ;
						+ Transform(aGrpVei[nPos,15],"@E 999999.99")    + Transform(((aGrpVei[nPos,15]/aGrpVei[nPos,9])*100),"@E 99.9") ;
						+ Transform(aGrpVei[nPos,16],"@E 99999,999.99") + Transform(((aGrpVei[nPos,16]/aGrpVei[nPos,9])*100),"@E 999.9") + " " ;
						+ If((MV_PAR04 >= 2 .and. !aNumVei[ni,1]$"ZXZ"),If(nPos2#0,Transform(aEstoque[nPos2,3],"@E 99999") + Transform(aEstoque[nPos2,4],"@E 9999") ;
																									+ Transform(aEstoque[nPos2,3]+aEstoque[nPos2,4],"@E 9999") + Transform(aEstoque[nPos2,5],"@E 99999") ;
																									+ Transform(aEstoque[nPos2,6],"@E 9999") + Transform(aEstoque[nPos2,5]+aEstoque[nPos2,6],"@E 9999") ;
																									+ Transform(aEstoque[nPos2,3]+aEstoque[nPos2,4]+aEstoque[nPos2,5]+aEstoque[nPos2,6],"@E 9999999"),"    0   0   0    0   0   0      0"),"")
				EndIf
		  	EndIf
	 	EndIf     	

		If cCatVen # aNumVei[ni,21]
			cCatVen := aNumVei[ni,21]
			If aNumVei[ni,21]=="0"
				cCategVen := STR0019
			ElseIf aNumVei[ni,21]=="1"
				cCategVen := STR0020
			ElseIf aNumVei[ni,21]=="2"
				cCategVen := STR0021
			ElseIf aNumVei[ni,21]=="3"
				cCategVen := STR0022
			ElseIf aNumVei[ni,21]=="4"
				cCategVen := STR0023
			ElseIf aNumVei[ni,21]=="5"
				cCategVen := STR0024
			ElseIf aNumVei[ni,21]=="6"
				cCategVen := STR0025
			ElseIf aNumVei[ni,21]=="7"
				cCategVen := STR0026
			ElseIf aNumVei[ni,21]=="8"
				cCategVen := STR0027
			ElseIf aNumVei[ni,21]=="9"
				cCategVen := STR0028
			Else
				cCategVen := STR0029
			EndIf
		EndIf
	 	

		If MV_PAR04 == 3 .and. Alltrim(aNumVei[ni,5])#"NAO_EXISTE"
			If nLin >= 60
	    		nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
				@ nLin++ , 24 psay STR0013 
				@ nLin++ , 24 psay cCabTot
	   	 	nLin++ 
			EndIf  
			If cCatVen # aNumVei[ni,21]
				cCatVen := aNumVei[ni,21]
				If aNumVei[ni,21]=="0"
					cCategV := STR0019
				ElseIf aNumVei[ni,21]=="1"
					cCategV := STR0020
				ElseIf aNumVei[ni,21]=="2"
					cCategV := STR0021
				ElseIf aNumVei[ni,21]=="3"
					cCategV := STR0022
				ElseIf aNumVei[ni,21]=="4"
					cCategV := STR0023
				ElseIf aNumVei[ni,21]=="5"
					cCategV := STR0024
				ElseIf aNumVei[ni,21]=="6"
					cCategV := STR0025
				ElseIf aNumVei[ni,21]=="7"
					cCategV := STR0026
				ElseIf aNumVei[ni,21]=="8"
					cCategV := STR0027
				ElseIf aNumVei[ni,21]=="9"
					cCategV := STR0028
				Else
					cCategV := STR0029
				EndIf
			EndIf
		  	@ nLin++ , 06 psay left(aNumVei[ni,5],20) + aNumVei[ni,6] + "   " + aNumVei[ni,7] + "   " + aNumVei[ni,8] + "   " + aNumVei[ni,9];
 						+ Transform(aNumVei[ni,10],"@E 9999999,999.99") ;
 						+ Transform(aNumVei[ni,11],"@E 9999,999.99")  + Transform(((aNumVei[ni,11]/aNumVei[ni,10])*100),"@E 999.9") ;
 						+ Transform(aNumVei[ni,12],"@E 999999,999.99")+ Transform(((aNumVei[ni,12]/aNumVei[ni,10])*100),"@E 999.9") ;
 						+ Transform(aNumVei[ni,13],"@E 99999,999.99") + Transform(((aNumVei[ni,13]/aNumVei[ni,10])*100),"@E 999.9") ;
 						+ Transform(aNumVei[ni,14],"@E 999,999.99")   + Transform(((aNumVei[ni,14]/aNumVei[ni,10])*100),"@E 99.9") ;
 						+ Transform(aNumVei[ni,15],"@E 99999,999.99") + Transform(((aNumVei[ni,15]/aNumVei[ni,10])*100),"@E 999.9") ;
	  					+ Transform(aNumVei[ni,16],"@E 999999.99")    + Transform(((aNumVei[ni,16]/aNumVei[ni,10])*100),"@E 99.9") ;
 						+ Transform(aNumVei[ni,17],"@E 99999,999.99") + Transform(((aNumVei[ni,17]/aNumVei[ni,10])*100),"@E 999.9") ;
	 					+ If(!Empty(aNumVei[ni,18]), "  " + Transform(aNumVei[ni,18],"@D") + STR0030," ") + aNumVei[ni,19] + cCategV
		EndIf
	EndIf






////////////////Resumo/////////////////////

if Alltrim(aNumVei[ni,5]) <> "NAO_EXISTE"
   nPerc += 1
   If aNumVei[ni,2] == "1" .and. aNumVei[ni,3] == "0"  		// Nacional Novo
   	nPos4 := Ascan(aResumo,{|x| x[1] == cCategVen})
      If nPos4 == 0 
         nTotNNov := 1  
         nTotNUsa := 0
         nTotINov := 0 
         nTotIUsa := 0
   	   aadd(aResumo,{cCategVen,STR0004,nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
   	Else
      	aResumo[nPos4,3] += 1 
   	Endif
//   	nPos5 := Ascan(aResAgr,{|x| x[1]+x[3] == cCategVen+aGrpVei[nPos,4]})
   	nPos5 := Ascan(aResAgr,{|x| x[1]+x[3] == cCategVen+aNumVei[ni,4]})
      If nPos5 == 0
         nTotNNov := 1
         nTotNUsa := 0
         nTotINov := 0 
         nTotIUsa := 0
//      	aadd(aResAgr,{cCategVen,STR0004,aGrpVei[nPos,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
      	aadd(aResAgr,{cCategVen,STR0004,aNumVei[ni,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
   	Else
      	aResAgr[nPos5,4] += 1 
   	Endif
   ElseIf  aNumVei[ni,2] == "1" .and. aNumVei[ni,3] == "1" 	// Nacional Usado
   	nPos7 := Ascan(aResumo,{|x| x[1] == cCategVen})
      If nPos7 == 0 
         nTotNUsa := 1    
         nTotNNov := 0 
         nTotINov := 0 
         nTotIUsa := 0 
      	aadd(aResumo,{cCategVen,STR0005,nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
      Else
      	aResumo[nPos7,4] += 1 
	   Endif
//   	nPos8:= Ascan(aResAgr,{|x| x[1]+x[3] == cCategVen+aGrpVei[nPos,4]})
   	nPos8:= Ascan(aResAgr,{|x| x[1]+x[3] == cCategVen+aNumVei[ni,4]})
      If nPos8 == 0
         nTotNUsa := 1
         nTotNNov := 0 
         nTotINov := 0 
         nTotIUsa := 0 
//      	aadd(aResAgr,{cCategVen,STR0005,aGrpVei[nPos,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
      	aadd(aResAgr,{cCategVen,STR0005,aNumVei[ni,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
   	Else
      	aResAgr[nPos8,5] += 1 
   	Endif

   ElseIf  aNumVei[ni,2] == "2" .and. aNumVei[ni,3] == "0" 	// Importado Novo
	   nPos9 := Ascan(aResumo,{|x| x[1] == cCategVen})
      If nPos9 == 0 
         nTotINov := 1
         nTotNNov := 0 
         nTotNUsa := 0 
         nTotIUsa := 0 
   	   aadd(aResumo,{cCategVen,STR0006,nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
      Else
      	aResumo[nPos9,5] += 1 
   	Endif
//	   nPos10 := Ascan(aResAgr,{|x| x[1]+x[2] == cCategVen+aGrpVei[nPos,4]})
	   nPos10 := Ascan(aResAgr,{|x| x[1]+x[2] == cCategVen+aNumVei[ni,4]})
      If nPos10 == 0
         nTotINov := 1
         nTotNNov := 0 
         nTotNUsa := 0 
         nTotIUsa := 0 
//   	   aadd(aResAgr,{cCategVen,STR0006,aGrpVei[nPos,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
   	   aadd(aResAgr,{cCategVen,STR0006,aNumVei[ni,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
   	Else
      	aResAgr[nPos10,6] += 1 
   	Endif

   ElseIf  aNumVei[ni,2] == "2" .and. aNumVei[ni,3] == "1"	// Importado Usado
	   nPos11 := Ascan(aResumo,{|x| x[1] == cCategVen})
      If nPos11 == 0 
         nTotIUsa := 1   
         nTotNNov := 0 
         nTotNUsa := 0 
         nTotINov := 0 
   	   aadd(aResumo,{cCategVen,STR0007,nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
      Else
      	aResumo[nPos11,6] += 1 
   	Endif
//	   nPos12:= Ascan(aResAgr,{|x| x[1]+x[2] == cCategVen+aGrpVei[nPos,4]})
	   nPos12:= Ascan(aResAgr,{|x| x[1]+x[2] == cCategVen+aNumVei[ni,4]})
      If nPos12 == 0
         nTotIUsa := 1
         nTotNNov := 0 
         nTotNUsa := 0 
         nTotINov := 0 
//      	aadd(aResAgr,{cCategVen,STR0007,aGrpVei[nPos,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
      	aadd(aResAgr,{cCategVen,STR0007,aNumVei[ni,4],nTotNNov,nTotNUsa,nTotINov,nTotIUsa})
	   Else
   	   aResAgr[nPos12,7] += 1 
   	Endif

   EndIf    
Endif

Next    
FS_Resumo()		

Ms_Flush()
Set Printer to
Set Device  to Screen              

Return                                              


Static Function FS_Resumo()

Local n, i

nLin+=2
@ nLin++ ,004 pSay STR0058 //- - - - - - - - - -  - - - - R E S U M O  P/  M O D A L I D A D E  D E  V E N D A - - - - - - - - - - - - - - -"
nLin+=2
@ nLin++ ,004 pSay STR0004   //Novos Nacional
nLin++

aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
for i := 1 to Len(aResumo) 
   nLin++
   if aResumo[i,3] <> 0 
      nTotPerc := (aResumo[i,3] / nPerc) * 100   
     
      @ nLin++ ,004 pSay aResumo[i,1]+" ------------------------------ "+transform(aResumo[i,3], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
      nLin++
   Endif
   for n := 1 to Len(aResAgr) 
       if aResAgr[n,1] == aResumo[i,1]        
          if aResAgr[n,4] <> 0 
             nTotPerc := (aResAgr[n,4] / nPerc) * 100
             @ nLin++ ,008 pSay left(aResAgr[n,3],19)+" --------------------- "+transform(aResAgr[n,4], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
          Endif
       Endif
			If nLin >= 60
	    		nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
	   	 	nLin++ 
			EndIf  
   next
NEXT       

nLin+=2
@ nLin++ ,004 pSay STR0005 //Usados Nacional
nLin++

aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
for i := 1 to Len(aResumo) 
   nLin++
   if aResumo[i,4] <> 0 
      nTotPerc := (aResumo[i,4] / nPerc) * 100   
      @ nLin++ ,004 pSay aResumo[i,1]+" ------------------------------ "+transform(aResumo[i,4], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
      nLin++
   Endif   
   for n := 1 to Len(aResAgr) 
       if aResAgr[n,1] == aResumo[i,1]        
          if aResAgr[n,5] <> 0
             nTotPerc := (aResAgr[n,5] / nPerc) * 100
             @ nLin++ ,008 pSay left(aResAgr[n,3],19)+" --------------------- "+transform(aResAgr[n,5], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
          Endif
       Endif
			If nLin >= 60
	    		nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
	   	 	nLin++ 
			EndIf  
   next
NEXT       

nLin+=2
@ nLin++ ,004 pSay STR0006 //Novo Importado
nLin++

aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
for i := 1 to Len(aResumo) 
   nLin++
  if aResumo[i,5] <> 0 
      nTotPerc := (aResumo[i,5] / nPerc) * 100   
      @ nLin++ ,004 pSay aResumo[i,1]+" ------------------------------ "+transform(aResumo[i,5], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
      nLin++
   Endif   
   for n := 1 to Len(aResAgr) 
       if aResAgr[n,1] == aResumo[i,1]        
          if aResAgr[n,6] <> 0 
             nTotPerc := (aResAgr[n,6] / nPerc) * 100
             @ nLin++ ,008 pSay left(aResAgr[n,3],19)+" --------------------- "+transform(aResAgr[n,6], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
          Endif
       Endif
			If nLin >= 60
	    		nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
	   	 	nLin++ 
			EndIf  
   next
NEXT       

nLin+=2
@ nLin++ ,004 pSay STR0007 //Usado Importado
nLin++

aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
aSort(aResAgr,1,,{|x,y| x[1]+x[3] < y[1]+y[3]})
for i := 1 to Len(aResumo) 
   nLin++
   if aResumo[i,6] <> 0 
      nTotPerc := (aResumo[i,6] / nPerc) * 100   
      @ nLin++ ,004 pSay aResumo[i,1]+" ------------------------------ "+transform(aResumo[i,6], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
      nLin++
   Endif   
   for n := 1 to Len(aResAgr) 
       if aResAgr[n,1] == aResumo[i,1]        
          if aResAgr[n,7] <> 0 
             nTotPerc := (aResAgr[n,7] / nPerc) * 100
             @ nLin++ ,008 pSay left(aResAgr[n,3],19)+" --------------------- "+transform(aResAgr[n,7], "99999")+"  -  "+transform(nTotPerc, "@E 99.99")+" % "
          Endif
       Endif
			If nLin >= 60
	    		nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
	   	 	nLin++ 
			EndIf  
   next
NEXT       


RETURN
