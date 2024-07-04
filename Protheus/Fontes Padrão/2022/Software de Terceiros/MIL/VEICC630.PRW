// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEICC630.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VEICC630³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Interesses de Clientes (Oportunidade de Negocio) x Estoque  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC630()
Local nTam      := 0
Local lCEVOUT   := ( VAI->(FieldPos("VAI_CEVOUT")) <> 0 )
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private overd   := LoadBitmap( GetResources(), "BR_VERDE" )
Private olara   := LoadBitmap( GetResources(), "BR_LARANJA" )
Private overm   := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private aIntVei := {}
Private aVeiTot := {}
Private aVeiEst := {}
Private cCodVen := space(TamSX3("VDM_CODVEN")[1])
Private cMarVeiF3 := space(TamSX3("VDM_CODMAR")[1])
Private cModelo := space(TamSX3("VDM_MODVEI")[1])
Private dDatIni := dDataBase
Private dDatFin := ctod("01/"+IIf(month(dDatabase)<12,strzero(month(dDatabase)+1,2)+"/"+substr(strzero(year(dDatabase),4),3,2),"01/"+substr(strzero(year(dDatabase)+1,4),3,2)))-1
Private cCodCli := space(TamSX3("VDL_CODCLI")[1])
Private cLojCli := space(TamSX3("VDL_LOJCLI")[1])
Private cCodFas := space(TamSX3("VDK_CODFAS")[1])
//
Private lEst    := .t.
Private lPed    := .t.
Private lNov    := .t.
Private lUsa    := .t.
//
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek(xFilial("VAI")+__cUserID)
If lCEVOUT .and. VAI->VAI_CEVOUT<>"1"
	cCodVen := VAI->VAI_CODVEN
EndIf

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  25 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox 1
aAdd( aObjects, { 0 ,  18 , .T. , .F. } ) // CheckBox
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox 2
aAdd( aObjects, { 0 ,  10 , .T. , .F. } ) // Legenda
aPos := MsObjSize( aInfo, aObjects )

FS_FILTRAR(0)

DbSelectArea("VDM")
DEFINE MSDIALOG oDlgIntVei TITLE STR0001 From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Interesses de Clientes x Estoque/Pedido
oDlgIntVei:lEscClose := .F.

@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[2,1]-003,aPos[1,4] LABEL "" OF oDlgIntVei PIXEL
@ aPos[1,1]+003,aPos[1,2]+004 SAY (STR0002+":") SIZE 45,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+004 MSGET oCodVen VAR cCodVen F3 "SA3" VALID ( vazio() .or. FG_Seek("SA3","cCodVen",1) ) PICTURE X3Picture("A3_COD") SIZE 28,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE WHEN ( !lCEVOUT .or. VAI->VAI_CEVOUT=="1" )

@ aPos[1,1]+003,aPos[1,2]+040 SAY (STR0003+":") SIZE 45,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE // Interesse
@ aPos[1,1]+011,aPos[1,2]+040 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 42,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+012,aPos[1,2]+086 SAY STR0004 SIZE 20,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE // a
@ aPos[1,1]+011,aPos[1,2]+093 MSGET oDatFin VAR dDatFin VALID(dDatFin>=dDatIni) PICTURE "@D" SIZE 42,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE

@ aPos[1,1]+003,aPos[1,2]+139 SAY (STR0011+":") SIZE 45,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+139 MSGET oCodCli VAR cCodCli F3 "SA1" PICTURE X3Picture("A1_COD") SIZE 30,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+172 MSGET oLojCli VAR cLojCli PICTURE "@!" SIZE 10,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE

@ aPos[1,1]+003,aPos[1,2]+191 SAY (STR0007+":") SIZE 45,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+191 MSGET oMarca VAR cMarVeiF3 F3 "VE1" PICTURE X3Picture("VV1_CODMAR") SIZE 25,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE

@ aPos[1,1]+003,aPos[1,2]+224 SAY (STR0008+":") SIZE 45,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+224 MSGET oModelo VAR cModelo F3 "MCF" PICTURE X3Picture("VV1_MODVEI") SIZE 70,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE

@ aPos[1,1]+003,aPos[1,2]+298 SAY (STR0024+":") SIZE 45,08 OF oDlgIntVei  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+298 MSGET oCodFas VAR cCodFas F3 "VDKFAS" PICTURE X3Picture("VDK_CODFAS") SIZE 33,08 OF oDlgIntVei PIXEL COLOR CLR_BLUE

