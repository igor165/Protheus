#include "VEIVR170.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIVR170 ºAutor  ³Andre Luis Almeida  º Data ³  27/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Estoque de Veiculos/Maquinas                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR170
Private cTipVei   := STR0001 			// Veiculos 
Private cDesc1    := STR0002 +cTipVei 	//estoque de 
Private cDesc2    := ""
Private cDesc3    := ""
Private cAlias    := "VV1"
Private aRegistros:= {}
Private nLin      := 0
Private aPag      := 1
Private nIte      := 1
Private aReturn   := { STR0003, 1,STR0004, 2, 2, 1, "",1 } //zebrado # administracao
Private cTamanho  := "P"           	// P/M/G
Private Limite    := 80           	// 80/132/220
Private aOrdem    := {}           	// Ordem do Relatorio
Private cTitulo   := STR0005 +UPPER(cTipVei)  //ESTOQUE DE
Private cNomeProg := "VEIVR170"
Private cNomeRel  := "VEIVR170"
Private nLastKey  := 0
Private nCaracter := 15
Private cabec1    := ""
Private cabec2    := ""
Private cPerg     := "VVR170"

// ValidPerg()
cNomeRel:=SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
If nLastKey == 27
	Return
EndIf     
PERGUNTE(cPerg,.f.)
                        
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_IMPVR170(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf

MS_Flush()
Return
           
Static Function FS_IMPVR170()
Local nRecSM0 := SM0->(Recno())
Local cEmpres := SM0->M0_CODIGO
Local aFil    := {}
Local cQuery  := ""
Local cQAlSB2 := "SQLSB2"
Local cQAlVV1 := "SQLVV1" // VV1
Local cFilAtu := ""
Local cGruVei := left(GetNewPar("MV_GRUVEI","VEI")+space(10),len(SB1->B1_GRUPO))
Local nPos    := 0
Local ni      := 0
Local nNovoUsado := 0
Local cSitVei := ""
Local aSitVei := {}
Local aRetVVF := {}
Local lOk     := .t.
Local cAux    := ""
Private cTipo    := ""
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "VV1"
Private Li       := 80
Private m_Pag    := 1
Private wnRel    := "VEIVR170"
Private aNumEst := {}
Private aGrpEst := {}
Private aMod    := {}
Private aTotMod := {}
Private aTotSit := {}
// estoque inicial informe de vendas por chassi
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV1_SITVEI")
cSitVei := X3CBOX()
While len(cSitVei) > 1
	nPos := If(at(";",cSitVei)==0,len(cSitVei)+1,at(";",cSitVei))
	If substr(cSitVei,1,1) $ "02345"
		aAdd(aSitVei,{substr(cSitVei,1,1),substr(cSitVei,3,nPos-3)})
	EndIf
	cSitVei := Alltrim(substr(cSitVei,nPos+1,len(cSitVei)))
EndDo
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	If cEmpres == SM0->M0_CODIGO
		aAdd( aFil , { SM0->M0_CODFIL , left(SM0->M0_FILIAL+space(17),17) , 0 , 0 })
	EndIf
	DbSkip()
EndDo
DbGoTo(nRecSM0)

aAdd(aTotSit,{ "0" , "0" , 0 })  // Na Empresa - Veiculos Novos
aAdd(aTotSit,{ "0" , "1" , 0 })  // Na Empresa - Veiculos Usados
aAdd(aTotSit,{ "2" , "0" , 0 })  // Em Transito - Veiculos Novos
aAdd(aTotSit,{ "2" , "1" , 0 })  // Em Transito - Veiculos Usados
aAdd(aTotSit,{ "3" , "0" , 0 })  // Remessa - Veiculos Novos
aAdd(aTotSit,{ "3" , "1" , 0 })  // Remessa - Veiculos Usados
aAdd(aTotSit,{ "4" , "0" , 0 })  // Consignados - Veiculos Novos
aAdd(aTotSit,{ "4" , "1" , 0 })  // Consignados - Veiculos Usados
aAdd(aTotSit,{ "5" , "0" , 0 })  // Transferencia - Veiculos Novos
aAdd(aTotSit,{ "5" , "1" , 0 })  // Transferencia - Veiculos Usados
aAdd(aTotSit,{ "6" , "0" , 0 })  // 6 (Interno) Reservados - Veiculos Novos
aAdd(aTotSit,{ "6" , "1" , 0 })  // 6 (Interno) Reservados - Veiculos Usados

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
                                     
cabec1 := STR0006+" "+Transform(MV_PAR08,"@D")+" "+ STR0007 +" "+Transform(MV_PAR09,"@D")+" - "+ STR0008 +" "+str(MV_PAR10,3) //Filtro: Entrada por Compra  # a # Qtd Min. dias:

nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      

cQuebra := "INICIAR"
cQuebMod:="INICIAR"
cTitEst := ""
ni      := 0
nTotal  := 0
cTracos := "------------------------------------------------------------------------------"              

cQuery := "SELECT VV1.VV1_CHASSI , VV1.VV1_CHAINT , VV1.VV1_SITVEI , VV1.VV1_TRACPA , VV1.VV1_ESTVEI , VV1.VV1_RESERV , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_DTHRES , VV1.VV1_DTHVAL , VV1.VV1_CORVEI , VV1.VV1_FABMOD , VV1.VV1_PLAVEI , VV2.VV2_DESMOD , VVC.VVC_DESCRI "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 , "+RetSqlName("VVC")+" VVC WHERE "
If MV_PAR07 # 1 
	If MV_PAR07 == 2
		cQuery += "VV1.VV1_ESTVEI='0' AND " 	// Novos 
	Else // MV_PAR07 == 3
		cQuery += "VV1.VV1_ESTVEI='1' AND " 	// Usados
	EndIf
EndIf
cQuery += "VV1.VV1_SITVEI IN ('0','2','3','4','5') AND VV1.D_E_L_E_T_=' ' AND VV2.D_E_L_E_T_=' '  AND VVC.D_E_L_E_T_=' ' AND VV1.VV1_CODMAR=VVC.VVC_CODMAR AND VV1.VV1_CORVEI=VVC.VVC_CORVEI AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. ) 
While !( cQAlVV1 )->( Eof() )
	If ( cQAlVV1 )->( VV1_SITVEI ) == "0" .and. left(( cQAlVV1 )->( VV1_TRACPA ),6) == "FATDIR"
   	( cQAlVV1 )->( DbSkip() )
		Loop
	EndIf
	cSitVei := ( cQAlVV1 )->( VV1_SITVEI )
	If cSitVei == "0"
		If ( cQAlVV1 )->( VV1_RESERV ) $ "1/3" 	// Reservados
			cSitVei := "6"
		EndIf
	EndIf
	lOk := .t.
	Do Case
		Case cSitVei == "0" .and. MV_PAR01 <> 1 // Estoque na Empresa
			lOk := .f.
		Case cSitVei == "2" .and. MV_PAR02 <> 1 // Em Transito
			lOk := .f.
		Case cSitVei == "3" .and. MV_PAR03 <> 1 // Remessa
			lOk := .f.
		Case cSitVei == "4" .and. MV_PAR04 <> 1 // Consignado
			lOk := .f.
		Case cSitVei == "5" .and. MV_PAR05 <> 1 // Transferencia
			lOk := .f.
		Case cSitVei == "6" .and. MV_PAR06 <> 1 // Reservado
			lOk := .f.
	EndCase
	If lOk
		If cSitVei == "4"
			aRetVV0 := FM_VEIUMOV(( cQAlVV1 )->( VV1_CHASSI ),,) 		// Chassi
			If len(aRetVV0) > 0 .and. aRetVV0[1] == "S"
		   	( cQAlVV1 )->( DbSkip() )
				Loop
			EndIf
      EndIf
		aRetVVF := FM_VEIUMOV(( cQAlVV1 )->( VV1_CHASSI ),"E","0") 		// Chassi, E-Entrada, 0-Normal (OPEMOV)
		If len(aRetVVF) <= 0
			aRetVVF := FM_VEIUMOV(( cQAlVV1 )->( VV1_CHASSI ),"E",) 	// Chassi, E-Entrada
		EndIf
		If len(aRetVVF) > 0
			DbSelectArea("VVF") 
			DbSetOrder(1)
			DbSeek(aRetVVF[2]+aRetVVF[3]) // Filial + TRACPA
			if !Empty(mv_par08) .or. !empty(mv_par09)
	        	if VVF->VVF_DATMOV < mv_par08 .or. VVF->VVF_DATMOV > mv_par09
					( cQAlVV1 )->( DbSkip() )
		         Loop
				Endif   
	    	Endif       
			if !Empty(mv_par10)
	        	if (ddatabase-VVF->VVF_DATMOV) < mv_par10
			   	( cQAlVV1 )->( DbSkip() )
					Loop
		      Endif
	    	Endif
		    dDatMov := VVF->VVF_DATMOV
		Else
		    dDatMov := dDataBase
		EndIf
		nTotal++
		nPos := 0
		nPos := aScan(aTotSit,{|x| x[1] + x[2] == cSitVei + ( cQAlVV1 )->( VV1_ESTVEI ) })
		If nPos > 0
			aTotSit[nPos,3]++
		EndIf
		nPos := 0
		nPos := aScan(aTotMod,{|x| x[1] + x[2] + x[3] + x[4] == cSitVei + ( cQAlVV1 )->( VV1_ESTVEI ) + ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV2_DESMOD ) })
		If nPos == 0
			aAdd(aTotMod,{ cSitVei , ( cQAlVV1 )->( VV1_ESTVEI ) , ( cQAlVV1 )->( VV1_CODMAR ) , ( cQAlVV1 )->( VV2_DESMOD ) , 1 }) 
		Else
		 	aTotMod[nPos,5]++
		EndIf
		nPos := 0
		nPos := aScan(aGrpEst,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == cSitVei + ( cQAlVV1 )->( VV1_ESTVEI ) + ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV2_DESMOD ) + ( cQAlVV1 )->( VVC_DESCRI ) })
		If nPos == 0
			aAdd(aGrpEst,{ cSitVei , ( cQAlVV1 )->( VV1_ESTVEI ) , ( cQAlVV1 )->( VV1_CODMAR ) , ( cQAlVV1 )->( VV2_DESMOD ) , ( cQAlVV1 )->( VVC_DESCRI ) , 1 })
		Else
		 	aGrpEst[nPos,6]++
		EndIf
		cReserva := ""
		If (!Empty(( cQAlVV1 )->( VV1_DTHRES )).and.(ctod(substr(( cQAlVV1 )->( VV1_DTHVAL ),1,8)) > dDataBase)) .or. cSitVei == "3"
			aRetVV0 := FM_VEIUMOV(( cQAlVV1 )->( VV1_CHASSI ),"S","0") // Chassi, S-Saida, 0-Normal (OPEMOV)
			If len(aRetVV0) > 0
				DbSelectArea("VV0")
				DbSetOrder(1)
				DbSeek(aRetVV0[2]+aRetVV0[3]) // Filial + NUMTRA
				DbSelectArea("SA1") 
				DbSetOrder(1)
				DbSeek(xFilial("SA1") + VV0->VV0_CODCLI + VV0->VV0_LOJA )
				If (!Empty(( cQAlVV1 )->( VV1_DTHRES )).and.(ctod(substr(( cQAlVV1 )->( VV1_DTHVAL ),1,8)) > dDataBase))
					cReserva := "ate " + substr(( cQAlVV1 )->( VV1_DTHVAL ),1,8) + " " + left(SA1->A1_NOME,16)
				EndIf
			EndIf
		EndIf
		cFilAtu:= ""
		cQuery := "SELECT SB2.B2_FILIAL FROM "+RetSqlName("SB1")+" SB1 , "+RetSqlName("SB2")+" SB2 WHERE SB1.B1_COD=SB2.B2_COD AND SB2.B2_QATU > 0 AND "
		cQuery += "SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE='"+left(( cQAlVV1 )->( VV1_CHAINT )+space(30),len(SB1->B1_CODITE))+"' AND SB1.D_E_L_E_T_=' ' AND SB2.D_E_L_E_T_=' '"

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB2 , .F., .T. ) 
		If !( cQAlSB2 )->( Eof() )
			cFilAtu := ( cQAlSB2 )->( B2_FILIAL )
		EndIf
		( cQAlSB2 )->( dbCloseArea() )
		cAux := ""
		nPos := aScan(aFil,{|x| x[1] == cFilAtu })
		If nPos > 0
			cFilAtu += "-"+left(aFil[nPos,2]+space(15),15)
			If ( cQAlVV1 )->( VV1_ESTVEI ) =="0"
				aFil[nPos,3]++
			ElseIf ( cQAlVV1 )->( VV1_ESTVEI ) =="1"
				aFil[nPos,4]++
			EndIf
		Else
			If cSitVei == "3" .or. cSitVei == "5"
				aRetVV0 := FM_VEIUMOV(( cQAlVV1 )->( VV1_CHASSI ),,) // Chassi
				If len(aRetVV0) > 0 .and. aRetVV0[1] == "S"
					DbSelectArea("VV0")
					DbSetOrder(1)
					DbSeek(aRetVV0[2]+aRetVV0[3]) // Filial + NUMTRA
					nPos := aScan(aFil,{|x| x[1] == aRetVV0[2] })
					If nPos > 0
						cAux := aRetVV0[2]+"-"+left(aFil[nPos,2]+space(7),7)+" -> "
						DbSelectArea("SA1") 
						DbSetOrder(1)
						DbSeek(xFilial("SA1") + VV0->VV0_CODCLI + VV0->VV0_LOJA )
						If cSitVei == "3"
							cAux += VV0->VV0_CODCLI+"-"+VV0->VV0_LOJA+" "+left(SA1->A1_NOME,12)
						Else// cSitVei == "5"
							nPos := aScan(aFil,{|x| x[1] == substr(SA1->A1_CGC,11,2) })
							If nPos > 0
								cAux += substr(SA1->A1_CGC,11,2)+"-"+left(aFil[nPos,2]+space(7),7)
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				nPos := aScan(aSitVei,{|x| x[1] == cSitVei })
				If nPos > 0
					cFilAtu := left(aSitVei[nPos,2]+space(17),17)
					nPos := aScan(aFil,{|x| x[2] == cFilAtu })
					If nPos <= 0
						aAdd( aFil , { "  " , cFilAtu , 0 , 0 })
						nPos := len(aFil)
					EndIf
					If ( cQAlVV1 )->( VV1_ESTVEI ) =="0"
						aFil[nPos,3]++
					ElseIf ( cQAlVV1 )->( VV1_ESTVEI ) =="1"
						aFil[nPos,4]++
					EndIf
				EndIf
			EndIf
		EndIf
		aAdd(aNumEst,{ cSitVei , ( cQAlVV1 )->( VV1_ESTVEI ) , ( cQAlVV1 )->( VV1_CODMAR ) , ( cQAlVV1 )->( VV2_DESMOD ) , ( cQAlVV1 )->( VVC_DESCRI ) , ( cQAlVV1 )->( VV1_CHASSI ) , Transform(( cQAlVV1 )->( VV1_FABMOD ),"@R 9999/9999") , dDatMov , cReserva , Dtos(dDatMov), cAux , ( cQAlVV1 )->( VV1_PLAVEI ) , If(!Empty(cAux),cAux,cFilAtu) }) 
		If cSitVei == "0" .and. MV_PAR11 >= 2 .and. MV_PAR01 == 1
			nPos := 0
			nPos := aScan(aMod,{|x| x[1] + x[2] + x[3] + x[4] == left(cFilAtu,2) + ( cQAlVV1 )->( VV1_ESTVEI ) + ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV2_DESMOD ) })
			If nPos == 0
				aAdd(aMod,{ left(cFilAtu,2) , ( cQAlVV1 )->( VV1_ESTVEI ) , ( cQAlVV1 )->( VV1_CODMAR ) , ( cQAlVV1 )->( VV2_DESMOD ) , 1 }) 
			Else
			 	aMod[nPos,5]++
			EndIf
		EndIf
	EndIf
  	( cQAlVV1 )->( DbSkip() )
