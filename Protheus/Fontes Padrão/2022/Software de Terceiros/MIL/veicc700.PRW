// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 02     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICC700.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VEICC700³ Autor ³ Andre Luis Almeida       ³ Data ³ 03/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Consulta de Atendimentos por Data/Hora de Abertura          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC700(cPAREmp,aPAREmp,aPARFil)
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aFilAtu    := FWArrFilAtu()
Local nTam       := 0
Local nAlt       := 0
Private aSM0     := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private aVetEmp  := {}
Private aEmpr    := {} // Empresas Consolidadas
Private cEmpr    := "" // Nome da Empresa
Private lMarcar  := .f.
Private lDClik   := .f.
//
Private aDia     := {}
Private aHora    := {}
Private aStatus  := {}
Private aVended  := {}
Private dDatIni  := (dDataBase-Day(dDataBase)+1)
Private dDatFin  := (dDataBase)
Private aDiaTik  := {.f.,.t.,.t.,.t.,.t.,.t.,.f.}
Private aStaTik  := {.t.,.t.,.t.,.t.,.t.,.t.,.t.}
Private aTipTik  := {.t.,.t.,.t.}
Private aHorTik  := {.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.}
Private aTikTik  := {.f.,.t.,.t.,.t.,.t.,.t.,.t.}
Private cStatus  := ""
Private cHoras   := ""
Private cTipFat  := ""
Private cCodVen  := space(TamSX3("A3_COD")[1])
Private aFiltros := {dDatIni,dDatFin,aDiaTik,aStaTik,cCodVen,aTipTik,aHorTik,aTikTik}
//
Default cPAREmp  := ""
Default aPAREmp  := aEmpr
Default aPARFil  := aFiltros
//
aFiltros := aPARFil
FS_SLVFILT(2)
//
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0005+": " // Consolidado
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0004,STR0003) // Nao existem dados para esta Consulta ! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,2]==aFilAtu[SM0_FILIAL])
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+aFilAtu[SM0_FILIAL]+" )"
EndIf
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 150 , .T. , .F. } ) // Filtros
aAdd( aObjects, { 0 , 150 , .T. , .T. } ) // ListBox's
aPos := MsObjSize( aInfo, aObjects )
//
FS_FILTRAR(0)
//
DEFINE MSDIALOG oIntVCC700 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta de Atendimentos por Data/Hora de Abertura
oIntVCC700:lEscClose := .F.
//
nTam := ((aPos[1,4]-190)/7)
@ aPos[1,1],aPos[1,2] TO aPos[1,1]+025,aPos[1,4] LABEL STR0010 OF oIntVCC700 PIXEL // Período
@ aPos[1,1]+009,aPos[1,2]+010 MSGET oDatIni VAR dDatIni VALID( dDatIni <= dDataBase .and. FS_SLVFILT(1) ) SIZE 40,08 OF oIntVCC700 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+010,aPos[1,2]+056 SAY STR0011 SIZE 10,08 OF oIntVCC700 PIXEL COLOR CLR_BLUE // ate
@ aPos[1,1]+009,aPos[1,2]+070 MSGET oDatFin VAR dDatFin VALID( dDatIni <= dDatFin .and. FS_SLVFILT(1) ) SIZE 40,08 OF oIntVCC700 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+010,aPos[1,2]+(nTam*0)+135 CHECKBOX oDia1 VAR aDiaTik[1] PROMPT STR0012 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Dom
@ aPos[1,1]+010,aPos[1,2]+(nTam*1)+135 CHECKBOX oDia2 VAR aDiaTik[2] PROMPT STR0013 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Seg
@ aPos[1,1]+010,aPos[1,2]+(nTam*2)+135 CHECKBOX oDia3 VAR aDiaTik[3] PROMPT STR0014 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Ter
@ aPos[1,1]+010,aPos[1,2]+(nTam*3)+135 CHECKBOX oDia4 VAR aDiaTik[4] PROMPT STR0015 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Qua
@ aPos[1,1]+010,aPos[1,2]+(nTam*4)+135 CHECKBOX oDia5 VAR aDiaTik[5] PROMPT STR0016 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Qui
@ aPos[1,1]+010,aPos[1,2]+(nTam*5)+135 CHECKBOX oDia6 VAR aDiaTik[6] PROMPT STR0017 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Sex
@ aPos[1,1]+010,aPos[1,2]+(nTam*6)+135 CHECKBOX oDia7 VAR aDiaTik[7] PROMPT STR0018 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // Sab
@ aPos[1,1]+010,aPos[1,4]-040 CHECKBOX oDiaT VAR aTikTik[1] PROMPT STR0019 ON CLICK FS_TIK("Dia",1,7,aTikTik[1],"oDiaT") OF oIntVCC700 SIZE 45,10 PIXEL // Todos
//
nTam := ((aPos[1,4]-60)/7)
@ aPos[1,1]+028,aPos[1,2] TO aPos[1,1]+053,aPos[1,4] LABEL STR0020 OF oIntVCC700 PIXEL // Status atual do Atendimento
@ aPos[1,1]+038,aPos[1,2]+(nTam*0)+010 CHECKBOX oSta1 VAR aStaTik[1] PROMPT STR0021 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Em Aberto
@ aPos[1,1]+038,aPos[1,2]+(nTam*1)+010 CHECKBOX oSta2 VAR aStaTik[2] PROMPT STR0022 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Pend.Aprovacao
@ aPos[1,1]+038,aPos[1,2]+(nTam*2)+010 CHECKBOX oSta3 VAR aStaTik[3] PROMPT STR0023 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Pre-Aprovado
@ aPos[1,1]+038,aPos[1,2]+(nTam*3)+010 CHECKBOX oSta4 VAR aStaTik[4] PROMPT STR0024 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Aprovado
@ aPos[1,1]+038,aPos[1,2]+(nTam*4)+010 CHECKBOX oSta5 VAR aStaTik[5] PROMPT STR0025 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Reprovado
@ aPos[1,1]+038,aPos[1,2]+(nTam*5)+010 CHECKBOX oSta6 VAR aStaTik[6] PROMPT STR0026 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Finalizado
@ aPos[1,1]+038,aPos[1,2]+(nTam*6)+010 CHECKBOX oSta7 VAR aStaTik[7] PROMPT STR0027 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 65,10 PIXEL // Cancelado
@ aPos[1,1]+038,aPos[1,4]-040 CHECKBOX oStaT VAR aTikTik[2] PROMPT STR0019 ON CLICK FS_TIK("Sta",1,7,aTikTik[2],"oStaT") OF oIntVCC700 SIZE 45,10 PIXEL // Todos
//
@ aPos[1,1]+056,aPos[1,2] TO aPos[1,1]+081,aPos[1,2]+60 LABEL STR0028 OF oIntVCC700 PIXEL // Vendedor
@ aPos[1,1]+066,aPos[1,2]+010 MSGET oCodVen VAR cCodVen PICTURE "@!" F3 "SA3" VALID FS_SLVFILT(1) SIZE 40,08 OF oIntVCC700 PIXEL
//
nTam := ((aPos[1,4]-135)/3)
@ aPos[1,1]+056,aPos[1,2]+065 TO aPos[1,1]+081,aPos[1,4] LABEL STR0035 OF oIntVCC700 PIXEL // Tipo de Atendimento
@ aPos[1,1]+066,aPos[1,2]+(nTam*0)+075 CHECKBOX oTip1 VAR aTipTik[1] PROMPT STR0036 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 95,10 PIXEL // Atendimento de Novos
@ aPos[1,1]+066,aPos[1,2]+(nTam*1)+075 CHECKBOX oTip2 VAR aTipTik[2] PROMPT STR0037 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 95,10 PIXEL // Atendimento de Usados
@ aPos[1,1]+066,aPos[1,2]+(nTam*2)+075 CHECKBOX oTip3 VAR aTipTik[3] PROMPT STR0038 ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 95,10 PIXEL // Faturamento Direto
@ aPos[1,1]+066,aPos[1,4]-040 CHECKBOX oTipT VAR aTikTik[3] PROMPT STR0019 ON CLICK FS_TIK("Tip",1,3,aTikTik[3],"oTipT") OF oIntVCC700 SIZE 45,10 PIXEL // Todos
//
nTam := ((aPos[1,4]-55)/8)
@ aPos[1,1]+084,aPos[1,2] TO aPos[1,1]+137,aPos[1,4] LABEL STR0039 OF oIntVCC700 PIXEL // Horas a considerar
@ aPos[1,1]+095,aPos[1,2]+(nTam*0)+010 CHECKBOX oHor00 VAR aHorTik[01] PROMPT "00h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 00
@ aPos[1,1]+095,aPos[1,2]+(nTam*1)+010 CHECKBOX oHor01 VAR aHorTik[02] PROMPT "01h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 01
@ aPos[1,1]+095,aPos[1,2]+(nTam*2)+010 CHECKBOX oHor02 VAR aHorTik[03] PROMPT "02h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 02
@ aPos[1,1]+095,aPos[1,2]+(nTam*3)+010 CHECKBOX oHor03 VAR aHorTik[04] PROMPT "03h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 03
@ aPos[1,1]+095,aPos[1,2]+(nTam*4)+010 CHECKBOX oHor04 VAR aHorTik[05] PROMPT "04h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 04
@ aPos[1,1]+095,aPos[1,2]+(nTam*5)+010 CHECKBOX oHor05 VAR aHorTik[06] PROMPT "05h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 05
@ aPos[1,1]+095,aPos[1,2]+(nTam*6)+010 CHECKBOX oHor06 VAR aHorTik[07] PROMPT "06h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 06
@ aPos[1,1]+095,aPos[1,2]+(nTam*7)+010 CHECKBOX oHor07 VAR aHorTik[08] PROMPT "07h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 07
@ aPos[1,1]+095,aPos[1,4]-040 CHECKBOX oHorT1 VAR aTikTik[4] PROMPT STR0019 ON CLICK FS_TIK("Hor",1,8,aTikTik[4],"oHorT1") OF oIntVCC700 SIZE 45,10 PIXEL // Todos
//
@ aPos[1,1]+109,aPos[1,2]+(nTam*0)+010 CHECKBOX oHor08 VAR aHorTik[09] PROMPT "08h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 08
@ aPos[1,1]+109,aPos[1,2]+(nTam*1)+010 CHECKBOX oHor09 VAR aHorTik[10] PROMPT "09h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 09
@ aPos[1,1]+109,aPos[1,2]+(nTam*2)+010 CHECKBOX oHor10 VAR aHorTik[11] PROMPT "10h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 10
@ aPos[1,1]+109,aPos[1,2]+(nTam*3)+010 CHECKBOX oHor11 VAR aHorTik[12] PROMPT "11h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 11
@ aPos[1,1]+109,aPos[1,2]+(nTam*4)+010 CHECKBOX oHor12 VAR aHorTik[13] PROMPT "12h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 12
@ aPos[1,1]+109,aPos[1,2]+(nTam*5)+010 CHECKBOX oHor13 VAR aHorTik[14] PROMPT "13h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 13
@ aPos[1,1]+109,aPos[1,2]+(nTam*6)+010 CHECKBOX oHor14 VAR aHorTik[15] PROMPT "14h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 14
@ aPos[1,1]+109,aPos[1,2]+(nTam*7)+010 CHECKBOX oHor15 VAR aHorTik[16] PROMPT "15h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 15
@ aPos[1,1]+109,aPos[1,4]-040 CHECKBOX oHorT2 VAR aTikTik[5] PROMPT STR0019 ON CLICK FS_TIK("Hor",9,16,aTikTik[5],"oHorT2") OF oIntVCC700 SIZE 45,10 PIXEL // Todos
//
@ aPos[1,1]+123,aPos[1,2]+(nTam*0)+010 CHECKBOX oHor16 VAR aHorTik[17] PROMPT "16h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 16
@ aPos[1,1]+123,aPos[1,2]+(nTam*1)+010 CHECKBOX oHor17 VAR aHorTik[18] PROMPT "17h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 17
@ aPos[1,1]+123,aPos[1,2]+(nTam*2)+010 CHECKBOX oHor18 VAR aHorTik[19] PROMPT "18h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 18
@ aPos[1,1]+123,aPos[1,2]+(nTam*3)+010 CHECKBOX oHor19 VAR aHorTik[20] PROMPT "19h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 19
@ aPos[1,1]+123,aPos[1,2]+(nTam*4)+010 CHECKBOX oHor20 VAR aHorTik[21] PROMPT "20h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 20
@ aPos[1,1]+123,aPos[1,2]+(nTam*5)+010 CHECKBOX oHor21 VAR aHorTik[22] PROMPT "21h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 21
@ aPos[1,1]+123,aPos[1,2]+(nTam*6)+010 CHECKBOX oHor22 VAR aHorTik[23] PROMPT "22h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 22
@ aPos[1,1]+123,aPos[1,2]+(nTam*7)+010 CHECKBOX oHor23 VAR aHorTik[24] PROMPT "23h" ON CLICK FS_SLVFILT(1) OF oIntVCC700 SIZE 25,10 PIXEL // 23
@ aPos[1,1]+123,aPos[1,4]-040 CHECKBOX oHorT3 VAR aTikTik[6] PROMPT STR0019 ON CLICK FS_TIK("Hor",17,24,aTikTik[6],"oHorT3") OF oIntVCC700 SIZE 45,10 PIXEL // Todos
//
@ aPos[1,3]-010,aPos[1,4]-105 BUTTON oFiltrar PROMPT UPPER(STR0008) OF oIntVCC700 SIZE 50,10 PIXEL ACTION Processa( {|| FS_FILTRAR(1) } ) // Filtrar
@ aPos[1,3]-010,aPos[1,4]-050 BUTTON oEmpr    PROMPT UPPER(STR0002) OF oIntVCC700 SIZE 50,10 PIXEL ACTION (lDClik:=.t.,oIntVCC700:End()) // Filiais
@ aPos[1,3]-009,aPos[1,2]+005 CHECKBOX oZero VAR aTikTik[7] PROMPT STR0034 OF oIntVCC700 SIZE 80,10 PIXEL // Lista zerados
//
nTam := (aPos[2,4]/3)
//
@ aPos[2,1],aPos[2,2]+000 LISTBOX oLbDia FIELDS HEADER STR0029,STR0030,STR0032,"%" COLSIZES 40,18,25,20 SIZE nTam,aPos[2,3]-aPos[2,1] OF oIntVCC700 PIXEL ON CHANGE FS_LISTA(oLbDia:nAt,1) PIXEL // Data / Dia
oLbDia:SetArray(aDia)
oLbDia:bLine := { || { aDia[oLbDia:nAt,1] , aDia[oLbDia:nAt,2] , FG_AlinVlrs(Transform(aDia[oLbDia:nAt,3],"@E 9999,999")) , FG_AlinVlrs(Transform((aDia[oLbDia:nAt,3]/aDia[1,3])*100,"@E 999.9")+" %") }}
//
@ aPos[2,1],aPos[2,2]+nTam+004 LISTBOX oLbHora FIELDS HEADER STR0031,STR0032,"%" COLSIZES 18,25,20 SIZE nTam-037,aPos[2,3]-aPos[2,1] OF oIntVCC700 PIXEL // Hora
oLbHora:SetArray(aHora)
oLbHora:bLine := { || { aHora[oLbHora:nAt,1]+aHora[oLbHora:nAt,3] , FG_AlinVlrs(Transform(aHora[oLbHora:nAt,2],"@E 9999,999")) , FG_AlinVlrs(Transform((aHora[oLbHora:nAt,2]/aDia[oLbDia:nAt,3])*100,"@E 999.9")+" %") }}
//
If int((aPos[2,3]-aPos[2,1])/2) > 80
	nAlt := 80 // Tamanho maximo
