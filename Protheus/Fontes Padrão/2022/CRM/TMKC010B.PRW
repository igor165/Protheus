#INCLUDE "TMKC010B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "TMKDEF.CH"

#DEFINE cPerg "TMKC10"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010TLV   บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo dos paineis 18-Orcamentos, 19-Faturamentบฑฑ
ฑฑบ          ณ20-Cancelamentos, 21-Vendas SigaLoja e 22-Bonus               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบCleber M. ณ17/01/07ณ115806ณ-Adequacao para montagem do aCols e aHeader 	บฑฑ
ฑฑบ          ณ        ณ9.12  ณpela FillGetDados (Walk-thru)               	บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010TLV(oExplorer, nPanel, aEmpCont, cPanel)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01TLV															// Listbox do Cabecalho - SUA
Local aCabeca	:= {}													// Array com os registros do SUA - Cabecalho do atendimento de televendas
Local oGetDados 														// Getdados com os itens - SUB	
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSUAExc	:= (X2ModAcess("SUA") == "E")							// Indica se o SUD esta como exclusivo

Default cPanel := "" // Para release 11.7 o controle sera pelo nome do panel

aCabeca := TKCListBox("SUA", aEmpCont, nPanel,,cPanel)

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0002,; //"	01} SUA - Cabe็alho do atendimento tele vendas"
									STR0003; //"	02) SUB - Produtos do atendimento do tele vendas"
									})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SUB"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a montagem do aHeader e aCols pela FillGetDados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		If lSUAExc .AND. cFilAnt <> aCabeca[1][14]
			cFilAnt := aCabeca[1][14]
		EndIf
		TkMontaItens( "SUB", aCabeca[1][1], "V" )	
		cFilAnt := cFilAtu	
		AAdd(aAllHeader, {"SUB", aHeader})
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft 	ListBox oLB01TLV Fields;
				Header	STR0109,; // 01 - Filial
						STR0004,; // 02 - Codigo 
						STR0005,; // 03 - Operador 
						STR0006,; // 04 - Tabela 
						STR0007,; // 05 - Operacao 
						STR0008,; // 06 - Midia 
						STR0009,; // 07 - Vendedor 
						STR0010,; // 08 - Emissao 
						STR0011,; // 09 - Campanha 
						STR0012,; // 10 - Ocorrencia 
						STR0013,; // 11 - Cond. Pagamento 
						STR0014,; // 12 - Form. Pagamento 
						STR0015,; // 13 - Status 
						STR0016;  // 14 - Transportadora 
				Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01TLV:SetArray(aCabeca)
oLB01TLV:bLine:={||{	aCabeca[oLB01TLV:nAt,14],;
						aCabeca[oLB01TLV:nAt,1],;
						aCabeca[oLB01TLV:nAt,2],;
						aCabeca[oLB01TLV:nAt,3],;
						aCabeca[oLB01TLV:nAt,4],;
						aCabeca[oLB01TLV:nAt,5],;
						aCabeca[oLB01TLV:nAt,6],;
						aCabeca[oLB01TLV:nAt,7],;
						aCabeca[oLB01TLV:nAt,8],;
						aCabeca[oLB01TLV:nAt,9],;
 						aCabeca[oLB01TLV:nAt,10],;
 						aCabeca[oLB01TLV:nAt,11],;
 						aCabeca[oLB01TLV:nAt,12],;
 						aCabeca[oLB01TLV:nAt,13]  }}
oLB01TLV:nAt := 1
oLB01TLV:Default()

oLB01TLV:bChange := {||	If((lSUAExc .AND. cFilAnt <> Eval(oLB01TLV:bLine)[1]),(cFilAnt := Eval(oLB01TLV:bLine)[1]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SUB"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SUB"})][2])),;
						TkMontaItens( "SUB", Eval(oLB01TLV:bLine)[2], "V" ),;
						oGetDados:oBrowse:Refresh(),;
						cFilAnt := cFilAtu }
							
If Type("aDados") == "A"
	aDados[3]:=aCabeca
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um browser tipo MSGetDados Read Only dos itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oGetDados := MSGetDados():New((nBottom*.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01TLV:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn21  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel dos produtos Mais Comprados   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn21(oExplorer, nPanel, aEmpCont)

Local aArea     := GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local aCoord    := {}													// Array com as cordenadas
Local oLB01Pn23															// Listbox do Cabecalho - SF2/SD2
Local aCabeca   := {}													// Array com os registros do SF2/SD2 - Cabecalho dos produtos mais vendidos
Local nRec      := SB1->(RecNo())													
Local oEnchoice
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSB1Exc	:= (X2ModAcess("SB1") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("SF2", aEmpCont, nPanel) 

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0017,; //"	01} SF2 - Cabe็alho das notas fiscais emitidas"
									STR0018,; //"	02) SD2 - Produtos que mcont้m cada nota fiscal"
									STR0106; //"	03) SB1 - Cadastro de Produtos"
									})
	Return(Nil)
Endif

If lSB1Exc .AND. cFilAnt <> aCabeca[1][09]
	cFilAnt := aCabeca[1][09]
EndIf

nRec := TKC010Brow( "SB1", "E", aCabeca[1][1] )
If nRec == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0017,; //"	01} SF2 - Cabe็alho das notas fiscais emitidas"
									STR0018,; //"	02) SD2 - Produtos que mcont้m cada nota fiscal"
									STR0106; //"	03) SB1 - Cadastro de Produtos"
									})
	Return(Nil)
Endif

cFilAnt := cFilAtu

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft 	ListBox oLB01Pn23 Fields;
				Header	STR0109,; // 01 - Filial
						STR0004,; // 02 - Codigo"
						STR0019,; // 03 - Produto"
						STR0020,; // 04 - UM"
						STR0021,; // 05 - Qtdade"
						STR0022,; // 06 - Ult. Valor"
						STR0023,; // 07 - Ult. Compra"
						STR0009,; // 08 - Vendedor"
						STR0024;  // 09 - Nome"
				Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn23:SetArray(aCabeca)
oLB01Pn23:bLine:={||{	aCabeca[oLB01Pn23:nAt,9],;
						aCabeca[oLB01Pn23:nAt,1],;
						aCabeca[oLB01Pn23:nAt,2],;
						aCabeca[oLB01Pn23:nAt,3],;
						aCabeca[oLB01Pn23:nAt,4],;
						aCabeca[oLB01Pn23:nAt,5],;
						aCabeca[oLB01Pn23:nAt,6],;
						aCabeca[oLB01Pn23:nAt,7],;
						aCabeca[oLB01Pn23:nAt,8]}}
oLB01Pn23:nAt := 1
oLB01Pn23:Default()

