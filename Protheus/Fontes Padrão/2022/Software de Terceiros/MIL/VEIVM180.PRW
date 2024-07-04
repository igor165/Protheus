#Include "PROTHEUS.CH"
#Include "VEIVM180.CH"

Static cDMSPrefOri  := GetNewPar("MV_PREFVEI","VEI")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIVM180 º Autor ³ Andre Luis Almeida º Data ³  06/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Comissoes / Incentivos - Faturamento Direto                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Faturamento Direto                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM180(nRecVV9,lTela,lGrvAuto)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nTam      := 0
Local nTotSel   := 0
Local nCntFor   := 0
//
Private aIncent := {{.f.,"oNada","","","","",0,0,0,0,0,"","","",0,ctod(""),"","","","","","","",""}}
Private cOrdLb  := "00C"
Private cFilAte := space(TamSX3("VV9_FILIAL")[1])
Private cNumAte := space(TamSX3("VV9_NUMATE")[1])
Private dDatIni := ctod("")
Private dDatFin := dDataBase
Private cChassi := space(TamSX3("VV1_CHASSI")[1])
Private cCodPed := space(TamSX3("VQ0_CODIGO")[1])
Private cNumPed := space(TamSX3("VQ0_NUMPED")[1])
//
Private cNivImp := ""
Private aTipInc := {}
//
Private oNada   := LoadBitmap( GetResources() , "NADA" )		// Nenhuma figura
Private oLBNO   := LoadBitmap( GetResources() , "LBNO" )		// Sem TIK
Private oLBTIK  := LoadBitmap( GetResources() , "LBTIK" )		// Com TIK
//
Private oS0     := LoadBitmap( GetResources() , "BR_BRANCO" )	// 0=Levantamento
Private oS1     := LoadBitmap( GetResources() , "BR_AMARELO" )	// 1=Gravado
Private oS2     := LoadBitmap( GetResources() , "BR_VERDE" )	// 2=A faturar
Private oS3     := LoadBitmap( GetResources() , "BR_AZUL" )		// 3=NF/Titulos gerados
Private oS4     := LoadBitmap( GetResources() , "BR_VERMELHO" )	// 4=Cancelado
//
Default nRecVV9 := 0
Default lTela   := .t. // Mostra Tela
Default lGrvAuto:= .f. // Grava levantamento automaticamente
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 65, .T. , .F. } ) // Filtro / % default
AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox Incentivos         
AAdd( aObjects, { 0, 10, .T. , .F. } ) // Legenda
aPos := MsObjSize( aInfo, aObjects )
//
FS_VM180X1(.f.)
//
If nRecVV9 > 0
	VV9->(DbGoTo(nRecVV9))
	cFilAte := VV9->VV9_FILIAL
	cNumAte := VV9->VV9_NUMATE
	FS_LEVANTA(0)
EndIf
//
If lTela // Mostra Tela
	//
	DEFINE MSDIALOG oVEIVM180 TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Comissões / Incentivos - Faturamento Direto
		oVEIVM180:lEscClose := .F.
		@ aPos[1,1]+002,aPos[1,2] LISTBOX oLbTipInc FIELDS HEADER STR0003,"%",STR0008,STR0009 ;
					COLSIZES 80,50,50,50 SIZE aPos[1,4]-255,aPos[1,3]-aPos[1,1] OF oVEIVM180 PIXEL ON DBLCLICK FS_TIPINC(oLbTipInc:nAt)
		oLbTipInc:SetArray(aTipInc)
		oLbTipInc:bLine := { || {	aTipInc[oLbTipInc:nAt,2] ,;
									FG_AlinVlrs(Transform(aTipInc[oLbTipInc:nAt,3],"@E 999.99 %")),;
									IIf(aTipInc[oLbTipInc:nAt,4],STR0059,""),;
									IIf(aTipInc[oLbTipInc:nAt,5],STR0059,"")}}
		
		@ aPos[1,1],aPos[1,4]-247 TO aPos[1,3]+002,aPos[1,4]-085 LABEL STR0002 OF oVEIVM180 PIXEL // Filtro

		@ aPos[1,1]+009,aPos[1,4]-239 SAY (STR0032+":") SIZE 55,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Filial
		@ aPos[1,1]+016,aPos[1,4]-239 MSGET oFilAte VAR cFilAte PICTURE "@!" F3 "SM0_01" SIZE 50,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK
		@ aPos[1,1]+009,aPos[1,4]-186 SAY (STR0033+":") SIZE 55,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Atendimento
		@ aPos[1,1]+016,aPos[1,4]-186 MSGET oNumAte VAR cNumAte PICTURE "@!" F3 "VV0ATE" SIZE 46,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK
		@ aPos[1,1]+009,aPos[1,4]-136 SAY (AllTrim(RetTitle("VVA_CODPED"))+":") SIZE 55,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Cód.Pedido
		@ aPos[1,1]+016,aPos[1,4]-136 MSGET oCodPed VAR cCodPed PICTURE "@!" F3 "VQ0" VALID VM1800011_COD_PEDIDO(cCodPed) SIZE 46,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK

		@ aPos[1,1]+028,aPos[1,4]-239 SAY (STR0004+":") SIZE 55,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Data Atendimento 
		@ aPos[1,1]+035,aPos[1,4]-239 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 44,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK
		@ aPos[1,1]+035,aPos[1,4]-192 SAY STR0005 SIZE 10,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+035,aPos[1,4]-184 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 44,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK
		@ aPos[1,1]+028,aPos[1,4]-136 SAY (AllTrim(RetTitle("VQ0_NUMPED"))+":") SIZE 55,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Nro.Pedido
		@ aPos[1,1]+035,aPos[1,4]-136 MSGET oNumPed VAR cNumPed PICTURE "@!" SIZE 46,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK WHEN .f.

		@ aPos[1,1]+047,aPos[1,4]-239 SAY (AllTrim(RetTitle("VQ0_CHASSI"))+":") SIZE 60,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Chassi
		@ aPos[1,1]+054,aPos[1,4]-239 MSGET oChassi VAR cChassi F3 "VV1" PICTURE "@!" SIZE 90,08 OF oVEIVM180 PIXEL HASBUTTON COLOR CLR_BLACK WHEN Empty(cCodPed)
		@ aPos[1,1]+054,aPos[1,4]-136 BUTTON oFiltro PROMPT STR0006 OF oVEIVM180 SIZE 46,09 PIXEL ACTION FS_LEVANTA(1) // Filtrar

		@ aPos[2,1]+002,aPos[2,2]+000 LISTBOX oLbIncent FIELDS HEADER "","",STR0032,STR0033,STR0086,STR0037,STR0038,STR0022,STR0028,"% "+STR0007,STR0029,"%",STR0027,STR0035,STR0036,STR0072,STR0044 ;
					COLSIZES 10,10,40,36,40,60,70,110,47,33,47,33,47,38,45,35,30 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oVEIVM180 PIXEL ON DBLCLICK (FS_DBLCLICK(oLbIncent:nAt,oLbIncent:nColPos,@nTotSel),oTotSel:Refresh())
		oLbIncent:SetArray(aIncent)
		oLbIncent:bLine := { || {	IIf(aIncent[oLbIncent:nAt,01],oLBTIK,oLBNO) , &(aIncent[oLbIncent:nAt,02]) ,;
									aIncent[oLbIncent:nAt,03] , aIncent[oLbIncent:nAt,04] , aIncent[oLbIncent:nAt,24],;
									aIncent[oLbIncent:nAt,18] , aIncent[oLbIncent:nAt,19]+" "+aIncent[oLbIncent:nAt,20] ,;
									aIncent[oLbIncent:nAt,05]+"-"+aIncent[oLbIncent:nAt,06]+" "+aIncent[oLbIncent:nAt,17] ,;
									FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,07],"@E 999,999,999.99")),;
									FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,08],"@E 999.99 %")),;
									FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,09],"@E 999,999,999.99")),;
									FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,10],"@E 999.99 %")),;
									FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,11],"@E 999,999,999.99")),;
									substr(aIncent[oLbIncent:nAt,12],2),;
									aIncent[oLbIncent:nAt,13]+"-"+aIncent[oLbIncent:nAt,14],;
									aIncent[oLbIncent:nAt,23],;
									aIncent[oLbIncent:nAt,21]}}
		oLbIncent:bHeaderClick := {|oObj,nCol| FS_ORDLB(nCol,1) , }

		@ aPos[1,1]+004,aPos[1,4]-080 BUTTON oSair PROMPT STR0011 OF oVEIVM180 SIZE 80,09 PIXEL ACTION oVEIVM180:End() // SAIR
		@ aPos[1,1]+017,aPos[1,4]-080 BUTTON oGrav PROMPT STR0012 OF oVEIVM180 SIZE 80,09 PIXEL ACTION FS_GRAVAR(1,0,"")             // Gravar Levantamento
		@ aPos[1,1]+030,aPos[1,4]-080 BUTTON oLibe PROMPT STR0013 OF oVEIVM180 SIZE 80,09 PIXEL ACTION FS_GRAVAR(2,0,"")             // Libera p/ Gerar NF/Titulos
		@ aPos[1,1]+043,aPos[1,4]-080 BUTTON oGera PROMPT STR0015 OF oVEIVM180 SIZE 80,09 PIXEL ACTION FS_GRAVAR(3,0,"")             // Gerar NF/Titulos
		@ aPos[1,1]+057,aPos[1,4]-080 BUTTON oCanc PROMPT STR0014 OF oVEIVM180 SIZE 80,09 PIXEL ACTION FS_GRAVAR(4,oLbIncent:nAt,"") // Cancelar

		nTam := (aPos[3,4]/6)
		@ aPos[3,1]+001,aPos[3,2]+(nTam*0)+004 BITMAP oxBrac RESOURCE "BR_BRANCO"   OF oVEIVM180 NOBORDER SIZE 10,10 PIXEL
		@ aPos[3,1]+001,aPos[3,2]+(nTam*0)+013 SAY STR0039 SIZE 100,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Levantamento
		@ aPos[3,1]+001,aPos[3,2]+(nTam*1)+004 BITMAP oxAmar RESOURCE "BR_AMARELO"  OF oVEIVM180 NOBORDER SIZE 10,10 PIXEL
		@ aPos[3,1]+001,aPos[3,2]+(nTam*1)+013 SAY STR0040 SIZE 100,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Gravados
		@ aPos[3,1]+001,aPos[3,2]+(nTam*2)+004 BITMAP oxVerd RESOURCE "BR_VERDE"    OF oVEIVM180 NOBORDER SIZE 10,10 PIXEL
		@ aPos[3,1]+001,aPos[3,2]+(nTam*2)+013 SAY STR0041 SIZE 100,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Liberados para faturar
		@ aPos[3,1]+001,aPos[3,2]+(nTam*3)+004 BITMAP oxAzul RESOURCE "BR_AZUL"     OF oVEIVM180 NOBORDER SIZE 10,10 PIXEL
		@ aPos[3,1]+001,aPos[3,2]+(nTam*3)+013 SAY STR0042 SIZE 100,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // NF/Titulos gerados
		@ aPos[3,1]+001,aPos[3,2]+(nTam*4)+004 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oVEIVM180 NOBORDER SIZE 10,10 PIXEL
		@ aPos[3,1]+001,aPos[3,2]+(nTam*4)+013 SAY STR0043 SIZE 100,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Cancelado
		@ aPos[3,1]+001,aPos[3,2]+(nTam*5)+000 SAY STR0068 SIZE 100,8 OF oVEIVM180 PIXEL COLOR CLR_BLUE // Valor Total
		@ aPos[3,1]+000,aPos[3,2]+(nTam*5)+030 MSGET oTotSel VAR nTotSel PICTURE "@E 999,999,999.99" SIZE (nTam-30),08 OF oVEIVM180 PIXEL HASBUTTON WHEN .f.

	ACTIVATE MSDIALOG oVEIVM180

EndIf

