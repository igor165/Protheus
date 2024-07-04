// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 30     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOM410.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  08/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006574_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³OFIOM410³ Autor ³ Andre Luis Almeida       ³ Data ³ 04/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao:                                                             ³±±
±±³(1) Central para Geracao das Listas de Contato, por:                   ³±±
±±³        - KM / Tempo (Revisoes)                                        ³±±
±±³        - Vendas ou Passagens Oficina                                  ³±±
±±³        - Clientes que estao sem comprar                               ³±±
±±³        - Check-List Oficina                                           ³±±
±±³        - Clientes pela Data de Cadastro no CEV                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³(2) FS_LEVKM  - Geracao por "KM / Tempo (Revisoes)"                    ³±±
±±³(3) FS_LEVSC  - Geracao por "Clientes que estao sem comprar"           ³±±
±±³(4) FS_LEVCEV - Geracao por "Clientes pela Data de Cadastro no CEV"    ³±±
±±³(5) OFIOM410CLI - Tela para selecionar clientes e criar lista contatos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Oficina/CEV                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM410()
Local aRet := {}
Local aParamBox  := {} // ParamBox
Local aCheckBox  := {}
Private cObjetiv := "" // Objetivo da Visista/Agenda
Private cTmpNeg  := "F"
Private oTempNeg := Nil
Private olblTemp := Nil
If ( VCF->(FieldPos("VCF_DATCAD")) > 0 )
	aCheckBox := {STR0002,STR0003,STR0004,STR0005,STR0047} // KM / Tempo (Revisoes) / Vendas ou Passagens Oficina / Clientes que estao sem comprar / Check-List Oficina / Clientes pela Data de Cadastro no CEV
Else
	aCheckBox := {STR0002,STR0003,STR0004,STR0005} // KM / Tempo (Revisoes) / Vendas ou Passagens Oficina / Clientes que estao sem comprar / Check-List Oficina
EndIf
aAdd(aParamBox,{3,STR0001,1,aCheckBox,160,"",.F.})  // Geracao de Listas de Contato
While .t.
	dbSelectArea("VCF")
	If ParamBox(aParamBox,STR0001,@aRet,,,,,,,,.F.) // Geracao de Listas de Contato
		Do Case
			Case aRet[1] == 1
				cObjetiv := STR0002 // KM / Tempo (Revisoes)
				FS_LEVKM()
			Case aRet[1] == 2
				cObjetiv := STR0003 // Vendas ou Passagens Oficina
				VEICC600()
			Case aRet[1] == 3
				cObjetiv := STR0004 // Clientes que estao sem comprar
				FS_LEVSC()
			Case aRet[1] == 4
				cObjetiv := STR0005 // Check-List Oficina
				OFIOA280G()
			Case aRet[1] == 5
				cObjetiv := STR0047 // Clientes pela Data de Cadastro no CEV
				FS_LEVCEV()
		EndCase
		aParambox[1,3] := aRet[1] // Grava ultima escolha do usuario.
	Else
		Exit
	EndIf
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_LEVKM³ Autor ³ Andre Luis Almeida       ³ Data ³ 04/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Geracao das Listas de Contato por KM / Tempo (Revisoes)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Oficina/CEV                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVKM()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0                         
////////////////////////////////////////////////////////////////////////////////////////////
Private nQtd       := 1
Private oNoTik     := LoadBitmap( GetResources(), "LBNO" )
Private oYesTik    := LoadBitmap( GetResources(), "LBTIK" )
Private nKMIni     := 0
Private nKMFin     := 99999999
Private nDiaIni    := 0
Private nDiaFin    := 999999
Private nCkRad1    := 1
Private aGrp       := {}
Private aMod       := {}
Private aConsidera := {{0,99999999,0,999999}}
Private cMarVeiF3  := space(3)
Private lMarcarV   := .t.
Private lA1_IBGE   := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)

FS_TIKKM(0) // Carrega Grupos e Modelos

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 20 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 10, 10, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oLEVKM TITLE STR0002 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL// KM / Tempo (Revisoes)

@ aPosObj[2,1]+009,aPosObj[2,2]+010 SAY STR0077 SIZE 30,10 OF oLEVKM PIXEL COLOR CLR_BLUE // Qtde:
@ aPosObj[2,1]+008,aPosObj[2,2]+030 MSGET oQtd VAR nQtd VALID FS_QDADE() PICTURE "999999" SIZE 40,8 OF oLEVKM PIXEL COLOR CLR_BLUE

@ aPosObj[2,1],aPosObj[2,2]+003 TO aPosObj[2,3]-10,(aPosObj[2,4]/2)-2 LABEL STR0036 OF oLEVKM PIXEL // "Considerar"
                                     
@ aPosObj[2,1],(aPosObj[2,4]/2) TO aPosObj[2,3]-10,aPosObj[2,4] LABEL STR0023 OF oLEVKM PIXEL // "Veiculo"
@ aPosObj[2,1]+012,(aPosObj[2,4]/2)+012 RADIO oRadio1 VAR nCkRad1 3D SIZE 40,10 PROMPT STR0037,STR0038 OF oLEVKM PIXEL ON CHANGE FS_TIKKM(nCkRad1) // "Grupos" / "Modelos"

//tela
@ aPosObj[2,1]+020,aPosObj[2,2]+005 LISTBOX oLbcons FIELDS HEADER STR0078,STR0079,STR0080,STR0081 COLSIZES 60,60,60,60 SIZE (aPosObj[2,4]/2)-aPosObj[2,2]-10,aPosObj[2,3]-aPosObj[1,3]-035 OF oLEVKM PIXEL ON DBLCLICK FS_SELECIONA(aConsidera,oLbcons:nAt) 
oLbcons:SetArray(aConsidera)
oLbcons:bLine := { || {Transform(aConsidera[oLbcons:nAt,1],"@E 999,999,999,999"),;
transform(aConsidera[oLbcons:nAt,2],"@E 999,999,999,999") ,;
transform(aConsidera[oLbcons:nAt,3],"@E 999999999") ,;
transform(aConsidera[oLbcons:nAt,4],"@E 999999999") }}

@ aPosObj[2,1]+007,(aPosObj[2,4]/2)+70 LISTBOX oLbGrp FIELDS HEADER "",STR0039,STR0040,STR0041 COLSIZES 10,25,40,80 SIZE (aPosObj[2,4]/2)-73,aPosObj[2,3]-aPosObj[1,3]-22 OF oLEVKM PIXEL ON DBLCLICK FS_TIKKM(10) // "Marca" / "Grupo" / "Descricao"
oLbGrp:SetArray(aGrp)
oLbGrp:bLine := { || {If(aGrp[oLbGrp:nAt,1],oYesTik,oNoTik),;
aGrp[oLbGrp:nAt,2] ,;
aGrp[oLbGrp:nAt,3] ,;
aGrp[oLbGrp:nAt,4] }}

@ aPosObj[2,1]+007,(aPosObj[2,4]/2)+70 LISTBOX oLbMod FIELDS HEADER "",STR0039,STR0042,STR0041 COLSIZES 10,25,40,80 SIZE (aPosObj[2,4]/2)-73,aPosObj[2,3]-aPosObj[1,3]-022 OF oLEVKM PIXEL ON DBLCLICK FS_TIKKM(20) // "Marca" / "Modelo" / "Descricao"
oLbMod:SetArray(aMod)
oLbMod:bLine := { || {If(aMod[oLbMod:nAt,1],oYesTik,oNoTik),;
aMod[oLbMod:nAt,2] ,;
aMod[oLbMod:nAt,3] ,;
aMod[oLbMod:nAt,4] }}
oLbMod:lVisible := .f.

@ aPosObj[2,3]-035,(aPosObj[2,4]/2)+008 BITMAP oxTik RESOURCE "LBTIK" OF oLEVKM NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[2,3]-035,(aPosObj[2,4]/2)+020 SAY oTitTik VAR STR0052 SIZE 100,10 OF oLEVKM PIXEL COLOR CLR_BLUE // selecionado
@ aPosObj[2,3]-024,(aPosObj[2,4]/2)+008 BITMAP oxNo  RESOURCE "LBNO" OF oLEVKM NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[2,3]-024,(aPosObj[2,4]/2)+020 SAY oTitNo  VAR STR0053 SIZE 100,10 OF oLEVKM PIXEL COLOR CLR_BLUE // nao selecionado

@ aPosObj[2,1]+008,(aPosObj[2,4]/2)+071 CHECKBOX oMarcarV VAR lMarcarV PROMPT "" OF oLEVKM ON CLICK If( FS_TIKKM( 30 , lMarcarV ) , .t. , ( lMarcarV:=!lMarcarV , oMarcarV:Refresh() ) ) SIZE 07,05 PIXEL COLOR CLR_BLUE

