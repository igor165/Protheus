// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Veivm015.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM015 ³ Autor ³  Andre                ³ Data ³ 23/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno de REMESSA / CONSIGNADO                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM015

Private cIdeSB6
Private cNfiOri, cSerOri
Private cEstFor, cLojFor, nOpcMnu, cCodVV0
Private cChaInt, cChassi, nCusVei, nVBaIcm, nAliIcm, nTotIcm, cAlmVei
Private cNota        := cNumero := ""
Private cSerie       := ""
Private Inclui       := .t.
Private lAbortPrint  := .f.
Private aRotina      := MenuDef()
Private lChaTemp     := .f.
Private lMSErroAuto  := .f.
Private lMSHelpAuto  := .t.
Private aHeader      := {}
Private aCols        := {}
Private bRefresh     := { || .t. }
Private aIteParc     := {{cTod(""),0}}
Private cParPrg      := "3" // Faturamento
Private cTipSai      := "3" // Remessa
Private cBIcm0       := FlagQtVei := .t.
Private cCadastro    := OemToAnsi(STR0055) //Retorno de Remessa / Consignado
Private oFonte       := TFont():New( "Arial", 6, 12 )
Private oFnt6        := TFont():New( "Times New Roman", 7, 17 )
Private cGruVei      := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private aMemos       := {{"VVF_OBSMEM","VVF_OBSERV"}}
Private cObserv      := E_MSMM(VVF->VVF_OBSMEM,68)
Private aIndexVV0 	 := {}			//Variavel Para Filtro
Private lA1_IBGE     := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE     := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)

Private M->VVF_QTDVEI := 1

Private lMudouNum := .f.

aCampoVV1 := {}
FlagQtVei := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
cIndex    := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao := '!Empty(VV0->VV0_NUMPED) .and. VV0->VV0_SITNFI $ "12" .and. !Empty(VV0->VV0_NUMNFI) .and. VV0->VV0_TIPFAT <> "2" .and. VV0->VV0_OPEMOV $ "3/5"'

//cFiltra 	  := "A2_FILIAL=='"+xFilial('SA2')+"' .And. A2_CONDO == '1'"
bFiltraBrw 	:= {|| FilBrowse("VV0",@aIndexVV0,@cCondicao) }
Eval(bFiltraBrw)

aCores := {{'VV0->VV0_OPEMOV == "3" .and. VV0->VV0_SITNFI == "1"','BR_VERDE'},;
{'VV0->VV0_OPEMOV == "5" .and. VV0->VV0_SITNFI == "1"','BR_AMARELO'},;
{'VV0->VV0_OPEMOV == "3" .and. VV0->VV0_SITNFI == "2"','BR_PRETO'},;
{'VV0->VV0_OPEMOV == "5" .and. VV0->VV0_SITNFI == "2"','BR_VERMELHO'}}

mBrowse( 6, 1,22,75,"VV0",,,,,,aCores)

dbSelectArea("VV0")
RetIndex()
dbsetOrder(1)

#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_RTREMES³ Autor ³  Andre                ³ Data ³ 23/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorno da Remessa / Consignado                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RTREMES(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0
Local cont
Private oDesTes, cDesTes
Private oDatEmi, dDatEmi
Private cIdeSB6
Private lExclui := nOpc == 4
Private get_Observ := space(200)

Private nAcresFin := 0 // Cria Variavel para compatib. com o VEIVM011

if VV0->(EOF())
	Return .t.
Endif

cCodVV0 := VV0->VV0_NUMTRA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Inclui
	DbSelectArea("SX3")
	DbSeek("VVF")
	While !Eof().and.(x3_arquivo=="VVF")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		DbSkip()
	EndDo
Else
	RegToMemory("VVF",.f.)
	DbSelectArea("VVF")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Inclui
	DbSelectArea("SX3")
	DbSeek("VVG")
	While !Eof().and.(x3_arquivo=="VVG")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		DbSkip()
	EndDo
Else
	DbSelectArea("VVG")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

if nOpc == 3  // Devolucao
	if VV0->VV0_SITNFI == "2"
		MsgInfo(STR0056,STR0009) //Veiculo ja retornado... - Atencao!
		Return .f.
	Endif
Elseif nOpc == 4  // Devolucao
	if Empty(VV0->VV0_TRADEV)
		MsgInfo(STR0057 ,STR0009) //Nota Fiscal nao foi Devolvida... - Atencao!
	Endif
Endif

// Posiciona no Item da Nota de Saida
dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)

dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+VVA->VVA_CHASSI)

cChassi := VVA->VVA_CHASSI
cChaInt := VVA->VVA_CHAINT

dDatEmi := dDataBase
cCodDes := VV0->VV0_CODCLI
cLojDes := VV0->VV0_LOJA
cObs    := space(100)
cNomDes := ""
cDesTes := ""
FS_VALCLI(1)
FS_VALCLI(2)
nOpca   := 2

VE1->(dbSetOrder(1))
VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

VVR->(dbSetOrder(2))
VVR->(dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD))

VVC->(dbSetOrder(1))
VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))

DEFINE MSDIALOG oDlgRet TITLE OemtoAnsi(STR0058) FROM  02,06 TO 29,78 OF oMainWnd  //Dados da Devolucao

@ 013,000 SCROLLBOX oScroll VERTICAL SIZE 186,286 OF oDlgRet BORDER PIXEL

