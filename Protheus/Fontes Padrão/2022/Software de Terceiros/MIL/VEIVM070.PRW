#Include "Protheus.ch"
#Include "VEIVM070.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM070 ³ Autor ³  Manoel               ³ Data ³ 15/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Dados do Faturamento Direto                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM070
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0                                
//
Local bCampo  := { |nCPO| Field(nCPO) }
Local i , nCntFor, _ni
Local cQAlVV0  := "SQLVV0" 
Private cTipAva  := "1"   //Veiculos
Private cCpoDiv  := "    1"
Private aRotina := {{},{},{},{},{}}					
Private cCadastro  := OemToAnsi(STR0001)//Atualiza Dados do Faturamento Direto / Estoque
Private cTipFat := ""

Private aNewBot := {}

If 1 == 2
	FS_FiltFt()
	FS_FormPg()
Endif
aadd(aNewBot,{"FILTRO" ,"FS_FiltFt()",STR0002})		//Filtro
aadd(aNewBot,{"BUDGET" ,"FS_FormPg()",STR0003})		//Forma de Pagamento do Cliente
For i:=1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next

cPerg := "VEM070"
ValidP1()
PERGUNTE(cPerg,.t.)

cModVda := ""
If Mv_Par01 == 1 // Faturamento Direto
   cModVDa := "2" 
	cPerg := "FATDIR"
	ValidPerg()
ElseIf Mv_Par01 == 2 // Estoque Novos
   cModVDa := "0" 
	cPerg := "DECVIS"
	ValidPerg()
ElseIf Mv_Par01 == 3 // Estoque Semi-Novos
   cModVDa := "1" 
	cPerg := "DECVIS"
	ValidPerg()
Endif

PERGUNTE(cPerg,.t.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VV0")

Inclui := .f.

aRotina := {  {"","" , 0 , 1},;   		// Pesquisar
					{"","", 0 , 2} ,;   // Consultar
					{"","", 0 , 3} ,;   // Incluir
					{"","", 0 , 4 },; 	// Alterar
					{"","", 0 , 5 } } 	// Excluir

						
nOpcE := 4
nOpcG := 4

Aheader := {}
nUsado:=0

If cModVda == "2" // Faturamento Direto
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("VV0_NNFFDI")
	While !Eof().and.(x3_campo=="VV0_NNFFDI")
	      nUsado:=nUsado+1
	      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!S9",;
		        x3_tamanho, x3_decimal,x3_valid,;
	           x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
			DbSkip()
	EndDo
Else
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("VV0_NUMNFI")
	While !Eof().and.(x3_campo=="VV0_NUMNFI")
	      nUsado:=nUsado+1
	      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!S9",;
		        x3_tamanho, x3_decimal,x3_valid,;
	           x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
			DbSkip()
	EndDo
Endif
	
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VVA_CHASSI")
While !Eof().and.(x3_campo=="VVA_CHASSI")
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!S19",;
	        x3_tamanho, x3_decimal,x3_valid,;
           "ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", x3_tipo, x3_arquivo, "V", x3_Relacao, "ÇÇ" } )
		DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV0")
While !Eof().and.(x3_arquivo=="VV0")
   if Alltrim(x3_campo) $ "VV0_MODVDA#VV0_VALNEG#VV0_VEIPAT#VV0_ENTREG#VV0_DRCFAB#VV0_RECCLI#VV0_DPGFAB#VV0_DPGVEN"
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
	        x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif   
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_NUMTRA")
While !Eof().and.(x3_campo=="VV0_NUMTRA")
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!S10",;
	        x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
		DbSkip()
EndDo

RegToMemory("VV0",.f.)
DbSelectArea("VV0")
For nCntFor := 1 TO FCount()
    M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

If cModVda $ "0.1" // Novos Estoque / Semi-Novos Estoque
//	DbSelectArea("VV0")
//	DbSetOrder(4)
//	DbSeek(xFilial("VV0")+Mv_Par01+Mv_Par02)
	cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV, VV0.VV0_NUMNFI, VV0.VV0_SITNFI, VV0.VV0_OPEMOV, VV0.VV0_TIPFAT " 
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_OPEMOV='0' AND VV0.VV0_SITNFI='1' "
	cQuery += "AND (VV0.VV0_TIPFAT = '0' OR VV0.VV0_TIPFAT = '1') AND VV0.VV0_NUMNFI ='"+mv_par01+"' AND VV0.VV0_SERNFI = '"+mv_par02+"' AND VV0.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0 , .F., .T. ) 