Else
	nAlt := int((aPos[2,3]-aPos[2,1])/2) // Metade
EndIf
//
@ aPos[2,1],aPos[2,2]+nTam+nTam-030 LISTBOX oLbStatus FIELDS HEADER STR0033,STR0032,"%" COLSIZES 80,25,20 SIZE nTam+028,nAlt OF oIntVCC700 PIXEL // Status Atual
oLbStatus:SetArray(aStatus)
oLbStatus:bLine := { || { aStatus[oLbStatus:nAt,1] , FG_AlinVlrs(Transform(aStatus[oLbStatus:nAt,2],"@E 9999,999")) , FG_AlinVlrs(Transform((aStatus[oLbStatus:nAt,2]/aDia[oLbDia:nAt,3])*100,"@E 999.9")+" %") }}
//
@ aPos[2,1]+nAlt+4,aPos[2,2]+nTam+nTam-030 LISTBOX oLbVended FIELDS HEADER STR0028,STR0032,"%" COLSIZES 80,25,20 SIZE nTam+028,aPos[2,3]-aPos[2,1]-nAlt-5 OF oIntVCC700 PIXEL // Vendedor
oLbVended:SetArray(aVended)
oLbVended:bLine := { || { aVended[oLbVended:nAt,1]+" "+aVended[oLbVended:nAt,3] , FG_AlinVlrs(Transform(aVended[oLbVended:nAt,2],"@E 9999,999")) , FG_AlinVlrs(Transform((aVended[oLbVended:nAt,2]/aDia[oLbDia:nAt,3])*100,"@E 999.9")+" %") }}
//
ACTIVATE MSDIALOG oIntVCC700 ON INIT EnchoiceBar(oIntVCC700,{|| oIntVCC700:End() },{|| oIntVCC700:End() },,)
If lDClik
	VEICC700(cEmpr,aEmpr,aFiltros)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_SLVFILT³ Autor ³ Andre Luis Almeida     ³ Data ³ 04/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Salvar/Voltar Filtro                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SLVFILT(nTp)