@ aPos[1,1]+007,aPos[1,4]-063 BUTTON oFiltrar PROMPT STR0006 OF oDlgIntVei SIZE 55,11 PIXEL ACTION (FS_FILTRAR(1),FS_VEICULOS(oLbIntVei:nAt))

@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbIntVei FIELDS HEADER "",; 
						STR0007,; // Marca
						STR0008,; // Modelo
						STR0010,; // Cor
						STR0009,; // Qtde
						STR0003,; // Interesse
						STR0024,; // Fase
						STR0011,; // Cliente
						STR0012,; // Fone
						STR0013,; // Cidade-UF
						STR0002;  // Vendedor
						COLSIZES 10,20,120,35,15,30,70,150,80,110,80 SIZE aPos[2,4]-3,aPos[2,3]-aPos[2,1] OF oDlgIntVei PIXEL ON CHANGE FS_VEICULOS(oLbIntVei:nAt)
oLbIntVei:SetArray(aIntVei)
oLbIntVei:bLine := { || {IIf(aIntVei[oLbIntVei:nAt,01]=="0",overm,IIf(aIntVei[oLbIntVei:nAt,01]=="1",olara,overd)),;
						aIntVei[oLbIntVei:nAt,02] ,;
						aIntVei[oLbIntVei:nAt,03]+" - "+aIntVei[oLbIntVei:nAt,04] ,;
						aIntVei[oLbIntVei:nAt,05] ,;
						FG_AlinVlrs(Transform(aIntVei[oLbIntVei:nAt,06],"@E 999,999")) ,;
						Transform(aIntVei[oLbIntVei:nAt,07],"@D") ,;
						aIntVei[oLbIntVei:nAt,12] ,;
						aIntVei[oLbIntVei:nAt,08] ,;
						aIntVei[oLbIntVei:nAt,09] ,;
						aIntVei[oLbIntVei:nAt,10] ,;
						aIntVei[oLbIntVei:nAt,11] }}
//
@ aPos[3,1]+000,aPos[3,2]+000 TO aPos[4,3],aPos[4,4] LABEL STR0015 OF oDlgIntVei PIXEL // Veiculo(s)
//
nTam := ( aPos[3,4] / 4 )
@ aPos[3,1]+010,aPos[3,2]+008+(nTam*0) CHECKBOX oCkEst VAR lEst PROMPT STR0020 OF oDlgIntVei ON CLICK (FS_FILTRAR(2),FS_VEICULOS(oLbIntVei:nAt)) SIZE 66,08 PIXEL
@ aPos[3,1]+010,aPos[3,2]+008+(nTam*1) CHECKBOX oCkPed VAR lPed PROMPT STR0021 OF oDlgIntVei ON CLICK (FS_FILTRAR(2),FS_VEICULOS(oLbIntVei:nAt)) SIZE 66,08 PIXEL
@ aPos[3,1]+010,aPos[3,2]+008+(nTam*2) CHECKBOX oCkNov VAR lNov PROMPT STR0022 OF oDlgIntVei ON CLICK (FS_FILTRAR(2),FS_VEICULOS(oLbIntVei:nAt)) SIZE 66,08 PIXEL
@ aPos[3,1]+010,aPos[3,2]+008+(nTam*3) CHECKBOX oCkUsa VAR lUsa PROMPT STR0023 OF oDlgIntVei ON CLICK (FS_FILTRAR(2),FS_VEICULOS(oLbIntVei:nAt)) SIZE 66,08 PIXEL
//
@ aPos[4,1]+000,aPos[4,2]+000 LISTBOX oLbVeiEst FIELDS HEADER "",;
						STR0005,; // Veiculo
						STR0007,; // Marca
						STR0008,; // Modelo
						STR0010,; // Cor
						STR0014,; // Chassi
						STR0019,;  // Filial Estoque
						COLSIZES 10,70,20,120,60,80 SIZE aPos[4,4]-3,aPos[4,3]-aPos[4,1] OF oDlgIntVei PIXEL
oLbVeiEst:SetArray(aVeiEst)
oLbVeiEst:bLine := { || {IIf(aVeiEst[oLbVeiEst:nAt,1]=="0",overm,IIf(aVeiEst[oLbVeiEst:nAt,1]=="1",olara,overd)),;
						aVeiEst[oLbVeiEst:nAt,2] ,;
						aVeiEst[oLbVeiEst:nAt,3] ,;
						aVeiEst[oLbVeiEst:nAt,4]+" - "+aVeiEst[oLbVeiEst:nAt,5] ,;
						aVeiEst[oLbVeiEst:nAt,6] ,;
						aVeiEst[oLbVeiEst:nAt,7] ,;
						aVeiEst[oLbVeiEst:nAt,8] }}
