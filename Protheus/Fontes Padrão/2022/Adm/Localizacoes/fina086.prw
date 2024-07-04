#include "FINA086.CH"
#Include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWLIBVERSION.CH"
#define CRLF Chr(13)+Chr(10)

Static lFWCodFil := .T.

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINA086   ³ Autor ³ Bruno Sobieski           ³ Data ³ 20.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Cancelacion de la orden de Pago.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³  BOPS  ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³04.06.99³Melhor  ³No dejar cancelar OP si alguno de sus    ³±±
±±³              ³05.07.99³Melhor  ³Acierto en la generacion del archivo de  ³±±
±±³              ³        ³        ³trabajo.                                 ³±±
±±³Bruno         ³19.11.99³Melhor  ³Atualizacao A1_SALDUP quando usado CT.   ³±±
±±³Bruno         ³19.11.99³Melhor  ³Considerar parametro MV_CPNEG.           ³±±
±±³Wagner M      ³08.06.10³Melhor  ³Alterado tratamento no cancelamento      ³±±
±±³              ³        ³        ³da ITF no cancelamento da OP e corrig    ³±±
±±³              ³        ³        ³ido contabilização do ITF.               ³±±
±±³Mayra Camargo ³09/05/13³Melhor  ³Se encontro error al revisar llamado     ³±±
±±³              ³        ³        ³TF2479. MarkBrow() no seleccionaba regs. ³±±
±±³              ³        ³        ³Se corrigio cambiando param. "" por null ³±±
±±³Emanuel V.V.  ³22/07/14³Melhor  ³TPMRHJ - Verifica si tiene retencion de  ³±±
±±³              ³        ³        ³IB y es de la provincia de Rio Negro     ³±±
±±³              ³        ³        ³para saber si procede anulacion o no.    ³±±
±±³Jonathan Glez ³01/07/15³PCREQ   ³Se elimina la funcion  fa086VldSIX,      ³±±
±±³              ³        ³-4256   ³la cual hacen modificacion a diccio-     ³±±
±±³              ³        ³        ³nario por motivo de adecuacion de        ³±±
±±³              ³        ³        ³fuentes para nuevas estructura de  SX    ³±±
±±³              ³        ³        ³SX para Version 12.                      ³±±
±±³Jonathan Glez ³09/10/15³PCREQ   ³Merge v12.1.8                            ³±±
±±³              ³        ³-4261   ³                                         ³±±
±±³Marco A. Glz. ³17/03/17³MMI-4866³Se replica a V12 la funcionalidad reali- ³±±
±±³              ³        ³        ³zada en el issue MMI-4727 V11.8 (ARG)    ³±±
±±³Laura Medina  ³30/06/17³MMI-6097³Al cancelar OP vinculada a Preorden, se  ³±±
±±³              ³        ³        ³preguntara si ¿Desea cancelar la Preorden³±±
±±³              ³        ³        ³de Pago vinculada a la OP X?:            ³±±
±±³              ³        ³        ³SI=Se mantiene misma funcionalidad (se   ³±±
±±³              ³        ³        ³   anula la OP y la Preorden)            ³±±
±±³              ³        ³        ³NO=Se anula OP y la Preorden queda con   ³±±
±±³              ³        ³        ³   estatus "aprobada"(para uso posterior)³±±
±±³Jonathan Glez ³27/09/17³TSSERMI01³En la funcion a086ChkPA() se cambia la  ³±±
±±³              ³        ³    -154 ³variable nNumOrdPg y se pone la etiqueta³±±
±±³              ³        ³         ³STR0119.                                ³±±
±±³Jose Glez     ³28/11/17|DMINA    ³Se agrega validacion para detectar si   ³±±
±±³              ³        |	  -1217 ³la rutina se ejecuta de manera automati-³±±
±±³              ³        |         |-ca y no mostrar cuadros de usuario     ³±±
±±³Raul Ortiz M  ³14/12/17³DMICNS-  ³Se corrige pregunta para consultar la   ³±±
±±³              ³        ³667      ³contabilidad online en la anulacion     ³±±
±±³              ³        ³         ³de una orden de pago.                   ³±±
±±³Raúl Ortiz M  ³12/03/18³DMICNS-  ³Se agrega funcionaliad al anular para   ³±±
±±³              ³        ³1276     ³dar de baja diferencia de cambio(ARG)   ³±±
±±³Raúl Ortiz M  ³13/03/18³DMICNS  ³Se modifica para no anular cheques cuando³±±
±±³              ³        ³ -1537  ³no han sido utilizados. Argentina.       ³±±
±±³M.Camargo     ³13/10/17³DMINA-761|Se modifica la variable nNumOP por      ³±±
±±³              ³        ³         ³cNumOP en la funcion a086checkTX .      ³±±
±±³              ³        ³         ³Se agrega mensaje STR0120 .             ³±±
±±³              ³        ³         ³Se modifica la función Cancela() y la   ³±±
±±³              ³        ³         ³función xAtuaSE2() para poder hacer     ³±±
±±³              ³        ³         ³el retorno correcto de saldos cuando    ³±±
±±³              ³        ³         ³se anula una OP que relaciona titulos   ³±±
±±³              ³        ³         ³de diferentes filiales.                 ³±±
±±³M.Camargo     ³11/06/18³DMINA-2992³Se modifica función xAtuaSE2() ,se e-  ³±±
±±³              ³        ³          ³limina condición cuando se anula OP    ³±±
±±³              ³        ³          ³de diferentes filiales ya que no per-  ³±±
±±³              ³        ³          ³mitía reversión de saldos al quedar    ³±±
±±³              ³        ³          ³cFilOrig vacía en anulación con par-   ³±±
±±³              ³        ³          ³cialidades.                            ³±±
±±³ Marco A Glez ³13/07/18³DMANSISTE-³Se replica issue DMINA-1913 (V12.1.14),³±±
±±³              ³        ³16        ³actualice E5_SITUACA con valor C si el ³±±
±±³              ³        ³          ³E5_RECPAG == "P". (MEX)                ³±±
±±³ gSantacruz   ³03/08/18³DMINA-3802³Peru, cambio en la funcion xDelSE5,    ³±±
±±³              ³        ³          ³que actualice los movto de SE5 cuando  ³±±
±±³              ³        ³          ³se  cancela la OP.                     ³±±
±±³ Alf. Medrano ³07/11/18³DMINA-4339³se actualiza la fun xAtuaSE2. en actua-³±±
±±³              ³        ³          ³lizacion de cuentas por pagar se asigna³±±
±±³              ³        ³          ³filial origen MEX.                     ³±±
±±³ Oscar G.     ³19/12/18³DMINA-5269³En Fun xDelSE5 se realiza localizacion ³±±
±±³              ³        ³          ³al eliminar doctos. en tabla SE5.      ³±±
±±³              ³        ³          ³En Fun xAtuaSE2 se restaura saldo de   ³±±
±±³              ³        ³          ³retenciones al cancelar OP.     (EQU)  ³±±
±±³ Oscar G.     ³09/05/19³DMINA-6481³En Fun. GeraTRB se suma desucento a    ³±±
±±³              ³        ³          ³Total bruto, en Func. xAtuaSE2 se ajus-³±±
±±³              ³        ³          ³ta calculo para restaruar saldo. (ARG) ³±±
±±³ Oscar G.     ³29/01/20³DMINA-7825³En Fun xDelSE5 se elimina actualizacion³±±
±±³              ³        ³          ³del campo E5_SITUACA duplicada. (MEX)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fina086( nOpcAuto, aCabOP, lRotAut)

	Local aStru			:= {}		
	Local cQuery		:= ""
	Local cArqTrab		:= ""
	Local cChave		:= ""
	Local nIndex		:= ""
	Local cResultPE		:= ""
	Local nI			:= 0
	Local aCpos			:= {}
	Local aCampos		:= {}
	Local lF086NP1		:= ExistBlock ("F086NP1")
	Local lF086NP2		:= ExistBlock ("F086NP2")
	Local cLayoutEmp	:= ""
	Local lGestao		:= .F.
	Local cCompSE2		:= ""
	Local lRet			:= .T.
	Local lCCR			:= .F.
	Local aAreaAtu	:= {}

	Private lFilCanc	:= .F.
	Private lDigita		:= .F.
	Private lAglutina	:= .F.
	Private lInverte	:= .F.
	Private lExclui		:= .F.
	Private nDecs		:= 0
	Private cMarcaTR	:= ""
	Private cCadastro	:= OemToAnsi(STR0012)
	Private aPos		:= {  8,  4, 11, 74 }
	Private cLibOrd		:= Alltrim(GetMV("MV_LIBORD"))
	Private cCodDiario 	:= ""
	Private aFlagCTB 	:= {}
	Private lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Private cForOP		:= ""
	Private cFilForOP	:= ""
	Private cNumOrdPg	:= ""
	Private nCondChq	:= 0
	Private dEmisOP		:= Ctod("//")
	Private lOPRotAut	:= .F.
	Private lMsfil		:= .F.
	Private oTmpTable	:= Nil
	Private lOrdPDesc := .F.
	Private lCancOP   := .T.
	Private nMsgOK    := 0
	
	Default cTxtRotAut := ""
	
	aAreaAtu := GetArea()
	DbSelectArea("SEK")
	dbSetOrder(1)
	If SEK->(ColumnPos("EK_CCR")) > 0 
		lCCR := .T.
	Endif
	RestArea(aAreaAtu)
	
	If lRotAut
		cForOP		:= PadR(aCabOP[1][2], TAMSX3( "FJR_FORNECE"	)[1] )
		cFilForOP	:= PadR(aCabOP[2][2], TAMSX3( "FJR_LOJA"		)[1] )
		cNumOrdPg	:= PadR(aCabOP[3][2], TAMSX3( "FJR_ORDPAG" 	)[1] )
		nCondChq	:= aCabOP[4][2]
		lOPRotAut	:= lRotAut
	EndIf

	If cPaisLoc == "ARG"
		cLayoutEmp 	:= FWSM0Layout()
		lGestao		:= Iif( lFWCodFil, ( "E" $ cLayoutEmp .And. "U" $ cLayoutEmp ), .F. )	// Indica se usa Gestao Corporativa
		If lFWCodFil .And. lGestao
			cCompSE2	:= FwModeAccess("SE2",1) + FwModeAccess("SE2",2) + FwModeAccess("SE2",3)
		Else
			cCompSE2	:= If(Empty(xFilial("SE2")),"CCC","EEE")
		Endif
		If cCompSE2 == "CCC"
			If !F850MsFil()
				lRet	:= .F.
			Endif
		Endif
	Endif

	If !pergunte("PAG018", !lOPRotAut) .AND. lRet
		lRet	:=	.F.
	Endif

	If lRet

		lFilCanc	:= If( Mv_Par01==1,.T.,.F.)
		lDigita	:= If( mv_par02==1,.T.,.F.)
		lAglutina	:= If( mv_par03==1,.T.,.F.)
		nDecs		:= MsDecimais(mv_par06)

		If lOPRotAut
			DbSelectArea("FJR")
			dbSetOrder(1)
			If DbSeek(XFilial("FJR")+cNumOrdPg)
				If FJR->FJR_CANCEL == .T.
					cTxtRotAut += STR0113 // "Ordem de pagamento já está cancelada."
					lRet	:= .F.
				Else
					dDEmisOP := FJR->FJR_EMISSA
					lRet	:=	F086RotAut()
				EndIf
			Else
				cTxtRotAut += STR0023 // Não existe.
				lRet	:= .F.
			EndIf
		Else

			AADD(aCampos,{ "MARK"			, "C", 2, 0 })
			AADD(aCampos,{ "NUMERO"		, "C", TamSX3("EK_ORDPAGO")[1]	, TamSX3("EK_ORDPAGO")[2]	})
			AADD(aCampos,{ "PROVEEDOR"	, "C", TamSX3("EK_FORNECE")[1]	, TamSX3("EK_FORNECE")[2]	})
			AADD(aCampos,{ "SUCURSAL"	, "C", TamSX3("EK_LOJA")[1]		, TamSX3("EK_LOJA")[2]		})
			AADD(aCampos,{ "TOTALBRUT"	, "N", 17, nDecs})
			If cPaisLoc $ "ARG|URU|BOL|PTG|ANG|PER"
				AADD(aCampos,{ "TOTALRET"	, "N", 17, nDecs })
			Endif
			AADD(aCampos,{ "TOTALDESC"	, "N", 17, nDecs })
			AADD(aCampos,{ "TOTALREDU"	, "N", 17, nDecs })
			AADD(aCampos,{ "TOTALDESP"	, "N", 17, nDecs })
			AADD(aCampos,{ "TOTALNETO"	, "N", 17, nDecs })
			AADD(aCampos,{ "EMISION"  	, "D",  8, 0 })
			AADD(aCampos,{ "CANCELADA"	, "C",  1, 0 })
			AADD(aCampos,{ "PODE" 	  	, "C",  1, 0 })
			
			If cPaisLoc <> "BRA"
				AADD(aCampos,{ "SITUACAO" 	  , "C",  2, 0 })
			EndIf
			If cPaisLoc $ "ARG"
				AADD(aCampos,{ "PGTOELT" , "C",  1, 0 })
			EndIf
			If cPaisLoc $ "MEX|COL|PER"
				AADD(aCampos,{ "NUMDOC"	, "C", TamSX3("EK_NUM")[1]	, TamSX3("EK_NUM")[2]	})
				AADD(aCampos,{ "TIPODOC"	, "C", TamSX3("EK_TIPODOC")[1]	, TamSX3("EK_TIPODOC")[2]	})
				AADD(aCampos,{ "PREFIXO"	, "C", TamSX3("EK_PREFIXO")[1]	, TamSX3("EK_PREFIXO")[2]	})
				AADD(aCampos,{ "PARCELA"	, "C", TamSX3("EK_PARCELA")[1]	, TamSX3("EK_PARCELA")[2]	})
				AADD(aCampos,{ "TIPO"	, "C", TamSX3("EK_TIPO")[1]	, TamSX3("EK_TIPO")[2]	})
			EndIf

			If cPaisLoc $ "MEX|ARG" .and. lF086NP1
				aCampos := ExecBlock ("F086NP1",.F.,.F.,aCampos)
			EndIf

			aOrdem := {"NUMERO"}
			
			oTmpTable := FWTemporaryTable():New("TRB")
			oTmpTable:SetFields(aCampos)
			oTmpTable:AddIndex("IN1", aOrdem)
			oTmpTable:Create()

			DbSelectArea("SEK")

			#IFDEF TOP
			If TcSrvType() != "AS/400"
				aStru	:=	DbStruct()
				dbCloseArea()
				dbSelectArea("SA1")

				cQuery:= " SELECT * FROM " + RetSqlName("SEK") + " WHERE"
				cQuery+= " EK_FILIAL = '" + xFilial("SEK") + "'"
				cQuery+= " AND EK_ORDPAGO BETWEEN '"+mv_par04+"' AND '" +mv_par05+"'"
				If ExistBlock("FA086FLT")
					cResultPE := ExecBlock("FA086FLT",.F.,.F.)
					If ValType(cResultPE) == "C"
						cQuery += cResultPE
					EndIf
				EndIf
				
				If lCCR   
					cQuery+= " AND EK_CCR = ''"
				Endif
				
				cQuery+= " AND D_E_L_E_T_ <> '*'"
				cQuery+= " ORDER BY EK_FILIAL,EK_ORDPAGO"
				cQuery:= ChangeQuery(cQuery)

				MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEK', .F., .T.) },OemToAnsi(STR0060),OemToAnsi(STR0001))

				For nI := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SEK', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			Else
				#ENDIF
				cArqTrab	:= Criatrab(NIL,.F.)
				cChave		:=	"EK_ORDPAGO"
				cCond		:= "EK_ORDPAGO>='"+mv_par04+"' .And. EK_ORDPAGO<='"+mv_par05+"' .And. EK_FILIAL=='"+xFilial("SEK")+"'"
				If ExistBlock("FA086FLT")
					cResultPE	:= ExecBlock("FA086FLT",.F.,.F.)
					If ValType(cResultPE) == "C"
						cCond	+= cResultPE
					EndIf
				EndIf
				IndRegua("SEK",cArqTrab,cChave,,cCond,OemToAnsi(STR0001))
				dbCommit()
				nIndex := RetIndex("SEK")
				dbSelectArea("SEK")
				#IFNDEF TOP
				DbSetIndex(cArqTrab+OrdBagExt())
				#ENDIF
				dbSetOrder(nIndex+1)
				dbGoTop()
				#IFDEF TOP
			EndIf
			#ENDIF

			Processa({|| GeraTRB() })

			#IFDEF TOP
			dbSelectArea("SEK")
			dbCloseArea()
			ChKFile("SEK")
			#ENDIF

			dbSelectArea("SEK")
			RetIndex("SEK")
			dbSetOrder(1)
			DbClearFilter()

			DbSelectArea("TRB")
			DbGoTop()

			If BOF() .and. EOF()
				Help(" ",1,"RECNO")
			Else
				aCpos:={}
				AADD(aCpos,{ "MARK"     , "","" })
				AADD(aCpos,{ "NUMERO"   , "", OemToAnsi(STR0003) }) //"Ord. de PAgo"
				AADD(aCpos,{ "PROVEEDOR", "", OemToAnsi(STR0004) }) //"Proveedor"
				AADD(aCpos,{ "SUCURSAL" , "", OemToAnsi(STR0005) }) //"Suc."
				AADD(aCpos,{ "TOTALBRUT", "", OemToAnsi(STR0006),PesqPict("SEK","EK_VALOR",17,mv_par06) }) //"Total Bruto"
				If cPaisLoc $ "ARG|URU|BOL|PTG|ANG|PER"
					AADD(aCpos,{ "TOTALRET" , "", OemToAnsi(STR0007),PesqPict("SEK","EK_VALOR",17,mv_par06) }) //"Retenciones"
				Endif
				AADD(aCpos,{ "TOTALDESC", "", OemToAnsi(STR0008),PesqPict("SEK","EK_VALOR",17,mv_par06) }) //"Total Desc. PAs"
				AADD(aCpos,{ "TOTALREDU", "", OemToAnsi(STR0009),PesqPict("SEK","EK_VALOR",17,mv_par06) }) //"Total Reducido"
				AADD(aCpos,{ "TOTALNETO", "", OemToAnsi(STR0010),PesqPict("SEK","EK_VALOR",17,mv_par06) }) //"Total Neto"
				AADD(aCpos,{ "EMISION"  , "", OemToAnsi(STR0011) }) //"Emitida"
				If cPaisLoc <> "BRA"
					AADD(aCpos,{ "SITUACAO" , "", OemToAnsi("Estatus"),"@!" }) //"Status"
				Endif

				If cPaisLoc $ "MEX|ARG" .and. lF086NP2
					aCpos := ExecBlock ("F086NP2",.F.,.F.,aCpos)
				EndIf

				PRIVATE aRotina := MenuDef()

				If cPaisLoc <> "BRA"
					lInverte:=.F.
					cMarcaTR := GetMark()

					fa086MBrow("TRB","MARK","SITUACAO",aCpos,cMarcaTR,nOpcAuto)
				Else
					cMarcaTR := GetMark()
					MarkBrow("TRB","MARK","CANCELADA+PODE",aCpos,,cMarcaTR,,,,,IIf( cPaisLoc=="COS","ValidCH('TRB')",Nil) )
				EndIf
			ENDIF
			If oTmpTable <> Nil
				oTmpTable:Delete()
				oTmpTable := Nil
			EndIf
		EndIf
	EndIf

	If !lRet
		AutoGrLog(cTxtRotAut)
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GeraTRB  ³ Autor ³ Bruno Sobieski        ³ Data ³ 12/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera el archivo de trabajo.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTRB()

	Local cForAnt, cLojaAnt, cPode, nTB, nTR, nDe, nRe
	Local cSituacao 	:= "01"
	Local cPgtoElt  	:= ""
	Local lF086NP3  	:= ExistBlock ("F086NP3") 
	Private lOrdRet     := .F.
	Private lTitRet		:=	GetNewPar("MV_TITRET",.F.)

	dbSelectArea("SEK")
	SEK->(DbGoTop())
	ProcRegua(Reccount())
	DO WHILE SEK->(!EOF())
	

		lOrdRet := Iif( cPaisLoc $ "PER|EQU", xValOrd(EK_ORDPAGO),.F.)
		IF ( cPaisLoc=="ARG" .OR. lOrdRet .Or. AllTrim(EK_TIPO)<>"TF")  .and. !(lFilCanc .And. ( EK_CANCEL .or. (cPaisLoc == "CHI" .and. !EK_CANCEL .and. !Empty(SEK->EK_CANPARC)) ) ) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento de OPs agrupadas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cpaisLoc <> "BRA"
				If !Empty(EK_FORNEPG)
					cForAnt   := EK_FORNEPG
					cLojaAnt  := EK_LOJAPG
				Else
					cForAnt   := EK_FORNECE
					cLojaAnt  := EK_LOJA
				Endif
			Else
				cForAnt   := EK_FORNECE
				cLojaAnt  := EK_LOJA
			Endif

			DbSelectArea("TRB")
			If !dbSeek(SEK->EK_ORDPAGO)

				Reclock("TRB",.T.)
				TRB->PROVEEDOR	:=cForAnt
				TRB->SUCURSAL 	:=cLojaAnt
				TRB->EMISION  	:=SEK->EK_DTDIGIT
				TRB->NUMERO   	:=SEK->EK_ORDPAGO
				If cPaisLoc $ "MEX|COL|PER"
					TRB->NUMDOC := SEK->EK_NUM 
					TRB->PREFIXO:= SEK->EK_PREFIXO
					TRB->TIPODOC:= SEK->EK_TIPODOC
					TRB->PARCELA:= SEK->EK_PARCELA
					TRB->TIPO	:= SEK->EK_TIPO
				EndIf
				TRB->CANCELADA	:=IIF(SEK->EK_CANCEL .or. (cPaisLoc == "CHI" .and. !Empty(SEK->EK_CANPARC)),"S","")
				If cPaisLoc $ "MEX|ARG" .and. lF086NP3
					ExecBlock ("F086NP3",.F.,.F.,"TRB")
				EndIf
				MsUnlock()
			EndIf

			aVerOP := F086VerOP()

			cPode		:= aVerOP[1][1][2]
			cSituacao	:= aVerOP[1][2][2]
			cPgtoElt	:= aVerOP[1][3][2]
			nDE			:= aVerOP[1][4][2]
			If cPaisLoc == "ARG"
				nTB		:= aVerOP[1][5][2] + Iif(aVerOP[1][4][3],nDE,0) 
			Else
				nTB		:= aVerOP[1][5][2]
			EndIf
			nRE			:= aVerOP[1][6][2]
			nTR			:= aVerOP[1][7][2]

			Reclock("TRB")
			TRB->PODE		:=	cPode
			TRB->TOTALBRUT	+=	nTB
			If cPaisLoc $ "ARG|URU|BOL|PTG|ANG|PER"
				TRB->TOTALRET +=	nTR
			Endif
			TRB->TOTALDESC	+=	nDe
			TRB->TOTALREDU	+=	nRe
			TRB->TOTALNETO	+=	(nTB-nTR-nDe-nRe)  
			If cPaisLoc <> "BRA"
				If cSituacao $ "01|03|04|05|06|07" .and. TRB->CANCELADA <> "S"
					TRB->SITUACAO	:= cSituacao
				Else
					TRB->SITUACAO	:= "02"
				EndIf
			EndIf
			If cPaisLoc == "ARG"
				TRB->PGTOELT := cPgtoElt
			EndIf
			MsUnlock()
			cSituacao 	:= "01"
			cPgtoElt	:= ""
			DbSelectArea("SEK")
		Else
			IncProc()
			SEK->(DbSkip())
		Endif
	EndDo
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ PAGO019  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ CANCELACION DE LA ORDEN DE PAGO                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pago018                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  DATA    ¦ BOPS ¦                  ALTERACAO                          ¦¦¦
¦¦+----------+------+-----------------------------------------------------¦¦¦
¦¦¦20.05.99	 ¦Melhor¦Desmarcado de los elementos despues de cancelados,   ¦¦¦
¦¦¦        	 ¦      ¦ inclusion de una Regla de Procesamiento y acierto en¦¦¦
¦¦¦        	 ¦      ¦ la grabacion de la fecha de baja.                   ¦¦¦
¦¦¦04.06.99	 ¦Melhor¦Considerar titulos tipo AB- .                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function fa086Cancel()

	Local lExclui	:= .T.
	local lRet		:= .T.

	If !CtbValiDt(,dDatabase,,,,{"FIN001"},)

		Return
	EndIf

	If ExistBlock("FA086OK")
		lExclui := ExecBlock("FA086OK",.F.,.F.)
	Endif

	If lExclui .And. UsaSeqCor()
		cCodDiario := CTBAVerDia()
	Endif

	If lExclui

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000313")

		Processa({ || lRet := Cancela()})  //,,,"Cancelando"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a gravacao dos lancamentos do SIGAPCO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoFinLan("000313")

		If ExistBlock("FA86CAN")
			ExecBlock("FA86CAN",.F.,.F.)
		Endif
		If lRet
		   MsgInfo(STR0120)//"Anulación finalizada con Exito"
		EndIf
	EndIf
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cancela    ³ Autor ³ Lucas               ³ Data ³ 16.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para cancelar Orden de Pago.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cancela()

Local cArquivo      := ""
Local nHdlPrv       := 0
Local nTotalLanc    := 0
Local cLoteCom      := ""
Local nLinha        := 2
Local lLancPad71    := .F. //VerPadrao("571")
Local cOper         := ""
Local cSolic        := ""
Local cOrdPago      := ""
Local cFornec       := ""
Local cLoja         := ""
Local lPgtoElt      := .F.
Local nColig        := GetNewPar("MV_RMCOLIG",0)
Local lMsgUnica     := IsIntegTop()
#IFDEF TOP
    Local cQuery        := ""
#ENDIF
Local cAlias        := ""
Local cKeyImp       := ""
Local lRet          := .T.
Local cNumOrdPag    := ""
Local cPadrao571    := ""
Local aFormasPgto   := {}
Local nC            := 0
Local cNumOP
Local cFornece		:= ""
Local cTabela		:= ""
Local lIsMark
Local cFilFVC       := xFilial("FVC")
Local cFilFJK       := xFilial("FJK")
Local lAutomato     :=IsBlind()
Local lBajaTpTit 	:= .F.
Local nDocsBj		:= 0
Local cTpBaja		:= ""

Default lOPRotAut   := .F.

Private nSalvRec    := 0
Private aDiario := {}
Private cDebMed := ""
Private aDebMed := {}
Private cDebInm := {}
Private aDebInm := {}
Private lGeraLanc	:= .T. // Lanctos. On-Line
Private aRecnoSE2 := {}
Private aFilOrig  := {}

cTabela := Iif( lOPRotAut, "SEK", "TRB")
nMsgOK		:= 0 
lCancOP	:= .T.

/* Verifica as formas de pagamento */
lOrdPDesc   := .F.
aDebMed     := {}
aDebInm     := {}
aTipoTerc       := {}
aTipoDocto      := {"Todos"}
cTipoDocto      := aTipoDocto[1]
cDocPg          := ""
aFormasPgto := Fin025Tipo()

For nC := 1 To Len(aFormasPgto)
    If aFormasPgto[nC,5] $ "13" .And. aFormasPgto[nC,7]     //documentos de terceiros
        Aadd(aTipoTerc,Aclone(aFormasPgtop[nC]))
        Aadd(aTipoDocto,aFormasPgto[nC,3])
    Endif
    If aFormasPgto[nC,5] $ "23"
        If aFormasPgto[nC,4] == "1"
            Aadd(aDebMed,aFormasPgto[nC,1])
        Else  //gera movimento bancario
            Aadd(aDebInm,aFormasPgto[nC,1])
        Endif
        If !Empty(cDocPg)
            cDocPg += ";"
        Endif
        cDocPg += (AllTrim(aFormasPgto[nC,1]) + "=" + Alltrim(aFormasPgto[nC,3]))
    Endif
Next
If Len(aDebMed) ==  0
    aDebMed :=  {MVCHEQUE}
Endif
cDebMed :=  aDebMed[1]
If Len(aDebInm) ==  0
    If Ascan(aDebmed,"TF") = 0
        AAdd(aDebInm,"TF")
    EndIf
    If Ascan(aDebMed,"EF") = 0
        AAdd(aDebInm,"EF")
    EndIf
    If Len(aDebInm) ==  0
        AAdd(aDebInm,"")
    EndIf
Endif
cDebInm :=  aDebInm[1]+IiF(Len(aDebInm)>1,"|"+aDebInm[2],"")

BEGIN TRANSACTION

