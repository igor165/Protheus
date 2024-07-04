#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "HSPAHR97.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR96  ºAutor  ³                    º Data ³  17/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Laudo para emissao de APAC Deficiencia auditiva             º±±
±±º          ³(verifica a funcao chamadora e executa                      º±±
±±º          ³a funcao principal (HSPAHR97m) passando como parametro a    º±±
±±º          ³tabela utilizada  pela funcao chamadora                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                

Function HSPAHR97()

If FunName() $ "HSPM24AA"		// Atendimento Ambulatorial
	HSPAHR97m("GCY")
ElseIf FunName () $ "HSPAHM12"	// Solicitacao de APAC
	HSPAHR97m("GK7")
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR97m ºAutor  ³                    º Data ³  15/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Laudo para emissao de APAC Deficiencia auditiva             º±±
±±º          ³(funcao principal)                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHR97m(cTabela)



Local nLinMax	:= 0
Local nColMax	:= 0
Local nLinIni	:= 0	// Linha Lateral (inicial) Esquerda
Local nColIni	:= 0	// Coluna Lateral (inicial) Esquerda
Local nLenEnd   := 0
Local cFileLogo
Local oFont02
Local oFont02n
Local oFont03n
Local oFont04
Local oFont05 
Local oFont06
Local oFont06n
Local cMes		:= hs_getMes()
Local cDesPro1	:= ""
Local nI,nJ
Local nLinha
Local nProc
Local cNomeProc
Local cConvenio
Local cDesConv  
Local cConvPAC	:= GetMv("MV_CCVSUS")
   


// Qtde de linhas folha A4
nLinMax	:=	3200   
nColMax	:=	2330
// Fontes para impressao Papel A4
oFont02		:= TFont():New("Arial", 11, 11, , .F., , , , .T., .F.) // Normal
oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
oFont04n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
oFont05		:= TFont():New("Arial", 09, 09, , .T., , , , .T., .F.) // Negrito  
oFont06		:= TFont():New("Arial", 10, 10, , .F., , , , .T., .F.) // Normal
oFont06n	:= TFont():New("Arial", 10, 10, , .T., , , , .T., .F.) // Negrito



oPrint	:= TMSPrinter():New(STR0029) //"Laudo para emissao de APAC Deficiencia auditiva"
// Define impressao em modo retrato
oPrint:SetPortrait()
// Define impressão em papel A4
oPrint:SetPaperSize(9)
// Verifica se existe alguma impressora configurada para Impressao Grafica
lPrinter := oPrint:IsPrinterActive()


//Inicia uma nova pagina
oPrint:StartPage()
//Box Principal                                                 ³
oPrint:Box( nLinIni, nColIni, nLinMax, nColMax)




//Box para logotipo SUS
oPrint:Box(0050, 0020, 0200, 0600)
//Carrrega o logo
hs_LogoSus(@cFileLogo)
//Verifica se o arquivo existe e foi carregado para exibi-lo
If File(cFilelogo)
	oPrint:SayBitmap(0090, 0040, cFileLogo, 0400, 0100)		// Tem que estar abaixo do RootPath
EndIf

//Box Titulo do Formulario	
oPrint:Box(0050, 0610, 0200, 1800)
oPrint:Say(0090, 1220 , STR0030, oFont03n,,,, 2) //" LAUDO PARA EMISSÃO DE APAC "
oPrint:Say(0140, 1220 , STR0031, oFont03n,,,, 2) //" DEFICIÊNCIA AUDITIVA "

//Box Nr.do Produto
oPrint:Box(0050, 1810, 0200, 2320)
oPrint:Say(0060, 1850, STR0032, oFont04) //"Nr. do Produto"  



//Box Identificacao da unidade  
oPrint:Box(0210, 0020, 0350, 2320)
oPrint:Say(0210, 0140, STR0033, oFont04) //"Identificação da Unidade"
oPrint:Box(0240, 0130, 0340, 1550)
oPrint:Say(0240, 0140, STR0034, oFont04) //"Nome"
oPrint:Say(0270, 0140, SM0->M0_NOMECOM, oFont02n)
oPrint:Box(0240, 1560, 0340, 2210)

//Box CNPJ	
oPrint:Say(0240, 1800, STR0035, oFont04) //"CNPJ"
oPrint:Say(0270, 1585, hs_formCnp(SM0->M0_CGC), oFont02n)



//Box Principal da secao "Dados do Paciente"
oPrint:Box(0360, 0020, 1180, 2320)
oPrint:Say(0360, 0140, STR0036, oFont04) //"Dados do Paciente"
	
//Selecionando arquivo de pacientes	
DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + &(cTabela+"->"+cTabela+"_REGGER"))


	
	
