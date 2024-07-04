// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEIVM030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM030 ³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saida de Veiculo Consignado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM030

Local aArea    := GetArea()

Private aHeader    := Nil
Private aCols      := Nil
Private oLbParc
Private aIteParc   := {}
Private aIndVV0    := {}
Private aHeaderC   := {}
Private aColsC     := {}
Private bFiltraBrw := {|| Nil}
Private cGruVei    := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private cSimVda    := "V"
Private cPrefNF    := ""
Private cPrefix    := GetNewPar("MV_PREFVEI","VEI")
Private cSitVei    := "0"
Private cEstoque   := "S"
Private cTipSai    := "5" //Consignado
Private cTipOpe    := 3
Private cTipoMov := "C"
Private lTroco     := .f.

Private nAliIss    := GETMV("MV_TXISS")  / 100
Private nAliPis    := GETMV("MV_TXPIS")  / 100
Private nAliCof    := GETMV("MV_TXCOFIN")/ 100

Private lMsHelpAuto:= .f.
Private lMsErroAuto:= .f.
Private lAbortPrint:= .f.
Private aRotina    := MenuDef()

Private lMudouNum := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro  := OemToAnsi(STR0006) //Saida de Veiculos por Consignacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
cIndex    := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao :='VV0->VV0_OPEMOV $ "57" .and. VV0->VV0_SITNFI <> "0"' // Consignado e Ret. Consignado nao Cancelados

bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
Eval(bFiltraBrw)

aCores := {{'VV0->VV0_OPEMOV == "5" .AND. VV0->VV0_SITNFI == "1"','BR_VERDE'},;
           {'VV0->VV0_OPEMOV == "7" .AND. VV0->VV0_SITNFI == "1"','BR_AMARELO'},;
           {'VV0->VV0_OPEMOV == "5" .AND. VV0->VV0_SITNFI <> "1"','BR_PRETO'}}

mBrowse( 6, 1,22,75,"VV0",,,,,,aCores)

dbSelectArea("VV0")
RetIndex("VV0")
dbClearFilter()
aEval(aIndVV0,{|x| Ferase(x[1]+OrdBagExt())})
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CONSIGN³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao Principal de Saida de Veiculo Consignado             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CONSIGN(cAlias,nReg,nOpc)

Local cont
Local nLin    := 14
Local nOpcOk  := 0
Local nCntFor := 0  
Local nReg_   := nReg 
Local bCampo  := { |nCPO| Field(nCPO) }


//Variaveis de Tela
Private cCliente,cLoja,cNome,cVendedor,cNVendedor,cCodTes,cDTes,cCodTes2,cDTes2,cChave,cMarca,cModelo,cProprietario,cEstado,cCombustivel
Private nValVei,cAnoModelo,cCor,cNfiOri,cSerOri,cIteNFOri,cTipoCli,nValEnt
Private nTotalEnt:= 0

Private lVisual  := .f.
Private cNota    := ""
Private cSerie   := ""
Private cAuxTipo := "N" // Rubens - Alterado nome de cTipo para cAuxTipo pois a Mata410 alterava seu conteudo
Private cTraEnt  := ""
Private cIdeSB6  := ""
Private cObserv  := E_MSMM(VVA->VVA_OBSMEM,68)
Private nAcresFin := 0 // Cria Variavel para compatib. com o VEIVM011

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 03/08/2009                                            ³
//³Cria aHeaderIC e aColsIC para compatibilizacao com FS_VALTES011³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeaderIC:= {}
Private aColsIC  := {}

cCliente  := space(06)
cLoja     := space(02)
cNome     := space(30)
cEstado   := space(30)
cVendedor := space(06)
cNVendedor:= space(30)
cCodTes   := space(03)
cDTes     := space(30)
cCodTes2  := space(03)
cDTes2    := space(30)
cChave    := space(25)
cAnoModelo:= space(09)
cCor      := space(20)
cForPg    := space(03)
cDesPg    := space(20)
nValEnt   := 0
nValVei   := 0
cNfiOri   := ""
cSerOri   := ""
cIteNFOri := ""
nOpca     := 0

cLocVei := GETMV("MV_LOCVEIN")
if VV1->VV1_ESTVEI == '1'
	cLocVei := GETMV("MV_LOCVEIU")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de atendimento ao cliente                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV9")
While x3_arquivo == "VV9" .and. !eof()
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de remessa                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
aPriEnc := {}
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV0_CODCLI/VV0_LOJA/VV0_NOMCLI/VV0_CODVEN/VV0_NOMVEN/VV0_CHASSI/VV0_CHAINT/VV0_DESMAR/VV0_DESGRU/VV0_DESMOD/VV0_FABMOD/VV0_PLAVEI/VV0_VALMOV/VV0_FORPAG/VV0_DESFPG/VV0_CODTES/VV0_VBAICM/VV0_ALIICM/VV0_TOTICM/VV0_OBSERV/VV0_OBSMEM/VV0_CODTRA/VV0_TPFRET"
		AADD(aPriEnc,x3_campo)
	Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de atendimento ao cliente                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
While x3_arquivo == "VVA" .and. !eof()
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo
M->VVA_VALVDA := 0
M->VVA_VMFVDA := 0

Private lExclui := nOpc == 4

if lExclui
	if !Empty(VV0->VV0_TRADEV)
		MsgStop(STR0056,STR0028) //Para cancelar primeiro cancele o retorno da remessa... - Atencao!
		Return .f.		
	Endif
Endif

Private aSvtela
Private aSvGets

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)
	
dbSelectArea("SA3")
dbSetOrder(1)
if type("Inclui") == "U" .or. Inclui .or. (!Inclui .and. Empty(VV0->VV0_CODVEN))
	dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
	M->VV0_CODVEN := VAI->VAI_CODVEN
	M->VV0_NOMVEN := SA3->A3_NOME
Else
	dbSeek(xFilial("SA3")+M->VV0_CODVEN)
	M->VV0_CODVEN := VAI->VAI_CODVEN
	M->VV0_NOMVEN := SA3->A3_NOME 
Endif	

//Zera as variaveis fiscais
MaFisEnd()

// Funcao para Ver o Tipo de Saida
if !FS_VERTIPOC()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra o Browse de acordo com a condicao                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VV0")
	cCondicao :='VV0->VV0_OPEMOV $ "57" .and. VV0->VV0_SITNFI <> "0"' // Consignado e Ret. Consignado nao Cancelados
	bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
	Eval(bFiltraBrw)
   Return( .f. )
