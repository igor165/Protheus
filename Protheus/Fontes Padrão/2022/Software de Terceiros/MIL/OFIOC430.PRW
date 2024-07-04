#Include "Protheus.ch"
#Include "OFIOC430.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC430 ³ Autor ³  Rafael Goncalves     ³ Data ³ 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Avancada Orcamento por Fase                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamada   ³ OFIOC430()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OFIOC430(cAlias, nReg, nOpc, lNoBrowse)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}//
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private cCbStat := STR0001 // Todos
Private aCbStat := { STR0001 , STR0079 , STR0080 , STR0081 , STR0082 , STR0083 ,; // Todos / Orçamento Digitado / Orçamento Margem Pendente / Orçamento Avaliação de Crédito / Orçamento Aguardando Separação / Orçamento Aguardando Lib. Diverg
					 STR0084 , STR0096 , STR0085 , STR0086 , STR0087 , STR0088 ,; // Orçamento Lib. Faturamento / Orçamento aguardando outro Orçamento / Orçamento Importando para OS / Orçamento Cancelado / Orçamento Faturado / Orçamento Solicitação Atendida
					 STR0089 , STR0090 , STR0091 , STR0092  } // Pedido Aberto / Pedido Parc. Atendido / Pedido Encerrado / Pedido Cancelado
Private aRelStat := {"","0","2","3","4","5",;
					"F","G","I","C","X","S",;
					"0","1","2","3"} // Relacionamento do Combo 'aCbStat' com Status do Orcamento (VS1_STATUS) ou Pedido para filtro (VS1_PEDSTA)
Private cReserva:= ""
Private aReserva:= {"", ("0=" + STR0012), ("1=" + STR0013)} // Nao / Sim
Private cTipo   := STR0014
Private aTipo   := {(STR0014), ("1=" + STR0015), ("2=" + STR0016)} // Todos / Pecas / Oficina
Private dDatIni := ctod("01/" + StrZero(Month(dDataBase), 2) + "/" + Substr(StrZero(Year(dDataBase), 4), 3, 2)) //ctod("")
Private dDatFim := dDataBase
Private dDtVIni := ctod("01/" + StrZero(Month(dDataBase), 2) + "/" + Substr(StrZero(Year(dDataBase), 4), 3, 2)) //ctod("")
Private dDtVFin := dDataBase+60
Private cFilFtr := space(len(SA1->A1_FILIAL))
Private cCodCli := space(Len(SA1->A1_COD))
Private cLojCli := space(Len(SA1->A1_LOJA))
Private cNomCli := space(21)
Private cCodVend:= space(Len(SA3->A3_COD))
Private cNomVen := space(21)

Private cCodPec := space(Len(SB1->B1_COD))   //codigo da peca ou servico
Private cGruPec := space(Len(SB1->B1_GRUPO)) //codigo da peca ou servico
Private aListOrc := {} //ordem de servicos filtrada.
Private aPecOrc := {}  //Pecas da ordem de servico selecionada
Private aSerOrc := {}  //Servicos da OS selecionada
Private cChassi := space(Len(VV1->VV1_CHASSI))

Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )   // "Orcamento Digitado"
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO") // "Cancelado"
Private oazul := LoadBitmap( GetResources(), "BR_azul")     // "Aguardando Separacao"
Private oAzulC := LoadBitmap( GetResources(), "BR_azul_claro") // Aguardando outro Orçamento
Private olara := LoadBitmap( GetResources(), "BR_laranja")  // "Importado para O.S."
Private opret := LoadBitmap( GetResources(), "BR_preto")    // "Faturado"
Private oBranc:= LoadBitmap( GetResources(), "BR_branco")   // "Avaliacao de Credito"
Private oPink := LoadBitmap( GetResources(), "BR_PINK")     // "Margem Pendente"
Private oMarr := LoadBitmap( GetResources(), "BR_MARROM")   // "Aguardando Lib.Diverg."
Private oAmar := LoadBitmap( GetResources(), "BR_AMARELO")  // "Liberado p/ Faturamento"
Private cRegSel := 0
Private lNomCli := .f.

Default lNoBrowse := .f.

DbSelectArea("VAI")
DbSetOrder(4)
If DbSeek( xFilial("VAI") + __CUSERID )
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3") + VAI->VAI_CODVEN )
		cCodVend:= SA3->A3_COD
		cNomVen := SA3->A3_NOME
	EndIf
EndIF

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05,  55, .T., .F. } ) //Cabecalho
AAdd( aObjects, { 01,  10, .T., .T. } ) //list box superior
AAdd( aObjects, { 01, 120, .T., .F. } ) //list box superior

aInfo := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2 }
aPosObj := MsObjSize (aInfo, aObjects, .F.)

aadd(aPecOrc,{"", "", "", 0, 0, "", 0})
aadd(aSerOrc,{"", "", "", "", 0, "", 0})

// Ponto de entrada para manipulação das variáveis do filtro.
If ExistBlock("OCMNTFIL")
	ExecBlock("OCMNTFIL", .f., .f.)
EndIf

DEFINE MSDIALOG oPesqOS TITLE STR0017 From aSizeAut[7],000 TO aSizeAut[6], aSizeAut[5] of oMainWnd;
	STYLE DS_MODALFRAME PIXEL //Pesquisa Avancada

oPesqOS:lEscClose := .F.

// Cabeçalho
@ aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3], aPosObj[1,4] LABEL STR0018 OF oPesqOS PIXEL //Filtro

// Status
@ aPosObj[1,1] + 08, aPosObj[1,2] + 4 SAY oDat VAR STR0019 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Status
@ aPosObj[1,1] + 07, aPosObj[1,2] + 25 MSCOMBOBOX oCbStat VAR cCbStat ITEMS aCbStat SIZE 125,08 OF oPesqOS PIXEL//;
// Fim Status

// Filial
@ aPosObj[1,1] + 08, aPosObj[1,2] + 157 SAY oFil VAR STR0020 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Filial
@ aPosObj[1,1] + 07, aPosObj[1,2] + 172 MSGET oFilFtr VAR cFilFtr F3 "SM0_01" SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLACK
// Fim Filial

// Tipo
@ aPosObj[1,1] + 08, aPosObj[1,2] + 235 SAY oTip VAR STR0026 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Tipo
@ aPosObj[1,1] + 07, aPosObj[1,2] + 250 MSCOMBOBOX oTipo VAR cTipo ITEMS aTipo SIZE 48,08 OF oPesqOS PIXEL//;
// Fim Tipo

