#include "VEIVM012.CH"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM012 ³ Autor ³ ANDRE                 ³ Data ³ 10/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Caixa de veiculos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM012

Local oFolder      
Local aIndVV9   := {}
Local cCondicao := ""
Private bFiltraBrw := {|| Nil}
Private aCampos    := {}
Private cCadastro  := OemToAnsi(STR0001) //Caixa de veiculos
Private aRotina := MenuDef()

Private lMudouNum := .f.

#IFDEF TOP
	dbSelectArea("VV9")
	set filter to
	dbSelectArea("VV0")
	set filter to
	dbSelectArea("VVA")
	set filter to
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV9")
RetIndex()
dbSetOrder(1)

cCondicao  := "VV9->VV9_STATUS $ 'P/T/F/O/L'"

bFiltraBrw := {|| FilBrowse("VV9",@aIndVV9,@cCondicao) }
Eval(bFiltraBrw)

aCores := {{'VV9->VV9_STATUS == "A" .AND. VM011VEIVD()','lbok_ocean'},;
		   {'VV9->VV9_STATUS == "A"','BR_VERDE'},;
           {'VV9->VV9_STATUS == "F"','BR_PRETO'},;
           {'VV9->VV9_STATUS == "P"','BR_AMARELO'},;
           {'VV9->VV9_STATUS == "R"','BR_LARANJA'},;
           {'VV9->VV9_STATUS == "O"','BR_BRANCO'},;
           {'VV9->VV9_STATUS == "L"','BR_AZUL'},;
           {'VV9->VV9_STATUS == "C"','BR_VERMELHO'}}

mBrowse( 6, 1,22,75,"VV9",,,,,,aCores)

dbSelectArea("VV9")
RetIndex("VV9")
dbClearFilter()
aEval(aIndVV9,{|x| Ferase(x[1]+OrdBagExt())})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CAIXA012     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa o processo de atendimento                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAIXA012(cAlias, nReg, nOpc)

Local cont, nIC, nC
Local cStr1    := ""
Local cStr2    := ""
Local lInclui  := Inclui
Local bCampo   := { |nCPO| Field(nCPO) }
Local nOpca    := 0
Local aPriEnc  := {}
Local aSegEnc  := {}
Local aTerEnc  := {}
Local aQuaEnc  := {}
Local aQuiEnc  := {}
Local aSexEnc  := {}
Local aSetEnc  := {}                                      													
Local aTitles  := {OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008)}	//Renegociar - Valores - Acessorios - Campanha - Diversos - Negociacao - Recebimento

Private oFoto    := LoadBitmap( GetResources(), "MAQFOTO" )
Private oNada    := LoadBitmap( GetResources(), "NADA" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAmarelo := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oAzul    := LoadBitmap( GetResources(), "BR_AZUL" )
Private oGratis  := LoadBitmap( GetResources(), "bpmstask1" )
Private oChecked := LoadBitmap( GetResources(), "checked" )

Private cMotivo  := "000004"  //Filtro da consulta do motivo
Private cTipAva  := "1" //Veiculos
Private cCpoDiv  := "    1"
Private aStru    := {}
Private aErrAva  := {}
Private cSimVda  := "V"
Private cMoedCor := cOutMoed := GetMv("MV_SIMB1")
Private cSimOMoe := 1
Private cTipOpe  := 3   //Veiculos
Private nTamNota := 9
Private lExclui  := nOpc == 5
Private lAutFat  := .t.
Private lPedApr  := .t.
Private lFatura  := .t.
Private lJaFiltro:= .f.
Private lJaPer012:= !Inclui
Private lJaGravou:= !Inclui
Private lJaCal012:= !Inclui
Private lEmiNfi  := .t.
Private lNegPag  := .t.
Private lLibVei  := .f.
Private cNota    := cNumero := ""
Private cSerie   := ""
Private cChaRes  := ""
Private aStruVV1 := {}
Private aKits    := {}
Private aAcessor := {}
Private aCorM    := {}
Private aCorP    := {}
Private cGruVei  := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private cPrefixo := GetNewPar("MV_PREFVEI","VEI")
Private aIteParc := {}
Private aIteParB := {}
Private aIteEnt  := {}
Private aAlter   := {}
Private nSeqPro  := 1
Private cPrefNF  := "   "
Private nTitDif  := 0
Private cFilSelVV1 := xFilial("VV1")
Private cTipPag1 := "VV0_FORPAG"
Private oTipPag, oDesPag, oDesBco, oCodBco
Private cCondic1 := ctod(" ")
Private cCondic2 := space(02)
Private cCondic3 := space(02)
Private cCondic4 := space(02)
Private cCondic5 := "1"
Private lTroco   := .f.
Private aMarca   := {}
Private aGener   := {}
Private aEspec   := {}
Private cCodMar  := Space(3)
Private cGruMod  := Space(06)
Private cModVei  := Space(10)
Private cGruCor  := Space(02)
Private cCor     := Space(6)
Private cCombus  := ""
Private cTipCor  := ""
Private nAnoIni  := 0
Private nAnoFin  := 0
Private nValFxI  := 0
Private nValFxF  := 0
Private nKMFxa   := 0
Private cEstVeiF := ""
Private lSelect  := .f.
Private nAcessor := 0
Private nTotalEnt:= 0
Private nTotEntr := 0
Private aColsC   := {}
Private aHeaderC := {}
Private aHeaderIC:= {}
Private aColsIC  := {}
Private aHeaderTC:= {}
Private aColsTC  := {}
Private aHeaderAG:= {}
Private aColsAG  := {}
Private aGravaEnt:= {}
Private cLinOk   := "AllwaysTrue()"
Private cTudoOk  := "AllwaysTrue()"
Private cFieldOk := "FG_DADOSENT(M->VV0_VALTOT,3),FS_CALC012()"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de atendimento ao cliente                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV9")
While x3_arquivo == "VV9" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV9_NOMVIS/VV9_DATVIS/VV9_TELVIS/VV9_TIPMID/VV9_OBSMEM/VV9_OBSERV"+;
	   "VV9_CODCLI/VV9_LOJA"
		AADD(aPriEnc,x3_campo)
	Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

if !Inclui
	dbSelectArea("VV9")
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	dbSelectarea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+M->VV9_NUMATE)
	dbSelectarea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+M->VV9_NUMATE)
	M->VV0_CODTES := VVA->VVA_CODTES
Endif	

If ExistBlock("CAMPOSVEI1")
	cStr1 := ExecBlock("CAMPOSVEI1",.f.,.f.)
	if Type("cStr1") <> "C"
	   cStr1 := ""
	Endif   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atendimento ao cliente                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ cStr1+"VV0_CHASSI/VV0_CODMAR/VV0_DESMAR/VV0_GRUMOD/VV0_DESGRU/VV0_MODVEI/VV0_DESMOD/VV0_CORVEI/VV0_DESCOR/VV0_FABMOD/"+;
	   "VV0_PLAVEI/VV0_CODVEN/VV0_NOMVEN/VV0_VALMOV/VV0_ACESSO/VV0_VALCOR/VV0_PERDES/VV0_VALDES/VV0_VALTOT/VV0_FORPAG/VV0_DESFPG/VV0_RESERV/VV0_DATVAL/VV0_HORVAL"
		AADD(aSegEnc,x3_campo)
	Endif
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. x3_campo $ "VV0_VALMOV/VV0_ACESSO/VV0_VALDES/VV0_VALTOT/VV0_TOTENT/VV0_VALFIN/VV0_AGREGA/VV0_VALRES/VV0_VALTRO/VV0_IMPOST"
		AADD(aQuiEnc,x3_campo)
	Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
While x3_arquivo == "VVA" .and. !eof()
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campanha promocional                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VZ7")
nUsadoIC:=0
While !Eof().And.(x3_arquivo=="VZ7")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VZ7_CODACV/VZ7_ITECAM/VZ7_VALITE"
		nUsadoIC:=nUsadoIC+1
		Aadd(aHeaderIC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )		
		wVar  := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
Enddo

aColsIC:={}
aColsIC:={Array(nUsadoIC+1)}
aColsIC[1,nUsadoIC+1]:=.F.
For cont:=1 to nUsadoIC
	aColsIC[1,cont]:=CriaVar(aHeaderIC[cont,2])
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Negociacao de pagamento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV0_FORPAG/VV0_DESFPG/VV0_CODBCO/VV0_CODAGE/VV0_AGEFIN/"+;
	   "VV0_DATINI/VV0_DIA1PC/VV0_PARCEL/VV0_INTERV/VV0_FIXDIA/VV0_DIAFIX/VV0_TXAFIN/VV0_COEFIC/VV0_PTXRET/VV0_VTXRET/VV0_PCUSFN/"+;
	   "VV0_VCUSFN/VV0_PCOMFN/VV0_VCOMFN/VV0_TIPFIN"
		AADD(aTerEnc,x3_campo)
      wVar := "M->"+x3_campo
      &wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

If ExistBlock("CAMPOSVEI2")
	cStr2 := ExecBlock("CAMPOSVEI2",.f.,.f.)
	if Type("cStr2") <> "C"
	   cStr2 := ""
	Endif   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Outros dados para o atendimento de venda                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
While x3_arquivo == "VVA" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VVA_REDCUS/VVA_DATRCU/VVA_BONFAB/VVA_BONREG/VVA_BONCON/VVA_DATBFB/VVA_DESCLI/VVA_DATDCL/VVA_RECTEC/VVA_DATRTC/VVA_INPICO/"+;
	   "VVA_INPCRT/VVA_INPCBF/VVA_INISRT/VVA_INISBF/VVA_VALFRE/VVA_VALREV/VVA_DESVEI/VVA_VALREV/VVA_ASSIMP/VVA_DESFIX/VVA_DSPFIN"
		AADD(aSetEnc,x3_campo)
	Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finalizacao da venda                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. x3_campo $ cStr2+"VV0_CODTES/VV0_VBAICM/VV0_ALIICM/VV0_TOTICM/VV0_DESACE/"+;
	   "VV0_CODAVA/VV0_LOJAAV/VV0_NOMAVA/VV0_CBCOAA/VV0_ABCOAA/VV0_NBCOAA/VV0_TIPVEN/VV0_DESTVD/"+;
	   "VV0_CATVEN"   ///VV0_VALMOV/VV0_VALDES/VV0_VALTOT/VV0_ACESSO
//	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. x3_campo $ cStr2+"VV0_CODTES/VV0_VBAICM/VV0_ALIICM/VV0_TOTICM/VV0_DESACE/"+;
//	   "VV0_ACESSO/VV0_CODAVA/VV0_LOJAAV/VV0_NOMAVA/VV0_CATVEN/VV0_CBCOAA/VV0_ABCOAA/VV0_NBCOAA/VV0_VALMOV/VV0_VALDES/VV0_VALTOT/VV0_TIPVEN/VV0_DESTVD/"
		AADD(aQuaEnc,x3_campo)
      wVar := "M->"+x3_campo
      &wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

if !Inclui
	dbSelectArea("VV0")
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Negociacao de pagamentos da entrada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
dbSelectArea("SX3")
dbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
   If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR")
      nUsadoC++
      Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
      x3_tamanho, x3_decimal,x3_valid,;
      x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      wVar := "M->"+x3_campo
      &wVar := CriaVar(x3_campo)
   Endif
   dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for alteracao traz valores digitados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Inclui
	dbSelectArea("VS9")
	dbSetOrder(1)
	if dbSeek(xFilial("VS9")+M->VV9_NUMATE+"V")
		While !Eof() .and. VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VV0->VV0_NUMTRA+'V'
			If VS9->VS9_TIPPAG == "DP"  //Duplicata
				aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
				aAdd(aIteParB, {!Empty(VS9->VS9_DATBAI),VS9->VS9_DATPAG,VS9->VS9_VALPAG,VS9->VS9_TIPTIT == "0" })
				if !Empty(VS9->VS9_REFPAG)
					M->VV0_DATINI := cTod(Substr(VS9->VS9_REFPAG,01,08))
					M->VV0_DIA1PC := Substr(VS9->VS9_REFPAG,09,02)
					M->VV0_PARCEL := Substr(VS9->VS9_REFPAG,11,02)
					M->VV0_INTERV := Substr(VS9->VS9_REFPAG,13,02)
				Endif
			Else
            AADD(aIteEnt,{!Empty(VS9->VS9_DATBAI),VS9->VS9_TIPPAG,VS9->VS9_DESPAG,VS9->VS9_DATPAG,VS9->VS9_VALPAG,VS9->VS9_TIPTIT == "0",VS9->VS9_SEQUEN})
				AADD(aColsC,Array(nUsadoC+1))
				For cont := 1 to nUsadoC
					aColsC[Len(aColsC),cont]:=If(aHeaderC[cont,10] # "V",FieldGet(FieldPos(aHeaderC[cont,2])),CriaVar(aHeaderC[cont,2]))
				Next
				aColsC[Len(aColsC),nUsadoC+1]:=.F.
            nTotalEnt := nTotalEnt + VS9->VS9_VALPAG
            nTotEntr  := nTotEntr + VS9->VS9_VALPAG
            M->VV0_TOTENT := nTotalEnt
			Endif
			if !Empty(VS9->VS9_SEQPRO)
				nSeqPro := Val(VS9->VS9_SEQPRO)
			Else
			   nSeqPro += 1
			Endif	
			dbSkip()
		Enddo
	Endif
Endif

if Len(aColsC) == 0
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For cont:=1 to nUsadoC
	    aColsC[1,cont]:=CriaVar(aHeaderC[cont,2])
	Next
Endif	

if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
	aIteParB := {{.f.,cTod(""),0,.f.}}
Endif

if Len(aIteEnt) == 0
	aIteEnt := {{.f.,"","",cTod(""),0,.f.,""}}
Endif

AAGET012(aHeaderC,aColsC)

FS_VEND011()

//Traz o TES padrao para esta operacao de saida (S) normal (N)
dbSelectArea("VZA")
dbSetOrder(1)
if dbSeek(xFilial("VZA")+"SN"+iif( Inclui, "0",VV1->VV1_ESTVEI) )
   if Empty(M->VV0_CODTES)
      M->VV0_CODTES := VZA->VZA_CODTES
   Endif   
Endif

dbSelectarea("VV1")
dbSetOrder(1)
dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
dbSelectarea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGruVei+VVA->VVA_CHAINT)
cCadastro := OemToAnsi(STR0001)+"  ["+VV9->VV9_NUMATE+"]" //Caixa de veiculos