DbSelectArea(cTabela)
DbGoTop()
ProcRegua(Reccount())
Do While !EOF() .and. lRet
    IncProc()
    
    cNumOP   := Iif( lOPRotAut, cNumOrdPg,   TRB->NUMERO      )
    cFornece := Iif( lOPRotAut, cForOP,      TRB->PROVEEDOR )
    cLoja    := Iif( lOPRotAut, cFilForOP,   TRB->SUCURSAL  )
    
  If !lAutomato 
      lIsMark  := Iif( lOPRotAut, .T., IsMArk("MARK",cMarcaTR) ) 
  Else
      lIsMark := .T.
  Endif
    
    If lIsMark .AND. a086chkSEF() .AND. a086chSFE() .AND. a086checkTX()
        
        DbSelectArea("SEK")
        DbSetOrder(1)
        If DbSeek(xFilial("SEK")+cNumOP)
            cNumOrdPag := cNumOP
        EndIf
		lBajaTpTit := .F.
		nDocsBj := 0
        Do While xFilial("SEK") == SEK->EK_FILIAL .AND. cNumOP == SEK->EK_ORDPAGO 
            If !SEK->EK_CANCEL
					If cPaisLoc == "COL" .And. SEK->EK_DESCONT <> 0
						lOrdPDesc := .T.
					EndIf

					//Valida se é pagamento eletrônico
					If cPaisLoc == "ARG|RUS|"
						If 	SEK->EK_PGTOELT == "1"
							lPgtoElt := .T.
						EndIf
					EndIf
            
            // Se Portugal, Alimenta aDiario
            If UsaSeqCor()
                AADD(aDiario,{"SEK",SEK->(RECNO()),cCodDiario,"EK_NODIA","EK_DIACTB"})
            Endif
            
            If SEK->EK_TIPODOC=="CP"
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                PcoDetLan("000313","04","FINA085A",.T.)
                lRet    :=  xDelChqPr(lPgtoElt)
				If cPaisLoc $ "PER|EQU"
					lOrdRet := xValOrd(SEK->EK_ORDPAGO)
					If lOrdRet
						xAtuaSE2()
						lOrdRet:=.F.
					EndIf
				EndIf
            ElseIf SEK->EK_TIPODOC=="CT"
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                PcoDetLan("000313","03","FINA085A",.T.)
                xAtuaChqTer()
            ElseIf SEK->EK_TIPODOC$"TB" .And. !lPgtoElt
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                PcoDetLan("000313","01","FINA085A",.T.)
                xAtuaSE2()
				nDocsBj++
            ElseIf SEK->EK_TIPODOC$"RG"
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                PcoDetLan("000313","01","FINA085A",.T.)
                xDelSE2TX()
				lBajaTpTit := .T.
            ElseIf SEK->EK_TIPODOC$"PA"
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  PcoDetLan("000313","01","FINA085A",.T.)
                  xDelSE2PA()
            Endif
            RecLock("SEK",.F.)
            Replace SEK->EK_CANCEL With .T.
            MsUnLock()
             
            //-------------------------------------------
            // Atualizao cabecalho da Ordem de Pagamento
            //-------------------------------------------
            DbSelectArea("FJR")
            DbSetOrder(1) //FJR_FILIAL+FJR_ORDPAG
            If DbSeek(XFilial("FJR")+SEK->EK_ORDPAGO)
                RecLock("FJR",.F.)
                FJR->FJR_CANCEL := .T.
                FJR->(MsUnlock())
            EndIf
            
            If nColig > 0  .and. IntePMS() .And. SEK->EK_TIPODOC=="PA" .and. !lMsgUnica
                lRet    :=  FA086PMS()
            Endif
            //-------------------------------------------------------
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³FSW - Silvia Monica - 16/08/2011³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If cPaisLoc <> "BRA" .And. SEK->EK_TIPODOC == "PA" .and. lRet
                cSolic      := SEK->EK_SOLFUN
                cOrdPago    := SEK->EK_ORDPAGO
                cOper       := "E"
                cFornec     := SEK->EK_FORNECE
                cLoja       := SEK->EK_LOJA
                FA585PAGTO(cSolic, cOrdPago, cOper, cFornec, cLoja)
            Endif
          Endif
        SEK->(DbSkip())            
        EndDo
		//Métrica
		If cPaisLoc != "EQU" 
			If lBajaTpTit .and. nDocsBj == 1 // Retención
				cTpBaja := "RG"
			ElseIf  lBajaTpTit .and. nDocsBj > 1 //Retención combinada
				cTpBaja := "TB_RG"
			ElseIf !lBajaTpTit // baja de titulo normal
				cTpBaja := "TB"
			EndIf
			LxMetFS086(cTpBaja)
		EndIf


        If lRet//se a OP estiver apropriada no top, nao foi possivel cancelar
            xDelRgPa() //Borra todos los documentos relativos a Retenciones.
            //+--------------------------------------------------------------+
            //¦ Genera asiento contable.                                     ¦
            //+--------------------------------------------------------------+
            If lGeraLanc
                //+--------------------------------------------------------------+
                //¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
                //+--------------------------------------------------------------+
                dbSelectArea("SX5")
                dbSeek(xFilial()+"09FIN")
                cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
                nHdlPrv := HeadProva( cLoteCom,;
                "PAGO019",;
                Substr( cUsuario, 7, 6 ),;
                @cArquivo )
                
                If nHdlPrv <= 0
                    Help(" ",1,"A100NOPROV")
                EndIf
            EndIf
            xDelSE5()  //Borra todas las bajas del SE5.
            
            If !lOPRotAut
                DbSelectArea("TRB")
                RecLock("TRB",.f.)
                Replace CANCELADA With "S"
                MsUnLock()
            EndIf
            
            
            If nHdlPrv > 0
                SEK->(DbSetOrder(1))
                SEK->(DbSeek(xFilial("SEK")+cNumOP,.F.))
                SA2->(DbsetOrder(1))
                SA2->(DbSeek(xFilial()+SEK->EK_FORNECE+SEK->EK_LOJA))
                
                Do while !SEK->( EOF() ) .And. SEK->EK_ORDPAGO == cNumOP
                    
                    Do Case
                        Case SEK->EK_TIPODOC == "TB" .And. SEK->EK_TIPO $ MV_CPNEG+"/"+MVPAGANT .And. VerPadrao("5BG")
                            lLancPad71 := .T.
                            cPadrao571 := "5BG"
                        Case SEK->EK_TIPODOC == "TB" .And. !(SEK->EK_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. VerPadrao("5BH")
                            lLancPad71 := .T.
                            cPadrao571 := "5BH"
                        Case SEK->EK_TIPODOC == "PA" .And. VerPadrao("5BI")
                            lLancPad71 := .T.
                            cPadrao571 := "5BI"
                        Case SEK->EK_TIPODOC == "CP" .And. SEK->EK_TIPO $ cDebMed .And. VerPadrao("5BJ")
                            lLancPad71 := .T.
                            cPadrao571 := "5BJ"
                        Case SEK->EK_TIPODOC == "CP" .And. SEK->EK_TIPO $ cDebInm .And. VerPadrao("5BK")
                            lLancPad71 := .T.
                            cPadrao571 := "5BK"
                        Case SEK->EK_TIPODOC == "CT" .And. VerPadrao("5BL")
                            lLancPad71 := .T.
                            cPadrao571 := "5BL"
                        Case SEK->EK_TIPODOC == "RG" .And. VerPadrao("5BM")
                            lLancPad71 := .T.
                            cPadrao571 := "5BM"
                        Otherwise
                            lLancPad71 := VerPadrao("571")
                            cPadrao571 := "571"
                    EndCase
                    If lLancPad71
                        If ( SEK->EK_TIPODOC=="CP" )
                            SA6->(DbsetOrder(1))
                            SA6->(DbSeek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))
                        EndIf
                        If SEK->EK_LA=="S"
                            Do Case
                                Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
                                    cAlias := "SF2"
                                Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
                                    cAlias := "SF2"
                                Otherwise
                                    cAlias := "SF1"
                            EndCase
                            cKeyImp := xFilial(cAlias)  +;
                            SEK->EK_NUM     +;
                            SEK->EK_PREFIXO +;
                            SEK->EK_FORNECE +;
                            SEK->EK_LOJA
                            If ( cAlias == "SF1" )
                                cKeyImp += SE1->E1_TIPO
                            Endif
                            Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
                            
                            If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
                                aAdd( aFlagCTB, {"EK_LA", "C", "SEK", SEK->( Recno() ), 0, 0, 0} )
                            Else
                                RecLock("SEK",.F.)
                                Replace EK_LA With "C"
                                MsUnLock()
                            EndIf
                            
                            SE2->(dbGoTo(nSalvRec))
                            dbSelectArea("SEK")
                            nTotalLanc += DetProva( nHdlPrv,;
                            cPadrao571,;
                            "PAGO019",;
                            cLoteCom,;
                            @nLinha,;
                            /*lExecuta*/,;
                            /*cCriterio*/,;
                            /*lRateio*/,;
                            /*cChaveBusca*/,;
                            /*aCT5*/,;
                            /*lPosiciona*/,;
                            @aFlagCTB,;
                            /*aTabRecOri*/,;
                            /*aDadosProva*/ )
                        Endif
                    Endif
                    SEK->(DbSkip())
                ENDDO
                
                //+-----------------------------------------------------+
                 //¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
                //+-----------------------------------------------------+
                RodaProva(  nHdlPrv,;
                nTotalLanc)
                
                //+-----------------------------------------------------+
                //¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
                //+-----------------------------------------------------+
                lLanctOk := cA100Incl( cArquivo,;
                nHdlPrv,;
                3,;
                cLoteCom,;
                lDigita,;
                lAglutina,;
                /*cOnLine*/,;
                /*dData*/,;
                /*dReproc*/,;
                @aFlagCTB,;
                /*aDadosProva*/,;
                aDiario )
                aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
                
                If !lLanctOk .AND. !lUsaFlag
                    #IFDEF TOP
                        cQuery := "UPDATE " + RetSqlName("SEK")
                        cQuery += "  SET EK_LA = 'S' "
                        cQuery += "WHERE EK_ORDPAGO ='" + cNumOp + "' AND "
                        cQuery += "D_E_L_E_T_ = ' ' "
                        TCSqlExec( cQuery )
                    #ELSE
                        SEK->(DbSeek(xFilial("SEK")+cNumOP))
                        While !SEK->(EOf()) .and.;
                            SEK->EK_FILIAL == xFilial("SEK") .and.;
                            SEK->EK_ORDPAGO == cNumOP
                            RecLock("SEK",.F.)
                            Replace EK_LA   With "S"
                            MsUnLock()
                            SEK->(DbSkip())
                        End
                    #ENDIF
                EndIf
            EndIf
        Endif//Somente executa se puder cancelar a OP
        //-------------------------------
        // Cancelamento da Pre-OP Mod II
        //-------------------------------
        If cPaisLoc <> "BRA" .And. !Empty(cNumOrdPag)
            DbSelectArea("FJK")
			FJK->(DbSetOrder(2)) //FJK_FILIAL+FJK_ORDPAG+FJK_PREOP
			If FJK->(DbSeek(cFilFJK+cNumOrdPag))				
				While FJK->(!Eof()) 
					If FJK_FILIAL+FJK_ORDPAG == cFilFJK+cNumOrdPag
						If lCancOP
							If AliasInDic("FVC")
								DBSELECTAREA("FVC")
								FVC->(DBSETORDER(1)) //FVC_FILIAL+FVC_PREOP+FVC_TIPO
								If FVC->(DBSEEK(cFilFVC+FJK->FJK_PREOP))
									While FVC->(!Eof()) .AND. FJK->FJK_PREOP == FVC->FVC_PREOP .AND. FVC->FVC_FILIAL == cFilFVC
										RecLock("FVC",.F.)
										FVC->(DbDelete())
										FVC->(MsUnlock())
										FVC->(DbSkip())
									Enddo
								EndIf
							EndIf 
						Endif
						RecLock("FJK",.F.)
						IF lCancOP
							FJK->FJK_DTCANC := dDataBase
						Else
							FJK->FJK_ORDPAG := ""
						Endif
							FJK->(MsUnlock())
					Endif
				FJK->(DbSkip())
				EndDo
			EndIf
		EndIf
    Endif
    If !lOPRotAut
        DbSelectArea("TRB")
        RecLock("TRB", .F.)
        Replace MARK With ""
        MsUnLock()
    EndIf
    DbSkip()
EndDo


END TRANSACTION
DisarmTransaction()
msUnlockAll()

Return lRet

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelChqPr¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Borrar los registros relacionados con el Chwuqe Propio.    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
Uso       ¦ PAGO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function xDelChqPr(lPgtoElt)

	Local nSinal		:= 1
	Local cTipos		:= GetSESTipos({|| ES_RCOPGER == "1"},"2") // Debitos Inmediatos
	Local aArea			:= GetArea()
	Local cCampo		:= ""
	Local cSeqFRF		:= ""
	Local cCondWhile	:= ".F."
	Local oDlg1
	Local nRadio		:= Iif(lOPRotAut, nCondChq, 0)
	Local oRadio
	Local lRet			:= .T.             
	Local aAreaAnt 		:= {}
	Local oModelBx		:= Nil
	Local oSubFKA		:= Nil
	Local lRetSE5		:= .T.
	Local cLog			:= ""
	Local lAutomato     :=IsBlind()
	Local aRetAuto		:= {}

	DEFAULT lPgtoElt	:= .F. //define se é pagamento eletrônico ou não

	DbSelectArea("SE2")
	DbSetOrder(1)
	DbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incluido o tipo 'EF' e a pesquisa de Debitos Inmediatos no SES³
	//³Sergio Fuzinaka - 08.10.01                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !FOUND() .AND. !(trim(SEK->EK_TIPO)$"CA|TF|TJ|VC|EF") .AND. ((trim(SEK->EK_TIPO)$cTipos) .Or. SEK->EK_TIPO$MVCHEQUE) .And. !lPgtoElt
		// "El titulo ", " de ", " no existe."
		If lOPRotAut
			cTxtRotAut	:=	OemToAnsi(STR0021)+SEK->EK_PREFIXO+SEK->EK_NUM+" "+SEK->EK_PARCELA;
			+SEK->EK_TIPO+OemToAnsi(STR0022)+SEK->EK_FORNECE+" "+SEK->EK_LOJA+ OemToAnsi(STR0023)
			lRet		:= .F.
		Else
			MsgStop(OemToAnsi(STR0021)+SEK->EK_PREFIXO+SEK->EK_NUM+" "+SEK->EK_PARCELA;
			+SEK->EK_TIPO+OemToAnsi(STR0022)+SEK->EK_FORNECE+" "+SEK->EK_LOJA+ OemToAnsi(STR0023))
		EndIf
	ELSE
		If !(trim(SEK->EK_TIPO)$"CA|TF|TJ|VC|EF") .AND. ((trim(SEK->EK_TIPO)$cTipos) .Or. SEK->EK_TIPO$MVCHEQUE) .And. !lPgtoElt
			nSinal	:=	IIf(E2_TIPO$MV_CPNEG+"/"+MVPAGANT,-1,1)
			SA2->(DbSetOrder(1))
			If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
				SA2->(DbSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
			Else
				SA2->(DbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA))
			Endif
			RecLock("SA2",.F.)
			SA2->A2_SALDUP 	:= SA2->A2_SALDUP  - SE2->E2_VLCRUZ * nSinal
			SA2->A2_SALDUPM	:= SA2->A2_SALDUPM - xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,Val(GetMv("MV_MCUSTO")),SE5->E5_DATA) * nSinal
			MsUnLock()
			RecLock("SE2",.F.)
			DbDelete()
			MsUnLock()
		Endif
		If AllTrim(SEK->EK_TIPO)=="CA" .And. !lPgtoElt
			cOrder		:= Indexord()
			nTamPago	:= Tamsx3("EF_TITULO")[1]
			cNumero	:= Padr(SEK->EK_ORDPAGO,nTamPago)
			cPref		:= Space(TamSx3("EF_PREFIXO")[1])
			cParc		:= Space(TamSx3("EF_PARCELA")[1])

			dbSelectArea("SEF")
			dbSetOrder(3)
			dbSeek(xFilial("SEF")+ cPref +cNumero+cParc+"ORP")
			dbSetorder(cOrder)
			cCampo:=SEF->EF_TITULO

			cCondWhile := "SEF->EF_PREFIXO == cPref .and. AllTrim(SEF->EF_TITULO) == AllTrim(cNumero) .and. "
			cCondWhile += "SEF->EF_PARCELA == cParc .and. AllTrim(SEF->EF_TIPO) == 'ORP'"

		ElseIf AllTrim(SEK->EK_TIPO) == "CH"
			If !lPgtoElt
				RecLock("SE2",.F.)//deve ser deletado o cheque do E2.
				DbDelete()
				MsUnLock()
			EndIf

			DbSelectArea("FRE")
			FRE->(dbSetOrder(3))//indice alterado de 1 para 3 Caio Quiqueto dos Santo 26/01/12
			FRE->(dbSeek(xFilial("FRE")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+SEK->EK_TALAO))

			nTamPago := Tamsx3("EF_TITULO")[1]
			cNumero  := Padr(SEK->EK_ORDPAGO,nTamPago)

			dbSelectArea("SEF")
			SEF->(dbSetOrder(3))
			If cPaisLoc == "BOL"
				//EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
				SEF->(MsSeek(xFilial("SEF")+FRE->FRE_PREFIX+cNumero+SEK->EK_PARCELA+"CH "+SEK->EK_NUM))
			Else
				SEF->(dbSeek(xFilial("SEF")+FRE->FRE_PREFIX+cNumero+SEK->EK_PARCELA+"CH"))
			EndIf
			cCampo  := SEF->EF_TITULO

			If cPaisLoc == "ARG"
				cCondWhile := "SEF->EF_PREFIXO == FRE->FRE_PREFIX .and.	AllTrim(SEF->EF_TITULO) == AllTrim(SEK->EK_ORDPAGO) .and. " 
				cCondWhile += "SEF->EF_PARCELA == SEK->EK_PARCELA .and. AllTrim(SEF->EF_TIPO) == 'CH'"
			Else
				cCondWhile := "SEF->EF_PREFIXO == FRE->FRE_PREFIX .and.	AllTrim(SEF->EF_NUM) == AllTrim(SEK->EK_NUM) .and. " 
				cCondWhile += "SEF->EF_PARCELA == SEK->EK_PARCELA .and. AllTrim(SEF->EF_TIPO) == 'CH'"
			EndIf
		ElseIf (SEK->EK_TIPO$MVCHEQUE)
			cNumero := SEK->EK_NUM
			dbSelectArea("SEF")
			dbSetOrder(1)
			dbSeek(xFilial("SEF")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+cNumero,.t.)
			cCampo:=SEF->EF_NUM

			cCondWhile := "SEF->EF_BANCO == SEK->EK_BANCO .and.	SEF->EF_AGENCIA == SEK->EK_AGENCIA .and. "
			cCondWhile += "SEF->EF_CONTA == SEK->EK_CONTA .and. AllTrim(cNumero) == '"+AllTrim(cCampo)+"'"
		EndIf
		If Found() .AND. lRet
			While !(SEF->(Eof())) .and. SEF->EF_FILIAL == xFilial("SEF") .and. &cCondWhile.
				If Alltrim(UPPER(SEF->EF_ORIGEM)) $ "FINA085A|FINA095|FINA850"
					If AllTrim(SEF->EF_NUM) == AllTrim(SEK->EK_NUM)
						If !(cPaisLoc <> "BRA" .AND. SEF->EF_STATUS $ '06|07') //Verifica se o cheque é da Rep. Dominicana ou Equador e se não é substituido ou Devolvido
							IF SEF->EF_IMPRESS == "S"
								RecLock("SEF",.F.)
								SEF->EF_IMPRESS	:=	"C"
								SEF->EF_STATUS := "05"
								MSUnLock()
								//Registrar Historico do Cheque (Folha de cheque cancelada por satisfação do correntista).
								DbSelectArea("FRF")
								cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
								RecLock("FRF",.T.)
								FRF->FRF_FILIAL	:= xFilial("FRF")
								FRF->FRF_BANCO	:= SEF->EF_BANCO
								FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
								FRF->FRF_CONTA	:= SEF->EF_CONTA
								FRF->FRF_NUM		:= SEF->EF_NUM
								FRF->FRF_PREFIX	:= SEF->EF_PREFIXO
								FRF->FRF_CART		:= "P"
								FRF->FRF_DATPAG	:= dDataBase
								FRF->FRF_MOTIVO	:= "20"
								FRF->FRF_DESCRI	:= "CHEQUE ANULADO"
								FRF->FRF_SEQ		:= cSeqFRF
								FRF->(MsUnLock())
								ConfirmSX8()
								If Alltrim(UPPER(SEF->EF_ORIGEM)) $ "FINA085A|FINA095|FINA850"
									Exit
								EndIf
							Elseif !(SEF->EF_IMPRESS $ "CA")
								If cPaisLoc <> "BRA"		//Anular Cheque vinculado ao Pago.								
									//Verifica se o cheque deve ser anulado ou disponibilizado para uso
									If !lAutomato
										DEFINE MSDIALOG oDlg1 FROM	31,15 TO 180,350 TITLE STR0045 + " " + SEK->EK_ORDPAGO PIXEL OF oMainWnd //  "CANCELAMENTO DE CHEQUES"
										//@ 001, 002 TO 108, 268 LABEL  "" OF oDlg1  PIXEL // "Datos del Cheque"
										@ 005,005 SAY STR0095 PIXEL SIZE 160,160 Of oDlg1
										@ 025,005 SAY OemToAnsi(STR0056)+ ": " + SEK->EK_NUM PIXEL SIZE 160,160 Of oDlg1
										@ 045,005 RADIO oRadio VAR nRadio ITEMS STR0096,STR0097 SIZE 150,150 PIXEL OF oDlg1 //"Inutilizar","Disponibilizar para Uso"
										DEFINE SBUTTON FROM 047,120 TYPE 1 ENABLE OF oDlg1 ACTION (oDlg1:End(),oDlg1:End() )
										nRadio := 1
										ACTIVATE MSDIALOG oDlg1 CENTERED
									Else
										If FindFunction("GetParAuto")
											aRetAuto	:= GetParAuto("FINA086TestCase")
											If ValType(aRetAuto) == "A" .and. Len(aRetAuto) > 0 
												nRadio 		:= aRetAuto[1]
											EndIf
										Endif
									EndIf
									RecLock("SEF",.F.)
									//If nRadio == 0

									//EndIf
									If nRadio == 1 //Se anula o cheque
										SEF->EF_STATUS := "05"
									Else  //Se disponibiliza para uso
										SEF->EF_STATUS	:=	"00"
										SEF->EF_BENEF		:=	""
										SEF->EF_VENCTO	:=	Ctod("")
										SEF->EF_DATA		:=	Ctod("")
										SEF->EF_DATAPAG	:=	Ctod("")
										SEF->EF_HIST 		:=	""
										SEF->EF_REFTIP 	:=	""
										SEF->EF_LIBER 		:=	"S"
										SEF->EF_FORNECE	:=	""
										SEF->EF_LOJA		:=	""
										SEF->EF_LA     	:=	""
										SEF->EF_SEQUENC	:=	""
										SEF->EF_PARCELA	:=	""
										SEF->EF_TITULO  	:=	""
										SEF->EF_TIPO    	:=	"CH"
										SEF->EF_IMPRESS   :=	""
										SEF->EF_VALOR		:=	0
									EndIf
									MsUnLock()
									//Registrar Historico do Cheque (Folha de cheque cancelada por satisfação do correntista)
									DbSelectArea("FRF")
									cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
									RecLock("FRF",.T.)
									FRF->FRF_FILIAL	:= xFilial("FRF")
									FRF->FRF_BANCO	:= SEF->EF_BANCO
									FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
									FRF->FRF_CONTA	:= SEF->EF_CONTA
									FRF->FRF_NUM		:= SEF->EF_NUM
									FRF->FRF_PREFIX	:= SEF->EF_PREFIXO
									FRF->FRF_CART		:= "P"
									FRF->FRF_DATPAG	:= dDataBase
									FRF->FRF_MOTIVO	:= "20"
									FRF->FRF_DESCRI	:= "CHEQUE ANULADO"
									FRF->FRF_SEQ		:= cSeqFRF
									FRF->(MsUnLock())
									ConfirmSX8()
								Else
									RecLock("SEF",.F.)
									SEF->(dbDelete())
									MsUnLock()
								EndIf
								If Alltrim(UPPER(SEF->EF_ORIGEM)) $ "FINA085A|FINA095" .AND. cPaisLoc <> "BOL"
									Exit
								EndIf
								//Valida si el cheque fue emitido
								If cPaisLoc == "BOL" .AND. SE2->E2_SALDO <> 0
									Exit
								EndIf
							Endif

							// ATUALIZAR SALDO BANCARIO QDO CHEQUE ESTEJA LIBERADO
							If ( SEF->EF_VALOR != 0 .And. SEF->EF_LIBER != "N" ).And. !lPgtoElt
								AtuSalBco( SEF->EF_BANCO,SEF->EF_AGENCIA,SEF->EF_CONTA,SEF->EF_VENCTO,SEF->EF_VALOR,"+")
							Endif

							// DELETAR REGISTRO DO CHEQUE NO SE5 QDO EXISTIR
							dbSelectArea( "SE5" )
							If cPaisLoc == "BOL"
								dbSetOrder(3)
								//E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)
								MsSeek(xFilial("SE5")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+PadR(SEF->EF_NUM,TamSX3("E5_NUMERO")[1])+SEF->EF_PARCELA+SEF->EF_TIPO,.T.)
							Else
								dbSetOrder( 1 ) //E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
								SE5->( dbSeek(xFilial("SE5")+DtoS(SEF->EF_DATA)+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_NUM,.T.) )
							EndIf
							While ( SE5->(!Eof()) .And.;
							Iif(cPaisLoc<>"BOL",SE5->E5_DATA == SEF->EF_DATA,.T.)	.And.;
							SE5->E5_BANCO		== SEF->EF_BANCO		.And.;
							SE5->E5_AGENCIA	== SEF->EF_AGENCIA	.And.;
							SE5->E5_CONTA		== SEF->EF_CONTA		.And.;
							Iif(cPaisLoc<>"BOL", AllTrim(SE5->E5_NUMCHEQ) == AllTrim(SEF->EF_NUM),AllTrim(SE5->E5_NUMERO) == AllTrim(SEF->EF_NUM)))

								If (cPaisLoc == "BRA")
									If ( AllTrim(SE5->E5_NUMCHEQ) == AllTrim(SEF->EF_NUM) .And.;
									!(SE5->E5_TIPODOC $ "VL/BA/CM/MT/DC/JR/TL/V2/D2/V2") .And.;
									SE5->E5_MOEDA $ "C1/C2/C3/C4/C5/  " )
										If SE5->E5_TIPODOC <>"PA"
											//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
											If AllTrim( SE5->E5_TABORI ) == "FK2" 

												If SE5->E5_TIPODOC $ "VL|BA"

													aAreaAnt := GetArea()
													oModelBx  := FWLoadModel("FINM020")						
													oModelBx:SetOperation( 4 ) //Alteração
													oModelBx:Activate()
													oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
													oSubFKA := oModelBx:GetModel( "FKADETAIL" )
													oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

													//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
													//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
													//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
													oModelBx:SetValue( "MASTER", "E5_OPERACAO", 3 )
													oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )

													If oModelBx:VldData()
														oModelBx:CommitData()
														oModelBx:DeActivate()
													Else
														lRetSE5 := .F.
														cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
														cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
														cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
														Help( ,,"M020VLDE3",,cLog, 1, 0 )

													Endif								
													RestArea(aAreaAnt)
												Else
													//Cancelo os registros de valores acessoriso (Multas, Juros etc)
													RecLock("SE5")
													dbDelete()
													MsUnLock()
												Endif

											Endif

										EndIf
									EndIf
								Else
									//+--------------------------------------------------------------+
									//¦ Desvincular o cheque da Ordem de Pago.                       ¦
									//+--------------------------------------------------------------+
									If cPaisLoc <> "BRA" 
										If SE5->E5_TIPODOC <> "PA"

											//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
											If AllTrim( SE5->E5_TABORI ) == "FK2" 

												If SE5->E5_TIPODOC $ "VL|BA"

													aAreaAnt := GetArea()
													oModelBx  := FWLoadModel("FINM020")						
													oModelBx:SetOperation( 4 ) //Alteração
													oModelBx:Activate()
													oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
													oSubFKA := oModelBx:GetModel( "FKADETAIL" )
													oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

													//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
													//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
													//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
													If cPaisLoc == "BOL"
														oModelBx:SetValue( "MASTER", "E5_OPERACAO",1)
													Else
														oModelBx:SetValue( "MASTER", "E5_OPERACAO", 3 )
													EndIf
													oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )

													If oModelBx:VldData()
														oModelBx:CommitData()
														oModelBx:DeActivate()
													Else
														lRet := .F.
														cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
														cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
														cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
														Help( ,,"M020VLDE3",,cLog, 1, 0 )

													Endif								
													RestArea(aAreaAnt)
												Else
													//Cancelo os registros de valores acessoriso (Multas, Juros etc)
													RecLock("SE5")
													dbDelete()
													MsUnLock()
												Endif

											Endif

										EndIf
										If cPaisLoc <> "BOL"
											dbSelectArea("SEF")
											RecLock("SEF",.F.)
											EF_STATUS := "05"	//Anulado
											MsUnLock()
										
											//Registrar o Histórico de Compensações/devoluções
											DbSelectArea("FRF")
											cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
											RecLock("FRF",.T.)
											FRF->FRF_FILIAL	:= xFilial("FRF")
											FRF->FRF_BANCO	:= SEF->EF_BANCO
											FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
											FRF->FRF_CONTA	:= SEF->EF_CONTA
											FRF->FRF_NUM	 	:= SEF->EF_NUM
											FRF->FRF_PREFIX	:= SEF->EF_PREFIXO
											FRF->FRF_CART	 	:= "P"
											FRF->FRF_DATPAG	:=	dDataBase
											FRF->FRF_MOTIVO	:= "20"
											FRF->FRF_DESCRI	:= "CHEQUE ANULADO"
											FRF->FRF_SEQ	 	:= cSeqFRF
											FRF->(MsUnLock())
											ConfirmSX8()
										EndIf
									EndIf
								EndIf
								SE5->(dbSkip())
							Enddo
							DbSelectarea("SEF")
						EndIf
					end if
				EndIf
				SEF->(dbSkip())
			Enddo
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xAtuaChqTer        BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Borrar los registros relacionados con el Cheque de Terceros¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
Uso       ¦ PAGO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function xAtuaChqTer()

	Local aArea 		:= GetArea()
	Local  aAreaSE5		:= {}

	Local aAreaAnt 		:= {}
	Local oModelBx		:= Nil
	Local oSubFKA		:= Nil
	Local lRet			:= .T.
	Local cLog			:= ""

	cAliasAnt	:=	ALIAS()
	nOrderAnt	:=	IndexOrd()

	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek(xFilial("SE1")+SEK->EK_ENTRCLI+SEK->EK_LOJCLI+SEK->EK_PREFIXO+;
	SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO,.F.)
	IF FOUND()
		RecLock("SE1",.F.)
		Replace E1_BAIXA     With CTOD("")
		Replace E1_SALDO     With (E1_SALDO + SEK->EK_VALOR)
		Replace E1_STATUS    WITH "A"
		Replace E1_ORDPAGO   WITH Space(tamsx3("E1_ORDPAGO")[1])
		If cpaisLoc == "ARG"
			Replace E1_FORNECE   WITH Space(tamsx3("E1_FORNECE")[1])
		EndIf
		If cpaisLoc == "ARG"
			Replace E1_LOJAFOR   WITH Space(tamsx3("E1_LOJAFOR")[1])
		EndIf                                                                                                                          v
		MsUnLock()
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
		AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		//Apaga registro ref. a baixa do Cheque no SE5
		aAreaSE5:= SE5->(GetArea())
		DbSelectArea("SE5")
		DbSetOrder(7)
		If DbSeek(xFilial("SE5")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_ENTRCLI+SEK->EK_LOJCLI)
			MsUnLock()

			//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
			If AllTrim( SE5->E5_TABORI ) == "FK2" 

				If SE5->E5_TIPODOC $ "VL|BA"

					aAreaAnt := GetArea()
					oModelBx  := FWLoadModel("FINM020")						
					oModelBx:SetOperation( 4 ) //Alteração
					oModelBx:Activate()
					oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
					oSubFKA := oModelBx:GetModel( "FKADETAIL" )
					oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

					//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
					//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
					//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
					oModelBx:SetValue( "MASTER", "E5_OPERACAO", 3 )
					oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )

					If oModelBx:VldData()
						oModelBx:CommitData()
						oModelBx:DeActivate()
					Else
						lRet := .F.
						cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
						Help( ,,"M020VLDE3",,cLog, 1, 0 )

					Endif								
					RestArea(aAreaAnt)
				Else
					//Cancelo os registros de valores acessoriso (Multas, Juros etc)
					RecLock("SE5")
					dbDelete()
					MsUnLock()
				Endif

			Endif

		EndIf
		SE5->(RestArea(aAreaSE5))
	Endif
	/*
	atualiza o controle de cheques e o historico de movimentos de cheques*/
	SEF->(DbSetOrder(1))
	If (SEF->(DbSeek(xFilial("SEF") + SEK->EK_BANCO + SEK->EK_AGENCIA + SEK->EK_CONTA + PadR(SEK->EK_NUM,TamSX3("EF_NUM")[1]))))
		RecLock("SEF",.F.)
		Replace SEF->EF_STATUS	With "01"
		Replace SEF->EF_ORDPAGO With Space(TamSX3("EF_ORDPAGO")[1])
		MsUnlock()
	Endif
	If cPaisLoc <> "BRA"
		FRF->(DbSetOrder(1))
		If (FRF->(DbSeek(xFilial("FRF") + SEK->EK_BANCO + SEK->EK_AGENCIA + SEK->EK_CONTA + SEK->EK_PREFIXO + PadR(SEK->EK_NUM,TamSX3("FRF_NUM")[1]))))
			RecLock("FRF",.F.)
			FRF->(DbDelete())
			FRF->(MsUnLock())
		Endif
	Endif
	RestArea(aArea)
	