//Box nome do paciente	
oPrint:Box(0390, 0130, 0480, 2210)
oPrint:Say(0390, 0140, STR0037, oFont04) //"Nome do Paciente"
oPrint:Say(0420, 0140, GBH->GBH_NOME, oFont02n)

//Box CNS	
oPrint:Box(0490, 0130, 0580, 1055)
oPrint:Say(0490, 0140, STR0038, oFont04) //"CNS"
oPrint:Say(0520, 0140, hs_formCNS(GBH->GBH_NUMCNS), oFont02n)

//Box CPF	
oPrint:Box(0490, 1065, 0580, 2210)
oPrint:Say(0490, 1085, STR0039, oFont04) //"CPF"
oPrint:Say(0520, 1085, hs_formCpf(GBH->GBH_CPF), oFont02n)
	
oPrint:Box(0590, 0130, 0680, 2210)
oPrint:Say(0590, 0140, STR0040, oFont04) //"Nome da Mãe ou Responsável"
oPrint:Say(0620, 0140, GBH->GBH_NOMMAE, oFont02n)
	
	
	
oPrint:Box(0690, 0130, 0780, 1510)
oPrint:Say(0690, 0140, STR0041, oFont04) //"Endereço (Logradouro, nº, complemento, bairro)"

//oPrint:Say(0720, 0140, AllTrim(GBH->GBH_END) + ", " + AllTrim(GBH->GBH_NUM) + ", " + SubStr(AllTrim(GBH->GBH_COMPLE),1,11) + ", " + SubStr(AllTrim(GBH->GBH_BAIRRO),1,9), oFont02n)

If Len(AllTrim(GBH->GBH_END))+Len(AllTrim(GBH->GBH_NUM))+Len(AllTrim(GBH->GBH_COMPLE))+Len(AllTrim(GBH->GBH_BAIRRO)) <= 60
    oPrint:Say(0720, 0140, hs_formEnd(GBH->GBH_END,GBH->GBH_NUM,GBH->GBH_COMPLE,GBH->GBH_BAIRRO), oFont02n)
Else
    nLenEnd := Len(AllTrim(GBH->GBH_END))+Len(AllTrim(GBH->GBH_NUM))+Len(AllTrim(GBH->GBH_COMPLE))    
    oPrint:Say(0720, 0140, hs_formEnd(GBH->GBH_END,GBH->GBH_NUM,GBH->GBH_COMPLE,SubStr(AllTrim(GBH->GBH_BAIRRO),1,60-nLenEnd)), oFont02n)
EndIf   
	
oPrint:Box(0690, 1520, 0780, 2210)
oPrint:Say(0690, 1550, STR0042, oFont04) //"DDD - Nº Telefone"
oPrint:Say(0720, 1550, hs_formTel(GBH->GBH_Tel), oFont02n)
	                       
	
	
oPrint:Box(0790, 0130, 0880, 0900)
oPrint:Say(0790, 0140, STR0043, oFont04) //"Município"
oPrint:Say(0820, 0140, GBH->GBH_MUN, oFont02n)
	
