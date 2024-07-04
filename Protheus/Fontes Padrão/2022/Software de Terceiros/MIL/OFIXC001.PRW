// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 63     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "tbiconn.ch"
#include "Protheus.ch"
#include "OFIXC001.ch"
#include "FWCommand.ch"
#include "TOPCONN.CH"

/*/{Protheus.doc} mil_ver
Versao do fonte modelo novo
@author Andre Luis Almeida
@since 29/01/2018
@version undefined

@type function
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "005214_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIXC001   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Pecas de Orcamento                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXC001(cProduto,cFilOld)
Local aObjects := {} , aInfo := {}, aPos := {}, nCntFor
Local aSizeHalf := MsAdvSize(.t.)
Local lRet := .f.
Local cBKPCodIte := ""

Local cSlvVis
Local cSlvInc
Local cSlvAlt
Local cSlvExc
Local lBkpVarV := .f.
Local lBkpVarI := .f.
Local lBkpVarA := .f.
Local lBkpVarE := .f.
Local cFilAntBkp := cFilAnt

Local lVAI_ACEDET := VAI->(ColumnPos('VAI_ACEDET')) > 0

Default cProduto := ' '
Default cFilOld := cFilAnt

Private lNNRVDADMS  := NNR->(ColumnPos('NNR_VDADMS')) > 0

Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
Private aIteRelP := {{"","","",0,0,"","",""}}
Private nEstoque
Private cGrupo := space(TamSx3("B1_GRUPO")[1])
Private cCodIte := space(TamSx3("B1_CODITE")[1])
Private xItem := {}
Private oXC01Tecnico
Private aNewBot := {{"PEDIDO"  ,{|| OX001REQCPR(cGrupo,cCodIte,1,.t.) }	, STR0054 } ,;
					{"SOLICITA",{|| OX001VENPER(cGrupo,cCodIte) }		, STR0055 } ,;
					{"COMPTITL",{|| OFIOC460(,,cGrupo,cCodIte) }			, STR0056 } ,;
					{"MAQFOTO" ,{|| OX001KEYF6(.t.) }                      ,("<F6> "+STR0072)}} // Foto(s)/Video(s)

cFilAnt := cFilOld // Para Consultar a Peça da Filial escolhida, independente da filial gravada no registro posicionado no Browse

If ( ExistBlock("OX001OPC") )
	aAdd(aNewBot ,{"E5", {|| ExecBlock("OX001OPC",.f.,.f.,{ 3,"1",cGrupo,cCodIte} ) }, STR0057 } ) // Opc.Avanç.
EndIf

ProcessMessage()

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

SET KEY VK_F4 TO
SETKEY(VK_F6,{|| OX001KEYF6(.t.) } )
//
oXC01Tecnico := DMS_Tecnico():New()
oXC01Tecnico:SetTecByUserID(__cUserID)

If TYPE("VISUALIZA") <> "U"
	lBkpVarV := .t.
	cSlvVis  := VISUALIZA
Endif
If TYPE("INCLUI") <> "U"
	lBkpVarI := .t.
	cSlvInc  := INCLUI
Endif
If TYPE("ALTERA") <> "U"
	lBkpVarA := .t.
	cSlvAlt  := ALTERA
Endif
If TYPE("EXCLUI") <> "U"
	lBkpVarE := .t.
	cSlvExc := EXCLUI
Endif

VISUALIZA = .t.
INCLUI    = .f.
ALTERA    = .f.
EXCLUI    = .f.

//
if Type("cApCodMar")=="U"
	cApCodMar := ""
	cApModVei := ""
	cApSegMod := ""
	cApAno    := Replicate("0",IIf(VE3->(ColumnPos("VE3_ANOMOD"))>0,TamSX3("VE3_ANOMOD")[1],4))
endif
//
cChave     := space(TamSx3("B1_CODITE")[1])
cGrupo     := space(TamSx3("B1_GRUPO")[1])
cGruite    := cGrupo
cCodIte    := space(TamSx3("B1_CODITE")[1])
cDesc      := space(TamSx3("B1_DESC")[1])
cGrupoAnt  := ""
cCodIteAnt := ""
//
// Monta os F3 conforme o SX3
//
DBSelectArea("SX3")
DBSetOrder(2)
DBSeek("VS3_CODITE")
cF3CODITE := "B16" // Busca pela Variavel cGruIte
DBSeek("VS3_GRUITE")
cF3GRUITE := SX3->X3_F3

// Fator de reducao de 0.8
for nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
next
//
// ########################################################################
// # Montagem do vetor com informacoes adicionais                         #
// ########################################################################
aVetInfo := {}
aAdd(aVetInfo,{STR0001						,	'iif(!Empty(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),"")'	,	NIL					,	"@!"							})
aAdd(aVetInfo,{STR0002						,	"OC001RSIT()"								,	NIL		   			,	"@!"							})

If !lVAI_ACEDET .or. VAI->VAI_ACEDET <> "0"
	aAdd(aVetInfo,{STR0003					,	"OC001RPRE()"								,	"OC001BPRECO()"		,	SB1->(X3PICTURE("B1_PRV1"))		})
Else
	aAdd(aVetInfo,{STR0003					,	"OC001RPRE()"								,	NIL					,	SB1->(X3PICTURE("B1_PRV1"))		})
EndIf

aAdd(aVetInfo,{STR0004						,	"OC001REST()"								,	"OC001BESTOQUE()"	,	SB2->(X3PICTURE("B2_QATU")) 	})
aAdd(aVetInfo,{"'"+RetTitle("B1_ESTSEG")+"'",	'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTSEG")'	,	NIL					,	SB1->(X3PICTURE("B1_ESTSEG")) 	})
aAdd(aVetInfo,{STR0077						,	"OC001UM(SB1->B1_UM)"	 	    			,	NIL				   ,	SB1->(X3PICTURE("B1_UM")) 	})
If SB1->(ColumnPos("B1_ESTMIN")) > 0
	aAdd(aVetInfo,{"'"+RetTitle("B1_ESTMIN")+"'",'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTMIN")',	NIL					,	SB1->(X3PICTURE("B1_ESTMIN")) 	})
Else
	aAdd(aVetInfo,{"'"+RetTitle("B1_EMIN")+"'",'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_EMIN")'	,	NIL					,	SB1->(X3PICTURE("B1_EMIN"))	 	})
endif
aAdd(aVetInfo,{STR0006						,	"OC001RCLAS()"								,	NIL					,	"@!"							})
aAdd(aVetInfo,{"'"+RetTitle("B5_CODCAI")+"'",	"SB5->B5_CODCAI"							,	NIL					,	"@!"							})
if GetNewPar("MV_CUSBAL","S") == "S"
	aAdd(aVetInfo,{"'"+RetTitle("B2_CM1")+"'"	,	"SB2->B2_CM1"								,	NIL					,	SB2->(X3PICTURE("B2_CM1"))		})
Endif
aAdd(aVetInfo,{"'"+RetTitle("B1_PRV1")+"'"	,	'FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")'	,	NIL					,	SB1->(X3PICTURE("B1_PRV1"))		})
aAdd(aVetInfo,{"'"+RetTitle("B1_QE")+"'"	,	"SB1->B1_QE"								,	NIL					,	SB1->(X3PICTURE("B1_QE"))		})
aAdd(aVetInfo,{"'"+RetTitle("B1_PESO")+"'"	,	"SB1->B1_PESO"								,	NIL					,	SB1->(X3PICTURE("B1_PESO"))		})
aAdd(aVetInfo,{"'"+RetTitle("B1_GRUDES")+"'",	"SB1->B1_GRUDES"							,	NIL					,	"@!"				})
aAdd(aVetInfo,{"'"+RetTitle("B1_DTREFP1")+"'",	"SB1->B1_DTREFP1"							,	NIL					,	"@D"				})
// ########################################################################
// # Montagem do vetor com informacoes adicionais                         #
// ########################################################################
// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aVetInfo
If ExistBlock("OC001AVI")
	ExecBlock("OC001AVI",.f.,.f.)
EndIf
If ExistBlock("OC001INI")
	If !ExecBlock("OC001INI",.f.,.f.)
		//Se retorna falso, restaura a variavel antes de sair
		If lBkpVarV
			VISUALIZA := cSlvVis
		Endif
		If lBkpVarI
			INCLUI := cSlvInc
		Endif
		If lBkpVarA
			ALTERA := cSlvAlt
		Endif
		If lBkpVarE
			EXCLUI := cSlvExc
		Endif
		Return
	EndIf
EndIf
// ########################################################################
// # Montagem das informacoes de posicionamento da consulta               #
// ########################################################################
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }// Tamanho total da tela
AAdd( aObjects, { 0, 04, .T., .f. } )
AAdd( aObjects, { 0, 08, .T., .f. } )
AAdd( aObjects, { 0, 08, .T., .f. } )
for nCntFor := 1 to Len(aVetInfo) step 2
	AAdd( aObjects, { 0, 08, .T., .f. } )
next
AAdd( aObjects, { 0, 08, .T., .T. } )
aPos := MsObjSize( aInfo, aObjects )
dyc := (aPos[1,4] - aPos[1,2])
dyc2 := ((aPos[1,4] - aPos[1,2]) / 2) + 4	// step horizontal
_nSpc := 40
_nLarg := dyc2 - _nSpc - 10
nBtnSize := 25
// ########################################################################
// # Montagem da tela com informacoes fixas                               #
// ########################################################################
DEFINE MSDIALOG oDlgCP FROM aSizeHalf[7],0 TO aSizeHalf[6]+23,aSizeHalf[5]-9 TITLE STR0013 OF oMainWnd PIXEL
// Linha 1
oSay01 := TSay():New(aPos[2,1],aPos[2,2],{|| STR0014 },oDlgCP,,oFnt3,,,,.t.,CLR_BLACK,,_nSpc,8)
@ aPos[2,1],aPos[2,2] + _nSpc GET o_Chave VAR  cChave SIZE _nLarg,8 OF oDlgCP PIXEL
o_Chave:bValid  	 := {|U| (IIF(Empty(cChave),.t.,(FS_VERALT() .and. FG_POSSB1('cChave','SB1->B1_COD')) .and. OC001PREPEC(cChave))) }
//
oSay02 := TSay():New(aPos[2,1],aPos[2,2]+dyc2,{|| STR0015 },oDlgCP,,oFnt3,,,,.t.,CLR_BLACK,,_nSpc,8)
@ aPos[2,1],aPos[2,2]+dyc2 + _nSpc MSGET o_Grupo VAR cGrupo F3 cF3GRUITE VALID (OC001PREPEC()) SIZE _nLarg,8 PIXEL OF oDlgCP
// Linha 2
oSay01 := TSay():New(aPos[3,1],aPos[3,2],{|| STR0016 },oDlgCP,,oFnt3,,,,.t.,CLR_BLACK,,_nSpc,8)
@ aPos[3,1],aPos[3,2] + _nSpc MSGET o_CodIte VAR cCodIte F3 cF3CODITE VALID IIF(Empty(cCodIte),.t.,FG_POSSB1('cCodIte','SB1->B1_CODITE','cGrupo')) .and. (OC001PREPEC()) SIZE _nLarg,8 PIXEL OF oDlgCP
//
oSay02 := TSay():New(aPos[3,1],aPos[3,2]+dyc2,{|| STR0017 },oDlgCP,,oFnt3,,,,.t.,CLR_BLACK,,_nSpc,8)
@ aPos[3,1],aPos[3,2]+dyc2 + _nSpc MSGET o_Desc VAR cDesc SIZE _nLarg - nBtnSize ,8 PIXEL OF oDlgCP
@ aPos[3,1],aPos[3,2]+dyc2 + _nSpc + _nLarg - nBtnSize BUTTON oBtn1 PROMPT (STR0018) OF oDlgCP SIZE nBtnSize,10 PIXEL ACTION OC001BDESC()
// ########################################################################
// # Montagem da tela com informacoes adicionais                          #
// ########################################################################
aVetResp := {}
for nCntFor := 1 to Len(aVetInfo) step 2
	nIndObj  :=  INT(nCntFor/2)+4
	// Coluna 1 das informacoes adicionais
	aAdd(aVetResp,"")
	cCpoMacro := "{|| "+aVetInfo[nCntFor,1]+"}"
	oSay := TSay():New(aPos[nIndObj,1],aPos[nIndObj,2],&cCpoMacro,oDlgCP,,oFnt3,,,,.t.,CLR_BLACK,,_nSpc,8)
	cBlkGet 	:= "{ |u| if(PCount()>0,aVetResp["+STRZERO(nCntFor,2)+"]:=u,aVetResp["+STRZERO(nCntFor,2)+"]		)}"
	cBlkCampo := "aVetResp["+STRZERO(nCntFor,2)+"]"
	cBlkPict :=  "aVetInfo["+STRZERO(nCntFor,2)+",4]"
	if aVetInfo[nCntFor,3] == NIL
		oGet1:= TGet():New(aPos[nIndObj,1], aPos[nIndObj,2] + _nSpc,&(cBlkGet), oDlgCP,_nLarg,8,&(cBlkPict),{|o| .T.},,,,,,.T.,,,{|o| .F.},,,,,,,cBlkCampo)
	else
		oGet1:= TGet():New(aPos[nIndObj,1], aPos[nIndObj,2] + _nSpc,&(cBlkGet), oDlgCP,_nLarg - nBtnSize,8,&(cBlkPict),{|o| .T.},,,,,,.T.,,,{|o| .F.},,,,,,,cBlkCampo)
		cBtnAction := "{|| "+ aVetInfo[nCntFor,3]+"}"
		oBtn := TButton():New( aPos[nIndObj,1],aPos[nIndObj,2] + _nSpc + _nLarg - nBtnSize ,STR0018, oDlgCP, &(cBtnAction), nBtnSize, 10,,,,.t.)
	endif
	// Coluna 2 das informacoes adicionais
	if nCntFor + 1 <= Len(aVetInfo)
		aAdd(aVetResp,"")
		cCpoMacro := "{|| "+aVetInfo[nCntFor+1,1]+"}"
		oSay := TSay():New(aPos[nIndObj,1],aPos[nIndObj,2]+dyc2,&cCpoMacro		,oDlgCP,,oFnt3,,,,.t.,CLR_BLACK,,_nSpc,8)
		cBlkGet 	:= "{ |u| if(PCount()>0,aVetResp["+STRZERO(nCntFor+1,2)+"]:=u,aVetResp["+STRZERO(nCntFor+1,2)+"]		)}"
		cBlkCampo := "aVetResp["+STRZERO(nCntFor+1,2)+"]"
		cBlkPict :=  "aVetInfo["+STRZERO(nCntFor+1,2)+",4]"
		if aVetInfo[nCntFor+1,3] == NIL
			oGet1:= TGet():New(aPos[nIndObj,1],aPos[nIndObj,2]+dyc2 + _nSpc,&(cBlkGet), oDlgCP,_nLarg,8,&(cBlkPict),{|o| .T.},,,,,,.T.,,,{|o| .F.},,,,,,,cBlkCampo)
		else
			oGet1:= TGet():New(aPos[nIndObj,1],aPos[nIndObj,2]+dyc2 + _nSpc,&(cBlkGet), oDlgCP,_nLarg - nBtnSize,8,&(cBlkPict),{|o| .T.},,,,,,.T.,,,{|o| .F.},,,,,,,cBlkCampo)
			cBtnAction := "{|| "+ aVetInfo[nCntFor+1,3]+"}"
			oBtn := TButton():New( aPos[nIndObj,1],aPos[nIndObj,2] + dyc2 + _nSpc + _nLarg - nBtnSize ,STR0018, oDlgCP, &(cBtnAction), nBtnSize, 10,,,,.t.)
		endif
	endif

next
// ########################################################################
// # Montagem da listbox contendo informacoes dos itens relacionados      #
// ########################################################################
@ aPos[Len(aPos),1],aPos[Len(aPos),2] LISTBOX oLbIteRelP FIELDS HEADER ;
(STR0051), ;
(STR0052), ;
(STR0053), ;
(STR0019), ;
(STR0020), ;
(STR0021), ;
(STR0022), ;
(STR0023) ;
COLSIZES 0.05 * dyc, 0.125 * dyc, 0.125 * dyc, 0.035 * dyc, 0.125 * dyc, 0.175 * dyc, 0.125 * dyc, 0.09 * dyc ;
SIZE aPos[Len(aPos),4] - aPos[Len(aPos),2], aPos[Len(aPos),3] - aPos[Len(aPos),1] OF oDlgCP ON DBLCLICK ( OC001SOBEREL(oLbIteRelP:nAt), oLbIteRelP:Refresh() ) PIXEL
//
oLbIteRelP:SetArray(aIteRelP)
//
oLbIteRelP:bLine := { || { aIteRelP[oLbIteRelP:nAt,6],;
aIteRelP[oLbIteRelP:nAt,7],;
aIteRelP[oLbIteRelP:nAt,8],;
aIteRelP[oLbIteRelP:nAt,1],;
aIteRelP[oLbIteRelP:nAt,2],;
aIteRelP[oLbIteRelP:nAt,3],;
FG_AlinVlrs(Transform(aIteRelP[oLbIteRelP:nAt,4],SB2->(X3PICTURE("B2_QATU")))),;
FG_AlinVlrs(Transform(aIteRelP[oLbIteRelP:nAt,5],"@E 999,999,999.99"))}}
// ########################################################################
// # Verifica se houve passagem de parametro contendo algum codigo (SB1)  #
// ########################################################################
if !Empty(cProduto)
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1")+cProduto)
	M->VS3_GRUITE := SB1->B1_GRUPO
	M->VS3_CODITE := SB1->B1_CODITE
	OC001PREPEC(cProduto)
else
	M->VS3_GRUITE := space(TamSx3("VS3_GRUITE")[1])
	M->VS3_CODITE := space(TamSx3("VS3_CODITE")[1])
endif
//
If !FM_PILHA("OFIOM020") .and. ( !lVAI_ACEDET .or. VAI->VAI_ACEDET <> "0" ) // Permissão para visualizar a Consulta Detalhada
	cBtnConAction := "{|| OC001CONANA()}"
	oBtnCon := TButton():New( aPos[Len(aPos),1]+(aPos[Len(aPos),3] - aPos[Len(aPos),1]+1),aPos[Len(aPos),2],STR0078, oDlgCP, &(cBtnConAction), nBtnSize+50, 10,,,,.t.)
Endif

If ExistBlock("OC001TEL")
	ExecBlock("OC001TEL",.f.,.f.)
EndIf

ACTIVATE MSDIALOG oDlgCP CENTER ON INIT (EnchoiceBar(oDlgCP,{|| lRet := .t. ,OC001POSPEC(),OFXC0010018_PontoEntradaEnchoice("CONFIRMAR"),oDlgCP:End()},{ || OFXC0010018_PontoEntradaEnchoice("CANCELAR"),oDlgCP:End() },,aNewBot))

//
SETKEY(VK_F4,{|| OX001KEYF4() })
SET KEY VK_F6 TO

If lBkpVarV
	VISUALIZA := cSlvVis
Endif
If lBkpVarI
	INCLUI := cSlvInc
Endif
If lBkpVarA
	ALTERA := cSlvAlt
Endif
If lBkpVarE
	EXCLUI := cSlvExc
Endif
//
cFilAnt := cFilAntBkp
//
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OC001BDESC | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Tela de consulta por descricao                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC001BDESC()
Local cAliasSB1  := "cQrySB1"
Local cQuery     := ""
Local nPesqAspa  := ""
Local cGruVei    := GetNewPar("MV_GRUVEI","VEI")+space(4-len(GetNewPar("MV_GRUVEI","VEI")))
Local nsaldo     := 0
Local cLOCALI2   := ""
Local cDesSQL    := ""
Local nOpca      := 0
Local bTroca     := { || stuff(get_descri,AT(",",get_descri),1,"%") }
Local lLOCAOM110 := ExistBlock("LOCAOM110")
Local cFilSB2    := xFilial("SB2")
//
If Empty(cDesc)
	Return .f.
Endif
//
if Select(cAliasSB1) > 0
	(cAliasSB1)->(dbCloseArea())
Endif
//
nOpcAplica := 0
//

if GetNewPar("MV_FAPLPEC","0")=="1"

	DEFINE MSDIALOG oAplica FROM 000,000 TO 9,27 TITLE STR0026 OF oMainWnd

	M->VV1_CODMAR := IIF(cApCodMar =="",SPACE(TamSX3("VV2_CODMAR")[1]),cApCodMar)
	M->VV1_MODVEI := IIF(cApModVei =="",SPACE(TamSX3("VV2_MODVEI")[1]),cApModVei)
	M->VV1_SEGMOD := IIF(cApSegMod =="",SPACE(TamSX3("VV2_SEGMOD")[1]),cApSegMod)

	@ 004,005 SAY (STR0051) SIZE 50,08 OF oAplica PIXEL COLOR CLR_BLACK
	@ 004,032 MSGET M->VV1_CODMAR F3 "VE1" VALID (Empty(M->VV1_CODMAR).or.ExistCpo("VE1",M->VV1_CODMAR)) SIZE 75,8 PIXEL OF oAplica
	@ 014,005 SAY (STR0067) SIZE 50,08 OF oAplica PIXEL COLOR CLR_BLACK
	@ 014,032 MSGET M->VV1_MODVEI F3 "MCV" VALID (Empty(M->VV1_MODVEI).or.ExistCpo("VV2",M->VV1_CODMAR+M->VV1_MODVEI)) SIZE 75,8 PIXEL OF oAplica
	@ 024,005 SAY (STR0068) SIZE 50,08 OF oAplica PIXEL COLOR CLR_BLACK
	@ 024,032 MSGET M->VV1_SEGMOD F3 "VX0" VALID (Empty(M->VV1_SEGMOD).or.ExistCpo("VVX",M->VV1_CODMAR+M->VV1_SEGMOD)) SIZE 75,8 PIXEL OF oAplica
	@ 034,005 SAY (STR0069) SIZE 50,08 OF oAplica PIXEL COLOR CLR_BLACK
	If VE3->(ColumnPos("VE3_ANOMOD")) > 0
		@ 034,032 MSGET cApAno PICTURE X3Picture("VE3_ANOMOD") VALID (OC001PREPEC()) SIZE 35,8 PIXEL OF oAplica
	EndIf
	@ 045,005 BUTTON oBtnAp1 PROMPT (STR0070) SIZE 100,08 OF oAplica PIXEL ACTION (nOpcAplica := 1,oAplica:End()) // OK
	@ 055,005 BUTTON oBtnAp2 PROMPT (STR0071) SIZE 100,08 OF oAplica PIXEL ACTION (nOpcAplica := 0,oAplica:End()) // CANCELAR

	ACTIVATE MSDIALOG oAplica CENTER
Endif
if GetNewPar("MV_FAPLPEC","0")=="2"
   FS_CATEGORIA()
endif
//

//
if nOpcAplica == 1
	cApCodMar := M->VV1_CODMAR
	cApModVei := M->VV1_MODVEI
	cApSegMod := M->VV1_SEGMOD
endif
//
dbSelectArea("SB2")
dbSetOrder(1)
//
dbSelectArea("SB5")
dbSetOrder(1)
//
dbSelectArea("SB1")
dbSetOrder(3)
//
aArray := {}
cDesSQL := cDesc
// Retira do texto as ASPAS para frente (caso exista) //
nPesqAspa := AT("'",cDesSQL)
If nPesqAspa > 0
	If nPesqAspa == 1
		cDesSQL := space(len(SB1->B1_DESC))
	Else // nPesqAspa > 1
		cDesSQL := Left(cDesSQL,nPesqAspa-1)
	EndIf
	cDesc := cDesSQL
EndIf
nPesqAspa := AT('"',cDesSQL)
If nPesqAspa > 0
	If nPesqAspa == 1
		cDesSQL := space(len(SB1->B1_DESC))
	Else // nPesqAspa > 1
		cDesSQL := Left(cDesSQL,nPesqAspa-1)
	EndIf
	cDesc := cDesSQL
EndIf
//
while AT(",",cDesSQL) > 0
	cDesSQL := Eval(bTroca)
enddo
//
if GetNewPar("MV_FAPLPEC","0")$"01"
	cQuery := "SELECT SB1.R_E_C_N_O_ SB1REC, SB5.R_E_C_N_O_ SB5REC FROM "+RetSqlName("SB1")+" SB1 "
	if !Empty(cApCodMar) .or. !Empty(cApModVei) .or. !Empty(cApSegMod)
		cQuery += "JOIN "+RetSqlName("VE3")+" VE3 ON ( VE3.VE3_FILIAL='"+xFilial("VE3")+"' AND VE3.VE3_GRUITE=SB1.B1_GRUPO AND VE3.VE3_CODITE=SB1.B1_CODITE AND VE3.VE3_CODMAR='"+cApCodMar+"' AND "
		if !Empty(cApModVei)
			cQuery += " ( VE3.VE3_MODVEI='"+cApModVei+"' OR VE3.VE3_MODVEI=' ' ) AND "
		Endif
		if !Empty(cApSegMod)
			cQuery += " ( VE3.VE3_SEGMOD='"+cApSegMod+"' OR VE3.VE3_SEGMOD=' ' ) AND "
		endif
		if val(cApAno) > 0	.and. VE3->(ColumnPos("VE3_ANOMOD")) > 0
			cQuery += " ( VE3.VE3_ANOMOD='"+cApAno+"' OR VE3.VE3_ANOMOD=' ' )  AND "
		endif
		cQuery += " VE3.D_E_L_E_T_=' ') "
	endif
	cQuery += "LEFT JOIN "+RetSqlName("SB5")+" SB5  ON ( SB5.B5_FILIAL='"+xFilial("SB5")+ "' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+ "' AND "
	cQuery += " SB1.B1_DESC LIKE '"+alltrim(cDesSQL)+"%' AND "
	cQuery += " SB1.B1_GRUPO<>'"+cGruVei+"' AND "
	cQuery += " SB1.D_E_L_E_T_ = ' '"
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
	Do While !( cAliasSB1 )->( Eof() )
		SB1->(dbGoto((cAliasSB1)->SB1REC))
		nSaldo := OC001REST()
		cLOCALI2 := ""
		if lLOCAOM110
			cLOCALI2 := ExecBlock("LOCAOM110",.f.,.f.,{ SB1->B1_COD })
		Else
			if (cAliasSB1)->SB5REC > 0
				SB5->(dbGoto((cAliasSB1)->SB5REC))
				cLOCALI2 := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
			endif
		endif
		aAdd(aArray,{ SB1->B1_DESC , SB1->B1_GRUPO , SB1->B1_CODITE , cLOCALI2 , nSaldo , SB1->B1_COD })
		dbSelectArea(cAliasSB1)
		dbSkip()
	Enddo
	(cAliasSB1)->(dbCloseArea())
	DBSelectArea("SB1")
	//
	if Len(aArray) == 0
		MsgStop(STR0024,STR0025)
		Return(.f.)
	EndIf
	//
	nOpca := 0
	DBSelectArea("SB1")
	DBSetOrder(7)
	DEFINE MSDIALOG oDlgPesD FROM 000,000 TO 032,079 TITLE STR0026 OF oMainWnd
	//
	@ 003,003 SAY (STR0027 +": "+cDesc) SIZE 300,08 OF oDlgPesD PIXEL COLOR CLR_RED
	//
	@ 012,002 LISTBOX oLbDesc FIELDS HEADER  (STR0028),;
	(STR0029),;
	(STR0030),;
	(STR0031),;
	(STR0032);
	COLSIZES 90,20,50,50,50 SIZE 313,228 OF oDlgPesD ON DBLCLICK (OC001PREPEC(aArray[oLbDesc:nAt,6]),oDlgPesD:End()) PIXEL
	oLbDesc:SetArray(aArray)
	oLbDesc:bLine := { || { aArray[oLbDesc:nAt,1] , aArray[oLbDesc:nAt,2] , aArray[oLbDesc:nAt,3] , aArray[oLbDesc:nAt,4] , FG_AlinVlrs(Transform(aArray[oLbDesc:nAt,5],SB2->(X3PICTURE("B2_QATU")))) }}
	//
	ACTIVATE MSDIALOG oDlgPesD CENTER
	//
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |OC001BPRECO ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela de consulta de precos e almoxarifados das filiais      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001BPRECO()
Local i := 0, cont
Local aFilPrec  := {}
//
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial(aFilAtu[3], aFilAtu[4], aFilAtu[1], .f.)
Local nCont     := 0
Local cBkpFilAnt:= cFilAnt
//
wAlias := Alias()
wRecno := Recno()
//
cFilPrec :=  cFilAnt + " - " + FWFilialName()
//
//Levanta as Filiais
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd(aFilPrec, cFilAnt + " - " + FWFilialName())
Next
cFilAnt := cBkpFilAnt
//
FS_FILPREC(cFilAnt, 0)
//
DEFINE MSDIALOG xDlg TITLE (STR0033) From 14,30 to 43,100 of oMainWnd // Precos do Item
//
@ 040,002 SAY STR0058 SIZE 50,8 OF xDlg PIXEL COLOR CLR_BLACK // Filiais:
@ 038,025 MSCOMBOBOX oCBFilial VAR cFilPrec SIZE 140,08 COLOR CLR_BLACK ITEMS aFilPrec OF xDlg ON CHANGE FS_FILPREC(Left(cFilPrec, len(cFilAnt)), 1) PIXEL COLOR CLR_BLUE
@ 055,002 LISTBOX oLbHeadx FIELDS HEADER (STR0034),(STR0035) COLSIZES 180,60 SIZE 276,158 OF xDlg PIXEL // Formula / Valor
//
oLbHeadx:SetArray(xItem)
oLbHeadx:bLine := { || { xItem[oLbHeadx:nAt,1], xItem[oLbHeadx:nAt,2] }}
//
ACTIVATE MSDIALOG xDlg CENTER ON INIT (EnchoiceBar(xDlg, {|| xOpca := 1, xDlg:End()}, {|| xOpca := 2, xDlg:End()}))
//
dbSelectArea("VEG")
dbSetOrder(1)
dbSeek(xFilial("VEG"))
dbSelectArea(wAlias)
DbGoto(wRecno)
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OC001PREPEC ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche as informacoes da consulta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001PREPEC(cProd)
Default cProd := ""
if cGrupoAnt+cCodIteAnt == cGrupo+cCodIte
	return .f.
endif
cGruIte := cGrupo
if cProd != ""
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1")+cProd)
else
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1") + cGrupo + cCodIte)
endif
//
MsAguarde({|lEnd,cProd| OC001MSPEC(@lEnd)},STR0036,STR0037,.T.)
oLbIteRelP:SetFocus()

//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OC001MSPEC  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche as informacoes da consulta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001MSPEC(lEnd,cProd)
Local nSaldo := 0
Local cont  := 0
Local nCntFor
Default cProd := ""
// ######################################################################################
// # Verifica preenchimento do parametro para iniciar o preenchimento dos demais campos #
// ######################################################################################
MsProcTxt(STR0038)
ProcessMessage()
//
cChave := space(TamSx3("B1_CODITE")[1])
cGrupo := SB1->B1_GRUPO
cCodIte := FG_ITESUB(SB1->B1_GRUPO+SB1->B1_CODITE)
if ValType(cCodIte) == "A"
	cGrupo := cCodIte[1]
	cCodIte := cCodIte[2]
endif
//
if cCodIte != SB1->B1_CODITE  .or. cGrupo != SB1->B1_GRUPO
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+cGrupo + cCodIte)
endif
cDesc := SB1->B1_DESC
//
MsProcTxt(STR0039)
ProcessMessage()
dbSelectArea("VAI")
dbSetOrder(4)
if dbSeek(xFilial("VAI")+__cUserID)
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
endif
MsProcTxt(STR0040)
ProcessMessage()
//
DBSelectArea("SB1")
DBSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
//
dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
//
aIteRelP := FG_ITEREL(Nil,SB1->B1_GRUPO,SB1->B1_CODITE,GetNewPar("MV_FMLPECA",'"      "'))
For nCntFor := 1 to Len(aIteRelP)
	if !Empty(aIteRelP[nCntFor,1]+aIteRelP[nCntFor,2])
		DBSelectArea("SBM")
		DBSeek(xFilial("SBM")+aIteRelP[nCntFor,1])
		DbSelectArea("VE1")
		DBSetOrder(1)
		DBSeek(xFilial("VE1")+SBM->BM_CODMAR)
		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1")+aIteRelP[nCntFor,1]+aIteRelP[nCntFor,2])
		aAdd(aIteRelP[nCntFor],SBM->BM_CODMAR)
		aAdd(aIteRelP[nCntFor],VE1->VE1_DESMAR)
		aAdd(aIteRelP[nCntFor],SB1->B1_COD)
	Else
		aAdd(aIteRelP[nCntFor],"")
		aAdd(aIteRelP[nCntFor],"")
		aAdd(aIteRelP[nCntFor],"")
	Endif
next
//
If ( ExistBlock("OX001IRL") )
	aIteRelP := ExecBlock("OX001IRL",.f.,.f.,{aIteRelP})
EndIf
//
If len(aIteRelP) <= 0
	aIteRelP := {{"","","",0,0,"","",""}}
EndIf
//
if Type("oLbIteRelP")=="O"
	oLbIteRelP:nAt := 1
	oLbIteRelP:SetArray(aIteRelP)
	oLbIteRelP:bLine := { || { aIteRelP[oLbIteRelP:nAt,6],;
	aIteRelP[oLbIteRelP:nAt,7],;
	aIteRelP[oLbIteRelP:nAt,8],;
	aIteRelP[oLbIteRelP:nAt,1],;
	aIteRelP[oLbIteRelP:nAt,2],;
	aIteRelP[oLbIteRelP:nAt,3],;
	FG_AlinVlrs(Transform(aIteRelP[oLbIteRelP:nAt,4],SB2->(X3PICTURE("B2_QATU")))),;
	FG_AlinVlrs(Transform(aIteRelP[oLbIteRelP:nAt,5],"@E 999,999,999.99"))}}
	oLbIteRelP:Refresh()
	oSay01:SetFocus()
endif
//
DBSelectArea("SB1")
DBSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
//
dbSelectArea("SBM")
DBSetOrder(1)
DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
//
dbSelectArea("SB5")
dbSetOrder(1)
dbSeek(xFilial("SB5")+SB1->B1_COD)
//

for nCntFor := 1 to Len(aVetInfo)
	MsProcTxt(STR0041+" "+aVetInfo[nCntFor,1])
	ProcessMessage()
	aVetResp[nCntFor] := &(aVetInfo[nCntFor,2])
next
//
dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
MsProcTxt(STR0042)
ProcessMessage()
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OC001BESTOQUE³ Autor ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra Estoque das Pecas por Almoxarifado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001BESTOQUE()
Local aFilAtu     := FWArrFilAtu()
Local cNomFilial
Local nCont       := 0
Local cBkpFilAnt  := cFilAnt
Local nAuxSaldo   := 0
Local oFilial     := DMS_FilialHelper():New()
Local aAuxIteN := {}
Local aAuxIte  := {}
Local i

Private aIte1     := {}
Private aIteTer   := {}
Private aIteNTer  := {}
Private	nSaldoTot := 0
Private	nSaldoTotT:= 0
//
aAuxFilial := oFilial:GetAllFilGrupoEmpresa()
aAuxFilial := oFilial:FiltroFilial(aFilAtu[SM0_CODFIL], aAuxFilial, oXC01Tecnico:GetConfig("VAI_FTESTQ"))
For nCont := 1 to Len(aAuxFilial)
	cFilAnt := aAuxFilial[nCont]
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cGrupo+cCodIte)
	//
	cQuery := " SELECT NNR.NNR_CODIGO, NNR.NNR_DESCRI, SB2.B2_LOCAL, SB2.B2_QTNP, SB2.B2_QNPT, SB2.R_E_C_N_O_ AS B2RECNO "
	cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
	
	cQuery += " JOIN " + RetSqlName('NNR') + " NNR ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR.NNR_CODIGO = SB2.B2_LOCAL AND NNR.D_E_L_E_T_ = ' ' "
	if lNNRVDADMS
		cQuery += " AND NNR.NNR_VDADMS = '1' "
		cQuery += " WHERE SB2.B2_FILIAL = '"+xFilial('SB2')+"' 
	else
		cQuery += " WHERE SB2.B2_FILIAL = '"+xFilial('SB2')+"' AND SB2.B2_LOCAL = " + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	end
	
	cQuery +=       " AND SB2.B2_COD = '" + SB1->B1_COD + "' "
	cQuery +=       " AND SB2.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPSLD"

	SB2->(DBSetOrder(1))
	While !TMPSLD->(Eof())

		cNomFilial := AllTrim(FWFilialName())
		SB2->(DbGoto(TMPSLD->B2RECNO))
		nAuxSaldo := SaldoSB2()

		nPosFil := aScan(aAuxIteN,{|x| x[1] == cNomFilial+"/"+cFilAnt})
		If nPosFil == 0
			aAdd(aAuxIteN ,{cNomFilial+"/"+cFilAnt,nAuxSaldo})
		Else
			aAuxIteN[nPosFil,2] += nAuxSaldo
		EndIf
		
		nPosFil := aScan(aAuxIte,{|x| x[1] == cNomFilial+"/"+cFilAnt})
		If nPosFil == 0
			aAdd(aAuxIte  ,{cNomFilial+"/"+cFilAnt,nAuxSaldo,TMPSLD->B2_QTNP,TMPSLD->B2_QNPT})
		Else
			aAuxIte [nPosFil,2] += nAuxSaldo
			aAuxIte [nPosFil,3] += TMPSLD->B2_QTNP
			aAuxIte [nPosFil,4] += TMPSLD->B2_QNPT
		EndIf

		nSaldoTot  += (nAuxSaldo)
		nSaldoTotT += (TMPSLD->B2_QTNP+TMPSLD->B2_QNPT)

		TMPSLD->(DbSkip())

	EndDo

	TMPSLD->(DbCloseArea())

Next

For i := 1 to Len(aAuxIteN)
	aAdd(aIteNTer,{"+ "+aAuxIteN[i,1]," "," ",TRANS(aAuxIteN[i,2],"@E 999,999,999.99"),"",""})
Next

For i := 1 to Len(aAuxIte)
	aAdd(aIteTer ,{"+ "+aAuxIte[i,1]," "		," ", TRANS(aAuxIte[i,2],"@E 999,999,999.99"),"",""})
	aAdd(aIteTer ,{"+ "+aAuxIte[i,1],STR0059	," ", TRANS(aAuxIte[i,3],"@E 999,999,999.99"),"",""})
	aAdd(aIteTer ,{"+ "+aAuxIte[i,1],STR0060	," ", TRANS(aAuxIte[i,4],"@E 999,999,999.99"),"",""})
Next

aAdd(aIteNTer,{STR0075,"","",TRANS(nSaldoTot,"@E 999,999,999.99"),"",""}) // Sdo Total
aAdd(aIteTer,{STR0076,"","",TRANS(nSaldoTot+nSaldoTotT,"@E 999,999,999.99"),"",""}) // Sdo Total + Terceiros
//
aIte1 := aIteNTer
cFilAnt := cBkpFilAnt
//
If ExistBlock("OC001EST")
	ExecBlock("OC001EST",.f.,.f.)
EndIf
//
if Len(aIte1) == 0
	aAdd(aIte1,{"","","","","",""})
Endif
//
cEstTer := "1="+STR0073 // Sem Estoque de Terceiros
aEstTer :=  {"1="+STR0073,"2="+STR0074} // Sem Estoque de Terceiros / Com Estoque de Terceiros
xOpca := 0
//
DEFINE MSDIALOG xDlg TITLE STR0043 From 14,30 to 43,126 of oMainWnd //"Localizacao do Item"

@ 038,002 MSCOMBOBOX oEstTer VAR cEstTer SIZE 140,08 COLOR CLR_BLACK ITEMS aEstTer OF xDlg         ;
	ON CHANGE (IIf(cEstTer=="1",aIte1 := aIteNTer,aIte1 := aIteTer) , oLbHeadx:SetArray(aIte1) ,   ;
	oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] , aIte1[oLbHeadx:nAt,2], aIte1[oLbHeadx:nAt,3] ,;
		FG_AlinVlrs(aIte1[oLbHeadx:nAt,4]), aIte1[oLbHeadx:nAt,6] }} , oLbHeadx:Refresh() )        ;
	PIXEL COLOR CLR_BLUE
@ 055,002 LISTBOX oLbHeadx FIELDS HEADER           ;
	Alltrim(RetTitle("B2_FILIAL")) + " " + STR0080,; //Filial / (duplo clique na linha para ver mais)
	Alltrim(RetTitle("B2_LOCAL"))+" - "+(STR0045), ; //Armazem - Descricao
	(STR0079),                                     ; //"Disp.Vda"
	(STR0046),                                     ; //"Quantidade"
	(STR0044)                                      ; //"Localizacao"
	COLSIZES 120,70,50,40,60 SIZE 378,158 OF xDlg PIXEL ON DBLCLICK (OC001DISITE(oLbHeadx:nAt))

oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] , aIte1[oLbHeadx:nAt,2], aIte1[oLbHeadx:nAt,3] , FG_AlinVlrs(aIte1[oLbHeadx:nAt,4]) , aIte1[oLbHeadx:nAt,6] }}
//
ACTIVATE MSDIALOG xDlg CENTER ON INIT ( EnchoiceBar(xDlg,{|| xOpca := 1,xDlg:End()},{|| xOpca := 2,xDlg:End()}))
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |OC001DISITE  |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Duplo clique na lista de pecas por almoxarifado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001DISITE(nNumero)
Local lLevSC7    := .f.
Local i          := 0
Local nPosRg     := 0
Local cBkpFilAnt := cFilAnt
//
cFilAnt := right(aIte1[nNumero,1],len(cFilAnt)) // cFilAnt
//
if SubStr(aIte1[nNumero,1],1,1) == " "
	if GetNewPar("MV_LOCALIZ","N") == "S" .and. localiza(SB1->B1_COD)
		OC001DISPLOC(nNumero)
		cFilAnt := cBkpFilAnt
		Return
	Else
		cFilAnt := cBkpFilAnt
		Return
	Endif
Endif
//
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
//
aIte2 := {}
For i:= 1 to nNumero
	aAdd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4],aIte1[i,5],aIte1[i,6]})
Next
//
if SubStr(aIte1[nNumero,1],1,1) == "+"
	aIte2[Len(aIte2),1] := "- "+SubStr(aIte1[nNumero,1],3)
	lLevSC7 := .t.
	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek(xFilial("SB5")+SB1->B1_COD)
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+SB1->B1_COD)
	Do while !EOF() .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == SB1->B1_COD

		nRecNo = SB2->(RecNo())
		nSaldo := SaldoSB2()
		SB2->(DBGoTo(nRecNo))
		SB2->(DBSeek(xFilial("SB2")+SB1->B1_COD+SB2->B2_LOCAL))
		SB5->(DBSetOrder(1))
		SB5->(DBSeek(xFilial("SB5")+SB1->B1_COD))
		NNR->(DBSetOrder(1))
		NNR->(dbSeek(xFilial("NNR")+SB2->B2_LOCAL))
		
		aOpcNNR := X3CBOXAVET("NNR_VDADMS","0")

		cDispVda := Subs(aOpcNNR[1],3,3)
		If lNNRVDADMS
			If NNR->NNR_VDADMS == "1"
				cDispVda := Subs(aOpcNNR[2],3,3)
			EndIf
		Else
			if SB1->B1_LOCPAD == SB2->B2_LOCAL
				cDispVda := Subs(aOpcNNR[2],3,3)
			EndIf
		EndIf

		aAdd(aIte2,{"   + "+FWFilialName()+"/"+cFilAnt,;
					SB2->B2_LOCAL+" - "+NNR->NNR_DESCRI,;
					cDispVda,;
					TRANS(nSaldo,"@E 999,999,999.99"),;
					SB2->B2_LOCAL,;
					FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")})

		dbSelectarea("SB2")
		dbSkip()
	Enddo

Else
	aIte2[Len(aIte2),1] := "+ "+SubStr(aIte1[nNumero,1],3)
Endif
//
dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
//
&& Levanta Itens pedido SC7
If cBkpFilAnt == cFilAnt .and. lLevSC7 // somente da mesma Filial (Logada) e esta visualizando a Filial analiticamente

	nSaldo := 0
	DbSelectArea("SBM")
	DbSetOrder(1)
	DbSeek(xFilial("SBM")+SB1->B1_GRUPO)

	DbSelectArea("VIA")
	DbSetOrder(2)
	DbSeek( xFilial("VIA") + SBM->BM_CODMAR + SB1->B1_CODITE )
	Do While !Eof() .And. VIA->VIA_FILIAL+VIA->VIA_CODMAR+VIA->VIA_CODITE == xFilial("VIA") + SBM->BM_CODMAR + SB1->B1_CODITE

		If Empty(VIA->VIA_GRUITE) .Or. VIA->VIA_GRUITE == SB1->B1_GRUPO

			DbSelectArea("VI0")
			DbSetOrder(1)
			DbSeek( xFilial("VI0") + SBM->BM_CODMAR + VIA->VIA_SERNFI + VIA->VIA_NUMNFI )

			DbSelectArea("SF1")
			DbSetOrder(1)
			If !Empty(VI0->VI0_NUMNFI) .and. !DbSeek(xFilial('SF1')+VI0->VI0_NUMNFI+VI0->VI0_SERNFI) .And. ((nSaldo := VIA->VIA_QTDFAT) > 0)

				DbSelectArea("SA2")
				If !Empty(VI0->VI0_CODFOR)
					DbSetOrder(1)
					DbSeek( xFilial("SA2") + VI0->VI0_CODFOR + VI0->VI0_LOJFOR )
				Else
					If !Empty(VIA->VIA_CGCFOR)
						If !DbSeek( xFilial("SA2") + VIA->VIA_CGCFOR )
							DbSelectArea("SA2")
						EndIf
					Else
						DbSelectArea("SA2")
						DbSetOrder(1)
						DbSeek( xFilial("SA2") + VE4->VE4_CODFOR + VE4->VE4_LOJFOR )
					EndIf
				EndIf

				If Len(aIte2)	== 0 .Or. (( nPosRg := Ascan(aIte2,{|x| x[1]+x[2]+x[4] == "   + "+FWFilialName()+"/"+cFilAnt+STR0066+" - "+Substr(SA2->A2_NOME,1,20)+"/"+SA2->A2_MUN+"ET" }) ) == 0 ) // Transito
					aAdd(aIte2,{"   + "+FWFilialName()+"/"+cFilAnt,STR0066+" - "+Substr(SA2->A2_NOME,1,20)+"/"+SA2->A2_MUN,"",TRANS(0,"@E 999,999,999.99"),"ET",""}) // Transito
					nPosRg := Len(aIte2)
				EndIf

				aIte2[nPosRg,4] := TRANS( (Val(aIte2[nPosRg,4]) + nSaldo) ,"@E 999,999,999.99")

			EndIf

		EndIf

		DbSelectArea("VIA")
		DbSkip()

	EndDo

	nSaldo := 0
	DbSelectArea("SC7")
	DbSetOrder(4)
	DbSeek( xFilial("SC7") + SB1->B1_COD )
	Do While !Eof() .And. SC7->C7_FILIAL+SC7->C7_PRODUTO == xFilial("SC7") + SB1->B1_COD

		If Empty(SC7->C7_RESIDUO) .And. ((nSaldo := SC7->C7_QUANT - SC7->C7_QUJE) > 0)

			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + SC7->C7_FORNECE )

			If Len(aIte2)	== 0 .Or. (( nPosRg := Ascan(aIte2,{|x| x[1]+x[2]+x[5] == "   + "+FWFilialName()+"/"+cFilAnt+STR0061+"   - "+Substr(SA2->A2_NOME,1,20)+"/"+SA2->A2_MUN+"PD" }) ) == 0 )
				aAdd(aIte2,{"   + "+FWFilialName()+"/"+cFilAnt,STR0061+"   - "+Substr(SA2->A2_NOME,1,20)+"/"+SA2->A2_MUN,"",TRANS(0,"@E 999,999,999.99"),"PD",""})
				nPosRg := Len(aIte2)
			EndIf

			aIte2[nPosRg,4] := TRANS( (Val(aIte2[nPosRg,4]) + nSaldo) ,"@E 999,999,999.99")

		EndIf

		DbSelectArea("SC7")
		DbSkip()

	EndDo

	&& Pega saldo em transito e subtrai do pedido
	For nPosRg:=1 To Len(aIte2)

		If aIte2[nPosRg,5] == "PD"

			If Len(aIte2)	# 0 .And. (( nPosTrans := Ascan(aIte2,{|x| Substr(x[2],12)+x[5] == Substr(aIte2[nPosRg,2],12)+"ET" }) ) # 0 )

				aIte2[nPosRg,4] := TRANS( (Val(aIte2[nPosRg,4]) - Val(aIte2[nPosTrans,4])) ,"@E 999,999,999.99")
				If Val(aIte2[nPosRg,4]) < 0
					aIte2[nPosRg,4] := TRANS( 0 ,"@E 999,999,999.99")
				EndIf

			EndIf

		EndIf

	Next

EndIf
//
cFilAnt := cBkpFilAnt
//
For i:= nNumero+1 to Len(aIte1)
	if SubStr(aIte1[i,1],1,1) # " "
		aadd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4],aIte1[i,5],aIte1[i,6]})
	Endif
Next
//
if len(aIte2) == 0
	aadd(aIte2,{"","","","","",""})
Endif
//
aIte1 := aclone(aIte2)
//
If ExistBlock("OC001EST")
	ExecBlock("OC001EST",.f.,.f.)
EndIf
//
oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] , aIte1[oLbHeadx:nAt,2], aIte1[oLbHeadx:nAt,3] , FG_AlinVlrs(aIte1[oLbHeadx:nAt,4]) , aIte1[oLbHeadx:nAt,6] }}
oLbHeadx:Refresh()
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |OC001DISPLOC |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra localizacao na lista de pecas por almoxarifado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001DISPLOC(nNumero)
Local i:=0
//
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
//
if SubStr(aIte1[nNumero,1],4,1) == " "
	Return
Endif
//
aIte2 := {}
For i:= 1 to nNumero
	aAdd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4],aIte1[i,5],aIte1[i,6]})
Next
//
if SubStr(aIte1[nNumero,1],4,1) == "+"
	aIte2[nNumero,1] := "   -"+SubStr(aIte1[nNumero,1],5)
	dbSelectArea("SBF")
	dbSetOrder(2)
	dbSeek(xFilial("SBF")+SB1->B1_COD+aIte1[nNumero,4])
	Do while !EOF() .and. SBF->BF_FILIAL == xFilial("SBF") .and. SBF->BF_PRODUTO == SB1->B1_COD .and. SBF->BF_LOCAL == aIte1[nNumero,4]
		SBE->(dbSeek(xFilial("SBE")+SBF->BF_LOCAL+SBF->BF_LOCALIZ))
		aAdd(aIte2,{"       "+SBF->BF_LOCALIZ,SBE->BE_DESCRIC,"",TRANS(SBF->BF_QUANT,"@E 999,999,999.99"),SBE->BE_LOCAL,""})
		dbSelectArea("SBF")
		dbSkip()
	Enddo
Else
	if SubStr(aIte1[nNumero,1],4,1) == "-"
		aIte2[nNumero,1] := "   +"+SubStr(aIte1[nNumero,1],5)
		For i:= nNumero+1 to Len(aIte1)
			if !SubStr(aIte1[i,1],4,1) $ "+/-" .and. !SubStr(aIte1[i,1],1,1) $ "+/-"
				nNumero++
			Else
				Exit
			Endif
		Next
	Endif
Endif
//
For i:= nNumero+1 to Len(aIte1)
	aadd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4],aIte1[i,5],aIte1[i,6]})
Next
//
if Len(aIte2) == 0
	aadd(aIte2,{"","","","","",""})
Endif
//
aIte1 := aClone(aIte2)
//
oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] , aIte1[oLbHeadx:nAt,2] , aIte1[oLbHeadx:nAt,3] , FG_AlinVlrs(aIte1[oLbHeadx:nAt,4]) , aIte1[oLbHeadx:nAt,6] }}
oLbHeadx:Refresh()
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |OC001SOBEREL |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Sobe item relacionado ao cabecalho da consulta              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001SOBEREL(nItem)
DBSelectArea("SB1")
DBSetOrder(7)
DBSeek(xFilial("SB1")+aIteRelP[nItem,1]+aIteRelP[nItem,2])
OC001PREPEC(SB1->B1_COD)
o_Chave:SetFocus()
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |OC001POSPEC  |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Posiciona no SB1 antes de retornar da consulta              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001POSPEC()
dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+cGrupo+cCodIte)
	return .t.
endif
return .f.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | OC001RSIT   |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a situacao do produto (B1_SITPROD)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001RSIT()
Local cSituac  := ""
if !Empty(SB1->B1_COD)
	dbSelectArea("SX5")
	DbSetOrder(1)
	if DbSeek(xFilial("SX5")+"T2"+SB1->B1_SITPROD)
		cSituac := SX5->X5_DESCRI
	Endif
Endif
return cSituac
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |OC001RCLAS   |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Classificacao ABC do item segundo a demanda (SBL) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001RCLAS()
//
Local cAbc := STR0050
dbSelectArea("SBL")
dbSetOrder(1)
dbSeek(xFilial("SBL")+SB1->B1_COD)
//
While !eof() .and. SBL->BL_PRODUTO == SB1->B1_COD
	cABC := SBL->BL_ABCVEND+SBL->BL_ABCCUST
	dbSkip()
Enddo
if Empty(SB1->B1_COD)
	cABC := ""
Endif
//
return cABC
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | OC001REST   |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a quantidade em estoque da peca                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001REST()
Local nSaldo   := 0

If lNNRVDADMS
	cQuery := " SELECT SB2.R_E_C_N_O_ AS B2RECNO"
	cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
	cQuery += " JOIN " + RetSqlName('NNR') + " NNR ON "
	cQuery +=                                " NNR.NNR_FILIAL = '"+xFilial('NNR')+"' "
	cQuery +=                            " AND NNR.NNR_CODIGO = SB2.B2_LOCAL "
	cQuery +=                            " AND NNR.NNR_VDADMS = '1' "
	cQuery +=                            " AND NNR.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SB2.B2_FILIAL = '"+xFilial('SB2')+"' 
	cQuery +=   " AND SB2.B2_COD = '" + SB1->B1_COD + "' "
	cQuery +=   " AND SB2.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPNNR"
	While !TMPNNR->(Eof())
		
		SB2->(DbGoto(TMPNNR->B2RECNO))
		nSaldo += SaldoSB2()

		TMPNNR->(DbSkip())
	EndDo
	
	TMPNNR->(DbCloseArea())
Else

	nSaldo := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))

EndIf

return nSaldo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | OC001RPRE   |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o preco publico da peca                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001RPRE()
Local cForPad 	:= GetNewPar("MV_FMLPECA",'"      "')
Local nPreco  	:= 0

dbSelectArea("VEG")
VEG->(dbSetOrder(2))
//
dbSelectArea("SBM")
SBM->(dbSetOrder(1))

If SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO)) .AND. !Empty(SBM->BM_FORMUL)
	wVar := SBM->BM_FORMUL
	nPreco := FG_FORMULA(SBM->BM_FORMUL)
ElseIf VEG->(dbSeek(xFilial("VEG")+"04"+&cForPad))
	wVar := VEG->VEG_FORMUL
	nPreco := FG_FORMULA(&cForPad)
Else
	nPreco := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")
EndIf

If ValType(nPreco) <> "N"
	nPreco := 0
EndIf

return nPreco
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FS_FILPREC  |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o preco publico da peca                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILPREC(cFilDif,nLista)
Local cBkpFilAnt := cFilAnt
Local i          := 0
Default nLista   := 0
//
cFilAnt := cFilDif
//
xItem := {}
//
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
dbSelectArea("SB5")
dbSetOrder(1)
dbSeek(xFilial("SB5")+SB1->B1_COD)
dbSelectArea("VEG")
dbSetOrder(2)
//
dbSeek(xFilial("VEG")+"04")
//
lRet := .t.
Do while !EOF() .and. VEG->VEG_FILIAL == xFilial("VEG") .and. VEG->VEG_GRUFOR == "04"
	if Empty(VEG->VEG_GRUPOS)
		lRet := .t.
	Else
		lRet := .f.
		For i:=1 to 25
			if Empty(Substr(VEG->VEG_GRUPOS,(i*4)-3,4))
				Exit
			Else
				if cGrupo == Substr(VEG->VEG_GRUPOS,(i*4)-3,4)
					lRet := .t.
					Exit
				Endif
			Endif
		Next
	Endif
	//
	nRecNoVEG := VEG->(recno())

	//PE para validar se adiciona a formula na listagem
	If ExistBlock("OC001FOR")
		lRet := ExecBlock("OC001FOR",.f.,.f.,{VEG->VEG_CODIGO, VEG->VEG_GRUFOR, VEG->VEG_GRUPOS, VEG->VEG_FORMUL})
	EndIf	

	if lRet
		wVar := VEG->VEG_FORMUL
		aadd(xItem,{VEG->VEG_DESCRI,FG_AlinVlrs(Transform(FG_FORMULA(VEG->VEG_CODIGO),"@E 999,999,999.99"))})
	Endif
	//
	dbSelectArea("VEG")
	dbSetOrder(2)
	DbGoto(nRecNoVEG)
	dbSkip()
Enddo
//
if len(xItem) == 0
	aadd(xItem,{"",""})
Endif
//
xOpca := 0
//
cFilAnt := cBkpFilAnt
//
if nLista == 1
	oLbHeadx:SetArray(xItem)
	oLbHeadx:bLine := { || { xItem[oLbHeadx:nAt,1] , xItem[oLbHeadx:nAt,2] }}
	oLbHeadx:Refresh()
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FS_VERALT   |Autor  ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra Alternativos (Peças)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERALT()

Local cAreaAnt		:= GetArea()
Local cQuery3 		:= ""
Local cQVB12		:= "SQLVB12"
Local aConVB12		:= {}
Local aConVB1SB12	:= {}
Local nPos			:= 0
Local nOpcao := 1

cQuery3 := "SELECT VB1.VB1_KEYALT, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_COD , SB1.B1_DESC FROM " + RetSqlName("SB1")+" SB1"
cQuery3 += " JOIN "  + RetSqlName("VB1")+" VB1 ON VB1.VB1_COD = SB1.B1_COD"
cQuery3 += " WHERE VB1.VB1_KEYALT LIKE '" + AllTrim(CcHAVE) + "%' AND VB1.D_E_L_E_T_= ' '"
cQuery3 += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND VB1.VB1_FILIAL = '" + xFilial("VB1")+"'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery3 ), cQVB12, .F., .T. )
While !(cQVB12)->(Eof())
	AAdd(aConVB12,{(cQVB12)->(VB1_KEYALT), (cQVB12)->(B1_GRUPO), (cQVB12)->(B1_CODITE), (cQVB12)->(B1_DESC),(cQVB12)->(B1_COD)})
	(cQVB12)->(DbSkip())
EndDo
(cQVB12)->(DbCloseArea())
DBSelectArea("SB1")
If Len(aConVB12) >= 1 //.and. nOpcao<>2
	RestArea(cAreaAnt)

	DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,080 TITLE (STR0062) OF oMainWnd  // Cadastros Alternativos Encontrados
	@ 001,001 LISTBOX olBox2 FIELDS HEADER (STR0063),; // Codigo Alternativo
	(STR0019),; // Grupo
	(STR0064),; // Cod. Item
	(STR0021);  // Descricao
	COLSIZES 50,20,60,65 SIZE 315,111 OF oDesVB1 PIXEL ON DBLCLICK (nPos := olBox2:nAt, oDesVB1:END())
	olBox2:SetArray(aConVB12)
	olBox2:bLine := { || {  aConVB12[olBox2:nAt,1] , aConVB12[olBox2:nAt,2] , 	aConVB12[olBox2:nAt,3] , aConVB12[olBox2:nAt,4] }}
	ACTIVATE MSDIALOG oDesVB1 CENTER
	If nPos != 0
		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1")+aConVB12[nPos,2]+aConVB12[nPos,3])
		cChave := SB1->B1_COD
	EndIf

EndIf

Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |FS_CATEGORIA| Autor |  Luis				  | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Categoria.				                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_CATEGORIA()

//Local aHelpP:={"Indica se deve mostrar na estrutura os ","produtos relacionados a cada uma das" ,"categorias."}
//Local aHelpS:={"Indica si debe mostrar en la estructura","los productos relacionados a cada una","de las categorías."}
//Local aHelpE:={"Determine if products in the structure" ,"related to each one of the categories","must be displayed."}
LOCAL aButtons:= {}
Local aRetCopy  := If(Type("aRotina")=="A",ACLONE(aRotina),{})
Local  dDataIni   := dDataBase
Local  dDataFim   := dDataBase
Local aArea     := GetArea()
Local aSize     := MsAdvSize(.T.)
Local aInfo     := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Local aObjects  := {{100,100,.T.,.T.}}
Local aObjects2 := {{45,100,.T.,.T.},{55,100,.T.,.T.,.T.}}
Local aPosObj   := {}
PRIVATE cCodVazio   :=CriaVar("ACU_COD",.F.)
PRIVATE cProdVazio  :=CriaVar("ACV_CODPRO",.F.)
PRIVATE cGrupoVazio :=Criavar("ACV_GRUPO",.F.)
PRIVATE cRecnoVazio :=StrZero(0,10)
PRIVATE lExisteGrupo:=ACV->(ColumnPos("ACV_GRUPO")) > 0
Private aDadosProd := {}
cCadastro := "Categoria"
lPrevVenda := .f.
If !lPrevVenda
	// Inclui botoes para manipulacao
//	AADD(aButtons,{'bmpincluir',{|| FT140Tree(1,oTree)},OemToAnsi("Incluir")})
//	AADD(aButtons,{'NOTE',{|| FT140Tree(2,oTree)},OemToAnsi("Alterar")})
//	AADD(aButtons,{'EXCLUIR',{|| FT140Tree(3,oTree)},OemToAnsi("Excluir")})
	//Inclusao da pergunte e help de forma dinamica
//	PutSx1("FAT140","01","Mostra produtos na estrutura ?","¿Muestra productos en estructura ?","Show products in structure ?","mv_ch1","N",1,0,2,"C","","","","",;
//		"mv_par01","Sim","Sim","Yes","","Nao","No","No","","","","","","","","","")
//	PutSX1Help("P.FAT14001.",aHelpP,aHelpE,aHelpS)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra a pergunta sobre os produtos                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	Pergunte("FAT140",.T.)
Else
	// Inclui botoes
	// Inclusao de previsoes
//	AADD(aButtons,{'NOTE',{|| Ft140IncPV(oTree,dDataIni,dDatafim,aDadosProd)},OemToAnsi(""),OemToAnsi("")})
	// Refresh no tree
	AADD(aButtons,{'reload',{|| Fat140Trfs(oDlg,oTree,aTotais,aDadosProd,dDataIni,dDataFim) },"Refresh","Refresh"})
EndIf

aPosObj   := MsObjSize( aInfo,If(lPrevVenda,aObjects2,aObjects),.T.,If(lPrevVenda,.T.,NIL))

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,80 to 710,710 of oMainWnd PIXEL
	// Cria o Tree e preenche as informacoes
	oTree := DbTree():New(17,05,350,310,oDlg,,,.T.)
	FT140MTree(oTree,cCodVazio,NIL,NIL,NIL,.t.,lPrevVenda,,dDataIni,dDataFim,aDadosProd)
	// Caso a chamada ocorra da previsao de vendas altera caracteristica da tela apresentando informacoes sobre produtos e previsoes
	If lPrevVenda
		oPanel := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg,oDlg:oFont,.T.,.T.,,,aPosObj[2,3],aPosObj[2,4],.T.,.T. )
		oTree:bChange := {|| (If(Val(Substr(oTree:GetCargo(),nPosIni,10))>0,If(Substr(oTree:GetCargo(),1,1) == "2",(SB1->(MsGoto(Val(Substr(oTree:GetCargo(),nPosIni,10)))),RegtoMemory("SB1",.F.)),(SC4->(MsGoto(Val(Substr(oTree:GetCargo(),nPosIni,10)))),RegtoMemory("SC4",.F.))),),FT140RTree(@oTree,@oPanel,{0,0,aPosObj[2,4],aPosObj[2,3]},)) }
	EndIf
ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||FS_POSICIONA()},{||oDlg:End()},,aButtons)
Release Object oTree
RestArea(aArea)
// Restaura area original
aRotina:=AClone(aRetCopy)
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |FT140MTree  | Autor |  Luis				  | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Procura por uma categoria nao bloqueada         			    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FT140MTree(oTree,cCodPai,lSeek1,cTexto,cCodCargo,lExplProd,lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)

Local nRec		:= 0
Local aArea		:= GetArea()
Local aDadosRet	:= {}
Local nx		:= 0
Local lCpBloq	:= (ACU->(ColumnPos("ACU_MSBLQL")) > 0)
//Local lSeek1    := .F.



dbSelectArea("ACV")
dbSetOrder(1)

dbSelectArea("ACU")
dbSetOrder(2)

//1 FILIAL+COD
//2 FILIAL+CODPAI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura por uma categoria nao bloqueada (campo MSBLQL)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSeek1

	lSeek1:=MsSeek(xFilial("ACU")+cCodPai) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))

	If !lSeek1 .AND. Found()
		While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == xFilial("ACU") .AND. ACU->ACU_CODPAI == cCodPai
			ACU->(DbSkip())
			lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
		End
	EndIf

EndIf

If lSeek1
	If !Empty(cCodPai) .And. !Empty(cTexto) .And. !Empty(cCodCargo)
		oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
	Else
		oTree:AddTree("Estrutura"+Space(Len(ACU->ACU_DESC)+130),.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodVazio+cProdVazio+cGrupoVazio+cRecnoVazio)
	EndIf
	// Enquanto esta regiao for a regiao pai
	While !Eof() .And. ACU_FILIAL+ACU_CODPAI == xFilial("ACU")+cCodPai
		//Salta categorias bloqueadas
		If (lCpBloq  .AND. ACU->ACU_MSBLQL == '1')
			DbSkip()
			Loop
		End
		cCodCargo:=ACU_COD
		nRec:=Recno()
		cTexto:=ACU->ACU_DESC

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por uma categoria nao bloqueada (campo MSBLQL)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSeek1:=MSSeek(xFilial("ACU")+cCodCargo) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))

		If !lSeek1 .AND. Found()
			While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == xFilial("ACU") .AND. ACU->ACU_CODPAI == cCodCargo
				ACU->(DbSkip())
				lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
			End
		EndIf

		If !lSeek1
			// Inclui todos os produtos relacionados
			If lExplProd .And. ACV->(MsSeek(xFilial("ACV")+cCodCargo))
				oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
				aDadosRet:=Fata140Prd(oTree,cCodCargo,lPrevVenda,aTotais,dDataIni,dDataFim)
				For nx:=1 to Len(aDadosRet)
					AADD(aDadosProd,ACLONE(aDadosRet[nx]))
				Next nx
				oTree:EndTree()
			Else
				oTree:AddTreeItem(cTexto,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
				oTree:blDblClick := { ||FS_POSICIONA(SUBSTR(OTREE:GETCARGO(),8,15))}
			EndIf
		Else
			FT140MTree(oTree,ACU_CODPAI,lSeek1,cTexto,cCodCargo,lExplProd,lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
		EndIf
		dbGoto(nRec)
		dbSkip()
	End
	// Inclui todos os produtos relacionados
	If lExplProd
		aDadosRet:=Fata140Prd(oTree,cCodPai,lPrevVenda,aTotais,dDataIni,dDataFim)
		For nx:=1 to Len(aDadosRet)
			AADD(aDadosProd,ACLONE(aDadosRet[nx]))
		Next nx
	EndIf
	oTree:EndTree()
EndIf
// Sorteia array com resultados por grupo
aSort(aDadosProd,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
RestArea(aArea)
RETURN



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |FT140MTree  | Autor |  Luis				  | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | informacoes dos produtos associados.            			    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function Fata140Prd(oTree,cCod,lPrevVenda,aTotais,dDataIni,dDataFim)
Local aArea       := GetArea()
Local cGrupo      := If(lExisteGrupo,RetTitle("ACV_GRUPO"),"")
Local cProduto    := RetTitle("ACV_CODPRO")
Local cTextoTotal := ""
Local cRecno      := cRecnoVazio
Local aRetorno    := {}
Local i
Local j
Local aColsGrd    := {}

Local lInfo := .F.

dbSelectArea("ACV")
dbSetOrder(1)
If MsSeek(xFilial("ACV")+cCod)
	While !Eof() .And. xFilial("ACV")+cCod == ACV->ACV_FILIAL+ACV->ACV_CATEGO
		aColsGrd:={}
		cRecno:=cRecnoVazio
		If lExisteGrupo .And. !Empty(ACV->ACV_GRUPO)
			cTextoTotal:=cGrupo+ACV->ACV_GRUPO
		ElseIf !Empty(ACV->ACV_CODPRO)
			cTextoTotal:=cProduto+ACV->ACV_CODPRO
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+ACV->ACV_CODPRO))
				cRecno:=StrZero(SB1->(Recno()),10)
				cTextoTotal:=(Alltrim(cProduto))+" - "+(Alltrim(ACV->ACV_CODPRO))+" - "+SB1->B1_DESC
			EndIf
		ElseIf !Empty(ACV->ACV_REFGRD)
			aColsGrd:=Ft140Grade(ACV->ACV_REFGRD)
		EndIf
	    if !Empty(cDesc)
	       if !(Alltrim(cDesc) $ SB1->B1_DESC)
	          dbSelectArea("ACV")
	          dbSkip()
	          Loop
	       Endif
	    Endif
		If len(aColsGrd)>0
			If !lInfo
				For i:=1 to len(aColsGrd)
				cTextoTotal:=cProduto + Acolsgrd[i,1]
					If lPrevVenda .And. Fat140PV(oTree,aColsGrd[I,1],ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACv->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,""),.T.)
						oTree:AddTree(cTextoTotal,.T.,,,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,"")+aColsGrd[I,2])
						// Inclui as previsoes de venda ja cadastradas no periodo selecionado
						Fat140PV(oTree,aColsGrd[I,1],ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACV->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,""),.F.)
						oTree:EndTree()
					Else
						oTree:AddTreeItem(cTextoTotal,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+PADR(AcolsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,"")+aColsGrd[I,2])
						oTree:blDblClick := { ||FS_POSICIONA(SUBSTR(OTREE:GETCARGO(),8,15))}
					EndIf
				Next
			EndIf
			// Array que retorna informacoes dos produtos associados
			For j:=1 to len(aColsGrd)
				AADD(aRetorno,{ACV->ACV_CATEGO,acolsGrd[J,1],ACV->ACV_GRUPO})
			Next
		Else
			If !lInfo
				If lPrevVenda .And. Fat140PV(oTree,ACV->ACV_CODPRO,ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACv->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,""),.T.)
					oTree:AddTree(cTextoTotal,.T.,,,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,"")+cRecno)
					// Inclui as previsoes de venda ja cadastradas no periodo selecionado
					Fat140PV(oTree,ACV->ACV_CODPRO,ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,""),.F.)
					oTree:EndTree()
				Else
					oTree:AddTreeItem(cTextoTotal,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,"")+cRecno)
					oTree:blDblClick := { ||FS_POSICIONA(SUBSTR(OTREE:GETCARGO(),8,15))}
				EndIf

			EndIf
			// Array que retorna informacoes dos produtos associados
			AADD(aRetorno,{ACV->ACV_CATEGO,ACV->ACV_CODPRO,ACV->ACV_GRUPO})

		EndIf
		dbSkip()
	End
EndIf
RestArea(aArea)
RETURN aRetorno

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |FS_POSICIONA| Autor |  Thiago				  | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Posiciona no item.		                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_POSICIONA()

	OC001PREPEC(SUBSTR(OTREE:GETCARGO(),8,15))
   oDlg:End()

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC001UM    | Autor |  Thiago				  | Data | 12/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna Unidade de Medida.                                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC001UM(cUnid)

dbSelectArea("SAH")
dbSetOrder(1)
dbSeek(xFilial("SAH")+cUnid)

Return(SAH->AH_UMRES)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OC001CONANºAutor  ³Renato Vinicius     º Data ³  28/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada da consulta analitica de pecas(OFIOC520)           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC001CONANA()

Local cAlias := GetArea()
If !Empty(cGrupo) .and. !Empty(cCodIte)
	cQuery := "SELECT SB1.R_E_C_N_O_ FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQuery += "SB1.B1_GRUPO = '"+cGrupo+"' AND SB1.B1_CODITE = '"+cCodIte+"' AND SB1.D_E_L_E_T_ = ' '"
	nRecSB1:= FM_SQL(cQuery)
	OC520Visual("SB1",nRecSB1,2)
else
	OFIOC520(.t.)
//	OC520Visual("SB1",0,2)
endif
RestArea(cAlias)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat140PV  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³06.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui informacoes da previsao de venda no tree              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpC1: Codigo da categoria                                   ³±±
±±³          ³ ExpA1: Array com os totais da categoria                      ³±±
±±³          ³ ExpD1: Data inicial para filtragem da previsao de vendas     ³±±
±±³          ³ ExpD2: Data final para filtragem da previsao de vendas       ³±±
±±³          ³ ExpC2: Texto para cargo do tree                              ³±±
±±³          ³ ExpL1: Somente checa a existencia de registros               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fat140PV(oTree,cCodPro,cCodGrupo,aTotais,dDataIni,dDataFim,cCargo,lCheca)
Local aArea     :=GetArea()

Local lPossuiReg:=.F.
Local cRecno    := cRecnoVazio
Local nAcho     := 0
Local cAliasTop := ""
Local cQuery    := ""

Default cCodPro  :=""
Default cCodGrupo:=""
Default aTotais  :={}
Default dDataIni := dDatabase
Default dDataFim := dDatabase
Default cCargo   :=""
Default lCheca   :=.F.

cAliasTop := GetNextAlias()
cQuery := "SELECT SC4.*,SC4.R_E_C_N_O_ REGC4 FROM "+RetSqlName("SC4")+" SC4, "+RetSqlName("SB1")+" SB1 "
cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SC4.C4_FILIAL='"+xFilial("SC4")+"' AND "
If !Empty(cCodPro)
	cQuery+= "SB1.B1_COD   ='"+cCodPro+"' AND "					
ElseIf !Empty(cCodGrupo)
	cQuery+= "SB1.B1_GRUPO ='"+cCodGrupo+"' AND "	
EndIf
cQuery += "	SC4.C4_PRODUTO = SB1.B1_COD AND "					
cQuery += "SC4.C4_DATA >= '" + DTOS(dDataIni) + "' AND SC4.C4_DATA <= '" + DTOS(dDataFim) + "' AND "
cQuery += "SB1.D_E_L_E_T_=' ' AND SC4.D_E_L_E_T_=' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC4->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)
While !Eof() 
	// So esta checando se possui registros
	If lCheca
		lPossuiReg:=.T.
		Exit		
	EndIf
	nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
	If nAcho > 0
		aTotais[nAcho,4]+=1
		aTotais[nAcho,5]+=C4_QUANT
		aTotais[nAcho,6]+=C4_VALOR
	Else
		AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
	EndIf
	cRecno:= StrZero((cAliasTop)->REGC4,10)
	oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)	
	dbSkip()
End
dbCloseArea()      
RestArea(aArea)
RETURN lPossuiReg



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140RTree³ Autor ³Rodrigo de A Sartorio  ³ Data ³05.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua refresh no painel de acordo com posicao no tree       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpO2: Objeto painel                                         ³±±
±±³          ³ ExpA1: Array com posicao                                     ³±±
±±³          ³ ExpA2: Array com totais                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FT140RTree(oTree,oPanel,aPos,aTotais)
Local cCargo     := oTree:GetCargo()
Local aDados     := {}
Local aArea      := GetArea()
Local cGrupo     := Substr(cCargo,2,Len(ACU->ACU_COD))
Local nRec       := Val(Substr(cCargo,Len(ACU->ACU_COD)+Len(ACV->ACV_CODPRO)+Len(cGrupoVazio)+2,10))
Local nAcho      := 0
Local lOneColumn := If(aPos[4]-aPos[2]>312,.F.,.T.)
Local oScroll

If Substr(cCargo,1,1) == "1"
	nAcho:=Ascan(aTotais,{|x| x[2]== cGrupo})
	If nAcho > 0
		AADD(aDados,{aTotais[nAcho,3],""})
		AADD(aDados,{STR0007,Transform(aTotais[nAcho,4],PesqPict("SC4","C4_QUANT",14))})
		AADD(aDados,{STR0008,Transform(aTotais[nAcho,5],PesqPict("SC4","C4_QUANT",14))})
		AADD(aDados,{STR0009,Transform(aTotais[nAcho,6],PesqPict("SC4","C4_VALOR",14))})
	Else
		AADD(aDados,{STR0010})
	EndIf
	C040MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
	oScroll:Show()
ElseIf Substr(cCargo,1,1) == "2"
	If nRec == 0
		AADD(aDados,{STR0010})
		C040MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		oScroll:Show()
	Else
		dbSelectArea("SB1")
		MsGoto(nRec)
		RegtoMemory("SB1",.F.)
		oPanel:Hide()
		MsFreeObj(@oPanel, .T.)
		MsMGet():New("SB1",nRec,1,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
		oPanel:Show()
	EndIf
ElseIf Substr(cCargo,1,1) == "3" .And. (nRec > 0)
	dbSelectArea("SC4")
	MsGoto(nRec)
	RegtoMemory("SC4",.F.)
	oPanel:Hide()
	MsFreeObj(@oPanel, .T.)
	MsMGet():New("SC4",nRec,1,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
	oPanel:Show()
EndIf
RestArea(aArea)
RETURN


/*/{Protheus.doc} OFXC0010018_PontoEntradaEnchoice
	Função criada para chamar pontos de entrada na Enchoice da rotina.
	@type function
	@author Matheus Teixeira Silva
	@since 12/04/2020
/*/
Function OFXC0010018_PontoEntradaEnchoice(cBotao)

Do Case
	Case cBotao == "CONFIRMAR"
		If ExistBlock("OC001TOK")
			ExecBlock("OC001TOK",.f.,.f.,{cChave,cGrupo,cCodIte,cDesc, aIteRelP})
		EndIf
	Case cBotao == "CANCELAR"
		If ExistBlock("OC001CAN")
			ExecBlock("OC001CAN",.f.,.f.,{cChave,cGrupo,cCodIte,cDesc, aIteRelP})
		EndIf
EndCase

Return .T.