aFields := {{"CODCLI",STR0059        ,"C",TamSx3("VV0_CODCLI")[1],TamSx3("VV0_CODCLI")[1],"@!",.f.,,,,CLR_BLACK},; //Cliente
{"LOJA"  ,RetTitle("VV0_LOJA"),"C",TamSx3("VV0_LOJA")[1]  ,TamSx3("VV0_LOJA")[1]  ,"@!",.f.,,,,CLR_BLACK},;//Loja
{"NOMCLI",RetTitle("VV0_NOMCLI"),"C",TamSx3("VV0_NOMCLI")[1],60,"@!",.f.,,,,CLR_BLACK},;//Nome
{"CHASSI",RetTitle("VV0_CHASSI"),"C",TamSx3("VV0_CHASSI")[1],60,"@!",.f.,,,,CLR_BLACK},;//Chassi
{"CHAINT",RetTitle("VV0_CHAINT"),"C",TamSx3("VV0_CHAINT")[1],TamSx3("VV0_CHAINT")[1],"@!",.f.,,,,CLR_BLACK},;//Chassi Interno
{"MARCA" ,RetTitle("VV0_CODMAR"),"C",TamSx3("VV0_CODMAR")[1],40,"@!",.f.,,,,CLR_BLACK},;//Marca
{"GRUPO" ,RetTitle("VV0_GRUMOD"),"C",TamSx3("VV0_GRUMOD")[1],60,"@!",.f.,,,,CLR_BLACK},;//Grupo Modelo
{"MODELO",RetTitle("VV0_MODVEI"),"C",TamSx3("VV0_MODVEI")[1],60,"@!",.f.,,,,CLR_BLACK},;//Modelo"
{"COR"   ,RetTitle("VV0_DESCOR"),"C",TamSx3("VV0_DESCOR")[1],40,"@!",.f.,,,,CLR_BLACK},;//"Cor"
{"FABMOD",RetTitle("VV0_FABMOD"),"C",TamSx3("VV0_FABMOD")[1],TamSx3("VV0_FABMOD")[1],"@R 9999/9999",.f.,,,,CLR_BLACK},;//Fab/Mod
{"PLAVEI",RetTitle("VV0_PLAVEI"),"C",TamSx3("VV0_PLAVEI")[1],TamSx3("VV0_FABMOD")[1],"@!",.f.,,,,CLR_BLACK},;//Placa
{"TES"   ,RetTitle("VV0_CODTES"),"C",TamSx3("VV0_CODTES")[1],TamSx3("VV0_CODTES")[1],"@!",nOpc == 3,"VALTES015(get_TES)","SF4",,CLR_HRED}}//TES
If VVF->(FieldPos("VVF_PLIQUI")) > 0  
	aAdd(aFields,{"TRANSP",RetTitle("VVF_TRANSP"),"C",TamSx3("VVF_TRANSP")[1],TamSx3("VVF_TRANSP")[1],"@!",.t.,,"SA4",,CLR_BLACK})
	aAdd(aFields,{"PLIQUI",RetTitle("VVF_PLIQUI"),"N",TamSx3("VVF_PLIQUI")[1],30,"@E 999999.9999",.t.,"(val(get_pLIQUI) < 1000000)",,,CLR_BLACK})
	aAdd(aFields,{"PBRUTO",RetTitle("VVF_PBRUTO"),"N",TamSx3("VVF_PBRUTO")[1],30,"@E 999999.9999",.t.,"(val(get_PBRUTO) < 1000000)",,,CLR_BLACK})
endif


for cont := 1 to Len(aFields)
	&("o_"+aFields[cont,1]) := Nil
next

for cont := 1 to Len(aFields)
	if aFields[cont,3] == "C"
		&("get_"+aFields[cont,1]) := space(aFields[cont,4])
	Elseif aFields[cont,3] == "D"
		&("get_"+aFields[cont,1]) := ctod("")
	Else
		&("get_"+aFields[cont,1]) := 0
	Endif
next

EnchoiceTemp(oScroll, aFields)

get_CODCLI := VV0->VV0_CODCLI
get_LOJA   := VV0->VV0_LOJA
get_NOMCLI := SA1->A1_NOME
get_CHASSI := VV1->VV1_CHASSI
get_CHAINT := VV1->VV1_CHAINT
get_MARCA  := VE1->VE1_DESMAR
get_GRUPO  := VVR->VVR_DESCRI
get_MODELO := VV2->VV2_DESMOD
get_COR    := VVC->VVC_DESCRI
get_FABMOD := VV1->VV1_FABMOD
get_PLAVEI := VV1->VV1_PLAVEI
if nOpc <> 3
	dbSelectArea("VVG")
	dbSetOrder(1)
	if dbSeek(xFilial("VVG")+VV0->VV0_TRADEV)
		get_TES := VVG->VVG_CODTES
	Endif
Endif

for cont := 1 to Len(aFields)
	&("o_"+aFields[cont,1]):Refresh()
next

o_TES:SetFocus()

ACTIVATE MSDIALOG oDlgRet CENTER ON INIT EnchoiceBar(oDlgRet,{||nOpca := 1,Iif(VALID015(),oDlgRet:End(),.t.)},{||nOpca := 2,oDlgRet:End()})

if nOpca <> 1 .or. nOpc == 2
	Return .t.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltra 	  := "A2_FILIAL=='"+xFilial('SA2')+"' .And. A2_CONDO == '1'"
bFiltraBrw 	:= {|| FilBrowse("SA2",@aIndexVV0,@cCondicao) }
Eval(bFiltraBrw)

Return( .t. )


///////////////////
Function VALID015()