oPrint:Box(0790, 0910, 0880, 1010)
oPrint:Say(0790, 0940, STR0044, oFont04) //"UF"
oPrint:Say(0820, 0925, SubStr(GBH->GBH_EST,1,1) + "  " + SubStr(GBH->GBH_EST,2,1), oFont02n)
	
oPrint:Box(0790, 1020, 0880, 1510)
oPrint:Say(0790, 1050, STR0045, oFont04) //"CEP"
oPrint:Say(0820, 1050, hs_formCep(GBH->GBH_CEP), oFont02n)
	
oPrint:Box(0790, 1520, 0880, 1850)
oPrint:Say(0790, 1540, STR0046, oFont04) //"Data de Nascimento"
oPrint:Say(0820, 1540, DtoC(GBH->GBH_DTNASC), oFont02n)
	
oPrint:Say(0850, 1870, STR0047, oFont04) //"SEXO"
oPrint:Say(0790, 1985, STR0048, oFont04) //"Masc."
oPrint:Say(0790, 2125, STR0049, oFont04) //"Fem."
	
oPrint:Box(0820, 1950, 0880, 2075)
oPrint:Line(0820, 2012, 0880, 2012)
oPrint:Say(0840, 2040, "1", oFont04) //"1" - Masculino
	
oPrint:Box(0820, 2085, 0880, 2210)
oPrint:Line(0820, 2147, 0880, 2147)
oPrint:Say(0840, 2175, "2", oFont04) //"2" - Feminino
	
If GBH->GBH_SEXO == "0"
	oPrint:Say(0840, 1975, "X", oFont05) //Masculino
Else
	oPrint:Say(0840, 2110, "X", oFont05) //Feminino
EndIf

//Box Convenio / Sim / Nao
//	oPrint:Box(0790, 0030, 0990, 1000)
//Box Convenio
oPrint:Box(0890, 0130, 0990, 0500)	
oPrint:Say(0915, 0200, STR0050, oFont02n) //"CONVÊNIO"
//Box Sim
oPrint:Box(0890, 0500, 0990, 0700)
oPrint:Say(0905, 0580, STR0051, oFont04) //"Sim"
oPrint:Box(0940, 0500, 0990, 0700)
//Box Nao
oPrint:Box(0890, 0700, 0940, 0900)	
oPrint:Say(0905, 0780, STR0052, oFont04) //"Não"
oPrint:Box(0940, 0700, 0990, 0900)
//Box Nome do Convenio
oPrint:Box(0890, 0910, 0990, 2210)	
oPrint:Say(0890, 0920, STR0053, oFont04) //"Nome do Convênio"    

// Pega o plano do paciente, caso tenha.
DbSelectArea("GD4")
DbSetOrder(1)
DbSeek(xFilial("GD4") + &(cTabela+"->"+cTabela+"_REGGER"))
   
While GD4->(!Eof()) .AND. GD4->GD4_REGGER == &(cTabela+"->"+cTabela+"_REGGER")
	If GD4->GD4_CODCON <> cConvPAC //Se o Codigo do convenio eh diferente do SUS(cConvPAC, obtida via GetMv("MV_CCVSUS"))
		if GD4->GD4_IDPADR=="1" //Se eh o plano padrao
	    	cConvenio	:= GD4->GD4_CODCON
    		cDesConv	:= Posicione("GA9",1,xFilial("GA9") + GD4->GD4_CODCON,"GA9_NOME")
    		Exit
  		endif
  		//Se o convenio particular nao eh o padrao
	    cConvenio	:= GD4->GD4_CODCON
    	cDesConv	:= Posicione("GA9",1,xFilial("GA9") + GD4->GD4_CODCON,"GA9_NOME")
	EndIf
    GD4->(DbSkip())
End
	

If !Empty(cConvenio)
	oPrint:Say(0950, 0595, "X", oFont02) 