@ aPosObj[2,1]+050,(aPosObj[2,4]/2)+012 SAY oTitMarca VAR (STR0039+":") SIZE 55,10 OF oLEVKM PIXEL COLOR CLR_BLUE // Marca
@ aPosObj[2,1]+060,(aPosObj[2,4]/2)+012 MSGET oMarca VAR cMarVeiF3 VALID FS_TIKKM(9) F3 "VE1" PICTURE "@!" SIZE 20,8 OF oLEVKM PIXEL COLOR CLR_BLUE

DEFINE SBUTTON FROM aPosObj[1,1]+005,aPosObj[1,4]-60 TYPE 1 ACTION Processa( {|| FS_FILTRA() } ) ENABLE OF oLEVKM PIXEL
DEFINE SBUTTON FROM aPosObj[1,1]+005,aPosObj[1,4]-30 TYPE 2 ACTION oLEVKM:End() ENABLE OF oLEVKM PIXEL

ACTIVATE MSDIALOG oLEVKM
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_TIKKM ³ Autor ³ Andre Luis Almeida      ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik da tela quando Levantamento KM / Tempo (Revisoes)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKKM(nTipo,lMarcar)
Local cQuery  := ""
Local cQAlias := "SQLTAB"
Local ni := 0
Default lMarcar := .f.
Do Case
	Case nTipo == 1 // nCkRad1 == 1
		oLbGrp:lVisible := .t.
		oLbMod:lVisible := .f.
	Case nTipo == 2 // nCkRad1 == 2
		oLbGrp:lVisible := .f.
		oLbMod:lVisible := .t.
	Case nTipo == 10 // Selecionar Grupo do Modelo
		If !Empty(aGrp[oLbGrp:nAt,2])
			aGrp[oLbGrp:nAt,1]:=!aGrp[oLbGrp:nAt,1]
		EndIf
	Case nTipo == 20 // Selecionar Modelo
		If !Empty(aMod[oLbMod:nAt,2])
			aMod[oLbMod:nAt,1]:=!aMod[oLbMod:nAt,1]
		EndIf
	Case nTipo == 30 // TIK TOTAL
		For ni := 1 to Len(aGrp)
			If !Empty(aGrp[ni,3])
				aGrp[ni,1] := lMarcar
			EndIf
		Next
		For ni := 1 to Len(aMod)
			If !Empty(aMod[ni,3])
				aMod[ni,1] := lMarcar
			EndIf
		Next
		lMarcarV := lMarcar
		oLbGrp:Refresh()
		oLbMod:Refresh()
	Case nTipo == 0 .or. nTipo == 9 // Inicial ou Filtra pela Marca
		aGrp := {}
		aMod := {}
		cQuery := "SELECT VVR.* FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
		If !Empty(cMarVeiF3)
			cQuery += "VVR.VVR_CODMAR='"+cMarVeiF3+"' AND "
		EndIf
		cQuery += "VVR.D_E_L_E_T_=' ' ORDER BY VVR.VVR_CODMAR , VVR.VVR_GRUMOD "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				Aadd(aGrp,{ lMarcarV ,( cQAlias )->( VVR_CODMAR ),( cQAlias )->( VVR_GRUMOD ),( cQAlias )->( VVR_DESCRI )})
				( cQAlias )->( DbSkip() )
			EndDo
		Else
			Aadd(aGrp,{.f.,"","",""})
		EndIf
		( cQAlias )->( dbCloseArea() )
		cQuery := "SELECT VV2.* FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
		If !Empty(cMarVeiF3)
			cQuery += "VV2.VV2_CODMAR='"+cMarVeiF3+"' AND "
		EndIf
		cQuery += "VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_MODVEI "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				Aadd(aMod,{ lMarcarV ,( cQAlias )->( VV2_CODMAR ),( cQAlias )->( VV2_MODVEI ),( cQAlias )->( VV2_DESMOD )})
				( cQAlias )->( DbSkip() )
			EndDo
		Else
			Aadd(aMod,{.f.,"","",""})
		EndIf
		( cQAlias )->( dbCloseArea() )
		If nTipo == 9
			oLbGrp:nAt := 1
			oLbGrp:SetArray(aGrp)
			oLbGrp:bLine := { || {If(aGrp[oLbGrp:nAt,1],oYesTik,oNoTik),;
			aGrp[oLbGrp:nAt,2] ,;
			aGrp[oLbGrp:nAt,3] ,;
			aGrp[oLbGrp:nAt,4] }}
			oLbGrp:Refresh()
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || {If(aMod[oLbMod:nAt,1],oYesTik,oNoTik),;
			aMod[oLbMod:nAt,2] ,;
			aMod[oLbMod:nAt,3] ,;
			aMod[oLbMod:nAt,4] }}
			oLbMod:Refresh()
		EndIf
EndCase
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRA³ Autor ³ Andre Luis Almeida      ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levanta Clientes por KM / Tempo (Revisoes)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA() // LEVANTA CLIENTES
Local cTitulo := STR0002 // "KM / Tempo (Revisoes)"
Local cQuery  := ""
Local cQAlVV1 := "SQLVV1"
Local cQAlVO1 := "SQLVO1"
Local cQAlVOI := "SQLVOI"
Local cTipTem := "'*',"
Local cSA1    := ""
Local cSA1Nome:= ""
Local cSA1Fone:= ""
Local cChassi := ""
Local aModAux := {}
Local aGrpAux := {}
Local nPos    := 0
Local ni      := 0
Local cObsAge := ""
Local aAux    := {}
Local cAux    := ""
Local nDias   := 0
Local dDtRef  := dDataBase
Local nKmDia  := 0
Local nKmAtu  := 0
Local aClientes  := {}
Local cSGBD      := Upper(TcGetDb())
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nKmI       := 0
Local nKmF       := 0
Local nDiasI     := 0
Local nDiasF     := 0
Local nCont      := 0
Local cFilVO1    := "" 
Local cUltFil    := "" 
Local nFilial    := 4 
Local lxFilial   := xFilial("VO1") <> xFilial("VZB")    
Local lAddVet    := .f.
Local cFilAdd    := ""
Local _i         := 0
//
nFilial := Aviso(STR0071,STR0072+CHR(13) + CHR(10)+STR0073+CHR(13) + CHR(10)+STR0074+CHR(13) + CHR(10)+STR0075,{"[1]","[2]","[3]",STR0076})
if nFilial == 4
	Return(.f.)
Endif	
//
// Objetivo //
cObjetiv := STR0002+CHR(13)+CHR(10) // KM / Tempo (Revisoes)
//
// Filtrar somente Tipos de Tempo de Garantia/Revisao //
cQuery := "SELECT VOI.VOI_TIPTEM FROM "+RetSqlName("VOI")+" VOI WHERE VOI.VOI_FILIAL='"+xFilial("VOI")+"' "
cQuery += "AND VOI.VOI_SITTPO IN ('2','4') AND VOI.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOI , .F., .T. )
Do While !( cQAlVOI )->( Eof() )
	cTipTem += "'"+( cQAlVOI )->( VOI_TIPTEM )+"',"
	( cQAlVOI )->( DbSkip() )
EndDo
( cQAlVOI )->( dbCloseArea() )
cTipTem := left(cTipTem,len(cTipTem)-1)
////////////////////////////////////////////////////////
If nCkRad1 == 1
	For ni := 1 to len(aGrp)
		If aGrp[ni,1]
			Aadd(aGrpAux,{aGrp[ni,2]+aGrp[ni,3]})
		EndIf
	Next
Else // nCkRad1 == 2
	For ni := 1 to len(aMod)
		If aMod[ni,1]
			Aadd(aModAux,{aMod[ni,2]+aMod[ni,3]})
		EndIf
	Next
EndIf
cQuery := "SELECT VV1.VV1_DATVEN , VV1.VV1_MEDMKM , VV1.VV1_PROATU , VV1.VV1_LJPATU , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI FROM "+RetSqlName("VV1")+" VV1 WHERE "
If VV1->(FieldPos("VV1_BLQPRO")) > 0
	cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_DATVEN<>'        ' AND VV1.VV1_BLQPRO<>'1' AND VV1.D_E_L_E_T_=' ' "
