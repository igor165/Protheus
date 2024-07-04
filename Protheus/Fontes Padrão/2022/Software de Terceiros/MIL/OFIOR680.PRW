#Include "OFIOR680.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ OFIOR680 ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  12/09/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Estoque / Transito / Progresso de Veiculos                 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ MIL                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIOR680
Private cTitulo := STR0001 //Veiculos ( Estoque / Transito / Progresso )"
Private cDesc1  := cTitulo
Private cDesc2  := ""
Private cDesc3  := ""
Private cNomeRel:= "OFIOR680"
Private cPerg   := "OFR680"
Private cAlias  := "VV1"
Private cabec1  := STR0002 	//Pedido     DtPedido Dt.Progr Modelo do Veiculo    Cor    Chassi            Fabr/Mod. DEst DFat Comb. NFComp DtCompra  Vlr.Compra Vlr.Publico Opcionais               TPg Atendimento(Usuario/Nro/Cliente)"
Private cabec2  := ""
Private nLin    := 1
Private aPag    := 1
Private m_Pag   := 1
Private aReturn := { STR0003, 1,STR0004, 2, 2, 1, "",1 }  //Zebrado # Administracao
Private cTamanho:= "G" 		// P/M/G
Private Limite  := 220 		// 80/132/220
Private aOrdem  := {}
Private nLastKey:= 0
Private nCaracter:= 15

//	ValidPerg()
	PERGUNTE(cPerg,.f.)
	DbSelectArea("VE1")
	DbSetOrder(1)
	DbSeek( xFilial("VE1") + MV_PAR01 )
	cNomeRel:=SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
	cTitulo := Alltrim(cTitulo)+" - "+Transform(dDataBase,"@D")
	If nLastKey == 27
		Return
	Endif
	PERGUNTE(cPerg,.f.)
	SetDefault(aReturn,cAlias)
	RptStatus( { |lEnd| FS_OFR680(@lEnd,cNomeRel,cAlias) } , cTitulo )
	If aReturn[5] == 1
	   OurSpool( cNomeRel )
	EndIf
	MS_Flush()

Return