Else
//	DbSelectArea("VV0")
//	DbSetOrder(2)
//	DbSeek(xFilial("VV0")+"0")
	cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV, VV0.VV0_NUMNFI, VV0.VV0_SITNFI, VV0.VV0_OPEMOV, VV0.VV0_TIPFAT,VV0.VV0_NNFFDI,VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV " 
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_OPEMOV='0' AND VV0.VV0_TIPFAT = '2' AND VV0.VV0_SITNFI='1' AND VV0.VV0_NNFFDI = '"+Mv_Par01+"' AND VV0.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0 , .F., .T. ) 
Endif

acols:={}

While !( cQAlVV0 )->( Eof() )

	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek( ( cQAlVV0 )->( VV0_FILIAL ) + ( cQAlVV0 )->( VV0_NUMTRA ) )

	DbSelectArea("VVA")
	DbSetOrder(1)
	DbSeek(xFilial("VVA")+( cQAlVV0 )->VV0_NUMTRA)

	AADD(acols,Array(nUsado+1))
	For _ni:=1 to nUsado
	   If _ni == 1 .or. _ni > 2
	   	DbSelectArea("VV0")
	   Else	
	   	DbSelectArea("VVA")
	   Endif	
		acols[Len(acols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	acols[Len(acols),nUsado+1]:=.F.

	DbSelectArea(cQAlVV0)
	( cQAlVV0 )->( DbSkip() )

Enddo
(cQAlVV0)->(DBCloseArea())
dbSelectArea("VV0")
If Len(aCols) == 0
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
Endif

If cModVda == "0" // Novos Estoque
	cTitulo    := OemToAnsi(STR0004)	//Atualiza Dados do Faturamento de Novos Estoque
ElseIf cModVda == "1" // Semi-Novos Estoque
	cTitulo    := OemToAnsi(STR0005)	//Atualiza Dados do Faturamento Semi-Novos Estoque
ElseIf cModVda == "2" // Faturamento Direto
	cTitulo    := OemToAnsi(STR0006)	//Atualiza Dados do Faturamento Direto
Endif
cAliasEnch := "VV0"
cLinOk     := "FG_OBRIGAT"
cTudoOk    := "AllwaysTrue()"
cFieldOk   := "FG_MEMVAR()"
//cFieldOk   := "allwaysTrue()"

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcG := If(nOpcG==Nil,3,nOpcG)
nOpca := 0
lVirtual := .f.
nLinhas:= 99           
Inclui := .f.
Altera := .t.

dbSelectArea("VV0")

// Configura os tamanhos dos objetos 							
aObjects := {}
AAdd( aObjects, { 05, 100 , .T. , .T. } ) 	//Enchoice			
//AAdd( aObjects, { 01, 10  , .T. , .T. } ) 	//Get Dados 		
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior	
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior 	
//tamanho para resolucao 1024*768 								
//aSizeAut[3]:= 508     										
//aSizeAut[5]:= 1016            								
// Fator de reducao de 0.8                       				
//for nCntTam := 1 to Len(aSizeAut)           					
//	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)  			
//next     														

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5]	of oMainWnd PIXEL
oGetDados:= MsGetDados():New(aPosObj[1,1]+002,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],nOpcG,cLinOk,cTudoOk,"",.T.,{"VV0_VALNEG","VV0_VEIPAT","VV0_ENTREG","VV0_DRCFAB","VV0_RECCLI","VV0_DPGFAB","VV0_DPGVEN"},,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg ON INIT (FG_EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()},,aNewBot) )

if nOpca == 1
   FS_GvVm070()
Endif



Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GvVm070³ Autor ³  Manoel               ³ Data ³ 15/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava campos alterados                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GvVm070()
Local i_

lMSHelpAuto := .f.
lMSErroAuto := .f.
             
DbSelectArea("VV0")
dbSetOrder(1)

Begin Transaction


