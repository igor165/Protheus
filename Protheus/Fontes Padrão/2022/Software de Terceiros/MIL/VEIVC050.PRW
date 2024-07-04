#include "VEIVC050.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVC050 ³       ³ Andre Luis Almeida    ³ Data ³ 19/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ficha do Veiculos - Relatorio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/             
Function VEIVC050  
	Private cTipAva   := "1"
	If Pergunte("FICVEI",.t.)   
		Processa( {|| FS_RFICVE() } )
	EndIf
Return

Static Function FS_RFICVE()
	Local ni := 0
	Private cDesc1    := STR0001
	Private cDesc2    := ""
	Private cDesc3    := ""
	Private cAlias    := "VV0"
	Private aRegistros:= {}
	Private nLin      := 0
	Private aPag      := 1
	Private nIte      := 1
	Private aReturn   := {STR0002,1,STR0003,2,2,1,"",1}
	Private cTamanho  := "M"           // P/M/G
	Private Limite    := 132           // 80/132/220
	Private aOrdem    := {}           // Ordem do Relatorio
	Private cTitulo   := STR0004
   Private cNomeProg := "VEIVC050"
   Private cNomeRel  := "VEIVC050"
	Private nLastKey  := 0
	Private nCaracter := 15
	Private ccabec1   := ""
	Private ccabec2   := ""
	Private cPerg     := nil
	Private c_tipven  := ""
	Private m_Pag		:= 1
	Private cCodMap   := MV_PAR05
	Private aStru     := {}
	Private cCpoDiv   := "    1"
	Private cOutMoed  := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
	Private cSimOMoe  := Val(Alltrim(GetMv("MV_INDMFT")))
	Private cSimVda   := "V"
	Private nopc      := 2  
	Private lOpcGN    := .f.      
	Private nOpcMid   := 0
	Private aFichas	:= {} // { Tik , Chassi , Dt.Entrada , Dt.Saida , Tipo Saida , Trans.Entrada , Trans.Saida }
	Private aFicAux	:= {} // { Tik , Chassi , Dt.Entrada , Dt.Saida , Tipo Saida , Trans.Entrada , Trans.Saida }
	Private aChassi	:= {} // { Chassi }
	Private oOk			:= LoadBitmap( GetResources(), "LBTIK" )
	Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
	Private lMarcar	:= .f.
	Private nOK			:= 0
	Private nPos		:= 0
	Private cCabFic	:= If( MV_PAR01 == 1 , STR0005+MV_PAR04 , STR0006+Transform(MV_PAR02,"@D")+STR0007+Transform(MV_PAR03,"@D") )
   If MV_PAR01 == 1
		Aadd(aChassi,{ MV_PAR04 } )
   Else
		// VV0_OPEMOV == "0" //
   	DbSelectArea("VV0")
	   DbSetOrder(2)
	   DbSeek(xFilial("VV0")+"0"+dtos(MV_PAR02),.t.)
		Do While !Eof() .and. xFilial("VV0") == VV0->VV0_FILIAL .and. VV0->VV0_OPEMOV == "0" .and. VV0->VV0_DATMOV <= MV_PAR03
			DbSelectArea("VVA")
			DbSetOrder(1)
			DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		   nPos := 0
			nPos := aScan(aChassi,{|x| x[1] == VVA->VVA_CHASSI })
			If nPos == 0 
			 	Aadd(aChassi,{ VVA->VVA_CHASSI } )
		   EndIf
		   DbSelectArea("VV0") 
		   DbSkip()
		EndDo
		// VV0_OPEMOV == "3" //
   	DbSelectArea("VV0")
	   DbSetOrder(2)
	   DbSeek(xFilial("VV0")+"3"+dtos(MV_PAR02),.t.)
		Do While !Eof() .and. xFilial("VV0") == VV0->VV0_FILIAL .and. VV0->VV0_OPEMOV == "3" .and. VV0->VV0_DATMOV <= MV_PAR03
			DbSelectArea("VVA")
			DbSetOrder(1)
			DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		   nPos := 0
			nPos := aScan(aChassi,{|x| x[1] == VVA->VVA_CHASSI })
			If nPos == 0 
			 	Aadd(aChassi,{ VVA->VVA_CHASSI } )
		   EndIf
		   DbSelectArea("VV0") 
		   DbSkip()
		EndDo
		If len(aChassi) <= 0
			MsgAlert(STR0009,STR0008)
			Return()
		EndIf
   EndIf
   For ni := 1 to len(aChassi)
		DbSelectArea("VV1")
		DbSetOrder(2)
		DbSeek(xFilial("VV1")+aChassi[ni,1])
		DbSelectArea("VVG")
		DbSetOrder(2)
		If DbSeek(xFilial("VVG")+VV1->VV1_CHAINT)
			Do While !Eof() .and. xFilial("VVG") == VVG->VVG_FILIAL .and. VVG->VVG_CHAINT == VV1->VV1_CHAINT
				DbSelectArea("VVF")
				DbSetOrder(1)
				DbSeek(xFilial("VVF")+VVG->VVG_TRACPA)
				If MV_PAR01 == 1
					Aadd(aFichas,{ .f. , VVG->VVG_CHASSI , Transform(VVF->VVF_DATMOV,"@D") , " " , " " , VVG->VVG_TRACPA , " ",If(VV1->VV1_ESTVEI=="0",STR0010,STR0011) } )
				EndIf
				DbSelectArea("VVA")
				DbSetOrder(3)
				DbSeek(xFilial("VVA")+VV1->VV1_CHAINT)
				Do While !Eof() .and. xFilial("VVA") == VVA->VVA_FILIAL .and. VVA->VVA_CHAINT == VV1->VV1_CHAINT
					If VVA->VVA_TRACPA == VVG->VVG_TRACPA // .or. VV1->VV1_TRACPA == VVA->VVA_TRACPA
					   DbSelectArea("VV0")
				   	DbSetOrder(1)
						DbSeek(xFilial("VV0")+VVA->VVA_NUMTRA) 
					   If VV0->VV0_SITNFI # "0" .and.  VV0->VV0_OPEMOV $ "0/3"
							If MV_PAR01 == 1
								If VV0->VV0_OPEMOV == "0" .and. VV0->VV0_TIPFAT != "2"
									aFichas[len(aFichas),4] := Transform(VV0->VV0_DATMOV,"@D")
									aFichas[len(aFichas),5] := STR0012
									aFichas[len(aFichas),7] := VVA->VVA_NUMTRA
								ElseIf VV0->VV0_OPEMOV == "3"
									aFichas[len(aFichas),4] := Transform(VV0->VV0_DATMOV,"@D")
									aFichas[len(aFichas),5] := STR0013
									aFichas[len(aFichas),7] := VV0->VV0_TRADEV // de acordo com conversa com a Silvania (16.12.2003)
								ElseIf VV0->VV0_OPEMOV $ "5/7"
									aFichas[len(aFichas),4] := Transform(VV0->VV0_DATMOV,"@D")
									aFichas[len(aFichas),5] := STR0014
									aFichas[len(aFichas),7] := VVA->VVA_NUMTRA
								EndIf
						   Else
						   	If ( ( VV0->VV0_DATMOV >= MV_PAR02 ) .and. ( VV0->VV0_DATMOV <= MV_PAR03 ) )
									Aadd(aFichas,{ .f. , VVG->VVG_CHASSI , Transform(VVF->VVF_DATMOV,"@D") , Transform(VV0->VV0_DATMOV,"@D") , STR0012 , VVG->VVG_TRACPA , VVA->VVA_NUMTRA,If(VV1->VV1_ESTVEI=="0",STR0010,STR0011)} )
								EndIf
							EndIf
						EndIf
					EndIf
				   DbSelectArea("VVA") 
				   DbSkip()
				EndDo  
		   	DbSelectArea("VVG")
			   DbSkip()
			EndDo  
		Elseif Alltrim(VV1->VV1_TRACPA)=="FATDIR"
			DbSelectArea("VVA")
			DbSetOrder(3)
			DbSeek(xFilial("VVA")+VV1->VV1_CHAINT)
			Do While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_CHAINT == VV1->VV1_CHAINT
				If VVA->VVA_TRACPA == VVG->VVG_TRACPA //.or. VV1->VV1_TRACPA == VVA->VVA_TRACPA
				   DbSelectArea("VV0")
			   	DbSetOrder(1)
					DbSeek(xFilial("VV0")+VVA->VVA_NUMTRA) 
				   If VV0->VV0_SITNFI # "0" .and.  ( ( MV_PAR01 == 1 .or. MV_PAR01 == 2 ) .and. VV0->VV0_OPEMOV $ "0/3" )
						If MV_PAR01 == 1
							If VV0->VV0_OPEMOV == "0" .and. VV0->VV0_TIPFAT == "2"
								Aadd(aFichas,{ .f. , VV1->VV1_CHASSI , Transform(VV0->VV0_DATMOV,"@D") ,Transform(VV0->VV0_DATMOV,"@D")  , STR0015 , STR0016 , VVA->VVA_NUMTRA,If(VV1->VV1_ESTVEI=="0",STR0010,STR0011) } )
							EndIf
					   Else
					   	If ( ( VV0->VV0_DATMOV >= MV_PAR02 ) .and. ( VV0->VV0_DATMOV <= MV_PAR03 ) )
								Aadd(aFichas,{ .f. , VV1->VV1_CHASSI , Transform(VV0->VV0_DATMOV,"@D") , Transform(VV0->VV0_DATMOV,"@D") , STR0017 , VVA->VVA_TRACPA , VVA->VVA_NUMTRA,If(VV1->VV1_ESTVEI=="0",STR0010,STR0011)} )
							Endif
						EndIf
					EndIf
				EndIf
			   DbSelectArea("VVA") 
			   DbSkip()
			EndDo  
		EndIf	
	Next
	If len(aFichas) == 0
		Aadd(aFichas,{ .f. , " " , " " , " " , " " , " " , " ", " " } )
	Else
		If MV_PAR01 == 2
			aFicAux := {}
			For ni := 1 to len(aFichas) 
				If !Empty(Alltrim(aFichas[ni,7]))
		 			Aadd(aFicAux,{ aFichas[ni,1] , aFichas[ni,2] , aFichas[ni,3] , aFichas[ni,4] , aFichas[ni,5] , aFichas[ni,6] , aFichas[ni,7], aFichas[ni,8] } )
				EndIf
			Next                      
			aFichas := {}
		   aFichas := aClone(aFicAux)
		EndIf
		aSort(aFichas,1,,{|x,y| x[2]+dtos(ctod(x[3])) < y[2]+dtos(ctod(y[3])) })
	EndIf
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 025,078 TITLE ("*** "+STR0001+" ***") OF oMainWnd
	@ 005,130 SAY cCabFic SIZE 400,08 OF oDlg1 PIXEL COLOR CLR_BLUE			
  	@ 017,003 LISTBOX oLbx1 FIELDS HEADER OemToAnsi(" "),OemToAnsi(STR0018),OemToAnsi(STR0019),OemToAnsi(STR0020),OemToAnsi(STR0021),OemToAnsi(STR0022) COLSIZES 10,90,40,40,40,50 SIZE 303,155 OF oDlg1 PIXEL ON DBLCLICK (aFichas[oLbx1:nAt,1] := !aFichas[oLbx1:nAt,1])
   oLbx1:SetArray(aFichas)
  	oLbx1:bLine := { || {If(aFichas[oLbx1:nAt,1],oOk,oNo),;
									aFichas[oLbx1:nAt,2],;
  			                  aFichas[oLbx1:nAt,3],;
  			                  aFichas[oLbx1:nAt,4],;
  			                  aFichas[oLbx1:nAt,5],;
  			                  aFichas[oLbx1:nAt,8]}}
   @ 005, 004 CHECKBOX oRFicha VAR lMarcar PROMPT STR0023 ;
                            OF oDlg1 ;
                            ON CLICK If( FS_TIK( lMarcar ) , .t. , ( lMarcar:=!lMarcar , oRFicha:Refresh() ) ) ;
                              SIZE 80,08 PIXEL COLOR CLR_BLUE
	DEFINE SBUTTON FROM 175,235 TYPE 6 ACTION (oDlg1:End(),nOK:=1) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 175,270 TYPE 2 ACTION oDlg1:End() ENABLE OF oDlg1
   ACTIVATE MSDIALOG oDlg1 CENTER 
   If nOK == 1
		cNomeRel:=SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
		If nLastKey == 27
			Return
		EndIf     
		SetDefault(aReturn,cAlias)
		RptStatus( { |lEnd| FS_IMP_RFICVE(@lEnd,cNomeRel,cAlias) } , cTitulo )
		If aReturn[5] == 1
		   OurSpool( cNomeRel )
		EndIf
		MS_Flush()
   EndIf
