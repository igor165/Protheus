#Include "VEIXA340.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  13/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007368_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIXA340 ³ Autor ³  Fabio                ³ Data ³ 08/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Entrada NF de Veiculos GM                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA340

PRIVATE aRotina := { { STR0001 ,"axPesqui", 0 , 1},;   //Pesquisar
{ STR0002 ,"VXA340"   , 0 , 2},;   //Visualizar
{ STR0003 ,"VXA340"   , 0 , 4},;   //Alterar
{ STR0004 ,"VXA340"   , 0 , 5},;   //Excluir
{ STR0005 ,"Processa( {|| VXA340IMP() } )"  , 0 , 3}}    //Importar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006)   //"Garantia Solicitada VW" //"Importacao do Retorno de Garantia da Fabrica"
Private cMarcar:=GetMark()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Markbrow("VIV","VIV_OK","FS_FILVXA340BROW()",,.f.,cMarcar)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXA340     ºAutor  ³Fabio               º Data ³  09/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA340(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local cTitulo , cAliasEnchoice
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice:={}

aRotina := { { "","",0 , 1},;
{ "","",0 , 2},;
{ "","",0 , 3},;
{ "","",0 , 4},;
{ "","",0 , 5 }}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VIV",.t.)         // .t. para carregar campos virtuais

If nOpc == 2
	nOpcE := 2
	nOpcG := 2
ElseIf nOpc == 3
	nOpc  := 4
	nOpcE := 4
	nOpcG := 4
Else
	nOpc  := 5
	nOpcE := 5
	nOpcG := 5
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VIV")

While !Eof().and.(x3_arquivo=="VIV")
	if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $[VIV_CODCON/VIV_TIPREG/VIV_DATRET])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	dbSkip()
End

If nOpc # 3
	DbSelectArea("VIV")
	For nCntFor := 1 To FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

cTitulo       :=STR0001    //"Entrada NF Peca"
cAliasEnchoice:="VIV"

DEFINE MSDIALOG oDlg1 TITLE cTitulo From 9,0 to 44,80	of oMainWnd

EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,262,315},,3,,,,,,.F.)

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||nOpca:=1,If(!obrigatorio(aGets,aTela),nOpca := 0,If(FS_GRAVXA340(nOpc),oDlg1:End(),nOpca := 0) )},{||nOpca := 0,oDlg1:End()})

