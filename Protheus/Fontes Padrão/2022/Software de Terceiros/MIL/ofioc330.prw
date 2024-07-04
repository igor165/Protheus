	// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 21     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "Protheus.ch"
#INCLUDE "OFIOC330.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOC330 º Autor ³ Rubens Takahashi   º Data ³  03/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Historico do Veiculo na Oficina                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC330(cChaint)
Default cChaint := ""

Private cCadastro := STR0001
Private aRotina := MenuDef()

if Empty(cChaint)
	dbSelectArea("VV1")
	mBrowse( 6,1,22,75,"VV1")
Else  
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+cChaint)
	nRecNo := RecNo()
	OC330("VV1",nRecNo,2)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OC330    º Autor ³ Rubens Takahashi   º Data ³  03/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Historico do Veiculo na Oficina                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OC330(cAlias,nReg,nOpc)

Local aSizeAut	 := MsAdvSize(.t.)
Local cAuxCodFil := ""
Local cAuxNomFil := ""

Local aVO1       := {}
Local aVS1       := {}
Local aColLBVO3  := {}
Local aColLBVO4  := {}

Local cSQL       := ""
Local cAliasVO1  := "TVO1"
Local cAliasVS1  := "TVS1"

//Local aFilAtu    := FWArrFilAtu()
Local aSM0       := OC3300015_LevantaFiliais()
Local cBkpFilAnt := cFilAnt
Local nCont      := 0     
Local aNewBotx   := {}

Private oBrVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Private oBrAzul     := LoadBitmap( GetResources(), "BR_AZUL")
Private oBrAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
Private oBrVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
Private oBrPreto    := LoadBitmap( GetResources(), "BR_PRETO")

For nCont := 1 to Len(aSM0)

	cFilAnt := aSM0[nCont]

	// Ordem de Servico
	cSQL := "SELECT VO1.VO1_FILIAL, VO1.VO1_NUMOSV, VO1.VO1_DATABE, VO1.VO1_HORABE, VO1.VO1_DATENT, VO1.VO1_HORENT, VO1.VO1_FUNABE, VO1.VO1_STATUS, VAI.VAI_NOMTEC "
	cSQL += " FROM " + RetSQLName("VO1") + " VO1 "
	cSQL += " LEFT JOIN "+RetSQLName("VAI")+" VAI ON VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VO1.VO1_FUNABE AND VAI.D_E_L_E_T_=' ' "
	cSQL += " WHERE VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_CHAINT='"+VV1->VV1_CHAINT+"' AND VO1.D_E_L_E_T_=' ' ORDER BY VO1.VO1_FILIAL, VO1.VO1_NUMOSV "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO1 , .F., .T. )
	While !(cAliasVO1)->(Eof())
	
		If cAuxCodFil <> (cAliasVO1)->VO1_FILIAL
			cAuxCodFil := (cAliasVO1)->VO1_FILIAL
			cAuxNomFil := FWFilialName(cEmpAnt, (cAliasVO1)->VO1_FILIAL,1)
		EndIf
	
		AADD(aVO1,{ (cAliasVO1)->VO1_FILIAL ,;							// 01
					cAuxNomFil,;										// 02
					(cAliasVO1)->VO1_NUMOSV ,;							// 03
					Transform( StoD((cAliasVO1)->VO1_DATABE),"@D"),;	// 04
					Transform( (cAliasVO1)->VO1_HORABE,"@R 99:99"),;	// 05
					Transform( StoD((cAliasVO1)->VO1_DATENT),"@D"),;	// 06
					Transform( (cAliasVO1)->VO1_HORENT,"@R 99:99"),;	// 07
					(cAliasVO1)->VO1_FUNABE ,;							// 08
					(cAliasVO1)->VAI_NOMTEC ,;							// 09
					(cAliasVO1)->VO1_STATUS })							// 10
	
		(cAliasVO1)->(dbSkip())
	EndDo
	(cAliasVO1)->(dbCloseArea())
	
   // Orcamento
	cSQL := "SELECT VS1.VS1_FILIAL, VS1.VS1_NUMORC, VS1.VS1_TIPORC, VS1.VS1_DATORC, VS1.VS1_DATORC, VS1.VS1_HORORC, VS1.VS1_CODVEN, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_NCLIFT, VS1.VS1_STATUS "
	cSQL += " FROM " + RetSQLName("VS1") + " VS1 "
	cSQL += " WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_CHAINT='"+VV1->VV1_CHAINT+"' AND VS1.D_E_L_E_T_=' ' ORDER BY VS1.VS1_FILIAL, VS1.VS1_NUMORC "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS1 , .F., .T. )
	While !(cAliasVS1)->(Eof())
		If cAuxCodFil <> (cAliasVS1)->VS1_FILIAL
			cAuxCodFil := (cAliasVS1)->VS1_FILIAL
			cAuxNomFil := FWFilialName(cEmpAnt, (cAliasVS1)->VS1_FILIAL,1)
		EndIf
  		if (cAliasVS1)->VS1_TIPORC == "1"
  			cTpOrc := STR0006
  		Else
  			cTpOrc := STR0007
  		Endif	
		AADD(aVS1,{ (cAliasVS1)->VS1_FILIAL ,;							// 01
					cAuxNomFil,;										// 02
					(cAliasVS1)->VS1_NUMORC ,;							// 03
					cTpOrc ,;							// 04
					Transform( StoD((cAliasVS1)->VS1_DATORC),"@D"),;	// 05
					Transform( (cAliasVS1)->VS1_HORORC,"@R 99:99"),;	// 06
					(cAliasVS1)->VS1_CODVEN ,;							// 07
					(cAliasVS1)->VS1_CLIFAT ,;							// 08
					(cAliasVS1)->VS1_LOJA ,;							// 09
					(cAliasVS1)->VS1_NCLIFT ,;							// 10
					(cAliasVS1)->VS1_STATUS })							// 11
	
		(cAliasVS1)->(dbSkip())
	EndDo
	(cAliasVS1)->(dbCloseArea())
	

