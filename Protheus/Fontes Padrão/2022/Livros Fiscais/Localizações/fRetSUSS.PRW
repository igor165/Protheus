#Include "Protheus.ch"
#Include "fRetSUSS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFGERTXTRetบAutor  ณRenato Nagib        บ Data ณ  26/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo temporario com registros tipo SUSS da tabela   บฑฑ
ฑฑบ          ณSFE para exportacao em txt dentro do periodo informado.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR ณ DATA   ณ BOPS    ณ          MOTIVO DA ALTERACAO         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glezณ03/01/17ณSERINN001ณSe modifica la funcion FDelSUSS, para ณฑฑ
ฑฑณ             ณ        ณ     -548ณhacer el correcto borrado y cierre de ณฑฑ
ฑฑณ             ณ        ณ         ณlas tablas temp. por limpieza de CTREEณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static cProv     := ""
Static cOrdP     := ""
Static cImp		 := ""
Static cClie     := ""
Static cNumDoc   := ""
Static cEspe     := ""
Static alArq     := {}
Static cTmpPer := GetNextAlias()
Function SUSS(dDataIni,dDataFin, aProv)

	Local lCCP      := .T.
	Local nCpo
	Local aconcept  := {}
	Local cDtIni	:=""
	Local cDtFim	:=""
	Local nAux		:= 1
	Local cTabEqui	:= ""

	Private	oTmpTable
	Private lAutomato := isblind()
	Default dDataIni := ""
	Default dDataFin := ""
	Default aProv := {}

	CreaTemp()
	If Len(aProv) <> 0
		cProv := ObtProv(aProv[1][1])
		cOrdP := ObtProv(aProv[1][2])
		cClie := ObtProv(aProv[1][3])
		cNumDoc:= ObtProv(aProv[1][4])
		cImp  := aProv[1][6]
		cEspe := aProv[1][5]
		cTabEqui := Iif(Len(aProv[1]) >= 7, aProv[1][7], "")
	EndIf
	cDtIni	:= DTOS(dDataIni)
	cDtFim	:= DTOS(dDataFin)
	//Verifica se existe a tabela CCP(equivalenvias) caso exista insere valores defaut.
	dbSelectArea("SX3")
	dbSetorder(1)
	If !AliasIndic('CCP')
		lCCP:=.F.
	Else
		dbSelectArea('CCP')
		dbSetorder(1)
		If !dbSeek(xFilial('CCP')+'SUSS')
			aAdd(aconcept,{'1', STR0001 ,'754'}) //"Servicios de Seguridad"
			aAdd(aconcept,{'2', STR0002 ,'755'}) //" R้gimen General "
			aAdd(aconcept,{'3', STR0003 ,'740'}) //"Servicios de Construcciones"
			For nCpo:=1 To 3
				RecLock('CCP',.T.)
				CCP_FILIAL:=xFilial('CCP')
				CCP_COD   :='SUSS'
				CCP_VORIGE:=aConcept[nCpo,1]
				CCP_DESCR :=aConcept[nCpo,2]
				CCP_VDESTI:=aConcept[nCpo,3]
				CCP_ARQUIV:=''
				CCP_CAMPO :=''
				MsUnlock()
			Next
		EndIf
	EndIf

	If cImp  == "SUSS"
		If !lAglFil // Agrupa sucursales?
			fRetSUSS(dDataIni,dDataFin,lCCP,cFilAnt)
		Else
			For nAux:=1 to Len(aFilsCalc)
				If aFilsCalc[nAux][1]
					fRetSUSS(dDataIni,dDataFin,lCCP,aFilsCalc[nAux][2])
				EndIf
				aFilsCalc[nAux][1] := .F.
			Next nAux
			If MsgYesNo(STR0004) // "ฟVerificar los para la exportaci๓n?"
				TRelSFE("TRB")
			EndIf
		EndIf
	ElseIf cImp == "IVA"
		IVARET(cDtIni,cDtFim,cTabEqui)
		IVAPER(cDtIni,cDtFim,cEspe, cTabEqui)
	ElseIf UPPER(cImp) = "GANANCIAS BENEFICIARIOS DEL EXTERIOR"
		If !lAglFil // Agrupa sucursales?
			fRetGAN(dDataIni,dDataFin,cFilAnt)
		Else
			For nAux:=1 to Len(aFilsCalc)
				If aFilsCalc[nAux][1]
					fRetGAN(dDataIni,dDataFin,aFilsCalc[nAux][2])
				EndIf
				aFilsCalc[nAux][1] := .F.
			Next nAux
			If !lAutomato
				If MsgYesNo(STR0004) // "ฟVerificar los para la exportaci๓n?"
					TRelSFE("TRB3")
				EndIf
			EndIf
		EndIF
	Else
		fRetSUSS(dDataIni,dDataFin,lCCP,cFilAnt)
		IVARET(cDtIni,cDtFim, cTabEqui)
		IVAPER(cDtIni,cDtFim,cEspe, cTabEqui)
		fRetGAN(dDataIni,dDataFin,cFilAnt)
	EndIf



Return (alArq)

