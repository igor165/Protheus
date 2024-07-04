#INCLUDE "VEIVM019.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM019 ³ Autor ³  Manoel               ³ Data ³ 15/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reavaliacao da Venda de Veiculos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIVM019
Local aCores :=	{{'(VV0->VV0_TIPFAT # "2" .and. VV0->VV0_OPEMOV == "0" .and. !empty(VV0->VV0_NUMNFI) .and.'+;
							' VV0->VV0_SITNFI == "1" .and. VV0->VV0_AUTFAT == "1") .or. (VV0->VV0_TIPFAT == "2" .and.'+;
							' VV0->VV0_OPEMOV == "0" .and. VV0->VV0_SITNFI == "1" .and. VV0->VV0_AUTFAT == "1")','BR_VERDE'},;
						 {'VV0->VV0_OPEMOV $ "01"','BR_VERMELHO'}}

Private cTipAva := "01"
Private aErrAva := {}        
Private cParPrg := "3"
Private cTipFat := "0"
Private cTipSai := "0"
DEFINE FONT oFnt1 NAME "Arial" SIZE 08,14 BOLD
DEFINE FONT oFnt2 NAME "Arial" SIZE 08,15 BOLD
DEFINE FONT oFnt3 NAME "Arial" SIZE 08,13 BOLD
DEFINE FONT oFnt4 NAME "Arial" BOLD
DEFINE FONT oFnt5 NAME "Times New Roman" SIZE 10,18 BOLD
DEFINE FONT oFnt6 NAME "Times New Roman" SIZE 07,17 BOLD
DEFINE FONT oFnt7 NAME "Times New Roman" SIZE 07,13 BOLD
Private cCpoDiv  := "    1"
Private aStru    := {}
Private aStruLb  := {}
Private aIteDesp := {}
Private aIteRece := {}
Private cSimVda  := "V"
Private cMoedCor := cOutMoed := GetMv("MV_SIMB1")
Private cCadastro  := OemToAnsi(STR0003) //"Reavaliacao da Venda de Veiculos"
Private aRotina := MenuDef()

dbSelectArea("VV0")
dbSetOrder(1)

mBrowse( 6, 1,22,75,"VV0",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_AltVm019³ Autor ³  Manoel               ³ Data ³ 15/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reavaliacao da Venda de Veiculos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FS_AltVm019(cAlias,nReg,nOpc)
Local cCondicao :='(VV0->VV0_TIPFAT # "2" .and. VV0->VV0_OPEMOV == "0" .and. !empty(VV0->VV0_NUMNFI) .and. VV0->VV0_SITNFI == "1" .and. VV0->VV0_AUTFAT == "1") .or. (VV0->VV0_TIPFAT == "2" .and. VV0->VV0_OPEMOV == "0" .and. VV0->VV0_SITNFI == "1" .and. VV0->VV0_AUTFAT == "1")'
Local _ni := 0

If !&(cCondicao)
	Help(" ",1,"DOCINVALID")
	Return
EndIf

aRotina := {  {"","" , 0 , 1},;   	 //Pesquisar
					{"","", 0 , 2},; //Consultar
					{"","", 0 , 3},; //Incluir
					{"","", 0 , 4},; //Alterar
					{"","", 0 , 5} } //Excluir
						
						
if nOpc == 1
   nOpcE := 2
   nOpcG := 2
Elseif nOpc == 2
   nOpcE := 4
   nOpcG := 4
Else
   nOpcE := ""
   nOpcG := ""
Endif					

dbSelectArea("SX3")
dbSeek("VV0")
acpoEncS := {}
While !Eof().and.(x3_arquivo=="VV0")
   if Alltrim(x3_campo) $ "VV0_CHASSI#VV0_DATMOV#VV0_VALMOV#VV0_NUMNFI#VV0_SERNFI#VV0_CODVEN#VV0_CODCLI#VV0_LOJA#VV0_NOMCLI#VV0_FORPAG#VV0_DESFPG"
	   AADD(acpoEncS,x3_campo)
	Endif   
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

RegToMemory("VV0",.f.)
DbSelectArea("VV0")

Inclui := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e acols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VVA")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVA")                           
   if Alltrim(x3_campo) $ "VVA_RECTEC#VVA_BONFAB#VVA_DESCLI#VVA_VALREV#VVA_INPCRT#VVA_INISRT#VVA_INPCBF#VVA_INISBF#VVA_PISRTE#VVA_PISBFB#VVA_ISSRTE#VVA_ISSBFB#VVA_DATDCL#VVA_DATBFB#VVA_DATRTC"
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
	        x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif                                 
	if VV0->VV0_TIPFAT == "2"
	   if Alltrim(x3_campo) $ "VVA_VALCVD#VVA_VALFRE"
	      nUsado:=nUsado+1
	      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		        x3_tamanho, x3_decimal,x3_valid,;
	           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		Endif   
	Else	
	   if Alltrim(x3_campo) $ "VVA_REDCUS#VVA_DATRCU"
	      nUsado:=nUsado+1
	      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		        x3_tamanho, x3_decimal,x3_valid,;
	           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		Endif   
	Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
