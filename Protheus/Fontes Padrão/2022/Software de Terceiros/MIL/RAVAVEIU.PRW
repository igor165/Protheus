// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º  03    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RAVAVEIU  ³ Autor ³Thiago				    ³ Data ³ 17/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamado   ³000407									                  ³±±
±±³Descricao ³Impressao da avalicao de veiculo usado                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RAVAVEIU()

Local oPrint
Local i 	:= 1
Local lin 	:= 0
Private aImpCpo := {}
Private oFont16, oFont08, oFont10,oFont07, oFont12 , oFont06,oFont12w

oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont06	:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont12	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)

dbSelectArea("SX3")
dbSetOrder(1)
Dbseek("VAZ")
While !Eof() .And. (SX3->X3_ARQUIVO == "VAZ")
	IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		AADD(aImpCpo,{ Alltrim(SX3->X3_CAMPO) , Alltrim(SX3->X3_TITULO) })
	EndIf
	dbSelectArea("SX3")		
	dbSkip()
EndDo

//If !VAZ->(Dbseek(xFilial("VAZ")+M->VAZ_CHASSI))
//	MsgStop("Avaliação ainda nao foi gravado") //"Avaliação ainda nao foi gravado"
//	Return
//Endif	
oPrint	:= TMSPrinter():New( OemToAnsi("Avaliação de veiculo usado") ) //"Avaliação de veiculo usado"
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

oPrint:Say(075,900,"AVALIAÇÃO DE VEÍCULO USADO",oFont16 ) //"CHECKLIST DE VEÍCULOS (OFICINA)"

oPrint:Box( 150, 30, 310, 2350 )

dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+VAZ->VAZ_CHASSI)

dbSelectArea("VV2")
dbSetOrder(1)
dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)

dbSelectArea("VE1")
dbSetOrder(1)
dbSeek(xFilial("VE1")+VV1->VV1_CODMAR)

dbSelectArea("VVC")
dbSetOrder(1)
dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+VAZ->VAZ_CODCLI+VAZ->VAZ_LOJCLI)

// 1a Linha       

oPrint:Say(160,0040,"Chassi",oFont08 )
oPrint:Say(160,0555,"Marca",oFont08 ) 
oPrint:Say(160,1060,"Dt.Avaliação",oFont08 ) 
oPrint:Say(160,1290,"Cod.Avaliação",oFont08 ) 
oPrint:Say(160,1640,"Modelo",oFont08 ) 
  //
oPrint:Say(190,0040,VAZ->VAZ_CHASSI,oFont10)
oPrint:Say(190,0555,VAZ->VAZ_CODMAR+" - "+VE1->VE1_DESMAR,oFont10 )
oPrint:Say(190,1060,Dtoc(VAZ->VAZ_DATAVA),oFont10)
oPrint:Say(190,1290,VAZ->VAZ_CODIGO,oFont10)
oPrint:Say(190,1640,VAZ->VAZ_MODVEI+" - "+VV2->VV2_DESMOD,oFont10)
//                     

//// 2a Linha

oPrint:Say(240,040,"Cliente",oFont08 ) 
oPrint:Say(240,860,"Ano Fab/Mod",oFont08 )
oPrint:Say(240,1083,"Combustível",oFont08 ) 
oPrint:Say(240,1470,"Qtd.Portas",oFont08 ) 
oPrint:Say(240,1660,"Placa",oFont08 )
oPrint:Say(240,1860,"Nro Certificado",oFont08 )
oPrint:Say(240,2110,"Kilometragem",oFont08 ) 

oPrint:Say(270,040,VAZ->VAZ_CODCLI+"/"+VAZ->VAZ_LOJCLI+" - "+SA1->A1_NOME,oFont10)
oPrint:Say(270,860,VAZ->VAZ_FABMOD,oFont10)  
if VAZ->VAZ_COMVEI == "0"
   cComvei := "Gasolina"
Elseif VAZ->VAZ_COMVEI == "1"
   cComvei := "Alcool"
Elseif VAZ->VAZ_COMVEI == "2"
   cComvei := "Diesel"
Elseif VAZ->VAZ_COMVEI == "3"
   cComvei := "Gas Natural"
Elseif VAZ->VAZ_COMVEI == "4"
   cComvei := "Alcool/Gasolina"
Elseif VAZ->VAZ_COMVEI == "5"
   cComvei := "Alcool/Gasolina/GNV"
Else
   cComvei := "Sem Combustível"