oLB01Pn23:bChange := {||	If((lSB1Exc .AND. cFilAnt <> Eval(oLB01Pn23:bLine)[1]),(cFilAnt := Eval(oLB01Pn23:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SB1", "E", Eval(oLB01Pn23:bLine)[2] ),;
							SB1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

AAdd(aCoord, { (nBottom*.53), nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SB1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn23:bChange)
				
RestArea(aArea)

Return(Nil)



 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn22  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Conhecimento               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบCleber M. ณ17/01/07ณ115806ณ-Adequacao para montagem do aCols e aHeader 	บฑฑ
ฑฑบ          ณ        ณ9.12  ณpela FillGetDados (Walk-thru)               	บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn22(oExplorer, nPanel, aEmpCont)

Local aArea      := GetArea()
Local nTop       := 05		// Coordenadas da tela
Local nLeft      := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn24				// Listbox do Cabecalho - ACB
Local aCabeca    := {}		// Array com os registros do ACC - Cabecalho do atendimento
Local oGetDados

Define Cursor cMao HAND

aCabeca := TKCListBox("ACB", aEmpCont, nPanel)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0025,; //"	01} ACB - Cabe็alho do banco de conhecimentos"
									STR0026; //"	02) ACC - Itens do banco de conhecimentos"
									})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACC"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a montagem do aHeader e aCols pela FillGetDados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		TkMontaItens( "ACC", aCabeca[1][1], "" )	
		AAdd(aAllHeader, {"ACC", aHeader})
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft 	ListBox oLB01Pn24 Fields;
				Header	STR0004,; // 01 - Codigo 
						STR0027,; // 02 - Objeto 
						STR0028;  // 03 - Desccricao 
				Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel;
				On DblClick( MsDocView( Eval(oLB01Pn24:bLine)[2]) )

oLB01Pn24:Cargo := "CONHECIMENTOS"
oLB01Pn24:SetArray(aCabeca)
oLB01Pn24:bLine:={||{	aCabeca[oLB01Pn24:nAt,1],;
						aCabeca[oLB01Pn24:nAt,2],;
 						aCabeca[oLB01Pn24:nAt,3] }}
oLB01Pn24:oCursor := cMao
oLB01Pn24:nAt := 1 
oLB01Pn24:Default()
oLB01Pn24:bChange := {||	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACC"}),;
							aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "ACC"})][2])),;
							TkMontaItens( "ACC", Eval(oLB01Pn24:bLine)[1], "" ),;
							oGetDados:oBrowse:Refresh() }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um browser tipo MSGetDados Read Only dos itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oGetDados := MSGetDados():New((nBottom*.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

If Type("aDados") == "A"
	aDados[4] := aCabeca
EndIf

RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn23  บAutor  ณArmando M. Tessaroliบ Data ณ  28/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Analise Banco de conhecimenบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn23(oExplorer, nPanel, aEmpCont)

Local aArea    := GetArea()
Local nTop       := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)

Local aResultado := {} 
Local aListBox   := {}
Local aOrdem     := { STR0029, STR0030 } //"Ocorrencias","Descricao"
        
Local cKeyWord   := Space( 100 ) 
Local cDescri    := Space( 40 ) 
Local cResultado := "" 
Local cOrdem     := "" 
Local cObjeto    := Space( 200 ) 

Local lExata     := .F. 
Local lKeyWord   := .F. 

Local oListBox
Local oBut1 
Local oBut2
Local oPesqExata                                          
Local oOrdem 

@  0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oExplorer:GetPanel(nPanel) SIZE nRight/6, nBottom+10 NOBORDER WHEN .F. PIXEL ADJUST
	
TSay():New(nTop, nRight*.1,{|| STR0031 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"LOCALIZAR E VISUALIZAR CONHECIMENTO"
	
@ nBottom*.07, nRight*.1 TO nBottom, nRight LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

TSay():New(nBottom*.17, nRight*.18,{|| STR0027 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Objeto"
@ nBottom*.17, nRight*.33 MSGET oGetPesq3 VAR cObjeto PICTURE "@!" SIZE 80, 10 VALID .T. OF oExplorer:GetPanel(nPanel) PIXEL
	                                                      
TSay():New(nBottom*.24, nRight*.18,{|| STR0030 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Descricao"
@ nBottom*.24, nRight*.33 MSGET oGetPesq2 VAR cDescri PICTURE "@!" SIZE 80, 10 VALID .T. OF oExplorer:GetPanel(nPanel) PIXEL
	                        
TSay():New(nBottom*.31, nRight*.18,{|| STR0032 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Palavras chave"
@ nBottom*.31, nRight*.33 MSGET oGetPesq1 VAR cKeyWord PICTURE "@!" SIZE 80, 10 VALID .T. OF oExplorer:GetPanel(nPanel) PIXEL
	
TSay():New(nBottom*.38, nRight*.18,{|| STR0033 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Ordenar por"
@ nBottom*.38, nRight*.33	COMBOBOX oOrdem VAR cOrdem ITEMS aOrdem SIZE 80,10 OF oExplorer:GetPanel(nPanel) PIXEL;
	ON CHANGE Ft340Show( @oListBox, @aResultado, oOrdem, @lKeyWord ) 
	
@ nBottom*.45, nRight*.33 LISTBOX oListBox VAR cResultado ITEMS aListBox PIXEL SIZE nRight*.58, nBottom*.37 OF oExplorer:GetPanel(nPanel) MULTI
                                 
@ nBottom*.85, nRight*.33 CHECKBOX oPesqExata VAR lExata SIZE 60,8 PIXEL OF oExplorer:GetPanel(nPanel) PROMPT STR0034 //"Pesquisa Exata"
		                                                                                        
DEFINE SBUTTON oBut1 FROM nBottom*.85, nRight*.72 TYPE 15 ENABLE ONSTOP STR0035 OF oExplorer:GetPanel(nPanel); //"Pesquisar"
ACTION FT340LocLz(	@oListBox, cKeyWord, cDescri, cObjeto,;
					@aResultado, lExata, oOrdem, @lKeyWord)

DEFINE SBUTTON oBut2 FROM nBottom*.85, nRight*.82 TYPE 14 ENABLE ONSTOP STR0036 OF oExplorer:GetPanel(nPanel); //"Abrir"
ACTION	(ACB->( DbSetOrder(1) ),;
		 ACB->( DbGoto(aResultado[oListBox:nAt][2])),;
			 MsDocView( ACB->ACB_OBJETO ));
WHEN !Empty(cResultado)


RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn24  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Telecobranca               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn24(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()                                            // Salva a area atual
Local nTop      := 02													// Coordenadas da tela
Local nLeft     := 02
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oGraphic                                                     		
Local nSerie
Local aSerie    := {}
Local nI		:= 0 

Pergunte(cPerg,.F.)	// Posiciona no grupo de perguntas

If Empty(Mv_Par05)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณO departamento de tecnologia alterou a classe de grafico do   ณ
	//ณremote, em funcao disso limitou tb a quantidade de graficos.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TKC010SD(oExplorer, nPanel, {	STR0037,; //"Falta definir o parametro para o tipo de grแfico deste painel de informa็๕es."
									STR0038,; //"Os Tipos de Grแficos disponํveis sใo:"
									STR0039,; //"	01) GRP_LINE		C๓digo GRF01"
									STR0040,; //"	02) GRP_AREA		C๓digo GRF02"
									STR0041,; //"	03) GRP_POINT		C๓digo GRF03"
									STR0042,; //"	04) GRP_BAR		C๓digo GRF04"
									STR0048,; //"	10) GRP_PIE		C๓digo GRF10"
									})
	Return(Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSubstituir este set pela variavel nSerie ao adicionar o aSerieณ
//ณpara criar varias series.                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nSerie := Val( Mv_Par05 )

AAdd(aSerie, {nSerie, 0, STR0054, 65280} )		// CLR_HGREEN 	//"Telecobrancas"
AAdd(aSerie, {nSerie, 0, STR0055, 16711680} )	// CLR_HBLUE 	//"Negociacoes"
AAdd(aSerie, {nSerie, 0, STR0056, 16711935} )	// CLR_HMAGENTA //"Recebimentos"
AAdd(aSerie, {nSerie, 0, STR0057, 12632256} )	// CLR_HGRAY 	//"Nao Recebidos"
AAdd(aSerie, {nSerie, 0, STR0058, 65535} )		// CLR_YELLOW 	//"Cobr. Vencida"
AAdd(aSerie, {nSerie, 0, STR0059, 255} )		// CLR_HRED 	//"A Realizar"

aSerie := TKC010VP26(aSerie, aEmpCont)

TkC010Grap(@oGraphic,nLeft,nTop,nRight,(nBottom * .7),oExplorer:GetPanel(nPanel),aSerie,CONTROL_ALIGN_BOTTOM)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um quadro de legenda detalhada dos valores que montam a serieณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

@ (nBottom * .73),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .75),05 BitMap oBmp1 ResName "BR_VERDE" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
//"Total geral de telecobran็as realizadas ao clientes com titulos em atrazo"
TSay():New((nBottom * .75),15,{|| STR0060 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

@ (nBottom * .79),05 BitMap oBmp2 ResName "BR_AZUL" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
//"Numero de cobran็as dos titulos vencidos e nใo pagos que estao em andamento"
TSay():New((nBottom * .79),15,{|| STR0061 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

@ (nBottom * .83),05 BitMap oBmp1 ResName "BR_PINK" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
//"Titulos vencidos e recebidos atraves de negociacoes encerradas (sem data de retorno) do telecobranca"
TSay():New((nBottom * .83),15,{|| STR0062 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

@ (nBottom * .87),05 BitMap oBmp1 ResName "BR_CINZA" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
//"Negociacoes encerradas (sem data de retorno) com titulos que ainda nใo foram pagos pelo cliente"
TSay():New((nBottom * .87),15,{|| STR0063 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

@ (nBottom * .91),05 BitMap oBmp1 ResName "BR_AMARELO" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
//"Cobrancas que possuem uma data de retorno agendada e ainda nใo foram realizadas pelo operador"
TSay():New((nBottom * .91),15,{|| STR0064 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

@ (nBottom * .95),05 BitMap oBmp1 ResName "BR_VERMELHO" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
//"Quantidade de titulos no financeiro que deverao fazer parte de uma lista de contatos"
TSay():New((nBottom * .95),15,{|| STR0065 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn25  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Cobrancas                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบCleber M. ณ17/01/07ณ115806ณ-Adequacao para montagem do aCols e aHeader 	บฑฑ
ฑฑบ          ณ        ณ9.12  ณpela FillGetDados (Walk-thru)               	บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn25(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn27															// Listbox do Cabecalho - SUC
Local aCabeca   := {}													// Array com os registros do SUC - Cabecalho do atendimento
Local oGetDados
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lACGExc	:= (X2ModAcess("ACG") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("ACF", aEmpCont, nPanel)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0066,; //"	01} ACF - Cabe็alho do atendimento telecobrn็a"
									STR0067; //"	02) ACG - Tํtulos vencidos do atendimento do telecobran็a"
									})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACG"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a montagem do aHeader e aCols pela FillGetDados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		If lACGExc .AND. cFilAnt <> aCabeca[1][10]
			cFilAnt := aCabeca[1][10]
		EndIf
		TkMontaItens( "ACG", aCabeca[1][1], "C" )
		cFilAnt := cFilAtu	
		AAdd(aAllHeader, {"ACG", aHeader})
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft 	ListBox oLB01Pn27 Fields;
				Header	STR0109,; // 01 - Filial
						STR0068,; // 02 - Atendimento 
						STR0023,; // 03 - Data 
						STR0069,; // 04 - Retorno 
						STR0070,; // 05 - Hora 
					 	STR0071,; // 06 - Ligacao 
						STR0005,; // 07 - Operador 
						STR0024,; // 08 - Nome 
						STR0012,; // 09 - Ocorrencia 
						STR0072;  // 10 - Descricao 
				Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn27:Cargo := "TELECOBRANCA"
oLB01Pn27:SetArray(aCabeca)
oLB01Pn27:bLine:={||{	aCabeca[oLB01Pn27:nAt,10],;
						aCabeca[oLB01Pn27:nAt,1],;
						aCabeca[oLB01Pn27:nAt,2],;
						aCabeca[oLB01Pn27:nAt,3],;
						aCabeca[oLB01Pn27:nAt,4],;
						aCabeca[oLB01Pn27:nAt,5],;
						aCabeca[oLB01Pn27:nAt,6],;
						aCabeca[oLB01Pn27:nAt,7],;
						aCabeca[oLB01Pn27:nAt,8],;
						aCabeca[oLB01Pn27:nAt,9] }}
oLB01Pn27:nAt := 1
oLB01Pn27:Default()

oLB01Pn27:bChange := {||   If((lACGExc .AND. cFilAnt <> Eval(oLB01Pn27:bLine)[1]),(cFilAnt := Eval(oLB01Pn27:bLine)[1]),.T.),;
							nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACG"}),;
							aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "ACG"})][2])),;
							TkMontaItens( "ACG", Eval(oLB01Pn27:bLine)[2], "C" ),;
							oGetDados:oBrowse:Refresh(),;
							cFilAnt := cFilAtu } 
							
If Type("aDados") == "A"
	aDados[5] := aCabeca
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um browser tipo MSGetDados Read Only dos itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

n:= 1 // Garante posicionamento na primeira linha
oGetDados := MSGetDados():New((nBottom*.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01Pn27:bChange)

RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn26  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Negociacao                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบCleber M. ณ17/01/07ณ115806ณ-Adequacao para montagem do aCols e aHeader 	บฑฑ
ฑฑบ          ณ        ณ9.12  ณpela FillGetDados (Walk-thru)               	บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn26(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                        // Salva a area atual
Local nTop      := 05												// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn28														// Listbox do Cabecalho - ACF
Local aCabeca   := {}												// Array com os registros do ACF - Cabecalho do telecobranca
Local oGetDados
Local oObs
Local cObs      := ""
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lACGExc	:= (X2ModAcess("ACG") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("ACF", aEmpCont, nPanel,,P_TLC_NEGOCIA)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0066,; //"	01} ACF - Cabe็alho do atendimento telecobrn็a"
									STR0067; //"	02) ACG - Tํtulos vencidos do atendimento do telecobran็a"
									})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACG"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a montagem do aHeader e aCols pela FillGetDados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lACGExc .AND. cFilAnt <> aCabeca[1][10]
			cFilAnt := aCabeca[1][10]
		EndIf
		TkMontaItens( "ACG", aCabeca[1][1], "C" )
		cFilAnt := cFilAtu	
		AAdd(aAllHeader, {"ACG", aHeader})
	Endif

Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn28 Fields;
				Header	STR0109,; // 01 - Filial
						STR0068,; // 02 - Atendimento
						STR0023,; // 03 - Data 
						STR0069,; // 04 - Retorno 
						STR0070,; // 05 - Hora 
					 	STR0071,; // 06 - Ligacao 
						STR0005,; // 07 - Operador 
						STR0024,; // 08 - Nome 
						STR0012,; // 09 - Ocorrencia 
						STR0072;  // 10 - Descricao 
				Size nRight*.7,(nBottom*.4) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn28:SetArray(aCabeca)
oLB01Pn28:bLine:={||{	aCabeca[oLB01Pn28:nAt,10],;
						aCabeca[oLB01Pn28:nAt,1],;
						aCabeca[oLB01Pn28:nAt,2],;
						aCabeca[oLB01Pn28:nAt,3],;
						aCabeca[oLB01Pn28:nAt,4],;
						aCabeca[oLB01Pn28:nAt,5],;
						aCabeca[oLB01Pn28:nAt,6],;
						aCabeca[oLB01Pn28:nAt,7],;
						aCabeca[oLB01Pn28:nAt,8],;
						aCabeca[oLB01Pn28:nAt,9] }}
oLB01Pn28:nAt := 1
oLB01Pn28:Default()

oLB01Pn28:bChange := {||	If((lACGExc .AND. cFilAnt <> Eval(oLB01Pn28:bLine)[1]),(cFilAnt := Eval(oLB01Pn28:bLine)[1]),.T.),;
							nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACG"}),;
							aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "ACG"})][2])),;
							TkMontaItens( "ACG", Eval(oLB01Pn28:bLine)[2], "C" ),;
							oGetDados:oBrowse:Refresh(),;
							ACF->( DbSetOrder(1) ),;
							ACF->( MsSeek(xFilial("ACF") + Eval(oLB01Pn28:bLine)[2]) ),;
							cObs := MSMM(ACF->ACF_CODOBS,80),;
							oObs:Refresh(),;
							cFilAnt := cFilAtu }

TSay():New(nTop,nRight*.73,{|| STR0073 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Observa็๕es"

@ (nTop+10),nRight*.73 GET oObs VAR cObs MEMO SIZE nRight*.28,nBottom*.35 READONLY OF oExplorer:GetPanel(nPanel) PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um browser tipo MSGetDados Read Only dos itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetDados := MSGetDados():New((nBottom*.45),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01Pn28:bChange)

RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn27  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Ocorrencias                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบAndrea F. ณ22/07/05ณ8.11  ณFNC 002358/2005 - Exibir os dados do atendi-  บฑฑ
ฑฑบ          ณ        ณ      ณmento correspondente ao titulo selecionado.   บฑฑ
ฑฑบ          ณ        ณ      ณno listbox.                                   บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn27(oExplorer, nPanel, aEmpCont)

Local aArea     := GetArea()                                            // Salva a area atual
Local nTop      := 0													// Coordenadas de tela
Local nLeft     := 0
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn29															// Listbox do Cabecalho com todos os titulos da empresa - ACG
Local aCabeca   := {}													// Array com os registros do ACG - representa os titulos cobrados
Local oLB02Pn29															// Listbox dos Itens da consulta que cont้m todas as cobrnacas de um titulo - ACF
Local aItens    := {}													// Array com os registros do ACF - representa as cobran็as de cada titulo
Local oFolder
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}
Local oObs
Local cObs
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo
Local lACFExc	:= (X2ModAcess("ACF") == "E")							// Indica se o ACF esta como exclusivo

aCabeca := TKCListBox("ACG", aEmpCont, nPanel,,P_TLC_OCORR)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0074,; //"	01} ACG - Cabe็alho principal do folder que sใo todos os ดtitulos em telecobran็a"
									STR0075,; //"	02) ACF - Todas as cobran็as realizadas para cada tํtulo e sua negocia็ใo"
									STR0107; //"	03) SE1 - Tํtulos a receber do financeiro "
									})
	Return(Nil)
Endif

If lSE1Exc .AND. cFilAnt <> aCabeca[1][15]
	cFilAnt := aCabeca[1][15]
EndIf

nRec := TKC010Brow( "SE1", "E", aCabeca[1][1] + aCabeca[1][2] + aCabeca[1][3] )

cFilAnt := cFilAtu

If nRec == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0074,; //"	01} ACG - Cabe็alho principal do folder que sใo todos os ดtitulos em telecobran็a"
									STR0075,; //"	02) ACF - Todas as cobran็as realizadas para cada tํtulo e sua negocia็ใo"
									STR0107; //"	03) SE1 - Tํtulos a receber do financeiro "
									})
	Return(Nil)
Endif

oFolder := TFolder():New(nTop,nLeft,{STR0076,STR0077},{},oExplorer:GetPanel(nPanel),,,,.T.,.F.,nRight,nBottom) //"Tํtulos"###"Financeiro"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

@ nTop+5,nLeft+5	ListBox oLB01Pn29 Fields;
					Header	STR0109,; // 01 - Filial
							STR0078,; // 02 - Prefixo
							STR0079,; // 03 - Titulo
							STR0080,; // 04 - Parcela 
							STR0081,; // 05 - Tipo 
							STR0082,; // 06 - Natureza 
						 	STR0083,; // 07 - Vencimento 
							STR0084,; // 08 - Venc.Real 
							STR0022,; // 09 - Valor 
							STR0085,; // 10 - Acrescimo 
							STR0086,; // 11 - Desconto 
							STR0015,; // 12 - Status 
							STR0087,; // 13 - Responsavel 
							STR0024;  // 14 - Nome 
					Size nRight-10,(nBottom * .5) NoScroll Of oFolder:aDialogs[1] Pixel

oLB01Pn29:SetArray(aCabeca)
oLB01Pn29:bLine:={||{	aCabeca[oLB01Pn29:nAt,15],;
						aCabeca[oLB01Pn29:nAt,1],;
						aCabeca[oLB01Pn29:nAt,2],;
						aCabeca[oLB01Pn29:nAt,3],;
						aCabeca[oLB01Pn29:nAt,4],;
						aCabeca[oLB01Pn29:nAt,5],;
						aCabeca[oLB01Pn29:nAt,6],;
						aCabeca[oLB01Pn29:nAt,7],;
						aCabeca[oLB01Pn29:nAt,8],;
						aCabeca[oLB01Pn29:nAt,9],;
 						aCabeca[oLB01Pn29:nAt,10],;
 						aCabeca[oLB01Pn29:nAt,11],;
 						aCabeca[oLB01Pn29:nAt,12],;
 						aCabeca[oLB01Pn29:nAt,13] }}
oLB01Pn29:nAt := 1
oLB01Pn29:Default()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um campo memo na tela para mostrar o historico das negociacoesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TSay():New(nBottom*.55,nRight*.73,{|| STR0073 },oFolder:aDialogs[1],,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Observa็๕es"
@ nBottom*.6,nRight*.73 GET oObs VAR cObs MEMO SIZE nRight*.26,nBottom*.32 READONLY OF oFolder:aDialogs[1] PIXEL

aItens 	:= TKCListBox("ACF", aEmpCont, nPanel, aCabeca[oLB01Pn29:nAt][14],P_TLC_OCORR)

oLB01Pn29:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn29:bLine)[1]),(cFilAnt := Eval(oLB01Pn29:bLine)[1]),.T.),;
							nRec 	:= TKC010Brow( "SE1", "E", Eval(oLB01Pn29:bLine)[2] + Eval(oLB01Pn29:bLine)[3] + Eval(oLB01Pn29:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							aItens 	:= TKCListBox("ACF", aEmpCont, nPanel, aCabeca[oLB01Pn29:nAt][14],P_TLC_OCORR),;
							oLB02Pn29:SetArray(aItens),;
							oLB02Pn29:bLine:={||{	aItens[oLB02Pn29:nAt,10],;
													aItens[oLB02Pn29:nAt,1],;
													aItens[oLB02Pn29:nAt,2],;
													aItens[oLB02Pn29:nAt,3],;
													aItens[oLB02Pn29:nAt,4],;
													aItens[oLB02Pn29:nAt,5],;
													aItens[oLB02Pn29:nAt,6],;
													aItens[oLB02Pn29:nAt,7],;
													aItens[oLB02Pn29:nAt,8],;
													aItens[oLB02Pn29:nAt,9]}},;
							oLB02Pn29:nAt := 1,;
							oLB02Pn29:Refresh(),;
							ACF->( DbSetOrder(1) ),;
							ACF->( MsSeek(xFilial("ACF") + Eval(oLB02Pn29:bLine)[1]) ),;
							cObs := MSMM(ACF->ACF_CODOBS,80),;
							oObs:Refresh(),;
							cFilAnt := cFilAtu}
                                                     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um browser tipo MSGetDados Read Only dos itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

@ (nBottom*.55),nLeft+5	ListBox oLB02Pn29 Fields;
							Header	STR0109,; // 01 - Filial
									STR0068,; // 02 - Atendimento  
									STR0023,; // 03 - Data 
									STR0069,; // 04 - Retorno 
									STR0070,; // 05 - Hora 
								 	STR0071,; // 06 - Liga็ใo 
									STR0005,; // 07 - Operador 
									STR0024,; // 08 - Nome 
									STR0012,; // 09 - Ocorrencia 
									STR0072;  // 10 - Descricao 
							Size nRight*.7,nBottom*.38 NoScroll Of oFolder:aDialogs[1] Pixel

oLB02Pn29:SetArray(aItens)

oLB02Pn29:bLine:={||{	aItens[oLB02Pn29:nAt,10],;
						aItens[oLB02Pn29:nAt,1],;
						aItens[oLB02Pn29:nAt,2],;
						aItens[oLB02Pn29:nAt,3],;
						aItens[oLB02Pn29:nAt,4],;
						aItens[oLB02Pn29:nAt,5],;
						aItens[oLB02Pn29:nAt,6],;
						aItens[oLB02Pn29:nAt,7],;
						aItens[oLB02Pn29:nAt,8],;
						aItens[oLB02Pn29:nAt,9]	}}
						
						
oLB02Pn29:nAt := 1

oLB02Pn29:bChange := {||	If((lACFExc .AND. cFilAnt <> Eval(oLB02Pn29:bLine)[1]),(cFilAnt := Eval(oLB02Pn29:bLine)[1]),.T.),;
							ACF->( DbSetOrder(1) ),;
							ACF->( MsSeek(xFilial("ACF") + Eval(oLB02Pn29:bLine)[2]) ) ,;
							cObs := MSMM(ACF->ACF_CODOBS,80),;
							oObs:Refresh(),;
							cFilAnt := cFilAtu}

oLB02Pn29:Default()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nTop+5, nLeft+5, nBottom-20, nRight-5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oFolder:aDialogs[2],,,,,,.T.)

Eval(oLB02Pn29:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn28  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Cobrancas Vencidas         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบCleber M. ณ17/01/07ณ115806ณ-Adequacao para montagem do aCols e aHeader 	บฑฑ
ฑฑบ          ณ        ณ9.12  ณpela FillGetDados (Walk-thru)               	บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn28(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                        // Salva a area atual
Local nTop      := 05												// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn30														// Listbox do Cabecalho - ACF
Local aCabeca    := {}												// Array com os registros do ACF - Cabecalho do telecobranca
Local oGetDados
Local oObs
Local cObs       := ""
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lACGExc	:= (X2ModAcess("ACG") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("ACF", aEmpCont, nPanel,,P_TLC_VENCIDA)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0066,; //"	01} ACF - Cabe็alho do atendimento telecobrn็a"
									STR0067; //"	02) ACG - Tํtulos vencidos do atendimento do telecobran็a"
									})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACG"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a montagem do aHeader e aCols pela FillGetDados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		If lACGExc .AND. cFilAnt <> aCabeca[1][10]
			cFilAnt := aCabeca[1][10]
		EndIf
		
		TkMontaItens( "ACG", aCabeca[1][1], "C" )
		
		cFilAnt := cFilAtu
		
		AAdd(aAllHeader, {"ACG", aHeader})
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn30 Fields;
				Header	STR0109,; // 01 - Filial
						STR0068,; // 02 - Atendimento 
						STR0023,; // 03 - Data 
						STR0069,; // 04 - Retorno 
						STR0070,; // 05 - Hora 
					 	STR0071,; // 06 - Ligacao 
						STR0005,; // 07 - Operador 
						STR0024,; // 08 - Nome 
						STR0012,; // 09 - Ocorrencia 
						STR0072;  // 10 - Descricao 
				Size nRight*.7,(nBottom*.4) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn30:SetArray(aCabeca)
oLB01Pn30:bLine:={||{	aCabeca[oLB01Pn30:nAt,10],;
						aCabeca[oLB01Pn30:nAt,1],;
						aCabeca[oLB01Pn30:nAt,2],;
						aCabeca[oLB01Pn30:nAt,3],;
						aCabeca[oLB01Pn30:nAt,4],;
						aCabeca[oLB01Pn30:nAt,5],;
						aCabeca[oLB01Pn30:nAt,6],;
						aCabeca[oLB01Pn30:nAt,7],;
						aCabeca[oLB01Pn30:nAt,8],;
						aCabeca[oLB01Pn30:nAt,9] }}
oLB01Pn30:nAt := 1
oLB01Pn30:Default()

oLB01Pn30:bChange := {||	If((lACGExc .AND. cFilAnt <> Eval(oLB01Pn30:bLine)[1]),(cFilAnt := Eval(oLB01Pn30:bLine)[1]),.T.),;
							nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACG"}),;
							aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "ACG"})][2])),;
							TkMontaItens( "ACG", Eval(oLB01Pn30:bLine)[2], "C" ),;
							oGetDados:oBrowse:Refresh(),;
							ACF->( DbSetOrder(1) ),;
							ACF->( MsSeek(xFilial("ACF") + Eval(oLB01Pn30:bLine)[2]) ),;
							cObs := MSMM(ACF->ACF_CODOBS,80),;
							oObs:Refresh(),;
							cFilAnt := cFilAtu 	}

TSay():New(nTop,nRight*.73,{|| STR0073 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Observa็๕es"

@ (nTop+10),nRight*.73 GET oObs VAR cObs MEMO SIZE nRight*.28,nBottom*.35 READONLY OF oExplorer:GetPanel(nPanel) PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um browser tipo MSGetDados Read Only dos itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

n := 1 // Garante posicionamento na primeira linha
oGetDados := MSGetDados():New((nBottom*.45),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01Pn30:bChange)

RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn29  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Cobrancas a Realizar       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn29(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn31															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("SE1", aEmpCont, nPanel)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0088; //"	01} SE1 - Tํtulos do contas a receber"
									})
	Return(Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn31 Fields;
				Header	STR0109,; // 01 - Filial
						STR0078,; // 02 - Prefixo 
						STR0089,; // 03 - Tํtulo 
						STR0080,; // 04 - Parcela 
						STR0081,; // 05 - Tipo 
					 	STR0082,; // 06 - Natureza 
						STR0072,; // 07 - Descricao 
						STR0090,; // 08 - Portador 
						STR0024,; // 09 - Nome 
						STR0091,; // 10 - Emissao 
						STR0083,; // 11 - Vencimento 
						STR0092,; // 12 - Venc. Real 
						STR0093,; // 13 - Venc. Original 
						STR0022,; // 14 - Valor 
						STR0094,; // 15 - Saldo 
						STR0095,; // 16 - IRRF  
						STR0096,; // 17 - ISS 
						STR0097,; // 18 - Bordero 
						STR0098;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn31:SetArray(aCabeca)
oLB01Pn31:bLine:={||{	aCabeca[oLB01Pn31:nAt,19],;
						aCabeca[oLB01Pn31:nAt,1],;
						aCabeca[oLB01Pn31:nAt,2],;
						aCabeca[oLB01Pn31:nAt,3],;
						aCabeca[oLB01Pn31:nAt,4],;
						aCabeca[oLB01Pn31:nAt,5],;
						aCabeca[oLB01Pn31:nAt,6],;
						aCabeca[oLB01Pn31:nAt,7],;
						aCabeca[oLB01Pn31:nAt,8],;
						aCabeca[oLB01Pn31:nAt,9],;
						aCabeca[oLB01Pn31:nAt,10],;
						aCabeca[oLB01Pn31:nAt,11],;
						aCabeca[oLB01Pn31:nAt,12],;
						aCabeca[oLB01Pn31:nAt,13],;
						aCabeca[oLB01Pn31:nAt,14],;
						aCabeca[oLB01Pn31:nAt,15],;
						aCabeca[oLB01Pn31:nAt,16],;
						aCabeca[oLB01Pn31:nAt,17],;
						aCabeca[oLB01Pn31:nAt,18] }}
oLB01Pn31:nAt := 1
oLB01Pn31:Default()

oLB01Pn31:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn31:bLine)[1]),(cFilAnt := Eval(oLB01Pn31:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SE1", "E", Eval(oLB01Pn31:bLine)[2] + Eval(oLB01Pn31:bLine)[3] + Eval(oLB01Pn31:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn31:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn30  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Analise Financeira         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn30(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 5													// Coordenadas de tela
Local nLeft     := 5
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .92) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oGraphic
Local nSerie

Local nI		:= 0 

Private aSerie    := {}
Pergunte(cPerg,.F.)		// Posiciona do grupo de perguntas

If Empty(Mv_Par06)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณO departamento de tecnologia alterou a classe de grafico do   ณ
	//ณremote, em funcao disso limitou tb a quantidade de graficos.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TKC010SD(oExplorer, nPanel, {	STR0037,; //"Falta definir o parametro para o tipo de grแfico deste painel de informa็๕es."
									STR0038,; //"Os Tipos de Grแficos disponํveis sใo:"
									STR0039,; //"	01) GRP_LINE		C๓digo GRF01"
									STR0040,; //"	02) GRP_AREA		C๓digo GRF02"
									STR0041,; //"	03) GRP_POINT		C๓digo GRF03"
									STR0042,; //"	04) GRP_BAR		C๓digo GRF04"
									STR0048,; //"	10) GRP_PIE		C๓digo GRF10"
									})
	Return(Nil)
Endif


nSerie := Val( Mv_Par06 )

AAdd(aSerie, {nSerie, 0, STR0076, 65280} )	// CLR_HGREEN 	//"Tํtulos"
AAdd(aSerie, {nSerie, 0, STR0099, 16711680} )	// CLR_HBLUE 	//"Pagos"
AAdd(aSerie, {nSerie, 0, STR0100, 16711935} )	// CLR_HMAGENTA //"Abertos"
AAdd(aSerie, {nSerie, 0, STR0101, 12632256} )	// CLR_HGRAY 	//"Vencidos"
AAdd(aSerie, {nSerie, 0, STR0102, 65535} )	// CLR_YELLOW 	//"A Vencer"
AAdd(aSerie, {nSerie, 0, STR0103, 255} )		// CLR_HRED 	//"Pg. Atraso"
AAdd(aSerie, {nSerie, 0, STR0104, 16777215} )	// CLR_WHITE 	//"Pg. Cart๓rio"
AAdd(aSerie, {nSerie, 0, STR0105, 16776960} )	// CLR_HCYAN 	//"Protestado"

aSerie := TKC010VP32(aSerie, aEmpCont)			// Carrega os valores para as series

TkC010Grap(@oGraphic,nLeft,nTop,nRight,nBottom,oExplorer:GetPanel(nPanel),aSerie,CONTROL_ALIGN_BOTTOM)
	
RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn31  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Titulos Vencidos           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn31(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 05													// Coordenadas
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLb01Pn33															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}  
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("SE1", aEmpCont, nPanel,,P_ANF_VENCIDO)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0088; //"	01} SE1 - Tํtulos do contas a receber"
									})
	Return(Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLb01Pn33 Fields;
				Header	STR0109,; // 01 - Filial
						STR0078,; // 02 - Prefixo 
						STR0089,; // 03 - Tํtulo 
						STR0080,; // 04 - Parcela 
						STR0081,; // 05 - Tipo 
					 	STR0082,; // 06 - Natureza 
						STR0072,; // 07 - Descricao 
						STR0090,; // 08 - Portador 
						STR0024,; // 09 - Nome 
						STR0091,; // 10 - Emissao 
						STR0083,; // 11 - Vencimento 
						STR0092,; // 12 - Venc. Real 
						STR0093,; // 13 - Venc. Original 
						STR0022,; // 14 - Valor 
						STR0094,; // 15 - Saldo 
						STR0095,; // 16 - IRRF 
						STR0096,; // 17 - ISS  
						STR0097,; // 18 - Bordero 
						STR0098;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLb01Pn33:SetArray(aCabeca)
oLb01Pn33:bLine:={||{	aCabeca[oLb01Pn33:nAt,19],;
						aCabeca[oLb01Pn33:nAt,1],;
						aCabeca[oLb01Pn33:nAt,2],;
						aCabeca[oLb01Pn33:nAt,3],;
						aCabeca[oLb01Pn33:nAt,4],;
						aCabeca[oLb01Pn33:nAt,5],;
						aCabeca[oLb01Pn33:nAt,6],;
						aCabeca[oLb01Pn33:nAt,7],;
						aCabeca[oLb01Pn33:nAt,8],;
						aCabeca[oLb01Pn33:nAt,9],;
						aCabeca[oLb01Pn33:nAt,10],;
						aCabeca[oLb01Pn33:nAt,11],;
						aCabeca[oLb01Pn33:nAt,12],;
						aCabeca[oLb01Pn33:nAt,13],;
						aCabeca[oLb01Pn33:nAt,14],;
						aCabeca[oLb01Pn33:nAt,15],;
						aCabeca[oLb01Pn33:nAt,16],;
						aCabeca[oLb01Pn33:nAt,17],;
						aCabeca[oLb01Pn33:nAt,18] }}
oLb01Pn33:nAt := 1
oLb01Pn33:Default()

oLb01Pn33:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLb01Pn33:bLine)[1]),(cFilAnt := Eval(oLb01Pn33:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SE1", "E", Eval(oLb01Pn33:bLine)[2] + Eval(oLb01Pn33:bLine)[3] + Eval(oLb01Pn33:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLb01Pn33:bChange)

RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn32  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel A Vencer                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn32(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn34															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("SE1", aEmpCont, nPanel,,P_ANF_VENCER)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0088; //"	01} SE1 - Tํtulos do contas a receber"
									})
	Return(Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn34 Fields;
				Header	STR0109,; // 01 - Filial
						STR0078,; // 02 - Prefixo 
						STR0089,; // 03 - Tํtulo 
						STR0080,; // 04 - Parcela 
						STR0081,; // 05 - Tipo 
					 	STR0082,; // 06 - Natureza 
						STR0072,; // 07 - Descricao 
						STR0090,; // 08 - Portador 
						STR0024,; // 09 - Nome 
						STR0091,; // 10 - Emissao 
						STR0083,; // 11 - Vencimento 
						STR0092,; // 12 - Venc. Real 
						STR0093,; // 13 - Venc. Original 
						STR0022,; // 14 - Valor 
						STR0094,; // 15 - Saldo 
						STR0095,; // 16 - IRRF  
						STR0096,; // 17 - ISS 
						STR0097,; // 18 - Bordero 
						STR0098;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn34:SetArray(aCabeca)
oLB01Pn34:bLine:={||{	aCabeca[oLB01Pn34:nAt,19],;
						aCabeca[oLB01Pn34:nAt,1],;
						aCabeca[oLB01Pn34:nAt,2],;
						aCabeca[oLB01Pn34:nAt,3],;
						aCabeca[oLB01Pn34:nAt,4],;
						aCabeca[oLB01Pn34:nAt,5],;
						aCabeca[oLB01Pn34:nAt,6],;
						aCabeca[oLB01Pn34:nAt,7],;
						aCabeca[oLB01Pn34:nAt,8],;
						aCabeca[oLB01Pn34:nAt,9],;
						aCabeca[oLB01Pn34:nAt,10],;
						aCabeca[oLB01Pn34:nAt,11],;
						aCabeca[oLB01Pn34:nAt,12],;
						aCabeca[oLB01Pn34:nAt,13],;
						aCabeca[oLB01Pn34:nAt,14],;
						aCabeca[oLB01Pn34:nAt,15],;
						aCabeca[oLB01Pn34:nAt,16],;
						aCabeca[oLB01Pn34:nAt,17],;
						aCabeca[oLB01Pn34:nAt,18] }}
oLB01Pn34:nAt := 1
oLB01Pn34:Default()

oLB01Pn34:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn34:bLine)[1]),(cFilAnt := Eval(oLB01Pn34:bLine)[1]),.T.),;   
							nRec := TKC010Brow( "SE1", "E", Eval(oLB01Pn34:bLine)[2] + Eval(oLB01Pn34:bLine)[3] + Eval(oLB01Pn34:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn34:bChange)

RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn33  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Pagamento com Atrazo       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn33(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 05													// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn35															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("SE1", aEmpCont, nPanel,,P_ANF_ATRASO)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,;  //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									"	01} SE1 - Tํtulos do contas a receber"; 
									})
	Return(Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn35 Fields;
				Header	STR0109,; // 01 - Filial
						STR0078,; // 02 - Prefixo 
						STR0089,; // 03 - Tํtulo 
						STR0080,; // 04 - Parcela 
						STR0081,; // 05 - Tipo 
					 	STR0082,; // 06 - Natureza 
						STR0072,; // 07 - Descricao 
						STR0090,; // 08 - Portador 
						STR0024,; // 09 - Nome 
						STR0091,; // 10 - Emissao 
						STR0083,; // 11 - Vencimento 
						STR0092,; // 12 - Venc. Real 
						STR0093,; // 13 - Venc. Original 
						STR0108,; // 14 - Valor 
						STR0094,; // 15 - Saldo 
						STR0095,; // 16 - IRRF 
						STR0096,; // 17 - ISS 
						STR0097,; // 18 - Bordero 
						STR0098;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn35:SetArray(aCabeca)
oLB01Pn35:bLine:={||{	aCabeca[oLB01Pn35:nAt,19],;
						aCabeca[oLB01Pn35:nAt,1],;
						aCabeca[oLB01Pn35:nAt,2],;
						aCabeca[oLB01Pn35:nAt,3],;
						aCabeca[oLB01Pn35:nAt,4],;
						aCabeca[oLB01Pn35:nAt,5],;
						aCabeca[oLB01Pn35:nAt,6],;
						aCabeca[oLB01Pn35:nAt,7],;
						aCabeca[oLB01Pn35:nAt,8],;
						aCabeca[oLB01Pn35:nAt,9],;
						aCabeca[oLB01Pn35:nAt,10],;
						aCabeca[oLB01Pn35:nAt,11],;
						aCabeca[oLB01Pn35:nAt,12],;
						aCabeca[oLB01Pn35:nAt,13],;
						aCabeca[oLB01Pn35:nAt,14],;
						aCabeca[oLB01Pn35:nAt,15],;
						aCabeca[oLB01Pn35:nAt,16],;
						aCabeca[oLB01Pn35:nAt,17],;
						aCabeca[oLB01Pn35:nAt,18] }}
oLB01Pn35:nAt := 1
oLB01Pn35:Default()

oLB01Pn35:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn35:bLine)[1]),(cFilAnt := Eval(oLB01Pn35:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SE1", "E", Eval(oLB01Pn35:bLine)[2] + Eval(oLB01Pn35:bLine)[3] + Eval(oLB01Pn35:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn35:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn34  บAutor  ณArmando M. Tessaroliบ Data ณ  12/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta todo o conteudo do painel de Pagamento em Cartorio      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil do Contato                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                           บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ16/11/04ณ8.11  ณ-Revisao do fonte:Sintaxe,Documentacao,Logica บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑบ          ณ        ณ      ณ                                              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TKC010Pn34(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn36															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("SE1", aEmpCont, nPanel,,P_ANF_CARTORIO)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0088; //"	01} SE1 - Tํtulos do contas a receber"
									})
	Return(Nil)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn36 Fields;
				Header	STR0109,; // 01 - Filial
						STR0078,; // 02 - Prefixo 
						STR0089,; // 03 - Tํtulo 
						STR0080,; // 04 - Parcela 
						STR0081,; // 05 - Tipo 
					 	STR0082,; // 06 - Natureza 
						STR0072,; // 07 - Descricao 
						STR0090,; // 08 - Portador 
						STR0024,; // 09 - Nome 
						STR0091,; // 10 - Emissao 
						STR0083,; // 11 - Vencimento 
						STR0092,; // 12 - Venc. Real 
						STR0093,; // 13 - Venc. Original 
						STR0108,; // 14 - Valor 
						STR0094,; // 15 - Saldo 
						STR0095,; // 16 - IRRF  
						STR0096,; // 17 - ISS 
						STR0097,; // 18 - Bordero 
						STR0098;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn36:SetArray(aCabeca)
