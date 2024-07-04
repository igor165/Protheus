#INCLUDE "HSPAHP44.ch"

#include "protheus.ch"

Static __cSize, __nType

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHP44 บ Autor ณGilson da Silva     บ Data ณ  08/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณImpressao de Fichas Referentes ao Setor de Atendimento      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpl01 - Determina se o Browse ja vem marcado ou nao        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ   
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณMARCELO JOSEณ        ณXXXXXXณImprime pagina em branco no comeco e no   ณฑฑ
ฑฑณ            ณ        ณ      ณfim/relatorios deposicionados no OurSpool ณฑฑ
ฑฑณMARCELO JOSEณ03/11   ณXXXXXXณrelatorio  + etiqueta imprime pag bco fim ณฑฑ
ฑฑณMARCELO JOSEณ08/11   ณXXXXXXณrelatorio+etiq+etiq nao imp. 2 mod. etiq  ณฑฑ
ฑฑณMARCELO JOSEณ18/11   ณXXXXXXณetiq+etiq imp. pag em branco              ณฑฑ
ฑฑณMARCELO JOSEณ24/02/06ณXXXXXXณ ACRESCENTOU PARAMETRO aPosici            ณฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHP44(lMarca,cLocAte,aPosici, lVldUseBlq)
Local aArea     := GetArea()
Local aButtons := {}
Local nOpcGDN  := 0
Local oDlgGDN
Local nCont    := 0
Local cAlias   := Alias()

Local aHGDN    := {}
Local aCGDN    := {}
Local nUGDN    := 0
Local aHGTQ    := {}
Local aCGTQ    := {}
Local nUGTQ    := 0
Local cLstGDN  := ("GDN_CODFIC|GDN_NOMFIC|GDN_FUNCAO|GDN_NVIAS |GDN_TPFONT|GDN_TAMLIN|GDN_QTLIN |GDN_MODIMP")
//Local cLstGTQ  := ("GTQ_CODIGO|GTQ_DESCR|GTQ_TIPIMP|GTQ_PREVIW|GTQ_MODIMP")
Local aCpoEdit := {"GDN_NVIAS "}
Local cCondGDN //:= "GDN->GDN_CODLOC == '" + cLocAte + "'"
Local nCtaPos  := 0
Local nModImp  := 0
Local nNVias   := 0
Local nFuncao  := 0
Local nTpFont  := 0
Local nTamLin  := 0
Local nIdMarc  := 0
Local nQtLin   := 0
Local nNomFic  := 0
Local oPreview
Local lPreview := .T.
Local oGDNNewGet
Local aREtq    := {}
Local aRTxt    := {}
Local aRImg    := {}
Local bFS_GDN 	:= {|| FS_Mark(oGDNNewGet, nIdmarc)}
Local cFicBlq  := ""
Local lUtLayRel:= SuperGetMV("MV_UTLAYRE", NIL, .F.)
Local aJoinGtt := {}

Local aRetPE	:= {}
Local nCodFicPE	:= 0
 
Private lMarca_Ok := .F.

DEFAULT lMarca      := .F.
DEFAULT aPosici     := {}
DEFAULT lVldUseBlq  := .T.
DEFAULT cLocAte		:= ""	


cCondGDN := "GDN->GDN_CODLOC == '" + cLocAte + "'"
//Adciona o botao na enchoicebar
aAdd(aButtons	, {"edit_ocean", {|| Eval(bFS_GDN)}, STR0003}) //"Marca ou Desmarca Todos"

If Len(aPosici) > 0
	For nCtaPos := 1 to Len(aPosici)
		dbSelectArea( aPosici[nCtaPos,1] )
		DBSetOrder( aPosici[nCtaPos,2] )
		DbSeek(xFilial(aPosici[nCtaPos,1]) + aPosici[nCtaPos,3] )
	Next
	RestArea(aArea)
EndIf

DEFINE MSDIALOG oDlgGDN TITLE OemtoAnsi(Substr(STR0002,1,20)) FROM  01, 01 TO 30, 100 OF oMainWnd // //"Impressao de Fichas Referentes ao Setor de Atendimento"

If lUtLayRel
	@ 015, 001 FOLDER oFolRel SIZE 400, 210  OF oDlgGDN PIXEL PROMPTS "Setor", "Geral"
	//oFolRel:Align := CONTROL_ALIGN_ALLCLIENT
EndIf