DEFINE MSDIALOG oDlgAtend TITLE cCadastro FROM  4.5,0 To 36.5,80 OF oMainWnd

	aSvtela  := {{},{},{},{},{},{},{},{},{}}
	aSvGets  := {{},{},{},{},{},{},{},{},{}}
   
	@ 048,001 FOLDER oFolder012 SIZE 315,182 OF oDlgAtend PROMPTS aTitles[1],aTitles[2],aTitles[3],aTitles[4],aTitles[5],aTitles[6],aTitles[7] PIXEL
	FG_INIFOLDER("oFolder012")
	oFolder012:bChange    := {||  BOTOES012()  } // Executa na mudanca da aba
	oFolder012:bSetOption := {|x| .t.    }       // Validacao na saida da aba

   oFolder012:noption := 6

   //Tela de informacoes do cliente
	aTela    := {}
	aGets    := {}
	dbSelectArea("VV9")
	Zero()
	oGetMGet1:= MsMGet():New("VV9",0,4,,,,aPriEnc,{014,001,060,316},,2,,,,oDlgAtend,,.T.,.F.,"aSvTela[1]")
	oGetMGet1:oBox:bGotFocus   := {|| AL_Entra(1,"VV9")}
	oGetMGet1:oBox:bLostFocus  := {|| AL_Sai(1)}
	aSvTela[1] := aClone(aTela)
	aSvGets[1] := aClone(aGets)
   Inclui := lInclui

   //Tela de valores do atendimento
	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}
	oGetMGet2:= MsMGet():New("VV0",0,2,,,,aSegEnc,{000,000,170,315},,2,,,,oFolder012:aDialogs[2],,.T.,.F.,"aSvTela[2]")
	oGetMGet2:oBox:bGotFocus   := {|| AL_Entra(2,"VV0")}
	oGetMGet2:oBox:bLostFocus  := {|| AL_Sai(2)}
	aSvTela[2] := aClone(aTela)
	aSvGets[2] := aClone(aGets)
   Inclui := lInclui

	MENU oMenu POPUP 
		MENUITEM STR0009         Action (lFechaDlg := .f.,STATUS011("O",.t.),iif(lFechaDlg,oDlgAtend:End(),.f.))	//Pre-Aprovar
		MENUITEM STR0010         Action (lFechaDlg := .f.,STATUS011("L",.t.),iif(lFechaDlg,oDlgAtend:End(),.f.))	//Aprovar Fat
 		MENUITEM STR0011            Action (ENCERRA011(2),iif(!empty(M->VV9_MOTIVO),oDlgAtend:End(),.t.)) .and. STATUS011("R",.t.)	//Reprovar
		MENUITEM STR0012            Action STATUS011("A",.t.)	//Reativar
		MENUITEM STR0013       Action (ENCERRA011(2),iif(!empty(M->VV9_MOTIVO),oDlgAtend:End(),.t.))	//Cancela Venda
 		MENUITEM STR0014     Action (CANRES011())	//Cancela Reserva
		MENUITEM STR0015            Action (oFolder012:noption := 1,AAGET012())	//Negociar
		MENUITEM STR0016           Action AVARES011()	//Avaliacao
		MENUITEM STR0017            Action FS_CLI011()	//Clientes
		MENUITEM STR0018    Action (oFolder012:noption := 3)	//Acessorios / Cor
		MENUITEM STR0005            Action (oFolder012:noption := 4)	//Campanha
		MENUITEM STR0019  Action (oFolder012:noption := 5)	//Outras Informacoes
		MENUITEM STR0021 Action FS_VALMIN()	//Valores Negociacao
	ENDMENU

 	@ 228,010 BUTTON oOpcoes  PROMPT OemToAnsi(STR0022)         OF oDlgAtend SIZE 43,11 PIXEL ACTION OPCOES012( oOpcoes, 2, -160, oMenu )//Opcoes
 	@ 228,060 BUTTON oCalcula PROMPT OemToAnsi(STR0023)       OF oDlgAtend SIZE 43,11 PIXEL ACTION FS_CALC012() //Calcular

 	@ 228,215 BUTTON oVoltar  PROMPT OemToAnsi(STR0024)      OF oDlgAtend SIZE 43,11 PIXEL ACTION VOLTAR012()  //<< Voltar
 	@ 228,265 BUTTON oAvancar PROMPT OemToAnsi(STR0025)     OF oDlgAtend SIZE 43,11 PIXEL ACTION AVANCA012()  //Avancar >>

   //if !lEmiNfi
   //   oAvancar:cCaption := "Finalizar"
  // Endif   

   oCalcula:lVisible := .f.

   //Tela de acessorios
	@ 001,001 LISTBOX oLboxAce FIELDS HEADER;
	OemToAnsi(""),;          //Indicador de selecao
	OemToAnsi(STR0026),;        //Indica se o veiculo tem foto cadastrada
	OemToAnsi(STR0027),; //Descricao do acessorio
	OemToAnsi(STR0028);      //Valor do acessorio
	COLSIZES 5,5,80,50;
	SIZE 200,130 OF oFolder012:aDialogs[3] PIXEL
	
	if len(aAcessor) == 0
   	aAdd(aAcessor, { .f.," ",0,"",.f.,.f. } )
	Endif
			
	oLboxAce:SetArray(aAcessor)

	oLboxAce:bLine := { || { if(aAcessor[oLboxAce:nAt,01] == .f.,oNo,iif(aAcessor[oLboxAce:nAt,06],oChecked,oTik)),;
   							     aAcessor[oLboxAce:nAt,02],;
								     FG_AlinVlrs(Transform(aAcessor[oLboxAce:nAt,03],"9,999,999.99")),;
   							     if(aAcessor[oLboxAce:nAt,05] == .f.,oNada,oGratis) }}
 
   //Cores Metalicas
	@ 001,204 LISTBOX oLboxCorM FIELDS HEADER;
	OemToAnsi(""),;             //Indicador de selecao
	OemToAnsi(STR0029),;  		//Cor
	OemToAnsi(STR0028);         //Valor da cor
	COLSIZES 5,40,45;
	SIZE 108,062 OF oFolder012:aDialogs[3] PIXEL
	
	if len(aCorM) == 0
   	aAdd(aCorM, { .f.," ",0 } )
	Endif
			
	oLboxCorM:SetArray(aCorM)
	oLboxCorM:bLine := { || { if(aCorM[oLboxCorM:nAt,01] == .f.,oNo,oTik),;
	   								aCorM[oLboxCorM:nAt,02],;
		   							FG_AlinVlrs(Transform(aCorM[oLboxCorM:nAt,03],"9,999,999.99")),} }

   //Cores Perolizadas
	@ 068,204 LISTBOX oLboxCorP FIELDS HEADER;
	OemToAnsi(""),;                	//Indicador de selecao
	OemToAnsi(STR0030),;  			//Cor
	OemToAnsi(STR0028);            	//Valor da cor
	COLSIZES 5,40,45;
	SIZE 108,062 OF oFolder012:aDialogs[3] PIXEL
	
	if len(aCorP) == 0
   	aAdd(aCorP, { .f.," ",0 } )
	Endif
			
	oLboxCorP:SetArray(aCorM)
	oLboxCorP:bLine := { || { if(aCorP[oLboxCorP:nAt,01] == .f.,oNo,oTik),;
	   								aCorP[oLboxCorP:nAt,02],;
		   							FG_AlinVlrs(Transform(aCorP[oLboxCorP:nAt,03],"9,999,999.99")),} }

   //Campanha promocional
	aHeader  := aClone(aHeaderIC)
	aCols    := aClone(aColsIC)
	oGetDadosIC:= MsGetDados():New(01,1,182,315,nOpc,cLinOk,cTudoOk,"",.T.,,,,,'FS_ITECAM("A")',,,,oFolder012:aDialogs[4])
	oGetDadosIC:oBrowse:default()
	oGetDadosIC:oBrowse:bChange      := {|| FS_ITECAM("A"), oGetDadosIC:oBrowse:Refresh()  }
	oGetDadosIC:oBrowse:bDelete      := {|| FS_ITECAM("D"),if(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.), oGetDadosIC:oBrowse:Refresh() }

   //Outros valores do atendimento
	dbSelectArea("VVA")
	aTela    := {}
	aGets    := {}
	Zero()
	oGetOut:= MsMGet():New("VVA",0,nOpc,,,,aSetEnc,{000,000,142,315},,2,,,,oFolder012:aDialogs[5],,.T.,.F.,"aSvTela[7]")
	aSvTela[7] := aClone(aTela)
	aSvGets[7] := aClone(aGets)

   //Negociacao de pagamento
	MENU oMenuB1 POPUP 
		MENUITEM STR0031 Action RECEB012(oLbEnt,"E",aIteEnt[oLbEnt:nAt,2],aIteEnt[oLbEnt:nAt,4],aIteEnt[oLbEnt:nAt,5])//Definitivo
		MENUITEM STR0032 Action BAIXA012(oLbEnt,"E",aIteEnt[oLbEnt:nAt,2],aIteEnt[oLbEnt:nAt,4],aIteEnt[oLbEnt:nAt,5])//Baixar
		MENUITEM STR0033 Action ESTORNO012(oLbEnt,"E",aIteEnt[oLbEnt:nAt,2],aIteEnt[oLbEnt:nAt,4],aIteEnt[oLbEnt:nAt,5])//Estornar
		MENUITEM STR0034 Action FS_TRF012()//Transferir
		MENUITEM STR0035 Action .t.//Detalhes (Entrada)
	ENDMENU
	oMenuB1:cName := "B1"

	MENU oMenuB2 POPUP 
		MENUITEM STR0031 Action RECEB012(oLbParB,"F","DP ",aIteParB[oLbParB:nAt,2],aIteParB[oLbParB:nAt,3])//Definitivo
		MENUITEM STR0032 Action BAIXA012(oLbParB,"F","DP ",aIteParB[oLbParB:nAt,2],aIteParB[oLbParB:nAt,3])//Baixar
		MENUITEM STR0033 Action ESTORNO012(oLbParB,"F","DP ",aIteParB[oLbParB:nAt,2],aIteParB[oLbParB:nAt,3])//Estornar
		MENUITEM STR0034 Action FS_TRF012()//Transferir
	ENDMENU
	oMenuB2:cName := "B2"

	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}
	oGetMGet5:= MsMGet():New("VV0",0,2,,,,aQuiEnc,{001,001,168,092},,2,,,,oFolder012:aDialogs[6],,.T.,.T.,"aSvTela[5]")
	oGetMGet5:oBox:bGotFocus   := {|| AL_Entra(5,"VV0")}
	oGetMGet5:oBox:bLostFocus  := {|| AL_Sai(5)}
	aSvTela[5] := aClone(aTela)
	aSvGets[5] := aClone(aGets)
   Inclui := lInclui

	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}
	oGetMGet3:= MsMGet():New("VV0",0,1,,,,aTerEnc,{001,093,109,207},,2,,,,oFolder012:aDialogs[6],,.T.,.T.,"aSvTela[3]")
	oGetMGet3:oBox:bGotFocus   := {|| AL_Entra(3,"VV0")}
	oGetMGet3:oBox:bLostFocus  := {|| AL_Sai(3)}
	aSvTela[3] := aClone(aTela)
	aSvGets[3] := aClone(aGets)
   Inclui := lInclui

	@ 001, 208 LISTBOX oLbParB FIELDS HEADER  OemToAnsi(""),OemToAnsi(STR0036),OemToAnsi(STR0028); //Data - Valor
	COLSIZES 10,40,50;
	SIZE 105,105 OF oFolder012:aDialogs[6] PIXEL ON DBLCLICK MENU012( oLbParB, 2, -5, oMenuB2, oLbParB,"DP " )
	oLbParB:SetArray(aIteParB)
	oLbParB:bLine := { || { if(aIteParB[oLbParB:nAt,4],oAmarelo,if(aIteParB[oLbParB:nAt,1] == .t.,oVerde,oVermelho)),;
                       	dToc(aIteParB[oLbParB:nAt,2]),;
						  Transform(aIteParB[oLbParB:nAt,3],"@E 999,999,999.99")}}
                                                                                          
	@ 110, 092 LISTBOX oLbEnt FIELDS HEADER  OemToAnsi(""),OemToAnsi(STR0037),OemToAnsi(STR0027),OemToAnsi(STR0036),OemToAnsi(STR0028); //Tipo - Descricao - Data - Valor
	COLSIZES 10,30,100,40,50;
	SIZE 308,060 OF oFolder012:aDialogs[6] PIXEL ON DBLCLICK MENU012( oLbEnt, 2, -5, oMenuB1, oLbEnt,aIteEnt[oLbEnt:nAt,2] )
	oLbEnt:SetArray(aIteEnt)
	oLbEnt:bLine := { || { iif(aIteEnt[oLbEnt:nAt,6],oAmarelo,if(aIteEnt[oLbEnt:nAt,1] == .t.,oVerde,if(aIteEnt[oLbEnt:nAt,6],oAmarelo,oVermelho))),;
                       	      aIteEnt[oLbEnt:nAt,2],;
                       	      aIteEnt[oLbEnt:nAt,3],;
                       	dToc(aIteEnt[oLbEnt:nAt,4]),;
						  Transform(aIteEnt[oLbEnt:nAt,5],"@E 999,999,999.99")}}

   //Renegociacao dos pagamentos
	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}
	oGetMGet7:= MsMGet():New("VV0",0,2,,,,aQuiEnc,{001,001,078,092},,2,,,,oFolder012:aDialogs[1],,.T.,.T.,"aSvTela[5]")
	oGetMGet7:oBox:bGotFocus   := {|| AL_Entra(5,"VV0")}
	oGetMGet7:oBox:bLostFocus  := {|| AL_Sai(5)}
	aSvTela[5] := aClone(aTela)
	aSvGets[5] := aClone(aGets)
   Inclui := lInclui

	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}
	oGetMGet8:= MsMGet():New("VV0",0,nOpc,,,,aTerEnc,{001,093,078,205},,2,,,,oFolder012:aDialogs[1],,.T.,.T.,"aSvTela[8]")
	oGetMGet8:oBox:bGotFocus   := {|| AL_Entra(8,"VV0")}
	oGetMGet8:oBox:bLostFocus  := {|| AL_Sai(8)}
	aSvTela[8] := aClone(aTela)
	aSvGets[8] := aClone(aGets)
   
	@ 001, 206 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0036),OemToAnsi(STR0028); //Data - Valor
	COLSIZES 10,40,50;
	SIZE 105,077 OF oFolder012:aDialogs[1] PIXEL ON DBLCLICK FG_ALTFINAN(oLbParc:nAt)
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || {	dToc(aIteParc[oLbParc:nAt,1]),;
						  Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}

   nLinhas  := 99
	aHeader  := aClone(aHeaderC)
	aCols    := aClone(aColsC)
	oGetCondicao:= MsGetDados():New(080,001,130,312,nOpc,cLinOk,cTudoOk,"",If(nOpc > 2 .and. nOpc < 5,.t.,.f.),aAlter[n],,,nLinhas,cFieldOk,,,,oFolder012:aDialogs[1])
	oGetCondicao:oBrowse:Default()
	oGetCondicao:oBrowse:bChange     := {|| AAGET012(), AALTER012(n), FG_MEMVAR(), lSalvou := .f. }
   oGetCondicao:oBrowse:bEditCol    := {|| FG_TOTENT(.T.),if(!Empty(aCols[n,FG_POSVAR("VS9_TIPPAG")]),aCols[n,FG_POSVAR("VS9_DESPAG")] := VSA->VSA_DESPAG,.t.),M->VV0_TOTENT := nTotalEnt,FS_CALC012(),lSalvou := .f.,oGetMGet5:Refresh()}
	oGetCondicao:oBrowse:bAltered    := {|| lSalvou := .f. ,FG_TOTENT(.T.)}
	oGetCondicao:oBrowse:bDelete     := {|| DELETE012(),if(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.), oGetCondicao:oBrowse:Refresh() }
   
   //Finalizacao da venda
	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}
	oGetMGet9:= MsMGet():New("VV0",0,nOpc,,,,aQuiEnc,{001,001,168,092},,2,,,,oFolder012:aDialogs[7],,.T.,.T.,"aSvTela[9]")
	oGetMGet9:oBox:bGotFocus   := {|| AL_Entra(9,"VV0")}
	oGetMGet9:oBox:bLostFocus  := {|| AL_Sai(9)}
	aSvTela[9] := aClone(aTela)
	aSvGets[9] := aClone(aGets)
   Inclui := lInclui

	dbSelectArea("VV0")
	Zero()
	aTela := {}
	aGets := {}                                                           
	oGetMGet4:= MsMGet():New("VV0",0,nOpc,,,,aQuaEnc,{001,093,168,307},,2,,,,oFolder012:aDialogs[7],,.T.,.T.,"aSvTela[4]")
	oGetMGet4:oBox:bGotFocus   := {|| AL_Entra(4,"VV0")}
	oGetMGet4:oBox:bLostFocus  := {|| AL_Sai(4)}
	aSvTela[4] := aClone(aTela)
	aSvGets[4] := aClone(aGets)

	ACESS012()
	CORES012()