Static Function CreaTemp()

	Local alStruct:={}
	Local aOrder :={}

	Aadd(alStruct,{"FORMULARIO" ,"C",04,0})
	Aadd(alStruct,{"VERSION"    ,"C",04,0})
	Aadd(alStruct,{"CODTRAZA"   ,"C",10,0})
	Aadd(alStruct,{"CUIT"       ,"C",11,0})
	Aadd(alStruct,{"IMPUESTO"   ,"C",03,0})
	Aadd(alStruct,{"REGIMEN"    ,"C",03,0})
	Aadd(alStruct,{"CUITRET"    ,"C",11,0})
	Aadd(alStruct,{"FCHRET"     ,"C",10,0})
	Aadd(alStruct,{"TIPCOMP"    ,"C",02,0})
	Aadd(alStruct,{"FCHCOMP"    ,"C",10,0})
	Aadd(alStruct,{"NROCOMPRO"  ,"C",16,0})
	Aadd(alStruct,{"IMPCOMP"    ,"C",14,0})
	Aadd(alStruct,{"IMPRETE"    ,"C",14,0})
	Aadd(alStruct,{"NROCERTORI" ,"C",25,0})
	Aadd(alStruct,{"FCHCERTORI" ,"C",10,0})
	Aadd(alStruct,{"IMPCERTORI" ,"C",14,0})
	Aadd(alStruct,{"OTROS"      ,"C",30,0})

	aOrder	:=	{"REGIMEN","CUIT","NROCOMPRO","TIPCOMP"} //JGR
	oTmpTable := FWTemporaryTable():New('TRB')
	oTmpTable:SetFields( alStruct )
	oTmpTable:AddIndex("I01", aOrder)
	oTmpTable:Create()

	alStruct:={}
	aOrder :={}

	Aadd(alStruct,{"VERSION"    ,"C",04,0})
	Aadd(alStruct,{"CODTRAZA"   ,"C",36,0})
	Aadd(alStruct,{"IMPUESTO"   ,"C",03,0})
	Aadd(alStruct,{"REGIMEN"    ,"C",03,0})
	Aadd(alStruct,{"FCHRETPER"  ,"C",10,0})
	Aadd(alStruct,{"CONDICION"  ,"C",02,0})
	Aadd(alStruct,{"IMPOSIBIL"  ,"C",01,0})
	Aadd(alStruct,{"NRORETMOT"  ,"C",30,0})
	Aadd(alStruct,{"IMPRETPER"  ,"C",14,0})
	Aadd(alStruct,{"IMPCAL"     ,"C",14,0})
	Aadd(alStruct,{"REGEXCL"    ,"C",01,0})
	Aadd(alStruct,{"POREXCL"    ,"C",06,0})
	Aadd(alStruct,{"FECHPUB"    ,"C",10,0})
	Aadd(alStruct,{"TIPOCOMP"   ,"C",02,0})
	Aadd(alStruct,{"FCHCOMP"    ,"C",10,0})
	Aadd(alStruct,{"NROCOMP"    ,"C",16,0})
	Aadd(alStruct,{"COE"        ,"C",12,0})
	Aadd(alStruct,{"COEORI"     ,"C",12,0})
	Aadd(alStruct,{"CAE"        ,"C",14,0})
	Aadd(alStruct,{"IMPCMP"     ,"C",14,0})
	Aadd(alStruct,{"MOTEMI"     ,"C",30,0})
	Aadd(alStruct,{"RETPERCL"   ,"C",11,0})
	Aadd(alStruct,{"CERORG"     ,"C",25,0})
	Aadd(alStruct,{"CERORGFCH"  ,"C",10,0})
	Aadd(alStruct,{"CERORGIMP"  ,"C",14,0})
	Aadd(alStruct,{"MOTANU"		,"C",01,0})

	aOrder	:=	{"REGIMEN","RETPERCL"} //JGR

	oTmpTable := FWTemporaryTable():New('TRB1')
	oTmpTable:SetFields( alStruct )
	oTmpTable:AddIndex("I01", aOrder)
	oTmpTable:Create()

	oTmpTable := FWTemporaryTable():New("TRB2")
	oTmpTable:SetFields( alStruct )
	oTmpTable:AddIndex("I01", aOrder)
	oTmpTable:Create()

	alStruct:={}
	aOrder :={}

	Aadd(alStruct,{"FORMULARIO" ,"C",04,0}) //1
	Aadd(alStruct,{"VERSION"    ,"C",04,0}) //2
	Aadd(alStruct,{"CODTRAZA"   ,"C",10,0}) //3
	Aadd(alStruct,{"CUIT"       ,"C",11,0}) //4
	Aadd(alStruct,{"IMPUESTO"   ,"C",03,0}) //5
	Aadd(alStruct,{"REGIMEN"    ,"C",03,0}) //6
	Aadd(alStruct,{"CUITORD"    ,"C",11,0}) //7
	Aadd(alStruct,{"FCHRET"     ,"C",10,0}) //8
	Aadd(alStruct,{"TIPCOMP"    ,"C",02,0}) //9
	Aadd(alStruct,{"FCHCOMP"    ,"C",10,0}) //10
	Aadd(alStruct,{"NROCOMPRO"  ,"C",16,0}) //11
	Aadd(alStruct,{"IMPCOMP"    ,"C",14,0}) //12
	Aadd(alStruct,{"FILLER"     ,"C",14,0}) //13
	Aadd(alStruct,{"NROCERTORI" ,"C",25,0}) //14
	Aadd(alStruct,{"FCHCERTORI" ,"C",10,0}) //15
	Aadd(alStruct,{"IMPCERTORI" ,"C",14,0}) //16
	Aadd(alStruct,{"MOTEMINCC"  ,"C",30,0}) //17
	Aadd(alStruct,{"NRORET"     ,"C",01,0}) //18
	Aadd(alStruct,{"NORETMOT"   ,"C",30,0}) //19
	Aadd(alStruct,{"APLCDI"     ,"C",01,0}) //20
	Aadd(alStruct,{"CODLIAQ"    ,"C",04,0}) //21
	Aadd(alStruct,{"APACRE"     ,"C",01,0}) //22
	Aadd(alStruct,{"RETCVENIF"  ,"C",50,0}) //23
	Aadd(alStruct,{"RETNOMDE"   ,"C",60,0}) //24
	Aadd(alStruct,{"RETDOMEXT"  ,"C",60,0}) //25
	Aadd(alStruct,{"RETDOMEXTP" ,"C",03,0}) //26
	Aadd(alStruct,{"RETTIPPER"  ,"C",01,0}) //27
	Aadd(alStruct,{"RETNACCONP" ,"C",03,0}) //28
	Aadd(alStruct,{"RETNACCONF" ,"C",10,0}) //29

	aOrder	:=	{"TIPCOMP","CUIT","NROCOMPRO"}

	oTmpTable := FWTemporaryTable():New('TRB3')
	oTmpTable:SetFields( alStruct )
	oTmpTable:AddIndex("I01", aOrder)
	oTmpTable:Create()


Return
Static Function Tipo(cTipo,nPorIva,cEspecie)

	Local aAux :=""

	If 	 cTipo =="I"
		cTipo := "1"
	ElseIf cTipo =="N"
		cTipo := "2"
	ElseIf cTipo =="S"
		cTipo :=" 3"
	Else
		cTipo := "0"
	EndIf

	If nPorIva==0
		nPorIva:=1
	Else
		nPorIva:=0
	EndIf

	If cEspecie =="NF"
		cEspecie:="01"
	ElseIf cEspecie =="NCC"
		cEspecie:="03"
	Else
		cEspecie:="04"
	EndIf

	aAux := {cTipo,nPorIva,cEspecie}
Return aAux

Static Function sfhreg(cfecha,cCod,cLoja,cImpuesto,lTabla)

	Local cTabla :=""
	Local aDatos :={}
	Local cSFH	 :=GetNextAlias()

	Iif(lTabla,cTabla:="FH_CLIENTE",cTabla:="FH_FORNECE")
	cQuery	:= ""
	cQuery := "SELECT  FH_FIMVIGE ,FH_INIVIGE ,FH_ISENTO,FH_PERCENT,FH_INIVIGE"
	cQuery += " FROM " + RetSqlName("SFH")
	cQuery += " WHERE FH_FILIAL = '" + xFilial("SFH") + "'"
	cQuery += " AND "+cTabla+" = '"+cCod+"'"
	cQuery += " AND FH_LOJA ='"+cLoja+"'"
	cQuery += " AND FH_IMPOSTO ='"+cImpuesto+"'"

	cQuery += " AND FH_INIVIGE BETWEEN '"+SUBSTR(cFecha,1,6)+"01"+"' AND '"+ DTOS(LastDay( CTOD("01/"+SUBSTR(cFecha,5,2)+"/"+SUBSTR(cFecha,1,4))))+"' "
	cQuery += " AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cSFH, .T., .T.)

	(cSFH)->(dbGoTop())
	Do While (cSFH)->(!EOF())
		Iif ((cSFH)->FH_ISENTO=="S",aadd(aDatos,"1"),aadd(aDatos,"0"))
		aadd(aDatos,(cSFH)->FH_PERCENT)
		aadd(aDatos,(cSFH)->FH_INIVIGE)
		(cSFH)->(dbSkip())
	EndDo
	if len(aDatos)==0
		aDatos:={"0","0",""}
	EndIf

	(cSFH)->(dbCloseArea())
Return aDatos

Static Function numDoc(cTabla)

	Local nTamPV := TamSX3("F"+cTabla+"_PV")[1]
	Local nTamNF := TamSX3("F"+cTabla+"_DOC")[1]
	Local cDoc	 := &(cTmpPer+"->F"+cTabla+"_DOC")

	If nTamPV== 4
		cDoc := "0" + cDoc
	EndIf

	cDoc :=	Substr(cDoc,1,5)+"-"+Substr(cDoc,6,nTamNF)

return cDoc

Static Function tpajus(cTabla)
	Local cLeyenda :=""
	IF (cTmpPer)->(ColumnPos("F"+cTabla+"_TPAJUS"))>0
		cLeyenda:=  &("(cTmpPer)->F"+cTabla+"_TPAJUS")
	EndIf

	If cLeyenda== "Q"
		cLeyenda:="Diferencia Cantidad"
	elseIf cLeyenda== "P"
		cLeyenda:="Diferencia Precio"
	ElseIf cLeyenda== "C"
		cLeyenda:="Diferencia de Cambio"
	ElseIf  cLeyenda== "O"
		cLeyenda:="Otros Ajustes (Default)"
	EndIf

Return cLeyenda