For i_ :=1 to len(aCols)
		
	if aCols[i_,len(aHeader)+1]
		loop
	Endif

	If dbSeek(xFilial("VV0")+acols[i_,FG_POSVAR("VV0_NUMTRA","aHeader")])
	
      If VV0->VV0_VALNEG != aCols[i_,FG_POSVAR("VV0_VALNEG","aHeader")]

			if !recLock("VV0",.f.)
		      Help("  ",1,"REGNLOCK")
				DisarmTransaction()
				Break
			Endif	
			FG_GRAVAR("VV0",aCols,aHeader,i_)
			MsUnlock()

			dbSelectArea("VVA")
			dbSetOrder(1)
			DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
			dbSelectArea("VV1")
			dbSetOrder(1)
			DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
			
		   M->VVA_COMVDE := VVA->VVA_COMVDE
		   M->VVA_COMGER := VVA->VVA_COMGER
		   
		   If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
		      ExecBlock("FS_COMVEI",.f.,.f.)
		      RecLock("VVA",.f.)
				VVA->VVA_COMVDE := M->VVA_COMVDE
				VVA->VVA_CMFVDE := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMVDE}} )
				VVA->VVA_CMFGER := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMGER}} )
			   VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_VALIRF-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT
				VVA->VVA_LMFLQ2 := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_LUCLQ2}} )
				MsUnlock()
			Endif
		   If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
		      ExecBlock("FS_COMVEI",.f.,.f.)
		      RecLock("VVA",.f.)
				VVA->VVA_COMGER := M->VVA_COMGER
				MsUnlock()
			Endif
      Endif
		
		if !recLock("VV0",.f.)
	      Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif	
   Endif
   
Next
	                        
End Transaction

	
if lMsErroAuto
	MostraErro()
   lMSHelpAuto := .f.
   lMSErroAuto := .f.
	lDeleta := .t.
	Return .f.
Endif

lMsHelpAuto := .f.
   
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FiltFt ³ Autor ³  Manoel               ³ Data ³ 15/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa Filtro nos Veiculos de Faturamento Direto          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FiltFt()

Local _ni
Local cQAlVV0  := "SQLVV0" 

If !pergunte(cPerg,.t.)
	Return
Endif

If cModVda $ "0.1" // Novos Estoque / Semi-Novos Estoque
//	DbSelectArea("VV0")
//	DbSetOrder(4)
//	DbSeek(xFilial("VV0")+Mv_Par01+Mv_Par02)
	cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV, VV0.VV0_NUMNFI, VV0.VV0_SITNFI, VV0.VV0_OPEMOV, VV0.VV0_TIPFAT " 
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 WHERE VV0.VV0_FILIAL = '"+xFilial("VV0")+"' AND VV0.VV0_NUMNFI = '"+Mv_Par01+"' AND VV0.VV0_SERNFI = '"+Mv_Par02+"' AND VV0.VV0_OPEMOV = '0' AND VV0.VV0_TIPFAT = '0' .AND. VV0.VV0_SITNFI = '1' AND VV0.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0 , .F., .T. ) 

Else
//	DbSelectArea("VV0")
//	DbSetOrder(2)
//	DbSeek(xFilial("VV0")+"0")      

	cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV, VV0.VV0_NUMNFI, VV0.VV0_SITNFI, VV0.VV0_OPEMOV, VV0.VV0_TIPFAT,VV0.VV0_NNFFDI,VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV 
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 WHERE "
	if Empty(Mv_Par01) 
	   if Mv_Par02 != 3
	      if Mv_Par02==1
			cQuery += "VV0.VV0_VEIPAT = '"+str(Mv_Par02,1)+"' AND "
		  Else
			cQuery += "VV0->VV0_VEIPAT = ' ' AND VV0->VV0_VEIPAT = '0' AND "
		  Endif	   
       Endif
	   if mv_par04 != 3
	      if Mv_Par04 == 1  
 			 cQuery += "VV0.VV0_DRCFAB <> '        ' AND 
	      Else
 			 cQuery += "VV0.VV0_DRCFAB = '        ' AND 
	      Endif   
	   Endif  
       If Mv_Par05 != 3
          if Mv_Par05==1
		     cQuery += "VV0.VV0_RECCLI = '"+str(Mv_Par05,1)+"' AND "
		  Else   
			 cQuery += "VV0.VV0_RECCLI ' ' AND VV0->VV0_RECCLI = '0' AND "
	 	  Endif   
	   Endif	 
	   If Mv_Par06 != 3
    	  If Mv_Par06 == 1
			 cQuery += "VV0.VV0_DPGFAB <> '        ' AND "
		  Else
			 cQuery += "VV0.VV0_DPGFAB = '        ' AND "
		  Endif	 
		  If Mv_Par07 != 3
			 If Mv_Par07 == 1
			    cQuery += "VV0.VV0_DPGVEN <> '        ' AND "
			 Else
			    cQuery += "VV0.VV0_DPGVEN = '        ' AND "
			 Endif
		  Endif	    
       Endif
	Endif            
	cQuery += "VV0.VV0_FILIAL '"+xFilial("VV0")+"' AND VV0.VV0_OPEMOV = '0' AND VV0.VV0_TIPFAT = '2' AND VV0.VV0_SITNFI = '1' AND VV0->VV0_NNFFDI = '"+Mv_Par01+"' AND VV0.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0 , .F., .T. ) 

