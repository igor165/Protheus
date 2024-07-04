#Include "Protheus.ch" 
#Include "VEIVR240.CH"

   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVR240 ³ Autor ³ Luis Delorme          ³ Data ³ 02/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Estoque Mínimo de Veículos                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR240

Local cDesc1	 := STR0001 // Relatorio de Estoque Mínimo de Veículos
Local cDesc2	 := ""                
Local cDesc3	 := ""
Local cAlias	 := "SD1" 
Private nLin 	 := 90
Private aReturn := { STR0003, 1,STR0004, 2, 2, 1, "",1 }  //Zebrado # Administracao
Private cTamanho:= "M"     	// P/M/G   												
Private Limite  := 132     	// 80/132/220        									
Private nCaracter:=15
Private aOrdem  := {}      	// Ordem do Relatorio									
Private cTitulo := STR0002 	//Movimento de Entrada e Saida de Veiculos				
Private cNomProg:= "VEIVR240"
Private cNomeRel:= "VEIVR240"
Private nLastKey:= 0                       
Private cLivFol := " " 	//GetMv("MV_LIVFOL")
Private nLivro  := 0 	//val(substr(cLivFol,1,3))
Private nFolha  := 0 	//val(substr(cLivFol,4,4))
Private nNumFol := 0
Private cPerg := ""
//
cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
//
If nLastKey == 27
	Return
EndIf  
//
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| ImpVVR240(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ImpVVR240 ³ Autor ³ Luis Delorme         ³ Data ³ 02/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Estoque Mínimo de Veículos                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpVVR240(lEnd,wNRel,cAlias)
Local ni := 1 
Local j:=1
Local cGruVei  := left(GetNewPar("MV_GRUVEI","VEIC")+space(10),len(SB1->B1_GRUPO))
Local cQuery    := ""
//
Private Li    := 80
Private m_Pag := 1
Private lAbortPrint := .f.
Private cabec1 := ""
Private cabec2 := ""
Private aVeics := {}
Private cQAlVV1 := "SQLVV1" // SD1
//
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
//
cQuery := "SELECT VV1_CODMAR, VV1_MODVEI, VV1_CORVEI, COUNT(VV1_CHAINT) CONT "
cQuery += " FROM "+RetSqlName("VV1")+" VV1, "+ RetSqlName("VV2")+" VV2,"+ RetSqlName("VVC")+" VVC"
cQuery += " WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND"
cQuery += " VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND"
cQuery += " VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND"
cQuery += " VV1_SITVEI != '1' AND VV1_SITVEI != ' ' AND "
cQuery += " VV1_CODMAR = VV2_CODMAR AND VV1_MODVEI = VV2_MODVEI AND"
cQuery += " VV1_CODMAR = VVC_CODMAR AND VV1_CORVEI = VVC_CORVEI AND"
cQuery += " VV1.D_E_L_E_T_=' ' AND VVC.D_E_L_E_T_=' ' AND VV2.D_E_L_E_T_=' ' "
cQuery += " GROUP BY VV1_CODMAR, VV1_MODVEI, VV1_CORVEI ORDER BY VV1_CODMAR, VV1_MODVEI, VV1_CORVEI"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. ) 
While !( cQAlVV1 )->( Eof() )
	aAdd(aVeics,{ (cQAlVV1)->(VV1_CODMAR), (cQAlVV1)->(VV1_MODVEI), (cQAlVV1)->(VV1_CORVEI), (cQAlVV1)->(CONT) } )
	( cQAlVV1 )->( DbSkip() )
Enddo
( cQAlVV1 )->( DbCloseArea() )
//
DBSelectArea("VRI")
DBSetOrder(1)
DBSeek(xFilial("VRI"))
//
while !eof() .and. xFilial("VRI") == VRI->VRI_FILIAL 
	nTotEst := 0
	if Empty(VRI->VRI_CORVEI)
		ix1 := aScan(aVeics, {|x| x[1]+x[2] == VRI->VRI_CODMAR + VRI->VRI_MODVEI })
		while ix1> 0 .and. ix1 <= Len(aVeics) .and. VRI->VRI_CODMAR + VRI->VRI_MODVEI == aVeics[ix1,1]+aVeics[ix1,2]
			nTotEst += aVeics[ix1,4]
			ix1++
		enddo
	else	
		ix1 := aScan(aVeics, {|x| x[1]+x[2]+x[3] == VRI->VRI_CODMAR + VRI->VRI_MODVEI + VRI->VRI_CORVEI})
	endif
	if nLin > 55 
		nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,cTamanho,nCaracter,,.f.) + 1 
		nLin++
		@nLin++,1 psay "Mar Modelo                                                    Cor                               E.Min Lot.Ec Pt.Ped Lot.Mn  Estoq"
		nLin ++
	endif

	DBSelectArea("VVC")
	DBSetOrder(1)
	DBSeek(xFilial("VVC")+VRI->VRI_CODMAR+VRI->VRI_CORVEI)
	//
	DBSelectArea("VV2")
	DBSetOrder(1)
	DBSeek(xFilial("VV2")+VRI->VRI_CODMAR+VRI->VRI_MODVEI)
	if ix1 > 0
		@nLin++,1 psay VRI->VRI_CODMAR + " " + VRI->VRI_MODVEI + " - "+Left(VV2->VV2_DESMOD,24)+ " "+ VRI->VRI_CORVEI+ " - "+Left(VVC->VVC_DESCRI,24) + " "+ Transform(VRI->VRI_ESTMIN,"@E 99999") +;
		"  "+ Transform(VRI->VRI_LOTECO,"@E 99999") + "  "+ Transform(VRI->VRI_PTOPED,"@E 99999")  + "  "+ Transform(VRI->VRI_LOTMIN,"@E 99999") +"  "+;
		Transform(IIF(Empty(VRI->VRI_CORVEI),nTotEst,aVeics[ix1,4]),"@E 99999")
	else
		@nLin++,1 psay VRI->VRI_CODMAR + " " + VRI->VRI_MODVEI + " - "+Left(VV2->VV2_DESMOD,24)+ " "+ VRI->VRI_CORVEI+ " - "+Left(VVC->VVC_DESCRI,24) + " "+ Transform(VRI->VRI_ESTMIN,"@E 99999") +;
		"  "+ Transform(VRI->VRI_LOTECO,"@E 99999") + "  "+ Transform(VRI->VRI_PTOPED,"@E 99999")  + "  "+ Transform(VRI->VRI_LOTMIN,"@E 99999") +"  "+;
		Transform(0,"@E 99999")
	endif
	DBSelectArea("VRI")
	DBSkip()
enddo
//
Ms_Flush()
Set Printer to
Set Device  to Screen              
//
Return