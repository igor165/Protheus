// ษออออออออหออออออออป
// บ Versao บ 68     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIVA350.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ VEIVA350 บ Autor ณ Andre Luis Almeida บ Data ณ  06/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Parametros das Rotinas                                     บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ ATENCAO:  Para inserir nova rotina, eh necessario incluir a mesma no  บฑฑ
ฑฑบ           vetor "aRotTot", atribuir todos os parametros da rotina na  บฑฑ
ฑฑบ           variavel "cParamet" e documentar nas "Rotinas disponiveis"  บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑบ Rotinas disponiveis:                                                  บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑบ   001 - Abertura de OS                                                บฑฑ
ฑฑบ   002 - Agendamento Oficina                                           บฑฑ
ฑฑบ   003 - Apontamento Eletronico                                        บฑฑ
ฑฑบ   004 - Atendimento de Veiculos                                       บฑฑ
ฑฑบ   005 - Cadastro de Veiculos                                          บฑฑ
ฑฑบ   006 - Cancelamento de OS                                            บฑฑ
ฑฑบ   007 - CEV                                                           บฑฑ
ฑฑบ   008 - Consulta de OS                                                บฑฑ
ฑฑบ   009 - Consulta de Painel de Oficina                                 บฑฑ
ฑฑบ   010 - Contagem de Estoque                                           บฑฑ
ฑฑบ   011 - Fechamento de OS                                              บฑฑ
ฑฑบ   012 - Integracao John Deere                                         บฑฑ
ฑฑบ   013 - Liberacao de OS                                               บฑฑ
ฑฑบ   014 - Movimentacoes de Veiculos                                     บฑฑ
ฑฑบ   015 - Orcamento                                                     บฑฑ
ฑฑบ   016 - Requisi็ใo de Pecas                                           บฑฑ
ฑฑบ   017 - Requisi็ใo de Servicos                                        บฑฑ
ฑฑบ   018 - Sugestao de Compras                                           บฑฑ
ฑฑบ   019 - Libera็ใo de Cr้dito da Oficina                               บฑฑ
ฑฑบ   020 - Requisi็ใo e Devolu็ใo de Ferramentas                         บฑฑ
ฑฑบ   021 - Painel Venda Pecas                                            บฑฑ
ฑฑบ   022 - Integra็ใo Scania	                                          บฑฑ
ฑฑบ   023 - Consulta de Pecas (Balcao/Oficina)                            บฑฑ
ฑฑบ   024 - Cadastro de Pecas                                             บฑฑ
ฑฑบ   025 - SIR	(Mitsubishi)                                              บฑฑ
ฑฑบ   026 - Auto-Center                                                   บฑฑ
ฑฑบ   027 - Etiqueta para Itens                                           บฑฑ
ฑฑบ   028 - Transferencia de Pecas                                        บฑฑ
ฑฑบ   029 - Conferencia de Pecas                                          บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametroณ aRotUsu ( vetor com as rotinas que o usuario tera acesso ) บฑฑ
ฑฑบ          ณ Exemplo:     aRotUsu := {"001","004","005",...}            บฑฑ
ฑฑบ          ณ              aRotUsu := {"*"} AXTABELA (todos parametros)  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA350(aRotUsu)
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ni        := 0
Local cRot      := ""
Private overd   := LoadBitmap( GetResources(), "BR_verde")    // parametro existente na base
Private overm   := LoadBitmap( GetResources(), "BR_vermelho") // parametro nao existente na base
Private aNewBot := {}   // Impressao
Private aPar    := {{"overm","","","",""}} // vetor dos parametros
Private aRot    := {}   // Rotinas disponiveis
Private aRotTot := {""} // Todas as Rotinas
Default aRotUsu := {}   // Rotinas que o usuario tem acesso
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Rotinas                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
aAdd(aRotTot,"001="+STR0012) // Abertura de OS
aAdd(aRotTot,"002="+STR0013) // Agendamento Oficina
aAdd(aRotTot,"003="+STR0014) // Apontamento Eletronico
aAdd(aRotTot,"004="+STR0010) // Atendimento de Veiculos
aAdd(aRotTot,"005="+STR0015) // Cadastro de Veiculos
aAdd(aRotTot,"006="+STR0016) // Cancelamento de OS
aAdd(aRotTot,"007="+STR0017) // CEV
aAdd(aRotTot,"008="+STR0018) // Consulta de OS
aAdd(aRotTot,"009="+STR0019) // Consulta de Painel de Oficina
aAdd(aRotTot,"010="+STR0020) // Contagem de Estoque
aAdd(aRotTot,"011="+STR0021) // Fechamento de OS
aAdd(aRotTot,"012="+STR0011) // Integracao John Deere
aAdd(aRotTot,"013="+STR0022) // Liberacao de OS
aAdd(aRotTot,"014="+STR0023) // Movimentacoes de Veiculos
aAdd(aRotTot,"015="+STR0024) // Orcamento
aAdd(aRotTot,"016="+STR0025) // Requisicao de Pecas
aAdd(aRotTot,"017="+STR0026) // Requisicao de Servicos
aAdd(aRotTot,"018="+STR0027) // Sugestao de Compras
aAdd(aRotTot,"019="+STR0031) // Liberacao de Credito do Oficina
aAdd(aRotTot,"020="+STR0032) // Requisi็ใo e Devolu็ใo de Ferramentas
aAdd(aRotTot,"021="+STR0034) // Painel Venda Pecas
aAdd(aRotTot,"022="+STR0035) // Integra็ใo Scania
aAdd(aRotTot,"023="+STR0036) // Consulta de Pecas (Balcao/Oficina) 
aAdd(aRotTot,"024="+STR0039) // Cadastro de Pecas
aAdd(aRotTot,"025="+STR0040) // SIR (Mitsubishi)
aAdd(aRotTot,"026="+STR0041) // Auto-Center
aAdd(aRotTot,"027="+STR0042) // Etiqueta para Itens
aAdd(aRotTot,"028="+STR0043) // Transferencia de Pe็as
aAdd(aRotTot,"029="+STR0044) // Conferencia de Pe็as
//
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PE para manipular vetor das Rotinas   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("VA350ROT")
	aRotTot := ExecBlock("VA350ROT",.f.,.f.,{aRotTot})
