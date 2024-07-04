#INCLUDE "plsa365.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "COLORS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "hatActions.ch"

static aSubEspAlt := {}
Static objCENFUNLGP := CENFUNLGP():New()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA365MNT³ Autor ³ Michele Tatagiba      ³ Data ³ 04.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao da  Rede Referenciada                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
FOI FEITA ESTA FUNCAO PARA DECLARAR AS PRIVATES DEVIDO AO "TABLE OVERFLOW" DA COMPILACAO. (EDUARDO MOTTA-08/11/2001)
/*/
Function PLSA365MNT(cAlias,nReg,nOpc)
Private oFolder
Private oFolder4
Private oFolder7
Private nOpcao		:= nOpc
Private lOk			:= .F.
Private aVetBNG		:= {}
Private aVetBNM		:= {}
Private aVetBNO		:= {}
Private aVetBN8		:= {}
Private aVetBN9		:= {}
Private aVetBZA		:= {}
Private aVetBZB		:= {}
Private aVetDelBNG	:= {}
Private aVetDelBNM	:= {}
Private aVetDelBNO	:= {}
Private aVetDelBN8	:= {}
Private aVetDelBN9	:= {}
Private aVetDelBZA	:= {}
Private aVetDelBZB	:= {}
Private aSvAtela	:= {{},{},{}}
Private aSvAGets	:= {{},{},{}}
Private aTela		:={}
Private aGets		:={}
Private oEnc01
Private oGet02
Private oGet03
Private oGet06
Private oGet07
Private oGet35
Private oGet47
Private oGet48
Private oGet49
Private oGet50
Private oGet51
Private oGet58
Private oGet60

Private aCab02 := {}
Private aCab03	:= {}
Private aCab04	:= {}
Private aCab06	:= {}
Private aCab07	:= {}
Private aCab09	:= {}
Private aCab10	:= {}
Private aCab16	:= {}
Private aCab18	:= {}
Private aCab19	:= {}
Private aCab20	:= {}
Private aCab21	:= {}
Private aCab23	:= {}
Private aCab32	:= {}
Private aCab35	:= {}
Private aCab47	:= {}
Private aCab48	:= {}
Private aCab49	:= {}
Private aCab50	:= {}
Private aCab51	:= {}
Private aCab58	:= {}
Private aCab52	:= {}
Private aCab53	:= {}

Private aDad02	:= {}
Private aDad03	:= {}
Private aDad04	:= {}
Private aDad06	:= {}
Private aDad07	:= {}
Private aDad09	:= {}
Private aDad10	:= {}
Private aDad16	:= {}
Private aDad18	:= {}
Private aDad19	:= {}
Private aDad20	:= {}
Private aDad21	:= {}
Private aDad23	:= {}
Private aDad32	:= {}
Private aDad35	:= {}
Private aDad47	:= {}
Private aDad48	:= {}
Private aDad49	:= {}
Private aDad51	:= {}
Private aDad58	:= {}

Private cCodInt		:= ""
Private cCodLoc		:= ""
Private cLocal		:= ""
Private cCodRda		:= ""
Private cDesInt		:= ""
Private cCodEsp		:= ""
Private cDesEsp		:= ""
Private cCodSub		:= ""
Private cCodMed		:= ""
Private cCodTab		:= ""
Private cCodOpc		:= ""
Private cPrePRF		:= "01"
Private lProgRR		:= .T.
Private cCodQuest	:= ""
Private cProQuest	:= ""
Private cCodPla		:= ""
Private cCodGru		:= ""
Private lCarTDE		:= .F.
Private INCLUI		:= .F.
Private lRetorno	:= .F.
Private lUpdBC0 	:= .F.
Private aHeadBLG	:= {}
Private aColsBLG	:= {}
Private aVetBLG		:= {}
Private aVetConBLG	:= {}
Private aHeadBLH	:= {}
Private aColsBLH	:= {}
Private aVetBLH		:= {}
Private aVetConBLH	:= {}
Private aHeadPer	:= {}
Private aColsPer	:= {}
Private aVetPer		:= {}
Private cCodigo		:= ""
Private oSayLoc01,oSayLoc02
Private oSayEsp01,oSayEsp02
Private oSay01,oSay02
Private oSayOpe01,oSayOpe02
Private oBrwCtb
Private oBrwBZ2
Private oBrwRda
Private oBrwFaixa
Private oBrwTaxa
Private oBrwB30 
Private oBrwB59
Private oGet75 
Private oGet30 

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

Return ManutRef(cAlias,nReg,nOpc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ManutRef  ³ Autor ³ Eduardo Motta         ³ Data ³ 23.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao da  Rede Ferefenciada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSA360MNT(cAlias,nReg,nOpc)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ManutRef(cAlias,nReg,nOpc)
Local nControl	:= 0
Local nControl4 := 0
Local nControl7 := 0
Local aPages    := {}, aTitles:= {}
Local aPages4   := {}, aTitles4:= {}
Local aPages7   := {}, aTitles7:= {}
Local oDlg, ni
Local oFont
Local aFolders
Local aFolders4
Local aFolders7
Local nOpca     := 0
Local oWnd      := GetWndDefault()
Local oFont01
Local bFilter
Local cDesLoc   := ""
Local lLock     := .F.
Local lBakInclui
Local aVetGet02 :={}
Local aVetGet03 :={}
Local aVetGet07 :={}
Local aVetGet35 :={}
Local aVetGet47 :={}
Local aVetGet48 :={}
Local aVetGet49 :={}
Local aVetGet50 :={}
Local aVetGet51 :={}
Local aVetGet58 :={}
Local aVetGet59 :={}  //Majoração  
Local aVetGet60 :={}  //Acreditacoes 
Local aVetGet75 :={}    
Local aVetGet30 :={}  //Associacao  

Local nFolMaj	:= 10
Local nFaixDes  := 11
Local nFolAss   := 12

Local aTrbCtb   := {}
Local aTrbRda   := {}
Local aTrbFaixa := {}
Local aTrbTaxa	:= {}
Local aTrbB30	:= {}

Local nPosIntBLH
Local nPosLocBLH
Local nPosEspBLH
Local nPosSubBLH
Local nPosTabBLH
Local nPosOpcBLH
Local nPosPrfBLH
Local nOrdBAU := BAU->(IndexOrd())
Local nRecBAU := BAU->(RECNO())


LOCAL oGrupo
Local bCancel  	:= {|| If(MsgYesNo(__cMsgAban),(nOpca := 0,oDlg:End(), aSize(aSubEspAlt, 0) ,IIF(lUpdBC0,MsgInfo("As manutenções realizadas nos Procedimentos Autorizados irão permanecer."),) ),.F.) }
LOCAL lSalv
Local aTmp
Local aTmp2
Local nCt1
Local nCt2
Local cCdOpe
Local cCdLoc
Local cCdEsp
Local lPerExc

Local aSize
Local aInfo
Local aObjects
Local aPosObj
Local aPosObj2
Local aPosObj3
Local nAltura
Local i
Local aBot:={}  
Local nFolder := 6
Local nFolAux := 5

LOCAL aButtons:= {}      
Local aButEsp := {}
LOCAL lTabB58 := .F.
LOCAL lTabB51 := .F.

Local nPosLocal    := 0
Local nPosOpe      := 0
Local nPosCodAX    := 0  //Variaveis usadas na exclusão do localxEspecialidades
Local nPosOpeAX    := 0
Local nPosEspAX    := 0

//Integração GRC
Private aEspLocAux := {}
Private aLocAux 	 := {}
Private aProcsNAut := {}
Private aOperadoras:= {}

PRIVATE xnFolder   := 1 

//Odontologico
PRIVATE aHeaderFCP  := {}
PRIVATE aColsFCP    := {}  
PRIVATE aVetTrabFCP := {}                       

If ExistBlock("PL365ROT")
	nOpc := Execblock("PL365ROT",.F.,.F.,{nopc})
Else
	nOpc := 4		
Endif

N := 1

aFolders  := {__cNameBAU,STR0001,STR0002,STR0050,;
				STR0051,STR0004,STR0005,STR0054,"RDA x Planos"} //"Operadoras"###"Parametros Contabilidade"###"Horario Especial X RDA"###"Faixa de Desconto"###"Local de Atendimento"###"Especialidades"###"Taxa de Comercialização"

If PLSALIASEX("B59")
	Aadd(aFolders, OemtoAnsi("Majoração"))
	nFolMaj := Ascan(aFolders, OemtoAnsi("Majoração")) 
Endif

If PLSALIASEX("B75")
	Aadd(aFolders, "Desc Faixa x RDA")
	nFaixDes := Ascan(aFolders, "Desc Faixa x RDA")
Endif

If PLSALIASEX("B62")
	Aadd(aFolders, OemtoAnsi("Associação")) // Associação
	nFolAss := Ascan(aFolders, OemtoAnsi("Associação")) 
Endif

//aFolders2 := {STR0006}//Procedimentos autorizados 


aFolders4 := {STR0001,STR0023,STR0024,STR0022,STR0018,STR0025, STR0014,STR0015} //"Operadoras"###"Avaliacao"###"Relacionamento"###"Procedimentos"###"Material"###"Medicamentos"###"Taxas"###"Diarias"

         
aFolders7 := {STR0016,STR0026,STR0027,STR0028} //"Filme"###"Divisao Remuneracao"###"Diferenciacao da Ref./U.S. por Unidade"###"Grupo de Servicos

If !PLSALIASEXI("B40") .And. !PLSALIASEXI("B49")
	AaDd(aFolders7, OemtoAnsi(STR0056)) //"Acesso portal"
Endif

If PLSALIASEX("B58")
	AaDd(aFolders7, OemtoAnsi(STR0066)) //"Desc Fx Evento"
Endif

If PLSALIASEX("B24")
	AaDd(aFolders7, OemtoAnsi(STR0062)) //Tabela de preço
Endif

AaDd(aFolders7, OemtoAnsi("Acreditacoes")) //Acreditacoes

SetEnch("")
For nI := 1 to Len(aFolders)
	Aadd(aTitles,OemtoAnsi(aFolders[nI]))
	Aadd(aPages,"HEADER "+Trim(Str(nI,2)))
	nControl++
Next
SetEnch("")

SetEnch("")
For nI := 1 to Len(aFolders4)
	Aadd(aTitles4,OemtoAnsi(aFolders4[nI]))
	Aadd(aPages4,"HEADER "+Trim(Str(nI,2)))
	nControl4++
Next
SetEnch("")

For nI := 1 to Len(aFolders7)
	Aadd(aTitles7,OemtoAnsi(aFolders7[nI]))
	Aadd(aPages7,"HEADER "+Trim(Str(nI,2)))
	nControl7++
Next

DEFINE FONT oFont01 NAME "Arial" SIZE 0,-16 BOLD

DbSelectArea("BAU")
BB0->(RegToMemory("BB0",.F.))
BAU->(RegToMemory("BAU",.F.))

SETAPILHA()

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, aSize[ 3 ] * 0.07, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj2 := {}
nAltura := (aPosObj[1][3] - aPosObj[1][1]) / 2
aAdd(aPosObj2, { aPosObj[1][1], aPosObj[1][2], aPosObj[1][1] + nAltura - 1, (aPosObj[1][4] / 2) - 1 })
aAdd(aPosObj2, { aPosObj[1][1] + nAltura + 1, aPosObj[1][2], aPosObj[1][3], (aPosObj[1][4] / 2) - 1 })
aAdd(aPosObj2, { aPosObj[1][1], (aPosObj[1][4] / 2) + 1, aPosObj[1][1] + nAltura - 1, aPosObj[1][4] })
aAdd(aPosObj2, { aPosObj[1][1] + nAltura + 1, (aPosObj[1][4] / 2) + 1, aPosObj[1][3], aPosObj[1][4] })

aObjects := {}
AAdd( aObjects, { 1, aPosObj[2][4] * 0.275, .t., .f. } )
AAdd( aObjects, { 1, 1, .t., .t., .t. } )
aInfo := { 0, 0, aPosObj[2][3] - 2, aPosObj[2][4] - 12, 3, 3 }
aPosObj3 := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CABECALHO INFORMATIVO                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPosObj2[1], Round(((nAltura - (nAltura / 2)) / 2) + aPosObj2[1][1], 0))
aAdd(aPosObj2[2], Round(((nAltura - (nAltura / 2)) / 2) + aPosObj2[2][1], 0))
aAdd(aPosObj2[3], Round(((nAltura - (nAltura / 2)) / 2) + aPosObj2[3][1], 0))
aAdd(aPosObj2[4], Round(((nAltura - (nAltura / 2)) / 2) + aPosObj2[4][1], 0))

@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGrupo TO aPosObj2[1][3], aPosObj2[1][4] PIXEL OF oDlg LABEL " "+__cNameBAU+" "  COLOR CLR_HBLUE, CLR_HRED 

PLSSAYESP(aPosObj2[1][5]+1,;
          aPosObj2[1][2]+5,;
          { || M->BAU_CODIGO+"  -  "+M->BAU_NOME },;
          aPosObj2[1][4]-5,;
          aPosObj2[1][3]-1,;
          oDlg,;
          AdvFont,;
          CLR_HBLUE,;
          "oSay01")

	@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGrupo TO aPosObj2[2][3], aPosObj2[2][4] PIXEL OF oDlg LABEL STR0029  COLOR CLR_HBLUE, CLR_HRED //" Localidade "

PLSSAYESP(aPosObj2[2][5]+1,;
          aPosObj2[2][2]+5,;
          { || cCodLoc+" - "+cDesLoc },;
          aPosObj2[2][4]-5,;
          aPosObj2[2][3]-1,;
          oDlg,;
          AdvFont,;
          CLR_HBLUE,;
          "oSayLoc01")

	@ aPosObj2[3][1], aPosObj2[3][2] GROUP oGrupo TO aPosObj2[3][3], aPosObj2[3][4] PIXEL OF oDlg LABEL STR0030 COLOR CLR_HBLUE, CLR_HRED        //" Operadora "

PLSSAYESP(aPosObj2[3][5]+1,;
          aPosObj2[3][2]+5,;
          { || " ",cCodInt+"  -  "+cDesInt },;          
          aPosObj2[3][4]-5,;
          aPosObj2[3][3]-1,;
          oDlg,;
          AdvFont,;
          CLR_HBLUE,;
          "oSayOpe01")
  
	@ aPosObj2[4][1], aPosObj2[4][2] GROUP oGrupo TO aPosObj2[4][3], aPosObj2[4][4] PIXEL OF oDlg LABEL STR0031 COLOR CLR_HBLUE, CLR_HRED        //" Especialidade "

PLSSAYESP(aPosObj2[4][5]+1,;
          aPosObj2[4][2]+5,;
          { || cCodEsp+" - "+cDesEsp },;
          aPosObj2[4][4]-5,;
          aPosObj2[4][3]-1,;
          oDlg,;
          AdvFont,;
          CLR_HBLUE,;
          "oSayEsp01")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de todos os folders do dialogo            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Folder principal da tela NIVEL 1
oFolder := TFolder():New(aPosObj[2][1],aPosObj[2][2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[2][3],aPosObj[2][4],)
oFolder:aDialogs[1]:oFont  := oDlg:oFont
oFolder:aDialogs[3]:oFont  := oDlg:oFont
oFolder:bChange             := {|nFolder| cCodInt := oGet02:aCols[oGet02:Linha(),oGet02:FieldPos("BAW_CODINT")],AFOLChg(nFolder),AtuCabTel()}

// Folder dentro do Local de Atendimento
oFolder7 := TFolder():New(aPosObj3[2][1],aPosObj3[2][2],aTitles7,aPages7,oFolder:aDialogs[6],,,,.T.,.F.,aPosObj3[2][3],aPosObj3[2][4])
oFolder7:aDialogs[1]:oFont := oDlg:oFont
oFolder7:aDialogs[2]:oFont := oDlg:oFont
//endif
// Declaracao das GETDADOS do Folder Principal NIVEL 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - Enchoice - PLANO DE SAUDE                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
BAU->(DBSetOrder(nOrdBAU))
BAU->(DBGoto(nRecBAU))
dbSelectArea("BAU")
oEnc02:= MsMGet():New("BAU" ,nReg ,K_Visualizar,,,,,{3,3,aPosObj[2][4]-15,aPosObj[2][3]-4},,,,,,oFolder:aDialogs[1],,,.F.,"aSvATela[2]")

aSvATela[2] := aClone(aTela)
aSvAGets[2] := aClone(aGets)

cCodigo := M->BAU_CODIGO

// Declaracao das GETDADOS do Folder Operadora NIVEL 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - Operadora                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BAW",aVetGet02,nOpc)            
aCab02  := aClone(aHeader)
cCodInt := GDFieldGet("BAW_CODINT",1,nil,aCab02,aCols)

AtuCabTel()
oGet02            := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil, oFolder:aDialogs[2],nil,  ,nil,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BAW",nOpc,aFolders4[1],nil,nil,nil,aVetGet02,'PLSBAWVld','PLSBAWDel',nil)
oGet02:bLostFocus := {||cCodInt := oGet02:aCols[oGet02:Linha(),oGet02:FieldPos("BAW_CODINT",aCab02)],cDesInt := oGet02:aCols[oGet02:Linha(),oGet02:FieldPos("BAW_DESINT",aCab02)],AtuCabTel(),oBrwCtb:forcerefresh(oGet02),oBrwRda:forcerefresh(oGet02),oBrwFaixa:forcerefresh(oGet02),oGet07:forcerefresh(oGet02),oGet03:forcerefresh(oGet02),oBrwTaxa:forcerefresh(oGet02)}
oGet02:bChange    := {|| Eval(oGet02:bLostFocus),Change02()}

CargaCols("BHU",aTrbCtb,nOpc)
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,PLRETPOS("BHU_CODINT",aHeader,.T.)]==cCodInt}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> CONTABILIDADE                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwCtb := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[3],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BHU",nOpc,STR0002,nil,nil,nil,aTrbCtb,nil,nil,bFilter) //"Parametros Contabilidade"
oBrwCtb:oPai       := oGet02
oBrwCtb:aOrigem    := {"BAW_CODINT"}
oBrwCtb:aRelac     := {"BHU_CODINT"}

CargaCols("BY5",aTrbRda,nOpc)
bFilter := {|nLine,aCols,aHeader|aCols[nLine,PLRETPOS("BY5_CODINT",aHeader,.T.)]==cCodInt}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> HORARIO ESPECIAL X RDA                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwRda := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[4],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BY5",nOpc,STR0050,nil,nil,nil,aTrbRda,'PlsVldBY5',nil,bFilter) //"Horario Especial X RDA"

CargaCols("BY6",aTrbFaixa,nOpc)
bFilter := {|nLine,aCols,aHeader|aCols[nLine,PLRETPOS("BY6_CODINT",aHeader,.T.)]==cCodInt}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> FAIXA DE DESCONTO	                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwFaixa := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[5],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BY6",nOpc,STR0051,nil,nil,nil,aTrbFaixa,'PlsVigBY6',nil,bFilter) //"Faixa de Desconto"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 04 - LOCAL DE ATENDIMENTO                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// obs: Caso este browse mude de dialogo mudar tambem a declaracao do folder oFolder2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a getdados dos Locais de atendimento. Necessario para retirar os campos Data de US,   ³
//³ Data ate US, Data de Filme e Data ate US.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols   := {}
aHeader := {}
lSalv   := Inclui

If nOpc == K_Incluir                         
   Store Header "BB8" TO aHeader For .T. .And. !(SX3->X3_CAMPO $ "BB8_DTDEUS,BB8_DTATUS")   
   Store COLS Blank "BB8" TO aCols FROM aHeader
Else
   Store Header "BB8" TO aHeader For .T.
   
   BB8->(DbSetOrder(1))
   If ! BB8->(MsSeek(xFilial("BB8")+cCodigo))
      n := 1   
   	  Inclui := .T.      
      Store COLS Blank "BB8" TO aCols FROM aHeader
 	  Inclui := lSalv      
   Else
      Store COLS "BB8" TO aCols FROM aHeader VETTRAB aVetGet07 While xFilial("BB8")+cCodigo == BB8->(BB8_FILIAL+BB8_CODIGO)
   Endif   
Endif               
              
aCab07  := aClone(aHeader)
cCodLoc := GdFieldGet("BB8_CODLOC",1,nil,aHeader,aCols)
cDesLoc := GdFieldGet("BB8_DESLOC",1,nil,aHeader,aCols)
cLocal := GdFieldGet("BB8_LOCAL",1,nil,aHeader,aCols)
If ExistBlock("PL365BB8")
	aButEsp := AClone(Execblock("PL365BB8",.F.,.F.,{"1",aButEsp}))
EndIf

bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BB8_CODINT",aHeader)]==cCodInt }
oGet07            := TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3],nil  ,oFolder:aDialogs[6],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BB8",nOpc,aFolders[6],nil,nil,nil,aVetGet07,'PLSBB8Vld','PLSBB8Del',bFilter,If(ExistBlock("PL365BB8"),{|| Execblock("PL365BB8",.F.,.F.,{"2"}) },{|| }),aButEsp,,If(ExistBlock("PL365BB8"),{|| Execblock("PL365BB8",.F.,.F.,{"3"}) },{|| }))
oGet07:bLostFocus := {||cLocal := oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_LOCAL",.T.,aCab07)],cCodLoc := oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_CODLOC",.T.,aCab07)],cDesLoc := Posicione("BD1",1,xFilial("BD1")+cCodInt+oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_LOCAL",.T.,aCab07)],"BD1_DESLOC"),oSayLoc01:Refresh(),oSayLoc02:Refresh()}
oGet07:bChange    := {||Eval(oGet07:bLostFocus),Change07(lTabB58,lTabB51),ChangeBRW()}
oGet07:oPai       := oGet02
oGet07:aOrigem    := {"BAW_CODINT"}
oGet07:aRelac     := {"BB8_CODINT"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 03 - LOCAL DE ATENDIMENTO X FILME             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BPI",aVetGet35,nOpc)
aCab35            := aClone(aHeader)
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BPI_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("BPI_CODLOC",aHeader)]==cCodLoc }
oGet35            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[1],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BPI",nOpc,aFolders7[1],nil,nil,nil,aVetGet35,,'PLSBPIDel',bFilter) 
oGet35:cVldLine := 'PLSVLDVIG("BPI",nOpcao,oGet35,"BPI_VIGDE","BPI_VIGATE")'
oGet35:oPai       := oGet07
oGet35:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
oGet35:aRelac     := {"BPI_CODINT","BPI_CODLOC"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 08 - DIVISAO DE REMUNERACAO                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BZA",aVetGet47,nOpc)
aCab47            := aClone(aHeader)
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BZA_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("BZA_CODLOC",aHeader)]==cCodLoc }
oGet47            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BZA",nOpc,aFolders7[2],nil,nil,nil,aVetGet47,,,bFilter)
oGet47:oPai       := oGet07
oGet47:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
oGet47:aRelac     := {"BZA_CODINT","BZA_CODLOC"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 09 - U.S. por unidade                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CargaCols("BCK",aVetGet48,nOpc)
aCab48            := aClone(aHeader)
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BCK_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("BCK_CODLOC",aHeader)]==cCodLoc }
oGet48            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[3],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BCK",nOpc,aFolders7[3],nil,nil,nil,aVetGet48,,,bFilter)
oGet48:oPai       := oGet07
oGet48:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
oGet48:aRelac     := {"BCK_CODINT","BCK_CODLOC"}
oGet48:cVldLine   := 'PLSXANAFAI( { "BCK_CODUNI" },"BCK_VIGINI","BCK_VIGFIN",n)'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 09 - Grupo de servico                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CargaCols("BIN",aVetGet49,nOpc)
aCab49            := aClone(aHeader)
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BIN_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("BIN_CODLOC",aHeader)]==cCodLoc }
oGet49            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[4],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BIN",nOpc,aFolders7[4],nil,nil,nil,aVetGet49,,,bFilter)
oGet49:oPai       := oGet07
oGet49:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
oGet49:aRelac     := {"BIN_CODINT","BIN_CODLOC"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 10 - Acesso ao Portal						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PLSALIASEXI("B40") .And. !PLSALIASEXI("B49")
	CargaCols("BSO",aVetGet50,nOpc)
	aCab50            := aClone(aHeader)
	bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BSO_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("BSO_CODLOC",aHeader)]==cCodLoc }
	oGet50            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[nFolAux],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BSO",nOpc,aFolders7[nFolAux],nil,nil,nil,aVetGet50,,,bFilter)
	oGet50:oPai       := oGet07
	oGet50:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
	oGet50:aRelac     := {"BSO_CODINT","BSO_CODLOC"}
	nFolAux++
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 11 - Desc Fx Evento							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B58")
	CargaCols("B58",aVetGet58,nOpc)
	aCab58            := aClone(aHeader)
	bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B58_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("B58_CODLOC",aHeader)]==cCodLoc }
	oGet58            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[nFolAux],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B58",nOpc,aFolders7[nFolAux],nil,nil,nil,aVetGet58,,,bFilter)
	oGet58:oPai       := oGet07
	oGet58:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
	oGet58:aRelac     := {"B58_CODINT","B58_CODLOC"}
	oGet58:cVldLine   := 'PlsVldDfe("B58",.F.,Nil,oGet58)'
    lTabB58 		  := .T.
    nFolAux++
EndIf
  
If PLSALIASEX("B24") 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 11 - Tabelas de preco.						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CargaCols("B24",aVetGet51,nOpc)
	aCab51            := aClone(aHeader)
	bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B24_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("B24_CODLOC",aHeader)]==cCodLoc }
	oGet51            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[nFolAux],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B24",nOpc,aFolders7[nFolAux],nil,nil,nil,aVetGet51,,,bFilter)
	oGet51:oPai       := oGet07
	oGet51:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
	oGet51:aRelac     := {"B24_CODINT","B24_CODLOC"}
	oGet51:cVldLine   := 'PLSVLDVIG("B24",nOpcao,oGet51,"B24_VIGINI","B24_VIGFIN",{1,M->B24_TABPRE,"B24_TABPRE"})'
	lTabB51 		  := .T.
	nFolAux++
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 12 - Acreditacoes							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("B7P",aVetGet60,nOpc)
aCab52            := aClone(aHeader)
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B7P_CODINT",aHeader)]==cCodInt .And. aCols[nLine,GdFieldPos("B7P_CODLOC",aHeader)]==cCodLoc }
oGet60            := TPLSBrw():New(003,003,aPosObj3[2][3]-4,aPosObj3[2][4]-15,nil  ,oFolder7:aDialogs[nFolAux],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B7P",nOpc,aFolders7[nFolAux],nil,nil,nil,aVetGet60,,,bFilter)
oGet60:oPai       := oGet07
oGet60:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
oGet60:aRelac     := {"B7P_CODINT","B7P_CODLOC"}
oGet60:cVldLine   := 'PLSVLDACR(oGet60)'
nFolAux++
// Declaracao das GETDADOS do Folder LOCAL DE ATENDIMENTO NIVEL 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - ESPECIALIDADES - local de atendimento    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BAX",aVetGet03,nOpc)
aCab03            := aClone(aHeader)                                                     
bFilter           := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BAX_CODINT",aHeader)]==cCodInt .and. aCols[nLine,GdFieldPos("BAX_CODLOC",aHeader)]==cCodLoc}
oGet03            := TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3]+100,nil  ,oFolder:aDialogs[7],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BAX",nOpc,aFolders[7],nil,nil,nil,aVetGet03,'PLSBAXVld','PLSBAXDel',bFilter)
oGet03:bLostFocus := {||cCodEsp := oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_CODESP",.T.,aCab03)],cDesEsp := If(oGet03:aCols[1,oGet03:PLRETPOS("BAX_CODLOC",.F.,aCab03)] == cCodLoc .And. !Empty(cCodEsp),oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_DESESP",.T.,aCab03)],""),cCodSub := oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_CODSUB",.T.,aCab03)]}//,oSayEsp01:Refresh(),oSayEsp02:Refresh()}
oGet03:bChange    := {||Eval(oGet03:bLostFocus),oSayEsp01:Refresh(),oSayEsp02:Refresh(),PlsIniBC0("ALL")}
oGet03:oPai       := oGet07
oGet03:aOrigem    := {"BB8_CODINT","BB8_CODLOC"}
oGet03:aRelac     := {"BAX_CODINT","BAX_CODLOC"}
oGet03:oBrowse:oBrowse:bAdd := { || PLS365TES() }

cCodEsp := GdFieldGet("BAX_CODESP",1,nil,aHeader,aCols)
cCodSub := GdFieldGet("BAX_CODSUB",1,nil,aHeader,aCols)
cDesEsp := If(!Empty(cDesLoc),GdFieldGet("BAX_DESESP",1,nil,aHeader,aCols),"")

TSay():New(aPosObj3[1][3]+110,110,{||'Atenção: Os cadastros relacionados a especialidades foram migrados para o submenu "Especialidade x Cadastros Relacionados" disponível na tela principal do Cadastro de RDA.'},oFolder:aDialogs[7],,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,500,500)
//nao tirar linha abaixo comentada
//@ 053,25 BUTTON "Complemento"  SIZE 50,13 ACTION (!(oGet10:IsDeleted(oGet10:Linha())) .AND. PlsProcTDE(aHeadBLH,aColsBLH,aVetBLH,nOpc,bScanBLH,bFiltBLH,"BLH",aVetConBLH,"")) Pixel OF oFolder3:aDialogs[2] When lRetorno

lBakInclui := INCLUI
Store Header "BLH" to aHeadBLH For .T.
nPosIntBLH := GdFieldPos("BLH_CODINT",aHeadBLH)
nPosLocBLH := GdFieldPos("BLH_CODLOC",aHeadBLH)
nPosEspBLH := GdFieldPos("BLH_CODESP",aHeadBLH)
nPosSubBLH := GdFieldPos("BLH_CODSUB",aHeadBLH)
nPosTabBLH := GdFieldPos("BLH_CODTAB",aHeadBLH)
nPosOpcBLH := GdFieldPos("BLH_CODPRO",aHeadBLH)
nPosPrfBLH := GdFieldPos("BLH_CODPRF",aHeadBLH)

DbSelectArea("BLH")
DbSetOrder(1)
If MsSeek(xFilial("BLH")+cCodigo)
	INCLUI := .F.
	Store COLS "BLH" TO aColsBLH FROM aHeadBLH VETTRAB aVetBLH While xFilial("BLH") == BLH->BLH_FILIAL .and. cCodigo == BLH->BLH_CODIGO
Else
	n := 1
	INCLUI  := .T.
	Store COLS Blank "BLH" TO aColsBLH FROM aHeadBLH
EndIf
INCLUI  := lBakInclui

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> TAXA DE COMERCIALIZACAO                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CargaCols("BYZ",aTrbTaxa,nOpc)
bFilter := {|nLine,aCols,aHeader|aCols[nLine,PLRETPOS("BYZ_CODINT",aHeader,.T.)]==cCodInt}
oBrwTaxa := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[8],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BYZ",nOpc,STR0054,nil,nil,nil,aTrbTaxa,nil,nil,bFilter) //"Taxa de Comercializacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 9 -> RDA x PLANOS                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B30")
	CargaCols("B30",aTrbB30,nOpc)
	bFilter := {|nLine,aCols,aHeader|aCols[nLine,PLRETPOS("B30_CODINT",aHeader,.T.)]==cCodInt}
	oBrwB30 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[9],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B30",nOpc,"RDA x Planos",nil,nil,nil,aTrbB30,nil,nil,bFilter) //
	oBrwB30:cVldLine := 'PlDupB30()'
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 10 - Majoração                          		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B59")
	CargaCols("B59",aVetGet59,nOpc)
	oBrwB59:= TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nFolMaj],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B59",nOpc,aFolders[nFolMaj],nil,nil,nil,aVetGet59)
	oBrwB59:cVldLine   := 'PlsVldB59()'  
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 11 - Desc Fx Evento   	                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B75")
	CargaCols("B75",aVetGet75,nOpc)
	oGet75 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nFaixDes],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B75",nOpc,aFolders[nFaixDes],nil,nil,nil,aVetGet75)
	oGet75:cVldLine   := 'PlsVldDfe("B75",.F.,Nil,oGet75)'  
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 12 - Associacao                         		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B62")
	CargaCols("B62",aVetGet30,nOpc)
	oGet30 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nFolAss],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B62",nOpc,aFolders[nFolAss],nil,nil,nil,aVetGet30)
	oGet30:cVldLine   := 'PlsVldB62()'  
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Odontologico...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If GetNewPar("MV_PLATIOD","0") == '1' .And. PLSALIASEX("BZ2")
	aadd(aButtons,{"PRECO",{ || PLSA365FCP(nOpc) },"Faixa x Condicao de Pagamento","Fx.x Cond"})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para incluir novo botao na enchoice                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de botoes de apoio...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL365BOT1")
   aBot := ExecBlock("PL365BOT1",.F.,.F.,{nOpc,cCodigo,cCodLoc,cCodEsp})
   If ValType(aBot) == "A" 
       For i:=1 to Len(aBot)
       	   aadd(aButtons,{aBot[i,1],aBot[i,2],aBot[i,3],aBot[i,4]})
       Next i	
   EndIf
Endif

BAU->(DBSetOrder(nOrdBAU))
BAU->(DBGoto(nRecBAU))

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guardando no array as informações referentes a operadora       ³
//³da rede de atendimento para utilização na integração PLS x GRC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
aOps := aClone(oGet02:oBrowse:aCols)

ACTIVATE DIALOG oDlg ON INIT ( EnchoiceBar(oDlg, {|| If( Plsa365TOk(nOpc) .And. If(ExistBlock("PL365VAL"),ExecBlock("PL365VAL",.F.,.F.),.T.),(nOpca:=1,oDlg:End(),.F.),.f.) },bCancel,.F.,aButtons )) Centered

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validação do usuario antes da gravação.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL365CHK")     
   ExecBlock("PL365CHK",.F.,.F.,{nOpca,BAU->BAU_CODIGO,cCodLoc,cCodEsp})
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Integridade entre arquivos...				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPerExc := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Excluindo Operadora...				 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*

Angelo - 09/11/2004
As linhas abaixo foram comentadas porque os folders seguintes nao sao relativos ao folder OPERADORA
Elas nao foram excluidas para caso de uma possivel utilizacao no futuro

aTmp := aClone(oGet02:aCols) //Operadora
nCt2 := len(aTmp)
cCdOpe := ""
lPerExc := .T.
For nCt1 := 1 to nCt2
	If aTmp[nCt1][len(aTmp[nCt1])]  
		cCdOpe := aTmp[nCt1][1]
    Else
    	cCdOpe := ""
    Endif
    
	If len(alltrim(cCdOpe)) > 0

		If PLSA365Del(nOpc,"O",BAU->BAU_CODIGO,cCdOpe,"","")
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Locais de Atendimento...				 			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTmp := aClone(oGet07:aCols)
			nCt2 := len(aTmp)
			For nCt1 := 1 to nCt2
				If aTmp[nCt1][23] == cCdOpe
					oGet07:aCols[nCt1][len(aTmp[nCt1])] := .T.
					oGet07:lAltered := .T.
				Endif
			Next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Especialidades...				 			 		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTmp := aClone(oGet03:aCols)
			nCt2 := len(aTmp)
			For nCt1 := 1 to nCt2
				If aTmp[nCt1][5] == cCdOpe
					oGet03:aCols[nCt1][len(aTmp[nCt1])] := .T.
					oGet03:lAltered := .T.
				Endif
			Next
		Else
			lPerExc := .F.
		Endif
	
	Endif
Next

Fim das linhas comentadas - Angelo - 09/11/2004

*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Excluindo Locais de Atendimento...	 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTmp := aClone(oGet07:aCols)
/* linha comentada (nCt2) devido a um array out of bounds que ocorria na exclusao de um local de atendimento
que possuia vinculada uma especialidade - Daher 20/02/2005 */
//nCt2 := len(aTmp)
cCdLoc := ""
nPosLocal    := aScan(oGet07:aHeader,{|x| UPPER(x[2])=="BB8_CODLOC"} )
nPosOpe      := aScan(oGet07:aHeader,{|x| UPPER(x[2])=="BB8_CODINT"} )
nPosCodAX    := aScan(oGet03:aHeader,{|x| UPPER(x[2])=="BAX_CODLOC"} )
nPosOpeAX    := aScan(oGet03:aHeader,{|x| UPPER(x[2])=="BAX_CODINT"} )
nPosEspAX    := aScan(oGet03:aHeader,{|x| UPPER(x[2])=="BAX_CODESP"} )