If lMarca
	HS_BDados("GDN", @aHGDN, @aCGDN, @nUGDN, 1, GDN->GDN_CODLOC, cCondGDN,,,cLstGDN,,,,"GDN_IDMARC","IIf(GDN_PADRAO == '0', 'LBNO', 'LBTIK')", .T.,,.F.)
Else
	HS_BDados("GDN", @aHGDN, @aCGDN, @nUGDN, 1, GDN->GDN_CODLOC, cCondGDN,,,cLstGDN,,,,"GDN_IDMARC", "'LBNO'", .T.,,.F.)
EndIf

nNVias  := aScan(aHGDN, {| aVet | aVet[2] == "GDN_NVIAS "})
nFuncao := aScan(aHGDN, {| aVet | aVet[2] == "GDN_FUNCAO"})
nTpFont := aScan(aHGDN, {| aVet | aVet[2] == "GDN_TPFONT"})
nTamLin := aScan(aHGDN, {| aVet | aVet[2] == "GDN_TAMLIN"})
nIdMarc := aScan(aHGDN, {| aVet | aVet[2] == "GDN_IDMARC"})
nModImp := aScan(aHGDN, {| aVet | aVet[2] == "GDN_MODIMP"})
nQtLin  := aScan(aHGDN, {| aVet | aVet[2] == "GDN_QTLIN "})
nNomFic := aScan(aHGDN, {| aVet | aVet[2] == "GDN_NOMFIC"})

@ 016, 005 CheckBox oPreview Var lPreview Prompt "Visualizar" Size 50, 10 Of oDlgGDN PIXEL

If lUtLayRel
	oGDNNewGet := MsNewGetDados():New(001, 001, 190, 391, GD_UPDATE,,,, aCpoEdit,,,,,, oFolRel:aDialogs[1], aHGDN, aCGDN)
	oGDNNewGet:oBrowse:BlDblClick := {|| IIf(oGDNNewGet:oBrowse:nColPos <> nNVias, FS_DblClk( oGDNNewGet, nIdMarc, nNVias), oGDNNewGet:EDITCELL(oGDNNewGet:OBROWSE, oGDNNewGet:oBrowse:nAt, oGDNNewGet:oBrowse:nColPos))}
Else
	oGDNNewGet := MsNewGetDados():New(030, 001, 217, 391, GD_UPDATE,,,, aCpoEdit,,,,,, oDlgGDN, aHGDN, aCGDN)
	oGDNNewGet:oBrowse:BlDblClick := {|| IIf(oGDNNewGet:oBrowse:nColPos <> nNVias, FS_DblClk( oGDNNewGet, nIdMarc, nNVias), oGDNNewGet:EDITCELL(oGDNNewGet:OBROWSE, oGDNNewGet:oBrowse:nAt, oGDNNewGet:oBrowse:nColPos))}
Endif

  

If lUtLayRel
	aJoinGtt := {{" JOIN " + RetSqlName("GTT") + " GTT", "", "GTT.GTT_FILIAL = '" + xFilial("GTT") + "' AND GTT.D_E_L_E_T_ <> '*' AND GTT.GTT_CODLAY = GTQ.GTQ_CODIGO AND GTT.GTT_CODUSU = '" + cUsername + "'", ""}}

	HS_BDados("GTQ", @aHGTQ, @aCGTQ, @nUGTQ, 1,, "GTQ_TIPPER = '0' AND GTQ_ATIVO = '1'",,,,,,,"GTQ_IDMARC","'LBNO'", ,,.F.) //GTQ  GTT
	aHGTQ := {}
	nUGTQ := 0
	HS_BDados("GTQ", @aHGTQ, @aCGTQ, @nUGTQ, 1,, "GTQ_TIPPER = '1' AND GTQ_ATIVO = '1'",,,,,,,"GTQ_IDMARC","'LBNO'", ,,.F.,,,,,aJoinGtt) //GTQ  GTT	
	nGTQCodigo := aScan(aHGTQ, {| aVet | aVet[2] == "GTQ_CODIGO"})
	nQTQIdMarc := aScan(aHGTQ, {| aVet | aVet[2] == "GTQ_IDMARC"})
	nQTQTipImp := aScan(aHGTQ, {| aVet | aVet[2] == "GTQ_TIPIMP"})	
	
		
		
	oGTQNewGet := MsNewGetDados():New(001, 001, 190, 391, GD_UPDATE,,,,,,,,,, oFolRel:aDialogs[2], aHGTQ, aCGTQ)
	oGTQNewGet:oBrowse:BlDblClick := {|| FS_DblClk( oGTQNewGet, nIdMarc, nNVias)}
	If Empty(oGDNNewGet:aCols[1, nNomFic])
		oFolRel:aDialogs[1]:Disable()
	Endif
	If Empty(oGTQNewGet:aCols[1, nGTQCodigo])
		oFolRel:aDialogs[2]:Disable()
	Endif	