Endif
//adiciona campos ao executar a consulta - Rafael 30-09
if cAuxTipo == "N"
	if nOpc # 3
		dbSelectArea("VV0")
		dbGoto(nReg_)
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next
		dbSelectArea("VVA")
		dbSetOrder(1)
		dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		M->VV0_CODTES := VVA->VVA_CODTES
		M->VV0_CHAINT := VVA->VVA_CHAINT  
		M->VV0_CHASSI := VVA->VVA_CHASSI  
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+M->VV0_CHAINT)
		
		VE1->(dbSetOrder(1))
		VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	  	M->VV0_CODMAR := VV1->VV1_CODMAR
	  	M->VV0_DESMAR := VE1->VE1_DESMAR
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	  	M->VV0_MODVEI := VV1->VV1_MODVEI
	  	M->VV0_DESMOD := VV2->VV2_DESMOD
		M->VV0_CHASSI := VV1->VV1_CHASSI
		M->VV0_CODFRO := VV1->VV1_CODFRO
		M->VV0_PLAVEI := VV1->VV1_PLAVEI
		M->VV0_FABMOD := VV1->VV1_FABMOD
		
		dbSelectArea("VVR")
		dbSetOrder(2)
		dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD)
		M->VV0_GRUMOD := VV2->VV2_GRUMOD
		M->VV0_DESGRU := VVR->VVR_DESCRI
		
		FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	    if alltrim(SX3->X3_CAMPO) == "VV0_DESCOR"
	       cRet := VVC->VVC_DESCRI
	    Endif
		M->VV0_DESCOR := VVC->VVC_DESCRI
	
	    dbSelectArea("SA1")
	    dbSetOrder(1)
	    dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	    M->VV0_NOMCLI := SA1->A1_NOME
	   
	    dbSelectArea("SE4")
	    dbSetOrder(1)
	    dbSeek(xFilial("SE4")+VV0->VV0_FORPAG)
	    M->VV0_DESFPG := SE4->E4_DESCRI
	
	    dbSelectArea("SA3")
	    dbSetOrder(1)
	    dbSeek(xFilial("SA3")+VV0->VV0_CODVEN)
	    M->VV0_NOMVEN := SA3->A3_NOME
		
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
		M->VV0_PLAVEI := VV1->VV1_PLAVEI
	
	Endif
		
	aSvtela  := {{},{}}
	aSvGets  := {{},{}}

	SETAPILHA()
	DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM  4,0 To 29,80 OF oMainWnd

		aTela := {}
		aGets := {}
		dbSelectArea("VV0")
		Zero()
		oGetMGet1:= MsMGet():New("VV0",0,nOpc,,,,aPriEnc,{013,000,203,315},,2,,,,oDlgFolder,,.T.,.F.,"aSvTela[1]",.t.)
		oGetMGet1:oBox:bGotFocus   := {|| AL_Entra(1,"VV0") }
		oGetMGet1:oBox:bLostFocus  := {|| AL_Sai(1)}
		aSvTela[1] := aClone(aTela)
		aSvGets[1] := aClone(aGets)

	ACTIVATE MSDIALOG oDlgFolder CENTER ON INIT EnchoiceBar(oDlgFolder,{|| Processa({|| FS_TOKVM030() }),if(nOpca == 1,oDlgFolder:End(),.f.)},{||nOpca := 2,oDlgFolder:End()} )
Else
   dbSelectArea("VVF")
   dbSetOrder(1)
   if !dbSeek(xFilial("VVF")+cTraEnt)
      Return .f.
   Endif   

   dbSelectArea("VVG")
   dbSetOrder(1)
   if !dbSeek(xFilial("VVG")+cTraEnt)
      Return .f.
   Endif   
	M->VV0_CHASSI := VVG->VVG_CHASSI  

	dbSelectArea("SA2")
	dbSetOrder(1)
	if dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)

		VV1->(dbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1")+VVG->VVG_CHAINT))

		VE1->(dbSetOrder(1))
		VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))

		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

		VVR->(dbSetOrder(2))
		VVR->(dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD))

		VVC->(dbSetOrder(1))
		VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
			
	   nOpca := 0
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Dados da Devolucao") FROM  02,06 TO 23,78 OF oMainWnd  //Dados da Devolucao
	
			@ 013,000 SCROLLBOX oScroll VERTICAL SIZE 130,286 OF oDlg BORDER PIXEL
			oScroll:Align:= CONTROL_ALIGN_ALLCLIENT

			aFields := {{"CODFOR",RetTitle("VV0_CODCLI"),"C",TamSx3("VV0_CODCLI")[1],TamSx3("VV0_CODCLI")[1],"@!",.f.,,,,CLR_HBLUE},;    //Fornecedor
							{"LOJA"  ,RetTitle("VV0_LOJA"),"C",TamSx3("VV0_LOJA")[1]  ,TamSx3("VV0_LOJA")[1]  ,"@!",.f.,,,,CLR_HBLUE},;
							{"NOMCLI",RetTitle("VV0_NOMCLI"),"C",TamSx3("VV0_NOMCLI")[1],60,"@!",.f.,,,,CLR_BLACK},;
							{"CHASSI",RetTitle("VV0_CHASSI"),"C",TamSx3("VV0_CHASSI")[1],60,"@!",.f.,,,,CLR_HBLUE},;
							{"CHAINT",RetTitle("VV0_CHAINT"),"C",TamSx3("VV0_CHAINT")[1],TamSx3("VV0_CHAINT")[1],"@!",.f.,,,,CLR_BLACK},;
							{"MARCA" ,RetTitle("VV0_CODMAR"),"C",TamSx3("VV0_CODMAR")[1],40,"@!",.f.,,,,CLR_BLACK},;
							{"GRUPO" ,RetTitle("VV0_GRUMOD"),"C",TamSx3("VV0_GRUMOD")[1],60,"@!",.f.,,,,CLR_BLACK},;
							{"MODELO",RetTitle("VV0_MODVEI"),"C",TamSx3("VV0_MODVEI")[1],60,"@!",.f.,,,,CLR_BLACK},;
							{"COR"   ,RetTitle("VV0_DESCOR"),"C",TamSx3("VV0_DESCOR")[1],40,"@!",.f.,,,,CLR_BLACK},;
							{"FABMOD",RetTitle("VV0_FABMOD"),"C",TamSx3("VV0_FABMOD")[1],TamSx3("VV0_FABMOD")[1],"@R 9999/9999",.f.,,,,CLR_BLACK},;
							{"PLAVEI",RetTitle("VV0_PLAVEI"),"C",TamSx3("VV0_PLAVEI")[1],TamSx3("VV0_FABMOD")[1],"@!",.f.,,,,CLR_BLACK},;
							{"VALOR" ,RetTitle("VV0_VALMOV"),"C",TamSx3("VV0_VALMOV")[1],35,"@E 999,999,999.99",.f.,,,,CLR_HBLUE},;
							{"TES"   ,RetTitle("VV0_CODTES"),"C",TamSx3("VV0_CODTES")[1],TamSx3("VV0_CODTES")[1],"@!",.t.,"VALTES30(get_TES)","SF4",,CLR_HRED},;
							{"CODTRA",RetTitle("VV0_CODTRA"),"C",TamSx3("VV0_CODTRA")[1],10,"@!",.t.,"Vazio() .or. ExistCPO('SA4')","SA4",,CLR_BLACK}}
      	        	
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
			
			// Rubens - 31/08/2009
			// Adiciona o Combo do Tipo do Frete por ultimo 
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("VV0_TPFRET"))
			aTPFRETE := FormatIN(" ;" + AllTrim(X3CBOX()),";")
			aTPFRETE := StrTran(aTPFRETE,"(","{")
			aTPFRETE := StrTran(aTPFRETE,")","}")
			aTPFRETE := &(aTPFRETE)
			get_TPFRETE := Space(TAMSX3("VV0_TPFRET")[1])
			@ ((Int(Len(aFields)/2)) * 17)+1 , IIF ( (Len(aFields) % 2) == 0 , 4 , 170 ) SAY RetTitle("VV0_TPFRET") OF oScroll Pixel 
			@ ((Int(Len(aFields)/2)) * 17)+8 , IIF ( (Len(aFields) % 2) == 0 , 4 , 170 ) MSCOMBOBOX o_TPFRETE VAR get_TPFRETE SIZE 30,19 ITEMS aTPFRETE OF oScroll PIXEL COLOR CLR_BLACK
  		
			get_CODFOR := SA2->A2_COD
			get_LOJA   := SA2->A2_LOJA
			get_NOMCLI := SA2->A2_NOME
			get_CHASSI := VV1->VV1_CHASSI
			get_CHAINT := VV1->VV1_CHAINT
			get_MARCA  := VE1->VE1_DESMAR
			get_GRUPO  := VVR->VVR_DESCRI
			get_MODELO := VV2->VV2_DESMOD
			get_COR    := VVC->VVC_DESCRI
			get_FABMOD := VV1->VV1_FABMOD
			get_PLAVEI := VV1->VV1_PLAVEI
			get_VALOR  := VVF->VVF_VALMOV
	
			for cont := 1 to Len(aFields)
			    &("o_"+aFields[cont,1]):Refresh()
			next
      	   
	      o_TES:SetFocus()
   	      
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,Iif(FS_TOKVM030(),oDlg:End(),.t.)},{||nOpca := 2,oDlg:End()})
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra o Browse de acordo com a condicao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
cCondicao :='VV0->VV0_OPEMOV $ "57" .and. VV0->VV0_SITNFI <> "0"' // Consignado e Ret. Consignado nao Cancelados
bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
Eval(bFiltraBrw)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VALTES30  ³ Autor ³  Andre                ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do TES digitado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VALTES30(cTes)

