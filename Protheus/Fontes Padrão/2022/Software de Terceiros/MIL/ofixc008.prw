// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "OFIXC008.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OFIXC008 ³ Autor ³ Thiago                ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Consulta Detalhada de Peças.					 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXC008(cOrcam)

//variaveis controle de janela 																	
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}// 
Local nCntFor := 0 						
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)	 
Local lSetKey := FindFunction("OFISetKey")

Local lVAI_ACEDET := VAI->(ColumnPos('VAI_ACEDET')) > 0

Private oGetPCons
Private cNomFab  := space(TamSx3("B1_FABRIC")[1])  
Private cDesc   := space(TamSx3("B1_DESC")[1])  
Private cFamilia := space(TamSx3("VE3_FAMILI")[1])  
Private cClasse  := space(TamSx3("VE3_CLASSE")[1]) 
Private cSubCla  := space(TamSx3("VE3_SUBCLA")[1]) 
Private cMarca   := space(TamSx3("VV1_CODMAR")[1])  
Private cModelo  := space(TamSx3("VV1_MODVEI")[1])  
Private cAno     := space(TamSx3("VV1_FABMOD")[1])  
Private cKit     := space(20)
Private cLogoEmpr := GetNewPar("MV_DIRFTGC","") + "ologoconsultapeca.GIF"
Private cGrupo := space(TamSx3("B1_GRUPO")[1])
Private cCHAVE   := space(TamSx3("B1_CODITE")[1]) 
Private cTudoOk    := ""
Private aItens := {}       
Private cAplicaPeca := "0"
Private aItensRel := {{"","","","","",0,0}}
Private aPedPen   := {{"",ctod("  /  /  "),0}}
Private cGrupoAnt  := ""
Private cCodIteAnt := ""
Private aCols      := {} , aHeader := {} , aCpoEnchoice  :={}
Private cCodIte    := "" 
Private cCodbar    := space(TamSx3("B1_CODBAR")[1]) 
Private cAplic     := "0"
Private cPesqui    := "0" 

Default cOrcam     := "2"

if cOrcam == "1"  
	if Empty(M->VS1_TIPORC) .or. Empty(M->VS1_CLIFAT)
		MsgStop(STR0001)
		Return(.f.)
	Endif
Endif

cLinOkP    := "OC008VLIN() .AND. FG_OBRIGAT()"
cFieldOkP  := "FG_MEMVAR()"
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 149 , .T. , .F. } )//cabecalho
AAdd( aObjects, { 000, 065 , .T. , .T. } )//listbox
AAdd( aObjects, { 000, 065 , .T. , .T. } )//listbox
AAdd( aObjects, { 000, 010 , .T. , .F. } )//listbox

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)     

If lSetKey
	oSetKey := OFISetKey():New()
	oSetKey:Backup()
EndIf

// ########################################################################
// # Montagem do vetor com informacoes adicionais                         #
// ########################################################################
SETKEY(VK_F8,{|| FS_PESQUISAR() })
SETKEY(VK_F4,{|| FS_APLICACAO() })
SETKEY(VK_F5,{|| FS_RESULTADO() })
SETKEY(VK_F7,{|| FS_LIMPATELA() })
SETKEY(VK_F6,{|| FS_FOTO() })
SETKEY(VK_F10,{|| FS_EXPORTAR(cOrcam) })
SETKEY(VK_F11,{|| FS_FINALIZA() })

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

aVetInfo := {}
aAdd(aVetInfo,{STR0002						,	'FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")'	,	NIL					,	"@!"							})
aAdd(aVetInfo,{STR0003  					,	"OC001RSIT()"								,	NIL		   			,	"@!"							})
If !lVAI_ACEDET .or. VAI->VAI_ACEDET <> "0"
	aAdd(aVetInfo,{STR0004 					,	"OC001RPRE()"								,	"OC001BPRECO()"		,	SB1->(X3PICTURE("B1_PRV1"))		})
Else
	aAdd(aVetInfo,{STR0004 					,	"OC001RPRE()"								,	NIL					,	SB1->(X3PICTURE("B1_PRV1"))		})
EndIf
aAdd(aVetInfo,{STR0005						,	"OC001REST()"								,	"OC001BESTOQUE()"	,	SB2->(X3PICTURE("B2_QATU")) 	})
aAdd(aVetInfo,{"'"+RetTitle("B1_ESTSEG")+"'",	'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTSEG")'	,	NIL					,	SB1->(X3PICTURE("B1_ESTSEG")) 	})
If SB1->(FieldPos("B1_ESTMIN")) > 0
	aAdd(aVetInfo,{"'"+RetTitle("B1_ESTMIN")+"'",'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTMIN")',	NIL					,	SB1->(X3PICTURE("B1_ESTMIN")) 	})
Else
	aAdd(aVetInfo,{"'"+RetTitle("B1_EMIN")+"'",'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_EMIN")'	,	NIL					,	SB1->(X3PICTURE("B1_EMIN"))	 	})
endif
aAdd(aVetInfo,{STR0006						,	"OC001RCLAS()"								,	NIL					,	"@!"							})
aAdd(aVetInfo,{"'"+RetTitle("B5_CODCAI")+"'",	"SB5->B5_CODCAI"							,	NIL					,	"@!"							})
if GetNewPar("MV_CUSBAL","S") == "S"
	aAdd(aVetInfo,{RetTitle("B2_CM1")+"'"	,	"SB2->B2_CM1"								,	NIL					,	SB2->(X3PICTURE("B2_CM1"))		})
Endif
aAdd(aVetInfo,{"'"+RetTitle("B1_PRV1")+"'"	,	'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")'	,	NIL					,	SB1->(X3PICTURE("B1_PRV1"))		})
aAdd(aVetInfo,{"'"+RetTitle("B1_QE")+"'"	,	"SB1->B1_QE"								,	NIL					,	SB1->(X3PICTURE("B1_QE"))		})
aAdd(aVetInfo,{"'"+RetTitle("B1_PESO")+"'"	,	"SB1->B1_PESO"								,	NIL					,	SB1->(X3PICTURE("B1_PESO"))		})
aAdd(aVetInfo,{"'"+RetTitle("B1_GRUDES")+"'",	"SB1->B1_GRUDES"							,	NIL					,	"@!"				})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("B1_COD")
nUsado:=nUsado+1
AADD(aHeader,{ Trim(X3Titulo()),;
	X3_CAMPO,;
	X3_PICTURE,;
	X3_TAMANHO,;
	X3_DECIMAL,;
	X3_VALID,;
	X3_USADO,;
	X3_TIPO,;
	X3_ARQUIVO,;
	X3_CONTEXT,;
	X3_RELACAO,;
	X3_RESERV  } )

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("B1_CODITE")
nUsado:=nUsado+1
AADD(aHeader,{ Trim(X3Titulo()),;
	X3_CAMPO,;
	X3_PICTURE,;
	X3_TAMANHO,;
	X3_DECIMAL,;
	X3_VALID,;
	X3_USADO,;
	X3_TIPO,;
	X3_ARQUIVO,;
	X3_CONTEXT,;
	X3_RELACAO,;
	X3_RESERV  } )

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("B1_DESC")
nUsado:=nUsado+1
AADD(aHeader,{ Trim(X3Titulo()),;
	X3_CAMPO,;
	X3_PICTURE,;
	X3_TAMANHO,;
	X3_DECIMAL,;
	X3_VALID,;
	X3_USADO,;
	X3_TIPO,;
	X3_ARQUIVO,;
	X3_CONTEXT,;
	X3_RELACAO,;
	X3_RESERV  } )

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("B1_OPC")
nUsado:=nUsado+1
AADD(aHeader,{ STR0007,;
	X3_CAMPO,;
	X3_PICTURE,;
	X3_TAMANHO,;
	X3_DECIMAL,;
	X3_VALID,;
	X3_USADO,;
	X3_TIPO,;
	X3_ARQUIVO,;
	X3_CONTEXT,;
	X3_RELACAO,;
	X3_RESERV  } )

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("B2_QATU")
nUsado:=nUsado+1
AADD(aHeader,{ STR0008,;
	X3_CAMPO,;
	X3_PICTURE,;
	X3_TAMANHO,;
	X3_DECIMAL,;
	"",;
	X3_USADO,;
	X3_TIPO,;
	X3_ARQUIVO,;
	X3_CONTEXT,;
	X3_RELACAO,;
	X3_RESERV  } )

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("B1_PRV1")
nUsado:=nUsado+1
AADD(aHeader,{ Trim(X3Titulo()),;
	X3_CAMPO,;
	X3_PICTURE,;
	X3_TAMANHO,;
	X3_DECIMAL,;
	X3_VALID,;
	X3_USADO,;
	X3_TIPO,;
	X3_ARQUIVO,;
	X3_CONTEXT,;
	X3_RELACAO,;
	X3_RESERV  } )


