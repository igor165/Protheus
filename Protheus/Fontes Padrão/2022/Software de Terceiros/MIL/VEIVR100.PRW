#INCLUDE "veivr100.ch"
#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVR100  ³ Autor ³Ricardo Farinelli      ³ Data ³ 12/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao da Ficha de Check-list de Entrega                 ³±±
±±³Parametros³cNum    - Numero da OS ou Proposta (Opcional)               ³±±
±±³Descricao ³lResumo - Se linha para assinatura do cliente ou nao.       ³±±
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

Function VEIVR100(cNum,lResumo)

Local oPrint
Local i 	:= 1
Local lin 	:= 0
Default lResumo := .F.

Private oFont16, oFont08, oFont10,oFont10L, oFont07, oFont07L, oFont08L, oFont12 

If Valtype(cNum)=="U"
	Return
Endif	

Private cNumTra := cNum

oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)

If !VAH->(Dbseek(xFilial("VAH")+cNumTra))
	Return
Endif	
oPrint	:= TMSPrinter():New( OemToAnsi(STR0001)) //"Check-list de Entrega de Veiculo"
oPrint:Setup()
MontaRel(oPrint,@i,@lin,lResumo)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MONTAREL  ºAutor  ³Ricardo Farinelli   º Data ³  11/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao principal para confeccao do relatorio                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaRel(oPrint,i,lin,lResumo)

Cabecalho(oPrint,@i)  			// Funcao que monta o cabecalho
lin := Detail(oPrint,@i)  		// Funcao que monta o cabecalho
If lin > 2700				// Espaco minimo para colocacao do rodape	
	i++
	oPrint:EndPage() 		// Finaliza a pagina
	Cabecalho(oPrint,@i)
	lin := 330
Endif
If lResumo
	Resumo(oPrint,@i,@lin) // imprime o resumo da avaliacao
Endif
oPrint:Preview()  				// Visualiza antes de imprimir

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cabecalho³ Autor ³ Ricardo Farinelli     ³ Data ³ 11/01/02 ³±±
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
Local cChave:= ""
If File(cFig+"LGRL"+cEmpAnt+cFilAnt+".BMP")
	cFig +="LGRL"+cEmpAnt+cFilAnt+".BMP"
Elseif File(cFig+"LGRL"+cEmpAnt+".BMP")
	cFig +="LGRL"+cEmpAnt+".BMP"
Else
	cFig +="LGRL.BMP"
Endif
oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(20,30,cFig ,250,80)

oPrint:Say(075,850,STR0002,oFont16)  //"CHECK-LIST DE ENTREGA"

oPrint:Box( 150, 30, 310, 2350 )

SA1->(DbsetOrder(1))
If Left(cNumTra,2)#STR0003 //"OS"
	VV0->(Dbseek(xFilial("VV0")+cNumTra))
	cChave := VV0->(VV0_CODCLI+VV0_LOJA)
	VVA->(Dbseek(xFilial("VVA")+cNumTra))
	cChaveVei:= VVA->VVA_CHAINT
Else
	VO1->(Dbseek(xFilial("VV1")+Right(cNumTra,8)))
	cChave := VV1->(VV1_PROATU+VV1_LJPATU)	
	cChaveVei := VV1->VV1_CHAINT
Endif	
VAH->(Dbseek(xFilial("VAH")+cNumTra))
SA1->(Dbseek(xFilial("SA1")+cChave))
VV1->(Dbseek(xFilial("VV1")+cChaveVei))
VE1->(DbsetOrder(1))
VE1->(Dbseek(xFilial("VE1")+VV1->VV1_CODMAR))
VV2->(Dbseek(xFilial("VV2")+VV1->(VV1_CODMAR+VV1_MODVEI)))

// 1a Linha
oPrint:Say(160,0040,STR0004,oFont08 )  //"Documento"
oPrint:Say(160,0425,STR0005,oFont08) //"Tipo"
oPrint:Say(160,1010,STR0006,oFont08 )  //"Data"
oPrint:Say(160,1590,STR0007,oFont08 ) //"Empresa"
oPrint:Say(160,2160,STR0008,oFont08 )  //"Pagina"