Else
	cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_DATVEN<>'        ' AND VV1.D_E_L_E_T_=' ' "
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
Do While !( cQAlVV1 )->( Eof() )
	DbSelectArea("VCF")
	DbSetOrder(1)
	If DbSeek( xFilial("VCF") + ( cQAlVV1 )->( VV1_PROATU ) + ( cQAlVV1 )->( VV1_LJPATU ) )
		If !Empty(VCF->VCF_BLOQAG)
			( cQAlVV1 )->( DbSkip() )
			Loop
		EndIf
	EndIf
	nPos := 0
	If nCkRad1 == 1
		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek( xFilial("VV2") + ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV1_MODVEI ) )
		nPos := aScan(aGrpAux, {|x| x[1] == ( cQAlVV1 )->( VV1_CODMAR ) + VV2->VV2_GRUMOD })
	Else // nCkRad1 == 2
		nPos := aScan(aModAux, {|x| x[1] == ( cQAlVV1 )->( VV1_CODMAR ) + ( cQAlVV1 )->( VV1_MODVEI ) })
	EndIf
	If nPos == 0
		( cQAlVV1 )->( DbSkip() )
		Loop
	EndIf
	///////////////////////////////////  KM VO1/VV1  ////////////////////////////////////
	cFilVO1 := "("
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
 		cFilVO1 += "'"+xFilial("VO1")+"'," 
	Next
	cFilAnt := cBkpFilAnt
	If len(cFilVO1) > 1
		cFilVO1 := left(cFilVO1,len(cFilVO1)-1)+")"
	EndIf
	if "DB2" $ cSGBD
		cQuery := "SELECT VO1.VO1_DATABE , VO1.VO1_KILOME , VO1.VO1_FILIAL "
	elseif "ORACLE" $ cSGBD
		cQuery := "SELECT * FROM ( SELECT VO1.VO1_DATABE , VO1.VO1_KILOME , VO1.VO1_FILIAL "
	else
		cQuery := "SELECT TOP 1 VO1.VO1_DATABE , VO1.VO1_KILOME , VO1.VO1_FILIAL "
	endif
	cQuery += "FROM "+RetSqlName("VO1")+" VO1 , "+RetSqlName("VO4")+" VO4 WHERE "
	cQuery += "VO1.VO1_FILIAL IN "+cFilVO1+" AND VO1.VO1_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND "
	cQuery += "VO4.VO4_FILIAL=VO1.VO1_FILIAL AND VO4.VO4_NUMOSV=VO1.VO1_NUMOSV AND VO4.VO4_TIPTEM IN ("+cTipTem+") AND "
	cQuery += "VO1.D_E_L_E_T_=' ' AND VO4.D_E_L_E_T_=' ' ORDER BY VO1.VO1_DATABE DESC "
	if "DB2" $ cSGBD
		cQuery += " FETCH FIRST 1 ROW ONLY"
	elseif "ORACLE" $ cSGBD
		cQuery += " ) WHERE ROWNUM <= 1"
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO1 , .F., .T. )
	If !( cQAlVO1 )->( Eof() ) // Existe passagem na Oficina
		dDtRef := stod(( cQAlVO1 )->( VO1_DATABE ))
		cUltFil := ( cQAlVO1 )->( VO1_FILIAL )
		nDias  := ( dDtRef - stod(( cQAlVV1 )->( VV1_DATVEN )) ) // Dias: entre Passagem na Oficina e Venda Veiculo
		nKmDia := ( ( cQAlVO1 )->( VO1_KILOME ) / nDias ) // KM dia: pela Passagem na Oficina
		nDias  := ( dDataBase - stod(( cQAlVO1 )->( VO1_DATABE )) ) // Dias: entre Hoje e Passagem na Oficina
		nKmAtu := INT(( cQAlVO1 )->( VO1_KILOME ) + ( nDias * nKmDia )) // KM atual: Km da Passagem na Oficina + Calculo de Km ate Hoje
	Else // Nao existe passatem na Oficina
		dDtRef := stod(( cQAlVV1 )->( VV1_DATVEN ))
		cUltFil := xFilial("VO1")
		nDias  := ( dDataBase - dDtRef ) // Dias: entre Hoje e Venda Veiculo
		nKmDia := ( ( cQAlVV1 )->( VV1_MEDMKM ) / 30 ) // KM dia: pela Media informada no Cadastro do Veiculo
		nKmAtu := INT(( nDias * nKmDia )) // KM atual: Km da Venda do Veiculo + Calculo de Km ate Hoje
	EndIf
	( cQAlVO1 )->( dbCloseArea() )    
	///////////////////////     
	lAchouKM  := .f.
	lAchouDia := .f.
	For _i := 1 to Len(aConsidera)
		If	Empty(aConsidera[_i,1]) .and. Empty(aConsidera[_i,2]) .and. Empty(aConsidera[_i,3]) .and. Empty(aConsidera[_i,4])
			Loop
		EndIf
		If nKmAtu < aConsidera[_i,1] .or. nKmAtu > aConsidera[_i,2]
			Loop
		Else
			lAchouKM := .t.
		EndIf
		//////////////////////////////////  TEMPO EM DIAS  //////////////////////////////////
		nDias := ( dDataBase - dDtRef )
		If nDias < aConsidera[_i,3] .or. nDias > aConsidera[_i,4]
			Loop   
		Else 
			lAchouDia := .t.
		EndIf  
		if lAchouKM .and. lAchouDia  
			nKmI   := aConsidera[_i,1]
			nKmF   := aConsidera[_i,2]
			nDiasI := aConsidera[_i,3]
			nDiasF := aConsidera[_i,4]
		Endif
	Next	
	if !lAchouKM .or. !lAchouDia
		( cQAlVV1 )->( DbSkip() )  
		Loop
	Endif
	
	/////////////////////////////////////////////////////////////////////////////////////
	If cSA1 # ( cQAlVV1 )->( VV1_PROATU ) + ( cQAlVV1 )->( VV1_LJPATU )
		cSA1 := ( cQAlVV1 )->( VV1_PROATU ) + ( cQAlVV1 )->( VV1_LJPATU )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + cSA1 )
		cSA1Nome := SA1->A1_NOME
		cSA1Fone := ""
		If lA1_IBGE
			DbSelectArea("VAM")
			DbSetOrder(1)
			DbSeek( xFilial("VAM") + SA1->A1_IBGE )
			cSA1Fone := "("+VAM->VAM_DDD+") "
		EndIf
		cSA1Fone += Alltrim(SA1->A1_TEL)
	EndIf
	lAddVet := .f.
	Do Case
		Case lxFilial
			lAddVet := .t.
			cFilAdd := xFilial("VZB")
		Case nFilial == 1 // Somente Filial Logada
			if cUltFil == cFilAnt
				lAddVet := .t.
				cFilAdd := cUltFil
			Endif				
		Case nFilial == 2 // Todas as Agendas para Todas Filiais
			lAddVet := .t.
			cFilAdd := cUltFil
		Otherwise // Todas as Agendas para Filial Logada 
			lAddVet := .t.
			cFilAdd := xFilial("VZB")
	EndCase	
    If lAddVet
		Aadd(aClientes,{.t. ,;
						Transform(dDtRef,"@D") ,;
						( cQAlVV1 )->( VV1_PROATU ) ,;
						( cQAlVV1 )->( VV1_LJPATU ) ,;
						cSA1Nome ,;
						cSA1Fone ,;
						( cQAlVV1 )->( VV1_CHASSI ) ,;
						STR0046+Transform(dDataBase-dDtRef,"@E 999,999")+space(5)+"/"+space(5)+STR0044+" "+Transform(nKMAtu,VV1->(x3Picture("VV1_MEDMKM"))) ,;
						cFilAdd ,;
						nKmI ,;
						nKmF ,;
						nDiasI ,;
						nDiasF ,;
						0 ,;
						0 ,; 
						0 }) // KM calculada / Dias calculados
	EndIf
	( cQAlVV1 )->( DbSkip() )