aCols := { Array(nUsado + 1) }
aCols[1,nUsado+1] := .F.
For nCntFor:=1 to nUsado
	aCols[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
Next


DEFINE MSDIALOG oDlg TITLE STR0009 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL // Consulta Detalhada de Peças

// Bitmap do Logotipo 
If File(cLogoEmpr)
	TBitmap():New( 003 , 050 , 200 ,  100 ,,cLogoEmpr,.T.,oDlg,,,.T.,.F.,,,.F.,,.T.,,.F.)
EndIf

@ aPos[1,1]+040,aPos[1,2] TO aPos[1,3],aPos[1,4]/2 LABEL "" OF oDlg PIXEL 
@ aPos[1,1]+041,aPos[1,2]+020 SAY STR0010 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+041,aPos[1,2]+074 MSGET oChvProd VAR cCHAVE Valid if(!Empty(cCHAVE),(FS_VERALT() .and. FG_POSSB1('cCHAVE','SB1->B1_COD')) .and. OC008PREPEC(cCHAVE,"") .and. FS_KIT(cChave),.t.) PICTURE "@!" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+052,aPos[1,2]+020 SAY STR0011 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+052,aPos[1,2]+074 MSGET oNomFab VAR cNomFab Valid if(!Empty(cNomFab),OC008PREPEC(cNomFab,""),.t.) PICTURE "@!" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+063,aPos[1,2]+020 SAY STR0012 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+063,aPos[1,2]+074 MSGET oDescri VAR cDesc Valid if(!Empty(cDesc),OC008BDESC(),.t.) PICTURE "@!" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+074,aPos[1,2]+020 SAY STR0013 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+074,aPos[1,2]+074 MSGET oFamilia VAR cFamilia Valid FS_FAMILIA() PICTURE "@!" F3 "V7" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+085,aPos[1,2]+020 SAY STR0072 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+085,aPos[1,2]+074 MSGET oClasse VAR cClasse Valid FS_CLASSE() PICTURE "@!" F3 "V8" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+096,aPos[1,2]+020 SAY STR0073 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+096,aPos[1,2]+074 MSGET oSubCla VAR cSubCla Valid FS_SUBCLA() PICTURE "@!" F3 "V9" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+107,aPos[1,2]+020 SAY STR0014 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+107,aPos[1,2]+074 MSGET oMarca VAR cMarca F3 "VE1" PICTURE "@!" VALID FS_MARCA() SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+118,aPos[1,2]+020 SAY STR0015 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+118,aPos[1,2]+074 MSGET oModelo VAR cModelo PICTURE "@!" Valid FS_MODELO() F3 "VV2" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+129,aPos[1,2]+020 SAY STR0016 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+129,aPos[1,2]+074 MSGET oAno VAR cAno PICTURE "@!" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[1,1]+140,aPos[1,2]+020 SAY STR0017 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[1,1]+140,aPos[1,2]+74 BUTTON oKit  PROMPT "..." OF oDlg SIZE 10,08 PIXEL ACTION ( FS_KIT() )

@ aPos[1,1]+140,(aPos[1,4]/2)-70 BUTTON oPesquisa  PROMPT STR0018 OF oDlg SIZE 65,08 PIXEL ACTION ( FS_PESQUISAR() )

@ aPos[1,1],(aPos[1,4]/2)+2 SAY STR0019 OF oDlg   PIXEL COLOR CLR_RED
@ aPos[1,1]+8,(aPos[1,4]/2)+2  LISTBOX oLbox9 FIELDS HEADER STR0020, STR0021, STR0008 COLSIZES 80,80,80 SIZE ((aPos[1,4]-2)/2),((aPos[1,3]-aPos[1,1]-10)/2)+70 OF Odlg PIXEL 
		oLbox9:SetArray(aPedPen)
		oLbox9:bLine := { || { aPedPen[oLbox9:nAt,01],;
		Transform(aPedPen[oLbox9:nAt,02],"@D"),;
		Transform(aPedPen[oLbox9:nAt,03],"@E 99999")}}


@ aPos[2,1],aPos[2,2]+005 SAY STR0022 OF oDlg   PIXEL COLOR CLR_RED

n:=1
oGetPCons := MsGetDados():New(aPos[2,1]+08,aPos[2,2],aPos[2,3],aPos[2,4],3,cLinOkP,cTudoOk,"",.T.,{"B2_QATU","B1_PRV1"},,,20,cFieldOkP,,,,oDlg)
oGetPCons:oBrowse:default()
oGetPCons:oBrowse:bChange       := {|| FS_MEMVAR(), OC008ITEREL("1",""),FS_FILPREC() }
oGetPCons:oBrowse:bEditCol  := {|| .t. }

@ aPos[2,3],aPos[1,4]-70 BUTTON oPesquisa  PROMPT STR0023 OF oDlg SIZE 65,08 PIXEL ACTION ( FS_EXPORTAR(cOrcam) )

@ aPos[3,1],aPos[3,2]+005 SAY STR0024 OF oDlg   PIXEL COLOR CLR_RED
@ aPos[3,1]+08,aPos[2,2]  LISTBOX oLbox2 FIELDS HEADER STR0025,STR0026,STR0027, STR0028,STR0007,STR0008,STR0029 COLSIZES 80,80,80,160,160,60,80 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1]-10 OF Odlg PIXEL 
		oLbox2:SetArray(aItensRel)
		oLbox2:bLine := { || { aItensRel[oLbox2:nAt,01],;
		aItensRel[oLbox2:nAt,02],;
		aItensRel[oLbox2:nAt,03],;
		aItensRel[oLbox2:nAt,04],;
		aItensRel[oLbox2:nAt,05],;
		Transform(aItensRel[oLbox2:nAt,06],"@E 99999"),;
		Transform(aItensRel[oLbox2:nAt,07],"@E 99,999,999.99")}}

@ aPos[4,1],aPos[4,2]+018 SAY STR0030 OF oDlg   PIXEL COLOR CLR_BLUE 
@ aPos[4,1],aPos[4,2]+068 MSGET oCodBar VAR cCodbar Valid FS_CODBAR() PICTURE "@!" SIZE 150,8 OF oDlg PIXEL COLOR CLR_BLUE 

@ aPos[4,1],aPos[4,2]+238 SAY STR0031 OF oDlg   PIXEL COLOR CLR_RED


ACTIVATE MSDIALOG oDlg CENTER

