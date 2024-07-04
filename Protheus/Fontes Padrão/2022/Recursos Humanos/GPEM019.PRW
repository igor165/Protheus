#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM019.CH"

Static lIsBlind
Static lConsig
Static lCpoFlagIC

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM019  ³ Autor ³ Leandro Drumond            ³ Data   ³09/08/2013³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Integracoes com a folha de pagamento.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM019()		                   	                             ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mensal                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³   Data ³   FNC     ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Esther V.   ³31/03/15³TS9103     ³Ajuste para nao realizar integracao caso    ³±±
±±³            ³        ³           ³não haja verba de VR cadastradas.           ³±±
±±³Allyson M   ³29/12/15³TUCPC2     ³Ajuste p/ permitir a integracao do roteiro  ³±±
±±³            ³        ³           ³BEN (tipo I) no calculo de rescisao.        ³±±
±±³P. Pompeu   ³11/03/16³TUPMBA     ³Adicionado Filtro na Função RchIntFields    ³±±
±±³Allyson M   ³06/06/16³TVBNGB     ³Ajuste na validacao de acesso da filial p/  ³±±
±±³            ³        ³           ³caso de filial compartilhado.        	     ³±±
±±³Esther V.   ³23/06/16³           ³Ajuste no filtro da carga da tela quando vem³±±
±±³		       ³		³           ³do GPEM040. Ajuste na definicao do Menu.    ³±±
±±³Leandro Dr. ³01/07/16³TVNVNU     ³Criaçao de funcionalidade para cancelamento ³±±
±±³            ³        ³           ³da integração.                              ³±±
±±³Gabriel A.  ³15/12/16³98624      ³Ajuste na integração de roteiros com número ³±±
±±³            ³        ³MRH-1083   ³de pagamento diferente do fa Folha.         ³±±
±±³Renan Borges³24/01/17³MRH-5410   ³Ajuste para filtrar os registros corretamen-³±±
±±³            ³        ³           ³te na rotina de integrações.                ³±±
±±³Gabriel A.  ³22/03/17³MRH-8354   ³Ajuste na integração chamada pelo GPEM040   ³±±
±±³            ³        ³           ³para que permita trocar o período do filtro.³±±
±±ºRenan Borges³29/03/17³MRH-8998   ³Ajuste para quando realizar o cancelamento  ³±±
±±º            ³        ³           ³ da integração da rescisão seja retornado   ³±±
±±º            ³        ³           ³aos roteiros originais as verbas integra-   ³±±
±±º            ³        ³           ³das. Para a efetivação da correção é neces  ³±±
±±º            ³        ³           ³sário a integração e cancelamento dos da-   ³±±
±±º            ³        ³           ³dos novamente.                              ³±±
±±³Paulo O I   ³13/04/17³DRHPAG-239 ³Melhoria -  remoção de dependencias do ctree³±±
±±³Gabriel A.  ³08/05/17³DRHPAG-1263³Melhora de performance na integração de     ³±±
±±³            ³        ³           ³férias.                                     ³±±
±±³Eduardo K.  ³27/12/17³MPRIMESP-  ³Ajuste p/ somente permitir integrar pgto de ³±±
±±³            ³        ³12665      ³beneficios com o mesmo numero de pagamento  ³±±
±±³            ³        ³	        ³da folha.									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function GPEM019(lCancAut, aIntegra, nOpcM040)

Local aArea			:= GetArea()
Local aAreaRCH		:= RCH->( GetArea() )
Local aColsMark		:= {}
Local aPerAtual		:= {}
Local cIdCab
Local cIdGrid
Local cFilAux		:= cFilAnt
Local lMarcar		:= .F.
Local lGpem040		:= .F.
Local oPanelUp
Local oTela
Local oPanelDown
Local oGroup
LOcal oFont
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bIntegra		:= .F.
Local bCancela		:= {|| GPM019IniProc(.T.) }
Local bInverte		:= {|| fInverte(oMark:Mark()), oMark:Refresh(.T.) }
Local bSelInteg		:= {|| fSelInt(oMark:Mark()), oMark:Refresh(.T.) }

Private aRotMark   	:= {}
Private cFilRCH		:= Space( GetSx3Cache("RCH_FILIAL", "X3_TAMANHO") )
Private cProcFil	:= Space( GetSx3Cache("RCH_PROCES", "X3_TAMANHO") )
Private cRotFil		:= Space( GetSx3Cache("RCH_ROTEIR", "X3_TAMANHO") )
Private cPerFil		:= Space( GetSx3Cache("RCH_PER", "X3_TAMANHO") )
Private cSemFil		:= Space( GetSx3Cache("RCH_NUMPAG", "X3_TAMANHO") )
Private cAliasMark 	:= "TABAUX"
Private oMark
Private oDlgMark	:= Nil
Private oTmpTable   := Nil
Private lIntIc		:= .F.

Default lCancAut    := .F.
Default aIntegra    := {}
Default nOpcM040    := 0
DEFAULT lIsBlind 	:= IsBlind()

lGpem040 := (FunName() == "GPEM040" .And. nOpcM040 == 0)
bIntegra := {|| GPM019IniProc(.F., Nil, nOpcM040) }

If lGpem040
	//Utiliza o processo da rescisão
	cFilRCH		:=  xFilial("RCH")
	cProcFil 	:= cProcesso
	cPerFil		:= cPeriodo
	cSemFil		:= cSemana

	If Empty(cPerFil)
		fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetRotOrdinar() ) // Busca o periodo aberto da folha

		If !Empty(aPerAtual)
			cFilRCH		:=  xFilial("RCH")
			cProcFil	:= 	aPerAtual[1,8]
			//cRotFil	:=	aPerAtual[1,3]
			cPerFil		:=	aPerAtual[1,1]
			cSemFil 	:= 	aPerAtual[1,2]
		Else
			lGpem040	:= .F.
		EndIf
	EndIf
EndIf

If !fCriaTmp(nOpcM040)
	Help( ,, STR0030,, STR0004, 1, 0) //"Nenhum dos roteiros aptos a integração possuem período de cálculo ativo."
EndIf