ACTIVATE MSDIALOG oDlgAtend CENTER ON INIT (EnchoiceBar(oDlgAtend, {|| nOpca := 1, iif(FINAL012(),oDlgAtend:End(),.f.) },{|| nOpca := 2, iif(Inclui,ENCERRA011(1),.t.), oDlgAtend:End() }))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AVANCA012    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avanca para o proximo passo no atendimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVANCA012()

Local lEnd := .f.

if oAvancar:cCaption == STR0038 //Finalizar
   if oFolder012:noption = 6
      lEnd := FINAL012(2)
   Endif   
   if oFolder012:noption = 7 
      lEnd := FINAL012(3)
   Endif
   if lEnd
      oDlgAtend:End()
   Endif   
   Return
Endif                                                

if oFolder012:noption = 1
	Processa({|| ATUTIT012() })
Endif

if oFolder012:noption = 6
   if !lJaCal012
      MsgInfo(STR0039,STR0040)//Informe uma condicao de pagamento ! - Atencao...
      Return
   Endif
   INIFIS011()
  	FISCAL011()
Endif

if (oFolder012:noption = 6 .or. oFolder012:noption = 7) // .or. (oFolder012:noption = 2 .and. !lEmiNfi)
   oAvancar:cCaption := STR0038 //Finalizar
Else
   oAvancar:cCaption := STR0025 //Avancar >>
Endif   

//if (oFolder012:noption = 6 .and. !lEmiNfi)
//   Return
//Endif   

if oFolder012:noption == 1
   oFolder012:noption := oFolder012:noption + 5
Elseif oFolder012:noption == 2
   oFolder012:noption := oFolder012:noption + 4
Elseif oFolder012:noption == 3
   oFolder012:noption := oFolder012:noption + 3
Else   
   oFolder012:noption := oFolder012:noption + 1
Endif   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VOLTAR012    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avanca para o proximo passo no atendimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VOLTAR012()

if oFolder012:noption = 2
   Return
Endif   

if oFolder012:noption == 6
   oFolder012:noption := oFolder012:noption - 4
Elseif oFolder012:noption == 5
   oFolder012:noption := oFolder012:noption - 3
Elseif oFolder012:noption == 4
   oFolder012:noption := oFolder012:noption - 2
Else   
   oFolder012:noption := oFolder012:noption - 1
Endif   

//if (oFolder012:noption = 6 .and. lNegPag .and. !lEmiNfi)
//   oAvancar:cCaption := "Finalizar"
//Else
   oAvancar:cCaption := STR0025 //Avancar >>
//Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FINAL012     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finaliza o atendimento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINAL012(nOpc)

Local cont
Local lRet   := .f.
Local bCampo := { |nCPO| Field(nCPO) }
Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.
       
Default nOpc := 1

if lExclui
   if nOpc <> 1
      MsgInfo(STR0041 ,STR0040) //Confirme a exclusao no botao de ok! - Atencao...
      Return(.f.)
   Else
      if PERGUNTE("OFI151")
   	   Begin Transaction
            FS_EXCATE()
         End Transaction
      Endif
      Return(.t.)
   Endif   
Endif   

if VV9->VV9_STATUS == "P" .and. !lLibVei .and. nOpc > 2
   MsgStop(STR0042 ,STR0040) //Atendimento ainda nao aprovado! - Atencao...
   Return(.f.)
Endif   

if VV9->VV9_STATUS == "O" .and. !lAutFat .and. nOpc > 2
   MsgStop(STR0043 ,STR0040) //Faturamento ainda nao aprovado! - Atencao...
   Return(.f.)
Endif   

if VV9->VV9_STATUS == "F" .and. nOpc > 2
   MsgInfo(STR0044 ,STR0040) //Atendimento ja contem Nota Fiscal gerada! - Atencao...
   Return(.f.)
Endif   

if VV9->VV9_STATUS == "C"
   MsgInfo(STR0045 ,STR0040) //Atendimento nao pode ser fechado pois esta cancelado! - Atencao...
   Return(.f.)
Endif   

if nOpc == 3
	VV1->(dbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHAINT))
	if Empty(VV1->VV1_FILIAL)
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
	  	if !SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+VV1->VV1_LOCPAD)) .or. SB2->B2_QATU <= 0
	      MsgInfo(STR0046 ,STR0040) //Veiculo nao esta no estoque ou pertence a outra filial - Atencao...
	   	Return(.f.)
	  	Endif   
	Endif
Endif

if !lEmiNfi .and. nOpc == 3
   MsgInfo(STR0047 ,STR0040) //Usuario nao pode emitir Nota Fiscal! - Atencao...
   Return(.f.)
Endif

if !lFatura
   MsgInfo(STR0048 ,STR0040)  //Veiculo nao pode ser faturado devido a sua situacao! - Atencao...
   Return(.f.)
Endif   

if M->VV0_TIPFAT == "2" .and. VV9->VV9_STATUS <> "F"
   if !FS_FATDIR()
      Return(.f.)
   Endif
Endif   

if nOpc == 1
	If MsgYesNo(OemToAnsi(STR0049),OemToAnsi(STR0040)) //Grava Atendimento? - Atencao...

      if lAutFat
			If ExistBlock("LIBFAT012")
				//ExecBlock("LIBFAT012",.f.,.f.)
			Endif
		Endif	

		//Cabecalho do atendimento
		dbSelectarea("VV0")
		dbSetOrder(1)
		RecLock("VV0",.f.)
		FG_GRAVAR("VV0")
		For cont := 1 TO FCount()
			VV0->&(EVAL(bCampo,cont)) := M->&(EVAL(bCampo,cont))
		Next
		MsUnlock()
			   //Processa({|| FS_GRVATE1() })
	   lRet := .t.
	Endif
ElseIf nOpc == 2
	If MsgYesNo(OemToAnsi(STR0050),OemToAnsi(STR0040)) //Finaliza atendimento? - Atencao...
	   Begin Transaction
      if (lRet := FS_TITPER())
         STATUS011("T")
   	Else   
   	   lRet := .f.
   	Endif
   	if lMsErroAuto
			DisarmTransaction()
			Break
   	Endif
   	End Transaction
   	if lMsErroAuto
		   MostraErro()
   	Endif
	Endif
ElseIf nOpc == 3
	If ExistBlock("CKLBFT012")
		if !ExecBlock("CKLBFT012",.f.,.f.)
		   Return(.f.)
		Endif   
	Endif
   if FS_CHKINF()
		If MsgYesNo(OemToAnsi(STR0051),OemToAnsi(STR0040)) //Gera Nota Fiscal? - Atencao...

		   If !FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
					
		   	cNota := cNumero

   		   Begin Transaction
			   Processa({|| FS_GERANOTA() })
      	   lRet := !lMsErroAuto
		   	if lMsErroAuto
					DisarmTransaction()
					Break
	   		Endif
	   		End Transaction  
	   		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX6")
			MsRUnLock()

	   	Endif

	   	if lMsErroAuto
			   MostraErro()
   		Endif
		Endif
	Endif   
Endif	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqV012     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no browse do atendimento e retorna com o filtro   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqV012()
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de pesquisa                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
axPesqui()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no indice da IndRegua                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
Eval(bFiltraBrw)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ACESS012     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega os acessorios do modelo selecionado                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACESS012()

Local cMar := VV1->VV1_CODMAR
Local cMod := VV1->VV1_MODVEI
Local lCortesia := .f.

if M->VV0_SIMULA == "1"
   cMar := cCodMar
   cMod := cModVei
Endif
           
aAcessor := {}

dbSelectArea("VV6")
dbSetOrder(4)
dbSelectArea("VVM")
dbSetOrder(1)

if dbSeek(xFilial("VV1")+alltrim(cMar)+SPACE(TamSx3("VV1_CODMAR")[1]-len(alltrim(cMar)))+cMod)
   while !EOF() .and. xFilial("VV1")+alltrim(cMar)+SPACE(TamSx3("VV1_CODMAR")[1]-len(alltrim(cMar)))+allTrim(cMod) == xFilial("VVM")+VVM->VVM_CODMAR+Alltrim(VVM->VVM_MODVEI)
		dbSelectArea("VVW")
		dbSetOrder(1)
		if dbSeek(xFilial("VVW")+VVM->VVM_CODMAR+VVM->VVM_CODOPC)
      	lFound  := VV6->(dbSeek(xFilial("VVM")+M->VV9_NUMATE+VVM->VVM_CODOPC)) //Acessorios
         lOpcFab := .f.
         nValOpc := iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
      	if lFound .and. (!VVM->VVM_OPCSER <> "1")
            nAcessor  := nAcessor + iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
            lCortesia := (VV6->VV6_GRATIS == "S")
         ElseIf (VVM->VVM_OPCSER <> "1")
            lFound  := .t.
            lOpcFab := .t.
            nValOpc := 0
         Endif   
      	aAdd(aAcessor, { lFound .or. lOpcFab,alltrim(VVW->VVW_CODOPC)+" - "+VVW->VVW_DESOPC,nValOpc,VVW->VVW_CODOPC,lCortesia,lOpcFab } )
      Endif
      dbSelectArea("VVM")
      dbSkip()
   EndDo
Endif

/*   
dbSelectArea("VVM")
dbSetOrder(1)
if dbSeek(xFilial("VV1")+cMar+cMod)
   while !EOF() .and. xFilial("VV1")+cMar+cMod == xFilial("VVM")+VVM->VVM_CODMAR+VVM->VVM_MODVEI
		dbSelectArea("VVW")
		dbSetOrder(1)
		if dbSeek(xFilial("VVW")+VVM->VVM_CODMAR+VVM->VVM_CODOPC)
      	aAdd(aAcessor, { .f.,.f.,VVW->VVW_DESOPC,VVW->VVW_VALOPC } )
      Endif
      dbSelectArea("VVM")
      dbSkip()
   EndDo
Endif
*/

if len(aAcessor) == 0
  	aAdd(aAcessor, { .f.," ",0,"",.f.,.f. } )
Endif

oLboxAce:SetArray(aAcessor)
oLboxAce:bLine := { || { if(aAcessor[oLboxAce:nAt,01] == .f.,oNo,iif(aAcessor[oLboxAce:nAt,06],oChecked,oTik)),;
  							     aAcessor[oLboxAce:nAt,02],;
							     FG_AlinVlrs(Transform(aAcessor[oLboxAce:nAt,03],"9,999,999.99")),;
  							     if(aAcessor[oLboxAce:nAt,05] == .f.,oNada,oGratis) }}

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CORES012     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega as cores do modelo selecionado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CORES012()

Local cMar := VV1->VV1_CODMAR
Local cMod := VV1->VV1_MODVEI

if M->VV0_SIMULA == "1"
   cMar := cCodMar
   cMod := cModVei
Endif
           
aCorM := {}
aCorP := {}
   
dbSelectArea("VVC")
dbSetOrder(1)
if dbSeek(xFilial("VVC")+cMar)
   dbSelectArea("VVP")
   dbSetOrder(1)
   dbSeek(xFilial("VVP")+cMar+cMod)
   dbSelectArea("VVC")
   while !EOF() .and. xFilial("VV1")+cMar == xFilial("VVC")+VVC->VVC_CODMAR
      if VVC->VVC_TIPCOR == "1"
       	aAdd(aCorM, { .f.,VVC->VVC_DESCRI,VVP->VVP_VACRMT } )
      Endif
      if VVC->VVC_TIPCOR == "2"
       	aAdd(aCorP, { .f.,VVC->VVC_DESCRI,VVP->VVP_VACRPR } )
      Endif
      dbSelectArea("VVC")
      dbSkip()
   EndDo
Endif

if len(aCorM) == 0
  	aAdd(aCorM, { .f.," ",0 } )
Endif
if len(aCorP) == 0
  	aAdd(aCorP, { .f.," ",0 } )
Endif
			
oLboxCorM:SetArray(aCorM)
oLboxCorM:bLine := { || { if(aCorM[oLboxCorM:nAt,01] == .f.,oNo,oTik),;
     								aCorM[oLboxCorM:nAt,02],;
	    							FG_AlinVlrs(Transform(aCorM[oLboxCorM:nAt,03],"9,999,999.99")),} }

oLboxCorP:SetArray(aCorP)
oLboxCorP:bLine := { || { if(aCorP[oLboxCorP:nAt,01] == .f.,oNo,oTik),;
     								aCorP[oLboxCorP:nAt,02],;
	    							FG_AlinVlrs(Transform(aCorP[oLboxCorP:nAt,03],"9,999,999.99")),} }

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VALTES012    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o TES digitado e atualiza os campos fiscais         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VALTES012()

Local lRet := .t.

if val(M->VV0_CODTES) < 500
   lRet := .f.
Endif   

INIFIS012()
FISCAL012()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ INIFIS012    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as variaveis fiscais                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function INIFIS012()

if !Empty(M->VV9_CODCLI) .and. !Empty(M->VV9_LOJA)
	If !MaFisFound('NF')
		MaFisIni(M->VV9_CODCLI,M->VV9_LOJA,'C','N',SA1->A1_TIPO,MaFisRelImp("VEIVM011",{"VV0","VVA"}))
	EndIf
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISCAL012    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia todos os campos necessario para as funcoes fiscais   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISCAL012()

if M->VV0_VALMOV > 0 .and. MaFisFound('NF')
	FISREF011("IT_VALMERC" ,M->VV0_VALMOV+M->VV0_ACESSO)
	FISREF011("IT_DESPESA" ,M->VV0_DESACE)
	FISREF011("IT_DESCONTO",M->VV0_VALDES)
	if !Empty(M->VV0_CODTES)
	   FISREF011("IT_TES",M->VV0_CODTES)
	   M->VV0_VBAICM := MaFisRet(,"NF_BASEICM")
	   M->VV0_TOTICM := MaFisRet(,"NF_VALICM")
	Endif   
Endif
				
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISREF012    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os campos fiscais de acordo com o tes digitado    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISREF012(cReferencia,xValor)

Local aArea	:= GetArea()

if M->VV0_TIPFAT == "0"
	If !MaFisFound("IT",1)
		MaFisAdd("",M->VVA_CODTES,0,0,0,CriaVar("D2_NFORI"),CriaVar("D2_SERIORI"),,0,0,0,0,0)
		MaFisAlt(cReferencia,xValor,1)
	Endif
	If MaFisFound("NF")
		MaFisAlt(cReferencia,xValor,1)
	EndIf