If lGrvAuto .and. aIncent[1,2] <> "oNada" // Grava Automaticamente? Precisa possuir os incentivos levantados no vetor "aIncent"
	For nCntFor := 1 to len(aIncent)
		If right(aIncent[nCntFor,2],1) == "0" // Registro referente ao Levantamento
			aIncent[nCntFor,1] := .t. // Marcar registro para Gravar o Levantamento
		EndIf
	Next
	FS_GRAVAR(1,0,"",.f.) // Grava Levantamento automaticamente - não perguntar para o usuario se deseja gravar
EndIf

SetKey(VK_F12, Nil )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VM180X1³ Autor ³ Andre Luis Almeida     ³ Data ³ 01/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Pergunte com os parametros da Rotina ( F12 )                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VM180X1(lMostra)
Local cAux    := ""
Local nAux1   := 0
Local nAux2   := 0
Local ni      := 0
Local cPerg   := "VVM180"

Local cNamVQ2 := RetSQLName("VQ2")
Local cFilVQ2 := xFilial("VQ2")

SetKey(VK_F12, Nil )

//If !lMostra
	////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	////³ Pergunte para Configuracao da Rotina ³
	////ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//AADD(aRegs,{STR0010                  ,STR0010                   ,STR0010                   ,"MV_CH1","C",VCF->(TamSx3("VCF_NIVIMP")[1]),0,0,"G",'',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0056,STR0057},{STR0056,STR0057},{STR0056,STR0057}})
	////
	//AADD(aRegs,{STR0007+" "+STR0008      ,STR0007+" "+STR0008      ,STR0007+" "+STR0008       ,"MV_CH2","N",1 ,0,1,"C",'',"MV_PAR02",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	//AADD(aRegs,{STR0007+" "+STR0009      ,STR0007+" "+STR0009      ,STR0007+" "+STR0009       ,"MV_CH3","N",1 ,0,1,"C",'',"MV_PAR03",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	////
	//AADD(aRegs,{"1º."+STR0052            ,"1º."+STR0052            ,"1º."+STR0052             ,"MV_CH4","C",25,0,0,"G",'',"MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0058+" 1"},{STR0058+" 1"},{STR0058+" 1"}})
	//AADD(aRegs,{"1º."+STR0084+" "+STR0008,"1º."+STR0084+" "+STR0008,"1º."+STR0084+" "+STR0008,"MV_CH5","N",1 ,0,2,"C",'',"MV_PAR05",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	//AADD(aRegs,{"1º."+STR0084+" "+STR0009,"1º."+STR0084+" "+STR0009,"1º."+STR0084+" "+STR0009,"MV_CH6","N",1 ,0,2,"C",'',"MV_PAR06",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	////
	//AADD(aRegs,{"2º."+STR0052            ,"2º."+STR0052            ,"2º."+STR0052             ,"MV_CH7","C",25,0,0,"G",'',"MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0058+" 2"},{STR0058+" 2"},{STR0058+" 2"}})
	//AADD(aRegs,{"2º."+STR0084+" "+STR0008,"2º."+STR0084+" "+STR0008,"2º."+STR0084+" "+STR0008,"MV_CH8","N",1 ,0,2,"C",'',"MV_PAR08",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	//AADD(aRegs,{"2º."+STR0084+" "+STR0009,"2º."+STR0084+" "+STR0009,"2º."+STR0084+" "+STR0009,"MV_CH9","N",1 ,0,2,"C",'',"MV_PAR09",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	////
	//AADD(aRegs,{"3º."+STR0052            ,"3º."+STR0052            ,"3º."+STR0052             ,"MV_CHA","C",25,0,0,"G",'',"MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0058+" 3"},{STR0058+" 3"},{STR0058+" 3"}})
	//AADD(aRegs,{"3º."+STR0084+" "+STR0008,"3º."+STR0084+" "+STR0008,"3º."+STR0084+" "+STR0008,"MV_CHB","N",1 ,0,2,"C",'',"MV_PAR11",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	//AADD(aRegs,{"3º."+STR0084+" "+STR0009,"3º."+STR0084+" "+STR0009,"3º."+STR0084+" "+STR0009,"MV_CHC","N",1 ,0,2,"C",'',"MV_PAR12",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	////
	//AADD(aRegs,{"4º."+STR0052            ,"4º."+STR0052            ,"4º."+STR0052             ,"MV_CHD","C",25,0,0,"G",'',"MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0058+" 4"},{STR0058+" 4"},{STR0058+" 4"}})
	//AADD(aRegs,{"4º."+STR0084+" "+STR0008,"4º."+STR0084+" "+STR0008,"4º."+STR0084+" "+STR0008,"MV_CHE","N",1 ,0,2,"C",'',"MV_PAR14",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	//AADD(aRegs,{"4º."+STR0084+" "+STR0009,"4º."+STR0084+" "+STR0009,"4º."+STR0084+" "+STR0009,"MV_CHF","N",1 ,0,2,"C",'',"MV_PAR15",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	////
	//AADD(aRegs,{"5º."+STR0052            ,"5º."+STR0052            ,"5º."+STR0052             ,"MV_CHG","C",25,0,0,"G",'',"MV_PAR16","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0058+" 5"},{STR0058+" 5"},{STR0058+" 5"}})
	//AADD(aRegs,{"5º."+STR0084+" "+STR0008,"5º."+STR0084+" "+STR0008,"5º."+STR0084+" "+STR0008,"MV_CHH","N",1 ,0,2,"C",'',"MV_PAR17",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	//AADD(aRegs,{"5º."+STR0084+" "+STR0009,"5º."+STR0084+" "+STR0009,"5º."+STR0084+" "+STR0009,"MV_CHI","N",1 ,0,2,"C",'',"MV_PAR18",STR0059,STR0059,STR0059,"","",STR0083,STR0083,STR0083,'','','','','','','','','','','','','','','','','','S','','','',''})
	////
	//
//EndIf
//
Pergunte(cPerg,lMostra,,,,.f.)
//
cNivImp := MV_PAR01
aTipInc := {}
aAdd(aTipInc,{"0",STR0007,0,IIf(MV_PAR02==1,.t.,.f.),IIf(MV_PAR03==1,.t.,.f.)}) // Desconto
For ni := 4 to 18 step 3
	cAux := &("MV_PAR"+strzero(ni+0,2))
	If !Empty(cAux)
		nAux1 := &("MV_PAR"+strzero(ni+1,2))
		nAux2 := &("MV_PAR"+strzero(ni+2,2))
		aAdd(aTipInc,{strzero(len(aTipInc),1),cAux,0,IIf(nAux1==1,.t.,.f.),IIf(nAux2==1,.t.,.f.)})
	EndIf
Next
//
aTipInc[1,3] := FM_SQL("SELECT VQ2.VQ2_PERDES FROM "+cNamVQ2+" VQ2 WHERE VQ2.VQ2_FILIAL='"+cFilVQ2+"' AND VQ2.D_E_L_E_T_=' ' ORDER BY VQ2.VQ2_CODIGO DESC")
For ni := 2 to len(aTipInc)
	aTipInc[ni,3] := FM_SQL("SELECT VQ2.VQ2_PERINC FROM "+cNamVQ2+" VQ2 WHERE VQ2.VQ2_FILIAL='"+cFilVQ2+"' AND VQ2.VQ2_TIPINC='"+aTipInc[ni,1]+"' AND VQ2.D_E_L_E_T_=' ' ORDER BY VQ2.VQ2_CODIGO DESC")
Next
//
If lMostra
	oLbTipInc:nAt := 1
	oLbTipInc:SetArray(aTipInc)
	oLbTipInc:bLine := { || {	aTipInc[oLbTipInc:nAt,2] ,;
								FG_AlinVlrs(Transform(aTipInc[oLbTipInc:nAt,3],"@E 999.99 %")),;
								IIf(aTipInc[oLbTipInc:nAt,4],STR0059,""),;
								IIf(aTipInc[oLbTipInc:nAt,5],STR0059,"")}}
	oLbTipInc:Refresh()