Next
cFilAnt := cBkpFilAnt

If Len(aVO1) == 0
	AADD( aVO1 , { "", "" , "" , CtoD(" ") , 0 , CtoD(" ") , 0 , "","","" } )
Else
	aSort( aVO1 ,1,,{|x,y| x[1]+x[3] < y[1]+y[3] })
EndIf

If Len(aVS1) == 0
	AADD( aVS1 , { "","","","",CtoD(" "),0,"","","","","" } )
Else
	aSort( aVS1 ,1,,{|x,y| x[1]+x[3] < y[1]+y[3] })
EndIf

dbSelectArea("VV1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog Principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgFech := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,128,,,,,.t.)
oDlgFech:lEscClose := .F.

aObjFolder := {}
AADD( aObjFolder, { 100,  100, .T., .T. } )

aObjects := {}
AADD( aObjects, { 100,  100, .T., .T. } )
AADD( aObjects, { 100,  100, .T., .T. } )

aObjPecSer := {}
AADD( aObjPecSer,  { 100,  100, .T., .T. } )
AADD( aObjPecSer,  { 100,  100, .T., .T. } )

// Divisao principal da Tela                                       
aFolder   := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] , aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjFolder   , .T. )
aPOPri    := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] , aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects   , .T. )
aPOPecSer := MsObjSize( { aPOPri[2,2]   , aPOPri[2,1]   , aPOPri[2,4]   , aPOPri[2,3]   , 1 , 1 } , aObjPecSer , .T. , .T. )

@ aFolder[1,1],aFolder[1,2] FOLDER oFolder SIZE aFolder[1,4]-aFolder[1,2],aFolder[1,3]-aFolder[1,1] OF oDlgFech PROMPTS STR0008,STR0009 PIXEL 