// Reserva
@ aPosObj[1,1] + 08, aPosObj[1,2] + 310 SAY oReserv VAR STR0022 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Reserva
@ aPosObj[1,1] + 07, aPosObj[1,2] + 335 MSCOMBOBOX oReserva VAR cReserva ITEMS aReserva SIZE 40,08 OF oPesqOS PIXEL//;
// Fim Reserva

// Data
@ aPosObj[1,1] + 20, aPosObj[1,2] + 4 SAY oData VAR STR0023 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Data
@ aPosObj[1,1] + 19, aPosObj[1,2] + 25 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni > dDatFim, dDatFim := dDatIni, .T.));
	PICTURE "@D" SIZE 45,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1] + 20, aPosObj[1,2] + 73 SAY oDatate VAR STR0024 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE //ate
@ aPosObj[1,1] + 19, aPosObj[1,2] + 83 MSGET odatFim VAR dDatFim VALID(IIF(dDatIni > dDatFim, .F., .T.));
	PICTURE "@D" SIZE 45,08 OF oPesqOS PIXEL COLOR CLR_BLACK
// Fim Data


// Vencimento
@ aPosObj[1,1] + 20, aPosObj[1,2] + 137 SAY oData VAR STR0074 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Vencimento
@ aPosObj[1,1] + 19, aPosObj[1,2] + 170 MSGET oDtVIni VAR dDtVIni VALID(IIF(dDtVIni > dDtVFin, dDtVFin := dDtVIni, .T.));
	PICTURE "@D" SIZE 45,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1] + 20, aPosObj[1,2] + 218 SAY oDtVAte VAR STR0024 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE //ate
@ aPosObj[1,1] + 19, aPosObj[1,2] + 228 MSGET oDtVFin VAR dDtVFin VALID(IIF(dDtVIni > dDtVFin, .F., .T.));
	PICTURE "@D" SIZE 45,08 OF oPesqOS PIXEL COLOR CLR_BLACK
// Fim Data

// Peça
@ aPosObj[1,1] + 32, aPosObj[1,2] + 04 SAY oPecItem VAR STR0025 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Peca
@ aPosObj[1,1] + 31, aPosObj[1,2] + 25 MSGET oCodPec VAR cCodPec VALID(Processa({|| FS_PECITE() }));
	SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK
// Fim Peça

// Veículo
@ aPosObj[1,1] + 32, aPosObj[1,2] + 117 SAY oChass VAR STR0021 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Veiculo
@ aPosObj[1,1] + 31, aPosObj[1,2] + 140 MSGET oChassi VAR cChassi PICTURE "@!";
	VALID(FG_POSVEI("cChassi",), oChassi:Refresh()) SIZE 95,08 OF oPesqOS PIXEL COLOR CLR_BLACK
// Fim Veículo

// Registros Filtrados
@ aPosObj[1,1] + 08, aPosObj[1,4] - 230 SAY oRegSel VAR Alltrim(str(cRegSel)) + " " + STR0029 SIZE 100,08 OF oPesqOS PIXEL;
	COLOR CLR_BLUE //registro(s) filtrado(s)
// Fim Registros Filtrados

// Cliente
@ aPosObj[1,1] + 44, aPosObj[1,2] + 004 SAY oClient VAR STR0027 SIZE 20,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Cliente
@ aPosObj[1,1] + 43, aPosObj[1,2] + 025 MSGET oCodCli VAR cCodCli F3 "VSA" SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLACK WHEN ( !Empty(cCodCli) .or. Empty(cNomCli) )
@ aPosObj[1,1] + 43, aPosObj[1,2] + 065 MSGET oLojCli VAR cLojCli SIZE 20,08 OF oPesqOS PIXEL COLOR CLR_BLACK WHEN ( !Empty(cLojCli) .or. Empty(cNomCli) )
@ aPosObj[1,1] + 43, aPosObj[1,2] + 088 MSGET oNomCli VAR cNomCli PICTURE "@!" SIZE 100,08 OF oPesqOS PIXEL COLOR CLR_BLACK WHEN Empty(cCodCli+cLojCli)
@ aPosObj[1,1] + 44, aPosObj[1,2] + 190 CHECKBOX oNoCli VAR lNomCli PROMPT "" OF oPesqOS SIZE 40,10 PIXEL WHEN Empty(cCodCli+cLojCli)
@ aPosObj[1,1] + 44, aPosObj[1,2] + 199 SAY opNome VAR (STR0069) SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Parte Nome
// Fim Cliente

// Vendedor
@ aPosObj[1,1] + 44, aPosObj[1,2] + 238 SAY oVend VAR STR0028 SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Vendedor
@ aPosObj[1,1] + 43, aPosObj[1,2] + 265 MSGET oCodVend VAR cCodVend F3 "SA31" SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLACK WHEN ( ( !Empty(cCodVend) .or. Empty(cNomVen) ) .and. VAI->VAI_OUTVEN == "1" )
@ aPosObj[1,1] + 43, aPosObj[1,2] + 309 MSGET oNomVen VAR cNomVen PICTURE "@!" SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK WHEN ( Empty(cCodVend) .and. VAI->VAI_OUTVEN == "1" )
// Fim Vendedor

// Botões
@ aPosObj[1,1] + 07, aPosObj[1,4] - 100 BUTTON oFintra PROMPT (STR0030) OF oPesqOS SIZE 47,10 PIXEL; //FILTRAR
	ACTION (FS_OC430(cCbStat, cFilFtr, dDatIni, dDatFim, cCodCli, cLojCli, cNomCli, cCodVend, cNomVen, cChassi, cReserva, cTipo),;
	FS_LEVPC(aListOrc[oLstAgen:nAt,14], @aPecOrc, @aSerOrc, Left(aListOrc[oLstAgen:nAt,2], TamSX3("VS1_FILIAL")[1])))

@ aPosObj[1,1] + 07, aPosObj[1,4] - 50 BUTTON oLimFil PROMPT (STR0031) OF oPesqOS SIZE 47,10 PIXEL;// LIMPAR FILTRO
	ACTION (FS_LIMFIL(@cCbStat, @aCbStat, @cReserva, @cTipo, @dDatIni, @dDatFim, @cFilFtr, @cCodCli, @cLojCli,;
	@cNomCli, @cCodVend, @cNomVen, @cCodPec, @aListOrc, @aPecOrc, @aSerOrc)) //oPesqOS:End()