Static Function IVARET(cDtIni,cDtFim, cTab)

	Local oTmpTable
	Local cQryRet :=""
	Local aAux 	  :={}
	Local cTmp1   := GetNextAlias()
	Local lTab	  := .F.

	DEFAULT cTab	:= ""

	lTab := !Empty(cTab)

	cQryRet:=" SELECT  FE_EMISSAO, FE_ORDPAGO, FE_TIPO,FE_FORNECE,FE_LOJA,FE_FILIAL, "
	cQryRet+=" FE_RETENC, FE_DTRETOR, FE_NRETORI, "
	cQryRet+=" EK_EMISSAO,EK_NUM,SUM(EK_VALOR) EK_VALOR, "
	cQryRet+=" FE_CLIENTE CLIENTE,FE_VALBASE,"
	cQryRet+=" COALESCE(A2_COD,'') CODF,COALESCE(A2_CGC,'') CUITF, COALESCE(A2_NOME,'') NOMEA2, A2_TIPO, A2_IVPDCOB,A2_PORIVA"
	If lTab
		cQryRet+=", FE_CFO, CCP_VDESTI"
	EndIf
	cQryRet+=" FROM "+RetsqlName("SFE")+" SFE "
	cQryRet+=" LEFT JOIN "+RetsqlName("SA2")+" SA2 ON "
	cQryRet+=" A2_FILIAL = '"+xFilial("SA2")+"' "
	cQryRet+=" AND FE_FORNECE=A2_COD "
	cQryRet+=" AND FE_LOJA=A2_LOJA "
	cQryRet+=" AND SA2.D_E_L_E_T_=''
	cQryRet+=" LEFT JOIN  "+RetSqlName('SEK')+"  SEK"
	cQryRet+=" ON EK_FORNECE = FE_FORNECE AND EK_LOJA = FE_LOJA AND EK_ORDPAGO = FE_ORDPAGO AND EK_TIPODOC = 'TB' "
	cQryRet+=" AND SFE.D_E_L_E_T_ = ' ' AND SEK.D_E_L_E_T_ <> '*' AND EK_TIPO IN ('NF')"
	cQryRet+=" AND EK_FILIAL = '" + xFilial("SEK") + "' "
	If lTab
		cQryRet+=" LEFT JOIN " + RetSqlName('CCP') + " CCP"
		cQryRet+=" ON CCP_FILIAL = '" + xFilial("CCP") + "' AND CCP_COD = '" + cTab + "' AND CCP_VORIGE = FE_CFO AND CCP.D_E_L_E_T_=' '
	EndIf
	cQryRet+=" WHERE SFE.D_E_L_E_T_='' "
	cQryRet+=" AND FE_FILIAL = '"+xFilial("SFE")+"' "
	cQryRet+=" AND FE_NROCERT <> 'NORET' "
	cQryRet+=" AND FE_TIPO='I' "//I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
	cQryRet+=" AND FE_FORNECE<>'' "
	cQryRet+=" AND FE_RETENC <> 0 "
	cQryRet+=" AND FE_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "

	If !Empty(cProv)
		cQryRet+=" AND FE_FORNECE IN (" + cProv + ")"
	EndIf
	If !Empty(cOrdP)
		cQryRet+=" AND FE_ORDPAGO IN (" + cOrdP + ")"
	EndIf
	If Select((cTmp1))>0
		DbSelectArea((cTmp1))
		TRBRET->(DbCloseArea())
	EndIf
	cQryRet+="GROUP BY FE_ORDPAGO,FE_FORNECE,FE_TIPO,FE_FILIAL,FE_LOJA, FE_EMISSAO,FE_RETENC,FE_DTRETOR,FE_NRETORI,EK_EMISSAO,EK_NUM,FE_CLIENTE,FE_VALBASE,A2_COD,A2_CGC,A2_NOME,A2_TIPO,A2_IVPDCOB,A2_PORIVA"
	If lTab
		cQryRet += ",CCP_VDESTI,FE_CFO"
	EndIf
	cQryRet := ChangeQuery(cQryRet)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRet),cTMP1,.T.,.T.)

	DbSelectArea("TRB1")
	TRB1->(DbSetOrder(1))

	aAdd(alArq,{'',oTmpTable})
	IF  !((cTmp1))->(Eof())
		While ((cTmp1))->( !Eof())
			RecLock('TRB1',.T.)
			aAux := Tipo((cTmp1)->A2_TIPO,(cTmp1)->A2_PORIVA)
			TRB1->VERSION   := "0100"
			TRB1->CODTRAZA  := PADR((cTmp1)->NOMEA2, 36, " ")
			TRB1->IMPUESTO  := "216"
			TRB1->REGIMEN   := IIf(lTab .and. !Empty((cTmp1)->CCP_VDESTI), AllTrim((cTmp1)->CCP_VDESTI),"214")
			TRB1->FCHRETPER := Substr((cTmp1)->FE_EMISSAO,7,2)+"/"+Substr((cTmp1)->FE_EMISSAO,5,2)+"/"+Substr((cTmp1)->FE_EMISSAO,1,4)
			TRB1->CONDICION := STRZERO(Val(aAux[1]),2)
			TRB1->IMPOSIBIL := "0"
			TRB1->NRORETMOT	:=	""
			TRB1->IMPRETPER	:=	Transform((cTmp1)->FE_RETENC  ,"@E 99999999999.99")
			TRB1->IMPCAL	:=	Transform((cTmp1)->FE_VALBASE ,"@E 99999999999.99")
			TRB1->REGEXCL	:=	STR(aAux[2])
			TRB1->POREXCL	:=	STR((cTmp1)->A2_PORIVA)
			TRB1->FECHPUB	:=	(cTmp1)->A2_IVPDCOB
			TRB1->TIPOCOMP	:=	IIF(Empty((cTmp1)->FE_NRETORI), "06", "03")
			TRB1->FCHCOMP	:=	Substr((cTmp1)->EK_EMISSAO,7,2)+"/"+Substr((cTmp1)->EK_EMISSAO,5,2)+"/"+Substr((cTmp1)->EK_EMISSAO,1,4)
			TRB1->NROCOMP	:=	STRZERO(VAL((cTmp1)->FE_ORDPAGO),12)
			TRB1->COE		:=	SPACE(12)
			TRB1->COEORI	:=	SPACE(12)
			TRB1->CAE		:=	SPACE(14)
			TRB1->IMPCMP	:=	Transform((cTmp1)->EK_VALOR,"@E 99999999999.99")
			TRB1->MOTEMI	:=	SPACE(30)
			TRB1->RETPERCL	:=	Alltrim(STRTRAN((cTmp1)->CUITF,"-",""))
			TRB1->CERORG	:=  PADL((cTmp1)->FE_NRETORI, 25, " ")
			If !Empty((cTmp1)->FE_DTRETOR)
				TRB1->CERORGFCH := Substr((cTmp1)->FE_DTRETOR,7,2)+"/"+Substr((cTmp1)->FE_DTRETOR,5,2)+"/"+Substr((cTmp1)->FE_DTRETOR,1,4)
			Else
				TRB1->CERORGFCH := PADR("", 10, " ")
			EndIf
			
			TRB1->CERORGIMP	:=	Iif(TRB1->TIPOCOMP=="06","",Transform((cTmp1)->EK_VALOR,"@E 99999999999.99"))
			
			If Empty(TRB1->CERORG)
				TRB1->MOTANU:=      PADR("", 1, " ")
			Else
				TRB1->MOTANU:=      "4"
			Endif
			(cTmp1)->(dbSkip())
		Enddo

	Endif
	(cTmp1)->(dbCloseArea())
	If !lAutomato
		If MsgYesNo(STR0004)
			TRelSFE("TRB1")
		EndIf
	EndIf	
Return Nil