EndIf
SetKey(VK_F12,{ || FS_VM180X1(.t.) })
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_LEVANTA³ Autor ³ Andre Luis Almeida     ³ Data ³ 06/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levanta registros ( 0 - Inicial / 1 - Atendimentos/VQ2      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(nTp)
Local cFilVQ2  := ""
Local cFilSE1  := ""
Local cFilSA1  := ""
Local cFilVCF  := ""
Local cFilVV0  := ""
Local cFilAux  := ""
Local cNamVQ2  := RetSQLName("VQ2")
Local cNamSE1  := RetSQLName("SE1")
Local cNamSA1  := RetSqlName("SA1")
Local cNamVV0  := RetSqlName("VV0")
Local cNamVV9  := RetSqlName("VV9")
Local cNamVVA  := RetSqlName("VVA")
Local cNamVQ0  := RetSqlName("VQ0")
Local cQuery   := ""
Local cQAlSQL  := "ALIASSQL"
Local ni       := 0
Local nPDes    := 0
Local nPni     := 0
Local cTitPag  := ""
Local cTipInc  := ""
Local nTipInc  := 0
Local nSE1Sal  := 0
Local nSE1Tot  := 0
Local nVlrBase := 0
Local cBkpFilAnt := cFilAnt
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont      := 0
Local lVQ0_BASCFD:= VQ0->(FieldPos('VQ0_BASCFD')) > 0
//
aIncent := {}
//
For nCont := 1 to Len(aSM0)
	//
	cFilAnt := aSM0[nCont]
	//
	cFilVQ2 := xFilial("VQ2")
	cFilSE1 := xFilial("SE1")
	cFilSA1 := xFilial("SA1")
	cFilVCF := xFilial("VCF")
	cFilVV0 := xFilial("VV0")
	cFilVQ0 := xFilial("VQ0")
	//
	cQuery := "SELECT VQ2.VQ2_STATUS , VQ2.VQ2_FILATE , VQ2.VQ2_NUMATE , VQ2.VQ2_CODCLI , VQ2.VQ2_LOJCLI , "
	cQuery += "VQ2.VQ2_VLRINI , VQ2.VQ2_PERDES , VQ2.VQ2_VLRBAS , VQ2.VQ2_PERINC , VQ2.VQ2_VLRINC , "
	cQuery += "VQ2.VQ2_TIPINC , VQ2.VQ2_NUMNFI , VQ2.VQ2_SERNFI , VQ2."+ FGX_MILSNF('VQ2', 3, 'VQ2_SERNFI') +" , VQ2.VQ2_CHASSI , VQ2.VQ2_CODMAR , "
	cQuery += "VQ2.VQ2_MODVEI , VQ2.VQ2_OBSNFC , VQ2.VQ2_NUMTIT , VQ2.R_E_C_N_O_ AS RECVQ2 , SA1.A1_NOME , VQ0.VQ0_NUMPED "
	cQuery += "FROM "+cNamVQ2+" VQ2 "
	cQuery += "LEFT JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=VQ2.VQ2_CODCLI AND SA1.A1_LOJA=VQ2.VQ2_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+cNamVQ0+" VQ0 ON ( VQ0.VQ0_FILIAL='"+cFilVQ0+"' AND VQ0.VQ0_CHASSI=VQ2.VQ2_CHASSI AND VQ0.VQ0_CHASSI <> ' ' AND VQ0.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VQ2.VQ2_FILIAL='"+cFilVQ2+"' AND "
	cQuery += "VQ2.VQ2_DATATE>='"+dtos(dDatIni)+"' AND VQ2.VQ2_DATATE<='"+dtos(dDatFin)+"' AND "
	If !Empty(cFilAte)
		cQuery += "VQ2.VQ2_FILATE='"+cFilAte+"' AND "
	EndIf
	If !Empty(cNumAte)
		cQuery += "VQ2.VQ2_NUMATE='"+cNumAte+"' AND "
	EndIf
	If !Empty(cChassi)
		cQuery += "VQ2.VQ2_CHASSI = '" + Alltrim(cChassi) + "' AND "
	EndIf
	If !Empty(cCodPed)
		cQuery += "VQ0.VQ0_CODIGO = '"+cCodPed+"' AND "
	EndIf
	cQuery += "VQ2.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		cTitPag := ""
		If !Empty(( cQAlSQL )->( VQ2_NUMTIT )) .and. ( cQAlSQL )->( VQ2_STATUS ) <> "4"
			cFilAux := ( cQAlSQL )->( VQ2_FILATE )
			If FM_SQL("SELECT R_E_C_N_O_ FROM "+cNamSE1+" WHERE E1_FILIAL='"+cFilAux+"' AND E1_NUM='"+( cQAlSQL )->( VQ2_NUMTIT )+"' AND E1_PREFORI='"+cDMSPrefOri+"' AND D_E_L_E_T_=' '") <= 0
				cFilAux := cFilSE1
			EndIf
			nSE1Sal := FM_SQL("SELECT SUM(E1_SALDO) FROM "+cNamSE1+" WHERE E1_FILIAL='"+cFilAux+"' AND E1_NUM='"+( cQAlSQL )->( VQ2_NUMTIT )+"' AND E1_PREFORI='"+cDMSPrefOri+"' AND D_E_L_E_T_=' '")
			If nSE1Sal == 0
				cTitPag := STR0045 // Total
			Else
				nSE1Tot := FM_SQL("SELECT SUM(E1_VALOR) FROM "+cNamSE1+" WHERE E1_FILIAL='"+cFilAux+"' AND E1_NUM='"+( cQAlSQL )->( VQ2_NUMTIT )+"' AND E1_PREFORI='"+cDMSPrefOri+"' AND D_E_L_E_T_=' '")
				If nSE1Sal <> nSE1Tot
					cTitPag := STR0046 // Parcial
				EndIf
			EndIf
		EndIf
		nTipInc := aScan(aTipInc, {|x| x[1] == ( cQAlSQL )->( VQ2_TIPINC ) })
		If nTipInc > 0
			cTipInc := aTipInc[nTipInc,2]
		Else
			cTipInc := STR0060 // Outros
		EndIf
		If aScan(aIncent, {|x| x[3]+x[4]+left(x[12],1)+x[18] == ( cQAlSQL )->( VQ2_FILATE )+( cQAlSQL )->( VQ2_NUMATE )+( cQAlSQL )->( VQ2_TIPINC )+( cQAlSQL )->( VQ2_CHASSI ) }) <= 0
			aAdd(aIncent,{	.f.,;
						"oS"+( cQAlSQL )->( VQ2_STATUS ),;
						( cQAlSQL )->( VQ2_FILATE ),;
						( cQAlSQL )->( VQ2_NUMATE ),;
						( cQAlSQL )->( VQ2_CODCLI ),;
						( cQAlSQL )->( VQ2_LOJCLI ),;
						( cQAlSQL )->( VQ2_VLRINI ),;
						( cQAlSQL )->( VQ2_PERDES ),;
						( cQAlSQL )->( VQ2_VLRBAS ),;
						( cQAlSQL )->( VQ2_PERINC ),;
						( cQAlSQL )->( VQ2_VLRINC ),;
						( cQAlSQL )->( VQ2_TIPINC )+cTipInc,;
						( cQAlSQL )->( VQ2_NUMNFI ),;
						( cQAlSQL )->&( FGX_MILSNF('VQ2', 3, 'VQ2_SERNFI') ),;
						( cQAlSQL )->( RECVQ2 ),;
						ctod(""),;
						( cQAlSQL )->( A1_NOME ),;
						( cQAlSQL )->( VQ2_CHASSI ) ,;
						( cQAlSQL )->( VQ2_CODMAR ) ,;
						( cQAlSQL )->( VQ2_MODVEI ) ,;
						cTitPag ,;
						( cQAlSQL )->( VQ2_OBSNFC ) ,;
						( cQAlSQL )->( VQ2_NUMTIT ) ,;
						( cQAlSQL )->( VQ0_NUMPED ) ,;
						( cQAlSQL )->( VQ2_SERNFI ) })
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo	
	( cQAlSQL )->( DbCloseArea() )
	//
	If !Empty(cFilAte) .and. cFilAte <> cFilAnt
		Loop
	EndIf
	//
	cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV0.VV0_DATMOV , VVA.VVA_VALMOV , VVA.VVA_CODPED , SA1.A1_NOME , "
	cQuery += "VVA.VVA_CHAINT , VVA.VVA_CHASSI , VVA.VVA_CODMAR , VVA.VVA_MODVEI "
	cQuery += "FROM "+cNamVV0+" VV0 "
	cQuery += "JOIN "+cNamVVA+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
	cQuery += "JOIN "+cNamVV9+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' "
	cQuery += "LEFT JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=VV9.VV9_CODCLI AND SA1.A1_LOJA=VV9.VV9_LOJA AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	cQuery += "VV0.VV0_FILIAL='"+cFilVV0+"' AND "
	If !Empty(cNumAte)
		cQuery += "VV0.VV0_NUMTRA='"+cNumAte+"' AND "
	EndIf
	If !Empty(cChassi)
		cQuery += "VVA.VVA_CHASSI = '" + Alltrim(cChassi) + "' AND "
	EndIf
	If !Empty(cCodPed)
		cQuery += "VVA.VVA_CODPED = '" + Alltrim(cCodPed) + "' AND "
	EndIf
	cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
	cQuery += "VV0.VV0_TIPFAT='2' AND VV0.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		VCF->(DbSetOrder(1))
		VCF->(DbSeek(cFilVCF+( cQAlSQL )->( VV9_CODCLI )+( cQAlSQL )->( VV9_LOJA )))
		nPDes := 0
		If Empty(cNivImp) .or. ( VCF->VCF_NIVIMP <> cNivImp .and. aTipInc[1,4] ) .or. ( VCF->VCF_NIVIMP == cNivImp .and. aTipInc[1,5] )
			nPDes := aTipInc[1,3]
		EndIf
		For ni := 2 to len(aTipInc)
			nPni := 0
			If Empty(cNivImp) .or. ( VCF->VCF_NIVIMP <> cNivImp .and. aTipInc[ni,4] ) .or. ( VCF->VCF_NIVIMP == cNivImp .and. aTipInc[ni,5] )
				nPni := aTipInc[ni,3]
			EndIf
			If nPni > 0
				If aScan(aIncent, {|x| x[3]+x[4]+left(x[12],1)+x[18] == ( cQAlSQL )->( VV0_FILIAL )+( cQAlSQL )->( VV0_NUMTRA )+aTipInc[ni,1]+( cQAlSQL )->( VVA_CHASSI ) }) <= 0
					nVlrBase := 0
					If lVQ0_BASCFD .and. !Empty(( cQAlSQL )->( VVA_CODPED ))
						nVlrBase := FM_SQL("SELECT VQ0_BASCFD FROM "+cNamVQ0+" WHERE VQ0_FILIAL='"+cFilVQ0+"' AND VQ0_CODIGO='"+( cQAlSQL )->( VVA_CODPED )+"' AND VQ0_CHAINT='"+( cQAlSQL )->( VVA_CHAINT )+"' AND D_E_L_E_T_=' '")
					EndIf
					If nVlrBase == 0
						nVlrBase := ( cQAlSQL )->( VVA_VALMOV )
					EndIf
					aAdd(aIncent,{	.f.,;
							"oS0",;
							( cQAlSQL )->( VV0_FILIAL ),;
							( cQAlSQL )->( VV0_NUMTRA ),;
							( cQAlSQL )->( VV9_CODCLI ),;
							( cQAlSQL )->( VV9_LOJA ),;
							nVlrBase,;
							nPDes ,;
							round((nVlrBase*((100-nPDes)/100)),2),;
							nPni,;
							round((nVlrBase*((100-nPDes)/100))*(nPni/100),2),;
							aTipInc[ni,1]+aTipInc[ni,2],;
							"",;
							"",;
							0,;
							stod(( cQAlSQL )->( VV0_DATMOV )),;
							( cQAlSQL )->( A1_NOME ),;
							( cQAlSQL )->( VVA_CHASSI ) ,;
							( cQAlSQL )->( VVA_CODMAR ) ,;
							( cQAlSQL )->( VVA_MODVEI ) ,;
							"" ,;
							"" ,;
							"" ,;
							IIf(!Empty(( cQAlSQL )->( VVA_CODPED )),FM_SQL("SELECT VQ0_NUMPED FROM "+cNamVQ0+" WHERE VQ0_FILIAL='"+cFilVQ0+"' AND VQ0_CODIGO='"+( cQAlSQL )->( VVA_CODPED )+"' AND VQ0_CHAINT='"+( cQAlSQL )->( VVA_CHAINT )+"' AND D_E_L_E_T_=' '"),""),;
							"" })
				EndIf
			EndIf
		Next
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
Next

cFilAnt := cBkpFilAnt
//
If len(aIncent) <= 0
	aAdd(aIncent,{.f.,"oNada","","","","",0,0,0,0,0,"","","",0,ctod(""),"","","","","","","","",""})
EndIf
//
If nTp == 1
	oLbIncent:nAt := 1
	oLbIncent:SetArray(aIncent)
	oLbIncent:bLine := { || {	IIf(aIncent[oLbIncent:nAt,01],oLBTIK,oLBNO) , &(aIncent[oLbIncent:nAt,02]) ,;
								aIncent[oLbIncent:nAt,03] , aIncent[oLbIncent:nAt,04] ,aIncent[oLbIncent:nAt,24],;
								aIncent[oLbIncent:nAt,18] , aIncent[oLbIncent:nAt,19]+" "+aIncent[oLbIncent:nAt,20] ,;
								aIncent[oLbIncent:nAt,05]+"-"+aIncent[oLbIncent:nAt,06]+" "+aIncent[oLbIncent:nAt,17] ,;
								FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,07],"@E 999,999,999.99")),;
								FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,08],"@E 999.99 %")),;
								FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,09],"@E 999,999,999.99")),;
								FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,10],"@E 999.99 %")),;
								FG_AlinVlrs(Transform(aIncent[oLbIncent:nAt,11],"@E 999,999,999.99")),;
								substr(aIncent[oLbIncent:nAt,12],2),;
								aIncent[oLbIncent:nAt,13]+"-"+aIncent[oLbIncent:nAt,14],;
								aIncent[oLbIncent:nAt,23],;
								aIncent[oLbIncent:nAt,21]}}
	oLbIncent:Refresh()
EndIf
FS_ORDLB(4,nTp)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_ORDLB ³ Autor ³ Andre Luis Almeida     ³ Data ³ 06/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Ordenar VETOR - ListBox                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDLB(nCol,nTp)
Local nColAux := 0
Do Case
	Case nCol == 3
		nColAux := 4
	Case nCol == 4
		nColAux := 3
	Case nCol == 5
		nCol := 18
	Case nCol == 6
		nCol    := 19
		nColAux := 18
	Case nCol == 7
		nCol    := 5
		nColAux := 6
	Case nCol >= 8 .and. nCol <= 14
		nCol--
	Case nCol == 15
		nCol    := 23
		nColAux := 14
	Case nCol == 16
		nCol    := 21
		nColAux := 14
EndCase
If strzero(nCol,2) == left(cOrdLb,2)
	If right(cOrdLb,1) == "C"
		cOrdLb := strzero(nCol,2)+"D" // Decrescente
	Else
		cOrdLb := strzero(nCol,2)+"C" // Crescente
	EndIf
Else
	cOrdLb := strzero(nCol,2)+"C" // Crescente
EndIf
If right(cOrdLb,1) == "C"
	If nColAux == 0
		aSort(aIncent,,,{|x,y| x[nCol] < y[nCol] })
	Else
		aSort(aIncent,,,{|x,y| x[nCol]+x[nColAux] < y[nCol]+y[nColAux] })
	EndIf
Else
	If nColAux == 0
		aSort(aIncent,,,{|x,y| x[nCol] > y[nCol] })
	Else
		aSort(aIncent,,,{|x,y| x[nCol]+x[nColAux] > y[nCol]+y[nColAux] })
	EndIf
