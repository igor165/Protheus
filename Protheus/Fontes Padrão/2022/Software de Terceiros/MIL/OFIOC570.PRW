// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#INCLUDE "OFIOC570.ch"

Static cPrefOFI := GetNewPar("MV_PREFOFI","OFI") // F2_PREFORI
Static cPrefBAL := GetNewPar("MV_PREFBAL","BAL") // F2_PREFORI

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC570 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta do Potencial de Venda de Pecas e Servicos p/Frota ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cXCodCli = Codigo do Cliente                               ³±±
±±³ (filtro) ³ cXLojCli = Loja do Cliente                                 ³±±
±±³          ³ cXFilVda = Filial de Venda                                 ³±±
±±³          ³ cXMesIni = Mes Inicial                                     ³±±
±±³          ³ cXAnoIni = Ano Inicial                                     ³±±
±±³          ³ cXMesFin = Mes Final                                       ³±±
±±³          ³ cXAnoFin = Ano Final                                       ³±±
±±³          ³ cXCodMar = Marca do Veiculo                                ³±±
±±³          ³ cXModVei = Modelo do Veiculo                               ³±±
±±³          ³ cXAnoMod = Ano Modelo do Veiculo                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC570(cXCodCli,cXLojCli,cXFilVda,cXMesIni,cXAnoIni,cXMesFin,cXAnoFin,cXCodMar,cXModVei,cXAnoMod)
//////////////////////////////////////////////////
// Declarar variaveis                           //
//////////////////////////////////////////////////
Local aObjects   := {} , aInfo := {} , aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nLin       := 0
//
MsgStop(STR0027)
Return()
//
Private cLCodCli := space(TamSX3("VQJ_CODCLI")[1])
Private cLLojCli := space(TamSX3("VQJ_LOJCLI")[1])
Private cLNomCli := ""
Private cLFilVda := space(TamSX3("VQJ_FILVDA")[1])
Private aLFilVda := {}
Private cLMesIni := strzero(Month(dDataBase),2)
Private cLAnoIni := strzero(year(dDataBase),4)
Private cLMesFin := strzero(Month(dDataBase),2)
Private cLAnoFin := strzero(year(dDataBase),4)
Private aMesPot  := X3CBOXAVET("VQJ_MESPOT","0")
Private aAnoPot  := {}
Private cLCodMar := space(TamSX3("VQJ_CODMAR")[1])
Private cLModVei := space(TamSX3("VQJ_MODVEI")[1])
Private cLAnoMod := space(TamSX3("VQJ_ANOMOD")[1])
Private aAnoMod  := {}
Private M->VV1_CODMAR := "" // Compatibilidade com o SXB (MCV)
Private aVQJ     := {}
Private aVC3     := {}
//////////////////////////////////////////////////
// Carregar parametros passados para o filtro   //
//////////////////////////////////////////////////
Default cXCodCli := cLCodCli
Default cXLojCli := cLLojCli
Default cXFilVda := cLFilVda
Default cXMesIni := cLMesIni
Default cXAnoIni := cLAnoIni
Default cXMesFin := cLMesFin
Default cXAnoFin := cLAnoFin
Default cXCodMar := cLCodMar
Default cXModVei := cLModVei
Default cXAnoMod := cLAnoMod

//////////////////////////////////////////////////
// Preencher variaveis com os parametros        //
//////////////////////////////////////////////////
cLCodCli := cXCodCli
cLLojCli := cXLojCli
cLFilVda := cXFilVda
cLMesIni := cXMesIni
cLAnoIni := cXAnoIni
cLMesFin := cXMesFin
cLAnoFin := cXAnoFin
cLCodMar := cXCodMar
cLModVei := cXModVei
cLAnoMod := cXAnoMod
If !Empty(cLCodCli+cLLojCli)
	If !FS_VALID(0) // Codigo Cliente + Loja Cliente
		Return()
	EndIf
EndIf
//////////////////////////////////////////////////
// Filtrar registros ( Frota x Potencial )      //
//////////////////////////////////////////////////
FS_FILTRO(0)
//////////////////////////////////////////////////
// Tela de Apresentacao ( Frota x Potencial )   //
//////////////////////////////////////////////////
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  53 , .T. , .F. } ) // Campos (Filtros)
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox ( Potencial )
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox ( Frota )
aPos := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oOC570Dlg FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta do Potencial de Venda de Peças e Serviços por Frota
oOC570Dlg:lEscClose := .F.