If nTp == 1 // Salvar Filtro
	aFiltros := {dDatIni,dDatFin,aDiaTik,aStaTik,cCodVen,aTipTik,aHorTik,aTikTik}
Else // Voltar Filtro
	dDatIni := aFiltros[01] // Data Inicial
	dDatFin := aFiltros[02] // Data Final
	aDiaTik := aFiltros[03] // Dias da Semana ( CheckBox )
	aStaTik := aFiltros[04] // Status Atendimento ( CheckBox )
	cCodVen := aFiltros[05] // Cod.Vendedor
	aTipTik := aFiltros[06] // Tipo de Atendimento ( CheckBox )
	aHorTik := aFiltros[07] // Horas ( CheckBox )
	aTikTik := aFiltros[08] // Todos / Mostra Zerado ( CheckBox )
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TIK   ³ Autor ³ Andre Luis Almeida     ³ Data ³ 05/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik selecionar todos                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(cVet,nIni,nFin,lTik,cObj)
Local ni := 0
For ni := nIni to nFin
	&("a"+cVet+"Tik["+Alltrim(str(ni))+"]") := lTik
   Next
oFiltrar:SetFocus()
&(cObj+":SetFocus()")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida     ³ Data ³ 03/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Filtra Registros de Interesse                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp)
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local cQuery     := ""
Local cQAlias    := "SQLVV9VV0"
Local ni         := 0
Local nTot       := 0 
Local aAux       := {}
//
cStatus := ""
aStatus := {}
If aStaTik[1]
	cStatus += "'A',"
	aAdd(aStatus,{ STR0021 , 0 , "A" }) // Em Aberto