Else
	oPrint:Say(0950, 0795, "X", oFont02)  
EndIf

If !Empty(cDesConv)
	oPrint:Say(0940, 0920, cDesConv, oFont02)
EndIf
	


//Box Procedimento solicitado
oPrint:Box(1000, 0130, 1170, 2210)
oPrint:Say(1005, 0140, STR0054, oFont04) //"Procedimento Solicitado"
//Codigo     
oPrint:Box(1050, 0140, 1160, 0900)
oPrint:Say(1050, 0150, STR0055, oFont04) //"Código"
hs_boxProc(1090, 0170,oPrint,10,60,70,&(cTabela+"->"+cTabela+"_CODPRO"),oFont05)

oPrint:Box(1050, 0910, 1160, 2200)
oPrint:Say(1050, 0920, STR0056, oFont04) //"Nome do Procedimento" 
cNomeProc := Posicione('GA7', 1, xFilial('GA7') + &(cTabela+"->"+cTabela+"_CODPRO"), 'GA7_DESC')
oPrint:Say(1100, 0920, cNomeProc , oFont02)




//Box Justificativa dos procedimentos
oPrint:Box(1190, 0020, 2890, 2320)
oPrint:Say(1200, 1100, STR0057, oFont02n,,,, 2) //"JUSTIFICATIVA DO(S) PROCEDIMENTO(S)"
//Box Procedimento solicitado
oPrint:Box(1260, 0030, 2880, 2310)
oPrint:Say(1265, 1105, STR0058, oFont02n,,,, 2) //"PROCEDIMENTO SOLICITADO"

//Box CID 10
oPrint:Box(1310, 0130, 1450, 2210)
oPrint:Say(1310, 0140, STR0059, oFont06n) //"CID 10"
//Box Causa Principal
oPrint:Box(1360, 0170, 1440, 0820)
oPrint:Say(1360, 0180, STR0060, oFont04) //"CAUSA PRINCIPAL" 
//Box Causa Basica
oPrint:Box(1360, 0845, 1440, 1495)
oPrint:Say(1360, 0855, STR0061, oFont04) //"CAUSA BÁSICA" 
//Box Causa Associada
oPrint:Box(1360, 1520, 1440, 2170)
oPrint:Say(1360, 1530, STR0062, oFont04) //"CAUSA ASSOCIADA" 


//Box sinais e sintomas clinicos
oPrint:Box(1460, 0130, 1600, 2210)
oPrint:Say(1460, 0140, STR0063, oFont06n) //"SINAIS E SINTOMAS CLÍNICOS"
//Box Dificuldade auditiva
oPrint:Box(1510, 0160, 1570, 0220)
oPrint:Say(1520, 0230, STR0064, oFont04) //"Dificuldade auditiva" 
//Box OD
oPrint:Box(1510, 0530, 1570, 0590)
oPrint:Say(1520, 0600, STR0065, oFont04) //"OD" 
//Box OE
oPrint:Box(1510, 0740, 1570, 0800)
oPrint:Say(1520, 0810, STR0066, oFont04) //"OE" 
//Box Flutuante
oPrint:Box(1510, 0950, 1570, 1010)
oPrint:Say(1520, 1020, STR0067, oFont04) //"Flutuante" 
//Box Estavel
oPrint:Box(1510, 1230, 1570, 1290)
oPrint:Say(1520, 1300, STR0068, oFont04) //"Estável" 
//Box Progressiva
oPrint:Box(1510, 1470, 1570, 1530)
oPrint:Say(1520, 1540, STR0069, oFont04) //"Progressiva" 
//Box Com Zumbido
oPrint:Box(1510, 1750, 1570, 1810)
oPrint:Say(1520, 1820, STR0070, oFont04) //"Com Zumbido" 
//Box Com
oPrint:Box(1510, 2050, 1570, 2110)
oPrint:Say(1520, 2120, STR0071, oFont04) //"Com "   


