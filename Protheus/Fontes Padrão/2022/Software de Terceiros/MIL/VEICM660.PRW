// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#include "VEICM660.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM660 ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Roteiro de Visitas                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM660()
Local cCondic     := ""
Local lCEVOUT     := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Private lAltVend  := .t. // Altera vendedor ?
Private cCadastro := STR0001 // Roteiro de Visitas
Private aRotina   := MenuDef()
Private aCores    := {	{'VCN->VCN_STATUS == "1"','BR_LARANJA'},;	// 1=Digitado
						{'VCN->VCN_STATUS == "2"','BR_VERDE'},;	 	// 2=Finalizado
						{'VCN->VCN_STATUS == "3"','BR_AZUL'}}		// 3=Aprovado
If lCEVOUT
	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
		cCondic += "VCN->VCN_CODVEN==VAI->VAI_CODVEN"
		lAltVend := .f.
	EndIf
EndIf
//
If !Empty(cCondic)
	FilBrowse('VCN',{},cCondic)
EndIf
//
mBrowse( 6, 1,22,75,"VCN",,,,,,aCores)
//
If !Empty(cCondic)
	dbClearFilter()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  VCM660? ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada do aRotina ( V-isualizar / I-ncluir / A-lterar / E-xcluir )    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660V(cAlias,nReg,nOpc)
nOpc := 2 // Visualizar
VCM660(cAlias,nReg,nOpc)
Return()

Function VCM660I(cAlias,nReg,nOpc)
nOpc := 3 // Incluir
VCM660(cAlias,nReg,nOpc)
Return()

Function VCM660A(cAlias,nReg,nOpc)
nOpc := 4 // Alterar
VCM660(cAlias,nReg,nOpc)
Return()