EndIf
If aStaTik[2]
	cStatus += "'P',"
	aAdd(aStatus,{ STR0022 , 0 , "P" }) // Pend.Aprovação
EndIf
If aStaTik[3]
	cStatus += "'O',"
	aAdd(aStatus,{ STR0023 , 0 , "O" }) // Pre-Aprovado
EndIf
If aStaTik[4]
	cStatus += "'L',"
	aAdd(aStatus,{ STR0024 , 0 , "L" }) // Aprovado
EndIf
If aStaTik[5]
	cStatus += "'R',"
	aAdd(aStatus,{ STR0025 , 0 , "R" }) //  Reprovado
EndIf
If aStaTik[6]
	cStatus += "'F',"
	aAdd(aStatus,{ STR0026 , 0 , "F" }) // Finalizado
EndIf
If aStaTik[7]
	cStatus += "'C',"
	aAdd(aStatus,{ STR0027 , 0 , "C" }) // Cancelado
EndIf
If !Empty(cStatus)
	cStatus := left(cStatus,len(cStatus)-1)
Else
	aAdd(aStatus,{"",0,""})
EndIf
//
cHoras := ""
For ni := 1 to 24
	cHoras += IIf(aHorTik[ni],"1","0") // Horas Tikadas
Next
//
cTipFat := ""
cTipFat += IIf(aTipTik[1],"'0',","")
cTipFat += IIf(aTipTik[2],"'1',","")
cTipFat += IIf(aTipTik[3],"'2',","")
cTipFat += "'X'"
//
aDia := {}
aAdd(aDia,{STR0040,"",0,""}) // Total Geral
nTot := ( ( dDatFin - dDatIni ) + 1 )
For ni := 1 to nTot
	dData := dDatIni+(ni-1)
	nData := DOW(dData)
	If &("!aDiaTik["+strzero(nData,1)+"]")
		Loop
	EndIf
	cDow  := ""
	Do Case
		Case nData == 1
			cDow := STR0012 // Dom
		Case nData == 2
			cDow := STR0013 // Seg
		Case nData == 3
			cDow := STR0014 // Ter
		Case nData == 4
			cDow := STR0015 // Qua
		Case nData == 5
			cDow := STR0016 // Qui
		Case nData == 6
			cDow := STR0017 // Sex
		Case nData == 7
			cDow := STR0018 // Sab
	EndCase
	aAdd(aDia,{ Transform(dData,"@D") , cDow , 0 , dtos(dData) })
	If ni == nTot
		Exit
	EndIf