SetKey(VK_F8,Nil)
SetKey(VK_F4,Nil)
SetKey(VK_F7,Nil)
SetKey(VK_F6,Nil)
SetKey(VK_F11,Nil)

// Restaurar as teclas de atalho
If lSetKey
	oSetKey:Restore()
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FS_VERALT   |Autor  ³ THIAGO             ³ Data ³ 27/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra Alternativos (Peças)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERALT()

Local cAreaAnt		:= GetArea()
Local cQuery3 		:= ""
Local cQVB12		:= "SQLVB12"
Local aConVB12		:= {}
Local nPos			:= 0

cQuery3 := "SELECT VB1.VB1_KEYALT, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_COD , SB1.B1_DESC FROM " + RetSqlName("SB1")+" SB1"
cQuery3 += " JOIN "  + RetSqlName("VB1")+" VB1 ON VB1.VB1_COD = SB1.B1_COD"
cQuery3 += " WHERE VB1.VB1_KEYALT LIKE '" + AllTrim(CcHAVE) + "%' AND VB1.D_E_L_E_T_= ' '"
cQuery3 += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND VB1.VB1_FILIAL = '" + xFilial("VB1")+"'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery3 ), cQVB12, .F., .T. )
While !(cQVB12)->(Eof())
	AAdd(aConVB12,{(cQVB12)->(VB1_KEYALT), (cQVB12)->(B1_GRUPO), (cQVB12)->(B1_CODITE), (cQVB12)->(B1_DESC),(cQVB12)->(B1_COD)})
	(cQVB12)->(DbSkip())
EndDo
(cQVB12)->(DbCloseArea())
DBSelectArea("SB1")
If Len(aConVB12) >= 1
	RestArea(cAreaAnt)
	
	DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,080 TITLE (STR0032) OF oMainWnd  // Cadastros Alternativos Encontrados
	@ 001,001 LISTBOX olBox3 FIELDS HEADER (STR0033),; // Codigo Alternativo
	(STR0034),; // Grupo
	(STR0035),; // Cod. Item
	(STR0036);  // Descricao
	COLSIZES 50,20,60,65 SIZE 315,111 OF oDesVB1 PIXEL ON DBLCLICK (nPos := olBox3:nAt, oDesVB1:END())
	olBox3:SetArray(aConVB12)
	olBox3:bLine := { || {  aConVB12[olBox3:nAt,1] , aConVB12[olBox3:nAt,2] , 	aConVB12[olBox3:nAt,3] , aConVB12[olBox3:nAt,4] }}
	ACTIVATE MSDIALOG oDesVB1 CENTER
	If nPos != 0
		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1")+aConVB12[nPos,2]+aConVB12[nPos,3])
		cChave := SB1->B1_COD
	EndIf
	
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OC008PREPEC ³ Autor ³ THIAGO              ³ Data ³ 27/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche as informacoes da consulta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC008PREPEC(cProd,cCodBar1)
Default cProd := ""
cNomFab := ""
if cGrupoAnt+cCodIteAnt == cGrupo+cCodIte
	return .f.
endif

if cProd != ""
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1")+cProd)
Elseif cCodBar1 != ""
	DBSelectArea("SB1")
	DBSetOrder(5)
	DBSeek(xFilial("SB1")+cCodBar)
Else
	if Empty(cCodIte)
		return .t.
	endif
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1") + cGrupo + cCodIte)
endif
//
MsAguarde({|lEnd,cProd| OX008MSPEC(@lEnd)},STR0037,STR0038,.T.)
//
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX008MSPEC  ³ Autor ³ THIAGO              ³ Data ³ 27/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche as informacoes da consulta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX008MSPEC(lEnd,cProd)
Local nSaldo := 0
Local cQueSB1 := "SQLSB1"
Local nCntFor
Local aGruite := {}
Local lClicou := .t.
Default cProd := ""


// ######################################################################################
// # Verifica preenchimento do parametro para iniciar o preenchimento dos demais campos #
// ######################################################################################
MsProcTxt(STR0039)
ProcessMessage()
//                                  
if !Empty(cNomFab)
	cQuery := "SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SB1.B1_COD , SB1.B1_FABRIC FROM " + RetSqlName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_FABRIC LIKE '"+Alltrim(cNomFab)+"%' AND SB1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQueSB1, .F., .T. )
	If !( cQueSB1 )->( Eof() ) 
		lRet := .t.
		Do While !( cQueSB1 )->( Eof() )
			SB1->(DBSetOrder(1))
			SB1->(DBSeek(xFilial("SB1")+( cQueSB1 )->( B1_COD )  ) )
			Aadd(aGruIte,{ ( cQueSB1 )->( B1_GRUPO ) , ( cQueSB1 )->( B1_CODITE ) , ( cQueSB1 )->( B1_DESC ) , ( cQueSB1 )->( B1_COD ) , ( cQueSB1 )->( B1_FABRIC), OX001SLDPC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD) })
			( cQueSB1 )->( DbSkip() )
		EndDo
		If len(aGruIte) > 1
			dbSelectArea("SB1")
			dbSetOrder(1)
			DEFINE MSDIALOG oGruIte TITLE (STR0040) From 00,00 to 17,70 of oMainWnd
			@ 002,002 LISTBOX oLbGruIte FIELDS HEADER OemToAnsi(STR0034),;  //Grupo
			OemToAnsi(STR0041),;  //Codigo Item
			OemToAnsi(STR0036),;  //Descricao
			OemToAnsi(STR0042),; //Fabricante
			OemToAnsi(Alltrim(STR0043)) ; //Saldo
			COLSIZES 20,50,80,70,30 SIZE 274,124 OF oGruIte PIXEL ON DBLCLICK (DbSeek(xFilial("SB1")+aGruIte[oLbGruIte:nAt,4]),lClicou := .t.,oGruIte:End())
			oLbGruIte:SetArray(aGruIte)
			oLbGruIte:bLine := { || {aGruIte[oLbGruIte:nAt,1],;
			aGruIte[oLbGruIte:nAt,2] ,;
			aGruIte[oLbGruIte:nAt,3] ,;
			aGruIte[oLbGruIte:nAt,5] ,;
			aGruIte[oLbGruIte:nAt,6] }}
			ACTIVATE MSDIALOG oGruIte CENTER
			if !lClicou
				return .f.
			endif
		Endif
	EndIf
	( cQueSB1 )->( dbCloseArea() )
Endif

dbSelectArea("SB1")
cGrupo := SB1->B1_GRUPO
cCodIte := FG_ITESUB(SB1->B1_GRUPO+SB1->B1_CODITE)
if ValType(cCodIte) == "A"
	cGrupo := cCodIte[1]
	cCodIte := cCodIte[2]
endif
if cCodIte != SB1->B1_CODITE .or. cGrupo != SB1->B1_GRUPO
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+cGrupo + cCodIte)
endif
cChave := SB1->B1_COD
//
cDesc   := SB1->B1_DESC
cNomFab := SB1->B1_FABRIC
//
MsProcTxt(STR0044)
ProcessMessage()
dbSelectArea("VAI")
dbSetOrder(4)
if dbSeek(xFilial("VAI")+__cUserID)
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
endif
MsProcTxt(STR0045)
ProcessMessage()
//
DBSelectArea("SB1")
DBSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
//
dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
//
aIteRelP := FG_ITEREL(Nil,SB1->B1_GRUPO,SB1->B1_CODITE,GetNewPar("MV_FMLPECA",'"      "'))
For nCntFor := 1 to Len(aIteRelP)
	DBSelectArea("SBM")
	DBSeek(xFilial("SBM")+aIteRelP[nCntFor,1])
	DbSelectArea("VE1")
	DBSetOrder(1)
	DBSeek(xFilial("VE1")+SBM->BM_CODMAR)
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+aIteRelP[nCntFor,1]+aIteRelP[nCntFor,2])
	aAdd(aIteRelP[nCntFor],SBM->BM_CODMAR)
	aAdd(aIteRelP[nCntFor],VE1->VE1_DESMAR)
	aAdd(aIteRelP[nCntFor],SB1->B1_COD)