For nCt1 := 1 to len(oGet07:aCols)
	If aTmp[nCt1][len(aTmp[nCt1])]  
    	cCdOpe := aTmp[nCt1][nPosOpe]
		cCdLoc := aTmp[nCt1][nPosLocal]
	Else
    	cCdOpe := ""
		cCdLoc := ""
	Endif
	If len(alltrim(cCdLoc)) > 0

		If PLSA365Del(nOpc,"L",BAU->BAU_CODIGO,cCdOpe,cCdLoc,"")
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Especialidades...				 			 		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
		       Variavel "aTmp" substituida por "aTmp2" e "nCt1" por "nCt2" para corrigir erro "array out 
			   of bounds" que ocorria na exclusao de um local de atendimento que possuia vinculada uma ou 
			   mais especialidades. Ocorria o seguinte: a variavel "aTmp" eh atualizada antes do primeiro
			   "for"; qdo havia especialidades atualizava essa mesma variavel com as "especialidades" e a 
			   variavel "nCt1" com o nr de itens deste array apos execucao de um novo "for". Ao retornar 
			   para o 1o. "for", o conteudo destas variaveis estava alterado (o que ja geraria uma nao
			   conformidade) e caso o nr de itens de especialidades fosse menor que o nr de locais de 
			   atendimento, ao avaliar o conteudo do array "aTmp[nCt1]" ocorria o erro "array out of bound"
			   Sandro - 17/11/2005
			*/
			aTmp2 := aClone(oGet03:aCols)
			//nCt2 := len(aTmp)
			For nCt2 := 1 to len(oGet03:aCols)
				If aTmp2[nCt2][nPosCodAX] $ cCdLoc
					oGet03:aCols[nCt2][len(aTmp2[nCt2])] := .T.
					oGet03:lAltered := .T.
				Endif
			Next
		
		Else
			lPerExc := .F.
		Endif
	
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Excluindo Especialidades...			 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTmp := aClone(oGet03:aCols)
nCt2 := len(aTmp)
cCdEsp := ""
For nCt1 := 1 to nCt2
	If aTmp[nCt1][len(aTmp[nCt1])]  
    	cCdOpe := aTmp[nCt1][nPosOpeAX]
		cCdLoc := aTmp[nCt1][nPosCodAX]
		cCdEsp := aTmp[nCt1][nPosEspAX]
	Else
    	cCdOpe := ""
		cCdLoc := ""
		cCdEsp := ""
	Endif
		If len(alltrim(cCdEsp)) > 0
			If ! PLSA365Del(nOpc,"E",BAU->BAU_CODIGO,cCdOpe,cCdLoc,cCdEsp)
				lPerExc := .F.
			else
				PlsExcEsp(BAU->BAU_CODIGO,PlsIntPad(),aTmp[nCt1][7],aTmp[nCt1][2],aTmp[nCt1][4])
			endif
		Endif
Next


If lPerExc .and. nOpca == K_OK .and. Str(nOpc,1) $ "345"  // so entra se tiver confirmado e a opcao no aRotina for inclusao ou alteracao ou exclusao
	BEGIN TRANSACTION
	GravaRedeRef(nOpc,lLock)	
	END TRANSACTION
EndIf
BAU->(DBSetOrder(nOrdBAU))
BAU->(DBGoto(nRecBAU))

If  nOpca == K_OK .and. ExistBlock("PL365FIM")
    ExecBlock("PL365FIM",.F.,.F.)