oLB01Pn36:bLine:={||{	aCabeca[oLB01Pn36:nAt,19],;
						aCabeca[oLB01Pn36:nAt,1],;
						aCabeca[oLB01Pn36:nAt,2],;
						aCabeca[oLB01Pn36:nAt,3],;
						aCabeca[oLB01Pn36:nAt,4],;
						aCabeca[oLB01Pn36:nAt,5],;
						aCabeca[oLB01Pn36:nAt,6],;
						aCabeca[oLB01Pn36:nAt,7],;
						aCabeca[oLB01Pn36:nAt,8],;
						aCabeca[oLB01Pn36:nAt,9],;
						aCabeca[oLB01Pn36:nAt,10],;
						aCabeca[oLB01Pn36:nAt,11],;
						aCabeca[oLB01Pn36:nAt,12],;
						aCabeca[oLB01Pn36:nAt,13],;
						aCabeca[oLB01Pn36:nAt,14],;
						aCabeca[oLB01Pn36:nAt,15],;
						aCabeca[oLB01Pn36:nAt,16],;
						aCabeca[oLB01Pn36:nAt,17],;
						aCabeca[oLB01Pn36:nAt,18]}}
oLB01Pn36:nAt := 1
oLB01Pn36:Default()

oLB01Pn36:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn36:bLine)[1]),(cFilAnt := Eval(oLB01Pn36:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SE1", "E", Eval(oLB01Pn36:bLine)[2] + Eval(oLB01Pn36:bLine)[3] + Eval(oLB01Pn36:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn36:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTKC010Pn48บAutor  ณVendas CRM          บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe todas as NCCs do cliente que estao em aberto          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKC010C                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TKC010Pn48(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn34															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())
Local oEnchoice
Local aCoord    := {}   
Local oFnt		:= Nil
Local nTotal	:= 0
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

DEFINE FONT oFnt NAME "ARIAL" SIZE 08,17 BOLD

aCabeca := TKCListBox("SE1", aEmpCont, nPanel,,P_ANF_NCC)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informa็๕es deste folder sejam mostradas, sใo utilizadas as tabelas:"
									"",;
									STR0088; //"	01} SE1 - Tํtulos do contas a receber"
									})
	Return(Nil)