Function VCM660E(cAlias,nReg,nOpc)
nOpc := 5 // Excluir
VCM660(cAlias,nReg,nOpc)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  VCM660  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Roteiro de Visistas ( Visualizar / Incluir / Alterar / Excluir )       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660(cAlias,nReg,nOpc)
Local lOk       := .t.
Local ni        := 0
Local cTitulo   := " - "
Local cQuery    := ""
Local nOpcao    := 0
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private cAgenCS := "1"
Private aAgenCS := {"1="+STR0056,"2="+STR0057,"3="+STR0058} // Agendas SEM Abordagem / Agendas COM Abordagem / Todas as Agendas
Private cTipoDt := "1"
Private aTipoDt := {"1="+STR0059,"2="+STR0060} // Data da Agenda / Data da Abordagem
Private cCodVen := ""
Private cNomVen := ""
Private dDatIni := ctod("")
Private dDatFin := ctod("")
Private cCodBco := ""
Private cAgeBco := ""
Private cConBco := ""
Private aVetRot := {}
Private cCliCGC := ""
Private cCliFon := ""
Private cCliEnd := ""
Private cCliBai := ""
Private cCliCEP := ""     
Private cCliMun := ""
Private cUltVen := ""
Private cUltGer := ""
Private aBotVCM660 := {}
//
AADD(aBotVCM660, {"PCO_COINC",{|| VCM660ICLI(nOpc) }, STR0061 } ) // Incluir Roteiro SEM Agenda
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 33, .T. , .F. } ) // Filtro (topo)
AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox
AAdd( aObjects, { 0, 44, .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )
//
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If nOpc == 3 // Incluir
	cTitulo += STR0007 // Incluir
	cCodVen := VAI->VAI_CODVEN
	cCodBco := space(VCN->(TamSX3("VCN_CODBCO")[1]))
	cAgeBco := space(VCN->(TamSX3("VCN_AGEBCO")[1]))
	cConBco := space(VCN->(TamSX3("VCN_CONBCO")[1]))
Else
	cCodVen := VCN->VCN_CODVEN
	dDatIni := VCN->VCN_DATINI
	dDatFin := VCN->VCN_DATFIN
	cCodBco := VCN->VCN_CODBCO
	cAgeBco := VCN->VCN_AGEBCO
	cConBco := VCN->VCN_CONBCO
	If nOpc == 2 // Visualizar
		cTitulo += STR0006 // Visualizar
	ElseIf nOpc == 4 // Alterar
		cTitulo += STR0008 // Alterar
		If VCN->VCN_STATUS == "2" // 2=Finalizado
			If VAI->VAI_CEVROT == "1" // usuario somente digita roteiro
				MsgStop(STR0012,STR0011)// Impossivel ALTERAR roteiro FINALIZADO! / Atencao
				lOk := .f.
			Else
				If MsgYesNo(STR0047,STR0011) // Impossivel ALTERAR roteiro FINALIZADO! Deseja voltar o roteiro para o status DIGITADO? /  Atencao
					DbSelectArea("VCN")
					RecLock("VCN",.f.)
						VCN->VCN_STATUS := "1" // 1=Digitado
					MsUnLock()	
				Else
					lOk := .f.
				EndIf
			EndIf		
		ElseIf VCN->VCN_STATUS == "3" // 3=Aprovado
			MsgStop(STR0013,STR0011) // Impossivel ALTERAR roteiro APROVADO! / Atencao
			lOk := .f.
		EndIf
	ElseIf nOpc == 5 // Excluir
		cTitulo += STR0009 // Excluir
		If VCN->VCN_STATUS == "2" // 2=Finalizado
			If VAI->VAI_CEVROT == "1" // usuario somente digita roteiro
				MsgStop(STR0014,STR0011) // Usuario sem permissao para EXCLUIR roteiro FINALIZADO! / Atencao
				lOk := .f.
			EndIf
		ElseIf VCN->VCN_STATUS == "3" // 3=Aprovado
			If VAI->VAI_CEVROT $ "1/2"	// usuario somente digita/finaliza roteiro
				MsgStop(STR0015,STR0011) // Usuario sem permissao para EXCLUIR roteiro APROVADO! / Atencao
				lOk := .f.
			EndIf
		EndIf
	EndIf
EndIf
SA3->(DbSetOrder(1))
If SA3->(DbSeek(xFilial("SA3")+cCodVen)) 
	cNomVen := SA3->A3_NOME
EndIf
//
If lOk
	FS_FILTRAR(0,nOpc)
	DEFINE MSDIALOG oVCM660 TITLE STR0001+cTitulo FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Roteiro de Visitas
		oVCM660:lEscClose := .F.

		@ aPos[1,1]+001,aPos[1,2]+001 TO aPos[1,3],aPos[1,4]-001 LABEL Alltrim(FWFilialName()) OF oVCM660 PIXEL
		@ aPos[1,1]+010,aPos[1,2]+005 SAY (STR0025+":") SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Vendedor
		If nOpc == 3
			@ aPos[1,1]+008,aPos[1,2]+038 MSGET oVCM660CVen VAR cCodVen PICTURE "@!" F3 "SA3" VALID FS_VALSA3() SIZE 30,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .and. lAltVend )
			@ aPos[1,1]+019,aPos[1,2]+005 MSGET oVCM660NVen VAR cNomVen PICTURE "@!" SIZE 65,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.
			@ aPos[1,1]+008,aPos[1,2]+083 MSCOMBOBOX oVCM660TDt VAR cTipoDt SIZE 63,08 COLOR CLR_BLACK ITEMS aTipoDt OF oVCM660 PIXEL COLOR CLR_BLUE
			@ aPos[1,1]+019,aPos[1,2]+083 MSGET oVCM660DIni VAR dDatIni PICTURE "@D" SIZE 42,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 )
			@ aPos[1,1]+020,aPos[1,2]+128 SAY STR0027 SIZE 10,8 OF oVCM660 PIXEL COLOR CLR_BLUE // a
			@ aPos[1,1]+019,aPos[1,2]+135 MSGET oVCM660DFin VAR dDatFin PICTURE "@D" SIZE 42,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 )
			@ aPos[1,1]+019,aPos[1,2]+178 MSCOMBOBOX oVCM660ACS VAR cAgenCS SIZE 80,08 COLOR CLR_BLACK ITEMS aAgenCS OF oVCM660 PIXEL COLOR CLR_BLUE
		Else
			@ aPos[1,1]+019,aPos[1,2]+005 MSGET oVCM660CVen VAR cCodVen PICTURE "@!" F3 "SA3" VALID FS_VALSA3() SIZE 30,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .and. lAltVend )
			@ aPos[1,1]+019,aPos[1,2]+040 MSGET oVCM660NVen VAR cNomVen PICTURE "@!" SIZE 122,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.
			@ aPos[1,1]+010,aPos[1,2]+170 SAY (STR0026+":") SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Periodo
			@ aPos[1,1]+019,aPos[1,2]+170 MSGET oVCM660DIni VAR dDatIni PICTURE "@D" SIZE 42,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 )
			@ aPos[1,1]+020,aPos[1,2]+215 SAY STR0027 SIZE 10,8 OF oVCM660 PIXEL COLOR CLR_BLUE // a
			@ aPos[1,1]+019,aPos[1,2]+222 MSGET oVCM660DFin VAR dDatFin PICTURE "@D" SIZE 42,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 )
		EndIf
		@ aPos[1,1]+014,aPos[1,4]-050 BUTTON oVCM660Filt PROMPT STR0028 OF oVCM660 SIZE 40,10 PIXEL ACTION FS_FILTRAR(1,nOpc) WHEN ( nOpc == 3 ) // Filtrar
        //
		@ aPos[1,1]+010,aPos[1,2]+270 SAY (STR0073+":") SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Banco
		@ aPos[1,1]+019,aPos[1,2]+270 MSGET oVCM660CVen VAR cCodBco PICTURE "@!" F3 "SA6" SIZE 20,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. ( nOpc == 4 .and. VCN->VCN_STATUS == "1" ) )
		@ aPos[1,1]+010,aPos[1,2]+300 SAY (STR0074+":") SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Agencia
		@ aPos[1,1]+019,aPos[1,2]+300 MSGET oVCM660CVen VAR cAgeBco PICTURE "@!" SIZE 25,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. ( nOpc == 4 .and. VCN->VCN_STATUS == "1" ) )
		@ aPos[1,1]+010,aPos[1,2]+330 SAY (STR0075+":") SIZE 50,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Conta
		@ aPos[1,1]+019,aPos[1,2]+330 MSGET oVCM660CVen VAR cConBco PICTURE "@!" SIZE 50,08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. ( nOpc == 4 .and. VCN->VCN_STATUS == "1" ) )
        //
		@ aPos[2,1]+001,aPos[2,2]+001 LISTBOX oLbVCM660 FIELDS HEADER STR0029,STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0062,STR0063,STR0065,STR0066,STR0067,STR0068,STR0069,STR0070,STR0071,STR0079,STR0080,STR0076 ;
																	 COLSIZES 28,38,90,70,40,40,40,70,40,40,40,40,40,40,40,40,40,40,40,550 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF oVCM660 PIXEL ;
																	 ON CHANGE FS_DADOSCLI(aVetRot[oLbVCM660:nAt,03],aVetRot[oLbVCM660:nAt,04],1) ON DBLCLICK FS_EDIT( oLbVCM660:nAt , nOpc )
		oLbVCM660:SetArray(aVetRot)
		oLbVCM660:bLine := { || { FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,01],"@EZ 99,999")) ,;
								Transform(aVetRot[oLbVCM660:nAt,02],"@D") ,;
								aVetRot[oLbVCM660:nAt,03]+"-"+aVetRot[oLbVCM660:nAt,04]+" "+aVetRot[oLbVCM660:nAt,05] ,;
								aVetRot[oLbVCM660:nAt,06] ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,07],"@E 99,999,999")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,08],"@E 99,999,999")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,09],"@E 99,999,999")) ,;
								aVetRot[oLbVCM660:nAt,10] ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,12],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,13],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,14],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,15],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,16],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,17],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,18],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,19],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,20],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,21],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,22],"@E 999,999.99")) ,;
								aVetRot[oLbVCM660:nAt,23] }}
		ni := (aPos[3,4]/6)
		@ aPos[3,1]+001,aPos[3,2]+001 TO aPos[3,3],(ni*4)-002 LABEL STR0039 OF oVCM660 PIXEL // Dados do Cliente

		@ aPos[3,1]+009,aPos[3,2]+(ni*0.0)+005 SAY SA1->(RetTitle("A1_CGC")) SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // CNPJ
		@ aPos[3,1]+008,aPos[3,2]+(ni*0.5)+000 MSGET oV660ClCGC VAR cCliCGC PICTURE "@!" SIZE (ni*1.3),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.
		@ aPos[3,1]+009,aPos[3,2]+(ni*2.0)+005 SAY SA1->(RetTitle("A1_TEL")) SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Fone
		@ aPos[3,1]+008,aPos[3,2]+(ni*2.5)+000 MSGET oV660ClFon VAR cCliFon PICTURE "@!" SIZE (ni*1.3),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.

		@ aPos[3,1]+020,aPos[3,2]+(ni*0.0)+005 SAY SA1->(RetTitle("A1_END")) SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Endereco
		@ aPos[3,1]+019,aPos[3,2]+(ni*0.5)+000 MSGET oV660ClEnd VAR cCliEnd PICTURE "@!" SIZE (ni*1.3),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.
		@ aPos[3,1]+020,aPos[3,2]+(ni*2.0)+005 SAY SA1->(RetTitle("A1_BAIRRO")) SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Bairro
		@ aPos[3,1]+019,aPos[3,2]+(ni*2.5)+000 MSGET oV660ClBai VAR cCliBai PICTURE "@!" SIZE (ni*1.3),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.

		@ aPos[3,1]+031,aPos[3,2]+(ni*0.0)+005 SAY SA1->(RetTitle("A1_CEP")) SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // CEP
		@ aPos[3,1]+030,aPos[3,2]+(ni*0.5)+000 MSGET oV660ClCEP VAR cCliCEP PICTURE "@!" SIZE (ni*1.3),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.
		@ aPos[3,1]+031,aPos[3,2]+(ni*2.0)+005 SAY SA1->(RetTitle("A1_MUN")) SIZE 40,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Municipio/Estado
		@ aPos[3,1]+030,aPos[3,2]+(ni*2.5)+000 MSGET oV660ClMun VAR cCliMun PICTURE "@!" SIZE (ni*1.3),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.

		@ aPos[3,1]+001,(ni*4)+001 TO aPos[3,3],aPos[3,4]-001 LABEL STR0040 OF oVCM660 PIXEL // Visitas para o Cliente

		@ aPos[3,1]+009,aPos[3,2]+(ni*4.0)+005 SAY STR0041 SIZE 100,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Ultima do Vendedor
		@ aPos[3,1]+008,aPos[3,2]+(ni*5.0)+000 MSGET oV660UlVen VAR cUltVen PICTURE "@!" SIZE (ni*0.8),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.

		@ aPos[3,1]+020,aPos[3,2]+(ni*4.0)+005 SAY STR0042 SIZE 100,8 OF oVCM660 PIXEL COLOR CLR_BLUE // Ultima geral
		@ aPos[3,1]+019,aPos[3,2]+(ni*5.0)+000 MSGET oV660UlGer VAR cUltGer PICTURE "@!" SIZE (ni*0.8),08 OF oVCM660 PIXEL COLOR CLR_BLACK WHEN .f.

		@ aPos[3,1]+031,aPos[3,2]+(ni*4.0)+005 BUTTON oV660VerVis PROMPT STR0043 OF oVCM660 SIZE (ni*2)-15,10 PIXEL ACTION VEICC500(aVetRot[oLbVCM660:nAt,03],aVetRot[oLbVCM660:nAt,04]) WHEN ( !Empty(aVetRot[oLbVCM660:nAt,03]) .and. !FM_PILHA("VEICC500") ) // Verificar todas as visitas

	ACTIVATE MSDIALOG oVCM660 CENTER ON INIT (EnchoiceBar(oVCM660,{|| IIf(FS_OK(nOpc),(nOpcao:=1,oVCM660:End()),.t.) },{ || oVCM660:End()},,aBotVCM660))

	If nOpcao == 1 // OK Tela
		If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
			If nOpc == 3 // Incluir
				If Empty(dDatIni) .or. Empty(dDatFin)
					dDatIni := dDataBase
					For ni := 1 to len(aVetRot)
						If aVetRot[ni,02] < dDatIni
							dDatIni := aVetRot[ni,02]
						EndIf
						If aVetRot[ni,02] > dDatFin
							dDatFin := aVetRot[ni,02]
						EndIf
					Next
				EndIf
				DbSelectArea("VCN")
				RecLock("VCN",.t.)
					VCN->VCN_FILIAL := xFilial("VCN")
					VCN->VCN_CODIGO := GetSXENum("VCN","VCN_CODIGO")
					VCN->VCN_CODVEN := cCodVen
					VCN->VCN_DATINI := dDatIni
					VCN->VCN_DATFIN := dDatFin
					VCN->VCN_STATUS := "1" // 1=Digitado
					VCN->VCN_CODBCO := cCodBco
					VCN->VCN_AGEBCO := cAgeBco
					VCN->VCN_CONBCO := cConBco
				MsUnLock()
				ConfirmSX8()
			Else //  nOpc == 4 // Alterar - DELETAR REGISTROS PARA CRIA-LOS NOVAMENTE
				cQuery := "DELETE FROM "+RetSqlName("VCO")+ " WHERE VCO_FILIAL='"+VCN->VCN_FILIAL+"' AND VCO_CODIGO='"+VCN->VCN_CODIGO+"'"
				TCSqlExec(cQuery)
			EndIf
			DbSelectArea("VCO")
			For ni := 1 to len(aVetRot)
				If aVetRot[ni,01] > 0 .and. aVetRot[ni,09] > 0 // Possui KM acumulada 
					RecLock("VCO",.t.)
						VCO->VCO_FILIAL := VCN->VCN_FILIAL // Filial
						VCO->VCO_CODIGO := VCN->VCN_CODIGO // Codigo do roteiro
						VCO->VCO_DATVIS := aVetRot[ni,02] // Data da Visita
						VCO->VCO_CODCLI := aVetRot[ni,03] // Codigo do Cliente
						VCO->VCO_LOJCLI := aVetRot[ni,04] // Loja do Cliente
						VCO->VCO_ORIGEM := aVetRot[ni,06] // Origem
						VCO->VCO_KMINIC := aVetRot[ni,07] // KM inicial
						VCO->VCO_KMPERC := aVetRot[ni,08] // KM percorrida
						VCO->VCO_KMACUM := aVetRot[ni,09] // KM acumulada
						VCO->VCO_DESTIN := aVetRot[ni,10] // Destino
						VCO->VCO_VALPED := aVetRot[ni,12] // Vlr Pedagio
						VCO->VCO_VALREF := aVetRot[ni,13] // Vlr Refeicao
						VCO->VCO_VALPKM := aVetRot[ni,14] // Vlr KM rodado
						VCO->VCO_VALDIA := aVetRot[ni,15] // Vlr Diaria 
						VCO->VCO_VALHOT := aVetRot[ni,16] // Vlr Hotel  
						VCO->VCO_VALEST := aVetRot[ni,17] // Vlr Estacionamento
						VCO->VCO_VALTAX := aVetRot[ni,18] // Vlr Taxi   
						VCO->VCO_VALALU := aVetRot[ni,19] // Vlr Aluguel
						VCO->VCO_VALCEL := aVetRot[ni,20] // Vlr Celular
						VCO->VCO_VALNET := aVetRot[ni,21] // Vlr Internet
						VCO->VCO_VALFKM := aVetRot[ni,22] // Vlr Franquia KM
						VCO->VCO_OBSERV := aVetRot[ni,23] // Observacao
					MsUnLock()
				EndIf
			Next
		ElseIf nOpc == 5 // Excluir
			DbSelectArea("VCO")
			DbSetOrder(1)
			DbSeek( VCN->VCN_FILIAL + VCN->VCN_CODIGO )
			While !Eof() .and. VCO->VCO_FILIAL == VCN->VCN_FILIAL .and. VCO->VCO_CODIGO == VCN->VCN_CODIGO
				RecLock("VCO",.F.,.T.)
					dbDelete()
				MsUnLock()
				DbSelectArea("VCO")
				DbSkip()
			EndDo
			DbSelectArea("VCN")
			RecLock("VCN",.F.,.T.)
				dbDelete()
			MsUnLock()
		EndIf
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM660ICLI ³ Autor ³ Andre Luis Almeida              ³ Data ³ 30/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Incluir Roteiro SEM Agenda                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660ICLI(nOpc)
Local aRet    := {}
Local aParBox := {}
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	DbSelectArea("VCO")
	AADD(aParBox,{1,STR0030,cTod(""),"@D","IIf(!Empty(dDatIni),(MV_PAR01>=dDatIni),.t.) .and. IIf(!Empty(dDatIni),(MV_PAR01<=dDatFin),.t.)","",".T.",50,.t.}) // Data
	AADD(aParBox,{1,STR0031,space(TamSx3("A1_COD")[1]),"@!",'Empty(MV_PAR02) .or. FG_Seek("SA1","MV_PAR02+Alltrim(MV_PAR03)",1)',"SA1",".T.",35,.t.}) // Cliente
	AADD(aParBox,{1,Alltrim(SA1->(RetTitle("A1_LOJA"))),space(TamSx3("A1_LOJA")[1]),"@!",'Empty(MV_PAR03) .or. FG_Seek("SA1","MV_PAR02+MV_PAR03",1)',"",".T.",20,.t.}) // Loja
	While .t.
		If ParamBox(aParBox,STR0061,@aRet,,,,,,,,.f.) //Incluir Roteiro SEM Agenda
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+aRet[2]+aRet[3]))
			If len(aVetRot) <= 0 .or. !Empty(aVetRot[len(aVetRot),3]+aVetRot[len(aVetRot),4])
				aAdd(aVetRot,{0,aRet[1],aRet[2],aRet[3],SA1->A1_NOME,"",0,0,0,"","1",0,0,0,0,0,0,0,0,0,0,0,space(200)})
			Else
				aVetRot[len(aVetRot),02] := aRet[1]
				aVetRot[len(aVetRot),03] := aRet[2]
				aVetRot[len(aVetRot),04] := aRet[3]
				aVetRot[len(aVetRot),05] := SA1->A1_NOME
				aVetRot[len(aVetRot),23] := space(200)				
			EndIf
			oLbVCM660:nAt := len(aVetRot)
			oLbVCM660:SetArray(aVetRot)
			oLbVCM660:bLine := { || { FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,01],"@EZ 99,999")) ,;
								Transform(aVetRot[oLbVCM660:nAt,02],"@D") ,;
								aVetRot[oLbVCM660:nAt,03]+"-"+aVetRot[oLbVCM660:nAt,04]+" "+aVetRot[oLbVCM660:nAt,05] ,;
								aVetRot[oLbVCM660:nAt,06] ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,07],"@E 99,999,999")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,08],"@E 99,999,999")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,09],"@E 99,999,999")) ,;
								aVetRot[oLbVCM660:nAt,10] ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,12],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,13],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,14],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,15],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,16],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,17],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,18],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,19],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,20],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,21],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,22],"@E 999,999.99")) ,;
								aVetRot[oLbVCM660:nAt,23] }}
			oLbVCM660:Refresh()
			FS_DADOSCLI(aVetRot[oLbVCM660:nAt,03],aVetRot[oLbVCM660:nAt,04],1)
			FS_EDIT( oLbVCM660:nAt , nOpc )
		Else
			Exit
		EndIf
	EndDo
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OK    ³ Autor ³ Andre Luis Almeida                ³ Data ³ 03/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do OK da Janela                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OK(nOpc)
Local lOk := .f.
Local ni  := 0
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	For ni := 1 to len(aVetRot)   
		If aVetRot[ni,01] > 0 .and. aVetRot[ni,09] > 0 // Possui KM acumulada 
			lOk := .t.
			Exit
		EndIf
	Next
	If !lOk
		MsgStop(STR0046,STR0011) // Nenhum roteiro de visita informado. Favor verificar! / Atencao
	EndIf