next
//
If ( ExistBlock("OX001IRL") )
	aIteRelP := ExecBlock("OX001IRL",.f.,.f.,{aIteRelP})
EndIf
//
If len(aIteRelP) <= 0
	aIteRelP := {{"","","",0,0,"","",""}}
EndIf
//
if Type("oLbIteRelP")=="O"
	oLbIteRelP:nAt := 1
	oLbIteRelP:SetArray(aIteRelP)
	oLbIteRelP:bLine := { || { aIteRelP[oLbIteRelP:nAt,6],;
	aIteRelP[oLbIteRelP:nAt,7],;
	aIteRelP[oLbIteRelP:nAt,8],;
	aIteRelP[oLbIteRelP:nAt,1],;
	aIteRelP[oLbIteRelP:nAt,2],;
	aIteRelP[oLbIteRelP:nAt,3],;
	FG_AlinVlrs(Transform(aIteRelP[oLbIteRelP:nAt,4],SB2->(X3PICTURE("B2_QATU")))),;
	FG_AlinVlrs(Transform(aIteRelP[oLbIteRelP:nAt,5],"@E 999,999,999.99"))}}
	oLbIteRelP:Refresh()
endif
//
DBSelectArea("SB1")
DBSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
//
dbSelectArea("SBM")
DBSetOrder(1)
DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
//
dbSelectArea("SB5")
dbSetOrder(1)
dbSeek(xFilial("SB5")+SB1->B1_COD)
//

for nCntFor := 1 to Len(aVetInfo)
	MsProcTxt(STR0046+" "+aVetInfo[nCntFor,1])
	ProcessMessage()
//	aVetResp[nCntFor] := &(aVetInfo[nCntFor,2])
next
//
dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
MsProcTxt(STR0047)
ProcessMessage()
//
oFamilia:SetFocus()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_PESQUISAR ³ Autor ³ Thiago            ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Botao pesquisar.								 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQUISAR()

Local cAliasSB1   := "SQLSB1"  
aItens := {}       
Private nOpca := 2
if Empty(cCHAVE) .and. Empty(cNomFab) .and. Empty(cDesc) .and. Empty(cFamilia) .and. Empty(cClasse) .and. Empty(cSubCla) .and.  Empty(cMarca) .and. Empty(cModelo) .and. Empty(cAno)
   MsgInfo(STR0048)
   Return(.f.)
Endif

if !Empty(cCHAVE)
	nAchou := Ascan(aCols,{|x| Alltrim(x[1]) == Alltrim(cCHAVE) .and. x[7] == .f.})  
		if nAchou > 0 
			if !aCols[nAchou,Len(aCols[nAchou])]                  
			    MsgStop(STR0049)
				cNomFab  := space(TamSx3("B1_FABRIC")[1])  
				cDesc   := space(TamSx3("B1_DESC")[1])  
				cFamilia := space(TamSx3("VE3_FAMILI")[1])  
				cMarca   := space(TamSx3("VV1_CODMAR")[1])  
				cModelo  := space(TamSx3("VV1_MODVEI")[1])  
				cAno     := space(TamSx3("VV1_FABMOD")[1])  
				cKit     := space(20)
				cLogoEmpr := GetNewPar("MV_DIRFTGC","") + "ologoconsultapeca.GIF"
				cGrupo := space(TamSx3("B1_GRUPO")[1])
				cCHAVE   := space(TamSx3("B1_CODITE")[1]) 
			    Return(.f.)
			Endif
		Endif	
Endif           
cQuery := "SELECT SB1.B1_COD,SB1.B1_DESC,SB1.B1_CODITE,SB2.B2_QATU,SB1.B1_PRV1,SB5.B5_CEME,SB1.B1_FABRIC "
cQuery += "FROM "
cQuery += RetSqlName( "SB1" ) + " SB1 " 
cQuery += "JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD AND SB2.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_ = ' ' "
if !Empty(cFamilia) .or. !Empty(cClasse) .or. !Empty(cSubCla) .or. !Empty(cMarca) .or. !Empty(cModelo) .or. !Empty(cAno)
	cQuery += " INNER JOIN "+RetSqlName("VE3")+" VE3 ON VE3.VE3_FILIAL = '" + xFilial("VE3") + "' AND VE3.VE3_GRUITE = SB1.B1_GRUPO AND VE3.VE3_CODITE = SB1.B1_CODITE AND "
	if !Empty(cFamilia)
		cQuery += "VE3.VE3_FAMILI = '"+cFamilia+"' AND "
	Endif
	if !Empty(cClasse)
		cQuery += "VE3.VE3_CLASSE = '"+cClasse+"' AND "
	Endif
	if !Empty(cSubCla)
		cQuery += "VE3.VE3_SUBCLA = '"+cSubCla+"' AND "
	Endif
	if !Empty(cMarca)
		cQuery += " VE3.VE3_CODMAR = '"+cMarca+"' AND "
	Endif
	if !Empty(cModelo)
		cQuery += " VE3.VE3_MODVEI = '"+cModelo+"' AND "
	Endif
	if !Empty(cAno)
		cQuery += " VE3.VE3_ANOINI <= '"+Alltrim(cAno)+"' AND VE3.VE3_ANOFIN >= '"+Alltrim(cAno)+"' AND "
	Endif
	cQuery += "VE3.D_E_L_E_T_ = ' ' "
Endif	
cQuery += "WHERE " 
cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
if !Empty(cCHAVE)
	cQuery += "SB1.B1_COD = '"+cCHAVE+"' AND "
Endif	
cQuery += "SB2.B2_LOCAL = SB1.B1_LOCPAD AND "
cQuery += "SB1.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )

Do While !( cAliasSB1 )->( Eof() )
     
   if Len(aCols) == 1 .and. Empty(aCols[1,1])
      aCols := {}
   Endif   

   Aadd(aItens,{( cAliasSB1 )->B1_COD,( cAliasSB1 )->B1_CODITE,( cAliasSB1 )->B1_DESC,( cAliasSB1 )->B5_CEME,( cAliasSB1 )->B1_FABRIC,( cAliasSB1 )->B1_PRV1,})

   dbSelectArea(cAliasSB1)
   ( cAliasSB1 )->(dbSkip())

Enddo
(cAliasSB1)->(dbCloseArea())

if Len(aItens) == 0 
   MsgStop(STR0050)
   Return(.t.)
Endif
if Len(aItens) > 1 
    if cPesqui == "0"
	    cPesqui := "1"
		DEFINE MSDIALOG oDlg6 FROM 000,000 TO 018,080 TITLE (STR0051) OF oMainWnd
		@ 001,001 LISTBOX olBox5 FIELDS HEADER (STR0052),; // Codigo interno
		(STR0053),; // Codigo de Item
		(STR0042),; // Fabricante
		(STR0007);  // Aplicação(Truncada)
		COLSIZES 50,20,60,65 SIZE 315,111 OF oDlg6 PIXEL ON DBLCLICK (FS_APLICAPECA(olBox5:nAt), oDlg6:END())
		olBox5:SetArray(aItens)
		olBox5:bLine := { || {  aItens[olBox5:nAt,1] , aItens[olBox5:nAt,2] , aItens[olBox5:nAt,5] , aItens[olBox5:nAt,4] }}
		DEFINE SBUTTON FROM 120,260 TYPE 1 ACTION ( FS_APLICAPECA(olBox5:nAt), oDlg6:End() ) ENABLE OF oDlg6
		DEFINE SBUTTON FROM 120,290 TYPE 2 ACTION ( nOpca := 0, oDlg6:End() ) ENABLE OF oDlg6
		ACTIVATE MSDIALOG oDlg6 CENTER              
	Endif	