EndIf
//
If len(aRotUsu) == 0 // Nao foi passado nenhuma rotina como parametro
	aRot := aClone(aRotTot) // disponibilizar todas as rotinas
Else // Foi passada rotinas como parametro
	If len(aRotUsu) == 1 // Apenas uma rotina
		cRot := aRotUsu[1]
		VEIVA350CAR(cRot,.f.) // Filtrar parametros da rotina
	Else // Varias rotinas
		aRot := {""}
	EndIf
	For ni := 1 to len(aRotTot)
		If Ascan(aRotUsu,SUBSTR(aRotTot[ni],1,3)) > 0 // verificar se usuario pode acessar a rotina
			aAdd(aRot,aRotTot[ni]) // adicionar a rotina
		EndIf
	Next
EndIf
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aObjects := {}
AAdd( aObjects, { 0, 21, .T. , .F. } ) // Pesquisar
AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox
aPos := MsObjSize( aInfo, aObjects )
//
AADD(aNewBot, {"IMPRESSAO",{|| FS_VA350IMP() },( STR0033 )} ) // Impressao
//
DEFINE MSDIALOG oParRot TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Parametros das Rotinas
oParRot:lEscClose := .F.
@ aPos[1,1]+00,aPos[1,2]+00 TO aPos[1,1]+21,85 LABEL STR0002 OF oParRot PIXEL // Parametro existente na Base?
@ aPos[1,1]+10,aPos[1,2]+14 BITMAP OXverd RESOURCE "BR_verde" OF oParRot NOBORDER SIZE 10,10 PIXEL
@ aPos[1,1]+10,aPos[1,2]+24 SAY STR0003 SIZE 30,8 OF oParRot PIXEL COLOR CLR_BLUE // Sim
@ aPos[1,1]+10,aPos[1,2]+47 BITMAP OXverm RESOURCE "BR_vermelho" OF oParRot NOBORDER SIZE 10,10 PIXEL
@ aPos[1,1]+10,aPos[1,2]+57 SAY STR0004 SIZE 30,8 OF oParRot PIXEL COLOR CLR_BLUE // Nao
@ aPos[1,1]+00,aPos[1,2]+85 TO aPos[1,1]+21,aPos[1,4] LABEL STR0009 OF oParRot PIXEL // Rotina
@ aPos[1,1]+07,aPos[1,2]+88 MSCOMBOBOX oRot VAR cRot SIZE aPos[1,4]-93,08 COLOR CLR_BLACK ITEMS aRot OF oParRot PIXEL ON CHANGE VEIVA350CAR(cRot,.t.) WHEN len(aRot) > 1
@ aPos[2,1],aPos[2,2] LISTBOX oLbPar FIELDS HEADER "",STR0005,STR0006,STR0007,STR0008 COLSIZES 10,40,20,80,(aPos[2,4]-170) SIZE aPos[2,4]-2,aPos[2,3]-30 OF oParRot PIXEL ON DBLCLICK VEIVA350ALT(oLbPar:nAt)
oLbPar:bHeaderClick := {|oObj,nCol| VEIVA350ORD(nCol) , } // Ordenar Parametros
oLbPar:SetArray(aPar)
oLbPar:bLine := { || { &(aPar[oLbPar:nAt,1]) , aPar[oLbPar:nAt,2] , aPar[oLbPar:nAt,3] , 	aPar[oLbPar:nAt,4] , aPar[oLbPar:nAt,5] }}
ACTIVATE MSDIALOG oParRot CENTER ON INIT EnchoiceBar(oParRot,{|| oParRot:End() },{ || oParRot:End()},,aNewBot)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA350ALTบ Autor ณ Andre Luis Almeida บ Data ณ  06/06/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Altera conteudo do Parametro                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA350ALT(nLinha)
Local aRet      := {}
Local aParamBox := {}
Local cMascara  := ""
Local xConteud
If aPar[nLinha,1] == "overd" // Parametro existente na Base
	xConteud := aPar[nLinha,4]
	Do Case
		Case aPar[nLinha,3] == "C" // Caracter
			cMascara := ""
			xConteud := left(xConteud+space(300),len(SX6->X6_CONTEUD))
		Case aPar[nLinha,3] == "N" // Numerico
			cMascara := "@E 9999999999999999999999999"
		Case aPar[nLinha,3] == "D" // Data
			cMascara := "@D"
			xConteud := left(xConteud+space(10),len(SX6->X6_CONTEUD))
		Case aPar[nLinha,3] == "L" // Logico
			cMascara := "@!"
			xConteud := left(xConteud+space(3),3)
	EndCase
	AADD(aParamBox,{ 1,STR0005,aPar[nLinha,2],"@!","","",".F.",50,.t.}) // Parametro
	AADD(aParamBox,{ 1,STR0006,aPar[nLinha,3],"@!","","",".F.",20,.t.}) // Tipo
	AADD(aParamBox,{ 1,STR0007,xConteud,cMascara,"","","",120,.f.}) // Conteudo
	AADD(aParamBox,{11,STR0008,aPar[nLinha,5],"",".f.",.t.}) // Descricao
	If ParamBox(aParamBox,STR0005,@aRet,,,,,,,,.f.) // Parametro
		aPar[nLinha,4] := aRet[03] // Atualizar vetor no listbox
		PutMv(aPar[nLinha,2],aRet[03]) // Gravar conteudo no parametro
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA350ORDบ Autor ณ Andre Luis Almeida บ Data ณ  06/06/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Ordenar listbox - vetor dos Parametros                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA350ORD(nCol)
Asort(aPar,,,{|x,y| x[nCol] < y[nCol] })
oLbPar:Refresh()
oLbPar:SetFocus()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA350CARบ Autor ณ Andre Luis Almeida บ Data ณ  06/06/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega os Parametros de uma determinada rotina            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA350CAR(cRot,lRefr)
Local ni       := 0
Local cParAux  := ""
Local cParamet := "" // Parametro(10 posicoes) + / ...
aPar := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros por Rotina ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case

	Case cRot == "*" // Todos os parametros da BASE
		DbSelectArea("SX6")
		DbSetOrder(1)
		DbGoTop()
		While !Eof()
			aAdd(aPar,{ "overd" , SX6->X6_VAR , SX6->X6_TIPO , Alltrim(X6Conteud()) , Alltrim(X6Descric())+" "+Alltrim(X6Desc1())+" "+Alltrim(X6Desc2()) })
			dbskip()
		Enddo		

	Case cRot == "001" // Abertura de OS
		cParamet += "MV_LIMCRE /MV_FICAOS /MV_VKILHOR/MV_PLIBDMP/MV_CHKCRE /MV_IPECSRV/MV_MIL0045/"

	Case cRot == "002" // Agendamento Oficina
		cParamet += "MV_AGPARAM/MV_INCORC /MV_EMCONTA/MV_RELSERV/MV_EMSENHA/MV_RELAUTH/MV_RELAUSR/MV_RELAPSW/MV_ENDLOGO/MV_MOBSEMA/" // 10
		cParamet += "MV_VPROAGE/MV_INCTTPA/MV_FMLPECA/"

	Case cRot == "003" // Apontamento Eletronico
		cParamet += "MV_TEMPTPR/MV_TEMPBOX/"

	Case cRot == "004" // Atendimento de Veiculos
		cParamet += "MV_1DUPREF/MV_AVEIMAX/MV_BLQSTAV/MV_BOTATEN/MV_BOTATF7/MV_BXVEI  /MV_CHKCRE /MV_DIRFTGC/MV_FIBTABR/MV_FIALLBC/" // 10
		cParamet += "MV_FIBCTBV/MV_FUNJEST/MV_GRUVEI /MV_LOCVEIC/MV_LOCVEIN/MV_LOCVEIU/MV_LOGALTV/MV_LOJAVEI/MV_MAPAPR /MV_MINCOMV/" // 20
		cParamet += "MV_MINCVDU/MV_MINCVLV/MV_NATCFVN/MV_NATCFVU/MV_NATCONN/MV_NATCONU/MV_NATENTN/MV_NATENTU/MV_NATFINN/MV_NATFINU/" // 30
		cParamet += "MV_NATFIVN/MV_NATFIVU/MV_NATFPRN/MV_NATFPRU/MV_NATRFVN/MV_NATRFVU/MV_NATTCVN/MV_NATTCVU/MV_NATVDIC/MV_NATVEIN/" // 40
		cParamet += "MV_NATVEIU/MV_NATVZ7N/MV_NATVZ7U/MV_PDSPNOV/MV_PDSPUSA/MV_PREFVEI/MV_PTITVEI/MV_RESERVT/MV_SIMB1  /MV_TABPAD /" // 50
		cParamet += "MV_TITATEN/MV_TMFCUFN/MV_TMFCUFD/MV_TOTCUFD/MV_TOTCUFN/MV_TPNRNFS/MV_MAPAVAL/MV_VTIPVEN/MV_VTITVEI/MV_VUCCTB /" // 60
		cParamet += "MV_GRUVEIA/MV_MIL0010/MV_MIL0014/MV_MIL0016/MV_MIL0018/MV_MIL0035/MV_MIL0040/MV_MIL0045/MV_MIL0046/MV_MIL0047/" // 70
		cParamet += "MV_MIL0048/MV_MIL0049/MV_MIL0050/MV_MIL0057/MV_MIL0061/"

	Case cRot == "005" // Cadastro de Veiculos
		cParamet += "MV_MIL0003/MV_GRUVEI /MV_TIPVEI /MV_MARGSOL/MV_NREPVV1/"

	Case cRot == "006" // Cancelamento de OS
		cParamet += "MV_1DUPREF/MV_PREFOFI/MV_VALCAN /MV_RESITE /MV_INTDL  /MV_RESLOC /"

	Case cRot == "007" // CEV
		cParamet += "MV_ABORDB /MV_ABORDO /MV_PREFVEI/MV_PREFBAL/MV_PREFOFI/MV_RELT   /MV_MIL0069/"

	Case cRot == "008" // Consulta de OS
		cParamet += "MV_INCORC /"

	Case cRot == "009" // Consulta de Painel de Oficina
		cParamet += "MV_DIRFTGC/"

	Case cRot == "010" // Contagem de Estoque
		cParamet += "MV_CONTAGR/MV_RESITE /MV_BLQITE /MV_ARQPROD/MV_MIL0070/MV_MIL0071/MV_MIL0072/"

	Case cRot == "011" // Fechamento de OS
		cParamet += "MV_NUMPARC/MV_CPNCLC /MV_CHKCRE /MV_LOJAVEI/MV_PREFOFI/MV_BXSER  /MV_ESTNEG /MV_1DUPNAT/MV_TIPPER /MV_TPNRNFS/" // 10
		cParamet += "MV_TABPAD /MV_MIL0001/MV_GLIBVEN/MV_NATPER /MV_IOSVFEC/MV_MIL0036/MV_MIL0045/MV_MIL0056/MV_MIL0058/MV_MIL0059/" // 20
		cParamet += "MV_MIL0065/MV_MIL0084/"

	Case cRot == "012" // Integracao John Deere
		cParamet += "MV_MIL0004/MV_MIL0005/MV_MIL0006/MV_ESTNEG /MV_TPNRNFS/MV_FORPADV/MV_GRUVEI /MV_RESITE /MV_MIL0015/MV_MIL0022/" // 10
		cParamet += "MV_MIL0028/MV_MIL0029/MV_MIL0032/MV_MIL0043/MV_MIL0044/MV_MIL0062/MV_MIL0066/MV_MIL0085/MV_MIL0086/MV_MIL0088/" // 20
		cParamet += "MV_MIL0089/MV_MIL0102/"

	Case cRot == "013" // Liberacao de OS
		cParamet += "MV_INCORC /MV_VKILHOR/MV_LIBDIAG/MV_CHECKLI/MV_RESITE /MV_INTDL  /MV_RESLOC /MV_CHKCRE /MV_MIL0045/MV_MIL0103/"

	Case cRot == "014" // Movimentacoes de Veiculos
		cParamet += "MV_1DUPREF/MV_2DUPREF/MV_MIL0007/MV_MIL0010/MV_GRUVEI /MV_LOCVZL /MV_LOCVEIN/MV_LOCVEIU/MV_LOCVEIC/MV_NATVEIE/" // 10
		cParamet += "MV_PCOMVEI/MV_PREFVEI/MV_TPNRNFS/MV_VUCCTB /MV_BLQVEIU/MV_BCRVEIU/MV_RECVEIC/MV_TIPVEI /MV_MARGSOL/MV_ESPECIE/" // 20
		cParamet += "MV_ESPECNF/MV_INTDL  /MV_PERGVTR/MV_RESPMUL/MV_NATVEIS/MV_CUSTRFV/MV_ESTNEG /MV_BCOCXA /MV_LOJAVEI/MV_TMFCUFN/" // 30
		cParamet += "MV_MIL0024/MV_MIL0073/"

	Case cRot == "015" // Orcamento
		cParamet += "MV_GLIBVEN/MV_INCORC /MV_VERIORC/MV_MIL0001/MV_MIL0002/MV_MIL0011/MV_MIL0012/MV_CKCLIXX/MV_ALTFATP/MV_CADCVAM/" // 10
		cParamet += "MV_CHKCRE /MV_CPNCLC /MV_CREDCLI/MV_EEMAILO/MV_FASEORC/MV_FMLPECA/MV_FORMALO/MV_GORISC /MV_INCOBR /MV_INDMFT /" // 20
		cParamet += "MV_INTDL  /MV_LBVACB /MV_RESITE /MV_RESLOC /MV_SIMB   /MV_SIMB1  /MV_SIMB2  /MV_SIMB3  /MV_SIMB4  /MV_SIMB5  /" // 30
		cParamet += "MV_TESDACE/MV_TESFRET/MV_TESSEGU/MV_TIPPER /MV_TPNRNFS/MV_TXCOFIN/MV_TXPIS  /MV_VKILHOR/MV_VMLOROF/MV_DIVITE /" // 40
		cParamet += "MV_DIVLOC /MV_PREFBAL/MV_LOJAVEI/MV_TABPAD /MV_ESTNEG /MV_1DUPREF/MV_BCOCXA /MV_BXPEC  /MV_FORMALU/MV_MARMIN /" // 50
		cParamet += "MV_FORMALI/MV_CUSBAL /MV_GRUVEI /MV_FAPLPEC/MV_LOCALIZ/MV_DIRFTGC/MV_MIL0019/MV_MIL0026/MV_MIL0037/MV_MIL0045/" // 60
		cParamet += "MV_MIL0064/MV_MIL0075/MV_MIL0080/MV_MIL0093/MV_MIL0094/MV_MIL0095/MV_MIL0096/MV_MIL0097/MV_MIL0098/" // 70

	Case cRot == "016" // Requisicao de Pecas
		cParamet += "MV_DIRFTGC/MV_CREDCLI/MV_CHKCRE /MV_INCORC /MV_RESITE /MV_RESLOC /MV_RITEORC/MV_INTDL  /MV_CONSRV /MV_CALCMED/" // 10
		cParamet += "MV_REPPRO /MV_VTPABE /MV_FMLPECA/MV_LIBVAC /MV_LBVACR /MV_VERQTCC/MV_SIMB1  /MV_SIMB2  /MV_SIMB3  /MV_SIMB4  /" // 20
		cParamet += "MV_SIMB5  /MV_SIMB   /MV_INDMFT /MV_MIL0023/MV_MIL0045/"

	Case cRot == "017" // Requisicao de Servicos
		cParamet += "MV_SRV3PD /MV_PONLINE/MV_INCORC /MV_HORSEG /MV_HORCON /MV_CALDTEN/MV_RESITE /MV_RESLOC /MV_SUBORDE/MV_ICODBAR/" // 10
		cParamet += "MV_POSCBAR/MV_CHKCRE /MV_DIAFUT /MV_APOUNI /MV_MIL0045/"

	Case cRot == "018" // Sugestao de Compras
		cParamet += "MV_FMLPECA/MV_PEDANO /MV_TSTFJD /MV_TSTEJD /MV_MAQGPEC/MV_AUTGIRO/MV_VEICULO/MV_USAREQ /"

	Case cRot == "019" // Liberacao de Credito do Oficina
		cParamet += "MV_MIL0017/"

	Case cRot == "020" // Requisi็ใo e Devolu็ใo de Ferramentas
		cParamet += "MV_MIL0020/MV_MIL0038/MV_MIL0039/MV_MIL0076/"
    
	Case cRot == "021" // Painel Venda Pecas
		cParamet += "MV_MIL0025/MV_PREFBAL/MV_PREFOFI/MV_ESTADO/"

	Case cRot == "022" // Integra็ใo Scania
		cParamet += "MV_MIL0004/MV_MIL0005/MV_MIL0006/MV_MIL0030/MV_MIL0031/MV_MIL0033/MV_MIL0034/MV_MIL0063/"

	Case cRot == "023" // Consulta de Pecas (Balcao/Oficina)
		cParamet += "MV_MIL0042/"

	Case cRot == "024" // Cadastro de Pecas
		cParamet += "MV_MIL0077/"

	Case cRot == "025" // SIR (Mitsubishi)
		cParamet += "MV_MIL0083/"

	Case cRot == "026" // Auto-Center
		cParamet += "MV_FMLPECA/MV_MIL0079/MV_MIL0080/MV_MIL0081/MV_MIL0082/MV_MIL0093/MV_MIL0094/MV_MIL0096/MV_MIL0097/MV_MIL0100/" // 10
		cParamet += "MV_MIL0101/"

	Case cRot == "027" // Etiqueta para Itens
		cParamet += "MV_MIL0078/"

	Case cRot == "028" // Transferencia de Pecas
		cParamet += "MV_MIL0090/MV_MIL0104/"

	Case cRot == "029" // Conferencia de Pecas
		cParamet += "MV_MIL0091/MV_MIL0092/MV_MIL0095/MV_MIL0098/"