End

acols:={}
dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial()+M->VV0_NUMTRA)
While !eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. M->VV0_NUMTRA == VVA_NUMTRA
	AADD(acols,Array(nUsado+1))
	For _ni:=1 to nUsado
		acols[Len(acols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	Next
	acols[Len(acols),nUsado+1]:=.F.
	dbSkip()
Enddo

cTitulo    :=OemToAnsi(STR0003) //"Reavaliacao da Venda de Veiculos"
cAliasEnch :="VV1"
cLinOk     :="FG_OBRIGAT"
cTudoOk     :="AllwaysTrue()"
cFieldOk   :="FG_MEMVAR()"

aMyEncho     := aCpoEncS
aAltEnchoice := {}
Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
nOpca := 0
lVirtual := .f.
nLinhas:= 99           
Inclui := .f.
Altera := .t.


DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
EnChoice("VV0",nReg,nOpcE,,,,aMyEncho,{15,1,100,315},aAltEnchoice,3,,,,,,lVirtual)
oGetDados := MsGetDados():New(105,1,143,315,nOpcG,cLinOk,cTudoOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,if(MsgYesNo(OemToAnsi(STR0005),OemToAnsi("")),FS_FicVV019(),oDlg:End())),nOpca := 0)},{||oDlg:End()}) //"Deseja Visualizar Ficha do Veiculo ?"

If nOpca == 1
   FS_GvVm019()
Endif

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FicVV019  ³ Autor ³  Manoel               ³ Data ³ 18/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama FG que Apresenta a Ficha do Veiculo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³           																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FicVV019()

Private cGruVei := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)

DbSelectArea("VV1")
DbSetOrder(2)
DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)

FS_GvVm019()

cSimVda  := "V"
cTipSai  := "0"
                
nOpca1   := 0
cCodMap  := "001"
DEFINE MSDIALOG oDlgFV TITLE OemtoAnsi(STR0006) FROM  02,04 TO 09,27 OF oMainWnd   // "Demonstracao do Resultado" //"Demonstracao do Resultado"
	
@  15,06 SAY OemToAnsi(STR0007) OF oDlgFV PIXEL COLOR CLR_BLACK //"Codigo do Mapa"
@  15,52 MSGET oCodMap VAR cCodMap PICTURE "@!" F3 "VS5"  SIZE 34,3 OF oDlgFV PIXEL COLOR CLR_BLACK
@  02,02 TO 35,089  LABEL OemtoAnsi(STR0006)  OF oDlgFV PIXEL   //"Demonstracao do Resultado"
	
DEFINE SBUTTON FROM 37,24 TYPE 1 ACTION (nOpca1 := 1,oDlgFV:End())	ENABLE OF oDlgFV
DEFINE SBUTTON FROM 37,55 TYPE 2 ACTION (nOpca1 := 2,oDlgFV:End())	ENABLE OF oDlgFV
	
ACTIVATE MSDIALOG oDlgFV CENTER
	
if nOpca1 # 1
	Return .f.
Endif
	
cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
	