Endif

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BOTOES012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita ou desabilita alguns botoes na tela               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BOTOES012()

if Type("oCalcula") == "O"
	if oFolder012:noption = 1
	   oCalcula:lVisible := .t.
	Else   
	   oCalcula:lVisible := .f.
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CALC012   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula as parcelas na negociacao de pagamento             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALC012()
         
Local cont
Local cDia
Local nMes
Local nMesAnt

FS_VALOR011()

M->VV0_TOTENT := 0
For cont:=1 to len(aCols)
	if Empty(aCols[cont,1])
		Loop
	Endif
	if !aCols[cont,len(aCols[cont])]
	   M->VV0_TOTENT += aCols[cont,FG_POSVAR("VS9_VALPAG")]
	Endif
Next

dbSelectarea("SE4")
dbSetOrder(1)
if dbSeek(xFilial("SE4")+M->VV0_FORPAG)
	if !AllTrim(SE4->E4_COND) == "0" .or. SE4->E4_TIPO == "A"
      aColsC := aclone(aCols)
		FG_CONDICAO(M->VV0_DATINI,Str(M->VV0_DIA1PC),Str(M->VV0_PARCEL),Str(M->VV0_INTERVAL),"1","VV0_FORPAG",M->VV0_VALTOT)
      if M->VV0_FIXDIA == "1" .and. Val(M->VV0_DIAFIX) > 0 .and. Val(M->VV0_DIAFIX) < 32
         cDia    := M->VV0_DIAFIX
         nMesAnt := 0
         For cont := 1 to Len(aIteParc)
             if Val(cDia) > Day(LastDay(aIteParc[cont,1]))
                cDia := Str(Day(LastDay(aIteParc[cont,1])),2)
             Else
                cDia := M->VV0_DIAFIX
             Endif
             cDia := StrZero(Val(cDia),2)
             nMes := Month(aIteParc[cont,2])
             if nMesAnt == nMes
                nMes := Month(aIteParc[cont,1])+1
             Endif
             aIteParc[cont,1] := ctod(cDia+'/'+StrZero(nMes,2)+"/"+Substr(Str(Year(aIteParc[cont,1]),4),3,2))
             nMesAnt := nMes
         Next
			oLbParc:SetArray(aIteParc)
			oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
								  Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	      oLbParc:Refresh()
      Endif
	Else    
	   aIteParc := {{dDatabase,M->VV0_VALTOT - M->VV0_TOTENT}}
		oLbParc:SetArray(aIteParc)
		oLbParc:bLine := { || {	dToc(aIteParc[oLbParc:nAt,1]),;
							  Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
      oLbParc:Refresh()
	Endif
Endif

lJaCal012 := .t.

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VISIT012     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona o cliente e mostra os campos na tela             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VISIT012()
          
dbSelectarea("SA1")
dbSetOrder(2)
if dbSeek(xFilial("SA1")+M->VV9_NOMVIS)
   M->VV9_CODCLI := SA1->A1_COD
   M->VV9_LOJA   := SA1->A1_LOJA
   M->VV9_TELVIS := SA1->A1_TEL
   M->VV9_TIPMID := "8" //Ja e cliente
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IMPOSTO012   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a base para calculos e impostos                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IMPOSTO012()
              
Local nValor
              
nValor := M->VV0_VALTOT

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GVNEG012  ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava todos os dados da negociacao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRVNEG012()

Local nCont, cont, cont1
Local lAchou
Local cPrefNF   := "   "
Local cTipo     := "DP"
Local aParcelas := {}
Local bCampo    := { |nCPO| Field(nCPO) }
Local cTipCob   := if(!Empty(M->VV0_CODBCO),"1","0")

if Empty(VV0->VV0_NUMNFI)
	cPrefNF := SM0->M0_CODFIL+"E"
Else
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
Endif

//Cabecalho do atendimento
dbSelectarea("VV0")
dbSetOrder(1)
RecLock("VV0",.f.)
FG_GRAVAR("VV0")
For cont := 1 TO FCount()
	VV0->&(EVAL(bCampo,cont)) := M->&(EVAL(bCampo,cont))
Next
MsUnlock()

DELNEG012() //Exclui negociacao anterior

aMemos  := {{"VS9_OBSMEM","VS9_OBSERV"}}

cNumTit := M->VV0_NUMNFI
if Empty(M->VV0_NUMNFI)
	dbSelectArea("VE4")
	dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
   cNumTit := Right(VV9->VV9_NUMATE,nTamNota)
Endif

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if GetNewPar("MV_TPRVVEI","N") == "S" .and. Empty(cNota)
   cTipo     := "PR" //Provisorio
   cDesTipo  := STR0052   //PROVISORIO
Endif

nSeqPro := 1
cCodBco := M->VV0_CODBCO
cNumBord:= ""
dDatBord:= cTod("")
if SA6->A6_BORD == "0"
   cNumBord := "BCO"+SA6->A6_COD
   dDatBord := dDataBase
Endif

For cont:=1 to len(aColsC)
	if Empty(aColsC[cont,1])
		Loop
	Endif
	dbSelectArea("VS9")
	dbSetOrder(1)
   lAchou := dbSeek(xfilial("VS9")+VV0->VV0_NUMTRA+'V'+aColsC[cont,FG_POSVAR("VS9_TIPPAG")]+aColsC[cont,FG_POSVAR("VS9_SEQUEN")])
	if !aColsC[cont,len(aColsC[cont])] .and. (!lAchou .or. cont > Len(aIteEnt)) .or. (lAchou .and. aColsC[cont,FG_POSVAR('VS9_VALPAG',"aHeaderC")] <> aIteEnt[cont,5])
		cObserv2 := aColsC[cont,FG_POSVAR('VS9_OBSERV',"aHeaderC")]
		RecLock("VS9",!lAchou)
		FG_GRAVAR("VS9",aColsC,aHeaderC,cont)
		VS9->VS9_FILIAL := xFilial("VS9")
		VS9->VS9_NUMIDE := M->VV0_NUMTRA
		VS9->VS9_TIPOPE := "V"
		VS9->VS9_VALPAG := aColsC[cont,FG_POSVAR('VS9_VALPAG',"aHeaderC")]
		VS9->VS9_REFPAG := aColsC[cont,FG_POSVAR('VS9_REFPAG',"aHeaderC")]
	   VS9->VS9_PORTAD := aColsC[cont,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
		VS9->VS9_SEQUEN := aColsC[cont,FG_POSVAR('VS9_SEQUEN',"aHeaderC")]
	   VS9->VS9_TIPTIT := iif(cTipo=="PR","0","1")
		if !lAchou
   		VS9->VS9_SEQPRO := ConvPN2PC(nSeqPro)
   		nSeqPro += 1
   	Endif	
		MSMM(,TamSx3("VS9_OBSERV")[1],,cObserv2,1,,,"VS9","VS9_OBSMEM")
		ConfirmSx8()
		MsUnlock()

		For cont1:=1 to len(aGravaEnt)
			dbSelectArea("VSE")
			dbSetOrder(1)
			if !dbSeek(xfilial("VSE")+VV0->VV0_NUMTRA+'V'+aGravaEnt[cont1,2]+aColsC[cont,FG_POSVAR('VS9_SEQUEN',"aHeaderC")])
				RecLock("VSE",.t.)
				VSE->VSE_FILIAL := xFilial("VSE")
				VSE->VSE_NUMIDE := M->VV9_NUMATE
				VSE->VSE_TIPOPE := 'V'
				VSE->VSE_SEQUEN := aColsC[cont,FG_POSVAR('VS9_SEQUEN',"aHeaderC")]
				VSE->VSE_TIPPAG := aGravaEnt[cont1,2]
				VSE->VSE_DESCCP := aGravaEnt[cont1,3]
				VSE->VSE_NOMECP := aGravaEnt[cont1,4]
				VSE->VSE_TIPOCP := aGravaEnt[cont1,5]
				VSE->VSE_TAMACP := aGravaEnt[cont1,6]
				VSE->VSE_DECICP := aGravaEnt[cont1,7]
				VSE->VSE_PICTCP := aGravaEnt[cont1,8]
				VSE->VSE_VALDIG := aGravaEnt[cont1,9]
				MsUnlock()
			Endif	
		Next

      //Se so gerar titulo apos aprovacao e nao estiver aprovado ainda na continua
	   if GetNewPar("MV_TITAPR","S") == "S" .and. M->VV9_STATUS $ "A/P"
   	   Loop
	   Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os titulos                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      SA1->(dbSetOrder(1))
      SA1->(dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA))
      if cTipo <> "PR"
   		nCont := val(aColsC[cont,FG_POSVAR('VS9_SEQUEN',"aHeaderC")])
   	Else
   		nCont := val(VS9->VS9_SEQPRO)
   	Endif	

      dEmissao := dDataBase                         
      if aColsC[cont,FG_POSVAR("VS9_DATPAG")] < dDataBase   
         dEmissao := aColsC[cont,FG_POSVAR("VS9_DATPAG")]
      Endif   

   	if TamSx3("E1_PARCELA")[1] == 1
   	   cParcela := ConvPN2PC(ncont)
   	Else
//   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) ) 
			cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
   	Endif	   	

      aParcelas := {}
		aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                  ,nil})
		aAdd(aParcelas,{"E1_NUM"     , cNumTit                  ,nil})
		aAdd(aParcelas,{"E1_PARCELA" , cParcela                 ,nil})
		aAdd(aParcelas,{"E1_TIPO"    , iif(cTipo <> "PR",aColsC[cont,FG_POSVAR("VS9_TIPPAG")],cTipo),nil})
		aAdd(aParcelas,{"E1_NATUREZA", SA1->A1_NATUREZ          ,nil})
		aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD              ,nil})
		aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA             ,nil})
		aAdd(aParcelas,{"E1_EMISSAO" , dEmissao                 ,nil})
		aAdd(aParcelas,{"E1_VENCTO"  , aColsC[cont,FG_POSVAR("VS9_DATPAG")],nil})
		aAdd(aParcelas,{"E1_VENCREA" , DataValida(aColsC[cont,FG_POSVAR("VS9_DATPAG")]),nil})
		aAdd(aParcelas,{"E1_VALOR"   , aColsC[cont,FG_POSVAR("VS9_VALPAG")],nil})
	   aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                 ,nil})
	   aAdd(aParcelas,{"E1_DATABOR" , dDatBord                 ,nil})
   		aAdd(aParcelas,{"E1_PORTADO" , cCodBco                  	,nil})
		aAdd(aParcelas,{"E1_SITUACA" , cTipCob                  	,nil})
	   aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                 	,nil})
	   aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              	,nil})
		pergunte("FIN040",.F.)
  	   lMsErroAuto := .f.
  	   lMsHelpAuto := .t.
		_nRecSA1 := SA1->(Recno())//salva posicao SA1

		MSExecAuto({|x| FINA040(x)},aParcelas)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1
  	   
		if lMsErroAuto
			Help(" ",1,"ERROGERACR")
			Return(.t.)
		Endif
	Else
	   if val(VS9->VS9_SEQPRO)+1 > nSeqPro
   	   nSeqPro := val(VS9->VS9_SEQPRO)+1
   	Endif   
	Endif
Next
			
aMemos  := {{"VVA_OBSMEM","VVA_OBSERV"}}
			
For cont:=1 to Len(aIteParc)
	if Empty(aIteParc[cont,1])
		Exit
	Endif
   lAchou := dbSeek(xfilial("VS9")+VV0->VV0_NUMTRA+'V'+"DP"+strzero(cont,2))
	RecLock("VS9",!lAchou)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := M->VV0_NUMTRA
	VS9->VS9_TIPOPE := "V"
	VS9->VS9_TIPPAG := "DP"
//	VS9->VS9_DESPAG := STR0053 //DUPLICATA
	VS9->VS9_SEQUEN := strzero(cont,2)
	VS9->VS9_DATPAG := DataValida(aIteParc[cont,1])
	VS9->VS9_VALPAG := aIteParc[cont,2]
   VS9->VS9_PORTAD := M->VV0_CODBCO
   VS9->VS9_TIPTIT := iif(cTipo=="PR","0","1")
	if !lAchou
  		VS9->VS9_SEQPRO := ConvPN2PC(nSeqPro)
  		nSeqPro += 1
  	Endif	

	if !Empty(M->VV0_DATINI) .and. M->VV0_PARCEL > 0
		VS9->VS9_REFPAG := alltrim(dtoc(M->VV0_DATINI))+strzero(M->VV0_DIA1PC,2)+strzero(M->VV0_PARCEL,2)+strzero(M->VV0_PARCEL,2)
	Endif
	MsUnlock()

   //Se so gerar titulo apos aprovacao e nao estiver aprovado ainda na continua
   if GetNewPar("MV_TITAPR","S") == "S" .and. M->VV9_STATUS $ "A/P"
      Loop
   Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os titulos                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Empty(VV0->VV0_NUMNFI)
		cPrefNF := SM0->M0_CODFIL+"F"
	Else
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
	Endif

   if !dbSeek(xFilial("SE1")+cPrefNF+cNumTit)

      SA1->(dbSetOrder(1))
      SA1->(dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA))
      if cTipo <> "PR"
   		nCont := cont
   	Else
   		nCont := val(VS9->VS9_SEQPRO)
   	Endif	

      dEmissao := dDataBase                         
      if aIteParc[cont,1] < dDataBase   
         dEmissao := aIteParc[cont,1]
      Endif   

   	if TamSx3("E1_PARCELA")[1] = 1
   	   cParcela := ConvPN2PC(ncont)
   	Else
//   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) ) 
			cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
   	Endif	   	

      aParcelas := {}
		aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                  ,nil})
		aAdd(aParcelas,{"E1_NUM"     , cNumTit                  ,nil})
		aAdd(aParcelas,{"E1_PARCELA" , cParcela                 ,nil})
		aAdd(aParcelas,{"E1_TIPO"    , iif(cTipo <> "PR","DP",cTipo),nil})
		aAdd(aParcelas,{"E1_NATUREZA", SA1->A1_NATUREZ          ,nil})
		aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD              ,nil})
		aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA             ,nil})
		aAdd(aParcelas,{"E1_EMISSAO" , dEmissao                ,nil})
		aAdd(aParcelas,{"E1_VENCTO"  , aIteParc[cont,1],nil})
		aAdd(aParcelas,{"E1_VENCREA" , DataValida(aIteParc[cont,1]),nil})
		aAdd(aParcelas,{"E1_VALOR"   , aIteParc[cont,2],nil})
	   	aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                 ,nil})
	   	aAdd(aParcelas,{"E1_DATABOR" , dDatBord                 ,nil})
   		aAdd(aParcelas,{"E1_PORTADO" , cCodBco                  ,nil})
	   	aAdd(aParcelas,{"E1_SITUACA" , cTipCob                  ,nil})
	   	aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                 ,nil})
	   	aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              	,nil})
		pergunte("FIN040",.F.)
  	   	lMsErroAuto := .f.
  	   	lMsHelpAuto := .t.
		_nRecSA1 := SA1->(Recno())//salva posicao SA1

		MSExecAuto({|x| FINA040(x)},aParcelas)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1
		  	   
		if lMsErroAuto
			Help(" ",1,"ERROGERACR")
			Return(.t.)
		Endif
	Endif