if lExclui .or. (Inclui .or. Altera)
	if !lExclui
		
		if Empty(cCodDes)
			MsgInfo(STR0060 ,STR0009) //E necessario informar o codigo do Destinatario... - Atencao!
			Return .f.
		Endif
		
		if Empty(get_TES)
			MsgInfo(STR0061 ,STR0009 ) //E necessario informar o Tipo de Entrada (TES)... - Atencao!
			Return .f.
		Endif
		
		FS_MEMORET()
		
		M->VVF_FORPRO := "0" // Nao
		cNumNota := Space(09)
		cSerNota := Space(03)
		nOpca_   := 0
		DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0062) FROM  02,04 TO 13,28 OF oMainWnd   //"Tipo de Inclusao"
		
		nCkPerg1 := 1
		@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
		OemToAnsi(STR0063), OemToAnsi(STR0064);//Formulario proprio/Formulario do cliente
		OF oDlgPerg PIXEL ON CHANGE (iif(nCkPerg1==2,(oScroll2:lVisible := .t.),(oScroll2:lVisible := .f.)))
		
		@ 028, 000 SCROLLBOX oScroll2 VERTICAL SIZE 40,100 OF oDlgPerg NOBORDER PIXEL
		
		@ 001, 005 SAY oEmissao VAR OemToAnsi(STR0065)  OF oScroll2 PIXEL //Emissao
		@ 001, 035 MSGET oDatEmi VAR dDatEmi PICTURE "@D" SIZE 40,4  OF oScroll2 PIXEL COLOR CLR_BLACK
		@ 014, 005 Say STR0066  OF oScroll2 PIXEL //Nota
		@ 014, 035 MSGET oNumNota VAR cNumNota PICTURE "999999999"  SIZE 45,4  OF oScroll2 PIXEL  COLOR CLR_BLACK
		@ 026, 005 Say STR0067 OF oScroll2 PIXEL //Serie
		@ 026, 035 MSGET oSerNota VAR cSerNota PICTURE "@!" SIZE 25,4  OF oScroll2 PIXEL  COLOR CLR_BLACK
		oScroll2:lVisible := .f.
		
		@ 071,005 BUTTON oOk  PROMPT OemToAnsi(STR0068) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpca_ := 1,oDlgPerg:End())	//Confirma
		@ 071,048 BUTTON oNo  PROMPT OemToAnsi(STR0069)  OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpca_ := 2,oDlgPerg:End())	//Cancela
		
		oOk:SetFocus()
		
		ACTIVATE MSDIALOG oDlgPerg CENTER
		
		if nOpca_ == 1
			
			if nCkPerg1 == 1
				
				M->VVF_FORPRO := "1" // Sim
				
				If FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
					return .f.
				Endif
				If FM_NRNFFP(2) // 2a Chamada da tela que verifica NF quando Formulario Proprio
					return .f.
				Endif
				
				cNumNota := cNota
				
			Else
				
				if !Empty(cNumNota)
					cNota  := cNumNota
					cSerie := cSerNota
				Else
					MsgInfo(STR0070 ,STR0009) //Informe a numeracao da NF... - Atencao!
					Return( .f. )
				Endif
				
			Endif
			
		Else
			
			Return( .f. )
			
		Endif
		
		// Executa a Devolucao do Veiculo
		Processa( {|| FS_INTDEV() } )
		
		// Destrava a Numneracao de Nota Fiscal
		//SX5->(MsRUnLock())
		
		// Ponto de Entrada Depois da Gravacao da Nota Fiscal de Retorno de Remessa
		If ExistBlock("VM015DNF")
			ExecBlock("VM015DNF",.f.,.f.)
		EndIf
	Else
		// Posicionar no VVF
		if MsgYesNo(OemToAnsi(STR0071),OemToAnsi(STR0072))  //Cancela Retorno de Remessa / Consignado... - Confirma!
			if VV1->VV1_SITVEI == "1" 
	           MsgInfo(STR0101,STR0102)
	           Return(.f.)
	        Endif   
			dbSelectArea("VVF")
			dbSetOrder(1)
			if DbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
				Processa( {|| FS_CANCDEV() } )
			Endif
		Else
			Return .f.
		Endif
	Endif
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CANCDEV³ Autor ³  Andre                ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancela Devolucao                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCDEV()

Private lMsErroAuto := .f.
Private lMsHelpAuto := .f.

aHeader := NIL
aCols   := NIL

// Posiciona Arquivos na Ordem Principal
dbSelectArea("SX3")
dbSetOrder(1)

dbSelectArea("VVF")
dbSetOrder(1)

dbSelectArea("VVG")
dbSetOrder(1)

// Zera Variaveis fiscais
MaFisEnd()

Begin Transaction
FS_CANRTRM()
End Transaction

if lMsErroAuto
	MostraErro()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VALTES015 ³ Autor ³  Andre                ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do TES digitado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VALTES015(cTes)

Local lRet := .t.

if Val(cTes) > 500
	MsgInfo(OemtoAnsi(STR0024),OemtoAnsi(STR0009))
	lRet := .f.
Endif

if SF4->(DbSeek(xFilial("SF4")+cTes)) .and. lRet
	// Manoel - 01/03/2005
	cEstoque := SF4->F4_ESTOQUE
	nRecSF4  := SF4->(recno())
	
	SF4->(DbSeek(xFilial("SF4")+VVA->VVA_CODTES))
	If cEstoque == "S" .and. SF4->F4_ESTOQUE == "N"
		MsgInfo(STR0073 ,STR0009) //A SAIDA deste veiculo utilizou TES que NAO MOVIMENTA ESTOQUE! Nao pode ser devolvido com TES que MOVIMENTA ESTOQUE! - ATENCAO!
		lRet := .f.
	ElseIf cEstoque == "N" .and. SF4->F4_ESTOQUE == "S"
		MsgInfo(STR0074 ,STR0009) //A SAIDA deste veiculo utilizou TES que MOVIMENTA ESTOQUE! Nao pode ser devolvido com TES que NAO MOVIMENTA ESTOQUE! - ATENCAO!
		lRet := .f.
	Endif
	
	SF4->(DbGoTo(nRecSF4))
	/*
	if SF4->F4_PODER3 <> "D" //Devolucao
	MsgInfo("O TES tem que controlar poder de terceiro na DEVOLUCAO!","Atencao!")
	lRet := .f.
	Endif
	*/
Else
	if lRet
		MsgInfo(STR0075 ,STR0009) //TES informado nao encontrado... - Atencao!
		lRet := .f.
	Endif
Endif

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_INTDEV³ Autor ³  Andre                ³ Data ³ 23/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Entrada de Veiculos (por Devolucao)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INTDEV(cAlias,nReg,nOpc)

Local cClaFis
Local bCampo   := { |nCPO| Field(nCPO) }
Local _ni,nCntFor := 0
Local cItemOri := ""

ProcRegua(3)
IncProc(OemtoAnsi(STR0076)) //Gerando Nota Fiscal de Retorno de Remessa / Consignado ...

dbSelectArea("SD2")
dbSetOrder(3)
cIdeSB6 := space(6)
if dbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	cIdeSB6 := SD2->D2_IDENTB6
Endif

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VV1                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea("VV1")
DbsetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)