Local lRet := .t.

if Val(cTes) < 500
	lRet := .f.
Endif

if SF4->(DbSeek(xFilial("SF4")+cTes))
	if !lRet
		MsgInfo(OemtoAnsi(STR0057),STR0028) //O TES Informado se refere a uma ENTRADA, informe um TES correto de SAIDA... - Atencao!
	Endif
Else
	lRet := .f.
Endif

if lRet                
	if SF4->F4_ESTOQUE == "N"
		// Manoel - 17/02/2005 
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
		If VV1->VV1_SITVEI != " "
		   MsgInfo(STR0058,STR0028) //Atencao o TES informado nao movimenta estoque... - Atencao!
		Endif   
	Endif   

	//if SF4->F4_PODER3 <> "D" //Devolucao
	//   MsgInfo("O TES tem que controlar poder de terceiro na DEVOLUCAO!","Atencao!")
	//	lRet := .f.
	//Endif      
	
	M->VV0_CODCLI := get_CODFOR
	M->VV0_LOJA   := get_LOJA

	If !MaFisFound('NF')
		If !Empty(M->VV0_LOJA)
			MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','D',SA2->A2_TIPO,MaFisRelImp("VEIVM030",{"VVF","VVG"}))
	   EndIf
	Else
		FS_FisRef("NF_CODCLIFOR",M->VV0_CODCLI)
		If !Empty(M->VV0_LOJA)
			FS_FisRef("NF_LOJA",M->VV0_LOJA)
		EndIf
	EndIf
	
	M->VV0_VALMOV := get_VALOR
	M->VV0_CHAINT := get_CHAINT
	M->VV0_CODTES := get_TES

	FS_FisRef("IT_VALMERC",M->VV0_VALMOV)
	FS_FisRef("IT_PRODUTO",M->VV0_CHAINT)
	FS_FisRef("IT_TES"    ,M->VV0_CODTES)
	FS_FisRef("IT_ALIQICM",M->VV0_ALIICM)

	M->VV0_VBAICM := MaFisRet(,"NF_BASEICM")
	M->VV0_TOTICM := MaFisRet(,"NF_VALICM")
	
	M->VVA_CODTES := M->VV0_CODTES	
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_TOKVM030 | Autor ³ ANDRE               ³ Data ³ 25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Validacao do Programa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TOKVM030(cAlias, nReg, nOpc)
Local i := 0
//if !MsgYesNo("Confirma Emissao da Nota Fiscal ?","Atencao !")
//   Return( .f. )
//Endif   

nOpca := 2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rafael - 15/12/2009 - Solicitado Pelo Manoel                 ³
//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If cAuxTipo == "N"  //normal
	For i:=1 to Len(aPriEnc)
		If X3Obrigat(aPriEnc[i]) .and. Empty(&("M->"+aPriEnc[i]))
			Help(" ",1,"OBRIGAT2",,RetTitle(aPriEnc[i]),4,1 )
			Return
		EndIf
	Next        
EndIF

if cAuxTipo <> "D" // Devolucao
   if VV1->VV1_SITVEI == "3"
      MsgStop(STR0059,STR0028) //Veiculo ja esta em remessa... - Atencao!
      Return .f.
   ElseIf !VV1->VV1_SITVEI $ "04"
      MsgStop(STR0060,STR0028)  //Veiculo nao esta no estoque... - Atencao!
      Return .f.
   Endif   
Endif   

if ExistBlock("VM030ANF")
   if !ExecBlock("VM030ANF",.f.,.f.)
  	  Return(.f.)
   Endif
Endif

if !FG_SEMAFORO("SX5")
   Return(.f.)
Endif

If FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
	Return(.f.)
Endif

Processa( { || lMsErroAuto := FS_PROC030() } )

// Destrava a Numneracao de Nota Fiscal
SX5->(MsRUnLock())

FG_SEMAFORO("SX5","L")

if lMsErroAuto
   MostraErro()
Endif   

if !lMsErroAuto
   nOpca := 1
Endif   

Return( !lMsErroAuto )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_PROC030³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa o Retorno do Veiculo Consignado                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PROC030()

Local cTesPed, cC5_Tipo, aCusto030
Local x_ := 0
Private cNumPed, cLocVei
Private aCabPv := {}
Private aItePv := {}

ProcRegua(5)
IncProc(OemToAnsi(STR0061))//Gerando Nota Fiscal de Consignado

if cAuxTipo == "N" // Normal
   cTesPed := M->VV0_CODTES
Else
   cTesPed := get_TES
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 03/08/2009                              ³
	//³Valor do Frete e Transp digitado na EnchoiceTemp ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->VV0_CODTRA := get_CODTRA
	M->VV0_TPFRET := get_TPFRETE
	
Endif

if Empty(VV1->VV1_LOCPAD)
   cLocVei := GETMV("MV_LOCVEIN")    //Novo
   if VV1->VV1_ESTVEI == '1'
   	cLocVei := GETMV("MV_LOCVEIU") //Usado
   Endif
   if VV1->VV1_SITVEI == "4"         //Consignado
   	cLocVei := GETMV("MV_LOCVEIC")
   Endif
Else
   cLocVei := VV1->VV1_LOCPAD
Endif   

