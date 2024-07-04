#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH' 
#INCLUDE 'HSPAHR93.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RelSUS ºAutor  ³Sueli C. Santos     º Data ³  05/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_RelSUS()
Local cPerg		:= PADR("HSPLDO",6)


AjustaSX1()

If !Pergunte(cPerg, .T.)
	Return
EndIf

If MV_PAR01 == 1
	HSPR9301("GCY")
EndIf
If MV_PAR02 == 1
	HSPR9302("GCY")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPR9301  ºAutor  ³Sueli C Santos      º Data ³  10/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte criado para emitir o relatorio de Controle de         º±±
±±º          ³Frequencia Individual (Deficiencia Fisica).                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HSPR9301(cTabela)
Local nLinMax	:= 0
Local nColMax	:= 0
Local nLinIni	:= 0	// Linha Lateral (inicial) Esquerda
Local nColIni	:= 0	// Coluna Lateral (inicial) Esquerda
Local nColA4    := 0
Local nLinA4    := 0
Local cFileLogo
Local lPrinter     
Local nT		:= 0
Local nT1		:= 0
Local nT3		:= 0
Local n			:= 0
Local nO		:= 0
Local oFont02
Local oFont02n
Local oFont03n
Local oFont04
Local oFont05
Local oFont06n
Local nVolta    := 0
Local cDesPro1	:= ""
Local cCnesHosp := SuperGetMV("MV_HSPCNES")	// parametro do codigo CNES do Hospital
Local aProc 	:= {} 
Local cNrSeqG	:= ""
Local cNumDoc	:= ""

// ------------------------------- Posiciona tabela utilizada ------------------------------ //
If cTabela == "GCY"                         
	If HS_CountTB("GCZ", "GCZ_REGATE = '" + GCY->GCY_REGATE + "'") > 1 	
		cSql := " SELECT MAX(GCZ_NRSEQG) GCZ_NRSEQG FROM " + RetSqlName("GCZ") + " GCZ " 
		cSql += " WHERE GCZ_REGATE = '" + GCY->GCY_REGATE + "' AND D_E_L_E_T_ <> '*' "

	   	cSQL := ChangeQuery(cSQL)
	   	TCQUERY cSQL NEW ALIAS "TMPGCZ"			
		
		cNrSeqG := TMPGCZ->GCZ_NRSEQG

		DbSelectArea("TMPGCZ")
		DbCloseArea()
				
		DbSelectArea("GCZ")
		DbSetOrder(1)
		DbSeek(xFilial("GCZ") + cNrSeqG)
	Else
		DbSelectArea("GCZ")
		DbSetOrder(2)
		DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)
	EndIf   
ElseIf cTabela == "GCZ"  
	DbSelectArea("GCY")
	DbSetOrder(1)
	DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