EndIf

	
ACTIVATE MSDIALOG oDlgGDN CENTERED ON INIT (EnChoiceBar(oDlgGDN, {|| nOpcGDN := 1, IIf(FS_VldGer(), oDlgGDN:End(), .F.)}, {|| nOpcGDN := 0, oDlgGDN:End()},,aButtons))

If nOpcGDN == 1 // Opera็ใo confirmada
 	If ExistBlock("HSP44FCH")
   	
		aRetPE := ExecBlock("HSP44FCH",.F.,.F.,{oGDNNewGet:aHeader,oGDNNewGet:aCols,oGDNNewGet:nAt,cLocAte,GCY->GCY_REGATE})
		
		If !EMPTY(aRetPE)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Ajusta as informacoes do aCols com o resultado retornado do PE HSP44FCH 	ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nCont := 1 To Len(oGDNNewGet:aCols)
				nCodFicPE := aScan(aRetPE, { |aVet| aVet[1] == oGDNNewGet:aCols[nCont,2] })
				If nCodFicPE <> 0
					oGDNNewGet:aCols[nCont,nIdMarc] := IIf(!aRetPE[nCodFicPE,2],"LBNO","LBTIK") // Exclui a sele็ใo
				EndIf
			Next nCont
			
		EndIf	
  	EndIf
 	
	For nCont := 1  To Len(oGDNNewGet:aCols)
		If oGDNNewGet:aCols[nCont,nIdMarc] == "LBTIK"
			//HSPFITXT(cNomeArq, cModImp, nQtdLin, nQtdVias, cTPFont, cTamLin)
			//0=Modo Texto Com Cabecalho, 1=Modo Texto Sem Cabecalho ou 2=Ficha Padrใo Modo Texto

			//Valida็ใo usuario bloq/Ficha
			If lVldUseBlq
				DbSelectArea("GGY")
				DbSetOrder(2) //FILIAL + NOMFIC
				If DbSeek(xFilial("GGY") + UPPER(PADR(oGDNNewGet:aCols[nCont, nFuncao], Len(GGY->GGY_FUNCAO))) )
					DbSelectArea("GHW")
					DbSetOrder(2) //FILIAL + CODFIC + CODUSU
					If DbSeek(xFilial("GHW") + GGY->GGY_CODFIC + cUserName )
						cFicBlq += IIF(!Empty(cFicBlq), CHR(10), "") + oGDNNewGet:aCols[nCont, nNomFic]
						Loop
					EndIf
				EndIf
			EndIf

			If oGDNNewGet:aCols[nCont][nModImp] $ "012"
				aAdd(aRTxt, {AllTrim(    oGDNNewGet:aCols[nCont, nFuncao]) , ;
					AllTrim(Str(oGDNNewGet:aCols[nCont, nNVias ])), ;
					oGDNNewGet:aCols[nCont, nModImp]  , ;
					AllTrim(Str(oGDNNewGet:aCols[nCont, nQtLin ])), ;
					oGDNNewGet:aCols[nCont, nTPFont]  , ;
					oGDNNewGet:aCols[nCont, nTamLin] ,;
					""})