Else
	nAchou := Ascan(aCols,{|x| Alltrim(x[1]) == Alltrim(aItens[1,1])})  
	if nAchou > 0 
		if !aCols[nAchou,Len(aCols[nAchou])]                  
		    MsgStop(STR0048)
		    Return(.f.)
		Endif
	Endif	    
	Aadd(aCols,{aItens[1,1],aItens[1,2],aItens[1,3],aItens[1,4],1,aItens[1,6],.f.})
Endif  

if Len(aCols) == 1 .and. Empty(aCols[1,1])
   MsgStop(STR0049)
   Return(.t.)
Endif

if cAplicaPeca == "0"
	FS_PENDENTE(cChave)
	OC008ITEREL("2","")    
	FS_FILPREC()
Endif
cNomFab  := space(TamSx3("B1_FABRIC")[1])  
cDesc   := space(TamSx3("B1_DESC")[1])  
cFamilia := space(TamSx3("VE3_FAMILI")[1])  
cMarca   := space(TamSx3("VV1_CODMAR")[1])  
cModelo  := space(TamSx3("VV1_MODVEI")[1])  
cAno     := space(TamSx3("VV1_FABMOD")[1])  
cKit     := space(20)
cLogoEmpr := GetNewPar("MV_DIRFTGC","") + "ologoconsultapeca.GIF"
cGrupo := space(TamSx3("B1_GRUPO")[1])
cCHAVE   := space(TamSx3("B1_CODITE")[1]) 
if nopca == 0 
  cPesqui := "0"
Endif  


Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OC008ITEREL | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Preenche os itens relacionados na listbox                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC008ITEREL(cPesq,cProdut)
Local nCntFor       
Local i := 0 
Local cCodSB1 := ""
Local cGrupoVal := ""
Local cCodIteVal := "" 
Local cForPad := GetNewPar("MV_FMLPECA",'"      "')   

aItensRel := {}
Private cForVal  := ""
        
if cPesq == "1"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+aCols[n,1])
	lDelet := !aCols[n,Len(aCols[n])]
Elseif cPesq == "2"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+cChave)
	lDelet := .t.
Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+cProdut)
	lDelet := .t.
Endif
cGrupoVal  := SB1->B1_GRUPO
cCodIteVal := SB1->B1_CODITE
cForVal    := &cForPad

//######################################################################
//# Passa os campos para a funcao que retorna o array dos relacionados #
//######################################################################
if lDelet
	aIteRel1 := FG_ITEREL("",cGrupoVal,cCodIteVal,"cForVal")
	For nCntFor := 1 to Len(aIteRel1)
		DBSelectArea("SBM")
		DBSeek(xFilial("SBM")+aIteRel1[nCntFor,1])
		DbSelectArea("VE1")
		DBSetOrder(1)
		DBSeek(xFilial("VE1")+SBM->BM_CODMAR)
		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1")+aIteRel1[nCntFor,1]+aIteRel1[nCntFor,2])
		DBSelectArea("SB2")
		DBSetOrder(1)
		DBSeek(xFilial("SB2")+SB1->B1_COD)
		DBSelectArea("SB5")
		DBSetOrder(1)
		DBSeek(xFilial("SB5")+SB1->B1_COD)
		if !Empty(aIteRel1[nCntFor,1]+aIteRel1[nCntFor,2])
			cCodSB1 := SB1->B1_COD
		Else
			cCodSB1 := ""
		Endif

		if Len(aItensRel) == 1 .and. Empty(aItensRel[1,1])
			aItensRel := {}
		Endif
		Aadd(aItensRel,{SB1->B1_COD,aIteRel1[nCntFor,1],aIteRel1[nCntFor,2],aIteRel1[nCntFor,3],SB5->B5_CEME,SB2->B2_QATU,.f.})
	next
	//
	If ( ExistBlock("OX001IRL") )
		aIteRel1 := ExecBlock("OX001IRL",.f.,.f.,{aIteRel1})
	EndIf
	//
else
	aIteRel1 := {{"","","",0,0,"","",""}}
endif
//
If len(aIteRel1) <= 0
	aIteRel1 := {{"","","",0,0,"","",""}}
EndIf
//
oLbox2:SetArray(aItensRel)
oLbox2:bLine := { || { aItensRel[oLbox2:nAt,01],;
aItensRel[oLbox2:nAt,02],;
aItensRel[oLbox2:nAt,03],;
aItensRel[oLbox2:nAt,04],;
aItensRel[oLbox2:nAt,05],;
Transform(aItensRel[oLbox2:nAt,06],"@E 99999"),;
Transform(aItensRel[oLbox2:nAt,07],"@E 99,999,999.99")}}
oLbox2:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FS_FILPREC  |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o preco publico da peca                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILPREC()  

if cPesqui == "0"
	// #########################################################
	// # Adiciona botões na EnchoiceBar (aNewBot)              #
	// #########################################################
	If ( ExistBlock("M_OXC008 ") )
		ExecBlock("M_OXC008",.f.,.f.)
	EndIf
Endif
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OC008BDESC | Autor |  Thiago               | Data | 28/11/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Tela de consulta por descricao                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC008BDESC()
Local cAliasSB1   := "cQrySB1"
Local cQuery   := ""
Local nPesqAspa:= ""
Local cGruVei  := GetNewPar("MV_GRUVEI","VEI")+space(4-len(GetNewPar("MV_GRUVEI","VEI")))
Local cLocaliz := ""
Local cDesSQL  := ""
Local nOpca    := 0
Local bTroca   := { || stuff(get_descri,AT(",",get_descri),1,"%") }

if Select(cAliasSB1) > 0
	(cAliasSB1)->(dbCloseArea())
Endif

cApCodMar := cMarca
cApModVei := cModelo

dbSelectArea("SB2")
dbSetOrder(1)
//
dbSelectArea("SB5")
dbSetOrder(1)
//
dbSelectArea("SB1")
dbSetOrder(3)
//
aArray := {}
cDesSQL := cDesc
// Retira do texto as ASPAS para frente (caso exista) //
nPesqAspa := AT("'",cDesSQL)
If nPesqAspa > 0
	If nPesqAspa == 1
		cDesSQL := space(len(SB1->B1_DESC))
	Else // nPesqAspa > 1
		cDesSQL := Left(cDesSQL,nPesqAspa-1)
	EndIf
	cDesc := cDesSQL
EndIf
nPesqAspa := AT('"',cDesSQL)
If nPesqAspa > 0
	If nPesqAspa == 1
		cDesSQL := space(len(SB1->B1_DESC))
	Else // nPesqAspa > 1
		cDesSQL := Left(cDesSQL,nPesqAspa-1)
	EndIf
	cDesc := cDesSQL
EndIf
//
while AT(",",cDesSQL) > 0
	cDesSQL := Eval(bTroca)