if VV1->VV1_ESTVEI == "0" //Veiculo Novo
	cAlmVei := GetMv("MV_LOCVEIN")
Else
	cAlmVei := GetMv("MV_LOCVEIU")
Endif
__nRecno := SA1->(RecNo())
dbSelectArea("VV1")
RecLock("VV1",.f.)
VV1->VV1_SITVEI := "0"  // Em Estoque
FG_Seek("SA1","SM0->M0_CGC",3,.f.)
cConces := SA1->A1_COD
FG_Seek("VE4","VV1->VV1_CODMAR")
cCodFab := VE4->VE4_CODFAB+VE4->VE4_LOJA
FG_Seek("SA1","cCodFab",1,.f.)
cNomFab := SA1->A1_NREDUZ
dbSelectArea("VV1")
VV1->VV1_NOMANT := SA1->A1_NOME
VV1->VV1_ENDANT := SA1->A1_END
If lA1_IBGE
	FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
	VV1->VV1_CIDANT := VAM->VAM_DESCID
	VV1->VV1_ESTANT := VAM->VAM_ESTADO
Else
	VV1->VV1_CIDANT := SA1->A1_MUN
	VV1->VV1_ESTANT := SA1->A1_EST
EndIf
VV1->VV1_CEPANT := SA1->A1_CEP
VV1->VV1_DOCIND := SA1->A1_CGC
//VV1->VV1_LOCPAD := cAlmVei
MsUnlock()
SA1->(dbgoto(__nRecno))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VVF                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->VVF_TRACPA := GetSxENum("VVF","VVF_TRACPA")

cCodFor := VV0->VV0_CODCLI
cLoja   := VV0->VV0_LOJA

If !MaFisFound('NF')
	If !Empty(cLoja)
		MaFisIni(cCodFor,cLoja,'F','N','R',MaFisRelImp("VEIVM015",{"VVF","VVG"}))
	EndIf
EndIf

n:=1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVG")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVG")
	if ( X3USO(x3_usado).And.cNivel>=x3_nivel )
		nUsado:=nUsado+1
		aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aCols da GetDados                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
	aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
SB1->(dbSetOrder(1))

//MaFisRef("IT_PRODUTO","VVG00",VV1->VV1_CHAINT)
MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)              // FNC - 28020/2010 - BOBY - 14/12/10
                                                        // Trocado VV1_CHAINT pelo B1_COD, pois a referencia do
MaFisRef("IT_TES","VVG00",get_TES)                     // imposto e feito pelo B1_COD.
MaFisRef("IT_VALMERC","VVG00",VV0->VV0_VALMOV)

MaFisRef("IT_BASEICM","VVG00",VV0->VV0_VBAICM)
MaFisRef("IT_ALIQICM","VVG00",VV0->VV0_ALIICM)

nBaseIcm := MaFisRet(1,"IT_BASEICM")
nAliqIcm := MaFisRet(1,"IT_ALIQICM")
nValoIcm := MaFisRet(1,"IT_VALICM")

nBaseIpi := MaFisRet(1,"IT_BASEIPI")
nAliqIpi := MaFisRet(1,"IT_ALIQIPI")
nValoIpi := MaFisRet(1,"IT_VALIPI")

cTraCpa  := GetSxENum("VVF","VVF_TRACPA")

dDataTmp := dDataBase
if M->VVF_FORPRO == "0"  //Nao
	dDataTmp := dDatemi
Endif

DbSelectArea("VVF")
RecLock("VVF",.t.)
VVF->VVF_FILIAL := xFilial("VVF")
FG_GRAVAR("VVF")
VVF->VVF_SITNFI := "1"  //Valida
VVF->VVF_NUMPED := ""
VVF->VVF_OPEMOV := iif(VV0->VV0_OPEMOV=="3","7","8")  //Devolucao
VVF->VVF_QTDVEI := 1
VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
VVF->VVF_NUMTRA := VV0->VV0_NUMTRA
VVF->VVF_FORPRO := M->VVF_FORPRO
VVF->VVF_TRACPA := cTraCpa
VVF->VVF_DATMOV := dDataBase
VVF->VVF_DATFAB := dDataTmp
VVF->VVF_DATEMI := dDataTmp
VVF->VVF_CODFOR := VV0->VV0_CODCLI
VVF->VVF_LOJA   := VV0->VV0_LOJA
VVF->VVF_NUMNFI := cNota
VVF->VVF_SERNFI := cSerie
If VVF->(FieldPos("VVF_PLIQUI")) > 0  
	VVF->VVF_TRANSP := get_TRANSP
	VVF->VVF_PLIQUI := Val(get_PLIQUI)
	VVF->VVF_PBRUTO := val(get_PBRUTO)
endif
VVF->VVF_FORPAG := RetCondVei()
VVF->VVF_VALMOV := VV0->VV0_VALMOV
VVF->VVF_QTDVEI := 1
VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
VVF->VVF_NUMTRA := VV0->VV0_NUMTRA
VVF->VVF_CONFRE := 0
VVF->VVF_TOTFRE := 0
VVF->VVF_TOTSEG := 0
VVF->VVF_ICMRET := 0
//ICM
VVF->VVF_VBAICM := nBaseIcm
VVF->VVF_ALIICM := nAliqIcm
VVF->VVF_TOTICM := nValoIcm
//IPI
VVF->VVF_VBAIPI := nBaseIpi
VVF->VVF_ALIIPI := nAliqIpi
VVF->VVF_VALIPI := nValoIpi
MSMM(,TamSx3("VVF_OBSERV")[1],,cObserv,1,,,"VVF","VVF_OBSMEM")
ConfirmSx8("VVF")
MsUnlock()
nSvRecF := recno()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VVG                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea("VVG")
RecLock("VVG",.t.)
VVG->VVG_FILIAL := xFilial("VVG")
VVG->VVG_TRACPA := VVF->VVF_TRACPA
VVG->VVG_CHAINT := VV1->VV1_CHAINT
VVG->VVG_CHASSI := VV1->VV1_CHASSI
VVG->VVG_CODTES := get_TES
VVG->VVG_REDCUS := VVA->VVA_REDCUS
VVG->VVG_VCNVEI := 0
VVG->VVG_SEGVIA := 0
VVG->VVG_VALASS := 0
VVG->VVG_VALREV := 0
VVG->VVG_VALFRE := 0
VVG->VVG_ASSIMP := VVA->VVA_ASSIMP
VVG->VVG_ESTVEI := VVA->VVA_ESTVEI
VVG->VVG_CODIND := VVA->VVA_CODIND
VVG->VVG_CODORI := VVA->VVA_CODORI
VVG->VVG_VALUNI := VVA->VVA_VALVDA
VVG->VVG_LOCPAD := cAlmVei
//ICM
VVG->VVG_VBAICM := nBaseIcm
VVG->VVG_ALIICM := nAliqIcm
VVG->VVG_ICMCOM := nValoIcm
//IPI
VVG->VVG_VBAIPI := nBaseIpi
VVG->VVG_ALIIPI := nAliqIpi
VVG->VVG_VALIPI := nValoIpi
MsUnlock()