Static Function FS_OFR680
#IFDEF TOP
	Local cQuery  := ""
	Local cQAlVV1 := "SQLVV1"
	Local cQAlVV9 := "SQLVV9"
	Local nj      := 0
	Local ni      := 0
	Local cTip    := "1"
	Local cComb   := ""
	Local aComb   := X3CBOXAVET("VV1_COMVEI","0")
	Local nTam    := 0
	Local cImp    := ""
	Local aImp    := {}
	Local cNumNFI := space(15)
	Local cFabMod := space(9)
	Local nVlrCom := 0
	Local cCorVei := space(6)
	Local nVlrPub := 0
	Local nDiaEst := 0
	Local nDiaFat := 0
	Local cAtend  := ""
	Local cQuebra := ""
	Local nQuebra := 0
	Local nTotal  := 0
	cQuery := "SELECT VV1.* , VV2.VV2_SEGMOD , VV2.VV2_DESMOD FROM "+RetSqlName("VV1")+" VV1 INNER JOIN "+RetSqlName("VV2")+" VV2 "
	cQuery += "ON VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI "
	cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
	If MV_PAR04 == 1 			// Todos
		cQuery += "VV1.VV1_SITVEI IN ('0','3','4','6','2','7') AND "
	Else
	 	If MV_PAR04 == 2 		// Estoque de Veiculos
			cQuery += "VV1.VV1_SITVEI IN ('0','3','4','6') AND "
		ElseIf MV_PAR04 == 3 	// Transito
			cQuery += "VV1.VV1_SITVEI='2' AND "
		ElseIf MV_PAR04 == 4 	// Progresso de Veiculos
			cQuery += "VV1.VV1_SITVEI='7' AND "
		EndIf
	EndIf
	If !Empty(MV_PAR01)
		cQuery += "VV1.VV1_CODMAR='"+MV_PAR01+"' AND "
	EndIf
	If !Empty(MV_PAR02)
		cQuery += "VV2.VV2_GRUMOD='"+MV_PAR02+"' AND "
	EndIf
	If !Empty(MV_PAR03)
		cQuery += "VV1.VV1_MODVEI='"+MV_PAR03+"' AND "
	EndIf
	If !Empty(MV_PAR07)
		cQuery += "VV1.VV1_DATPED>='"+dtos(MV_PAR07)+"' AND "
	EndIf
	If !Empty(MV_PAR08)
		cQuery += "VV1.VV1_DATPED<='"+dtos(MV_PAR08)+"' AND "
	EndIf
	If !Empty(MV_PAR09)
		cQuery += "VV1.VV1_DATPRO>='"+dtos(MV_PAR09)+"' AND "
	EndIf
	If !Empty(MV_PAR10)
		cQuery += "VV1.VV1_DATPRO<='"+dtos(MV_PAR10)+"' AND "
	EndIf
	cQuery += "VV1.D_E_L_E_T_=' ' AND VV2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "
	If MV_PAR11 == 1 			// Ordem: Modelo Veiculo
		cQuery += "VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_DATPED , VV1.VV1_PEDFAB , "
	ElseIf MV_PAR11 == 2 		// Ordem: Pedido
		cQuery += "VV1.VV1_PEDFAB , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_DATPED , "
	ElseIf MV_PAR11 == 3 		// Ordem: Dt.Pedido
		cQuery += "VV1.VV1_DATPED , VV1.VV1_PEDFAB , VV1.VV1_CODMAR , VV1.VV1_MODVEI , "
	ElseIf MV_PAR11 == 4 		// Ordem: Dt.Program
		cQuery += "VV1.VV1_DATPRO , VV1.VV1_DATPED , VV1.VV1_PEDFAB , VV1.VV1_CODMAR , VV1.VV1_MODVEI , "
	EndIf
	cQuery += "VV1.VV1_CORVEI , VV1.VV1_CHASSI "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. ) 
	If !( cQAlVV1 )->( Eof() )
		ProcRegua( int( ( cQAlVV1 )->( RecCount() ) / 100 ) + 3 )
		IncProc( STR0005 )									//Levantando Veiculos...
		Do While !( cQAlVV1 )->( Eof() )
			ni++
			If ni == 100
				ni := 0
				IncProc( STR0005 )		   					//Levantando Veiculos...
			EndIf
			If ( cQAlVV1 )->( VV1_SITVEI ) == "2" 	   		// Transito
				cTip := "20"
			ElseIf ( cQAlVV1 )->( VV1_SITVEI ) == "7" 		// Progresso de Veiculos
				cTip := "30"
			Else // ( cQAlVV1 )->( VV1_SITVEI ) $ "0/3/4/6" // Estoque de Veiculos
				cTip := "1" + ( cQAlVV1 )->( VV1_SITVEI )
			EndIf
			cFabMod := space(9)
			cComb   := space(5)
			cCond   := space(3)
			cNumNFI := space(18)
			cCorVei := ( cQAlVV1 )->( VV1_CORVEI )
			cAtend  := ""
	      nTam    := 0
			nVlrPub := 0
			nVlrCom := 0
	      nDiaEst := 0
	      nDiaFat := 0
			If len(Alltrim(cCorVei)) < 5
				DbSelectArea("VVC")
				DbSetOrder(1)
				If DbSeek( xFilial("VVC") + ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV1_CORVEI ) )
					cCorVei := left(Alltrim(( cQAlVV1 )->( VV1_CORVEI ))+"-"+VVC->VVC_DESCRI,6)
				EndIf
			EndIf
	      If !Empty(( cQAlVV1 )->( VV1_FABMOD ))
				cFabMod := Transform(( cQAlVV1 )->( VV1_FABMOD ),"@R 9999/9999")
			EndIf
			nTam := aScan(aComb,{|x| x[1] == ( cQAlVV1 )->( VV1_COMVEI ) })
			If nTam > 0
				cComb := left(aComb[nTam,1]+"-"+aComb[nTam,2]+space(5),5)
			EndIf
			If MV_PAR06 == 1
				nVlrPub := VV1->VV1_SUGVDA
				If nVlrPub == 0
					DbSelectArea("VVP")
					DbSetOrder(1)
					DbSeek( xFilial("VVP") + ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV1_MODVEI ) + ( cQAlVV1 )->( VV2_SEGMOD ) + DTOS(dDataBase) , .t. )
					If ( ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV1_MODVEI ) + ( cQAlVV1 )->( VV2_SEGMOD ) # VVP->VVP_FILIAL + VVP->VVP_CODMAR + VVP->VVP_MODVEI + VVP->VVP_SEGMOD ) .or. ( VVP->VVP_DATPRC > dDataBase )
						If !Bof()
							DbSelectArea("VVP")
							DbSkip(-1)
						EndIf
					EndIf
					If ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV1_MODVEI ) + ( cQAlVV1 )->( VV2_SEGMOD ) == VVP->VVP_FILIAL + VVP->VVP_CODMAR + VVP->VVP_MODVEI + VVP->VVP_SEGMOD
						nVlrPub := VVP->VVP_VALTAB
					EndIf
				EndIf
	      EndIf
	      If !Empty(( cQAlVV1 )->( VV1_TRACPA ))
				DbSelectArea("VVF")
				DbSetOrder(1)
				If DbSeek( xFilial("VVF") + ( cQAlVV1 )->( VV1_TRACPA ) )
					If MV_PAR05 == 1
						nVlrCom := VVF->VVF_VALMOV
					EndIf
					If !Empty(VVF->VVF_DATMOV) 		// Data Entrada Estoque
						nDiaEst := dDataBase - VVF->VVF_DATMOV
						If dDataBase == VVF->VVF_DATMOV
							nDiaEst := 1
						EndIf
					EndIf
					If !Empty(VVF->VVF_DATEMI) 		// Data Faturamento Fabrica
						nDiaFat := dDataBase - VVF->VVF_DATEMI
						If dDataBase == VVF->VVF_DATEMI
							nDiaFat := 1
						EndIf
					EndIf
					cNumNFI:= VVF->VVF_NUMNFI+" "+If(!Empty(VVF->VVF_DATEMI),Transform(VVF->VVF_DATEMI,"@D"),space(8))
					cCond  := VVF->VVF_FORPAG
				EndIf
			EndIf
			If !Empty(( cQAlVV1 )->( VV1_PEDFAB ))
				cQuery := "SELECT VV9.VV9_NUMATE , VV9.VV9_USUARI , SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME "
				cQuery += "FROM "+RetSqlName("VV9")+" VV9 , "+RetSqlName("SA1")+" SA1 "	
				cQuery += "WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND "
				cQuery += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
				cQuery += "VV9.VV9_PEDFAB='"+( cQAlVV1 )->( VV1_PEDFAB )+"' AND "
				cQuery += "VV9.VV9_CODCLI=SA1.A1_COD AND VV9.VV9_LOJA=SA1.A1_LOJA AND "
				cQuery += "VV9.D_E_L_E_T_=' ' AND SA1.D_E_L_E_T_=' '"

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV9, .F., .T. ) 
				If !( cQAlVV9 )->( Eof() )
					cAtend := left(UsrRetName(( cQAlVV9 )->( VV9_USUARI )),11)+" "+left(( cQAlVV9 )->( VV9_NUMATE )+" "+( cQAlVV9 )->( A1_COD )+"-"+( cQAlVV9 )->( A1_LOJA )+" "+( cQAlVV9 )->( A1_NOME ),38)
				EndIf
				( cQAlVV9 )->( dbCloseArea() )
			EndIf
			nj++
			cImp := left(( cQAlVV1 )->( VV1_PEDFAB ),10)+" "+Transform(stod(( cQAlVV1 )->( VV1_DATPED )),"@D")+" "+Transform(stod(( cQAlVV1 )->( VV1_DATPRO )),"@D")+" "+;
										left(Alltrim(( cQAlVV1 )->( VV1_MODVEI ))+"-"+( cQAlVV1 )->( VV2_DESMOD )+space(20),20)+" "+cCorVei+" "+;
										left(( cQAlVV1 )->( VV1_CHASSI ),17) +" "+ cFabMod +	Transform(nDiaEst,"@EZ 99999")+Transform(nDiaFat,"@EZ 99999")+" "+cComb+" "+cNumNFI+;
										Transform(nVlrCom,"@EZ 9,999,999.99")+Transform(nVlrPub,"@EZ 9,999,999.99")+" "+left( Alltrim( ( cQAlVV1 )->( VV1_OPCFAB ) ) + space(23) , 23 )
			aAdd(aImp,{cTip,strzero(nj,10),cImp+" "+cCond+" "+cAtend})
		  	( cQAlVV1 )->( DbSkip() )
		EndDo
	EndIf
	( cQAlVV1 )->( dbCloseArea() )
	If len(aImp) > 0
		aSort(aImp,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		For ni := 1 to len(aImp)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
			EndIf
			If cQuebra # aImp[ni,1]
				If !Empty(cQuebra)
				   nLin++
					@nLin++ , 00 Psay left(STR0006 +" "+cTip+repl(".",45),45)+":"+Transform(nQuebra,"@E 999,999,999") //Total de
					nLin++
					nQuebra := 0
				EndIf
			   cQuebra := aImp[ni,1]
			   cTip := ""
				Do Case
					Case aImp[ni,1] == "10"
						cTip := STR0007		//Estoque de Veiculos
					Case aImp[ni,1] == "13"
						cTip := STR0008		//Estoque de Veiculos - Remessa
					Case aImp[ni,1] == "14"
						cTip := STR0009		//Estoque de Veiculos - Consignado
					Case aImp[ni,1] == "20"
						cTip := STR0010		//Veiculos em Transito
					Case aImp[ni,1] == "30"
						cTip := STR0011		//Veiculos em Progresso
				EndCase
				@nLin++ , 00 Psay "<<< "+cTip+" >>>"
				nLin++
			EndIf
			@nLin++ , 00 Psay aImp[ni,3]
			nQuebra++
			nTotal++
		Next
		nLin++
		@nLin++ , 00 Psay left(STR0006 +" "+cTip+repl(".",45),45)+":"+Transform(nQuebra,"@E 999,999,999")  	//Total de
		nLin++
		@nLin++ , 00 Psay left(STR0012 +repl(".",45),45)+":"+Transform(nTotal,"@E 999,999,999") 			//Total Geral de Veiculos
	EndIf
#ENDIF
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫ FunáÑo ≥ VALIDPERG ∫ MP8 ∫ Data ≥ 13/07/01 ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ValidPerg
local _sAlias := Alias()
local aRegs := {}
local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Marca do Veiculo" ,"","","mv_ch1","C",3,0,0,"G",'Vazio() .or. FG_SEEK("VE1","MV_PAR01",1,.F.)',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""})
aAdd(aRegs,{cPerg,"02","Grupo do Veiculo" ,"","","mv_ch2","C",6,0,0,"G",'Vazio() .or. FG_SEEK("VVR","MV_PAR01+MV_PAR02",2,.F.)',"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","VVR",""})
aAdd(aRegs,{cPerg,"03","Modelo do Veiculo","","","mv_ch3","C",30,0,0,"G",'Vazio() .or. FG_SEEK("VV2","MV_PAR01+MV_PAR03",1,.F.)',"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","V2R",""})
aAdd(aRegs,{cPerg,"04","Veiculos"         ,"","","mv_ch4","N",1,0,1,"C","","MV_PAR04","Todos","","","","","Em Estoque","","","","","Em Transito","","","","","Progresso","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Mostra Vlr.Compra","","","mv_ch5","N",1,0,1,"C","","MV_PAR05","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Mostra Vlr.Publico","","","mv_ch6","N",1,0,1,"C","","MV_PAR06","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Dt.Pedido Inicial","","","mv_ch7","D",8,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Dt.Pedido Final"  ,"","","mv_ch8","D",8,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Dt.Progr. Inicial","","","mv_ch9","D",8,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Dt.Progr. Final"  ,"","","mv_cha","D",8,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Ordem Relatorio"  ,"","","mv_chb","N",1,0,1,"C","","MV_PAR11","Modelo Veiculo","","","","","Cod.Pedido","","","","","Dt.Pedido","","","","","Dt.Program","","","","","","","","","",""})
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
*/