@ aPosObj[1,1] + 19, aPosObj[1,4] - 50 BUTTON oLimFil PROMPT (STR0073) OF oPesqOS SIZE 47,10 PIXEL;// VISUALIZAR
	ACTION (FS_VISORC(aListOrc[oLstAgen:nAt,14], Left(aListOrc[oLstAgen:nAt,2], TamSX3("VS1_FILIAL")[1]))) //oPesqOS:End()

@ aPosObj[1,1] + 31, aPosObj[1,4] - 50 BUTTON oLegenda PROMPT UPPER(STR0072) OF oPesqOS SIZE 47,10 PIXEL ACTION OC430011_Legenda_Orcamentos() // LEGENDA

@ aPosObj[1,1] + 43, aPosObj[1,4] - 50 BUTTON oSair PROMPT (STR0032) OF oPesqOS SIZE 47,10 PIXEL ACTION oPesqOS:End() // SAIR

// Fim Botões
// Fim Cabeçalho

// Listagem Orçamento por Fases
@ aPosObj[2,1], aPosObj[2,2] LISTBOX oLstAgen FIELDS HEADER "", STR0020, STR0033, STR0034, STR0035, STR0036,;// Filial / Orcamento / Tipo Orcamento / Faturar Para / Loja
	STR0037, STR0038, STR0039, STR0040, STR0041, STR0042, STR0043, STR0028; // Nome Cliente / Total da NF / Marca / Data Orcamento / Hora Orcamento / Validade/ Nf - Serie / Vendedor
	COLSIZES 10, 80, 35, 43, 40, 15, 100, 35, 25, 50, 50, 30, 50, 50;
	SIZE aPosObj[2,4] - 2, aPosObj[2,3] - aPosObj[1,3] - 2 OF oPesqOS PIXEL;
	ON DBLCLICK (FS_POSVS1(aListOrc[oLstAgen:nAt,14], aListOrc[oLstAgen:nAt,16], Left(aListOrc[oLstAgen:nAt,2], TamSX3("VS1_FILIAL")[1]), lNoBrowse));
	ON CHANGE (FS_LEVPC(aListOrc[oLstAgen:nAt,14], @aPecOrc, @aSerOrc, Left(aListOrc[oLstAgen:nAt,2], TamSX3("VS1_FILIAL")[1]))) // numero do agendamento - arary pecas - array servicos
// Fim Listagem Orçamento por Fases

// SetArray Vetor de Orcamentos
OC430VETORC()
// Fim SetArray Vetor de Orcamentos

// Listagem Peças e Serviços
@ aPosObj[3,1], aPosObj[3,2] FOLDER oFolder SIZE aPosObj[3,4] - 2, aPosObj[3,3] - aPosObj[2,3] - 2 OF oPesqOS;
	PROMPTS STR0015, STR0050 PIXEL // Peças / Serviços

// Listagem Peças da Ordem de Serviço
@ 002,002 LISTBOX oPecOS FIELDS HEADER STR0044,; // Grupo
	STR0045,                                   ; // Código
	STR0046,                                   ; // Descrição
	STR0047,                                   ; // Quantidade
	STR0048,                                   ; // Valor Bruto
	STR0049,                                   ; // % Desconto
	STR0052                                    ; // Valor Total
	COLSIZES 50, 70, 50, 50, 50, 50, 50 SIZE aPosObj[3,4] - 7, 105 OF oFolder:aDialogs[1] PIXEL

oPecOS:SetArray(aPecOrc)

oPecOS:bLine := { || { aPecOrc[oPecOS:nAt,1],                          ;
	aPecOrc[oPecOS:nAt,2],                                             ;
	aPecOrc[oPecOS:nAt,3],                                             ;
	Transform(aPecOrc[oPecOS:nAt,4], "@E 999,999"),                    ;
	FG_AlinVlrs(Transform(aPecOrc[oPecOS:nAt,5], "@E 999,999,999.99")),;
	aPecOrc[oPecOS:nAt,6],                                             ;
	FG_AlinVlrs(Transform(aPecOrc[oPecOS:nAt,7], "@E 999,999,999.99")) ;
}}
// Fim Listagem Peças da Ordem de Serviço

// Listagem Serviços da Ordem de Serviço
@ 002,002 LISTBOX oSerOS FIELDS HEADER STR0044,; // Grupo
	STR0045,                                   ; // Código
	STR0046,                                   ; // Descrição
	STR0051,                                   ; // Tempo Padrão
	STR0048,                                   ; // Valor Bruto
	STR0049,                                   ; // % Desconto
	STR0052                                    ; // Valor Total
	COLSIZES 50, 70, 50, 50, 50, 50, 50 SIZE aPosObj[3,4] - 7, 105 OF oFolder:aDialogs[2] PIXEL

oSerOS:SetArray(aSerOrc)

oSerOS:bLine := { || { aSerOrc[oSerOS:nAt,1],                          ;
	aSerOrc[oSerOS:nAt,2],                                             ;
	aSerOrc[oSerOS:nAt,3],                                             ;
	Transform(aSerOrc[oSerOS:nAt,4], "@R 99:99"),                      ;
	FG_AlinVlrs(Transform(aSerOrc[oSerOS:nAt,5], "@E 999,999,999.99")),;
	aSerOrc[oSerOS:nAt,6],                                             ;
	FG_AlinVlrs(Transform(aSerOrc[oSerOS:nAt,7], "@E 999,999,999.99")) ;
}}
// Fim Listagem Serviços da Ordem de Serviço
// Fim Listagem Peças e Serviços