Endif

AEval(aCabeca,{|x| nTotal+= Val(x[14]) })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Listbox do Cabecalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nTop, nLeft	ListBox oLB01Pn34 Fields;
				Header	STR0109,; // 01 - Filial
						STR0078,; // 02 - Prefixo 
						STR0089,; // 03 - Tํtulo 
						STR0080,; // 04 - Parcela 
						STR0081,; // 05 - Tipo 
					 	STR0082,; // 06 - Natureza 
						STR0072,; // 07 - Descricao 
						STR0090,; // 08 - Portador 
						STR0024,; // 09 - Nome 
						STR0091,; // 10 - Emissao 
						STR0083,; // 11 - Vencimento 
						STR0092,; // 12 - Venc. Real 
						STR0093,; // 13 - Venc. Original 
						STR0022,; // 14 - Valor 
						STR0094,; // 15 - Saldo 
						STR0095,; // 16 - IRRF  
						STR0096,; // 17 - ISS 
						STR0097,; // 18 - Bordero 
						STR0098;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

TSay():New(nBottom*.45 - 12, nRight - 45 ,{|| "Total:" + Transform(nTotal,"@E 9,999,999.99") },oExplorer:GetPanel(nPanel),,oFnt,,,,.T.,CLR_BLUE,CLR_WHITE) //"Objeto"