@ aPos[1,1],aPos[1,2] TO aPos[1,3],aPos[1,4] LABEL STR0002 OF oOC570Dlg PIXEL // Filtro

nLin := 10
@ aPos[1,1]+nLin+001,aPos[1,2]+005 SAY (STR0004+":") SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // Cliente
@ aPos[1,1]+nLin+000,aPos[1,2]+045 MSGET oLCodCli VAR cLCodCli PICTURE "@!" VALID FS_VALID(1) F3 "SA1" SIZE 40,08 OF oOC570Dlg PIXEL COLOR CLR_BLUE HASBUTTON
@ aPos[1,1]+nLin+000,aPos[1,2]+085 MSGET oLLojCli VAR cLLojCli PICTURE "@!" VALID FS_VALID(2) SIZE 20,08 OF oOC570Dlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+nLin+000,aPos[1,2]+110 MSGET oLNomCli VAR cLNomCli PICTURE "@!" SIZE 290,08 OF oOC570Dlg PIXEL COLOR CLR_BLUE WHEN .f.

nLin += 14
 
@ aPos[1,1]+nLin+001,aPos[1,2]+005 SAY (STR0007+":") SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // Periodo
@ aPos[1,1]+nLin+000,aPos[1,2]+045 MSCOMBOBOX oLMesIni VAR cLMesIni SIZE 55,08 ITEMS aMesPot OF oOC570Dlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+nLin+001,aPos[1,2]+110 SAY STR0009 SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // de
@ aPos[1,1]+nLin+000,aPos[1,2]+120 MSCOMBOBOX oLAnoIni VAR cLAnoIni SIZE 30,08 ITEMS aAnoPot OF oOC570Dlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+nLin+001,aPos[1,2]+155 SAY STR0008 SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // ate
@ aPos[1,1]+nLin+000,aPos[1,2]+170 MSCOMBOBOX oLMesFin VAR cLMesFin SIZE 55,08 ITEMS aMesPot OF oOC570Dlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+nLin+001,aPos[1,2]+230 SAY STR0009 SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // de
@ aPos[1,1]+nLin+000,aPos[1,2]+245 MSCOMBOBOX oLAnoFin VAR cLAnoFin SIZE 30,08 ITEMS aAnoPot OF oOC570Dlg PIXEL COLOR CLR_BLUE

if TYPE("aSelFil") == "U" 
	@ aPos[1,1]+nLin+001,aPos[1,2]+285 SAY (STR0006+":") SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // Filial Venda
	@ aPos[1,1]+nLin+000,aPos[1,2]+320 MSCOMBOBOX oLFilVda VAR cLFilVda SIZE 80,08 ITEMS aLFilVda OF oOC570Dlg PIXEL COLOR CLR_BLUE
Endif

nLin += 14
@ aPos[1,1]+nLin+001,aPos[1,2]+005 SAY (STR0010+"/"+STR0015+":") SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // Marca/Modelo
@ aPos[1,1]+nLin+000,aPos[1,2]+045 MSGET oLCodMar VAR cLCodMar PICTURE "@!" VALID FS_VALID(3) F3 "VE1" SIZE 40,08 OF oOC570Dlg PIXEL COLOR CLR_BLUE HASBUTTON
@ aPos[1,1]+nLin+000,aPos[1,2]+085 MSGET oLModVei VAR cLModVei PICTURE "@!" VALID FS_VALID(4) F3 "MCV" SIZE 80,08 OF oOC570Dlg PIXEL COLOR CLR_BLUE HASBUTTON
@ aPos[1,1]+nLin+001,aPos[1,2]+205 SAY (STR0013+":") SIZE 50,8 OF oOC570Dlg PIXEL COLOR CLR_BLUE // Ano Modelo
@ aPos[1,1]+nLin+000,aPos[1,2]+240 MSCOMBOBOX oLAnoMod VAR cLAnoMod SIZE 30,08 ITEMS aAnoMod OF oOC570Dlg PIXEL COLOR CLR_BLUE