//3=Ficha Padrใo Modo Imagem ou 4=Modo Imagem
			ElseIf oGDNNewGet:aCols[nCont][nModImp] $ "34"
				aAdd(aRImg, {AllTrim(    oGDNNewGet:aCols[nCont, nFuncao]) , ;
					AllTrim(Str(oGDNNewGet:aCols[nCont, nNVias ])), ;
					oGDNNewGet:aCols[nCont, nModImp]  , ;
					AllTrim(Str(oGDNNewGet:aCols[nCont, nQtLin ])), ;
					oGDNNewGet:aCols[nCont, nTPFont]  , ;
					oGDNNewGet:aCols[nCont, nTamLin] ,;
					""})

			//HSPAHR71(cCodEti, aParam, lCtrlQtd)
			// 5=Etiqetas
			ElseIf oGDNNewGet:aCols[nCont][nModImp] == "5"
				aAdd(aREtq, {AllTrim(oGDNNewGet:aCols[nCont, nFuncao]), oGDNNewGet:aCols[nCont, nNVias]})

			EndIf
		Endif
	Next

	If lUtLayRel
		For nCont := 1  To Len(oGTQNewGet:aCols)  
			If oGTQNewGet:aCols[nCont,nQTQIdMarc] == "LBTIK"
			
				If oGTQNewGet:aCols[nCont][nQTQTipImp] == "0"
						aAdd(aRTxt, {    "HSPM63" + AllTrim(oGTQNewGet:aCols[nCont, nGTQCodigo ]) + ".txt" , ;
						"1", ;
						"1"  , ;
						"55", ;
						"2"  , ;
						"2" ,;
						AllTrim(oGTQNewGet:aCols[nCont, nGTQCodigo ])})
	
	//3=Ficha Padrใo Modo Imagem ou 4=Modo Imagem
				ElseIf oGTQNewGet:aCols[nCont][nQTQTipImp] == "1"
						aAdd(aRImg, { "HSPM63" + AllTrim(oGTQNewGet:aCols[nCont, nGTQCodigo ]) + ".txt" , ;
						"1", ;
						"4"  , ;
						"55", ;
						"2"  , ;
						"2" ,;
						AllTrim(oGTQNewGet:aCols[nCont, nGTQCodigo ])})
				EndIf
			
			EndIf
		Next nCont
	EndIf
	
	If !Empty(cFicBlq)
		HS_MsgInf(STR0004 + CHR(10) + cFicBlq, STR0005, STR0006) //"Usuแrio sem permissใo para imprimir as fichas:"###"Aten็ใo"###"Valida็ใo de impressใo de Fichas por usuแrio"
	EndIf

	HS_CtrlImp(cAlias, "HSPAHP44", IIf(lUtLayRel, "Fichas", STR0007), "P", lPreview, aRTxt, aRImg, aREtq) // STR0004 //"Fichas do Atendimento"
	

	
EndIf

RestArea(aArea)

Return(Nil)

Function HS_CtrlImp(cAlias, cNonRel, cTitRel, cTamRel, lPreview, aRTxt, aRImg, aREtq, aPosArq, aExec)
Local nCont := 0, aArea := GetArea(), nFQtVias := 0
Local nPFuncao := 1
Local nPQtVias := 2
Local nPModImp := 3
Local nPQtdLin := 4
Local nPTpFont := 5
Local nPTamLin := 6
Local nCodPers := 7
Local nPArq    := 1
Local nQtdVia  := 0
Local nContVia := 0
Local lUtLayRel:= SuperGetMV("MV_UTLAYRE", NIL, .F.)
Local aHGTS	 := {}
Local aCGTS	 := {}
Local cModImp	 := ""
Local cDirectHTML := ""

Private __nPagFic := 0
Private M_PAG     := 0
Private cNomeRel  := cNonRel
Private cTitulo   := cTitRel
Private aReturn   := {STR0008,  1 ,STR0009 , 2, 2, 1, "", 1} //"Zebrado"###"Administracao"  4- PARAMETRO COMO 1=COMPRIME  2=NORMAL //"Zebrado"###"Administracao"
Private nLastKey  := 0
Private oPrint
Private aDadosEmp	:= {SM0->M0_NOMECOM					                          , ; // Nome da Empresa
						AllTrim(SM0->M0_ENDCOB)				                    , ; // Endereco
						AllTrim(SM0->M0_BAIRCOB)			                    , ; // Bairro
						AllTrim(SM0->M0_CIDCOB)				                    , ; // Cidade
						SM0->M0_ESTCOB						                           , ; // UF
						Transform(SM0->M0_CEPCOB, "@R 99999-999")      ,	; // CEP
						AllTrim(SM0->M0_TEL)     			                   , ;	// Telefone
						AllTrim(SM0->M0_FAX)     			                   , ;	// Fax
						Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), ; // CGC
						Transform(SM0->M0_INSC, "@R 999.999.999.999")}    	// I.E

Default aPosArq := {}
Default aExec   := {}

//aPoArq = {alias, ordem, chave}
For nPArq := 1 To Len(aPosArq)
	(aPosArq[nPArq][1])->(DbSetOrder(aPosArq[nPArq][2]))
	(aPosArq[nPArq][1])->(DbSeek(xFilial(aPosArq[nPArq][1]) + aPosArq[nPArq][3]))