ElseIf nOpc == 5 // Excluir
	lOk := .t.
EndIf
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALSA3³ Autor ³ Andre Luis Almeida                ³ Data ³ 03/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do SA3 (vendedor)                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALSA3()
Local lRet := .f.
cNomVen := ""
SA3->(DbSetOrder(1))
If SA3->(DbSeek(xFilial("SA3")+cCodVen)) 
	cNomVen := SA3->A3_NOME
	lRet := .t.
EndIf
oVCM660NVen:Refresh()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_EDIT  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Editar/Preecher colunas do ListBox                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EDIT( nLinTik , nOpc )
Local aRet      := {}
Local aParamBox := {}
Local ni        := 0
Local nMaior    := 0
Local cOrig     := left(aVetRot[nLinTik,06]+space(40),TamSx3("VCO_ORIGEM")[1])
Local nKMini    := aVetRot[nLinTik,07]
Local nKMper    := aVetRot[nLinTik,08]
Local nKMacu    := aVetRot[nLinTik,09]
Local cDest     := left(aVetRot[nLinTik,10]+space(40),TamSx3("VCO_DESTIN")[1])
Local nValPed   := aVetRot[nLinTik,12] // Vlr.Pedagio
Local nValRef   := aVetRot[nLinTik,13] // Vlr.Refeicao
Local nValPKM   := aVetRot[nLinTik,14] // Vlr.KM rodado
Local nValDia   := aVetRot[nLinTik,15] // Vlr.Diaria
Local nValHot   := aVetRot[nLinTik,16] // Vlr.Hotel
Local nValEst   := aVetRot[nLinTik,17] // Vlr.Estacionamento
Local nValTax   := aVetRot[nLinTik,18] // Vlr.Taxi
Local nValAlu   := aVetRot[nLinTik,19] // Vlr.Aluguel Veiculo
Local nValCel   := aVetRot[nLinTik,20] // Vlr.Celular
Local nValNet   := aVetRot[nLinTik,21] // Vlr.Internet
Local nValFKM   := aVetRot[nLinTik,22] // Vlr.Franquia KM
Local cObserv   := aVetRot[nLinTik,23] // Observacao
Private nLinClk := nLinTik
If ( nOpc == 3 .or. nOpc == 4 ) .and. !Empty(aVetRot[nLinTik,03])
	DbSelectArea("VCO")
	If aVetRot[nLinTik,09] == 0
		For ni := 1 to len(aVetRot)
			If nMaior <= aVetRot[ni,09] .and. ni <> nLinTik
				nMaior := aVetRot[ni,09]
				nKMini := nMaior
				cOrig  := left(aVetRot[ni,10]+space(40),TamSx3("VCO_DESTIN")[1])
			EndIf
		Next
	EndIf
	AADD(aParamBox,{1,STR0030,aVetRot[nLinTik,02],"@D","","",".F.",50,.f.}) // Data
	AADD(aParamBox,{1,STR0031,aVetRot[nLinTik,03]+"-"+aVetRot[nLinTik,04]+" "+aVetRot[nLinTik,05],"@!","","",".F.",120,.f.}) // Cliente
	AADD(aParamBox,{1,STR0032,cOrig,"@!","","",".T.",80,.f.}) // Origem
	AADD(aParamBox,{1,STR0033,nKMini,"@E 99,999,999","MV_PAR04>=0 .and. VCM660KM(1,nLinClk)","",".T.",50,.f.}) // KM inicial
	AADD(aParamBox,{1,STR0034,nKMper,"@E 99,999,999","MV_PAR05>=0 .and. VCM660KM(2,nLinClk)","",".T.",50,.f.}) // KM percorrida
	AADD(aParamBox,{1,STR0035,nKMacu,"@E 99,999,999","MV_PAR06>=0 .and. MV_PAR06>=MV_PAR04 .and. VCM660KM(3,nLinClk)","",".T.",50,.f.}) // KM acumulada
	AADD(aParamBox,{1,STR0036,cDest  ,"@!","","",".T.",80,.f.}) // Destino
	AADD(aParamBox,{1,STR0062,nValPed,"@E 999,999.99","MV_PAR08>=0","",".T.",50,.f.}) // Vlr.Pedagio
	AADD(aParamBox,{1,STR0063,nValRef,"@E 999,999.99","MV_PAR09>=0","",".T.",50,.f.}) // Vlr.Refeicao
	AADD(aParamBox,{1,STR0065,nValPKM,"@E 999,999.99","MV_PAR10>=0","",".T.",50,.f.}) // Vlr.KM rodado
	AADD(aParamBox,{1,STR0066,nValDia,"@E 999,999.99","MV_PAR11>=0","",".T.",50,.f.}) // Vlr.Diaria
	AADD(aParamBox,{1,STR0067,nValHot,"@E 999,999.99","MV_PAR12>=0","",".T.",50,.f.}) // Vlr.Hotel
	AADD(aParamBox,{1,STR0068,nValEst,"@E 999,999.99","MV_PAR13>=0","",".T.",50,.f.}) // Vlr.Estacionamento
	AADD(aParamBox,{1,STR0069,nValTax,"@E 999,999.99","MV_PAR14>=0","",".T.",50,.f.}) // Vlr.Taxi
	AADD(aParamBox,{1,STR0070,nValAlu,"@E 999,999.99","MV_PAR15>=0","",".T.",50,.f.}) // Vlr.Aluguel Veiculo
	AADD(aParamBox,{1,STR0071,nValCel,"@E 999,999.99","MV_PAR16>=0","",".T.",50,.f.}) // Vlr.Celular
	AADD(aParamBox,{1,STR0079,nValNet,"@E 999,999.99","MV_PAR17>=0","",".T.",50,.f.}) // Vlr.Internet
	AADD(aParamBox,{1,STR0080,nValFKM,"@E 999,999.99","MV_PAR18>=0","",".T.",50,.f.}) // Vlr.Franquia KM
	AADD(aParamBox,{1,STR0076,cObserv,"@!","","",".T.",120,.f.}) // Observacao
	If ParamBox(aParamBox,STR0049,@aRet,,,,,,,,.f.) //Digitacao
		aVetRot[nLinTik,06] := aRet[03] // Origem
		aVetRot[nLinTik,07] := aRet[04] // KM inicial
		aVetRot[nLinTik,08] := aRet[05] // KM percorrida      			
		aVetRot[nLinTik,09] := aRet[06] // KM acumulada
		aVetRot[nLinTik,10] := aRet[07] // Destino
		aVetRot[nLinTik,11] := "0"      // Ordem INTERNA
		aVetRot[nLinTik,12] := aRet[08] // Vlr.Pedagio
		aVetRot[nLinTik,13] := aRet[09] // Vlr.Refeicao
		aVetRot[nLinTik,14] := aRet[10] // Vlr.KM rodado
		aVetRot[nLinTik,15] := aRet[11] // Vlr.Diaria
		aVetRot[nLinTik,16] := aRet[12] // Vlr.Hotel
		aVetRot[nLinTik,17] := aRet[13] // Vlr.Estacionamento
		aVetRot[nLinTik,18] := aRet[14] // Vlr.Taxi
		aVetRot[nLinTik,19] := aRet[15] // Vlr.Aluguel Veiculo
		aVetRot[nLinTik,20] := aRet[16] // Vlr.Celular
		aVetRot[nLinTik,21] := aRet[17] // Vlr.Internet
		aVetRot[nLinTik,22] := aRet[18] // Vlr.Franquia KM
		aVetRot[nLinTik,23] := aRet[19] // Observacao
	EndIf
	aSort(aVetRot,1,,{|x,y| x[11]+strzero(x[9],8)+strzero(x[7],8)+dtos(x[2])+x[5] < y[11]+strzero(y[9],8)+strzero(y[7],8)+dtos(y[2])+y[5] }) // KM acumulada + Data + Nome Cliente
	nMaior := 0
	For ni := 1 to len(aVetRot)
		If aVetRot[ni,09] > 0
			nMaior++
			aVetRot[ni,01] := nMaior // Ordem
			aVetRot[ni,11] := "0"    // Ordem INTERNA
		Else
			aVetRot[ni,06] := ""     // Origem
			aVetRot[ni,01] := 0      // Ordem
			aVetRot[ni,10] := ""     // Destino
			aVetRot[ni,11] := "1"    // Ordem INTERNA
		EndIf
	Next
	aSort(aVetRot,1,,{|x,y| x[11]+strzero(x[9],8)+strzero(x[7],8)+dtos(x[2])+x[5] < y[11]+strzero(y[9],8)+strzero(y[7],8)+dtos(y[2])+y[5] }) // KM acumulada + Data + Nome Cliente
	oLbVCM660:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM660KM ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Digitacao das KMs ( inicial / percorrida / acumulada )                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660KM(nQualKM,nLinTik)
