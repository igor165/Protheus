#INCLUDE "LOCXURU.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#Define SAliasHead  4
#Define ScOpFin     9

/*
±±ºPrograma  ³VLDRUC  ºAutor  ³Danilo             º Data ³ 16/09/2021  º±±
±±ºDesc.     ³Faz a validação na inclusão do cadastro do cliente ,       -º±±
±±º          ³para realizar a inclusão do mesmo codigo de cliente e RUC   º±±
±±º          ³para lojas diferentes                                       º±±
±±º³Parametros³Parametros : Codigo Cliente, Loja , RUC                    º±±
*/

Function VLDRUC(cCodCli, cLoja, cRUC)

Local cAliasTMP := "SA1TMP"
Local cQuery := ""
Local lRetRUC := .T.
Local cCliAux := ""
Local cMsg := ""

Default cCodCli := ""
Default cLoja := ""
Default cRUC := ""

DbSelectArea("SA1")
DbSetOrder(1)
cQuery := "SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_CGC FROM " + RetSQLname("SA1")
cQuery += " WHERE " 
cquery += " A1_CGC = '" + cRUC + "' AND "	
cQuery += "D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .F., .T.)
(cAliasTMP)->(DbGoTop())

While (cAliasTMP)->(!EOF())
	If (cAliasTMP)->A1_COD == cCodCli .And. (cAliasTMP)->A1_LOJA <> cLoja	
		lRetRUC := .T.
	Else 
		lRetRUC := .F.
	Endif
	cCliAux := (cAliasTMP)->A1_COD
	dbSkip()
EndDo	
(cAliasTMP)->(dbCloseAre())	

If !lRetRUC
	cMsg += STR0001 + CHR(10) + CHR(13) // "Já existe um registro gravado com essa informação""
	cMsg += STR0002 +  cCliAux + CHR(10) + CHR(13) // "Cliente XXXXX."
	cMsg += STR0003 + CHR(10) + CHR(13)
	Alert(cMsg)
Endif

return lRetRUC