Return()

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelSE2TX     Autor:  Totvs        		¦ Data ¦ 12.09.11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Excluir registros de Taxas relacionadas com as retencoes	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦  		                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function xDelSE2TX()

	Local aImposto := {}
	Local cPrefixo := CriaVar("E2_PREFIXO")
	Local nX		 := 0

	//Indica os codigos dos impostos usados nos prefixos - DEFAULT
	Do Case
		Case cPaisLoc == "ARG"
		aImposto := {"IVA","IIB","SUS","GAN","SLI","ISI"}
		Otherwise
		aImposto := {cPrefixo} //Exclui os impostos com prefixo em branco
	End Case

	DbSelectArea("SE2")
	SE2->(dbSetOrder(1))

	For nX := 1 to Len(aImposto)
		If SE2->(dbSeek(xFilial("SE2")+aImposto[nX]+PadR(SEK->EK_ORDPAGO,TamSX3("E2_NUM")[1],"")))
			Do While (xFilial("SE2") == SE2->E2_FILIAL .And. aImposto[nX] == SE2->E2_PREFIXO .And. AllTrim(SEK->EK_ORDPAGO) == AllTrim(SE2->E2_NUM))
				RecLock("SE2",.F.)
				SE2->(DbDelete())
				SE2->(MsUnLock())
				SE2->(DbSkip())
			EndDo
		EndIf
	Next nX
	
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xPsqSE2TX     Autor:  Totvs        		¦ Data ¦ 12.09.11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Pesquisar registros de Taxas Baixadas das retencoes	 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦  		                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function xPsqSE2TX()
	Local aAreaAtu	:= {}
	Local lRet := .F.
	
	aAreaAtu := GetArea()
	DbSelectArea("SE2")
	dBSetOrder(1)
	MsSeek(xFilial("SE2")+SEK->EK_TIPO+SEK->EK_ORDPAGO)
	If FOUND()
		Do While (xFilial("SE2")==SE2->E2_FILIAL.And.SEK->EK_TIPO==SE2->E2_PREFIXO.And.SEK->EK_ORDPAGO==SE2->E2_NUM)
			If SE2->E2_SALDO ==	0
				lRet := .T.
			EndIf
			DbSkip()
		EndDo
	Endif
	RestArea(aAreaAtu)
	
Return lRet

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelRG     Autor:  BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Borrar los registros relacionados con las retenciones.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
Uso       ¦ PAGO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function xDelRgPa()
	Local lEstorna		:= (GetNewPar("MV_DELRET","D") == "E" )
	Local cZona		:= ""
	Local aChave		:= {}
	Local aRet			:= {}
	Local nX			:= 0
	Local cFornec		:= ""
	Local cNum			:= ""
	Local cFilSE2		:= ""
	Local cNumOP
	Local cImp			:= ""
	Default lOPRotAut	:= .F.
	Private acerts		:= {}

	cNumOP		:= Iif( lOPRotAut, cNumOrdPg,	TRB->NUMERO 	 )
	cAliasAnt	:=ALIAS()
	nOrderAnt	:=IndexOrd()
	cFornec 	:= GetMV("MV_UNIAO",.T.,"FISCO")
	cFornec 	:= Padr(cFornec,TamSX3("A2_COD")[1])

	DbSelectArea("SE2")
	dBSetOrder(8)
	DbSeek(xFilial("SE2")+cNumOP)
	If FOUND()
		Do While (xFilial("SE2")==E2_FILIAL.And.cNumOP==E2_ORDPAGO)
			If !Alltrim(E2_TIPO) $ MVNOTAFIS .And. Alltrim(UPPER(SE2->E2_ORIGEM)) $ "FINA085A|FINA850"
				If 	cPaisLoc $ "DOM|COS" .And. !(AllTrim(SE2->E2_TIPO) $ MVPAGANT) //Exclusão dos Abatimentos de Impostos
					FRN->( DbSetOrder(2) )
					If 	FRN->( DbSeek( xFilial("FRN") + SE2->E2_NATUREZ ) )
						If 	!FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN->FRN_CODNAT) 	== 	xFilial('FRN') 	+ SE2->E2_NATUREZ
							FRM->( DbSetOrder(2) )
							FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
							If 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial('FRM') 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
								cFatGer :=  FRM->FRM_FATGER
								If 	SE2->E2_TIPO <> MVPAGANT .And. FRM->FRM_APLICA $ "1|2"
									nSinal	:=	IIf(E2_TIPO $ MVPAGANT,-1,1)
									aAdd(aRet, {SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TITPAI,SE2->E2_VALOR})
									SA2->(DbSetOrder(1))
									SA2->(DbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA))
									RecLock("SA2",.F.)
									SA2->A2_SALDUP := SA2->A2_SALDUP  - xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO) * nSinal
									SA2->A2_SALDUPM:= SA2->A2_SALDUPM - xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO) * nSinal
									MsUnLock()
									RecLock("SE2",.F.)
									DbDelete()
									MsUnLock()
									SE2->(dbSkip())
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					nSinal	:=	IIf(E2_TIPO $ MVPAGANT,-1,1)
					SA2->(DbSetOrder(1))
					If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2").And. SE2->E2_FORNECE <> cFornec
						SA2->(DbSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
					Else
						SA2->(DbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA))
					Endif
					RecLock("SA2",.F.)
					SA2->A2_SALDUP := SA2->A2_SALDUP  - xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO) * nSinal
					SA2->A2_SALDUPM:= SA2->A2_SALDUPM - xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO) * nSinal
					MsUnLock()
					RecLock("SE2",.F.)
					If Iif(cPaisLoc $ "PER|EQU",!xValOrd(cNumOP),.T.)
						DbDelete()
					EndIf
					MsUnLock()
				EndIf
			EndIf
			DbSkip()
		EndDo
	Endif
	/*
	Apaga os registros referentes a titulos de impostos/retencoes, se ainda houver.*/
	cFornec := GetMV("MV_UNIAO",.T.,"FISCO")
	cFornec := Padr(cFornec,TamSX3("A2_COD")[1])
	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(xFilial("SA2") + cFornec))
		cFilSE2 := xFilial("SE2")
		SE2->(DbSetOrder(6))
		cNum := Padr(cNumOP,TamSX3("E2_NUM")[1])
		If SE2->(DbSeek(cFilSE2 + cFornec + SA2->A2_LOJA + Space(Len(SE2->E2_PREFIXO)) + cNum))		//o prefixo sempre e deixado em branco (ver fina085a - f085titimp)
			While !(SE2->(Eof())) .And. (SE2->E2_FILIAL == cFilSE2) .And. (SE2->E2_FORNECE == cFornec) .And. (SE2->E2_LOJA == SA2->A2_LOJA) .And. (SE2->E2_NUM == cNum)
				RecLock("SE2",.F.)
				SE2->(DbDelete())
				SE2->(MsUnLock())
				SE2->(DbSkip())
			Enddo
		Endif
	Endif

	//Restauro os valores descontados das retenções de impostos
	If cPaisLoc $ "DOM|COS"
		If Len(aRet) > 0
			For nX := 1 to Len(aRet)
				If !Empty(aRet[nX][7])
					DbSelectArea("SE2")
					SE2->(dBSetOrder(1))
					cChave := xFilial("SE2")+AllTrim(aRet[nX][7])
				Else
					DbSelectArea("SE2")
					SE2->(dBSetOrder(6))
					cChave := xFilial("SE2")+aRet[nX][5]+aRet[nX][6]+aRet[nX][1]+aRet[nX][2]+aRet[nX][3]
				EndIf

				If SE2->(dbSeek(cChave))
					If Alltrim(SE2->E2_TIPO) $ MVNOTAFIS
						RecLock("SE2",.F.)
						SE2->E2_VALOR    += aRet[nX][8]
						SE2->E2_SALDO    += aRet[nX][8]
						SE2->E2_VLCRUZ   += aRet[nX][8]
						SE2->(MsUnlock())
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	If cPaisLoc <> "CHI" .Or. cPaisLoc <> "BRA" //Fernando Dourado 02/06/00
		DbSelectArea("SFE")
		dBsetOrder(2)
		DbSeek(xFilial("SFE")+PadR(cNumOP,TamSX3("FE_ORDPAGO")[1]))
		Do While (xFilial("SFE") == FE_FILIAL .And. AllTrim(cNumOP) == AllTrim(FE_ORDPAGO))
			IIF(cPaisLoc == "ARG", aAdd(aChave,{SFE->(FE_NFISCAL+FE_SERIE+FE_FORNECE+FE_LOJA),SFE->FE_TIPO,SFE->FE_ORDPAGO}), aAdd(aChave,SFE->(FE_NFISCAL+FE_SERIE+FE_FORNECE+FE_LOJA)))

			If cPaisLoc $ "ARG" .And. Empty(FE_DTESTOR) .And. lEstorna		// Gera um registro de estorno das retenções.

				// Atualiza o registro da retenção atual com a data do estorno
				RecLock("SFE",.F.)
				Replace FE_DTESTOR With dDatabase
				MsUnLock()

				If SFE->FE_TIPO == "G"
					cImp:="GANAN"
				ElseIf SFE->FE_TIPO == "B"
					cImp:="IB "
					cZona := SFE->FE_EST
				ElseIf SFE->FE_TIPO == "I"
					cImp:="IVA"
				ElseIf SFE->FE_TIPO == "S"
					cImp:="SU "
				ElseIf SFE->FE_TIPO == "L"
					cImp:="SI "
				ElseIf Alltrim(SFE->FE_TIPO) $ "Z|M"
					cImp:="SIS"
				EndIf

				nRecReg	:= SFE->(Recno())
				nValImp	:= SFE->FE_VALIMP		* (-1)
				nValBase	:= SFE->FE_VALBASE	* (-1)
				nValReten	:= SFE->FE_RETENC		* (-1)
				nValDeduc	:= SFE->FE_DEDUC		* (-1)
				nDtRetOrig	:= SFE->FE_EMISSAO
				nNroOrig	:= SFE->FE_NROCERT
				dDtEstor	:= dDatabase
				nRecInc	:= 0
				cNroCert	:=	nNroOrig
				If cImp == "GANAN" .And. nValReten = 0 .and. "NORET" $ cNroCert
					cNroCert := "NORET"
				Else
					cNroCert :=	GetCert(cImp+cZona,SFE->FE_FORNECE+SFE->FE_LOJA+cImp+cZona)
				Endif

				PmsCopyReg("SFE",nRecReg,{{"FE_EMISSAO",dDtEstor},{"FE_VALIMP",nValImp},{"FE_VALBASE",nValBase},{"FE_RETENC",nValReten},{"FE_DEDUC",nValDeduc},;
				{"FE_NROCERT",cNroCert},{"FE_DTRETOR",nDtRetOrig},{"FE_NRETORI",nNroOrig}},@nRecInc)

				cZona := "" // Atualiza a Zona Fiscal somente para Ingresos Brutos
			ElseIf !lEstorna  .And. !(cPaisLoc $ "DOM|COS")
				RecLock("SFE",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			DbSkip()
		EndDo
	Endif

	//Flag de cumulatividade de IVA
	If cPaisLoc == "ARG"

		DbSelectArea("SF1")
		SF1->(dBsetOrder(1))
		For nX:= 1 to Len(aChave)
			If SF1->(DbSeek(xFilial("SF1")+aChave[nX][1])) .And. aChave[nX][2] == "I" .And. aChave[nX][3] == SF1->F1_ORDPAGO
				RecLock("SF1",.F.)
				SF1->F1_ORDPAGO := ""
				SF1->(MsUnlock())
			EndIf
		Next

		DbSelectArea("SF2")
		SF2->(dBsetOrder(1))
		For nX:= 1 to Len(aChave)
			If SF2->(DbSeek(xFilial("SF2")+aChave[nX][1])) .And. aChave[nX][2] == "I" .And. aChave[nX][3] == SF2->F2_ORDPAGO
				RecLock("SF2",.F.)
				SF2->F2_ORDPAGO := ""
				SF2->(MsUnlock())
			EndIf
		Next
	EndIf

	If cPaisLoc $ "EQU"
		DbSelectArea("SFE")
		SFE->(dBSetOrder(2)) //FE_FILIAL+FE_ORDPAGO+FE_TIPO 
		For nX:= 1 to Len(aChave)
			If SFE->(DbSeek(xFilial("SFE")+cNumOP))
				RecLock("SFE",.F.)
				SFE->FE_ORDPAGO := ""
				SFE->(MsUnlock())
			EndIf
		Next nX
	EndIf

	DbSelectArea(cAliasAnt)
	DbSetOrder(nOrderant)

Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xAtuaSE2 ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Actualizar los titulos del cuentas a Pagar.                ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
Uso       ¦ PAGO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function xAtuaSE2()

	Local nVlrMulta 	:= 0
	Local aAreaSalva 	:= GetArea()
	Local cFornece		:= ""
	Local cLoja		:= ""
	Local cFornImp		:= ""
	Local cLojImp		:= ""
	Local cTipo		:= " "
	Local nRegPag 		:= 0
	Local nValAba		:= 0
	Local nRegAba		:= 0
	Local lAtuSaldo 	:= .F.
	Local nVlrDac		:= 0
	Local aRecSE5		:={}
	Local cOrdPag		:= ""
	Local lBxTotal		:= .T.
	Local aRet			:= {}
	Local cChaveTit 	:= ""
	Local nRegSE2		:= 0
	Local nX			:= 0    
	Local nAcresc		:= 0
	Local aAreaAnt 		:= {}
	Local oModelBx		:= Nil
	Local oSubFKA		:= Nil
	Local lRet			:= .T.
	Local cLog			:= ""
	Local cFilOrig    := ""
	Local nPosSE2     := 0
	Local nPosFil     := 0
    Local lAutomato		:= IsBlind() // Tratamiento para scripts automatizados
    Local cFilSE2		:= xFilial("SE2")

	If Type("lOrdRet") == "U"
		lOrdRet := .F.
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se exite multa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE5")
	DbSetOrder(7)
	If DbSeek(xFilial("SE5")+SEK->(EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO))
		Do While xFilial("SE5")+SEK->(EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO) ==  E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO			
			If cPaisLoc == "MEX"
				nPosFil := Ascan(aFilOrig,{|x| x == SE5->E5_FILORIG })
				If nPosFil <= 0 .AND.  SE5->E5_ORDREC == SEK->EK_ORDPAGO
					AADD(aFilOrig , SE5->E5_FILORIG)
				EndIf
			EndIf		
			If SEK->EK_ORDPAGO == E5_ORDREC .And. E5_TIPODOC == "MT"
				nVlrMulta	:= E5_VLMOED2
			ElseIf E5_MOTBX == "DAC" .And. Empty(E5_SITUACA) .And.;
			SEK->EK_FORNECE+SEK->EK_LOJA == E5_CLIFOR+E5_LOJA
				nVlrDac 		:= E5_VLMOED2

				aAreaAnt := GetArea()
				oModelBx  := FWLoadModel("FINM020")						
				oModelBx:SetOperation( 4 ) //Alteração
				oModelBx:Activate()
				oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
				oSubFKA := oModelBx:GetModel( "FKADETAIL" )
				oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

				//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
				//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
				//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
				oModelBx:SetValue( "MASTER", "E5_OPERACAO", 1 )
				oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )

				If oModelBx:VldData()
					oModelBx:CommitData()
					oModelBx:DeActivate()
				Else
					lRet := .F.
					cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
					Help( ,,"M020VLDE3",,cLog, 1, 0 )
				Endif								
				RestArea(aAreaAnt)

			EndIf
			DbSkip()
		EndDo
	EndIf
	If ExistBlock("FA86ASE2")
		ExecBlock("FA86ASE2",.F.,.F.,{aRecSE5})
	EndIf

	DbSelectArea("SE2")
	DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If cPaisLoc == "MEX"
		For nX := 1 To Len(aFilOrig)
			cFilOrig = xFilial("SE2")
			If DbSeek(aFilOrig[nX]+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA,.F.)
				nPosSE2 := Ascan(aRecnoSE2,{|x| x == Recno() })
				If  nPosSE2 <= 0 .and. IIF(ALLTRIM(SE2->E2_TIPO) == "PA", ALLTRIM(SEK->EK_NUM)== ALLTRIM(SE2->E2_NUM),.T.)
					AADD(aRecnoSE2 , SE2->(Recno()))
					cFilOrig := aFilOrig[nX]
					SE2->(dbGoTop())
					Exit
				EndIf
			EndIf
		Next
	Else
		cFilOrig := xFilial("SE2")
	EndIf
	
	If Iif(cPaisLoc $ "PER|EQU" .And. lOrdRet,xSE2Ret(cFilOrig),DbSeek(cFilOrig+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA,.F.))
		RecLock("SE2",.F.)
		nRegPag	:= Recno()
		nSalvRec := nRegPag
		lAtuSaldo := IiF(E2_SALDO == 0,.T.,.F.)
		If E2_SDACRES < E2_ACRESC
			nAcresc:= E2_ACRESC - E2_SDACRES
			If nAcresc > ((SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) - (SEK->EK_JUROS + nVlrMulta))
				nAcresc:= ((SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) - (SEK->EK_JUROS + nVlrMulta))
			Endif
			Replace E2_SDACRES With E2_SDACRES + nAcresc
		Endif
		
		If cPaisLoc == "COL"
			If lOrdPDesc
				Replace E2_SALDO With E2_SALDO + ((SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) - (SEK->EK_JUROS + nVlrMulta)) - nAcresc - E2_DESCONT
			Else
				Replace E2_SALDO With E2_SALDO + ((SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) - (SEK->EK_JUROS + nVlrMulta)) - nAcresc
			EndIf
		ElseIf cPaisLoc == "ARG"
			Replace E2_SALDO With E2_SALDO + ((SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) - (SEK->EK_JUROS + nVlrMulta)) - nAcresc
		Else
			Replace E2_SALDO With E2_SALDO + ((SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) - (SEK->EK_JUROS + nVlrMulta)) - nAcresc - E2_DESCONT
		EndIf
		If E2_VALOR == E2_SALDO
			Replace E2_BAIXA With CTOD("")
			A055AtuDtBx("2",SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_BAIXA)
			lBxTotal := .T.
		Else
			lBxTotal := .F.
		Endif
		cOrdPag :=  SE2->E2_ORDPAGO
		If ALLTRIM(E2_ORDPAGO)<>ALLTRIM(E2_NUM) .AND. UPPER(E2_ORIGEM) <> "FINA085A"
			Replace E2_ORDPAGO  WITH SPACE((tamsx3("E2_ORDPAGO")[1]))
		EndIf
		If cPaisLoc == "COL"
			If lOrdPDesc
				Replace E2_DESCONT  WITH 0
			EndIf
		Else
			Replace E2_DESCONT  WITH 0
		EndIf
		Replace E2_JUROS    WITH 0
		Replace E2_MULTA    WITH 0
		Replace E2_VALLIQ	WITH 0
		If cPaisLoc == "COL" .And. lOrdPDesc
			Replace E2_SDDECRE	WITH E2_DECRESC
		EndIf
		MsUnLock()
		aAliasAtu:=GetArea()
		CancDifCam()
		RestArea(aAliasAtu)
		
		nSinal	:=	IIf(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT,-1,1)
		SA2->(DbSetOrder(1))
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
			SA2->(DbSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
		Else
			SA2->(DbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA))
		Endif
		RecLock("SA2",.F.)
		If cPaisLoc == "ARG"
			If (SEK->EK_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
				SA2->A2_SALDUP  := SA2->A2_SALDUP  - xMoeda(SEK->EK_VALOR,Val(SEK->EK_MOEDA),1,SEK->EK_EMISSAO)
				SA2->A2_SALDUPM := SA2->A2_SALDUPM - xMoeda(SEK->EK_VALOR,Val(SEK->EK_MOEDA),Val(GetMv("MV_MCUSTO")),SEK->EK_EMISSAO)
			Else
				SA2->A2_SALDUP  := SA2->A2_SALDUP  + xMoeda((SEK->(EK_VALOR + EK_DESCONT) + nVlrDac) - (SEK->EK_JUROS + nVlrMulta),Val(SEK->EK_MOEDA),1,SEK->EK_EMISSAO)
				SA2->A2_SALDUPM := SA2->A2_SALDUPM + xMoeda((SEK->(EK_VALOR + EK_DESCONT) + nVlrDac) - (SEK->EK_JUROS + nVlrMulta),Val(SEK->EK_MOEDA),Val(GetMv("MV_MCUSTO")),SEK->EK_EMISSAO)
			EndIf
		Else
			SA2->A2_SALDUP := SA2->A2_SALDUP  + xMoeda(SEK->EK_VALOR,Val(SEK->EK_MOEDA),1,SEK->EK_EMISSAO)
			SA2->A2_SALDUPM:= SA2->A2_SALDUPM + xMoeda(SEK->EK_VALOR,Val(SEK->EK_MOEDA),Val(GetMv("MV_MCUSTO")),SEK->EK_EMISSAO)
		EndIf
		MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se h  abatimentos para voltar a carteira  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitAnt := (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
		cFornece:= SE2->E2_FORNECE
		cLoja 	:= SE2->E2_LOJA
		cFornImp:= PadR(GetMV("MV_UNIAO"),TamSx3("A2_COD")[1])
		cLojImp := PadR("00",TamSx3("A2_LOJA")[1])
		cTipo	:=	SE2->E2_TIPO

		If SE2->(dbSeek(cTitAnt+cTipo+cFornece+cLoja))
			While !SE2->(Eof()) .and. cTitAnt+cTipo+cFornece+cLoja == (SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
				RecLock("SE2",.F.)
				Replace E2_ORDPAGO	WITH " "
				MsUnLock()
				If 	cPaisLoc $ "DOM|COS"  //Exclusão dos Abatimentos de Impostos
					FRN->( DbSetOrder(2) )
					If 	FRN->( DbSeek( xFilial("FRN") + SE2->E2_NATUREZ ) )
						While !FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN_CODNAT) 	== 	xFilial('FRN') 	+ SE2->E2_NATUREZ
							FRM->( DbSetOrder(2) )
							FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
							If 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial('FRM') 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
								If 	FRM->FRM_FATGER  ==	"2"  .And. cTipo <> MVPAGANT .And. FRM->FRM_APLICA $ "1|2"
									DbSelectArea("SFE")
									dBsetOrder(2)
									DbSeek(xFilial("SFE")+PadR(cNumOP,TamSX3("FE_ORDPAGO")[1]))
									Do While (xFilial("SFE") == FE_FILIAL .And. AllTrim(cNumOP) == AllTrim(FE_ORDPAGO))
										If SFE->FE_SIGLA == FRM->FRM_SIGLA
											RecLock("SFE",.F.)
											DbDelete()
											MsUnLock()
										EndIf
										SFE->(dbskip() )
									EndDo

									If FRM->FRM_APLICA == "1"
										cChaveTit := cTitAnt+FRM->FRM_TPTIT+cFornImp+cLojImp
									Else
										cChaveTit := cTitAnt+FRM->FRM_TPABT+cFornece+cLoja
									EndIf

									nRegSE2 := SE2->(Recno())

									dbSelectArea("SE2")
									SE2->(dbSetOrder(1))
									If SE2->(dbSeek(cChaveTit))
										While !SE2->(Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) == cChaveTit
											If AllTrim(cNumOP) == AllTrim(SE2->E2_ORDPAGO)
												If FRM->FRM_APLICA == "1"
													aAdd(aRet, {SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TITPAI,SE2->E2_VALOR})
												EndIf
												RecLock("SE2",.F.)
												SE2->(DbDelete())
												SE2->(MsUnLock())
											EndIf
											SE2->(dbSkip())
										EndDo
									EndIf

									SE2->(dbGoTo(nRegSE2))

								EndIf
							EndIf
							FRN->(dbSkip())
						EndDo
					EndIf

					SE2->(dbSkip())
					Loop

				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizar o valor do abatimento          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF SE2->E2_SALDO + SE2->E2_SDACRES == 0
					nValAba := SE2->E2_VALOR
					nRegAba := SE2->(Recno())
					SE2->(DbGoTo(nRegPag))
					If lAtuSaldo
						RecLock("SE2",.F.)
						If 	cPaisLoc $ "ARG|DOM|COS|EQU"
							Replace SE2->E2_SALDO With SE2->E2_SALDO
						Else
							Replace SE2->E2_SALDO With SE2->E2_SALDO + nValAba
						EndIf
						Replace SE2->E2_BAIXA With cTOd(Spac(08))
						MsUnLock()
					EndIf
					SE2->(DbGoTo(nRegAba))
				EndIf
				
				//Verificar si se cancela o no la preorden de Pago
				If cPaisLoc == "ARG" .And. !Empty(cOrdPag)
					DbSelectArea("FJK")
					FJK->(DbSetOrder(2)) //FJK_FILIAL+FJK_ORDPAG+FJK_PREOP
					If  FJK->(DbSeek(xFilial("FJK")+cOrdPag))
						If  nMsgOK == 0
						  If !lAutomato 
							IF  !(Msgyesno("¿Desea cancelar la Preorden de Pago vinculada a la Orden de pago "+Alltrim(cOrdPag)+"?"))
								lCancOP := .F.
							Endif
						  Else
						    If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
						         aRetAuto  := GetParAuto("FINA086TESTCASE")
						         lCancOP   := aRetAuto[1]
						    Endif
						  EndIf
						Endif
						nMsgOK++				
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Volta titulo para carteira 			    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Reclock("SE2",.F.)
				SE2->E2_BAIXA	:= CTOD("")
				If lBxTotal
					SE2->E2_SALDO	:= SE2->E2_VALOR
				EndIf
				If cPaisLoc == "COL"
					If lOrdPDesc
						SE2->E2_DESCONT	:= 0
					EndIf
				Else
					SE2->E2_DESCONT	:= 0
				EndIf
				SE2->E2_JUROS	:= 0
				SE2->E2_MULTA	:= 0
				SE2->E2_CORREC	:= 0
				SE2->E2_VARURV	:= 0
				SE2->E2_LOTE	:= Space(Len(E2_LOTE))
				SE2->E2_VALLIQ	:= 0
				SE2->E2_NUMBCO	:= Space(Len(SE2->E2_NUMBCO))
				If cPaisLoc == "CHI"
					SE2->E2_OTRGA    := 0
					SE2->E2_CAMBIO   := 0
					SE2->E2_IMPSUBS  := 0
				EndIf
				If cPaisLoc == "COL" .And. lOrdPDesc
					SE2->E2_SDDECRE := SE2->E2_DECRESC
				EndIf
				If	cPaisLoc == "ARG" .And. !lCancOP //Pre-orden NO se cancela (FJK/FJL)
					SE2->E2_MOVIMEN	:= CTOD("//")
					SE2->E2_PREOK		:= "S"
					SE2->E2_VLBXPAR	:= SE2->E2_VALOR
					SE2->E2_PREOP		:= ObtPreOrd(cOrdPag)
				Endif
				SE2->(MsUnLock())
				SE2->(dbSkip())
			Enddo
		Endif
		If cPaisLoc $ "DOM|COS"
			//Restauro os valores descontados das retenções de impostos
			If Len(aRet) > 0
				For nX := 1 to Len(aRet)
					If !Empty(aRet[nX][7])
						DbSelectArea("SE2")
						SE2->(dBSetOrder(1))
						cChave := xFilial("SE2")+AllTrim(aRet[nX][7])
					Else
						DbSelectArea("SE2")
						SE2->(dBSetOrder(6))
						cChave := xFilial("SE2")+aRet[nX][5]+aRet[nX][6]+aRet[nX][1]+aRet[nX][2]+aRet[nX][3]
					EndIf

					If SE2->(dbSeek(cChave))
						If Alltrim(SE2->E2_TIPO) $ MVNOTAFIS
							RecLock("SE2",.F.)
							SE2->E2_VALOR    += aRet[nX][8]
							SE2->E2_SALDO    += aRet[nX][8]
							SE2->E2_VLCRUZ   += aRet[nX][8]
							SE2->(MsUnlock())
						EndIf
					EndIf
				Next nX
			EndIf
			aRet := {}
		EndIf
	Endif
	//Restaurar saldo de retenciones cuando se anula orden de pago relacionada al pago de las retenciones
	If cPaisLoc $ "EQU"
		DbSetOrder(6) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If SE2->( MsSeek(cFilSE2+SEK->EK_FORNECE+SEK->EK_LOJA+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA) )
			While !SE2->( Eof() ) .And. SE2->( cFilSE2+SEK->EK_FORNECE+SEK->EK_LOJA+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA ) == cFilSE2+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
				If	(Alltrim(SE2->E2_TIPO) $ "IV-|IR-") .And. SEK->EK_ORDPAGO == SE2->E2_ORDPAGO
					RecLock("SE2",.F.)
					Replace SE2->E2_ORDPAGO WITH ""
					Replace SE2->E2_SALDO WITH SE2->E2_VALOR
					Replace SE2->E2_BAIXA WITH CTOD("")
					MsUnLock()
				EndIf
				SE2->(DBSkip())
			EndDo
		EndIf
	EndIf
	If cPaisLoc $ "DOM|COS"
		SE2->( DbSetOrder(8) ) // E2_FILIAL+E2_ORDPAGO
		If 	SE2->( DbSeek( xFilial("SE2") + cOrdPag ) )
			While 	!SE2->( Eof() ) .And. SE2->(xFilial("SE2") + cOrdPag) 	== 	xFilial('SE2') 	+ SE2->E2_ORDPAGO
				If	SE2->E2_TIPO $ "CH "
					RecLock("SE2",.F.)
					DbDelete()
					MsUnLock()
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aAreaSalva)

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelSE5  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Borrar los movimientos en SE5.                             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
Uso       ¦ PAGO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function xDelSE5(nHdlPrv,cLotecom,cArquivo,aFlagCTB)

	Local aRecSE5		:={}
	Local cTipoDoc 		:= "ES"
	Local dDataMov		:= dDatabase
	Local cHist
	Local lFindITF		:= .T.
	Local cTpDcDel		:= "" //Movimentos com E5_TIPODOC que podem ser excluídos no cancelamento da OP
	Local cNumOP            

	Local aAreaAnt 		:= {}
	Local oModelBx		:= Nil
	Local oSubFKA		:= Nil
	Local lRet			:= .T.
	Local cLog			:= ""

	/*
	ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	ºMV_ESTORDT: Parametro, que permite decidir si el saldo del Mov. de Rev.º
	ºde la OP debe registrarse con fecha del dia en el que fue generado el  º
	ºMov. de la OP o en la Fecha de la Rev. de la Orden de Pago. S=Si/N=No  º
	ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	*/
	Local cMovRevDta	:= SuperGetMV('MV_ESTORDT', .F., 'N')

	Default lOPRotAut	:= .F.

	cNumOP		:= Iif( lOPRotAut, cNumOrdPg,	TRB->NUMERO 	 )
	cAliasAnt	:=ALIAS()
	nOrderAnt	:=IndexOrd()
	
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	SA6->(DbGoTop())
	DbSelectArea("SE5")
	dBSetOrder(8) //E5_FILIAL+E5_ORDREC+E5_SERREC
	DbSeek(xFilial("SE5")+cNumOP)
	lExec:=.F.
	lExec1:=.F.
	Do While (xFilial("SE5")==E5_FILIAL.And.cNumOP==E5_ORDREC)
		nRecReg :=SE5->(Recno())
		cHist:= STR0084 + SE5->E5_ORDREC
		If E5_RECPAG=="P"

			If cPaisLoc == "MEX"
				cTpDcDel := "JR/MT/OG/DC"
				RecLock("SE5")
				SE5->E5_SITUACA := "C"
				SE5->(MsUnLock())
			Else
				cTpDcDel := "BA/JR/MT/OG/DC"
			Endif

			If !(SE5->E5_TIPODOC $ cTpDcDel)
			 If SA6->(DbSeek(xFilial("SA6") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA))
				If cMovRevDta == "S" //Si el Paramatro MV_ESTORDT = Si
					AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dDataBase, SE5->E5_VALOR, "+")
				Else
					AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DATA, SE5->E5_VALOR, "+")
				EndIf
				If lFindITF .And. FinProcITF( SE5->( Recno() ),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
					FinProcITF( SE5->( Recno() ),5,, .T.,{ nHdlPrv, "573", "", "PAGO019", cLotecom } , @aFlagCTB )
				EndIf
				If cPaisLoc<>"BRA"	.And. (GetNewPar("MV_ESTORDP","N") == "S" )
					nRecInc:=0
					If cMovRevDta == "S" //Si el Paramatro MV_ESTORDT = Si
						aFldsRever := {{"E5_RECPAG", "R"}, {"E5_TIPODOC", cTipoDoc}, {"E5_HISTOR", cHist}, {"E5_DATA", dDataBase}, {"E5_DTDIGIT", dDataBase}, {"E5_VENCTO", dDataBase}, {"E5_DTDISPO", dDataBase}}
						PmsCopyReg("SE5", nRecReg, aFldsRever, @nRecInc)
					Else
						PmsCopyReg("SE5",nRecReg,{{"E5_RECPAG","R"},{"E5_TIPODOC",cTipoDoc},{"E5_HISTOR",cHist},{"E5_DATA",dDataMov}},@nRecInc)
					EndIf
				Else

					//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
					If AllTrim( SE5->E5_TABORI ) $ "FK2|FK5" 

						If SE5->E5_TIPODOC $ "VL|BA"
							aAreaAnt := GetArea()
							If !lExec
								oModelBx  := FWLoadModel("FINM020")		
								If cPaisLoc$"ARG|BOL|CHI|PAR|URU"
									oModelBx:GetModel( 'FKADETAIL' ):SetLoadFilter(," FKA_IDPROC !='' ")
								EndIf				
								oModelBx:SetOperation( 4 ) //Alteração
								
								oModelBx:Activate()
								oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
								oSubFKA := oModelBx:GetModel( "FKADETAIL" )
								oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

								//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
								//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
								//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
								oModelBx:SetValue( "MASTER", "E5_OPERACAO", 1 )
								oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )
											
								If oModelBx:VldData()
						       		oModelBx:CommitData()
						       		oModelBx:DeActivate()
						       		lExec:=.T.
								Else
									lRet := .F.
							    	cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
							    	cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
							    	cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
									Help( ,,"M020VLDE3",,cLog, 1, 0 )
								Endif							
							Else
								RecLock("SE5",.F.) // Cancela o registro, pois o parametro MV_ESTORDP == N
								SE5->E5_SITUACA:="C"
								SE5->(MsUnlock()) 
							Endif									
							RestArea(aAreaAnt)
						Else
							//Cancelo os registros de valores acessoriso (Multas, Juros etc)
							RecLock("SE5")
							dbDelete()
							MsUnLock()
						Endif

					ElseIf cPaisLoc $ "COL|PER|BOL|CHI|EQU|URU|PAR" .and. Empty(SE5->E5_TABORI)
						RecLock("SE5",.F.)
						SE5->E5_SITUACA:="C"
						SE5->(MsUnlock())                  				
					Endif

				EndIf
			Endif
				Aadd(aRecSE5,SE5->(Recno()))
			Else

				//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
				If AllTrim( SE5->E5_TABORI ) == "FK2" 

					If SE5->E5_TIPODOC $ "VL|BA"
						aAreaAnt := GetArea()
						If !lExec1
							oModelBx  := FWLoadModel("FINM020")	
							If cPaisLoc$"ARG|BOL|CHI|PAR|URU"
								oModelBx:GetModel( 'FKADETAIL' ):SetLoadFilter(," FKA_IDPROC !='' ")
							EndIf						
							oModelBx:SetOperation( 4 ) //Alteração
							oModelBx:Activate()
							oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
							oSubFKA := oModelBx:GetModel( "FKADETAIL" )
							oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

							//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
							//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
							//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
							oModelBx:SetValue( "MASTER", "E5_OPERACAO", 3 )
							oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )
										
							If oModelBx:VldData()
					       		oModelBx:CommitData()
					       		oModelBx:DeActivate()
					       		lExec1:=.T.
							Else
								lRet := .F.
						    	cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
						    	cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
						    	cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
								Help( ,,"M020VLDE3",,cLog, 1, 0 )
							Endif
						Else
							RecLock("SE5")
							dbDelete()
							MsUnLock()
						Endif									
						RestArea(aAreaAnt)
					Else
						//Cancelo os registros de valores acessoriso (Multas, Juros etc)
						RecLock("SE5")
						dbDelete()
						MsUnLock()
					Endif

				ElseIf cPaisLoc $ "COL|PER|CHI|BOL|EQU|URU|PAR" .and. Empty(SE5->E5_TABORI)
					//Cancelo os registros de valores acessoriso (Multas, Juros etc)
					RecLock("SE5")
					dbDelete()
					MsUnLock()
				Endif
			EndIf
		Endif
		DbSkip()
	EndDo
	If ExistBlock("FA86ASE5")
		ExecBlock("FA86ASE5",.F.,.F.,{aRecSE5})
	EndIf

	DbSelectArea(cAliasAnt)
	DbSetOrder(nOrderant)

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ PAGO019  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ CANCELACION DE LA ORDEN DE PAGO                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pago018                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  DATA    ¦ BOPS ¦                  ALTERACAO                          ¦¦¦
¦¦+----------+------+-----------------------------------------------------¦¦¦
¦¦¦04.06.99	 ¦Melhor¦Considerar titulos tipo AB- .                        ¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function fa086Visual(cAlias)

	Local aAux, nA, nZ := 0
	Local cFornece, cLoja, cOrdPago,cOrdem
	Local aSx3Box 	:= {}
	Local nSavRec	:= 0
	Private aHeader :={}, aCols := {}

	nSavRec := SEK->(Recno())

	SEK->(DbSetOrder(1))
	SEK->(DbSeek(xFilial("SEK")+TRB->NUMERO))

	If cPaisLoc == "PTG"
		aSx3Box 	:= RetSx3Box( Posicione("SX3", 2, "EK_TPDESP", "X3CBox()" ),,, 1 )
	Endif
	If Empty(cAlias)
		nDecs    := MsDecimais(Val(SEK->EK_MOEDA))
		mv_par06 := Val(SEK->EK_MOEDA)
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("EK_VALOR")
	Aadd(aHeader,{OemToAnsi(STR0024),"DETALLE"   ,"@!",15,0,".T.",X3_usado,"C","SEK"}) //"Tipo de Valor"
	Aadd(aHeader,{OemToAnsi(STR0025),"EK_PREFIXO","@!",3 ,0,".T.",X3_usado,"C","SEK"}) //"Serie"
	Aadd(aHeader,{OemToAnsi(STR0026),"EK_NUM"    ,"@!",12,0,".T.",X3_usado,"C","SEK"}) //"Numero"
	Aadd(aHeader,{OemToAnsi(STR0027),"EK_PARCELA","@!",1 ,0,".T.",X3_usado,"C","SEK"}) //"Cuota"
	Aadd(aHeader,{OemToAnsi(STR0028),"EK_TIPO"   ,"@!",3 ,0,".T.",X3_usado,"C","SEK"}) //"Tipo"
	Aadd(aHeader,{OemToAnsi(STR0029+GetMv("MV_MOEDA"+Str(mv_par06,1))),"EK_VLMOED1",PesqPict("SEK","EK_VALOR",17,nDecs),17 ,nDecs,".t.",X3_usado,"N","SEK"}) //"Valor ($)"
	Aadd(aHeader,{OemToAnsi(STR0030),"EK_DTDIGIT",""  , 8,0,".T.",X3_usado,"D","SEK"}) //"Emision"
	Aadd(aHeader,{OemToAnsi(STR0031),"EK_ENTRCLI","@!",6 ,0,".T.",X3_usado,"C","SEK"})   //"Cliente"
	Aadd(aHeader,{OemToAnsi(STR0032),"EK_LOJCLI" ,"@!",2 ,0,".T.",X3_usado,"C","SEK"}) //"Sucursal"
	Aadd(aHeader,{OemToAnsi(STR0079),"EK_FORNECE","@!",6 ,0,".T.",X3_usado,"C","SEK"}) //"Fornecedor"
	Aadd(aHeader,{OemToAnsi(STR0080),"EK_LOJA"   ,"@!",2 ,0,".T.",X3_usado,"C","SEK"}) //"Sucursal"

	DbSelectArea("SEK")
	DbSetOrder(1)

	If !Empty(cAlias)
		cFornece	:=	TRB->PROVEEDOR
		cLoja		:=	TRB->SUCURSAL
		cOrdPago	:=	TRB->NUMERO
		DbSeek(xFilial("SEK")+TRB->NUMERO)
	Else
		cFornece	:=	SEK->EK_FORNEPG
		cLoja		:=	SEK->EK_LOJAPG
		cOrdPago := SEK->EK_ORDPAGO
	EndIf

	cOrdem  	:=	SEK->EK_ORDPAGO

	Do While(xFilial("SEK")==EK_FILIAL.And.cOrdem ==EK_ORDPAGO)
		nZ		:=nZ+1
		aAux	:={}
		Aadd(aAux,Space(20))
		For nA:=2  to Len(aHeader)
			Aadd(aAux,Criavar(aHeader[nA,2]))
		Next

		Aadd(aAux,.F.)
		Aadd(aCols,aAux)

		Do Case
			Case SEK->EK_TIPODOC=="CP"
			aCols[nZ][1]:= OemToAnsi(STR0033) // "Cheque Propio"
			Case SEK->EK_TIPODOC=="CT"
			If cPaisLoc $ "PTG|CHI"
				aCols[nZ][1]:= OemToAnsi(STR0081)
			Else
				aCols[nZ][1]:= OemToAnsi(STR0034) // "Cheque Terceros"
			Endif
			Case SEK->EK_TIPODOC=="TB"
			If Alltrim(SEK->EK_TIPO)=="PA"
				aCols[nZ][1]:= OemToAnsi(STR0035) // "PA Aplicado"
			Elseif Alltrim(SEK->EK_TIPO)=="AB-"
				aCols[nZ][1]:= OemToAnsi(STR0036) // "Reduccion"
			Else
				aCols[nZ][1]:= OemToAnsi(STR0037) // "Titulo Pagado"
			Endif
			Case SEK->EK_TIPODOC=="PA"
			aCols[nZ][1]:= OemToAnsi(STR0038) // "Pago Anticipado"
			Case SEK->EK_TIPODOC=="DE"
			If (nPosDesp	:=	Ascan(aSx3Box,{|x| x[2]== SEK->EK_TPDESP})) >0
				aCols[nZ][1]:= aSx3Box[nPosDesp,3]
			Else
				aCols[nZ][1]:= STR0083 //"Despesa"
			Endif
			Case SEK->EK_TIPODOC=="RG"
			//"Ret. Ganancias","Ret. I.V.A.","Ret. Ing. Brutos"
			If cPaisLoc == "ARG"
				aCols[nZ][1]:=Iif(SEK->EK_TIPO=="GN-",OemToAnsi(STR0039),IIf(EK_TIPO=="IV-",;
				OemToAnsi(STR0040),OemToAnsi(STR0041)))
			ElseIf cPaisLoc $ "URU|BOL|PER"
				aCols[nZ][1]:=	OemToAnsi(STR0007)
			ElseIf cPaisLoc == "PTG"
				aCols[nZ][1]:=Iif(EK_TIPO=="IV-",OemToAnsi(STR0040),OemToAnsi(STR0082))
			ElseIf cPaisLoc == "ANG"
				aCols[nZ][1]:= STR0091
			Endif
		EndCase
		aCols[nZ][2]:=SEK->EK_PREFIXO
		aCols[nZ][3]:=SEK->EK_NUM
		aCols[nZ][4]:=SEK->EK_PARCELA
		aCols[nZ][5]:=SEK->EK_TIPO
		aCols[nZ][6]:=IIf(MV_par06==1,SEK->EK_VLMOED1,xMoeda(SEK->EK_VALOR,Max(Val(SEK->EK_MOEDA),1),mv_par06,SEK->EK_DTDIGIT,nDecs+1))
		aCols[nZ][7]:=SEK->EK_DTDIGIT
		aCols[nZ][8]:=SEK->EK_ENTRCLI
		aCols[nZ][9]:=SEK->EK_LOJCLI
		aCols[nZ][10]:=SEK->EK_FORNECE
		aCols[nZ][11]:=SEK->EK_LOJA

		SEK->(DbSkip()	)
	EndDo

	@ 65,0  To 280,600 Dialog oDialog Title OemToAnsi(STR0014)  // "Visualizar"
	@  1,4  To 30,297
	@ 33,4  To 105,297 MULTILINE
	@  7,6  Say OemToAnsi(STR0042) + cOrdPAgo SIZE 200,10  //"Detalles de la Orden de Pago Nro  "
	@ 19,6  Say OemToAnsi(STR0043) + cFornece SIZE 80,10  //"Proveedor : "
	@ 19,75 Say OemToAnsi(STR0044) + cLoja SIZE 60,10     //"Sucursal :"
	Activate Dialog oDialog CENTERED

	If !Empty(cAlias)
		DbSelectArea("TRB")
	EndIf

	If nSavRec > 0
		SEK->(dbGoTo(nSavRec))
	EndIf

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ PAGO021  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ AxPesqui para cancelacion de orden de pago.                ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pago018                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function fa086Buscar()
	Local cCampo := Space(TamSx3("EK_ORDPAGO")[1]), aOrd :={}

	Aadd(aOrd, OemToAnsi(STR0045) ) // "Orden de Pago"
	@ 5, 5 TO 68, 400 DIALOG oDlg TITLE OemToAnsi(STR0046) //"Buscar"
	@ 1.6 ,002	COMBOBOX OemToAnsi(STR0045) ITEMS aOrd  SIZE 165,44
	@ 15  ,002 	GET cCampo SIZE 165,10
	@ 1.6 ,170	BMPBUTTON TYPE 1 ACTION Buscar(cCampo)
	@ 14.6,170 	BMPBUTTON TYPE 2 ACTION (oDlg:End())
	ACTIVATE DIALOG oDlg CENTERED