aColLbVO1 := { "", RetTitle("VO1_FILIAL") ,;
				RetTitle("VO1_NUMOSV"),;
				RetTitle("VO1_DATABE"),;
				RetTitle("VO1_HORABE"),;
				RetTitle("VO1_DATENT"),;
				RetTitle("VO1_HORENT"),;
				RetTitle("VO1_FUNABE"),;
				RetTitle("VO1_NOMABE") }

aColLbVS1 := { "", RetTitle("VS1_FILIAL") ,;
				RetTitle("VS1_NUMORC"),;
				RetTitle("VS1_TIPORC"),;
				RetTitle("VS1_DATORC"),;
				RetTitle("VS1_HORORC"),;
				RetTitle("VS1_CODVEN"),;
				RetTitle("VS1_CLIFAT"),;
				RetTitle("VS1_LOJA"),;
				RetTitle("VS1_NCLIFT") }


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox de OS ABA 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLbVO1 := TWBrowse():New(aPOPri[1,1],aPOPri[1,2],(aPOPri[1,4]-aPOPri[1,2]),(aPOPri[1,3]-aPOPri[1,1]),,aColLbVO1,,oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oLbVO1:aColSizes := {0,40,50,50,50,50,50,40,50}
oLbVO1:SetArray(aVO1)
oLbVO1:bLDblClick := { || FS_CONSOS( aVO1[oLbVO1:nAt,1] , aVO1[oLbVO1:nAt,3] ) }
oLbVO1:bChange := { || FS_ATLBOX( aVO1[oLbVO1:nAt,1] , aVO1[oLbVO1:nAt,3],"1" ) }
oLbVO1:bLine := { || { IIf(aVO1[oLbVO1:nAt,10] == "A", oBrVerde ,;
						IIf(aVO1[oLbVO1:nAt,10] == "D", oBrAzul ,;
						IIf(aVO1[oLbVO1:nAt,10] == "F", oBrVermelho ,;
						IIf(aVO1[oLbVO1:nAt,10] == "C", oBrPreto , "" )))), ;
	aVO1[oLbVO1:nAt,1] + "-" + aVO1[oLbVO1:nAt,2],;
	aVO1[oLbVO1:nAt,3] ,;
	aVO1[oLbVO1:nAt,4] ,;
	aVO1[oLbVO1:nAt,5] ,;
	aVO1[oLbVO1:nAt,6] ,;
	aVO1[oLbVO1:nAt,7] ,;
	aVO1[oLbVO1:nAt,8] ,;
	aVO1[oLbVO1:nAt,9] } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox de Pecas ABA 1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColLBVO3 := {  "TT" ,;
				RetTitle("VO3_GRUITE") ,;
				RetTitle("VO3_CODITE") ,;
				RetTitle("VO3_DESITE") ,;
				RetTitle("VO3_QTDREQ") }
oLbPeca := TWBrowse():New(aPOPecSer[1,1],aPOPecSer[1,2],(aPOPecSer[1,4]-aPOPecSer[1,2]),(aPOPecSer[1,3]-aPOPecSer[1,1]),,aColLBVO3,,oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbPeca:aColSizes := {10,40,50,150,20}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox de Servicos ABA 1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aColLBVO4 := {  "TT" ,;
				RetTitle("VO4_GRUSER") ,;
				RetTitle("VO4_CODSER") ,;
				RetTitle("VO4_DESSER") ,;
				RetTitle("VO4_TIPSER") ,;
				RetTitle("VO4_TEMPAD") ,;
				RetTitle("VO4_CODSEC") ;
				}
oLbSrvc := TWBrowse():New(aPOPecSer[2,1],aPOPecSer[2,2],(aPOPecSer[2,4]-aPOPecSer[2,2]),(aPOPecSer[2,3]-aPOPecSer[2,1]),,aColLBVO4,,oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbSrvc:aColSizes := {10,30,35,80,35,40,20}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox de Orçamento ABA 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLbVS1 := TWBrowse():New(aPOPri[1,1],aPOPri[1,2],(aPOPri[1,4]-aPOPri[1,2]),(aPOPri[1,3]-aPOPri[1,1]),,aColLbVS1,,oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oLbVS1:aColSizes := {0,40,40,50,50,50,50,40,50}
oLbVS1:SetArray(aVS1)
oLbVS1:bLDblClick := { || FS_CONSORC( aVS1[oLbVS1:nAt,1] , aVS1[oLbVS1:nAt,3] ) }
oLbVS1:bChange := { || FS_ATLORC( aVS1[oLbVS1:nAt,1] , aVS1[oLbVS1:nAt,3],"2" ) }
oLbVS1:bLine := { || { IIf(aVS1[oLbVS1:nAt,11] == "0", oBrVerde ,;
						IIf(aVS1[oLbVS1:nAt,11] == "P", oBrAzul ,;
						IIf(aVS1[oLbVS1:nAt,11] == "L", oBrAmarelo ,;
						IIf(aVS1[oLbVS1:nAt,11] == "I", oBrPreto ,;
						IIf(aVS1[oLbVS1:nAt,11] == "C", oBrVermelho , "" ))))), ;
	aVS1[oLbVS1:nAt,1] + "-" + aVS1[oLbVS1:nAt,2],;
	aVS1[oLbVS1:nAt,3] ,;
	aVS1[oLbVS1:nAt,4] ,;
	aVS1[oLbVS1:nAt,5] ,;
	aVS1[oLbVS1:nAt,6] ,;
	aVS1[oLbVS1:nAt,7] ,;
	aVS1[oLbVS1:nAt,8] ,;
	aVS1[oLbVS1:nAt,9] ,;
	aVS1[oLbVS1:nAt,10] } }


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox de Pecas ABA 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColLBVS3 := { RetTitle("VS3_GRUITE") ,;
				RetTitle("VS3_CODITE") ,;
				RetTitle("VS3_DESITE") ,;
				RetTitle("VS3_QTDITE") }
oLbPeca2 := TWBrowse():New(aPOPecSer[1,1],aPOPecSer[1,2],(aPOPecSer[1,4]-aPOPecSer[1,2]),(aPOPecSer[1,3]-aPOPecSer[1,1]),,aColLBVS3,,oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbPeca2:aColSizes := {40,40,150,20}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox de Servicos ABA 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColLBVS4 := { RetTitle("VS4_GRUSER") ,;
				RetTitle("VS4_CODSER") ,;
				RetTitle("VO6_DESSER") ,;
				RetTitle("VS4_TIPSER") ,;
				RetTitle("VS4_TEMPAD") ,;
				RetTitle("VS4_CODSEC") ;
				}
oLbSrvc2 := TWBrowse():New(aPOPecSer[2,1],aPOPecSer[2,2],(aPOPecSer[2,4]-aPOPecSer[2,2]),(aPOPecSer[2,3]-aPOPecSer[2,1]),,aColLBVS4,,oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbSrvc2:aColSizes := {25,35,80,35,35,30}

AADD(aNewBotx, {"ANALITICO",{|| OC330LEG() },( STR0010 )} ) // Legenda
AADD(aNewBotx, {"ANALITICO",{|| OC330IMP() },( STR0019 )} ) // Imprimir

oLbVO1:Refresh()
oLbVS1:Refresh()

ACTIVATE MSDIALOG oDlgFech ON INIT ( EnchoiceBar(oDlgFech, { || oDlgFech:End() }, { || oDlgFech:End() },, aNewBotx ) )

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_ATLBOX º Autor ³ Rubens Takahashi  º Data ³  03/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza ListBox de Pecas e Servico - Ordem de Servico     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAuxFil = Filial da Ordem de Servico                       º±±
±±º          ³ cAuxNumOs = Numero da Ordem de Servico                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ATLBOX( cAuxFil, cAuxNumOs )

Local cFilSALVA := cFilAnt
Local aVO3 := {}
Local aVO4 := {}
Local nPos//, nTam, nDel

cFilAnt := cAuxFil

// Pecas .. 
aVO3 := FMX_CALPEC(cAuxNumOs, , , , .f., .f.)
// Apaga linhas com qtde de pecas zerada ... 
nPos := 1
While nPos <= Len(aVO3)
	If aVO3[nPos,05] == 0
		aDel (aVO3, nPos)
		aSize(aVO3, Len(aVO3) - 1)
		Loop
	EndIf
	nPos++
End

If Len(aVO3) == 0
	AADD( aVO3 , {"","","",,0,,,,,,,,""} ) // Inicializa a Matriz com a mesma estrutura do retorno da funcao FMX_CALPEC
EndIf

oLbPeca:nAt := 1 
oLbPeca:SetArray(aVO3)
oLbPeca:bLine := { || { aVO3[oLbPeca:nAt,3],;
					    aVO3[oLbPeca:nAt,1],;
					    aVO3[oLbPeca:nAt,2],;
					    aVO3[oLbPeca:nAt,13],;
					    Transform( aVO3[oLbPeca:nAt,5] , "@E 999.99" ) } }
oLbPeca:Refresh()

// Servicos ... 
aVO4 := FMX_CALSER(cAuxNumOs, , , , .f. , .f. )
If Len(aVO4) == 0
	AADD( aVO4 , Array(19) ) // Inicializa a Matriz com a mesma estrutura do retorno da funcao FMX_CALSER
	aFill( aVO4[1] , "" )
	aVO4[01,10] := 0
EndIf

oLbSrvc:nAt := 1 
oLbSrvc:SetArray(aVO4)
oLbSrvc:bLine := { || { aVO4[oLbSrvc:nAt,4],;
					    aVO4[oLbSrvc:nAt,1],;
					    aVO4[oLbSrvc:nAt,2],;
					    substr(aVO4[oLbSrvc:nAt,15],1,40),;
					    aVO4[oLbSrvc:nAt,5],;
					    Transform( aVO4[oLbSrvc:nAt,10] , "@R 99:99") ,;
					    aVO4[oLbSrvc:nAt,18] } }
oLbSrvc:Refresh()

cFilAnt := cFilSALVA

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_ATLORC º Autor ³ Thiago				  º Data ³  21/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza ListBox de Pecas e Servico - Orcamento			     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAuxFil = Filial da Ordem de Servico                       º±±
±±º          ³ cAuxNumOrc = Numero do Orcamento			                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ATLORC( cAuxFil, cAuxNumOrc )

Local cFilSALVA := cFilAnt
Local aVS3 := {}
Local aVS4 := {}
Local nPos//, nTam, nDel
Local cAliasVS3 := "SQLVS3" 
Local cAliasVS4 := "SQLVS4" 

cFilAnt := cAuxFil

// Pecas .. 

cQuery := "SELECT VS3.VS3_GRUITE, VS3.VS3_CODITE, SB1.B1_DESC, VS3.VS3_QTDITE "
cQuery += "FROM "
cQuery += RetSqlName( "VS3" ) + " VS3 " 
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO = VS3.VS3_GRUITE AND SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.D_E_L_E_T_ =' ' "
cQuery += "WHERE " 
cQuery += "VS3.VS3_FILIAL='"+ xFilial("VS3")+ "' AND VS3.VS3_NUMORC = '"+cAuxNumOrc+"' AND VS3.VS3_QTDITE > 0 AND "
cQuery += "VS3.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )

Do While !( cAliasVS3 )->( Eof() )

	AADD( aVS3 , {( cAliasVS3 )->VS3_GRUITE , ( cAliasVS3 )->VS3_CODITE , ( cAliasVS3 )->B1_DESC , ( cAliasVS3 )->VS3_QTDITE} )

   DbSelectArea(cAliasVS3)
   ( cAliasVS3 )->(DbSkip())
EndDo
( cAliasVS3 )->( dbCloseArea() )

If Len(aVS3) == 0
	AADD( aVS3 , {"","","",0} ) // Inicializa a Matriz
EndIf

oLbPeca2:nAt := 1 
oLbPeca2:SetArray(aVS3)
oLbPeca2:bLine := { || { aVS3[oLbPeca2:nAt,1],;
					    aVS3[oLbPeca2:nAt,2],;
					    aVS3[oLbPeca2:nAt,3],;
					    Transform( aVS3[oLbPeca2:nAt,4] , "@E 999.99" ) } }
oLbPeca2:Refresh()

// Servicos ... 

cQuery := "SELECT VS4.VS4_GRUSER, VS4.VS4_CODSER, VO6.VO6_DESSER, VS4.VS4_TIPSER, VS4.VS4_TEMPAD, VS4.VS4_CODSEC "
cQuery += "FROM "
cQuery += RetSqlName( "VS4" ) + " VS4 " 
cQuery += "INNER JOIN "+RetSQLName("VO6")+" VO6 ON  VO6.VO6_FILIAL  = '"+xFilial("VO6")+"' AND VO6.VO6_CODSER = VS4.VS4_CODSER AND VS4.D_E_L_E_T_ =' ' "
cQuery += "WHERE " 
cQuery += "VS4.VS4_FILIAL='"+ xFilial("VS4")+ "' AND VS4.VS4_NUMORC = '"+cAuxNumOrc+"' AND "
cQuery += "VS4.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS4, .T., .T. )

Do While !( cAliasVS4 )->( Eof() )

	AADD( aVS4 , {( cAliasVS4 )->VS4_GRUSER , ( cAliasVS4 )->VS4_CODSER ,  substr(( cAliasVS4 )->VO6_DESSER,1,40) , ( cAliasVS4 )->VS4_TIPSER , ( cAliasVS4 )->VS4_TEMPAD , ( cAliasVS4 )->VS4_CODSEC } )


   DbSelectArea(cAliasVS4)
   ( cAliasVS4 )->(DbSkip())
EndDo
( cAliasVS4 )->( dbCloseArea() )

If Len(aVS4) == 0
	AADD( aVS4 , {"","","","",0,""} ) // Inicializa a Matriz
EndIf
oLbSrvc2:nAt := 1 
oLbSrvc2:SetArray(aVS4)
oLbSrvc2:bLine := { || { aVS4[oLbSrvc2:nAt,1],;
					    aVS4[oLbSrvc2:nAt,2],;
					    aVS4[oLbSrvc2:nAt,3],;
					    aVS4[oLbSrvc2:nAt,4],;
					    Transform( aVS4[oLbSrvc2:nAt,5] , "@R 99:99") ,;
					    aVS4[oLbSrvc2:nAt,6] } }
oLbSrvc2:Refresh()

cFilAnt := cFilSALVA

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_CONSOS º Autor ³ Rubens Takahashi  º Data ³  03/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chama a consulta de OS (OFIOC060)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAuxFil = Filial da Ordem de Servico                       º±±
±±º          ³ cAuxNumOs = Numero da Ordem de Servico                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_CONSOS( cAuxFil , cAuxNumOs )

Local cFilSALVA := cFilAnt

If Empty( cAuxNumOs )
	Return
EndIf

cFilAnt := cAuxFil 
VO1->(dbSetOrder(1))
If VO1->(DbSeek( xFilial("VO1") + cAuxNumOs ))
	OC060("VO1",VO1->(RECNO()),2)
EndIf

cFilAnt := cFilSALVA

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_CONSORC º Autor ³ Thiago		     º Data ³  21/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chama a tela do orçamento.				                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAuxFil = Filial da Ordem de Servico                       º±±
±±º          ³ cAuxNumOs = Numero da Ordem de Servico                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_CONSORC( cAuxFil , cAuxNumOrc )

Local cFilSALVA := cFilAnt

If Empty( cAuxNumOrc )
	Return
EndIf

cFilAnt := cAuxFil 
VS1->(dbSetOrder(1))
If VS1->(DbSeek( xFilial("VS1") + cAuxNumOrc ))
	OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
EndIf

cFilAnt := cFilSALVA

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  º Autor ³ Rubens Takahashi   º Data ³  03/06/11   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := { {STR0003,"AxPesqui",0,1},;
				   {STR0004,"OC330",0,2} ,;
				   {STR0005,"OC330PESQ",0,1}}
Return aRotina


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OC330PESQ º Autor ³ Andre Luis Almeidaº Data ³  08/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pesquisa Avancada do Veiculo (parte do Chassi,...)         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OC330PESQ()
Local aRet     := {}
Local aParamBox:= {}
DbSelectArea("VV1")
AADD(aParamBox,{1,STR0002,space(TamSx3("VV1_CHASSI")[1]),"@!",'FG_POSVEI("MV_PAR01",)',"VV1",".t.",80,.t.}) // Identificacao do Veiculo
ParamBox(aParamBox,STR0005,@aRet,,,,,,,,.f.) // Pesquisa Avançada
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OC330LEG  º Autor ³ Thiago            º Data ³  21/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Legenda.																	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OC330LEG()

if oFolder:aDialogs[1]:lVisibleControl 

	aLegenda  := {{ 'BR_VERDE'	, STR0011 },;	// Aberta
	{ 'BR_AZUL'		, STR0012 },;	// Liberada
	{ 'BR_VERMELHO'	, STR0013 },;	// Fechado
	{ 'BR_PRETO'	, STR0014 } }	// Cancelado
	
	BrwLegenda(cCadastro,STR0010 ,aLegenda)  //Legenda

Else

	aLegenda  := {{ 'BR_VERDE'	, STR0016 },;	// Digitado
	{ 'BR_AZUL'		, STR0017 },;	// Pendente Liberação 
	{ 'BR_AMARELO'		, STR0018 },;	// Liberado para exportação
	{ 'BR_PRETO'	, STR0015 },;	// Exportado para OS
	{ 'BR_VERMELHO'	, STR0014 } }	// Cancelado
	
	BrwLegenda(cCadastro,STR0010 ,aLegenda)  //Legenda

Endif	


Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OC330IMP  º Autor ³ Manoel Filho      º Data ³  12/12/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão do Historico de Passagem do Chassi      				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OC330IMP()
Local nRecVV1 := VV1->(Recno())

OFIOR150(.t.)

VV1->(DbGoTo(nRecVV1))

return

/*/{Protheus.doc} OC3300015_LevantaFiliais
Levantamento de filiais que o usuário deverá visualizar
@author Renato Vinicius
@since 12/09/2018
@version 1.0
@return aRetorno, array
@param
@type function
/*/

Function OC3300015_LevantaFiliais()

Local aRetorno 		:= {}
Local oHelperFil 	:= DMS_FilialHelper():New()
Local cVHistFil		:= "0"

If VAI->(FieldPos("VAI_PERHIS")) > 0 // Visualizar histórico de filiais onde o usuario nao tem acesso
	VAI->(dbSetOrder(4))
	If VAI->(MsSeek( xFilial("VAI") + __cUserID ) ) .and. !Empty( VAI->VAI_PERHIS )
		cVHistFil := VAI->VAI_PERHIS // 0 = Sem Permissao / 1 = Com Permissão 
	EndIf
EndIf

aRetorno := oHelperFil:GetAllFil(cVHistFil <> "0") // .T. permite visualizar / .F. não permite

Return aRetorno