Endif    

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtuCabtel  ³ Autor ³ Eduardo Motta       ³ Data ³ 18.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o cabecalho da tela no dialogo mostrando o nome   ³±±
±±³          ³ do credenciado e a operadora                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuCabTel()
	cDesInt := Posicione("BA0",1,xFilial("BA0")+cCodInt,"BA0_NOMINT") 
	
	oSay01:Refresh()               
	oSay02:Refresh()
	oSayOpe01:Refresh()
	oSayOpe02:Refresh()
	oSayLoc01:Refresh()
	oSayLoc02:Refresh()
	oSayEsp01:Refresh()
	oSayEsp02:Refresh()

	If Type("oBrwCtb") == "O"
	   oBrwCtb:Refresh()
	EndIf
	If Type("oBrwRda") == "O"
	   oBrwRda:Refresh()
	EndIf
	If Type("oBrwFaixa") == "O"
	   oBrwFaixa:Refresh()
	EndIf
	If Type("oBrwTaxa") == "O"
		oBrwTaxa:Refresh()
	EndIf
	If Type("oBrwB30") == "O"
		oBrwB30:Refresh()
	EndIf
	If Type("oBrwB59") == "O"
		oBrwB59:Refresh()
	EndIf
	If Type("oGet75") == "O"
		oGet75:Refresh()
	EndIf
	If Type("oGet30") == "O"
		oGet30:Refresh()
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ChangeBrw  ³ Autor ³ Eduardo Motta       ³ Data ³ 16.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza as GETDADOS de acordo com a localidade            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChangeBrw()

	If Empty(oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_LOCAL")]) .Or. oGet07:aCols[oGet07:Linha(),Len(oGet07:aHeader)+1]
	   Return
	Endif

	If Empty(oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_CODESP")]) .Or. oGet03:aCols[oGet03:Linha(),Len(oGet03:aHeader)+1]
	   Return
	Endif                   

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Change02   ³ Autor ³ Alexander Santos    ³ Data ³ 07.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza as GETDADOS 							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Change02()
	Local aBrw  := {"oGet07"}
	Local cVar,nInd
	           
	For nInd := 1 To Len(aBrw)
	   cVar := aBrw[nInd]
	   &(cVar):ForceRefresh(oGet02)
	Next
	
	If Type("oBrwCtb") == "O"
	   oBrwCtb:Refresh()
	EndIf
	
	If Type("oBrwRda") == "O"
	   oBrwRda:Refresh()
	EndIf

	If Type("oBrwFaixa") == "O"
	   oBrwFaixa:Refresh()
	EndIf
	
	If Type("oBrwTaxa") == "O"
		oBrwTaxa:Refresh()
	EndIf
	     
	If Type("oBrwB30") == "O"
		oBrwB30:Refresh()
	EndIf
	
	If Type("oBrwB59") == "O"
		oBrwB59:Refresh()
	EndIf
	
	If Type("oGet75") == "O"
		oGet75:Refresh()
	EndIf
	
	If Type("oGet30") == "O"
		oGet30:Refresh()
	EndIf
			
	If Empty(oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_CODESP")])
	   oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_DESESP")] := ""
	Endif

	oGet02:oBrowse:oBrowse:SetFocus()		
	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Change07   ³ Autor ³ Alexander Santos    ³ Data ³ 07.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza as GETDADOS								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Change07(lTabB58, lTabB51)
	Local aBrw := {"oGet35","oGet47","oGet48","oGet49","oGet03","oGet60"}  
	Local cVar,nInd             
	DEFAULT lTabB58 := .T.  
	DEFAULT lTabB51 := .F.
	
	If lTabB58            
	   Aadd(aBrw,"oGet58")
	Endif
	                      
	If lTabB51            
	   Aadd(aBrw,"oGet51")
	Endif
	
	If PLSALIASEX("B7P")            
	   Aadd(aBrw,"oGet60")
	Endif
	
	For nInd := 1 To Len(aBrw)
	    cVar := aBrw[nInd]
	    &(cVar):ForceRefresh(oGet07)
	Next  
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360TOk ³ Autor ³ Eduardo Motta       ³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a checagem dos campos e pastas obrigatorias            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Plsa360TOk(nOpc)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa365TOk(nOpc)
Local lRet     := .T.
Local nFolder  := 0
Local nI       := 0
Local aFoldObr := {}   // colocar neste array as GETDADOS obrigatorias no cadastro, ex: se a getdados oGet02 for obrigatoria especificar no array o elemento 2.
Local oFold
Local oVar
Local i 	   := 0

aadd(aFoldObr,{oGet02,01})

If nOpc # 4  // se a opcao selecionada nao for INCLUSAO ou ALTERACAO nao e' necessario checar os campos obrigatorios.
   Return .T.
EndIf
/*/
// VERIFICA PERCENTUAIS DO BC1 - CORPO CLINICO
For nI := 1 to Len(oGet09:aCols)
   If Empty(oGet09:FieldGet("BC1_CODPRF"))
      Loop
   EndIf   
   cKeyBC1 := oGet09:FieldGet("BC1_CODINT")+oGet09:FieldGet("BC1_CODLOC")+oGet09:FieldGet("BC1_CODESP")
   nPerBC1 := oGet09:FieldGet("BC1_PERSOC")
   nPosBC1 := aScan(aChkBC1,{|x| x[1]+x[2]+x[3]==cKeyBC1} )
   If nPosBC1 == 0
      aadd(aChkBC1,Array(4))
      nPosBC1 := Len(aChkBC1)
      aChkBC1[nPosBC1,1] := oGet09:FieldGet("BC1_CODINT")
      aChkBC1[nPosBC1,2] := oGet09:FieldGet("BC1_CODLOC")
      aChkBC1[nPosBC1,3] := oGet09:FieldGet("BC1_CODESP")
      aChkBC1[nPosBC1,4] := 0.00
   EndIf
   aChkBC1[nPosBC1,4] += nPerBC1
Next
For nI := 1 to Len(aChkBC1)
   If aChkBC1[nI,4] # 100
      MsgStop(" Percentual do corpo clinico invalido. Cod.Int:"+aChkBC1[nPosBC1,1]+" Cod.Loc: "+aChkBC1[nPosBC1,2]+" Espec.:"+aChkBC1[nPosBC1,3])
      Return .F.
   EndIf
Next
/*/

If !Obrigatorio(aSvAGets[2],aSvATela[2])   // verifica campos obrigatorio do primeiro folder
	lRet    := .F.
	nFolder := 1
	oFold   := oFolder
Else
	For nI := 1 to Len(aFoldObr)  // verifica os FOLDERs obrigatorios no cadastro
		oVar := aFoldObr[nI,1]
		If ValType(oVar) # "O" // se a variavel nao for um objeto foi passado errado no array aFoldObr, verificar o numero e corrigir.
			MsgStop(STR0035+StrZero(aFoldObr[nI],2)) //"Erro na verificacao de campos obrigatorios do folder "
			Loop
		EndIf
		If ! oVar:TudoOk()
			nFolder := aFoldObr[nI,2]
			oFold   := aFoldObr[nI,3]
			lRet    := .F.
			Exit
		EndIf
	Next
Endif

If BAU->( FieldPos("BAU_DATATU") ) > 0 .And. nOpc == K_Alterar .And. GetNewPar("MV_PLSUNI","1") == "1" .And. ; 
	MsgYesNo(STR0085+Substr(DtoS(dDataBase),7,2)+"/"+Substr(DtoS(dDataBase),5,2)+"/"+Substr(DtoS(dDataBase),1,4)+STR0086)//"Confirma a data " ### " para envio de alteração de dados cadastrais no PTU A400?"
	
		BAU->(RecLock("BAU",.F.))
			BAU->BAU_DATATU := dDataBase
		BAU->(MsUnLock())
EndIf

// INICIO
//  se algum dos itens de DIVISAO DE RECEBIMENTO tiver STATUS == 1 (SIM) entao algum corpo clinico
//  deve estar cadastrado
/*
For nI := 1 to Len(oGet47:aCols)
   If oGet47:FieldGet("BZA_STATUS",nI,oGet47:aHeader) == "1"
      lAchou := .T.
      Exit
   EndIf
Next
If lAchou
   For nI := 1 to Len(oGet09:aCols)
      If !Empty(oGet09:FieldGet("BC1_CODPRF",nI,oGet09:aHeader))
         lAchou := .F.
         Exit
      EndIf
   Next
   If lAchou
      MsgStop("Pelo menos um medico precisa estar cadastrado no folder Corpo Clinico")
      Return .F.
   EndIf   
EndIf
*/
// FIM


/*For nI := 1 To Len(oGet18:aCols)
	If !Empty(oGet18:FieldGet("BBI_VIGDE", nI, oGet18:aHeader)) .And. Empty(oGet18:FieldGet("BBI_VIGATE", nI, oGet18:aHeader))
		Msginfo("Informe as datas de vigência final nos planos que possuem data de vigência inicial")
		Return .F.
	ElseIF !Empty(oGet18:FieldGet("BBI_VIGATE", nI, oGet18:aHeader)) .And. Empty(oGet18:FieldGet("BBI_VIGDE", nI, oGet18:aHeader))
		Msginfo("Informe as datas de vigência inicial nos planos que possuem data de vigência final")
		Return .F.
	EndIf
Next nI*/

for i:= 1 to len(aSubEspAlt)
	// verifica se é necessario realizar alteracao no registro
	if(aSubEspAlt[i][3] == .T.)
		BC0->(dbSetOrder(1))		
		if(BC0->(dbSeek(xFilial("BC0")+aSubEspAlt[i][2]))) // BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP	
			// inserimos a subespecialidade para todos os procedimentos filhos da BAX alterada
			while !BC0->(eof()) .AND. xFilial("BC0")+aSubEspAlt[i][2] == BC0->(BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP)
				BC0->(recLock("BC0",.F.))
				BC0->BC0_CODSUB :=  aSubEspAlt[i][1]
				BC0->(msUnlock())
				BC0->(dbSkip())
			enddo			
		endif
		BBK->(dbsetOrder(1))
		if BBK->(MsSeek(xFilial("BBK") + Substr(aSubEspAlt[i][2],1,13)))
			while !BBK->(EoF()) .AND. xFilial("BBK") + Substr(aSubEspAlt[i][2],1,13) == BBK->(BBK_FILIAL+BBK_CODIGO+BBK_CODINT+BBK_CODESP)
				if !empty(BBK->BBK_CODSUB)
					BBK->(RecLock("BBK",.F.))
						BBK->BBK_CODSUB := aSubEspAlt[i][1]
					BBK->(MsUnlock())
				endif
				BBK->(dbskip())
			enddo
		endif
	endif
next i
// zera o array
aSize(aSubEspAlt, 0)

If !lRet
	oFold:SetOption(nFolder)
	oFold:aDialogs[nFolder]:SetFocus()
EndIf

Return lRet




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaRedeRef³ Autor ³ Eduardo Motta       ³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a gravacao dos dados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaRedeRef()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 18.09.02 ³V. 710³ Michele Tata³ Retirada da funcao PLSENDBRW que      ³±±
±±³          ³      ³ giba        ³ estava ocasionando NC ao incluir      ³±±
±±³          ³      ³             ³ uma RDA.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaRedeRef(nOpc,lLock)
Local aChav02
Local aChav03
Local aChav06
Local aChav07
Local aChav09
Local aChav10
Local aChav16
Local aChav18
Local aChav19
Local aChav20
Local aChav21
Local aChav35
Local aChav47
Local aChav48
Local aChavBLH
Local aChavBLG
Local aChavBZ2
Local aChavB7P


Local nTamCols
Local nPosBlo    := ascan(oGet07:aHeader,{|x| AllTrim(x[2]) == 'BB8_DATBLO'})
Local nPosFim	 := ascan(oGet07:aHeader,{|x| AllTrim(x[2]) == 'BB8_FIMATE'})
Local nPosCdLoc	 := ascan(oGet07:aHeader,{|x|Trim(x[2])=="BB8_CODLOC"})

//integração GRC
Local nCntAux

Local nPBB8CNES := ascan(oGet07:aheader, { |x| Alltrim(x[2]) == "BB8_CNES"} )
Local nPBB8EST  := ascan(oGet07:aheader, { |x| Alltrim(x[2]) == "BB8_EST"} )
Local nPBB8CDMUN := ascan(oGet07:aheader, { |x| Alltrim(x[2]) == "BB8_CODMUN"} )
local nPBB8CPF	:= ascan(oGet07:aheader, { |x| Alltrim(x[2]) == "BB8_CPFCGC"} )
Local nZ	:= 0
Local aAlt	:= {}
Local cTpArq := " "
Local aChvAnt := { "DEFAULT", "DEFAULT", "DEFAULT" }
Local aIncLoc := {} //CODLOC, CNES, EST, CODMUN
Local aItegrv	:= {}
local aAreBB8	:= {}
local lFimAte	:= .f.
local dDtaPtu	:= ''
local lGrvB7O	:= .t.
local cChave	:= ''

aChav02 := {{"BAW_CODIGO",cCodigo}}
aChav03 := {{"BAX_CODIGO",cCodigo}}
aChav06 := {{"BC0_CODIGO",cCodigo}}
aChav07 := {{"BB8_CODIGO",cCodigo}}
aChav09 := {{"BC1_CODIGO",cCodigo}}
aChav10 := {{"BE6_CODIGO",cCodigo}}
aChav16 := {{"BBG_CODIGO",cCodigo}}
aChav18 := {{"BBI_CODIGO",cCodigo}}
aChav19 := {{"BBK_CODIGO",cCodigo}}
aChav20 := {{"BBN_CODIGO",cCodigo}}
aChav21 := {{"BE9_CODIGO",cCodigo}}
aChav35 := {{"BPI_CODIGO",cCodigo}}
aChav47 := {{"BZA_CODIGO",cCodigo}}
aChav48 := {{"BCK_CODIGO",cCodigo}}
aChav49 := {{"BIN_CODIGO",cCodigo}}
aChav50 := {{"BSO_CODIGO",cCodigo}}
If PLSALIASEX("B24")
	aChav51 := {{"B24_CODIGO",cCodigo}}
Endif
aChavBLG := {{"BLG_CODIGO",cCodigo}}
aChavBLH := {{"BLH_CODIGO",cCodigo}}
aChavBHU := {{"BHU_CODIGO",cCodigo}}
aChavBY5 := {{"BY5_CODIGO",cCodigo}}
aChavBY6 := {{"BY6_CODIGO",cCodigo}}
aChavBYZ := {{"BYZ_CODIGO",cCodigo}}
aChavB7P := {{"B7P_CODIGO",cCodigo}}

If PLSALIASEX("B30")
	aChavB30 := {{"B30_CODIGO",cCodigo}}
Endif

If PLSALIASEX("B59")
	aChavB59:= {{"B59_CODIGO",cCodigo}}
Endif

If PLSALIASEX("B75")
	aChavB75:= {{"B75_CODIGO",cCodigo}}
Endif	

If PLSALIASEX("B62")
	aChavB62:= {{"B62_CODIGO",cCodigo}}
Endif	

If PLSALIASEX("B58")
	aChavB58 := {{"B58_CODIGO",cCodigo}}
Endif 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para retirar o filtro dos browses. Tive que fazer especifica      ³
//³ pois a funcao PLSENDBRW estava ocasionando erro ao se tentar incluir     ³
//³ uma RDA. Essa funcao retira o filtro baseado na funcao PLSENDBRW         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet02:EndFilter(.F.)
oGet03:EndFilter(.F.)
//oGet06:EndFilter(.F.)
oGet07:EndFilter(.F.)
oGet35:EndFilter(.F.)
oGet47:EndFilter(.F.)
oGet48:EndFilter(.F.)
oGet49:EndFilter(.F.)
oGet60:EndFilter(.F.)

If PLSALIASEX("B58")
   oGet58:EndFilter(.F.)
Endif   
oBrwCtb:EndFilter(.F.)
oBrwRda:EndFilter(.F.)
oBrwFaixa:EndFilter(.F.)
oBrwTaxa:EndFilter(.F.)  
    
If Type("oBrwB30") == "O"
	oBrwB30:EndFilter(.F.)      
Endif

//Integracao com o HAT
If GetNewPar("MV_PLSHAT","0") == "1" 
	PLHAT365(nOpc,cCodigo,oGet07,oGet03)
EndIf

if ( GetNewPar("MV_PLSUNI","0") == "1" )
	B7O->(DbSetOrder(4)) //B7O_FILIAL+B7O_CODRDA+B7O_NVEXC+B7O_ENDEXC
	BB8->(DbSetOrder(1))
	aAreBB8 := BB8->(getarea())
	For nCntAux := 1 To Len(oGet07:aCols) 
		lGrvB7O	:= .t.
		cChave := BAU->BAU_CODIGO +	GDFieldGet("BB8_CODINT",nCntAux,nil,oGet07:aHeader,oGet07:aCols) + ;
					GDFieldGet("BB8_CODLOC",nCntAux,nil,oGet07:aHeader,oGet07:aCols) + ;
					GDFieldGet("BB8_LOCAL" ,nCntAux,nil,oGet07:aHeader,oGet07:aCols)
							
		if ( BB8->( MsSeek(xFilial("BB8") + cChave)) .And. !ATAIL(oGet07:aCols[nCntAux]) )

			If BB8->(FieldPos('BB8_FIMATE')) > 0
				lFimAte := BB8->BB8_FIMATE <> oGet07:aCols[nCntAux][nPosFim]
			EndIf

			//Se estava bloqueado e agora tirou a data, limpo o B7O correspondente.
			If ( (!empty(BB8->BB8_DATBLO) .and. empty(oGet07:aCols[nCntAux][nPosBlo])) .or. ;
				 (!empty(BB8->BB8_FIMATE) .and. empty(oGet07:aCols[nCntAux][nPosFim])) )
				If B7O->( dbSeek(xFilial('B7O') + BAU->BAU_CODIGO + "04" + SUBSTR(oGet07:aCols[nCntAux][nPosCdLoc],2,2)) )
					B7O->(RecLock('B7O', .f.))
					B7O->(dbDelete())
					B7O->(MsUnlock()) 
				endif
						//apaga o motivo de bloqueio, caso a data de bloqueio seja apagada.
					if !empty(BB8->BB8_DATBLO) .and. empty(oGet07:aCols[nCntAux][nPosBlo])
						if BB8->(fieldPos("BB8_CODEXC")) > 0 .and.BB8->( dbSeek(xFilial('BB8') + BAU->BAU_CODIGO + PlsIntPad() + oGet07:aCols[nCntAux][nPosCdLoc]+ oGet07:aCols[nCntAux][5])) .AND. !EMPTY(BB8->BB8_CODEXC)
								oGet07:aCols[nCntAux][57] :=" "
						endif
					endif

			elseif ( BB8->BB8_DATBLO <> oGet07:aCols[nCntAux][nPosBlo] .OR. lFimAte .OR. oGet07:aCols[nCntAux][Len(oGet07:aCols[nCntAux])] ) // Pego o ultimo registro referente ao D_E_L_E_T_
				If B7O->(dbSeek(xFilial('B7O') + BAU->BAU_CODIGO + "04" + SUBSTR(oGet07:aCols[nCntAux][nPosCdLoc],2,2)))
					lGrvB7O := .f.
				endif 
				B7O->(RecLock('B7O', lGrvB7O))
					B7O->B7O_FILIAL := xFilial('B7O')
					B7O->B7O_CODRDA := BAU->BAU_CODIGO
					B7O->B7O_NVEXC  := '04'
					B7O->B7O_REDEXC	:= ""
					B7O->B7O_PLAEXC	:= ""
					B7O->B7O_ENDEXC := substr(oGet07:aCols[nCntAux][nPosCdLoc],2,2)
					dDtaPtu := iif( lFimAte, oGet07:aCols[nCntAux][nPosFim], oGet07:aCols[nCntAux][nPosBlo])
					B7O->B7O_DTBLOQ := Iif( Empty(dDtaPtu), DATE(), dDtaPtu)
				B7O->(MsUnlock())	
			EndIF
		endif
	Next
	RestArea(aAreBB8)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Operadora                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet02:Grava(aChav02)
oBRWCTB:Grava(aChavBHU)
oBrwRda:Grava(aChavBY5)
oBrwTaxa:Grava(aChavBYZ)

If Type("oBrwB30") == "O"
	oBrwB30:Grava(aChavB30)
Endif 
If Type("oBrwB59") == "O"
	oBrwB59:Grava(aChavB59)
Endif
If Type("oGet75") == "O"
	oGet75:Grava(aChavB75)
Endif
If Type("oGet30") == "O"
	oGet30:Grava(aChavB62)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Faixa x Condicao de Pagamento                		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLATIOD","0") == '1' .AND. Type("oBrwBZ2") == "O"
	aChavBZ2 := {{"BZ2_CODIGO",cCodigo}}          
	oBrwBZ2:Grava(aChavBZ2)
EndIf

B7P->(DbSetOrder(2)) //B7P_FILIAL+B7P_ITEM+B7P_CODINT+B7P_CODIGO+B7P_CODLOC
	
For nCntAux := 1 To Len(oGet60:aCols)
                                                                                         
	If B7P->(MsSeek(xFilial("B7P")+GDFieldGet("B7P_ITEM",nCntAux,nil,oGet60:aHeader,oGet60:aCols)+GDFieldGet("B7P_CODINT",nCntAux,nil,oGet60:aHeader,oGet60:aCols)+ BAU->BAU_CODIGO+GDFieldGet("B7P_CODLOC",nCntAux,nil,oGet60:aHeader,oGet60:aCols)))
		lAchou := .F.
	Else
		lAchou := .T.
	Endif
 
	If  ! Empty(GDFieldGet("B7P_CODACR",nCntAux,nil,oGet60:aHeader,oGet60:aCols))	.OR. !Empty(GDFieldGet("B7P_NIVACR",nCntAux,nil,oGet60:aHeader,oGet60:aCols))		
		
		if	! ATAIL(oGet60:aCols[nCntAux]) 
		
			B7P->(RecLock( "B7P",lAchou ))
				B7P->B7P_FILIAL	:= xFilial( "B7P" )
				B7P->B7P_CODIGO	:= BAU->BAU_CODIGO
				B7P->B7P_ITEM	:= GDFieldGet("B7P_ITEM",nCntAux,nil,oGet60:aHeader,oGet60:aCols)
				B7P->B7P_CODINT	:= GDFieldGet("B7P_CODINT",nCntAux,nil,oGet60:aHeader,oGet60:aCols)
				B7P->B7P_CODLOC	:= GDFieldGet("B7P_CODLOC",nCntAux,nil,oGet60:aHeader,oGet60:aCols)
				B7P->B7P_CODACR	:= GDFieldGet("B7P_CODACR",nCntAux,nil,oGet60:aHeader,oGet60:aCols) 
				B7P->B7P_NIVACR	:= GDFieldGet("B7P_NIVACR",nCntAux,nil,oGet60:aHeader,oGet60:aCols) 
				if B7P->(FieldPos("B7P_DATINI")) > 0
					B7P->B7P_DATINI	:= GDFieldGet("B7P_DATINI",nCntAux,nil,oGet60:aHeader,oGet60:aCols) 
					B7P->B7P_DATFIM	:= GDFieldGet("B7P_DATFIM",nCntAux,nil,oGet60:aHeader,oGet60:aCols) 
				endif
			B7P->( msUnLock() )
			
		Else
				
			B7P->(Reclock( "B7P",.F.))
			B7P->(dbDelete())
			B7P->(MsUnlock())        
	
		Endif
					
	EndIf
	
Next nCntAux

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Faixa de Desconto                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwFaixa:Grava(aChavBY6)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o historico de US de uma operadora                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVetBNG) <> 0

   	nTamCols := 1
	BNG->(DBSetOrder(2))
	
   	For nTamCols := 1 To Len(aVetBNG)

       if BNG->(MsSeek(xFilial("BNG")+aVetBNG[nTamCols,1]+aVetBNG[nTamCols,2]))
       
	       If Empty(dtos(BNG->BNG_DATATE)) .and. BNG->(BNG_FILIAL+BNG_CODIGO+BNG_CODINT) == xFilial("BNG")+aVetBNG[nTamCols,1]+aVetBNG[nTamCols,2]
	    
	          BNG->(RecLock("BNG",.F.))
		          BNG->BNG_DATATE := aVetBNG[nTamCols,7] - 1
	          BNG->(MSUnlock())
	          
	       Endif
	       
		endIf
		
       	BNG->(RecLock("BNG",.T.))
	       BNG->BNG_FILIAL := xFilial("BNG")
	       BNG->BNG_CODIGO := aVetBNG[nTamCols,1]
	       BNG->BNG_CODINT := aVetBNG[nTamCols,2]
	       BNG->BNG_VALCH  := aVetBNG[nTamCols,3]
	       BNG->BNG_FORMUL := aVetBNG[nTamCols,4]
	       BNG->BNG_EXPRES := aVetBNG[nTamCols,5]
	       BNG->BNG_NIVVAL := aVetBNG[nTamCols,6]
	       BNG->BNG_DATDE  := aVetBNG[nTamCols,7]
	       BNG->BNG_DATATE := aVetBNG[nTamCols,8]
       	BNG->(MSUnlock())
		
   Next
   
Endif

//Grava a GetDados de Contatos x Operadora verificando a integridade entre eles.
nZ := 1                                                                    
While nZ <= Len(oGet07:acols)
	If nZ > Len(oGet07:acols)
		exit
	endIf
	If empty(oGet07:acols[nZ][3])
		aDel(oGet07:acols, nZ)
		aSize(oGet07:acols, Len(oGet07:acols) - 1)
		nZ--
	endIf
	nZ++
endDo

If BAU->BAU_GERRPS == "1" .AND. !(BAU->BAU_ENVRPS $ "2,4") .AND. !(EmpTy(oGet07:aRecAlt))
	For nZ := 1 To Len(oGet07:aRecAlt)
		If oGet07:aRecalt[nZ][2] == "A"
			BB8->(DbGoTo(oGet07:aRecalt[nZ][3]))
			
			If Alltrim(oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CPF]) <> allTrim(BB8->BB8_CPFCGC)
				aadd(aAlt, "BB8_CPFCGC")
			endIf
			
			If Alltrim(oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CNES]) <> alltrim(BB8->BB8_CNES)
				aadd(aAlt, "BB8_CNES")
			endIf
			
			If Alltrim(oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8EST]) <> allTrim(BB8->BB8_EST)
				aadd(aAlt, "BB8_EST")
			endIf
			
			If Alltrim(oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CDMUN]) <> alltrim(BB8->BB8_CODMUN)
				aadd(aAlt, "BB8_CODMUN")
			endIf
			
			If Len(aalt) > 0

				aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPosCdLoc])
				aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CNES])
				aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8EST])
				aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CDMUN])
				aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CPF])
				
				If BAU->BAU_ENVRPS $ "1,3"
					cTpArq := "1"
				Elseif BAU->BAU_ENVRPS $ " ,0"
					cTpArq := "0"
				EndIf
				abkpchvant := aclone(aChvAnt)
				aChvAnt := { allTrim(BB8->BB8_CPFCGC), alltrim(BB8->BB8_CNES), alltrim(BB8->BB8_CODMUN) }
				PLSRPSALT(PLSINTPAD(), BAU->(Recno()), BB8->(Recno()), 0, aAlt, cTpArq, aChvAnt,aIncLoc)
				aChvAnt := aclone(abkpchvant)
			endIf
		elseIf oGet07:aRecalt[nZ][2] == "I" .AND. !(EmpTy(oGet07:acols[oGet07:aRecalt[nZ][4]][nPosCdLoc])) .AND. ascan(aItegrv, oGet07:aRecalt[nZ][4]) == 0
			
			aadd(aItegrv, oGet07:aRecalt[nZ][4])
			aAlt 	 := {"BB8_CODMUN", "BB8_EST", "BB8_CNES", "BB8_CPFCGC" }
			aChvAnt := { oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CPF], oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CNES], oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CDMUN] }
			aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPosCdLoc])
			aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CNES])
			aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8EST])
			aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CDMUN])
			aadd(aIncLoc, oGet07:acols[oGet07:aRecalt[nZ][4]][nPBB8CPF])
			cTpArq := "0"
			
			PLSRPSALT(PLSINTPAD(), BAU->(Recno()), 0, 0, aAlt, cTpArq, aChvAnt, aIncLoc)
			
		endIf
		aAlt 	 := {}//{"BB8_CODMUN", "BB8_EST", "BB8_CNES" }
		aIncLoc := {}
		cTpArq  := " "
		aChvAnt := { "DEFAULT", "DEFAULT", "DEFAULT" }
		If BAU->BAU_ENVRPS $ "1,3"
			BAU->(RecLock("BAU", .F.))
				BAU->BAU_ENVRPS := "3"
			BAU->(MsUnLock())
		endIf
	Next
endIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Local de Atendimento x Operadora verificando a inte  ³
//³ gridade entre eles.                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oGet07:Grava(aChav07)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o historico de US de um Local de Atendimento                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVetBN8) <> 0

   	nTamCols := 1
	BN8->(DBSetOrder(2))
	
   	For nTamCols := 1 To Len(aVetBN8)
   
       if BN8->(MsSeek(xFilial("BN8")+aVetBN8[nTamCols,1]+aVetBN8[nTamCols,2]+aVetBN8[nTamCols,3]))
       
	       If Empty(dtos(BN8->BN8_DATATE)) .And. BN8->(BN8_FILIAL+BN8_CODIGO+BN8_CODINT+BN8_CODLOC) == xFilial("BN8")+aVetBN8[nTamCols,1]+aVetBN8[nTamCols,2]+aVetBN8[nTamCols,3]
	          BN8->(RecLock("BN8",.F.))
	          BN8->BN8_DATATE := aVetBN8[nTamCols,8] - 1
	          BN8->(MSUnlock())
	       Endif
	       
		endIf
	       
       	BN8->(RecLock("BN8",.T.))
	       BN8->BN8_FILIAL := xFilial("BN8")
	       BN8->BN8_CODIGO := aVetBN8[nTamCols,1]
	       BN8->BN8_CODINT := aVetBN8[nTamCols,2]
	       BN8->BN8_CODLOC := aVetBN8[nTamCols,3]
	       BN8->BN8_VLRUS  := aVetBN8[nTamCols,4]
	       BN8->BN8_FORMUL := aVetBN8[nTamCols,5]
	       BN8->BN8_EXPRES := aVetBN8[nTamCols,6]
	       BN8->BN8_NIVVAL := aVetBN8[nTamCols,7]
	       BN8->BN8_DATDE  := aVetBN8[nTamCols,8]
	       BN8->BN8_DATATE := aVetBN8[nTamCols,9]
      	BN8->(MSUnlock())
		
   Next
   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Filme x Local de Atendimento verificando a integri   ³
//³ dade entre eles.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet35:Grava(aChav35)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o historico de Filmes x Local de Atendimento                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVetBN9) <> 0
   	nTamCols := 1
	BN9->(DBSetOrder(2))
   	For nTamCols := 1 To Len(aVetBN9)
   	
       	if BN9->(MsSeek(xFilial("BN9")+aVetBN9[nTamCols,1]+aVetBN9[nTamCols,2]+aVetBN9[nTamCols,3]+aVetBN9[nTamCols,4]))
	       
	       If Empty(dtos(BN9->BN9_DATATE)) .And. BN9->(BN9_FILIAL+BN9_CODIGO+BN9_CODINT+BN9_CODLOC+BN9_CODFIL) == xFilial("BN9")+aVetBN9[nTamCols,1]+aVetBN9[nTamCols,2]+aVetBN9[nTamCols,3]+aVetBN9[nTamCols,4]
	          BN9->(RecLock("BN9",.F.))
	          BN9->BN9_DATATE := aVetBN9[nTamCols,10] - 1
	          BN9->(MSUnlock())
	       Endif
	       
		endIf              
   
       	BN9->(RecLock("BN9",.T.))      
	       BN9->BN9_FILIAL := xFilial("BN9")
	       BN9->BN9_CODIGO := aVetBN9[nTamCols,1]
	       BN9->BN9_CODINT := aVetBN9[nTamCols,2]
	       BN9->BN9_CODLOC := aVetBN9[nTamCols,3]
	       BN9->BN9_CODFIL := aVetBN9[nTamCols,4]
	       BN9->BN9_VIGFIL := aVetBN9[nTamCols,5]
	       BN9->BN9_VLRFIL := aVetBN9[nTamCols,6]
	       BN9->BN9_PERFIL := aVetBN9[nTamCols,7]
	       BN9->BN9_NIVVAL := aVetBN9[nTamCols,8]
	       BN9->BN9_CODDOC := aVetBN9[nTamCols,9]
	       BN9->BN9_DATDE  := aVetBN9[nTamCols,10]
	       BN9->BN9_DATATE := aVetBN9[nTamCols,11]
       	BN9->(MSUnlock())
		
   Next
   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o historico de Porte Anestesico x Local de Atendimento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet47:Grava(aChav47)
oGet48:Grava(aChav48)
oGet49:Grava(aChav49)

If(!EMPTY(oGet50), oGet50:Grava(aChav50), "")

If PLSALIASEX("B24")
	oGet51:Grava(aChav51)
Endif
If PLSALIASEX("B58")
	oGet58:Grava(aChavB58)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o historico de Porte Anestesico x Local de Atendimento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVetBNM) <> 0
   
  	nTamCols := 1
	BNM->(DBSetOrder(2))
   
   	For nTamCols := 1 To Len(aVetBNM)
   
       if BNM->(MsSeek(xFilial("BNM")+aVetBNM[nTamCols,1]+aVetBNM[nTamCols,2]+aVetBNM[nTamCols,3]+Str(aVetBNM[nTamCols,4],2) ))
	       
	       if empty(dtos(BNM->BNM_DATATE)) .And. BNM->(BNM_FILIAL+BNM_CODIGO+BNM_CODINT+BNM_CODLOC+Str(BNM_CODPOR,2)) == xFilial("BNM")+aVetBNM[nTamCols,1]+aVetBNM[nTamCols,2]+aVetBNM[nTamCols,3]+Str(aVetBNM[nTamCols,4],2)
	          BNM->(RecLock("BNM",.F.))
	          BNM->BNM_DATATE := aVetBNM[nTamCols,10] - 1
	          BNM->(MSUnlock())
	       endIf
	       
		endIf
		
       	BNM->(RecLock("BNM",.T.))      
	       BNM->BNM_FILIAL := xFilial("BNM")
	       BNM->BNM_CODIGO := aVetBNM[nTamCols,1]
	       BNM->BNM_CODINT := aVetBNM[nTamCols,2]
	       BNM->BNM_CODLOC := aVetBNM[nTamCols,3]       
	       BNM->BNM_CODPOR := aVetBNM[nTamCols,4]
	       BNM->BNM_VLRPOR := aVetBNM[nTamCols,5]
	       BNM->BNM_VIGPOR := aVetBNM[nTamCols,6]       
	       BNM->BNM_CODDOC := aVetBNM[nTamCols,7]
	       BNM->BNM_PERPOR := aVetBNM[nTamCols,8]
	       BNM->BNM_NIVVAL := aVetBNM[nTamCols,9]
	       BNM->BNM_DATDE  := aVetBNM[nTamCols,10]
	       BNM->BNM_DATATE := aVetBNM[nTamCols,11]
       	BNM->(MSUnlock())
       	
   	Next
   	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Especialidade x Local de Atendimento verificando     ³
//³ a integridade entre eles.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet03:Grava(aChav03)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o historico de US de uma Especialidade x Rede de Atendimento       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVetBNO) <> 0

   	nTamCols := 1
	BNO->(DBSetOrder(2))
	
   	For nTamCols := 1 To Len(aVetBNO)
   	
       if BNO->(MsSeek(xFilial("BNO")+aVetBNO[nTamCols,1]+aVetBNO[nTamCols,2]+aVetBNO[nTamCols,3]+aVetBNO[nTamCols,4]+aVetBNO[nTamCols,5]))
	       
	       If Empty(dtos(BNO->BNO_DATATE)) .And. BNO->(BNO_FILIAL+BNO_CODIGO+BNO_CODINT+BNO_CODLOC+BNO_CODESP+BNO_CODSUB) == xFilial("BNO")+aVetBNO[nTamCols,1]+aVetBNO[nTamCols,2]+aVetBNO[nTamCols,3]+aVetBNO[nTamCols,4]+aVetBNO[nTamCols,5]
	          BNO->(RecLock("BNO",.F.))
	          BNO->BNO_DATATE := aVetBNO[nTamCols,10] - 1
	          BNO->(MSUnlock())
	       endIf
	       
		endIf
		   
   		BNO->(RecLock("BNO",.T.))
   			BNO->BNO_FILIAL := xFilial("BNO")
   			BNO->BNO_CODIGO := aVetBNO[nTamCols,1]
   			BNO->BNO_CODINT := aVetBNO[nTamCols,2]
   			BNO->BNO_CODLOC := aVetBNO[nTamCols,3]
   			BNO->BNO_CODESP := aVetBNO[nTamCols,4]
   			BNO->BNO_CODSUB := aVetBNO[nTamCols,5]
   			BNO->BNO_VALCH  := aVetBNO[nTamCols,6]
   			BNO->BNO_FORMUL := aVetBNO[nTamCols,7]
   			BNO->BNO_EXPRES := aVetBNO[nTamCols,8]
   			BNO->BNO_NIVVAL := aVetBNO[nTamCols,9]
   			BNO->BNO_DATDE  := aVetBNO[nTamCols,10]
   			BNO->BNO_DATATE := aVetBNO[nTamCols,11]
  		 BNO->(MSUnlock())
  		 
   Next
   
Endif
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Procedimentos Autorizados x Especialidade verificando³
//³ a integridade entre eles.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet06:Grava(aChav06)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Complemento de um Procedimento x Procedimento Autori ³
//³ zado, verificando integridade entre eles.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsBLG) > 0

   //Caso a linha de procedimento seja excluida, excluir tambem os itens de valorizacao referentes 
   If Len(oGet06:aCols) > 0
		
		BZB->(DbSetOrder(1))
		BDN->(DbSetOrder(1))
      	For nTamCols := 1 To Len(oGet06:aCols)

          If oGet06:aCols[nTamCols,Len(oGet06:aHeader)+1]

             // Excluir a linha de valorizacao
             nI := 1
             For nI := 1 To Len(aColsBLG)
             
                 If oGet06:aCols[nTamCols,oGet06:PlRetPos("BC0_CODTAB")] == aColsBLG[nI,GdFieldPos("BLG_CODTAB",aHeadBLG)] .And.;
                    oGet06:aCols[nTamCols,oGet06:PlRetPos("BC0_CODOPC")] == aColsBLG[nI,GdFieldPos("BLG_CODPRO",aHeadBLG)]
                    
                    aColsBLG[nI,Len(aHeadBLG)+1] := .T.
                    
                 Else
                    nI++
                 Endif
                 
             Next
             
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³DeletANO Rda x Local x Esp x Proc x Vlr³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If BDN->(DbSeek(xFilial("BDN")+M->BAU_CODIGO+oGet06:aCols[nTamCols,nPosCodInt]+oGet06:aCols[nTamCols,nPosCodLoc]+oGet06:aCols[nTamCols,nPosCodEsp]+oGet06:aCols[nTamCols,nPosCodTab]+oGet06:aCols[nTamCols,nPosCodPad]+oGet06:aCols[nTamCols,nPosCodOpc]))
                
                While BDN->(!Eof()) .and. (BDN->BDN_FILIAL+BDN->BDN_CODIGO+BDN->BDN_CODINT+BDN->BDN_CODLOC+BDN->BDN_CODESP+BDN->BDN_CODTAB+BDN->BDN_CODPAD+BDN->BDN_CODOPC == xFilial("BDN")+M->BAU_CODIGO+oGet06:aCols[nTamCols,nPosCodInt]+oGet06:aCols[nTamCols,nPosCodLoc]+oGet06:aCols[nTamCols,nPosCodEsp]+oGet06:aCols[nTamCols,nPosCodTab]+oGet06:aCols[nTamCols,nPosCodPad]+oGet06:aCols[nTamCols,nPosCodOpc])
					
					BDN->(Reclock( "BDN",.F.))
					BDN->(dbDelete())
					BDN->(MsUnlock())
					        
				BDN->(DbSkip())
				Enddo
				
			 Endif         
			 
		 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³DeletANO Rda x Local x Esp x Proc x Vlr³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If BZB->(DbSeek(xFilial("BZB")+M->BAU_CODIGO+oGet06:aCols[nTamCols,nPosCodInt]+oGet06:aCols[nTamCols,nPosCodLoc]+oGet06:aCols[nTamCols,nPosCodEsp]+oGet06:aCols[nTamCols,nPosCodTab]+oGet06:aCols[nTamCols,nPosCodOpc]))
                 
                While !Eof() .and. (BZB->BZB_FILIAL+BZB->BZB_CODIGO+BZB->BZB_CODINT+BZB->BZB_CODLOC+BZB->BZB_CODESP+BZB->BZB_CODTAB+BZB->BZB_CODOPC==xFilial("BZB")+M->BAU_CODIGO+oGet06:aCols[nTamCols,nPosCodInt]+oGet06:aCols[nTamCols,nPosCodLoc]+oGet06:aCols[nTamCols,nPosCodEsp]+oGet06:aCols[nTamCols,nPosCodTab]+oGet06:aCols[nTamCols,nPosCodOpc])
					
					BZB->(Reclock( "BZB",.F.))
					BZB->(dbDelete())
					BZB->(MsUnlock()) 
					       
				BZB->(DbSkip())
				Enddo
				
			 Endif
			          
          Endif
          
      Next
   Endif
   // Nao encontrei o objeto, ver isso com calma! Geraldo Felix Junior.
   PLUPTCOLS("BLG",aColsBLG,aHeadBLG,aVetBLG,4,aChavBLG,.t.)
