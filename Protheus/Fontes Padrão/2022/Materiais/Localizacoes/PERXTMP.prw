#include 'protheus.ch'
#include 'parmtype.ch'

//Funciones para tablas temporales de rutina CTBR402 ctbr118 FISR011 FISR012 y todos ls libros fiscales de Peru
/*/{Protheus.doc} CTBR402CT
Creación de tablas temporales de rutina CTBR402
@type method
@author luis.enriquez
@since 11/07/2019
@version 1.0
@example
CTBR402CT(aCampos, cTipo, lAnalit, FunName())
@see (links_or_references)
/*/
Function CTBR402CT(aCampos, cTipo, lAnalit, cFunName)
	Local aChave := {}
	oTmpTable := FWTemporaryTable():New("cArqTmp")
	oTmpTable:SetFields( aCampos )

	//Creación de índices
	If cTipo == "1" //Razao por Conta
	    If cFunName <> "CTBC402"
			aChave   := {"CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
		Else
			aChave   := {"CONTA","DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA"}
		EndIf
	ElseIf cTipo == "2" //Razao por Centro de Custo
		If lAnalit 		//Analítico
			If cFunName <> "CTBC440"
				aChave 	:= {"CCUSTO","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
			Else
				aChave 	:= {"CCUSTO","CONTA","DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI", "LINHA"}
			EndIf
		Else
			aChave 	:= {"CCUSTO","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
		Endif
	ElseIf cTipo == "3" //Razao por Item Contabil
		If lAnalit 		//Analítico
			If cFunName <> "CTBC480"
				aChave 	:= {"ITEM","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
			Else
				aChave 	:= {"ITEM","CONTA","DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA"}
			Endif
		Else
			aChave 	:= {"ITEM","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
		Endif
	ElseIf cTipo == "4" //Razao por Classe de Valor
		If cPaisLoc == "PER"
			If lAnalit	//Analítico
				If cFunName <> "CTBC490"
					aChave 	:= {"SEGOFI","NIT","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
				Else
					aChave 	:= {"SEGOFI","NIT","CONTA","DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA"}
				EndIf
			Else
				aChave 	:= {"SEGOFI","NIT","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
			Endif
		Else
			If lAnalit	//Analítico
				If cFunName <> "CTBC490"
					aChave 	:= {"NIT","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
				Else
					aChave 	:= {"NIT","CONTA","DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA"}
				EndIf
			Else
				aChave 	:= {"NIT","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
			Endif
		EndIf
	EndIf

	oTmpTable:AddIndex('T1', aChave)
	oTmpTable:Create()
	dbSelectArea("cArqTmp")
Return

/*/{Protheus.doc} CTBR402ET
Borrado de tablas temporales de rutina CTBR402
@type method
@author luis.enriquez
@since 11/07/2019
@version 1.0
@example
CTBR402ET()
@see (links_or_references)
/*/
Function CTBR402ET()
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
Return

//Funciones para tablas temporales de rutina FISR011
/*/{Protheus.doc} FISR011CT
Creación de tablas temporales de rutina FISR011
@type method
@author luis.enriquez
@since 11/07/2019
@version 1.0
@example
FISR011CT(cTmpTri)
@see (links_or_references)
/*/
Function FISR011CT(cTmpTri,aOrdem)

	Local aEstTRI := {}

	aAdd(aEstTRI, {'F3_NFISCAL'	, 'C', TamSX3('F3_NFISCAL')[1]	, 0})
	aAdd(aEstTRI, {'F3_SERIE'	, 'C', TamSX3('F3_SERIE')[1]	, 0})
	aAdd(aEstTRI, {'F3_CLIEFOR'	, 'C', TamSX3('F3_CLIEFOR')[1]	, 0})
	aAdd(aEstTRI, {'F3_LOJA'	, 'C', TamSX3('F3_LOJA')[1]		, 0})
	aAdd(aEstTRI, {'TRIBUTO'	, 'N', 14, 2})


	oTmpTable := FWTemporaryTable():New(cTmpTri)

	oTmpTable:SetFields( aEstTRI )


	oTmpTable:AddIndex("I1", aOrdem)

	oTmpTable:Create()

	TRI->(DbGoTop())

	Do While TRI->(!Eof())
		RecLock(cTmpTri,.T.)

		(cTmpTri)->TRIBUTO	  := TRI->TRIBUTO
		(cTmpTri)->F3_NFISCAL  := TRI->F3_NFISCAL


		(cTmpTri)->F3_SERIE	  := TRI->F3_SERIE
		(cTmpTri)->F3_CLIEFOR  := TRI->F3_CLIEFOR
		(cTmpTri)->F3_LOJA	  := TRI->F3_LOJA

		(cTmpTri)->(MsUnlock())
		TRI->(dbSkip())
	EndDo
	TRI->(DbCloseArea())
Return

/*/{Protheus.doc} FISR011ET
Borrado de tablas temporales de rutina FISR011
@type method
@author luis.enriquez
@since 11/07/2019
@version 1.0
@example
FISR011ET()
@see (links_or_references)
/*/
Function FISR011ET()
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
Return

//Funciones para tablas temporales de rutina FINR121
/*/{Protheus.doc} FINR121CT
Creación de tablas temporales de rutina FINR121
@type method
@author veronica.flores
@since 11/07/2019
@version 1.0
@example
FINR121CT(aCpo,cAliasPer)
@see (links_or_references)
/*/
Function FINR121CT(aCpo,cAliasPer)
	aOrdem := {"E5_DATA", "CT1_CTASUP"}
	oTmpTable := FWTemporaryTable():New(cAliasPer)
	oTmpTable:SetFields(aCpo)
	oTmpTable:AddIndex("IN1", aOrdem)
	oTmpTable:Create()
Return

//Funciones para tablas temporales de rutina MATR264
/*/{Protheus.doc} MATR264CT
Creación de tablas temporales de rutina MATR264
@type method
@author luis.enriquez
@since 11/07/2019
@version 1.0
@example
MATR264CT(aCpo,cAliasPer)
@see (links_or_references)
/*/
Function MATR264CT(aCampos)
	Local aOrdem	:=	{"PRODUTO","XIDESTAB","XLOCAL","XTPESTAB","FILIAL","EMISSAO","NODIA","TES"}


	//Creacion de Objeto
	oTmpTable := FWTemporaryTable():New("TRB")
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("I1", aOrdem)
	//Creacion de la tabla
	oTmpTable:Create()
Return

//Funciones para calculos de los Libros CTBR118 FISR012 CTBR402
/*/{Protheus.doc} DetIGVFnPeru
Verifica si las detracciones estan pagadas
@type method
@author
@since
@version 1.0
@example
@see
/*/

Function DetIGVFnPeru(cCodFor,cLojaFor,dDataIni,dDataFim)
Local aArea	:= GetArea()
Local cQry	:= GetNextAlias()
Local aRet	:= {}

	BeginSql Alias cQry
		SELECT
			SE5.E5_PREFIXO PREFIXO,
			SE5.E5_NUMERO NUMERO,
			SE5.E5_DATA DTMOV,
			SE5.E5_VALOR VALOR,
			SE5.E5_PARCELA PARCELA,
			SEK.EK_PREFIXO PRFPAGO,
			SEK.EK_NUM NUMPAGO,
			SEK.EK_PARCELA,
			SEK.EK_TIPO TIPO,
			SEK.EK_VALOR VALPAGO

		FROM
			%Table:SE5% SE5 LEFT JOIN %Table:SEK% SEK ON SE5.E5_ORDREC = SEK.EK_ORDPAGO  AND SEK.EK_FILIAL = %Exp:xFilial('SEK')% AND
			SEK.EK_TIPO = %Exp:'TX'% AND	SEK.%NotDel%

		WHERE
			SE5.E5_FILIAL = %Exp:xFilial('SE5')% AND
			SE5.E5_TIPO = %Exp:'TX'% AND
			SE5.E5_DATA BETWEEN %Exp:DtoS(dDataIni)% AND %Exp:DtoS(dDataFim)% AND
			SE5.E5_CLIFOR = %Exp:cCodFor% AND
			SE5.E5_LOJA = %Exp:cLojaFor% AND
			SE5.%NotDel%

		ORDER BY
			SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_DATA
	EndSql

	(cQry)->(dbGoTop())

	While !(cQry)->(Eof())
		aAdd(aRet,{(cQry)->PREFIXO,(cQry)->NUMERO,(cQry)->DTMOV,(cQry)->VALOR, (cQry)->PARCELA ,{(cQry)->PRFPAGO,(cQry)->NUMPAGO,(cQry)->PARCELA,(cQry)->TIPO,(cQry)->VALPAGO}})
		(cQry)->(dbSkip())
	EndDo

	(cQry)->(dbCloseArea())

RestArea(aArea)
Return aRet

//Funciones usadas para CTBR118 Y CTBR402
Function fFindA12Peru( cForCte,cLoj,cTpp,cAlias )
	Local _aInfo	:= {}
	Local _lTem		:= .F.

	Default cAlias	:= ""

	If cTpp == "V" .Or. cAlias == "SEL"
		SA1->( dbSetOrder(1) )//A1_FILIAL+A1_COD+A1_LOJA
		If SA1->( dbSeek( xFilial("SA1")+cForCte+cLoj) )
			Aadd( _aInfo, { alltrim(str(val(SA1->A1_TIPDOC))),  Iif ((alltrim (SA1->A1_PFISICA) == "-") ,"", SA1->A1_PFISICA)  ,SA1->A1_CGC,"" } )
			_aInfo[len(_aInfo),2] := strtran(_aInfo[len(_aInfo),2],"-","")
			_aInfo[len(_aInfo),3] := strtran(_aInfo[len(_aInfo),3],"-","")
			_lTem := .T.
		EndIf
	Endif

	If cTpp == "C" .Or. cAlias == "SEK"
		If !_lTem
			SA2->( dbSetOrder(1) )//A2_FILIAL+A2_COD+A2_LOJA
			If SA2->( dbSeek( xFilial("SA2")+cForCte+cLoj) )
				Aadd( _aInfo, { alltrim(str(val(SA2->A2_TIPDOC))), Iif ((alltrim (SA2->A2_PFISICA) == "-") ,"", SA2->A2_PFISICA)  ,SA2->A2_CGC,SA2->A2_DOMICIL } )
				_aInfo[len(_aInfo),2] := strtran(_aInfo[len(_aInfo),2],"-","")
				_aInfo[len(_aInfo),3] := strtran(_aInfo[len(_aInfo),3],"-","")
				_lTem := .T.
			EndIf
		EndIf
	endif

	If cTpp == "5" .Or. (cPaisLoc == "PER" .And. cTpp == "F") // Movimiento financiero o (Perú & Orden de Pago/Recibo de Cobro -> Banco)
		If !_lTem
			SA6->( dbSetOrder(3) )//A6_FILIAL+A6_CGC
			If SA6->( dbSeek( xFilial("SA6")+cForCte ) )
				if !empty(SA6->A6_CGC)
					Aadd( _aInfo, { "6","",SA6->A6_CGC,"" } )
					_aInfo[len(_aInfo),2]:=strtran(_aInfo[len(_aInfo),2],"-","")
				else
					Aadd( _aInfo, { "0","","00000000000","" } )
				endif
				_lTem := .T.
			EndIf
		EndIf
	Endif

	If Len(_aInfo) == 0
		Aadd( _aInfo, { "","","","" } )
	Endif

Return(_aInfo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PERXFIS   ºAutor  ³Microsiga           ºFecha ³  12/16/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fgenAnidado(cDocX,cFornece,dPFecIni,dPFecFin,cCodLibr,cSegofi,cContAux,cXFilial)

	local harea := getArea()
	local klin := ""
	local cParc := Padr(Alltrim(GetMV("MV_1DUP")),TamSX3("E2_PARCELA")[1])

	cTipDoc := ""
	cOserie := ""
	cTienda := ""
	cMovtip := ""
	cEspecie:= ""
	nDetra  := 0
	cFilSF3 := ""
	dFechsf3:= ctod("  /  /  ")
	cDctb   := ""
	cF1doc  := ""
	cOtienda:=''
	cOtienda := Posicione("SF3",6,xfilial("SF3")+cDocX,"F3_LOJA")
	If 	empty(cOtienda)
		cOtienda:= Posicione("SA2",1,xfilial("SA2")+cFornece,"A2_LOJA")
	endif
	SF3->( dbSetOrder(4) ) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
	SF1->( dbSetOrder(2) ) //F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
	IF SF3->( MsSeek( xFilial("SF3")+cFornece+cOtienda+cDocX ) )
		cTipDoc := SF3->F3_TPDOC
		cOserie := SF3->F3_SERIE
	   cTienda := SF3->F3_LOJA
	   cMovtip := SF3->F3_TIPOMOV
	   cEspecie:= SF3->F3_ESPECIE
	   nDetra  := SF3->F3_VALIMP5
	   cFilSF3 := SF3->F3_FILIAL
	   dFechsf3:= SF3->F3_EMISSAO
	ENDIF
	IF SF1->( MsSeek( xFilial("SF1")+cFornece+cOtienda+cDocX ) )
	   cTipDoc := SF1->F1_TPDOC
	   cDctb   := SF1->F1_DIACTB
	   cF1doc  := SF1->F1_DOC
	ENDIF

	cMesInic := SUBSTR(DtoS(dPFecIni),5,2) //Mes Inicial Selecionado
	cAnoInic := SUBSTR(DtoS(dPFecIni),3,2) // Ano Incial Selecionado
	cMesFin  := SUBSTR(DtoS(dPFecFin),5,2) //Mes Final Selecionado
	cAnoFin  := SUBSTR(DtoS(dPFecFin),3,2) // Ano Final Selecionado

	If Alltrim(cMesInic) == "01"
		cMesInic := "12"
		cAnoInic := Str(Val(cAnoInic)-1)
	Else
		cMesInic :=	Strzero(Val(cMesInic)-1,2)
	EndIF

	dDUtilInic := RetDiaUtil(cMesInic, cAnoInic) //  Retorna o Quinto dia util do mes Inicial selecionado
	dDUtilFin  := RetDiaUtil(cMesFin, cAnoFin) //  Retorna o Quinto dia util do proximo mes Final selecionado
	SE2->(DbGoTop())
	SE2->(dbSetOrder(6))//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If cMovtip="C" .And. alltrim(cEspecie)="NF" .And. cTipDoc="14"
		cFilSE2:=IIF(!EMPTY(xFilial('SE2')),cXFilial,XFILIAL('SE2'))

		If SE2->(Dbseek(cFilSE2+cFornece+cTienda+cOserie+cDocX)) //Procura o titulo TX no SE2, se encontrar deve imprimir
			cVcto := SE2->E2_VENCTO
			dBaixa:= SE2->E2_BAIXA
			If empty(dBaixa)
				klin := ""
			else
				If dBaixa>dPFecFin
					klin := ""
				Else
					klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
				endif
			EndIF
		EndIf

	ElseIf ALLTRIM(cMovtip)="C" .And. ALLTRIM(cEspecie)="NF" .And. nDetra>0

		cFilSE2:=IIF(!EMPTY(xFilial('SE2')),cXFilial,XFILIAL('SE2'))
		SE2->(Dbseek(cFilSE2+cFornece+cTienda+cOserie+cDocX+cParc)) //Procura o titulo TX no SE2, se encontrar deve imprimir
		dBaixa:= SE2->E2_BAIXA
		aRet := DetIGVFnPeru(cFornece,cTienda,(dDUtilInic-30),(dDUtilFin)) // Preenche o array aRet de acordo com a funcao
		nPos :=Ascan(aRet,{|x| x[1]+x[2]+x[5] == SE2->E2_PREFIXO+SE2->E2_NUM+cMV_1DUP})

		If nPos>0 .and. dFechsf3 <= dPFecFin .AND. cEspecie='NF' .AND. dBaixa<= dPFecFin
			cPrefixo := aRet[nPos,1]//Prefixo
			cNumero  := aRet[nPos,2]// Numero do Titulo
			cParcela := aRet[nPos,5]// Parcela
			cTipo := "TX"  			// Tipo que deve ser TX
			cFilSE2:=IIF(!EMPTY(xFilial('SE2')),cXFilial,XFILIAL('SE2'))
			dSfefecha:=Posicione("SFE",4,xfilial("SFE")+cFornece+cTienda+cNumero+cPrefixo,"FE_EMISSAO")

			If ALLTRIM(cNumero) == ALLTRIM(cDocX)//Verifica se o titulo do aRet e o mesmo do TRB4
				cProve:= cFornece
				SE2->(DbGoTop())
				SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If SE2->(Dbseek(cFilSE2+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
					SE2->(dbSetOrder(6))//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If SE2->(Dbseek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
						dFecha:=SE2->E2_BAIXA
						If dBaixa<(dPFecIni) .AND. dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>=(dPFecIni)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf (dBaixa)<(dPFecIni) .AND. dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)<(dPFecIni) .AND. (dSfefecha)>=(dPFecIni) .AND. Ctod(dSfefecha)<=(dPFecFin)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dDUtilFin)
							If dFecha<=(dBaixa) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf dFecha<=(dBaixa) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dBaixa)>(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf (dBaixa)>(dDUtilInic) .AND. dFecha>(dDUtilInic) .AND. (dBaixa)<=(dPFecFin) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. (dBaixa)<=(dPFecFin) .AND. dFecha<=(dPFecFin).AND. (dFechsf3)<(dPFecIni-31)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf (dBaixa)<(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dFechsf3)<(dPFecIni-31)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dDUtilInic) .AND. (dBaixa)<=(dDUtilInic)  // F3_ENTRADA
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf (dBaixa)>(dDUtilInic) .AND. dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dBaixa)<=(dPFecFin) .AND. (dFechsf3)>(dPFecIni-31) .AND. (dFechsf3)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>(dPFecIni-31) .AND. (dFechsf3)<(dPFecIni) .AND. (dBaixa)>(dDUtilInic) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>(dPFecIni-31) .AND. (dFechsf3)<(dPFecIni) .AND. (dBaixa)>=(dPFecIni) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							Else
								klin := ""
							EndIf
						ElseIf (dBaixa)<(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dFechsf3)<(dPFecIni-31)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf (dBaixa)<(dPFecIni) .AND. dFecha<=(dDUtilInic)
							klin := ""
						Else
							klin := ""
						Endif
					Endif
				EndIf
			Endif

		ElseIf nPos>0 .and. dFechsf3 <= dPFecFin .AND. cEspecie='NF' .AND. dBaixa > dPFecFin
			cPrefixo := aRet[nPos,1]//Prefixo
			cNumero  := aRet[nPos,2]// Numero do Titulo
			cParcela := aRet[nPos,5]// Parcela
			cTipo := "TX"  			// Tipo que deve ser TX
			cFilSE2:=IIF(!EMPTY(xFilial('SE2')),cXFilial,XFILIAL('SE2'))
			dSfefecha:=Posicione("SFE",4,xfilial("SFE")+cFornece+cTienda+cNumero+cPrefixo,"FE_EMISSAO")

			If ALLTRIM(cNumero) == ALLTRIM(cDocX) //Verifica se o titulo do aRet e o mesmo do TRB4
				cProve:= cFornece
				SE2->(DbGoTop())
				SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If SE2->(Dbseek(cFilSE2+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
					SE2->(dbSetOrder(6))//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If SE2->(Dbseek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
						dFecha:=SE2->E2_BAIXA
						If dBaixa<(dPFecIni) .AND. dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>=(dPFecIni)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf (dBaixa)<(dPFecIni) .AND. dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)<(dPFecIni) .AND. (dSfefecha)>=(dPFecIni) .AND. Ctod(dSfefecha)<=(dPFecFin) //--ORIGINAL
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dDUtilFin)
							If dFecha<=(dBaixa) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIf dFecha<=(dBaixa) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dBaixa)>(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF (dBaixa)>(dDUtilInic) .AND. dFecha>(dDUtilInic) .AND. (dBaixa)<=(dPFecFin) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. (dBaixa)<=(dPFecFin) .AND. dFecha<=(dPFecFin).AND. (dFechsf3)<(dPFecIni-31)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF (dBaixa)<(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dFechsf3)<(dPFecIni-31)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF (dBaixa)>=(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dDUtilInic) .AND. (dBaixa)<=(dDUtilInic)  // F3_ENTRADA
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF (dBaixa)>(dDUtilInic) .AND. dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dBaixa)<=(dPFecFin) .AND. (dFechsf3)>(dPFecIni-31) .AND. (dFechsf3)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>(dPFecIni-31) .AND. (dFechsf3)<(dPFecIni) .AND. (dBaixa)>(dDUtilInic) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							ElseIF dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. (dFechsf3)>(dPFecIni-31) .AND. (dFechsf3)<(dPFecIni) .AND. (dBaixa)>=(dPFecIni) .AND. (dBaixa)<=(dPFecFin)
								klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
							Else
								klin := ""
							EndIf
						ElseIf (dBaixa)<(dPFecIni) .AND. dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dFechsf3)<(dPFecIni-31)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf dFecha>=(dPFecIni) .AND. dFecha<=(dPFecFin) .AND. (dFechsf3)>=(dPFecIni) .AND. (dFechsf3)<=(dPFecFin)
							klin := cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
						ElseIf (dBaixa)<(dPFecIni) .AND. dFecha<=(dDUtilInic)
							klin := ""
						Else
							klin := ""
						Endif
					Endif
				EndIf
			Endif
		EndIf
	ElseIf cMovtip="C" .And. cEspecie="NF" .And. cDctb<>"08"
		klin := ""
	ElseIf ALLTRIM(cF1doc)==ALLTRIM(cDocX) .And. cDctb="14" .And. cMovtip="C"
		klin := ""
	Else
		klin += cCodLibr+"&"+SubStr(DTOS(dPFecIni),1,6)+"00&"+AllTrim(cSegofi)+"&"+cContAux
	EndIf

	restArea(harea)

Return(klin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PERXFIS   ºAutor  ³Microsiga           ºFecha ³  12/16/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fDocOri(cCTK_KEY, cCTL_ALIAS, cCTL_ORDER, _pLp, cCTL_KEY, cCT2_NODIA, cCT1_CONTA, cCT2_AGLUT)
Local vArea		:= getArea()
Local cDoc		:= ''
Local cSer		:= ''
Local cFor		:= ''
Local cLoj		:= ''
Local cSe2		:= ''
Local cSe3		:= ''
Local cTp		:= ''
Local cTpD		:= ''
Local cEmi		:= ''
Local aRet		:= {}
Local cCond		:= ""
Local cAliasS3	:= "TMPS3"
Local lBorrado	:= .F.
Local nX		:= 0
Local cAlTab	:= ""
Local aCposKey	:= {}
Local aCpos		:= {}
Local cKey		:= ""
Local cDatos	:= ""
Local cTxt		:= ""
Local cCpos		:= ""
Local cTab		:= ""
Local lControl	:= .F.
Local lExiste	:= .F.
Local cNODIA	:= ""
Local cCampo	:= ""
Local nMonOri	:= 0
Local cFilSE5	:= ""
Local cActPas	:= "12,13,14,16,17,19,42,43,46,47,49"	// Cuentas de activo/pasivo que requiren número del comprobante de cobro/pago
Local cFilSEK	:= ""
Local cOrdPago	:= ""
Local cFilSEL	:= ""
Local cRecibo	:= ""
Local cTipo		:= ""
Local nPos		:= 0
Local nLen1		:= 0
Local nLen2		:= 0
Local cClave	:= ""
Local cBanco	:= ""
Local cAgen		:= ""
Local cCta		:= ""

DEFAULT cCTL_KEY	:= ""
DEFAULT cCT2_NODIA	:= ""
DEFAULT cCT1_CONTA	:= ""
DEFAULT cCT2_AGLUT	:= ""

If !empty(_pLp)

	If !empty(cCTK_KEY) .and. !empty(cCTL_ALIAS)
		DBSELECTAREA(cCTL_ALIAS)
		DBSETORDER(VAL(cCTL_ORDER))

		lExiste	:= MsSEEK(Alltrim(cCTK_KEY))

		If cPaisLoc == "PER" .And. (!lExiste .Or. cCTL_ALIAS$"SF1/SD1/SF2/SD2/SEK/SEL/SE5/SE1/SE2") .And. !Empty(cCTL_KEY)
			/* NF compra/venta - Tratamiento por cambio en la longitud del campo de número de documento si:
			   - No encontró la clave según CT2_KEY
			   - Si la encuentra y es tabla de facturas de compras/ventas, comprobar que sea el registro esperado
			*/
			If !lExiste .Or. !( Alltrim(cCTK_KEY) == Alltrim(&(cCTL_KEY)) )
				// aCposKey: Campos que componen la clave
				// aCpos: {contenido, longitud anterior, longitud actual} de cada campo en CT2_KEY, según el diccionario
				aCposKey := StrTokArr(cCTL_KEY, "+")
				cDoc := Substr(cCTL_ALIAS,2) + IIf( cCTL_ALIAS$"SF1/SD1/SF2/SD2", "_DOC", IIf(cCTL_ALIAS$"SEK/SE1/SE2", "_NUM", "_NUMERO") )

				For nX := 1 to Len(aCposKey)
					If Substr(aCposKey[nX],1,5) == "DTOS("
						nLen2 := 8
					Else
						nLen2 := GetSx3Cache(aCposKey[nX],"X3_TAMANHO")
					EndIf

					If aCposKey[nX] == cDoc .And. nLen2 == 20
						nLen1 := 13		// Longitud anterior de número de nota fiscal era = 13
					Else
						nLen1 := nLen2
					Endif

					aAdd( aCpos , { Substr(cCTK_KEY, nPos + 1, nLen1 ), nLen1, nLen2 } )
					nPos += nLen1
				Next nX

				// Regenera expresión
				aEval( aCpos , { |x| cClave += PadR(x[1],x[3]) } )

				// Buscar nuevamente y verificar si el registro corresponde a los campos en el Key.
				msSeek(Alltrim(cClave))
				lExiste	:= ( Alltrim(cClave) == Alltrim(&(cCTL_KEY)) )

				aSize(aCposKey, 0)
				aSize(aCpos, 0)
				cDoc := ""
			EndIf
		EndIf

		If lExiste

			Do Case
			  	Case cCTL_ALIAS$"SF1/SD1"
			  		If cCTL_ALIAS == "SD1"
			  			cDoc := SD1->D1_DOC
				   		cSer := SD1->D1_SERIE
				   		cFor := SD1->D1_FORNECE
						cLoj := SD1->D1_LOJA
						cSe2 := ''
					    cEmi := dtos(SD1->D1_EMISSAO)
						cSe3 := SD1->D1_SERIE
						cTpD := ''
						cTp  := "C"

						SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
		   		        If SF1->(MsSEEK(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
				   		    cSe2 := SF1->F1_SERIE2
				 			cEmi := dtos(SF1->F1_EMISSAO)
							cTpD := SF1->F1_TPDOC

							If Alltrim(SF1->F1_ESPECIE) == "NCC"
								cSe2 := PuxaSer2Peru(cSer)
								cTp := "V"
							Endif

							cNODIA := SF1->F1_NODIA
							nMonOri := SF1->F1_MOEDA
		   		        Endif

		   			Else
			   		    cDoc := SF1->F1_DOC
			   		    cSer := SF1->F1_SERIE
			   		    cSe2 := SF1->F1_SERIE2
			   		    cFor := SF1->F1_FORNECE
						cLoj := SF1->F1_LOJA
						cEmi := dtos(SF1->F1_EMISSAO)

						cSe3 := SF1->F1_SERIE
						cTpD := SF1->F1_TPDOC
						cTp  := "C"

						If alltrim(SF1->F1_ESPECIE) == "NCC"
							cSe2 := PuxaSer2Peru(cSer)
							cTp  := "V"
						Endif

						cNODIA := SF1->F1_NODIA
						nMonOri := SF1->F1_MOEDA

					Endif

					If !Empty(cCT2_NODIA) .And. !(cCT2_NODIA == cNODIA)
						// Ocurre si un documento fue anulado y se volvió a registrar
						lExiste	:= .F.
					EndIf

				Case cCTL_ALIAS$"SF2/SD2"
			  		If cCTL_ALIAS == "SD2"
			  			cDoc := SD2->D2_DOC
				  	    cSer := SD2->D2_SERIE
				   	    cSe2 := ''
				   	    cFor := SD2->D2_CLIENTE
						cLoj := SD2->D2_LOJA
						cEmi := dtos(SD2->D2_EMISSAO)
						cSe3 := SD2->D2_SERIE
						cTpD := ''
						cTp  := "V"

						SF2->(DBSETORDER(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		   		        If SF2->(MsSEEK(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
				   		    cSer := IIf(empty(SF2->F2_SERIE),SF2->F2_SERIE,PuxaSer2Peru(SF2->F2_SERIE))
				   		    cSe2 := SF2->F2_SERIE2
							cSe3 := cSer
							cTpD := SF2->F2_TPDOC
							If Alltrim(SF2->F2_ESPECIE)=="NCP"
								cTp := "C"
							Endif

							cNODIA := SF2->F2_NODIA
							nMonOri := SF2->F2_MOEDA
		   		        Endif

		   			Else
			   		    cDoc := SF2->F2_DOC
			   		    cSer := IIf(empty(SF2->F2_SERIE),SF2->F2_SERIE,PuxaSer2Peru(SF2->F2_SERIE))
			   		    cSe2 := SF2->F2_SERIE2
			   		    cFor := SF2->F2_CLIENTE
						cLoj := SF2->F2_LOJA
						cEmi := dtos(SF2->F2_EMISSAO)
						cSe3 := cSer
						cTpD := SF2->F2_TPDOC
						cTp  := "V"

						If Alltrim(SF2->F2_ESPECIE) == "NCP"
							cTp := "C"
						Endif

						cNODIA := SF2->F2_NODIA
						nMonOri := SF2->F2_MOEDA

					Endif

					If !Empty(cCT2_NODIA) .And. !(cCT2_NODIA == cNODIA)
						// Ocurre si un documento fue anulado y se volvió a registrar
						lExiste	:= .F.
					EndIf

			   	Case cCTL_ALIAS == "SEL"
					cRecibo := EL_RECIBO
					cTp  := EL_TIPO
					cDoc := EL_NUMERO
					cSer := EL_PREFIXO
					cFor := EL_CLIENTE
					cLoj := EL_LOJA
					cEmi := ""
					nMonOri := Val(EL_MOEDA)
					cBanco	:= EL_BANCO
					cAgen	:= EL_AGENCIA
					cCta	:= EL_CONTA

					If cPaisLoc == "PER" .And. cCT2_AGLUT == "1" .And. ((!Empty(cCT1_CONTA) .And. SubStr(cCT1_CONTA,1,2) $ cActPas .And. SEL->EL_TIPODOC <> 'TB') .Or. ;
						(!Empty(cCT1_CONTA) .And. !(SubStr(cCT1_CONTA,1,2) $ cActPas) .And. SEL->EL_TIPODOC == 'TB' .And. SEL->EL_TIPO <> 'RA'))
						// Perú & Agrupación de asientos contables & ( (Cuenta de activo/pasivo & SEL no es registro de baja título) | (No cuenta de activo/pasivo & SEL es registro de baja título))
						// Buscar registro en SEL a través de SQL 

						/*	Debido a la forma en que CTBA105 genera asientos contables agrupados (Query min(CT2_KEY)),
							el resultado en CTK_KEY y CT2_KEY, no es según las expresiones en CTL_KEY, ya que contienen 
							solo los datos de la forma de pago y no de los documentos.
							Es necesario buscar el registro del documento partiendo del número del recibo. Sin embargo, es probable que
							no se obtengan los datos correctos en caso de cobro de más de un documento en el mismo recibo, ya que
							no se cuenta con elementos para relacionar el asiento agrupado con cada registro de detalle del recibo.
						*/

						cFilSEL := SEL->EL_FILIAL
						cTipo := IIF(SEL->EL_TIPODOC <> "TB", "% IN ('NF ','NDC','NCC')%", "% NOT IN ('NF ','NDC','NCC')%")

						BeginSql Alias cAliasS3
							SELECT 
								EL_PREFIXO, EL_NUMERO, EL_TIPO, EL_CLIENTE, EL_LOJA, EL_MOEDA, EL_BANCO, EL_AGENCIA, EL_CONTA
							FROM 
								%table:SEL% SEL
							WHERE
								SEL.EL_FILIAL = %exp:cFilSEL% AND
								SEL.EL_RECIBO = %exp:cRecibo% AND
								SEL.EL_TIPO %exp:cTipo% AND
								%notDel%
						EndSql

						While !(cAliasS3)->(Eof())
							cTp  := (cAliasS3)->EL_TIPO
							cDoc := (cAliasS3)->EL_NUMERO
							cSer := (cAliasS3)->EL_PREFIXO
							cFor := (cAliasS3)->EL_CLIENTE
							cLoj := (cAliasS3)->EL_LOJA
							cEmi := ""
							nMonOri := Val((cAliasS3)->EL_MOEDA)
							cBanco	:= (cAliasS3)->EL_BANCO
							cAgen	:= (cAliasS3)->EL_AGENCIA
							cCta	:= (cAliasS3)->EL_CONTA

							(cAliasS3)->(dbSkip())
						EndDo

						(cAliasS3)->(dbCloseArea())
					EndIf

					If cTp == "NCC"	// EL_TIPO
						SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
						IF SF1->(MsSEEK(xFilial("SF1")+cDoc+cSer+cFor+cLoj))
							cSe3 := SF1->F1_SERIE
							IF EMPTY(SF1->F1_SERIE)
								cSe2 := SF1->F1_SERIE2
							ELSE
								cSe2 := PuxaSer2Peru(SF1->F1_SERIE)
							ENDIF
							cTpD := SF1->F1_TPDOC
							cTp  := "V"
							dEmi := SF1->F1_EMISSAO
						ELSE
							cTpD := '00'
							cTp  := "F"
							cSe3 := ""
						ENDIF

					Else
						SF2->(DBSETORDER(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						IF SF2->(MsSEEK(xFilial("SF2")+cDoc+cSer+cFor+cLoj))
							cSer := SF2->F2_SERIE
							IF EMPTY(SF2->F2_SERIE)
								cSe2 := SF2->F2_SERIE2
							ELSE
								cSe2 := PuxaSer2Peru(SF2->F2_SERIE)
							ENDIF
							cTpD := SF2->F2_TPDOC
							cTp  := "V"
							dEmi := SF2->F2_EMISSAO

						ELSE
							cTpD := '00'
							cTp  := "F"
							cSe3 := ""

							If cPaisLoc == "PER" .And. Substr(cCT1_CONTA,1,2) == "10"
								//Cuenta contable de mayor = Bancos; 
								SA6->( dbSetOrder(1) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
								If SA6->( dbSeek( xFilial("SA6")+cBanco+cAgen+cCta ) )
									If !Empty(SA6->A6_CGC)
										cFor := SA6->A6_CGC
									Else
										cFor := ""
									Endif
								Endif
							Endif

						ENDIF

					ENDIF

			  	Case cCTL_ALIAS == "SEK"
					cOrdPago := EK_ORDPAGO
					cTp  := EK_TIPO
					cDoc := EK_NUM
					cSer := EK_PREFIXO
					cFor := EK_FORNECE
					cLoj := EK_LOJA
					nMonOri	:= Val(EK_MOEDA)
					cBanco	:= EK_BANCO
					cAgen	:= EK_AGENCIA
					cCta	:= EK_CONTA

					If cPaisLoc == "PER" .And. cCT2_AGLUT == "1" .And. !Empty(cCT1_CONTA) .And. SubStr(cCT1_CONTA,1,2) $ cActPas .And. SEK->EK_TIPODOC <> 'TB'
						// Perú & Agrupación de asientos contables & Cuenta = activo/pasivo & SEL no es registro de baja título
						// Buscar registro en SEL a través de SQL 

						/*	Debido a la forma en que CTBA105 genera asientos contables agrupados (Query min(CT2_KEY)),
							el resultado en CTK_KEY y CT2_KEY, no es según las expresiones en CTL_KEY, ya que contienen 
							solo los datos de la forma de pago y no de los documentos.
							Es necesario buscar el registro del documento partiendo del número de OP. Sin embargo, es probable que
							no se obtengan los datos correctos en caso de pagar más de un documento en la misma OP, ya que
							no se cuenta con elementos para relacionar el asiento agrupado con cada registro de detalle de la OP.
						*/

						cFilSEK := SEK->EK_FILIAL

						BeginSql Alias cAliasS3
							SELECT 
								EK_PREFIXO, EK_NUM, EK_TIPO, EK_FORNECE, EK_LOJA, EK_MOEDA, EK_BANCO, EK_AGENCIA, EK_CONTA
							FROM 
								%table:SEK% SEK
							WHERE
								SEK.EK_FILIAL = %exp:cFilSEK% AND
								SEK.EK_ORDPAGO = %exp:cOrdPago% AND
								SEK.EK_TIPODOC <> 'CP' AND
								%notDel%
						EndSql

						While !(cAliasS3)->(Eof())
							cTp  := (cAliasS3)->EK_TIPO
							cDoc := (cAliasS3)->EK_NUM
							cSer := (cAliasS3)->EK_PREFIXO
							cFor := (cAliasS3)->EK_FORNECE
							cLoj := (cAliasS3)->EK_LOJA
							nMonOri	:= Val((cAliasS3)->EK_MOEDA)
							cBanco	:= (cAliasS3)->EK_BANCO
							cAgen	:= (cAliasS3)->EK_AGENCIA
							cCta	:= (cAliasS3)->EK_CONTA

							(cAliasS3)->(dbSkip())
						EndDo

						(cAliasS3)->(dbCloseArea())
					EndIf

					If cTp == "NCP"	// EK_TIPO
						SF2->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
						IF SF2->(MsSEEK(xFilial("SF2")+cDoc+cSer+cFor+cLoj))
							cSe3 := SF2->F2_SERIE
							IF EMPTY(SF2->F2_SERIE)
								cSe2 := SF2->F2_SERIE2
							ENDIF
							cTpD := SF2->F2_TPDOC
							cTp  := "C"
							dEmi := SF2->F2_EMISSAO
						ELSE
							cTpD := '00'
							cTp  := "F"
							cSe3 := ""
						ENDIF

					ELSE
						SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
						IF SF1->(MsSEEK(xFilial("SF1")+cDoc+cSer+cFor+cLoj))
							cSer := SF1->F1_SERIE
							cSe3 := SF1->F1_SERIE
							IF EMPTY(SF1->F1_SERIE)
								cSe2 := SF1->F1_SERIE2
							ENDIF
							cTpD := SF1->F1_TPDOC
							cTp  := "C"
							dEmi := SF1->F1_EMISSAO

						ELSE
							cTpD := '00'
							cTp  := "F"
							cSe3 := ""

							If cPaisLoc == "PER" .And. Substr(cCT1_CONTA,1,2) == "10"
								//Cuenta contable de mayor = Bancos; 
								SA6->( dbSetOrder(1) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
								If SA6->( dbSeek( xFilial("SA6")+cBanco+cAgen+cCta ) )
									If !Empty(SA6->A6_CGC)
										cFor := SA6->A6_CGC
									Else
										cFor := ""
									Endif
								Endif
							Endif

						ENDIF

					ENDIF

			 	Case cCTL_ALIAS == "SE5"
					cSer := E5_PREFIXO
					cDoc := Alltrim(Iif( empty(E5_NUMCHEQ),E5_DOCUMEN,E5_NUMCHEQ ))
					cFor := E5_CLIFOR
					cLoj := E5_LOJA
					nMonOri := Val(E5_MOEDA)
					cBanco	:= E5_BANCO
					cAgen	:= E5_AGENCIA
					cCta	:= E5_CONTA

				 	If Alltrim(cCTL_ORDER) == "1" .And. Empty(E5_NUMCHEQ)
					 	// E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
						// Movimiento bancario sin #Cheque (LP = 560, 561, 562, 563, 564, 565), buscar por NODIA
						cFilSE5 := SE5->E5_FILIAL

						BeginSql Alias cAliasS3
							SELECT 
								E5_PREFIXO, E5_NUMCHEQ, E5_DOCUMEN, E5_CLIFOR, E5_LOJA, E5_MOEDA, E5_BANCO, E5_AGENCIA, E5_CONTA
							FROM 
								%table:SE5% SE5
							WHERE
								SE5.E5_FILIAL = %exp:cFilSE5% AND
								SE5.E5_NODIA = %exp:cCT2_NODIA% AND
								%notDel%
						EndSql

						If (cAliasS3)->(Eof())
							cSer := (cAliasS3)->E5_PREFIXO
							cDoc := (cAliasS3)->(Alltrim(Iif( empty(E5_NUMCHEQ),E5_DOCUMEN,E5_NUMCHEQ )))
							cFor := (cAliasS3)->E5_CLIFOR
							cLoj := (cAliasS3)->E5_LOJA
							nMonOri := Val((cAliasS3)->E5_MOEDA)
							cBanco	:= (cAliasS3)->E5_BANCO
							cAgen	:= (cAliasS3)->E5_AGENCIA
							cCta	:= (cAliasS3)->E5_CONTA
						EndIf

						(cAliasS3)->(dbCloseArea())
					EndIf

					cTpD := '00'
					cTp  := "5"
					cSe3 := ""
					cEmi := ""

					If Empty(cFor) .Or. (cPaisLoc == "PER" .And. Substr(cCT1_CONTA,1,2) == "10")
						SA6->( dbSetOrder(1) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
						If SA6->( dbSeek( xFilial("SA6")+cBanco+cAgen+cCta ) )
							If !empty(SA6->A6_CGC)
								cFor := SA6->A6_CGC
							Else
								cFor := ""
							Endif
						Endif
					Endif

			  	Case cCTL_ALIAS == "SE1"
					cDoc := SE1->E1_NUM
					cSer := SE1->E1_PREFIXO
					cSe2 := ""
					cFor := SE1->E1_CLIENTE
					cLoj := SE1->E1_LOJA
					cEmi := dtos(SE1->E1_EMISSAO)
					cSe3 := SE1->E1_PREFIXO
					cTpD := "00"
					cTp  := "V"
					cNODIA	:= SE1->E1_NODIA
					nMonOri	:= SE1->E1_MOEDA

			  	Case cCTL_ALIAS == "SE2"
					cDoc := SE2->E2_NUM
					cSer := SE2->E2_PREFIXO
					cSe2 := ""
					cFor := SE2->E2_FORNECE
					cLoj := SE2->E2_LOJA
					cEmi := dtos(SE2->E2_EMISSAO)
					cSe3 := SE2->E2_PREFIXO
					cTpD := "00"
					cTp  := "C"
					cNODIA	:= SE2->E2_NODIA
					nMonOri	:= SE2->E2_MOEDA

			EndCase

		EndIf

		If !lExiste
			If cCTL_ALIAS $ "SF2|SF1|SD1|SD2" .And. cCTL_KEY != ""
				If cCTL_ALIAS $ "SF2|SF1"
					cAlTab	 := SubStr(cCTL_ALIAS,2)
					cCpos := "%"+cAlTab+"_DOC NFISCAL,"+cAlTab+"_SERIE SERIE,"+cAlTab+IIf(cAlTab=="F1","_FORNECE","_CLIENTE")+" CLIEFOR,"
					cCpos += cAlTab+"_TPDOC TPDOC,"+cAlTab+"_LOJA LOJA,"+cAlTab+"_SERIE2 SERIE2,"+cAlTab+"_EMISSAO EMISSAO,"+cAlTab+"_ESPECIE ESPECIE,"+cAlTab+"_MOEDA MOEDA"+"%"
					cTab  := "%" + RetSqlName(IIf(cAlTab=="F1","SF1,","SF2")) + " SF%"
					cCond := "%" + cCTL_KEY + "='"+ AllTrim(cCTK_KEY) + "' "
					cCond := cCond + IIf(FunName() == "CTBR118","AND D_E_L_E_T_ <> ''", "AND D_E_L_E_T_ = ''") + "%"
					lControl := .T.

				ElseIf FunName() == "CTBR118"
					cAlTab	 := SubStr(cCTL_ALIAS,2)
					aCposKey := StrTokArr(cCTL_KEY,"+")
					aCpos	 := {cAlTab+"_FILIAL",cAlTab+"_DOC",cAlTab+"_SERIE",cAlTab+IIf(cAlTab=="D1","_FORNECE","_CLIENTE"),cAlTab+"_LOJA",cAlTab+"_EMISSAO"}
					cKey	 := ""
					cDatos	 := ""
					cTxt	 := cCTK_KEY
					cAlTab	 := IIf(cAlTab=="D1","F1","F2")
					For nX := 1 to Len(aCposKey)
						If aScan(aCpos,aCposKey[nX]) > 0
							cKey += cAlTab + Substr(aCposKey[nX],3) + "+"
							cCampo := SubStr(cTxt,1,TamSX3(aCposKey[nX])[1])
							If "'" $ cCampo	// Tratamiento a número de documento de entrada con apóstrofes
								cCampo := Strtran(cCampo, "'", "''")
							EndIf
							cDatos += cCampo
						EndIf
						cTxt := SubStr(cTxt,TamSX3(aCposKey[nX])[1] + 1)
					Next nX
					cCpos := "%"+cAlTab+"_DOC NFISCAL,"+cAlTab+"_SERIE SERIE,"+cAlTab+IIf(cAlTab=="F1","_FORNECE","_CLIENTE")+" CLIEFOR,"
					cCpos += cAlTab+"_TPDOC TPDOC,"+cAlTab+"_LOJA LOJA,"+cAlTab+"_SERIE2 SERIE2,"+cAlTab+"_EMISSAO EMISSAO,"+cAlTab+"_ESPECIE ESPECIE,"+cAlTab+"_MOEDA MOEDA"+"%"
					cTab  := "%" + RetSqlName(IIf(cAlTab=="F1","SF1,","SF2")) + " SF%"
					cCond := "%" + SubStr(cKey,1,Len(cKey)-1) + " = '" + cDatos + "' AND D_E_L_E_T_ <>''%"
					lControl := .T.

				EndIf

				If lControl
					BeginSql Alias cAliasS3
						SELECT
							%Exp:cCpos%
						FROM
							%Exp:cTab%
						WHERE
							%Exp:cCond%
					EndSql

					dbSelectArea(cAliasS3)

					If (cAliasS3)->(!Eof())
			  			cDoc := (cAliasS3)->NFISCAL
				   		cSer := (cAliasS3)->SERIE
				   		cFor := (cAliasS3)->CLIEFOR
						cLoj := (cAliasS3)->LOJA
						cSe2 := (cAliasS3)->SERIE2
					    cEmi := (cAliasS3)->EMISSAO
						cSe3 := (cAliasS3)->SERIE
						cTpD := (cAliasS3)->TPDOC
						nMonOri := (cAliasS3)->MOEDA

						If AllTrim((cAliasS3)->ESPECIE)=="NCC" .OR. (AllTrim((cAliasS3)->ESPECIE)!="NCP" .And. cCTL_ALIAS $ "SF2|SD2")
							cTp := "V"
						ElseIf AllTrim((cAliasS3)->ESPECIE)=="NCP"  .or. (AllTrim((cAliasS3)->ESPECIE)!="NCC" .And. cCTL_ALIAS $ "SF1|SD1")
							cTp := "C"
						Endif

					Else
						lBorrado := .T.

					EndIf

					dbCloseArea()
				EndIf
			EndIf
		EndIf

	ElseIf FunName() == "CTBR118" .And. cCTL_ALIAS$"SF1|SF2|SD1|SD2" .And. !Empty(cCT2_NODIA)
		cAlTab := IIf(cCTL_ALIAS$"SD1|SF1","F1","F2")
		cCpos := "%"+cAlTab+"_DOC NFISCAL,"+cAlTab+"_SERIE SERIE,"+cAlTab+IIf(cAlTab=="F1","_FORNECE","_CLIENTE")+" CLIEFOR,"
		cCpos += cAlTab+"_TPDOC TPDOC,"+cAlTab+"_LOJA LOJA,"+cAlTab+"_SERIE2 SERIE2,"+cAlTab+"_EMISSAO EMISSAO,"+cAlTab+"_ESPECIE ESPECIE,"+cAlTab+"_MOEDA MOEDA"+"%"
		cTab  := "%" + RetSqlName(IIf(cAlTab=="F1","SF1,","SF2")) + " SF%"
		cCond := "%" + cAlTab + "_NODIA = '" + cCT2_NODIA + "' AND D_E_L_E_T_ <>''%"

		BeginSql Alias cAliasS3
			SELECT
				%Exp:cCpos%
			FROM
				%Exp:cTab%
			WHERE
				%Exp:cCond%
		EndSql

		dbSelectArea(cAliasS3)

		If (cAliasS3)->(!Eof())
  			cDoc := (cAliasS3)->NFISCAL
	   		cSer := (cAliasS3)->SERIE
	   		cFor := (cAliasS3)->CLIEFOR
			cLoj := (cAliasS3)->LOJA
			cSe2 := (cAliasS3)->SERIE2
		    cEmi := (cAliasS3)->EMISSAO
			cSe3 := (cAliasS3)->SERIE
			cTpD := (cAliasS3)->TPDOC
			nMonOri := (cAliasS3)->MOEDA

			If AllTrim((cAliasS3)->ESPECIE) == "NCC" .OR. (AllTrim((cAliasS3)->ESPECIE)!="NCP" .And. cCTL_ALIAS $ "SF2|SD2")
				cTp := "V"
			ElseIf AllTrim((cAliasS3)->ESPECIE) == "NCP"  .or. (AllTrim((cAliasS3)->ESPECIE)!="NCC" .And. cCTL_ALIAS $ "SF1|SD1")
				cTp := "C"
			Endif

		Else
			lBorrado := .T.

		EndIf

		dbCloseArea()
	Endif
EndIf

If FUNNAME() == "CTBR118"
 	Aadd( aRet, { cTpD,cSer,cSe2,cDoc,cFor,cTp,cEmi,cSe3,cLoj,lBorrado,nMonOri} )
Else
 	Aadd( aRet, { cTpD,cSer,cSe2,cDoc,cFor,cTp,cEmi,cSe3,cLoj,nMonOri} )
EndIf

//Sin uso cSe3, cTp

restArea(vArea)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PERXFIS   ºAutor  ³Microsiga           ºFecha ³  12/16/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PuxaSer2Peru( _cSerOri )

	Local __lTem := .f.
	Local __cSerieNf := _cSerOri
	local _vArea := getArea()

	SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
	If SFP->( dbSeek( xFilial("SFP")+cFilAnt+_cSerOri+"1" ) )
		If !Empty(SFP->FP_SERIE2)
			__cSerieNf := Alltrim(SFP->FP_SERIE2)
		else
			__cSerieNf := Alltrim(SFP->FP_YSERIE)
		EndIf
		__lTem := .t.
	EndIf

	If !__lTem
		If SFP->( dbSeek( xFilial("SFP")+cFilAnt+_cSerOri+"2" ) )
			If !Empty(SFP->FP_SERIE2)
				__cSerieNf := Alltrim(SFP->FP_SERIE2)
			else
				__cSerieNf := Alltrim(SFP->FP_YSERIE)
			EndIf
			__lTem := .t.
		EndIf
	EndIf

	If !__lTem
		If SFP->( dbSeek( xFilial("SFP")+cFilAnt+_cSerOri+"3" ) )
			If !Empty(SFP->FP_SERIE2)
				__cSerieNf := Alltrim(SFP->FP_SERIE2)
			else
				__cSerieNf := Alltrim(SFP->FP_YSERIE)
			EndIf
			__lTem := .t.
		EndIf
	EndIf

	If !__lTem
		If SFP->( dbSeek( xFilial("SFP")+cFilAnt+_cSerOri+"6" ) )
			If !Empty(SFP->FP_SERIE2)
				__cSerieNf := Alltrim(SFP->FP_SERIE2)
			else
				__cSerieNf := Alltrim(SFP->FP_YSERIE)
			EndIf
			__lTem := .t.
		EndIf
	EndIf

	If Len(__cSerieNf)<=3
		__cSerieNf := Replicate("0",4-Len(_cSerOri))+_cSerOri
	EndIf

	restArea(_vArea)

Return( __cSerieNf )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SelLocal ³ Autor ³ MicroSiga			    ³ Data ³03.10.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona armazens										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR263                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Funciones utilizadas por los fuentes MATR263 Y MATR264*/
Function M264LocFil(cLocal1,cFilsel,cProd)  // Seleciona Armazem.

Local aAreaSb2  := GetArea()
Local cAliasTSB2 := ""

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+

aLocalFiR:={}

cSql003:=""
cSql003+= " SELECT DISTINCT B2_LOCAL LOCAL1  "
cSql003+= " FROM "+ RetSqlName("SB2") + " SB2"
cSql003+= " WHERE SB2.B2_FILIAL = '" + cFilsel +"'"
cSql003+= " AND SB2.D_E_L_E_T_ = ' ' "
IF FUNNAME() == "MATR263"
	cSql003+= " AND SB2.B2_LOCAL IN "+cLocal1+"  "
ELSE
	cSql003+= " AND SB2.B2_LOCAL = '"+cLocal1+"'  "
ENDIF
cSql003+= " AND SB2.B2_COD='"+cProd+"'"

cSql003+= " UNION "
cSql003+= " SELECT DISTINCT B9_LOCAL LOCAL1  "
cSql003+= " FROM "+ RetSqlName("SB9") + " SB9"
cSql003+= " WHERE SB9.B9_FILIAL = '" + cFilsel + "'"
cSql003+= " AND SB9.D_E_L_E_T_ = ' ' "

IF FUNNAME() == "MATR263"
	cSql003+= " AND SB9.B9_LOCAL IN "+cLocal1+"  "
ELSE //MATR264
	cSql003+= " AND SB9.B9_LOCAL = '"+cLocal1+"'  "
ENDIF
cSql003+= " AND SB9.B9_COD='"+cProd+"'"
cAliasTSB2 := GetNextAlias()

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql003 ), cAliasTSB2,.T.,.T.)
(cAliasTSB2)->(dBGotop())
WHILE ! EOF()
	aAdd(aLocalFiR, { .T., (cAliasTSB2)->LOCAL1," Almacen"+(cAliasTSB2)->LOCAL1}) // 'ARMAZEM '
	DBSKIP()
ENDDO

IF Select( cAliasTSB2 ) > 0
	dbSelectArea( cAliasTSB2 )
	dbCloseArea()
EndIf

RestArea( aAreaSb2 )

Return(aLocalFiR)

 Function M264fCalcEst(cCod,cLocal,dData,cFilAux,lConsTesTerc,lCusRep)

	#define F_SB9  1
	#define F_SD1  2
	#define F_SD2  3
	#define F_SD3  4
	#define F_SF4  5
	#define F_SF5  6

	Local dDtVai:=ctod("  /  /  ")
	Local lHasRec := .F.
	Local aSaldo     := { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }

	DEFAULT lConsTesTerc := .F.
	DEFAULT lCusRep      := .F.
	DEFAULT dData        := dDataBase
	SF5->(DBClearFilter())

	dData	 := If(Empty(dData),Ctod( "01/01/80","ddmmyy" ),dData)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de partida para compor o saldo inicial.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SB9" )

	MsSeek(cFilAux+cCod+cLocal)

	lHasRec := .f.
	While !Eof() .and. (cFilAux+cCod+cLocal == B9_FILIAL+B9_COD+B9_Local)
		If B9_DATA >= dData .and. lHasRec
			Exit
		Else
			lHasRec := .t.
		EndIf

		DbSkip()
	End
	If lHasRec
		DbSkip(-1)
	EndIf

	If ((cFilAux+cCod+cLocal == SB9->B9_FILIAL+SB9->B9_COD+SB9->B9_Local) .And. ;
		(SB9->B9_DATA < dData))

		aSaldo[01] := SB9->B9_QINI
		aSaldo[02] := SB9->B9_VINI1
		aSaldo[03] := SB9->B9_VINI2
		aSaldo[04] := SB9->B9_VINI3
		aSaldo[05] := SB9->B9_VINI4
		aSaldo[06] := SB9->B9_VINI5
		aSaldo[07] := SB9->B9_QISEGUM
		aSaldo[08] := SB9->B9_CM1
		aSaldo[09] := SB9->B9_CM2
		aSaldo[10] := SB9->B9_CM3
		aSaldo[11] := SB9->B9_CM4
		aSaldo[12] := SB9->B9_CM5

		If lCusRep
			aSaldo[13] := SB9->B9_CMRP1
			aSaldo[14] := SB9->B9_CMRP2
			aSaldo[15] := SB9->B9_CMRP3
			aSaldo[16] := SB9->B9_CMRP4
			aSaldo[17] := SB9->B9_CMRP5
			aSaldo[18] := SB9->B9_VINIRP1
			aSaldo[19] := SB9->B9_VINIRP2
			aSaldo[20] := SB9->B9_VINIRP3
			aSaldo[21] := SB9->B9_VINIRP4
			aSaldo[22] := SB9->B9_VINIRP5
		EndIf
		dDtVai    := SB9->B9_DATA+1
	Else
		dDtVai    := Ctod( "01/01/80","ddmmyy" )
	EndIf

Return(aSaldo)

Function M264getSerie2(cDocEsp)

local cRetSerie := CriaVar("FP_YSERIE")
local aEspecies	:= {}
local nX:=0
Local cFilSFP:= xFilial("SFP")

if len(cDocEsp)==1
	Aadd( aEspecies, cDocEsp )
else
	aEspecies := StrTokArr2( cDocEsp, "/" )
endif

SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE

for nX := 1 to len(aEspecies)

		If SFP->( MsSeek(cFilSFP+TRB->FILIAL+TRB->SERIE+aEspecies[nX] ) )

			If !Empty(SFP->FP_YSERIE)
				cRetSerie := Alltrim(SFP->FP_YSERIE)
			else
				cRetSerie := Alltrim(SFP->FP_SERIE2)
			EndIf

			exit

		Endif

next nX

Return(alltrim(cRetSerie))

 Function M264NodiaOrig(xSerie,xNumDoc,xTpDoc,xClifor,xLoja,xDoc,xFil)

	local _aArea	:= getArea()
	local cQuery	:= ""
	local cAlias	:= getNextAlias()

	local cQuery2	:= ""
	local cAlias2	:= getNextAlias()

	local cQuery3	:= ""
	local cAlias3	:= getNextAlias()

	local cQuery4	:= ""
	local cAlias4	:= getNextAlias()
	local _cCliente := ""
	local _cLoja	:= ""
	local _cDoc		:= ""
	local _cSerie	:= ""
	local xNodia	:= ""
	local lOk		:= .f.

	 xNumDoc	:= Padr(alltrim(xNumDoc),TamSx3("F1_DOC")[1])
	 xClifor	:= Padr(alltrim(xClifor),TamSx3("F1_FORNECE")[1])

If alltrim(xTpDoc)<>"NCC"  //

		cQuery := "SELECT D2_CLIENTE,D2_LOJA,D2_DOC,D2_SERIE"
		cQuery += "  FROM "+RetSqlName("SD2")

		cQuery += " WHERE D2_FILIAL='"+ xFil +"'"
		cQuery += "   AND D2_SERIREM='"+xSerie+"'"
		cQuery += "   AND D2_REMITO='"+xNumDoc+"'"
		cQuery += "   AND D_E_L_E_T_=''"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		if (cAlias)->(!Eof())
			_cCliente	:= (cAlias)->D2_CLIENTE
			_cLoja		:= (cAlias)->D2_LOJA
			_cDoc		:= (cAlias)->D2_DOC
			_cSerie		:= (cAlias)->D2_SERIE
			lOk			:= .t.

		else
			// -----------------------------------------------------------------------------------------------------
			// Codigo Anexado Por: Walmar de Freitas G. - Fecha: 03092019
			// Motivo: Anexado para recuperar el NODIA de las facturas que no tienen Remito - Cargadas Directamente
			// -----------------------------------------------------------------------------------------------------
				cQuery2 := "SELECT TOP 1 D2_CLIENTE,D2_LOJA,D2_DOC,D2_SERIE"
				cQuery2 += "  FROM "+RetSqlName("SD2")

				cQuery2 += " WHERE D2_FILIAL='"+ xFil +"'"
				cQuery2 += "   AND D2_SERIE='"+xSerie+"'"
				cQuery2 += "   AND D2_DOC='"+xDoc+"'"
				cQuery2 += "   AND D_E_L_E_T_=''"

				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAlias2,.T.,.T.)

				If (cAlias2)->(!Eof())
					_cCliente	:= (cAlias2)->D2_CLIENTE
					_cLoja		:= (cAlias2)->D2_LOJA
					_cDoc		:= (cAlias2)->D2_DOC
					_cSerie		:= (cAlias2)->D2_SERIE
					lOk			:= .t.
				EndIf
				(cAlias2)->( dbCloseArea() )
			//---------------------------------------------------------------------------------------------------------
		endif
		(cAlias)->( dbCloseArea() )

else

		SF1->( dbSetOrder(1) )	// xSerie,xNumDoc,xTpDoc,xClifor,xLoja)

		if SF1->( MsSeek( xFil + xNumDoc + xSerie + xClifor + xLoja ) )
			xNodia := alltrim(SF1->F1_NODIA)
		endif
		lOk := .f.
endif


	if lOk
		SF2->( dbSetOrder(2) )

		if SF2->( MsSeek( xFil +_cCliente + _cLoja + _cDoc + _cSerie ) )
			xNodia := alltrim(SF2->F2_NODIA)
		endif
	endif


	// -----------------------------------------------------------------------------------------------------
	// Codigo Anexado Por: Walmar de Freitas G. - Fecha: 03092019
	// Motivo: Anexado para recuperar el NODIA de los movmimientos de Inventario
	// Sin crear MV_SERKINV y MV_SERKTM - Deben ser creados para que se regularice . Solo Aplica a Bakels
	// -----------------------------------------------------------------------------------------------------
			If alltrim(xTpDoc) $ "DE0|DE1|DE4|DE6|ER0|PR0|RE0|RE1|RE4|RE6"

						cQuery3 := "SELECT TOP 1 D3_NODIA"
						cQuery3 += "  FROM "+RetSqlName("SD3")
						cQuery3 += " WHERE D3_FILIAL='" + xFil +"'"
						cQuery3 += "   AND D3_DOC='"    + xDoc +"'"
						cQuery3 += "   AND D_E_L_E_T_=''"
						cQuery3 += "   AND D3_ESTORNO <> 'S' "
						cQuery3 := ChangeQuery(cQuery3)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery3),cAlias3,.T.,.T.)

						If (cAlias3)->(!Eof())
							xNodia	:= (cAlias3)->D3_NODIA
						EndIf
						(cAlias3)->( dbCloseArea() )
		   EndIf
	// -----------------------------------------------------------------------------------------------------


	// -----------------------------------------------------------------------------------------------------
	// Codigo Anexado Por: Walmar de Freitas G. - Fecha: 04092019
	// Motivo: Anexado para recuperar el NODIA de las series 001 y especie RCN que no aparecen.
	// -----------------------------------------------------------------------------------------------------
			If alltrim(xTpDoc) $ "RCN|RDF|RTE|RFD".AND.xNodia ==''
						cQuery4 := "SELECT F1_NODIA "
						cQuery4 += "  FROM "+RetSqlName("SF1")
						cQuery4 += " WHERE F1_FILIAL='" + xFil +"'"
						cQuery4 += "   AND F1_DOC='"    + xDoc +"'"
						cQuery4 += "   AND D_E_L_E_T_=''"

						cQuery4 := ChangeQuery(cQuery4)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery4),cAlias4,.T.,.T.)

						If (cAlias4)->(!Eof())
							xNodia	:= (cAlias4)->F1_NODIA
						EndIf
						(cAlias4)->( dbCloseArea() )
		   Else
					if !lOk
							SF1->( dbSetOrder(1) )	// xSerie,xNumDoc,xTpDoc,xClifor,xLoja)

							if SF1->( MsSeek( xFil + xNumDoc + xSerie + xClifor + xLoja ) )
								xNodia := alltrim(SF1->F1_NODIA)
							endif
							lOk := .f.
					endif
		   EndIf
	// -----------------------------------------------------------------------------------------------------

	RestArea(_aArea)
Return(xNodia)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SelLocal ³ Autor ³ MicroSiga			    ³ Data ³03.10.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona armazens										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR263                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT263SelLocal(cLocal1)  // Seleciona Armazem.

Local cTitulo	:= "Selección de almacenes"
Local aArea		:= GetArea()
Local cAliasqry	:= GetNextAlias()
Local cTmpSB2Fil:= ""
Local cWhereSB2 := "%B2_FILIAL " + GetRngFil( aSelFil, "SB2", .T., @cTmpSB2Fil ) + "%"
Local cWhereSB9 := "%B9_FILIAL " + GetRngFil( aSelFil, "SB9", .T., @cTmpSB2Fil ) + "%"
Local nTamLocal	:= Len(SB2->B2_LOCAL)
Local cLocVacio	:= Space(nTamLocal)
Local cDummy	:= Replicate("*",nTamLocal)
Local aAlmacen	:= {}
Local cAlmacen	:= ""
Local cRet		:= ""
Local nCount	:= 0

aLocal	:= {}	// array definido en la rutina ejecutora

If Alltrim(cLocal1) == '**'

	// Query para extraer lista de almacenes con movimiento
	BeginSql Alias cAliasqry
		SELECT DISTINCT
	        SB2.B2_LOCAL LOCAL1
		FROM
	        %table:SB2% SB2
		WHERE
	        SB2.%exp:cWhereSB2% AND
	        SB2.B2_LOCAL <> %exp:cLocVacio% AND
	        SB2.%notDel%
	    UNION
		SELECT DISTINCT
	        SB9.B9_LOCAL LOCAL1
		FROM
	        %table:SB9% SB9
		WHERE
	        SB9.%exp:cWhereSB9% AND
	        SB9.B9_LOCAL <> %exp:cLocVacio% AND
	        SB9.%notDel%
	EndSql

	dbSelectArea(cAliasqry)
	(cAliasqry)->(dbGotop())

	Do While (cAliasqry)->(!Eof())
		aAdd(aLocal, { .F., (cAliasqry)->LOCAL1,""})
		aAdd(aAlmacen, "Almacén "+(cAliasqry)->LOCAL1)
		cAlmacen += (cAliasqry)->LOCAL1
		(cAliasqry)->(dbSkip())
	Enddo

	(cAliasqry)->(dbCloseArea())
	RestArea(aArea)

	cLocal1 := ""

	If Len(aAlmacen) > 0
		// Abre ventana de selección
		If AdmOpcoes(@cRet,OemToAnsi(cTitulo),aAlmacen,cAlmacen,,,.F.,nTamLocal,Len(aAlmacen),.T.,,,.T.,.T.)
			For nCount := 1 To len(cRet) Step nTamLocal
				cAlmacen := SubStr(cRet, nCount, nTamLocal)
				If cAlmacen <> cDummy
					cLocal1 += "'" + cAlmacen + "',"
					aLocal[aScan(aLocal,{|x|x[2]==cAlmacen})][1] := .T.
				EndIf
			Next nCount
		EndIf
	EndIf

	If !Empty(cLocal1)
		// String con los almacenes seleccionados para Query
		cLocal1 := "(" + SubStr(cLocal1, 1, Len(cLocal1) - 1) + ')'
	EndIf

ElseIf !Empty(cLocal1)

	// Código de almacén definido en el parámetro
	cLocal1 := "('" + PadR(cLocal1, nTamLocal) + "')"
	aAdd(aLocal, { .T., cLocal1,""})

EndIf

If Empty(cLocal1)
	// Parámetro en blanco, no se encontraron almacenes o no se seleccionó ninguno, regresar "01" como default
	cLocal1 := "('" + StrZero(1, nTamLocal) + "')"
	aAdd(aLocal, { .T., cLocal1,""})
EndIf

Return (cLocal1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M263LocFil³ Autor ³ MicroSiga			    ³ Data ³25.06.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecciona almacenes	con Id SUNAT						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR263                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M263LocFil(cLocal1, cFilSel, cProd, cEstab)
	Local aArea		:= GetArea()
	Local cAliasqry	:= GetNextAlias()
	Local cLocSB2	:= "% B2_LOCAL IN " + cLocal1 + " %"
	Local cLocSB9	:= "% B9_LOCAL IN " + cLocal1 + " %"
	Local aLocalFiR	:= {}

	// Query para extraer lista de almacenes con movimiento
	BeginSql Alias cAliasqry
		SELECT DISTINCT
	        SB2.B2_LOCAL LOCAL1, NNR_IDSUNA IDSUNAT
		FROM
	        %table:SB2% SB2
	    INNER JOIN %table:NNR% NNR
	    ON B2_LOCAL = NNR_CODIGO
		WHERE
	        SB2.B2_FILIAL = %exp:cFilSel% AND
	        SB2.%exp:cLocSB2% AND
	        SB2.B2_COD = %exp:cProd% AND
	        SB2.%notDel% AND
	        NNR.NNR_IDSUNA = %exp:cEstab% AND
	        NNR.%notDel%
	    UNION
		SELECT DISTINCT
	        SB9.B9_LOCAL LOCAL1, NNR_IDSUNA IDSUNAT
		FROM
	        %table:SB9% SB9
	    INNER JOIN %table:NNR% NNR
	    ON B9_LOCAL = NNR_CODIGO
		WHERE
	        SB9.B9_FILIAL = %exp:cFilSel% AND
	        SB9.%exp:cLocSB9% AND
	        SB9.B9_COD = %exp:cProd% AND
	        SB9.%notDel% AND
	        NNR.NNR_IDSUNA = %exp:cEstab% AND
	        NNR.%notDel%
	EndSql

	dbSelectArea(cAliasqry)
	(cAliasqry)->(dbGotop())

	Do While (cAliasqry)->(!Eof())
		aAdd(aLocalFiR, { .T., (cAliasqry)->LOCAL1," Almacen"+(cAliasqry)->LOCAL1})
		(cAliasqry)->(dbSkip())
	Enddo

	(cAliasqry)->(dbCloseArea())
	RestArea(aArea)

Return(aLocalFiR)

/*/{Protheus.doc} PrefijoCorr
	Obtiene prefijo de correlativo de asiento contable para libros electrónicos
	@type  Function
	@author ARodriguez
	@since 24/11/2020
	@version 1.0
	@param cSubLote, c, Sublote (CT2_SBLOTE)
	@param cRotina, c, Rutina origen (CT2_ROTINA)
	@return cPrefijo, C, Prefijo de correlativo (A-Apertura, C-Cierre, M-Movimiento)
	@example
	Se deben crear los parámetros que identificación los Sublotes de asientos de apertura y de cierre de ejercicio
	@see MV_SLAPERT, MV_SLCIERR
	/*/
Function PrefijoCorr( cSubLote, cRotina )
Local cPrefijo		:= ""

Static cMVSLAPERT	:= SuperGetMV("MV_SLAPERT", .T., "INI")
Static cMVSLCIERR	:= SuperGetMV("MV_SLCIERR", .T., "")

If Trim(cSubLote) $ cMVSLAPERT
	cPrefijo := "A"
ElseIf Trim(cSubLote) $ cMVSLCIERR .Or. "CTBA211" $ cRotina
	cPrefijo := "C"
Else
	cPrefijo := "M"
EndIf

Return cPrefijo