@ aPos[1,1]+nLin+000,aPos[1,2]+345 BUTTON oFiltrar PROMPT STR0014 OF oOC570Dlg SIZE 54,11 PIXEL ACTION FS_FILTRO(1) // Filtrar

@ aPos[2,1]+000,aPos[2,2] TO aPos[2,3],aPos[2,4] LABEL STR0021 OF oOC570Dlg PIXEL // Potencial
@ aPos[2,1]+008,aPos[2,2] LISTBOX oLbVQJ FIELDS HEADER STR0010,STR0015,STR0013,STR0004,STR0016,STR0017,STR0018,STR0019,STR0020 COLSIZES 20,60,35,110,20,20,80,90,90 SIZE aPos[2,4]-3,aPos[2,3]-aPos[2,1]-008 OF oOC570Dlg PIXEL ON CHANGE FS_VC3(1,oLbVQJ:nAt)
oLbVQJ:SetArray(aVQJ)
oLbVQJ:bLine := { || { 	aVQJ[oLbVQJ:nAt,01] ,;
					 	aVQJ[oLbVQJ:nAt,02] ,;
					 	aVQJ[oLbVQJ:nAt,03] ,;
					 	aVQJ[oLbVQJ:nAt,04]+"-"+aVQJ[oLbVQJ:nAt,05]+" "+aVQJ[oLbVQJ:nAt,06] ,;
					 	aVQJ[oLbVQJ:nAt,07] ,;
					 	aVQJ[oLbVQJ:nAt,08] ,;
					 	aVQJ[oLbVQJ:nAt,09] ,;
					 	FG_AlinVlrs(Transform(aVQJ[oLbVQJ:nAt,10],"@E 999,999,999.99")) ,;
						FG_AlinVlrs(Transform(aVQJ[oLbVQJ:nAt,11],"@E 999,999,999.99")) }}

@ aPos[3,1]+000,aPos[3,2] TO aPos[3,3],aPos[3,4] LABEL STR0022 OF oOC570Dlg PIXEL // Frota x Potencial x Realizado
@ aPos[3,1]+008,aPos[3,2] LISTBOX oLbVC3 FIELDS HEADER STR0004,STR0023,STR0024,STR0019,STR0025,STR0020,STR0026 COLSIZES 110,25,25,60,90,60,90 SIZE aPos[3,4]-3,aPos[3,3]-aPos[3,1]-008 OF oOC570Dlg PIXEL
oLbVC3:SetArray(aVC3)
oLbVC3:bLine := { || { 	aVC3[oLbVC3:nAt,01]+"-"+aVC3[oLbVC3:nAt,02]+" "+aVC3[oLbVC3:nAt,03] ,;
					 	Transform(aVC3[oLbVC3:nAt,04],"@R 9999/9999") ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,05],"@E 999,999")) ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,06],"@E 999,999,999.99")) ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,07],"@E 999,999,999.99"))+" "+FG_AlinVlrs(Transform((aVC3[oLbVC3:nAt,07]/aVC3[oLbVC3:nAt,06])*100,"@E 9999.9")+"%") ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,08],"@E 999,999,999.99")) ,;
						FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,09],"@E 999,999,999.99"))+" "+FG_AlinVlrs(Transform((aVC3[oLbVC3:nAt,09]/aVC3[oLbVC3:nAt,08])*100,"@E 9999.9")+"%") }}

ACTIVATE MSDIALOG oOC570Dlg ON INIT EnchoiceBar(oOC570Dlg,{ || oOC570Dlg:End() }, { || oOC570Dlg:End() },,)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRO³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantar/Filtrar registros                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRO(nTp)
Local lOk     := .f.
Local ni      := 0
Local cQuery  := ""
Local cQAlSQL := "SQLALIAS"
If nTp == 0 // Inicial
	// Filiais Venda
	aLFilVda := {''}
	cQuery := "SELECT DISTINCT F2_FILIAL FROM "+RetSqlName("SF2")+" WHERE F2_FILIAL='"+xFilial("SF2")+"' AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		aAdd(aLFilVda,( cQAlSQL )->( F2_FILIAL ))
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	// Ano Potencial
	For ni := 0 to 9
		aAdd(aAnoPot,strzero(year(dDataBase)-ni,4))
	Next
	// Ano Modelo
	aAnoMod := {''}
	aAdd(aAnoMod,strzero(year(dDataBase)+1,4))
	For ni := 0 to 50
		aAdd(aAnoMod,strzero(year(dDataBase)-ni,4))
	Next