Next
//
ProcRegua(len(aEmpr))
For nCont := 1 to Len(aEmpr)
	cFilAnt := aEmpr[nCont,1]
	IncProc(STR0009) // Levantando...
	cQuery := "SELECT VV9.VV9_DATVIS , VV9.VV9_HORVIS "
	cQuery += "FROM "+RetSqlName("VV9")+" VV9 "
	cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND "
	cQuery += "VV9.VV9_DATVIS>='"+dtos(dDatIni)+"' AND VV9.VV9_DATVIS<='"+dtos(dDatFin)+"' AND "
	If !Empty(cStatus)
		cQuery += "VV9.VV9_STATUS IN ("+cStatus+") AND "
	EndIf
	If !Empty(cCodVen)
		cQuery += "VV0.VV0_CODVEN='"+cCodVen+"' AND "
	EndIf
	cQuery += "VV0.VV0_TIPFAT IN ("+cTipFat+") AND "
	cQuery += "VV9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If substr(cHoras,val(left(strzero(( cQAlias )->( VV9_HORVIS ),4),2))+1,1) == "1" // Hora Tikada
			ni := aScan(aDia,{|x| x[4] == ( cQAlias )->( VV9_DATVIS ) })
			If ni > 0
				aDia[ni,3]++ // Data
			EndIf
			aDia[01,3]++ // Total Geral
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Next
cFilAnt := cBkpFilAnt
////////////////////////
// NAO Listar zerados //
////////////////////////
If !aTikTik[7]
	aAux := {}
	aAdd(aAux,aDia[1]) 
	For ni := 2 to len(aDia)
		If aDia[ni,3] > 0
			aAdd(aAux,aDia[ni]) 
		EndIf
	Next
	aDia := aClone(aAux)
