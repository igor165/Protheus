// 浜様様様曜様様様様�
// � Versao � 08     �
// 藩様様様擁様様様様�

#Include "protheus.ch"
#Include "FileIO.ch"
#INCLUDE "ofior010.ch"
#INCLUDE "OFIXDEF.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOR010 � Autor �  Emilton              � Data � 01/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Copia da Ordem de Servico                                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       �                                                            咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOR010

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //"Copia da Ordem de Servico"
Private cFinSrv := .f.
Private cKeyAce := ""
Private nFormul := 0
Private lSaiVei := .f.
Private lPerVei := .f.
Private nNroLin := 0
Private lDisponibilizou

Private cIndex, cChave, cCond
Private lLIBVOO := VOO->(FieldPos("VOO_LIBVOO")) > 0

VO1->(dbsetorder(1))
mBrowse( 6, 1,22,75,"VO1")

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOR010N  � Autor � Emilton               � Data � 01/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Pede Impressao de Formulario Normal                          咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Local                                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOR010N()

nFormul := 1
FG_PEDORD(VO1->VO1_NUMOSV,"N","N")   // "  Formulario Normal  "

Return .t.

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOR010E  � Autor � Emilton               � Data � 01/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Pede Imperssao de Formulario Especifico                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Local                                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOR010E(cAlias, nReg, nOpc)

//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
////////////////////////////////////////////////////////////////////////////////////////////

Local bCampo   := { |nCPO| Field(nCPO) }
Local oSitOsv
Local nCntFor  := 0
Private aTELA[0][0], aGETS[0], oDlgCopOsv, cTitle
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

cTitle := OemToAnsi(STR0004) //"Copia da Ordem de Servico"

nOpc  := 2     // Visualizar
nOpcE := 2     // Visualizar
nOpcG := 2     // Visualizar
nFormul := 2


DbSelectArea("VO1")
For nCntFor := 1 TO FCount()
	&( "M->"+EVAL(bCampo,nCntFor) ) := FieldGet(nCntFor)
Next

dbSelectArea("SX3")
dbSeek("VO1")
aCpoEnchoice := {}

While x3_arquivo == "VO1" .and. !eof()

	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !(X3_CAMPO $ "VO1_FILIAL/VO1_GETKEY/VO1_CODMOT/VO1_NOMMOT/VO1_DATENT/VO1_HORENT/VO1_STATUS/VO1_TEMGAR/VO1_TEMLIB/VO1_MECREQ/VO1_EXPGAR/VO1_SITGAR/VO1_CODMAR/VO1_MOTIVO/VO1_DESMOT")

		aAdd(aCpoEnchoice,x3_campo)

		If x3_context == "V"
			&("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
		EndIf

	Endif

	dbSkip()

EndDo

aSitOsv := {}
aValOsv := {}

If !FS_LEVOSV010()
	return .t.
EndIf

cLinOk     := "AllwaysTrue()"
cTudOOk    := "AllwaysTrue()"
cFieldOk   := "AllwaysTrue()"
nLinhas    := 99

dbSelectArea("VO1")
dbSetOrder(1)

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 130, .T. , .F. } )  //Cabecalho
AAdd( aObjects, { 01, 010, .T. , .T. } )  //list box superior
//

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgCopOsv TITLE cTitle  From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

EnChoice("VO1", nReg, nOpc, , , ,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]})