//
nTam := ( aPos[5,4] / 3 )
@ aPos[5,1]+000,aPos[5,2]+006+(nTam*0) BITMAP oxVerd RESOURCE "BR_VERDE" OF oDlgIntVei NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[5,1]+000,aPos[5,2]+015+(nTam*0) SAY STR0016 SIZE 150,8 OF oDlgIntVei PIXEL COLOR CLR_BLUE // Marca e Modelo iguais
@ aPos[5,1]+000,aPos[5,2]+006+(nTam*1) BITMAP oxlara RESOURCE "BR_LARANJA" OF oDlgIntVei NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[5,1]+000,aPos[5,2]+015+(nTam*1) SAY STR0017 SIZE 150,8 OF oDlgIntVei PIXEL COLOR CLR_BLUE // Marca e Grupo de Modelo iguais
@ aPos[5,1]+000,aPos[5,2]+006+(nTam*2) BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oDlgIntVei NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[5,1]+000,aPos[5,2]+015+(nTam*2) SAY STR0018 SIZE 150,8 OF oDlgIntVei PIXEL COLOR CLR_BLUE // Nao encontrado

ACTIVATE MSDIALOG oDlgIntVei ON INIT EnchoiceBar(oDlgIntVei,{|| oDlgIntVei:End() }, {|| oDlgIntVei:End() },,)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida     ³ Data ³ 20/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Filtra Interesses x Estoque                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp)
Local cQAlVDM  := "SQLVDM"
Local CQALVV1  := "SQLVV1"
Local cQuery   := ""
Local lA1_IBGE := ( SA1->(FieldPos("A1_IBGE")) > 0 )
Local cAux     := ""
Local cCodInt  := ""
Local cChaInt  := ""
//
aIntVei := {}
aVeiTot := {}
//
cQuery := "SELECT VDM.VDM_CODINT , VDM.VDM_CODMAR , VDM.VDM_MODVEI , VVC.VVC_DESCRI , VDM.VDM_QTDINT , VDM.VDM_DATINT , "
cQuery += "VDL.VDL_CODCLI , VDL.VDL_LOJCLI , VDL.VDL_NOMCLI , VDL.VDL_DDDCLI , VDL.VDL_TELCLI , "
cQuery += "SA1.A1_MUN , SA1.A1_EST , "
If lA1_IBGE
	cQuery += "VAM.VAM_DESCID , VAM.VAM_ESTADO , "
EndIf
cQuery += "SA3.A3_NOME , VV2.VV2_DESMOD , VV2.VV2_GRUMOD , VDM.VDM_CODFAS , VDK.VDK_DESFAS "
cQuery += "FROM "+RetSqlName("VDM")+" VDM "
cQuery += "JOIN "+RetSqlName("VDL")+" VDL ON ( VDL.VDL_FILIAL=VDM.VDM_FILIAL AND VDL.VDL_CODOPO=VDM.VDM_CODOPO AND VDL.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VDL.VDL_CODCLI AND SA1.A1_LOJA=VDL.VDL_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
If lA1_IBGE
	cQuery += "LEFT JOIN "+RetSqlName("VAM")+" VAM ON ( VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' ' ) "
EndIf
cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VDM.VDM_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VDM.VDM_CODMAR AND VV2.VV2_MODVEI=VDM.VDM_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VDM.VDM_CODMAR AND VVC.VVC_CORVEI=VDM.VDM_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("VDK")+" VDK ON ( VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_CODFAS=VDM.VDM_CODFAS AND VDK.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VDM.VDM_FILIAL='"+xFilial("VDM")+"' AND "
If !Empty(cCodCli)
	cQuery += "VDL.VDL_CODCLI='"+cCodCli+"' AND "
EndIf
If !Empty(cLojCli)
	cQuery += "VDL.VDL_LOJCLI='"+cLojCli+"' AND "
EndIf
If !Empty(cCodVen)
	cQuery += "( VDM.VDM_CODVEN=' ' OR VDM.VDM_CODVEN='"+cCodVen+"' ) AND "
EndIf
If !Empty(cMarVeiF3)
	cQuery += "VDM.VDM_CODMAR='"+cMarVeiF3+"' AND "