EndIf
// Levanta/Filtra registros
aVQJ   := {}
cQuery := "SELECT VQJ.* , SA1.A1_NOME FROM "+RetSqlName("VQJ")+" VQJ "
cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQJ.VQJ_CODCLI AND SA1.A1_LOJA=VQJ.VQJ_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VQJ.VQJ_FILIAL='"+xFilial("VQJ")+"' AND "
If !Empty(cLCodCli+cLLojCli)
	cQuery += "( VQJ.VQJ_CODCLI=' ' OR ( VQJ.VQJ_CODCLI='"+cLCodCli+"' AND VQJ.VQJ_LOJCLI='"+cLLojCli+"' ) ) AND "
EndIf
If !Empty(cLFilVda)
	cQuery += "( VQJ.VQJ_FILVDA=' ' OR VQJ.VQJ_FILVDA='"+cLFilVda+"' ) AND "
EndIf
If !Empty(cLCodMar)
	cQuery += "( VQJ.VQJ_CODMAR=' ' OR VQJ.VQJ_CODMAR='"+cLCodMar+"' ) AND "
EndIf
If !Empty(cLModVei)
	cQuery += "( VQJ.VQJ_MODVEI=' ' OR VQJ.VQJ_MODVEI='"+cLModVei+"' ) AND "
EndIf
If !Empty(cLAnoMod)
	cQuery += "( VQJ.VQJ_ANOMOD=' ' OR VQJ.VQJ_ANOMOD='"+cLAnoMod+"' ) AND "
EndIf
cQuery += "VQJ.D_E_L_E_T_=' ' ORDER BY VQJ.VQJ_CODMAR , VQJ.VQJ_MODVEI , VQJ.VQJ_MESPOT , VQJ.VQJ_ANOPOT , VQJ.VQJ_FILVDA , VQJ.VQJ_CODCLI , VQJ.VQJ_LOJCLI"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	lOk := .f.
	If Empty(( cQAlSQL )->( VQJ_MESPOT ))
		If cLAnoIni <= ( cQAlSQL )->( VQJ_ANOPOT ) .and. cLAnoFin >= ( cQAlSQL )->( VQJ_ANOPOT )
			lOk := .t.
		EndIf
	Else
		If ( cLAnoIni+cLMesIni <= ( cQAlSQL )->( VQJ_ANOPOT )+( cQAlSQL )->( VQJ_MESPOT ) ) .and. ( cLAnoFin+cLMesFin >= ( cQAlSQL )->( VQJ_ANOPOT )+( cQAlSQL )->( VQJ_MESPOT ) )
			lOk := .t.
		EndIf
	EndIf
	If lOk
		aAdd(aVQJ,{( cQAlSQL )->( VQJ_CODMAR ) , ( cQAlSQL )->( VQJ_MODVEI ) , ( cQAlSQL )->( VQJ_ANOMOD ) , ( cQAlSQL )->( VQJ_CODCLI ) , ( cQAlSQL )->( VQJ_LOJCLI ) , ( cQAlSQL )->( A1_NOME ) , ( cQAlSQL )->( VQJ_MESPOT ) , ( cQAlSQL )->( VQJ_ANOPOT ) , ( cQAlSQL )->( VQJ_FILVDA ) , ( cQAlSQL )->( VQJ_VALPEC ) , ( cQAlSQL )->( VQJ_VALSRV ) , .t. }) 
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
If len(aVQJ) <= 0
	aAdd(aVQJ,{ "" , "" , "" , "" , "" , "" , "" , "" , "" , 0 , 0 , .f. })