EndIf                                                                             
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Complemento de um Procedimento x Procedimento x Corpo³
//³ Clinico verificando integridade entre eles.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
If Len(aColsBLH) > 0
   PLUPTCOLS("BLH",aColsBLH,aHeadBLH,aVetBLH,4,aChavBLH,.t.)
EndIf
                                                                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a GetDados de Acreditacoes x Especialidade verificando a integrida ³
//³ de entre eles.                                          					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PlsConsiste(oGet07:aCols,oGet07:aHeader,oGet60:aOrigem,oGet60:aCols,oGet60:aHeader,oGet60:aRelac)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada PL365BOT1 para realizar a gravacao dos dados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL365BOT1")     
    ExecBlock("PL365BOT1",.F.,.F.,{"3",,,,nOpc})
EndIf  

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CargaCols   ³ Autor ³ Eduardo Motta       ³ Data ³ 08.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a carga no aCols/aHeader/aVetTrab do alias          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CargaCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CargaCols(cAlias,aVetTrab,nOpc,aColsPadTipo)
LOCAL lSalv := Inclui
Local nHead	:= 0, nCols, nCnt, lFound := .F.

aHeader := {}
aCols   := {}
Store Header cAlias TO aHeader For .T.
DbSelectArea(cAlias)
DbSetOrder(1)
If aColsPadTipo <> Nil
	If (lFound := MsSeek(xFilial(cAlias)+cCodigo))
		While 	xFilial(cAlias) == &(cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL") .and.;
				cCodigo == &(cAlias+"->"+PrefixoCpo(cAlias)+"_CODIGO") .And. ! Eof()
			If (nCols := Ascan(aCols, { |x| x[1] = &(cAlias+"->"+PrefixoCpo(cAlias)+"_TIPO")})) = 0
				Aadd(aCols, { 	&(cAlias+"->"+PrefixoCpo(cAlias)+"_TIPO"),;
								{ Array(Len(aHeader) + 1) }, { Recno() } } )
				nCols := Len(aCols)
				nCnt  := 1
			Else
				Aadd(aCols[nCols][2], Array(Len(aHeader) + 1))
				Aadd(aCols[nCols][3], Recno())
				nCnt  := Len(aCols[nCols][2])
			Endif
			aCols[nCols][2][nCnt][Len(aHeader) + 1] := .F.
			For nHead := 1 To Len(aHeader)
				If aHeader[nHead][10] = "V"
					aCols[nCols][2][nCnt][nHead] := CriaVar(AllTrim(aHeader[nHead][2]))
				Else
					aCols[nCols][2][nCnt][nHead] := &(AllTrim(aHeader[nHead][2]))
				Endif
			Next
			DbSkip()
		EndDo
	Endif

	aColsPadTipo := { Array(Len(aHeader) + 1) }
	For nHead := 1 To Len(aHeader)
		aColsPadTipo[1][nHead] := CriaVar(AllTrim(aHeader[nHead][2]))
	Next
	aColsPadTipo[1][nHead] := .F.
Else
	lFound := MsSeek(xFilial(cAlias)+cCodigo)
	Store COLS cAlias TO aCols FROM aHeader VETTRAB aVetTrab While xFilial(cAlias) == &(cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL") .and. cCodigo == &(cAlias+"->"+PrefixoCpo(cAlias)+"_CODIGO")
	If ! lFound
		n := 1
		Inclui := .T.
		Store COLS Blank cAlias TO aCols FROM aHeader
		Inclui := lSalv
	EndIf

	If Len(aCols) == 0
	   	n := 1
	   	Inclui := .T.
	   	Store COLS Blank cAlias TO aCols FROM aHeader
	   	Inclui := lSalv
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VldCorresp³ Autor ³ Michele Tatagiba      ³ Data ³ 07.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se liar para a PlsVldGD                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldCorresp(cTipo)                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldCorresp(cTipo,cCodigo,cCorresp)

// cTipo == 1 , estou digitando se e correspondencia para o BAU
// cTipo == 2 , estou digitando se e correspondencia para o BB8
LOCAL lRet    := .T.
LOCAL nInd    := 1
LOCAL nQtd    := 0
LOCAL cCodLoc := ""
                   
If cTipo == 1
   BB8->(DBSetOrder(1))
   If BB8->(MsSeek(xFilial("BB8")+cCodigo))
      While !BB8->(EOF()) .And. BB8->(BB8_FILIAL+BB8_CODIGO) == xFilial("BB8")+cCodigo
            If BB8->BB8_CORRES == "1"
     	       nQtd ++
		       cCodLoc := BB8->BB8_CODLOC
		    Endif
      BB8->(DBSkip())
      Enddo
   Endif   
Else
   For nInd := 1 To Len(oGet07:aCols)
     	If oGet07:aCols[nInd,oGet07:PLRETPOS("BB8_CORRES")] == "1" .and. ;
     	   oGet07:aCols[nInd,oGet07:PLRETPOS("BB8_CODLOC")] <> M->BB8_CODLOC
	    	nQtd ++
		    cCodLoc := oGet07:aCols[nInd,oGet07:PLRETPOS("BB8_CODLOC")]
     	Endif
   Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ To na getdados verificando se existe mais de uma correspondencia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == 2 .And. nQtd >= 1
	If M->BB8_CORRES == "1"
		MsgInfo(STR0036+cCodLoc) //"O Endereco de correspondecia foi selecionado anteriormente para o Local de Atendimento - "
//		lRet := .F. // apenas da mensagem de alerta quando tem mais de um local com "sim"
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ To na enchoice verificando se existe mais de uma correspondencia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == 1 .And. nQtd >= 1
	If cCorresp == "1"
		MsgInfo(STR0036+cCodLoc) //"O Endereco de correspondecia foi selecionado anteriormente para o Local de Atendimento - "
//		lRet := .F. // apenas da mensagem de alerta quando tem mais de um local com "sim"
	Endif
Endif

If cCorresp == "1" .And. cTipo <> 1 .And. M->BB8_CORRES == "1"
	MsgInfo(STR0037) //"O Endereco de correspondecia foi selecionado anteriormente para o Credenciado."
//	lRet := .F. // apenas da mensagem de alerta quando tem mais de um local com "sim"
Endif

Return(lRet)

Function PLSA360Int(cCodInt)
DEFAULT cCodInt := BAW->BAW_CODINT

lRet := Ascan(oGet02:aCols,;
{|a| a[oGet02:PLRETPOS("BAW_CODINT")] == cCodInt } ) > 0

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AFOLCHG    ³ Autor ³ Michele Tatagiba    ³ Data ³ 01.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Change do Folder Operadora                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AFOLChg(nFolder)

// Change para verificar se foi digitada alguma Operadora
If nFolder >= 3 //SAINDO DA OPERADORA
	If Empty(cCodInt) .Or. oGet02:aCols[oGet02:Linha(),Len(oGet02:aHeader)+1]
		HELP(" ",1,"PLS360FL")
		oFolder:SetOption(2)
		Return(.F.)
	Endif
Endif

// Change para verificar se foi digitada alguma Localidade antes de digitar uma Especialidade
If nFolder > 6 .And. nFolder < 8
   If Empty(oGet07:aCols[oGet07:Linha(),GdFieldPos("BB8_LOCAL",oGet07:aHeader)]) .Or. oGet07:aCols[oGet07:Linha(),Len(oGet07:aHeader)+1]
      HELP(" ",1,"PLS360FL22")
      oFolder:SetOption(3)
      lRetorno := .F.
      Return(.F.)
   Endif

   oGet03:ForceRefresh(oGet07)
Endif

AtuCabTel()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ As linhas abaixo irao resolver o problema que existe ao mudar de  |
//³ folder e dar um duplo clique sobre a getdados. Para funcionar,    |
//³ deveria primeiro clicar uma vez sobre a getdados e depois um      |
//³ duplo clique.                                                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Setfocus para o folder de operadora                               |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   oGet02:oBrowse:oBrowse:SetFocus()
ElseIf nFolder == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contabilidade									                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrwCtb:oBrowse:oBrowse:SetFocus()
ElseIf nFolder == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TPLSBRW -> HORARIO ESPECIAL X RDA                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrwRda:oBrowse:oBrowse:SetFocus()
ElseIf nFolder == 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TPLSBRW -> FAIXA DE DESCONTO	                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrwFaixa:oBrowse:oBrowse:SetFocus()	
ElseIf nFolder == 6
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Setfocus para o folder de Local de Atendimento                    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGet07:oBrowse:oBrowse:SetFocus()
//ElseIf nFolder == 7 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Setfocus para o folder de Especialidade                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oGet03:oBrowse:oBrowse:SetFocus()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AFOL2CHG   ³ Autor ³ Michele Tatagiba    ³ Data ³ 01.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Change do Folder Especialidade - Localidade                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AFOL2Chg(nFolder)

//LOCAL aBrw := {"oGet03","oGet06","oGet09","oGet10","oGet16","oGet18","oGet19","oGet20","oGet21"}
LOCAL aBrw := {"oGet03"}
LOCAL I    := 1

// Change para verificar se foi digitada alguma Especialidade a partir de uma Localidade
If Empty(oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BAX_CODESP")]) .Or. oGet03:aCols[oGet03:Linha(),Len(oGet03:aHeader)+1]
   Return(.F.)
Endif                  

lRetorno := .T.
For I:=1 To Len(aBrw)
	&(aBrw[I]):OBROWSE:OBROWSE:LREADONLY := .F.
Next


Return(.T.)



Function PLSA365Fil(cCodInt,cCodEsp)
DEFAULT cCodEsp := BAQ->(BAQ_CODINT+BAQ_CODESP)

If IsInCallStack("PLSA791")
	cCodigo:= M->BAX_CODIGO
Endif         
BBF->(DBSetOrder(1))
lRet := BBF->(MsSeek(xFilial("BBF")+cCodigo+cCodInt+cCodEsp))

Return(lRet)


Function PLSA365Dat(cCodEsp,dDatInc)
LOCAL   lRet    := .F.
DEFAULT cCodEsp := BAQ->(BAQ_CODINT+BAQ_CODESP)

BBF->(DBSetOrder(1))
If BBF->(MsSeek(xFilial("BBF")+cCodigo+cCodEsp))
   lRet := dDatInc >= BBF->BBF_DATINC
Endif   

If ! lRet
   MsgInfo(STR0040) //"A data informada e menor do que a data da inclusao da especialidade do Prestador"
Endif   

Return(lRet)


/*
Static Function PLS365Sint()

LOCAL lRet := .F.
LOCAL cCodPro := oGet06:aCols[oGet06:Linha(),oGet06:PlRetPos("BC0_CODOPC",.T.,aCab06)]
LOCAL cCodPad := oGet06:aCols[oGet06:Linha(),oGet06:PlRetPos("BC0_CODPAD",.T.,aCab06)]
   
BR8->(DBSetOrder(1))
If BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))   
   If BR8->BR8_ANASIN == "1"
      lRet := .T.     
   Else
      Help("",1,"PLS365SIN")
   Endif
Endif

Return(lRet)
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS365EndF ³ Autor ³ Michele Tatagiba    ³ Data ³ 18.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retira o filtro dos browses, um a um                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLS365ENDF                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oBrw       - nome do browse que vai perder o filtro        ³±±
±±³          ³ nPosCpoPri - Campo do aheader que nao pode ficar em branco ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function PLS365EndF(oBrw,nPosCpoPri)
      
Local nI
Local nLine := 0
If !oBrw:lFilter
   Return
EndIf

For nI := 1 to Len(oBrw:aItColDel)
   aDel(oBrw:aColsNoFil,oBrw:aItColDel[nI]-nI+1)
   aDel(oBrw:aVetNoFil,oBrw:aItColDel[nI]-nI+1)
Next

aSize(oBrw:aVetNoFil,Len(oBrw:aColsNoFil)-Len(oBrw:aItColDel))
aSize(oBrw:aColsNoFil,Len(oBrw:aColsNoFil)-Len(oBrw:aItColDel))
nLine := Len(oBrw:aColsNoFil)

For nI := 1 to Len(oBrw:aCols)
   If !Empty(oBrw:aCols[nI,nPosCpoPri])
      aadd(oBrw:aColsNoFil,aClone(oBrw:aCols[nI]))
      aadd(oBrw:aVetNoFil,oBrw:aVetTrab[nI])
   Endif
Next

aCols             := aClone(oBrw:aColsNoFil)
oBrw:aCols        := aClone(oBrw:aColsNoFil)
oBrw:aVetTrab     := aClone(oBrw:aVetNoFil)
oBrw:lFilter      := .F.
oBrw:aColsNoFil   := {}
oBrw:aVetNoFil    := {}
oBrw:aItColDel    := {}

Return
*/

FUNCTION PLS365TES()

M->BAX_DESESP := ""          
oGet03:ADDLINE()

RETURN(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA365DRM ³ Autor ³ Tulio Cesar      ³ Data ³ 16.03.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Botao para possibilitar dividir a renumeracao do proc.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA365DRM(nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aOldHeader := aClone(aHeader)
LOCAL aOldCols   := aClone(aCols)
LOCAL nOldN      := n           	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dados do dialogo...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca      := 0                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dados do browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oBrwBZB    := {}
LOCAL aDadBZB    := {}
LOCAL aCabBZB    := {}
LOCAL aTrbBZB    := {}

LOCAL cCodTab    := oGet06:FieldGet("BC0_CODTAB",oGet06:Linha(),oGet06:aHeader)
LOCAL cCodPro    := oGet06:FieldGet("BC0_CODOPC",oGet06:Linha(),oGet06:aHeader)
LOCAL cDesPro    := oGet06:FieldGet("BC0_DESOPC",oGet06:Linha(),oGet06:aHeader)

Local aSize
Local aInfo
Local aObjects
Local aPosObj
Local i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta rotina so sera usada na alteracao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
   MsgInfo(STR0041) //"Este botao nao esta disponivel na opcao incluir"
   Return
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols e aHeader...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BZB" TO aCabBZB For .T.
If nOpc == K_Incluir
   Store COLS Blank "BZB" TO aDadBZB FROM aCabBZB
Else
   BZB->(DbSetOrder(1))
   If BZB->(MsSeek(xFilial("BZB")+M->BAU_CODIGO+cCodInt+cCodLoc+cCodEsp+cCodTab+cCodPro))
      Store COLS "BZB" TO aDadBZB FROM aCabBZB VETTRAB aTrbBZB ;                                        
      While BZB->(BZB_FILIAL+BZB_CODIGO+BZB_CODINT+BZB_CODLOC+BZB_CODESP+BZB_CODTAB+BZB_CODOPC) == ;
            xFilial("BZB")+M->BAU_CODIGO+cCodInt+cCodLoc+cCodEsp+cCodTab+cCodPro
   Else
      Store COLS Blank "BZB" TO aDadBZB FROM aCabBZB
   Endif   
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
For i := 3 To Len(aSize)
	aSize[i] := Round(aSize[i] * 0.7, 0)
Next i
aObjects := {}       
aAdd( aObjects, { 1, 1, .T., .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPOsObj[1,4] += aPosObj[1,1]
aPOsObj[1,3] += aPosObj[1,2]

DEFINE MSDIALOG oDlg TITLE STR0042+cCodPro+" - "+cDesPro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel //"Divisao Remuneracao - "
oDlg:lEscClose := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBZB   := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBZB ,aDadBZB ,.F. ,"BZB" ,nOpc,STR0042+cCodPro+" - "+cDesPro ,nil,nil,nil,aTrbBZB,,,) //"Divisao Remuneracao - "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso opcao seja confirmada atualiza os dados...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Coberturas x Especialidade                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Begin Transaction
   
   aChave := {}
   aadd(aChave,{"BZB_CODIGO",M->BAU_CODIGO})
   aadd(aChave,{"BZB_CODINT",cCodInt})
   aadd(aChave,{"BZB_CODLOC",cCodLoc})
   aadd(aChave,{"BZB_CODESP",cCodEsp})
   aadd(aChave,{"BZB_CODTAB",cCodTab})
   aadd(aChave,{"BZB_CODOPC",cCodPro})
         
   oBrwBZB:Grava(aChave)
   End Transaction
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols   := aOldCols
aHeader := aOldHeader
n       := nOldN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA365VID ³ Autor ³ Tulio Cesar        ³ Data ³ 16.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera um registro do arquivo de remuneracoes mensais     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA365VID
Local I__f := 0

LOCAL oDlg
LOCAL nOpca     := 0                                               
LOCAL oEnc
LOCAL bOK       := { || nOpca := 1,If( Obrigatorio(oEnc:aGets,oEnc:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel   := { || oDlg:End() }
LOCAL cCadastro := STR0043 //"Alteracao"
LOCAL aOldTela  := aTela
LOCAL aOldGets  := aGets               
LOCAL nOrdBBB   := BBB->(IndexOrd())
LOCAL nRecBBB   := BBB->(Recno())

PRIVATE aTela   := {}
PRIVATE aGets   :={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,000 TO ndLinFin,ndColFin OF GetWndDefault()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "BBB" To Memory

oEnc := BBB->(MsMGet():New("BBB",BBB->(Recno()),K_Alterar,,,,,{015,004,192,390},,,,,,oDlg,,,.F.))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tratamento de acordo com a opcao...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Inclui movimento...                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BBB->(PLUPTENC("BBB",K_Alterar))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura aGets e aTela e Arquivo de Usuarios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := aOldTela
aGets := aOldGets

BBB->(DbSetOrder(nOrdBBB))
BBB->(DbGoTo(nRecBBB))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.F.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA365DCP ³ Autor ³ Tulio Cesar      ³ Data ³ 22.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Botao para possibilitar diferenciar a composicao de um    ³±±
±±³          ³ procedimento no folder rda x local x esp x proc. autoriz. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA365DCP(nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL IncluiSlv  := Inclui
LOCAL bRest      := { || Inclui  := IncluiSlv }
LOCAL aOldHeader := aClone(aHeader)
LOCAL aOldCols   := aClone(aCols)
LOCAL nOldN      := n           	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dados do dialogo...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca      := 0
LOCAL nPos1
LOCAL nPos2
LOCAL nPos3
LOCAL nCont      := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dados do browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oBrwBDN    := {}
LOCAL aDadBDN    := {}
LOCAL aCabBDN    := {}
LOCAL aTrbBDN    := {}
LOCAL aAux
LOCAL lCarregar  := .F.

LOCAL cCodTab    := oGet06:FieldGet("BC0_CODTAB",oGet06:Linha(),oGet06:aHeader)
LOCAL cCodPad    := oGet06:FieldGet("BC0_CODPAD",oGet06:Linha(),oGet06:aHeader)
LOCAL cCodPro    := oGet06:FieldGet("BC0_CODOPC",oGet06:Linha(),oGet06:aHeader)
LOCAL cDesPro    := oGet06:FieldGet("BC0_DESOPC",oGet06:Linha(),oGet06:aHeader)

Local aSize
Local aInfo
Local aObjects
Local aPosObj
Local i

LOCAL cIndBDN
LOCAL cMsgInd := "Atencao!!! Alterar o indice 1 do arquivo BDN para a expressao BDN_FILIAL+BDN_CODIGO+BDN_CODINT+BDN_CODLOC+BDN_CODESP+BDN_CODTAB+BDN_CODPAD+BDN_CODOPC+BDN_CODUNI"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificacao de indice invalido...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BDN->(DbSetOrder(1))
cIndBDN := Alltrim(StrTran(BDN->(IndexKey())," ",""))

If cIndBDN <> "BDN_FILIAL+BDN_CODIGO+BDN_CODINT+BDN_CODLOC+BDN_CODESP+BDN_CODTAB+BDN_CODPAD+BDN_CODOPC+BDN_CODUNI"   
   MsgInfo(cMsgInd)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente codigos de item podem ser parametrizados...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DbSetOrder(1))
If ! ( BR8->(DbSeek(xFilial("BR8")+cCodPad+cCodPro)) .And. BR8->BR8_ANASIN == "1" )
   MsgInfo(STR0049) //"Somente procedimentos analiticos (itens) podem ser parametrizados nesta opção."
   Eval(bRest)
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta rotina so sera usada na alteracao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
   MsgInfo(STR0041) //"Este botao nao esta disponivel na opcao incluir"
   Eval(bRest)   
   Return
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols e aHeader...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BDN" TO aCabBDN For .T.
If nOpc == K_Incluir
   Store COLS Blank "BDN" TO aDadBDN FROM aCabBDN
   lCarregar := .T.
   Inclui    := .T.
   nOpc      := K_Incluir
Else
   BDN->(DbSetOrder(1))
   If BDN->(MsSeek(xFilial("BDN")+M->BAU_CODIGO+cCodInt+cCodLoc+cCodEsp+cCodTab+cCodPad+cCodPro))
      Store COLS "BDN" TO aDadBDN FROM aCabBDN VETTRAB aTrbBDN ;                                        
      While BDN->(BDN_FILIAL+BDN_CODIGO+BDN_CODINT+BDN_CODLOC+BDN_CODESP+BDN_CODTAB+BDN_CODPAD+BDN_CODOPC) == ;
            xFilial("BDN")+M->BAU_CODIGO+cCodInt+cCodLoc+cCodEsp+cCodTab+cCodPad+cCodPro
      Inclui := .F.      
      nOpc   := K_Alterar
   Else
      Store COLS Blank "BDN" TO aDadBDN FROM aCabBDN
      lCarregar := .T.
      Inclui    := .T.
      nOpc      := K_Incluir
   Endif   
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve carregar a composicao padrao da TDE...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BD4->(DbSetOrder(1))
If BD4->(MsSeek(xFilial("BD4")+cCodInt+cCodTab+cCodPad+cCodPro)) .And. lCarregar
   aAux  := aClone(aDadBDN[1])
   nPos1 := PLRETPOS("BDN_CODUNI",aCabBDN)
   nPos2 := PLRETPOS("BDN_REF",aCabBDN)
   nPos3 := PLRETPOS("BDN_DESUNI",aCabBDN)
   While ! BD4->(Eof()) .And. BD4->(BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO) == ;
                               xFilial("BD4")+cCodInt+cCodTab+cCodPad+cCodPro
                               
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera as composicoes com vigencia vencida ou  ³
		//³ com o inicio da vigencia posterior a Data Base       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If ( dDataBase < BD4->BD4_VIGINI .And. !Empty(BD4->BD4_VIGINI)) .Or.;
           ( dDataBase > BD4->BD4_VIGFIM .And. !Empty(BD4->BD4_VIGFIM))
           BD4->(DbSkip())
           Loop
        EndIf
             
        If nCont <> 1
           aadd(aDadBDN,aClone(aAux))
        Endif   
        aDadBDN[nCont,nPos1] := BD4->BD4_CODIGO
        aDadBDN[nCont,nPos2] := BD4->BD4_VALREF
        aDadBDN[nCont,nPos3] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_DESCRI")

        nCont ++         
   		BD4->(DbSkip())
   Enddo
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
For i := 3 To Len(aSize)
	aSize[i] := Round(aSize[i] * 0.7, 0)
Next i
aObjects := {}       
aAdd( aObjects, { 1, 1, .T., .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPOsObj[1,4] += aPosObj[1,1]
aPOsObj[1,3] += aPosObj[1,2]

DEFINE MSDIALOG oDlg TITLE STR0044+cCodPro+" - "+cDesPro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel//"Diferenciar a Composicao do Procedimento - "
oDlg:lEscClose := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBDN   := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBDN ,aDadBDN ,.F. ,"BDN" ,nOpc,STR0044+cCodPro+" - "+cDesPro ,nil,nil,nil,aTrbBDN,,,) //"Diferenciar a Composicao do Procedimento - "
oBrwBDN:oBrowse:lDelete	:= .F.
oBrwBDN:lAddLine		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso opcao seja confirmada atualiza os dados...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Coberturas x Especialidade                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Begin Transaction
   
   aChave := {}
   aadd(aChave,{"BDN_CODIGO",M->BAU_CODIGO})
   aadd(aChave,{"BDN_CODINT",cCodInt})
   aadd(aChave,{"BDN_CODLOC",cCodLoc})
   aadd(aChave,{"BDN_CODESP",cCodEsp})
   aadd(aChave,{"BDN_CODTAB",cCodTab})
   aadd(aChave,{"BDN_CODOPC",cCodPro})
   aadd(aChave,{"BDN_CODPAD",cCodPad})
   oBrwBDN:Grava(aChave)
   End Transaction
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa ponto de entrada PL365BOT1 para realizar o cancelamento dos dados³
	//³ manipulados.                    										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PL365BOT1")     
	    ExecBlock("PL365BOT1",.F.,.F.,{"4",,,,nOpc})
	EndIf  
	
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols   := aOldCols
aHeader := aOldHeader
n       := nOldN
Inclui  := IncluiSlv
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA365BCK ³ Autor ³ Tulio Cesar      ³ Data ³ 22.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o campo BCK_CODUNM - Diferenciacao de U.S por Und  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA365BCK()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lRet       := .T.
LOCAL cMVPLSCIRD := GetNewPar("MV_PLSCIRD","PLSRETCH,PLSRETM2,PLSRETPA,PLSRETREA")

If lRet
    
	BD3->(dbGoTop())

    lRet := BD3->(PlsSeek("BD3",1,"M->BCK_CODUNI","M->BCK_DESUNI","BD3_DESCRI"))
    
    If lRet

        If ! AllTrim(BD3->BD3_RDMAKE) $ cMVPLSCIRD
            lRet := .F.
            Help("",1,"PLSA365BCK")
        Endif   

    Endif

Endif


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA365Del ³ Autor ³ Thiago Machado Correa ³ Data ³ 22.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de exclusao de registro na RDA                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA365Del(nOpc,cOpc,cCdRda,cCdOpe,cLcAte,cCdEsp)

Local aChaves := {}

If  nOpc <> 4
	Return .T.
Endif

// Angelo - 09/11/2004
// Nao vai ocorrer cOpc == "O", pois as linhas foram comentadas na rotina chamadora
// cOpc == "O" nao foi excluido em funcao de uma possivel necessidade no futuro

If cOpc == "O"
	aadd(aChaves,{"BHU","BHU_CODIGO",cCdRda,"BHU_CODINT",cCdOpe})
	aadd(aChaves,{"BY5","BY5_CODIGO",cCdRda,"BY5_CODINT",cCdOpe})
	aadd(aChaves,{"BY6","BY6_CODIGO",cCdRda,"BY6_CODINT",cCdOpe})	
	aadd(aChaves,{"BB8","BB8_CODIGO",cCdRda,"BB8_CODINT",cCdOpe})
	aadd(aChaves,{"BYZ","BYZ_CODIGO",cCdRda,"BYZ_CODINT",cCdOpe})
Endif

If cOpc $ "O,L"	
	aadd(aChaves,{"BPI","BPI_CODIGO",cCdRda,"BPI_CODINT",cCdOpe,"BPI_CODLOC",cLcAte})
	aadd(aChaves,{"BZA","BZA_CODIGO",cCdRda,"BZA_CODINT",cCdOpe,"BZA_CODLOC",cLcAte})
	aadd(aChaves,{"BCK","BCK_CODIGO",cCdRda,"BCK_CODINT",cCdOpe,"BCK_CODLOC",cLcAte})
	aadd(aChaves,{"BIN","BIN_CODIGO",cCdRda,"BIN_CODINT",cCdOpe,"BIN_CODLOC",cLcAte})
	aadd(aChaves,{"BD6","BD6_CODRDA",cCdRda,"BD6_OPERDA",cCdOpe,"BD6_CODLOC",cLcAte})
	
	If PLSALIASEX("B24")
		aadd(aChaves,{"B24","B24_CODIGO",cCdRda,"B24_CODINT",cCdOpe,"B24_CODLOC",cLcAte})	
	Endif
	If PLSALIASEX("B58")
		aadd(aChaves,{"B58","B58_CODIGO",cCdRda,"B58_CODINT",cCdOpe,"B58_CODLOC",cLcAte})	
	Endif
Endif

If cOpc $ "O,L,E"	
	aadd(aChaves,{"BC0","BC0_CODIGO",cCdRda,"BC0_CODINT",cCdOpe,"BC0_CODLOC",cLcAte,"BC0_CODESP",cCdEsp})
	aadd(aChaves,{"BZB","BZB_CODIGO",cCdRda,"BZB_CODINT",cCdOpe,"BZB_CODLOC",cLcAte,"BZB_CODESP",cCdEsp})              
	aadd(aChaves,{"BDN","BDN_CODIGO",cCdRda,"BDN_CODINT",cCdOpe,"BDN_CODLOC",cLcAte,"BDN_CODESP",cCdEsp})
    aadd(aChaves,{"BE6","BE6_CODIGO",cCdRda,"BE6_CODINT",cCdOpe,"BE6_CODLOC",cLcAte,"BE6_CODESP",cCdEsp})
	aadd(aChaves,{"BBG","BBG_CODIGO",cCdRda,"BBG_CODINT",cCdOpe,"BBG_CODLOC",cLcAte,"BBG_CODESP",cCdEsp})
	aadd(aChaves,{"BBI","BBI_CODIGO",cCdRda,"BBI_CODINT",cCdOpe,"BBI_CODLOC",cLcAte,"BBI_CODESP",cCdEsp})
	aadd(aChaves,{"BE9","BE9_CODIGO",cCdRda,"BE9_CODINT",cCdOpe,"BE9_CODLOC",cLcAte,"BE9_CODESP",cCdEsp})
	aadd(aChaves,{"BBK","BBK_CODIGO",cCdRda,"BBK_CODINT",cCdOpe,"BBK_CODLOC",cLcAte,"BBK_CODESP",cCdEsp})
	aadd(aChaves,{"BBN","BBN_CODIGO",cCdRda,"BBN_CODINT",cCdOpe,"BBN_CODLOC",cLcAte,"BBN_CODESP",cCdEsp})
	aadd(aChaves,{"BD6","BD6_CODRDA",cCdRda,"BD6_OPERDA",cCdOpe,"BD6_CODLOC",cLcAte,"BD6_CODESP",cCdEsp})
Endif

lRet := PLSCHKDEL(aChaves)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PesqMed   ºAutor  ³Rafael P. Rizzatto  º Data ³  04/20/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa medico por Nome RDA e NUmero C.R                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PesqMed()

Local aArea		:= GetArea()                                          
Local cCampo	:= Space(40)             
Local aOrd 		:= {STR0046,STR0047} //"Nome"###"Numero C.R."
Local cOrd		:= ""
Local nPosLin  	:= 0  
Local oDlg
Local nOpc		:= 0
Local nPosNome	:= 0
Local nPosNumCR	:= 0
Local nTam     

nPosNome  := Ascan(oGet09:aHeader,{|x| Alltrim(x[2])=="BC1_NOMRDA"})
nPosNumCR := Ascan(oGet09:aHeader,{|x| Alltrim(x[2])=="BC1_NUMCR"})

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0048 //"Pesquisa"

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nOpc := oCBX:nAT,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION (nOpc :=0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc > 0

    nTam := len(Alltrim(cCampo))
    If  nTam == 0
        cCampo := " "
        nTam   := 1
    Endif
    
	If nOpc == 1
		nPosLin := Ascan(oGet09:aCols,{|x| Alltrim(UPPER(cCampo)) == substr(UPPER(x[nPosNome]),1,nTam) })
	Else
		nPosLin := Ascan(oGet09:ACols,{|x| Alltrim(cCampo) == substr(x[nPosNumCR],1,nTam) })	
	EndIf

	If nPosLin > 0
		oGet09:Atualiza()
	    oGet09:SetPos(nPosLin-1) 
    Else
		Help(" ",1,"NORECNO")
    EndIf
    
EndIf
						
RestArea(aArea)

Return														    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBY5 ºAutor  ³Microsiga           º Data ³  26/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para chamada no botao de OK na aba de Horarios      º±±
±±º          ³ Especiais para validar a Data de Vigencia Inicial.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBY5()   

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := ""
Local aChave  := {'01',M->BY5_CODHON+M->BY5_CODATI,'BY5_CODHON+BY5_CODATI'} //BY5_FILIAL, BY5_CODIGO, BY5_CODINT, BY5_CODHON, BY5_CODATI

If BY5->( FieldPos("BY5_VIGINI") ) > 0 .And. BY5->( FieldPos("BY5_VIGFIN") ) > 0
	cDatDe  := "BY5_VIGINI"
	cDatAte := "BY5_VIGFIN"

	lRet := PLSVLDVIG("BY5",0,oBrwRda,cDatDe,cDatAte,aChave)
EndIf

Return(lRet)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA365FCP³ Autor ³ Regiane R. Barreira   ³ Data ³ 08.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faixa x Condicao de Pagamento						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSA365FCP()		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA365FCP(nOpc)

LOCAL oDlg
LOCAL bFilter
Local nOpcA		:= 0
LOCAL bOK		:= {|| nOpcA := 1,oDlg:End() }
LOCAL bCancel   := {|| oDlg:End() }

DEFINE MSDIALOG oDlg TITLE PLSRetTit("BZ2") FROM 008.0,010.3 TO 035.0,100.3
   
CargaCols("BZ2",aVetTrabFCP,nOpc)
aHeaderFCP  := aClone(aHeader)
aColsFCP    := aClone(aCols)

bFilter		:= {|nLine,aColsFCP,aHeaderFCP|aColsFCP[nLine,PLRETPOS("BZ2_CODINT",aHeaderFCP,.T.)]==cCodInt}

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

oBrwBZ2 := TPLSBrw():New(035,005,350,195,nil,oDlg,nil,    ,nil,nil,nil,.T.,nil,.T.,nil,aHeaderFCP,aColsFCP,;
                                .F.,"BZ2",nOpc,PLSRetTit("BZ2"),nil,nil,nil,aVetTrabFCP,nil,nil,bFilter)                                

oBrwBZ2:cVldLine := 'PLSXANAFAI({"BZ2_CODINT"},"BZ2_FAIDE", "BZ2_FAIATE",n)'

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel)

If nOpcA == 1
	aHeaderFCP	:= aClone(oBrwBZ2:aHeader)
	aColsFCP	:= aClone(oBrwBZ2:aCols)
EndIf
	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsVldBY6 ³ Autor ³ Regiane R. Barreira   ³ Data ³ 10.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica as faixas de descontos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PlsVldBY6(cCampo)                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsVldBY6()
Local lRet := .T. 	//Conteudo de retorno

If N > 1
	If N < Len(aCols)
		If (AllTrim(ReadVar()) == "M->BY6_FAIDE") .AND. M->BY6_FAIDE <= aCols[N-1,PLRETPOS("BY6_FAIATE",aHeader,.T.)]
			MsgInfo(STR0052+" R$ "+Alltrim(Transform(aCols[N-1,PLRETPOS("BY6_FAIATE",aHeader,.T.)],"@R 999,999,999.9999"))) //"O valor inicial desta faixa de desconto deve ser maior que o valor final da faixa anterior"
			lRet := .F.
        EndIf

		If (AllTrim(ReadVar()) == "M->BY6_FAIATE") .AND. M->BY6_FAIATE >= aCols[N+1,PLRETPOS("BY6_FAIDE",aHeader,.T.)]
			MsgInfo(STR0053+" R$ "+Alltrim(Transform(aCols[N+1,PLRETPOS("BY6_FAIDE",aHeader,.T.)],"@R 999,999,999.9999"))) //"O valor final desta faixa de desconto deve ser menor que o valor inicial da proxima faixa"
			lRet := .F.
		EndIf
	Else
		If (AllTrim(ReadVar()) == "M->BY6_FAIDE") .AND. M->BY6_FAIDE <= aCols[N-1,PLRETPOS("BY6_FAIATE",aHeader,.T.)]	
			MsgInfo(STR0052+" R$ "+Alltrim(Transform(aCols[N-1,PLRETPOS("BY6_FAIATE",aHeader,.T.)],"@R 999,999,999.9999"))) //"O valor inicial desta faixa de desconto deve ser maior que o valor final da faixa anterior"
			lRet := .F.
		EndIf
	EndIf
Else
	If Len(aCols) > 1
		If (AllTrim(ReadVar()) == "M->BY6_FAIATE") .AND. M->BY6_FAIATE >= aCols[N+1,PLRETPOS("BY6_FAIDE",aHeader,.T.)]
			MsgInfo(STR0053+" R$ "+Alltrim(Transform(aCols[N+1,PLRETPOS("BY6_FAIDE",aHeader,.T.)],"@R 999,999,999.9999"))) //"O valor final desta faixa de desconto deve ser menor que o valor inicial da proxima faixa"			
			lRet := .F.
		EndIf
	EndIf
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSBAXESP ³ Autor ³ DAvid de Oliveira     ³ Data ³ 11.04.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Descrição da Especialidade informa da no BAX      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSBAXESP()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBAXESP()

Local cDesEsp := "" 	//Conteudo de retorno

If Type("oGet03") <> "O"

	If !Empty(BAX->BAX_CODESP)
	
		cDesEsp := Posicione("BAQ",1,xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP),"BAQ_DESCRI")
		
	EndIf

EndIf	

Return(cDesEsp) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVldBBN ³ Autor ³ Microsiga 		    ³ Data ³ 29.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valid do campo BBN_CODPSA								      |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVldBBN() 

Return(PlsSeek("BR8",,M->BBN_CODPAD+M->BBN_CODPSA,"BBN_DESPSA","BR8_DESCRI") .And. PLSGATNIV(M->BBN_CODPAD,M->BBN_CODPSA,"BBN") .And. PLSVldGD())

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDB24 ºAutor  ³Darcio R. Sporl     º Data ³  10/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função criada para validar a linha do aCols, para evitar    º±±
±±º          ³duplicidade de registro, no complemento do Cadastro de RDA, º±±
±±º          ³na Aba de Tabela Honorários X RDA.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldB24()
Local lRet    := .T.

If ReadVar() == "M->B29_TABPRE" 

	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+M->B29_CODINT+M->B29_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf

ElseIf ReadVar() == "M->B24_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+M->B24_CODINT+M->B24_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf

ElseIf ReadVar() == "M->B86_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+M->BI3_CODINT+M->B86_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
         
ElseIf ReadVar() == "M->BMC_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+BA0->BA0_CODIDE+BA0->BA0_CODINT+M->BMC_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
	
ElseIf ReadVar() == "M->BS0_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BS0_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
	
ElseIf ReadVar() == "M->BBI_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BBI_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
	
ElseIf ReadVar() == "M->BOR_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BOR_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
         
ElseIf ReadVar() == "M->BS9_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BS9_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
	
ElseIf ReadVar() == "M->B30_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->B30_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
	
ElseIf ReadVar() == "M->BC5_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BC5_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf
ElseIf ReadVar() == "M->BMB_TABPRE" 
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BMB_TABPRE) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf

ElseIf ReadVar() == "M->B57_TABPRE"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->B57_TABPRE) )
		lRet := .F.			
	EndIf
	
ElseIf ReadVar() == "M->B12_TABPRE"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->B12_TABPRE) )
		lRet := .F.			
	EndIf	

ElseIf ReadVar() == "M->B85_TABPRE"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->B85_TABPRE) )
		lRet := .F.			
	EndIf	
		    
ElseIf ReadVar() == "M->B13_TABPRE"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->B13_TABPRE) )
		lRet := .F.			
	EndIf	
	        
ElseIf ReadVar() == "M->BBI_TABREC"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BBI_TABREC) )   
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf	
	        