//Box Provavel Etiologia
//oPrint:Box(1610, 0050, 1840, 2290)
oPrint:Box(1610, 0130, 1840, 2210)
oPrint:Say(1610, 0140, STR0072, oFont06n) //"PROVÁVEL ETIOLOGIA"
//Box Desconhecida
oPrint:Box(1660, 0160, 1720, 0220)
oPrint:Say(1670, 0230, STR0073, oFont04) //"Desconhecida"
//Box Genetica
oPrint:Box(1660, 0490, 1720, 0550)
oPrint:Say(1670, 0560, STR0074, oFont04) //"Genética" 
//Box Surdez subita
oPrint:Box(1660, 0800, 1720, 0860)
oPrint:Say(1670, 0870, STR0075, oFont04) //"Surdez Súbita" 
//Box Malformacao COngenita
oPrint:Box(1660, 1150, 1720, 1210)
oPrint:Say(1670, 1220, STR0076, oFont04) //"Malformação Congênita" 
//Box Prebiscula
oPrint:Box(1660, 1600, 1720, 1660)
oPrint:Say(1670, 1670, STR0077, oFont04) //"Prebíscula" 
//Box Otite Medica Cronica
oPrint:Box(1660, 1880, 1720, 1940)
oPrint:Say(1670, 1950, STR0078, oFont04) //"Otite Médica Crônica" 
//Linha 2 
//Box Pos-Operatorio
oPrint:Box(1740, 0160, 1800, 0220)
oPrint:Say(1750, 0230, STR0079, oFont04) //"Pós-Operatório"
//Box TCE
oPrint:Box(1740, 0490, 1800, 0550)
oPrint:Say(1750, 0560, STR0080, oFont04) //"TCE"
//Box Idiopatica
oPrint:Box(1740, 800, 1800, 0860)
oPrint:Say(1750, 0870, STR0081, oFont04) //"Idiopática"
//Box Uso de Ototoxicos
oPrint:Box(1740, 1150, 1800, 1210)
oPrint:Say(1750, 1220, STR0082, oFont04) //"Uso de Ototóxicos"
//Box Fratura do Osso Temporal
oPrint:Box(1740, 1600, 1800, 1660)
oPrint:Say(1750, 1670, STR0083, oFont04) //"Fratura do Osso Temporal"



//Box 1
oPrint:Box(1850, 0130, 1930, 2210)
//Box Anoxia
oPrint:Box(1860, 0160, 1920, 0220)
oPrint:Say(1870, 0230, STR0084, oFont04) //"Anóxia" 
//Box Baixo Peso
oPrint:Box(1860, 0500, 1920, 0560)
oPrint:Say(1870, 0570, STR0085, oFont04) //"Baixo Peso"
//Box Trabalho de Parto Prolongado
oPrint:Box(1860, 0880, 1920, 0940)
oPrint:Say(1870, 0950, STR0086, oFont04) //"Trabalho de Parto Prolongado"
//Box Prematuridade
oPrint:Box(1860, 1500, 1920, 1550)
oPrint:Say(1870, 1560, STR0087, oFont04) //"Prematuridade"
//Box Hiperbilirrubinemia
oPrint:Box(1860, 1900, 1920, 1960)
oPrint:Say(1870, 1970, STR0088, oFont04) //"Hiperbilirrubinemia"


//Box 2
oPrint:Box(1940, 0130, 2020, 2210)
//Box Meninoite
oPrint:Box(1950, 0160, 2010, 0220)
oPrint:Say(1960, 0230, STR0089, oFont04) //"Meninoite" 
//Box Sarampo
oPrint:Box(1950, 0500, 2010, 0560)
oPrint:Say(1960, 0570, STR0090, oFont04) //"Sarampo"
//Box Toxoplasmose
oPrint:Box(1950, 0880, 2010, 0940)
oPrint:Say(1960, 0950, STR0091, oFont04) //"Toxoplasmose"
//Box Caxumba
oPrint:Box(1950, 1310, 2010, 1360)
oPrint:Say(1960, 1370, STR0092, oFont04) //"Caxumba"
//Box Rubéola Congênita
oPrint:Box(1950, 1610, 2010, 1670)
oPrint:Say(1960, 1680, STR0093, oFont04) //"Rubéola Congênita"
//Box Outras
oPrint:Box(1950, 2010, 2010, 2070)
oPrint:Say(1960, 2080, STR0094, oFont04) //"Outras" 
                     


