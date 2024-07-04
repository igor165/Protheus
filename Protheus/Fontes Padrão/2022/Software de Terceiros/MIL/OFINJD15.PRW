#Include "PROTHEUS.CH"
#Include "OFIXDEF.CH"
#include "OFINJD15.CH"
#include "FWCOMMAND.CH"

Static cMVGARJD_T := OFNJD15SIMU()

#DEFINE X3_USADO_EMUSO "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"	// TORNA USADO POR TODOS OS MODULOS

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @type function
    @author Rubens Takahashi
    @since  25/07/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007461_1"


// Nao fazer CH - DEFINE de uso interno
#DEFINE lDebug .f.

// DEFINE para utilizacao da matriz aVMCPeca
#DEFINE _VMC_PECA_TIPTEM_            01
#DEFINE _VMC_PECA_LIBVOO_            02
#DEFINE _VMC_PECA_GRUITE_            03
#DEFINE _VMC_PECA_CODITE_            04
#DEFINE _VMC_PECA_DESCRI_            05
#DEFINE _VMC_PECA_UM_                06
#DEFINE _VMC_PECA_QTDPEC_            07 // Qtde Peca enviada
#DEFINE _VMC_PECA_QTDPECRETORNADA_   08 // Qtde Peca retornada
#DEFINE _VMC_PECA_VLRUNITENVIADO_    09 // Valor unitario peca enviado
#DEFINE _VMC_PECA_VLRUNITRETORNADO_  10 // Valor unitario peca retornado
#DEFINE _VMC_PECA_VLRTOTALENVIADO_   11 // Valor Total Peca Enviado
#DEFINE _VMC_PECA_VLRTOTALRETORNADO_ 12 // Valor Total peca Retornado
#DEFINE _VMC_PECA_PROBQTDE_          13 // Problema com Qtde
#DEFINE _VMC_PECA_PROBQTDEACERTADO_  14 // Problema com Qtde (Acertado)
#DEFINE _VMC_PECA_PROBVALOR_         15 // Problema com Valor
#DEFINE _VMC_PECA_PROBVALORACERTADO_ 16 // Problema com Valor (Acertado)
#DEFINE _VMC_PECA_VLRREQUISITADO_    17 // Valor da Peca (Requisicao)
#DEFINE _VMC_PECA_TES_               18 // TES da Requisicao
#DEFINE _VMC_PECA_CONVUM_            19 // Houve Conversao de Unidade de Medida ?
#DEFINE _VMC_PECA_QTD1UM_            20 // Quantidade na Primeira Unidade de Medida
#DEFINE _VMC_PECA_PECOUTRCRED_       21 // Peca enviada como outros creditos ?
#DEFINE _VMC_PECA_PMPMATRIZREEMB_    22 // Matriz de Reembolso - PMP (R$)
#DEFINE _VMC_PECA_QTDRET1UM_         23 // Quantidade Retornada na Primeira Unidade de Medida
#DEFINE _VMC_PECA_UMPARACONVERSAO_   24 // Unidade de Medida para Requisicao
#DEFINE _VMC_PECA_VLRUNIT_ZSPA_      25 // Valor unitario peca - Garantia Especial
#DEFINE _VMC_PECA_VLRTOTAL_ZSPA_     26 // Valor Total peca - Garantia Especial

// DEFINE para utilizacao da matriz aVMCSrvc
#DEFINE _VMC_SRVC_TIPTEM_            01 // M->VMC_TIPTEM
#DEFINE _VMC_SRVC_LIBVOO_            02 // M->VMC_LIBVOO
#DEFINE _VMC_SRVC_GRUSER_            03 // M->VMC_GRUSER
#DEFINE _VMC_SRVC_CODSER_            04 // M->VMC_CODSER
#DEFINE _VMC_SRVC_TIPTRA_            05 // M->VMC_TIPTRA
#DEFINE _VMC_SRVC_TIPTRD_            06 // M->VMC_TIPTRD
#DEFINE _VMC_SRVC_LOCTRA_            07 // M->VMC_LOCTRA
#DEFINE _VMC_SRVC_RECNO_             08 // Recno
#DEFINE _VMC_SRVC_HORASENVIADO_      09 // M->VMC_QTDTRA
#DEFINE _VMC_SRVC_HORASRETORNADA_    10 // M->VMC_QSRRET
#DEFINE _VMC_SRVC_VLRHORAENVIADO_    11 // M->VMC_VALHRE
#DEFINE _VMC_SRVC_VLRHORARETORNADA_  12 // M->VMC_VALHRR
#DEFINE _VMC_SRVC_VLRTOTALENVIADO_   13 // M->VMC_VTSERE
#DEFINE _VMC_SRVC_VLRTOTALRETORNADO_ 14 // M->VMC_VTSERR
#DEFINE _VMC_SRVC_PROBQTDE_          15 // .f. // Problema com Qtde
#DEFINE _VMC_SRVC_PROBQTDEACERTADO_  16 // .f. // Problema com Qtde (Acertado)
#DEFINE _VMC_SRVC_PROBVALOR_         17 // .f. // Problema com Valor
#DEFINE _VMC_SRVC_PROBVALORACERTADO_ 18 // .f. // Problema com Valor (Acertado)
#DEFINE _VMC_SRVC_ORIGEM_            19 // M->VMC_ORIGEM // Origem do Registro 1=Fabrica / 2=Manual
#DEFINE _VMC_SRVC_NAOAPROVADO_       20 // .f. // Servico n„o aprovado pela John Deere
#DEFINE _VMC_SRVC_POS_ACOLS_         21 // Linha da aCols Relacionada

// DEFINE para utilizacao da Matriz aVMCOutr
#DEFINE _VMC_OUTR_TIPTEM_            01 // VMC_TIPTEM
#DEFINE _VMC_OUTR_LIBVOO_            02 // VMC_LIBVOO
#DEFINE _VMC_OUTR_GRUSER_            03 // VMC_GRUSER
#DEFINE _VMC_OUTR_CODSER_            04 // VMC_CODSER
#DEFINE _VMC_OUTR_CODMAT_            05 // VMC_CODMAT
#DEFINE _VMC_OUTR_CODMAD_            06 // VMC_CODMAD
#DEFINE _VMC_OUTR_CUSMAT_            07 // VMC_CUSMAT
#DEFINE _VMC_OUTR_CUSMAR_            08 // VMC_CUSMAR
#DEFINE _VMC_OUTR_COMENT_            09 // VMC_COMENT
#DEFINE _VMC_OUTR_PROBVALOR_         10 // Problema com Valor
#DEFINE _VMC_OUTR_PROBVALORACERTADO_ 11 // Problema com Valor (Acertado)
#DEFINE _VMC_OUTR_RECNO_             12 // Recno
#DEFINE _VMC_OUTR_NAOTRANSMITIDO_    13 // Servico nao transmitido mas retornado pela fabrica
#DEFINE _VMC_OUTR_NAOAPROVADO_       14 // .f. // Servico n„o aprovado pela John Deere


// TO-DO
// 1) Validar para nao permitir que seja enviado deslocamento com tipo de servico de terceiros

// Classe para compatibilizacao - MsNewGetDados vs ExecAuto
CLASS GetDVMC
	DATA aHeader
	DATA aCols
	DATA nAt

	METHOD Create() CONSTRUCTOR
	METHOD Enable()
	METHOD Disable()
ENDCLASS

METHOD Create() CLASS GetDVMC
	::aHeader := {}
	::aCols := {}
	::nAt := 0
Return SELF

METHOD Enable() CLASS GetDVMC
Return

METHOD Disable() CLASS GetDVMC
Return
//

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ OFINJD15 ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Garantia JD - VMB e VMC                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFINJD15(xAutoCab, xAutoIte ,nOpcAuto, lNoMBrowse)

Default lNoMBrowse := .f.

Private aRotina   := MenuDef()
Private cCadastro := STR0001 // "Garantia John Deere"

Private cCodBateria

Private lB1CODFAB := (SB1->(FieldPos("B1_CODFAB")) <> 0)
Private oSqlHpl := DMS_SqlHelper():New()
cCodBateria := "DQ68477                    /DQ68477                    /DQ68478                    /AH232902                   /CB11480232                 /CQM14168                   /CQM14169                   /SJ10989                    /SJ10990                    /AKK11390                   /"
cCodBateria += "TY21754                    /TY23020                    /TY25221                    /TY25803                    /TY25866                    /TY25876                    /TY25878                    /TY25879                    /TY25881                    /TY26442                    /TY26783                    /TY6128                     /"

VMB->(dbSetOrder(1))

Private lIJD01Auto := ( xAutoCab <> NIL )

// Cria pergunte da rotina
OFNJD15SX1(.f.)
//

If cMVGARJD_T
	MsgInfo("Simulacao")
	If .f.
		OFINJD15TCK()
	EndIf
EndIf

If !lIJD01Auto

	If lNoMBrowse
		dbSelectArea("VMB")
		If ( nOpc <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
		EndIf
	Else
		SetKey(VK_F12,{ || OFNJD15SX1(.t.) })
		mBrowse( 6, 1,22,75,"VMB",,,,,,)
		SetKey(VK_F12,Nil)
	EndIf
Else
	aAutoCab := aClone(xAutoCab)
	aAutoIte := aClone(xAutoIte)
	MBrowseAuto( nOpcAuto , aAutoCab , "VO1" , .f. )
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥OFNJD15EXEC ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Garantia JD - VMB e VMC                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15EXEC(cAlias,nReg,nOpc,lTrans)

Local nCntFor := 0
Local nAuxPos
Local cTipoGar
Local cSQL
Local nVMBREPARO := 0
Local nVMBNUMOSV := 0
Local cNumReparo

Local cAliasVX5 := "TVX5"

Local cCpoVisualiza
Local cCpoObrigat

Local cAuxNView := ""

Local lRet := .t.

Local aTpGarCod := {}
Local aTpGarDes := {}
Local aRetParam := {}

Default lTrans := .f.

Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg

// Variavel utilizada na consulta padrao B16
Private cGruIte := ""

If !lIJD01Auto .and. ( nOpc == 3 ) .and. __cUserID <> "000000"
	MsgInfo(STR0147,STR0111) // N„o È possÌvel gerar um registro manualmente. O registro ser· gerado no momento da liberaÁ„o do tipo de tempo / ATEN«√O
	Return
EndIf

If ( nOpc == 4 .or. nOpc == 5) .and. !Empty(VMB->VMB_STATUS)
	MsgInfo(STR0002) // "N„o È possÌvel alterar a solicitaÁ„o"
	nOpc := 2
EndIf

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
nOpcE     := nOpc
nOpcG     := nOpc
/////////////////////////////////////////

If INCLUI
	If !lIJD01Auto
		cSQL := "SELECT VX5_CODIGO , VX5_DESCRI FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5_CHAVE = '006' AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5 , .F., .T. )
		While !(cAliasVX5)->(Eof())
			AADD(aTpGarCod , AllTrim((cAliasVX5)->VX5_CODIGO) )
			AADD(aTpGarDes , (cAliasVX5)->VX5_DESCRI )
			(cAliasVX5)->(dbSkip())
		EndDo
		(cAliasVX5)->(dbCloseArea())
		DbSelectArea("VMB")

		aRetParam := {}
		aParParam := {{3,STR0003,1,aTpGarDes,90,,.T.}} // "Tipo de Garantia"
		If !ParamBox(aParParam,STR0003,aRetParam) // "Tipo de Garantia"
			Return .f.
		EndIf
		cTipoGar := aTpGarCod[aRetParam[1]]
	Else
		// Pegar o tipo da garantia da aAutoCab
		nAuxPos := aScan( aAutoCab , { |x| x[1] == "VMB_TIPGAR" } )
		cTipoGar := aAutoCab[nAuxPos,2]
	EndIf
Else
	cTipoGar := VMB->VMB_TIPGAR
EndIf

OFNJD15CPO(cTipoGar,lTrans,@cCpoVisualiza,@cCpoObrigat,@cAuxNView)

aHeader := {}
aCols   := {}

RegToMemory("VMB" , .f. , .t. , .t. ) // .t. para carregar campos virtuais
RegToMemory("VMC",.f.) // .t. para carregar campos virtuais

aCpoEnchoice:={}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Executa a Modelo 3                                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cTitulo       := cCadastro
cAliasEnchoice:= "VMB"
cAliasGetD    := "VMC"
cLinOk        := "OFNJD15LOK()"
cTudOk        := "OFNJD15TOK()"
cFieldOk      := "AllwaysTrue()" // N„o utilizar FieldOK, pois o fonte È chamado atraves de ExecAuto

nOpca := 0

FM_Mod3(;
	cTitulo,;                                              // cTitulo
	cAliasEnchoice,;                                       // cAlias1
	cAliasGetD,;                                           // cAlias2
	@aCpoEnchoice,;                                        // aAuxEnchoice
	,;                                                     // aAltEnchoice
	@aHeader,;                                             // aAuxAHeader
	@aCols,;                                               // aAuxACols
	cFieldOk,;                                             // cFieldOk
	cLinOk,;                                               // cLinOk
	cTudOk,;                                               // cTudoOk
	,;                                                     // cDelOk
	nOpcE,;                                                // nOpcE
	nOpcG,;                                                // nOpcG
	,;                                                     // lVirtual
	oMainWnd,;                                             // _oWindow
	@oAuxDlg,;                                             // _oDlg
	@oAuxEnchoice,;                                        // _oEnchoice
	@oAuxGetDados,;                                        // _oGetDados
	cAuxNView,;                                            // cEnchNView
	"VMC_CODGAR/",;                                        // cGetDNView
	1 /* nOrdGet2 */ ,;                                    // nOrdGet2
	"VMC->VMC_FILIAL+VMC->VMC_CODGAR" /* cChvGet2 */ ,;    // cChvGet2
	xFilial("VMC") + VMB->VMB_CODGAR  /* cVlChvGet2 */ ,;  // cVlChvGet2
	,;                                                     // aRetPos
	,;                                                     // nPercTela
	,;                                                     // nPercObj1
	,;                                                     // aAlter
	,;                                                     // lWalkThru
	lIJD01Auto )                                           // lAuto

If lIJD01Auto
	oAuxGetDados := GetDVMC():Create()
Else
	aAuxAAlter := aClone(oAuxGetDados:aAlter)

	// TEMPORARIO... N„o ser· permitido alterar campos de valores ...
	nCntFor := 1
	While nCntFor <= Len(aAuxAAlter)
		If AllTrim(aAuxAAlter[nCntFor]) $ "VMC_TIPOPS/VMC_GRUITE/VMC_CODITE/VMC_UM/VMC_GRUSER/VMC_CODSER/VMC_QTDPEC/VMC_VUPECE/VMC_VTPECE/VMC_ADITIV/VMC_QTDTRA/VMC_VALHRE/VMC_VTSERE/VMC_CUSMAT"
			aDel(aAuxAAlter,nCntFor)
			aSize(aAuxAAlter,Len(aAuxAAlter)-1)
		Else
			nCntFor++
		EndIf
	EndDo
	//
	oAuxGetDados:lInsert := .f.
	oAuxGetDados:lDelete := .f.
EndIf

M->VMB_TIPGAR := cTipoGar
M->VMB_DTPGAR := Posicione("VX5",1,xFilial("VX5")+"006"+M->VMB_TIPGAR,"VX5_DESCRI")

If !Empty(M->VMB_CHAINT)
	VV1->(dbSetOrder(1))
	VV1->(MsSeek(xFilial("VV1") + M->VMB_CHAINT))

	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD ))
EndIf

If !lIJD01Auto
	oAuxGetDados:oBrowse:bChange := {|| FG_MEMVAR(oAuxGetDados:aHeader,oAuxGetDados:aCols,oAuxGetDados:nAt) , OFNJD15AA() }
	//oAuxGetDados:oBrowse:bDelete := {|| OFNJD15DEL(nOpc) }
	oAuxGetDados:oBrowse:Refresh()

	ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{ || IIf(OFNJD15OK(nOpc,cCpoObrigat,lTrans),(oAuxDlg:End(),nOpca := 1),.f.) }, { || oAuxDlg:End() },,)
Else

	nOpca := 1

	If INCLUI
		nVMBNUMOSV := aScan( aAutoCab , { |x| x[1] == "VMB_NUMOSV" } )
		nVMBREPARO := aScan( aAutoCab , { |x| x[1] == "VMB_REPARO" } )
		cNumReparo := OFNJD15RP( aAutoCab[nVMBNUMOSV,2] )
		If nVMBREPARO > 0
			aAutoCab[nVMBREPARO,2] := cNumReparo
		Else
			AADD( aAutoCab , { "VMB_REPARO" , cNumReparo , NIL } )
		EndIf
	EndIf

	If !EnchAuto("VMB",aAutoCab , { || OFNJD15OK(nOpc) } , nOpc )
		lMsErroAuto := .t.
	EndIf

	If !lMsErroAuto .and. !MsGetDAuto( aAutoIte , cLinOk, cTudOk , aAutoCab , nOpc , .f. )
		lMsErroAuto := .t.
	EndIf

	If lMsErroAuto
		RollBackSXE()
		nOpca := 0
		Return .f.
	EndIf

	oAuxGetDados:aCols := aClone(aCols)

EndIf
If nOpca == 1
	OFNJD15GRV(nOpc)
	lRet := .t.
Else
	RollBackSXE()
	lRet := .f.
EndIf

Return lRet



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15AA ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Controla os campos editaveis da getdados                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15AA()

If M->VMC_ORIGEM == "1"

	// Se for PMP, poder· ser alterado o local de trabalho ...
	If M->VMB_TIPGAR == "ZPIP" .and. M->VMC_TIPOPS == "S"
		oAuxGetDados:aAlter := oAuxGetDados:oBrowse:aAlter := { "VMC_LOCTRA" }
	Else
		oAuxGetDados:aAlter := oAuxGetDados:oBrowse:aAlter := {}
	EndIf

Else
	oAuxGetDados:aAlter := oAuxGetDados:oBrowse:aAlter := aClone(aAuxAAlter)
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15CPO∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera variavel auxiliar para controlar os campos que serao  ∫±±
±±∫          ≥ visiveis dependendo do tipo de solicitacao de garantia     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15CPO(cTipoGar,lTrans,cCpoVisualiza,cCpoObrigat,cAuxNView)

cCpoVisualiza := ""
cCpoObrigat   := ""
cAuxNView     := ""

cCpoVisualiza += "VMB_WARRME/VMB_MEMTYP/VMB_STATSG/VMB_WAROBS/VMB_DEALER/"

cCpoVisualiza += "VMB_DTACCS/VMB_DTACSL/"

Do Case
// Revis„o
Case cTipoGar == "ZZMK"
	cCpoVisualiza += "VMB_CODGAR/VMB_STATUS/VMB_DTAUTA/VMB_TIPGAR/VMB_DTPGAR/VMB_SUBGAR/VMB_DSBGAR/VMB_NUMOSV/VMB_CHASSI/VMB_CHAINT/"
	cCpoVisualiza += "VMB_REPARO/VMB_NREFE2/VMB_MODELO/VMB_SERMOD/VMB_QTDUTI/VMB_UNIMED/VMB_PLAMAN/VMB_INTSRV/VMB_INTSRD/"
	cCpoVisualiza += "VMB_DATMAN/VMB_NOTRAV/VMB_TIPMAQ/VMB_DTFALH/VMB_CLAIM /VMB_DTWMEM/VMB_SRVNNF/VMB_SRVSNF/VMB_SREEMB/"

	cCpoObrigat += "VMB_CODGAR/VMB_TIPGAR/VMB_SUBGAR/VMB_NUMOSV/VMB_REPARO/VMB_QTDUTI/VMB_UNIMED/VMB_PLAMAN/VMB_INTSRV/VMB_CHASSI/VMB_CHAINT/"

	If lTrans
		cCpoObrigat += "VMB_NOTRAV/"
	EndIf

// Campanha (PMP)
Case cTipoGar == "ZPIP"
	cCpoVisualiza += "VMB_CODGAR/VMB_NUMOSV/VMB_TIPGAR/VMB_DTPGAR/VMB_REPARO/VMB_NREFE2/VMB_DTABER/VMB_DTENVI/VMB_DTRETO/VMB_CLAIM /VMB_CRMEMO/VMB_STATUS/"
	cCpoVisualiza += "VMB_DTATUA/VMB_CHASSI/VMB_CHAINT/VMB_MODELO/VMB_SERMOD/VMB_NROPIP/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/"
	cCpoVisualiza += "VMB_CODITE/VMB_KEYPAR/VMB_FALHA /VMB_FALHAD/VMB_FALCOM/VMB_FALARE/VMB_MAQPAR/VMB_MAQPAD/VMB_DATMAN/"
	cCpoVisualiza += "VMB_DTWMEM/VMB_SRVNNF/VMB_SRVSNF/VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_ESPOBS/VMB_SREEMB/"

	cCpoObrigat += "VMB_CODGAR/VMB_TIPGAR/VMB_NUMOSV/VMB_REPARO/VMB_CHASSI/VMB_CHAINT/VMB_NROPIP/VMB_QTDUTI/VMB_UNIMED/VMB_CODSTA/"
	cCpoObrigat += "VMB_COROBS/VMB_CHASSI/VMB_CHAINT/"

// Normal
Case cTipoGar == "ZNRM"
	cCpoVisualiza += "VMB_CODGAR/VMB_TIPGAR/VMB_DTPGAR/VMB_NUMOSV/VMB_REPARO/VMB_NREFE2/VMB_DTABER/VMB_DTENVI/VMB_DTRETO/"
	cCpoVisualiza += "VMB_CLAIM /VMB_CRMEMO/VMB_STATUS/VMB_DTATUA/VMB_CHASSI/VMB_CHAINT/VMB_TIPMAQ/VMB_MODELO/VMB_SERMOD/VMB_QTDUTI/"
	cCpoVisualiza += "VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_SERCOM/VMB_FALHA /VMB_FALHAD/VMB_FALCOM/VMB_FALARE/"
	cCpoVisualiza += "VMB_MAQPAR/VMB_MAQPAD/VMB_DATMAN/VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_DTWMEM/VMB_SRVNNF/VMB_SRVSNF/VMB_ESPOBS/"

	cCpoObrigat += "VMB_TIPGAR/VMB_NUMOSV/VMB_REPARO/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/"
	cCpoObrigat += "VMB_FALHA /VMB_FALARE/VMB_MAQPAR/VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_CHASSI/VMB_CHAINT/"

// PeÁas
Case cTipoGar == "ZPAR"
	cCpoVisualiza += "VMB_CODGAR/VMB_TIPGAR/VMB_DTPGAR/VMB_NUMOSV/VMB_REPARO/VMB_NREFE2/VMB_DTABER/VMB_DTENVI/VMB_DTRETO/"
	cCpoVisualiza += "VMB_CLAIM /VMB_CRMEMO/VMB_STATUS/VMB_DTATUA/VMB_CHASSI/VMB_CHAINT/VMB_TIPMAQ/VMB_INSPOR/VMB_MODELO/VMB_SERMOD/"
	cCpoVisualiza += "VMB_INSDAT/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_SERCOM/VMB_USOPEC/"
	cCpoVisualiza += "VMB_UNUSPC/VMB_FALHA /VMB_FALHAD/VMB_FALCOM/VMB_FALARE/VMB_MAQPAR/VMB_MAQPAD/VMB_OSANTE/VMB_DATMAN/"
	cCpoVisualiza += "VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_DTWMEM/VMB_SRVNNF/VMB_SRVSNF/VMB_NFANTE/VMB_SRANTE/VMB_ESPOBS/"

	cCpoObrigat += "VMB_CODGAR/VMB_TIPGAR/VMB_NUMOSV/VMB_REPARO/VMB_INSPOR/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/"
	cCpoObrigat += "VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_USOPEC/VMB_UNUSPC/VMB_FALHA /VMB_FALHAD/VMB_FALARE/"
	cCpoObrigat += "VMB_MAQPAR/VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/"

// Bateria
Case cTipoGar == "ZZBT"

	cCpoVisualiza += "VMB_CODGAR/VMB_TIPGAR/VMB_DTPGAR/VMB_NUMOSV/VMB_REPARO/VMB_NREFE2/VMB_DTABER/VMB_DTENVI/VMB_DTRETO/"
	cCpoVisualiza += "VMB_CLAIM /VMB_CRMEMO/VMB_STATUS/VMB_DTATUA/VMB_CHASSI/VMB_CHAINT/VMB_TIPMAQ/VMB_APLICA/VMB_INSPOR/VMB_MODELO/"
	cCpoVisualiza += "VMB_SERMOD/VMB_INSDAT/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_TESRES/"
	cCpoVisualiza += "VMB_FALHA /VMB_FALHAD/VMB_FALCOM/VMB_DATMAN/VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_DTWMEM/VMB_SRVNNF/"
	cCpoVisualiza += "VMB_SRVSNF/VMB_OSANTE/VMB_NFANTE/VMB_SRANTE/VMB_ESPOBS/"

	cCpoObrigat += "VMB_CODGAR/VMB_TIPGAR/VMB_NUMOSV/VMB_REPARO/VMB_APLICA/VMB_INSPOR/VMB_QTDUTI/VMB_UNIMED/"
	cCpoObrigat += "VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_FALHA /VMB_FALHAD/VMB_CAUOBS/"
	cCpoObrigat += "VMB_QUEOBS/VMB_COROBS/"

// Esteira
Case cTipoGar == "ZZTK"

	cCpoVisualiza += "VMB_CODGAR/VMB_TIPGAR/VMB_DTPGAR/VMB_NUMOSV/VMB_REPARO/VMB_NREFE2/VMB_DTABER/VMB_DTENVI/VMB_DTRETO/VMB_CLAIM /VMB_CRMEMO/VMB_STATUS/"
	cCpoVisualiza += "VMB_DTATUA/VMB_CHASSI/VMB_TIPMAQ/VMB_APLICA/VMB_INSPOR/VMB_MODELO/VMB_SERMOD/VMB_INSDAT/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/"
	cCpoVisualiza += "VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_SERCOM/VMB_USOPEC/VMB_UNUSPC/VMB_FALHA /VMB_FALHAD/VMB_FALCOM/VMB_ALTMED/VMB_UNIALT/VMB_OSANTE/VMB_DATMAN/"
	cCpoVisualiza += "VMB_DTWMEM/VMB_SRVNNF/VMB_SRVSNF/VMB_ESPOBS/"

	cCpoObrigat += "VMB_CODGAR/VMB_TIPGAR/VMB_NUMOSV/VMB_REPARO/VMB_APLICA/VMB_INSPOR/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/"
	cCpoObrigat += "VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_USOPEC/VMB_UNUSPC/VMB_FALHA /VMB_FALHAD/VMB_ALTMED/VMB_UNIALT/"
	cCpoObrigat += "VMB_DATMAN/"


// AutorizaÁ„o Especial
Case cTipoGar == "ZSPA"

	cCpoVisualiza += "VMB_CODGAR/VMB_TIPGAR/VMB_DTPGAR/VMB_NUMOSV/VMB_REPARO/VMB_NREFE2/VMB_DTABER/VMB_DTENVI/VMB_DTRETO/"
	cCpoVisualiza += "VMB_CLAIM /VMB_CRMEMO/VMB_STATUS/VMB_DTATUA/VMB_CHASSI/VMB_CHAINT/VMB_TIPMAQ/VMB_MODELO/VMB_SERMOD/VMB_QTDUTI/"
	cCpoVisualiza += "VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/VMB_CODITE/VMB_KEYPAR/VMB_FALHA /VMB_FALHAD/VMB_FALCOM/VMB_FALARE/"
	cCpoVisualiza += "VMB_MAQPAR/VMB_MAQPAD/VMB_DATMAN/VMB_TIPESP/VMB_TIPESD/VMB_CLIVAL/VMB_CLIPER/VMB_CONVAL/VMB_CONPER/"
	cCpoVisualiza += "VMB_JDVAL /VMB_JDPER /VMB_ESPOBS/VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_DTWMEM/VMB_SRVNNF/VMB_SRVSNF/"
	cCpoVisualiza += "VMB_TOTALG/VMB_TOTALD/"

	cCpoVisualiza += "VMB_CLIVAR/VMB_CONVAR/VMB_JDVAR /"

	cCpoObrigat += "VMB_CODGAR/VMB_TIPGAR/VMB_NUMOSV/VMB_REPARO/VMB_QTDUTI/VMB_UNIMED/VMB_DTFALH/VMB_CODSTA/VMB_GRUITE/"
	cCpoObrigat += "VMB_CODITE/VMB_KEYPAR/VMB_FALHA /VMB_FALHAD/VMB_FALARE/VMB_MAQPAR/VMB_TIPESP/"
//	cCpoObrigat += "VMB_CLIVAL/VMB_CLIPER/"
	cCpoObrigat += "VMB_JDVAL /VMB_JDPER /VMB_ESPOBS/VMB_CAUOBS/VMB_CHASSI/VMB_CHAINT/"
	cCpoObrigat += "VMB_CAUOBS/VMB_QUEOBS/VMB_COROBS/VMB_ESPOBS/"

EndCase

If lTrans
	cCpoObrigat += "/VMB_DATMAN/"
EndIf

SX3->(dbSetOrder(1))
SX3->(dbSeek("VMB"))
While !SX3->(Eof())
	If SX3->X3_PROPRI <> "U" .and. !SX3->X3_CAMPO $ cCpoVisualiza
		cAuxNView += SX3->X3_CAMPO + "®"
	EndIf
	SX3->(dbSkip())
EndDo

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥OFNJD15LOK ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Linha OK - Garantia JD - VMB e VMC                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15LOK()
Local lRet := .t.
lRet := FG_OBRIGAT()
If lRet
	OFNJD15SI() // Levanta/Atribui sequencia dos itens das garantias
EndIf
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥OFNJD15TOK ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Tudo OK - Garantia JD - VMB e VMC                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15TOK()
Local lRet := .t.
lRet := AllwaysTrue()
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥OFNJD15DEL ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Delete - Garantia JD - VMB e VMC                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15DEL(nOpc)
If nOpc != 2 .and. nOpc != 5 .and. M->VMC_ORIGEM <> "1"
	oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := !oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
	oAuxGetDados:Refresh()
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥OFNJD15OK  ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ OK Tela - Garantia JD - VMB e VMC                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15OK(nOpc,cCpoObrigat,lTrans)

Local nCont := 0
Local lRet  := .t.

Default cCpoObrigat := ""

If nOpc != 2 .and. nOpc != 5
	If !lIJD01Auto

		// Valida a qtde utilizada
		If !Empty(M->VMB_CHASSI) .and. !OFNJD15UH(M->VMB_DTFALH,M->VMB_CHASSI,M->VMB_QTDUTI,M->VMB_UNIMED,M->VMB_CODGAR, .T.)
			//MsgInfo(STR0004) // "Quantidade utilizada inv·lida"
			lRet := .f.
		EndIf
		//

		If M->VMB_CODSTA == "3"
			MsgInfo(STR0005) // "N„o È permitido utilizar o cÛdigo '3'"
			lRet := .f.
		EndIf
		//

		// Regras especificas quando for alteracao para transmissao
		If lTrans

			DbSelectArea("VMB")
			For nCont := 1 to Len(aCpoEnchoice)
				If ( X3Obrigat(aCpoEnchoice[nCont]) .or. aCpoEnchoice[nCont] $ cCpoObrigat) .and. Empty(&("M->"+aCpoEnchoice[nCont]))
					Help(" ",1,"OBRIGAT",,RetTitle(aCpoEnchoice[nCont]),4,1 )
					lRet := .f.
					Exit
				EndIf
			Next

			If M->VMB_TIPGAR == "ZSPA" .and. M->VMB_TOTALG <> M->VMB_TOTALD
				MsgInfo(STR0006) // "Valor do rateio È diferente do valor total da SolicitaÁ„o de Garantia"
				lRet := .f.
			EndIf

//			If !(M->VMB_TIPGAR $ "ZPAR") .and. M->VMB_DATMAN > dDataBase
//				MsgStop("Data do reparo inv·lida")
//				lRet := .f.
//			EndIf

			// Regras especificas ...
			If M->VMB_TIPGAR $ "ZZBT/ZZTK" .and. M->VMB_INSPOR == "R"
				If Empty(M->VMB_INSDAT)
					Help(" ",1,"OBRIGAT",,RetTitle("VMB_INSDAT"),4,1 )
					lRet := .f.
				EndIf
				If Empty(M->VMB_OSANTE)
					Help(" ",1,"OBRIGAT",,RetTitle("VMB_OSANTE"),4,1 )
					lRet := .f.
				EndIf
			EndIf
			If M->VMB_TIPGAR $ "ZNRM/ZPAR/ZSPA/ZZTK" .and. M->VMB_FALHA == "17" .and. Empty(M->VMB_FALCOM)
				Help(" ",1,"OBRIGAT",,RetTitle("VMB_FALCOM"),4,1 )
				lRet := .f.
			EndIf
			If M->VMB_TIPGAR $ "ZZBT" .and. M->VMB_FALHA == "75" .and. Empty(M->VMB_FALCOM)
				Help(" ",1,"OBRIGAT",,RetTitle("VMB_FALCOM"),4,1 )
				lRet := .f.
			EndIf
			//

//			If M->VMB_TIPGAR $ "ZPAR/ZZBT" .and. Empty(M->VMB_CHASSI) .and. (Empty(M->VMB_MODELO) .or. Empty(M->VMB_SERMOD))
//				MsgStop("Para garantia de peÁas/bateria sem chassi È necess·rio informar o modelo e n˙mero de sÈrie")
//				lRet := .f.
//			EndIf
			If M->VMB_TIPGAR $ "ZPAR/ZZBT" .and. Empty(M->VMB_CHASSI) .and. Empty(M->VMB_MODELO)
				MsgStop(STR0007) // "Para garantia de peÁas/bateria sem chassi È necess·rio informar o modelo"
				lRet := .f.
			EndIf

			// Garantia de PeÁas
			If M->VMB_TIPGAR = "ZPAR"
				If M->VMB_INSPOR == "C" .and. aScan( oAuxGetDados:aCols , { |x| x[FG_POSVAR("VMC_TIPOPS","aHeader")] == "S" .and. !x[Len(x)] } ) <> 0
					MsgStop(STR0008) // "Garantia de peÁas instalada pelo cliente n„o pode haver serviÁos."
					lRet := .f.
				EndIf

				If M->VMB_INSPOR == "C" .and. Empty(M->VMB_NFANTE)
					MsgStop(STR0009) // "Informe a nota fiscal anterior."
					lRet := .f.
				EndIf

				If M->VMB_INSPOR == "D" .and. Empty(M->VMB_OSANTE)
					MsgStop(STR0010) // "Informe a OS anterior."
					lRet := .f.
				EndIf

				If M->VMB_TIPGAR == "D" .and. Empty(M->VMB_INSDAT)
					Help(" ",1,"OBRIGAT",,RetTitle("VMB_INSDAT"),4,1 )
					lRet := .f.
				EndIf
			EndIf

			If M->VMB_DTFALH > M->VMB_DATMAN
				MsgStop(STR0011) // "Data da falha n„o pode ser maior do que a data de manutenÁ„o"
				lRet := .f.
			EndIf

			If M->VMB_TIPGAR == "ZSPA"
				If M->VMB_TIPESP $ "01/08/09/10/11"
					MsgStop(STR0012) // "Tipo de Garantia especial inv·lido para produto AgrÌcola"
					lRet := .f.
				EndIf
			EndIf

//				If M->VMB_INSPOR == "D" .and. Empty(M->VMB_DATMAN)
//					MsgStop("Informa da data do reparo.")
//					lRet := .f.
//				EndIf
//			EndIf

			// Garantia de Bateria
			If M->VMB_TIPGAR == "ZZBT"
				// Se a maquina È nova, so pode ser instalada pela f·brica
				If M->VMB_CODSTA == "2" .and. M->VMB_INSPOR <> "F"
					MsgStop(STR0013) // "Bateria de equipamento novo sÛ pode ter sido instalada pela F·brica"
					lRet := .f.
				EndIf
			EndIf
			//

			// Se for garantia de bateria, verifica se existe servico lancado.
			If M->VMB_TIPGAR == "ZZBT" .AND. M->VMB_INSPOR <> "F"
				If aScan( oAuxGetDados:aCols , { |x| x[FG_POSVAR("VMC_TIPOPS","aHeader")] == "S" .and. !x[Len(x)] } ) <> 0
					MsgStop(STR0014) // "Garantia de Bateria instalada pelo Concession·rio/Cliente n„o permite serviÁo"
					lRet := .f.
				EndIf
			EndIf
			//

			// Garantia de Bateria
			If M->VMB_TIPGAR == "ZZBT"
				// Se codigo comecar com TY so pode ser instalada pelo concessionario
//				If SubStr(M->VMC_CODITE,1,2) == "TY" .and. M->VMB_INSPOR <> "R"
//				Ot·vio, 27/03/2014 - De acordo com Gilberto a peÁa a ser validada È a peÁa chave, e n„o as peÁas/baterias requisitadas na ordem de serviÁo.
				If SubStr(M->VMB_KEYPAR,1,2) == "TY" .and. M->VMB_INSPOR <> "R"
					MsgStop(STR0016) // "Bateria informada so pode ser enviada em SolicitaÁ„o de Garantia instalada pelo Concession·rio/Cliente"
					lRet := .f.
				EndIf
			EndIf

		EndIf

		nQtdeBat := 0
		nHoraBat := 0
		For nCont := 1 to Len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nCont,Len(oAuxGetDados:aCols[nCont])]
				FG_MEMVAR(oAuxGetDados:aHeader,oAuxGetDados:aCols,nCont)

				Do Case
				Case M->VMC_TIPOPS == "P"
					// Se for utilizado bateria, so pode enviar garantia como bateria
					If M->VMB_TIPGAR <> "ZZBT" .and. M->VMC_CODITE $ cCodBateria
						MsgInfo(STR0015) // "Tipo de garantia inv·lida quando utilizada um produto bateria"
						lRet := .f.
					EndIf

					If M->VMB_TIPGAR == "ZZBT"
						nQtdeBat += M->VMC_QTDPEC
					EndIf

				Case M->VMC_TIPOPS == "S"
					If Empty(M->VMC_TIPTRA)
						Help(" ",1,"OBRIGAT",,RetTitle("VMC_TIPTRA"),4,1 )
						lRet := .f.
					EndIf
					If Empty(M->VMC_LOCTRA)
						Help(" ",1,"OBRIGAT",,RetTitle("VMC_LOCTRA"),4,1 )
						lRet := .f.
					EndIf

					If M->VMB_TIPGAR == "ZZBT"
						nHoraBat += M->VMC_QTDTRA
					EndIf

				Case M->VMC_TIPOPS == "O"
					If Empty(M->VMC_CODMAT)
						Help(" ",1,"OBRIGAT",,RetTitle("VMC_CODMAT"),4,1 )
						lRet := .f.
					EndIf
					If !(Alltrim(M->VMC_CODMAT) $ "WTYSUBL5/WTYSUBL6/WTYSUBL8")
						If Empty(M->VMC_COMENT)
							Help(" ",1,"OBRIGAT",,RetTitle("VMC_COMENT"),4,1 )
							lRet := .f.
						EndIf
					EndIf
				EndCase
			EndIf
		Next nCont

		If M->VMB_TIPGAR == "ZZBT"
			If nQtdeBat == 0
				MsgStop(STR0017) // "Garantia de bateria deve possuir pelo menos uma bateria"
				lRet := .f.
			EndIf
			If nHoraBat > (nQtdeBat * 0.5)
				MsgStop(STR0018) // "Quantidade de horas maior do que o permitido para garantia de bateria"
				lRet := .f.
			EndIf
		EndIf



	EndIf

	If lRet
		OFNJD15SI() // Levanta/Atribui sequencia dos itens das garantias
	EndIf
EndIf
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥OFNJD15GRV ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gravar - Garantia JD - VMB e VMC                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15GRV(nOpc)

Local i := 0
Local nAuxTotal := 0

//Local cTipVeiTURF // Tipo de Veiculos - TURF
//Local cTipVeiGOLF // Tipo de Veiculos - GOLF
//Local cAuxDealer
//Local cAuxTipVei

If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar

	BEGIN TRANSACTION
	//
	DbSelectArea("VMB")
	RecLock("VMB",IIf(Inclui,.t.,.f.))
	FG_GRAVAR("VMB")
	If Inclui

		Pergunte("OFINJD15",.f.,,,,.f.)

		VMB->VMB_FILIAL := xFilial("VMB")
//		Rubens - 22/05/2017
//		Tratamento de Codigo de Dealer para equipamentos de TURF e GOLF retirado conforme email enviado pela
//		John Deere (Daniele Martinatti) no dia 18/05/2017
//
//		Pergunte("OFINJD15",.f.,,,,.f.)
//
//		cAuxDealer := GetMV("MV_MIL0005")
//
//		cTipVeiTURF := AllTrim(MV_PAR36) // Tipo de Veiculos - TURF
//		cTipVeiGOLF := AllTrim(MV_PAR37) // Tipo de Veiculos - GOLF
//
//		// Verifica se È TURF ou GOLF
//		cSQL := "SELECT VV2_TIPVEI "
//		cSQL += " FROM " + RetSQLName("VV1") + " VV1 "
//		cSQL += " JOIN " + RetSQLName("VV2") + " VV2 ON VV2_FILIAL = '" + xFilial("VV2") + "' "
//		cSQL +=  " AND VV2_CODMAR = VV1_CODMAR "
//		cSQL +=  " AND VV2_MODVEI = VV1_MODVEI "
//		cSQL +=  " AND VV2.D_E_L_E_T_ = ' '"
//		cSQL += " WHERE VV1_FILIAL = '" + xFilial("VV1") + "' "
//		cSQL +=   " AND VV1_CHASSI = '" + M->VMB_CHASSI + "' "
//		cSQL +=   " AND VV1.D_E_L_E_T_ = ' '"
//		cAuxTipVei := FM_SQL(cSQL)
//		Do Case
//		Case cAuxTipVei $ cTipVeiTURF
//			VMB->VMB_DEALER := Stuff(cAuxDealer,3,1,"T")
//		Case cAuxTipVei $ cTipVeiGOLF
//			VMB->VMB_DEALER := Stuff(cAuxDealer,3,1,"G")
//		EndCase
//		//

		ConfirmSX8()
	EndIf
	MSMM(VMB->VMB_ESPMEM,TamSx3("VMB_ESPOBS")[1],,M->VMB_ESPOBS,1,,,"VMB","VMB_ESPMEM")
	MSMM(VMB->VMB_CAUMEM,TamSx3("VMB_CAUOBS")[1],,M->VMB_CAUOBS,1,,,"VMB","VMB_CAUMEM")
	MSMM(VMB->VMB_QUEMEM,TamSx3("VMB_QUEOBS")[1],,M->VMB_QUEOBS,1,,,"VMB","VMB_QUEMEM")
	MSMM(VMB->VMB_CORMEM,TamSx3("VMB_COROBS")[1],,M->VMB_COROBS,1,,,"VMB","VMB_CORMEM")
	MsUnlock()
	//
	OFNJD15SI() // Levanta/Atribui sequencia dos itens das garantias
	//
	DbSelectArea("VMC")

	VMC->(DbSetOrder(1))
	For i := 1 to Len(oAuxGetDados:aCols)
		dbSeek(xFilial("VMC")+VMB->VMB_CODGAR+oAuxGetDados:aCols[i,FG_POSVAR("VMC_SEQGAR","aHeader")])
		If oAuxGetDados:aCols[i,Len(oAuxGetDados:aCols[i])]
			RecLock("VMC",.f.,.t.)
			DbDelete()
			MsUnlock()
		Else
			RecLock("VMC",!Found())
			FG_GRAVAR("VMC",oAuxGetDados:aCols,aHeader,i)
			VMC->VMC_FILIAL := xFilial("VMC")
			VMC->VMC_CODGAR := VMB->VMB_CODGAR
			If !Found() .and. Empty(VMC->VMC_SEQGAR)
				VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
			EndIf
			MsUnlock()

			Do Case
			Case VMC->VMC_TIPOPS == "P"
				nAuxTotal += VMC->VMC_VTPECE
			Case VMC->VMC_TIPOPS == "S"
				nAuxTotal += VMC->VMC_VTSERE
			Case VMC->VMC_TIPOPS == "O"
				nAuxTotal += VMC->VMC_CUSMAT
			EndCase
		EndIf
	Next
	//

	RecLock("VMB",.f.)
	VMB->VMB_TOTALG := nAuxTotal
	VMB->(MsUnlock())

	END TRANSACTION

ElseIf nOpc == 5 // Excluir
	//
	DbSelectArea("VMC")
	VMC->(DbSetOrder(1))
	DbSeek(xFilial("VMC")+VMB->VMB_CODGAR)
	While !eof() .and. xFilial("VMC")+VMB->VMB_CODGAR == VMC->VMC_FILIAL+VMC->VMC_CODGAR
		RecLock("VMC",.f.,.t.)
		DbDelete()
		MsUnlock()
		DbSkip()
	EndDo
	DbSelectArea("VMB")
	RecLock("VMB",.f.,.t.)
	DbDelete()
	MsUnlock()

	//
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15CL ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Clona registro para retransmissao                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15CL(cAlias,nReg,nOpc)

Local cAliasEnchoice := "VMB"
Local cAliasGetD     := "VMC"
Local cLinOk         := "AllwaysTrue()"
Local cTudOk         := "AllwaysTrue()"
Local cFieldOk       := "AllwaysTrue()"

Local cAuxMsg := ""
Local aPeca
Local aSrvc
Local nPos

Private aCpoEnchoice := {}
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg

If !(VMB->VMB_STATUS $ "04/05/07/15")
	MsgInfo(STR0019) // "SÛ È permitido clonar solicitaÁ„o de garantia quando o status for Deletado, Rejeitado ou Debitado"
	Return
EndIf

If !OFNJD15007_VerificaLibVOO( "CL" , VMB->VMB_NUMOSV , VMB->VMB_CODGAR)
	Return
EndIf

aPeca := FMX_CALPEC(;
	VMB->VMB_NUMOSV,;              // cNumOS
	,;                             // cTipTem
	,;                             // cGruIte
	,;                             // cCodIte
	.f.,;                          // lMov
	.f.,;                          // lNegoc
	.t.,;                          // lReqZerada - Remove itens com qtde zerada
	.t.,;                          // lRetAbe
	.f.,;                          // lRetLib
	.f.,;                          // lRetFec
	.f.,;                          // lRetCan
	,;                             // cLibVOO
	" VOI_SITTPO IN ('2','4') ",;  // cFiltroSQL
	.f.,;                          // lRetRem
	.f.)                           // lAgrInc
For nPos := 1 to Len(aPeca)
	If ! aPeca[nPos , PECA_TIPTEM] $ cAuxMsg
		cAuxMsg += aPeca[nPos , PECA_TIPTEM] + " / "
	EndIf
Next nPos 

aSrvc := FMX_CALSER(;
	VMB->VMB_NUMOSV,;            // cNumOS
	,;                           // cTipTem
	,;                           // cGruSer
	,;                           // cCodSer
	.f.,;                        // lApont
	.f.,;                        // lNegoc
	.t.,;                        // lRetAbe
	.f.,;                        // lRetLib
	.f.,;                        // lRetFec
	.f.,;                        // lRetCan
	,;                           // cLibVOO
	" VOI_SITTPO IN ('2','4') ") // cFiltroSQL
For nPos := 1 to Len(aSrvc)
	If ! aSrvc[nPos , SRVC_TIPTEM] $ cAuxMsg
		cAuxMsg += aSrvc[nPos , SRVC_TIPTEM] + " / "
	EndIf
Next nPos 

If Len(aPeca) <> 0 .or. Len(aSrvc) <> 0
	cAuxMsg := STR0233 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Left(cAuxMsg, Len(cAuxMsg) - 3 ) //"N„o È possÌvel clonar solicitaÁ„o de garantia. Existem peÁas e/ou serviÁos requisitados com tipo de tempo de garantia e com status aberto. Tipo de tempo:"

	FMX_HELP("NJD15CLONE", cAuxMsg, STR0234 ) // "Ser· necess·rio liberar os tipos de tesmpos de garantias da ordem de serviÁo."
	FWFreeArray(aPeca)
	FWFreeArray(aSrvc)

	Return .f.
EndIf


If !MsgNoYes(STR0020) // "Confirma a clonagem do registro atual"
	Return
EndIf

cTipoGar := VMB->VMB_TIPGAR

// Altera o nOPC para carregar as informaÁıes do registro atual
nOpc := 2

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
nOpcE     := nOpc
nOpcG     := nOpc
/////////////////////////////////////////

RegToMemory("VMB" , .f. , .t. , .t. )
RegToMemory("VMC" , .f. )

cAuxNView := "VMB_FILIAL/"

aHeader := {}
aCols   := {}

FM_Mod3("",cAliasEnchoice,cAliasGetD,@aCpoEnchoice,,@aHeader,@aCols,cFieldOk,cLinOk,cTudOk,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,;
	cAuxNView,"VMC_CODGAR/",;
	1 /* nOrdGet2 */ ,;
	"VMC->VMC_FILIAL+VMC->VMC_CODGAR" /* cChvGet2 */ ,;
	xFilial("VMC") + VMB->VMB_CODGAR  /* cVlChvGet2 */ ;
	,,,,,, .t. )

oAuxGetDados := GetDVMC():Create()
oAuxGetDados:aHeader := aClone(aHeader)
oAuxGetDados:aCols := aClone(aCols)

// Altera o nOPC para "simular" uma nova inclusao
nOpc := 3

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
nOpcE     := nOpc
nOpcG     := nOpc
/////////////////////////////////////////

M->VMB_CODGAR := CriaVar("VMB_CODGAR")
M->VMB_REPARO := OFNJD15RP(M->VMB_NUMOSV)

M->VMB_NREFE2 := CriaVar("VMB_NREFE2")
M->VMB_CRMEMO := CriaVar("VMB_CRMEMO")
M->VMB_STATUS := CriaVar("VMB_STATUS")
M->VMB_CLAIM  := CriaVar("VMB_CLAIM ")
M->VMB_MEMTYP := CriaVar("VMB_MEMTYP")
M->VMB_STATSG := CriaVar("VMB_STATSG")
M->VMB_DTENVI := CriaVar("VMB_DTENVI")
M->VMB_DTRETO := CriaVar("VMB_DTRETO")
M->VMB_DTATUA := CriaVar("VMB_DTATUA")
M->VMB_NROAUT := CriaVar("VMB_NROAUT")
M->VMB_WARRME := CriaVar("VMB_WARRME")
M->VMB_SRVSNF := CriaVar("VMB_SRVSNF")
M->VMB_SRVNNF := CriaVar("VMB_SRVNNF")

M->VMB_QUEMEM := Space(TamSX3("VMB_QUEMEM")[1]) // Limpa Conteudo para gravar em um novo registro do SYP
M->VMB_CAUMEM := Space(TamSX3("VMB_CAUMEM")[1]) // Limpa Conteudo para gravar em um novo registro do SYP
M->VMB_CORMEM := Space(TamSX3("VMB_CORMEM")[1]) // Limpa Conteudo para gravar em um novo registro do SYP
M->VMB_WARMEM := Space(TamSX3("VMB_WARMEM")[1]) // Limpa Conteudo para gravar em um novo registro do SYP

OFNJD15GRV(nOpc)

MsgInfo(STR0148 + chr(13) + chr(10) + chr(13) + chr(10) +; // Registro clonado
		AllTrim(RetTitle("VMB_CODGAR")) + ": " + M->VMB_CODGAR )

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15VLD∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao dos campos da Enchoice                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15VLD(cReadVar)

Local lRetorno := .t.
Local cTabela
Local lAtuTotal := .f.
Local aAuxPeca

Default cReadVar := ReadVar()

cReadVar := AllTrim(cReadVar)

//If cReadVar == "M->VMB_APLICA"
//	If !Empty(M->VMB_APLICA)
//		cTabela := IIF(M->VMB_TIPGAR="ZZBT","008","009")
//		lRetorno := FG_Seek("VX5","'" + cTabela + "' + M->VMB_APLICA",1,.F.,"M->VMB_APLICD","VX5_DESCRI")
//	EndIf
//EndIf

If cReadVar == "M->VMB_NUMOSV"
	VO1->(dbSetOrder(1))
	If !VO1->(MsSeek(xFilial("VO1") + M->VMB_NUMOSV))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VO1_NUMOSV")) + ": " + M->VMB_NUMOSV,4,1)
		Return .f.
	EndIf
	M->VMB_CHASSI := VO1->VO1_CHASSI
	M->VMB_CHAINT := VO1->VO1_CHAINT
	//M->VMB_QTDUTI := PadR(AllTrim(Str(VO1->VO1_KILOME)),TamSX3("VMB_QTDUTI")[1])
	M->VMB_QTDUTI := VO1->VO1_KILOME
EndIf

If cReadVar == "M->VMB_CHASSI"
	If !Empty(M->VMB_CHASSI)
		VV1->(dbSetOrder(2))
		If VV1->(dbSeek(xFilial("VV1")+M->VMB_CHASSI))
			M->VMB_CHAINT := VV1->VV1_CHAINT
		Else
			M->VMB_CHAINT := Space(TamSX3("VV1_CHAINT")[1])
		EndIf
	Else
		M->VMB_CHAINT := Space(TamSX3("VV1_CHAINT")[1])
	EndIf
EndIf

If cReadVar == "M->VMB_CHAINT"
	If !Empty(M->VMB_CHAINT)
		VV1->(dbSetOrder(1))
		If VV1->(dbSeek(xFilial("VV1")+M->VMB_CHAINT))
			M->VMB_CHASSI := VV1->VV1_CHASSI
		Else
			M->VMB_CHASSI := Space(TamSX3("VV1_CHASSI")[1])
		EndIf
	Else
		M->VMB_CHASSI := Space(TamSX3("VV1_CHASSI")[1])
	EndIf
EndIf

If cReadVar == "M->VMB_INSPOR"
	If Empty(M->VMB_INSPOR)
		Return .t.
	EndIf
	If M->VMB_TIPGAR == "ZPAR"
		If !(M->VMB_INSPOR $ "CD")
			MsgAlert(STR0021) // "Para garantia de peÁas utilize as opÁıes C ou D"
			Return .f.
		EndIf
	Else
		If !(M->VMB_INSPOR $ "FR")
			MsgAlert(STR0022) // "Para garantia de bateria/esteira utilize as opÁıes F ou R"
			Return .f.
		EndIf
	EndIf

	If M->VMB_INSPOR <> "C" .and. !Empty(M->VMB_NFANTE)
		M->VMB_SRANTE := Space(TamSX3("VMB_SRANTE")[1])
		M->VMB_NFANTE := Space(TamSX3("VMB_NFANTE")[1])
	EndIf
	If !(M->VMB_INSPOR $ "D/R") .and. !Empty(M->VMB_OSANTE)
		M->VMB_OSANTE := Space(TamSX3("VMB_OSANTE")[1])
	EndIf
EndIf

If cReadVar == "M->VMB_FALHA"
	If !Empty(M->VMB_FALHA)

		Do Case
		Case M->VMB_TIPGAR == "ZZBT"
			cTabela := "024"
		Otherwise
			cTabela := "011"
		EndCase

		DbSelectArea("VX5")
		lRetorno := FG_Seek("VX5","'" + cTabela + "'+M->VMB_FALHA",1,.F.,"M->VMB_FALHAD","VX5_DESCRI")
	Else
		M->VMB_FALHAD := ""
	EndIf
EndIf

If cReadVar == "M->VMB_GRUITE"
	M->VMB_CODITE := Space(TamSX3("VMB_CODITE")[1])
	M->VMB_KEYPAR := Space(TamSX3("VMB_KEYPAR")[1])
	If !ExistCPO("SBM",M->VMB_GRUITE)
		lRetorno := .f.
	EndIf
	cGruIte := M->VMB_GRUITE
EndIf

If cReadVar == "M->VMB_CODITE" .and. !Empty(M->VMB_CODITE)
	// Nao valida para Campanha, pois quando for campanha a peca chave deve ser o numero do PIP
	If M->VMB_TIPGAR <> "ZPIP"
		SB1->(dbSetOrder(7))
		lRetorno := (SB1->(dbSeek(xFilial("SB1") + M->VMB_GRUITE + M->VMB_CODITE)))
		If lRetorno
			M->VMB_KEYPAR := IIf(lB1CODFAB .and. !Empty(SB1->B1_CODFAB),SB1->B1_CODFAB,SB1->B1_CODITE)
		EndIf
//		lRetorno := !ExistCPO("SB1",M->VMB_GRUITE + M->VMB_CODITE,7)
	EndIf
Endif

If cReadVar == "M->VMB_OSANTE"
	//
	If !Empty(M->VMB_CHASSI)
		cSQL := "SELECT VO1_CHASSI FROM " + RetSQLName("VO1") + " WHERE VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1_NUMOSV = '" + M->VMB_OSANTE + "' AND D_E_L_E_T_ = ' '"
		If M->VMB_CHASSI <> FM_SQL( cSQL )
			MsgAlert(STR0023) // "N˙mero de sÈrie informado na OS anterior È diferente do n˙mero de sÈrie informado nesta SolicitaÁ„o de Garantia"
		EndIf
	EndIf
	//
	If !Empty(M->VMB_GRUITE) .and. !Empty(M->VMB_CODITE)
		aAuxPeca := FMX_CALPEC(VO1->VO1_NUMOSV , , M->VMB_GRUITE , M->VMB_CODITE , .F. , .F. , .F. , .T. , .T. , .T. , .F. )
		If Len(aAuxPeca) == 0
			MsgAlert(STR0024) // "N„o foi encontrada a peÁa causadora na Ordem de ServiÁo informada"
		EndIf
	EndIf
	//
EndIf

If cReadVar == "M->VMB_SRANTE"
	M->VMB_NFANTE := Space(TamSX3("VMB_NFANTE")[1])
EndIf

If cReadVar == "M->VMB_NFANTE"
	If !Empty(M->VMB_GRUITE) .and. !Empty(M->VMB_CODITE)
		cSQL := "SELECT D2_DOC "
		cSQL += " FROM " + RetSQLName("SD2") + " D2"
		cSQL +=        " JOIN " + RetSQLname("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = D2.D2_COD AND B1.D_E_L_E_T_ = ' '"
		cSQL += " WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cSQL +=   " AND D2.D2_SERIE = '" + M->VMB_SRANTE + "'"
		cSQL +=   " AND D2.D2_DOC = '" + M->VMB_NFANTE + "'"
		cSQL +=   " AND D2.D_E_L_E_T_ = ' '"
		cSQL +=   " AND B1.B1_GRUPO = '" + M->VMB_GRUITE + "'"
		cSQL +=   " AND B1.B1_CODITE = '" + M->VMB_CODITE + "'"
		If Empty(FM_SQL(cSQL))
			MsgAlert(STR0025) // "N„o foi encontrada a peÁa causadora na Nota Fiscal informada."
		EndIf
	EndIf
EndIf

// Garantia Especial - Parte do Cliente (R$)
If cReadVar == "M->VMB_CLIVAL"
	lAtuTotal := .t.
	M->VMB_CLIPER := Round( M->VMB_CLIVAL / M->VMB_TOTALG * 100 , 2 )
EndIf
// Garantia Especial - Parte do Cliente (%)
If cReadVar == "M->VMB_CLIPER"
	lAtuTotal := .t.
	M->VMB_CLIVAL := Round( M->VMB_TOTALG * ( M->VMB_CLIPER / 100 ) , 2 )
EndIf

// Garantia Especial - Parte do Concessionario (R$)
If cReadVar == "M->VMB_CONVAL"
	lAtuTotal := .t.
	M->VMB_CONPER := Round( M->VMB_CONVAL / M->VMB_TOTALG * 100 , 2 )
EndIf
// Garantia Especial - Parte do Concessionario (%)
If cReadVar == "M->VMB_CONPER"
	lAtuTotal := .t.
	M->VMB_CONVAL := Round( M->VMB_TOTALG * ( M->VMB_CONPER / 100 ) , 2 )
EndIf

// Garantia Especial - Parte da John Deere (R$)
If cReadVar == "M->VMB_JDVAL"
	lAtuTotal := .t.
	M->VMB_JDPER := Round( M->VMB_JDVAL / M->VMB_TOTALG * 100 , 2 )
EndIf
// Garantia Especial - Parte da John Deere (%)
If cReadVar == "M->VMB_JDPER"
	lAtuTotal := .t.
	M->VMB_JDVAL := Round( M->VMB_TOTALG * ( M->VMB_JDPER / 100 ), 2 )
EndIf

If lAtuTotal
	M->VMB_TOTALD := M->VMB_CLIVAL + M->VMB_CONVAL + M->VMB_JDVAL

	If M->VMB_TOTALD <> M->VMB_TOTALG
		// ???
	EndIf

EndIf

Return lRetorno






/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15VLG∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao dos campos da GetDados                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15VLG(cReadVar)

Local lRetorno := .t.

Default cReadVar := ReadVar()

If cReadVar == "M->VMC_GRUITE"
	If !Empty(M->VMC_GRUITE)
		lRetorno := ExistCPO("SBM",M->VMC_GRUITE)
	EndIf
	If Empty(M->VMC_GRUITE) .or. lRetorno
		M->VMC_CODITE := Space(TamSX3("VMC_CODITE")[1])
		M->VMC_DESCRI := Space(TamSX3("VMC_DESCRI")[1])
		M->VMC_PARTNO := Space(TamSX3("VMC_PARTNO")[1])
		If !lIJD01Auto
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_CODITE","aHeader")] := M->VMC_CODITE
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_DESCRI","aHeader")] := M->VMC_DESCRI
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_PARTNO","aHeader")] := M->VMC_PARTNO
		EndIf
	EndIf
EndIf
If cReadVar == "M->VMC_CODITE"
	If Empty(M->VMC_CODITE)
		M->VMC_DESCRI := Space(TamSX3("VMC_DESCRI")[1])
		M->VMC_PARTNO := Space(TamSX3("VMC_PARTNO")[1])
		If !lIJD01Auto
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_DESCRI","aHeader")] := M->VMC_DESCRI
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_PARTNO","aHeader")] := M->VMC_PARTNO
		EndIf
	Else
		SB1->(dbSetOrder(7))
		lRetorno := SB1->(dbSeek(xFilial("SB1") + M->VMC_GRUITE + M->VMC_CODITE ))
		If lRetorno
			M->VMC_DESCRI := SB1->B1_DESC
			M->VMC_PARTNO := IIf(lB1CODFAB .and. !Empty(SB1->B1_CODFAB), SB1->B1_CODFAB , SB1->B1_CODITE )
			If !lIJD01Auto
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_DESCRI","aHeader")] := M->VMC_DESCRI
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_PARTNO","aHeader")] := M->VMC_PARTNO
			EndIf
		EndIf
	EndIf
EndIf
If cReadVar == "M->VMC_TIPTRA"
	If Empty(M->VMC_TIPTRA)
		M->VMC_TIPTRD := Space(TamSX3("VMC_TIPTRD")[1])
		If !lIJD01Auto
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_TIPTRD","aHeader")] := M->VMC_TIPTRD
		EndIf
	Else
		VX5->(dbSetOrder(1))
		lRetorno := VX5->(dbSeek(xFilial("VX5") + '017' + M->VMC_TIPTRA))
		If lRetorno
			M->VMC_TIPTRD := VX5->VX5_DESCRI
			If !lIJD01Auto
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_TIPTRD","aHeader")] := M->VMC_TIPTRD
			EndIf
		EndIf
	EndIf
EndIf
If cReadVar == "M->VMC_CODMAT"
	If Empty(M->VMC_CODMAT)
		M->VMC_CODMAD := Space(TamSX3("VMC_CODMAD")[1])
		If !lIJD01Auto
			oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_CODMAD","aHeader")] := M->VMC_CODMAD
		EndIf
	Else
		VX5->(dbSetOrder(1))
		lRetorno := VX5->(dbSeek(xFilial("VX5") + '022' + M->VMC_CODMAT))
		If lRetorno
			M->VMC_CODMAD := VX5->VX5_DESCRI
			If !lIJD01Auto
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VMC_CODMAD","aHeader")] := M->VMC_CODMAD
			EndIf
		EndIf
	EndIf
EndIf
Return lRetorno




/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15TR ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Transmite registro de solicitacao de garantia              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15TR(cAlias,nReg,nOpc)

Local oWS // Instancia da Classe de WebService da John Deere
Local nPos
Local lRetAlt
Local nPos2
Local lOutrosCreditos := .f.

VMC->(dbSetOrder(1))
VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR ))

If !Empty(VMB->VMB_STATUS)
	MsgInfo(STR0026) // "SolicitaÁ„o de garantia j· transmitida"
	Return
ElseIf !cMVGARJD_T
	// Antes de transmitir, atualiza o status, pois em alguns casos
	// o webservice retorna erro mas a solicitacao era gerada no portal ...
	OFNJD15AS(cAlias,nReg,nOpc,.f.,.f.,.f.)
	If !Empty(VMB->VMB_CLAIM)
		MsgInfo(STR0026) // "SolicitaÁ„o de garantia j· transmitida"
		Return
	EndIf
	//
EndIf


// Verifica se os itens da SolicitaÁ„o de Garantia ainda est„o na OS
If ! OFNJD15CHK(VMB->VMB_CODGAR)
	Return .f.
EndIf

// Antes da transmissao, abre a solicitacao em modo de alteracao ...
nOpcBkp := nOpc
nOpc := 4
lRetAlt := OFNJD15EXEC(cAlias,nReg,nOpc,.t.)
nOpc := nOpcBkp
If !lRetAlt
	Return .f.
EndIf
//

If ! OFNJD15CG(AllTrim(VMB->VMB_CHASSI),VMB->VMB_DTFALH,VMB->VMB_QTDUTI,VMB->VMB_UNIMED, VMB->VMB_TIPGAR , VMB->VMB_CODSTA)
	If ! cMVGARJD_T
		Return
	EndIf
EndIf

If !MsgYesNo(STR0029) // "Confirma transmissao"
	Return
EndIf

VMB->(dbGoTo(nReg))

// Consulta Informacoes de Garantia do Chassi no WebService da John Deere
oWS := WSJohnDeere_Garantia():New("SaveClaim")

/*
If VMB->(ColumnPos("VMB_SNDGAR")) == 0
	oWS:SetDebug()
EndIf
*/

oWS:oSaveClaim_INPUT:oINPUT:cCLAIMTYPE           := AllTrim(VMB->VMB_TIPGAR)
oWS:oSaveClaim_INPUT:oINPUT:cDEALERACCOUNT       := AllTrim(VMB->VMB_DEALER)
oWS:oSaveClaim_INPUT:oINPUT:cSUBCLAIMTYPE        := AllTrim(VMB->VMB_SUBGAR)
//oWS:oSaveClaim_INPUT:oINPUT:cLIFETIME            := AllTrim(VMB->VMB_)
oWS:oSaveClaim_INPUT:oINPUT:cWO                  := AllTrim(VMB->VMB_NUMOSV)
oWS:oSaveClaim_INPUT:oINPUT:cSEG                 := AllTrim(VMB->VMB_REPARO)
oWS:oSaveClaim_INPUT:oINPUT:cAPPLICATION         := AllTrim(VMB->VMB_APLICA)
//oWS:oSaveClaim_INPUT:oINPUT:cAUTHORIZATIONNO     := AllTrim(VMB->VMB_)
oWS:oSaveClaim_INPUT:oINPUT:cINSTALLEDBY         := AllTrim(VMB->VMB_INSPOR)

If Empty(VMB->VMB_CHASSI)
	oWS:oSaveClaim_INPUT:oINPUT:cMODEL               := AllTrim(VMB->VMB_MODELO)
	oWS:oSaveClaim_INPUT:oINPUT:cMODELSERIALNO       := AllTrim(VMB->VMB_SERMOD)
EndIf
oWS:oSaveClaim_INPUT:oINPUT:cPIPNO               := AllTrim(VMB->VMB_NROPIP)
oWS:oSaveClaim_INPUT:oINPUT:cINSTALLDATE         := DtoS(VMB->VMB_INSDAT)
oWS:oSaveClaim_INPUT:oINPUT:cAMTUSE              := AllTrim(Str(VMB->VMB_QTDUTI,22))
oWS:oSaveClaim_INPUT:oINPUT:cUSEINDICATOR        := AllTrim(VMB->VMB_UNIMED)
oWS:oSaveClaim_INPUT:oINPUT:cFAILUREDATE         := DtoS(VMB->VMB_DTFALH)
oWS:oSaveClaim_INPUT:oINPUT:cDLRCLAIMNO          := AllTrim(VMB->VMB_NREFE2)
oWS:oSaveClaim_INPUT:oINPUT:cOWNERSTATCD         := AllTrim(VMB->VMB_CODSTA)
//oWS:oSaveClaim_INPUT:oINPUT:cKEYPARTNO           := AllTrim(VMB->VMB_CODITE)
oWS:oSaveClaim_INPUT:oINPUT:cKEYPARTNO           := AllTrim(VMB->VMB_KEYPAR)
oWS:oSaveClaim_INPUT:oINPUT:cMAINTPLAN           := AllTrim(VMB->VMB_PLAMAN)
oWS:oSaveClaim_INPUT:oINPUT:cSERVINTTYPE         := AllTrim(VMB->VMB_INTSRV)
If VMB->VMB_USOPEC <> 0
	oWS:oSaveClaim_INPUT:oINPUT:cPARTSUSE            := AllTrim(Str(VMB->VMB_USOPEC,10,0))
EndIf
oWS:oSaveClaim_INPUT:oINPUT:cPARTSUSEIND         := AllTrim(VMB->VMB_UNUSPC)
//oWS:oSaveClaim_INPUT:oINPUT:cPONUMB              := AllTrim(VMB->VMB_)
//oWS:oSaveClaim_INPUT:oINPUT:cREFNO3              := AllTrim(VMB->VMB_)
//oWS:oSaveClaim_INPUT:oINPUT:cRETAILNAME          := AllTrim(VMB->VMB_)
//oWS:oSaveClaim_INPUT:oINPUT:cSTORENO             := AllTrim(VMB->VMB_)
oWS:oSaveClaim_INPUT:oINPUT:cTESTRESULT          := AllTrim(VMB->VMB_TESRES)
oWS:oSaveClaim_INPUT:oINPUT:cFAILURETYPE         := AllTrim(VMB->VMB_FALHA)
oWS:oSaveClaim_INPUT:oINPUT:cFAILURETYPECOMMENTS := AllTrim(VMB->VMB_FALCOM)
If VMB->VMB_ALTMED <> 0
	oWS:oSaveClaim_INPUT:oINPUT:cLUGHT               := AllTrim(Str(VMB->VMB_ALTMED,10,0))
EndIf
oWS:oSaveClaim_INPUT:oINPUT:cLUGHTUSEIND         := AllTrim(VMB->VMB_UNIALT)
oWS:oSaveClaim_INPUT:oINPUT:cFAILUREAREA         := AllTrim(VMB->VMB_FALARE)
oWS:oSaveClaim_INPUT:oINPUT:cDOWNTIMEIND         := AllTrim(VMB->VMB_MAQPAR)
oWS:oSaveClaim_INPUT:oINPUT:cDTACCASE            := AllTrim(VMB->VMB_DTACCS)
oWS:oSaveClaim_INPUT:oINPUT:cDTACSOL             := AllTrim(VMB->VMB_DTACSL)
oWS:oSaveClaim_INPUT:oINPUT:cCOMPSERNO           := AllTrim(VMB->VMB_SERCOM)
If VMB->VMB_INSPOR $ "C/R"
	oWS:oSaveClaim_INPUT:oINPUT:cINVOICENO           := AllTrim(VMB->VMB_NFANTE)
Else
	oWS:oSaveClaim_INPUT:oINPUT:cINVOICENO           := AllTrim(VMB->VMB_OSANTE)
EndIf
oWS:oSaveClaim_INPUT:oINPUT:cREPAIRDATE          := DtoS(VMB->VMB_DATMAN)
If VMB->VMB_TIPGAR == "ZSPA"
	oWS:oSaveClaim_INPUT:oINPUT:cPOLICY          := AllTrim(VMB->VMB_TIPESP)
	oWS:oSaveClaim_INPUT:oINPUT:nCUSTAMT         := VMB->VMB_CLIVAL
	oWS:oSaveClaim_INPUT:oINPUT:nDLRAMT          := VMB->VMB_CONVAL
	oWS:oSaveClaim_INPUT:oINPUT:nCOAMT           := VMB->VMB_JDVAL
EndIf
If VMB->VMB_TIPGAR $ "ZSPA/ZPIP/ZPAR/ZNRM/ZZBT"
	oWS:oSaveClaim_INPUT:oINPUT:cBASISFORSETTLEMENT  := AllTrim(E_MSMM(VMB->VMB_ESPMEM,100000))
EndIf
oWS:oSaveClaim_INPUT:oINPUT:cCAUSE               := AllTrim(E_MSMM(VMB->VMB_CAUMEM,100000))
oWS:oSaveClaim_INPUT:oINPUT:cCOMPLAINT           := AllTrim(E_MSMM(VMB->VMB_QUEMEM,100000))
oWS:oSaveClaim_INPUT:oINPUT:cCORRECTION          := AllTrim(E_MSMM(VMB->VMB_CORMEM,100000))
oWS:oSaveClaim_INPUT:oINPUT:cNOTRAVEL            := IIf(VMB->VMB_NOTRAV == "0" , "X" , "" )
oWS:oSaveClaim_INPUT:oINPUT:cMACHINETYPE         := AllTrim(VMB->VMB_TIPMAQ)
//oWS:oSaveClaim_INPUT:oINPUT:cGOODSINSTALLATION   := AllTrim(VMB->VMB_BOAINS)

If !Empty(VMB->VMB_CHASSI)
	oWS:oSaveClaim_INPUT:AddPins()
	oWS:oSaveClaim_INPUT:oPins[1]:cPin := AllTrim(VMB->VMB_CHASSI)
EndIf

VMC->(dbSetOrder(1))
VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR ))

aServico := {}
lOutrosCreditos := .f.

While !VMC->(Eof()) .AND. VMC->VMC_FILIAL == xFilial("VMC") .AND. VMC->VMC_CODGAR == VMB->VMB_CODGAR

	Do Case
	// Servico
	Case VMC->VMC_TIPOPS == "S"

		nPos := aScan( aServico , { |x| x[1] == AllTrim(VMC->VMC_TIPTRA) .and. x[2] == AllTrim(VMC->VMC_LOCTRA) .and. x[4] == VMC->VMC_ORIGEM } )
		If nPos == 0
			AADD( aServico , { AllTrim(VMC->VMC_TIPTRA) , AllTrim(VMC->VMC_LOCTRA) , 0 , VMC->VMC_ORIGEM } )
			nPos := Len(aServico)
		EndIf
		aServico[nPos,3] += VMC->VMC_QTDTRA

	Case VMC->VMC_TIPOPS == "P"

		oWS:oSaveClaim_INPUT:AddReplacePart()
		nPos := Len(oWS:oSaveClaim_INPUT:oREPLACEPART)

//		oWS:oSaveClaim_INPUT:oREPLACEPART[nPos]:cPARTNO  := AllTrim(VMC->VMC_CODITE)
		oWS:oSaveClaim_INPUT:oREPLACEPART[nPos]:cPARTNO  := AllTrim(VMC->VMC_PARTNO)
//		oWS:oSaveClaim_INPUT:oREPLACEPART[nPos]:cALT_UOM := AllTrim(VMC->VMC_MEDALT)
		If AllTrim(VMC->VMC_UM) == "L"
			oWS:oSaveClaim_INPUT:oREPLACEPART[nPos]:cALT_UOM := AllTrim(VMC->VMC_UM)
		EndIf
		oWS:oSaveClaim_INPUT:oREPLACEPART[nPos]:nQTY     := VMC->VMC_QTDPEC
		oWS:oSaveClaim_INPUT:oREPLACEPART[nPos]:cRPSERNO := AllTrim(VMC->VMC_SERINO)

	Case VMC->VMC_TIPOPS == "O"

		lOutrosCreditos := .t.
		oWS:oSaveClaim_INPUT:AddOtherCredit()
		nPos := Len(oWS:oSaveClaim_INPUT:oOTHERCREDIT)

		oWS:oSaveClaim_INPUT:oOTHERCREDIT[nPos]:cDESC          := AllTrim(VMC->VMC_CODMAT)
		oWS:oSaveClaim_INPUT:oOTHERCREDIT[nPos]:nLABOR_MATCOST := VMC->VMC_CUSMAT
		oWS:oSaveClaim_INPUT:oOTHERCREDIT[nPos]:cLABOR_COMMENT := AllTrim(VMC->VMC_COMENT)

	EndCase

	VMC->(dbSkip())
EndDo

For nPos2 := 1 to Len(aServico)
	oWS:oSaveClaim_INPUT:AddLabor()
	nPos := Len(oWS:oSaveClaim_INPUT:oLABOR)

	oWS:oSaveClaim_INPUT:oLABOR[nPos]:cTYPE    := aServico[nPos2,1]
	//oWS:oLABOR[1]:cSPGFR   := VMC->VMC_SPGKEY
	oWS:oSaveClaim_INPUT:oLABOR[nPos]:cSUBTYPE := aServico[nPos2,2]
	//oWS:oSaveClaim_INPUT:oLABOR[nPos]:cTECHID  := AllTrim(VMC->VMC_TECHID)
	oWS:oSaveClaim_INPUT:oLABOR[nPos]:nAMT     := aServico[nPos2,3]
Next nPos2

lProcessado:= .f.
MsgRun(STR0030,STR0031,{|| lProcessado := oWS:SaveClaim() }) // "Transmitindo SolicitaÁ„o de Garantia"
If !lProcessado
	oWS:ExibeErro("SaveClaim")
	Return
EndIf

If oWS:oOUTPUT:oSUCCESS:cTYPE $ "E/X"
	MsgInfo(STR0035 + oWS:oOUTPUT:oSUCCESS:cTYPE + " - " + oWS:oOUTPUT:oSUCCESS:cRESDESC ) // "Erro: "
	Return
EndIf

If !oWS:oOUTPUT:oSUCCESS:cTYPE $ "S"
	MsgInfo(STR0032 + chr(13) + chr(10) + Chr(13) + chr(10) + oWS:oOUTPUT:oSUCCESS:cTYPE + " - " + oWS:oOUTPUT:oSUCCESS:cRESDESC )
EndIf

If VMB->(ColumnPos("VMB_SNDGAR")) <> 0
	dbSelectArea("VMB")
	RecLock("VMB",.f.)
	VMB->VMB_SNDGAR := oWS:cXMLSaveClaim
	VMB->(MsUnlock())
EndIf
oWS := NIL

If cMVGARJD_T
	MsgInfo(STR0149) // "Sistema configurado para simulaÁ„o, n„o È possÌvel transmitir a SolicitaÁ„o de Garantia"
	OFNJD15AS(cAlias,nReg,nOpc,.f.,.f.,.f.)
Else
	// Atualiza o status da SG
	OFNJD15AS(cAlias,nReg,nOpc,,.f.)
	//
EndIf

If lOutrosCreditos
	MsgAlert(STR0033) // "SolicitaÁ„o possui outros crÈditos. N„o esqueÁa de enviar copia da nota fiscal atravÈs do portal"
EndIf

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15AS ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Atualiza status da solicitacao de garantia                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15AS(cAlias,nReg,nOpc,lExibeMsg,lSetDebug,lMsgWS,lSchedule)

Local oWS // Instancia da Classe de WebService da John Deere

Local nCont
Local lJaProc := .f.

Default lExibeMsg := .t.
Default lSetDebug := .t.
Default lMsgWS := .t.
Default lSchedule := .f.

// Consulta Informacoes de Garantia do Chassi no WebService da John Deere
oWS := WSJohnDeere_Garantia():New("RetrieveClaim")
//oWS:SetDebug(lSetDebug)
oWS:oRetrieveClaim_INPUT:cDEALERACCOUNT := AllTrim(VMB->VMB_DEALER)
oWS:oRetrieveClaim_INPUT:cWO  := AllTrim(VMB->VMB_NUMOSV)
oWS:oRetrieveClaim_INPUT:cSEG := AllTrim(VMB->VMB_REPARO)
lProcessado:= .f.
If lSchedule
	lProcessado := oWS:RetrieveClaim()
Else
	MsgRun(STR0034,STR0031,{|| lProcessado := oWS:RetrieveClaim() }) // "Consultando SolicitaÁ„o de Garantia"
EndIf
If !lProcessado
	If !lSchedule
		oWS:ExibeErro("RetrieveClaim")
	EndIf
	Return .f.
EndIf

If oWS:oOUTPUT:oSUCCESS:cTYPE $ "E/X" .and. lMsgWS
	If !lSchedule
		MsgInfo(STR0035 + oWS:oOUTPUT:oSUCCESS:cTYPE + " - " + oWS:oOUTPUT:oSUCCESS:cRESDESC ) // "Erro: "
	EndIf
	Return .f.
EndIf

If oWS:oOUTPUT:oSUCCESS:cTYPE == "S"

	// Se retornar mais de uma SG, verifica se existe alguma com status APROVADO (03) / AGUARDANDO NF (09) / NF ATUALIZADA (12)
	// por algum motivo, algumas SG's ficaram duplicadas no portal ...
	If Len(oWS:oOUTPUT:oCLAIM) > 1
		For nCont := 1 to Len(oWS:oOUTPUT:oCLAIM)
			If oWS:oOUTPUT:oCLAIM[nCont]:cSTATUS $ "03/09/12"
				OFNJD15GST(oWS:oOUTPUT:oCLAIM[nCont])
				lJaProc := .t.
				Exit
			EndIf
		Next nCont
	EndIf
	//

	If !lJaProc
		For nCont := 1 to Len(oWS:oOUTPUT:oCLAIM)
			OFNJD15GST(oWS:oOUTPUT:oCLAIM[nCont])
		Next nCont
	EndIf

	If lExibeMsg
		MsgInfo(STR0036) // "SolicitaÁ„o atualizada"
	EndIf
EndIf

oWS := NIL

Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15GST ∫ Autor ≥ Rubens             ∫ Data ≥ 15/01/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Grava campos de atualizacao de status                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15GST(oAuxClaim)

dbSelectArea("VMB")
Reclock("VMB",.f.)

VMB->VMB_CLAIM  := oAuxClaim:cSAPCLAIMNO
VMB->VMB_STATUS := IIf( cMVGARJD_T , OFNJD15017_StatusSimulacao("STATUS") , oAuxClaim:cSTATUS )
VMB->VMB_DTATUA := oAuxClaim:dMODIFYDATE
VMB->VMB_DTABER := oAuxClaim:dOPENDATE
VMB->VMB_DTENVI := oAuxClaim:dSUBDATE
VMB->VMB_DTRETO := oAuxClaim:dRETDATE
VMB->VMB_CRMEMO := IIf( cMVGARJD_T , OFNJD15017_StatusSimulacao("CRMEMO", oAuxClaim:cCRMEMO ) , oAuxClaim:cCRMEMO )
VMB->VMB_CLIVAR := oAuxClaim:nCUSTAMT
VMB->VMB_CONVAR := oAuxClaim:nDLRAMT
VMB->VMB_JDVAR  := oAuxClaim:nCOAMT
VMB->(MSUnlock())

Return

Static Function OFNJD15017_StatusSimulacao(cCampo, cCRMEMO )
	If Empty(VMB->VMB_MEMTYP)
		If cCampo == "STATUS"
			Return "02"
		Else
			Return " "
		EndIf
	ElseIf VMB->VMB_MEMTYP == "4"
		If cCampo == "STATUS"
			Return "09"
		Else
			Return " "
		EndIf
	ElseIf VMB->VMB_MEMTYP == "1"
		If cCampo == "STATUS"
			Return "03"
		Else
			Return cCRMEMO
		EndIf
	EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15NF ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Transmite informacao da nota fiscal de Servico             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15NF(cAlias,nReg,nOpc)

Local oWS // Instancia da Classe de WebService da John Deere
Local cAuxType
Local cAuxRESDESC
Local nAuxRESCODE

If cMVGARJD_T
	MsgInfo(STR0151) // Sistema configurado para simulaÁ„o, n„o È possÌvel transmitir a N˙mero de Nota Fiscal.
	Return .f.
EndIf

If OFNJD15SEMREEMBOLSO()
	MsgStop(STR0214 ,STR0111) // "SolicitaÁ„o de garantia sem reembolso. OpÁ„o n„o disponÌvel para este tipo de solicitaÁ„o de garantia."
	Return .f.
EndIf

If Empty(VMB->VMB_SRVNNF)
	MsgInfo(STR0037) // "Nota fiscal n„o gerada para essa solicitaÁ„o de garantia"
	Return .f.
EndIf

SF2->(dbSetOrder(1))
If !SF2->(dbSeek(xFilial("SF2") + VMB->VMB_SRVNNF + VMB->VMB_SRVSNF ))
	MsgInfo(STR0038) // "Nota fiscal n„o encontrada"
	Return .f.
EndIf

If !MsgYesNo(STR0039) // "Confirma transmissao"
	Return
EndIf

// Consulta Informacoes de Garantia do Chassi no WebService da John Deere
oWS := WSJohnDeere_Garantia():New("UpdateDealerInvoice")
//oWS:SetDebug()
oWS:oUpdateDealerInvoice_INPUT:cSAPCLAIMNO := AllTrim(VMB->VMB_CLAIM)
oWS:oUpdateDealerInvoice_INPUT:cDLRINVNO := VMB->VMB_SRVNNF
oWS:oUpdateDealerInvoice_INPUT:cDLRINVDT := DtoS(SF2->F2_EMISSAO)
lProcessado:= .f.
MsgRun(STR0040,STR0031,{|| lProcessado := oWS:UpdateDealerInvoice() }) // "Enviando dados de Nota Fiscal"
If !lProcessado
	oWS:ExibeErro("UpdateDealerInvoice")
	Return
EndIf

cAuxType := oWS:oOUTPUT:oSUCCESS:cTYPE
cAuxRESDESC := oWS:oOUTPUT:oSUCCESS:cRESDESC
nAuxRESCODE := oWS:oOUTPUT:oSUCCESS:nRESCODE

If cAuxType $ "E/X"
	// TEMPORARIO - 19/02/2020
	// Contorno para atualizar VMB para os casos em que a NF foi atualizada, mas o sistema caiu no momento do processamento 
	// do retorno do WS
	If cAuxType == "X" .and. nAuxRESCODE == 400316
		oWS := NIL
		// Atualiza o status da SG
		OFNJD15AS(cAlias,nReg,nOpc,,.f.)
		//
		If VMB->VMB_STATUS == "03" // NF Ja foi transmitida... caso o contrario o status estaria "09"
			// Atualiza S.G.
			dbSelectArea("VMB")
			RecLock("VMB",.f.)
			VMB->VMB_STATSG := "2"
			VMB->(MsUnLock())
			//
			Return
		EndIf
	EndIf
	MsgInfo(STR0035 + cAuxType + " - " + cAuxRESDESC ) // "Erro: "
	Return
EndIf

If cAuxType == "S"
	oWS := NIL
	// Atualiza o status da SG
	OFNJD15AS(cAlias,nReg,nOpc,,.f.)
	//
	// Atualiza S.G.
	dbSelectArea("VMB")
	RecLock("VMB",.f.)
	VMB->VMB_STATSG := "2"
	VMB->(MsUnLock())
	//

EndIf

oWS := NIL

Return



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15CM ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Consulta Memo Credito                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15CM(cAlias,nReg,nOpc,lSchedule)

Local oWS // Instancia da Classe de WebService da John Deere
Local nCont
Local oObjAux
Local lRemPeca := .f.

// Consulta Informacoes de Memo Credito
oWS := WSJohnDeere_Garantia():New("RetrieveCreditMemo")
//oWS:SetDebug()
oWS:oRetrieveCreditMemo_INPUT:cDEALERACCOUNT  := AllTrim(VMB->VMB_DEALER)
oWS:oRetrieveCreditMemo_INPUT:cWO  := AllTrim(VMB->VMB_NUMOSV)
oWS:oRetrieveCreditMemo_INPUT:cSEG := AllTrim(VMB->VMB_REPARO)
lProcessado:= .f.
If lSchedule
	lProcessado := oWS:RetrieveCreditMemo()
Else
	MsgRun(STR0150,STR0031,{|| lProcessado := oWS:RetrieveCreditMemo() }) // Consultando Memo Credito / Processando
EndIf
If !lProcessado
	If !lSchedule
		oWS:ExibeErro("RetrieveCreditMemo")
	EndIf
	Return .f.
EndIf

If oWS:oOUTPUT:oSUCCESS:cTYPE $ "E/X"
	If !lSchedule
		MsgInfo("Erro: " + oWS:oOUTPUT:oSUCCESS:cTYPE + " - " + oWS:oOUTPUT:oSUCCESS:cRESDESC )
	EndIf
	Return .f.
EndIf

If oWS:oOUTPUT:oSUCCESS:cTYPE == "S"
//	MsgInfo("SolicitaÁ„o atualizada")
EndIf

// Marca peÁas para envio para analise
dbSelectArea("VMC")
VMC->(dbSetOrder(5))
For nCont := 1 to Len(oWS:oOUTPUT:oREPLACEPART)
	oObjAux := oWS:oOUTPUT:oREPLACEPART[nCont]
	If VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR + "P" + oObjAux:cPARTNO))
		RecLock("VMC",.f.)
		VMC->VMC_EXCODE := oObjAux:cEXCHCODE
		VMC->(MsUnlock())
	EndIf
	If AllTrim(oObjAux:cEXCHCODE) $ "1/2/8"
		lRemPeca := .t.
	EndIf
Next nCont
//

dbSelectArea("VMB")
RecLock("VMB",.f.)
VMB->VMB_REMPEC := IIf(lRemPeca , "1" , "0")
VMB->(MsUnlock())

oWS := NIL

Return .t.


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15RP ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera numeracao do reparo                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15RP(cNumOsv)

Local nNumReparo := FM_SQL("SELECT MAX(VMB_REPARO) FROM " + RetSQLName("VMB") + " WHERE VMB_FILIAL = '" + xFilial("VMB") + "' AND VMB_NUMOSV = '" + cNumOsv + "'" )

If Empty(nNumReparo)
	nNumReparo := 0
Else
	nNumReparo := Val(nNumReparo) + 1
EndIf

Return StrZero(nNumReparo,2)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15OS ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Atualiza Ordem de ServiÁo                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15OS(cAlias,nReg,nOpc)

Local aPeca
Local aSrvc

Local cAliasVMC := "TVMC"
Local cAuxFiltro := ""

Local nCont
Local nCont2
Local nPos
Local nProc


Local cAuxCpo

Local aResGar := {}
Local aResEsp := {}

Local oSizePrinc
Local oSizeInf
Local oSizeLBox

Local cCpoVisualiza
Local cCpoObrigat
Local cAuxNView

Local nTSrvc := 0
Local nTSrvcCli := 0
Local nTSrvcCon := 0
Local nTSrvcJD  := 0
Local nTSrvcNApr := 0 // Total de Servico de Garantia Especial Nao Aprovado

Local nTPeca       := 0
Local nTPecaCli    := 0
Local nTPecaCon    := 0
Local nTPecaJD     := 0
Local nTPecaJDZSPA := 0
Local nTPecaNApr   := 0 // Total de Peca de Garantia Especial Nao Aprovado

Local nTOutr := 0
Local nTOutrCli := 0
Local nTOutrCon := 0
Local nTOutrJD  := 0

Local nAuxDif
Local nAuxPos

Local cTTPEspCli := ""
Local cTTPEspCon := ""
Local cTTSEspCli := ""
Local cGSrEspCli := ""
Local cCSrEspCli := ""
Local cTSrEspCli := ""
Local cTTSEspCon := ""
Local cGSrEspCon := ""
Local cCSrEspCon := ""
Local cTSrEspCon := ""
Local cGOuEspCli := ""
Local cCOuEspCli := ""
Local cTOuEspCli := ""
Local cGOuEspCon := ""
Local cCOuEspCon := ""
Local cTOuEspCon := ""

Local cTTSerPMP
Local cGSerDesloc
Local cCSerDesloc
Local cTSerDesloc
Local cCodSecPMP
Local cDepGarPMP

Local nDecVO3VALPEC := TamSX3("VO3_VALPEC")[2]

Local cTESEsp := ""
Local cOperEsp := "  "

Local aNewBot := {}

Local nOpcGetDados := 0

Local aAuxLinha := {}
Local nQtdePRet

Local lMReemb := .f.
Local lMReemb100 := .f.

Local cOpEspInt := ""
Local cTESEspInt := ""

Private aCpoCustomizado := {}

Private cMotCancela := "000003"

Private nAuxTotEsp := 0
Private nJDVarPer  := 0 // Percentual da Garantia Especial para a John Deere
Private nCliVarPer := 0 // Percentual da Garantia Especial para o Cliente
Private nConVarPer := 0 // Percentual da Garantia Especial para o Concessionario

Private aVMCPeca := {}
Private aVMCSrvc := {}
Private aVMCOutr := {}

Private lTemPeca := .f.
Private lTemSrvc := .f.
Private lTemOutr := .f.

Private aCpoEnchoice := {}

Private aCpoPec := {}
Private aCpoSrv := {}
Private aCpoOut := {}

Private oOk       := LoadBitmap( GetResources(), "LBOK" )
Private oNo       := LoadBitmap( GetResources(), "LBNO" )
Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )

If OFNJD15SEMREEMBOLSO()
	MsgStop(STR0214 ,STR0111) // "SolicitaÁ„o de garantia sem reembolso. OpÁ„o n„o disponÌvel para este tipo de solicitaÁ„o de garantia."
	REturn .f.
EndIf

If OFNJD15003_NaoPodeAtu()
	Return .f.
EndIf

If !OFNJD15007_VerificaLibVOO( "AT" , VMB->VMB_NUMOSV , VMB->VMB_CODGAR)
	Return .f.
EndIf

cPerg := "OFINJD15"
Pergunte(cPerg,.f.,,,,.f.)

cTTPEspCli := MV_PAR01 // 'TT PeÁa (Esp. Cliente)'
cTTSEspCli := MV_PAR02 // 'TT Srvc (Esp. Cliente)'
cGSrEspCli := MV_PAR03 // 'Grupo Srvc (Esp. Cliente)'
cCSrEspCli := MV_PAR04 // 'Cod. ServiÁo (Esp. Cliente)'
cTSrEspCli := MV_PAR05 // 'Tipo ServiÁo (Esp. Cliente)'
cGOuEspCli := MV_PAR06 // 'Grupo Srvc O. Cred.(Esp. Cli)'
cCOuEspCli := MV_PAR07 // 'Cod. Srvc O. Cred. (Esp. Cli)'
cTOuEspCli := MV_PAR08 // 'Tipo Srvc O. Cred. (Esp. Cli)'

cTTPEspCon := MV_PAR09 // 'TT PeÁa (Esp. Interno)'
cTTSEspCon := MV_PAR10 // 'TT Srvc (Esp. Interno)'
cGSrEspCon := MV_PAR11 // 'Grupo Srvc (Esp. Interno)'
cCSrEspCon := MV_PAR12 // 'Cod. ServiÁo (Esp. Interno)'
cTSrEspCon := MV_PAR13 // 'Tipo ServiÁo (Esp. Interno)'
cGOuEspCon := MV_PAR14 // 'Grupo Srvc O. Cred.(Esp. Int)'
cCOuEspCon := MV_PAR15 // 'Cod. Srvc O. Cred. (Esp. Int)'
cTOuEspCon := MV_PAR16 // 'Tipo Srvc O. Cred. (Esp. Int)'

cTTSerPMP   := MV_PAR29	// Tipo de tempo de Servico de PMP
cGSerDesloc := MV_PAR20	// Grupo de Servico de Deslocamento
cCSerDesloc := MV_PAR21	// Codigo do Servico de Deslocamento
cTSerDesloc := MV_PAR22	// Tipo de Servico de Deslocamento
cCodSecPMP  := MV_PAR31	// Codigo da Secao para servico de PMP
cDepGarPMP  := MV_PAR32	// Departamento de Garantia de PMP

cMotCancela := MV_PAR17	// "000003"

cOperEsp := MV_PAR18	// "  "
cTESEsp  := MV_PAR19	// "713"

If OFNJD15058_validPerg()
	cOpEspInt   := MV_PAR42	// OperaÁ„o (Esp. Int) ?
	cTESEspInt  := MV_PAR43	// TES (Esp. Int) ?
EndIf
// Valida as unidades das pecas envolvidas na SG
OFNJD15UM(VMB->VMB_CODGAR,AllTrim(MV_PAR38))
//

RegToMemory("VMB" , .f. , .t. , .t. ) // .t. para carregar campos virtuais

If VMB->VMB_TIPGAR == "ZSPA"

	// Validacao do Tipod de Servico de Outros Creditos (Cliente e Interno)
	VOK->(dbSetOrder(1))
	If !VOK->(dbSeek(xFilial("VOK") + cTOuEspCli)) .or. !(VOK->VOK_INCMOB $ "2/5")
		MsgStop(STR0154 + " (" + AllTrim(STR0061) + ")." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + AllTrim(STR0061) + ": " + cTOuEspCli) // Tipo de ServiÁo inv·lido. Favor informar um tipo de serviÁo do tipo 2 ou 5 no par‚metro de tipo de serviÁo para outros crÈditos da parte cliente
		Return
	EndIf
	If !VOK->(dbSeek(xFilial("VOK") + cTOuEspCon)) .or. !(VOK->VOK_INCMOB $ "2/5")
		MsgStop(STR0155 + " (" + AllTrim(STR0069) + ")." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + AllTrim(STR0069) + ": " + cTOuEspCon) // Tipo de ServiÁo inv·lido. Favor informar um tipo de serviÁo do tipo 2 ou 5 no par‚metro de tipo de serviÁo para outros crÈditos da parte interna
		Return
	EndIf
	//
	If !Empty(cTESEsp)
		SF4->(dbSetOrder(1))
		If SF4->(dbSeek( xFilial("SF4") + cTESEsp)) .and. SF4->F4_ESTOQUE == "S"
			MsgStop(STR0156 + " (" + AllTrim(STR0072) + ")." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + AllTrim(STR0072) + ": " + cTESEsp) // TES para garantia especial n„o deve movimentar estoque. Favor informar um TES que n„o movimenta estoque no parametro de TES para outros crÈditos
			Return
		EndIf
	EndIf
	//

	AADD( aResEsp , { "M->VMB_JDVAL " , RetTitle("VMB_JDVAL ") , 0 } )
	AADD( aResEsp , { "M->VMB_JDPER " , RetTitle("VMB_JDPER ") , 0 } )
	AADD( aResEsp , { "M->VMB_JDVAR " , RetTitle("VMB_JDVAR ") , 0 } )
	If VMB->VMB_CLIVAR <> 0
		AADD( aResEsp , { "M->VMB_CLIVAL" , RetTitle("VMB_CLIVAL") , 0 } )
		AADD( aResEsp , { "M->VMB_CLIPER" , RetTitle("VMB_CLIPER") , 0 } )
		AADD( aResEsp , { "M->VMB_CLIVAR" , RetTitle("VMB_CLIVAR") , 0 } )
	EndIf
	If VMB->VMB_CONVAR <> 0
		AADD( aResEsp , { "M->VMB_CONVAL" , RetTitle("VMB_CONVAL") , 0 } )
		AADD( aResEsp , { "M->VMB_CONPER" , RetTitle("VMB_CONPER") , 0 } )
		AADD( aResEsp , { "M->VMB_CONVAR" , RetTitle("VMB_CONVAR") , 0 } )
	EndIf
	AADD( aResEsp , { "nAuxTotEsp" , RetTitle("VMB_TOTALG") , 0 } )

	nAuxTotEsp := M->VMB_CLIVAR + M->VMB_CONVAR + M->VMB_JDVAR

	// Especial com 100% para a John Deere ...
	If nAuxTotEsp == M->VMB_JDVAR
		nJDVarPer  := 1
		nCliVarPer := 0
		nConVarPer := 0
	Else
		nJDVarPer  := ( VMB->VMB_JDVAR  / nAuxTotEsp )
		nCliVarPer := ( VMB->VMB_CLIVAR / nAuxTotEsp )
		nConVarPer := ( VMB->VMB_CONVAR / nAuxTotEsp )

		// Ajusta Percentual de Rateio ...
		If nJDVarPer + nCliVarPer + nConVarPer <> 1
			If nCliVarPer <> 0
				nCliVarPer := 1 - (nJDVarPer + nConVarPer)
			Else
				nConVarPer := 1 - (nJDVarPer)
			EndIf
		EndIf

	EndIf

	For nCont := 1 to Len(aResEsp)
		aResEsp[nCont,3] := &(aResEsp[nCont,1])
	Next nCont

EndIf

AADD(aResGar , { "M->VMB_STOTPC" , RetTitle("VMB_STOTPC") , 0 } )
AADD(aResGar , { "M->VMB_ADITPC" , RetTitle("VMB_ADITPC") , 0 } )
AADD(aResGar , { "M->VMB_RETEPC" , RetTitle("VMB_RETEPC") , 0 } )
AADD(aResGar , { "M->VMB_TOTAPC" , RetTitle("VMB_TOTAPC") , 0 } )
AADD(aResGar , { "M->VMB_STOTSV" , RetTitle("VMB_STOTSV") , 0 } )
AADD(aResGar , { "M->VMB_ADITSV" , RetTitle("VMB_ADITSV") , 0 } )
AADD(aResGar , { "M->VMB_RETESV" , RetTitle("VMB_RETESV") , 0 } )
AADD(aResGar , { "M->VMB_TOTASV" , RetTitle("VMB_TOTASV") , 0 } )
AADD(aResGar , { "M->VMB_DESLOC" , RetTitle("VMB_DESLOC") , 0 } )
AADD(aResGar , { "M->VMB_OUTRAS" , RetTitle("VMB_OUTRAS") , 0 } )
AADD(aResGar , { "M->VMB_TOTALW" , RetTitle("VMB_TOTALW") , 0 } )

For nCont := 1 to Len(aResGar)
	aResGar[nCont,3] := &(aResGar[nCont,1])
Next nCont

cSQL := "SELECT DISTINCT VMC_TIPTEM , VMC_LIBVOO "
cSQL +=  " FROM " + RetSQLName("VMC")
cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
cSQL +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC, .F., .T. )
While !(cAliasVMC)->(Eof())
	cAuxFiltro += "(VO#_TIPTEM = '" + (cAliasVMC)->VMC_TIPTEM + "' AND VO#_LIBVOO = '" + (cAliasVMC)->VMC_LIBVOO + "') OR "
	(cAliasVMC)->(dbSkip())
EndDo
(cAliasVMC)->(dbCloseArea())
DbSelectArea("VMB")

cAuxFiltro := Left(cAuxFiltro,Len(cAuxFiltro)-3)

// Levanta pecas da OS
aPeca := FMX_CALPEC( VMB->VMB_NUMOSV , /* cTipTem */ , /* cGruIte */ , /* cCodIte */ , .t. /* lMov */ , .f. /* lNegoc */ , .f. /* lReqZerada */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan */ , /* cLibVOO */ , ;
	StrTran(cAuxFiltro,"#","3") )
aEval(aPeca, { |x| AADD(x,.f.) } )
// Levanta servicos da OS
aSrvc := FMX_CALSER( VMB->VMB_NUMOSV , /* cTipTem */ ,  /* cGruSer */ ,  /* cCodSer */ , .t.  /* lApont */ , .f. /* lNegoc */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan*/ , /* cLibVOO */ , ;
	StrTran(cAuxFiltro,"#","4") )
aEval(aSrvc, { |x| AADD(x,.f.) } )
//

aVMCPeca := {}
aVMCSrvc := {}
aVMCOutr := {}

VO1->(dbSetOrder(1))
VO1->(dbSeek( xFilial("VO1") + VMB->VMB_NUMOSV ))

VMC->(dbSetOrder(1))
VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR ))
While !VMC->(Eof()) .and. VMC->VMC_FILIAL == xFilial("VMC") .and. VMC->VMC_CODGAR == VMB->VMB_CODGAR

	RegToMemory("VMC" , .f. , .t. , .t. ) // .t. para carregar campos virtuais

	Do Case
	// Pecas
	Case VMC->VMC_TIPOPS == "P" .or. (VMC->VMC_TIPOPS == "O" .AND. !Empty(VMC->VMC_CODITE))

		//
		If !(VMB->VMB_TIPGAR $ "ZZMK")

			SB1->(dbSetOrder(7))
			SB1->(dbSeek(xFilial("SB1") + M->VMC_GRUITE + M->VMC_CODITE ))
			SB1->(dbSetOrder(1))

			// Peca enviada como outros creditos considera a qtde retornada a qtde enviada
			If VMC->VMC_TIPOPS == "O" .AND. !Empty(VMC->VMC_CODITE)
				nQtdePRet := M->VMC_QTDPEC
				nVlrUnRet := M->VMC_CUSMAR
				nVlrUnRet := Round(nVlrUnRet / nQtdePRet, nDecVO3VALPEC )
				nVlrTRet  := M->VMC_CUSMAR
			Else
				nQtdePRet := M->VMC_QPCRET
				nVlrUnRet := M->VMC_VUPECR
				nVlrTRet  := M->VMC_VTPECR
			EndIf
			//

			nVlrUnitZSPA := 0

			If SB1->B1_UM == M->VMC_UM
				nQtdePeca := 0
				nQtdePecaC := 0
				lConvUM := .f.
				nVlrUnit := nVlrUnRet
				If VMB->VMB_TIPGAR == "ZSPA"
					nVlrUnitZSPA := Round( nVlrTRet / nQtdePRet , nDecVO3VALPEC )
				EndIf
			ElseIf SB1->B1_SEGUM == M->VMC_UM
				lConvUM := .t.
				nQtdePeca  := Round( ConvUm(SB1->B1_COD,1,nQtdePRet,2) , TamSX3( "VO3_QTDREQ" )[2] )
				nQtdePecaC := Round( ConvUm(SB1->B1_COD,1,nQtdePRet,1) , TamSX3( "VO3_QTDREQ" )[2] ) // Quantidade Convertida ...

				// Calcula o valor unitario na primeira unidade de pedida
				If VMB->VMB_TIPGAR == "ZSPA"
					nVlrUnit := nVlrUnRet
					nVlrUnitZSPA := Round( nVlrTRet / nQtdePRet , nDecVO3VALPEC )
				Else
					nVlrUnit := nVlrTRet / nQtdePRet
				EndIf
				nVlrUnit := Round(nVlrUnit * nQtdePeca, nDecVO3VALPEC )
				//
			Else
				MsgInfo(STR0157+CHR(13)+CHR(10)+CHR(13)+CHR(10)+SB1->B1_GRUPO+" "+SB1->B1_CODITE+CHR(13)+CHR(10)+"B1_UM "+SB1->B1_UM+"B1_SEGUM "+SB1->B1_SEGUM+CHR(13)+CHR(10)+"VMC_UM "+VMC->VMC_UM) // Unidade de medida n„o configurada
				Return
			EndIf

			lTemPeca := .t.

			nPos := aScan( aPeca , { |x| x[PECA_GRUITE] == VMC->VMC_GRUITE .and. ;
										 x[PECA_CODITE] == VMC->VMC_CODITE .and. ;
										 x[PECA_TIPTEM] == VMC->VMC_TIPTEM .and. ;
										 x[PECA_LIBVOO] == VMC->VMC_LIBVOO } )

			AADD(aVMCPeca,Array(26))
			nAuxPos := Len(aVMCPeca)
			aVMCPeca[ nAuxPos , _VMC_PECA_TIPTEM_            ] := M->VMC_TIPTEM	// 01 -
			aVMCPeca[ nAuxPos , _VMC_PECA_LIBVOO_            ] := M->VMC_LIBVOO	// 02 -
			aVMCPeca[ nAuxPos , _VMC_PECA_GRUITE_            ] := M->VMC_GRUITE	// 03 -
			aVMCPeca[ nAuxPos , _VMC_PECA_CODITE_            ] := M->VMC_CODITE	// 04 -
			aVMCPeca[ nAuxPos , _VMC_PECA_DESCRI_            ] := M->VMC_DESCRI	// 05 -
			aVMCPeca[ nAuxPos , _VMC_PECA_UM_                ] := M->VMC_UM		// 06 -
			aVMCPeca[ nAuxPos , _VMC_PECA_QTDPEC_            ] := M->VMC_QTDPEC	// 07 - Qtde Peca enviada
			aVMCPeca[ nAuxPos , _VMC_PECA_QTDPECRETORNADA_   ] := nQtdePRet		// 08 - Qtde Peca retornada
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNITENVIADO_    ] := M->VMC_VUPECE	// 09 - Valor unitario peca enviado
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNITRETORNADO_  ] := nVlrUnit		// 10 - Valor unitario peca retornado
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRTOTALENVIADO_   ] := M->VMC_VTPECE	// 11 - Valor Total Peca Enviado
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRTOTALRETORNADO_ ] := nVlrTRet 		// 12 - Valor Total peca Retornado
			aVMCPeca[ nAuxPos , _VMC_PECA_PROBQTDE_          ] := .f.				// 13 - Problema com Qtde
			aVMCPeca[ nAuxPos , _VMC_PECA_PROBQTDEACERTADO_  ] := .f.				// 14 - Problema com Qtde (Acertado)
			aVMCPeca[ nAuxPos , _VMC_PECA_PROBVALOR_         ] := .f.				// 15 - Problema com Valor
			aVMCPeca[ nAuxPos , _VMC_PECA_PROBVALORACERTADO_ ] := .f.				// 16 - Problema com Valor (Acertado)
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRREQUISITADO_    ] := 0					// 17 - Valor da Peca (Requisicao)
			aVMCPeca[ nAuxPos , _VMC_PECA_TES_               ] := ""				// 18 - TES da Requisicao
			aVMCPeca[ nAuxPos , _VMC_PECA_CONVUM_            ] := lConvUM			// 19 - Houve Conversao de Unidade de Medida ?
			aVMCPeca[ nAuxPos , _VMC_PECA_QTD1UM_            ] := nQtdePeca		// 20 - Quantidade na Primeira Unidade de Medida
			aVMCPeca[ nAuxPos , _VMC_PECA_PECOUTRCRED_       ] := .f.				// 21 - Peca enviada como outros creditos ?
			aVMCPeca[ nAuxPos , _VMC_PECA_PMPMATRIZREEMB_    ] := 0					// 22 - Matriz de Reembolso - PMP (R$)
			aVMCPeca[ nAuxPos , _VMC_PECA_QTDRET1UM_         ] := nQtdePecaC		// 23 - Quantidade Retornada na Primeira Unidade de Medida
			aVMCPeca[ nAuxPos , _VMC_PECA_UMPARACONVERSAO_   ] := SB1->B1_UM		// 24 - Unidade de Medida para Requisicao
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNIT_ZSPA_      ] := nVlrUnitZSPA	// 25 - Valor unitario peca - Garantia Especial
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRTOTAL_ZSPA_     ] := Round(nQtdePRet * nVlrUnitZSPA , 2 ) // 26 - Valor TOTAL peca - Garantia Especial

			// Houve Requisicao ...
			If nPos <> 0
				aVMCPeca[ nAuxPos ,_VMC_PECA_VLRREQUISITADO_ ] := aPeca[nPos,PECA_VALOR]
				aVMCPeca[ nAuxPos ,_VMC_PECA_TES_ ] := aPeca[nPos,PECA_TES]
			EndIf
			//
			// Problema de Quantidade ou Valor Retornado Zerado
			If VMC->VMC_QTDPEC <> nQtdePRet .or. nVlrTRet == 0
				aVMCPeca[ nAuxPos ,_VMC_PECA_PROBQTDE_ ] := .t.
			EndIf
			
			// Matriz de Reembolso
			If VMB->VMB_TIPGAR == "ZPIP" .and. VMC->VMC_QTDPEC == nQtdePRet .AND. nVlrTRet == 0
				//aVMCPeca[ nAuxPos ,_VMC_PECA_QTDPECRETORNADA_ ] := 0
				aVMCPeca[ nAuxPos ,_VMC_PECA_PROBQTDE_ ] := .t.
			EndIf
			//

			// Problema com valor
			If VMC->VMC_VTPECE <> nVlrTRet
				aVMCPeca[ nAuxPos ,_VMC_PECA_PROBVALOR_ ] := .t.
			EndIf
			//

			// Peca enviada como outros creditos
			If VMC->VMC_TIPOPS == "O" .AND. !Empty(VMC->VMC_CODITE)
				aVMCPeca[ nAuxPos , _VMC_PECA_PECOUTRCRED_ ] := .t.
				nTPeca     += M->VMC_CUSMAT
			Else
				nTPeca     += nQtdePRet * M->VMC_VUPECR
				nTPecaNApr += (M->VMC_QTDPEC - nQtdePRet) * M->VMC_VUPECR
			EndIf
			//

			nTPecaJD   += nVlrTRet

			If VMB->VMB_TIPGAR == "ZSPA"
				nTPecaJDZSPA += Round( nQtdePRet * nVlrUnitZSPA , 2 )
			EndIf

		EndIf
		//

	// Servicos
	CASE VMC->VMC_TIPOPS == "S"

		lTemSrvc := .t.

		AADD(aVMCSrvc,Array(21))
		nAuxPos := Len(aVMCSrvc)
		aVMCSrvc[nAuxPos, _VMC_SRVC_TIPTEM_            ] := M->VMC_TIPTEM
		aVMCSrvc[nAuxPos, _VMC_SRVC_LIBVOO_            ] := M->VMC_LIBVOO
		aVMCSrvc[nAuxPos, _VMC_SRVC_GRUSER_            ] := M->VMC_GRUSER
		aVMCSrvc[nAuxPos, _VMC_SRVC_CODSER_            ] := M->VMC_CODSER
		aVMCSrvc[nAuxPos, _VMC_SRVC_TIPTRA_            ] := M->VMC_TIPTRA
		aVMCSrvc[nAuxPos, _VMC_SRVC_TIPTRD_            ] := M->VMC_TIPTRD
		aVMCSrvc[nAuxPos, _VMC_SRVC_LOCTRA_            ] := M->VMC_LOCTRA
		aVMCSrvc[nAuxPos, _VMC_SRVC_RECNO_             ] := VMC->(Recno()) 
		aVMCSrvc[nAuxPos, _VMC_SRVC_HORASENVIADO_      ] := M->VMC_QTDTRA
		aVMCSrvc[nAuxPos, _VMC_SRVC_HORASRETORNADA_    ] := M->VMC_QSRRET
		aVMCSrvc[nAuxPos, _VMC_SRVC_VLRHORAENVIADO_    ] := M->VMC_VALHRE
		aVMCSrvc[nAuxPos, _VMC_SRVC_VLRHORARETORNADA_  ] := M->VMC_VALHRR
		aVMCSrvc[nAuxPos, _VMC_SRVC_VLRTOTALENVIADO_   ] := M->VMC_VTSERE
		aVMCSrvc[nAuxPos, _VMC_SRVC_VLRTOTALRETORNADO_ ] := M->VMC_VTSERR
		aVMCSrvc[nAuxPos, _VMC_SRVC_PROBQTDE_          ] := .f. // Problema com Qtde
		aVMCSrvc[nAuxPos, _VMC_SRVC_PROBQTDEACERTADO_  ] := .f. // Problema com Qtde (Acertado)
		aVMCSrvc[nAuxPos, _VMC_SRVC_PROBVALOR_         ] := .f. // Problema com Valor
		aVMCSrvc[nAuxPos, _VMC_SRVC_PROBVALORACERTADO_ ] := .f. // Problema com Valor (Acertado)
		aVMCSrvc[nAuxPos, _VMC_SRVC_ORIGEM_            ] := M->VMC_ORIGEM // Origem do Registro 1=Fabrica / 2=Manual
		aVMCSrvc[nAuxPos, _VMC_SRVC_NAOAPROVADO_       ] := .f. // Servico n„o aprovado pela John Deere
		aVMCSrvc[nAuxPos, _VMC_SRVC_POS_ACOLS_         ] := 0

		// Revisao ...
		If VMB->VMB_TIPGAR == "ZZMK" .and. VMB->VMB_SUBGAR == "MTC"
			// Sempre acerta a quantidade e valor ...
			aVMCSrvc[nAuxPos,_VMC_SRVC_PROBQTDE_] := .t. // Problema com Qtde
			aVMCSrvc[nAuxPos,_VMC_SRVC_PROBVALOR_] := .t. // Problema com Valor
			//
		EndIf
		// Matriz de Reembolso
		If VMB->VMB_TIPGAR == "ZPIP" .and. M->VMC_QTDTRA == M->VMC_QSRRET .AND. M->VMC_VTSERR == 0
			aVMCSrvc[nAuxPos,_VMC_SRVC_PROBQTDE_] := .t. // Problema com Qtde
		EndIf
		// Servico nao aprovado 
		If VMC->VMC_VTSERE <> 0 .AND. VMC->VMC_VTSERR == 0
			aVMCSrvc[nAuxPos,_VMC_SRVC_NAOAPROVADO_] := .t.
			aVMCSrvc[nAuxPos,_VMC_SRVC_RECNO_] := VMC->(Recno())
		EndIf
		//
		If VMB->VMB_TIPGAR $ "ZNRM/ZPIP/ZPAR/ZZBT"
			// Problema com qtde de horas
			If VMC->VMC_QTDTRA <> VMC->VMC_QSRRET
				aVMCSrvc[nAuxPos,_VMC_SRVC_PROBQTDE_] := .t.
			EndIf
			// Problema com valor total de servicos
			If (VMC->VMC_VTSERR / VMC->VMC_QSRRET) <> VMC->VMC_VALHRE
				aVMCSrvc[nAuxPos,_VMC_SRVC_PROBVALOR_] := .t.
			EndIf
			//
		EndIf

		If VMB->VMB_TIPGAR == "ZSPA"
			If M->VMC_VALHRE == 0
				MsgInfo(STR0207 + CHR(13) + CHR(10) + STR0208 + " " + M->VMC_GRUSER + " - " + M->VMC_CODSER ) // ServiÁo na VMC sem valor de hora. / ServiÁo:
			EndIf

			nTSrvc     += M->VMC_QSRRET * M->VMC_VALHRE
			nTSrvcNApr += (M->VMC_QTDTRA - M->VMC_QSRRET) * M->VMC_VALHRE
			nTSrvcJD   += M->VMC_VTSERR
		EndIf

	// Outros Creditos
	CASE VMC->VMC_TIPOPS == "O" .AND. Empty(VMC->VMC_CODITE)

		lTemOutr := .t.

		AADD(aVMCOutr,Array(14))
		nAuxPos := Len(aVMCOutr)
		aVMCOutr[nAuxPos, _VMC_OUTR_TIPTEM_            ] := M->VMC_TIPTEM
		aVMCOutr[nAuxPos, _VMC_OUTR_LIBVOO_            ] := M->VMC_LIBVOO
		aVMCOutr[nAuxPos, _VMC_OUTR_GRUSER_            ] := M->VMC_GRUSER
		aVMCOutr[nAuxPos, _VMC_OUTR_CODSER_            ] := M->VMC_CODSER
		aVMCOutr[nAuxPos, _VMC_OUTR_CODMAT_            ] := M->VMC_CODMAT
		aVMCOutr[nAuxPos, _VMC_OUTR_CODMAD_            ] := M->VMC_CODMAD
		aVMCOutr[nAuxPos, _VMC_OUTR_CUSMAT_            ] := M->VMC_CUSMAT
		aVMCOutr[nAuxPos, _VMC_OUTR_CUSMAR_            ] := M->VMC_CUSMAR
		aVMCOutr[nAuxPos, _VMC_OUTR_COMENT_            ] := M->VMC_COMENT
		aVMCOutr[nAuxPos, _VMC_OUTR_PROBVALOR_         ] := .f. // Problema com Valor
		aVMCOutr[nAuxPos, _VMC_OUTR_PROBVALORACERTADO_ ] := .f. // Problema com Valor (Acertado)
		aVMCOutr[nAuxPos, _VMC_OUTR_RECNO_             ] := VMC->(Recno()) // Recno
		aVMCOutr[nAuxPos, _VMC_OUTR_NAOTRANSMITIDO_    ] := .f. // Servico nao transmitido na Ordem de Servico
		aVMCOutr[nAuxPos, _VMC_OUTR_NAOAPROVADO_       ] := .f. // Servico nao APROVADO

		// Deslocamento ...
		If VMC->VMC_CODMAT == "WTYSUBL8" .and. ((VMB->VMB_TIPGAR == "ZZMK" .and. VMB->VMB_SUBGAR == "MTC") .or. VMB->VMB_TIPGAR == "ZPIP")
			If VMC->VMC_CUSMAR <> 0
				aVMCOutr[nAuxPos,_VMC_OUTR_PROBVALOR_] := .T. // Problema com Valor
			EndIf
		Else
			aVMCOutr[nAuxPos,_VMC_OUTR_PROBVALOR_] := (VMC->VMC_CUSMAT == 0 .and. VMC->VMC_CUSMAR <> 0)

			// Outros Creditos n„o aprovado
			If VMC->VMC_CUSMAT <> 0 .AND. VMC->VMC_CUSMAR == 0
				aVMCOutr[nAuxPos,_VMC_OUTR_NAOAPROVADO_] := .t.
				aVMCOutr[nAuxPos,_VMC_OUTR_RECNO_] := VMC->(Recno())
			EndIf
			//

		EndIf
		//

		// Verifica se o servico foi transmitido para a JD
		If Empty(aVMCOutr[nAuxPos, _VMC_OUTR_CODSER_]) .and. M->VMC_CUSMAR <> 0
			aVMCOutr[nAuxPos, _VMC_OUTR_NAOTRANSMITIDO_] := .t.
		EndIf
		//

		nTOutr   += M->VMC_CUSMAT
		nTOutrJD += M->VMC_CUSMAR

	EndCase

	VMC->(dbSkip())
EndDo

// PMP com matriz de reembolso
lMReemb := .f.
lMReemb100 := .f.
If VMB->VMB_TIPGAR == "ZPIP" .and. VMB->VMB_MREEMP <> 0
	nTotReemb := 0
	nTotPeca  := 0
	aEval(aVMCPeca, { |x| nTotPeca += x[_VMC_PECA_VLRTOTALRETORNADO_] } )

	// Matriz de reembolso 100%
	If nTotPeca == 0
		aEval(aVMCPeca, { |x| nTotPeca += x[_VMC_PECA_VLRTOTALENVIADO_] } )

		For nCont := 1 to Len(aVMCPeca)
			aVMCPeca[nCont,_VMC_PECA_PMPMATRIZREEMB_] := VMB->VMB_MREEMP * (aVMCPeca[nCont,_VMC_PECA_VLRTOTALENVIADO_] / nTotPeca)
			nTotReemb += aVMCPeca[nCont,_VMC_PECA_PMPMATRIZREEMB_]
		Next nCont

		lMReemb100 := .t.

	Else
		For nCont := 1 to Len(aVMCPeca)
			aVMCPeca[nCont,_VMC_PECA_PMPMATRIZREEMB_] := VMB->VMB_MREEMP * (aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] / nTotPeca)
			nTotReemb += aVMCPeca[nCont,_VMC_PECA_PMPMATRIZREEMB_]
		Next nCont

		lMReemb := .t.
	EndIf

	If nTotReemb <> VMB->VMB_MREEMP .and. nTotReemb <> 0
		aVMCPeca[1,_VMC_PECA_PMPMATRIZREEMB_] += nTotReemb - VMB->VMB_MREEMP
	ElseIf nTotReemb == 0
		aVMCPeca[1,_VMC_PECA_PMPMATRIZREEMB_] += VMB->VMB_MREEMP
	EndIf

EndIf
//

If VMB->VMB_TIPGAR == "ZSPA"
	OFNJD15008_EspecialVerPecaJD( nTPecaJD, nTPecaJDZSPA )
EndIf

// Ponto de entrada que dever· retornar nome dos campos que ser„o
// adicionados na grid de PeÁas, ServiÁos e/ou Outros CrÈditos
If ExistBlock("ONJD15CP")
	aCpoCustomizado := ExecBlock("ONJD15CP",.f.,.f.)
EndIf
//

// Verifica os campos que ser„o exibidos na tela
OFNJD15CPO(VMB->VMB_TIPGAR,.F.,@cCpoVisualiza,@cCpoObrigat,@cAuxNView)

RegToMemory("VMB" , .f. , .t. , .t. ) // .t. para carregar campos virtuais

aHeader := {}
aCols   := {}

nOpc := 2
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
nOpcE     := nOpc
nOpcG     := nOpc

FM_Mod3("","VMB","VMC",@aCpoEnchoice,,@aHeader,@aCols,"AllwaysTrue()","AllwaysTrue()","AllwaysTrue()",,nOpcE,nOpcG,,,,,,;
	cAuxNView,"VMC_CODGAR/",;
	1 /* nOrdGet2 */ ,;
	"VMC->VMC_FILIAL+VMC->VMC_CODGAR" /* cChvGet2 */ ,;
	xFilial("VMC") + VMB->VMB_CODGAR  /* cVlChvGet2 */ ;
	,,,,,,.t. /* lAuto - passa como execauto para nao montar a tela */ )

// Calculo da Janela Principal
oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:AddObject("INFORMACOES", 100 , 120 , .T. , .F. )
oSizePrinc:AddObject("FOLDER"     , 100 , 100 , .T. , .T. )
//oSizePrinc:aMargins := { 3 , 0 , 3 , 3 }
oSizePrinc:Process()	// Calcula Coordenadas
//

// Calculo da Parte de Informacoes
oSizeInf := FwDefSize():New(.f.)
oSizeInf:aWorkArea := oSizePrinc:GetNextCallArea("INFORMACOES")
oSizeInf:AddObject("ENCHOICE"    ,080,100,.T.,.T.)
If VMB->VMB_TIPGAR == "ZSPA"
	oSizeInf:AddObject("LBOXESP" ,080,100,.F.,.T.)
EndIf
oSizeInf:AddObject("LBOXRESUMO" ,080,100,.F.,.T.)
oSizeInf:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeInf:lLateral := .t.	// Calcula em colunas
oSizeInf:Process()	// Calcula Coordenadas
//

// Calculo da Parte de Listbox e GetDados
oSizeLBox := FwDefSize():New(.f.)
oSizeLBox:aWorkArea := oSizePrinc:GetNextCallArea("FOLDER")
oSizeLBox:aWorkArea[3] -= oSizeLBox:aWorkArea[1] + 04	// Coluna Final
oSizeLBox:aWorkArea[4] -= oSizeLBox:aWorkArea[2] + 15	// Linha Final
oSizeLBox:aWorkArea[1] := 0 // Coluna Inicial
oSizeLBox:aWorkArea[2] := 0 // Linha Inicial

oSizeLBox:AddObject("LISTBOX"   ,100,100,.T.,.T.)
oSizeLBox:AddObject("GETDADOS"  ,100,100,.T.,.T.)
//oSizeLBox:aMargins := { 3 , 3 , 3 , 3 }

oSizeLBox:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeLBox:Process()	// Calcula Coordenadas
//


DEFINE MSDIALOG oDlgAtuOS TITLE STR0042 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4] // "Atualizar O.S."

oEnchVV1 := MSMGet():New("VMB",nReg, 2 /* Visualizar */ ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, ;
	oSizeInf:GetObjectArea("ENCHOICE"), ;
	aCpoEnchoice, 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oDlgAtuOS , .f. /* lF3 */ , .t. /* lMemoria */ , .F. /* lColumn */ ,;
	/* caTela */ , .t. /* lNoFolder */, .f. /* lProperty */ )


If VMB->VMB_TIPGAR == "ZSPA"
	oResEsp := TWBrowse():New( oSizeInf:GetDimension("LBOXESP","LININI") /* + 8 */ , ;
							   oSizeInf:GetDimension("LBOXESP","COLINI") /* + 2 */ ,;
							   oSizeInf:GetDimension("LBOXESP","XSIZE") /* -04 */  ,;
							   oSizeInf:GetDimension("LBOXESP","YSIZE") /* -10 */ ,,,,oDlgAtuOS,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oResEsp:AddColumn( TCColumn():New( STR0043 , { || aResEsp[oResEsp:nAt,02] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )                            // "DescriÁ„o"
	oResEsp:AddColumn( TCColumn():New( STR0044 , { || Transform(aResEsp[oResEsp:nAt,03],"@E 999,999.99" ) },,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) ) // "Valor"
	oResEsp:nAt := 1
	oResEsp:SetArray(aResEsp)
	oResEsp:Refresh()
EndIf

oResGar := TWBrowse():New( oSizeInf:GetDimension("LBOXRESUMO","LININI") /* + 8 */ , ;
						   oSizeInf:GetDimension("LBOXRESUMO","COLINI") /* + 2 */ ,;
						   oSizeInf:GetDimension("LBOXRESUMO","XSIZE") /* -04 */  ,;
						   oSizeInf:GetDimension("LBOXRESUMO","YSIZE") /* -10 */ ,,,,oDlgAtuOS,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oResGar:AddColumn( TCColumn():New( STR0043 , { || aResGar[oResGar:nAt,02] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )                            // "DescriÁ„o"
oResGar:AddColumn( TCColumn():New( STR0044 , { || Transform(aResGar[oResGar:nAt,03],"@E 999,999.99" ) },,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) ) // "Valor"
oResGar:nAt := 1
oResGar:SetArray(aResGar)
oResGar:Refresh()


oFAtuOS := TFolder():New( oSizePrinc:GetDimension("FOLDER","LININI" ) , ;
						  oSizePrinc:GetDimension("FOLDER","COLINI" ) ,;
						  , , oDlgAtuOS , , , , .t. , ,;
						  oSizePrinc:GetDimension("FOLDER","XSIZE" ),;
						  oSizePrinc:GetDimension("FOLDER","YSIZE" ) )

If Len(aVMCPeca) > 0

	oFAtuOS:AddItem( STR0045 , .t. ) // "PeÁas"
	nAuxFolder := Len(oFAtuOS:aDialogs)

	oPeca := TWBrowse():New( oSizeLBox:GetDimension("LISTBOX","LININI") /* + 8 */ , ;
							 oSizeLBox:GetDimension("LISTBOX","COLINI") /* + 2 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","XSIZE") /* -04 */  ,;
							 oSizeLBox:GetDimension("LISTBOX","YSIZE") /* -10 */ ,,,,oFAtuOS:aDialogs[nAuxFolder],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_TIPTEM") , { || aVMCPeca[oPeca:nAt,01] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_LIBVOO") , { || aVMCPeca[oPeca:nAt,02] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_GRUITE") , { || aVMCPeca[oPeca:nAt,03] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_CODITE") , { || aVMCPeca[oPeca:nAt,04] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_DESCRI") , { || aVMCPeca[oPeca:nAt,05] },,,,"LEFT" 	,100,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_UM")     , { || aVMCPeca[oPeca:nAt,06] },,,,"LEFT" 	,20,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_QTDPEC") , { || Transform(aVMCPeca[oPeca:nAt,_VMC_PECA_QTDPEC_],PesqPict("VMC","VMC_QTDPEC")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_QPCRET") , { || Transform(aVMCPeca[oPeca:nAt,_VMC_PECA_QTDPECRETORNADA_],PesqPict("VMC","VMC_QPCRET")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_VUPECE") , { || Transform(aVMCPeca[oPeca:nAt,09],PesqPict("VMC","VMC_VUPECE")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	If VMB->VMB_TIPGAR == "ZSPA"
		oPeca:AddColumn( TCColumn():New( RetTitle("VMC_VUPECR") , { || Transform(aVMCPeca[oPeca:nAt, _VMC_PECA_VLRUNIT_ZSPA_ ],PesqPict("VMC","VMC_VUPECR")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	Else
		oPeca:AddColumn( TCColumn():New( RetTitle("VMC_VUPECR") , { || Transform(aVMCPeca[oPeca:nAt,10],PesqPict("VMC","VMC_VUPECR")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	EndIf
	oPeca:AddColumn( TCColumn():New( RetTitle("VMC_VTPECE") , { || Transform(aVMCPeca[oPeca:nAt,11],PesqPict("VMC","VMC_VTPECE")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	If VMB->VMB_TIPGAR == "ZSPA"
		oPeca:AddColumn( TCColumn():New( RetTitle("VMC_VTPECR") , { || Transform(aVMCPeca[oPeca:nAt, _VMC_PECA_VLRTOTAL_ZSPA_ ],PesqPict("VMC","VMC_VTPECR")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	Else
		oPeca:AddColumn( TCColumn():New( RetTitle("VMC_VTPECR") , { || Transform(aVMCPeca[oPeca:nAt,12],PesqPict("VMC","VMC_VTPECR")) },,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) )
	EndIf
	oPeca:AddColumn( TCColumn():New( STR0046                , { || IIf( aVMCPeca[oPeca:nAt,13] , oVermelho , oVerde ) } ,,,,"LEFT" ,30,.T.,.F.,,,,.F.,) ) // Problema com Qtde
	oPeca:nAt := 1
	oPeca:SetArray(aVMCPeca)
	oPeca:Refresh()

	AADD( aCpoPec , "VO3_TIPTEM" )
	AADD( aCpoPec , "VO3_GRUITE" )
	AADD( aCpoPec , "VO3_CODITE" )
	AADD( aCpoPec , "VO3_FATPAR" )
	AADD( aCpoPec , "VO3_LOJA"   )
	AADD( aCpoPec , "VO3_NOMCLI" )
	AADD( aCpoPec , "VO3_QTDREQ" )
	AADD( aCpoPec , "B1_UM" )
	AADD( aCpoPec , "VO3_VALPEC" )
	AADD( aCpoPec , "VO3_VALTOT" )
	AADD( aCpoPec , "VO3_OPER"   )
	AADD( aCpoPec , "VO3_CODTES" )
	AADD( aCpoPec , "F4_ESTOQUE" )
	AADD( aCpoPec , "VO3_DEPINT" )
	AADD( aCpoPec , "VO3_PROREQ" )

	OFNJD15001_AdicionaCamposCustomizados(aCpoPec, aCpoCustomizado, "PECAS")

	aHPeca := {}
	aAlter := {}

	AADD( aHPeca , { STR0209, "PEC_STATUS" ,	"@!", 30,;
						0,     "AllWaysTrue()",		X3_USADO_EMUSO , 	"C",;
						"",		  "R",			"",	 				"" }) // Status
	M->PEC_STATUS := Space(30)

	SX3->(dbSetOrder(2))
	For nCont := 1 to Len(aCpoPec)

		cAuxCpo := "PEC" + SubStr( aCpoPec[nCont] , At("_",aCpoPec[nCont]) )

		SX3->(dbSeek(aCpoPec[nCont]))
		AADD( aHPeca , { AllTrim(X3Titulo()), cAuxCpo ,	SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,     "AllWaysTrue()",		X3_USADO_EMUSO , 	SX3->X3_TIPO,;
						SX3->X3_F3,		  "R",			"",	 				"" })

		If ! AllTrim(aCpoPec[nCont]) $ "F4_ESTOQUE/VO3_NOMCLI/B1_UM/VO3_GRUITE/VO3_CODITE/VO3_QTDREQ/VO3_VALPEC/VO3_VALTOT"
			AADD(aAlter,cAuxCpo)
		EndIf

		wVar  := "M->"+cAuxCpo
		&wVar := CriaVar(SX3->X3_CAMPO,.f.)

		wVar := "M->"+aCpoPec[nCont]
		&wVar := CriaVar(SX3->X3_CAMPO,.f.)

	Next nCont

	aCols := {}

	// Analisa as pecas ...
	For nCont := 1 to Len(aVMCPeca)
		// Problema com qtde de pecas ou
		// OU
		// A SG È de PMP e tem problema com valor e Matriz de Reembolso ...
		If  aVMCPeca[nCont, _VMC_PECA_PROBQTDE_ ] .or. ;
		  ( aVMCPeca[nCont, _VMC_PECA_PROBVALOR_] .and. VMB->VMB_TIPGAR == "ZPIP" .and. aVMCPeca[nCont, _VMC_PECA_PMPMATRIZREEMB_ ] <> 0 )

			If VMB->VMB_TIPGAR == "ZPIP"
				// Matriz de Reembolso, qtde aprovada, mas a Fabrica nao paga nada ...
				If aVMCPeca[nCont, _VMC_PECA_VLRTOTALRETORNADO_ ] == 0 .and. aVMCPeca[nCont, _VMC_PECA_PMPMATRIZREEMB_ ] <> 0
					nAuxPos := OFNJD15021_addAColsPeca(@aCols, nCont)
					
					aCols[nAuxPos,FG_POSVAR("PEC_UM","aHPeca")] := aVMCPeca[ nCont, _VMC_PECA_UMPARACONVERSAO_ ]

					nAuxVlrPeca	:= ( aVMCPeca[nCont, _VMC_PECA_VLRTOTALRETORNADO_ ] + aVMCPeca[nCont,_VMC_PECA_PMPMATRIZREEMB_] )

					If aVMCPeca[nCont,_VMC_PECA_CONVUM_]
						aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := aVMCPeca[nCont,_VMC_PECA_QTDRET1UM_]

						nAuxVlrPeca	:= nAuxVlrPeca / aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_]
						nAuxVlrPeca	:= nAuxVlrPeca * aVMCPeca[nCont,_VMC_PECA_QTD1UM_]
						nAuxVlrPeca	:= Round( nAuxVlrPeca ,TamSX3("VO3_VALPEC")[2])

					Else
						aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_]

						nAuxVlrPeca	:= Round( nAuxVlrPeca / aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] ,TamSX3("VO3_VALPEC")[2])
					EndIf

					nQtdePRet := aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")]

					aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] := nAuxVlrPeca
					aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")] := Round( nAuxVlrPeca * nQtdePRet,2)
					aCols[nAuxPos,FG_POSVAR("PEC_STATUS","aHPeca")] := STR0210 + " (100%)"// "MATRIZ REEMBOLSO"

				ElseIf aVMCPeca[nCont, _VMC_PECA_VLRTOTALRETORNADO_ ] <> 0 .and. aVMCPeca[nCont, _VMC_PECA_PMPMATRIZREEMB_ ] <> 0
					nAuxPos := OFNJD15021_addAColsPeca(@aCols, nCont)
					
					aCols[nAuxPos,FG_POSVAR("PEC_UM","aHPeca")] := aVMCPeca[ nCont, _VMC_PECA_UMPARACONVERSAO_ ]

					If aVMCPeca[nCont,_VMC_PECA_CONVUM_]
						aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := aVMCPeca[nCont,_VMC_PECA_QTDRET1UM_]
					Else
						aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_]
					EndIf
					nQtdePRet := aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")]

					nAuxVlrPeca	:= Round( aVMCPeca[nCont, _VMC_PECA_PMPMATRIZREEMB_ ] / nQtdePRet  ,TamSX3("VO3_VALPEC")[2])
					aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] := nAuxVlrPeca
					aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")] := Round( nAuxVlrPeca * nQtdePRet ,2)
					
					aCols[nAuxPos,FG_POSVAR("PEC_OPER"  ,"aHPeca")] := cOperEsp
					aCols[nAuxPos,FG_POSVAR("PEC_CODTES","aHPeca")] := cTESEsp
					aCols[nAuxPos,FG_POSVAR("PEC_STATUS","aHPeca")] := STR0210 // "MATRIZ REEMBOLSO"
				EndIf
			EndIf

			// Quantidade enviada È maior do que a quantidade retornada
			If aVMCPeca[nCont, _VMC_PECA_QTDPEC_ ] > aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_ ]
				nAuxPos := OFNJD15021_addAColsPeca(@aCols, nCont)
				aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := aVMCPeca[nCont, _VMC_PECA_QTDPEC_ ] - aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_ ]
				aCols[nAuxPos,FG_POSVAR("PEC_UM","aHPeca")] := aVMCPeca[ nCont, _VMC_PECA_UM_ ]
				aCols[nAuxPos,FG_POSVAR("PEC_STATUS","aHPeca")] := STR0211 // "PECA NAO APROVADA"
			// Quantidade retornada È maior do que a quantidade enviada
			ElseIf aVMCPeca[nCont, _VMC_PECA_QTDPEC_ ] < aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_ ]
				nAuxPos := OFNJD15021_addAColsPeca(@aCols, nCont)
				aCols[nAuxPos,FG_POSVAR("PEC_TIPTEM","aHPeca")] := aVMCPeca[nCont, _VMC_PECA_TIPTEM_ ]
				aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := aVMCPeca[nCont, _VMC_PECA_QTDPECRETORNADA_ ] - aVMCPeca[nCont, _VMC_PECA_QTDPEC_ ]
				aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] := aVMCPeca[nCont, _VMC_PECA_VLRUNITRETORNADO_ ]
				aCols[nAuxPos,FG_POSVAR("PEC_STATUS","aHPeca")] := STR0212 // "PECA ACRESCENTADA"
			EndIf
			//
		EndIf
	Next nCont
	//

	If VMB->VMB_TIPGAR == "ZSPA" .AND. (VMB->VMB_CLIVAR <> 0 .or. VMB->VMB_CONVAR <> 0)

		// ---------------- //
		// Analisa as pecas //
		// ---------------- //

		aCliCliente := OFNJD15CLI(cTTPEspCli, "P", VMB->VMB_NUMOSV )
		aCliConcess := OFNJD15CLI(cTTPEspCon, "P", VMB->VMB_NUMOSV )

		// Inicializa linha ...
		aAuxLinha := Array(Len(aHPeca)+1)
		For nCont := 1 to Len(aHPeca)
			aAuxLinha[nCont] := &("M->"+aHPeca[nCont,2])
		Next nCont
		aAuxLinha[Len(aAuxLinha)] := .f.
		//

		For nCont := 1 to Len(aVMCPeca)

			// Quantidade da Peca Retornada ...
			If aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] == 0
				Loop
			EndIf
			
			// Parte Cliente ...
			If VMB->VMB_CLIVAR <> 0
				nAuxPos := OFNJD15PECA( @aCols ,;
												nCont ,;
												cTTPEspCli ,;
												aCliCliente ,;
												OFNJD15038_verOpPeca(cTTPEspCli,cOperEsp,cOpEspInt) ,;
												OFNJD15048_verTESPeca(cTTPEspCli,cTESEsp,cTESEspInt),;
												VMB->VMB_CLIVAR,;
												nCliVarPer ,;
												@nTPecaCli,;
												aAuxLinha )
			EndIf

			// Parte Concessionario
			If VMB->VMB_CONVAR <> 0
				nAuxPos := OFNJD15PECA( @aCols ,;
												nCont ,;
												cTTPEspCon ,;
												aCliConcess ,;
												OFNJD15038_verOpPeca(cTTPEspCon,cOperEsp,cOpEspInt) ,;
												OFNJD15048_verTESPeca(cTTPEspCon,cTESEsp,cTESEspInt),;
												VMB->VMB_CONVAR,;
												nConVarPer ,;
												@nTPecaCon,;
												aAuxLinha )
			EndIf

		Next nCont

		nAuxPos := FG_POSVAR("PEC_VALPEC","aHPeca")
		aSort( aCols ,,, { |x,y| x[nAuxPos] > y[nAuxPos] } )

		// Se so tiver pecas e diferenca...
		// Tenta ajustar pelo valor do rateio...
		If !lTemSrvc .and. !lTemOutr

			If nTPecaCli <> VMB->VMB_CLIVAR

				nAuxDif := VMB->VMB_CLIVAR - nTPecaCli
				If nAuxDif > 0
					nAuxPos := aScan( aCols , { |x| x[FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCli .and. x[FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1 .and. x[FG_POSVAR("PEC_VALPEC","aHPeca")] > nAuxDif } )
				Else
					nAuxPos := aScan( aCols , { |x| x[FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCli .and. x[FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1 } )
				EndIf

				If nAuxPos <> 0
					aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] += nAuxDif
					aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")] += nAuxDif
					nTPecaCli += nAuxDif
				EndIf
			EndIf

			If nTPecaCon <> VMB->VMB_CONVAR
				nAuxDif := VMB->VMB_CONVAR - nTPecaCon
				If nAuxDif > 0
					nAuxPos := aScan( aCols , { |x| x[FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCon .and. x[FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1 .and. x[FG_POSVAR("PEC_VALPEC","aHPeca")] > nAuxDif } )
				Else
					nAuxPos := aScan( aCols , { |x| x[FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCon .and. x[FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1 } )
				EndIf

				If nAuxPos <> 0
					aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] += nAuxDif
					aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")] += nAuxDif
					nTPecaCon += nAuxDif
				EndIf
			EndIf
		EndIf

		// Verifica se tem problema de arredondamento
		If nTPeca <> (nTPecaCli + nTPecaCon + nTPecaJD)

			nAuxDif := nTPeca - (nTPecaCli + nTPecaCon + nTPecaJD)

			If nAuxDif > 0
				nAuxPos := aScan( aCols , { |x| x[FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1 .and. x[FG_POSVAR("PEC_VALPEC","aHPeca")] > nAuxDif } )
			Else
				nAuxPos := aScan( aCols , { |x| x[FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1 } )
			EndIf
			// Verifica se existe peca com qtde 1, se tiver acerta a diferenca nessas pecas ...
			If nAuxPos <> 0
				For nCont := 1 to Len(aCols)
					// Se for qtde 1 e o mesmo TT do cliente quando tiver parte de cliente ...
					If aCols[nCont,FG_POSVAR("PEC_QTDREQ","aHPeca")] == 1
						If aCols[nCont,FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCli .and. nTPecaCli <> 0 .and. nTPecaCli <> VMB->VMB_CLIVAR
							aCols[nCont,FG_POSVAR("PEC_VALPEC","aHPeca")] += nAuxDif
							aCols[nCont,FG_POSVAR("PEC_VALTOT","aHPeca")] += nAuxDif

							nTPecaCli += nAuxDif
							nAuxDif := 0
							Exit
						EndIf
						If aCols[nCont,FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCon .and. nTPecaCon <> 0 .and. nTPecaCon <> VMB->VMB_CONVAR
							aCols[nCont,FG_POSVAR("PEC_VALPEC","aHPeca")] += nAuxDif
							aCols[nCont,FG_POSVAR("PEC_VALTOT","aHPeca")] += nAuxDif

							nTPecaCon += nAuxDif
							nAuxDif := 0
							Exit
						EndIf
					EndIf
					//
				Next nCont
			EndIf
			//

			// Se ainda tiver diferenca ...
			If nAuxDif <> 0 .and. nTPecaCli <> 0

				nTruncar := 10 ** TamSX3("VO3_VALPEC")[2]

				For nAuxPos := 1 to Len(aCols)
					If aCols[nAuxPos,FG_POSVAR("PEC_TIPTEM","aHPeca")] == cTTPEspCli

						nAuxQtd     := aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")]
						nAuxVlrPeca := aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")]
						nAuxVlrTot  := aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")]

						nAuxVlrTot += nAuxDif

						If (Int( ( nAuxVlrTot / nAuxQtd ) * nTruncar ) / nTruncar) - (nAuxVlrTot / nAuxQtd) == 0
							nAuxVlrPeca := nAuxVlrTot / nAuxQtd
							nAuxVlrPeca := Round(nAuxVlrPeca,TamSX3("VO3_VALPEC")[2])
							aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] := nAuxVlrPeca
							aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")] := Round(aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] * nAuxVlrPeca,2)

							nTPecaCli += nAuxDif

							nAuxDif := 0

							Exit
						EndIf

					EndIf
				Next nAuxPos
			EndIf
			//

			If lDebug

				MsgInfo(;
					"nTPeca   : " + Str(nTPeca    ,10,2) + chr(13) + chr(10) + ;
					"nTPecaCal: " + Str(nTPecaCli + nTPecaCon+nTPecaJD,10,2) + chr(13) + chr(10) + chr(13) + CHR(10) +;
					"nTPecaCli: " + Str(nTPecaCli ,10,2) + chr(13) + chr(10) + ;
					"nTPecaCon: " + Str(nTPecaCon ,10,2) + chr(13) + chr(10) + ;
					"nTPecaJD : " + Str(nTPecaJD  ,10,2) + chr(13) + chr(10) )

			EndIf

		EndIf
		//

		aSort( aCols ,,, { |x,y| x[FG_POSVAR("PEC_TIPTEM","aHPeca")] + x[FG_POSVAR("PEC_GRUITE","aHPeca")] + x[FG_POSVAR("PEC_CODITE","aHPeca")] < y[FG_POSVAR("PEC_TIPTEM","aHPeca")]+y[FG_POSVAR("PEC_GRUITE","aHPeca")]+y[FG_POSVAR("PEC_CODITE","aHPeca")] } )

	EndIf

	nOpcGetDados := OFNJD15OPC("P",aCols,VMB->VMB_TIPGAR)

	// Adiciona linha em branco na aCols
	If Len(aCols) == 0
		AADD(aCols,Array(Len(aHPeca)+1))
		For nCont := 1 to Len(aHPeca)
			wVar  := "M->"+aHPeca[nCont,2]
			aCols[1,nCont] := &wVar
		Next nCont
		aCols[1,Len(aCols[1])] := .f.
	EndIf
	//

	cLinOk   := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"
	cFieldOk := "OFNJD15VGP()"
	cDelOk   := "OFNJD15010_VldDelPeca()"
	
	lTemPeca := .t.

	oGetPeca := MsNewGetDados():New( oSizeLBox:GetDimension("GETDADOS","LININI"),oSizeLBox:GetDimension("GETDADOS","COLINI"),oSizeLBox:GetDimension("GETDADOS","LINEND"),oSizeLBox:GetDimension("GETDADOS","COLEND"),;
			(nOpcGetDados),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
			cLinOk,;
			cTudoOk,;
			,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
			aAlter ,; 	// Campos alteraveis da GetDados
			/*nFreeze*/,;	// Campos estaticos da GetDados
			999,;
			cFieldOk,;
			/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
			cDelOk ,; 		// Funcao executada para validar a exclusao de uma linha
			oFAtuOS:aDialogs[nAuxFolder],;
			aHPeca,;
			aCols)
	oGetPeca:oBrowse:bChange := {|| FG_MEMVAR(oGetPeca:aHeader,oGetPeca:aCols,oGetPeca:nAt) }

	// Dispara FieldOk para os registros que foram processados ...
	For nCont := 1 to Len(oGetPeca:aCols)
		FG_MEMVAR(oGetPeca:aHeader,oGetPeca:aCols,nCont)

		// Dispara TES inteligente
		If !Empty(M->PEC_OPER) .and. !Empty(M->PEC_TIPTEM) .and. !Empty(M->PEC_FATPAR)
			OFNJD15VGP("M->PEC_OPER",nCont)
		ElseIf !Empty(M->PEC_CODTES)
			OFNJD15VGP("M->PEC_CODTES",nCont)
		EndIf
		//
	Next nCont
	//

EndIf

If Len(aVMCSrvc) > 0

	oFAtuOS:AddItem( STR0158 , .t. ) // ServiÁos
	nAuxFolder := Len(oFAtuOS:aDialogs)

	oSrvc := TWBrowse():New( oSizeLBox:GetDimension("LISTBOX","LININI") /* + 8 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","COLINI") /* + 2 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","XSIZE")  /* -04 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","YSIZE")  /* -10 */ ,,,,oFAtuOS:aDialogs[nAuxFolder],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_TIPTEM") , { || aVMCSrvc[oSrvc:nAt,01] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_LIBVOO") , { || aVMCSrvc[oSrvc:nAt,02] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_GRUSER") , { || aVMCSrvc[oSrvc:nAt,03] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_CODSER") , { || aVMCSrvc[oSrvc:nAt,04] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_TIPTRA") , { || aVMCSrvc[oSrvc:nAt,05] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_TIPTRD") , { || aVMCSrvc[oSrvc:nAt,06] },,,,"LEFT" 	,50,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_LOCTRA") , { || aVMCSrvc[oSrvc:nAt,07] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_QTDTRA") , { || Transform( aVMCSrvc[oSrvc:nAt,09] , PesqPict("VMC","VMC_QTDTRA") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_QSRRET") , { || Transform( aVMCSrvc[oSrvc:nAt,10] , PesqPict("VMC","VMC_QSRRET") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_VALHRE") , { || Transform( aVMCSrvc[oSrvc:nAt,11] , PesqPict("VMC","VMC_VALHRE") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_VALHRR") , { || Transform( aVMCSrvc[oSrvc:nAt,12] , PesqPict("VMC","VMC_VALHRR") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_VTSERE") , { || Transform( aVMCSrvc[oSrvc:nAt,13] , PesqPict("VMC","VMC_VTSERE") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oSrvc:AddColumn( TCColumn():New( RetTitle("VMC_VTSERR") , { || Transform( aVMCSrvc[oSrvc:nAt,14] , PesqPict("VMC","VMC_VTSERR") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )

	If !VMB->VMB_TIPGAR $ "ZZMK/ZPIP"
		oSrvc:AddColumn( TCColumn():New( STR0047            , { || IIf( aVMCSrvc[oSrvc:nAt,15] , oVermelho , oVerde ) } ,,,,"LEFT" ,30,.T.,.F.,,,,.F.,) ) // "Prob. Horas"
	EndIf
	oSrvc:nAt := 1
	oSrvc:SetArray(aVMCSrvc)
	oSrvc:Refresh()

	AADD( aCpoSrv , "VMC_TIPTRA" )
	AADD( aCpoSrv , "VMC_LOCTRA" )
	AADD( aCpoSrv , "VO4_TIPTEM" )
	AADD( aCpoSrv , "VO4_FATPAR" )
	AADD( aCpoSrv , "VO4_LOJA"   )
	AADD( aCpoSrv , "VO4_NOMCLI" )
	AADD( aCpoSrv , "VO4_GRUSER" )
	AADD( aCpoSrv , "VO4_CODSER" )
	AADD( aCpoSrv , "VO4_TIPSER" )
	AADD( aCpoSrv , "VO4_TEMPAD" )
	AADD( aCpoSrv , "VO4_VALHOR" )
	AADD( aCpoSrv , "VO4_VALSER" )
	AADD( aCpoSrv , "VO4_VALTOT" )
	AADD( aCpoSrv , "VO4_DEPGAR" )
	AADD( aCpoSrv , "VO4_DEPINT" )
	AADD( aCpoSrv , "VO4_CODSEC" )

	OFNJD15001_AdicionaCamposCustomizados(aCpoSrv, aCpoCustomizado, "SERVICOS")

	aHSrvc := {}
	aAlter := {}

	AADD( aHSrvc , { STR0209, "SER_STATUS" ,	"@!", 30,;
						0,     "AllWaysTrue()",		X3_USADO_EMUSO , 	"C",;
						"",		  "R",			"",	 				"" }) // Status
	M->SER_STATUS := Space(30)

	SX3->(dbSetOrder(2))
	For nCont := 1 to Len(aCpoSrv)

		cAuxCpo := "SER_" + Right(aCpoSrv[nCont],Len(aCpoSrv[nCont])-4)

		SX3->(dbSeek(aCpoSrv[nCont]))
		AADD( aHSrvc , { AllTrim(X3Titulo()), cAuxCpo ,	SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,     "AllWaysTrue()",		X3_USADO_EMUSO , 	SX3->X3_TIPO,;
						SX3->X3_F3,		  	 "R",			"",	 				"" })

		If !(aCpoSrv[nCont] $ "SER_VALTOT/SER_STATUS/SER_TIPTRA/SER_LOCTRA/SER_TIPTRA/SER_LOCTRA/VO4_TEMPAD/VO4_VALHOR/VO4_VALSER/VO4_VALTOT/")
			AADD(aAlter,cAuxCpo)
		EndIf

		wVar  := "M->"+cAuxCpo
		&wVar := CriaVar(SX3->X3_CAMPO,.f.)

		wVar := "M->"+aCpoSrv[nCont]
		&wVar := CriaVar(SX3->X3_CAMPO,.f.)

	Next nCont

	AADD( aHSrvc , { "Recno", "SER_RECNO" ,	"@ 9999999999", 10,;
						0,     "AllWaysTrue()",		X3_USADO_EMUSO , 	"N",;
						"",		  "R",			"",	 				"" }) // Recno


	aCols := {}

	// Analisa outros servicos ...
	For nCont := 1 to Len(aVMCSrvc)
		
		If    ( VMB->VMB_TIPGAR == "ZPIP" .AND. VMB->VMB_MREEMS <> 0 ) ; //  PMP Com Matriz de Reembolso 
		 .or. ( aVMCSrvc[nCont,_VMC_SRVC_NAOAPROVADO_] ) // Servico cortado pela fabrica

			AADD( aCols, Array(Len(aHSrvc)+1) )
			nAuxPos := Len(aCols)

			aVMCSrvc[nCont, _VMC_SRVC_POS_ACOLS_ ] := nAuxPos

			For nCont2 := 1 to Len(aHSrvc)
				wVar  := "M->"+aHSrvc[nCont2,2]
				aCols[nAuxPos,nCont2] := &wVar
			Next nCont2

			aCols[nAuxPos,FG_POSVAR("SER_TIPTRA","aHSrvc")] := aVMCSrvc[nCont,5]
			aCols[nAuxPos,FG_POSVAR("SER_LOCTRA","aHSrvc")] := aVMCSrvc[nCont,7]

			// Matriz de Reembolso
			If VMB->VMB_TIPGAR == "ZPIP" .AND. VMB->VMB_MREEMS <> 0 
				
				// Matriz de reembolso com 100% do cliente/concessionario
				If aVMCSrvc[nCont,_VMC_SRVC_NAOAPROVADO_]
					nHorasConsideradas := aVMCSrvc[nCont, _VMC_SRVC_HORASENVIADO_ ]

					aCols[nAuxPos,FG_POSVAR("SER_STATUS","aHSrvc")] := STR0210 + " (100%)" // "MATRIZ REEMBOLSO"
					aCols[nAuxPos,FG_POSVAR("SER_RECNO","aHSrvc")]  := aVMCSrvc[nCont,_VMC_SRVC_RECNO_]

				Else
					nHorasConsideradas := aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ]

					aCols[nAuxPos,FG_POSVAR("SER_GRUSER","aHSrvc")] := aVMCSrvc[nCont,03]
					aCols[nAuxPos,FG_POSVAR("SER_CODSER","aHSrvc")] := MV_PAR34

					aCols[nAuxPos,FG_POSVAR("SER_STATUS","aHSrvc")] := STR0210 // "MATRIZ REEMBOLSO"

				EndIf

				aCols[nAuxPos,FG_POSVAR("SER_TEMPAD","aHSrvc")] := nHorasConsideradas * 100

				nAuxVlrSrvc := VMB->VMB_MREEMS / nHorasConsideradas
				aCols[nAuxPos,FG_POSVAR("SER_VALHOR","aHSrvc")] := nAuxVlrSrvc
				aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")] := nHorasConsideradas * nAuxVlrSrvc
				aCols[nAuxPos,FG_POSVAR("SER_VALSER","aHSrvc")] := nHorasConsideradas * nAuxVlrSrvc
				//
			Else
				// Servico inteiro nao foi aprovado
				If aVMCSrvc[nCont,_VMC_SRVC_NAOAPROVADO_]
					aCols[nAuxPos,FG_POSVAR("SER_GRUSER","aHSrvc")] := aVMCSrvc[nCont,03]
					aCols[nAuxPos,FG_POSVAR("SER_CODSER","aHSrvc")] := aVMCSrvc[nCont,04]
					aCols[nAuxPos,FG_POSVAR("SER_TEMPAD","aHSrvc")] := aVMCSrvc[nCont, _VMC_SRVC_HORASENVIADO_ ] * 100
					aCols[nAuxPos,FG_POSVAR("SER_RECNO","aHSrvc")]  := aVMCSrvc[nCont,_VMC_SRVC_RECNO_]

					aCols[nAuxPos,FG_POSVAR("SER_TIPSER","aHSrvc")] := OFNJD15015_TipSerRequisicao(VMB->VMB_NUMOSV, aVMCSrvc[nCont, _VMC_SRVC_TIPTEM_], aVMCSrvc[nCont, _VMC_SRVC_GRUSER_], aVMCSrvc[nCont, _VMC_SRVC_CODSER_])

				Else
					aCols[nAuxPos,FG_POSVAR("SER_TEMPAD","aHSrvc")] := (aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] - aVMCSrvc[nCont, _VMC_SRVC_HORASENVIADO_ ]) * 100
					aCols[nAuxPos,FG_POSVAR("SER_RECNO","aHSrvc")]  := aVMCSrvc[nCont,_VMC_SRVC_RECNO_]
				EndIf
				//
			EndIf
			//
			If Empty(aCols[nAuxPos,FG_POSVAR("SER_STATUS","aHSrvc")])
				aCols[nAuxPos,FG_POSVAR("SER_STATUS","aHSrvc")] := FWNoAccent(STR0216) // "SERVI«O N√O APROVADO"
			EndIf
			//
			aCols[nAuxPos,Len(aCols[1])] := .f.

		EndIf
	Next nCont
	//
	If VMB->VMB_TIPGAR == "ZSPA"

		nVlrSer := 0
		nTSrvcCli := 0
		nTSrvcCon := 0

		For nProc := 1 to 2

			// Processa a parte do cliente
			If nProc == 1
				nVlrSer := VMB->VMB_CLIVAR
			// Processa a parte do concessionario
			ElseIf nProc == 2
				nVlrSer := VMB->VMB_CONVAR
			EndIf
			//

			//
			If nVlrSer == 0
				Loop
			EndIf
			//

			// Analisa as servicos ...
			AADD(aCols,Array(Len(aHSrvc)+1))
			nAuxPos := Len(aCols)
			For nCont2 := 1 to Len(aHSrvc)
				wVar  := "M->"+aHSrvc[nCont2,2]
				aCols[nAuxPos,nCont2] := &wVar
			Next nCont
			//

//				aCols[nAuxPos,FG_POSVAR("SER_TIPTRA","aHSrvc")] := aVMCSrvc[nCont,5]
//				aCols[nAuxPos,FG_POSVAR("SER_LOCTRA","aHSrvc")] := aVMCSrvc[nCont,7]

			If nProc == 1
				aCols[nAuxPos,FG_POSVAR("SER_TIPTEM","aHSrvc")] := cTTSEspCli
				aCols[nAuxPos,FG_POSVAR("SER_GRUSER","aHSrvc")] := cGSrEspCli
				aCols[nAuxPos,FG_POSVAR("SER_CODSER","aHSrvc")] := cCSrEspCli
				aCols[nAuxPos,FG_POSVAR("SER_TIPSER","aHSrvc")] := cTSrEspCli
			ElseIf nProc == 2
				aCols[nAuxPos,FG_POSVAR("SER_TIPTEM","aHSrvc")] := cTTSEspCon
				aCols[nAuxPos,FG_POSVAR("SER_GRUSER","aHSrvc")] := cGSrEspCon
				aCols[nAuxPos,FG_POSVAR("SER_CODSER","aHSrvc")] := cCSrEspCon
				aCols[nAuxPos,FG_POSVAR("SER_TIPSER","aHSrvc")] := cTSrEspCon
			EndIf


			aCliente := OFNJD15CLI(aCols[nAuxPos,FG_POSVAR("SER_TIPTEM","aHSrvc")], "S", VMB->VMB_NUMOSV )
			aCols[nAuxPos,FG_POSVAR("SER_FATPAR","aHSrvc")] := aCliente[1]
			aCols[nAuxPos,FG_POSVAR("SER_LOJA"  ,"aHSrvc")] := aCliente[2]
			aCols[nAuxPos,FG_POSVAR("SER_NOMCLI","aHSrvc")] := aCliente[3]

			aCols[nAuxPos,FG_POSVAR("SER_TEMPAD","aHSrvc")] := 0
			aCols[nAuxPos,FG_POSVAR("SER_VALHOR","aHSrvc")] := 0
			aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")] := 0

			aCols[nAuxPos,Len(aCols[1])] := .f.

			For nCont := 1 to Len(aVMCSrvc)

				aCols[nAuxPos,FG_POSVAR("SER_TEMPAD","aHSrvc")] += aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] * 100

//				nAuxVlrSrvc := aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] * aVMCSrvc[nCont,11] // Calcula o valor "enviado", a JD pode mudar a qtde de horas
//				nAuxVlrSrvc := nAuxVlrSrvc - aVMCSrvc[nCont,14]
//				nAuxVlrSrvc := nAuxVlrSrvc / aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ]
//				nAuxVlrSrvc := nAuxVlrSrvc * ( nVlrSer / nAuxTotEsp )
				nAuxVlrSrvc := (aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] * aVMCSrvc[nCont,11]) * ( nVlrSer / nAuxTotEsp )
				aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")] += nAuxVlrSrvc

			Next nCont

			aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")] := Round(aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")],2)

			If nProc == 1
				nTSrvcCli := aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")]
			// Acerta o valor do servico se tiver alguma diferenca
			Else
				nTSrvcCon := aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")]
//				aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")] += nTSrvc - (nTSrvcCli + nTSrvcJD + nTSrvcCon)
//				nTSrvcCon := aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")]
			EndIf

			aCols[nAuxPos,FG_POSVAR("SER_VALHOR","aHSrvc")] := (aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")] / ( aCols[nAuxPos,FG_POSVAR("SER_TEMPAD","aHSrvc")] / 100 ))

		Next nProc

		// Acerta o valor fixo do servico
		For nAuxPos := 1 to Len(aCols)
			aCols[nAuxPos,FG_POSVAR("SER_VALSER","aHSrvc")] := aCols[nAuxPos,FG_POSVAR("SER_VALTOT","aHSrvc")]
		Next nAuxPos
		//

		If lDebug
			MsgInfo(;
			"nTSrvc   : " + Str(nTSrvc   ,10,2) + chr(13) + CHR(10) +;
			"nTotCalc : " + Str(nTSrvcCli + nTSrvcJD + nTSrvcCon ,10,2) + chr(13) + CHR(10) +chr(13) + CHR(10) +;
			"nTSrvcCli: " + Str(nTSrvcCli,10,2) + chr(13) + CHR(10) +;
			"nTSrvcJD : " + Str(nTSrvcJD ,10,2) + chr(13) + CHR(10) +;
			"nTSrvcCon: " + Str(nTSrvcCon,10,2) + chr(13) + CHR(10) )
		EndIf

	EndIf

	nOpcGetDados := OFNJD15OPC("S",aCols,VMB->VMB_TIPGAR)

	// Adiciona linha em branco na aCols
	If Len(aCols) == 0
		AADD(aCols,Array(Len(aHSrvc)+1))
		For nCont := 1 to Len(aHSrvc)
			wVar  := "M->"+aHSrvc[nCont,2]
			aCols[1,nCont] := &wVar
		Next nCont
		aCols[1,Len(aCols[1])] := .f.
	EndIf
	//

	cLinOk   := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"
	cFieldOk := "OFNJD15VGS()"
	cDelOk   := "OFNJD15013_VldDelSrvc()"

	lTemSrvc := .t.

	oGetSrvc := MsNewGetDados():New( oSizeLBox:GetDimension("GETDADOS","LININI"),oSizeLBox:GetDimension("GETDADOS","COLINI"),oSizeLBox:GetDimension("GETDADOS","LINEND"),oSizeLBox:GetDimension("GETDADOS","COLEND"),;
			(nOpcGetDados),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
			cLinOk,;
			cTudoOk,;
			,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
			aAlter ,; 	// Campos alteraveis da GetDados
			/*nFreeze*/,;	// Campos estaticos da GetDados
			999,;
			cFieldOk,;
			/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
			cDelOk ,; 		// Funcao executada para validar a exclusao de uma linha
			oFAtuOS:aDialogs[nAuxFolder],;
			aHSrvc,;
			aCols)
	oGetSrvc:oBrowse:bChange := {|| FG_MEMVAR(oGetSrvc:aHeader,oGetSrvc:aCols,oGetSrvc:nAt) }

	// Dispara FieldOk para os registros que foram processados ...
	For nCont := 1 to Len(oGetSrvc:aCols)
		FG_MEMVAR(oGetSrvc:aHeader,oGetSrvc:aCols,nCont)

		// Se encontrar TT e nao encontrar Faturar Para..
		If !Empty(M->SER_TIPTEM) .and. Empty(M->SER_FATPAR)
			OFNJD15VGS("M->SER_FATPAR",nCont)
		EndIf
		//

	Next nCont
	//

	// SG de Revisao/PMP nao tem motivo de manipular as requisicoes
//	If VMB->VMB_TIPGAR $ "ZZMK/ZPIP"
	If VMB->VMB_TIPGAR $ "ZZMK"
		oGetSrvc:Disable()
	EndIf


EndIf

If Len(aVMCOutr) > 0

	oFAtuOS:AddItem( STR0206 , .t. ) // Outros CrÈditos
	nAuxFolder := Len(oFAtuOS:aDialogs)

	oOutr := TWBrowse():New( oSizeLBox:GetDimension("LISTBOX","LININI") /* + 8 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","COLINI") /* + 2 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","XSIZE")  /* -04 */ ,;
							 oSizeLBox:GetDimension("LISTBOX","YSIZE")  /* -10 */ ,,,,oFAtuOS:aDialogs[nAuxFolder],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_TIPTEM") , { || aVMCOutr[oOutr:nAt,01] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_LIBVOO") , { || aVMCOutr[oOutr:nAt,02] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_GRUSER") , { || aVMCOutr[oOutr:nAt,03] },,,,"LEFT" 	,30,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_CODSER") , { || aVMCOutr[oOutr:nAt,04] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_CODMAT") , { || aVMCOutr[oOutr:nAt,05] },,,,"LEFT" 	,40,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_CODMAD") , { || aVMCOutr[oOutr:nAt,06] },,,,"LEFT" 	,50,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_CUSMAT") , { || Transform( aVMCOutr[oOutr:nAt,07] , PesqPict("VMC","VMC_CUSMAT") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_CUSMAR") , { || Transform( aVMCOutr[oOutr:nAt,08] , PesqPict("VMC","VMC_CUSMAR") )} ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )
	oOutr:AddColumn( TCColumn():New( STR0048                , { || IIf( aVMCOutr[oOutr:nAt,10] , oVermelho , oVerde ) } ,,,,"LEFT" ,30,.T.,.F.,,,,.F.,) ) // "Prob. Valor"
	oOutr:AddColumn( TCColumn():New( RetTitle("VMC_COMENT") , { || aVMCOutr[oOutr:nAt,09] },,,,"LEFT" 	,100,.F.,.F.,,,,.F.,) )
	oOutr:nAt := 1
	oOutr:SetArray(aVMCOutr)
	oOutr:Refresh()

	AADD( aCpoOut , "VMC_CODMAT" )
	AADD( aCpoOut , "VO4_TIPTEM" )
	AADD( aCpoOut , "VO4_FATPAR" )
	AADD( aCpoOut , "VO4_LOJA"   )
	AADD( aCpoOut , "VO4_NOMCLI" )
	AADD( aCpoOut , "VO4_GRUSER" )
	AADD( aCpoOut , "VO4_CODSER" )
	AADD( aCpoOut , "VO4_TIPSER" )
	AADD( aCpoOut , "VO4_DEPGAR" )
	AADD( aCpoOut , "VO4_DEPINT" )
	AADD( aCpoOut , "VO4_KILROD" )
	AADD( aCpoOut , "VO4_PREKIL" )
	AADD( aCpoOut , "VO4_CODSEC" )
	AADD( aCpoOut , "VO4_VALVEN" )
	AADD( aCpoOut , "VO4_VALTOT" )

	OFNJD15001_AdicionaCamposCustomizados(aCpoOut, aCpoCustomizado, "OUTROSCREDITOS")

	AADD( aCpoOut , "VMC_NRECNO" )

	aHOutr := {}
	aAlter := {}

	AADD( aHOutr , { STR0209, "OUT_STATUS" ,	"@!", 30,;
						0,     "AllWaysTrue()",		X3_USADO_EMUSO , 	"C",;
						"",		  "R",			"",	 				"" }) // Status
	M->OUT_STATUS := Space(30)

	SX3->(dbSetOrder(2))
	For nCont := 1 to Len(aCpoOut)

		cAuxCpo := "OUT_" + Right(aCpoOut[nCont],Len(aCpoOut[nCont])-4)

		If "NRECNO" $ aCpoOut[nCont]
			AADD( aHOutr , { "RECNO", cAuxCpo ,	"@E 9999999999"	,		10,;
							0,     	"AllWaysTrue()",		X3_USADO_EMUSO , 	"N",;
							"",		  	 "R",			"","" })
		Else
			SX3->(dbSeek(aCpoOut[nCont]))
			AADD( aHOutr , { AllTrim(X3Titulo()), cAuxCpo ,	SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,     "AllWaysTrue()",		X3_USADO_EMUSO , 	SX3->X3_TIPO,;
							SX3->X3_F3,		  	 "R",			"","" })
		EndIf

		If !(aCpoOut[nCont] $ "VO4_VALTOT/VMC_NRECNO/VO4_KILROD/VO4_PREKIL/VO4_VALVEN/VO4_VALTOT")
			AADD(aAlter,cAuxCpo)
		EndIf

		wVar  := "M->"+cAuxCpo
		&wVar := CriaVar(SX3->X3_CAMPO,.f.)

		wVar := "M->"+aCpoOut[nCont]
		&wVar := CriaVar(SX3->X3_CAMPO,.f.)

	Next nCont

	aCols := {}

	// Analisa outros servicos ...
	For nCont := 1 to Len(aVMCOutr)
		// Outros creditos retornados no warrmemo e que n„o foram enviados na SolicitaÁ„o de Garantia ...
		If (aVMCOutr[nCont,_VMC_OUTR_PROBVALOR_] .and. Empty(aVMCOutr[nCont,_VMC_OUTR_TIPTEM_])) ;
		   .or. aVMCOutr[nCont,_VMC_OUTR_NAOTRANSMITIDO_] ;
		   .or. aVMCOutr[nCont,_VMC_OUTR_NAOAPROVADO_]


			AADD( aCols, Array(Len(aHOutr)+1) )
			nAuxPos := Len(aCols)

			For nCont2 := 1 to Len(aHOutr)-1
				wVar  := "M->"+aHOutr[nCont2,2]
				aCols[nAuxPos,nCont2] := &wVar
			Next nCont2

			If aVMCOutr[nCont,_VMC_OUTR_NAOTRANSMITIDO_]
				aCols[nAuxPos,FG_POSVAR("OUT_STATUS","aHOutr")] := FWNoAccent(STR0217) // "SERVI«O N√O TRANSMITIDO"
			EndIf

			If aVMCOutr[nCont,_VMC_OUTR_NAOAPROVADO_]
				aCols[nAuxPos,FG_POSVAR("OUT_STATUS","aHOutr")] := FWNoAccent(STR0216) // "SERVI«O N√O APROVADO"
			EndIf

			aCols[nAuxPos,FG_POSVAR("OUT_CODMAT","aHOutr")] := aVMCOutr[nCont,5]

			// Deslocamento
			If AllTrim(aVMCOutr[nCont,5]) $ "WTYSUBL5/WTYSUBL6/WTYSUBL8"
				aCols[nAuxPos,FG_POSVAR("OUT_KILROD","aHOutr")] := 1
				aCols[nAuxPos,FG_POSVAR("OUT_PREKIL","aHOutr")] := aVMCOutr[nCont, _VMC_OUTR_CUSMAR_ ]
				aCols[nAuxPos,FG_POSVAR("OUT_VALVEN","aHOutr")] := aVMCOutr[nCont, _VMC_OUTR_CUSMAR_ ]
				aCols[nAuxPos,FG_POSVAR("OUT_VALTOT","aHOutr")] := aVMCOutr[nCont, _VMC_OUTR_CUSMAR_ ]
			Else
				aCols[nAuxPos,FG_POSVAR("OUT_VALVEN","aHOutr")] := aVMCOutr[nCont, _VMC_OUTR_CUSMAR_ ]
			EndIf
			aCols[nAuxPos,FG_POSVAR("OUT_NRECNO","aHOutr")] := aVMCOutr[nCont,12]
			aCols[nAuxPos,Len(aCols[1])] := .f.

			// Se for PMP e for Deslocamento...
			If VMB->VMB_TIPGAR == "ZPIP" .and. AllTrim(aVMCOutr[nCont,5]) $ "WTYSUBL8"
				aCols[nAuxPos,FG_POSVAR("OUT_TIPTEM","aHOutr")] := cTTSerPMP
				aCols[nAuxPos,FG_POSVAR("OUT_GRUSER","aHOutr")] := cGSerDesloc
				aCols[nAuxPos,FG_POSVAR("OUT_CODSER","aHOutr")] := cCSerDesloc
				aCols[nAuxPos,FG_POSVAR("OUT_TIPSER","aHOutr")] := cTSerDesloc
				aCols[nAuxPos,FG_POSVAR("OUT_CODSEC","aHOutr")] := cCodSecPMP
				aCols[nAuxPos,FG_POSVAR("OUT_DEPGAR","aHOutr")] := cDepGarPMP
			EndIf
			//
			
			If aVMCOutr[nCont,_VMC_OUTR_NAOAPROVADO_]
				aCols[nAuxPos,FG_POSVAR("OUT_GRUSER","aHOutr")] := aVMCOutr[nCont,_VMC_OUTR_GRUSER_]
				aCols[nAuxPos,FG_POSVAR("OUT_CODSER","aHOutr")] := aVMCOutr[nCont,_VMC_OUTR_CODSER_]
			EndIf

		EndIf
	Next nCont
	//

	If VMB->VMB_TIPGAR == "ZSPA"

		nVlrOutros := 0
		nTOutrCli := 0
		nTOutrCon := 0

		For nProc := 1 to 2

			// Processa a parte do cliente
			If nProc == 1
				nVlrOutros := VMB->VMB_CLIVAR
			// Processa a parte do concessionario
			ElseIf nProc == 2
				nVlrOutros := VMB->VMB_CONVAR
			EndIf
			//

			If nVlrOutros == 0
				Loop
			EndIf

			// Adiciona um servico na aCols ...
			AADD(aCols,Array(Len(aHOutr)+1))
			nAuxPos := Len(aCols)
			For nCont2 := 1 to Len(aHOutr)-1
				wVar  := "M->"+aHOutr[nCont2,2]
				aCols[nAuxPos,nCont2] := &wVar
			Next nCont
			aCols[nAuxPos,FG_POSVAR("OUT_NRECNO","aHOutr")] := 0
			//

			If nProc == 1
				aCols[nAuxPos,FG_POSVAR("OUT_TIPTEM","aHOutr")] := cTTSEspCli
				aCols[nAuxPos,FG_POSVAR("OUT_GRUSER","aHOutr")] := cGOuEspCli
				aCols[nAuxPos,FG_POSVAR("OUT_CODSER","aHOutr")] := cCOuEspCli
				aCols[nAuxPos,FG_POSVAR("OUT_TIPSER","aHOutr")] := cTOuEspCli
			ElseIf nProc == 2
				aCols[nAuxPos,FG_POSVAR("OUT_TIPTEM","aHOutr")] := cTTSEspCon
				aCols[nAuxPos,FG_POSVAR("OUT_GRUSER","aHOutr")] := cGOuEspCon
				aCols[nAuxPos,FG_POSVAR("OUT_CODSER","aHOutr")] := cCOuEspCon
				aCols[nAuxPos,FG_POSVAR("OUT_TIPSER","aHOutr")] := cTOuEspCon
			EndIf

			aCliente := OFNJD15CLI(aCols[nAuxPos,FG_POSVAR("OUT_TIPTEM","aHOutr")], "S", VMB->VMB_NUMOSV )
			aCols[nAuxPos,FG_POSVAR("OUT_FATPAR","aHOutr")] := aCliente[1]
			aCols[nAuxPos,FG_POSVAR("OUT_LOJA"  ,"aHOutr")] := aCliente[2]
			aCols[nAuxPos,FG_POSVAR("OUT_NOMCLI","aHOutr")] := aCliente[3]

			//aCols[nAuxPos,FG_POSVAR("OUT_CODSEC","aHOutr")] := "001"

			aCols[nAuxPos,Len(aCols[1])] := .f.

			For nCont := 1 to Len(aVMCOutr)

//				If AllTrim(aVMCOutr[nCont,5]) $ "WTYSUBL2/WTYSUBL7"
				If !(AllTrim(aVMCOutr[nCont,5]) $ "WTYSUBL5/WTYSUBL6/WTYSUBL8")

//					nAuxVlrSrvc := aVMCOutr[nCont,7] - aVMCOutr[nCont,8]
//					nAuxVlrSrvc := Round(nAuxVlrSrvc * ( nVlrOutros / nAuxTotEsp ),2)

					nAuxVlrSrvc := Round(aVMCOutr[nCont,7] * ( nVlrOutros / nAuxTotEsp ),2)

					aCols[nAuxPos,FG_POSVAR("OUT_VALVEN","aHOutr")] += nAuxVlrSrvc

				EndIf

			Next nCont

			If nProc == 1
				nTOutrCli := aCols[nAuxPos,FG_POSVAR("OUT_VALVEN","aHOutr")]
			Else
				nTOutrCon := aCols[nAuxPos,FG_POSVAR("OUT_VALVEN","aHOutr")]
			EndIf

		Next nProc

		If lDebug
			MsgInfo(;
				"nTOutr   : " + Str(nTOutr   ,10,2) + chr(13) + CHR(10) +;
				"nTotCalc : " + Str(nTOutrCli + nTOutrJD + nTOutrCon ,10,2) + chr(13) + CHR(10) +;
				"nTOutrCli: " + Str(nTOutrCli,10,2) + chr(13) + CHR(10) +;
				"nTOutrJD : " + Str(nTOutrJD ,10,2) + chr(13) + CHR(10) +;
				"nTOutrCon: " + Str(nTOutrCon,10,2) + chr(13) + CHR(10) )
		EndIf

	EndIf

	nOpcGetDados := OFNJD15OPC("O",aCols,VMB->VMB_TIPGAR)

	// Adiciona linha em branco na aCols
	If Len(aCols) == 0
		AADD(aCols,Array(Len(aHOutr)+1))
		For nCont := 1 to Len(aHOutr)-1
			wVar  := "M->"+aHOutr[nCont,2]
			aCols[1,nCont] := &wVar
		Next nCont
		aCols[1,Len(aCols[1])] := .f.
	EndIf
	//

	cLinOk   := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"
	cFieldOk := "OFNJD15VGO()"
	cDelOk   := "OFNJD15016_VldDelOutrosCred()"

	lTemOutr := .t.

	oGetOutr := MsNewGetDados():New( oSizeLBox:GetDimension("GETDADOS","LININI"),oSizeLBox:GetDimension("GETDADOS","COLINI"),oSizeLBox:GetDimension("GETDADOS","LINEND"),oSizeLBox:GetDimension("GETDADOS","COLEND"),;
			(nOpcGetDados),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
			cLinOk,;
			cTudoOk,;
			,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
			aAlter ,; 	// Campos alteraveis da GetDados
			/*nFreeze*/,;	// Campos estaticos da GetDados
			999,;
			cFieldOk,;
			/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
			cDelOk ,; 		// Funcao executada para validar a exclusao de uma linha
			oFAtuOS:aDialogs[nAuxFolder],;
			aHOutr,;
			aCols)
	oGetOutr:oBrowse:bChange := {|| FG_MEMVAR(oGetOutr:aHeader,oGetOutr:aCols,oGetOutr:nAt) }

	// Dispara FieldOk para os registros que foram processados ...
	For nCont := 1 to Len(oGetOutr:aCols)
		FG_MEMVAR(oGetOutr:aHeader,oGetOutr:aCols,nCont)

		// Se encontrar TT e nao encontrar Faturar Para..
		If !Empty(M->OUT_TIPTEM) .and. Empty(M->OUT_FATPAR)
			OFNJD15VGO("M->OUT_TIPTEM",nCont)
		EndIf
		//

	Next nCont
	//


EndIf

// Se for garantia especial, verifica se os valores estao corretos ...
If VMB->VMB_TIPGAR == "ZSPA"

	nAuxDif := 0

	nCliParte := M->VMB_CLIVAR
	If nCliParte <> (nTPecaCli + nTSrvcCli + nTOutrCli)
		nPos := 0
		lProcDif := .f.

		If lTemSrvc
			nPos := aScan(oGetSrvc:aCols,{ |x| x[FG_POSVAR("SER_TIPTEM","aHSrvc")] == cTTSEspCli .and. x[FG_POSVAR("SER_CODSER","aHSrvc")] == cCSrEspCli } )
			If nPos <> 0
				oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALTOT","aHSrvc")] += nCliParte - (nTPecaCli + nTSrvcCli + nTOutrCli)
				oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALSER","aHSrvc")] := oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALTOT","aHSrvc")]

				nTSrvcCli := oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALTOT","aHSrvc")]
				lProcDif := .t.
			EndIf
		EndIf

		If !lProcDif .and. lTemOutr
			nPos := aScan(oGetOutr:aCols,{ |x| x[FG_POSVAR("OUT_TIPTEM","aHOutr")] == cTTSEspCli .and. x[FG_POSVAR("OUT_CODSER","aHOutr")] == cCOuEspCli } )
			If nPos <> 0
				oGetOutr:aCols[nPos,FG_POSVAR("OUT_VALVEN","aHOutr")] += nCliParte - (nTPecaCli + nTSrvcCli + nTOutrCli)

				nTOutrCli := oGetOutr:aCols[nPos,FG_POSVAR("OUT_VALVEN","aHOutr")]

			EndIf
		EndIf
	EndIf


	nConParte := M->VMB_CONVAR
	If nConParte <> (nTPecaCon + nTSrvcCon + nTOutrCon)
		nPos := 0
		lProcDif := .f.

		If lTemSrvc
			nPos := aScan(oGetSrvc:aCols,{ |x| x[FG_POSVAR("SER_TIPTEM","aHSrvc")] == cTTSEspCon .and. x[FG_POSVAR("SER_CODSER","aHSrvc")] == cCSrEspCon } )
			If nPos <> 0
				oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALTOT","aHSrvc")] += nConParte - (nTPecaCon + nTSrvcCon + nTOutrCon)
				oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALSER","aHSrvc")] := oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALTOT","aHSrvc")]

				nTSrvcCon := oGetSrvc:aCols[nPos,FG_POSVAR("SER_VALTOT","aHSrvc")]
				lProcDif := .t.
			EndIf
		EndIf

		If !lProcDif .and. lTemOutr
			nPos := aScan(oGetOutr:aCols,{ |x| x[FG_POSVAR("OUT_TIPTEM","aHOutr")] == cTTSEspCon .and. x[FG_POSVAR("OUT_CODSER","aHOutr")] == cCOuEspCon } )
			If nPos <> 0
				oGetOutr:aCols[nPos,FG_POSVAR("OUT_VALVEN","aHOutr")] += nConParte - (nTPecaCon + nTSrvcCon + nTOutrCon)

				nTOutrCon := oGetOutr:aCols[nPos,FG_POSVAR("OUT_VALVEN","aHOutr")]
			EndIf
		EndIf
	EndIf

	If lDebug
		MsgInfo(;
				"nTPeca   : " + Str(nTPeca    ,10,2) + chr(13) + chr(10) + ;
				"nTotCalc : " + Str(nTPecaCli + nTPecaCon+nTPecaJD,10,2) + chr(13) + chr(10) + ;
				"nTPecaCli: " + Str(nTPecaCli ,10,2) + chr(13) + chr(10) + ;
				"nTPecaCon: " + Str(nTPecaCon ,10,2) + chr(13) + chr(10) + ;
				"nTPecaJD : " + Str(nTPecaJD  ,10,2) + chr(13) + chr(10) + chr(13) + chr(10) + ;
				"nTSrvc   : " + Str(nTSrvc   ,10,2) + chr(13) + CHR(10) +;
				"nTotCalc : " + Str(nTSrvcCli + nTSrvcJD + nTSrvcCon ,10,2) + chr(13) + CHR(10) +;
				"nTSrvcCli: " + Str(nTSrvcCli,10,2) + chr(13) + CHR(10) +;
				"nTSrvcJD : " + Str(nTSrvcJD ,10,2) + chr(13) + CHR(10) +;
				"nTSrvcCon: " + Str(nTSrvcCon,10,2) + chr(13) + CHR(10) + chr(13) + chr(10) + ;
				"nTOutr   : " + Str(nTOutr   ,10,2) + chr(13) + CHR(10) +;
				"nTotCalc : " + Str(nTOutrCli + nTOutrJD + nTOutrCon ,10,2) + chr(13) + CHR(10) +;
				"nTOutrCli: " + Str(nTOutrCli,10,2) + chr(13) + CHR(10) +;
				"nTOutrJD : " + Str(nTOutrJD ,10,2) + chr(13) + CHR(10) +;
				"nTOutrCon: " + Str(nTOutrCon,10,2) + chr(13) + CHR(10) + chr(13) + chr(10) + ;
				"Cliente: "          + Str(nCliParte                    ,10,2) + chr(13) + chr(10) +;
				"Cliente Calc: "     + Str(nTPecaCli + nTSrvcCli + nTOutrCli,10,2) + chr(13) + chr(10) +;
				"Conc.: "            + Str(nConParte                    ,10,2) + chr(13) + chr(10) +;
				"Conc. Calc:"        + Str(nTPecaCon + nTSrvcCon + nTOutrCon,10,2) + chr(13) + chr(10) +;
				"John Deere: "       + Str(M->VMB_JDVAR                     ,10,2) + chr(13) + chr(10) +;
				"John Deere Calc.: " + Str(nTPecaJD + nTSrvcJD + nTOutrJD   ,10,2) + chr(13) + chr(10) )

	EndIf

EndIf
//

oFAtuOS:SetOption(1)

lOK := .f.

If lDebug
	AADD( aNewBot , { "PMSCOLOR", {|| OFNJD15IC() } , STR0159 } ) // "Imp. Conferencia"
EndIf

// Verifica se alguma peÁa foi cortada...
cErro := ""
For nAuxPos := 1 to Len(aVMCPeca)
	If aVMCPeca[nAuxPos,_VMC_PECA_PROBQTDE_] // Problema com Qtde
		cErro += aVMCPeca[nAuxPos,03] + " - " + aVMCPeca[nAuxPos,04] + " - " + AllTrim(aVMCPeca[nAuxPos,05]) + CHR(13) + CHR(10)
	EndIf
Next nAuxPos
If !Empty(cErro)
	Aviso(STR0111,STR0160 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // AtenÁ„o / "AtenÁ„o para a quantidade aprovada das peÁa(s) abaixo:"
			RetTitle("VMC_GRUITE") + " - " + RetTitle("VMC_CODITE") + " - " + RetTitle("VMC_DESCRI") + CHR(13) + CHR(10) + ;
			cErro, { STR0146 } , 3) // Ok
EndIf
//
If lMReemb
	MsgAlert(STR0239, STR0111) // "PMP com matriz de reembolso."
EndIf

If lMReemb100
	MsgAlert(STR0240, STR0111) // "PMP com matriz de reembolso de 100%."
EndIf

If Len(aNewBot) > 0
	ACTIVATE MSDIALOG oDlgAtuOS ON INIT EnchoiceBar(oDlgAtuOS,{ || IIf(OFNJD15PA(),oDlgAtuOS:End(),) },{||oDlgAtuOS:End()},,aNewBot)
Else
	ACTIVATE MSDIALOG oDlgAtuOS ON INIT EnchoiceBar(oDlgAtuOS,{ || IIf(OFNJD15PA(),oDlgAtuOS:End(),) },{||oDlgAtuOS:End()})
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15PECA ∫ Autor ≥ Rubens            ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Adiciona a linha de peca na getdados do processamento da   ∫±±
±±∫          ≥ atualizacao da Ordem de Servico                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15PECA( aCols, nPosVMCPeca, cTTVMCPeca, aAuxCliente, cOperEsp, cTESEsp, nValParte, nPerParte, nTotCliCon , aAuxLinha)

Local nAuxPos
Local nAuxQtd

AADD(aCols,aClone(aAuxLinha))
nAuxPos := Len(aCols)

aCols[nAuxPos,FG_POSVAR("PEC_TIPTEM","aHPeca")] := cTTVMCPeca
aCols[nAuxPos,FG_POSVAR("PEC_GRUITE","aHPeca")] := aVMCPeca[nPosVMCPeca,03]
aCols[nAuxPos,FG_POSVAR("PEC_CODITE","aHPeca")] := aVMCPeca[nPosVMCPeca,04]
aCols[nAuxPos,FG_POSVAR("PEC_UM","aHPeca")] := aVMCPeca[nPosVMCPeca,_VMC_PECA_UMPARACONVERSAO_]

If !Empty(aAuxCliente[1])
	aCols[nAuxPos,FG_POSVAR("PEC_FATPAR","aHPeca")] := aAuxCliente[1]
	aCols[nAuxPos,FG_POSVAR("PEC_LOJA"  ,"aHPeca")] := aAuxCliente[2]
	aCols[nAuxPos,FG_POSVAR("PEC_NOMCLI","aHPeca")] := aAuxCliente[3]
EndIf

aCols[nAuxPos,FG_POSVAR("PEC_OPER","aHPeca")]   := cOperEsp
aCols[nAuxPos,FG_POSVAR("PEC_CODTES","aHPeca")] := cTESEsp

// Houve conversao de unidade de medida na transmissao
If aVMCPeca[nPosVMCPeca,_VMC_PECA_CONVUM_]
	nAuxQtd := aVMCPeca[nPosVMCPeca,_VMC_PECA_QTDRET1UM_]
Else
	nAuxQtd := aVMCPeca[nPosVMCPeca,_VMC_PECA_QTDPECRETORNADA_]
EndIf
aCols[nAuxPos,FG_POSVAR("PEC_QTDREQ","aHPeca")] := nAuxQtd
//

// Se o Valor da Parte for igual ao da JD, considera os valores da JD
If nValParte == VMB->VMB_JDVAR
	nAuxVlrPeca := aVMCPeca[nPosVMCPeca,12] / nAuxQtd
Else
	// Peca de Outra Marca ... Paga como Outros Creditos
	If aVMCPeca[nPosVMCPeca,21]
		nAuxVlrPeca := aVMCPeca[nPosVMCPeca,_VMC_PECA_QTDPECRETORNADA_] * aVMCPeca[nPosVMCPeca,09]
		nAuxVlrPeca := nAuxVlrPeca * nPerParte // ( VMB->VMB_CLIVAR / nAuxTotEsp )
		nAuxVlrPeca := nAuxVlrPeca / aVMCPeca[nPosVMCPeca,_VMC_PECA_QTDPECRETORNADA_]
	Else
		nAuxVlrPeca := aVMCPeca[nPosVMCPeca,10] * nPerParte // * ( VMB->VMB_CLIVAR / nAuxTotEsp )
	EndIf
	//
EndIf

// Se for quantidade UM tem que arredondar com 2 casas decimais ...
If aVMCPeca[nPosVMCPeca,_VMC_PECA_QTDPECRETORNADA_] == 1
	nAuxVlrPeca := Round(nAuxVlrPeca,2)
Else
	nAuxVlrPeca := Round(nAuxVlrPeca,TamSX3("VO3_VALPEC")[2])
EndIf

aCols[nAuxPos,FG_POSVAR("PEC_VALPEC","aHPeca")] := nAuxVlrPeca
aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")] := Round( nAuxQtd * nAuxVlrPeca ,2)

nTotCliCon += aCols[nAuxPos,FG_POSVAR("PEC_VALTOT","aHPeca")]

Return nAuxPos


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15PA ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Processa atualizaÁ„o da Ordem de ServiÁo                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15PA()

Local nPos
Local aProcTT := {}
Local cMsgTT := ""
Local lSer5000 := .f.

Private lProc := .f.

// Valida os Tipos de Tempos de Pecas Informados ...
If lTemPeca
	VOI->(dbSetOrder(1))
	For nPos := 1 to Len(aVMCPeca)
		OFNJD15VTT( aVMCPeca[nPos,01] , @aProcTT , @cMsgTT )
	Next nPos

	For nPos := 1 to Len(oGetPeca:aCols)
		If oGetPeca:aCols[nPos,Len(oGetPeca:aCols[nPos])] .or. Empty(oGetPeca:aCols[nPos,FG_POSVAR("PEC_CODITE","aHPeca")])
			Loop
		EndIf
		OFNJD15VTT( oGetPeca:aCols[nPos,FG_POSVAR("PEC_TIPTEM","aHPeca")] , @aProcTT , @cMsgTT )
	Next nPos

	If !Empty(cMsgTT)
		MsgStop(STR0161 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +; // Foram utilizados um ou mais tipos de tempos com configuraÁ„o de valor de peÁa errado. Deve ser utilizado tipo de tempo que considera o valor da peÁa do momento da requisiÁ„o (VOI_VLPCAC = '2').
			STR0162 + " " + CHR(13) + CHR(10) + cMsgTT , STR0111 ) // Verifique a configuraÁ„o dos tipos de tempos abaixo:
		Return .f.
	EndIf
EndIf
//

If !MsgNoYes(STR0049) // "Confirma atualizaÁ„o da OS"
	Return .f.
EndIf

If OFNJD15SERIE5000()
	lRetAviso := Aviso(STR0111,;
                       STR0163,; // Esta solicitaÁ„o de garantia possui um valor de serviÁo menor do que R$ 1,00. Deseja gerar nota fiscal ou finalizar a Ordem de ServiÁo como M„o de Obra Gratuita?
                       { STR0164 , "M.O. Grat." , STR0165 }, 3) // Nota Fiscal / Cancelar
	If lRetAviso == 1
		lSer5000 := .f.
	ElseIf lRetAviso == 2
		If Empty(MV_PAR41)
			MsgInfo(STR0166) // Parametro de tipo de serviÁo de M„o de Obra gratuita n„o foi informado. Por favor, acesse a tela de par‚metros da rotina (Bot„o F12) e informe o par‚metro 'Tipo de ServiÁo Gratuito'.
			Return .f.
		EndIf
		lSer5000 := .t.
	Else
		Return .f.
	Endif
EndIf

oProcJD := MsNewProcess():New( { |lEnd| lProc := OFNJD15AOS(lSer5000) } , STR0001 , "" , .T. )
oProcJD:Activate()

Return lProc

/*/{Protheus.doc} OFNJD15SERIE5000
Retorna se a solicitaÁ„o de garantia È da Serie 5000
@author Rubens
@since 16/08/2017
@version undefined

@type function
/*/
Function OFNJD15SERIE5000()
Return (VMB->VMB_TIPGAR == "ZZMK" .and. VMB->VMB_SUBGAR == "MTC" .and. VMB->VMB_TOTALW < 1)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15VTT ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Valida tipo de tempo utilizado para requisicao de pecas    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15VTT(cTipTem, aProcTT , cMsgTT )
If aScan(aProcTT, cTipTem ) == 0
	AADD( aProcTT , cTipTem )
	VOI->(dbSeek(xFilial("VOI") + cTipTem ))
	If VOI->VOI_VLPCAC == "2"
		cMsgTT += VOI->VOI_TIPTEM + " - " + AllTrim( VOI->VOI_DESTTE ) + CHR(13) + CHR(10)
	EndIf
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15AOS ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Processa atualizaÁ„o da Ordem de ServiÁo                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15AOS(lSer5000)

Local aPeca
Local aSrvc

Local cAliasVMC := "TVMC"
Local cAliasVO3 := "TVO3"
Local cAliasVO4 := "TVO4"

Local aAuxIteVO4 := {}
Local aIteVO4 := {}

Local aAuxIteVO3 := {}
Local aIteVO3 := {}

Local nTamTipTem := TamSX3("VO4_TIPTEM")[1]
Local nTamCodSer := TamSX3("VO4_CODSER")[1]

Local aSrvcVHRDIG := {}

Local cAuxTipTem := ""
Local cTipTemPeca := ""

Local nCont
Local nCont2
Local nContPc
Local nPos
Local nPosGet

Local aAltVO4 := {}

Local aCabAltVO4 := {}
Local aIteAltVO4 := {}

Local lVAIVALSER := (VAI->(FieldPos("VAI_VALSER")) <> 0)

Local aAddVMC := { {} , {} , {} }

Local aBkpAColsP := IIf( lTemPeca , aClone(oGetPeca:aCols) , {} )
Local aBkpAColsS := IIf( lTemSrvc , aClone(oGetSrvc:aCols) , {} )
Local aBkpAColsO := IIf( lTemOutr , aClone(oGetOutr:aCols) , {} )

Local nCntFor := 0
Local aAjProc := {} // Controla campos que devem ser alterados para processamento das alteracoes da OS

Local nPosaProb := 0
Local nPosaVMCP := 0

Local cAliasTT := "TTTCAN"
Local aTTCanPec := {} // Tipo de tempo utilizado na Atualizacao de OS mas esta CANCELADO atualmente
Local aReqPecTTCan := {}
Local nPosReqCan
Local nPosMov

Local cSQL
Local cAuxTipSer
Local nAuxKilRod
Local lAtuSrvc

//Local nDecVO3VALPEC := TamSX3("VO3_VALPEC")[2]
Local nVlrUnit := 0

Local aMReembSrv := {}

Local nSvRecVMB

Local nQtdeDev

Local cAliasOutrosSrvc := GetNextAlias()
Local cAliasSerTer     := GetNextAlias()
Local nTotRateado := 0
Local nSrvcProc   := 0

local lDelOutCred := .f.

local aPE_Peca := {}
local aPE_Srvc := {}
local aPE_Outros := {}
local aBkpArray := {}
local aParPE

lProbQtde := .f.
lProbValor := .f.

if ExistBlock("ONJD15VA")

	aBkpArray := {;
		aClone(aVMCPeca),;
		aClone(aVMCSrvc),;
		aClone(aVMCOutr) ;
	}

	aPE_Peca := IIf( lTemPeca , aClone(oGetPeca:aCols), {} )
	aPE_Srvc := IIf( lTemSrvc , aClone(oGetSrvc:aCols), {} )
	aPE_Outros := IIf( lTemOutr , aClone(oGetOutr:aCols), {} )

	aParPE := {;
		{ aVMCPeca ,aVMCSrvc , aVMCOutr } ,;
		{ aPE_Peca, aPE_Srvc, aPE_Outros } ;
		}

	lRet := ExecBlock("ONJD15VA", .f., .f., aParPE )

	// Restaura aCols dos Objetos de Tela
	OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
	aVMCPeca       := aClone( aBkpArray[1] )
	aVMCSrvc       := aClone( aBkpArray[2] )
	aVMCOutr       := aClone( aBkpArray[3] )

	aBkpArray := aSize(aBkpArray,0)

	if ! lRet
		Return .f.
	endif

EndIf

nSvRecVMB := VMB->(RecNo())

aProbPeca := {}

oProcJD:SetRegua1(6)

oProcJD:IncRegua1(STR0167) // Analisando alteraÁıes

oProcJD:SetRegua2(IIf( lTemPeca , Len(oGetPeca:aCols) , 0 ) + IIf( lTemSrvc , Len(oGetSrvc:aCols) , 0 ) + IIf( lTemOutr , Len(oGetOutr:aCols) , 0 ) + Len(aVMCPeca) + Len(aVMCSrvc) + Len(aVMCOutr))

// Gera com os registros novos criados para posterio gravacao na tabela VMC
If lTemPeca
	For nPosGet := 1 to Len(oGetPeca:aCols)
		If oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] .or. Empty(oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")])
			Loop
		EndIf

		oProcJD:IncRegua2()

		// Se for o mesmo TT de garantia, nao adiciona na VMC,
		// pois se tratar de alguma peca que nao esta requisitada na OS mas a JD pagou ...
		If aScan(aVMCPeca,{ |x| x[1] == oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_TIPTEM","aHPeca")] }) <> 0
			Loop
		EndIf
		//

		AADD( aAddVMC[1] , { ;
			oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_TIPTEM","aHPeca")] ,;
			oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_GRUITE","aHPeca")] ,;
			oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")] ,;
			oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_QTDREQ","aHPeca")] ,;
			oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_QTDREQ","aHPeca")]  ;
			} )

	Next nPosGet
EndIf
If lTemSrvc
	For nPosGet := 1 to Len(oGetSrvc:aCols)
		If oGetSrvc:aCols[nPosGet,Len(oGetSrvc:aCols[nPosGet])] .or. Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_CODSER","aHSrvc")])
			Loop
		EndIf

		oProcJD:IncRegua2()

		AADD( aAddVMC[2] , { ;
			oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] ,;
			oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_GRUSER","aHSrvc")] ,;
			oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_CODSER","aHSrvc")] ,;
			oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TEMPAD","aHSrvc")] ,;
			oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TEMPAD","aHSrvc")]  ;
			} )

	Next nPosGet
EndIf
If lTemOutr
	For nPosGet := 1 to Len(oGetOutr:aCols)
		If oGetOutr:aCols[nPosGet,Len(oGetOutr:aCols[nPosGet])] .or. Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODSER","aHOutr")])
			Loop
		EndIf

		oProcJD:IncRegua2()

		AADD( aAddVMC[3] , { ;
			oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] ,;
			oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_GRUSER","aHOutr")] ,;
			oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODSER","aHOutr")] ,;
			oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_VALTOT","aHOutr")] ,;
			oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_VALTOT","aHOutr")] ,;
			oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_NRECNO","aHOutr")]  ;
			} )

	Next nPosGet
EndIf
//

For nCont := 1 to Len(aVMCPeca)

	oProcJD:IncRegua2()

	// Qtde de pecas diferente da qtde de pecas enviada
	If aVMCPeca[nCont,_VMC_PECA_QTDPEC_] <> aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] .OR. aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] == 0

		lProbQtde := .t.

		// Qtde enviada È maior do que o retorno
		If aVMCPeca[nCont,_VMC_PECA_QTDPEC_] > aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] .OR. aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] == 0

			If aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] == 0
				nQtdeDev := aVMCPeca[nCont,_VMC_PECA_QTDPEC_]
			Else
				nQtdeDev := aVMCPeca[nCont,_VMC_PECA_QTDPEC_] - aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_]
			EndIf
	
			AADD( aProbPeca , { ;
				"Q" , ;                                   // 01 - Tipo Problema
				"D" , ;                                   // 02 - Movimentacao
				aVMCPeca[nCont,_VMC_PECA_TIPTEM_] , ;                    // 03 - Tipo de Tempo
				aVMCPeca[nCont,_VMC_PECA_LIBVOO_] , ;                    // 04 - Liberacao
				aVMCPeca[nCont,_VMC_PECA_GRUITE_] , ;                    // 05 - Grupo Peca
				aVMCPeca[nCont,_VMC_PECA_CODITE_] , ;                    // 06 - Codigo Peca
				nQtdeDev,; // 07 - Qtde
				aVMCPeca[nCont,_VMC_PECA_VLRREQUISITADO_] , ;                    // 08 - Valor
				aVMCPeca[nCont,_VMC_PECA_TES_] , ;                    // 09 - TES
				aVMCPeca[nCont,_VMC_PECA_UM_] , ;                    // 10 - Unidade de medida
				0 } )                                     // 11 - Qtde Processada

		EndIf

		// Procura todos os registros do mesmo produto para requisitar ...
		For nPosGet := 1 to Len(oGetPeca:aCols)
			If oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] .or. Empty(oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")])
				Loop
			EndIf

			If VMB->VMB_TIPGAR $ "ZSPA/ZPIP" .and. oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_VALPEC","aHPeca")] <> 0
				Loop
			EndIf

			If oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_GRUITE","aHPeca")] == aVMCPeca[nCont,03] .and. oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")] == aVMCPeca[nCont,04]
				AADD( aProbPeca , { "Q" , ;                           // 01 - Tipo Problema
									"R" , ;                           // 02 - Movimentacao
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_TIPTEM","aHPeca")] , ; // 03 - Tipo de Tempo
									, ;                               // 04 - Liberacao
									aVMCPeca[nCont,_VMC_PECA_GRUITE_] , ;            // 05 - Grupo Peca
									aVMCPeca[nCont,_VMC_PECA_CODITE_] , ;            // 06 - Codigo Peca
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_QTDREQ","aHPeca")] , ; // 07 - Qtde
									0 , ;                             // 08 - Valor
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODTES","aHPeca")] , ; // 09 - TES
									aVMCPeca[nCont,_VMC_PECA_UM_] ,;             // 10 - Unidade de medida
									.f.,;                             // 11 - Ja Processado
									.f.,;                             // 12 - Requisicao de Garantia Especial
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_OPER","aHPeca")] ,; // 13 - Operacao
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_PROREQ","aHPeca")] ,; // 14 - Produtivo
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_DEPINT","aHPeca")] ,; // 15 - Depto. Interno
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_FATPAR","aHPeca")] ,; // 16 - Cliente
									oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_LOJA"  ,"aHPeca")] ,; // 17 - Loja
									} )

				oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] := .T.
			EndIf
		Next nPosGet
		//

	EndIf

	// Valor total de pecas È diferente do que o valor enviado
	If aVMCPeca[nCont,_VMC_PECA_VLRTOTALENVIADO_] <> aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] .and. aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] <> 0
		lProbValor := .t.
		AADD( aProbPeca , { "V" , ;				// 01 - Tipo Problema
			aVMCPeca[ nCont , _VMC_PECA_TIPTEM_ ], ;					// 02 - Tipo de tempo
			aVMCPeca[ nCont , _VMC_PECA_LIBVOO_ ], ;					// 03 - Liberacao
			aVMCPeca[ nCont , _VMC_PECA_GRUITE_ ], ;					// 04 - Grupo Peca
			aVMCPeca[ nCont , _VMC_PECA_CODITE_ ], ;					// 05 - Codigo Peca
			aVMCPeca[ nCont , _VMC_PECA_VLRTOTALRETORNADO_ ], ;	// 06 - Valor Total Retornado
			aVMCPeca[ nCont , _VMC_PECA_QTDPECRETORNADA_ ], ;		// 07 - Qtde de Peca Retornada
			aVMCPeca[ nCont , _VMC_PECA_UM_ ], ;						// 08 - Unidade de Medida
			aVMCPeca[ nCont , _VMC_PECA_CONVUM_], ;					// 09 - Indica se houve alteracao de Unidade de Medida
			aVMCPeca[ nCont , _VMC_PECA_QTD1UM_] } )					// 10 - Quantidade do produto na primeira Unidade de Medida
		
		If VMB->VMB_TIPGAR == "ZSPA"
			aProbPeca[ Len(aProbPeca) , 06 ] := aVMCPeca[ nCont , _VMC_PECA_VLRTOTAL_ZSPA_ ]
		EndIf
		//

	EndIf
	//

	//// Qtde de Pecas igual, mas nao paga nada
	////If aVMCPeca[nCont,_VMC_PECA_QTDPEC_] == aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] .and. aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] == 0
	//If aVMCPeca[nCont,_VMC_PECA_VLRTOTALRETORNADO_] == 0
	//	lProbQtde := .t.
	//
	//	AADD( aProbPeca , { ;
	//		"Q" , ;                                       // 01 - Tipo Problema
	//		"D" , ;                                       // 02 - Movimentacao
	//		aVMCPeca[nCont,_VMC_PECA_TIPTEM_] , ;         // 03 - Tipo de Tempo
	//		aVMCPeca[nCont,_VMC_PECA_LIBVOO_] , ;         // 04 - Liberacao
	//		aVMCPeca[nCont,_VMC_PECA_GRUITE_] , ;         // 05 - Grupo Peca
	//		aVMCPeca[nCont,_VMC_PECA_CODITE_] , ;         // 06 - Codigo Peca
	//		IIf( aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] > 0 , aVMCPeca[nCont,_VMC_PECA_QTDPECRETORNADA_] , aVMCPeca[nCont,_VMC_PECA_QTDPEC_] ), ;         // 07 - Qtde
	//		aVMCPeca[nCont,_VMC_PECA_VLRREQUISITADO_] , ; // 08 - Valor
	//		aVMCPeca[nCont,_VMC_PECA_TES_] , ;            // 09 - TES
	//		aVMCPeca[nCont,_VMC_PECA_UM_] , ;             // 10 - Unidade de medida
	//		0 } )                                         // 11 - Qtde Processada
	//
	//	// Procura todos os registros do mesmo produto para requisitar ...
	//	For nPosGet := 1 to Len(oGetPeca:aCols)
	//		If oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] .or. Empty(oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")])
	//			Loop
	//		EndIf
	//
	//		If VMB->VMB_TIPGAR $ "ZSPA/ZPIP" .and. oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_VALPEC","aHPeca")] <> 0
	//			Loop
	//		EndIf
	//
	//		If oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_GRUITE","aHPeca")] == aVMCPeca[nCont,03] .and. oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")] == aVMCPeca[nCont,04]
	//			AADD( aProbPeca , { "Q" , ;                           // 01 - Tipo Problema
	//								"R" , ;                           // 02 - Movimentacao
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_TIPTEM","aHPeca")] , ;        // 03 - Tipo de Tempo
	//								, ;                               // 04 - Liberacao
	//								aVMCPeca[nCont,_VMC_PECA_GRUITE_] , ;            // 05 - Grupo Peca
	//								aVMCPeca[nCont,_VMC_PECA_CODITE_] , ;            // 06 - Codigo Peca
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_QTDREQ","aHPeca")] , ; // 07 - Qtde
	//								0 , ;                             // 08 - Valor
	//								, ;                               // 09 - TES
	//								aVMCPeca[nCont,_VMC_PECA_UM_]  ,;            // 10 - Unidade de medida
	//								.f. ,;                            // 11 - Ja Processado
	//								.f. ,;                            // 12 - Requisicao de Garantia Especial
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_OPER","aHPeca")],; // 13 - Operacao
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_PROREQ","aHPeca")] ,; // 14 - Produtivo
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_DEPINT","aHPeca")] ,; // 15 - Depto. Interno
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_FATPAR","aHPeca")] ,; // 16 - Cliente
	//								oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_LOJA"  ,"aHPeca")] ,; // 17 - Loja
	//								} )
	//
	//			oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] := .T.
	//
	//		EndIf
	//	Next nPosGet
	//	//
	//
	//EndIf

Next nCont

SB1->(dbSetOrder(7))

// Processa restante de requisicoes
If lTemPeca
	For nPosGet := 1 to Len(oGetPeca:aCols)
		If oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] .or. Empty(oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")])
			Loop
		EndIf

		oProcJD:IncRegua2()

		SB1->(dbSeek(xFilial("SB1") + oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_GRUITE","aHPeca")] + oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")]))

		AADD( aProbPeca , { "Q" , ;                           // 01 - Tipo Problema
							"R" , ;                           // 02 - Movimentacao
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_TIPTEM","aHPeca")] , ; // 03 - Tipo de Tempo
							, ;                               // 04 - Liberacao
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_GRUITE","aHPeca")] , ; // 05 - Grupo Peca
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODITE","aHPeca")] , ; // 06 - Codigo Peca
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_QTDREQ","aHPeca")] , ; // 07 - Qtde
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_VALPEC","aHPeca")] , ;                             // 08 - Valor
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODTES","aHPeca")], ;                               // 09 - TES
							IIf( ! Empty(oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_UM","aHPeca")]) , oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_UM","aHPeca")] , SB1->B1_UM ) ,;            // 10 - Unidade de medida
							.f. ,;		// Ja Processado
							.t.  ,;		// Requisicao de Garantia Especial
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_OPER","aHPeca")] ,; // 13 - Operacao
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_PROREQ","aHPeca")] ,; // 14 - Produtivo
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_DEPINT","aHPeca")] ,; // 15 - Depto. Interno
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_FATPAR","aHPeca")] ,; // 16 - Cliente
							oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_LOJA"  ,"aHPeca")] ,; // 17 - Loja
							} )

		oGetPeca:aCols[nPosGet,Len(oGetPeca:aCols[nPosGet])] := .T.

	Next nPosGet
EndIf
//

For nCont := 1 to Len(aVMCSrvc)

	oProcJD:IncRegua2()

	aAuxIteVO4 := {}
	lAtuSrvc := .f.
	// Revisao ...
	If VMB->VMB_TIPGAR == "ZZMK" .and. VMB->VMB_SUBGAR == "MTC"
		lAtuSrvc := .t.
	EndIf
	// Garantia Normal / PMP / PeÁas / Bateria
	If VMB->VMB_TIPGAR $ "ZNRM/ZPIP/ZPAR/ZZBT"
		// Verifica se tem problema de valor da Hora OU problema na quantidade de horas ...
		If ( ;
			(aVMCSrvc[nCont,_VMC_SRVC_VLRTOTALRETORNADO_] / aVMCSrvc[nCont,_VMC_SRVC_HORASRETORNADA_]) <> aVMCSrvc[nCont,_VMC_SRVC_VLRHORAENVIADO_] ; // Valor de Hora Diferente
			.or.;
		     aVMCSrvc[nCont,_VMC_SRVC_HORASENVIADO_] <> aVMCSrvc[nCont,_VMC_SRVC_HORASRETORNADA_]; // Quantidade de Horas Diferente
		   ) .and.;
		   aVMCSrvc[nCont,_VMC_SRVC_VLRTOTALRETORNADO_] <> 0

			lAtuSrvc := .t.
		EndIf
	EndIf
	If lAtuSrvc
		AADD( aAuxIteVO4, { "LINPOS"     , "VO4_TIPTEM+VO4_CODSER",PadR(AllTrim(aVMCSrvc[nCont,01]),nTamTipTem) , PadR(AllTrim(aVMCSrvc[nCont,04]),nTamCodSer)})
		AADD( aAuxIteVO4, { "VO4_TEMPAD" , aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] * 100, nil } )
		AADD( aAuxIteVO4, { "VO4_VALHOR" , Round(aVMCSrvc[nCont,14] / aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ],2) , nil })
		If lSer5000
			AADD( aAuxIteVO4, { "VO4_TIPSER" , MV_PAR41 , nil })
			AADD( aAuxIteVO4, { "VO4_VALSER" , 0 , nil })
		Else
			AADD( aAuxIteVO4, { "VO4_VALSER" , aVMCSrvc[nCont,14] , nil })
		EndIf
		AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

		AADD( aSrvcVHRDIG , { PadR(AllTrim(aVMCSrvc[nCont,01]),nTamTipTem) , PadR(AllTrim(aVMCSrvc[nCont,04]),nTamCodSer) } )

		If At(aVMCSrvc[nCont,01],cAuxTipTem) == 0
			cAuxTipTem += aVMCSrvc[nCont,01] + "/"
		EndIf
	EndIf
	// Servico Nao Provado
	If aVMCSrvc[nCont, _VMC_SRVC_NAOAPROVADO_]
		// Procura o registro na aCols com as informaÁıes do servico nao aprovado
		nPosGet := aScan( oGetSrvc:aCols, { |x| x[FG_POSVAR("SER_RECNO","aHSrvc")] == aVMCSrvc[nCont,_VMC_SRVC_RECNO_] })
		If nPosGet == 0
			OFNJD15014_Help("NJD15SRVCEXIST", STR0221 ) // "InformaÁıes do serviÁo n„o aprovado n„o encontrada na Grid."
			Return .f.
		EndIf

		aCabAltVO4 := {}
		aIteAltVO4 := {}

		AADD( aCabAltVO4 , { "NUMOSV" , VMB->VMB_NUMOSV                                          , Nil }) // Numero do pedido
		AADD( aCabAltVO4 , { "TIPTEM" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] , Nil }) // Tipo de Tempo Novo
		AADD( aCabAltVO4 , { "TIPSER" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPSER","aHSrvc")] , nil } )

		VOI->(dbSetOrder(1))
		VOI->(msSeek(xFilial("VOI") + oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] ))
		
		If VOI->VOI_DEPINT == "1" .AND. ! Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPINT","aHSrvc")])
			AADD( aCabAltVO4 , { "DEPINT" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPINT","aHSrvc")] , nil } )
		EndIf

		If VOI->VOI_DEPGAR == "1" .AND. ! Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPGAR","aHSrvc")])
			AADD( aCabAltVO4 , { "DEPGAR" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPGAR","aHSrvc")] , nil } )
		EndIf
		
		aAuxIteVO4 := {}
		AADD( aAuxIteVO4 , { "VO4_TIPTEM" , aVMCSrvc[nCont, _VMC_SRVC_TIPTEM_ ] , nil } )
		AADD( aAuxIteVO4 , { "VO4_CODSER" , aVMCSrvc[nCont, _VMC_SRVC_CODSER_ ] , nil } )
		AADD( aIteAltVO4 , aClone( aAuxIteVO4 ) )

		If At(aVMCSrvc[nCont,01],cAuxTipTem) == 0
			cAuxTipTem += aVMCSrvc[nCont,01] + "/"
		EndIf

		If VMB->VMB_TIPGAR == "ZPIP"
			// Matriz utilizada para ajustar o valor do servico no final do processamento ...
			AADD( aMReembSrv , { VMB->VMB_NUMOSV ,;
								 oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] ,;
								 aVMCSrvc[nCont, _VMC_SRVC_CODSER_ ] ,;
								 oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_VALSER","aHSrvc")] } )
			//
		Else
			aMReembSrv := {}
		EndIf

		AADD( aAltVO4 , { aClone(aCabAltVO4) , aClone(aIteAltVO4) , aClone(aMReembSrv) })

	EndIf
	// Garantia Especial
	If VMB->VMB_TIPGAR $ "ZSPA" .and. ! aVMCSrvc[nCont, _VMC_SRVC_NAOAPROVADO_]

		cSQL := "SELECT VOK_INCMOB "
		cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
		cSQL +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK_TIPSER = VO4_TIPSER AND VOK.D_E_L_E_T_ = ' '"
		cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
		cSQL +=   " AND VO4_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
		cSQL +=   " AND VO4_TIPTEM = '" + PadR(AllTrim(aVMCSrvc[nCont,01]),nTamTipTem) + "'"
		cSQL +=   " AND VO4_CODSER = '" + PadR(AllTrim(aVMCSrvc[nCont,04]),nTamCodSer) + "'"
		cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
		cAuxTipSer := FM_SQL(cSQL)

		AADD( aAuxIteVO4, { "LINPOS"     , "VO4_TIPTEM+VO4_CODSER",PadR(AllTrim(aVMCSrvc[nCont,01]),nTamTipTem) , PadR(AllTrim(aVMCSrvc[nCont,04]),nTamCodSer)})

		Do Case
		// Mao de Obra
		Case cAuxTipSer $ "0/1/3"
			AADD( aAuxIteVO4, { "VO4_TEMPAD" , aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] * 100, nil } )
			AADD( aAuxIteVO4, { "VO4_VALHOR" , aVMCSrvc[nCont,12] , nil })
			AADD( aAuxIteVO4, { "VO4_VALSER" , aVMCSrvc[nCont,14] , nil })
		// Servico de Terceiro
		Case cAuxTipSer $ "2"
			AADD( aAuxIteVO4, { "VO4_VALVEN" , aVMCSrvc[nCont,14] , nil })
			AADD( aAuxIteVO4, { "VO4_VALSER" , aVMCSrvc[nCont,14] , nil })
		// KM de Socorro
		Case cAuxTipSer $ "5"
			cSQL := "SELECT VO4_KILROD "
			cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
			cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
			cSQL +=   " AND VO4_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
			cSQL +=   " AND VO4_CODSER = '" + PadR(AllTrim(aVMCSrvc[nCont,04]),nTamCodSer) + "'"
			cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
			nAuxKilRod := FM_SQL(cSQL)
			AADD( aAuxIteVO4, { "VO4_PREKIL" , Round(aVMCSrvc[nCont,14] / nAuxKilRod,TamSX3("VO4_PREKIL")[2]) , nil })
		EndCase
		//

		AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

		AADD( aSrvcVHRDIG , { PadR(AllTrim(aVMCSrvc[nCont,01]),nTamTipTem) , PadR(AllTrim(aVMCSrvc[nCont,04]),nTamCodSer) } )

		If At(aVMCSrvc[nCont,01],cAuxTipTem) == 0
			cAuxTipTem += aVMCSrvc[nCont,01] + "/"
		EndIf

	EndIf
Next nCont

VOK->(dbSetOrder(1))
VOI->(dbSetOrder(1))

// Se Informado, requisita servicos ...
If (VMB->VMB_TIPGAR == "ZPIP" .or. VMB->VMB_TIPGAR == "ZSPA") .and. lTemSrvc

	For nPosGet := 1 to Len(oGetSrvc:aCols)
		If oGetSrvc:aCols[nPosGet,Len(oGetSrvc:aCols[nPosGet])] .or. Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_CODSER","aHSrvc")])
			Loop
		EndIf

		If !Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTRA","aHSrvc")])
			If VMB->VMB_TIPGAR == "ZPIP"
				nAuxPos := aScan( aVMCSrvc, { |x| x[_VMC_SRVC_POS_ACOLS_] == nPosGet })
				If nAuxPos == 0
					Loop
				EndIf

				If aVMCSrvc[nAuxPos, _VMC_SRVC_NAOAPROVADO_] // Linha ja foi processada no bloco anterior
					Loop
				EndIf
				
			Else
				Loop
			EndIf
		EndIf

		If !Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")])

			If VOI->VOI_TIPTEM <> oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")]
				VOI->(MsSeek( xFilial("VOI") + oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] ))
			EndIf

			If VOK->VOK_TIPSER <> oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPSER","aHSrvc")]
				VOK->(MsSeek( xFilial("VOK") + oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPSER","aHSrvc")] ))
			EndIf

			aAuxIteVO4 := {}
			AADD(aAuxIteVO4, { "VO4_NUMOSV" , VMB->VMB_NUMOSV , nil } )

			AADD(aAuxIteVO4, { "VO4_TIPTEM" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] , nil } )

			If !Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_FATPAR","aHSrvc")])
				AADD(aAuxIteVO4, { "VO4_FATPAR" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_FATPAR","aHSrvc")] , nil } )
				AADD(aAuxIteVO4, { "VO4_LOJA"   , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_LOJA"  ,"aHSrvc")] , nil } )
			EndIf

			AADD(aAuxIteVO4, { "VO4_GRUSER" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_GRUSER","aHSrvc")] , nil } )
			AADD(aAuxIteVO4, { "VO4_CODSER" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_CODSER","aHSrvc")] , nil } )
			AADD(aAuxIteVO4, { "VO4_TIPSER" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPSER","aHSrvc")] , nil } )

			// Tipo de Servico de Terceiros ...
			If VOK->VOK_INCMOB == "2"
				AADD(aAuxIteVO4, { "VO4_VALVEN" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_VALSER","aHSrvc")] , nil })
			// Por Mao de Obra ...
			Else
				AADD(aAuxIteVO4, { "VO4_TEMPAD" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TEMPAD","aHSrvc")] , nil } )

				AADD(aAuxIteVO4, { "VO4_VALHOR" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_VALHOR","aHSrvc")] , nil })
				AADD(aAuxIteVO4, { "VO4_VALSER" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_VALSER","aHSrvc")] , nil })
			EndIf
			//

			AADD(aAuxIteVO4, { "VO4_CODSEC" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_CODSEC","aHSrvc")] , nil } )

			If VOI->VOI_DEPINT == "1" .and. !Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPINT","aHSrvc")])
				AADD(aAuxIteVO4, { "VO4_DEPINT" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPINT","aHSrvc")] , nil } )
			EndIf

			If VOI->VOI_DEPGAR == "1" .and. !Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPGAR","aHSrvc")])
				AADD(aAuxIteVO4, { "VO4_DEPGAR" , oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_DEPGAR","aHSrvc")] , nil } )
			EndIf

			For nCont := 1 to Len(aCpoCustomizado)
				If aCpoCustomizado[nCont,1] == "SERVICOS"
					cAuxCpo := "SER_" + Right(aCpoCustomizado[nCont,2],Len(aCpoCustomizado[nCont,2])-4)
					If !Empty(oGetSrvc:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHSrvc")])
						AADD(aAuxIteVO4, { aCpoCustomizado[nCont,2] , oGetSrvc:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHSrvc")] , nil } )
					EndIf
				EndIf
			Next nCont

			AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

			If At(oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")],cAuxTipTem) == 0
				cAuxTipTem += oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] + "/"
			EndIf

		EndIf
	Next nPosGet
EndIf
//
//

For nCont := 1 to Len(aVMCOutr)

	oProcJD:IncRegua2()

	If aVMCOutr[nCont,_VMC_OUTR_CUSMAR_] <> 0 // Valor de Retorno

		aAuxIteVO4 := {}

		// Nao houve requisicao
		If aVMCOutr[nCont,07] == 0 .or. aVMCOutr[nCont,_VMC_OUTR_NAOTRANSMITIDO_] // Valor de Transmissao

			AADD(aAuxIteVO4, { "VO4_NUMOSV" , VMB->VMB_NUMOSV , nil } )

			// Procura todos os registros do mesmo produto para requisitar ...
			For nPosGet := 1 to Len(oGetOutr:aCols)
				If oGetOutr:aCols[nPosGet,Len(oGetOutr:aCols[nPosGet])] .or. Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODSER","aHOutr")])
					Loop
				EndIf

				If aVMCOutr[nCont,_VMC_OUTR_NAOTRANSMITIDO_] .and. oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_STATUS","aHOutr")] <> FWNoAccent(STR0217)
					Loop
				EndIf

				If oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODMAT","aHOutr")] == aVMCOutr[nCont,05]

					OFNJD15002_NovaLinhaRequisicaoVO4( @aAuxIteVO4 , aVMCOutr[nCont,08] , nPosGet , aCpoCustomizado )

					// Deleta o Registro na aCols para nao processar novamente ...
					oGetOutr:aCols[nPosGet,Len(oGetOutr:aCols[nPosGet])] := .t.

					If At(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")],cAuxTipTem) == 0
						cAuxTipTem += oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] + "/"
					EndIf

				EndIf

			Next nPosGet
			//

			AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

		Else

			lProcOutCredito := .f.

			// Procura um servico de terceiro requisitado com o mesmo valor transmitido ...
			cSQL := "SELECT VOK_INCMOB, VO4_VALVEN "
			cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
			cSQL +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK_TIPSER = VO4_TIPSER AND VOK.D_E_L_E_T_ = ' '"
			cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
			cSQL +=   " AND VO4.VO4_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
			cSQL +=   " AND VO4.VO4_TIPTEM = '" + PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) + "'"
			cSQL +=   " AND VO4.VO4_CODSER = '" + PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer) + "'"
			cSQL +=   " AND VO4.VO4_VALVEN = " + Str(aVMCOutr[nCont,07],20,2)
			cSQL +=   " AND VOK_INCMOB = '2'" // Servico de terceiro
			cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasOutrosSrvc , .F., .T. )
			If ! (cAliasOutrosSrvc)->(Eof())

				aAuxIteVO4 := {}
				AADD( aAuxIteVO4, { "LINPOS" ,;
					"VO4_TIPTEM+VO4_CODSER+VO4_VALVEN" ,;
					PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) ,; // Tipo de Tempo 
					PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer) ,; // Codigo do Servico 
					(cAliasOutrosSrvc)->VO4_VALVEN }) 				// Valor do Servico 
				
				AADD( aAuxIteVO4, { "VO4_VALVEN" , aVMCOutr[nCont,08] , nil })
				AADD( aAuxIteVO4, { "VO4_VALSER" , aVMCOutr[nCont,08] , nil })

				AADD( aIteVO4 , aClone( aAuxIteVO4 ) )
				
				If At(aVMCOutr[nCont,01],cAuxTipTem) == 0
					cAuxTipTem += aVMCOutr[nCont,01] + "/"
				EndIf

				lProcOutCredito := .t.
			EndIf
			(cAliasOutrosSrvc)->(dbCloseArea())

			// Se nao encontrar um servico requisitado, provavelmente o valor transmitido √© a soma de varias 
			// requisicoes de servicos de terceiros 
			If lProcOutCredito == .f.
			
				cSQL := "SELECT VOK_INCMOB, SUM(VO4_KILROD) VO4_KILROD, SUM(VO4_VALVEN) VO4_VALVEN, COUNT(*) CONTADOR "
				cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
				cSQL +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK_TIPSER = VO4_TIPSER AND VOK.D_E_L_E_T_ = ' '"
				cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
				cSQL +=   " AND VO4_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
				cSQL +=   " AND VO4_TIPTEM = '" + PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) + "'"
				cSQL +=   " AND VO4_CODSER = '" + PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer) + "'"
				cSQL +=   " AND VOK_INCMOB IN ('2','5')" // Servico de terceiro / Socorro (Deslocamento)
				cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
				cSQL += " GROUP BY VOK_INCMOB"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasOutrosSrvc , .F., .T. )
				WHile !(cAliasOutrosSrvc)->(Eof())

					Do Case
					// Servico de Terceiro
					Case (cAliasOutrosSrvc)->VOK_INCMOB $ "2"

						cSQL := "SELECT VO4_VALVEN "
						cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
						cSQL +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK_TIPSER = VO4_TIPSER AND VOK.D_E_L_E_T_ = ' '"
						cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
						cSQL +=   " AND VO4_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
						cSQL +=   " AND VO4_TIPTEM = '" + PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) + "'"
						cSQL +=   " AND VO4_CODSER = '" + PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer) + "'"
						cSQL +=   " AND VOK_INCMOB = '2' "  // Servico de terceiro			
						cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
						cSQL += " ORDER BY VO4_VALVEN"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasSerTer , .F., .T. )
						While !(cAliasSerTer)->(Eof())

							nSrvcProc++

							aAuxIteVO4 := {}
							AADD( aAuxIteVO4, { "LINPOS" ,;
								"VO4_TIPTEM+VO4_CODSER+VO4_VALVEN" ,;
								PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) ,; // Tipo de Tempo 
								PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer) ,; // Codigo do Servico 
								(cAliasSerTer)->VO4_VALVEN }) 									// Valor do Servico 
					
							If nSrvcProc == (cAliasOutrosSrvc)->CONTADOR
								nAuxVlrSrvc := aVMCOutr[nCont,08] - nTotRateado
							Else
								// Calcula percentual do servico atual com relacao a todos os servicos de terceiros requisitados ...
								nPercentual := (cAliasSerTer)->VO4_VALVEN / (cAliasOutrosSrvc)->VO4_VALVEN
								nAuxVlrSrvc := Round(aVMCOutr[nCont,08] * nPercentual,2)
								nTotRateado += nAuxVlrSrvc
							EndIf
							AADD( aAuxIteVO4, { "VO4_VALVEN" , nAuxVlrSrvc , nil })
							AADD( aAuxIteVO4, { "VO4_VALSER" , nAuxVlrSrvc , nil })

							(cAliasSerTer)->(dbSkip())

							AADD( aIteVO4 , aClone( aAuxIteVO4 ) )
						
						End
						(cAliasSerTer)->(dbCloseArea())

							
					// KM de Socorro
					Case (cAliasOutrosSrvc)->VOK_INCMOB $ "5"
						aAuxIteVO4 := {}
						AADD( aAuxIteVO4, { "LINPOS" ,;
							"VO4_TIPTEM+VO4_CODSER",;
							PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) , ;
							PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer)})

						nAuxKilRod := (cAliasOutrosSrvc)->VO4_KILROD
						AADD( aAuxIteVO4, { "VO4_PREKIL" , Round(aVMCOutr[nCont,08] / nAuxKilRod,TamSX3("VO4_PREKIL")[2]) , nil })

						AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

					EndCase
					//

					If At(aVMCOutr[nCont,01],cAuxTipTem) == 0
						cAuxTipTem += aVMCOutr[nCont,01] + "/"
					EndIf

					(cAliasOutrosSrvc)->(dbSkip())

				End
				(cAliasOutrosSrvc)->(dbCloseArea())
			Endif

		EndIf

	Else

		lDelOutCred := .t.
		// Outros Servicos nao aprovado, remove da OS quando nao for WTYSUBL7

		If aVMCOutr[nCont, _VMC_OUTR_NAOAPROVADO_]
			// Procura o registro na aCols com as informaÁıes do servico nao aprovado
			nPosGet := aScan( oGetOutr:aCols, { |x| x[FG_POSVAR("OUT_NRECNO","aHOutr")] == aVMCOutr[nCont,_VMC_OUTR_RECNO_] })

			aCabAltVO4 := {}
			aIteAltVO4 := {}
			AADD( aCabAltVO4 , { "NUMOSV" , VMB->VMB_NUMOSV                                          , Nil }) // Numero do pedido
			AADD( aCabAltVO4 , { "TIPTEM" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] , Nil }) // Tipo de Tempo Novo
			AADD( aCabAltVO4 , { "TIPSER" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPSER","aHOutr")] , nil } )

			VOI->(dbSetOrder(1))
			VOI->(msSeek(xFilial("VOI") + oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] ))
			
			If VOI->VOI_DEPINT == "1" .AND. ! Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPINT","aHOutr")])
				AADD( aCabAltVO4 , { "DEPINT" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPINT","aHOutr")] , nil } )
			EndIf

			If VOI->VOI_DEPGAR == "1" .AND. ! Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPGAR","aHOutr")])
				AADD( aCabAltVO4 , { "DEPGAR" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPGAR","aHOutr")] , nil } )
			EndIf
			
			aAuxIteVO4 := {}
			AADD( aAuxIteVO4 , { "VO4_TIPTEM" , aVMCOutr[nCont, _VMC_OUTR_TIPTEM_ ] , nil } )
			AADD( aAuxIteVO4 , { "VO4_CODSER" , aVMCOutr[nCont, _VMC_OUTR_CODSER_ ] , nil } )
			AADD( aIteAltVO4 , aClone( aAuxIteVO4 ) )

			If At(aVMCOutr[nCont,_VMC_OUTR_TIPTEM_],cAuxTipTem) == 0
				cAuxTipTem += aVMCOutr[nCont,_VMC_OUTR_TIPTEM_] + "/"
			EndIf

			AADD( aAltVO4 , { aClone(aCabAltVO4) , aClone(aIteAltVO4) , {} })

			lDelOutCred := .F.

		EndIf

		if lDelOutCred

			aAuxIteVO4 := {}
			AADD( aAuxIteVO4, { "LINPOS"     , "VO4_TIPTEM+VO4_CODSER",PadR(AllTrim(aVMCOutr[nCont,01]),nTamTipTem) , PadR(AllTrim(aVMCOutr[nCont,04]),nTamCodSer)})
			AADD( aAuxIteVO4, { "AUTDELETA" , "S" , NIL } )

			AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

			If At(aVMCOutr[nCont,01],cAuxTipTem) == 0
				cAuxTipTem += aVMCOutr[nCont,01] + "/"
			EndIf
			
		endif

	EndIf

Next nCont

If Len(aVMCOutr) > 0

	// Procura todos os registros do mesmo produto para requisitar ...
	For nPosGet := 1 to Len(oGetOutr:aCols)
		If oGetOutr:aCols[nPosGet,Len(oGetOutr:aCols[nPosGet])] .or. Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODSER","aHOutr")])
			Loop
		EndIf

		// "SERVI«O N√O APROVADO" -> ja foi processado
		if oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_STATUS","aHOutr")] == FWNoAccent(STR0216)
			loop
		endif

		oProcJD:IncRegua2()

		aAuxIteVO4 := {}
		AADD(aAuxIteVO4, { "VO4_NUMOSV" , VMB->VMB_NUMOSV , nil } )
		OFNJD15002_NovaLinhaRequisicaoVO4( aAuxIteVO4 , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_VALVEN","aHOutr")] , nPosGet , aCpoCustomizado )

		AADD( aIteVO4 , aClone( aAuxIteVO4 ) )

		oGetOutr:aCols[nPosGet,Len(oGetOutr:aCols[nPosGet])] := .t.

		If At(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")],cAuxTipTem) == 0
			cAuxTipTem += oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] + "/"
		EndIf

	Next nPosGet
	//
EndIf

DbSelectArea("VMB")

aLiberar := {}
aRecalVOO  := {}
cAuxLibVOO := ""

Begin Transaction

oProcJD:IncRegua1(STR0168) // Cancelando LiberaÁ„o de Tipo de Tempo
oProcJD:SetRegua2(Len(aProbPeca) + Len(aVMCPeca) + Len(aIteVO4))

If VMB->VMB_TIPGAR $ "ZNRM/ZPIP/ZPAR/ZZBT/ZSPA"

	// Procura todos os tipos de tempos utilizados nas requisicoes de pecas
	cTipTemPeca := ""
	For nCont := 1 to Len(aProbPeca)
		If aProbPeca[nCont,1] == "Q" .and. AT(aProbPeca[nCont,03],cTipTemPeca) == 0
			cTipTemPeca += "'" + aProbPeca[nCont,3] + "',"
		EndIf
	Next nCont
	//

	If !Empty(cTipTemPeca)

		cTipTemPeca := Left(cTiPTemPeca,Len(cTipTemPeca)-1)

		// Verifica se altum Tipo de Tempo utilizado na Atualizacao est· cancelado ...
		// Nesses casos o Tipo de tempo voltar· como aberto se n„o houver peÁas requisitadas para ele ...
		aTTCanPec := {}
		cSQL := "SELECT DISTINCT VO3_TIPTEM"
		cSQL +=  " FROM " + RetSQLName("VO3") + " VO3 "
		cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
		cSQL +=   " AND VO3.VO3_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
		cSQL +=   " AND VO3.VO3_DATCAN <> '        '"
		cSQL +=   " AND VO3.VO3_TIPTEM IN (" + cTipTemPeca + ")"
		cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasTT , .F., .T. )
		While !(cAliasTT)->(Eof())
			If aScan(aTTCanPec,{ |x| x == (cAliasTT)->VO3_TIPTEM }) == 0
				AADD(aTTCanPec, (cAliasTT)->VO3_TIPTEM )
			EndIf
			(cAliasTT)->(dbSkip())
		EndDo
		(cAliasTT)->(dbCloseArea())
		DbSelectArea("VMB")

		For nCont := 1 to Len(aTTCanPec)
			aReqPecTTCan := FMX_CALPEC( VMB->VMB_NUMOSV , ;
												aTTCanPec[nCont], ;
												/* cGruIte */  ,;
												/* cCodIte */  ,;
												.t. /* lMov */ ,;
												.f. /* lNegoc */ ,;
												.f. /* lReqZerada */ ,;
												.t. /* lRetAbe */ ,;
												.f. /* lRetLib */ ,;
												.f. /* lRetFec */ ,;
												.t. /* lRetCan */ ,;
												/* cLibVOO */ ,;
												" VO3_DATCAN <> '        ' ")
			// Verifica se existe algum saldo de peca requisitada ...
			If aScan(aReqPecTTCan,{ |x| x[PECA_QTDREQ] <> 0 }) <> 0
				FMX_HELP("OFNJD15TTCAN",STR0236 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + AllTrim(RetTitle("VO3_TIPTEM")) + ": " + aTTCanPec[nCont] ) // Tipo de tempo cancelado com saldo de pecas requisitadas.
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
				Return .f.
			EndIf
			//
			dbSelectArea("VO3")
			For nPosReqCan := 1 to Len(aReqPecTTCan)
				For nPosMov := 1 to Len(aReqPecTTCan[nPosReqCan,PECA_MOV])
					VO3->(dbGoTo(aReqPecTTCan[ nPosReqCan , PECA_MOV , nPosMov , PECA_MOV_RECVO3 ]))
					RecLock("VO3",.F.)
					VO3->VO3_DATCAN := CtoD(" ")
					VO3->VO3_HORCAN := 0
					VO3->(MsUnLock())
				Next nPosMov
			Next nPosReqCan

		Next nCont
	EndIf
	//

	// Analisa os problemas de peca.
	// Quando envolver alteracao de quantidade, deve cancelar liberacao
	For nCont := 1 to Len(aProbPeca)
		If aProbPeca[nCont,1] == "Q"
			VOO->(dbSetOrder(1)) // VOO_FILIAL, VOO_NUMOSV, VOO_TIPTEM, VOO_LIBVOO, R_E_C_N_O_, D_E_L_E_T_
			If aProbPeca[nCont,2] == "D"
				VOO->(dbSeek( xFilial("VOO") + VMB->VMB_NUMOSV + aProbPeca[nCont,3] + aProbPeca[nCont,4] ))
				cAuxLibVOO := aProbPeca[nCont,4]
			Else
				VOO->(dbSeek( xFilial("VOO") + VMB->VMB_NUMOSV + aProbPeca[nCont,3] ))
			EndIf

			If VOO->(Found())

				// Se for problema de requisicao, deve utilizar o numero da liberacao da VOO posicionada ...
				If aProbPeca[nCont,2] == "R"
					cAuxLibVOO := VOO->VOO_LIBVOO
				EndIf

				oProcJD:IncRegua2(VMB->VMB_NUMOSV + "-" + aProbPeca[nCont,3] + "-" + cAuxLibVOO)

				// Cancela tipo de tempo ...
				If !OFNJD15CTT(VMB->VMB_NUMOSV, aProbPeca[nCont,3], cAuxLibVOO, @aLiberar)
					OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
					Return .f.
				EndIf

			EndIf
		EndIf
	Next nCont
	//

	// Verifica se foi gerada mais de uma liberacao de TT para a mesma SG...
	cAuxLibVOO := ""
	nCont2 := 0
	aLibVOOGar := {}
	For nCont := 1 to Len(aVMCPeca)
		If aScan(aLibVOOGar,{ |x| x[1] == aVMCPeca[nCont,01] .and. x[2] == aVMCPeca[nCont,02] }) == 0
			AADD( aLibVOOGar , { aVMCPeca[nCont,01] , aVMCPeca[nCont,02] } )
		EndIf
	Next nCont
	For nCont := 1 to Len(aLibVOOGar)

		oProcJD:IncRegua2(VMB->VMB_NUMOSV + "-" + aLibVOOGar[nCont,01] + "-" + aLibVOOGar[nCont,02])

		If !OFNJD15CTT(VMB->VMB_NUMOSV, aLibVOOGar[nCont,01] , aLibVOOGar[nCont,02] , @aLiberar)
			OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
			Return .f.
		EndIf
	Next nCont
	//

EndIf

// Se tiver problema no servico ...
If Len(aIteVO4) > 0 .or. Len(aAltVO4) <> 0

	cAuxTipTem := Left(cAuxTipTem,Len(cAuxTipTem)-1)

	aCabCanc := {}

	cSQL := "SELECT DISTINCT VMC_TIPTEM, VMC_LIBVOO"
	cSQL +=  " FROM " + RetSQLname("VMC")
	cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
	cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
	cSQL +=   " AND VMC_LIBVOO <> '        '"
	cSQL +=   " AND VMC_TIPTEM IN " + FormatIN(cAuxTipTem,"/")
	cSQL +=   " AND VMC_TIPOPS IN ('S','O')"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC , .F., .T. )
	While !(cAliasVMC)->(Eof())

		VOO->(dbSetOrder(1)) // VOO_FILIAL, VOO_NUMOSV, VOO_TIPTEM, VOO_LIBVOO, R_E_C_N_O_, D_E_L_E_T_
		If VOO->(dbSeek( xFilial("VOO") + VMB->VMB_NUMOSV + (cAliasVMC)->VMC_TIPTEM + (cAliasVMC)->VMC_LIBVOO ))

			oProcJD:IncRegua2(VMB->VMB_NUMOSV + "-" + (cAliasVMC)->VMC_TIPTEM + "-" + (cAliasVMC)->VMC_LIBVOO)

			// Cancela Liberacao de tipo de tempo ...
			If !OFNJD15CTT(VMB->VMB_NUMOSV , (cAliasVMC)->VMC_TIPTEM , (cAliasVMC)->VMC_LIBVOO , @aLiberar )
				OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
				(cAliasVMC)->(dbCloseArea())
				dbSelectArea("VMB")
				Return .f.
			EndIf

		EndIf
		(cAliasVMC)->(dbSkip())
	EndDo
	(cAliasVMC)->(dbCloseArea())
	DbSelectArea("VMB")
EndIf
//

oProcJD:IncRegua1(STR0169) // Ajustando ServiÁos
oProcJD:SetRegua2(2)

// Altera Requisicao de Servico
If Len(aAltVO4) <> 0

	oProcJD:IncRegua2()
	For nCntFor := 1 to Len(aAltVO4)

		aCabAltVO4 := aClone( aAltVO4[nCntFor, 1 ] )
		aIteAltVO4 := aClone( aAltVO4[nCntFor, 2 ] )
		aMReembSrv := aClone( aAltVO4[nCntFor, 3 ] )

		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| OFIOM030(,,x,y,z)},aCabAltVO4,aIteAltVO4,3)
		if lMsErroAuto
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MostraErro()
			OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
			Return .f.
		Endif
		lMSHelpAuto := .f.

		For nCont := 1 to Len(aMReembSrv)
			cSQL := "SELECT R_E_C_N_O_ VO4RECNO"
			cSQL +=  " FROM " + RetSQLName("VO4")
			cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
			cSQL +=   " AND VO4_NUMOSV = '" + aMReembSrv[nCont,1] + "'"
			cSQL +=   " AND VO4_TIPTEM = '" + aMReembSrv[nCont,2] + "'"
			cSQL +=   " AND VO4_CODSER = '" + aMReembSrv[nCont,3] + "'"
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO4 , .F., .T. )
			While !(cAliasVO4)->(Eof())
				dbSelectArea("VO4")
				dbGoTo((cAliasVO4)->VO4RECNO)
				RecLock("VO4",.F.)
				VO4->VO4_VALSER := aMReembSrv[nCont,4]
				VO4->(MsUnLock())
				(cAliasVO4)->(dbSkip())
			EndDo
			(cAliasVO4)->(dbCloseArea())
			DbSelectArea("VMB")
		Next nCont
	Next nCntFor

EndIf
//


// Requisicao de Servico ...
If Len(aIteVO4) <> 0

	oProcJD:IncRegua2()

	For nCntFor := 1 to Len(aIteVO4)
		If Alltrim(aIteVO4[nCntFor,1,1]) == "LINPOS"
			OFNJD15AJ("BACKUP",@aAjProc,"VOI",1,(xFilial("VOI") + aIteVO4[nCntFor,1,3]),"VOI_ALTVLR",999)
		ElseIf Alltrim(aIteVO4[nCntFor,1,1]) == "VO4_NUMOSV" .and. Len(aIteVO4[nCntFor]) >= 2
			OFNJD15AJ("BACKUP",@aAjProc,"VOI",1,(xFilial("VOI") + aIteVO4[nCntFor,2,2]),"VOI_ALTVLR",999)
		EndIf
	Next

	// Controla alteracao do campo de valor de servico fixo por usuario ...
	If lVAIVALSER
		OFNJD15AJ("BACKUP",@aAjProc,"VAI",4,(xFilial("VAI")+__cUserID),"VAI_VALSER",999)
	EndIf
	//

	lMSHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| OFIOM030(,,x,y,z)},{},aIteVO4,2)
	If lMsErroAuto
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MostraErro()
		OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
		Return .f.
	Endif
	lMSHelpAuto := .f.
	//

EndIf
//

// Acerta o campo para considerar o valor do VO4
For nCont := 1 to Len(aSrvcVHRDIG)
	cSQL := "SELECT R_E_C_N_O_ VO4RECNO"
	cSQL +=  " FROM " + RetSQLName("VO4")
	cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
	cSQL +=   " AND VO4_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
	cSQL +=   " AND VO4_TIPTEM = '" + aSrvcVHRDIG[nCont,1] + "'"
	cSQL +=   " AND VO4_CODSER = '" + aSrvcVHRDIG[nCont,2] + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO4 , .F., .T. )
	While !(cAliasVO4)->(Eof())
		dbSelectArea("VO4")
		dbGoTo((cAliasVO4)->VO4RECNO)
		RecLock("VO4",.F.)
		VO4->VO4_VHRDIG := "1"
		VO4->(MsUnLock())
		(cAliasVO4)->(dbSkip())
	EndDo
	(cAliasVO4)->(dbCloseArea())
Next nCont
dbSelectArea("VMC")
//

oProcJD:IncRegua1("Ajustando PeÁas")
oProcJD:SetRegua2(4)

If Len(aProbPeca) > 0

	VAI->(DbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID))
	OFNJD15AJ("BACKUP",@aAjProc,"VAI",4,(xFilial("VAI") + __cUserID),"VAI_DEVPEC","1")
	VAI->(DbSetOrder(1))

	// Se nao foi adicionado registro na matriz, nao houve cancelamento de liberacao
	// a OS pode estar com status de liberada e ha necessidade de alterar requisicao ...
	If Len(aLiberar) == 0
		VO1->(dbSetOrder(1))
		VO1->(dbSeek(xFilial("VO1") + VMB->VMB_NUMOSV))
		RecLock("VO1",.F.)
		VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV,"A")
		VO1->(MsUnLock())
	EndIf

	SB1->(dbSetOrder(7))

	oProcJD:IncRegua2()

	// Converte UM quando necess·rio
	For nCont := 1 to Len(aProbPeca)

		If aProbPeca[nCont,1] == "Q" .and. aProbPeca[nCont,2] == "D"
			SB1->(dbSeek(xFilial("SB1") + aProbPeca[nCont,5] + aProbPeca[nCont,6]))
			If SB1->B1_UM <> aProbPeca[nCont,10]
				SB1->(dbSetOrder(1))
				nQtdeDev := Round( ConvUm(SB1->B1_COD,1, aProbPeca[nCont,7] ,1) , TamSX3( "VO3_QTDREQ" )[2] )
				aProbPeca[nCont,07] := nQtdeDev
				SB1->(dbSetOrder(7))
			EndIf
		EndIf

	Next nCont
	//

	// Devolve as pecas que deve ser devolvidas
	While .t.
		aAuxReqPec := {}
		aIteVO3 := {}
		nQtdeProc := 0
		nQtdeDev  := 0
		lProcAlgumaDev := .f.

		For nCont := 1 to Len(aProbPeca)

			// Problema de devolucao e ainda existem pendencias a serem processadas ...
			If aProbPeca[nCont,1] == "Q" .and. aProbPeca[nCont,2] == "D" .and. aProbPeca[nCont,7] > aProbPeca[nCont,11]

				aAuxReqPec := OM020007_MatrizDev( ;
						VO1->VO1_NUMOSV ,;
						aProbPeca[nCont,3] ,;
						aProbPeca[nCont,5] ,;
						aProbPeca[nCont,6] )

				If Len(aAuxReqPec) == 0
					DisarmTransaction()
					RollbackSx8()
					MsUnlockAll()
					FMX_HELP( "OFNJD15DEVREQ", STR0140 ) // "Quantidade requisitada È menor do que a quantidade que deve ser devolvida."
					OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
					Return .f.
				EndIf

				nQtdeSaldoReq := aAuxReqPec[1, 10] // Retorno da Funcao OM020007_MatrizDev

				nQtdeDev := aProbPeca[nCont,7] - aProbPeca[nCont,11]

				lProcAlgumaDev := .t.

				If nQtdeSaldoReq >= nQtdeDev
					nQtdeProc := nQtdeDev
				Else
					nQtdeProc := nQtdeSaldoReq
				EndIf

				aProbPeca[nCont,11] += nQtdeProc

				aAuxIteVO3 := {}
				AADD(aAuxIteVO3, { "VO3_NUMOSV" , VMB->VMB_NUMOSV , nil } )
				AADD(aAuxIteVO3, { "VO3_TIPTEM" , aProbPeca[nCont,3] , nil } )
				AADD(aAuxIteVO3, { "VO3_GRUITE" , aProbPeca[nCont,5] , nil } )
				AADD(aAuxIteVO3, { "VO3_CODITE" , aProbPeca[nCont,6] , nil } )
				AADD(aAuxIteVO3, { "VO3_QTDREQ" , nQtdeProc , nil } )
				AADD(aAuxIteVO3, { "VO3_QTDEST" , nQtdeProc , nil } )
				If VAI->VAI_FUNPRO=="1"
					AADD(aAuxIteVO3, { "VO3_PROREQ" , VAI->VAI_CODTEC , nil } )
				EndIf
				AADD( aIteVO3 , aClone( aAuxIteVO3 ) )

				If Len(aIteVO3) > 0

					lMSHelpAuto := .t.
					lMsErroAuto := .f.
					MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,3 /* Devolucao */ )
					if lMsErroAuto
						DisarmTransaction()
						RollbackSx8()
						MsUnlockAll()
						MostraErro()
						OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
						Return .f.
					Endif
					lMSHelpAuto := .f.

					aIteVO3 := {}

				EndIf

			EndIf

		Next nCont

		//
		// Todas as pecas ja foram devolvidas
		If aScan(aProbPeca , { |x| x[1] == "Q" .and. x[2] == "D" .and. x[7] <> x[11] }) == 0
			Exit
		Else
			If lProcAlgumaDev == .f.
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				FMX_HELP( "OFNJD15DEV", STR0141 ) // "N„o foi possÌvel realizar todas as devoluÁıes necess·rias."
				OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
				Return .f.
			EndIf
		EndIf

	EndDo
	SB1->(dbSetOrder(7))
	// Requisita Pecas que devem ser requisitas
	aIteVO3 := {}
	
	For nCont := 1 to Len(aProbPeca)

		If aProbPeca[nCont,1] == "Q" .and. aProbPeca[nCont,2] == "R"

			// Se ja foi processado
			If aProbPeca[nCont,11]
				Loop
			EndIf
			//

			// Requisicao referente a garantia Especial nao processa agora
			If aProbPeca[nCont,12]
				Loop
			EndIf
			//

			aProbPeca[nCont,11] := .t.

			SB1->(dbSeek(xFilial("SB1") + aProbPeca[nCont,5] + aProbPeca[nCont,6]))

			aAuxIteVO3 := {}
			AADD(aAuxIteVO3, { "VO3_NUMOSV" , VMB->VMB_NUMOSV , nil } )
			AADD(aAuxIteVO3, { "VO3_TIPTEM" , aProbPeca[nCont,3] , nil } )

			If !Empty(aProbPeca[nCont,16])
				AADD(aAuxIteVO3, { "VO3_FATPAR" , aProbPeca[nCont,16] , nil } )
				AADD(aAuxIteVO3, { "VO3_LOJA"   , aProbPeca[nCont,17] , nil } )
			EndIf

			AADD(aAuxIteVO3, { "VO3_GRUITE" , aProbPeca[nCont,5] , nil } )
			AADD(aAuxIteVO3, { "VO3_CODITE" , aProbPeca[nCont,6] , nil } )

			If SB1->B1_UM == aProbPeca[nCont,10]
				AADD(aAuxIteVO3, { "VO3_QTDREQ" , aProbPeca[nCont,7] , nil } )
				AADD(aAuxIteVO3, { "VO3_QTDEST" , aProbPeca[nCont,7] , nil } )
			Else
				SB1->(dbSetOrder(1))
				//nQtde := Round( ConvUm(SB1->B1_COD,nQtde,1,2) , TamSX3( "VMC_QTDPEC" )[2] )
				aProbPeca[nCont,7] := Round( ConvUm(SB1->B1_COD,1,aProbPeca[nCont,7],1) , TamSX3( "VO3_QTDREQ" )[2] )
				AADD(aAuxIteVO3, { "VO3_QTDREQ" , aProbPeca[nCont,7] , nil } )
				AADD(aAuxIteVO3, { "VO3_QTDEST" , aProbPeca[nCont,7] , nil } )
				SB1->(dbSetOrder(7))
			EndIf

			If !Empty(aProbPeca[nCont,14])
				AADD(aAuxIteVO3, { "VO3_PROREQ" , aProbPeca[nCont,14] , nil } )
			Else
				If VAI->VAI_FUNPRO=="1"
					AADD(aAuxIteVO3, { "VO3_PROREQ" , VAI->VAI_CODTEC , nil } )
				EndIf
			EndIf

			// Operacao
			If !Empty(aProbPeca[nCont,13])
				AADD(aAuxIteVO3, { "VO3_OPER" , aProbPeca[nCont,13] , nil } )
			EndIf

			// TES
			If !Empty(aProbPeca[nCont,09])
				AADD(aAuxIteVO3, { "VO3_CODTES" , aProbPeca[nCont,09] , nil } )
			EndIf

			If !Empty(aProbPeca[nCont,15])
				AADD(aAuxIteVO3, { "VO3_DEPINT" , aProbPeca[nCont,15] , nil } )
			EndIf

			For nPosGet := 1 to Len(oGetPeca:aCols)
				For nContPc := 1 to Len(aCpoCustomizado)
					If aCpoCustomizado[nContPc,1] == "PECAS"
						cAuxCpo := "PEC_" + Right(aCpoCustomizado[nContPc,2],Len(aCpoCustomizado[nContPc,2])-4)
						If !Empty(oGetPeca:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHPeca")])
							AADD(aAuxIteVO3, { aCpoCustomizado[nContPc,2] , oGetPeca:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHPeca")] , nil } )
						EndIf
					EndIf
				Next nContPc
			Next nPosGet
			AADD( aIteVO3 , aClone( aAuxIteVO3 ) )
		EndIf

	Next nCont

	oProcJD:IncRegua2()

	If Len(aIteVO3) > 0
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,2 /* Requisita */ )
		if lMsErroAuto
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MostraErro()
			OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
			Return .f.
		Endif
		lMSHelpAuto := .f.
	EndIf

	cAuxTipTem := ""
	SB1->(dbSetOrder(7))
	If VMB->VMB_TIPGAR == "ZSPA" .or. VMB->VMB_TIPGAR == "ZPIP"

		oProcJD:IncRegua2()

		While .t.

			cAuxTipTem := ""
			aIteVO3 := {}

			For nCont := 1 to Len(aProbPeca)

				If aProbPeca[nCont,1] == "Q" .and. aProbPeca[nCont,2] == "R"

					// Se ja foi processado
					If aProbPeca[nCont,11]
						Loop
					EndIf
					//

					// So processa registro de garantia especial ...
					If !aProbPeca[nCont,12]
						Loop
					EndIf
					//

					If Empty(cAuxTipTem)
						cAuxTipTem := aProbPeca[nCont,3]
					EndIf

					If !cAuxTipTem == aProbPeca[nCont,3]
						Loop
					EndIf

					aProbPeca[nCont,11] := .t.

					SB1->(dbSeek(xFilial("SB1") + aProbPeca[nCont,5] + aProbPeca[nCont,6]))

					aAuxIteVO3 := {}
					AADD(aAuxIteVO3, { "VO3_NUMOSV" , VMB->VMB_NUMOSV , nil } )
					AADD(aAuxIteVO3, { "VO3_TIPTEM" , aProbPeca[nCont,3] , nil } )

					If !Empty(aProbPeca[nCont,16])
						AADD(aAuxIteVO3, { "VO3_FATPAR" , aProbPeca[nCont,16] , nil } )
						AADD(aAuxIteVO3, { "VO3_LOJA"   , aProbPeca[nCont,17] , nil } )
					EndIf

					AADD(aAuxIteVO3, { "VO3_GRUITE" , aProbPeca[nCont,5] , nil } )
					AADD(aAuxIteVO3, { "VO3_CODITE" , aProbPeca[nCont,6] , nil } )
					AADD(aAuxIteVO3, { "VO3_CODTES" , aProbPeca[nCont,9] , nil } )

					If SB1->B1_UM == aProbPeca[nCont,10]
						AADD(aAuxIteVO3, { "VO3_VALPEC" , aProbPeca[nCont,8] , nil } )
						AADD(aAuxIteVO3, { "VO3_VALLIQ" , aProbPeca[nCont,8] , nil } )

						AADD(aAuxIteVO3, { "VO3_QTDREQ" , aProbPeca[nCont,7] , nil } )
						AADD(aAuxIteVO3, { "VO3_QTDEST" , aProbPeca[nCont,7] , nil } )
					Else
						SB1->(dbSetOrder(1))
						aProbPeca[nCont,7] := Round( ConvUm(SB1->B1_COD,1,aProbPeca[nCont,7],1) , TamSX3( "VO3_QTDREQ" )[2] )
						AADD(aAuxIteVO3, { "VO3_QTDREQ" , aProbPeca[nCont,7] , nil } )
						AADD(aAuxIteVO3, { "VO3_QTDEST" , aProbPeca[nCont,7] , nil } )
						SB1->(dbSetOrder(7))
					EndIf

					If !Empty(aProbPeca[nCont,14])
						AADD(aAuxIteVO3, { "VO3_PROREQ" , aProbPeca[nCont,14] , nil } )
					Else
						If VAI->VAI_FUNPRO=="1"
							AADD(aAuxIteVO3, { "VO3_PROREQ" , VAI->VAI_CODTEC , nil } )
						EndIf
					EndIf

					If !Empty(aProbPeca[nCont,15])
						AADD(aAuxIteVO3, { "VO3_DEPINT" , aProbPeca[nCont,15] , nil } )
					EndIf

					For nPosGet := 1 to Len(oGetPeca:aCols)
						For nContPc := 1 to Len(aCpoCustomizado)
							If aCpoCustomizado[nContPc,1] == "PECAS"
								cAuxCpo := "PEC_" + Right(aCpoCustomizado[nContPc,2],Len(aCpoCustomizado[nContPc,2])-4)
								If !Empty(oGetPeca:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHPeca")])
									AADD(aAuxIteVO3, { aCpoCustomizado[nContPc,2] , oGetPeca:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHPeca")] , nil } )
								EndIf
							EndIf
						Next nContPc
					Next nPosGet

					AADD( aIteVO3 , aClone( aAuxIteVO3 ) )
				EndIf

			Next nCont
			If Len(aIteVO3) > 0
				lMSHelpAuto := .t.
				lMsErroAuto := .f.
				MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,2 /* Requisita */ )
				if lMsErroAuto
					DisarmTransaction()
					RollbackSx8()
					MsUnlockAll()
					MostraErro()
					OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
					Return .f.
				Endif
				lMSHelpAuto := .f.
			EndIf

			If aScan(aProbPeca, { |x| x[1] == "Q" .and. x[2] == "R" .and. !x[11] } ) == 0
				Exit
			EndIf

		EndDo

	EndIf
	//

	// Acerta valor unitario de pecas
	For nCont := 1 to Len(aProbPeca)

		// Se o problema for valor, acerta o valor das pecas ...
		If aProbPeca[nCont,1] == "V"

			cSQL := "SELECT R_E_C_N_O_ VO3RECNO "
			cSQL +=  " FROM " + RetSQLName("VO3")
			cSQL += " WHERE VO3_FILIAL = '" + xFilial("VO3") + "'"
			cSQL +=   " AND VO3_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
			cSQL +=   " AND VO3_TIPTEM = '" + aProbPeca[nCont,2] + "'"
			//cSQL +=   " AND VO3_LIBVOO = '" + aProbPeca[nCont,3] + "'"
			cSQL +=   " AND VO3_GRUITE = '" + aProbPeca[nCont,4] + "'"
			cSQL +=   " AND VO3_CODITE = '" + aProbPeca[nCont,5] + "'"
			cSQL +=   " AND D_E_L_E_T_ = '  '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO3 , .F., .T. )
			While !(cAliasVO3)->(Eof())
				dbSelectArea("VO3")
				dbGoTo((cAliasVO3)->VO3RECNO)
				RecLock("VO3",.F.)
				// Houve conversao de unidade de medida na transmissao
				If aProbPeca[nCont,09]
					nVlrUnit := aProbPeca[nCont,6] / aProbPeca[nCont,7]
					nVlrUnit := Round(nVlrUnit * aProbPeca[nCont,10], TamSX3("VO3_VALPEC")[2])
					VO3->VO3_VALPEC := nVlrUnit
					VO3->VO3_VALLIQ := nVlrUnit
				Else
					VO3->VO3_VALPEC := Round(aProbPeca[nCont,6] / aProbPeca[nCont,7] , TamSX3("VO3_VALPEC")[2])
					VO3->VO3_VALLIQ := Round(aProbPeca[nCont,6] / aProbPeca[nCont,7] , TamSX3("VO3_VALPEC")[2])
				EndIf
				VO3->VO3_VALDES := 0
				(cAliasVO3)->(dbSkip())
			EndDo
			(cAliasVO3)->(dbCloseArea())
			dbSelectArea("VMC")

			// Marca VOO para recalculo ...
			If aScan(aRecalVOO, { |x| x[1] == aProbPeca[nCont,2] .and. x[2] == aProbPeca[nCont,3] }) == 0
				AADD( aRecalVOO , { aProbPeca[nCont,2] , aProbPeca[nCont,3] } )
			EndIf
			//

		EndIf
	Next nCont
EndIf

oProcJD:IncRegua1(STR0170) // Liberando Tipo de Tempo

// Se houve cancelamento da liberacao, ent„o È necess·rio liberar novamente ...
If Len(aLiberar) > 0

	oProcJD:SetRegua2(Len(aLiberar))

	cAuxTipTem := ""
	aEval( aLiberar , { |x| cAuxTipTem += x + "," } )
	cAuxTipTem := FormatIN(Left(cAuxTipTem,Len(cAuxTipTem)-1),",")

	aPeca := FMX_CALPEC( VMB->VMB_NUMOSV , , /* cGruIte */ , /* cCodIte */ , .t. /* lMov */   , .f. /* lNegoc */ , .t. /* lReqZerada */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan */ , /* cLibVOO */ , " VO3_TIPTEM IN " + cAuxTipTem )
	aSrvc := FMX_CALSER( VMB->VMB_NUMOSV , , /* cGruSer */ , /* cCodSer */ , .t. /* lApont */ , .f. /* lNegoc */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan*/ , /* cLibVOO */ , " VO4_TIPTEM IN " + cAuxTipTem  )
	For nCont := 1 to Len(aLiberar)

		If aScan(aPeca , { |x| x[PECA_TIPTEM] == aLiberar[nCont] } ) == 0 .and. aScan(aSrvc , { |x| x[SRVC_TIPTEM] == aLiberar[nCont] } ) == 0
			Loop
		EndIf

		oProcJD:IncRegua2(VMB->VMB_NUMOSV + "-" + aLiberar[nCont])

		aCabLib := {}
		aAdd(aCabLib ,{"VO1_NUMOSV" , VMB->VMB_NUMOSV , Nil }) // Numero do pedido
		aAdd(aCabLib ,{"TIPTEM"     , aLiberar[nCont] , Nil }) // Tipo de pedido

		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| OFIOM140(x,y,z)},,aCabLib,2)
		If lMsErroAuto
			DisarmTransaction()
			MsUnlockAll()
			MostraErro()
			OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
			Return .f.
		EndIf
		lMSHelpAuto := .f.
	Next nCont

EndIf
//

// Se n„o foi liberado nada, atualiza o Status da OS
If Len(aLiberar) == 0
	VO1->(dbSetOrder(1))
	VO1->(dbSeek(xFilial("VO1") + VMB->VMB_NUMOSV))
	RecLock("VO1",.F.)
	VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV," ")
	VO1->(MsUnLock())
EndIf
//

// Se houver necessidade de atualizar o total da liberacao ...
If Len(aRecalVOO) > 0
	For nCont := 1 to Len(aRecalVOO)
		// Se o TT foi liberado novamente nao ha necessidade de recalcular valores de liberacao ..
		If aScan(aLiberar, aRecalVOO[nCont]) == 0

			// Verifica se ainda existe o registro do VOO
			VOO->(dbSetOrder(1))
			If !VOO->(dbSeek(xFilial("VOO") + VMB->VMB_NUMOSV + aRecalVOO[nCont,1] + aRecalVOO[nCont,2] ))
				Loop
			EndIf

			OM140RECAL( VMB->VMB_NUMOSV , aRecalVOO[nCont,1] , aRecalVOO[nCont,2] )
		EndIf
	Next nCont
EndIf
//

oProcJD:IncRegua1(STR0171) // Atualizando SolicitaÁ„o de Garantia

// Atualiza S.G.
dbSelectArea("VMB")
DbGoto(nSvRecVMB)

RecLock("VMB",.f.)
VMB->VMB_STATSG := "1"
VMB->(MsUnLock())
//

// Atualiza numero da liberacao do VOO
aPeca := FMX_CALPEC( VMB->VMB_NUMOSV , /* cTipTem */ , /* cGruIte */ , /* cCodIte */ , .f. /* lMov */ , .f. /* lNegoc */ , .f. /* lReqZerada */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan */ , /* cLibVOO */ , )
aSrvc := FMX_CALSER( VMB->VMB_NUMOSV , /* cTipTem */ ,  /* cGruSer */ ,  /* cCodSer */ , .f.  /* lApont */ , .f. /* lNegoc */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan*/ , /* cLibVOO */ , )

oProcJD:SetRegua2( Len(aPeca) + Len(aSrvc) )

VMC->(dbSetOrder(1))
VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR ))
While !VMC->(Eof()) .AND. VMC->VMC_FILIAL == xFilial("VMC") .AND. VMC->VMC_CODGAR == VMB->VMB_CODGAR

	oProcJD:IncRegua2()

	cAuxLibVOO := ""

	Do Case
	// Peca
	Case VMC->VMC_TIPOPS == "P" .or. (VMC->VMC_TIPOPS == "O" .AND. !Empty(VMC->VMC_CODITE))
		If (nPos := aScan(aPeca , { |x| x[PECA_TIPTEM] == VMC->VMC_TIPTEM .and. x[PECA_GRUITE] == VMC->VMC_GRUITE .and. x[PECA_CODITE] == VMC->VMC_CODITE } )) <> 0
			cAuxLibVOO := aPeca[nPos,PECA_LIBVOO]
		EndIf

	// Servico
	Case VMC->VMC_TIPOPS == "S"
		If (nPos := aScan(aSrvc , { |x| x[SRVC_TIPTEM] == VMC->VMC_TIPTEM .and. x[SRVC_CODSER] == VMC->VMC_CODSER } )) <> 0
			cAuxLibVOO := aSrvc[nPos,SRVC_LIBVOO]
		EndIf

	// Outros Creditos
	Case VMC->VMC_TIPOPS == "O" .and. Empty(VMC->VMC_CODITE)
		If (nPos := aScan(aSrvc , { |x| x[SRVC_TIPTEM] == VMC->VMC_TIPTEM .and. x[SRVC_CODSER] == VMC->VMC_CODSER } )) <> 0
			cAuxLibVOO := aSrvc[nPos,SRVC_LIBVOO]
		EndIf

	EndCase

	RecLock("VMC",.F.)
	VMC->VMC_LIBVOO := cAuxLibVOO
	MsUnlock()

	VMC->(dbSkip())
EndDo
//

// Grava alteracoes nas tabela de itens da Solicitacao de Garantia ...
dbSelectArea("VMC")
If lTemPeca
	For nCont := 1 to Len(aAddVMC[1])

		nPosaProb := aScan( aProbPeca , { |x| x[3]== aAddVMC[1,nCont,1] .AND. x[5] == aAddVMC[1,nCont,2] .AND. x[6] == aAddVMC[1,nCont,3] } )
		nPosaVMCP := aScan( aVMCPeca , { |x| x[3] == aAddVMC[1,nCont,2].AND. x[4] == aAddVMC[1,nCont,3] } )

		RecLock("VMC",.t.)
		VMC->VMC_FILIAL := xFilial("VMC")
		VMC->VMC_CODGAR := VMB->VMB_CODGAR
		VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
		VMC->VMC_ORIGEM := "3"
		VMC->VMC_TIPTEM := aAddVMC[1,nCont,1]
		VMC->VMC_GRUITE := aAddVMC[1,nCont,2]
		VMC->VMC_CODITE := aAddVMC[1,nCont,3]
		VMC->VMC_QTDPEC := aAddVMC[1,nCont,4]
		VMC->VMC_QPCRET := aAddVMC[1,nCont,5]

		VMC->VMC_TIPOPS := "P"
		VMC->VMC_PARTNO := aAddVMC[1,nCont,3]
		VMC->VMC_UM		:= aProbPeca[nPosaProb,10]
		VMC->VMC_VUPECE	:= aVMCPeca[nPosaVMCP,9]
		VMC->VMC_VTPECE	:= aVMCPeca[nPosaVMCP,11]
		VMC->VMC_VUPECR	:= aProbPeca[nPosaProb,8]
		VMC->VMC_VTPECR	:= aProbPeca[nPosaProb,7]*aProbPeca[nPosaProb,8]

		MsUnLock()
	Next nCont
EndIf
If lTemSrvc
	For nCont := 1 to Len(aAddVMC[2])
		RecLock("VMC",.t.)
		VMC->VMC_FILIAL := xFilial("VMC")
		VMC->VMC_CODGAR := VMB->VMB_CODGAR
		VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
		VMC->VMC_ORIGEM := "3"
		VMC->VMC_TIPOPS := "S"
		VMC->VMC_TIPTEM := aAddVMC[2,nCont,1]
		VMC->VMC_GRUSER := aAddVMC[2,nCont,2]
		VMC->VMC_CODSER := aAddVMC[2,nCont,3]
		VMC->VMC_QTDTRA := aAddVMC[2,nCont,4] / 100
		VMC->VMC_QSRRET := aAddVMC[2,nCont,5] / 100
		MsUnLock()
	Next nCont
EndIf
If lTemOutr
	For nCont := 1 to Len(aAddVMC[3])
		If aAddVMC[3,nCont,6] > 0
			VMC->(DbGoto(aAddVMC[3,nCont,6]))
			RecLock("VMC",.f.)
			VMC->VMC_TIPTEM := aAddVMC[3,nCont,1]
			VMC->VMC_GRUSER := aAddVMC[3,nCont,2]
			VMC->VMC_CODSER := aAddVMC[3,nCont,3]
		Else
			RecLock("VMC",.t.)
			VMC->VMC_FILIAL := xFilial("VMC")
			VMC->VMC_CODGAR := VMB->VMB_CODGAR
			VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
			VMC->VMC_ORIGEM := "3"
			VMC->VMC_TIPOPS := "O"
			VMC->VMC_TIPTEM := aAddVMC[3,nCont,1]
			VMC->VMC_GRUSER := aAddVMC[3,nCont,2]
			VMC->VMC_CODSER := aAddVMC[3,nCont,3]
			VMC->VMC_CUSMAT := aAddVMC[3,nCont,4]
			VMC->VMC_CUSMAR := aAddVMC[3,nCont,5]
		Endif

		//Otavio 10/04/2014 - O LIBVOO ja foi encontrado para todos os VMCs anteriormente utilizando TT e CODSER.
		// No entanto, este registro de VMC est· sendo incluso/alterado agora. Temos ent„o que gravar seu LIBVOO agora tambÈm.
		If (nPos := aScan(aSrvc , { |x| x[SRVC_TIPTEM] == VMC->VMC_TIPTEM .and. x[SRVC_CODSER] == VMC->VMC_CODSER } )) <> 0
			VMC->VMC_LIBVOO := aSrvc[nPos,SRVC_LIBVOO]
		EndIf
		MsUnLock()

	Next nCont
EndIf

// Ajusta mensagem para nota fiscal
If MV_PAR39 == 1 .OR. !Empty(MV_PAR40)
	cSQL := "SELECT DISTINCT VOO.R_E_C_N_O_ VOORECNO " +;
		" FROM " + RetSQLName("VMC") + " VMC " +;
		" JOIN " + RetSQLName("VOO") + " VOO ON VOO.VOO_FILIAL = '" + xFilial("VOO") + "' AND VOO.VOO_NUMOSV = '" + VMB->VMB_NUMOSV + "' AND VOO.VOO_LIBVOO = VMC.VMC_LIBVOO AND VOO.D_E_L_E_T_ = ' '" +;
		" WHERE VMC.VMC_FILIAL = '" + xFilial("VMC") + "'" +;
		" AND VMC.VMC_CODGAR = '" + VMB->VMB_CODGAR + "'" +;
		" AND VMC.VMC_LIBVOO <> '  '" +;
		" AND VMC.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC , .F., .T. )
	dbSelectArea("VOO")
	While !(cAliasVMC)->(Eof())
		VOO->(dbGoTo( (cAliasVMC)->VOORECNO))
		RecLock("VOO",.F.)
		If MV_PAR39 == 1
			If VOO->VOO_TOTPEC <> 0
				VOO->VOO_MNNOTP := AllTrim(RetTitle("VV1_CHASSI")) + ": " + ALlTrim(VMB->VMB_CHASSI) + " - " + AllTrim(RetTitle("VO1_NUMOSV")) + ": " + VMB->VMB_NUMOSV
			EndIf
			If VOO->VOO_TOTSRV <> 0
				VOO->VOO_MNNOTS := AllTrim(RetTitle("VV1_CHASSI")) + ": " + ALlTrim(VMB->VMB_CHASSI) + " - " + AllTrim(RetTitle("VO1_NUMOSV")) + ": " + VMB->VMB_NUMOSV
			EndIf
		EndIf
		If !Empty(MV_PAR40)
			If VOO->VOO_TOTPEC <> 0
				VOO->VOO_MNPADP := MV_PAR40
			EndIf
			If VOO->VOO_TOTSRV <> 0
				VOO->VOO_MNPADS := MV_PAR40
			EndIf
		EndIf
		MsUnlock()
		(cAliasVMC)->(dbSkip())
	EndDo
	(cAliasVMC)->(dbCloseArea())
	DbSelectArea("VMB")
Endif
//

// Verifica se os valores foram ajustados corretamente
If ! OFNJD15018_ValoresCorretos(VMB->VMB_NUMOSV)
	If lDebug
		MsgStop(STR0224) // "N„o foi possÌvel atualizar a Ordem de ServiÁo corretamente."
	Else
		DisarmTransaction()
		MsUnlockAll()
		OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
		MsgStop(STR0224) // "N„o foi possÌvel atualizar a Ordem de ServiÁo corretamente."
		Return .f.
	EndIf
EndIf

// Volta o conteudo original dos campos que foram alterados para processamento da alteracao da OS
OFNJD15AJ("RESTORE",aAjProc)

End Transaction

MsgInfo(STR0050) // "OS atualizada"

Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15AJ  ∫ Autor ≥ Rubens             ∫ Data ≥ 10/02/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Grava/Restaura campos que devem ser modificados no momento ∫±±
±±∫          ≥ da atualizacao da OS.                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15AJ(cTpProc,aAjProc,cTabela,nIndice,cChaveSeek,cCampo,nXValor)

Local aAuxArea := GetArea()
Local nCntFor
Local aAreaAJ

Do Case
Case cTpProc == "BACKUP"
	dbSelectArea(cTabela)
	aAreaAJ := GetArea()
	dbSetOrder(nIndice)
	If MsSeek(cChaveSeek)
		AADD( aAjProc , { cTabela, cCampo, &(cCampo), Recno() })
		RecLock(cTabela,.f.)
		&(cCampo) := nXValor
		MsUnlock()
	Endif
	RestArea(aAreaAJ)
Case cTpProc == "RESTORE"
	For nCntFor := 1 to Len(aAjProc)
		dbSelectArea(aAjProc[nCntFor,1])
		aAreaAJ := GetArea()
		dbGoto(aAjProc[nCntFor,4])
		RecLock(aAjProc[nCntFor,1],.f.)
		&(aAjProc[nCntFor,2]) := aAjProc[nCntFor,3]
		MsUnlock()
		RestArea(aAreaAJ)
	Next
EndCase

RestArea(aAuxArea)

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15CTT ∫ Autor ≥ Rubens             ∫ Data ≥ 11/08/14  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Cancela Tipo de tempo para atualizacao de OS               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15CTT(cNumOsv,cTipTem,cLibVOO,aLiberar)

Local lRetorno := .t.
Local aCabCanc := {}

// Marca TT para liberar novamente
If aScan(aLiberar,cTipTem) == 0
	AADD( aLiberar , cTipTem )
EndIf
//

VOO->(dbSetOrder(1))
// Se n„o encontrou, provavelmente Liberacao ja foi cancelada ...
If !VOO->(dbSeek(xFilial("VOO") + cNumOsv + cTipTem + cLibVOO ))
	Return .t.
EndIf

// Cancela liberacao do tipo de tempo ...
aAdd(aCabCanc ,{"VO1_NUMOSV" , cNumOsv			, Nil })	// Ordem de Servico
aAdd(aCabCanc ,{"TIPTEM"     , cTipTem			, Nil })	// Tipo de pedido
aAdd(aCabCanc ,{"LIBVOO"     , cLibVOO			, Nil })	// Liberacao VOO
aAdd(aCabCanc ,{"MOTIVO"     , cMotCancela	, Nil })	// Motivo do cancelamento

lMSHelpAuto := .t.
lMsErroAuto := .f.
MSExecAuto({|x,y,z| OFIOM150(x,y,z)},,aCabCanc,2)
If lMsErroAuto
	DisarmTransaction()
	MsUnlockAll()
	MostraErro()
	lRetorno := .f.
EndIf
lMSHelpAuto := .f.

Return lRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15REST ∫ Autor ≥ Rubens            ∫ Data ≥ 11/08/14  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Volta aCols das GetDados quando acontece altum erro na     ∫±±
±±∫          ≥ atualizacao da OS                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15REST(aBkpAColsP,aBkpAColsS,aBkpAColsO)
If lTemPeca
	oGetPeca:aCols := aClone(aBkpAColsP)
EndIf
If lTemSrvc
	oGetSrvc:aCols := aClone(aBkpAColsS)
EndIf
If lTemOutr
	oGetOutr:aCols := aClone(aBkpAColsO)
EndIf
Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15UH ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Valida a quantidade utilizada                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15UH(dtFalha,cChassi,nQtde,cUn,cCodGar,lMostraErr)

Local cSQL
Local nCont   := 0
Local aFilAtu := FWArrFilAtu()
Local aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cFilVMB := "("
Local cBkpFilAnt := cFilAnt
//Local cAl     := GetNextAlias()
Local nRecVMB := 0
Local cErrMsg, oReg, aDados
Local lValid := .T.

Default dtFalha    := M->VMB_DTFALH
Default cChassi    := M->VMB_CHASSI
Default nQtde      := M->VMB_QTDUTI
Default cUn        := M->VMB_UNIMED
Default cCodGar    := M->VMB_CODGAR
Default lMostraErr := .F.


For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	cFilVMB += "'"+xFilial("VMB")+"',"
Next
cFilAnt := cBkpFilAnt
cFilVMB := left(cFilVMB,len(cFilVMB)-1)+")"

If !Empty(cCodGar)
	cSQL 	:= "SELECT R_E_C_N_O_ RECVMB "
	cSQL 	+=  " FROM "+RetSqlName("VMB")
	cSQL 	+= " WHERE VMB_FILIAL IN "+cFilVMB
	cSQL 	+=   " AND VMB_CHASSI =  '" + cChassi + "'"
	cSQL 	+=   " AND VMB_CODGAR =  '" + cCodGar + "'"
	cSQL 	+=   " AND D_E_L_E_T_=' '"
	nRecVMB := FM_SQL(cSQL)
EndIf

cSQL := "SELECT VMB_QTDUTI, VMB_DTFALH, VMB_CODGAR "
cSQL +=  " FROM "+RetSqlName("VMB")
cSQL += " WHERE VMB_FILIAL IN "+cFilVMB
cSQL +=   " AND VMB_CHASSI =  '" + cChassi + "'"
cSQL +=   " AND VMB_DTFALH <= '" + DtoS(dtFalha) + "'"
If !Empty(cCodGar)
	cSQL +=   " AND R_E_C_N_O_ <>  '" + AllTrim(Str(nRecVMB)) + "'"
EndIf
cSQL +=   " AND D_E_L_E_T_=' '"
cSQL +=   " ORDER BY R_E_C_N_O_ DESC"
cSQL := oSqlHpl:TOPFunc(cSQL, 1)
aDados := oSqlHpl:GetSelect({;
	{'campos', {"VMB_QTDUTI", "VMB_DTFALH", "VMB_CODGAR"}},;
	{'query' , cSQL} ;
})
If LEN(aDados) > 0
	oReg := aDados[1]
	nRet := oReg:GetValue("VMB_QTDUTI")
	If nRet <> 0 .and. nRet > nQtde
		lValid := .F.
	EndIf
EndIf
If lValid
	cSQL := "SELECT VMB_QTDUTI, VMB_DTFALH, VMB_CODGAR "
	cSQL +=  " FROM "+RetSqlName("VMB")
	cSQL += " WHERE VMB_FILIAL IN "+cFilVMB
	cSQL +=   " AND VMB_CHASSI =  '" + cChassi + "'"
	cSQL +=   " AND VMB_DTFALH > '" + DtoS(dtFalha) + "'"
	If !Empty(cCodGar)
		cSQL +=   " AND R_E_C_N_O_ <>  '" + AllTrim(Str(nRecVMB)) + "'"
	EndIf
	cSQL +=   " AND D_E_L_E_T_=' '"
	cSQL +=   " ORDER BY R_E_C_N_O_"
	cSQL := oSqlHpl:TOPFunc(cSQL, 1)
	aDados := oSqlHpl:GetSelect({;
		{'campos', {"VMB_QTDUTI", "VMB_DTFALH", "VMB_CODGAR"}},;
		{'query' , cSQL} ;
	})
	if LEN(aDados) > 0
		oReg := aDados[1]
		nRet := oReg:GetValue("VMB_QTDUTI")
		If nRet <> 0 .and. nRet < nQtde
			lValid := .F.
		Endif
	endif
EndIf
if lMostraErr .and. ! lValid
	cErrMsg := STR0004
	cErrMsg += chr(13) + chr(10) + STR0132 /*"Por favor, verifique as informaÁıes abaixo:"*/
	cErrMsg += chr(13) + chr(10)
	cErrMsg += chr(13) + chr(10) + STR0225 /* "Data da falha desta S.G.: "*/      + DTOC(dtFalha)
	cErrMsg += chr(13) + chr(10) + STR0134 /*"HorÌmetro informado nesta S.G.: "*/ + ALLTRIM(STR(nQtde))
	cErrMsg += chr(13) + chr(10)
	cErrMsg += chr(13) + chr(10) + STR0135 /*"Dados da S.G. anterior"*/
	cErrMsg += chr(13) + chr(10) + STR0138 /*"N˙mero da S.G. Protheus: "*/ + ALLTRIM(oReg:GetValue('VMB_CODGAR'))
	cErrMsg += chr(13) + chr(10) + STR0226 /* "Data da falha: "*/      + DTOC(STOD(oReg:GetValue('VMB_DTFALH')))
	cErrMsg += chr(13) + chr(10) + STR0137 /*"HorÌmetro informado: "*/ + ALLTRIM(STR(oReg:GetValue('VMB_QTDUTI')))

	MsgAlert(cErrMsg, STR0111) // MSGMONTADA | AtenÁ„o
endif
Return lValid


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15CG ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Verifica se um equipamento est· em garantia                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15CG(cChassi, dDtFalha, nQtdUti, cUN, cTipoGar, cStatProp)

Local nCont1
Local nCont2
Local oWS
Local lRet := .f.
Local cAuxMsg := ""

Private lProcessado := .f.

If cTipoGar <> "ZNRM"
	Return .t.
EndIf

// Verificar se o equipamento esta em garantia ...
oWS := WSJohnDeere_Garantia():New("RetrieveWarrantyInfo")
//oWS:SetDebug()
oWS:oRetrieveWarInfo_INPUT:cPin := AllTrim(cChassi)
MsgRun(STR0051,STR0031,{|| lProcessado := oWS:RetrieveWarrantyInfo() }) // "Consultando registro de garantia"
If !lProcessado
	oWS:ExibeErro("RetrieveWarrantyInfo")
	MsgStop(STR0052) // "N„o È possÌvel continuar, pois n„o foi possÌvel consultar o status da garantia do equipamento"
	Return .f.
EndIf

// Se for garantia normal e o Status È vendido, deve existir um registro de garantia do tipo B
If cTipoGar == "ZNRM"

	For nCont1 := 1 to Len(oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER)
		nPos := 0

		// Vendido
		If cStatProp == "1"
			// B - Garantia Basica
			// Q - Limitada Basica
			// X - Extended Warranty (Comprehensive)
			// P - Extended Warranty (Powertrain)
			// H - Extended Warranty (Powertrain & Hydraulic)
			// G - Extended Warranty (Engine)
			If oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:cWARRANTY_TYPE $ "B/Q/X/P/H/G"
				nPos := nCont1
			EndIf
		EndIf

		// Em Estoque ou Demonstracao
		If cStatProp == "2" .or. cStatProp == "4"
			If oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:cWARRANTY_TYPE == "D"
				nPos := nCont1
			EndIf
		EndIf

		If nPos <> 0
			//lRet := .f.
			If dDtFalha >= oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nPos]:dSTARTDATE .and. dDtFalha <= oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nPos]:dEXPIREDATE
				lRet := .t.
			EndIf

			cAuxMsg += STR0003 + ": " + oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:cWARRANTY_TYPE + CHR(13) + CHR(10) + ; // Tipo de Garantia
				STR0172 + ": " + DtoC(oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nPos]:dSTARTDATE) + CHR(13) + CHR(10) + ; // Data de inÌcio da garantia
				STR0173 + ": " + DtoC(oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nPos]:dEXPIREDATE) + CHR(13) + CHR(10) // Data de fim da garantia

			If lRet
				For nCont2 := 1 to Len(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS)
					If oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cWARRANTY_TYPE == oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nPos]:cWARRANTY_TYPE
						If oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cLIMIT_TYPE == cUN
							If nQtdUti > Val(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cLIMIT_VALUE)
								lRet := .f.
							EndIf
							cAuxMsg += STR0174 + ": " + oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cLIMIT_TYPE + CHR(13) + CHR(10) + ; // Unidade de medida
								STR0175 + ": " + AllTrim(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cLIMIT_VALUE) // Quantidade
						EndIf
					EndIf
				Next nCont2
			EndIf
		EndIf

	Next nCont1

	If !lRet

		// Verifica se est· coberto pela garantia de motor.
		For nCont1 := 1 to Len(oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER)
			If oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:cWARRANTY_TYPE == "E"
				If dDtFalha >= oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:dSTARTDATE .and. dDtFalha <= oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:dEXPIREDATE
					lRet := .t.
				EndIf
				If lRet
					For nCont2 := 1 to Len(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS)
						If oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cWARRANTY_TYPE == oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont1]:cWARRANTY_TYPE
							If oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cLIMIT_TYPE == cUN
								If nQtdUti > Val(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont2]:cLIMIT_VALUE)
									lRet := .f.
								EndIf
							EndIf
						EndIf
					Next nCont2
				EndIf

				If lRet
					MsgInfo(STR0053)
				EndIf
			EndIf
		Next nCont1
		//
	EndIf
EndIf
//

If !lRet

	If Empty(cAuxMsg)

		If cStatProp == "1" 

			// Verifica se a maquina esta com status de NOVA na JOhn Deere. 
			For nCont1 := 1 to Len(oWS:oOUTPUT:oE_MACHINESTATUS)
				If oWS:oOUTPUT:oE_MACHINESTATUS[nCont1]:cMACHINESTATUS == "NEW"
					cAuxMsg += STR0241 + CHR(13) + CHR(10) +; // "N„o foi possÌvel encontrar um critÈrio de garantia v·lido para a m·quina. M·quina com status de NOVA no portal da John Deere e o status da m·quina informada na solicitaÁ„o de garantia podem ser incompatÌveis."
						STR0242 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +; // "Verifique se o status da m·quina no portal e o status da solicitaÁ„o de garantia (VMB_CODSTA) est„o corretos."
						STR0243 + ": " + AllTrim(oWS:oOUTPUT:oE_MACHINESTATUS[nCont1]:cMACHINESTATUS) + " - " + AllTrim(oWS:oOUTPUT:oE_MACHINESTATUS[nCont1]:cMACHINESTATUS_DESC) + CHR(13) + CHR(10) +; // "Status da M·quina no Portal"
						RetTitle("VMB_CODSTA") + ": " + cStatProp + " - " + X3CBOXDESC("VMB_CODSTA",cStatProp)
					Exit
				EndIf
			Next nCont1
			//

		EndIf
	Else
		cAuxMsg := STR0178 + CHR(13) + CHR(10) + cAuxMsg // InformaÁıes do Portal
	Endif

	AVISO(STR0111, STR0028 + CHR(13) + CHR(10) + ; // AtenÁ„o / Equipamento n„o esta em garantia
		STR0176 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // SolicitaÁ„o de garantia n„o ser· transmitida.
		STR0177 + CHR(13) + CHR(10) + ; // InformaÁıes da SolicitaÁ„o de Garantia
		 AllTrim(RetTitle("VMB_CHASSI")) + ": " + cChassi + CHR(13) + CHR(10) + ;
		 AllTrim(RetTitle("VMB_DTFALH")) + ": " + DtoC(dDtFalha) + CHR(13) + CHR(10) + ;
		 AllTrim(RetTitle("VMB_QTDUTI")) + ": " + AllTrim(Str(nQtdUti,10)) + CHR(13) + CHR(10) + ;
		 AllTrim(RetTitle("VMB_UNIMED")) + ": " + cUN + CHR(13) + CHR(10) + ;
		 AllTrim(RetTitle("VMB_TIPGAR")) + ": " + cTipoGar + CHR(13) + CHR(10) + ;
		 AllTrim(RetTitle("VMB_CODSTA")) + ": " + cStatProp + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
		 cAuxMsg ;
		 , { STR0146 } , 3)
EndIf

FWFreeObj(@oWS)

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15IC ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Cria uma planilha para conferencia da garantia especial    ∫±±
±±∫          ≥ Funcao utilizada no desenvolvimento da garantia especial   ∫±±
±±∫          ≥ Funcao INTERNA                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15IC()

Local nCont
Local nCont2
Local oExcel := FWMSEXCEL():New()
Local aAuxLinha

If lTemPeca
	oExcel:AddworkSheet(STR0045) // PeÁas
	oExcel:AddTable(STR0045,STR0045) // PeÁas / PeÁas

	oExcel:AddColumn(STR0045,STR0045,"TT",1,1)
	oExcel:AddColumn(STR0045,STR0045,STR0179,1,1) // PeÁas / PeÁas / Codigo
	oExcel:AddColumn(STR0045,STR0045,STR0180,3,2) // PeÁas / PeÁas / Qtde
	oExcel:AddColumn(STR0045,STR0045,STR0181,3,2) // PeÁas / PeÁas / Vlr. Unitario
	oExcel:AddColumn(STR0045,STR0045,STR0182,3,2) // PeÁas / PeÁas / Vlr.Total

	For nCont := 1 to Len(aVMCPeca)

		aAuxLinha := Array(5)
		aAuxLinha[1] := aVMCPeca[nCont, _VMC_PECA_TIPTEM_ ]
		aAuxLinha[2] := aVMCPeca[nCont, _VMC_PECA_CODITE_ ]
		aAuxLinha[3] := aVMCPeca[nCont, _VMC_PECA_QTDPECRETORNADA_ ]
		aAuxLinha[4] := aVMCPeca[nCont, _VMC_PECA_VLRUNITRETORNADO_ ]
		aAuxLinha[5] := aVMCPeca[nCont, _VMC_PECA_VLRTOTALRETORNADO_]

		oExcel:AddRow(STR0045,STR0045,aAuxLinha) // PeÁas / PeÁas

	Next nCont
	oExcel:AddRow(STR0045,STR0045,{"","","","",""}) // PeÁas / PeÁas
	oExcel:AddRow(STR0045,STR0045,{"","","","",""}) // PeÁas / PeÁas

	If Len(oGetPeca:aCols) > 0

		For nCont2 := 1 to 2

			If nCont2 == 1
				cTipTem := "CINT"
			ElseIf nCont2 == 2
				cTipTem := "CEXT"
			EndIf

			For nCont := 1 to Len(oGetPeca:aCols)

				If oGetPeca:aCols[nCont,FG_POSVAR("PEC_TIPTEM","oGetPeca:aHeader")] <> cTipTem
					Loop
				EndIf

				aAuxLinha := Array(5)
				aAuxLinha[1] := oGetPeca:aCols[nCont,FG_POSVAR("PEC_TIPTEM","oGetPeca:aHeader")]
				aAuxLinha[2] := oGetPeca:aCols[nCont,FG_POSVAR("PEC_CODITE","oGetPeca:aHeader")]
				aAuxLinha[3] := oGetPeca:aCols[nCont,FG_POSVAR("PEC_QTDREQ","oGetPeca:aHeader")]
				aAuxLinha[4] := oGetPeca:aCols[nCont,FG_POSVAR("PEC_VALPEC","oGetPeca:aHeader")]
				aAuxLinha[5] := oGetPeca:aCols[nCont,FG_POSVAR("PEC_VALTOT","oGetPeca:aHeader")]
				oExcel:AddRow(STR0045,STR0045,aAuxLinha)

			Next nCont

			oExcel:AddRow(STR0045,STR0045,{"","","","",""}) // PeÁas / PeÁas
			oExcel:AddRow(STR0045,STR0045,{"","","","",""}) // PeÁas / PeÁas

		Next nCont2

	EndIf

EndIf


If lTemSrvc
	oExcel:AddworkSheet(STR0158) // ServiÁos
	oExcel:AddTable(STR0158,STR0158) // ServiÁos / ServiÁos
	oExcel:AddColumn(STR0158,STR0158,"TT",1,1) // ServiÁos / ServiÁos
	oExcel:AddColumn(STR0158,STR0158,STR0179,1,1) // ServiÁos / ServiÁos / Codigo
	oExcel:AddColumn(STR0158,STR0158,STR0183,1,2) // ServiÁos / ServiÁos / Horas
	oExcel:AddColumn(STR0158,STR0158,STR0184,3,2) // ServiÁos / ServiÁos / Vlr. Hora
	oExcel:AddColumn(STR0158,STR0158,STR0185,3,2) // ServiÁos / ServiÁos / Vlr. Total

	For nCont := 1 to Len(aVMCSrvc)

		aAuxLinha := Array(5)
		aAuxLinha[1] := aVMCSrvc[nCont,01]
		aAuxLinha[2] := aVMCSrvc[nCont,04]
	//	aAuxLinha[3] := aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ]
		aAuxLinha[3] := Transform( aVMCSrvc[nCont, _VMC_SRVC_HORASRETORNADA_ ] , PesqPict("VMC","VMC_QSRRET") )
		aAuxLinha[4] := aVMCSrvc[nCont,12]
		aAuxLinha[5] := aVMCSrvc[nCont,14]

		oExcel:AddRow(STR0158,STR0158,aAuxLinha) // ServiÁos / ServiÁos

	Next nCont
	oExcel:AddRow(STR0158,STR0158,{"","","","",""}) // ServiÁos / ServiÁos
	oExcel:AddRow(STR0158,STR0158,{"","","","",""}) // ServiÁos / ServiÁos


	If Len(oGetSrvc:aCols) > 0

		For nCont2 := 1 to 2

			If nCont2 == 1
				cTipTem := "CS  "
			ElseIf nCont2 == 2
				cTipTem := "IS  "
			EndIf

			For nCont := 1 to Len(oGetSrvc:aCols)

				If oGetSrvc:aCols[nCont,FG_POSVAR("SER_TIPTEM","oGetSrvc:aHeader")] <> cTipTem
					Loop
				EndIf

				aAuxLinha := Array(5)
				aAuxLinha[1] := oGetSrvc:aCols[nCont,FG_POSVAR("SER_TIPTEM","oGetSrvc:aHeader")]
				aAuxLinha[2] := oGetSrvc:aCols[nCont,FG_POSVAR("SER_CODSER","oGetSrvc:aHeader")]
				aAuxLinha[3] := Transform( oGetSrvc:aCols[nCont,FG_POSVAR("SER_TEMPAD","oGetSrvc:aHeader")], PesqPict("VMC","VMC_QSRRET") )
				aAuxLinha[4] := oGetSrvc:aCols[nCont,FG_POSVAR("SER_VALHOR","oGetSrvc:aHeader")]
				aAuxLinha[5] := oGetSrvc:aCols[nCont,FG_POSVAR("SER_VALTOT","oGetSrvc:aHeader")]
				oExcel:AddRow(STR0158,STR0158,aAuxLinha) // ServiÁos / ServiÁos

			Next nCont

			oExcel:AddRow(STR0158,STR0158,{"","","","",""}) // ServiÁos / ServiÁos
			oExcel:AddRow(STR0158,STR0158,{"","","","",""}) // ServiÁos / ServiÁos

		Next nCont2

	EndIf
EndIf

oExcel:Activate()

oExcel:GetXMLFile("C:\Totvs\"+ AllTrim(VMB->VMB_CODGAR)+"_"+StrTran(Time(),":","")+".xls")
oExcel:DeActivate()

MsgInfo(STR0186) // Arquivo gerado

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥OFNJD15SI≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 15/05/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levanta/Atribui sequencia dos itens das garantias          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15SI()
Local i    := 0
Local nAux := 0
For i := 1 to Len(oAuxGetDados:aCols)
	If Val(oAuxGetDados:aCols[i,FG_POSVAR("VMC_SEQGAR","aHeader")]) > nAux
		nAux := Val(oAuxGetDados:aCols[i,FG_POSVAR("VMC_SEQGAR","aHeader")])
	EndIf
Next
For i := 1 to Len(oAuxGetDados:aCols)
	If Empty(oAuxGetDados:aCols[i,FG_POSVAR("VMC_SEQGAR","aHeader")])
		nAux++
		oAuxGetDados:aCols[i,FG_POSVAR("VMC_SEQGAR","aHeader")] := strzero(nAux,3)
	EndIf
Next
Return()


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15VGP ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao da GetDados de pecas                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15VGP(cReadVar,nPosGet)

Local lRetorno := .t.
//Local aCliente
//Local nContador

Default cReadVar := ReadVar()
Default nPosGet  := oGetPeca:nAt

If cReadVar == "M->PEC_TIPTEM"
	VOI->(dbSetOrder(1))
	If !VOI->(MsSeek(xFilial("VOI") + M->PEC_TIPTEM ))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VOI_TIPTEM")) + ": " + M->PEC_TIPTEM,4,1)
		Return .f.
	EndIf
	If VOI->VOI_SITTPO $ "2/4" .AND. OFNJD15006_NaoUsarTTGar(M->PEC_GRUITE, M->PEC_CODITE)
		FMX_HELP("OFNJD15TT",STR0237, STR0235) // Tipo de tempo inv·lido." // "Necess·rio informar tipo de tempo diferente de garantia."
		Return .f.
	EndIf
	oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_TIPTEM","aHPeca")] := M->PEC_TIPTEM
	OFNJD15CLI(M->PEC_TIPTEM, "P", VMB->VMB_NUMOSV , .t. , "PEC" , nPosGet )

	If ! Empty(M->PEC_FATPAR) .AND. ! Empty(M->PEC_OPER) .and. Empty(M->PEC_CODTES)
		OFNJD15VGP("M->PEC_OPER",nPosGet)
	EndIf

EndIf

If cReadVar == "M->PEC_GRUITE"
	M->VO3_GRUITE := M->PEC_GRUITE
EndIf

If cReadVar == "M->PEC_FATPAR"
	OFNJD15ACL("PEC_FATPAR",M->PEC_TIPTEM,nPosGet)
EndIf

If cReadVar == "M->PEC_LOJA"
	OFNJD15ACL("PEC_LOJA",M->PEC_TIPTEM,nPosGet)
EndIf

If cReadVar == "M->PEC_QTDREQ"
	M->PEC_VALTOT := Round(M->PEC_QTDREQ * M->PEC_VALPEC,2)
	oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_VALTOT","aHPeca")] := M->PEC_VALTOT
EndIf

If cReadVar == "M->PEC_VALPEC"
	M->PEC_VALTOT := Round(M->PEC_QTDREQ * M->PEC_VALPEC,2)
	oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_VALTOT","aHPeca")] := M->PEC_VALTOT
EndIf

If cReadVar == "M->PEC_PROREQ"
	If !ExistCpo("VAI", M->PEC_PROREQ,1)
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VAI_CODTEC")) + ": " + M->PEC_PROREQ,4,1)
		Return .f.
	EndIf
	OFNJD15ATP("PEC_PROREQ", M->PEC_TIPTEM, nPosGet)
EndIf

If cReadVar == "M->PEC_DEPINT"
	OFNJD15ATP("PEC_DEPINT", M->PEC_TIPTEM, nPosGet)
EndIf

If cReadVar == "M->PEC_OPER"

	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1") + M->PEC_GRUITE + M->PEC_CODITE ))
	SB1->(dbSetOrder(1))

	cAuxTES := MaTesInt(2,M->PEC_OPER,M->PEC_FATPAR,M->PEC_LOJA,"C",SB1->B1_COD)
	SF4->(dbSetOrder(1))
	If !Empty(cAuxTES)
		If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
			cAuxTES := ""
		EndIf
	EndIf
	If Empty(cAuxTES)
		cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
		If !Empty(cAuxTES)
			If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
				cAuxTES := ""
			EndIf
		EndIf
	Endif
	If !Empty(cAuxTES)
		oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_CODTES","aHPeca")]  := M->PEC_CODTES := cAuxTES
		oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_ESTOQUE","aHPeca")] := M->PEC_ESTOQUE := SF4->F4_ESTOQUE
		OFNJD15022_checkConfigEstoque(SF4->F4_ESTOQUE, oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_STATUS","aHPeca")])
	EndIf
EndIF

If cReadVar == "M->PEC_CODTES"
	If M->PEC_CODTES <= "500"
		Return .f.
	EndIf
	SF4->(dbSetOrder(1))
	If !SF4->(MsSeek(xFilial("SF4") + M->PEC_CODTES))
		Return .f.
	EndIf
	oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_ESTOQUE","aHPeca")] := M->PEC_ESTOQUE := SF4->F4_ESTOQUE
	OFNJD15022_checkConfigEstoque(SF4->F4_ESTOQUE, oGetPeca:aCols[nPosGet,FG_POSVAR("PEC_STATUS","aHPeca")])
EndIf

Return lRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15ACL  ∫ Autor ≥ Rubens            ∫ Data ≥ 11/08/14  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Atualiza Cliente para Faturar Para                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15ACL(cCampo,cTipTem,nPosGet,lLimpa)

Local cPrefixo   := Left(cCampo,3)
Local cAuxFatPar
Local cAuxLoja

Default lLimpa := .f.

If lLimpa
	&("M->" + cPrefixo + "_FATPAR") := Space(TamSX3("VO3_FATPAR")[1])
	OFNJD15ATP(cPrefixo + "_FATPAR", cTipTem, 0)

	&("M->" + cPrefixo + "_LOJA")   := Space(TamSX3("VO3_LOJA")[1])
	OFNJD15ATP(cPrefixo + "_LOJA"  , cTipTem, 0)

	&("M->" + cPrefixo + "_NOMCLI") := Space(TamSX3("VO3_NOMCLI")[1])
	OFNJD15ATP(cPrefixo + "_NOMCLI", cTipTem, 0)
Else

	cAuxFatPar := &("M->" + cPrefixo + "_FATPAR")
	cAuxLoja   := &("M->" + cPrefixo + "_LOJA")

	cAuxLoja := IIF( !Empty(cAuxLoja) , cAuxLoja , "" )

	SA1->(dbSetOrder(1))
	If !SA1->(dbSeek(xFilial("SA1") + cAuxFatPar + cAuxLoja ))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_FATPAR")) + ": " + cAuxFatPar + " - " + cAuxLoja ,4,1)
		Return .f.
	EndIf

	// Se alterar o faturar para e a loja ja existir, deve limpar o loja e o nome...
	If "FATPAR" $ cCampo  .and. !Empty(cAuxLoja)
		&("M->" + cPrefixo + "_LOJA")   := Space(TamSX3("VO3_LOJA")[1])
		OFNJD15ATP(cPrefixo + "_LOJA"  , cTipTem, 0)

		&("M->" + cPrefixo + "_NOMCLI") := Space(TamSX3("VO3_NOMCLI")[1])
		OFNJD15ATP(cPrefixo + "_NOMCLI", cTipTem, 0)

		lLimpa := .t.
	EndIf
	//

	If !Empty(cAuxLoja) .and. !lLimpa
		&("M->" + cPrefixo + "_NOMCLI") := SA1->A1_NOME
		OFNJD15ATP(cPrefixo + "_NOMCLI", cTipTem, 0)
	EndIf

	OFNJD15ATP( cCampo , cTipTem , nPosGet)
EndIf

Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15REST ∫ Autor ≥ Rubens            ∫ Data ≥ 11/08/14  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Replica informacao para todos os registros de mesmo tipo   ∫±±
±±∫          ≥ de tempo                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15ATP(cCampo, cTipTem, nPosGet, uNovoValor)

Local nColGetTT
Local nColGet
Local nContador
Local cNomHeader := ""
Local oAuxGD

Default uNovoValor := &("M->" + cCampo)

Do Case
Case Left(cCampo,3) == "PEC"
	cNomHeader := "aHPeca"
	oAuxGD := oGetPeca
Case Left(cCampo,3) == "SER"
	cNomHeader := "aHSrvc"
	oAuxGD := oGetSrvc
Case Left(cCampo,3) == "OUT"
	cNomHeader := "aHOutr"
	oAuxGD := oGetOutr
EndCase

nColGetTT  := FG_POSVAR(Left(cCampo,3) + "_TIPTEM",cNomHeader)
nColGet    := FG_POSVAR(cCampo,cNomHeader)

For nContador := 1 to Len(oAuxGD:aCols)
	If oAuxGD:aCols[nContador,nColGetTT] == cTipTem .and. (nPosGet <> nContador .or. nPosGet == 0)
		oAuxGD:aCols[nContador,nColGet] := uNovoValor
	EndIf
Next nContador

oAuxGD:oBrowse:Refresh()
//oAuxGD:Refresh()

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15VGS ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao da GetDados de Servicos                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15VGS(cReadVar,nPosGet)

Local lRetorno := .t.

Default cReadVar := ReadVar()
Default nPosGet := oGetSrvc:nAt

If cReadVar $ "M->SER_GRUSER/M->SER_CODSER"
	If M->SER_STATUS == STR0216 // "SERVI«O N√O APROVADO"
		HELP(' ',1,"NJD15ALTBLQ" ,,STR0218,2,0,,,,,, ) // "N„o È permitido alterar dados do serviÁo para este registro."
		Return .f.
	EndIf
	If M->SER_STATUS == STR0210 + " (100%)" // "MATRIZ REEMBOLSO"
		HELP(' ',1,"NJD15ALTBLQ" ,,STR0218,2,0,,,,,, ) // "N„o È permitido alterar dados do serviÁo para este registro."
		Return .f.
	EndIf
EndIf

If cReadVar == "M->SER_TIPTEM"
	VOI->(dbSetOrder(1))
	If !VOI->(MsSeek(xFilial("VOI") + M->SER_TIPTEM ))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VOI_TIPTEM")) + ": " + M->SER_TIPTEM,4,1)
		Return .f.
	EndIf
	If VOI->VOI_SITTPO $ "2/4" .AND. OFNJD15012_NaoUsarTTGar(M->SER_RECNO)
		HELP(' ',1,"NJD15TTSRVC" ,,STR0222,2,0,,,,,, {STR0223}) // "Tipo de tempo inv·lido." // "Informar um tipo de tempo de cliente ou interno."
		Return .f.
	EndIf
	oGetSrvc:aCols[nPosGet,FG_POSVAR("SER_TIPTEM","aHSrvc")] := M->SER_TIPTEM
	OFNJD15CLI(M->SER_TIPTEM, "S", VMB->VMB_NUMOSV , .t. , "SER" , nPosGet )
EndIf

If cReadVar == "M->SER_FATPAR"
	OFNJD15ACL("SER_FATPAR",M->SER_TIPTEM,nPosGet)
EndIf

If cReadVar == "M->SER_LOJA"
	OFNJD15ACL("SER_LOJA",M->SER_TIPTEM,nPosGet)
EndIf

If cReadVar == "M->SER_TIPSER"
	VOK->(dbSetOrder(1))
	If !VOK->(dbSeek(xFilial("VOK") + M->SER_TIPSER))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VO4_TIPSER")) + ": " + M->SER_TIPSER,4,1)
		Return .f.
	EndIf

	If VOK->VOK_INCMOB $ "5"
		MsgInfo(STR0187) // Utilizar um tipo de serviÁo diferente de Quilometragem
		Return .f.
	EndIf
EndIf

If cReadVar == "M->SER_LOJA"
	If !ExistCpo("SA1", M->SER_FATPAR + M->SER_LOJA)
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_FATPAR")) + ": " + M->SER_FATPAR + " - " + M->SER_LOJA,4,1)
		Return .f.
	EndIf
	OFNJD15ATP("SER_LOJA", M->SER_TIPTEM, nPosGet)
EndIf

If cReadVar == "M->SER_GRUSER"
	M->VO4_GRUSER := M->SER_GRUSER
EndIf

If cReadVar == "M->SER_TEMPAD"
	If M->SER_STATUS == FWNoAccent(STR0216)
		Return .f.
	EndIf
EndIf

Return lRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15VGO ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao da GetDados de Outros Creditos                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15VGO(cReadVar,nPosGet)

Local lRetorno := .t.

Default cReadVar := ReadVar()
Default nPosGet := oGetOutr:nAt

If cReadVar == "M->OUT_TIPTEM"
	VOI->(dbSetOrder(1))
	If !VOI->(MsSeek(xFilial("VOI") + M->OUT_TIPTEM ))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VOI_TIPTEM")) + ": " + M->OUT_TIPTEM,4,1)
		Return .f.
	EndIf

	If oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_STATUS","aHOutr")] == STR0217 // "SERVI«O N√O TRANSMITIDO"
		If VOI->VOI_SITTPO <> "2"
			HELP(" ",1,"NJD15OUTRNTRA",,STR0219,4,1, NIL, NIL, NIL, NIL, NIL, {STR0220} ) //  "Outros crÈditos n„o transmitido. // "Informar um tipo de tempo de garantia."
			Return .f.
		EndIf
	EndIf

	oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] := M->OUT_TIPTEM
	OFNJD15CLI(M->OUT_TIPTEM, "S", VMB->VMB_NUMOSV , .t. , "OUT" , nPosGet )
EndIf

If cReadVar == "M->OUT_FATPAR"
	OFNJD15ACL("OUT_FATPAR",M->OUT_TIPTEM,nPosGet)
EndIf

If cReadVar == "M->OUT_LOJA"
	OFNJD15ACL("OUT_LOJA",M->OUT_TIPTEM,nPosGet)
EndIf

If cReadVar == "M->OUT_TIPSER"
	VOK->(dbSetOrder(1))
	If !VOK->(dbSeek(xFilial("VOK") + M->OUT_TIPSER))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VO4_TIPSER")) + ": " + M->OUT_TIPSER,4,1)
		Return .f.
	EndIf

	If !VOK->VOK_INCMOB $ "2/5"
		MsgInfo(STR0188) // Utilizar um tipo de serviÁo de Terceiros ou Quilometragem
		Return .f.
	EndIf
EndIf

If cReadVar == "M->OUT_LOJA"
	If !ExistCpo("SA1", M->OUT_FATPAR + M->OUT_LOJA)
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_FATPAR")) + ": " + M->OUT_FATPAR + " - " + M->OUT_LOJA,4,1)
		Return .f.
	EndIf
	OFNJD15ATP("OUT_LOJA", M->OUT_TIPTEM, nPosGet)
EndIf

If cReadVar == "M->OUT_GRUSER"
	M->VO4_GRUSER := M->OUT_GRUSER
EndIf

Return lRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15CLI ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Pesquisa o cliente de acordo com o tipo de tempo           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15CLI(cParTipTem,cTipReq,cNumOsv,lAtuGetD,cAuxPref,nPosGet)

	Local cCodMarca

	Default lAtuGetD := .f.

	VO1->(dbSetOrder(1))
	If VO1->(MsSeek(xFilial("VO1") + cNumOsv))
		cCodMarca := OFNJD15011_RetornaMarca(VO1->VO1_CODMAR)
	Else
		cCodMarca := FMX_RETMAR("JD ")
	EndIf

	aRetCli := {"","",""}
	FG_TIPTPFAT(cParTipTem,"aRetCli[1]","aRetCli[2]","aRetCli[3]",cCodMarca,cTipReq,cNumOsv,.F.   ,.f.      ,,.f.)

	// Atualiza aCols Automaticamente
	If lAtuGetD
		If Empty(aRetCli[2])
			OFNJD15ACL( cAuxPref + "_FATPAR" , cParTipTem, 0 , .t. )
		Else
			cAuxPref := AllTrim(cAuxPref)
			&("M->" + cAuxPref + "_FATPAR") := aRetCli[1]
			OFNJD15ACL( cAuxPref + "_FATPAR" , cParTipTem , 0 )
			&("M->" + cAuxPref + "_LOJA"  ) := aRetCli[2]
			OFNJD15ACL( cAuxPref + "_LOJA" , cParTipTem , 0 )
		EndIf
	EndIf
	//

Return aRetCli


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15PW ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Pesquisa o cliente de acordo com o tipo de tempo           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15PW(cAlias,nReg,nOpc)

Local aParamBox := {}
Local aRetParam := {}

If !VAI->(FieldPos("VAI_FABUSR")) <> 0
	MsgInfo(STR0112,STR0111) // 'OpÁ„o n„o disponÌvel.'
	Return .t.
EndIf

// Procura Equipe tÈcnica...
VAI->(DbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
VAI->(DbSetOrder(1))
If !VAI->(Found())
	MsgStop(STR0113,STR0111) // 'Usu·rio sem cadastro na equipe tÈcnica.'
	Return .t.
EndIf
//

AADD(aParamBox,{1,RetTitle("VAI_FABUSR"),VAI->VAI_FABUSR,PesqPict("VAI","VAI_FABUSR"),"","",IIf( !Empty(VAI->VAI_FABUSR) , ".F." , ".T.") ,50,.T.})
AADD(aParamBox,{8,RetTitle("VAI_FABPWD"),Space(TamSX3("VAI_FABPWD")[1]),PesqPict("VAI","VAI_FABPWD"),"","","",50,.T.})

If !ParamBox(aParamBox,STR0114,@aRetParam,,,,,,,,.f.) // 'Alterar senha'
	Return .f.
EndIf

// Altera senha ...
RecLock("VAI",.f.)
VAI->VAI_FABUSR := aRetParam[1]
VAI->VAI_FABPWD := aRetParam[2]
VAI->(MsUnlock())
//

MsgInfo(STR0115,STR0111) // 'Senha alterada'

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15SX1 ∫ Autor ≥ Rubens             ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Parametros da rotina                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15SX1(lPergunte)

//Local aRegs := {}
Local cPerg := "OFINJD15"

Default lPergunte := .t.

Private cMotivo  := "000002"  // Filtro da consulta do motivo
Private M->VG8_CODMAR := FMX_RETMAR("JD ") // Filtro para grupo de servico

SetKey(VK_F12,Nil)

Pergunte(cPerg,lPergunte,,,,.f.)

If ! lPergunte .and. Empty(MV_PAR01)
	Pergunte(cPerg,.t.,,,,.f.)
EndIf

SetKey(VK_F12,{ || OFNJD15SX1(.t.) })

// AADD(aRegs,{STR0054,STR0054,STR0054,'MV_CH1','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR01)','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT PeÁa (Esp. Cliente)'
// AADD(aRegs,{STR0055,STR0055,STR0055,'MV_CH2','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR02)','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT Srvc (Esp. Cliente)'
// AADD(aRegs,{STR0056,STR0056,STR0056,'MV_CH3','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR03,2)','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc (Esp. Cliente)'
// AADD(aRegs,{STR0057,STR0057,STR0057,'MV_CH4','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR04,4)','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod. ServiÁo (Esp. Cliente)'
// AADD(aRegs,{STR0058,STR0058,STR0058,'MV_CH5','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR05)','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo ServiÁo (Esp. Cliente)'
// AADD(aRegs,{STR0059,STR0059,STR0059,'MV_CH6','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR06,2)','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc O. Cred.(Esp. Cli)'
// AADD(aRegs,{STR0060,STR0060,STR0060,'MV_CH7','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR07,4)','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod. Srvc O. Cred. (Esp. Cli)'
// AADD(aRegs,{STR0061,STR0061,STR0061,'MV_CH8','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR08)','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo Srvc O. Cred. (Esp. Cli)'
// AADD(aRegs,{STR0062,STR0062,STR0062,'MV_CH9','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR09)','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT PeÁa (Esp. Interno)'
// AADD(aRegs,{STR0063,STR0063,STR0063,'MV_CHA','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR10)','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT Srvc (Esp. Interno)'
// AADD(aRegs,{STR0064,STR0064,STR0064,'MV_CHB','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR11,2)','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc (Esp. Interno)'
// AADD(aRegs,{STR0065,STR0065,STR0065,'MV_CHC','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR12,4)','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod. ServiÁo (Esp. Interno)'
// AADD(aRegs,{STR0066,STR0066,STR0066,'MV_CHD','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR13)','MV_PAR13','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo ServiÁo (Esp. Interno)'
// AADD(aRegs,{STR0067,STR0067,STR0067,'MV_CHE','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR14,2)','MV_PAR14','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc O. Cred.(Esp. Int)'
// AADD(aRegs,{STR0068,STR0068,STR0068,'MV_CHF','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR15,4)','MV_PAR15','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod. Srvc O. Cred. (Esp. Int)'
// AADD(aRegs,{STR0069,STR0069,STR0069,'MV_CHG','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR16)','MV_PAR16','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo Srvc O. Cred. (Esp. Int)'
// AADD(aRegs,{STR0070,STR0070,STR0070,'MV_CHH','C',06,0,,'G','Vazio().or.ExistCPO("VS0",cMotivo+MV_PAR17)','MV_PAR17','','','','','','','','','','','','','','','','','','','','','','','','','VS0','','','','@!',{},{},{}}) // 'Motivo de Cancelamento'
// AADD(aRegs,{STR0071,STR0071,STR0071,'MV_CHI','C',02,0,,'G','Vazio().or.Existcpo("SX5","DJ"+MV_PAR18)','MV_PAR18','','','','','','','','','','','','','','','','','','','','','','','','','DJ','','','','@!',{},{},{}}) // 'OperaÁ„o (G. Especial)'
// AADD(aRegs,{STR0072,STR0072,STR0072,'MV_CHJ','C',03,0,,'G','Vazio().or.ExistCPO("SF4",MV_PAR19,1)','MV_PAR19','','','','','','','','','','','','','','','','','','','','','','','','','SF4','','','','@!',{},{},{}}) // 'TES (G. Especial)'
// AADD(aRegs,{STR0073,STR0073,STR0073,'MV_CHK','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR20,2)','MV_PAR20','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc. Desloc. (Rev./PMP)'
// AADD(aRegs,{STR0074,STR0074,STR0074,'MV_CHL','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR21,4)','MV_PAR21','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod. Srvc. Desloc. (Rev./PMP)'
// AADD(aRegs,{STR0075,STR0075,STR0075,'MV_CHM','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR22)','MV_PAR22','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo Srvc. Desloc. (Rev./PMP)'
// AADD(aRegs,{STR0076,STR0076,STR0076,'MV_CHN','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR23)','MV_PAR23','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT ServiÁo (Revis„o)'
// AADD(aRegs,{STR0077,STR0077,STR0077,'MV_CHO','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR24,2)','MV_PAR24','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc (Revis„o)'
// AADD(aRegs,{STR0078,STR0078,STR0078,'MV_CHP','C',03,0,,'G','Vazio().or.ExistCPO("VOD",MV_PAR25)','MV_PAR25','','','','','','','','','','','','','','','','','','','','','','','','','VOD','','','','@!',{},{},{}}) // 'Cod. SeÁ„o (Revis„o)'
// AADD(aRegs,{STR0079,STR0079,STR0079,'MV_CHQ','C',01,0,,'G','Vazio().or.Existcpo("SX5","VF"+MV_PAR26)','MV_PAR26','','','','','','','','','','','','','','','','','','','','','','','','','VF','','','','@!',{},{},{}}) // 'Depto. Garantia (Revis„o)'
// AADD(aRegs,{STR0080,STR0080,STR0080,'MV_CHR','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR27)','MV_PAR27','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo Srvc (Revis„o)'
// AADD(aRegs,{STR0081,STR0081,STR0081,'MV_CHS','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR28)','MV_PAR28','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT PeÁa (PMP)'
// AADD(aRegs,{STR0082,STR0082,STR0082,'MV_CHT','C',04,0,,'G','Vazio().or.ExistCPO("VOI",MV_PAR29)','MV_PAR29','','','','','','','','','','','','','','','','','','','','','','','','','VOI','','','','@!',{},{},{}}) // 'TT ServiÁo (PMP)'
// AADD(aRegs,{STR0083,STR0083,STR0083,'MV_CHU','C',02,0,,'G','Vazio().or.ExistCPO("VOS",MV_PAR30,2)','MV_PAR30','','','','','','','','','','','','','','','','','','','','','','','','','VOS','','','','@!',{},{},{}}) // 'Grupo Srvc (PMP)'
// AADD(aRegs,{STR0084,STR0084,STR0084,'MV_CHV','C',03,0,,'G','Vazio().or.ExistCPO("VOD",MV_PAR31)','MV_PAR31','','','','','','','','','','','','','','','','','','','','','','','','','VOD','','','','@!',{},{},{}}) // 'Cod. SeÁ„o (PMP)'
// AADD(aRegs,{STR0085,STR0085,STR0085,'MV_CHW','C',01,0,,'G','Vazio().or.Existcpo("SX5","VF"+MV_PAR32)','MV_PAR32','','','','','','','','','','','','','','','','','','','','','','','','','VF','','','','@!',{},{},{}}) // 'Depto. Garantia (PMP)'
// AADD(aRegs,{STR0086,STR0086,STR0086,'MV_CHY','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR33)','MV_PAR33','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // 'Tipo Srvc (PMP)'
// AADD(aRegs,{STR0087,STR0087,STR0087,'MV_CHZ','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR34,4)','MV_PAR34','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod. Srvc M. Reembolso(PMP)'
// AADD(aRegs,{STR0107,STR0107,STR0107,'MV_CI0','C',15,0,,'G','Vazio().or.ExistCPO("VO6",MV_PAR35,4)','MV_PAR35','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Cod Srvc (PMP)'
// AADD(aRegs,{STR0108,STR0108,STR0108,'MV_CI1','C',30,0,,'G','','MV_PAR36','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Tipo de Veiculo de TURF'
// AADD(aRegs,{STR0109,STR0109,STR0109,'MV_CI2','C',30,0,,'G','','MV_PAR37','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Tipo de Veiculo de GOLF'
// AADD(aRegs,{STR0110,STR0110,STR0110,'MV_CI3','C',30,0, ,'G','','MV_PAR38',''   ,'','','','',''   ,'','','','','','','','','','','','','','','','','','','','','','','@!',{},{},{}}) // 'Convers„o de Unid. Med.'
// AADD(aRegs,{STR0130,STR0130,STR0130,'MV_CI4','N',01,0,2,'C','','MV_PAR39','Sim','','','','','N„o','','','','','','','','','','','','','','','','','','','','','','',''  ,;
// 	{ STR0189 + " ",STR0190},; // Grava numero de Chassi e Ordem de / ServiÁo na observaÁ„o da nota fiscal.
// 	{ STR0189 + " ",STR0190},; // Grava numero de Chassi e Ordem de / ServiÁo na observaÁ„o da nota fiscal.
// 	{ STR0189 + " ",STR0190} }) // Grava numero de Chassi e Ordem de / ServiÁo na observaÁ„o da nota fiscal.
// AADD(aRegs,{STR0131,STR0131,STR0131,'MV_CI5','C',3,0,0,'G','Vazio().Or.ExistCpo("SM4",MV_PAR40)','MV_PAR40','','','','','','','','','','','','','','','','','','','','','','','','','SM4','','','','',;
// 	{ STR0191 },; // Grava mensagem padr„o da nota fiscal.
// 	{ STR0191 },; // Grava mensagem padr„o da nota fiscal.
// 	{ STR0191 } }) // Grava mensagem padr„o da nota fiscal.
// AADD(aRegs,{STR0139,STR0139,STR0139,'MV_CI6','C',3,0,,'G','OFNJD15004_ValidPerg("MV_PAR41")','MV_PAR41','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}} ) // "Tipo de ServiÁo Gratuito"

Return

Function OFNJD15004_ValidPerg(cNomPar)
	Do Case
	Case cNomPar == "MV_PAR41"
		If !Empty(MV_PAR41)
			VOK->(dbSetOrder(1))
			If !VOK->(dbSeek(xFilial("VOK") + MV_PAR41))
				HELP(" ",1,"REGNOIS",,MV_PAR41,4,1)
				Return .f.
			Else
				If VOK->VOK_INCMOB <> "0"
					ShowHelpDlg ( "OFNJD15MOG", { STR0192 }) // Informe um registro configurado como M„o de Obra Gratuita.
					Return .f.
				eNDiF
			EndIf
		EndIf
	EndCase
Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15RM ∫ Autor ≥ Andre Luis / Rubens ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera nota fiscal para remessa de peca para analise         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15RM(cAlias,nReg,nOpc)

Local aIteRem := {}
Local aIteRes := {}
Local cNumIte := "00"
Local aPvlNfs := {}

Local ii := 0

Local lESTNEG  := (GetMV("MV_ESTNEG") == "S")

Local cNota := ""
Local cSerie := ""

Local aParamBox := {}
Local aRetParam := {}

Local aIndPre
Local lVOOINDPRE := (VOO->(FieldPos("VOO_INDPRE")) <> 0)

Local cSQLRem := ""
Local cAliasVMB := "TVMB"

Default nVS1_PESOL := 0
Default nVS1_PESOB := 0

If lVOOINDPRE
	aIndPre  := X3CBOXAVET("VOO_INDPRE","0")
EndIf

If VMB->VMB_REMPEC <> "1"
	MsgInfo(STR0088) // "N„o existe peÁa para envar para an·lise"
	Return
EndIf

aRetParam := Array(IIf( lVOOINDPRE , 18 , 16))
aParamBox := {}

aRetParam[1] := Space(TamSX3("C5_CLIENTE")[1])
aRetParam[2] := Space(TamSX3("C5_LOJACLI")[1])
aRetParam[3] := Space(TamSX3("C6_TES")[1])
aRetParam[4] := Space(TamSX3("C6_OPER")[1])

aRetParam[5]  := Space(TamSX3("C5_PESOL"  )[1])
aRetParam[6]  := Space(TamSX3("C5_PBRUTO" )[1])
aRetParam[7]  := Space(TamSX3("C5_MENNOTA")[1])
aRetParam[8]  := Space(TamSX3("C5_MENPAD" )[1])
aRetParam[9]  := Space(TamSX3("C5_VOLUME1")[1])
aRetParam[10] := Space(TamSX3("C5_VOLUME2")[1])
aRetParam[11] := Space(TamSX3("C5_VOLUME3")[1])
aRetParam[12] := Space(TamSX3("C5_VOLUME4")[1])
aRetParam[13] := Space(TamSX3("C5_ESPECI1")[1])
aRetParam[14] := Space(TamSX3("C5_ESPECI2")[1])
aRetParam[15] := Space(TamSX3("C5_ESPECI3")[1])
aRetParam[16] := Space(TamSX3("C5_ESPECI4")[1])

If lVOOINDPRE
	aRetParam[17] := Space(TamSX3("VOO_INDPRE")[1])
	aRetParam[18] := Space(TamSX3("VOO_TRANSP")[1])
EndIf

DbSelectArea("VMC")
dbSetOrder(1)
dbSeek( xFilial("VMC") + VMB->VMB_CODGAR )

aIteRem := {}

cSQLRem := " SELECT VMC_CODGAR,VMC_GRUITE,VMC_CODITE,VMC_QPCRET,B1_COD,B1_PESO,B1_PESBRU,B1_PRV1,VMC_UM, "
cSQLRem += " ROUND(B1_PRV1 * 0.1,2) nPrecoUn "
cSQLRem += " FROM " + RetSQLName("VMB") + " VMB "
cSQLRem += " JOIN " + RetSQLName("VMC") + " VMC ON(VMC_FILIAL = VMB_FILIAL AND VMC_CODGAR = VMB_CODGAR AND VMC.D_E_L_E_T_ = ' ')
cSQLRem += " JOIN " + RetSQLName("SB1") + " B1 ON(B1_FILIAL = '" + xFilial("SB1") + "' AND VMC_GRUITE = B1_GRUPO AND VMC_CODITE = B1_CODITE AND B1.D_E_L_E_T_ = ' ')
cSQLRem += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "' "
cSQLRem += " AND VMC_EXCODE IN ('1','2','8') AND VMB_REMPEC = '1' "
cSQLRem += " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
cSQLRem += " AND VMB.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQLRem ), cAliasVMB, .F., .T. )
While !(cAliasVMB)->(Eof())
	//
	nVS1_PESOL += (cAliasVMB)->B1_PESO
	nVS1_PESOB += (cAliasVMB)->B1_PESBRU
	//
	aAdd(aIteRem,{(cAliasVMB)->B1_COD,;
		(cAliasVMB)->VMC_QPCRET,;
		(cAliasVMB)->VMC_UM,;
		(cAliasVMB)->nPrecoUn;
		})
	//
	(cAliasVMB)->(dbSkip())
EndDo
(cAliasVMB)->(dbCloseArea())

DbSelectArea("VMB")

iif(nVS1_PESOL>0,(aRetParam[5] := nVS1_PESOL),(aRetParam[5] := 0))
iif(nVS1_PESOB>0,(aRetParam[6] := nVS1_PESOB),(aRetParam[6] := 0))

aAdd(aParamBox,{1,RetTitle("C5_CLIENTE"),aRetParam[1] ,"@!","","SA1","",0,.T.}) // Cliente
aAdd(aParamBox,{1,RetTitle("C5_LOJA")   ,aRetParam[2] ,"@!","",""   ,"",0,.T.}) // Loja
aAdd(aParamBox,{1,RetTitle("C6_TES")    ,aRetParam[3] ,"@!","","SF4","",0,.T.}) // TES
aAdd(aParamBox,{1,RetTitle("C6_OPER")   ,aRetParam[4] ,"@!","","DJ ","",0,.F.}) // Operacao
aAdd(aParamBox,{1,RetTitle("C5_PESOL"  ),aRetParam[5] ,"@E 999,999.9999","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_PBRUTO" ),aRetParam[6] ,"@E 999,999.9999","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_MENNOTA"),aRetParam[7] ,"@!","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_MENPAD" ),aRetParam[8] ,"@!","","SM4","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_VOLUME1"),aRetParam[9] ,"99999","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_VOLUME2"),aRetParam[10],"99999","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_VOLUME3"),aRetParam[11],"99999","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_VOLUME4"),aRetParam[12],"99999","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_ESPECI1"),aRetParam[13],"@X","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_ESPECI2"),aRetParam[14],"@X","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_ESPECI3"),aRetParam[15],"@X","","","",0,.F.})
aAdd(aParamBox,{1,RetTitle("C5_ESPECI4"),aRetParam[16],"@X","","","",0,.F.})
If lVOOINDPRE
	aAdd(aParamBox,{2,RetTitle("VOO_INDPRE"),,aIndPre,80,"",.f.})
	aAdd(aParamBox,{1,RetTitle("VOO_TRANSP"),aRetParam[18],"@!","","SA4 ","",0,.F.}) // Transportadora
EndIf

If !ParamBox(aParamBox,STR0089,@aRetParam,,,,,,,,.f.) // "Emiss„o NF de Remessa"
	Return .f.
EndIf
//
aCabPV 		:= {}
aIte		:= {}
aIteTempPV	:= {}
aPvlNfs 	:= {}
//
For ii := 1 to len(aIteRem)
	//
	cNumIte := SOMA1(cNumIte)
	//
	aIteTempPV	:= {}
	//
	aAdd(aIteTempPV,{"C6_ITEM"   ,cNumIte												  ,nil})
	aAdd(aIteTempPV,{"C6_PRODUTO",aIteRem[ii][1]										  ,nil})
	aAdd(aIteTempPV,{"C6_QTDVEN" ,aIteRem[ii][2]										  ,nil})
	aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase												  ,nil})
	aAdd(aIteTempPV,{"C6_UM"     ,aIteRem[ii][3]										  ,nil})
	If !Empty(aRetParam[4])
		aAdd(aIteTempPV,{"C6_OPER"	 ,aRetParam[4]										  ,nil})
	EndIf
	aAdd(aIteTempPV,{"C6_LOCAL"  ,FM_PRODSBZ(aIteRem[ii][1],"SB1->B1_LOCPAD")			  ,nil})
	aAdd(aIteTempPV,{"C6_PRUNIT" ,aIteRem[ii][4]							 			  ,nil})
	aAdd(aIteTempPV,{"C6_PRCVEN" ,aIteRem[ii][4]							 			  ,nil})
	aAdd(aIteTempPV,{"C6_VALOR"  ,A410Arred(aIteRem[ii][2] * aIteRem[ii][4] , "C6_VALOR") ,nil})
	aAdd(aIteTempPV,{"C6_VALDESC",0														  ,nil})
	If !Empty(aRetParam[3])
		aAdd(aIteTempPV,{"C6_TES"    ,aRetParam[3]										  ,nil})
	EndIf
	aAdd(aIteTempPV,{"C6_COMIS1",0														  ,nil})
	aAdd(aIteTempPV,{"C6_QTDLIB" ,0														  ,Nil})
	aAdd(aIteRes,aClone(aIteTempPV))
Next

If Len(aIteTempPV) == 0
	MsgInfo(STR0090) // "N„o existe peÁa para envar para an·lise"
	Return
EndIf

If !MsgNoYes(STR0091) // "Deseja gerar nota fiscal de remessa"
	Return
EndIf

lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"),)
If !lRet .or. Empty(cSerie)
	Return .f.
EndIf

SE4->(dbGoTop())

SA1->(dbSetOrder(1))
//SA1->(dbSeek(xFilial("SA1") + "000004" + "01"))
SA1->(dbSeek(xFilial("SA1") + aRetParam[1] + aRetParam[2] ))
cNumPed  := CriaVar("C5_NUM")
aAdd(aCabPV,{"C5_NUM"    , cNumPed				 ,Nil}) // Numero do pedido
aAdd(aCabPV,{"C5_TIPO"   , "N"					 ,Nil}) // Tipo de pedido
aAdd(aCabPV,{"C5_CLIENTE", SA1->A1_COD			 ,Nil}) // Codigo do cliente
aAdd(aCabPV,{"C5_LOJACLI", SA1->A1_LOJA			 ,Nil}) // Loja do cliente
aAdd(aCabPV,{"C5_TIPOCLI", SA1->A1_TIPO			 ,Nil}) // Tipo do Cliente
aAdd(aCabPV,{"C5_EMISSAO", dDataBase			 ,Nil}) // Data de emissao
aAdd(aCabPV,{"C5_CONDPAG", SE4->E4_CODIGO		 ,Nil}) // Codigo da condicao de pagamanto
aAdd(aCabPV,{"C5_DESC1"  , 0					 ,Nil}) // Percentual do Desconto Geral
aAdd(aCabPV,{"C5_TIPLIB" , "2"					 ,Nil}) // Tipo de Liberacao ( 2 - Libera por Pedido de Venda. )
aAdd(aCabPV,{"C5_MOEDA"  , 1					 ,Nil}) // Moeda
aAdd(aCabPV,{"C5_LIBEROK", "S"					 ,Nil}) // Liberacao Total
// novos campos
aAdd(aCabPV, {"C5_PESOL"  ,aRetParam[5]			 ,Nil}) // Peso Liquido
aAdd(aCabPV, {"C5_PBRUTO" ,aRetParam[6]			 ,Nil}) // Peso Bruto
aAdd(aCabPV, {"C5_MENNOTA",AllTrim(aRetParam[7]) ,Nil}) // MENSAGEM DA NOTA
aAdd(aCabPV, {"C5_MENPAD" ,aRetParam[8]			 ,Nil}) // MENSAGEM PADR√O
aAdd(aCabPV, {"C5_VOLUME1",val(aRetParam[9])	 ,Nil}) // VOLUME 1
aAdd(aCabPV, {"C5_VOLUME2",val(aRetParam[10])	 ,Nil}) // VOLUME 2
aAdd(aCabPV, {"C5_VOLUME3",val(aRetParam[11])	 ,Nil}) // VOLUME 3
aAdd(aCabPV, {"C5_VOLUME4",val(aRetParam[12])	 ,Nil}) // VOLUME 4
aAdd(aCabPV, {"C5_ESPECI1",AllTrim(aRetParam[13]),Nil}) // ESPECIE 1
aAdd(aCabPV, {"C5_ESPECI2",AllTrim(aRetParam[14]),Nil}) // ESPECIE 2
aAdd(aCabPV, {"C5_ESPECI3",AllTrim(aRetParam[15]),Nil}) // ESPECIE 3
aAdd(aCabPV, {"C5_ESPECI4",AllTrim(aRetParam[16]),Nil}) // ESPECIE 4

If lVOOINDPRE
	If SC5->(FieldPos("C5_INDPRES")) > 0
		aAdd(aCabPV,{"C5_INDPRES"  , aRetParam[17] 	,Nil}) 	// Presenca do Comprador
	Endif

	If ( VOO->(FieldPos("VOO_TRANSP")) > 0 .and. !Empty(aRetParam[18]) )
		aAdd(aCabPV,{"C5_TRANSP"  , aRetParam[18] 	,Nil}) 	// Transportadora
	Endif
EndIf

Begin Transaction

// GeraÁ„o do pedido de Venda
lMsErroAuto := .f.
MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aIteRes,3)
//
If lMsErroAuto
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MostraErro()
	Return .F.
EndIf

lCredito := .t.
lEstoque := .t.
lLiber   := .t.
lTransf  := .f.

SC9->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed

	If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
		nQtdLib := SC6->C6_QTDVEN
		nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
	EndIf

	SC6->(dbSkip())
Enddo

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Selecionando Itens para Faturamento ... ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
	If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
		SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
		SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
		SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
		SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
		SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
		SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
		SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
		aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
						SC9->C9_ITEM,;
						SC9->C9_SEQUEN,;
						SC9->C9_QTDLIB,;
						SC9->C9_PRCVEN,;
						SC9->C9_PRODUTO,;
						SF4->F4_ISS=="S",;
						SC9->(RecNo()),;
						SC5->(RecNo()),;
						SC6->(RecNo()),;
						SE4->(RecNo()),;
						SB1->(RecNo()),;
						SB2->(RecNo()),;
						SF4->(RecNo())})
	Else
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MaFisEnd()
		MaFisRestore()
//		MsgStop(STR0061,STR0004) // "Exite um ou mais item do pedido de venda (SC5) que n„o foi liberado!"
		Return(.f.)
	EndIf
	SC9->(dbSkip())
Enddo

If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.f.) // Verifica SC5 bloqueado
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MaFisEnd()
	MaFisRestore()
	Return(.f.)
EndIf

ConfirmSx8()
nRecSA1 := SA1->(Recno())

PERGUNTE("MT460A",.f.)

cNota := MaPvlNfs(aPvlNfs,;           // 01
				  cSerie,;            // 02
				  (mv_par01 == 1),;   // 03
				  (mv_par02 == 1),;   // 04
				  (mv_par03 == 1),;   // 05
				  (mv_par04 == 1),;   // 06
				  .F.,;               // 07
				  0,;                 // 08
				  0,;                 // 09
				  .T.,;               // 10
				  .F.,;               // 11
				  ,;				  // 12
				  ,;	// 13
				  ,;				  // 14
				  ,;				  // 15
				  ,)				  // 16

If lMsErroauto
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MaFisEnd()
	MaFisRestore()
	MostraErro()
	Return(.f.)
EndIf
ConfirmSx8()

// Acerta o tamanho da variavel ...
cNota := PadR(cNota,SF2->(TamSx3("F2_DOC")[1]))
//

SA1->(DbGoTo(nRecSA1))

dbSelectArea("VMB")
RecLock("VMB",.f.)
VMB->VMB_REMPEC := "0"
VMB->(MsUnlock())

End Transaction

// Por algum motivo o cliente permanece bloqueado
SA1->(MsUnLock())
//

aInfNF := {}
AADD( aInfNF , { cSerie , ;	// Serie da NF
				 cNota  , ;	// Numero da NF
				 STR0092 } )

FMX_TELAINF( "1", aInfNF )

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15EW ∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Estorna processamento do Warranty memo                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15EW(cAlias,nReg,nOpc)

Local cSQL

If Empty(VMB->VMB_WARRME)
	MsgInfo(STR0193,STR0111) // Warrmemo ainda n„o processado / AtenÁ„o
	Return
EndIf

If VMB->VMB_STATSG <> "4"
	MsgInfo(STR0194,STR0111) // N„o È possÌvel estornar processamento do warrmemo / AtenÁ„o
	Return
EndIf

cSQL := "SELECT COUNT(*) "
cSQL +=  " FROM " + RetSQLName("VMC")
cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
cSQL +=   " AND VMC_ORIGEM = ' '"
cSQL +=   " AND D_E_L_E_T_ = ' '"
If FM_SQL(cSQL) <> 0
	MsgStop(STR0195,STR0111) // N„o È possÌvel estornar processamento pois existe um ou mais registros gravados sem origem (VMC_ORIGEM) / AtenÁ„o
	Return
EndIf

If !MsgNoYes(STR0196) // Confirma o estorno do proc. do warrmemo?
	Return
EndIf

Begin Transaction

VMC->(dbSetOrder(1))
VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR ))
While !VMC->(Eof()) .and. VMC->VMC_FILIAL == xFilial("VMC") .and. VMC->VMC_CODGAR == VMB->VMB_CODGAR
	RecLock("VMC",.f.,.t.)
	If VMC->VMC_ORIGEM == "3"
		VMC->(DbDelete())
	Else
		VMC->VMC_QPCRET := 0
		VMC->VMC_VTPECR := 0
		VMC->VMC_VUPECR := 0
		VMC->VMC_QSRRET := 0
		VMC->VMC_VTSERR := 0
		VMC->VMC_VALHRR := 0
		VMC->VMC_CUSMAR := 0
	EndIf
	VMC->(MsUnLock())
	VMC->(dbSkip())
EndDo

RecLock("VMB",.f.)
VMB->VMB_STATSG := " "
VMB->VMB_WARRME := " "
VMB->VMB_DTWMEM := CtoD(" ")
VMB->(MsUnLock())

// Atualiza o Status da Garantia ...
OFNJD15AS(cAlias,nReg,nOpc,.f.,.f.,.f.)

END TRANSACTION

MsgInfo(STR0197) // Processamento estornado

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15UM ∫ Autor ≥ Rubens              ∫ Data ≥ 10/09/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Verifica se uma determinada peca deveria ter sua unidade   ∫±±
±±∫          ≥ de medida convertida na transmiss„o da solicitada de gar.  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15UM(cCodGar,cParConvUM)

Local nPosConvUM
Local aConvUM := {}
Local aRegs := {}
Local nPos
Local cSQL
Local cMsg := ""
Local cAliasVMC := "TVMC"

cSQL := "SELECT VMC_GRUITE, VMC_CODITE, VMC_UM, VMC.R_E_C_N_O_ VMCRECNO, B1_DESC, B1_COD, B1_UM, B1_SEGUM, B1_TIPCONV, B1_CONV "
cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
cSQL +=  " JOIN " + RetSQLName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_GRUPO = VMC.VMC_GRUITE AND B1.B1_CODITE = VMC.VMC_CODITE AND B1.D_E_L_E_T_ = ' '"
cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
cSQL +=   " AND VMC_CODGAR = '" + cCodGar + "'"
cSQL +=   " AND VMC_TIPOPS = 'P'"
cSQL +=   " AND VMC.D_E_L_E_T_ = ' '"
cSQL +=   " AND B1.B1_UM = VMC_UM"
cSQL +=   " AND B1.B1_SEGUM <> '  '"
cSQL +=   " AND B1.B1_CONV <> 0"
cSQL +=   " AND B1.B1_TIPCONV <> ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC , .F., .T. )

If !(cAliasVMC)->(Eof())
	// Conversao de Unidade de Medida
	If !Empty(cParConvUM)
		aConvUM := StrTokArr(AllTrim(cParConvUM),";")
	Else
		AADD( aConvUM , "BD/L " ) // Por enquanto so sera feita validaÁ„o com Balde -> Litro
	EndIf
	//
EndIf

If Len(aConvUM) == 0
	(cAliasVMC)->(dbCloseArea())
	dbSelectArea("VMB")
	Return .t.
EndIf
aSort(aConvUM)

While !(cAliasVMC)->(Eof())
	If (nPos := aScan(aConvUM,{ |x| (cAliasVMC)->B1_UM $ AllTrim(x) })) <> 0
		For nPosConvUM := nPos to Len(aConvUM)
			nPos := At("/",aConvUM[nPosConvUM])
			cUMDe   := AllTrim(SubStr(aConvUM[nPosConvUM],1,nPos-1))
			cUMPara := AllTrim(SubStr(aConvUM[nPosConvUM],nPos+1))

			If cUMDe == AllTrim((cAliasVMC)->B1_UM) .and. cUMPara == AllTrim((cAliasVMC)->B1_SEGUM)
				cMsg += (cAliasVMC)->VMC_GRUITE + " - " + (cAliasVMC)->VMC_CODITE + " - " + (cAliasVMC)->B1_DESC + "-" + cUMDe + "->" + cUMPara + CHR(13) + CHR(10)
				AADD( aRegs , { (cAliasVMC)->VMCRECNO , (cAliasVMC)->B1_COD , (cAliasVMC)->B1_SEGUM } )
				Exit
			EndIf
		Next nPosConvUM
	EndIf
	//

	(cAliasVMC)->(dbSkip())
EndDo
(cAliasVMC)->(dbCloseArea())

If Len(aRegs) > 0
	cMsg := STR0198 + " " + chr(13) + chr(10) + chr(13) + chr(10) + cMsg // As peÁas abaixo n„o sofreram convers„o de unidade de medida na transmiss„o da solicitaÁ„o de garantia. Deseja converter antes de atualizar a Ordem de ServiÁo?
	If MsgYesNo(cMsg , STR0111)
		dbSelectArea("VMC")
		For nPos := 1 to Len(aRegs)
			VMC->(dbGoTo(aRegs[nPos,1]))
			RecLock("VMC",.f.)
			VMC->VMC_QTDPEC := Round( ConvUm(aRegs[nPos,2],VMC->VMC_QTDPEC,1,2) , TamSX3( "VMC_QTDPEC" )[2] )
			VMC->VMC_UM     := aRegs[ nPos , 3 ]
			VMC->(MsUnLock())
		Next nPos
	EndIf
EndIf

dbSelectArea("VMB")

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ MenuDef  ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 15/05/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Tratamento do menu aRotina							      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MenuDef()

Local aRotina := {;
	{ STR0093 , "AxPesqui"    , 0 , 1 },; // Pesquisar
	{ STR0094 , "OFNJD15EXEC" , 0 , 2 },; // Vizualizar
	{ STR0095 , "OFNJD15EXEC" , 0 , 3 },; // Incluir
	{ STR0096 , "OFNJD15EXEC" , 0 , 4 },; // Alterar
	{ STR0097 , "OFNJD15EXEC" , 0 , 5 },; // Excluir
	{ STR0098 , "OFNJD15CL"   , 0 , 6 },; // Clonar
	{ STR0099 , "OFNJD15TR"   , 0 , 6 },; // Transmitir
	{ STR0100 , "OFNJD15AS"   , 0 , 6 },; // Atualiza Status
	{ STR0101 , "OFNJD15NF"   , 0 , 6 },; // Transmitir NF
	{ STR0102 , "OFNJD15OS"   , 0 , 6 },; // Atualiza O.S.
	{ STR0103 , "OFNJD15CM"   , 0 , 6 },; // Cons. Memo Credito
	{ STR0104 , "OFNJD15RM"   , 0 , 6 },; // NF Remessa para Analise
	{ STR0106 , "OFNJD15PW"   , 0 , 3 },; // Altera Senha
	{ STR0116 , "OFNJD15EW"   , 0 , 6 },; // Estorna Proc. WM
	{ STR0125 , "OFNJD15AFP"  , 0 , 6 },; // "Alterar Cliente(Faturar Para)"
	{ STR0244 , 'OFNJD15023_CallDTF()'  , 0 , 6 },; // "Importa Warrmemo"
	{ STR0230 , "OFNJD15LTOK"  , 0 , 3 } } // "Limpar Token"


If __cUserID == "000000"
	AADD( aRotina , { STR0105 , "VEIVA350({'012'})" , 0 , 3 } ) // "Parametros"
EndIf

Return aRotina

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15SEQ∫ Autor ≥ Rubens Takahashi    ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera sequencia do arquivo VMC                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15SEQ(cFilVMC,cCodGar)

Local cRetorno

Default cFilVMC := xFilial("VMC")

cRetorno := FM_SQL("SELECT MAX(VMC_SEQGAR) FROM " + RetSQLName("VMC") + " WHERE VMC_FILIAL = '" + cFilVMC + "' AND VMC_CODGAR = '" + cCodGar + "' AND D_E_L_E_T_ = ' '")
cRetorno := StrZero(Val(cRetorno) + 1 , TamSX3("VMC_SEQGAR")[1])

Return cRetorno

/*/{Protheus.doc} OFNJD15CHK
Verifica se os itens da SolicitaÁ„o de Garantia ainda est„o requisitados na O.S.

@author Rubens
@since 28/04/2014
@version 1.0

@param cCodGar, string, Codigo da Solicitacao de Garantia
@return lRet, Indica se as peÁas/serviÁos est„o requisitados na O.S.

/*/
Function OFNJD15CHK(cCodGar)

Local aPecas
Local aSrvc
Local cSQL
Local cErro := ""
Local lRet := .t.
Local nTotPecVMC := 0
Local nTotPecVO3 := 0

Local nTotSerVMC := 0
Local nTotSerVO4 := 0

Local lVMB_SREEMB := (VMB->(FieldPos("VMB_SREEMB")) <> 0)

VMB->(dbSetOrder(1))
If !VMB->(MsSeek(xFilial("VMB") + cCodGar))
	Return .f.
EndIf

VO1->(dbSetOrder(1))
VO1->(dbSeek(xFilial("VO1") + VMB->VMB_NUMOSV ))

If !Empty(VMB->VMB_CHASSI) .AND. VO1->VO1_CHASSI <> VMB->VMB_CHASSI
	MsgStop(STR0199,STR0111) // Chassi da SolicitaÁ„o de Garantia est· diferente do Chassi da Ordem de ServiÁo / AtenÁ„o
	Return .f.
EndIf

VMC->(dbSetOrder(1))
If !VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR))
	MsgStop(STR0200,STR0111) // SolicitaÁ„o de garantia n„o possui itens / AtenÁ„o
	Return .f.
EndIf

If lVMB_SREEMB .and. VMB->VMB_SREEMB == "1" // Existindo o campo e marcando como Zerada, nao verifica se o TT esta liberado
Else
	// Ot·vio 24/01/2014 - N„o se pode transmitir garantias JD, seja ela qual for, sem antes liberar o tipo de tempo. Definido com John Deere (Neusa).
	cSQL := "SELECT COUNT(*) "
	cSQL += " FROM " + RetSQLName("VMB") + " VMB "
	cSQL += " JOIN " + RetSQLName("VMC") + " VMC ON VMB.VMB_FILIAL = VMC.VMC_FILIAL AND VMB.VMB_CODGAR = VMC.VMC_CODGAR AND VMC.VMC_LIBVOO = ' ' AND VMC.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE VMB.VMB_FILIAL = '" + VMB->VMB_FILIAL + "' "
	cSQL += " AND VMB.VMB_CODGAR = '" + VMB->VMB_CODGAR + "' "
	cSQL += " AND VMB.VMB_STATUS = ' ' " //NAO ENVIADO
	cSQL += " AND VMB.D_E_L_E_T_ = ' ' "
	If FM_SQL(cSQL) > 0
		MsgStop(STR0122,STR0111) // "O tipo de tempo referente a este registro de garantia ainda n„o foi liberado. Libere o tipo de tempo para depois transmitir a garantia!"
		Return .f.
	EndIf
	//
EndIf

// Se for qualquer revisao diferente de PDI, ou garantia de normal/especial, verifica se existe registro do produto
If VMB->VMB_TIPGAR $ "ZNRM/ZSPA" .or. (VMB->VMB_TIPGAR == "ZZMK" .and. VMB->VMB_INTSRV <> "PDI")
	cSQL := "SELECT VMY_NUMERO "
	cSQL +=  " FROM " + RetSQLName("VMY")
	cSQL += " WHERE VMY_FILIAL = '[VMY]'"
	cSQL +=   " AND VMY_GETKEY = '" + VMB->VMB_CHASSI + "'"
	cSQL +=   " AND VMY_DTTRAN <> '        '"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	aRet := FMX_SQLGC(cSQL)
	If Len(aRet) == 0 .and. !MsgNoYes(STR0027) // "N„o encontrado o registro do produto. Deseja transmitir garantia"
		Return .f.
	EndIf
EndIf
//

// Verifica se foi utilizando codigo de outros creditos de deslocamento para garantia diferente de REVISAO e PMP
If !VMB->VMB_TIPGAR $ "ZPIP/ZZMK"
	cSQL := "SELECT COUNT(*) "
	cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
	cSQL += " WHERE VMC.VMC_FILIAL = '" + xFilial("VMC") + "'"
	cSQL +=   " AND VMC.VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
	cSQL +=   " AND VMC.VMC_TIPOPS = 'O'"
	cSQL +=   " AND VMC.VMC_CODMAT IN ('WTYSUBL5','WTYSUBL6','WTYSUBL8')" // Codigos de DESLOCAMENTOS
	cSQL +=   " AND VMC.D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) > 0
		MsgStop(STR0123 + CHR(13) + CHR(10) + STR0124,STR0111) // "SÛ È permitido o envio de registro de deslocamento para solicitaÁ„o de garantia de Revis„o ou PMP"
		Return .f.
	EndIf
EndIf
//

If !OFNJD15007_VerificaLibVOO( "CHK" , VMB->VMB_NUMOSV , VMB->VMB_CODGAR )
	Return .f.
EndIF

// Por enquanto so verifica garantia normal e especial ...
If !VMB->VMB_TIPGAR $ "ZNRM/ZSPA"
	Return .t.
EndIf
//
cErro := ""
// ===================================== //
//    A N A L I S E   D E   P E C A S    //
// ===================================== //
aPecas := FMX_CALPEC(VMB->VMB_NUMOSV,,,,.f.,.f.,.t.,.t.,.t.,.f.,.f.,," VOI_SITTPO IN ('2','4') ",.f.,.f.)
nTotPecVO3 := 0
aEval(aPecas,{ |x| nTotPecVO3 += x[PECA_VALBRU] })

cSQL := "SELECT SUM(VMC_VTPECE) "
cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
cSQL +=   " AND VMC_CODGAR = '" + cCodGar + "'"
cSQL +=   " AND (VMC_TIPOPS = 'P' OR (VMC_TIPOPS = 'O' AND VMC_CODITE <> '       ' )) "
cSQL +=   " AND D_E_L_E_T_ = ' '"
nTotPecVMC := FM_SQL(cSQL)

If nTotPecVO3 <> nTotPecVMC
	cErro += STR0118 + ": " + Transform(nTotPecVO3, "@E 999,999,999.99" ) + CHR(13) + CHR(10) + ; // "Total de peÁas requisitadas"
				STR0119 + ": " + Transform(nTotPecVMC, "@E 999,999,999.99" ) + CHR(13) + CHR(10) + CHR(13) + CHR(10) // "Total de peÁas da solicitaÁ„o"
EndIf

// =========================================== //
//    A N A L I S E   D E   S E R V I C O S    //
// =========================================== //
aSrvc  := FMX_CALSER(VMB->VMB_NUMOSV,,,,.f.,.f.,.t.,.t.,.f.,.f.,," VOI_SITTPO IN ('2','4') ")
nTotSerVO4 := 0
aEval(aSrvc,{ |x| nTotSerVO4 += x[SRVC_VALBRU] })

cSQL := "SELECT SUM(VMC_VTSERE+VMC_CUSMAT) "
cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
cSQL +=   " AND VMC_CODGAR = '" + cCodGar + "'"
cSQL +=   " AND (VMC_TIPOPS = 'S' OR (VMC_TIPOPS = 'O' AND VMC_CODITE = '       ' )) "
cSQL +=   " AND D_E_L_E_T_ = ' '"
nTotSerVMC := FM_SQL(cSQL)

If nTotSerVO4 <> nTotSerVMC
	cErro += STR0120 + ": " + Transform(nTotSerVO4, "@E 999,999,999.99" ) + CHR(13) + CHR(10) + ; // "Total de serviÁos requisitados"
				STR0121 + ": " + Transform(nTotSerVMC, "@E 999,999,999.99" ) // "Total de serviÁos/outros crÈditos da solicitaÁ„o"
EndIf

If !Empty(cErro)
	AVISO(STR0111, STR0117 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cErro, { STR0146 } , 3) // AtenÁ„o / 'DivergÍncia entre o total das requisiÁıes de peÁas/serviÁos com o total dos itens da solicitaÁ„o de garantia.' / Ok
	lRet := .f.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ AjustaHelp∫ Autor ≥ Rubens              ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Ajusta Help                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
//Static Function AjustaHelp()
//
//Local aHelpEng, aHelpSpa, aHelpPor
//
//aHelpPor := { STR0201 + " ",STR0202 } // Tipo de tempo cancelado com / saldo de pecas requisitadas.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PNJD15TTCAN",aHelpPo/r,aHelpEng,aHelpSpa,.t.)
//
//aHelpPor := { STR0203,STR0204,STR0205 } // Tipo de tempo inv·lido. / Necess·rio informar tipo de / tempo diferente de garantia.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PNJD15TT",aHelpPor,aHelpEng,aHelpSpa,.t.)
//
//Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15OPC∫ Autor ≥ Rubens Takahashi    ∫ Data ≥ 14/05/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Retorna Opcao para criacao da GetDados                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OFNJD15OPC(cTipReg, aAuxACols , cTipGar )

Local nRetOpcGD := GD_INSERT+GD_UPDATE+GD_DELETE

If cTipGar $ "ZZMK/ZPIP/ZNRM/ZPAR/ZZBT" .and. Len(aAuxACols) == 0
	nRetOpcGD := 0
EndIf

Return nRetOpcGD

// Controle interno, nao deve refletir ambiente oficial do cliente
Function OFNJD15SIMU()
	Local lRetorno := .f.
	If cEmpAnt == "99" .and. GetNewPar("MV_XMILJD1",.f.)
		lRetorno := .t.
	EndIf
Return lRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15AFP∫ Autor ≥ Rubens Takahashi    ∫ Data ≥ 06/11/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Atualiza o cliente(faturar para) de TT de garantia         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15AFP(cAlias,nReg,nOpc)

Local aParamBox := {}
Local aRetParam := {}
Local cSQL
Local cAliasAFP := "TAFP"
Local cLinha := ""

If Empty(VMB->VMB_WARRME)
	MsgStop(STR0129,STR0111) // "O warrmemo n„o foi importado."
	Return .t.
EndIf

cSQL := "SELECT DISTINCT VMC_TIPTEM, VOO_FATPAR, VOO_LOJA, A1_NOME"
cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
cSQL +=  " JOIN " + RetSQLName("VMC") + " VMC ON VMC.VMC_FILIAL = '" + xFilial("VMC") + "' AND VMC.VMC_CODGAR = VMB.VMB_CODGAR AND VMC.D_E_L_E_T_ = ' '"
cSQL +=  " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VMC.VMC_TIPTEM AND VOI.VOI_SITTPO = '2' AND VOI.D_E_L_E_T_ = ' '"
cSQL +=  " JOIN " + RetSQLName("VOO") + " VOO ON VOO.VOO_FILIAL = '" + xFilial("VOO") + "' AND VOO.VOO_NUMOSV = VMB.VMB_NUMOSV AND VOO.VOO_LIBVOO = VMC.VMC_LIBVOO AND VOO.D_E_L_E_T_ = ' '"
cSQL +=  " JOIN " + RetSQLName("SA1") + " SA1 ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "' AND SA1.A1_COD = VOO.VOO_FATPAR AND SA1.A1_LOJA = VOO.VOO_LOJA AND SA1.D_E_L_E_T_ = ' '"
cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMC") + "'"
cSQL +=   " AND VMB_CODGAR = '" + VMB->VMB_CODGAR + "'"
cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"
cSQL +=   " AND (VMC_TIPOPS = 'P' OR (VMC.VMC_TIPOPS = 'O' AND VMC.VMC_CODITE <> '  ' ))"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasAFP , .F., .T. )
If (cAliasAFP)->(Eof())
	(cAliasAFP)->(dbCloseArea())
	dbSelectArea("VMB")
	Return .t.
EndIf

// Verifica se ja foi gerada nota fiscal para este tipo de tempo ...
cSQL := "SELECT DISTINCT VOO_NUMNFI"
cSQL +=  " FROM " + RetSQLName("VOO") + " VOO "
cSQL += " WHERE VOO.VOO_FILIAL = '" + xFilial("VOO") + "'"
cSQL +=   " AND VOO.VOO_NUMOSV = '" + VMB->VMB_NUMOSV + "'"
cSQL +=   " AND VOO.VOO_TIPTEM = '" + (cAliasAFP)->VMC_TIPTEM + "'"
cSQL +=   " AND VOO.D_E_L_E_T_ = ' '"
If !Empty(FM_SQL(cSQL))
	MsgStop(STR0126,STR0111) // "N„o È possÌvel alterar o cliente, pois j· existe uma nota fiscal gerada para este tipo de tempo."
	(cAliasAFP)->(dbCloseArea())
	dbSelectArea("VMB")
	Return .t.
EndIf
//
aAdd(aParamBox,{1,RetTitle("VOO_TIPTEM"), (cAliasAFP)->VMC_TIPTEM ,"@!","",""   ,".f.",0,.T.}) // Tipo de Tempo
aAdd(aParamBox,{1,RetTitle("C5_CLIENTE"), (cAliasAFP)->VOO_FATPAR ,"@!","",""   ,".f.",0,.T.}) // Cliente
aAdd(aParamBox,{1,RetTitle("C5_LOJA")   , (cAliasAFP)->VOO_LOJA   ,"@!","",""   ,".f.",0,.T.}) // Loja
aAdd(aParamBox,{1,RetTitle("A1_NOME")   , (cAliasAFP)->A1_NOME    ,"@!","",""   ,".f.",80,.T.}) // Nome
aAdd(aParamBox,{1,RetTitle("C5_CLIENTE"), Space(TamSX3("VOO_FATPAR")[1]) ,"@!","","SA1",""   ,0,.T.}) // Cliente
aAdd(aParamBox,{1,RetTitle("C5_LOJA")   , Space(TamSX3("VOO_LOJA"  )[1]) ,"@!","",""   ,""   ,0,.T.}) // Loja

(cAliasAFP)->(dbCloseArea())
dbSelectArea("VMB")

While .t.
	If !ParamBox(aParamBox,STR0125,@aRetParam,,,,,,,,.f.) // "Alterar Cliente(Faturar Para)"
		Return .f.
	EndIf
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek( xFilial("SA1") + aRetParam[5] + aRetParam[6] ))
		cLinha := aParamBox[5,2] + ": " + aRetParam[5] + "-" + aRetParam[6] + SA1->A1_NOME
		Exit
	Else
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("C5_CLIENTE")) + ": " + aRetParam[5] + " - " + aRetParam[6] ,4,1)
	EndIf
EndDo

cLinha := STR0127 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // "Confirma a alteraÁ„o do cliente (faturar para) do tipo de tempo ?"
	aParamBox[1,2] + ": " + aParamBox[1,3] + CHR(13) + CHR(10) + ;
	cLinha
If !MsgYesNo(cLinha,STR0111)
	Return
EndIf

Begin Transaction
OFNJD15FP("VO3", VMB->VMB_NUMOSV, aRetParam[1], aRetParam[5], aRetParam[6])
OFNJD15FP("VO4", VMB->VMB_NUMOSV, aRetParam[1], aRetParam[5], aRetParam[6])
OFNJD15FP("VOO", VMB->VMB_NUMOSV, aRetParam[1], aRetParam[5], aRetParam[6])
End Transaction

dbSelectArea("VMB")

MsgInfo(STR0128,STR0111) // "Cliente alterado."

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15FP ∫ Autor ≥ Rubens Takahashi    ∫ Data ≥ 06/11/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Altera registros de requisicao com o novo cliente          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function OFNJD15FP(cAuxAlias, cNumOsv, cTipTem, cCliente, cLoja)

Local cAliasAlt := "TALT"

// Requisicao de PeÁas ..
cSQL := "SELECT R_E_C_N_O_ TREC"
cSQL +=  " FROM " + RetSQLName(cAuxAlias) + " " + cAuxAlias + " "
cSQL += " WHERE " + cAuxAlias + "." + cAuxAlias + "_FILIAL = '" + xFilial(cAuxAlias) + "'"
cSQL +=   " AND " + cAuxAlias + "." + cAuxAlias + "_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND " + cAuxAlias + "." + cAuxAlias + "_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND " + cAuxAlias + ".D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasAlt , .F., .T. )
While !(cAliasAlt)->(Eof())
	dbSelectArea(cAuxAlias)
	dbGoTo( (cAliasAlt)->TREC )
	RecLock(cAuxAlias , .f. )
	&(cAuxAlias + "_FATPAR") := cCliente
	&(cAuxAlias + "_LOJA")   := cLoja
	MsUnlock()
	(cAliasAlt)->(dbSkip())
EndDo
(cAliasAlt)->(dbCloseArea())
DbSelectArea("VMB")
//

Return

/*/{Protheus.doc} OFNJD15001_AdicionaCamposCustomizados
Adiciona campos customizados nas matrizes de campos que ser„o utilizadas nas grid de ServiÁos e Outros CrÈditos
@author Rubens
@since 24/05/2016
@version undefined
@param aCampos, array, Matriz de campos que ser„o exibidos na grid
@param aCpoCustomizado, array, Matriz de campos customizados
@param cTipoFiltro, characters, Filtro para adicionar campos na matriz de campos
@type function
/*/
Static Function OFNJD15001_AdicionaCamposCustomizados(aCampos,aCpoCustomizado,cTipoFiltro)
	Local nCont
	For nCont := 1 to Len(aCpoCustomizado)
		If aCpoCustomizado[nCont,1] == cTipoFiltro
			AADD( aCampos , aCpoCustomizado[nCont,2])
		EndIf
	Next nCont
Return

/*/{Protheus.doc} OFNJD15002_NovaLinhaRequisicaoVO4
Adiciona uma linha na matriz que ser· utilizada na integraÁ„o com a requisicao de servicos
@author Rubens
@since 24/05/2016
@version undefined
@param aAuxIteVO4, array, Matriz que contem os dados de uma linha da matriz de integraÁ„o=
@param nValorServico, numeric, Valor do serviÁo
@param nPosGet, numeric, PosiÁ„o da Grid de Outros CrÈditos
@param aCpoCustomizado, array, Matriz com nome dos campos customizados
@type function
/*/
Static Function OFNJD15002_NovaLinhaRequisicaoVO4( aAuxIteVO4 , nValorServico , nPosGet , aCpoCustomizado)

	Local nCont

	If VOI->VOI_TIPTEM <> oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")]
		VOI->(MsSeek( xFilial("VOI") + oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] ))
	EndIf

	If VOK->VOK_TIPSER <> oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPSER","aHOutr")]
		VOK->(MsSeek( xFilial("VOK") + oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPSER","aHOutr")] ))
	EndIf

	AADD(aAuxIteVO4, { "VO4_TIPTEM" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPTEM","aHOutr")] , nil } )
	If !Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_FATPAR","aHOutr")])
		AADD(aAuxIteVO4, { "VO4_FATPAR" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_FATPAR","aHOutr")] , nil } )
		AADD(aAuxIteVO4, { "VO4_LOJA"   , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_LOJA"  ,"aHOutr")] , nil } )
	EndIf
	AADD(aAuxIteVO4, { "VO4_GRUSER" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_GRUSER","aHOutr")] , nil } )
	AADD(aAuxIteVO4, { "VO4_CODSER" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODSER","aHOutr")] , nil } )
	AADD(aAuxIteVO4, { "VO4_TIPSER" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_TIPSER","aHOutr")] , nil } )
	// Deslocamento
	If VOK->VOK_INCMOB == "5"
		AADD(aAuxIteVO4, { "VO4_KILROD" , 1 , nil } )
		AADD(aAuxIteVO4, { "VO4_PREKIL" , nValorServico , nil } )
	// Servico de Terceiros
	ElseIf VOK->VOK_INCMOB == "2"
		AADD(aAuxIteVO4, { "VO4_VALVEN" , nValorServico , nil } )
	EndIf
	AADD(aAuxIteVO4, { "VO4_CODSEC" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_CODSEC","aHOutr")] , nil } )
	If VOI->VOI_DEPINT == "1" .and. !Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPINT","aHOutr")])
		AADD(aAuxIteVO4, { "VO4_DEPINT" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPINT","aHOutr")] , nil } )
	EndIf
	If VOI->VOI_DEPGAR == "1" .and. !Empty(oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPGAR","aHOutr")])
		AADD(aAuxIteVO4, { "VO4_DEPGAR" , oGetOutr:aCols[nPosGet,FG_POSVAR("OUT_DEPGAR","aHOutr")] , nil } )
	EndIf

	For nCont := 1 to Len(aCpoCustomizado)
		If aCpoCustomizado[nCont,1] == "OUTROSCREDITOS"
			cAuxCpo := "OUT_" + Right(aCpoCustomizado[nCont,2],Len(aCpoCustomizado[nCont,2])-4)
			If !Empty(oGetOutr:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHOutr")])
				AADD(aAuxIteVO4, { aCpoCustomizado[nCont,2] , oGetOutr:aCols[nPosGet,FG_POSVAR(cAuxCpo,"aHOutr")] , nil } )
			EndIf
		EndIf
	Next nCont

Return


/*/{Protheus.doc} OFNJD15003_NaoPodeAtu
Retorna se N√O pode prosseguir com a AtualizaÁ„o da Ordem de ServiÁo
@author Rubens
@since 15/08/2017
@version undefined

@type function
/*/
Static Function OFNJD15003_NaoPodeAtu()
	// Verifica campo de arquivo de retorno (Warranty Memo)
	If Empty(VMB->VMB_WARRME)
		MsgStop(STR0152) // Arquivo de retorno (Warranty Memo) n„o foi processado. Favor processar o arquivo antes de tentar atualizar a Ordem de ServiÁo
		Return .t.
	EndIf

	// Verifica se trata de uma solicitacao da Serie 5000
	If (VMB->VMB_TIPGAR == "ZZMK" .and. VMB->VMB_TOTALW < 1 )
		cSQL := "SELECT DISTINCT VO4_DATFEC "
		cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
		cSQL +=         " JOIN " + RetSQLName("VMC") + " VMC "
		cSQL +=                "  ON VMC.VMC_FILIAL = VMB.VMB_FILIAL"
		cSQL +=                " AND VMC.VMC_CODGAR = VMB.VMB_CODGAR"
		cSQL +=                " AND VMC.D_E_L_E_T_ = ' '"
		cSQL +=         " JOIN " + RetSQLName("VO4") + " VO4 "
		cSQL +=                "  ON VO4.VO4_FILIAL = VMB.VMB_FILIAL"
		cSQL +=                " AND VO4.VO4_NUMOSV = VMB.VMB_NUMOSV"
		cSQL +=                " AND VO4.VO4_GRUSER = VMC.VMC_GRUSER"
		cSQL +=                " AND VO4.VO4_CODSER = VMC.VMC_CODSER"
		cSQL +=                " AND VO4.D_E_L_E_T_ = ' '"
		cSQL += "WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=  " AND VMB.VMB_CODGAR = '" + VMB->VMB_CODGAR + "'"
		cSQL +=  " AND VMB.D_E_L_E_T_ = ' '"
		cSQL +=  " AND VMC.VMC_CODSER <> '         '"
		Return (!Empty(FM_SQL(cSQL)))
	EndIf

	// Verifica campo de Status S.G.
	If VMB->VMB_STATSG <> "4"
		MsgStop(STR0041 + chr(13) + chr(10) + chr(13) + chr(10) + STR0153 + " " + X3CBOXDESC("VMB_STATSG",VMB->VMB_STATSG)) // "N„o È possÌvel atualizar a O.S." / Status da solicitaÁ„o:
		Return .t.
	EndIf
Return .f.


/*/{Protheus.doc} OFNJD15006_NaoUsarTTGar
Retorna se nao pode usar o tipo de tempo de garantia na atualizacao de ordem de servico
@author Rubens
@since 25/01/2019
@version 1.0
@return ${return}, ${return_description}
@param cGruIte, characters, descricao
@param cCodIte, characters, descricao
@type function
/*/
Static Function OFNJD15006_NaoUsarTTGar(cGruIte, cCodIte)
	Local nPosVMCPeca := aScan(aVMCPeca,{ |x| x[_VMC_PECA_GRUITE_] == cGruIte .and. x[_VMC_PECA_CODITE_] == cCodIte })
	Local lRetorno := .t.

	If nPosVMCPeca <> 0
		If aVMCPeca[ nPosVMCPeca , _VMC_PECA_QTDPECRETORNADA_ ] > aVMCPeca[ nPosVMCPeca , _VMC_PECA_QTDPEC_ ]
			lRetorno := .f.
		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} OFNJD15007_VerificaLibVOO
Verifica se existe o registro de liberacao do tipo de tempo È valido
@author Rubens
@since 31/10/2017
@version 1.0
@return ${return}, ${return_description}
@param cChamada, characters, descricao
@param cNumOsv, characters, descricao
@param cCodGar, characters, descricao
@type function
/*/
Static Function OFNJD15007_VerificaLibVOO( cChamada , cNumOsv , cCodGar )

	Local cAliasCHK := "TVMCCHK"
	Local cErro := ""

	// Se for um registro sem reembolso, nao verifica liberaÁ„o, pois
	// n„o existira liberacao do registro da VMC na Ordem de Servico
	// cada concessionario podera cobrar da forma que desejar, sendo interno ou contra o cliente
	cSQL := ;
		"SELECT VMB_SREEMB " +;
			" FROM " + RetSQLName("VMB") + " VMB " +;
		" WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "' " +;
			" AND VMB.VMB_CODGAR = '" + cCodGar + "' " +;
			" AND VMB.D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == "1"
	
		// Neste momento deve existir um registro de liberaÁ„o de serviÁo com tipo de tempo de cliente ou interno
		If cChamada == "CHK"
			cSQL := ;
				"SELECT COUNT(*) " +;
				" FROM " + RetSQLName("VOO") + " VOO " +;
				" JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "'" +;
												" AND VOI.VOI_TIPTEM = VOO.VOO_TIPTEM " +;
												" AND VOI.D_E_L_E_T_ = ' ' " +;
				" JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VOO.VOO_FILIAL " +;
												" AND VO4.VO4_TIPTEM = VOO.VOO_TIPTEM " +;
												" AND VO4.VO4_NUMOSV = VOO.VOO_NUMOSV " +;
												" AND VO4.VO4_FATPAR = VOO.VOO_FATPAR " +;
												" AND VO4.VO4_LOJA   = VOO.VOO_LOJA "   +;
												" AND VO4.VO4_LIBVOO = VOO.VOO_LIBVOO " +;
												" AND VOI.D_E_L_E_T_ = ' ' " +;
				" JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") +"'"+;
												" AND VOK.VOK_TIPSER = VO4.VO4_TIPSER " +;
												" AND VOK.VOK_INCMOB NOT IN ('2','5') " +;
												" AND VOK.D_E_L_E_T_ = ' ' " +;
				" WHERE VOO.VOO_FILIAL = '" + xFilial("VOO") + "'" +;
				" AND VOO.VOO_NUMOSV = '" + cNumOsv + "'" +;
				" AND VOO.D_E_L_E_T_ = ' ' " +;
				" AND VOI.VOI_SITTPO IN ('1','3')" // Cliente ou Interno
			If FM_SQL(cSQL) <= 0
				cErro := STR0142 + ;
					CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
					STR0145 + CHR(13) + CHR(10) + ;// "N„o È possÌvel continuar." "Registro de liberaÁ„o de tipo de tempo n„o encontrado."
					STR0215 // "Para prosseguir com a transmiss„o, faÁa requisiÁ„o e liberaÁ„o de serviÁo com tipo de tempo de cliente ou interno."

				AVISO(STR0111, cErro, { STR0146 } , 3)
				Return .f.

			EndIf
		EndIf
		
		Return .t.

	EndIf
	// Fim Sem Reembolso

	// Verifica se houve alguma alteraÁ„o das liberaÁıes de Tipo de Tempo ...
	VOO->(dbSetOrder(1))
	cSQL := "SELECT DISTINCT VMC_TIPTEM, VMC_LIBVOO "
	cSQL +=  " FROM " + RetSQLName("VMC") + " VMC "
	cSQL += " WHERE VMC.VMC_FILIAL = '" + xFilial("VMC") + "' "
	cSQL +=   " AND VMC.VMC_CODGAR = '" + cCodGar + "' "
	If cChamada == "AT" // AtualizaÁ„o de OS
		cSQL +=   " AND VMC.VMC_ORIGEM <> '3' "
	EndIf
	cSQL +=   " AND VMC.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasCHK , .F., .T. )
	While !(cAliasCHK)->(Eof())
		If !VOO->(dbSeek(xFilial("VOO") + cNumOsv + (cAliasCHK)->VMC_TIPTEM + (cAliasCHK)->VMC_LIBVOO ))
			cErro := RetTitle("VMB_NUMOSV") + ": " + cNumOsv + CHR(13) + CHR(10) + ;
						RetTitle("VMC_TIPTEM") + ": " + (cAliasCHK)->VMC_TIPTEM + CHR(13) + CHR(10) + ;
						RetTitle("VOO_LIBVOO") + ": " + (cAliasCHK)->VMC_LIBVOO + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		EndIf
		(cAliasCHK)->(dbSkip())
	EndDo
	(cAliasCHK)->(dbCloseArea())
	dbSelectArea("VMB")
	If !Empty(cErro)

		Do Case
		Case cChamada == "CHK" ; cMsgErro := STR0142 // "N„o È possÌvel continuar."
		Case cChamada == "CL"  ; cMsgErro := STR0143 // "N„o È possÌvel clonar solicitaÁ„o de garantia."
		Case cChamada == "AT"  ; cMsgErro := STR0144 // "N„o È possÌvel atualizar Ordem de ServiÁo."
		End Case

		cErro := cMsgErro + ;
			CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
			STR0145 + ; // "Registro de liberaÁ„o de tipo de tempo n„o encontrado."
			CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
			cErro

		AVISO(STR0111, cErro, { STR0146 } , 3)
		Return .f.
	EndIf
	//

Return .t.



/*/{Protheus.doc} OFNJD15SEMREEMBOLSO
Retorna se solicitaÁ„o de garantia È uma garantia sem reembolso
@author Rubens
@since 18/06/2018
@version 1.0
@return lRetorno, Retorna se È uma solicitacao sem reembolso
@param cNumOsv, characters, Numero da ordem de servico a ser pesquisada
@type function
/*/
Static Function OFNJD15SEMREEMBOLSO()
	Local lRetorno := .f.
	Local lVMB_SREEMB := (VMB->(FieldPos("VMB_SREEMB")) <> 0)

	If lVMB_SREEMB .and. VMB->VMB_SREEMB == "1" // Existindo o campo e marcando como Zerada, nao verifica se o TT esta liberado
		lRetorno := .t.
	Endif

Return lRetorno
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ OFNJD15009_GarantiaEspecial                                ∫±±
±±∫Autor     ≥ Fernando Vitor Cavani                   ∫Data ≥ 22/05/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ VerificaÁ„o especÌfica por Marca (Garantia Especial)       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ cNumOsv = N˙mero da Ordem de ServiÁo                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Retorno   ≥ True ou False                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Oficina                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFNJD15009_GarantiaEspecial(cNumOsv)
Local lretorno := .t.

Default cNumOsv := ""

If !Empty(cNumOsv)
	cSQL := "SELECT R_E_C_N_O_ "
	cSQL += "FROM " + RetSQLName("VMB") + " VMB "
	cSQL += "WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "' "
	cSQL += "  AND VMB.VMB_NUMOSV = '" + cNumOsv + "' "
	cSQL += "  AND VMB.VMB_TIPGAR = 'ZSPA' "
	cSQL += "  AND VMB.VMB_STATUS IN('03','09','12') "
	cSQL += "  AND VMB.D_E_L_E_T_ = ' ' "

	If FM_SQL(cSQL) > 0
		// Se encontrar Garantia Especial desconsiderar, ent„o .f.
		lretorno := .f.
	EndIf
EndIf
Return lRetorno



/*/{Protheus.doc} OFNJD15010_VldDelPeca
Funcao resposavel por validar se uma linha da Grid de Pecas pode ser excluida antes de confirmar a atualizacao da Ordem de Servico

@author Rubens
@since 25/05/2018
@version 1.0
@return logico, Retorna se a linha pode ou nao ser excluida
@param nPosGet, numeric, descricao
@type function
/*/
Function OFNJD15010_VldDelPeca(nPosGet)

	Default nPosGet := oGetPeca:nAt

	If !Empty(oGetPeca:aCols[ nPosGet , FG_POSVAR("PEC_STATUS","aHPeca")])
		MsgInfo(STR0213,STR0111) // "Item n„o pode ser excluÌdo da atualizaÁ„o da Ordem de ServiÁo."
		Return .f.
	EndIf

Return .t.



Static Function OFINJD15TCK(cAlias,nReg,nOpc,lSchedule)

OFNJD15AS(cAlias,nReg,nOpc,.f.      , .t.     , .f.  , .f.     )
//OFNJD15AS(cAlias,nReg,nOpc,lExibeMsg,lSetDebug,lMsgWS,lSchedule)
OFNJD15CM(cAlias,nReg,nOpc,.f.)

Return

Static Function OFNJD15008_EspecialVerPecaJD( nTPecaJD, nTPecaJDZSPA )

	Local nAuxPos
	//Local nTruncar
	Local nDecVO3VALPEC := TamSX3("VO3_VALPEC")[2]
	
	If nTPecaJD == nTPecaJDZSPA
		Return .t.
	EndIf
	aSort( aVMCPeca ,,, { |x,y| x[ _VMC_PECA_VLRTOTALRETORNADO_ ] > y[ _VMC_PECA_VLRTOTALRETORNADO_ ] } )

	nAuxDif := nTPecaJD - nTPecaJDZSPA
	If nAuxDif > 0
		nAuxPos := aScan( aVMCPeca , { |x| x[ _VMC_PECA_QTDPECRETORNADA_ ] == 1 .and. x[ _VMC_PECA_VLRUNIT_ZSPA_ ] > nAuxDif } )
	Else
		nAuxPos := aScan( aVMCPeca , { |x| x[ _VMC_PECA_QTDPECRETORNADA_ ] == 1 } )
	EndIf

	If nAuxPos <> 0
		aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNIT_ZSPA_  ] += nAuxDif
		aVMCPeca[ nAuxPos , _VMC_PECA_VLRTOTAL_ZSPA_ ] += nAuxDif
		nTPecaJDZSPA += nAuxDif

		aSort( aVMCPeca ,,, { |x,y| x[ _VMC_PECA_GRUITE_ ] + x[ _VMC_PECA_CODITE_ ] < y[ _VMC_PECA_GRUITE_ ] + y[ _VMC_PECA_CODITE_ ] } )
		Return
	EndIf

	//nTruncar := 10 ** nDecVO3VALPEC

	For nAuxPos := 1 to Len(aVMCPeca)

		nAuxQtd     := aVMCPeca[ nAuxPos , _VMC_PECA_QTDPECRETORNADA_ ]
		nAuxVlrPeca := aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNIT_ZSPA_    ]
		nAuxVlrTot  := Round(aVMCPeca[ nAuxPos , _VMC_PECA_QTDPECRETORNADA_ ] * aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNIT_ZSPA_ ], 2)// aVMCPeca[ nAuxPos , _VMC_PECA_VLRTOTALRETORNADO_    ]

		nAuxVlrTot += nAuxDif

		nVlrUnitCalc := Round( ( nAuxVlrTot / nAuxQtd ) , nDecVO3VALPEC)

		// Calcula o valor unitario truncado para verificar se È possÌvel jogar a diferenca na peca 
//		If (Int( ( nAuxVlrTot / nAuxQtd ) * nTruncar ) / nTruncar) - (nAuxVlrTot / nAuxQtd) == 0
		If Round(nVlrUnitCalc * nAuxQtd, 2) == nAuxVlrTot

			aVMCPeca[ nAuxPos , _VMC_PECA_VLRUNIT_ZSPA_      ] := nVlrUnitCalc 
			aVMCPeca[ nAuxPos , _VMC_PECA_VLRTOTAL_ZSPA_     ] := Round(aVMCPeca[ nAuxPos , _VMC_PECA_QTDPECRETORNADA_ ] * nVlrUnitCalc ,2)

			nTPecaJDZSPA += nAuxDif

			Exit
		EndIf

	Next nAuxPos

	aSort( aVMCPeca ,,, { |x,y| x[ _VMC_PECA_GRUITE_ ] + x[ _VMC_PECA_CODITE_ ] < y[ _VMC_PECA_GRUITE_ ] + y[ _VMC_PECA_CODITE_ ] } )

Return

/*/{Protheus.doc} OFNJD15011_RetornaMarca
Retorna o codigo da marca utilizada para buscar o Cliente Faturar Para
@author Rubens
@since 16/08/2018
@version 1.0
@return cRetorno, Codigo da Marca
@param cVV1Marca, characters, descricao
@type function
/*/
Function OFNJD15011_RetornaMarca(cVV1Marca)

	Local cSQL 
	Local cRetMarca

	cSQL := ;
		"SELECT VE1_1.VE1_CODMAR, '0' " +;
			" FROM " + RetSQLName("VE1") + " VE1_1 " +;
		" WHERE VE1_1.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
			" AND VE1_1.VE1_CODMAR = '" + cVV1Marca + "' " +;
			" AND VE1_1.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM') " +;
			" AND VE1_1.D_E_L_E_T_ =  ' '  " +;
		" UNION " +;
		"SELECT VE1_2.VE1_CODMAR, '1' " +;
			" FROM " + RetSQLName("VE1") + " VE1_2 " +;
		" WHERE VE1_2.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
			" AND VE1_2.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM') " +;
			" AND VE1_2.D_E_L_E_T_ =  ' '  " +;
		" ORDER BY 2 "
	cRetMarca := FM_SQL(cSQL)

Return cRetMarca


/*/{Protheus.doc} OFNJD15006_NaoUsarTTGar
Retorna se nao pode usar o tipo de tempo de garantia na atualizacao de ordem de servico - SERVICOS
@author Rubens
@since 31/10/2017
@version 1.0
@return ${return}, ${return_description}
@param nRecVMC, numeric, Recno da VMC para relacionar com a aVMCSrvc
@type function
/*/
Static Function OFNJD15012_NaoUsarTTGar(nRecVMC)

	Local nPosVMCSrvc
	Local lRetorno := .t.

	If nRecVMC <> 0

		nPosVMCSrvc := aScan(aVMCSrvc,{ |x| x[_VMC_SRVC_RECNO_] == nRecVMC })
		If nPosVMCSrvc <> 0
			If aVMCSrvc[ nPosVMCSrvc , _VMC_SRVC_NAOAPROVADO_ ]
				lRetorno := .f.
			EndIf
		EndIf
	EndIf

Return lRetorno

Function OFNJD15013_VldDelSrvc(nPosGet)

	Default nPosGet := oGetSrvc:nAt

	If ! Empty(oGetSrvc:aCols[ nPosGet , FG_POSVAR("SER_STATUS","aHSrvc")])
		OFNJD15014_Help("NJD15DELSRVC", STR0213) // "Item n„o pode ser excluÌdo da atualizaÁ„o da Ordem de ServiÁo."
		Return .f.
	EndIf

Return .t.


Static Function OFNJD15014_Help(cNomeHelp, cTexto, cSolucao)
	Default cSolucao := ""

	Help(;
		NIL, NIL,; // cRotina , nLinha
		cNomeHelp,; // cCampo
		,; // cNome
		cTexto,; // cMensagem
		1,; // nLinha1
		0,; // nColuna
		NIL, NIL, NIL, NIL,; // lPop , hWnd , nHeight , nWidth  
		NIL,; // lGravaLog
		{ cSolucao } ) // aSoluc
Return


Static Function OFNJD15015_TipSerRequisicao( cNumOsv, cTipTem, cGruSer, cCodSer )

	Local cQuery := ""
	Local cRetorno

	cQuery := ;
		"SELECT VO4_TIPSER " +;
		" FROM " + RetSQLName("VO4") + " VO4 " +;
		" WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'" +;
		  " AND VO4.VO4_NUMOSV = '" + cNumOsv + "'" +;
		  " AND VO4.VO4_TIPTEM = '" + cTipTem + "'" +;
		  " AND VO4.VO4_GRUSER = '" + cGruSer + "'" +;
		  " AND VO4.VO4_CODSER = '" + cCodSer + "'" +;
		  " AND VO4.D_E_L_E_T_ = ' '"
	cRetorno := FM_SQL(cQuery)

Return cRetorno


Function OFNJD15016_VldDelOutrosCred(nPosGet)

	Default nPosGet := oGetOutr:nAt

	If ! Empty(oGetOutr:aCols[ nPosGet , FG_POSVAR("OUT_STATUS","aHOutr")])
		MsgInfo(STR0213,STR0111) // "Item n„o pode ser excluÌdo da atualizaÁ„o da Ordem de ServiÁo."
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} OFNJD15018_ValoresCorretos
Indica se os valores estao de acordo com os valores retornados pela fabrica
@author rubens.takahashi
@since 26/12/2019
@version 1.0
@return lRetorno, Indica se os valores estao corretos
@param cNumOsv, characters, description
@type function
/*/
Function OFNJD15018_ValoresCorretos(cNumOsv)

	Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006",""))
	Local cAuxCodMar := FMX_RETMAR(cMVMIL0006)
	Local lRetorno := .t.
	Local cAliasVOO := "TVOO"

	cSQL := "SELECT VOO_NUMOSV, VOO_TIPTEM, VOO_FATPAR, VOO_LOJA, VOO_TOTPEC, VOO_HRSPAD, VOO_HRSAPL, VOO_TOTSRV, VOO_PESQLJ, VOO_NUMNFI, VOO_SERNFI"
	cSQL += " , VOO_LIBVOO "
	cSQL +=  " FROM " + RetSQLName("VOO") + " VOO "
	cSQL += " WHERE VOO.VOO_FILIAL = '" + xFilial("VOO") + "'"
	cSQL +=   " AND VOO.VOO_NUMOSV = '" + cNumOsv + "'"
	cSQL +=   " AND EXISTS ( SELECT VOI_TIPTEM "
	cSQL +=                  " FROM " + RetSQLName("VOI") + " VOI "
	cSQL +=                 " WHERE VOI.VOI_FILIAL = '" + xFilial("VOI") + "'" 
	cSQL +=                   " AND VOI.VOI_TIPTEM = VOO.VOO_TIPTEM "
	cSQL +=                   " AND VOI.VOI_SITTPO IN ('2','4')"
	cSQL +=                   " AND VOI.D_E_L_E_T_ = ' ' )"
	cSQL +=   " AND VOO.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VOO_TIPTEM"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVOO , .F., .T. )
	While !(cAliasVOO)->(Eof())

		lRetorno := OFNJD15019_ValidaTTGarantia(;
			(cAliasVOO)->VOO_NUMOSV,;
			(cAliasVOO)->VOO_TIPTEM,;
			(cAliasVOO)->VOO_LIBVOO,;
			(cAliasVOO)->VOO_TOTPEC ,;
			(cAliasVOO)->VOO_TOTSRV ,;
			cAuxCodMar )
		
		If ! lRetorno
			Exit
		EndIf
		
		(cAliasVOO)->(dbSkip())
	End
	(cAliasVOO)->(dbCloseArea())

	dbSelectArea("VMB")

Return lRetorno

/*/{Protheus.doc} OFNJD15019_ValidaTTGarantia
Valida o Tipo de tempo de Garantia para verificar se os valores estao de acordo com os valores retornados pela John Deere
@author rubens.takahashi
@since 26/12/2019
@version 1.0
@return lRetorno, Indica se a Ordem de Servico foi atualizada corretamente
@param cNumOsv, characters, description
@param cTipTem, characters, description
@param cLibVOO, characters, description
@param nValPecGar, numeric, description
@param nValSerGar, numeric, description
@param cCodMar, characters, description
@type function
/*/
Function OFNJD15019_ValidaTTGarantia(cNumOsv, cTipTem, cLibVOO, nValPecGar, nValSerGar, cCodMar)
	Local lRetorno := .t.
	Local cFormul := ""
	Local cFunExp := ""

	VO1->(dbSetOrder(1))
	VO1->(MsSeek(xFilial("VO1") + cNumOsv ))

	cCodMarVV1 := FMX_RETMAR("JD ") + "/" + FMX_RETMAR("GRS") + "/" + FMX_RETMAR("PLA") + "/" + FMX_RETMAR("JDC") + "/" + FMX_RETMAR("HCM")

	cFormul := FMX_FEXPGA("",cTipTem,cCodMarVV1)
	If Empty(cFormul)
		Return .t.
	EndIf
	cFunExp := OFNJD15020_Formula( cFormul , 'VF' , cTipTem , cLibVOO , "{ '" + cCodMar + "' , " + Str(nValPecGar,10,2) + "," + Str(nValSerGar,10,2) + "}" )
		
	lRetorno := FG_VERFORGAR(cFunExp)

Return lRetorno


/*/{Protheus.doc} OFNJD15020_Formula
Retorna a Formula para validar os valores ao final do processamento da atualizacao da Ordem de Servico

@author rubens.takahashi
@since 26/12/2019
@version 1.0
@return cFuncao, String com a formula e parametros para ser executado por Macro
@param cFuncao, characters, description
@param cParFunc, characters, description
@param cTipTem, characters, description
@param cLibVOO, characters, description
@param cArrParFunc, characters, description
@type function
/*/
Static Function OFNJD15020_Formula( cFuncao , cParFunc , cTipTem , cLibVOO , cArrParFunc )

	Local nIni

	Default cArrParFunc := ""

	cFuncao := AllTrim(cFuncao)
	nIni := At("(",cFuncao)
	If nIni <> 0
		cFuncao := Left(cFuncao,nIni-1)
	EndIf

	cFuncao += "('" + cParFunc + "','" + cTipTem + "','" + cLibVOO + "'," + IIF( !Empty(cArrParFunc) , "," + cArrParFunc , "" ) + " )"

Return cFuncao


Function OFNJD15LTOK()
	Local oOkta := OFJDOkta():New()

	oOkta := OFJDOkta():New()
	if oOkta:oConfig:warranty()
		oOkta:SetWarranty()
		oOkta:cleanProfile()
		MsgInfo(STR0231) // "Token removido."
	Else
		MsgInfo(STR0232) // "Sistema n„o est· configurado para utilizar a autenticaÁ„o via Okta."
	endif
Return

/*/{Protheus.doc} OFNJD15021_addAColsPeca
Adiciona uma linha na aCols de Peca

@author rubens.takahashi
@since 01/06/2020
@version 1.0

@param aPAColsPeca, array, Array da aCols de Peca
@param nPosVMCPeca, numeric, Posicao da array aVMCPeca
@type function
/*/
Static Function OFNJD15021_addAColsPeca(aPAColsPeca, nPosVMCPeca)
	Local nCont2
	Local nAuxPos

	AADD(aPAColsPeca,Array(Len(aHPeca)+1))
	nAuxPos := Len(aPAColsPeca)
	For nCont2 := 1 to Len(aHPeca)
		wVar  := "M->"+aHPeca[nCont2,2]
		aPAColsPeca[nAuxPos,nCont2] := &wVar
	Next nCont
	aPAColsPeca[nAuxPos,FG_POSVAR("PEC_TIPTEM","aHPeca")] := M->PEC_TIPTEM
	aPAColsPeca[nAuxPos,FG_POSVAR("PEC_GRUITE","aHPeca")] := aVMCPeca[ nPosVMCPeca, _VMC_PECA_GRUITE_ ]
	aPAColsPeca[nAuxPos,FG_POSVAR("PEC_CODITE","aHPeca")] := aVMCPeca[ nPosVMCPeca, _VMC_PECA_CODITE_ ]
	aPAColsPeca[nAuxPos,Len(aCols[1])] := .f.

Return nAuxPos

/*/{Protheus.doc} OFNJD15022_checkConfigEstoque
Verifica configuracao de Estoque do TES informado

@author rubens.takahashi
@since 01/06/2020
@version 1.0

@param cMovEstq, characters, description
@param cStatLinha, characters, description

@type function
/*/
Static Function OFNJD15022_checkConfigEstoque(cMovEstq, cStatLinha)
	If cMovEstq == "N"
		cStatLinha := Upper(FWNoAccent(cStatLinha))
		Do Case
		Case cStatLinha == Upper(FWNoAccent(STR0210 + " (100%)")) // // "MATRIZ REEMBOLSO(100%)"
			MsgInfo(STR0238 + CHR(13) + CHR(10) + STR0228, STR0111) // "PeÁa com matriz de reembolso de 100% e informado um TES que n„o movimenta estoque." // Verifique se o TES informado est· correto.
		Case cStatLinha == Upper(FWNoAccent(STR0211)) // "PECA NAO APROVADA"
			MsgInfo(STR0227 + CHR(13) + CHR(10) + STR0228, STR0111) // "PeÁa n„o foi aprovada pela f·brica e informado um TES que n„o movimenta estoque." // Verifique se o TES informado est· correto.
		Case cStatLinha == Upper(FWNoAccent(STR0212)) // "PECA ACRESCENTADA"
			MsgInfo(STR0229 + CHR(13) + CHR(10) + STR0228, STR0111) // PeÁa adicionada pela f·brica e informado um TES que n„o movimenta estoque. // Verifique se o TES informado est· correto.
		EndCase
	EndIf
Return .t.
/*/{Protheus.doc} OFNJD15023_CallDTF
CI 010616
FunÁ„o que faz a chamada da rotina de importaÁ„o dos arquivos Warrmemo via API DTF.

@author Jose Silveira
@since 29/09/2021
@version 1.0

@param cTTEsp, characters, description

@type function
/*/

Function OFNJD15023_CallDTF()

Private oDTFConfig := OFJDDTFConfig():New()
Private oRetAPiG := OFJDDTF():New("GET")

oDTFConfig:GetConfig()

oRetAPiG:getDTFList_Service("_WARRMEMO_",oDTFConfig:getWarranty())

MsgInfo("ImportaÁ„o Concluida")

Return .t.

/*/{Protheus.doc} OFNJD15038_verOpPeca
CI 010646
FunÁ„o que verifica o tipo do tempo para retornar o tipo de operaÁ„o
conforme informado no PERGUNTE

@author matheus.silva
@since 20/04/2021
@version 1.0

@param cTTEsp, characters, description

@type function
/*/
Static Function OFNJD15038_verOpPeca(cTTEsp,cOperEsp,cOpEspInt)

	VOI->(DbSetOrder(1))
	If VOI->(msSeek(xFilial("VOI") + cTTEsp))

		Do case
		Case VOI->VOI_SITTPO == "3" .AND. !Empty(cOpEspInt)//Interno
			Return cOpEspInt
		Otherwise //Padr„o
			Return cOperEsp
		EndCase

	EndIf
Return cOperEsp

/*/{Protheus.doc} OFNJD15048_verTESPeca
CI 010646
FunÁ„o que verifica o tipo do tempo para retornar a TES
conforme informado no PERGUNTE

@author matheus.silva
@since 20/04/2021
@version 1.0

@param cTTEsp, characters, description

@type function
/*/
Static Function OFNJD15048_verTESPeca(cTTEsp,cTESEsp,cTESEspInt)

	VOI->(DbSetOrder(1))
	If VOI->(msSeek(xFilial("VOI") + cTTEsp))

		Do case
		Case VOI->VOI_SITTPO == "3" .AND. !Empty(cTESEspInt)//Interno
			Return cTESEspInt
		Otherwise //Padr„o
			Return cTESEsp
		EndCase

	EndIf
Return cTESEsp

/*/{Protheus.doc} OFNJD15058_validPerg
Retorna se a base possui todas as perguntas OFINJD15 criadas
@author matheus.silva
@since 22/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OFNJD15058_validPerg()

	Local oObjSX1 := FWSX1Util():New()

	oObjSX1:AddGroup("OFINJD15")
	oObjSX1:SearchGroup()
	If Len(oObjSX1:GetGroup("OFINJD15")[2]) >= 43 //Tamanho atual
		Return .T.
	EndIf

Return .F.