Next
		
Return(.f.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DELNEG012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao da negociacao                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DELNEG012()

Local cont

dbSelectArea("VS9")
For cont := 1 to Len(aColsC)
	if aColsC[cont,len(aColsC[cont])]
      EXCTIT012("E",aCols[cont,FG_POSVAR("VS9_TIPPAG")],ConvPN2PC(val(aCols[cont,FG_POSVAR("VS9_SEQUEN")])))
		dbSelectArea("VSE")
		if dbSeek(xfilial("VSE")+VV0->VV0_NUMTRA+'V'+aColsC[cont,FG_POSVAR("VS9_TIPPAG")]+aColsC[cont,FG_POSVAR("VS9_SEQUEN")])
			if RecLock("VSE",.f.,.t.)
				VSE->(dbDelete())
				MsUnlock()
				WriteSx2("VSE")
			Endif
		Endif
	Else
		dbSelectArea("VS9")
		if dbSeek(xfilial("VS9")+VV0->VV0_NUMTRA+'V'+aColsC[cont,FG_POSVAR("VS9_TIPPAG")]+aColsC[cont,FG_POSVAR("VS9_SEQUEN")])
         if aColsC[cont,FG_POSVAR("VS9_VALPAG")] <> VS9->VS9_VALPAG
   	      EXCTIT012("E",aCols[cont,FG_POSVAR("VS9_TIPPAG")],ConvPN2PC(val(aCols[cont,FG_POSVAR("VS9_SEQUEN")])))
	      Endif
	   Endif   
	Endif	
Next

if (Len(aIteParB) <> Len(aIteParc)) .or. (aIteParB[1,2] <> aIteParc[1,1]) .or. (aIteParB[1,3] <> aIteParc[1,2])
	for cont := 1 to len(aIteParB)
		dbSelectArea("VS9")
		if dbSeek(xfilial("VS9")+VV0->VV0_NUMTRA+'VDP'+strzero(cont,2))
	      EXCTIT012("F","DP",ConvPN2PC(cont))
		Endif
	Next
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TITPER    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera os titulos permanentes para a nota fiscal             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TITPER()

Local cNumTit := Right(M->VV9_NUMATE,nTamNota)

dbSelectArea("SE1")
dbSetOrder(1)
if dbSeek(xFilial("SE1")+"ENT"+cNumTit)
   while !Eof() .and. SE1->E1_NUM == cNumTit .and. SE1->E1_PREFIXO == "ENT"
      if SE1->E1_PREFIXO <> "VEI"
		   RecLock("SE1",.f.)
		   SE1->E1_PREFIXO := "VEI"
   		MsUnlock()
   	Endif	
   	dbSelectArea("SE1")
      dbSeek(xFilial("SE1")+"ENT"+cNumTit)
   Enddo	
Endif
if dbSeek(xFilial("SE1")+"FIN"+cNumTit)
   while !Eof() .and. SE1->E1_NUM == cNumTit .and. SE1->E1_PREFIXO == "FIN"
      if SE1->E1_PREFIXO <> "VEI"
		   RecLock("SE1",.f.)
		   SE1->E1_PREFIXO := "VEI"
   		MsUnlock()
   	Endif	
   	dbSelectArea("SE1")
      dbSeek(xFilial("SE1")+"FIN"+cNumTit)
   Enddo	
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BAIXA012     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Baixa a percela                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BAIXA012(oObjeto, cPref, cTipo, dVencto, nValor)

Local dDatBai  := dDataBase
Local cBanco 	:= IIf(Type("cBanco")=="U",CriaVar("E1_PORTADO",.F.), cBanco)
Local cAgencia := IIf(Type("cAgencia")=="U",CriaVar("E1_AGEDEP" ,.F.),cAgencia)
Local cConta	:= IIf(Type("cConta")=="U",CriaVar("E1_CONTA"  ,.F.),cConta)

Local lBaixa  := .t.
Local cNumTit := Right(M->VV9_NUMATE,nTamNota)
Local nList   := iif(cPref == "E",1,2)
//Local cParcela:= ConvPN2PC(oObjeto:nAt)
Local cParcela:= ConvPN2PC(iif(nList==2,oObjeto:nAt,Val(aIteEnt[oObjeto:nAt,7])))

cParcela := cParcela+SPACE(TamSx3("E1_PARCELA")[1]-Len(cParcela))

lRet := .f.
DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0054) FROM  02,04 TO 17,31 OF oMainWnd	//Pagamento

		@ 001,006 SAY  OemToAnsi(STR0055)  OF oDlgPerg PIXEL COLOR CLR_BLUE	//Data do pagamento
		@ 011,006 MSGET oDatBai VAR dDatBai PICTURE "@D" SIZE 70,4 VALID dDatBai <= dDataBase OF oDlgPerg PIXEL COLOR CLR_BLACK

		@ 025,006 SAY  OemToAnsi(STR0056)  OF oDlgPerg PIXEL COLOR CLR_BLUE //Banco
		@ 033,006 MSGET oBanco VAR cBanco PICTURE "@!" SIZE 40,4 F3 "SA6" VALID .t. OF oDlgPerg PIXEL COLOR CLR_BLACK

		@ 047,006 SAY  OemToAnsi(STR0057)  OF oDlgPerg PIXEL COLOR CLR_BLUE	//Agencia
		@ 055,006 MSGET oAgencia VAR cAgencia PICTURE "@!" SIZE 50,4 VALID .t. OF oDlgPerg PIXEL COLOR CLR_BLACK

		@ 069,006 SAY  OemToAnsi(STR0058)  OF oDlgPerg PIXEL COLOR CLR_BLUE	//Conta
		@ 077,006 MSGET oConta VAR cConta PICTURE "@!" SIZE 80,4 VALID .t. OF oDlgPerg PIXEL COLOR CLR_BLACK

		@ 093,006 BUTTON oOk     PROMPT OemToAnsi(STR0059)       OF oDlgPerg SIZE 33,11 PIXEL ACTION (lRet := .t. , oDlgPerg:End()) //OK
		@ 093,045 BUTTON oCancel PROMPT OemToAnsi(STR0060) OF oDlgPerg SIZE 33,11 PIXEL ACTION (oDlgPerg:End()) //Cancelar
		oOk:SetFocus()
		
ACTIVATE MSDIALOG oDlgPerg CENTER

If !lRet
   Return(.f.)
Endif

if cTipo <> "PR"
	if Empty(VV0->VV0_NUMNFI)
		cPrefNF := SM0->M0_CODFIL+cPref
	Else
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
	Endif
Endif

if Len(cPrefNF) < TamSx3("E1_TIPO")[1]
   cPrefNF := alltrim(cPrefNF)+SPACE(TamSx3("VV1_CODMAR")[1]-len(alltrim(cPrefNF)))
Endif

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if !Empty(M->VV0_NUMNFI)  //if (VE4->VE4_GTPRFT  <> "0" .and. M->VV0_TIPFAT <> "1")
   cNumTit   := M->VV0_NUMNFI
	if cTipo == "PR"
	   cTipo := "DP"
	Endif   
Else
   cNumTit  := Right(M->VV9_NUMATE,nTamNota)
Endif 

dbSelectArea("SE1")
dbSetOrder(1)
if dbSeek(xFilial("SE1")+cPrefNF+cNumTit+cParcela+cTipo)
	if DTOS(dVencto) > DTOS(dDataBase)
	   lBaixa := MsgYesNo(STR0061 ,STR0040) //Vencimento da parcela e posterior a data de hoje! - Atencao...
	Endif   
	if lBaixa
      
      /*
      if SE1->E1_PREFIXO <> M->VV0_SERNFI
		   RecLock("SE1",.f.)
		   SE1->E1_PREFIXO := M->VV0_SERNFI
   		MsUnlock()
   	Endif	
      */
      
		aBaixa  := {{"E1_PREFIXO",cPrefNF,Nil},;
		{"E1_NUM"	   ,cNumTit            ,Nil},;
		{"E1_PARCELA"  ,cParcela           ,Nil},;
		{"E1_TIPO"	   ,cTipo              ,Nil},;
		{"AUTMOTBX"	   ,"NOR"              ,Nil},;
		{"AUTDTBAIXA"  ,dDatBai            ,Nil},;
		{"AUTDTCREDITO",dDatBai            ,Nil},;
		{"AUTHIST"	   ,'Baixa Automatica' ,Nil},;
		{"AUTBANCO"	   ,cBanco             ,Nil},;
		{"AUTAGENCIA"  ,cAgencia           ,Nil},;
		{"AUTCONTA"	   ,cConta             ,Nil},;
		{"AUTVALREC"   ,nValor             ,Nil }}
		
		lMsErroAuto := .f.
		lMsHelpAuto := .t.

		MSExecAuto({|x| FINA070(x)},aBaixa)

		If lMsErroAuto
			Help(" ",1,"ERROBXATAV") // Erro na Baixa do Titulo a Vista
			MostraErro()
			Return(.f.)
		EndIf
		
		dbSelectarea("VS9")
		dbSetOrder(1)
		if dbSeek(xFilial("VS9")+M->VV9_NUMATE+"V"+alltrim(cTipo)+StrZero(Val(cParcela),2))
		   RecLock("VS9",.f.)
		   VS9->VS9_DATBAI := dDataBase
		   VS9->VS9_TIPTIT := iif(cTipo=="PR","0","1")
         MsUnlock()
         if nList == 1
            aIteEnt[oObjeto:nAt,1] := .t.
            aIteEnt[oObjeto:nAt,6] := VS9->VS9_TIPTIT == "0"
         Else
            aIteParB[oObjeto:nAt,1] := .t.
            aIteParB[oObjeto:nAt,4] := VS9->VS9_TIPTIT == "0"
         Endif   
		Endif
	Endif	
Endif

if nList == 2
	oLbParB:SetArray(aIteParB)
	oLbParB:bLine := { || { if(aIteParB[oLbParB:nAt,4],oAmarelo,if(aIteParB[oLbParB:nAt,1] == .t.,oVerde,oVermelho)),;
	                    	dToc(aIteParB[oLbParB:nAt,2]),;
						  Transform(aIteParB[oLbParB:nAt,3],"@E 999,999,999.99")}}
	oLbParB:Refresh()					  
Else
	oLbEnt:SetArray(aIteEnt)
	oLbEnt:bLine := { || { iif(aIteEnt[oLbEnt:nAt,6],oAmarelo,if(aIteEnt[oLbEnt:nAt,1] == .t.,oVerde,oVermelho)),;
	                    	      aIteEnt[oLbEnt:nAt,2],;
   	                 	      aIteEnt[oLbEnt:nAt,3],;
      	              	dToc(aIteEnt[oLbEnt:nAt,4]),;
						  Transform(aIteEnt[oLbEnt:nAt,5],"@E 999,999,999.99")}}
	oLbEnt:Refresh()					  
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ESTORNO012   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Estorna a Baixa da percela                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ESTORNO012(oObjeto, cPref, cTipo, dVencto, nValor)
      
Local lBaixa  := .t.
Local cNumTit := Right(M->VV9_NUMATE,nTamNota)
Local nList   := iif(cPref == "E",1,2)
//Local cParcela:= ConvPN2PC(oObjeto:nAt)
Local cParcela:= ConvPN2PC(iif(nList==2,oObjeto:nAt,Val(aIteEnt[oObjeto:nAt,7])))

cParcela := cParcela+SPACE(TamSx3("E1_PARCELA")[1]-Len(cParcela))

if cTipo <> "PR"
	if Empty(VV0->VV0_NUMNFI)
		cPrefNF := SM0->M0_CODFIL+cPref
	Else
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
	Endif
Endif

if Len(cPrefNF) < TamSx3("E1_TIPO")[1]
   cPrefNF := alltrim(cPrefNF)+SPACE(TamSx3("VV1_CODMAR")[1]-len(alltrim(cPrefNF)))
Endif

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if !Empty(M->VV0_NUMNFI)  //if (VE4->VE4_GTPRFT  <> "0" .and. M->VV0_TIPFAT <> "1")
   cNumTit   := M->VV0_NUMNFI
	if cTipo == "PR"
	   cTipo := "DP"
	Endif   
Else
   cNumTit  := Right(M->VV9_NUMATE,nTamNota)
Endif 

dbSelectArea("SE1")
dbSetOrder(1)
if dbSeek(xFilial("SE1")+cPrefNF+cNumTit+cParcela+cTipo)
	if SE1->E1_STATUS == "B"
		aBaixa  := {{"E1_PREFIXO",cPrefNF ,Nil},;
		{"E1_NUM"	   ,cNumTit            ,Nil},;
		{"E1_PARCELA"  ,cParcela           ,Nil},;
		{"E1_TIPO"	   ,cTipo              ,Nil},;
		{"AUTMOTBX"	   ,"NOR"              ,Nil},;
		{"AUTDTBAIXA"  ,dDataBase          ,Nil},;
		{"AUTDTCREDITO",dDataBase          ,Nil},;
		{"AUTHIST"	   ,'Baixa Automatica' ,Nil},;
		{"AUTVALREC"   ,nValor             ,Nil }}
		
		lMsErroAuto := .f.
		lMsHelpAuto := .t.

		MSExecAuto({|x,y| FINA070(x,y)},aBaixa,5)

		If lMsErroAuto
			Help(" ",1,"ERROBXATAV") // Erro na Baixa do Titulo a Vista
			MostraErro()
			Return(.f.)
		EndIf

      /*
      if SE1->E1_PREFIXO <> M->VV0_SERNFI
		   RecLock("SE1",.f.)
		   SE1->E1_PREFIXO := cPrefNF
   		MsUnlock()
   	Endif	
		 */
		 
		dbSelectarea("VS9")
		dbSetOrder(1)
		if dbSeek(xFilial("VS9")+M->VV9_NUMATE+"V"+alltrim(cTipo)+StrZero(Val(cParcela),2))
		   RecLock("VS9",.f.)
		   VS9->VS9_DATBAI := ctod("")
		   VS9->VS9_TIPTIT := iif(cTipo=="PR","0","1")
         MsUnlock()
         if nList == 1
            aIteEnt[oObjeto:nAt,1] := .f.
            aIteEnt[oObjeto:nAt,6] := VS9->VS9_TIPTIT == "0"
         Else
            aIteParB[oObjeto:nAt,1] := .f.
            aIteParB[oObjeto:nAt,4] := VS9->VS9_TIPTIT == "0"
         Endif   
		Endif
	Endif	
Endif

if nList == 2
	oLbParB:SetArray(aIteParB)
	oLbParB:bLine := { || { if(aIteParB[oLbParB:nAt,4],oAmarelo,if(aIteParB[oLbParB:nAt,1] == .t.,oVerde,oVermelho)),;
	                    	dToc(aIteParB[oLbParB:nAt,2]),;
						  Transform(aIteParB[oLbParB:nAt,3],"@E 999,999,999.99")}}
	oLbParB:Refresh()					  
