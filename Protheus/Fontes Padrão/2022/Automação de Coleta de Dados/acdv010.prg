#INCLUDE "acdv010.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV010    ³ Autor ³ Desenv. ACD         ³ Data ³ 27/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Liberacao/Rejeicao  de produtos via no CQ                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ACDV010()
Local nOpc

If UsaCB0("01")
	ACDV0101(1)   // produto com cb0
Else
	VTCLear()
	@ 0,0 VTSay STR0001  //'Selecione:'
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0002,STR0003})  //"Nota de Entrada"###"Producao"
	If nOpc == 1
		ACDV011()  // produto sem cb0 (Nota entrada)
	ElseIf nOpc == 2
		ACDV012()  // produto sem cb0 (Producao)
	EndIf
EndIf
Return

Function ACDV011()
ACDV0101(2)
Return
Function ACDV012()
ACDV0101(3)
Return

Static Function ACDV0101(nTipo)
Local bkey09
Local bkey24
Local oTpTab1	:= NIL
Local oTpTab2	:= NIL
Local lVolta := .F.
Private lBranco := .t.
Private cNota     := Space(TamSx3("F1_DOC")[1])
Private cSerie    := Space(SerieNfId("SF1",6,"F1_SERIE"))
Private cFornec   := Space(TamSx3("F1_FORNECE")[1])
Private cLoja     := Space(TamSx3("F1_LOJA")[1])
Private cDoc      := Space(TamSx3("D3_DOC")[1])
Private cProd     := Space(TamSX3("CB0_CODET2")[1])
Private nQtdePro  := 1
Private cArmazem  := Space(TamSX3("B2_LOCAL")[1])
Private cEndereco := Space(TamSX3("BF_LOCALIZ")[1])
Private aDist     := {}
Private aRecSD1   := {}
Private aRecSD3   := {}
Private aHisEti   := {}
Private cCondSF1  := "1 "   // variavel utilizada na consulta Sxb 'CBW'
Private lForcaQtd := GetMV("MV_CBFCQTD",,"2") =="1" // Forca foco no GET Qtde
Private lUsaEnder := .F.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

oTpTab1 := FWTemporaryTable():New( "CABTMP" )

aStru :={{"CAB_NUMRF"	,"C",3,00}}

oTpTab1:SetFields( aStru )
oTpTab1:AddIndex("indice1", {"CAB_NUMRF"} )

oTpTab1:Create()

aStru:= {}
oTpTab2 := FWTemporaryTable():New( "ITETMP" )

aStru :={	{"ITE_RECNO","C",6,00},;
	{"ITE_FILIAL","C",2,00},;
	{"ITE_NUMCQ","C",6,00},;
	{"ITE_QTD"   ,"N",12,4}}
	
oTpTab2:SetFields( aStru )
oTpTab2:AddIndex("indice1", {"ITE_RECNO","ITE_FILIAL","ITE_NUMCQ"} )
oTpTab2:AddIndex("indice2", {"ITE_FILIAL","ITE_NUMCQ"} )

oTpTab2:Create()

RegistraCab()

bkey09 := VTSetKey(09,{|| Informa()},STR0050) //"Informacao"
bKey24 := VTSetKey(24,{|| Estorna()},STR0051)   // CTRL+X //"Estorno"

If ExistBlock("ACDV10INI")
	ExecBlock("ACDV10INI",.F.,.F.,)
EndIf


If nTipo == 1
	cProd	:= Space(TamSX3("CB0_CODET2")[1])
Else
	cProd	:= IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
EndIf