EndIf
If !Empty(cModelo)
	cQuery += "VDM.VDM_MODVEI='"+cModelo+"' AND "
EndIf
If !Empty(cCodFas)
	cQuery += "VDM.VDM_CODFAS='"+cCodFas+"' AND "
EndIf
cQuery += "VDM.VDM_DATINT>='"+dtos(dDatIni)+"' AND VDM.VDM_DATINT<='"+dtos(dDatFin)+"' AND VDM.VDM_MOTCAN=' ' AND VDM.VDM_CODMAR<>' ' AND "
cQuery += "VDM.VDM_FILATE=' ' AND VDM.VDM_NUMATE=' ' AND VDM.D_E_L_E_T_=' ' ORDER BY VDM.VDM_DATINT , VDM.VDM_CODMAR , VDM.VDM_MODVEI , VDM.VDM_CODINT "
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVDM , .F., .T. )
Do While !( cQAlVDM )->( Eof() )
	//
	If cCodInt == ( cQAlVDM )->( VDM_CODINT )
		( cQAlVDM )->( DbSkip() )
		Loop
	EndIf
	cCodInt := ( cQAlVDM )->( VDM_CODINT )
	//
	Aadd(aIntVei,{"0",;																									// 01
				( cQAlVDM )->( VDM_CODMAR ),;																			// 02
				Alltrim(( cQAlVDM )->( VDM_MODVEI )),;																	// 03
				( cQAlVDM )->( VV2_DESMOD ),;																			// 04
				( cQAlVDM )->( VVC_DESCRI ),;																			// 05
				( cQAlVDM )->( VDM_QTDINT ),;																			// 06
				stod(( cQAlVDM )->( VDM_DATINT )),;																	// 07
				( cQAlVDM )->( VDL_CODCLI )+"-"+( cQAlVDM )->( VDL_LOJCLI )+" "+left(( cQAlVDM )->( VDL_NOMCLI ),30),;	// 08
				"( "+( cQAlVDM )->( VDL_DDDCLI )+" ) "+( cQAlVDM )->( VDL_TELCLI ) ,;			// 09
				Alltrim(left(IIf(lA1_IBGE,( cQAlVDM )->( VAM_DESCID ),( cQAlVDM )->( A1_MUN )),22))+"-"+IIf(lA1_IBGE,( cQAlVDM )->( VAM_ESTADO ),( cQAlVDM )->( A1_EST )),; // 10
				left(( cQAlVDM )->( A3_NOME ),20) ,; // 11
				( cQAlVDM )->( VDM_CODFAS )+" "+( cQAlVDM )->( VDK_DESFAS ) })	// 12
	//
	cQuery := "SELECT VV1.VV1_CHAINT , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VVC.VVC_DESCRI , VV1.VV1_CHASSI , VV1.VV1_FILENT "
	cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
	cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CODMAR='"+( cQAlVDM )->( VDM_CODMAR )+"' AND VV2.VV2_GRUMOD='"+( cQAlVDM )->( VV2_GRUMOD )+"' AND "
	Do Case
		Case lEst .and. lPed // Estoque e Pedido
			cQuery += "VV1.VV1_SITVEI IN ('0','8') AND "
		Case lEst // Somente Estoque
			cQuery += "VV1.VV1_SITVEI='0' AND "
		Case lPed // Somente Pedido
			cQuery += "VV1.VV1_SITVEI='8' AND "
		OtherWise // Nenhum selecionado
			cQuery += "VV1.VV1_SITVEI='XXX' AND "
	EndCase
	Do Case
		Case lNov .and. !lUsa // Somente NOVO
			cQuery += "VV1.VV1_ESTVEI<>'1' AND "
		Case !lNov .and. lUsa // Somente USADO
			cQuery += "VV1.VV1_ESTVEI='1' AND "
		Case !lNov .and. !lUsa // Nenhum selecionado
			cQuery += "VV1.VV1_ESTVEI='XXX' AND "
	EndCase
	cQuery += "VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHAINT "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
	If !( cQAlVV1 )->( Eof() )
		aIntVei[len(aIntVei),1] := "1" // Modelo diferente
		Do While !( cQAlVV1 )->( Eof() )
			//
			If cChaInt == ( cQAlVV1 )->( VV1_CHAINT )
				( cQAlVV1 )->( DbSkip() )
				Loop
			EndIf
			cChaInt := ( cQAlVV1 )->( VV1_CHAINT )
			//
			cMesmoMod := "1" // Modelo diferente
			If ( cQAlVDM )->( VDM_MODVEI ) == ( cQAlVV1 )->( VV1_MODVEI )
				cMesmoMod := "2" // Mesmo Modelo
				aIntVei[len(aIntVei),1] := "2" // Mesmo Modelo
			EndIf
			Aadd(aVeiTot,{cMesmoMod,;
						IIf(( cQAlVV1 )->( VV1_SITVEI )=="0",STR0020,STR0021)+" ( "+IIf(( cQAlVV1 )->( VV1_ESTVEI )=="1",STR0023,STR0022)+" )",;
						( cQAlVDM )->( VDM_CODMAR ),Alltrim(( cQAlVV1 )->( VV1_MODVEI )),( cQAlVV1 )->( VV2_DESMOD ),( cQAlVV1 )->( VVC_DESCRI ),;
						( cQAlVV1 )->( VV1_CHASSI ),( cQAlVV1 )->( VV1_FILENT ),len(aIntVei)})
			( cQAlVV1 )->( DbSkip() )
		EndDo
	EndIf
	( cQAlVV1 )->( dbCloseArea() )
	//
	( cQAlVDM )->( DbSkip() )