Static Function IVAPER(cDtIni,cDtFim, cEspecie, cTab)

	Local cQryPer   :=""
	Local nlI		:=0
	Local aNrLvrIV	:={}

	Local cQryNLvro	:= ""
	Local oTmpTable
	Local cAux      :=""
	Local aDatos :={}
	Local cTmpLvro:= GetNextAlias()
	Local lTab	  := .F.

	DEFAULT cTab	:= ""

	lTab := !Empty(cTab)

	cQryNLvro:=" SELECT DISTINCT FB_CLASSIF CODIMP1 ,FB_CLASSE CODIMP2 ,FB_CODIGO CODIGO,FB_DESCR DESCR, FB_CPOLVRO NLIVRO,FB_TIPO TIPO, FB_ESTADO ESTADO "
	cQryNLvro+=" FROM "+RetsqlName("SFB")+" SFB "
	cQryNLvro+=" WHERE D_E_L_E_T_='' "
	cQryNLvro+=" AND FB_FILIAL= '" + xFilial("SFB") + "' "
	cQryNLvro+=" AND FB_CLASSIF = '3' "
	cQryNLvro+=" AND FB_CLASSE = 'P' "
	cQryNLvro+=" AND FB_TIPO =   'N' "

	If Select(cTmpLvro)>0
		DbSelectArea(cTmpLvro)
		(cTmpLvro)->(DbCloseArea())
	EndIf

	cTRBLVRO := ChangeQuery(cQryNLvro)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,cTmpLvro, .T., .F.)


	DbSelectArea(cTmpLvro)
	(cTmpLvro)->(dbGoTop())
	If (cTmpLvro)->(!Eof())
		Do While (cTmpLvro)->(!Eof())
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))
			If (cTmpLvro)->CODIMP1=="3" .And. (cTmpLvro)->TIPO == "N" .And. (cTmpLvro)->CODIMP2$ "P"
				aAdd(aNrLvrIV,{(cTmpLvro)->CODIGO,(cTmpLvro)->NLIVRO})
			Endif
			(cTmpLvro)->(DbSkip())
		End
	EndIf

	cQryPer:=" SELECT SF3.* , "
	cQryPer+=" COALESCE(A1_NOME,'') NOMEA1 ,A1_CGC, A1_NOME , A1_TIPO,SF2.*,SF1.*  "
	If lTab
		cQryPer+=", CCP_VDESTI"
	EndIf
	cQryPer+=" FROM "+RetsqlName("SF3")+" SF3 "
	cQryPer+=" LEFT JOIN "+RetsqlName("SA1")+" SA1 ON "
	cQryPer+=" A1_FILIAL = '" + xFilial("SA1") + "' "
	cQryPer+=" AND F3_CLIEFOR=A1_COD "
	cQryPer+=" AND F3_LOJA=A1_LOJA "
	cQryPer+=" AND SA1.D_E_L_E_T_='' "
	cQryPer+=" AND F3_TIPOMOV = 'V' "

	cQryPer+=" LEFT JOIN  "+RetSqlName('SF2')+" SF2"
	cQryPer+=" ON F2_DOC = F3_NFISCAL AND F2_LOJA = F3_LOJA  AND F2_CLIENTE=F3_CLIEFOR"
	cQryPer+=" AND SF3.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ <> '*' "
	cQryPer+=" AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "

	cQryPer+=" LEFT JOIN  "+RetSqlName('SF1')+" SF1"
	cQryPer+=" ON F1_DOC = F3_NFISCAL AND F1_LOJA = F3_LOJA  AND F1_FORNECE=F3_CLIEFOR"
	cQryPer+=" AND SF3.D_E_L_E_T_ = ' ' AND SF1.D_E_L_E_T_ <> '*' "
	cQryPer+=" AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "

	If lTab
		cQryPer+=" LEFT JOIN " + RetSqlName('CCP') + " CCP"
		cQryPer+=" ON CCP_FILIAL = '" + xFilial("CCP") + "' AND CCP_COD = '" + cTab + "' AND CCP_VORIGE = F3_CFO AND CCP.D_E_L_E_T_=' '
	EndIf

	cQryPer+=" WHERE SF3.D_E_L_E_T_='' "
	cQryPer+=" AND ((F3_ESPECIE  IN ('"+iif((cEspecie!="TODOS"),cEspecie,"NF','NCC','NDC" )+"') "
	cQryPer+=" ))"
	If (Len(aNrLvrIV)>0)
		cQryPer += " AND ("
		For nlI:=1 To Len(aNrLvrIV)
			If nlI <> 1
				cQryPer += " OR "
			EndIf
			cQryPer += " F3_VALIMP"+aNrLvrIV[nlI][2]+" > 0 "
		Next nlI
		cQryPer += ")"
	EndIf

	If !Empty(cClie)
		cQryPer+=" AND F3_CLIEFOR IN (" + cClie+ ")"
	EndIf
	If !Empty(cNumDoc)
		cQryPer+=" AND F3_NFISCAL IN (" + cNumDoc + ")"
	EndIf

	cQryPer+=" AND F3_FILIAL = '"+xFilial("SF3")+"' "
	cQryPer+=" AND F3_ENTRADA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
	cQryPer+=" AND F3_CFO <>'' "
	cQryPer+=" ORDER BY F3_EMISSAO, F3_NFISCAL , F3_SERIE , F3_CLIEFOR ,F3_LOJA, F3_TIPOMOV "
	If lTab
		cQryPer += ",CCP_VDESTI"
	EndIf

	If Select(cTmpPer)>0
		DbSelectArea(cTmpPer)
		(cTmpPer)->(DbCloseArea())
	EndIf

	cTRBPER := ChangeQuery(cQryPer)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPER ) ,cTmpPer, .T., .F.)

	DbSelectArea(cTmpPer)
	(cTmpPer)->(dbGoTop())
	aAdd(alArq,{'',oTmpTable})
	If (cTmpPer)->(!Eof())
		Do While (cTmpPer)->(!Eof())
			DbSelectArea("SF3")
			SF3->(DbSetOrder(4))//F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
			SF3->(DbGoTop())
			If DbSeek(AvKey((cTmpPer)->F3_FILIAL,"F3_FILIAL")+AvKey((cTmpPer)->F3_CLIEFOR,"F3_CLIEFOR")+AvKey((cTmpPer)->F3_LOJA,"F3_LOJA")+AvKey((cTmpPer)->F3_NFISCAL,"F3_NFISCAL"+AvKey((cTmpPer)->F3_SERIE,"F3_SERIE")))

				If (Len(aNrLvrIV)>0)
					If (((cTmpPer)->F3_ESPECIE!="NCC"),cAux:="2",cAux:="1")

						DbSelectArea("TRB2")
						TRB2->(dbSetOrder(1))//RET_CODRET+RET_NUMCER
						TRB2->(dbGoTop())
						RecLock("TRB2",.T.)

						aAux := Tipo((cTmpPer)->A1_TIPO,0,ALLTRIM((cTmpPer)->F3_ESPECIE))
						aDatos:=sfhreg(&("(cTmpPer)->F"+cAux+"_EMISSAO"),(cTmpPer)->F3_CLIEFOR,(cTmpPer)->F3_LOJA,"IVP",.T.)

						TRB2->VERSION   := "0100"
						TRB2->CODTRAZA  := PADR((cTmpPer)->A1_NOME, 36, " ")
						TRB2->IMPUESTO  := "216"
						TRB2->REGIMEN   := IIf(lTab .and. !Empty((cTmpPer)->CCP_VDESTI), AllTrim((cTmpPer)->CCP_VDESTI),"214")
						TRB2->FCHRETPER := Substr((cTmpPer)->F3_EMISSAO,7,2)+"/"+Substr((cTmpPer)->F3_EMISSAO,5,2)+"/"+Substr((cTmpPer)->F3_EMISSAO,1,4)
						TRB2->CONDICION := STRZERO(Val(aAux[1]),2)
						TRB2->IMPOSIBIL := "0"
						TRB2->NRORETMOT	:=	""
						TRB2->IMPRETPER	:=	Transform(&("(cTmpPer)->F3_VALIMP"+aNrLvrIV[1][2])	,"@E 99999999999.99")
						TRB2->IMPCAL	:=	Transform(&("(cTmpPer)->F3_BASIMP"+aNrLvrIV[1][2]) ,"@E 99999999999.99")
						TRB2->REGEXCL	:=	aDatos[1]
						TRB2->POREXCL	:=	Transform(aDatos[2],"@E 999.99")
						TRB2->FECHPUB	:=	Substr(aDatos[3],7,2)+"/"+Substr(aDatos[3],5,2)+"/"+Substr(aDatos[3],1,4)//(cTmpPer)->A2_IVPDCOB
						TRB2->TIPOCOMP	:=	aAux[3]
						TRB2->FCHCOMP	:=	Substr((cTmpPer)->F3_EMISSAO,7,2)+"/"+Substr((cTmpPer)->F3_EMISSAO,5,2)+"/"+Substr((cTmpPer)->F3_EMISSAO,1,4)
						TRB2->NROCOMP	:=	numDoc(cAux)
						TRB2->COE		:=	SPACE(12)
						TRB2->COEORI	:=	SPACE(12)
						TRB2->CAE		:=	(cTmpPer)->F3_CAE
						TRB2->IMPCMP	:=	Transform(&("(cTmpPer)->F"+cAux+"_VALBRUT") ,"@E 99999999999.99")
						TRB2->MOTEMI	:=	PADR(tpajus(cAux), 30, " ")
						TRB2->RETPERCL	:=	Alltrim(STRTRAN((cTmpPer)->A1_CGC,"-",""))
						TRB2->CERORG	:=  PADL(&("(cTmpPer)->F"+cAux+"_DOC"), 25, " ")
						TRB2->CERORGFCH :=	Substr(&("(cTmpPer)->F"+cAux+"_EMISSAO"),7,2)+"/"+Substr(&("(cTmpPer)->F"+cAux+"_EMISSAO"),5,2)+"/"+Substr(&("(cTmpPer)->F"+cAux+"_EMISSAO"),1,4)
						TRB2->CERORGIMP	:=	Transform(&("(cTmpPer)->F"+cAux+"_VALBRUT"),"@E 99999999999.99")
						TRB2->MOTANU:=      PADR("", 1, " ")
						
						TRB2->(MsUnlock())
					EndIf
				EndIf

				(cTmpPer)->(DbSkip())
			EndDo
		EndIf
		If !lAutomato
			If MsgYesNo(STR0004)
				TRelSFE("TRB2")
			EndIf
		EndIf
			
		Return Nil