ACTIVATE MSDIALOG oPesqOS

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OC430 | Autor ³ Rafael Goncalves      ³Data  ³ 11/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza o levantamento das informacoes                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1-Opcao do combo - "" = todas                              ³±±
±±³          ³ 2-Filial                                                   ³±±
±±³          ³ 3-Data Inicial                                             ³±±
±±³          ³ 4-Data Final                                               ³±±
±±³          ³ 5-Codigo do cliente                                        ³±±
±±³          ³ 6-Loja do Cliente                                          ³±±
±±³          ³ 7-Nome do cliente                                          ³±±
±±³          ³ 8-Codigo do Vendedo                                        ³±±
±±³          ³ 8-Nome do vendedor                                         ³±±
±±³          ³ 9-Chassi do veiculo                                        ³±±
±±³          ³10-Se mostra orcamento reservados ou nao / "" indiferente   ³±±
±±³          ³11-Tipo de orcamento a ser filtrado                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OC430(cCbStat,cFilFtr,dDatIni,dDatFim,cCodCli,cLojCli,cNomCli,cCodVend,cNomVen,cChassi,cReserva,cTipo)
Local cQAlVS1 	:= "SQLVS1"
Local cQuery	:= ""
Local cPARGVei 	:= left(GetMv("MV_GRUVEI")+space(4),4)
Local cPARGSrv 	:= left(GetNewPar("MV_GRUSRV","SRVC")+space(4),4)
Local nCont
Local nPosStat := 0

Local aFilAtu		:= {} // Informacoes da Filial Atual ...
Local aSM0			:= {} // Filiais para Executar SELECT 
Local cBkpFilAnt	:= cFilAnt
Local cAuxNomFilial

Default cCbStat := "" 	//Status
Default cFilFtr	:= "" 	// Filial
Default dDatIni	:= ctod("")//data Inicial
Default dDatFim := ctod("")//Ddata Final
Default cCodCli	:="" 	//Codigo Cliente
Default cLojCli	:="" 	//loja cliente
Default cCodVend:=""	//codigo vendedor
Default cNomCli :=""	//nome cliente
Default cNomVen :="" 	//nome vendedor
Default cChassi :=""	//Chassi do veiculo
Default cReserva:=""	//mostra reservados. 0-Nao / 1-Sim
Default cTipo 	:= STR0014 //tipo de orcamento a ser filtrado.

if VAI->VAI_OUTFIL == "1"
	 aFilAtu := FWArrFilAtu()
	 aSM0 := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Else
	aAdd( aSM0, cFilAnt )
Endif

if !Empty(cCbStat) .AND. cCbStat <> STR0001 // Filtrar por Status
	nPosStat := ascan( aCbStat , cCbStat )
EndIf

cRegSel := 0
aListOrc:={}
                        