oSitOsv := TWBrowse():New(aPosObj[2,1],aPosObj[2,2],(aPosObj[2,4]-2),(aPosObj[2,3]-aPosObj[1,3]-2),,,,oDlgCopOsv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oSitOsv:nAt := 1
oSitOsv:SetArray(aSitOsv)

oSitOsv:addColumn( TCColumn():New( ""      , { || IIf(aSitOsv[oSitOsv:nAt,1],oOk,oNo) 					},,,,"LEFT"  ,05,.T.,.F.,,,,.F.,) )
oSitOsv:addColumn( TCColumn():New( STR0005 , { || aSitOsv[oSitOsv:nAt,2] 								},,,,"LEFT"  ,10,.F.,.F.,,,,.F.,) ) // "Tipo de Tempo"
If lLIBVOO
	oSitOsv:addColumn( TCColumn():New( RetTitle("VOO_LIBVOO"), { || aSitOsv[oSitOsv:nAt,10]				},,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )	// Numero da Libera艫o
EndIf
oSitOsv:addColumn( TCColumn():New( STR0006 , { || aSitOsv[oSitOsv:nAt,3] +"-" + aSitOsv[oSitOsv:nAt,9]	},,,,"LEFT"  ,25,.F.,.F.,,,,.F.,) ) // "Cliente"
oSitOsv:addColumn( TCColumn():New( STR0007 , { || aSitOsv[oSitOsv:nAt,4]								},,,,"LEFT"  ,95,.F.,.F.,,,,.F.,) ) // "Nome do Cliente"
oSitOsv:addColumn( TCColumn():New( STR0008 , { || Transform(aSitOsv[oSitOsv:nAt,5],"@E 99,999.99")		},,,,"RIGHT" ,45,.F.,.F.,,,,.F.,) ) // "Total de Pecas"
oSitOsv:addColumn( TCColumn():New( STR0009 , { || Transform(aSitOsv[oSitOsv:nAt,6],"@R 999:99")			},,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) ) // "Horas Padrao"
oSitOsv:addColumn( TCColumn():New( STR0010 , { || Transform(aSitOsv[oSitOsv:nAt,7],"@R 999:99")			},,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) ) // "Horas Trab."
oSitOsv:addColumn( TCColumn():New( STR0011 , { || Transform(aSitOsv[oSitOsv:nAt,8],"@E 99,999.99")		},,,,"RIGHT" ,45,.F.,.F.,,,,.F.,) ) // "Total de Servicos"
oSitOsv:bLDblClick := { || IIf(aSitosv[oSitOsv:nAt,1],aSitOsv[oSitOsv:nAt,1] := .f.,FS_VAL010(oSitOsv:nAt)) }
oSitOsv:Refresh()

ACTIVATE MSDIALOG oDlgCopOsv ON INIT (EnchoiceBar(oDlgCopOsv,{|| nOpca := 1,If(FS_PEDORD(),oDlgCopOsv:End(),.t.)},{|| nOpca := 0,oDlgCopOsv:End()}))

dbSelectArea("VO1")
dbSetOrder(1)

Return .T.

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �FS_VAL010   � Autor � Rubens                � Data � 23/02/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao na selecao do Tipo de Tempo                        咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Local                                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_VAL010(nNroLin)

SA1->(DbSetOrder(1))
SA1->(MsSeek( xFilial("SA1") + aSitOsv[nNroLin,3] + aSitOsv[nNroLin,9] ))
If SA1->A1_MSBLQL == "1"
	MsgStop(STR0021+CHR(13)+CHR(10)+CHR(13)+CHR(10)+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME,STR0022) // Cliente bloqueado! / Atencao
	Return(.f.)
EndIf

aSitOsv[nNroLin,1] := .t.

Return


/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_LEVOSV010� Autor � Emilton               � Data � 01/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Cria Vetor para listbox na tela                              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Local                                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION FS_LEVOSV010()

Local aPeca
Local aSrvc

Local nRegCop := 0
Local aCodSer := {}

Local nCont

/* Analisa Pecas ... */
aPeca := FMX_CALPEC( VO1->VO1_NUMOSV ,;
					 /* cTipTem */,;
					 /* cGruIte */,;
					 /* cCodIte */,;
					 .f. /* lMov */,;
					 .t. /* lNegoc */,;
					 .f. /* lReqZerada */,;
					 .t. /* lRetAbe */,;
					 .t. /* lRetLib */,;
					 .t. /* lRetFec */,;
					 .f. /* lRetCan */,;
					  /* cLibVOO */,;
					  /* cFiltroSQL */ )

For nCont := 1 to Len(aPeca)

	// Base com liberacao parcial de TT
	If lLIBVOO .and. Len(aPeca[nCont]) >= 25
		nRegCop := aScan( aSitOsv,{|x| x[2] == aPeca[nCont,03] .and. x[10] == aPeca[nCont,25] } )
	Else
		nRegCop := aScan( aSitOsv,{|x| x[2] == aPeca[nCont,03] } )
	EndIf
	If nRegCop == 0

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + aPeca[nCont,15] + aPeca[nCont,16] ))

		AADD( aSitOsv , Array(10) )
		nRegCop := Len(aSitOsv)

		aSitOsv[nRegCop,01] := .f.
		aSitOsv[nRegCop,02] := aPeca[nCont,03]	// Tipo de Tempo
		aSitOsv[nRegCop,03] := aPeca[nCont,15]	// Cliente
		aSitOsv[nRegCop,04] := SA1->A1_NREDUZ
		aSitOsv[nRegCop,05] := 0
		aSitOsv[nRegCop,06] := 0
		aSitOsv[nRegCop,07] := 0
		aSitOsv[nRegCop,08] := 0
		aSitOsv[nRegCop,09] := aPeca[nCont,16]	// Loja
		aSitOsv[nRegCop,10] := ""				// Liberacao de Tipo de Tempo

		If lLIBVOO .and. Len(aPeca[nCont]) >= 25
			aSitOsv[nRegCop,10] := aPeca[nCont,25]
		EndIf
	EndIf

	aSitOsv[nRegCop,05] += aPeca[nCont,10] - aPeca[nCont,07]