Local ni   := 0
Local lRet := .t.
Local cMsg := ""
For ni := 1 to len(aVetRot)
	If ni <> nLinTik .and. lRet .and. aVetRot[ni,01] > 0
		cMsg := STR0029+": "+Transform(aVetRot[ni,01],"@EZ 99,999")+space(10)+STR0030+": "+Transform(aVetRot[ni,02],"@D")+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg += FG_AlinVlrs(left(aVetRot[ni,03]+"-"+aVetRot[ni,04]+space(15),15),"E")+aVetRot[ni,05]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg += FG_AlinVlrs(left(STR0032+":"+space(15),15),"E")+aVetRot[ni,06]+CHR(13)+CHR(10)
		cMsg += FG_AlinVlrs(left(STR0033+":"+space(15),15),"E")+FG_AlinVlrs(Transform(aVetRot[ni,07],"@E 99,999,999"))+CHR(13)+CHR(10)
		cMsg += FG_AlinVlrs(left(STR0034+":"+space(15),15),"E")+FG_AlinVlrs(Transform(aVetRot[ni,08],"@E 99,999,999"))+CHR(13)+CHR(10)
		cMsg += FG_AlinVlrs(left(STR0035+":"+space(15),15),"E")+FG_AlinVlrs(Transform(aVetRot[ni,09],"@E 99,999,999"))+CHR(13)+CHR(10)
		cMsg += FG_AlinVlrs(left(STR0036+":"+space(15),15),"E")+aVetRot[ni,10]
		If nQualKM == 1 // KM inicial
			If ( aVetRot[ni,07] < MV_PAR04 .and. MV_PAR04 < aVetRot[ni,09] )
				MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0011) // KM informada esta dentro do roteiro: / Atencao
				lRet := .f.
			EndIf
		ElseIf nQualKM == 2 // KM percorrida
			If ( aVetRot[ni,07] < (MV_PAR04+MV_PAR05) .and. (MV_PAR04+MV_PAR05) < aVetRot[ni,09] )
				MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0011) // KM informada esta dentro do roteiro: / Atencao
				lRet := .f.
			ElseIf ( MV_PAR04 <> MV_PAR04+MV_PAR05 ) .and. ( aVetRot[ni,07] <> aVetRot[ni,09] )
				If ( MV_PAR04 <= aVetRot[ni,07] .and. MV_PAR04+MV_PAR05 >= aVetRot[ni,09] )
					MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0011) // KM informada esta dentro do roteiro: / Atencao
					lRet := .f.
				EndIf
			EndIf
		ElseIf nQualKM == 3 // KM acumulada
			If ( aVetRot[ni,07] < MV_PAR06 .and. MV_PAR06 < aVetRot[ni,09] )
				MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0011) // KM informada esta dentro do roteiro: / Atencao
				lRet := .f.
			ElseIf ( MV_PAR04 <> MV_PAR06 ) .and. ( aVetRot[ni,07] <> aVetRot[ni,09] )
				If ( MV_PAR04 <= aVetRot[ni,07] .and. MV_PAR06 >= aVetRot[ni,09] )
					MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0011) // KM informada esta dentro do roteiro: / Atencao
					lRet := .f.
				EndIf
			EndIf
		EndIf
	EndIf
Next
If lRet
	If nQualKM == 1 // KM inicial
		MV_PAR06 := ( MV_PAR04 + MV_PAR05 )
	ElseIf nQualKM == 2 // KM percorrida
		MV_PAR06 := ( MV_PAR04 + MV_PAR05 )
	ElseIf nQualKM == 3 // KM acumulada
		MV_PAR05 := ( MV_PAR06 - MV_PAR04 )
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTRAR³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Agendas (VC1/VCO) por Periodo/Vendedor                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp,nOpc)
Local cQAlias  := "SQLVC1VCO" // VC1 / VCO
Local cQuery   := ""
Local lOk      := .t.
Local nValPed  := 0 // Vlr.Pedagio
Local nValRef  := 0 // Vlr.Refeicao
Local nValPKM  := 0 // Vlr.KM rodado
Local nValDia  := 0 // Vlr.Diaria
Local nValHot  := 0 // Vlr.Hotel
Local nValEst  := 0 // Vlr.Estacionamento
Local nValTax  := 0 // Vlr.Taxi
Local nValAlu  := 0 // Vlr.Aluguel Veiculo
Local nValCel  := 0 // Vlr.Celular
Local nValNet  := 0 // Vlr.Internet
Local nValFKM  := 0 // Vlr.Franquia KM
Local cObserv  := "" // Observacao
aVetRot := {}
If nOpc == 3 // Incluir
	If nTp == 1
		If Empty(cCodVen)
			MsgStop(STR0037,STR0011) // Vendedor nao informado! / Atencao
		Else            
			// Verificar se ja existe roteiro no periodo informado //
			cQuery := "SELECT VCO.R_E_C_N_O_ RECVCO "
			cQuery += "FROM "+RetSqlName("VCO")+" VCO , "+RetSqlName("VCN")+" VCN "
			cQuery += "WHERE VCO.VCO_FILIAL='"+xFilial("VCO")+"' AND VCO.VCO_DATVIS>='"+dtos(dDatIni)+"' AND VCO.VCO_DATVIS<='"+dtos(dDatFin)+"' AND VCO.D_E_L_E_T_=' ' AND "
			cQuery += "VCN.VCN_FILIAL=VCO.VCO_FILIAL AND VCN.VCN_CODIGO=VCO.VCO_CODIGO AND VCN.VCN_CODVEN='"+cCodVen+"' AND VCN.D_E_L_E_T_=' '"
			If FM_SQL(cQuery) > 0
				If !MsgYesNo(STR0048,STR0011) // Ja existe(m) roteiro(s) cadastrado(s) para o Vendedor dentro do periodo informado. Deseja continuar? / Atencao
					lOk := .f.
				EndIf
			EndIf
			If lOk
				// Levanta Visitas (VC1) pelo Vendedor e Data de Visita ou Abordagem //
                If cTipoDt == "1" // Data da Agenda
					cQuery := "SELECT VC1.VC1_DATAGE AS VC1_DATA , "
				Else // Data da Abordagem
					cQuery := "SELECT VC1.VC1_DATVIS AS VC1_DATA , "
				EndIf				
				cQuery += "VC1.VC1_CODCLI , VC1.VC1_LOJA , SA1.A1_NOME FROM "+RetSqlName("VC1")+" VC1 "
				cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC1.VC1_CODCLI AND SA1.A1_LOJA=VC1.VC1_LOJA AND SA1.D_E_L_E_T_=' ' ) "
				cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_CODVEN='"+cCodVen+"' AND "
				If cAgenCS == "1" // Agendas SEM Abordagem 
					cQuery += "VC1.VC1_DATVIS=' ' AND "
       			ElseIf cAgenCS == "2" // Agendas COM Abordagem
					cQuery += "VC1.VC1_DATVIS<>' ' AND "
      			EndIf
                If cTipoDt == "1" // Data da Agenda
					cQuery += "VC1.VC1_DATAGE>='"+dtos(dDatIni)+"' AND VC1.VC1_DATAGE<='"+dtos(dDatFin)+"' AND VC1.D_E_L_E_T_=' ' "
					cQuery += "ORDER BY VC1.VC1_DATAGE , SA1.A1_NOME "
				Else // Data da Abordagem
					cQuery += "VC1.VC1_DATVIS>='"+dtos(dDatIni)+"' AND VC1.VC1_DATVIS<='"+dtos(dDatFin)+"' AND VC1.D_E_L_E_T_=' ' "
					cQuery += "ORDER BY VC1.VC1_DATVIS , SA1.A1_NOME "
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
				Do While !( cQAlias )->( Eof() )
					aAdd(aVetRot,{0,stod(( cQAlias )->( VC1_DATA )),( cQAlias )->( VC1_CODCLI ),( cQAlias )->( VC1_LOJA ),( cQAlias )->( A1_NOME ),"",0,0,0,"","1",0,0,0,0,0,0,0,0,0,0,0,space(200)})
					( cQAlias )->( DbSkip() )
				EndDo
				( cQAlias )->( dbCloseArea() )
			EndIf
		EndIf
	EndIf