While .t.
	VTClear
	@ 0,0 VTSAY STR0004  //"Liberacao/Rejeicao"
	nL := 0
	nQtdePro := 1
		If lVT100B
			If nTipo == 2 // nota
				@ 1,00 VTSAY  STR0005 VTGet cNota   pict '@!'  	when iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.)  Valid VldNota(cNota) F3 'CBW' // // //'Nota '
				@ 1,14 VTSAY '-' VTGet cSerie  pict '@!'   		 	when lBranco .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.) Valid VldNota(@cNota,@cSerie,,,.T.)
				@ 2,00 VTSAY  STR0006 VTGet cFornec pict '@!' F3 'FOR' when iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.) Valid VldNota(cNota,cSerie,cFornec) // // //'Forn.'
				@ 2,14 VTSAY '-' VTGet cLoja   pict '@!'   		 	when iif(lVolta .and. lForcaQtd,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.)  Valid (lBranco := .f.,VldNota(cNota,cSerie,cFornec,cLoja))
				@ 3,00 VTSAY  STR0007 VTGet nQtdePro   pict CBPictQtde() 	when (lForcaQtd .and. lVolta, lVolta := .F.) // // //'Qtde.'
				VTREAD
			ElseIf nTipo == 3 // producao
				@ 1,0 VTSAY  STR0008 VTGet cDoc   pict '@!' 	when iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.) Valid VldDoc(cDoc) // // //'Documento '
				@ 2,0 VTSAY  STR0007 VTGet nQtdePro   pict CBPictQtde() 	when (lForcaQtd .Or. VTLastkey() == 5)		 // // //'Qtde.'
				VTREAD
			EndIf
			
			If !(vtLastKey() == 27) .or. (nTipo != 2 .and. nTipo != 3)
				//possivel segunda tela
				lVolta := .F.
				VTClear(1,0,3,19)
				If UsaCB0("01") .and. UsaCB0("02")
					@ 1,0 VTSAY STR0009  // // //'Etiqueta'
					@ 2,0 VTGET cProd PICTURE "@!" VALID VTLastkey() == 05 .or.  VldEtiq() when iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.,lBranco := .T.),.T.)
				Else
					@ 1,0 VTSAY STR0010 VTGET cProd PICTURE "@!" VALID VTLastkey() == 05 .or. Empty(cProd) .or. VldProd() when iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.,lBranco := .T.),.T.) // // //'Produto'
					//@ ++nL,0 VTGET cProd PICTURE "@!" VALID VTLastkey() == 05 .or. Empty(cProd) .or. VldProd()
					//@ 1,0 VTSAY STR0011  // // //'Endereco'
					IF UsaCB0("02")
						@ 2,0 VTSAY STR0011 VTGET cProd PICTURE "@!" VALID  VTLastkey() == 05 .or. VldEtiq("02") // // //'Endereco'
						//@ 2,0 VTGET cProd PICTURE "@!" VALID  VTLastkey() == 05 .or. VldEtiq("02")
					Else
						//@ 2,0 VTGet cArmazem PICTURE "!!" Valid VTLastkey() == 05 .or. ! Empty(cArmazem)
						//@ 2,3 VTSAY "-" VTGET cEndereco PICTURE "@!" VALID VtLastKey()==5 .or. VldEndereco()
						@ 2,0 VTSAY STR0011 // Label Endereço 
						@ 3,0 VTGet cArmazem PICTURE "!!" Valid VTLastkey() == 05 .or. ! Empty(cArmazem) // // //'Endereco'
						@ 3,VTCOL()++ VTSAY "-" VTGET cEndereco PICTURE "@!" VALID VtLastKey()==5 .or. VldEndereco()
					EndIf
				EndIf
				VTRead	
			Endif	
			
			If lVolta
				Loop
			EndIf
		Else
			If nTipo == 2 // nota
				@ 1,00 VTSAY  STR0005 VTGet cNota   pict '@!'  	when Empty(cNota).or. VtLastkey()==5  Valid VldNota(cNota) F3 'CBW' // // //'Nota '
				@ 1,14 VTSAY '-' VTGet cSerie  pict '@!'   		 	when (Empty(cSerie) .and. lBranco) .or. VtLastkey()==5 Valid VldNota(@cNota,@cSerie,,,.T.)
				@ 2,00 VTSAY  STR0006 VTGet cFornec pict '@!' F3 'FOR' when Empty(cFornec) .or. VtLastkey()==5 Valid VldNota(cNota,cSerie,cFornec) // // //'Forn.'
				@ 2,14 VTSAY '-' VTGet cLoja   pict '@!'   		 	when Empty(cLoja) .or. VtLastkey()==5  Valid (lBranco := .f.,VldNota(cNota,cSerie,cFornec,cLoja))
				@ 3,00 VTSAY  STR0007 VTGet nQtdePro   pict CBPictQtde() 	when (lForcaQtd .Or. VTLastkey() == 5) // // //'Qtde.'
				nL := 3
			ElseIf nTipo == 3 // producao
				@ 1,0 VTSAY  STR0008 VTGet cDoc   pict '@!' 	when Empty(cDoc) .or. VtLastkey()==5 Valid VldDoc(cDoc) // // //'Documento '
				@ 2,0 VTSAY  STR0007 VTGet nQtdePro   pict CBPictQtde() 	when (lForcaQtd .Or. VTLastkey() == 5)		 // // //'Qtde.'
				nL := 2
			EndIf
			If UsaCB0("01") .and. UsaCB0("02")
				@ ++nL,0 VTSAY STR0009  // // //'Etiqueta'
				@ ++nL,0 VTGET cProd PICTURE "@!" VALID VTLastkey() == 05 .or.  VldEtiq()
			Else
				@ ++nL,0 VTSAY STR0010  // // //'Produto'
				@ ++nL,0 VTGET cProd PICTURE "@!" VALID VTLastkey() == 05 .or. Empty(cProd) .or. VldProd()
				@ ++nL,0 VTSAY STR0011  // // //'Endereco'
				IF UsaCB0("02")
					@ ++nL,0 VTGET cProd PICTURE "@!" VALID  VTLastkey() == 05 .or. VldEtiq("02")
				Else
					@ ++nL,0 VTGet cArmazem PICTURE "!!" Valid VTLastkey() == 05 .or. ! Empty(cArmazem)
					@   nL,3 VTSAY "-" VTGET cEndereco PICTURE "@!" VALID VtLastKey()==5 .or. VldEndereco()
				EndIf
			EndIf
			VTREAD
		EndIf
	If VTLASTKEY()==27
		If Empty(aDist) .or. VTYesNo(STR0012,STR0026,.T.)		  //### //### //"Saindo perdera o que foi lido, confirma saida?" //"ATENCAO"
			Exit
		EndIf
	EndIf

	If nTipo == 1
		cProd	:= Space(TamSX3("CB0_CODET2")[1])
	Else
		cProd	:= IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	EndIf

End
vtsetkey(09,bkey09)
vtsetkey(24,bkey24)

RegistraCab(.F.)
oTpTab1:Delete()
oTpTab2:Delete()
If ExistBlock("ACDV10FIM")
	ExecBlock("ACDV10FIM",.F.,.F.,)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldNota()

@author Totvs
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function VldNota(cNota,cSerie,cFornec,cLoja,lSerie)

Default cNota	:= ""
Default cSerie	:= ""
Default cFornec	:= ""
Default cLoja	:= "" 

If VtLastkey() == 05
	Return .t.
EndIf
SF1->(DbSetOrder(1))

If lSerie
	CBMULTDOC("SF1",cNota,@cSerie)
EndIf