EndIf
If nTp == 1
	oLbIncent:Refresh()
	oLbIncent:SetFocus()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TIPINC ³ Autor ³ Andre Luis Almeida    ³ Data ³ 31/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Duplo Clik no ListBox dos Tipos de Incentivos ( Altera % )  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIPINC(nLinVet)
Local aRet      := {}
Local aParamBox := {}
cTip := aTipInc[nLinVet,2]
AADD(aParamBox,{1,"%"+" "+cTip,aTipInc[nLinVet,3],"@E 999.99" ,"MV_PAR01>=0","","",50,.f.})
If ParamBox(aParamBox,STR0031,@aRet,,,,,,,,.f.) // Incentivo - ALTERAR
	aTipInc[nLinVet,3] := aRet[01] // % 
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_DBLCLICK³ Autor ³ Andre Luis Almeida    ³ Data ³ 06/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Duplo Clik no ListBox ( seleciona e altera valores )        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DBLCLICK(nLinVet,nColVet,nTotSel)
Local ni        := 0
Local lOkTela   := .f.
Local cTip      := ""
Local aRet      := {}
Local aParamBox := {}
Local cFilBkp   := ""
if aIncent[nLinVet,3] <> cFilAnt 
	MsgAlert(STR0085)
	Return(.f.)
Endif
If aIncent[nLinVet,2] <> "oNada"
	If nColVet <= 1 .and. right(aIncent[nLinVet,2],1) $ "012" // Tik
		aIncent[nLinVet,1] := !aIncent[nLinVet,1]
	ElseIf right(aIncent[nLinVet,2],1) $ "01" // Alterar Valores
		If ExistBlock("VM180VLR")
			// Parametros do Ponto de Entrada (ParamIXB):
			//    [1] = % Desconto
			//    [2] = Vlr Base
			//    [3] = % Comissão
			//    [4] = Vlr Comissão
			//    [5] = RecNo VQ2
			//    [6] = Valor Inicial
			//    [7] = Filial Atendimento
			//    [8] = Nro. Atendimento
			aRet := ExecBlock("VM180VLR",.f.,.f., {	aIncent[nLinVet,08] ,;
													aIncent[nLinVet,09] ,;
													aIncent[nLinVet,10] ,;
													aIncent[nLinVet,11] ,;
													aIncent[nLinVet,15] ,;
													aIncent[nLinVet,07] ,;
													aIncent[nLinVet,03] ,;
													aIncent[nLinVet,04] })
			If ValType(aRet) == "A"
				// Retorno do Ponto de Entrada:
				//    [1] = % Desconto
				//    [2] = Vlr Base
				//    [3] = % Comissão
				//    [4] = Vlr Comissão
				aIncent[nLinVet,08] := aRet[01] // % Desconto
				aIncent[nLinVet,09] := aRet[02] // Vlr Base
				aIncent[nLinVet,10] := aRet[03] // % Comissão
				aIncent[nLinVet,11] := aRet[04] // Vlr Comissão
				lOkTela := .t.
			EndIf
		Else
			cTip := substr(aIncent[nLinVet,12],2)
			AADD(aParamBox,{1,STR0028         ,aIncent[nLinVet,07],"@E 999,999,999.99",""         ,"",".F.",50,.t.}) // Vlr Inicial
			AADD(aParamBox,{1,"% "+STR0007    ,aIncent[nLinVet,08],"@E 999.99"        ,"VM180VLDP(2)","","",50,.f.}) // % Desconto
			AADD(aParamBox,{1,STR0029         ,aIncent[nLinVet,09],"@E 999,999,999.99","VM180VLDP(3)","","",50,.f.}) // Vlr Base
			AADD(aParamBox,{1,"% "+cTip       ,aIncent[nLinVet,10],"@E 999.99"        ,"VM180VLDP(4)","","",50,.f.}) // % Comissão
			AADD(aParamBox,{1,STR0027+" "+cTip,aIncent[nLinVet,11],"@E 999,999,999.99","VM180VLDP(5)","","",50,.f.}) // Vlr Comissão
			If ParamBox(aParamBox,STR0031,@aRet,,,,,,,,.f.) // Incentivo - ALTERAR
				aIncent[nLinVet,08] := aRet[02] // % Desconto
				aIncent[nLinVet,09] := aRet[03] // Vlr Base
				aIncent[nLinVet,10] := aRet[04] // % Comissão
				aIncent[nLinVet,11] := aRet[05] // Vlr Comissão
				lOkTela := .t.
			EndIf
		EndIf
		If lOkTela
			If right(aIncent[nLinVet,2],1) $ "12" .and. aIncent[nLinVet,15] > 0
				DbSelectArea("VQ2")
				DbGoTo(aIncent[nLinVet,15])
				RecLock("VQ2",.f.)
					VQ2->VQ2_PERDES := aIncent[nLinVet,08] // % Desconto
					VQ2->VQ2_VLRBAS := aIncent[nLinVet,09] // Vlr Base
					VQ2->VQ2_PERINC := aIncent[nLinVet,10] // % Comissão
					VQ2->VQ2_VLRINC := aIncent[nLinVet,11] // Vlr Comissão
				MsUnLock()
			EndIf
		EndIf
	ElseIf !Empty(aIncent[nLinVet,13])
		SetKey(VK_F12, Nil )
		VQ2->(DbGoTo(aIncent[nLinVet,15]))
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek(VQ2->VQ2_FILNFI+aIncent[nLinVet,13]+aIncent[nLinVet,14])
			cAlias  := "SF2"
			nReg    := SF2->(Recno())
			nOpc    := 2
			cFilBkp := cFilAnt
			If cFilAnt <> SF2->F2_FILIAL
				cFilAnt := SF2->F2_FILIAL
			Endif
			Mc090Visual(cAlias,nReg,nOpc)
			cFilAnt := cFilBkp
		EndIf
		DbSelectArea("VQ2")
		SetKey(VK_F12,{ || FS_VM180X1(.t.) })
	EndIf
EndIf
nTotSel := 0
For ni := 1 to len(aIncent)
	If aIncent[ni,1]
		nTotSel += aIncent[ni,11]
	EndIf
Next
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VM180VLDP ³ Autor ³ Andre Luis Almeida    ³ Data ³ 07/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao dos campos da Parambox                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM180VLDP(nTp)
Local nVlrAux := &("MV_PAR0"+Alltrim(str(nTp)))
If nVlrAux < 0 .or. ( ( nTp == 2 .or. nTp == 4 ) .and. nVlrAux > 100 )
	Return(.f.)
EndIf
Do Case
	Case nTp == 2
		MV_PAR03 := round( ( MV_PAR01 * ( ( 100 - MV_PAR02 ) / 100 ) ) , 2 )
		MV_PAR05 := round( ( MV_PAR03 * ( MV_PAR04 / 100 ) ) , 2 )
	Case nTp == 3
		MV_PAR02 := round( ( 100 - ( ( MV_PAR03 / MV_PAR01 ) * 100 ) ) , 2 )
		MV_PAR05 := round( ( MV_PAR03 * ( MV_PAR04 / 100 ) ) , 2 )
	Case nTp == 4
		MV_PAR05 := round( ( MV_PAR03 * ( MV_PAR04 / 100 ) ) , 2 )
	Case nTp == 5          
		MV_PAR04 := round( ( ( MV_PAR05 / MV_PAR03 ) * 100 ) , 2 )
EndCase
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_GRAVAR ³ Autor ³ Andre Luis Almeida    ³ Data ³ 07/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Gravacoes / Cancelamentos / Geracao de NF/Titulos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVAR(nTp,nLinVet,cStatus,lPerg)
Local cNomVV9   := RetSqlName("VV9")
Local cNomVV0   := RetSqlName("VV0")
Local cFilVQ2   := xFilial("VQ2")
Local cQAlSQL   := "ALIASSQL"
Local cAliasVDT := "SQLVDT"
Local cQuery    := ""
Local cQAux     := ""
Local ni        := 0
Local nTotal    := 0
Local lOk       := .f.
Local cProb     := "" 
Local aParcelas := {}
Local cBkpFil   := ""
Default lPerg   := .t. // Pergunta se deve SALVAR os registros do Levantamento?
//
If aIncent[1,2] == "oNada"
	MsgInfo(STR0051,STR0016) // Sera necessario fazer o levantamento antes. / Atencao
	Return()
EndIf
//
If nTp <> 4 // Diferente de Cancelamento
	For ni := 1 to len(aIncent)
		If nLinVet == ni .or. ( nLinVet == 0 .and. aIncent[ni,1] )
			cQuery := "SELECT VV0.R_E_C_N_O_ RECVV0 "
			cQuery += "FROM "+cNomVV0+" VV0 "
			cQuery += "JOIN "+cNomVV9+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' "
			cQuery += "WHERE "
			cQuery += "VV0.VV0_FILIAL='"+aIncent[ni,03]+"' AND VV0.VV0_NUMTRA='"+aIncent[ni,04]+"' AND "
			cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND VV0.VV0_TIPFAT='2' AND VV0.D_E_L_E_T_=' '"
			If FM_SQL(cQuery) == 0
				cProb += aIncent[ni,03]+" "+aIncent[ni,04]+CHR(13)+CHR(10)
				aIncent[ni,1] := .f.
			EndIf
		EndIf
	Next
	If !Empty(cProb)
		MsgStop(STR0049+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cProb,STR0016) // O(s) Atendimento(s) relacionado(s) abaixo não pode(m) ser(em) selecionado(s) devido ao(s) seu(s) STATUS. Atenção
		Return()
	EndIf
EndIf