Next nCont



/* Analisa Servicos */
aSrvc := FMX_CALSER( VO1->VO1_NUMOSV ,;
					 /* cTipTem */,;
					 /* cGruSer */,;
					 /* cCodSer */,;
					 .f. /* lApont */,;
					 .t. /* lNegoc */,;
					 .t. /* lRetAbe */,;
					 .t. /* lRetLib */,;
					 .t. /* lRetFec */,;
					 .f. /* lRetCan */,;
					 /* cLibVOO */,;
					 /* cFiltroSQL */)

For nCont := 1 to Len(aSrvc)

	// Base com liberacao parcial de TT
	If lLIBVOO .and. Len(aSrvc[nCont]) >= 38
		nRegCop := aScan( aSitOsv,{|x| x[2] == aSrvc[nCont,04] .and. x[10] == aSrvc[nCont,38] } )
	Else
		nRegCop := aScan( aSitOsv,{|x| x[2] == aSrvc[nCont,04] } )
	EndIf
	If nRegCop == 0

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + aSrvc[nCont,20] + aSrvc[nCont,21] ))

		AADD( aSitOsv , Array(10) )
		nRegCop := Len(aSitOsv)

		aSitOsv[nRegCop,01] := .f.
		aSitOsv[nRegCop,02] := aSrvc[nCont,04]	// Tipo de Tempo
		aSitOsv[nRegCop,03] := aSrvc[nCont,20]	// Cliente
		aSitOsv[nRegCop,04] := SA1->A1_NREDUZ
		aSitOsv[nRegCop,05] := 0
		aSitOsv[nRegCop,06] := 0
		aSitOsv[nRegCop,07] := 0
		aSitOsv[nRegCop,08] := 0
		aSitOsv[nRegCop,09] := aSrvc[nCont,21]	// Loja
		aSitOsv[nRegCop,10] := ""				// Liberacao de Tipo de Tempo

		If lLIBVOO .and. Len(aSrvc[nCont]) >= 38
			aSitOsv[nRegCop,10] := aSrvc[nCont,38]
		EndIf

	EndIf

	aSitOsv[nRegCop,06] += aSrvc[nCont,10] // tempo padrao
	aSitOsv[nRegCop,07] += aSrvc[nCont,11] // tempo trabalhado
	aSitOsv[nRegCop,08] += aSrvc[nCont,09] // Valor Srv

Next nCont

If Empty(aSitOsv)
	AADD( aSitOsv , Array(10) )
	nRegCop := Len(aSitOsv)
	aSitOsv[nRegCop,01] := .t.
	aSitOsv[nRegCop,02] := ""	// Tipo de Tempo
	aSitOsv[nRegCop,03] := ""	// Cliente
	aSitOsv[nRegCop,04] := ""
	aSitOsv[nRegCop,05] := 0
	aSitOsv[nRegCop,06] := 0
	aSitOsv[nRegCop,07] := 0
	aSitOsv[nRegCop,08] := 0
	aSitOsv[nRegCop,09] := ""	// Loja
	aSitOsv[nRegCop,10] := ""	// Liberacao de Tipo de Tempo
EndIf

Return .t.

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � FS_PEDORD  � Autor � Emilton               � Data � 01/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Cria Vetor para listbox na tela                              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Local                                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
STATIC FUNCTION FS_PEDORD()

local ix1
Local cNroOs := ""

If aScan(aSitOsv, { |x| x[1] } ) == 0 .or. ( Len(aSitOsv) == 1 .and. Empty(aSitOsv[1,2]) )
	Help(" ",1,"R010SEMORD")  && Nao Existe Nenhum Tipo de Tempo Selecionado
	Return .f.
EndIf

cNroOs := VO1->VO1_NUMOSV

