#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA447A.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA447A ³ Autor ³ Gpe Santacruz             ³ Data ³ 14/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla el boton de Resumen y de Extraccion por Factura       ³±±
±±³          ³ de la Rutina de Pedimento MATA447.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATA447A()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marco A    ³29/09/17³TSSERMI01-³Se realiza replica para V12.1.17, de la   ³±±
±±³            ³        ³151       ³funcionalidad de Pedimentos de Importacion³±±
±±³            ³        ³          ³para el Pais Mexico.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATA447A()

	Local aArea 		:= GetArea()

	Local aH1			:= {}
	Local aH2			:= {}
	Local aH3			:= {}

	Local aC1			:= {}
	Local aC2			:= {}
	Local aC3			:= {}

	Local aCamStr1		:= {}
	Local aCamStr2		:= {}
	Local aCamStr3		:= {}
	Local aIva			:= {}

	Local nx			:= 0
	Local nj			:= 0
	Local ny			:= 0
	Local nHayIVA		:= 0

	Local oDlg3

	Local bGraba3		:= {|| oDlg3:End()}
	Local bCance3		:= {|| oDlg3:End()}

	Local CFILSA2		:= XFILIAL("SA2")
	Local CFILRSA		:= XFILIAL("RSA")
	Local CFILSYA		:= XFILIAL("SYA")
	Local CFILSB1		:= XFILIAL("SB1")
	Local CFILRSD		:= XFILIAL("RSD")

	Local nPosEmi2		:= 0
	Local nPosMon2		:= 0
	Local nPosTC2		:= 0
	Local nPosInc2		:= 0
	Local nPosMer2		:= 0
	Local nPosVal2		:= 0
	Local nPosFac		:= 0
	Local nPosTasa		:= 0

	Local nPosFacT		:= 0
	Local nPosSer		:= 0
	Local nPosProv		:= 0
	Local nPosTda		:= 0

	Local nPosSec8		:= 0
	Local nPosTax		:= 0
	Local nPosImp		:= 0

	Local nHaySec		:= 0
	Local cDesPai		:= ''
	Local cDesPrd		:= ''

	Private oGetH1
	Private oGetH2
	Private oGetH3

	Private aColsaC2	:={}
	Private aColsaC3	:={}

	If !lUsoRSG
		Return
	EndIf
	
	/*Variable utilizada para Métrica para sacar el promedio de uso del botón Resumen del Pedimento*/
	If Type("nUsoBtnRes") <> "U"
		nUsoBtnRes++
	EndIf

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Creacion de Headers y aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	aAdd(aCamStr1,"RSG_SECC")
	aAdd(aCamStr1,"RSG_FRACAR")
	aAdd(aCamStr1,"RSG_PAIVTA")
	aAdd(aCamStr1,"RSG_PRODUC")
	aAdd(aCamStr1,"B1_DESC")
	aAdd(aCamStr1,"RSG_CANUMC")
	aAdd(aCamStr1,"RSG_UMC")
	aAdd(aCamStr1,"RSG_PRECIO")
	aAdd(aCamStr1,"RSG_VALADU")
	aAdd(aCamStr1,"RSG_VALCOM")
	MX01AHeads(aCamStr1,@aH1)

	aAdd(aCamStr2,"RSH_SECC")
	aAdd(aCamStr2,"RSH_IMPUES")
	aAdd(aCamStr2,"RSA_DESC")
	aAdd(aCamStr2,"RSH_TIPTAS")
	aAdd(aCamStr2,"RSH_TASA")
	aAdd(aCamStr2,"RSH_IMPPAG")
	MX01AHeads(aCamStr2,@aH2)

	aAdd(aCamStr3,"RSG_SECC")
	aAdd(aCamStr3,"RSG_FACT")
	aAdd(aCamStr3,"RSG_SERIE")
	aAdd(aCamStr3,"RSG_PROV")
	aAdd(aCamStr3,"RSG_TDA")
	aAdd(aCamStr3,"A2_NOME")
	aAdd(aCamStr3,"RSE_EMISIO")
	aAdd(aCamStr3,"RSE_INCOTE")
	aAdd(aCamStr3,"RSE_MONED")
	aAdd(aCamStr3,"RSE_VALMER")
	aAdd(aCamStr3,"RSE_TC")
	aAdd(aCamStr3,"RSE_VALBRU")
	MX01AHeads(aCamStr3,@aH3)

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inserta la informacion en los aCols, agrupando la informacion por numero de Seccion³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	//aCOLS de Secciones y Facturas
	nPosSec	:= aScan(aH1,{|x| Trim(x[2]) == "RSG_SECC"	})
	nPosCan	:= aScan(aH1,{|x| Trim(x[2]) == "RSG_CANUMC"	})
	nPosCom	:= aScan(aH1,{|x| Trim(x[2]) == "RSG_VALCOM"	})
	nPosAdu	:= aScan(aH1,{|x| Trim(x[2]) == "RSG_VALADU"	})
	nPosPre	:= aScan(aH1,{|x| Trim(x[2]) == "RSG_PRECIO"	})
	nPosEmi	:= aScan(aH3,{|x| Trim(x[2]) == "RSE_EMISIO"	})
	nPosMon	:= aScan(aH3,{|x| Trim(x[2]) == "RSE_MONED"	})
	nPosTC		:= aScan(aH3,{|x| Trim(x[2]) == "RSE_TC"		})
	nPosInc	:= aScan(aH3,{|x| Trim(x[2]) == "RSE_INCOTE"	})
	nPosMer	:= aScan(aH3,{|x| Trim(x[2]) == "RSE_VALMER"	})
	nPosVal	:= aScan(aH3,{|x| Trim(x[2]) == "RSE_VALBRU"	})
	nPosSec3	:= aScan(aH3,{|x| Trim(x[2]) == "RSG_SECC"	})
	nPosFac3	:= aScan(aH3,{|x| Trim(x[2]) == "RSG_FACT"	})
	nPosNom	:= aScan(aH3,{|x| Trim(x[2]) == "A2_NOME"		})


	aH3[nPosMer,1] := STR0001	//"Val. Mon. Fac."
	aH3[nPosVal,1] := STR0002	//"Val. Dolares"

	nPosEmi2	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_EMISIO"})
	nPosMon2	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_MONED"})
	nPosTC2	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_TC"})
	nPosInc2	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_INCOTE"})
	nPosMer2	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_VALMER"})
	nPosVal2	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_VALBRU"})
	nPosFac	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_TC"})
	nPosTasa	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_TASA"})
 	nPosFacT	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_FACT"})
	nPosSer	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_SERIE"})
	nPosProv	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_PROV"})
	nPosTda	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_TDA"})

	nPosSec8	:= aScan(aH2,{|x| Trim(x[2])=="RSH_SECC"	})
	nPosTax	:= aScan(aH2,{|x| Trim(x[2])=="RSH_IMPUES"})
	nPosImp	:= aScan(aH2,{|x| Trim(x[2])=="RSH_IMPPAG"})


	RSA->(DBSetOrder(1))
	SA2->(DBSetOrder(1))
	SYA->(DBSetOrder(1))
	SB1->(DBSetOrder(1))
	RSD->(DBSetOrder(1))

	TMPRSG->(DBGoTop())
	Do While !TMPRSG->(Eof())

		nHaySec := aScan(aC1,{|x| Trim(x[nPosSec]) == AllTrim(TMPRSG->RSG_SECC) })
		If 	nHaySec == 0
			cDesPai := ''
			If SYA->(DBSeek(CFILSYA+TMPRSG->RSG_PAIVTA))
				cDesPai := SYA->YA_SIGLA
			EndIf
			cDesPrd := ''
			If SB1->(DBSeek(CFILSB1+TMPRSG->RSG_PRODUC))
				cDesPrd := SB1->B1_DESC
			EndIf

			Aadd(aC1,Array(Len(AH1)+1))
			For nx := 1 To Len(aH1)
				If AllTrim(aH1[NX,2]) == 'RSG_PAIVTA'
					aC1[Len(aC1),nx] := cDesPai
				Else
					If AllTrim(aH1[NX,2]) == 'B1_DESC'
						aC1[Len(aC1),nx] := cDesPrd
					Else
						aC1[Len(aC1),nx] := &("TMPRSG->"+AllTrim(aH1[NX,2]))
					EndIf
				EndIf
			Next
			aC1[Len(aC1)][LEN(AH1)+1] := .F.
		Else

			aC1[nHaySec,nPosCan]	+= TMPRSG->RSG_CANUMC
			aC1[nHaySec,nPosCom]	+= TMPRSG->RSG_VALCOM
			aC1[nHaySec,nPosAdu]	+= TMPRSG->RSG_VALADU
			aC1[nHaySec,nPosPre]	:= aC1[nHaySec,nPosCom] / aC1[nHaySec,nPosCan]

		EndIf

    	//Junta los importes de iva por seccion
		nHayIva := aScan(aIVA,{|x| Trim(x[1]) == AllTrim(TMPRSG->RSG_SECC) .AND. x[3] == TMPRSG->RSG_PORIVA })
		If nHayIva > 0
			aIVA[nHayIVA,4] += TMPRSG->RSG_IMPIVA
		Else
			aAdd(aIVA,{TMPRSG->RSG_SECC,"IVA",TMPRSG->RSG_PORIVA,TMPRSG->RSG_IMPIVA})
		EndIf

		//aCols de Facturas (3)
		nHaySec := aScan(aC3,{|x| x[nPosSec3]+x[nPosFac3]==TMPRSG->RSG_SECC+TMPRSG->RSG_FACT })
		If 	nHaySec == 0
			aAdd(aC3,Array(Len(AH3)+1))
			For ny := 1 To Len(aH3)
				cNome := ''
				If SA2->(DBSeek(CFILSA2+TMPRSG->RSG_PROV+TMPRSG->RSG_TDA))
					cNome := SA2->A2_NOME
				EndIf
				If AllTrim(aH3[Ny,2]) == 'A2_NOME'
					aC3[Len(aC3),nPosNom] := cNome
				Else
					If SubStr(aH3[Ny,2],1,3) == 'RSG'
						aC3[Len(aC3),ny]:=&("TMPRSG->"+AllTrim(aH3[Ny,2]))
					Else
						nHayFac := aScan(oGetFacts:aCols,{|x| Trim(x[nPosFact]) == AllTrim(TMPRSG->RSG_FACT) .AND. Trim(x[nPosSer]) == AllTrim(TMPRSG->RSG_SERIE)  .AND. Trim(x[nPosProv])==AllTrim(TMPRSG->RSG_PROV) .AND. Trim(x[nPosTda])==AllTrim(TMPRSG->RSG_TDA)})
						If nHayFac > 0
							aC3[Len(aC3),nPosEmi]	:= oGetFacts:aCols[nHayFac,nPosEmi2]
							aC3[Len(aC3),nPosMon]	:= oGetFacts:aCols[nHayFac,nPosMon2]
							aC3[Len(aC3),nPosTC]		:= oGetFacts:aCols[nHayFac,nPosFac]
							aC3[Len(aC3),nPosINC]	:= oGetFacts:aCols[nHayFac,nPosINC2]
							aC3[Len(aC3),nPosMer]	:= oGetFacts:aCols[nHayFac,nPosMer2]
							aC3[Len(aC3),nPosVal]	:= oGetFacts:aCols[nHayFac,nPosMer2] * oGetFacts:aCols[nHayFac,nPosFac]
						EndIf
					EndIf
				EndIf
			Next
			aC3[Len(aC3),Len(ah3)+1] := .F.
		EndIf
		//aCOLS de Impuestos
		If TMPRSH->(DBSeek(TMPRSG->RSG_FACT+TMPRSG->RSG_SERIE+TMPRSG->RSG_PROV+TMPRSG->RSG_TDA+TMPRSG->RSG_ITEM))
			Do While !TMPRSH->(Eof()) .AND. TMPRSG->RSG_FACT+TMPRSG->RSG_SERIE+TMPRSG->RSG_PROV+TMPRSG->RSG_TDA+TMPRSG->RSG_ITEM == TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_TDA+TMPRSH->RSH_ITEM
				If !RSD->(DBSeek(CFILRSD+M->RSC_NUMPED+TMPRSH->RSH_IMPUES))
					cDesc := ''
					If RSA->(DBSeek(CFILRSA+TMPRSH->RSH_IMPUES))
						cDesc := RSA->RSA_DESC
					EndIf
					nHaySec := aScan(aC2,{|x| x[nPosSec8]+x[nPosTax] == TMPRSH->RSH_SECC+TMPRSH->RSH_IMPUES })
					If 	nHaySec == 0
						aAdd(aC2,Array(Len(AH2)+1))
						For nx:=1 To Len(aH2)
							If AllTrim(aH2[NX,2]) == 'RSA_DESC'
								aC2[Len(aC2),nx] := CDESC
							Else
								aC2[Len(aC2),nx] := &("TMPRSH->"+AllTrim(aH2[NX,2]))
							EndIf
						Next
						aC2[Len(aC2),Len(ah2)+1] := .F.
					Else
						aC2[nHaySec,nPosImp] += TMPRSH->RSH_IMPPAG
					EndIf
				EndIf
    			//Junta los importes de iva por seccion
				nHayIva := aScan(aIVA,{|x| Trim(x[1]) == AllTrim(TMPRSH->RSH_SECC) .AND. x[3] == TMPRSH->RSH_PORIVA })
				If nHayIva > 0
					aIVA[nHayIVA,4] += TMPRSH->RSH_IMPIVA
				Else
					aAdd(aIVA,{TMPRSG->RSG_SECC,"IVA",TMPRSH->RSH_PORIVA,TMPRSH->RSH_IMPIVA})
				EndIf
				TMPRSH->(DBSkip())
			EndDo
		EndIf
		TMPRSG->(DBSkip())
	EndDo
	//Actualiza el precio unitario del aCols de fracciones arancelarias
	For NX := 1 To LEN(aC1)
		aC1[nX,nPosPre] := aC1[nX,nPosCom] / aC1[nX,nPosCan]
	Next

	aC1			:= aSort(aC1,,,{|x,y| x[nPosSec] < y[nPosSec] })
	nPosPor	:= aScan(aH2,{|x| Trim(x[2]) == "RSH_TASA"})
	nPosTT		:= aScan(aH2,{|x| Trim(x[2]) == "RSH_TIPTAS"})
	nPosDes	:= aScan(aH2,{|x| Trim(x[2]) == "RSA_DESC"})

	For nx := 1 To Len(aIVA)
		nHaySec := aScan(Ac2,{|x| x[nPosSec8] == aIVA[NX,nPosSec8] .AND. Trim(x[nPosTax])== AllTrim(aIVA[NX,nPosTax])  })

		If nHaySec == 0
			aAdd(aC2,Array(Len(AH2)+1))
			aC2[Len(aC2),nPosSec8]	:= aIVA[nx,1]
			aC2[Len(aC2),nPosTax]	:= '     '
			aC2[Len(aC2),nPosDes]	:= aIVA[nx,2]
			aC2[Len(aC2),nPosTT]		:= '  '
			aC2[Len(aC2),nPosPor]	:= aIVA[nx,3]
			aC2[Len(aC2),nPosImp]	:= aIVA[nx,4]
			aC2[Len(aC2),Len(ah2)+1]	:= .F.
		Else
			aC2[nHaySec,nPosImp] += aIVA[NX,4]
		EndIf
	Next

	For nx := 1 To Len(aC2)
		aC2[nX,nPosImp]	:= round(aC2[nX,nPosImp],0)
		nHaySec			:= 0
		For ny := 1 To Len(aColsaC2)
			nHaySec := aScan(aColsAc2[ny],{|x| x[nPosSec8] == aC2[nx,nPosSec8] })
			If nHaySec > 0
				exit
			EndIf
		Next
		If nHaySec > 0
			nHaySec2 := aScan(aColsAc2[ny],{|x| x[nPosTax] == aC2[nx,nPosTax] })
			If nHaySec2 > 0
				aColsaC2[nHaySec,nHaysec2,nPosImp] += aC2[nx,nPosImp]
			Else
				aAdd(aColsaC2[ny],aC2[nx])
			EndIf
		Else
			aAdd(aColsaC2,{aC2[nx]})
		EndIf
	Next

	For nx := 1 To Len(aC3)
		nHaySec := 0
		For ny := 1 To Len(aColsaC3)
			nHaySec := aScan(aColsAc3[ny],{|x| x[nPosSec3] == aC3[nx,nPosSec3] })
			If nHaySec > 0
				exit
			EndIf
		Next
		If nHaySec > 0
			nHaySec2 := aScan(aColsAc3[ny],{|x| x[nPosFac3] == aC3[nx,nPosFac3] })
			If nHaySec2 == 0
				aAdd(aColsaC3[ny],aC3[nx])
			EndIf
		Else
			aAdd(aColsaC3,{aC3[nx]})
		EndIf
	Next

	DEFINE MSDIALOG oDlg3 TITLE STR0003+M->RSC_NUMPED From 100,50 To 492,1191 OF odlg PIXEL  //"Resumen del Pedimento "

	oGetH1 := MsNewGetDados():New(03,2,80,570,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
				"AllwaysTrue","AllwaysTrue" ,  oDlg3, aH1, aC1)
	oGetH2 := MsNewGetDados():New(82,2,140,570,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
				"AllwaysTrue","AllwaysTrue" ,  oDlg3, aH2, aColsaC2[1])
	oGetH3 := MsNewGetDados():New(142,2,195,570,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
				"AllwaysTrue","AllwaysTrue" ,  oDlg3, aH3, aColsaC3[1])
	oGetH1:oBrowse:bChange := {|| MX01AbChange() }

	ACTIVATE MSDIALOG oDlg3 CENTERED

	RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MX01AHeads ³Autor ³Gpe Santacruz          ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera los headers para cada getdados de la pantalla de      ³±±