EndDo
( cQAlVV1 )->( dbCloseArea() )
OFIOM410CLI(aClientes,cTitulo)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_LEVSC³ Autor ³ Andre Luis Almeida       ³ Data ³ 04/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Geracao das Listas Contato de Clientes que estao sem comprar³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Oficina/CEV                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVSC()
Local lA1_IBGE  := IIf(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Local cTitulo   := STR0004 // Clientes que estao sem comprar
Local cQuery    := ""
Local cQryAlias := "SQLSEMCPA"
Local aRet      := {}
Local nQtdCpa   := 30
Local nMaxDia   := 90
Local cSegCli   := space(len(SA1->A1_SATIV1))
Local aCombo    := {STR0010,STR0011,STR0012,STR0013} // Todos / Balcao / Oficina / Veiculos
Local aParamBox := {} // ParamBox
Local aClientes := {}
aAdd(aParamBox,{1,STR0006,nQtdCpa,"999","","","MV_PAR01>=0",0,.f.}) // A quantos dias nao compra
aAdd(aParamBox,{1,STR0007,nMaxDia,"999","MV_PAR02>=0","","",0,.f.}) // Limite maximo de dias
aAdd(aParamBox,{1,STR0008,cSegCli,"@!","","T3","",0,.f.}) // Segmento do Cliente
aAdd(aParamBox,{2,STR0009,STR0010,aCombo,80,"",.F.}) // Prefixo
If ParamBox(aParamBox,STR0004,@aRet,,,,,,,,.F.)// Clientes que estao sem comprar
	// Objetivo //
	cObjetiv := STR0004+" ( "+aRet[4]+" )"+CHR(13)+CHR(10) // Clientes que estao sem comprar
	cObjetiv += STR0006+": "+Alltrim(str(aRet[1]))+CHR(13)+CHR(10) // A quantos dias nao compra
	cObjetiv += STR0007+": "+Alltrim(str(aRet[2])) // Limite maximo de dias
	If !Empty(aRet[3])
		cObjetiv += CHR(13)+CHR(10)+STR0008+": "+aRet[3] // Segmento do Cliente
	EndIf
	//
	SA1->(DBSetOrder(1))
	VAM->(DBSetOrder(1))
	cQuery := "SELECT SF2.F2_CLIENTE, SF2.F2_LOJA, MAX(SF2.F2_EMISSAO) AS DATAF2 FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SF2")+" SF2 "
	cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
	If aRet[4] == STR0011 // Balcao
		cQuery += "SF2.F2_PREFORI='"+GetNewPar("MV_PREFBAL","BAL")+"' AND "
	ElseIf aRet[4] == STR0012 // Oficina
		cQuery += "SF2.F2_PREFORI='"+GetNewPar("MV_PREFOFI","OFI")+"' AND "
	ElseIf aRet[4] == STR0013 // Veiculos
		cQuery += "SF2.F2_PREFORI='"+GetNewPar("MV_PREFVEI","VEI")+"' AND "
	EndIf
	cQuery += "SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SD2.D_E_L_E_T_=' '  AND "
	cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SD2.D2_TES=SF4.F4_CODIGO AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' AND "
	cQuery += "SF2.D_E_L_E_T_=' ' GROUP BY SF2.F2_CLIENTE, SF2.F2_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	while !((cQryAlias)->(eof()))
		if (cQryAlias)->(DATAF2) > DTOS(DDATABASE - aRet[1])
			( cQryAlias )->( DbSkip() )
			loop
		endif
		if !Empty(aRet[2])
			if (cQryAlias)->(DATAF2) < DTOS(DDATABASE - aRet[2])
				( cQryAlias )->( DbSkip() )
				loop
			endif
		endif
		DBSelectArea("SA1")
		DBSeek(xFilial("SA1") + (cQryAlias)->(F2_CLIENTE) + (cQryAlias)->(F2_LOJA)  )
		if !Empty(aRet[3])
			if SA1->A1_SATIV1 != aRet[3]
				( cQryAlias )->( DbSkip() )
				loop
			endif
		endif
		If lA1_IBGE
			DBSelectArea("VAM")
			DbSeek( xFilial("VAM") + SA1->A1_IBGE )
		EndIf
		Aadd(aClientes,{.t. ,;
						stod((cQryAlias)->( DATAF2 )) ,;
						(cQryAlias)->(F2_CLIENTE) ,;
						(cQryAlias)->(F2_LOJA) ,;
						SA1->A1_NOME ,;
						IIf(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+left(SA1->A1_TEL,15) ,;
						"" ,;
						"" ,;
						xFilial("VZB") ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 })
		( cQryAlias )->( DbSkip() )
	EndDo
	( cQryAlias )->( dbCloseArea() )
	OFIOM410CLI(aClientes,cTitulo)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_LEVCEV³ Autor ³ Andre Luis Almeida      ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Geracao das Listas de Clientes pela Data de Cadastro no CEV ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ CEV                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVCEV()
Local cTitulo   := STR0047 // Clientes pela Data de Cadastro no CEV
Local lA1_IBGE  := ( SA1->(FieldPos("A1_IBGE")) > 0 )
Local cQuery    := ""
Local cQryAlias := "SQLVCF"
Local aClientes := {}
Local aRet      := {}
Local aParamBox := {} // ParamBox
aAdd(aParamBox,{1,STR0048,ctod("") ,"@D","MV_PAR01<=MV_PAR02","","",50,.f.}) // Data Inicial
aAdd(aParamBox,{1,STR0049,dDataBase,"@D","MV_PAR02>=MV_PAR01","","",50,.f.}) // Data Final
If ParamBox(aParamBox,STR0047,@aRet,,,,,,,,.F.)// Clientes que estao sem comprar
	// Objetivo //
	cObjetiv := STR0047+" "+Transform(aRet[1],"@D")+" "+STR0035+" "+Transform(aRet[2],"@D") // Clientes pela Data de Cadastro no CEV / a 
	//
	SA1->(DBSetOrder(1))
	VAM->(DBSetOrder(1))
	cQuery := "SELECT VCF.VCF_CODCLI , VCF.VCF_LOJCLI , VCF.VCF_DATCAD FROM "+RetSqlName("VCF")+" VCF WHERE VCF.VCF_FILIAL='"+xFilial("VCF")+"' AND "
	cQuery += "VCF.VCF_DATCAD>='"+dtos(aRet[1])+"' AND VCF.VCF_DATCAD<='"+dtos(aRet[2])+"' AND VCF.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	While !((cQryAlias)->(eof()))
		DBSelectArea("SA1")
		DBSeek(xFilial("SA1")+(cQryAlias)->(VCF_CODCLI)+(cQryAlias)->(VCF_LOJCLI))
		If lA1_IBGE
			DBSelectArea("VAM")
			DbSeek( xFilial("VAM") + SA1->A1_IBGE )
		EndIf
		Aadd(aClientes,{.t. ,;
						stod((cQryAlias)->(VCF_DATCAD)) ,;
						(cQryAlias)->(VCF_CODCLI) ,;
						(cQryAlias)->(VCF_LOJCLI) ,;
						SA1->A1_NOME ,;
						IIf(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+left(SA1->A1_TEL,15) ,;
						"" ,;
						"" ,;
						xFilial("VZB") ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 })
		( cQryAlias )->( DbSkip() )
	EndDo
	( cQryAlias )->( dbCloseArea() )
	OFIOM410CLI(aClientes,cTitulo)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³OFIOM410CLI³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tela para selecionar/criar contatos para os Clientes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ aCli := Vetor com os Clientes do Levantamento               ³±±
±±³         ³ cTit := Titulo do Levantamento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Oficina/CEV                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM410CLI(aCli,cTit)
Local ni        := 0
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private oAzul   := LoadBitmap( GetResources(), "BR_AZUL" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private oTik    := LoadBitmap( GetResources(), "LBTIK" )
Private oNada   := LoadBitmap( GetResources(), "NADA" )
Private cNFilt  := space(len(VZB->VZB_NOMFIL))
Private cTpAge  := space(len(VC5->VC5_TIPAGE))
Private dDtAge  := ctod("")
Private cCdVen  := space(len(SA3->A3_COD))
Private lMarcarC := .f.
Private nCkRad2  := 1
Private aClientes:= {}

Private M->VDM_CAMPOP := Space(TamSX3("VDM_CAMPOP")[1])
Private cMarVeiF3     := Space(TamSX3("VE1_CODMAR")[1])
Private cModelo   	  := Space(TamSX3("VV2_MODVEI")[1])
Private cVended  	  := Space(TamSX3("A3_COD")[1])
Private cCodFas		  := Space(TamSX3("VDK_CODFAS")[1])
Private M->VDM_TIPMID := Space(TamSX3("VDM_TIPMID")[1])

Default aCli     := {}
Default cTit     := "" 
If type("cObjetiv") == "U"
	cObjetiv := ""
EndIf
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 38 , .T. , .F. } ) // Botoes
aAdd( aObjects, { 0 , 00 , .T. , .T. } ) // ListBox
aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Legenda
aPos := MsObjSize( aInfo, aObjects )
For ni := 1 to len(aCli)
	If !Empty(aCli[ni,3]) .and. !Empty(aCli[ni,4])
		Aadd(aClientes,aClone(aCli[ni]))
		aClientes[len(aClientes),1] := lMarcarC
	EndIf
Next
If len(aClientes) <= 0
	Aadd(aClientes,{.f. ,;
					"" ,;
					"" ,;
					"" ,;
					"" ,;
					"" ,;
					"" ,;
					"" ,;
					"" ,;
					0 ,;
					0 ,;
					0 ,;
					0 ,;
					0 ,;
					0 ,;
					0 })
	lMarcarC := .f.
EndIf
DEFINE MSDIALOG oAgCLI TITLE (STR0015+" - "+cTit) From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Lista de Contatos
@ aPos[1,1]+008,aPos[1,2]+001 RADIO oRadio2 VAR nCkRad2 3D SIZE 90,10 PROMPT (STR0012),(STR0014),(STR0065) OF oAgCLI PIXEL ON CHANGE FS_TIK(nCkRad2,"1") // Oficina / CEV / Oportunidade de Negocios
@ aPos[1,1],aPos[1,2]+098 TO aPos[2,1]-002,445 LABEL "" OF oAgCLI PIXEL

//Oficina
@ aPos[1,1]+015,aPos[1,2]+101 SAY oTit11 VAR (STR0016+":") SIZE 45,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Nome Filtro
@ aPos[1,1]+014,aPos[1,2]+131 MSGET oNFilt VAR cNFilt PICTURE "@!" SIZE 250,8 OF oAgCLI PIXEL COLOR CLR_BLUE

//CEV
@ aPos[1,1]+003,aPos[1,2]+101 SAY oTit12 VAR (STR0017+":") SIZE 45,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Tp.Agenda
@ aPos[1,1]+002,aPos[1,2]+131 MSGET oTpAge VAR cTpAge VALID FS_VALID("VC5") F3 "VC5" PICTURE "@!" SIZE 15,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+101 SAY oTit13 VAR (STR0018+":") SIZE 18,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Data
@ aPos[1,1]+014,aPos[1,2]+131 MSGET oDtAge VAR dDtAge VALID (Empty(dDtAge).or.dDtAge>=dDataBase) PICTURE "@D" SIZE 44,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+027,aPos[1,2]+101 SAY oTit14 VAR (STR0019+":") SIZE 32,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Vendedor
@ aPos[1,1]+026,aPos[1,2]+131 MSGET oCdVen VAR cCdVen VALID FS_VALID("SA3") F3 "SA3" PICTURE "@D" SIZE 44,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,aPos[1,2]+185 SAY oTit15 VAR (STR0063+":") SIZE 28,08 OF oAgCLI PIXEL COLOR CLR_BLUE // Objetivo
@ aPos[1,1]+002,aPos[1,2]+210 GET oObjet VAR cObjetiv OF oAgCLI MEMO SIZE 170,035 PIXEL

//Oportunidade de Negocios
@ aPos[1,1]+003,aPos[1,2]+101 SAY oTitCam VAR (STR0070+":") SIZE 32,08 OF oAgCLI PIXEL COLOR CLR_BLUE // Campanha
@ aPos[1,1]+002,aPos[1,2]+131 MSGET oCampan VAR M->VDM_CAMPOP VALID ExistCpo("VX5","026"+M->VDM_CAMPOP) F3 "VX5" PICTURE "@!" SIZE 40,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,aPos[1,2]+180 SAY oTitVen VAR (STR0019+":") SIZE 32,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Vendedor
@ aPos[1,1]+002,aPos[1,2]+210 MSGET oVended VAR cVended VALID FS_VALID("SA3") F3 "SA3" PICTURE "@!" SIZE 40,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+101 SAY oTitMar VAR (STR0066+":") SIZE 30,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Marca
@ aPos[1,1]+014,aPos[1,2]+131 MSGET oMarca VAR cMarVeiF3 VALID Vazio() .or. ExistCpo("VE1",cMarVeiF3) F3 "VE1" PICTURE "@!" SIZE 20,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+180 SAY oTitMod VAR (STR0067+":") SIZE 45,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Modelo
@ aPos[1,1]+014,aPos[1,2]+210 MSGET oModelo VAR cModelo VALID Vazio() .or. ExistCpo("VV2",cMarVeiF3+cModelo) F3 "MCF" PICTURE "@!" SIZE 80,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+027,aPos[1,2]+101 SAY oTitFas VAR (STR0068+":") SIZE 28,08 OF oAgCLI PIXEL COLOR CLR_BLUE // Fase
@ aPos[1,1]+026,aPos[1,2]+131 MSGET oFases VAR cCodFas VALID Vazio() .or. ExistCpo("VDK",cCodFas) F3 "VDKFAS" PICTURE "@!" SIZE 20,8 OF oAgCLI PIXEL COLOR CLR_BLUE
@ aPos[1,1]+027,aPos[1,2]+180 SAY oTitMid VAR (STR0069+":") SIZE 28,08 OF oAgCLI PIXEL COLOR CLR_BLUE // Midia
@ aPos[1,1]+026,aPos[1,2]+210 MSGET oMidias VAR M->VDM_TIPMID VALID Vazio() .or. ExistCpo("VX5","027"+M->VDM_TIPMID) F3 "VX5" PICTURE "@!" SIZE 60,8 OF oAgCLI PIXEL COLOR CLR_BLUE


@ aPos[1,1]+003,aPos[1,2]+294 SAY olblTemp VAR STR0091+":" SIZE 28,08 OF oAgCLI PIXEL COLOR CLR_BLUE // Temperatura da negociação
@ aPos[1,1]+002,aPos[1,2]+324 COMBOBOX oTempNeg VAR cTmpNeg ITEMS X3CBOXAVET("VDL_TMPNEG","0") SIZE 60,8 OF oAgCLI PIXEL

oTit12:lVisible := .f.
oTit13:lVisible := .f.
oTit14:lVisible := .f.
oTit15:lVisible := .f.
oTpAge:lVisible := .f.
oDtAge:lVisible := .f.
oCdVen:lVisible := .f.
oObjet:lVisible := .f.
olblTemp:lVisible := .f.
oTempNeg:lVisible := .f.

oTitCam:lVisible := .f.
oCampan:lVisible := .f.
oTitMar:lVisible := .f.
oMarca:lVisible  := .f.
oTitMod:lVisible := .f.
oModelo:lVisible := .f.
oTitVen:lVisible := .f.
oVended:lVisible := .f.
oTitFas:lVisible := .f.
oFases:lVisible  := .f.
oTitMid:lVisible := .f.
oMidias:lVisible  := .f.

@ aPos[2,1],aPos[2,2] LISTBOX oLbCli FIELDS HEADER "","",STR0018,STR0020,STR0021,STR0022,STR0023,STR0045,"Vlr.Peças","Vlr.Serviços","Vlr.Veiculos","Vlr.Total" ;
											COLSIZES 10,10,30,30,90,50,80,60,60,60,60,60 SIZE aPos[2,4]-02,aPos[2,3]-aPos[2,1] OF oAgCLI PIXEL ;
											ON DBLCLICK FS_TIK(3,"2") // Data / Cliente / Nome / Fone / Veiculo / Observacao
oLbCli:SetArray(aClientes)
oLbCli:bLine := { || {	IIf(aClientes[oLbCli:nAt,1],oTik,oNo),;
						IIf(FS_AGENDADO(aClientes[oLbCli:nAt,3],aClientes[oLbCli:nAt,4],cTpAge),oAzul,oNada),;
						aClientes[oLbCli:nAt,2],;
						aClientes[oLbCli:nAt,3]+"-"+aClientes[oLbCli:nAt,4],;
						aClientes[oLbCli:nAt,5],aClientes[oLbCli:nAt,6],;
						aClientes[oLbCli:nAt,7],;
						aClientes[oLbCli:nAt,8],;
						FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,14],"@E 999,999,999.99")),;
						FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,15],"@E 999,999,999.99")),;
						FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,16],"@E 999,999,999.99")),;
						FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,14]+aClientes[oLbCli:nAt,15]+aClientes[oLbCli:nAt,16],"@E 999,999,999.99")) }}