EndIf

	// Papél A4
	nLinMax	:=	3200   
	nColMax	:=	2330   
		
	// Papél A4
	oFontSo		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont02		:= TFont():New("Arial", 11, 11, , .F., , , , .T., .F.) // Normal
	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont04n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont05		:= TFont():New("Arial", 09, 09, , .T., , , , .T., .F.) // Negrito
	oFont06n	:= TFont():New("Arial", 07, 07, , .T., , , , .T., .F.) // Negrito
		
	oPrint	:= TMSPrinter():New(STR0001) //"LAUDO PARA SOLICITACAO DE AUTORIZAÇÃO DE INTERNAÇÃO HOSPITALAR"
		
	oPrint:SetPortrait()	// Modo retrato
		
	oPrint:SetPaperSize(9)// Papél A4
		
	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()
	
		
	DbSelectArea(cTabela)

	nVolta  += 1
	nT      += 5
	nT1     += 2
	nT3     += 3
	
	nLinIni := 0
	nColIni := 0
	nColA4  := 0
	nLinA4  := 0
		
	oPrint:StartPage()		// Inicia uma nova pagina
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Box Principal                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Box( 0010, 0010, nLinMax, nColMax)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega e Imprime Logotipo da Empresa                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FS_LogoEmp(@cFileLogo)
	
	oPrint:Box(0050, 0020, 0200, 0600)
	If File(cFilelogo)
		oPrint:SayBitmap(0090, 0040, cFileLogo, 0400, 0100)		// Tem que estar abaixo do RootPath
	EndIf 
	
	// Papél A4
	nColA4    := -0065
	
	oPrint:Box(0050, 0610, 0200, 2320)
	oPrint:Say(0090, 1285 + nColA4, STR0002, oFont03n,,,, 2) //"LAUDO PARA SOLICITAÇÃO DE AUTORIZAÇÃO "
	oPrint:Say(0140, 1285 + nColA4, STR0003, oFont03n,,,, 2) //"DE INTERNAÇÃO HOSPITALAR"

	DbSelectArea("GK7")
	DbSetOrder(3)
	If DbSeek(xFilial("GK7") + &(cTabela+"->"+cTabela+"_REGATE"))
		MsBar3( 'CODE128', 0.7 , 17, Alltrim(GK7->GK7_SOLICI), oPrint, .F., , .T., 0.015, 0.6, .F., 'TAHOMA', 'B', .F. )
		oPrint:Say(0165, 2100 + nColA4, Alltrim(GK7->GK7_SOLICI), oFontSo) //
	EndIf
	// Bloco I - Identificacao do Estabelecimento    

	oPrint:Box(0210, 0020, 0450, 2320)
	oPrint:Say(0220, 0030, STR0004, oFont04) //"Identificação do Estabelecimento de Saude"
   
	oPrint:Box(0250, 0030, 0340, 1800)
	oPrint:Say(0250, 0040, STR0005, oFont04) //"Nome do Estabelecimento Solicitante"
	oPrint:Say(0280, 0040, SM0->M0_NOMECOM, oFont05)

	oPrint:Box(0250, 1810, 0340, 2310)
	oPrint:Say(0250, 1890 + nColA4, STR0006, oFont04) //"CNES"
	oPrint:Say(0280, 1900 + nColA4, cCnesHosp, oFont05)
	
	oPrint:Box(0350, 0030, 0440, 1800)
	oPrint:Say(0350, 0040, STR0007, oFont04) //"Nome do Estabelecimento Executante"
	oPrint:Say(0380, 0040, SM0->M0_NOMECOM, oFont05)
	
	oPrint:Box(0350, 1810, 0440, 2310)
	oPrint:Say(0350, 1890 + nColA4, STR0006, oFont04) //"CNES"
	oPrint:Say(0380, 1900 + nColA4, cCnesHosp, oFont05)

   
	//Bloco II - Identificacao do Paciente
	oPrint:Box(0460, 0020, 1100, 2320)   
	oPrint:Say(0470, 0030, STR0008, oFont04) //"Identificacao do Paciente"
	
	If &(cTabela+"->"+cTabela+"_TPALTA") == "99"
		HS_MSGINF(STR0093,STR0091,STR0092) //"Paciente cancelado!","Atenção","Validação Laudo SUS"		
		Return()                                                        
	ElseIf HS_COUNTTB("GD4","GD4_REGGER ='" + &(cTabela+"->"+cTabela+"_REGGER") + "' AND GD4_CODCON = '" + GetMV("MV_PCONSUS",,"") +  "'") == 0
		HS_MSGINF(STR0094,,STR0091,STR0092) //"Paciente não possui convênio SUS!","Atenção","Validação Laudo SUS"		
		Return()                                                        	
	EndIf
	
	DbSelectArea("GBH")
	DbSetOrder(1)
	DbSeek(xFilial("GBH") + &(cTabela+"->"+cTabela+"_REGGER"))
	
	oPrint:Box(0500, 0030, 0590, 1800)
	oPrint:Say(0500, 0040, STR0009, oFont04) //"Nome do Paciente"
   	oPrint:Say(0530, 0050, GBH->GBH_NOME, oFont05)

	oPrint:Box(0500, 1810, 0590, 2310)
	oPrint:Say(0500, 1890 + nColA4, STR0010, oFont04) //"Nº do Prontuário"
	oPrint:Say(0530, 1900 + nColA4, &(cTabela+"->"+cTabela+"_REGGER"), oFont05)

	oPrint:Box(0600, 0030, 0690, 1100)
	oPrint:Say(0600, 0040, STR0011, oFont04) //"Cartao Nacional de Saúde (CNS)"
	oPrint:Say(0630, 0050, GBH->GBH_NUMCNS, oFont05)    
	
	oPrint:Box(0600, 1110, 0690, 1400)
	oPrint:Say(0600, 1120, STR0012, oFont04) //"Data Nascimento"
	oPrint:Say(0630, 1130, DtoC(GBH->GBH_DTNASC), oFont05)    

	oPrint:Box(0600, 1410, 0690, 1800)
	oPrint:Say(0600, 1450, STR0013, oFont04) //"SEXO"
	oPrint:Say(0600, 1585, STR0014, oFont04) //"Masc."
	oPrint:Say(0600, 1725, STR0015, oFont04) //"Fem."

	oPrint:Box(0630, 1540, 0680, 1660)
	oPrint:Line(0630,1600, 0680, 1600)
	oPrint:Say(0650, 1630, "1", oFont04) //"1" - Masculino

	oPrint:Box(0630, 1670, 0680, 1790)
	oPrint:Line(0630, 1730, 0680, 1730)
	oPrint:Say(0650, 1765, "3", oFont04) //"2" - Feminino

	If GBH->GBH_SEXO == "0"
		oPrint:Say(0650, 1560, "X", oFont05) //Masculino
	Else
		oPrint:Say(0650, 1690, "X", oFont05) //Feminino
	EndIf
   
	oPrint:Box(0600, 1810, 0690, 2310)
	oPrint:Say(0600, 1820, STR0016, oFont04) //"Raca/Cor"
	Do Case
	  Case GBH->GBH_CORPEL == "01"
	  	oPrint:Say(0630, 1830, "Branca", oFont05)
	  Case GBH->GBH_CORPEL == "02"
	   	oPrint:Say(0630, 1830, "Preta", oFont05) //"Negra"
	  Case GBH->GBH_CORPEL == "03"
	    oPrint:Say(0630, 1830, "Parda", oFont05) //"Morena"
	  Case GBH->GBH_CORPEL == "04"
	    oPrint:Say(0630, 1830, "Amarela", oFont05) //"Parda"       
	  Case GBH->GBH_CORPEL == "05"
	   	 oPrint:Say(0630, 1830, "Indigena", oFont05) //"Parda" 
	  Case Empty(GBH->GBH_CORPEL)
	   	oPrint:Say(0630, 1830, "Sem Informação", oFont05) //"Parda"
	 EndCase
	 
	oPrint:Box(0700, 0030, 0790, 1700)
	oPrint:Say(0700, 0040, STR0017, oFont04) //"Nome da Mãe"
	oPrint:Say(0730, 0050, GBH->GBH_NOMMAE, oFont05)

	oPrint:Box(0700, 1710, 0790, 2310)
	oPrint:Say(0700, 1740, STR0018, oFont04) //"DDD"
	oPrint:Say(0730, 1740, "0  " + SubStr(GBH->GBH_TEL,1,1) + "  " + SubStr(GBH->GBH_TEL,2,1), oFont05)
	oPrint:Box(0700, 1920, 0790, 2310)
	oPrint:Say(0700, 1950, STR0019, oFont04) //"Telefone de Contato"
	oPrint:Say(0730, 1950, SubStr(GBH->GBH_TEL,3,1) + "  " + SubStr(GBH->GBH_TEL,4,1) + "  " + SubStr(GBH->GBH_TEL,5,1) + "  " +;
							SubStr(GBH->GBH_TEL,6,1) + "  " + SubStr(GBH->GBH_TEL,7,1) + "  " + SubStr(GBH->GBH_TEL,8,1) + "  " +;
							SubStr(GBH->GBH_TEL,9,1) + "  " + SubStr(GBH->GBH_TEL,10,1), oFont05)
							             
	DbSelectArea("GFD")
	DbSetOrder(3)
	DbSeek(xFilial("GFD") + &(cTabela+"->"+cTabela+"_REGGER"))
								
 	oPrint:Box(0800, 0030, 0890, 1700)
	oPrint:Say(0800, 0040, STR0020, oFont04) //"Nome do Responsável"  
	If !Empty(GFD->GFD_NOME)
		oPrint:Say(0830, 0050, GFD->GFD_NOME, oFont05) 
	Else
		oPrint:Say(0830, 0050, GBH->GBH_NOME, oFont05 )
	EndIf	
	  
	oPrint:Box(0800, 1710, 0890, 2310)
	oPrint:Say(0800, 1740, STR0018, oFont04) //"DDD"
	oPrint:Say(0830, 1740, "0  " + SubStr(GFD->GFD_TEL,2,1) + "  " + SubStr(GFD->GFD_TEL,3,1), oFont05)
	oPrint:Box(0800, 1920, 0890, 2310)
	oPrint:Say(0800, 1950, STR0019, oFont04) //"Telefone de Contato"
	oPrint:Say(0830, 1950, SubStr(GFD->GFD_TEL,5,1) + "  " + SubStr(GFD->GFD_TEL,6,1) + "  " + SubStr(GFD->GFD_TEL,7,1) + "  " +;
							SubStr(GFD->GFD_TEL,8,1) + "  " + SubStr(GFD->GFD_TEL,10,1) + "  " + SubStr(GFD->GFD_TEL,11,1) + "  " +;
							SubStr(GFD->GFD_TEL,12,1) + "  " + SubStr(GFD->GFD_TEL,13,1), oFont05)
	
	
	oPrint:Box(0900, 0030, 0990, 2310)
	oPrint:Say(0900, 0040, STR0021, oFont04) //"Endereço (Logradouro, nº, complemento, bairro)"
	oPrint:Say(0930, 0050, AllTrim(GBH->GBH_END) + ", " + AllTrim(GBH->GBH_NUM)+ Iif(!Empty(SubStr(AllTrim(GBH->GBH_COMPLE),1,20)),+ " - " + SubStr(AllTrim(GBH->GBH_COMPLE),1,20),"") + ", " + SubStr(AllTrim(GBH->GBH_BAIRRO),1,30), oFont05)
	
	oPrint:Box(1000, 0030, 1090, 1500)
	oPrint:Say(1000, 0040, STR0022, oFont04) //"Município de Residencia"
	oPrint:Say(1030, 0050, GBH->GBH_MUN, oFont05)
     
 	oPrint:Box(1000, 1510, 1090, 1850)
	oPrint:Say(1000, 1520, STR0023, oFont04) //"Cod. IBGE Município"
	oPrint:Say(1030, 1530, Posicione("GAM",3,xFilial("GAM")+GBH->GBH_CEP,"GAM->GAM_CODIGO"), oFont05)
	
	oPrint:Box(1000, 1860, 1090, 1960)
	oPrint:Say(1000, 1870, STR0024, oFont04) //"UF"
	oPrint:Say(1030, 1880, GBH->GBH_EST, oFont05)

	oPrint:Box(1000, 1970, 1090, 2310)
	oPrint:Say(1000, 1980, STR0025, oFont04) //"CEP"
	oPrint:Say(1030, 1990, SubStr(GBH->GBH_CEP,1,1) + "  " + SubStr(GBH->GBH_CEP,2,1) + "  " + SubStr(GBH->GBH_CEP,3,1) + "  " +;
							SubStr(GBH->GBH_CEP,4,1) + "  " + SubStr(GBH->GBH_CEP,5,1) + "  -  " + SubStr(GBH->GBH_CEP,6,1)+ "  " +;
							SubStr(GBH->GBH_CEP,7,1) + "  " + SubStr(GBH->GBH_CEP,8,1), oFont05)

    //Bloco III - Justificativa 
    oPrint:Box(1120, 0020, 2100, 2320)   
	oPrint:Say(1130, 0030, STR0026, oFont04) //"Justificativa da Internação"
	
	oPrint:Box(1160, 0030, 1560, 2310)
	oPrint:Say(1170, 0040, STR0027, oFont04) //"Principais Sinais e Sintomas Clinicos"
	
	oPrint:Box(1570, 0030, 1770, 2310)
	oPrint:Say(1580, 0040, STR0028, oFont04) //"Condicões que Justificam a Internação"

	oPrint:Box(1780, 0030, 1980, 2310)
	oPrint:Say(1790, 0040, STR0029, oFont04) //"Principais Resultados de Provas Diagnosticas(Resultados de Exames Realizados)"
		
	oPrint:Box(1990, 0030, 2080, 1250)
	oPrint:Say(2000, 0040, STR0030, oFont04) //"Diagnóstico Inicial"
	oPrint:Say(2040, 0050, Posicione('GAS', 1, xFilial('GAS') + GCY->GCY_CIDINT, 'GAS_PATOLO'), oFont04)
	
	oPrint:Box(1990, 1260, 2080, 1600)
	oPrint:Say(2000, 1270, STR0031, oFont04) //"CID 10 Principal"
	oPrint:Say(2040, 1280, Alltrim(GCY->GCY_CIDINT) , oFont04) //"CID 10 Principal"	

	oPrint:Box(1990, 1610, 2080, 1950)
	oPrint:Say(2000, 1620, STR0032, oFont04) //"CID 10 Secundario"
	oPrint:Say(2040, 1630, Alltrim(GCY->GCY_CIDCMP), oFont04) //"CID 10 Secundario"	

	oPrint:Box(1990, 1960, 2080, 2310)
	oPrint:Say(2000, 1970, STR0033, oFont04) //"CID 10 Causas Associadas"
    
	//Bloco IV - Procedimento Solicitado 
    oPrint:Box(2110, 0020, 2450, 2320)   
	oPrint:Say(2120, 0030, STR0034, oFont04) //"Procedimento Solicitado"
     
	DbSelectArea("GCZ")
	DbSetOrder(2)
	GCZ->(DbSeek(xFilial("GCZ")+ &(cTabela+"->"+cTabela+"_REGATE")))
	
	oPrint:Box(2150, 0030, 2240, 1600)
	oPrint:Say(2160, 0040, STR0035, oFont04) //"Nome do Procedimento" 
	oPrint:Say(2190, 0050, Posicione('GA7', 1, xFilial('GA7') + GCZ->GCZ_CODDES, 'GA7_DESC'), oFont05)
	
	oPrint:Box(2150, 1610, 2240, 2310) 
	oPrint:Say(2160, 1620, STR0036, oFont04) //"Código do Procedimento"
	oPrint:Say(2190, 1630, GCZ->GCZ_CODPRT, oFont05)   
	
	oPrint:Box(2250, 0030, 2340, 0400)
	oPrint:Say(2260, 0040, STR0037, oFont04) //"Clinica" 
    oPrint:Say(2290, 0050, Posicione("GCW",1,xFilial("GCW")+&(cTabela+"->"+cTabela+"_CODCLI"),"GCW_DESCLI"), oFont06n)
	
	oPrint:Box(2250, 0410, 2340, 0890) 
	oPrint:Say(2260, 0420, STR0038, oFont04) //"Carater da Internação"
	oPrint:Say(2290, 0430, Posicione("GD1",1,xFilial("GD1")+&(cTabela+"->"+cTabela+"_CARATE"),"GD1_DCARAT"), oFont06n)
	    
	oPrint:Box(2250, 0900, 2340, 1210) 
	oPrint:Say(2260, 0910, STR0039, oFont04) //"Documento"
	DbSelectArea("GBJ")
	DbSetOrder(1) //GBJ_FILIAL+GBJ_CRM
	If DbSeek(xFilial("GBJ") + GCZ->GCZ_CODCRM) 
		If !Empty(GBJ->GBJ_CODCNS)
			cNumDoc := GBJ->GBJ_CODCNS
			oPrint:Say(2300, 0920, "( X ) CNS ", oFont04)
			oPrint:Say(2300, 1060, "(   ) CPF ", oFont04)         
		ElseIf !Empty(GBJ->GBJ_CIC)
			cNumDoc := GBJ->GBJ_CIC
			oPrint:Say(2300, 0920, "(   ) CNS ", oFont04)
			oPrint:Say(2300, 1060, "( X ) CPF ", oFont04)         
		Else
			oPrint:Say(2300, 0920, "(   ) CNS ", oFont04)
			oPrint:Say(2300, 1060, "(   ) CPF ", oFont04)         			
		Endif
	Else

		oPrint:Say(2300, 0920, "(   ) CNS ", oFont04)
		oPrint:Say(2300, 1060, "(   ) CPF ", oFont04)         	
	EndIf
    
	oPrint:Box(2250, 1220, 2340, 2310) 
	oPrint:Say(2260, 1230, STR0040, oFont04) //"N° Documento (CNS/CPF) do Profissional Solicitante/Assistente"
	oPrint:Say(2300, 1240, cNumDoc, oFont04)
	
	oPrint:Box(2350, 0030, 2440, 1300) 
	oPrint:Say(2360, 0040, STR0041, oFont04) //"Nome do Profissional Solicitante/Assistente"
	oPrint:Say(2400, 0050, HS_INIPADR('SRA',11,GCZ->GCZ_CODCRM,'RA_NOME'), oFont04) //"Nome do Profissional Solicitante/Assistente"	
	
	oPrint:Box(2350, 1310, 2440, 1650) 
	oPrint:Say(2360, 1320, STR0042, oFont04) //"Data da Solicitaçao"
	oPrint:Say(2400, 1350, IIf(Empty(GCZ->GCZ_DATSOL),"_____/_____/________",HS_DToC(GCZ->GCZ_DATSOL)), oFont04)
	
	oPrint:Box(2350, 1660, 2440, 2310) 
	oPrint:Say(2360, 1670, STR0043, oFont04) //"Assinatura e Carimbo (N° do Registro do Conselho)"
	
	//Bloco V - Preencher em caso de Causas Externas (Acidentes ou Violências)                                                                                                            
	oPrint:Box(2470, 0020, 2810, 2320) 
	oPrint:Say(2480, 0030, STR0044, oFont04) //Preencher em caso de Causas Externas (Acidentes ou Violências)
	
	oPrint:Box(2510, 0030, 2700, 0700) 
	oPrint:Say(2530, 0040, "(    ) Acidente de Trânsito ", oFont04)   // (    ) Acidente de Trânsito
   	oPrint:Say(2580, 0040, "(    ) Acidente Trabalho Típico ", oFont04)  // (    ) Acidente Trabalho Típico
	oPrint:Say(2630, 0040, "(    ) Acidente Trabalho Trajeto ", oFont04)  //(    ) Acidente Trabalho Trajeto
	
	oPrint:Box(2510, 0710, 2600, 1600) 
	oPrint:Say(2520, 0720, STR0045, oFont04) // CNPJ da Seguradora
	
	oPrint:Box(2510, 1610, 2600, 1960) 
	oPrint:Say(2520, 1620, STR0046, oFont04)    //  Nº° do Bilhete
	
	oPrint:Box(2510, 1970, 2600, 2310) 
	oPrint:Say(2520, 1980, STR0047, oFont04)  // Série    
	
	oPrint:Box(2610, 0710, 2700, 1600) 
	oPrint:Say(2620, 0720, STR0048, oFont04)  //CNPJ Empresa
	 
	oPrint:Box(2610, 1610, 2700, 1960) 
	oPrint:Say(2620, 1620, STR0049, oFont04)  //CNAE da Empresa    
	
	oPrint:Box(2610, 1970, 2700, 2310) 
	oPrint:Say(2620, 1980, STR0050, oFont04) //CBOR
	
	oPrint:Box(2710, 0030, 2800, 2310)                             
	oPrint:Say(2720, 0040, STR0051, oFont04) //Vínculo com a Previdência
	oPrint:Say(2750, 0050, "(    ) Empregado ", oFont04) // 
	oPrint:Say(2750, 0420, "(    ) Empregador ", oFont04) // 
	oPrint:Say(2750, 0790, "(    ) Autônomo ", oFont04) // 
	oPrint:Say(2750, 1160, "(    ) Desempregado ", oFont04) // 
	oPrint:Say(2750, 1530, "(    ) Aposentado ", oFont04) // 
	oPrint:Say(2750, 1900, "(    ) Não Segurado ", oFont04) // 
   	
   	//Bloco VI - Autorização                                                               
   	oPrint:Box(2830, 0020, 3190, 2320)                             
	oPrint:Say(2840, 0030, STR0084, oFont04) //"Autorização "
	
	oPrint:Box(2870, 0030, 2960, 1300)                             
	oPrint:Say(2880, 0040, STR0053, oFont04) //"Nome do Profissional Autorizador "
	
	oPrint:Box(2870, 1310, 2960, 1650) 
	oPrint:Say(2880, 1320, STR0054, oFont04) //"Cod. Orgão Emissor"
	
	oPrint:Box(2870, 1660, 3180, 2310) 
	oPrint:Say(2880, 1670, STR0055, oFont04) //"N° da Autorização de Internacão Hospitalar"
	
	oPrint:Box(2970, 0030, 3060, 0380) 
	oPrint:Say(2980, 0040, STR0039, oFont04) //"Documento"
	oPrint:Say(3010, 0050, "(    ) CNS ", oFont04)
	oPrint:Say(3010, 0210, "(    ) CPF ", oFont04)
	
	oPrint:Box(2970, 0390, 3060, 1650) 
	oPrint:Say(2980, 0400, STR0056, oFont04) //"N° Documento (CNS/CPF) do Profissional Autorizador"
	
	oPrint:Box(3080, 0030, 3180, 0380) 
	oPrint:Say(3090, 0040, STR0090, oFont04) //"Data da Autorizaçao"
	oPrint:Say(3150, 0050, "____/____/______", oFont04)
		
	oPrint:Box(3080, 0390, 3180, 1650) 
	oPrint:Say(3090, 0400, STR0057, oFont04) //"Assinatura e Carimbo (N° do Registro do Conselho)"
	
	oPrint:EndPage()	// Finaliza a pagina
	oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPR9302  ºAutor  ³Sueli C. Santos     º Data ³  10/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte criado para emitir o relatorio de Laudo medico SUS    º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HSPR9302(cTabela)