nSvRecG := recno()

//Posicionamento p/ calcular o Custo do Veiculo
VV1->(DbsetOrder(1))
VV1->(dbSeek(xFilial("VV1")+VVG->VVG_CHAINT))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))

VVF->(dbSetOrder(1))
VVF->(dbSeek(xFilial("VVF")+VV1->VV1_TRACPA ))
VVG->(dbSetOrder(1))
VVG->(dbSeek(xFilial("VVG")+VVF->VVF_TRACPA+VV1->VV1_CHAINT ))

dbSelectArea("VVF")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("VVG")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

nValFre := VVG->VVG_VALFRE

nCustoVeiculo := 0
cArqPes := "VVG"
if VVG->VVG_ESTVEI == "0" //Novo
	DbSelectArea("VVG")
	If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
		nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
	ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
		nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
	Endif
Else
	cFor := GetMv("MV_VUCCTB")
	if !Empty(cFor)
		nCustoVeiculo := FG_FORMULA(cFor)
	Endif
Endif
if nCustoVeiculo <= 0
	nCustoVeiculo := VVG->VVG_VALUNI
Endif

dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
		if VVD->VVD_ATUCUS=="1"
			nCustoVeiculo += VVD->VVD_VALOR
		Endif
		dbSelectArea("VVD")
		dbSkip()
	Enddo
Endif

VVF->(DbGoTo(nSvRecF))
VVG->(DbGoTo(nSvRecG))

dbSelectArea("VVF")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("VVG")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Arquivo de Produtos < SB1 >                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
SB1->(dbSetOrder(1))

// Posiciona no TES de Retorno
SF4->(DbGoTop())
SF4->(DbSeek(xFilial("SF4")+VVG->VVG_CODTES))

//Pega a classificacao fiscal de acordo com o estado do cliente
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+cCodDes+cLojDes))

cClaFis := FG_CLAFIS(VVG->VVG_CODTES)

cItemOri := FM_SQL("SELECT D2_ITEM " + ; 
					" FROM " + RetSQLName("SD2") + " SD2 "    + ;
					" WHERE D2_FILIAL  = '" + xFilial("SD2")  + "'" + ;
					" AND   D2_DOC     = '" + VV0->VV0_NUMNFI + "'" + ;
					" AND   D2_SERIE   = '" + VV0->VV0_SERNFI + "'" + ;
					" AND   D2_CLIENTE = '" + cCodDes + "'"   + ;
					" AND   D2_LOJA    = '" + cLojDes + "'"   + ;
					" AND   D_E_L_E_T_ = ' '")

IncProc(OemtoAnsi(STR0077)) //Gerando Arquivo de Entrada...

// Cria Vetor de Itens para o MATA100 (Nota Fiscal de Entrada)
aIteTempNFE := {}
aCabNfe     := {}              

