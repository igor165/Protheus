#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "PLSA101.CH"

#define K_Ajuste 	6

STATIC aIndices := {}
STATIC lAjuste  := .F.
STATIC aFranquia:= {}
STATIC aCopart	:= {}
STATIC lArredonda := GetNewPar("MV_PLARRVL",.T.)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  ЁPLSA101  Ё Autor Ё Tulio Cesar          Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Reajuste de Precos de Venda e das Empresas e PF            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
/* Niveis do parametro de reajuste, por ordem de prioridade.
Subcontrato 	= 3
contrato 		= 2
Grupo empresa 	= 1
*/
Function PLSA101
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variavels da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := "Reajuste"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega matriz com arquivos para reajustar o valor da franquia...        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aFranquia, {"BHE",1,"BHE_FILIAL+BHE_CODINT+BHE_CODIGO+BHE_NUMCON+BHE_VERCON+BHE_SUBCON+BHE_VERSUB","BHE_LIMFRA",'1'}) //- OK
Aadd( aFranquia, {"BHF",1,"BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB","BHF_LIMFRA",'1'}) //- OK
Aadd( aFranquia, {"BLX",1,"BLX_FILIAL+BLX_CODINT+BLX_CODIGO+BLX_NUMCON+BLX_VERCON+BLX_SUBCON+BLX_VERSUB","BLX_LIMFRA",'1'}) //- OK
Aadd( aFranquia, {"BHG",1,"BHG_FILIAL+BHG_CODINT+BHG_CODIGO+BHG_NUMCON+BHG_VERCON+BHG_SUBCON+BHG_VERSUB","BHG_LIMFRA",'1'}) //- OK
Aadd( aFranquia, {"BGS",1,"BGS_FILIAL+BGS_CODINT+BGS_CODIGO+BGS_NUMCON+BGS_VERCON+BGS_SUBCON+BGS_VERSUB","BGS_LIMFRA",'1'}) //- OK
Aadd( aFranquia, {"BLW",1,"BLW_FILIAL+BLW_CODINT+BLW_CODIGO+BLW_NUMCON+BLW_VERCON+BLW_SUBCON+BLW_VERSUB","BLW_LIMFRA",'1'}) //- OK
Aadd( aFranquia, {"BGL",1,"BGL_FILIAL+BGL_CODINT+BGL_CODIGO+BGL_NUMCON+BGL_VERCON+BGL_SUBCON+BGL_VERSUB","BGL_LIMFRA",'1'}) //- OK

// Familias...
Aadd( aFranquia, {"BVC",1,"BVC_FILIAL+BVC_CODINT+BVC_CODEMP+BVC_MATRIC","BVC_LIMFRA",'2'}) //- OK
Aadd( aFranquia, {"BVF",1,"BVF_FILIAL+BVF_CODINT+BVF_CODEMP+BVF_MATRIC","BVF_LIMFRA",'2'}) //- OK

// Usuarios...
Aadd( aFranquia, {"BVJ",1,"BVJ_FILIAL+BVJ_CODINT+BVJ_CODEMP+BVJ_MATRIC+BVJ_TIPREG","BVJ_LIMFRA",'3'}) //- OK
Aadd( aFranquia, {"BVM",1,"BVM_FILIAL+BVM_CODINT+BVM_CODEMP+BVM_MATRIC+BVM_TIPREG","BVM_LIMFRA",'3'}) //- OK

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega matriz com arquivos para reajustar o valor de copart...          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If CheckCampCopart({'BHG_VLRCOP','BHG_PERCOP','BHG_VIGINI','BHG_VIGFIN','BHG_CODREA','BHG_REAVIG','BHG_CODINT'})
	Aadd( aCopart, {"BHG",1,"BHG_FILIAL+BHG_CODINT+BHG_CODIGO+BHG_NUMCON+BHG_VERCON+BHG_SUBCON+BHG_VERSUB",'1','BHG_VLRCOP','BHG_PERCOP','BHG_VIGINI','BHG_VIGFIN','BHG_CODREA','BHG_REAVIG','BHG_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BHE_VLRCOP','BHE_PERCOP','BHE_VIGINI','BHE_VIGFIN','BHE_CODREA','BHE_REAVIG','BHE_CODINT'})
	Aadd( aCopart, {"BHE",1,"BHE_FILIAL+BHE_CODINT+BHE_CODIGO+BHE_NUMCON+BHE_VERCON+BHE_SUBCON+BHE_VERSUB",'1','BHE_VLRCOP','BHE_PERCOP','BHE_VIGINI','BHE_VIGFIN','BHE_CODREA','BHE_REAVIG','BHE_CODINT'}) //- OK
EndIf	

If CheckCampCopart({'BHF_VALCOP','BHF_PERCOP','BHF_VIGINI','BHF_VIGFIN','BHF_CODREA','BHF_REAVIG','BHF_CODINT'})
	Aadd( aCopart, {"BHF",1,"BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB",'1','BHF_VALCOP','BHF_PERCOP','BHF_VIGINI','BHF_VIGFIN','BHF_CODREA','BHF_REAVIG','BHF_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BLX_VLRCOP','BLX_PERCOP','BLX_VIGINI','BLX_VIGFIN','BLX_CODREA','BLX_REAVIG','BLX_CODINT'})
	Aadd( aCopart, {"BLX",1,"BLX_FILIAL+BLX_CODINT+BLX_CODIGO+BLX_NUMCON+BLX_VERCON+BLX_SUBCON+BLX_VERSUB",'1','BLX_VLRCOP','BLX_PERCOP','BLX_VIGINI','BLX_VIGFIN','BLX_CODREA','BLX_REAVIG','BLX_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BLW_VLRCOP','BLW_PERCOP','BLW_VIGINI','BLW_VIGFIN','BLW_CODREA','BLW_REAVIG','BLW_CODINT'})
	Aadd( aCopart, {"BLW",1,"BLW_FILIAL+BLW_CODINT+BLW_CODIGO+BLW_NUMCON+BLW_VERCON+BLW_SUBCON+BLW_VERSUB",'1','BLW_VLRCOP','BLW_PERCOP','BLW_VIGINI','BLW_VIGFIN','BLW_CODREA','BLW_REAVIG','BLW_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BGS_VLRCOP','BGS_PERCOP','BGS_VIGINI','BGS_VIGFIN','BGS_CODREA','BGS_REAVIG','BGS_CODINT'})
	Aadd( aCopart, {"BGS",1,"BGS_FILIAL+BGS_CODINT+BGS_CODIGO+BGS_NUMCON+BGS_VERCON+BGS_SUBCON+BGS_VERSUB",'1','BGS_VLRCOP','BGS_PERCOP','BGS_VIGINI','BGS_VIGFIN','BGS_CODREA','BGS_REAVIG','BGS_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BGL_VALCOP','BGL_PERCOP','BGL_VIGINI','BGL_VIGFIN','BGL_CODREA','BGL_REAVIG','BGL_CODINT'})
	Aadd( aCopart, {"BGL",1,"BGL_FILIAL+BGL_CODINT+BGL_CODIGO+BGL_NUMCON+BGL_VERCON+BGL_SUBCON+BGL_VERSUB",'1','BGL_VALCOP','BGL_PERCOP','BGL_VIGINI','BGL_VIGFIN','BGL_CODREA','BGL_REAVIG','BGL_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BOR_VALCOP','BOR_PERCOP','BOR_VIGDE' ,'BOR_VIGATE','BOR_CODREA','BOR_REAVIG','BOR_CODINT'})
	Aadd( aCopart, {"BOR",1,"BOR_FILIAL+BOR_CODINT+BOR_CODEMP+BOR_NUMCON+BOR_VERCON+BOR_SUBCON+BOR_VERSUB",'1','BOR_VALCOP','BOR_PERCOP','BOR_VIGDE' ,'BOR_VIGATE','BOR_CODREA','BOR_REAVIG','BOR_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BS9_VALCOP','BS9_PERCOP','BS9_VIGDE' ,'BS9_VIGATE','BS9_CODREA','BS9_REAVIG','BS9_SUBCON'})
	Aadd( aCopart, {"BS9",1,"BS9_FILIAL+BS9_SUBCON"                                                       ,'1','BS9_VALCOP','BS9_PERCOP','BS9_VIGDE' ,'BS9_VIGATE','BS9_CODREA','BS9_REAVIG','SUBSTRING(BS9_SUBCON,1,4)'}) //- OK
EndIf

If CheckCampCopart({'BNZ_VLRCOP','BNZ_PERCOP','BNZ_VIGINI','BNZ_VIGFIN','BNZ_CODREA','BNZ_REAVIG','BNZ_SUBCON'})
	Aadd( aCopart, {"BNZ",1,"BNZ_FILIAL+BNZ_SUBCON"                                                       ,'1','BNZ_VLRCOP','BNZ_PERCOP','BNZ_VIGINI','BNZ_VIGFIN','BNZ_CODREA','BNZ_REAVIG','SUBSTRING(BNZ_SUBCON,1,4)'}) //- OK
EndIf
//BNX - CabeГalho BNZ
// PLSA038BS9() //Valid do BS9_CODUNI

// Familias...
If CheckCampCopart({'BVC_VALCOP','BVC_PERCOP','BVC_VIGINI','BVC_VIGFIN','BVC_CODREA','BVC_REAVIG','BVC_CODINT'})
	Aadd( aCopart, {"BVC",1,"BVC_FILIAL+BVC_CODINT+BVC_CODEMP+BVC_MATRIC",'2','BVC_VALCOP','BVC_PERCOP','BVC_VIGINI','BVC_VIGFIN','BVC_CODREA','BVC_REAVIG','BVC_CODINT'}) //- OK
EndIf	

If CheckCampCopart({'BVF_VALCOP','BVF_PERCOP','BVF_VIGINI','BVF_VIGFIN','BVF_CODREA','BVF_REAVIG','BVF_CODINT'})	
	Aadd( aCopart, {"BVF",1,"BVF_FILIAL+BVF_CODINT+BVF_CODEMP+BVF_MATRIC",'2','BVF_VALCOP','BVF_PERCOP','BVF_VIGINI','BVF_VIGFIN','BVF_CODREA','BVF_REAVIG','BVF_CODINT'}) //- OK
EndIf
// Usuarios...
If CheckCampCopart({'BVJ_VALCOP','BVJ_PERCOP','BVJ_VIGDE','BVJ_VIGATE','BVJ_CODREA','BVJ_REAVIG','BVJ_CODINT'})	
	Aadd( aCopart, {"BVJ",1,"BVJ_FILIAL+BVJ_CODINT+BVJ_CODEMP+BVJ_MATRIC+BVJ_TIPREG",'3','BVJ_VALCOP','BVJ_PERCOP','BVJ_VIGDE','BVJ_VIGATE','BVJ_CODREA','BVJ_REAVIG','BVJ_CODINT'}) //- OK
EndIf

If CheckCampCopart({'BVM_VALCOP','BVM_PERCOP','BVM_VIGDE','BVM_VIGATE','BVM_CODREA','BVM_REAVIG','BVM_CODINT'})
	Aadd( aCopart, {"BVM",1,"BVM_FILIAL+BVM_CODINT+BVM_CODEMP+BVM_MATRIC+BVM_TIPREG",'3','BVM_VALCOP','BVM_PERCOP','BVM_VIGDE','BVM_VIGATE','BVM_CODREA','BVM_REAVIG','BVM_CODINT'}) //- OK
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define browse...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BHW->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BHW"))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101MOV Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Reajuste de Precos de Venda e das Empresas e PF            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA101MOV(cAlias,nReg,nOpc)
Local I__f := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cCadastro := Iif(!lAjuste, "Reajuste", "Ajuste")
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := {|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) .And. ConfExcLote(nOpc, lAjuste),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel   := {|| oDlg:End() }
LOCAL oEnchoice
LOCAL aButtons  := {}
LOCAL aRet
LOCAL aErrosGrp
LOCAL aGrupos
LOCAL aContratos
LOCAL aSubCon
LOCAL aFamilias
LOCAL aErrosFam
LOCAL aErrosSub
LOCAL aUsuarios
LOCAL aErrosUsr
LOCAL lRetOK
LOCAL nOpcGD
LOCAL oFolder
LOCAL oSubFld
LOCAL oTree
LOCAL oSay
LOCAL oBmp
LOCAL cQuebPro
LOCAL cAnoMesInd := ""
LOCAL lFlag      := .T.
LOCAL lDataOpc   := .F.
LOCAL cDeEmpresa := ""
LOCAL cAteEmpresa := ""

LOCAL aDadosBPB := {}
LOCAL aCabBPB   := {}
LOCAL aTrbBPB   := {}

LOCAL aDadosBPV := {}
LOCAL aCabBPV   := {}
LOCAL aTrbBPV   := {}
LOCAL oBrwBPV

LOCAL aDadosBPC := {}
LOCAL aCabBPC   := {}
LOCAL aTrbBPC   := {}
LOCAL oBrwBPC

LOCAL aDadosBYD := {}
LOCAL aCabBYD   := {}
LOCAL aTrbBYD   := {}
LOCAL oBrwBYD

LOCAL cFaixa
LOCAL cValor1
LOCAL cValor2
LOCAL cIndice
LOCAL nQtdArv := 0
LOCAL cCodInt := ''
LOCAL cCodRea := ''
LOCAL cCodAjs := ''
LOCAL aErrosCreTmp := {}  // RDS

LOCAL cChaverea
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё No mbrowse do ajuste nao tem a opcao alterar... entao forco a troca para Ё
//| a opcao de Excluir														 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAjuste .and. nOpc == K_Alterar
	nOpc := 5
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Consiste ajustes...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSALIASEX("BHV")
	If nOpc == K_Excluir
		If !lAjuste
			BHV->( dbSetorder(01) )
			If BHV->( dbSeek(xFilial("BHV")+BHW->(BHW_CODINT+BHW_CODREA)) )
				Aviso("Ajustes","Este lote de reajuste possui ajustes lancados. Primeiro exclua todos os ajustes.",{"Sair"})
				Return(.F.)
			Endif
		Endif
	Endif
Endif

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 200, .T., .T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )


aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dados da enchoice...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Incluir
	RegToMemory( cAlias, .T., .F. )
Else
	RegToMemory( cAlias, .F., .F. )
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Enchoice....                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If     nOpc == K_Alterar
	nOpcGD := K_Visualizar
Else
	nOpcGD := nOpc
Endif
If nOpc == K_Incluir
	oEnchoice := MSMGet():New(calias,BHW->(Recno()),nOpcGD,,,,nil,aPosObj[1],nil,,,,,oDlg,,,.F.)
Else
	oEnchoice := MSMGet():New(calias,BHW->(Recno()),nOpcGD,,,,nil,aPosObj[1],nil,,,,,oDlg,,,.F.)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define folder...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc <> K_Incluir
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS	"Resumo do Reajuste","Criticas"
	If PLSALIASEX("BHO")
		@ 005,003 FOLDER oSubFld SIZE aPosObj[2][3]-15,aPosObj[2][4]-20 OF oFolder:aDialogs[2] PIXEL	PROMPTS	"Grupo Empresa","SubContrato","Familia","Usuarios"
	Else
		@ 005,003 FOLDER oSubFld SIZE aPosObj[2][3]-15,aPosObj[2][4]-20 OF oFolder:aDialogs[2] PIXEL	PROMPTS	"Grupo Empresa","SubContrato","Familia"
	Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for visualizacao exibe tree com os dados...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc <> K_Incluir
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define legendas...                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ 003,006 BITMAP oBmp RESNAME "BR_VERDE"   OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 003,016 Say oSay PROMPT "Grupos Empresas" SIZE 100,010 OF oFolder:aDialogs[1] PIXEL
	
	@ 003,070 BITMAP oBmp RESNAME "BR_AMARELO"   OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 003,080 Say oSay PROMPT "Contratos" SIZE 100,010 OF oFolder:aDialogs[1] PIXEL
	
	@ 003,115 BITMAP oBmp RESNAME "BR_AZUL"   OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 003,125 Say oSay PROMPT "Subcontratos" SIZE 100,010 OF oFolder:aDialogs[1] PIXEL
	
	@ 003,170 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 003,180 Say oSay PROMPT "Familias" SIZE 100,010 OF oFolder:aDialogs[1] PIXEL
	
	@ 003,225 BITMAP oBmp RESNAME "BR_LARANJA"   OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 003,235 Say oSay PROMPT "Usuarios" SIZE 100,010 OF oFolder:aDialogs[1] PIXEL
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define o objeto arvore...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oTree := DbTree():New(015,005,aPosObj[2][4]-15,aPosObj[2][3]-15,oFolder:aDialogs[1],nil,nil,.T.,nil)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da leitura de todos os grupos empresas...                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BPD->(DbSetOrder(1))
	If BPD->(DbSeek(xFilial("BPD")+BHW->(BHW_CODINT+BHW_CODREA)))
		While ! BPD->(Eof()) .And. BPD->(BPD_FILIAL+BPD_OPEREA+BPD_CODREA) == xFilial("BPD")+BHW->(BHW_CODINT+BHW_CODREA) .And. lFlag
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
			//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If PLSALIASEX("BHV")
				If BPD->( FieldPos("BPD_CODAJS") ) > 0
					If (lAjuste .and. BPD->BPD_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BPD->BPD_CODAJS))
						BPD->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define a arvore do grupo empresa...                                      Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oTree:AddTree(BPD->BPD_CODEMP+" - "+AllTrim(BPD->BPD_DESEMP)+" ("+AllTrim(str(BPD->BPD_NFAM))+" Familia(s) )"+Space(100),.T.,"BR_VERDE","BR_VERDE","BR_VERDE","BR_VERDE","GRP"+BPD->BPD_CODEMP)
			nQtdArv ++
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Para cada grupo empresa le contratos e subcontratos (PF)...              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BPD->BPD_TIPO == "2"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Arvore para cada contrato...                                             Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BPE->(DbSetOrder(1))
				If BPE->(DbSeek(xFilial("BPE")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_CODEMP)))
					While ! BPE->(Eof()) .And. BPE->(BPE_FILIAL+BPE_OPEREA+BPE_CODREA+BPE_CODEMP) == ;
						xFilial("BPE")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_CODEMP) .And. lFlag
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
						//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If PLSALIASEX("BHV")
							If BPE->( FieldPos("BPE_CODAJS") ) > 0
								If (lAjuste .and. BPE->BPE_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BPE->BPE_CODAJS))
									BPE->( dbSkip() )
									Loop
								Endif
							Endif
						Endif
						
						oTree:AddTree(TransForm(BPE->(BPE_CONEMP+BPE_VERCON),"@R !!!!!!!!!!!!-!!!")+ " ("+AllTrim(str(BPE->BPE_NFAM))+" Familia(s) )"+Space(100) ,.T.,"BR_AMARELO","BR_AMARELO","BR_AMARELO","BR_AMARELO","CON"+BPE->(BPE_CONEMP+BPE_VERCON))
						nQtdArv ++
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Arvore para cada subcontrato...                                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BPF->(DbSetOrder(1))
						If BPF->(DbSeek(xFilial("BPF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)))
							While ! BPF->(Eof()) .And. BPF->(BPF_FILIAL+BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON) == ;
								xFilial("BPF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON) .And. lFlag
								
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
								//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If PLSALIASEX("BHV")
									If BPF->( FieldPos("BPF_CODAJS") ) > 0
										If (lAjuste .and. BPF->BPF_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BPF->BPF_CODAJS))
											BPF->( dbSkip() )
											Loop
										Endif
									Endif
								Endif
								
								oTree:AddTree(TransForm(BPF->(BPF_SUBCON+BPF_VERSUB),"@R !!!!!!!!!-!!!")+ " ("+AllTrim(str(BPF->BPF_NFAM))+" Familia(s) )"+Space(100) ,.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+BPF->(BPF_SUBCON+BPF_VERSUB))
								nQtdArv ++
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Arvore para subcontrato x produto x valores...                           Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BYC->(DbSetOrder(2))
								If BYC->(DbSeek(xFilial("BYC")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB))))
									While ! BYC->(Eof()) .And. BYC->(BYC_FILIAL+BYC_OPEREA+BYC_CODREA+BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB) == ;
										xFilial("BYC")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB) .And. lFlag
										
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
										//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If PLSALIASEX("BHV")
											If BYC->( FieldPos("BYC_CODAJS") ) > 0
												If (lAjuste .and. BYC->BYC_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYC->BYC_CODAJS))
													BYC->( dbSkip() )
													Loop
												Endif
											Endif
										Endif
										
										BI3->(DbSetOrder(1))
										If BI3->(DbSeek(xFilial("BI3")+BYC->(BYC_CODOPE+BYC_CODPRO+BYC_VERPRO)))
											cQuebPro := BYC->(BYC_CODPRO+BYC_VERPRO)
											oTree:AddTree("Produto "+BI3->BI3_CODIGO+" - "+AllTrim(BI3->BI3_DESCRI)+Space(100) ,.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+cQuebPro)
											nQtdArv ++
											
											While ! BYC->(Eof()) .And. BYC->(BYC_FILIAL+BYC_OPEREA+BYC_CODREA+BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB+BYC_CODPRO+BYC_VERPRO) == ;
												xFilial("BYC")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro .And. lFlag
												
												//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
												//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
												//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
												//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
												If PLSALIASEX("BHV")
													If BYC->( FieldPos("BYC_CODAJS") ) > 0
														If (lAjuste .and. BYC->BYC_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYC->BYC_CODAJS))
															BYC->( dbSkip() )
															Loop
														Endif
													Endif
												Endif
												
												cFaixa  := "Faixa Etaria "+AllTrim(Str(BYC->BYC_IDAINI))+" a "+AllTrim(Str(BYC->BYC_IDAFIN))+" anos"
												cValor1 := "Valor Antigo "+AllTrim(Str(BYC->BYC_VLRANT,17,2))
												cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYC->BYC_VLRREA,17,2))
												cIndice := "Indice Aplicado "+AllTrim(Str(BYC->BYC_PERREA,17,4))
												
												oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												
												oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:EndTree()
												
												BYC->(DbSkip())
												SaiRotina(nQtdArv,@lFlag)
											Enddo
											oTree:EndTree()
										Else
											BYC->( dbSkip() )
										Endif
										SaiRotina(nQtdArv,@lFlag)
									Enddo
								Endif
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Arvore para subcontrato x produto x valores... (Salarial)                Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BPR->(DbSetOrder(1))//BPR_FILIAL+BPR_OPEREA+BPR_CODREA+BPR_CODEMP+BPR_CONEMP+BPR_VERCON+BPR_SUBCON+BPR_VERSUB
								If BPR->(DbSeek(xFilial("BPR")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB))))
									While ! BPR->(Eof()) .And. BPR->(BPR_FILIAL+BPR_OPEREA+BPR_CODREA+BPR_OPEREA+BPR_CODEMP+BPR_CONEMP+BPR_VERCON+BPR_SUBCON+BPR_VERSUB) == ;
										xFilial("BPR")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB) .And. lFlag
										
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
										//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If PLSALIASEX("BHV")
											If BPR->( FieldPos("BPR_CODAJS") ) > 0
												If (lAjuste .and. BPR->BPR_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BPR->BPR_CODAJS))
													BPR->( dbSkip() )
													Loop
												Endif
											Endif
										Endif
										
										BI3->(DbSetOrder(1))
										If BI3->(DbSeek(xFilial("BI3")+BPR->(BPR_OPEREA+BPR_CODPRO+BPR_VERSAO)))
											cQuebPro := BPR->(BPR_CODPRO+BPR_VERSAO)
											oTree:AddTree("Produto "+BI3->BI3_CODIGO+" - "+AllTrim(BI3->BI3_DESCRI)+Space(100) ,.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+cQuebPro)
											nQtdArv ++
											
											While ! BPR->(Eof()) .And. BPR->(BPR_FILIAL+BPR_OPEREA+BPR_CODREA+BPR_OPEREA+BPR_CODEMP+BPR_CONEMP+BPR_VERCON+BPR_SUBCON+BPR_VERSUB+BPR_CODPRO+BPR_VERSAO) == ;
												xFilial("BPR")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro .And. lFlag
												
												//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
												//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
												//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
												//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
												If PLSALIASEX("BHV")
													If BPR->( FieldPos("BPR_CODAJS") ) > 0
														If (lAjuste .and. BPR->BPR_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BPR->BPR_CODAJS))
															BPR->( dbSkip() )
															Loop
														Endif
													Endif
												Endif
												
												cFaixa  := "Faixa Salarial "+AllTrim(Str(BPR->BPR_VLSLIN))+" a "+AllTrim(Str(BPR->BPR_VLSLFN))+" reais"
												cValor1 := "Valor Antigo "+AllTrim(Str(BPR->BPR_VLRANT,17,2))
												cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BPR->BPR_VALOR,17,2))
												cIndice := "Indice Aplicado "+AllTrim(Str(BPR->BPR_PERREA,17,4))
												
												oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												
												oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:EndTree()
												
												BPR->(DbSkip())
												SaiRotina(nQtdArv,@lFlag)
											Enddo
											oTree:EndTree()
										Else
											BPR->( dbSkip() )
										Endif
										SaiRotina(nQtdArv,@lFlag)
									Enddo
								Endif
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Arvore para subcontrato x produto x adesoes...                           Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BYE->(DbSetOrder(2))
								If BYE->(DbSeek(xFilial("BYE")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB))))
									While ! BYE->(Eof()) .And. BYE->(BYE_FILIAL+BYE_OPEREA+BYE_CODREA+BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB) == ;
										xFilial("BYE")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB) .And. lFlag
										
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
										//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If PLSALIASEX("BHV")
											If BYE->( FieldPos("BYE_CODAJS") ) > 0
												If (lAjuste .and. BYE->BYE_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYE->BYE_CODAJS))
													BYE->( dbSkip() )
													Loop
												Endif
											Endif
										Endif
										
										cQuebPro := BYE->(BYE_CODPRO+BYE_VERPRO)
										oTree:AddTree("Valores Taxa Adesao"+Space(100) ,.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+cQuebPro)
										nQtdArv ++
										
										While ! BYE->(Eof()) .And. BYE->(BYE_FILIAL+BYE_OPEREA+BYE_CODREA+BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB+BYE_CODPRO+BYE_VERPRO) == ;
											xFilial("BYE")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro .And. lFlag
											
											//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
											//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
											//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
											//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
											If PLSALIASEX("BHV")
												If BYE->( FieldPos("BYE_CODAJS") ) > 0
													If (lAjuste .and. BYE->BYE_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYE->BYE_CODAJS))
														BYE->( dbSkip() )
														Loop
													Endif
												Endif
											Endif
											
											cFaixa  := "Faixa Etaria "+AllTrim(Str(BYE->BYE_IDAINI))+" a "+AllTrim(Str(BYE->BYE_IDAFIN))+" anos"
											cValor1 := "Valor Antigo "+AllTrim(Str(BYE->BYE_VLRANT,17,2))
											cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYE->BYE_VLRREA,17,2))
											cIndice := "Indice Aplicado "+AllTrim(Str(BYE->BYE_PERREA,17,4))
											
											oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
											nQtdArv ++
											
											oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
											nQtdArv ++
											oTree:EndTree()
											
											oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
											nQtdArv ++
											oTree:EndTree()
											
											oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
											nQtdArv ++
											oTree:EndTree()
											
											oTree:EndTree()
											
											BYE->(DbSkip())
											SaiRotina(nQtdArv,@lFlag)
										Enddo
										oTree:EndTree()
										SaiRotina(nQtdArv,@lFlag)
									Enddo
								Endif
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Arvore para subcontrato x produto x opcionais x valores...               Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BYF->(DbSetOrder(2))
								If BYF->(DbSeek(xFilial("BYF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON+BPF->(BPF_SUBCON+BPF_VERSUB))))
									While ! BYF->(Eof()) .And. BYF->(BYF_FILIAL+BYF_OPEREA+BYF_CODREA+BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB) == ;
										xFilial("BYF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB) .And. lFlag
										
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
										//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If PLSALIASEX("BHV")
											If BYF->( FieldPos("BYF_CODAJS") ) > 0
												If (lAjuste .and. BYF->BYF_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYF->BYF_CODAJS))
													BYF->( dbSkip() )
													Loop
												Endif
											Endif
										Endif
										
										BI3->(DbSetOrder(1))
										If BI3->(DbSeek(xFilial("BI3")+BYF->(BYF_CODOPE+BYF_CODOPC+BYF_VEROPC)))
											cQuebPro := BYF->(BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC)
											oTree:AddTree("Opcional "+BI3->BI3_CODIGO+" - "+AllTrim(BI3->BI3_DESCRI)+Space(100) ,.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+cQuebPro)
											nQtdArv ++
											
											While ! BYF->(Eof()) .And. BYF->(BYF_FILIAL+BYF_OPEREA+BYF_CODREA+BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB+BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC) == ;
												xFilial("BYF")+BPE->(BPE_OPEREA+BPE_CODREA+BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)+BPF->(BPF_SUBCON+BPF_VERSUB)+cQuebPro .And. lFlag
												
												//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
												//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
												//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
												//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
												If PLSALIASEX("BHV")
													If BYF->( FieldPos("BYF_CODAJS") ) > 0
														If (lAjuste .and. BYF->BYF_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYF->BYF_CODAJS))
															BYF->( dbSkip() )
															Loop
														Endif
													Endif
												Endif
												
												cFaixa  := "Faixa Etaria "+AllTrim(Str(BYF->BYF_IDAINI))+" a "+AllTrim(Str(BYF->BYF_IDAFIN))+" anos"
												cValor1 := "Valor Antigo "+AllTrim(Str(BYF->BYF_VLRANT,17,2))
												cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYF->BYF_VLRREA,17,2))
												cIndice := "Indice Aplicado "+AllTrim(Str(BYF->BYF_PERREA,17,4))
												
												oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												
												oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR")
												nQtdArv ++
												oTree:EndTree()
												
												oTree:EndTree()
												
												BYF->(DbSkip())
												SaiRotina(nQtdArv,@lFlag)
											Enddo
											oTree:EndTree()
										Endif
										SaiRotina(nQtdArv,@lFlag)
									Enddo
								Endif
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Arvore para cada familia processada...                                   Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BHL->(DbSetOrder(2))
								If BHL->(DbSeek(xFilial("BHL")+BPF->(BPF_OPEREA+BPF_CODREA+BPF_OPEREA+BPF_CONEMP+BPF_VERCON+;
									BPF_SUBCON+BPF_VERSUB)))
									While ! BHL->(Eof()) .And. BHL->(BHL_FILIAL+BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CONEMP+BHL_VERCON+BHL_SUBCON+BHL_VERSUB) == ;
										xFilial("BHL")+BPF->(BPF_OPEREA+BPF_CODREA+BPF_OPEREA+BPF_CONEMP+BPF_VERCON+;
										BPF_SUBCON+BPF_VERSUB) .And. lFlag
										
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
										//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If PLSALIASEX("BHV")
											If BHL->( FieldPos("BHL_CODAJS") ) > 0
												If (lAjuste .and. BHL->BHL_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BHL->BHL_CODAJS))
													BHL->( dbSkip() )
													Loop
												Endif
											Endif
										Endif
										
										PLSA101MAU(oTree,@nQtdArv)
										BHL->(DbSkip())
										SaiRotina(nQtdArv,@lFlag)
									Enddo
								Endif
								oTree:EndTree()
								
								BPF->(DbSkip())
								SaiRotina(nQtdArv,@lFlag)
							Enddo
						Endif
						oTree:EndTree()
						
						BPE->(DbSkip())
						SaiRotina(nQtdArv,@lFlag)
					Enddo
				Endif
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Arvore para cada familia processada...                                   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BHL->(DbSetOrder(1))
				If BHL->(DbSeek(xFilial("BHL")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_OPEREA+BPD_CODEMP)))
					While ! BHL->(Eof()) .And. BHL->(BHL_FILIAL+BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP) == ;
						xFilial("BHL")+BPD->(BPD_OPEREA+BPD_CODREA+BPD_OPEREA+BPD_CODEMP)  .And. lFlag
						
						PLSA101MAU(oTree,@nQtdArv)
						BHL->(DbSkip())
						SaiRotina(nQtdArv,@lFlag)
					Enddo
				Endif
			Endif
			oTree:EndTree()
			BPD->(DbSkip())
			SaiRotina(nQtdArv,@lFlag)
		Enddo
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados dos erros das familias...                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Store Header "BPB" TO aCabBPB For .T.
	
	BPB->(DbSetOrder(1))
	If ! BPB->(DbSeek(xFilial("BPB")+BHW->(BHW_CODINT+BHW_CODREA)))
		Store COLS Blank "BPB" TO aDadosBPB FROM aCabBPB
	Else
		Store COLS "BPB" TO aDadosBPB FROM aCabBPB VETTRAB aTrbBPB While ;
		xFilial("BPB")+BHW->(BHW_CODINT+BHW_CODREA) == BPB->(BPB_FILIAL+BPB_OPEREA+BPB_CODREA)
	Endif
	oBrwBPB := TPLSBrw():New(003,003,aPosObj[2][3]-20,aPosObj[2][4]-30,nil  ,oSubFld:aDialogs[3],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBPB,aDadosBPB,.F.,"BPB",K_Visualizar,"Criticas da Familia",nil,nil,nil,aTrbBPB)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados dos erros dos usuarios...                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If PLSALIASEX("BPV")
		Store Header "BPV" TO aCabBPV For .T.
		
		BPV->(DbSetOrder(1))
		If ! BPV->(DbSeek(xFilial("BPV")+BHW->(BHW_CODINT+BHW_CODREA)))
			Store COLS Blank "BPV" TO aDadosBPV FROM aCabBPV
		Else
			Store COLS "BPV" TO aDadosBPV FROM aCabBPV VETTRAB aTrbBPV While ;
			xFilial("BPV")+BHW->(BHW_CODINT+BHW_CODREA) == BPV->(BPV_FILIAL+BPV_OPEREA+BPV_CODREA)
		Endif
		oBrwBPV := TPLSBrw():New(003,003,aPosObj[2][3]-20,aPosObj[2][4]-30,nil  ,oSubFld:aDialogs[4],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBPV,aDadosBPV,.F.,"BPV",K_Visualizar,"Criticas do Usuario",nil,nil,nil,aTrbBPV)
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados dos erros dos grupos empresas                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Store Header "BPC" TO aCabBPC For .T.
	
	BPC->(DbSetOrder(1))
	If ! BPC->(DbSeek(xFilial("BPC")+BHW->(BHW_CODINT+BHW_CODREA)))
		Store COLS Blank "BPC" TO aDadosBPC FROM aCabBPC
	Else
		Store COLS "BPC" TO aDadosBPC FROM aCabBPC VETTRAB aTrbBPC While ;
		xFilial("BPC")+BHW->(BHW_CODINT+BHW_CODREA) == BPC->(BPC_FILIAL+BPC_OPEREA+BPC_CODREA)
	Endif
	oBrwBPC := TPLSBrw():New(003,003,aPosObj[2][3]-20,aPosObj[2][4]-30,nil  ,oSubFld:aDialogs[1],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBPC,aDadosBPC,.F.,"BPC",K_Visualizar,"Criticas do Grupo Empresa",nil,nil,nil,aTrbBPC,nil,nil,nil)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados dos erros dos subcontratos...                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Store Header "BYD" TO aCabBYD For .T.
	
	BYD->(DbSetOrder(1))
	If ! BYD->(DbSeek(xFilial("BYD")+BHW->(BHW_CODINT+BHW_CODREA)))
		Store COLS Blank "BYD" TO aDadosBYD FROM aCabBYD
	Else
		Store COLS "BYD" TO aDadosBYD FROM aCabBYD VETTRAB aTrbBYD While ;
		xFilial("BYD")+BHW->(BHW_CODINT+BHW_CODREA) == BYD->(BYD_FILIAL+BYD_OPEREA+BYD_CODREA)
	Endif
	oBrwBYD := TPLSBrw():New(003,003,aPosObj[2][3]-20,aPosObj[2][4]-30,nil  ,oSubFld:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBYD,aDadosBYD,.F.,"BYD",K_Visualizar,"Criticas do Grupo Empresa",nil,nil,nil,aTrbBYD,nil,nil,nil)
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Faz o tratamento...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Chama funcao generica que realiza o processamento...                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpc <> K_Visualizar
		If nOpc == K_Incluir
			If !lAjuste
				cAnoMesInd := IF(BHW->(FieldPos("BHW_AMIND"))>0,M->BHW_AMIND,"")
				Processa( {|| aRet := PLSA101Pro(M->BHW_CODINT,;
				M->BHW_ANOMES,;
				M->BHW_EMPDE,;
				M->BHW_EMPATE,;
				M->BHW_TIPOUS,;
				M->BHW_MSG01,;
				M->BHW_MSG02,;
				M->BHW_MSG03,;
				.T.,;
				cAnoMesInd) },;
				"Reajuste","Processando...",.T. )
				
			Else
				cAnoMesInd := IF(BHV->(FieldPos("BHV_AMIND"))>0,M->BHV_AMIND,"")
				Processa( {|| aRet := PLSA101Pro(M->BHV_CODINT,;
				M->BHV_ANOMES,;
				M->BHV_EMPDE,;
				M->BHV_EMPATE,;
				'2',;
				M->BHV_MSG01,;
				M->BHV_MSG02,;
				M->BHV_MSG03,;
				.T.,;
				cAnoMesInd) },;
				"Ajuste","Processando...",.T. )
			Endif
			
			aErrosGrp  	:= aRet[1]
			aGrupos    	:= aRet[2]
			aContratos 	:= aRet[3]
			aSubCon    	:= aRet[4]
			aFamilias  	:= aRet[5]
			aErrosFam  	:= aRet[6]
			aErrosSub  	:= aRet[7]
			aUsuarios  	:= aRet[8]
			aErrosUsr	:= aRet[9]
			lDataOpc    := aRet[10]
			
			lRetOK := PLSA101Sel(aErrosGrp,aGrupos,aContratos,aSubCon,;
			aFamilias,aErrosFam,aErrosSub,aUsuarios,aErrosUsr)[1]
			
			If lRetOK
				If !lAjuste
					Processa( {|| PLSA101ATU(M->BHW_CODINT,M->BHW_ANOMES,M->BHW_EMPDE,;
					M->BHW_EMPATE,M->BHW_TIPOUS,M->BHW_MSG01,;
					M->BHW_MSG02,M->BHW_MSG03,.T.,aErrosGrp,;
					aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,;
					aErrosSub,cAnoMesInd,aUsuarios,aErrosUsr,lDataOpc) },;
					"Reajuste","Aplicando Reajuste...",.T. )
				Else
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Desfaz o reajuste caso nЦo houver acumulo de acordo com o parametro abaixo.  Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !(GetNewPar("MV_PLACUAJ",.F.)) // Indica se haverА acumulo do reajuste quando efetuar um ajuste na rotina Reajuste Empresas (PLSA101)
						Processa( {|| PLSA101EXC(M->BHV_CODINT,M->BHV_CODREA,.T.,M->BHV_CODAJS,;
						aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,;
						aErrosSub,cAnoMesInd,aUsuarios,aErrosUsr,nOpc) },"Ajuste","Aplicando Ajuste...",.T. )
					EndIf
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Aplica o ajuste...                                                       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Processa( {|| PLSA101ATU(M->BHV_CODINT,M->BHV_ANOMES,M->BHV_EMPDE,;
					M->BHV_EMPATE,'2',M->BHV_MSG01,;
					M->BHV_MSG02,M->BHV_MSG03,.T.,aErrosGrp,;
					aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,;
					aErrosSub,cAnoMesInd,aUsuarios,aErrosUsr,lDataOpc) },;
					"Ajuste","Aplicando Ajuste...",.T. )
				Endif
			Endif
		Else
			If !lAjuste
				cCodInt := M->BHW_CODINT
				cCodRea := M->BHW_CODREA
				cCodAjs := ''
				cDeEmpresa := M->BHW_EMPDE
				cAteEmpresa := M->BHW_EMPATE
			Else
				cCodInt := M->BHV_CODINT
				cCodRea := M->BHV_CODREA
				cCodAjs := M->BHV_CODAJS
			Endif
			Processa( {|| PLSA101EXC(cCodInt, cCodRea,.T., cCodAjs, aErrosGrp, aGrupos, aContratos, aSubCon, aFamilias, aErrosFam,;
									 aErrosSub, cAnoMesInd, aUsuarios, aErrosUsr, nOpc, Nil, cDeEmpresa, cAteEmpresa)},;
									 "Reajuste","Aplicando Reajuste...", .T.)
		Endif
	Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