FG_CalcVlrs(FS_VDRVM010(VV0->VV0_TIPFAT,cCodMap))
FG_ResAva(cOutMoed,3,"V","0","VEIVM010")
	
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_PCIRTBF³ Autor ³  Manoel               ³ Data ³ 19/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Pis e Cofins e Iss sobre Bonus de Fabrica ou sobre ³±±
±±³          ³ Receita tecnica                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PCIRTBF()                                                    

Local	nAliIss   := GetMv("MV_TXISS")  / 100
Private cGruVei := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))

VV1->(dbSetOrder(1))
VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHAINT))

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))

FG_Seek("SF4","VVA->VVA_CODTES",1,.f.)

If readvar() == "M->VVA_INPCRT" // Tem Pis/Cofins sobre Receita Tecnica
	aPisCof := CalcPisCofSai(M->VVA_RECTEC)
   if  M->VVA_INPCRT == "1" 
       M->VVA_PISRTE := aPisCof[1,1] + aPisCof[1,2] //M->VVA_RECTEC * nAliPis
   Else
       M->VVA_PISRTE := 0
   Endif

Elseif readvar() == "M->VVA_INISRT" // Tem Iss sobre Receita Tecnica

   if  M->VVA_INISRT == "1" 
       M->VVA_ISSRTE := M->VVA_RECTEC * nAliIss
   Else
       M->VVA_ISSRTE := 0
   Endif

Elseif readvar() == "M->VVA_INPCBF" // Tem Pis/Cofins sobre Bonus de Fabrica
	aPisCof := CalcPisCofSai(M->VVA_BONFAB)
   if  M->VVA_INPCBF == "1" 
       M->VVA_PISBFB := aPisCof[1,1] + aPisCof[1,2] //M->VVA_BONFAB * nAliPis
   Else
       M->VVA_PISBFB := 0
   Endif

Elseif readvar() == "M->VVA_INISBF" // Tem Iss sobre Bonus de Fabrica

   if  M->VVA_INISBF == "1" 
       M->VVA_ISSBFB := M->VVA_BONFAB * nAliIss
   Else
       M->VVA_ISSBFB := 0
   Endif

Endif          

//acols[n,FG_POSVAR("VVA_PISRTE")] := M->VVA_PISRTE
//acols[n,FG_POSVAR("VVA_ISSRTE")] := M->VVA_ISSRTE
//acols[n,FG_POSVAR("VVA_PISBFB")] := M->VVA_PISBFB
//acols[n,FG_POSVAR("VVA_ISSBFB")] := M->VVA_ISSBFB

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GvVm019³ Autor ³  Manoel               ³ Data ³ 19/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava campos alterados                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GvVm019()
lMSHelpAuto := .f.
lMSErroAuto := .f.

Begin Transaction

	if !recLock("VVA",.f.)
      Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	Endif	

	VVA->VVA_RECTEC := M->VVA_RECTEC
	VVA->VVA_RMFTEC := FG_CalcMF({ {M->VVA_DATRTC,M->VVA_RECTEC} })
	VVA->VVA_BONFAB := M->VVA_BONFAB
	VVA->VVA_BMFFAB := FG_CalcMF({ {M->VVA_DATBFB,M->VVA_BONFAB} })
	VVA->VVA_DESCLI := M->VVA_DESCLI
	VVA->VVA_DMFCLI := FG_CalcMF({ {M->VVA_DATDCL,M->VVA_DESCLI} })
	VVA->VVA_VALREV := M->VVA_VALREV
	VVA->VVA_VMFREV := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VALREV} })
	VVA->VVA_INPCRT := M->VVA_INPCRT
	VVA->VVA_INISRT := M->VVA_INISRT
	VVA->VVA_INPCBF := M->VVA_INPCBF
	VVA->VVA_INISBF := M->VVA_INISBF
	VVA->VVA_PISRTE := M->VVA_PISRTE
	VVA->VVA_PMFRTE := FG_CalcMF({ {M->VVA_DATRTC,M->VVA_PISRTE} })
	VVA->VVA_PISBFB := M->VVA_PISBFB
	VVA->VVA_PMFBFB := FG_CalcMF({ {M->VVA_DATBFB,M->VVA_PISBFB} })
	VVA->VVA_ISSRTE := M->VVA_ISSRTE
	VVA->VVA_IMFRTE := FG_CalcMF({ {M->VVA_DATRTC,M->VVA_ISSRTE} })
	VVA->VVA_ISSBFB := M->VVA_ISSBFB
	VVA->VVA_IMFBFB := FG_CalcMF({ {M->VVA_DATBFB,M->VVA_ISSBFB} })
	VVA->VVA_DATDCL := M->VVA_DATDCL
	VVA->VVA_DATBFB := M->VVA_DATBFB
	VVA->VVA_DATRTC := M->VVA_DATRTC
	if VV0->VV0_TIPFAT == "2"
	   VVA->VVA_VALCVD := M->VVA_VALCVD
	   VVA->VVA_VMFCVD := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VALCVD} })
	   VVA->VVA_VALFRE := M->VVA_VALFRE
	   VVA->VVA_VMFFRE := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VALFRE} })
	Else
	   VVA->VVA_REDCUS := M->VVA_REDCUS
	   VVA->VVA_RMFCUS := FG_CalcMF({ {M->VVA_DATRCU,M->VVA_REDCUS} })
	   VVA->VVA_DATRCU := M->VVA_DATRCU
	Endif   
	                        
