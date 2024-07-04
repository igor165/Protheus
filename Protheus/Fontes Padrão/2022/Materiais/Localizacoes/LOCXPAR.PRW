#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOCXPAR.CH"

//Array aCfgNf
#Define SnTipo      1
#Define ScCliFor    2
#Define SAliasHead  4

/*/{Protheus.doc} DocOriPAR
Función para seleccionar documentos origen.
@type function
@author raul.medina
@since 05/2022
@version 1.0
*/

Function DocOriPAR()
Local aArea    		:= GetArea()
Local aSF2			:= SF2->(GetArea())
Local aSD2			:= SD2->(GetArea())
Local aCposF4		:= {}
Local aRecs    		:= {}
Local aRet     		:= {}
Local nI 			:= 0
Local nTaxaNf		:= 0
Local nUm			:= 0
Local nSegUm		:= 0
Local nCod			:= 0
Local nLocal		:= 0
Local nQuant		:= 0
Local nNfOri		:= 0
Local nSeriOri		:= 0
Local nItemOri		:= 0
Local nItem			:= 0
Local nTes			:= 0
Local nCf			:= 0
Local nLoteCtl		:= 0
Local nNumLote		:= 0
Local nDtValid		:= 0
Local nVunit		:= 0
Local nTotal		:= 0
Local nQTSegum		:= 0
Local nConta		:= 0
Local nItemCta   	:= 0
Local nCCusto		:= 0
Local nDesc			:= 0
Local nValDesc		:= 0
Local nClVl			:= 0
Local cCondicao 	:= ""
Local cItem			:= ""
Local cTipoDoc 		:= ""
Local cCliFor		:= M->F2_CLIENTE
Local cLoja  		:= M->F2_LOJA
Local cSeek  		:= ""
Local cWhile 		:= ""
Local cAliasCab		:= ""
Local cAliasItem	:= ""
Local cAliasTRB		:= ""
Local cQuery		:= ""
Local cFilSD		:= ""
Local cFilSB1		:= xFilial("SB1")
Local cFilSD2		:= xFilial("SD2")

Private aFiltro		:= {}

If Empty(cCliFor) .OR. Empty(cLoja)
	Aviso(cCadastro,STR0001,{STR0002}) //"Llene los datos del encabezado."###"OK"
	Return
EndIf

For nI:=1 to Len(aHeader)
	Do Case
		Case  Alltrim(aHeader[nI][2]) == "D2_UM"
			nUm      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SEGUM"
			nSegUm   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_COD"
			nCod     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOCAL"
			nLocal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QUANT"
			nQuant   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
			nNfOri  := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
			nSeriOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
			nItemOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEM"
			nItem    := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TES"
			nTes     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CF"
			nCf      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOTECTL"
			nLoteCtl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NUMLOTE"
			nNumLote := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DTVALID"
			nDtValid := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PRCVEN"
			nVunit   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TOTAL"
			nTotal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QTSEGUM"
			nQTSegum := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CONTA"
			nConta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CCUSTO"
			nCCusto := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESCON"
			nValDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESC"
			nDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMCC"
			nItemCta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLVL"
			nClVl := nI
	Endcase