If !lIsBlind
	DbSelectArea(cAliasMark)

	SET FILTER TO TAB_FIL == ''

	aColsMark:= fMntColsMark()

	aAdvSize	:= MsAdvSize( .F.,.F.,370)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	Define MsDialog oDlgMark FROM 0, 0 To 500, 800 Title STR0001 Pixel  ////"Integrações com a Folha de Pagamento"

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgMark )
	cIdCab	  := oTela:CreateHorizontalBox( 13 )
	cIdGrid   := oTela:CreateHorizontalBox( 80 )

	oTela:Activate( oDlgMark, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdCab )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

		@ 0 , aObjSize[1,2]	GROUP oGroup TO 26,aObjSize[1,4]*0.62 LABEL OemToAnsi(STR0039) OF oPanelUp PIXEL	//"Filtro"
		oGroup:oFont:=oFont

		@ aObjSize[1,1]*0.5, aObjSize[1,2]+1 		SAY   OemToAnsi(GetSx3Cache("RCH_FILIAL", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
		@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+1 	MSGET cFilRCH  PICTURE "@!" SIZE 010,007	OF oPanelUp PIXEL WHEN !lGpem040 F3 'FWSM0' HASBUTTON VALID Gp19VldMark(.T.)

		@ aObjSize[1,1]*0.5, aObjSize[1,2]+80 		SAY   OemToAnsi(GetSx3Cache("RCH_PROCES", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
		@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+80 	MSGET cProcFil  PICTURE "@!" SIZE 010,007	OF oPanelUp PIXEL WHEN !lGpem040 F3 "RCJ" HASBUTTON VALID Gp19VldMark()

		@ aObjSize[1,1]*0.5	, aObjSize[1,2]+160 	SAY   OemToAnsi(GetSx3Cache("RCH_ROTEIR", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
		@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+160	MSGET cRotFil PICTURE "@!" SIZE 010,007	OF oPanelUp PIXEL WHEN !lGpem040 F3 "SRY" HASBUTTON VALID Gp19VldMark()

		@ aObjSize[1,1]*0.5	, aObjSize[1,2]+240		SAY   OemToAnsi(GetSx3Cache("RCH_PER", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
		@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+240	MSGET cPerFil  PICTURE "@!" SIZE 010,007	OF oPanelUp PIXEL HASBUTTON VALID Gp19VldMark()

		@ aObjSize[1,1]*0.5	, aObjSize[1,2]+320		SAY   OemToAnsi(GetSx3Cache("RCH_NUMPAG", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
		@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+320	MSGET cSemFil  PICTURE "@!" SIZE 010,007	OF oPanelUp PIXEL HASBUTTON VALID Gp19VldMark()

	oMark := FWMarkBrowse():New()

	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)

	//Indica o container onde sera criado o browse
	oMark:SetOwner(oPanelDown)

	oMark:bAllMark := { || SetMarkAll(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'TAB_OK')
	oMark:SetValid({||.T.})
	oMark:AddButton(STR0005, bIntegra,,,, .F., 2 ) //'Integrar'
	//Não exibe botão de cancelamento quando chamada for originada pelas rotinas de cálculo.
	If !(FunName() $ "GPEM040*GPEM030*GPEM630")
		oMark:AddButton(STR0042, bCancela,,,, .F., 2 ) //"Cancelar Integração"
		oMark:AddButton(STR0045, bInverte,,,, .F., 2 ) //"Inverter Seleção"
		oMark:AddButton(STR0046, bSelInteg,,,, .F., 2 ) //"Apenas Integrados"
	Else
		oMark:SetMenuDef("GPEM019")
	EndIf

	oMark:AddLegend( "Empty(TAB_INTEG)", "GREEN", STR0002 ) //Apto a integrar
	oMark:AddLegend( "!Empty(TAB_INTEG)", "RED" , STR0003 ) //Integrado

	oMark:Activate()

	If lGPEM040
		Gp19VldMark()
	EndIf

	ACTIVATE MSDIALOG oDlgMark CENTERED
Else
	GPM019IniProc(lCancAut, aIntegra, nOpcM040)
EndIf

oTmpTable:Delete()
oTmpTable := Nil

//Retorna a filial para a que estava logada antes da execução da rotina
cFilAnt := cFilAux
RestArea(aAreaRCH)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GPM019IniProc ³ Autor ³ Leandro Drumond     ³ Data ³10/08/13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicia as integracoes.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		                                   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM019           			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GPM019IniProc(lCancela, aIntegra, nOpcM040)
Local bProcesso		:= {|oSelf| GPM019Processa(oSelf)}
Local cCadastro 	:= STR0001 //"Integrações com a Folha de Pagamento"
Local cDescricao	:= STR0006 //"Este programa efetuará a integração dos roteiros previamente marcados com a folha de pagamento"
Local cMarca 		:= ""
Local lGpem040		:= .F.
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lIntRes		:= .F.

Private aTitle 		:= {}
Private aLog   		:= {}
Private lOfusca		:= Len(aFldRel) > 0
/*Variaveis usada nas integracoes cde VT, VR e VA*/
Private aTamIt		:= TamSx3("RA_ITEM")
Private aTamClVL	:= TamSx3("RA_CLVL")
Private lTemItem	:= !Empty( aTamIt )
Private lTemClVl	:= !Empty( aTamClVl )

DEFAULT lCancela 	:= .F.
DEFAULT aIntegra    := {}
DEFAULT nOpcM040 	:= 0
DEFAULT lIsBlind 	:= IsBlind()
DEFAULT lConsig		:= GetMvRH("MV_CONSIG",, .F.)
DEFAULT lCpoFlagIC	:= ChkFile("SRG") .And. SRG->(ColumnPos( "RG_CONFIC")) > 0 

cMarca 		:= IIf( lIsBlind , "" , oMark:Mark() )
lGpem040	:= (FunName() == "GPEM040" .And. !lIsBlind .And. nOpcM040 == 0)

If lCancela
	cDescricao	:= STR0040 //"Este programa efetuará o cancelamento da integração dos roteiros previamente selecionados."
	bProcesso		:= {|oSelf| GPM019Cancela(oSelf)}
Else
	bProcesso		:= {|oSelf| GPM019Processa(oSelf)}
EndIf

lIntIc := .F.

If !lIsBlind
	DbSelectArea(cAliasMark)
	DbGoTop()

	While !Eof()
		If oMark:IsMark(cMarca)
			If lCancela .and. !Empty(TAB_INTEG)
				aAdd(aRotMark,{TAB_PROC, TAB_ROT, TAB_PER, TAB_NPAG, TAB_TPROT, TAB_DTREF, TAB_FIL,TAB_DESC})
			ElseIf !lCancela .and. Empty(TAB_INTEG)
				aAdd(aRotMark,{TAB_PROC, TAB_ROT, TAB_PER, TAB_NPAG, TAB_TPROT, TAB_DTREF, TAB_FIL,TAB_DESC})
				If TAB_TPROT == "4"
					lIntRes := .T.
				EndIf			
			EndIf
		EndIf

		DbSkip()
	EndDo

	If lIntRes .And. cPaisLoc == "BRA" .And. lConsig .And. lCpoFlagIC .And. MsgYesNo( OemToAnsi( STR0047 ), OemToAnsi( STR0030 ) )//"Deseja enviar a(s) rescisão(ões) para a instituição de crédito?"##"Atenção"
		lIntIc := .T.
	EndIf

	DbGoTop()
Else
	If !Empty(aIntegra)
		aRotMark := AClone(aIntegra)
		lIntIc   := (aScan(aRotMark, {|x| x[5] == "4"}) > 0)
	EndIf
EndIf

If Empty(aRotMark)
	Help( ,, STR0030,, STR0010, 1, 0) //"Nenhum roteiro selecionado."
//	SetMarkAll(oMark:Mark(),.F. )
	oMark:Refresh() //Atualiza markbrowse
	Gp19VldMark()
Else
	If !lIsBlind
		tNewProcess():New( "GPEM019" , cCadastro , bProcesso , cDescricao , "",,,,,.T.)
		If lGpem040
			MsgInfo(OemToAnsi(STR0038), OemToAnsi(STR0001)) //Integração realizada com sucesso!
		EndIf
	Else
		If lCancela
			GPM019Cancela()
		Else
			GPM019Processa()
		EndIf
	EndIf
EndIf

If lGpem040
	oDlgMark:End()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GPM019Processa³ Autor ³ Leandro Drumond     ³ Data ³10/08/13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa as integracoes.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		                                   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM019           			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function GPM019Processa(oSelf)

Local aCodFol		:= {}
Local aFilOk		:= {}
Local aLogAux		:= {}
Local aPerAberto	:= {}
Local cAcessaSRA	:= &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM019" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
Local cFilAux		:= ""
Local cFilBkp		:= ""
Local cCposQuery	:= ""
Local cWhere		:= ""
Local cJoin			:= ""
Local cPdEmp   		:= ""
Local cPdFun   		:= ""
Local cPdTot   		:= ""
Local cAnoMes		:= ""
Local cFilFol 		:= ""
Local cProcFol		:= ""
Local cPerFol		:= ""
Local cSemFol		:= ""
Local cKeyRCH		:= ""
Local dDataRef		:= CtoD("")
Local lIntOk		:= .T.
Local lResFer		:= .F.
Local nPos			:= 0
Local nNumReg		:= 0
Local aPerAtual		:= {}
Local lGPM19INTEG	:= ExistBlock("GPM19INTEG")
Local lGPEM040		:= IsInCallStack("AbreCadastro")
Local lVerFil		:= FWModeAccess("RCH", 1)+FWModeAccess("RCH", 2)+FWModeAccess("RCH", 3) != FWModeAccess("SRY", 1)+FWModeAccess("SRY", 2)+FWModeAccess("SRY", 3) .And. Len(AllTrim(xFilial("RCH"))) < Len(AllTrim(xFilial("SRY")))

Private cAliasSRA	:= "QSRA"
Private cRotBen		:= ""
Private nSobrepor	:= 0	//Usada nas integraoes de VT/VR/VA/PLA.
Private nAgrupa		:= 0	//Usada nas integraoes de VT/VR/VA/PLA.
Private cRotFol		:= ""
Private aVbsForn	:= {}	//Usada na integracao do PLA para obter as verbas de empresa especificas por fornecedor

DEFAULT lIsBlind 	:= IsBlind()

cCposQuery 	:= "%SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, SRA.RA_ITEM, SRA.RA_CLVL, SRA.RA_CATFUNC, SRA.RA_PROCES%"

If !lIsBlind
	oSelf:SetRegua1(Len(aRotMark))
	oSelf:SaveLog( STR0008 + " - " + STR0009) //"Integração com a Folha de Pagamento"##"Inicio do processamento"
EndIf

cFilBkp := cFilAnt

For nPos := 1 to Len(aRotMark)

	If !lIsBlind
		oSelf:IncRegua1(STR0008 + " - " + aRotMark[nPos,1] + "/" + aRotMark[nPos,3] + "/" + aRotMark[nPos,2] + " - " + aRotMark[nPos,8])
	EndIf

	If cKeyRCH <> aRotMark[nPos,7] + aRotMark[nPos,1] + aRotMark[nPos,3] + aRotMark[nPos,4] .Or. aRotMark[nPos,5] $ "3*4" .Or. (nPos - 1 > 0 .And. aRotMark[nPos,5] $ "3*4") .Or. lResFer

		DbSelectArea("RCH")
		DbSetOrder(1)
		If cKeyRCH <> aRotMark[nPos,7] + aRotMark[nPos,1] + aRotMark[nPos,3] + aRotMark[nPos,4] .Or. lResFer
			cKeyRCH := aRotMark[nPos,7] + aRotMark[nPos,1] + aRotMark[nPos,3] + aRotMark[nPos,4]
			If !Dbseek(cKeyRCH + fGetRotOrdinar()) //Busca período da folha
				If !Dbseek(cKeyRCH + fGetCalcRot("9")) //Busca período autonomo
					If !( fGetPerAtual(aPerAtual,aRotMark[nPos,7],aRotMark[nPos,1],fGetRotOrdinar() ) )
						If !( fGetPerAtual(aPerAtual,aRotMark[nPos,7],aRotMark[nPos,1],fGetCalcRot("9") ) )
							Loop //Não possui período para integrar
						Else
							If !( RCH->( MsSeek( aRotMark[nPos,7] + aPerAtual[1][8] + aPerAtual[1][1] + aPerAtual[1][2] + aPerAtual[1][3] ) ) )
								Loop
							EndIf
						EndIf
					Else
						If !( RCH->( MsSeek( aRotMark[nPos,7] + aPerAtual[1][8] + aPerAtual[1][1] + aPerAtual[1][2] + aPerAtual[1][3] ) ) )
							Loop
						ElseIf aRotMark[nPos,5] == "K"
							RCH->(DbSetOrder(6))
							If !( RCH->( MsSeek( aRotMark[nPos,7] + aPerAtual[1][8] +  aPerAtual[1][3] + aRotMark[nPos,3] ) ) ) //verifica se existe rot FOL cadastrado no mesmo período
								aAdd(aTitle, OemToAnsi(STR0033)) //Falha na integracao de roteiro do usuario
								aAdd(aLog,{})
								aAdd(aLog[Len(aLog)], OemToAnsi(STR0044)) //"Não foi encontrado período da folha com a mesma competencia do período de valores extras para integração"
								Loop
							EndIf
						EndIf
					EndIf
				ElseIf cPaisLoc == "BRA" .And. RCH->RCH_STATUS == "2"
					aAdd(aTitle, OemToAnsi(STR0050)) //"Falha na integraçao de roteiro"
					aAdd(aLog,{})
					aAdd(aLog[Len(aLog)], OemToAnsi(STR0048)) //'Roteiro da folha está sendo calculado (RCH_STATUS com "2"), portanto a integração não será realizada.'
					lResFer := aRotMark[nPos,5] $ "3*4"
					Loop
				EndIf
			ElseIf cPaisLoc == "BRA" .And. RCH->RCH_STATUS == "2"
				aAdd(aTitle, OemToAnsi(STR0050)) //"Falha na integraçao de roteiro"
				aAdd(aLog,{})
				aAdd(aLog[Len(aLog)], OemToAnsi(STR0048)) //'Roteiro da folha está sendo calculado (RCH_STATUS com "2"), portanto a integração não será realizada.'
				lResFer := aRotMark[nPos,5] $ "3*4"
				Loop
			EndIf
			If lVerFil
				aFilOk := fBuscFil( aRotMark[nPos, 2] )
			EndIf
		EndIf
		lResFer := aRotMark[nPos,5] $ "3*4"	 //Sempre executa a query de Funcionarios e posiciona na RCH quando o ultimo roteiro processado foi FER ou RES

		If ( Select( cAliasSRA ) > 0 )
			( cAliasSRA )->( dbCloseArea() )
		EndIf

		cFilFol := RCH->RCH_FILIAL
		cProcFol:= RCH->RCH_PROCES
		cRotFol	:= RCH->RCH_ROTEIR
		cPerFol	:= RCH->RCH_PER
		cSemFol	:= RCH->RCH_NUMPAG

		cWhere := "%"
		cWhere += " SRA.RA_PROCES = '" + cProcFol + "' AND"
		If !(aRotMark[nPos,5] $ "3*4*C") .and.  ( !lGPEM040 .or. !lRecRes .or. cCompl == "S") 
			cWhere += " NOT EXISTS( SELECT RG_FILIAL, RG_MAT FROM " + RetSqlName( "SRG" ) + " SRG WHERE SRG.D_E_L_E_T_ = ' ' AND SRG.RG_FILIAL = SRA.RA_FILIAL AND SRG.RG_MAT = SRA.RA_MAT AND SRG.RG_EFETIVA <> 'N' ) AND "
		EndIf
		cWhere += " RCH.RCH_FILIAL = '" + cFilFol + "' AND"
		cWhere += " RCH.RCH_PROCES = '" + cProcFol + "' AND"
		cWhere += " RCH.RCH_ROTEIR = '" + cRotFol + "' AND"
		cWhere += " RCH.RCH_PER = '" + cPerFol + "' AND"
		cWhere += " RCH.RCH_NUMPAG = '" + cSemFol + "'"

		If lGPEM040
			cWhere += " AND SRA.RA_FILIAL = '" + SRA->RA_FILIAL + "' AND SRA.RA_MAT = '" + SRA->RA_MAT + "' "
		EndIf

		cWhere += "%"

		cJoin := "%"
		cJoin += FWJoinFilial( "RCH", "SRA" )
		cJoin += "%"

		//Obtem quantidade de registro para a regua de processamento
		If !(aRotMark[nPos,5] $ "3*4")
			BeginSql alias cAliasSRA
				SELECT Count(*) AS NUMREG
				FROM %table:SRA% SRA
				INNER JOIN  %table:RCH% RCH
				ON 			%exp:cJoin%
				WHERE %exp:cWhere% AND
				SRA.%notDel% AND
				RCH.%notDel%
			EndSql

			nNumReg := (cAliasSRA)->NUMREG

			( cAliasSRA )->( dbCloseArea() )

			BeginSql alias cAliasSRA
				SELECT %exp:cCposQuery%
				FROM %table:SRA% SRA
				INNER JOIN  %table:RCH% RCH
				ON 			%exp:cJoin%
				WHERE %exp:cWhere% AND
				SRA.%notDel% AND
				RCH.%notDel%
				ORDER BY RA_FILIAL, RA_MAT
			EndSql
		ElseIF aRotMark[nPos,5] == "3"
			BeginSql alias cAliasSRA
				SELECT Count(*) AS NUMREG
				FROM %table:SRA% SRA
				INNER JOIN  %table:RCH% RCH ON %exp:cJoin%
				WHERE %exp:cWhere% AND
				EXISTS(SELECT DISTINCT SRH.RH_FILIAL, SRH.RH_MAT FROM %table:SRH% SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_PROCES = SRA.RA_PROCES AND SRH.RH_PERIODO = %exp:cPerFol% AND SRH.RH_ROTEIR = %exp:aRotMark[nPos,2]% AND SRH.RH_NPAGTO = %exp:cSemFol% AND SRH.D_E_L_E_T_= ' ') AND
				SRA.%notDel% AND
				RCH.%notDel%
			EndSql

			nNumReg := (cAliasSRA)->NUMREG

			( cAliasSRA )->( dbCloseArea() )

			BeginSql alias cAliasSRA
				SELECT DISTINCT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, SRA.RA_ITEM, SRA.RA_CLVL, SRA.RA_CATFUNC, SRA.RA_PROCES
				FROM %table:SRA% SRA
				INNER JOIN  %table:RCH% RCH ON %exp:cJoin%
				WHERE %exp:cWhere% AND
				EXISTS(SELECT DISTINCT SRH.RH_FILIAL, SRH.RH_MAT FROM %table:SRH% SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_PROCES = SRA.RA_PROCES AND SRH.RH_PERIODO = %exp:cPerFol% AND SRH.RH_ROTEIR = %exp:aRotMark[nPos,2]% AND SRH.RH_NPAGTO = %exp:cSemFol% AND SRH.D_E_L_E_T_= ' ') AND
				SRA.%notDel% AND
				RCH.%notDel%
				ORDER BY RA_FILIAL, RA_MAT
			EndSql
		Else
			BeginSql alias cAliasSRA
				SELECT Count(*) AS NUMREG
				FROM %table:SRA% SRA
				INNER JOIN  %table:RCH% RCH ON %exp:cJoin%
				WHERE %exp:cWhere% AND
				EXISTS(SELECT DISTINCT SRG.RG_FILIAL, SRG.RG_MAT FROM %table:SRG% SRG WHERE SRG.RG_FILIAL = SRA.RA_FILIAL AND SRG.RG_MAT = SRA.RA_MAT AND SRG.RG_PROCES = SRA.RA_PROCES AND SRG.RG_PERIODO = %exp:cPerFol% AND SRG.RG_ROTEIR = %exp:aRotMark[nPos,2]% AND SRG.RG_SEMANA = %exp:cSemFol% AND SRG.D_E_L_E_T_= ' ') AND
				SRA.%notDel% AND
				RCH.%notDel%
			EndSql

			nNumReg := (cAliasSRA)->NUMREG

			( cAliasSRA )->( dbCloseArea() )

			BeginSql alias cAliasSRA
				SELECT DISTINCT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, SRA.RA_ITEM, SRA.RA_CLVL, SRA.RA_CATFUNC, SRA.RA_PROCES
				FROM %table:SRA% SRA
				INNER JOIN  %table:RCH% RCH ON %exp:cJoin%
				WHERE %exp:cWhere% AND
				EXISTS(SELECT DISTINCT SRG.RG_FILIAL, SRG.RG_MAT FROM %table:SRG% SRG WHERE SRG.RG_FILIAL = SRA.RA_FILIAL AND SRG.RG_MAT = SRA.RA_MAT AND SRG.RG_PROCES = SRA.RA_PROCES AND SRG.RG_PERIODO = %exp:cPerFol% AND SRG.RG_ROTEIR = %exp:aRotMark[nPos,2]% AND SRG.RG_SEMANA = %exp:cSemFol% AND SRG.D_E_L_E_T_= ' ') AND
				SRA.%notDel% AND
				RCH.%notDel%
				ORDER BY RA_FILIAL, RA_MAT
			EndSql
		EndIf
	Else
		(cAliasSRA)->(DbGoTop())
	EndIf

	If aRotMark[nPos,5] $ "3*4"
		DbSelectArea("RCH")
		DbSetOrder(RetOrder("RCH","RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR"))

		DbSeek(aRotMark[nPos,7]+aRotMark[nPos,1]+aRotMark[nPos,3]+aRotMark[nPos,4]+aRotMark[nPos,2])

		fRetPerComp(RCH->RCH_MES, RCH->RCH_ANO,aRotMark[nPos,7], aRotMark[nPos,1],fGetRotOrdinar(),@aPerAberto )

		If Empty(aPerAberto)
			fRetPerComp(RCH->RCH_MES, RCH->RCH_ANO,aRotMark[nPos,7], aRotMark[nPos,1],fGetCalcRot("9"),@aPerAberto )
		EndIf

		If Empty(aPerAberto)
			If aRotMark[nPos,5] == "3"
				aAdd(aTitle, OemToAnsi(STR0022))  //"Nao foi encontrado período da folha com a mesma competência do período de férias para integração."
			Else
				aAdd(aTitle, OemToAnsi(STR0027))  //"Nao foi encontrado período da folha com a mesma competência do período de rescisão para integração."
			EndIf
			aAdd(aLog,{})
			aAdd(aLog[Len(aLog)] , STR0023 + aRotMark[nPos,1] + " " + STR0024 + aRotMark[nPos,3] + " " + STR0025 + aRotMark[nPos,4]) //"Processo: ### Período: ### Núm. Pagto: ### "
			Loop
		Else
			If aRotMark[nPos,5] == "3"
				aAdd(aTitle, OemToAnsi(STR0026))  //"Funcionários já possuem dados de Férias integrados"
			Else
				aAdd(aTitle, OemToAnsi(STR0028))  //"Funcionários já possuem dados de Rescisão integrados"
			EndIf
			aAdd(aLog,{})
			cProcFol 	:= aRotMark[nPos,1]
			cRotFol		:= aPerAberto[1,8]
			cPerFol		:= aPerAberto[1,1]
			cSemFol		:= aPerAberto[1,2]
		EndIf
		DbSelectArea("RGB")
		DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEQ+DTOS(RGB_DTREF)"))
		If aRotMark[nPos,5] == "4"
			DbSelectArea("SRH")
			DbSetOrder(RetOrder("SRH","RH_FILIAL+RH_MAT+RH_ROTEIR+DTOS(RH_DTRECIB)"))
		EndIf
	ElseIf aRotMark[nPos,5] == "8" //Vale Transporte
		aAdd(aTitle, OemToAnsi(STR0014))  //"Funcionários já possuem dados de Vale Transporte integrados"
		aAdd(aLog,{})
		cRotBen := fGetCalcRot("8")
	ElseIf aRotMark[nPos,5] == "C"		//Plano de Saude
		cAnoMes	:=	aRotMark[nPos,3]
		nOrdSRA	:= RetOrder( "SRA", "RA_FILIAL+RA_MAT" )
		aAdd(aTitle, OemToAnsi(STR0021))  //"Funcionários já possuem dados de Plano de Saude integrados"
		aAdd(aLog,{})
	ElseIf aRotMark[nPos,5] == "D"		//Vale Refeicao
		aAdd(aTitle, OemToAnsi(STR0015))  //"Funcionários já possuem dados de Vale Transporte integrados"
		aAdd(aLog,{})
		cRotBen := fGetCalcRot("D")
	ElseIf aRotMark[nPos,5] == "E"		//Vale Alimentacao
		aAdd(aTitle, OemToAnsi(STR0016))  //"Funcionários já possuem dados de Vale Transporte integrados"
		aAdd(aLog,{})
		cRotBen := fGetCalcRot("E")
	ElseIf aRotMark[nPos,5] == "H"		//Ponto Eletronico
		aAdd(aTitle, OemToAnsi(STR0031))  //"Funcionário já possui dados do Ponto Eletronico integrados"
		aAdd(aLog,{})
		cRotBen := fGetCalcRot("H")
	ElseIf aRotMark[nPos,5] == "I"
		aAdd(aTitle, OemToAnsi(STR0032))  //"Funcionário já possui dados de Outros Beneficios integrados"
		aAdd(aLog,{})
		cRotBen := fGetCalcRot("H")
	ElseIf aRotMark[nPos,5] == "K"
		aAdd(aTitle, OemToAnsi(STR0043))  //"Funcionário já possui dados de Valores Extras integrados"
		aAdd(aLog,{})
	EndIf

	dDataRef := aRotMark[nPos,6]

	If !lIsBlind
		oSelf:SetRegua2(nNumReg)
	EndIf

	cFilAux := ""

	While (cAliasSRA)->( !Eof() )

		If !lIsBlind
			oSelf:IncRegua2('')
		EndIf

		cFilAnt := (cAliasSRA)->RA_FILIAL

		If !lIsBlind .And. oSelf:lEnd
			Exit
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consiste Filiais e Acessos                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( (cAliasSRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
			dbSelectArea(cAliasSRA)
			dbSkip()
			Loop
		EndIf
		If lVerFil .And. aScan( aFilOk, { |x| xFilial("SRY", (cAliasSRA)->RA_FILIAL) == x[1] } ) == 0
			dbSelectArea(cAliasSRA)
			dbSkip()
			Loop
		EndIf

		Begin Transaction	

			If cFilAux <> (cAliasSRA)->RA_FILIAL
				If !Fp_CodFol(@aCodFol , (cAliasSRA)->RA_FILIAL, .T.) //Carrega verbas
					lFechOk := .F.
					DisarmTransaction()
					lIntOk := .F.
					Break
				EndIf
				If aRotMark[nPos,5] $ "8/D/E" 
					aLogAux 	:= aLog //SetMnemonicos zera variavel aLog, pois aLog eh um mnemonico	
					SetMnemonicos((cAliasSRA)->RA_FILIAL,NIL,.T.)
					aLog 		:= aLogAux //Retorna conteudo de aLog
				EndIf
				If aRotMark[nPos,5] == "E" //Vale Alimentacao			
					cPdEmp		:= cValToChar(P_PDVAEMP)//-- Base parte Empresa - Vale Alimentação
					cPdFun		:= cValToChar(P_PDVADES)//-- Vale Alimentação
					If Type("P_PDVAVAL") <> "U"
						cPDTot	:= P_PDVAVAL
					EndIf
					If Empty(cPdEmp) .or. Empty(cPdFun)
						aAdd(aTitle, OemToAnsi(STR0017))
						aAdd(aLog,{})
						aAdd(aLog[Len(aLog)] , STR0018 ) //"Nao foram informdas as verbas de vale alimentação nos mnemonicos P_PDVAEMP e/ou P_PDVADES. Vale alimentação não foi integrado."
						lIntOk := .F.
						DisarmTransaction()
						Break
					EndIf
				EndIf
				cFilAux := (cAliasSRA)->RA_FILIAL
			EndIf

			If aRotMark[nPos,5] $ "D*E*I" //Vale refeição/alimentação/outros beneficios
				If lGPEM040
					fLimpaRGB((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcFol,cPerFol,cSemFol,aRotMark[nPos,2],If(aRotMark[nPos,5]$"D*E",dDataRef,CtoD("")))
				EndIf
			Else
				fLimpaRGB((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcFol,cPerFol,If(aRotMark[nPos,5] == "K", aRotMark[nPos,4], cSemFol),aRotMark[nPos,2],If(aRotMark[nPos,5]=="8",dDataRef,CtoD("")),If(aRotMark[nPos,5] == "N","RTF"+aRotMark[nPos,3]+aRotMark[nPos,4],""))
			EndIf

			If aRotMark[nPos,5] == "3"			//Ferias
				lIntOk := fIntegraFer((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcFol,aRotMark[nPos,2],cRotFol,aRotMark[nPos,3],cPerFol,aRotMark[nPos,4],cSemFol,aCodFol)
			ElseIf aRotMark[nPos,5] == "4"   	//Rescisao
				nSobrepor := 1
				lIntOk := fIntegraRes((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, cProcFol, aRotMark[nPos,2], cRotFol, aRotMark[nPos,3], cPerFol, aRotMark[nPos,4], cSemFol, lIntIc)
				nSobrePor := 0
			ElseIf aRotMark[nPos,5] == "8"		//Vale Transporte
				If nSobrePor == 0
					fInfoBen(@nSobrePor,@nAgrupa, .F.)
				EndIf
				cPdEmp	 := aCodFol[210,1]		//-- Base parte Empresa - Vale Transporte
				cPdFun	 := aCodFol[051,1]		//-- Vale Transporte
				lIntOk   := fIntegraVT(cPdEmp, cPdFun, aCodFol, cProcFol, cPerFol, cSemFol, dDataRef )  //GPEM015
			ElseIf aRotMark[nPos,5] == "C"		//Plano de Saude
				If nSobrePor == 0
					fInfoBen(@nSobrePor,@nAgrupa)
				EndIf
				DbSelectArea( "SRA" )
				DbSetOrder( nOrdSRA )
				DbSeek( (cAliasSRA)->(RA_FILIAL+RA_MAT),.F.)
				lIntOk := fIntegraPLS(aCodFol,cAnoMes,cRotFol,cPerFol,cSemFol)
			ElseIf aRotMark[nPos,5] == "D"		//Vale Refeicao
				cPdEmp	:= aCodFol[212,1]		//-- Base parte Empresa - Vale Refeição
				cPdFun	:= aCodFol[050,1]		//-- Vale Refeição
				If Len(aCodFol) >= 1868 .And. !Empty(aCodFol[1868,1])
					cPDTot	:= aCodFol[1868,1]	//-- Valor Vale Refeição
				EndIf
				If Empty(cPdEmp) .or. Empty(cPdFun)
					aAdd(aTitle, OemToAnsi(STR0036)) //"Falha na integracao do Vale Refeicao"
					aAdd(aLog,{})
					aAdd(aLog[Len(aLog)] , STR0037 ) //"Identificadores de Calculo não encontrados. Verificar cadastro das verbas de Vale Refeição."
					lIntOk := .F.
					DisarmTransaction()
					Break
				EndIf
				If nSobrePor == 0
					fInfoBen(@nSobrePor,@nAgrupa)
				EndIf
				lIntOk := fIntegraVRA(cPdEmp, cPdFun, cProcFol, cPerFol, cSemFol, dDataRef, "1", cPDTot, nSobrePor, nAgrupa) //GPEM015
			ElseIf aRotMark[nPos,5] == "E"		//Vale Alimentacao
				If nSobrePor == 0
					fInfoBen(@nSobrePor,@nAgrupa)
				EndIf
				lIntOk := fIntegraVRA(cPdEmp, cPdFun, cProcFol, cPerFol, cSemFol, dDataRef, "2", cPDTot, nSobrePor, nAgrupa) //GPEM015
			ElseIf aRotMark[nPos,5] == "H"
				lIntOk := fImpPonto(,,,,@aLog)
			ElseIf aRotMark[nPos,5] == "I"		//Outros Beneficios
				If nSobrePor == 0
					fInfoBen(@nSobrePor,@nAgrupa,.F.)
				EndIf
				lIntOk := fIntegraOUT((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,(cAliasSRA)->RA_PROCES,cProcFol,cRotFol,cPerFol,cSemFol,aRotMark[nPos,2],aRotMark[nPos,3],aRotMark[nPos,4], nSobrePor)
			ElseIf aRotMark[nPos,5] == "K"		//VALORES EXTRAS
				lIntOk := fIntegraVEX((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,(cAliasSRA)->RA_PROCES,cProcFol,cRotFol,cPerFol,cSemFol,aRotMark[nPos,2],aRotMark[nPos,3],aRotMark[nPos,4])
			ElseIf aRotMark[nPos,5] == "N"		//Retificadora
				lIntOk := fIntegraRTF((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,(cAliasSRA)->RA_PROCES,cProcFol,cRotFol,cPerFol,cSemFol,aRotMark[nPos,2],aRotMark[nPos,3],aRotMark[nPos,4], aCodFol)
			Else
				//Para outros tipos de roteiro, que devam ser integrados, verifica se o ponto de entrada existe, caso nao exista, e exibida mensagem informativa.
				If lGPM19INTEG
					lIntOk := ExecBlock("GPM19INTEG",.F.,.F.)
				Else
					aAdd(aTitle, OemToAnsi(STR0033)) //Falha na integracao de roteiro do usuario
					aAdd(aLog,{})
					aAdd(aLog[Len(aLog)] , STR0034 + aRotMark[nPos,2] +  STR0035) //"O roteiro " ### " foi definido para ser integrado com a folha porém não foi criado rotina para integração. (Ponto de Entrada 'GPM19INTEG')"
				EndIf
			EndIf

		End Transaction

		If !lIntOk
			Exit
		EndIf

		(cAliasSRA)->( DbSkip() )

	EndDo

	If lIntOk .and. !lGPEM040
		nRecRCH := RCH->(Recno())
		DbSelectArea("RCH")
		DbSetOrder(1) //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
		If DbSeek(aRotMark[nPos,7]+aRotMark[nPos,1]+aRotMark[nPos,3]+aRotMark[nPos,4]+aRotMark[nPos,2])
			RecLock("RCH",.F.)
			RCH->RCH_DTINTE  := dDataBase
			RCH->( MsUnlock() )
		EndIf
		UpdTabMark(aRotMark[nPos,1],aRotMark[nPos,2],aRotMark[nPos,3],aRotMark[nPos,4],aRotMark[nPos,7])
		RCH->(DbGoTo(nRecRCH))
	EndIf

	If Len(aLog) > 0 .and. Empty(aLog[Len(aLog)]) .and. lIntOk
		aDel(aLog,Len(aLog))
		aDel(aTitle,Len(aTitle))
		aSize(aLog,Len(aLog)-1)
		aSize(aTitle,Len(aTitle)-1)
	EndIf

Next nPos

cFilAnt := cFilBkp

If ( Select( cAliasSRA ) > 0 )
	DbSelectArea(cAliasSRA)
	DbCloseArea()
EndIf

If !lIsBlind
	oSelf:SaveLog( STR0008+" - "+STR0019) //"Integração com a Folha de Pagamento"##"Fim do processamento"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresenta com Log de erros                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fMakeLog(aLog,aTitle,,,STR0020,STR0008,"M","P",,.F.)  //"LOG de Ocorrencias"## - Integração com a Folha de Pagamento"

//	SetMarkAll(oMark:Mark(),.F. )
	aRotMark := {}

	oMark:Refresh() //Atualiza markbrowse

	Gp19VldMark()
EndIf

aTitle := {}	//Zera os logs
aLog   := {}	//Zera os logs

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GPM019Cancela³ Autor ³ Leandro Drumond     ³ Data ³01/07/16³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa as integracoes.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		                                   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM019           			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function GPM019Cancela(oSelf)

Local cAcessaSRA	:= &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM019" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
Local aFilOk		:= {}
Local aPerAtual		:= {}
Local cCposQuery	:= ""
Local cWhere		:= ""
Local cJoin			:= ""
Local cPerBen		:= ""
Local cSemBen		:= ""
Local cKeyRCH		:= ""
Local nPos			:= 0
Local nNumReg		:= 0
Local cAliasSRA		:= GetNextAlias()
Local cRotFol		:= fGetCalcRot("1")
Local cSemFol		:= "01"
Local dDataRef		:= CtoD("")
Local lVerFil		:= FWModeAccess("RCH", 1)+FWModeAccess("RCH", 2)+FWModeAccess("RCH", 3) != FWModeAccess("SRY", 1)+FWModeAccess("SRY", 2)+FWModeAccess("SRY", 3) .And. Len(AllTrim(xFilial("RCH"))) < Len(AllTrim(xFilial("SRY")))

DEFAULT lIsBlind 	:= IsBlind()
DEFAULT lConsig		:= GetMvRH("MV_CONSIG",, .F.)
DEFAULT lCpoFlagIC	:= ChkFile("SRG") .And. SRG->(ColumnPos( "RG_CONFIC")) > 0 

If ( Select( cAliasSRA ) > 0 )
	( cAliasSRA )->( dbCloseArea() )
EndIf

If !lIsBlind
	oSelf:SetRegua1(Len(aRotMark))
	oSelf:SaveLog( STR0041 + " - " + STR0009) //"Cancelamento da Integração"##"Inicio do processamento"
EndIf

DbSelectArea("RCH")
DbSetOrder(1)

For nPos := 1 to Len(aRotMark)
	//aAdd(aRotMark,{TAB_PROC, TAB_ROT, TAB_PER, TAB_NPAG, TAB_TPROT, TAB_DTREF, TAB_FIL})
	If lVerFil
		aFilOk := fBuscFil( aRotMark[nPos, 2] )
	EndIf
	cProcesso	:= aRotMark[nPos,1]
	cRoteiro	:= aRotMark[nPos,2]
	cPerBen		:= cPeriodo	:= aRotMark[nPos,3]
	cSemBen		:= cNumPag	:= aRotMark[nPos,4]
	dDataRef	:= CtoD("")

	If cPaisLoc == "BRA"
		cKeyRCH := aRotMark[nPos,7] + aRotMark[nPos,1] + aRotMark[nPos,3] + aRotMark[nPos,4]
		If Dbseek(cKeyRCH + fGetRotOrdinar()) .And. RCH->RCH_STATUS == "2"
			aAdd(aTitle, OemToAnsi(STR0051)) //"Falha no cancelamento da integração"
			aAdd(aLog,{})
			aAdd(aLog[Len(aLog)], OemToAnsi(STR0049)) //'Roteiro da folha está sendo calculado (RCH_STATUS com "2"), portanto o cancelamento não será realizado.'
			Loop
		ElseIf Dbseek(cKeyRCH + fGetCalcRot("9")) .And. RCH->RCH_STATUS == "2"
			aAdd(aTitle, OemToAnsi(STR0051)) //"Falha no cancelamento da integração"
			aAdd(aLog,{})
			aAdd(aLog[Len(aLog)], OemToAnsi(STR0049)) //'Roteiro da folha está sendo calculado (RCH_STATUS com "2"), portanto o cancelamento não será realizado.'
			Loop
		EndIf
	EndIf

	If aRotMark[nPos,5] == "N" //RTF
		fGetPerAtual( @aPerAtual, xFilial("RCH"), cProcesso, fGetRotOrdinar() ) // Busca o periodo aberto da folha

		If !Empty(aPerAtual)
			cPeriodo	:=	aPerAtual[1,1]
			cNumPag 	:= 	aPerAtual[1,2]
		EndIf
	EndIf

	If cNumPag > "01" //Verifica se o roteiro da folha possui semana superior a "01", do contrário, busca integrações apenas na semana "01"
		If aRotMark[nPos,5] $ "8*D*E" //VR-VT-VA
			dDataRef := aRotMark[nPos,6]
		EndIf
		DbSelectArea("RCH")
		DbSetOrder(1) //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
		If DbSeek(aRotMark[nPos,7]+cProcesso+cPeriodo+cNumPag+cRotFol)
			cSemFol := cNumPag
		ElseIf aRotMark[nPos,5] == "K" //VEX
			dDataRef := aRotMark[nPos,6] //Se semana do VEX for superior a "01" e existir apenas a semana "01" na folha, efetua a exclusão de acordo com a data de referência
		EndIf
	EndIf

	cCposQuery 	:= "%SRA.RA_FILIAL, SRA.RA_MAT%"

	cWhere := "%"
	cWhere += " RCH.RCH_PROCES = '" + cProcesso + "' AND"
	cWhere += " RCH.RCH_FILIAL = '" + aRotMark[nPos,7] + "' AND"
	cWhere += " RCH.RCH_ROTEIR = '" + cRoteiro + "' AND"
	cWhere += " RCH.RCH_PER = '" + cPerBen + "' AND"
	cWhere += " RCH.RCH_NUMPAG = '" + cSemBen + "'"
	cWhere += "%"

	cJoin := "%"
	cJoin += FWJoinFilial( "RCH", "SRA" )
	cJoin += "%"

	//Obtem quantidade de registro para a regua de processamento
	BeginSql alias cAliasSRA
		SELECT Count(*) AS NUMREG
		FROM %table:SRA% SRA
		INNER JOIN  %table:RCH% RCH
		ON 			%exp:cJoin%
		WHERE %exp:cWhere% AND
		EXISTS(SELECT * FROM %table:RGB% RGB WHERE RGB_FILIAL = RA_FILIAL AND RGB_MAT = RA_MAT AND RGB.RGB_PROCES = %exp:cProcesso% AND RGB.RGB_PERIOD = %exp:cPeriodo% AND RGB.RGB_ROTORI = %exp:aRotMark[nPos,2]% AND RGB.RGB_SEMANA = %exp:cSemFol% AND RGB.%notDel%) AND
		SRA.%notDel% AND
		RCH.%notDel%
	EndSql

	nNumReg := (cAliasSRA)->NUMREG

	( cAliasSRA )->( dbCloseArea() )

	BeginSql alias cAliasSRA
		SELECT %exp:cCposQuery%
		FROM %table:SRA% SRA
		INNER JOIN  %table:RCH% RCH
		ON 			%exp:cJoin%
		WHERE %exp:cWhere% AND
		EXISTS(SELECT * FROM %table:RGB% RGB WHERE RGB_FILIAL = RA_FILIAL AND RGB_MAT = RA_MAT AND RGB.RGB_PROCES = %exp:cProcesso% AND RGB.RGB_PERIOD = %exp:cPeriodo% AND RGB.RGB_ROTORI = %exp:aRotMark[nPos,2]% AND RGB.RGB_SEMANA = %exp:cSemFol% AND RGB.%notDel%) AND
		SRA.%notDel% AND
		RCH.%notDel%
		ORDER BY RA_FILIAL, RA_MAT
	EndSql

	If !lIsBlind
		oSelf:SetRegua2(nNumReg)
	EndIf

	Begin Transaction

		While (cAliasSRA)->( !Eof() )
			If !lIsBlind
				oSelf:IncRegua2('')
			EndIf

			cFilAnt := (cAliasSRA)->RA_FILIAL

			If !lIsBlind .And. oSelf:lEnd
				lFechOk := .F.
				DisarmTransaction()
				Break
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Consiste Filiais e Acessos                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !( (cAliasSRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
				dbSelectArea(cAliasSRA)
				dbSkip()
				Loop
			EndIf
			If lVerFil .And. aScan( aFilOk, { |x| xFilial("SRY", (cAliasSRA)->RA_FILIAL) == x[1] } ) == 0
				dbSelectArea(cAliasSRA)
				dbSkip()
				Loop
			EndIf

			//Apaga dados da RGB
			fLimpaRGB((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcesso,cPeriodo,cSemFol,cRoteiro,dDataRef,If(aRotMark[nPos,5] == "N","RTF" + aRotMark[nPos,3] + aRotMark[nPos,4],""))
			If aRotMark[nPos,5] <> "N"
				fVoltaRGB((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcesso,cPeriodo,cNumPag,cRoteiro, aRotMark[nPos,5])
			EndIf

			If cPaisLoc == "BRA" .And. aRotMark[nPos, 5] == "4" .And. lConsig .And. lCpoFlagIC
				fVoltaIC((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, cProcesso, cPeriodo, cNumPag)
			EndIf

			(cAliasSRA)->( DbSkip() )

		EndDo

		DbSelectArea("RCH")
		DbSetOrder(1) //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
		If DbSeek(aRotMark[nPos,7]+aRotMark[nPos,1]+aRotMark[nPos,3]+aRotMark[nPos,4]+aRotMark[nPos,2])
			RecLock("RCH",.F.)
			RCH->RCH_DTINTE  := CtoD("")
			RCH->( MsUnlock() )
		EndIf
		UpdTabMark(aRotMark[nPos,1],aRotMark[nPos,2],aRotMark[nPos,3],aRotMark[nPos,4],aRotMark[nPos,7],.T.)

	End Transaction

	( cAliasSRA )->( dbCloseArea() )

	If !lIsBlind
		oSelf:IncRegua1(STR0008)
	EndIf
Next nPos

If !lIsBlind
	oSelf:SaveLog( STR0041+" - "+STR0019) //"Cancelamento da Integração"##"Fim do processamento"

	fMakeLog(aLog,aTitle,,,STR0020,STR0008,"M","P",,.F.)  //"LOG de Ocorrencias"## - Integração com a Folha de Pagamento"

//	SetMarkAll(oMark:Mark(),.F. )
	aRotMark := {}

	oMark:Refresh() //Atualiza markbrowse

	Gp19VldMark()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCriaTmp       ³ Autor ³ Leandro Drumond    ³ Data ³ 09/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria tabela temporaria para uso no FWMarkBrowse      			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCriaTmp()				                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GPEM019					                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCriaTmp(nOpcM040)
Local aColumns	 := {}
Local cQuery	 := ''
Local cKeyAux	 := ''
Local cAliasRCH	 := 'QRCH'
Local cAcessaSRA := &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM019" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
Local lRet		 := .F.

DEFAULT	nOpcM040 := 0

If Select(cAliasMark) > 0
	DbSelectArea(cAliasMark)
	DbCloseArea()
EndIf

aAdd( aColumns, { "TAB_OK"		,"C",02,00 })
aAdd( aColumns, { "TAB_ROT"		,"C",TAMSX3("RY_CALCULO")[1],TAMSX3("RY_CALCULO")[2]})
aAdd( aColumns, { "TAB_DESC"	,"C",TAMSX3("RY_DESC")[1],TAMSX3("RY_DESC")[2]})
aAdd( aColumns, { "TAB_PROC"	,"C",TAMSX3("RCH_PROCES")[1],TAMSX3("RCH_PROCES")[2]})
aAdd( aColumns, { "TAB_PER"		,"C",TAMSX3("RCH_PER")[1],TAMSX3("RCH_PER")[2]})
aAdd( aColumns, { "TAB_NPAG"	,"C",TAMSX3("RCH_NUMPAG")[1],TAMSX3("RCH_NUMPAG")[2]})
aAdd( aColumns, { "TAB_TPROT"	,"C",TAMSX3("RY_TIPO")[1],TAMSX3("RY_TIPO")[2]})
aAdd( aColumns, { "TAB_INTEG"	,"D",8,0})
aAdd( aColumns, { "TAB_DTREF"	,"D",8,0})
aAdd( aColumns, { "TAB_FIL"		,"C",TAMSX3("RCH_FILIAL")[1],TAMSX3("RCH_FILIAL")[2]})

oTmpTable := FWTemporaryTable():New(cAliasMark)
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "IND", { "TAB_FIL", "TAB_PROC", "TAB_ROT", "TAB_PER", "TAB_NPAG" } )
oTmpTable:Create()

dbSelectArea( "RCH" )
DbSetOrder(RetOrdem("RCH","RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG"))

cQuery := "SELECT RY_DESC, RY_TIPO, RCH_FILIAL, RCH_PROCES, RCH_ROTEIR, RCH_PER, RCH_NUMPAG, RCH_DTINTE, RCH_DTINI, RCH_DTPAGO"
cQuery += 		" FROM " + RetSqlName("RCH") + " RCH"
cQuery +=			" INNER JOIN " + RetSqlName("SRY") + " SRY"
cQuery +=			" ON RCH_ROTEIR = RY_CALCULO AND "
cQuery +=			FWJoinFilial( "RCH", "SRY" )
cQuery +=		" WHERE"

If FunName() == "GPEM009"
	cQuery +=			" RY_TIPO = 'C' AND RY_INTEGRA = '1' AND" //PLA
ElseIf FunName() == "GPEM015"
	cQuery +=			" RY_TIPO IN ('8','D','E') AND RY_INTEGRA = '1' AND" //VT/VR/VA
ElseIf FunName() == "GPEM015A"
	cQuery +=			" RY_TIPO = 'I' AND RY_INTEGRA = '1' AND" //BEN
ElseIf FunName() == "GPEM030"
	cQuery +=			" RY_TIPO = '3' AND RY_INTEGRA = '1' AND" //Ferias
ElseIf FunName() == "GPEM040"
	If nOpcM040 == 0
		cQuery +=			" RY_TIPO NOT IN  ('4','N') AND RY_INTEGRA = '1' AND" //Ferias/Vale Transporte/Plano de Saude/Vale Refeicao/Vale Alimentacao/Ponto Eletronico/Outros Beneficios
		cQuery += 			" RCH_FILIAL = '"+cFilRCH+"' AND RCH_PROCES = '"+cProcFil+"' AND RCH_PER = '"+cPerFil+"' AND RCH_NUMPAG = '"+cSemFil+"' AND "
	Else
		cQuery +=		" RY_TIPO = '4' AND RY_INTEGRA = '1' AND" //Rescisao
	EndIf
Else
	cQuery +=			" RY_INTEGRA ='1' AND" //Ferias/Rescisao/Vale Transporte/Plano de Saude/Vale Refeicao/Vale Alimentacao
EndIf

cQuery +=			" RCH_PERSEL = '1' AND"
cQuery +=			" SRY.D_E_L_E_T_ = ' ' AND RCH.D_E_L_E_T_ = ' '"
cQuery += 		" ORDER BY " + SqlOrder(RCH->(IndexKey()))

cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCH)

TcSetField(cAliasRCH,"RCH_DTINTE","D",8,0)

DbSelectArea(cAliasRCH)

DbSelectArea(cAliasMark)

While (cAliasRCH)->(!Eof())
	If cKeyAux <> (cAliasRCH)->(RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG)

		cKeyAux := (cAliasRCH)->(RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG)

		If ( !(Empty((cAliasRCH)->RCH_FILIAL)) .And. !(AllTrim((cAliasRCH)->RCH_FILIAL) $ fValidFil()) ) .Or. !Eval( cAcessaSRA )
			(cAliasRCH)->(DbSkip())
			Loop
		EndIf
		lRet := .T.

		RecLock(cAliasMark,.T.)
		(cAliasMark)->TAB_FIL 	:= (cAliasRCH)->RCH_FILIAL
		(cAliasMark)->TAB_ROT 	:= (cAliasRCH)->RCH_ROTEIR
		(cAliasMark)->TAB_DESC 	:= (cAliasRCH)->RY_DESC
		(cAliasMark)->TAB_PROC	:= (cAliasRCH)->RCH_PROCES
		(cAliasMark)->TAB_PER	:= (cAliasRCH)->RCH_PER
		(cAliasMark)->TAB_NPAG	:= (cAliasRCH)->RCH_NUMPAG
		(cAliasMark)->TAB_INTEG	:= (cAliasRCH)->RCH_DTINTE
		(cAliasMark)->TAB_TPROT	:= (cAliasRCH)->RY_TIPO
		(cAliasMark)->TAB_DTREF	:= If((cAliasRCH)->RY_TIPO == "K", StoD((cAliasRCH)->RCH_DTPAGO), StoD((cAliasRCH)->RCH_DTINI) )

		MsUnLock()
	EndIf

	(cAliasRCH)->(DbSkip())

EndDo

( cAliasRCH )->( dbCloseArea() )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMntColsMark³ Autor ³ Leandro Drumond       ³ Data ³ 10/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta dados dos campos da tabela temporaria                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMntColsMark()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMntColsMark()
Local aArea		:= GetArea()
Local aColsAux 	:=`{}
Local aColsSX3	:= {}
Local aCampos  	:= {"RCH_FILIAL","RCH_PROCES","RCH_PER","RY_CALCULO","RY_DESC","RCH_NUMPAG","RCH_DTINTE"}
Local aDados	:= {{||(cAliasMark)->TAB_FIL},{||(cAliasMark)->TAB_PROC},{||(cAliasMark)->TAB_PER},{||(cAliasMark)->TAB_ROT}, {||(cAliasMark)->TAB_DESC},{||(cAliasMark)->TAB_NPAG},{||(cAliasMark)->TAB_INTEG}}
Local nX		:= 0

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX]) )
	    aColsSX3 := {X3Titulo(),aDados[nX], SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
	    aAdd(aColsAux,aColsSX3)
	    aColsSX3 := {}
	EndIf
Next nX

RestArea(aArea)

Return aColsAux

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SetMarkAll  ³ Autor ³ Leandro Drumond       ³ Data ³ 10/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/desmarca todos os itens 			                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SetMarkAll(cMarca,lMarcar )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SetMarkAll(cMarca,lMarcar )

Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->TAB_OK := IIf( lMarcar .and. Empty((cAliasMark)->TAB_INTEG), cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea( aAreaMark )

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpdTabMark  ³ Autor ³ Leandro Drumond       ³ Data ³ 11/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza dados da tabela temporaria		                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ UpdTabMark()					                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UpdTabMark(cProcAux,cRotAux,cPerAux,cSemAux,cFilAux,lCancela)

Local aArea		 := GetArea()
Local aAreaMark  := (cAliasMark)->( GetArea() )

DEFAULT lCancela := .F.

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	If (cAliasMark)->TAB_FIL == cFilAux .and. (cAliasMark)->TAB_PROC == cProcAux .and. (cAliasMark)->TAB_ROT == cRotAux .and. (cAliasMark)->TAB_PER == cPerAux .and. (cAliasMark)->TAB_NPAG == cSemAux
		RecLock( (cAliasMark), .F. )
		(cAliasMark)->TAB_INTEG := If(lCancela,CtoD(""),dDataBase)
		MsUnLock()
	EndIf
	(cAliasMark)->( dbSkip() )
EndDo

RestArea( aAreaMark )
RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp19VldMark ³ Autor ³ Leandro Drumond       ³ Data ³ 13/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida selecao de periodo do markbrowse		                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RchIntFields()		                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Gp19VldMark(lAtuFil)

	DEFAULT lAtuFil := .F.

	If lAtuFil .and. !Empty(cFilRCH)
		DbSelectArea("SRA")
		DbSeek(AllTrim(cFilRCH))
		cFilRCH := xFilial("RCH",SRA->RA_FILIAL) //Altera o cFilCalc para ficar de acordo com o compartilhamento utilizado.
	EndIf

	DbSelectArea(cAliasMark)
	SET FILTER TO

//	SetMarkAll(oMark:Mark(),.F. )
	oMark:Refresh()

	DbSelectArea(cAliasMark)

	If Empty(cFilRCH)
		If !Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil .And.  TAB_PER ==  cPerFil .And. TAB_NPAG ==cSemFil .And.  TAB_ROT  ==   cRotFil
		ElseIf !Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil .And.  TAB_PER ==  cPerFil .And. TAB_NPAG ==cSemFil
		ElseIf !Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
		 	SET FILTER TO TAB_PROC == cProcFil .And.  TAB_PER ==  cPerFil .And.  TAB_ROT  ==   cRotFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil .And. TAB_NPAG == cSemFil .And. TAB_ROT == cRotFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil .And. TAB_NPAG ==cSemFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil .And. TAB_ROT  == cRotFil
		ElseIf !Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil .And.  TAB_PER == cPerFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_PROC == cProcFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_PER == cPerFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_PER == cPerFil .And. TAB_NPAG == cSemFil .And. TAB_ROT == cRotFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_PER == cPerFil .And. TAB_NPAG == cSemFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO  TAB_PER ==  cPerFil .And.  TAB_ROT  ==   cRotFil
		ElseIf Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO  TAB_NPAG == cSemFil .And.  TAB_ROT == cRotFil
		ElseIf Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_NPAG == cSemFil
		ElseIf Empty(cProcFil) .and. Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_ROT == cRotFil
		EndIf
	Else
		If !Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And.  TAB_PER ==  cPerFil .And. TAB_NPAG ==cSemFil .And.  TAB_ROT  ==   cRotFil
		ElseIf !Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And.  TAB_PER ==  cPerFil .And. TAB_NPAG ==cSemFil
		ElseIf !Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
		 	SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And.  TAB_PER ==  cPerFil .And. TAB_ROT  ==   cRotFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And. TAB_NPAG == cSemFil .And. TAB_ROT == cRotFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And. TAB_NPAG ==cSemFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And. TAB_ROT  == cRotFil
		ElseIf !Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil .And.  TAB_PER == cPerFil
		ElseIf !Empty(cProcFil) .and. Empty(cPerFil) .and. Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PROC == cProcFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PER == cPerFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PER == cPerFil .And. TAB_NPAG == cSemFil .And. TAB_ROT == cRotFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PER == cPerFil .And. TAB_NPAG == cSemFil
		ElseIf Empty(cProcFil) .and. !Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_PER ==  cPerFil .And.  TAB_ROT  ==   cRotFil
		ElseIf Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_NPAG == cSemFil .And.  TAB_ROT == cRotFil
		ElseIf Empty(cProcFil) .and. Empty(cPerFil) .and. !Empty(cSemFil) .and. Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_NPAG == cSemFil
		ElseIf Empty(cProcFil) .and. Empty(cPerFil) .and. Empty(cSemFil) .and. !Empty(cRotFil)
			SET FILTER TO TAB_FIL == cFilRCH .And. TAB_ROT == cRotFil
		Else
			SET FILTER TO TAB_FIL == cFilRCH
		EndIf
	EndIf
	oMark:GoTop(.T.)
	oMark:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RchIntFields³ Autor ³ Leandro Drumond       ³ Data ³ 10/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta especifica do cadastro de periodos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RchIntFields()		                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RchIntFields()
Local aArea		:= GetArea()
Local cAliasQry	:= "QRCH"
Local cJoin		:= ""
Local cWhere	:= ""
Local cKeyAux	:= ""
Local lOK     	:= .F.
Local nPosLbxA	:= 0.00
Local oDlg		:= NIL
Local oLbxA		:= NIL
Local nOpca		:= 0
Local aAdvSize	:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize 	:= {}

Local bSet15 := {|| NIL}
Local bSet24 := {|| NIL}

aLbxA := {}

VAR_IXB := {"","","","",""}

cJoin := "% "
cJoin += FWJoinFilial( "RCH", "SRY" ) + " AND "
cJoin += " RCH.RCH_ROTEIR 	  = SRY.RY_CALCULO "
cJoin += "%"

cWhere := "%"
cWhere += " (SRY.RY_TIPO 	= '1' OR SRY.RY_TIPO 	= '9') AND "
cWhere += " RCH.RCH_DTFECH 		= '' "

if(VerSenha(114)) /*Se pode visualizar registros de outras filiais...*/
	if(Type("cFilRCH") == "C") /*Caso essa função seja chamada em outro fonte...*/
		if(!(Empty(AllTrim(cFilRCH))))
			cWhere += " AND RCH_FILIAL LIKE '%"+ AllTrim(cFilRCH) +"%' "
		endIf
	endIf

	aFilVld := Separa(fValidFil(),"/")
	cIn := ""
	aEval(aFilVld,{|x|IIF(Empty(x),,cIn+= "'" + xFilial("RCH",x) + "',")})
	cIn := SubStr(cIn,1,Len(cIn)- 1)
	cWhere += " AND RCH_FILIAL IN ("+ cIn + ")"
Else /*Caso contrário apenas da Filial corrente.*/
	cWhere += " AND RCH_FILIAL = '" + xFilial("RCH") + "'"
endIf

cWhere += "%"

BeginSql alias cAliasQry
	SELECT 		RCH_FILIAL, RCH_PROCES, RCH_ROTEIR, RCH_PER, RCH_NUMPAG
	FROM 		%table:RCH% RCH
	INNER JOIN  %table:SRY% SRY
	ON 			%exp:cJoin%
	WHERE 		%exp:cWhere% AND
				RCH.%NotDel% AND
				SRY.%NotDel%
	ORDER BY RCH_FILIAL, RCH_PROCES, RCH_PER
EndSql

While (cAliasQry)->( !Eof() )
	If cKeyAux <> (cAliasQry)->( RCH_FILIAL + RCH_PROCES + RCH_ROTEIR + RCH_PER + RCH_NUMPAG )
		(cAliasQry)->( aAdd( aLbxA, { RCH_FILIAL, RCH_PROCES, RCH_ROTEIR, RCH_PER, RCH_NUMPAG } ) )
		cKeyAux := (cAliasQry)->( RCH_FILIAL + RCH_PROCES + RCH_ROTEIR + RCH_PER + RCH_NUMPAG )
	EndIf
	(cAliasQry)->( dbSkip() )
EndDo

If Empty(aLbxA)
	aAdd( aLbxA , {'','','','','' } )
EndIf

( cAliasQry )->( dbCloseArea() )

aAdvSize		:= MsAdvSize( , .T., 390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 15 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

//Abaixo utilizamos o tamanho da janela como na versão 10, pois cada objeto tem seu posicionamento específico,
//o cada qual eh realocado conforme a resolução da tela do usuário
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0029) PIXEL		// "Selecione o periodo de destino"

	@  aObjSize[1,1], aObjSize[1,2] LISTBOX oLbxA FIELDS HEADER GetSx3Cache("RCH_FILIAL", "X3_TITULO") , GetSx3Cache("RCH_PROCES", "X3_TITULO"),;
	 GetSx3Cache("RCH_ROTEIR", "X3_TITULO"), GetSx3Cache("RCH_PER", "X3_TITULO"), GetSx3Cache("RCH_NUMPAG", "X3_TITULO") SIZE 290,130;
	OF oDlg PIXEL ON DBLCLICK ( lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End() )

	oLbxA:SetArray(aLbxA)
	oLbxA:bLine := { || {aLbxA[oLbxA:nAt,1],aLbxA[oLbxA:nAt,2],aLbxA[oLbxA:nAt,3],aLbxA[oLbxA:nAt,4],aLbxA[oLbxA:nAt,5]}}

	bSet15 := { || nOpca := 1, lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End()}
	bSet24 := { || nOpca := 0, lOk := .F., oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, bSet15, bSet24))

If ( lOk )
	VAR_IXB[1] := aLbxA[nPosLbxA,1]
	VAR_IXB[2] := aLbxA[nPosLbxA,2]
	VAR_IXB[3] := aLbxA[nPosLbxA,3]
	VAR_IXB[4] := aLbxA[nPosLbxA,4]
	VAR_IXB[5] := aLbxA[nPosLbxA,5]
EndIf

RestArea( aArea )

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLimpaRGB  ºAutor  ³Leandro Drumond    º Data ³  17/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa incidencias							      			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLimpaRGB(cFil,cMat,cProcesso,cPeriodo,cNumPag,cRoteiro,dDataRef,cNumID)

Local cQuery := ""

DEFAULT cNumID := ""

cQuery := "DELETE FROM " + RetSqlName("RGB") + " "
cQuery += "WHERE RGB_FILIAL='" + cFil + "' AND "
cQuery += "RGB_PROCES='" + cProcesso + "' AND "
cQuery += "RGB_PERIOD='" + cPeriodo + "' AND "
cQuery += "RGB_SEMANA='" + cNumPag + "' AND "
cQuery += "RGB_ROTORI='" + cRoteiro + "' AND "
cQuery += "RGB_MAT='" + cMat + "' "

If !Empty(dDataRef)
	cQuery += " AND RGB_DTREF = '" + DtoS(dDataRef) + "' "
EndIf

If !Empty(cNumId)
	cQuery += " AND ( RGB_NUMID = '" + cNumId + "' OR RGB_NUMID = '' ) "
EndIf

TcSqlExec( cQuery )

TcRefresh( InitSqlName("RGB") )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fvoltaRGB  ºAutor  ³Renan Borges       º Data ³  29/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Volta incidencias							      			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fVoltaRGB(cFil,cMat,cProcesso,cPeriodo,cNumPag,cRoteiro,cTpRotMrk)

Local cQuery := ""

Default cTpRotMrk := ""

If cTpRotMrk == "4" // Rescisao
	fAtuSeqRGB(cFil,cMat,cProcesso,cPeriodo,cNumPag)
EndIf


	cQuery := "UPDATE " + RetSqlName("RGB") + " "
	If cTpRotMrk == "4" // Rescisao
		cQuery += "SET RGB_ROTEIR= CASE WHEN RGB_ROTORI <> ' ' THEN 'FOL' ELSE RGB_ROTORI END ,"
		cQuery += "RGB_ROTORI= CASE WHEN RGB_ROTORI <> ' ' THEN RGB_ROTORI ELSE ' ' END "
	Else
		cQuery += "SET RGB_ROTEIR=RGB_ROTORI, RGB_ROTORI=' ' "
	EndIf
	cQuery += "WHERE RGB_FILIAL='" + cFil + "' AND "
	cQuery += "RGB_PROCES='" + cProcesso + "' AND "
	cQuery += "RGB_PERIOD='" + cPeriodo + "' AND "
	cQuery += "RGB_SEMANA='" + cNumPag + "' AND "
	cQuery += "RGB_ROTEIR='" + cRoteiro + "' AND "
	cQuery += "RGB_ROTORI <> ' ' AND RGB_ROTORI <> RGB_ROTEIR AND "
	cQuery += "RGB_MAT='" + cMat + "' "


TcSqlExec( cQuery )

TcRefresh( InitSqlName("RGB") )

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef    ³ Autor ³ Leandro Drumond       ³ Data ³ 09/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Menu Funcional                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Return {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction³fIntegraVEX    ºAutor  ³Leandro Drumond  º Data ³ 22/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Integra Valores Extras    com a folha.                        º±±
±±º        ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³Roteiros de Calculo			                                  º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fIntegraVEX(cFil, cMat, cProcBen, cProcFol, cRotFol, cPerFol, cSemFol, cRotBen, cPerBen, cSemBen)
Local aArea			:= GetArea()
Local cKeySRC		:= cFil + cMat + cProcBen  + cRotBen + cPerBen
Local cPdAux		:= ""
Local cSeq			:= ""
Local cCCAux		:= ""
Local cItemAux		:= ""
Local cClvlAux		:= ""
Local lGrava		:= .T.
Local nHrsAux   	:= 0
Local nValAux		:= 0

DEFAULT lGPM19RGB 	:= ExistBlock("GPM19RGB")

DbSelectArea("SRA")
DbSetOrder(1)
DbSeek(cFil + cMat)

DbSelectArea("RGB")
DbSetOrder(RetORder("RGB","RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEQ+DTOS(RGB_DTREF)"))

DbSelectArea("SRC")//RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO, RC_SEMANA, R_E_C_N_O_, D_E_L_E_T_
DbSetOrder(6)

If(DbSeek(cKeySRC))
	While SRC->(!Eof() .and. RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO == cKeySRC )
		If !Empty(cSemBen) .and. SRC->RC_SEMANA <> cSemBen
			SRC->(DbSkip())
			Loop
		EndIf

		cPdAux  := SRC->RC_PD
		cSeq    := SRC->RC_SEQ
		nHrsAux := SRC->RC_HORAS
		nValAux := SRC->RC_VALOR
		cCCAux	:= SRC->RC_CC
		cItemAux:= SRC->RC_ITEM
		cClVLAux:= SRC->RC_CLVL
		lGrava  := .T.

		If RGB->(DbSeek(cFil + cProcFol + cMat + cPerFol + cSemFol + cRotFol + cPdAux + cCCAux + cItemAux + cClVLAux))
		  	If Val(PosSRV(  cPdAux , cFil , "RV_QTDLANC" )) > 1
				If RGB->(DbSeek(cFil + cProcFol + cMat + cPerFol + cSemFol + cRotFol + cPdAux + cCCAux + cItemAux + cClVLAux + cSeq))
					If !(RGB->RGB_ROTORI == cRotBen) .or. cSemFol < SRC->RC_SEMANA //Se estiver integrando várias semanas na mesma folha, não deve sobrescrever a verba
						While .T.
							If cSeq == "9"
								lGrava := .F.
								Exit
							EndIf
							cSeq := Soma1(cSeq)
							If RGB->(DbSeek(cFil + cProcFol + cMat + cPerFol + cSemFol + cRotFol + cPdAux + cCCAux + cItemAux + cClVLAux + cSeq))
								If RGB->RGB_ROTORI == cRotBen
									Loop
								Else
									RGB->( RecLock( "RGB" , .F. ) )
									Exit
								EndIf
							Else
								RGB->( RecLock( "RGB" , .T. ) )
								Exit
							EndIf
						Enddo
					Else
						RGB->( RecLock( "RGB" , .F. ) )
					EndIf
				Else
					RGB->( RecLock( "RGB" , .T. ) )
				EndIf
			Else
				If cSemFol <> SRC->RC_SEMANA //integração da semana posterior a semana da folha
					nHrsAux += RGB->RGB_HORAS
			  		nValAux += RGB->RGB_VALOR
				Else
					nHrsAux := RGB->RGB_HORAS
			  		nValAux := RGB->RGB_VALOR
			  	EndIf
		  		RGB->( RecLock( "RGB" , .F. ) )
			EndIf
		Else
			RGB->( RecLock( "RGB" , .T. ) )
		EndIf

		If lGrava
			RGB->RGB_FILIAL	:= SRC->RC_FILIAL
			RGB->RGB_MAT 	:= SRC->RC_MAT
			RGB->RGB_CC		:= cCCAux
			RGB->RGB_PD		:= cPdAux
			RGB->RGB_TIPO1	:= SRC->RC_TIPO1
			RGB->RGB_TIPO2	:= "G"
			RGB->RGB_HORAS  := nHrsAux
			RGB->RGB_VALOR	:= nValAux
			RGB->RGB_PARCEL	:= 0
			RGB->RGB_ITEM 	:= cItemAux
			RGB->RGB_CLVL 	:= cClVlAux
			RGB->RGB_PROCES	:= cProcFol
	      	RGB->RGB_PERIOD	:= cPerFol
			RGB->RGB_ROTEIR	:= cRotFol
			RGB->RGB_SEMANA	:= cSemFol
	      	RGB->RGB_ROTORI	:= cRotBen
	      	RGB->RGB_SEQ	:= cSeq
			RGB->RGB_DTREF  := SRC->RC_DATA //Grava a data de pagamento para que seja possível excluir apenas os registros da semana correta quando existir mais de uma semana integrada na mesma folha
			RGB->RGB_CONVOC := SRC->RC_CONVOC

			If lGPM19RGB
				ExecBlock("GPM19RGB", .F. , .F., { cRotFol, SRC->RC_FILIAL, SRC->RC_MAT, cPerFol, cSemFol } )
			EndIf

		 	RGB->(MsUnLock())
		 EndIf


		SRC->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc}fIntegraRTF
Efetua a integração do roteiro RTF no roteiro FOL do período em aberto
@author allyson.mesashi
@since 15/01/2019
@version P12.1.17
/*/
Function fIntegraRTF(cFil, cMat, cProcBen, cProcFol, cRotFol, cPerFol, cSemFol, cRotBen, cPerBen, cSemBen, aCodFol)
Local aArea			:= GetArea()
Local cKeySRC		:= cFil + cMat + cProcBen  + cRotBen + cPerBen + cSemBen
Local nValLiq		:= 0
Local nValLiqIR 	:= 0
Local cSeq			:= "0"
Local lGrava		:= .T.

DEFAULT lGPM19RGB 	:= ExistBlock("GPM19RGB")

DbSelectArea("SRA")
DbSetOrder(1)
DbSeek(cFil + cMat)

DbSelectArea("RGB")
DbSetOrder(RetORder("RGB","RGB_FILIAL+RGB_PROCES+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_MAT+RGB_PD+RGB_SEQ"))

DbSelectArea("SRC")//RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO, RC_SEMANA, R_E_C_N_O_, D_E_L_E_T_
DbSetOrder(6)

If(DbSeek(cKeySRC))
	While SRC->(!Eof() .and. RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA == cKeySRC )
		PosSrv(SRC->RC_PD, SRC->RC_FILIAL)
		If SRC->RC_PD == aCodFol[1658, 1]
			nValLiq   += SRC->RC_VALOR
		EndIf
		If SRV->RV_IR == "S" .And. SRV->RV_REFFER != "S" .And. SRV->RV_REF13 != "S" .And. SRV->RV_CODFOL != "0064"
			nValLiqIR += SRC->RC_VALOR
		EndIf
		SRC->(DbSkip())
	EndDo

	If nValLiq > 0
		If RGB->(DbSeek(cFil + cProcFol + cPerFol + cSemFol + cRotFol + cMat + aCodFol[1659, 1]))
			While .T.
				If cSeq == "9"
					lGrava := .F.
					Exit
				EndIf
				cSeq := Soma1(cSeq)
				If !RGB->(DbSeek(cFil + cProcFol + cPerFol + cSemFol + cRotFol + cMat + aCodFol[1659, 1] + cSeq))
					RGB->( RecLock( "RGB" , .T. ) )
					Exit
				EndIf
			Enddo
			If !lGrava
				RGB->( RecLock( "RGB" , .F. ) )
			EndIf
		Else
			RGB->( RecLock( "RGB" , .T. ) )
		EndIf
		RGB->RGB_FILIAL	:= SRA->RA_FILIAL
		RGB->RGB_MAT 	:= SRA->RA_MAT
		RGB->RGB_CC		:= SRA->RA_CC
		RGB->RGB_PD		:= aCodFol[1659, 1]
		RGB->RGB_TIPO1	:= SRC->RC_TIPO1
		RGB->RGB_TIPO2	:= "G"
		RGB->RGB_HORAS  := 0
		RGB->RGB_VALOR	:= nValLiq
		RGB->RGB_PARCEL	:= 0
		RGB->RGB_ITEM 	:= SRA->RA_ITEM
		RGB->RGB_CLVL 	:= SRA->RA_CLVL
		RGB->RGB_PROCES	:= cProcFol
		RGB->RGB_PERIOD	:= cPerFol
		RGB->RGB_ROTEIR	:= cRotFol
		RGB->RGB_SEMANA	:= cSemFol
		RGB->RGB_ROTORI	:= cRotBen
		RGB->RGB_SEQ	:= cSeq
		RGB->RGB_NUMID  := "RTF" + cPerBen + cSemBen //Ajuste para possibilitar a exclusão dos registros na RGB após cancelamento de reintegração e existir mais de um período de RTF integrado na mesma folha.

		If lGPM19RGB
			ExecBlock("GPM19RGB", .F. , .F., { cRotBen, SRA->RA_FILIAL, SRA->RA_MAT, cPerFol, cSemFol } )
		EndIf

		RGB->(MsUnLock())
	EndIf

	cSeq := "0"
	lGrava := .T.
	If nValLiqIR > 0
		If RGB->(DbSeek(cFil + cProcFol + cPerFol + cSemFol + cRotFol + cMat + aCodFol[1660, 1]))
			While .T.
				If cSeq == "9"
					lGrava := .F.
					Exit
				EndIf
				cSeq := Soma1(cSeq)
				If !RGB->(DbSeek(cFil + cProcFol + cPerFol + cSemFol + cRotFol + cMat + aCodFol[1660, 1] + cSeq))
					RGB->( RecLock( "RGB" , .T. ) )
					Exit
				EndIf
			Enddo
			If !lGrava
				RGB->( RecLock( "RGB" , .F. ) )
			EndIf
		Else
			RGB->( RecLock( "RGB" , .T. ) )
		EndIf
		RGB->RGB_FILIAL	:= SRA->RA_FILIAL
		RGB->RGB_MAT 	:= SRA->RA_MAT
		RGB->RGB_CC		:= SRA->RA_CC
		RGB->RGB_PD		:= aCodFol[1660, 1]
		RGB->RGB_TIPO1	:= SRC->RC_TIPO1
		RGB->RGB_TIPO2	:= "G"
		RGB->RGB_HORAS  := 0
		RGB->RGB_VALOR	:= nValLiqIR
		RGB->RGB_PARCEL	:= 0
		RGB->RGB_ITEM 	:= SRA->RA_ITEM
		RGB->RGB_CLVL 	:= SRA->RA_CLVL
		RGB->RGB_PROCES	:= cProcFol
		RGB->RGB_PERIOD	:= cPerFol
		RGB->RGB_ROTEIR	:= cRotFol
		RGB->RGB_SEMANA	:= cSemFol
		RGB->RGB_ROTORI	:= cRotBen
		RGB->RGB_SEQ	:= cSeq
		RGB->RGB_NUMID  := "RTF" + cPerBen + cSemBen //Ajuste para possibilitar a exclusão dos registros na RGB após cancelamento de reintegração e existir mais de um período de RTF integrado na mesma folha.

		If lGPM19RGB
			ExecBlock("GPM19RGB", .F. , .F., { cRotBen, SRA->RA_FILIAL, SRA->RA_MAT, cPerFol, cSemFol } )
		EndIf

		RGB->(MsUnLock())
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc}fAtuSeqRGB
Ajusta sequência de lançamentos ao cancelar a integração do roteiro RES
@author julio.silva
@since 09/12/2019
@version P12.1.17
/*/
Static Function fAtuSeqRGB(cFil,cMat,cProcesso,cPeriodo,cNumPag)
	Local aArea		:= GetArea()
	Local cKeyRGB	:= cFil + cProcesso + cMat + cPeriodo + cNumPag
	Local cKeyAtu	:= ""
	Local cRotRES	:= fGetCalcRot("4")
	Local cSeqAux	:= ""
	Local nRecRGB	:= 0
	Local lAtuRGB	:= .T.

	DbSelectArea("RGB")
	DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEQ+DTOS(RGB_DTREF)"))

	If DbSeek(cKeyRGB)
		While RGB->( !Eof() .and. RGB_FILIAL + RGB_PROCES + RGB_MAT + RGB_PERIOD + RGB_SEMANA == cKeyRGB )
			If !(RGB->RGB_ROTEIR == cRotRES)
				RGB->(DbSkip())
				Loop
			EndIf

			lAtuRGB := .T.
			nRecRGB := Recno()
			cKeyAtu := cKeyRGB + cRotRES + RGB_PD + RGB_CC + RGB_ITEM + RGB_CLVL
			cSeqAux	:= ""

			While lAtuRGB
				If DbSeek(cKeyAtu + cSeqAux) .And. !(Recno() == nRecRGB)
					cSeqAux := If(cSeqAux == "", "1", Soma1(cSeqAux))
				Else
					lAtuRGB := .F.
				EndIf
			EndDo

			DbGoTo(nRecRGB)

			RecLock("RGB",.F.)
			RGB_SEQ	   := cSeqAux
			MsUnLock()

			RGB->(DbSkip())
		EndDo
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fInverte
Inverte a seleção
@author allyson.mesashi
@since 16/11/2020
@version P12.1.27
/*/
Static Function fInverte( cMarca )

Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	If RecLock( (cAliasMark), .F. )
		(cAliasMark)->TAB_OK := IIf( (cAliasMark)->TAB_OK != cMarca, cMarca, '  ' )
		MsUnLock()
	EndIf
	(cAliasMark)->( dbSkip() )
EndDo

RestArea( aAreaMark )

Return .T.

/*/{Protheus.doc} fSelInt
Seleciona apenas os roteiros integrados
@author allyson.mesashi
@since 16/11/2020
@version P12.1.27
/*/
Static Function fSelInt( cMarca )

Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	If RecLock( (cAliasMark), .F. )
		(cAliasMark)->TAB_OK := IIf( !Empty((cAliasMark)->TAB_INTEG), cMarca, '  ' )
		MsUnLock()
	EndIf
	(cAliasMark)->( dbSkip() )
EndDo

RestArea( aAreaMark )

Return .T.

/*/{Protheus.doc} fVoltaIC
Atualiza o campo RG_CONFIC na integração da rescisão
@author Allyson Mesashi
@since 10/02/2021
/*/
Static Function fVoltaIC(cFilSRA, cMatSRA, cProcesso, cPeriodo, cNumPag)

Local cAliasSRG	:= GetNextAlias()
Local cFilter 	:= ""
Local cSet 		:= ""
Local cSRGSqlName
Local cQuery
Local cQueryUPD

If ( Select( cAliasSRG ) > 0 )
	( cAliasSRG )->( dbCloseArea() )
EndIf

cSRGSqlName := InitSqlName( "SRG" )

cQuery 	:= "UPDATE " + cSRGSqlName
cSet	:= " SET RG_CONFIC = '4'"
cFilter := " WHERE RG_FILIAL = '" + cFilSRA  + "'"
cFilter += " AND RG_MAT = '" + cMatSRA + "'"
cFilter += " AND RG_PROCES = '" + cProcesso  + "'"
cFilter += " AND RG_PERIODO = '" + cPeriodo + "'"
cFilter += " AND RG_SEMANA = '" + cNumPag  + "'"
cFilter += " AND RG_EFETIVA = 'S'"
cFilter += " AND RG_CONFIC = '2'"
cFilter += " AND D_E_L_E_T_ = ' '"

cQueryUPD := ( cQuery + cSet + cFilter )

TcSqlExec( cQueryUPD )
TcRefresh( cSRGSqlName )

Return

/*/{Protheus.doc} fVoltaIC
Verifica as filiais que possuem integração para o roteiro selecionado
@author Allyson Mesashi
@since 18/02/2021
/*/
Static Function fBuscFil( cRotInt )

Local aFilSRY	:= {}
Local cAliasTMP	:= GetNextAlias()
Local cQuery	:= ""

Default cRotInt	:= ""

cQuery := "SELECT RY_FILIAL"
cQuery += 	" FROM " + RetSqlName("SRY") + " SRY"
cQuery +=	" WHERE"
cQuery +=	" RY_CALCULO = '"+cRotInt+"' AND"
cQuery +=	" RY_INTEGRA = '1' AND"
cQuery +=	" SRY.D_E_L_E_T_ = ' '"
cQuery += 	" ORDER BY " + SqlOrder(SRY->(IndexKey()))

cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP)

While (cAliasTMP)->( !Eof() )
	aAdd(aFilSRY, { (cAliasTMP)->RY_FILIAL })
	(cAliasTMP)->( DbSkip() )
EndDo

(cAliasTMP)->( dbCloseArea() )

Return aFilSRY

/*/{Protheus.doc} fInfoBen
Pergunta se deve sobrepor/agrupar beneficios
@author Leandro Drumond
@since 06/07/2022
/*/
Static Function fInfoBen(nSobrePor,nAgrupa,lAglutina)
Local oDlg
Local lSobrePor
Local lAgrupar

DEFAULT lAglutina 	:= .T.
DEFAULT lIsBlind 	:= IsBlind()

Pergunte("GPEM015A",.F.) //Carrega valor padrão
nSobrepor := mv_par04
nAgrupa   := mv_par05

lSobrePor := nSobrePor == 1
lAgrupar  := nAgrupa == 1

If !lIsBlind

	DEFINE MSDIALOG oDlg FROM  94,1 TO 250,280 TITLE OemToAnsi(STR0052) PIXEL // "Integração de Benefícios"

		@ 10,20 CHECKBOX lSobrePor PROMPT STR0053 PIXEL SIZE 80, 10 //"Sobrepor Lançamentos"

		If lAglutina
			@ 30,20 CHECKBOX lAgrupar PROMPT STR0054 PIXEL SIZE 80, 10	//"Agrupar Benefícios"
		EndIf

		DEFINE SBUTTON FROM 55,60 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (.T.)

	nSobrepor := If(lSobrePor,1,2)
	nAgrupa   := If(lAgrupar,1,2)

	//Grava valores alterados
	If nSobrePor <> mv_par04 .or. nAgrupa <> mv_par05
		SetMVValue("GPEM015A", "MV_PAR04", nSobrepor)
		SetMVValue("GPEM015A", "MV_PAR05", nAgrupa)
		Pergunte("GPEM015A", .F.)
	EndIf
EndIf

Return Nil
