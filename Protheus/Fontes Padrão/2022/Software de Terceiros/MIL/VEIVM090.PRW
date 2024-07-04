#Include "Protheus.ch"
#Include "Folder.ch"
#Include "Fileio.ch"
#Include "VEIVM090.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIVM090 º Autor ³ Manoel             º Data ³  17/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza e Emite Dados de Comissoes de Veiculos 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM090()

Local i
Private cAlias    := "VV0"
Private cDesc1    := STR0001 //Comissoes de Veiculos
Private cDesc2    := ""
Private cDesc3    := ""
Private aRegistros:= {}
Private nLin      := 0
Private cTitulo   := STR0001 //Comissoes de Veiculos
Private Titulo    := STR0001 //Comissoes de Veiculos
Private cNomeProg := "VEIVM090"
Private cNomeRel  := "VEIVM090"
Private nLastKey  := 0
Private nCaracter := 15
Private cabec1    := ""
Private cabec2    := ""
Private lAbortPrint := .f.
Private cString  := "VV0"
Private Li       := 80
Private m_Pag    := 1
Private wnRel    := "VEIVM090"
Private nPos     := 0
Private ni       := 0
Private aReturn  := { OemToAnsi(STR0003), 1,OemToAnsi(STR0002), 1, 1, 1, "",2 }		//1-ZEBRADO,2-,3-ADMINISTRACAO
Private aVetor   := {}
Private aHeader  := {}
Private aCols    := {}
Private cAliasVV0 := "SQLVV0"
Private aAlter    := {}
Private aNewBot := {}
Private dDatAnt := ""              // Antonio - FNC 2124/2010 - 03/03/2010