aAdd(aIteTempNFE,{"D1_ITEM"    ,"01",Nil})
//aAdd(aIteTempNFE,{"D1_DOC"     ,cNota,Nil})
//aAdd(aIteTempNFE,{"D1_SERIE"   ,cSerie,Nil})
aAdd(aIteTempNFE,{"D1_COD"     ,SB1->B1_COD,Nil})
aAdd(aIteTempNFE,{"D1_UM"      ,"UN",Nil})
aAdd(aIteTempNFE,{"D1_QUANT"   ,1,Nil})
aAdd(aIteTempNFE,{"D1_VUNIT"   ,VVG->VVG_VALUNI,Nil})
aAdd(aIteTempNFE,{"D1_TOTAL"   ,VVG->VVG_VALUNI,Nil})
aAdd(aIteTempNFE,{"D1_VALIPI"  ,nValoIpi,Nil})
aAdd(aIteTempNFE,{"D1_PICM"    ,VVG->VVG_ALIICM,Nil})
aAdd(aIteTempNFE,{"D1_VALICM"  ,nValoIcm,Nil})
aAdd(aIteTempNFE,{"D1_BASEIPI" ,nBaseIpi,Nil})
aAdd(aIteTempNFE,{"D1_BASEICM" ,nBaseIcm,Nil})
aAdd(aIteTempNFE,{"D1_CUSTO"   ,nCustoVeiculo  ,Nil})
aAdd(aIteTempNFE,{"D1_TES"     ,get_TES,Nil})
aAdd(aIteTempNFE,{"D1_CF"      ,cClaFis,Nil})
aAdd(aIteTempNFE,{"D1_CC"      ,VVG->VVG_CENCUS,Nil})
aAdd(aIteTempNFE,{"D1_LOCAL"   ,cAlmVei,Nil})
//aAdd(aIteTempNFE,{"D1_LOCPAD"  ,cAlmVei,Nil})
aAdd(aIteTempNFE,{"D1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
aAdd(aIteTempNFE,{"D1_DTDIGIT" ,VVF->VVF_DATMOV,Nil})
aAdd(aIteTempNFE,{"D1_NFORI"   ,VV0->VV0_NUMNFI,Nil})
aAdd(aIteTempNFE,{"D1_SERIORI" ,VV0->VV0_SERNFI,Nil})
aAdd(aIteTempNFE,{"D1_ITEMORI" ,cItemOri,Nil})
if SF4->F4_PODER3 == "D"
	dbSelectArea("SB6")
	dbSetOrder(3)
	if dbSeek(xFilial("SB6")+cIdeSB6+SB1->B1_COD)
		aAdd(aIteTempNFE,{"D1_IDENTB6" ,SB6->B6_IDENT,Nil})
	Endif
	dbSelectArea("VVG")
Endif

if VVF->VVF_FORPRO == "0" // Formulario Proprio = Nao
	cFormul := "N"
Else
	cFormul := "S"
Endif

nTotal := VVG->VVG_VALUNI

//SA2->(DbSetOrder(1))
//SA2->(DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA))
SA1->(dbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA))

aAdd(aCabNFE,{"F1_TIPO"    ,"D"            ,Nil})
aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
//aAdd(aCabNFE,{"F1_ESPECIE" ,"NF"           ,Nil})
aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
aAdd(aCabNFE,{"F1_DOC"     ,cNota          ,Nil})
aAdd(aCabNFE,{"F1_SERIE"   ,cSerie         ,Nil})
aAdd(aCabNFE,{"F1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
aAdd(aCabNFE,{"F1_DTDIGIT" ,VVF->VVF_DATMOV,Nil})
aAdd(aCabNFE,{"F1_RECBMTO" ,VVF->VVF_DATMOV,Nil})
aAdd(aCabNFE,{"F1_FORNECE" ,cCodDes        ,Nil})
aAdd(aCabNFE,{"F1_LOJA   " ,cLojDes        ,Nil})
aAdd(aCabNFE,{"F1_COND"    ,VVF->VVF_FORPAG,Nil})
aAdd(aCabNFE,{"F1_ICMSRET" ,VVF->VVF_ICMRET,Nil})
aAdd(aCabNFE,{"F1_VALMERC" ,nTotal         ,Nil})
aAdd(aCabNFE,{"F1_VALBRUT" ,nTotal         ,Nil})
aAdd(aCabNFE,{"F1_BASEICM" ,VVF->VVF_VBAICM,Nil})
aAdd(aCabNFE,{"F1_VALICM"  ,VVF->VVF_TOTICM,Nil})
aAdd(aCabNFE,{"F1_EST"     ,SA1->A1_EST    ,Nil})

If VVF->(FieldPos("VVF_PLIQUI")) > 0  
	aAdd(aCabNFE,{"F1_PLIQUI"		,VVF->VVF_PLIQUI   ,Nil})
	aAdd(aCabNFE,{"F1_PBRUTO"		,VVF->VVF_PBRUTO   ,Nil})
endif

//aAdd(aCabNFE,{"F1_PLIQUI"  ,VV1->VV1_PESLIQ,Nil})  // FNC 17972/BOBY/23/08/10 - PESO LIQUIDO DO CAD VEICULOS
//aAdd(aCabNFE,{"F1_PBRUTO"  ,VV1->VV1_PESBRU,Nil})  //                           PESO BRUTO DO CAD VEICULOS

//Chamada do MATA103 (Nota Fiscal de Entrada)
lMsHelpAuto := .t.
lMsErroAuto := .f.

lInclui := inclui
inclui  := .t.
nAnt    := MAFISSAVE()
MAFISEND()
MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,{aIteTempNFE},3)
MAFISRESTORE(nAnt)
inclui := lInclui

if lMsErroAuto
	DisarmTransaction()
	Break
Endif
//      
//
RecLock("VVF",.f.)
VVF->VVF_NUMNFI := SF1->F1_DOC
VVF->VVF_SERNFI := SF1->F1_SERIE
MsUnlock()

DbSelectarea("SF1")
DbSetOrder(1)
if DbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
	RecLock("SF1",.f.)
	SF1->F1_VALMERC := nTotal
	SF1->F1_VALBRUT := nTotal
	MsUnlock()
Endif

//Regrava o custo do Veiculo
dbSelectArea("VVG")
RecLock("VVG",.f.)
VVG->VVG_VCNVEI := nCustoVeiculo
VVG->VVG_VALFRE := nValFre
MsUnlock()

//dbSelectArea("SB1")
//dbSetOrder(7)
//dbSeek(xFilial("SB1")+GetMv("MV_GRUVEI")+VVG->VVG_CHAINT)

FM_LOCVZL(1)

dbSelectArea("SB2")
dbSetOrder(1)
if dbSeek(xFilial("SB2")+SB1->B1_COD)
	RecLock("SB2",.f.)
	If SB2->B2_QATU > 0
		//Custo
		SB2->B2_CM1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
		SB2->B2_CM2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
		SB2->B2_CM3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
		SB2->B2_CM4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
		SB2->B2_CM5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
		//Valor
		SB2->B2_VATU1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
		SB2->B2_VATU2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
		SB2->B2_VATU3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
		SB2->B2_VATU4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
		SB2->B2_VATU5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	Else
		//Custo
		SB2->B2_CM1 := 0
		SB2->B2_CM2 := 0
		SB2->B2_CM3 := 0
		SB2->B2_CM4 := 0
		SB2->B2_CM5 := 0
		//Valor
		SB2->B2_VATU1 := 0
		SB2->B2_VATU2 := 0
		SB2->B2_VATU3 := 0
		SB2->B2_VATU4 := 0
		SB2->B2_VATU5 := 0
	Endif
	MsUnlock()
Endif

dbSelectarea("SD1")
dbSetOrder(1)
if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+VVG->VVG_CHAINT)
	RecLock("SD1",.f.)
	SD1->D1_CUSTO  := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SD1->D1_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SD1->D1_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SD1->D1_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SD1->D1_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif

dbSelectArea("SB6")
dbSetOrder(3)
if dbSeek(xFilial("SB6")+SD1->D1_IDENTB6+VVG->VVG_CHAINT+space(9))
	RecLock("SB6",.f.)
	SB6->B6_CUSTO1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SB6->B6_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SB6->B6_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SB6->B6_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SB6->B6_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VV0                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Marca Nota de Saida como devolvida
dbSelectArea("VV0")
dbSetOrder(1)
if dbSeek(xFilial("VV0")+cCodVV0)
	RecLock("VV0",.f.)
	VV0->VV0_SITNFI := "2" && Devolucao
	VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
	VV0->VV0_TRADEV := VVF->VVF_TRACPA
	MsUnlock()
Endif

End Transaction
//     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

FGX_AMOVVEI(xFilial("VV1"),VVG->VVG_CHASSI)
//
if !lMsErroAuto
	if VVF->VVF_FORPRO == "1" // Formulario Proprio
		if ExistBlock("NFENTVEI")
			IncProc(OemtoAnsi(STR0078))//Imprimindo Nota Fiscal...
			dbSelectArea("VV0")
			ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_CODFOR,VVF->VVF_LOJA})
		Endif
	Endif