/*/{Protheus.doc} NfTudOkUru
	Validaciones generales en la inclusión de documentos.
	La función es llamada en NfTudOk (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 29/09/2022
	@version version
	@param 	aCfgNf: Array con la configuración del documento.
			aDupli: Array con valores financieros.
			nBaseDup: Valor del título financiero de la nota fiscal.
			nMoedaNF: Moneda del documento.
			nMoedaCor: Moneda a convertir el valor.
			nTaxa: Valor de la tasa de cambio.
			l103Class: Indica si existe integración.
			cFunName: Nombre de la función.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function NfTudOkUru(aCfgNf, aDupli, nBaseDup, nMoedaNF, nMoedaCor, nTaxa, l103Class, cFunName)
Local lRet := .T.
Local nI   := 0
Local nTotDup   := 0

Default aCfgNf    := {}
Default aDupli    := {}
Default nBaseDup  := 0
Default nMoedaNF  := 1
Default nMoedaCor := 1
Default nTaxa     := 0
Default l103Class := .F.
Default cFunName  := Funname()

	// Valida que exista informacion de los titulos cuando la condicion de pago es informada
	If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupl) > 0 .AND. nBaseDup > 0 .AND. Val(Alltrim(Extrae(aDupl[1],5)))==0
		Aviso(STR0004,STR0005,{STR0006}) //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
		lRet	:= .F.
	EndIf
	//Controla se o valor total das duplicatas bate com o total
	If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .and. Val(Substr(aDupli[1],rat("³",aDupli[1])+1,len(aDupli[1])))>0  // O sistema gera uma estrutura vazia para duplicata.
		For nI := 1 To Len(aDupli)
			nTotDup += DesTrans(Extrae(aDupli[nI],5,))
		Next nI
		If lRet
			//Ajuste para permitir el valor financiero con impuestos provisionales del MATA462N y MATA462AN
			If Abs(xMoeda(nBaseDup,nMoedaNF,nMoedaCor,dDataBase,,nTaxa) - nTotDup) > SuperGetMV("MV_LIMPAG")
				Aviso(STR0004,STR0005,{STR0006})				 //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
				lRet	:= .F.
			EndIf
		EndIf
	Endif
Return lRet

/*/{Protheus.doc} LxDelNfUru
	Validaciones generales en el borrado/anulación del documento fiscal.
	La función es llamada en LocxDelNF (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 28/09/2022
	@param 	cAlias: Alias de tabla (SF1/SF2).
			lDeleta: .T. para borrar documento fiscal.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function LxDelNfUru(cAlias, lDeleta)
Local aDadSfe := {}
Local lRet    := .T.

	If lDeleta
		aDadSFE:={}
		If cAlias == "SF1" .And. !Alltrim(SF1->F1_ESPECIE)$"NDE/NCC"
			aAdd(aDadSFE,{"",0,"",0,0,0,SF1->F1_DOC,SF1->F1_SERIE,"E",SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_ESPECIE,"",SF1->F1_NATUREZ})
		ElseIf cAlias == "SF2" .And. Alltrim(SF2->F2_ESPECIE)$"NDI/NCP/NF"
			aAdd(aDadSFE,{"",0,"",0,0,0,SF2->F2_DOC,SF2->F2_SERIE,"S",SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_ESPECIE,"",SF2->F2_NATUREZ})
		Endif
		lRet := FGrvSFE("5",aDadSfe)
	Endif

Return lRet

/*/{Protheus.doc} LxGrvNfUru
	La función es llamada en GravaNFGURU (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 28/09/2022
	@param aCfgNF: Array de configuración de nota fiscal.
			lInclui: .T. cuando se realiza la inclusión de un documento.
	@return Nil
	/*/
Function LxGrvNfUru(aCfgNF, lInclui)
Local cGrpTrib   :=""
Local nContImp 	 :=0
Local nExistImp	 :=0
Local nDadSfe    :=0
Local aNroImp    :={}
Local aDadSfe    :={}
Local cFilSB1	 := xFilial("SB1")
Local cFilSB5	 := xFilial("SB5")
Local cFilSFC	 := xFilial("SFC")
Local cFilSFF	 := xFilial("SFF")
Local cMvAgente  := ""
Local cImpRet    := ""

Default aCfgNF   := {}
Default lInclui  := .F.

	If lInclui .And. !Empty(aCfgNF)
		//Define se ira reter ou nao a retencao por meio do parametro sendo que cada posicao seria um imposto
		cMvAgente:=Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
		cImpRet:=""

		For nContImp:=1 To len(cMVAgente)
			If Substr(cMvAgente,nContImp,1)=="S"
				If nContImp==1
					cImpRet+="IRP|"//Impuesto sobre la renta de las personas fisicas
				ElseIf nContImp==2
					cImpRet+="IRN|IR2|"//Impuesto sobre la renta de los no residentes
				ElseIf nContImp==3
					cImpRet+="ON|"//Obligaciones negociables
				ElseIf nContImp==4
					cImpRet+="RI2|"//IVA Retencion
				ElseIf nContImp==5
					cImpRet+="PFI|"//IVA-Percepcion
				ElseIf nContImp==6
					cImpRet+="IRA|"//IRA-Retencion
				ElseIf nContImp==7
					cImpRet+="IV8|"//IV8-Antecipo Iva Importacao
				ElseIf nContImp==8
					cImpRet+="IMS|"//IMS-Imposto Especifico Interno
				ElseIf nContImp==9
					cImpRet+="PFR|"//PFR-Percepcao Fija de IRA
				Endif
			Endif
		Next

		DbSelectArea("SFB")
		SFB->(DbSetOrder(1))
		SFB->(DbGoTop())
		Do While SFB->(!Eof())
			If Alltrim(SFB->FB_CODIGO)$cImpRet
				nExistImp:=aScan(aNroImp,{|x| Alltrim(x[1])+Alltrim(x[2])==Alltrim(SFB->FB_CODIGO)+Alltrim(SFB->FB_CPOLVRO)})
				If nExistImp==0
					aAdd(aNroImp,{SFB->FB_CODIGO,SFB->FB_CPOLVRO})
				Endif
			Endif
			SFB->(DbSkip())
		End

		If aCfgNF[SAliasHead] == "SF1" .And. !Alltrim(SF1->F1_ESPECIE)$"NDE/NCC/RCN"
			DbSelectArea("SD1")
			SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			SD1->(DbGoTop())
			If DbSeek(xFilial("SD1")+AvKey(SF1->F1_DOC,"D1_DOC")+AvKey(SF1->F1_SERIE,"D1_SERIE")+AvKey(SF1->F1_FORNECE,"D1_FORNECE")+AvKey(SF1->F1_LOJA,"D1_LOJA"))
				Do While SD1->(!Eof()) .And. Alltrim(SD1->D1_DOC)==Alltrim(SF1->F1_DOC) .And. Alltrim(SD1->D1_SERIE)==Alltrim(SF1->F1_SERIE) ;
				.And. Alltrim(SD1->D1_FORNECE)==Alltrim(SF1->F1_FORNECE) .And. Alltrim(SD1->D1_LOJA)==Alltrim(SF1->F1_LOJA)
					For nContImp:=1 To Len(aNroImp)
						cGrpTrib:=""
						If aNroImp[nContImp][1]=="IRP"
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If MsSeek(cFilSB1 + AvKey(SD1->D1_COD,"B1_COD") )
								cGrpTrib:=SB1->B1_GRPIRPF
							Endif
						ElseIf aNroImp[nContImp][1]=="IRA"
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If MsSeek(cFilSB1 + AvKey(SD1->D1_COD,"B1_COD") )
								cGrpTrib:=SB1->B1_GRPIRAE
							Endif
						ElseIf aNroImp[nContImp][1]=="IMS"
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If MsSeek(cFilSB1 + AvKey(SD1->D1_COD,"B1_COD") )
								cGrpTrib:=SB1->B1_GRPIMS
							Endif
						ElseIf aNroImp[nContImp][1]=="RI2"
							dbSelectArea("SFF")
							SFF->(dbSetOrder(5))
							SFF->(dbGoTop())
							If SFF->(MsSeek(cFilSFF+"RI2"+SD1->D1_CF))
								cGrpTrib := SFF->FF_GRUPO
							EndIf
							DbSelectArea("SB5")
							SB5->(DbSetOrder(1))
							SB5->(DbGoTop())
							If MsSeek(cFilSB5 + AvKey(SD1->D1_COD,"B1_COD") )
								cGrpTrib:=SB5->B5_GRPIVA
							Endif
						Endif
						DbSelectArea("SFC")
						SFC->(DbSetOrder(2))
						SFC->(DbGoTop())
						If MsSeek(cFilSFC+AvKey(SD1->D1_TES,"FC_TES")+AvKey(Alltrim(aNroImp[nContImp][1]),"FC_IMPOSTO"))
							nDadSfe:=aScan(aDadSFE,{|x| Alltrim(x[1])+Alltrim(x[2])+Alltrim(x[3]) == Alltrim(aNroImp[nContImp][1])+Alltrim(&("SD1->D1_ALQIMP"+aNroImp[nContImp][2]))+Alltrim(cGrpTrib)})
							If nDadSfe==0
								aAdd(aDadSFE;
								,{aNroImp[nContImp][1];
								,&("SD1->D1_ALQIMP"+aNroImp[nContImp][2]);
								,cGrpTrib;
								,xMoeda(&("SD1->D1_BASIMP"+aNroImp[nContImp][2]),SF1->F1_MOEDA,1,,,SF1->F1_TXMOEDA);
								,xMoeda(&("SD1->D1_VALIMP"+aNroImp[nContImp][2]),SF1->F1_MOEDA,1,,,SF1->F1_TXMOEDA);
								,xMoeda(&("SD1->D1_VALIMP"+aNroImp[nContImp][2]),SF1->F1_MOEDA,1,,,SF1->F1_TXMOEDA);
								,SD1->D1_DOC;
								,SD1->D1_SERIE;
								,"E";
								,SD1->D1_FORNECE;
								,SD1->D1_LOJA;
								,SD1->D1_ESPECIE;
								,SD1->D1_TES;
								,SF1->F1_NATUREZ;
								,SD1->D1_CF;
								,SF1->F1_EMISSAO;
								})
							Else
								aDadSfe[nDadSfe][4]+=xMoeda(&("SD1->D1_BASIMP"+aNroImp[nContImp][2]),SF1->F1_MOEDA,1,,,SF1->F1_TXMOEDA)
								aDadSfe[nDadSfe][5]+=xMoeda(&("SD1->D1_VALIMP"+aNroImp[nContImp][2]),SF1->F1_MOEDA,1,,,SF1->F1_TXMOEDA)
							Endif
						Endif
					Next
					SD1->(DbSkip())
				End
			Endif
		ElseIf aCfgNF[SAliasHead] == "SF2" .And. Alltrim(SF2->F2_ESPECIE)$"NDI/NCP/NF"
			DbSelectArea("SD2")
			SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
			SD2->(DbGoTop())
			If DbSeek(xFilial("SD2")+AvKey(SF2->F2_DOC,"D2_DOC")+AvKey(SF2->F2_SERIE,"D2_SERIE")+AvKey(SF2->F2_CLIENTE,"D2_CLIENTE")+AvKey(SF2->F2_LOJA,"D2_LOJA"))
				Do While SD2->(!Eof()) .And. Alltrim(SD2->D2_DOC)==Alltrim(SF2->F2_DOC) .And. Alltrim(SD2->D2_SERIE)==Alltrim(SF2->F2_SERIE) ;
				.And. Alltrim(SD2->D2_CLIENTE)==Alltrim(SF2->F2_CLIENTE) .And. Alltrim(SD2->D2_LOJA)==Alltrim(SF2->F2_LOJA)
					cGrpTrib:=""
					For nContImp:=1 To Len(aNroImp)
						cGrpTrib:=""
						If aNroImp[nContImp][1]=="IRP"
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If MsSeek(cFilSB1 + AvKey(SD2->D2_COD,"B1_COD") )
								cGrpTrib:=SB1->B1_GRPIRPF
							Endif
						ElseIf aNroImp[nContImp][1]=="IRA"
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If MsSeek(cFilSB1 + AvKey(SD2->D2_COD,"B1_COD") )
								cGrpTrib:=SB1->B1_GRPIRAE
							Endif
						ElseIf aNroImp[nContImp][1]=="IMS"
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If MsSeek(cFilSB1 + AvKey(SD2->D2_COD,"B1_COD") )
								cGrpTrib:=SB1->B1_GRPIMS
							Endif
						ElseIf aNroImp[nContImp][1]=="RI2"
							dbSelectArea("SFF")
							SFF->(dbSetOrder(5))
							SFF->(dbGoTop())
							If SFF->(MsSeek(cFilSFF+"RI2"+SD2->D2_CF))
								cGrpTrib := SFF->FF_GRUPO
							EndIf
							DbSelectArea("SB5")
							SB5->(DbSetOrder(1))
							SB5->(DbGoTop())
							If MsSeek(cFilSB5 + AvKey(SD2->D2_COD,"B1_COD") )
								cGrpTrib:=SB5->B5_GRPIVA
							Endif
                        Endif
						DbSelectArea("SFC")
						SFC->(DbSetOrder(2))
						SFC->(DbGoTop())
						If MsSeek(cFilSFC+AvKey(SD2->D2_TES,"FC_TES")+AvKey(Alltrim(aNroImp[nContImp][1]),"FC_IMPOSTO"))
							nDadSfe:=aScan(aDadSFE,{|x| Alltrim(x[1])+Alltrim(x[2])+Alltrim(x[3]) == Alltrim(aNroImp[nContImp][1])+Alltrim(&("SD2->D2_ALQIMP"+aNroImp[nContImp][2]))+Alltrim(cGrpTrib)})
							If nDadSfe==0
								aAdd(aDadSFE;
								,{aNroImp[nContImp][1];
								,&("SD2->D2_ALQIMP"+aNroImp[nContImp][2]);
								,cGrpTrib;
								,xMoeda((IIF(aNroImp[nContImp][1]$"IRP|IRA|RI2",&("SF2->F2_BASIMP"+aNroImp[nContImp][2]),&("SD2->D2_BASIMP"+aNroImp[nContImp][2]))),SF2->F2_MOEDA,1,,,SF2->F2_TXMOEDA);
								,xMoeda((IIF(aNroImp[nContImp][1]$"IRP|IRA|RI2",&("SF2->F2_VALIMP"+aNroImp[nContImp][2]),&("SD2->D2_VALIMP"+aNroImp[nContImp][2]))),SF2->F2_MOEDA,1,,,SF2->F2_TXMOEDA);
								,xMoeda((IIF(aNroImp[nContImp][1]$"IRP|IRA|RI2",&("SF2->F2_VALIMP"+aNroImp[nContImp][2]),&("SD2->D2_VALIMP"+aNroImp[nContImp][2]))),SF2->F2_MOEDA,1,,,SF2->F2_TXMOEDA);
								,SD2->D2_DOC;
								,SD2->D2_SERIE;
								,"S";
								,SD2->D2_CLIENTE;
								,SD2->D2_LOJA;
								,SD2->D2_ESPECIE;
								,SD2->D2_TES;
								,SF2->F2_NATUREZ;
								,SD2->D2_CF;
								})
							Else
								aDadSfe[nDadSfe][4]+=xMoeda(&("SD2->D2_BASIMP"+aNroImp[nContImp][2]),SF2->F2_MOEDA,1,,,SF2->F2_TXMOEDA)
								aDadSfe[nDadSfe][5]+=xMoeda(&("SD2->D2_VALIMP"+aNroImp[nContImp][2]),SF2->F2_MOEDA,1,,,SF2->F2_TXMOEDA)
							Endif
						Endif
					Next
					SD2->(DbSkip())
				End
			Endif
	    Endif
		FGrvSFE("3",aDadSfe)
	Endif

Return Nil


/*/{Protheus.doc} LxRetValIR
	Verifica los valor de retención y base de IR acumulados.
	La función es llamada en RetValIR (LOCXNF2.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 28/09/2022
	@param 	cImp: Código de Impuesto
			cTes: Código de TES
	@return aRet: Valores de retención
	/*/
Function LxRetValIR(cImp, cTes)
Local cQueryNF := ""
Local cQueryNC := ""
Local aArea    := GetArea()
Local aRetNF   := {0,0}
Local aRetNC   := {0,0}
Local aRet     := {0,0}

Default cImp := "IRP"
Default cTes := ""

	&("M->F2_CLIENTE") := Criavar("F2_CLIENTE")
	&("M->F2_LOJA")    := Criavar("F2_LOJA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona o acumulado de retenções do período para as notas NF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQueryNF := " SELECT SUM(FE_VALBASE) SUMBASE , SUM(FE_RETENC) SUMRETENC
	cQueryNF += " FROM "+RetSqlName("SFE")+" SFE "
	cQueryNF += " WHERE SFE.D_E_L_E_T_='' "
	cQueryNF += " AND SFE.FE_EMISSAO LIKE '%"+SubStr(Dtos(DDATABASE),1,6)+"__'"
	cQueryNF += " AND SFE.FE_TIPIMP LIKE '"+cImp+"'"
	cQueryNF += " AND SFE.FE_ESPECIE LIKE '%NF_'"
	cQueryNF += " AND SFE.FE_FILIAL = '" + xFilial('SFE') + "' "

	If	Type("M->F1_DOC")<>"U"
		cQueryNF += " AND SFE.FE_FORNECE = '"+M->F1_FORNECE+"' "
		cQueryNF += " AND SFE.FE_LOJA = '"+M->F1_LOJA+"' "
	Else
		cQueryNF += " AND SFE.FE_FORNECE = '"+M->F2_CLIENTE+"' "
		cQueryNF += " AND SFE.FE_LOJA = '"+M->F2_LOJA+"' "
	EndIF

	cQueryNF:=ChangeQuery(cQueryNF)
	TcQuery cQueryNF New Alias "VALBASERETNF"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona o acumulado de retenções do período para as notas NC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQueryNC := " SELECT SUM(FE_VALBASE) SUMBASE , SUM(FE_RETENC) SUMRETENC
	cQueryNC += " FROM "+RetSqlName("SFE")+" SFE "
	cQueryNC += " WHERE SFE.D_E_L_E_T_='' "
	cQueryNC += " AND SFE.FE_EMISSAO LIKE '%"+SubStr(Dtos(DDATABASE),1,6)+"__'"
	cQueryNC += " AND SFE.FE_TIPIMP LIKE '"+cImp+"'"
	cQueryNC += " AND SFE.FE_ESPECIE LIKE '%NC_'"

	If	Type("M->F1_DOC")<>"U"
		cQueryNC += " AND SFE.FE_FORNECE = '"+M->F1_FORNECE+"' "
		cQueryNC += " AND SFE.FE_LOJA = '"+M->F1_LOJA+"' "
	Else
		cQueryNC += " AND SFE.FE_FORNECE = '"+M->F2_CLIENTE+"' "
		cQueryNC += " AND SFE.FE_LOJA = '"+M->F2_LOJA+"' "
	EndIF

	cQueryNC:=ChangeQuery(cQueryNC)
	TcQuery cQueryNC New Alias "VALBASERETNC"


	DbSelectArea("VALBASERETNF")
	If VALBASERETNF->(!Eof())
		aRetNF[1] := IIf(!Empty(VALBASERETNF->SUMBASE),VALBASERETNF->SUMBASE,0)
		aRetNF[2] := IIf(!Empty(VALBASERETNF->SUMRETENC),VALBASERETNF->SUMRETENC,0)
		DbCloseArea()
	EndIf

	DbSelectArea("VALBASERETNC")
	If VALBASERETNC->(!Eof())
		aRetNC[1] := IIf(!Empty(VALBASERETNC->SUMBASE),VALBASERETNC->SUMBASE,0)
		aRetNC[2] := IIf(!Empty(VALBASERETNC->SUMRETENC),VALBASERETNC->SUMRETENC,0)
		DbCloseArea()
	EndIf

	aRet[1] := aRetNF[1]-aRetNC[1] //base acumulada e atualizada da diferença
	aRet[2] := aRetNF[2]-aRetNC[2] //valor de retencao acumulado e atualizado da diferença

	RestArea(aArea)

Return aRet