DbSelectArea("VC1")
oLbCli:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcarC:=!lMarcarC , FS_TIK(lMarcarC,"3") ) , .t. ) , }

@ aPos[1,1]+014,aPos[1,2]+390 BUTTON oOk PROMPT STR0024 ACTION FS_LEVCLI() OF oAgCLI SIZE 45,10 PIXEL 		// Gerar Contato
@ aPos[1,1]+005,aPos[1,4]-028 BUTTON oImpr PROMPT STR0025 OF oAgCLI SIZE 28,10 PIXEL ACTION FS_IMPRIMIR(cTit) 	// Imprimir
@ aPos[1,1]+021,aPos[1,4]-028 BUTTON oSair PROMPT STR0026 ACTION oAgCLI:End() OF oAgCLI SIZE 28,10 PIXEL  	// Sair
// Legenda //
@ aPos[3,1],020 BITMAP oxTik RESOURCE "LBTIK" OF oAgCLI NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],030 SAY oTitTik VAR STR0027 SIZE 100,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Cliente selecionado
@ aPos[3,1],120 BITMAP oxNo RESOURCE "LBNO" OF oAgCLI NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],130 SAY oTitNo VAR STR0028 SIZE 100,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Cliente nao selecionado
@ aPos[3,1],220 BITMAP oxAzul RESOURCE "BR_AZUL" OF oAgCLI NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],230 SAY oTitAzul VAR STR0029 SIZE 100,10 OF oAgCLI PIXEL COLOR CLR_BLUE // Cliente ja agendado no CEV
ACTIVATE MSDIALOG oAgCLI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VALID ³ Autor ³ Andre Luis Almeida      ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao do Tipo de Agenda / Vendedor                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALID(cTipo)
Local lRet := .t.
If cTipo == "VC5" // Tipo de Agenda
	If !Empty(cTpAge)
		DbSelectArea("VC5")
		DbSetOrder(1)
		If !DbSeek( xFilial("VC5") + cTpAge )
			lRet := .f.
		EndIf
	EndIf
	oLbCli:Refresh()
	DbSelectArea("VC1")