EndIf
//
If nTp > 0
	oLbDia:nAt := 1
	oLbDia:SetArray(aDia)
	oLbDia:bLine := { || { aDia[oLbDia:nAt,1] , aDia[oLbDia:nAt,2] , FG_AlinVlrs(Transform(aDia[oLbDia:nAt,3],"@E 9999,999")) , FG_AlinVlrs(Transform((aDia[oLbDia:nAt,3]/aDia[1,3])*100,"@E 999.9")+" %") }}
	oLbDia:Refresh()
EndIf
FS_LISTA(1,nTp)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LISTA ³ Autor ³  Andre Luis Almeida   ³ Data ³ 04/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LISTA(nLinha,nTp)
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local cQuery     := ""
Local cQAlias    := "SQLVV9VV0"
Local ni         := 0
Local aAux       := {}
//
aHora := {}
For ni := 1 to 24
	If substr(cHoras,ni,1) == "1" // Hora Tikada
		aAdd(aHora,{ strzero(ni-1,2) , 0  , "h" })
	EndIf
Next
//
For ni := 1 to len(aStatus)
	aStatus[ni,2] := 0
Next
//
aVended := {}
//
For nCont := 1 to Len(aEmpr)
	cFilAnt := aEmpr[nCont,1]
	cQuery := "SELECT VV9.VV9_HORVIS , VV9.VV9_STATUS , VV0.VV0_CODVEN "
	cQuery += "FROM "+RetSqlName("VV9")+" VV9 "
	cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND "
	If !Empty(aDia[nLinha,4])
		cQuery += "VV9.VV9_DATVIS='"+aDia[nLinha,4]+"' AND "
	Else
		cQuery += "VV9.VV9_DATVIS>='"+dtos(dDatIni)+"' AND VV9.VV9_DATVIS<='"+dtos(dDatFin)+"' AND "
	EndIf
	If !Empty(cStatus)
		cQuery += "VV9.VV9_STATUS IN ("+cStatus+") AND "
	EndIf
	If !Empty(cCodVen)
		cQuery += "VV0.VV0_CODVEN='"+cCodVen+"' AND "
	EndIf
	cQuery += "VV0.VV0_TIPFAT IN ("+cTipFat+") AND "
	cQuery += "VV9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If substr(cHoras,val(left(strzero(( cQAlias )->( VV9_HORVIS ),4),2))+1,1) == "1" // Hora Tikada
			ni := aScan(aHora,{|x| x[1] == left(strzero(( cQAlias )->( VV9_HORVIS ),4),2) })
			If ni > 0
				aHora[ni,2]++ // Hora
			EndIf
			ni := aScan(aStatus,{|x| x[3] == ( cQAlias )->( VV9_STATUS ) })
			If ni > 0
				aStatus[ni,2]++ // Status
			EndIf
			ni := aScan(aVended,{|x| x[1] == ( cQAlias )->( VV0_CODVEN ) })
			If ni == 0
				aAdd(aVended,{( cQAlias )->( VV0_CODVEN ),1,left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlias )->( VV0_CODVEN )+"' AND D_E_L_E_T_=' '"),17)})
			Else
				aVended[ni,2]++ // Vendedor
			EndIf
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Next
cFilAnt := cBkpFilAnt
////////////////////////
// NAO Listar zerados //
////////////////////////
If !aTikTik[7]
	aAux := {}
	For ni := 1 to len(aHora)
		If aHora[ni,2] > 0
			aAdd(aAux,aHora[ni]) 
		EndIf
	Next
	aHora := aClone(aAux)
	aAux := {}
	For ni := 1 to len(aStatus)
		If aStatus[ni,2] > 0
			aAdd(aAux,aStatus[ni]) 
		EndIf
	Next
	aStatus := aClone(aAux)
