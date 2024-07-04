#INCLUDE "PROTHEUS.CH"

//Posicoes do array de impostos
#DEFINE IVA  01   
#DEFINE MAX_DEFIMP  07   
Static oTmpTable := NiL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCITI_ARG  ณ Autor ณMarcello               ณ Data ณ20/10/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณCITI - Argentina                                            ณฑฑ
ฑฑณ          ณCruzamiento Informatico de Transaciones Importantes         ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณArquivo com as rotinas para geracao dos arquivos temporariosณฑฑ
ฑฑณ          ณcom os dados para criacao dos arquivos txt.                 ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ13/01/2017ณLuis Enrํquez  ณ-SERINN001-676-Se realiza merge para reali- ณฑฑ
ฑฑณ          ณ               ณ zar modificaci๓n en creaci๓n de tablas     ณฑฑ
ฑฑณ          ณ               ณ temp. CTREE.                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCITIVENT  บAutor  ณMarcello            บFecha ณ 25/10/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o arquivo temporario com os dados referentes a vendas  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CITI - Argentina                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CITIVENT()
Local aArea		:= GetArea()
Local aEstru	:= {}
Local aSF3		:= {}
Local aImps		:= {}
Local dDtDigit  := Ctod("//")
Local nImp		:= 0
Local nI		:= 0
Local nTamFat	:= 0
Local nTotIsen  := 0
Local nTotNAlc  := 0
Local nNrAlqIVA := 0
Local nNetoGrv	:= 0
Local nImpLiq	:= 0
Local nDecimais := MsDecimais(1)
Local cImpIVA	:= GetNewPar("MV_CITIIVA","IVA|IV1|IV3|IV7|IV8")
Local cFilSF3	:= ""
Local cAliasTmp	:= "R02"
Local cAliasSF	:= ""
Local cAliasCF	:= ""
Local cArqTmp	:= ""
Local cTipoComp	:= ""
Local cSFDoc	:= ""
Local cFecha	:= ""
Local cCUIT		:= ""
Local cNombre   := ""
Local cNotaAtu	:= ""
Local cQuery	:= ""
Local cFatura	:= ""
Local cDocId	:= ""
Local cCompHasta:= ""
Local lOk		:= .T.
	Local aOrdem := {}

Private aDImps    := Array(MAX_DEFIMP,03)
Private nMoedaCor := 0
Private nTaxaMoeda:= 0
Private cAliasSF3 := ""

//Dados referentes a categoria IVA
aDImps[IVA][1] := "IVA"
aDImps[IVA][2] := AllTrim(cImpIVA) 
aDImps[IVA][3] := {}
/**/
nTamFat:= TamSX3("F3_NFISCAL")[1]
aEstru :=	{	{"ORDREG"    ,"C",03,00},;
				{"TIPOREG"   ,"C",01,00},;
				{"FECHACOMP" ,"C",08,00},;
				{"TIPOCOMP"  ,"C",02,00},;
				{"CONTRFISC" ,"C",01,00},;
				{"PUNTOVENTA","C",04,00},;
				{"NRCOMP"    ,"C",20,00},;
				{"NRCOMPHAST","C",20,00},;
				{"CODDOCID"  ,"C",02,00},;
				{"IDCOMPR"   ,"C",11,00},;
				{"DENOCOMPR" ,"C",30,00},;
				{"IMPORTTL"  ,"N",15,02},;
				{"TTLCONCEPT","N",15,02},;
				{"NETOGRAV"  ,"N",15,02},;
				{"ALICIVA"   ,"N",05,02},;
				{"IMPLIQUID" ,"N",15,02},;
				{"IMPLIQRNI" ,"N",15,02},;
				{"OPEREXENT" ,"N",15,02},;
				{"PERCEPPAG" ,"N",15,02},;
				{"PERCEPIB"  ,"N",15,02},;
				{"PERCIMPMUN","N",15,02},;
				{"IMPINTERN" ,"N",15,02},;
				{"TIPORESP"  ,"C",02,00},;
				{"CODMONEDA" ,"C",03,00},;
				{"TIPOCAMB"  ,"N",10,00},;
				{"CANTALIIVA","N",01,00},;
				{"CODOPER"   ,"C",01,00},;
				{"CAI"       ,"C",14,00},;
				{"FECHAVENC" ,"C",08,00},;
				{"FECHAANUL" ,"C",08,00},;
				{"INFOADIC"  ,"C",75,00},;
				{"FCPGRETENC","C",08,00},;
				{"RETENCION" ,"N",15,02},;
				{"FATURA"    ,"C",nTamFat,00},;
				{"ENTRADA"   ,"C",08,00}}
	oTmpTable := FWTemporaryTable():New(cAliasTmp) 
	oTmpTable:SetFields( aEstru ) 
	aOrdem	:=	{"IDCOMPR","ENTRADA","FATURA","ORDREG"} 
	oTmpTable:AddIndex("IN1", aOrdem) 
	oTmpTable:Create() 	