Else// If cTipo == "SA3" // Vendedor
	If !Empty(cCdVen)
		DbSelectArea("SA3")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA3") + cCdVen )
			lRet := .f.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TIK  ³ Autor ³ Andre Luis Almeida      ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ TIK: CheckBox (OFICINA/CEV) / Cliente (INDIVIDUAL/TOTAL)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(xPAR,cTipo)
Local ni := 0
If cTipo == "1" // CheckBox
	If xPAR == 1 // OFICINA
		oTit11:lVisible := .t.
		oNFilt:lVisible := .t.
		oTit12:lVisible := .f.
		oTit13:lVisible := .f.
		oTit14:lVisible := .f.
		oTit15:lVisible := .f.
		oTpAge:lVisible := .f.
		oDtAge:lVisible := .f.
		oCdVen:lVisible := .f.
		oObjet:lVisible := .f.
		oTitCam:lVisible := .f.
		oCampan:lVisible := .f.
		oTitMar:lVisible := .f.
		oMarca:lVisible  := .f.
		oTitMod:lVisible := .f.
		oModelo:lVisible := .f.
		oTitVen:lVisible := .f.
		oVended:lVisible := .f.
		oTitFas:lVisible := .f.
		oFases:lVisible  := .f.
		oTitMid:lVisible := .f.
		oMidias:lVisible  := .f.
		olblTemp:lVisible := .f.
		oTempNeg:lVisible := .f.
	ElseIf xPAR == 2 // CEV
		oTit11:lVisible := .f.
		oNFilt:lVisible := .f.
		oTit12:lVisible := .t.
		oTit13:lVisible := .t.
		oTit14:lVisible := .t.
		oTit15:lVisible := .t.
		oTpAge:lVisible := .t.
		oDtAge:lVisible := .t.
		oCdVen:lVisible := .t.
		oObjet:lVisible := .t.
		oTitCam:lVisible := .f.
		oCampan:lVisible := .f.
		oTitMar:lVisible := .f.
		oMarca:lVisible  := .f.
		oTitMod:lVisible := .f.
		oModelo:lVisible := .f.
		oTitVen:lVisible := .f.
		oVended:lVisible := .f.
		oTitFas:lVisible := .f.
		oFases:lVisible  := .f.
		oTitMid:lVisible := .f.
		oMidias:lVisible  := .f.
		olblTemp:lVisible := .f.
		oTempNeg:lVisible := .f.
	Elseif xPAR == 3 // Oportunidade de Negocios
		oTit11:lVisible := .f.
		oNFilt:lVisible := .f.
		oTit12:lVisible := .f.
		oTit13:lVisible := .f.
		oTit14:lVisible := .f.
		oTit15:lVisible := .f.
		oTpAge:lVisible := .f.
		oDtAge:lVisible := .f.
		oCdVen:lVisible := .f.
		oObjet:lVisible := .f.
		oTitCam:lVisible := .t.
		oCampan:lVisible := .t.
		oTitMar:lVisible := .t.
		oMarca:lVisible  := .t.
		oTitMod:lVisible := .t.
		oModelo:lVisible := .t.
		oTitVen:lVisible := .t.
		oVended:lVisible := .t.
		oTitFas:lVisible := .t.
		oFases:lVisible  := .t.
		oTitMid:lVisible := .t.
		oMidias:lVisible  := .t.
		olblTemp:lVisible := .t.
		oTempNeg:lVisible := .t.
	EndIf
	oLbCli:Refresh()
	DbSelectArea("VC1")
ElseIf cTipo == "2" // Cliente INDIVIDUAL
	If !Empty(aClientes[oLbCli:nAt,3])
		aClientes[oLbCli:nAt,1] := !aClientes[oLbCli:nAt,1]
	EndIf