Endif   
oPrint:Say(270,1083,cComvei,oFont10)
oPrint:Say(270,1510,VAZ->VAZ_QTDPOR,oFont10)
oPrint:Say(270,1660,VAZ->VAZ_PLAVEI,oFont10)
oPrint:Say(270,1860,VAZ->VAZ_CERTIF,oFont10)
oPrint:Say(270,2110,Alltrim(str(VAZ->VAZ_KILVEI)),oFont10)

// Construcao das linhas do cabecalho
// Primeira linha
oPrint:Line( 230,  30, 230, 2350 )   	// horizontoal
oPrint:Line( 150, 550, 230, 550 )   	// vertical
oPrint:Line( 150, 1050, 230, 1050 )   	// vertical
oPrint:Line( 150, 1275, 230, 1275 )   	// vertical
oPrint:Line( 150, 1630, 230, 1630 )   	// vertical
//
//// Segunda Linha
oPrint:Line( 230, 850, 310, 850 )   	// vertical
oPrint:Line( 230, 1075, 310, 1075 )   	// vertical
oPrint:Line( 230, 1455, 310, 1455 )   	// vertical
oPrint:Line( 230, 1650, 310, 1650 )   	// vertical
oPrint:Line( 230, 1850, 310, 1850 )   	// vertical
oPrint:Line( 230, 2100, 310, 2100 )   	// vertical

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
Local lin  := 330
Local nPos := 0