Next nI
cAliasCab	:= "SF2"
cAliasItem	:= "SD2"
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAliasCab))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAliasCab
	If SX3->X3_BROWSE == "S" .AND. cNivel >= SX3->X3_NIVEL
		AAdd(aCposF4,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo

If aCfgNF[1] == 2

	cTipoDoc	:= "'01'" //Tipo documento origem 
	cSeek  	:= "'" + xFilial(cAliasCab)+cCliFor+cLoja + "'"
	cWhile 	:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA)== " + cSeek
	cCondicao	:= "Ascan(aFiltro,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_TIPODOC)) > 0"
	cItem		:= aCols[Len(aCols),nItem]

	cAliasTRB := GetNextAlias()
	cQuery := "select distinct D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC,D2_ITEM"
	cQuery += " from " + RetSqlName("SD2") + " SD2 where "
	cQuery += " D2_FILIAL ='" + xFilial("SD2") + "'"
	cQuery += " and D2_CLIENTE = '" + cCliFor + "'"
	cQuery += " and D2_LOJA = '" + cLoja + "'"
	cQuery += " and D2_TIPODOC in (" + cTipoDoc + ")"
	cQuery += " and D2_QUANT > D2_QTDEDEV"
	cQuery += " and SD2.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)
    DbSelectArea(cAliasTRB)

    While (cAliasTRB)->(!Eof())
    	nI := Ascan(aCols,{|x| x[nNFORI] == (cAliasTRB)->D2_DOC .AND. x[nItemOri] == (cAliasTRB)->D2_ITEM .AND. !x[Len(x)]})
    	If nI == 0
			Aadd(aFiltro, (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_TIPODOC)
		Endif
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
EndIf

If !Empty(aFiltro)	
	aRet := LocxF4(cAliasCab,2,cWhile,cSeek,aCposF4,,STR0003,cCondicao,.T.,,,,,.F.)  // Retorn
Else
	Help(" ",1,"A103F4")
	Return
EndIf
If ValType(aRet)=="A" .AND. Len(aRet)==3
	aRecs := aRet[3]
EndIf
If ValType(aRecs)!="A" .OR. (ValType(aRecs)=="A" .AND. Len(aRecs)==0)
	Return
EndIf
SD2->(DbSetOrder(3))
cFilSD := cFilSD2
ProcRegua(Len(aRecs))

For nI := 1 To Len(aRecs)
	SF2->(MsGoTo(aRecs[nI]))
	SD2->(DbSeek(cFilSD + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
	IncProc(STR0004 + "(" + SF2->F2_DOC + ")")
	While SD2->D2_FILIAL == cFilSD .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND. SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA
		If SD2->D2_QUANT > SD2->D2_QTDEDEV
        	If Ascan(aCols,{|x| x[nNFORI] == SD2->D2_DOC .AND. x[nItemOri] == SD2->D2_ITEM .AND. !x[Len(x)]}) == 0
				nLenAcols := Len(aCols)
				If !Empty(aCols[nLenAcols,nCod])
					AAdd(aCols,Array(Len(aHeader)+1))
					nLenAcols := Len(aCols)
					cItem := Soma1(cItem)
				Endif
			 	aCols[nLenAcols][Len(aHeader)+1] := .F.
				SB1->(MsSeek(cFilSB1+SD2->D2_COD))
				If (nUm      >  0  ,  aCOLS[nLenAcols][nUm     ] := SD2->D2_UM	,)
				If (nSegUm   >  0  ,  aCOLS[nLenAcols][nSegUm  ] := SB1->B1_SEGUM,)
				If (nCod     >  0  ,  aCOLS[nLenAcols][nCod    ] := SD2->D2_COD,)
				If (nLocal   >  0  ,  aCOLS[nLenAcols][nLocal  ] := SD2->D2_LOCAL,)
				If (nNfOri   >  0  ,  aCOLS[nLenAcols][nNfOri  ] := SD2->D2_DOC,)
				If (nSeriOri >  0  ,  aCOLS[nLenAcols][nSeriOri] := SD2->D2_SERIE,)
				If (nItemOri >  0  ,  aCOLS[nLenAcols][nItemOri] := SD2->D2_ITEM,)
				If (nItem    >  0  ,  aCOLS[nLenAcols][nItem   ] := cItem,)
				If (nConta   >  0  ,  aCOLS[nLenAcols][nConta  ] := SD2->D2_CONTA,)
	   			If (nCCusto  >  0  ,  aCOLS[nLenAcols][nCCusto ] := SD2->D2_CCUSTO,)
			   	If (nItemCta >  0  ,  aCOLS[nLenAcols][nItemCta] := SD2->D2_ITEMCC,)
			   	If (nClVl    >  0  ,  aCOLS[nLenAcols][nClVl]  	:= SD2->D2_CLVL,)
				If (nLoteCtl >  0  ,  aCOLS[nLenAcols][nLoteCtl] := SD2->D2_LOTECTL,)
				If (nNumLote >  0  ,  aCOLS[nLenAcols][nNumLote] := SD2->D2_NUMLOTE,)
				If (nDtValid >  0  ,  aCOLS[nLenAcols][nDtValid] := SD2->D2_DTVALID,)

				If nTES <> 0
					aCols[nLenAcols][nTES] := SD2->D2_TES
					aCols[nLenAcols][nCf] := SD2->D2_CF
				EndIf
				nTaxaNF := MaFisRet(,'NF_TXMOEDA')
				nTaxaNF := Iif(nTaxaNF == 0,Recmoeda(dDatabase,M->F1_MOEDA),nTaxaNF)
				AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
				MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)
				MaFisAlt("IT_RECORI",SD2->(Recno()),nLenAcols)

			EndIf
		Endif
		SD2->(DbSkip())
	EndDo
Next nI
oGetDados:lNewLine:=.F.
oGetDados:obrowse:refresh()
Eval(bDoRefresh)
AtuLoadQt()
RestArea(aSD2)
RestArea(aSF2)
RestArea(aArea)

Return
/*/{Protheus.doc} valPreAuto
	(long_description)
	@author adrian.perez
	@since 18/05/2022
	@version version
	@param cFilAnt, Caracter, Filial.
	@param cSerie, Caracter, Serie del documento en este caso es fijo en 1 (especie NF). 
	@param cEspecie, Caracter, Tipo de documento. 
	@param cnFiscal, Caracter, Número de documento. 
		
	@return cRet,caracter, valor asiganado, regresar valor asiganado
	/*/
Function CtrFolAutPAR(cFilAnt,cSerie,cEspecie,cnFiscal)

	Local lRet		:= .T.
	Local alAreaSFP	:= {}
	Local lNoAutoFac:=.F.
	Local dFecha:= dDataBase
	Local lActivo:= .T.
	DEFAULT cFilAnt:=""
	DEFAULT cSerie:=""
	DEFAULT cEspecie:="1"
	DEFAULT cnFiscaL:=""
	
	If !Empty(cEspecie)
		
				alAreaSFP := GetArea()

				dbSelectArea("SFP")
				SFP->(dbGoTop())
				dbSetOrder(5)
				If DbSeek(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
					lRet := .F.
					While !SFP->(Eof()) .AND.AllTrim(SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE) == AllTrim(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)

							IF !Empty(cNFIscal)
								If (Empty(SFP->FP_NUMINI) .or. Empty(SFP->FP_NUMFIM))  .OR.  SFP->FP_NUMINI <= cnFiscal .and. SFP->FP_NUMFIM >= cnFiscal
									IF SFP->FP_ATIVO == "1"
										IF SFP->FP_AUTOFAC== "1"
											M->F1_SERIE2:= SFP->FP_SERIE2
											M->F1_NUMTIM:= SFP->FP_CAI
											dFecha:= SFP->FP_DTAVAL
										ELSE
												lNoAutoFac:=.T.
										ENDIF
										lRet := .T.
									ELSE
										lActivo:=.F.
									ENDIF
									
								Else
									lRet := .F.
								EndIf
							Else
								IF SFP->FP_ATIVO == "1"
									IF SFP->FP_AUTOFAC== "1"
										M->F1_SERIE2:= SFP->FP_SERIE2
										M->F1_NUMTIM:= SFP->FP_CAI
										dFecha:= SFP->FP_DTAVAL
									ELSE
											lNoAutoFac:=.T.
									ENDIF
									lRet := .T.
								ELSE
										lActivo:=.F.
								ENDIF
								
							ENDIF


						SFP->(dbSkip())
					EndDo
					If lRet
						If dDataBase <= dFecha
							
							lRet := .T.
						Else
							Help("", 1, STR0005,STR0007,{STR0006}) //"¡Atencion!"###"La fecha de emisión de este documento está fuera del límite registrado en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal."###"OK"

							lRet := .F.
						EndIf
						
							IF lNoAutoFac
								Help("", 1, STR0005,STR0008,{STR0006}) // Serie no configurada para auto factura
								lRet := .F.
							ENDIF
					
						
					Else
						IF !lActivo
							
								Help("", 1, STR0005,STR0011,{STR0006})  //La serie no esta activ
								lRet := .F.
						ELSE
								Help("", 1,STR0005,STR0009,{STR0006})//"¡Atencion!"###"No existe este número registrado en ningún rango con esta serie o clase."###"OK"
								lRet := .F.
						ENDIF
					
					EndIf
				Else
					Help("", 1,STR0005,STR0010,{STR0006})//"¡Atencion!"###"Esta serie o especie no está registrada en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal."###"OK"
					lRet := .F.
				EndIf

				SFP->(dbCloseArea())
				RestArea(alAreaSFP)

	EndIf
Return lRet

/*/{Protheus.doc} valPreAuto
	(long_description)
	@author adrian.perez
	@since 18/05/2022
	@version version
	@param cDato,caracter, valor asiganado en este caso proviene del parametro MV_PAR01 pregunta MT101N
	@param lAutoFac,booleano, .T. indica si es autofactura, .f. no es autofactura
	
	@return cRet,caracter, valor asiganado, regresar valor asiganado
	/*/
Function autoFactPar(cDato,lAutoFac)
	Local cRet:=0
	DEFAULT cDato:=""
	DEFAULT lAutofac:=.f.
	IF cFunName$"MATA101N" 
		cRet:=cDato	
	ENDIF
	IF(cRet==5)
		lAutoFac:=.T.
	ELSE
		lAutoFac:=.F.
	ENDIF	
Return cRet


/*/{Protheus.doc} xGrvCabPAR
	Funcitón de grabado de encabezado para Paraguay
	@type  Function
	@author Arturo Samaniego
	@since 15/07/2022
	/*/
Function xGrvCabPAR(cFunName, aCabNota, cAlias)
Local nPosParAux := 0
Local cCpo       := ""

Default cFunName := FunName()

	IF (cFunName == "MATA101N")
		nPosParAux := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim("F1_AUTOFAC") } )
		IF nPosParAux<>0
			aCabNota[2][nPosParAux] := cValToChar(aCabNota[2][nPosParAux])
		ENDIF
	ENDIF
	IF ((cFunName == "MATA101N") .OR.(cFunName == "MATA466N") .OR. IsBlind() )
		nPosParAux := 0
		cCpo := PrefixoCpo(cAlias)
		nPosParAux := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim(cCpo+"_DOCEL") } )
		IF nPosParAux <> 0
			aCabNota[2][nPosParAux] := cValToChar(aCabNota[2][nPosParAux])
		ENDIF
	ENDIF