If ! SF1->(DbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
	VTBEEP(2)
	VTALERT(STR0013,STR0014,.T.,3000)  //### //### //"Nota nao encontrada"###"AVISO"
	VTKeyBoard(chr(20))
	Return .f.
Endif
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDoc()

@author Totvs
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function VldDoc(cDoc)
SD3->(DbSetOrder(2))
If ! SD3->(DbSeek(xFilial("SD3")+cDoc))
	VTBEEP(2)
	VTALERT(STR0015,STR0014,.T.,3000)  //### //### //"Documento nao encontrado"###"AVISO"
	VTKeyBoard(chr(20))
	Return .f.
Endif
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldProd()

@author Totvs
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static function VldProd()
Local nPos      	:= 0
Local nX        	:= 0
Local nP       		:= 0
Local aEtiqueta 	:= {}
Local cChavPesq 	:= ""
Local aChavPesq 	:= ""
Local cChave    	:= ""
Local cTipDis   	:= ""
Local cNumseri  	:= Space(TamSX3("BF_NUMSERI")[1])
Local cArmCQ		:= AlmoxCQ()
Local cLote     	:= Space(TamSX3("B8_LOTECTL")[1])
Local cSLote    	:= Space(TamSX3("B8_NUMLOTE")[1])
Local aDistBKP  	:= aClone(aDist)
Local aHisEtiBKP	:= aClone(aHisEti)
Local aGrava        :={}
Local aItensPallet  := CBItPallet(cProd)
Local lIsPallet     := .t.
Local lForcaArm		:= .F.
Local cCbEndCQ		:= GetMv("MV_CBENDCQ")

If len(aItensPallet) == 0
	aItensPallet:={cProd}
	lIsPallet := .f.
EndIf

Begin Sequence
For nP:= 1 to len(aItensPallet)
	cProd :=  aItensPallet[nP]
	If UsaCB0("01")
		aEtiqueta := CBRetEti(cProd,"01")
		If Empty(aEtiqueta)
			VTBEEP(2)
			VTALERT(STR0016,STR0014,.T.,4000)   //"Etiqueta invalida."###"AVISO"
			break
		EndIf
		If ! lIsPallet .and. ! Empty(CB0->CB0_PALLET)
			VTBeep(2)
			VTALERT(STR0052,STR0014,.T.,4000) //"Etiqueta invalida, Produto pertence a um Pallet"###"AVISO"
			break
		EndIf
		If ascan(aHisEti,{|x|x[1] == cProd}) > 0
			VTBEEP(2)
			VTALERT(STR0017,STR0014,.T.,4000)   //"Produto ja foi lido."###"AVISO"
			break
		EndIf
		If aEtiqueta[10] # AlmoxCQ()
			VTBEEP(2)
			VTALERT(STR0047,STR0014,.T.,4000)   //"AVISO" //"Produto ja liberado"
			break
		EndIf
		If Localiza(cProd) .And. Empty(aEtiqueta[9])
			VTBEEP(2)
			VTALERT(STR0058,STR0014,.T.,4000)   //"AVISO" //"Produto ja rejeitado"
			break
		EndIf
		If !Empty(cCbEndCQ) .And. !(aEtiqueta[10]+Alltrim(aEtiqueta[09])+";" $ cCbEndCQ)
			VTBEEP(2)
			VTALERT(STR0048,STR0014,.T.,4000)   //"AVISO" //"Produto ja rejeitado"
			break
		EndIf	
		If Empty(aEtiqueta[4]+aEtiqueta[5]+aEtiqueta[6]+aEtiqueta[7]+aEtiqueta[11]+aEtiqueta[12])
			VTBEEP(2)
			VTALERT(STR0019,STR0014,.T.,4000)   //"Produto nao conferido"###"AVISO"
			break
		EndIf

		cNota    := aEtiqueta[4]
		cSerie   := aEtiqueta[5]
		cFornec  := aEtiqueta[6]
		cLoja    := aEtiqueta[7]
		cLote    := aEtiqueta[16]
		cSLote   := aEtiqueta[17]
		cNumseri := aEtiqueta[23]
		If CBChkSer(aEtiqueta[1])
			If !VldEndSer(cNumseri,aEtiqueta)	
				Break
			EndIf
		EndIf   
		If Localiza(aEtiqueta[1])
			lUsaEnder := .T.
		EndIf
	Else
		If ! CBLoad128(@cProd)
			break
		EndIf
		cTipId:=CBRetTipo(cProd)
		If ! cTipId $ "EAN8OU13-EAN14-EAN128"
			VTBEEP(2)
			VTALERT(STR0016,STR0014,.T.,4000)  //"Etiqueta invalida."###"AVISO"
			break
		EndIf
		aEtiqueta := CBRetEtiEAN(cProd)
		If Empty(aEtiqueta) .or. Empty(aEtiqueta[2])
			VTBEEP(2)
			VTALERT(STR0016,STR0014,.T.,4000)   //"Etiqueta invalida."###"AVISO"
			break
		EndIf
		nQE:= 1
		If ! CBProdUnit(aEtiqueta[1])
			nQE := CBQtdEmb(aEtiqueta[1])
			If empty(nQE)
				break
			EndIf
		EndIf
		aEtiqueta[2]:=aEtiqueta[2]*nQE
		cLote := aEtiqueta[3]
		If ! CBRastro(aEtiqueta[1],@cLote,@cSLote)
			break
		EndIf
		cNumseri := aEtiqueta[5]
		If CBChkSer(aEtiqueta[1])
		 	If ! CBNumSer(@cNumseri,Nil,aEtiqueta)
				Break
			EndIf	
			If !VldEndSer(cNumseri,aEtiqueta)	
				Break
			EndIf	
		EndIf   
	EndIf                               
	/* Verifica se o numero de serie ja foi lido para o produto*/
	If CBChkSer(aEtiqueta[1]) .And. Ascan(aDist,{|x| x[2]+x[9] == aEtiqueta[1]+cNumseri}) > 0
		VtAlert(STR0055,STR0014,.t.,4000)  //"Numero de Serie ja foi lido para esse produto","AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf                                   

	// quandos os elementos abaixo estiverem em branco e' porque nao foi conferido
	If ExistBlock("AIC010VPR") .and. ! ExecBlock("AIC010VPR",.F.,.F.,cProd)
		break
	EndIf
	If ! CBProdLib(AlmoxCQ(),aEtiqueta[1])
		break
	EndIF
	If !Empty(cNota+cSerie+cFornec+cLoja) .AND. IIf(UsaCB0("01"),aEtiqueta[24]<>"SD3",.T.)
		cTipDis   := "SD1"
		cChave    :=cNota+cSerie+cFornec+cLoja
		aChavPesq :=RetNumCQ(cChave+aEtiqueta[1],aEtiqueta[2]*nQtdePro,cTipDis,cLote,cSLote)
		IF Empty(aChavPesq)
			VTBEEP(2)
			VTALERT(STR0020,STR0014,.T.,4000)   //"Nao tem saldo a analisar"###"AVISO"
			break
		EndIf
	Else
		cTipDis   := "SD3"
		If UsaCB0("01")
			SD7->(DbSetOrder(3))
			If !SD7->(DbSeek(xFilial("SD7")+CB0->(CB0_CODPRO+CB0_NUMSEQ)))
				VTBEEP(2)
				VTALERT(STR0053,STR0014,.T.,4000)   //###"AVISO" //"Nao tem saldo a analisar no SD7"
				break
			EndIf
		Else
			SD3->(DbSetOrder(2))
			If ! SD3->(DbSeek(xFilial("SD3")+cDoc+aEtiqueta[1]))
				VTBEEP(2)
				VTALERT(STR0054,STR0014,.T.,4000)   //###"AVISO" //"Nao tem saldo a analisar no SD3"
				break
			Endif
			SD7->(DbSetOrder(3))
			If !SD7->(DbSeek(xFilial("SD7")+SD3->(D3_COD+D3_NUMSEQ)))
				VTBEEP(2)
				VTALERT(STR0053,STR0014,.T.,4000)   //###"AVISO" //"Nao tem saldo a analisar no SD7"
				break
			EndIf
		EndIf
		cChave := SD7->(D7_NUMERO+D7_PRODUTO+D7_LOCAL)
		aChavPesq:= RetNumCQ(cChave,aEtiqueta[2]*nQtdePro,cTipDis,cLote,cSLote)
		IF Empty(aChavPesq)
			VTBEEP(2)
			VTALERT(STR0020,STR0014,.T.,4000)   //"Nao tem saldo a analisar"###"AVISO"
			break
		EndIf
	EndIf
	For nX := 1 to len(aChavPesq)
		cChavPesq := aChavPesq[nX,1]
		aadd(aHisEti,{cProd,aEtiqueta[1],cChavPesq})
		nPos:= aScan(aDist,{|x| x[1] == cChavPesq .and. x[2] == aEtiqueta[1]})
		If nPos > 0 .And. Empty(cNumseri) 
			aDist[nPos,3] += aChavPesq[nX,2]
			aadd(aDist[nPos,5],{cProd,aEtiqueta[2],CB0->CB0_CODETI})
		Else
			aadd(aDist,{cChavPesq,aEtiqueta[1],aChavPesq[nX,2],cTipDis,{{cProd,aEtiqueta[2],CB0->CB0_CODETI}},cLote,cSLote,cArmCQ,cNumseri})
		EndIf
		aadd(aGrava,{xFilial(cTipDis),cChavPesq,aChavPesq[nX,2]})
		VTKeyBoard(chr(20))	
	Next
Next
For nX:= 1 to len(aGrava)
	GravaQtd(aGrava[nX,1],aGrava[nX,2],aGrava[nX,3])
Next
// Ponto de entrada para forcar foco no Armazem 
If ExistBlock("V010FArm")
	lForcaArm := ExecBlock("V010FArm",.f.,.f.)
	If ValType(lForcaArm)<> "L"
		lForcaArm := .f.   
    EndIf
EndIf
If lForcaArm
	VTGetSetFocus("cArmazem")
Else
	nQtdePro := 1
	VTGetRefresh("nQtdePro")
EndIf

VTKeyBoard(chr(20))	
Return .f.
End sequence
aDist  := aClone(aDistBKP)
aHisEti:= aClone(aHisEtiBKP)
nQtdePro := 1
VTGetRefresh("nQtdePro")
VTKeyBoard(chr(20))	
Return .f.


Static Function RetNumCQ(cChave,nQtde,cTipDis,cLote,cSLote)
Local aNumCQ  :={}
Local nSaldo  :=nQtde
Local nQtdBx  := 0

If cTipDis == "SD1"
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial('SD1')+cChave))
	While SD1->(!Eof() .and. xFilial('SD1')+cChave == ;
		D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD)

		If ! ( SD1->D1_LOTECTL==cLote .and. SD1->D1_NUMLOTE ==cSLote )
			SD1->(DbSkip())
			Loop
		EndIf
		If Empty(SD1->D1_NUMCQ)
			SD1->(DbSkip())
			Loop
		EndIf
		SD7->(DBSetOrder(1))
		If ! SD7->(DbSeek(xFilial("SD7")+SD1->(D1_NUMCQ+D1_COD+D1_LOCAL)))
			SD1->(DbSkip())
			loop
		EndIf
		While SD7->(! Eof() .and. D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL == xFilial("SD7")+SD1->(D1_NUMCQ+D1_COD+D1_LOCAL))
			SD7->(DbSkip())
		EndDo
		SD7->(DbSkip(-1))
		nQtdBx := RetSaldo(SD1->(D1_FILIAL+D1_NUMCQ))
		IF Empty(nQtdBx)
			SD1->(DbSkip())
			loop
		EndIf
		If nQtdBx > nSaldo
			nQtdBx :=nSaldo
		EndIf
		aadd(aNumCQ,{SD1->D1_NUMCQ,nQtdBx})
		nSaldo -=nQtdBx
		If Empty(nSaldo)
			Exit
		EndIf
		SD1->(DbSkip())
	End