Local nLinMax	:= 0
Local nColMax	:= 0
Local nLinIni	:= 0	// Linha Lateral (inicial) Esquerda
Local nColIni	:= 0	// Coluna Lateral (inicial) Esquerda
Local nColA4    := 0
Local nLinA4    := 0
Local cFileLogo
Local lPrinter     
Local nT		:= 0
Local nT1		:= 0
Local nT3		:= 0
Local n			:= 0
Local nO		:= 0
Local oFont02
Local oFont02n
Local oFont03n
Local oFont04
Local oFont05
Local cDesConv	:= ""
Local cCPFMed	:= ""
Local cNomMed	:= ""
Local aProc		:= {}
Local cCid10	:= ""
Local cDiaIn	:= ""
Local cObs		:= ""
Local nLinObs	:= 0
Local nObs		:= 0
Local aObs		:= {}
Local nLin		:= 0
Local lImprimiu	:= .F.
Local cCnesHosp := SuperGetMV("MV_HSPCNES")	// parametro do codigo CNES do Hospital

	// Papél A4
	nLinMax	:=	3200   
	nColMax	:=	2330   
		
	// Papél A4
	oFont02		:= TFont():New("Arial", 11, 11, , .F., , , , .T., .F.) // Normal
	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont04n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont05		:= TFont():New("Arial", 09, 09, , .T., , , , .T., .F.) // Negrito
	oFont06n	:= TFont():New("Arial", 07, 07, , .T., , , , .T., .F.) // Negrito
		
	oPrint	:= TMSPrinter():New(STR0058) //"LAUDO PARA SOLICITAÇÃO/AUTORIZAÇÃO DE MUDANCA DE PROCEDIMENTO E DE PROCEDIMENTO(S)ESPECIAL(AIS)"
		
	oPrint:SetPortrait()	// Modo retrato
		
	oPrint:SetPaperSize(9)// Papél A4
		
	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()
	
		
	DbSelectArea(cTabela)

	nLinIni := 0
	nColIni := 0
	nColA4  := 0
	nLinA4  := 0
		
	oPrint:StartPage()		// Inicia uma nova pagina
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Box Principal                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Box( 0010, 0010, nLinMax, nColMax)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega e Imprime Logotipo da Empresa                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FS_LogoEmp(@cFileLogo)
	
	oPrint:Box(0050, 0020, 0200, 0600)
	If File(cFilelogo)
		oPrint:SayBitmap(0090, 0040, cFileLogo, 0400, 0100)		// Tem que estar abaixo do RootPath
	EndIf 
	
	// Papél A4
	nColA4    := -0065
	
	oPrint:Box(0050, 0610, 0200, 2100)
	oPrint:Say(0090, 1385 + nColA4, STR0059, oFont03n,,,, 2) //"LAUDO PARA SOLICITAÇÃO/AUTORIZAÇÃO DE MUDANCA DE "
	oPrint:Say(0140, 1385 + nColA4, STR0060, oFont03n,,,, 2) //"PROCEDIMENTO E DE PROCEDIMENTO(S)ESPECIAL(AIS)"
    
	oPrint:Box(0050, 2110, 0200, 2320)
	oPrint:Say(0090, 2270 + nColA4, STR0061, oFont03n,,,, 2)//"FOLHA"
	oPrint:Say(0140, 2270 + nColA4, "1/2", oFont03n,,,, 2)	
	
	/*DbSelectArea("GK7")
	DbSetOrder(3)
	If DbSeek(xFilial("GK7") + &(cTabela+"->"+cTabela+"_REGATE"))
		MsBar3( 'CODE128', 0.7 , 15.5, Alltrim(GK7->GK7_SOLICI), oPrint, .F., , .T., 0.015, 0.6, .F., 'TAHOMA', 'B', .F. )
	EndIf	*/
	// Bloco I - Identificacao do Estabelecimento    

	oPrint:Box(0210, 0020, 0450, 2320)
	oPrint:Say(0220, 0030, STR0004, oFont04) //"Identificação do Estabelecimento de Saude"
   
	oPrint:Box(0250, 0030, 0340, 1800)
	oPrint:Say(0250, 0040, STR0005, oFont04) //"Nome do Estabelecimento Solicitante"
	oPrint:Say(0280, 0040, SM0->M0_NOMECOM, oFont05)

	oPrint:Box(0250, 1810, 0340, 2310)
	oPrint:Say(0250, 1890 + nColA4, STR0006, oFont04) //"CNES"
	oPrint:Say(0280, 1900 + nColA4, cCnesHosp, oFont05)
	
	oPrint:Box(0350, 0030, 0440, 1800)
	oPrint:Say(0350, 0040, STR0007, oFont04) //"Nome do Estabelecimento Executante"
	oPrint:Say(0380, 0040, SM0->M0_NOMECOM, oFont05)
	
	oPrint:Box(0350, 1810, 0440, 2310)
	oPrint:Say(0350, 1890 + nColA4, STR0006, oFont04) //"CNES"
	oPrint:Say(0380, 1900 + nColA4, cCnesHosp, oFont05)

   
	//Bloco II - Identificacao do Paciente
	oPrint:Box(0460, 0020, 1100, 2320)   
	oPrint:Say(0470, 0030, STR0008, oFont04) //"Identificacao do Paciente"

	If &(cTabela+"->"+cTabela+"_TPALTA") == "99"
		HS_MSGINF(STR0093,STR0091,STR0092) //"Paciente cancelado!","Atenção","Validação Laudo SUS"		
		Return()                                                        
	ElseIf HS_COUNTTB("GD4","GD4_REGGER ='" + &(cTabela+"->"+cTabela+"_REGGER") + "' AND GD4_CODCON = '" + GetMV("MV_PCONSUS",,"") +  "'") == 0
		HS_MSGINF(STR0094,,STR0091,STR0092) //"Paciente não possui convênio SUS!","Atenção","Validação Laudo SUS"		
		Return()                                                        	
	EndIf  
	
	DbSelectArea("GBH")
	DbSetOrder(1)
	DbSeek(xFilial("GBH") + &(cTabela+"->"+cTabela+"_REGGER"))
	
	oPrint:Box(0500, 0030, 0590, 1800)
	oPrint:Say(0500, 0040, STR0009, oFont04) //"Nome do Paciente"
   	oPrint:Say(0530, 0050, GBH->GBH_NOME, oFont05)

	oPrint:Box(0500, 1810, 0590, 2310)
	oPrint:Say(0500, 1890 + nColA4, STR0010, oFont04) //"Nº do Prontuário"
	oPrint:Say(0530, 1900 + nColA4, &(cTabela+"->"+cTabela+"_REGGER"), oFont05)

	oPrint:Box(0600, 0030, 0690, 1100)
	oPrint:Say(0600, 0040, STR0011, oFont04) //"Cartao Nacional de Saúde (CNS)"
	oPrint:Say(0630, 0050, GBH->GBH_NUMCNS, oFont05)    
	
	oPrint:Box(0600, 1110, 0690, 1400)
	oPrint:Say(0600, 1120, STR0012, oFont04) //"Data Nascimento"
	oPrint:Say(0630, 1130, DtoC(GBH->GBH_DTNASC), oFont05)    

	oPrint:Box(0600, 1410, 0690, 1800)
	oPrint:Say(0600, 1450, STR0013, oFont04) //"SEXO"
	oPrint:Say(0600, 1585, STR0014, oFont04) //"Masc."
	oPrint:Say(0600, 1725, STR0015, oFont04) //"Fem."

	oPrint:Box(0630, 1540, 0680, 1660)
	oPrint:Line(0630,1600, 0680, 1600)
	oPrint:Say(0650, 1630, "1", oFont04) //"1" - Masculino

	oPrint:Box(0630, 1670, 0680, 1790)
	oPrint:Line(0630, 1730, 0680, 1730)
	oPrint:Say(0650, 1765, "3", oFont04) //"2" - Feminino

	If GBH->GBH_SEXO == "0"
		oPrint:Say(0650, 1560, "X", oFont05) //Masculino
	Else
		oPrint:Say(0650, 1690, "X", oFont05) //Feminino
	EndIf
   
	oPrint:Box(0600, 1810, 0690, 2310)
	oPrint:Say(0600, 1820, STR0016, oFont04) //"Raca/Cor"
	Do Case
	  Case GBH->GBH_CORPEL == "01"
	  	oPrint:Say(0630, 1830, "Branca", oFont05)
	  Case GBH->GBH_CORPEL == "02"
	   	oPrint:Say(0630, 1830, "Preta", oFont05) //"Negra"
	  Case GBH->GBH_CORPEL == "03"
	    oPrint:Say(0630, 1830, "Parda", oFont05) //"Morena"
	  Case GBH->GBH_CORPEL == "04"
	    oPrint:Say(0630, 1830, "Amarela", oFont05) //"Parda"       
	  Case GBH->GBH_CORPEL == "05"
	   	 oPrint:Say(0630, 1830, "Indigena", oFont05) //"Parda" 
	  Case Empty(GBH->GBH_CORPEL)
	   	oPrint:Say(0630, 1830, "Sem Informação", oFont05) //"Parda"
	 EndCase
	 
	oPrint:Box(0700, 0030, 0790, 1700)
	oPrint:Say(0700, 0040, STR0017, oFont04) //"Nome da Mãe"
	oPrint:Say(0730, 0050, GBH->GBH_NOMMAE, oFont05)

	oPrint:Box(0700, 1710, 0790, 2310)
	oPrint:Say(0700, 1740, STR0018, oFont04) //"DDD"
	oPrint:Say(0730, 1740, "0  " + SubStr(GBH->GBH_TEL,1,1) + "  " + SubStr(GBH->GBH_TEL,2,1), oFont05)
	oPrint:Box(0700, 1920, 0790, 2310)
	oPrint:Say(0700, 1950, STR0019, oFont04) //"Telefone de Contato"
	oPrint:Say(0730, 1950, SubStr(GBH->GBH_TEL,3,1) + "  " + SubStr(GBH->GBH_TEL,4,1) + "  " + SubStr(GBH->GBH_TEL,5,1) + "  " +;
							SubStr(GBH->GBH_TEL,6,1) + "  " + SubStr(GBH->GBH_TEL,7,1) + "  " + SubStr(GBH->GBH_TEL,8,1) + "  " +;
							SubStr(GBH->GBH_TEL,9,1) + "  " + SubStr(GBH->GBH_TEL,10,1), oFont05)
							             
	DbSelectArea("GFD")
	DbSetOrder(3)
	DbSeek(xFilial("GFD") + &(cTabela+"->"+cTabela+"_REGGER"))
								
 	oPrint:Box(0800, 0030, 0890, 1700)
	oPrint:Say(0800, 0040, "Nome do Responsável", oFont04) //"Nome do Responsável"  
	If !Empty(GFD->GFD_NOME)
		oPrint:Say(0830, 0050, GFD->GFD_NOME, oFont05) 
	Else
		oPrint:Say(0830, 0050, GBH->GBH_NOME, oFont05 )
	EndIf	
	  
	oPrint:Box(0800, 1710, 0890, 2310)
	oPrint:Say(0800, 1740, STR0018, oFont04) //"DDD"
	oPrint:Say(0830, 1740, "0  " + SubStr(GFD->GFD_TEL,2,1) + "  " + SubStr(GFD->GFD_TEL,3,1), oFont05)
	oPrint:Box(0800, 1920, 0890, 2310)
	oPrint:Say(0800, 1950, STR0019, oFont04) //"Telefone de Contato""
	oPrint:Say(0830, 1950, SubStr(GFD->GFD_TEL,5,1) + "  " + SubStr(GFD->GFD_TEL,6,1) + "  " + SubStr(GFD->GFD_TEL,7,1) + "  " +;
							SubStr(GFD->GFD_TEL,8,1) + "  " + SubStr(GFD->GFD_TEL,9,1) + "  " + SubStr(GFD->GFD_TEL,10,1) + "  " +;
							SubStr(GFD->GFD_TEL,11,1) + "  " + SubStr(GFD->GFD_TEL,12,1), oFont05)
	
	
	oPrint:Box(0900, 0030, 0990, 2310)
	oPrint:Say(0900, 0040, STR0021, oFont04) //"Endereço (Rua, nº, bairro)"
	oPrint:Say(0930, 0050, AllTrim(GBH->GBH_END) + ", " + AllTrim(GBH->GBH_NUM)+ Iif(!Empty(SubStr(AllTrim(GBH->GBH_COMPLE),1,20)),+ " - " + SubStr(AllTrim(GBH->GBH_COMPLE),1,20),"") + ", " + SubStr(AllTrim(GBH->GBH_BAIRRO),1,30), oFont05)
	
	oPrint:Box(1000, 0030, 1090, 1500)
	oPrint:Say(1000, 0040, STR0022, oFont04) //"Município de Residencia"
	oPrint:Say(1030, 0050, GBH->GBH_MUN, oFont05)
     
 	oPrint:Box(1000, 1510, 1090, 1850)
	oPrint:Say(1000, 1520, STR0023, oFont04) //"Cod. IBGE Município"
	oPrint:Say(1030, 1530, Posicione("GAM",3,xFilial("GAM")+GBH->GBH_CEP,"GAM->GAM_CODIGO"), oFont05)
	
	oPrint:Box(1000, 1860, 1090, 1960)
	oPrint:Say(1000, 1870, STR0024, oFont04) //"UF"
	oPrint:Say(1030, 1880, GBH->GBH_EST, oFont05)

	oPrint:Box(1000, 1970, 1090, 2310)
	oPrint:Say(1000, 1980, STR0025, oFont04) //"CEP"
	oPrint:Say(1030, 1990, SubStr(GBH->GBH_CEP,1,1) + "  " + SubStr(GBH->GBH_CEP,2,1) + "  " + SubStr(GBH->GBH_CEP,3,1) + "  " +;
							SubStr(GBH->GBH_CEP,4,1) + "  " + SubStr(GBH->GBH_CEP,5,1) + "  -  " + SubStr(GBH->GBH_CEP,6,1)+ "  " +;
							SubStr(GBH->GBH_CEP,7,1) + "  " + SubStr(GBH->GBH_CEP,8,1), oFont05)

	//Bloco III - Numero da Autorizacao de Internacao Hospitalar (AIH)
    oPrint:Box(1110, 0020, 1200, 2320)   
	oPrint:Say(1120, 0030, STR0062, oFont05) //Numero da Autorizacao de Internacao Hospitalar (AIH)
	
    //Bloco IV - Mudança de Procedimento 
    oPrint:Box(1210, 0020, 1570, 2320)   
    oPrint:Say(1220, 0030, STR0063, oFont05) //"MUDANÇA DE PROCEDIMENTO"
	
	oPrint:Box(1270, 0030, 1360, 1600)
	oPrint:Say(1280, 0040, STR0064, oFont04) //"Nome do Procedimento Solicitado - Anterior"    
  //	oPrint:Say(1310, 0050, Posicione('GA7', 1, xFilial('GA7') + GCZ->GCZ_CODDES, 'GA7_DESC'), oFont05)
	
	oPrint:Box(1270, 1610, 1360, 2310) 
	oPrint:Say(1280, 1620, STR0065, oFont04) //"Código do Procedimento - Anterior"