aSF3 := SF3->(GetArea())
cFilSF3 := xFilial("SF3")
cQuery := ""
nI := 0
#IFDEF TOP
	cAliasSF3 := GetNextAlias()
	cQuery := "select * from " + RetSqlName("SF3")
	cQuery += " where F3_FILIAL = '" + cFilSF3 + "'"
	cQuery += " and F3_EMISSAO between '" + Dtos(dDmaInc) + "' and '" + Dtos(dDmaFin) + "'"
	cQuery += " and F3_TIPOMOV = 'V'"
	cQuery += " and F3_DTCANC = ''"
	cQuery += " and D_E_L_E_T_ =''"
	cQuery += " order by F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_CLIEFOR,F3_LOJA"	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasSF3, .F., .T.)
	dbSelectArea(cAliasSF3)
	aEstru := SF3->(DbStruct())
	For nI := 1 To Len(aEstru)
		If aEstru[nI][2] != "C" .And. FieldPos(aEstru[nI][1]) != 0
			TCSetField(cAliasSF3, aEstru[nI][1], aEstru[nI][2], aEstru[nI][3], aEstru[nI][4])
		EndIf
	Next nI
	(cAliasSF3)->(DbGoTop())
#ELSE
	cAliasSF3 := "SF3"
	DbSelectArea("SF3")
	DbSetOrder(1)
	DbSeek(xFilial("SF3") + Substr(Dtos(dDmaInc),1,6),.F.)