ElseIf ReadVar() == "M->B30_TABREC"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->B30_TABREC) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf	
	
ElseIf ReadVar() == "M->BC5_TABREC"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BC5_TABREC) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf	
	        
ElseIf ReadVar() == "M->BS0_TABREC"
	B22->(dbSetOrder(01))
	If !B22->( MsSeek(xFilial("B22")+PlsIntPad()+M->BS0_TABREC) )
		MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
		lRet := .F.			
	EndIf	
	
Elseif ReadVar() == "M->B24_VIGINI" 
	// Testa se arquivo esta posicionado para evitar posicionamento redundante.
	If B22->(Eof()) .or. B22->B22_CODTAB <> M->B24_TABPRE
	
		B22->(dbSetOrder(01))
		IF !B22->( MsSeek(xFilial("B22")+M->B24_CODINT+M->B24_TABPRE) )
			MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
			lRet := .F.			
		Endif
		
	Endif
	
	If lRet .and. !Empty(M->B24_VIGINI) .and. !Empty(M->B24_VIGFIN) .and. M->B24_VIGINI > M->B24_VIGFIN// Nao permitido.
		MsgStop(STR0060) //"A vigência inicial deve ser menor ou igual a vigência final."
		lRet := .F.			
	Endif
			
Elseif ReadVar() == "M->B24_VIGFIN" 
	// Testa se arquivo esta posicionado para evitar posicionamento redundante.
	If B22->(Eof()) .or. B22->B22_CODTAB <> M->B24_TABPRE
	
		B22->(dbSetOrder(01))
		IF !B22->( MsSeek(xFilial("B22")+M->B24_CODINT+M->B24_TABPRE) )
			MsgStop(STR0063) //"Código de horário especial não é válido."
			lRet := .F.			
		Endif
		
	Endif
	                
	If lRet .and. !Empty(M->B24_VIGINI) .and. !Empty(M->B24_VIGFIN) .and. M->B24_VIGFIN < M->B24_VIGINI// Nao permitido.
		MsgStop(STR0061) //"A vigência final deve ser maior ou igual a vigência inicial."
		lRet := .F.			
	Endif