RETURN

//---
Static Function Buscar(cCampo)
	DbSelectArea("TRB")
	TRB->(DbSeek(Alltrim(cCampo),.T.))
	Close(oDlg)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a086ChkSEF ³ Autor ³ Lucas               ³ Data ³ 16.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui os cheques não compensados vinculados a Orden de    ³±±
±±³          ³ Pago.		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a086chkSEF()
	Local lRet			:=	.T.
	Local nOrder,nTamPago,cNumero,cPref,cParc
	Local cCampo
	Local cNumOP
	Default lOPRotAut	:= .F.

	cNumOP	:= Iif( lOPRotAut, cNumOrdPg, TRB->NUMERO )

	DbSelectArea("SEK")
	DbSetOrder(1)
	If dbSeek(xFilial("SEK")+cNumOP)

		While ! Eof() .and. EK_FILIAL == xFilial("SEK") .and. EK_ORDPAGO == cNumOP

			If EK_TIPODOC == "CP" .And. EK_TIPO $ "CH |CA "

				If cPaisLoc <> "BRA"
					//Verificar Status do Cheque para verificar se é possível cancelar a Ordem de Pago.
					SEF->(dbOrderNickName("EQU09"))
					If SEF->(dbSeek(xFilial("SEF")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+SEK->EK_ORDPAGO))
						While ! SEF->(Eof()) .and. SEF->EF_BANCO == SEK->EK_BANCO ;
						.and. SEF->EF_AGENCIA == SEK->EK_AGENCIA ;
						.and. SEF->EF_CONTA == SEK->EK_CONTA ;
						.and. AllTrim(SEF->EF_TITULO) == AllTrim(SEK->EK_ORDPAGO)
							If SEF->EF_STATUS != "06" //Verifica se não é um cheque substituido
								//Anular Cheques
								A095Anular("SEF",SEF->(RECNO()),5)
							EndIf
							SEF->(dbSkip())
						End
					Endif
				Else
					dbSelectArea("SEF")
					dbSetOrder(1)

					If Trim(SEK->EK_TIPO)=="CA"
						nOrder:=Indexord()
						nTampago:=Tamsx3("EF_TITULO")[1]
						cNumero := Padr(SEK->EK_ORDPAGO,nTampago)
						cPref:=Space(Tamsx3("EF_PREFIXO")[1])
						cParc:=Space(Tamsx3("EF_PARCELA")[1])

						dbSetOrder(3)
						dbSeek(xFilial("SEF")+ cPref +cNumero+cParc+"ORP")
						dbSetOrder(nOrder)
						cCampo:="SEF->EF_TITULO"
					Else
						cNumero := SEK->EK_NUM
						DbSeek(xFilial("SEF")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+cNumero,.t.)
						cCampo:="SEF->EF_NUM"
					EndIf
					If Found()
						While xFilial("SEF")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA;
						+alltrim(cNumero)==SEF->EF_FILIAL+SEF->EF_BANCO+SEF->EF_AGENCIA+;
						SEF->EF_CONTA+Alltrim(&(cCampo)) .And. !EOF()

							If SEF->EF_IMPRESS == "S" .and. GetMV("MV_CANPOCH")
								If lOPRotAut
									lRet	:= .T.
								Else
									lRet	:=	MsgYesNo(Oemtoansi(STR0056)+SEF->EF_NUM+OemtoAnsi(STR0057)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+; //"El cheque "###" ya fue impreso."
									OemToAnsi(STR0058)+ Chr(13)+Chr(10)+; //"Confirme para continuar... "
									OemToAnsi(STR0059)) //"(Si el cheque fue de numeracion automatica, sera eliminado del mov. Bancario)"
								EndIf
							ElseIf SEF->EF_IMPRESS == "S" .and. !(GetMV("MV_CANPOCH"))
								lRet	:= .F.
							EndIf
							SEF->(DBSKIP())
						End
					EndIf
				EndIf
			ElseIf ALLTRIM(EK_TIPO) == "PA"
				If  ALLTRIM(EK_TIPODOC)=="PA"
					lRet := a086chkPA(.F.)
					Exit
				Else
					lRet := a086chkPA(.T.)
				EndIf
			Endif
			DbSelectArea("SEK")
			DbsKip()
		Enddo
	EndIf

	If ExistBlock("A086SEF")
		lRet :=	ExecBlock("A086SEF",.F.,.F.,lRet)
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³Fa086CanPaºAuthor ³Alexandre Silva     º Date ³  04-12-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o cancelamento parcial da ordem de pago.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ Fina086 (Localizacao Chile)                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a086ChkPA(lEstorno)

	Local lRet  := .T.
	Local aAreaSalva := GetArea()

	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA)
		If lEstorno
			RecLock("SE2",.F.)
			Replace E2_ORDPAGO With  SEK->EK_NUM
			MsUnLock()
		Else
			If E2_VALOR <> E2_SALDO
				If lOPRotAut
					cTxtRotAut += STR0061 + cNumOrdPg
				Else
					MsgAlert( STR0119 )
				EndIf
				lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSalva)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³Fa086CanPaºAuthor ³Alexandre Silva     º Date ³  04-12-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o cancelamento parcial da ordem de pago.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ Fina086 (Localizacao Chile)                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fa086CanPa(lOpcao)

	Local nOpca			:= 	0
	Local nCampo		:= 	0
	Local aOrdDados	:= 	{}
	Local aCabSEK   	:= 	{}
	Local aOrdProc	:=	{}
	Local aCoordExt 	:= 	{09,0,42,80}
	Local aTamSK		:= 	{5,50}
	Local oDlgMark	:= 	Nil
	Local bBline		:=	  {||}
	Local nPosChave	:=		0
	Private cBanco	:= 	Criavar("A6_COD")
	Private cAgencia	:= 	Criavar("A6_AGENCIA")
	Private cConta	:= 	Criavar("A6_NUMCON")
	Private cNatureza:= 	Criavar("E5_NATUREZ")
	Private cVlrProc	:= 	Space(60)
	Private	cCmbSel:= 	""
	Private aLinSEK	:= 	Nil
	Private aCampos	:=	{}//Campos que serao mostrados no browse.
	Private oOk		:=	LoadBitMap(GetResources(),"LBTIK")
	Private oNo		:=	LoadBitMap(GetResources(),"LBNO")
	Private oBrowse	:=	Nil
	Private bSEL		:= {|u| If( PCount() == 0, cCmbSel, cCmbSel := u ) }////Usado na mudancao do DropDown
	Private lEstorna	:=	lOpcao //Controla o tipo de operacao, Cancelamento da Baixa ou Estorno do cancelamento da baixa
	Private cMsgEst	:=	Iif(lEstorna,STR0075,"") //" Estorno do "

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³   Verifica se existe lista de campos para cliente     ³
	³   no Profile do usuario, para que possa resgata-la    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	aCampos	:=	{"nSEL","EK_FORNECE","EK_LOJA","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_VALOR","EK_TIPO","EK_SEQ","EK_TIPODOC","EK_CANPARC"}//Campos que serao mostrados no browse.
	nPosChave	:=	Ascan(aCampos,{|x| x=="EK_CANPARC"})
	aOrdDados	:= 	Load086Pag(aCampos)
	aCabSEK   	:= 	aOrdDados[1]
	aLinSEK	:=	aOrdDados[2]
	bBline		:=	&("{|| "+aOrdDados[3]+"}")

	For nCampo = 1 To Len(aCampos)
		If aCampos[nCampo] # "nSEL"
			Aadd(aOrdProc,aCabSEK[nCampo])
		EndIf
	Next nCampos

	If Len(aLinSEK) > 0 //Verifica se existem dados para serem mostrados.\\

		ASort(aLinSEK,,,{|x,y| x[6] < y[6]})

		DEFINE MSDIALOG oDlgMark TITLE cMsgEst+ STR0065 FROM aCoordExt[1],aCoordExt[2] TO aCoordExt[3],aCoordExt[4] //"Cancelamento parcial da ordem de pago"

		If lEstorna
			@ 045,012 Say STR0066 //"Selecione os documentos para estorno do cancelamento e cofirme."
			@ 053,012 Say STR0071 //"Seran seleccionados automaticamente todos los titulos cancelados en la misma operacion"
		Else
			@ 045,012 Say STR0076 //"Instrucoes:"
			@ 053,012 Say STR0067 //"Selecione os documentos para cancelamento e cofirme."
		Endif

		@ 067,010 To 094,306 //Desenho da caixa

		If !lEstorna
			@ 069,012 Say STR0068 //"Caixa para credito"
			@ 080,012 Get cBanco 	Picture "@S03" F3 "SA6" Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.T.)
			@ 080,040 Say ""
			@ 080,040 Get cAgencia	Picture "@S06"  Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.T.)
			@ 080,072 Say ""
			@ 080,070 Get cConta	Picture "@S15"  Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.T.)
			@ 069,105 Say STR0077 //"Modalidade"
			@ 080,105 Get cNatureza 	Picture "@S10"  F3 'SED' Valid ExistCpo('SED')
			@ 081,136 Say STR0078 //"Ordem"

			TComboBox():New(076,158,bSEL,aOrdProc,050,044,oDlgMark,,{||FA086aOrd(aCabSEK)}, , , ,.T.,,,,)

			@ 080,216 Say STR0070 //"Pesq."
			@ 079,237 Get cVlrProc Picture "@S36" Valid FA086aOrd(aCabSEK)

		Else
			@ 081,012 Say STR0078 //"Ordem"

			TComboBox():New(076,29,bSEL,aOrdProc,050,044,oDlgMark,,{||FA086aOrd(aCabSEK)}, , , ,.T.,,,,)

			@ 080,082 Say STR0070 //"Pesq."
			@ 080,110 Get cVlrProc Picture "@S36" Valid FA086aOrd(aCabSEK)
		Endif

		oBrowse := TwBrowse():New(103,010,297,132,,aCabSEK,aTamSK, oDlgMark,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oBrowse:lColDrag	:= .T.
		oBrowse:nFreeze	:= 1
		oBrowse:SetArray(aLinSEK)

		If !lEstorna
			oBrowse:bLDblClick 	:= { || aLinSEK[oBrowse:nAt,1] *= -1 }
		Else
			oBrowse:bLDblClick 	:= { || aEval(aLinSEK,{|x| IIf(x[nPosChave]==aLinSEK[oBrowse:nAt][nPosChave],x[1]*=-1,Nil),oBrowse:Refresh()}) }
		Endif

		oBrowse:bLine			:= bBline

		ACTIVATE MSDIALOG oDlgMark CENTERED ON INIT	EnchoiceBar(oDlgMark,;
		{ || nOpca:=1,If(aScan(aLinSEK,{|x| x[1]== 1})>0,If(lEstorna,FaEstCanc(),FaCanPar()) .And. oDlgMark:End(),Aviso("Atenção","Nenhum título selecionado para baixa",{"OK"}))},;
		{ || nOpca:=0,oDlgMark:End()},,/*aButtons*/)
	Else
		MsgInfo(STR0069) //"Nao foram localizados titulos baixados para cancelamento."
	EndIf

Return nOpca

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Load086PagºAutor  ³Alexandre Silva     º Date ³  04-12-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a montagem da matriz de cabecalho e carrega os registrosº±±
±±º          ³que foram selecionados pelo usuario atraves dos parametros. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fina086                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Load086Pag(aCampos)

	Local cPict		:= ""
	Local cbLinha	:= ""//Propriedade bLine da TwBrowse
	Local aCabTit 	:= {}
	Local aLinDet	:= {}
	Local nX		:= 0
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Montagem do cabecalho.                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	For nX := 1 To Len(aCampos)
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Se comecar com EK, Usar a RetTile.        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If Subs(aCampos[nX],1,3) == "EK_"
			AADD(aCabTit,Rtrim(RetTitle(aCampos[nX])))
			cPict	:= PesqPict("SEK",aCampos[nX])
			cbLinha += ", Transform(aLinSEK[oBrowse:nAT][" + AllTrim(Str(nX))+ "], '" + cPict + "')"
		Else
			Do Case
				Case aCampos[nX]== "nSEL"
				AADD(aCabTit," ")
				cbLinha	:= "{IIF(aLinSEK[oBrowse:nAt,1] > 0,oOk,oNo)"
			EndCase
		EndIf
	Next nX

	cbLinha += "}"

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Popularizando as linhas do Browse.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	SEK->(dbSetOrder(1))
	SEK->(dbSeek(xFilial("SEK")+TRB->NUMERO+"TB"))
	Do While ! SEK->(Eof()) .And. xFilial("SEK")+TRB->NUMERO == SEK->EK_FILIAL+SEK->EK_ORDPAGO;
	.And. Alltrim(SEK->EK_TIPODOC) == "TB"
	If ((lEstorna .And. !Empty(SEK->EK_CANPARC)) .Or. (!lEstorna .And. Empty(SEK->EK_CANPARC)))/*;
	 	.And. Alltrim(SEK->EK_TIPO) <> "PA"*/
			AADD(aLinDet,{})
			For nX := 1 To Len(aCampos)
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Se comecar com EK, Usar a RetTile.        ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If Subs(aCampos[nX],1,3) == "EK_"
					AADD(aLinDet[Len(aLinDet)],&("SEK->"+aCampos[nX]))
				Else
					Do Case
						Case aCampos[nX]== "nSEL"
						AADD(aLinDet[Len(aLinDet)],-1)
					EndCase
				EndIf
			Next nX
		EndIf
		SEK->(dbskip())
	EndDo

Return {aCabTit,aLinDet,cbLinha}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA086aOrd ºAutor  ³Alexandre Silva     º Data ³  10/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ordena linhas do grid de acordo com a combo.        		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FA086aOrd(aCabSEK)

	Local cTipo		:= ""
	Local nColSel	:= Ascan(aCabSEK,cCmbSel)//Coluna Selecionada
	Local nItemLoc	:= 0

	ASort(aLinSEK,,,{|x,y| x[nColSel] < y[nColSel]})

	If Len(aLinSEK) > 0 .And. ! Empty(cVlrProc)
		cTipo := ValType(aLinSEK[1,nColSel])
		Do Case
			Case cTipo=="D"
			xValProc := Ctod(cVlrProc)
			Case cTipo=="N"
			xValProc := Val(cVlrProc)
			Case cTipo$"C|U"
			xValProc := Alltrim(cVlrProc)
		EndCase

		If cTipo == "D" .Or. cTipo == "N"
			nItemLoc := Ascan(aLinSEK,{|aVal|,aVal[nColSel] == xValProc})
		Else
			nItemLoc := Ascan(aLinSEK,{|aVal|, Alltrim(aVal[nColSel]) == xValProc})
		EndIf
	EndIf

	If nItemLoc <> 0
		oBrowse:nAt	:= nItemLoc
	EndIf

	oBrowse:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FaCanPar  ºAutor  ³Alexandre Silva    º Data ³ 10/12/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o cancelamento dos titulos marcados.                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FaCanPar()

	Local nHdlPrv 		:= 	0
	Local nJuros		:= 	0
	Local nMulta		:= 	0
	Local nCorrec		:= 	0
	Local nDescont		:= 	0
	Local nAcresc   	:= 	0
	Local nDecresc  	:= 	0
	Local nTotAbat		:= 	0
	Local nTotAdto		:= 	0
	Local nTxMoeda		:= 	0
	Local nI 			:= 	0
	Local nRecSe5   	:= 	0
	Local nDifCambio	:= 	0
	Local nImpSubst		:= 	0
	Local nOtrga		:= 	0
	Local nAtraso		:= 	0
	Local nTit			:= 	0
	Local nLocTit		:=	0
	Local nLocCol		:=	0
	Local nValor		:=	0
	Local nSalvRec		:= 	0
	Local nValPgto		:= 	0
	Local nValSalSE5	:= 	0
	Local nPosSeq		:=	Ascan(aCampos,"EK_SEQ")
	Local cNumTit		:=	""
	Local cArquivo		:=	""
	Local cParcela		:=	""
	Local cNum			:=	""
	Local cPrefixo		:=	""
	Local cFornece		:=	""
	Local cLoja  		:= 	""
	Local cTipo			:=	""
	Local cTitAnt		:=	""
	Local cDescrMo		:= ""
	Local cSequencia	:= ""
	Local cParcCanc 	:= ""
	Local cTipoDoc		:= "CM/CX/DC/MT/JR/BA/VL"+iiF(cPaisloc == "CHI","IS/","")
	Local cHist086   	:=	STR0072 //"Canc. da baixa (Canc. Parcial da O.P.)."
	Local dBaixa		:=	SE2->E2_BAIXA
	Local dDataAnt		:=	dDataBase
	Local lBaixaAbat	:= .F.
	Local lPadrao571 	:= VerPadrao('571')
	Local lPadrao563 	:= VerPadrao('563')
	Local cChave		:=	""
	Local cChaveBx		:=	""
	Local lBxCEC 		:= .F.//Verificador de existencia de baixa por compensacao entre carteiras
	Local lLanca		:= .T.	//(mv_par07==1)
	Local aMotBx		:= ReadMotBx()
	Local aAreaSA6		:=	SA6->(GetArea())
	Local aAreaSE2		:=	SE2->(GetArea())
	Local aBaixa 		:= 	{}
	Local aLocSE2		:=	{"EK_PREFIXO","EK_NUM","EK_PARCELA","EK_TIPO","EK_FORNECE","EK_LOJA"}//Campos p/ loc. do titulo no SE2
	Local aLocSEK		:=	{"EK_TIPODOC","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_TIPO","EK_SEQ"}
	Local nTotalLanc	:=	0
	Local cLote			:=	""
	Local cAlias		:= ""
	Local cKeyImp		:= ""
	Local lLanctOk		:= .F.
	//***Reestruturação do SE5***
	Local aAreaAnt 		:= {}
	Local oModelBx		:= Nil
	Local oSubFKA		:= Nil
	Local lRet			:= .T.
	Local cLog			:= ""
	Local oModelMov		:= FWLoadModel("FINM030")
	Local oSubFKAMV
	Local oSubFK5MV
	Local cCamposE5		:= ""
	Local cPadrao571	:= ""
	//***Reestruturação do SE5***
	Private aBaixaSE5 	:= 	{}

	//+--------------------------------------------------------------+
	//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
	//+--------------------------------------------------------------+
	If lLanca
		dbSelectArea("SX5")
		dbSeek(xFilial()+"09FIN")
		cLote:=IIF(Found(),Trim(X5DESCRI()),"FIN")

		nHdlPrv := HeadProva( cLote,;
		"PAGO019",;
		Substr( cUsuario, 7, 6 ),;
		@cArquivo )

		If nHdlPrv <= 0
			Help(" ",1,"A100NOPROV")
		EndIf
	Endif

	Begin Transaction

		For nTit := 1 to Len(aLinSEK)
			For nLocTit := 1 to Len(aLocSE2)
				nLocCol := Ascan(aCampos,{|aValor|Alltrim(aValor) == aLocSE2[nLocTit] })                    // Result: 2
				cNumTit	+= aLinSEK[nTit,nLocCol]
			Next nLocTit

			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			If aLinSEK[nTit,1] == 1 .And. SE2->(dbSeek(xFilial("SE2")+cNumTit))

				nSalvRec 	:= 	SE2->(Recno())
				nValPgto 	:= 	SE2->E2_VALLIQ
				cParcela 	:=	SE2->E2_PARCELA
				cNum	   	:=	SE2->E2_NUM
				cPrefixo 	:=	SE2->E2_PREFIXO
				cFornece 	:=	SE2->E2_FORNECE
				cLoja  	    :=	SE2->E2_LOJA
				cTipo	   	:=	SE2->E2_TIPO

				Do Case
					Case Empty(SE2->E2_BAIXA)
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Verifica se o Titulo nao sofreu baixa 								 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					Help(" ",1,"TITNAOXADO")
					Return .T.
					Case !DtMovFin(,,"2")
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Verifica se data do movimento n„o ‚ menor que data limite de ³
					³ movimentacao no financeiro    								 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					Return .T.
					Case  SE2->E2_TIPO $ MVABATIM
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Verifica se ‚ um registro Principal								     ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					Help(" ",1,"NAOPRINCIP")
					Return .T.
				EndCase

				nTotAbat := SumAbatPag( cPrefixo, cNum, cParcela, cFornece, SE2->E2_MOEDA,"V",dBaixa,cLoja )

				If cPaisLoc == "CHI"
					nOtrga     := SE2->E2_OTRGA
					nDifCambio := SE2->E2_CAMBIO
					nImpSubst  := SE2->E2_IMPSUBS
				EndIf

				nAcresc  := SE2->E2_ACRESC
				nDecresc := SE2->E2_DECRESC

				SE2->(dbGoTo(nSalvRec))

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Procura pelas baixas deste titulo                                     ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				aBaixa   := Sel080Baixa( "VL /BA /CP /",cPrefixo, cNum, cParcela,cTipo,@nTotAdto,@lBaixaAbat,cFornece,cLoja,@lBxCEC)
				nOpBaixa	:= Ascan(aBaixaSE5,{|aVal| Alltrim(aVal[9]) == aLinSEK[nTit,nPosSeq]})

				If Len(aBaixa) == 0
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Procura pelas compensa‡”es										   	 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					Do Case
						Case lBxCEC  //Compensacao entre carteiras
						Help(" ",1,"BX_CEC",,STR0073,1,0)   //"Este titulo possui apenas baixas por Compensacao entre Carteiras. Cancele a compensacao para cancelar a baixa."
						Case SE5->(dbSeek(xFilial("SE5")+"CP"+cPrefixo+cNum+cParcela+cTipo))
						Help(" ",1,"TITULOADT")
						Case SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. !lBaixaAbat
						Help(" ",1,"TITULOADT")
						Case Empty( SE2 -> E2_FATURA )
						Help(" ",1,"BAIXTITINC")
						Otherwise
						Help(" ",1,"TITFATURAD")
					EndCase
					Return .T.
				EndIf

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Pega os Valores da Baixa Escolhida       									  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				dBaixa		:= aBaixaSE5[nOpBaixa,07]
				cSequencia 	:= aBaixaSE5[nOpBaixa,09]
				cChaveBx    := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+cFornece+cLoja+cSequencia
				cChave      := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(dBaixa)+cFornece+cLoja+cSequencia
				cParcCanc 	:= aBaixaSE5[nOpBaixa,03]

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Verifica se data do cancelamento ‚ menor que a data da baixa ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If dBaixa > dDataBase
					Help(" ",1,"DTBAIXA")
					Return .T.
				Endif

				dbSelectArea("SE5")
				SE5->(dbSetOrder(2))

				For nI := 1 to Len( cTipoDoc) Step 3

					If SE5->( dbSeek(xFilial("SE5")+Substr(cTipoDoc,nI,2)+cChave) )
						Do Case
							Case substr(cTipoDoc,nI,2 ) $ "CM/CX"
							If cPaisloc <> "CHI"
								nCorrec		:= SE5->E5_VALOR
							Else
								nDifcambio	:= SE5->E5_VALOR
							EndIf
							Case substr(cTipoDoc,nI,2 ) $ "DC"
							nDescont:= SE5->E5_VALOR
							Case substr(cTipoDoc,nI,2 ) $ "MT"
							nMulta	:= SE5->E5_VALOR
							Case substr(cTipoDoc,nI,2 ) $ "JR"
							If cPaisloc <> "CHI"
								nJuros	:= SE5->E5_VALOR
							Else
								nOtrga	:= SE5->E5_VALOR
							EndIf
							Case substr(cTipoDoc,nI,2 ) $ "BA/VL"
							If !Empty(SE5->E5_BANCO)
								SA6->(DbSetOrder(1))
								SA6->(dbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
								nValPgto := xMoeda(SE5->E5_VALOR,Max(IIf(Type("SA6->A6_MOEDAP")=="U",SA6->A6_MOEDA,SA6->A6_MOEDAP),1),1,SE5->E5_DATA)
							Else
								nValPgto := SE5->E5_VALOR
							Endif
							cHist070 	:= SE5->E5_HISTOR
							cMotBx   	:= SE5->E5_MOTBX
							cNumBor  	:= SubStr(SE5->E5_DOCUMEN,1,6)
							cLoteFin 	:= SE5->E5_LOTE
							nRecSe5  	:= SE5->(Recno())
							nValEstrang := SE5->E5_VLMOED2
							Case substr(cTipoDoc,nI,2 ) $ "IS" 	//Localizacao Chile
							nImpsubst	:= SE5->E5_VALOR
						EndCase
					EndIf
				Next

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Verifica se foi utilizada taxa contratada para moeda > 1          ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				dbGoTo(nRecSe5)		//volta para o registro principal

				If SE2->E2_MOEDA > 1 .and. Round(NoRound(xMoeda(nValPgto,1,SE2->E2_MOEDA,dBaixa,3),3),2) != SE5->E5_VLMOED2
					nTxMoeda := Noround((SE5->E5_VALOR / SE5->E5_VLMOED2),5)
				Else
					nTxMoeda := RecMoeda(dBaixa,SE2->E2_MOEDA)
				Endif
				If nTxMoeda	== 0
					nTxMoeda := 1
				EndIf

				//Estornar o Cheque vinculados
				dbSelectArea("SEF")

				If cPaisLoc <> "BRA"		//Anula o Cheque vinculado ao PA
					SEF->(dbOrderNickName("EQU09"))
					If SEF->(dbSeek(xFilial("SEF")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+SEK->EK_ORDPAGO))
						While ! SEF->(Eof()) .and. SEF->EF_BANCO == SEK->EK_BANCO ;
						.and. SEF->EF_AGENCIA == SEK->EK_AGENCIA ;
						.and. SEF->EF_CONTA == SEK->EK_CONTA ;
						.and. AllTrim(SEF->EF_TITULO) == AllTrim(SEK->EK_ORDPAGO)

							RecLock("SEF",.F.)
							EF_STATUS := "06"
							MsUnLock()

							SEF->(dbSkip())
						End
					EndIf
				Else
					dbSetOrder(1)
				EndIf

				nValPadrao		:= nValPgto-(nJuros+nMulta-nDescont)
				nSalDup			:= SE2->E2_SALDO-nValPadrao

				dbSelectArea("SE5")
				dbGoTo(nRecSe5)					//volta para o registro principal

				nI 			:=  Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(cMotBx) })
				cDescrMo	:= if( nI > 0,Substr(aMotBx[nI],07,10),"" )

				SA2->( dbseek( xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
				dbSelectArea("SE2")
				cTitulo	   	:= SE2->E2_PREFIXO + " " + SE2->E2_NUM

				SED->( dbSeek(xFilial("SED")+SE2->E2_NATUREZ) )
				SA6->( DbSetOrder(1) )
				SA6->( DbSeek(xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA) ) )

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Gravar valores no SE2										     ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				Reclock( "SE2" )
				SE2->E2_VALLIQ := nValPgto
				If cPaisloc <> "CHI"
					SE2->E2_JUROS	:= nJuros
					SE2->E2_CORREC := nCorrec
				Else
					SE2->E2_JUROS	:= nOtrga + nImpsubst
					SE2->E2_CORREC	:= nDifCambio
					SE2->E2_OTRGA	:=	nOtrga
					SE2->E2_CAMBIO	:=	nDifCambio
					SE2->E2_IMPSUBS	:=	nImpSubst
				EndIf
				SE2->E2_MULTA		:= nMulta
				SE2->E2_DESCONT 	:= nDescont

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Gera lancamento contabil de estorno 								 ³
				³Verifica se contabiliza on-line o estorno da baixa	   			 ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cNumTit := xFilial("SEK")+TRB->NUMERO
				For nLocTit := 1 to Len(aLocSEK)
					nLocCol	:= Ascan(aCampos,{|aValor|Alltrim(aValor) == aLocSEK[nLocTit] })
					cNumTit	+= aLinSEK[nTit,nLocCol]
				Next nLocTit

				SEK->(dbSetOrder(1))
				SEK->(dbSeek(cNumTit))



				Do Case
					Case SEK->EK_TIPODOC == "TB" .And. SEK->EK_TIPO $ MV_CPNEG+"/"+MVPAGANT .And. VerPadrao("5BG")
					lPadrao571 := .T.
					cPadrao571 := "5BG"
					Case SEK->EK_TIPODOC == "TB" .And. !(SEK->EK_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. VerPadrao("5BH")
					lPadrao571 := .T.
					cPadrao571 := "5BH"
					Case SEK->EK_TIPODOC == "PA" .And. VerPadrao("5BI")
					lPadrao571 := .T.
					cPadrao571 := "5BI"
					Case SEK->EK_TIPODOC == "CP" .And. SEK->EK_TIPO $ cDebMed .And. VerPadrao("5BJ")
					lPadrao571 := .T.
					cPadrao571 := "5BJ"
					Case SEK->EK_TIPODOC == "CP" .And. SEK->EK_TIPO $ cDebInm .And. VerPadrao("5BK")
					lPadrao571 := .T.
					cPadrao571 := "5BK"
					Case SEK->EK_TIPODOC == "CT" .And. VerPadrao("5BL")
					lPadrao571 := .T.
					cPadrao571 := "5BL"
					Case SEK->EK_TIPODOC == "RG" .And. VerPadrao("5BM")
					lPadrao571 := .T.
					cPadrao571 := "5BM"
					Otherwise
					lPadrao571 := VerPadrao("571")
					cPadrao571 := "571"
				EndCase

				If lPadrao571 .And. lLanca .And. SEK->EK_LA = 'S'
					Do Case
						Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
						cAlias := "SF2"
						Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
						cAlias := "SF2"
						Otherwise
						cAlias := "SF1"
					EndCase
					cKeyImp := 	xFilial(cAlias)	+;
					SEK->EK_NUM		+;
					SEK->EK_PREFIXO	+;
					SEK->EK_FORNECE	+;
					SEK->EK_LOJA
					If ( cAlias == "SF1" )
						cKeyImp += SE1->E1_TIPO
					Endif
					Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")

					nTotalLanc += DetProva( nHdlPrv,;
					cPadrao571,;
					"FINA086",;
					cLote,;
					/*nLinha*/,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )

				Endif
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Volta titulo para carteira 										         ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				SA6->( DbSetOrder(1) )
				SA6->( MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta) )
				Reclock( "SE2" )
				nTotAbat := Iif(SE2->E2_SALDO!=0,0,nTotAbat)
				dDataAnt := Iif(nOpBaixa==Len(aBaixa),Iif(Len(aBaixa)==1,CtoD(""),	aBaixaSE5[Len(aBaixa)-1][7]),E2_BAIXA)
				If SE2->E2_MOEDA == Max(SA6->A6_MOEDA,1)
					nValor 		:= SE2->E2_SALDO+(nValPgto-nJuros-nMulta+nDescont+nTotAbat)
					If cPaisLoc == "CHI" .AND. alltrim(SE5->E5_TIPO) $ "NCP|NDI|PA|"
						nValSalSE5	-=	nValPgto
					Else
						nValSalSE5	+=	nValPgto
					EndIf
				Else
					nValor 		:= SE2->E2_SALDO+((nValPgto-nJuros-nMulta+nDescont+nTotAbat) / NoRound(nTxMoeda,5))
					If cPaisLoc == "CHI" .AND. alltrim(SE5->E5_TIPO) $ "NCP|NDI|PA|"
						nValSalSE5	-=	(nValPgto / NoRound(nTxMoeda,5))
					Else
						nValSalSE5	+=	(nValPgto / NoRound(nTxMoeda,5))
					EndIf
				Endif
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Volta valor original do titulo se cancelamento final das baixas ³
				³ e n„o houverem compensa‡oes.                                   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If Len(aBaixa) == 1 .and. nTotAdto == 0 .and. !SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
					nValor := SE2->E2_VALOR
				Endif
				SE2->E2_SALDO 	:=	Iif( nValor < 0 , 0 , nValor )
				SE2->E2_BAIXA 	:=	Iif( Str(E2_SALDO,17,2) == Str(E2_VALOR,17,2),CtoD(""), E2_BAIXA )
				SE2->E2_DESCONT	:= 0
				SE2->E2_MULTA	:= 0
				SE2->E2_JUROS	:= 0
				SE2->E2_CORREC	:= 0
				SE2->E2_VALLIQ	:= 0
				SE2->E2_LOTE 	:= Space(Len(SE2->E2_LOTE))
				SE2->E2_IMPCHEQ	:= " "
				SE2->E2_NUMBCO	:= Space(Len(SE2->E2_NUMBCO))
				If cPaisLoc == "CHI"
					SE2->E2_OTRGA    := 0
					SE2->E2_CAMBIO   := 0
					SE2->E2_IMPSUBS  := 0
				EndIf
				//Caso exista solicitacao de NCP eh necessario atualizar o campo CU_DTBAIXA...
				A055AtuDtBx("2",SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_BAIXA)
				If (SE2->E2_SALDO == SE2->E2_VALOR .AND. EMPTY(SE2->E2_BAIXA))
					SE2->E2_SDACRES := SE2->E2_ACRESC
					SE2->E2_SDDECRE := SE2->E2_DECRESC
				EndIf
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Verifica se h  abatimentos para voltar a carteira			     ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If SE2->(dbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA))
					cTitAnt := (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
					While !SE2->(Eof()) .and. cTitAnt == (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
						If (!SE2->E2_TIPO $ MVABATIM) .Or. (SE2->E2_FORNECE+SE2->E2_LOJA != cFornece+cLoja)
							SE2->(dbSkip())
							Loop
						EndIf
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³Volta titulo para carteira 				³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						Reclock("SE2")
						SE2->E2_BAIXA	:= dDataAnt
						SE2->E2_SALDO	:= E2_VALOR
						SE2->E2_DESCONT	:= 0
						SE2->E2_JUROS	:= 0
						SE2->E2_MULTA	:= 0
						SE2->E2_CORREC	:= 0
						SE2->E2_VARURV	:= 0
						SE2->E2_VALLIQ	:= 0
						SE2->E2_LOTE	:= Space(Len(E2_LOTE))
						SE2->E2_NUMBCO	:= Space(Len(SE2->E2_NUMBCO))
						If cPaisLoc == "CHI"
							SE2->E2_OTRGA    := 0
							SE2->E2_CAMBIO   := 0
							SE2->E2_IMPSUBS  := 0
						EndIf
						SE2->(dbSkip())
					Enddo
				Endif

				SE2->(dbGoTo(nSalvRec))

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Localiza na movimenta‡„o banc ria, os registros referentes a baixa³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				dbSelectArea("SE5")
				dbSetOrder(7)

				SE5->( dbSeek(xFilial("SE5")+cChaveBx ))
				While !Eof() .And. xFilial("SE5")+cChaveBx == &(IndexKey())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cancela as baixas gerando um lancamento de estorno no SE5         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
					If cPaisLoc == "CHI"  .And. ExistBlock("FA86CAPR")
						nRec := ExecBlock("FA86CAPR",.F.,.F.,{})  //PE modificacion sobre SE5 en anulacion de orden parcial
					Else
						If AllTrim( SE5->E5_TABORI ) == "FK2" 
	
							If SE5->E5_TIPODOC $ "VL|BA"
	
								aAreaAnt := GetArea()
								oModelBx  := FWLoadModel("FINM020")						
								oModelBx:SetOperation( 4 ) //Alteração
								oModelBx:Activate()
								oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
								oSubFKA := oModelBx:GetModel( "FKADETAIL" )
								oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
	
								//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
								//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
								//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
								oModelBx:SetValue( "MASTER", "E5_OPERACAO", 1 )
								oModelBx:SetValue( "MASTER", "HISTMOV"    , "ESTORNO " + Alltrim(SE5->E5_HISTOR) )
	
								If oModelBx:VldData()
									oModelBx:CommitData()
									oModelBx:DeActivate()
								Else
									lRet := .F.
									cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
									cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
									cLog += cValToChar(oModelBx:GetErrorMessage()[6])        	
									Help( ,,"M020VLDE3",,cLog, 1, 0 )
	
								Endif								
								RestArea(aAreaAnt)
							Else
								//Cancelo os registros de valores acessoriso (Multas, Juros etc)
								RecLock("SE5")
								dbDelete()
								MsUnLock()
							Endif
	
						Endif
				
					EndIf

					DbSkip()
				EndDo

				dbSetOrder(1)
				dbGoTo(nRecSe5)		//volta para o registro principal

				If !Eof()
					RecLock( "SA2" )
					If SE2->E2_MOEDA > 1
						nValPadrao := Round(NoRound(xMoeda(nValPadrao,1,SE2->E2_MOEDA,dBaixa,3),3),2)
						nValPadrao := Round(NoRound(xMoeda(nValPadrao,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
					Endif
					IF SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						SA2->A2_SALDUP		:= A2_SALDUP - nValPadrao
						SA2->A2_SALDUPM	:= A2_SALDUPM-xMoeda(nValPadrao,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
					Else
						SA2->A2_SALDUP	:= A2_SALDUP + nValPadrao
						SA2->A2_SALDUPM	:= A2_SALDUPM+xMoeda(nValPadrao,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
					Endif
					nAtraso:=dBaixa-SE2->E2_VENCTO
					If nAtraso > 1
						IF Dow(SE2->E2_VENCTO) == 1 .Or. Dow(SE2->E2_VENCTO) == 7
							IF Dow(dBaixa) == 2 .and. nAtraso <= 2
								nAtraso := 0
							EndIF
						EndIF
						nAtraso:=IIF(nAtraso<0,0,nAtraso)
						If SA2->A2_MATR < nAtraso
							Replace A2_MATR With nAtraso
						EndIf
					Endif
				Endif
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Marcar no registro de baixa do SEK o cancelamento da baixa        ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cNumTit := xFilial("SEK")+TRB->NUMERO
				For nLocTit := 1 to Len(aLocSEK)
					nLocCol	:= Ascan(aCampos,{|aValor|Alltrim(aValor) == aLocSEK[nLocTit] })                    // Result: 2
					cNumTit	+= aLinSEK[nTit,nLocCol]
				Next nLocTit

				SEK->(dbSetOrder(1))
				If  SEK->(dbSeek(cNumTit))
					nValor	+= SEK->EK_VALOR
					RecLock("SEK",.F.)
					Replace SEK->EK_CANPARC With GetMV('MV_NUMLIQ')
					MsUnlock()
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Desabilita a opcao de cancelamento da MarkBrowse.                 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					RecLock("TRB",.F.)
					Replace TRB->PODE With "N"

					If cPaisLoc == "CHI"
						TRB->CANCELADA := "S"	
						TRB->SITUACAO  := "02"		
					EndIf

					MsUnlock()
				Endif
			EndIf
			cNumTit		:=	""
			aBaixaSE5 	:=	{}
		Next nTit
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Gera o movimento para compensar o estorno no SE5	       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If nValSalSE5 > 0
			//Model de Movimento bancario
			cCamposE5 += "{"
			cCamposE5 += " {'E5_LOTE'    ,'" + cLoteFin + "'},"
			cCamposE5 += " {'E5_DTDIGIT' , dDataBase },"
			cCamposE5 += " {'E5_VENCTO'  , dDataBase },"
			cCamposE5 += " {'E5_MOTBX'   ,'" + TrazCodMot(cMotBx) + "'}"
			cCamposE5 += "}"

			oModelMov:SetOperation( 3 ) //Inclusao
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) // Habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) // Novo processo	

			oSubFK5MV  := oModelMov:GetModel("FK5DETAIL")
			oSubFKAMV  := oModelMov:GetModel("FKADETAIL")

			oSubFKAMV:SetValue( "FKA_IDORIG", FWUUIDV4() )            
			oSubFKAMV:SetValue( "FKA_TABORI", "FK5" )

			oSubFK5MV:SetValue( "FK5_BANCO"  , cBanco )
			oSubFK5MV:SetValue( "FK5_AGENCI" , cAgencia )
			oSubFK5MV:SetValue( "FK5_CONTA"  , cConta )
			oSubFK5MV:SetValue( "FK5_DATA"   , dDatabase )
			oSubFK5MV:SetValue( "FK5_DTDISP" , dDataBase) 

			If cPaisLoc<>"CHI"
				oSubFK5MV:SetValue( "FK5_MOEDA"  , aTitSe5[nI,06])
				oSubFK5MV:SetValue( "FK5_TXMOED" , aTitSe5[nI,07])
				oSubFK5MV:SetValue( "FK5_FILORI" , aTitSe5[nI,25] )
			Else
				oSubFK5MV:SetValue( "FK5_MOEDA"  , StrZero(SE2->E2_MOEDA,2))
				oSubFK5MV:SetValue( "FK5_TXMOED" , RecMoeda(dDataBase,SE2->E2_MOEDA))
				oSubFK5MV:SetValue( "FK5_FILORI" , cFilAnt )
			EndIf

			oSubFK5MV:SetValue( "FK5_VALOR"	 , nValSalSE5 )
			oSubFK5MV:SetValue( "FK5_NATURE" , cNatureza )
			oSubFK5MV:SetValue( "FK5_RECPAG" , Iif(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG,"P","R") )
			oSubFK5MV:SetValue( "FK5_LA"     , " " )
			oSubFK5MV:SetValue( "FK5_TPDOC"  , "VL" )
			oSubFK5MV:SetValue( "FK5_HISTOR" , Left(cHist086,TamSX3("FK5_HISTOR")[1]) )
			oSubFK5MV:SetValue( "FK5_SEQ"    , cSequencia )
			oSubFK5MV:SetValue( "FK5_DOC"    , "SEK" + TRB->NUMERO + GetMV('MV_NUMLIQ') )	
			oSubFK5MV:SetValue( "FK5_VLMOE2" , nValEstrang )

			//Grava os dados

			If oModelMov:VldData()
				oModelMov:CommitData()          
				oModelMov:DeActivate()
			Else
				cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	

				Help( ,,"M010VLDI5",,cLog, 1, 0 )	             
			Endif

			nRecSE5	:=	SE5->(Recno())

			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
			EndIf

			If lPadrao563  .and. lLanca
				Do Case
					Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
					cAlias := "SF2"
					Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
					cAlias := "SF2"
					Otherwise
					cAlias := "SF1"
				EndCase
				cKeyImp := 	xFilial(cAlias)	+;
				SEK->EK_NUM		+;
				SEK->EK_PREFIXO	+;
				SEK->EK_FORNECE	+;
				SEK->EK_LOJA
				If ( cAlias == "SF1" )
					cKeyImp += SE1->E1_TIPO
				Endif
				Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")

				nTotalLAnc		+= DetProva( nHdlPrv,;
				"563",;
				"FINA086",;
				cLote,;
				/*nLinha*/,;
				/*lExecuta*/,;
				/*cCriterio*/,;
				/*lRateio*/,;
				/*cChaveBusca*/,;
				/*aCT5*/,;
				/*lPosiciona*/,;
				@aFlagCTB,;
				/*aTabRecOri*/,;
				/*aDadosProva*/ )
			Endif
		EndIf
		cNumLiq	:=	GetMV('MV_NUMLIQ')
		PutMV('MV_NUMLIQ',Soma1(cNumLiq))
	End Transaction
	MsgInfo(cMsgEst+STR0074) 	 //"Cancelamento da(s) baixa(s) completo."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera lan‡amento cont bil de estorno ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF nTotalLanc > 0 .and.  lLanca
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para Lan‡amento Cont bil 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RodaProva(  nHdlPrv,;
		nTotalLanc)

		lLanctOk := cA100Incl( cArquivo,;
		nHdlPrv,;
		3,;
		cLote,;
		lDigita,;
		.F.,;
		/*cOnLine*/,;
		/*dData*/,;
		/*dReproc*/,;
		@aFlagCTB,;
		/*aDadosProva*/,;
		/*aDiario*/ )
		If lLanctOk .AND. !lUsaFlag
			If nRecSE5 > 0
				SE5->(MsGoTo(nRecSE5))

				aAreaAnt := GetArea()					
				oModelMov:SetOperation( 4 ) //Alteração
				oModelMov:Activate()
				oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
				oSubFK5MV  := oModelMov:GetModel("FK5DETAIL")
				oSubFKAMV  := oModelMov:GetModel("FKADETAIL")

				If oSubFKAMV:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

					oSubFK5MV:SetValue( "FK5_LA", "S" )

					If oModelMov:VldData()
						oModelMov:CommitData()
						oModelMov:DeActivate()
					Else
						cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	
						Help( ,,"M030VLDE3",,cLog, 1, 0 )
					Endif								
				EndIf
				RestArea(aAreaAnt)			
			Endif
		Endif

		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	Endif

	RestArea(aAreaSA6)
	RestArea(aAreaSE2)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FaEstCanc ºAutor  ³Bruno Sobieski      º Data ³  10/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o estorno do cancelamento dos titulos marcados.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FaEstCanc()

	Local cChaveBx := ""
	Local nTit,nLocCol,nX
	Local nMulta	:=	nVlrDac	:=	0
	Local cNumTit	:=	""
	Local aLocSE2	:=	{"EK_PREFIXO","EK_NUM","EK_PARCELA","EK_TIPO","EK_FORNECE","EK_LOJA"}//Campos p/ loc. do titulo no SE2
	Local aLocSEK	:=	{"EK_TIPODOC","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_TIPO","EK_SEQ"}
	Local aCanParc	:=	{}
	Local lPadrao570 	:= VerPadrao('570')
	Local lPadrao565 	:= VerPadrao('565')
	Local nTotalLanc	:=	0
	Local cLote			:=	""
	Local lLanca		:= .T. //(mv_par07==1)
	Local cArquivo		:=	''
	Local cAlias		:= ""
	Local cKeyImp		:= ""
	Local nLocTit		:= 0
	//***Reestruturação do SE5
	Local oModelMov	:= FWLoadModel("FINM020")
	Local oSubFKAMV
	Local oSubFK5MV
	Local cLog			:= ""
	Local aAreaAnt		:= {}
	Local cCamposE5     := ""
	
	//***Reestruturação do SE5
	Begin Transaction

		If lLanca
			dbSelectArea("SX5")
			dbSeek(xFilial()+"09FIN")
			cLote:=IIF(Found(),Trim(X5DESCRI()),"FIN")
			nHdlPrv := HeadProva( cLote,;
			"FINA086",;
			Substr( cUsuario, 7, 6 ),;
			@cArquivo )
			If nHdlPrv <= 0
				Help(" ",1,"A100NOPROV")
			EndIf
		Endif

		For nTit := 1 to Len(aLinSEK)
			cNumTit	:=	""
			For nLocTit := 1 to Len(aLocSE2)
				nLocCol := Ascan(aCampos,{|aValor| Alltrim(aValor) == aLocSE2[nLocTit] })                    // Result: 2
				cNumTit	+= aLinSEK[nTit,nLocCol]
			Next nLocTit

			nLocCol := Ascan(aCampos,{|x| x == "EK_SEQ" })                    // Result: 2
			cSequencia := aLinSEK[nTit,nLocCol]

			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			If aLinSEK[nTit,1] == 1 .And. SE2->(dbSeek(xFilial("SE2")+cNumTit))
				cChaveBx := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Localiza na movimenta‡„o banc ria, os registros referentes a baixa³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				dbSelectArea("SE5")
				dbSetOrder(7)

				SE5->( dbSeek(xFilial("SE5")+cChaveBx+cSequencia ))
				While !Eof() .And. xFilial("SE5")+cChaveBx+cSequencia == &(IndexKey())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cancela as baixas gerando um lancamento de estorno no SE5         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAreaAnt := GetArea()					
					oModelMov := FWLoadModel("FINM020")
					oModelMov:SetOperation( 4 ) //Alteração

					oModelMov:Activate()

					cCamposE5 := "{{'E5_SITUACA', ' ' }}"

					oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
					oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )

					oSubFK5MV  := oModelMov:GetModel("FK5DETAIL")
					oSubFKAMV  := oModelMov:GetModel("FKADETAIL")

					If oSubFKAMV:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
						Else
							oSubFK5MV:SetValue( "FK5_LA", "S" )
						EndIf

						If oModelMov:VldData()
							oModelMov:CommitData()
							oModelMov:DeActivate()
						Else
							cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	
							Help( ,,"M030VLDE3",,cLog, 1, 0 )
						Endif								
					EndIf
					RestArea(aAreaAnt)			
					//MsUnlock()

					If E5_TIPODOC $ "MT"
						nMulta	:= SE5->E5_VLMOED2
					Endif
					If E5_MOTBX == 'DAC'
						nVlrDac 	:= SE5->E5_VLMOED2
					Endif
					DbSkip()
				EndDo

				cNumTit := xFilial("SEK")+TRB->NUMERO
				For nLocTit := 1 to Len(aLocSEK)
					nLocCol	:= Ascan(aCampos,{|aValor|Alltrim(aValor) == aLocSEK[nLocTit] })                    // Result: 2
					cNumTit	+= aLinSEK[nTit,nLocCol]
				Next nLocTit
				//Atualizar SEK
				SEK->(dbSetOrder(1))
				SEK->(dbSeek(cNumTit))
				If Ascan(aCanParc,SEK->EK_CANPARC)== 0
					AAdd(aCanParc,SEK->EK_CANPARC)
				Endif
				RecLock('SEK',.F.)
				Replace EK_CANPARC	With ""
				MsUnLock()
				//Atualizar SE2
				RecLock('SE2',.F.)
				Replace E2_SALDO With E2_SALDO - (SEK->EK_VALOR + SEK->EK_DESCONT + nVlrDac) + (SEK->EK_JUROS + nMulta)
				Replace E2_BAIXA With SEK->EK_EMISSAO
				MsUnLock()
				If lPadrao570  .And. lLanca
					Do Case
						Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
						cAlias := "SF2"
						Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
						cAlias := "SF2"
						Otherwise
						cAlias := "SF1"
					EndCase
					cKeyImp := 	xFilial(cAlias)	+;
					SEK->EK_NUM		+;
					SEK->EK_PREFIXO	+;
					SEK->EK_FORNECE	+;
					SEK->EK_LOJA
					If ( cAlias == "SF1" )
						cKeyImp += SE1->E1_TIPO
					Endif
					Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")

					nTotalLanc	+= DetProva( nHdlPrv,;
					"570",;
					"FINA086",;
					cLote,;
					/*nLinha*/,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )
				Endif
			Endif
		Next

		For nX := 1 To Len(aCanParc)
			dbSelectArea("SE5")
			dbSetOrder(10)
			If DbSeek(xFilial()+'SEK'+TRB->NUMERO+aCanParc[nX])

				aAreaAnt := GetArea()
		cHistEst:= SE5->E5_HISTOR
		
		If (GetNewPar("MV_ESTORDP","N") == "S" )
			oModel :=  FWLoadModel('FINM030')//Mov. Bancario Manual
			oModel:SetOperation( 4 ) //Alteração
			oModel:Activate()
			oSubFKA := oModel:GetModel( "FKADETAIL" )
			oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
			oModel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
			oModel:SetValue( "MASTER", "E5_OPERACAO", 2 ) //E5_OPERACAO 3 = Deleta da SE5 e sem gerar estorno na FK5
		Else
			oModel :=  FWLoadModel('FINM030')//Mov. Bancario Manual
			oModel:SetOperation( 4 ) //Alteração
			oModel:Activate()
			oSubFKA := oModel:GetModel( "FKADETAIL" )
			oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
			oModel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
			oModel:SetValue( "MASTER", "E5_OPERACAO", 1 ) //E5_OPERACAO 3 = Deleta da SE5 e sem gerar estorno na FK5
		EndIf
				If oModel:VldData()
					oModel:CommitData()
					oModel:DeActivate()
			If (GetNewPar("MV_ESTORDP","N") == "S" )
				aAreaTu:=GetArea()
				DbSelectArea("SE5")
				RecLock("SE5",.F.)
				SE5->E5_HISTOR:=STR0122  + cHistEst // // "Reversión"
				MsUnlock()
				RestArea(aAreaTu)
			EndIf
		
			RecLock("TRB",.F.)
			Replace TRB->PODE With "S"
			
			If cPaisLoc == "CHI"
				TRB->CANCELADA := "N"	
				TRB->SITUACAO   := "01"		
            EndIf
            MsUnlock()
				Else
					lRet := .F.
					cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[6])

					If (Type("lF040Auto") == "L" .and. lF040Auto)
						Help( ,,"M040VALID",,cLog, 1, 0 )
					Endif
				Endif

				If SE5->E5_LA == 'S '
					If lPadrao565  .And. lLanca
						Do Case
							Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
							cAlias := "SF2"
							Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
							cAlias := "SF2"
							Otherwise
							cAlias := "SF1"
						EndCase
						cKeyImp := 	xFilial(cAlias)	+;
						SEK->EK_NUM		+;
						SEK->EK_PREFIXO	+;
						SEK->EK_FORNECE	+;
						SEK->EK_LOJA
						If ( cAlias == "SF1" )
							cKeyImp += SE1->E1_TIPO
						Endif
						Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")

						nTotalLanc	+= DetProva( 	nHdlPrv,;
						"565",;
						"FINA086",;
						cLote,;
						/*nLinha*/,;
						/*lExecuta*/,;
						/*cCriterio*/,;
						/*lRateio*/,;
						/*cChaveBusca*/,;
						/*aCT5*/,;
						/*lPosiciona*/,;
						@aFlagCTB,;
						/*aTabRecOri*/,;
						/*aDadosProva*/ )
					Endif
				Endif
			Endif
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera lan‡amento cont bil de estorno	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF nTotalLanc > 0 .and.  lLanca
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lan‡amento Cont bil  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RodaProva(  nHdlPrv,;
			nTotalLanc)

			cA100Incl( cArquivo,;
			nHdlPrv,;
			3,;
			cLote,;
			lDigita,;
			.F.,;
			/*cOnLine*/,;
			/*dData*/,;
			/*dReproc*/,;
			@aFlagCTB,;
			/*aDadosProva*/,;
			/*aDiario*/ )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

		Endif

	End Transaction

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fa086Sel ³ Autor ³ Lucas                 ³ Data ³ 16.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A086Sel(nOpcao,aDados)
	Local nX	:=	0
	For nX:=1 To Len(aDados)
		aDados[nX][1]	:=	nOpcao
	Next
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Lucas                 ³ Data ³ 16.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criação do aRotina na redefinição do MenuDef.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {}
	If cPaisLoc == "CHI" .Or. cPaisLoc == "BRA"
		aRotina := {  { OemToAnsi(STR0013),'fa086Buscar',0 ,1},;  //"bUscar"
		{ OemToAnsi(STR0014),'fa086Visual',0 ,1},;  //"Visualizar"
		{ OemToAnsi(STR0062),'Fa086CanPa(.F.)',0 ,1},;  //"Canc. Parc."		 //"Can. parcial"
		{ OemToAnsi(STR0063),'Fa086CanPa(.T.)',0 ,1},;  //"Canc. Parc."		 //"Est. Can. Parc."
		{ OemToAnsi(STR0015),'fa086Cancel',0 ,1} }  //"Cancelar"
	ElseIf cPaisLoc $ "ARG|DOM|EQU"
		aRotina := {  { OemToAnsi(STR0013),'fa086Buscar',0 ,1},;  //"bUscar"
		{ OemToAnsi(STR0014),'fa086Visual',0 ,1},;  //"Visualizar"
		{ OemToAnsi(STR0015),'fa086Cancel',0 ,1},;  //"Cancelar"
		{ OemToAnsi("Leyenda"),'fa086Leg',0 ,2} }  //"Leyenda"
	Else
		aRotina := {  { OemToAnsi(STR0013),'fa086Buscar',0 ,1},;  //"bUscar"
		{ OemToAnsi(STR0014),'fa086Visual',0 ,1},;  //"Visualizar"
		{ OemToAnsi(STR0015),'fa086Cancel',0 ,1} }  //"Cancelar"
	Endif
Return(aRotina)

//----
Static Function a086chSFE()

	Local aFiles		:= Iif(cPaisLoc=="ANG",Array(ADIR("*.EM")),{})
	Local lRet			:= .t.
	Local lDel			:= .F.
	Local lValida		:= .T.
	Local nX			:= 0
	Local aDatas		:= {}
	Local cNumOP		:= ""
	Local cFornece		:= ""
	Local cLoja			:= ""
	Local dEmissao		:= Ctod("//")

	Default lOPRotAut	:= .F.

	cNumOP		:= Iif( lOPRotAut, cNumOrdPg,	TRB->NUMERO  )
	cFornece	:= Iif( lOPRotAut, cForOP, 		TRB->PROVEEDOR )
	cLoja		:= Iif( lOPRotAut, cFilForOP,	TRB->SUCURSAL  )
	dEmissao	:= Iif( lOPRotAut, dEmisOP,		TRB->EMISION  )

	If ExistBlock("A086SFEG")
		lRet	:=	ExecBlock("A086SFEG",.F.,.F.,lRet)
		lValida:=.f.
	Endif
	If cPaisLoc=="ANG" .And. lValida
		DbSelectArea("SFE")
		DbSetOrder(2)   // / Pesquisa por Ordem de pago
		If	SFE->(dbSeek(xFilial("SFE")+ cNumOP+ "3"))
			//Exemplo de nome de arquivo de apuração: ADDMMAADDMMAA0101.II, onde:
			//A	Indica que o arquivo em questão é de apuração de impostos.
			//DDMMAA	Data inicial do processamento (dia, com dois caracteres, mês, com dois caracteres e ano, com dois caracteres)
			//DDMMAA	Data final do processamento (dia, com dois caracteres, mês, com dois caracteres e ano, com dois caracteres)
			//01	Código da empresa que está efetuando a apuração.
			//01	Código da filial que está efetuando a apuração.
			//II	Indica o imposto apurado, sendo:
			//SE = Imposto de Selo;
			//CO = Imposto de Consumo e
			//EM = Imposto de Empreitada
			ADIR("A????????????"+cEmpAnt+cFilAnt+".EM", aFiles)
			For nX:=1 TO Len(aFiles)
				AAdd(aDatas,{Ctod(Substr(aFiles[nX],2,2)+"/"+Substr(aFiles[nX], 4,2)+"/"+Substr(aFiles[nX],6,2)),;
				Ctod(Substr(aFiles[nX],8,2)+"/"+Substr(aFiles[nX],10,2)+"/"+Substr(aFiles[nX],12,2))})
			Next
			For nX:= 1 To Len(aDatas)
				If SFE->FE_EMISSAO >= aDatas[nX,1] .And. SFE->FE_EMISSAO <= aDatas[nX,2]
					If Aviso(STR0086,STR0087+;//"Atencao" ##"Foi encontrada uma apuracao para uma retencao de Empreitadas, confirma a exclusão da OP?"
					CHR(13)+CHR(10)+STR0088,{STR0089,STR0090}) == 2 //"Se optar por excluir deverá refazer a apuração (somente é permitido se ainda não foi paga)."##"Continuar"##"Cancelar"
						lRet	:=	.F.
					Endif
					Exit
				Endif
			Next
		Endif
	ElseIf cPaisLoc=="ARG" .And. lValida
		DbSelectArea("SFE")
		DbSetOrder(2)   // / Pesquisa por Ordem de pago

		If	SFE->(dbSeek(xFilial("SFE")+ cNumOP+ "G"))
			cConceito:= SFE->FE_CONCEPT
			DbSetOrder(3)        // Indice por codigo de fornecedor
			// 	If SFE->EF_TIPO$"S"
			cChaveSFE := xFilial("SFE")+cFornece+cLoja
			If SFE->FE_RETENC = 0 //SFE->FE_TIPO$"S|G"
				SFE->(dbSkip())
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA .And.  lRet
					If ( Month( SFE->FE_EMISSAO ) == Month( SEK->EK_DTDIGIT ) .And.YEAR( SFE->FE_EMISSAO )==Year( SEK->EK_DTDIGIT ) ) .And.;
					( SFE->FE_TIPO $"G" ) .And. cConceito==SFE->FE_CONCEPT
						If SFE->FE_RETENC > 0 .And. SFE->FE_ORDPAGO <> cNumOP  .And. Empty(SFE->FE_DTESTOR)
							If lOPRotAut
								cTxtRotAut += "Ganancias" + CRLF + STR0085 + "  " + SFE->FE_ORDPAGO + CRLF + CRLF
							Else
								MsgAlert(STR0085 + "  " + SFE->FE_ORDPAGO,"Ganancias")
							EndIf
							lRet:=.F.
						EndIf
					EndIf
					SFE->(dbSkip())
				EndDo
			Else

				lDel:= .F.
				aAreaSFE:=GetArea()
				SFE->(dbSkip(-1))
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA .And. (Month(SFE->FE_EMISSAO) == Month(dEmissao) .And.YEAR(SFE->FE_EMISSAO)==Year(dEmissao )) .and.	 !lDel .And. lRet
					If SFE->FE_TIPO $"G"
						If SFE->FE_RETENC = 0 .And. SFE->FE_ORDPAGO <> cNumOP

							RestArea(aAreaSFE)
							SFE->(DBSkip())
							If !SFE->(Eof())
								While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA .And.  lRet  //.And. cConceito==SFE->FE_CONCEPT
									If (Month(SFE->FE_EMISSAO) == Month(dEmissao) .And.YEAR(SFE->FE_EMISSAO)==Year(dEmissao)) .And.;
									(SFE->FE_TIPO $"G") .And. cConceito==SFE->FE_CONCEPT
										If SFE->FE_RETENC > 0 .And. SFE->FE_ORDPAGO <> cNumOP .And. Empty(SFE->FE_DTRETOR)
											If lOPRotAut
												cTxtRotAut += "Ganancias" + CRLF + STR0085 + "  " + SFE->FE_ORDPAGO + CRLF + CRLF
											Else
												MsgAlert(STR0085 + "  " + SFE->FE_ORDPAGO,"Ganancias")
											EndIf
											lRet :=.F.
										EndIf
									EndIf
									SFE->(DBSkip())
								EndDo
							Else
								lDel:= .T.
							EndIF
						Else
							lDel:= .T.
						EndIf
					EndIf
					SFE->(DBSkip())
				EndDo
			EndIf

		EndIf
		DbSelectArea("SFE")
		DbSetOrder(2)
		If	SFE->(dbSeek(xFilial("SFE")+ cNumOP+ "S")) .And.  lRet
			cConceito:= SFE->FE_CONCEPT
			DbSetOrder(3)
			cChaveSFE := xFilial("SFE")+cFornece+cLoja
			If SFE->FE_RETENC = 0 //SFE->FE_TIPO$"S|G"
				SFE->(dbSkip())
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA  .And.  lRet
					If (Month(SFE->FE_EMISSAO) == Month(dEmissao) .And.YEAR(SFE->FE_EMISSAO)==Year(dEmissao)) .And.;
					(SFE->FE_TIPO $"S")
						If SFE->FE_RETENC > 0 .And. SFE->FE_ORDPAGO <> cNumOP .And. Empty(SFE->FE_DTRETOR)//.And. SFE->FE_ORDPAGO > TRB->NUMERO//TRB->EMISION < SFE->FE_EMISSAO) //.And. TRB->EMISION <> SFE->FE_EMISSAO
							If lOPRotAut
								cTxtRotAut += "SUSS" + CRLF + STR0085 + "  " + SFE->FE_ORDPAGO + CRLF + CRLF
							Else
								MsgAlert(STR0085 + "  " + SFE->FE_ORDPAGO,"SUSS")
							EndIf
							lRet :=.F.
						EndIf

					EndIf
					SFE->(dbSkip())
				EndDo
			Else

				lDel:= .F.
				aAreaSFE:=GetArea()
				SFE->(dbSkip(-1))
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA .And. (Month(SFE->FE_EMISSAO) == Month(dEmissao) .And.YEAR(SFE->FE_EMISSAO)==Year(dEmissao)) .and.	 !lDel  .And.  lRet
					If SFE->FE_TIPO $"S" //.And. cConceito==SFE->FE_CONCEPT
						If SFE->FE_RETENC = 0 .And. SFE->FE_ORDPAGO <> cNumOP

							RestArea(aAreaSFE)
							SFE->(DBSkip())
							If !SFE->(Eof())

								While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA //.And. cConceito==SFE->FE_CONCEPT
									If (Month(SFE->FE_EMISSAO) == Month(dEmissao) .And.YEAR(SFE->FE_EMISSAO)==Year(dEmissao)) .And.;
									(SFE->FE_TIPO $"S")
										If SFE->FE_RETENC > 0 .And. SFE->FE_ORDPAGO <> cNumOP .And. Empty(SFE->FE_DTRETOR)
											If lOPRotAut
												cTxtRotAut += "SUSS" + CRLF + STR0085 + "  " + SFE->FE_ORDPAGO + CRLF + CRLF
											Else
												MsgAlert(STR0085 + "  " + SFE->FE_ORDPAGO,"SUSS")
											EndIf
											lRet :=.F.
										EndIf
									EndIf
									SFE->(DBSkip())
								EndDo
							Else
								lDel:= .T.
							EndIF
						Else
							lDel:= .T.
						EndIf
					EndIf
					SFE->(DBSkip())
				EndDo
			EndIf
		EndIf
	ELSEIF cPaisLoc=="PER" .And. lValida
		DbSelectArea("SFE")
		DbSetOrder(2)   // / Pesquisa por Ordem de pago
		If	SFE->(dbSeek(xFilial("SFE")+ cNumOP+ "I"))
			//Exemplo de nome de arquivo de apuração: ADDMMAADDMMAA0101.II, onde:
			//A	Indica que o arquivo em questão é de apuração de impostos.
			//DDMMAA	Data inicial do processamento (dia, com dois caracteres, mês, com dois caracteres e ano, com dois caracteres)
			//DDMMAA	Data final do processamento (dia, com dois caracteres, mês, com dois caracteres e ano, com dois caracteres)
			//01	Código da empresa que está efetuando a apuração.
			//01	Código da filial que está efetuando a apuração.
			//II	Indica o imposto apurado, sendo:
			//IG = IGV;
			//IS = ISC
			ADIR("A????????????"+cEmpAnt+cFilAnt+".IG", aFiles)
			For nX:=1 TO Len(aFiles)
				AAdd(aDatas,{Ctod(Substr(aFiles[nX],2,2)+"/"+Substr(aFiles[nX], 4,2)+"/"+Substr(aFiles[nX],6,2)),;
				Ctod(Substr(aFiles[nX],8,2)+"/"+Substr(aFiles[nX],10,2)+"/"+Substr(aFiles[nX],12,2))})
			Next
			For nX:= 1 To Len(aDatas)
				If SFE->FE_EMISSAO >= aDatas[nX,1] .And. SFE->FE_EMISSAO <= aDatas[nX,2]
					//	If Aviso("Atencao","Foi encontrada uma apuracao para uma retencao do IGV, confirma a exclusão da OP?"+;
					//			CHR(13)+CHR(10)+"Se optar por excluir deverá refazer a apuração (somente é permitido se ainda não foi paga).",{"Continuar","Cancelar"}) == 2
					If Aviso(STR0086, STR0092 +;
					CHR(13)+CHR(10)+STR0093,{STR0089,STR0090}) == 2

						lRet	:=	.F.
					Endif
					Exit
				Endif
			Next
		Endif

		/* Verifica se foi feita retencao de IR */
		If	SFE->(dbSeek(xFilial("SFE")+ PadR(cNumOP,TamSX3("FE_ORDPAGO")[1])+ "R"))
			If lOPRotAut
				lRet	:= .T.
			Else
				lRet	:= MsgYesNo(AllTrim(cNumOP) + " - " + STR0094 + CRLF + STR0093,STR0086)
			EndIf
		Endif
	EndIf

	If ExistBlock("A086SFE")
		lRet	:=	ExecBlock("A086SFE",.F.,.F.,lRet)
	Endif

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fa086Leg ³ Autor ³ Lucas                 ³ Data ³ 16.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa086Leg(cAlias, nReg)

	Local aLegenda := 	{ 	{"BR_VERDE"   , STR0098 },;   	//"Disponivel para Anulación"
	{"BR_VERMELHO", STR0099 },;   	//"Orden de Pago Cancelada"
	{"BR_AMARELO" , STR0100	},;   	//"Cheques Vinculados"
	{"BR_PRETO"   , STR0144		},;   //"Cheques Compensados"
	{"BR_AZUL"    , STR0145}	} //"Retencion Gerada e Baixada"
	Local uRetorno := .T.

	//Conciliação Bancária
	If cPaisLoc <> "BRA"
		aAdd(aLegenda,{"BR_PINK", STR0110}) //Movimento Conciliado
	EndIf

	//Lote Financeiro
	If cPaisLoc $ "ARG"
		aAdd(aLegenda,{"BR_LARANJA", STR0111}) //Ordem de Pago em Lote Ativo
	EndIf

	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		Aadd(uRetorno, { 'TRB->SITUACAO=="01"', aLegenda[1][1] } )
		Aadd(uRetorno, { 'TRB->SITUACAO=="02"', aLegenda[2][1] } )
		Aadd(uRetorno, { 'TRB->SITUACAO=="03"', aLegenda[3][1] } )
		Aadd(uRetorno, { 'TRB->SITUACAO=="04"', aLegenda[4][1] } )
		Aadd(uRetorno, { 'TRB->SITUACAO=="05"', aLegenda[5][1] } )

		//Conciliação Bancária
		If cPaisLoc <> "BRA"
			Aadd(uRetorno, { 'TRB->SITUACAO=="06"', aLegenda[6][1] } )
		EndIf

		If cPaisLoc $ "ARG"
			Aadd(uRetorno, { 'TRB->SITUACAO=="07"', aLegenda[7][1] } )
		EndIf

	Else
		BrwLegenda(STR0103, STR0102, aLegenda) //"Anulación de Orden de Pago"###"Legenda"
	Endif

Return uRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fa086MBrow ³ Autor ³ Lucas               ³ Data ³ 16.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define uma tela para executar a MsSelect, simulando uma    ³±±
±±³          ³ MarkBrowse.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fa086MBrow(cAlias,cCpoMark,cCpo,aCpos,cMarca,nOpcAuto)
	
	Local aCores   := {}
	Local aButtons := {}
	Local lConfirm := .F.
	Local oDlg2
	Local lAutomato := IsBlind()
	Local aMarca	:= {}
	Local lMarkAll  := .F. 
	Local lInverte	:= .F.
	Private lRetSal := .F.

	AADD(aCores, { 'TRB->SITUACAO == "01"', "BR_VERDE" } )		//"Disponivel para Anulación"
	AADD(aCores, { 'TRB->SITUACAO == "02"', "BR_VERMELHO" } )	//"Orden de Pago Cancelada"
	AADD(aCores, { 'TRB->SITUACAO == "03"', "BR_AMARELO" } )	//"Cheques Vinculados"
	AADD(aCores, { 'TRB->SITUACAO == "04"', "BR_PRETO" } )		//"Cheques Compensados"
	AADD(aCores, { 'TRB->SITUACAO == "05"', "BR_AZUL"})         //"Doctos Generados Bajados"

	//Conciliação Bancária
	If cPaisLoc <> "BRA"
		AADD(aCores, { 'TRB->SITUACAO == "06"', "BR_PINK"}) //Movimento Conciliado
	EndIf

	//Lote Financeiro
	If cPaisLoc $ "ARG"
		AADD(aCores, { 'TRB->SITUACAO == "07"', "BR_LARANJA"})  //Ordem de Pago em Lote Ativo
	EndIf

	Aadd(aButtons,{'RECALC' ,{|| fa086Buscar()},,OemToAnsi("Buscar")+"",OemToAnsi("Buscar")})
	Aadd(aButtons,{'POSCLI' ,{|| fa086Visual()},,OemToAnsi("Visualizar")+"",OemToAnsi("Visualizar")})
	Aadd(aButtons,{'NOTE'   ,{|| fa086Leg(cAlias, TRB->(Recno()))}   ,,OemToAnsi("Leyenda")+"",OemToAnsi("Leyenda")})

	If cPaisLoc $ "CHI"
		Aadd(aButtons,{'NOTE'   ,{|| Fa086CanPa(.F.)}   ,,OemToAnsi(STR0062)+"",OemToAnsi(STR0062)})
		Aadd(aButtons,{'NOTE'   ,{|| Fa086CanPa(.T.)}   ,,OemToAnsi(STR0063)+"",OemToAnsi(STR0063)})
	EndIf

	aSize := MSADVSIZE()
  If !lAutomato
	DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0102) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  //"Cancelamento da Ordem de Pago"

	oDlg2:lMaximized := .T.

	TRB->(dbGoTop())

	If cPaisLoc $ "MEX|PER|COL" 
		oMark:=MsSelect():New("TRB","MARK",'SITUACAO=="02".OR.SITUACAO=="04".OR.SITUACAO=="05".OR.SITUACAO=="06".OR.SITUACAO=="07"',aCpos,@lInverte,@cMarcaTR,{02,1,123,316},,,,,aCores)
		oMark:bMark := {|| iif(fn086Mark(cMarcaTR, aMarca, oMark, lMarkAll, lInverte),oDlg2:End(),)}
		oMark:oBrowse:bAllMark  := {|| fn086AllMk(cMarca, aMarca, oMark)}
	Else
		oMark:=MsSelect():New("TRB","MARK",'SITUACAO=="02".OR.SITUACAO=="04".OR.SITUACAO=="05".OR.SITUACAO=="06".OR.SITUACAO=="07"',aCpos,,cMarcaTR,{02,1,123,316},,,,,aCores)
	EndIf
	oMark:oBrowse:lhasMark := .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:REFRESH()

	 ACTIVATE MSDIALOG oDlg2 ON INIT ( EnchoiceBar( oDlg2,{|| lConfirm:=.T.,oDlg2:End()} , {|| oDlg2:End() },,aButtons )) CENTERED //"Deseja cancelar?"

	  If lConfirm
	     fa086Cancel()
	  EndIf
  Else
     
     fa086Cancel()
  
  Endif	
	
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fn086AllMk ³ Autor ³ Alfredo Medran    ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca y desmarca todos los registros contenidos en el brows³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fa086MBrow                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function fn086AllMk(cMarca, aMarca, oMark)

Local cAlias       := Alias()
Local cCpoMarca    := 'MARK'
Local nOrderSeek   := 1 
Local nPos         := 0
Local nRecno       := Recno()

dbSelectArea(cAlias)
dbSetOrder(nOrderSeek)
dbGoTop()

Do While !Eof()
	Reclock(cAlias, .F.)
	If (&(cCpoMarca)!=cMarca) // verifica si esta desmarcado
			If TRB->TIPODOC != 'PA'
				If !(TRB->SITUACAO $ "02|04|05|06|07")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Marca registro posicionado                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aScan(aMarca,{|x| x[1] == Recno()}) == 0
						aAdd(aMarca, {Recno(), TRB->TIPODOC})
						SimpleLock(cAlias)		
					EndIf
					Fieldput(Fieldpos(cCpoMarca), cMarca)
				EndIf
			EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desmarca registro posicionado                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := aScan(aMarca,{|x| x[1] == TRB->(RECNO())}) 
		If nPos > 0
			aDel(aMarca, nPos)
			aSize(aMarca, Len(aMarca)-1)
			SimpleLock(cAlias)		
			Fieldput(Fieldpos(cCpoMarca), '') 
		EndIf
	
	EndIf	
		
	MsUnlock()
	dbSkip()
EndDo

dbGoto(nRecno)
oMark:oBrowse:Refresh()

Return Nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fn086Mark ³ Autor ³ Alfredo Medran        ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea un browse para la bajas de los PA's                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fa086MBrow                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function fn086Mark(cMarcaTR, aMarca, oMark, lMarkAll, lInverte)

Local aArea 	:= GetArea()
Local aMotBx 	:= {}
Local aDescMotBx:= {}
Local a2ndRow 	:= {}
Local nI 		:= 0
Local cF3Bco 	:= "SA6"
Local nValPgto 	:= 0
Local nPos 		:= 0
Local nNumReg	:= 0
Local cFilTit 	:= ""
Local nAncho 	:=  0
Local nLargo 	:= 0
Local oDlg, oSize
//se inicializan variables privadas utilizadas funciones ValInfoPA, obtMndaBco, valMndBco y fa080Grv
Private cMarcaT := ""
Private cMotBx 	:= ""
Private cMoedaC := ""
Private cBanco 	:= CriaVar("E1_PORTADO")
Private cAgencia:= CriaVar("E1_AGEDEP")
Private cConta	:= CriaVar("E1_CONTA")
private dBaixa  := CriaVar("E2_BAIXA")
private dDebito	:= CriaVar("E2_BAIXA")
private cMoeda	:= ""
Private nTxMoeda:= 0
private nCentMd1:= MsDecimais(1)
private lAut 	:= If( lAut=NIL,.F.,lAut)
private cCheque	:= ""
private nMoedaBco:= 1
private nValEstrang := 0


lRetSal := .F.
If !(TRB->SITUACAO $ "02|04|05|06|07")  // accede para documentos activos

	nNumReg := Len(aMarca)
	If nNumReg > 0
		If aScan(aMarca,{|x| x[1] > 0}) <= 0
			aMarca := {}
		Else
			If TRB->TIPODOC == 'PA' // desmarca el documento
				TRB->(RecLock("TRB",.f.))
				TRB->MARK := " "
				TRB->(MsUnlock())
				MsgInfo(  STR0123 + chr(10)  + STR0124, STR0125)//"La baja de los documentos de tipo PA es individual." // "Para poder realizar la baja desmarque todos documentos marcados y vuelva a seleccionar el documento PA." // "Aviso" 
				Return 
			EndIf
		EndIf
	EndIf
	
	If IsMark("MARK",cMarcaTR,lInverte)
		//agrega documentos marcados a array
		AADD(aMarca,{ TRB->(RECNO()),TRB->TIPODOC } )
	Else
		If  Len(aMarca) > 0
			nPos := aScan(aMarca,{|x| x[1] == TRB->(RECNO())}) 
			if nPos > 0 //quita informacion en el array de documento a desmarcar 
				aDel(aMarca, nPos)
				aSize(aMarca, Len(aMarca)-1)
			EndIf
		EndIf
	EndIf
	
	cMarcaT := cMarcaTR // cMarcaT variable utilizada en func fn086Grv
	
	//genera un formulario especial para las bajas de los documentos PA
	If !EMPTY(TRB->MARK) .AND. TRB->TIPODOC == 'PA'
		dbSelectArea("SEK")
		dbSetOrder(1)//EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ   
		//verifica que documento PA seleccionado existe en SEK (Órdenes de Pago               )                                                                                  
		If MSSEEK(xFilial("SEK") + TRB->NUMERO + TRB->TIPODOC + TRB->PREFIXO + TRB->NUMDOC + TRB->PARCELA + TRB->TIPO )
			aMotBx	:= ReadMotBx()
			//Retorna o Array aDescMotBx con las descripciones de motivo das Bajas
			If Len(aDescMotbx) == 0
				For nI := 1 to len( aMotBx )
					If substr(aMotBx[nI],34,01) == "A" .or. substr(aMotBx[nI],34,01) =="P"
						If substr(aMotBx[nI],01,03) == "DEV" // solo para devoluciones
							AADD( aDescMotbx,substr(aMotBx[nI],07,10))
							cMotBx := substr(aMotBx[nI],07,10)
						EndIf
					EndIf
				Next nI
			EndIf
			
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
			cFilTit		:= xFilial("SE2")
			//Obtiene informacion de pago en SE2 (Cuentas por Pagar)
			If SE2->(MsSeek(cFilTit + TRB->PREFIXO + TRB->NUMDOC + TRB->PARCELA + TRB->TIPO + TRB->PROVEEDOR + TRB->SUCURSAL ))
				nValPgto := SE2->E2_VLCRUZ
				nValEstrang := SE2->E2_SALDO
				cMoedaC	:= IIF(Empty(SE2->E2_MOEDA),"1",AllTrim(Str(SE2->E2_MOEDA,2)))
			EndIf
			nAncho :=  290
			nLargo := 350
			DEFINE MSDIALOG oDlg FROM	31,15 TO nLargo,nAncho TITLE STR0126  PIXEL OF oMainWnd //"Anulación de PA"
				oSize := FwDefSize():New(.T.,,,oDlg)
				oSize:lLateral := .F.
				oSize:lProp	:= .T. // Proporcional
				oSize:AddObject( "1STROW" ,  100, 85, .T., .T. )
				oSize:AddObject( "2NDROW" ,  100, 81, .T., .T. )
		
				oSize:Process() 
		
				a1stRow := {oSize:GetDimension("1STROW","LININI"),;
								oSize:GetDimension("1STROW","COLINI"),;
								oSize:GetDimension("1STROW","LINEND"),;
								oSize:GetDimension("1STROW","XSIZE")}
				a2ndRow := {oSize:GetDimension("2NDROW","LININI"),;
								oSize:GetDimension("2NDROW","COLINI"),;
								oSize:GetDimension("2NDROW","LINEND"),;
								oSize:GetDimension("2NDROW","XSIZE")}
								
				a1stRow[1]  := 5
				a2ndRow[1] := 95
				a1stRow[3] := 92
				@ a1stRow[1] + 000, a1stRow[2] + 000 GROUP oGrp1  TO a1stRow[3], (a1stRow[4]-7) LABEL STR0127 OF oDlg PIXEL //"Datos Generales"
				@ a2ndRow[1] + 000, a2ndRow[2] + 000 GROUP oGrp2  TO a2ndRow[3] - 25, (a2ndRow[4]-7) LABEL STR0128 OF oDlg  PIXEL//"Saldo Pendiente"
				
				@ a1stRow[1] + 008, a1stRow[2] + 004 SAY STR0129			SIZE 40,07 OF oDlg PIXEL //"Motivo de Baja"	
				@ a1stRow[1] + 008, a1stRow[2] + 065 SAY cMotBx  			SIZE 65,47 OF oDlg PIXEL 
				
				nUltLin := 25		
				@ nUltLin, a1stRow[2] + 004 SAY STR0130	SIZE 40,07 OF oDlg PIXEL //"Banco"
				@ nUltLin,a1stRow[2] + 065  MSGET oBanco VAR cBanco 	SIZE 65, 08 OF oDlg PIXEL HASBUTTON F3 cF3Bco Valid ;
				CarregaSA6(@cBanco,@cAgencia,@cConta,MovBcoBx(cMotBx,.T.),,.T.) .and. obtMndaBco(cBanco,cAgencia,cConta)
	
				nUltLin += 12
				@ nUltLin,a1stRow[2] + 004  SAY STR0131	SIZE 39,07 OF oDlg PIXEL //"Agencia"
				@ nUltLin,a1stRow[2] + 065 MSGET oAgencia VAR cAgencia	SIZE 65, 08 OF oDlg PIXEL HASBUTTON   Valid ;
				 CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.).and. obtMndaBco(cBanco,cAgencia,cConta)
	
				nUltLin += 12
				@ nUltLin,a1stRow[2] + 004  SAY STR0132	SIZE 41,07 OF oDlg PIXEL //"Cuenta"
				@ nUltLin,a1stRow[2] + 065 MSGET oConta VAR cConta 	SIZE 65, 08 OF oDlg PIXEL HASBUTTON  Valid ;
				CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.) .and. obtMndaBco(cBanco,cAgencia,cConta)
				
				nUltLin += 12
				@ nUltLin,a1stRow[2] + 004  SAY STR0133	SIZE 41,07 OF oDlg PIXEL //"Moneda"
				@ nUltLin,a1stRow[2] + 065 MSGET oMoeda VAR cMoeda 	SIZE 20, 08 OF oDlg PIXEL When .F.
				
				nUltLin += 12
				@ nUltLin,a1stRow[2] + 004  SAY STR0134	SIZE 41,07 OF oDlg PIXEL //"Tasa"
				@ nUltLin,a1stRow[2] + 065 MSGET oTxMoeda VAR nTxMoeda 	SIZE 20, 08 OF oDlg PIXEL When .F.
				
				
				nUltLin += 30				
				@ nUltLin,a2ndRow[2] + 004 SAY STR0135 + " " +  SubStr(GetMV("MV_SIMB"+cMoedaC),1,3) SIZE 53,07 OF oDlg PIXEL COLOR CLR_HBLUE //"Valor "
				@ nUltLin,a2ndRow[2] + 065 MSGET oVlEstrang VAR nValEstrang	SIZE 65, 08 OF oDlg PIXEL HASBUTTON Picture PesqPict("SE2","E2_VALOR"); 
				Valid valMndBco(nValEstrang) 
				
				DEFINE SBUTTON FROM 137, 105 TYPE 1  ACTION iif(ValInfoPA(), Processa({|lEnd| fn086Grv(), oDlg:End()},STR0136 ,STR0137,.F.),.F.) ENABLE OF oDlg //"Realizando devolución." // "Procesando..."
				DEFINE SBUTTON FROM 137, 73 TYPE 2  ACTION  oDlg:End() ENABLE OF oDlg
			 
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
		//elimina la marca lógica del documento selccionado
		nPos := aScan(aMarca,{|x| x[1] == TRB->(RECNO())}) 
		If nPos > 0
			aDel(aMarca, nPos)
			aSize(aMarca, Len(aMarca)-1)
		EndIf
		TRB->(RecLock("TRB",.f.))
		TRB->MARK := " "
		TRB->(MsUnlock())
	EndIf
	oMark:oBrowse:REFRESH()
EndIf
RestArea( aArea )

Return lRetSal

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fn086mFk2 ³ Autor ³ Alfredo Medran     ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Actualiza FK2_VALOR y FK2_VLMOE2                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fina080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fn086mFk2(oSubFK2,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco)
Local nDecimal := TamSX3("E2_TXMOEDA")[2]
If oSubFK2 != Nil
	oSubFK2:SetValue( "FK2_VALOR" ,  &cCpoTp)
	oSubFK2:SetValue( "FK2_VLMOE2", Round(xMoeda( &cCpoTp, nMoedaBco , nMoedaTit,,nDecimal,, nTxModTit),2) )
EndIf

return nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fn086mFk5 ³ Autor ³ Alfredo Medran     ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Actualiza FK5_VALOR y FK5_VLMOE2                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fina080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fn086mFk5(oSubFK5,cCpoTp,nMoedaBco,nMoedaTit,nTxModTit,nTxModBco,nJuros)
Local nDecimal := TamSX3("E5_TXMOEDA")[2]
If oSubFK5 != Nil
	oSubFK5:SetValue( "FK5_VALOR" ,&cCpoTp )
	oSubFK5:SetValue( "FK5_VLMOE2", Round(xMoeda( &cCpoTp, nMoedaBco , nMoedaTit,,nDecimal,, nTxModTit),2) )
EndIf

return nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fn086MoeEx ³ Autor ³ Alfredo Medrano   ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  verifica si la moneda titulo es exrangera, para mostrar   ³±±
±±³          ³  E5_VLMOED2 o E5_VALOR                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ finc050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fn086MoeEx(cMoeda, cMoedaBJ, cTipoDoc, cMotBx, cDtMov As Character, cCart As Character)

Local lRet 		 := .F.
Local nMoeda 	 := 0
Default cMoeda   := "1"
Default cMoedaBJ := "1"
Default cTipoDoc := ""
Default cMotBx   := ""
Default cDtMov   := DTOS(DATE())
Default cCart    := "P"

nMoeda := Val(cValToChar(cMoeda))
nMdaBJ := Val(cValToChar(cMoedaBJ))

If cMotBx $ "LIQ|FAT|CMP|DEV|CEC" .And. nMoeda <> nMdaBJ  .And. !Empty(cTipoDoc) .And. !Empty(cMotBx)
	cTipoDoc := AllTrim(cTipoDoc)
	cMotBx   := AllTrim(cMotBx)
	cCart    := AllTrim(cCart)

	// A partir destas datas foram alteradas as gravações dos movimentos (E5_VALOR e E5_VLMOED2) em moeda estrangeira
	// dos processos de fatura, liquidação e compensação CP
	If cCart == "P"
		lRet := ((cDtMov >= "20180413") .Or. (cDtMov >= "20171227" .And. cTipoDoc $ "ES|CP|BA|" .And. cMotBx $ "CMP|CEC|"))
	Else
		lRet := (cDtMov >= "20181129" .And. cTipoDoc $ "BA|CP|ES|VL|" .And. cMotBx $ "CMP|DEV|")
	Endif

	If lRet
		If cTipoDoc $ "CP|BA|ES|VL|" .And. cMotBx  $ "CMP|DEV|CEC"
			// Compensação
			lRet := .T.
		ElseIf cTipoDoc $ "BA|ES" .And. cMotBx $ "LIQ|FAT"
			// Liquidação ou fatura.
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ValInfoPA ³ Autor ³ Alfredo Medran     ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ valida la información agregada para la devolución de PA    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fn086Mark                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ValInfoPA()
Local lRet := .t.
	If !CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.)
		lRet := .F.
	EndIf
	
	If lRet .and. !valMndBco(nValEstrang)
		lRet := .F.
	EndIf