Do Case

	Case nTp == 1 // Gravar registros selecionados do levantados
		If nLinVet == 0
			For ni := 1 to len(aIncent)
				If aIncent[ni,1] .and. right(aIncent[ni,2],1) == "0"
					lOk := .t.
					Exit
	   			EndIf
	   		Next
	   	EndIf
		If !lOk .and. nLinVet == 0
			MsgInfo(STR0021,STR0016) // Nenhum registro selecionado do levantamento! / Atencao
		ElseIf nLinVet <> 0 .or. !lPerg .or. MsgYesNo(STR0017,STR0016) // Deseja gravar os registros selecionados do levantado? / Atencao
			//
			Begin Transaction
			//
			For ni := 1 to len(aIncent)
				If nLinVet == ni .or. ( nLinVet == 0 .and. aIncent[ni,1] .and. right(aIncent[ni,2],1) == "0" )
					DbSelectArea("VQ2")
					RecLock("VQ2",.t.)
						VQ2->VQ2_FILIAL := cFilVQ2
						VQ2->VQ2_CODIGO := GetSXENum("VQ2","VQ2_CODIGO")
						VQ2->VQ2_DATINC := dDataBase
						VQ2->VQ2_FILATE := aIncent[ni,03]
						VQ2->VQ2_NUMATE := aIncent[ni,04]
						VQ2->VQ2_DATATE := aIncent[ni,16]
						VQ2->VQ2_CODCLI := aIncent[ni,05]
						VQ2->VQ2_LOJCLI := aIncent[ni,06]
						VQ2->VQ2_VLRINI := aIncent[ni,07]
						VQ2->VQ2_PERDES := aIncent[ni,08]
						VQ2->VQ2_VLRBAS := aIncent[ni,09]
						VQ2->VQ2_PERINC := aIncent[ni,10]
						VQ2->VQ2_VLRINC := aIncent[ni,11]
						VQ2->VQ2_TIPINC := left(aIncent[ni,12],1)
						VQ2->VQ2_NUMNFI := aIncent[ni,13]
						VQ2->VQ2_SERNFI := aIncent[ni,14]
						if fieldpos("VQ2_SDOC") > 0
							VQ2->VQ2_SDOC := aIncent[ni, 25]
						EndIf
						VQ2->VQ2_CHASSI := aIncent[ni,18]
						VQ2->VQ2_CODMAR := aIncent[ni,19]
						VQ2->VQ2_MODVEI := aIncent[ni,20]
						VQ2->VQ2_OBSNFC := aIncent[ni,22]
						VQ2->VQ2_NUMTIT := aIncent[ni,23]
					MsUnLock()
					ConfirmSX8()
					aIncent[ni,15] := VQ2->(RecNo())
					FS_GRAVAR(5,ni,"1") // Grava Status com '1'
				EndIf
			Next
			//
			End Transaction
			//
		EndIf
		
		
	Case nTp == 2 // Liberar para geracao de NF/Titulos
		For ni := 1 to len(aIncent)
			If aIncent[ni,1]
				lOk := .t.
				Exit				
			EndIf
		Next
		If !lOk
			MsgInfo(STR0020,STR0016) // Necessario selecionar os registros! / Atencao
		ElseIf MsgYesNo(STR0018,STR0016) // Deseja liberar para geracao de NF/Titulos dos registros selecionados? / Atencao
			//
			Begin Transaction
			//
			For ni := 1 to len(aIncent)
				If aIncent[ni,1]
					If aIncent[ni,15] == 0 // Nao gravou ainda
						FS_GRAVAR(1,ni,"1") // Gravar registros selecionados do levantados
					EndIf
					FS_GRAVAR(5,ni,"2") // Grava Status com '2'
				EndIf
			Next
			//
			End Transaction
			//
		EndIf
		
		
	Case nTp == 3 // Geracao de NF/Titulos
		//
		For ni := 1 to len(aIncent)
			If aIncent[ni,1]
				nTotal += aIncent[ni,11]
				If right(aIncent[ni,02],1) <> "2"
					MsgInfo(STR0019,STR0016) // Para gerar NF/Titulos, antes sera necessario liberar todos os registros selecionados! / Atencao
					nTotal := -1
					Exit
				EndIf
			EndIf
		Next
		//
		If nTotal == 0
			MsgInfo(STR0020,STR0016) // Necessario selecionar os registros! / Atencao
		ElseIf nTotal > 0
			cBkpFil := cFilAnt // Salvar cFilAnt
			cFilAnt := FWPesqSM0("M0_CODFIL",cEmpAnt)  // Escolher a filial que deseja trabalhar
			If !Empty(cFilAnt)
				VM180GNFTIT(nTotal) // Gerar NF e Titulos
			EndIf
			cFilAnt := cBkpFil // Voltar cFilAnt
		EndIf
		

	Case nTp == 4 // Cancelamento
		if aIncent[nLinVet,3] <> cFilAnt 
			MsgAlert(STR0085)
			Return(.f.)
		Endif
		If right(aIncent[nLinVet,02],1) $ "012" // Levantados / Gravados / Liberados para faturar
			If MsgYesNo(STR0047,STR0016) // Deseja Cancelar a comissão/incentivo selecionado? / Atencao
				DbSelectArea("VQ2")
				DbGoTo(aIncent[nLinVet,15])
				aMotCancel := OFA210MOT("000013","7",VQ2->VQ2_FILIAL,VQ2->VQ2_CODIGO,.T.) // Filtro da consulta do motivo
				If Len(aMotCancel) > 0 
					If aIncent[nLinVet,15] == 0 // Nao gravou ainda
						FS_GRAVAR(1,nLinVet,"1") // Gravar registros selecionados do levantados
					EndIf
					FS_GRAVAR(5,nLinVet,"4") // Grava Status com '4'
					aIncent[nLinVet,01] := .f.
					dbSelectArea("VQ2")             
					RecLock("VQ2",.f.)
					VQ2->VQ2_MOTIVO := aMotCancel[1]
					MsUnlock()
				EndIf      
			Endif	
		ElseIf right(aIncent[nLinVet,02],1) == "3" // NF/Titulos gerados
			If !Empty(aIncent[nLinVet,13]+aIncent[nLinVet,14]) // NF
				If MsgYesNo(STR0048+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aIncent[nLinVet,13]+"-"+aIncent[nLinVet,14],STR0016) // Deseja Cancelar a NF? / Atencao
					DbSelectArea("VQ2")
					DbGoTo(aIncent[nLinVet,15])
					aMotCancel := OFA210MOT("000013","7",VQ2->VQ2_FILIAL,VQ2->VQ2_CODIGO,.T.) // Filtro da consulta do motivo
					If Len(aMotCancel) > 0 
						DbSelectArea("SF2")
						DbSetOrder(1)
						If DbSeek(xFilial("SF2")+aIncent[nLinVet,13]+space(TamSX3("F2_DOC")[1]-Len(aIncent[nLinVet,13]))+aIncent[nLinVet,14])
							SE4->(DbSetOrder(1))
							If SE4->(DbSeek(xFilial("SE4")+SF2->F2_COND))
								If SE4->E4_TIPO == "A" // Condicao de Pagamento do tipo Negociacao
									//
									cQAux := "  FROM "+RetSQLName("SE1")+" SE1"
									cQAux += " WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"'"
									cQAux += "   AND SE1.E1_PREFIXO='"+SF2->F2_PREFIXO+"'"
									cQAux += "   AND SE1.E1_NUM='"+aIncent[nLinVet,23]+"'"
									cQAux += "   AND SE1.E1_CLIENTE='"+SF2->F2_CLIENTE+"'"
									cQAux += "   AND SE1.E1_LOJA='"+SF2->F2_LOJA+"'"
									cQAux += "   AND SE1.E1_PREFORI='"+cDMSPrefOri+"'"
									cQAux += "   AND SE1.E1_FILORIG='"+aIncent[nLinVet,03]+"'"
									cQAux += "   AND SE1.D_E_L_E_T_=' '"
									//
									// Verificar se ja existe Titulos Baixados ou Parcialmente Baixados
									cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1"
									cQuery += cQAux
									cQuery += "   AND ( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR )"
									If FM_SQL(cQuery) > 0
										MsgStop(STR0071,STR0016) // Ha titulo(s) de Contas a Receber ja baixado(s)! / Atencao
										Return
									EndIf
									cQuery := "SELECT SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO"
									cQuery += cQAux
									dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
									While !(cQAlSQL)->(Eof())
										If (cQAlSQL)->(E1_TIPO) $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT // Nao leva para a exclusao os Titulo de Abatimento de Impostos
											(cQAlSQL)->(DbSkip())
											Loop
										EndIf
										aAdd(aParcelas,{{"E1_PREFIXO" , (cQAlSQL)->( E1_PREFIXO ) ,nil},;
														{"E1_NUM"     , (cQAlSQL)->( E1_NUM )     ,nil},;
														{"E1_PARCELA" , (cQAlSQL)->( E1_PARCELA ) ,nil},;
														{"E1_TIPO"    , (cQAlSQL)->( E1_TIPO )    ,nil},;
														{"E1_ORIGEM"  , "MATA460"                  ,nil}})
										(cQAlSQL)->(DbSkip())
									Enddo
									(cQAlSQL)->(DbCloseArea())
								EndIf
							EndIf
	                    EndIf
						If FMX_EXCNFS(aIncent[nLinVet,13]+space(TamSX3("F2_DOC")[1]-Len(aIncent[nLinVet,13])),aIncent[nLinVet,14],.t.)
							Begin Transaction
								If len(aParcelas) > 0
									DbSelectArea("SE1")
									Pergunte("FIN040",.F.)
									For ni := 1 to len(aParcelas)
										lMsErroAuto := .f.
										MSExecAuto({|x,y| FINA040(x,y)},aParcelas[ni],5)
										If lMsErroAuto
											MostraErro()
											DisarmTransaction()
											Return
										EndIf
									Next
								EndIf
								For ni := 1 to len(aIncent)
									If aIncent[ni,13]+aIncent[ni,14] == aIncent[nLinVet,13]+aIncent[nLinVet,14]
										FS_GRAVAR(5,ni,"4") // Grava Status com '4'
									EndIf
								Next
							End Transaction
						EndIf
						dbSelectArea("VQ2")             
						RecLock("VQ2",.f.)
						VQ2->VQ2_MOTIVO := aMotCancel[1]
						MsUnlock()
					EndIf  
				Endif	
			Else // Titulos
				If MsgYesNo(STR0070+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aIncent[nLinVet,23],STR0016) // Deseja Cancelar o(s) Titulo(s)? / Atencao
					// Verificar se ja existe Titulos Baixados ou Parcialmente Baixados
					cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
					cQuery += "SE1.E1_NUM='"+aIncent[nLinVet,23]+"' AND SE1.E1_PREFORI='"+cDMSPrefOri+"' AND ( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR ) AND "
					cQuery += "SE1.E1_FILORIG='"+aIncent[nLinVet,03]+"' AND SE1.D_E_L_E_T_=' '"
					If FM_SQL(cQuery) > 0
						MsgStop(STR0071,STR0016) // Ha titulo(s) de Contas a Receber ja baixado(s)! / Atencao
						Return
					EndIf
					cQuery := "SELECT SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO FROM "+RetSQLName("SE1")+" SE1 "
					cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_NUM='"+aIncent[nLinVet,23]+"' AND SE1.E1_PREFORI='"+cDMSPrefOri+"' AND "
					cQuery += "SE1.E1_FILORIG='"+aIncent[nLinVet,03]+"' AND SE1.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
					While !(cQAlSQL)->(Eof())
						If (cQAlSQL)->(E1_TIPO) $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT // Nao leva para a exclusao os Titulo de Abatimento de Impostos
							(cQAlSQL)->(DbSkip())
							Loop
						EndIf
						aAdd(aParcelas,{{"E1_PREFIXO" , (cQAlSQL)->( E1_PREFIXO ) ,nil},;
										{"E1_NUM"     , (cQAlSQL)->( E1_NUM )     ,nil},;
										{"E1_PARCELA" , (cQAlSQL)->( E1_PARCELA ) ,nil},;
										{"E1_TIPO"    , (cQAlSQL)->( E1_TIPO )    ,nil},;
										{"E1_ORIGEM"  , "MATA460"                  ,nil}})
						(cQAlSQL)->(DbSkip())
					Enddo
					(cQAlSQL)->(DbCloseArea())
					DbSelectArea("SE1")
					Pergunte("FIN040",.F.)
					Begin Transaction
						For ni := 1 to len(aParcelas)
							lMsErroAuto := .f.
							MSExecAuto({|x,y| FINA040(x,y)},aParcelas[ni],5)
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Return
							EndIf
						Next
						For ni := 1 to len(aIncent)
							If aIncent[ni,23] == aIncent[nLinVet,23]
								FS_GRAVAR(5,ni,"4") // Grava Status com '4'
							EndIf
						Next
					End Transaction
				EndIf
			EndIf
		ElseIf right(aIncent[nLinVet,02],1) == "4" // Cancelado
			// Verificar se o Atendimento esta Cancelado //
			VV9->(DbSetOrder(1))
			If VV9->(DbSeek(aIncent[nLinVet,03]+aIncent[nLinVet,04]))
				If VV9->VV9_STATUS == "C" // Cancelado
					MsgAlert(STR0030,STR0016) // Impossivel recuperar registro, o Atendimento esta cancelado! / Atencao
				Else
					If MsgYesNo(STR0034,STR0016) // Deseja recuperar o registro selecionado? / Atencao
						If !Empty(aIncent[nLinVet,13]+aIncent[nLinVet,14]+aIncent[nLinVet,23])
							aIncent[nLinVet,13] := ""
							aIncent[nLinVet,14] := ""
							aIncent[nLinVet,21] := ""
							aIncent[nLinVet,22] := ""
							aIncent[nLinVet,23] := ""
							if len(aIncent) >= 25
								aIncent[nLinVet,25] := ""
							Endif

							DbSelectArea("VQ2")
							DbGoTo(aIncent[nLinVet,15])
							RecLock("VQ2",.f.)
								VQ2->VQ2_FILNFI := ""
								VQ2->VQ2_NUMNFI := ""
								VQ2->VQ2_SERNFI := ""
								if fieldpos('VQ2_SDOC') > 0
									VQ2->VQ2_SDOC := ""
								EndIf
								VQ2->VQ2_DATNFI := ctod("")
								VQ2->VQ2_OBSNFC := ""
								VQ2->VQ2_NUMTIT := ""
								VQ2->VQ2_MOTIVO := ""
							MsUnLock()  
						EndIf
						// Exclui registro do questionario    
				
						cQuery := "SELECT VDT.R_E_C_N_O_ RECVDT "
						cQuery += "FROM "
						cQuery += RetSqlName( "VDT" ) + " VDT " 
						cQuery += "WHERE " 
						cQuery += "VDT.VDT_FILIAL='"+ xFilial("VDT")+ "' AND VDT.VDT_TIPASS ='000013' AND VDT.VDT_CODMOT = '"+VQ2->VQ2_MOTIVO+"' AND VDT.VDT_CODORI = '"+VQ2->VQ2_CODIGO+"' AND VDT.D_E_L_E_T_ = ' '"
			
						dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVDT, .T., .T. )

						Do While !( cAliasVDT )->( Eof() )
							VDT->(dbGoTo(( cAliasVDT )->(RECVDT)))
				            RecLock("VDT",.F.,.T.)
				            dbdelete()
       	    			 	MsUnlock()
		       			 	dbSelectArea(cAliasVDT)
       					 	( cAliasVDT )->(dbSkip())
            		    Enddo
					    ( cAliasVDT )->( dbCloseArea() )
						DbSelectArea("VQ2")
						DbGoTo(aIncent[nLinVet,15])
						RecLock("VQ2",.f.)
						VQ2->VQ2_MOTIVO := ""
						MsUnLock()  
						FS_GRAVAR(5,nLinVet,"1") // Grava Status com '1'
					EndIf
				EndIf
			EndIf
		EndIf


	Case nTp == 5 // Grava Status
		aIncent[nLinVet,02] := left(aIncent[nLinVet,02],len(aIncent[nLinVet,02])-1)+cStatus
		DbSelectArea("VQ2")
		DbGoTo(aIncent[nLinVet,15])
		RecLock("VQ2",.f.)
			VQ2->VQ2_STATUS := cStatus
		MsUnLock()