ElseIf cTipDis == "SD3"
	SD7->(DBSetOrder(1))
	While SD7->(! Eof() .and. D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL == xFilial("SD7")+cChave)
		SD7->(DbSkip())
	EndDo
	SD7->(DbSkip(-1))

	nQtdBx := RetSaldo(xFilial(cTipDis)+SD7->D7_NUMERO)	

	If nQtdBx > nSaldo
		nQtdBx :=nSaldo
	EndIf

	aadd(aNumCQ,{SD7->D7_NUMERO,nQtdBx})
	nSaldo -=nQtdBx
EndIf
If nSaldo > 0
	aNumCQ :={}
EndIf
Return aNumCQ


Static Function RetSaldo(cChave)
Local nSaldo := SD7->D7_SALDO
ITETMP->(DBSetOrder(2))
ITETMP->(DbSeek(cChave))
While  ITETMP->( !Eof() .and. ITE_FILIAL+ITE_NUMCQ == cChave )
	nSaldo -= ITETMP->ITE_QTD
	ITETMP->(DbSkip())
End
ITETMP->(DBSetOrder(1))
Return nSaldo

Static Function VldEndereco()
Local cTitulo
Local nX
Local cCbEndCQ := GetMV("MV_CBENDCQ")
Local lOk      := .T.

