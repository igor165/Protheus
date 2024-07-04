// ษออออออออหออออออออป
// บ Versao บ 02     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIVA370.CH"

#define STR0001 "Pontos de Entrada das Rotinas"
#define STR0002 "PE compilado no ambiente?"
#define STR0003 "Sim"
#define STR0004 "Nใo"
#define STR0005 "Ponto de Entrada"
#define STR0006 "Rotina"
#define STR0007 "Liber็ใo de Cr้dito da Oficina"
#define STR0008 "Requisi็ใo e Devolu็ใo de Ferramentas"
#define STR0009 "Sugestใo de Compras"
#define STR0010 "Atendimento de Veํculos"
#define STR0011 "Integra็ใo John Deere"
#define STR0012 "Abertura de OS"
#define STR0013 "Agendamento Oficina"
#define STR0014 "Apontamento Eletr๔nico"
#define STR0015 "Cadastro de Veiculos"
#define STR0016 "Cancelamento de OS"
#define STR0017 "CEV"
#define STR0018 "Consulta de OS"
#define STR0019 "Consulta de Painel de Oficina"
#define STR0020 "Contagem de Estoque"
#define STR0021 "Fechamento de OS"
#define STR0022 "Libera็ใo de OS"
#define STR0023 "Movimenta็๕es de Veiculos"
#define STR0024 "Or็amento"
#define STR0025 "Requisi็ใo de Pe็as"
#define STR0026 "Requisi็ใo de Servi็os"
#define STR0027 "Aten็ใo"
#define STR0028 "ponto de entrada duplicado!"
#define STR0029 "OBSOLETO"
#define STR0030 "Impressใo"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ VEIVA370 บ Autor ณ Andre Luis Almeida บ Data ณ  17/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Pontos de Entradas das Rotinas                             บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ ATENCAO:  Para inserir nova rotina, eh necessario incluir a mesma no  บฑฑ
ฑฑบ           vetor "aRotTot", atribuir todos os parametros da rotina na  บฑฑ
ฑฑบ           variavel "cPEs" e documentar nas "Rotinas disponiveis"      บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Rotinas disponiveis:                                                  บฑฑ
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
ฑฑบ   019 - Liber็ใo de Cr้dito da Oficina"                               บฑฑ
ฑฑบ   020 - Requisi็ใo e Devolu็ใo de Ferramentas"                        บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametroณ aRotUsu ( vetor com as rotinas que o usuario tera acesso ) บฑฑ
ฑฑบ          ณ Exemplo:     aRotUsu := {"001","004","005",...}            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA370(aRotUsu)
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ni        := 0
Local cRot      := ""
Private overd   := LoadBitmap( GetResources(), "BR_verde")    // Ponto de Entrada compilado no ambiente
Private overm   := LoadBitmap( GetResources(), "BR_vermelho") // Ponto de Entrada nao compilado no ambiente
Private aNewBot := {}   // Impressao
Private aPEs    := {{"overm",""}} // vetor dos Pontos de Entradas
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
aAdd(aRotTot,"018="+STR0009) // Sugestao de Compras
aAdd(aRotTot,"019="+STR0007) // Liberacao de Credito do Oficina
aAdd(aRotTot,"020="+STR0008) // Requisi็ใo e Devolu็ใo de Ferramentas
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PE para manipular vetor das Rotinas   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("VA370ROT")
	aRotTot := ExecBlock("VA370ROT",.f.,.f.,{aRotTot})
EndIf
//
If len(aRotUsu) == 0 // Nao foi passado nenhuma rotina como parametro
	aRot := aClone(aRotTot) // disponibilizar todas as rotinas