//Box CARACTERIZACAO DA PERDA     
oPrint:Box(2030, 0050, 2640, 1165)
oPrint:Say(2032, 0570, STR0095, oFont02n,,,, 2) //"CARACTERIZAÇÃO DA PERDA" 


//Box Tipo
oPrint:Box(2075, 0060, 2533, 0617)

//Box Tipo - Cabecalho
oPrint:Box(2075, 0060, 2162, 0437)
oPrint:Say(2095, 0120, STR0096, oFont02n,,,, 2) //"TIPO"
//Box OE
oPrint:Box(2075, 0437, 2162, 0527)
oPrint:Say(2095, 0482, STR0066, oFont02n,,,, 2) //"OE"
//Box OD
oPrint:Box(2075, 0527, 2162, 0617)
oPrint:Say(2095, 0572, STR0065, oFont02n,,,, 2) //"OD"

//Box Tipo - Linhas 1 a 4
//Box Neurossensorial - Linha 1
oPrint:Box(2162, 0060, 2255, 0437)
oPrint:Say(2192, 0090, STR0097, oFont04) //"Neurossensorial"
//Boxes
oPrint:Box(2162, 0437, 2255, 0527)
oPrint:Box(2162, 0527, 2255, 0617)

//Box Condutiva - Linha 2
oPrint:Box(2255, 0060, 2348, 0437)
oPrint:Say(2285, 0090, STR0098, oFont04) //"Condutiva"
//Boxes
oPrint:Box(2255, 0437, 2348, 0527)
oPrint:Box(2255, 0527, 2348, 0617)

//Box Mista - Linha 3
oPrint:Box(2348, 0060, 2441, 0437)
oPrint:Say(2378, 0090, STR0099, oFont04) //"Mista"
//Boxes
oPrint:Box(2348, 0437, 2441, 0527)
oPrint:Box(2348, 0527, 2441, 0617)
//Box Central - Linha 4
oPrint:Box(2441, 0060, 2534, 0437)
oPrint:Say(2471, 0090, STR0100, oFont04) //"Central"
//Boxes
oPrint:Box(2441, 0437, 2533, 0527)
oPrint:Box(2441, 0527, 2533, 0617)
         


//Box Grau
oPrint:Box(2075, 0627, 2630, 1155)

//Box Grau - Cabecalho
oPrint:Box(2075, 0627, 2162, 0975)
oPrint:Say(2095, 0647, STR0101, oFont02n) //"GRAU"
//Box OE
oPrint:Box(2075, 0975, 2162, 1065)
oPrint:Say(2095, 1024, STR0066, oFont02n,,,, 2) //"OE"
//Box OD
oPrint:Box(2075, 1065, 2162, 1155)
oPrint:Say(2095, 1110, STR0065, oFont02n,,,, 2) //"OD"
                     

//Bos Tipo - Linhas 1 a 5
//Box Normal - Linha 1
oPrint:Box(2162, 0627, 2255, 0975)
oPrint:Say(2192, 0647, STR0102, oFont04) //"Normal"
//Boxes
oPrint:Box(2162, 0975, 2255, 1065)
oPrint:Box(2162, 1065, 2255, 1155)

//Box Leve - Linha 2
oPrint:Box(2255, 0627, 2348, 0975)
oPrint:Say(2285, 0647, STR0103, oFont04) //"Condutiva"
//Boxes
oPrint:Box(2255, 0975, 2348, 1065)
oPrint:Box(2255, 1065, 2348, 1155)