Else
	oLbEnt:SetArray(aIteEnt)
	oLbEnt:bLine := { || { iif(aIteEnt[oLbEnt:nAt,6],oAmarelo,if(aIteEnt[oLbEnt:nAt,1] == .t.,oVerde,if(aIteEnt[oLbEnt:nAt,6],oAmarelo,oVermelho))),;
	                    	      aIteEnt[oLbEnt:nAt,2],;
   	                 	      aIteEnt[oLbEnt:nAt,3],;
      	              	dToc(aIteEnt[oLbEnt:nAt,4]),;
						  Transform(aIteEnt[oLbEnt:nAt,5],"@E 999,999,999.99")}}
	oLbEnt:Refresh()					  
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RECEB012     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera status do titulo de provisorio para definitivo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RECEB012(oObjeto, cPref, cTipo, dVencto, nValor)
      
Local lBaixa  := .t.
Local cNumTit := Right(M->VV9_NUMATE,nTamNota)
Local nList   := iif(cPref == "ENT",1,2)
//Local cParcela:= ConvPN2PC(oObjeto:nAt)
Local cParcela:= ConvPN2PC(iif(nList==2,oObjeto:nAt,Val(aIteEnt[oObjeto:nAt,7])))

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if !Empty(M->VV0_NUMNFI) .or. (VE4->VE4_GTPRFT  <> "0" .and. M->VV0_TIPFAT <> "1")
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
Else
	cPrefNF := SM0->M0_CODFIL+"E"
Endif

lBaixa := MsgYesNo(STR0062 ,STR0040) //Marca parcela como recebida! - Atencao...

dbSelectarea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+M->VV9_NUMATE+"V"+alltrim(cTipo)+StrZero(Val(cParcela),2))
   RecLock("VS9",.f.)
   VS9->VS9_TIPTIT := "2"
   MsUnlock()
	cTipo    := "PR"
   cParcela := ConvPN2PC(val(VS9->VS9_SEQPRO))
	dbSelectArea("SE1")
	dbSetOrder(1)
	if	dbSeek(xFilial("SE1")+cPrefNF+cNumTit+cParcela+cTipo)
		if lBaixa
		   RecLock("SE1",.f.)
		   SE1->E1_TIPO := VS9->VS9_TIPPAG
  			MsUnlock()
		Endif
	Endif	
Endif

if nList == 2
   aIteParB[oObjeto:nAt,4] := .f.
	oLbParB:SetArray(aIteParB)
	oLbParB:bLine := { || { if(aIteParB[oLbParB:nAt,4],oAmarelo,if(aIteParB[oLbParB:nAt,1] == .t.,oVerde,oVermelho)),;
	                    	dToc(aIteParB[oLbParB:nAt,2]),;
						  Transform(aIteParB[oLbParB:nAt,3],"@E 999,999,999.99")}}
	oLbParB:Refresh()					  
Else
   aIteEnt[oObjeto:nAt,6] := .f.
	oLbEnt:SetArray(aIteEnt)
	oLbEnt:bLine := { || { iif(aIteEnt[oLbEnt:nAt,6],oAmarelo,if(aIteEnt[oLbEnt:nAt,1] == .t.,oVerde,if(aIteEnt[oLbEnt:nAt,6],oAmarelo,oVermelho))),;
	                    	      aIteEnt[oLbEnt:nAt,2],;
   	                 	      aIteEnt[oLbEnt:nAt,3],;
      	              	dToc(aIteEnt[oLbEnt:nAt,4]),;
						  Transform(aIteEnt[oLbEnt:nAt,5],"@E 999,999,999.99")}}
	oLbEnt:Refresh()					  
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ STATUS012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modifica o status do atendimento dependendo da operacao    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function STATUS012(cOpcao)

//Registro do atendimento
dbSelectarea("VV9")
dbSetOrder(1)
RecLock("VV9",.f.)
VV9->VV9_STATUS := cOpcao
MsUnlock()
M->VV9_STATUS := cOpcao

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AVARES012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda do browse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVARES012()

if !PERGUNTE("ATDCLI")
	Return
Endif

cCodMap  := Mv_Par01
cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)

dbSelectArea("VS5")
dbSetOrder(1)
dbSeek(xFilial("VS5")+cCodMap)

dbSelectArea("VOQ")
dbSetOrder(1)
dbSeek(xFilial("VOQ")+cCodMap)

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
	
	if !(M->VV0_TIPFAT $ VOQ_TIPFAT)
		dbSkip()
		Loop
	Endif
	If VOQ_INDATI # "1" // Sim
		dbSkip()
		Loop
	Endif
	If VOQ_CODMAP # cCodMap
		exit
	Endif
	
	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
	aadd(aStru,{ M->VV0_NUMTRA,VV1->VV1_TRACPA,SB1->B1_COD,;
	VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,M->VV0_DATMOV,0,0,VOQ_CTATOT})
	
	dbSkip()
	
Enddo

//Simula a gravacao para apresentacao do mapa
CPOMEM012("M")

//Calcula os valores do vetor
FG_CalcVlrs(aStru)

//Executa o mapa de avaliacao
FG_ResAva(cOutMoed,3,"V","","VEIVM010")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DELETE012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os titulos e a tela de negociacao                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DELETE012()     

if Len(aAlter[1]) == 0
   If !acols[n,len(acols[n])]
      acols[n,len(acols[n])] := .t.
   Endif   
   Return
Endif   

If !acols[n,len(acols[n])]
	if MsgYesNo(STR0063 ,STR0040) //Confirma a exclusão do pagamento? - Atencao
      M->VV0_TOTENT -= aCols[n,FG_POSVAR("VS9_VALPAG")]
		oGetMGet5:oBox:Refresh()
		oGetMGet7:oBox:Refresh()
   Else   
      acols[n,len(acols[n])] := .t.
	Endif   
Endif	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EXCTIT012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui os titulos gerados                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EXCTIT012(cTipNeg,cTipo,cParcela)

Local cont, cont2
Local lMsErroAuto := .f.
Local cTipoE1 := cTipo
Local cParcE1 := cParcela
Local cNumTit := iif(Empty(VV0->VV0_NUMNFI),Substr(VV9->VV9_NUMATE,2,nTamNota),VV0->VV0_NUMNFI)

if cTipo <> "PR"
	if Empty(VV0->VV0_NUMNFI)
		cPrefNF := SM0->M0_CODFIL+cTipNeg
	Else
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
	Endif
Endif

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if !Empty(M->VV0_NUMNFI) .or. (VE4->VE4_GTPRFT  <> "0" .and. M->VV0_TIPFAT <> "1")
   cNumTit   := M->VV0_NUMNFI
Endif 

dbSelectArea("VS9")
if dbSeek(xfilial("VS9")+VV0->VV0_NUMTRA+'V'+cTipo+strzero(val(cParcela),2))
   if VS9->VS9_TIPTIT == "0"
      cTipoE1 := "PR"
      cParcE1 := ConvPN2PC(val(VS9->VS9_SEQPRO))
   Endif   
Endif
   
dbSelectArea("SE1")
dbSetOrder(1)
if dbSeek(xFilial("SE1")+cPrefNF+cNumTit+cParcE1+cTipoE1)
	aParcelas := {}                                                                                                                                 
	AADD(aParcelas,{{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
                    {"E1_NUM"     ,E1_NUM     ,nil},;
                    {"E1_PARCELA" ,E1_PARCELA ,nil},;
  	                {"E1_TIPO"    ,E1_TIPO    ,nil},;
     	            {"E1_NATUREZA",E1_NATUREZA,nil},;
        	        {"E1_CLIENTE" ,E1_CLIENTE ,nil},;
                    {"E1_LOJA"    ,E1_LOJA    ,nil},;
                    {"E1_EMISSAO" ,E1_EMISSAO ,nil},;
                    {"E1_VENCTO"  ,E1_VENCTO  ,nil},;
  	                {"E1_VENCREA" ,E1_VENCREA ,nil},;
     	            {"E1_VALOR"   ,E1_VALOR   ,nil},;
        	        {"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
           	        {"E1_DATABOR" ,E1_DATABOR ,Nil},;
              	    {"E1_PORTADO" ,E1_PORTADO ,Nil},;
                 	{"E1_SITUACA" ,E1_SITUACA ,Nil}})
	pergunte("FIN040",.F.)
	For cont2 = 1 to len(aParcelas)
		MSExecAuto({|x,y| FINA040(x,y)},aParcelas[cont2],5)
	   if lMsErroAuto
  	      Return(.f.)
  	   Endif
  	Next
Endif		

dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+VV9->VV9_NUMATE+"V"+cTipo+strzero(val(cParcela),2))
	if RecLock("VS9",.f.,.t.)
		dbDelete()
		MsUnlock()
		WriteSx2("VS9")
	Endif
Endif

Return(lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AALTER012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se pode alterar a linha de edicao                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AALTER012(nLinha)

if (len(aIteEnt) < nLinha .or. !aIteEnt[nLinha,1]) .or. (Empty(aIteEnt[nLinha,1]))
   oGetCondicao:oBrowse:aAlter := aClone(aAlter[nLinha])
  	oGetCondicao:aAlter         := aClone(aAlter[nLinha])
Else   
   oGetCondicao:oBrowse:aAlter := {}
   oGetCondicao:aAlter         := {}
Endif   

oGetCondicao:Refresh()
oGetCondicao:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AAGET012     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta as linha que poderão ser alteradas                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AAGET012(aHeader_,aCols_)

Local cont1, cont2

Default aHeader_ := aHeader
Default aCols_  := aCols

aAlter := {}
      
for cont1 := 1 to len(aCols_)
   if (len(aIteEnt) < cont1 .or. !aIteEnt[cont1,1])
	   aadd(aAlter,{})
	   if len(aIteEnt) >= cont1 .and. !Empty(aCols_[cont1,1])
	   	aadd(aAlter[Len(aAlter)],"VS9_DATPAG")
	   	aadd(aAlter[Len(aAlter)],"VS9_VALPAG")
	   	aadd(aAlter[Len(aAlter)],"VS9_REFPAG")
	   	aadd(aAlter[Len(aAlter)],"VS9_PORTAD")
	   Else
			for cont2:=1 to Len(aHeader_)
		   	aadd(aAlter[Len(aAlter)],aHeader_[cont2,2])
   		next
   	Endif	
	Else
	   aadd(aAlter,{})
	Endif
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATUTIT012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os titulos e a tela de negociacao                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATUTIT012()

Local cont
Local lRetErro := .f.

if !Empty(M->VV0_NUMNFI) 
   cNota  := M->VV0_NUMNFI
   cSerie := M->VV0_SERNFI
Endif

aColsC    := aClone(aCols)
nTotalEnt := 0

for cont := 1 to len(aCols)
	if !aCols[cont,len(aCols[cont])]
      nTotalEnt += aCols[cont,FG_POSVAR("VS9_VALPAG")]
   Endif   
Next

for cont := 1 to len(aIteParc)
    nTotalEnt += aIteParc[cont,2]
Next

if nTotalEnt > M->VV0_VALTOT
   MsgInfo(STR0064 ,STR0040) //Valor maior que o total faturado... - Atencao!
   Return .f.
Endif   

nTotalEnt := 0

Begin Transaction
   lRetErro := GRVNEG012()
   if lRetErro
		DisarmTransaction()
		Break
	Endif   
End Transaction
if lRetErro
   MostraErro()
Endif 

aIteEnt  := {}
aIteParc := {}
aIteParB := {}
aColsC   := {}
aCols    := {}
    
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+M->VV9_NUMATE+"V")
	While !Eof() .and. VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VV0->VV0_NUMTRA+'V'
		If VS9->VS9_TIPPAG == "DP"  //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			aAdd(aIteParB, {!Empty(VS9->VS9_DATBAI),VS9->VS9_DATPAG,VS9->VS9_VALPAG,VS9->VS9_TIPTIT <> "1"})
			if !Empty(VS9->VS9_REFPAG)
				M->VV0_DATINI := cTod(Substr(VS9->VS9_REFPAG,01,08))
				M->VV0_DIA1PC := Substr(VS9->VS9_REFPAG,09,02)
				M->VV0_PARCEL := Substr(VS9->VS9_REFPAG,11,02)
				M->VV0_INTERV := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
         AADD(aIteEnt,{!Empty(VS9->VS9_DATBAI),VS9->VS9_TIPPAG,VS9->VS9_DESPAG,VS9->VS9_DATPAG,VS9->VS9_VALPAG,VS9->VS9_TIPTIT <> "1",VS9->VS9_SEQUEN})
			AADD(aColsC,Array(nUsadoC+1))
			For cont := 1 to nUsadoC
				aColsC[Len(aColsC),cont]:=If(aHeaderC[cont,10] # "V",FieldGet(FieldPos(aHeaderC[cont,2])),CriaVar(aHeaderC[cont,2]))
			Next
			aColsC[Len(aColsC),nUsadoC+1]:=.F.
         nTotalEnt     := nTotalEnt + VS9->VS9_VALPAG
         M->VV0_TOTENT := nTotalEnt
		Endif
		dbSkip()
	Enddo
Endif

oLbEnt:SetArray(aIteEnt)
//oLbEnt:bLine := { || { iif(aIteEnt[oLbEnt:nAt,6],oAmarelo,if(aIteEnt[oLbEnt:nAt,1] == .t.,oVermelho,oVerde)),;
oLbEnt:bLine := { || { iif(aIteEnt[oLbEnt:nAt,6],oAmarelo,if(aIteEnt[oLbEnt:nAt,1] == .t.,oVerde,if(aIteEnt[oLbEnt:nAt,6],oAmarelo,oVermelho))),;
                    	      aIteEnt[oLbEnt:nAt,2],;
                    	      aIteEnt[oLbEnt:nAt,3],;
                    	dToc(aIteEnt[oLbEnt:nAt,4]),;
			  Transform(aIteEnt[oLbEnt:nAt,5],"@E 999,999,999.99")}}

oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || {	dToc(aIteParc[oLbParc:nAt,1]),;
					  Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:Refresh()

oLbParB:SetArray(aIteParB)
oLbParB:bLine := { || { if(aIteParB[oLbParB:nAt,4],oAmarelo,if(aIteParB[oLbParB:nAt,1] == .t.,oVerde,oVermelho)),;
                       	dToc(aIteParB[oLbParB:nAt,2]),;
					  Transform(aIteParB[oLbParB:nAt,3],"@E 999,999,999.99")}}
oLbParB:Refresh()

aCols := aClone(aColsC)
oGetCondicao:oBrowse:Refresh()

oGetMGet5:oBox:Refresh()
oGetMGet7:oBox:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CPOMEM012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava variaves de memoria ou campos no arquivo             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOMEM012(cOpcao)
          
Local cont
Local lOpc
Local lOk := .t.
Local lChassi  := .f.
Local cWhile2  := ""
Local cAlias2  := ""
Local dJurEst  := 0
Local nCorrecao:= 0
Local nDesCli  := 0
Local cLocVV0  := iif(cOpcao<>"M","VV0",cOpcao)
Local cLocVVA  := iif(cOpcao<>"M","VVA",cOpcao)
Local cFunJEst := GetNewPar("MV_FUNJEST","") //Nome da Funcao que Calcula o Juros de Estoque

dbSelectArea("VVA")

if cOpcao <> "M"
   Reclock("VVA",.f.)
Endif   

//Juros de estoque
&(cLocVVA+"->VVA_JUREST") := 0

if M->VV0_SIMULA <> "1" .and. M->VV0_TIPFAT <> "1" //Nao for faturamento direto e nao for simulacao
   dbSelectArea("VVF")
   dbSetOrder(1)
   if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
	   dbSelectArea("VVG")
	   dbSetOrder(1)
	   dbSeek(xFilial("VVG")+VV1->VV1_TRACPA)

      dJurEst := VVF->VVF_DATEMI

		&(cLocVVA+"->VVA_VCAVEI") := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,dJurEst,dDataBase,VVG->VVG_VCNVEI)
      nCorrecao := &(cLocVVA+"->VVA_VCAVEI") - VVG->VVG_VCNVEI
		&(cLocVVA+"->VVA_JUREST") := nCorrecao

	   if nCorrecao == 0
	      dbSelectArea("SE2")
			dbSetOrder(1)
			if dbSeek(xFilial("SE2")+VVF->VVF_SERNFI+VVF->VVF_NUMNFI)
				if SE2->E2_BAIXA # ctod("  /  /  ") .and. (dDataBase - SE2->E2_BAIXA) > 0  //baixado
				   If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
						&(cLocVVA+"->VVA_JUREST") := nCorrecao + ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,'V'})
					Else	
						&(cLocVVA+"->VVA_JUREST") := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,"V")
					Endif	
				Endif
			Else
			   If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
					&(cLocVVA+"->VVA_JUREST") := nCorrecao + ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,'V'})
				Else	
					&(cLocVVA+"->VVA_JUREST") := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,"V")	      
				Endif
			Endif	
		Endif	
		&(cLocVVA+"->VVA_VALREV") := VV2->VV2_VALREV
		&(cLocVVA+"->VVA_SEGVIA") := VVG->VVG_SEGVIA
		&(cLocVVA+"->VVA_VALASS") := VVG->VVG_VALASS
		&(cLocVVA+"->VVA_PISENT") := VVG->VVG_PISENT
		&(cLocVVA+"->VVA_COFENT") := VVG->VVG_COFENT
		&(cLocVVA+"->VVA_CODIND") := VVG->VVG_CODIND
	Endif	
