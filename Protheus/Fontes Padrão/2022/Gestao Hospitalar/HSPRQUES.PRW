#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "HSPRQUES.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPRQUES ³ Autor ³ Saude                 ³ Data ³ 30/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Relatorio de Impressao do Questionario de Perguntas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPRQUES(cAlias, cCpoChave, cValChv, cCdQues, cRegAte, cAssinatura, cCrmMed, cCodloc, lCertDig, cCodGFU, lCertLote, aGuiasLote)
Local cCdusu    := ""
Local cRegger   := ""
Local cNameFile := ""	 

Private	cPerg 		:= "HSPRQU"
Private oReport
Private cTabela 	:= cAlias
Private cCpoChv		:= cCpoChave
Private cChave		:= cValChv
Private aResp		:= {}
Private aQuest		:= {}
Private aAux		:= {}
Private cTitRel		:= ""
Private cFunCab		:= ""
Private cTpQues		:= ""
Private lMntVazio	:= .F.
Private cImgAss		:= Alltrim(cAssinatura)
Private cCodCrm		:= cCrmMed
Private cAtendi 	:= cRegAte
Private cTipnasc    := ""
Private lImpAnam   := SuperGetmv("MV_IMPANAM",,.T. )


Default cAssinatura	:= ""
Default cRegAte		:= ""
Default cCrmMed		:= ""
Default cCodloc     := ""
Default lCertDig    := .F.   
Default cCodGFU     := ""
Default lCertLote   := .F.

If  FunName() # "HSPAHP10" .AND. Empty(cCdQues) .AND. !Empty(cAtendi)
	If lImpAnam
		If !(aCodUsr := HS_VldDAnm(,.F.))[1]
			Return(Nil)
		EndIf
	Else
		PswOrder(2)
		PswSeek(cUserName,.T.)
		cCdusu:=cUserName
		DbSelectArea("GM1")
		DbSetOrder(1) // GM1_FILIAL + GM1_CODLOC + GM1_CODUSU
		DbSeek(xFilial("GM1") + cCodloc + cCdusu)
		If GM1->GM1_AUTORI == "0"
			HS_MSGINF(STR0001,STR0002,STR0004)//"Usuário não autorizado para Imprimir Anamnese","Atenção","Validação Rel. Questionário"
			Return(Nil)
		EndIf
	Endif
Endif

If lCertDig
	cNameFile := "GCY"+cRegAte+"GFU"+cCodGFU       
	MV_PAR01  := GFU->GFU_DATCON
	MV_PAR02  := GFU->GFU_DATCON 
Else
	Pergunte(cPerg,.T.)
EndIf

DbSelectArea("GCY")
DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
DbSeek(xFilial("GCY") + cRegAte)
cRegger:=GCY->GCY_REGGER

oReport := ReportDef(cAlias, cCpoChave, cValChv, cCdQues, cRegAte, cAssinatura, cCrmMed, cCodloc,cRegger, lCertDig,cNameFile, cCodGFU)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se certificado digital, chama DLL para certificar o PDF gerado              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If !lCertDig   
	oReport:PrintDialog()