// Construcao da grade
oPrint:Box(lin,0030,lin+70,2350)
lin+=10
oPrint:Say(lin,1050,"Opcionais do Veículo",oFont12) //"Check-List Itens do Veículo"
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_LATDIR" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) //"Possui Estepe: "  
	if VAZ->VAZ_LATDIR == "1"
	   cLatDir := "Sem detalhes"
	Elseif VAZ->VAZ_LATDIR == "2"
	   cLatDir := "Riscado"
	Elseif VAZ->VAZ_LATDIR == "3"
	   cLatDir := "Amassado"
	Elseif VAZ->VAZ_LATDIR == "4"
	   cLatDir := "Riscado/Amassado"
	Else
	   cLatDir := ""
	Endif
	oPrint:Say(lin+20,0240,cLatDir,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_LATESQ" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) //"Possui Toca CD: "
	if VAZ->VAZ_LATESQ == "1"
	   cLatEsq := "Sem detalhes"
	Elseif VAZ->VAZ_LATESQ == "2"
	   cLatEsq := "Riscado"
	Elseif VAZ->VAZ_LATESQ == "3"
	   cLatEsq := "Amassado"
	Elseif VAZ->VAZ_LATESQ == "4"
	   cLatEsq := "Riscado/Amassado"
	Else
	   cLatEsq := ""
	Endif
	oPrint:Say(lin+20,1040,cLatEsq,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_LATFRE" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) //"Possui Toca-Fitas: "
	if VAZ->VAZ_LATFRE == "1"
	   cLatFre := "Sem detalhes"
	Elseif VAZ->VAZ_LATFRE == "2"
	   cLatFre := "Riscado"
	Elseif VAZ->VAZ_LATFRE == "3"
	   cLatFre := "Amassado"
	Elseif VAZ->VAZ_LATFRE == "4"
	   cLatFre := "Riscado/Amassado"
	Else
	   cLatFre := ""
	Endif
	oPrint:Say(lin+20,1900,cLatFre,oFont10) //"Sim"###"Nao"
EndIf
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_LATTRA" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) //"Frente Som Removível: "
	if VAZ->VAZ_LATTRA == "1"
	   cLatTra := "Sem detalhes"
	Elseif VAZ->VAZ_LATTRA == "2"
	   cLatTra := "Riscado"
	Elseif VAZ->VAZ_LATTRA == "3"
	   cLatTra := "Amassado"
	Elseif VAZ->VAZ_LATTRA == "4"
	   cLatTra := "Riscado/Amassado"
	Else
	   cLatTra := ""
	Endif
	oPrint:Say(lin+20,0240,cLatTra,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_LATTET" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) //"Possui Módulo Som: "
	if VAZ->VAZ_LATTET == "1"
	   cLatTeto := "Sem detalhes"
	Elseif VAZ->VAZ_LATTET == "2"
	   cLatTeto := "Riscado"
	Elseif VAZ->VAZ_LATTET == "3"
	   cLatTeto := "Amassado"
	Elseif VAZ->VAZ_LATTET == "4"
	   cLatTeto := "Riscado/Amassado"
	Else
	   cLatTeto := ""
	Endif
	oPrint:Say(lin+20,1040,cLatTeto,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_MECMOT" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) //"Possui Triângulo: "
	if VAZ->VAZ_MECMOT == "1"
	   cMecMot := "Ok"
	Elseif VAZ->VAZ_MECMOT == "2"
	   cMecMot := "Necessario Manutenção"
	Else
	   cMecMot := ""
	Endif
	oPrint:Say(lin+20,1900,cMecMot,oFont10) //"Sim"###"Nao"
EndIf
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_MECCAM" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) //"Possui DVD: "
	if VAZ->VAZ_MECCAM == "1"
	   cMecCam := "Ok"
	Elseif VAZ->VAZ_MECCAM == "2"
	   cMecCam := "Necessario Manutenção"
	Else
	   cMecCam := ""
	Endif
	oPrint:Say(lin+20,0240,cMecCam,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_MECSUS" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) //"Roda Liga-Leve: "
	if VAZ->VAZ_MECSUS == "1"
	   cMecSus := "Ok"
	Elseif VAZ->VAZ_MECSUS == "2"
	   cMecSus := "Necessario Manutenção"
	Else
	   cMecSus := ""
	Endif
	oPrint:Say(lin+20,1040,cMecSus,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_PDIDIR" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) //"Possui Antena Externa: "
	if VAZ->VAZ_PDIDIR == "1"
	   cPdidir := "0%"
	Elseif VAZ->VAZ_PDIDIR == "2"
	   cPdidir := "25%"
	Elseif VAZ->VAZ_PDIDIR == "3"
	   cPdidir := "50%"
	Elseif VAZ->VAZ_PDIDIR == "4"
	   cPdidir := "75%"
	Elseif VAZ->VAZ_PDIDIR == "5"
	   cPdidir := "100%"
	Else
	   cPdidir := ""
	Endif
	oPrint:Say(lin+20,1900,cPdidir,oFont10) //"Sim"###"Nao"
EndIf   
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_PDIESQ" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) //"Disqueteira CD: "
	if VAZ->VAZ_PDIESQ == "1"
	   cPdiEsq := "0%"
	Elseif VAZ->VAZ_PDIESQ == "2"
	   cPdiEsq := "25%"
	Elseif VAZ->VAZ_PDIESQ == "3"
	   cPdiEsq := "50%"
	Elseif VAZ->VAZ_PDIESQ == "4"
	   cPdiEsq := "75%"
	Elseif VAZ->VAZ_PDIESQ == "5"
	   cPdiEsq := "100%"
	Else
	   cPdiEsq := ""
	Endif
	oPrint:Say(lin+20,0240,cPdiEsq,oFont10) //"Sim"###"Nao"
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_PTRDIR" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_PTRDIR == "1"
	   cPTrDir := "0%"
	Elseif VAZ->VAZ_PTRDIR == "2"
	   cPTrDir := "25%"
	Elseif VAZ->VAZ_PTRDIR == "3"
	   cPTrDir := "50%"
	Elseif VAZ->VAZ_PTRDIR == "4"
	   cPTrDir := "75%"
	Elseif VAZ->VAZ_PTRDIR == "5"
	   cPTrDir := "100%"
	Else
	   cPTrDir := ""
	Endif
	oPrint:Say(lin+20,1040,cPTrDir,oFont10) 
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_PTRESQ" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_PTRESQ == "1"
	   cPTREsq := "0%"
	Elseif VAZ->VAZ_PTRESQ == "2"
	   cPTREsq := "25%"
	Elseif VAZ->VAZ_PTRESQ == "3"
	   cPTREsq := "50%"
	Elseif VAZ->VAZ_PTRESQ == "4"
	   cPTREsq := "75%"
	Elseif VAZ->VAZ_PTRESQ == "5"
	   cPTREsq := "100%"
	Else
	   cPTREsq := ""
	Endif
	oPrint:Say(lin+20,1900,cPTREsq,oFont10)
EndIf
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEDIR" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08)     
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_ACEDIR =="0","Nao","Sim"),oFont10) 
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEARC" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1040,Iif(VAZ->VAZ_ACEARC =="0","Nao","Sim"),oFont10)
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEBAG" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) //"Possui Triângulo: "
	oPrint:Say(lin+20,1900,Iif(VAZ->VAZ_ACEBAG =="0","Nao","Sim"),oFont10) //"Sim"###"Nao"
EndIf
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACECOU" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08)     
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_ACECOU =="0","Nao","Sim"),oFont10) 
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEARC" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1040,Iif(VAZ->VAZ_ACEARC =="0","Nao","Sim"),oFont10)
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEAUT" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) //"Possui Triângulo: "
	oPrint:Say(lin+20,1900,Iif(VAZ->VAZ_ACEAUT =="0","Nao","Sim"),oFont10) //"Sim"###"Nao"
EndIf
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEROD" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08)     
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_ACEROD =="0","Nao","Sim"),oFont10) 
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACESOM" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1040,Iif(VAZ->VAZ_ACESOM =="0","Nao","Sim"),oFont10)
EndIf
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ACEABS" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) //"Possui Triângulo: "
	oPrint:Say(lin+20,1900,Iif(VAZ->VAZ_ACEABS =="0","Nao","Sim"),oFont10) //"Sim"###"Nao"