Function fRetSUSS(dDataIni,dDataFin,lCCP,cSuc)

	Local cProv     := ""
	Local cOrdP     := ""
	Local cValBase  := "0.00"
	Local oTmpTable
	Local cTmp :=GetNextAlias()
	Local lGrvtxt := .F.

	Default cSuc := ""
	cQuery:=" SELECT DISTINCT (FE_NROCERT) NROCERT,
	cQuery+=" A2_COD COD,"
	cQuery+="		A2_CGC CUIT,"
	cQuery+=" A2_NOME NOM,"
	cQuery+=" FE_EMISSAO FCHRET,"
	cQuery+=" SUM(FE_RETENC) RETENIDO,"
	cQuery+=" FE_ORDPAGO ORDPAG,"
	cQuery+=" FE_NRETORI NUMCERTORI,"
	cQuery+=" FE_DTRETOR FCHCERTORI,"
	cQuery+=" FE_DTESTOR FCHESTOR,"
	cQuery+=" FE_SIRECER NUMSIRE,"
	cQuery+=" EK_EMISSAO FCHCOMP,"
	If lCCP
		cQuery+=" CCP_VDESTI AS CODREG"
	Else
		cQuery+=" CODREG = CASE WHEN FE_CONCEPT='1' THEN '754'"
		cQuery+="               WHEN FE_CONCEPT='2' THEN '755'"
		cQuery+="               WHEN FE_CONCEPT='3' THEN '756'"
		cQuery+="				ELSE"
		cQuery+="               ''"
		cQuery+="				END"
	EndIf
	cQuery+=" FROM "+RetSqlName('SFE')+" SFE"
	cQuery+=" INNER JOIN "+RetSqlName('SA2')+" SA2"
	cQuery+="       ON A2_COD=FE_FORNECE AND A2_LOJA=FE_LOJA AND SFE.D_E_L_E_T_='' AND SA2.D_E_L_E_T_ <> '*' "
	cQuery+=" INNER JOIN (SELECT DISTINCT EK_FILIAL, EK_ORDPAGO, EK_TIPODOC, EK_PREFIXO, EK_FORNECE, EK_LOJA, "
	cQuery+="                    D_E_L_E_T_, EK_EMISSAO, EK_TIPO FROM "+RetSqlName('SEK')+" WHERE EK_FILIAL ='"+xFilial("SEK",cSuc)+"' ) SEK"
	cQuery+=" ON EK_FORNECE = FE_FORNECE AND EK_LOJA = FE_LOJA AND EK_ORDPAGO = FE_ORDPAGO AND EK_TIPODOC = 'TB' "
	cQuery+="    AND SFE.D_E_L_E_T_ = ' ' AND SEK.D_E_L_E_T_ <> '*' AND EK_TIPO IN ('NF')"
	If lCCP
		cQuery+=" INNER JOIN (SELECT DISTINCT CCP_FILIAL, CCP_COD, CCP_VORIGE, CCP_DESCR, CCP_VDESTI, CCP_ARQUIV, CCP_CAMPO, D_E_L_E_T_"
		cQuery+=" FROM " +RetSqlName('CCP')+") CCP"
		cQuery+=" ON CCP_FILIAL='"+xFilial('CCP',cSuc)+"' AND SFE.D_E_L_E_T_='' AND CCP_COD='SUSS' AND CCP_VORIGE=FE_CONCEPT AND CCP.D_E_L_E_T_ <> '*' "
	EndIf
	cQuery+=" WHERE FE_TIPO='S'"
	cQuery+=" AND FE_EMISSAO BETWEEN '"+dTOs(dDataIni)+"' AND '"+dTOs(dDataFin)+"'"
	cQuery+=" AND FE_NROCERT <> 'NORET'"
	cQuery+=" AND FE_NRETORI <> 'NORET'"
	cQuery+=" AND FE_FILIAL = '" +xFilial("SFE",cSuc) + "' "
	If !Empty(cProv)
		cQuery+=" AND FE_FORNECE IN (" + cProv + ")"
	EndIf
	If !Empty(cOrdP)
		cQuery+=" AND FE_ORDPAGO IN (" + cOrdP + ")"
	EndIf
	cQuery+=" GROUP BY FE_NROCERT, A2_COD, A2_CGC, A2_NOME, FE_EMISSAO, FE_ORDPAGO, FE_NRETORI, FE_DTRETOR, FE_DTESTOR,FE_SIRECER, EK_EMISSAO, CCP_VDESTI "
	cQuery+=" ORDER BY FE_EMISSAO"

	cQuery:=ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)  //TRB

	DbSelectArea("TRB")
	TRB->(DbSetOrder(1))
	aAdd(alArq,{'',oTmpTable})

	//Insertar los registros en la tabla "TRB"
	IF  !(cTmp)->(Eof())
		While (cTmp)->( !Eof())
			if Empty((cTmp)->NUMSIRE) .and. Empty((cTmp)->FCHESTOR) .and. Empty((cTmp)->NUMCERTORI)
				lGrvtxt := .T.
			ElseIf !(Empty((cTmp)->NUMSIRE)) .and. !(Empty((cTmp)->NUMCERTORI))
				lGrvtxt := .T.
			ElseIf Empty((cTmp)->NUMSIRE) .and. !(stod((cTmp)->FCHESTOR) >= dDataIni .and. stod((cTmp)->FCHESTOR) <= dDataFin) .and. Empty((cTmp)->NUMCERTORI)
				lGrvtxt := .T.
			Endif
			if lGrvtxt
				If !(TRB->(MsSeek(Padr((cTmp)->CODREG,Len(TRB->REGIMEN))+Padr(Alltrim(SM0->M0_CGC),Len(TRB->CUIT))+PADR((cTmp)->ORDPAG, 16, " ")+IIF(Empty((cTmp)->NUMCERTORI), "06", "03"))))
					RecLock('TRB',.T.)
					cValBase := ObtValBase(dDataIni, dDataFin, (cTmp)->COD, (cTmp)->ORDPAG, (cTmp)->NUMCERTORI,cSuc)
					TRB->FORMULARIO   := "2004"
					TRB->VERSION      := "0100"
					TRB->CODTRAZA     := PADR((cTmp)->NOM, 10, " ")
					TRB->CUIT         := Alltrim(SM0->M0_CGC)
					TRB->IMPUESTO     := "353"
					TRB->REGIMEN      := (cTmp)->CODREG
					TRB->CUITRET      := Alltrim((cTmp)->CUIT)
					TRB->FCHRET       := IIF(Empty((cTmp)->NUMCERTORI),Substr((cTmp)->FCHRET,7,2)+"/"+Substr((cTmp)->FCHRET,5,2)+"/"+Substr((cTmp)->FCHRET,1,4),Substr((cTmp)->FCHCOMP,7,2)+"/"+Substr((cTmp)->FCHCOMP,5,2)+"/"+Substr((cTmp)->FCHCOMP,1,4))
					TRB->TIPCOMP      := IIF(Empty((cTmp)->NUMCERTORI), "06", "03")
					TRB->FCHCOMP      := Substr((cTmp)->FCHCOMP,7,2)+"/"+Substr((cTmp)->FCHCOMP,5,2)+"/"+Substr((cTmp)->FCHCOMP,1,4)
					TRB->NROCOMPRO    := PADR((cTmp)->ORDPAG, 16, " ")
					TRB->IMPCOMP      := cValBase
					TRB->IMPRETE      := Transform(IIf((cTmp)->RETENIDO > 0, (cTmp)->RETENIDO, (cTmp)->RETENIDO * (-1)), "@E 99999999999.99")
					TRB->NROCERTORI   := Iif(TRB->TIPCOMP=="06",Space(25), PADL(Alltrim((cTmp)->NUMSIRE),25," "))
					TRB->IMPCERTORI   := Iif(TRB->TIPCOMP=="06","",cValBase)
					If !Empty((cTmp)->FCHCERTORI)
						TRB->FCHCERTORI := Substr((cTmp)->FCHCERTORI,7,2)+"/"+Substr((cTmp)->FCHCERTORI,5,2)+"/"+Substr((cTmp)->FCHCERTORI,1,4)
					Else
						TRB->FCHCERTORI := PADR("", 10, " ")
					EndIf
					TRB->OTROS := PADR("", 30, " ")
					TRB->(MsunLock())
				Endif
			Endif
			lGrvtxt := .F.
			(cTmp)->(dbSkip())
		Enddo

	Endif
	(cTmp)->(dbCloseArea())
	If !lAglFil
		If !lAutomato
			If MsgYesNo(STR0004) // "ฟVerificar los para la exportaci๓n?"
				TRelSFE("TRB")
			EndIf
		EndIf
	EndIf
