#INCLUDE "VEIVR110.ch"
#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVR110  ³ Autor ³Ricardo Farinelli      ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao da Ficha de Avaliacao de veiculos Usados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao de Concessionarias                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function VEIVR110()

Local oPrint
Local i 	:= 1
Local lin 	:= 0

Private oFont16, oFont08, oFont10,oFont10L, oFont07, oFont07L, oFont08L, oFont12 

oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont08L	:= TFont():New("MS LineDraw",08,08,,.F.,,,,.T.,.F.)
oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
oFont07L	:= TFont():New("MS LineDraw",07,07,,.F.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10L	:= TFont():New("MS LineDraw",10,10,,.F.,,,,.T.,.F.)
oFont12	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)

If !VA7->(Dbseek(xFilial("VA7")+M->VA7_CODAVA))
	MsgStop(STR0001) //"Avaliacao ainda nao foi gravada"
	Return
Endif	
oPrint	:= TMSPrinter():New( OemToAnsi(STR0002) ) //"Avaliacao de Veiculos"
oPrint:Setup()

MontaRel(oPrint,@i,@lin)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MONTAREL  ºAutor  ³Ricardo Farinelli   º Data ³  11/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao principal para confeccao do relatorio                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaRel(oPrint,i,lin)

Cabecalho(oPrint,@i)  			// Funcao que monta o cabecalho
lin := Detail(oPrint,@i)  		// Funcao que monta o cabecalho
If lin > 2700				// Espaco minimo para colocacao do rodape	
	i++
	oPrint:EndPage() 		// Finaliza a pagina
	Cabecalho(oPrint,@i)
	lin := 330
Endif
Resumo(oPrint,@i,@lin) // imprime o resumo da avaliacao