//Box Moderado - Linha 3
oPrint:Box(2348, 0627, 2441, 0975)
oPrint:Say(2378, 0647, STR0104, oFont04) //"Moderado"
//Boxes
oPrint:Box(2348, 0975, 2441, 1065)
oPrint:Box(2348, 1065, 2441, 1155)

//Box Profundo - Linha 4
oPrint:Box(2441, 0627, 2534, 0975)
oPrint:Say(2471, 0647, STR0105, oFont04) //"Profundo"
//Boxes
oPrint:Box(2441, 0975, 2533, 1065)
oPrint:Box(2441, 1065, 2533, 1155)

//Box Severo - Linha 5
oPrint:Box(2533, 0627, 2630, 0975)
oPrint:Say(2565, 0657, STR0106, oFont04) //"Severo"
//Boxes
oPrint:Box(2533, 0975, 2630, 1065)
oPrint:Box(2533, 1065, 2630, 1155)





//Box PROTESES AUDITIVAS
oPrint:Box(2030, 1175, 2640, 2290)
oPrint:Say(2032, 1690, STR0107, oFont02n,,,, 2) //"PROTÉSES AUDITIVAS"

//Box Tipo - Cabecalho
oPrint:Box(2075, 1185, 2162, 1562)
oPrint:Say(2095, 1245, STR0096, oFont02n,,,, 2) //"TIPO"
//Box OE
oPrint:Box(2075, 1562, 2162, 1652)
oPrint:Say(2095, 1607, STR0066, oFont02n,,,, 2) //"OE"
//Box OD
oPrint:Box(2075, 1652, 2162, 1742)
oPrint:Say(2095, 1697, STR0065, oFont02n,,,, 2) //"OD"

//Box Tipo - Linhas 1 a 4
//Box Retroauricular - Linha 1
oPrint:Box(2162, 1185, 2255, 1562)
oPrint:Say(2192, 1215, STR0108, oFont04) //"Retroauricular"
//Boxes
oPrint:Box(2162, 1562, 2255, 1652)
oPrint:Box(2162, 1652, 2255, 1742)

//Box Intra auricular - Linha 2
oPrint:Box(2255, 1185, 2348, 1562)
oPrint:Say(2285, 1215, STR0109, oFont04) //"Intra auricular"
//Boxes
oPrint:Box(2255, 1562, 2348, 1652)
oPrint:Box(2255, 1652, 2348, 1742)

//Box Micro canal - Linha 3
oPrint:Box(2348, 1185, 2441, 1562)
oPrint:Say(2378, 1215, STR0110, oFont04) //"Micro canal"
//Boxes
oPrint:Box(2348, 1562, 2441, 1652)
oPrint:Box(2348, 1652, 2441, 1742)

//Box Intra canal - Linha 4
oPrint:Box(2441, 1185, 2534, 1562)
oPrint:Say(2471, 1215, STR0111, oFont04) //"Intra canal"
//Boxes
oPrint:Box(2441, 1562, 2533, 1652)
oPrint:Box(2441, 1652, 2533, 1742)




//Box Tecnologia
oPrint:Box(2075, 1752, 2533, 2280)
 
//Box Grau - Cabecalho
oPrint:Box(2075, 1752, 2162, 2100)
oPrint:Say(2095, 1772, STR0112, oFont02n) //"TECNOLOGIA" 
//Box OE
oPrint:Box(2075, 2100, 2162, 2190)
oPrint:Say(2095, 2149, STR0066, oFont02n,,,, 2) //"OE"
//Box OD
oPrint:Box(2075, 2190, 2162, 2280)
oPrint:Say(2095, 2235, STR0065, oFont02n,,,, 2) //"OD"
                     