return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fn086Grv ³   Autor ³ Alfredo Medran     ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³procesa la afectación de tablas SEK, SE2, SE5 y FK’s        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fn086Mark                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function fn086Grv()
Local lRet 			:= .T.
Local lPadraoBx 	:= .F.
Local lPadraoVd 	:= .F.
Local lContabiliza 	:= .F.
Local lAdiantamento := .F.
Local lMultNat 		:= .F.
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lAltBord 		:= .F.
Local aCtBaixa		:= {}
Local cMoedaTx 		:= ""
Local nHdlPrv 		:= 0
Local nSalvRec		:=0
Local nA 			:= 0
Local  cContabiliza := GETMV("MV_CTBAIXA") //Opcion de contabilizacion de la baja (C. Pagar)  B = baja, C = al emitir el Cheque o en A =Ambos       
Local nTotal		:=0
Local dDtaAnt       := dDataBase
Local aDiario		:= {}
Local cArquivo      := ""
Local lPadBxPA		:= .F.
//Se inicializan variables privadas utilizadas en la función fa080Grv
private lAglut 		:= lAglutina
private nMulta 		:= 0 
private nJuros 		:= 0 
private nVA 		:= 0 
private nDescont 	:= 0 
private nOtrga 		:= 0 
private nImpSubst 	:= 0 
private nAcresc 	:= 0 
private nDecresc 	:= 0 
private aTxMoedas 	:= {}
private nCM 	  	:= 0
Private nValPgto 	:= 0
private nTotAbat 	:= 0
Private cLoteFin 	:= Space(TamSX3("E2_LOTE")[1])
Private cMarca 		:= ""
Private cPortado	:= "   "
Private cHist070  	:= CriaVar("E5_HISTOR")
Private cNumBor 	:= Space(6)
Private cBenef		:= CriaVar("E5_BENEF")
Private lChqPre		:= .f.
Private cLote 		:= ""