Return

Static Function FS_IMP_RFICVE()
	Local bCampo := { |reg| Field(reg) }
	Local nCntFor := 0, vv := 0, ipp := 0, ni := 0
	Local lPesDoc := .f. 
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("VV1_PESDOC")
		lPesDoc := .t. 
	EndIf 
	For ni := 1 to len(aFichas) 
		If aFichas[ni,1]
			DbSelectArea("VV1")
			DbSetOrder(2)
			DbSeek(xFilial("VV1")+aFichas[ni,2])
			DbSelectArea("VE1")
			DbSetOrder(1)
			DbSeek(xFilial("VE1")+VV1->VV1_CODMAR)
			DbSelectArea("VE4")
			DbSetOrder(1)
			DbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
			DbSelectArea("VVC")
			DbSetOrder(1)
			DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
			DbSelectArea("VVF")
			DbSetOrder(1)
			DbSeek(xFilial("VVF")+aFichas[ni,6]) 
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			DbSelectArea("VVG")
			DbSetOrder(1)
			DbSeek(xFilial("VVG")+aFichas[ni,6]+VV1->VV1_CHAINT)
			DbSelectArea("VVH")
			DbSetOrder(1)
			DbSeek(xFilial("VVH")+VVG->VVG_CODIND)
			If !Empty(Alltrim(aFichas[ni,7]))
			   DbSelectArea("VV0")
		   	DbSetOrder(1)
				DbSeek(xFilial("VV0")+aFichas[ni,7]) 
	      Endif
			cModVda := "                         "
	      If VV0->VV0_TIPFAT == "0"
	 	     If Subs(SA2->A2_CGC,1,9) == Subs(VE4->VE4_CGCFAB,1,9)
		        cModVda := STR0024
	        Else
		        cModVda := STR0025+VV1->VV1_PLAVEI
	        Endif
	      ElseIf VV0->VV0_TIPFAT == "1"
	        cModVda := STR0026+VV1->VV1_PLAVEI
	      ElseIf VV0->VV0_TIPFAT == "2"
	        cModVda := STR0027+VV1->VV1_PLAVEI
	      Endif  
			nLin      := cabec(ctitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter) + 1
			cCGCCPF1  := subs(transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1)
			cCGCCPFc  := cCGCCPF1 + space(18-len(cCGCCPF1))
			cCGCCPF2  := subs(transform(SA2->A2_CGC,PicPes(SA2->A2_TIPO)),1,at("%",transform(SA2->A2_CGC,PicPes(SA2->A2_TIPO)))-1)
			cCGCCPFf  := cCGCCPF2 + space(18-len(cCGCCPF2))        
			@ nLin++,00 psay STR0028 + cModVda +repl("-",65)
			@ nLin++,00 psay STR0029 + VV1->VV1_CHASSI          + Space(25) + STR0030 + Alltrim(VE1->VE1_DESMAR) + " - " + VV2->VV2_DESMOD
			@ nLin++,00 psay STR0031 + left(VVC->VVC_DESCRI,25) + Space(25) + STR0032 + Subs(VV1->VV1_FABMOD,1,4) + "/" + Subs(VV1->VV1_FABMOD,5,4) + Space(18) + STR0033 + VVG->VVG_CODIND + " - " + VVH->VVH_DESCRI
			@ nLin++,00 psay STR0034 + left(SA1->A1_NOME,40)    + Space(10) + STR0035 + cCGCCPFc        + Space(13) + STR0036 + left(SA1->A1_TEL,21) 
	      If VV0->VV0_TIPFAT != "2" // So Imprime Entrada quando nao for Faturamento Direto
				@ nLin++,00 psay STR0037 + repl("-",90)
				@ nLin++,00 psay STR0038 + dToc(VVF->VVF_DATMOV)      + Space(42) + STR0039 + VVF->VVF_NUMNFI + "/" + VVF->VVF_SERNFI
				@ nLin++,00 psay STR0040 + SA2->A2_NOME                + Space(10) + STR0035 + cCGCCPFf        + Space(13) + STR0041 + Alltrim(left(SA2->A2_MUN,21)) + "-" + SA2->A2_EST
				@ nLin++,00 psay STR0042 + transform(VVG->VVG_VCNVEI,"@E 999,999,999.99") + If(lPesDoc .and. !Empty(VV1->VV1_PESDOC) , space(36) + STR0043 + VV1->VV1_PESDOC , "" )
				@ nLin++,00 psay STR0044 + transform(VVG->VVG_VBICRT,"@E 9,999,999.99") + Space(25) + STR0045 + transform(VVH->VVH_DIACAR,"@E999")
			Endif	
			If !Empty(Alltrim(aFichas[ni,7]))
			   DbSelectArea("VV0")
		   	DbSetOrder(1)
				DbSeek(xFilial("VV0")+aFichas[ni,7]) 
			   If Subs(SA2->A2_CGC,1,9) == Subs(VE4->VE4_CGCFAB,1,9)
					If (VVF->VVF_DATEMI + VVH->VVH_DIACAR) > VV0->VV0_DATMOV
					   @ nLin++,101 psay STR0046 + Dtoc(VV0->VV0_DATMOV+VVH->VVH_DIAPGF)
					Else   
					   @ nLin++,101 psay STR0046 + Dtoc(VVF->VVF_DATEMI+VVH->VVH_DIACAR)
					Endif
				Else
				  nLin++
				Endif
				DbSelectArea("VV0")
				For nCntFor := 1 TO FCount()
					M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
				Next
				DbSelectArea("VVA")
				DbSetOrder(1)
				DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
				For nCntFor := 1 TO FCount()
					M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
				Next
				c_tipven := STR0049
				If VV0->VV0_TIPVEN = "RD"
				   c_tipven := STR0047
				ElseIf VV0->VV0_TIPVEN = "AL"   
				   c_tipven := STR0048
				EndIf
				If !Empty(VV0->VV0_CLIALI)
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial("SA1")+VV0->VV0_CLIALI+VV0->VV0_LOJALI)
				   c_tipven := c_tipven + rtrim(SA1->A1_NOME)
				EndIf
				@ nLin++,00 psay STR0050 + repl("-",90)
			   c_catven := "                 "
				Do Case
					Case VV0->VV0_CATVEN = "0"
			   		c_catven := STR0051
					Case VV0->VV0_CATVEN = "1"
					   c_catven := STR0052
					Case VV0->VV0_CATVEN = "2"
				   	c_catven := STR0053
					Case VV0->VV0_CATVEN = "3"
				   	c_catven := STR0054
					Case VV0->VV0_CATVEN = "4"
				   	c_catven := STR0055
					Case VV0->VV0_CATVEN = "5"
				   	c_catven := STR0056
					Case VV0->VV0_CATVEN = "6"
					   c_catven := STR0057
					Case VV0->VV0_CATVEN = "7"
					   c_catven := STR0058
					Case VV0->VV0_CATVEN = "8"
					   c_catven := STR0059
					Case VV0->VV0_CATVEN = "9"
				   	c_catven := STR0060
					Case VV0->VV0_CATVEN = "A"
					   c_catven := STR0061
				EndCase
				DbSelectArea("SA3")
				DbSetOrder(1)
				DbSeek(xFilial("SA3")+VV0->VV0_CODVEN)
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
				cCGCCPF1  := subs(transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1)
				cCGCCPFc  := cCGCCPF1 + space(18-len(cCGCCPF1))
				@ nLin++,00 psay STR0062 + dToc(VV0->VV0_DATMOV)      + Space(42) + STR0039 + VV0->VV0_NUMNFI + "/" + VV0->VV0_SERNFI + space(21) + STR0063 + If(VV0->VV0_OPEMOV=="0",Alltrim(STR0012),Alltrim(STR0013))
				@ nLin++,00 psay STR0064 + left(SA1->A1_NOME,40)      + Space(10) + STR0035 + cCGCCPFc        + Space(13) + STR0036 + left(SA1->A1_TEL,21) 
				@ nLin++,00 psay STR0065 + Alltrim(SA1->A1_END)+ " - " + Alltrim(SA1->A1_BAIRRO) + STR0066 + Transform(SA1->A1_CEP,"@R 99999-999") + STR0067 + Alltrim(left(SA1->A1_MUN,21)) + "-" + SA1->A1_EST
				@ nLin++,00 psay STR0068 + transform(VV0->VV0_VALMOV,"@E 999,999,999.99") + Space(36)  + STR0069 + VV0->VV0_CODVEN + " - " + Subs(SA3->A3_NOME,1,30) 
				@ nLin++,00 psay STR0070 + c_catven + space(33) + c_tipven 
				If VV0->VV0_OPEMOV$"0/3/5/7"
					@ nLin++,00 psay repl("-",132)
					@ nLin++,00 psay STR0071
					@ nLin++,00 psay repl("-",132)
			 		FS_CHA050()
				 	aStru := {}
		 			aStru := FG_CalcVlrs(FS_RVETOR(VV0->VV0_TIPFAT,MV_PAR05))
					For vv := 1 to len(aStru)
					    If nLin > 75
							nLin := cabec(ctitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter) + 1
							nLin++
				   	 EndIf
					    @ nLin++,00 psay "  " + If(Left(aStru[vv,05],7)==Space(7),Space(3)+Ltrim(aStru[vv,05]),aStru[vv,05]+Space(3)) + Space(6) + transform(aStru[vv,09],"@E 9,999,999.99")+Space(6)+transform(aStru[vv,10],"@E 999.99")
					Next  	
			 	EndIf
				@ nLin++,00 psay repl("-",132)
				DbSelectArea("VS9")
				If DbSeek(xFilial("VS9")+VV0->VV0_NUMTRA)
					nValParcs := 0                             
					aVetPrtParc := {}
					While !eof() .and. VS9->VS9_NUMIDE == VV0->VV0_NUMTRA
			         aadd(aVetPrtParc, DToc(VS9->VS9_DATPAG) +Space(3)+Transform(VS9->VS9_VALPAG,"@E 99,999,999.99")+Space(7)+VS9->VS9_DESPAG)
			         nValParcs := nValParcs + VS9->VS9_VALPAG
			         dbSkip()
					Enddo
					If Len(aVetPrtParc) + 5 + nLin > 75
						nLin := cabec(ctitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter) + 1
						nLin++
				   EndIf
					@ nLin++,00 psay STR0072
					nLin++
					@ nLin++,00 psay STR0073
				   For ipp := 1 to Len(aVetPrtParc)
	               @ nLin++, 00 psay aVetPrtParc[ipp]
		         Next      
					nLin++
					@ nLin++,00 psay "        ----------------"
					@ nLin++,00 psay "           "+Transform(nValParcs,"@E 99,999,999.99")
				Endif	
			EndIf   
	   EndIf
	Next