Else
	//Levanta preco atual da tabela.
	VVP->(dbSetOrder(1))                                                                       
	VVP->(dbSeek(xFilial("VVP")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD+Dtos(dDataBase),.t.))
		   
	nValRpr := 0
	nValRmt := 0
	nValCus := 0
			
   If VVP->VVP_FILIAL+VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == xFilial("VVP")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD ;
   	.And. VVP->VVP_DATPRC >= dDataBase
  	
		nValRpr := VVP->VVP_VACRPR
		nValRmt := VVP->VVP_VACRMT
		nValCus := VVP->VVP_CUSTAB
				
	EndIf   

   dbSelectArea("VVC")
   dbSetOrder(1)
  	dbSeek(xFilial("VVC")+M->VV0_CODMAR+M->VV0_CORVEI)

   if VVC->VVC_TIPCOR == "1"
    	nValCor := nValRmt
   Endif
   if VVC->VVC_TIPCOR == "2"
    	nValCor := nValRpr
   Endif
	&(cLocVVA+"->VVA_VCAVEI") := nValCus + nValCor
Endif

VE1->(dbSetOrder(1))
VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

/*
dbSelectArea("VVO")
dbSetOrder(1)
if dbSeek(xFilial("VVO")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+dtos(dDataBase))
	&(cLocVVA+"->VVA_BONFAB") := if(VV1->VV1_ESTVEI=="0" .or. M->VV0_TIPFAT == "1",VVO->VVO_VALBON,0)
Endif
*/
dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
   while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
     	nDesCli += VVD->VVD_VALOR
      dbSelectArea("VVD")
      dbSkip()
  	Enddo
Endif
&(cLocVVA+"->VVA_DESCLI") := nDesCli
&(cLocVVA+"->VVA_DESCLI") := VV1->VV1_BONFAB
//Campanha promocional
DbSelectArea("VV2")
dbSetOrder(1)
DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
/*
dbSelectArea("VZ5")
dbSetOrder(2)
If dbSeek(xFilial("VZ5")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_CHASSI )
   cWhile  := 'VZ5->VZ5_FILIAL+VZ5->VZ5_CHASSI == xFilial("VZ5")+VV1->VV1_CHASSI'
   lChassi := .t.
Else   
   If dbSeek(xFilial("VZ5")+VV1->VV1_CODMAR+VV1->VV1_MODVEI )
      cWhile := 'VZ5->VZ5_FILIAL+VZ5->VZ5_MODVEI == xFilial("VZ5")+VV1->VV1_MODVEI'
   Endif
Endif
*/
M->VVA_BONFAB := 0
If VVA->(FieldPos("VVA_BONREG"))>0
	M->VVA_BONREG := 0
EndIf
If VVA->(FieldPos("VVA_BONCON"))>0
	M->VVA_BONCON := 0
Endif	
dbSelectArea("VZ7")
dbSetOrder(1)
If !dbSeek(xFilial("VZ7")+M->VV9_NUMATE)
	dbSelectArea("VZ5")
	dbSetOrder(1)
	dbSeek(xFilial("VZ5"))
	while !eof() .and. xFilial("VZ5") == VZ5->VZ5_FILIAL
		lOk := .f.
		Do Case 
			Case !Empty(VZ5->VZ5_CHASSI) // Chassi
				If ( VZ5->VZ5_CHASSI ) == ( VV1->VV1_CHASSI )
					lOk := .t.
				EndIf
			Case !Empty(VZ5->VZ5_MODVEI) // Modelo
				If ( VZ5->VZ5_CODMAR + VZ5->VZ5_GRUMOD + VZ5->VZ5_MODVEI ) == ( VV1->VV1_CODMAR + VV2->VV2_GRUMOD + VV1->VV1_MODVEI )
					lOk := .t.
				EndIf
			Case !Empty(VZ5->VZ5_GRUMOD) // Grupo do Modelo
				If ( VZ5->VZ5_CODMAR + VZ5->VZ5_GRUMOD ) == ( VV1->VV1_CODMAR + VV2->VV2_GRUMOD )
					lOk := .t.
				EndIf
			Case !Empty(VZ5->VZ5_CODMAR) // Marca
				If ( VZ5->VZ5_CODMAR ) == ( VV1->VV1_CODMAR )
					lOk := .t.
				EndIf
			OtherWise
				lOk := .t.
		EndCase
		If lOk
			If !Empty(VZ5->VZ5_ESTVEI) .and. VZ5->VZ5_ESTVEI <> "2" // Estado do Veiculo: 0-Novos/1-Usados/2-Ambos
				If VZ5->VZ5_ESTVEI <> VV1->VV1_ESTVEI
					lOk := .f.
				EndIf
			EndIf
		EndIf
		If !lOk
			DbSelectArea("VZ5")
			DbSkip()
			Loop
		EndIf
	   lOpc := .t.
	   For cont := 1 to Len(Alltrim(VZ5->VZ5_OPCION))
	      cOpcion := subs(VZ5->VZ5_OPCION,p_*3-2,3)
			If at(cOpcion,vv1->vv1_opcfab) == 0
			   lOpc := .f.
			Endif   
	   Next
      If dDataBase >= VZ5->VZ5_DATINI .and. dDataBase <= VZ5->VZ5_DATFIN .and. if(lChassi,If(Empty(VZ5->VZ5_FABMOD),.t.,VV1->VV1_FABMOD == VZ5->VZ5_FABMOD),.t.) .and. lOpc .and. If(lChassi,!Empty(VZ5->VZ5_CHASSI),Empty(VZ5->VZ5_CHASSI))
//         M->VVA_BONFAB += (VZ5->VZ5_BONNAC+VZ5->VZ5_BONREG+VZ5->VZ5_BONCON)
		If VZ5->(FieldPos("VZ5_BONFAB"))>0
			M->VVA_BONFAB += VZ5->VZ5_BONFAB
		EndIf
		If VVA->(FieldPos("VVA_BONREG"))>0
			M->VVA_BONREG += VZ5->VZ5_BONREG
		EndIf
		If VVA->(FieldPos("VVA_BONCON"))>0
			M->VVA_BONCON += VZ5->VZ5_BONCON
		EndIf
         If !Empty(M->VV0_CHASSI)
				dbSelectArea("VZ6")
				dbSetOrder(1)
				dbSeek(xFilial("VZ6")+VZ5->VZ5_CODACV)                                            
				cWhile2 := 'VZ6->VZ6_FILIAL+VZ6->VZ6_CODACV == xFilial("VZ6")+VZ5->VZ5_CODACV'
				cAlias2 := "VZ6"
			Else 
				dbSelectArea("VZ7")
				dbSetOrder(2)
				dbSeek(xFilial("VZ7")+VZ5->VZ5_CODACV)                                            
				cWhile2 := 'VZ7->VZ7_FILIAL+VZ7->VZ7_CODACV == xFilial("VZ7")+VZ5->VZ5_CODACV'
				cAlias2 := "VZ7"
		   Endif
         While !eof() .and. &cWhile2
            If !Empty(M->VV0_CHASSI)
	            dbSelectArea("VZ7")
				   RecLock("VZ7",.t.)
				   VZ7->VZ7_FILIAL := xFilial("VZ7")
					VZ7->VZ7_NUMTRA := M->VV0_NUMTRA
				   VZ7->VZ7_CODACV := VZ6->VZ6_CODACV
				   VZ7->VZ7_ITECAM := VZ6->VZ6_ITECAM
				   VZ7->VZ7_VALITE := VZ6->VZ6_VALITE
				   MsUnlock()                        
	         Endif   
				&(cLocVVA+"->VVA_DESCLI") += VZ7->VZ7_VALITE
				dbSelectArea(cAlias2)
        		dbSkip()
         Enddo
      Endif   
      dbSelectArea("VZ5")
      dbSkip()
   Enddo
Else
   While !eof() .and. VZ7->VZ7_FILIAL+VZ7->VZ7_NUMTRA == xFilial("VZ7")+M->VV0_NUMTRA
		&(cLocVVA+"->VVA_DESCLI") += VZ7->VZ7_VALITE      
		dbskip()
   Enddo
Endif

if cOpcao <> "M"
   VVA->(MsUnlock())
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava valores de moeda forte nas variaveis de memoria               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FS_MFORTE("M")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TRF012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transfere titulos entre portadores                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TRF012()

Local cPorAtu := space(3)
Local cPorNov := space(3)
Local cDesAtu := space(60)
Local cDesNov := space(60)
Local aTit    := {}
    
dbSelectArea("SE1")
dbSetOrder(1)
if dbSeek(xFilial("SE1"))
	aadd(atit,{.t.,SE1->E1_NUM,SE1->E1_EMISSAO,SE1->E1_VALOR})

	DEFINE MSDIALOG oDlgTRF TITLE OemtoAnsi(STR0065) FROM  02,04 TO 12,45 OF oMainWnd  //Transferencia de portadores

		@ 006,002 SAY OemToAnsi(STR0066) OF oDlgTRF PIXEL COLOR CLR_BLUE //Portador atual
		@ 014,002 MSGET oPorAtu VAR cPorAtu PICTURE "@!" SIZE 45,4  OF oDlgTRF PIXEL COLOR CLR_BLACK when .f.
		@ 014,055 MSGET oDesAtu VAR cDesAtu PICTURE "@!" SIZE 105,4  OF oDlgTRF PIXEL COLOR CLR_BLACK when .f.

		@ 027,002 SAY OemToAnsi(STR0067) OF oDlgTRF PIXEL COLOR CLR_BLUE  //Novo Portador
		@ 035,002 MSGET oPorNov VAR cPorNov PICTURE "@!" F3 "SA6" SIZE 45,4  OF oDlgTRF PIXEL COLOR CLR_BLACK
		@ 035,055 MSGET oDesAtu VAR cDesAtu PICTURE "@!" SIZE 105,4  OF oDlgTRF PIXEL COLOR CLR_BLACK when .f.
                                                                                                                                        
	 	@ 058,020 BUTTON oOk     PROMPT OemToAnsi(STR0059)       OF oDlgTRF SIZE 43,11 PIXEL ACTION (iif(TRANST012(aTit, cPorAtu,cPorNov), oDlgTRF:End(),.f.))//ok
	 	@ 058,065 BUTTON oCancel PROMPT OemToAnsi(STR0060) OF oDlgTRF SIZE 43,11 PIXEL ACTION (oDlgTRF:End())//CANCELAR

	   oOk:SetFocus()

	ACTIVATE MSDIALOG oDlgTRF CENTER
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CAIXA012T    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transfere titulos entre portadores                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAIXA012T()

Local cPorAtu := space(3)
Local cPorNov := space(3)
Local cDesAtu := space(60)
Local cDesNov := space(60)
Local dData1  := dDataBase
Local dData2  := dDataBase
Local aTit    := {{.f.,"","","",ctod(""),0 }}

Local oNada   := LoadBitmap( GetResources(), "NADA" )
Local oTik    := LoadBitmap( GetResources(), "LBTIK" )
Local oNo     := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlgTRF TITLE OemtoAnsi(STR0065) FROM  02,04 TO 25.5,45 OF oMainWnd //transferencia de portadores

	@ 002,002 SAY OemToAnsi(STR0068) OF oDlgTRF PIXEL COLOR CLR_BLUE //Periodo de                  ate
	@ 011,002 MSGET oData1 VAR dData1 PICTURE "@D" SIZE 45,4  OF oDlgTRF PIXEL COLOR CLR_BLACK
	@ 011,055 MSGET oData2 VAR dData2 PICTURE "@D" SIZE 45,4  OF oDlgTRF PIXEL COLOR CLR_BLACK

	@ 024,002 SAY OemToAnsi(STR0066) OF oDlgTRF PIXEL COLOR CLR_BLUE//portador atual
	@ 032,002 MSGET oPorAtu VAR cPorAtu PICTURE "@!" F3 "SA6" SIZE 45,4  OF oDlgTRF PIXEL COLOR CLR_BLACK
	@ 032,055 MSGET oDesAtu VAR cDesAtu PICTURE "@!" SIZE 105,4  OF oDlgTRF PIXEL COLOR CLR_BLACK when .f.

 	@ 046,002 BUTTON oBusca  PROMPT OemToAnsi(STR0069) OF oDlgTRF SIZE 43,11 PIXEL ACTION (BUSTIT012(@aTit,dData1,dData2,cPorAtu))  //Carregar

 	@ 046,055 BUTTON oInverte PROMPT OemToAnsi(STR0070) OF oDlgTRF SIZE 43,11 PIXEL ACTION (aEval(aTit,{|x| x[1] := !x[1] }))  //Inverter

	@ 059,001 LISTBOX oLbTit FIELDS HEADER;
	OemToAnsi(""),;
	OemToAnsi(STR0071),;  	//Atendimento
	OemToAnsi(STR0072),; 	//Nome
	OemToAnsi(STR0073),;  	//Titulo
	OemToAnsi(STR0074),;  	//Emissao
	OemToAnsi(STR0028);		//Valor
	COLSIZES 5,40,50,40,40,60;
	SIZE 158,080 OF oDlgTRF PIXEL ON DBLCLICK (iif(aTit[oLbTit:nAt,01] == .f.,aTit[oLbTit:nAt,01] := .t.,aTit[oLbTit:nAt,01] := .f.))
	
	if len(aTit) == 0
   	aAdd(aTit, { .f.,"","","",ctod(""),0 } )
	Endif
			
	oLbTit:SetArray(aTit)
	oLbTit:bLine := { || { if(aTit[oLbTit:nAt,01] == .f.,oNo,oTik),;
   							     aTit[oLbTit:nAt,02],;
   							     aTit[oLbTit:nAt,03],;
   							     aTit[oLbTit:nAt,04],;
   							     aTit[oLbTit:nAt,05],;
								     FG_AlinVlrs(Transform(aTit[oLbTit:nAt,06],"9,999,999.99")),} }

	@ 142,002 SAY OemToAnsi(STR0067) OF oDlgTRF PIXEL COLOR CLR_BLUE 	//novo portador
	@ 150,002 MSGET oPorNov VAR cPorNov PICTURE "@!" F3 "SA6" SIZE 45,4  OF oDlgTRF PIXEL COLOR CLR_BLACK
	@ 150,055 MSGET oDesNov VAR cDesNov PICTURE "@!" SIZE 105,4  OF oDlgTRF PIXEL COLOR CLR_BLACK when .f.

 	@ 163,065 BUTTON oOk     PROMPT OemToAnsi(STR0059)       OF oDlgTRF SIZE 43,11 PIXEL ACTION (iif(TRANST012(aTit, cPorAtu, cPorNov),oDlgTRF:End(),.f.))
 	@ 163,115 BUTTON oCancel PROMPT OemToAnsi(STR0060) OF oDlgTRF SIZE 43,11 PIXEL ACTION (oDlgTRF:End())//CANCELAR

   oOk:SetFocus()