enddo
//
cQuery := "SELECT SB2.R_E_C_N_O_ SB2REC, SB5.R_E_C_N_O_ SB5REC, B1_COD, B1_CODITE, B1_GRUPO, B1_DESC, B1_LOCPAD FROM "+RetSqlName("SB1")+" SB1 "
if !Empty(cApCodMar) .or. !Empty(cApModVei) 
	cQuery += "INNER JOIN "+RetSqlName("VE3")+" VE3 ON ( VE3_FILIAL = '"+xFilial("VE3")+ "' AND VE3_GRUITE = B1_GRUPO AND VE3_CODITE = B1_CODITE AND VE3_CODMAR = '"+cApCodMar+"' AND "
	if !Empty(cApModVei)
		cQuery += " ( VE3_MODVEI = '"+cApModVei+"' OR VE3_MODVEI =' ') AND "
	Endif	
	if val(cApAno) > 0	.and. VE3->(FieldPos("VE3_ANOMOD")) > 0
		cQuery += " ( VE3_ANOMOD = '"+cApAno+"' OR VE3_ANOMOD = ' ')  AND "
	endif
	cQuery += " VE3.D_E_L_E_T_ = ' ') "
endif

cQuery += "LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5  ON ( SB5.B5_FILIAL = '"+xFilial("SB5")+ "' AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_ = ' ' ) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2  ON ( SB2.B2_FILIAL = '"+xFilial("SB2")+ "' AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' ) "

cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+ "' AND "
cQuery += " SB1.B1_DESC LIKE '"+alltrim(cDesSQL)+"%' AND "

cQuery += " SB1.D_E_L_E_T_ = ' '"
//
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
Do While !( cAliasSB1 )->( Eof() )
	if (cAliasSB1)->B1_GRUPO <> cGruVei
		cLocaliz := ""
		if !Empty((cAliasSB1)->SB5REC)
			SB5->(dbGoto((cAliasSB1)->SB5REC))
			cLocaliz := FM_PRODSBZ((cAliasSB1)->B1_COD,"SB5->B5_LOCALIZ")
			if ExistBlock("LOCAOM110")
				cLocaliz := ExecBlock("LOCAOM110",.f.,.f.,{(cAliasSB1)->B1_COD})
			Endif
		endif
		nSaldo := 0
		if !Empty((cAliasSB1)->SB2REC)
			SB2->(dbGoto((cAliasSB1)->SB2REC))
			nSaldo := SaldoSB2()
		Endif
		aAdd(aArray,{(cAliasSB1)->B1_DESC,(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,cLocaliz,nSaldo, B1_COD})
	Endif
	dbSelectArea(cAliasSB1)
	dbSkip()
Enddo
(cAliasSB1)->(dbCloseArea())
DBSelectArea("SB1")
//
if Len(aArray) == 0
	MsgStop(STR0065,STR0066)
	Return(.f.)
EndIf
//
nOpca := 0
DBSelectArea("SB1")
DBSetOrder(7)
DEFINE MSDIALOG oDlgPesD FROM 000,000 TO 032,080 TITLE STR0067 OF oMainWnd
//  	
@ 003,003 SAY (STR0068 +": "+cDesc) SIZE 300,08 OF oDlgPesD PIXEL COLOR CLR_RED
//
@ 012,002 LISTBOX oLbDesc FIELDS HEADER  (STR0036),;
(STR0034),;
(STR0069),;
(STR0070),;
(STR0071);
COLSIZES 90,20,50,50,50 SIZE 313,228 OF oDlgPesD ON DBLCLICK (OC008PREPEC(aArray[oLbDesc:nAt,6],""),oDlgPesD:End()) PIXEL
oLbDesc:SetArray(aArray)
oLbDesc:bLine := { || { aArray[oLbDesc:nAt,1] , aArray[oLbDesc:nAt,2] , aArray[oLbDesc:nAt,3] , aArray[oLbDesc:nAt,4] , FG_AlinVlrs(Transform(aArray[oLbDesc:nAt,5],SB2->(X3PICTURE("B2_QATU")))) }}
//
ACTIVATE MSDIALOG oDlgPesD CENTER
//
	
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_APLICAPECA ³ Autor ³ Thiago           ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Aplicacao da peca.   						 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_APLICAPECA(cLinha) 
    cAplicaPeca := "1"
    cPesqui := "0"           
    nOpca := 1  
	nAchou := Ascan(aCols,{|x| Alltrim(x[1]) == Alltrim(aItens[cLinha,1])})  
	if nAchou > 0 
		if !aCols[nAchou,Len(aCols[nAchou])]                  
		    MsgStop(STR0049)
		    Return(.f.)
		Endif
	Endif	    
          
	Aadd(aCols,{aItens[cLinha,1],aItens[cLinha,2],aItens[cLinha,3],aItens[cLinha,4],1,aItens[cLinha,6],.f.})
	FS_PENDENTE(aCols[1,1])
	OC008ITEREL("3",aCols[1,1])     
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+aCols[1,1])
	FS_FILPREC()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_PENDENTE ³ Autor ³ Thiago  	        ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Pedidos pendentes.   						 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PENDENTE(cProdut)
Local cSQLSC7 := "SQLSC7"
  
		// Lendo Pedidos Pendentes
cQuery := "SELECT SC7.C7_NUM,SC7.C7_EMISSAO,SC7.C7_QUANT,SC7.C7_QUJE "
cQuery += "FROM "+RetSQLName("SC7")+" SC7 "
cQuery += "WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' AND SC7.C7_PRODUTO = '"+cProdut+"' AND SC7.C7_RESIDUO <> 'S' AND SC7.C7_QUANT <> SC7.C7_QUJE AND "
cQuery += "SC7.D_E_L_E_T_=' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSC7 , .F. , .T. )
		
(cSQLSC7)->(DbGoTop())
While (cSQLSC7)->(!Eof())

    if Len(aPedPen) == 1 .and. Empty(aPedPen[1,1])
       aPedPen := {}
    Endif   
    Aadd(aPedPen,{(cSQLSC7)->C7_NUM,stod((cSQLSC7)->C7_EMISSAO),(cSQLSC7)->C7_QUANT-(cSQLSC7)->C7_QUJE})
    			      
    dbSelectArea(cSQLSC7)
    (cSQLSC7)->(DbSkip())
		      
Enddo     
(cSQLSC7)->(dbCloseArea())  
oLbox9:SetArray(aPedPen)
     oLbox9:bLine := { || { aPedPen[oLbox9:nAt,01],;
     Transform(aPedPen[oLbox9:nAt,02],"@D"),;
   	 Transform(aPedPen[oLbox9:nAt,03],"@E 99999")}}
 	 oLbox9:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_LIMPATELA ³ Autor ³ Thiago  	        ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Limpa tela.			   						 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMPATELA()
           
cCHAVE   := space(TamSx3("B1_CODITE")[1]) 
cNomFab  := space(TamSx3("B1_FABRIC")[1])  
cDesc   := space(TamSx3("B1_DESC")[1])  
cFamilia := space(TamSx3("VE3_FAMILI")[1])  
cMarca   := space(TamSx3("VV1_CODMAR")[1])  
cModelo  := space(TamSx3("VV1_MODVEI")[1])  
cAno     := space(TamSx3("VV1_FABMOD")[1])  
cKit     := space(20)
//
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_APLICACAO ³ Autor ³ Thiago  	        ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Aplicacao da peca.	   						 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_APLICACAO()
Local cAplicacao := "" 
Local nOp := 1
                  
    if cAplic == "0"
		cAplic := "1"
	    dbSelectArea("SB5")
	    dbSetOrder(1)
	    dbSeek(xFilial("SB5")+aCols[n,1])
    
	    cAplicacao := SB5->B5_CEME

		DEFINE MSDIALOG oDlg8 FROM 000,000 TO 020,070 TITLE STR0054 OF oMainWnd     
	
		@ 008,010 GET oMsg2 VAR cAplicacao OF oDlg8 MEMO SIZE 258,110 PIXEL READONLY MEMO FONT (TFont():New('Courier New',0,-13,.T.,.T.))

		DEFINE SBUTTON FROM 125,240 TYPE 1 ACTION (FS_OKAPLIC(nOp),oDlg8:End()) ENABLE OF oDlg8
		ACTIVATE MSDIALOG oDlg8 CENTER 
		if nOp == 1 
		     cAplic := "0"
		Endif
    Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_FOTO ³ Autor ³ Thiago      	        ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Exibe foto/video.	   						 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FOTO()