Elseif ReadVar() == "M->B29_VIGINI" 
	// Testa se arquivo esta posicionado para evitar posicionamento redundante.
	If B22->(Eof()) .or. B22->B22_CODTAB <> M->B29_TABPRE
	
		B22->(dbSetOrder(01))
		IF !B22->( MsSeek(xFilial("B22")+M->B29_CODINT+M->B29_TABPRE) )
			MsgStop(STR0063) //"Código da Tabela de Preço não é válido."
			lRet := .F.			
		Endif
		
	Endif
	
	If lRet .and. !Empty(M->B29_VIGINI) .and. !Empty(M->B29_VIGFIN) .and. M->B29_VIGINI > M->B29_VIGFIN// Nao permitido.
		MsgStop(STR0060) //"A vigência inicial deve ser menor ou igual a vigência final."
		lRet := .F.			
	Endif
			
Elseif ReadVar() == "M->B29_VIGFIN" 
	// Testa se arquivo esta posicionado para evitar posicionamento redundante.
	If B22->(Eof()) .or. B22->B22_CODTAB <> M->B29_TABPRE
	
		B22->(dbSetOrder(01))
		IF !B22->( MsSeek(xFilial("B22")+M->B29_CODINT+M->B29_TABPRE) )
			MsgStop(STR0063) //"Código de horário especial não é válido."
			lRet := .F.			
		Endif
		
	Endif
	                
	If lRet .and. !Empty(M->B29_VIGINI) .and. !Empty(M->B29_VIGFIN) .and. M->B29_VIGFIN < M->B29_VIGINI// Nao permitido.
		MsgStop(STR0061) //"A vigência final deve ser maior ou igual a vigência inicial."
		lRet := .F.			
	Endif
Endif

Return(lRet)     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVigBY6 ºAutor  ³Microsiga           º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para chamada no botao de OK na aba de Horarios      º±±
±±º          ³ Especiais para validar a Data de Vigencia Inicial.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVigBY6()   

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := ""
Local aChave  := {'01',M->BY6_FAIDE,'BY6_FAIDE'} //BY6_FILIAL, BY6_CODIGO, BY6_CODINT, BY6_FAIDE

If BY6->( FieldPos("BY6_VIGINI") ) > 0 .And. BY6->( FieldPos("BY6_VIGFIN") ) > 0
	cDatDe  := "BY6_VIGINI"
	cDatAte := "BY6_VIGFIN"

	lRet := PLSVLDVIG("BY6",0,oBrwFaixa,cDatDe,cDatAte,aChave)
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSBC0VLD ºAutor  ³Microsiga           º Data ³  09/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a Data de Bloqueio na tabela BC0 foi informada   º±±
±±º          ³ e em caso positivo, valida se o motivo de bloqueio 		  º±± 
±±º          ³ foi informado.											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSBC0VLD()   
Local lRet := .T.

If BC0->( FieldPos("BC0_DATBLO") ) > 0 .And. BC0->( FieldPos("BC0_MOTBLO") ) > 0
	If !Empty(M->BC0_DATBLO) .And. Empty(M->BC0_MOTBLO)
		Aviso(STR0078,STR0079,{STR0069},2) //"Motivo do Bloqueio"###"Informe o Motivo do Bloqueio do Procedimento"###"Ok"
		lRet := .F.
	EndIf 
	
	If !Empty(M->BC0_DATBLO) .And. M->BC0_DATBLO < dDataBAse
		Aviso(STR0070,STR0071,{STR0069},2) //"Data de Bloqueio"###"A Data de Bloqueio do Procedimento não pode ser menor do que a Data Atual."###"Ok"
		lRet := .F.
	EndIf
EndIf