For nCont := 1 to Len(aSM0)
                          
	if !Empty(cFilFtr)  .and. cFilFtr <> aSM0[nCont]
		Loop		
	Endif
	cFilAnt := aSM0[nCont]
	cAuxNomFilial := FWFIlialName(,,1)

	cQuery := "SELECT DISTINCT VS1.VS1_NUMORC , VS1.VS1_STATUS , VS1.VS1_FILIAL , VS1.VS1_TIPORC , VS1.VS1_PEDSTA , VS1.VS1_CLIFAT , VS1.VS1_LOJA , VS1.VS1_NCLIFT"
	cQuery +=       " , VS1.VS1_VTOTNF , VS1.VS1_CODMAR , VS1.VS1_DATORC , VS1.VS1_HORORC , VS1.VS1_DATVAL , VS1.VS1_NUMNFI , VS1.VS1_SERNFI "
	cQuery +=       " , SA3.A3_COD , SA3.A3_NREDUZ "
	cQuery +=  " FROM "+RetSqlName("VS1")+" VS1 "
	cQuery +=        " JOIN "+RetSqlName("SA3")+" SA3 ON (SA3.A3_FILIAL='"+xFilial("SA3")+"' AND VS1.VS1_CODVEN=SA3.A3_COD AND SA3.D_E_L_E_T_=' ') "
	If !Empty(cChassi)
		cQuery += " JOIN "+RetSqlName("VV1")+" VV1 ON (VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VS1.VS1_CHAINT=VV1.VV1_CHAINT AND VV1.VV1_CHASSI='"+cChassi+"') AND VV1.D_E_L_E_T_=' ' "
	EndIF
	// grupo do item selecionado for igual ao de servico            '
	If cGruPec == cPARGSrv
		If !Empty(cCodPec) //Servico
			cQuery += "JOIN "+RetSqlName("VS4")+" VS4 ON (VS4.VS4_FILIAL=VS1.VS1_FILIAL AND VS1.VS1_NUMORC=VS4.VS4_NUMORC AND VS4.VS4_CODSER='"+cCodPec+"' AND VS4.D_E_L_E_T_=' ') "
		EndIF
	ElseIf (!cGruPec==cPARGSrv .and. !cGruPec==cPARGVei)//se o grupo for diferente de servico e diferente de veiculo eh peca.
		If !Empty(cCodPec) //Servico
			DBSelectArea("SB1")   
			dbSetOrder(1)
			if MsSeek(xFilial("SB1")+cCodPec)
			   cCodI := SB1->B1_CODITE
			   cGrpI := SB1->B1_GRUPO
			Else
				DBSelectArea("SB1")   
				dbSetOrder(7)
				MsSeek(xFilial("SB1")+cCodPec)
				cCodI := SB1->B1_CODITE
	   		    cGrpI := SB1->B1_GRUPO
			Endif   
			cQuery += "JOIN "+RetSqlName("VS3")+" VS3 ON (VS3.VS3_FILIAL=VS1.VS1_FILIAL AND VS1.VS1_NUMORC=VS3.VS3_NUMORC AND VS3.VS3_GRUITE='"+cGrpI+"' AND VS3.VS3_CODITE='"+cCodI+"'  AND VS3.D_E_L_E_T_=' ') "
		EndIF
	EndIf
	cQuery += "WHERE "
	cQuery += " VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND "
	//verifica a data inicial
	If !Empty(dDatIni)
		cQuery += "VS1.VS1_DATORC>='"+dtos(dDatIni)+"' AND "
	EndIF
	//verifica a data fianl
	If !Empty(dDatFim)
		cQuery += "VS1.VS1_DATORC<='"+dtos(dDatFim)+"' AND "
	EndIF
	//verifica data de Vencimento
	If !Empty(dDtVIni)
		cQuery += "VS1.VS1_DATVAL>='"+dtos(dDtVIni)+"' AND "
	EndIf
	If !Empty(dDtVFin)
		cQuery += "VS1.VS1_DATVAL<='"+dtos(dDtVFin)+"' AND "
	EndIf
	//filtra codigo do cliente
	If !Empty(cCodCli+cLojCli)
		cQuery += "VS1.VS1_CLIFAT='"+cCodCli+"' AND VS1.VS1_LOJA='"+cLojCli+"' AND "
	elseif !Empty(cNomCli)
		If lNomCli//filtra contido nome do cliente
			cQuery += "VS1.VS1_NCLIFT LIKE '%"+ AllTrim(cNomCli)+"%' AND "
		Else //filtra pelo inicio do nome do cliente
			cQuery += "VS1.VS1_NCLIFT LIKE '"+ AllTrim(cNomCli)+"%' AND "
		EndIF
	EndIf
	//verifica o status
	Do Case
		Case nPosStat > 12 // Pedidos
			cQuery += "VS1.VS1_TIPORC='P' AND VS1.VS1_PEDSTA='"+aRelStat[nPosStat]+"' AND "
		Case nPosStat > 0 // Orçamentos
			cQuery += "VS1.VS1_TIPORC IN ('1','2') AND VS1.VS1_STATUS='"+aRelStat[nPosStat]+"' AND "
		Otherwise
			cQuery +="VS1.VS1_STATUS<>' ' AND "
	EndCase
	//filtra codigo do vendedor
	if VAI->VAI_OUTVEN == "1"
		If !Empty(cCodVend)
			cQuery += "VS1.VS1_CODVEN='"+cCodVend+"' AND "
		ElseIf !Empty(cNomVen)//fitlra descricao do nome vendedor.
			cQuery +=   "(VS1_CODVEN IN (SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_NOME LIKE '"+ AllTrim(cNomVen)+"%' AND D_E_L_E_T_ = ' ' ) "
			cQuery += "OR VS1_CODVE2 IN (SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_NOME LIKE '"+ AllTrim(cNomVen)+"%' AND D_E_L_E_T_ = ' ' ) "
			cQuery += "OR VS1_CODVE3 IN (SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_NOME LIKE '"+ AllTrim(cNomVen)+"%' AND D_E_L_E_T_ = ' ' ) "
			cQuery += "OR VS1_CODVE4 IN (SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_NOME LIKE '"+ AllTrim(cNomVen)+"%' AND D_E_L_E_T_ = ' ' ) "
			cQuery += "OR VS1_CODVE5 IN (SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_NOME LIKE '"+ AllTrim(cNomVen)+"%' AND D_E_L_E_T_ = ' ' )) AND "
		EndIf
	else
		cQuery += "VS1.VS1_CODVEN='"+cCodVend+"' AND "
	endif	
	If cTipo == "1"
		cQuery += " VS1.VS1_TIPORC IN ('1','P') AND "
	elseif cTipo == "2"
		cQuery += " VS1.VS1_TIPORC='2' AND "
	else // Todos
		cQuery += " VS1.VS1_TIPORC IN ('1','2','P') AND "
	EndIf
	cQuery += "VS1.D_E_L_E_T_=' '"

	//Reservado
	If !Empty(cReserva)
		cQuery += Iif(cReserva=="1"," AND EXISTS "," AND NOT EXISTS ")
		cQuery += "( SELECT VE6.VE6_NUMORC FROM "+RetSqlName("VE6")+" VE6 WHERE VE6.VE6_FILIAL='"+xFilial("VE6")+"' AND VE6.VE6_INDREG='3' AND VE6.VE6_NUMORC=VS1.VS1_NUMORC AND VE6.D_E_L_E_T_=' ' )"
	EndIF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1, .F., .T. )
	Do While !( cQAlVS1 )->( Eof() )
		Do Case
			Case ( cQAlVS1 )->( VS1_TIPORC ) == "1"
				cDescrTp := STR0093 // Orçamento Peças
			Case ( cQAlVS1 )->( VS1_TIPORC ) == "2"
				cDescrTp := STR0094 // Orçamento Oficina
			Otherwise
				cDescrTp := STR0095 // Pedido Peças
		EndCase
		Aadd(aListOrc,{ ( cQAlVS1 )->( VS1_STATUS ),;
						( cQAlVS1 )->( VS1_FILIAL )+" - " + cAuxNomFilial ,;
						( cQAlVS1 )->( VS1_NUMORC ) , ;
						cDescrTp ,;
						( cQAlVS1 )->( VS1_CLIFAT ) ,;
						( cQAlVS1 )->( VS1_LOJA ) ,;
						left(( cQAlVS1 )->( VS1_NCLIFT ),30),;
						FG_AlinVlrs(Transform(( cQAlVS1 )->( VS1_VTOTNF ),"@E 999,999,999.99")) ,;
						( cQAlVS1 )->( VS1_CODMAR ) ,;
						Transform(stod(( cQAlVS1 )->( VS1_DATORC )),"@D") ,;
						Transform(( cQAlVS1 )->( VS1_HORORC ),"@R 99:99"),;
						Transform(stod(( cQAlVS1 )->( VS1_DATVAL )),"@D") ,;
						( cQAlVS1 )->( VS1_NUMNFI ) +"-"+ FGX_UFSNF( ( cQAlVS1 )->( VS1_SERNFI ) ) , ;
						( cQAlVS1 )->( VS1_NUMORC ) ,;
						( cQAlVS1 )->( A3_NREDUZ ) ,;
						( cQAlVS1 )->( A3_COD ) ,;
						( cQAlVS1 )->( VS1_TIPORC ) ,;
						( cQAlVS1 )->( VS1_PEDSTA )	} )
		cRegSel:=cRegSel+1
		( cQAlVS1 )->( DbSkip() )
	EndDo
	( cQAlVS1 )->( dbCloseArea() )

Next nCont

cFilAnt := cBkpFilAnt

DBSelectArea("VS1")
OC430VETORC() // SetArray Vetor de Orcamentos

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OC430VETORC| Autor ³ Andre Luis Almeida   ³Data  ³ 06/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ListBox dos Orcamentos - SetArray do Vetor no objeto       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC430VETORC()
If Len(aListOrc) <= 0
	aadd(aListOrc,{"","","","","","","","","",ctod(""),"",ctod(""),"","","","","",""})