oPrint:Preview()  				// Visualiza antes de imprimir

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cabecalho³ Autor ³ Ricardo Farinelli     ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho do relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cabecalho(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Capabili                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Cabecalho(oPrint,i)
Local cFig := GetSrvProfString("StartPath","")
If File(cFig+"LGRL"+cEmpAnt+cFilAnt+".BMP")
	cFig +="LGRL"+cEmpAnt+cFilAnt+".BMP"
Elseif File(cFig+"LGRL"+cEmpAnt+".BMP")
	cFig +="LGRL"+cEmpAnt+".BMP"
Else
	cFig +="LGRL.BMP"
Endif
oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(20,30,cFig ,250,80)

oPrint:Say(075,750,STR0003,oFont16 ) //"AVALIAÇÃO DE VEÍCULOS USADOS"

oPrint:Box( 150, 30, 310, 2350 )

SA1->(DbsetOrder(1))
SA1->(Dbseek(xFilial("SA1")+VA7->(VA7_CODCLI+VA7_LOJA)))
VE1->(DbsetOrder(1))
VE1->(Dbseek(xFilial("VE1")+VA7->VA7_MARCA))
VV2->(Dbseek(xFilial("VV2")+VA7->(VA7_MARCA+VA7_MODVEI)))

// 1a Linha
oPrint:Say(160,0040,STR0004,oFont08 ) //"Numero Avaliação"
oPrint:Say(160,0425,STR0005,oFont08 ) //"Validade"
oPrint:Say(160,1010,STR0006,oFont08 ) //"Data"
oPrint:Say(160,1590,STR0007,oFont08 ) //"Empresa"
oPrint:Say(160,2160,STR0008,oFont08 ) //"Página"

oPrint:Say(190,0040,VA7->VA7_CODAVA,oFont10)
oPrint:Say(190,0425,StrZero(GETMV("MV_VALDAVA",,10),3)+STR0009,oFont10 ) //" dia(s)"
oPrint:Say(190,1010,Dtoc(VA7->VA7_DATA),oFont10)
oPrint:Say(190,1590,SM0->M0_NOME,oFont10)
oPrint:Say(190,2160,STRZERO(i,2),oFont10)

// 2a Linha
oPrint:Say(240,0040,STR0010,oFont08 ) //"Marca"
oPrint:Say(240,0425,STR0011,oFont08 ) //"Modelo"
oPrint:Say(240,1010,STR0012,oFont08 ) //"Modelo/Fabricação"
oPrint:Say(240,1280,STR0013,oFont08 ) //"Combustível"
oPrint:Say(240,1595,STR0014,oFont08 ) //"Cliente"

oPrint:Say(270,0040,VA7->VA7_MARCA+" - "+VE1->VE1_DESMAR,oFont10)
oPrint:Say(270,0425,VA7->VA7_MODVEI+" - "+Subs(VV2->VV2_DESMOD,1,15),oFont10)
oPrint:Say(270,1010,VA7->VA7_ANOMOD+"/"+VA7->VA7_ANOFAB,oFont10)
oPrint:Say(270,1280,X3Combo("VA7_COMBUS",VA7->VA7_COMBUS),oFont10)
oPrint:Say(270,1595,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME,oFont10)

// Construcao das linhas do cabecalho
// Primeira linha
oPrint:Line( 230,  30, 230, 2350 )   	// horizontoal
oPrint:Line( 150, 415, 310, 415 )   	// vertical
oPrint:Line( 150, 1000, 310, 1000 )   	// vertical
oPrint:Line( 150, 1575, 310, 1575 )   	// vertical
oPrint:Line( 150, 2150, 230, 2150 )   	// vertical

// Segunda Linha
oPrint:Line( 230, 1270, 310, 1270 )   	// vertical

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Detail   ³ Autor ³ Ricardo Farinelli     ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Itens do relatorio                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Detail(ExpO1,ExpN1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Capabili                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Detail(oPrint,i)
Local lin 	:= 330

VAC->(DbsetOrder(1))
If VAC->(Dbseek(xFilial("VAC")+VA7->VA7_CODAVA))
	// Construcao da grade
	oPrint:Box(lin,0030,lin+140,2350)
	lin+=10
	oPrint:Say(lin,950,STR0015,oFont12) //"Aparência Geral do Veículo"
	lin+=60
	oPrint:Line(lin,0030,lin,2350)
	oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
	oPrint:Line( lin, 1490, lin+70, 1490 )   	// vertical
	lin+=10
	oPrint:Say(lin,0040,STR0016,oFont08) //"Aparência"
	oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
	oPrint:Say(lin,1500,STR0018,oFont08) //"Nota"

	lin+=60
	Do While VAC->(VAC_FILIAL+VAC_CODAVA) == xFilial("VAC")+VA7->VA7_CODAVA .and. !VAC->(Eof())
		oPrint:Say(lin,0040,VAC->VAC_TIPAVA,oFont10)
		VA4->(DbSetOrder(1))
		VA4->(Dbseek(xFilial("VA4")+VAC->VAC_TIPAVA))
		oPrint:Say(lin,0180,VA4->VA4_DESCRI,oFont10)
		oPrint:Say(lin,1500,Iif(Trim(VAC->VAC_NOTA)=="1",STR0019,; //"Um"
									Iif(Trim(VAC->VAC_NOTA)=="2",STR0020,; //"Dois"
									Iif(Trim(VAC->VAC_NOTA)=="3",STR0021,; //"Três"
									Iif(Trim(VAC->VAC_NOTA)=="4",STR0022,; //"Quatro"
									Iif(Trim(VAC->VAC_NOTA)=="5",STR0023,; //"Cinco"
									Iif(Trim(VAC->VAC_NOTA)=="6",STR0024,; //"Seis"
									Iif(Trim(VAC->VAC_NOTA)=="7",STR0025,; //"Sete"
									Iif(Trim(VAC->VAC_NOTA)=="8",STR0026,; //"Oito"
									Iif(Trim(VAC->VAC_NOTA)=="9",STR0027,STR0028))))))))),oFont10) //"Nove"###"Dez"
		oPrint:Line( lin, 0030, lin+60, 0030 )   	// vertical
		oPrint:Line( lin, 0170, lin+60, 0170 )   	// vertical
		oPrint:Line( lin, 1490, lin+60, 1490 )   	// vertical
		oPrint:Line( lin, 2350, lin+60, 2350 )   	// vertical
		lin+=60
		If lin > 2700				// Espaco minimo para colocacao do rodape	
			i++
	  	   oPrint:Line(lin,0030,lin,2350)			
			oPrint:EndPage() 		// Finaliza a pagina
			Cabecalho(oPrint,@i)
			lin := 330
			oPrint:Box(lin,0030,lin+140,2350)
			lin+=10
			oPrint:Say(lin,950,STR0015,oFont12) //"Aparência Geral do Veículo"
			lin+=60
			oPrint:Line(lin,0030,lin,2350)
			oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
			oPrint:Line( lin, 1490, lin+70, 1490 )   	// vertical
			lin+=10
			oPrint:Say(lin,0040,STR0016,oFont08) //"Aparência"
			oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
			oPrint:Say(lin,1500,STR0018,oFont08) //"Nota"
			lin+=60
		Endif
		VAC->(Dbskip())
	Enddo	
   oPrint:Line(lin,0030,lin,2350)			
   lin+=80
Endif

VA9->(DbsetOrder(1))
If VA9->(Dbseek(xFilial("VA9")+VA7->VA7_CODAVA))
	// Construcao da grade
	oPrint:Box(lin,0030,lin+140,2350)
	lin+=10
	oPrint:Say(lin,0930,STR0029,oFont12) //"Opcionais contidos no Veículo"
	lin+=60
	oPrint:Line(lin,0030,lin,2350)
	oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
	oPrint:Line( lin, 1340, lin+70, 1340 )   	// vertical
	oPrint:Line( lin, 1690, lin+70, 1690 )   	// vertical
	lin+=10
	oPrint:Say(lin,0040,STR0030,oFont08) //"Código"
	oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
	oPrint:Say(lin,1350,STR0031,oFont08) //"Preço"
	oPrint:Say(lin,1700,STR0032,oFont08) //"Agrega Valor"
	
	lin+=60
	Do While VA9->(VA9_FILIAL+VA9_CODAVA) == xFilial("VA9")+VA7->VA7_CODAVA .and. !VA9->(Eof())
		oPrint:Say(lin,0040,VA9->VA9_CODOPC,oFont10)
		oPrint:Say(lin,0180,VA9->VA9_DESCRI,oFont10)
		oPrint:Say(lin,1400,Transform(VA9->VA9_PRECO,"@E 99999,999.99"),oFont10L)
		oPrint:Say(lin,1700,Iif(VA9->VA9_ITESER=="0",STR0033,STR0034),oFont10) //"Sim"###"Não"
		oPrint:Line( lin, 0030, lin+60, 0030 )   	// vertical
		oPrint:Line( lin, 0170, lin+60, 0170 )   	// vertical
		oPrint:Line( lin, 1340, lin+60, 1340 )   	// vertical
		oPrint:Line( lin, 1690, lin+60, 1690 )   	// vertical
		oPrint:Line( lin, 2350, lin+60, 2350 )   	// vertical
		lin+=60
		If lin > 2700				// Espaco minimo para colocacao do rodape	
			i++
	  	   oPrint:Line(lin,0030,lin,2350)			
			oPrint:EndPage() 		// Finaliza a pagina
			Cabecalho(oPrint,@i)
			lin := 330
			oPrint:Box(lin,0030,lin+140,2350)
			lin+=10
			oPrint:Say(lin,0930,STR0029,oFont12) //"Opcionais contidos no Veículo"
			lin+=60
			oPrint:Line(lin,0030,lin,2350)
			oPrint:Line( lin, 0170, lin+60, 0170 )   	// vertical
			oPrint:Line( lin, 1340, lin+60, 1340 )   	// vertical
			oPrint:Line( lin, 1690, lin+60, 1690 )   	// vertical
			lin+=10
			oPrint:Say(lin,0040,STR0030,oFont08) //"Código"
			oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
			oPrint:Say(lin,1350,STR0031,oFont08) //"Preço"
			oPrint:Say(lin,1700,STR0035,oFont08) //"Agrega"
			lin+=60
		Endif
		VA9->(Dbskip())
	Enddo	
   oPrint:Line(lin,0030,lin,2350)			
   lin+=80
Endif
	
VAD->(DbsetOrder(1))
If VAD->(Dbseek(xFilial("VAD")+VA7->VA7_CODAVA))
	// Construcao da grade
	oPrint:Box(lin,0030,lin+140,2350)
	lin+=10
	oPrint:Say(lin,0950,STR0036,oFont12) //"Ocorrências com o Veículo"
	lin+=60
	oPrint:Line(lin,0030,lin,2350)
	oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
	oPrint:Line( lin, 1340, lin+70, 1340 )   	// vertical
	oPrint:Line( lin, 1690, lin+70, 1690 )   	// vertical
	lin+=10
	oPrint:Say(lin,0040,STR0030,oFont08) //"Código"
	oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
	oPrint:Say(lin,1350,STR0031,oFont08) //"Preço"
	oPrint:Say(lin,1700,STR0037,oFont08) //"Tipo"
	
	lin+=60
	Do While VAD->(VAD_FILIAL+VAD_CODAVA) == xFilial("VAD")+VA7->VA7_CODAVA .and. !VAD->(Eof())
		oPrint:Say(lin,0040,VAD->VAD_CODIGO,oFont10)
		oPrint:Say(lin,0180,VAD->VAD_DESCRI,oFont10)
		oPrint:Say(lin,1400,Transform(VAD->VAD_VLRPEN,"@E 99999,999.99"),oFont10L)
		oPrint:Say(lin,1700,Iif(VAD->VAD_TIPPEN=="0",STR0038,; //"Somar"
									Iif(VAD->VAD_TIPPEN=="1",STR0039,STR0040)),oFont10) //"Subtrair"###"Informativo"
		oPrint:Line( lin, 0030, lin+60, 0030 )   	// vertical
		oPrint:Line( lin, 0170, lin+60, 0170 )   	// vertical
		oPrint:Line( lin, 1340, lin+60, 1340 )   	// vertical
		oPrint:Line( lin, 1690, lin+60, 1690 )   	// vertical
		oPrint:Line( lin, 2350, lin+60, 2350 )   	// vertical
		lin+=60
		If lin > 2700				// Espaco minimo para colocacao do rodape	
			i++
	  	   oPrint:Line(lin,0030,lin,2350)			
			oPrint:EndPage() 		// Finaliza a pagina
			Cabecalho(oPrint,@i)
			lin := 330
			oPrint:Box(lin,0030,lin+140,2350)
			lin+=10
			oPrint:Say(lin,0950,STR0036,oFont12) //"Ocorrências com o Veículo"
			lin+=60
			oPrint:Line(lin,0030,lin,2350)
			oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
			oPrint:Line( lin, 1340, lin+70, 1340 )   	// vertical
			oPrint:Line( lin, 1690, lin+70, 1690 )   	// vertical
			lin+=10
			oPrint:Say(lin,0040,STR0030,oFont08) //"Código"
			oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
			oPrint:Say(lin,1350,STR0031,oFont08) //"Preço"
			oPrint:Say(lin,1700,STR0037,oFont08) //"Tipo"
			
			lin+=60
		Endif
		VAD->(Dbskip())
	Enddo	
   oPrint:Line(lin,0030,lin,2350)			
   lin+=80
Endif

VAA->(DbsetOrder(1))
If VAA->(Dbseek(xFilial("VAA")+VA7->VA7_CODAVA))
	// Construcao da grade
	oPrint:Box(lin,0030,lin+140,2350)
	lin+=10
	oPrint:Say(lin,0960,STR0041,oFont12) //"Check-List da Avaliação"
	lin+=60
	oPrint:Line(lin,0030,lin,2350)
	oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
	oPrint:Line( lin, 0790, lin+70, 0790 )   	// vertical
	oPrint:Line( lin, 0940, lin+70, 0940 )   	// vertical
	oPrint:Line( lin, 1560, lin+70, 1560 )   	// vertical
	oPrint:Line( lin, 1690, lin+70, 1690 )   	// vertical
	oPrint:Line( lin, 2170, lin+70, 2170 )   	// vertical
	lin+=10
	oPrint:Say(lin,0040,STR0042,oFont08) //"Grupo"
	oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
	oPrint:Say(lin,0800,STR0043,oFont08) //"Item"
	oPrint:Say(lin,0950,STR0017,oFont08) //"Descrição"
	oPrint:Say(lin,1570,STR0044,oFont08)		 //"Avaria"
	oPrint:Say(lin,1700,STR0017,oFont08) //"Descrição"
	oPrint:Say(lin,2180,STR0045,oFont08)	 //"Valor"
	lin+=60
	Do While VAA->(VAA_FILIAL+VAA_CODAVA) == xFilial("VAA")+VAA->VAA_CODAVA .and. !VAA->(Eof())
		oPrint:Say(lin,0040,VAA->VAA_CODGRU,oFont07)
		VA0->(DbsetOrder(1))
		VA0->(Dbseek(xFilial("VA0")+VAA->VAA_CODGRU))
		oPrint:Say(lin,0180,VA0->VA0_DESCRI,oFont07)
		oPrint:Say(lin,0800,VAA->VAA_ITEM,oFont07)
		VA0->(DbsetOrder(2))
		VA0->(Dbseek(xFilial("VA0")+VAA->(VAA_CODGRU+VAA_ITEM)))		
		oPrint:Say(lin,0950,VA0->VA0_DESCRI,oFont07)
		oPrint:Say(lin,1570,VAA->VAA_AVARIA,oFont07)
		VA4->(DbsetOrder(1))
		VA4->(Dbseek(xFilial("VA4")+VAA->VAA_AVARIA))		
		oPrint:Say(lin,1700,Substr(VA4->VA4_DESCRI,1,25),oFont07)
		oPrint:Say(lin,2180,Transform(VAA->VAA_VALOR,"@E 999,999.99"),oFont07L)
		oPrint:Line( lin, 0030, lin+60, 0030 )   	// vertical
		oPrint:Line( lin, 0170, lin+60, 0170 )   	// vertical
		oPrint:Line( lin, 0790, lin+60, 0790 )   	// vertical
		oPrint:Line( lin, 0940, lin+60, 0940 )   	// vertical
		oPrint:Line( lin, 1560, lin+60, 1560 )   	// vertical
		oPrint:Line( lin, 1690, lin+60, 1690 )   	// vertical
		oPrint:Line( lin, 2170, lin+60, 2170 )   	// vertical
		oPrint:Line( lin, 2350, lin+60, 2350 )   	// vertical		
		lin+=60
		If lin > 2700				// Espaco minimo para colocacao do rodape	
			i++
	  	   oPrint:Line(lin,0030,lin,2350)			
			oPrint:EndPage() 		// Finaliza a pagina
			Cabecalho(oPrint,@i)
			lin := 330
			oPrint:Box(lin,0030,lin+140,2350)
			lin+=10
			oPrint:Say(lin,0960,STR0041,oFont12) //"Check-List da Avaliação"
			lin+=60
			oPrint:Line(lin,0030,lin,2350)
			oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
			oPrint:Line( lin, 0790, lin+70, 0790 )   	// vertical
			oPrint:Line( lin, 0940, lin+70, 0940 )   	// vertical
			oPrint:Line( lin, 1560, lin+70, 1560 )   	// vertical
			oPrint:Line( lin, 1690, lin+70, 1690 )   	// vertical
			oPrint:Line( lin, 2170, lin+70, 2170 )   	// vertical
			lin+=10
			oPrint:Say(lin,0040,STR0042,oFont08) //"Grupo"
			oPrint:Say(lin,0180,STR0017,oFont08) //"Descrição"
			oPrint:Say(lin,0790,STR0043,oFont08) //"Item"
			oPrint:Say(lin,0940,STR0017,oFont08) //"Descrição"
			oPrint:Say(lin,1570,STR0044,oFont08)		 //"Avaria"
			oPrint:Say(lin,1700,STR0017,oFont08) //"Descrição"
			oPrint:Say(lin,2180,STR0045,oFont08)	 //"Valor"
			lin+=60
		Endif
		VAA->(Dbskip())
	Enddo	
   oPrint:Line(lin,0030,lin,2350)			
   lin+=80
Endif

Return lin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESUMO    ºAutor  ³Ricardo Farinelli   º Data ³  10/31/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o Resumo da Avaliacao                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Resumo(oPrint,i,lin)

oPrint:Box(lin,30,lin+290,2350)
lin+=10
oPrint:Say(lin,1000,STR0046,oFont12) //"Resumo da Avaliação"
lin+=70
oPrint:Line(lin,30,lin,2350)
lin+=20
oPrint:Box(lin,80,lin+70,580)
oPrint:Say(lin+20,110,STR0047,oFont08) //"Preço Inicial"
oPrint:Say(lin+20,330,Transform(VA7->VA7_PREINI,"@E 999,999.99"),oFont10L)

oPrint:Box(lin,650,lin+70,1150)
oPrint:Say(lin+20,680,STR0048,oFont08) //"Preço Mínimo"
oPrint:Say(lin+20,900,Transform(VA7->VA7_PREMIN,"@E 999,999.99"),oFont10L)

oPrint:Box(lin,1220,lin+70,1720)
oPrint:Say(lin+20,1250,STR0049,oFont08) //"Preço Tabela"
oPrint:Say(lin+20,1470,Transform(VA7->VA7_PRETAB,"@E 999,999.99"),oFont10L)

oPrint:Box(lin,1790,lin+70,2290)
oPrint:Say(lin+20,1820,STR0050,oFont08) //"Preço Opcs (+)"
oPrint:Say(lin+20,2040,Transform(VA7->VA7_PREOPC,"@E 999,999.99"),oFont10L)

lin+=100

oPrint:Box(lin,80,lin+70,580)
oPrint:Say(lin+20,110,STR0051,oFont08) //"Preço Avarias (-)"
oPrint:Say(lin+20,330,Transform(VA7->VA7_PREAVA,"@E 999,999.99"),oFont10L)

oPrint:Box(lin,650,lin+70,1150)
oPrint:Say(lin+20,680,STR0052,oFont08) //"Preço Ocorr. (+)"
oPrint:Say(lin+20,900,Transform(VA7->VA7_PREOC1,"@E 999,999.99"),oFont10L)

oPrint:Box(lin,1220,lin+70,1720)
oPrint:Say(lin+20,1250,STR0053,oFont08) //"Preço Ocorr. (-)"
oPrint:Say(lin+20,1470,Transform(VA7->VA7_PREOC2,"@E 999,999.99"),oFont10L)

oPrint:Box(lin,1790,lin+70,2290)
oPrint:Say(lin+20,1820,STR0054,oFont08) //"Preço Sugerido"
oPrint:Say(lin+20,2040,Transform(VA7->VA7_PREPAG,"@E 999,999.99"),oFont10L)

lin+=150

oPrint:Box(lin,650,lin+70,1150)
oPrint:Say(lin+10,660,STR0055,oFont08) //"Cliente:"
oPrint:Box(lin,1220,lin+70,1720)
oPrint:Say(lin+10,1230,Trim(SM0->M0_NOME)+":",oFont08)

Return lin 