Else 
	// Levanta registros ja gravados ( VCN / VCO ) //
	cQuery := "SELECT VCO.VCO_DATVIS , VCO.VCO_CODCLI , VCO.VCO_LOJCLI , SA1.A1_NOME , VCO.VCO_ORIGEM , VCO.VCO_KMINIC , VCO.VCO_KMPERC , VCO.VCO_KMACUM , VCO.VCO_DESTIN "
	cQuery += ", VCO.VCO_VALPED , VCO.VCO_VALREF , VCO.VCO_VALPKM , VCO.VCO_VALDIA , VCO.VCO_VALHOT , VCO.VCO_VALEST , VCO.VCO_VALTAX , VCO.VCO_VALALU , VCO.VCO_VALCEL , VCO.VCO_VALNET , VCO.VCO_VALFKM , VCO.VCO_OBSERV "
	cQuery += "FROM "+RetSqlName("VCO")+" VCO "
	cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VCO.VCO_CODCLI AND SA1.A1_LOJA=VCO.VCO_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VCO.VCO_FILIAL='"+VCN->VCN_FILIAL+"' AND VCO.VCO_CODIGO='"+VCN->VCN_CODIGO+"' AND "
	cQuery += "VCO.D_E_L_E_T_=' ' ORDER BY VCO.VCO_KMACUM "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		nValPed := ( cQAlias )->( VCO_VALPED ) // Vlr.Pedagio
		nValRef := ( cQAlias )->( VCO_VALREF ) // Vlr.Refeicao
		nValPKM := ( cQAlias )->( VCO_VALPKM ) // Vlr.KM rodado
		nValDia := ( cQAlias )->( VCO_VALDIA ) // Vlr.Diaria
		nValHot := ( cQAlias )->( VCO_VALHOT ) // Vlr.Hotel
		nValEst := ( cQAlias )->( VCO_VALEST ) // Vlr.Estacionamento
		nValTax := ( cQAlias )->( VCO_VALTAX ) // Vlr.Taxi
		nValAlu := ( cQAlias )->( VCO_VALALU ) // Vlr.Aluguel Veiculo
		nValCel := ( cQAlias )->( VCO_VALCEL ) // Vlr.Celular
		nValNet := ( cQAlias )->( VCO_VALNET ) // Vlr.Internet
		nValFKM := ( cQAlias )->( VCO_VALFKM ) // Vlr.Franquia KM			
		cObserv := ( cQAlias )->( VCO_OBSERV ) // Observacao
		aAdd(aVetRot,{len(aVetRot)+1,stod(( cQAlias )->( VCO_DATVIS )),( cQAlias )->( VCO_CODCLI ),( cQAlias )->( VCO_LOJCLI ),( cQAlias )->( A1_NOME ),( cQAlias )->( VCO_ORIGEM ),( cQAlias )->( VCO_KMINIC ),( cQAlias )->( VCO_KMPERC ),( cQAlias )->( VCO_KMACUM ),( cQAlias )->( VCO_DESTIN ),"0",nValPed,nValRef,nValPKM,nValDia,nValHot,nValEst,nValTax,nValAlu,nValCel,nValNet,nValFKM,cObserv})
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
If len(aVetRot) <= 0
	aAdd(aVetRot,{0,ctod(""),"","","","",0,0,0,"","1",0,0,0,0,0,0,0,0,0,0,0,""})
EndIf
If nTp == 1
	oLbVCM660:nAt := 1
	oLbVCM660:SetArray(aVetRot)
	oLbVCM660:bLine := { || { FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,01],"@EZ 99,999")) ,;
								Transform(aVetRot[oLbVCM660:nAt,02],"@D") ,;
								aVetRot[oLbVCM660:nAt,03]+"-"+aVetRot[oLbVCM660:nAt,04]+" "+aVetRot[oLbVCM660:nAt,05] ,;
								aVetRot[oLbVCM660:nAt,06] ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,07],"@E 99,999,999")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,08],"@E 99,999,999")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,09],"@E 99,999,999")) ,;
								aVetRot[oLbVCM660:nAt,10] ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,12],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,13],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,14],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,15],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,16],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,17],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,18],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,19],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,20],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,21],"@E 999,999.99")) ,;
								FG_AlinVlrs(Transform(aVetRot[oLbVCM660:nAt,22],"@E 999,999.99")) ,;
								aVetRot[oLbVCM660:nAt,23] }}
	oLbVCM660:Refresh()
	oLbVCM660:SetFocus()
	FS_DADOSCLI(aVetRot[oLbVCM660:nAt,03],aVetRot[oLbVCM660:nAt,04],1)	
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM660FIN ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finaliza Roteiro de Visistas                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660FIN()
If VCN->VCN_STATUS == "1" // 1=Digitado
	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	If Empty(VAI->VAI_CEVROT) .or. VAI->VAI_CEVROT == "1" // usuario somente digita
		MsgStop(STR0024,STR0011) // Usuario sem permissao para FINALIZAR roteiro! / Atencao
	Else
		If MsgYesNo(STR0022,STR0011) // Deseja FINALIZAR o roteiro? / Atencao
			DbSelectArea("VCN")
			RecLock("VCN",.f.)
				VCN->VCN_STATUS := "2" // 2=Finalizado
			MsUnLock()
		EndIf
	EndIf
ElseIf VCN->VCN_STATUS == "2" // 2=Finalizado
	MsgStop(STR0021,STR0011) // Roteiro ja FINALIZADO! / Atencao
ElseIf VCN->VCN_STATUS == "3" // 3=Aprovado
	MsgStop(STR0019,STR0011) // Roteiro ja APROVADO! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM660APR ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova Roteiro de Visistas                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660APR()
If VCN->VCN_STATUS == "1" // 1=Digitado
	MsgStop(STR0018,STR0011) // FINALIZAR roteiro antes de APROVAR! /  Atencao
ElseIf VCN->VCN_STATUS == "2" // 2=Finalizado
	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	If VAI->VAI_CEVROT <> "3" // usuario nao aprova roteiro
		MsgStop(STR0020,STR0011) // Usuario sem permissao para APROVAR roteiro! / Atencao
	Else
		If MsgYesNo(STR0023,STR0011) // Deseja APROVAR o roteiro? / Atencao
			DbSelectArea("VCN")
			RecLock("VCN",.f.)
				VCN->VCN_STATUS := "3" // 3=Aprovado
			MsUnLock()
		EndIf
	EndIf
ElseIf VCN->VCN_STATUS == "3" // 3=Aprovado
	MsgStop(STR0019,STR0011) // Roteiro ja APROVADO! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DADOSCLI³ Autor ³ Andre Luis Almeida               ³ Data ³ 03/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega Dados do Cliente e Ultimas Visitas                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DADOSCLI(cCodCli,cLojCli,nTp)
Local cQuery := ""
cCliCGC := ""
cCliFon := ""
cCliEnd := ""
cCliBai := ""
cCliCEP := ""
cCliMun := ""
cUltVen := ""
cUltGer := ""
If !Empty(cCodCli+cLojCli)
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
		// Carrega Dados do Cliente //
		cCliCGC := Transform(SA1->A1_CGC,IIf(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))
		cCliFon := "( "+Alltrim(SA1->A1_DDD)+" ) "+SA1->A1_TEL
		cCliEnd := SA1->A1_END
		cCliBai := SA1->A1_BAIRRO 
		cCliCEP := Transform(SA1->A1_CEP,SA1->(x3Picture("A1_CEP")))
		cCliMun := Alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST
		VAM->(DbSetOrder(1))	
		If VAM->(Dbseek(xFilial("VAM")+SA1->A1_IBGE))
			cCliMun := Alltrim(VAM->VAM_DESCID)+"-"+VAM->VAM_ESTADO
		EndIf
		If nTp == 1 // Levanta ultimas visitas e atualiza objetos na tela
			// Levanta a ultima visita do Vendedor para o Cliente //
			cQuery := "SELECT VC1.VC1_DATVIS FROM "+RetSqlName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_CODVEN='"+cCodVen+"' AND "
			cQuery += "VC1.VC1_CODCLI='"+cCodCli+"' AND VC1.VC1_LOJA='"+cLojCli+"' AND VC1.VC1_DATVIS<>' ' AND VC1.D_E_L_E_T_=' ' ORDER BY VC1.VC1_DATVIS DESC "
			cUltVen := FM_SQL(cQuery)
			If !Empty(cUltVen)
				cUltVen := Transform(stod(cUltVen),"@D")
			EndIf
			// Levanta a ultima visita geral para o Cliente //
			cQuery := "SELECT VC1.VC1_DATVIS FROM "+RetSqlName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
			cQuery += "VC1.VC1_CODCLI='"+cCodCli+"' AND VC1.VC1_LOJA='"+cLojCli+"' AND VC1.VC1_DATVIS<>' ' AND VC1.D_E_L_E_T_=' ' ORDER BY VC1.VC1_DATVIS DESC "
			cUltGer := FM_SQL(cQuery)
			If !Empty(cUltGer)
				cUltGer := Transform(stod(cUltGer),"@D")
			EndIf
		EndIf
	EndIf
EndIf
If nTp == 1 // Levanta ultimas visitas e atualiza objetos na tela
	oV660ClCGC:Refresh()
	oV660ClFon:Refresh()
	oV660ClEnd:Refresh()
	oV660ClBai:Refresh()
	oV660ClCEP:Refresh()
	oV660ClMun:Refresh()
	oV660UlVen:Refresh()
	oV660UlGer:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM660LEG ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Roteiro de Visistas                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660LEG()
Local aLegenda := {	{'BR_LARANJA'	,STR0003},;	// Digitado
					{'BR_VERDE'		,STR0004},;	// Finalizado
					{'BR_AZUL'		,STR0005}}	// Aprovado