//aadd(aNewBot,{"IMPRESSAO" ,"FS_Imprime()",STR0004})
aadd(aNewBot,{"IMPRESSAO" ,"FS_ChImp()",STR0004}) //Imprime Comissoes
For i:=1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next
If !ExistDir("\logs\VEIVM090\")
	MontaDir("\logs\VEIVM090\")
EndIf
cPerg := "PVM090"

If !pergunte(cPerg,.t.)
	Return
Else
	Mv_Par01_1:=Mv_Par01
	Tamanho   := "M"
	limite    := 80
	//	cIndVV0 := CriaTrab(Nil, .F.)
	//	cChave  := "VV0_FILIAL+VV0_OPEMOV+Dtos(VV0_DATEMI)"
	//	IndRegua("VV0",cIndVV0,cChave,,,OemToAnsi("Aguarde... Indexando Arquivos...") )
	Processa( {|| FS_Levanta() } )
	//	If Mv_Par05 == 1 // Conferencia
	If Len(aVetor) > 0
		FS_TelConf()
	Else
		MsgInfo(STR0075,STR0076)
	EndIf
	//	Else // Fechamento
	//		Processa( {|| FS_Imprime() } )
	//	Endif
Endif

#IFNDEF TOP
	//   If File(cIndVV0+OrdBagExt())
	//      fErase(cIndVV0+OrdBagExt())
	//   Endif
#ENDIF

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LEVANTAº Autor ³ Manoel             º Data ³  17/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Levantamento dos Dados de Comissoes de Veiculos 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Levanta()

Private cTipAva := "1"   //Veiculos
Private cCpoDiv := "    1"


// Armazena dados da impressao
aVetor := {}
// 1o Elemento - Modalidade
// 2o Elemento - Codigo do Vendedor
// 3o Elemento - Vendedor
// 4o Elemento - Data da Venda
// 5o Elemento - NF e Serie
// 6o Elemento - Cliente
// 7o Elemento - Modelo do Veiculo
// 8o Elemento - Chassi do Veiculo
// 9o Elemento - Valor Negociado
//10o Elemento - Valor Base da Comissao Vendedor
//11o Elemento - Percentual de Comissao Vendedor
//12o Elemento - Valor da Comissao do Vendedor
//13o Elemento - Valor Base da Comissao Superior
//14o Elemento - Percentual de Comissao Superior
//15o Elemento - Valor da Comissao do Superior
//16o Elemento - Data de Pagamento da Comissao ao Vendedor
//17o Elemento - Numero da Transacao

If Mv_Par06 == 1 // Comissoes nao pagas
	Mv_Par01 := Ctod("01/01/08")
Endif

If FieldPos("VV0_NNFCOM") == 0
	cQuery := "SELECT VV0.VV0_OPEMOV, VV0.VV0_NNFFDI , VV0.VV0_SNFFDI , VV0.VV0_DATMOV,VV0.VV0_CODCLI,VV0.VV0_LOJA,VV0.VV0_CODVEN,VV0.VV0_NUMNFI,VV0.VV0_SERNFI,VV0.VV0_MODVDA,VV0.VV0_TIPFAT,VV0.VV0_DPGVEN,VV0.VV0_VALNEG,VV0.VV0_NUMTRA,VVA.VVA_NUMTRA,VVA.VVA_LUCLQ1,VVA.VVA_LUCLQ2,VVA.VVA_COMVDE,VVA.VVA_COMGER,VVA.VVA_CHASSI,VV1.VV1_TRACPA,VV1.VV1_CHASSI,VV1.VV1_ESTVEI,VV1.VV1_MODVEI "
	cQuery += "FROM "
	cQuery += RetSqlName( "VV0" ) + " VV0 , "+RetSqlName( "VVA" ) + " VVA , "+RetSqlName( "VV1" ) + " VV1 "
	cQuery += "WHERE "
	cQuery += "VV0.VV0_FILIAL='"+ xFilial("VV0")+ "' AND (VV0.VV0_OPEMOV = '0' OR VV0.VV0_OPEMOV = '7') AND VV0.VV0_DATEMI >= '"+dtos(mv_par01)+"' AND VV0.VV0_DATEMI <= '"+dtos(mv_par02)+"' AND VV0.VV0_NUMNFI <> '         ' AND (((VV0.VV0_OPEMOV = '7') OR VV0.VV0_OPEMOV = '0')) AND (VV0.VV0_TIPFAT <> '2' OR VV0.VV0_AUTFAT = '1') AND VV0.VV0_SITNFI = '1' AND "
	if mv_par03 == 1
		if !Empty(mv_par04)
			cQuery += "VV0.VV0_CODVEN ='"+mv_par04+"' AND "
		Endif
		if mv_par06 == 1
			cQuery += "VV0.VV0_DPGVEN = '        ' AND "
		Elseif mv_par06 == 2
			cQuery += "VV0.VV0_DPGVEN <> '        ' AND "
		Endif
	Endif
Else
	cQuery := "SELECT VV0.VV0_OPEMOV,VV0.VV0_NNFCOM,VV0.VV0_NNFFDI , VV0.VV0_SNFFDI , VV0.VV0_SNFCOM,VV0.VV0_CLICSG,VV0.VV0_LOJCSG,VV0.VV0_DATMOV,VV0.VV0_CODCLI,VV0.VV0_LOJA,VV0.VV0_CODVEN,VV0.VV0_NUMNFI,VV0.VV0_SERNFI,VV0.VV0_MODVDA,VV0.VV0_TIPFAT,VV0.VV0_DPGVEN,VV0.VV0_DPGSUP,VV0.VV0_DPGGER,VV0.VV0_VALNEG,VV0.VV0_HISPGC,VV0.VV0_NUMTRA,VVA.VVA_NUMTRA,VVA.VVA_LUCLQ1,VVA.VVA_LUCLQ2,VVA.VVA_COMVDE,VVA.VVA_COMGER,VVA.VVA_CPGVEN,VVA.VVA_CHASSI,VV1.VV1_TRACPA,VV1.VV1_CHASSI,VV1.VV1_ESTVEI,VV1.VV1_MODVEI "
	cQuery += "FROM "
	cQuery += RetSqlName( "VV0" ) + " VV0 , "+RetSqlName( "VVA" ) + " VVA , "+RetSqlName( "VV1" ) + " VV1 "
	cQuery += "WHERE "
	cQuery += "VV0.VV0_FILIAL='"+ xFilial("VV0")+ "' AND (VV0.VV0_OPEMOV = '0' OR VV0.VV0_OPEMOV = '7') AND VV0.VV0_DATEMI >= '"+dtos(mv_par01)+"' AND VV0.VV0_DATEMI <= '"+dtos(mv_par02)+"' AND VV0.VV0_NUMNFI <> '         ' AND (((VV0.VV0_OPEMOV = '7' AND VV0.VV0_NNFCOM <> '         ') OR VV0.VV0_OPEMOV = '0') OR VV0.VV0_OPEMOV = '0') AND (VV0.VV0_TIPFAT <> '2' OR VV0.VV0_AUTFAT = '1') AND VV0.VV0_SITNFI = '1' AND "
	if mv_par03 == 1
		if !Empty(mv_par04)
			cQuery += "VV0.VV0_CODVEN ='"+mv_par04+"' AND "
		Endif
		if mv_par06 == 1
			cQuery += "VV0.VV0_DPGVEN = '        ' AND "
		Elseif mv_par06 == 2
			cQuery += "VV0.VV0_DPGVEN <> '        ' AND "
		Endif
	Endif
EndIf
cQuery += "VV0.VV0_NUMTRA = VVA.VVA_NUMTRA AND VVA.VVA_CHAINT = VV1.VV1_CHAINT AND "
cQuery += "VV0.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV0, .T., .T. )

Do While !( cAliasVV0 )->( Eof() )
	
	IncProc(STR0005)		//Aguarde... Lendo Faturamentos de Veiculos...
	
	If ( cAliasVV0 )->VV0_OPEMOV == "7"
		DbSelectArea("SF2")
		DbSetOrder(1)
		If FieldPos("VV0_NNFCOM") == 0
			If DbSeek(xFilial("SF2")+( cAliasVV0 )->VV0_NUMNFI+( cAliasVV0 )->VV0_SERNFI)
				If SF2->F2_EMISSAO > Mv_Par02 .or. SF2->F2_EMISSAO < Mv_Par01
					exit
				Endif
				dDatMov := SF2->F2_EMISSAO
				cChavCli := ( cAliasVV0 )->VV0_CODCLI+( cAliasVV0 )->VV0_LOJA				
			Endif
		Else
			If DbSeek(xFilial("SF2")+( cAliasVV0 )->VV0_NNFCOM+( cAliasVV0 )->VV0_SNFCOM)
				If SF2->F2_EMISSAO > Mv_Par02 .or. SF2->F2_EMISSAO < Mv_Par01
					exit
				Endif
				dDatMov := SF2->F2_EMISSAO
				cChavCli := ( cAliasVV0 )->VV0_CLICSG+( cAliasVV0 )->VV0_LOJCSG
			EndIf
		EndIf
	Else
		If (stod(( cAliasVV0 )->VV0_DATMOV) > Mv_Par02 .and. ( cAliasVV0 )->VV0_OPEMOV != "0" )
			exit
		Endif
		dDatMov := stod(( cAliasVV0 )->VV0_DATMOV)
		cChavCli := ( cAliasVV0 )->VV0_CODCLI+( cAliasVV0 )->VV0_LOJA
	Endif
	
	dbSelectArea("SA1")
	DbSetOrder(1)
	dbseek(xFilial("SA1")+cChavCli)
	
	dbSelectArea("SA3")
	DbSetOrder(1)
	If Mv_Par03 == 1 // Vendedor
		dbseek(xFilial("SA3")+( cAliasVV0 )->VV0_CODVEN)
		cCodVen := ( cAliasVV0 )->VV0_CODVEN
		cNomVen := Left(SA3->A3_NOME,25)+" - "+( cAliasVV0 )->VV0_CODVEN
	Else // Supervisor ou Gerente
		dbseek(xFilial("SA3")+Mv_Par04)
		cCodVen := Mv_Par04
		cNomVen := Left(SA3->A3_NOME,25)+" - "+Mv_Par04
	Endif
	
	DbSelectArea("VVG")
	DbSetOrder(1)
	DbSeek(xFilial("VVG")+( cAliasVV0 )->VV1_TRACPA)
	
	DbSelectArea("VVF")
	DbSetOrder(1)
	DbSeek(xFilial("VVF")+VVG->VVG_TRACPA)
	
	cMod := STR0006		//Sem ModVda
	cNFSerie := ( cAliasVV0 )->VV0_NUMNFI+"-"+( cAliasVV0 )->VV0_SERNFI
	If ( cAliasVV0 )->VV0_MODVDA == "0"
		cMod := STR0007		//Novos Estq
		cNFSerie := ( cAliasVV0 )->VV0_NUMNFI+"-"+( cAliasVV0 )->VV0_SERNFI
	ElseIf ( cAliasVV0 )->VV0_MODVDA == "1"
		cMod := STR0008		//Semi-Novos
		cNFSerie := ( cAliasVV0 )->VV0_NUMNFI+"-"+( cAliasVV0 )->VV0_SERNFI
	ElseIf ( cAliasVV0 )->VV0_MODVDA == "2"
		cMod := STR0010	//Especiais
		cNFSerie := ( cAliasVV0 )->VV0_NNFFDI+"-"+( cAliasVV0 )->VV0_SNFFDI
	ElseIf ( cAliasVV0 )->VV0_MODVDA == "3"
		cMod := STR0011		//VDI
		cNFSerie := ( cAliasVV0 )->VV0_NNFFDI+"-"+( cAliasVV0 )->VV0_SNFFDI
	ElseIf ( cAliasVV0 )->VV0_MODVDA == "4"
		cMod := STR0012		//Consignado
		//       cNFSerie := ( cAliasVV0 )->VV0_NUMNFI+"-"+( cAliasVV0 )->VV0_SERNFI
		cNFSerie := ( cAliasVV0 )->VV0_NNFCOM+"-"+( cAliasVV0 )->VV0_SNFCOM
	Endif
	
	nCpoBas  := 0
	nCpoBasS := 0
	
	If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
		ExecBlock("FS_COMVEI",.f.,.f.)
	Else
		nCpoBas  := ( cAliasVV0 )->VVA_LUCLQ1
		nCpoBasS := ( cAliasVV0 )->VVA_LUCLQ2
	Endif
	
	cChassi := Right(Alltrim(( cAliasVV0 )->VV1_CHASSI),8)+Space(8-Len(Right(Alltrim(( cAliasVV0 )->VV1_CHASSI),8)))
	cModelo := Left(( cAliasVV0 )->VV1_MODVEI,10)+Space(10-Len(Left(( cAliasVV0 )->VV1_MODVEI,10)))
	
	If Mv_Par03 == 1 // Vendedor
		dDpgVen := stod(( cAliasVV0 )->VV0_DPGVEN)
	ElseIf Mv_Par03 == 2 // Supervisor
		dDpgVen := stod(( cAliasVV0 )->VV0_DPGSUP)
	ElseIf Mv_Par03 == 3 // Gerente
		dDpgVen := stod(( cAliasVV0 )->VV0_DPGGER)
	Endif
	If Empty(dDpgVen)
		
		//		 If day(VV0->VV0_DATMOV) <= 20
		nMes     := month(stod(( cAliasVV0 )->VV0_DATMOV))+1
		//		 Else
		//			 nMes     := month(( cAliasVV0 )->VV0_DATMOV)+2
		//		 Endif
		
		If nMes == 13
			cMes := "01"
			cAno := Right(StrZero(Year(stod(( cAliasVV0 )->VV0_DATMOV))+1,4),2)
		ElseIf nMes == 14
			cMes := "02"
			cAno := Right(StrZero(Year(stod(( cAliasVV0 )->VV0_DATMOV))+1,4),2)
		Else
			cMes := StrZero(nMes,2)
			cAno := Right(StrZero(Year(stod(( cAliasVV0 )->VV0_DATMOV)),4),2)
		Endif
		
		dDpgVen := Datavalida(Ctod("05/"+cMes+"/"+cAno))
		dDatAnt := dDpgVen   // Antonio - FNC 2124/2010 - 03/03/2010
	Endif
	
	If FieldPos("VV0_NNFCOM") == 0
		aadd(aVetor,{cMod,cCodVen,cNomVen,dDatMov,cNFSerie,;
		Left(SA1->A1_NOME,20),cModelo,cChassi,( cAliasVV0 )->VV0_VALNEG,;
		nCpoBas,(( cAliasVV0 )->VVA_COMVDE/( cAliasVV0 )->VV0_VALNEG)*100,( cAliasVV0 )->VVA_COMVDE,nCpoBasS,(( cAliasVV0 )->VVA_COMGER/nCpoBasS)*100,( cAliasVV0 )->VVA_COMGER,dDpgVen,( cAliasVV0 )->VV0_NUMTRA})
	//		 nCpoBas,(( cAliasVV0 )->VVA_COMVDE/( cAliasVV0 )->VV0_VALNEG)*100,( cAliasVV0 )->VVA_COMVDE,nCpoBasS,(( cAliasVV0 )->VVA_COMGER/nCpoBasS)*100,( cAliasVV0 )->VVA_COMGER,dDpgVen,( cAliasVV0 )->VV0_NUMTRA})
	//		 nCpoBas,(( cAliasVV0 )->VVA_COMVDE/( cAliasVV0 )->VV0_VALNEG)*100,( cAliasVV0 )->VVA_COMVDE,nCpoBasS,(( cAliasVV0 )->VVA_COMGER/nCpoBasS)*100,( cAliasVV0 )->VVA_COMGER,dDpgVen,( cAliasVV0 )->VVA_COMSUP,( cAliasVV0 )->VVA_CPGVEN,( cAliasVV0 )->VVA_CPGGER,( cAliasVV0 )->VVA_CPGSUP,dDpgVen,( cAliasVV0 )->VV0_HISPGC,( cAliasVV0 )->VV0_NUMTRA})
	
		DbSelectArea(cAliasVV0)
		( cAliasVV0 )->(DbSkip())
	Else
		aadd(aVetor,{cMod,cCodVen,cNomVen,dDatMov,cNFSerie,;
		Left(SA1->A1_NOME,20),cModelo,cChassi,( cAliasVV0 )->VV0_VALNEG,;
		nCpoBas,(( cAliasVV0 )->VVA_COMVDE/( cAliasVV0 )->VV0_VALNEG)*100,If(( cAliasVV0 )->VVA_CPGVEN>0,( cAliasVV0 )->VVA_CPGVEN,( cAliasVV0 )->VVA_COMVDE),nCpoBasS,(( cAliasVV0 )->VVA_COMGER/nCpoBasS)*100,( cAliasVV0 )->VVA_COMGER,dDpgVen,( cAliasVV0 )->VV0_NUMTRA})
	//		 nCpoBas,(( cAliasVV0 )->VVA_COMVDE/( cAliasVV0 )->VV0_VALNEG)*100,( cAliasVV0 )->VVA_COMVDE,nCpoBasS,(( cAliasVV0 )->VVA_COMGER/nCpoBasS)*100,( cAliasVV0 )->VVA_COMGER,dDpgVen,( cAliasVV0 )->VV0_NUMTRA})
	//		 nCpoBas,(( cAliasVV0 )->VVA_COMVDE/( cAliasVV0 )->VV0_VALNEG)*100,( cAliasVV0 )->VVA_COMVDE,nCpoBasS,(( cAliasVV0 )->VVA_COMGER/nCpoBasS)*100,( cAliasVV0 )->VVA_COMGER,dDpgVen,( cAliasVV0 )->VVA_COMSUP,( cAliasVV0 )->VVA_CPGVEN,( cAliasVV0 )->VVA_CPGGER,( cAliasVV0 )->VVA_CPGSUP,dDpgVen,( cAliasVV0 )->VV0_HISPGC,( cAliasVV0 )->VV0_NUMTRA})
	
		DbSelectArea(cAliasVV0)
		( cAliasVV0 )->(DbSkip())
	EndIf
		
Enddo
(cAliasVV0)->(DBCloseArea())

aSort(aVetor,,,{|x,y| x[1]+x[2]+x[5] < y[1]+y[2]+y[5]})

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPRIMEº Autor ³ Manoel             º Data ³  17/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao dos Dados de Comissoes de Veiculos 			     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Imprime()

Local _i_

Cabec1 := ""
Cabec2 := ""

Mv_Par01 := Mv_Par01_1

li        := 80
m_pag     := 1
cTamanho  := "M"
Tamanho   := "M"
limite    := 132
nTipo     := 15
nCaracter := 15
nomeprog  := "VEIVM090"

Titulo    := STR0022		//Pagamento de Comissao

wnrel:= "VEIVM090"
wnrel:=SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

Set Printer to &wnrel
Set Printer On
Set Device  to Printer

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

//aSort(aVetor,,,{|x,y| x[3]+x[1]+Dtos(x[4]) < y[3]+y[1]+Dtos(y[4])})

// 1o Elemento - Modalidade
// 2o Elemento - Codigo do Vendedor
// 3o Elemento - Vendedor
// 4o Elemento - Data da Venda
// 5o Elemento - NF e Serie
// 6o Elemento - Cliente
// 7o Elemento - Modelo do Veiculo
// 8o Elemento - Chassi do Veiculo
// 9o Elemento - Valor Negociado
//10o Elemento - Valor Base da Comissao Vendedor
//11o Elemento - Percentual de Comissao Vendedor
//12o Elemento - Valor da Comissao do Vendedor
//13o Elemento - Valor Base da Comissao Gerente
//14o Elemento - Percentual de Comissao Gerente
//15o Elemento - Valor da Comissao do Gerente
//16o Elemento - Valor da Comissao do Supervisor
//17o Elemento - Valor Pago de Comissao do Vendedor
//18o Elemento - Valor Pago de Comissao do Gerente
//19o Elemento - Valor Pago de Comissao do Supervisor
//20o Elemento - Data de Pagamento da Comissao ao Vendedor
//21o Elemento - Historico de Pagamento de Comissao
//22o Elemento - Numero da Transacao


If Mv_Par03 == 1 // Vendedor
	cCabec1 := STR0023     //Data Vda  nro.NF         Cliente           Modelo    Chassi  Vl Veiculo Base Comis Com Vended Pagto Com
	cCabec2 := "-------- ---------- -------------------- ---------- -------- ---------- ---------- ---------- ---------"
	//				99/99/99 xxxxxx-xxx xxxxxxxxxxxxxxxxxxxx xxxxxxxxxx xxxxxxxx 999,999,99 999,999,99 999,999,99 99/99/99
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130       140       150       160      170       180       190       200       210
	//Else // Supervisor
ElseIf Mv_Par03 == 2 // Supervisor
	cCabec1 := STR0024		// Pagto Com"   //Data Vda  nro.NF         Cliente           Modelo    Chassi  Vl Veiculo Base Comis Com Superv
	cCabec2 := "-------- ---------- -------------------- ---------- -------- ---------- ---------- ----------"// ---------"
	//				99/99/99 xxxxxx-xxx xxxxxxxxxxxxxxxxxxxx xxxxxxxxxx xxxxxxxx 999,999,99 999,999,99 999,999,99 99/99/99
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130       140       150       160      170       180       190       200       210
ElseIf Mv_Par03 == 3 // Gerente
	cCabec1 := STR0025		// Pagto Com"    //Data Vda  nro.NF         Cliente           Modelo    Chassi  Vl Veiculo Base Comis ComGerente
	cCabec2 := "-------- ---------- -------------------- ---------- -------- ---------- ---------- ----------"// ---------"
	//				99/99/99 xxxxxx-xxx xxxxxxxxxxxxxxxxxxxx xxxxxxxxxx xxxxxxxx 999,999,99 999,999,99 999,999,99 99/99/99
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130       140       150       160      170       180       190       200       210
Endif
cModa   := ""
cVend   := ""
nTotVen  := 0
nTotVenM := 0

For _i_ := 1 to Len(aVetor)
	
	If Mv_Par03 == 1 // Vendedor
		If aVetor[_i_,12] == 0 .or. Empty(aVetor[_i_,16])
			Loop
		Endif
	ElseIf Mv_Par03 == 2 // Supervisor
		If aVetor[_i_,15] == 0 .or. Empty(aVetor[_i_,16])
			Loop
		Endif
	ElseIf Mv_Par03 == 3 // Gerente
		If aVetor[_i_,18] == 0 .or. Empty(aVetor[_i_,20])
			Loop
		Endif
	Endif
	
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@ li++,00 PSAY  STR0026+" "+Dtoc(Mv_Par01)+ STR0027 +Dtoc(Mv_Par02)   //PERIODO.............
		li++
		If Mv_Par03 == 1 // Vendedor
			@ li++,00 PSAY  STR0028 +" "+aVetor[_i_,3] + If(cVend!=aVetor[_i_,3],""," "+ STR0036) //VENDEDOR............### (continuacao...)
			//		 Else
		ElseIf Mv_Par03 == 2 // Supervisor
			@ li++,00 PSAY  STR0029 +" "+aVetor[_i_,3] + If(cVend!=aVetor[_i_,3],""," "+ STR0036)//SUPERVISOR.......... ###(continuacao...)
		ElseIf Mv_Par03 == 3 // Gerente
			@ li++,00 PSAY  STR0030 +" "+aVetor[_i_,3] + If(cVend!=aVetor[_i_,3],""," "+ STR0036)//GERENTE............. ###(continuacao...)
		Endif
		li++
		@ li++,00 PSAY  STR0031 +" "+aVetor[_i_,1] //MODALIDADE DA VENDA.
		li++
		@li,00  PSAY cCabec1
		li:=li+1
		@li,00  PSAY cCabec2
		li++
		cModa := aVetor[_i_,1]
		cVend := aVetor[_i_,3]
	Endif
	If cVend != aVetor[_i_,3]
		@ li++,00 PSAY  STR0032 +cModa+" "+repl(".",51)+Transform(nTotVenM,"@E 9999,999.99")  //Total da Modalidade
		li++
		If Mv_Par03 == 1 // Vendedor
			@ li++,00 PSAY  STR0033 +cVend+" "+repl(".",29)+Transform(nTotVen,"@E 9999,999.99")  //Total do Vendedor
			//       Else
		ElseIf Mv_Par03 == 2 // Supervisor
			@ li++,00 PSAY  STR0034 +cVend+" "+repl(".",29)+Transform(nTotVen,"@E 9999,999.99")  //Total Supervisor
		ElseIf Mv_Par03 == 3 // Gerente
			@ li++,00 PSAY  STR0035 +cVend+" "+repl(".",29)+Transform(nTotVen,"@E 9999,999.99")  //Total Gerente
		Endif
		nTotVen  := 0
		nTotVenM := 0
		cModa := aVetor[_i_,1]
		cVend := aVetor[_i_,3]
		li := 80
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		li:=li+2
		@ li++,00 PSAY  STR0026+" "+Dtoc(Mv_Par01)+ STR0027 +Dtoc(Mv_Par02) //PERIODO.............
		li++
		If Mv_Par03 == 1 // Vendedor
			@ li++,00 PSAY  STR0037 +aVetor[_i_,3] //VENDEDOR.............
			//     Else
		ElseIf Mv_Par03 == 2 // Supervisor
			@ li++,00 PSAY  STR0038 +aVetor[_i_,3] //SUPERVISOR...........
		ElseIf Mv_Par03 == 3 // Gerente
			@ li++,00 PSAY  STR0039 +aVetor[_i_,3] //GERENTE..............
		Endif
		li++
		@ li++,00 PSAY  STR0040 +aVetor[_i_,1]  //MODALIDADE DA VENDA..
		li++
		@li,00  PSAY cCabec1
		li:=li+1
		@li,00  PSAY cCabec2
		li++
	Endif
	If cModa != aVetor[_i_,1]
		@ li++,00 PSAY  STR0041 +" "+cModa+" "+repl(".",51)+Transform(nTotVenM,"@E 9999,999.99")  //Total da Modalidade
		nTotVenM := 0
		cModa := aVetor[_i_,1]
		li := li + 2
		@ li++,00 PSAY  STR0040 +aVetor[_i_,1] //MODALIDADE DA VENDA..
		li++
		@li,00  PSAY cCabec1
		li:=li+1
		@li,00  PSAY cCabec2
		li++
	Endif
	If Mv_Par03 == 1 // Vendedor
		nVet09 := 0
		nVet10 := 0
		nVet12 := 0
		
		@ li++,00 PSAY  Dtoc(aVetor[_i_,04])+" "+aVetor[_i_,05]+" "+aVetor[_i_,06]+" "+aVetor[_i_,07]+" "+;
		aVetor[_i_,08]+" "+transform(nVet09,"@E 999,999.99")+" "+Transform(nVet10,"@E 999,999.99")+" "+;
		Transform(nVet12,"@E 999,999.99")+" "+Dtoc(aVetor[_i_,16])
		//	 Else // Supervisor
	Elseif Mv_Par03 == 2 // Supervisor
		nVet09 := 0
		nVet13 := 0
		nVet15 := 0
		@ li++,00 PSAY  Dtoc(aVetor[_i_,04])+" "+aVetor[_i_,05]+" "+aVetor[_i_,06]+" "+aVetor[_i_,07]+" "+;
		aVetor[_i_,08]+" "+transform(nVet09,"@E 999,999.99")+" "+Transform(nVet13,"@E 999,999.99")+" "+;
		Transform(nVet15,"@E 999,999.99")
	Elseif Mv_Par03 == 3 // Gerente
		nVet09 := 0
		nVet13 := 0
		nVet15 := 0
		@ li++,00 PSAY  Dtoc(aVetor[_i_,04])+" "+aVetor[_i_,05]+" "+aVetor[_i_,06]+" "+aVetor[_i_,07]+" "+;
		aVetor[_i_,08]+" "+transform(nVet09,"@E 999,999.99")+" "+Transform(nVet13,"@E 999,999.99")+" "+;
		Transform(nVet15,"@E 999,999.99")
	Endif
	
Next
@ li++,00 PSAY  STR0032 +cModa+" "+repl(".",51)+Transform(nTotVenM,"@E 9999,999.99") //total da modalidade
li++
If Mv_Par03 == 1 // Vendedor
	@ li++,00 PSAY  STR0033 +cVend+" "+repl(".",29)+Transform(nTotVen,"@E 9999,999.99") //total do vendedor
	//Else
Elseif Mv_Par03 == 2 // Supervisor
	@ li++,00 PSAY  STR0034 +cVend+" "+repl(".",29)+Transform(nTotVen,"@E 9999,999.99") //total do supervisor
Elseif Mv_Par03 == 3 // Gerente
	@ li++,00 PSAY  STR0035 +cVend+" "+repl(".",29)+Transform(nTotVen,"@E 9999,999.99") //total do gerente
Endif

ms_flush()

Set Printer to
set Device  to Screen

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

Return .t.

//aHelpPor := {}
//aHelpSpa := {}
//aHelpEng := {}
//AADD(aHelpPor,"Informe a Data Inicial.      		 ")
//AADD(aHelpSpa,"Informe a Data Inicial.      		 ")
//AADD(aHelpEng,"Informe a Data Inicial.      		 ")
//AADD(aPergs,{"Data Inicial?     ","Data Inicial?     ","Data Inicial?     ","mv_ch1","D",8,0,0,"G","","Mv_Par01","",;
//"","","","","","","","","","","","","","","","","","","","","","","","VV1","","S","","",aHelpPor,aHelpEng,aHelpSpa})
//
//aHelpPor := {}
//aHelpSpa := {}
//aHelpEng := {}
//AADD(aHelpPor,"Informe a Data Final.        		 ")
//AADD(aHelpSpa,"Informe a Data Final.        		 ")
//AADD(aHelpEng,"Informe a Data Final.        		 ")
//AADD(aPergs,{"Data Final?       ","Data Final?       ","Data Final?       ","mv_ch2","D",8,0,0,"G","","Mv_Par02","",;
//"","","","","","","","","","","","","","","","","","","","","","","","VV1","","S","","",aHelpPor,aHelpEng,aHelpSpa})
//
//aHelpPor := {}
//aHelpSpa := {}
//aHelpEng := {}
//AADD(aHelpPor,"Informe o tipo de comissao.   ")
//AADD(aHelpSpa,"Informe o tipo de comissao.   ")
//AADD(aHelpEng,"Informe o tipo de comissao.   ")
//AADD(aPergs,{"Vended ou Supervis?","Vended ou Supervis?","Vended ou Supervis?","mv_ch3","N",1,0,0,"C","","Mv_Par03","Vendedor",;
//"","","","","Supervisor","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})
//
//aHelpPor := {}
//aHelpSpa := {}
//aHelpEng := {}
//AADD(aHelpPor,"Informe o codigo do Vendedor.    ")
//AADD(aHelpSpa,"Informe o codigo do Vendedor.    ")
//AADD(aHelpEng,"Informe o codigo do Vendedor.    ")
//AADD(aPergs,{"Vendedor?	       ","Vendedor?	       ","Vendedor?	       ","mv_ch4","C",6,0,0,"G","","Mv_Par04","",;
//"","","","","","","","","","","","","","","","","","","","","","","","SA3","","S","","",aHelpPor,aHelpEng,aHelpSpa})
//
//aHelpPor := {}
//aHelpSpa := {}
//aHelpEng := {}
//AADD(aHelpPor,"Informe o tipo de emissao.    ")
//AADD(aHelpSpa,"Informe o tipo de emissao.    ")
//AADD(aHelpEng,"Informe o tipo de emissao.    ")
//AADD(aPergs,{"Tipo de Emissao?  ","Tipo de Emissao?  ","Tipo de Emissao?  ","mv_ch5","N",1,0,0,"C","","Mv_Par05","Conferencia",;
//"","","","","Impressao","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})
//
//aHelpPor := {}
//aHelpSpa := {}
//aHelpEng := {}
//AADD(aHelpPor,"Informe se paga ou nao vended.")
//AADD(aHelpSpa,"Informe se paga ou nao vended.")
//AADD(aHelpEng,"Informe se paga ou nao vended.")
//AADD(aPergs,{"Pagamos Vendedor ?","Pagamos Vendedor ?","Pagamos Vendedor ?","mv_ch6","N",1,0,0,"C","","Mv_Par06","Nao",;
//"","","","","Sim","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TELCONFº Autor ³ Manoel             º Data ³  17/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Atualizacao dos Dados de Comissoes de Veiculos 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TelConf()

Local _ni, iac

dbSelectArea("VV0")

Inclui := .f.

aRotina := {  {"","" , 0 , 1},;   	  // Pesquisar
{"","", 0 , 2} ,; // Consultar
{"","", 0 , 3} ,; // Incluir
{"","", 0 , 4 },; // Alterar
{"","", 0 , 5 } } // Excluir


nOpcE := 4
nOpcG := 4

aHeader := {}
aCols   := {}
nUsado:=0

nUsado:=nUsado+1
Aadd(aHeader,{ STR0043, "VV0_MODVDA", "@!",;	//Modal.Vda
10, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "VV0", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0044, "VV0_CODVEN", "@!",;		//Cod.Vend
6, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "SA3", "", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0045, "A3_NREDUZ", "@!",;		//Vendedor
8, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "SA3", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0046, "VV0_DATMOV", "@!",;		//Emissao
8, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "D", "VV0", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0047, "VV0_NNFFDI", "@!",;		//NF/Serie
10, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "VV0", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0048, "A1_NOME", "@!",;		//Cliente
20, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "SA1", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0049, "VV1_MODVEI", "@!",;		//Modelo
10, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "VV1", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0050, "VV1_CHASSI", "@!",;		//Chassi
08, 0,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "C", "VV1", "V", "", "ÇÇ" } )
nUsado:=nUsado+1

Aadd(aHeader,{ STR0051, "VV0_VALNEG", "@!E 999,999.99",;		//Vl Negoc
9, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VV0", "V", "", "ÇÇ" } )
nUsado:=nUsado+1

Aadd(aHeader,{ STR0052, "VVA_LUCLQ1", "@!E 999,999.99",;		//Base Ven
9, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VVA", "V", "", "ÇÇ" } )

nUsado:=nUsado+1
Aadd(aHeader,{ STR0053, "VVA_PERCOM", "@!E 99.99",;		//%Com Ven
05, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VVA", "", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0054, "VVA_COMVDE", "@!E 999,999.99",;		//Comiss Vend
9, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VVA", "", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0055, "VVA_LUCLQ2", "@!E 999,999.99",;		//Base Ger
9, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VVA", "V", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0056, "VVA_PERSUP", "@!E 99.99",;		//%Com Ge
05, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VVA", "", "", "ÇÇ" } )
nUsado:=nUsado+1
Aadd(aHeader,{ STR0057, "VVA_COMGER", "@!E 999,999.99",;		//Comiss Ger
9, 2,".t.",;
"ÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇ", "N", "VVA", "", "", "ÇÇ" } )

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_DPGVEN")
While !Eof()
	If x3_campo=="VV0_DPGVEN"
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_NUMTRA")
While !Eof()
	If x3_campo=="VV0_NUMTRA"
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	DbSkip()
EndDo


For iac := 1 to Len(aVetor)
	AADD(acols,Array(nUsado+1))
	For _ni:=1 to nUsado
		acols[Len(acols),_ni]:=aVetor[iac,_ni]
	Next
	acols[Len(acols),nUsado+1]:=.F.
Next
//VVA_PERCOM
If Len(aCols) == 0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		If !(aHeader[_ni,2] $ "VVA_PERCOM/VVA_PERSUP")
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Endif
	Next
Endif

cTitulo    := OemToAnsi(STR0001) //Comissoes de Veiculos
cAliasEnch := "VV0"
cLinOk     := "FG_OBRIGAT"
cTudoOk    := "AllwaysTrue()"
cFieldOk   := "FS_TRAVM090()"

aAlter     := {"VVA_PERCOM","VVA_PERSUP","VV0_CODVEN","VVA_PERCOM","VV0_DPGVEN","VV0_DPGSUP","VV0_DPGGER","VV0_HISPGC","VVA_CPGVEN","VVA_CPGGER","VVA_CPGSUP","VVA_COMVDE"}

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcG := If(nOpcG==Nil,3,nOpcG)
nOpcaA:= 0
lVirtual := .f.
nLinhas:= 99
Inclui := .f.
Altera := .t.

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,98	of oMainWnd
oGetDados:= MsGetDados():New(15,1,143,386,nOpcG,cLinOk,cTudoOk,"",.T.,aAlter,,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg CENTER ON INIT (FG_EnchoiceBar(oDlg,{|| nOpcaA := 1, oDlg:End()},{|| nOpcaA := 2,oDlg:End()},,aNewBot) )

If nOpcaA == 1
	FS_GrvVM090() // Grava Alteracoes
Endif

DbSelectArea("VV0")
Retindex()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TRAVM090º Autor ³ Manoel             º Data ³  17/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Trata Acols da Tela de Dados de Comissoes de Veiculos		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TraVM090()

If ReadVar() == "M->VVA_PERCOM"
	aCols[n,FG_POSVAR("VVA_COMVDE","aHeader")] := (M->VVA_PERCOM * aCols[n,FG_POSVAR("VVA_LUCLQ1","aHeader")]) / 100
	oGetDados:oBrowse:Refresh()
	Return .t.
ElseIf ReadVar() == "M->VVA_PERSUP"
	aCols[n,FG_POSVAR("VVA_COMGER","aHeader")] := (M->VVA_PERSUP * aCols[n,FG_POSVAR("VVA_LUCLQ2","aHeader")]) / 100
	oGetDados:oBrowse:Refresh()
	Return .t.
Elseif ReadVar() == "M->VV0_CODVEN"
	If M->VV0_CODVEN != aCols[n,FG_POSVAR("VV0_CODVEN","aHeader")]
		SA3->(DbSetOrder(1))
		SA3->(dbseek(xFilial("SA3")+M->VV0_CODVEN))
		aCols[n,FG_POSVAR("A3_NREDUZ","aHeader")] := SA3->A3_NOME
		oGetDados:oBrowse:Refresh()
	Endif
	Return .t.
Elseif ReadVar() $ "M->VV0_DPGVEN.M->VV0_DPGSUP.M->VV0_DPGGER"
	Return .t.
Elseif ReadVar() == "M->VV0_HISPGC"
	Return .t.
Elseif ReadVar() $ "M->VVA_CPGVEN.M->VVA_CPGGER.M->VVA_CPGSUP"
	Return .t.
Elseif ReadVar() $ "M->VVA_COMVDE"
	Return .t.
Else
	Return .f.
Endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FG_TRAVM090º Autor ³ Manoel             º Data ³  20/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava Acols da Tela de Dados de Comissoes de Veiculos	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvVM090()
Local lAtualiza := .f.
Local i_

DbSelectArea("VV0")
Retindex()
DbSetOrder(1)
DbSelectArea("VVA")
DbSetOrder(1)

If MsgYesNo(STR0063)  //Deseja realmente atualizar as datas de Pagamento de Comissao?
	lAtualiza := .t.
Endif

For i_ :=1 to len(aCols)
	
	DbSelectArea("VV0")
	If dbSeek(xFilial("VV0")+acols[i_,FG_POSVAR("VV0_NUMTRA","aHeader")])
		DbSelectArea("VVA")
		DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		If lAtualiza
			If Mv_Par03 == 1 .and. VV0->VV0_DPGVEN != aCols[i_,FG_POSVAR("VV0_DPGVEN","aHeader")]
				dDPGVEN := VV0->VV0_DPGVEN
				if !recLock("VV0",.f.)
					Help("  ",1,"REGNLOCK")
					DisarmTransaction()
					Break
				Endif
				VV0->VV0_DPGVEN := aCols[i_,FG_POSVAR("VV0_DPGVEN","aHeader")]
				MsUnlock()
				FS_LOG(STR0064  + /*Dtoc(dDPGVEN)*/ Dtoc(dDatAnt) + STR0065 + Dtoc(aCols[i_,FG_POSVAR("VV0_DPGVEN","aHeader")]),VVA->VVA_CHASSI )//Data Pagto Comissao de  ### para ###
			Endif
		Endif
		If Mv_Par03 == 1 // Vendedor
			If VV0->VV0_CODVEN != aCols[i_,FG_POSVAR("VV0_CODVEN","aHeader")]
				cCODVEN := VV0->VV0_CODVEN
				if !recLock("VV0",.f.)
					Help("  ",1,"REGNLOCK")
					DisarmTransaction()
					Break
				Endif
				VV0->VV0_CODVEN := aCols[i_,FG_POSVAR("VV0_CODVEN","aHeader")]
				MsUnlock()
				FS_LOG(STR0066  + cCODVEN + STR0065 + aCols[i_,FG_POSVAR("VV0_CODVEN","aHeader")],VVA->VVA_CHASSI ) //vendedor de *** para
				If VV0->VV0_TIPFAT != "2"
					dbSelectArea("SF2")
					dbSetOrder(1)
					dbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
					if !recLock("SF2",.f.)
						Help("  ",1,"REGNLOCK")
						DisarmTransaction()
						Break
					Endif
					SF2->F2_VEND1 := aCols[i_,FG_POSVAR("VV0_CODVEN","aHeader")]
					MsUnlock()
				Endif
			Endif
		Endif
		
		If lAtualiza
			DbSelectArea("VVA")
			If dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
				if !recLock("VVA",.f.)
					Help("  ",1,"REGNLOCK")
					DisarmTransaction()
					Break
				Endif
				If FieldPos("VVA_CPGVEN") != 0
					VVA->VVA_CPGVEN := aCols[i_,FG_POSVAR("VVA_COMVDE","aHeader")]
				Else
					VVA->VVA_COMVDE := aCols[i_,FG_POSVAR("VVA_COMVDE","aHeader")]
				EndIf
				MsUnlock()						
			Endif
		Endif
		
	Endif
	
Next

Return


Static Function FS_ChImp()
/////////////////////////////////////
Local _ni, iac

If 1 == 2
	FS_ChImp()
Endif
aVetor := {}

For iac := 1 to Len(aCols)
	AADD(aVetor,Array(nUsado))
	For _ni:=1 to nUsado
		aVetor[Len(aVetor),_ni]:=aCols[iac,_ni]
	Next
Next

Fs_Imprime()

Return .t.

static Function FS_LOG(cCpoLog,cChassi)
///////////////////////////////
nHnd := -1
while  nHnd < 0
	cNomeArq := "\logs\VEIVM090\"+dtos(DDATABASE)+".txt"
	nHnd := FOPEN(cNomeArq,2)
	if nHnd == -1 // .and. FERROR() == 2
		nHnd := FCREATE(cNomeArq,0)
	endif
	if nHnd >=0
		FSeek(nHnd,0,2)
		FWrite(nHnd, STR0071 +" "+time()+"h "+ STR0072 +" "+Alltrim(Subs(cUsuario,7,15)) + " "+ STR0073 +" " + cChassi + " - " +;  //as ### o usuario ### alterou o chassi
		cCpoLog + chr(13)+chr(10) )
		FClose(nHnd)
	Else
		MsgAlert("Crie o diretorio \logs\VEIVM090\ para o arquivo de logs seja gerado corretamente!","Atencao!")
		Break
	endif
enddo

return (.t.)