if Len(aCols) <> 0 
	OFIXC003(aCols[n,1])
Endif	

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_EXPORTAR ³ Autor ³ Thiago             ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Exporta itens da consulta para orçamento.	 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EXPORTAR(cOrcam)   
Local i := 0
Local nCntFor := 0
Local nCntFor2 := 0
Local nCntFor3 := 0

if (Len(aCols) == 1 .and. Empty(aCols[1,1])) .or. (Len(aCols) == 1 .and. aCols[1,Len(aCols[1])])
	MsgStop(STR0055)
	Return(.f.)
Endif
For i:= 1 to Len(aCols)
	if (!aCols[i,Len(aCols[i])])
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+aCols[i,1])        
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2")+aCols[i,1])
		nSdoPecB2 := 0
		While !eof() .and. xFilial("SB2")+SB1->B1_COD == SB2->B2_FILIAL+SB2->B2_COD
			nSdoPecB2 += SB2->B2_QATU
			dbSkip()
		Enddo
		DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
		If Round(aCols[i,6],2) < Round(SB2->B2_CM1,2) .and. nSdoPecB2 > 0 
			MsgStop(STR0056+CHR(10)+CHR(13)+STR0057+SB1->B1_GRUPO+" - "+SB1->B1_CODITE)    
			Return(.f.)
		Endif
		if SB2->B2_QATU == 0
			MsgStop(STR0058+CHR(10)+CHR(13)+STR0056+SB1->B1_GRUPO+" - "+SB1->B1_CODITE)
			Return(.f.)
		Endif 
		if aCols[i,5] == 0 
			MsgStop(STR0059+CHR(10)+CHR(13)+STR0056+SB1->B1_GRUPO+" - "+SB1->B1_CODITE)
			Return(.f.)
		Endif
	Endif
Next
if cOrcam <> "1"
	cNumOrc := GetSXENum("VS1","VS1_NUMORC")
	dbSelectArea("VS1")
	Reclock("VS1",.t.)
	VS1->VS1_FILIAL := xFilial("VS1")
	VS1->VS1_NUMORC := cNumOrc      
	VS1->VS1_DATORC := dDataBase 
	VS1->VS1_STATUS := "0"
	VS1->VS1_DATVAL := dDataBase+GetNewPar("MV_DTLIMIT",0)
	VS1->VS1_TIPORC := "1"
	MsUnlock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0009 ) // Grava Data/Hora na Mudança de Status do Orçamento / Consulta Detalhada de Peças
	EndIf
	nSeq := 1
	For i:= 1 to Len(aCols)
		if (!aCols[i,Len(aCols[i])])
			dbSelectArea("VS3")
			Reclock("VS3",.t.)
			VS3->VS3_FILIAL := xFilial("VS3")
			VS3->VS3_NUMORC := cNumOrc
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+aCols[i,1])
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek(xFilial("SB2")+aCols[i,1])
			VS3->VS3_SEQUEN := strzero(nSeq,3)
			VS3->VS3_GRUITE := SB1->B1_GRUPO
			VS3->VS3_CODITE := SB1->B1_CODITE 
			VS3->VS3_QTDITE := aCols[i,5]
			VS3->VS3_VALPEC := aCols[i,6]*aCols[i,5]
			MsUnlock()
			nSeq += 1
		Endif
	Next
	ConfirmSX8()

	oDlg:End()

	SetKey(VK_F8,Nil)
	SetKey(VK_F4,Nil)
	SetKey(VK_F7,Nil)
	SetKey(VK_F6,Nil)
	SetKey(VK_F11,Nil)
	// Chamada do orcamento por fases
	OFIXX001(,,,4)
	SETKEY(VK_F8,{|| FS_PESQUISAR() })
	SETKEY(VK_F4,{|| FS_APLICACAO() })
	SETKEY(VK_F5,{|| FS_RESULTADO() })
	SETKEY(VK_F7,{|| FS_LIMPATELA() })
	SETKEY(VK_F6,{|| FS_FOTO() })
	SETKEY(VK_F11,{|| FS_FINALIZA() })