EndIF      
oLstAgen:nAt := 1
oLstAgen:SetArray(aListOrc)
oLstAgen:bLine := { || {IIf(aListOrc[oLstAgen:nAt,17]<>"P",;
							IIf(aListOrc[oLstAgen:nAt,1]=="0",oVerd,;
							IIf(aListOrc[oLstAgen:nAt,1]=="2",oPink,;
							IIf(aListOrc[oLstAgen:nAt,1]=="3",oBranc,;
							IIf(aListOrc[oLstAgen:nAt,1]=="4",oAzul,;
							IIf(aListOrc[oLstAgen:nAt,1]=="5",oMarr,;
							IIf(aListOrc[oLstAgen:nAt,1]=="F",oAmar,;
							IIf(aListOrc[oLstAgen:nAt,1]=="G",oAzulC,;
							IIf(aListOrc[oLstAgen:nAt,1]=="I",oLara,;
							IIf(aListOrc[oLstAgen:nAt,1]=="C",oVerm,oPret)))))))));
						,;
							IIf(aListOrc[oLstAgen:nAt,18]=="0",oVerd,;
							IIf(aListOrc[oLstAgen:nAt,18]=="1",oAmar,;
							IIf(aListOrc[oLstAgen:nAt,18]=="2",oPret,oVerm)));
						),;
						aListOrc[oLstAgen:nAt,2],;
						aListOrc[oLstAgen:nAt,3],;
						aListOrc[oLstAgen:nAt,4],;
						aListOrc[oLstAgen:nAt,5],;
						aListOrc[oLstAgen:nAt,6],;
						aListOrc[oLstAgen:nAt,7],;
						aListOrc[oLstAgen:nAt,8],;
						aListOrc[oLstAgen:nAt,9],;
						aListOrc[oLstAgen:nAt,10],;
						aListOrc[oLstAgen:nAt,11],;
						aListOrc[oLstAgen:nAt,12],;
						aListOrc[oLstAgen:nAt,13],;
						aListOrc[oLstAgen:nAt,15]}}
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PECITE| Autor ³ Rafael Goncalves      ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ pesquisa iten no SB1 e depois no VB1                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PECITE()
Local cQuery   := ""
Local cQAlSB1  := "SQLSB1"
Local cPARGVei := left(GetMv("MV_GRUVEI")+space(4),4)
Local aPecSel  := {}
Local nPos	   := 0

If Vazio(cCodPec)
	Return(.t.)
EndIf

ProcRegua( RecCount() )