ElseIf cTipo == "3" // Cliente TOTAL
	For ni := 1 to Len(aClientes)
		If !Empty(aClientes[ni,3])
			aClientes[ni,1] := xPAR
		EndIf
	Next
	lMarcarC := xPAR
	oLbCli:Refresh()
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_AGENDADO³ Autor ³ Andre Luis Almeida    ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ CEV: Verifica se ja existe algum contato sem abordagem para ³±±
±±³         ³ o Cliente, Loja e Tipo de Agenda                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AGENDADO(cCli,cLoj,cAge)
Local lRet := .f.
Local cQuery  := ""
Local cQAlVC1 := "SQLVC1" // VC1
If nCkRad2 == 2 // CEV
	cQuery := "SELECT COUNT(*) AS QTDE FROM "+RetSqlName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
	If !Empty(cAge)
		cQuery += "VC1.VC1_TIPAGE='"+cAge+"' AND "
	EndIf
	cQuery += "VC1.VC1_CODCLI='"+cCli+"' AND VC1.VC1_LOJA='"+cLoj+"' AND VC1.VC1_DATVIS='        ' AND VC1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVC1, .F., .T. )
	If !( cQAlVC1 )->( Eof() )
		If ( cQAlVC1 )->( QTDE ) > 0
			lRet := .t.
		EndIf
	EndIf
	( cQAlVC1 )->( dbCloseArea() )
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_LEVCLI ³ Autor ³ Andre Luis Almeida    ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Geracao das Listas de Contato ( VZB = Oficina / VC1 = CEV ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVCLI()
Local lVDN_CODOPO := ( VDN->(FieldPos("VDN_CODOPO")) > 0 )
Local lOk     := .f.
Local ni      := 0  
Local nj      := 0  
Local nRecVDL := 0
Local cFilBkp := cFilAnt
Local aCliNAO := {} 
If ( nCkRad2 == 1 .and. !Empty(cNFilt) ) .or. ( nCkRad2 == 2 .and. !Empty(cTpAge) .and. !Empty(cCdVen) .and. !Empty(dDtAge) ) ;
	.or.  ( nCkRad2 == 3 .and. !Empty(M->VDM_CAMPOP) .and. !Empty(cVended) .and. !Empty(cCodFas) .and. !Empty(M->VDM_TIPMID))
	For ni := 1 to Len(aClientes)
		If aClientes[ni,1]
			lOk := .t.
		EndIf
	Next
	If !lOk
		MsgAlert(STR0031,STR0030) // Nenhum cliente foi selecionado ! / Atencao
	Else
		If nCkRad2 == 2 // CEV
			lOk := .f.
			For ni := 1 to Len(aClientes)
				If aClientes[ni,1]
					// Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente //
					If VCM510VAL("1",cCdVen,cTpAge,aClientes[ni,3],aClientes[ni,4],dDataBase,"","")
						lOk := .t.
					Else
						If MsgYesNo(STR0064,STR0030) // Deseja desmarcar a Agenda não permitida? / Atencao
							aClientes[ni,1] := .f.
						EndIf
						lOk := .f.
						Exit
					EndIf
				EndIf
			Next
		EndIf
		If lOk
			If MsgYesNo(STR0032,STR0030) // Voce tem certeza que deseja incluir os contatos selecionados ? / Atencao
				For ni := 1 to Len(aClientes)
					if Len(aClientes[ni]) > 9 
						cObj := STR0034+":"+Transform(aClientes[ni,10],"@E 999,999,999")+" "+STR0035+Transform(aClientes[ni,11],"@E 999,999,999")+CHR(13)+CHR(10) // KM / ate
						cObj += STR0043+":"+Transform(aClientes[ni,12],"@E 9,999,999")+" "+STR0035+Transform(aClientes[ni,13],"@E 9,999,999")+CHR(13)+CHR(10) // Tempo em dias / ate 
		         Else
			         cObj := ""
		         Endif
					If aClientes[ni,1] 
						if Len(aClientes[ni]) > 9 
							cFilAnt := aClientes[ni,9]
						Endif	
						If nCkRad2 == 1 // Oficina
							DbSelectArea("VZB")
							RecLock("VZB",.t.)  
							VZB->VZB_FILIAL := xFilial("VZB")
							VZB->VZB_STATUS := "1"
							VZB->VZB_NOMFIL := cNFilt
							VZB->VZB_CODCLI := aClientes[ni,3]
							VZB->VZB_LOJA   := aClientes[ni,4]
							VZB->VZB_NOMCLI := aClientes[ni,5]
							VZB->VZB_TEL    := aClientes[ni,6]
							VZB->VZB_CHASSI := aClientes[ni,7]
							VZB->VZB_DATA   := dDataBase
							MsUnLock()
						ElseIf nCkRad2 == 2 // CEV
							FS_AGENDA(cTpAge,dDtAge,cCdVen,aClientes[ni,3],aClientes[ni,4],,,,cObjetiv+CHR(13)+CHR(10)+cObj,"","")
						ElseIf nCkRad2 == 3 // Oportunidade de Negocios
							DbSelectArea("VDL")
							nRecVDL := 0
							if GetNewPar("MV_MIL0069","0") == "0"
								nRecVDL := FM_SQL("SELECT VDL.R_E_C_N_O_ AS RECVDL FROM "+RetSqlName("VDL")+" VDL WHERE VDL.VDL_FILIAL='"+xFilial("VDL")+"' AND VDL.VDL_CODCLI='"+aClientes[ni,3]+"' AND VDL.VDL_LOJCLI='"+aClientes[ni,4]+"' AND VDL.D_E_L_E_T_=' '")
							Endif	
							If nRecVDL == 0
								DbSelectArea("VDL")
								RecLock("VDL",.t.)
								VDL->VDL_FILIAL := xFilial("VDL")
								VDL->VDL_CODOPO := GetSxeNum("VDL","VDL_CODOPO")
								VDL->VDL_CODCLI := aClientes[ni,3]
								VDL->VDL_LOJCLI := aClientes[ni,4]
								VDL->VDL_NOMCLI := aClientes[ni,5]
								VDL->VDL_TELCLI := aClientes[ni,6]
								VDL->VDL_TMPNEG := cTmpNeg
								MsUnlock()
								ConfirmSx8()
							Else
								DbSelectArea("VDL")
								DbGoTo(nRecVDL)
								RecLock("VDL",.F.)
								VDL->VDL_TMPNEG := cTmpNeg
								MsUnlock()
							Endif
							DbSelectArea("VDM")
							RecLock("VDM",.t.)
							VDM->VDM_FILIAL := xFilial("VDM")
							VDM->VDM_CODOPO := VDL->VDL_CODOPO
							VDM->VDM_CODINT := GetSxeNum("VDM","VDM_CODINT")
							VDM->VDM_CAMPOP := M->VDM_CAMPOP
							VDM->VDM_CODMAR := cMarVeiF3
							VDM->VDM_MODVEI := cModelo
							VDM->VDM_CODVEN := cVended  	 
							VDM->VDM_CODFAS := cCodFas		 
							VDM->VDM_TIPCON := "1"
							VDM->VDM_QTDINT := IIf(!Empty(cMarVeiF3+cModelo),1,0)
							VDM->VDM_TIPMID := M->VDM_TIPMID
							VDM->VDM_DATINT := dDataBase
							VDM->VDM_DATLIM := dDataBase
							VDM->VDM_VLRNEG := 0
							MsUnlock()
							ConfirmSx8()
							DbSelectArea("VDN")
							For nj := 1 to 2
								RecLock("VDN",.t.)
								VDN->VDN_FILIAL := xFilial("VDN")
								VDN->VDN_CODHIS := GetSxeNum("VDN","VDN_CODHIS")
								VDN->VDN_CODINT := VDM->VDM_CODINT
								If lVDN_CODOPO
									VDN->VDN_CODOPO := VDM->VDM_CODOPO
								EndIf
								If nj == 1
									VDN->VDN_CODFAS := cCodFas		 
									VDN->VDN_CODCLI := aClientes[ni,3]
									VDN->VDN_LOJCLI := aClientes[ni,4]
									VDN->VDN_NOMCLI := aClientes[ni,5]
									VDN->VDN_CODVEN := cVended
									VDN->VDN_OBSERV := cObjetiv
								EndIf  	 
								VDN->VDN_DATHIS := dDataBase
								VDN->VDN_HORHIS := Val(Left(time(),2) + subs(time(),4,2))
								VDN->VDN_USUHIS := __cUserId
								VDN->VDN_TIPHIS := strzero(nj,1)
								if VDN->VDN_TIPHIS == '1'
									VDN->VDN_TMPNEG := VDL->VDL_TMPNEG
									VDN->VDN_VLRNEG := VDM->VDM_VLRNEG
								endif
								MsUnlock()
								ConfirmSx8()
							Next
						EndIf
						if Len(aClientes[ni]) > 9 
							cFilAnt := cFilBkp
						Endif	
					Else
						Aadd(aCliNAO,aClone(aClientes[ni]))
					EndIf
				Next	
				MsgInfo(STR0033,STR0030) // Contatos gerados com sucesso ! / Atencao
				aClientes := aClone(aCliNAO)
			EndIf
			If len(aClientes) <= 0
				Aadd(aClientes,{.f. ,;
								"" ,;
								"" ,;
								"" ,;
								"" ,;
								"" ,;
								"" ,;
								"" ,;
								"" ,;
								0 ,;
								0 ,;
								0 ,;
								0 ,;
								0 ,;
								0 ,;
								0 })
			EndIf
			oLbCli:nAt := 1
			oLbCli:SetArray(aClientes)
			oLbCli:bLine := { || {	IIf(aClientes[oLbCli:nAt,1],oTik,oNo),;
									IIf(FS_AGENDADO(aClientes[oLbCli:nAt,3],aClientes[oLbCli:nAt,4],cTpAge),oAzul,oNada),;
									aClientes[oLbCli:nAt,2],;
									aClientes[oLbCli:nAt,3]+"-"+aClientes[oLbCli:nAt,4],;
									aClientes[oLbCli:nAt,5],aClientes[oLbCli:nAt,6],;
									aClientes[oLbCli:nAt,7],;
									aClientes[oLbCli:nAt,8],;
									FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,14],"@E 999,999,999.99")),;
									FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,15],"@E 999,999,999.99")),;
									FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,16],"@E 999,999,999.99")),;
									FG_AlinVlrs(Transform(aClientes[oLbCli:nAt,14]+aClientes[oLbCli:nAt,15]+aClientes[oLbCli:nAt,16],"@E 999,999,999.99")) }}
			DbSelectArea("VC1")
		EndIf
	EndIf
Else
	MsgStop(STR0050,STR0030) // Favor preencher corretamente os campos relacionados a geracao de contato! / Atencao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_IMPRIMIR³ Autor ³ Andre Luis Almeida    ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao do ListBox dos Clientes                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR(cTit) // Imprimir
Local oReport
Local aRet      := {}
Local aParamBox := {}
Local aTipVen   := {"1="+STR0056,"3="+STR0055,"4="+STR0013} // Servicos / Pecas / Veiculos
If VCF->(FieldPos("VCF_VENVEU")) > 0 // Possui campos novos
	aTipVen := {"1="+STR0056,"3="+STR0055,"4="+STR0083,"5="+STR0084,"6="+STR0085,"7="+STR0086} // Servicos / Pecas / Veic.Novos / Veic.Usados / Pneus / Outros
EndIf
AADD(aParamBox,{2,STR0082,"1",aTipVen,100,"",.F.}) // 01-Tipo de Vendedor
AADD(aParamBox,{1,STR0019,Space(TamSX3("VCF_VENVEI")[1]),"@!",'VAZIO() .OR. FG_SEEK("SA3","MV_PAR02",1,.f.)',"SA3",,40,.f.}) // 02-Vendedor
If ParamBox(aParamBox,STR0015,@aRet,,,,,,,,.f.)
	oReport:= ReportDef(cTit,aRet) // Nesta função nos definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
	oReport:SetPortrait() // Define orientação de página do relatório como retrato.
	oReport:PrintDialog() // Essa função serve para disparar a impressão do TReport,  ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ ReportDef ³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Definicoes do oReport (linhas/colunas/totalizadores)        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(cTit,aVetFiltro)
Local oSection1
Local oSection2