for ix1 := 1 to len(aSitOSv)
	If aSitOsv[ix1,1]
		FG_PEDORD(cNroOs,"E",aSitOSv[ix1,2])
	EndIf
Next

Return .t.

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � MenuDef    � Autor � Emilton               � Data � 01/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Menu								                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Local                                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()

Local aRotina := {	{ STR0001 , "AxPesqui" , 0, 1},; //"Pesquisar"
					{ STR0002 , "OFIOR010N", 0, 2},; //"For. Normal"
					{ STR0003 , "OFIOR010E", 0, 2},; //"For. Espec."
					{ STR0023 , "OR0100016_TelaImprimirOSSelecionadas", 0, 2} } // Imprimir O.S. selecionadas
Return aRotina

/*/{Protheus.doc} OR0100016_TelaImprimirOSSelecionadas
Op艫o do menu para chamar a nova tela de impress�o das O.S. seleciondas
@author Fernando Vitor Cavani
@since 30/11/2018
@version 1.0
@return l�gico
@type function
/*/
Function OR0100016_TelaImprimirOSSelecionadas()
Local aTELA := FWGetDialogSize(oMainWnd)
Local oDlgImpOS

Private oBrowseO, oBrowseS
Private aVetOS := {}

DEFINE MSDIALOG oDlgImpOS TITLE STR0023 FROM aTELA[1], aTELA[2] TO aTELA[3], aTELA[4] PIXEL // Imprimir O.S. selecionadas

// Cria Layer e as linhas
oLayer := FWLayer():New()
oLayer:Init(oDlgImpOS, .F., .T.)
oLayer:AddLine("TOP", 50, .F.)
oLayer:AddLine("BOT", 50, .F.)

// Cria as colunas
oLayer:AddCollumn("TCOL", 100, .F., "TOP")
oLayer:AddCollumn("BCOL", 100, .F., "BOT")

// Vari�veis (padr�o) para uso das colunas criadas
cTopCol := oLayer:getColPanel("TCOL", "TOP")
cBotCol := oLayer:getColPanel("BCOL", "BOT")

// Browse (Todas as OS)
oBrowseO := FWMBrowse():New()
oBrowseO:AddMarkColumns({|| IIF(aScan(aVetOS, {|x| x[7] == VO1->(RecNo())}), "CHECKED", "UNCHECKED")}, {|| OR0100036_MontaArrayBrowseOSSelecionadas()})
oBrowseO:SetAlias("VO1")
oBrowseO:SetOwner(cTopCol)
oBrowseO:SetDescription(STR0024) // Selecionar O.S. que deseja imprimir
oBrowseO:DisableDetails()
oBrowseO:SetMenuDef("")
oBrowseO:SetIgnoreARotina(.t.)
oBrowseO:SetDoubleClick({ || OR0100036_MontaArrayBrowseOSSelecionadas()})
oBrowseO:DisableReport()
oBrowseO:Activate()

// Browse (OS selecionadas)
// Usando Componente FWFormBrowse j� que est� sendo usado array por
// hierarquia do FWBrowse e esse componente possui inclus�o de bot�o
oBrowseS := FWFormBrowse():New()
oBrowseS:AddMarkColumns({|| IIF(aVetOS[oBrowseS:At(),1], "CHECKED", "UNCHECKED")}, {|| OR0100046_MarcaDesmarcaOSSelecionada()})
oBrowseS:SetOwner(cBotCol)
oBrowseS:SetDescription(STR0023) // Imprimir O.S. selecionadas
oBrowseS:SetDataArray()
oBrowseS:SetArray(aVetOS)
oBrowseS:SetColumns(OR0100026_ColunasBrowseOSSelecionadas())
oBrowseS:SetDoubleClick({ || OR0100046_MarcaDesmarcaOSSelecionada()})
oBrowseS:AddButton(STR0025, {|| OR0100056_ImpressaoOSSelecionadas(0)},,,, .F., 2) // Impress�o Formul�rio Normal
oBrowseS:AddButton(STR0026, {|| OR0100056_ImpressaoOSSelecionadas(1)},,,, .F., 2) // Impress�o Formul�rio Espec�fico
oBrowseS:DisableReport()
oBrowseS:Activate()

// Seta o foco no Browse Principal
oBrowseO:oBrowse:Setfocus()

ACTIVATE MSDIALOG oDlgImpOS

// Destr�i os Browse's pois d� erro ao reabrir a tela j� que o Alias fica "aberto"
oBrowseO:DeActivate()
oBrowseS:DeActivate()
Return .t.