±±³          ³Resumen                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.-Arreglo de los campos a mostrar.                      ³±±
±±³          ³aExp2.-Arreglo del encabezado que regresara                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aExp2                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MX01AHeads(aCamStr,aH)

	Local nx     := 0
	Local nUsado := 0

	DBSelectArea("SX3")
	SX3->(DBSetOrder(2))
	For nx := 1 To Len(aCamStr)
		If SX3->(DBSeek(aCamStr[nx]))
			nUsado++
			aAdd(aH,{ Trim( X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal})
		Endif
	Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MX01AbChange Autor³Gpe Santacruz          ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Refresca la informacion de los getdados inferiores, al cambia³±±
±±³          ³r de renglo del getdados principal                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ oGetH1                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MX01AbChange()

	Local lRet		:= .t.
	Local nx		:= 0
	Local cSecc	:= oGetH1:aCols[oGetH1:Nat,1]
	Local ny		:= 0
	Local npos		:= 0

	For ny := 1 To Len(aColsaC2)
		nPos := aScan(aColsAc2[ny],{|x| x[1] == cSecc })
		If nPos > 0
			exit
		EndIf
	Next
	If  nPos > 0
		oGetH2:aCols := aColsaC2[ny]
		oGetH2:Refresh()
	EndIf
	nPos	:= 0
	ny		:= 0
	For ny := 1 To Len(aColsaC3)
		nPos := aScan(aColsAc3[ny],{|x| x[1] == cSecc })
		If nPos > 0
			exit
		EndIf
	Next
	If  npos > 0
		oGetH3:aCols := aColsaC3[ny]
		oGetH3:Refresh()
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447AFACTS³ Autor³Gpe Santacruz          ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pantalla para seleccionar items de las factura               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MEXA001                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447AFACTS()

	Local aArea     := GetArea()
	Local aSvKeys   := GetKeys()
	Local nX        := 0
	Local nOpca     := 0
	Local nPos      := 0
	Local nMarcados := 0
	Local aStru     := {}
	Local aCpos     := {}
	Local aPosEnch  := {}
	Local lRet      := .t.
	Local aCanExt   := {}
	Local oDlg4

	Local nPosFac  := aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_FACT"})
	Local nPosSer  := aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_SERIE"})
	Local nPosProv := aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_PROV"})
	Local nPosTda  := aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_TDA"})
	Local nPosMon  := aScan(oGetFacts:aHeader,{|x| Trim(x[2]) == "RSE_MONED"})
	Local cPictCan := PesqPict("SD1","D1_QUANT")

	Private cAlmDef2	:= '  '   //Almacen de entrada por default
	Private oMark2		:= Nil
	Private oPrd2		:= Nil
	Private cCodPrd2	:= Nil
	Private oCanPen2	:= Nil
	Private nCanpen2	:= 0
	Private oAlmEnt2	:= Nil
	Private cAlmEnt2	:= cAlmDef2
	Private lInverte2	:= .f.
	Private oTmpTab2	:= Nil

	If Empty(oGetFacts:aCols[oGetFacts:nat,nposFac]) .or.  Empty(oGetFacts:aCols[oGetFacts:nat,nposProv]) .or.  Empty(oGetFacts:aCols[oGetFacts:nat,nposTda])
		MsgAlert(STR0004) //"El numero de factura y codigo de proveedor no existen en el encabezado de la factura"
		RestArea(aArea)
		RestKeys( aSvKeys , .T. )
		Return
	EndIf

	SF1->(DBSetOrder(1))
	//Verifica si es extracción de factura
	If !SF1->(DBSeek(XFILIAL("SF1")+oGetFacts:aCols[oGetFacts:nat,nposFac]+oGetFacts:aCols[oGetFacts:nat,nposSer]+oGetFacts:aCols[oGetFacts:nat,nposProv]+oGetFacts:aCols[oGetFacts:nat,nposTda]))
		msginfo(STR0005) //"Esta factura aun no esta registradas, en compras!"
		Return
	Else
		If SF1->F1_MOEDA<> oGetFacts:aCols[oGetFacts:nat,nposMon]
			msginfo(STR0006)  //"La moneda de la factura original es diferente a la moneda que se coloco en este encabezado!. Modifique y vuelva a intentar."
			Return
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Redefinicao do aCpos para utilizar no MarkBrow ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	 //Campos a visualizar
	aCpos := {	{"TRB_OK"		, "", STR0007},;
				{"TRB_ITEM"	, "", STR0008},;
				{"TRB_PRODUC"	, "", STR0009},;
				{"TRB_DESC"	, "", STR0010},;
				{"TRB_UM"		, "", STR0011},;
				{"TRB_CANTOT"	, "", STR0012,X3PICTURE("RSF_CANT"		)},;
				{"TRB_UM2"		, "", STR0013},;
				{"TRB_CANUM2"	, "", STR0014,X3PICTURE("RSF_CANUM2"	)},;
				{"TRB_PRECIO"	, "", STR0015,X3PICTURE("RSF_PRECIO"	)},;
				{"TRB_TOTAL"	, "", STR0016,X3PICTURE("RSF_TOTAL"	)},;
				{"TRB_VLDESC"	, "", "Descuento",X3PICTURE("RSF_VLDESC"	)},;
				{"TRB_CANPEN"	, "", STR0017,X3PICTURE("RSF_CANT"		)},;
				{"TRB_CANT"	, "", STR0018,X3PICTURE("RSF_CANT"		)},;
				{"TRB_ALMACE"	, "", STR0019},;
				{"TRB_OC"		, "", STR0020},;
				{"TRB_ITEOC"	, "", STR0021}}

	MX01APRODEXT(oGetFacts:aCols[oGetFacts:nat,nposFac],oGetFacts:aCols[oGetFacts:nat,nposSer],oGetFacts:aCols[oGetFacts:nat,nposProv],oGetFacts:aCols[oGetFacts:nat,nposTda]) //CREA TABLA TEMPORAL

	TRB2->(DBGoTop())
	cCodPrd2 := TRB2->TRB_PRODUC+"      "+TRB2->TRB_DESC +"       "+TRB2->TRB_UM
	nCanPen2 := TRB2->TRB_CANT

	DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11  BOLD
	DEFINE MSDIALOG oDlg4 TITLE STR0022+oGetFacts:aCols[oGetFacts:nat,nposFac]+oGetFacts:aCols[oGetFacts:nat,nposSer] FROM 60,0 TO 90,150 OF oMainWnd  //"Seleccione los productos de la Factura "
	aPosEnch := {30,0,228,593}
	@1.2,5 SAY oPrd2 VAR cCodPrd2 OF oDlg4 FONT oFont2
	@1.5,37 SAY STR0023  OF oDlg4  FONT oFont2   //"Cantidad a Extraer:"
	@1.2,44 get oCanPen2 VAR nCanPen2 picture cPictCan VALID MT477AVldCanExt(CMARCA) OF oDlg4 size 60,2

	@1.5,55 SAY STR0024  OF oDlg4  FONT oFont2  //"Almacen de Entrada:"
	@1.2,63 get oAlmEnt2 VAR cAlmEnt2 Valid MT477AVldAlmEnt() OF oDlg4 size 20,2

	oMark2 := MsSelect():New("TRB2","TRB_OK","",aCpos,lInverte2,cMarca,aPosEnch)
	oMark2:oBrowse:lCanAllMark	:= .T.
	oMark2:oBrowse:lHasMark		:= .T.
	oMark2:bMark					:= {||Marca2Item(cMarca,lInverte2,oDlg4)}

	oMark2:oBrowse:bAllMark		:= {||Marca2Tudo(cMarca,oDlg4)}
	oMark2:OBROWSE:BCHANGE		:= {||MT477ARefCant()}

	ACTIVATE MSDIALOG oDlg4 CENTERED ON INIT EnchoiceBar(oDlg4,{||nOpcA:=1,oDlg4:End()},{||oDlg4:End()})

	If nOpcA == 1
		MT477ACtaAcols()
		MT447Refresh()
	EndIf

	TRB2->(DBCloseArea())
	If oTmpTab2 <> Nil
		oTmpTab2:Delete()
		oTmpTab2 := Nil
	EndIf
	
	RestArea(aArea)
	RestKeys(aSvKeys , .T.)

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    MX01APRODEXT³Autor ³Gpe Santacruz          ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Crea tabla temporal, para los items de la extraccion por Fact³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.-Numero de factura                                     ³±±
±±³          ³cExp2.-Numero de Serie                                       ³±±
±±³          ³cExp3.-Codigo de proveedor                                   ³±±
±±³          ³cExp4.-Codigo de tienda                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pantalla de extraccion de facturas                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MX01APRODEXT(cFac,cSer,cProv,cTda)

	Local aStru		:= {}
	Local cAliasRSE	:= ''
	Local nPos			:= 0
	Local cArqTrab	:= ''
	Local aCanExt		:= {}
	Local cQryCond	:= ''
	Local cQry			:= ''
	Local nPosPrd		:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_PRODUC"})
	Local nPosCan1	:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_CANT"})
	Local nPosCan2	:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_CANUM2"})
	Local nPosalm		:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_ALMACE"})
	Local nDelete		:= GdFieldPos("GDDELETED",oGetItemF:aHeader)
	Local nx			:= 0
	Local nCp			:= 0
	Local cAlm			:= ''
	Local cAliasSUM	:= ''
	Local cI			:= ''
	Local nposimp		:= 0
	Local nBase		:= 0
	Local nValor		:= 0
	Local nTasa		:= 0
	CURSORWAIT()

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera arreglo con las cantidad extraidas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cAliasSUM := CriaTrab(Nil,.F.)
	cQryCond := "Select RSF_PRODUC,SUM(RSF_CANT) CAN1,SUM(RSF_CANUM2) CAN2"
	cQryCond += " from "+RetSqlName("RSF") +" RSF, "+RetSqlName("RSE") +" RSE WHERE "
	cQryCond += " RSE_ITEM=RSF_ITEDOC AND  RSE_NUMPED=RSF_NUMPED "
	cQryCond += " AND RSE_FACT='"+CFAC+"' AND RSE_SERIE='"+CSER+"' AND RSE_PROV='"+CPROV+"' AND RSE_tda='"+CTDA+"'  and RSF_NUMPED<>'"+M->RSC_NUMPED+"' "
	cQryCond += " AND  RSF_FILIAL='"+XFILIAL("RSF")+"' AND RSF.D_E_L_E_T_ = ' ' AND  RSE_FILIAL='"+XFILIAL("RSE")+"'  AND RSE.D_E_L_E_T_ = ' ' "
	cQryCond += " GROUP BY RSF_PRODUC "
	cQry := ChangeQuery(cQryCond)
	DbUseArea( .T., 'TOPCONN', TCGenQry(,, cQry), cAliasSUM, .T., .T. )
	do while !(cAliasSUM)->(Eof())
		aAdd(aCanExt,{(cAliasSUM)->RSF_PRODUC,(cAliasSUM)->can1,(cAliasSUM)->can2,0,'  '})
		(cAliasSUM)->(dbskip())
	EndDo
	(cAliasSUM)->(DBCloseArea())
    //Suma como cantidad extraida, lo contenido en el aCols de Items
	For nx := 1 To Len(oGetItemF:aCols)
		If !oGetItemF:aCols[NX,nDelete]
			nPos := aScan(aCanExt,{|x| allTrim(x[1]) == AllTrim(oGetItemF:aCols[nx,nPosPrd]) })
			If nPos > 0
				aCanExt[npos,4] += oGetItemF:aCols[nx,nPosCan1]
				aCanExt[npos,3] += oGetItemF:aCols[nx,nPosCan2]
			Else
				aAdd(aCanExt,{oGetItemF:aCols[nx,nPosPrd],0,oGetItemF:aCols[nx,nPosCan2],oGetItemF:aCols[nx,nPosCan1],oGetItemF:aCols[nx,nPosAlm]})
			EndIf
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo de Trabalho para a escolha dos ensaios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aStru,{"TRB_OK"		, "C",02,0})
	Aadd( aStru,{"TRB_ITEM"		, "C",TamSx3("RSF_ITEM")[1],0})
	Aadd( aStru,{"TRB_PRODUC"	, "C",TamSx3("RSF_PRODUC")[1],0})
	Aadd( aStru,{"TRB_DESC"		, "C",TamSx3("B1_DESC")[1],0})
	Aadd( aStru,{"TRB_UM"		, "C",TamSx3("RSF_UM")[1],0})
	Aadd( aStru,{"TRB_CANTOT"	, "N",TamSx3("RSF_CANT")[1],TamSx3("RSF_CANT")[2]})
	Aadd( aStru,{"TRB_UM2"		, "C",TamSx3("RSF_UM2")[1],0})
	Aadd( aStru,{"TRB_CANUM2"   , "N",TamSx3("RSF_CANUM2")[1],TamSx3("RSF_CANUM2")[2]})
	Aadd( aStru,{"TRB_PRECIO"	, "N",TamSx3("RSF_PRECIO")[1],TamSx3("RSF_PRECIO")[2]})
	Aadd( aStru,{"TRB_TOTAL"	, "N",TamSx3("RSF_TOTAL")[1],TamSx3("RSF_TOTAL")[2]})
	Aadd( aStru,{"TRB_VLDESC"	, "N",TamSx3("RSF_VLDESC")[1],TamSx3("RSF_VLDESC")[2]})
	Aadd( aStru,{"TRB_CANPEN"	, "N",TamSx3("RSF_CANT")[1],TamSx3("RSF_CANT")[2]})	//Cantidad Pendiente
	Aadd( aStru,{"TRB_CANT"		, "N",TamSx3("RSF_CANT")[1],TamSx3("RSF_CANT")[2]})	//Cantidad a extraer
	Aadd( aStru,{"TRB_ALMACE"	, "C",TamSx3("RSF_ALMACE")[1],0})
	Aadd( aStru,{"TRB_TES"		, "C",TamSx3("RSF_TES")[1],0})
	Aadd( aStru,{"TRB_OC"		, "C",TamSx3("RSF_PEDIDO")[1],0})
	Aadd( aStru,{"TRB_ITEOC"		, "C",TamSx3("RSF_ITEMPC")[1],0})
	Aadd( aStru,{"TRB_CC"		, "C",TamSx3("RSF_CC")[1],0})
	Aadd( aStru,{"TRB_CLVL"		, "C",TamSx3("RSF_CLVL")[1],0})
	Aadd( aStru,{"TRB_CONTA"		, "C",TamSx3("RSF_CONTA")[1],0})
	Aadd( aStru,{"TRB_ITCTA"		, "C",TamSx3("RSF_ITCTA")[1],0})

	For nx := 1 To 8
		cI := AllTrim(str(nx))
		nposimp := aScan(oGetItemF:aHeader,{|x| Trim(x[2])== "RSF_ALIMP"+cI})
		If nposimp > 0
			Aadd(aStru,{ "TRB_BASIM" + ci, "N", TamSx3("RSF_BSIMP"+CI)[1], TamSx3("RSF_BSIMP"+CI)[2]})
			Aadd(aStru,{ "TRB_VALIM" + ci, "N", TamSx3("RSF_VLIMP"+CI)[1], TamSx3("RSF_VLIMP"+CI)[2]})
			Aadd(aStru,{ "TRB_ALQIM" + ci, "N", TamSx3("RSF_ALIMP"+CI)[1], TamSx3("RSF_ALIMP"+CI)[2]})
		Else
			exit
		EndIf
	Next

	oTmpTab2 := FWTemporaryTable():New("TRB2")
	oTmpTab2:SetFields(aStru)
	oTmpTab2:AddIndex("I1", {"TRB_ITEM"}) 
	oTmpTab2:Create()
	
	cAliasRSE := CriaTrab(Nil,.F.)
	cQryCond := "Select D1_COD, D1_UM, D1_QUANT, D1_SEGUM, D1_QTSEGUM, D1_VUNIT , D1_TOTAL,   D1_ITEM,D1_DOC, D1_SERIE, D1_FORNECE, "
	cQryCond += "D1_LOJA, D1_EMISSAO, B1_DESC, D1_TES, D1_PEDIDO,D1_ITEMPC,D1_CONTA,D1_CLVL,D1_CC,D1_ITEMCTA,B1_LOCPAD, D1_VALDESC "

	For nx := 1 To 8
		cI := AllTrim(str(nx))
		nposimp := aScan(oGetItemF:aHeader,{|x| Trim(x[2]) == "RSF_ALIMP"+cI})
		If nposimp > 0
			cQryCond += ", D1_BASIMP"+ci+", D1_VALIMP"+ci+", D1_ALQIMP"+ci
		Else
			exit
		EndIf
	Next

	cQryCond += " from "+RetSqlName("SB1") +" SB1, " +RetSqlName("SD1") +" SD1 "
	cQryCond += " WHERE  D1_COD =B1_COD "
	cQryCond += " AND D1_DOC='"+cfac+"' AND D1_SERIE='"+CSER+"' AND D1_FORNECE='"+CPROV+"' AND D1_LOJA='"+CTDA+"' "
	cQryCond += " AND D1_FILIAL='"+xfilial("SD1")+"' AND B1_FILIAL='"+xfilial("SB1")+"'  "
	cQryCond += " AND SD1.D_E_L_E_T_  = ' ' "
	cQryCond += " AND SB1.D_E_L_E_T_  = ' ' "

	cQry := cQryCond+"   ORDER BY D1_ITEM,D1_COD "
	cQry := ChangeQuery(cQry)
	DbUseArea( .T., 'TOPCONN', TCGenQry(,, cQry), cAliasRSE, .T., .T. )
	TCSetField(cAliasRSE,"D1_EMISSAO","D")

	Do While  !(cAliasRSE)->(Eof())
		nPos		:= aScan(aCanExt,{|x| allTrim(x[1])==AllTrim((cAliasRSE)->D1_COD)})
		nCanExt	:= 0
		cAlm		:= '  '
		If npos > 0
			nCP			:= (cAliasRSE)->D1_QUANT - aCanExt[npos,2]
			nCanExt	:= aCanExt[npos,4]
			cAlm		:= aCanExt[npos,5]
		Else
			nCP := (cAliasRSE)->D1_QUANT
		EndIf
		If nCP>0
			RECLOCK("TRB2",.T.)
			TRB2->TRB_OK		:= If (nCanExt>0,CMARCA,'  ')
			TRB2->TRB_ITEM	:= (cAliasRSE)->D1_ITEM
			TRB2->TRB_PRODUC	:= (cAliasRSE)->D1_COD
			TRB2->TRB_DESC	:= (cAliasRSE)->B1_DESC
			TRB2->TRB_UM		:= (cAliasRSE)->D1_UM
			TRB2->TRB_CANTOT	:= (cAliasRSE)->D1_QUANT
			TRB2->TRB_UM2		:= (cAliasRSE)->D1_SEGUM
			TRB2->TRB_CANUM2	:= (cAliasRSE)->D1_QTSEGUM
			TRB2->TRB_PRECIO	:= (cAliasRSE)->D1_VUNIT
			TRB2->TRB_TOTAL	:= (cAliasRSE)->D1_TOTAL
			TRB2->TRB_VLDESC	:= (cAliasRSE)->D1_VALDESC
			TRB2->TRB_CANPEN	:= nCP		//Cantidad pendiente
			TRB2->TRB_CANT	:= nCanExt	//Cantidad a extraer
			TRB2->TRB_ALMACE	:= (cAliasRSE)->B1_LOCPAD   //cAlm
			TRB2->TRB_TES		:= (cAliasRSE)->D1_TES
			TRB2->TRB_OC		:= (cAliasRSE)->D1_PEDIDO
			TRB2->TRB_ITEOC	:= (cAliasRSE)->D1_ITEMPC
			TRB2->TRB_CC		:= (cAliasRSE)->D1_CC
			TRB2->TRB_CLVL	:= (cAliasRSE)->D1_CLVL
			TRB2->TRB_CONTA	:= (cAliasRSE)->D1_CONTA
			TRB2->TRB_ITCTA	:= (cAliasRSE)->D1_ITEMCTA

			For nx := 1 To 8
				cI := AllTrim(str(nx))
				nposimp := aScan(oGetItemF:aHeader,{|x| Trim(x[2]) == "RSF_ALIMP"+cI})
				If nposimp > 0
					dbselectarea(caliasRSE)
					nBase	:= &("D1_BASIMP"+ci)
					nValor	:= &("D1_VALIMP"+ci)
					nTasa	:= &("D1_ALQIMP"+ci)
					dbselectarea("TRB2")
					&("TRB_BASIM"+ci) := nBase
					&("TRB_ALQIM"+ci) := nTasa
					&("TRB_VALIM"+ci) := nValor
				Else
					exit
				EndIf
			Next
			TRB2->(MsUnlock())
		EndIf
		(cAliasRSE)->(DBSkip())
	EndDo
	(cAliasRSE)->(DBCloseArea())
	CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT477AVldCanExt³Autor ³Gpe Santacruz      ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el get de la cantidad a extraer                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT477AVldCanExt()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Factura                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT477AVldCanExt()

	Local lRet:= .t.

	If nCanPen2 > TRB2->TRB_CANPEN//TRB2->TRB_CANPEN+TRB2->TRB_CANT
		msgInfo(STR0025) //"La cantidad a extraer es mayor a la cantidad que tiene el deposito"
		lRet := .f.
	Else
		reclock("TRB2",.F.)
		TRB2->TRB_CANT := nCanPen2 //Cantidad a extraer
		If nCanPen2 > 0
			If Empty(TRB2->TRB_OK)
				TRB2->TRB_OK := cMarca
			EndIf
		Else
			TRB2->TRB_OK := "  "
		EndIf
		TRB2->(MsUnlock())
		oMark2:obrowse:Refresh()
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT477AVldAlmEnt³Autor ³Gpe Santacruz      ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el get del almacen de entrada de la extraccion        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³VldAlnEnt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Factura                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT477AVldAlmEnt()

	Local lRet := .t.

	If Empty(cAlmEnt2) .and. nCanPen2>0
		MsgInfo(STR0026) //"Debe seleccionar un almacen o cambie la cantidad a extraer a cero!"
		lRet := .f.
	Else
	    DBSelectArea("NNR")
	    NNR->(DBSetOrder(1))
	    If !NNR->(DBSeek(xFilial("NNR")+cAlmEnt2))
	   		 msgInfo("Almacen inexistente") 
			 lRet := .f.
	    Else
			cAlmDef2 := cAlmEnt2
			reclock("TRB2",.F.)
			TRB2->TRB_ALMACE := cAlmEnt2
	
			If nCanPen2 > 0
				If Empty(TRB2->TRB_OK)
					TRB2->TRB_OK := cMarca
				EndIf
			Else
				TRB2->TRB_OK		:= "  "
				TRB2->TRB_ALMACE	:= '  '
			EndIf
			TRB2->(MsUnlock())
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Marca2Item ³ Autor ³Gpe Santacruz        ³ Data ³ 14/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca un item del MarkBrowse                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Extraccion por Factura                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Marca2Item(cMarca,lInverte2,oDlg4)

	If TRB2->(IsMark("TRB_OK",cMarca,lInverte2))
		RecLock("TRB2",.F.)
		If !lInverte2
			TRB2->TRB_OK		:= cMarca
			TRB2->TRB_CANT	:= TRB2->TRB_CANPEN
			If !empty(cAlmDef2)
				TRB2->TRB_ALMACE := cAlmDef2
			EndIf
		Else
			TRB2->TRB_OK	:= "  "
			TRB2->TRB_CANT:= 0
		EndIf
		TRB2->(MsUnlock())
	Else
		RecLock("TRB2",.F.)
		If !lInverte2
			TRB2->TRB_OK	:= "  "
			TRB2->TRB_CANT:= 0
		Else
			TRB2->TRB_OK	:= cMarca
			TRB2->TRB_CANT:= TRB2->TRB_CANPEN
			If !empty(cAlmDef2)
				TRB2->TRB_ALMACE := cAlmDef2
			EndIf
		EndIf
		TRB2->(MsUnlock())
	EndIf
	nCanPen2	:= TRB2->TRB_CANT
	cAlmEnt2	:= TRB2->TRB_ALMACE
	oCanPen2:Refresh()
	oAlmEnt2:Refresh()
	oDlg4:Refresh()

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Marca2Tudo ³Autor ³Gpe Santacruz   ³ Data  ³ 14/03/16        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Seleciona todos los items del MarkBrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³Marca2Tudo()  	  	   								            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.-Marca para el browse                                  ³±±
±±³          ³oExp1.-Cuadro de dialogo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Factura                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Marca2Tudo(cMarca,oDlg4)

	Local nRecno:= TRB2->(Recno())

	While ! TRB2->(Eof())
		RecLock("TRB2",.F.)
		If Empty(TRB2->TRB_OK)
			TRB2->TRB_OK	:= cMarca
			TRB2->TRB_CANT:= TRB2->TRB_CANPEN
		Else
			TRB2->TRB_OK		:= " "
			TRB2->TRB_CANT	:=	0
			TRB2->TRB_ALMACE	:= ' '
		EndIf
		TRB2->(MsUnlock())
		TRB2->(DbSkip())
	EndDo
	TRB2->(DbGoto(nRecno))
	oDlg4:Refresh()

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT477ARefCant³ Autor ³Gpe Santacruz       ³ Data ³ 14/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Refresca la cantidad extraida en el encabezado, cuando     ³±±
±±³          ³ cambia de linea                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Extraccion por Factura                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT477ARefCant()

	CCodPrd2 := TRB2->TRB_PRODUC+"      "+TRB2->TRB_DESC +"       "+TRB2->TRB_UM
	nCanPen2 := TRB2->TRB_CANT
	cAlmEnt2 := TRB2->TRB_ALMACE

	oCanPen2:Refresh()
	oAlmEnt2:Refresh()
	oPrd2:REFRESH()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT477ACtaAcols³Autor ³Gpe Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Refresca el aCols del Items de Facturas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT477ACtaAcols()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Factura                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT477ACtaAcols()

	Local nPosPrd		:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_PRODUC"})
	Local nPosAlm		:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_ALMACE"})
	Local nPosCan		:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_CANT"})
	Local nPosItDoc	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2])=="RSE_ITEM"})
	Local npositem	:= aScan(oGetItemF:aHeader,{|x| Trim(x[2])=="RSF_ITEM"})

	Local nPosFac		:= aScan(oGetFacts:aHeader,{|x| Trim(x[2])=="RSE_FACT"})
	Local nPosSer		:= aScan(oGetFacts:aHeader,{|x| Trim(x[2])=="RSE_SERIE"})
	Local nPosProv	:= aScan(oGetFacts:aHeader,{|x| Trim(x[2])=="RSE_PROV"})
	Local nPosTda		:= aScan(oGetFacts:aHeader,{|x| Trim(x[2])=="RSE_TDA"})

	Local nPos			:= 0
	Local nx			:= 0
	Local aPos			:= {}
	Local cItem		:= Strzero(1,TAMSX3("RSF_ITEM")[1])
	Local nItem		:= 0
	Local cItDoc		:= ''
	Local nPosCF		:= GdFieldPos("RSE_PROV"  , oGetFacts:aHeader)
	Local nPosLoj		:= GdFieldPos("RSE_TDA"   , oGetFacts:aHeader)
	Local nPosIt1		:= GdFieldPos("RSE_ITEM"  , oGetFacts:aHeader)
	Local nPosIt2		:= GdFieldPos("RSF_ITEDOC", oGetItemF:aHeader)
	Local nPosVldesc	:= GdFieldPos("RSF_VLDESC", oGetItemF:aHeader)
	Local ny			:= 0

	If !msgyesno(STR0027) //"Se actualizaran los datos de los Items, de acuerdo a la seleccion realizada. Continuar?"
		Return
	EndIf

	cursorwait()
	For ny := 1 To Len(oGetItemF:aCols)
		oGetItemF:aCols[ny][Len(oGetItemF:aCols[ny])] := .t.
		oGetItemF:NAT := ny
		MT447DEL2()
	Next

	oGetItemF:aCols := {}
	oGetItemF:FORCEREFRESH()

	MaFisAlt("NF_VALMERC"	, 0, oGetFacts:NAT)
	MaFisAlt("NF_TOTAL"		, 0, oGetFacts:NAT)
	MaFisAlt("NF_DESCONTO"	, 0, oGetFacts:NAT)

	MT447Refresh()

	cItDoc := oGetFacts:aCols[oGetFacts:NAT,nPosItDoc]

	SX3->(DBSetOrder(2))
	TRB2->(DBGoTop())
	Do While !TRB2->(Eof())
		If !Empty(TRB2->TRB_OK)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona nuevo registro en el aCols ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(oGetItemF:aCols,Array(Len(oGetItemF:aHeader)+1))
			nItem := Len(oGetItemF:aCols) //120411

			For nX := 1 To Len(oGetItemF:aHeader)
				do case
					Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_ITEDOC"
						oGetItemF:aCols[nitem][nX] := cItDoc
				endcase
			Next nX

			oGetItemF:aCols[Len(oGetItemF:aCols)][Len(oGetItemF:aHeader)+1] := .F.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Actualiza el aCols con la informacion de de SD1 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To Len(oGetItemF:aHeader)
				Do Case
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_ITEM"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_ITEM
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_ITEDOC"
					oGetItemF:aCols[nItem][nX] := cItDoc
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_PRODUC"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_PRODUC
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_TOTAL"
					oGetItemF:aCols[nItem][nX] :=  TRB2->TRB_CANT * TRB2->TRB_PRECIO
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_CANT"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_CANT
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_PRECIO"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_PRECIO
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_VLDESC"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_VLDESC				
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_PEDIDO"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_OC
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_ITEMPC"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_ITEOC
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_DESC"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_DESC
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_TES"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_TES
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_ALMACE"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_ALMACE
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_UM"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_UM
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_UM2"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_UM2
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_CC"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_CC
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_CLVL"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_CLVL
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_CONTA"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_CONTA
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_ITCTA"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_ITCTA
				Case Trim(oGetItemF:aHeader[nX][2]) == "RSF_CANUM2"
					oGetItemF:aCols[nItem][nX] := TRB2->TRB_CANT*TRB2->TRB_CANUM2/TRB2->TRB_CANTOT
				Case SubStr(Trim(oGetItemF:aHeader[nX][2]),1,9) $ "RSF_ALIMP"
					cImp := SubStr(Trim(oGetItemF:aHeader[nX][2]),10,1)
					oGetItemF:aCols[nItem][nX] := &("TRB2->TRB_ALQIM"+cImp)
				Case SubStr(Trim(oGetItemF:aHeader[nX][2]),1,9) $ "RSF_VLIMP"
					cImp := SubStr(Trim(oGetItemF:aHeader[nX][2]),10,1)
					If &("TRB2->TRB_VALIM"+cImp) > 0
						oGetItemF:aCols[nItem][nX] := &("TRB2->TRB_VALIM"+cImp)*TRB2->TRB_CANT/TRB2->TRB_CANTOT
					EndIf
				Case SubStr(Trim(oGetItemF:aHeader[nX][2]),1,9) $ "RSF_BSIMP"
					cImp := SubStr(Trim(oGetItemF:aHeader[nX][2]),10,1)
					If &("TRB2->TRB_BASIM"+cImp)>0
						oGetItemF:aCols[nItem][nX] := &("TRB2->TRB_BASIM"+cImp)*TRB2->TRB_CANT/TRB2->TRB_CANTOT
					EndIf
				OtherWise
					If Empty(oGetItemF:aCols[nItem,nX])
						oGetItemF:aCols[nItem,nX] := CriaVar(oGetItemF:aHeader[nX][2])
					EndIf
				EndCase
			Next nX
			cItem  :=  Soma1(citem)

			//Permite agregar mas campos que se pueden extraer de la sd1->RSF
			If (ExistBlock("MT477RSF"))
				oGetItemF:aCols:=ExecBlock("MT477RSF",.F.,.F.,{oGetFacts:aCols[oGetFacts:nat,nposFac],oGetFacts:aCols[oGetFacts:nat,nposSer],oGetFacts:aCols[oGetFacts:nat,nposProv],oGetFacts:aCols[oGetFacts:nat,nposTda],TRB2->TRB_PRODUC,TRB2->TRB_ITEM,oGetItemF:aCols,oGetItemF:aHeader})
			EndIf

			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Crea arreglo para poder hacer uso de la funcion MAFISREF, que es ejecutada³
			//³en casi todos los campos (x3_valid), de RSF                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			If !MaFisFound("NF")
				If !Empty(oGetFacts:aCols[oGetFacts:nat][nPosCF]) .And.!Empty(oGetFacts:aCols[oGetFacts:nat][nPosLoj])
					MaFisIni(oGetFacts:aCols[oGetFacts:nat][nPosCF],oGetFacts:aCols[oGetFacts:nat][nPosLoj],"F","N",Nil,aRefImpos,,.T.)
				EndIf
			EndIf
			If MaFisFound()
				MaFisIniLoad(nItem) //inicia la estructura del arreglo aNfItem
				For nX := 1 To Len(aRefImpRSF)
					nPosC:= GdFieldPos(aRefImpRSF[nX][2],oGetItemF:aHeader)
					If nposc == 0
						msgAlert(STR0028+aRefImpRSF[nX][2] +STR0029) //" No encontro campo "+aRefImpRSF[nX][2] +" en el encabezado del oGetItemF"
					EndIf
					MaFisLoad(aRefImpRSF[nX][3],oGetItemF:aCols[nItem,nPosC],nItem)  //Carga valores a aNfItem

				Next nX
				MaFisEndLoad(nItem)
			EndIf

			//Valida que la linea tenga todo lo necesario
			oGetItemF:NAT	:= nItem
			lRetorno		:= MT447LOk2()

			//Refresca el getdados ya con el acosl incluido
			nPos	:= oGetItemF:OBROWSE:NROWPOS
			oGetItemF:FORCEREFRESH()
			oGetItemF:GoTo(nPos)

		EndIf
		TRB2->(DBSkip())
	EndDo
	CursorArrow()

Return