Begin Transaction

		aCabPV   := {}
		cNumPed  := CriaVar("C5_NUM")

      if cAuxTipo == "N" // Normal
	  		dbSelectArea("VVF")
			dbSetOrder(1)
			dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
	  		dbSelectArea("VVG")
			dbSetOrder(1)
			dbSeek(xFilial("VVG")+VV1->VV1_TRACPA)
      Else
	  		dbSelectArea("VVF")
			dbSetOrder(1)
			dbSeek(xFilial("VVF")+cTraEnt)
	  		dbSelectArea("VVG")
			dbSetOrder(1)
			dbSeek(xFilial("VVG")+cTraEnt)
			M->VV0_CHAINT := get_CHAINT
		Endif	

      nBICMSVVF := VVF->VVF_VBAICM
      nAICMSVVF := VVF->VVF_ALIICM
      nVICMSVVF := VVF->VVF_TOTICM
      nBICMSVVG := VVG->VVG_VBAICM
  	   nAICMSVVG := VVG->VVG_ALIICM
     	nVICMSVVG := VVG->VVG_ICMCOM
    	nVCustVVG := VVG->VVG_VCNVEI

  	   cCliente := iif(cAuxTipo <> "D",M->VV0_CODCLI,get_CODFOR)
  	   cLoja    := iif(cAuxTipo <> "D",M->VV0_LOJA,get_LOJA)
  	   cVendedor:= iif(cAuxTipo <> "D",M->VV0_CODVEN,"")
  	   cChave   := iif(cAuxTipo <> "D",M->VV0_CHASSI,get_CHASSI)
  	   nValVei  := iif(cAuxTipo <> "D",M->VV0_VALMOV,get_VALOR)


      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+cCliente+cLoja)
    
      if cAuxTipo == "D" // Devolucao
         cC5_Tipo := "B" // Utiliza Fornecedor
         cTipoCli := "R" // Revendedor
      Else   
         cC5_Tipo := "N" // Normal
         cTipoCli := SA1->A1_TIPO
      Endif   

      IncProc(OemToAnsi(STR0062)) //Gerando Pedido

		aAdd(aCabPV,{"C5_NUM"    ,cNumPed        ,Nil})   // Numero do pedido
		aAdd(aCabPV,{"C5_TIPO"   ,cC5_Tipo       ,Nil})   // Tipo de pedido
		aAdd(aCabPV,{"C5_CLIENTE",cCliente       ,Nil})   // Codigo do cliente
		aAdd(aCabPV,{"C5_LOJAENT",cLoja          ,Nil})   // Loja para entrada
		aAdd(aCabPV,{"C5_LOJACLI",cLoja          ,Nil})   // Loja do cliente
		aAdd(aCabPV,{"C5_CONDPAG",RetCondVei()   ,Nil})   // Codigo da condicao de pagamanto
		aAdd(aCabPV,{"C5_VEND1"  ,cVendedor      ,Nil})   // Codigo do vendedor
		aAdd(aCabPV,{"C5_EMISSAO",dDataBase      ,Nil})   // Data de emissao
		aAdd(aCabPV,{"C5_TIPOCLI",cTipoCli       ,Nil})   // Tipo do Cliente
		aAdd(aCabPV,{"C5_INCISS" ,"N"            ,Nil})   // ISS Incluso
		aAdd(aCabPV,{"C5_TIPLIB" ,"2"            ,Nil})   // Tipo do Cliente
		aAdd(aCabPV,{"C5_MOEDA"  ,1              ,Nil})   // Moeda
		aAdd(aCabPV,{"C5_LIBEROK","S"            ,Nil})   // Liberacao Total
		aAdd(aCabPV,{"C5_COMIS1" ,0              ,Nil})   // Percentual de Comissao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 31/07/2009                                              ³
		//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
		//³FNC 18018/2009                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aCabPV,{"C5_TRANSP" ,M->VV0_CODTRA  ,Nil})   // Transportadora
		IF !Empty(M->VV0_TPFRET)
			aAdd(aCabPV,{"C5_TPFRETE",M->VV0_TPFRET  ,Nil})   // Tipo  do Frete 
		ENDIF

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SC5")
		While !Eof().and.(x3_arquivo=="SC5")
			wVar := "M->"+x3_campo
			&wVar:= CriaVar(x3_campo)
			dbSkip()
		EndDo

      For x_:=1 to Len(aCabPV)
          Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
      Next
			
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
  		SB1->(dbSetOrder(7))
      SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
  		SB1->(dbSetOrder(1))
  		
  		SE4->(dbSetOrder(1))

		cLocal     := SB1->B1_LOCPAD
		cCFiscal   := FG_CLAFIS(cTesPed)
      aItePv     := {}
		aIteTempPV := {}

		aAdd(aIteTempPV,{"C6_NUM"    ,cNumPed      ,Nil}) // Numero do Pedido
		aAdd(aIteTempPV,{"C6_ITEM"   ,"01"         ,Nil}) // Numero do Item no Pedido
		aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD  ,Nil}) // Codigo do Produto
		aAdd(aIteTempPV,{"C6_QTDVEN" ,1            ,Nil}) // Quantidade Vendida
		aAdd(aIteTempPV,{"C6_PRUNIT" ,nValVei      ,Nil}) // Preco Unitario do Produto
		aAdd(aIteTempPV,{"C6_PRCVEN" ,nValVei      ,Nil}) // Preco Unitario Liquido
		aAdd(aIteTempPV,{"C6_VALOR"  ,nValVei      ,Nil}) // Valor Total do Item
		aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase    ,Nil}) // Data da Entrega
		aAdd(aIteTempPV,{"C6_UM"     ,"UN"         ,Nil}) // Unidade de Medida Primar.
		aAdd(aIteTempPV,{"C6_TES"    ,cTesPed      ,Nil}) // Tipo de Entrada/Saida do Item
		aAdd(aIteTempPV,{"C6_LOCAL"  ,cLocal       ,Nil}) // Almoxarifado
		aAdd(aIteTempPV,{"C6_CF"     ,cCFiscal     ,Nil}) // CFO
		aAdd(aIteTempPV,{"C6_VALDESC",0            ,Nil}) // Valor do Desconto
		aAdd(aIteTempPV,{"C6_COMIS1" ,0            ,Nil}) // Comissao Vendedor
		aAdd(aIteTempPV,{"C6_DESCRI" ,Alltrim(cChave)       ,Nil}) // Descricao do Produto
		aAdd(aIteTempPV,{"C6_CLI"    ,cCliente     ,Nil}) // Cliente
		aAdd(aIteTempPV,{"C6_LOJA"   ,cLoja        ,Nil}) // Loja do Cliente
		aAdd(aIteTempPV,{"C6_QTDEMP" ,1            ,Nil}) // Quantidade Empenhada

    if cAuxTipo == "D" // Devolucao
			aAdd(aIteTempPV,{"C6_IDENTB6",cIdeSB6    ,Nil}) // Identificacao do Poder de Terceiro
			aAdd(aIteTempPV,{"C6_NFORI"  ,cNfiOri    ,Nil}) // Numero da NF Original
			aAdd(aIteTempPV,{"C6_SERIORI",cSerOri    ,Nil}) // Serie da NF Original
			aAdd(aIteTempPV,{"C6_ITEMORI",cIteNFOri  ,Nil}) // Sequencia do Item da NF Original
		Endif	
		
		aAdd(aItePv,aClone(aIteTempPV))

      inclui      := .t.
		lMsErroAuto := .f.
		
		if ExistBlock("PEDVM030")
			ExecBlock("PEDVM030",.f.,.f.)
		Endif

      FG_X3ORD("C",,aCabPV)
		FG_X3ORD("I",,aItePv)
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePV,3)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		lCredito := .t.
		lEstoque := .t.
		lLiber   := .t.
		lTransf  := .f.
			
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+cNumPed+"01")
		While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
		   nQtdLib := SC6->C6_QTDVEN
		   cChavSC9 := cNumPed+SC6->C6_ITEM
		   FG_Seek("SC9","cChavSC9")
		   nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
		   dbSelectArea("SC6")
		   dbSkip()
		Enddo

      IncProc(OemToAnsi(STR0063)) //Liberando Pedido

		aPvlNfs  := {}
		cChavSC9 := cNumPed+"01"

		dbSelectArea("SC9")
		dbSetOrder(1)
		SC9->(dbSeek(xFilial("SC9")+cChavSC9))
		While !Eof() .and. SC9->C9_FILIAL == xFilial("SC9") .and. SC9->C9_PEDIDO == cNumPed

			If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
                                  
            cTesPd2:= cTesPed
            cPagto := RetCondVei()
				dbSelectArea("SC9")
				FG_Seek("SB1","SC9->C9_PRODUTO",1)
				FG_Seek("SC5","SC9->C9_PEDIDO",1,.F.)
				FG_Seek("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
				FG_Seek("SB5","SB1->B1_COD")
				FG_Seek("SB2","SB1->B1_COD+cLocVei")
				FG_Seek("SF4","cTesPd2")
				FG_Seek("SE4","cPagto",1)  //Tem que ser Tipo A para nao criar SE1 automatico

				aAdd(aPvlNfs,{C9_PEDIDO,;
				               C9_ITEM,;
									C9_SEQUEN,;
									C9_QTDLIB,;
									C9_PRCVEN,;
									C9_PRODUTO,;
									SF4->F4_ISS=="S",;
									SC9->(RecNo()),;
									SC5->(RecNo()),;
									SC6->(RecNo()),;
									SE4->(RecNo()),;
									SB1->(RecNo()),;
									SB2->(RecNo()),;
									SF4->(RecNo())})
									
			Endif
			dbSelectArea("SC9")
			dbSkip()
		Enddo
			
		if Len(aPvlNfs) == 0
		   MsgInfo(STR0064,STR0028) //Problema com os Itens do Pedido (Arquivo < SC9 >) ... - Atencao!
			DisarmTransaction()
			Break
		Endif

      IncProc(OemToAnsi(STR0065))  //Gerando Nota Fiscal

      //Funcao que trata aliquota do ICMS para veiculos
      FS_ALIICMS(SB1->B1_COD)
			
		PERGUNTE("MT461A",.f.)
		cNota   := MaPvlNfs(aPvlNfs,cSerie, .F., .F., .f., .T., .F., 0, 0, .T., .F.)

		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		//
		FM_LOCVZL(2)
		FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
		//
	    dbSelectArea("SF2")
		RecLock("SF2",.f.)
		SF2->F2_COND    := cForPg
		SF2->F2_DUPL    := cNota
		SF2->F2_PREFORI := cPrefix
		SF2->F2_VALFAT  := nValVei
		//SF2->F2_BASEICM := nBICMSVVF
		//SF2->F2_VALICM  := nVICMSVVF
		MsUnlock()  

		// Andre Luis Almeida - 12/02/2004 //
		/*
			DbSelectArea("SD2")
			RecLock("SD2",.f.)
			SD2->D2_BASEICM := nBICMSVVG
			SD2->D2_VALICM  := nVICMSVVG 
			MsUnlock()
			DbSelectArea("SF3")
			RecLock("SF3",.f.)
			SF3->F3_BASEICM := nBICMSVVF
			SF3->F3_VALICM  := nVICMSVVF
			MsUnlock()
   	   DbSelectArea("SF2")
   	*/   

		// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	   If ExistBlock("VM030DNF")
	      ExecBlock("VM030DNF",.f.,.f.)
	   EndIf

      // Gravacao dos Arquivos de Gestao de Concessionarias
      IncProc(OemToAnsi(STR0066)) //Gravando Dados Gerais

	   dbSelectArea("VV0")
	   RecLock("VV0",.t.)
	   FG_GRAVAR("VV0")
	   VV0->VV0_FILIAL := xFilial("VV0")
      //VV0->VV0_NUMTRA := GetSXENum("VV0","VV0_NUMTRA")
		ConfirmSx8()
      if cAuxTipo == "N" // Normal
		   VV0->VV0_OPEMOV := "5"  //Consignacao
		Else
		   VV0->VV0_OPEMOV := "7"  //Retorno da Entrada de Consignacao
		   VV0->VV0_TRADEV := VVF->VVF_TRACPA
		Endif   
	   VV0->VV0_TIPFAT := VV1->VV1_ESTVEI //0=Novo;1=Usado
	   VV0->VV0_DATMOV := dDataBase
	   VV0->VV0_DATEMI := dDataBase
	   VV0->VV0_NUMPED := cNumPed
	   VV0->VV0_CODCLI := cCliente
	   VV0->VV0_LOJA   := cLoja
	   VV0->VV0_NUMNFI := cNota
	   VV0->VV0_SERNFI := cSerie
	   VV0->VV0_FORPAG := cForPg
	   VV0->VV0_VALMOV := nValVei
	   VV0->VV0_SITNFI := "1"
	   VV0->VV0_DTHEMI := Dtoc(dDataBase) + [/] + Time()
      VV0->VV0_ESTCLI := SA1->A1_EST
      VV0->VV0_CODVEN := cVendedor
	   //Impostos
	   VV0->VV0_VBAICM := nBICMSVVF // 0 // Andre Luis Almeida - 12/02/2004
	   VV0->VV0_ALIICM := nAICMSVVF // 0 // Andre Luis Almeida - 12/02/2004 
	   VV0->VV0_TOTICM := nVICMSVVF // 0  // Andre Luis Almeida - 12/02/2004
	   MsUnlock()

      aAreaVV1  := VV1->(GetArea("VV1"))
      aCusto030 := FS_CUSTOVEIC()
      VV1->(RestArea(aAreaVV1))
      
		VV1->(dbSetOrder(2))
	   VV1->(dbSeek(xFilial("VV1")+cchave))
	   dbSelectArea("VVA")                                        
	   RecLock("VVA",.t.)
	   FG_GRAVAR("VVA")
	   //Chaves Primarias
	   VVA->VVA_FILIAL := xFilial("VVA")
	   VVA->VVA_NUMTRA := VV0->VV0_NUMTRA
      //Dados do Veiculo
	   VVA->VVA_CHASSI := VV1->VV1_CHASSI
	   VVA->VVA_CHAINT := VV1->VV1_CHAINT
	   VVA->VVA_ESTVEI := VV1->VV1_ESTVEI
      VVA->VVA_CODORI := VV1->VV1_CODORI	   
		VVA->VVA_TRACPA := VV1->VV1_TRACPA
	   //Outras Informacoes
	   VVA->VVA_SIMVDA := "V" //Venda
	   VVA->VVA_CODTES := cTesPed
	   VVA->VVA_FATTOT := nValVei
	   VVA->VVA_FMFTOT := FG_CalcMF({{dDataBase,nValVei}})
	   VVA->VVA_VALVDA := nValVei
	   VVA->VVA_VMFVDA := FG_CalcMF({{dDataBase,nValVei}})
	   VVA->VVA_VALMOV := nValVei
      VVA->VVA_VMFMOV := FG_CalcMF({{dDataBase,nValVei}})
	   VVA->VVA_VCAVEI := aCusto030[1]
	   VVA->VVA_VALFRE := aCusto030[2]
      VVA->VVA_VMFVEI := FG_CalcMF({{dDataBase,VVA->VVA_VCAVEI}})
		VVA->VVA_ICMCOM := 0
		VVA->VVA_ALIICM := 0
	   VVA->VVA_VCAVEI := nVCustVVG // aCusto030[1] // Andre Luis Almeida - 12/02/2004
		VVA->VVA_ALIICM := nAICMSVVG // 0 // Andre Luis Almeida - 12/02/2004 
	   VVA->VVA_VBAICM := nBICMSVVG // 0 // Andre Luis Almeida - 12/02/2004
	   VVA->VVA_ICMVEN := nVICMSVVG // 0 // Andre Luis Almeida - 12/02/2004
	   		
		VVA->VVA_VDESCO := VVG->VVG_VDESCO
		VVA->VVA_VMFSCO := FG_CalcMF({ {VVF->VVF_DATMOV,VVA->VVA_VDESCO} })
		VVA->VVA_IMFCOM := FG_CalcMF( { {FG_RtDtImp("ICM",VVF->VVF_DATMOV),VVA->VVA_ICMCOM} })
		VVA->VVA_TOTIMP := VVA->VVA_ICMVEN+VVA->VVA_ISSCVD+VVA->VVA_PISVEN+VVA->VVA_COFVEN+VVA->VVA_ISSRTE+VVA->VVA_PISRTE+VVA->VVA_ISSBFB+VVA->VVA_PISBFB
		VVA->VVA_TMFIMP := VVA->VVA_IMFVEN+VVA->VVA_IMFCVD+VVA->VVA_PMFVEN+VVA->VVA_CMFVEN+VVA->VVA_IMFRTE+VVA->VVA_PMFRTE+VVA->VVA_IMFBFB+VVA->VVA_PMFBFB
      VVA->VVA_TOTCUS := FG_FORMULA(GetMv("MV_TOTCUFN"))
      VVA->VVA_TMFCUS := FG_FORMULA(GetMv("MV_TMFCUFN"))
		VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_TOTIMP-VVA->VVA_VCAVEI-VVA->VVA_VALFRE
		VVA->VVA_LMFBRU := VVA->VVA_FMFTOT-VVA->VVA_TMFIMP-VVA->VVA_VMFVEI-VVA->VVA_VMFFRE
		VVA->VVA_TOTDES := VVA->VVA_DESVEI+VVA->VVA_DESCLI+VVA->VVA_SEGVIA+VVA->VVA_VALASS+VVA->VVA_VALREV+VVA->VVA_ASSIMP+VVA->VVA_DESFIX
		VVA->VVA_TMFDES := VVA->VVA_DMFVEI+VVA->VVA_DMFCLI+VVA->VVA_SMFVIA+VVA->VVA_VMFASS+VVA->VVA_VMFREV+VVA->VVA_AMFIMP+VVA->VVA_DMFFIX
		VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
		VVA->VVA_LMFLQ1 := VVA->VVA_LMFBRU-VVA->VVA_JMFEST-VVA->VVA_AMFSSO-VVA->VVA_VMFSCO-VVA->VVA_DMFCLI-VVA->VVA_SMFVIA-VVA->VVA_VMFASS-VVA->VVA_VMFREV-VVA->VVA_DMFVEI-VVA->VVA_AMFIMP-VVA->VVA_CMFVDE-VVA->VVA_CMFGER-VVA->VVA_CMFPAT //LUCRO MARGINAL
		VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)      //LAIR
		VVA->VVA_LMFLQ2 := VVA->VVA_LMFLQ1-VVA->VVA_DMFFIX+(VVA->VVA_RMFCUS+VVA->VVA_RMFVEI-VVA->VVA_DMFFIN)      //LAIR
		VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
		MSMM(,TamSx3("VVA_OBSERV")[1],,cObserv,1,,,"VVA","VVA_OBSMEM")
	   
	   MsUnlock()

      VV1->(RestArea(aAreaVV1))
      dbSelectArea("VV1")
      dbSetOrder(2)
      if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
	      RecLock("VV1",.f.)
	      VV1->VV1_NUMTRA := VV0->VV0_NUMTRA
   	   if cAuxTipo == "D" // Devolucao
	         VV1->VV1_SITVEI := " " //Nao esta mais no estoque
   	   Else
	     	   VV1->VV1_SITVEI := "4" //Consignado
   	   Endif   
	      MsUnlock()
	   Endif   

      if cAuxTipo == "D" // Devolucao
			RecLock("VVF",.f.)
			VVF->VVF_SITNFI := "2"    // Devolvida
			VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
			MsUnlock()
      Endif