End Case
//
If cRot <> "*"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ PE para manipular quais PARAMETROS sao da Rotina selecionada ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock("VA350PAR")
		cParamet := ExecBlock("VA350PAR",.f.,.f.,{cRot,cParamet})
	EndIf
	//
	For ni := 1 to (len(cParamet)/11)
		cParAux := substr(cParamet,(ni*11)-10,10)
		aAdd(aPar,{ IIf(GetMv(cParAux,.T.,),"overd","overm") , cParAux , SX6->X6_TIPO , Alltrim(X6Conteud()) , Alltrim(X6Descric())+" "+Alltrim(X6Desc1())+" "+Alltrim(X6Desc2()) })
	Next
	//
EndIf
Asort(aPar,,,{|x,y| x[2] < y[2] })
cParAux := ""
For ni := 1 to len(aPar)
	If cParAux == aPar[ni,2]
		MsgAlert(aPar[ni,2]+" - "+STR0028+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0029+" "+cRot,STR0030) // parametro duplicado! / Rotina: / Atencao
		Exit
	EndIf
	cParAux := aPar[ni,2]
Next
If len(aPar) <= 0
	aAdd(aPar,{"overm","","","",""})
EndIf
If lRefr
	oLbPar:nAt := 1
	oLbPar:SetArray(aPar)
	oLbPar:bLine := { || { &(aPar[oLbPar:nAt,1]) , aPar[oLbPar:nAt,2] , aPar[oLbPar:nAt,3] , 	aPar[oLbPar:nAt,4] , aPar[oLbPar:nAt,5] }}
	oLbPar:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VA350IMPบ Autor ณ Andre Luis Almeida บ Data ณ  21/01/14  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VA350IMP()
Local ni       := 0
Local _aIntCab := {}
Local _aIntIte := {}
//
aAdd(_aIntCab,{ STR0002 , "C" ,  20 , "@!" })
aAdd(_aIntCab,{ STR0005 , "C" ,  50 , "@!" })
aAdd(_aIntCab,{ STR0007 , "C" , 350 , "@!" })
//
For ni := 1 to len(aPar)
	aAdd(_aIntIte,{ IIf(aPar[ni,1]=="overd",STR0003,STR0004) , aPar[ni,2] , aPar[ni,4] })
Next
//
FGX_VISINT( "VEIVA350" , STR0001 , _aIntCab , _aIntIte , .t. )
//
Return()