EndDo
( cQAlVDM )->( dbCloseArea() )
If len(aIntVei) <= 0
	Aadd(aIntVei,{"0","","","","",0,cTod(""),"","","","",""})
EndIf
If len(aVeiTot) <= 0
	Aadd(aVeiTot,{"0","","","","","","","",0})
EndIf
Asort(aVeiTot,1,,{|x,y| strzero(9-val(x[1]),1)+x[3]+x[4]+x[5]+x[7] < strzero(9-val(y[1]),1)+y[3]+y[4]+y[5]+y[7] }) // Ordenar por veiculo mais proximo
If nTp > 0
	If nTp <> 2 .or. oLbIntVei:nAt > len(aIntVei)
		oLbIntVei:nAt := 1
	EndIf
	oLbIntVei:SetArray(aIntVei)
	oLbIntVei:bLine := { || {IIf(aIntVei[oLbIntVei:nAt,01]=="0",overm,IIf(aIntVei[oLbIntVei:nAt,01]=="1",olara,overd)),;
						aIntVei[oLbIntVei:nAt,02] ,;
						aIntVei[oLbIntVei:nAt,03]+" - "+aIntVei[oLbIntVei:nAt,04] ,;
						aIntVei[oLbIntVei:nAt,05] ,;
						FG_AlinVlrs(Transform(aIntVei[oLbIntVei:nAt,06],"@E 999,999")) ,;
						Transform(aIntVei[oLbIntVei:nAt,07],"@D") ,;
						aIntVei[oLbIntVei:nAt,12] ,;
						aIntVei[oLbIntVei:nAt,08] ,;
						aIntVei[oLbIntVei:nAt,09] ,;
						aIntVei[oLbIntVei:nAt,10] ,;
						aIntVei[oLbIntVei:nAt,11] }}
	oLbIntVei:Refresh()
EndIf
DbSelectArea("VDM")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_VEICULOS ³ Autor ³ Andre Luis Almeida  ³ Data ³ 20/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Listar Veiculos do Estoque                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEICULOS(nLinha)
Local ni := 0
aVeiEst := {}
For ni := 1 to len(aVeiTot)
	If nLinha == aVeiTot[ni,9]
		aAdd(aVeiEst,aClone(aVeiTot[ni]))
	EndIf
Next
If len(aVeiEst) <= 0
	Aadd(aVeiEst,{"0","","","","","","","",0})
EndIf     
oLbVeiEst:nAt := 1
oLbVeiEst:SetArray(aVeiEst)
oLbVeiEst:bLine := { || {IIf(aVeiEst[oLbVeiEst:nAt,1]=="0",overm,IIf(aVeiEst[oLbVeiEst:nAt,1]=="1",olara,overd)),;
						aVeiEst[oLbVeiEst:nAt,2] ,;
						aVeiEst[oLbVeiEst:nAt,3] ,;
						aVeiEst[oLbVeiEst:nAt,4]+" - "+aVeiEst[oLbVeiEst:nAt,5] ,;
						aVeiEst[oLbVeiEst:nAt,6] ,;
						aVeiEst[oLbVeiEst:nAt,7] ,;
						aVeiEst[oLbVeiEst:nAt,8] }}
oLbVeiEst:Refresh()
Return(.t.)