End Transaction

if !lMsErroauto
if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
	If ExistBlock("NFSAIVEI")
	   dbSelectArea("VV0")
	   Set Filter To
		ExecBlock("NFSAIVEI",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI})
	Endif
Endif	
Endif

Return( lMsErroAuto )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_CUSTOVEIC| Autor ³ ANDRE               ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o Custo do Veiculo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CUSTOVEIC()
                
Local nValFre
Local bCampo        := { |nCPO| Field(nCPO) }
Local nCustoVeiculo := 0
Local nCntFor		:= 0

//Posicionamento p/ calcular o Custo do Veiculo
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

if VV1->VV1_ESTVEI == "0"
	If !Empty(VV2->VV2_FORCTB)       //Modelo do Veiculo
		nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCTB)
	ElseIf !Empty(VE4->VE4_FORCUS)   //Parametros da Montadora
		nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
	Endif
	if ValType(nCustoVeiculo) <> "N"
	   nCustoVeiculo := 0
	Endif   
Else                                
   cFor := GetMv("MV_VUCGER")
   if !Empty(cFor)
		nCustoVeiculo := FG_FORMULA(cFor)
		if ValType(nCustoVeiculo) <> "N"
		   nCustoVeiculo := 0
		Endif   
	Endif
Endif

if nCustoVeiculo <= 0
   dbSelectArea("VV1")
   dbSetOrder(1)
   if dbSeek(xFilial("VV1")+M->VVA_CHAINT)
   	dbSelectArea("VVG")
   	dbSetOrder(1)
 	 	if DbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)
 	 	   nCustoVeiculo := VVG->VVG_VCNVEI
 	 	Endif
 	Endif 	   
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

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
SB1->(dbSetOrder(1))