Return


Function fRetGAN(dDataIni,dDataFin,cSuc)

Local cFechaAux	:= ""
Local lRev		:= .F.
Local oTmpTable
Local cTmp 		:=GetNextAlias()

Default cSuc 	:= ""


	cQuery 	:= "SELECT A2_NOME, A2_CGC, A2_NIF, A2_END, A2_PAIS, FE_VALBASE, FE_EMISSAO, FE_ORDPAGO, FE_RETENC, FE_ALIQ,FE_NRETORI, FE_DTRETOR, "
	cQuery	+= "CCP.CCP_VDESTI AS CODPAIS, CCP1.CCP_VDESTI AS REGIMEN, CCP2.CCP_VDESTI AS CODALIQ"
	cQuery	+= " FROM "+RetSqlName('SFE')+" SFE"
	cQuery	+= " INNER JOIN "+RetSqlName('SA2')+" SA2"
	cQuery	+= "       ON A2_COD=FE_FORNECE AND A2_LOJA=FE_LOJA AND A2_TIPO = 'E' AND A2_FILIAL = '" +xFilial("SA2",cSuc) + "' AND SA2.D_E_L_E_T_ <> '*' "
	cQuery	+= " LEFT JOIN "+RetSqlName('CCP')+" CCP"
	cQuery	+= "       ON CCP_FILIAL='" +xFilial("CCP",cSuc) + "' AND CCP.CCP_COD='GNBE' AND CCP.CCP_VORIGE=A2_PAIS AND CCP.D_E_L_E_T_ <> '*'"
	cQuery	+= " LEFT JOIN "+RetSqlName('CCP')+" CCP1"
	cQuery	+= "       ON CCP1.CCP_FILIAL='" +xFilial("CCP",cSuc) + "' AND CCP1.CCP_COD='RGBE' AND CCP1.CCP_VORIGE=FE_ALIQ AND CCP1.D_E_L_E_T_ <> '*'"
	cQuery	+= " LEFT JOIN "+RetSqlName('CCP')+" CCP2"
	cQuery	+= "       ON CCP2.CCP_FILIAL='" +xFilial("CCP",cSuc) + "' AND CCP2.CCP_COD='ALBE' AND CCP2.CCP_VORIGE=FE_ALIQ AND CCP2.D_E_L_E_T_ <> '*'"
	cQuery 	+= "WHERE FE_TIPO = 'G' "
	cQuery	+= "AND FE_EMISSAO BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFin) + "'"
	cQuery	+= "AND ( FE_DTESTOR < '" + DToS(dDataIni) + "' Or " 
	cQuery	+= "FE_DTESTOR > '" + DToS(dDataFin) + "' Or " 
	cQuery	+= "FE_DTESTOR = ' ' Or "
	cQuery	+= "FE_NRETORI <> ' ' "
	cQuery	+= ") And ( "
	cQuery	+= "FE_DTRETOR < '" + DToS(dDataIni) + "' Or "
	cQuery	+= "FE_DTRETOR > '" + DToS(dDataFin) + "' Or "
	cQuery	+= "FE_DTRETOR = ' ' Or "
	cQuery	+= "FE_NRETORI = ' ' ) "
	cQuery	+= "AND FE_FILIAL = '" +xFilial("SFE",cSuc) + "' "
	If !Empty(cProv)
		cQuery+=" AND FE_FORNECE IN (" + cProv + ")"
	EndIf
	If !Empty(cOrdP)
		cQuery+=" AND FE_ORDPAGO IN (" + cOrdP + ")"
	EndIf
	cQuery	+= "AND SFE.D_E_L_E_T_='' "
	cQuery	+= " ORDER BY FE_EMISSAO"

	cQuery:=ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)  //TRB


	DbSelectArea("TRB3")
	TRB3->(DbSetOrder(1))
	aAdd(alArq,{'',oTmpTable})

	//Insertar los registros en la tabla "TRB3" 
	IF  !(cTmp)->(Eof())
		While (cTmp)->( !Eof())
			If !(TRB3->(MsSeek(IIF(Empty((cTmp)->FE_NRETORI), "06", "03")+Padr(Alltrim(SM0->M0_CGC),Len(TRB->CUIT))+PADR((cTmp)->FE_ORDPAGO, 16, " "))))
				RecLock('TRB3',.T.)
				lRev				:= !Empty((cTmp)->FE_NRETORI) 
				cFechaAux			:= DTOC(SToD(Iif(lRev,(cTmp)->FE_DTRETOR,(cTmp)->FE_EMISSAO)))
				TRB3->FORMULARIO	:= "2003"
				TRB3->VERSION   	:= "0100"
				TRB3->CODTRAZA  	:= (cTmp)->A2_NOME
				TRB3->CUIT			:= Alltrim(SM0->M0_CGC)
				TRB3->IMPUESTO  	:= "218"
				TRB3->REGIMEN   	:= Iif(ValType((cTmp)->REGIMEN) == "C",(cTmp)->REGIMEN,"") 
				TRB3->CUITORD   	:= (cTmp)->A2_CGC
				TRB3->FCHRET   		:= cFechaAux
				TRB3->TIPCOMP   	:= "06"
				TRB3->FCHCOMP   	:= cFechaAux
				TRB3->NROCOMPRO 	:= (cTmp)->FE_ORDPAGO
				TRB3->IMPCOMP   	:= Transform(IIf((cTmp)->FE_VALBASE > 0, (cTmp)->FE_VALBASE, (cTmp)->FE_VALBASE * (-1)), "@E 99999999999.99") 
				TRB3->FILLER   		:= ""
				If !lRev
					TRB3->NROCERTORI	:= ""
					TRB3->FCHCERTORI	:= ""
					TRB3->IMPCERTORI	:= ""
					TRB3->MOTEMINCC 	:= ""
				else
					TRB3->TIPCOMP   	:= "03"
					TRB3->NROCERTORI	:= (cTmp)->FE_NRETORI
					TRB3->FCHCERTORI	:= DTOC(SToD((cTmp)->FE_EMISSAO))
					TRB3->IMPCERTORI	:= Transform(IIf((cTmp)->FE_VALBASE > 0, (cTmp)->FE_VALBASE, (cTmp)->FE_VALBASE * (-1)), "@E 99999999999.99")
					TRB3->MOTEMINCC 	:= "ANULACIำN"
				EndIf
				TRB3->NRORET    	:= "0"
				TRB3->NORETMOT  	:= ""
				TRB3->APLCDI    	:= "0"
				TRB3->CODLIAQ   	:= Iif(ValType((cTmp)->CODALIQ) == "C",(cTmp)->CODALIQ,"") 
				TRB3->APACRE  		:= "0"
				TRB3->RETCVENIF 	:= (cTmp)->A2_NIF
				TRB3->RETNOMDE 		:= (cTmp)->A2_NOME
				TRB3->RETDOMEXT 	:= (cTmp)->A2_END
				TRB3->RETDOMEXTP	:= IIf(ValType((cTmp)->CODPAIS) == "C",(cTmp)->CODPAIS,"")
				TRB3->RETTIPPER 	:= "J"
				TRB3->RETNACCONF	:= ""
				TRB3->RETNACCONP	:= ""

				TRB3->(MsunLock())
			Endif
			(cTmp)->(dbSkip())
		Enddo

	Endif
	(cTmp)->(dbCloseArea())
	If !lAglFil
		If !lAutomato
			If MsgYesNo(STR0004) // "ฟVerificar los para la exportaci๓n?"
				TRelSFE("TRB3")
			EndIf
		EndIf
	EndIf