Endif

acols:={}

While !( cQAlVV0 )->( Eof() )

	DbSelectArea("VVA")
	DbSetOrder(1)
	DbSeek(xFilial("VVA")+( cQAlVV0 )->VV0_NUMTRA)

	AADD(acols,Array(nUsado+1))
	For _ni:=1 to nUsado
	   If _ni == 1 .or. _ni > 2
	   	DbSelectArea(cQAlVV0)
	   Else	
	   	DbSelectArea("VVA")
	   Endif	
		acols[Len(acols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	acols[Len(acols),nUsado+1]:=.F.
	If !Empty(Mv_Par01)
	   exit
	Endif		

	DbSelectArea(cQAlVV0)
	( cQAlVV0 )->(dbSkip())

Enddo
(cQAlVV0)->(DBCloseArea())

If Len(aCols) == 0
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
Endif

OGetDados:oBrowse:refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg
local _sAlias := Alias()
local aRegs := {}
local i,j
dbSelectArea("SX1")
dbSetOrder(1)
//cPerg := PADR(cPerg,6)
cPerg := LEFT(cPerg+SPACE(15),LEN(SX1->X1_GRUPO))
If Mv_Par01 == 1
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Numero NF Fabrica   ","","","mv_ch1","C",6,0,0,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Veiculo em Transito ","","","mv_ch2","C",1,0,0,"C","","Mv_Par02","Sim","","","","","Nao","","","","","Nao Considera","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Entregue ao Cliente ","","","mv_ch3","C",1,0,0,"C","","Mv_Par03","Sim","","","","","Nao","","","","","Nao Considera","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Recebemos da Fabrica","","","mv_ch4","C",1,0,0,"C","","Mv_Par04","Sim","","","","","Nao","","","","","Nao Considera","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Recebemos do Cliente","","","mv_ch5","C",1,0,0,"C","","Mv_Par05","Sim","","","","","Nao","","","","","Nao Considera","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Pagamos Fabrica     ","","","mv_ch6","C",1,0,0,"C","","Mv_Par06","Sim","","","","","Nao","","","","","Nao Considera","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Pagamos Vendedor    ","","","mv_ch7","C",1,0,0,"C","","Mv_Par07","Sim","","","","","Nao","","","","","Nao Considera","","","","","","","","","","","","","","",""})
Else
  	aAdd(aRegs,{cPerg,"01","Numero NFiscal      ","","","mv_ch1","C",9,0,0,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Serie NFiscal       ","","","mv_ch2","C",3,0,0,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
EndIf

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FormPg ³ Autor ³  Manoel               ³ Data ³ 16/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta condicao de Pagamento do Cliente                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FormPg()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0                                
//
Local _ni

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS9")
aHeaderC:={}
nUsadoC := 0
While !Eof().And.(x3_arquivo=="VS9")
//	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(SX3->X3_CAMPO) $ "VS9_DATPAG#VS9_VALPAG#VS9_REFPAG"//#VS9_SEQUEN"//#VS9_OBSERV#VS9_PORTAD#VS9_DESPOR#VS9_ENTRAD")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_SEQUEN"//#VS9_OBSERV#VS9_PORTAD#VS9_DESPOR#VS9_ENTRAD")
		If Trim(SX3->X3_CAMPO) $ "VS9_VALPAG"
			nUsadoC++
			Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,"",;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			wVar := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
		Else			
			nUsadoC++
			Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			wVar := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
		Endif
	Endif
	dbSkip()
EndDo
               
DbSelectArea("VVA")
DbSetOrder(1)
dbSeek(xFilial("VVA")+acols[n,FG_POSVAR("VV0_NUMTRA","aHeader")])

DbSelectArea("VV0")
DbSetOrder(1)
dbSeek(xFilial("VV0")+acols[n,FG_POSVAR("VV0_NUMTRA","aHeader")])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for alteracao traz valores digitados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsC   := {}
aIteParc := {}
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+VVA->VVA_NUMTRA+Space(5)+"V")
	While !Eof() .and. VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VVA->VVA_NUMTRA+Space(5)+'V'

//			If If(cModVda == "2",VS9->VS9_TIPPAG == "FD",.t.)
				AADD(aColsC,Array(nUsadoC+1))
				For _ni:=1 to nUsadoC
					aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
				Next
				aColsC[Len(aColsC),nUsadoC+1]:=.F.
//			Endif	
			dbSkip()
	Enddo
Endif

if Len(aColsC) == 0
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Endif

If cModVda $ "0.1" // Novos Estoque / Semi-Novos Estoque
	cNumNFF := STR0007 +"    "+acols[n,FG_POSVAR("VV0_NUMNFI","aHeader")]   //NF Saida
Else
	cNumNFF := STR0008 +"  "+acols[n,FG_POSVAR("VV0_NNFFDI","aHeader")]   //NF Fabrica
Endif
cChassi := STR0009+"  "+acols[n,FG_POSVAR("VVA_CHASSI","aHeader")]   //Chassi

nOpcaC := 0 

// Configura os tamanhos dos objetos 							
aObjects := {}//												
AAdd( aObjects, { 05, 12  , .T. , .F. } ) 	//Enchoice			
AAdd( aObjects, { 01, 10  , .T. , .T. } ) 	//Get Dados 		
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior	
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior 	
//tamanho para resolucao 1024*768 								
//aSizeAut[3]:= 508     										
//aSizeAut[5]:= 1016            								
// Fator de reducao de 0.8                       				
for nCntTam := 1 to Len(aSizeAut)           					
	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.94)  			