dbSelectArea("SB2")
dbSetOrder(1)
if dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei)
   RecLock("SB2",.f.)
   SB2->B2_CM1   := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
   SB2->B2_CM2   := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
   SB2->B2_CM3   := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
   SB2->B2_CM4   := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
   SB2->B2_CM5   := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
  	MsUnlock()
Endif	

dbSelectArea("SB6")
dbSetOrder(3)
if dbSeek(xFilial("SB6")+cIdeSB6)
	RecLock("SB6",.f.)
	SB6->B6_CUSTO1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SB6->B6_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SB6->B6_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SB6->B6_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SB6->B6_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif   

dbSelectArea("SD2")
dbSetOrder(3)
if dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
	RecLock("SD2",.f.)
	SD2->D2_CUSTO1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SD2->D2_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SD2->D2_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SD2->D2_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SD2->D2_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif	

dbSelectArea("VVA")

Return( {nCustoVeiculo,nValFre} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_MEMO030³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³MEMO p/ Observacao                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MEMO030()

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0026) FROM  02,04 TO 14,56 OF oMainWnd  //Observacao

	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1

	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()
	
ACTIVATE MSDIALOG oDlg1 CENTER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_VERTIPOC| Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para ver o tipo de saida de Consignado               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERTIPOC()

Local x_ := 0
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

If Inclui
// Inclusao	
nOpc1 := 2
cTipR := " "
DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0067) FROM  02,04 TO 8,28 OF oMainWnd  //Tipo de Inclusao
	
	nCkPerg1 := 1
	@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
	OemToAnsi(STR0068), OemToAnsi(STR0069);   //Saida por Consignacao - Retorno de Entrada
	OF oDlgPerg PIXEL 

 	@ 028,005 BUTTON oOkBt  PROMPT OemToAnsi(STR0070) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpc1 := 1,oDlgPerg:End()) //Confirma
 	@ 028,048 BUTTON oNoBt  PROMPT OemToAnsi(STR0071) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpc1 := 2,oDlgPerg:End()) //Cancela
   
   oOkBt:SetFocus()

ACTIVATE MSDIALOG oDlgPerg CENTER

if nOpc1 <> 1
	Return(.f.)
Endif
    
cTipR := str(nCkPerg1,1)

if cTipR == "2"
   //Browse das Entradas de Consignado
   cCondicao :='VVF->VVF_OPEMOV == "4" .and. VVF->VVF_SITNFI == "1"' 
   aIteBrw   := {}
   cAuxTipo     := "D"
   lVisual   := .t.
   cTipSai   := "7" //Ret. de Consignado

   dbSelectArea("VVF")
   dbSetOrder(1)
   dbSeek(xFilial("VVF"))
   While !eof() .and. VVf->VVf_FILIAL == xFilial("VVF")
      if &cCondicao
         aadd(aIteBrw,{.f.,VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_VALMOV,VVF->VVF_TRACPA,VVF->VVF_DATMOV,VVF->VVF_CODFOR,VVF->VVF_LOJA})
      Endif   
	   dbSelectArea("VVF")
	   dbSkip()
   Enddo

   if Len(aIteBrw) == 0
      aadd(aIteBrw,{.f.," "," "," "," "," "," "," "})
   Endif

   xOpca  := 0
   cOrcto := space(8)

   DEFINE MSDIALOG oDlg2 FROM  04,10 TO 34,86 TITLE cCadastro OF oMainWnd

   @ 013, 001 LISTBOX oLbHd2 FIELDS HEADER	OemToAnsi(""),;
   OemToAnsi(STR0045),;		//Nota
   OemToAnsi(STR0046),;		//Serie
   OemToAnsi(STR0047),;		//Valor
   OemToAnsi(STR0048),;		//Transacao
   OemToAnsi(STR0049),;		//Data
   OemToAnsi(STR0010),;		//Fornecedor
   OemToAnsi(STR0009);		//Loja
   COLSIZES 10,35,20,35,35,35,40,35;
   SIZE 299,213 OF oDlg2 PIXEL ON DBLCLICK (FS_SELCONS(oLbHd2:nAt))
   oLbHd2:Align := CONTROL_ALIGN_ALLCLIENT
                                                                     

   oLbHd2:SetArray(aIteBrw)
   oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
   aIteBrw[oLbHd2:nAt,2] ,;
   aIteBrw[oLbHd2:nAt,3] ,;
   FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,4],"@E 99,999,999.99")) ,;
   aIteBrw[oLbHd2:nAt,5] ,;
   aIteBrw[oLbHd2:nAt,6] ,;
   aIteBrw[oLbHd2:nAt,7] ,;
   aIteBrw[oLbHd2:nAt,8] }}



   ACTIVATE MSDIALOG oDlg2 CENTER ON INIT (EnchoiceBar(oDlg2,{|| xOpca := 1,oDlg2:End()},{|| xOpca := 2,oDlg2:End()}))

   if xOpca <> 1
      Return( .f. )
   Endif   
Endif