DbSelectArea("VIV")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAIA00ºAutor  ³Fabio               º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Importacao                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVXA340(nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

&& Grava Arquivo Pai
DbSelectArea("VIV")
If nOpc == 4
	
	If !RecLock("VIV",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	FG_GRAVAR("VIV")
	MsUnlock()
	
ElseIf nOpc == 5
	
	DbSelectArea("VIV")
	
	If !RecLock("VIV",.F.,.T.)
		
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
		
	EndIf
	
	DbDelete()
	MsUnLock()
	WRITESX2("VIV")
	
EndIf

End Transaction

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXA340IMP  ºAutor  ³Fabio               º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Importacao                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA340IMP(cAlias,nReg,nOpc)
Local aRet := {}
Local aParamBox := {}
Local nBarra  := 0
Local cLocPad := GetNewPAr("MV_LOCVEIN","VN")
Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lMsFinalAuto := .f.

VZL->(DBSetOrder(1))
aAdd(aParamBox,{1,"Armazém",Space(2),"","((M->VVG_LOCPAD := MV_PAR01) == MV_PAR01) .AND. VZL->(DBSeek(xFilial('VZL')+MV_PAR01))","NNR","",0,.F.})
aAdd(aParamBox,{1,"Localizacao",Space(15),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,.F.})

If !MsgYesNo(OemToAnsi(STR0007), OemToAnsi(STR0008))
	Return
EndIf


// If !( Upper(VIV->VIV_TIPPLA) $ "CVF" )
If Empty(VIV->VIV_TIPPLA)
	MsgStop(STR0009+ Chr(13)+Chr(10)+STR0011+VIV->VIV_TIPPLA+ Chr(13)+Chr(10),STR0010)
	Return
EndIf

DbSelectArea("VE4")
DbSetOrder(1)

DbSelectArea("VVC")
DbSetOrder(2)

DbSelectArea("VIV")
DbSeek( xFilial("VIV") )
Count to nBarra For VIV->VIV_FILIAL == xFilial("VIV") .And. IsMark("VIV_OK",ThisMark(),ThisInv())

ProcRegua( nBarra )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

DbSeek( xFilial("VIV") )
M->VVG_LOCPAD := space(TamSX3("VVG_LOCPAD")[1])
M->VVG_LOCALI := space(TamSX3("VVG_LOCALI")[1])
Do While !Eof() .And. VIV->VIV_FILIAL == xFilial("VIV")
	cLocalizacao := space(15)
	If IsMark("VIV_OK",ThisMark(),ThisInv()) .And. !FS_FILVXA340BROW()
		if TCCanOpen(RetSQLName("VZL")) // USA LOCALIZACAO DE VEICULOS
			If !(ParamBox(aParamBox,"Localizacao de Veiculos - "+Alltrim(VIV->VIV_CHASSI),@aRet))
				DbSelectArea("VIV")
				if MsgYesNo("Deseja efetuar a entrada do veiculo sem localizacao ?","Atencao")
					DbSkip()
				Endif
				loop
			else
				cLocPad := aRet[1]
				cLocalizacao := aRet[2]
			Endif
		endif

		VE4->(DbSeek(xFilial("VE4")+VIV->VIV_CODMAR))

		xAutoCab := {}
		aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")    ,Nil})
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"               ,Nil})
		aAdd(xAutoCab,{"VVF_OPEMOV"  ,"0"               ,Nil})
		aAdd(xAutoCab,{"VVF_DATMOV"  ,dDataBase         ,Nil})
		aAdd(xAutoCab,{"VVF_DATEMI"  ,VIV->VIV_DATNFI   ,Nil})
		aAdd(xAutoCab,{"VVF_CODFOR"  ,VE4->VE4_CODFOR   ,Nil})
		aAdd(xAutoCab,{"VVF_LOJA"    ,VE4->VE4_LOJFOR   ,Nil})
		aAdd(xAutoCab,{"VVF_FORPAG"  ,VIV->VIV_CONPAG   ,Nil})
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,VIV->VIV_NUMNFI   ,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,VIV->VIV_SERNFI   ,Nil})
		aAdd(xAutoCab,{"VVF_VALMOV"  ,VIV->VIV_VALOR    ,Nil})
		aAdd(xAutoCab,{"VVF_NUMPED"  ,VIV->VIV_CODPED   ,Nil})
		//
		xAutoItens := {}
		xAutoIten := {}
		aAdd(xAutoIten,{"VVG_FILIAL"  ,xFilial("VVG")    ,Nil})
		aAdd(xAutoIten,{"VVG_CHASSI"  ,VIV->VIV_CHASSI   ,Nil})
		aAdd(xAutoIten,{"VVG_CODTES"  ,VE4->VE4_TESENT   ,Nil})
		aAdd(xAutoIten,{"VVG_ESTVEI"  ,"0"               ,Nil})
		aAdd(xAutoIten,{"VVG_CODORI"  ,"0"               ,Nil})
		aAdd(xAutoIten,{"VVG_LOCPAD"  ,cLocPad           ,Nil})
		aAdd(xAutoIten,{"VVG_SITTRI"  ,"0"               ,Nil})
		aAdd(xAutoIten,{"VVG_VALUNI"  ,VIV->VIV_VALOR    ,Nil})
		aAdd(xAutoIten,{"VVG_VCNVEI"  ,VIV->VIV_VALOR    ,Nil})
		aAdd(xAutoIten,{"VVG_VBAICM"  ,VIV->VIV_BAICMS    ,Nil})
		aAdd(xAutoIten,{"VVG_ALIICM"  ,VIV->VIV_ALICMS     ,Nil})
		aAdd(xAutoIten,{"VVG_ICMCOM"  ,VIV->VIV_TOTICM    ,Nil})
		aAdd(xAutoIten,{"VVG_ALIIPI"  ,VIV->VIV_ALIPI    ,Nil})
		aAdd(xAutoIten,{"VVG_VALIPI"  ,VIV->VIV_TOTIPI    ,Nil})
		aAdd(xAutoIten,{"VVG_VBICRT"  ,VIV->VIV_BICMSU    ,Nil})
		aAdd(xAutoIten,{"VVG_ICMRET"  ,VIV->VIV_ICMSUB    ,Nil})
		aAdd(xAutoIten,{"VVG_TOTSEG"  ,VIV->VIV_SEGURO    ,Nil})
		aAdd(xAutoIten,{"VVG_VALDES"  ,VIV->VIV_DESCON    ,Nil})
		aAdd(xAutoIten,{"VVG_CODIND"  ,VIV->VIV_TIPPLA    ,Nil})
		aAdd(xAutoIten,{"VVG_PISENT"  ,VIV->VIV_PISSUB    ,Nil})
		aAdd(xAutoIten,{"VVG_COFENT"  ,VIV->VIV_COFSUB    ,Nil})
		if TCCanOpen(RetSQLName("VZL")) // USA LOCALIZACAO DE VEICULOS
			aAdd(xAutoIten,{"VVG_LOCALI"  ,cLocalizacao    ,Nil})
		endif
		aAdd(xAutoItens,xAutoIten)
		//
		xAutoVeic := {}
		aAdd(xAutoVeic,{"VV1_FILIAL"  ,xFilial("VV1")    ,Nil})
		aAdd(xAutoVeic,{"VV1_STATUS"  ,xFilial("SD2")    ,Nil})  // << ---- ATUALIZAR
		aAdd(xAutoVeic,{"VV1_RENAVA"  ,"0000000000"   	,Nil})		// <<--- de onde pegar???
		aAdd(xAutoVeic,{"VV1_CODMAR"  ,VIV->VIV_CODMAR   ,Nil})
		aAdd(xAutoVeic,{"VV1_MODVEI"  ,VIV->VIV_MODVEI   ,Nil})
		aAdd(xAutoVeic,{"VV1_PEDFAB"  ,VIV->VIV_CODPED   ,Nil})
		aAdd(xAutoVeic,{"VV1_FABMOD"  ,VIV->VIV_FABMOD   ,Nil})
		aAdd(xAutoVeic,{"VV1_CHASSI"  ,VIV->VIV_CHASSI   ,Nil})
		aAdd(xAutoVeic,{"VV1_TIPCAB"  ,VIV->VIV_CABINA   ,Nil})
		aAdd(xAutoVeic,{"VV1_CAMBIO"  ,VIV->VIV_CAMBIO   ,Nil})
		aAdd(xAutoVeic,{"VV1_NUMDIF"  ,VIV->VIV_DIFERE   ,Nil})
		aAdd(xAutoVeic,{"VV1_NUMMOT"  ,VIV->VIV_MOTOR    ,Nil})
		DBSelectArea("VJ1")
		DBSetorder(1)
		if DBSeek(xFilial("VJ1") + VIV->VIV_CODMAR + VIV->VIV_CODPED)
			aAdd(xAutoVeic,{"VV1_CORVEI"  ,STRZERO(VJ1->VJ1_CORINT,2)   ,Nil})
			aAdd(xAutoVeic,{"VV1_CORFXA"  ,STRZERO(VJ1->VJ1_COREXT,2)   ,Nil})
		endif