Else
	MostraErro()
Endif

Return( .t. )


//////////////////////////////
Static Function FS_VALCLI(nOp)

Local lRet := .t.

DbSelectArea("SA1")
DbSetOrder(1)
if nOp == 1
	if DbSeek(xFilial("SA1")+cCodDes)
		cNomDes := SA1->A1_NOME
	Else
		MsgInfo(STR0079 ,STR0009) // Destinatario nao Cadastrado... - Atencao!
		lRet := .f.
	Endif
Else
	if DbSeek(xFilial("SA1")+cCodDes+cLojDes)
		cNomDes := SA1->A1_NOME
	Else
		MsgInfo(STR0079 ,STR0009) //Destinatario nao Cadastrado... - Atencao!
		lRet := .f.
	Endif
Endif

Return(lRet)


//////////////////////
Function FS_IMPRESSR()
Local lEstErro := lMsHelpAuto
nOpc1   := 0
DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0080) FROM  02,04 TO 8,28 OF oMainWnd   //Tipo de Inclusao

nCkPerg1 := 1
@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
OemToAnsi(STR0081), OemToAnsi(STR0082); //NF de Saida - NF de Retorno
OF oDlgPerg PIXEL

@ 028,005 BUTTON oOk  PROMPT OemToAnsi(STR0068) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpc1 := 1,oDlgPerg:End())//confirma
@ 028,048 BUTTON oNo  PROMPT OemToAnsi(STR0069)  OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpc1 := 2,oDlgPerg:End())//cancela

oOk:SetFocus()

ACTIVATE MSDIALOG oDlgPerg CENTER
lMsHelpAuto := .f.
if nOpc1 == 1
	if nCkPerg1 == 1
		If ExistBlock("NFSAIVEI")
			dbSelectArea("SF2")
			dbSetOrder(1)
			if dbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
				ExecBlock("NFSAIVEI",.f.,.f.,{SF2->F2_DOC,SF2->F2_SERIE,"SN"}) // SN - NF Saida (Normal)
			Endif
		else
			Help(1," ","NOWINDOWS",,STR0099,4,1)  //O Nome do RDMAKE padrao eh NFSAIVEI
		Endif
	Else
		If ExistBlock("NFENTVEI")
			dbSelectArea("VVF")
			dbSetOrder(1)
			if dbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
				ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF_CODFOR,VVF_LOJA})
			Endif
		else
			Help(1," ","NOWINDOWS",,STR0100,4,1)  //O Nome do RDMAKE padrao eh NFENTVEI
		Endif
	Endif
Endif
lMsHelpAuto := lEstErro
Return


////////////////////
Function FS_PESQ15()

//axPesqui()// Boby - 19/10/10 - Fnc 23161/2010 - Quando a função FilBrowse for utilizada   
PesqBrw()   //                   a função de pesquisa devera ser a PesqBrw ao invés da AxPesqui
dbSelectArea("VV0")
//dbSetOrder(nIndex+1)

Return


/////////////////////
Function FS_MEMORET()

cObserv := ""

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0083) FROM  02,04 TO 14,56 OF oMainWnd //Observacao

DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1

@ 03,013 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
oObserv:bRClicked := {|| AllwaysTrue() }
oObserv:SetFocus()

ACTIVATE MSDIALOG oDlg1 CENTER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CANRTRM³ Autor ³ Andre                 ³ Data ³ 10/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancela Nota Fiscal de Retorno de Remessa                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANRTRM()

Local nSavReg, nRecSE2
Local bCampo  := { |nCPO| Field(nCPO) }
Local nRecVVG := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura a IndRegua para mostrar a barra de progresso³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(3)