If Empty(aDist)
	VTALERT(STR0016,STR0014,.T.,4000)    //"Etiqueta invalida."###"AVISO"
	VTClearGet()
	VTClearGet("cArmazem")
	VTGetSetFocus("cArmazem")
	Return .f.
EndIf
// Tratamento para nao obrigar a informar o endereco caso produto nao controle endereco e MV_CBENDCQ em branco
If Empty(cEndereco) .And. !lUsaEnder .And. Empty(cCbEndCQ) .And. UsaCB0("01")
	lOk := .T.
Else
	SBE->(DbSetOrder(1))
	If ! SBE->(DbSeek(xFilial("SBE")+cArmazem+cEndereco))
		VTBEEP(2)
		VTALERT(STR0022,STR0014,.T.,4000)    //"Endereco nao encontrado"###"AVISO"
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIf
	If ! CBEndLib(cArmazem,cEndereco)
		VTBEEP(2)
		VTALERT(STR0023,STR0014,.T.,4000)    //"Endereco bloqueado"###"AVISO"
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIf
EndIf
If cArmazem == AlmoxCQ()
	If !Empty(cCbEndCQ) .And. !(cArmazem+Alltrim(cEndereco)+";" $ cCbEndCQ)
		VTBEEP(2)
		VTALERT(STR0049,STR0014,.T.,4000)    //"AVISO" //"Endereco invalido"
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIf
EndIf
For nX  := 1 to len(aDist)
	If ! CBProdLib(cArmazem,aDist[nX,2],.f.)
		VTBEEP(2)
		VTALERT(STR0045+aDist[nX,2]+STR0046+cArmazem,STR0014,.t.,4000) //"Aviso" //'Produto '###' bloqueado para inventario no armazem '
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIF
Next

If cArmazem == AlmoxCQ()
	cTitulo := STR0024 //" Confirma a rejeicao dos itens? "
Else
	cTitulo := STR0025 //" Confirma a liberacao dos itens? "
EndIf
VTBEEP(2)
If VTYesNo(cTitulo,STR0026,.T.)    //"ATENCAO"
	Analisa(cEndereco,cArmazem)
	VTKeyBoard(chr(20))
	cArmazem  := Space(TamSX3("B2_LOCAL")[1])
	cEndereco := Space(TamSX3("BF_LOCALIZ")[1])
	cNota     := Space(TamSx3("F1_DOC")[1])
	cSerie    := Space(SerieNfId("SF1",6,"F1_SERIE"))
	cFornec   := Space(TamSx3("F1_FORNECE")[1])
	cLoja     := Space(TamSx3("F1_LOJA")[1])
	cDoc      := Space(TamSx3("D3_DOC")[1])
	cLote     := Space(TamSx3("D3_LOTECTL")[1])
	cSLote    := Space(TamSx3("D3_NUMLOTE")[1])
	lBranco   := .t.
	lUsaEnder := .F.
	Return .t.
EndIf
Return .f.

Static Function Analisa(cEndereco,cArmazem)
Local nI
Local nX := 0
Local aMov:={}
Local nTipo
Local aSave := VTSAVE()
Local cEndeWMS  := ""
Local cServWMS  := ""
Local aRetPE    := {}
Local lProcessa := .T.

For nI := 1 to len(aDist)
	aMov:={}
	SD7->(DBSetOrder(1))
	SD7->(DbSeek(xFilial("SD7")+aDist[nI,1]+aDist[nI,2])) // Seek com NUMCQ+PRODUTO
	If cArmazem == AlmoxCQ()
		nTipo:= 2
	Else
		nTipo:= 1
	EndIf
	If ExistBlock('A010WMSO')
		aRetPE := ExecBlock('A010WMSO', Nil, Nil, {nTipo, aDist[nI,2], cArmazem, aDist[nI,3]})
		If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
			cServWMS  := If( ValType(aRetPE[1])=="C", aRetPE[1], "" )
			cEndeWMS  := If( ValType(aRetPE[2])=="C", aRetPE[2], "" )
			lProcessa := If( ValType(aRetPE[3])=="L", aRetPE[3], .T. )
		EndIf
	EndIf	
	SD3->(DbSetOrder(7))
	SD3->(DbSeek(xFilial("SD3")+CB0->CB0_CODPROD+CB0->CB0_LOCAL+DTOS(CB0->CB0_DTNASC)+CB0->CB0_NUMSEQ))
	If lProcessa
		aadd(aMov,{nTipo,aDist[nI,3],cArmazem,dDataBase," "," ","",ConvUm(aDist[nI,2],aDist[nI,3],0,2),cEndeWMS,aDist[nI,9],cServWMS})
		fGravaCQ(aDist[nI,2],aDist[nI,1],.f.,aMov,If(SD7->D7_ORIGLAN=='CP',PegaCMD1(),PegaCMD3()),NIL)
		If Localiza(aDist[nI,2])
			Distribui(cEndereco,cArmazem,nI)
		Else
			If UsaCB0("01")
				For nX := 1 to len(aDist[nI,5])
					CBGrvEti("01",{NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cArmazem,,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aDist[nI,9]},aDist[nI,5,nX,3])
					CBLog("03",{aDist[nI,2],CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,cArmazem,CB0->CB0_LOCALI,CB0->CB0_NUMSEQ,SD7->D7_NUMERO,aDist[nI,5,nX,3]})
				Next
			Else
				CBLog("03",{aDist[nI,2],aDist[nI,3],SD7->D7_LOTECTL,SD7->D7_NUMLOTE,cArmazem,"",SD7->D7_NUMSEQ,SD7->D7_NUMERO,""})
			EndIf
		EndIf
	EndIf