End Transaction
	
If lMsErroAuto
	MostraErro()
   lMSErroAuto := .f.
	lDeleta := .t.
	Return .f.
Endif

lMsHelpAuto := .f.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VM019LEG  |Autor  ³Valdir F. Silva     | Data ³  20/12/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra a legenda da mbrowse                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM019LEG()
Local	alegenda := {{'BR_VERMELHO',STR0008},;//Outros Documentos
					     {'BR_VERDE',STR0010}}//Vendas disponiveis para reavaliacao

BrwLegenda(cCadastro,STR0009 ,aLegenda)//Legenda

Return

Static Function MenuDef()
Local aRotina := {{OemtoAnsi(STR0001)	,"axPesqui"    	, 0 , 2},;  	//Consultar
        			{OemtoAnsi(STR0002)	,"FS_AltVm019"	, 0 , 4 },;  	//Alterar
				   	{OemToAnsi(STR0009)	,"VM019LEG" 	, 0 , 2,0,.f.},;//Legenda 
				   	{ STR0011 			,"VM019_LVEI" 	, 0 , 2}}   	//Pesquisa Chassi
Return aRotina   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM019_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 13/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM019_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )
Private oVerm := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private oBran := LoadBitmap( GetResources() , "BR_BRANCO" )
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
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0012) FROM  01,05 TO 17,70 OF oMainWnd	//Pesquisa Chassi
	@ 003,004 SAY STR0013 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE	//Veiculo:
  	@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
 	@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0014) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End())	//SAIR
	@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
																OemToAnsi(STR0015),;//Filial
																OemToAnsi(STR0016),;//Dt.Movimento
																OemToAnsi(STR0017),;//NF/Serie
																OemToAnsi(STR0018),;//Valor
																OemToAnsi(STR0019);//Cliente
																COLSIZES 10,35,37,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="0112",oVerd,IIf(left(aLevPesq[oLbLevPesq:nAt,02],3)=="011".and.substr(aLevPesq[oLbLevPesq:nAt,02],4,1)<>"2".and.Alltrim(aLevPesq[oLbLevPesq:nAt,02])<>"-",oVerd,oVerm)),; 
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
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_OPEMOV , VV0.VV0_TIPFAT , VV0.VV0_AUTFAT , VV0.VV0_SITNFI , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
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
   cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV"

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
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_OPEMOV ) + ( cQAlVV0 )->( VV0_TIPFAT ) + ( cQAlVV0 )->( VV0_SITNFI ) + ( cQAlVV0 )->( VV0_AUTFAT ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+( cQAlVV0 )->( VV0_SERNFI ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0020 +" "+cLevChas,STR0021) //Nenhuma Reavalicao da Venda de Veiculo para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq) 
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="0112",oVerd,IIf(left(aLevPesq[oLbLevPesq:nAt,02],3)=="011".and.substr(aLevPesq[oLbLevPesq:nAt,02],4,1)<>"2".and.Alltrim(aLevPesq[oLbLevPesq:nAt,02])<>"-",oVerd,oVerm)),;
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
