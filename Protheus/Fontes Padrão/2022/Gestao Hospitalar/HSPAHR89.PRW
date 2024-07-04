#INCLUDE 'Protheus.ch'
#INCLUDE 'Topconn.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHR89 ³ Autor ³ Saude                 ³ Data ³ 14/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Impressao do Mapa Geral de trabalho           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPAHR89(cNumMapa)

Default cNumMapa := ""

Private oReport
Private cMapa	:= cNumMapa

oReport := ReportDef() 
oReport:PrintDialog()  

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡…o ³ Impressao do relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef()

//Local oReport		// Objeto do relatório
Local oSection1		// Objeto da seção 1
Local oCell			// Obejot do cabeçalho
 
oReport := TReport():New("HSPAHR89","Mapa de Trabalho Geral", , {|oReport| R89IMP(oReport)}, "Mapa de Trabalho Geral") //" imprimir a quantidade partos e nascidos por convênio por período."
 
oReport:SetPortrait()

oSection1 := TRSection():New(oReport, "Mapa de Trabalho Geral", {"GCY"}) //"RELATÓRIO QUANTIDADE DE PARTOS E NASCIDOS POR CONVÊNIO"
oCell := TRCell():New(oSection1, " TESTE1 ",," Col 1",,17) 		//"CONVENIOS"
oReport:SkipLine(1)                                                                          
oCell := TRCell():New(oSection1, " TESTE1 ",," Col 2",,40) 		//"CONVENIOS"


Return(oReport)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R89IMP   ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡…o ³ Montagem da query e quebras do relatorio                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R89IMP(oReport)

//Local oSection1 := oReport:Section(1)
//Local nLin		:= 0
Local nAux		:= 0
Local nCol		:= 50
Local cLocExe	:= ""
Local cCodPed	:= ""
Local cMater	:= ""
Local cIdUrg	:= ""

Local cSql		:= ""
Local cCabec	:= "Requisição       Data da Coleta         Paciente                                               Sexo             Idade             Local                                             Procedencia "