If !Empty(cCodPec)
	IncProc((STR0062)) //Levantando informacoes
	cQuery := "SELECT SB1.B1_COD , SB1.B1_DESC , SB1.B1_CODITE , VB1.VB1_KEYALT , SB1.B1_GRUPO FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += "LEFT JOIN "+RetSqlName("VB1")+" VB1 ON (VB1.VB1_FILIAL='"+xFilial("VB1")+"' AND VB1.VB1_COD = SB1.B1_COD AND VB1.D_E_L_E_T_=' ') "
	cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND ("
	cQuery += "SB1.B1_COD LIKE '%"+ AllTrim(UPPER(cCodPec))+"%' OR "		//codigo
	cQuery += "SB1.B1_CODITE LIKE '%"+ AllTrim(UPPER(cCodPec))+"%' OR "	//codite
	cQuery += "VB1.VB1_KEYALT LIKE '%" + AllTrim(UPPER(cCodPec)) + "%' OR "	//alternativo
	cQuery += "SB1.B1_DESC LIKE '%"+ AllTrim(UPPER(cCodPec))+"%') AND "		//descricao
	cQuery += "SB1.B1_GRUPO<>'"+cPARGVei+"' AND SB1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
	If !( cQAlSB1 )->( Eof() )
		( cQAlSB1 )->( DbGotop() )
		While !( cQAlSB1 )->( Eof() )
			nPos := 0
			nPos := aScan(aPecSel,{|x| x[1] == ( cQAlSB1 )->( B1_COD ) })
			if nPos <= 0
				AADD(aPecSel,{( cQAlSB1 )->( B1_COD ) , ( cQAlSB1 )->( B1_GRUPO ) , ( cQAlSB1 )->( B1_DESC ) , ( cQAlSB1 )->( B1_CODITE )	 , ( cQAlSB1 )->( VB1_KEYALT ) })
			EndIf
			IncProc((STR0063)) //Carregando informacoes
			( cQAlSB1 )->( DbSkip() )
		EndDo
	EndIf
	( cQAlSB1 )->( dbCloseArea() )
	DBSelectArea("VS1")
	
	If Len(aPecSel) > 1
		
		DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,080 TITLE (STR0064) OF oMainWnd // Cadastros Encontrados
		@ 001,001 LISTBOX olBox2 FIELDS HEADER (STR0045),; // Codigo Alternativo
		(STR0044),; // Grupo
		(STR0065),; // Cod. Item
		(STR0046),; // Descricao
		(STR0066);  // Alternativo
		COLSIZES 50,20,60,20,65 SIZE 315,111 OF oDesVB1 PIXEL ON DBLCLICK (nPos := olBox2:nAt, oDesVB1:END())
		olBox2:SetArray(aPecSel)
		olBox2:bLine := { || {  	aPecSel[olBox2:nAt,1] ,;
		aPecSel[olBox2:nAt,2] ,;
		aPecSel[olBox2:nAt,4] ,;
		aPecSel[olBox2:nAt,3] ,;
		aPecSel[olBox2:nAt,5] }}
		ACTIVATE MSDIALOG oDesVB1 CENTER
		
		If nPos != 0
			cCodPec:=aPecSel[nPos,1]
			cGruPec:=aPecSel[nPos,2]
		EndIf
	Elseif Len(aPecSel) = 1 // se encontrar somente 1 registro não exibe tela p
		cCodPec:=aPecSel[1,1]
		cGruPec:=aPecSel[1,2]
	Else
		cCodPec:=space(Len(SB1->B1_COD))
		cGruPec:=space(Len(SB1->B1_GRUPO))
	EndIf
EndIf

oCodPec:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVPC | Autor ³ Rafael Goncalves      ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levante pecas e servicos so orcamento selecionado          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - numero do orcamento                                    ³±±
±±³          ³ 2 - Array de Pecas                                         ³±±
±±³          ³ 3 - Array de Servicos                                      ³±±
±±³          ³ 4 - Filial do Orcamento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVPC(cNumOrc,aPecOrc,aSerOrc,cFilVS1)
Local cQuery1   := ""
Local cQAlVS3  := "SQLVS3"
Local cQuery2   := ""
Local cQAlVS4  := "SQLVS4"

Default cNumOrc := ""

aPecOrc:={}//ZERA ARRAY DE PECAS
aSerOrc:={}//ZERA ARRAY DE SERVICOS

if !Empty(cNumOrc)
	//Levante pecas do orcamento.
	cQuery1 := "SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , VS3.VS3_QTDITE , VS3.VS3_VALPEC , VS3.VS3_PERDES , VS3.VS3_VALTOT "
	cQuery1 += "  FROM "+RetSqlName("VS3")+" VS3 "
	cQuery1 += "  LEFT JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.B1_FILIAL='"+xFilial("SB1")+"' AND VS3.VS3_GRUITE=SB1.B1_GRUPO AND VS3.VS3_CODITE=SB1.B1_CODITE AND SB1.D_E_L_E_T_=' ')"
	cQuery1 += " WHERE VS3.VS3_FILIAL='"+cFilVS1+"'"
	cQuery1 += "   AND VS3.VS3_NUMORC='"+cNumOrc+"'"
	cQuery1 += "   AND VS3.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery1 ), cQAlVS3, .F., .T. )
	While !( cQAlVS3 )->( Eof() )
		AADD(aPecOrc,{( cQAlVS3 )->( B1_GRUPO ) , ( cQAlVS3 )->( B1_CODITE ) , ( cQAlVS3 )->( B1_DESC )  , ( cQAlVS3 )->( VS3_QTDITE ) , ( cQAlVS3 )->( VS3_VALPEC ) , ( cQAlVS3 )->( VS3_PERDES ) , ( cQAlVS3 )->( VS3_VALTOT ) })
		( cQAlVS3 )->( DbSkip() )
	EndDo
	( cQAlVS3 )->( dbCloseArea() )
	DBSelectArea("VS1")
	//Levante Servicos do orcamento.
	cQuery2 := "SELECT VS4.VS4_TIPSER , VS4.VS4_CODSER , VS4.VS4_TEMPAD , VS4.VS4_VALSER , VS4.VS4_PERDES , VS4.VS4_VALTOT , VO6.VO6_DESSER "
	cQuery2 += "  FROM "+RetSqlName("VS4")+" VS4 "
	if Empty(xFilial("VO6"))
		cQuery2 += " LEFT JOIN "+RetSqlName("VO6")+" VO6 ON (VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND VO6.VO6_CODSER=VS4.VS4_CODSER AND VO6.D_E_L_E_T_=' ') "
	else
		cQuery2 += " LEFT JOIN "+RetSqlName("VO6")+" VO6 ON (VO6.VO6_FILIAL='"+cFilVS1+"' AND VO6.VO6_CODSER=VS4.VS4_CODSER AND VO6.D_E_L_E_T_=' ') "
	endif
	cQuery2 += " WHERE VS4.VS4_FILIAL='"+cFilVS1+"'"
	cQuery2 += "   AND VS4.VS4_NUMORC='"+cNumOrc+"'"
	cQuery2 += "   AND VS4.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cQAlVS4, .F., .T. )
	While !( cQAlVS4 )->( Eof() )
		AADD(aSerOrc,{( cQAlVS4 )->( VS4_TIPSER ) , ( cQAlVS4 )->( VS4_CODSER ) , ( cQAlVS4 )->( VO6_DESSER ) , ( cQAlVS4 )->( VS4_TEMPAD ) , ( cQAlVS4 )->( VS4_VALSER ) , ( cQAlVS4 )->( VS4_PERDES ) , ( cQAlVS4 )->( VS4_VALTOT ) })
		( cQAlVS4 )->( DbSkip() )
	EndDo
	( cQAlVS4 )->( dbCloseArea() )
	DBSelectArea("VS1")
EndIF

If Len(aPecOrc) <= 0
	aadd(aPecOrc,{"","","",0,0,"",0})
EndIF

If Len(aSerOrc) <= 0
	aadd(aSerOrc,{"","","","",0,"",0})
EndIF

oPecOS:SetArray(aPecOrc)
oPecOS:bLine := { || {  aPecOrc[oPecOS:nAt,1] ,;
aPecOrc[oPecOS:nAt,2] ,;
aPecOrc[oPecOS:nAt,3] ,;
Transform( aPecOrc[oPecOS:nAt,4] , "@E 999,999") ,;
FG_AlinVlrs(Transform(aPecOrc[oPecOS:nAt,5],"@E 999,999,999.99")) ,;
aPecOrc[oPecOS:nAt,6] ,;
FG_AlinVlrs(Transform(aPecOrc[oPecOS:nAt,7],"@E 999,999,999.99")) }}

oSerOS:SetArray(aSerOrc)
oSerOS:bLine := { || {  aSerOrc[oSerOS:nAt,1] ,;
aSerOrc[oSerOS:nAt,2] ,;
aSerOrc[oSerOS:nAt,3] ,;
Transform(aSerOrc[oSerOS:nAt,4],"@R 99:99"),;
FG_AlinVlrs(Transform(aSerOrc[oSerOS:nAt,5],"@E 999,999,999.99")) ,;
aSerOrc[oSerOS:nAt,6] ,;
FG_AlinVlrs(Transform(aSerOrc[oSerOS:nAt,7],"@E 999,999,999.99")) }}

oPecOS:Refresh()
oSerOS:Refresh()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_POSVS1| Autor ³ Rafael Goncalves      ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posiciona no VS1 para retornar ao mBrowse no reg.correto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1- Numero do Orcamento                                     ³±±
±±³          ³ 2- Codigo do Usuario                                       ³±±
±±³          ³ 3- Filial do Orcamento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSVS1(cNumOrc, cCodUsu, cFilialVS1, lNoBrowse)
Local lRet := .f.

If lNoBrowse
	MsgInfo(STR0071) // A funcionalidade de duplo clique para posicionamento no browse da rotina está disponível apenas para as rotinas Orc. Por Fases (OFIXA011) e Funções Oficina (OFIXA120)
	Return .f.
EndIf

If Empty(cNumOrc)
	MsgInfo(STR0070) // Nao existe dados para esta pesquisa
	Return .f.
EndIf

Default cFilialVS1 := xFilial("VS1")

DbSelectArea("VAI")
DbSetOrder(4)

If DbSeek( xFilial("VAI") + __CUSERID )
	If VAI->VAI_OUTVEN == "1"
		DbSelectArea("VS1")
		DbSetOrder(1)

		DbSeek( cFilialVS1 + cNumOrc )

		oPesqOS:End()

		lRet := .t.
	ElseIf VAI->VAI_OUTVEN == "0"
		DbSelectArea("SA3")
		DbSetOrder(1)

		If DbSeek( xFilial("SA3") + VAI->VAI_CODVEN )
			If SA3->A3_COD == cCodUsu
				DbSelectArea("VS1")
				DbSetOrder(1)

				DbSeek( cFilialVS1 + cNumOrc )

				oPesqOS:End()

				lRet := .t.
			EndIf
		EndIf
	EndIf
EndIf

If !lRet
	MsgInfo(STR0067, STR0068) // Usuário sem permissão para visualizar este orçamento / Atenção
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LIMFIL| Autor ³ Rafael Goncalves      ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posiciona no VS1 para retornar ao mBrowse no reg.correto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Todas as variaveis de componente                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMFIL(cCbStat,aCbStat,cReserva,cTipo,dDatIni,dDatFim,cFilFtr,cCodCli,cLojCli,cNomCli,cCodVend,cNomVen,cCodPec,aListOrc,aPecOrc,aSerOrc)

cCbStat := STR0001
cReserva:= ""
cTipo   := STR0014
dDatIni := ctod("01/"+StrZero(Month(dDataBase),2)+"/"+Substr(StrZero(Year(dDataBase),4),3,2))//ctod("")
dDatFim := dDataBase//ctod("")
cFilFtr := space(len(SA1->A1_FILIAL))
cCodCli := space(Len(SA1->A1_COD))
cLojCli := space(Len(SA1->A1_LOJA))
cNomCli := space(21)
cCodPec := space(Len(SB1->B1_COD))		//codigo da peca ou servico
cGruPec := space(Len(SB1->B1_GRUPO))	//codigo da peca ou servico
cChassi := space(Len(VV1->VV1_CHASSI))
cRegSel := 0

DbSelectArea("VAI")
DbSetOrder(4)
If DbSeek( xFilial("VAI") + __CUSERID )
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3") + VAI->VAI_CODVEN )
		cCodVend:= SA3->A3_COD
		cNomVen := SA3->A3_NOME
	EndIf
EndIF

aListOrc:={}
aPecOrc:={}
aSerOrc:={}

aadd(aPecOrc,{"","","",0,0,"",0})
aadd(aSerOrc,{"","","","",0,"",0})

OC430VETORC() // SetArray Vetor de Orcamentos

oPecOS:SetArray(aPecOrc)
oPecOS:bLine := { || {  aPecOrc[oPecOS:nAt,1] ,;
aPecOrc[oPecOS:nAt,2] ,;
aPecOrc[oPecOS:nAt,3] ,;
Transform( aPecOrc[oPecOS:nAt,4] , "@E 999,999") ,;
FG_AlinVlrs(Transform(aPecOrc[oPecOS:nAt,5],"@E 999,999,999.99")) ,;
aPecOrc[oPecOS:nAt,6] ,;
FG_AlinVlrs(Transform(aPecOrc[oPecOS:nAt,7],"@E 999,999,999.99")) }}

oSerOS:SetArray(aSerOrc)
oSerOS:bLine := { || {  aSerOrc[oSerOS:nAt,1] ,;
aSerOrc[oSerOS:nAt,2] ,;
aSerOrc[oSerOS:nAt,3] ,;
Transform(aSerOrc[oSerOS:nAt,4],"@R 99:99"),;
FG_AlinVlrs(Transform(aSerOrc[oSerOS:nAt,5],"@E 999,999,999.99")) ,;
aSerOrc[oSerOS:nAt,6] ,;
FG_AlinVlrs(Transform(aSerOrc[oSerOS:nAt,7],"@E 999,999,999.99")) }}

oPecOS:Refresh()
oSerOS:Refresh()
oLstAgen:Refresh()
oCbStat:Refresh()
oReserva:Refresh()
oTipo:Refresh()
oPesqOS:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VISORC| Autor ³ Manoel Filho          ³Data  ³ 07/05/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posiciona e Visualiza  Orçamento posicionado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1- Numero do Orcamento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VISORC(cNumOrc, cFilialVS1)
Default cNumOrc    := ""
Default cFilialVS1 := xFilial("VS1")

If Empty(cNumOrc)
	MsgInfo(STR0070) // Nao existe dados para esta pesquisa
	Return .f.
EndIf

OFIC170( cFilialVS1 , cNumOrc )

Return

/*/{Protheus.doc} OC430011_Legenda_Orcamentos()
Legenda Orcamentos

@author Andre Luis Almeida
@since 31/10/2019
@version undefined
@type function
/*/
Static Function OC430011_Legenda_Orcamentos()
Local aLegenda := {}
//
aadd(aLegenda, {'',STR0033}) // Orçamento
aadd(aLegenda, {'BR_VERDE',STR0053}) // Digitado
aadd(aLegenda, {'BR_PINK',STR0054}) // Margem Pendente
aadd(aLegenda, {'BR_BRANCO',STR0055}) // Avaliação de Crédito
aadd(aLegenda, {'BR_AZUL',STR0056}) // Aguardando Separação
aadd(aLegenda, {'BR_MARROM',STR0057}) // Aguardando Lib.Diverg.
aadd(aLegenda, {'BR_AZUL_CLARO',STR0097}) // Aguardando outro Orçamento
aadd(aLegenda, {'BR_AMARELO',STR0058}) // Liberado p/ Faturamento
aadd(aLegenda, {'BR_LARANJA',STR0059}) // Importando para OS
aadd(aLegenda, {'BR_VERMELHO',STR0060}) // Cancelado
aadd(aLegenda, {'BR_PRETO',STR0061}) // Faturado
aadd(aLegenda, {'',""})
aadd(aLegenda, {'',STR0075}) // Pedidos de Orçamento
aadd(aLegenda, {'BR_VERDE',STR0076}) // Aberto
aadd(aLegenda, {'BR_AMARELO',STR0077}) // Parcialmente Atendido
aadd(aLegenda, {'BR_VERMELHO',STR0060}) // Cancelado
aadd(aLegenda, {'BR_PRETO',STR0078}) // Encerrado
//
BrwLegenda(STR0033+" / "+STR0075,STR0072,aLegenda) // Orçamento / Pedidos de Orçamento / Legenda
//
Return