Next
aDist  := {}
aHisEti:= {}
VTCLEAR
VtRestore(,,,,aSave)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³VldEtiq     ³ Autor ³ Desenv. ACD         ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do produto lido na etiqueta                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retl = Retorna .T. se validacao foi ok                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Codigo da etiqueta de produto                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEtiq(cTipoObr) //funcao utilizado quando usacb0 no produto e endereco
Local cTipId   := ""
Local aItensPallet
Local lIsPallet := .t.
DEFAULT cTipoObr := "01/02"
If Empty(cProd)
	Return .f.
EndIf

aItensPallet := CBItPallet(cProd)
If len(aItensPallet) == 0
	lIsPallet := .f.
EndIf

cTipId:=CBRetTipo(cProd)
If lIsPallet .or. (cTipId =="01"  .and. cTipId $ cTipoObr )
	VldProd()
ElseIf cTipId =="02" .and. cTipId $ cTipoObr
	aEtiqueta := CBRetEti(cProd,"02")
	If Empty(aEtiqueta)
		VTBEEP(2)
		VTALERT(STR0016,STR0014,.T.,4000)   //"Etiqueta invalida."###"AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cEndereco:=aEtiqueta[1]
	cArmazem :=aEtiqueta[2]
	Return VLDEndereco()
Else
	VTBEEP(2)
	VTALERT(STR0016,STR0014,.T.,4000)   //"Etiqueta invalida."###"AVISO"
EndIf
VTKeyBoard(chr(20))	
Return .f.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Distribui   ³ Autor ³ Desenv. ACD         ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a distribuicao no Sistema                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Distribui(cLocaliz,cLocal,nI)
Local cItem    := ""
Local cDoc     := ""
Local cNumSeq  := ""
Local cLote    := ""
Local cSLote   := ""
Local nX       := 0
Local aCab     := {}
Local aItens   := {}
Local nRec     := 0
Private lMSErroAuto := .F.

VTMSG(STR0027,1)  // // //"Aguarde..."
Begin Transaction
	SD7->(DBSetOrder(2))
	While SD7->(!EOF() .And.(D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL) == xFilial("SD7")+aDist[nI,1]+aDist[nI,2]+aDist[nI,8])
		If CBChkSer(aDist[nI,2])
			nRec := CB010RecD7(1,aDist[nI,1],aDist[nI,2],aDist[nI,8],aDist[nI,9])
			
		ElseIf !CBChkSer(aDist[nI,2])
			nRec := CB010RecD7(2,aDist[nI,1],aDist[nI,2],aDist[nI,8],aDist[nI,9])
		EndIf
		If nRec > 0
			SD7->(MsGoto(nRec))
			
		EndIf	
		cDoc    := SD7->D7_NUMERO
		cNumSeq := SD7->D7_NUMSEQ
		cLote   := SD7->D7_LOTECTL
		cSLote  := SD7->D7_NUMLOTE
		cItem := Item(nI,cLocal,cLocaliz,cNumSeq)
		aCAB  :={{"DA_PRODUTO",aDist[nI,2]   , nil},;
		{"DA_LOCAL"  ,cLocal          , nil},;
		{"DA_NUMSEQ" ,cNumSeq         , nil},; //relacionado ao campo D1_NUMSEQ
		{"DA_DOC"    ,cDoc            , nil}} //Relacionado ao campo F1_DOC ou D1_DOC
		
		aITENS:={{{"DB_ITEM"   ,cItem , nil},;
		{"DB_LOCALIZ",cLocaliz        , nil},;
		{"DB_QUANT"  ,aDist[nI,3]     , nil},;
		{"DB_DATA"   ,dDATABASE       , nil},;
		{"DB_LOTECTL",cLote 		  ,nil},;
		{"DB_NUMLOTE",cSLote		  ,nil},;
		{"DB_NUMSERI",aDist[nI][9],  ,nil}}}	
		//esta variavel deverah ser retirada mais tarde
		nModuloOld  := nModulo
		nModulo     := 4
		lMSHelpAuto := .T.
		lMSErroAuto := .F.
		msExecAuto({|x,y|mata265(x,y)},aCab,aItens)
		nModulo := nModuloOld
		lMSHelpAuto := .F.
		If lMSErroAuto
			DisarmTransaction()
			VTBEEP(2)
			VTALERT(STR0028,STR0029,.T.,4000)   //"Falha no processo de distribuicao."###"ERRO"
			Break
		EndIf
		If UsaCB0("01")
			For nX := 1 to len(aDist[nI,5])
				CBGrvEti("01",{NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cLocaliz,cLocaL,,cNumSeq,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aDist[nI,9]},aDist[nI,5,nX,1])
				CBLog("03",{aDist[nI,2],CB0->CB0_QTDE,cLote,cSLote,cLocal,cLocaliz,cNumSeq,cDoc,aDist[nI,5,nX,1]})
			Next
		Else
			CBLog("03",{aDist[nI,2],aDist[nI,3],cLote,cSLote,cLocal,cLocaliz,cNumSeq,cDoc,""})
		EndIf
		RegistraCab(.t.)
		SD7->(DbSkip())
	End		
End Transaction
If lMsErroAuto
	VTDispFile(NomeAutoLog(),.t.)
Endif
Return

Static Function Item(nPos,cLocal,Localiz,cNumSeq)
Local cItem     := ""
SDB->(dbSetOrder(1))
If SDB->(dbSeek(xFilial("SDB")+aDist[nPos,2]+cLocal+aDist[nPos,1]))
	While SDB->(!EOF() .and. xFilial("SDB")+aDist[nPos,2]+cLocal+aDist[nPos,1] ==;
		DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ)
		cItem := SDB->DB_ITEM
		SDB->(dbSkip())
	end
	cItem := strzero(val(cItem)+1,3)
Else
	cItem := "001"