EndIf
If nTp > 0
	oLbVQJ:nAt := 1
	oLbVQJ:SetArray(aVQJ)
	oLbVQJ:bLine := { || { 	aVQJ[oLbVQJ:nAt,01] ,;
					 	aVQJ[oLbVQJ:nAt,02] ,;
					 	aVQJ[oLbVQJ:nAt,03] ,;
					 	aVQJ[oLbVQJ:nAt,04]+"-"+aVQJ[oLbVQJ:nAt,05]+" "+aVQJ[oLbVQJ:nAt,06] ,;
					 	aVQJ[oLbVQJ:nAt,07] ,;
					 	aVQJ[oLbVQJ:nAt,08] ,;
					 	aVQJ[oLbVQJ:nAt,09] ,;
					 	FG_AlinVlrs(Transform(aVQJ[oLbVQJ:nAt,10],"@E 999,999,999.99")) ,;
						FG_AlinVlrs(Transform(aVQJ[oLbVQJ:nAt,11],"@E 999,999,999.99")) }}
	oLbVQJ:Refresh()
EndIf
FS_VC3(nTp,1)
DbSelectArea("VQJ")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VC3   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 22/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento VC3                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VC3(nTp,nLin)
//
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
//
Local cNamVC3    := RetSqlName("VC3")
Local cNamSA1    := RetSqlName("SA1")
Local cNamSD2    := RetSqlName("SD2")
Local cNamSD1    := RetSqlName("SD1")
Local cNamSF2    := RetSqlName("SF2")
Local cNamVS1    := RetSqlName("VS1")
Local cNamVOO    := RetSqlName("VOO")
Local cNamVOI    := RetSqlName("VOI")
Local cNamVO1    := RetSqlName("VO1")
Local cNamVV1    := RetSqlName("VV1")
Local cNamSF4    := RetSQLName("SF4")
//
Local cFilSD1    := ""
Local cFilSF2    := ""
Local cFilVS1    := ""
Local cFilVOO    := ""
Local cFilVOI    := ""
Local cFilVO1    := ""
Local cFilVV1    := ""
Local cFilSF4    := ""
//
Local cQuery     := ""
Local cQAlSQL    := "SQLALIAS"
Local cQAlAux    := "SQLAUX"
//
Local cAuxAnoMod := cLAnoMod // Filtra Ano Modelo
Local cAuxCodCli := cLCodCli // Filtra Codigo Cliente
Local cAuxLojCli := cLLojCli // Filtra Loja Cliente
Local sDatIni    := aVQJ[nLin,08]+"0101" // Anual
Local sDatFin    := aVQJ[nLin,08]+"1231" // Anual
Local nVlrPec    := 0
Local nVlrSrv    := 0
//
aVC3 := {}
If aVQJ[nLin,12] // valido
	If !Empty(aVQJ[nLin,03])
		cAuxAnoMod := aVQJ[nLin,03] // Filtra Ano Modelo
	EndIf
	If !Empty(aVQJ[nLin,04])
		cAuxCodCli := aVQJ[nLin,04] // Filtra Codigo Cliente
		cAuxLojCli := aVQJ[nLin,05] // Filtra Loja Cliente
	EndIf
	If !Empty(aVQJ[nLin,07]) // Mes
		sDatIni := aVQJ[nLin,08]+aVQJ[nLin,07]+"01"
		If aVQJ[nLin,07] <> "12"
			sDatFin := dtos(stod(aVQJ[nLin,08]+strzero(val(aVQJ[nLin,07])+1,2)+"01")-1)
		EndIf
	EndIf

	if TYPE("aSelFil") == "U" 
		If !Empty(aVQJ[nLin,09])
			aSM0 := {aVQJ[nLin,09]} // Somente a Filial Venda
		EndIf
		aSelFil := aClone(aSM0)
	Endif 
	
	cQuery := "SELECT VC3.VC3_CODCLI , VC3.VC3_LOJA , SA1.A1_NOME , VC3.VC3_FABMOD , VC3.VC3_QTDFRO FROM "+cNamVC3+" VC3 "
	cQuery += "LEFT JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC3.VC3_CODCLI AND SA1.A1_LOJA=VC3.VC3_LOJA AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VC3.VC3_FILIAL='"+xFilial("VC3")+"' AND "
	If !Empty(cAuxCodCli+cAuxLojCli)
		cQuery += "( VC3.VC3_CODCLI='"+cAuxCodCli+"' AND VC3.VC3_LOJA='"+cAuxLojCli+"' ) AND " // Filtra Cliente
	EndIf
	cQuery += "VC3.VC3_CODMAR='"+aVQJ[nLin,1]+"' AND "
	cQuery += "VC3.VC3_MODVEI='"+aVQJ[nLin,2]+"' AND "
	If !Empty(cAuxAnoMod)
		cQuery += "VC3.VC3_FABMOD LIKE '%"+cAuxAnoMod+"' AND " // Filtra Ano Modelo
	EndIf
	cQuery += "VC3.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		//
		nVlrPec := 0
		nVlrSrv := 0
		//
		For nCont := 1 to Len(aSelFil)
			//
			cFilAnt := aSelFil[nCont]
			//
			cFilSD1 := xFilial("SD1")
			cFilSF2 := xFilial("SF2")
			cFilVS1 := xFilial("VS1")
			cFilVOO := xFilial("VOO")
			cFilVOI := xFilial("VOI")
			cFilVO1 := xFilial("VO1")
			cFilVV1 := xFilial("VV1")
			cFilSF4 := xFilial("SF4")
			//
			//////////////////////
			// PECAS BALCAO     //
			//////////////////////
			cQuery := "SELECT SD2.D2_DOC , SD2.D2_SERIE , SUM(SD2.D2_TOTAL) TOTAL FROM "+cNamSD2+" SD2 "
			cQuery += "JOIN "+cNamSF2+" SF2 ON ( SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_PREFORI='"+cPrefBAL+"' AND SF2.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamSF4+" SF4 ON ( SF4.F4_FILIAL='"+cFilSF4+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_ = ' ' ) "
			cQuery += "JOIN "+cNamVS1+" VS1 ON ( VS1.VS1_FILIAL='"+cFilVS1+"' AND VS1.VS1_NUMNFI=SD2.D2_DOC AND VS1.VS1_SERNFI=SD2.D2_SERIE AND VS1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+cFilVV1+"' AND VV1.VV1_CHAINT=VS1.VS1_CHAINT AND VV1.VV1_CODMAR='"+aVQJ[nLin,1]+"' AND VV1.VV1_MODVEI='"+aVQJ[nLin,2]+"' AND "
			If !Empty(( cQAlSQL )->( VC3_FABMOD ))
				cQuery += "VV1.VV1_FABMOD='"+( cQAlSQL )->( VC3_FABMOD )+"' AND "
			EndIf
			cQuery += "VV1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
			cQuery += "SD2.D2_CLIENTE='"+( cQAlSQL )->( VC3_CODCLI )+"' AND SD2.D2_LOJA='"+( cQAlSQL )->( VC3_LOJA )+"' AND " // Filtra Cliente
			cQuery += "SD2.D2_EMISSAO>='"+sDatIni+"' AND SD2.D2_EMISSAO<='"+sDatFin+"' AND " // Filtra Periodo
			cQuery += "SD2.D_E_L_E_T_=' ' GROUP BY SD2.D2_DOC , SD2.D2_SERIE"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
			While !( cQAlAux )->( Eof() )
				cQuery := "SELECT SUM(SD1.D1_TOTAL) DEV FROM "+cNamSD1+" SD1 WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND "
				cQuery += "SD1.D1_NFORI='"+( cQAlAux )->( D2_DOC )+"' AND SD1.D1_SERIORI='"+( cQAlAux )->( D2_SERIE )+"' AND SD1.D_E_L_E_T_=' '"
				//
				nVlrPec += ( cQAlAux )->( TOTAL ) - FM_SQL(cQuery) // SD2 ( vendas ) - SD1 ( devolucao )
				//
				( cQAlAux )->( DbSkip() )
			EndDo
			( cQAlAux )->( DbCloseArea() )
			//			
			//////////////////////
			// PECAS OFICINA    //
			//////////////////////
			cQuery := "SELECT VOO.VOO_NUMNFI , VOO.VOO_SERNFI , SUM(VOO.VOO_TOTPEC) TOTAL FROM "+cNamVOO+" VOO "
			cQuery += "JOIN "+cNamSF2+" SF2 ON ( SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC=VOO.VOO_NUMNFI AND SF2.F2_SERIE=VOO.VOO_SERNFI AND SF2.F2_EMISSAO>='"+sDatIni+"' AND SF2.F2_EMISSAO<='"+sDatFin+"' AND SF2.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVOI+" VOI ON ( VOI.VOI_FILIAL='"+cFilVOI+"' AND VOI.VOI_TIPTEM=VOO.VOO_TIPTEM AND VOI.VOI_SITTPO<>'3' AND VOI.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVO1+" VO1 ON ( VO1.VO1_FILIAL='"+cFilVO1+"' AND VO1.VO1_NUMOSV=VOO.VOO_NUMOSV AND VO1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+cFilVV1+"' AND VV1.VV1_CHASSI=VO1.VO1_CHASSI AND VV1.VV1_CODMAR='"+aVQJ[nLin,1]+"' AND VV1.VV1_MODVEI='"+aVQJ[nLin,2]+"' AND "
			If !Empty(( cQAlSQL )->( VC3_FABMOD ))
				cQuery += "VV1.VV1_FABMOD='"+( cQAlSQL )->( VC3_FABMOD )+"' AND "
			EndIf
			cQuery += "VV1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VOO.VOO_FILIAL='"+cFilVOO+"' AND "
			cQuery += "VOO.VOO_FATPAR='"+( cQAlSQL )->( VC3_CODCLI )+"' AND VOO.VOO_LOJA='"+( cQAlSQL )->( VC3_LOJA )+"' AND " // Filtra Cliente
			cQuery += "VOO.VOO_NUMNFI<>' ' AND "
			cQuery += "VOO.D_E_L_E_T_=' ' GROUP BY VOO.VOO_NUMNFI , VOO.VOO_SERNFI"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
			While !( cQAlAux )->( Eof() )
				cQuery := "SELECT SUM(SD1.D1_TOTAL) DEV FROM "+cNamSD1+" SD1 WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND "
				cQuery += "SD1.D1_NFORI='"+( cQAlAux )->( VOO_NUMNFI )+"' AND SD1.D1_SERIORI='"+( cQAlAux )->( VOO_SERNFI )+"' AND SD1.D_E_L_E_T_=' '"
				//
				nVlrPec += ( cQAlAux )->( TOTAL ) - FM_SQL(cQuery) // VOO ( vendas ) - SD1 ( devolucao )
				//
				( cQAlAux )->( DbSkip() )
			EndDo
			( cQAlAux )->( DbCloseArea() )
			//			
			//////////////////////
			// SERVICOS OFICINA //
			//////////////////////
			cQuery := "SELECT SUM(VOO.VOO_TOTSRV) TOTAL FROM "+cNamVOO+" VOO "
			cQuery += "JOIN "+cNamSF2+" SF2 ON ( SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC=VOO.VOO_NUMNFI AND SF2.F2_SERIE=VOO.VOO_SERNFI AND SF2.F2_EMISSAO>='"+sDatIni+"' AND SF2.F2_EMISSAO<='"+sDatFin+"' AND SF2.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVOI+" VOI ON ( VOI.VOI_FILIAL='"+cFilVOI+"' AND VOI.VOI_TIPTEM=VOO.VOO_TIPTEM AND VOI.VOI_SITTPO<>'3' AND VOI.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVO1+" VO1 ON ( VO1.VO1_FILIAL='"+cFilVO1+"' AND VO1.VO1_NUMOSV=VOO.VOO_NUMOSV AND VO1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+cFilVV1+"' AND VV1.VV1_CHASSI=VO1.VO1_CHASSI AND VV1.VV1_CODMAR='"+aVQJ[nLin,1]+"' AND VV1.VV1_MODVEI='"+aVQJ[nLin,2]+"' AND "
			If !Empty(( cQAlSQL )->( VC3_FABMOD ))
				cQuery += "VV1.VV1_FABMOD='"+( cQAlSQL )->( VC3_FABMOD )+"' AND "
			EndIf
			cQuery += "VV1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VOO.VOO_FILIAL='"+cFilVOO+"' AND "
			cQuery += "VOO.VOO_FATPAR='"+( cQAlSQL )->( VC3_CODCLI )+"' AND VOO.VOO_LOJA='"+( cQAlSQL )->( VC3_LOJA )+"' AND " // Filtra Cliente
			cQuery += "VOO.VOO_NUMNFI<>' ' AND "
			cQuery += "VOO.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
			While !( cQAlAux )->( Eof() )
				//
				nVlrSrv += ( cQAlAux )->( TOTAL ) // VOO ( servicos )
				//
				( cQAlAux )->( DbSkip() )
			EndDo
			( cQAlAux )->( DbCloseArea() )
			//
		Next
   		//
		aAdd(aVC3,{ ( cQAlSQL )->( VC3_CODCLI ) , ( cQAlSQL )->( VC3_LOJA ) , ( cQAlSQL )->( A1_NOME ) , ( cQAlSQL )->( VC3_FABMOD ) , ( cQAlSQL )->( VC3_QTDFRO ) , ( cQAlSQL )->( VC3_QTDFRO )*aVQJ[nLin,10] , nVlrPec , ( cQAlSQL )->( VC3_QTDFRO )*aVQJ[nLin,11] , nVlrSrv })
   		//
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	//
	cFilAnt := cBkpFilAnt
	//
EndIf
If len(aVC3) <= 0
	aAdd(aVC3,{ "" , "" , "" , "" , 0 , 0 , 0 , 0 , 0 })
EndIf
If nTp > 0
	oLbVC3:nAt := 1
	oLbVC3:SetArray(aVC3)
	oLbVC3:bLine := { || { 	aVC3[oLbVC3:nAt,01]+"-"+aVC3[oLbVC3:nAt,02]+" "+aVC3[oLbVC3:nAt,03] ,;
					 	Transform(aVC3[oLbVC3:nAt,04],"@R 9999/9999") ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,05],"@E 999,999")) ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,06],"@E 999,999,999.99")) ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,07],"@E 999,999,999.99"))+" "+FG_AlinVlrs(Transform((aVC3[oLbVC3:nAt,07]/aVC3[oLbVC3:nAt,06])*100,"@E 9999.9")+"%") ,;
					 	FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,08],"@E 999,999,999.99")) ,;
						FG_AlinVlrs(Transform(aVC3[oLbVC3:nAt,09],"@E 999,999,999.99"))+" "+FG_AlinVlrs(Transform((aVC3[oLbVC3:nAt,09]/aVC3[oLbVC3:nAt,08])*100,"@E 9999.9")+"%") }}
	oLbVC3:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALID ³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos campos na tela                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALID(nTp)