BrwLegenda(cCadastro,STR0002,aLegenda) // Legenda
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM660IMP ³ Autor ³ Andre Luis Almeida                ³ Data ³ 03/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Roteiro de Visistas                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM660IMP(nTp)
Local nQtdPerc  := 0
//
Local nValPed   := 0 // Vlr.Pedagio
Local nValRef   := 0 // Vlr.Refeicao
Local nValPKM   := 0 // Vlr.KM rodado
Local nValDia   := 0 // Vlr.Diaria
Local nValHot   := 0 // Vlr.Hotel
Local nValEst   := 0 // Vlr.Estacionamento
Local nValTax   := 0 // Vlr.Taxi
Local nValAlu   := 0 // Vlr.Aluguel Veiculo
Local nValCel   := 0 // Vlr.Celular
Local nValNet   := 0 // Vlr.Internet
Local nValFKM   := 0 // Vlr.Franquia KM
Local nTotKM    := 0 // Total KM( Vlr.KM rodado * KM rodado )
Local nTotal    := 0 // Total Geral
Local cObserv   := "" // Observacao
//
Local ni        := 0
Local nj        := 0
Local cSQL      := ""
Local cQAlias   := "SQLVCO" // VCO
Local cQuery    := ""
Local cQuebra   := ""
Local aRet      := {}
Local aParamBox := {}
//
Local aImpres   := {} // Impressao
Local aTotDat   := {} // Total por Data
Local aTotVen   := {} // Total por Vendedor
Local aDatVen   := {} // Total por Data e Vendedor
//
Local cBkpFilAnt:= cFilAnt
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont     := 0
//
Private cDesc1  := ""
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "G"
Private limite  := 220
Private cString := "VCN"
Private titulo  := STR0001 // Roteiro de Visitas
Private cabec1  := ""
Private cabec2  := ""
Private cabAux  := ""
Private aReturn := {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEICM660"
Private nLastKey:= 0
Private cPerg   := "VCM660"
// Dados do Cliente
Private cCliCGC := ""
Private cCliFon := ""
Private cCliEnd := ""
Private cCliBai := ""
Private cCliCEP := ""
Private cCliMun := ""
DbSelectArea("VCN")
If nTp == 1 // Imprimir somente o Roteiro selecionado no Browse
	cabec1  := X3CBOXDESC("VCN_STATUS",VCN->VCN_STATUS)+" - "+STR0025+": "+VCN->VCN_CODVEN // Vendedor
	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(xFilial("SA3")+VCN->VCN_CODVEN)) 
		cabec1 += " "+left(SA3->A3_NOME,25)
	EndIf
	cabec1 += " - "+STR0026+": "+Transform(VCN->VCN_DATINI,"@D")+" "+STR0027+" "+Transform(VCN->VCN_DATFIN,"@D") // Periodo / a
	cabec1 += " - "+STR0073+": "+VCN->VCN_CODBCO+" "+STR0074+": "+VCN->VCN_AGEBCO+" "+STR0075+": "+VCN->VCN_CONBCO // Banco / Agencia / Conta
Else // Imprimir Roteiros por Periodo e/ou Vendedor
	AADD(aParamBox,{1,STR0052,dDataBase-day(dDataBase)+1,"@D","","",".T.",50,.f.}) // Data Incial
	AADD(aParamBox,{1,STR0053,dDataBase,"@D","","",".T.",50,.f.}) // Data Final
	AADD(aParamBox,{1,STR0025,space(TamSX3("A3_COD")[1]),"@!","","SA3",".T.",50,.f.}) // Vendedor
	AADD(aParamBox,{1,STR0078,cFilAnt,"@!","","SM0_01",".T.",70,.f.}) // Filial
	If !ParamBox(aParamBox,STR0001,@aRet,,,,,,,,.f.) // Roteiro de Visitas
		Return()
	EndIf
	cabec1 := STR0026+": "+Transform(aRet[1],"@D")+" "+STR0027+" "+Transform(aRet[2],"@D") // Periodo / a
	If !Empty(aRet[3])
		cabec1 += " - "+STR0025+": "+aRet[3] // Vendedor
		SA3->(DbSetOrder(1))
		If SA3->(DbSeek(xFilial("SA3")+aRet[3])) 
			cabec1 += " "+left(SA3->A3_NOME,25)
		EndIf
	EndIf
	If !Empty(aRet[4])
		cabec1 += " - "+STR0078+": "+aRet[4] // Filial
	EndIf