dbSelectArea("BHW")
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101PRO Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Processamento da rotina de reajuste PF e PJ...             Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA101Pro(cCodOpe,cAnoMes,cEmpDe,cEmpAte,cTipOus,;
cMsg01,cMsg02,cMsg03,lDisplay,cAnoMesInd,lautomato)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cSQL
LOCAL cTipoAna
LOCAL cConsTmp
LOCAL nIndice    := 0
LOCAL cIndice
LOCAL cAno       := Subs(cAnoMes,1,4)
LOCAL cMes       := Subs(cAnoMes,5,2)
LOCAL aFamilias  := {}
LOCAL aErrosGrp  := {}
LOCAL aErrosFam  := {}
LOCAL aErrosSub  := {}
LOCAL aGrupos    := {}
LOCAL aContratos := {}
LOCAL aSubCon    := {}
LOCAL aUsuarios  := {}
LOCAL aErrosUsr  := {}
LOCAL aRetUsr	 := {}
LOCAL cQuebCon
LOCAL cQuebSub
LOCAL lIndVld     := .F.
LOCAL lAbortPrint := .F.
LOCAL lProduto    := .F.
LOCAL lOpcional   := .F.
LOCAL lDataOpc    := .F.
LOCAL lTaxa       := .F.
LOCAL aRegGrp
LOCAL aRegCon
LOCAL dDatAnalise := ctod("01/"+subs(cAnoMesInd,5,2)+"/"+subs(cAnoMesInd,3,2))
LOCAL cCodPla     := ''
LOCAL cVerPla	  := ''
LOCAL nBgj
LOCAL nBh3
LOCAL nBya
LOCAL lOnlyLook	  := .F.
LOCAL cNivel 	  := ''
LOCAL lFranquia   := .F.
LOCAL niRea
LOCAL lZeraNiv1	  :=.F.
LOCAL lZeraNiv2	  :=.F.
LOCAL lZeraNiv3	  :=.F.
LOCAL nJ := 0
LOCAL cInCpFx     := ""
LOCAL nInCpFx     := 0.0
LOCAL cInCpPe     := ""
LOCAL nInCpPe     := 0.0

DEFAULT lautomato :=.F.

If lDisplay
	//SETA REGuA...
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Analisa dados da query...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BG9->(DbSetOrder(1))
BG9->(DbSeek(xFilial("BG9")))
While ! BG9->(Eof()) .And. BG9->BG9_FILIAL == xFilial("BG9")
	aTotUsr:={}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Testa cancelamento do processo...                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lautomato.and.Interrupcao(lAbortPrint)
		Exit
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Bypassa registros fora do filtro...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ! ( ( BG9->BG9_CODINT == cCodOpe ) .And. ;
		( BG9->BG9_CODIGO >= cEmpDe .And. BG9->BG9_CODIGO <= cEmpAte ) )
		BG9->(DbSkip())
		Loop
	Endif
	
	If ! ( cTipOus == "3" .Or. cTipOus == BG9->BG9_TIPO ) .AND. !( GetNewPar("MV_PLACUAJ",.F.) ) // Permite acumular reajuste em pessoa fМsica caso parametro for true.
		BG9->(DbSkip())
		Loop
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exibe mensagem de processamento...                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lDisplay
		IncProc("Analisando Grupo "+BG9->BG9_CODIGO+" ("+AllTrim(BG9->BG9_DESCRI)+")")
		ProcessMessage()
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Liga flag de controle para analisar o grupo empresa atual...             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lIndVld := .F.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Busca o indice para o grupo empresa...                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nBgj := 1 To 2
		cSQL := " SELECT BGJ_TIPOIN,BGJ_TIPO,BGJ_PERRRL,BGJ_INDRRL,BGJ_PROD,BGJ_OPC,BGJ_TAX "
		If BGJ->( FieldPos("BGJ_USRBLQ") ) > 0
			cSql += " ,BGJ_USRBLQ "
		Endif
		If BGJ->( FieldPos("BGJ_FRANQ") ) > 0
			cSql += " ,BGJ_FRANQ "
		Endif
		If BGJ->( FieldPos("BGJ_ZERAIN") ) > 0
			cSql += " ,BGJ_ZERAIN "
		Endif
		If BGJ->( FieldPos("BGJ_DATOPC") ) > 0
			cSql += " ,BGJ_DATOPC "
		Endif

		// EspecМfico Coparticipao /////////////
		If BGJ->( FieldPos("BGJ_IRCPFX") ) > 0
			cSql += " ,BGJ_IRCPFX "
		EndIf
		If BGJ->( FieldPos("BGJ_PRCPFX") ) > 0
			cSql += " ,BGJ_PRCPFX "
		EndIf
		If BGJ->( FieldPos("BGJ_IRCPPE") ) > 0
			cSql += " ,BGJ_IRCPPE "
		EndIf
		If BGJ->( FieldPos("BGJ_PRCPPE") ) > 0
			cSql += " ,BGJ_PRCPPE "
		EndIf
		////////////////////////////////////////
		
		cSQL += " FROM "+RetSQLName("BGJ")+" WHERE "
		cSQL += " BGJ_FILIAL = '"+xFilial("BGJ")+"' AND "
		cSQL += " BGJ_CODINT = '"+BG9->BG9_CODINT+"' AND "
		cSQL += " BGJ_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
		If nBgj == 1
			cSQL += " ( BGJ_ANO = '"+cAno+"' ) AND "
			cSQL += " ( BGJ_MES = '"+cMes+"' ) AND "
		Else
			cSQL += " ( BGJ_ANO = '    ' OR BGJ_ANO = '"+cAno+"' ) AND "
			cSQL += " ( BGJ_MES = '  ' OR BGJ_MES = '"+cMes+"' ) AND "
		Endif
		
		If BGJ->(FieldPos("BGJ_DATAIN")) > 0
			cSQL += " ( BGJ_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pode ser um reajuste ou um ajuste...                                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BGJ->(BGJ->(FieldPos("BGJ_TIPREA"))) > 0
			If !lAjuste
				cSQL += " ( BGJ_TIPREA = '1' OR BGJ_TIPREA = '') AND "
			Else
				cSQL += " BGJ_TIPREA = '2' AND "
			Endif
		Endif
		
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL := ChangeQuery(cSQL)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
		
		If ! PLS101->(Eof())
			cTipoAna  := PLS101->BGJ_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato "3" - Considerar aniversario da inclusao do usuario
			cConsTmp  := PLS101->BGJ_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano "3" - Usuarios com mais de 12 anos de plano
			cIndice   := PLS101->BGJ_INDRRL  //indice de reajuste...
			lIndVld   := .T.
			lProduto  := PLS101->BGJ_PROD == "1"
			lOpcional := PLS101->BGJ_OPC == "1"
			If BGJ->( FieldPos("BGJ_DATOPC") ) > 0
				lDataOpc  := PLS101->BGJ_DATOPC == "1" .And. cConsTmp <> "1"
			Endif
			lTaxa     := PLS101->BGJ_TAX == "1"
			cNivel	  := '1'
			
			If BGJ->( FieldPos("BGJ_ZERAIN") ) > 0
				lZeraNiv1 := PLS101->BGJ_ZERAIN = "S"
				nIndice   := If(PLS101->BGJ_ZERAIN<>"S",PLS101->BGJ_PERRRL,0)  //Percentual de reajuste...
			Else
				lZeraNiv1 :=.F.
				nIndice   := PLS101->BGJ_PERRRL  //Percentual de reajuste...
			Endif
			
			If BGJ->( FieldPos("BGJ_USRBLQ") ) > 0
				lOnlyLook := (PLS101->BGJ_USRBLQ == "1")
			Endif
			If BGJ->( FieldPos("BGJ_FRANQ") ) > 0
				lFranquia := (PLS101->BGJ_FRANQ == "1")
			Endif

			// EspecМfico Coparticipao /////////////
			If BGJ->( FieldPos("BGJ_IRCPFX") ) > 0
				cInCpFx := PLS101->BGJ_IRCPFX
			Else
				cInCpFx := ""
			EndIf
			If BGJ->( FieldPos("BGJ_PRCPFX") ) > 0
				nInCpFx := PLS101->BGJ_PRCPFX
			Else
				nInCpFx := 0.0
			EndIf
			If BGJ->( FieldPos("BGJ_IRCPPE") ) > 0
				cInCpPe := PLS101->BGJ_IRCPPE
			Else
				cInCpPe := ""
			EndIf
			If BGJ->( FieldPos("BGJ_PRCPPE") ) > 0
				nInCpPe := PLS101->BGJ_PRCPPE
			Else
				nInCpPe := 0.0
			EndIf
			////////////////////////////////////////
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fecha area de trabalho temporaria...                                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PLS101->(DbCloseArea())
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Encontrou a parametrizacao desejada, abandono o loop agora.              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Exit
			
		Else
			cTipoAna  := ""
			cConsTmp  := ""
			nIndice   := 0
			cIndice   := ""
			lIndVld   := .F.
			lProduto  := .F.
			lOpcional := .F.
			lTaxa     := .F.
			lOnlyLook := .F.
			cNivel 	  := ''
			lFranquia := .F.
			lZeraNiv1 :=.F.
			cInCpFx   := ""
			nInCpFx   := 0.0
			cInCpPe   := ""
			nInCpPe   := 0.0
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fecha area de trabalho temporaria...                                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PLS101->(DbCloseArea())
		Endif
	Next
	aRegGrp   := {;
		cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv1,;
		cInCpFx,nInCpFx,cInCpPe,nInCpPe;
	}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acumula como um grupo empresa valido no processamento...                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aadd(aGrupos,{;
		BG9->BG9_CODIGO,AllTrim(BG9->BG9_DESCRI),BG9->BG9_TIPO,0,cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,;
		lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv1,cInCpFx,nInCpFx,cInCpPe,nInCpPe;
	})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se for um grupo empresa PF sempre tem que ter a parametrizacao no grp... Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BG9->BG9_TIPO == "1" .And. ! lIndVld
		aadd(aErrosGrp,{"01","Nao foi encontrado parametrizacoes de reajuste para a empresa",BG9->BG9_CODIGO,BG9->BG9_DESCRI})
		BG9->(DbSkip())
		Loop
	Endif
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Aplica o reajuste, caso seja necessario...                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->(DbSetOrder(7))
	If BA3->(DbSeek(xFilial("BA3")+BG9->(BG9_CODINT+BG9_CODIGO)))
		While ! BA3->(Eof()) .And. BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP) == xFilial("BA3")+BG9->(BG9_CODINT+BG9_CODIGO)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem de processamento...                                       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Analisando Familia "+BA3->(BA3_CODINT+'.'+BA3_CODEMP+'.'+BA3_MATRIC))
				ProcessMessage()
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se for PJ busca por contrato e subcontrato...                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BG9->BG9_TIPO == "2"
				For nBh3 := 1 To 2
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Pesquisa se houve niveis de parametrizacoes de reajuste neste nivel...   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cSQL := " SELECT BH3_TIPOIN,BH3_TIPO,BH3_PERRRL,BH3_INDRRL,BH3_PROD,BH3_OPC,BH3_TAX "
					If BH3->( FieldPos("BH3_USRBLQ") ) > 0
						cSQL += " ,BH3_USRBLQ "
					Endif
					If BH3->( FieldPos("BH3_FRANQ") ) > 0
						cSql += " ,BH3_FRANQ "
					Endif
					
					If BH3->( FieldPos("BH3_ZERAIN") ) > 0
						cSql += " ,BH3_ZERAIN "
					Endif
					
					If BH3->( FieldPos("BH3_DATOPC") ) > 0
						cSql += " ,BH3_DATOPC "
					Endif

					// EspecМfico Coparticipao /////////////
					If BH3->( FieldPos("BH3_IRCPFX") ) > 0
						cSql += " ,BH3_IRCPFX "
					EndIf
					If BH3->( FieldPos("BH3_PRCPFX") ) > 0
						cSql += " ,BH3_PRCPFX "
					EndIf
					If BH3->( FieldPos("BH3_IRCPPE") ) > 0
						cSql += " ,BH3_IRCPPE "
					EndIf
					If BH3->( FieldPos("BH3_PRCPPE") ) > 0
						cSql += " ,BH3_PRCPPE "
					EndIf
					////////////////////////////////////////
					
					cSQL += " FROM "+RetSQLName("BH3")+" WHERE "
					cSQL += " BH3_FILIAL = '"+xFilial("BH3")+"' AND "
					cSQL += " BH3_CODINT = '"+BG9->BG9_CODINT+"' AND "
					cSQL += " BH3_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
					cSQL += " BH3_NUMCON = '"+BA3->BA3_CONEMP+"' AND "
					cSQL += " BH3_VERSAO = '"+BA3->BA3_VERCON+"' AND "
					If nBh3 == 1
						cSQL += " ( BH3_ANO = '"+cAno+"' ) AND "
						cSQL += " ( BH3_MES = '"+cMes+"' ) AND "
					Else
						cSQL += " ( BH3_ANO = '    ' OR BH3_ANO = '"+cAno+"' ) AND "
						cSQL += " ( BH3_MES = '  ' 	OR BH3_MES = '"+cMes+"' ) AND "
					Endif
					
					If BH3->(FieldPos("BH3_DATAIN")) > 0
						cSQL += " ( BH3_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
					Endif
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Pode ser um reajuste ou um ajuste...                                     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BH3->(BH3->(FieldPos("BH3_TIPREA"))) > 0
						If !lAjuste
							cSQL += " ( BH3_TIPREA = '1' OR BH3_TIPREA = '') AND "
						Else
							cSQL += " BH3_TIPREA = '2' AND "
						Endif
					Endif
					cSQL += " D_E_L_E_T_ = ' ' "
					
					cSQL := ChangeQuery(cSQL)
					DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
					
					If ! PLS101->(Eof())
						cTipoAna  := PLS101->BH3_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
						cConsTmp  := PLS101->BH3_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
						cIndice   := PLS101->BH3_INDRRL  //indice de reajuste...
						lIndVld   := .T.
						lProduto  := PLS101->BH3_PROD == "1"
						lOpcional := PLS101->BH3_OPC == "1"
						If BH3->( FieldPos("BH3_DATOPC") ) > 0
							lDataOpc  := PLS101->BH3_DATOPC == "1".And. cConsTmp <> "1"
						Endif
						
						lTaxa     := PLS101->BH3_TAX == "1"
						cNivel    := '2'
						
						If BH3->( FieldPos("BH3_ZERAIN") ) > 0
							lZeraNiv2 := PLS101->BH3_ZERAIN="S"
							nIndice   := If(PLS101->BH3_ZERAIN<>"S",PLS101->BH3_PERRRL,0)  //Percentual de reajuste...
						Else
							lZeraNiv2 :=.F.
							nIndice   := PLS101->BH3_PERRRL  //Percentual de reajuste...
						Endif
						
						If BH3->( FieldPos("BH3_USRBLQ") ) > 0
							lOnlyLook := (PLS101->BH3_USRBLQ == "1")
						Endif
						If BH3->( FieldPos("BH3_FRANQ") ) > 0
							lFranquia := (PLS101->BH3_FRANQ  == "1")
						Endif

						// EspecМfico Coparticipao /////////////
						If BH3->( FieldPos("BH3_IRCPFX") ) > 0
							cInCpFx := PLS101->BH3_IRCPFX
						Else
							cInCpFx := ""
						EndIf
						If BH3->( FieldPos("BH3_PRCPFX") ) > 0
							nInCpFx := PLS101->BH3_PRCPFX
						Else
							nInCpFx := 0.0
						EndIf
						If BH3->( FieldPos("BH3_IRCPPE") ) > 0
							cInCpPe := PLS101->BH3_IRCPPE
						Else
							cInCpPe := ""
						EndIf
						If BH3->( FieldPos("BH3_PRCPPE") ) > 0
							nInCpPe := PLS101->BH3_PRCPPE
						Else
							nInCpPe := 0.0
						EndIf
						////////////////////////////////////////

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Fecha area de trabalho temporaria...                                     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						PLS101->(DbCloseArea())
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Encontrou a parametrizacao desejada, abandono o loop agora.              Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						Exit
						
					Else
						If nBh3 == 2
							If aRegGrp[5]
								cTipoAna  := aRegGrp[01]
								cConsTmp  := aRegGrp[02]
								nIndice   := aRegGrp[03]
								cIndice   := aRegGrp[04]
								lIndVld   := .T.
								lProduto  := aRegGrp[06]
								lOpcional := aRegGrp[07]
								lTaxa     := aRegGrp[08]
								lOnlyLook := aRegGrp[09]
								cNivel    := aRegGrp[10]
								lFranquia := aRegGrp[11]
								lZeraNiv2 := aRegGrp[12]
								cInCpFx   := aRegGrp[13]
								nInCpFx   := aRegGrp[14]
								cInCpPe   := aRegGrp[15]
								nInCpPe   := aRegGrp[16]
							Else
								cTipoAna  := ""
								cConsTmp  := ""
								nIndice   := 0
								cIndice   := ""
								lIndVld   := .F.
								lProduto  := .F.
								lOpcional := .F.
								lTaxa     := .F.
								lOnlyLook := .F.
								cNivel    := ''
								lFranquia := .F.
								lZeraNiv2 := .F.
								cInCpFx   := ""
								nInCpFx   := 0.0
								cInCpPe   := ""
								nInCpPe   := 0.0
							Endif
						Endif
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Fecha area de trabalho temporaria...                                     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						PLS101->(DbCloseArea())
					Endif
				Next
				
				aRegCon   := {;
					cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv2,;
					cInCpFx,nInCpFx,cInCpPe,nInCpPe;
				}
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Realiza a quebra por contrato...                                         Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cQuebCon := BA3->(BA3_CONEMP+BA3_VERCON)
				aadd(aContratos,{;
					BG9->BG9_CODIGO,BG9->BG9_CODIGO+BA3->BA3_CONEMP+BA3->BA3_VERCON,0,cTipoAna,cConsTmp,nIndice,;
					cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv2,cInCpFx,nInCpFx,cInCpPe,nInCpPe;
				})
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a quebra por contrato...                                             Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				While ! BA3->(Eof()) .And. BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON) == ;
					xFilial("BA3")+BG9->(BG9_CODINT+BG9_CODIGO)+cQuebCon
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Vefifica se ja foi reajusteado para este subcontrato neste ano mes...    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !lAjuste
						BPF->(DbSetOrder(2))
						If BPF->(DbSeek(xFilial("BPF")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)+cAnoMes))
							
							aadd(aErrosSub,{"02","Subcontrato ja reajustado neste ano/mes",;
							BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,;
							BA3->BA3_SUBCON,BA3->BA3_VERSUB})
							BA3->(DbSkip())
							Loop
						Endif
					Else
						BPF->(DbSetOrder(1))
						If BPF->(DbSeek(xFilial("BPF")+ BA3->BA3_CODINT+BHW->BHW_CODREA+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB))
							While !BPF->( Eof() ) .and. BPF->BPF_OPEREA+BPF->BPF_CODREA+BPF->BPF_CODEMP+BPF->BPF_CONEMP+BPF->BPF_VERCON+BPF->BPF_SUBCON+BPF->BPF_VERSUB ==;
								BA3->BA3_CODINT+BHW->BHW_CODREA+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB
								If !Empty(BPF->BPF_CODAJS)
									aadd(aErrosSub,{"02","Subcontrato ja ajustado neste ano/mes",;
									BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,;
									BA3->BA3_SUBCON,BA3->BA3_VERSUB})
									BA3->(DbSkip())
									Loop
								Endif
								BPF->( dbSkip() )
							Enddo
						Endif
					Endif
					
					For nBya := 1 To 2
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Pesquisa se houve niveis de parametrizacoes de reajuste neste nivel...   Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cSQL := " SELECT BYA_TIPOIN,BYA_TIPO,BYA_PERRRL,BYA_INDRRL,BYA_PROD,BYA_OPC,BYA_TAX "
						
						If BYA->( FieldPos("BYA_CODPLA") ) > 0
							cSql += " , BYA_CODPLA, BYA_VERPLA "
						Endif
						If BYA->( FieldPos("BYA_USRBLQ") ) > 0
							cSql += " , BYA_USRBLQ "
						Endif
						If BYA->( FieldPos("BYA_FRANQ") ) > 0
							cSql += " , BYA_FRANQ "
						Endif
						
						If BYA->( FieldPos("BYA_ZERAIN") ) > 0
							cSql += " ,BYA_ZERAIN "
						Endif
						
						If BYA->( FieldPos("BYA_DATOPC") ) > 0
							cSql += " ,BYA_DATOPC "
						Endif

						// EspecМfico Coparticipao /////////////
						If BYA->( FieldPos("BYA_IRCPFX") ) > 0
							cSql += " ,BYA_IRCPFX "
						EndIf
						If BYA->( FieldPos("BYA_PRCPFX") ) > 0
							cSql += " ,BYA_PRCPFX "
						EndIf
						If BYA->( FieldPos("BYA_IRCPPE") ) > 0
							cSql += " ,BYA_IRCPPE "
						EndIf
						If BYA->( FieldPos("BYA_PRCPPE") ) > 0
							cSql += " ,BYA_PRCPPE "
						EndIf
						////////////////////////////////////////
						
						cSql += " FROM "+RetSQLName("BYA")+" WHERE "
						cSQL += " BYA_FILIAL = '"+xFilial("BYA")+"' AND "
						cSQL += " BYA_CODINT = '"+BG9->BG9_CODINT+"' AND "
						cSQL += " BYA_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
						cSQL += " BYA_NUMCON = '"+BA3->BA3_CONEMP+"' AND "
						cSQL += " BYA_VERSAO = '"+BA3->BA3_VERCON+"' AND "
						cSQL += " BYA_SUBCON = '"+BA3->BA3_SUBCON+"' AND "
						cSQL += " BYA_VERSUB = '"+BA3->BA3_VERSUB+"' AND "
						If nBya == 1
							cSQL += " ( BYA_ANO = '"+cAno+"' ) AND "
							cSQL += " ( BYA_MES = '"+cMes+"' ) AND "
						Else
							cSQL += " ( BYA_ANO = '    ' OR BYA_ANO = '"+cAno+"' ) AND "
							cSQL += " ( BYA_MES = '  ' OR BYA_MES = '"+cMes+"' ) AND "
						Endif
						
						If BYA->(FieldPos("BYA_DATAIN")) > 0
							cSQL += " ( BYA_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Pode ser um reajuste ou um ajuste...                                     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If BYA->(BYA->(FieldPos("BYA_TIPREA"))) > 0
							If !lAjuste
								cSQL += " (BYA_TIPREA = '1' OR BYA_TIPREA = '') AND "
							Else
								cSQL += " BYA_TIPREA = '2' AND "
							Endif
						Endif
						cSQL += " D_E_L_E_T_ = ' ' "
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Considerar apenas o produto especifico...                                Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If BYA->( FieldPos("BYA_CODPLA") ) > 0
							cSql += " ORDER BY BYA_CODPLA DESC, BYA_VERPLA DESC "
						Endif
						
						cSQL := ChangeQuery(cSQL)
						DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Caso nao ache com parametros especificos, retorna para nova pesquisa     Ё
						//Ё usando parametros genericos...                                           Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If PLS101->( Eof() ) .and. nBya == 1
							PLS101->( dbClosearea() )
							Loop
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Caso nao ache com parametros genericos, a rotina vai usar parametros de  Ё
							//Ё outros niveis...                                                         Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						Elseif PLS101->( Eof() ) .and. nBya == 2
							If     aRegCon[5]
								cTipoAna  := aRegCon[01]
								cConsTmp  := aRegCon[02]
								nIndice   := aRegCon[03]
								cIndice   := aRegCon[04]
								lIndVld   := .T.
								lProduto  := aRegCon[06]
								lOpcional := aRegCon[07]
								lTaxa     := aRegCon[08]
								lOnlyLook := aRegCon[09]
								cNivel    := aRegCon[10]
								lFranquia := aRegCon[11]
								lZeraNiv3 := aRegCon[12]
								cInCpFx   := aRegCon[13]
								nInCpFx   := aRegCon[14]
								cInCpPe   := aRegCon[15]
								nInCpPe   := aRegCon[16]
							ElseIf aRegGrp[5]
								cTipoAna  := aRegGrp[01]
								cConsTmp  := aRegGrp[02]
								nIndice   := aRegGrp[03]
								cIndice   := aRegGrp[04]
								lIndVld   := .T.
								lProduto  := aRegGrp[06]
								lOpcional := aRegGrp[07]
								lTaxa     := aRegGrp[08]
								lOnlyLook := aRegGrp[09]
								cNivel    := aRegGrp[10]
								lFranquia := aRegGrp[11]
								lZeraNiv3 := aRegGrp[12]
								cInCpFx   := aRegGrp[13]
								nInCpFx   := aRegGrp[14]
								cInCpPe   := aRegGrp[15]
								nInCpPe   := aRegGrp[16]
							Else
								cTipoAna  := ""
								cConsTmp  := ""
								nIndice   := 0
								cIndice   := ""
								lIndVld   := .F.
								lProduto  := .F.
								lOpcional := .F.
								lTaxa     := .F.
								lOnlyLook := .F.
								cNivel	  := ''
								lFranquia := .F.
								lZeraNiv3 := .F.
								cInCpFx   := ""
								nInCpFx   := 0.0
								cInCpPe   := ""
								nInCpPe   := 0.0
							Endif
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica se existe indice para o subcontrato... se nao existir critica   Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If ! lIndVld
								PLS101->( dbCloseArea() )
								BA3->(DbSkip())
								Loop
							Else
								PLS101->( dbCloseArea() )
							Endif
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Alimenta a matriz de sub contratos selecionados...                       Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							A101ADDSUB(cIndice, nIndice, cAnoMesInd, aSubCon, aErrosSub,;
							cTipoAna,cConsTmp,lIndVld,lProduto,lOpcional,lTaxa,Space(04),;
							Space(03),lOnlyLook,cNivel,lFranquia,lZeraNiv3,,cInCpFx,nInCpFx,cInCpPe,nInCpPe)
						Else
							PLS101->( dbGotop() )
							While !PLS101->( Eof() )
								
								cTipoAna  := PLS101->BYA_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
								cConsTmp  := PLS101->BYA_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
								cIndice   := PLS101->BYA_INDRRL  //indice de reajuste...
								lIndVld   := .T.
								lProduto  := PLS101->BYA_PROD 	== "1"
								lOpcional := PLS101->BYA_OPC 	== "1"
								If BYA->( FieldPos("BYA_DATOPC") ) > 0
									lDataOpc  := PLS101->BYA_DATOPC == "1".And. cConsTmp <> "1"
								Endif
								lTaxa     := PLS101->BYA_TAX 	== "1"
								cNivel    := '3'
								
								If BYA->( FieldPos("BYA_ZERAIN") ) > 0
									lZeraNiv3 := PLS101->BYA_ZERAIN="S"							
									nIndice   := If(PLS101->BYA_ZERAIN<>"S",PLS101->BYA_PERRRL,0)  //Percentual de reajuste...				
								Else
									lZeraNiv3 :=.F.
									nIndice   := PLS101->BYA_PERRRL  //Percentual de reajuste...
								Endif
								
								If BYA->( FieldPos("BYA_CODPLA") ) > 0
									cCodPla   := PLS101->BYA_CODPLA
								Endif
								If BYA->( FieldPos("BYA_VERPLA") ) > 0
									cVerPla	  := PLS101->BYA_VERPLA
								Endif
								If BYA->( FieldPos("BYA_USRBLQ") ) > 0
									lOnlyLook := (PLS101->BYA_USRBLQ == "1")
								Endif
								If BYA->( FieldPos("BYA_FRANQ") ) > 0
									lFranquia := (PLS101->BYA_FRANQ == "1")
								Endif

								// EspecМfico Coparticipao /////////////
								If BYA->( FieldPos("BYA_IRCPFX") ) > 0
									cInCpFx := PLS101->BYA_IRCPFX
								Else
									cInCpFx := ""
								EndIf
								If BYA->( FieldPos("BYA_PRCPFX") ) > 0
									nInCpFx := PLS101->BYA_PRCPFX
								Else
									nInCpFx := 0.0
								EndIf
								If BYA->( FieldPos("BYA_IRCPPE") ) > 0
									cInCpPe := PLS101->BYA_IRCPPE
								Else
									cInCpPe := ""
								EndIf
								If BYA->( FieldPos("BYA_PRCPPE") ) > 0
									nInCpPe := PLS101->BYA_PRCPPE
								Else
									nInCpPe := 0.0
								EndIf
								////////////////////////////////////////
								
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Alimenta a matriz de sub contratos selecionados...                       Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								A101ADDSUB(cIndice, nIndice, cAnoMesInd, aSubCon, aErrosSub,;
								cTipoAna,cConsTmp,lIndVld,lProduto,lOpcional,lTaxa,cCodPla,cVerPla,;
								lOnlyLook,cNivel,lFranquia,lZeraNiv3,,cInCpFx,nInCpFx,cInCpPe,nInCpPe)
								PLS101->( dbSkip() )
							Enddo
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Fecha a area de trabalho...                                              Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							PLS101->(DbCloseArea())
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Caso encontre parametro, abandona o FOR imediatamente...                 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							Exit
						Endif
					Next
					If ! lIndVld
						Loop
					Endif
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Faz a quebra por subcontrato...                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cQuebSub := BA3->(BA3_SUBCON+BA3_VERSUB)
					While ! BA3->(Eof()) .And. BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) == ;
						xFilial("BA3")+BG9->(BG9_CODINT+BG9_CODIGO)+cQuebCon+cQuebSub
						//BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
						///POSICIONA NO SUBCONBTRATO PARA VERIFICAR SE ESTA BLOQUEADO
						BQC->(Dbseek(xFilial("BQC")+BG9->(BG9_CODINT+BG9_CODIGO)+cQuebCon+cQuebSub ))
						If !Empty(BQC->BQC_CODBLO).And. Substr(dtos(BQC->BQC_DATBLO),1,6)<=(cAno+cMes) .And. !GetNewPar("MV_PLREABQ",.T.)
							BA3->(Dbskip())
							Loop
						Endif
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Exibe mensagem de processamento...                                       Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lDisplay
							IncProc("Analisando Familia "+BA3->BA3_CODINT+'.'+BA3->BA3_CODEMP+'.'+BA3->BA3_MATRIC)
							ProcessMessage()
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё ** Verifica se a familia tem usuarios ativos...                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						aRetUsr := PLSLOADUSR(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,cAno,cMes,,lOnlyLook)
						If Len(aRetUsr) == 0
							BA3->(DbSkip())
							Loop
						Else
							aAdd(aTotUsr,aRetUsr)
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Cancelamento Reajuste  (RDS) 13/10/2010                                 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						
						If Len(aRetUsr) > 0
							aErrosCreTmp := PLSA101CRE(aRetUsr)
							If Len(aErrosCreTmp) > 0
								For niRea := 1 to Len(aErrosCreTmp)
									aadd(aErrosUsr,{"04","Usuario com Cancelamento de Reajuste em Vigencia.",aErrosCreTmp[niRea][3]})
								Next
							Endif
						Endif
						PLSA101VLD(cTipoAna,cConsTmp,nIndice,cIndice,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,cAno,;
						cMes,lProduto,lOpcional,lTaxa,cAnoMesInd,aUsuarios,aErrosUsr,aRetUsr,cNivel,lFranquia,lZeraNiv3,,;
						cInCpFx,nInCpFx,cInCpPe,nInCpPe)
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Proximo familia.... da quebra...                                         Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BA3->(DbSkip())
					Enddo
					
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifico se o titular estА ciente e de acordo com a RN 309.                                      |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					
					
					//Tratamento para atender a RN309 que determina um percentual mАximo de reajuste para contratos coletivos com menos de 30 vidas
					If Len(aTotUsr)<= GetNewPar("MV_RN309QT",30) .and. GetNewPar("MV_PLSR309","1") =="1"
						// Ler o aFamilias e alterar o indice de reajuste
						For nj:=1 to len(aFamilias)
							If aFamilias[nJ,15] = "2" //Pessoa FМsica
								If BQC->( MsSeek(xFilial("BQC")+substr(aFamilias[nJ,2],1,TamSx3("BA3_CODINT")[1])+aFamilias[nJ,5]) )
									DbSelectArea("BQC")
									lCie309 := AllTrim(BQC->BQC_CIE309) = '1' 
									If lCie309 .AND. ;
										BT5->( MsSeek(xFilial("BT5")+BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON) ) )
										If AllTrim(BT5->BT5_TIPCON) $ "2,3" //Contrato coletivo
											If Val(aFamilias[nJ,3]) > GetNewPar("MV_RN309PC",9.04)
												aFamilias[nJ,3]:= Alltrim(str(GetNewPar("MV_RN309PC",9.04)))
											Endif
										EndIf		
									EndIf
								EndIf
							EndIf
						Next
						For nJ:=1 to Len(aSubCon)
							
							If aSubCon[nJ,23] == '1' .AND. ;
								BT5->( MsSeek(xFilial("BT5")+aSubCon[nJ,24]+aSubCon[nJ,4]+aSubCon[nJ,5]+aSubCon[nJ,6]) )
						
								If AllTrim(BT5->BT5_TIPCON) $ "2,3" //Contrato coletivo
							
									If aSubCon[nJ,2] > GetNewPar("MV_RN309PC",9.04)
										aSubCon[nJ,2]:= GetNewPar("MV_RN309PC",9.04)
									Endif
									If aSubCon[nJ,11]> GetNewPar("MV_RN309PC",9.04)
										aSubCon[nJ,11]:= GetNewPar("MV_RN309PC",9.04)
									Endif
							
								EndIf
							
							EndIf
							
						Next
						For nJ:=1 to Len(aUsuarios)
							If aUsuarios[nJ,14] = "2" //Contrato Pessoa Juridica
								If BQC->( MsSeek(xFilial("BQC")+substr(aUsuarios[nJ,2],1,TamSx3("BA3_CODINT")[1])+aUsuarios[nJ,5]) )
									DbSelectArea("BQC")
									lCie309 := AllTrim(BQC->BQC_CIE309) = '1'
									If  lCie309 .AND. ;
										BT5->( MsSeek(xFilial("BT5")+BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON) ) )
										If AllTrim(BT5->BT5_TIPCON) $ "2,3" .AND. Val(aUsuarios[nJ,3]) > GetNewPar("MV_RN309PC",9.04)
								aUsuarios[nJ,3]:= Alltrim(Str(GetNewPar("MV_RN309PC",9.04)))
							Endif
									EndIf
								EndIf
							EndIf
						Next
					Endif
				Enddo
				
				If aContratos[Len(aContratos),3] == 0
					aDel(aContratos,Len(aContratos))
					aSize(aContratos,Len(aContratos)-1)
				Endif
				
				
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё ** Verifica se a familia tem usuarios ativos...                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aRetUsr := PLSLOADUSR(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,cAno,cMes,,lOnlyLook)
				If Len(aRetUsr) == 0
					BA3->(DbSkip())
					Loop
				Endif
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Cancelamento Reajuste  (RDS) 13/10/2010                                 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				
				If Len(aRetUsr) > 0
					aErrosCreTmp := PLSA101CRE(aRetUsr)
					If Len(aErrosCreTmp) > 0
						If Len(aErrosCreTmp) > 0
							For niRea := 1 to Len(aErrosCreTmp)
								aadd(aErrosUsr,{"04","Usuario com Cancelamento de Reajuste em Vigencia.",aErrosCreTmp[niRea][3]})
							Next
						Endif
					Endif
				Endif
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Tratamentos para PF... analisa a familia atual....                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PLSA101VLD(cTipoAna,cConsTmp,nIndice,cIndice,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,cAno,cMes,;
				lProduto,lOpcional,lTaxa,cAnoMesInd,aUsuarios,aErrosUsr,aRetUsr,cNivel,lFranquia,lZeraNiv1,,cInCpFx,nInCpFx,cInCpPe,nInCpPe)
				
				BA3->(DbSkip())
			Endif
		Enddo
	Elseif !GetNewPar('MV_PLRSUBV',.F.)
		aadd(aErrosGrp,{"03","Nao existem familias para este grupo empresa",BG9->BG9_CODIGO,BG9->BG9_DESCRI})
	Endif
	
	If GetNewPar('MV_PLRSUBV',.F.)	//// Verifica se tem subcontrado sem familia para o reajuste
		
		cSQL:= "SELECT BQC_CODINT,BQC_CODEMP,BQC_NUMCON,BQC_VERCON,BQC_SUBCON,BQC_VERSUB "
		cSQL+= "FROM "+RetSqlName('BQC')+" BQC "
		cSQL+=" LEFT JOIN "+RetSqlName('BA3') +" BA3 ON BA3_FILIAL='"+xFilial("BA3")+"' AND BA3_CODINT = BQC_CODINT AND BA3_CODEMP = BQC_CODEMP AND "
		cSQL+=" BA3_CONEMP=BQC_NUMCON AND BA3_VERCON=BQC_VERCON AND BA3_SUBCON=BQC_SUBCON AND BA3_VERSUB=BQC_VERSUB  AND BA3.D_E_L_E_T_ = '' "
		cSQL+=" WHERE BQC.D_E_L_E_T_ = '' AND BQC_FILIAL ='"+xFilial("BQC")+"' AND BQC_CODINT ='"+BG9->BG9_CODINT+"' AND BQC_CODEMP='"+BG9->BG9_CODIGO+"' AND BA3_CODEMP IS NULL "
		
		cSQL := ChangeQuery(cSQL)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"TRBBQC",.T.,.T.)
		
		While TRBBQC->(!EOF())
			
			
			For nBh3 := 1 To 2
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Pesquisa se houve niveis de parametrizacoes de reajuste neste nivel...   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cSQL := " SELECT BH3_TIPOIN,BH3_TIPO,BH3_PERRRL,BH3_INDRRL,BH3_PROD,BH3_OPC,BH3_TAX "
				If BH3->( FieldPos("BH3_USRBLQ") ) > 0
					cSQL += " ,BH3_USRBLQ "
				Endif
				If BH3->( FieldPos("BH3_FRANQ") ) > 0
					cSql += " ,BH3_FRANQ "
				Endif
				
				If BH3->( FieldPos("BH3_ZERAIN") ) > 0
					cSql += " ,BH3_ZERAIN "
				Endif
				
				If BH3->( FieldPos("BH3_DATOPC") ) > 0
					cSql += " ,BH3_DATOPC "
				Endif

				// EspecМfico Coparticipao /////////////
				If BH3->( FieldPos("BH3_IRCPFX") ) > 0
					cSql += " ,BH3_IRCPFX "
				EndIf
				If BH3->( FieldPos("BH3_PRCPFX") ) > 0
					cSql += " ,BH3_PRCPFX "
				EndIf
				If BH3->( FieldPos("BH3_IRCPPE") ) > 0
					cSql += " ,BH3_IRCPPE "
				EndIf
				If BH3->( FieldPos("BH3_PRCPPE") ) > 0
					cSql += " ,BH3_PRCPPE "
				EndIf
				////////////////////////////////////////
				
				cSQL += " FROM "+RetSQLName("BH3")+" WHERE "
				cSQL += " BH3_FILIAL = '"+xFilial("BH3")+"' AND "
				cSQL += " BH3_CODINT = '"+BG9->BG9_CODINT+"' AND "
				cSQL += " BH3_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
				cSQL += " BH3_NUMCON = '"+TRBBQC->BQC_NUMCON+"' AND "
				cSQL += " BH3_VERSAO = '"+TRBBQC->BQC_VERCON+"' AND "
				If nBh3 == 1
					cSQL += " ( BH3_ANO = '"+cAno+"' ) AND "
					cSQL += " ( BH3_MES = '"+cMes+"' ) AND "
				Else
					cSQL += " ( BH3_ANO = '    ' OR BH3_ANO = '"+cAno+"' ) AND "
					cSQL += " ( BH3_MES = '  ' 	OR BH3_MES = '"+cMes+"' ) AND "
				Endif
				
				If BH3->(FieldPos("BH3_DATAIN")) > 0
					cSQL += " ( BH3_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
				Endif
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Pode ser um reajuste ou um ajuste...                                     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BH3->(BH3->(FieldPos("BH3_TIPREA"))) > 0
					If !lAjuste
						cSQL += " ( BH3_TIPREA = '1' OR BH3_TIPREA = '') AND "
					Else
						cSQL += " BH3_TIPREA = '2' AND "
					Endif
				Endif
				cSQL += " D_E_L_E_T_ = ' ' "
				
				cSQL := ChangeQuery(cSQL)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
				
				If ! PLS101->(Eof())
					cTipoAna  := PLS101->BH3_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
					cConsTmp  := PLS101->BH3_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
					cIndice   := PLS101->BH3_INDRRL  //indice de reajuste...
					lIndVld   := .T.
					lProduto  := PLS101->BH3_PROD == "1"
					lOpcional := PLS101->BH3_OPC == "1"
					If BH3->( FieldPos("BH3_DATOPC") ) > 0
						lDataOpc  := PLS101->BH3_DATOPC == "1".And. cConsTmp <> "1"
					Endif
					
					lTaxa     := PLS101->BH3_TAX == "1"
					cNivel    := '2'
					
					If BH3->( FieldPos("BH3_ZERAIN") ) > 0
						lZeraNiv2 := PLS101->BH3_ZERAIN="S"
						nIndice   := If(PLS101->BH3_ZERAIN<>"S",PLS101->BH3_PERRRL,0)  //Percentual de reajuste...
					Else
						lZeraNiv2 :=.F.
						nIndice   := PLS101->BH3_PERRRL  //Percentual de reajuste...
					Endif
					
					If BH3->( FieldPos("BH3_USRBLQ") ) > 0
						lOnlyLook := (PLS101->BH3_USRBLQ == "1")
					Endif
					If BH3->( FieldPos("BH3_FRANQ") ) > 0
						lFranquia := (PLS101->BH3_FRANQ  == "1")
					Endif

					// EspecМfico Coparticipao /////////////
					If BH3->( FieldPos("BH3_IRCPFX") ) > 0
						cInCpFx := PLS101->BH3_IRCPFX
					Else
						cInCpFx := ""
					EndIf
					If BH3->( FieldPos("BH3_PRCPFX") ) > 0
						nInCpFx := PLS101->BH3_PRCPFX
					Else
						nInCpFx := 0.0
					EndIf
					If BH3->( FieldPos("BH3_IRCPPE") ) > 0
						cInCpPe := PLS101->BH3_IRCPPE
					Else
						cInCpPe := ""
					EndIf
					If BH3->( FieldPos("BH3_PRCPPE") ) > 0
						nInCpPe := PLS101->BH3_PRCPPE
					Else
						nInCpPe := 0.0
					EndIf
					////////////////////////////////////////

					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Fecha area de trabalho temporaria...                                     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PLS101->(DbCloseArea())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Grupo empreasa                                                           Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If Ascan(aGrupos,{ |x| x[1] == BG9->BG9_CODIGO}) == 0
					
						aadd(aGrupos,{BG9->BG9_CODIGO,AllTrim(BG9->BG9_DESCRI),BG9->BG9_TIPO,0,cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,;
						lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv1,cInCpFx,nInCpFx,cInCpPe,nInCpPe})
					Endif 
			
					If Ascan(aContratos,{ |x| x[2] == BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON}) == 0
						aadd(aContratos,{BG9->BG9_CODIGO,BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON,0,cTipoAna,cConsTmp,nIndice,;
						cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv2,cInCpFx,nInCpFx,cInCpPe,nInCpPe})
					Endif
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Encontrou a parametrizacao desejada, abandono o loop agora.              Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Exit
					
				Else
					If nBh3 == 2
						If aRegGrp[5]
							cTipoAna  := aRegGrp[01]
							cConsTmp  := aRegGrp[02]
							nIndice   := aRegGrp[03]
							cIndice   := aRegGrp[04]
							lIndVld   := .T.
							lProduto  := aRegGrp[06]
							lOpcional := aRegGrp[07]
							lTaxa     := aRegGrp[08]
							lOnlyLook := aRegGrp[09]
							cNivel    := aRegGrp[10]
							lFranquia := aRegGrp[11]
							lZeraNiv2 := aRegGrp[12]
							cInCpFx   := aRegGrp[13]
							nInCpFx   := aRegGrp[14]
							cInCpPe   := aRegGrp[15]
							nInCpPe   := aRegGrp[16]
						Else
							cTipoAna  := ""
							cConsTmp  := ""
							nIndice   := 0
							cIndice   := ""
							lIndVld   := .F.
							lProduto  := .F.
							lOpcional := .F.
							lTaxa     := .F.
							lOnlyLook := .F.
							cNivel    := ''
							lFranquia := .F.
							lZeraNiv2 := .F.
							cInCpFx   := ""
							nInCpFx   := 0.0
							cInCpPe   := ""
							nInCpPe   := 0.0
						Endif
					Endif
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Fecha area de trabalho temporaria...                                     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PLS101->(DbCloseArea())
				Endif
			Next
				
			aRegCon   := {cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv2,cInCpFx,nInCpFx,cInCpPe,nInCpPe}
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Realiza a quebra por contrato...                                         Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cQuebCon := TRBBQC->(BQC_NUMCON+BQC_VERCON) 
			
            /*/
			If Ascan(aContratos,{ |x| x[2] == BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON}) == 0
				aadd(aContratos,{BG9->BG9_CODIGO,BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON,0,cTipoAna,cConsTmp,nIndice,;
				cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv2})
			Endif
			/*/
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Faz a quebra por contrato...                                             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			While ! TRBBQC->(Eof()) .And. TRBBQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON) == ;
				BG9->(BG9_CODINT+BG9_CODIGO)+cQuebCon
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Vefifica se ja foi reajusteado para este subcontrato neste ano mes...    Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !lAjuste
					BPF->(DbSetOrder(2))
					If BPF->(DbSeek(xFilial("BPF")+TRBBQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)+cAnoMes))
						
						aadd(aErrosSub,{"02","Subcontrato ja reajustado neste ano/mes",;
						TRBBQC->BQC_CODINT,TRBBQC->BQC_CODEMP,TRBBQC->BQC_NUMCON,BQC->BQC_VERCON,;
						BQC->BQC_SUBCON,BQC->BQC_VERSUB})
						TRBBQC->(DbSkip())
						Loop
					Endif
				Else
					BPF->(DbSetOrder(1))
					If BPF->(DbSeek(xFilial("BPF")+ TRBBQC->BQC_CODINT+BHW->BHW_CODREA+TRBBQC->BQC_CODEMP+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON+TRBBQC->BQC_SUBCON+TRBBQC->BQC_VERSUB))
						While !BPF->( Eof() ) .and. BPF->BPF_OPEREA+BPF->BPF_CODREA+BPF->BPF_CODEMP+BPF->BPF_CONEMP+BPF->BPF_VERCON+BPF->BPF_SUBCON+BPF->BPF_VERSUB ==;
							TRBBQC->BQC_CODINT+BHW->BHW_CODREA+TRBBQC->BQC_CODEMP+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON+TRBBQC->BQC_SUBCON+TRBBQC->BQC_VERSUB
							If !Empty(BPF->BPF_CODAJS)
								aadd(aErrosSub,{"02","Subcontrato ja ajustado neste ano/mes",;
								TRBBQC->BQC_CODINT,TRBBQC->BQC_CODEMP,TRBBQC->BQC_NUMCON,TRBBQC->BQC_VERCON,;
								TRBBQC->BQC_SUBCON,TRBBQC->BQC_VERSUB})
								TRBBQC->(DbSkip())
								Loop
							Endif
							BPF->( dbSkip() )
						Enddo
					Endif
				Endif
				
				For nBya := 1 To 2
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Pesquisa se houve niveis de parametrizacoes de reajuste neste nivel...   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cSQL := " SELECT BYA_TIPOIN,BYA_TIPO,BYA_PERRRL,BYA_INDRRL,BYA_PROD,BYA_OPC,BYA_TAX "
					
					If BYA->( FieldPos("BYA_CODPLA") ) > 0
						cSql += " , BYA_CODPLA, BYA_VERPLA "
					Endif
					If BYA->( FieldPos("BYA_USRBLQ") ) > 0
						cSql += " , BYA_USRBLQ "
					Endif
					If BYA->( FieldPos("BYA_FRANQ") ) > 0
						cSql += " , BYA_FRANQ "
					Endif
					
					If BYA->( FieldPos("BYA_ZERAIN") ) > 0
						cSql += " ,BYA_ZERAIN "
					Endif
					
					If BYA->( FieldPos("BYA_DATOPC") ) > 0
						cSql += " ,BYA_DATOPC "
					Endif

					// EspecМfico Coparticipao /////////////
					If BYA->( FieldPos("BYA_IRCPFX") ) > 0
						cSql += " ,BYA_IRCPFX "
					EndIf
					If BYA->( FieldPos("BYA_PRCPFX") ) > 0
						cSql += " ,BYA_PRCPFX "
					EndIf
					If BYA->( FieldPos("BYA_IRCPPE") ) > 0
						cSql += " ,BYA_IRCPPE "
					EndIf
					If BYA->( FieldPos("BYA_PRCPPE") ) > 0
						cSql += " ,BYA_PRCPPE "
					EndIf
					////////////////////////////////////////
					
					cSql += " FROM "+RetSQLName("BYA")+" WHERE "
					cSQL += " BYA_FILIAL = '"+xFilial("BYA")+"' AND "
					cSQL += " BYA_CODINT = '"+BG9->BG9_CODINT+"' AND "
					cSQL += " BYA_CODIGO = '"+BG9->BG9_CODIGO+"' AND "
					cSQL += " BYA_NUMCON = '"+TRBBQC->BQC_NUMCON+"' AND "
					cSQL += " BYA_VERSAO = '"+TRBBQC->BQC_VERCON+"' AND "
					cSQL += " BYA_SUBCON = '"+TRBBQC->BQC_SUBCON+"' AND "
					cSQL += " BYA_VERSUB = '"+TRBBQC->BQC_VERSUB+"' AND "
					If nBya == 1
						cSQL += " ( BYA_ANO = '"+cAno+"' ) AND "
						cSQL += " ( BYA_MES = '"+cMes+"' ) AND "
					Else
						cSQL += " ( BYA_ANO = '    ' OR BYA_ANO = '"+cAno+"' ) AND "
						cSQL += " ( BYA_MES = '  ' OR BYA_MES = '"+cMes+"' ) AND "
					Endif
					
					If BYA->(FieldPos("BYA_DATAIN")) > 0
						cSQL += " ( BYA_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
					Endif
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Pode ser um reajuste ou um ajuste...                                     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BYA->(BYA->(FieldPos("BYA_TIPREA"))) > 0
						If !lAjuste
							cSQL += " (BYA_TIPREA = '1' OR BYA_TIPREA = '') AND "
						Else
							cSQL += " BYA_TIPREA = '2' AND "
						Endif
					Endif
					cSQL += " D_E_L_E_T_ = ' ' "
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Considerar apenas o produto especifico...                                Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BYA->( FieldPos("BYA_CODPLA") ) > 0
						cSql += " ORDER BY BYA_CODPLA DESC, BYA_VERPLA DESC "
					Endif
					
					cSQL := ChangeQuery(cSQL)
					DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Caso nao ache com parametros especificos, retorna para nova pesquisa     Ё
					//Ё usando parametros genericos...                                           Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If PLS101->( Eof() ) .and. nBya == 1
						PLS101->( dbClosearea() )
						Loop
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Caso nao ache com parametros genericos, a rotina vai usar parametros de  Ё
						//Ё outros niveis...                                                         Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Elseif PLS101->( Eof() ) .and. nBya == 2
						If     aRegCon[5]
							cTipoAna  := aRegCon[01]
							cConsTmp  := aRegCon[02]
							nIndice   := aRegCon[03]
							cIndice   := aRegCon[04]
							lIndVld   := .T.
							lProduto  := aRegCon[06]
							lOpcional := aRegCon[07]
							lTaxa     := aRegCon[08]
							lOnlyLook := aRegCon[09]
							cNivel    := aRegCon[10]
							lFranquia := aRegCon[11]
							lZeraNiv3 := aRegCon[12]
							cInCpFx   := aRegCon[13]
							nInCpFx   := aRegCon[14]
							cInCpPe   := aRegCon[15]
							nInCpPe   := aRegCon[16]
						ElseIf aRegGrp[5]
							cTipoAna  := aRegGrp[01]
							cConsTmp  := aRegGrp[02]
							nIndice   := aRegGrp[03]
							cIndice   := aRegGrp[04]
							lIndVld   := .T.
							lProduto  := aRegGrp[06]
							lOpcional := aRegGrp[07]
							lTaxa     := aRegGrp[08]
							lOnlyLook := aRegGrp[09]
							cNivel    := aRegGrp[10]
							lFranquia := aRegGrp[11]
							lZeraNiv3 := aRegGrp[12]
							cInCpFx   := aRegGrp[13]
							nInCpFx   := aRegGrp[14]
							cInCpPe   := aRegGrp[15]
							nInCpPe   := aRegGrp[16]
						Else
							cTipoAna  := ""
							cConsTmp  := ""
							nIndice   := 0
							cIndice   := ""
							lIndVld   := .F.
							lProduto  := .F.
							lOpcional := .F.
							lTaxa     := .F.
							lOnlyLook := .F.
							cNivel	  := ''
							lFranquia := .F.
							lZeraNiv3 := .F.
							cInCpFx   := ""
							nInCpFx   := 0.0
							cInCpPe   := ""
							nInCpPe   := 0.0
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se existe indice para o subcontrato... se nao existir critica   Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If ! lIndVld
							PLS101->( dbCloseArea() )
							TRBBQC->(DbSkip())
							Loop
						Else
							PLS101->( dbCloseArea() )
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Alimenta a matriz de sub contratos selecionados...                       Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						A101ADDSUB(cIndice, nIndice, cAnoMesInd, aSubCon, aErrosSub,;
						cTipoAna,cConsTmp,lIndVld,lProduto,lOpcional,lTaxa,Space(04),;
						Space(03),lOnlyLook,cNivel,lFranquia,lZeraNiv3,.T.,cInCpFx,nInCpFx,cInCpPe,nInCpPe)
					Else
						PLS101->( dbGotop() )
						While !PLS101->( Eof() )
							
							cTipoAna  := PLS101->BYA_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
							cConsTmp  := PLS101->BYA_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
							cIndice   := PLS101->BYA_INDRRL  //indice de reajuste...
							lIndVld   := .T.
							lProduto  := PLS101->BYA_PROD 	== "1"
							lOpcional := PLS101->BYA_OPC 	== "1"
							If BYA->( FieldPos("BYA_DATOPC") ) > 0
								lDataOpc  := PLS101->BYA_DATOPC == "1".And. cConsTmp <> "1"
							Endif
							lTaxa     := PLS101->BYA_TAX 	== "1"
							cNivel    := '3'
							
							If BYA->( FieldPos("BYA_ZERAIN") ) > 0
								lZeraNiv3 := PLS101->BYA_ZERAIN="S"
								nIndice   := If(PLS101->BYA_ZERAIN<>"S",PLS101->BYA_PERRRL,0)  //Percentual de reajuste...
							Else
								lZeraNiv3 :=.F.
								nIndice   := PLS101->BYA_PERRRL  //Percentual de reajuste...
							Endif
							
							If BYA->( FieldPos("BYA_CODPLA") ) > 0
								cCodPla   := PLS101->BYA_CODPLA
							Endif
							If BYA->( FieldPos("BYA_VERPLA") ) > 0
								cVerPla	  := PLS101->BYA_VERPLA
							Endif
							If BYA->( FieldPos("BYA_USRBLQ") ) > 0
								lOnlyLook := (PLS101->BYA_USRBLQ == "1")
							Endif
							If BYA->( FieldPos("BYA_FRANQ") ) > 0
								lFranquia := (PLS101->BYA_FRANQ == "1")
							Endif

							// EspecМfico Coparticipao /////////////
							If BYA->( FieldPos("BYA_IRCPFX") ) > 0
								cInCpFx := PLS101->BYA_IRCPFX
							Else
								cInCpFx := ""
							EndIf
							If BYA->( FieldPos("BYA_PRCPFX") ) > 0
								nInCpFx := PLS101->BYA_PRCPFX
							Else
								nInCpFx := 0.0
							EndIf
							If BYA->( FieldPos("BYA_IRCPPE") ) > 0
								cInCpPe := PLS101->BYA_IRCPPE
							Else
								cInCpPe := ""
							EndIf
							If BYA->( FieldPos("BYA_PRCPPE") ) > 0
								nInCpPe := PLS101->BYA_PRCPPE
							Else
								nInCpPe := 0.0
							EndIf
							////////////////////////////////////////
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Alimenta a matriz de sub contratos selecionados...                       Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					   		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Grupo empreasa                                                           Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If Ascan(aGrupos,{ |x| x[1] == BG9->BG9_CODIGO}) == 0
				
								aadd(aGrupos,{BG9->BG9_CODIGO,AllTrim(BG9->BG9_DESCRI),BG9->BG9_TIPO,0,cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,;
								lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv1,cInCpFx,nInCpFx,cInCpPe,nInCpPe})
							Endif 
			
					   		If Ascan(aContratos,{ |x| x[2] == BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON}) == 0
			   					aadd(aContratos,{BG9->BG9_CODIGO,BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON,0,cTipoAna,cConsTmp,nIndice,;
			   					cIndice,lIndVld,lProduto,lOpcional,lTaxa,lOnlyLook,cNivel,lFranquia,lZeraNiv2,cInCpFx,nInCpFx,cInCpPe,nInCpPe})
		 					Endif
							A101ADDSUB(cIndice, nIndice, cAnoMesInd, aSubCon, aErrosSub,;
							cTipoAna,cConsTmp,lIndVld,lProduto,lOpcional,lTaxa,cCodPla,cVerPla,;
							lOnlyLook,cNivel,lFranquia,lZeraNiv3,.T.,cInCpFx,nInCpFx,cInCpPe,nInCpPe)
							PLS101->( dbSkip() )
						Enddo
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Fecha a area de trabalho...                                              Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						PLS101->(DbCloseArea())
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Caso encontre parametro, abandona o FOR imediatamente...                 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						Exit
					Endif
				Next
				If ! lIndVld
					Loop
				Endif
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a quebra por subcontrato...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cQuebSub := TRBBQC->(BQC_SUBCON+BQC_VERSUB)
				While ! TRBBQC->(Eof()) .And. TRBBQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) == ;
					BG9->(BG9_CODINT+BG9_CODIGO)+cQuebCon+cQuebSub
					//BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
					///POSICIONA NO SUBCONBTRATO PARA VERIFICAR SE ESTA BLOQUEADO
					BQC->(Dbseek(xFilial("BQC")+BG9->(BG9_CODINT+BG9_CODIGO)+cQuebCon+cQuebSub ))
					If !Empty(BQC->BQC_CODBLO).And. Substr(dtos(BQC->BQC_DATBLO),1,6)<=(cAno+cMes) .And. !GetNewPar("MV_PLREABQ",.T.)
						TRBBQC->(Dbskip())
						Loop
					Endif
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Exibe mensagem de processamento...                                       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				
					/*/
					PLSA101VLD(cTipoAna,cConsTmp,nIndice,cIndice,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,cAno,;
					cMes,lProduto,lOpcional,lTaxa,cAnoMesInd,aUsuarios,aErrosUsr,aRetUsr,cNivel,lFranquia,lZeraNiv3)
					/*/
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Proximo familia.... da quebra...                                         Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					TRBBQC->(DbSkip())
				Enddo
				
				//Tratamento para atender a RN309 que determina um percentual mАximo de reajuste para contratos coletivos com menos de 30 vidas
				
			Enddo
			    //teste
			/*/
			If Len(aContratos) > 0 .and. aContratos[Len(aContratos),3] == 0
				aDel(aContratos,Len(aContratos))
				aSize(aContratos,Len(aContratos)-1)
			Endif
			/*/
		Enddo
		TRBBQC->(DbcloseArea())
	Endif
	BG9->(DbSkip())