Local lRet := .t.
If nTp <= 2 // 1.Codigo Cliente / 2.Loja Cliente
	cLNomCli := ""
	If Empty(cLCodCli)
		cLLojCli := space(TamSX3("VQJ_LOJCLI")[1])
	Else
		lRet := .f.
		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+cLCodCli+cLLojCli))
			lRet := .t.
			cLNomCli := SA1->A1_NOME
		ElseIf nTp == 1 .and. SA1->(MsSeek(xFilial("SA1")+cLCodCli))
			lRet := .t.
			cLLojCli := SA1->A1_LOJA
			cLNomCli := SA1->A1_NOME
		EndIf
		If !lRet
			MsgStop(STR0005,STR0003) // Cliente nao encontrado! / Atencao
		EndIf
	EndIf
	If nTp > 0
		oLLojCli:Refresh()
		oLNomCli:Refresh()
	EndIf
ElseIf nTp == 3 // 3.Marca
	M->VV1_CODMAR := "" // Compatibilidade com o SXB (MCV)
	cLModVei := space(TamSX3("VQJ_MODVEI")[1])
	oLModVei:Refresh()
	If !Empty(cLCodMar)
		lRet := .f.
		VE1->(DbSetOrder(1))
		If VE1->(MsSeek(xFilial("VE1")+cLCodMar))
			lRet := .t.
			M->VV1_CODMAR := cLCodMar
		Else
			MsgStop(STR0011,STR0003) // Marca nao encontrada! / Atencao
		EndIf
	EndIf
ElseIf nTp == 4 // 4.Modelo
	If !Empty(cLModVei)
		lRet := .f.
		VV2->(DbSetOrder(1))
		If VV2->(MsSeek(xFilial("VV2")+cLCodMar+cLModVei))
			lRet := .t.
		Else
			MsgStop(STR0012,STR0003) // Modelo nao encontrado! / Atencao
		EndIf
	EndIf
EndIf
Return(lRet)