Return

/*++++++++++++++++++++++++++++ */

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRelSFE   บAutor  ณRenato Nagib        บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEmite Reatorio para conferencia dos registros a serem       บฑฑ
ฑฑบ          ณexportados para txt                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TRelSFE(cTab)
	Local olReport
	Private cTabla:=cTab
	If TRepInUse()
		olReport:=ReportDef()
		olReport:PrintDialog()
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณRenato Nagib        บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar utilizada para definicao do relatorio TRelSFEบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina                                                  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()
	Local olReport
	Local oSection
	
	if cTabla =="TRB"
			olReport:=TReport():New("SFETxt", STR0005 ,,{|olReport| PrintReport(olReport)}, STR0006) //"Datos para exportaci๓n" ## //"Conferencia dos dados para exportacao txt"
			oSection:=TRSection():new(olReport,STR0007,{ cTabla}) //"Impostos"
			TRCell():New(oSection,"FORMULARIO" ,""   ,,                  ,5 )
			TRCell():New(oSection,"VERSION"    ,""   ,,                  ,5 )
			TRCell():New(oSection,"CODTRAZA"   ,"SA2",,                  ,10)
			TRCell():New(oSection,"CUIT"       ,"SM0",,"@R 99-99999999-9",15)
			TRCell():New(oSection,"IMPUESTO"   ,""   ,,                  ,3 )
			TRCell():New(oSection,"REGIMEN"    ,"CCP",,                  ,3 )
			TRCell():New(oSection,"CUITRET"    ,"SA2",,"@R 99-99999999-9",15)
			TRCell():New(oSection,"FCHRET"     ,"SFE",,                  ,10)
			TRCell():New(oSection,"TIPCOMP"    ,""   ,,                  ,2 )
			TRCell():New(oSection,"FCHCOMP"    ,"SEK",,                  ,10)
			TRCell():New(oSection,"NROCOMPRO"  ,"SFE",,                  ,16)
			TRCell():New(oSection,"IMPCOMP"    ,"SEK",,                  ,14)
			TRCell():New(oSection,"IMPRETE"    ,"SFE",,                  ,14)
	ElseIf cTabla =="TRB3"
		olReport:=TReport():New("SFETxt", STR0005 ,,{|olReport| PrintReport(olReport)}, STR0006) //"Datos para exportaci๓n" ## //"Conferencia dos dados para exportacao txt"
		oSection:=TRSection():new(olReport,STR0007,{ cTabla}) //"Impostos"
		TRCell():New(oSection,"FORMULARIO" ,""   ,,                  ,5 )
		TRCell():New(oSection,"VERSION"    ,""   ,,                  ,5 )
		TRCell():New(oSection,"CODTRAZA"   ,"SA2",,                  ,10)
		TRCell():New(oSection,"CUIT"       ,"SM0",,"@R 99-99999999-9",15)
		TRCell():New(oSection,"IMPUESTO"   ,""   ,,                  ,3 )
		TRCell():New(oSection,"REGIMEN"    ,"CCP",,                  ,3 )
		TRCell():New(oSection,"CUITORD"    ,"SA2",,"@R 99-99999999-9",15)
		TRCell():New(oSection,"FCHRET"     ,"SFE",,                  ,10)
		TRCell():New(oSection,"TIPCOMP"    ,""   ,,                  ,2 )
		TRCell():New(oSection,"FCHCOMP"    ,"SEK",,                  ,10)
		TRCell():New(oSection,"NROCOMPRO"  ,"SFE",,                  ,16)
		TRCell():New(oSection,"IMPCOMP"    ,"SEK",,                  ,14)
		TRCell():New(oSection,"CODLIAQ"    ,"CCP",,                  ,4 )

	Else
		olReport:=TReport():New("SFETxt", STR0005 ,,{|olReport| PrintReport(olReport)}, STR0006) //"Datos para exportaci๓n" ## //"Conferencia dos dados para exportacao txt"
		oSection:=TRSection():new(olReport,STR0007,{ cTabla}) //"Impostos"
		TRCell():New(oSection,"VERSION"    ,"",,                  ,5 )
		TRCell():New(oSection,"CODTRAZA"   ,"",,                  ,10)
		TRCell():New(oSection,"IMPUESTO"   ,"",,                  ,3 )
		TRCell():New(oSection,"REGIMEN"    ,"",,                  ,3 )
		TRCell():New(oSection,"CUITRET"    ,"",,"@R 99-99999999-9",15)
		TRCell():New(oSection,"FCHRETPER"     ,"",,                  ,10)
		TRCell():New(oSection,"TIPCOMP"    ,"",,                  ,2 )
		TRCell():New(oSection,"FCHCOMP"    ,"",,                  ,10)
		TRCell():New(oSection,"NROCOMPRO"  ,"",,                  ,16)
		TRCell():New(oSection,"IMPCOMP"    ,"",,                  ,14)
		TRCell():New(oSection,"IMPRETEPER"    ,"",,                  ,14)
	EndIf