If MSGYESNO(STR0138,STR0139) //"Se realizará la devolución para la baja del PA seleccionado." // "Desea proseguir con la devolución ?"

	If Empty(nTxMoeda)
		nTxMoeda := 0 //evitar erro type mismatch na função xmoeda, quando parâmetro MV_EASYFIN for igual S e a moeda = 2
	EndIf 
	
	//Identifica se contab. deve ocorrer na baixa ou geração de cheques e se
	//o tipo do titulo for PA e existir cheque deve ser contabilizado
	dbSelectArea("SEF")                                                                                            
	dbSetOrder(3) // EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC 
	If SE2->E2_TIPO $ MVPAGANT .and. SEF->(dbseek(xFilial("SEF")+SE2->E2_PREFIXO+SE2->E2_NUM+;
		SE2->E2_PARCELA+SE2->E2_TIPO))
		lContabiliza := .T.
	Else
		lContabiliza := IIf(cContabiliza = "B" .Or. cContabiliza = "A", .T., .F.)
	EndIf
	
	If MovBcoBx(cMotBx, .T.) .and. !ChqMotBx(cMotBx)
		lContabiliza := .T.
	EndIF
	If cContabiliza == "C" .And. !ChqMotBx(cMotBx)
		lContabiliza := .T.
	EndIF
	If SE2->E2_TIPO $ MVPAGANT
		lContabiliza := .T.
	EndIf
	
	nSalvRec 	:= SE2->(RecNO())
	If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
		lAdiantamento := .T.
	EndIf
	//Analisa si el titulo fue gerado a partir de un cheque pre datado
	lChqPre := .f.
	dbSelectArea("SE5")
	dbSetOrder(2) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
	If SE5->(dbSeek( xFilial("SE5") + "CD" + SE2->E2_PREFIXO + ;
			SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + dToS(SE2->E2_EMISSAO )+;
			SE2->E2_FORNECE + SE2->E2_LOJA ))

		lChqPre := .T.
		cBanco   := SE5->E5_BANCO
		cAgencia := SE5->E5_AGENCIA
		cConta   := SE5->E5_CONTA
		cCheque  := SE5->E5_NUMCHEQ
		cBenef   := SE5->E5_BENEF
		cHist070 := SE5->E5_HISTOR
	EndIf
	
	
	If Empty(cBenef) // se obtiene el nombre del proveedor que fungirá como veneficiario
		dbSelectArea("SA2")
		dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
		If SA2->(dbSeek(xFilial("SA2",SE2->E2_FILORIG)+SE2->E2_FORNECE+SE2->E2_LOJA))
			cBenef   := Padr(SA2->A2_NREDUZ,TamSx3("EF_BENEF")[1])
		Endif
	Endif
	
	cPortado	 := SE2->E2_PORTADO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Monta Hist¢rico da Baixa para digitação pelo usuario					?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	cHist070 := Criavar("E5_HISTOR")		//Inicilizador padrao
	If Empty(cHist070)
		cHist070 := STR0140 + Space(Len(cHist070)-20) 	//"Valor pago s/ Titulo"
	Endif
	
	cNumBor	:= SE2->E2_NUMBOR
	cMarca  := cMarcaT

	//obtiene las monedas y las tasas del dia
	Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
	For nA	:=	2	To MoedFin()
		cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
		If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
			Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
		Else
			Exit
		Endif
	Next
	
	nMoedaBco:=Iif(nMoedaBco>0,nMoedaBco,1)
	
	nValPgto := nValEstrang

	nSalTit := Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2) //Converte o saldo do titulo a moeda 1.
	
	If SE2->( Deleted() ) //valida que el registro no este borrado
		nOpc1 := 0
		lRet  := .F.
		Help( " " , 1 , "RECNO" )
		Return lRet /*Function fA080Tit*/
	EndIf
	//Asiento estandar para Bajas
	cPadrao:="530"
	lPadraoBx := VerPadrao(cPadrao) .And. lContabiliza
	lPadraoVd := VerPadrao( "518" ) .And. lContabiliza
	lPadBxPA  := VerPadrao( "514" ) .And. lContabiliza

	cLanca :=  IIf(!Empty(SEK->EK_LA), "S", "N") // Asiento estandar Online
	
	Begin Transaction
	
		aAreaSA2 := SA2->(GetArea())
	    // fina080 - fa080Grv - funcion utilizada para guardado de tablas SEK, SE2, SE5 y FK’s 
		lBaixou := fa080Grv(lPadraoBx,lPadraoVd,.F.,cLanca, ,nTxMoeda,dDebito,,lMultNat,lUsaFlag,lAltBord,@aCtBaixa)
				
		If !lBaixou
			DisarmTransaction()
			Break
		EndIf

		RestArea(aAreaSA2)

		If lAltBord .and. !Empty(cNumBor)
			FaGrvActBd(cNumBor,cPort240,cAgen240,cConta240,dDataBord,cModPgto,cTipoPag)
		Endif

		//Reposiciono o arquivo de fornecedores para a contabilizacao
		SA2->(dbSetOrder(1))  //A2_FILIAL+A2_COD+A2_LOJA
		SA2->(MsSeek(xFilial("SA2",SE2->E2_FILORIG)+SE2->E2_FORNECE+SE2->E2_LOJA))

		//Reposiciono o arquivo de BANCOS para a contabilizacao
		SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON                                                                                                                           
		SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))

		//Grava os lancamentos nas contas orcamentarias SIGAPCO
		PcoDetLan("000005","01","FINA086")

		//Finaliza a gravacao dos lancamentos do SIGAPCO
		PcoFinLan("000005")

		If lBaixou
			PABrtComp(.T.)
			// verifica si el titulo fue saldado completamente para marcar las tablas SEK y TRB
			If ROUND(SE2->E2_SALDO,2) + ROUND(SE2->E2_SDACRES,2)  == 0
				F086ActSEK(SEK->EK_ORDPAGO)

	            RecLock("TRB",.F.)
	            	Replace CANCELADA With "S"
                MsUnLock()
			EndIf
			F086ActPA(SE2->E2_NUM,SE2->E2_FORNECE,SE2->E2_EMISSAO,SE2->E2_PREFIXO,xMoeda(nValPgto,nMoedaBco,SE2->E2_MOEDA,dBaixa,3,nTxMoeda) ,SE2->E2_LOJA)
		EndIf

	End transaction 
	//Fin transacción de grabación	
		
		
	If lBaixou
		//Inicia transação contábil 
		Begin Transaction
			If cLanca == "S" 
				dbSelectArea("SX5")
				dbSetOrder(1)// X5_FILIAL+X5_TABELA+X5_CHAVE 
				If MSSeek(xFilial()+"09FIN")   
					cLote:=IIF(Found(),Trim(X5DESCRI()),"FIN")
				EndIf                                                                                                                                 
			Endif
			If  (lPadraoBx .or. lPadraoVd) .and. cLanca == "S" 
				//Inicializa Lancamento Contabil
				nHdlPrv := HeadProva( cLote, "FINA080" /*cPrograma*/, Substr(cUsuario,7,6), @cArquivo )
			Endif

			If lPadraoBx .and. cLanca == "S" 
			  	If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
                    aAdd( aFlagCTB, {"EK_LA", "C", "SEK", SEK->( Recno() ), 0, 0, 0} )
                Else
                    RecLock("SEK",.F.)
                    Replace EK_LA With "C"
                    MsUnLock()
                EndIf
				dDataBase := dBaixa
				nTotal += DetProva(nHdlPrv, cPadrao, "FINA086" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/,;
				/*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
				dDataBase := dDtaAnt
			Endif


			IF (lPadraoBx .or. lPadraoVd ) .and. cLanca=="S" .and. lBaixou
				//-- Se for rotina automatica força exibir mensagens na tela, pois mesmo quando não exibe os lançametnos, a tela
				//-- sera exibida caso ocorram erros nos lançamentos padronizados

				If UsaSeqCor()
					cCodDiario := CTBAVerDia()
					aAdd(aDiario,{"SE5",SE5->(RecNo()),cCodDiario,"E5_NODIA","E5_DIACTB"})
				Else
					aDiario := {}
				EndIf

				If lContabiliza .And. cLanca=="S" .And. nHdlPrv != 0
					//Efetiva Lan‡amento Contabil
					dDataBase := dBaixa
					cA100Incl(cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita, lAglut, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario)
					dDataBase := dDtaAnt
				EndIf

				aFlagCTB := {}//Limpa o coteudo apos a efetivacao do lancamento	
			Endif
		End Transaction
	EndIf
	
	If lBaixou .And. lRet .And. lPadBxPA .And. cLanca == "S"
		aDiario		:= {}
		cArquivo	:= ""
		cLote		:= ""
		//Inicia transaccion contable
		Begin Transaction
			LoteCont( "FIN" )
			IF lPadBxPA
				nHdlPrv := HeadProva( cLote, "FINA086" /*cPrograma*/, Substr(cUsuario,7,6), @cArquivo )
				// Prepara Lancamento Contabil
				If lUsaFlag  // Almazena en aFlagCTB para atualizar en modulo Contable
					aAdd( aFlagCTB, {"EK_LA", "S", "SEK", SEK->( Recno() ), 0, 0, 0} )
				Endif
				nTotal := DetProva( nHdlPrv			, "514"			, "FINA086" /*cPrograma*/	, cLote				, /*nLinha*/	,;
									/*lExecuta*/	, /*cCriterio*/	, /*lRateio*/				, /*cChaveBusca*/	, /*aCT5*/		,;
									/*lPosiciona*/	, @aFlagCTB		, /*aTabRecOri*/			, /*aDadosProva*/ )
			EndIf

			If  UsaSeqCor()
				cCodDiario := CTBAVerDia()	
				aAdd(aDiario,{"SE5",SE5->(RecNo()),cCodDiario,"E5_NODIA","E5_DIACTB"})
			EndIf

			If nTotal > 0
				// Envia para Lanzamiento Contable
				cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita, lAglut, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario )
				aFlagCTB := {}  // Limpa el contenido despues de finalizar el lanzamiento
			EndIf
		End Transaction
	EndIf

	If lBaixou
		MsgInfo(STR0141)//"Baja finalizada con exito." 
		lRetSal := .T.
	EndIf
	