EndIf
//
If len(aHora) <= 0
	aAdd(aHora,{"",0,""})
EndIf
If len(aStatus) <= 0
	aAdd(aStatus,{"",0,""})
EndIf
If len(aVended) <= 0
	aAdd(aVended,{"",0,""})
EndIf
//
If nTp > 0
	oLbHora:nAt := 1
	oLbHora:SetArray(aHora)
	oLbHora:bLine := { || { aHora[oLbHora:nAt,1]+aHora[oLbHora:nAt,3] , FG_AlinVlrs(Transform(aHora[oLbHora:nAt,2],"@E 9999,999")) , FG_AlinVlrs(Transform((aHora[oLbHora:nAt,2]/aDia[oLbDia:nAt,3])*100,"@E 999.9")+" %") }}
	oLbHora:Refresh()
	//
	oLbStatus:nAt := 1
	oLbStatus:SetArray(aStatus)
	oLbStatus:bLine := { || { aStatus[oLbStatus:nAt,1] , FG_AlinVlrs(Transform(aStatus[oLbStatus:nAt,2],"@E 9999,999")) , FG_AlinVlrs(Transform((aStatus[oLbStatus:nAt,2]/aDia[oLbDia:nAt,3])*100,"@E 999.9")+" %") }}
	oLbStatus:Refresh()
	//
	oLbVended:nAt := 1
	oLbVended:SetArray(aVended)
	oLbVended:bLine := { || { aVended[oLbVended:nAt,1]+" "+aVended[oLbVended:nAt,3] , FG_AlinVlrs(Transform(aVended[oLbVended:nAt,2],"@E 9999,999")) , FG_AlinVlrs(Transform((aVended[oLbVended:nAt,2]/aDia[oLbDia:nAt,3])*100,"@E 999.9")+" %") }}
	oLbVended:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 03/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux    := {}
Local ni         := {}
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local aFilAtu    := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0002 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0006,STR0007 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIKFIL(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TIKFIL³ Autor ³ Andre Luis Almeida     ³ Data ³ 05/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik Filiais                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKFIL(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return()