EndIf

lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ESPELE" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_ESPELE =="0","Nao","Sim"),oFont10) 
EndIf  
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_TRVELE" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08)
	oPrint:Say(lin+20,1040,Iif(VAZ->VAZ_TRVELE =="0","Nao","Sim"),oFont10) 
EndIf     
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_VDRELE" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1900,Iif(VAZ->VAZ_VDRELE =="0","Nao","Sim"),oFont10)
EndIf       
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_MANREV" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_MANREV =="0","Nao","Sim"),oFont10) 
EndIf  
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ALTFAL" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1040,Iif(VAZ->VAZ_ALTFAL =="0","Nao","Sim"),oFont10) 
EndIf     
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_TRIANG" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1900,Iif(VAZ->VAZ_TRIANG =="0","Nao","Sim"),oFont10) 
EndIf       
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_EXTINT" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_EXTINT =="0","Nao","Sim"),oFont10)
EndIf  
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_FERRAM" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1040,Iif(VAZ->VAZ_FERRAM =="0","Nao","Sim"),oFont10) 
EndIf     
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_CHARES" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,1900,Iif(VAZ->VAZ_CHARES =="0","Nao","Sim"),oFont10) 
EndIf       
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_MECEMB" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08)  
	if VAZ->VAZ_MECEMB == "1"
	   cMecEmb := "Ok"
	Elseif VAZ->VAZ_MECEMB == "2"
	   cMecEmb := "Necessario Manutenção"
	Else
	   cMecEmb := ""
	Endif
	oPrint:Say(lin+20,0240,cMecEmb,oFont10) 
EndIf  
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_MECDIR" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_MECDIR == "1"
	   cMecDir := "Ok"
	Elseif VAZ->VAZ_MECDIR == "2"
	   cMecDir := "Necessario Manutenção"
	Else
	   cMecDir := ""
	Endif
	oPrint:Say(lin+20,1040,cMecDir,oFont10) 
EndIf     
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_FREIOS" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_FREIOS == "1"
	   cFreios := "Ok"
	Elseif VAZ->VAZ_FREIOS == "2"
	   cFreios := "Necessario Manutenção"
	Else
	   cFreios := ""
	Endif
	oPrint:Say(lin+20,1900,cFreios,oFont10) 
EndIf       
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ESCAPA" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_ESCAPA == "1"
	   cEscapa := "Ok"
	Elseif VAZ->VAZ_ESCAPA == "2"
	   cEscapa := "Necessario Manutenção"
	Else
	   cEscapa := ""
	Endif
	oPrint:Say(lin+20,0240,cEscapa,oFont10) 
EndIf  
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_BANCOS" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_BANCOS == "1"
	   cBancos := "Ok"
	Elseif VAZ->VAZ_BANCOS == "2"
	   cBancos := "Necessario Manutenção"
	Else
	   cBancos := ""
	Endif
	oPrint:Say(lin+20,1040,cBancos,oFont10)