Next

For nPArq := 1 To Len(aExec)
	&(aExec[nPArq])
Next

// Impressใo Modo Texto
If Len(aRTxt) > 0

	For nCont := 1  To Len(aRTxt)
		nQtdVia := 1

		If aRTxt[nCont, nPModImp] $ "01"
			aRTxt[nCont, nPFuncao] := "HSPFITXT('" + ;
				aRTxt[nCont, nPFuncao] + "', '" + aRTxt[nCont, nPModImp] + "', " + aRTxt[nCont, nPQtdLin] + ", " + ;
				aRTxt[nCont, nPQtVias] + ", '" + aRTxt[nCont, nPTpFont] + "', '" + aRTxt[nCont, nPTamLin] + "')"

		Else
			cNomeRel   := "HSPAHF" + aRTxt[nCont, nPFuncao]
			aRTxt[nCont, nPFuncao] := "HSPAHF" + aRTxt[nCont, nPFuncao]+"()"
			aReturn[6] := cNomeRel
			nQtdVia    := VAL(aRTxt[nCont, nPQtVias])
		EndIf

		cTitulo  := cTitRel
		cNomeRel := SetPrint(cAlias, cNomeRel, "", @cTitulo, "", "", "", .T., "", .T., cTamRel,, .T.)
		If nLastKey == 27
			RestArea(aArea)
			Return(Nil)
		Endif

		RestArea(aArea)

		aReturn[4] := Val(aRTxt[nCont, nPTpFont])  //Tipo da Fonte se Comprimido ou Normal

		SetDefault(aReturn, cAlias)//,,, aRTxt[1, nPTamLin])

		__SetAskSubs(.F.)
		H44SetTam(aRTxt[nCont, nPTamLin])
		H44SetTip(IIf(aReturn[4] == 1, 15, 18))

		nTipo := IIf(aReturn[4] == 1, 15, 18)
		// Executa relat๓rio personalizavel da rotina HSPAHM63
		If lUtLayRel .AND. Len(aRTxt[nCont] > 6)
			If !Empty(aRTxt[nCont, nCodPers])
				aCGTS := {}
				aHGTS := {}			
				DbSelectArea("GTQ")
				DbGoTop()
				DbSetOrder(1)					
				If GTQ->(MsSeek(xFilial("GTQ") + aRTxt[nCont, nCodPers]))
					HS_MacGTQ(GTQ->GTQ_MACRO) // Executa os macros existentes
					HS_BDados("GTS", @aHGTS, @aCGTS,,1,, "GTS->GTS_CODLAY = '" + aRTxt[nCont, nCodPers] + "'",,,,,,,,,,,,,,,,,,)		    
					nGTSArquiv := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_ARQUIV"})
					nGTSIndice := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_INDICE"})
					nGTSDado   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_DADO"})					
					nGTSOrdExe   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_ORDEXE"})
					
					HS_EXEGTS(aCGTS,nGTSArquiv, nGTSOrdExe, nGTSDado,nGTSIndice)
					
				EndIf
			EndIf
		EndIf

		&(aRTxt[nCont, nPFuncao])

		If aReturn[5] == 1 .And. lPreview
			For nContVia :=  1 To nQtdVia
				OurSpool(cNomeRel)
			Next
		EndIf

		Ms_Flush()

	Next

EndIf