Return

/*/{Protheus.doc} xCliForPAR
	Función para asignar valor en encabezado
	@type  Function
	@author Arturo Samaniego
	@since 15/07/2022
	/*/
Function xCliForPAR()
	If aCfgNf[ScCliFor]=="SA2" .AND. !Empty(SA2->A2_NUMTIM) .OR.  StrZero(aCfgNf[SnTipo],2)=="54"
		If aCfgNf[SAliasHead] == "SF2"
			M->F2_NUMTIM := SA2->A2_NUMTIM
		ElseIf aCfgNf[SAliasHead] == "SF1"
			M->F1_NUMTIM := SA2->A2_NUMTIM
		Endif
	EndIf
Return


/*/{Protheus.doc} ParLinOk
//Funcion destinada a validaciones para pARAGUAY en la funcion NfLinok.
@author raul.medina
@since 07/2022
@version 1.0

@type function
/*/
Function ParLinOk(cAliasI,aCposIOri,cAliasCF,aDadosIOri,cTipDoc,nLinha,lFormP,nMoedaNF,l103Class)
Local lRet			:= .T.
Local nI 			:= 0
Local nPosTes		:= 0
Local nPosQuant		:= 0
Local nPosVUnit		:= 0
Local nPosTotal		:= 0
Local aCposI		:= aClone(aCposIOri)
Local aDadosI		:= aClone(aDadosIOri)

	nPosTes 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_TES' })
	nPosQuant 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_QUANT' })
	nPosVUnit 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+IIf(cAliasI=="SD1","_VUNIT","_PRCVEN") })
	nPosTotal	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_TOTAL'})

	For nI := IIf(nLinha>0,nLinha,1) to IIf(nLinha>0,nLinha,Len(aDadosI))

		If aDadosI[nI][Len(aDadosI[nI])]
			Loop
		EndIf

		If ( MsDecimais(nMoedaNF) == 0 .or. (FunName()$"MATA143"))
			If nPosTes>0 .AND. nPosQuant>0 .AND. nPosVUnit>0 .AND. nPosTotal>0 .AND.;
				lRet .And. Iif(MaTesSel(aDadosI[nI][nPosTes]).And.aDadosI[nI][nPosQuant]==0,aDadosI[nI][nPosVUnit]<>aDadosI[nI][nPosTotal],;
					(Abs(aDadosI[nI][nPosTotal] - (aDadosI[nI][nPosVUnit]*aDadosI[nI][nPosQuant])) > 1 )).and. !l103Class
				Aviso(STR0013,STR0014,{STR0002}) //"ATENCIÓN" ## "Inconsistencia en los valores del documento" ##"STR0002"
				lRet := .F.
			EndIf
		EndIf
	
	Next