oPrint:Say(190,0040,VAH->VAH_NUMTRA,oFont10)
oPrint:Say(190,0425,Iif(Left(cNumtra,2)#STR0003,STR0009,STR0010),oFont10) //"OS"###"Entrega de Veículo Vendido"###"Entrega de Veículo Oficina"
oPrint:Say(190,1010,Dtoc(dDataBase),oFont10)
oPrint:Say(190,1590,SM0->M0_NOME,oFont10)
oPrint:Say(190,2160,STRZERO(i,2),oFont10)

// 2a Linha

oPrint:Say(240,0040,STR0011,oFont08 )  //"Marca"
oPrint:Say(240,0425,STR0012,oFont08 )  //"Modelo"
oPrint:Say(240,1010,STR0013,oFont08 )  //"Modelo/Fabricação"
oPrint:Say(240,1280,STR0014,oFont08 )  //"Combustível"
oPrint:Say(240,1595,STR0015,oFont08 ) //"Cliente"

oPrint:Say(270,0040,VV2->VV2_CODMAR+" - "+VE1->VE1_DESMAR,oFont10)
oPrint:Say(270,0425,VV2->VV2_MODVEI+" - "+Subs(VV2->VV2_DESMOD,1,15),oFont08)
oPrint:Say(270,1010,Transform(VV1->VV1_FABMOD,"@R ####/####"),oFont10)
oPrint:Say(270,1280,X3Combo(STR0016,VV1->VV1_COMVEI),oFont10) //"VV1_COMVEI"
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
±±³Funcao    ³ Detail   ³ Autor ³ Ricardo Farinelli     ³ Data ³ 11/01/02 ³±±
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

// Construcao da grade
oPrint:Box(lin,0030,lin+140,2350)
lin+=10
oPrint:Say(lin,1150,STR0017,oFont10N) //"Tarefas"
lin+=60
oPrint:Line(lin,0030,lin,2350)
oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
oPrint:Line( lin, 1490, lin+70, 1490 )   	// vertical
lin+=10
oPrint:Say(lin,0040,STR0018,oFont08) //"Tarefa"
oPrint:Say(lin,0180,STR0019,oFont08)  //"Descricao"
oPrint:Say(lin,1500,STR0020,oFont08)  //"Status"

lin+=60
Do While VAH->(VAH_FILIAL+VAH_NUMTRA) == xFilial("VAH")+cNumTra .and. !VAH->(Eof())

	VAF->(Dbseek(xFilial("VAF")+VAH->VAH_CODIGO))
	// 13/08/2009 - Rubens	
	// Nao imprime ocorrencia de check list marcada para nao imprimir
	IF VAF->VAF_LIBIMP == "0"
		VAH->(DbSkip())
		Loop
	ENDIF

	oPrint:Say(lin,0040,VAH->VAH_CODIGO,oFont10)

	oPrint:Say(lin,0180,VAF->VAF_DESCRI,oFont10)
	oPrint:Say(lin,1500,Iif(Trim(VAH->VAH_LIBST)=="1",STR0021,STR0022)) //"Sim"###"Nao"
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
		oPrint:Say(lin,1150,STR0017,oFont10N) //"Tarefas"
		lin+=60
		oPrint:Line(lin,0030,lin,2350)
		oPrint:Line( lin, 0170, lin+70, 0170 )   	// vertical
		oPrint:Line( lin, 1490, lin+70, 1490 )   	// vertical
		lin+=10
		oPrint:Say(lin,0040,STR0018,oFont08) //"Tarefa"
		oPrint:Say(lin,0180,STR0019,oFont08)  //"Descricao"
		oPrint:Say(lin,1500,STR0020,oFont08)  //"Status"
	
		lin+=60
	Endif
	VAH->(Dbskip())
Enddo	
oPrint:Line(lin,0030,lin,2350)			
lin+=80

Return lin

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESUMO    ºAutor  ³Ricardo Farinelli   º Data ³  11/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o Resumo do Check-List                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Resumo(oPrint,i,lin)

oPrint:Box(lin,650,lin+70,1150)
oPrint:Say(lin+10,660,STR0015,oFont08)  //"Cliente"
oPrint:Box(lin,1220,lin+70,1720)
oPrint:Say(lin+10,1230,Trim(SM0->M0_NOME)+":",oFont08)

Return lin 