Local oFont1 	:= TFont():New("Times New Roman",9,12 ,.T.,.F.,5,.T.,5,.T.,.F.) 
Local oFont2 	:= TFont():New("Times New Roman",9,15 ,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont3 	:= TFont():New("Times New Roman",9,13 ,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont4 	:= TFont():New("Times New Roman",9,11 ,.F.,.T.,5,.T.,5,.T.,.F.)
Local lQuebra	:= .F.
Local lCabec	:= .F.
Local lPrxQua	:= .F.

cSql := " SELECT GA7_MNEMON, GA7_DESC, GBY_CODLOC, GBY_LOCSOL, GBY_CODPED, GPC_DESCRI MATERIAL, GBY_URGDES, " 
cSql += " GBY_SOLICI, GBY_DATCOL, GD0_DORIPA, GCY_NOME, GCY_SEXO, GCY_IDADE, GCS1.GCS_NOMLOC EXECUTANTE, "
cSql += " GBH_DTNASC, GCS2.GCS_NOMLOC SOLICITANTE , GBY_RESERV, GCY_REGATE "
cSql += " FROM " + RetSqlName("GBY") + " GBY "
cSql += " JOIN " + RetSqlName("GCS") + " GCS1 ON GCS1.GCS_CODLOC = GBY.GBY_CODLOC AND GCS1.GCS_FILIAL = '"  + xFilial("GCS") + "' AND GCS1.D_E_L_E_T_ <> '*' ""
cSql += " JOIN " + RetSqlName("GCS") + " GCS2 ON GCS2.GCS_CODLOC = GBY.GBY_LOCSOL AND GCS2.GCS_FILIAL = '"  + xFilial("GCS") + "' AND GCS2.D_E_L_E_T_ <> '*' ""
cSql += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_CODPRO = GBY.GBY_PROSOL AND GA7.GA7_FILIAL = '"  + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' ""
cSql += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_REGATE = GBY.GBY_REGATE AND GCY.GCY_FILIAL = '"  + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' ""
cSql += " JOIN " + RetSqlName("GBH") + " GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = '"  + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' ""
cSql += " LEFT JOIN " + RetSqlName("GD0") + " GD0 ON GD0.GD0_ORIPAC = GCY.GCY_ORIPAC AND GD0.GD0_FILIAL = '"  + xFilial("GD0") + "' AND GD0.D_E_L_E_T_ <> '*' ""
cSql += " LEFT JOIN " + RetSqlName("GPG") + " GPG ON GPG.GPG_CODSEQ = GBY.GBY_CFGMMM AND GPG.GPG_FILIAL = '"  + xFilial("GPG") + "' AND GPG.D_E_L_E_T_ <> '*' ""
cSql += " LEFT JOIN " + RetSqlName("GPC") + " GPC ON GPC.GPC_CODMAT = GPG.GPG_CODMAT AND GPG.GPG_FILIAL = '"  + xFilial("GPG") + "' AND GPG.D_E_L_E_T_ <> '*' ""
cSql += " WHERE GBY.GBY_NUMMAP = '" + cMapa + "' AND GBY.GBY_FILIAL = '"  + xFilial("GBY") + "' AND GBY.D_E_L_E_T_ <> '*' "
cSql += " ORDER BY GBY_CODLOC, GBY_CODPED, GPC_DESCRI, GBY_URGDES "

cSql := ChangeQuery(cSql)

TCQUERY cSql NEW ALIAS "QRYR89"

//FS_CABTPQ5(@oReport, cTabela,cChave,lMntVazio)   

oReport:SkipLine(1)

oReport:Say(oReport:Row(),040, "" ,oFont3)
oReport:Say(oReport:Row(),040, "Data da Impressão: " + DTOC(dDataBase) + " " + Time() ,oFont3)
oReport:Say(oReport:Row(),1900, "Numero do Mapa: " + cMapa ,oFont3)
oReport:SkipLine(5)

While !QRYR89->(Eof())    
	If cLocExe <> Alltrim(QRYR89->GBY_CODLOC)
		lQuebra := .T.     
		nCol := 50
		oReport:Say(oReport:Row(),040, Alltrim(QRYR89->EXECUTANTE) ,oFont2)		
		oReport:SkipLine(3)
	EndIf
	If !lCabec 
		lCabec := .T.
		nCol := 50		
		oReport:Say(oReport:Row(),040, cCabec ,oFont3)
		oReport:SkipLine(2) 							
		oReport:Line(oReport:Row(),0001,oReport:Row(),3230) // IMPRIME LINHA Horizontal
		oReport:SkipLine(1) 					
	Endif
	If cCodPed <> Alltrim(QRYR89->GBY_CODPED) .OR. lQuebra
		If lPrxQua
			lPrxQua := .F.
			oReport:nRow := oReport:Row() + 170
		EndIf
		nAux := 0
		lQuebra := .T.
		nCol := 50		
		oReport:Say(oReport:Row(),040, QRYR89->GBY_CODPED ,oFont2)		
		oReport:Say(oReport:Row(),250, IIf(!Empty(QRYR89->GBY_DATCOL),HS_DTOC(STOD(QRYR89->GBY_DATCOL)),"") ,oFont4)				
		If Alltrim(QRYR89->GBY_RESERV) $ "0/1/2/3/4/5"		
			DbSelectArea("GB2")
			DbSetOrder(1)
			If DbSeek(xFilial("GB2") + QRYR89->GCY_REGATE + QRYR89->GBY_RESERV)
				oReport:Say(oReport:Row(),560, Alltrim(GB2->GB2_NOME) ,oFont4)	                       
				oReport:Say(oReport:Row(),1250, FS_Idade(GB2->GB2_DTNASC, dDataBase) ,oFont4) 
				oReport:Say(oReport:Row(),1060, HS_RDescrB("GCY_SEXO  " , GB2->GB2_SEXO) ,oFont4)												
			Else
				oReport:Say(oReport:Row(),560, Alltrim(QRYR89->GCY_NOME) ,oFont4)				   
				oReport:Say(oReport:Row(),1250, FS_Idade(STOD(QRYR89->GBH_DTNASC), dDataBase) ,oFont4) 		
				oReport:Say(oReport:Row(),1060, HS_RDescrB("GCY_SEXO  " , QRYR89->GCY_SEXO) ,oFont4)												
			EndIf			
		Else
			oReport:Say(oReport:Row(),560, Alltrim(QRYR89->GCY_NOME) ,oFont4)					 
			oReport:Say(oReport:Row(),1250, FS_Idade(STOD(QRYR89->GBH_DTNASC), dDataBase) ,oFont4) 	
			oReport:Say(oReport:Row(),1060, HS_RDescrB("GCY_SEXO  " , QRYR89->GCY_SEXO) ,oFont4)											
		EndIf
		//oReport:Say(oReport:Row(),1060, HS_RDescrB("GCY_SEXO  " , QRYR89->GCY_SEXO) ,oFont4)								
		//oReport:Say(oReport:Row(),1250, FS_Idade(STOD(QRYR89->GBH_DTNASC), dDataBase) ,oFont4) 
		oReport:Say(oReport:Row(),1450, Substring(Alltrim(QRYR89->SOLICITANTE),1,20) ,oFont4) 		
		oReport:Say(oReport:Row(),1900, Alltrim(QRYR89->GD0_DORIPA) ,oFont4)
		oReport:SkipLine(3)  
		oReport:SkipLine(1)  		
	EndIf
	If cMater <> Alltrim(QRYR89->MATERIAL) .OR. cIdUrg <> QRYR89->GBY_URGDES .OR. lQuebra	 
	    If nAux > 0 
			oReport:SkipLine(5)
		EndIf
		lQuebra := .T.
		nCol := 50		
		oReport:Say(oReport:Row(),040, Iif(!Empty(Alltrim(QRYR89->MATERIAL)),Alltrim(QRYR89->MATERIAL) + " - ","") + IIf(QRYR89->GBY_URGDES == "1", "Urgencia", "Normal") ,oFont3) 
		oReport:SkipLine(1)  		
		oReport:SkipLine(2)
	EndIf        
	If nCol > 1800
		oReport:SkipLine(5)
		nCol := 50
	EndIf		
	oReport:box(oReport:Row(),nCol,oReport:Row() + 120,nCol + 300)
	lPrxQua := .T.
	//oReport:box(0500,0030,0600,0500)	
	oReport:Say(oReport:Row() + 4,nCol + 4, IIf(Empty(QRYR89->GA7_MNEMON),Substr(QRYR89->GA7_DESC,1,4),Alltrim(QRYR89->GA7_MNEMON)) ,oFont1) 	
	nCol := nCol + 310

	lQuebra := .F.
	nAux ++
	cLocExe	:= Alltrim(QRYR89->GBY_CODLOC)
	cCodPed	:= Alltrim(QRYR89->GBY_CODPED)
	cMater	:= Alltrim(QRYR89->MATERIAL)
	cIdUrg	:= QRYR89->GBY_URGDES
	QRYR89->(DbSkip())
EndDo

oReport:SkipLine(1)
If oReport:PageBreak()
	oReport:PrintHeader() 
EndIf  

DbSelectArea("QRYR89")
DbCloseArea()

//oReport:endpage()

Return(Nil)

 
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