if VVF->VVF_OPEMOV $ "7/8" //Retorno de Remessa / Consignacao
	
	dbSelectArea("VVG")
	dbSetOrder(1)
	if !dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		DisarmTransaction()
		Break
	Endif
	
	if VVF->VVF_SITNFI == "1"
		
		dbSelectArea("SD1")
		dbSetOrder(1)
		cIdeSB6 := space(6)
		if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			cIdeSB6 := SD1->D1_IDENTB6
		Endif
		
		FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
		
		VV1->(dbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1")+VVG->VVG_CHAINT))
		
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
		SB1->(dbSetOrder(1))
		
		FG_Seek("SF4","VVG->VVG_CODTES",1,.f.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Significa que o veiculo nao esta mais no estoque      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if VV1->VV1_SITVEI <> "0" //Estoque
			If SF4->F4_ESTOQUE == "S"
				DisarmTransaction()
				Break
			Endif
		Endif
		
		aCabNFE   := {}
		aIte      := {}
		
		dbSelectArea("VVG")
		
		nRecVVG := VVG->(Recno())
		ix_:=1
		While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
			aItensNFR := {}
			aAdd(aItensNFR,{"D1_DOC"     ,VVF->VVF_NUMNFI,Nil})
			aAdd(aItensNFR,{"D1_SERIE"   ,VVF->VVF_SERNFI,Nil})
			aAdd(aItensNFR,{"D1_FORNECE" ,VVF->VVF_CODFOR,Nil})
			aAdd(aItensNFR,{"D1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
			aAdd(aItensNFR,{"D1_COD"     ,SB1->B1_COD    ,Nil})
			aAdd(aItensNFR,{"D1_ITEM"    ,strzero(ix_,2) ,Nil})
			aAdd(aItensNFR,{"D1_IDENTB6" ,cIdeSB6        ,Nil})
			aAdd(aIte,aclone(aItensNFR))
			dbSkip()
			ix_++
		Enddo
		VVG->(dbGoTo(nRecVVG))

		cFormul := "N"
		
		aAdd(aCabNFE,{"F1_TIPO"    ,"D"            ,Nil})
		aAdd(aCabNFE,{"F1_DOC"     ,VVF->VVF_NUMNFI,Nil})
		aAdd(aCabNFE,{"F1_SERIE"   ,VVF->VVF_SERNFI,Nil})
		aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
		aAdd(aCabNFE,{"F1_LOJA"    ,VVF->VVF_LOJA  ,Nil})
		aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
		aAdd(aCabNFE,{"F1_COND"    ,RetCondVei()   ,Nil})
		aAdd(aCabNFE,{"F1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
		aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
		aAdd(aCabNFE,{"F1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
		aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
		//		aAdd(aCabNFE,{"F1_ESPECIE" ,"NF"           ,Nil})
//		aAdd(aCabNFE,{"F1_PLIQUI"  ,VV1->VV1_PESLIQ,Nil}) // FNC 17972/BOBY/23/08/10 - PESO LIQUIDO DO CAD VEICULOS
//		aAdd(aCabNFE,{"F1_PBRUTO"  ,VV1->VV1_PESBRU,Nil}) //                           PESO BRUTO DO CAD VEICULOS
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			cParDup := SF4->F4_DUPLIC
			RecLock("SF4",.f.)
			SF4->F4_DUPLIC := "N"
			MsUnlock()
		Endif
		
		MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIte,5)
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			RecLock("SF4",.f.)
			SF4->F4_DUPLIC := cParDup
			MsUnlock()
		Endif
		
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SD1->D1_COD)

		FM_LOCVZL(2)
		
		dbSelectArea("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_SITNFI := "0" //Cancelada
		VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
		
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui Cabecalho da Nota de Retorno                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VVF")
		RecLock("VVF",.f.,.t.)
		dbDelete()
		MsUnlock()
		WriteSx2("VVF")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui Item da Nota de Retorno                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VVG")
		RecLock("VVG",.f.,.t.)
		dbDelete()
		MsUnlock()
		WriteSx2("VVG")
		*/
		
		dbSelectArea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "1" //Valida
		VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		VV0->VV0_TRADEV := ""
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VVF->(dbGoTo(VVF->(Recno())))
		VVG->(dbGoTo(VVG->(Recno())))
		
		FGX_AMOVVEI(xFilial("VV1"),VVG->VVG_CHASSI)		

	Endif
	
Endif

Return

Static Function MenuDef()
Local aRotina   := {{ OemtoAnsi(STR0003) ,"FS_PESQ15", 0 , 1},;       		// Pesquisar
					{ OemtoAnsi(STR0001) ,"FS_RTREMES", 0 , 2},;    		// Vizualizar
					{ OemtoAnsi(STR0084) ,"FS_RTREMES", 0 , 4},;    		// Retorno
					{ OemtoAnsi(STR0004) ,"FS_RTREMES", 0 , 5},;    		// Cancelar
					{ OemtoAnsi(STR0080) ,"FS_IMPRESSR",0 , 4},;    		// Impressao
					{ OemtoAnsi(STR0085) ,"FS_LEGEN015",0 , 2, 1,.f.},;  	// Legenda
					{           STR0086  ,"VM015_LVEI" , 0 , 2}}			//Pesquisa Chassi

Return aRotina

Function FS_LEGEN015()

Local aLegenda := {{'BR_VERDE'   ,STR0087},;	//Remessa
					{'BR_AMARELO' ,STR0088},;	//Consignado
					{'BR_PRETO'   ,STR0089},;	//Rems. ja retornado
					{'BR_VERMELHO',STR0090}}	//Cons. ja retornado

BrwLegenda(cCadastro,STR0085 ,aLegenda)        //Legenda

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM015_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM015_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private overd := LoadBitmap( GetResources() , "BR_VERDE" )
Private overm := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private opret := LoadBitmap( GetResources() , "BR_PRETO" )
Private oamar := LoadBitmap( GetResources() , "BR_AMARELO" )
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
EndDo
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0091) FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
@ 003,004 SAY STR0092 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE//Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0093) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0094),;//Filial
OemToAnsi(STR0095),;//Dt.Movimento
OemToAnsi(STR0096),;//Nro. NFiscal
OemToAnsi(STR0097),;//Vlr Venda
OemToAnsi(STR0059);//Cliente
COLSIZES 10,35,35,29,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="31",overd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="51",oamar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="32",opret,overm))),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VV0")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	dbSetOrder(1)//NUMTRA
	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local lOk := .t.
Local cQuery := ""
Local cQAlVV0 := "SQLVV0"
Local cFilLibs := ""
Local nNUMPED := len(VV0->VV0_NUMPED)
Local nNUMNFI := len(VV0->VV0_NUMNFI)
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_OPEMOV , VV0.VV0_SITNFI , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
	cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VV0.VV0_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VV0.VV0_NUMPED<>'"+ space(nNUMPED)+"' AND VV0.VV0_SITNFI IN ('1','2') AND VV0.VV0_NUMNFI<>'"+ space(nNUMNFI) + "' AND VV0.VV0_TIPFAT<>'2' AND VV0.VV0_OPEMOV IN ('3','5') AND "
	cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
	Do While !( cQAlVV0 )->( Eof() )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
		If nEmpAtu > 0
			cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
		EndIf
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_OPEMOV )+( cQAlVV0 )->( VV0_SITNFI ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+( cQAlVV0 )->( VV0_SERNFI ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0098 + cLevChas,STR0009) //Nenhuma Remessa / Consignado Encontrado para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="31",overd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="51",oamar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="32",opret,overm))),;
	aLevPesq[oLbLevPesq:nAt,03],;
	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	aLevPesq[oLbLevPesq:nAt,05],;
	FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	If !lOk
		oLevChas:SetFocus()
	EndIf
EndIf
Return
