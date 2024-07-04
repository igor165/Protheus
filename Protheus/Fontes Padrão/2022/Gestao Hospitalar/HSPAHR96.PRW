#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "HSPAHR96.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR96  ºAutor  ³  Saude             º Data ³  17/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controle de frequencia individual de paciente com           º±±
±±º          ³deficiencia auditiva (verifica a funcao chamadora e executa º±±
±±º          ³a funcao principal (HSPAHR96m) passando como parametro a    º±±
±±º          ³tabela utilizada  pela funcao chamadora                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                

Function HSPAHR96()

If FunName() $ "HSPM24AA"		// Atendimento Ambulatorial
	HSPAHR96m("GCY")
ElseIf FunName() $ "HSPAHM12"	// Solicitacao de APAC
	HSPAHR96m("GK7")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR96m ºAutor  ³ Saude              º Data ³  15/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controle de frequencia individual de paciente com           º±±
±±º          ³deficiencia auditiva (funcao principal)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHR96m(cTabela)

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
Local nLenEnd   := 0
Local oFont02
Local oFont02n
Local oFont03n
Local oFont04
Local oFont05
Local nVolta    := 0
Local cMes		:= hs_getMes()
Local cDesPro1	:= ""
Local aProc		:= {}
Local lOrtPro	:= .F.
Local nI,nJ
Local nLinha
Local nProc
Local nProcImpr
Local cProcVazio


// Papél A4
nLinMax	:=	3200   
nColMax	:=	2330   
	
// Papél A4
oFont02		:= TFont():New("Arial", 11, 11, , .F., , , , .T., .F.) // Normal
oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
oFont04n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
oFont05		:= TFont():New("Arial", 09, 09, , .T., , , , .T., .F.) // Negrito
	
oPrint	:= TMSPrinter():New(STR0034) //"CONTROLE DE FREQUÊNCIA INDIVIDUAL"
	
oPrint:SetPortrait()	// Modo retrato
	
oPrint:SetPaperSize(9)// Papél A4
	
// Verifica se existe alguma impressora configurada para Impressao Grafica
lPrinter := oPrint:IsPrinterActive()
	
//If !lPrinter
//	oPrint:Setup()
//EndIf     

DbSelectArea("GKA")
DbSetOrder(1)
DbSeek(xFilial("GKA") + GK7->GK7_SOLICI) 

While GKA->(!Eof()) .AND. GKA->GKA_SOLICI == GK7->GK7_SOLICI
	aADD(aProc, GKA->GKA_CODPRO)
	GKA->(DbSkip())
End
nProcImpr :=1 

//Se nao houver nenhum procedimento, adiciona um unico item ao array para impressao dos
//procedimentos secundarios e atribui um tamanho 1 para o array para impressao posterior  
if len(aProc)==0
	aADD(aProc, Repl(" ",10))
endif



//Inicia a impressao


while nProcImpr<=len(AProc)
	
	nVolta  += 1
	nT      += 5
	nT1     += 2
	nT3     += 3
	
	nLinIni := 0
	nColIni := 0
	nColA4  := 0
	nLinA4  := 0
	
	oPrint:StartPage()		// Inicia uma nova pagina
	

	//Box Principal                                                 ³
	oPrint:Box( 0010, 0010, nLinMax, nColMax)
	

	//Carrega e Imprime Logotipo do SUS
	hs_LogoSus(@cFileLogo)
	
	oPrint:Box(0050, 0020, 0200, 0600)
	If File(cFilelogo)
		oPrint:SayBitmap(0090, 0040, cFileLogo, 0400, 0100)		// Tem que estar abaixo do RootPath
	EndIf
	
	// Papél A4
	nColA4    := -0065
	
	oPrint:Box(0050, 0610, 0200, 1800)
	oPrint:Say(0090, 1235 + nColA4, STR0035, oFont03n,,,, 2) //"CONTROLE DE FREQUÊNCIA INDIVIDUAL DE "
	oPrint:Say(0140, 1235 + nColA4, STR0036, oFont03n,,,, 2) //"PACIENTE COM DEFICIÊNCIA AUDITIVA"
	
	oPrint:Box(0050, 1810, 0200, 2320)
	oPrint:Say(0080, 1850, STR0037, oFont04) //"Nº do Prontuário"
	oPrint:Say(00110, 1920 + nColA4, &(cTabela+"->"+cTabela+"_REGGER"), oFont04n)
	
	/*	oPrint:Say(0050, 1980, "Nº do Prontuário", oFont04) //"Nº do Prontuário"
	oPrint:Say(0090, 2050 + nColA4, &(cTabela+"->"+cTabela+"_REGGER"), oFont04n)    */
	
	If !Empty(GK7->GK7_SOLICI)
		MsBar3( 'CODE128', 0.7 , 17.5, Alltrim(GK7->GK7_SOLICI), oPrint, .F., , .T., 0.015, 0.6, .F., 'TAHOMA', 'B', .F. )
		oPrint:Say(0165, 2180 + nColA4, Alltrim(GK7->GK7_SOLICI), oFont04) //
	EndIf
	
	oPrint:Box(0210, 0020, 0350, 2320)
	oPrint:Say(0210, 0040, STR0038, oFont04) //"Identificação da Unidade"
	oPrint:Box(0240, 0030, 0340, 1650)
	oPrint:Say(0240, 0040, STR0039, oFont04) //"Nome"
	oPrint:Say(0270, 0040, SM0->M0_NOMECOM, oFont02n)
	oPrint:Box(0240, 1660, 0340, 2310)
	
	oPrint:Say(0240, 1965 + nColA4, STR0040, oFont04) //"CNPJ"

	oPrint:Say(0270, 1685, hs_formCnp(SM0->M0_CGC), oFont02n)
	
	oPrint:Box(0360, 0020, 0900, 2320)
	oPrint:Say(0360, 0040, STR0041, oFont04) //"Dados do Paciente"
	
	
	DbSelectArea("GBH")
	DbSetOrder(1)
	DbSeek(xFilial("GBH") + &(cTabela+"->"+cTabela+"_REGGER"))
	
	
	
	oPrint:Box(0390, 0030, 0480, 2310)
	oPrint:Say(0390, 0040, STR0042, oFont04) //"Nome do Paciente"
	oPrint:Say(0420, 0040, GBH->GBH_NOME, oFont02n)
	
	oPrint:Box(0490, 0030, 0580, 1155)
	oPrint:Say(0490, 0040, STR0043, oFont04) //"CNS"
	oPrint:Say(0520, 0040, hs_formCNS(GBH->GBH_NUMCNS), oFont02n)
	
	oPrint:Box(0490, 1165, 0580, 2310)
	oPrint:Say(0490, 1185, STR0044, oFont04) //"CPF"
	oPrint:Say(0520, 1185, hs_formCpf(GBH->GBH_CPF), oFont02n)
	
	oPrint:Box(0590, 0030, 0680, 2310)
	oPrint:Say(0590, 0040, STR0045, oFont04) //"Nome da Mãe ou Responsável"
	oPrint:Say(0620, 0040, GBH->GBH_NOMMAE, oFont02n)
	
	
	
	oPrint:Box(0690, 0030, 0780, 1610)
	oPrint:Say(0690, 0040, STR0046, oFont04) //"Endereço (Logradouro, nº, complemento, bairro)"
	
	//oPrint:Say(0720, 0040, AllTrim(GBH->GBH_END) + ", " + AllTrim(GBH->GBH_NUM) + ", " + SubStr(AllTrim(GBH->GBH_COMPLE),1,11) + ", " + SubStr(AllTrim(GBH->GBH_BAIRRO),1,9), oFont02n)
	
	If Len(AllTrim(GBH->GBH_END))+Len(AllTrim(GBH->GBH_NUM))+Len(AllTrim(GBH->GBH_COMPLE))+Len(AllTrim(GBH->GBH_BAIRRO)) <= 64
	    oPrint:Say(0720, 0040, hs_formEnd(GBH->GBH_END,GBH->GBH_NUM,GBH->GBH_COMPLE,GBH->GBH_BAIRRO), oFont02n)
	Else
	    nLenEnd := Len(AllTrim(GBH->GBH_END))+Len(AllTrim(GBH->GBH_NUM))+Len(AllTrim(GBH->GBH_COMPLE))    
	    oPrint:Say(0720, 0040, hs_formEnd(GBH->GBH_END,GBH->GBH_NUM,GBH->GBH_COMPLE,SubStr(AllTrim(GBH->GBH_BAIRRO),1,64-nLenEnd)), oFont02n)
    EndIf   
	
	oPrint:Box(0690, 1620, 0780, 2310)
	oPrint:Say(0690, 1650, STR0047, oFont04) //"DDD - Nº Telefone"
	oPrint:Say(0720, 1650, hs_formTel(GBH->GBH_Tel), oFont02n)
	
	
	oPrint:Box(0790, 0030, 0880, 1000)
	oPrint:Say(0790, 0040, STR0048, oFont04) //"Município"
	oPrint:Say(0820, 0040, GBH->GBH_MUN, oFont02n)
	
	oPrint:Box(0790, 1010, 0880, 1110)
	oPrint:Say(0790, 1040, STR0049, oFont04) //"UF"
	oPrint:Say(0820, 1025, SubStr(GBH->GBH_EST,1,1) + "  " + SubStr(GBH->GBH_EST,2,1), oFont02n)
	
	oPrint:Box(0790, 1120, 0880, 1610)
	oPrint:Say(0790, 1150, STR0050, oFont04) //"CEP"
	oPrint:Say(0820, 1150, hs_formCep(GBH->GBH_CEP), oFont02n)
	
	oPrint:Box(0790, 1620, 0880, 1950)
	oPrint:Say(0790, 1640, STR0051, oFont04) //"Data de Nascimento"
	oPrint:Say(0820, 1640, DtoC(GBH->GBH_DTNASC), oFont02n)
	
	oPrint:Say(0850, 1970, STR0052, oFont04) //"SEXO"
	oPrint:Say(0790, 2085, STR0053, oFont04) //"Masc."
	oPrint:Say(0790, 2225, STR0054, oFont04) //"Fem."
	
	oPrint:Box(0820, 2050, 0880, 2175)
	oPrint:Line(0820, 2112, 0880, 2112)
	oPrint:Say(0840, 2140, "1", oFont04) //"1" - Masculino
	
	oPrint:Box(0820, 2185, 0880, 2310)
	oPrint:Line(0820, 2247, 0880, 2247)
	oPrint:Say(0840, 2275, "2", oFont04) //"2" - Feminino
	
	If GBH->GBH_SEXO == "0"
		oPrint:Say(0840, 2075, "X", oFont05) //Masculino
	Else
		oPrint:Say(0840, 2210, "X", oFont05) //Feminino
	EndIf
	
	oPrint:Box(0920, 0020, 3190, 2320)
	oPrint:Say(0950, 0900, STR0055, oFont03n) //"DECLARAÇÃO"
	oPrint:Say(1050, 0040, STR0056 + lower(cMes) + STR0057, oFont05) //"DECLARO QUE NO MÊS DE ______________________, O PACIENTE IDENTIFICADO ACIMA, FOI SUBMETIDO AOS PROCEDIMENTOS"
	oPrint:Say(1100, 0040, STR0058, oFont05) //"ABAIXO RELACIONADOS, CONFORME ASSINATURAS(S) DO PACIENTE/RESPONSÁVEL ABAIXO."
	
	
	
	oPrint:Box(1220, 0030, 1410, 2310)
	oPrint:Say(1250, 1150, STR0059, oFont03n,,,,2) //"CÓDIGO DO PROCEDIMENTO PRINCIPAL"
	//Desenha o box inserindo o procedimento principal
	hs_boxProc(1320,0670,oPrint,10,75,100,&(cTabela+"->"+cTabela+"_CODPRO"),oFont05)
	
	
	
	
	oPrint:Box(1460, 0030, 3180, 2310)
	oPrint:Say(1490, 1130, STR0060, oFont03n,,,,2) //"CÓDIGO DOS PROCEDIMENTOS SECUNDÁRIOS"
	
	
	//Preenchendo procedimentos secundarios - 9 Linhas com 3 colunas
	//os procedimentos estao armazenados no array aProc
	nLinha:=1570
	nProc :=len(aProc)
	nJ    :=nProcImpr
	cProcVazio:=Repl(" ",10)
	for nI=1 to 9
		if nJ<=nProc
			hs_boxProc(nLinha,0070,oPrint,10,60,68,aProc[nJ],oFont05)
			nJ++
			nProcImpr++
		else
			hs_boxProc(nLinha,0070,oPrint,10,60,68,cProcVazio,oFont05)
		endif
		
		if nJ<=nProc
			hs_boxProc(nLinha,0820,oPrint,10,60,68,aProc[nJ],oFont05)
			nJ++
			nProcImpr++
		else
			hs_boxProc(nLinha,0820,oPrint,10,60,68,cProcVazio,oFont05)
		endif
		
		if nJ<=nProc
			hs_boxProc(nLinha,1570,oPrint,10,60,68,aProc[nJ],oFont05)
			nJ++
			nProcImpr++
		else
			hs_boxProc(nLinha,1570,oPrint,10,60,68,cProcVazio,oFont05)
		endif
		
		nLinha+=80
	next nI
	
	oPrint:Say(2350, 1700, SubStr(AllTrim(SM0->M0_CIDCOB),1,13)+", " + AllTrim(Str(Day(dDataBase))) + STR0061 + ;
	cMes + STR0061 + AllTrim(Str(Year(dDataBase))), oFont05)
	
	oPrint:Line(2800, 1400, 2800, 2280)
	oPrint:Say(2840, 1550, STR0062, oFont05) //Assinatura / Carimbo do Diretor da unidade
	
	
	oPrint:Box(2920, 0045, 3140, 2295)
	
	oPrint:Box(2950, 0060, 3120, 1410)
	oPrint:Say(2980, 0090, STR0063, oFont04) //"Nome / Assinatura do Paciente ou Responsável"
	oPrint:Say(3030, 0090,GBH->GBH_NOME , oFont02n)
	
	oPrint:Box(2950, 1420, 3120, 2280)
	oPrint:Say(2980, 1450, STR0043+ " / " + STR0044, oFont04) //"CNS / CPF"
	oPrint:Say(3030, 1450, hs_formCns(GBH->GBH_NUMCNS) + " / " + hs_formCpf(GBH->GBH_CPF), oFont05)
	
	oPrint:EndPage()	// Finaliza a pagina
	
Enddo



oPrint:Preview()	// Visualiza impressao grafica antes de imprimir


	
Return
             
           