//Box Tenologia - Linhas 1 a 4
//Box Tipo A - Linha 1
oPrint:Box(2162, 1752, 2255, 2100)
oPrint:Say(2192, 1772, STR0113, oFont04) //"Tipo A"
//Boxes
oPrint:Box(2162, 2100, 2255, 2190)
oPrint:Box(2162, 2190, 2255, 2280)

//Box Tipo B - Linha 2
oPrint:Box(2255, 1752, 2348, 2100)
oPrint:Say(2285, 1772, 	STR0114, oFont04) //"Tipo B"
//Boxes
oPrint:Box(2255, 2100, 2348, 2190)
oPrint:Box(2255, 2190, 2348, 2280)

//Box Tipo C - Linha 3
oPrint:Box(2348, 1752, 2441, 2100)
oPrint:Say(2378, 1772, STR0115, oFont04) //"Tipo C"
//Boxes
oPrint:Box(2348, 2100, 2441, 2190)
oPrint:Box(2348, 2190, 2441, 2280)

//Box Via Ossea - Linha 4
oPrint:Box(2441, 1752, 2534, 2100)
oPrint:Say(2471, 1772, STR0116, oFont04) //"Via Óssea"
//Boxes
oPrint:Box(2441, 2100, 2533, 2190)
oPrint:Box(2441, 2190, 2533, 2280)




//Box Motivo de Reposicao AASI  
oPrint:Box(2650, 0050, 2860, 2290)
oPrint:Say(2655, 0060, STR0117, oFont06n) //"Motivo de reposição de AASI"
//Box Roubo (anexar boletim de ocorrencia)
oPrint:Box(2705, 0070, 2765, 0130)
oPrint:Say(2715, 0140, STR0118, oFont04) //"Roubo (anexar boletim de ocorrência)"

//Box Falha tecnica do AASI (findo o prazo de garantia)
oPrint:Box(2705, 1100, 2765, 1160)
oPrint:Say(2715, 1170, STR0119, oFont04) //"Falha técnica do AASI (findo o prazo de garantia)"

//Linha 2
//Box Perda auditiva progressiva (anexar exame(s))
oPrint:Box(2785, 0070, 2845, 0130)
oPrint:Say(2800, 0140, STR0120, oFont04) //"Perda auditiva progressiva (anexar exame(s))"



                                                  

//Box Assinatura e Carimbo
oPrint:Box(2900, 0020, 3190, 2320)
oPrint:Say(2900, 1100, STR0121, oFont02n,,,, 2) //"ASSINATURA E CARIMBO"    

//Linha1
//Box CPF do OTORRINOLARINGOLOGISTA / FONOAUDIOLOGO     
oPrint:Box(2950, 0040, 3060, 1170)
oPrint:Say(2950, 0050, STR0122, oFont06n) //"CPF do OTORRINOLARINGOLOGISTA / FONOAUDIÓLOGO"
hs_boxProc(2990, 0090,oPrint,11,60,92,Repl(" ",11),oFont05) 

//Box Nome     
oPrint:Box(2950, 1180, 3060, 2310)
oPrint:Say(2950, 1190, STR0034, oFont06n) //"Nome"

//Linha2
//Data
oPrint:Box(3070, 0040, 3180, 0770) 
oPrint:Say(3070, 0050, STR0123, oFont06n) //"Data"

oPrint:Line(3150,0150,3150,0650)
oPrint:Line(3150,0275,3100,0300)
oPrint:Line(3150,0400,3100,0425)


//Box OTORRINOLARINGOLOGISTA / FONOAUDIOLOGO 
oPrint:Box(3070, 0780, 3180, 2310)
oPrint:Say(3070, 0790, STR0124, oFont06n) //"OTORRINOLARINGOLOGISTA / FONOAUDIÓLOGO"





	
// Finaliza a pagina		
oPrint:EndPage()
// Visualiza impressao grafica antes de imprimir	
oPrint:Preview()