EndIf
cabAux := cabec1
nomeprog := SetPrint(cString,nomeprog,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf     
SetDefault(aReturn,cString)
nLin  := 60
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
Pergunte(cPerg,.f.)
If nTp == 1 // Imprimir somente o Roteiro selecionado no Browse
	cSQL := "FROM "+RetSqlName("VCO")+" VCO WHERE VCO.VCO_FILIAL='"+VCN->VCN_FILIAL+"' AND VCO.VCO_CODIGO='"+VCN->VCN_CODIGO+"' AND VCO.D_E_L_E_T_=' ' "
	nQtdPerc := FM_SQL("SELECT SUM(VCO.VCO_KMPERC) KMPERC "+cSQL)
	nValPed := FM_SQL("SELECT SUM(VCO.VCO_VALPED) VALOR "+cSQL)
	nValRef := FM_SQL("SELECT SUM(VCO.VCO_VALREF) VALOR "+cSQL)
	nValDia := FM_SQL("SELECT SUM(VCO.VCO_VALDIA) VALOR "+cSQL)
	nValHot := FM_SQL("SELECT SUM(VCO.VCO_VALHOT) VALOR "+cSQL)
	nValEst := FM_SQL("SELECT SUM(VCO.VCO_VALEST) VALOR "+cSQL)
	nValTax := FM_SQL("SELECT SUM(VCO.VCO_VALTAX) VALOR "+cSQL)
	nValAlu := FM_SQL("SELECT SUM(VCO.VCO_VALALU) VALOR "+cSQL)
	nValCel := FM_SQL("SELECT SUM(VCO.VCO_VALCEL) VALOR "+cSQL)
	nValNet := FM_SQL("SELECT SUM(VCO.VCO_VALNET) VALOR "+cSQL)
	nValFKM := FM_SQL("SELECT SUM(VCO.VCO_VALFKM) VALOR "+cSQL)
	nTotKM  := FM_SQL("SELECT SUM(VCO.VCO_VALPKM * VCO.VCO_KMPERC) VALOR "+cSQL)
	nTotal  := ( nValPed + nValRef + nTotKM + nValDia + nValHot + nValEst + nValTax + nValAlu + nValCel + nValNet + nValFKM )

	/////////////////////////////////
	// MEDIA do valor do KM rodado //
	/////////////////////////////////
	nValPKM := ( ( nTotal - ( nValPed + nValRef + nValDia + nValHot + nValEst + nValTax + nValAlu + nValCel + nValNet + nValFKM ) ) / nQtdPerc )
	/////////////////////////////////

	If nQtdPerc > 0 
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		@ nLin++, 42 PSAY STR0072 // Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
		@ nLin++, 00 PSAY left(STR0050+Transform(nQtdPerc,"@E 999,999,999")+space(40),40)+Transform(nValPed,"@E 99999,999.99")+Transform(nValRef,"@E 99999,999.99")+Transform(nValPKM,"@E 999999.99999")+Transform(nValDia,"@E 99999,999.99")+Transform(nValHot,"@E 99999,999.99")+Transform(nValEst,"@E 99999,999.99")+Transform(nValTax,"@E 99999,999.99")+Transform(nValAlu,"@E 99999,999.99")+Transform(nValCel,"@E 99999,999.99")+Transform(nValNet,"@E 99999,999.99")+Transform(nValFKM,"@E 99999,999.99")+Transform(nTotal,"@E 99,999,999.99")
		@ nLin++, 00 PSAY repl("_",limite)
	EndIf
	cQuery := "SELECT VCO.VCO_DATVIS , VCO.VCO_CODCLI , VCO.VCO_LOJCLI , SA1.A1_NOME , VCO.VCO_ORIGEM , VCO.VCO_KMINIC , VCO.VCO_KMPERC , VCO.VCO_KMACUM , VCO.VCO_DESTIN "
	cQuery += ", VCO.VCO_VALPED , VCO.VCO_VALREF , VCO.VCO_VALPKM , VCO.VCO_VALDIA , VCO.VCO_VALHOT , VCO.VCO_VALEST , VCO.VCO_VALTAX , VCO.VCO_VALALU , VCO.VCO_VALCEL , VCO.VCO_VALNET , VCO.VCO_VALFKM , VCO.VCO_OBSERV "
	cQuery += "FROM "+RetSqlName("VCO")+" VCO "
	cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VCO.VCO_CODCLI AND SA1.A1_LOJA=VCO.VCO_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VCO.VCO_FILIAL='"+VCN->VCN_FILIAL+"' AND VCO.VCO_CODIGO='"+VCN->VCN_CODIGO+"' AND "
	cQuery += "VCO.D_E_L_E_T_=' ' ORDER BY VCO.VCO_KMACUM "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If nLin >= 55
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIf
		If cQuebra <> ( cQAlias )->( VCO_DATVIS )
			cQuebra := ( cQAlias )->( VCO_DATVIS )
			nLin++
			@ nLin++, 00 PSAY Transform(stod(cQuebra),"@D")
			nLin++
			@ nLin++, 00 PSAY STR0045 // Ordem  Cliente                        Origem                         KM inicial KM percor. KM acumul. Destino                        
		EndIf
		nValPed := ( cQAlias )->( VCO_VALPED ) // Vlr.Pedagio
		nValRef := ( cQAlias )->( VCO_VALREF ) // Vlr.Refeicao
		nValPKM := ( cQAlias )->( VCO_VALPKM ) // Vlr.KM rodado
		nValDia := ( cQAlias )->( VCO_VALDIA ) // Vlr.Diaria
		nValHot := ( cQAlias )->( VCO_VALHOT ) // Vlr.Hotel
		nValEst := ( cQAlias )->( VCO_VALEST ) // Vlr.Estacionamento
		nValTax := ( cQAlias )->( VCO_VALTAX ) // Vlr.Taxi
		nValAlu := ( cQAlias )->( VCO_VALALU ) // Vlr.Aluguel Veiculo
		nValCel := ( cQAlias )->( VCO_VALCEL ) // Vlr.Celular
		nValNet := ( cQAlias )->( VCO_VALNET ) // Vlr.Internet
		nValFKM := ( cQAlias )->( VCO_VALFKM ) // Vlr.Franquia KM
		nTotKM  := ( ( cQAlias )->( VCO_VALPKM ) * ( cQAlias )->( VCO_KMPERC ) ) // Total ( Vlr.KM rodado * KM rodado )
		cObserv := ( cQAlias )->( VCO_OBSERV ) // Observacao
		nTotal  := ( nValPed + nValRef + nTotKM + nValDia + nValHot + nValEst + nValTax + nValAlu + nValCel + nValNet + nValFKM )
	    ni++
		@ nLin++, 00 PSAY Transform(ni,"@E 99999")+"  "+left(( cQAlias )->( VCO_CODCLI )+"-"+( cQAlias )->( VCO_LOJCLI )+" "+( cQAlias )->( A1_NOME ),30)+" "+( cQAlias )->( VCO_ORIGEM )+Transform(( cQAlias )->( VCO_KMINIC ),"@E 999,999,999")+Transform(( cQAlias )->( VCO_KMPERC ),"@E 999,999,999")+Transform(( cQAlias )->( VCO_KMACUM ),"@E 999,999,999")+" "+( cQAlias )->( VCO_DESTIN )
		If !Empty(cObserv)
			@ nLin++, 07 PSAY STR0077+": "+cObserv // Obs.
		EndIf
		If MV_PAR01 == 2 // Sim
			FS_DADOSCLI(( cQAlias )->( VCO_CODCLI ),( cQAlias )->( VCO_LOJCLI ),0)
			@ nLin++, 07 PSAY cCliEnd+" "+cCliBai+" "+left(cCliFon+space(22),22)+" "+cCliMun
		EndIf
		@ nLin++, 42 PSAY STR0072 // Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
		@ nLin++, 40 PSAY Transform(nValPed,"@E 99999,999.99")+Transform(nValRef,"@E 99999,999.99")+Transform(nValPKM,"@E 999999.99999")+Transform(nValDia,"@E 99999,999.99")+Transform(nValHot,"@E 99999,999.99")+Transform(nValEst,"@E 99999,999.99")+Transform(nValTax,"@E 99999,999.99")+Transform(nValAlu,"@E 99999,999.99")+Transform(nValCel,"@E 99999,999.99")+Transform(nValNet,"@E 99999,999.99")+Transform(nValFKM,"@E 99999,999.99")+Transform(nTotal,"@E 99,999,999.99")
		nLin++
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Else // Imprimir Roteiros por Periodo e/ou Vendedor
	For nCont := 1 to Len(aSM0)
		If !Empty(aRet[4]) .and. aRet[4] <> aSM0[nCont]
			Loop
		EndIf
		cFilAnt := aSM0[nCont]
		//
		cabec1 := cabAux 
		If Empty(aRet[4])
			cabec1 += " - "+STR0078+": "+cFilAnt // Filial
		EndIf
		//
		aImpres   := {} // Impressao
		aTotDat   := {} // Total por Data
		aTotVen   := {} // Total por Vendedor
		aDatVen   := {} // Total por Data e Vendedor
		//
		aAdd(aTotDat,{STR0054,0,"",0,0,0,0,0,0,0,0,0,0,0,0}) // Total por Data
		aAdd(aTotVen,{STR0055,0,"",0,0,0,0,0,0,0,0,0,0,0,0}) // Total por Vendedor
	    //
		cQuery := "SELECT VCO.VCO_DATVIS , VCO.VCO_CODCLI , VCO.VCO_LOJCLI , SA1.A1_NOME , VCO.VCO_ORIGEM , VCO.VCO_KMINIC , VCO.VCO_KMPERC , VCO.VCO_KMACUM , VCO.VCO_DESTIN , VCN.VCN_CODVEN , SA3.A3_NOME "
		cQuery += ", VCO.VCO_VALPED , VCO.VCO_VALREF , VCO.VCO_VALPKM , VCO.VCO_VALDIA , VCO.VCO_VALHOT , VCO.VCO_VALEST , VCO.VCO_VALTAX , VCO.VCO_VALALU , VCO.VCO_VALCEL , VCO.VCO_VALNET , VCO.VCO_VALFKM , VCO.VCO_OBSERV "
		cQuery += "FROM "+RetSqlName("VCO")+" VCO "
		cQuery += "JOIN "+RetSqlName("VCN")+" VCN ON ( VCN.VCN_FILIAL='"+xFilial("VCN")+"' AND VCN.VCN_CODIGO=VCO.VCO_CODIGO AND VCN.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VCO.VCO_CODCLI AND SA1.A1_LOJA=VCO.VCO_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VCN.VCN_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VCO.VCO_FILIAL='"+xFilial("VCO")+"' AND VCO.VCO_DATVIS>='"+dtos(aRet[1])+"' AND VCO.VCO_DATVIS<='"+dtos(aRet[2])+"' AND "
		If !Empty(aRet[3])
			cQuery += "VCN.VCN_CODVEN='"+aRet[3]+"' AND "
		EndIf
		cQuery += "VCO.D_E_L_E_T_=' ' ORDER BY VCO.VCO_DATVIS , VCN.VCN_CODVEN , VCO.VCO_KMACUM "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		Do While !( cQAlias )->( Eof() )
			nValPed := ( cQAlias )->( VCO_VALPED ) // Vlr.Pedagio
			nValRef := ( cQAlias )->( VCO_VALREF ) // Vlr.Refeicao
			nValPKM := ( cQAlias )->( VCO_VALPKM ) // Vlr.KM rodado
			nValDia := ( cQAlias )->( VCO_VALDIA ) // Vlr.Diaria
			nValHot := ( cQAlias )->( VCO_VALHOT ) // Vlr.Hotel
			nValEst := ( cQAlias )->( VCO_VALEST ) // Vlr.Estacionamento
			nValTax := ( cQAlias )->( VCO_VALTAX ) // Vlr.Taxi
			nValAlu := ( cQAlias )->( VCO_VALALU ) // Vlr.Aluguel Veiculo
			nValCel := ( cQAlias )->( VCO_VALCEL ) // Vlr.Celular
			nValNet := ( cQAlias )->( VCO_VALNET ) // Vlr.Internet
			nValFKM := ( cQAlias )->( VCO_VALFKM ) // Vlr.Franquia KM
			nTotKM  := ( ( cQAlias )->( VCO_VALPKM ) * ( cQAlias )->( VCO_KMPERC ) ) // Total ( Vlr.KM rodado * KM rodado )
			cObserv := ( cQAlias )->( VCO_OBSERV ) // Observacao
			nTotal  := ( nValPed + nValRef + nTotKM + nValDia + nValHot + nValEst + nValTax + nValAlu + nValCel + nValNet + nValFKM )
			aAdd(aImpres,{( cQAlias )->( VCO_DATVIS ),( cQAlias )->( VCN_CODVEN ),( cQAlias )->( A3_NOME ),( cQAlias )->( VCO_CODCLI ),( cQAlias )->( VCO_LOJCLI ),( cQAlias )->( A1_NOME ),( cQAlias )->( VCO_ORIGEM ),Transform(( cQAlias )->( VCO_KMINIC ),"@E 999,999,999"),Transform(( cQAlias )->( VCO_KMPERC ),"@E 999,999,999"),Transform(( cQAlias )->( VCO_KMACUM ),"@E 999,999,999"),( cQAlias )->( VCO_DESTIN ) , nValPed , nValRef , nValPKM , nValDia , nValHot , nValEst , nValTax , nValAlu , nValCel , nValNet , nValFKM , nTotal , cObserv })
	
			// Total por Data //
			ni := aScan(aTotDat,{|x| x[1] == space(7)+Transform(stod(( cQAlias )->( VCO_DATVIS )),"@D") })
			If ni <= 0
				aAdd(aTotDat,{ space(7)+Transform(stod(( cQAlias )->( VCO_DATVIS )),"@D") , 0 , " - "+FG_CDOW(stod(( cQAlias )->( VCO_DATVIS ))) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
				ni := len(aTotDat)
			EndIf
			aTotDat[01,02] += ( cQAlias )->( VCO_KMPERC )
			aTotDat[ni,02] += ( cQAlias )->( VCO_KMPERC )
			aTotDat[01,04] += nValPed
			aTotDat[ni,04] += nValPed
			aTotDat[01,05] += nValRef
			aTotDat[ni,05] += nValRef
			aTotDat[01,06] += nValPKM
			aTotDat[ni,06] += nValPKM
			aTotDat[01,07] += nValDia
			aTotDat[ni,07] += nValDia
			aTotDat[01,08] += nValHot
			aTotDat[ni,08] += nValHot
			aTotDat[01,09] += nValEst
			aTotDat[ni,09] += nValEst
			aTotDat[01,10] += nValTax
			aTotDat[ni,10] += nValTax
			aTotDat[01,11] += nValAlu
			aTotDat[ni,11] += nValAlu
			aTotDat[01,12] += nValCel
			aTotDat[ni,12] += nValCel
			aTotDat[01,13] += nValNet
			aTotDat[ni,13] += nValNet
			aTotDat[01,14] += nValFKM
			aTotDat[ni,14] += nValFKM
			aTotDat[01,15] += nTotal
			aTotDat[ni,15] += nTotal

			// Total por Vendedor //
			ni := aScan(aTotVen,{|x| x[1] == space(7)+( cQAlias )->( VCN_CODVEN ) })
			If ni <= 0
				aAdd(aTotVen,{ space(7)+( cQAlias )->( VCN_CODVEN ) , 0 , " - "+( cQAlias )->( A3_NOME ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
				ni := len(aTotVen)
			EndIf
			aTotVen[01,02] += ( cQAlias )->( VCO_KMPERC )
			aTotVen[ni,02] += ( cQAlias )->( VCO_KMPERC )
			aTotVen[01,04] += nValPed
			aTotVen[ni,04] += nValPed
			aTotVen[01,05] += nValRef
			aTotVen[ni,05] += nValRef
			aTotVen[01,06] += nValPKM
			aTotVen[ni,06] += nValPKM
			aTotVen[01,07] += nValDia
			aTotVen[ni,07] += nValDia
			aTotVen[01,08] += nValHot
			aTotVen[ni,08] += nValHot
			aTotVen[01,09] += nValEst
			aTotVen[ni,09] += nValEst
			aTotVen[01,10] += nValTax
			aTotVen[ni,10] += nValTax
			aTotVen[01,11] += nValAlu
			aTotVen[ni,11] += nValAlu
			aTotVen[01,12] += nValCel
			aTotVen[ni,12] += nValCel
			aTotVen[01,13] += nValNet
			aTotVen[ni,13] += nValNet
			aTotVen[01,14] += nValFKM
			aTotVen[ni,14] += nValFKM
			aTotVen[01,15] += nTotal
			aTotVen[ni,15] += nTotal
	
			// Total por Data + Vendedor //
			ni := aScan(aDatVen,{|x| x[1] == ( cQAlias )->( VCO_DATVIS )+( cQAlias )->( VCN_CODVEN ) })
			If ni <= 0
				aAdd(aDatVen,{ ( cQAlias )->( VCO_DATVIS )+( cQAlias )->( VCN_CODVEN ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
				ni := len(aDatVen)
			EndIf
			aDatVen[ni,02] += ( cQAlias )->( VCO_KMPERC )
			aDatVen[ni,03] += nValPed
			aDatVen[ni,04] += nValRef
			aDatVen[ni,05] += nValPKM
			aDatVen[ni,06] += nValDia
			aDatVen[ni,07] += nValHot
			aDatVen[ni,08] += nValEst
			aDatVen[ni,09] += nValTax
			aDatVen[ni,10] += nValAlu
			aDatVen[ni,11] += nValCel
			aDatVen[ni,12] += nValNet
			aDatVen[ni,13] += nValFKM
			aDatVen[ni,14] += nTotal
			
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
	
		/////////////////////////////////
		// MEDIA do valor do KM rodado //
		/////////////////////////////////
		For ni := 1 to len(aTotDat)
			aTotDat[ni,6] := ( ( aTotDat[ni,15] - ( aTotDat[ni,04] + aTotDat[ni,05] + aTotDat[ni,07] + aTotDat[ni,08] + aTotDat[ni,09] + aTotDat[ni,10] + aTotDat[ni,11] + aTotDat[ni,12] + aTotDat[ni,13] + aTotDat[ni,14] ) ) / aTotDat[ni,2] )
		Next
		For ni := 1 to len(aTotVen)
			aTotVen[ni,6] := ( ( aTotVen[ni,15] - ( aTotVen[ni,04] + aTotVen[ni,05] + aTotVen[ni,07] + aTotVen[ni,08] + aTotVen[ni,09] + aTotVen[ni,10] + aTotVen[ni,11] + aTotVen[ni,12] + aTotVen[ni,13] + aTotVen[ni,14] ) ) / aTotVen[ni,2] )
		Next
		For ni := 1 to len(aDatVen)
			aDatVen[ni,5] := ( ( aDatVen[ni,14] - ( aDatVen[ni,03] + aDatVen[ni,04] + aDatVen[ni,06] + aDatVen[ni,07] + aDatVen[ni,08] + aDatVen[ni,09] + aDatVen[ni,10] + aDatVen[ni,11] + aDatVen[ni,12] + aDatVen[ni,13] ) ) / aDatVen[ni,2] )
		Next
		/////////////////////////////////
	
		If Empty(aRet[3]) // Nao filtrou o vendedor
			If nLin >= 55
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
			EndIf
			@ nLin++, 59 PSAY right(space(11)+Alltrim(STR0064),11)+"  "+STR0072 // KM percor.   Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
			For ni := 1 to len(aTotDat)
				If nLin >= 55
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
				EndIf
				@ nLin++, 00 PSAY left(aTotDat[ni,1]+aTotDat[ni,3]+space(59),59)+Transform(aTotDat[ni,2],"@E 999,999,999")+Transform(aTotDat[ni,4],"@E 99999,999.99")+Transform(aTotDat[ni,5],"@E 99999,999.99")+Transform(aTotDat[ni,6],"@E 999999.99999")+Transform(aTotDat[ni,7],"@E 99999,999.99")+Transform(aTotDat[ni,8],"@E 99999,999.99")+Transform(aTotDat[ni,9],"@E 99999,999.99")+Transform(aTotDat[ni,10],"@E 99,999999.99")+Transform(aTotDat[ni,11],"@E 99999,999.99")+Transform(aTotDat[ni,12],"@E 99999,999.99")+Transform(aTotDat[ni,13],"@E 99999,999.99")+Transform(aTotDat[ni,14],"@E 99999,999.99")+Transform(aTotDat[ni,15],"@E 99,999,999.99")
			Next
			nLin++
			@ nLin++, 59 PSAY right(space(11)+Alltrim(STR0064),11)+"  "+STR0072 // KM percor.   Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
			For ni := 1 to len(aTotVen)
				If nLin >= 55
					nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
				EndIf
				@ nLin++, 00 PSAY left(aTotVen[ni,1]+aTotVen[ni,3]+space(59),59)+Transform(aTotVen[ni,2],"@E 999,999,999")+Transform(aTotVen[ni,4],"@E 99999,999.99")+Transform(aTotVen[ni,5],"@E 99999,999.99")+Transform(aTotVen[ni,6],"@E 999999.99999")+Transform(aTotVen[ni,7],"@E 99999,999.99")+Transform(aTotVen[ni,8],"@E 99999,999.99")+Transform(aTotVen[ni,9],"@E 99999,999.99")+Transform(aTotVen[ni,10],"@E 99999,999.99")+Transform(aTotVen[ni,11],"@E 99999,999.99")+Transform(aTotVen[ni,12],"@E 99999,999.99")+Transform(aTotVen[ni,13],"@E 99999,999.99")+Transform(aTotVen[ni,14],"@E 99999,999.99")+Transform(aTotVen[ni,15],"@E 99,999,999.99")
			Next
			nLin := 60
		ElseIf !Empty(aRet[3]) // Filtrou o vendedor
			If nLin >= 55
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
			EndIf
			@ nLin++, 72 PSAY STR0072 // Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
			@ nLin++, 00 PSAY left(STR0050+Transform(aTotVen[1,2],"@E 999,999,999")+space(70),70)+Transform(aTotVen[1,4],"@E 99999,999.99")+Transform(aTotVen[1,5],"@E 99999,999.99")+Transform(aTotVen[1,6],"@E 999999.99999")+Transform(aTotVen[1,7],"@E 99999,999.99")+Transform(aTotVen[1,8],"@E 99999,999.99")+Transform(aTotVen[1,9],"@E 99999,999.99")+Transform(aTotVen[1,10],"@E 99999,999.99")+Transform(aTotVen[1,11],"@E 99999,999.99")+Transform(aTotVen[1,12],"@E 99999,999.99")+Transform(aTotVen[1,13],"@E 99999,999.99")+Transform(aTotVen[1,14],"@E 99999,999.99")+Transform(aTotVen[1,15],"@E 99,999,999.99")
		EndIf
		For ni := 1 to len(aImpres)
			If nLin >= 55
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
			EndIf
			If cQuebra <> aImpres[ni,1]+aImpres[ni,2]
				cQuebra := aImpres[ni,1]+aImpres[ni,2]
				nj := aScan(aDatVen,{|x| x[1] == cQuebra })
				If nj > 0
					@ nLin++, 00 PSAY repl("_",limite)
					nLin++
					@ nLin++, 59 PSAY right(space(11)+Alltrim(STR0064),11)+"  "+STR0072 // KM percor.   Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
					@ nLin++, 00 PSAY left(Transform(stod(aImpres[ni,1]),"@D")+" - "+STR0025+": "+aImpres[ni,2]+" - "+aImpres[ni,3]+space(59),59)+Transform(aDatVen[nj,2],"@E 999,999,999")+;
										Transform(aDatVen[nj,03],"@E 99999,999.99")+Transform(aDatVen[nj,4],"@E 99999,999.99")+Transform(aDatVen[nj,05],"@E 999999.99999")+Transform(aDatVen[nj,06],"@E 99999,999.99")+Transform(aDatVen[nj,07],"@E 99999,999.99")+Transform(aDatVen[nj,08],"@E 99999,999.99")+Transform(aDatVen[nj,09],"@E 99999,999.99")+Transform(aDatVen[nj,10],"@E 99999,999.99")+Transform(aDatVen[nj,11],"@E 99999,999.99")+Transform(aDatVen[nj,12],"@E 99999,999.99")+Transform(aDatVen[nj,13],"@E 99999,999.99")+Transform(aDatVen[nj,14],"@E 99,999,999.99")
					nLin++
				EndIf			
			Else
				nLin++
			EndIf
			@ nLin++, 07 PSAY substr(STR0045,8) // Cliente                        Origem                         KM inicial KM percor. KM acumul. Destino                        
			@ nLin++, 07 PSAY left(aImpres[ni,4]+"-"+aImpres[ni,5]+" "+aImpres[ni,6],30)+" "+aImpres[ni,7]+aImpres[ni,8]+aImpres[ni,9]+aImpres[ni,10]+" "+aImpres[ni,11]
			If !Empty(aImpres[ni,24])
				@ nLin++, 07 PSAY STR0077+": "+aImpres[ni,24] // Obs.
			EndIf
			If MV_PAR01 == 2 // Sim
				FS_DADOSCLI(aImpres[ni,4],aImpres[ni,5],0)
				@ nLin++, 07 PSAY cCliEnd+" "+cCliBai+" "+left(cCliFon+space(22),22)+" "+cCliMun
			EndIf
			@ nLin++, 72 PSAY STR0072 // Vl.Pedágio Vl.Refeição Vlr.KM rod.  Vlr.Diária   Vlr.Hotel  Vlr.Estac.    Vlr.Taxi Vlr.Aluguel Vlr.Celular Vl.Internet Vl.Franq.KM    Vlr.TOTAL
			@ nLin++, 70 PSAY Transform(aImpres[ni,12],"@E 99999,999.99")+Transform(aImpres[ni,13],"@E 99999,999.99")+Transform(aImpres[ni,14],"@E 999999.99999")+Transform(aImpres[ni,15],"@E 99999,999.99")+Transform(aImpres[ni,16],"@E 99999,999.99")+Transform(aImpres[ni,17],"@E 99999,999.99")+Transform(aImpres[ni,18],"@E 99999,999.99")+Transform(aImpres[ni,19],"@E 99999,999.99")+Transform(aImpres[ni,20],"@E 99999,999.99")+Transform(aImpres[ni,21],"@E 99999,999.99")+Transform(aImpres[ni,22],"@E 99999,999.99")+Transform(aImpres[ni,23],"@E 99,999,999.99")
		Next
		nLin := 60
	Next
	cFilAnt := cBkpFilAnt
EndIf
DbSelectArea("VCN")
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return()  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Roteiro de Visitas                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{STR0010 ,"AxPesqui"	,0,1},; 		// Pesquisar
					{STR0006 ,"VCM660V"		,0,2},;  		// Visualizar
					{STR0007 ,"VCM660I"		,0,3},;   		// Incluir
					{STR0008 ,"VCM660A"		,0,4},;   		// Alterar
					{STR0009 ,"VCM660E"		,0,5},;   		// Excluir
					{STR0002 ,"VCM660LEG"	,0,4,2,.f.},;	// Legenda
					{STR0016 ,"VCM660FIN"	,0,4},;   		// Finalizar Roteiro
					{STR0017 ,"VCM660APR"	,0,4},;  		// Aprovar Roteiro
					{STR0044 ,"VCM660IMP(1)",0,4},;   		// Imprimir Roteiro
					{STR0051 ,"VCM660IMP(2)",0,4}}   		// Impr. Period/Vend
Return aRotina