/*/{Protheus.doc} OR0100026_ColunasBrowseOSSelecionadas
Retorna as colunas do Browse de OS selecionadas
@author Fernando Vitor Cavani
@since 05/12/2018
@version 1.0
@return aColumns, array, colunas VO1 das OS seleciondas
@type function
/*/
Static Function OR0100026_ColunasBrowseOSSelecionadas()
Local aColumns := {}

AAdd(aColumns, FWBrwColumn():New())
aColumns[1]:SetData(&("{|| aVetOS[oBrowseS:At(),2] }"))
aColumns[1]:SetTitle(RetTitle("VO1_FILIAL")) // Filial
aColumns[1]:SetSize(20) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[2]:SetData(&("{|| aVetOS[oBrowseS:At(),3] }"))
aColumns[2]:SetTitle(RetTitle("VO1_NUMOSV")) // Nro OS
aColumns[2]:SetSize(20) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[3]:SetData(&("{|| aVetOS[oBrowseS:At(),4] }"))
aColumns[3]:SetTitle(RetTitle("VO1_CHASSI")) // Chassi Veic
aColumns[3]:SetSize(20) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[4]:SetData(&("{|| aVetOS[oBrowseS:At(),5] }"))
aColumns[4]:SetTitle(STR0005) // Tipo de Tempo
aColumns[4]:SetSize(20) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[5]:SetData(&("{|| aVetOS[oBrowseS:At(),6] }"))
aColumns[5]:SetTitle(STR0006) // Cliente
aColumns[5]:SetSize(20) // 20 %
Return aColumns

/*/{Protheus.doc} OR0100036_MontaArrayBrowseOSSelecionadas
Monta o array das OS seleciondas
@author Fernando Vitor Cavani
@since 05/12/2018
@version 1.0
@return l�gico
@type function
/*/
Static Function OR0100036_MontaArrayBrowseOSSelecionadas()
Local nRecNo   := VO1->(RecNo())
Local cFilial  := VO1->VO1_FILIAL
Local cNumOS   := VO1->VO1_NUMOSV
Local cChassi  := VO1->VO1_NUMOSV
Local nPos     := 0
Local nCont    := 0
Local aPesqPec := {}
Local aPesqSer := {}
Local lPesqTT  := .f.

If nRecNo > 0
	nPos := aScan(aVetOS, {|x| x[7] == nRecNo})
	If Empty(nPos)
		// Pe�as
		aPesqPec := FMX_CALPEC(cNumOS,,,, .f., .t., .f., .t., .t., .t., .f.,,)
		For nCont := 1 to Len(aPesqPec)
			// Verificando se j� n�o existe o Tipo de Tempo para a OS selecionada
			nPos := aScan(aVetOS, {|x| x[7] == nRecNo .And. x[5] == aPesqPec[nCont, PECA_TIPTEM]})
			If Empty(nPos)
				lPesqTT := .t.

				Aadd(aVetOS, {                    ;
					.t.,                          ; //                // 01
					cFilial,                      ; // VO1_FILIAL     // 02
					cNumOS,                       ; // VO1_NUMOSV     // 03
					cChassi,                      ; // VO1_CHASSI     // 04
					aPesqPec[nCont, PECA_TIPTEM], ; // VO3_TIPTEM     // 05
					aPesqPec[nCont, PECA_CLIENTE],; // VO3_FATPAR     // 06
					nRecNo                        ; // VO1->(RecNo()) // 07
				})
			EndIf
		Next nCont

		// Servi�os
		aPesqSer := FMX_CALSER(cNumOS,,,, .f., .t., .t., .t., .t., .f.,,)
		For nCont := 1 to Len(aPesqSer)
			// Verificando se j� n�o existe o Tipo de Tempo para a OS selecionada
			nPos := aScan(aVetOS, {|x| x[7] == nRecNo .And. x[5] == aPesqSer[nCont, SRVC_TIPTEM]})
			If Empty(nPos)
				lPesqTT := .t.

				Aadd(aVetOS, {                    ;
					.t.,                          ; //                // 01
					cFilial,                      ; // VO1_FILIAL     // 02
					cNumOS,                       ; // VO1_NUMOSV     // 03
					cChassi,                      ; // VO1_CHASSI     // 04
					aPesqSer[nCont, SRVC_TIPTEM], ; // VO4_TIPTEM     // 05
					aPesqSer[nCont, SRVC_CLIENTE],; // VO4_FATPAR     // 06
					nRecNo                        ; // VO1->(RecNo()) // 07
				})
			EndIf
		Next nCont

		If !(lPesqTT)
			// Caso n�o foi encontrado nenhum Tipo de Tempo
			aAdd(aVetOS, {;
				.t.,      ; //                // 01
				cFilial,  ; // VO1_FILIAL     // 02
				cNumOS,   ; // VO1_NUMOSV     // 03
				cChassi,  ; // VO1_CHASSI     // 04
				"",       ; // Tipo Tempo     // 05
				"",       ; // Cliente        // 06
				nRecNo    ; // VO1->(RecNo()) // 07
			})
		EndIf

		oBrowseS:SetArray(aVetOS)
		oBrowseS:Refresh()
	Else
		// Remove OS do array
		While nPos <= Len(aVetOS) .And. aVetOS[nPos,7] == nRecNo
			aDel(aVetOS, nPos)
			aSize(aVetOS, Len(aVetOS) - 1)

			If Len(aVetOS) < 0
				aVetOS := {}
			EndIf
		EndDo

		oBrowseS:SetArray(aVetOS)
		oBrowseS:Refresh()
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} OR0100046_MarcaDesmarcaOSSelecionada
Marca/Desmarca a OS selecionada
@author Fernando Vitor Cavani
@since 10/01/2019
@version 1.0
@return l�gico
@type function
/*/
Static Function OR0100046_MarcaDesmarcaOSSelecionada()
Local nLin := oBrowseS:At()

If nLin > 0
	If aVetOS[nLin,1]
		aVetOS[nLin,1] := .f.
	Else
		aVetOS[nLin,1] := .t.
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} OR0100056_ImpressaoOSSelecionadas
Verifica qual fun艫o de impress�o deve ser chamada (Formul�rio Normal ou Espec�fico)
@author Fernando Vitor Cavani
@since 08/01/2019
@version 1.0
@param nTipo, num�rico, Tipo do Formul�rio de Impress�o (Normal ou Espec�fico)
@return l�gico
@type function
/*/
Static Function OR0100056_ImpressaoOSSelecionadas(nTipo)
Local nCont  := 0
Local nImp   := 0
Local cNumOS := ""