EndIf     
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_REVLAT" })
If nPos > 0
	oPrint:Box(lin,1640,lin+70,2350)
	oPrint:Say(lin+20,1650,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_REVLAT == "1"
	   cRevLat := "Ok"
	Elseif VAZ->VAZ_REVLAT == "2"
	   cRevLat := "Necessario Manutenção"
	Else
	   cRevLat := ""
	Endif
	oPrint:Say(lin+20,1900,cRevLat,oFont10) 
EndIf    
lin+=80
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_BAGAGE" })
If nPos > 0
	oPrint:Box(lin,0030,lin+70,740)
	oPrint:Say(lin+20,0040,aImpCpo[nPos,2]+":",oFont08) 
	oPrint:Say(lin+20,0240,Iif(VAZ->VAZ_BAGAGE =="0","Nao","Sim"),oFont10) 
EndIf  
nPos := aScan(aImpCpo,{|x| x[1] == "VAZ_ESTEPE" })
If nPos > 0
	oPrint:Box(lin,0820,lin+70,1550)
	oPrint:Say(lin+20,0830,aImpCpo[nPos,2]+":",oFont08) 
	if VAZ->VAZ_PDIDIR == "1"
	   cEstepe := "0%"
	Elseif VAZ->VAZ_PDIDIR == "2"
	   cEstepe := "25%"
	Elseif VAZ->VAZ_PDIDIR == "3"
	   cEstepe := "50%"
	Elseif VAZ->VAZ_PDIDIR == "4"
	   cEstepe := "75%"
	Elseif VAZ->VAZ_PDIDIR == "5"
	   cEstepe := "100%"
	Else
	   cEstepe := ""
	Endif
	oPrint:Say(lin+20,1040,cEstepe,oFont10) 
EndIf        
lin+=120
oPrint:Say(lin,1050,"Resultado da Avaliação",oFont12) //"Observações"
lin+=50

oPrint:Line(lin,0030,lin,2350)
oPrint:Line( lin, 030, lin+100, 030 )   	// vertical
oPrint:Line( lin, 0600, lin+100, 0600 )   	// vertical
oPrint:Line( lin, 1200, lin+100, 1200 )   	// vertical
oPrint:Line( lin, 1500, lin+100, 1500 )   	// vertical
oPrint:Line( lin, 1800, lin+100, 1800 )   	// vertical
oPrint:Line( lin, 2350, lin+100, 2350 )   	// vertical
lin+=10
oPrint:Say(lin,0040,"Usuário Avaliação",oFont08) 
oPrint:Say(lin,0610,"Usuário Solicitante",oFont08) 
oPrint:Say(lin,1210,"Vlr.Avaliação",oFont08) 
oPrint:Say(lin,1510,"Vlr.Compra",oFont08) 
oPrint:Say(lin,1810,"Aprovado",oFont08)	
lin+=40                                  
oPrint:Say(lin,040,VAZ->VAZ_CUSAVA+" - "+UsrRetName(VAZ->VAZ_CUSAVA),oFont10)
oPrint:Say(lin,610,VAZ->VAZ_CUSSOL+" - "+UsrRetName(VAZ->VAZ_CUSAVA),oFont10)
oPrint:Say(lin,1210,transform(VAZ->VAZ_VALAVA,"@E 999,999,999.99"),oFont10)
oPrint:Say(lin,1510,transform(VAZ->VAZ_VALCOM,"@E 999,999,999.99"),oFont10)   
if VAZ->VAZ_APROVA == "1"
   cAprova := "Sim"
Else
   cAprova := "Nao"
Endif   
oPrint:Say(lin,1810,cAprova,oFont10)
lin+=55

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
Local cCampo := ""                                         

oPrint:Box(lin,30,lin+70,2350)
lin+=10
oPrint:Say(lin,1100,"Observações",oFont12) //"Observações"
lin+=70
//oPrint:Line(lin,30,lin,2350)
dbSelectArea("SYP")
dbSetOrder(1)
if dbSeek(xFilial("SYP")+VAZ->VAZ_OCOMEM)  
    nNroLin := 0     
    cUltima := ""
    While !Eof() .and. xFilial("SYP") == SYP->YP_FILIAL .and. SYP->YP_CHAVE == VAZ->VAZ_OCOMEM

		nPos1 := AT("\13\10",SYP->YP_TEXTO)
		if nPos1 > 0
			nPos := len(alltrim(SYP->YP_TEXTO)) - 6
		else
			nPos := len(alltrim(SYP->YP_TEXTO))
		endif
		cCampo += " "+Substr(SYP->YP_TEXTO,1,nPos)
    	dbSelectArea("SYP")
    	dbSkip()
    Enddo
Endif 
cInicio := "Inicio" 
nPos := 1
While cInicio <> ""   
	oPrint:Line( lin, 030, lin+40, 030 )   	// vertical
	oPrint:Line( lin, 2350, lin+40, 2350 )   	// vertical
	oPrint:Say(lin,040,Alltrim(substr(cCampo,nPos,90)),oFont10)  
	lin+=40     
    nPos += 90 
    cInicio := substr(cCampo,nPos,80)
Enddo
oPrint:Line( lin, 030, lin+100, 030 )   	// vertical
oPrint:Line( lin, 2350, lin+100, 2350 )   	// vertical
lin+=100     
oPrint:Line(lin,30,lin,2350)
lin+=400
oPrint:Box(lin,650,lin+70,1150)
oPrint:Say(lin+10,660,"Cliente",oFont08) //"Cliente:"
oPrint:Box(lin,1220,lin+70,1720)
oPrint:Say(lin+10,1230,Trim(SM0->M0_NOME)+":",oFont08)

Return lin 