Else // Foi passada rotinas como parametro
	If len(aRotUsu) == 1 // Apenas uma rotina
		cRot := aRotUsu[1]
		VEIVA370CAR(cRot,.f.) // Filtrar PEs da rotina
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
AADD(aNewBot, {"IMPRESSAO",{|| FS_VA370IMP() },( STR0030 )} ) // Impressao
//
DEFINE MSDIALOG oPEsRot TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Pontos de Entrada da Rotina
oPEsRot:lEscClose := .F.
@ aPos[1,1]+00,aPos[1,2]+00 TO aPos[1,1]+21,85 LABEL STR0002 OF oPEsRot PIXEL // PE compilado no ambiente?
@ aPos[1,1]+10,aPos[1,2]+14 BITMAP OXverd RESOURCE "BR_verde" OF oPEsRot NOBORDER SIZE 10,10 PIXEL
@ aPos[1,1]+10,aPos[1,2]+24 SAY STR0003 SIZE 30,8 OF oPEsRot PIXEL COLOR CLR_BLUE // Sim
@ aPos[1,1]+10,aPos[1,2]+47 BITMAP OXverm RESOURCE "BR_vermelho" OF oPEsRot NOBORDER SIZE 10,10 PIXEL
@ aPos[1,1]+10,aPos[1,2]+57 SAY STR0004 SIZE 30,8 OF oPEsRot PIXEL COLOR CLR_BLUE // Nao
@ aPos[1,1]+00,aPos[1,2]+85 TO aPos[1,1]+21,aPos[1,4] LABEL STR0006 OF oPEsRot PIXEL // Rotina
@ aPos[1,1]+07,aPos[1,2]+88 MSCOMBOBOX oRot VAR cRot SIZE aPos[1,4]-93,08 COLOR CLR_BLACK ITEMS aRot OF oPEsRot PIXEL ON CHANGE VEIVA370CAR(cRot,.t.) WHEN len(aRot) > 1
@ aPos[2,1],aPos[2,2] LISTBOX oLbPEs FIELDS HEADER "",STR0005 COLSIZES 10,(aPos[2,4]-20) SIZE aPos[2,4]-2,aPos[2,3]-30 OF oPEsRot PIXEL
oLbPEs:bHeaderClick := {|oObj,nCol| VEIVA370ORD(nCol) , } // Ordenar PEs
oLbPEs:SetArray(aPEs)
oLbPEs:bLine := { || { &(aPEs[oLbPEs:nAt,1]) , aPEs[oLbPEs:nAt,2] }}
ACTIVATE MSDIALOG oPEsRot CENTER ON INIT EnchoiceBar(oPEsRot,{|| oPEsRot:End() },{ || oPEsRot:End()},,aNewBot)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA370ORDบ Autor ณ Andre Luis Almeida บ Data ณ  17/01/14  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Ordenar listbox - vetor dos PEs                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA370ORD(nCol)
Asort(aPEs,,,{|x,y| x[nCol] < y[nCol] })
oLbPEs:Refresh()
oLbPEs:SetFocus()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA370CARบ Autor ณ Andre Luis Almeida บ Data ณ  17/01/14  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega os PEs de uma determinada rotina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA370CAR(cRot,lRefr)
Local ni       := 0
Local cPEsAux  := ""
Local cPEs     := "" // PE(11 posicoes) + / ...
Local cPEx     := "" // PE(11 posicoes) + / ...  ( OBSOLETOS )
aPEs := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PEs por Rotina        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case

	Case cRot == "001" // Abertura de OS
		cPEs += "MNBROM010  /OFI010FBRW /INCBOT010  /OM010DPGR  /OM010BLOQ  /VA010DPGR  /"
		// OBSOLETOS //
		cPEx += ""
		
	Case cRot == "002" // Agendamento Oficina
		cPEs += "OM350ABT   /O350EMAIL  /OF350GRORC /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "003" // Apontamento Eletronico
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "004" // Atendimento de Veiculos
		cPEs += "VM011LEG   /VEI018FBRW /VX001AFA   /VX001DFA   /NFSAIVEI   /BLQCOB     /VLDEXC011  /VXI01ACA   /VXI01DCA   /PEDVEI011  /" // 10
		cPEs += "VXI02TIT   /VM011DNF   /VXI02CR    /VXI02CP    /VXI02ILJ   /VX002INI   /VX002FIN   /FS_COMVEI  /VXX02RF7   /VX002RPG   /" // 20
		cPEs += "VX002RPL   /VX002F10   /ATENDVEI   /PEVM011ITD /VX002NME   /VX05FILT   /VX007RMC   /VM011PFIN  /VX012VAL   /VXX14DTBN  /" // 30
		cPEs += "VXX13VAP   /VXX13DAP   /VX030FIM   /PVM011DTENT/VM040AGD   /VXC01FIL   /VXC01QRY   /PEVM011OSV /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "005" // Cadastro de Veiculos
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "006" // Cancelamento de OS
		cPEs += "OFM150MK   /VA150DPGR  /OM150IGA   /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "007" // CEV
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "008" // Consulta de OS
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "009" // Consulta de Painel de Oficina
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "010" // Contagem de Estoque
		cPEs += "OPM040AI   /OPM040R    /OPM040DV   /OPM040B7   /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "011" // Fechamento de OS
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "012" // Integracao John Deere
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "013" // Liberacao de OS
		cPEs += "OM140CHK   /VA140DPGR  /OM140IGA   /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "014" // Movimentacoes de Veiculos
		cPEs += "VX000BOT   /VX000MF1   /PEV000LOK  /VX000TOK   /VX000SAI   /VX000DCA   /VX000ANF   /VX000DNF   /VA010AB1   /VX000AIN   /" // 10
		cPEs += "NFENTVEI   /VA610MUL   /VX000CNF   /VM000EXC   /VX001MF1   /VM030ANF   /VX001ANF   /VX001DNF   /VX001APV   /NFSAIVEI   /" // 20
		cPEs += "VX001CNF   /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "015" // Orcamento
		cPEs += "OXA011BOT  /POXA011FBR /OA011APRO  /POA011FT   /OX011CLONE /OA011DCL   /OA011LEG   /OA011COR   /OXA012LP   /OI001RDE   /" // 10
		cPEs += "OXVS7DGR   /OI001SCO   /OXIEMAIL   /ORDBUSCB   /OI001FNV   /OX001CPC   /OXX001ABOT /OX001ABT   /OX001MF1   /OX001NME   /" // 20
		cPEs += "OX001AHP   /OX001AHS   /OX001HCB   /OX001AFP   /CHKPRO110  /OX001VSP   /OX001PPC   /OX001AFS   /OX001LKP   /OX001LKS   /" // 30
		cPEs += "OFIX01TUDOK/OX001TOK   /OX001GRA   /OX001GVS1  /OX001VS1   /OX001GVS3  /OX001VS3   /OXA001DBFAT/OX001FAT   /OX01CANCEL /" // 40
		cPEs += "OX001CAN   /OX001DCN   /OX001OK    /OX001VPO   /OX001AEX   /OFX01OSV   /IMPORCVSJ  /OX001IOR   /OX001DEX   /IMPSUBORD  /" // 50
		cPEs += "OXA001VDEL /OX001ADP   /OXA001DELP /OX001DDP   /OX004AIP   /ESTOF110   /OX001SPC   /OX001IRL   /OX001SRL   /VA010DPGR  /" // 60
		cPEs += "OXA001SAIR /OX001SAI   /OX001VPP   /OX00RESERV /OX001RES   /OX001ARS   /ORCAMTO    /OX001VEC   /OXA012LS   /OXX002BTN1 /" // 70
		cPEs += "OX002NEX   /OX002ARS   /OXX002DTR  /OX003PRIM  /PEOX003BTN /OX005BOT   /OX005DGR   /OX004ACP   /OX004DCP   /OX004AFT   /" // 80
		cPEs += "OX004ILJ   /OX004ATR   /OX004RIT   /OX004AMP   /OX004APV   /OX004DNF   /OX004DFT   /NFPECSER   /FMABREOS   /FMIMPORC   /" // 90
		// OBSOLETOS //
		cPEx += "OXX004AFAT /OXX004ILOJ /OXX004ATRA /OXX004AMPV /OXX004AIPV /OXX004APV  /OX04RESITE /"

	Case cRot == "016" // Requisicao de Pecas
		cPEs += "OM020INI   /OM3020TP   /OM020VSJ   /OM020VIO   /VERTPGCC   /RQPCOM020  /ORDBUSCA   /OM020ALT   /POM020DG   /RDLOCALIZ  /" // 10 
		cPEs += "OM020VLD   /ALTTPREQ   /OX001IRL   /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "017" // Requisicao de Servicos
		cPEs += "OM3020TP   /OM030INI   /OM030OKN   /OM030ANGR  /OM030DPGR  /IMPSUBORD  /OM030DEL   /OM030VAS   /VERTPGCC   /OM030VLD   /" // 10
		cPEs += "ALTTPREQ   /OM030TOK   /"
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "018" // Sugestao de Compras
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "019" // Liberacao de Credito do Oficina
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

	Case cRot == "020" // Requisi็ใo e Devolu็ใo de Ferramentas
		cPEs += ""
		// OBSOLETOS //
		cPEx += ""