Return(lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSBC1VLD ºAutor  ³Microsiga           º Data ³  09/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a Data de Bloqueio na tabela BC1 foi informada   º±±
±±º          ³ e em caso positivo, valida se o motivo de bloqueio 		  º±±
±±º          ³ foi informado.											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSBC1VLD()   
Local lRet := .T.

If BC1->( FieldPos("BC1_DATBLO") ) > 0 .And. BC1->( FieldPos("BC1_MOTBLO") ) > 0
	If !Empty(M->BC1_DATBLO) .And. Empty(M->BC1_MOTBLO)
		Aviso(STR0078,STR0080,{STR0069},2) //"Motivo do Bloqueio"###"Informe o Motivo do Bloqueio do Corpo Clinico"###"Ok"
		lRet := .F.
	EndIf  
	
	If !Empty(M->BC1_DATBLO) .And. M->BC1_DATBLO < dDataBAse
		Aviso(STR0070,STR0074,{STR0069},2) //"Data de Bloqueio"###"A Data de Bloqueio do Corpo Clinico não pode ser menor do que a Data Atual."###"OK"
		lRet := .F.
	EndIf
	
	If Empty(M->BC1_DATBLO) .And. !Empty(M->BC1_CODBLO)
		Aviso(STR0070,STR0075,{STR0069},2) //"Data de Bloqueio"###"A Data de Bloqueio do Corpo Clinico, não foi Informada."###"OK"
		lRet := .F.
	EndIf 
	
EndIf

Return(lRet) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBY6 ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha do acols da Desc Fx Evento.                 º±±      
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldBY62()

Local nFor		:= 0
Local lRet 		:= .T.

For nFor := 1 To Len(oGet30:aCols) 
	// Valida deletados e primeira insercao de dados.
	If !oGet30:IsDeleted(nFor) .And. nFor != n	.And. Iif(	Len(oGet30:aCols) == 1,;
											   				!Empty(oGet30:FieldGet("BY6_DTFDPI", nFor)),;
															.T.)
																
 		// Data inicial no intervalo de uma data anterior nao deixa passar
   		If	M->BY6_DTFDPI >= oGet30:FieldGet("BY6_DTFDPI", nFor)  .And.; 
	   		(	M->BY6_DTFDPI <= oGet30:FieldGet("BY6_DTFDPF", nFor) .Or.; 
	   			Empty(oGet30:FieldGet("BY6_DTFDPF", nFor));	
	   		)
	   		// Valida o intevalo de procedimentos
	   		If 	( 	M->BY6_PROINI >= oGet30:FieldGet("BY6_PROINI", nFor) .And.; 
	   				M->BY6_PROINI <= oGet30:FieldGet("BY6_PROFIM", nFor) 	) .Or.;
	   			( 	M->BY6_PROFIM >= oGet30:FieldGet("BY6_PROINI", nFor) .And.; 
	   				M->BY6_PROFIM <= oGet30:FieldGet("BY6_PROFIM", nFor) 	)		   			
	   			MsgInfo(OemtoAnsi(STR0044)) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
				lRet := .F.
				exit 
			EndIf
		EndIf
  		// Data final no intervalo de uma data anterior nao deixa passar
   		If	M->BY6_DTFDPF >= oGet30:FieldGet("BY6_DTFDPI", nFor)  .And.; 
	   		(	M->BY6_DTFDPF <= oGet30:FieldGet("BY6_DTFDPF", nFor) .Or.; 
	   			Empty(oGet30:FieldGet("BY6_DTFDPF", nFor));	
	   		)
   			// Valida o intevalo de procedimentos
	   		If 	( 	M->BY6_PROINI >= oGet30:FieldGet("BY6_PROINI", nFor) .And.; 
	   				M->BY6_PROINI <= oGet30:FieldGet("BY6_PROFIM", nFor) 	) .Or.;
	   			( 	M->BY6_PROFIM >= oGet30:FieldGet("BY6_PROINI", nFor) .And.; 
	   				M->BY6_PROFIM <= oGet30:FieldGet("BY6_PROFIM", nFor) 	)		   			
	   			MsgInfo(OemtoAnsi(STR0044)) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
				lRet := .F.
				exit 
			EndIf
		EndIf 
		// Comporta intervalo de datas
		If 	M->BY6_DTFDPI <= oGet30:FieldGet("BY6_DTFDPI", nFor) .And.;
			(	( 	M->BY6_DTFDPF >= oGet30:FieldGet("BY6_DTFDPF", nFor) .And.;
			 		!Empty(oGet30:FieldGet("BY6_DTFDPF", nFor));
				) .Or.; 
	   			Empty(M->BY6_DTFDPF) )
	  		// Valida o intevalo de procedimentos
	   		If 	( 	M->BY6_PROINI >= oGet30:FieldGet("BY6_PROINI", nFor) .And.; 
	   				M->BY6_PROINI <= oGet30:FieldGet("BY6_PROFIM", nFor) 	) .Or.;
	   			( 	M->BY6_PROFIM >= oGet30:FieldGet("BY6_PROINI", nFor) .And.; 
	   				M->BY6_PROFIM <= oGet30:FieldGet("BY6_PROFIM", nFor) 	)		   			
	   			MsgInfo(OemtoAnsi(STR0044)) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
				lRet := .F.
				exit 
			EndIf
	   	EndIf	
	
	EndIf
Next
		
Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVeVigOp   ºAutor  ³Totvs			    º Data ³  22/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Vigencia da Operadora			                     º±±      
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVeVigOp(cOper,cRDA,dData)
Local lRet 		:= .F.
Local nFor      := 0
Local cSQL 		:= ""
Default cOper	:= PLSINTPAD()
 
If TYPE("oGet02") =="O"
	For nFor := 1 To Len(oGet02:aCols) 
		If !oGet02:IsDeleted(nFor) .And. oGet02:FieldGet("BAW_CODINT", nFor) == cOper
		 	If !Empty(oGet02:FieldGet("BAW_VIGFIN", nFor)) 
		 		If dData <= oGet02:FieldGet("BAW_VIGFIN", nFor) .And. dData >= oGet02:FieldGet("BAW_VIGINI", nFor)		 			
		    		lRet := .T.
		    		Exit
		   		Endif
		 	Else
		 		If dData >= oGet02:FieldGet("BAW_VIGINI", nFor)
		 			lRet := .T. 
		 			Exit
		 		Endif
		 	Endif
		Endif	
	End
Else
	cSQL := "SELECT BAW_VIGINI, BAW_VIGFIN FROM "+ RetSQLName("BAW")
	cSQL += " WHERE BAW_FILIAL = '" + xFilial("BAW")+ "' AND "
	cSQL += " BAW_CODINT = '" + cOper+ "' AND "
	cSQL += " BAW_CODIGO = '" + cRDA+ "' AND "
	cSQL += " D_E_L_E_T_ = '' "
	
	PLSQuery(cSQL,"TrbBAW")

   	While TrbBAW->(!Eof()) 
   		If !Empty(TrbBAW->BAW_VIGFIN) 
   			If dData <= TrbBAW->BAW_VIGFIN .And. dData >= TrbBAW->BAW_VIGINI
		   		lRet := .T. 
		   		Exit
		   	Endif
		Else
			If dData >= TrbBAW->BAW_VIGINI
		   		lRet := .T.
		 		Exit
		 	Endif
		Endif
    
    	TrbBAW->(dbSkip())
   	End
   	TrbBAW->(dbCloseArea())
Endif
	
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsDInFxPr   ºAutor  ³Totvs			    º Data ³  22/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Vigencia da Operadora			                     º±±      
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsDInFxPr()
LOCAl lRet 		:= .T.
LOCAl cAlias    := Substr(ReadVar(),4,3)
LOCAL cOper	    := PLSINTPAD()
LOCAL aArea     := GetArea()
LOCAL cCampo    := ReadVar()

If cCampo $ "M->"+cAlias+"_DTFDPI,M->B62_DTVGIN,M->B59_DTMAJI" .And. !Empty(cCampo)

	If FieldPos(cAlias+"_CODINT") > 0 .And. TYPE("M->"+cAlias+"_CODINT") <> "U" 
		cOper:= &("M->"+cAlias+"_CODINT") 
	Endif	
	
    If !PlsVeVigOp(cOper,BAU->BAU_CODIGO,&(cCampo))
		lRet:=.F.
		Help( ,, 'HELP',,"Vigencia da Operadora vencida!", 1, 0)
	Endif
Endif

RestArea(aArea)
Return lRet 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldB30 ºAutor  ³Microsiga           º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para chamada no botao de OK na aba de Horarios      º±±
±±º          ³ Especiais para validar a Data de Vigencia Inicial.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldB30()

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := ""
Local aChave  := {'01',M->B30_CODPRO+M->B30_VERSAO+M->B30_CODTAB+M->B30_TABPRE,'B30_CODPRO+B30_VERSAO+B30_CODTAB+B30_TABPRE'}

If b30->( FieldPos("B30_VIGDE") ) > 0 .And. b30->( FieldPos("B30_VIGATE") ) > 0
	cDatDe  := "B30_VIGDE"
	cDatAte := "B30_VIGATE"

	lRet := PLSVLDVIG("B30",0,oBrwB30,cDatDe,cDatAte,aChave)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldB59 ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha do acols da majoracao.                      º±±      
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldB59()
Local nFor		:= 0
Local lRet 		:= .T.

For nFor := 1 To Len(oBrwB59:aCols) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Valida deletados e primeira insercao de dados.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !oBrwB59:IsDeleted(nFor) .And. nFor != n	.And. Iif(	Len(oBrwB59:aCols) == 1,;
											   				!Empty(oBrwB59:FieldGet("B59_DTMAJI", nFor)),;
															.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Data inicial no intervalo de uma data anterior nao deixa passar
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   		If	M->B59_CODINT ==  oBrwB59:FieldGet("B59_CODINT", nFor) .And. ;
   			M->B59_DTMAJI >= oBrwB59:FieldGet("B59_DTMAJI", nFor)  .And.; 
	   		(	M->B59_DTMAJI <= oBrwB59:FieldGet("B59_DTMAJF", nFor) .Or.; 
	   			Empty(oBrwB59:FieldGet("B59_DTMAJF", nFor));	
	   		)   			
   			MsgInfo(OemtoAnsi("Esta Vigencia esta no intervalo de outra ja cadastrada"))
			lRet := .F.
			exit 
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Data final no intervalo de uma data anterior nao deixa passar
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   		If	M->B59_CODINT ==  oBrwB59:FieldGet("B59_CODINT", nFor) .And. ;
   			M->B59_DTMAJF >= oBrwB59:FieldGet("B59_DTMAJI", nFor)  .And.; 
	   		(	M->B59_DTMAJF <= oBrwB59:FieldGet("B59_DTMAJF", nFor) .Or.; 
	   			Empty(oBrwB59:FieldGet("B59_DTMAJF", nFor));	
	   		)
   			MsgInfo(OemtoAnsi("Esta Vigencia esta no intervalo de outra ja cadastrada")) 
			lRet := .F.
			exit
		EndIf 
		
			// Comporta intervalo de datas
		If 	M->B59_CODINT ==  oBrwB59:FieldGet("B59_CODINT", nFor) .And. ;
			M->B59_DTMAJI <= oBrwB59:FieldGet("B59_DTMAJI", nFor) .And.;
			(	( 	M->B59_DTMAJF >= oBrwB59:FieldGet("B59_DTMAJF", nFor) .And.;
			 		!Empty(oBrwB59:FieldGet("B59_DTMAJF", nFor));
				) .Or.; 
	   			Empty(M->B59_DTMAJF) )
	  		MsgInfo(OemtoAnsi("Esta Vigencia esta no intervalo de outra ja cadastrada")) 
			lRet := .F.
			exit
	   	EndIf	
	
	EndIf
Next
		
Return( lRet ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldB62 ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha do acols da Associacao.                     º±±      
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldB62()
Local nFor		:= 0
Local lRet 		:= .T.

For nFor := 1 To Len(oGet30:aCols) 
	// Valida deletados e primeira insercao de dados.
	If !oGet30:IsDeleted(nFor) .And. nFor != n	.And. Iif(	Len(oGet30:aCols) == 1,;
											   				!Empty(oGet30:FieldGet("B62_DTVGIN", nFor)),;
															.T.)
 		// Data inicial no intervalo de uma data anterior nao deixa passar
   		If M->B62_CODINT ==  oGet30:FieldGet("B62_CODINT", nFor) .And. ;
   			M->B62_DTVGIN >= oGet30:FieldGet("B62_DTVGIN", nFor)  .And.; 
	   		(M->B62_DTVGIN <= oGet30:FieldGet("B62_DTVGIN", nFor) .Or.; 
	   			Empty(oGet30:FieldGet("B62_DTVGF", nFor));	
	   		)   			
   			MsgInfo(OemtoAnsi("Esta Vigencia esta no intervalo de outra ja cadastrada")) 
			lRet := .F.
			exit 
		EndIf
  		
  		// Data final no intervalo de uma data anterior nao deixa passar
   		If M->B62_CODINT ==  oGet30:FieldGet("B62_CODINT", nFor) .And. ;
   			M->B62_DTVGF >= oGet30:FieldGet("B62_DTVGIN", nFor)  .And.; 
	   		(	M->B62_DTVGF <= oGet30:FieldGet("B62_DTVGF", nFor) .Or.; 
	   			Empty(oGet30:FieldGet("B62_DTVGF", nFor));	
	   		)
   			MsgInfo(OemtoAnsi("Esta Vigencia esta no intervalo de outra ja cadastrada")) 
			lRet := .F.
			exit
		EndIf 
		
		// Comporta intervalo de datas
		If M->B62_CODINT ==  oGet30:FieldGet("B62_CODINT", nFor) .And. ;
   			M->B62_DTVGIN <= oGet30:FieldGet("B62_DTVGIN", nFor) .And.;
			(	( M->B62_DTVGF >= oGet30:FieldGet("B62_DTVGIN", nFor) .And.;
			 		!Empty(oGet30:FieldGet("B62_DTVGF", nFor));
				) .Or.; 
	   			Empty(M->B62_DTVGF) )
	  		MsgInfo(OemtoAnsi("Esta Vigencia esta no intervalo de outra ja cadastrada")) 
			lRet := .F.
			exit
	   	EndIf	
	
	EndIf
Next
		
Return( lRet ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldMaj ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os campos da majoracao.		                      º±±      
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldMaj(nTipo)                               
           
Local lRet := .T. 

Default nTipo := 1

If nTipo == 1 // Fisico
	If !(M->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") .Or. M->BAU_TIPPE == "F")
		lRet := .F.
	EndIf
ElseIf 	nTipo == 2 // Cooperado
	If !(M->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE"))
		lRet := .F.
	EndIf
ElseIf nTipo == 3 // Juridico 
	If !(M->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") .Or. (M->BAU_TIPPE == "J"))
		lRet := .F.
	EndIf
EndIf 
           
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsCalMaj    ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o valor da majoracao. 			                     º±±      
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsCalMaj(cCodRda, cCodInt, dDataPro, cTipGuia)
Local nPorcen  	 := 0
Local cTipMaj  	 := "" 
Local cAlias   	 := ""
Default cCodRda  := ""  
Default cCodInt  := ""
Default dDataPro := ""
Default cTipGuia := "" 

B59->(DbSetOrder(1))
If B59->(MsSeek(xFilial("B59")+cCodRda+cCodInt))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifico a data
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	While !B59->(EoF()) .And. 	B59->B59_FILIAL+B59->B59_CODIGO+B59->B59_CODINT ==  xFilial("B59")+cCodRda+cCodInt		

    	If 	dDataPro >= B59->B59_DTMAJI .And. ( dDataPro <= B59->B59_DTMAJF .Or. Empty(B59->B59_DTMAJF) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Posiciono na RDA 	
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	    	BAU->( DbSetOrder(1) )
	    	If BAU->( MsSeek(xFilial("BAU")+cCodRda) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Pego o valor da majoracao
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     	 		Do Case
     	   			Case BAU->BAU_TIPPE == "F"  .And. !(BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE"))
     	    			nPorcen := B59->B59_PERFIS
     	    		Case BAU->BAU_TIPPE == "J" .And. !(BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE"))
     	    			nPorcen := B59->B59_PERJUR	
     	   			Case BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") .and. !empty(ReadVar())    	   					
     	    			
     	    			If Empty(cTipGuia)
     	    				If  SubStr(ReadVar(),4,3) $ "BE1|BE2|BEA|B44|B45" .Or. SubStr(ReadVar(),1,3) $ "BE1|BE2|BEA|B44|B45"
								cAlias := "BE1"
	     	    			Else
	     	    			 	cAlias := "BE4"
							EndIf
	     	    			If &(cAlias)->(FieldPos(cAlias+"_TIPMAJ")) > 0
	                        	cTipMaj := &("M->"+cAlias+"_TIPMAJ")
							Endif
     	    			Else
	     	    			If cTipGuia $ "01|02|04" 
	     	    				cAlias:= "BD5"
	     	    			Else
	     	    				cAlias:= "BE4"
	     	    			Endif
	     	    			
	     	    			If &(cAlias)->(FieldPos(cAlias+"_TIPMAJ")) > 0
	                        	cTipMaj := &(cAlias+"->"+cAlias+"_TIPMAJ")
							Endif
	     	    		Endif
	     	    			
						
     	    			If cTipMaj $ "/1/2/3"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
							//³ Quando intercambio, busco de acordo com o tipo de majoracao
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     	    				Do Case
     	    					Case cTipMaj == "1"	
     	    						nPorcen := B59->B59_PERFIS
	    						Case cTipMaj == "2"	
	     	    					nPorcen := B59->B59_PERJUR
	    						Case cTipMaj == "3"	
	     	    					nPorcen := B59->B59_PERCOO  
   							EndCase
		    			EndIf	     	    				
     	    	EndCase
     	    	Exit
     	 	EndIf		
   		EndIf
		B59->(DbSkip())
	EndDo
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(nPorcen)    

Function PLWhenMaj(cCodRda)
Local lRet := .F.
Default cCodRda := " "

BAU->(DbSetOrder(1))   
If BAU->(MsSeek(xFilial("BAU")+cCodRda)) .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")	 	
	lRet := .T.
Endif
     	    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS365BC1
Função para gravação dos dados da importação do Corpo Clínico (Primeira aba - RDA/Profissionais)
@author Oscar Zanin
@since 06/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS365BC1(aCorreto)

Local nJ	:= 0
Local lOk	:= .T.

BEGIN TRANSACTION

BC1->(DbSelectArea("BC1"))
BC1->(DbSetOrder(5)) //BC1_FILIAL+BC1_CODIGO+BC1_CODLOC+BC1_CODESP+BC1_CODPRF

For nJ := 1 To Len(aCorreto)
	
	lOk := .T. //Inicializa a cada ciclo
	//Verifica se o profissional já está no corpo clínico. Os Space(TamSX3(...)) são para completar os espaços em branco, sem eles a busca não encontra nada.
	If BC1->(MsSeek(aCorreto[nJ][9] + aCorreto[nJ][11] + aCorreto[nJ][2] + Space(TamSX3("BC1_CODPRF")[1]-Len(aCorreto[nJ][2])) + aCorreto[nJ][1] + Space(tamSX3("BC1_CODRDA")[1]-Len(aCorreto[nJ][1])) + Space(TamSX3("BC1_CODIGO")[1]-Len(aCorreto[nJ][11])) + aCorreto[nJ][13] + aCorreto[nJ][12]))
		lOk := .F.
	EndIf
	
	//Grava somente as RDAs/Profissionais novos
	If lOk	
		BC1->(RecLock("BC1", .T.))
			BC1->BC1_CODRDA	:= aCorreto[nJ][1]
			BC1->BC1_CODPRF	:= acorreto[nJ][2]
			BC1->BC1_NOMPRF	:= Posicione("BB0", 1, xFilial("BB0") + aCorreto[nJ][2], "BB0_NOME")
			BC1->BC1_PERSOC	:= aCorreto[nJ][3]
			BC1->BC1_PERDES	:= aCorreto[nJ][4]
			BC1->BC1_PERACR	:= aCorreto[nJ][5]
			BC1->BC1_CODBLO	:= aCorreto[nJ][6]
			BC1->BC1_CONSDV	:= aCorreto[nJ][7]
			BC1->BC1_OBSERV	:= aCorreto[nJ][8]
			BC1->BC1_FILIAL	:= aCorreto[nJ][9]
			BC1->BC1_CODINT	:= aCorreto[nJ][10]
			BC1->BC1_CODIGO	:= aCorreto[nJ][11]
			BC1->BC1_CODESP	:= aCorreto[nJ][12]
			BC1->BC1_CODLOC	:= aCorreto[nJ][13]
		BC1->(MsUnlock())
	EndIf
	
Next

BC1->(DbCloseArea())

END TRANSACTION

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS365BE6
Função para gravação dos dados da importação dos procedimentos (Segunda aba - Procedimentos)
@author Oscar Zanin
@since 06/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS365BE6(aCorreto)

Local nJ	:= 0
Local lOk	:= .T.

BEGIN TRANSACTION

BE6->(DbSelectArea("BE6"))
BE6->(DbSetOrder(1))

For nJ := 1 To Len(aCorreto)
	
	lOk := .T.
	If BE6->(MsSeek(aCorreto[nJ][4] + aCorreto[nJ][9] + Space(TamSX3("BE6_CODIGO")[1]-Len(aCorreto[nJ][9])) + aCorreto[nJ][5] + Space(TamSX3("BE6_CODPRF")[1]-Len(aCorreto[nJ][5])) + aCorreto[nJ][6] + aCorreto[nJ][8] + aCorreto[nJ][10] + aCorreto[nJ][2]))
		lOk := .F.
	EndIF
	
	If lOk
		BE6->(RecLock("BE6", .T.))
			BE6->BE6_CODTAB := aCorreto[nJ][1]
			BE6->BE6_CODPRO := aCorreto[nJ][2]
			BE6->BE6_PGTDIV := aCorreto[nJ][3]
			BE6->BE6_FILIAL := aCorreto[nJ][4]
			BE6->BE6_CODPRF := aCorreto[nJ][5]
			BE6->BE6_CODLOC := aCorreto[nJ][6]
			BE6->BE6_CODINT := aCorreto[nJ][7]
			BE6->BE6_CODESP := aCorreto[nJ][8]
			BE6->BE6_CODIGO := aCorreto[nJ][9]
			BE6->BE6_CODPAD := aCorreto[nJ][10]
		BE6->(MsUnlock())
	EndIF
Next

BE6->(DbCloseArea())
	
END TRANSACTION

Return

/*/{Protheus.doc} PLS365BC0
Função para gravação dos dados dos procedimentos autorizados
@author Oscar Zanin
@since 11/05/2015
@version P12
/*/
Function PLS365BC0(aCorreto)
Local nJ	:= 0
Local lOk	:= .T.

BEGIN TRANSACTION

BC0->(DbSelectArea("BC0"))
BC0->(DbSetOrder(1))

For nJ := 1 To Len(aCorreto)
	
	lOk := .T.
	
	If BC0->(MsSeek(aCorreto[nJ][1] + aCorreto[nJ][2] + aCorreto[nJ][3] + aCorreto[nJ][4] + aCorreto[nJ][5] + aCorreto[nJ][6] + aCorreto[nJ][7]))
		lOk := .F.
	EndIF
	
	If lOk
		BC0->(RecLock("BC0", .T.))
			BC0->BC0_FILIAL	:= aCorreto[nJ][1]
			BC0->BC0_CODIGO	:= aCorreto[nJ][2]
			BC0->BC0_CODINT	:= aCorreto[nJ][3]
			BC0->BC0_CODLOC	:= aCorreto[nJ][4]
			BC0->BC0_CODESP	:= aCorreto[nJ][5]
			BC0->BC0_CODTAB	:= aCorreto[nJ][6]
			BC0->BC0_CODOPC	:= aCorreto[nJ][7]
			BC0->BC0_VALCH	:= aCorreto[nJ][8]
			BC0->BC0_VALREA	:= aCorreto[nJ][9]
			BC0->BC0_FORMUL	:= aCorreto[nJ][10]
			BC0->BC0_EXPRES	:= aCorreto[nJ][11]
			BC0->BC0_PERDES	:= aCorreto[nJ][12]
			BC0->BC0_PERACR	:= aCorreto[nJ][13]
			BC0->BC0_TIPO	:= aCorreto[nJ][14]
			BC0->BC0_VIGDE	:= aCorreto[nJ][15]
			BC0->BC0_VIGATE	:= aCorreto[nJ][16]
			BC0->BC0_BANDA	:= aCorreto[nJ][17]
			BC0->BC0_UCO	:= aCorreto[nJ][18]
			BC0->BC0_CODBLO	:= aCorreto[nJ][19]
			BC0->BC0_DATBLO	:= aCorreto[nJ][20]
			BC0->BC0_OBSERV	:= aCorreto[nJ][21]
			BC0->BC0_CODPAD	:= aCorreto[nJ][22]
		BC0->(MsUnlock())
	EndIF
Next

BC0->(DbCloseArea())

END TRANSACTION

Return

/*/{Protheus.doc} PLSVLDACR
Valida cols do relacionamento de acreditações.

@Project	TTQLAU	 
@author	Lucas de Azevedo Nonato
@since		13/10/2015
@version	P12 
@Return	L 
@Obs 			  
/*/
Function PlsVldAcr()
Local lRet 	:= .T.
Local aArea := B7P->(GetArea())
Local nCnt 	:= 1

While nCnt <= Len(oGet60:aCols)

	If Alltrim(oGet60:aCols[nCnt][2])+oGet60:aCols[nCnt][4]+oGet60:aCols[nCnt][5] == AllTrim(M->B7P_CODACR)+M->B7P_CODINT+M->B7P_CODLOC

		If oGet60:aCols[nCnt][1] <> M->B7P_ITEM
			lRet := .F.
			Alert("Acreditação " + AllTrim(M->B7P_CODACR) + " ja está relacionada.")
			Exit
		EndIf
		
	EndIf
	
	nCnt++
		
EndDo

RestArea(aArea)

Return lRet

/*/{Protheus.doc} PLSVLDB62X
Função para as validações da tabela B62 - Aba de associação do complemento da RDA
@author Oscar Zanin
@since 31/03/2016
@version P12
/*/
Function PLSVLDB62X(nTp)
Local lRet := .F.

If nTp == 1
	lRet := EmpTy(M->B62_CODPAD) .OR. ExistCpo("BR4", M->B62_CODPAD, 1)                                             
elseIf nTp == 2
	lRet := EmpTy(M->B62_PROINI) .OR. ExistCpo("BR8",M->B62_CODPAD+M->B62_PROINI,1)                            
elseIf nTp == 3
	lRet := EmpTy(M->B62_PROFIM) .OR. ExistCpo("BR8",M->B62_CODPAD+M->B62_PROFIM,1)                          
elseIf nTP == 4
	lRet := EmpTy(M->B62_DTFDPI) .OR. M->B62_DTFDPI <= M->B62_DTFDPF
elseIf nTp == 5	
	lRet := EmpTy(M->B62_DTFDPF) .OR. (M->B62_DTFDPF >= M->B62_DTFDPI .AND. !(EmpTy(M->DTFDPI)))                                                
EndIf

return lRet


/*/{Protheus.doc} PLVLDBJLPT
Valid do campo BLJ_INDEDI (indicador de residencia utilizado no PTU A400)

@Project	TUWAEA
@author	Equipe Saude
@since		31/05/2016
@version	P11 
@Return	L 
@Obs 			  
/*/
Function PLVLDBJLPT 
Local nFor   := 0
Local lRet   := .F.
Local nAtPTU := 0               
Local nPosGERPTU := Ascan(oGet15:aHeader,{|x|x[2] == "BBF_GERPTU"})
Local nPosCODATU := Ascan(oGet15:aHeader,{|x|x[2] == "BBF_CODATU"})
Local nPosCODESP := Ascan(oGet15:aHeader,{|x|x[2] == "BBF_CODESP"})
Local nPosDESESP := Ascan(oGet15:aHeader,{|x|x[2] == "BBF_DESESP"})
Local cCodEsp1   := ""
Local cCodEsp2   := ""
Local cCodAtu1   := ""
Local cCodAtu2   := ""
			      
If nPosGERPTU > 0 .And. nPosCODATU > 0 .And. nPosCODESP > 0 .And. nPosDESESP > 0  			
	For nFor := 1 to len(oGet15:aCols)
		If oGet15:aCols[nFor][nPosGERPTU] == "1"  
			nAtPTU := nAtPTU + 1 
		EndIf
		
		If nAtPTU == 1
			cCodEsp1 := oGet15:aCols[nFor][nPosCODESP] + " - " + oGet15:aCols[nFor][nPosDESESP]
			cCodAtu1 := oGet15:aCols[nFor][nPosCODATU]
		ElseIf nAtPTU == 2
			cCodEsp2 := oGet15:aCols[nFor][nPosCODESP] + " - " + oGet15:aCols[nFor][nPosDESESP]
			cCodAtu2 := oGet15:aCols[nFor][nPosCODATU]
		EndIf	
	Next     
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Se BBF_GERPTU == 2 Não; não consiste 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nAtPTU <> 0
	Do Case
		Case M->BLJ_INDEDI == '1' .And. !Empty(cCodEsp1)
			 MsgInfo(STR0081+Alltrim(cCodEsp1)+".")//"Vinculando esta Formação Profissional para a Especialidade "  
			 lRet := .T.
		
		Case M->BLJ_INDEDI == '2' .And. !Empty(cCodEsp2)
	 		MsgInfo(STR0081+Alltrim(cCodEsp2)+".")//"Vinculando esta Formação Profissional para a Especialidade " 
	 		lRet := .T. 
	 	
	 	Case M->BLJ_INDEDI == '3' .And. !Empty(cCodAtu1) 
	  		MsgInfo(STR0082+Alltrim(cCodAtu1)+".")//"Vinculando esta Formação Profissional para a Área de Atuação "
	  		lRet := .T.
	 	
	 	Case M->BLJ_INDEDI == '4' .And. !Empty(cCodAtu2) 
	 		MsgInfo(STR0082+Alltrim(cCodAtu2)+".")//"Vinculando esta Formação Profissional para a Área de Atuação "
	 		lRet := .T.
	 	
	 	OtherWise  
			If M->BLJ_INDEDI == '1' .Or. M->BLJ_INDEDI == '2'  
				MsgInfo(STR0083)//"Não foi encontrado uma Especialidade parametrizada para o nível informado. Verifique o campo BBF_GERPTU das Especialidades desta RDA."
			ElseIf M->BLJ_INDEDI == '3' .Or. M->BLJ_INDEDI == '4'
				MsgInfo(STR0084)//"Não foi encontrado uma Área de Atuação parametrizada para o nível informado. Verifique os campos BBF_GERPTU/BBF_CODATU das Especialidades desta RDA."
			EndIf
	EndCase
Else
	lRet := .T.	
EndIf		

Return lRet


/*/{Protheus.doc} PLSSetSubE
Seta o array com as BAX alteradas

@Project	PLSSetSubE
@author	Pablo Alipio
@since		12/07/2018
@version	P12 
/*/
function PLSSetSubE(aSubEsp)
	aSubEspAlt := aSubEsp 
return

/*/{Protheus.doc} PLSGetSubE
Retorna o array com as BAX alteradas

@Project	PLSGetSubE
@author	Pablo Alipio
@since		12/07/2018
@version	P12 
@Return	Array 
/*/
function PLSGetSubE()
	local aSubEsp := aSubEspAlt
return aSubEsp

/*/{Protheus.doc} PlsExcEsp
	quando realizada a exclusão da especialidade, exclui os registros filhos
	@type  Static Function
	@author Thiago
	@since 08/2020
	@version version
	@param Codigo RDA, Codigo operadora, Codigo do local, codigo da especialidade, codigo sub especialidade
	@return return, return_type, return_description
	/*/
Static Function PlsExcEsp(cBauCod,cCodint,cCodLoc,cCodEsp,cCodSub)
local cSql :=" "
local nFor :=1
local aAlias := {"BC0","BZB","BDN","BE6","BBI","BE9","BBK","BBN","BC1","BBG"}
local cNtmSub := "BDN|BZB"

for nFor := 1 to len(aAlias)
	cSql += " Select R_E_C_N_O_ Rec, '" + aAlias[nFor] + "' campo FROM " + RetSqlName(aAlias[nFor])
	cSql += " WHERE "
	cSql += aAlias[nFor] + "_FILIAL = '" + xFilial("BZB") + "' "
	cSql += " AND " + aAlias[nFor] + "_CODIGO = '" + cBauCod + "' "
	cSql += " AND " + aAlias[nFor] + "_CODINT = '" + cCodint + "' "
	cSql += " AND " + aAlias[nFor] + "_CODLOC = '" + cCodLoc + "' "
	cSql += " AND " + aAlias[nFor] + "_CODESP = '" + cCodEsp + "' "
	if !( aAlias[nFor] $ cNtmSub )
		cSql += " AND " + aAlias[nFor] + "_CODSUB = '" + cCodSub + "' "
	endif
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " UNION "
next
	cSql += left(cSql, len(cSql)-7)

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"aArea",.f.,.t.)

	while ( !aArea->(eof()) )
		(aArea->(campo))->(dbgoto(aArea->rec))
		(aArea->(campo))->(Reclock((aArea->(campo)),.F.))
		(aArea->(campo))->(DBDelete())
		(aArea->(campo))->(msunlock())
		aArea->(DBSkip())
	enddo
		aArea->(DbCloseArea())
Return 

/*/{Protheus.doc} PlDupB30
	Pós validação do Browser Planos x RDA para evitar registros duplicados quando as vigencias estiverem vazias.
	@since 05/11/2021
/*/
Function PlDupB30()
Local nFor		:= 0
Local lRet 		:= .T.

For nFor := 1 To Len(oBrwB30:aCols) 
// Valida deletados e primeira insercao de dados.
	If !oBrwB30:IsDeleted(nFor) .And. nFor != n	.And. iif(	Len(oBrwB30:aCols) == 1,;
											   				!Empty(oBrwB30:FieldGet("B30_CODPRO", nFor)),;
															.T.)
		if M->B30_CODINT == oBrwB30:FieldGet("B30_CODINT", nFor) .AND.;
		   M->B30_CODPRO == oBrwB30:FieldGet("B30_CODPRO", nFor) .AND.;
		   M->B30_VERSAO == oBrwB30:FieldGet("B30_VERSAO", nFor) .AND.;
		   M->B30_VIGDE  == oBrwB30:FieldGet("B30_VIGDE", nFor) .AND.;
		   M->B30_TABPRE  == oBrwB30:FieldGet("B30_TABPRE", nFor)

			MsgInfo(OemtoAnsi(STR0088))//"Já existe um cadastro para este plano com a mesma versão, vigência e tabela de preço."
			lret := .f.
		endif
	
	endif

NEXT
Return lRet