Else  
	FErase(GetTempPath()+"totvsprinter\"+cNameFile+".pdf") 
	
	If GetNewPar("MV_HSCDPDF","0") <> "1"
		oReport:SetViewPDF(.F.)
	EndIf
		
	oReport:Print()   
	If !lCertLote 
		HSCertDig("1",cNameFile,cCodCrm)
	Else
		Aadd(aGuiasLote,{GetTempPath()+"totvsprinter\"+cNameFile+".pdf",cNameFile+".pdf",cCodCrm})
	EndIf	
EndIf

Return(Nil)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³REPORTDEF ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri??o ³ Impressao do relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef(cAlias, cCpoChave, cValChv, cCdQues, cRegAte, cAssinatura, cCrmMed, cCodloc, cRegger, lCertDig, cNameFile, cCodGFU)

//Local oReport		// Objeto do relatório
Local oSection1		// Objeto da seção 1
Local oSection0		// Objeto da seção 1
Local oCell			// Obejot do cabeçalho
Default lCertDig    := .F.
Default cNameFile   := ""
Default cCodGFU     := ""
oReport := TReport():New("HSPRQUES",HS_MontCabe(cTitRel, MV_PAR01, MV_PAR02), , {|oReport| RQUESIMP(oReport,cAlias, cCpoChave, cValChv, cCdQues, cRegAte, cAssinatura, cCrmMed, cCodloc,cRegger,cCodGFU)}, cTitRel) //" imprimir a quantidade partos e nascidos por convênio por período."

oReport:SetPortrait()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se certificado digital, seta impressora para geracao do PDF automaticamente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCertDig
	oReport:cFile       := cNameFile 
	oReport:nRemoteType := NO_REMOTE
	oReport:nDevice     := 6 //-- Gera arquivo PDF
	oReport:SetEnvironment(1)//1-Server e 2-Cliente 
EndIf

oSection1 := TRSection():New(oReport, cTitRel, {cTabela})
oSection1:SetHeaderBreak(.f.)    //Indica se cabecalho da secao sera impresso em cada quebra
oSection1:SetPageBreak(.T.)      //Indica quebra de pagina no final da secao
oSection1:SetHeaderPage(.F.)     //Indica que cabecalho da secao sera impresso no topo da pagina
oSection1:SetHeaderSection(.F.)  //Indica se cabecalho da secao sera impresso (padrao)


oCell := TRCell():New(oSection1, " TESTE1 ",," Col 1",,17) 		//"CONVENIOS"
oReport:SkipLine(1)
oCell := TRCell():New(oSection1, " TESTE1 ",," Col 2",,40) 		//"CONVENIOS"*/



Return(oReport)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³ R82Imp   ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri??o ³ Montagem da query e quebras do relatorio                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function RQUESIMP(oReport,cAlias, cCpoChave, cValChv, cCdQues, cRegAte, cAssinatura, cCrmMed, cCodloc,cRegger,cCodGFU)

Local oSection1 := oReport:Section(1)
Local cEnvServ := GetEnvServer()
Local cPathFile 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))
Local nLin		:= 7
Local cTipDado	:= ""
Local nPosVet	:= 0
Local cSepar	:= ""
Local oFont1 	:= TFont():New("Arial",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont2 	:= TFont():New("Times New Roman",9,10 ,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont3 	:= TFont():New("Courier New",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFontAux	:= Nil
Local lBold		:= .F.
Local lItalic	:= .F.
Local cResMem	:= ""
Local nLinObs	:= 0
Local aResMem	:= {}
Local nObs		:= 0
Local cquest:=""
local ccanam:=""
Local cSqlGfu:= ""
Default cCodGFU := ""

If !Empty(cCodGFU)
	cSqlGfu := " SELECT  *     FROM " + RetSqlName("GFU") + " WHERE GFU_REGGER = '" + cRegger + "'"
	cSqlGfu += " AND GFU_CDANAM = '" + cCodGFU + "' "
	cSqlGfu += " AND D_E_L_E_T_ <> '*' AND GFU_FILIAL = '" + xFilial("GFU") + "'"
	cSqlGfu += " ORDER BY  GFU_CDANAM "
	cSqlGfu := ChangeQuery(cSqlGfu)
Else
	cSqlGfu := " SELECT  *     FROM " + RetSqlName("GFU") + " WHERE GFU_REGGER = '" + cRegger + "'"
	cSqlGfu += " AND GFU_DATCON >= '" + DTOS(MV_PAR01) + "' AND GFU_DATCON <= '" + DTOS(MV_PAR02) + "'"
	cSqlGfu += " AND D_E_L_E_T_ <> '*' AND GFU_FILIAL = '" + xFilial("GFU") + "'"
	cSqlGfu += " ORDER BY  GFU_CDANAM "
	cSqlGfu := ChangeQuery(cSqlGfu)
EndIf

TCQuery cSqlGfu New Alias "QRYGFU"


If EOF()
	HS_MSGINF(STR0003,STR0002, STR0004)//"Paciente não possui Anamnese","Atenção" ,"Validação Rel. Questionário"
	QRYGFU->(DbCloseArea())
	Return(Nil)
Endif

While QRYGFU->(!Eof())
			nPosVet:=0
	cCdQues := QRYGFU->GFU_CDQUES
	cValChv := QRYGFU->GFU_CDANAM
	cTipnasc :=QRYGFU->GFU_RESERV
	cAtendi	:=QRYGFU->GFU_REGATE
			aResp := HS_BusResp(cAlias, {{cAlias + "->" + cCpoChave, cValChv}}, cAlias)

			DbSelectArea("GFS")
			DbSetOrder(1)
			DbSeek(xFilial("GFS") + cCdQues)
			cTitRel := IIf(Empty(GFS->GFS_TITREL), STR0005 + cCdQues, GFS->GFS_TITREL)//"Relatório Questionario: "
			cFunCab := IIf(Empty(GFS->GFS_FUNCAB), "", GFS->GFS_FUNCAB)
			cTpQues := IIf(Empty(GFS->GFS_TPQUES), "", GFS->GFS_TPQUES)

	DbSelectArea("GCY")
	DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
	DbSeek(xFilial("GCY") + cAtendi)
	
	cCodloc :=GCY->GCY_CODLOC
			If Len(aResp) == 0
				aQuest := FS_MontaVazio(cCdQues,@aResp,cAlias)
				lMntVazio	:= .T.
				If Len(aResp) == 0
			QRYGFU->(DbCloseArea())
					Return(Nil)
				EndIf
			Else
				aQuest 	:= FS_MontaVazio(cCdQues,aAux,cAlias)
			EndIf


			If SubString (cPathFile,Len(cPathFile),Len(cPathFile)) <> "\"
				cPathFile += "\"
			EndIf

			If Empty(cFunCab)
				If cTpQues == "4" .OR. cTpQues == "5"
					FS_CABTPQ5(@oReport, cTabela,cChave,lMntVazio)
				ElseIf cTpQues == "0"
			FS_CABTPQ0(@oReport, cTabela,cChave,lMntVazio,cAtendi,cCodCrm,cTipnasc,cCodloc,cRegger)
				EndIf
			Else
				If FindFunction(cFunCab)
					&(cFunCab)
				EndIf
			EndIf

			oReport:SkipLine(1)

	For  nLin := 1 To Len(aResp)
				cTipDado	:= SubStr(aResp[nLin,1],3,1)
				cCodPer		:= PADR(SubStr(aResp[nLin,1],8,6), TamSx3("GCH_CODPER")[1])  
				nPosVet 	:= IIF(aScan(aQuest, {|aVet| aVet[1] == cCodPer})>0,aScan(aQuest, {|aVet| aVet[1] == cCodPer}),nPosVet )
				If nPosVet==0
					loop
				Endif
				cSepar 		:= IIf(aQuest[nPosVet,10 ] == "1", " | " ,"")
				lBold		:= (aQuest[nPosVet,15] == "2" .OR. aQuest[nPosVet,15] == "3")
				lItalic		:= (aQuest[nPosVet,15] == "1" .OR. aQuest[nPosVet,15] == "3")
				oFont1	:= Nil
				oFont2	:= Nil
				oFont3	:= Nil
				oFont1 	:= TFont():New("Arial",9,IIf(aQuest[nPosVet,16]==0,10,aQuest[nPosVet,16]) ,.T.,lBold,5,lItalic,5,.T.,.F.)
				oFont2 	:= TFont():New("Times New Roman",9,IIf(aQuest[nPosVet,16]==0,10,aQuest[nPosVet,16]) ,.T.,lBold,5,lItalic,5,.T.,.F.)
				oFont3 	:= TFont():New("Courier New",9,IIf(aQuest[nPosVet,16]==0,10,aQuest[nPosVet,16]),.T.,lBold,5,lItalic,5,.T.,.F.)
				oFontAux := Nil
				oFontAux := IIf(aQuest[nPosVet,14] == "1",oFont2,IIf(aQuest[nPosVet,14] == "2",oFont3,oFont1))
				If !Empty(aResp[nLin,2])
					oReport:Say(oReport:Row(),IIf(Empty(aQuest[nPosVet,11]) .OR. aQuest[nPosVet,11] == 0 , 10,aQuest[nPosVet,11]), IIf(!Empty(aQuest[nPosVet,5 ]),aQuest[nPosVet,5 ],aResp[nLin,3]),oFontAux)
					If cTipDado == "D"
						oReport:Say(oReport:Row(),IIf(Empty(aQuest[nPosVet,12]) .OR. aQuest[nPosVet,12] == 0 , 600,aQuest[nPosVet,12]), cSepar + DTOC(aResp[nLin,2]),oFontAux)
					ElseIf cTipDado == "M"
						cResMem := aResp[nLin,2]
						nLinObs	:= MLCOUNT(cResMem, , , )
						aResMem := {}
						For nObs := 1 To nLinObs
							aADD(aResMem,{MEMOLINE(cResMem, , nObs, )})
						Next nObs
						oReport:SkipLine(1)
						For nObs := 1 To Len(aResMem)
							oReport:SkipLine(1)
							oReport:Say(iif(oReport:Row()==0,oReport:IncRow(245),oReport:Row()), IIf(Empty(aQuest[nPosVet,12]) .OR. aQuest[nPosVet,12] == 0 , 600,aQuest[nPosVet,12]), aResMem[nObs,1], oFontAux)
						Next nObs
					ElseIf cTipDado == "N"
						If ValType(aResp[nLin,2]) == "N"
							oReport:Say(oReport:Row(),IIf(Empty(aQuest[nPosVet,12]) .OR. aQuest[nPosVet,12] == 0 , 600,aQuest[nPosVet,12]), cSepar + Alltrim(Str(aResp[nLin,2])),oFontAux)

						Else
							oReport:Say(oReport:Row(),IIf(Empty(aQuest[nPosVet,12]) .OR. aQuest[nPosVet,12] == 0 , 600,aQuest[nPosVet,12]), cSepar + aResp[nLin,2],oFontAux)

						EndIf
					Else
					     If !Empty(HS_IniPadr("GCH", 1, cCodPer, "GCH_CBOX"))
      						aResp[nLin][2] := HS_MA7RDes(cCodPer, AllTrim(aResp[nLin][2]))
					     EndIf
						oReport:Say(oReport:Row(),IIf(Empty(aQuest[nPosVet,12]) .OR. aQuest[nPosVet,12] == 0 , 600,aQuest[nPosVet,12]), cSepar + aResp[nLin,2],oFontAux)

					EndIf
		Else //Não Imprime as perguntas que estão sem Respostas

					LOOP
				EndIf
				oReport:Say(oReport:Row(),IIf(Empty(aQuest[nPosVet,13]) .OR. aQuest[nPosVet,13] == 0 , 600,aQuest[nPosVet,13]), cSepar + aQuest[nPosVet,8],oFontAux)

				oReport:SkipLine(1)
				oReport:SkipLine(1)
				If aQuest[nPosVet,9] == "1"
					oReport:Line(oReport:Row(),0001,oReport:Row(),3230) // IMPRIME LINHA Horizontal
					oReport:SkipLine(1)
					oReport:SkipLine(1)
				EndIf


			NEXT nLin 



			If !Empty(cImgAss)
				If File(cPathFile + cImgAss + ".bmp")
					FErase(cPathFile + cImgAss + ".bmp")
				EndIf
				RepExtract(cImgAss,cPathFile + cImgAss + ".bmp",.T.) //Extrai a imagem do repositorio de imagens para a impressao no relatorio
				oReport:SayBitmap( 2600,900,cPathFile + cImgAss + ".bmp", 450, 300 )
				oReport:Line(3000,800,3000,1600) // IMPRIME LINHA Horizontal
				oReport:Say(3040,920, cCodCrm + " - " + Posicione("SRA", 11, xFilial("SRA") + cCodCrm, "RA_NOME"),oFontAux)

			EndIf

			oReport:SkipLine(1)
			If oReport:PageBreak()
				oReport:PrintHeader()
    oReport:Section(1):Finish()   
    oReport:Section(1):Init() 
			EndIf

	
    oReport:Section(1):Finish()   
     oReport:Section(1):SetPageBreak(.T.)
    oReport:Section(1):Init() 

	QRYGFU->(DbSkip())
	End

If QRYGFU->(EOF())
	QRYGFU->(DbCloseArea())
Endif

Return(Nil) 


Static Function FS_MontaVazio(cCdQues,aDados,cAlias)
	Local aArea := GetArea()
	Local cSql 	:= ""
	Local aRet	:= {}

	cSql := "SELECT GFT_GRPPER, GFT_NMPAST FROM " + RetSqlName("GFT") + " "
	cSql += "WHERE GFT_FILIAL = '" + xFilial("GFT") + "' AND GFT_IDATIV = '1' AND GFT_CDQUES = '" + cCDQues + "' AND D_E_L_E_T_ <> '*'"

	TCQUERY ChangeQuery(cSql) NEW ALIAS "TMPQUES"

	DbSelectArea("TMPQUES")

	While !TMPQUES->(Eof())
		DbSelectArea("GCG")
		DbSetOrder(3) // GCG_FILIAL + GCG_GRPPER + GCG_ORDPER
		DbSeek(xFilial("GCG") + TMPQUES->GFT_GRPPER)

		While !GCG->(Eof()) .and. xFilial("GCG") == GCG->GCG_FILIAL .And. TMPQUES->GFT_GRPPER == GCG->GCG_GRPPER
			DbSelectArea("GCH")
			GCH->(DbSetOrder(1))
			GCH->(DbSeek(xFilial("GCH") + GCG->GCG_CODPER))
			AADD(aDados,{"__" + GCH->GCH_TIPPER + cAlias + "_" + GCH->GCH_CODPER,IIf(GCH->GCH_SRELAT == "1" .AND. !Empty(GCH->GCH_RELRES),Alltrim(GCH->GCH_RELRES),IIf(GCH->GCH_TIPPER == "N",Padr("",10,"_"),Padr("",GCH->GCH_TAMRES,"_"))),GCH->GCH_DESPER,GCH->GCH_DESEXT})
			AADD(aRet,{GCH->GCH_CODPER,GCH->GCH_TIPPER,GCH->GCH_TAMRES,GCH->GCH_DESPER,GCH->GCH_DESEXT, TMPQUES->GFT_GRPPER,TMPQUES->GFT_NMPAST,GCH->GCH_TXTREF,GCH->GCH_IMPLIN,GCH->GCH_IMPSEP,GCH->GCH_NPOSC1,GCH->GCH_NPOSC2,GCH->GCH_NPOSC3,GCH->GCH_FONT,GCH->GCH_ESTFON,GCH->GCH_TAMFON})
			GCG->(DbSkip())
		EndDo
		TMPQUES->(DbSkip())
	EndDo

	TMPQUES->(DbCloseArea())

RestArea(aArea)
Return(aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CABTPQ5  ºAutor  ³Microsiga           º Data ³  01/18/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cabecalho Relatorio                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function FS_CABTPQ5(oReport, cAlias,cChave,lMntVazio)
	Local aArea := GetArea()
	Local cCodLoc := ""
	Local cNomLoc := ""
	Local cLocSol := ""
	Local cNomSol := ""
	Local cSolici := ""
	Local cCodReq := ""
	Local cOriPac := ""
	Local dDtNasc
	Local oFont2 := TFont():New("Arial",9,12 ,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont1 := TFont():New("Arial",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)

	If Type("__cNumSolic") <> "U" .AND. !Empty(__cNumSolic) // Variavel do Fonte HSPAHP10
		cSolici := __cNumSolic
	ElseIf cChave <> "000000"
		cSolici := cChave
	EndIf

	DbSelectArea("GBY")
	DbSetOrder(1)
	If DbSeek(xFilial("GBY") + cSolici)
		cAtendi := GBY->GBY_REGATE
		cCodLoc	:= GBY->GBY_CODLOC
		cCodReq	:= GBY->GBY_CODPED
		cLocSol := GBY->GBY_LOCSOL
		cNomSol := HS_IniPadr("GCS", 1, cLocSol, "GCS_NOMLOC",,.F.)
		cNomLoc :=  HS_IniPadr("GCS", 1, cCodLoc, "GCS_NOMLOC",,.F.)
	EndIf


	DbSelectArea("GCY")
	DbSetOrder(1)
	DbSeek(xFilial("GCY") + cAtendi)
	cOriPac := HS_IniPadr("GD0", 1, GCY->GCY_ORIPAC, "GD0_DORIPA",,.F.)
	dDtNasc := HS_IniPadr("GBH", 1, GCY->GCY_REGGER, "GBH_DTNASC",,.F.)

	oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:Say(oReport:Row(),900, "",oFont1)
	oReport:SkipLine(1)
	oReport:SkipLine(1)
	If Type("__cNmMpaInd") <> "U" // Variavel do Fonte HSPAHP10
		oReport:Say(oReport:Row(),1100, Alltrim(cNomLoc) + IIf(!Empty(__cNmMpaInd),STR0010  + __cNmMpaInd,"") ,oFont2) //" - Mapa: "
	Else
		oReport:Say(oReport:Row(),1100, Alltrim(cNomLoc)  ,oFont2)
	EndIf

	oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:SkipLine(1)

	If Alltrim(GBY->GBY_RESERV) $ "0/1/2/3/4/5"
		DbSelectArea("GB2")
		DbSetOrder(1)
		If DbSeek(xFilial("GB2") + cAtendi + GBY->GBY_RESERV)
			oReport:Say(oReport:Row(),500, STR0011 + Alltrim(GB2->GB2_NOME),oFont1) //"Paciente: "
			dDtNasc := GB2->GB2_DTNASC
		Else
			oReport:Say(oReport:Row(),500, STR0011  + Alltrim(GCY->GCY_NOME),oFont1)//"Paciente: "
		EndIf
	Else
		oReport:Say(oReport:Row(),500, STR0011  + Alltrim(GCY->GCY_NOME),oFont1) //"Paciente: "
	EndIf


	oReport:Say(oReport:Row(),1300,STR0012  + FS_Idade(dDtNasc, dDataBase),oFont1)//"Idade: "
	oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:Say(oReport:Row(),30,STR0013  + cCodReq,oFont1)	//"Requisição: "
	oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:Say(oReport:Row(),30,STR0014  + Alltrim(cNomSol),oFont1)		//"Solicitante: "
	oReport:Say(oReport:Row(),1500,STR0015  + Alltrim(cOriPac),oFont1)		//"Procedencia: "
oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:Line(oReport:Row(),0001,oReport:Row(),3230)


RestArea(aArea)
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Idade      ³ Autor ³                  ³ Data   /  /     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula a idade do Paciente                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_Idade(dDataI, dDataF)
	Local aIdade := HS_DifData(dDataI, dDataF)

Return(StrZero(aIdade[1], 2) + "a" + StrZero(aIdade[2], 2) + "m" + StrZero(aIdade[3], 2) + "d") //" ano(s) "###" mes(es) "###" dia(s) "
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CABTPQ0  ºAutor  ³Microsiga           º Data ³  12/28/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho Anamnese Doc/Relat no Atendimento                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_CABTPQ0(oReport, cAlias,cChave,lMntVazio,cAtendi,cCodCrm,cTipnasc,cCodloc,cRegger)
	Local aArea := GetArea()
	Local cNomLoc := ""
	Local cNome := ""
	Local dDtNasc
	Local oFont2 := TFont():New("Arial",9,12 ,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont1 := TFont():New("Arial",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)
	Local cCrmI:= ""
	Local cSqlGMT := ""
	Local cSqlGB2 := ""
	Local aLinGbh := {}
	Local aLinGcy := {}
	Local aLinGb2 := {}
	Local nLin:=0


	Private aVetCpos := {}


	cSqlGMT += " SELECT DISTINCT GMT_ORDEM, GMT_TABELA, GMT_CAMPO "
	cSqlGMT += "  FROM " + RetSqlName ("GMT") + " GMT"
	cSqlGMT += "  WHERE GMT_FILIAL = '" + xFilial("GMT") + "' AND GMT.D_E_L_E_T_ <> '*' "
cSqlGMT += "  AND (GMT.GMT_CODLOC = '" + cCodloc + "' OR GMT.GMT_CODLOC = '  ') "
	cSqlGMT += "  AND GMT.GMT_MOSTRA ='1' "
	cSqlGMT += "  ORDER BY 2,1 "

	TCQUERY ChangeQuery(cSqlGMT) NEW ALIAS "TMPGMT"


	DbSelectArea("TMPGMT")

	While !Eof()
		AADD(aVetCpos, {TMPGMT->GMT_ORDEM,TMPGMT->GMT_TABELA,TMPGMT->GMT_CAMPO})
		DbSkip()
	EndDo


	TMPGMT->(DbCloseArea())

	If Len (aVetCpos) == 0
		Return(Nil)
	EndIf

	If aScan(aVetCpos, {|aVet| aVet[2] == "GBH"})  > 0
		DbSelectArea("GBH")
		DbSetOrder(1)
	If DbSeek(xFilial("GBH") +  cRegger)
			RegToMemory("GBH",.F.)
		EndIf
	EndIf

	If aScan(aVetCpos, {|aVet| aVet[2] == "GCY"})  > 0
		DbSelectArea("GCY")
		DbSetOrder(1)
		If DbSeek(xFilial("GCY") +  cAtendi)
			RegToMemory("GCY",.F.)
		EndIf
	EndIf

	If aScan(aVetCpos, {|aVet| aVet[2] == "GB2"})  > 0


		If Alltrim(cTipnasc) $ "0/1/2/3/4/5"
			DbSelectArea("GB2")
			DbSetOrder(1)
			If DbSeek(xFilial("GB2") +  cAtendi + cTipnasc)
				RegToMemory("GB2",.F.)
			EndIf
		EndIf
	Endif



	If aScan(aVetCpos, {|aVet| aVet[2] == "GBH"})  > 0
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:Say(oReport:Row(),900, "",oFont1)
		oReport:SkipLine(1)
		oReport:SkipLine(1)

		oReport:Say(oReport:Row(),900, STR0016 ,oFont2)//"Dados do Paciente"
		oReport:SkipLine(1)
		oReport:SkipLine(1)

		aLinGbh := FS_IMPTABELA("GBH")
		For nLin := 1 to len(aLinGbh)
			oReport:Say(oReport:Row(),10, aLinGbh[nLin],oFont1)
			oReport:SkipLine(1)
			oReport:SkipLine(1)
		Next
		oReport:SkipLine(1)
		oReport:Line(oReport:Row(),0001,oReport:Row(),3230)
		oReport:SkipLine(1)
	EndIf

	If aScan(aVetCpos, {|aVet| aVet[2] == "GCY"})  > 0
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:Say(oReport:Row(),900, "",oFont1)
		oReport:SkipLine(1)
		oReport:SkipLine(1)

		oReport:Say(oReport:Row(),900, STR0017 ,oFont2)//"Dados do Atendimento"
		oReport:SkipLine(1)
		oReport:SkipLine(1)

		aLinGcy := FS_IMPTABELA("GCY")
		For nLin := 1 to len(aLinGcy)
			oReport:Say(oReport:Row(),10, aLinGcy[nLin],oFont1)
			oReport:SkipLine(1)
			oReport:SkipLine(1)
		Next
		oReport:SkipLine(1)
		oReport:Line(oReport:Row(),0001,oReport:Row(),3230,,oFont2)
		oReport:SkipLine(1)
	EndIf



	If (aScan(aVetCpos, {|aVet| aVet[2] == "GB2"})  > 0  .and. 	Alltrim(cTipnasc) $ "0/1/2/3/4/5")
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:Say(oReport:Row(),900, "",oFont1)
		oReport:SkipLine(1)
		oReport:SkipLine(1)

		oReport:Say(oReport:Row(),900, STR0018 ,oFont2)//"Dados do RN"
		oReport:SkipLine(1)
		oReport:SkipLine(1)

		aLinGcy := FS_IMPTABELA("GB2")
		For nLin := 1 to len(aLinGcy)
			oReport:Say(oReport:Row(),10, aLinGcy[nLin],oFont1)
			oReport:SkipLine(1)
			oReport:SkipLine(1)
		Next
		oReport:SkipLine(1)
		oReport:Line(oReport:Row(),0001,oReport:Row(),3230,,oFont2)
		oReport:SkipLine(1)

	EndIf

	oReport:SkipLine(1)
	oReport:SkipLine(1)
	oReport:SkipLine(1)


RestArea(aArea)
Return(nLin)
 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPTABELA  ºAutor  ³Microsiga           º Data ³  12/28/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_IMPTABELA(cAlias, nLin)
	Local aLinhas := {}
	Local cLinha	:= ""
	Local cLinAux	:= ""
	Local nTotPag 	:= 170
	Local nI:=0
	Local cConteu :=""
	Local clinhaF:= ""
	Local cX3BOX 	:=""
	Local aBox 		:={}

	For nI := 1 to Len(aVetCpos)
		If aVetCpos[nI,2] == cAlias .AND. ValType("M->" + aVetCpos[nI,3]) # "U"
			cLinAux := cLinha
			DbSelectArea("SX3")
			DbSetOrder(2)
			DbSeek(aVetCpos[nI,3])
			If Len(Alltrim(cLinha)) <> 0
				cLinha += "     "
			EndIf
			If  valtype((&("M->" + aVetCpos[nI,3]))) =="D"
				cConteu:= Dtoc((&("M->" + aVetCpos[nI,3])))
			ElseIf valtype((&("M->" + aVetCpos[nI,3]))) == "N"
				cConteu:=str((&("M->" + aVetCpos[nI,3]))	)
			Else
				cConteu:=alltrim(&("M->" + aVetCpos[nI,3]))
				cX3BOX := HS_CfgSx3(aVetCpos[nI,3])[SX3->(FieldPos("X3_CBOX"))]
				If !Empty(cX3BOX)
					Hs_dcbox(aVetCpos[nI,3],@aBox)
					cConteu := IIF(aScan(aBox , {|aVet|aVet[1] == alltrim(&("M->" + aVetCpos[nI,3]))}) > 0, aBox[ASCAN(aBox,{|aVet| aVet[1] == alltrim(&("M->" + aVetCpos[nI,3]))}),2],alltrim(&("M->" + aVetCpos[nI,3])))
					cX3BOX :=""
				Endif
			Endif

			If Len(cLinha) < nTotPag
				cLinha += Alltrim(X3titulo()) + ": " + cConteu
			Endif

			If Len(cLinha) >= nTotPag
				AADD(aLinhas,Substr(cLinAux,1,nTotPag))
				cLinha := ""
				clinhaF:=Alltrim(X3titulo()) + ": " + cConteu
				clinha :=clinhaF
				clinhaF :=""
			EndIf
		EndIf
	Next nI

	If Len(cLinha) < nTotPag
		AADD(aLinhas,cLinha)
	EndIf

Return(aLinhas)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSCertDig º Autor ³ Microsiga         º Data ³  20/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a certificacao digital dos relatorios de anamnese  º±±
±±º          ³ e prescricao medica                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ cTipCert "1" - Anamnese (1 arquivo)                        º±±
±±º          ³          "2" - Prescricao (1 arquivo)                      º±±
±±º          ³          "3" - Validar assinatura anamnese                 º±±
±±º          ³          "4" - Assinatura por lote - anamnese              º±±
±±º          ³          "5" - Assinatura lor lote - prescricao            º±±
±±º          ³          "6" - Validar assinatura prescricao               º±±
±±º          ³                                                            º±±
±±º          ³ Importante: ao chamar essa rotina para assinatura unitaria º±±
±±º          ³ a tabela GFU ou GHV deve estar posicionada 			      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSCertDig(cTipCert,cNameFile,cCodCrm,cFolderLot,aGuiasLote)
Local cFolderPdf  := ""    
Local cNameCert   := "DLLAssinaturaDigital.dll"
Local nRet        := 0
Local cBuffer     := ""
Local nParamCert  := 0                
Local cAlias      := ""
Local cUrlWebServ := ""
Local lOk         := .T.
Local cPathServer := ""   
Local cPathLocal  := ""
Local aRetPath    := {}
Local aArea       := {}
Local oXML           
Local cError      := ""
Local cWarning    := ""
Local nCont       := 0
Local cFileXML    := ""
Local nQtdLote    := 0
Local aProxyInfo  := {}
Local cMsgFim     := ""
Default cNameFile := ""
Default cCodCrm   := ""
Default cFolderLot:= ""
Default aGuiasLote:= {}    

nQtdLote := len(aGuiasLote)

Do Case 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Assina Anamnese (um arquivo)                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipCert == "1"
		cFolderPdf := "\certificados\anamnese\"+cCodCrm
		nParamCert := 1
		cBuffer:= GetTempPath()+"totvsprinter\"+cNameFile+".pdf"+Space(2740-len(GetTempPath()+"totvsprinter\"+cNameFile+".pdf"))
		cAlias := "GFU"      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Assina Prescricao (um arquivo)                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case cTipCert == "2" 
		cFolderPdf := "\certificados\prescricao\" 
		nParamCert := 1   
		cBuffer:= GetTempPath()+"totvsprinter\"+cNameFile+".pdf"+Space(2740-len(GetTempPath()+"totvsprinter\"+cNameFile+".pdf"))
		cAlias := "GHV"  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida assinatura Anamnese			                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case cTipCert == "3"
		nParamCert := 3
		cPathServer := PLSMUDSIS(Alltrim(GFU->GFU_DIRCER)+'\'+GFU->GFU_ARQCER)  
		aRetPath    := fDirPdfHSP(Alltrim(GFU->GFU_CODCRM),"A")
		If aRetPath[1]
			cPathLocal := aRetPath[2]  
			If !CpyS2T(cPathServer,cPathLocal,.T.)
				MsgInfo("Não foi possível mover o arquivo PDF para a pasta "+cPathLocal)
				lOk := .F.
			EndIf	
		Else
           	MsgInfo(aRetPath[2])
           	lOk := .F.
		EndIf
			  
	    cUrlWebServ := GetNewPar("MV_HSURLCD","")
		If Empty(cUrlWebServ)
			MsgInfo("Necessário informar o parâmetro MV_HSURLCD com a URL do WebService") 	
			lOk := .F.
		Else  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   			//³ Verifica se ha configuracao de proxy                                        ³
  			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aProxyInfo := GetProxyCD()   
		
			cBuffer := E_MSMM(GFU->GFU_ASSDIG) 
			cBuffer += "|"+(cPathLocal+Alltrim(GFU->GFU_ARQCER))
			cBuffer += "|"+cUrlWebServ 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   			//³ Utiliza o proxy                                                             ³
  			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			cBuffer += "|"+aProxyInfo[1]
			cBuffer += "|"+aProxyInfo[2]
			cBuffer += "|"+aProxyInfo[3]
			cBuffer += "|"+aProxyInfo[4]
		EndIf     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida assinatura Prescricao     	                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case cTipCert == "6"
		nParamCert := 3
		cPathServer := PLSMUDSIS(Alltrim(GHV->GHV_DIRCER)+'\'+GHV->GHV_ARQCER)  
		aRetPath    := fDirPdfHSP(Alltrim(GHV->GHV_CODCRM),"P")
		If aRetPath[1]
			cPathLocal := aRetPath[2]  
			If !CpyS2T(cPathServer,cPathLocal,.T.)
				MsgInfo("Não foi possível mover o arquivo PDF para a pasta "+cPathLocal)
				lOk := .F.
			EndIf	
		Else
           	MsgInfo(aRetPath[2])
           	lOk := .F.
		EndIf
			  
	    cUrlWebServ := GetNewPar("MV_HSURLCD","")
		If Empty(cUrlWebServ)
			MsgInfo("Necessário informar o parâmetro MV_HSURLCD com a URL do WebService") 	
			lOk := .F.
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   			//³ Verifica se ha configuracao de proxy                                        ³
  			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aProxyInfo := GetProxyCD()   
			
			cBuffer := E_MSMM(GHV->GHV_ASSDIG) 
			cBuffer += "|"+(cPathLocal+Alltrim(GHV->GHV_ARQCER))
			cBuffer += "|"+cUrlWebServ    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   			//³ Utiliza o proxy                                                             ³
  			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			cBuffer += "|"+aProxyInfo[1]
			cBuffer += "|"+aProxyInfo[2]
			cBuffer += "|"+aProxyInfo[3]
			cBuffer += "|"+aProxyInfo[4]
		
		EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Assinatura por lote - Anamnese			                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case cTipCert == "4" 
		nParamCert := 2
		cBuffer    := GetTempPath()+"totvsprinter\"+cFolderLot+"\" 
		cFileXML   := cBuffer  
		cAlias     := "GFU" 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Assinatura por lote - Prescricao		                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case cTipCert == "5" 
		nParamCert := 2
		cBuffer    := GetTempPath()+"totvsprinter\"+cFolderLot+"\"   
		cFileXML   := cBuffer
		cAlias     := "GHV" 
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria diretorio para salvar arquivos - Pastas primarias                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lOk .And. MakeDir(PLSMUDSIS("\certificados")) == 3
   MsgInfo("Não foi possível criar diretorio certificados")
   lOk := .F.
EndIf      

If lOk .And. cTipCert $ "14" .And. MakeDir(PLSMUDSIS("\certificados\anamnese\")) == 3
   MsgInfo("Não foi possível criar diretorio \certificados\anamnese\")
   lOk := .F.
EndIf 

If lOk .And. cTipCert $ "25" .And. MakeDir(PLSMUDSIS("\certificados\prescricao\")) == 3
   MsgInfo("Não foi possível criar diretorio \certificados\prescricao\")
   lOk := .F.
EndIf 

If cTipCert $ "45" .And. MakeDir(PLSMUDSIS("\certificados\xml")) == 3
	MsgInfo("Não foi possível criar o diretorio \certificados\xml")
	lOk := .F.
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria diretorio para salvar arquivos - Pastas variaveis                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lOk .And. cTipCert $ "12" .And. MakeDir(PLSMUDSIS(cFolderPdf)) == 3
   MsgInfo("Não foi possível criar diretorio "+ cFolderPdf)
   lOk := .F.
EndIf          

If cTipCert $ "45" .And. MakeDir(GetTempPath()+"totvsprinter\"+cFolderLot) == 3
	MsgInfo("Não foi possível criar o diretorio "+GetTempPath()+"totvsprinter\"+cFolderLot)
	lOk := .F.
EndIf       

If cTipCert $ "4"
	For nCont := 1 to len(aGuiasLote)
		If MakeDir(PLSMUDSIS("\certificados\anamnese\"+Alltrim(aGuiasLote[nCont][3]))) == 3 
			MsgInfo("Não foi possível criar diretorio \certificados\anamnese\"+aGuiasLote[nCont][3])
			lOk := .F.          
		EndIf	
	Next
EndIf    

If cTipCert $ "5"
	For nCont := 1 to len(aGuiasLote)
		If MakeDir(PLSMUDSIS("\certificados\prescricao\"+Alltrim(aGuiasLote[nCont][3]))) == 3 
			MsgInfo("Não foi possível criar diretorio \certificados\prescricao\"+aGuiasLote[nCont][3])
			lOk := .F.
		EndIf	
	Next
EndIf    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tudo Ok, chama a DLL para certificar/validar                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk
	nHnd := ExecInDLLOpen(cNameCert)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e possivel acessar a dll                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nHnd == -1
		If File(cNameCert, 2)
			Alert("Falha ao carregar DLL. Verifique atualização da DLL: "+cNameCert)
		Else
			Alert("ERRO - DLL não encontrada: "+cNameCert)
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa DLLAssinaturaDigital.dll para realizar a assinatura do certificado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := ExeDLLRun2(nHnd, nParamCert, @cBuffer)

		ExecInDllClose( nHnd ) 
	 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno de assinatura unitaria                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		If cTipCert $ "12" .And. len(cBuffer) > 20 .And. Substr(cBuffer,1,21) == "-----BEGIN PKCS7-----"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia o arquivo PDF para o servidor                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CpyT2S( GetTempPath()+"totvsprinter\"+cNameFile+".pdf", PLSMUDSIS(cFolderPdf) )     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o retorno da assinatura na tabela correspondente                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSMM(nil,len(Alltrim(cBuffer)),nil,Alltrim(cBuffer),1,nil,nil,cAlias,cAlias+"_ASSDIG")  
			RecLock(cAlias, .F.)
			&(cAlias+"->"+cAlias+"_STAASS") := "1"      
			&(cAlias+"->"+cAlias+"_ARQCER") := cNameFile+".PDF"  
	 		&(cAlias+"->"+cAlias+"_DIRCER") := cFolderPdf
			MsUnlock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno de validacao de assinatura                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		ElseIf cTipCert $ "36"   
			MsgInfo(cBuffer)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno de assinatura por lote - Anamnese/Prescricao                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		ElseIf cTipCert $ "45" 
			
			aArea := &(cAlias+"->(GetArea())")
			CpyT2S( GetTempPath()+"totvsprinter\"+cFolderLot+"\"+Alltrim(cBuffer), PLSMUDSIS("\certificados\xml") )  
			oXml := XmlParserFile( PLSMUDSIS("\certificados\xml\")+Alltrim(cBuffer), "_", @cError, @cWarning )
							
			If Empty(cError) .And. Empty(cWarning) .And. XmlChildEx(oXml:_OUTPUT ,"_DOCUMENT") <> Nil
				
				If nQtdLote == 1
					
					If oXml:_OUTPUT:_DOCUMENT:_STATUSID:Text == "1" .And. ;
						IIF(cAlias == "GFU",&(cAlias)->(DbSeek(xFilial(cAlias)+UPPER(Substr(oXml:_OUTPUT:_DOCUMENT:_DOCID:Text,13,6)))), &(cAlias)->(DbSeek(xFilial(cAlias)+UPPER(Substr(oXml:_OUTPUT:_DOCUMENT:_DOCID:Text,4,6))+UPPER(Substr(oXml:_OUTPUT:_DOCUMENT:_DOCID:Text,13,6)))))
					  
					 	MSMM(nil,len(Alltrim(oXml:_OUTPUT:_DOCUMENT:_SIG:Text)),nil,Alltrim(oXml:_OUTPUT:_DOCUMENT:_SIG:Text),1,nil,nil,cAlias,cAlias+"_ASSDIG") 
						cNameFile := UPPER(oXml:_OUTPUT:_DOCUMENT:_DOCID:Text)
						
						If cTipCert == "4"
							cFolderPdf := "\certificados\anamnese\"+Alltrim(&(cAlias+"->"+cAlias+"_CODCRM"))
						ElseIf cTipCert == "5"
							cFolderPdf := "\certificados\prescricao\"+Alltrim(&(cAlias+"->"+cAlias+"_CODCRM"))
						EndIf             
						
						RecLock(cAlias, .F.)
		 				&(cAlias+"->"+cAlias+"_STAASS") := "1"      
		   				&(cAlias+"->"+cAlias+"_ARQCER") := cNameFile
	 	   				&(cAlias+"->"+cAlias+"_DIRCER") := cFolderPdf
		  				MsUnlock()	
		  				
		  				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Copia o arquivo PDF para o servidor                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						CpyT2S( GetTempPath()+"totvsprinter\"+cNameFile, PLSMUDSIS(cFolderPdf) )    
					Else
						cMsgFim += "Não foi possível assinar o arquivo: "+UPPER(oXml:_OUTPUT:_DOCUMENT:_DOCID:Text)
					Endif 
				Else
					For nCont := 1 to len(oXml:_OUTPUT:_DOCUMENT)       
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz a leitura do arquivo Xml gerado                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If oXml:_OUTPUT:_DOCUMENT[nCont]:_STATUSID:Text == "1" .And. ;
							IIF(cAlias == "GFU",&(cAlias)->(DbSeek(xFilial(cAlias)+UPPER(Substr(oXml:_OUTPUT:_DOCUMENT[nCont]:_DOCID:Text,13,6)))), &(cAlias)->(DbSeek(xFilial(cAlias)+UPPER(Substr(oXml:_OUTPUT:_DOCUMENT[nCont]:_DOCID:Text,4,6))+UPPER(Substr(oXml:_OUTPUT:_DOCUMENT[nCont]:_DOCID:Text,13,6)))))
							
							MSMM(nil,len(Alltrim(oXml:_OUTPUT:_DOCUMENT[nCont]:_SIG:Text)),nil,Alltrim(oXml:_OUTPUT:_DOCUMENT[nCont]:_SIG:Text),1,nil,nil,cAlias,cAlias+"_ASSDIG") 
							cNameFile := UPPER(oXml:_OUTPUT:_DOCUMENT[nCont]:_DOCID:Text)
							
							If cTipCert == "4"
								cFolderPdf := "\certificados\anamnese\"+Alltrim(&(cAlias+"->"+cAlias+"_CODCRM"))
							ElseIf cTipCert == "5"
								cFolderPdf := "\certificados\prescricao\"+Alltrim(&(cAlias+"->"+cAlias+"_CODCRM"))
							EndIf             
						
							RecLock(cAlias, .F.)
			 				&(cAlias+"->"+cAlias+"_STAASS") := "1"      
			   				&(cAlias+"->"+cAlias+"_ARQCER") := cNameFile
		 	   				&(cAlias+"->"+cAlias+"_DIRCER") := cFolderPdf
			  				MsUnlock()		
						  
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Copia o arquivo PDF para o servidor                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							CpyT2S( GetTempPath()+"totvsprinter\"+cNameFile, PLSMUDSIS(cFolderPdf) )    
						Else
							cMsgFim += "Não foi possível assinar o arquivo: "+UPPER(oXml:_OUTPUT:_DOCUMENT[nCont]:_DOCID:Text) + CHR(13)+CHR(10)
						EndIf 	 
					Next      
				EndIf	
	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver algum problema na realizacao do Parse, informa                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Else
		    	If !Empty(cError)
		       		MsgInfo("Não foi possível carregar o arquivo XML gerado. Erro: "+cError)
		        ElseIf !Empty(cWarning)
		       		MsgInfo("Não foi possível carregar o arquivo XML gerado. Aviso: "+cWarning)
				Else
			   		MsgInfo("Processo cancelado.")
				EndIf
					
		    EndIf
			
			RestArea(aArea)   
			DelClassIntf()  
		EndIf	
		
	EndIf        
EndIf

If !Empty(cMsgFim)
	MsgInfo(cMsgFim)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GetProxyCD ³ Autor ³ TOTVS               ³ Data ³ 01.02.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Define proxy para validacao do certificado digital		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetProxyCD()
LOCAL cIniFile  := ""
LOCAL cAddress  := ""  
LOCAL cUsername := ""
LOCAL cPassword := ""
LOCAL cDomain   := ""  
LOCAL cPath     := ""

cPath := GetNewPar("MV_HSPROCD","")
If Empty(cPath)
	cIniFile := PLSMUDSIS("\certdigproxy.ini")
Else 
	If Substr(cPath,len(cPath),1) $ "\/"
		cIniFile := cPath+"certdigproxy.ini"	
	Else
		cIniFile := cPath+"\certdigproxy.ini"	
	EndIf	
	cIniFile := PLSMUDSIS(cIniFile)
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o conteudo as informacoes do proxy                         		   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
cAddress   := GetPvProfString("SETUP","Address" ,"",cIniFile)
cUsername  := GetPvProfString("SETUP","Username","",cIniFile)
cPassword  := GetPvProfString("SETUP","Password","",cIniFile)
cDomain    := GetPvProfString("SETUP","Domain"  ,"",cIniFile)

Return {cAddress,cUsername,cPassword,cDomain}