next     														

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgC TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

nc          := 1              
nSv         := n
nLinhas     := 99
aHeaderSv   := aClone(aHeader)
aHeader     := aClone(aHeaderC)
aColsSv     := aClone(aCols)
aCols       := aClone(aColsC)

@ aPosObj[1,1]+002,aPosObj[1,2]+003 SAY  OemToAnsi(cNumNFF)  OF oDlgC PIXEL COLOR CLR_HBLUE
@ aPosObj[1,1]+002,aPosObj[1,2]+086 SAY  OemToAnsi(cChassi)  OF oDlgC PIXEL COLOR CLR_HBLUE

oGetCondicao:= MsGetDados():New(aPosObj[2,1]+002,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,99,"AllwaysTrue()",,,,oDlgC)
oGetCondicao:oBrowse:default()
ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,{||nOpcaC:=1,Fs_GravaPg(),oDlgC:End()},{||oDlgC:End()})

aCols   := aClone(aColsSv)
aHeader := aClone(aHeaderSv)       
n       := nSv

Return

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GravaPg³ Autor ³  Manoel               ³ Data ³ 16/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava condicao de Pagamento do Cliente                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GravaPg()

Local i

DbSelectArea("VS9")
If cModVda == "2" // Faturamento Direto
//	dbSeek(xFilial("VS9")+VV0->VV0_NUMTRA+'V'+'FD')//+strzero(i,2))
	dbSeek(xFilial("VS9")+VV0->VV0_NUMTRA+Space(5)+'V')//+strzero(i,2))
Else
	dbSeek(xFilial("VS9")+VV0->VV0_NUMTRA+Space(5)+'V')
Endif
While !eof() .and. VS9->VS9_NUMIDE == VV0->VV0_NUMTRA+Space(5)

      nRec := recno()
		RecLock("VS9",.F.,.T.)
		DbDelete()
		MsUnlock()
		WriteSx2("VS9")
		DbSelectArea("VS9")
		If nRec != recno()
			DbGoto(nRec)
		Endif
		DbSkip()

Enddo

For i:=1 to len(aCols)

	if aCols[i,len(aCols[i])]
		loop
	Endif

	dbSelectArea("VS9")
	dbSetOrder(1)
//	RecLock("VS9",!Found())
	RecLock("VS9",.t.)
	FG_GRAVAR("VS9",aCols,aHeader,i)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := VV0->VV0_NUMTRA
	VS9->VS9_TIPOPE := "V"
//	If cModVda == "2" // Faturamento Direto
//		VS9->VS9_TIPPAG := "FD"
//	Endif
	VS9->VS9_SEQUEN := Strzero(i,2)
	MsUnlock()
Next
	
	

Static Function ValidP1

local _sAlias := Alias()
local aRegs := {}
local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := LEFT(cPerg+SPACE(15),LEN(SX1->X1_GRUPO))
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Modalidade da Venda ","","","mv_ch1","N",1,0,0,"C","","Mv_Par01","Vdas Especiais","","","","","Novos Estoque","","","","","Semi-Novos Estoque","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return
	