EndCase
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VM180GNFTITº Autor ³ Andre Luis Almeida º Data ³ 01/11/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera NF / Titulos de Incentivos de Faturamento Direto      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM180GNFTIT(nTotal)
Local cQuery      := ""
Local cQAlSQL     := "ALIASSQL"
Local cFilVQ2     := xFilial("VQ2")
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeAut    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam     := 0
Local lOkTELA     := .f.
Local nLinTela    := 0
//
Local aNF         := {}
Local cFilSF2     := xFilial("SF2")
Local cFilSE1     := xFilial("SE1")
Local cNamSE1     := RetSQLName("SE1")
Local cOBSNFC     := ""
Local cParc       := ""
Local cPreTit     := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos quando gerar somente TITULOS
Local cNumTit     := ""
Local aVetPE      := {}
Local aTipCli     := X3CBOXAVET("A1_TIPO","0")
Local aIndPre     := X3CBOXAVET("VV0_INDPRE","0")
//
Local lExistPET   := (ExistBlock("VM180TIT"))
Local nNumTit     := 0
Local aAuxParc    := {}
//
Local aVetCab     := {}
Local aVetIte     := {}
Local aVetTit     := {}
//
Private aSE1CIFD  := {}
Private nTotSE1FD := nTotal // Total das Parcelas
Private nDivSE1FD := 0 // Divergencia entre o Total das Parcelas
Private aNFTit    := {             ;
	space(TamSX3("A1_COD")[1]),    ;
	space(TamSX3("A1_LOJA")[1]),   ;
	"",                            ;
	space(TamSX3("A3_COD")[1]),    ;
	"",                            ;
	space(TamSX3("E1_NATUREZ")[1]),;
	"",                            ;
	space(TamSX3("E1_PORTADO")[1]),;
	space(TamSX3("B1_COD")[1]),    ;
	"",                            ;
	"",                            ;
	RetCondVei(),                  ;
	"",                            ;
	"",                            ;
	space(TamSX3("C5_MENPAD")[1]), ;
	"",                            ;
	space(TamSX3("C5_MENNOTA")[1]),;
	space(TamSX3("C5_ESTPRES")[1]),;
	space(TamSX3("C5_MUNPRES")[1]),;
	""                             ;
}
Private nOpcNFTit := 1
Private M->C5_ESTPRES := "" // Utilizado no F3 da Consulta do Municipio (CC2SC5)
///////////////////////////////////////
// Fator de reducao de 0.85          //
///////////////////////////////////////
For nCntTam := 1 to Len(aSizeAut)
	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.85)