EndIf
return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ obtMndaBco ³  Autor ³ Alfredo Medran   ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³obtiene la moneda y tasa del banco seleccionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fn086Mark                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function obtMndaBco(cBanco,cAgencia,cConta)
Local aArea 	:= GetArea()
default cBanco 	:= ""
default cAgencia:= ""
default cConta	:= ""
	
	dbSelectArea("SA6")
	DbSetOrder(1)//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON                                                                                                                           
	If SA6->(MSSEEK(xFilial("SA6")+cBanco+cAgencia+cConta))
		nMoedaBco:= Max(SA6->A6_MOEDA,1)
		cMoeda := AllTrim(Str(nMoedaBco))
		cMoedaC := cMoeda
		nTxMoeda := RecMoeda(dBaixa, cMoeda)
	Else
		cMoeda := "1"
		nTxMoeda := 1
		nMoedaBco := 1
	EndIf
	
RestArea( aArea )
return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ valMndBco ³  Autor ³ Alfredo Medran    ³ Data ³ 29/07/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³valida valor de devolución dependiendo la moneda del banco  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fn086Mark                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function valMndBco(nVal)
Local lRet 		:= .T. 
Local nValPadrao:= 0
Default nVal 	:= 0

	If nVal > 0
		nValPadrao := Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoedaBco,SE2->E2_EMISSAO,nCentMd1+1),nCentMd1+1),nCentMd1)
		if  nVal > nValPadrao
			msginfo(STR0142)//"El valor informado es mayor al valor del documento a cancelar."
			lRet := .F. 
		EndIf
	ElseIf nVal <= 0
			msginfo(STR0143)//"El valor informado debe se mayor a 0."
			lRet := .F. 
	EndIf
Return lRet


Static Function lRetCkPG(n,cDebInm,cBanco,nPagar)
	Local lRetCx:=.T.
	If cPaisLoc == "PER"
		If n == 3
			If cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
				lRetCx:=.F.
			Endif
		Endif
	Endif