Return lRet

/*/{Protheus.doc} LxExSer2()
Validación para uso de serie 2
@author raul.medina
@since 07/2022
/*/
Function ParExSer2()
Local aArea    	:= GetArea()
Local cVarAct	:= readvar()
Local cOp 		:= "1"
Local lRETPAR	:=.F. //RTS PARAGUAY

	If (FunName() $ 'MATA462TN')
		lRETPAR := .T.
	EndIf

	If FunName() $ 'MATA467N|MATA462N' .OR. lRETPAR
		cOp := IIF(FunName() $ 'MATA462N' .OR. lRETPAR,"6","1")
		SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
		If ALLTRIM(cVaract) $ "M->F2_DOC|M->F2_SERIE" //factura de Venta
			If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+cOp))
				M->F2_SERIE2 := SFP->FP_SERIE2
				If SF2->(ColumnPos("F2_NUMTIM")) > 0
					M->F2_NUMTIM := AllTrim(SFP->FP_CAI)
				EndIf
			Else
				M->F2_SERIE2 := ''
			EndIf
		Endif
	EndIf
	IF FunName() $ 'MATA465N'//  Nota de Debito/Credito
    	 SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
		If ALLTRIM(cVaract) $ "M->F1_DOC|M->F1_SERIE"  //NCC  CREDITO

			If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F1_SERIE+(IIf(cPaisLoc <> "PAR",'2','4')) ))
					M->F1_SERIE2:= SFP->FP_SERIE2
					If SF1->(ColumnPos("F1_NUMTIM")) > 0
						M->F1_NUMTIM := AllTrim(SFP->FP_CAI)
					EndIf
				ELSE
					M->F1_SERIE2:= ''
				ENDIF
		Else
			If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //NDC  DEBITO

				If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+(IIf(cPaisLoc <> "PAR",'3','5')) ))
					M->F2_SERIE2:= SFP->FP_SERIE2
					If SF2->(ColumnPos("F2_NUMTIM")) > 0
						M->F2_NUMTIM := AllTrim(SFP->FP_CAI)
					EndIf
				Else
					M->F2_SERIE2 := ''
				EndIf
			Endif
		EndIf
	EndIf
	RestArea(aArea)