Enddo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("BHW")
Return({aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,aErrosSub,aUsuarios,aErrosUsr,lDataOpc})
//
//эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
//╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
//╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
//╠╠ЁFuncao    Ё PLSA101CRE Ё Autor Ё RDS    Inicio em ------> Ё 08/10/2010 Ё╠╠
//╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
//╠╠ЁDescri┤└o Ё Verifica se ha cancelamento de reajuste por usuario        Ё╠╠
//╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
//╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
//ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
//
Function PLSA101CRE(aUsrs)

LOCAL nContUsrs
LOCAL cAnoMes
LOCAL aTesteCre := {}

If Type("M->BHW_ANOMES") <> "U"
	cAnoMes := M->BHW_ANOMES
Else
	cAnoMes := STRZERO(YEAR(dDataBase),4)+STRZERO(MONTH(dDataBase),2)
EndIf

For nContUsrs := 1 to Len(aUsrs)
	If PLSALIASEX("BYW")
		BYW->(DbSetOrder(1))//BYW_CODINT+BYW_CODEMP+BYW_MATRIC+BYW_TIPREG+DTOS(BYW_DATINI)
		If BYW->(DbSeek(xFilial("BYW")+SUBSTR(aUsrs[nContUsrs][13],1,16)))
			If  M->BHW_ANOMES	 >= (substr(Alltrim(DTOS(BYW->BYW_DATINI)),1,4)+substr(Alltrim(DTOS(BYW->BYW_DATINI)),5,2)) .AND. Empty(BYW->BYW_DATFIN) .Or. M->BHW_ANOMES <= (substr(Alltrim(DTOS(BYW->BYW_DATFIN)),1,4)+substr(Alltrim(DTOS(BYW->BYW_DATFIN)),5,2))
				aadd(aTesteCre,{"04","Usuario com Cancelamento Reajuste em Vigencia",SUBSTR(aUsrs[nContUsrs][13],1,16)})
			Endif
		Endif
	Endif
Next

Return(aTesteCre)

// Fim da Rotina
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101VLD Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Valida um reajuste de uma familia...                       Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
BA3 - Sempre posicionado
BG9 - Sempre posicionado

cTipoAna "1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
cConsTmp "1" - Incondicional / "2" - Familias com mais de 12 anos de plano / "3" - Usuarios com mais de 12 meses...
nIndice  Percentual de reajuste...
cIndice  indice de reajuste...