End Case
//
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PE para manipular quais PEs sao da Rotina selecionada        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("VA370PES")
	cPEs := ExecBlock("VA370PES",.f.,.f.,{cRot,cPEs})
EndIf
//
For ni := 1 to (len(cPEs)/12)
	cPEsAux := Alltrim(substr(cPEs,(ni*12)-11,11))
	aAdd(aPEs,{ IIf(ExistBlock(cPEsAux),"overd","overm") , cPEsAux })
Next
// OBSOLETOS //
For ni := 1 to (len(cPEx)/12)
	cPEsAux := Alltrim(substr(cPEx,(ni*12)-11,11))
	If ExistBlock(cPEsAux)
		aAdd(aPEs,{ "overd" , cPEsAux + "    <<<    "+STR0029 +" ***"}) // OBSOLETO
	EndIf
Next
//
Asort(aPEs,,,{|x,y| x[2] < y[2] })
cPEsAux := ""
For ni := 1 to len(aPEs)
	If cPEsAux == aPEs[ni,2]
		MsgAlert(aPEs[ni,2]+" - "+STR0028+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0006+": "+cRot,STR0027) // ponto de entrada duplicado! / Rotina: / Atencao
		Exit
	EndIf
	cPEsAux := aPEs[ni,2]
Next
If len(aPEs) <= 0
	aAdd(aPEs,{"overm",""})
EndIf
If lRefr
	oLbPEs:nAt := 1
	oLbPEs:SetArray(aPEs)
	oLbPEs:bLine := { || { &(aPEs[oLbPEs:nAt,1]) , aPEs[oLbPEs:nAt,2] }}
	oLbPEs:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VA370IMPบ Autor ณ Andre Luis Almeida บ Data ณ  21/01/14  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VA370IMP()
Local ni       := 0
Local _aIntCab := {}
Local _aIntIte := {}
//
aAdd(_aIntCab,{ STR0002 , "C" ,  20 , "@!" })
aAdd(_aIntCab,{ STR0005 , "C" ,  50 , "@!" })
//
For ni := 1 to len(aPEs)
	aAdd(_aIntIte,{ IIf(aPEs[ni,1]=="overd",STR0003,STR0004) , aPEs[ni,2] })
Next
//
FGX_VISINT( "VEIVA370" , STR0001 , _aIntCab , _aIntIte , .t. )
//
Return()