Return .T.

/*/{Protheus.doc} LxExSer2()
Validaciones para el control de formularios
@author raul.medina
@since 07/2022
/*/
Function CtrFolPar(cFilAnt,cSerie,cEspecie,cnFiscal)
Local lRet		:= .T.
Local alAreaX	:= {}
	
	cEspecie := Alltrim(cEspecie)
	If !Empty(cEspecie) .And. !Empty(cnFiscal)

		If Upper(Alltrim(FunName())) $ "MATA465N/MATA466N/MATA467N"
			
			If cEspecie $ "NF|NCC|NDC|NDI|NCI"

				Do Case
					Case cEspecie == "NF"
						cEspecie := "1"
					Case cEspecie == "NCI"
						cEspecie := "2"
					Case cEspecie == "NDI"
						cEspecie := "3"
					Case cEspecie == "NCC"
						cEspecie := "4"
					Case cEspecie == "NDC"
						cEspecie := "5"
				EndCase
					
				alAreaX := GetArea()

				dbSelectArea("SFP")
				SFP->(dbGoTop())
				dbSetOrder(5)
				If DbSeek(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
					lRet := .F.
					While AllTrim(SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE) == AllTrim(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
						If SFP->FP_NUMINI <= cnFiscal .and.  cnFiscal > SFP->FP_NUMFIM 
							lRet := .F.
							Exit
						ElseIf SFP->FP_NUMINI > cnFiscal .and.  cnFiscal < SFP->FP_NUMFIM
							lRet := .F.
							Exit
						Else
							lRet := .T.
							Exit
						EndIf
					
					EndDo
					If lRet
						If SFP->FP_ATIVO == "1"
							If dDataBase <= SFP->FP_DTAVAL
								lRet := .T.
							Else
								Aviso(STR0005,STR0007,{STR0002}) //"¡Atencion!"###""La fecha de emisión de este documento está fuera del límite registrado en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal""###"OK"
								lRet := .F.
							EndIf
						Else
							Aviso(STR0005,STR0012,{STR0002}) //"¡Atencion!"###"Este rango de hojas esta registrado pero no esta activo. Por lo tanto, no podra utilizarse para la emisión del documento fiscal."###"OK"
							lRet := .F.
						EndIf
					Else
						Aviso(STR0005,STR0009,{STR0002}) //"¡Atencion!"###""No existe este número registrado en ningún rango con esta serie o clase""###"OK"
					EndIf
				Else
					Aviso(STR0005,STR0010,{STR0002}) //"¡Atencion!"###""Esta serie o especie no está registrada en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal""###"OK"
					lRet := .F.
				EndIf

				SFP->(dbCloseArea())
				RestArea(alAreaX)
			EndIf
		EndIf
	EndIf

Return lRet