#ENDIF
lOk := .T.
cNotaAtu := ""
SD2->(dbSetOrder(3))
SD1->(dbSetOrder(1))
DbSelectArea(cAliasSF3)
ProcRegua((cAliasSF3)->(RecCount()))
While (cAliasSF3)->(!Eof()) .And. (cAliasSF3)->F3_FILIAL == cFilSF3
	If cNotaAtu <> (cAliasSF3)->(F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE)
		IncProc((cAliasSF3)->F3_NFISCAL)
		cNotaAtu := (cAliasSF3)->(F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE)
		#IFNDEF TOP
			lOk := ((cAliasSF3)->F3_TIPOMOV == "V" .And. (cAliasSF3)->F3_ENTRADA >= dDmaInc .And. (cAliasSF3)->F3_ENTRADA <= dDmaFin .And. Empty(F3_DTCANC))
		#ENDIF
		If lOk
			aAliq     := {}
			aAliqAux  := {}
				cAliasSF  := IIf((cAliasSF3)->F3_TES < "500","SF1","SF2")
				cAliasSD  := IIf((cAliasSF3)->F3_TES < "500","SD1","SD2")
			cAliasCF  := "SA1"
			(cAliasSF)->(DbSetOrder(1))
			(cAliasSF)->(DbSeek(xFilial(cAliasSF) + (cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))
				nMoedaCor  := (cAliasSF)->(&(SubStr(cAliasSF,2,2)+"_MOEDA"))
				nTaxaMoeda := (cAliasSF)->(&(SubStr(cAliasSF,2,2)+"_TXMOEDA"))
				nTotal     := (cAliasSF)->(&(SubStr(cAliasSF,2,2)+"_VALBRUT"))
			nTotal     := Round(xMoeda(nTotal,nMoedaCor,1,(cAliasSF3)->F3_ENTRADA,nDecimais+1,nTaxaMoeda),nDecimais)	
			dDtDigit   := (cAliasSF)->(SubStr(cAliasSF,2,2)+"_DTDIGIT")
			nOperExent := 0
			nTtlConc   := 0
			aImps      := {}
			(cAliasSD)->(dbSeek(xFilial(cAliasSD) + (cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))
    		While !(cAliasSD)->(Eof()) .And. xFilial(cAliasSD)+(cAliasSD)->(SubStr(cAliasSD,2,2)+"_DOC")+(cAliasSD)->(SubStr(cAliasSD,2,2)+"_SERIE")+(cAliasSD)->(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE"))+(cAliasSD)->(SubStr(cAliasSD,2,2)+"_LOJA") ==;
  	                           			xFilial(cAliasSD)+(cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA
				aAliqAux := PesqInfImp(cAliasSD,IVA,"3",(cAliasSD)->(SubStr(cAliasSD,2,2)+"_TES"),"2")

			   	For nI := 1 To Len(aAliqAux)  
			    	naliq:=aALiqAux[nI]
		       		aALiqAux[nI]:=Iif(type("naliq")=="U",0,naliq)
		    	Next nI
		    	
		    	For nI := 1 To Len(aAliqAux)
					If aScan(aAliq,{|x| x == aAliqAux[nI]}) == 0
						AAdd(aAliq,aAliqAux[nI])
					EndIf
					If aAliqAux[nI] == 0
						IndExGrv(aAliqAux[nI],@nOperExent,@nTtlConc,cAliasSD,.F.)
					EndIf
				Next nI        
				AAdd(aImps,aClone(aDImps))
				(cAliasSD)->(dbSkip())
 			Enddo
 			If nOperExent<> 0 .And. nMoedaCor<> 1
				nOperExent     := Round(xMoeda(nOperExent,nMoedaCor,1,(cAliasSF3)->F3_ENTRADA,nDecimais+1,nTaxaMoeda),nDecimais)	
			EndIf
			nNrAlqIVA := Len(aAliq)
			If cAliasSF == "SF2"
				cLiqProd := SF2->F2_LIQPROD
			EndIf 
			If nNrAlqIVA > 0
				aAliq := aSort(aAliq)
				cTipoComp	:= CITITpComp(cAliasSF,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_ESPECIE)
				cSFDoc 		:= M991NrComp((cAliasSF3)->F3_NFISCAL,cTipoComp)
				cFecha		:= Dtos((cAliasSF3)->F3_EMISSAO)
				cFatura		:= (cAliasSF3)->F3_NFISCAL
				/**/
				cCompHasta  := cSFDoc
				cSFDoc		:= PadL(AllTrim(SubStr(cSFDoc,1,4)),4,"0") + PadL(Alltrim(SubStr(cSFDoc,5,8)),20,"0")
				cCompHasta  := PadL(Alltrim(SubStr(cCompHasta,5,8)),20,"0")
				cNombre		:= PadR(PesqIdCliFor(cAliasCF,"4",nTotal),25)
				cDocID      := PesqIdCliFor(cAliasCF,"1",nTotal)
				cCUIT		:= PadL(PesqIdCliFor(cAliasCF,"2",nTotal),11,"0")
				lexento:= .F.
				For nI := 1 To nNrAlqIVA
					nNetoGrv := Round(xMoeda(TotCat(IVA,"1",aImps,"2",,aAliq,aAliq[nI],.F.),nMoedaCor,1,(cAliasSF3)->F3_ENTRADA,nDecimais+1,nTaxaMoeda),nDecimais)
					nImpLiq  := Round(xMoeda(TotCat(IVA,"2",aImps,"2",,aAliq,aAliq[nI],.F.),nMoedaCor,1,(cAliasSF3)->F3_ENTRADA,nDecimais+1,nTaxaMoeda),nDecimais)
					DbSelectArea(cAliasTmp)
					RecLock(cAliasTmp,.T.)      
					Replace ORDREG		With If(aAliq[nI]==0,"ZZZ",StrZero(nI,3))
					Replace TIPOREG		With "1"
					Replace FECHACOMP	With cFecha
					Replace TIPOCOMP	With cTipoComp
					Replace CONTRFISC	With " "
					Replace PUNTOVENTA	With Substr(cSFDoc,1,4)
					Replace NRCOMP		With Substr(cSFDoc,5)
					Replace NRCOMPHAST	With cCompHasta
					Replace CODDOCID	With cDocID
					Replace IDCOMPR		With cCuit
					Replace DENOCOMPR	With cNombre 
					If aAliq[nI]== 0
						lexento:= .T.
					EndIf
					Replace IMPORTTL	With If((nI==nNrAlqIVA .And. !lexento) .or. aAliq[nI]== 0 ,nTotal,0)
					Replace TTLCONCEPT	With If(nI==nNrAlqIVA .Or. aAliq[nI]==0,nTtlConc,0)
					Replace NETOGRAV	With nNetoGrv
					Replace ALICIVA		With aAliq[nI]
					Replace IMPLIQUID	With nImpLiq
					Replace IMPLIQRNI	With 0
					Replace OPEREXENT	With If(aAliq[nI]==0,nOperExent,0)
					Replace PERCEPPAG	With 0
					Replace PERCEPIB	With 0
					Replace PERCIMPMUN	With 0
					Replace IMPINTERN	With 0
					Replace TIPORESP	With "00"
					Replace CODMONEDA	With "   "
					Replace TIPOCAMB	With 0
					Replace CANTALIIVA	With nNrAlqIVA
					Replace CODOPER		With " "
					Replace CAI			With Replicate("0",14)
					Replace FECHAVENC	With "00000000"
					Replace FECHAANUL	With "00000000"
					Replace INFOADIC	With " "
					Replace FCPGRETENC	With "00000000"
					Replace RETENCION	With 0
					Replace FATURA		With cFatura
					Replace ENTRADA		With Dtos((cAliasSF3)->F3_ENTRADA)
					MsUnLock()
				Next
				DbSelectArea(cAliasSF3)
			Endif
		Endif
	Endif
	(cAliasSF3)->(DbSkip())
Enddo
(cAliasTmp)->(DbCommit())
#IFDEF TOP
	DbSelectArea(cAliasSF3)
	DbCloseArea()
#ENDIF
RestArea(aSF3)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCITICOMP  บAutor  ณMarcello            บFecha ณ 20/10/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o arquivo temporario com os dados referentes a compras บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CITI - Argentina                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CITICOMP(X, cSuc)
Local aArea		:= GetArea()
Local aEstru	:= {}
Local aSF3		:= {}
Local aImps		:= {}
Local dDtDigit  := Ctod("//")
Local nImp		:= 0
Local nIVAComis	:= 0
Local nI		:= 0
Local nTamFat	:= 0
Local nTamEsp	:= 0
Local nMoedaCor := 0
Local nTaxaMoeda:= 0
Local nDecimais := MsDecimais(1)
Local nMinimo	:= GetNewPar("MV_CITCMIN",500)
Local cTpComNC	:= GetNewPar("MV_CITCNC","03|08|53")
Local cImpIVA	:= GetNewPar("MV_CITIIVA","IVA|IV1|IV3|IV7|IV8")
Local cEspQry	:= ""  
Local cEspAux	:= ""
Local cAliasSF3	:= ""
Local cFilSF3	:= ""
Local cAliasTmp	:= "R01"
Local cAliasSF	:= ""
Local cAliasCF	:= ""
Local cArqTmp	:= ""
Local cTipoComp	:= ""
Local cSFDoc	:= ""
Local cFecha	:= ""
Local cCUIT		:= ""
Local cNombre   := ""
Local cCUITVend	:= ""
Local cVend		:= ""
Local cNotaAtu	:= ""
Local cQuery	:= ""
Local cFatura	:= ""
Local cEntrada	:= ""
Local cLiqProd  := ""
Local lOk		:= .T.
Local cHAWB		:=""
Local nProcFil := 0
Local cFilSel := "" 
	Local aOrdem := {}
Default cSuc := "" 

cSuc := Substr(cSuc,1,1)
If  cSuc== "1" //Significa que sera consolidado y que hubo seleccion de Sucursales
    //Cambiar logico para que NO continue procesando filiales    
       For nProcFil:=1 to len(aFilsCalc)
             If aFilsCalc[nProcFil,1] == .T.
                    cFilSel += IIF(EMPTY(cFilSel),"'","','")+aFilsCalc[nProcFil,2]
                    aFilsCalc[nProcFil,1]:=.F.                 
             Endif
       Next nProcFil
       cFilSel += "'" 
       cFilSel = "F3_FILIAL IN ( " + cFilSel + " ) "
Endif

nTamFat:= TamSX3("F3_NFISCAL")[1]
nTamFat:= TamSX3("F3_ESPECIE")[1]
aEstru :=	{	{"TIPOCOMP","C",02,00},;
				{"NRCOMP"  ,"C",24,00},;
				{"FCCOMP"  ,"C",08,00},;
				{"CUITINFO","C",11,00},;
				{"NOMBRE"  ,"C",25,00},;
				{"IMPUESTO","N",12,02},;
				{"CUITVEND","C",11,00},;
				{"VENDEDOR","C",25,00},;
				{"IVACOMIS","N",12,02},;
				{"FATURA"  ,"C",nTamFat,00},;
				{"ENTRADA" ,"C",8,00}}
	oTmpTable := FWTemporaryTable():New(cAliasTmp) 
	oTmpTable:SetFields( aEstru ) 
	aOrdem	:=	{"CUITINFO","ENTRADA","FATURA"} 
	oTmpTable:AddIndex("IN1", aOrdem) 
	oTmpTable:Create() 	
aSF3 := SF3->(GetArea())
cFilSF3 := xFilial("SF3")
cQuery := ""
nI := 0
#IFDEF TOP
	cAliasSF3 := GetNextAlias()
	cQuery := "select * from " + RetSqlName("SF3")
	If  cSuc == "1"
		cQuery += " where " + cFilSel + "" 
	Else
		cQuery += " where F3_FILIAL = '" + cFilSF3 + "'" 
	EndIf
	cQuery += " and F3_ENTRADA between '" + Dtos(dDmaInc) + "' and '" + Dtos(dDmaFin) + "'"     
	If substr(X,1,1) == "1"  // Se escolher SI (Incluir NCC/NDE)  
		cQuery += " and (F3_TIPOMOV = 'C' OR F3_ESPECIE IN('NCC','NDE'))"  
    Else
    	cQuery += " and (F3_TIPOMOV = 'C')"  	   
	Endif
	cQuery += " and F3_DTCANC = ''"
	cQuery += " and D_E_L_E_T_ =''"
	cQuery += " order by F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_CLIEFOR,F3_LOJA"	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasSF3, .F., .T.)
	dbSelectArea(cAliasSF3)
	aEstru := SF3->(DbStruct())
	For nI := 1 To Len(aEstru)
		If aEstru[nI][2] != "C" .And. FieldPos(aEstru[nI][1]) != 0
			TCSetField(cAliasSF3, aEstru[nI][1], aEstru[nI][2], aEstru[nI][3], aEstru[nI][4])
		EndIf
	Next nI
	(cAliasSF3)->(DbGoTop())
#ELSE
	cAliasSF3 := "SF3"
	DbSelectArea("SF3")
	DbSetOrder(1)
	DbSeek(xFilial("SF3") + Substr(Dtos(dDmaInc),1,6),.F.)
#ENDIF
lOk := .T.
cNotaAtu := ""  
cTmpFil := cFilAnt
DbSelectArea(cAliasSF3)
ProcRegua((cAliasSF3)->(RecCount()))
While (cAliasSF3)->(!Eof()) .And.  IIf(cSuc == "2",(cAliasSF3)->F3_FILIAL == cFilSF3, .T.)
	cFilAnt := (cAliasSF3)->F3_FILIAL
	If cNotaAtu <> (cAliasSF3)->(F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE)
		IncProc((cAliasSF3)->F3_NFISCAL)
		cNotaAtu := (cAliasSF3)->(F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE)
		#IFNDEF TOP
			lOk := ((cAliasSF3)->F3_TIPOMOV == "C" .And. (cAliasSF3)->F3_ENTRADA >= dDmaInc .And. (cAliasSF3)->F3_ENTRADA <= dDmaFin .And. Empty(F3_DTCANC))
		#ENDIF
		If lOk
			cAliasSF	:= If((cAliasSF3)->F3_TES < "500","SF1","SF2")
			(cAliasSF)->(DbSetOrder(1))
			(cAliasSF)->(DbSeek((cAliasSF3)->F3_FILIAL + (cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))//(cAliasSF)->(DbSeek(xFilial(cAliasSF) + (cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))
			cHAWB:=""
			If cAliasSF == "SF2"
				cLiqProd := SF2->F2_LIQPROD
			EndIf 
			If cAliasSF == "SF1" .And. (!Empty(SF1->F1_HAWB))
				cHAWB:= SF1->F1_HAWB
				cTipEx:=SF1->F1_TIPO_NF  
			EndIf	
			cAliasCF  := Iif(F3_TIPOMOV == "V","SA1","SA2")
			(cAliasSF)->(DbSetOrder(1))
			(cAliasSF)->(DbSeek((cAliasSF3)->F3_FILIAL + (cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))//(cAliasSF)->(DbSeek(xFilial(cAliasSF) + (cAliasSF3)->F3_NFISCAL +  (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))
				nMoedaCor  := (cAliasSF)->(&(SubStr(cAliasSF,2,2)+"_MOEDA"))
				nTaxaMoeda := (cAliasSF)->(&(SubStr(cAliasSF,2,2)+"_TXMOEDA"))
				dDtDigit   := (cAliasSF)->(&(SubStr(cAliasSF,2,2)+"_DTDIGIT"))
			aImps := CITI_IMP(cAliasSF,cImpIVA)
			nImp := 0
			For nI := 1 To Len(aImps)
				nImp += aImps[nI,3]
			Next
			nImp := Round(xMoeda(nImp,nMoedaCor,1,dDtDigit,nDecimais+1,nTaxaMoeda),nDecimais)
			If nImp > 0
				If nImp >= nMinimo
					cTipoComp	:= CITITpComp(cAliasSF,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_ESPECIE, cLiqProd)
					cSFDoc 		:= CITINrComp((cAliasSF3)->F3_NFISCAL,cTipoComp)
					cFecha		:= Dtos((cAliasSF3)->F3_EMISSAO)
					If cTipoComp $ cTpComNC
						cCUIT	:= SM0->M0_CGC
						cNombre	:= SM0->M0_NOMECOM
					Else  
						(cAliasCF)->(DbSeek(xfilial(cAliasCF) + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))
						If cAliasCF == "SA2"
							cCUIT	:= SA2->A2_CGC
							cNombre	:= SA2->A2_NOME
						Else
							cCUIT	:= SA1->A1_CGC           
							cNombre	:= SA1->A1_NOME
						Endif
					Endif
					cFatura	:= (cAliasSF3)->F3_NFISCAL
					cEntrada:= Dtos((cAliasSF3)->F3_ENTRADA)
				Else                                        
					cTipoComp	:= "00"
					cSFdoc		:= "00"
					cFecha		:= "00000000"
					(cAliasCF)->(DbSeek(xfilial(cAliasCF) + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA))
					If cAliasCF == "SA2"
						cCUIT	:= SA2->A2_CGC
						cNombre	:= SA2->A2_NOME
					Else
						cCUIT	:= SA1->A1_CGC
						cNombre	:= SA1->A1_NOME
					Endif
					cFatura	:= "0"
					cFatura	:= Padl(cFatura,nTamFat,"0")
					cEntrada:= "00000000"
				Endif
				cSFDoc		:= PadL(AllTrim(SubStr(cSFDoc,1,4)),4,"0") + PadL(Alltrim(SubStr(cSFDoc,5,8)),20,"0")
				cNombre		:= PadR(cNombre,25)
				cCUIT		:= PadL(cCUIT,11,"0")
				cVend		:= ""
				cFecha		:= Substr(cFecha,7,2) + Substr(cFecha,5,2) + Substr(cFecha,1,4)
				nIVAComis	:= 0
				cCUITVend	:= PadL(cCUITVend,11,"0")
				DbSelectArea(cAliasTmp)
				If nImp >= nMinimo
					RecLock(cAliasTmp,.T.)
				Else     
					If ("NCP"$(cAliasSF3)->F3_ESPECIE)
				   		nImp := - nImp
					EndIf
					If (cAliasTmp)->(DbSeek(cCuit+cEntrada))
						RecLock(cAliasTmp,.F.)
						nImp += (cAliasTmp)->IMPUESTO
					Else
						RecLock(cAliasTmp,.T.)
					Endif				
				Endif	

				Replace TIPOCOMP	With cTipoComp
				Replace NRCOMP		With cSFDoc
				Replace FCCOMP		With cFecha
				Replace CUITINFO	With cCUIT
				Replace NOMBRE     	With cNombre
				Replace IMPUESTO	With nImp
				Replace CUITVEND	With cCUITVend
				Replace VENDEDOR	With cVend
				Replace IVACOMIS	With nIVAComis
				Replace FATURA		With cFatura
				Replace ENTRADA		With cEntrada
				MsUnLock()
				DbSelectArea(cAliasSF3)
			Endif
		Endif
	Endif
	(cAliasSF3)->(DbSkip())
Enddo
(cAliasTmp)->(DbCommit())
#IFDEF TOP
	DbSelectArea(cAliasSF3)
	DbCloseArea()
#ENDIF          

cFilAnt := cTmpFil

RestArea(aSF3)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCITI_IMP  บAutor  ณMarcello            บFecha ณ 25/10/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecupera a  base e o valor dos impostos de uma fatura       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบArgumentosณcImps - Codigos dos impostos. Exemplo: "IVA|IV7"            บฑฑ
ฑฑบEntrada   ณ        Os impostos devem estar separados por "|"           บฑฑ
ฑฑบ          ณcAlias - "alias" do arquivo cabecalho da fatura             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบArgumentosณaImp - Base/Valor dos impostos                              บฑฑ
ฑฑบRetorno   ณaImp[1] - Codigo do imposto                                 บฑฑ
ฑฑบ          ณaImp[2] - base                                              บฑฑ
ฑฑบ          ณaImp[3] - valor                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CITI - Argentina                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CITI_IMP(cAlias,cImps)
Local aArea		:= {}
Local aSFB		:= {}
Local aRet		:= {}
Local aCpos		:= {}
Local nPos		:= 0
Local nPosCpo	:= 0
Local cFilSFB	:= xFilial("SFB")
Local cImp		:= ""
Local cCpo		:= ""

If !Empty(cImps)
	aArea := GetArea()
	aSFB  := SFB->(GetArea())
	SFB->(DbSetOrder(1))
	While !Empty(cImps)
		nPos := At("|",cImps)
		If nPos > 0
			cImp := Substr(cImps,1,nPos-1)
			cImps := Substr(cImps,nPos+1)
		Else
			cImp := cImps
			cImps := ""
		Endif
		If SFB->(DbSeek(cFilSFB + cImp))
			Aadd(aRet,{cImp,0,0})
			nPos := Len(aRet)
			cCpo := Substr(cAlias,2,2) + "_BASIMP" + SFB->FB_CPOLVRO
			If Ascan(aCpos,cCpo) == 0
				Aadd(aCpos,cCpo)
				nPosCpo := (cAlias)->(FieldPos(cCpo))
				If nPosCpo > 0
					aRet[nPos,2] += (cAlias)->(FieldGet(nPosCpo))
				Endif
				cCpo := Substr(cAlias,2,2) + "_VALIMP" + SFB->FB_CPOLVRO
				nPosCpo := (cAlias)->(FieldPos(cCpo))
				If nPosCpo > 0
					aRet[nPos,3] += (cAlias)->(FieldGet(nPosCpo))
				Endif
			Endif
		Endif
	Enddo
	RestArea(aSFB)
	RestArea(aArea)
Endif
Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCITITpComp  บAutor  ณCamila Januแrio     บ Data ณ  16/05/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os tipos de comprovante de acordo com a            บฑฑ
ฑฑบ          ณ s้rie/esp้cie                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localiza็๕es - Uso Exclusivo CITICompras                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function CITITpComp(cAlias,cSerie,cEspecie, cLiqProd)                                                

Local cCodTipo := "00" 
Local cCodInt  := "00" 
Local cEntSai	:= ""

cEspecie := GetSesNew(AllTrim(cEspecie),Iif(cAlias$"SD2|SF2","1","2"))

If cAlias == "SF1" .And.  cEspecie$"NCC|NCI|NDE|NDP|NF"
     cEntSai:= "Entrada"
Else
	cEntSai:= "Saida"
EndIf     

If !Empty(cSerie) .And. !Empty(cEspecie) 
    
    IF cEntSai == "Saida"
    	IF cEspecie$"NF" //Verifica a Especie da Nota
    	     IF Empty(cLiqProd)  // Valor do Campo F2_LIQPROD
    	     	//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "01"
    				cCodInt  := "01"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "06"
    				cCodInt  := "02"
    			ElseIf 	Substr(cSerie,1,1) == "E"
    	     		cCodTipo := "19"
    				cCodInt  := "03"
    	     	EndIf
    	     Else
    	     	//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "60"
    				cCodInt  := "04"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "61"
    				cCodInt  := "05"
    			ElseIf 	Substr(cSerie,1,1) == "E"
    	     		cCodTipo := "62"
    				cCodInt  := "06"
    	     	EndIf
    	     EndIf 		
    	ElseIf  cEspecie$"NDC" //Verifica a Especie da Nota  NDC  	
    			//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "02"
    				cCodInt  := "07"
    			ElseIf Substr(cSerie,1,1) == "B"
    				cCodTipo := "07"
    				cCodInt  := "08"
    			Elseif Substr(cSerie,1,1) == "E" 
    				cCodTipo := "20"
    				cCodInt  := "09" 
    			EndIf
    	ElseIf  cEspecie$"NCE" //Verifica a Especie da Nota  NCE  						
    	  		//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "02"
    				cCodInt  := "10"
    			ElseIf Substr(cSerie,1,1) == "B"
    				cCodTipo := "07"
    				cCodInt  := "11"
    			ElseIf Substr(cSerie,1,1) == "C" 
    				cCodTipo := "  "
    				cCodInt  := "12"   
    			ElseIf Substr(cSerie,1,1) == "E" 
    				cCodTipo := "  "
    				cCodInt  := "13" 
    			ElseIf Substr(cSerie,1,1) == "M" 
    				cCodTipo := "57"
    				cCodInt  := "14" 		
    			EndIf
    	ElseIf  cEspecie$"NDI" //Verifica a Especie da Nota  NDI    
        		//Preenche os Codidoas de acordo com a serie
        		IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "03"
    				cCodInt  := "35"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "42"
    				cCodInt  := "36"
    			ElseIf 	Substr(cSerie,1,1) == "E"
    	     		cCodTipo := "42"
    				cCodInt  := "37"
    			EndIf	
        ElseIf  cEspecie$"NCP" //Verifica a Especie da Nota  NCP
        	 //Preenche os Codidoas de acordo com a serie
        		IF  Substr(cSerie,1,1) == "A"
    				cCodTipo := "42"
    				cCodInt  := "38"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "08"
    				cCodInt  := "39"
    			ElseIf 	Substr(cSerie,1,1) == "C
    	     		cCodTipo := "42"
    				cCodInt  := "40"
    			ElseIf 	Substr(cSerie,1,1) == "E"	
    				cCodTipo := "42"
    				cCodInt  := "41"
    			EndIf		
    	EndIf		
    Else //Compras
		IF cEspecie$"NF" //Verifica a Especie da Nota
    	     IF Empty(cLiqProd)   // Valor do Campo F1_LIQPROD
    	     	//Preenche os Codigos de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "01"
    				cCodInt  := "22"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "  "
    				cCodInt  := "23"
    			ElseIf 	Substr(cSerie,1,1) == "C"
    	     		cCodTipo := "39"
    				cCodInt  := "24"
    			ElseIf 	Substr(cSerie,1,1) == "E"
    	     		cCodTipo := "39"
    				cCodInt  := "25"
    			ElseIf Substr(cSerie,1,1) == "M"
    	     		cCodTipo := "57"
    				cCodInt  := "26"	
    	     	EndIf
    	     Else
    	     	//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "60"
    				cCodInt  := "28"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "  "
    				cCodInt  := "29"
    	     	EndIf
    	     EndIf 		
    	ElseIf  cEspecie$"NDP" //Verifica a Especie da Nota  NDP 
    		//Preenche os Codidoas de acordo com a serie 
        	    IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "02"
    				cCodInt  := "30"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "39"
    				cCodInt  := "31"
    			ElseIf 	Substr(cSerie,1,1) == "C"
    	     		cCodTipo := "39"
    				cCodInt  := "32"
    			ElseIf 	Substr(cSerie,1,1) == "E"
    	     		cCodTipo := "39"
    				cCodInt  := "33"
    			ElseIf Substr(cSerie,1,1) == "M"
    	     		cCodTipo := "57"
    				cCodInt  := "34"	
    	     	EndIf 	
        	ElseIf  cEspecie$"NCC" //Verifica a Especie da Nota  NCC		
    			//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "03"
    				cCodInt  := "15"
    			ElseIf Substr(cSerie,1,1) == "B"
    				cCodTipo := "08"
    				cCodInt  := "15"
    			ElseIf Substr(cSerie,1,1) == "E" 
    				cCodTipo := "21"
    				cCodInt  := "17" 
    			EndIf
       		ElseIf  cEspecie$"NDE" //Verifica a Especie da Nota  NDE	
				//Preenche os Codidoas de acordo com a serie
    	     	IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "03"
    				cCodInt  := "18"
    			ElseIf Substr(cSerie,1,1) == "B"
    				cCodTipo := "08"
    				cCodInt  := "19"
    			ElseIf Substr(cSerie,1,1) == "C" 
    				cCodTipo := "  "
    				cCodInt  := "20"   
    			ElseIf Substr(cSerie,1,1) == "E" 
    				cCodTipo := "21"
    				cCodInt  := "21" 		
    			EndIf
    	ElseIf  cEspecie$"NCI" //Verifica a Especie da Nota  NCI
    			//Preenche os Codidoas de acordo com a serie
        		IF   Substr(cSerie,1,1) == "A"
    				cCodTipo := "02"
    				cCodInt  := "42"
    			ElseIf Substr(cSerie,1,1) == "B"	
	    			cCodTipo := "39"
    				cCodInt  := "43"
    			ElseIf 	Substr(cSerie,1,1) == "E"
    	     		cCodTipo := "39"
    				cCodInt  := "44"
    			EndIf	
        ElseIf  cEspecie$"NCP" //Verifica a Especie da Nota  NCP
        	 //Preenche os Codidoas de acordo com a serie
   				cCodTipo := "42"
   				//cCodInt  := "38"
    	EndIf		    					
    EndIf     
EndIf	
Return(cCodTipo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ CITINrComp   ณAutor ณCamila Januแrio       ณDataณ16/05/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Verifica se o codigo do comprovante possui letras, retornanณฑฑ 
ฑฑณ          ณ zeros, dependendo do tipo de comprovante.                  ณฑฑ
ฑฑณ          ณ                                                 			  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localiza็๕es - Uso Exclusivo CITICompras                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function CITINrComp(cDoc,cTpComp)
Return( IIf(Val(cDoc)==0 .And. cTpComp$"39,87",StrZero(0,12),cDoc))
		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ CITIDEL      ณAutor ณLuis Enriquez         ณDataณ09/01/2017ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Elimina e inicializa objeto de tablas temporales.          ณฑฑ 
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                 			  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localiza็๕es - Uso Exclusivo CITICompras-CITIVentas        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function CITIDEL()
	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf 
Return 
