// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "Veivr180.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVR180 ³ Autor ³ Rafael/Andre Luis     ³ Data ³ 13/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  1 - RELATORIO DE NF DE ENTRADA                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR180

	Local aFilAtu      := FWArrFilAtu()
	Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
	Local cBkpFilAnt:= cFilAnt
	Local   cOrdem ` := ""
	Local nCont      := 0
	Private aFil     := {}
	Private cAlias   :="VVF" //Go to
	Private nLin     := 1
	Private aPag     := 1
	Private cTitulo  := STR0001 //Entrada de Veiculos N-Novos e U-Usados
	Private cCabec1  := ""
	Private cCabec2  := ""
	Private cDesc1   := Alltrim(cTitulo)
	Private cDesc2   := ""
	Private cDesc3   := ""
	Private aReturn  := { STR0002 , 1, STR0003 , 2, 2, 1, "",1 }//Zebrado # Administracao
	Private cTamanho := "M"           	// P/M/G
	Private Limite   := 132          	// 80/132/220
	Private cNomProg := "VEIVR180"
	Private cNomeRel := "VEIVR180"
	Private nLastKey := 0
	Private nCaracter:= 15
	Private cPerg    := "VVR180"
	/*
	MV_PAR01 = FILIAL Inicial    C  2  G
	MV_PAR02 = FILIAL final      C  2  G
	MV_PAR03 = Data Inicial      D  8  G
	MV_PAR04 = Data Final        D  8  G
	MV_PAR05 = Tipo de Relatorio N  1  C ( 1-Todos / 2-Novos / 3-Usados )
	MV_PAR06 = Totalizador       N  1  C ( 1-Chassi / 2-Data / 3-Modelo / 4-NF+Serie / 5-Fornecedor )
	*/
	
	If !FS_VERBASE()			 	// Verifica a existencia dos arquivos envolvidos na Consulta
		MsgStop(STR0004 ,STR0005 )	//Nao existem dados para este Relatorio! # Atencao
		Return
	EndIf
	
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		aAdd( aFil , { cFilAnt , FWFilialName() })
	Next
	cFilAnt := cBkpFilAnt
	
	//ValidPerg(cPerg)
	set printer to &cNomeRel
	set printer on
	set device to printer
	cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
	if nlastkey == 27
		return
	Endif
	PERGUNTE(cPerg,.f.)
	If MV_PAR05 == 2
		cTitulo:= STR0006 	// Entrada de Veiculos Novos
	ElseIf MV_PAR05 == 3
		cTitulo:= STR0007 	// Entrada de Veiculos Usados
	EndIf
	if MV_PAR06 == 1  	 	//imprimir a ordem no cCabec
		cOrdem := STR0008 	//Chassi
	elseif MV_PAR06 == 2
		cOrdem := STR0009 	//Data
	elseif MV_PAR06 == 3
		cOrdem := STR0010	//Modelo
	elseif MV_PAR06 == 4
		cOrdem := STR0011	//NF + Serie
	else
		cOrdem := STR0012	//Fornecedor
	endif
	cCabec1 := STR0013 +" "+MV_PAR01+ STR0014 + MV_PAR02 +"   "+ STR0015 +" "+ transform(MV_PAR03,"@D")+ STR0014 + transform(MV_PAR04,"@D") + "  "+ STR0016 +" " + cOrdem//"Filial: #  a  # Periodo: #  a  # Ordem:
	Do Case
		Case MV_PAR06 == 1 			//Cabecalho pelo -> Chassi
			cCabec2 := STR0017 	//   NF+SERIE      COD.FOR   FORNECEDOR           DT.MOVTO CHASSI               T MARCA+MODELO                  COR      VALOR
			
		Case MV_PAR06 == 2 			//Cabecalho pelo -> Data
			cCabec2 := STR0018	//     NF+SERIE      COD.FOR   FORNECEDOR                CHASSI               T MARCA+MODELO                  COR        VALOR
			
		Case MV_PAR06 == 3 			//Cabecalho   pelo -> marca+Modelo
			cCabec2 :=STR0019 	//     NF+SERIE      COD.FOR   FORNECEDOR                          DT.MOVTO CHASSI               T COR                   VALOR
			
		Case MV_PAR06 == 4  		//Cabecalho   pelo -> NF+Serie
			cCabec2 :=STR0020	//     DT.MOVTO CHASSI               T MARCA+MODELO                       DESCR. MODELO                  COR             VALOR
			
		Case MV_PAR06 == 5 			//Cabecalho  pelo -> Fornecedor
			cCabec2 :=STR0021 	//     NF+SERIE      DT.MOVTO CHASSI               T MARCA+MODELO   	           DESCR. MODELO             COR            VALOR
			
	EndCase
	
	
	
	SetDefault(aReturn,cAlias)
	RptStatus({|lEnd| FS_VVR180(@lEnd,cNomeRel,cAlias)},cTitulo)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VVR180³ Autor ³ Rafael/Andre Luis     ³ Data ³ 13/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Impressao						                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VVR180(lEnd,wNRel,cAlias)
Local cFilAtu := ""
Local aVetImp := {}
Local aValTot := {}
Local cQuery  := ""
Local cQAlVVF := "SQLVVF"
Local ni      := 0
Local nPos    := 0
Local cQuebra1:= ""
Local cQuebra2:= ""
M_PAG         := 1
nLin          := 80
aPag          := 1
cQuery := "SELECT VVF.VVF_FILIAL , VVF.VVF_NUMNFI , VVF.VVF_SERNFI , VVF.VVF_LOJA , VVF.VVF_CODFOR , VVF.VVF_DATMOV , VVG.VVG_CHASSI , VVG.VVG_VALUNI , VVG.VVG_ESTVEI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VVC.VVC_DESCRI FROM "+RetSqlName("VVF")+" VVF , "+RetSqlName("VVG")+" VVG , "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 , "+RetSqlName("VVC")+" VVC  WHERE "
cQuery += "VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVG.VVG_CHAINT=VV1.VV1_CHAINT AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI AND VV1.VV1_CORVEI=VVC.VVC_CORVEI AND VV1.VV1_CODMAR=VVC.VVC_CODMAR AND VVF.VVF_SITNFI='1' AND VVF.VVF_FILIAL>='"+MV_PAR01+"' AND VVF.VVF_FILIAL<='"+MV_PAR02+"' AND VVF.VVF_DATMOV>='"+dtos(MV_PAR03)+"' AND VVF.VVF_DATMOV<='"+dtos(MV_PAR04)+"' AND "
if Empty(xfilial("VV1"))
	cQuery += "VV1.VV1_FILIAL='"+ xFilial("VV1")+"' AND "
ELSE
	cQuery += "VV1.VV1_FILIAL=VVF.VVF_FILIAL AND "
ENDIF
IF Empty(xfilial("VV2"))
	cQuery += "VV2.VV2_FILIAL='"+ xFilial("VV2")+"' AND "
ELSE
	cQuery += "VV2.VV2_FILIAL=VVF.VVF_FILIAL AND "
ENDIF
IF Empty(xfilial("VVC"))
	cQuery += "VVC.VVC_FILIAL='"+ xFilial("VVC")+"' AND "
ELSE
	cQuery += "VVC.VVC_FILIAL=VVF.VVF_FILIAL AND "
ENDIF
IF MV_PAR05 # 1
	If MV_PAR05 == 2
		cQuery += "VVG.VVG_ESTVEI='0' AND "
	Else
		cQuery += "VVG.VVG_ESTVEI<>'0' AND "
	Endif
EndIF
cQuery += "VVF.D_E_L_E_T_=' ' AND VVG.D_E_L_E_T_=' ' AND VV1.D_E_L_E_T_=' ' AND VV2.D_E_L_E_T_=' ' AND VVC.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
Aadd(aValTot,{" "," ",0})
Do While !( cQAlVVF )->( Eof() )
	aValTot[1,3] +=( cQAlVVF )->( VVG_VALUNI )
	nPos := Ascan( aValTot , { |x| x[1]+x[2] == ( cQAlVVF )->( VVF_FILIAL )+" " })
	If nPos <= 0
		Aadd(aValTot,{( cQAlVVF )->( VVF_FILIAL )," ",( cQAlVVF )->( VVG_VALUNI )})
	Else
		aValTot[nPos,3] += ( cQAlVVF )->( VVG_VALUNI )
	EndIf
	nPos := 0
	Do Case  //MONTA O VETOR
		
		Case MV_PAR06 == 2 // -> Data
			nPos := Ascan( aValTot , { |x| x[1]+x[2] == ( cQAlVVF )->( VVF_FILIAL )+( cQAlVVF )->( VVF_DATMOV ) })
			If nPos <= 0
				Aadd(aValTot,{( cQAlVVF )->( VVF_FILIAL ),( cQAlVVF )->( VVF_DATMOV ),0})
				nPos := len(aValTot)
			EndIf
			
		Case MV_PAR06 == 3 // -> marca+Modelo
			nPos := Ascan( aValTot , { |x| x[1]+x[2] == ( cQAlVVF )->( VVF_FILIAL ) + ( cQAlVVF )->( VV1_CODMAR ) + ( cQAlVVF )->( VV1_MODVEI )+( cQAlVVF )->( VV2_DESMOD ) })
			If nPos <= 0
				Aadd(aValTot,{( cQAlVVF )->( VVF_FILIAL ),( cQAlVVF )->( VV1_CODMAR )+( cQAlVVF )->( VV1_MODVEI )+( cQAlVVF )->( VV2_DESMOD ),0})
				nPos := len(aValTot)
			EndIf
			
		Case MV_PAR06 == 4 // -> NF+Serie
			nPos := Ascan( aValTot , { |x| x[1]+x[2] == ( cQAlVVF )->( VVF_FILIAL )+( cQAlVVF )->( VVF_NUMNFI )+"-"+( cQAlVVF )->( VVF_SERNFI ) })
			If nPos <= 0
				Aadd(aValTot,{( cQAlVVF )->( VVF_FILIAL ),( cQAlVVF )->( VVF_NUMNFI )+"-"+( cQAlVVF )->( VVF_SERNFI ),0})
				nPos := len(aValTot)
			EndIf
			
		Case MV_PAR06 == 5 // -> Fornecedor
			nPos := Ascan( aValTot , { |x| x[1]+x[2] == ( cQAlVVF )->( VVF_FILIAL )+( cQAlVVF )->( VVF_CODFOR )+"-"+( cQAlVVF )->( VVF_LOJA ) })
			If nPos <= 0
				Aadd(aValTot,{( cQAlVVF )->( VVF_FILIAL ),( cQAlVVF )->( VVF_CODFOR )+"-"+( cQAlVVF )->( VVF_LOJA ),0})
				nPos := len(aValTot)
			EndIf
			
	EndCase
	
	If nPos > 0
		aValTot[nPos,3] += ( cQAlVVF )->( VVG_VALUNI )
	EndIf
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	
	if Empty(xFilial("SA2"))
		dbSeek(xFilial("SA2")+( cQAlVVF )->( VVF_CODFOR )+( cQAlVVF )->( VVF_LOJA ))
	else
		dbSeek(( cQAlVVF )->( VVF_FILIAL ) + ( cQAlVVF )->( VVF_CODFOR )+( cQAlVVF )->( VVF_LOJA ))
	endif			 	  //   01                                               02                                                             03                                       04                            05                                06                               07                                                 08                                                             09                              10                               11                          12
	Aadd(aVetImp,{( cQAlVVF )->( VVF_FILIAL ) , ( cQAlVVF )->( VVF_NUMNFI )+"-"+( cQAlVVF )->( VVF_SERNFI ) , ( cQAlVVF )->( VVF_CODFOR )+"-"+( cQAlVVF )->( VVF_LOJA ) , left(SA2->A2_NOME,25) , ( cQAlVVF )->( VVF_DATMOV ) , left(( cQAlVVF )->( VVG_CHASSI ),20) , ( cQAlVVF )->( VVG_VALUNI ) , IIF(( cQAlVVF )->( VVG_ESTVEI )=='0','N','U') , ( cQAlVVF )->( VV1_CODMAR ) ,  ( cQAlVVF )->( VV1_MODVEI ) , ( cQAlVVF )->( VV2_DESMOD ) , ( cQAlVVF )->( VVC_DESCRI )})
	( cQAlVVF )->( DbSkip() )
EndDo
( cQAlVVF )->( dbCloseArea() )

///////////////////////////////////////////////////////////////////////////////

Do Case
	Case MV_PAR06 == 1 //Ordena pelo -> Chassi
		asort(aVetImp,,,{|x,y| x[1]+x[6] < y[1]+y[6] })
		
	Case MV_PAR06 == 2 //Ordena pelo -> Data
		asort(aVetImp,,,{|x,y| x[1]+x[5] < y[1]+y[5] })
		
	Case MV_PAR06 == 3 //Ordena pelo -> marca+Modelo
		asort(aVetImp,,,{|x,y| x[1]+x[9]+x[10] < y[1]+y[9]+y[10] })
		
	Case MV_PAR06 == 4 //Ordena pelo -> NF+Serie
		asort(aVetImp,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
		
	Case MV_PAR06 == 5 //Ordena pelo -> Fornecedor
		asort(aVetImp,,,{|x,y| x[1]+x[3] < y[1]+y[3] })
		
EndCase


nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
cQuebra1 := "INICIAL"
cQuebra2 := "INICIAL"
@ nLin++, 01 pSay left(STR0022 +" "+space(114),114)+transform(aValTot[1,3],"@E 99,999,999,999.99") //TOTAL GERAL:
For ni := 1 to len(aVetImp)
	If nLin >= 58
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
	EndIf
	If cQuebra1 <> aVetImp[ni,1]
		cQuebra1 := aVetImp[ni,1]
		nLin++
		cFilAtu := ""
		nPos := aScan(aFil,{|x| x[1] == aVetImp[ni,1]})
		If nPos > 0
			cFilAtu := "-"+left(aFil[nPos,2]+space(20),20)  //nome da filial no relatorio.
		EndIf
		nPos := Ascan( aValTot , { |x| x[1]+x[2] == cQuebra1+" " })
		@ nLin++, 01 pSay left(aVetImp[ni,1]+cFilAtu+space(114),114)+IIf(nPos>0,Transform(aValTot[nPos,3],"@E 99,999,999,999.99"),"")
		cQuebra2 := "INICIAL"
	EndIf
	Do Case
		Case MV_PAR06 == 1 //Chassi
			@ nLin++, 03 pSay left(aVetImp[ni,2]+" "+aVetImp[ni,3]+" "+left(aVetImp[ni,4],20)+" "+ transform(stod(aVetImp[ni,5]),"@D")+" "+aVetImp[ni,6]+" "+aVetImp[ni,8]+" "+aVetImp[ni,9]+" "+left(aVetImp[ni,10]+space(25),25)+" "+aVetImp[ni,12]+space(116),116)+" "+transform(aVetImp[ni,7],"@E 9,999,999.99")
		Case MV_PAR06 == 2 //Data
			If cQuebra2 <> aVetImp[ni,5]
				cQuebra2 := aVetImp[ni,5]
				nPos := Ascan( aValTot , { |x| x[1]+x[2] == cQuebra1+cQuebra2 })
				nLin++
				@ nLin++, 03 pSay left(transform(stod(aVetImp[ni,5]),"@D")+space(117),117)+IIf(nPos>0,Transform(aValTot[nPos,3],"@E 9,999,999.99"),"")
			EndIf
			@ nLin++, 05 pSay left(aVetImp[ni,2]+" "+aVetImp[ni,3]+" "+aVetImp[ni,4]+" "+aVetImp[ni,6]+" "+aVetImp[ni,8]+" "+aVetImp[ni,9]+" "+left(aVetImp[ni,10]+space(25),25)+" "+aVetImp[ni,12]+space(114),114)+" "+transform(aVetImp[ni,7],"@E 9,999,999.99")
		Case MV_PAR06 == 3 // marca+Modelo
			If cQuebra2 <> aVetImp[ni,9]+aVetImp[ni,10]+aVetImp[ni,11]
				cQuebra2 := aVetImp[ni,9]+aVetImp[ni,10]+aVetImp[ni,11]
				nPos := Ascan( aValTot , { |x| x[1]+x[2] == cQuebra1+cQuebra2 })
				nLin++
				@ nLin++, 03 pSay left(aVetImp[ni,9]+" "+aVetImp[ni,10]+" "+aVetImp[ni,11]+space(117),117)+IIf(nPos>0,Transform(aValTot[nPos,3],"@E 9,999,999.99"),"")
			EndIf
			@ nLin++, 05 pSay left(aVetImp[ni,2]+" "+aVetImp[ni,3]+" "+left(aVetImp[ni,4]+space(35),35)+" "+ transform(stod(aVetImp[ni,5]),"@D")+" "+aVetImp[ni,6]+" "+aVetImp[ni,8]+" "+aVetImp[ni,12]+" "+space(115),115)+transform(aVetImp[ni,7],"@E 9,999,999.99")
		Case MV_PAR06 == 4 //NF+Serie
			If cQuebra2 <> aVetImp[ni,2]
				cQuebra2 := aVetImp[ni,2]
				nPos := Ascan( aValTot , { |x| x[1]+x[2] == cQuebra1+cQuebra2 })
				nLin++
				@ nLin++, 03 pSay left(aVetImp[ni,2]+" "+aVetImp[ni,3]+" "+aVetImp[ni,4]+space(117),117)+IIf(nPos>0,Transform(aValTot[nPos,3],"@E 9,999,999.99"),"")
			EndIf
			@ nLin++, 05 pSay left(transform(stod(aVetImp[ni,5]),"@D")+" "+aVetImp[ni,6]+" "+aVetImp[ni,8]+" "+aVetImp[ni,9]+" "+aVetImp[ni,10]+" "+left(aVetImp[ni,11]+space(30),30)+" "+aVetImp[ni,12]+space(114),114)+" "+transform(aVetImp[ni,7],"@E 9,999,999.99")
		Case MV_PAR06 == 5 //Fornecedor
			If cQuebra2 <> aVetImp[ni,3]
				cQuebra2 := aVetImp[ni,3]
				nPos := Ascan( aValTot , { |x| x[1]+x[2] == cQuebra1+cQuebra2 })
				nLin++
				@ nLin++, 03 pSay left(aVetImp[ni,3]+" "+aVetImp[ni,4]+space(116),116)+" "+IIf(nPos>0,Transform(aValTot[nPos,3],"@E 9,999,999.99"),"")
			EndIf
			@ nLin++, 05 pSay left(aVetImp[ni,2]+" "+ transform(stod(aVetImp[ni,5]),"@D")+" "+aVetImp[ni,6]+" "+aVetImp[ni,8]+" "+aVetImp[ni,9]+" "+left(aVetImp[ni,10]+space(24),24)+" "+left(+aVetImp[ni,11]+space(25),25)+" "+aVetImp[ni,12]+space(114),114)+" "+transform(aVetImp[ni,7],"@E 9,999,999.99")
	EndCase
Next
Set Printer to
Set device to Screen
MS_FLUSH()
If aReturn[5] == 1
	OurSpool(cNomeRel)
EndIf
Return
//////////////////////////////////////////////////////////////////////////////////////////
/* rafael 02/01/09
Static Function ValidPerg(cPerg)
Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := left(cPerg+space(15),len(SX1->X1_GRUPO))
aAdd(aRegs,{cPerg,"01","Filial Inicial"   ,"","","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Filial Final"     ,"","","mv_ch2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Data Inicial"     ,"","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Data Final"       ,"","","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Tipo de Veiculos" ,"","","mv_ch7","N",1,0,0,"C","","mv_par05","Todos","","","","","Novos","","","","","Usados","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Ordenar por"      ,"","","mv_ch6","N",1,0,0,"C","","mv_par06","Chassi","","","","","Dt. Movto.","","","","","Marca+Modelo","","","","","NF+Serie","","","","","Fornecedor","","","","",""})
For i:=1 to Len(aRegs)
if !dbSeek(cPerg+aRegs[i,2])
RecLock("SX1",.t.)
For j:=1 to FCount()
If j <= Len(aRegs[i])
FieldPut(j,aRegs[i,j])
Endif
Next
MsUnlock()
endif
Next

dbSelectArea(_sAlias)
Return
*/
// Verifica a Base da Empresa para realizar a Consulta //
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERBASE ³ Autor ³ Rafael/Andre Luis    ³ Data ³ 13/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica a existencia dos arquivos envolvidos na Consulta. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERBASE()
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Local aSM0     := {}
Local cEmpSALVA:= cEmpAnt
Local cFilSALVA:= cFilAnt
Private bBlock := ErrorBlock()
Private bErro  := ErrorBlock( { |e| lOk := .f. } )
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
cEmpAnt := aSM0[1]
cFilAnt := aSM0[2]
cQuery := "SELECT VVF.VVF_TRACPA FROM "+RetSqlName("VVF")+" VVF WHERE VVF.VVF_TRACPA='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VVG.VVG_TRACPA FROM "+RetSqlName("VVG")+" VVG WHERE VVG.VVG_TRACPA='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VV1.VV1_CHAINT FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_CHAINT='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VV2.VV2_CODMAR FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_CODMAR='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VVC.VVC_CORVEI FROM "+RetSqlName("VVC")+" VVC WHERE VVC.VVC_CORVEI='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
ErrorBlock(bBlock)
cEmpAnt := cEmpSALVA
cFilAnt := cFilSALVA
Return(lOk)