EndIf
Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Informa    ³ Autor ³ Desenv. ACD         ³ Data ³ 30/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local aCab,aSize,aSave := VTSAVE()
Local nX,nPos
Local aTemp:={}
VTClear()
If  UsaCB0("01")
	aCab  := {STR0030,STR0031}   //"Etiqueta"###"Produto"
	aSize := {10,16}
	aTemp := aClone(aHisEti)
Else
	aCab  := {STR0031,STR0032,STR0033,STR0034,STR0056}   //"Produto"###"Quantidade"###"Lote"###"SubLote###""Nr. de Serie""
	aSize := {15,12,10,7,20}
	aHisEti:= {}
	For nx:= 1 to len(aDist)
		nPos := Ascan(aTemp,{|x| x[1] == aDist[nx,2] .and. x[3] == aDist[nx,6] .and. x[4] == aDist[nx,7] .And. x[5] == aDist[nx,9]})
		IF nPos == 0
			aadd(aTemp,{aDist[nx,2],aDist[nX,3],aDist[nX,6],aDist[nX,7],aDist[nx,9]})
		Else
			aTemp[nPos,2] += aDist[nX,3]
		endIf
	Next
EndIf
VTaBrowse(0,0,7,19,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
Return

Static Function Estorna()
Local aTela
Local cEtiqueta
aTela := VTSave()
VTClear()
cEtiqueta := Space(20)
nQtdePro  := 1
@ 00,00 VtSay Padc(STR0037,VTMaxCol())  // // //"Estorno da Leitura"
If ! UsaCB0('01')
	@ 1,00 VTSAY  STR0038 // //'Qtde. '
	@ 1,05 VTGet nQtdePro   pict CBPictQtde() when VTLastkey() == 5 //
EndIf
@ 02,00 VtSay STR0039  // // //"Etiqueta:"
@ 03,00 VtGet cEtiqueta pict "@!" Valid VldEstorno(cEtiqueta,nQtdePro)
VtRead
vtRestore(,,,,aTela)
Return

Static Function VldEstorno(cEtiqueta,nQtdePro)
Local nPos,cKey,nQtd,cProd,nPosID,cNumseri
Local nX,nP
Local aEtiqueta,nSaldo,nQtdeBx
Local cLote     := Space(TamSX3("B8_LOTECTL")[1])
Local cSLote    := Space(TamSX3("B8_NUMLOTE")[1])
Local aDistBKP  := aClone(aDist)
Local aHisEtiBKP:= aClone(aHisEti)
Local aGrava    :={}
Local aItensPallet := CBItPallet(cEtiqueta)
Local lIsPallet:= .t.
Local nTamNSerie := TamSX3("BF_NUMSERI")[1]

If Empty(cEtiqueta)
	Return .f.
EndIF

If len(aItensPallet) == 0
	aItensPallet:={cEtiqueta}
	lIsPallet := .f.
EndIf
Begin Sequence
For nP:= 1 to len(aItensPallet)
	cEtiqueta := aItensPallet[nP]
	If UsaCB0("01")
		nPos := Ascan(aHisEti, {|x| AllTrim(x[1]) == AllTrim(cEtiqueta)})
		If nPos == 0
			VTBeep(2)
			VTALERT(STR0040,STR0014,.T.,4000)    //"Etiqueta nao encontrada"###"AVISO"
			Break
		EndIf
		If ! lIsPallet .and. ! Empty(CB0->CB0_PALLET)
			VTBeep(2)
			VTALERT(STR0052,STR0014,.T.,4000) //"Etiqueta invalida, Produto pertence a um Pallet"###"AVISO"
			break
		EndIf
	Else
		If ! CBLoad128(@cEtiqueta)
			Break
		EndIf
		aEtiqueta := CBRetEtiEAN(cEtiqueta)
		IF Len(aEtiqueta) == 0
			VTBeep(2)
			VTALERT(STR0041,STR0014,.T.,4000)    //"Etiqueta invalida"###"AVISO"
			Break
		EndIf
		cLote := aEtiqueta[3]
		If ! CBRastro(aEtiqueta[1],@cLote,@cSLote)
			VTBeep(2)
			VTALERT(STR0042,STR0014,.T.,4000)    //"Lote invalido"###"AVISO"
			Break
		EndIf
	EndIf
	If UsaCB0("01")
		//Estorno do aHisEti
		cKey := aHisEti[nPos,3]
		cProd:= aHisEti[nPos,2]
		nQtd := CBRetEti(cEtiqueta,'01')[2]
		aDel(aHisEti,nPos)
		aSize(aHisEti,Len(aHisEti)-1)
		//Estorno do aDist
		nPos := aScan(aDist,{|x| AllTrim(x[1]) == Alltrim(cKey) .and. x[2] == cProd})
		aadd(aGrava,{xFilial(aDist[nPos,4]),aDist[nPos,1],nQtd*-1})
		aDist[nPos,3] := aDist[nPos,3] - nQtd
		If Empty(aDist[nPos,3])
			aDel(aDist,nPos)
			aSize(aDist,Len(aDist)-1)
		Else
			nPosID := Ascan(aDist[nPos,5],{|x| Alltrim(x[1]) == Alltrim(cEtiqueta)})
			aDel(aDist[nPos,5],nPosID)
			aSize(aDist[nPos,5],Len(aDist[nPos,5])-1)
		EndIf
	Else
		cProd     := aEtiqueta[1]
		nQtde     := aEtiqueta[2]
		nSaldo    := 0
		cNumseri  := Space(nTamNSerie)
		cNumseri := aEtiqueta[5]
		If CBChkSer(aEtiqueta[1]) .And. ! CBNumSer(@cNumseri,Nil,aEtiqueta)
			Break
		EndIf 
		For nx:= 1 to len(aDist)
			If ! (aDist[nX,2] == cProd .and. aDist[nX,6] == cLote .and. aDist[nX,7] == cSLote .and. aDist[nX,9] == cNumseri)
				Loop
			EndIf
			nSaldo += aDist[nX,3]
			If nSaldo >= (nQtde*nQtdePro)
				Exit
			EndIf
		Next
		If  nSaldo < (nQtde*nQtdePro)
			VTBeep(2)
			VTALERT(STR0044,STR0014,.T.,4000)    // // //"Saldo insuficiente"###"AVISO"
			Break
		EndIf
		nSaldo := (nQtde*nQtdePro)
		nQtdeBx:= 0
		For nx:= 1 to len(aDist)
			If nX > Len(aDist)
				Exit
			EndIF
			If ! (aDist[nX,2] == cProd .and. aDist[nX,6] == cLote .and. aDist[nX,7] == cSLote .And. aDist[nX,9] == cNumseri)
				Loop
			EndIf
			If nSaldo ==0
				Exit
			EndIf
			If aDist[nx,3] <= nSaldo
				nQtdeBx := aDist[nx,3]
			Else
				nQtdeBx := nSaldo
			EndIf
			aadd(aGrava,{xFilial(aDist[nx,4]),aDist[nx,1],nQtdeBx*-1})
			aDist[nx,3] := aDist[nx,3] - nQtdeBx
			nSaldo -= nQtdeBx
			If Empty(aDist[nx,3])
				aDel(aDist,nx)
				aSize(aDist,Len(aDist)-1)
				nX--
				Loop
			EndIf
		Next
	EndIf
Next

If ! VTYesNo(STR0037,STR0026,.t.)  //### //"Confirma o estorno desta Etiqueta?"###"ATENCAO"
	Break
EndIf
For nX:= 1 to len(aGrava)
	GravaQtd(aGrava[nX,1],aGrava[nX,2],aGrava[nX,3])
Next
nQtdePro := 1
VTGetRefresh("nQtdePro")
VTKeyBoard(chr(20))
Return .f.
End Sequence
aDist  := aClone(aDistBKP)
aHisEti:= aClone(aHisEtiBKP)
nQtdePro := 1
VTGetRefresh("nQtdePro")
VTKeyBoard(chr(20))
Return .f.

Static Function RegistraCab(lRegistra)
DEFAULT lRegistra:= .T.
CABTMP->(DbGotop())
ITETMP->(DbSetOrder(1))
While !  CABTMP->(eof())
	If ! CABTMP->(Rlock())
		CABTMP->(DbSkip())
		Loop
	EndIf
	While ITETMP->(DBSEEK(Str(CABTMP->(Recno()),6)))
		RecLock("ITETMP",.f.)
		ITETMP->(DBDelete())
		ITETMP->(MsUnLock())
	End
	CABTMP->(DBDelete())
	CABTMP->(MsUnLock())
	CABTMP->(DbSkip())
End
//- Elimina os itens que estão sobrando sem cabecalho
ITETMP->(DbGotop())
While ITETMP->(!Eof())
	CABTMP->(dbGoto(Val(ITETMP->(ITE_RECNO))))
	If CABTMP->(DELETED())
		RecLock("ITETMP",.f.)
		ITETMP->(DBDelete())
		ITETMP->(MsUnLock())
	EndIf
	ITETMP->(dbSkip())
EndDo
If lRegistra
	RecLock("CABTMP",.t.)
	CABTMP->CAB_NUMRF := VTNUMRF()
	CABTMP->(MsUnlock())
	RecLock("CABTMP",.f.)
EndIf
Return .t.

Static function GravaQtd(cFilTmp,cNumCQ,qtde)
ITETMP->(DbSetOrder(1))
If ! ITETMP->(DBSeek(Str(CABTMP->(Recno()),6)+cFilTmp+cNumCQ))
	RecLock("ITETMP",.t.)
	ITETMP->ITE_RECNO:= Str(CABTMP->(Recno()),6)
	ITETMP->ITE_FILIAL := cFilTmp
	ITETMP->ITE_NUMCQ:=cNumCQ
Else
	RecLock("ITETMP",.f.)
EndIf
ITETMP->ITE_QTD   += Qtde
ITETMP->(MsUnLock())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldEndSer ºAutor  ³Aecio Ferreira Gomes     º Data ³  24/04/09           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida existencia do numero de Serie.                                    º±±
±±º          ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACDV010                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEndSer(cNumseri,aEtiqueta)
Local lRet   := .t. 

SBF->(dbSetOrder(4))

If Empty(cNumseri) 
  	VtAlert(STR0057,STR0014,.t.,4000)
    Return lRet := .f.
EndIf

If ! SBF->(DbSeek(xFilial('SBF')+aEtiqueta[1]+cNumseri))
	Help(" ",1,"SALDOLOCLZ")
    Return lRet:=.F.
EndIf			
    
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CB010RecD7ºAutor  ³Isaias Florencio         º Data ³  14/10/2014         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Recno() do ultimo registro da movimentacao SD7                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACDV010                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CB010RecD7(nOpc,cNumDoc,cProd,cLocal,cNumSerie)
Local aAreaAnt := GetArea()
Local nRecno   := 0


	Local cAliasTmp	:= GetNextAlias()
	Local cQuery     	:= ''
	
	cQuery := "SELECT MAX(SD7.R_E_C_N_O_) AS RECNO FROM "+ RetSqlName("SD7")+" SD7 "
	cQuery += "WHERE SD7.D7_FILIAL	= '" + xFilial('SD7') + "' AND "
	cQuery += "SD7.D7_PRODUTO = '" + cProd   + "' AND SD7.D7_LOCAL = '"+ cLocal + "' AND "
	cQuery += "SD7.D7_NUMERO  = '" + cNumDoc + "' AND "
	If nOpc == 1 // Utiliza numero de serie
		cQuery += "SD7.D7_NUMSERI  = '"+ cNumSerie + "' AND "
	EndIf	
	cQuery += "SD7.D_E_L_E_T_   = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	If (cAliasTmp)->(!Eof())
		nRecno := (cAliasTmp)->RECNO
	EndIf
	
	(cAliasTmp)->(DbCloseArea())

RestArea(aAreaAnt)
Return nRecno