EndDo
( cQAlVV1 )->( dbCloseArea() )
cB := space(11)
@ nLin++ , 02 psay "============================================================================"
@ nLin++ , 06 psay STR0009 +"  " + Transform(nTotal,"@E 9999,999,999") //T  O  T  A  L       E  M       E  S  T  O  Q  U  E 
@ nLin++ , 02 psay "============================================================================"
nLin++
@ nLin++ , 02 psay "==========================================="+IIF(MV_PAR07<=2,"= "+STR0010+" ","========")+"==="+IIF(MV_PAR07==1.or.MV_PAR07==3," "+STR0011+" ","========")+"==== "+STR0012+" ==="//NOVOS # USADOS # TOTAL
If MV_PAR01==1
	@ nLin++ , 03 psay left(STR0013 +space(38),38)+IIF(MV_PAR07<=2,Transform(aTotSit[1,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aTotSit[2,3],"@E 999,999,999"),cB)+Transform(aTotSit[1,3]+aTotSit[2,3],"@E 999,999,999")//[A] EM ESTOQUE NA EMPRESA
EndIf                             
If MV_PAR02==1
	@ nLin++ , 03 psay left(STR0014 +space(38),38)+IIF(MV_PAR07<=2,Transform(aTotSit[3,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aTotSit[4,3],"@E 999,999,999"),cB)+Transform(aTotSit[3,3]+aTotSit[4,3],"@E 999,999,999")//[B] EM TRANSITO
EndIf                             
If MV_PAR03==1
	@ nLin++ , 03 psay left(STR0015 +space(38),38)+IIF(MV_PAR07<=2,Transform(aTotSit[5,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aTotSit[6,3],"@E 999,999,999"),cB)+Transform(aTotSit[5,3]+aTotSit[6,3],"@E 999,999,999")//[C] REMESSA
EndIf                             
If MV_PAR04==1
	@ nLin++ , 03 psay left(STR0016 +space(38),38)+IIF(MV_PAR07<=2,Transform(aTotSit[7,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aTotSit[8,3],"@E 999,999,999"),cB)+Transform(aTotSit[7,3]+aTotSit[8,3],"@E 999,999,999")//[D] CONSIGNADOS
EndIf                             
If MV_PAR05==1
	@ nLin++ , 03 psay left(STR0017 +space(38),38)+IIF(MV_PAR07<=2,Transform(aTotSit[9,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aTotSit[10,3],"@E 999,999,999"),cB)+Transform(aTotSit[9,3]+aTotSit[10,3],"@E 999,999,999")//[E] TRANSFERENCIA
EndIf                             
If MV_PAR06==1
	@ nLin++ , 03 psay left(STR0018 +space(38),38)+IIF(MV_PAR07<=2,Transform(aTotSit[11,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aTotSit[12,3],"@E 999,999,999"),cB)+Transform(aTotSit[11,3]+aTotSit[12,3],"@E 999,999,999")//[F] RESERVADOS
EndIf                             
@ nLin++ , 02 psay "============================================================================"
nLin++
@ nLin++ , 06 psay STR0019 +IIF(MV_PAR07<=2,"  "+STR0010+" ","        ")+"   "+IIF(MV_PAR07==1.or.MV_PAR07==3," "+STR0011+" ","        ")+"     "+STR0012 //TOTAL POR FILIAL  # NOVOS # USADOS # TOTAL
nLin++                           
For nPos := 1 to len(aFil)
	@ nLin++ , 08 psay aFil[nPos,1]+" - "+aFil[nPos,2]+space(11)+IIF(MV_PAR07<=2,Transform(aFil[nPos,3],"@E 999,999,999"),cB)+IIF(MV_PAR07==1.or.MV_PAR07==3,Transform(aFil[nPos,4],"@E 999,999,999"),cB)+Transform(aFil[nPos,3]+aFil[nPos,4],"@E 999,999,999")
Next
aSort(aNumEst,1,,{|x,y| x[2]+x[1]+x[3]+x[4]+x[5]+x[10]+x[6] < y[2]+y[1]+y[3]+y[4]+y[5]+y[10]+y[6] })
cSitVei  := "INICIAR"
cQuebra  := "INICIAR"
cQuebMod := "INICIAR"
For ni:=1 to len(aNumEst)
   If cSitVei # aNumEst[ni,1]+aNumEst[ni,2]
		cSitVei := aNumEst[ni,1]+aNumEst[ni,2]
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1
		@ nLin++ , 01 psay cTracos
		Do Case
	   	Case cSitVei == "00"
			   @ nLin++ , 02 psay 	STR0020 + Transform(aTotSit[1,3],"@E 99,999,999") 	//***  NOVOS - [A] EM ESTOQUE NA EMPRESA  ***                 Total:
				cTitEst := 			STR0021                                        		//***  NOVOS - [A] EM ESTOQUE NA EMPRESA  ***                   Continuacao...
	   		Case cSitVei == "01"
				@ nLin++ , 02 psay STR0022 + Transform(aTotSit[2,3],"@E 99,999,999")	//***  USADOS - [A] EM ESTOQUE NA EMPRESA  ***                Total:
				cTitEst := STR0023                                        				//***  USADOS - [A] EM ESTOQUE NA EMPRESA  ***                  Continuacao...
			Case cSitVei == "20"
				@ nLin++ , 02 psay STR0024 + Transform(aTotSit[3,3],"@E 99,999,999")	//***  NOVOS - [B] EM TRANSITO  ***                           Total:
				cTitEst := STR0025                                        				//***  NOVOS - [B] EM TRANSITO  ***                             Continuacao...
			Case cSitVei == "21"
				@ nLin++ , 02 psay STR0026 + Transform(aTotSit[4,3],"@E 99,999,999")	//***  USADOS - [B] EM TRANSITO  ***                          Total:
				cTitEst := STR0027                                        				//***  USADOS - [B] EM TRANSITO  ***                            Continuacao...
			Case cSitVei == "30"
				@ nLin++ , 02 psay STR0028 + Transform(aTotSit[5,3],"@E 99,999,999")	//***  NOVOS - [C] REMESSA  ***                               Total:
				cTitEst := STR0029                                         				//***  NOVOS - [C] REMESSA  ***                                 Continuacao...
			Case cSitVei == "31"
		 		@ nLin++ , 02 psay STR0030 + Transform(aTotSit[6,3],"@E 99,999,999")	//***  USADOS - [C] REMESSA  ***                              Total:
				cTitEst := STR0031                                        				//***  USADOS - [C] REMESSA  ***                                Continuacao...
			Case cSitVei == "40"
		   		@ nLin++ , 02 psay STR0032 + Transform(aTotSit[7,3],"@E 99,999,999")	//***  NOVOS - [D] CONSIGNADOS  ***                           Total:
				cTitEst := STR0033                                        				//***  NOVOS - [D] CONSIGNADOS  ***                             Continuacao...
			Case cSitVei == "41"
			   	@ nLin++ , 02 psay STR0034 + Transform(aTotSit[8,3],"@E 99,999,999")	//***  USADOS - [D] CONSIGNADOS  ***                          Total:
				cTitEst := STR0035                                        				//***  USADOS - [D] CONSIGNADOS  ***                            Continuacao...
			Case cSitVei == "50"
		   		@ nLin++ , 02 psay STR0036 + Transform(aTotSit[7,3],"@E 99,999,999")	//***  NOVOS - [E] TRANSFERENCIA  ***                         Total:
				cTitEst := STR0037                                       				//***  NOVOS - [E] TRANSFERENCIA  ***                           Continuacao...
			Case cSitVei == "51"
			   	@ nLin++ , 02 psay STR0038 + Transform(aTotSit[8,3],"@E 99,999,999")	//***  USADOS - [E] TRANSFERENCIA  ***                        Total:
				cTitEst := STR0039                                        				//***  USADOS - [E] TRANSFERENCIA  ***                          Continuacao...
			Case cSitVei == "60"
				@ nLin++ , 02 psay STR0040 + Transform(aTotSit[11,3],"@E 99,999,999")	//***  NOVOS - [F] RESERVADOS  ***                            Total:
				cTitEst := STR0041                                       				//***  NOVOS - [F] RESERVADOS  ***                              Continuacao...
			Case cSitVei == "61"
			 	@ nLin++ , 02 psay STR0042 + Transform(aTotSit[12,3],"@E 99,999,999")	//***  USADOS - [F] RESERVADOS  ***                           Total:
				cTitEst := STR0043                                        				//***  USADOS - [F] RESERVADOS  ***                             Continuacao...
		EndCase
		@ nLin++ , 01 psay cTracos
	EndIf
	If ( cQuebMod # ( aNumEst[ni,1]+aNumEst[ni,2]+aNumEst[ni,3]+aNumEst[ni,4] ))
		cQuebMod := ( aNumEst[ni,1]+aNumEst[ni,2]+aNumEst[ni,3]+aNumEst[ni,4] )
		If nLin > 53
			nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
			@ nLin++ , 01 psay cTracos
		 	@ nLin++ , 02 psay cTitEst
			@ nLin++ , 01 psay cTracos
		EndIf
		nPos := 0
		nPos := aScan(aTotMod,{|x| x[1] + x[2] + x[3] + x[4] == cQuebMod })
		If MV_PAR11 >= 2
			nLin++
		EndIf
	  	@ nLin++ , 01 psay aTotMod[nPos,3] + " " + aTotMod[nPos,4] + STR0044 + Transform(aTotMod[nPos,5],"@E 99,999,999")  //Total do Modelo:
	EndIf
	If MV_PAR11 >= 2
		If ( cQuebra # ( aNumEst[ni,1]+aNumEst[ni,2]+aNumEst[ni,3]+aNumEst[ni,4]+aNumEst[ni,5] ))
			cQuebra := ( aNumEst[ni,1]+aNumEst[ni,2]+aNumEst[ni,3]+aNumEst[ni,4]+aNumEst[ni,5] )
		  	If nLin > 56
				nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				@ nLin++ , 01 psay cTracos
			  	@ nLin++ , 02 psay cTitEst
				@ nLin++ , 01 psay cTracos
			EndIf
			nPos := 0
			nPos := aScan(aGrpEst,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == cQuebra }) 
			If MV_PAR11 == 3
				nLin++
			EndIf
			@ nLin++ , 01 psay Transform(aGrpEst[nPos,6],"@E 99,999") + " " + aGrpEst[nPos,5]
		EndIf
		If MV_PAR11 == 3
			If nLin > 59
				nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				@ nLin++ , 01 psay cTracos
				@ nLin++ , 02 psay cTitEst
				@ nLin++ , 01 psay cTracos
				nLin++
			EndIf
			If aNumEst[ni,2] == "0"
				@ nLin++ , 08 psay aNumEst[ni,6] +" "+ aNumEst[ni,7] +" "+ If(aNumEst[ni,1]=="3",aNumEst[ni,11], If(Empty(aNumEst[ni,9]),Transform(dDataBase-aNumEst[ni,8],"@E 9,999") + " "+ STR0045 +"  "+aNumEst[ni,13],aNumEst[ni,9])) //dIAS
			Else
				@ nLin++ , 08 psay left(aNumEst[ni,6],20) +" "+ Transform(aNumEst[ni,12],"@R AAA-9999") +" "+ aNumEst[ni,7] +" "+ If(aNumEst[ni,1]=="3",aNumEst[ni,11], If(Empty(aNumEst[ni,9]),Transform(dDataBase-aNumEst[ni,8],"@E 9,999") + " "+ STR0045 +"  "+aNumEst[ni,13],aNumEst[ni,9]))//dIAS
			EndIf
		EndIf
	EndIf
Next
If MV_PAR11 >= 2 .and. MV_PAR01 == 1
	aSort(aNumEst,1,,{|x,y| x[1]+left(x[13],2)+x[2]+x[3]+x[4]+x[6]+x[5] < y[1]+left(y[13],2)+y[2]+y[3]+y[4]+y[6]+y[5] })
	cSitVei  := "INICIAR"
	cQuebra  := "INICIAR"
	cQuebMod := "INICIAR"
	nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1
	@ nLin++ , 02 psay STR0046 + Transform(aTotSit[1,3]+aTotSit[2,3],"@E 99,999,999")//***  [A] EM ESTOQUE NA EMPRESA  ***                         Total:
	For ni:=1 to len(aNumEst)            
		If aNumEst[ni,1] == "0"
	        If cQuebra # left(aNumEst[ni,13],2)
				cQuebra := left(aNumEst[ni,13],2)
				nLin++
				If nLin > 55
					nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				EndIf
				nPos := 0
				nPos := aScan(aFil,{|x| x[1] == cQuebra })
				If nPos > 0
					@ nLin++ , 03 psay left(aFil[nPos,1]+" - "+aFil[nPos,2]+space(65),65)+Transform(aFil[nPos,3]+aFil[nPos,4],"@E 99,999,999")
				EndIf
				cSitVei := "INICIAL"
			EndIf
			If cSitVei # aNumEst[ni,2]
				cSitVei := aNumEst[ni,2]
				If nLin > 56
					nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				EndIf
				nPos := 0
				nPos := aScan(aFil,{|x| x[1] == cQuebra })
				If nPos > 0
					If cSitVei == "0"
						@ nLin++ , 05 psay left(STR0010 +space(63),63)+Transform(aFil[nPos,3],"@E 99,999,999")//NOVOS
				  	Else//If cSitVei == "1"
						@ nLin++ , 05 psay left(STR0011 +space(63),63)+Transform(aFil[nPos,4],"@E 99,999,999")//USADOS
					EndIf
				EndIf
				cQuebMod := "INICIAR"
			EndIf
			If cQuebMod # aNumEst[ni,3]+aNumEst[ni,4]
				cQuebMod := aNumEst[ni,3]+aNumEst[ni,4]
				If nLin > 57
					nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				EndIf
				nPos := 0
				nPos := aScan(aMod,{|x| x[1] + x[2] + x[3] + x[4] == left(aNumEst[ni,13],2) + aNumEst[ni,2] + cQuebMod })
				@ nLin++ , 07 psay left(cQuebMod+space(61),61)+IIf(nPos>0,Transform(aMod[nPos,5],"@E 99,999,999"),"")
			EndIf
			If MV_PAR11 == 3
				If nLin > 59
					nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				EndIf
				If cSitVei == "0"
					@ nLin++ , 09 psay aNumEst[ni,6] +" "+ aNumEst[ni,7] +" "+ If(Empty(aNumEst[ni,9]),Transform(dDataBase-aNumEst[ni,8],"@E 9,999") + " "+ STR0045 +" "+left(aNumEst[ni,5],16),aNumEst[ni,9]) //dIAS
			  	Else//If cSitVei == "1"
					@ nLin++ , 09 psay left(aNumEst[ni,6],20) +" "+ Transform(aNumEst[ni,12],"@R AAA-9999") +" "+ aNumEst[ni,7] +" "+ If(Empty(aNumEst[ni,9]),Transform(dDataBase-aNumEst[ni,8],"@E 9,999") + " "+ STR0045 +" "+left(aNumEst[ni,5],16),aNumEst[ni,9])//dIAS
				EndIf
			EndIf
		EndIf
	Next
EndIf
Set Printer to
Set Device to Screen
Return
/* rafael 02/01/09
Static Function ValidPerg()
Local i := 0 
Local j := 0
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,len(SX1->X1_GRUPO))
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01",STR0047,"","","mv_ch1","N",1,0,0,"C","","mv_par01",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","","","","","",""})			//Estoque na Empresa # Mostrar # Nao Mostrar
AADD(aRegs,{cPerg,"02",STR0050,"","","mv_ch2","N",1,0,0,"C","","mv_par02",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","","","","","",""})			//Em Transito # Mostrar # Nao Mostrar
AADD(aRegs,{cPerg,"03",STR0051,"","","mv_ch3","N",1,0,0,"C","","mv_par03",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","","","","","",""})			//Remessa # Mostrar # Nao Mostrar
AADD(aRegs,{cPerg,"04",STR0052,"","","mv_ch4","N",1,0,0,"C","","mv_par04",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","","","","","",""})			//Consignados # Mostrar # Nao Mostrar
AADD(aRegs,{cPerg,"05",STR0053,"","","mv_ch5","N",1,0,0,"C","","mv_par05",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","","","","","",""})			//Transferencia # Mostrar # Nao Mostrar
AADD(aRegs,{cPerg,"06",STR0054,"","","mv_ch6","N",1,0,0,"C","","mv_par06",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","","","","","",""})			//Reservados # Mostrar # Nao Mostrar
AADD(aRegs,{cPerg,"07",STR0055,"","","mv_ch7","N",1,0,0,"C","","mv_par07",STR0056,"","","","",STR0057,"","","","",STR0058,"","","","","","","","","","","","","","","","","","",""})	//Estado: Novos/Usados  # Todos # Novos # Usados
AADD(aRegs,{cPerg,"08",STR0059,"","","mv_ch8","D",8,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})					//Dt Inicial Entr.Compra"
AADD(aRegs,{cPerg,"09",STR0060,"","","mv_ch9","D",8,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})					//Dt Final Entr.Compra  
AADD(aRegs,{cPerg,"10",STR0061,"","","mv_cha","N",3,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})					//Qtd Min. dias Entr.Compra
AADD(aRegs,{cPerg,"11",STR0062,"","","mv_chb","N",1,0,0,"C","","mv_par11",STR0063,"","","","",STR0064,"","","","",STR0065,"","","","","","","","","","","","","","","","","","",""})	//Tipo de Relatorio # Resumido # Sintetico # Analitico
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
//    dbSeek(cPerg+aRegs[i,2])
//		RecLock("SX1",!found())
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	EndIf
Next

dbSelectArea(_sAlias)
Return
*/