ACTIVATE MSDIALOG oDlgTRF CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BUSTIT012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca titulos para a tranferencia de portador              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TRANST012(aTit, cPorAtu, cPorNov)
            
Local lRet := .t.
Local cont

dbSelectArea("SE1")
dbSetOrder(4)

For cont := 1 to Len(aTit)
    if aTit[cont,1]
       //Muda de portador
       if dbSeek(xFilial("SE1")+cPorAtu+aTit[cont,3]+aTit[cont,7]+aTit[cont,4])
          if RecLock("SE1",.f.)
             SE1->E1_PORTADO := cPorNov
             MsUnlock()
          Else
            lRet := .f.
          Endif     
       Endif
    Endif
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BUSTIT012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca titulos para a tranferencia de portador              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BUSTIT012(aTit, dData1, dData2, cPortador )

Local lAchou := .f.

dbSelectArea("VV9")
dbSetOrder(1)

aTit := {}

dbSelectArea("SE1")
dbSetOrder(6)
dbSeek(xFilial("SE1")+dtos(dData1),.t.)
While E1_FILIAL == xFilial("SE1") .and. E1_EMISSAO >= dData1 .and. E1_EMISSAO <= dData2
   lAchou := .f.
   if E1_PORTADO == cPortador
      if Empty(SE1->E1_NUMBOR)
	      dbSelectArea("VV9")
   	   if dbSeek(xFilial("VV9")+strzero(val(SE1->E1_NUM),10))
      	   lAchou := .t.
				dbSelectArea("VV0")
				dbSetOrder(1)
     		   dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
	      Else
				dbSelectArea("VV0")
				dbSetOrder(4)
   	   	dbSeek(xFilial("VV0")+SE1->E1_NUM+SE1->E1_SERIE)
         
	         dbSelectArea("VV9")
   	      if dbSeek(xFilial("VV9")+VV0->VV0_NUMTRA)
      	      lAchou := .t.
	         Endif   
   	   Endif
	      if lAchou
   		   aadd(aTit,{.t.,VV9->VV9_NUMATE,SE1->E1_NOMCLI,SE1->E1_NUM,SE1->E1_EMISSAO,SE1->E1_VALOR,SE1->E1_PREFIXO})
   		Endif   
	   Endif
	Endif   
  	dbSelectArea("SE1")
   dbSkip()
Enddo

if len(aTit) == 0
  	aAdd(aTit, { .f.,"","","",ctod(""),0 } )
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LEGEN012     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda do browse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Function LEGEN012()

Local aLegenda := {{'BR_VERDE'   ,'Atendimento em Aberto'},;
                   {'BR_PRETO'   ,'Atendimento Finalizado'},;
                   {'BR_AMARELO' ,'Pendente de Aprovacao'},;
                   {'BR_LARANJA' ,'Atendimento Reprovado'},;
                   {'BR_BRANCO'  ,'Pre-Aprovado'},;
                   {'BR_AZUL'    ,'Aprovado'},;
                   {'BR_VERMELHO','Atendimento Cancelado'}}

BrwLegenda(cCadastro,"Legenda" ,aLegenda)

Return
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPCOES012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Opcoes do atendimento                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPCOES012( oObj, nX, nY, oMenu )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AEval( oMenu:aItems, { |x| x:Disable() } ) 

if VV9->VV9_STATUS <> "P"
   oMenu:aItems[1]:Disable()
Endif   

if !VV9->VV9_STATUS $ "P/O"
   oMenu:aItems[2]:Disable()
Endif

if VV9->VV9_STATUS <> "R"
   oMenu:aItems[3]:Disable()
Endif

if !lAutFat
   oMenu:aItems[2]:Disable()
   oMenu:aItems[5]:Disable()
Endif

if !lLibVei
   oMenu:aItems[1]:Disable()
   oMenu:aItems[3]:Disable()
   oMenu:aItems[4]:Disable()
   oMenu:aItems[6]:Disable()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Menu PopUp                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMenu:Activate( nX, nY, oObj )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPCOES012    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Opcoes do atendimento                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MENU012( oObj, nX, nY, oMenu, oObjeto, cTipo )
      
Local cParcela:= strzero(oObjeto:nAt,2)

if oMenu:cName == "B1"
   cParcela := aColsC[oObjeto:nAt,FG_POSVAR("VS9_SEQUEN")]
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Enable() } ) 

dbSelectarea("VS9")
dbSetOrder(1)                                                
if dbSeek(xFilial("VS9")+M->VV9_NUMATE+"V"+alltrim(cTipo)+cParcela)
   if Empty(VS9->VS9_DATBAI)
      oMenu:aItems[3]:Disable()
   Else   
      oMenu:aItems[2]:Disable()
   Endif
Else
   AEval( oMenu:aItems, { |x| x:Disable() } ) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Menu PopUp                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMenu:Activate( nX, nY, oObj )

Return

Static Function MenuDef()
Local aRotina := {{OemtoAnsi(STR0075),"PesqV012" , 0 , 1},;//Pesquisar
				{OemtoAnsi(STR0076),"CAIXA012" , 0 , 2},;//Consultar
				{OemtoAnsi(STR0077),"CAIXA012" , 0 , 4},;//Caixa
				{OemtoAnsi(STR0078),"CAIXA012T", 0 , 4},;//Transferencia
				{OemtoAnsi(STR0079),"CAIXA012" , 0 , 5},;//Cancela
				{OemtoAnsi(STR0080),"LEGEN011" , 0, 3 ,2,.f.},;//  Legenda
				{OemtoAnsi(STR0081),"VM012_LVEI", 0, 2 }}//Pesq.Avancada
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM012_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM012_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private nCkPerg1:= 1                     
Private aComboStat := {"","F-" + STR0082,"T-" + STR0083,"P-" + STR0084,"O-" + STR0085,"L-"+ STR0086}//Atendimento Finalizado - Atendimento Finalizado parcialmente - Pendente de Aprovacao - Pre-Aprovado - Aprovado
Private cComboStat := ""
Private dDtIniAte  := dDataBase-(day(dDataBase)-1)
Private dDtFinAte  := dDataBase
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )
Private oOcea := LoadBitmap( GetResources() , "lbok_ocean" )
Private oPret := LoadBitmap( GetResources() , "BR_PRETO" )
Private oAmar := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oLara := LoadBitmap( GetResources() , "BR_LARANJA" )
Private oBran := LoadBitmap( GetResources() , "BR_BRANCO" )
Private oAzul := LoadBitmap( GetResources() , "BR_AZUL" )
Private oVerm := LoadBitmap( GetResources() , "BR_VERMELHO" )
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
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0087) FROM  01,05 TO 17,85 OF oMainWnd //Pesquisa Chassi/Cliente/Status/Periodo
	                                                                                         
	@ 000,002 RADIO oRadio1 VAR nCkPerg1 3D SIZE 50,10 PROMPT OemToAnsi(STR0088),OemToAnsi(STR0089) OF oLevPesq PIXEL ON CHANGE (FS_COMBOTIPO(),FS_LEVVEI())//Chassi/Cliente - Status/Periodo

  	@ 005,055 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL

	@ 005,055 MSCOMBOBOX oCoboStat VAR cComboStat VALID FS_LEVVEI() SIZE 110,08 ITEMS aComboStat OF oLevPesq PIXEL COLOR CLR_BLUE
  	@ 006,168 SAY oTit1 VAR STR0090 SIZE 33,08 OF oLevPesq PIXEL COLOR CLR_BLUE //Periodo:
  	@ 006,227 SAY oTit2 VAR STR0091 SIZE 10,08 OF oLevPesq PIXEL COLOR CLR_BLUE  //a
  	@ 005,189 MSGET oDtIniAte VAR dDtIniAte VALID FS_LEVVEI() PICTURE "@D" SIZE 36,08 OF oLevPesq PIXEL
  	@ 005,232 MSGET oDtFinAte VAR dDtFinAte VALID FS_LEVVEI() PICTURE "@D" SIZE 36,08 OF oLevPesq PIXEL
	oTit1:lVisible:=.f.
	oTit2:lVisible:=.f.
	oCoboStat:lVisible:=.f.
  	oDtIniAte:lVisible:=.f.
  	oDtFinAte:lVisible:=.f.
  	
 	@ 005,272 BUTTON oNo PROMPT OemToAnsi(STR0092) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
	@ 020,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
																OemToAnsi(STR0093),;//Filial
																OemToAnsi(STR0036),;//Data
																OemToAnsi(STR0071),; //atendimento
																OemToAnsi(STR0094);//Cliente
																COLSIZES 10,35,35,25,150 SIZE 313,099 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
   							   	aLevPesq[oLbLevPesq:nAt,03],;
   							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
   							   	aLevPesq[oLbLevPesq:nAt,05],;
   							   	aLevPesq[oLbLevPesq:nAt,06] }}
ACTIVATE MSDIALOG oLevPesq CENTER
DbSelectArea("VV9")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca 
  	//posiciona no registro
  	DbSetOrder(1)//NUM.ATENDIMENTO
  	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif       
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local cQuery := ""
Local cQAlVV0 := "SQLVV0"
Local cFilLibs := ""
Local cVV9_STATUS := ""
If Empty(cLevChas) .and. nCkPerg1 == 1 // Chassi/Cliente
	aLevPesq := {{"","","",ctod(""),"",0,""}}
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
	  							   	aLevPesq[oLbLevPesq:nAt,03],;
	  							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	  							   	aLevPesq[oLbLevPesq:nAt,05],;
	  							   	aLevPesq[oLbLevPesq:nAt,06] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	Return()
EndIf
aLevPesq := {}
cQuery := "SELECT VV9.VV9_NUMATE , VV9.VV9_STATUS , VV9.VV9_DATVIS , VV0.VV0_FILIAL , VV0.VV0_CODCLI , VV0.VV0_LOJA , VVA.VVA_CHAINT FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VV9")+" VV9 , "+RetSqlName("VVA")+" VVA WHERE VV9.VV9_STATUS IN ('T','F','O','L','P') AND "
cQuery += "VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND "
If nCkPerg1 == 1 // Chassi/Cliente
	cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND "
Else//If nCkPerg1 == 2 // Status/Periodo
	If !Empty(cComboStat)
		If left(cComboStat,1)=="X"
			cQuery += "VV9.VV9_STATUS='A' AND "
		Else
			cQuery += "VV9.VV9_STATUS='"+left(cComboStat,1)+"' AND "
		EndIf
	EndIf
	If Empty(dDtFinAte) .or. dDtIniAte > dDtFinAte
		dDtFinAte := dDtIniAte 
		oDtFinAte:Refresh()
	EndIf
	cQuery += "VV9.VV9_DATVIS>='"+dtos(dDtIniAte)+"' AND VV9.VV9_DATVIS<='"+dtos(dDtFinAte)+"' AND "
EndIf
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
cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' AND VV9.D_E_L_E_T_=' ' ORDER BY VV9.VV9_DATVIS , VV9.VV9_NUMATE "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
Do While !( cQAlVV0 )->( Eof() )
	cVV9_STATUS := ( cQAlVV0 )->( VV9_STATUS )
	If cVV9_STATUS == "A"
		DbSelectArea("VV1")
		DbSetOrder(1)
		DbSeek( xFilial("VV1") + ( cQAlVV0 )->( VVA_CHAINT ) )
		If VV1->VV1_SITVEI == "1" // 1-Vendido
			cVV9_STATUS := "X"
		EndIf
	EndIf
	If ( cVV9_STATUS == "A" .and. left(cComboStat,1) == "X" ) .or. ( cVV9_STATUS == "X" .and. left(cComboStat,1) == "A" )
		( cQAlVV0 )->( DbSkip() )
		Loop	
	EndIf
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
	cEmpAtu := ""
	nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
   If nEmpAtu > 0 
      cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
   EndIf
	aAdd(aLevPesq,{ ( cQAlVV0 )->( VV9_NUMATE ) , cVV9_STATUS , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV9_DATVIS )) , ( cQAlVV0 )->( VV9_NUMATE ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
	( cQAlVV0 )->( DbSkip() )
EndDo
( cQAlVV0 )->( dbCloseArea() )
If len(aLevPesq) <= 0
	If nCkPerg1 == 1 // Chassi/Cliente
		MsgAlert( STR0095 + " " + cLevChas,STR0040) //Nenhum Atendimento encontrado para o Chassi - Atencao
	Else//If nCkPerg1 == 2 // Status/Periodo
		MsgAlert( STR0096 ,STR0040) //Nenhum Atendimento encontrado - Atencao
	EndIf
		aLevPesq := {{"","","",ctod(""),"",""}}
EndIf
oLbLevPesq:nAt := 1
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
	  							   	aLevPesq[oLbLevPesq:nAt,03],;
	  							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	  							   	aLevPesq[oLbLevPesq:nAt,05],;
	  							   	aLevPesq[oLbLevPesq:nAt,06] }}
oLbLevPesq:Refresh()
Return

Static Function FS_COMBOTIPO()
	oLevChas:lVisible:=.f.
	oTit1:lVisible:=.f.
	oTit2:lVisible:=.f.
	oCoboStat:lVisible:=.f.
  	oDtIniAte:lVisible:=.f.
  	oDtFinAte:lVisible:=.f.
	If nCkPerg1 == 1 // Chassi/Cliente"
		oLevChas:lVisible:=.t.
		oLevChas:SetFocus()
	Else//If nCkPerg1 == 2 // Status/Periodo"
		oTit1:lVisible:=.t.
		oTit2:lVisible:=.t.
		oCoboStat:lVisible:=.t.
		oCoboStat:SetFocus()
	  	oDtIniAte:lVisible:=.t.
	  	oDtFinAte:lVisible:=.t.
	EndIf
Return