oLB01Pn34:SetArray(aCabeca)
oLB01Pn34:bLine:={||{	aCabeca[oLB01Pn34:nAt,19],;
						aCabeca[oLB01Pn34:nAt,1],;
						aCabeca[oLB01Pn34:nAt,2],;
						aCabeca[oLB01Pn34:nAt,3],;
						aCabeca[oLB01Pn34:nAt,4],;
						aCabeca[oLB01Pn34:nAt,5],;
						aCabeca[oLB01Pn34:nAt,6],;
						aCabeca[oLB01Pn34:nAt,7],;
						aCabeca[oLB01Pn34:nAt,8],;
						aCabeca[oLB01Pn34:nAt,9],;
						aCabeca[oLB01Pn34:nAt,10],;
						aCabeca[oLB01Pn34:nAt,11],;
						aCabeca[oLB01Pn34:nAt,12],;
						aCabeca[oLB01Pn34:nAt,13],;
						aCabeca[oLB01Pn34:nAt,14],;
						aCabeca[oLB01Pn34:nAt,15],;
						aCabeca[oLB01Pn34:nAt,16],;
						aCabeca[oLB01Pn34:nAt,17],;
						aCabeca[oLB01Pn34:nAt,18] }}
oLB01Pn34:nAt := 1
oLB01Pn34:Default()

oLB01Pn34:bChange := {||	If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn34:bLine)[1]),(cFilAnt := Eval(oLB01Pn34:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SE1", "E", Eval(oLB01Pn34:bLine)[2] + Eval(oLB01Pn34:bLine)[3] + Eval(oLB01Pn34:bLine)[4] ),;
							SE1->(DbGoTo(nRec)),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta um Enchoice tipo MsMGet Read Only do cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn34:bChange)

RestArea(aArea)

Return Nil