// oReport
oReport := TReport():New("OM410R",cTit,,{|oReport| OM410Impr(oReport,aVetFiltro)})

// Vendedor
oSection1 := TRSection():New(oReport,STR0019,) // Vendedor
TRCell():New(oSection1,STR0019,"",STR0019    ,"@!" ,50,,{|| cVendNom },,,,.t.)

// Clientes
oSection2 := TRSection():New(oReport,STR0020) // Cliente
TRCell():New(oSection2,"CodCli","",STR0020 ,"@!" ,50,,{|| cCliente },,,,.t.) // Cliente
TRCell():New(oSection2,"NroFon","",STR0022 ,"@!" ,20,,{|| cFone },,,,.t.) // Fone
TRCell():New(oSection2,"VlrPec","",STR0087 ,"@E 999,999,999.99" ,15,,{|| nVlrPec },,,"RIGHT",.t.) // Vlr.Peças
TRCell():New(oSection2,"VlrSrv","",STR0088 ,"@E 999,999,999.99" ,15,,{|| nVlrSrv },,,"RIGHT",.t.) // Vlr.Serviços
TRCell():New(oSection2,"VlrVei","",STR0089 ,"@E 999,999,999.99" ,15,,{|| nVlrVei },,,"RIGHT",.t.) // Vlr.Veiculos
TRCell():New(oSection2,"VlrTot","",STR0090 ,"@E 999,999,999.99" ,15,,{|| nVlrTot },,,"RIGHT",.t.) // Vlr.Total
TRCell():New(oSection2,"DatCad","",STR0018 ,"@D"                ,15,,{|| dDatCad },,,,.t.) // Data
TRFunction():New(oSection2:Cell("CodCli"),NIL,"COUNT") // Totalizador ( conta quantidade de Clientes do Vendedor )
TRFunction():New(oSection2:Cell("VlrPec"),NIL,"SUM")   // Totalizador ( soma valor de pecas do Vendedor )
TRFunction():New(oSection2:Cell("VlrSrv"),NIL,"SUM")   // Totalizador ( soma valor de servicos do Vendedor )
TRFunction():New(oSection2:Cell("VlrVei"),NIL,"SUM")   // Totalizador ( soma valor de veiculos do Vendedor )
TRFunction():New(oSection2:Cell("VlrTot"),NIL,"SUM")   // Totalizador ( soma valor total do Vendedor )
oSection2:SetTotalInLine(.F.) // Colocar o Totalizador da Secao 2 em UMA linha
//
oReport:SetTotalInLine(.F.) // Colocar o Totalizador Geral em UMA linha
//
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ OM410Impr ³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao While/For com chamadas de PrintLine               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OM410Impr(oReport,aVetFiltro)
Local ni        := 0
Local nPos      := 0
Local cQuebra   := ""
Local aImpCli   := {}
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
For ni := 1 to len(aClientes)
	nPos := Ascan(aImpCli,{ |x| x[2] == aClientes[ni,3]+aClientes[ni,4] })
	VCF->(DbSetOrder(1))
	VCF->(DbSeek(xFilial("VCF")+aClientes[ni,3]+aClientes[ni,4]))
	cVendNom := ""
	Do Case
		Case aVetFiltro[1] == "1" // Vendedor de Servicos
			cVendNom := VCF->VCF_VENSRV
		Case aVetFiltro[1] == "3" // Vendedor de Pecas
			cVendNom := VCF->VCF_VENPEC
		Case aVetFiltro[1] == "4" // Vendedor de Veiculos Novos
			cVendNom := VCF->VCF_VENVEI
		Case aVetFiltro[1] == "5" // Vendedor de Veiculos Usados
			cVendNom := VCF->VCF_VENVEU
		Case aVetFiltro[1] == "6" // Vendedor de Pneus
			cVendNom := VCF->VCF_VENPNE
		Case aVetFiltro[1] == "7" // Vendedor de Outros
			cVendNom := VCF->VCF_VENOUT
	EndCase
	If Empty(aVetFiltro[2]) .or. ( aVetFiltro[2] == cVendNom ) // Filtra  Vendedor
		If nPos == 0
			aAdd(aImpCli,{	cVendNom,;
							aClientes[ni,3]+aClientes[ni,4],;
							left(aClientes[ni,3]+"-"+aClientes[ni,4]+" "+aClientes[ni,5]+space(49),49),;
							left(aClientes[ni,6]+space(21),21),;
							aClientes[ni,14],;
							aClientes[ni,15],;
							aClientes[ni,16],;
							aClientes[ni,14]+aClientes[ni,15]+aClientes[ni,16],;
							VCF->VCF_DATCAD})
		Else
			aImpCli[nPos,5] += aClientes[ni,14]
			aImpCli[nPos,6] += aClientes[ni,15]
			aImpCli[nPos,7] += aClientes[ni,16]
			aImpCli[nPos,8] := aImpCli[nPos,5]+aImpCli[nPos,6]+aImpCli[nPos,7]
		EndIf
	EndIf
Next
aSort(aImpCli,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
//
cQuebra := "INICIAL"
For ni := 1 to len(aImpCli)
	If Alltrim(cQuebra) <> Alltrim(aImpCli[ni,1])
		SA3->(DbSetOrder(1))
		SA3->(DbSeek(xFilial("SA3")+aImpCli[ni,1]))
		cVendNom := aImpCli[ni,1]+" - "+Alltrim(SA3->A3_NOME)
		If cQuebra <> "INICIAL"
			oSection2:Finish()
		EndIf
		oSection1:Init()
		oSection1:PrintLine() // Imprimir Secao 1
		oSection1:Finish()
		oSection2:Init()
		cQuebra := aImpCli[ni,1]
	EndIf
	cCliente := aImpCli[ni,3] // Cliente
	cFone    := aImpCli[ni,4] // Fone
	nVlrPec  := aImpCli[ni,5] // Valor de Pecas
	nVlrSrv  := aImpCli[ni,6] // Valor de Servicos
	nVlrVei  := aImpCli[ni,7] // Valor de Veiculos
	nVlrTot  := aImpCli[ni,8] // Valor Total
	dDatCad  := aImpCli[ni,9] // Data
	oSection2:PrintLine() // Imprimir Secao 2
Next
If cQuebra <> "INICIAL"
	oSection2:Finish()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ OM410LEG  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 05/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATENCAO ³ -> Esta funcao eh chamada por outras rotinas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Legenda ( Selecionado / Nao selecionado )                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM410LEG()
Local cCadastro := ""
Local aLegenda := { {"BR_VERDE",STR0052},{"BR_VERMELHO",STR0053}} // Selecionado / Nao selecionado
BrwLegenda(cCadastro,STR0051,aLegenda) // Legenda
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_QDADE  ³ Autor ³ Thiago		     	     ³ Data ³ 01/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao quantidade.							                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function FS_QDADE()
Local i:= 0 

aConsidera := {{0,99999999,0,999999}}

For i := 1 to nQtd-1 
	AADD(aConsidera,{0,0,0,0})
Next
oLbcons:SetArray(aConsidera)
oLbcons:bLine := { || {Transform(aConsidera[oLbcons:nAt,1],"@E 999,999,999,999"),;
transform(aConsidera[oLbcons:nAt,2],"@E 999,999,999,999") ,;
transform(aConsidera[oLbcons:nAt,3],"@E 999999999") ,;
transform(aConsidera[oLbcons:nAt,4],"@E 999999999") }}
oLbcons:Refresh()
                   
Return(.t.)  
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SELECIONA º Autor ³ Thiago				     º Data ³ 25/01/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Selec campo.																  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELECIONA(aConsidera,nLinha)
Local aRet := {}
Local aParamBox := {}
//         ("Km De"),("Km Até"),("Dias De"),("Dias Até")                     
AADD(aParamBox,{1,STR0078,aConsidera[nLinha,1],"@E 999,999,999,999","","","",40,.f.}) // Km De
AADD(aParamBox,{1,STR0079,aConsidera[nLinha,2],"@E 999,999,999,999","","","",40,.f.}) // Km Ate
AADD(aParamBox,{1,STR0080,aConsidera[nLinha,3],"@E 999,999","","","",40,.f.}) // Dias De
AADD(aParamBox,{1,STR0081,aConsidera[nLinha,4],"@E 999,999","","","",40,.f.}) // Dias De
if !ParamBox(aParamBox,"",@aRet,,,,,,,,.f.) 
	Return(.f.)
Endif  
aConsidera[nLinha,1] := aRet[1]
aConsidera[nLinha,2] := aRet[2]
aConsidera[nLinha,3] := aRet[3]
aConsidera[nLinha,4] := aRet[4]

Return(.t.)