if cAuxTipo == "D" // Devolucao
   For x_:=1 to Len(aIteBrw)
      if aIteBrw[x_,1]
		   dbSelectArea("VVF")
		   dbSetOrder(4)
		   if dbSeek(xFilial("VVF")+aIteBrw[x_,7]+aIteBrw[x_,8]+aIteBrw[x_,2]+aIteBrw[x_,3])

		      dbSelectArea("VVG")
			   dbSetOrder(1)
			   dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		   
		      dbSelectArea("SA2")
			   dbSetOrder(1)
			   dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			   		   
				cCliente  := VVF->VVF_CODFOR
				cLoja     := VVF->VVF_LOJA
				cNome     := SA2->A2_NOME
				cVendedor := space(06)
				cNVendedor:= space(30)
				cCodTes   := VVG->VVG_CODTES
				nValVei   := VVG->VVG_VALUNI
				cChave    := VVG->VVG_CHASSI
            cTipoCli  := SA2->A2_TIPO
            cForPg    := VVF->VVF_FORPAG


					// Andre Luis Almeida - 12/02/2004 //
		            nBICMSVVF := VVF->VVF_VBAICM
		            nAICMSVVF := VVF->VVF_ALIICM
	   	         nVICMSVVF := VVF->VVF_TOTICM
	      	      nBICMSVVG := VVG->VVG_VBAICM
	         	   nAICMSVVG := VVG->VVG_ALIICM
	            	nVICMSVVG := VVG->VVG_ICMCOM
	            	nVCustVVG := VVG->VVG_VCNVEI
	            /////////////////////////////////////


				dbSelectArea("SD1")
				dbSetOrder(1)
				if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
				   cNfiOri   := SD1->D1_DOC
				   cSerOri   := SD1->D1_SERIE
				   cIteNFOri := SD1->D1_ITEM
			      cIdeSB6   := SD1->D1_IDENTB6
				Endif

				cTraEnt := aIteBrw[x_,5]

				// Sai do FOR pois so pode haver 1 item selecionado
				Exit

         Endif
      Endif
   Next   
Endif

Else
// Consulta
			   dbSelectArea("VVF")
			   dbSetOrder(1)
			   if dbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
	
			      dbSelectArea("VVG")
				   dbSetOrder(1)
				   dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
			   
			      dbSelectArea("SA2")
				   dbSetOrder(1)
				   dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
				   		   
			      dbSelectArea("SA1")
			      dbSetOrder(1)
			      dbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
			
			      dbSelectArea("VV2")
			      dbSetOrder(1)
			      dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
			
			      dbSelectArea("VVC")
			      dbSetOrder(1)
			      dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)

			      dbSelectArea("VV1")
			      dbSetOrder(1)
			      dbSeek(xFilial("VV1")+VVG->VVG_CHAINT)
			      
			      cTxtCom := ""
			      Do Case
			         Case VV1->VV1_COMVEI == "0"
			              cTxtCom := STR0030	//Gasolina
			         Case VV1->VV1_COMVEI == "1"
			              cTxtCom := STR0031	//Alcool
			         Case VV1->VV1_COMVEI == "2"
			              cTxtCom := STR0032	//Diesel
			         Case VV1->VV1_COMVEI == "3"
			              cTxtCom := STR0033	//Gas Natural
			         Case VV1->VV1_COMVEI == "4"
			              cTxtCom := STR0072	//Gasolina/Alcool
			         Case VV1->VV1_COMVEI == "9"
			              cTxtCom := STR0034 	//Sem Combustivel
			      EndCase
			      cChave        := VV1->VV1_CHASSI
			      cMarca        := VV1->VV1_CODMAR
			      cModelo       := VV2->VV2_DESMOD
			      cProprietario := SA1->A1_NOME
			      cEstado       := if(VV1->VV1_ESTVEI=="0",STR0035,STR0036)//Novo - Usado
			      cCombustivel  := cTxtCom
			      cAnoModelo    := VV1->VV1_FABMOD
			      cCor          := VVC->VVC_DESCRI
			      
			      // Pega o Valor da Entrada do Veiculo
			      If cAuxTipo == "D"
				      if !Empty(VVF->VVF_TRACPA)
				         dbSelectArea("VVG")
				         dbSetOrder(1)
				         if dbSeek(xFilial("VVG")+VVF->VVF_TRACPA+VV1->VV1_CHAINT)                                                                    
				            nValVei := VVG->VVG_VALUNI-VVG->VVG_VALDES+VVG->VVG_TOTSEG+VVG->VVG_TOTFRE+VVG->VVG_DESACE+VVG->VVG_VALIPI+VVG->VVG_ICMRET+VVG->VVG_VALFRE         
				            nValEnt := VVG->VVG_VALUNI-VVG->VVG_VALDES+VVG->VVG_TOTSEG+VVG->VVG_TOTFRE+VVG->VVG_DESACE+VVG->VVG_VALIPI+VVG->VVG_ICMRET
				         Endif
				      Endif
				   Else
				         dbSelectArea("VVG")
				         dbSetOrder(1)
				         if dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)                                                                    
				            nValVei := VVG->VVG_VALUNI-VVG->VVG_VALDES+VVG->VVG_TOTSEG+VVG->VVG_TOTFRE+VVG->VVG_DESACE+VVG->VVG_VALIPI+VVG->VVG_ICMRET+VVG->VVG_VALFRE         
				            nValEnt := VVG->VVG_VALUNI-VVG->VVG_VALDES+VVG->VVG_TOTSEG+VVG->VVG_TOTFRE+VVG->VVG_DESACE+VVG->VVG_VALIPI+VVG->VVG_ICMRET
				         Endif
				   Endif   
						   
					cCliente  := VVF->VVF_CODFOR
					cLoja     := VVF->VVF_LOJA
					cNome     := SA2->A2_NOME
					cVendedor := VV0->VV0_CODVEN
			     dbSelectArea("SA3")
			     dbSetOrder(1)
			      if dbSeek(xFilial("SA3")+cVendedor)
			        cNVendedor := SA3->A3_NOME
			      Else
					  cNVendedor:= space(30)
					Endif
					cCodTes   := VVG->VVG_CODTES
					nValVei   := VVG->VVG_VALUNI
					cChave    := VVG->VVG_CHASSI
	            cTipoCli  := SA2->A2_TIPO
	            cForPg    := VVF->VVF_FORPAG
	
					dbSelectArea("SD1")
					dbSetOrder(1)
					if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
					   cNfiOri   := SD1->D1_DOC
					   cSerOri   := SD1->D1_SERIE
					   cIteNFOri := SD1->D1_ITEM
				      cIdeSB6   := SD1->D1_IDENTB6
					Endif
	         Endif
Endif	                                          

Return( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_SELCONS | Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para ver o tipo de saida de Consignado               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SELCONS(nPos)

Local i

For i:=1 to Len(aIteBrw)
   aIteBrw[i,1] := .f.
Next   

if aIteBrw[nPos,1]
   aIteBrw[nPos,1] := .f.
Else
   aIteBrw[nPos,1] := .t.
Endif
      
oLbHd2:SetArray(aIteBrw)
oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
aIteBrw[oLbHd2:nAt,2] ,;
aIteBrw[oLbHd2:nAt,3] ,;
FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,4],"@E 99,999,999.99")) ,;
aIteBrw[oLbHd2:nAt,5] ,;
aIteBrw[oLbHd2:nAt,6] ,;
aIteBrw[oLbHd2:nAt,7] ,;
aIteBrw[oLbHd2:nAt,8] }}

oLbHd2:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_V030LEG | Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Legenda para MBrowse                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_V030LEG()

Local aLegenda := {}

alegenda := {{'BR_VERDE'   ,STR0050},; 	//Remessa
             {'BR_AMARELO' ,STR0073},; 	//Retorno da Entrada de Consignado
             {'BR_PRETO'   ,STR0074}} 	//Veiculo Consignado Normal Retornado

BrwLegenda(cCadastro,STR0005 ,aLegenda) //Legenda

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_CANCONS | Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Cancelamento de Consignado                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCONS()

Local lRet := .t.
Local aRegSD2 := {}
Local aRegSE1 := {}
Local aRegSE2 := {}

Private cNumTit := ""
Private lMsHelpAuto := .t.
Private lMsErroAuto := .f.
Private cAuxTipo       := if(VV0->VV0_OPEMOV == "5","N","D")