Next
aInfo := { aSizeAut[ 1 ] , aSizeAut[ 2 ] , aSizeAut[ 3 ] , aSizeAut[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 24 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 , 90 , .T. , .T. } ) // ListBox Parcelas do Incentivo -> Faturamento Direto
aAdd( aObjects, { 0 , 13 , .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )
///////////////////////////////////////
// Pegar dados da ultima nota gerada //
///////////////////////////////////////
cQuery := "SELECT SF2.F2_CLIENTE , SF2.F2_LOJA , SA1.A1_NOME , SA1.A1_TIPO , SF2.F2_VEND1 , SA3.A3_NOME , SD2.D2_COD , SB1.B1_DESC FROM "+RetSQLName("VQ2")+" VQ2 "
cQuery += "JOIN "+RetSQLName("SF2")+" SF2 ON ( SF2.F2_FILIAL=VQ2.VQ2_FILNFI AND SF2.F2_DOC=VQ2.VQ2_NUMNFI AND SF2.F2_SERIE=VQ2.VQ2_SERNFI AND SF2.D_E_L_E_T_=' ' ) "
cQuery += "JOIN "+RetSQLName("SD2")+" SD2 ON ( SD2.D2_FILIAL=VQ2.VQ2_FILNFI AND SD2.D2_DOC=VQ2.VQ2_NUMNFI AND SD2.D2_SERIE=VQ2.VQ2_SERNFI AND SD2.D_E_L_E_T_=' ' ) "
cQuery += "JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' ) "
cQuery += "JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=SF2.F2_VEND1 AND SA3.D_E_L_E_T_=' ' ) "
cQuery += "JOIN "+RetSQLName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VQ2.VQ2_FILIAL='"+cFilVQ2+"' AND VQ2.VQ2_NUMNFI<>' ' AND VQ2.D_E_L_E_T_=' ' "
cQuery += "ORDER BY VQ2.VQ2_CODIGO DESC"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
If !( cQAlSQL )->( Eof() )
	aNFTit[01] := ( cQAlSQL )->( F2_CLIENTE )
	aNFTit[02] := ( cQAlSQL )->( F2_LOJA )
	aNFTit[03] := ( cQAlSQL )->( A1_NOME )
	aNFTit[04] := ( cQAlSQL )->( F2_VEND1 )
	aNFTit[05] := ( cQAlSQL )->( A3_NOME )
	aNFTit[09] := ( cQAlSQL )->( D2_COD )
	aNFTit[10] := ( cQAlSQL )->( B1_DESC )
	aNFTit[13] := ( cQAlSQL )->( A1_TIPO )
EndIf
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VQ2")
//
VM180CONDPG("1",.f.,,) // Carregar Parcelas
//
DEFINE MSDIALOG oSE1CFD TITLE (STR0015) FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd  PIXEL
oTPanelVM180 := TPanel():New(aPos[1,1]+003,aPos[1,2]+003,"",oSE1CFD,NIL,.T.,.F.,NIL,NIL,aPos[3,4]-184,aPos[3,3]-aPos[1,1]-007,.T.,.F.)
nLinTela := 00
@ aPos[1,1]+nLinTela+005,aPos[1,2]+003 SAY (STR0073+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Gerar
@ aPos[1,1]+nLinTela+000,aPos[1,2]+030 RADIO oTpNFTit VAR nOpcNFTit 3D SIZE 100,20 PROMPT STR0081,STR0082 OF oTPanelVM180 PIXEL ON CHANGE VM180VTELA(0)
nLinTela := 30
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY (STR0074+": ") COLOR CLR_HBLUE OF oTPanelVM180 PIXEL // Cliente
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit01 VAR aNFTit[01] PICTURE "@!" F3 "SA1" VALID VM180VTELA(1) SIZE 45,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+097 MSGET oNFTit02 VAR aNFTit[02] PICTURE "@!" VALID VM180VTELA(1) SIZE 15,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+115 MSGET oNFTit03 VAR aNFTit[03] PICTURE "@!" SIZE aPos[1,4]-313,08 OF oTPanelVM180 PIXEL HASBUTTON WHEN .f.
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY (STR0075+": ") COLOR CLR_HBLUE OF oTPanelVM180 PIXEL // Vendedor
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit04 VAR aNFTit[04] PICTURE "@!" F3 "SA3" VALID VM180VTELA(2) SIZE 45,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+097 MSGET oNFTit05 VAR aNFTit[05] PICTURE "@!" SIZE aPos[1,4]-295,08 OF oTPanelVM180 PIXEL HASBUTTON WHEN .f.
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY (STR0076+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Natureza
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit06 VAR aNFTit[06] PICTURE "@!" F3 "SED" VALID VM180VTELA(3) SIZE 62,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+115 MSGET oNFTit07 VAR aNFTit[07] PICTURE "@!" SIZE aPos[1,4]-313,08 OF oTPanelVM180 PIXEL HASBUTTON WHEN .f.
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY (STR0077+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Banco
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit08 VAR aNFTit[08] PICTURE "@!" SIZE 20,08 OF oTPanelVM180 PIXEL HASBUTTON
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitTip VAR (STR0087+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Tipo de Cliente
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSCOMBOBOX oNFTit13 VAR aNFTit[13] SIZE 130,08 ITEMS aTipCli OF oTPanelVM180 PIXEL COLOR CLR_BLUE WHEN ( len(aTipCli) > 0 )
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitInd VAR (STR0088+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Indic.Presenca
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSCOMBOBOX oNFTit14 VAR aNFTit[14] SIZE 130,08 ITEMS aIndPre OF oTPanelVM180 PIXEL COLOR CLR_BLUE WHEN ( len(aIndPre) > 0 )
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitPro VAR (STR0078+": ") COLOR CLR_HBLUE OF oTPanelVM180 PIXEL // Servico - Produto
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit09 VAR aNFTit[09] PICTURE "@!" F3 "SB1" VALID VM180VTELA(4) SIZE 85,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+137 MSGET oNFTit10 VAR aNFTit[10] PICTURE "@!" SIZE aPos[1,4]-335,08 OF oTPanelVM180 PIXEL HASBUTTON WHEN .f.
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitPro VAR (Alltrim(RetTitle("C5_ESTPRES"))+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // UF Prestacao
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit18 VAR aNFTit[18] PICTURE "@!" F3 "12" VALID VM180VTELA(7) SIZE 40,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+001,aPos[1,2]+113 SAY oTitPro VAR (Alltrim(RetTitle("C5_MUNPRES"))+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // UF Prestacao
@ aPos[1,1]+nLinTela+000,aPos[1,2]+160 MSGET oNFTit19 VAR aNFTit[19] PICTURE "@!" F3 "CC2SC5" VALID VM180VTELA(8) SIZE 50,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+215 MSGET oNFTit20 VAR aNFTit[20] PICTURE "@!" SIZE aPos[1,4]-413,08 OF oTPanelVM180 PIXEL HASBUTTON WHEN .f.
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitMsgP VAR (STR0089+": ") COLOR CLR_HBLUE OF oTPanelVM180 PIXEL // Mens. Padrao
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit15 VAR aNFTit[15] PICTURE "@!" F3 "SM4" VALID ((texto() .Or. Vazio()) .And. VM180VTELA(6)) SIZE 45,08 OF oTPanelVM180 PIXEL HASBUTTON
@ aPos[1,1]+nLinTela+000,aPos[1,2]+097 MSGET oNFTit16 VAR aNFTit[16] PICTURE "@!" SIZE aPos[1,4]-295,08 OF oTPanelVM180 PIXEL HASBUTTON WHEN .f.
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitMsgNF VAR (STR0090+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Mens.p/ Nota
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 MSGET oNFTit17 VAR aNFTit[17] PICTURE "@!" SIZE aPos[1,4]-249,08 OF oTPanelVM180 PIXEL HASBUTTON
nLinTela += 13
@ aPos[1,1]+nLinTela+001,aPos[1,2]+003 SAY oTitObs VAR (STR0079+": ") COLOR CLR_BLUE OF oTPanelVM180 PIXEL // Observacao NF
@ aPos[1,1]+nLinTela+000,aPos[1,2]+050 GET oNFTit11 VAR aNFTit[11] OF oTPanelVM180 MEMO SIZE aPos[1,4]-249,054 PIXEL
//
@ aPos[1,1]+002,(aPos[1,4]-172)+000 TO aPos[1,3],aPos[1,4] LABEL (STR0069) OF oSE1CFD PIXEL // Parcelas
@ aPos[1,1]+011,(aPos[1,4]-172)+005 SAY (STR0068+": ") COLOR CLR_BLUE OF oSE1CFD PIXEL // Valor Total
@ aPos[1,1]+010,(aPos[1,4]-172)+035 MSGET oTotal VAR nTotSE1FD PICTURE "@E 9,999,999.99" SIZE 50,08 OF oSE1CFD WHEN .f. PIXEL HASBUTTON
@ aPos[1,1]+011,(aPos[1,4]-172)+090 SAY (STR0025+": ") COLOR CLR_HBLUE OF oSE1CFD PIXEL // Cond.Pagamento
@ aPos[1,1]+010,(aPos[1,4]-172)+135 MSGET oNFTit12 VAR aNFTit[12] PICTURE "@!" F3 "SE4" VALID VM180CONDPG("1",.t.,,) SIZE 17,08 OF oSE1CFD PIXEL HASBUTTON
@ aPos[2,1]+000,(aPos[2,4]-172)+000 LISTBOX oLbSE1CFD FIELDS HEADER STR0066 , STR0067 , "%" COLSIZES 50,50,50 SIZE 172,aPos[2,3]-aPos[2,1] OF oSE1CFD ON DBLCLICK VM180CONDPG("2",.t.,oLbSE1CFD:nAt,oLbSE1CFD:nColPos) PIXEL // Data / Valor
oLbSE1CFD:SetArray(aSE1CIFD)
oLbSE1CFD:bLine := { || { Transform(aSE1CIFD[oLbSE1CFD:nAt,01],"@D") , FG_AlinVlrs(Transform(aSE1CIFD[oLbSE1CFD:nAt,02],"@E 999,999,999.99")) , FG_AlinVlrs(Transform((aSE1CIFD[oLbSE1CFD:nAt,02]/nTotSE1FD)*100,"@E 9,999.99"))+" %" }}
@ aPos[3,1]+001,aPos[1,4]-085 SAY (STR0065+": ") OF oSE1CFD PIXEL // Divergencia
@ aPos[3,1]+000,aPos[1,4]-050 MSGET oDivSE1CFD VAR nDivSE1FD PICTURE "@E 9,999,999.99" SIZE 50,08 OF oSE1CFD WHEN .f. PIXEL HASBUTTON
ACTIVATE MSDIALOG oSE1CFD CENTER ON INIT EnchoiceBar(oSE1CFD,{|| IIf(VM180CONDPG("3",,,).and.VM180VTELA(5),(lOkTELA:=.t.,oSE1CFD:End()),.t.) },{ || oSE1CFD:End()},,)
If lOkTELA // Ok TELA
    //
	cNumTit := FM_SQL("SELECT MAX(SE1.E1_NUM) FROM "+cNamSE1+" SE1 WHERE SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO='"+cPreTit+"' AND SE1.E1_NUM LIKE 'CFD%' AND SE1.E1_FILORIG='"+cFilSF2+"'")
	If Empty(cNumTit)
		cNumTit := "CFD"+strzero(1,TamSX3("E1_NUM")[1]-3)
	Else
		cNumTit := "CFD"+strzero(val(right(cNumTit,TamSX3("E1_NUM")[1]-3))+1,TamSX3("E1_NUM")[1]-3)
	EndIf
	//
	If nOpcNFTit == 1 // NF e Titulos
	//
		aVetCab := {   ;
			aNFTit[01],;
			aNFTit[02],;
			aNFTit[04],;
			aNFTit[12],;
			aNFTit[06],;
			aNFTit[08],;
			aNFTit[11],;
			aNFTit[17],;
			aNFTit[15] ;
		}

		aAdd(aVetIte, {aNFTit[09], nTotSE1FD})

		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial("SE4")+aNFTit[12]))
			If SE4->E4_TIPO == "A" // Condicao de Pagamento do tipo Negociacao
				If len(aSE1CIFD) > 0
					aAdd(aVetTit,{"E1_VENCTO","E1_VENCREA","E1_VALOR"})
					aAdd(aVetTit,{})
					For nCntTam := 1 to len(aSE1CIFD)
						aAdd(aVetTit[2],{aSE1CIFD[nCntTam,01],DataValida(aSE1CIFD[nCntTam,01]),aSE1CIFD[nCntTam,02]})
					Next
				EndIf
			EndIf
		EndIf
		////////////////////////////////////////////////////////////////////////
		// Para manipulacao dos vetores de integracao com o MATA410, utilizar //
		// os PE's PEGERNFS e PEGERNFT que sao chamados antes das integracoes //
		////////////////////////////////////////////////////////////////////////
		aNF := FMX_GERNFS(aVetCab,aVetIte,.t.,cDMSPrefOri,aVetTit,aNFTit[13],aNFTit[14],aNFTit[18],aNFTit[19])
		If len(aNF) > 0 .and. !Empty(aNF[1])
			cNumTit := aNF[1]
			Begin Transaction
				For nCntTam := 1 to len(aIncent)
					If aIncent[nCntTam,1]
						FS_GRAVAR(5,nCntTam,"3") // Grava Status com '3'
						DbSelectArea("VQ2")
						DbGoTo(aIncent[nCntTam,15])
						RecLock("VQ2",.f.)
							VQ2->VQ2_FILNFI := cFilSF2
							VQ2->VQ2_NUMNFI := aNF[1]
							VQ2->VQ2_SERNFI := aNF[2]
							if fieldpos("VQ2_SDOC") > 0
								VQ2->VQ2_SDOC := FGX_UFSNF( aNF[2] )
							EndIf
							VQ2->VQ2_DATNFI := dDataBase
							VQ2->VQ2_OBSNFC := cOBSNFC
							VQ2->VQ2_NUMTIT := cNumTit
						MsUnLock()
						If Empty(cOBSNFC) .and. !Empty(aNFTit[11])
							MSMM(VQ2->VQ2_OBSNFC,TamSx3("VQ2_OBSNFM")[1],,aNFTit[11],1,,,"VQ2","VQ2_OBSNFC")
							cOBSNFC := VQ2->VQ2_OBSNFC
						EndIf
						aIncent[nCntTam,01] := .f.
						aIncent[nCntTam,13] := aNF[1]
						aIncent[nCntTam,14] := aNF[2]
						aIncent[nCntTam,22] := cOBSNFC
						aIncent[nCntTam,23] := cNumTit
					EndIf
				Next
			End Transaction
		Else
			Return(.f.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX6")
		MsRUnLock()
		//
		MsUnlockAll()
	//
	Else // nOpcNFTit == 2 // Somente Titulos
	//
		If len(aSE1CIFD) > 0
			Begin Transaction
				For nCntTam := 1 to len(aSE1CIFD)
					//
					cParc := FM_SQL("SELECT MAX(SE1.E1_PARCELA) FROM "+cNamSE1+" SE1 WHERE SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO='"+cPreTit+"' AND SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_FILORIG='"+cFilSF2+"'")
					If Empty(cParc)
						cParc := strzero(0,TamSX3("E1_PARCELA")[1])
					EndIf
					cParc := Soma1(cParc)
					//
					aVetTit := {}
					aAdd(aVetTit,{"E1_PREFIXO",cPreTit        ,nil})
					aAdd(aVetTit,{"E1_NUM"    ,cNumTit        ,nil})
					aAdd(aVetTit,{"E1_PARCELA",cParc          ,nil})
					If !Empty(aNFTit[06])
						aAdd(aVetTit,{"E1_NATUREZ",aNFTit[06] ,nil})
					EndIf
					aAdd(aVetTit,{"E1_CLIENTE",aNFTit[01]     ,nil})
					aAdd(aVetTit,{"E1_LOJA"   ,aNFTit[02]     ,nil})
					aAdd(aVetTit,{"E1_TIPO"   ,"CFD"          ,nil})
					aAdd(aVetTit,{"E1_PREFORI",cDMSPrefOri       ,nil})
					aAdd(aVetTit,{"E1_EMISSAO",dDataBase      ,nil})
					aAdd(aVetTit,{"E1_VENCTO" ,aSE1CIFD[nCntTam,01],nil})
					aAdd(aVetTit,{"E1_VENCREA",DataValida(aSE1CIFD[nCntTam,01]),nil})
					aAdd(aVetTit,{"E1_VALOR"  ,aSE1CIFD[nCntTam,02],nil})
					aAdd(aVetTit,{"E1_ORIGEM" ,"MATA460"      ,nil})
					aAdd(aVetTit,{"E1_VEND1"  ,aNFTit[04]     ,nil})
					If !Empty(aNFTit[08])
						aAdd(aVetTit,{"E1_PORTADO",aNFTit[08] ,nil})
					EndIf
					If lExistPET
						aAuxParc := ExecBlock("VM180TIT",.f.,.f.,{ aClone(aVetTit) })
						If ValType(aAuxParc) == "A"
							aVetTit := aClone(aAuxParc)
							nNumTit := aScan(aVetTit, {|x| x[1] == "E1_NUM" })
							If nNumTit > 0
								cNumTit := aVetTit[nNumTit,2] // Pegar o nro do Titulo que pode ter sido alterado
							EndIf
						EndIf
					EndIf
					If len(aVetTit) > 0
						Pergunte("FIN040",.f.)
						lMsErroAuto := .f.
						MSExecAuto({|x| FINA040(x)},aVetTit)
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
							Return(.f.)
						EndIf
					EndIf
				Next
				For nCntTam := 1 to len(aIncent)
					If aIncent[nCntTam,1]
						FS_GRAVAR(5,nCntTam,"3") // Grava Status com '3'
						DbSelectArea("VQ2")
						DbGoTo(aIncent[nCntTam,15])
						RecLock("VQ2",.f.)
							VQ2->VQ2_NUMTIT := cNumTit
						MsUnLock()
						aIncent[nCntTam,01] := .f.
						aIncent[nCntTam,23] := cNumTit
					EndIf
				Next
			End Transaction
		Else
			Return(.f.)
		EndIf
	//
	EndIf
    //
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| PE apos "Emissao da NF" (1) ou da "Geracao de Titulos" (2)       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("VM180FIM")
		If nOpcNFTit == 1 // NF
			aVetPE := { cFilSF2 , aNF[1] , aNF[2] } // SF2 -> Filial / Nro. NF / Serie NF
		Else // Titulos
			aVetPE := { cFilSE1 , cPreTit , cNumTit } // SE1 -> Filial / Prefixo Titulo / Nro. Titulo
		EndIf	
		ExecBlock("VM180FIM",.f.,.f.,{nOpcNFTit,aVetPE})
	EndIf
	
EndIf
Return(lOkTELA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VM180VTELAº Autor ³ Andre Luis Almeida º Data ³ 04/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacoes na Tela de geracao de NF / Titulos              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM180VTELA(nTp)
Local lRet       := .t.
Local ni         := 0
Local cCposObrig := ""
//
Local oCliente   := DMS_Cliente():New()
//


Do Case
	Case nTp == 0 // NF e Titulos / Somente Titulos
		oNFTit09:lVisible  := ( nOpcNFTit == 1 )
		oNFTit10:lVisible  := ( nOpcNFTit == 1 )
		oNFTit11:lVisible  := ( nOpcNFTit == 1 )
		oNFTit13:lVisible  := ( nOpcNFTit == 1 )
		oNFTit14:lVisible  := ( nOpcNFTit == 1 )
		oNFTit15:lVisible  := ( nOpcNFTit == 1 )
		oNFTit16:lVisible  := ( nOpcNFTit == 1 )
		oNFTit17:lVisible  := ( nOpcNFTit == 1 )
		oTitPro:lVisible   := ( nOpcNFTit == 1 )
		oTitObs:lVisible   := ( nOpcNFTit == 1 )
		oTitTip:lVisible   := ( nOpcNFTit == 1 )
		oTitInd:lVisible   := ( nOpcNFTit == 1 )
		oTitMsgP:lVisible  := ( nOpcNFTit == 1 )
		oTitMsgNF:lVisible := ( nOpcNFTit == 1 )

	Case nTp == 1 // Digitacao do Codigo/Loja do Cliente
		If !Empty(aNFTit[01])
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+aNFTit[01]+aNFTit[02]))
				If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					lRet := .f.
				Else
					aNFTit[03] := SA1->A1_NOME
					aNFTit[13] := SA1->A1_TIPO
				EndIf
			Else
				If SA1->(MsSeek(xFilial("SA1")+aNFTit[01]))
					If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
						lRet := .f.
					Else
						aNFTit[02] := SA1->A1_LOJA
						aNFTit[03] := SA1->A1_NOME
						aNFTit[13] := SA1->A1_TIPO
					EndIf
				Else
					lRet := .f.
					aNFTit[03] := ""
				EndIf
			EndIf
		Else
			aNFTit[02] := space(TamSX3("A1_LOJA")[1])
			aNFTit[03] := ""
		EndIf
		oNFTit02:Refresh()
		oNFTit03:Refresh()
		oNFTit13:Refresh()

	Case nTp == 2 // Digitacao do Codigo do Vendedor
		If !Empty(aNFTit[04])
			SA3->(DbSetOrder(1))
			If SA3->(MsSeek(xFilial("SA3")+aNFTit[04]))
				aNFTit[05] := SA3->A3_NOME
			Else
				lRet := .f.
				aNFTit[05] := ""
			EndIf	
		Else
			aNFTit[05] := ""
		EndIf
		oNFTit05:Refresh()
		
	Case nTp == 3 // Digitacao do Codigo da Natureza
		If !Empty(aNFTit[06])
			SED->(DbSetOrder(1))
			If SED->(MsSeek(xFilial("SED")+aNFTit[06]))
				aNFTit[07] := SED->ED_DESCRIC
			Else
				lRet := .f.
				aNFTit[07] := ""
			EndIf
		Else
			aNFTit[07] := ""
		EndIf
		oNFTit07:Refresh()

	Case nTp == 4 // Digitacao do Codigo do Servico - Produto
		If !Empty(aNFTit[09])
			SB1->(DbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+aNFTit[09]))
				aNFTit[10] := SB1->B1_DESC
			Else
				lRet := .f.
				aNFTit[10] := ""
			EndIf
		Else
			aNFTit[10] := ""
		EndIf
		oNFTit10:Refresh()

	Case nTp == 5 // Valida Campos obrigatorios da TELA
		If nOpcNFTit == 1 // NF e Titulos
			cCposObrig := "0102040912"
		Else
			cCposObrig := "01020412"
		EndIf
		For ni := 1 to len(cCposObrig) step 2
			If Empty(aNFTit[val(substr(cCposObrig,ni,2))])
				MsgStop(STR0080,STR0002) // Impossivel continuar! Existem campos obrigatorios nao preenchidos. / Atencao
				&("oNFTit"+substr(cCposObrig,ni,2)+":SetFocus()")
				lRet := .f.
				Exit
			EndIf
		Next

	Case nTp == 6 // Digitacao do Código da Mensagem Padrão
		If !Empty(aNFTit[15])
			SM4->(DbSetOrder(1))
			If SM4->(MsSeek(xFilial("SM4")+aNFTit[15]))
				aNFTit[16] := SM4->M4_DESCR
			Else
				lRet := .f.
				aNFTit[16] := ""
			EndIf
		Else
			aNFTit[16] := ""
		EndIf
		oNFTit16:Refresh()

	Case nTp == 7 // Digitacao da UF de Prestação
		M->C5_ESTPRES := "" // Utilizado no F3 da Consulta do Municipio (CC2SC5)
		If !Empty(aNFTit[18])
			SX5->(DbSetOrder(1))
			If SX5->(MsSeek(xFilial("SX5")+"12"+aNFTit[18]))
				M->C5_ESTPRES := aNFTit[18]
			Else
				lRet := .f.
				aNFTit[20] := ""
			EndIf
		Else
			aNFTit[20] := ""
		EndIf
		oNFTit20:Refresh()

	Case nTp == 8 // Digitacao do Municipio de Prestação
		aNFTit[20] := ""
		If !Empty(aNFTit[19])
			CC2->(DbSetOrder(1))
			If CC2->(MsSeek(xFilial("CC2")+aNFTit[18]+aNFTit[19]))
				aNFTit[19] := CC2->CC2_CODMUN
				aNFTit[20] := CC2->CC2_MUN
			Else
				lRet := .f.
			EndIf
		EndIf
		oNFTit20:Refresh()

EndCase

// Ponto de Entrada antes da Geração de Nota e Titulo
// Dependendo do retorno impedirá a sequência do processo
if ExistBlock("VM180ANT")
	if !ExecBlock("VM180ANT",.f.,.f.,{nTp})
		lRet := .f.
	Endif
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VM180CONDPGº Autor ³ Andre Luis Almeida º Data ³ 01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar Geracao de NF e Titulos ( VM180GNFTIT )    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cTipo = 1 Monta vetor de Parcelas atraves da Cond.Pagamentoº±±
±±º          ³       = 2 Altera a Data/Valor da Parcela selecionada       º±±
±±º          ³       = 3 Valida valor total dos Incentivos                º±±
±±º          ³       = 4 Digitacao da Valor da Parcela                    º±±
±±º          ³       = 5 Digitacao do % referente ao Valor da Parcela     º±±
±±º          ³ lRefresh - Refresh no ListBox ?    .f.  /  .t.             º±±
±±º          ³ nLin     - Linha do ListBox                                º±±
±±º          ³ nCol     - Coluna do ListBox                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM180CONDPG(cTipo,lRefresh,nLin,nCol)

Local nValTot    := 0
Local lRet       := .t.
Local aRet       := {}
Local aParamBox  := {}
Default cTipo    := "1"
Default lRefresh := .f.
Default nLin     := 1
Default nCol     := 1
Do Case
	Case cTipo == "1" // Monta vetor atraves da Condicao de Pagamento
		If Empty(aNFTit[12])
			aNFTit[12] := RetCondVei()
		EndIf
		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial("SE4")+aNFTit[12]))
			If SE4->E4_TIPO <> "A" // Diferente de Condicao de Pagamento do tipo Negociacao
				aSE1CIFD := {}
				aSE1CIFD := Condicao(nTotSE1FD,SE4->E4_CODIGO,,dDataBase)
			EndIf
		Else
			lRet := .f.
		EndIf
		If len(aSE1CIFD) <= 0
			aadd(aSE1CIFD,{dDataBase,nTotSE1FD})
		EndIf
	Case cTipo == "2" // Duplo-Click na linha da Parcela (Alterar a Data/Valor da Parcela)
		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial("SE4")+aNFTit[12]))
			If SE4->E4_TIPO <> "A" // Diferente de Condicao de Pagamento do tipo Negociacao
				MsgStop(STR0061,STR0002) // Condicao de Pagamento utilizada nao e do tipo negociada. Impossivel alterar data/valor! / Atencao
			Else
				AADD(aParamBox,{1,STR0066,aSE1CIFD[nLin,1],"@D",'MV_PAR01>=dDataBase',,".t.",50,.t.}) // Data
				AADD(aParamBox,{1,STR0067,aSE1CIFD[nLin,2],"@E 999,999,999.99",'VM180CONDPG("4",.t.,,)',,IIf(nCol<=2,".t.",".f."),50,IIf(nCol<=2,.t.,.f.)}) // Valor
				AADD(aParamBox,{1,"%",(aSE1CIFD[nLin,2]/nTotSE1FD)*100,"@E 9,999.99",'VM180CONDPG("5",.t.,,)',,IIf(nCol==3,".t.",".f."),50,IIf(nCol==3,.t.,.f.)}) // %
				AADD(aParamBox,{1,STR0050,(aSE1CIFD[nLin,2]+nDivSE1FD),"@E 9,999.99",'',,".f.",50,.f.}) // Vlr p/ nao existir divergencia
				If ParamBox(aParamBox,(STR0031),@aRet,,,,,,,,.f.) // Alterar
					aSE1CIFD[nLin,1] := aRet[1] // Data
					aSE1CIFD[nLin,2] := aRet[2] // Valor
				EndIf
				For nLin := 1 to len(aSE1CIFD)
					nValTot += aSE1CIFD[nLin,2]
				Next
				nDivSE1FD := ( nTotSE1FD - nValTot )
				oDivSE1CFD:Refresh()
			EndIf
		EndIf
	Case cTipo == "3" // Valida Divergencia de valores ( Parcelas x Total )
		If nDivSE1FD <> 0
			MsgStop(STR0062+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Impossivel continuar! Ha divergencia entre o total das Parcelas e o valor dos Incentivos.
			FG_AlinVlrs(left(STR0064+space(30),30),"E")+FG_AlinVlrs(Transform(nTotSE1FD,"@E 999,999,999.99"))+CHR(13)+CHR(10)+; // Total dos Incentivos
			FG_AlinVlrs(left(STR0063+space(30),30),"E")+FG_AlinVlrs(Transform(nTotSE1FD-nDivSE1FD,"@E 999,999,999.99"))+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Total das Parcelas
			FG_AlinVlrs(left(STR0065+space(30),30),"E")+FG_AlinVlrs(Transform(nDivSE1FD,"@E 999,999,999.99")),STR0002) // Divergencia / Atencao
			lRet := .f.
		EndIf
	Case cTipo == "4" // Digitacao do Valor da Parcela
		If MV_PAR02 > 0
			MV_PAR03 := round( ( ( MV_PAR02 / nTotSE1FD ) * 100 ) , 2 )
		Else
			lRet := .f.
		EndIf
	Case cTipo == "5" // Digitacao do % do Valor da Parcela
		If MV_PAR03 > 0
			MV_PAR02 := round( ( ( nTotSE1FD / 100 ) * MV_PAR03 ) , 2 )
		Else
			lRet := .f.
		EndIf
EndCase
If lRefresh
	oLbSE1CFD:SetArray(aSE1CIFD)
	oLbSE1CFD:bLine := { || { Transform(aSE1CIFD[oLbSE1CFD:nAt,01],"@D") , FG_AlinVlrs(Transform(aSE1CIFD[oLbSE1CFD:nAt,02],"@E 999,999,999.99")) , FG_AlinVlrs(Transform((aSE1CIFD[oLbSE1CFD:nAt,02]/nTotSE1FD)*100,"@E 9,999.99"))+" %" }}
	oLbSE1CFD:Refresh()
EndIf
Return(lRet)

/*/{Protheus.doc} VM1800011_COD_PEDIDO()
	Validação do Codigo do Pedido, preenche automaticamente o Numero do Pedido e o Chassi do Veiculo
	
	@author Andre Luis Almeida
	@since 13/04/2020
/*/
Static Function VM1800011_COD_PEDIDO(cCodPed)
Local lRet := .f.
If Empty(cCodPed)
	cNumPed := space(TamSX3("VQ0_NUMPED")[1])
	oNumPed:Refresh()
	lRet := .t.
Else
	DbSelectArea("VQ0")
	DbSetOrder(1)
	If DbSeek( xFilial("VQ0") + cCodPed )
		cNumPed := VQ0->VQ0_NUMPED
		cChassi := VQ0->VQ0_CHASSI
		oNumPed:Refresh()
		oChassi:Refresh()
		lRet := .t.
	EndIf
EndIf
Return lRet