//	oPrint:Say(1310, 1630, GCZ->GCZ_CODDES, oFont05)   
	
	oPrint:Box(1370, 0030, 1460, 1600)
	oPrint:Say(1380, 0040, STR0066, oFont04) //"Nome do Procedimento Solicitado - Mudança"    
		
	oPrint:Box(1370, 1610, 1460, 2310) 
	oPrint:Say(1380, 1620, STR0067, oFont04) //"Código do Procedimento - Mudança"
	
	oPrint:Box(1470, 0030, 1560, 1250)
	oPrint:Say(1480, 0040, STR0030, oFont04) //"Diagnóstico Inicial"
	oPrint:Say(1520, 0050, Posicione('GAS', 1, xFilial('GAS') + GCY->GCY_CIDINT, 'GAS_PATOLO'), oFont04)	
	
	oPrint:Box(1470, 1260, 1560, 1600)
	oPrint:Say(1480, 1270, STR0031, oFont04) //"CID 10 Principal"
	oPrint:Say(1520, 1280, Alltrim(GCY->GCY_CIDINT) , oFont04) //"CID 10 Principal"		

	oPrint:Box(1470, 1610, 1560, 1950)
	oPrint:Say(1480, 1620, STR0032, oFont04) //"CID 10 Secundario"
	oPrint:Say(1520, 1630, Alltrim(GCY->GCY_CIDCMP), oFont04) //"CID 10 Secundario"		

	oPrint:Box(1470, 1960, 1560, 2310)
	oPrint:Say(1480, 1970, STR0033, oFont04) //"CID 10 Causas Associadas"
	
   //Bloco V  
	oPrint:Box(1580, 0020, 2160, 2320)
	oPrint:Say(1590, 0030, STR0068, oFont05) //"SOLICITAÇÃO DE PROCEDIMENTO(S) ESPECIAL(AIS)"
	
	oPrint:Box(1640, 0030, 1730, 1600)
	oPrint:Say(1650, 0040, STR0069, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1640, 1610, 1730, 2310) 
	oPrint:Say(1650, 1620, STR0070, oFont04) //"Código do Procedimento Principal"
	
	oPrint:Line(1740,0020,1740,2320)
	
	oPrint:Box(1750, 0030, 1840, 2310)                                       
	oPrint:Say(1760, 0040, STR0071,oFont04) //"Solicitação de Diarias de UTI e/ou Diaria de Acompanhante"
	
	oPrint:Box(1790, 0070, 1830, 0110)                                       
	oPrint:Say(1790, 0140, STR0072, oFont04) // "Diaria de Acompanhante "
	
	oPrint:Box(1790, 0670, 1830,0710 )
	oPrint:Say(1790, 0740, STR0073, oFont04) // "Diaria de UTI Tipo I "
	
	oPrint:Box(1790, 1160, 1830, 1200)
	oPrint:Say(1790, 1230, STR0074, oFont04) //  "Diaria de UTI Tipo II "
	
	oPrint:Box(1790, 1600, 1830, 1640)
	oPrint:Say(1790, 1670, STR0075, oFont04) // "Diaria de UTI Tipo III "
	
	oPrint:Line(1850,0020,1850,2320)
	
	oPrint:Box(1860, 0030, 1950, 1450)
	oPrint:Say(1870, 0040, STR0076, oFont04) //"Descrição do Procedimento Especial"
	
	oPrint:Box(1860, 1460, 1950, 2160) 
	oPrint:Say(1870, 1470, STR0077, oFont04) //"Código do Procedimento Especial"

	oPrint:Box(1860, 2170, 1950, 2310) 
	oPrint:Say(1870, 2180, STR0078, oFont04) //"Qtde"
    
	oPrint:Box(1960, 0030, 2050, 1450)
	oPrint:Say(1970, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1960, 1460, 2050, 2160) 
	oPrint:Say(1970, 1470, STR0077, oFont04) //"Código do Procedimento Especial"

	oPrint:Box(1960, 2170, 2050, 2310) 
	oPrint:Say(1970, 2180, STR0078, oFont04) //"Qtde"
	
	oPrint:Box(2060, 0030, 2150, 1450)
	oPrint:Say(2070, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(2060, 1460, 2150, 2160) 
	oPrint:Say(2070, 1470, STR0077, oFont04) //"Código do Procedimento Especial"

	oPrint:Box(2060, 2170, 2150, 2310) 
	oPrint:Say(2070, 2180, STR0078, oFont04) //"Qtde"  
	 
	//BLOCO VI
	oPrint:Box(2170, 0020, 2530, 2320) 
	oPrint:Say(2180, 0030, STR0079, oFont05) //"JUSTIFICATIVA DA SOLICITAÇÃO" 
	 
	oPrint:Box(2540, 0020, 2860, 2320) 
	oPrint:Say(2550, 0030, STR0080, oFont05) //"PROFISSIONAL SOLICITANTE"
	
	oPrint:Box(2590, 0030, 2700, 1800) 
	oPrint:Say(2600, 0040, STR0081, oFont04) //"Nome do Profissional Solicitante"
	 
	oPrint:Box(2590, 1810, 2700, 2310) 
	oPrint:Say(2590, 1820, STR0090, oFont04) //"Data da Solicitaçao"
	oPrint:Say(2660, 1860, "_____/_____/________", oFont04)      
	
	oPrint:Box(2710, 0030, 2850, 0500) 
	oPrint:Say(2720, 0040, STR0039, oFont04) //"Documento"
	oPrint:Say(2760, 0050, "(    ) CNS ", oFont04)
	oPrint:Say(2760, 0300, "(    ) CPF ", oFont04)
    
	oPrint:Box(2710, 0510, 2850, 1200) 
	oPrint:Say(2720, 0520, STR0082, oFont04) //"N° Documento (CNS/CPF) do Profissional Solicitante"
	
	oPrint:Box(2710, 1210, 2850, 2310) 
	oPrint:Say(2720, 1220, STR0083, oFont04) //"Assinatura e Carimbo (N° do Registro do Conselho)"
	
	//Bloco VIII
	oPrint:Box(2870, 0020, 3190, 2320) 
	oPrint:Say(2880, 0030, STR0084, oFont05) //"AUTORIZAÇÃO" 
	
	oPrint:Box(2920, 0030, 3030, 1500) 
	oPrint:Say(2930, 0040, STR0085, oFont04) //"Nome do Profissional Autorizador"
	 
	oPrint:Box(2920, 1510, 3030, 1800) 
	oPrint:Say(2930, 1520, STR0054, oFont04) //"Data da Solicitaçao"
	
	oPrint:Box(2920, 1810, 3030, 2310) 
	oPrint:Say(2930, 1820, STR0090, oFont04) //"Data da Autorização"
	oPrint:Say(2990, 1850, "_____/_____/________", oFont04)      
	
	oPrint:Box(3040, 0030, 3180, 0500) 
	oPrint:Say(3050, 0040, STR0039, oFont04) //"Documento"
	oPrint:Say(3100, 0050, "(    ) CNS ", oFont04)
	oPrint:Say(3100, 0300, "(    ) CPF ", oFont04)
    
	oPrint:Box(3040, 0510, 3180, 1200) 
	oPrint:Say(3050, 0520, STR0056, oFont04) //"N° Documento (CNS/CPF) do Profissional Solicitante"
	
	oPrint:Box(3040, 1210, 3180, 2310) 
	oPrint:Say(3050, 1220, STR0083, oFont04) //"Assinatura e Carimbo (N° do Registro do Conselho)"
	
	oPrint:EndPage()	// Finaliza a pagina
   
   //Impressao Pagina 2 
	nLinIni := 0
	nColIni := 0
	nColA4  := 0
	nLinA4  := 0
		
	oPrint:StartPage()		// Inicia uma nova pagina
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Box Principal                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Box( 0010, 0010, nLinMax, nColMax)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega e Imprime Logotipo da Empresa                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FS_LogoEmp(@cFileLogo)
	
	oPrint:Box(0050, 0020, 0200, 0600)
	If File(cFilelogo)
		oPrint:SayBitmap(0090, 0040, cFileLogo, 0400, 0100)		// Tem que estar abaixo do RootPath
	EndIf 
	
	// Papél A4
	nColA4    := -0065
	
	oPrint:Box(0050, 0610, 0200, 2100)
	oPrint:Say(0090, 1385 + nColA4, STR0059, oFont03n,,,, 2) //"LAUDO PARA SOLICITAÇÃO/AUTORIZAÇÃO DE MUDANCA DE "
	oPrint:Say(0140, 1385 + nColA4, STR0060, oFont03n,,,, 2) //"PROCEDIMENTO E DE PROCEDIMENTO(S)ESPECIAL(AIS)"
    
	oPrint:Box(0050, 2110, 0200, 2320)
	oPrint:Say(0090, 2270 + nColA4, STR0061, oFont03n,,,, 2)
	oPrint:Say(0140, 2270 + nColA4, "2/2", oFont03n,,,, 2)	
	
	oPrint:Box(0210, 0020, 1880, 2320)
	oPrint:Say(0220, 0030, STR0086, oFont05) //"SOLICITAÇÃO DE PROCEDIMENTO(S) ESPECIAL(AIS)"
	//1
	oPrint:Box(0280, 0030, 0370, 1450)
	oPrint:Say(0290, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0280, 1460, 0370, 2160) 
	oPrint:Say(0290, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0280, 2170, 0370, 2310) 
	oPrint:Say(0290, 2180, STR0078, oFont04) //"Qtde"
    //2
	oPrint:Box(0380, 0030, 0470, 1450)
	oPrint:Say(0390, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0380, 1460, 0470, 2160) 
	oPrint:Say(0390, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0380, 2170, 0470, 2310) 
	oPrint:Say(0390, 2180, STR0078, oFont04) //"Qtde"
	//3
	oPrint:Box(0480, 0030, 0570, 1450)
	oPrint:Say(0490, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0480, 1460, 0570, 2160) 
	oPrint:Say(0490, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0480, 2170, 0570, 2310) 
	oPrint:Say(0490, 2180, STR0078, oFont04) //"Qtde"   
     //4
	oPrint:Box(0580, 0030, 0670, 1450)
	oPrint:Say(0590, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0580, 1460, 0670, 2160) 
	oPrint:Say(0590, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0580, 2170, 0670, 2310) 
	oPrint:Say(0590, 2180, STR0078, oFont04) //"Qtde"
    //5
	oPrint:Box(0680, 0030, 0770, 1450)
	oPrint:Say(0690, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0680, 1460, 0770, 2160) 
	oPrint:Say(0690, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0680, 2170, 0770, 2310) 
	oPrint:Say(0690, 2180, STR0078, oFont04) //"Qtde"
	//6
	oPrint:Box(0780, 0030, 0870, 1450)
	oPrint:Say(0790, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0780, 1460, 0870, 2160) 
	oPrint:Say(0790, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0780, 2170, 0870, 2310) 
	oPrint:Say(0790, 2180, STR0078, oFont04) //"Qtde"   
	//7
	oPrint:Box(0880, 0030, 0970, 1450)
	oPrint:Say(0890, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0880, 1460, 0970, 2160) 
	oPrint:Say(0890, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0880, 2170, 0970, 2310) 
	oPrint:Say(0890, 2180, STR0078, oFont04) //"Qtde"
    //8
	oPrint:Box(0980, 0030, 1070, 1450)
	oPrint:Say(0990, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(0980, 1460, 1070, 2160) 
	oPrint:Say(0990, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(0980, 2170, 1070, 2310) 
	oPrint:Say(0990, 2180, STR0078, oFont04) //"Qtde"
	//9
	oPrint:Box(1080, 0030, 1170, 1450)
	oPrint:Say(1090, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1080, 1460, 1170, 2160) 
	oPrint:Say(1090, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1080, 2170, 1170, 2310) 
	oPrint:Say(1090, 2180, STR0078, oFont04) //"Qtde"   
    //10
	oPrint:Box(1180, 0030, 1270, 1450)
	oPrint:Say(1190, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1180, 1460, 1270, 2160) 
	oPrint:Say(1190, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1180, 2170, 1270, 2310) 
	oPrint:Say(1190, 2180, STR0078, oFont04) //"Qtde"
    //11
	oPrint:Box(1280, 0030, 1370, 1450)
	oPrint:Say(1290, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1280, 1460, 1370, 2160) 
	oPrint:Say(1290, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1280, 2170, 1370, 2310) 
	oPrint:Say(1290, 2180, STR0078, oFont04) //"Qtde"
	//12
	oPrint:Box(1380, 0030, 1470, 1450)
	oPrint:Say(1390, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1380, 1460, 1470, 2160) 
	oPrint:Say(1390, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1380, 2170, 1470, 2310) 
	oPrint:Say(1390, 2180, STR0078, oFont04) //"Qtde"   
    //13
	oPrint:Box(1480, 0030, 1570, 1450)
	oPrint:Say(1490, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1480, 1460, 1570, 2160) 
	oPrint:Say(1490, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1480, 2170, 1570, 2310) 
	oPrint:Say(1490, 2180, STR0078, oFont04) //"Qtde"
    //14
	oPrint:Box(1580, 0030, 1670, 1450)
	oPrint:Say(1590, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1580, 1460, 1670, 2160) 
	oPrint:Say(1590, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1580, 2170, 1670, 2310) 
	oPrint:Say(1590, 2180, STR0078, oFont04) //"Qtde"
	//15
	oPrint:Box(1680, 0030, 1770, 1450)
	oPrint:Say(1690, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1680, 1460, 1770, 2160) 
	oPrint:Say(1690, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1680, 2170, 1770, 2310) 
	oPrint:Say(1690, 2180, STR0078, oFont04) //"Qtde"   
	//16
	oPrint:Box(1780, 0030, 1870, 1450)
	oPrint:Say(1790, 0040, STR0076, oFont04) //"Descrição do Procedimento Principal"
	
	oPrint:Box(1780, 1460, 1870, 2160) 
	oPrint:Say(1790, 1470, STR0077, oFont04) //"Código do Procedimento"

	oPrint:Box(1780, 2170, 1870, 2310) 
	oPrint:Say(1790, 2180, STR0078, oFont04) //"Qtde"   
    
	//BLOCO VI
	oPrint:Box(1900, 0020, 2500, 2320) 
	oPrint:Say(1910, 0030, STR0087, oFont05) //"Código do Procedimento" 
	 
	oPrint:Box(2520, 0020, 2850, 2320) 
	oPrint:Say(2540, 0030, STR0080, oFont05) //"PROFISSIONAL SOLICITANTE"
     
	oPrint:Box(2580, 0030, 2840, 2310) 
	oPrint:Say(2590, 0040, STR0088, oFont04) //"Assinatura e Carimbo (N° do Registro do Conselho) do Profissional Solicitante"

	oPrint:Box(2870, 0020, 3190, 2320) 
	oPrint:Say(2890, 0030, STR0084, oFont05) //"AUTORIZAÇÃO 
     
	oPrint:Box(2930, 0030, 3180, 2310) 
	oPrint:Say(2940, 0040, STR0089, oFont04) //"Assinatura e Carimbo (N° do Registro do Conselho) do Profissional Autorizador"

	
oPrint:EndPage()
oPrint:Preview()	// Visualiza impressao grafica antes de imprimir

	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LogoEmpºAutor  ³Sueli C Santos      º Data ³  24/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para carregar o logotipo da empresa.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LogoEmp(cLogoSUS)

Local cStartPath	:= GetSrvProfString("STARTPATH","")

If SubStr(cStartPath, Len(cStartPath),1) <> "/" .AND. SubStr(cStartPath, Len(cStartPath),1) <> "\"
	If At("/", cStartPath) > 0
		cStartPath := cStartPath + "/"
	Else
		cStartPath := cStartPath + "\"	
	EndIf
EndIf
// Logotipo da Empresa
cLogoSUS := cStartPath + "logosus.bmp"

Return(Nil)
                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AjustaSX1³ Autor ³ Sueli C Santos        ³ Data ³ 25/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica as perguntas incluindo-as caso nao existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local aArea		:= GetArea()
Local aRegs		:= {}
Local i			:= 0
Local j			:= 0
Local lInclui	:= .F.
Local aHelpPor	:= {}
Local cPerg:= PADR("HSPLDO",6)


aRegs	:= {}

AADD(aRegs,{cPerg,"01","Sol. Intern. Hospitalar ?     ","                           ","                              ","MV_CH0","C",01,00,01,"C","                                                            ","MV_PAR01       ","Sim "," "," ","                                                           ","               ","Nao         ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      "," ","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"02","Sol Mudanca Proc e Proc Esp. ?","                           ","                              ","MV_CH1","C",01,00,02,"C","                                                            ","MV_PAR02       ","Sim  "," "," ","                                                           ","             ","Nao         ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      "," ","   ","              ","                                        ","      "})

dbSelectArea("SX1")
dbSetOrder(1)
For i := 1 To Len(aRegs)
	lInclui := !dbSeek(cPerg + "    " + aRegs[i,2])
	RecLock("SX1", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Endif
	Next
	MsUnlock()
	
	aHelpPor := {}
	 
	IF i == 1
		AADD(aHelpPor,"Informe se deseja imprimir o Laudo para" )
		AADD(aHelpPor,"Solicitacao de Autorizacao de Internacao")
		AADD(aHelpPor,"Hospitalar")   
	ELSEIF i==2
		AADD(aHelpPor,"Informe se deseja imprimir o Laudo para")
		AADD(aHelpPor,"Solicitacao/Autorizacao de Mudanca de  ")
		AADD(aHelpPor,"Procedimento e de Procedimento(s)      ")
		AADD(aHelpPor,"Especial(ais)") 
	ENDIF
    PutSX1Help("P."+cPerg+strzero(i,2)+".",aHelpPor)
Next

RestArea(aArea)
Return()