Return(lRetCx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a086checkTºAutor  ³Microsiga           ºFecha ³  04/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apaga os titulos gerados para retencoes/recolhimento de    º±±
±±º          ³ impostos.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a086checkTX()

	Local lRet			:= .T.
	Local cAgente		:= GETMV("MV_AGENTE")
	Local cFornec		:= ""
	Local cNum			:= ""
	Local cFilSE2		:= ""
	Local cPrefixo		:= ""
	Local cNumOP		:= ""
	Local cFornece		:= ""
	Local cLoja			:= ""
	Local lIrRet        := .F.
	Local lTitTx        := .F.
	Default lOPRotAut	:= .F.

	cNumOP		:= Iif( lOPRotAut, cNumOrdPg,	TRB->NUMERO 	 )
	cFornece	:= Iif( lOPRotAut, cForOP, 		TRB->PROVEEDOR )
	cLoja		:= Iif( lOPRotAut, cFilForOP,	TRB->SUCURSAL  )

	If cPaisLoc=="PAR"

		DbSelectArea("SA2")
		dBSetOrder(1)
		DbSeek(xFilial("SA2")+cFornece+cLoja)
		If SA2->A2_PAIS <> "586" .And. !Empty(SA2->A2_PAIS)
			cPrefixo:= "EXT" // Fornecedor do tipo exterior
		ElseIf (Subs(cAgente,1,1) == "E")
			cPrefixo:="EXP"  // Agente Exportador
		ElseIf (Subs(cAgente,1,1) == "D")
			cPrefixo:="DES"  // Agente Designado
		EndIf

		DbSelectArea("SE2")
		dBSetOrder(1)
		If DbSeek(xFilial("SE2")+cPrefixo+cNumOP)
			While SE2->(!Eof() .AND. E2_FILIAL == xFilial("SE2") )  .And. lRet
				If  cNumOP == Alltrim(SE2->E2_NUM) .And. SE2->E2_PREFIXO == cPrefixo .And. SE2->E2_TIPO == "TX " .And. !Empty(SE2->E2_BAIXA)
					If lOPRotAut
						cTxtRotAut += STR0104 + STR0105 + CRLF + CRLF
					Else
						MsgAlert(STR0104 + STR0105)
					EndIf
					lRet:=.F.
				EndIf
				SE2->(DBSkip())
			EndDo
		EndIf
	ElseIf cPaisLoc == "PER"
		lRet := .T.
		cFornec := GetMV("MV_UNIAO",.T.,"FISCO")
		cFornec := Padr(cFornec,TamSX3("A2_COD")[1])
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(xFilial("SA2") + cFornec))
			SE2->(DbSetOrder(6))
			cFilSE2 := xFilial("SE2")
			cNum := Padr(cNumOP,TamSX3("E2_NUM")[1])
			If SE2->(DbSeek(xFilial("SE2") + cFornec + SA2->A2_LOJA + Space(Len(SE2->E2_PREFIXO)) + cNum))		//o prefixo sempre e deixado em branco (ver fina085a - f085titimp)
				While !(SE2->(Eof())) .And. (SE2->E2_FILIAL == cFilSE2) .And. (SE2->E2_FORNECE == cFornec) .And. (SE2->E2_LOJA == SA2->A2_LOJA) .And. (SE2->E2_NUM == cNum) .And. lRet
					lRet := Empty(SE2->E2_BAIXA)
					lIrRet := Iif( !lIrRet .And. !lRet,SE2->E2_TIPO $ "IR-",.F.)
					lTitTx := Iif( !lTitTx .And. !lRet,SE2->E2_TIPO $ "TX",.F.)
					SE2->(DbSkip())
				Enddo
				If !lRet
					If lOPRotAut
						If lTitTx
							cTxtRotAut += STR0104 + STR0105 + CRLF + CRLF
						EndIf
						if lIrRet
							cTxtRotAut += STR0146 + STR0147 + CRLF + CRLF
						Endif
					Else
						If lTitTx
							MsgAlert(STR0104 + STR0105)
						EndIf
						if lIrRet
							MsgAlert(STR0146 + STR0147)
						Endif
					EndIf
				Endif
			Endif
		Endif
	EndIf
	
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA086PMS   ³ Autor ³Jandir Deodato         ³ Data ³04/09/12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida se o PA da OP está apropriado no Totvs Obras e Projetos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA086PMS()

	Local aArea		:={}
	Local aAreaSE2	 	:={}
	Local aAreaAFR		:={}
	Local cAliasTMP
	Local lRet:=.T.
	
	aArea:=GetArea()
	
	dbSelectArea("SE2")
	aAreaSE2:=SE2->(GetArea())
	SE2->(dbSetOrder(1))//FILIAL+PREFIXO+NUM+PARCELA+TIPO+FORNECEDOR+LOJA
	dbSelectArea("AFR")
	aAreaAFR:=AFR->(GetArea())
	AFR->(dbSetOrder(2))//FILIAL+PREFIXO+NUM+PARCELA+TIPO+FORNECEDOR+LOJA+PROJETO+REVISAO
	cAliasTMP:=GetNextAlias()
	If SE2->(dbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA))
		If AFR->(dbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA))
			cQuery:="SELECT AFR_VIAINT FROM " +RetSqlName("AFR")
			cQuery+=" WHERE AFR_FILIAL = '"+xFilial("AFR") + "' AND AFR_PREFIX ='"+SEK->EK_PREFIXO+"' AND AFR_NUM ='"+SEK->EK_NUM+"'"
			cQuery+=" AND AFR_PARCEL='"+SEK->EK_PARCELA+"' AND AFR_TIPO='"+SEK->EK_TIPO+"' AND AFR_FORNEC='"+SEK->EK_FORNECE+"'"
			cQuery+=" AND AFR_LOJA='"+SEK->EK_LOJA+"' AND D_E_L_E_T_ =' ' "
			cQuery:=ChangeQuery(cQuery)
			If Select(cAliasTMP)>0
				(cAliasTMP)->(dbCloseArea())
			EndIf
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .T., .T.)
			(cAliasTMP)->(dbGoTop())
			While (cAliasTMP)->(!EOF()) .and. lRet
				If (cAliasTMP)->AFR_VIAINT=='S'
					lRet:=.F.
					Help( " ", 1, "PMSXTOP",, OemToAnsi(STR0107)+" "+"("+SEK->EK_TIPO+")"+" "+rTrim(SEK->EK_NUM)+" " +OemToAnsi(STR0108)+CRLF+OemToAnsi(STR0109), 1, 0 )//O Título + "vinculado a esta ordem de pago esta apropriado  no Totvs Obras e Projetos." +"Desfaça a apropriação no TOP antes de cancelar a OP"
				Endif
				(cAliasTMP)->(dbSkip())
			EndDo
			(cAliasTMP)->(dbCloseArea())
			If lRet
				PMSWriteFI(2,"SE2")//extorno
				PMSWriteFI(3,"SE2")//exclusao
			Endif
		Endif
	Endif
	RestArea(aAreaAFR)
	RestArea(aAreaSE2)
	RestArea(aArea)
	
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValidCH   ³ Autor ³Ramon Teodoro          ³ Data ³23/04/13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida a permissão da O.P. para o cancelamento, caso exista  ³±±
±±³ algum cheque relacionado que esteja baixado, exibe o help              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidCH(cAlias)
	Local lRetorna := .T.

	If (cAlias)->PODE == "N"

		Help( " ",1,"FINA086" )

		lRetorna := .F.
	EndIf

	If lRetorna
		lMarca := ((cAlias)->MARK== cMarcaTR)
		TRB->MARK := If(lMarca,"",cMarcaTR)
	EndIf

Return lRetorna


/*{Protheus.doc} F086VerOP
Validação da OP para exclusão.

@author Lucas de Oliveira
@since 07/04/2014
@version 1.0
*/
Function F086VerOP()

	Local cFornePg
	Local cLojaPg
	Local cPode		:= ""
	Local cOrdAnt
	Local nTB			:= 0
	Local nTR			:= 0
	Local nDe			:= 0
	Local nRe			:= 0
	Local cSituacao	:= "01"
	Local cPgtoElt		:= ""
	Local aRegs		:= {}
	Local lCanPar		:= .F.
	Local aRet			:= {}
	Local lCompensa		:= .F. 
	Local lVinculo		:= .F.
	Local lDispon		:= .F.
	Local lDescOP		:= .F.
	Local cIR           := "IR-"
	Local lVldCTB       := .F.
	Local dDataFin      := GetMV("MV_DATAFIN")

	If Type("lOrdRet") == "U"
		lOrdRet := .F.
	EndIf

	If Type("lTitRet") == "U"
		lTitRet := .F.
	EndIf

	DbSelectArea("SEK")
	cOrdAnt	:= EK_ORDPAGO
	Do While EK_ORDPAGO == cOrdAnt .And. !EOF()
		IncProc()

		If  (cPaisLoc=="ARG" .OR. lOrdRet .OR. AllTrim(EK_TIPO)<>"TF" ) .and. !(lFilCanc .And. ( (cPaisLoc <> "CHI" .and. EK_CANCEL ) .or. (cPaisLoc == "CHI" .and. !EK_CANCEL .and. !Empty(SEK->EK_CANPARC)) ))

			If EK_TIPODOC=="TB"
				If Alltrim(EK_TIPO)$("PA"+MV_CPNEG)
					nDe	+=	IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
				Elseif EK_TIPO $ MVABATIM .And. (cPaisLoc $ "PER|EQU" .And. !(EK_TIPO == cIR))
					nRe	+=	IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
				ElseIf cPaisLoc $"DOM|COS"
					nTB	+=	IIf(MV_par06==1,EK_VALORIG,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
					nDe	+=	IIf(MV_par06==1,EK_VALORIG - EK_VALOR,xMoeda(EK_VALORIG - EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
					nDe +=  IIf(MV_par06==Val(EK_MOEDA),EK_DESCONT,xMoeda(EK_DESCONT,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
				Else
					nTB	+=	IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
					nDe +=  IIf(MV_par06==Val(EK_MOEDA),EK_DESCONT,xMoeda(EK_DESCONT,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
					lDescOP := Iif(cPaisLoc == "ARG" .And. EK_DESCONT > 0,.T.,.F.)
				Endif
			ElseIf EK_TIPODOC=="RG"
				nTR	+=	IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
			Elseif EK_TIPODOC=="PA"
				nTB	+= IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
			Elseif EK_TIPODOC=="DE"
				nTB	+= IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
			ElseIf EK_TIPODOC	==	"CP".And.EK_TIPO<>"VC "
				If cPaisLoc <> "BRA"
					If !Empty(EK_FORNEPG)
						cFornePg	:= EK_FORNEPG
						cLojaPg	:= EK_LOJAPG
					Else
						cFornePg	:= EK_FORNECE
						cLojaPg	:= EK_LOJA
					Endif
					If lOrdRet
						nTB	+=	IIf(MV_par06==1,EK_VLMOED1,xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
						nDe +=  IIf(MV_par06==Val(EK_MOEDA),EK_DESCONT,xMoeda(EK_DESCONT,Max(Val(EK_MOEDA),1),mv_par06,EK_DTDIGIT,nDecs+1))
						lOrdRet := .F.
					EndIf
				Else
					cFornePg	:= EK_FORNECE
					cLojaPg	:= EK_LOJA
				EndIf

				DbSelectArea("SE2")
				DbSetOrder(6)
				MsSeek(xFilial("SE2")+cFornePg+cLojaPg+SEK->EK_PREFIXO+;
				SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO,.F.)
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Quando o cliente tiver feito cancelamento parcial da ordem de³
				³pago nao podera cancela-la ate desfaze-lo Bops 68189.        ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ**/
				If !lCanPar
					If cPode <>"N"
						If !SE2->(Found())
							cPode := ""
						Else
							cPode := If(SE2->E2_VALOR==SE2->E2_SALDO,"","N")
						Endif
					EndIf
				EndIf

				//Controle de Conc. Bancária
				If cPaisLoc <> "BRA"
					aAdd(aRegs,{SEK->EK_PREFIXO,SEK->EK_NUM,SEK->EK_PARCELA,SEK->EK_TIPO,SEK->EK_FORNECE,SEK->EK_LOJA,SEK->EK_BANCO,SEK->EK_AGENCIA,SEK->EK_CONTA})
				EndIf

			Endif
			If (cPaisLoc == "CHI" .Or. cPaisLoc == "BRA") .And. !Empty(SEK->EK_CANPARC)
				cPode	:= "N"
				lCanPar	:= .T.
			EndIf
			If (!Empty(SEK->EK_DTREC) .and. cLibOrd=="S")
				cPode:= "N"
			Endif
			If dDataFin >= SEK->EK_DTDIGIT
				cPode:= "N"
			Endif
			If cPaisLoc == "ARG"
				If !lVldCTB .And. cPode <> "N"
					If !CtbValiDt(,SEK->EK_DTDIGIT,,,,{"FIN001"},)
						cPode:= "N"
					Endif
					lVldCTB := .T.
				EndIf
			Else
				If cPode <> "N" .And. !CtbValiDt(,SEK->EK_DTDIGIT,,,,{"FIN001"},)
					cPode:= "N"
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se o documento foi ajustado por diferencia ³
			//³de cambio com data posterio a OP                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cPaisLoc == "ARG" .And. SEK->EK_TIPODOC <> "RG") .Or. (cPaisLoc $ "RUS")
				SIX->(DbSetOrder(1))
				If SIX->(DbSeek('SFR'))
					DbSelectArea('SFR')
					DbSetOrder(1)
					MsSeek(xFilial()+"2"+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA+Dtos(SEK->EK_DTDIGIT),.T.)
					If FR_FILIAL==xFilial() .And.	FR_CHAVOR==SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA.And.;
					SEK->EK_DTDIGIT <= SFR->FR_DATADI
						cPode	:=	'N'
					Endif
				Endif
			Endif

			If cPaisLoc <> "BRA"
				If SEK->EK_TIPODOC == "CP" .and. AllTrim(SEK->EK_TIPO) == "CH"
					//Verificar Status do Cheque para verificar se é possível cancelar a Ordem de Pago.
					cSituacao := "01"
					SEF->(dbOrderNickName("EQU09"))
					If SEF->(MsSeek(xFilial("SEF")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+SEK->EK_ORDPAGO))
						While ! SEF->(Eof()).and. cOrdAnt== AllTrim(SEK->EK_ORDPAGO)  ;
							.and. SEF->EF_BANCO	 == SEK->EK_BANCO ;
							.and. SEF->EF_AGENCIA	 == SEK->EK_AGENCIA ;
							.and. SEF->EF_CONTA	 == SEK->EK_CONTA ;
							.and. AllTrim(SEF->EF_TITULO) == AllTrim(SEK->EK_ORDPAGO)
								If SEF->EF_STATUS == "02"		//Cheque Vinculado.
									lVinculo := .T.
								ElseIf SEF->EF_STATUS == "03" .and. SEF->EF_IMPRESS =="S"	//Cheque Emitido.
									lDispon	:= .T.
								ElseIf SEF->EF_STATUS == "04"	//Cheque Compensado.                     	 	
									lCompensa := .T.
								EndIf
								SEF->(dbSkip())
						EndDo
						Do Case
							Case lCompensa .and. !lVinculo .and. !lDispon // Apenas cheques ja compensados.
								cSituacao := "04"

							Case !lCompensa .and. lVinculo .and. !lDispon // Apenas cheques vinculados.
								cSituacao := "03"

							Case !lCompensa .and. !lVinculo .and. lDispon // Apenas cheques disponiveis para anulação. 
								cSituacao := "01"

							Case !lCompensa .and. lVinculo .and. lDispon // Tendo cheques vinculados e disponiveis para anulação.
								cSituacao := "03"

							Case lCompensa .and. !lVinculo .and. lDispon // Tendo cheques compensados e disponiveis para anulação.
								cSituacao := "04"

							Case lCompensa .and. lVinculo .and. !lDispon // Tendo cheques compensados e vinculados.
								cSituacao := "04"

							Case lCompensa .and. lVinculo .and. lDispon // Possuindo os tres tipos Compensados, vinculados e disponiveis para anulação
								cSituacao := "04"

							Otherwise // Caso não ache nenhuma situação utiliza 01.
								cSituacao := "01"
                    	EndCase

					EndIf
				EndIf
			EndIf

			If AllTrim(SEK->EK_TIPODOC) == "TB" .And. AllTrim(SEK->EK_TIPO) == "NF" .And. cPaisLoc=="CHI" .And. Empty(aRegs)
				aAdd(aRegs,{SEK->EK_PREFIXO,SEK->EK_ORDPAGO,SEK->EK_PARCELA,SEK->EK_TIPO,SEK->EK_FORNECE,SEK->EK_LOJA,SEK->EK_BANCO,SEK->EK_AGENCIA,SEK->EK_CONTA})
			EndIf

			//Verificar Status das Retenções para verificar se é possível cancelar a Ordem de Pago.
			If lTitRet .And. SEK->EK_TIPODOC == "RG" .And. cPaisLoc == "ARG"
				If xPsqSE2TX()
					cSituacao	:= "05"
				EndIf
			EndIf

			If lOPRotAut
				If	!Empty(SEK->EK_CANPARC)
					cSituacao	:= "1000"	//Cancelamento parcial.
				ElseIf	(!Empty(SEK->EK_DTREC) .AND. Alltrim(GetMV("MV_LIBORD")) == "S")
					cSituacao	:= "1001"	//OP já liberada.
				ElseIf	dDataFin >= SEK->EK_DTDIGIT
					cSituacao	:= "1002"	//A data de digitação da OP é menor ou igual à data limite para movimentações financeiras.
					cPode		:= "N"
				ElseIf	!CtbValiDt(,SEK->EK_DTDIGIT,,,,{"FIN001"},)
					cPode		:= "N"
				ElseIf cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG" .AND. cOrdAnt == SFR->FR_ORDPAG
					cSituacao	:= "1003"	//A OP possui ajuste de câmbio.
				EndIf
			EndIf

			//Ordem de Pago em Lote
			If cPaisLoc == "ARG" .And. cSituacao <> "07"
				dbSelectArea("FJB")
				FJB->(dbSetOrder(1))
				If FJB->(MsSeek(xFilial("FJB")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+SEK->EK_NUMLOT))
					If (FJB->FJB_STATUS $ "1|3|4|6")
						dbSelectArea("FJC")
						FJC->(dbSetOrder(1))
						If FJC->(MsSeek(xFilial("FJC")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA+SEK->EK_NUMLOT+SEK->EK_ORDPAGO))
							If FJC->FJC_STATUS == "1" //Ativa
								cSituacao 	:= "07"
								cPode		:= "N"
							EndIf
						EndIf
					EndIf
				EndIf

				If SEK->EK_PGTOELT == "1" .And. Empty(cPgtoElt)
					cPgtoElt := "S"
				EndIf
			EndIf

		EndIf

		//Conciliação Bancária
		If cPaisLoc <> "BRA"
			If F472VldConc(aRegs)
				cSituacao := "06"
			EndIf
		EndIf

		DbSelectArea("SEK")
		SEK->(dbSkip())

	EndDo

	aAdd( aRet, {;
	{ "Permissão para exclusão"		, cPode 		},;
	{ "Situação da ordem de pago"	, cSituacao	},;
	{ "Pgto. Eletrônico"				, cPgtoElt		},;
	{ "Desconto"						, nDE , lDescOP	},;
	{ "Valor pago"						, nTB			},;
	{ "Abatimentos"					, nRE			},;
	{ "Retenções"						, nTR			};
	} )

Return aRet

/*{Protheus.doc} F086RotAut
Rotina Automática para exclusão da OP.

@author Lucas de Oliveira
@since 07/04/2014
@version 1.0
*/
Function F086RotAut()

	Local	aVerOP
	Private lTitRet		:=	GetNewPar("MV_TITRET",.F.)

	aVerOP	:= F086VerOP()

	If aVerOP != Nil .AND. Len(aVerOP) > 0
		lRet	:=	Fa086Cancel()
	EndIf

Return lRet
/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ ObtPreOrd  ³Autor ³ Laura Medina        ³ Fecha ³28/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Funcion para obener el numero de pre-orden de pago que le  ³±± 
±±³           ³ corresponde al documento en proceso.                       ³±± 
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtPreOrd(cOrdPag) 
Local cAliasQry	:= GetNextAlias()    
Local cQuery 		:= ""
Local cPreOrd		:= Space(TamSx3("E2_PREOP")[1])

cQuery := "SELECT FJL_PREOP "
cQuery += "FROM " + RetSqlName("FJL")+ " FJL, " + RetSqlName("FJK")+ " FJK "
cQuery += "WHERE FJK_ORDPAG ='"+ cOrdPag +"' AND "
cQuery += "FJK_FORNEC ='"+ E2_FORNECE +"' AND "
cquery += "FJK_LOJA   ='"+ E2_LOJA +"' AND "
cQuery += "FJK_PREOP  = FJL_PREOP AND "
cQuery += "FJL_PREFIX ='"+ E2_PREFIXO +"' AND "
cQuery += "FJL_NUM    ='"+ E2_NUM +"' AND "
cquery += "FJL_FORNEC ='"+ E2_FORNECE +"' AND "
cquery += "FJL_LOJA   ='"+ E2_LOJA +"' AND "
cquery += "FJL_TIPO   ='"+ E2_TIPO +"' AND "
cQuery += "FJL_FILIAL='" +XFILIAL("FJL") + "' AND "
cQuery += "FJK_FILIAL='" +XFILIAL("FJK") + "' AND "
cQuery += "FJL.D_E_L_E_T_<>'*' AND "
cQuery += "FJK.D_E_L_E_T_<>'*'   "

cQuery := ChangeQuery(cQuery)

If Select(cAliasQry)>0
	(cAliasQry)->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

DbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
If (cAliasQry)->(!Eof())
	 cPreOrd := (cAliasQry)->FJL_PREOP
	(cAliasQry)->(dbSkip())
Endif

(cAliasQry)->( dbCloseArea() )

Return cPreOrd    

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CancDifCam ³ Autor ³Raúl Ortiz Medina     ³ Data ³12/03/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida si existe diferencia de cambio para el documento y    ³±±
±±³ 	      ³realiza la baja del documento de diferencia de cambio        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³No recibe parámetro                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CancDifCam()
Local aArea 	 := GetArea()
Local aAreaTRB := TRB->(GetArea())
Local aAreaSE5 := SE5->(GetArea())

	SIX->(DbSetOrder(1))
	If SIX->(MsSeek('SFR'))
		DbSelectArea('SFR')
		DbSetOrder(1)
		If SFR->(MsSeek(xFilial()+"2"+PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA, len(SFR->FR_CHAVOR)),.T.))
			While SFR->FR_FILIAL==xFilial("SFR") .And.	SFR->FR_CHAVOR==PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA, len(SFR->FR_CHAVOR))
				If SFR->FR_ORDPAG ==  SEK->EK_ORDPAGO
					SE2->(DbSetOrder(1))
					If SE2->(MsSeek(xFilial("SE2")+SFR->FR_CHAVDE))
						FA084Dele(SE2->(RECNO()),SFR->(RECNO()))
					EndIf
				EndIf
				SFR->(DbSkip())
			Enddo
		Endif
	Endif

RestArea(aArea)
RestArea(aAreaTRB)
RestArea(aAreaSE5)

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelSE2PA     Autor:  Totvs        		¦ Data ¦ 27.12.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Excluir registros deo tipo PA						      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦  		                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function xDelSE2PA()

Local aTpAd := {"PA "}
Local cPrefixo := CriaVar("E2_PREFIXO")
Local nX		 := 0

DbSelectArea("SE2")
SE2->(dbSetOrder(1))

For nX := 1 to Len(aTpAd)
	If SE2->(dbSeek(xFilial("SE2")+PadR(SEK->EK_PREFIXO,TamSX3("E2_PREFIXO")[1]) + PadR(SEK->EK_ORDPAGO,TamSX3("E2_NUM")[1],"")))
		Do While (xFilial("SE2") == SE2->E2_FILIAL .And. aTpAd[nX] == SE2->E2_TIPO .And. AllTrim(SEK->EK_ORDPAGO) == AllTrim(SE2->E2_NUM))
			If cPaisLoc == "ARG"
				nSinal	:=	IIf(E2_TIPO$MV_CPNEG+"/"+MVPAGANT,-1,1)
				SA2->(DbSetOrder(1))
				If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
					SA2->(DbSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
				Else
					SA2->(DbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA))
				Endif
				RecLock("SA2",.F.)
				SA2->A2_SALDUP 	:= SA2->A2_SALDUP  - SE2->E2_VLCRUZ * nSinal
				SA2->A2_SALDUPM	:= SA2->A2_SALDUPM - xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,Val(GetMv("MV_MCUSTO")),SEK->EK_EMISSAO) * nSinal
				MsUnLock()
			EndIf
			RecLock("SE2",.F.)
			SE2->(DbDelete())
			SE2->(MsUnLock())
			SE2->(DbSkip())
		EndDo
	EndIf
Next nX

Return


/*/{Protheus.doc} xValOrd
Función que valida si la orden de pago cuenta con un solo registro en la tabla SEK
que corresponde a una retención.
@type
@author eduardo.manriquez
@since 28/07/2021
@version 1.0
@param cNumOrd , caracter , Numero de la orden de pago
@return lRet , boolean , .T. - Si solo cuenta con un registro de retención
@example
 xValOrd(cNumOrd)
@see (links_or_references)
/*/
Static Function xValOrd(cNumOrd)

	Local lRet        := .F.
	Local nReg        := 0
	Local aArea       := GetArea()
	Local cSEKRet     := GetNextAlias()

	
	Default cNumOrd    := ""

	BeginSQL Alias cSEKRet
		SELECT EK_NUM
		FROM %Table:SEK% SEK
		WHERE SEK.EK_ORDPAGO = %Exp:cNumOrd% AND SEK.EK_FILIAL= %xfilial:SEK% 
		AND SEK.%NotDel%
	EndSQL
	Count to nReg
	If nReg == 1
		lRet := .T.
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} xSE2Ret
Función que realiza el salto a la cuenta por pagar correspondiente a la retención
pagada en la orden de pago.
@type
@author eduardo.manriquez
@since 28/07/2021
@version 1.0
@param cFil , caracter , Filial de la tabla SE2
@return lRet , boolean , .T. - Si encuentra la cuenta por pagar, .F. - No encuentra la Cuenta por pagar
@example
 xSE2Ret(cFil)
@see (links_or_references)
/*/
Static Function xSE2Ret(cFil)

	Local lRet        := .F.
	Default cFil      :=xFilial("SE2")

	DbSelectArea("SE2")
	SE2->(dBSetOrder(8)) // E2_FILIAL+E2_ORDPAGO
	If SE2->(DbSeek(cFil+SEK->EK_ORDPAGO,.F.))
		lRet := .T.
	Endif
Return lRet

/*/{Protheus.doc} LxMetFS015
Metríca para verificar cantidad de anulaciones de OP por tipo (Si son de retenciones o combinadas) por  país por empresa
@type
@author Alfredo.Medrano
@since 29/11/2021
@version 1.0
@example
LxMetFS086()
@see (links_or_references)
/*/
Static Function LxMetFS086(cTipo)
	Local cIdMetric	  := ""
	Local cSubRoutine := ""
	Local lMetVal     := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	Local cAutomato   := IIf(GetRemoteType() == 5 .OR. IsBlind(), "_auto", "") //Si es ejecución automática con TIR agrega identificador
	Local cRotina := "FINA086"
	Default cTipo := ""
	If lMetVal .and. !Empty(cTipo)
		
		cSubRoutine :=  "anulacion_op_" + cTipo + "_" + cPaisLoc + cAutomato
		cIdMetric	:= "financiero-protheus_cantidad-de-anulaciones-de-op-por-tipo-por-pais-por-empresa_total"
		FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, 1,/*dDate*/, /*nLapTime*/,cRotina)
	EndIf

Return Nil


/*/{Protheus.doc} F086ActPA
Función que actualiza el valor total del PA con el monto devuelto del PA
@type
@author veronica.flores
@since 08/12/2021
@version 1.0
@param cNumOP 	, caracter 	, Numero de la orden de pago
@param cFornec 	, caracter 	, Codigo del Proveedor de la orden de pago
@param dEmision , data		, Fecha de emision de la orden de pago
@param cPrefixo , caracter	, Prefijo de la orden de pago
@param nValDev	, numerico	, Valor devuelto del PA
@param cTienda	, caracter	, Codigo de la tienda del Proveedor
@return
@see (links_or_references)
/*/
Static Function F086ActPA(cNumOP,cFornec,dEmision,cPrefixo,nValDev,cTienda)

	Local nVlrSld	:= 0
	Local aAreaSE5 	:= SE5->(GetArea())
	Local cMovRevDta:= SuperGetMV('MV_ESTORDT', .F., 'N')
	Default nValDev	:=0
	
	dbSelectArea("SE5")
	dbSetOrder(2) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
	If SE5->(MsSeek( xFilial("SE5") + "VL" + cPrefixo + cNumOP ))
		While SE5->(!Eof()) .and. SE5->E5_NUMERO == cNumOP
			If SE5->E5_CLIFOR == cFornec .AND. SE5->E5_DATA == dEmision .And. SE5->E5_LOJA == cTienda
				nVlrSld := SE5->E5_VALOR - nValDev
				RecLock("SE5",.F.)
				SE5->E5_VALOR := IIF(nVlrSld <=0,0,nVlrSld) 
				If nVlrSld <= 0
					SE5->E5_SITUACA:= "C"
				EndIf
				SE5->(MsUnlock())
				AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, IIf(cMovRevDta == "S", dDataBase, SE5->E5_DATA), nValDev, "+")		
			EndIf
			SE5->(DBSkip())
		EndDo
	EndIf
	RestArea(aAreaSE5)
Return 

/*/{Protheus.doc} F086ActSEK
	Actualiza campo EK_CANCEL de la tabla SEK al anular Ordenes de Pago
	@type  Function
	@author Luis Enríquez
	@since 18/06/2022
	@version 12.127 o Superior
	@param cNoOrdP, caracter, Número de Orden de Pago
	@example
	F086ActSEK(cNoOrdP)
	/*/
Static Function F086ActSEK(cNoOrdP)
	Local cFilSEK   := xFilial("SEK")
	Local aAreaSEK := SEK->(GetArea())

	Default cNoOrdP := ""

	DbSelectArea("SEK")
	SEK->(dbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
	SEK->(dbGoTop())
	If SEK->(DbSeek(cFilSEK + cNoOrdP))
		If !Empty(cNoOrdP)
			Do While SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cNoOrdP
				If !SEK->EK_CANCEL
					RecLock("SEK",.F.)
					SEK->EK_CANCEL := .T.
					SEK->(MsUnLock())
				EndIf
				SEK->(DbSkip())            
			EndDo
		EndIf
	EndIf
	RestArea(aAreaSEK)
Return Nil