Default nTipo := 0

If Empty(aVetOS)
	MsgAlert(STR0027, STR0022) // Favor selecionar ao menos uma O.S. para impress�o. / Aten艫o
Else
	If nTipo == 0
		// Formul�rio Normal
		nFormul := 1

		For nCont := 1 To Len(aVetOS)
			If cNumOS != aVetOS[nCont,3]
				nImp := 2

				// Posicionando pois o RdMake n�o usa o par�metro e sim o posicionamento
				("VO1")->(dbGoTo(aVetOS[nCont,7]))

				// Impress�o Formul�rio Normal
				FG_PEDORD(aVetOS[nCont,3], "N", "N")
			EndIf

			cNumOS := aVetOS[nCont,3]
		Next

		If nImp == 0
			// Caso exista OS selecionada mas nenhuma marcada para impress�o
			MsgAlert(STR0028, STR0022) // Favor marcar ao menos uma das O.S. selecionadas para impress�o. / Aten艫o
		EndIf
	Else
		// Formul�rio Espec�fico
		nFormul := 2

		For nCont := 1 To Len(aVetOS)
			If aVetOS[nCont,1]
				If !(Empty(aVetOS[nCont,5]))
					nImp := 2
			
					// Posicionando pois o RdMake n�o usa o par�metro e sim o posicionamento
					("VO1")->(dbGoTo(aVetOS[nCont,7]))

					// Impress�o Formul�rio Espec�fico
					FG_PEDORD(aVetOS[nCont,3], "E", aVetOS[nCont,5])
				EndIf

				If nImp == 0
					// Caso exista OS selecionada e marcada para impress�o por�m sem Tipo de Tempo
					nImp := 1
				EndIf
			EndIf
		Next

		If nImp == 0
			// Caso exista OS selecionada mas nenhuma marcada para impress�o
			MsgAlert(STR0028, STR0022) // Favor marcar ao menos uma das O.S. selecionadas para impress�o. / Aten艫o
		ElseIf nImp == 1
			// Caso exista OS selecionada e marcada para impress�o por�m sem Tipo de Tempo
			MsgAlert(STR0029, STR0022) // Favor selecionar ao menos uma O.S. com Tipo de Tempo para impress�o. / Aten艫o
		EndIf
	EndIf
EndIf
Return .t.