/*/
Function PLSA101VLD(cTipoAna,cConsTmp,nIndice,cIndice,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,cAno,cMes,lProduto,;
lOpcional,lTaxa,cAnoMesInd,aUsuarios,aErrosUsr,aRetUsr,cNivel,lFranquia,lZeraNiv,lSubVazio,cInCpFx,nInCpFx,cInCpPe,nInCpPe)

LOCAL nIndRet := 0
LOCAL nInReCpF := 0.0
LOCAL nInReCpP := 0.0
LOCAL cTipoIn
LOCAL cTpInCpF := ""
LOCAL cTpInCpP := ""
LOCAL lAplicar
LOCAL _dDataBas
LOCAL cMesRea
LOCAL nPos
LOCAL _dDatUsr
LOCAL cMesUsr
LOCAL lExistUsr := .F.
LOCAL cCodPla   := ''
LOCAL cVerPla   := ''
LOCAL lReaPla   := .F.
LOCAL lReaCop   := .F.
LOCAL lReaPlU   := .F.
LOCAL lReaCoU   := .F.
LOCAL cMReaCo   := ""

DEFAULT aUsuarios := {}
DEFAULT aErrosUsr := {}
DEFAULT aRetUsr	  := {}
DEFAULT cNivel	  := ''
DEFAULT lFranquia := .F.
DEFAULT lZeraNiv  := .F.
DEFAULT cInCpFx		:= ""
DEFAULT nInCpFx		:= 0.0
DEFAULT cInCpPe		:= ""
DEFAULT nInCpPe		:= 0.0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se ja foi reajustustada neste ano/mes...                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste 
	If BG9->BG9_TIPO == '2' .or. ( BG9->BG9_TIPO $ '1,3' .and. cConsTmp <> '3' ).and. !lSubVazio
		BHL->(DbSetOrder(3))
		If BHL->(DbSeek(xFilial("BHL")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno+cMes))
			aadd(aErrosFam,{"03","Familia ja resjustada neste ano/mes",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
			Return
		Endif
	Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe indice especifico para a familia...                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(BA3->BA3_INDREA).and. !lSubVazio
	cIndice := BA3->BA3_INDREA
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o o indice para reajuste da mensalidade...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRetInd := AnalisaIndice(cIndice,Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),nIndice,lZeraNiv)
nIndRet := aRetInd[1]
cTipoIn := aRetInd[2]

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o o indice para reajuste da coparticipacao tipo valor fixo...      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRetInd := AnalisaIndice(cInCpFx,Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),nInCpFx,.F.)
nInReCpF := aRetInd[1]
cTpInCpF := aRetInd[2]

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o o indice para reajuste da coparticipacao tipo percentual...      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRetInd := AnalisaIndice(cInCpPe,Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),nInCpPe,.F.)
nInReCpP := aRetInd[1]
cTpInCpP := aRetInd[2]

lReaPla := Iif(nIndRet == 0 .And. !lZeraNiv, .F., .T.)
lReaCop := Iif(nInReCpF == 0 .And. nInReCpP == 0, .F., .T.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Nao achei... retorno de erro...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lReaPla .and. !lReaCop
	aadd(aErrosFam,{"01","Nao foi encontrato parametrizacoes de reajuste",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
Else
	lAplicar  := .F.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Para considerar aniversario da familia...                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_dDataBas := BA3->BA3_DATCIV
	cMesRea   := BA3->BA3_MESREA
	If BA1->( FieldPos("BA1_MREACO") ) > 0
		cMReaCo   := BA3->BA3_MREACO
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Considera aniversario da familia e e esta no mes de aniversario...       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (BG9->BG9_TIPO == '1' .and. cConsTmp == "3") .or. (BG9->BG9_TIPO =='2' .and. cConsTmp $ "1|3" .and. GetNewPar("MV_PLREAPJ","2")=="1")
		//Usuarios incluidos a mais de 12 meses
		lAplicar := .T.
		
	Elseif cTipoAna == "1" .And. ( (lReaPla .And. cMesRea == cMes) .Or. (lReaCop .And. cMReaCo == cMes) )
		lAplicar := .T.
		
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Considerar aniversario do subcontrato...                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ElseIf cTipoAna == "2"
		lAplicar := .T.
		
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Trata regra se e para aplicar com base no tmp de permanencia no plano... Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lAplicar
		lAplicar := .F.
		If     cConsTmp == "1"
			lAplicar := .T.
			
		ElseIf cConsTmp == "2" .And. ;
			PLDIFANOS(PLSTRANO(_dDataBas,.T.),PLSTRMES(_dDataBas),cAno,cMes,"M") >= 12
			//Familias com mais de 12 meses
			lAplicar := .T.
			
		Elseif (BG9->BG9_TIPO == '1' .and. cConsTmp == "3") .or. (BG9->BG9_TIPO =='2' .and. cConsTmp == "1|3" .and. GetNewPar("MV_PLREAPJ","2")=="1")
			//Usuarios incluidos a mais de 12 meses
			lAplicar := .T.
			
		Endif
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acumula dados de reajuste...                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lAplicar
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se for PJ acumula por contrato e subcontrato...                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BG9->BG9_TIPO == "2"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula por contrato...                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nPos := Ascan(aContratos,{ |x| x[2] == BG9->BG9_CODIGO+BA3->BA3_CONEMP+BA3->BA3_VERCON})
			
			If nPos > 0
				aContratos[nPos,3] := aContratos[nPos,3] + 1
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Primeiro tenta encontrar a matriz com o produto especifico da familia... Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nPos := Ascan(aSubCon,{ |x| x[01] == BG9->BG9_CODIGO+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB .AND.;
			x[17] == BA3->BA3_CODPLA .and. x[18] == BA3->BA3_VERSAO})
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Caso nao encontra, tenta encontrar apenas pela chave do subcontrato...   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nPos == 0
				nPos := Ascan(aSubCon,{ |x| x[01] == BG9->BG9_CODIGO+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB .and.;
				x[17] == Space(Len(BA3->BA3_CODPLA)) .and.;
				x[18] == Space(Len(BA3->BA3_VERSAO))} )
			Endif
			
			If nPos > 0
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Incrementa quantidade de usuarios do subcontrato...     				 |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aSubCon[nPos,3] := aSubCon[nPos,3] + 1
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Alimenta variavel com o codigo e a versao do produto do subcontrato...   |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cCodPla := aSubCon[nPos,17]
				cVerPla := aSubCon[nPos,18]
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Pega o indice informado para o sub contrato x produto...				 |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If Empty(BA3->BA3_INDREA)
					aRetInd := AnalisaIndice(aSubCon[nPos,12],Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),aSubCon[nPos,11],aSubCon[nPos,22])
					nIndRet := aRetInd[1]
					cTipoIn := aRetInd[2]
				Endif

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Busca o o indice para reajuste da coparticipacao tipo valor fixo...      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aRetInd := AnalisaIndice(aSubCon[nPos,28],Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),aSubCon[nPos,25],.F.)
				nInReCpF := aRetInd[1]
				cTpInCpF := aRetInd[2]

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Busca o o indice para reajuste da coparticipacao tipo percentual...      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aRetInd := AnalisaIndice(aSubCon[nPos,32],Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),aSubCon[nPos,29],.F.)
				nInReCpP := aRetInd[1]
				cTpInCpP := aRetInd[2]
			Endif
			
			If GetNewPar("MV_PLREAPJ","2") =="1"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Para considerar aniversario da inclusao do usuario...                    Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				
				BA1->( dbSetorder(02) ) //VERIFICAR INDICE  13
				If BA1->( dbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
					While !BA1->( Eof() ) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ==;
						BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se usuario tem faixa especifica para ser reajustada...          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If (nPos := Ascan(aRetUsr, { |x| x[13] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) })) == 0
							BA1->( dbSkip() )
							Loop
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se usuario tem faixa especifica para ser reajustada...          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BDK->(DbSetOrder(1))
						If !BDK->( DbSeek(xFilial("BDK")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) )
							BA1->( dbSkip() )
							Loop
						Endif
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se usuario ja sofreu reajuste no periodo...                     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If PLSALIASEX("BHO")
							BHO->(DbSetOrder(1))
							If BHO->(DbSeek(xFilial("BHO")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+cAno+cMes))
								aadd(aErrosUsr,{"04","Usuario ja resjustado neste ano/mes",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)})
								BA1->( dbSkip() )
								Loop
							Endif
						Endif
						
						
						_dDatUsr  := BA1->BA1_DATINC
						If BA1->( FieldPos("BA1_MESREA") ) > 0 .And. !Empty(BA1->BA1_MESREA)
							cMesUsr   := BA1->BA1_MESREA
						Else
							cMesUsr   := StrZero(Month(BA1->BA1_DATINC),2)
						Endif
						
						If BA1->( FieldPos("BA1_MREACO") ) > 0 .And. !Empty(BA1->BA1_MREACO)
							cMesUCo   := BA1->BA1_MREACO
						Else
							cMesUCo   :=  BA1->BA1_MESREA
						Endif

						cMesRea   := cMesUsr
						cMReaCo   := cMesUCo


						If 	(cConsTmp $ "1|3" .and. (cMesUsr == cMes .Or. cMesUCo == cMes) .and.; // Usuarios com mais de 12 anos de plano OU incondicional
							PLDIFANOS(PLSTRANO(_dDatUsr,.T.),PLSTRMES(_dDatUsr),cAno,cMes,"M") >= 12) 

							lReaPlU := lReaPla
							lReaCoU := lReaCop

							If lReaPla .And. cMesUsr != cMes
								lReaPlU := .F.
								nIndRet := 0
								cTipoIn := ""
							EndIf

							If lReaCop .And. cMesUCo != cMes
								lReaCoU  := .F.
								nInReCpF := 0
								cTpInCpF := ""
								nInReCpP := 0
								cTpInCpP := ""
							EndIf
							
							aadd(aUsuarios,{BG9->BG9_CODIGO,;
							BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),;
							Str(nIndRet,12,4),;
							cTipoIn,;
							BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),;
							lProduto,;
							lOpcional,;
							lTaxa,;
							cIndice,;
							BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
							cTipoAna,;
							cConsTmp,;
							lFranquia,;
							BA3->BA3_TIPOUS,;
							BA1->BA1_CODPLA,;
							BA1->BA1_VERSAO,;
							nInReCpF,;
							Str(nInReCpF,12,4),;
							cTpInCpF,;
							cInCpFx,;
							nInReCpP,;
							Str(nInReCpP,12,4),;
							cTpInCpP,;
							cInCpPe,;
							lReaPlU,;
							lReaCoU})
							
							lExistUsr := .T.
						Endif
						BA1->(Dbskip())
					Enddo
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verificacoes e nivel de usuario...                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If 	BG9->BG9_TIPO == '1'
			BA1->( dbSetorder(02) )
			If BA1->( dbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
				While !BA1->( Eof() ) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ==;
					BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se usuario tem faixa especifica para ser reajustada...          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If (nPos := Ascan(aRetUsr, { |x| x[13] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) })) == 0
						BA1->( dbSkip() )
						Loop
					Endif
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se usuario tem faixa especifica para ser reajustada...          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BDK->(DbSetOrder(1))
					If !BDK->( DbSeek(xFilial("BDK")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) )
						BA1->( dbSkip() )
						Loop
					Endif
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se usuario ja sofreu reajuste no periodo...                     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If PLSALIASEX("BHO")
						BHO->(DbSetOrder(1))
						If BHO->(DbSeek(xFilial("BHO")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+cAno+cMes))
							aadd(aErrosUsr,{"04","Usuario ja resjustado neste ano/mes",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)})
							BA1->( dbSkip() )
							Loop
						Endif
					Endif
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Para considerar aniversario da inclusao do usuario...                    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					_dDatUsr  := BA1->BA1_DATINC
					If BA1->( FieldPos("BA1_MESREA") ) > 0 .And. !Empty(BA1->BA1_MESREA)
						cMesUsr   := BA1->BA1_MESREA
					Else
						cMesUsr   := StrZero(Month(BA1->BA1_DATINC),2)
					Endif

					If BA1->( FieldPos("BA1_MREACO") ) > 0 .And. !Empty(BA1->BA1_MREACO)
						cMesUCo   := BA1->BA1_MREACO
					Else
						cMesUCo   := BA1->BA1_MESREA
					Endif

					cMesRea   := cMesUsr
					cMReaCo   := cMesUCo

					If 	cConsTmp $ "1|3" .and. (cMesUsr == cMes .Or. cMesUCo == cMes) .and.;
						PLDIFANOS(PLSTRANO(_dDatUsr,.T.),PLSTRMES(_dDatUsr),cAno,cMes,"M") >= 12

						lReaPlU := lReaPla
						lReaCoU := lReaCop

						If lReaPla .And. cMesUsr != cMes
							lReaPlU := .F.
							nIndRet := 0
							cTipoIn := ""
						EndIf

						If lReaCop .And. cMesUCo != cMes
							lReaCoU  := .F.
							nInReCpF := 0
							cTpInCpF := ""
							nInReCpP := 0
							cTpInCpP := ""
						EndIf
						
						aadd(aUsuarios,{BG9->BG9_CODIGO,;
						BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),;
						Str(nIndRet,12,4),;
						cTipoIn,;
						BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),;
						lProduto,;
						lOpcional,;
						lTaxa,;
						cIndice,;
						BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
						cTipoAna,;
						cConsTmp,;
						lFranquia,;
						BA3->BA3_TIPOUS,;
						BA1->BA1_CODPLA,;
						BA1->BA1_VERSAO,;
						nInReCpF,;
						Str(nInReCpF,12,4),;
						cTpInCpF,;
						cInCpFx,;
						nInReCpP,;
						Str(nInReCpP,12,4),;
						cTpInCpP,;
						cInCpPe,;
						lReaPlU,;
						lReaCoU})
						
						lExistUsr := .T.
					Endif
					
					BA1->( dbSkip() )
				Enddo
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Nenhum usuario para reajustar, eh possivel que toda a familia ja tenha sido reajustada...  |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !lExistUsr
					BHL->(DbSetOrder(3))
					If BHL->(DbSeek(xFilial("BHL")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno+cMes))
						aadd(aErrosFam,{"03","Familia ja resjustada neste ano/mes",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Acumula por familia...                                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (BG9->BG9_TIPO == '2' .and. GetNewPar("MV_PLREAPJ","2")=="2")  .or.;
			( BG9->BG9_TIPO $ '1,2,3' .and. cConsTmp <> '3' ) .or.;
			lExistUsr

			If cTipoAna == "1" .And. lReaPla .And. cMesRea != cMes .And. nIndRet = 0 .And. (nIndRet == 0 .And. !lZeraNiv)
				lReaPla := .F.
				nIndRet := 0
				cTipoIn := ""
			EndIf

			If cTipoAna == "1" .And. lReaCop .And. cMReaCo != cMes
				lReaCop  := .F.
				nInReCpF := 0
				cTpInCpF := ""
				nInReCpP := 0
				cTpInCpP := ""
			EndIf
			
			aadd(aFamilias,{BG9->BG9_CODIGO,;
			BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),;
			Str(nIndRet,12,4),;
			cTipoIn + IIF(GetNewPar("MV_PLACUAJ",.F.) .AND. lAjuste," - Ajuste Acululativo",""),;
			BA3->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB),;
			lProduto,;
			lOpcional,;
			lTaxa,;
			cIndice,;
			cTipoAna,;
			cConsTmp,;
			cCodPla,;
			cVerPla,;
			lFranquia,;
			BA3->BA3_TIPOUS,;
			nInReCpF,;
			Str(nInReCpF,12,4),;
			cTpInCpF,;
			cInCpFx,;
			nInReCpP,;
			Str(nInReCpP,12,4),;
			cTpInCpP,;
			cInCpPe,;
			lReaPla,;
			lReaCop})
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula por grupo empresa...                                             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nPos := Ascan(aGrupos,{ |x| x[1] == BG9->BG9_CODIGO})
			If nPos > 0
				aGrupos[nPos,4] := aGrupos[nPos,4] + 1
			Endif
			
		Endif
	Endif
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina....                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101VL1 Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Validacao do campo BHW_ANOMES...             .             Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA101VL1(cAnoMes)
LOCAL cAno := Subs(cAnoMes,1,4)
LOCAL cMes := Subs(cAnoMes,5,2)
LOCAL lRet := .T.

If ! (cMes >= "01" .And. cMes <= "12")
	lRet := .F.
Endif

If Len(AllTrim(cAno)) < 4
	lRet := .F.
Endif

Return(lRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101SEL Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Analise retorno de reajustes e seleciona o que deve reaj.  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA101Sel(aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,aErrosSub,aUsuarios,aErrosUsr)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definve variaveis da rotina....                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL aButtons  := {}
LOCAL oDlg
LOCAL bOK       := { || If(PLSA101VGR(aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,aErrosSub,aErrosUsr),(nOpca := 1, oDlg:End()),(nOpca := 0)) }
LOCAL nOpca     := 0
LOCAL bCancel   := { || oDlg:End() }
LOCAL cCadastro := ''
LOCAL oTree
LOCAL nFor
LOCAL nFor2
LOCAL nFor3
LOCAL nFor4
LOCAL nUsr      := 0
LOCAL oBmp
LOCAL oSay
LOCAL oFolder
LOCAL oCriFam
LOCAL oCriGru
LOCAL oCriSub

LOCAL cCopart := ""
LOCAL cCpVlFx := ""
LOCAL cCpPerc := ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define texto para o dialog...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	cCadastro := "Confirmacao de Dados para Reajuste"
Else
	cCadastro := "Confirmacao de Dados para Ajuste"
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define folder...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//@ 017,300 Say oSay PROMPT " << Criticas >> " SIZE 100,010 OF oDlg PIXEL
If PLSALIASEX("BHO")
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS	"Grupo Empresa","SubContratos","Familias","Usuarios"
Else
	@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS	"Grupo Empresa","SubContratos","Familias","Usuarios"
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta browse de criticas dos grupos empresas...                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSBRWGEN(aErrosGrp,{ {"Cod.Critica","@C",30},{"Descricao","@C",200},{"Grupo Empresa","@C",70},;
{"Descricao","@C",200}  },oFolder:aDialogs[1],oCriGru,005,005,aPosObj[2][3]-10,aPosObj[2][4]-20)

PLSBRWGEN(aErrosSub,{ {"Cod.Critica","@C",30},{"Descricao","@C",200},{"Operadora","@C",40},;
{"Empresa","@C",40},{"Contrato","@C",40},{"Versao","@C",40},{"Subcontrato","@C",40},{"Versao","@C",40} },;
oFolder:aDialogs[2],oCriSub,005,005,aPosObj[2][3]-10,aPosObj[2][4]-20)

PLSBRWGEN(aErrosFam,{ {"Cod.Critica","@C",30},{"Descricao","@C",200},{"Matricula da Familia","@C",70} },;
oFolder:aDialogs[3],oCriFam,005,005,aPosObj[2][3]-10,aPosObj[2][4]-20)


If PLSALIASEX("BHO")
	PLSBRWGEN(aErrosUsr,{ {"Cod.Critica","@C",30},{"Descricao","@C",200},{"Matricula da Usuario","@C",70} },;
	oFolder:aDialogs[4],oCriFam,005,005,aPosObj[2][3]-10,aPosObj[2][4]-20)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define legendas...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 018,006 BITMAP oBmp RESNAME "BR_VERDE"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
@ 018,016 Say oSay PROMPT "Grupos Empresas" SIZE 100,010 OF oDlg PIXEL

@ 018,070 BITMAP oBmp RESNAME "BR_AMARELO"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
@ 018,080 Say oSay PROMPT "Contratos" SIZE 100,010 OF oDlg PIXEL

@ 018,115 BITMAP oBmp RESNAME "BR_AZUL"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
@ 018,125 Say oSay PROMPT "Subcontratos" SIZE 100,010 OF oDlg PIXEL

@ 018,170 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
@ 018,180 Say oSay PROMPT "Familias" SIZE 100,010 OF oDlg PIXEL

@ 018,225 BITMAP oBmp RESNAME "BR_LARANJA"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
@ 018,235 Say oSay PROMPT "Usuarios" SIZE 100,010 OF oDlg PIXEL

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Tree...                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oTree := DbTree():New(030,005,aPosObj[2][4],aPosObj[2][3],oDlg,nil,nil,.T.,nil)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Para cada grupo define arvore...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aGrupos)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё bypassa grupos empresas sem familias...                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aGrupos[nFor,4] == 0 .and. !(GetNewPar('MV_PLRSUBV',.F.))
		Loop
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define arvore para o grupo empresa...                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oTree:AddTree(aGrupos[nFor,1]+" - "+aGrupos[nFor,2]+" ("+AllTrim(str(aGrupos[nFor,4]))+" Familia(s) )"+Space(100),.T.,"BR_VERDE","BR_VERDE","BR_VERDE","BR_VERDE","GRP"+aGrupos[nFor,1])
	If aGrupos[nFor,3] == "1" //PF... exibe as familias...
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define arvore para a familia...                                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nFor2 := 1 To Len(aFamilias)
			If aFamilias[nFor2,1] == aGrupos[nFor,1]
				cCpVlFx := Iif(AllTrim(aFamilias[nFor2,17])!="0.0000", " (Copart Fixo: "+AllTrim(aFamilias[nFor2,17])+"%) ", "")
				cCpPerc := Iif(AllTrim(aFamilias[nFor2,21])!="0.0000", " (Copart Perc: "+AllTrim(aFamilias[nFor2,21])+"%) ", "")
				oTree:AddTree(Transform(aFamilias[nFor2,2],__cPictFam)+" Mensal.: "+AllTrim(aFamilias[nFor2,3])+"% - "+aFamilias[nFor2,4]+cCpVlFx+cCpPerc+Space(100),.T.,"BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","FAM"+aFamilias[nFor2,2])
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define arvore para o usuario..                                           Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				For nUsr := 1 To Len(aUsuarios)
					If aUsuarios[nUsr,2] == aFamilias[nFor2,2]
						cCpVlFx := Iif(AllTrim(aUsuarios[nUsr,18])!="0.0000", " (Copart Fixo: "+AllTrim(aUsuarios[nUsr,18])+"%) ", "")
						cCpPerc := Iif(AllTrim(aUsuarios[nUsr,22])!="0.0000", " (Copart Perc: "+AllTrim(aUsuarios[nUsr,22])+"%) ", "")
						oTree:AddTree(Transform(aUsuarios[nUsr,10],__cPictUsr)+" Mensal.: "+AllTrim(aUsuarios[nUsr,3])+"% - "+aUsuarios[nUsr,4]+cCpVlFx+cCpPerc+Space(100),.T.,"BR_LARANJA","BR_LARANJA","BR_LARANJA","BR_LARANJA","USR"+aUsuarios[nUsr,10])
						oTree:EndTree()
					Endif
				Next
				oTree:EndTree()
			Endif
		Next
	Else //PJ, exibir os contratos...
		For nFor2 := 1 To Len(aContratos)
			If aContratos[nFor2,1] == aGrupos[nFor,1]
				oTree:AddTree(TransForm(Subs(aContratos[nFor2,2],5,16),"@R !!!!!!!!!!!!-!!!")+ " ("+AllTrim(str(aContratos[nFor2,3]))+" Familia(s) )"+Space(100) ,.T.,"BR_AMARELO","BR_AMARELO","BR_AMARELO","BR_AMARELO","CON"+aContratos[nFor2,2])
				//subcontratos...
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё bypassa contratos sem familias...                                        Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If aContratos[nFor2,3] == 0 .and. !(GetNewPar('MV_PLRSUBV',.F.))
					Loop
				Endif
				
				For nFor3 := 1 To Len(aSubCon)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё bypassa subcontratos sem familias...                                     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If aSubCon[nFor3,2] == 0 .and. !(GetNewPar('MV_PLRSUBV',.F.))
						Loop
					Endif
					
					If aGrupos[nFor,1] == Subs(aSubCon[nFor3,1],1,4) .And. ;
						aContratos[nFor2,2] == Subs(aSubCon[nFor3,1],1,19)

						//cCopart := If(AllTrim(aSubCon[nFor3,25])!="0.0000" .Or. AllTrim(aSubCon[nFor3,28])!="0.0000", " + Coparticipacao", "")
						cCpVlFx := Iif(AllTrim(aSubCon[nFor3,26])!="0.0000", " + Copart Fixo: "+AllTrim(aSubCon[nFor3,26])+"% - "+aSubCon[nFor3,27]+" ", "")
						cCpPerc := Iif(AllTrim(aSubCon[nFor3,30])!="0.0000", " + Copart Perc: "+AllTrim(aSubCon[nFor3,30])+"% - "+aSubCon[nFor3,31]+" ", "")
						cCopart = cCpVlFx + cCpPerc
						
						If BYA->( FieldPos("BYA_CODPLA") ) > 0
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Monta texto para apresentacao dos subs separados pro produto...          Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If !Empty(aSubCon[nFor3,17])
								cTxtPro := " Produto "+aSubCon[nFor3,17]+"-"+aSubCon[nFor3,18]+cCopart
							Else
								cTxtPro := " Demais Produtos "+cCopart
							Endif
							
							oTree:AddTree(TransForm(Subs(aSubCon[nFor3,1],20,12),"@R !!!!!!!!!-!!!")+;
							cTxtPro+;
							"  ("+AllTrim(str(aSubCon[nFor3,3]))+" Familia(s) )"+Space(100),;
							.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+aContratos[nFor2,2])
							
						Else
							oTree:AddTree(TransForm(Subs(aSubCon[nFor3,1],21,12),"@R !!!!!!!!!-!!!")+cCopart+ " ("+AllTrim(str(aSubCon[nFor3,3]))+" Familia(s) )"+Space(100) ,.T.,"BR_AZUL","BR_AZUL","BR_AZUL","BR_AZUL","SUB"+aContratos[nFor2,2])
						Endif
						
						For nFor4 := 1 To Len(aFamilias)
							If aFamilias[nFor4,5] == aSubCon[nFor3,1]
								If 	aFamilias[nFor4,12] == aSubCon[nFor3,17] .and.;
									aFamilias[nFor4,13] == aSubCon[nFor3,18]

									cCpVlFx := Iif(AllTrim(aFamilias[nFor4,17])!="0.0000", " (Copart Fixo: "+AllTrim(aFamilias[nFor4,17])+"%) ", "")
									cCpPerc := Iif(AllTrim(aFamilias[nFor4,21])!="0.0000", " (Copart Perc: "+AllTrim(aFamilias[nFor4,21])+"%) ", "")
									
									oTree:AddTree(Transform(aFamilias[nFor4,2],__cPictFam)+" Mensal.: "+AllTrim(aFamilias[nFor4,3])+"% - "+AllTrim(aFamilias[nFor4,4])+cCpVlFx+cCpPerc+Space(100),.T.,"BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","FAM"+aFamilias[nFor4,2])
									For nUsr := 1 To Len(aUsuarios)
										If aUsuarios[nUsr,2] == aFamilias[nFor4,2]

											cCpVlFx := Iif(AllTrim(aUsuarios[nUsr,18])!="0.0000", " (Copart Fixo: "+AllTrim(aUsuarios[nUsr,18])+"%) ", "")
											cCpPerc := Iif(AllTrim(aUsuarios[nUsr,22])!="0.0000", " (Copart Perc: "+AllTrim(aUsuarios[nUsr,22])+"%) ", "")
											
											oTree:AddTree(Transform(aUsuarios[nUsr,10],__cPictUsr)+" Mensal.: "+AllTrim(aUsuarios[nUsr,3])+"% - "+AllTrim(aUsuarios[nUsr,4])+cCpVlFx+cCpPerc+Space(100),.T.,"BR_LARANJA","BR_LARANJA","BR_LARANJA","BR_LARANJA","USR"+aUsuarios[nUsr,10])
											oTree:EndTree()
										Endif
									Next
									oTree:EndTree()
								Endif
								
							Endif
						Next
						oTree:EndTree()
					Endif
					
				Next
				oTree:EndTree()
			Endif
		Next
	Endif
	oTree:EndTree()
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return({nOpca==K_OK})
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101ATU Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Atualiza os dados do reajuste na base de dados...          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA101ATU(cCodOpe,cAnoMes,cEmpDe,cEmpAte,cTipOus,cMsg01,cMsg02,cMsg03,lDisplay,;
aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,aErrosSub,;
cAnoMesInd, aUsuarios, aErrosUsr,lDataOpc)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis locais...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nFor
LOCAL cMatricFam
LOCAL cMatricUsr
LOCAL lProduto
LOCAL lOpcional
LOCAL lTaxa
LOCAL cCodRea
LOCAL nVlrRea
LOCAL cIndRea
LOCAL cSubCon
LOCAL lExistUsr := .F.
LOCAL nRecBDK	:= 0
LOCAL lAplica	:= .T.
LOCAL cCodAjs
LOCAL n_		:= 0
LOCAL lFranquia := .F.
LOCAL aRetPto   := {}
LOCAL lFaiSal	:= .F.
LOCAL cCodTit   := GetNewPar("MV_PLCDTIT","T")
LOCAL cTipReg   := PlGrauTit()
LOCAL aDatOPc 	:= {}
LOCAL lPls101Io := ExistBlock("PLS101IO")
LOCAL lPl101Fam := ExistBlock("PL101FAM")
LOCAL lPl101Sub	:= ExistBlock("PL101SUB")
LOCAL cChvB1BTab
LOCAL cChvB1BSub
LOCAL cChvB1GTab
LOCAL cChvB1GSub

LOCAL nCont		:= 0
LOCAL cInCpFx	:= ""
LOCAL nInCpFx	:= 0.0
LOCAL cInCpPe	:= ""
LOCAL nInCpPe	:= 0.0
LOCAL nVReCoF	:= 0.0
LOCAL nVReCoP	:= 0.0
LOCAL lReaPla	:= .T.
LOCAL lReaCop	:= .T.

DEFAULT lDataOpc:= .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё busca o proximo codigo do lote de reajuste...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lajuste
	cCodRea := PLSA625Cd("BHW_CODREA","BHW",1,"BHW_CODINT",cCodOpe)
Else
	cCodRea := PLSA625Cd("BHV_CODAJS","BHV",1,"BHV->(BHV_CODINT+BHV_CODREA)",cCodOpe+M->BHV_CODREA)
Endif

If ExistBlock("PL101ATU")
	aRetPto    := ExecBlock("PL101ATU",.F.,.F.,{aFamilias,aGrupos,aContratos,aSubCon})
	aFamilias  := aRetPto[1]
	aGrupos    := aRetPto[2]
	aContratos := aRetPto[3]
	aSubcon    := aRetPto[4]
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia transacao...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava cabecalho do lote de reajuste...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BHW->(RecLock("BHW",.T.))
	BHW->BHW_FILIAL  := xFilial("BHW")
	BHW->BHW_CODINT  := cCodOpe
	BHW->BHW_CODREA  := cCodRea
	BHW->BHW_ANOMES  := cAnoMes
	BHW->BHW_EMPDE   := cEmpDe
	BHW->BHW_EMPATE  := cEmpAte
	BHW->BHW_TIPOUS  := cTipOus
	BHW->BHW_MSG01   := cMsg01
	BHW->BHW_MSG02   := cMsg02
	BHW->BHW_MSG03   := cMsg03
	If BHW->(FieldPos("BHW_AMIND")) > 0
		BHW->BHW_AMIND := cAnoMesInd
	Endif
	BHW->(MsUnLock())
	
	cCodInt := BHW->BHW_CODINT
	cCodRea := BHW->BHW_CODREA
	cCodAjs := ''
Else
	BHV->(RecLock("BHV",.T.))
	BHV->BHV_FILIAL  := xFilial("BHV")
	BHV->BHV_CODINT  := cCodOpe
	BHV->BHV_CODREA  := M->BHV_CODREA
	BHV->BHV_CODAJS  := cCodRea
	BHV->BHV_ANOMES  := cAnoMes
	BHV->BHV_AMAJUS  := M->BHV_AMAJUS
	BHV->BHV_EMPDE   := cEmpDe
	BHV->BHV_EMPATE  := cEmpAte
	BHV->BHV_MSG01   := cMsg01
	BHV->BHV_MSG02   := cMsg02
	BHV->BHV_MSG03   := cMsg03
	If BHV->(FieldPos("BHV_AMIND")) > 0
		BHV->BHV_AMIND := cAnoMesInd
	Endif
	BHV->(MsUnLock())
	
	cCodInt := BHV->BHV_CODINT
	cCodRea := BHV->BHV_CODREA
	cCodAjs := BHV->BHV_CODAJS
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza os precos de todas as familias...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aFamilias)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados da familia atual...                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMatricFam := aFamilias[nFor,02]
	lProduto   := aFamilias[nFor,06]
	lOpcional  := aFamilias[nFor,07]
	lTaxa      := aFamilias[nFor,08]
	nIndice    := Val(aFamilias[nFor,03])
	cIndRea    := aFamilias[nFor,09]
	lFranquia  := aFamilias[nFor,14]
	cInCpFx	   := aFamilias[nFor,19]
	nInCpFx	   := aFamilias[nFor,16]
	lCopFix    := Iif(nInCpFx>0,.T.,.F.)
	cInCpPe	   := aFamilias[nFor,23]	
	nInCpPe	   := aFamilias[nFor,20]
	lCopPer    := Iif(nInCpPe>0,.T.,.F.)
	aDatOPc    := {}
	lReaPla    := aFamilias[nFor,24]
	lReaCop    := aFamilias[nFor,25]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona na familia...                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->(DbSetOrder(1))
	If BA3->(DbSeek(xFilial("BA3")+cMatricFam))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exibe mensagem informativa...                                            Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lDisplay
			IncProc("Analisando Familia... "+TransForm(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),__cPictFam))
			ProcessMessage()
		Endif
		
		BG9->(DbSetOrder(1))
		BG9->(DbSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a familia ja foi reajustada... Havera casos em que a familia Ё
		//Ё ja tera sido reajustada e agora so irei reajustar o usuario que acabou deЁ
		//Ё completar 12 meses de plano. Esta situacao so ocorre em PF quando eh     Ё
		//Ё selecionada a opcao para considerar o aniversari o da inclusao.           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		lAplica := .T.
		If BG9->BG9_TIPO == '1' .and. aFamilias[nFor][11] == '3'
			BHL->(DbSetOrder(3))
			If BHL->(DbSeek(xFilial("BHL")+cMatricFam+Subs(cAnoMes,1,4)+Subs(cAnoMes,5,2)))
				Aadd(aErrosFam,{"03","Familia ja resjustada neste ano/mes. Apenas os usuarios serao reajustados.",cMatricFam})
				lAplica := .F.
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Acumula dados do grupo empresa, contrato, subcontrato e familia...       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (lReaPla .And. (lProduto .Or. lOpcional .Or. lTaxa .Or. lFranquia)) .Or. (lReaCop .And. (lCopFix .Or. lCopPer))
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza arquivos de familias processadas no lote...                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BHL->(RecLock("BHL",.T.))
			BHL->BHL_FILIAL := xFilial("BHL")
			BHL->BHL_OPEREA := cCodInt
			BHL->BHL_CODREA := cCodRea
			If BHL->( FieldPos("BHL_CODAJS") ) > 0
				BHL->BHL_CODAJS := cCodAjs
			Endif
			BHL->BHL_CODOPE := BA3->BA3_CODINT
			BHL->BHL_CODEMP := BA3->BA3_CODEMP
			BHL->BHL_MATRIC := BA3->BA3_MATRIC
			BHL->BHL_CONEMP := BA3->BA3_CONEMP
			BHL->BHL_VERCON := BA3->BA3_VERCON
			BHL->BHL_SUBCON := BA3->BA3_SUBCON
			BHL->BHL_VERSUB := BA3->BA3_VERSUB
			BHL->BHL_ANOREA := Subs(cAnoMes,1,4)
			BHL->BHL_MESREA := Subs(cAnoMes,5,2)
			BHL->(MsUnLock())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza arquivos de grupos empresas atualizados no lote...              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !lAjuste
				BPD->(DbSetOrder(1))
				BPD->(DbSeek(xFilial("BPD")+cCodint+cCodRea+BA3->BA3_CODEMP))
				
			Else
				BPD->(DbSetOrder(3))
				BPD->(DbSeek(xFilial("BPD")+cCodint+cCodRea+cCodAjs+BA3->BA3_CODEMP))
			Endif
			
			If !BPD->( Found() )
				BPD->(RecLock("BPD",.T.))
				BPD->BPD_FILIAL := xFilial("BPD")
				BPD->BPD_OPEREA := cCodInt
				BPD->BPD_CODREA := cCodRea
				If BPD->( FieldPos("BPD_CODAJS") ) > 0
					BPD->BPD_CODAJS := cCodAjs
				Endif
				BPD->BPD_CODEMP := BA3->BA3_CODEMP
				BPD->BPD_DESEMP := BG9->BG9_DESCRI
				BPD->BPD_TIPO   := BG9->BG9_TIPO
				BPD->BPD_NFAM   := 1
				BPD->BPD_ANOREA := Subs(cAnoMes,1,4)
				BPD->BPD_MESREA := Subs(cAnoMes,5,2)
				BPD->(MsUnLock())
			Else
				BPD->(RecLock("BPD",.F.))
				BPD->BPD_NFAM   := BPD->BPD_NFAM + 1
				BPD->(MsUnLock())
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se for PJ atualiza contrato e subcontrato...                             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BA3->BA3_TIPOUS == "2"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza arquivos de contratos...                                        Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !lAjuste
					BPE->(DbSetOrder(1))
					BPE->(DbSeek(xFilial("BPE")+cCodInt+cCodRea+BA3->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
				Else
					BPE->(DbSetOrder(2))
					BPE->(DbSeek(xFilial("BPE")+cCodInt+cCodRea+cCodAjs+BA3->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
				Endif
				
				If ! BPE->( Found() )
					BG9->(DbSetOrder(1))
					BG9->(DbSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
					
					BPE->(RecLock("BPE",.T.))
					BPE->BPE_FILIAL := xFilial("BPE")
					BPE->BPE_OPEREA := cCodInt
					BPE->BPE_CODREA := cCodRea
					If BPE->( FieldPos("BPE_CODAJS") ) > 0
						BPE->BPE_CODAJS := cCodAjs
					Endif
					BPE->BPE_CODEMP := BA3->BA3_CODEMP
					BPE->BPE_DESEMP := BG9->BG9_DESCRI
					BPE->BPE_CONEMP := BA3->BA3_CONEMP
					BPE->BPE_VERCON := BA3->BA3_VERCON
					BPE->BPE_NFAM   := 1
					BPE->BPE_ANOREA := Subs(cAnoMes,1,4)
					BPE->BPE_MESREA := Subs(cAnoMes,5,2)
					BPE->(MsUnLock())
				Else
					BPE->(RecLock("BPE",.F.))
					BPE->BPE_NFAM   := BPE->BPE_NFAM + 1
					BPE->(MsUnLock())
				Endif
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza arquivos de subcontratos...                                     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !lAjuste
					BPF->(DbSetOrder(1))
					BPF->(DbSeek(xFilial("BPF")+cCodInt+cCodRea+BA3->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
				Else
					BPF->(DbSetOrder(3))
					BPF->(DbSeek(xFilial("BPF")+cCodInt+cCodRea+cCodAjs+BA3->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
				Endif
				
				If !BPF->( Found() )
					BG9->(DbSetOrder(1))
					BG9->(DbSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
					
					BT6->(DbSetOrder(1))
					BT6->(DbSeek(xFilial("BT6")+cCodInt+BA3->(BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
					
					BPF->(RecLock("BPF",.T.))
					BPF->BPF_FILIAL := xFilial("BPF")
					BPF->BPF_OPEREA := cCodInt
					BPF->BPF_CODREA := cCodRea
					If BPF->( FieldPos("BPF_CODAJS") ) > 0
						BPF->BPF_CODAJS := cCodAjs
					Endif
					BPF->BPF_CODEMP := BA3->BA3_CODEMP
					BPF->BPF_DESEMP := BG9->BG9_DESCRI
					BPF->BPF_CONEMP := BA3->BA3_CONEMP
					BPF->BPF_VERCON := BA3->BA3_VERCON
					BPF->BPF_SUBCON := BA3->BA3_SUBCON
					BPF->BPF_VERSUB := BA3->BA3_VERSUB
					BPF->BPF_ANOREA := Subs(cAnoMes,1,4)
					BPF->BPF_MESREA := Subs(cAnoMes,5,2)
					BPF->BPF_NFAM   := 1
					BPF->BPF_CODPRO := BT6->BT6_CODPRO
					BPF->BPF_INDREA := nIndice
					BPF->(MsUnLock())
				Else
					BPF->(RecLock("BPF",.F.))
					BPF->BPF_NFAM   := BPF->BPF_NFAM + 1
					BPF->(MsUnLock())
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Consistencia feita na familia...                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !lAplica
			Loop
		Endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reajusta franquia no nivel de familia...                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lReaPla .And. lFranquia
			For n_ := 1 To Len(aFranquia)
				// Apenas alias referente a familia...
				If aFranquia[n_][5] <> '2'
					Loop
				Endif
				
				cAlias := aFranquia[n_][1]
				
				// Seleciona area
				dbSelectArea(cAlias)
				&(cAlias)->( dbSetorder(aFranquia[n_][2]) )
				
				// Pesquisa chave
				&(cAlias)->( msSeek(xFilial(cAlias)+cMatricFam) )
				
				// Precessa registros...
				While !(&(cAlias)->(Eof())) .and. &((cAlias)->(aFranquia[n_][3])) == xFilial(cAlias)+cMatricFam
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Apura o valor com o reajuste...                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cCpoFra := cAlias+"->"+aFranquia[n_][4]
					cCpoAms := cAlias+"_ANOMES"
					cCpoVat := cAlias+"_VLRANT"
					
					nVlrRea := IIF(lArredonda,Round(&(cCpoFra) + ((&(cCpoFra)*nIndice)/100),2), NoRound(&(cCpoFra) + ((&(cCpoFra)*nIndice)/100),2) )
					
					// Grava historico
					If nVlrRea > 0
						B0B->( Reclock("B0B", .T.) )
							B0B->B0B_FILIAL := xFilial("B0B")
							B0B->B0B_ALIAS	:= cAlias
							B0B->B0B_CODREA	:= cCodRea
							B0B->B0B_CODINT	:= cCodInt
							B0B->B0B_CODEMP	:= &(cAlias+"->"+cAlias+"_CODEMP")
							B0B->B0B_MATRIC := &(cAlias+"->"+cAlias+"_MATRIC")
							B0B->B0B_VLRANT	:= &(cCpoFra)
							B0B->B0B_VLRREA	:= nVlrRea
							B0B->B0B_PERREA	:= nIndice
							B0B->B0B_INDREA	:= cIndRea
							B0B->B0B_DATREA	:= dDataBase
							B0B->B0B_CODPRO := BA3->BA3_CODPLA
							B0B->B0B_VERPRO := BA3->BA3_VERSAO
						B0B->( msUnlock() )
						
						// Reajusta registro recorrente
						Reclock(cAlias, .F.)
						
						// Grava ano/mes do reajuste.
						If &(cAlias)->(Fieldpos(cCpoAms)) > 0
							&(cCpoAms) := cAnoMes
						Endif
						
						// Grava o valor atual no campo valor anterior antes de reajustar.
						If &(cAlias)->(Fieldpos(cCpoVat)) > 0
							&(cCpoVat) := &(cCpoFra)
						Endif
						
						// Aplica o reajuste ao valor da franquia.
						&(cCpoFra) := nVlrRea
						&(cAlias)->( msUnlock() )
					Endif
					&(cAlias)->( dbSkip() )
				Enddo
			Next
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Reajusta franquia no nivel do usuario...                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BA1->( msSeek(xFilial("BA1")+cMatricFam) )
				While !BA1->( Eof() ) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatricFam
					For n_ := 1 To Len(aFranquia)
						// Apenas alias referente a familia...
						If aFranquia[n_][5] <> '3'
							Loop
						Endif
						
						cAlias := aFranquia[n_][1]
						
						// Seleciona area
						dbSelectArea(cAlias)
						&(cAlias)->( dbSetorder(aFranquia[n_][2]) )
						
						// Pesquisa chave
						&(cAlias)->( msSeek(xFilial(cAlias)+cMatricFam+BA1->BA1_TIPREG) )
						
						// Precessa registros...
						While !(&(cAlias)->(Eof())) .and. &((cAlias)->(aFranquia[n_][3])) == xFilial(cAlias)+cMatricFam+BA1->BA1_TIPREG
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Apura o valor com o reajuste...                                          Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							cCpoFra := cAlias+"->"+aFranquia[n_][4]
							cCpoAms := cAlias+"_ANOMES"
							cCpoVat := cAlias+"_VLRANT"
							
							nVlrRea := IIf(lArredonda,Round(&(cCpoFra) + ((&(cCpoFra)*nIndice)/100),2),NoRound(&(cCpoFra) + ((&(cCpoFra)*nIndice)/100),2))
							
							If nVlrRea > 0
								// Grava historico
								B0B->( Reclock("B0B", .T.) )
									B0B->B0B_FILIAL := xFilial("B0B")
									B0B->B0B_ALIAS	:= cAlias
									B0B->B0B_CODREA	:= cCodRea
									B0B->B0B_CODINT	:= cCodInt
									B0B->B0B_CODEMP	:= &(cAlias+"->"+cAlias+"_CODEMP")
									B0B->B0B_MATRIC := &(cAlias+"->"+cAlias+"_MATRIC")
									B0B->B0B_TIPREG := &(cAlias+"->"+cAlias+"_TIPREG")
									B0B->B0B_VLRANT	:= &(cCpoFra)
									B0B->B0B_VLRREA	:= nVlrRea
									B0B->B0B_PERREA	:= nIndice
									B0B->B0B_INDREA	:= cIndRea
									B0B->B0B_DATREA	:= dDataBase
									If !Empty(BA1->BA1_CODPLA)
										B0B->B0B_CODPLA := BA1->BA1_CODPLA
										B0B->B0B_VERSAO := BA1->BA1_VERSAO
									Else
										B0B->B0B_CODPRO := BA3->BA3_CODPLA
										B0B->B0B_VERPRO := BA3->BA3_VERSAO
									Endif
								B0B->( msUnlock() )
								
								// Reajusta registro recorrente
								Reclock(cAlias, .F.)
								
								// Grava ano/mes do reajuste.
								If &(cAlias)->(Fieldpos(cCpoAms)) > 0
									&(cCpoAms) := cAnoMes
								Endif
								
								// Grava o valor atual no campo valor anterior antes de reajustar.
								If &(cAlias)->(Fieldpos(cCpoVat)) > 0
									&(cCpoVat) := &(cCpoFra)
								Endif
								
								// Aplica o reajuste ao valor da franquia.
								&(cCpoFra) := nVlrRea
								&(cAlias)->( msUnlock() )
							Endif
							
							&(cAlias)->( dbSkip() )
						Enddo
					Next
					
					BA1->( dbSkip() )
				Enddo
			Endif
		Endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reajusta Copart. no nivel de familia...                                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lReaCop .And. (lCopFix .Or. lCopPer)
			PL101ReaCo(cCodRea, cAnoMes, '2', cMatricFam, nInCpFx, nInCpPe)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Reajusta franquia no nivel do usuario...                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BA1->( msSeek(xFilial("BA1")+cMatricFam) )
				While !BA1->( Eof() ) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatricFam
					PL101ReaCo(cCodRea, cAnoMes, '3', cMatricFam, nInCpFx, nInCpPe)
					BA1->( dbSkip() )
				Enddo
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Para cada familia se inicia o processo de reajuste de precos... MENSALID Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lReaPla .And. (lProduto .Or. lOpcional .Or. lTaxa)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza faixa salarial da familia (se existir)...                       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If PLSALIASEX("B1C") .and. PLSALIASEX("BYP") .And. lProduto
				B1C->(DbSetOrder(1))
				If B1C->(DbSeek(xFilial("B1C")+cMatricFam))
					While ! B1C->(Eof()) .And. B1C->(B1C_FILIAL+B1C_CODOPE+B1C_CODEMP+B1C_MATRIC) == xFilial("B1C")+cMatricFam
						lFaiSal := .T.
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Apura o valor com o reajuste...                                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nVlrRea := IIf(lArredonda,Round(B1C->B1C_VALOR + ((B1C->B1C_VALOR*nIndice)/100),2),NoRound(B1C->B1C_VALOR + ((B1C->B1C_VALOR*nIndice)/100),2))
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Joga para o historico o valor atual desta faixa...                       Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BYP->(RecLock("BYP",.T.))
						BYP->BYP_FILIAL := xFilial("BYP")
						BYP->BYP_OPEREA := cCodInt
						BYP->BYP_CODREA := cCodRea
						If BYP->( FieldPos("BYP_CODAJS") ) > 0
							BYP->BYP_CODAJS := cCodAjs
						Endif
						BYP->BYP_CODOPE := BA3->BA3_CODINT
						BYP->BYP_CODEMP := BA3->BA3_CODEMP
						BYP->BYP_MATRIC := BA3->BA3_MATRIC
						BYP->BYP_CODFAI := B1C->B1C_CODFAI
						BYP->BYP_VLSLIN := B1C->B1C_VLSLIN
						BYP->BYP_VLSLFN := B1C->B1C_VLSLFN
						BYP->BYP_VLRANT := B1C->B1C_VALOR
						BYP->BYP_VLRREA := nVlrRea
						BYP->BYP_DATREA := dDataBase
						BYP->BYP_DATANT := STOD(BHW->BHW_ANOMES+"01")
						BYP->BYP_INDREA := cIndRea
						BYP->BYP_PERREA := nIndice
						BYP->BYP_CODFOR := B1C->B1C_CODFOR
						BYP->(MsUnLock())
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						B1C->(RecLock("B1C",.F.))
						B1C->B1C_VLRANT := B1C->B1C_VALOR
						B1C->B1C_ANOMES := cAnoMes
						B1C->B1C_VALOR  := nVlrRea
						B1C->(MsUnLock())
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Acessa proximo registro...                                               Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						B1C->(DbSkip())
					Enddo
				Endif
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza faixa etaria da familia...                                      Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBU->(DbSetOrder(1))
			If BBU->(DbSeek(xFilial("BBU")+cMatricFam)) .And. lProduto
				While ! BBU->( Eof() ) .And. BBU->(BBU_FILIAL+BBU_CODOPE+BBU_CODEMP+BBU_MATRIC) == xFilial("BBU")+cMatricFam
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Apura o valor com o reajuste...                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nVlrRea := IIf(lArredonda,Round(BBU->BBU_VALFAI + ((BBU->BBU_VALFAI*nIndice)/100),2),NoRound(BBU->BBU_VALFAI + ((BBU->BBU_VALFAI*nIndice)/100),2))
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Joga para o historico o valor atual desta faixa...                       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BP7->(RecLock("BP7",.T.))
					BP7->BP7_FILIAL := xFilial("BP7")
					BP7->BP7_OPEREA := cCodInt
					BP7->BP7_CODREA := cCodRea
					If BP7->( FieldPos("BP7_CODAJS") ) > 0
						BP7->BP7_CODAJS := cCodAjs
					Endif
					BP7->BP7_CODOPE := BA3->BA3_CODINT
					BP7->BP7_CODEMP := BA3->BA3_CODEMP
					BP7->BP7_MATRIC := BA3->BA3_MATRIC
					BP7->BP7_CODFAI := BBU->BBU_CODFAI
					BP7->BP7_IDAINI := BBU->BBU_IDAINI
					BP7->BP7_IDAFIN := BBU->BBU_IDAFIN
					BP7->BP7_VLRANT := BBU->BBU_VALFAI
					BP7->BP7_VLRREA := nVlrRea
					BP7->BP7_DATREA := dDataBase
					BP7->BP7_INDREA := cIndRea
					BP7->BP7_PERREA := nIndice
					BP7->BP7_CODFOR := BBU->BBU_CODFOR
					BP7->(MsUnLock())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BBU->(RecLock("BBU",.F.))
					BBU->BBU_VLRANT := BBU->BBU_VALFAI
					BBU->BBU_ANOMES := cAnoMes
					BBU->BBU_REJAPL := nIndice
					BBU->BBU_PERREJ := dDatabase
					BBU->BBU_VALFAI := nVlrRea
					BBU->(MsUnLock())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Acessa proximo registro...                                               Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BBU->(DbSkip())
				Enddo
			Else
				If lProduto .And. !lFaiSal
					aadd(aErrosFam,{"02","Nao foi encontrada a faixa etaria",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza por quantidade de beneficiАrios da familia (se existir)...                       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If PLSALIASEX("B1H")  .And. PLSALIASEX("BPQ") .AND. lProduto
				B1H->(DbSetOrder(1))
				If B1H->(DbSeek(xFilial("B1H")+cMatricFam)) .AND. B1H->B1H_QTDFIN > 0
					While ! B1H->(Eof()) .And. B1H->(B1H_FILIAL+B1H_CODOPE+B1H_CODEMP+B1H_MATRIC) == xFilial("B1H")+cMatricFam .AND. ;
						B1H->B1H_QTDFIN > 0
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Apura o valor com o reajuste...                                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nVlrRea := IIf(lArredonda,Round(B1H->B1H_VALOR + ((B1H->B1H_VALOR*nIndice)/100),2),NoRound(B1H->B1H_VALOR + ((B1H->B1H_VALOR*nIndice)/100),2))
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Joga para o historico o valor atual desta faixa...                       Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BPQ->(RecLock("BPQ",.T.))
						BPQ->BPQ_FILIAL := xFilial("BPQ")
						BPQ->BPQ_OPEREA := cCodInt
						BPQ->BPQ_CODREA := cCodRea
						If BPQ->( FieldPos("BPQ_CODAJS") ) > 0
							BPQ->BPQ_CODAJS := cCodAjs
						Endif
						BPQ->BPQ_CODOPE := BA3->BA3_CODINT
						BPQ->BPQ_CODEMP := BA3->BA3_CODEMP
						BPQ->BPQ_MATRIC := BA3->BA3_MATRIC
						BPQ->BPQ_CODFAI := B1H->B1H_CODFAI
						BPQ->BPQ_QTDINI := B1H->B1H_QTDINI
						BPQ->BPQ_QTDFIN := B1H->B1H_QTDFIN
						BPQ->BPQ_VLRANT := B1H->B1H_VALOR
						BPQ->BPQ_CODSEQ := B1H->B1H_CODSEQ
						BPQ->BPQ_VLRREA := nVlrRea
						BPQ->BPQ_DATREA := dDataBase
						BPQ->BPQ_DATANT := STOD(BHW->BHW_ANOMES+"01")
						BPQ->BPQ_INDREA := cIndRea
						BPQ->BPQ_PERREA := nIndice
						BPQ->BPQ_CODFOR := B1H->B1H_CODFOR
						BPQ->(MsUnLock())
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						B1H->(RecLock("B1H",.F.))
						B1H->B1H_VLRANT := BPQ->BPQ_VLRANT
						B1H->B1H_ANOMES := cAnoMes
						B1H->B1H_VALOR  := nVlrRea
						B1H->(MsUnLock())
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Acessa proximo registro...                                               Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						B1H->(DbSkip())
					EndDo
				EndIf
			EndIf
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza faixa etaria do usuario (se existir)...                         Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ((BG9->BG9_TIPO == '1' .and. Len(aUsuarios) == 0) .or. (BG9->BG9_TIPO == '2' .and. GetNewPar("MV_PLREAPJ","2")=="2"))  .And. lProduto
				
				BDK->(DbSetOrder(1))
				If BDK->(DbSeek(xFilial("BDK")+cMatricFam))
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Grava recno do arquivo de faixas especificas do usuario...               Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					//nRecBDK := BDK->( Recno() )
					nRecBA3 := BA3->( Recno() )
					nRecBA1 := BA1->( Recno() )
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё A faixa sera processa por usuarios...                                    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BA1->( dbSetorder(02) )
					BA1->( MsSeek(xFilial("BA1")+cMatricFam) )
					
					While !BA1->( Eof() ) .and. BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) == cMatricFam
						
						lExistUsr := .F.
						
						If Len(aErrosUsr) > 0 .And.;
							aScan(aErrosUsr,{|x| x[3] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) .And. x[1] == "04" }) > 0
							BA1->(dbSkip())
							Loop
						EndIf
						
						If BG9->BG9_TIPO == '2'
							If !Empty(BA1->BA1_CODPLA) .and. !Empty(BA1->BA1_VERSAO)
								// Primeiro busco pelo produto especifico do usuario...
								If (nPos := Ascan(aSubCon, {| x | 	x[01] == BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) .and.;
									x[17] == BA1->BA1_CODPLA .and.;
									x[18] == BA1->BA1_VERSAO }) ) > 0
									cIndice := aSubCon[nPos][12]
									nIndice := aSubCon[nPos][11]
									
									// Se nao houver parametro especifico para o produto do usuario, procuro por um parametro generico para todos os produtos...
								Elseif (nPos := Ascan(aSubCon, {| x | 	x[01] == BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) .and.;
									Alltrim(x[17]) == '' .and.;
									Alltrim(x[18]) == '' }) ) > 0
									cIndice := aSubCon[nPos][12]
									nIndice := aSubCon[nPos][02]
								Else
									aadd(aErrosUsr,{"05","NЦo foi encontrado parБmetro de reajuste para o produto do usuАrio.",cMatricFam+BA1->BA1_TIPREG})
									BA1->( dbSkip() )
									Loop
								Endif
							Endif
						Endif
						
						BDK->(DbSetOrder(1))
						If BDK->(DbSeek(xFilial("BDK")+cMatricFam+BA1->BA1_TIPREG))
							
							nRecBDK := BDK->( Recno() )
							
							While ! BDK->(Eof()) .And. BDK->(BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG) == xFilial("BDK")+cMatricFam+BA1->BA1_TIPREG
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Confirma existencia da faixa especifica do usuario...                    Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								lExistUsr := .T.
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Apura o valor com o reajuste...                                          Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								nVlrRea := IIf(lArredonda,Round(BDK->BDK_VALOR + ((BDK->BDK_VALOR*nIndice)/100),2),NoRound(BDK->BDK_VALOR + ((BDK->BDK_VALOR*nIndice)/100),2))
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Joga para o historico o valor atual desta faixa...                       Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BYB->(RecLock("BYB",.T.))
								BYB->BYB_FILIAL := xFilial("BYB")
								BYB->BYB_OPEREA := cCodInt
								BYB->BYB_CODREA := cCodRea
								If BYB->( FieldPos("BYB_CODAJS") ) > 0
									BYB->BYB_CODAJS := cCodAjs
								Endif
								BYB->BYB_CODOPE := BA3->BA3_CODINT
								BYB->BYB_CODEMP := BA3->BA3_CODEMP
								BYB->BYB_MATRIC := BA3->BA3_MATRIC
								BYB->BYB_TIPREG := BDK->BDK_TIPREG
								BYB->BYB_CODFAI := BDK->BDK_CODFAI
								BYB->BYB_IDAINI := BDK->BDK_IDAINI
								BYB->BYB_IDAFIN := BDK->BDK_IDAFIN
								BYB->BYB_VLRANT := BDK->BDK_VALOR
								BYB->BYB_VLRREA := nVlrRea
								BYB->BYB_DATREA := dDataBase
								BYB->BYB_INDREA := cIndRea
								BYB->BYB_PERREA := nIndice
								BYB->(MsUnLock())
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BDK->(RecLock("BDK",.F.))
								BDK->BDK_VLRANT := BDK->BDK_VALOR
								BDK->BDK_ANOMES := cAnoMes
								BDK->BDK_VALOR  := nVlrRea
								BDK->(MsUnLock())
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Acessa proximo registro...                                               Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BDK->(DbSkip())
							Enddo
						Endif
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza arquivos de usuarios processados no lote...                     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lExistUsr
							If PLSALIASEX("BHO")
								BDK->( dbGoto(nRecBDK) )
								
								BHO->(RecLock("BHO",.T.))
								BHO->BHO_FILIAL := xFilial("BHO")
								BHO->BHO_OPEREA := cCodInt
								BHO->BHO_CODREA := cCodRea
								If BHO->( FieldPos("BHO_CODAJS") ) > 0
									BHO->BHO_CODAJS := cCodAjs
								Endif
								BHO->BHO_CODOPE := BDK->BDK_CODINT
								BHO->BHO_CODEMP := BDK->BDK_CODEMP
								BHO->BHO_MATRIC := BDK->BDK_MATRIC
								BHO->BHO_TIPREG := BDK->BDK_TIPREG
								BHO->BHO_CONEMP := BA3->BA3_CONEMP
								BHO->BHO_VERCON := BA3->BA3_VERCON
								BHO->BHO_SUBCON := BA3->BA3_SUBCON
								BHO->BHO_VERSUB := BA3->BA3_VERSUB
								BHO->BHO_ANOREA := Subs(cAnoMes,1,4)
								BHO->BHO_MESREA := Subs(cAnoMes,5,2)
								BHO->(MsUnLock())
							Endif
						Endif
						
						BA1->( dbSkip() )
					Enddo
				Endif
			Endif
			
			BA1->( dbSetorder(02) )
			BA1->( MsSeek(xFilial("BA1")+cMatricFam) )
			
			While !BA1->( Eof() ) .and. BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) == cMatricFam
				If Len(aErrosUsr) > 0 .And.;
					aScan(aErrosUsr,{|x| x[3] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) .And. x[1] == "04" }) > 0
					BDK->(DbSetOrder(1))
					If ! BDK->(DbSeek(xFilial("BDK")+cMatricFam+BA1->BA1_TIPREG))
						nCodFai:= 0
						BBU->(DbSetOrder(1))
						If BBU->(DbSeek(xFilial("BBU")+cMatricFam))
							While ! BBU->( Eof() ) .And. BBU->(BBU_FILIAL+BBU_CODOPE+BBU_CODEMP+BBU_MATRIC) == xFilial("BBU")+cMatricFam .And.;
								!Empty(BBU->BBU_VLRANT)
								nCodFai ++
								BDK->( RecLock("BDK", .T.) )
								BDK->BDK_FILIAL := xFilial("BDK")
								BDK->BDK_CODFAI := StrZero(nCodFai,3)
								BDK->BDK_IDAINI := BBU->BBU_IDAINI
								BDK->BDK_IDAFIN := BBU->BBU_IDAFIN
								BDK->BDK_VALOR  := BBU->BBU_VLRANT
								BDK->BDK_CODINT := BA1->BA1_CODINT
								BDK->BDK_CODEMP := BA1->BA1_CODEMP
								BDK->BDK_MATRIC := BA1->BA1_MATRIC
								BDK->BDK_TIPREG := BA1->BA1_TIPREG
								BDK->BDK_VLRANT := 0
								BDK->(MsUnLock())
								BBU->( dbSkip() )
							EndDo
						Endif
					EndIf
				EndIf
				BA1->(dbSkip())
			EndDo
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza valores de adesao da familia...                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lTaxa
				BRX->(DbSetOrder(1))
				If BRX->(DbSeek(xFilial("BRX")+cMatricFam))
					While ! BRX->(Eof()) .And. BRX->(BRX_FILIAL+BRX_CODOPE+BRX_CODEMP+BRX_MATRIC) == xFilial("BRX")+cMatricFam
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Apura o valor com o reajuste...                                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nVlrRea := IIf(lArredonda,Round(BRX->BRX_VLRADE + ((BRX->BRX_VLRADE*nIndice)/100),2),NoRound(BRX->BRX_VLRADE + ((BRX->BRX_VLRADE*nIndice)/100),2))
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Joga para o historico o valor atual desta faixa...                       Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BYG->(RecLock("BYG",.T.))
						BYG->BYG_FILIAL := xFilial("BYG")
						BYG->BYG_OPEREA := cCodInt
						BYG->BYG_CODREA := cCodRea
						If BYG->( FieldPos("BYG_CODAJS") ) > 0
							BYG->BYG_CODAJS := cCodAjs
						Endif
						BYG->BYG_CODOPE := BA3->BA3_CODINT
						BYG->BYG_CODEMP := BA3->BA3_CODEMP
						BYG->BYG_MATRIC := BA3->BA3_MATRIC
						BYG->BYG_CODFAI := BRX->BRX_CODFAI
						BYG->BYG_IDAINI := BRX->BRX_IDAINI
						BYG->BYG_IDAFIN := BRX->BRX_IDAFIN
						BYG->BYG_VLRANT := BRX->BRX_VLRADE
						BYG->BYG_VLRREA := nVlrRea
						BYG->BYG_DATREA := dDataBase
						BYG->BYG_INDREA := cIndRea
						BYG->BYG_PERREA := nIndice
						BYG->BYG_CODFOR := BRX->BRX_CODFOR
						BYG->(MsUnLock())
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BRX->(RecLock("BRX",.F.))
						BRX->BRX_VLRANT := BRX->BRX_VLRADE
						BRX->BRX_ANOMES := cAnoMes
						BRX->BRX_VLRADE := nVlrRea
						BRX->(MsUnLock())
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Acessa proximo registro...                                               Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BRX->(DbSkip())
					Enddo
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza opcionais da familia...                                         Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lOpcional
				
				BF1->(DbSetOrder(1))
				If BF1->(DbSeek(xFilial("BF1")+cMatricFam))
					While ! BF1->(Eof()) .And. BF1->(BF1_FILIAL+BF1_CODINT+BF1_CODEMP+BF1_MATRIC) == xFilial("BF1")+cMatricFam
						If lDataOpc .And. !Empty(BF1->BF1_DATBAS)
							If !PLDIFANOS(PLSTRANO(BF1->BF1_DATBAS,.T.),PLSTRMES(BF1->BF1_DATBAS),Subs(cAnoMes,1,4),Subs(cAnoMes,5,2),"M") >= 12
								BF1->(dbSkip())
								Loop
							Endif
						Endif
						
						BBY->(DbSetOrder(1))
						If BBY->(DbSeek(xFilial("BBY")+cMatricFam+BF1->BF1_CODPRO))
							While ! BBY->(Eof()) .And. BBY->(BBY_FILIAL+BBY_CODOPE+BBY_CODEMP+BBY_MATRIC+BBY_CODOPC) == xFilial("BBY")+cMatricFam+BF1->BF1_CODPRO
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Criacao de ponto de entrada para manipular indices de reajustes de opc.  Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If lPls101Io
									aRetPto := ExecBlock("PLS101IO",.F.,.F.,{cMatricFam,nIndice,cIndRea,cAnoMes})
									nIndEsp := aRetPto[1]
									cIndEsp := aRetPto[2]
								Else
									nIndEsp := nIndice
									cIndEsp := cIndRea
								Endif
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Apura o valor com o reajuste...                                          Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								nVlrRea := IIf(lArredonda,Round(BBY->BBY_VALFAI + ((BBY->BBY_VALFAI*nIndEsp)/100),2),NoRound(BBY->BBY_VALFAI + ((BBY->BBY_VALFAI*nIndEsp)/100),2))
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Joga para o historico o valor atual desta faixa...                       Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BYH->(RecLock("BYH",.T.))
								BYH->BYH_FILIAL := xFilial("BYH")
								BYH->BYH_OPEREA := cCodInt
								BYH->BYH_CODREA := cCodRea
								If BYH->( FieldPos("BYH_CODAJS") ) > 0
									BYH->BYH_CODAJS := cCodAjs
								Endif
								BYH->BYH_CODOPE := BA3->BA3_CODINT
								BYH->BYH_CODEMP := BA3->BA3_CODEMP
								BYH->BYH_MATRIC := BA3->BA3_MATRIC
								BYH->BYH_CODFAI := BBY->BBY_CODFAI
								BYH->BYH_IDAINI := BBY->BBY_IDAINI
								BYH->BYH_IDAFIN := BBY->BBY_IDAFIN
								BYH->BYH_VLRANT := BBY->BBY_VALFAI
								BYH->BYH_VLRREA := nVlrRea
								BYH->BYH_DATREA := dDataBase
								BYH->BYH_INDREA := cIndEsp
								BYH->BYH_PERREA := nIndEsp
								BYH->BYH_CODFOR := BBY->BBY_CODFOR
								BYH->BYH_CODOPC := BBY->BBY_CODOPC
								BYH->BYH_VEROPC := BBY->BBY_VEROPC
								BYH->(MsUnLock())
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BBY->(RecLock("BBY",.F.))
								BBY->BBY_VLRANT := BBY->BBY_VALFAI
								BBY->BBY_ANOMES := cAnoMes
								BBY->BBY_VALFAI := nVlrRea
								BBY->(MsUnLock())
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Acessa proximo registro...                                               Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BBY->(DbSkip())
							Enddo
						Endif
						
						BF1->(DbSkip())
					Enddo
				Endif
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza opcionais dos usuarios...                                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BA1->( dbSetorder(02) )
				BA1->( MsSeek(xFilial("BA1")+cMatricFam) )
				While !BA1->( Eof() ) .and. BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) == cMatricFam
					//BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG+BF4_CODPRO
					BF4->(DbSetOrder(1))
					If BF4->(DbSeek(xFilial("BF4")+BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
						While ! BF4->(Eof()) .And. BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG) == xFilial("BF4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
							// se for pessoa fisica
							If BG9->BG9_TIPO =='1'.and. BF4->BF4_TIPREG <> cTipReg .and. lDataOpc  // pessoa fisica
								If Len(aDatOpc) > 0
									nposdat:= ascan(aDatOpc,{ |x| Alltrim(x[1])==BF4->BF4_CODPRO+BF4->BF4_VERSAO})
									If nPosdat> 0
										ddatbas:=aDatOpc[nPosdat,2]
										If !Empty(ddatbas)
											
											If !PLDIFANOS(PLSTRANO(ddatbas,.T.),PLSTRMES(ddatbas),Subs(cAnoMes,1,4),Subs(cAnoMes,5,2),"M") >= 12
												BF4->(dbSkip())
												Loop
											Endif
											
										Endif
									Else
										BF4->(dbSkip())
										Loop
										
									Endif
								Else
									BF4->(dbSkip())
									Loop
									
								Endif
							ElseIf lDataOpc
								If BF4->BF4_TIPREG == cTipReg
									aadd(aDatOPc,{BF4->BF4_CODPRO+BF4->BF4_VERSAO, BF4->BF4_DATBAS})
								Endif
								
								If !Empty(BF4->BF4_DATBAS)
									
									If !PLDIFANOS(PLSTRANO(BF4->BF4_DATBAS,.T.),PLSTRMES(BF4->BF4_DATBAS),Subs(cAnoMes,1,4),Subs(cAnoMes,5,2),"M") >= 12
										BF4->(dbSkip())
										Loop
									Endif
									
								Endif
							Endif
							
							BZX->(DbSetOrder(1))//BZX_FILIAL+BZX_CODOPE+BZX_CODEMP+BZX_MATRIC+BZX_TIPREG+BZX_CODOPC+BZX_VEROPC+BZX_CODFOR+BZX_CODFAI
							If BZX->(DbSeek(xFilial("BZX")+cMatricFam+BF4->(BF4_TIPREG+BF4_CODPRO)))
								While ! BZX->(Eof()) .And. BZX->(BZX_FILIAL+BZX_CODOPE+BZX_CODEMP+BZX_MATRIC+BZX_TIPREG+BZX_CODOPC) ==;
									xFilial("BZX")+cMatricFam+BF4->(BF4_TIPREG+BF4_CODPRO)
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Criacao de ponto de entrada para manipular indices de reajustes de opc.  Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									If lPls101Io
										aRetPto := ExecBlock("PLS101IO",.F.,.F.,{cMatricFam,nIndice,cIndRea,cAnoMes})
										nIndEsp := aRetPto[1]
										cIndEsp := aRetPto[2]
									Else
										nIndEsp := nIndice
										cIndEsp := cIndRea
									Endif
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Apura o valor com o reajuste...                                          Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									nVlrRea := IIf(lArredonda,Round(BZX->BZX_VALFAI + ((BZX->BZX_VALFAI*nIndEsp)/100),2),NoRound(BZX->BZX_VALFAI + ((BZX->BZX_VALFAI*nIndEsp)/100),2))
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Joga para o historico o valor atual desta faixa...                       Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									BYI->(RecLock("BYI",.T.))
									BYI->BYI_FILIAL := xFilial("BYI")
									BYI->BYI_OPEREA := cCodInt
									BYI->BYI_CODREA := cCodRea
									If BYI->( FieldPos("BYI_CODAJS") ) > 0
										BYI->BYI_CODAJS := cCodAjs
									Endif
									BYI->BYI_CODOPE := BA3->BA3_CODINT
									BYI->BYI_CODEMP := BA3->BA3_CODEMP
									BYI->BYI_MATRIC := BA3->BA3_MATRIC
									BYI->BYI_TIPREG := BZX->BZX_TIPREG
									BYI->BYI_CODFAI := BZX->BZX_CODFAI
									BYI->BYI_IDAINI := BZX->BZX_IDAINI
									BYI->BYI_IDAFIN := BZX->BZX_IDAFIN
									BYI->BYI_VLRANT := BZX->BZX_VALFAI
									BYI->BYI_VLRREA := nVlrRea
									BYI->BYI_DATREA := dDataBase
									BYI->BYI_INDREA := cIndEsp
									BYI->BYI_PERREA := nIndEsp
									BYI->BYI_CODFOR := BZX->BZX_CODFOR
									BYI->BYI_CODOPC := BZX->BZX_CODOPC
									BYI->BYI_VEROPC := BZX->BZX_VEROPC
									BYI->(MsUnLock())
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									BZX->(RecLock("BZX",.F.))
									BZX->BZX_VLRANT := BZX->BZX_VALFAI
									BZX->BZX_ANOMES := cAnoMes
									BZX->BZX_VALFAI := nVlrRea
									BZX->(MsUnLock())
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Acessa proximo registro...                                               Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									BZX->(DbSkip())
								Enddo
							Endif
							BF4->(dbSkip())
						Enddo
					Endif
					BA1->(dbSkip())
				Enddo
			Endif
		Endif
		
		If lPl101Fam
			ExecBlock("PL101FAM",.F.,.F.,{nIndice, cIndRea, cMatricFam} )
		Endif
	Else
		aadd(aErrosFam,{"03","Nao foi encontrada a familia na base de dados",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
	Endif
	lFaiSal := .F.
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza os precos dos usuarios selecionados...                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aUsuarios)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta dados da familia atual...                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMatricUsr := aUsuarios[nFor,10]
	lProduto   := aUsuarios[nFor,06]
	lOpcional  := aUsuarios[nFor,07]
	lTaxa      := aUsuarios[nFor,08]
	nIndice    := Val(aUsuarios[nFor,03])
	cIndRea    := aUsuarios[nFor,09]
	lFranquia  := aUsuarios[nFor,13]
	
	BDK->(DbSetOrder(1))
	BA1->(DbSetOrder(2))
	If BDK->(msSeek(xFilial("BDK")+cMatricUsr))
		
		lExistUsr := .F.
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona o usuario...                                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BA1->( msSeek(xFilial("BA1")+cMatricUsr) )
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava recno do arquivo de faixas especificas do usuario...               Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nRecBDK := BDK->( Recno() )
			
			While ! BDK->(Eof()) .And. BDK->(BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG) == xFilial("BDK")+cMatricUsr
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Confirma existencia da faixa especifica do usuario...                    Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				lExistUsr := .T.
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := IIf(lArredonda,Round(BDK->BDK_VALOR + ((BDK->BDK_VALOR*nIndice)/100),2),NoRound(BDK->BDK_VALOR + ((BDK->BDK_VALOR*nIndice)/100),2))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BYB->(RecLock("BYB",.T.))
				BYB->BYB_FILIAL := xFilial("BYB")
				BYB->BYB_OPEREA := cCodInt
				BYB->BYB_CODREA := cCodRea
				If BYB->( FieldPos("BYB_CODAJS") ) > 0
					BYB->BYB_CODAJS := cCodAjs
				Endif
				BYB->BYB_CODOPE := BDK->BDK_CODINT
				BYB->BYB_CODEMP := BDK->BDK_CODEMP
				BYB->BYB_MATRIC := BDK->BDK_MATRIC
				BYB->BYB_TIPREG := BDK->BDK_TIPREG
				BYB->BYB_CODFAI := BDK->BDK_CODFAI
				BYB->BYB_IDAINI := BDK->BDK_IDAINI
				BYB->BYB_IDAFIN := BDK->BDK_IDAFIN
				BYB->BYB_VLRANT := BDK->BDK_VALOR
				BYB->BYB_VLRREA := nVlrRea
				BYB->BYB_DATREA := dDataBase
				BYB->BYB_INDREA := cIndRea
				BYB->BYB_PERREA := nIndice
				BYB->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BDK->(RecLock("BDK",.F.))
				BDK->BDK_VLRANT := BDK->BDK_VALOR
				BDK->BDK_ANOMES := cAnoMes
				BDK->BDK_VALOR := nVlrRea
				BDK->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BDK->(DbSkip())
			Enddo
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza arquivos de usuarios processados no lote...                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lExistUsr
				BDK->( dbGoto(nRecBDK) )
				If PLSALIASEX("BHO")
					BHO->(RecLock("BHO",.T.))
					BHO->BHO_FILIAL := xFilial("BHO")
					BHO->BHO_OPEREA := cCodInt
					BHO->BHO_CODREA := cCodRea
					If BHO->( FieldPos("BHO_CODAJS") ) > 0
						BHO->BHO_CODAJS := cCodAjs
					Endif
					BHO->BHO_CODOPE := BDK->BDK_CODINT
					BHO->BHO_CODEMP := BDK->BDK_CODEMP
					BHO->BHO_MATRIC := BDK->BDK_MATRIC
					BHO->BHO_TIPREG := BDK->BDK_TIPREG
					BHO->BHO_CONEMP := BA3->BA3_CONEMP
					BHO->BHO_VERCON := BA3->BA3_VERCON
					BHO->BHO_SUBCON := BA3->BA3_SUBCON
					BHO->BHO_VERSUB := BA3->BA3_VERSUB
					BHO->BHO_ANOREA := Subs(cAnoMes,1,4)
					BHO->BHO_MESREA := Subs(cAnoMes,5,2)
					BHO->(MsUnLock())
				Endif
			Endif
		Else
			aadd(aErrosFam,{"04","Nao foi encontrado o usuario na base de dados",cMatricUsr})
		Endif
	Else
		aadd(aErrosFam,{"04","Nao foi encontrado faixa especifica do usuario",cMatricUsr})
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza os precos do subcontrato x produto...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aSubCon)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza faixa etaria do subcontrato...                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSubCon   := cCodOpe+aSubCon[nFor,1]
	lProduto  := aSubCon[nFor,14]
	lOpcional := aSubCon[nFor,15]
	lTaxa     := aSubCon[nFor,16]
	nIndice	  := aSubCon[nFor,02]
	cIndRea	  := aSubCon[nFor,12]
	lFranquia := aSubCon[nFor,21]
	cInCpFx	   := aSubCon[nFor,28]
	nInCpFx	   := aSubCon[nFor,25]
	lCopFix    := Iif(nInCpFx>0,.T.,.F.)
	cInCpPe	   := aSubCon[nFor,32]
	nInCpPe	   := aSubCon[nFor,29]
	lCopPer    := Iif(nInCpPe>0,.T.,.F.)
	lReaPla    := aSubCon[nFor,33]
	lReaCop    := aSubCon[nFor,34]
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza arquivos de grupos empresas atualizados no lote...              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BG9->(DbSetOrder(1))
	BG9->(DbSeek(xFilial("BG9")+cCodInt+Substr(aSubCon[nFor,1],1,4)))
	If !lAjuste
		BPD->(DbSetOrder(1))
		BPD->(DbSeek(xFilial("BPD")+cCodint+cCodRea+Substr(aSubCon[nFor,1],1,4)))
				
	Else
		BPD->(DbSetOrder(3))
		BPD->(DbSeek(xFilial("BPD")+cCodint+cCodRea+cCodAjs+Substr(aSubCon[nFor,1],1,4)))
	Endif
			
	If !BPD->( Found() )
		BPD->(RecLock("BPD",.T.))
		BPD->BPD_FILIAL := xFilial("BPD")
		BPD->BPD_OPEREA := cCodInt
		BPD->BPD_CODREA := cCodRea
		If BPD->( FieldPos("BPD_CODAJS") ) > 0
			BPD->BPD_CODAJS := cCodAjs
		Endif
		BPD->BPD_CODEMP := Substr(aSubCon[nFor,1],1,4)
		BPD->BPD_DESEMP := BG9->BG9_DESCRI
		BPD->BPD_TIPO   := BG9->BG9_TIPO
		BPD->BPD_ANOREA := Subs(cAnoMes,1,4)
		BPD->BPD_MESREA := Subs(cAnoMes,5,2)
		BPD->(MsUnLock())
	Endif
			
   	If !lAjuste
		BPE->(DbSetOrder(1))
		BPE->(DbSeek(xFilial("BPE")+cCodInt+cCodRea+aSubCon[nFor,4]+aSubCon[nFor,5]+aSubCon[nFor,6]))
	Else
		BPE->(DbSetOrder(2))
		BPE->(DbSeek(xFilial("BPE")+cCodInt+cCodRea+cCodAjs+aSubCon[nFor,4]+aSubCon[nFor,5]+aSubCon[nFor,6]))
	Endif
				
	If ! BPE->( Found() )
		BG9->(DbSetOrder(1))
		BG9->(DbSeek(xFilial("BG9")+cCodInt+aSubCon[nFor,4]))
					
		BPE->(RecLock("BPE",.T.))
		BPE->BPE_FILIAL := xFilial("BPE")
		BPE->BPE_OPEREA := cCodInt
		BPE->BPE_CODREA := cCodRea
		If BPE->( FieldPos("BPE_CODAJS") ) > 0
			BPE->BPE_CODAJS := cCodAjs
		Endif
		BPE->BPE_CODEMP := aSubCon[nFor,4]
		BPE->BPE_DESEMP := BG9->BG9_DESCRI
		BPE->BPE_CONEMP := aSubCon[nFor,5]
		BPE->BPE_VERCON := aSubCon[nFor,6]
		BPE->BPE_ANOREA := Subs(cAnoMes,1,4)
		BPE->BPE_MESREA := Subs(cAnoMes,5,2)
		BPE->(MsUnLock())
		
	Endif
				
	If !lAjuste
		BPF->(DbSetOrder(1))
		BPF->(DbSeek(xFilial("BPF")+cCodInt+cCodRea+aSubCon[nFor,1]))
	Else
		BPF->(DbSetOrder(3))
		BPF->(DbSeek(xFilial("BPF")+cCodInt+cCodRea+cCodAjs+aSubCon[nFor,1]))
	Endif
				
	If !BPF->( Found() )
	
					
		BT6->(DbSetOrder(1))
		BT6->(DbSeek(xFilial("BT6")+cCodInt+aSubCon[nFor,1]))
					
		BPF->(RecLock("BPF",.T.))
		BPF->BPF_FILIAL := xFilial("BPF")
		BPF->BPF_OPEREA := cCodInt
		BPF->BPF_CODREA := cCodRea
		If BPF->( FieldPos("BPF_CODAJS") ) > 0
			BPF->BPF_CODAJS := cCodAjs
		Endif
		BPF->BPF_CODEMP := aSubCon[nFor,4]
		BPF->BPF_DESEMP := BG9->BG9_DESCRI
		BPF->BPF_CONEMP := aSubCon[nFor,5]
		BPF->BPF_VERCON := aSubCon[nFor,6]
		BPF->BPF_SUBCON := aSubCon[nFor,7]
		BPF->BPF_VERSUB := aSubCon[nFor,8]
		BPF->BPF_ANOREA := Subs(cAnoMes,1,4)
		BPF->BPF_MESREA := Subs(cAnoMes,5,2)
		BPF->BPF_CODPRO := BT6->BT6_CODPRO
		BPF->BPF_INDREA := nIndice
		BPF->(MsUnLock())
	Endif
	
	
	If lReaPla .And. lProduto
		BTN->(DbSetOrder(3))
		If BTN->(DbSeek(xFilial("BTN")+cSubCon))
			While ! BTN->(Eof()) .And. BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB) == ;
				xFilial("BTN")+cSubCon
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Reajuste apenas as faixas do produto contido na linha da matriz de sub contrato... |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If 	!Empty(aSubCon[nFor,17]) .and.;
					!(BTN->BTN_CODPRO == aSubCon[nFor,17] .and. BTN->BTN_VERPRO == aSubCon[nFor,18])
					BTN->( dbSkip() )
					Loop
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё O produto da matriz esta em branco, eh a regra para todos os demais produtos...    |
					//Ё Tenho que testar se a faixa pertence a um produto que esta na matriz ou se ja foi  |
					//Ё reajustada no periodo...                                                           |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Elseif Empty(aSubCon[nFor,17])
					If ( nPos := Ascan(aSubCon, {|x| cCodOpe + x[1] == BTN->(BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB) .and.;
						x[17] == BTN->BTN_CODPRO .and. x[18] == BTN->BTN_VERPRO}) ) > 0
						BTN->( dbSkip() )
						Loop
					Endif
				Endif
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := IIf(lArredonda,Round(BTN->BTN_VALFAI + ((BTN->BTN_VALFAI*nIndice)/100),2),NoRound(BTN->BTN_VALFAI + ((BTN->BTN_VALFAI*nIndice)/100),2))
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BYC->(RecLock("BYC",.T.))
				BYC->BYC_FILIAL := xFilial("BYC")
				BYC->BYC_OPEREA := cCodInt
				BYC->BYC_CODREA := cCodRea
				If BYC->( FieldPos("BYC_CODAJS") ) > 0
					BYC->BYC_CODAJS := cCodAjs
				Endif
				BYC->BYC_CODOPE := SUBS(BTN->BTN_CODIGO,1,4)
				BYC->BYC_CODEMP := SUBS(BTN->BTN_CODIGO,5,4)
				BYC->BYC_CONEMP := BTN->BTN_NUMCON
				BYC->BYC_VERCON := BTN->BTN_VERCON
				BYC->BYC_SUBCON := BTN->BTN_SUBCON
				BYC->BYC_VERSUB := BTN->BTN_VERSUB
				BYC->BYC_CODPRO := BTN->BTN_CODPRO
				BYC->BYC_VERPRO := BTN->BTN_VERPRO
				BYC->BYC_CODFAI := BTN->BTN_CODFAI
				BYC->BYC_IDAINI := BTN->BTN_IDAINI
				BYC->BYC_IDAFIN := BTN->BTN_IDAFIN
				BYC->BYC_VLRANT := BTN->BTN_VALFAI
				BYC->BYC_VLRREA := nVlrRea
				BYC->BYC_DATREA := dDataBase
				BYC->BYC_INDREA := cIndRea
				BYC->BYC_PERREA := nIndice
				BYC->BYC_CODFOR := BTN->BTN_CODFOR
				BYC->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BTN->(RecLock("BTN",.F.))
				BTN->BTN_VLRANT := BTN->BTN_VALFAI
				BTN->BTN_ANOMES := cAnoMes
				BTN->BTN_VALFAI := nVlrRea
				BTN->BTN_REJAPL := nIndice
				BTN->BTN_PERREJ := dDataBase
				BTN->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BTN->(DbSkip())
			Enddo
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza valores de adesao do subcontrato...                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lReaPla .And. lTaxa
		BR6->(DbSetOrder(1))
		If BR6->(DbSeek(xFilial("BR6")+cSubCon))
			While ! BR6->(Eof()) .And. BR6->(BR6_FILIAL+BR6_CODIGO+BR6_NUMCON+BR6_VERCON+BR6_SUBCON+BR6_VERSUB) == ;
				xFilial("BR6")+cSubCon
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := IIf(lArredonda,Round(BR6->BR6_VLRADE + ((BR6->BR6_VLRADE*nIndice)/100),2),NoRound(BR6->BR6_VLRADE + ((BR6->BR6_VLRADE*nIndice)/100),2))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BYE->(RecLock("BYE",.T.))
				BYE->BYE_FILIAL := xFilial("BYE")
				BYE->BYE_OPEREA := cCodInt
				BYE->BYE_CODREA := cCodRea
				If BYE->( FieldPos("BYE_CODAJS") ) > 0
					BYE->BYE_CODAJS := cCodAjs
				Endif
				BYE->BYE_CODOPE := SUBS(BR6->BR6_CODIGO,1,4)
				BYE->BYE_CODEMP := SUBS(BR6->BR6_CODIGO,5,4)
				BYE->BYE_CONEMP := BR6->BR6_NUMCON
				BYE->BYE_VERCON := BR6->BR6_VERCON
				BYE->BYE_SUBCON := BR6->BR6_SUBCON
				BYE->BYE_VERSUB := BR6->BR6_VERSUB
				BYE->BYE_CODPRO := BR6->BR6_CODPRO
				BYE->BYE_VERPRO := BR6->BR6_VERPRO
				BYE->BYE_CODFAI := BR6->BR6_CODFAI
				BYE->BYE_IDAINI := BR6->BR6_IDAINI
				BYE->BYE_IDAFIN := BR6->BR6_IDAFIN
				BYE->BYE_VLRANT := BR6->BR6_VLRADE
				BYE->BYE_VLRREA := nVlrRea
				BYE->BYE_DATREA := dDataBase
				BYE->BYE_INDREA := cIndRea
				BYE->BYE_PERREA := nIndice
				BYE->BYE_CODFOR := BR6->BR6_CODFOR
				BYE->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BR6->(RecLock("BR6",.F.))
				BR6->BR6_VLRANT := BR6->BR6_VLRADE
				BR6->BR6_ANOMES := cAnoMes
				BR6->BR6_VLRADE := nVlrRea
				BR6->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BR6->(DbSkip())
			Enddo
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza valores de opcionais do subcontrato...                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lReaPla .And. lOpcional
		BBX->(DbSetOrder(1))
		If BBX->(DbSeek(xFilial("BBX")+cSubCon))
			While ! BBX->(Eof()) .And. BBX->(BBX_FILIAL+BBX_CODIGO+BBX_NUMCON+BBX_VERCON+BBX_SUBCON+BBX_VERSUB) == ;
				xFilial("BBX")+cSubCon
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lPls101Io
					aRetPto := ExecBlock("PLS101IO",.F.,.F.,{cMatricFam,nIndice,cIndRea,cAnoMes})
					nIndEsp := aRetPto[1]
					cIndEsp := aRetPto[2]
				Else
					nIndEsp := nIndice
					cIndEsp := cIndRea
				Endif
				
				nVlrRea := IIf(lArredonda,Round(BBX->BBX_VALFAI + ((BBX->BBX_VALFAI*nIndEsp)/100),2),Round(BBX->BBX_VALFAI + ((BBX->BBX_VALFAI*nIndEsp)/100),2))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BYF->(RecLock("BYF",.T.))
				BYF->BYF_FILIAL := xFilial("BYF")
				BYF->BYF_OPEREA := cCodInt
				BYF->BYF_CODREA := cCodRea
				BYF->BYF_CODOPE := cCodInt
				If BYF->( FieldPos("BYF_CODAJS") ) > 0
					BYF->BYF_CODAJS := cCodAjs
				Endif
				BYF->BYF_CODEMP := SUBS(BBX->BBX_CODIGO,5,4)
				BYF->BYF_CONEMP := BBX->BBX_NUMCON
				BYF->BYF_VERCON := BBX->BBX_VERCON
				BYF->BYF_SUBCON := BBX->BBX_SUBCON
				BYF->BYF_VERSUB := BBX->BBX_VERSUB
				BYF->BYF_CODPRO := BBX->BBX_CODPRO
				BYF->BYF_VERPRO := BBX->BBX_VERPRO
				BYF->BYF_CODFAI := BBX->BBX_CODFAI
				BYF->BYF_IDAINI := BBX->BBX_IDAINI
				BYF->BYF_IDAFIN := BBX->BBX_IDAFIN
				BYF->BYF_VLRANT := BBX->BBX_VALFAI
				BYF->BYF_VLRREA := nVlrRea
				BYF->BYF_DATREA := dDataBase
				BYF->BYF_INDREA := cIndEsp
				BYF->BYF_PERREA := nIndEsp
				BYF->BYF_CODFOR := BBX->BBX_CODFOR
				BYF->BYF_CODOPC := BBX->BBX_CODOPC
				BYF->BYF_VEROPC := BBX->BBX_VEROPC
				BYF->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBX->(RecLock("BBX",.F.))
				BBX->BBX_VLRANT := BBX->BBX_VALFAI
				BBX->BBX_ANOMES := cAnoMes
				BBX->BBX_VALFAI := nVlrRea
				BBX->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBX->(DbSkip())
			Enddo
		Endif
	Endif
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza faixa salarial do Subcontrato (se existir)...                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If PLSALIASEX("B1B") .and. PLSALIASEX("BPR") .And. lProduto .And. lReaPla

		If Empty(aSubCon[nFor][17])
			cChvB1BTab := "B1B->(B1B_FILIAL+B1B_CODIGO+B1B_NUMCON+B1B_VERCON+B1B_SUBCON+B1B_VERSUB)"
			cChvB1BSub := cCodInt+aSubCon[nFor][4]+aSubCon[nFor][5]+aSubCon[nFor][6]+aSubCon[nFor][7]+aSubCon[nFor][8]
		Else
			cChvB1BTab := "B1B->(B1B_FILIAL+B1B_CODIGO+B1B_NUMCON+B1B_VERCON+B1B_SUBCON+B1B_VERSUB+B1B_CODPRO+B1B_VERPRO)"
			cChvB1BSub := cCodInt+aSubCon[nFor][4]+aSubCon[nFor][5]+aSubCon[nFor][6]+aSubCon[nFor][7]+aSubCon[nFor][8]+aSubCon[nFor][17]+aSubCon[nFor][18] 
		EndIf

		B1B->(DbSetOrder(1))
		If	B1B->(DbSeek(xFilial("B1B")+cChvB1BSub))
			
			While ! B1B->(Eof()) .And. &(cChvB1BTab) == xFilial("B1B")+cChvB1BSub
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := IIf(lArredonda,Round(B1B->B1B_VALOR + ((B1B->B1B_VALOR*nIndice)/100),2),NoRound(B1B->B1B_VALOR + ((B1B->B1B_VALOR*nIndice)/100),2))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				BPR->(RecLock("BPR",.T.))
				BPR->BPR_FILIAL := xFilial("BPR")
				BPR->BPR_OPEREA := cCodInt
				BPR->BPR_CODREA := cCodRea
				If BPR->( FieldPos("BPR_CODAJS") ) > 0
					BPR->BPR_CODAJS := cCodAjs
				Endif
				BPR->BPR_CODEMP := aSubCon[nFor][4]
				BPR->BPR_DESEMP := BG9->BG9_DESCRI
				BPR->BPR_CONEMP := aSubCon[nFor][5]
				BPR->BPR_VERCON := aSubCon[nFor][6]
				BPR->BPR_SUBCON := aSubCon[nFor][7]
				BPR->BPR_VERSUB := aSubCon[nFor][8]
				BPR->BPR_VERSAO := BA3->BA3_VERSAO
				BPR->BPR_FORPAG := B1B->B1B_CODFOR
				BPR->BPR_ANOREA := Subs(cAnoMes,1,4)
				BPR->BPR_MESREA := Subs(cAnoMes,5,2)
				BPR->BPR_CODFAI := B1B->B1B_CODFAI
				BPR->BPR_CODPRO := B1B->B1B_CODPRO
				BPR->BPR_VLSLIN := B1B->B1B_VLSLIN
				BPR->BPR_VLSLFN := B1B->B1B_VLSLFN
				BPR->BPR_VALOR  := nVlrRea
				BPR->BPR_PERREA := nIndice
				BPR->BPR_VLRANT := B1B->B1B_VALOR
				BPR->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				B1B->(RecLock("B1B",.F.))
				B1B->B1B_VLRANT := B1B->B1B_VALOR
				B1B->B1B_VALOR  := nVlrRea
				B1B->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				B1B->(DbSkip())
			Enddo
		Endif
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza faixa por quantidade do Subcontrato (se existir)...                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If PLSALIASEX("B1G") .and. PLSALIASEX("BPS") .And. lProduto .And. lReaPla

		If Empty(aSubCon[nFor][17])
			cChvB1GTab := "B1G->(B1G_FILIAL+B1G_CODIGO+B1G_NUMCON+B1G_VERCON+B1G_SUBCON+B1G_VERSUB)"
			cChvB1GSub := cCodInt+aSubCon[nFor][4]+aSubCon[nFor][5]+aSubCon[nFor][6]+aSubCon[nFor][7]+aSubCon[nFor][8]
		Else
			cChvB1GTab := "B1G->(B1G_FILIAL+B1G_CODIGO+B1G_NUMCON+B1G_VERCON+B1G_SUBCON+B1G_VERSUB+B1G_CODPRO+B1G_VERPRO)"
			cChvB1GSub := cCodInt+aSubCon[nFor][4]+aSubCon[nFor][5]+aSubCon[nFor][6]+aSubCon[nFor][7]+aSubCon[nFor][8]+aSubCon[nFor][17]+aSubCon[nFor][18] 
		EndIf
		
		B1G->(DbSetOrder(1))
		If	B1G->(DbSeek(xFilial("B1G")+cChvB1GSub))
			
			While ! B1G->(Eof()) .And. &(cChvB1GTab) == xFilial("B1G")+cChvB1GSub
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := IIf(lArredonda,Round(B1G->B1G_VALOR + ((B1G->B1G_VALOR*nIndice)/100),2),NoRound(B1G->B1G_VALOR + ((B1G->B1G_VALOR*nIndice)/100),2))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				BPS->(RecLock("BPS",.T.))
				BPS->BPS_FILIAL := xFilial("BPS")
				BPS->BPS_OPEREA := cCodInt
				BPS->BPS_CODREA := cCodRea
				If BPS->( FieldPos("BPS_CODAJS") ) > 0
					BPS->BPS_CODAJS := cCodAjs
				Endif
				BPS->BPS_CODEMP := aSubCon[nFor][4]
				BPS->BPS_DESEMP := BG9->BG9_DESCRI
				BPS->BPS_CONEMP := aSubCon[nFor][5]
				BPS->BPS_VERCON := aSubCon[nFor][6]
				BPS->BPS_SUBCON := aSubCon[nFor][7]
				BPS->BPS_VERSUB := aSubCon[nFor][8]
				BPS->BPS_VERSAO := B1G->B1G_VERPRO
				BPS->BPS_FORPAG := B1G->B1G_CODFOR
				BPS->BPS_ANOREA := Subs(cAnoMes,1,4)
				BPS->BPS_MESREA := Subs(cAnoMes,5,2)
				BPS->BPS_CODFAI := B1G->B1G_CODFAI
				BPS->BPS_CODPRO := B1G->B1G_CODPRO
				BPS->BPS_QTDINI := B1G->B1G_QTDINI
				BPS->BPS_QTDFIN := B1G->B1G_QTDFIN
				BPS->BPS_VALOR  := nVlrRea
				BPS->BPS_VLRANT := B1G->B1G_VALOR
				BPS->BPS_CODSEQ := B1G->B1G_CODSEQ
				BPS->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				B1G->(RecLock("B1G",.F.))
				B1G->B1G_VLRANT := B1G->B1G_VALOR
				B1G->B1G_VALOR  := nVlrRea
				B1G->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				B1G->(DbSkip())
			Enddo
		Endif
	EndIf
	
	If lReaPla .And. lFranquia
		For n_ := 1 To Len(aFranquia)
			// Processa apenas arquivos do subcontrato...
			If aFranquia[n_][5] <> '1'
				Loop
			Endif
			
			// Obtem o alias a ser processado pela rotina...
			cAlias := aFranquia[n_][1]
			
			// Seleciona area
			dbSelectArea(cAlias)
			&(cAlias)->( dbSetorder(aFranquia[n_][2]) )
			
			cSQL:= "SELECT " + cAlias+"_CODIGO, " + cAlias + "_NUMCON, " + cAlias + "_VERCON, " + cAlias + "_SUBCON, " + cAlias+"_VERSUB, " 
			cSQL+=	cAlias + "_CODPRO, " + cAlias + "_VERPRO, " + cAlias+"_LIMFRA, " + cAlias + "_ANOMES, " + cAlias + "_VLRANT, " + "R_E_C_N_O_"
			cSQL+=" FROM "+ RetSqlName(cAlias)
			cSQL+=' WHERE ' + cAlias + "_FILIAL = "+ "'"  + xFilial(cAlias)  + "'" 
			cSQL+=" AND " + cAlias+"_CODINT = " + "'" +SUBSTR(cSubCon,0,4)   + "'" 
			cSQL+=" AND " + cAlias+"_CODIGO = " + "'" +SUBSTR(cSubCon,5,4)   + "'"
			cSQL+=" AND " + cAlias+"_NUMCON = " + "'" +SUBSTR(cSubCon,9,12)  + "'"
			cSQL+=" AND " + cAlias+"_VERCON = " + "'" +SUBSTR(cSubCon,21,3)  + "'"
			cSQL+=" AND " + cAlias+"_SUBCON = " + "'" +SUBSTR(cSubCon,24,9)  + "'"
			cSQL+=" AND " + cAlias+"_VERSUB = " + "'" +SUBSTR(cSubCon,33,9)  + "'"
			cSQL+=" AND (" + cAlias+"_VIGFIN >= " + "'" + dtos(dDataBase)     + "'"
			cSQL+=" OR  " + cAlias+"_VIGFIN = ' ')"
			cSQL+=" AND " + " D_E_L_E_T_ = ' ' " 
			cSQL+=" ORDER BY " + cAlias+"_CODPRO" + IIF(cAlias == "BHF",+","+ cAlias + "_CODGRU","")

			cSQL := ChangeQuery(cSQL)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"TRBFRA",.T.,.T.)
			
			// Precessa registros...
			While !(TRBFRA->(Eof())) 
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cCpoFra := TRBFRA->&(cAlias + "_LIMFRA")
				cCpoAms := TRBFRA->&(cAlias + "_ANOMES")
				cCpoVat := TRBFRA->&(cAlias + "_VLRANT")			
				
				nVlrRea := IIf(lArredonda, Round(cCpoFra+((cCpoFra*nIndice)/100),2), NoRound(cCpoFra+((cCpoFra*nIndice)/100),2))
				
				// Grava historico
				If nVlrRea > 0
					B0B->( Reclock("B0B", .T.) )
						B0B->B0B_FILIAL := xFilial("B0B")
						B0B->B0B_ALIAS	:= cAlias
						B0B->B0B_CODREA	:= cCodRea
						B0B->B0B_CODINT	:= cCodInt
						B0B->B0B_CODEMP	:= TRBFRA->&(cAlias +"_CODIGO")
						B0B->B0B_NUMCON	:= TRBFRA->&(cAlias +"_NUMCON")
						B0B->B0B_VERCON	:= TRBFRA->&(cAlias +"_VERCON")
						B0B->B0B_SUBCON	:= TRBFRA->&(cAlias +"_SUBCON")
						B0B->B0B_VERSUB	:= TRBFRA->&(cAlias +"_VERSUB")
						B0B->B0B_CODPRO	:= TRBFRA->&(cAlias +"_CODPRO")
						B0B->B0B_VERPRO	:= TRBFRA->&(cAlias +"_VERPRO")
						B0B->B0B_VLRANT	:= cCpoFra
						B0B->B0B_VLRREA	:= nVlrRea
						B0B->B0B_PERREA	:= nIndice
						B0B->B0B_INDREA	:= cIndRea
						B0B->B0B_DATREA	:= dDataBase
						B0B->B0B_RECREA := Alltrim(cValToChar(TRBFRA->&("R_E_C_N_O_"))) //Gravo o recno do reajuste para utilizar na exclusЦo do reajuste
					B0B->( msUnlock() )
					
					&(cAlias)->(DbGoTo(TRBFRA->&("R_E_C_N_O_")))
					
					// Reajusta registro recorrente
					Reclock(cAlias, .F.)
						
						// Grava ano/mes do reajuste.
						If &(cAlias)->(Fieldpos(TRBFRA->(cAlias + "_ANOMES"))) > 0
							&(cAlias+"->"+cAlias+"_ANOMES") := cAnoMes
						Endif
						
						// Grava o valor atual no campo valor anterior antes de reajustar.
						If &(cAlias)->(Fieldpos(TRBFRA->(cAlias + "_VLRANT"))) > 0
							&(cAlias+"->"+cAlias+"_VLRANT") := cCpoFra
						Endif
						
						// Aplica o reajuste ao valor da franquia.
						&(cAlias+"->"+cAlias+"_LIMFRA")  := nVlrRea
					
					&(cAlias)->( msUnlock() )
					
				Endif
				TRBFRA->( dbSkip() )
			Enddo
			TRBFRA->(DbCloseArea())
		Next
	Endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reajusta Copart. no nivel de familia...                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lReaCop .And. (lCopFix .Or. lCopPer)
		PL101ReaCo(cCodRea, cAnoMes, '1', cSubCon, nInCpFx, nInCpPe)
	Endif
	
	If lPl101Sub
		ExecBlock("PL101SUB",.F.,.F.,{nIndice, cIndRea, cSubCon} )
	Endif
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava criticas das familias...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aErrosFam)
	BPB->(RecLock("BPB",.T.))
	BPB->BPB_FILIAL := xFilial("BPB")
	BPB->BPB_OPEREA := cCodInt
	BPB->BPB_CODREA := cCodRea
	If BPB->( FieldPos("BPB_CODAJS") ) > 0
		BPB->BPB_CODAJS := cCodAjs
	Endif
	BPB->BPB_CODCRI := aErrosFam[nFor,1]
	BPB->BPB_DESCRI := aErrosFam[nFor,2]
	BPB->BPB_MATRIC := aErrosFam[nFor,3]
	BPB->(MsUnLock())
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava criticas dos usuarios...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSALIASEX("BPV")
	For nFor := 1 To Len(aErrosUsr)
		BPV->(RecLock("BPV",.T.))
		BPV->BPV_FILIAL := xFilial("BPV")
		BPV->BPV_OPEREA := cCodInt
		BPV->BPV_CODREA := cCodRea
		If BPV->( FieldPos("BPV_CODAJS") ) > 0
			BPV->BPV_CODAJS := cCodAjs
		Endif
		BPV->BPV_CODCRI := aErrosUsr[nFor,1]
		BPV->BPV_DESCRI := aErrosUsr[nFor,2]
		BPV->BPV_MATRIC := aErrosUsr[nFor,3]
		BPV->(MsUnLock())
	Next
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava criticas dos grupos empresas...                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aErrosGrp)
	BPC->(RecLock("BPC",.T.))
	BPC->BPC_FILIAL := xFilial("BPC")
	BPC->BPC_OPEREA := cCodInt
	BPC->BPC_CODREA := cCodRea
	If BPC->( FieldPos("BPC_CODAJS") ) > 0
		BPC->BPC_CODAJS := cCodAjs
	Endif
	BPC->BPC_CODCRI := aErrosGrp[nFor,1]
	BPC->BPC_DESCRI := aErrosGrp[nFor,2]
	BPC->BPC_CODEMP := aErrosGrp[nFor,3]
	BPC->BPC_DESEMP := aErrosGrp[nFor,4]
	BPC->(MsUnLock())
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava criticas dos subcontratos...                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aErrosSub)
	BYD->(RecLock("BYD",.T.))
	BYD->BYD_FILIAL := xFilial("BYD")
	BYD->BYD_OPEREA := cCodInt
	BYD->BYD_CODREA := cCodRea
	If BYD->( FieldPos("BYD_CODAJS") ) > 0
		BYD->BYD_CODAJS := cCodAjs
	Endif
	BYD->BYD_CODCRI := aErrosSub[nFor,1]
	BYD->BYD_DESCRI := aErrosSub[nFor,2]
	BYD->BYD_CODOPE := aErrosSub[nFor,3]
	BYD->BYD_CODEMP := aErrosSub[nFor,4]
	BYD->BYD_CONEMP := aErrosSub[nFor,5]
	BYD->BYD_VERCON := aErrosSub[nFor,6]
	BYD->BYD_SUBCON := aErrosSub[nFor,7]
	BYD->BYD_VERSUB := aErrosSub[nFor,8]
	BYD->(MsUnLock())
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101EXC Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Exclui um reajuste de cobranca...                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA101EXC(cCodOpe,cCodRea,lDisplay,cCodAjs,aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,;
					aErrosSub,cAnoMesInd,aUsuarios,aErrosUsr,nOpc,lAutoma,cDeEmpresa,cAteEmpresa)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nFor 		:= 0
LOCAL i         := 0
LOCAL cQuebFam 	:= ''
LOCAL cQuebUsr 	:= ''
LOCAL cQuebSub 	:= ''
LOCAL cQuebra  	:= ''
LOCAL cChv		:= ''
LOCAL cKey		:= ''
LOCAL aBP7Regs 	:= {}
LOCAL aBYBRegs 	:= {}
LOCAL aBYCRegs 	:= {}
LOCAL aBYERegs 	:= {}
LOCAL aBYFRegs 	:= {}
LOCAL aBYGRegs 	:= {}
LOCAL aBYHRegs 	:= {}
LOCAL aBYIRegs 	:= {}
LOCAL aBHORegs 	:= {}
LOCAL aErros   	:= {}
LOCAL aEmp			:= {}
LOCAL aBPQRegs 	:= {}
LOCAL aBYPRegs 	:= {}
LOCAL nCodRea		:= ''
LOCAL lregBPQ		:= .F.
LOCAL lregBPR		:= .F.
LOCAL lregBPS		:= .F.
LOCAL lRegBYP		:= .F.
LOCAL lExcluiLote	:= .T.

DEFAULT cCodAjs 	:= ''
DEFAULT cCodAjs 	:= ''
DEFAULT aErrosGrp	:= {}
DEFAULT aGrupos		:= {}
DEFAULT aContratos	:= {}
DEFAULT aSubCon		:= {}
DEFAULT aFamilias	:= {}
DEFAULT aErrosFam	:= {}
DEFAULT aErrosSub	:= {}
DEFAULT cAnoMesInd	:= {}
DEFAULT aUsuarios	:= {}
DEFAULT aErrosUsr	:= {}
DEFAULT lAutoma		:= .F.
DEFAULT cDeEmpresa  := ""
DEFAULT cAteEmpresa := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia transacao...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes no nivel da familia...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BP7->(DbSetOrder(2))
If BP7->(DbSeek(xFilial("BP7")+cCodOpe+cCodRea))
	While ! BP7->(Eof()) .And. BP7->(BP7_FILIAL+BP7_OPEREA+BP7_CODREA) == xFilial("BP7")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BP7", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BP7->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebFam := BP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebFam})) == 0
					BP7->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BP7->( FieldPos("BP7_CODAJS") ) > 0
					If Empty(BP7->BP7_CODAJS) .or. BP7->BP7_CODAJS <> cCodAjs
						BP7->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BP7->(Eof()) .And. BP7->(BP7_FILIAL+BP7_OPEREA+BP7_CODREA+BP7_CODOPE+BP7_CODEMP+BP7_MATRIC) == ;
			xFilial("BP7")+cCodOpe+cCodRea+cQuebFam
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				
				IncProc("Excluindo Reajuste Familia... "+TransForm(BP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC),__cPictFam))
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBU->(DbSetOrder(1))
			If BBU->(DbSeek(xFilial("BBU")+BP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC+BP7_CODFOR+BP7_CODFAI)))
				BBU->(RecLock("BBU",.F.))
				BBU->BBU_VALFAI := BP7->BP7_VLRANT
				BBU->BBU_ANOMES := ""
				BBU->BBU_VLRANT := 0
				BBU->BBU_REJAPL := 0
				BBU->BBU_PERREJ := cTod('')
				BBU->(MsUnLock())
			Else
				aadd(aErros,{"Faixa Etaria "+BP7->BP7_CODFAI+" nao encontrada para a familia "+BP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBP7Regs,BP7->(Recno()))
			BP7->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBP7Regs)
	BP7->(DbGoTo(aBP7Regs[nFor]))
	lExc := .F.
	If !lAjuste
		If BP7->( FieldPos("BP7_CODAJS") ) > 0
			If Empty(BP7->BP7_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BP7->( FieldPos("BP7_CODAJS") ) > 0
			If !Empty(BP7->BP7_CODAJS) .and. BP7->BP7_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BP7->(RecLock("BP7",.F.))
		BP7->(DbDelete())
		BP7->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes no nivel do usuario...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYB->(DbSetOrder(2))
If BYB->(DbSeek(xFilial("BYB")+cCodOpe+cCodRea))
	While ! BYB->(Eof()) .And. BYB->(BYB_FILIAL+BYB_OPEREA+BYB_CODREA) == xFilial("BYB")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYB", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYB->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebUsr := BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG)
		cQuebFam := BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebFam})) == 0
					BYB->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYB->( FieldPos("BYB_CODAJS") ) > 0
					If Empty(BYB->BYB_CODAJS) .or. BYB->BYB_CODAJS <> cCodAjs
						BYB->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYB->(Eof()) .And. BYB->(BYB_FILIAL+BYB_OPEREA+BYB_CODREA+BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG) == ;
			xFilial("BYB")+cCodOpe+cCodRea+cQuebUsr
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Usuario... "+TransForm(BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG),__cPictUsr))
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BDK->(DbSetOrder(2))
			If BDK->(DbSeek(xFilial("BDK")+BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG+BYB_CODFAI)))
				BDK->(RecLock("BDK",.F.))
				BDK->BDK_VALOR := BYB->BYB_VLRANT
				BDK->BDK_ANOMES := ""
				BDK->BDK_VLRANT := 0
				BDK->(MsUnLock())
			Else
				aadd(aErros,{"Faixa Etaria "+BYB->BYB_CODFAI+" nao encontrada para o usuario "+BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG)})
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BDK->(DbSetOrder(2))
			If BDK->(DbSeek(xFilial("BDK")+BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG+BYB_CODFAI)))
				BDK->(RecLock("BDK",.F.))
				BDK->BDK_VALOR := BYB->BYB_VLRANT
				BDK->BDK_ANOMES := ""
				BDK->BDK_VLRANT := 0
				BDK->(MsUnLock())
			Else
				aadd(aErros,{"Faixa Etaria "+BYB->BYB_CODFAI+" nao encontrada para o usuario "+BYB->(BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG)})
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYBRegs,BYB->(Recno()))
			BYB->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYBRegs)
	BYB->(DbGoTo(aBYBRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYB->( FieldPos("BYB_CODAJS") ) > 0
			If Empty(BYB->BYB_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYB->( FieldPos("BYB_CODAJS") ) > 0
			If !Empty(BYB->BYB_CODAJS) .and. BYB->BYB_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYB->(RecLock("BYB",.F.))
		BYB->(DbDelete())
		BYB->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui o historico de reajuste em nivel de usuario...                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSALIASEX("BHO")
	BHO->(DbSetOrder(02))
	If BHO->( DbSeek(xFilial("BHO")+cCodOpe+cCodRea) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BHO->(Eof()) .And. BHO->(BHO_FILIAL+BHO_OPEREA+BHO_CODREA) ==;
			xFilial("BHO")+cCodOpe+cCodRea

			If !lAjuste .And. !ChckExcEmpresa("BHO", cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				BHO->(DbSkip())
				Loop
			EndIf
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
			//| tiver parametro para que seja feito o AJUSTE.							 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lAjuste
				If nOpc == K_Incluir
					If (nPosFam := Ascan(aUsuarios, {|x| Alltrim(x[2]) == BHO->BHO_CODOPE+BHO->BHO_CODEMP+BHO->BHO_MATRIC})) = 0
						BHO->( dbSkip() )
						Loop
					Endif
				Elseif nopc == K_Excluir
					If BHO->( FieldPos("BHO_CODAJS") ) > 0
						If Empty(BHO->BHO_CODAJS) .or. BHO->BHO_CODAJS <> cCodAjs
							BHO->( dbSkip() )
							Loop
						Endif
					Endif
				Endif
			Endif
			
			aadd(aBHORegs,BHO->(Recno()))
			BHO->(DbSkip())
		Enddo
	Endif
	
	For nFor := 1 To Len(aBHORegs)
		BHO->(DbGoTo(aBHORegs[nFor]))
		lExc := .F.
		If !lAjuste
			If BHO->( FieldPos("BHO_CODAJS") ) > 0
				If Empty(BHO->BHO_CODAJS)
					lExc := .T.
				Endif
			Else
				lExc := .T.
			Endif
		Else
			If BHO->( FieldPos("BHO_CODAJS") ) > 0
				If !Empty(BHO->BHO_CODAJS) .and. BHO->BHO_CODAJS == cCodAjs
					lExc := .T.
				Endif
			Endif
		Endif
		If lExc
			BHO->(RecLock("BHO",.F.))
			BHO->(DbDelete())
			BHO->(MsUnLock())
		Endif
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes no nivel do subcontrato...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYC->(DbSetOrder(2))
If BYC->(DbSeek(xFilial("BYC")+cCodOpe+cCodRea))
	While ! BYC->(Eof()) .And. BYC->(BYC_FILIAL+BYC_OPEREA+BYC_CODREA) == xFilial("BYC")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYC", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYC->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebSub := BYC->(BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB+BYC_CODPRO+BYC_VERPRO+BYC_CODFOR)
		cQuebra  := BYC->(BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == cQuebra})) = 0
					BYC->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYC->( FieldPos("BYC_CODAJS") ) > 0
					If Empty(BYC->BYC_CODAJS) .or. BYC->BYC_CODAJS <> cCodAjs
						BYC->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYC->(Eof()) .And. BYC->(BYC_FILIAL+BYC_OPEREA+BYC_CODREA+BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB+BYC_CODPRO+BYC_VERPRO+BYC_CODFOR) == ;
			xFilial("BYC")+cCodOpe+cCodRea+cQuebSub
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Subcontrato... "+cQuebSub)
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BTN->(DbSetOrder(3))
			If BTN->(DbSeek(xFilial("BTN")+BYC->(BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB+;
				BYC_CODPRO+BYC_VERPRO+BYC_CODFOR+BYC_CODFAI)))
				BTN->(RecLock("BTN",.F.))
				BTN->BTN_VALFAI := BYC->BYC_VLRANT
				BTN->BTN_ANOMES := ""
				BTN->BTN_VLRANT := 0
				BTN->BTN_REJAPL := 0
				BTN->BTN_PERREJ := cTod('')
				
				BTN->(MsUnLock())
			Else
				aadd(aErros,{"Faixa Etaria "+BYC->BYC_CODFAI+" nao encontrada para o subcontrato "+BYC->(BYC_CODOPE+BYC_CODEMP+BYC_CONEMP+BYC_VERCON+BYC_SUBCON+BYC_VERSUB)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYCRegs,BYC->(Recno()))
			BYC->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYCRegs)
	BYC->(DbGoTo(aBYCRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYC->( FieldPos("BYC_CODAJS") ) > 0
			If Empty(BYC->BYC_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYC->( FieldPos("BYC_CODAJS") ) > 0
			If !Empty(BYC->BYC_CODAJS) .and. BYC->BYC_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYC->(RecLock("BYC",.F.))
		BYC->(DbDelete())
		BYC->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes de adesao no nivel do subcontrato...                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYE->(DbSetOrder(2))
If BYE->(DbSeek(xFilial("BYE")+cCodOpe+cCodRea))
	While ! BYE->(Eof()) .And. BYE->(BYE_FILIAL+BYE_OPEREA+BYE_CODREA) == xFilial("BYE")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYE", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYE->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebSub := BYE->(BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB+BYE_CODFOR)
		cQuebra  := BYE->(BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == cQuebra})) = 0
					BYE->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYE->( FieldPos("BYE_CODAJS") ) > 0
					If Empty(BYE->BYE_CODAJS) .or. BYE->BYE_CODAJS <> cCodAjs
						BYE->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYE->(Eof()) .And. BYE->(BYE_FILIAL+BYE_OPEREA+BYE_CODREA+BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB+BYE_CODFOR) == ;
			xFilial("BYE")+cCodOpe+cCodRea+cQuebSub
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Subcontrato... "+cQuebSub)
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BR6->(DbSetOrder(1))
			If BR6->(DbSeek(xFilial("BR6")+BYE->(BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB+;
				BYE_CODPRO+BYE_VERPRO+BYE_CODFOR+BYE_CODFAI)))
				BR6->(RecLock("BR6",.F.))
				BR6->BR6_VLRADE := BYE->BYE_VLRANT
				BR6->BR6_ANOMES := ""
				BR6->BR6_VLRANT := 0
				BR6->(MsUnLock())
			Else
				aadd(aErros,{"Adesao "+BYE->BYE_CODFAI+" nao encontrada para o subcontrato "+BYE->(BYE_CODOPE+BYE_CODEMP+BYE_CONEMP+BYE_VERCON+BYE_SUBCON+BYE_VERSUB)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYERegs,BYE->(Recno()))
			BYE->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYERegs)
	BYE->(DbGoTo(aBYERegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYE->( FieldPos("BYE_CODAJS") ) > 0
			If Empty(BYE->BYE_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYE->( FieldPos("BYE_CODAJS") ) > 0
			If !Empty(BYE->BYE_CODAJS) .and. BYE->BYE_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYE->(RecLock("BYE",.F.))
		BYE->(DbDelete())
		BYE->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes de opc no nivel do subcontrato...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYF->(DbSetOrder(2))
If BYF->(DbSeek(xFilial("BYF")+cCodOpe+cCodRea))
	While ! BYF->(Eof()) .And. BYF->(BYF_FILIAL+BYF_OPEREA+BYF_CODREA) == xFilial("BYF")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYF", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYF->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebSub := BYF->(BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB+BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC+BYF_CODFOR)
		cQuebra := BYF->(BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == cQuebra})) = 0
					BYF->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYF->( FieldPos("BYF_CODAJS") ) > 0
					If Empty(BYF->BYF_CODAJS) .or. BYF->BYF_CODAJS <> cCodAjs
						BYF->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYF->(Eof()) .And. BYF->(BYF_FILIAL+BYF_OPEREA+BYF_CODREA+BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB+BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC+BYF_CODFOR) == ;
			xFilial("BYF")+cCodOpe+cCodRea+cQuebSub
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Subcontrato... "+cQuebSub)
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBX->(DbSetOrder(2))
			If BBX->(DbSeek(xFilial("BBX")+BYF->(BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB+;
				BYF_CODPRO+BYF_VERPRO+BYF_CODOPC+BYF_VEROPC+BYF_CODFOR+BYF_CODFAI)))
				BBX->(RecLock("BBX",.F.))
				BBX->BBX_VALFAI := BYF->BYF_VLRANT
				BBX->BBX_ANOMES := ""
				BBX->BBX_VLRANT := 0
				BBX->(MsUnLock())
			Else
				aadd(aErros,{"Valor Opcional Faixa "+BYF->BYF_CODFAI+" nao encontrada para o subcontrato "+BYF->(BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYFRegs,BYF->(Recno()))
			BYF->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYFRegs)
	BYF->(DbGoTo(aBYFRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYF->( FieldPos("BYF_CODAJS") ) > 0
			If Empty(BYF->BYF_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYF->( FieldPos("BYF_CODAJS") ) > 0
			If !Empty(BYF->BYF_CODAJS) .and. BYF->BYF_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYF->(RecLock("BYF",.F.))
		BYF->(DbDelete())
		BYF->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes de adesao na familia...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYG->(DbSetOrder(2))
If BYG->(DbSeek(xFilial("BYG")+cCodOpe+cCodRea))
	While ! BYG->(Eof()) .And. BYG->(BYG_FILIAL+BYG_OPEREA+BYG_CODREA) == xFilial("BYG")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYG", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYG->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebFam := BYG->(BYG_CODOPE+BYG_CODEMP+BYG_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebFam})) = 0
					BYG->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYG->( FieldPos("BYG_CODAJS") ) > 0
					If Empty(BYG->BYG_CODAJS) .or. BYG->BYG_CODAJS <> cCodAjs
						BYG->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYG->(Eof()) .And. BYG->(BYG_FILIAL+BYG_OPEREA+BYG_CODREA+BYG_CODOPE+BYG_CODEMP+BYG_MATRIC) == ;
			xFilial("BYG")+cCodOpe+cCodRea+cQuebFam
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Familia... "+TransForm(BYG->(BYG_CODOPE+BYG_CODEMP+BYG_MATRIC),__cPictFam))
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BRX->(DbSetOrder(1))
			If BRX->(DbSeek(xFilial("BRX")+BYG->(BYG_CODOPE+BYG_CODEMP+BYG_MATRIC+BYG_CODFOR+BYG_CODFAI)))
				BRX->(RecLock("BRX",.F.))
				BRX->BRX_VLRADE := BYG->BYG_VLRANT
				BRX->BRX_ANOMES := ""
				BRX->BRX_VLRANT := 0
				BRX->(MsUnLock())
			Else
				aadd(aErros,{"Reajuste da faixa "+BYG->BYG_CODFAI+" nao encontrada para a familia "+BYG->(BYG_CODOPE+BYG_CODEMP+BYG_MATRIC)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYGRegs,BYG->(Recno()))
			BYG->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYGRegs)
	BYG->(DbGoTo(aBYGRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYG->( FieldPos("BYG_CODAJS") ) > 0
			If Empty(BYG->BYG_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYG->( FieldPos("BYG_CODAJS") ) > 0
			If !Empty(BYG->BYG_CODAJS) .and. BYG->BYG_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYG->(RecLock("BYG",.F.))
		BYG->(DbDelete())
		BYG->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes de opcionais da familia...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYH->(DbSetOrder(2))
If BYH->(DbSeek(xFilial("BYH")+cCodOpe+cCodRea))
	While ! BYH->(Eof()) .And. BYH->(BYH_FILIAL+BYH_OPEREA+BYH_CODREA) == xFilial("BYH")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYH", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYH->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebFam := BYH->(BYH_CODOPE+BYH_CODEMP+BYH_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebFam})) = 0
					BYH->( dbSkip() )
					Loop
				Endif
			Elseif nopc == K_Excluir
				If BYH->( FieldPos("BYH_CODAJS") ) > 0
					If Empty(BYH->BYH_CODAJS) .or. BYH->BYH_CODAJS <> cCodAjs
						BYH->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYH->(Eof()) .And. BYH->(BYH_FILIAL+BYH_OPEREA+BYH_CODREA+BYH_CODOPE+BYH_CODEMP+BYH_MATRIC) == ;
			xFilial("BYH")+cCodOpe+cCodRea+cQuebFam
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Familia... "+TransForm(BYH->(BYH_CODOPE+BYH_CODEMP+BYH_MATRIC),__cPictFam))
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBY->(DbSetOrder(1))
			If BBY->(DbSeek(xFilial("BBY")+BYH->(BYH_CODOPE+BYH_CODEMP+BYH_MATRIC+BYH_CODOPC+BYH_VEROPC+BYH_CODFOR+BYH_CODFAI)))
				BBY->(RecLock("BBY",.F.))
				BBY->BBY_VALFAI := BYH->BYH_VLRANT
				BBY->BBY_ANOMES := ""
				BBY->BBY_VLRANT := 0
				BBY->(MsUnLock())
			Else
				aadd(aErros,{"Reajuste dos opcional da faixa "+BYH->BYH_CODFAI+" nao encontrada para a familia "+BYH->(BYH_CODOPE+BYH_CODEMP+BYH_MATRIC)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYHRegs,BYH->(Recno()))
			BYH->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYHRegs)
	BYH->(DbGoTo(aBYHRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYH->( FieldPos("BYH_CODAJS") ) > 0
			If Empty(BYH->BYH_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYH->( FieldPos("BYH_CODAJS") ) > 0
			If !Empty(BYH->BYH_CODAJS) .and. BYH->BYH_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYH->(RecLock("BYH",.F.))
		BYH->(DbDelete())
		BYH->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes de opcionais dos usuarios...                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BYI->(DbSetOrder(2))
If BYI->(DbSeek(xFilial("BYI")+cCodOpe+cCodRea))
	While ! BYI->(Eof()) .And. BYI->(BYI_FILIAL+BYI_OPEREA+BYI_CODREA) == xFilial("BYI")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYI", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYI->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebUsr := BYI->(BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG)
		cQuebra	 := BYI->(BYI_CODOPE+BYI_CODEMP+BYI_MATRIC)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebra})) = 0
					BYI->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYI->( FieldPos("BYI_CODAJS") ) > 0
					If Empty(BYI->BYI_CODAJS) .or. BYI->BYI_CODAJS <> cCodAjs
						BYI->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYI->(Eof()) .And. BYI->(BYI_FILIAL+BYI_OPEREA+BYI_CODREA+BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG) == ;
			xFilial("BYI")+cCodOpe+cCodRea+cQuebUsr
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				IncProc("Excluindo Reajuste Opcionais Usuario... "+TransForm(BYI->(BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG),__cPictUsr))
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BZX->(DbSetOrder(1))
			If BZX->(DbSeek(xFilial("BZX")+BYI->(BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG+BYI_CODOPC+BYI_VEROPC+BYI_CODFOR+BYI_CODFAI)))
				BZX->(RecLock("BZX",.F.))
				BZX->BZX_VALFAI := BYI->BYI_VLRANT
				BZX->BZX_ANOMES := ""
				BZX->BZX_VLRANT := 0
				BZX->(MsUnLock())
			Else
				aadd(aErros,{"Reajuste do opcional faixa "+BYI->BYI_CODFAI+" nao encontrada para o usuario "+BYI->(BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYIRegs,BYI->(Recno()))
			BYI->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYIRegs)
	BYI->(DbGoTo(aBYIRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYI->( FieldPos("BYI_CODAJS") ) > 0
			If Empty(BYI->BYI_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYI->( FieldPos("BYI_CODAJS") ) > 0
			If !Empty(BYI->BYI_CODAJS) .and. BYI->BYI_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYI->(RecLock("BYI",.F.))
		BYI->(DbDelete())
		BYI->(MsUnLock())
	Endif
Next

If PLSALIASEX("BPQ")
	BPQ->(DbSetOrder(1))
	If BPQ->(DbSeek(xFilial("BPQ")+cCodOpe+cCodRea))
		While ! BPQ->(Eof()) .And. BPQ->(BPQ_FILIAL+BPQ_OPEREA+BPQ_CODREA) == xFilial("BPQ")+cCodOpe+cCodRea

			If !lAjuste .And. !ChckExcEmpresa("BPQ", cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				BPQ->(DbSkip())
				Loop
			EndIf

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define quebra da familia...                                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cQuebFam := BPQ->(BPQ_CODOPE+BPQ_CODEMP+BPQ_MATRIC)
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
			//| tiver parametro para que seja feito o AJUSTE.							 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lAjuste
				If nOpc == K_Incluir
					If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebFam})) == 0
						BPQ->( dbSkip() )
						Loop
					Endif
				Elseif nOpc == K_Excluir
					If BPQ->( FieldPos("BPQ_CODAJS") ) > 0
						If Empty(BPQ->BPQ_CODAJS) .or. BPQ->BPQ_CODAJS <> cCodAjs
							BPQ->( dbSkip() )
							Loop
						Endif
					Endif
				Endif
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			While ! BPQ->(Eof()) .And. BPQ->(BPQ_FILIAL+BPQ_OPEREA+BPQ_CODREA+BPQ_CODOPE+BPQ_CODEMP+BPQ_MATRIC) == ;
				xFilial("BPQ")+cCodOpe+cCodRea+cQuebFam
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Exibe mensagem informativa...                                            Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lDisplay
					IncProc("Excluindo Reajuste Familia... "+TransForm(BPQ->(BPQ_CODOPE+BPQ_CODEMP+BPQ_MATRIC),__cPictFam))
					ProcessMessage()
					
				Endif
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				B1H->(DbSetOrder(1))
				If B1H->(DbSeek(xFilial("B1H")+BPQ->(BPQ_CODOPE+BPQ_CODEMP+BPQ_MATRIC+BPQ_CODFOR+BPQ_CODFAI+BPQ_CODSEQUEN)))
					B1H->(RecLock("B1H",.F.))
					B1H->B1H_VALOR := BPQ->BPQ_VLRANT
					
					nRegBPQ := BPQ->(Recno())
					nCodRea := BPQ->BPQ_CODREA
					
					while  !BPQ->(BOF()) .AND. B1H->B1H_VLRANT != BPQ->BPQ_VLRREA
						BPQ->(dbSkip(-1))
					EndDo
					
					If B1H->B1H_VLRANT == BPQ->BPQ_VLRANT .OR. BPQ->(BOF()) .OR. lregBPQ
						B1H->B1H_ANOMES := ""
						B1H->B1H_VLRANT := 0
						lregBPQ = .T.
					Else
						B1H->B1H_ANOMES := DTOS(BPQ->BPQ_DATANT)
						B1H->B1H_VLRANT := BPQ->BPQ_VLRANT
					EndIf
					
					BPQ->(dbGoto(nRegBPQ))
					B1H->(MsUnLock())
				Else
					aadd(aErros,{"Faixa Etaria "+BPQ->BPQ_CODFAI+" nao encontrada para a familia "+BPQ->(BPQ_CODOPE+BPQ_CODEMP+BPQ_MATRIC)})
				Endif
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Exclui o historico de reajuste desta familia atual...                    Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aadd(aBPQRegs,BPQ->(Recno()))
				BPQ->(DbSkip())
			Enddo
		Enddo
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nFor := 1 To Len(aBPQRegs)
		BPQ->(DbGoTo(aBPQRegs[nFor]))
		lExc := .F.
		If !lAjuste
			If BPQ->( FieldPos("BPQ_CODAJS") ) > 0
				If Empty(BPQ->BPQ_CODAJS)
					lExc := .T.
				Endif
			Else
				lExc := .T.
			Endif
		Else
			If BPQ->( FieldPos("BPQ_CODAJS") ) > 0
				If !Empty(BPQ->BPQ_CODAJS) .and. BPQ->BPQ_CODAJS == cCodAjs
					lExc := .T.
				Endif
			Endif
		Endif
		If lExc
			BPQ->(RecLock("BPQ",.F.))
			BPQ->(DbDelete())
			BPQ->(MsUnLock())
		Endif
	Next
EndIf


BYP->(DbSetOrder(1))
If BYP->(DbSeek(xFilial("BYP")+cCodOpe+cCodRea))
	While ! BYP->(Eof()) .And. BYP->(BYP_FILIAL+BYP_OPEREA+BYP_CODREA) == xFilial("BYP")+cCodOpe+cCodRea

		If !lAjuste .And. !ChckExcEmpresa("BYP", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYP->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define quebra da familia...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQuebFam := BYP->(BYP_CODOPE+BYP_CODEMP+BYP_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == cQuebFam})) == 0
					BYP->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYP->( FieldPos("BYP_CODAJS") ) > 0
					If Empty(BYP->BYP_CODAJS) .or. BYP->BYP_CODAJS <> cCodAjs
						BYP->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While ! BYP->(Eof()) .And. BYP->(BYP_FILIAL+BYP_OPEREA+BYP_CODREA+BYP_CODOPE+BYP_CODEMP+BYP_MATRIC) == ;
			xFilial("BYP")+cCodOpe+cCodRea+cQuebFam
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exibe mensagem informativa...                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lDisplay
				
				IncProc("Excluindo Reajuste Familia... "+TransForm(BYP->(BYP_CODOPE+BYP_CODEMP+BYP_MATRIC),__cPictFam))
				ProcessMessage()
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Navega por todos os itens deste reajuste da familia atual...             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			B1C->(DbSetOrder(1))
			If B1C->(DbSeek(xFilial("B1C")+BYP->(BYP_CODOPE+BYP_CODEMP+BYP_MATRIC+BYP_CODFOR+BYP_CODFAI)))
				
				B1C->(RecLock("B1C",.F.))
				B1C->B1C_VALOR := B1C->B1C_VLRANT
				
				nRegBYP := BYP->(Recno())
				nCodRea := BYP->BYP_CODREA
				
				while  !BYP->(BOF()) .AND. B1C->B1C_VLRANT != BYP->BYP_VLRREA
					BYP->(dbSkip(-1))
				EndDo
				
				If BYP->(BOF()) .OR. lRegBYP
					B1C->B1C_ANOMES := ""
					B1C->B1C_VLRANT := 0
					lRegBYP = .T.
				Else
					B1C->B1C_ANOMES := DTOS(BYP->BYP_DATANT)
					B1C->B1C_VLRANT := BYP->BYP_VLRANT
				EndIf
				
				BYP->(dbGoto(nRegBYP))
				B1C->(MsUnLock())
			Else
				aadd(aErros,{"Faixa Etaria "+BYP->BYP_CODFAI+" nao encontrada para a familia "+BYP->(BYP_CODOPE+BYP_CODEMP+BYP_MATRIC)})
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui o historico de reajuste desta familia atual...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aBYPRegs,BYP->(Recno()))
			BYP->(DbSkip())
		Enddo
	Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nFor := 1 To Len(aBYPRegs)
	BYP->(DbGoTo(aBYPRegs[nFor]))
	lExc := .F.
	If !lAjuste
		If BYP->( FieldPos("BYP_CODAJS") ) > 0
			If Empty(BYP->BYP_CODAJS)
				lExc := .T.
			Endif
		Else
			lExc := .T.
		Endif
	Else
		If BYP->( FieldPos("BYP_CODAJS") ) > 0
			If !Empty(BYP->BYP_CODAJS) .and. BYP->BYP_CODAJS == cCodAjs
				lExc := .T.
			Endif
		Endif
	Endif
	If lExc
		BYP->(RecLock("BYP",.F.))
		BYP->(DbDelete())
		BYP->(MsUnLock())
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desfaz o reajuste da franquia...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PL101DelCo(cCodOpe, cCodRea, lAjuste, cDeEmpresa, cAteEmpresa, @lExcluiLote)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desfaz o reajuste da franquia...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSALIASEX("B0B")
	PL101ExcFr(cCodRea, cCodOpe, lAjuste, cDeEmpresa, cAteEmpresa, @lExcluiLote)
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for acionada pela rotina de ajuste, nao deve excluir o historico do reajuste...  |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lDisplay
	IncProc("Excluindo criticas...")
	ProcessMessage()
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui todos as criticas da familia...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BPB->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BPB->(BPB_OPEREA+BPB_CODREA)"
Else
	BPB->(DbSetOrder(2))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BPB->(BPB_OPEREA+BPB_CODREA+BPB_CODAJS)"
Endif

aRegs := {}
If BPB->(DbSeek(xFilial("BPB")+cChv))
	While !BPB->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BPB", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BPB->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == Alltrim(BPB->BPB_MATRIC)})) = 0
					BPB->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BPB->( FieldPos("BPB_CODAJS") ) > 0
					If Empty(BPB->BPB_CODAJS) .or. BPB->BPB_CODAJS <> cCodAjs
						BPB->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		Aadd(aRegs, BPB->( Recno() ))
		BPB->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BPB->( dbGoto(aRegs[i]) )
		BPB->(RecLock("BPB",.F.))
		BPB->(DbDelete())
		BPB->(MsUnLock())
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui todos as criticas do usuario...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSALIASEX("BPV")
	
	If !lAjuste
		BPV->(DbSetOrder(1))
		cChv := BHW->(BHW_CODINT+BHW_CODREA)
		cKey := "BPV->(BPV_OPEREA+BPV_CODREA)"
	Else
		BPC->(DbSetOrder(1))
		cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
		cKey := "BPV->(BPV_OPEREA+BPV_CODREA+BPV_CODAJS)"
	Endif
	
	If BPV->(DbSeek(xFilial("BPV")+cChv))
		While !BPV->(Eof()) .And. &cKey == cChv

			If !lAjuste .And. !ChckExcEmpresa("BPV", cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				BPV->(DbSkip())
				Loop
			EndIf
			
			BPV->(RecLock("BPV",.F.))
			BPV->(DbDelete())
			BPV->(MsUnLock())
			
			BPV->(dbSkip())
		Enddo
	EndIf
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui todos as criticas do grupo empresa...                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BPC->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BPC->(BPC_OPEREA+BPC_CODREA)"
Else
	BPC->(DbSetOrder(2))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BPC->(BPC_OPEREA+BPC_CODREA+BPC_CODAJS)"
Endif

aRegs := {}
If BPC->(DbSeek(xFilial("BPC")+cChv))
	While !BPC->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BPC", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BPC->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[3]) == Alltrim(BPC->BPC_CODEMP)})) = 0
					BPC->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BPC->( FieldPos("BPC_CODAJS") ) > 0
					If Empty(BPC->BPC_CODAJS) .or. BPC->BPC_CODAJS <> cCodAjs
						BPC->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		Aadd(aRegs, BPC->( Recno() ))
		BPC->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BPC->( dbGoto(aRegs[i]) )
		BPC->(RecLock("BPC",.F.))
		BPC->(DbDelete())
		BPC->(MsUnLock())
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui todos as criticas do subcontrato...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BYD->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BYD->(BYD_OPEREA+BYD_CODREA)"
Else
	BYD->(DbSetOrder(2))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BYD->(BYD_OPEREA+BYD_CODREA+BYD_CODAJS)"
Endif

aRegs := {}
If BYD->(DbSeek(xFilial("BYD")+cChv))
	While !BYD->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BYD", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BYD->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == BYD->(BYD_OPEREA+BYD_CODEMP+BYD_CONEMP+BYD_VERCON+BYD_SUBCON+BYD_VERSUB)})) = 0
					BYD->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BYD->( FieldPos("BYD_CODAJS") ) > 0
					If Empty(BYD->BYD_CODAJS) .or. BYD->BYD_CODAJS <> cCodAjs
						BYD->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		Aadd(aRegs, BYD->( Recno() ))
		BYD->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BYD->( dbGoto(aRegs[i]) )
		BYD->(RecLock("BYD",.F.))
		BYD->(DbDelete())
		BYD->(MsUnLock())
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui grupos empresas processados...                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BPD->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BPD->(BPD_OPEREA+BPD_CODREA)"
Else
	BPD->(DbSetOrder(3))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BPD->(BPD_OPEREA+BPD_CODREA+BPD_CODAJS)"
Endif

aRegs := {}
If BPD->(DbSeek(xFilial("BPD")+cChv))
	While !BPD->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BPD", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BPD->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[3]) == BPD->BPD_CODEMP})) == 0
					BPD->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BPD->( FieldPos("BPD_CODAJS") ) > 0
					If Empty(BPD->BPD_CODAJS) .or. BPD->BPD_CODAJS <> cCodAjs
						BPD->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		Aadd(aRegs, BPD->( Recno() ))
		BPD->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BPD->( dbGoto(aRegs[i]) )
		BPD->(RecLock("BPD",.F.))
		BPD->(DbDelete())
		BPD->(MsUnLock())
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui contratos processados...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BPE->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BPE->(BPE_OPEREA+BPE_CODREA)"
Else
	BPE->(DbSetOrder(2))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BPE->(BPE_OPEREA+BPE_CODREA+BPE_CODAJS)"
Endif

aRegs := {}
If BPE->(DbSeek(xFilial("BPE")+cChv))
	While !BPE->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BPE", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BPE->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aContratos, {|x| Alltrim(x[2]) == BPE->(BPE_OPEREA+BPE_CODEMP+BPE_CONEMP+BPE_VERCON)})) = 0
					BPE->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BPE->( FieldPos("BPE_CODAJS") ) > 0
					If Empty(BPE->BPE_CODAJS) .or. BPE->BPE_CODAJS <> cCodAjs
						BPE->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		Aadd(aRegs, BPE->( Recno() ))
		BPE->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BPE->( dbGoto(aRegs[i]) )
		BPE->(RecLock("BPE",.F.))
		BPE->(DbDelete())
		BPE->(MsUnLock())
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui subcontratos processados...                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BPF->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BPF->(BPF_OPEREA+BPF_CODREA)"
Else
	BPF->(DbSetOrder(3))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BPF->(BPF_OPEREA+BPF_CODREA+BPF_CODAJS)"
Endif

aRegs := {}
If BPF->(DbSeek(xFilial("BPF")+cChv))
	While !BPF->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BPF", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BPF->(DbSkip())
			Loop
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == BPF->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)})) = 0
					BPF->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BPF->( FieldPos("BPF_CODAJS") ) > 0
					If Empty(BPF->BPF_CODAJS) .or. BPF->BPF_CODAJS <> cCodAjs
						BPF->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		Aadd(aRegs, BPF->( Recno() ))
		BPF->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BPF->( dbGoto(aRegs[i]) )
		BPF->(RecLock("BPF",.F.))
		BPF->(DbDelete())
		BPF->(MsUnLock())
	Next
Endif

If PLSALIASEX("BPR")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exclui subcontratos processados...                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lAjuste
		BPR->(DbSetOrder(1))
		cChv := BHW->(BHW_CODINT+BHW_CODREA)
		cKey := "BPR->(BPR_OPEREA+BPR_CODREA)"
	Else
		BPR->(DbSetOrder(3))
		cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
		cKey := "BPR->(BPR_OPEREA+BPR_CODREA+BPR_CODAJS)"
	Endif
	
	aBPRRegs := {}
	If BPR->(DbSeek(xFilial("BPR")+cChv))
		While !BPR->( Eof() ) .and. &cKey == cChv

			If !lAjuste .And. !ChckExcEmpresa("BPR", cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				BPR->(DbSkip())
				Loop
			EndIf

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
			//| tiver parametro para que seja feito o AJUSTE.							 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lAjuste
				If nOpc == K_Incluir
					If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == BPR->(BPR_OPEREA+BPR_CODEMP+BPR_CONEMP+BPR_VERCON+BPR_SUBCON+BPR_VERSUB)})) = 0
						BPR->( dbSkip() )
						Loop
					Endif
				Elseif nOpc == K_Excluir
					If BPR->( FieldPos("BPR_CODAJS") ) > 0
						If Empty(BPR->BPR_CODAJS) .or. BPR->BPR_CODAJS <> cCodAjs
							BPR->( dbSkip() )
							Loop
						Endif
					Endif
				Endif
			Endif
			
			B1B->(DbSetOrder(1))
			If	B1B->(DbSeek(xFilial("B1B")+BPR->(BPR_OPEREA+BPR_CODEMP+BPR_CONEMP+BPR_VERCON+BPR_SUBCON+BPR_VERSUB+BPR_CODPRO+BPR_VERSAO+;
				BPR_FORPAG+BPR_CODFAI)))
				
				B1B->(RecLock("B1B",.F.))
				B1B->B1B_VALOR := BPR->BPR_VLRANT
				
				nRegBPR := BPR->(Recno())
				nCodRea := BPR->BPR_CODREA
				
				while !BPR->(BOF()) .AND. B1B->B1B_VLRANT != BPR->BPR_VALOR
					BPR->(dbSkip(-1))
				EndDo
				
				If B1B->B1B_VLRANT == BPR->BPR_VLRANT .OR. BPR->(BOF()) .OR. lregBPR
					B1B->B1B_VLRANT := 0
					lregBPR := .T.
				Else
					B1B->B1B_VLRANT := BPR->BPR_VLRANT
				EndIf
				
				BPR->(dbGoto(nRegBPR))
				B1B->(MsUnLock())
			Else
				
				aadd(aErros,{"Faixa Salarial "+BPR->BPR_CODFAI+" nao encontrada para a familia "+BPR->(BPR_OPEREA+BPR_CODEMP)})
				
			Endif
			
			Aadd(aBPRRegs, BPR->( Recno() ))
			BPR->( dbSkip() )
		Enddo
		
		For i := 1 To Len(aBPRRegs)
			BPR->( dbGoto(aBPRRegs[i]) )
			BPR->(RecLock("BPR",.F.))
			BPR->(DbDelete())
			BPR->(MsUnLock())
		Next
	Endif
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui subcontratos processados...                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If PLSALIASEX("BPS")
	If !lAjuste
		BPS->(DbSetOrder(1))
		cChv := BHW->(BHW_CODINT+BHW_CODREA)
		cKey := "BPS->(BPS_OPEREA+BPS_CODREA)"
	Else
		BPS->(DbSetOrder(3))
		cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
		cKey := "BPS->(BPS_OPEREA+BPS_CODREA+BPS_CODAJS)"
	Endif
	
	aBPSRegs := {}
	If BPS->(DbSeek(xFilial("BPS")+cChv))
		While !BPS->( Eof() ) .and. &cKey == cChv

			If !lAjuste .And. !ChckExcEmpresa("BPS", cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				BPS->(DbSkip())
				Loop
			EndIf

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
			//| tiver parametro para que seja feito o AJUSTE.							 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lAjuste
				If nOpc == K_Incluir
					If (nPosFam := Ascan(aSubCon, {|x| Alltrim(x[1]) == BPS->(BPS_OPEREA+BPS_CODEMP+BPS_CONEMP+BPS_VERCON+BPS_SUBCON+BPS_VERSUB)})) = 0
						BPS->( dbSkip() )
						Loop
					Endif
				Elseif nOpc == K_Excluir
					If BPS->( FieldPos("BPS_CODAJS") ) > 0
						If Empty(BPS->BPS_CODAJS) .or. BPS->BPS_CODAJS <> cCodAjs
							BPS->( dbSkip() )
							Loop
						Endif
					Endif
				Endif
			Endif
			
			B1G->(DbSetOrder(1))
			If	B1G->(DbSeek(xFilial("BPS")+BPS->(BPS_OPEREA+BPS_CODEMP+BPS_CONEMP+BPS_VERCON+BPS_SUBCON+BPS_VERSUB+BPS_CODPRO+BPS_VERSAO+;
				BPS_FORPAG+BPS_CODFAI+BPS_CODSEQ)))
				
				B1G->(RecLock("B1G",.F.))
				B1G->B1G_VALOR := BPS->BPS_VLRANT
				
				nRegBPR := BPS->(Recno())
				nCodRea := BPS->BPS_CODREA
				
				while !BPS->(BOF()) .AND. B1G->B1G_VLRANT != BPS->BPS_VALOR
					BPS->(dbSkip(-1))
				EndDo
				
				If B1G->B1G_VLRANT == BPS->BPS_VLRANT .OR. lregBPS
					B1G->B1G_VLRANT := 0
					lregBPS := .T.
				Else
					B1G->B1G_VLRANT := BPS->BPS_VLRANT
				EndIf
				
				BPS->(dbGoto(nRegBPR))
				B1G->(MsUnLock())
				
				B1G->(MsUnLock())
			Else
				aadd(aErros,{"Faixa Etaria "+BPS->BPS_CODFAI+" nao encontrada para a familia "+BPS->(BPS_OPEREA+BPS_CODEMP+BPS_CONEMP+BPS_VERCON+BPS_SUBCON+BPS_VERSUB+BPS_CODPRO+BPS_VERSAO)})
			Endif
			
			Aadd(aBPSRegs, BPS->( Recno() ))
			BPS->( dbSkip() )
		Enddo
		
		For i := 1 To Len(aBPSRegs)
			BPS->( dbGoto(aBPSRegs[i]) )
			BPS->(RecLock("BPS",.F.))
			BPS->(DbDelete())
			BPS->(MsUnLock())
		Next
	Endif
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui familias processadas...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAjuste
	BHL->(DbSetOrder(1))
	cChv := BHW->(BHW_CODINT+BHW_CODREA)
	cKey := "BHL->(BHL_OPEREA+BHL_CODREA)"
Else
	BHL->(DbSetOrder(4))
	cChv := BHV->(BHV_CODINT+BHV_CODREA+BHV_CODAJS)
	cKey := "BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODAJS)"
Endif

aRegs := {}
If BHL->(DbSeek(xFilial("BHL")+cChv))
	While !BHL->( Eof() ) .and. &cKey == cChv

		If !lAjuste .And. !ChckExcEmpresa("BHL", cDeEmpresa, cAteEmpresa)
			lExcluiLote := .F.
			BHL->(DbSkip())
			Loop
		EndIf
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste feito em funcao do bops 128447. So ira excluir o reajuste de quem Ё
		//| tiver parametro para que seja feito o AJUSTE.							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAjuste
			If nOpc == K_Incluir
				If (nPosFam := Ascan(aFamilias, {|x| Alltrim(x[2]) == BHL->(BHL_OPEREA+BHL_CODEMP+BHL_MATRIC)})) = 0
					BHL->( dbSkip() )
					Loop
				Endif
			Elseif nOpc == K_Excluir
				If BHL->( FieldPos("BHL_CODAJS") ) > 0
					If Empty(BHL->BHL_CODAJS) .or. BHL->BHL_CODAJS <> cCodAjs
						BHL->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		Aadd(aRegs, BHL->( Recno() ))
		BHL->( dbSkip() )
	Enddo
	
	For i := 1 To Len(aRegs)
		BHL->( dbGoto(aRegs[i]) )
		BHL->(RecLock("BHL",.F.))
		BHL->(DbDelete())
		BHL->(MsUnLock())
	Next
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui lote de reajuste...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Excluir
	If !lAjuste .And. lExcluiLote
		If !BHW->( Eof() )
			BHW->(RecLock("BHW",.F.))
			BHW->(DbDelete())
			BHW->(MsUnLock())
		Endif
	Else
		If !BHV->( Eof() )
			BHV->(RecLock("BHV",.F.))
			BHV->(DbDelete())
			BHV->(MsUnLock())
		Endif
	Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza Transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe mensagem caso tenha criticas na exclusao...                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoma
	If Len(aErros) > 0
		PLSCRIGEN(aErros,{ {"Criticas","@C",300} },"Foi identificada criticas para esta exclusao de reajuste...")
	Endif
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101MAU Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta a arvore para a familia posicionada...               Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA101MAU(oTree,nQtdArv)
LOCAL cFaixa
LOCAL cValor1
LOCAL cValor2
LOCAL cIndice
LOCAL cTipReg
LOCAL cQuebOpc
LOCAL cQuebUsr

nQtdArv ++

oTree:AddTree("Familia "+TransForm(BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC),__cPictFam)+Space(100) ,.T.,"BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","FAM"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))


BP7->(DbSetOrder(1))
If BP7->(DbSeek(xFilial("BP7")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC+BHL_OPEREA+BHL_CODREA)))
	oTree:AddTree("Faixa Etaria da Familia"+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","PROD"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
	While ! BP7->(Eof()) .And. BP7->(BP7_FILIAL+BP7_CODOPE+BP7_CODEMP+BP7_MATRIC+BP7_OPEREA+BP7_CODREA) == ;
		xFilial("BP7")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC+BHL_OPEREA+BHL_CODREA)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
		//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BHV")
			If BP7->( FieldPos("BP7_CODAJS") ) > 0
				If (lAjuste .and. BP7->BP7_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BP7->BP7_CODAJS))
					BP7->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
		
		cFaixa  := "Faixa Etaria "+AllTrim(Str(BP7->BP7_IDAINI))+" a "+AllTrim(Str(BP7->BP7_IDAFIN))+" anos"
		cValor1 := "Valor Antigo "+AllTrim(Str(BP7->BP7_VLRANT,17,2))
		cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BP7->BP7_VLRREA,17,2))
		cIndice := "Indice Aplicado "+AllTrim(Str(BP7->BP7_PERREA,17,4))
		
		oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BP7->BP7_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		
		oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BP7->BP7_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BP7->BP7_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BP7->BP7_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:EndTree()
		
		BP7->(DbSkip())
	Enddo
	oTree:EndTree()
Endif

BYP->(DbSetOrder(2))
If BYP->(DbSeek(xFilial("BYP")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC+BHL_OPEREA+BHL_CODREA)))
	oTree:AddTree("Faixa Salarial da Familia"+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","PROD"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
	While ! BYP->(Eof()) .And. BYP->(BYP_FILIAL+BYP_CODOPE+BYP_CODEMP+BYP_MATRIC+BYP_OPEREA+BYP_CODREA) == ;
		xFilial("BYP")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC+BHL_OPEREA+BHL_CODREA)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
		//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BHV")
			If BYP->( FieldPos("BYP_CODAJS") ) > 0
				If (lAjuste .and. BYP->BYP_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYP->BYP_CODAJS))
					BYP->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
		
		cFaixa  := "Faixa Salarial "+AllTrim(Str(BYP->BYP_VLSLIN))+" a "+AllTrim(Str(BYP->BYP_VLSLFN))+" reais"
		cValor1 := "Valor Antigo "+AllTrim(Str(BYP->BYP_VLRANT,17,2))
		cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYP->BYP_VLRREA,17,2))
		cIndice := "Indice Aplicado "+AllTrim(Str(BYP->BYP_PERREA,17,4))
		
		oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYP->BYP_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		
		oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYP->BYP_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYP->BYP_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYP->BYP_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:EndTree()
		
		BYP->(DbSkip())
	Enddo
	oTree:EndTree()
Endif

BYB->(DbSetOrder(2))
If BYB->(DbSeek(xFilial("BYB")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)))
	
	While ! BYB->(Eof()) .And. BYB->(BYB_FILIAL+BYB_OPEREA+BYB_CODREA+BYB_CODOPE+BYB_CODEMP+BYB_MATRIC) == ;
		xFilial("BYB")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
		//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BHV")
			If BYB->( FieldPos("BYB_CODAJS") ) > 0
				If (lAjuste .and. BYB->BYB_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYB->BYB_CODAJS))
					BYB->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
		cTipReg := BYB->BYB_TIPREG
		
		BA1->(DbSetOrder(2))
		BA1->(DbSeek(xFilial("BA1")+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)+cTipReg))
		
		oTree:AddTree("Faixa Etaria Especifica do Usuario "+AllTrim(BA1->BA1_NOMUSR)+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","PROD"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		
		While ! BYB->(Eof()) .And. BYB->(BYB_FILIAL+BYB_OPEREA+BYB_CODREA+BYB_CODOPE+BYB_CODEMP+BYB_MATRIC+BYB_TIPREG) == ;
			xFilial("BYB")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)+cTipReg
			
			cFaixa  := "Faixa Etaria "+AllTrim(Str(BYB->BYB_IDAINI))+" a "+AllTrim(Str(BYB->BYB_IDAFIN))+" anos"
			cValor1 := "Valor Antigo "+AllTrim(Str(BYB->BYB_VLRANT,17,2))
			cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYB->BYB_VLRREA,17,2))
			cIndice := "Indice Aplicado "+AllTrim(Str(BYB->BYB_PERREA,17,4))
			
			oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYB->BYB_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			
			oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYB->BYB_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			oTree:EndTree()
			
			oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYB->BYB_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			oTree:EndTree()
			
			oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYB->BYB_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			oTree:EndTree()
			
			oTree:EndTree()
			
			BYB->(DbSkip())
		Enddo
		oTree:EndTree()
	Enddo
Endif


BYG->(DbSetOrder(2))
If BYG->(DbSeek(xFilial("BYG")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)))
	oTree:AddTree("Valores Adesao da Familia"+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","OPC"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
	
	While ! BYG->(Eof()) .And. BYG->(BYG_FILIAL+BYG_OPEREA+BYG_CODREA+BYG_CODOPE+BYG_CODEMP+BYG_MATRIC) == ;
		xFilial("BYG")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
		//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BHV")
			If BYG->( FieldPos("BYG_CODAJS") ) > 0
				If (lAjuste .and. BYG->BYG_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYG->BYG_CODAJS))
					BYG->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
		
		cFaixa  := "Faixa Etaria "+AllTrim(Str(BYG->BYG_IDAINI))+" a "+AllTrim(Str(BYG->BYG_IDAFIN))+" anos"
		cValor1 := "Valor Antigo "+AllTrim(Str(BYG->BYG_VLRANT,17,2))
		cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYG->BYG_VLRREA,17,2))
		cIndice := "Indice Aplicado "+AllTrim(Str(BYG->BYG_PERREA,17,4))
		
		oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYG->BYG_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		
		oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYG->BYG_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYG->BYG_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYG->BYG_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		oTree:EndTree()
		
		oTree:EndTree()
		
		BYG->(DbSkip())
	Enddo
	oTree:EndTree()
Endif

BYH->(DbSetOrder(2))
If BYH->(DbSeek(xFilial("BYH")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)))
	oTree:AddTree("Valores Opcionais da Familia"+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","OPC"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
	
	While ! BYH->(Eof()) .And. BYH->(BYH_FILIAL+BYH_OPEREA+BYH_CODREA+BYH_CODOPE+BYH_CODEMP+BYH_MATRIC) == ;
		xFilial("BYH")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
		//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BHV")
			If BYH->( FieldPos("BYH_CODAJS") ) > 0
				If (lAjuste .and. BYH->BYH_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYH->BYH_CODAJS))
					BYH->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
		cQuebOpc := BYH->(BYH_CODOPC+BYH_VEROPC)
		
		BI3->(DbSetOrder(1))
		BI3->(DbSeek(xFilial("BI3")+BYH->(BYH_CODOPE+BYH_CODOPC+BYH_VEROPC)))
		
		oTree:AddTree("Opcional "+BI3->BI3_CODIGO+" - "+AllTrim(BI3->BI3_DESCRI)+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","OPC"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		
		While ! BYH->(Eof()) .And. BYH->(BYH_FILIAL+BYH_OPEREA+BYH_CODREA+BYH_CODOPE+BYH_CODEMP+BYH_MATRIC+BYH_CODOPC+BYH_VEROPC) == ;
			xFilial("BYH")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)+cQuebOpc
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
			//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If PLSALIASEX("BHV")
				If BYH->( FieldPos("BYH_CODAJS") ) > 0
					If (lAjuste .and. BYH->BYH_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYH->BYH_CODAJS))
						BYH->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
			cFaixa  := "Faixa Etaria "+AllTrim(Str(BYH->BYH_IDAINI))+" a "+AllTrim(Str(BYH->BYH_IDAFIN))+" anos"
			cValor1 := "Valor Antigo "+AllTrim(Str(BYH->BYH_VLRANT,17,2))
			cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYH->BYH_VLRREA,17,2))
			cIndice := "Indice Aplicado "+AllTrim(Str(BYH->BYH_PERREA,17,4))
			
			oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYH->BYH_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			
			oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYH->BYH_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			oTree:EndTree()
			
			oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYH->BYH_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			oTree:EndTree()
			
			oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYH->BYH_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			oTree:EndTree()
			
			oTree:EndTree()
			BYH->(DbSkip())
		Enddo
		oTree:EndTree()
	Enddo
	oTree:EndTree()
Endif

BYI->(DbSetOrder(2))
If BYI->(DbSeek(xFilial("BYI")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)))
	oTree:AddTree("Opcionais do usuario"+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","OPC"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
	While ! BYI->(Eof()) .And. BYI->(BYI_FILIAL+BYI_OPEREA+BYI_CODREA+BYI_CODOPE+BYI_CODEMP+BYI_MATRIC) == ;
		xFilial("BYI")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
		//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BHV")
			If BYI->( FieldPos("BYI_CODAJS") ) > 0
				If (lAjuste .and. BYI->BYI_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYI->BYI_CODAJS))
					BYI->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
		
		cQuebUsr := BYI->BYI_TIPREG
		
		BA1->(DbSetOrder(2))
		BA1->(DbSeek(xFilial("BA1")+BYI->(BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG)))
		
		oTree:AddTree("Valores Opcionais do usuario "+AllTrim(BA1->BA1_NOMUSR)+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","OPC"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
		
		While ! BYI->(Eof()) .And. BYI->(BYI_FILIAL+BYI_OPEREA+BYI_CODREA+BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG) == ;
			xFilial("BYI")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)+cQuebUsr
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
			//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If PLSALIASEX("BHV")
				If BYI->( FieldPos("BYI_CODAJS") ) > 0
					If (lAjuste .and. BYI->BYI_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYI->BYI_CODAJS))
						BYI->( dbSkip() )
						Loop
					Endif
				Endif
			Endif
			
			BI3->(DbSetOrder(1))
			BI3->(DbSeek(xFilial("BI3")+BYI->(BYI_CODOPE+BYI_CODOPC+BYI_VEROPC)))
			
			cQuebOpc := cQuebUsr+BYI->(BYI_CODOPC+BYI_VEROPC)
			
			oTree:AddTree("Opcional "+BI3->BI3_CODIGO+" - "+AllTrim(BI3->BI3_DESCRI)+Space(100) ,.T.,"PRODUTO","PRODUTO","PRODUTO","PRODUTO","OPC"+BHL->(BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
			
			While ! BYI->(Eof()) .And. BYI->(BYI_FILIAL+BYI_OPEREA+BYI_CODREA+BYI_CODOPE+BYI_CODEMP+BYI_MATRIC+BYI_TIPREG+BYI_CODOPC+BYI_VEROPC) == ;
				xFilial("BYI")+BHL->(BHL_OPEREA+BHL_CODREA+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC)+cQuebOpc
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Seleciona apenas os itens do ajuste selecionado...                       Ё
				//Ё Tive que fazer assim para nao alterar as chaves de todas as tabelas...   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If PLSALIASEX("BHV")
					If BYI->( FieldPos("BYI_CODAJS") ) > 0
						If (lAjuste .and. BYI->BYI_CODAJS <> BHV->BHV_CODAJS) .or. (!lAjuste .and. !Empty(BYI->BYI_CODAJS))
							BYI->( dbSkip() )
							Loop
						Endif
					Endif
				Endif
				cFaixa  := "Faixa Etaria "+AllTrim(Str(BYI->BYI_IDAINI))+" a "+AllTrim(Str(BYI->BYI_IDAFIN))+" anos"
				cValor1 := "Valor Antigo "+AllTrim(Str(BYI->BYI_VLRANT,17,2))
				cValor2 := "Valor Apos Reajuste "+AllTrim(Str(BYI->BYI_VLRREA,17,2))
				cIndice := "Indice Aplicado "+AllTrim(Str(BYI->BYI_PERREA,17,4))
				
				oTree:AddTree(cFaixa+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYI->BYI_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
				
				oTree:AddTree(cValor1+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYI->BYI_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
				oTree:EndTree()
				
				oTree:AddTree(cValor2+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYI->BYI_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
				oTree:EndTree()
				
				oTree:AddTree(cIndice+Space(100) ,.T.,"SALARIOS","SALARIOS","SALARIOS","SALARIOS","VLR"+BHL->(BYI->BYI_CODFAI+BHL_CODOPE+BHL_CODEMP+BHL_MATRIC))
				oTree:EndTree()
				
				oTree:EndTree()
				BYI->(DbSkip())
			Enddo
			oTree:EndTree()
		Enddo
		oTree:EndTree()
	Enddo
	oTree:EndTree()
Endif

oTree:EndTree()
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  ЁanalisaindiceЁ Autor Ё Tulio Cesar        Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta a arvore para a familia posicionada...                 Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function AnalisaIndice(cIndice,cAno,cMes,nIndice,lZeraNiv)
LOCAL nIndRet := 0
LOCAL cTipoIn := ""
LOCAL nPosInd

If ! Empty(cIndice)
	nIndRet := PLSBUSIND(cIndice,cAno,cMes)
	cTipoIn := "Indice "+cIndice
	
	nPosInd := Ascan(aIndices,{|x| x[1] == cIndice})
	If nPosInd == 0
		AAD->(DbSetOrder(1))
		If AAD->(DbSeek(xFilial("AAD")+cIndice))
			cTipoIn += " ("+AllTrim(AAD->AAD_DESCRI)+") "
		Endif
		aadd(aIndices,{AAD->AAD_CODIND,AllTrim(AAD->AAD_DESCRI)})
	Else
		cTipoIn += " ("+aIndices[nPosInd,2]+") "
	Endif
Else
	nIndRet := nIndice
	cTipoIn := "Indice Informado Fixo"
Endif

If lZeraNiv
	nIndRet:=0
Endif

Return({nIndRet,cTipoIn})

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA101VGR  Ё Autor Ё Tulio Cesar        Ё Data Ё 07.05.2004 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Valida a confirmacao do reajuste...                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA101VGR(aErrosGrp,aGrupos,aContratos,aSubCon,aFamilias,aErrosFam,aErrosSub,aErrosUsr)
LOCAL aErros    := {}
LOCAL lHelp     := .F.
LOCAL aRet
LOCAL lRet      := .T.
LOCAL lFamilias := (Len(aFamilias)>0)

If Len(aErrosGrp) > 0
	aadd(aErros,{"Existem "+AllTrim(Str(Len(aErrosGrp)))+" erro(s) no nivel do Grupo Empresa"})
	lHelp := .T.
Endif

If Len(aErrosFam) > 0
	aadd(aErros,{"Existem "+AllTrim(Str(Len(aErrosFam)))+" erro(s) no nivel da Familia"})
	lHelp := .T.
Endif

If Len(aErrosUsr) > 0
	aadd(aErros,{"Existem "+AllTrim(Str(Len(aErrosUsr)))+" erro(s) no nivel do Usuario"})
	lHelp := .T.
Endif

If Len(aErrosSub) > 0
	aadd(aErros,{"Existem "+AllTrim(Str(Len(aErrosSub)))+" erro(s) no nivel do subcontrato"})
	lHelp := .T.
Endif

If Len(aFamilias) == 0  .and. !(GetNewPar('MV_PLRSUBV',.F.))
	aadd(aErros,{"Nao existem familias para reajuste"})
	lHelp := .T.
Endif

If lHelp
	If lFamilias
		aRet := PLSCRIGEN(aErros,{ {"Criticas","@C",300} },"Existem Criticas Para Este Processamento... Confirma a geracao ???")
		lRet := aRet[1]
	Else
		aRet := PLSCRIGEN(aErros,{ {"Criticas","@C",300} },"Existem Criticas FATAIS Para Este Processamento... o reajuste nao podera ser executado...")
		lRet := .F.
	Endif
Endif

Return(lRet)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSSUBREAJ  Ё Autor Ё Tulio Cesar        Ё Data Ё 14.05.2004 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Retorna os meses de reajuste para um subcontrato             Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSSUBREAJ(cCodOpe,cCodEmp,cContrato,cVerCon,cSubContrato,cVerSub,cAno,cMes)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define as variaveis da rotina...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cSQL
LOCAL cTipoAna
LOCAL cConsTmp
LOCAL nIndice
LOCAL cIndice
LOCAL cDesIn
LOCAL lIndVld
LOCAL lProduto
LOCAL lOpcional
LOCAL lTaxa
LOCAL lOK         := .F.
LOCAL nOrdBG9     := BG9->(IndexOrd())
LOCAL nRecBG9     := BG9->(Recno())
LOCAL bRest       := { || BG9->(DbSetOrder(nOrdBG9)), BG9->(DbGoTo(nRecBG9)) }
LOCAL dDatAnalise := ctod("01/"+cMes+"/"+cAno)
LOCAL cNivRea	  := ''

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicione no grupo empresa...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BG9->(DbSetOrder(1))
BG9->(DbSeek(xFilial("BG9")+cCodOpe+cCodEmp))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for PJ leitura dos niveis grupo empresa, contrato e subcontrato...    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BG9->BG9_TIPO == "2"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Subcontrato...                                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := " SELECT BYA_TIPOIN,BYA_TIPO,BYA_PERRRL,BYA_INDRRL,BYA_PROD,BYA_OPC,BYA_TAX FROM "+RetSQLName("BYA")+" WHERE "
	cSQL += " BYA_FILIAL = '"+xFilial("BYA")+"' AND "
	cSQL += " BYA_CODINT = '"+cCodOpe+"' AND "
	cSQL += " BYA_CODIGO = '"+cCodEmp+"' AND "
	cSQL += " BYA_NUMCON = '"+cContrato+"' AND "
	cSQL += " BYA_VERSAO = '"+cVerCon+"' AND "
	cSQL += " BYA_SUBCON = '"+cSubContrato+"' AND "
	cSQL += " BYA_VERSUB = '"+cVerSub+"' AND "
	cSQL += " ( BYA_ANO = '    ' OR BYA_ANO = '"+cAno+"' ) AND "
	cSQL += " ( BYA_MES = '  ' OR BYA_MES = '"+cMes+"' ) AND "
	
	If BYA->(FieldPos("BYA_DATAIN")) > 0
		cSQL += " ( BYA_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
	Endif
	
	cSQL += " D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
	
	If ! PLS101->(Eof())
		cTipoAna  := PLS101->BYA_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
		cConsTmp  := PLS101->BYA_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
		nIndice   := PLS101->BYA_PERRRL  //Percentual de reajuste...
		cIndice   := PLS101->BYA_INDRRL  //indice de reajuste...
		lIndVld   := .T.
		lProduto  := PLS101->BYA_PROD == "1"
		lOpcional := PLS101->BYA_OPC == "1"
		lTaxa     := PLS101->BYA_TAX == "1"
		lOK       := .T.
		cNivRea	:= '3'
	Endif
	PLS101->(DbCloseArea())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Contrato...                                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ! lOK
		cSQL := " SELECT BH3_TIPOIN,BH3_TIPO,BH3_PERRRL,BH3_INDRRL,BH3_PROD,BH3_OPC,BH3_TAX FROM "+RetSQLName("BH3")+" WHERE "
		cSQL += " BH3_FILIAL = '"+xFilial("BH3")+"' AND "
		cSQL += " BH3_CODINT = '"+cCodOpe+"' AND "
		cSQL += " BH3_CODIGO = '"+cCodEmp+"' AND "
		cSQL += " BH3_NUMCON = '"+cContrato+"' AND "
		cSQL += " BH3_VERSAO = '"+cVerCon+"' AND "
		cSQL += " ( BH3_ANO = '    ' OR BH3_ANO = '"+cAno+"' ) AND "
		cSQL += " ( BH3_MES = '  ' OR BH3_MES = '"+cMes+"' ) AND "
		
		If BH3->(FieldPos("BH3_DATAIN")) > 0
			cSQL += " ( BH3_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
		Endif
		
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL := ChangeQuery(cSQL)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
		
		If ! PLS101->(Eof())
			cTipoAna  := PLS101->BH3_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
			cConsTmp  := PLS101->BH3_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
			nIndice   := PLS101->BH3_PERRRL  //Percentual de reajuste...
			cIndice   := PLS101->BH3_INDRRL  //indice de reajuste...
			lIndVld   := .T.
			lProduto  := PLS101->BH3_PROD == "1"
			lOpcional := PLS101->BH3_OPC == "1"
			lTaxa     := PLS101->BH3_TAX == "1"
			lOK       := .T.
			cNivRea   := '2'
		Endif
		PLS101->(DbCloseArea())
	Endif
Endif

If ( BG9->BG9_TIPO == "1" ) .Or. (BG9->BG9_TIPO == "2" .And. ! lOK)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PF...                                                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := " SELECT BGJ_TIPOIN,BGJ_TIPO,BGJ_PERRRL,BGJ_INDRRL,BGJ_PROD,BGJ_OPC,BGJ_TAX FROM "+RetSQLName("BGJ")+" WHERE "
	cSQL += " BGJ_FILIAL = '"+xFilial("BGJ")+"' AND "
	cSQL += " BGJ_CODINT = '"+cCodOpe+"' AND "
	cSQL += " BGJ_CODIGO = '"+cCodEmp+"' AND "
	cSQL += " ( BGJ_ANO = '    ' OR BGJ_ANO = '"+cAno+"' ) AND "
	cSQL += " ( BGJ_MES = '  ' OR BGJ_MES = '"+cMes+"' ) AND "
	
	If BGJ->(FieldPos("BGJ_DATAIN")) > 0
		cSQL += " ( BGJ_DATAIN <= '"+dtos(dDatAnalise)+"' ) AND "
	Endif
	
	cSQL += " D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"PLS101",.T.,.T.)
	
	If ! PLS101->(Eof())
		cTipoAna  := PLS101->BGJ_TIPOIN  //"1" - Considerar aniversario da familia   "2" - Considerar aniversario do subcontrato
		cConsTmp  := PLS101->BGJ_TIPO    //"1" - Incondicional  "2" - Familias com mais de 12 anos de plano
		nIndice   := PLS101->BGJ_PERRRL  //Percentual de reajuste...
		cIndice   := PLS101->BGJ_INDRRL  //indice de reajuste...
		lIndVld   := .T.
		lProduto  := PLS101->BGJ_PROD == "1"
		lOpcional := PLS101->BGJ_OPC == "1"
		lTaxa     := PLS101->BGJ_TAX == "1"
		lOK       := .T.
		cNivRea   := '1'
	Endif
	PLS101->(DbCloseArea())
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no indice...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lOK
	AAD->(DbSetOrder(1))
	AAD->(DbSeek(xFilial("AAD")+cIndice))
	cDesIn := AAD->AAD_DESCRI
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o indice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  ! Empty(cIndice)
	nIndice := PLSBUSIND(cIndice,cAno,cMes)
Endif

Eval(bRest)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorno da funcao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return({lOK,cTipoAna,cConsTmp,nIndice,cIndice,lIndVld,lProduto,lOpcional,lTaxa,cDesIn,cNivRea})


Static Function SaiRotina(nQtdArv,lFlag)
If nQtdArv >= 100 .And. lFlag
	MsgInfo("Existem muitos dados a serem apresentados. Utilize o relatorio de reajuste para consultar esse reajuste por completo.")
	lFlag := .F.
Endif

Return



/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA101AJS╨Autor  ЁGeraldo Felix Junior╨ Data Ё  25/01/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Ajuste de precos de um reajuste.                           ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Rotina de reajuste.                                       ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA101AJS()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variavels da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aRotina   := { { "Pesquisar"  ,'AxPesqui'  , 0 , K_Pesquisar	},;
{ "Visualizar" ,'PLSA101Mov',  0 , K_Visualizar 	},;
{ "Incluir"    ,'PLSA101Mov',  0 , K_Incluir    	},;
{ "Alterar"    ,'NAODISP',  0 , K_Alterar    	},;
{ "Excluir"    ,'PLSA101Mov',  0 , K_Excluir    	} }
PRIVATE cCadastro := "ajuste"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Liga flag de ajuste...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lAjuste := .T.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa integriada do dicionario de dados...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! PLSALIASEX("BHV")
	MsgStop("Para utilizar esta funcao deve ser atualizada a versao do pls. Familia BHV")
	Return
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro por codigo do reajuste...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFil := "@BHV_FILIAL = '"+xFilial("BHV")+"' AND BHV_CODINT = '"+BHW->BHW_CODINT+"' AND BHV_CODREA = '"+BHW->BHW_CODREA+"' AND D_E_L_E_T_ = ' '"
DbSelectArea("BHV")
BHV->(DbSetOrder(1))
SET FILTER TO &cFil

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define browse...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BHV->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BHV"))
BHV->(DbClearFilter())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desliga flag de ajuste ao sair da rotina de ajuste...                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lAjuste := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(Nil)


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA101ADDSUB╨Autor  ЁGeraldo Felix Junior╨ Data Ё  01/26/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Alimenta a matriz de subcontratos envolvidos no reajuste...╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function A101ADDSUB(cIndice,nIndice,cAnoMesInd,aSubCon,aErrosSub,;
cTipoAna,cConsTmp,lIndVld,lProduto,lOpcional,lTaxa,;
cCodPla,cVerPla,lOnlyLook,cNivel,lFranquia,lZeraNiv,lSubvazio,cInCpFx,nInCpFx,cInCpPe,nInCpPe)

LOCAL aRetInd 		:= {}
LOCAL nIndRet 		:= 0
LOCAL nInReCpF := 0.0
LOCAL nInReCpP := 0.0
LOCAL cTipoIn
LOCAL cTpInCpF := ""
LOCAL cTpInCpP := ""
LOCAL lReaPla   := .F.
LOCAL lReaCop   := .F.

Default lOnlyLook 	:= .F.
Default lSubvazio   := .F.
Default cInCpFx		:= ""
Default nInCpFx		:= 0.0
Default cInCpPe		:= ""
Default nInCpPe		:= 0.0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza o preco no subcontrato, para valores de venda/novos funcionariosЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRetInd := AnalisaIndice(cIndice,Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),nIndice,lZeraNiv)
nIndRet := aRetInd[1]
cTipoIn := aRetInd[2]

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o o indice para reajuste da coparticipacao tipo valor fixo...      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRetInd := AnalisaIndice(cInCpFx,Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),nInCpFx,.F.)
nInReCpF := aRetInd[1]
cTpInCpF := aRetInd[2]

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o o indice para reajuste da coparticipacao tipo percentual...      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRetInd := AnalisaIndice(cInCpPe,Subs(cAnoMesInd,1,4),Subs(cAnoMesInd,5,2),nInCpPe,.F.)
nInReCpP := aRetInd[1]
cTpInCpP := aRetInd[2]

lReaPla := Iif(nIndRet == 0 .And. !lZeraNiv, .F., .T.)
lReaCop := Iif(nInReCpF == 0 .And. nInReCpP == 0, .F., .T.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Nao achei... retorno de erro...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lReaPla .and. !lReaCop
	                      
	if !lSubvazio
		aadd(aErrosSub,{"01","Indice nao encontrado para o subcontrato Indice ["+cIndice+"] Ano ["+Subs(cAnoMesInd,1,4)+"] Mes ["+Subs(cAnoMesInd,5,2)+"]" ,;
		BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,;
		BA3->BA3_SUBCON,BA3->BA3_VERSUB,cCodPla,cVerPla})
	Else
		aadd(aErrosSub,{"01","Indice nao encontrado para o subcontrato Indice ["+cIndice+"] Ano ["+Subs(cAnoMesInd,1,4)+"] Mes ["+Subs(cAnoMesInd,5,2)+"]" ,;
	    TRBBQC->BQC_CODINT,TRBBQC->BQC_CODEMP,TRBBQC->BQC_NUMCON,TRBBQC->BQC_VERCON,;
		TRBBQC->BQC_SUBCON,TRBBQC->BQC_VERSUB,cCodPla,cVerPla})
	
	Endif
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza a quebra por subcontrato...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("BQC")
	aadd(aSubCon,{Iif(!lSubvazio,BG9->BG9_CODIGO+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB,BG9->BG9_CODIGO+TRBBQC->BQC_NUMCON+TRBBQC->BQC_VERCON+TRBBQC->BQC_SUBCON+TRBBQC->BQC_VERSUB),;
	nIndRet,;
	0,;
	BG9->BG9_CODIGO,;
	Iif(!lsubVazio,BA3->BA3_CONEMP,TRBBQC->BQC_NUMCON),;
	Iif(!lSubVazio,BA3->BA3_VERCON,TRBBQC->BQC_VERCON),;
	Iif(!lSubVazio,BA3->BA3_SUBCON,TRBBQC->BQC_SUBCON),;
	Iif(!lSubVazio,BA3->BA3_VERSUB,TRBBQC->BQC_VERSUB),;
	cTipoAna,;
	cConsTmp,;
	nIndice,;
	cIndice,;
	lIndVld,;
	lProduto,;
	lOpcional,;
	lTaxa,;
	cCodPla,;
	cVerPla,;
	lOnlyLook,;
	cNivel,;
	lFranquia,;
	lZeraNiv ,;
	Iif(!lSubVazio,BQC->BQC_CIE309,""),;
	Iif(!lSubvazio,BA3->BA3_CODINT,BQC->BQC_CODINT),;
	nInReCpF,;
	Str(nInReCpF,12,4),;
	cTpInCpF,;
	cInCpFx,;
	nInReCpP,;
	Str(nInReCpP,12,4),;
	cTpInCpP,;
	cInCpPe,;
	lReaPla,;
	lReaCop})
Endif

Return({aSubCon,aErrosSub})


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA101Con╨Autor  ЁGeraldo Felix Junior╨ Data Ё  08/21/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁConsulta reajustes...                                       ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA101Con()

LOCAL cPerg 	:= 'PLA101'
LOCAL cCodTit   := SuperGetMv("MV_PLCDTIT")
LOCAL aReaFam	:= {}
LOCAL n_		:= 0
LOCAL m_		:= 0
// Cria o SX1
CriaSX1(cPerg)

If !Pergunte(cPerg)
	Return()
Endif

cCodOpe := mv_par01

cEmpDe	:= mv_par02
cEmpAte := mv_par03

cConDe  := mv_par04
cConAte := mv_par05

cSubDe	:= mv_par06
cSubAte := mv_par07

cFamDe	:= mv_par08
cFamAte := mv_par09

cMesDe  := mv_par10
cAnoDe  := mv_par11

cMesAte := mv_par12
cAnoAte := mv_par13

cTipo	:= mv_par14

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )


aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE "Historico de reajuste de "+Iif(cTipo==1,"pessoa fisica.","pessoa juridica") FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

If cTipo == 2
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Seleciona registros do reajuste de pessoa juridica...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSql := "SELECT * FROM "+RetSqlName("BPF")+" WHERE BPF_FILIAL = '"+xFilial("BPF")+"' "
	cSql += "AND BPF_OPEREA = '"+cCodOpe+"' "
	cSql += "AND BPF_CODEMP >= '"+cEmpDe+"' "
	cSql += "AND BPF_CODEMP <= '"+cEmpAte+"' "
	cSql += "AND BPF_CONEMP >= '"+cConDe+"' "
	cSql += "AND BPF_CONEMP <= '"+cConAte+"' "
	cSql += "AND BPF_SUBCON >= '"+cSubDe+"' "
	cSql += "AND BPF_SUBCON <= '"+cSubAte+"' "
	cSql += "AND BPF_ANOREA+BPF_MESREA >= '"+cAnoDe+cMesDe+"' "
	cSql += "AND BPF_ANOREA+BPF_MESREA <= '"+cAnoAte+cMesAte+"' "
	cSql += "AND D_E_L_E_T_ = ' ' "
	
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Seleciona registros do reajuste de pessoa fisica...                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSql := " SELECT * FROM "+RetSqlName("BHL")+", "+RetSqlName("BA3")+" WHERE BHL_FILIAL = '"+xFilial("BHL")+"' "
	cSql += " AND BA3_FILIAL = '"+xFilial("BA3")+"' "
	cSql += " AND BHL_OPEREA = BA3_CODINT "
	cSql += " AND BHL_CODEMP = BA3_CODEMP "
	cSql += " AND BHL_MATRIC = BA3_MATRIC "
	cSql += " AND BHL_OPEREA = '"+cCodOpe+"' "
	cSql += " AND BHL_CODEMP >= '"+cEmpDe+"' "
	cSql += " AND BHL_CODEMP <= '"+cEmpAte+"' "
	cSql += " AND BHL_MATRIC >= '"+cFamDe+"' "
	cSql += " AND BHL_MATRIC <= '"+cFamAte+"' "
	cSql += " AND BHL_ANOREA+BHL_MESREA >= '"+cAnoDe+cMesDe+"' "
	cSql += " AND BHL_ANOREA+BHL_MESREA <= '"+cAnoAte+cMesAte+"' "
	cSql += " AND BA3_TIPOUS = '1' "
	cSql += " AND "+RetSqlName("BHL")+".D_E_L_E_T_ = ' ' "
	cSql += " AND "+RetSqlName("BA3")+".D_E_L_E_T_ = ' ' "
	
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa query e monta area de trabalho temporaria...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cSql := ChangeQuery(cSql)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),"TRB121",.T.,.T.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define objeto dbTree para exibir a arvore da consulta...                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oTree := DbTree():New(015,005,aPosObj[1][4]-1,aPosObj[1][3]-1,oDlg,nil,nil,.T.,nil)
oTree:BuildTrb(400, 17)
oTree:BeginUpdate()
oTree:SetEnable()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Adiciona itens a arvore da consulta...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While !TRB121->( Eof() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a arvore do grupo empresa...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cTipo == 2
		cCodInt := TRB121->BPF_OPEREA
		cCodEmp := TRB121->BPF_CODEMP
		oTree:AddTree("Grupo empresa: "+TRB121->BPF_CODEMP+" - "+AllTrim(TRB121->BPF_DESEMP),.T.,"BR_VERDE","BR_VERDE","BR_VERDE","BR_VERDE","GRP"+TRB121->BPF_CODEMP)
		
		While !TRB121->( Eof() ) .and. TRB121->BPF_OPEREA == cCodInt .and.;
			TRB121->BPF_CODEMP == cCodEmp
			
			cConEmp := TRB121->BPF_CONEMP
			cVerCon := TRB121->BPF_VERCON
			oTree:AddTree("Contrato: "+TRB121->BPF_CONEMP+" - "+TRB121->BPF_VERCON,.T.,"BR_AMARELO",;
			"BR_AMARELO","BR_AMARELO","BR_AMARELO","GRP"+TRB121->BPF_CONEMP+TRB121->BPF_VERCON)
			
			While !TRB121->( Eof() ) .and. TRB121->BPF_OPEREA == cCodInt .and.;
				TRB121->BPF_CODEMP == cCodEmp .and.;
				TRB121->BPF_CONEMP == cConEmp .and.;
				TRB121->BPF_VERCON == cVercon
				
				cSubCon := TRB121->BPF_SUBCON
				cVersub := TRB121->BPF_VERSUB
				BQC->( dbSetorder(01) )
				BQC->( msSeek(xFilial("BQC")+cCodint+cCodEmp+cConEmp+cVerCon+cSubCon+cVerCon) )
				cDesSub 	:= BQC->BQC_DESCRI
				cInclusao   := dtoc(BQC->BQC_DATCON)
				
				oTree:AddTree("Subcontrato: "+TRB121->BPF_SUBCON+" - "+TRB121->BPF_VERSUB+' - '+cDesSub+;
				Space(03)+"Dt Inclusao: "+cInclusao,.T.,"BR_AZUL",;
				"BR_AZUL","BR_AZUL","BR_AZUL","GRP"+TRB121->BPF_SUBCON+TRB121->BPF_VERSUB)
				
				While !TRB121->( Eof() ) .and. TRB121->BPF_OPEREA == cCodInt .and.;
					TRB121->BPF_CODEMP == cCodEmp .and.;
					TRB121->BPF_CONEMP == cConEmp .and.;
					TRB121->BPF_VERCON == cVercon .and.;
					TRB121->BPF_SUBCON == cSubCon .and.;
					TRB121->BPF_VERSUB == cVersub
					
					oTree:AddTree("Mes / Ano do reajuste - "+TRB121->BPF_MESREA+" / "+TRB121->BPF_ANOREA+;
					" - "+Alltrim(Str(TRB121->BPF_INDREA))+"%",.T.,"BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","BR_VERMELHO","SUB"+TRB121->BPF_CODEMP)
					
					oTree:EndTree()
					TRB121->( dbSkip() )
				Enddo
				oTree:EndTree()
			Enddo
			oTree:EndTree()
		Enddo
		oTree:EndTree()
	Else
		cCodInt := TRB121->BHL_CODOPE
		cCodEmp := TRB121->BHL_CODEMP
		cDesEmp := Posicione("BG9", 1, xFilial("BG9")+cCodInt+cCodEmp, "BG9_DESCRI")
		oTree:AddTree("Grupo empresa: "+cCodEmp+" - "+cDesemp,.T.,"BR_VERDE","BR_VERDE","BR_VERDE","BR_VERDE","GRP"+TRB121->BHL_CODEMP)
		
		While !TRB121->( Eof() ) .and. TRB121->BHL_OPEREA == cCodInt .and.;
			TRB121->BHL_CODEMP == cCodEmp
			
			cMatric := TRB121->BHL_MATRIC
			cCodRea := TRB121->BHL_CODREA
			
			BA1->( dbSetorder(01) )
			BA1->( msSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cCodTit) )
			cTitular := Alltrim(BA1->BA1_NOMUSR)
			cInclusao:= dToc(BA1->BA1_DATINC)
			
			BP7->( dbSetorder(02) )
			If BP7->( dbSeek(xFilial("BP7")+cCodInt+cCodRea+cCodInt+cCodEmp+cMatric) )
				cMatFam := (TRB121->BHL_CODOPE+TRB121->BHL_CODEMP+TRB121->BHL_MATRIC)
				
				// Cria matriz com quebras por familia...
				If Len(aReaFam) == 0
					Aadd(aReaFam, {cMatFam,{},cTitular,cInclusao})
					nPos := Len(aReaFam)
				Else
					If (nPos := Ascan(aReaFam, {|x| x[1] == cMatFam})) == 0
						Aadd(aReaFam, {cMatFam,{},cTitular,cInclusao})
						nPos := Len(aReaFam)
					Endif
				Endif
				
				// Alimenta matriz com detalhes do reajuste.
				While !TRB121->( Eof() ) .and. TRB121->BHL_OPEREA == cCodInt .and.;
					TRB121->BHL_CODEMP == cCodEmp .and.;
					TRB121->BHL_MATRIC == cMatric
					
					Aadd( aReaFam[nPos][2], {TRB121->BHL_MESREA,TRB121->BHL_ANOREA,Alltrim(Str(BP7->BP7_PERREA))} )
					
					TRB121->( dbSkip() )
					
				Enddo
				
				
			Else
				TRB121->( dbSkip() )
				
			Endif
		Enddo
		
		// Ordena matriz por familia
		//		Asort(aReaFam,,, {|x| x[1] < x[1]})
		
		For n_ := 1 To Len(aReaFam)
			// monta string para ser recuperada no ITEM.
			cCargo := ("FAM"+aReaFam[n_][1])
			
			oTree:AddTree("Familia: "+aReaFam[n_][1]+" - "+"Titular: "+aReaFam[n_][3]+;
			Space(03)+"Dt Inclusao: "+aReaFam[n_][4],;
			.T.,;
			"BR_AMARELO",;
			"BR_AMARELO",;
			"BR_AMARELO",;
			"BR_AMARELO",;
			cCargo)
			
			For m_ := 1 To Len(aReaFam[n_][2])
				// Alimenta itens do noh de familias.
				oTree:AddTreeItem("Mes / Ano do reajuste - "+aReaFam[n_][2][m_][1]+"/"+aReaFam[n_][2][m_][2]+" - "+;
				aReaFam[n_][2][m_][3]+'%',.T.,"BR_VERMELHO",cCargo)
			Next
			// Finaliza o noh de familias.
			oTree:EndTree()
			
		Next
		
		oTree:EndTree()
	Endif
	
Enddo
oTree:EndUpdate()
TRB121->( dbClosearea() )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},.F.,{})

Return()

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё CriaSX1   Ё Autor ЁGeraldo Felix Junior. Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Atualiza SX1                                               Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function CriaSX1(cPerg)

Local aRegs	:=	{}

aadd(aRegs,{cPerg,"01","Operadora ?                   ","","","mv_ch1","C", 4,0,0,"G",""           ,"mv_par01",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B89PLS"	,""})
aadd(aRegs,{cPerg,"02","Grupo/empresa de ?            ","","","mv_ch2","C", 4,0,0,"G",""           ,"mv_par02",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B7APLS"	,""})
aadd(aRegs,{cPerg,"03","Grupo/empresa ate ?           ","","","mv_ch3","C", 4,0,0,"G",""           ,"mv_par03",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B7APLS"	,""})
aadd(aRegs,{cPerg,"04","Contrato de ?                 ","","","mv_ch4","C",12,0,0,"G",""           ,"mv_par04",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B7BPLS"	,""})
aadd(aRegs,{cPerg,"05","Contrato ate ?                ","","","mv_ch5","C",12,0,0,"G",""           ,"mv_par05",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B7BPLS"	,""})
aadd(aRegs,{cPerg,"06","Subcontrato de ?              ","","","mv_ch6","C", 9,0,0,"G",""           ,"mv_par06",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B7CPLS"	,""})
aadd(aRegs,{cPerg,"07","Subcontrato ate ?             ","","","mv_ch7","C", 9,0,0,"G",""           ,"mv_par07",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","B7CPLS"	,""})
aadd(aRegs,{cPerg,"08","Matricula de ?                ","","","mv_ch8","C", 6,0,0,"G",""           ,"mv_par08",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   	  	,""})
aadd(aRegs,{cPerg,"09","Matricula ate ?               ","","","mv_ch9","C", 6,0,0,"G",""           ,"mv_par09",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   	  	,""})
aadd(aRegs,{cPerg,"10","Mes de?                       ","","","mv_cha","C", 2,0,0,"G","PlsVldMes()","mv_par10",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   	  	,""})
aadd(aRegs,{cPerg,"11","Ano de?                       ","","","mv_chb","C", 4,0,0,"G",""           ,"mv_par11",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   		,""})
aadd(aRegs,{cPerg,"12","Mes ate?                      ","","","mv_chc","C", 2,0,0,"G","PlsVldMes()","mv_par12",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   		,""})
aadd(aRegs,{cPerg,"13","Ano ate?                      ","","","mv_chd","C", 4,0,0,"G",""           ,"mv_par13",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   		,""})
aadd(aRegs,{cPerg,"14","Tipo contrato ?               ","","","mv_che","N", 1,0,0,"C",""           ,"mv_par14","Fisica"      	,"","","","","Juridica"       	,"","","","",""         	  ,"","","","",""       ,"","","","","","","","",""   		,""})

PlsVldPerg( aRegs )

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё26/12/2006Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё		1 - Pesquisa e Posiciona em um Banco de Dados         Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ "Pesquisar"  ,'AxPesqui'  ,  0 , K_Pesquisar  , 0, .F.},;
{ "Visualizar" ,'PLSA101Mov',  0 , K_Visualizar , 0, Nil},;
{ "Incluir"    ,'PLSA101Mov',  0 , K_Incluir    , 0, Nil},;
{ "Ajuste "    ,'PLSA101Ajs',  0 , K_Incluir    , 0, Nil},;
{ "Excluir"    ,'PLSA101Mov',  0 , K_Alterar    , 0, Nil},;
{ "Historico"  ,'PLSA101Con',  0 , K_Visualizar , 0, Nil}}
Return(aRotina)

Function PL101ReaCo(cCodRea, cAnoMes, cNivel, cChave, nInCpFx, nInCpPe)

LOCAL dDataReaj
LOCAL n_
LOCAL nI
LOCAL cAlias
LOCAL aFields
LOCAL aCpos
LOCAL cTrab
LOCAL cDado
LOCAL aNewData
LOCAL cCpoFix
LOCAL cCpoPer
LOCAL cCpoVin
LOCAL cCpoVfi
LOCAL cCpoSeq
LOCAL cCpoVig

LOCAL nCont		:= 0
LOCAL nVReCoF	:= 0.0
LOCAL nVReCoP	:= 0.0

dDataReaj := SToD(cAnoMes+"01")
For n_ := 1 To Len(aCopart)

	// Apenas alias referente a familia...
	If aCopart[n_][4] <> cNivel
		Loop
	Endif
	
	cAlias := aCopart[n_][1]

	// Carrega campos da tabela sendo tratada
	aFields := &(cAlias)->( DbStruct() )
	
	// Seleciona area
	dbSelectArea(cAlias)
	&(cAlias)->( dbSetorder(aCopart[n_][2]) )
	
	// Pesquisa chave
	&(cAlias)->( msSeek(xFilial(cAlias)+cChave) )
	
	// Precessa registros...

	// Inicialmente, fecha as vigЙncias e guarda no aNewData,
	// os novos registros a serem criados
	aNewData := {}
	While !(&(cAlias)->(Eof())) .and. &((cAlias)->(aCopart[n_][3])) == xFilial(cAlias)+cChave
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Apura o valor com o reajuste...                                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cCpoFix := cAlias+"->"+aCopart[n_][5]
		cCpoPer := cAlias+"->"+aCopart[n_][6]
		cCpoVin := cAlias+"->"+aCopart[n_][7]
		cCpoVfi := cAlias+"->"+aCopart[n_][8]
		cCpoSeq := cAlias+"->"+aCopart[n_][9]
		cCpoVig := cAlias+"->"+aCopart[n_][10]

		nVReCoF := IIF( lArredonda, Round(&(cCpoFix) + ((&(cCpoFix)*nInCpFx)/100),2), NoRound(&(cCpoFix) + ((&(cCpoFix)*nInCpFx)/100),2) )
		nVReCoP := IIF( lArredonda, Round(&(cCpoPer) + ((&(cCpoPer)*nInCpPe)/100),2), NoRound(&(cCpoPer) + ((&(cCpoPer)*nInCpPe)/100),2) )

		If Empty(&(cCpoVfi)) //XXX_VIGFIN
			&(cAlias)->(Reclock(cAlias, .F.))
			&(cCpoVfi) := dDataReaj - 1
			&(cCpoVig) := cCodRea
			&(cAlias)->(MsUnlock())

			aCpos := {}
			For nCont := 1 To Len(aFields)
				cTrab := cAlias+"->"+aFields[nCont,1]
				cDado := &cTrab
				aadd(aCpos,{cTrab,cDado})
			Next

			aadd(aNewData, {cAlias, aCpos, cCodRea, ' ', dDataReaj, STod(''), nVReCoF, nVReCoP})
		EndIf
		&(cAlias)->( dbSkip() )
	Enddo

	// Depois cria os registros armazenados em aNewData
	For nI := 1 To Len(aNewData)
		&(aNewData[nI][1])->(Reclock(aNewData[nI][1],.T.))
			For nCont := 1 To Len(aNewData[nI][2])
				&(aNewData[nI][2][nCont][1]) := aNewData[nI][2][nCont][2]
			Next	
			// aqui eu preencho qual sequencia do reajuste que gravou a vigencia
			// vamos usar isso na hora de excluir o reajuste teremos que excluir este registro					
			&(cCpoSeq) := aNewData[nI][3]
			&(cCpoVig) := aNewData[nI][4]
			&(cCpoVin) := aNewData[nI][5]
			&(cCpoVfi) := aNewData[nI][6]
			&(cCpoFix) := aNewData[nI][7]
			&(cCpoPer) := aNewData[nI][8]
		&(aNewData[nI][1])->(MsUnlock())
	Next
Next
Return

Function PL101DelCo(cCodOpe, cCodRea, lAjuste, cDeEmpresa, cAteEmpresa, lExcluiLote)

	Local n_ := 0
	Local cAlias := ""
	Local nCont := 1

	Default lAjuste := .F.
	Default cDeEmpresa := ""
	Default cAteEmpresa := ""
	Default lExcluiLote := .T.

	If cCodRea == ""
		Return
	EndIf

	// Para cada nМvel de coparticipacao
	For n_ := 1 To Len(aCopart)

		cAlias := aCopart[n_][1]
		cCpoVfi := cAlias+"->"+aCopart[n_][8]
		cCpoSeq := cAlias+"->"+aCopart[n_][9]
		cCpoVig := cAlias+"->"+aCopart[n_][10]

		// Primeiro, excluo novos registros criados pelo reajuste sendo excluМdo;
		cSql := " SELECT R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" "+cAlias
		cSql += " WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "+aCopart[n_][11]+" = '"+cCodOpe+"' AND "+aCopart[n_][9]+" = '"+cCodRea+"' AND D_E_L_E_T_ = ' '" 
		PlsQuery(cSql,'TRB')
		aRecs := {}
		While !TRB->(Eof())
			aadd(aRecs,TRB->REC)
			TRB->(DbSkip())
		Enddo
		If Len(aRecs) > 5
			TRB->(DbCloseArea())
			Return
		EndIf
		DbSelectArea(cAlias)
		For nCont:=1 to Len(aRecs)
			DbGoTo(aRecs[nCont])

			If !lAjuste .And. !ChckExcEmpresa(cAlias, cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				Loop
			EndIf

			Reclock(cAlias,.F.)
				DbDelete()
			MsUnlock()
		Next
		TRB->(DbCloseArea())

		// Depois reabro as vigЙncias que foram fechadas pelo reajuste sendo excluМdo.
		cSql := " SELECT R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+"  "+cAlias
		cSql += " WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "+aCopart[n_][11]+" = '"+cCodOpe+"' AND "+aCopart[n_][10]+" = '"+cCodRea+"' AND D_E_L_E_T_ = ' '" 
		PlsQuery(cSql,'TRB')
		aRecs := {}
		While !TRB->(Eof())
			aadd(aRecs,TRB->REC)
			TRB->(DbSkip())
		Enddo
		If Len(aRecs) > 5
			TRB->(DbCloseArea())
			Return
		EndIf
		DbSelectArea(cAlias)
		For nCont:=1 to Len(aRecs)
			DbGoTo(aRecs[nCont])

			If !lAjuste .And. !ChckExcEmpresa(cAlias, cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				Loop
			EndIf

			Reclock(cAlias,.F.)
				&(cCpoVfi) := Stod('')
				&(cCpoVig) := ' '
			MsUnlock()
		Next
	Next

Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL101ExcFr╨Autor  ЁGeraldo Felix Jr.   ╨ Data Ё  21/12/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Exclui reajuste da franquia...                             ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL101ExcFr(cCodRea, cCodOpe, lAjuste, cDeEmpresa, cAteEmpresa, lExcluiLote)

	Local nCnt := 0
	Local nPos := 0
	Local nPos1 := 0
	Local aChaves := {}
	Local aRegB0B := {}
	
	Default lAjuste := .F.
	Default cDeEmpresa := ""
	Default cAteEmpresa := ""
	Default lExcluiLote := .T.

	// Seleciona area
	dbSelectArea("B0B")

	// Cria matriz com chaves de acesso aos registros de franquia.
	Aadd(aChaves, {'1',02, "B0B_FILIAL+B0B_CODINT+B0B_CODEMP+B0B_NUMCON+B0B_VERCON+B0B_SUBCON+B0B_VERSUB+B0B_CODPRO+B0B_VERPRO"})
	Aadd(aChaves, {'2',04, "B0B_FILIAL+B0B_CODINT+B0B_CODEMP+B0B_MATRIC"})
	Aadd(aChaves, {'3',05, "B0B_FILIAL+B0B_CODINT+B0B_CODEMP+B0B_MATRIC+B0B_TIPREG"})

	// A exclusao do reajuste da franquia parte do historico.
	If B0B->( dbSeek(xFilial("B0B")+cCodOpe+cCodRea) )
		While !B0B->( Eof() ) .and. B0B->B0B_CODINT == cCodOpe .and. B0B->B0B_CODREA == cCodRea

			If !lAjuste .And. !ChckExcEmpresa("B0B", cDeEmpresa, cAteEmpresa)
				lExcluiLote := .F.
				B0B->(DbSkip())
				Loop
			EndIf

			cAlias := B0B->B0B_ALIAS
			If (nPos := AScan(aFranquia,{|x| x[1] == cAlias})) > 0
				
				If !Empty(B0B->B0B_RECREA)
					
					dbSelectArea(cAlias)
					&(cAlias)->(DbGoTo(Val(B0B->B0B_RECREA))) //Recno da tabela de reajuste de exclusЦo
					
					&(cAlias)->( RecLock(cAlias, .F.) )
						&(cAlias+"->"+cAlias+"_LIMFRA") 	:= B0B->B0B_VLRANT
						&(cAlias+"->"+cAlias+"_ANOMES") 	:= ''
						&(cAlias+"->"+cAlias+"_VLRANT") 	:= 0	
					&(cAlias)->( MsUnlock() )
				
				Else
				
					nPos1 := Ascan(aChaves,  {|x| x[1] == aFranquia[nPos][5]} )
					If nPos1 > 0
						
						&(cAlias)->( dbSetorder(aFranquia[nPos][02]) )
						If &(cAlias)->( dbSeek(B0B->(&(aChaves[nPos1][3]))) )
							&(cAlias)->( RecLock(cAlias, .F.) )
							
							If &(cAlias)->( FieldPos(aFranquia[nPos][4]) ) > 0
								&(cAlias+"->"+aFranquia[nPos][4]) 	:= B0B->B0B_VLRANT
							Endif
							If &(cAlias)->( FieldPos(cAlias+"_ANOMES") ) > 0
								&(cAlias+"->"+cAlias+"_ANOMES") 	:= ''
							Endif
							If &(cAlias)->( FieldPos(cAlias+"_VLRANT") ) > 0
								&(cAlias+"->"+cAlias+"_VLRANT") 	:= 0
							Endif
							
							&(cAlias)->( MsUnlock() )
						Endif
					Endif
				Endif
			Endif
			
			Aadd(aRegB0B, B0B->( Recno() ))
			B0B->( dbSkip() )
		Enddo
	Endif

	// Deleta o historico do reajuste da franquia...
	For nCnt := 1 To Len(aRegB0B)
		B0B->( dbGoto(aRegB0B[nCnt]) )
		If !B0B->( Eof() )
			B0B->( RecLock("B0B", .F.) )
			B0B->( dbDelete() )
			B0B->( MsUnlock() )
		Endif
	Next

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}CheckCampCopart 
	Verifica a existЙncia dos campos passado por parБmetro
	@author V.Alves
	@since 24/08/2021
	@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckCampCopart(aCampos)
	Local nCont := 0
	Local cAlias := ""
	Local lRetorno := .T.
	Default aCampos := {}

	If Len(aCampos) > 0
		For nCont := 1 to Len(aCampos)
			cAlias := Substr(aCampos[nCont],1,3)
			If !(cAlias)->(FieldPos(aCampos[nCont]))
				lRetorno := .F.
				Exit
			EndIF
		Next
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} ConfExcLote 
Pergunta de ConfirmaГЦo quando for realizada a exclusЦo somente de 
algumas Empresas

@author Vinicius Queiros Teixeira
@since 27/12/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ConfExcLote(nOpcao, lAjuste)

	Local lConfirma := .T.

	Default nOpcao := 0
	Default lAjuste := .F.

	If nOpcao == K_Excluir .And. !lAjuste
		If (!Empty(M->BHW_EMPDE) .And. BHW->BHW_EMPDE <> M->BHW_EMPDE) .Or. (!Empty(M->BHW_EMPATE) .And. BHW->BHW_EMPATE <> M->BHW_EMPATE)
			
			If !MsgNoYes(STR0001+"<b>"+M->BHW_EMPDE+"</b> a <b>"+M->BHW_EMPATE+"</b>?", STR0002) // "Tem certeza que deseja excluir somente os reajustes das empresas: " ; "ConfirmaГЦo"
				lConfirma := .F.			
			EndIf
		
		EndIf
	EndIf

Return lConfirma


//-------------------------------------------------------------------
/*/{Protheus.doc} ChckExcEmpresa 
Verifica se a empresa posicionada da tabela informada serА excluida
de acordo com o range de Empresas De e AtИ

@author Vinicius Queiros Teixeira
@since 27/12/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ChckExcEmpresa(cTabela, cDeEmpresa, cAteEmpresa)

	Local lExclui := .T.
	Local cEmpresa := ""

	Default cTabela := ""
	Default cDeEmpresa := ""
	Default cAteEmpresa := ""

	If !Empty(cTabela) .And. !Empty(cDeEmpresa) .And. !Empty(cAteEmpresa)
		
		Do Case
			Case (cTabela == "BPB" .Or. cTabela == "BPV")
				cEmpresa := Substr(&(cTabela+"->"+cTabela+"_MATRIC"), 5, 4)
				
			Case &(cTabela+"->(FieldPos('"+cTabela+"_CODEMP"+"'))") > 0
				cEmpresa := &(cTabela+"->"+cTabela+"_CODEMP")

			Case &(cTabela+"->(FieldPos('"+cTabela+"_CODIGO"+"'))") > 0
				cEmpresa := &(cTabela+"->"+cTabela+"_CODIGO")
						
		EndCase

		If !Empty(cEmpresa)
			lExclui := cEmpresa >= cDeEmpresa .And. cEmpresa <= cAteEmpresa
		EndIf

	EndIf

Return lExclui