//		aAdd(xAutoVeic,{"VV1_CORVEI"  ,VIV->VIV_COREXT   ,Nil})
//		aAdd(xAutoVeic,{"VV1_CORFXA"  ,VIV->VIV_CORINT   ,Nil})
		aAdd(xAutoVeic,{"VV1_OPCFAB"  ,VIV->VIV_OPCION   ,Nil})
		if Vv1->(FieldPos("VV1_CODCHA")) > 0
			aAdd(xAutoVeic,{"VV1_CODCHA"  ,VIV->VIV_CODCHA   ,Nil})
		endif
		//
		aAdd(xAutoVeic,{"VV1_ESTVEI"  ,"0"               ,Nil})
		//
		if VVC->(dbSeek(xFilial("VVC")+VIV->VIV_CODMAR+AllTrim(VIV->VIV_COREXT)))
			aAdd(xAutoVeic,{"VV1_CORVEI"  ,VVC->VVC_CODCOR      ,Nil})
		Endif
		//
		DBSelectArea("VJ1")
		DBSetOrder(1)
		if DBSeek(xFilial("VJ1")+VIV->VIV_CODMAR+VIV->VIV_CODPED)
			reclock("VJ1",.f.)
			VJ1->VJ1_NUMNFI := VIV->VIV_NUMNFI
			msunlock()
		endif
		//
		If ExistBlock("PEVX340AI")
			lRet := ExecBlock("PEVX340AI",.f.,.f.,{xAutoCab,xAutoItens,xAutoVeic})
      Else
			DBSelectArea("VV1")
			DBSetorder(2)
			lRet := .t.
			if !DBSeek(xFilial("VV1")+VIV->VIV_CHASSI)
				MSExecAuto({|x,y| VEIXA010(x,y)},xAutoVeic,3) 
			endif
			if !lRet .or. lMsErroAuto
				DisarmTransaction()
				MostraErro()
				return .f.
			endif
			if lRet
				MSExecAuto({|x,y,w,z,k| VEIXX000(x,y,w,z,k)},xAutoCab,xAutoItens,{},3,"0" )
			endif
			if !lRet .or. lMsErroAuto
				DisarmTransaction()
				MostraErro()
				return .f.
			endif
			//
			if lRet == NIL
				lRet := .t.
			endif
      Endif		        
		//
		if lRet
			&& Deleta o registro apos importacao
			DbSelectArea("VIV")
			If !RecLock("VIV",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				DisarmTransaction()
				Break
			EndIf
			DbDelete()
			MsUnLock()
			WRITESX2("VIV")
			If ExistBlock("OFA340DPG")
				ExecBlock("OFA340DPG",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_CODFOR,VVF->VVF_LOJA})
         Endif
		Endif		
	EndIf
	
	DbSelectArea("VIV")
	DbSkip()
	
EndDo

End Transaction

If lMsErroAuto
	
	MostraErro()
	
EndIf

DbSelectArea("VIV")

Return( !lMsErroAuto )


Function FS_FILVXA340BROW()

DbSelectArea("SF1")
DbSetOrder(1)
If DbSeek(xFilial('SF1')+VIV->VIV_NUMNFI+VIV->VIV_SERNFI)
	DbSelectArea("VIV")
	Return(.t.)
EndIf

DbSelectArea("VIV")

Return(.f.)