// Impressใo Modo Imagem
If Len(aRImg) > 0
	oPrint := TMSPrinter():New("Fichas")
	If !(oPrint:Setup())
		oPrint:End()
		RestArea(aArea)
		Return(Nil)
	EndIf

	For nCont := 1  To Len(aRImg)

		RestArea(aArea)

		If aRImg[nCont, nPModImp] == "3" //3=Ficha Padrใo Modo Imagem
			aRImg[nCont, nPFuncao] := "HSPAHF" + aRImg[nCont, nPFuncao]+"('" + aRImg[nCont, nPModImp] + "', " + aRImg[nCont, nPQtVias] + ")"

		Else //4=Modo Imagem
			aRImg[nCont, nPFuncao] := "HSPFITXT('" + ;
				aRImg[nCont, nPFuncao] + "', '" + aRImg[nCont, nPModImp] + "', " + aRImg[nCont, nPQtdLin] + ", " + ;
				aRImg[nCont, nPQtVias] + ", '" + aRImg[nCont, nPTpFont] + "', '" + aRImg[nCont, nPTamLin] + "')"

		EndIf
		// Executa relat๓rio personalizavel da rotina HSPAHM63
		If lUtLayRel .AND. Len(aRImg[nCont]) > 6	
			If !Empty(aRImg[nCont, nCodPers])
				aCGTS := {}
				aHGTS := {}			
				DbSelectArea("GTQ")
				DbGoTop()
				DbSetOrder(1)					
				If GTQ->(MsSeek(xFilial("GTQ") + aRImg[nCont, nCodPers]))
					HS_MacGTQ(GTQ->GTQ_MACRO) // Executa os macros existentes
					HS_BDados("GTS", @aHGTS, @aCGTS,,1,, "GTS->GTS_CODLAY = '" + aRImg[nCont, nCodPers] + "'",,,,,,,,,,,,,,,,,,)		    
					nGTSArquiv := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_ARQUIV"})
					nGTSIndice := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_INDICE"})
					nGTSDado   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_DADO"})					
					nGTSOrdExe   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_ORDEXE"})					
					cDirectHTML := IIf(!Empty(GTQ->GTQ_DIRECT),Alltrim(GTQ->GTQ_DIRECT) + Alltrim(aRImg[nCont, nCodPers]) + Substring(GTQ->GTQ_DESCR,1,15) + " " + Dtos(dDataBase) + ".htm","")
					
					HS_EXEGTS(aCGTS,nGTSArquiv, nGTSOrdExe, nGTSDado,nGTSIndice)
					
				EndIf
			EndIf
		EndIf
		
		&(aRImg[nCont, nPFuncao])

	Next
	/*If !Empty(cModImp)
		
		If cModImp == "1"
			oPrint:SetLandscape()
		Else
			oPrint:SetPortrait()
		EndIf
	EndIf*/
	If lPreview
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf

	oPrint:End()

EndIf

// Impressใo das Etiquetas
If Len( aREtq ) > 0
	For nCont := 1 to Len(aREtq)

		RestArea(aArea)
		aREtq[nCont, nPFuncao] := "HSPAHR71(" + StrTran(aREtq[nCont, nPFuncao], "__QTDEIMP", AllTrim(Str(aREtq[nCont, nPQtVias]))) + ")"
		&(aREtq[nCont, nPFuncao])

	Next
EndIf

RestArea(aArea)

Return(Nil)

/*                                                                                          	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณFS_VldGer ณ Autor ณGilson da Silva        ณ Data ณ14/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Verifica se os campos obrigatorios foram preenchidos       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                            														  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSPAHP44 											                                    	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function FS_VldGer()
 Local lRet := .T.
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClk บ Autor ณGilson da Silva     บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca as fichas para impressao                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ EXPo1 = Objeto da NewGetDados que sera marcado/desmarcada  ณฑฑ
ฑฑบ          ณ EXPn2 = Posicao do Campo de marca no Browse                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(oNewGetD, nCpoPosi, nNVias)
Local lRet := .T.  

If oNewGetD:oBrowse:nColPos <> nNVias 
 If oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] == "LBNO"
	 oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBTIK"
 Else        
	 oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBNO"
 Endif
 oNewGetD:oBrowse:Refresh()
EndIf 

Return(lRet)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Mark   บ Autor ณGilson da Silva     บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca todas as fichas para impressao              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ EXPo1 = Objeto da NewGetDados que sera marcado/desmarcado  ณฑฑ
ฑฑบ          ณ EXPn2 = Posicao do Campo de marca no Browse                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Mark(oNewGetD, nCpoPosi)
Local lRet     := .T.
Local nContFor := 0 

For nContFor := 1 to len(oNewGetD:aCols)
 If lMarca_Ok
  oNewGetD:aCols[nContFor,nCpoPosi] := "LBNO" 	
 Else
 	oNewGetD:aCols[nContFor,nCpoPosi] := "LBTIK"
 Endif 
Next  

lMarca_Ok := !lMarca_Ok

oNewGetD:oBrowse:Refresh()

Return(lRet)
                
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณH44SETTAM บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function H44SetTam(cTam)
__cSize := IIF(cTam == "1", "P", IIF(cTam == "2", "M", "G"))
Return                                                                       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณH44SETTIP บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function H44SetTip(nTipo)
 __nType := nTipo
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณH44GETTAM บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function H44GetTam()
Return __cSize

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณH44GETTIP บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function H44GetTip()
Return __nType