Return olReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณRenato Nagib       บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar utilizada para impressao do Relatorio       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(olReport)
	Local olSection :=olReport:Section(1)
	
	If cTabla =="TRB"
		olReport:Section(1):Cell("FORMULARIO"):SetBlock( {|| &(cTabla+"->FORMULARIO")} )
		olReport:Section(1):Cell("VERSION"   ):SetBlock( {|| &(cTabla+"->VERSION")   } )
		olReport:Section(1):Cell("CODTRAZA"  ):SetBlock( {|| &(cTabla+"->CODTRAZA")  } )
		olReport:Section(1):Cell("CUIT")     :SetBlock({||   &(cTabla+"->CUIT")})
		olReport:Section(1):Cell("IMPUESTO"  ):SetBlock( {|| &(cTabla+"->IMPUESTO")  } )
		olReport:Section(1):Cell("REGIMEN"   ):SetBlock( {|| &(cTabla+"->REGIMEN")   } )
		olReport:Section(1):Cell("CUITRET"   ):SetBlock( {|| &(cTabla+"->CUITRET")   } )
		olReport:Section(1):Cell("FCHRET"    ):SetBlock( {|| &(cTabla+"->FCHRET")    } )
		olReport:Section(1):Cell("TIPCOMP"   ):SetBlock( {|| &(cTabla+"->TIPCOMP")   } )
		olReport:Section(1):Cell("FCHCOMP"   ):SetBlock( {|| &(cTabla+"->FCHCOMP")   } )
		olReport:Section(1):Cell("NROCOMPRO" ):SetBlock( {|| &(cTabla+"->NROCOMPRO") } )
		olReport:Section(1):Cell("IMPCOMP"   ):SetBlock( {|| &(cTabla+"->IMPCOMP")   } )
		olReport:Section(1):Cell("IMPRETE"   ):SetBlock( {|| &(cTabla+"->IMPRETE")   } )
		olSection:Print()
	ElseIf cTabla == "TRB3"
		olReport:Section(1):Cell("FORMULARIO"):SetBlock( {|| &(cTabla+"->FORMULARIO")} )
		olReport:Section(1):Cell("VERSION"   ):SetBlock( {|| &(cTabla+"->VERSION")   } )
		olReport:Section(1):Cell("CODTRAZA"  ):SetBlock( {|| &(cTabla+"->CODTRAZA")  } )
		olReport:Section(1):Cell("CUIT"	 	 ):SetBlock( {|| &(cTabla+"->CUIT")      } )
		olReport:Section(1):Cell("IMPUESTO"  ):SetBlock( {|| &(cTabla+"->IMPUESTO")  } )
		olReport:Section(1):Cell("REGIMEN"   ):SetBlock( {|| &(cTabla+"->REGIMEN")   } )
		olReport:Section(1):Cell("CUITORD"   ):SetBlock( {|| &(cTabla+"->CUITORD")   } )
		olReport:Section(1):Cell("FCHRET"    ):SetBlock( {|| &(cTabla+"->FCHRET")    } )
		olReport:Section(1):Cell("TIPCOMP"   ):SetBlock( {|| &(cTabla+"->TIPCOMP")   } )
		olReport:Section(1):Cell("FCHCOMP"   ):SetBlock( {|| &(cTabla+"->FCHCOMP")   } )
		olReport:Section(1):Cell("NROCOMPRO" ):SetBlock( {|| &(cTabla+"->NROCOMPRO") } )
		olReport:Section(1):Cell("IMPCOMP"   ):SetBlock( {|| &(cTabla+"->IMPCOMP")   } )
		olReport:Section(1):Cell("CODLIAQ"   ):SetBlock( {|| &(cTabla+"->CODLIAQ")   } )

		olSection:Print()
	Else

		olReport:Section(1):Cell("VERSION"   ):SetBlock( {|| &(cTabla+"->VERSION")   } )
		olReport:Section(1):Cell("CODTRAZA"  ):SetBlock( {|| &(cTabla+"->CODTRAZA")  } )
		olReport:Section(1):Cell("IMPUESTO"  ):SetBlock( {|| &(cTabla+"->IMPUESTO")  } )
		olReport:Section(1):Cell("REGIMEN"   ):SetBlock( {|| &(cTabla+"->REGIMEN")   } )
		olReport:Section(1):Cell("CUITRET"   ):SetBlock( {|| &(cTabla+"->RETPERCL")   } )
		olReport:Section(1):Cell("FCHRETPER" ):SetBlock( {|| &(cTabla+"->FCHRETPER")    } )
		olReport:Section(1):Cell("TIPCOMP"   ):SetBlock( {|| &(cTabla+"->TIPOCOMP")   } )
		olReport:Section(1):Cell("FCHCOMP"   ):SetBlock( {|| &(cTabla+"->FCHCOMP")   } )
		olReport:Section(1):Cell("NROCOMPRO" ):SetBlock( {|| &(cTabla+"->NROCOMP") } )
		olReport:Section(1):Cell("IMPCOMP"   ):SetBlock( {|| &(cTabla+"->IMPCMP")   } )
		olReport:Section(1):Cell("IMPRETEPER"   ):SetBlock( {|| &(cTabla+"->IMPRETPER")   } )

		olSection:Print()
	EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFDelSUSS    บAutor  ณRenato Cruz nagib               28/04/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui  o arquivo temporario processado                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSUSS                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Function FDelSUSS(aDelArq)
	Local aAreaDel := GetArea()
	Local nLoop := 0

	For nLoop := 1 To Len(aDelArq)
		If valtype(aDelArq[nLoop,2]) == "O"
			aDelArq[nLoop,2]:Delete()  //JGR
		else
			dbSelectArea(aDelArq[nLoop,2])
			dbCloseArea()
		Endif
	Next

	RestArea(aAreaDel)
Return

Static Function ObtProv(cBuffer)
	Local cCadena := ""
	Local nloop := 0

	cBuffer := Alltrim(cBuffer)

	If !Empty(cBuffer)
		If subStr(cBuffer,len(cBuffer),1) != ";"
			cBuffer += ";"
		EndIf
		For nloop=1 to len(cBuffer)
			cCadena += "'" + allTrim(substr(cBuffer,1,at(";",cBuffer)-1)) + "'"
			cBuffer := substr(cBuffer,at(";",cBuffer)+1,len(cBuffer)-at(";",cBuffer))
			If  Len(cBuffer) == 0
				Exit
			Else
				cCadena += ','
			EndIf
		Next nloop
	EndIf
Return cCadena

Static Function ObtValBase(dFchIni, dFchFin, cProv, cOrdPag, cNroCertOr,cSuc)
	LocaL cQuery   := ""
	Local cTmp     := GetNextAlias()
	Local cValBase := 0
	Default cSuc   := ""
	cQuery += " SELECT Sum(FE_VALBASE) VALBASE
	cQuery += " FROM " + RetSqlName('SFE') + " SFE"
	cQuery += " WHERE  FE_TIPO = 'S'"
	cQuery += " AND FE_EMISSAO BETWEEN '" + DTOS(dFchIni) + "' AND '" + DTOS(dFchFin) +"'"
	cQuery += " AND FE_FORNECE = '" + cProv + "'"
	cQuery += " AND FE_ORDPAGO = '" + cOrdPag + "'"
	cQuery += " AND FE_FILIAL = '" + xFilial("SFE",cSuc) + "'"
	If Empty(cNroCertOr)
		cQuery += " AND FE_NRETORI = ''"
	Else
		cQuery += " AND FE_NRETORI <> ''"
	EndIf
	cQuery += " AND FE_NROCERT <> 'NORET'"

	cQuery:=ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.F.)
	cValBase := Transform(IIf((cTmp)->VALBASE > 0, (cTmp)->VALBASE, (cTmp)->VALBASE * (-1)), "@E 99999999999.99")
	(cTmp)->(dbCloseArea())

Return cValBase