Else
	if Len(aCols) > 0
		lOX001Auto := .t.
		lPrimLinha := .t.

		for nCntFor := 1 to Len(aCols)  
		    if (!aCols[nCntFor,Len(aCols[nCntFor])])
				// verifica se o item já foi lancado no orcamento
				lAchouUm := .f.
				lAchou := .f.
				for nCntFor2 := 1 to Len(oGetPecas:aCols)
					// pula itens deletados
					if !oGetPecas:aCols[nCntFor2,Len(oGetPecas:aCols[nCntFor2])]
						// se o item já foi lançado no orçamento deve-se apenas alterar a quantidade    
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek(xFilial("SB1")+aCols[nCntFor,1])
						if SB1->B1_GRUPO == oGetPecas:aCols[nCntFor2,FG_POSVAR("VS3_GRUITE","aHeaderP")] .and.;
							SB1->B1_CODITE == oGetPecas:aCols[nCntFor2,FG_POSVAR("VS3_CODITE","aHeaderP")]     
							lAchou := .t.
							// salva valores da acols para restauração
							nAtual := oGetPecas:nAt
							oGetPecas:nAt := nCntFor2
							n := nCntFor2
							// monta as variáveis de memória
							For nCntFor3:=1 to Len(aHeaderP)
    							&("M->"+aHeaderP[nCntFor3,2]) := oGetPecas:aCols[oGetPecas:nAt,nCntFor3]
							next
							// atualiza quantidade
							M->VS3_QTDITE := aCols[nCntFor,5] + oGetPecas:aCols[nCntFor2,FG_POSVAR("VS3_QTDITE","aHeaderP")]
							// executa o fieldok com os valores posicionados
							__ReadVar := "M->VS3_QTDITE"
							OX001FPOK(.f.)
							// restaura a posição anterior da acols
							oGetPecas:nAt := nAtual
							n := nAtual
							lAchouUm := .t.
							exit
						endif
					endif
				next  
				if !lAchou 
					if !Empty(oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")])
						// adiciona a linha com os valores default
						AADD(oGetPecas:aCols,Array(nUsadoPX01+1))
						oGetPecas:aCols[Len(oGetPecas:aCols),nUsadoPX01+1]:=.F.
						For nCntFor2:=1 to nUsadoPX01
							oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2]:=CriaVar(aHeaderP[nCntFor2,2])
						Next
						oGetPecas:nAt := Len(oGetPecas:aCols)
						n := Len(oGetPecas:aCols)
					endif
				 Endif
				// se o item sofreu alteração de quantidade (já lançado) faz o loop
				if lAchouUm
					loop
				endif
				// quando o item é lançado pela primeira vez ele deve ocupar o lugar do item atual (kit)
				// caso contrário deve-se criar uma nova linha
				if !lPrimLinha
					// adiciona a linha com os valores default
					AADD(oGetPecas:aCols,Array(nUsadoPX01+1))
					oGetPecas:aCols[Len(oGetPecas:aCols),nUsadoPX01+1]:=.F.
					For nCntFor2:=1 to nUsadoPX01
						oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2]:=CriaVar(aHeaderP[nCntFor2,2])
					Next
					oGetPecas:nAt := Len(oGetPecas:aCols)
					n := Len(oGetPecas:aCols)
				endif
				// monta o vetor com os itens necessários      
				
				aVetCmp := {}
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+aCols[nCntFor,1])
				aAdd(aVetCmp,{"VS3_GRUITE",SB1->B1_GRUPO,M->VS3_GRUITE} )
				aAdd(aVetCmp,{"VS3_CODITE",SB1->B1_CODITE,M->VS3_CODITE} )
				aAdd(aVetCmp,{"VS3_FORMUL",M->VS1_FORMUL,       M->VS1_FORMUL} )
				cCodTes := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
				if M->VS1_TIPORC == "2"
					DBSelectArea("SB1")
					DBSetOrder(1)
					DBSeek(xFilial("SB1")+aCols[nCntFor,1])
					DBSetOrder(1)
					DBSelectArea("VOI")
					DBSetOrder(1)
					DBSeek(xFilial("VOI")+M->VS1_TIPTEM)
					if !Empty(VOI->VOI_CODOPE)
						cTesCmp :=  MaTesInt(2,VOI->VOI_CODOPE,M->VS1_CLIFAT,M->VS1_LOJA,"C",SB1->B1_COD)
						aAdd(aVetCmp,{"VS3_CODTES",cTesCmp,M->VS3_CODTES} )
					Else
						aAdd(aVetCmp,{"VS3_CODTES",cCodTes,M->VS3_CODTES} )
					endif
				else                                                            
					aAdd(aVetCmp,{"VS3_CODTES",cCodTes,M->VS3_CODTES} )
				endif
				aAdd(aVetCmp,{"VS3_QTDITE",aCols[nCntFor,5],M->VS3_QTDITE} )
	//			aAdd(aVetCmp,{"VS3_PERDES",(1-(((aItensKit[nCntFor,6]*nValKit)/100)/aItensKit[nCntFor,5]))*100,M->VS3_PERDES} )
				RegToMemory("VS3",.t.)
				// faz o laço para cada item, preenchendo os valores e chamando o FieldOk
				for nCntFor2 := 1 to Len(aVetCmp)
					&("M->"+aVetCmp[nCntFor2,1] ) := aVetCmp[nCntFor2,2]
					__ReadVar := "M->"+aVetCmp[nCntFor2,1]
					if !OX001FPOK(.f.)
						// se o fieldok retornar falso deve-se restaurar a linha anterior (primeira linha) ou exluir a linha (demais linhas)
						if !lPrimLinha
							aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
							For nCntFor3:=1 to Len(aHeaderP)
								&("M->"+aHeaderP[nCntFor3,2]) := oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor3]
							next
						else
							M->VS3_GRUITE := aVetCmp[1,3]
							M->VS3_CODITE := aVetCmp[2,3]
							M->VS3_CODTES := aVetCmp[3,3]
							M->VS3_QTDITE := aVetCmp[4,3]
						endif
						oGetPecas:nAt := Len(oGetPecas:aCols)
						exit
					endif
				next
				lPrimLinha := .f.
			Endif	
		next
		// caso ainda esteja na primeira linha significa que todas os itens já estavam no orçamento ou nenhum item deu certo
//		if lPrimLinha .and. Len(oGetPecas:aCols) > 0
//			aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
//		endif
		// zera o aItensKit e atualiza os valores de tela e acols
//		aItensKit := {}
		oGetPecas:nAt := Len(oGetPecas:aCols)
		n := oGetPecas:nAt
		lOX001Auto := .f.
		OX001ATUF1()
		oGetPecas:oBrowse:refresh()  
		oDlg:End()
		return .t.
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_FINALIZA ³ Autor ³ Thiago             ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Finaliza consulta.							 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FINALIZA()

oDlg:End()                 

              
        
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_CODBAR ³ Autor ³ Thiago               ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Pesquisa por codigo de barra.				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CODBAR()
Local cQAlSB1 := "SQLSB1"
           
If !Empty(cCodbar)
	cQuery := "SELECT SB1.B1_CODBAR FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
	cQuery += "SB1.B1_CODBAR='"+cCodBar+"' AND SB1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
         
    if Empty(( cQAlSB1 )->B1_CODBAR)
       MsgStop(STR0060)
	   (cQAlSB1)->(dbCloseArea())  
       Return(.f.)
       Endif         
	(cQAlSB1)->(dbCloseArea())  
Else
    Return(.t.)
Endif  
  
OC008PREPEC("",Alltrim(cCodbar))
FS_PESQUISAR()
oGetPCons:oBrowse:Refresh()
cCodbar := space(TamSx3("B1_CODBAR")[1])           
oCodbar:SetFocus()		

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_KIT ³ Autor ³ Thiago                  ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Verifica KIT.								 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_KIT()
                        
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+Alltrim(cChave))
cKit := OFIOC040(SB1->B1_GRUPO,SB1->B1_CODITE)
       
dd:= 0
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_MARCA ³ Autor ³ Thiago                ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao no campo marca.    				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MARCA()
Local lRet := .t.

if !Empty(cMarca)
   dbSelectArea("VE1")
   dbSetOrder(1)
   if !dbSeek(xFilial("VE1")+cMarca)
      MsgStop(STR0061)
      lRet := .f.
   Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_FAMILIA ³ Autor ³ Thiago              ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao no campo familia.    				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FAMILIA()
Local lRet := .t. 

if !Empty(cFamilia)
   dbSelectArea("SX5")
   dbSetOrder(1)
   if !dbSeek(xFilial("SX5")+"V7"+cFamilia)
      MsgStop(STR0062)
      lRet := .f.
   Endif
Endif
cPesqui := "0"
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_CLASSE ³ Autor ³ Thiago              ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao no campo classe.    				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CLASSE()
Local lRet := .t. 

if !Empty(cClasse)
   dbSelectArea("SX5")
   dbSetOrder(1)
   if !dbSeek(xFilial("SX5")+"V8"+cClasse)
      MsgStop(STR0074)
      lRet := .f.
   Endif
Endif
cPesqui := "0"
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_SUBCLA ³ Autor ³ Thiago               ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao no campo sub-classe.  				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SUBCLA()
Local lRet := .t. 

if !Empty(cSubCla)
   dbSelectArea("SX5")
   dbSetOrder(1)
   if !dbSeek(xFilial("SX5")+"V9"+cSubCla)
      MsgStop(STR0075)
      lRet := .f.
   Endif
Endif
cPesqui := "0"
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_MODELO ³ Autor ³ Thiago              ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao no campo modelo.    				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MODELO()
Local lRet := .t.

if !Empty(cModelo)
   dbSelectArea("VV2")
   dbSetOrder(4)
   if !dbSeek(xFilial("VV2")+cModelo)
      MsgStop(STR0063)
      lRet := .f.
   Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_OKAPLIC ³ Autor ³ Thiago              ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao no botao de ok na tela de aplicacao da peca.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OKAPLIC(nOp)
nOp := 2
cAplic := "0"
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OC008VLIN ³ Autor ³ Thiago               ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao do linok										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC008VLIN()
if Empty(aCols[n,1]) .or. Empty(aCols[n,2]) .or. Empty(aCols[n,3])
   MsgInfo(STR0064)
   Return(.f.)
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_RESULTADO ³ Autor ³ Thiago            ³ Data ³ 26/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Escolhe o item posicionado na tela de resultados.		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RESULTADO()
if Len(aItens) > 1 
	FS_APLICAPECA(olBox5:nAt) 
	oDlg6:End()
Endif  
aItens := {}
Return(.t.)