cTipSai := if(VV0->VV0_OPEMOV == "5","5","7") //Consignado ou Ret. de Consignado

if cAuxTipo <> "D" // Devolucao
   if VV0->VV0_SITNFI == "2"  // Devolvida
      MsgInfo(STR0053,STR0028) //Este veiculo ja foi Devolvido... - Atencao!
      Return( .f. )
   Endif
   if VV0->VV0_SITNFI == "0"  // Cancelado
      MsgInfo(STR0054,STR0028) //Este veiculo ja foi Cancelado... - Atencao!
      Return( .f. )
   Endif
Endif   

if !MsgYesNo(STR0055,STR0028) //Confirma Cancelamento de Consignado? - Atencao!
   lRet := .f.
Endif
   
if lRet
	Begin Transaction
	
	   dbSelectArea("VVA")
	   dbSetOrder(1)
	   dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)

	   dbSelectArea("VV1")
	   dbSetOrder(1)
	   dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)

		//Exclusao da Nota Fiscal
		aMata520Cab   := {{"F2_DOC"  ,VV0->VV0_NUMNFI ,Nil},; //Numero da nota
                        {"F2_SERIE",VV0->VV0_SERNFI ,Nil}}  //Serie


		dbSelectArea("SF2")
		dbSetOrder(1)
		If dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o estorno do documento de saída pode ser feito     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
			   /*Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2, Array com os registro do SE1, Array com os registro do SE2 ) */
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Estorna o documento de saida                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
				PERGUNTE("MTA521",.f.)
				SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
			Else
				//Nao pode ser excluida.
				lMsErroAuto:= .T.
			   Return(.f.)
			EndIf    
		Endif
	
	   /*
		MSExecAuto({|x| Mata520(x)},aMata520Cab)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		*/
		
		//Cancela a Liberacao
		SC9->(DbSetOrder(1))
		SC9->(DbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
		While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
			SC9->(a460Estorna())
			SC9->(dbSkip())
		EndDo
		
		//Exclusao do Pedido
		aMata410Cab   := {{"C5_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do pedido SC5
		aMata410Itens := {{"C6_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do Pedido SC6

		MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
		dbSetOrder(1)
		//
		FM_LOCVZL(1)
		FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
		//
		dbSelectArea("VV1")
		RecLock("VV1",.f.)
		VV1->VV1_NUMTRA := Space(10)
		if cAuxTipo == "N" // Normal
			VV1->VV1_SITVEI := "0"
		Else
			VV1->VV1_SITVEI := "4"
		Endif
		MsUnlock()

      // Volta Estado Anterior da NF de Entrada Qdo Devolucao
      if cAuxTipo == "D" // Devolucao
	  		dbSelectArea("VVF")
			dbSetOrder(1)
			dbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
			RecLock("VVF",.f.)
			VVF->VVF_SITNFI := "1"    //Valida
			VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
			MsUnlock()
      Endif
		
      // Atualiza Arquivo da Saida de Consignacao de Veiculos
		dbSelectArea("VV0")
		RecLock("VV0",.f.)
  		VV0->VV0_SITNFI := "0" // Cancelada
		VV0->VV0_DATUSU := DtoS(dDataBase)+"-"+__cUserID
		VV0->VV0_NUMPED := ""
		VV0->VV0_NUMNFI := ""
		VV0->VV0_SERNFI := ""
		MsUnlock()

		dbSelectArea("VVA")
		RecLock("VVA",.f.)
		VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
		MsUnlock()
		
	End Transaction
Endif	

If lMsErroAuto
	MostraErro()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ALIICMS³ Autor ³ Andre                 ³ Data ³ 11/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda aliquota de ICMS dependendo do estado do cliente p/    ³±±
±±³          ³veiculos novos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALIICMS(cCodB1)

Local aAreaSB1 := GetArea("SB1")
//Local nAliq    := 0 //Consignado nao tem ICMS

dbSelectArea("SB1")
dbSetOrder(1)
if dbSeek(xFilial("SB1")+cCodB1)
   RecLock("SB1",.f.)
// SB1->B1_PICM := nAliq      // FCN 7542 - BOBY - TES INTELIGENTE PREENCHE AUTOMATICAMENTE NA B1 
   MsUnlock()
Endif

SB1->(RestArea(aAreaSB1))

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_PESQ    ³ Autor ³ Manoel Filho     ³ Data ³12/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Pesquisa nos Arquivos (Com UPPER quando caracter)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Geral			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PESQ()
 cSavArea  := Alias()                        
 cSavInd   := IndexOrd()
 aIndFil   := {} 
 cChaveSel := space(100)
 cIndSel   := space(100) 
 
 DBSelectArea("SIX")
 DBSeek(cSavArea)   
 cNumOrd := 1
 While !Eof() .and. indice == cSavArea
  AADD(aIndFil,StrZero(cNumOrd++,2)+". "+Descricao)
  DBSkip()
 Enddo                 
 
 DEFINE MSDIALOG oDlgP TITLE OemToAnsi(STR0001) From 5,14 to 11,76 of oMainWnd  // Pesquisar
 
 @ 011,004 MSCOMBOBOX oPesq1 VAR cIndSel SIZE 200,9 COLOR CLR_BLACK;
           ITEMS aIndFil OF oDlgP PIXEL
              
 @ 024,004 MSGet oPesq2 var cChaveSel PICTURE "@!" size 200,9 OF oDlgP PIXEL COLOR CLR_BLACK 
 
 DEFINE SBUTTON FROM 011,209 TYPE 1 ACTION (FS_Pesq2(),oDlgP:End()) ENABLE OF oDlgP
 DEFINE SBUTTON FROM 024,209 TYPE 2 ACTION (oDlgP:End()) ENABLE OF oDlgP
 
 ACTIVATE MSDIALOG oDlgP CENTERED
Return                     
 
Static Function FS_Pesq2()                                           
 DBSelectArea(cSavArea)
 nOrdAnt := IndexOrd()
 DBSetOrder(Val(Subs(cIndSel,1,2)))
 DbSeek(xFilial(cSavArea) + Alltrim(cChaveSel)) 
 If Len(aIndFil) < nOrdAnt
  DBSetOrder(nOrdAnt)
 Endif   
 DbSetOrder(cSavInd)
Return
 
Static Function MenuDef()
Local aRotina := {{OemtoAnsi(STR0001),"AxPesqui", 0 ,1},;					//Pesquisar
						{OemtoAnsi(STR0002),"FS_CONSIGN", 0, 2},;			//Consultar
						{OemtoAnsi(STR0003),"FS_CONSIGN", 0, 3},;			//Incluir
						{OemtoAnsi(STR0004),"FS_CANCONS", 0, 4},;			//Cancelar
						{OemtoAnsi(STR0005),"FS_V030LEG", 0, 0 ,2,.f.},; 	//Legenda
						{ STR0075	  	   ,"VM030_LVEI" , 0 , 2}}   		//Pesquisa Chassi
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM030_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 10/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM030_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )
Private oAmar := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oPret := LoadBitmap( GetResources() , "BR_PRETO" )
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
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0076) FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
	@ 003,004 SAY STR0077 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE //Veiculo:
  	@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
 	@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0078) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
	@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
																OemToAnsi(STR0079),;//Filial
																OemToAnsi(STR0080),;//Dt.Movimento
																OemToAnsi(STR0081),;//NF/Serie
																OemToAnsi(STR0082),;//Valor
																OemToAnsi(STR0083);//Cliente
																COLSIZES 10,35,37,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="31",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="61",oAmar,oPret)),;
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
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_OPEMOV, VV0.VV0_SITNFI , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
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
 	cQuery += "VV0.VV0_OPEMOV IN ('5','7') AND VV0.VV0_SITNFI<>'0' AND VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV"

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
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_OPEMOV ) + ( cQAlVV0 )->( VV0_SITNFI ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+( cQAlVV0 )->( VV0_SERNFI ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0084+" "+cLevChas,STR0028)//Nenhuma Saida de Veiculo Consignado para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq) 
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="51",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="71",oAmar,oPret)),;
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