Return()

Static Function FS_RVETOR(cTipFat,cCodMap)
	aStru := {}
	lCarBott:= .t.
	DbSelectArea("VS5")
	DbSetOrder(1)
	DbSeek(xFilial("VS5")+cCodMap)
	DbSelectArea("VOQ")
	DbSetOrder(1)
	DbSeek(xFilial("VOQ")+cCodMap)
	While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
		If !(cTipFat $ VOQ->VOQ_TIPFAT)
			DbSelectArea("VOQ")
			DbSkip()
			Loop
		Endif
		If VOQ->VOQ_INDATI # "1" && Sim
			DbSelectArea("VOQ")
			DbSkip()
			Loop
		Endif
		If VOQ->VOQ_CODMAP # cCodMap
			Exit
		Endif
		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
		aadd(aStru,{ VV0->VV0_NUMTRA,VV1->VV1_TRACPA,VV1->VV1_CHAINT,VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,VV0->VV0_DATMOV,0,0,VOQ->VOQ_CTATOT})
		DbSelectArea("VOQ")
		DbSkip()
	Enddo
Return(aStru)
   
Static Function FS_CHA050
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)
	cChaint := VV1->VV1_CHAINT
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"D")
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"R")
Return(.t.)

Static Function FS_TIK( lMarcar )
	Local ni := 0
	For ni := 1 to Len(aFichas)
		aFichas[ni,1] := lMarcar
	Next
	oLbx1:SetFocus()
	oLbx1:Refresh()
Return(.t.)