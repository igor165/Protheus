#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n³ GERAVENRIVA ³ Autor ³Felipe C. Seolin       ³ Data ³29/07/2010³±±
±±ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri.³ Gera Arquivo de Retenção/Exportação                           ³±±
±±ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    ³ VENRIVA.INI                                                   ³±±
±±ÃÄÄÄÄÄÄÄÅÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³LuisEnríquez³11/01/17³SERINN001-928³-Se merge para agregar cambio en   ³±±
±±³            ³        ³             ³ creación de tablas temporales co- ³±±
±±³            ³        ³             ³ mo CTREE.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GERAVENRIVA()
	Local alStruRet	:= {}
	Local alStruExp	:= {}
	Local alArqTrab	:= {}
	Local alImp		:= {}
	Local clArqTraR	:= ""
	Local clArqTraE	:= ""
	Local clQuery	:= ""
	Local clImp		:= ""
	Local nlI		:= 0
	Local lAchouIV	:=.F.
	Local aOrdem := {}
	Private oTmpTable := Nil
	
	Aadd(alStruRet,{"CONTRIB" ,"C",10,0},.T.      ) 
	Aadd(alStruRet,{"PERIMP"  ,"C",06,0},.T.,'dbf') 
	Aadd(alStruRet,{"EMISSAO" ,"C",10,0},.T.,'dbf') 
	Aadd(alStruRet,{"OPERACAO","C",01,0},.T.,'dbf') 
	Aadd(alStruRet,{"TIPDOC"  ,"C",02,0},.T.,'dbf') 
	Aadd(alStruRet,{"CLIFOR"  ,"C",10,0},.T.,'dbf') 
	Aadd(alStruRet,{"NUMDOC"  ,"C",09,0},.T.,'dbf') 
	Aadd(alStruRet,{"CTRDOC"  ,"C",09,0},.T.,'dbf') 
	Aadd(alStruRet,{"VLRDOC"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruRet,{"BASIMP"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruRet,{"VLRIVA"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruRet,{"NDOCAF"  ,"C",09,0},.T.,'dbf') 
	Aadd(alStruRet,{"NUMCPV"  ,"C",14,0},.T.,'dbf') 
	Aadd(alStruRet,{"VLRISE"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruRet,{"ALIQ"    ,"C",06,0},.T.,'dbf') 
	Aadd(alStruRet,{"NUMEXP"  ,"C",15,0},.T.,'dbf') 

	oTmpTable := FWTemporaryTable():New('RETINI') 
	oTmpTable:SetFields( alStruRet ) 
	aOrdem	:=	{"CONTRIB"} 
	oTmpTable:AddIndex("IN1", aOrdem) 
	oTmpTable:Create() 

	aAdd(alArqTrab,{clArqTraR,'RETINI'})
 	Aadd(alStruExp,{"CONTRIB" ,"C",10,0},.T.      ) 
	Aadd(alStruExp,{"PERIMP"  ,"C",06,0},.T.,'dbf') 
	Aadd(alStruExp,{"EMISSAO" ,"C",10,0},.T.,'dbf') 
	Aadd(alStruExp,{"OPERACAO","C",01,0},.T.,'dbf') 
	Aadd(alStruExp,{"TIPDOC"  ,"C",02,0},.T.,'dbf') 
	Aadd(alStruExp,{"CLIFOR"  ,"C",10,0},.T.,'dbf') 
	Aadd(alStruExp,{"NUMDOC"  ,"C",09,0},.T.,'dbf') 
	Aadd(alStruExp,{"CTRDOC"  ,"C",09,0},.T.,'dbf') 
	Aadd(alStruExp,{"VLRDOC"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruExp,{"BASIMP"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruExp,{"VLRIVA"  ,"C",15,0},.T.,'dbf') 
	Aadd(alStruExp,{"NDOCAF"  ,"C",09,0},.T.,'dbf') 

	oTmpTable := FWTemporaryTable():New('EXPINI') 
	oTmpTable:SetFields( alStruExp ) 
	aOrdem	:=	{"CONTRIB"} 
	oTmpTable:AddIndex("IN1", aOrdem) 
	oTmpTable:Create() 
	
	aAdd(alArqTrab,{clArqTraE,'EXPINI'})

	clQuery := "SELECT DISTINCT	SF3.* "
	clQuery += "				,A1_EST ESTCLI "
	clQuery += "				,A1_CGC RGCLI "
	clQuery += "				,A2_EST ESTFOR "
	clQuery += "				,A2_CGC RGFOR "
	clQuery += "FROM	" + RetSqlName("SF3") + " SF3 "

	clQuery += "LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	clQuery += "ON	A1_COD = F3_CLIEFOR "
	clQuery += "AND	A1_LOJA = F3_LOJA "	
	clQuery += "AND	A1_FILIAL = '" + xFilial("SA1") + "' "
	clQuery += "AND	SA1.D_E_L_E_T_ = '' "

	clQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	clQuery += "ON	A2_COD = F3_CLIEFOR "
	clQuery += "AND	A2_LOJA = F3_LOJA "
	clQuery += "AND	A2_FILIAL = '" + xFilial("SA2") + "' "
	clQuery += "AND	SA2.D_E_L_E_T_ = '' "

	clQuery += "INNER JOIN " + RetSqlName("SFC") + " SFC "
	clQuery += "ON	FC_TES = F3_TES "
	clQuery += "AND	FC_FILIAL = '" + xFilial("SFC") + "' "
	clQuery += "AND	SFC.D_E_L_E_T_ = '' "

	clQuery += "WHERE	F3_FILIAL = '" + xFilial("SF3") + "' "
	clQuery += "AND		SF3.D_E_L_E_T_ = '' "
	clQuery += "AND		F3_ENTRADA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	If _aTotal[07][01][01] == "E"
		clQuery += "AND		F3_TIPOMOV = 'C' "
		clQuery += "AND		A2_EST <> 'EX' "
	EndIf

	clQuery += "ORDER BY F3_EMISSAO "

	TcQuery clQuery New Alias "RET"
	TcSetField("RET","F3_ENTRADA" ,"D",08,00)
	TcSetField("RET","F3_EMISSAO","D",08,00)

	If _aTotal[07][01][01] == "R"
		clAlias := "RETINI"
	Else
		clAlias := "EXPINI"
	EndIf

	RET->(DBGoTop())

	While RET->(!EOF())
		DBSelectArea(clAlias)
		alImp := TesImpInf(RET->F3_TES)
		lAchouIV:=.F.
		For nlI := 1 to Len(alImp)
			If SubStr(alImp[nlI][1],1,2) $ "RV|IV"
				clImp := alImp[nlI][1]
				clLivro := Posicione("SFB",1,xFilial("SFB") + clImp,"FB_CPOLVRO")
				If SubStr(alImp[nlI][1],1,2) $ "IV"
					If RecLock(clAlias,.T.)
						&("clAlias")->CONTRIB := SubStr(AllTrim(SM0->M0_CGC),1,10)
						&("clAlias")->PERIMP := SubStr(dtos(RET->F3_ENTRADA),1,6)
						&("clAlias")->EMISSAO := SubStr(dtos(RET->F3_EMISSAO),1,4) + "-" + SubStr(dtos(RET->F3_EMISSAO),5,2) + "-" + SubStr(dtos(RET->F3_EMISSAO),7,2)
						&("clAlias")->OPERACAO := RET->F3_TIPOMOV
						If AllTrim(RET->F3_ESPECIE) == "NF" .and. AllTrim(RET->ESTCLI) <> "EX" .and. AllTrim(RET->ESTFOR) <> "EX"
							&("clAlias")->TIPDOC := "01"
						ElseIf AllTrim(RET->F3_ESPECIE) $ "NDP/NDI/NDC/NDE" .and. AllTrim(RET->ESTCLI) <> "EX" .and. AllTrim(RET->ESTFOR) <> "EX"
							&("clAlias")->TIPDOC := "02"
						ElseIf AllTrim(RET->F3_ESPECIE) $ "NCP/NCI/NCC/NCE" .and. AllTrim(RET->ESTCLI) <> "EX" .and. AllTrim(RET->ESTFOR) <> "EX"
							&("clAlias")->TIPDOC := "03"
						ElseIf AllTrim(RET->ESTCLI) == "EX" .or. AllTrim(RET->ESTFOR) == "EX"
							&("clAlias")->TIPDOC := Iif(RET->F3_TIPOMOV == "C","05","06")
						EndIf
						DBSelectArea("SFE")
						If AllTrim(RET->F3_TIPOMOV) == "V"
							SFE->(DBSetOrder(8))
						ElseIf AllTrim(RET->F3_TIPOMOV) == "C"
							SFE->(DBSetOrder(4))
						EndIf
						If AllTrim(RET->F3_TIPOMOV) == "V"
							&("clAlias")->CLIFOR := SubStr(AllTrim(RET->RGCLI),1,10)
						ElseIf AllTrim(RET->F3_TIPOMOV) == "C"
							&("clAlias")->CLIFOR := SubStr(AllTrim(RET->RGFOR),1,10)
						EndIf
						&("clAlias")->NUMDOC := RET->F3_NFISCAL
						cCTRDOC:=""
						If AllTrim(RET->F3_ESPECIE) $ "NDI/NCI/NDC/NCC" .or. (AllTrim(RET->F3_ESPECIE) $ "NF" .and. AllTrim(RET->F3_TIPOMOV) == "V")
						    cCTRDOC:=GetSFP(RET->F3_FILIAL,RET->F3_SERIE,RET->F3_NFISCAL,RET->F3_ESPECIE)
						ElseIf AllTrim(RET->F3_ESPECIE) $ "NDP/NDE" .or. (AllTrim(RET->F3_ESPECIE) $ "NF" .and. AllTrim(RET->F3_TIPOMOV) == "C")
							cCTRDOC:=Posicione("SF1",1,xFilial("SF1") + RET->F3_NFISCAL + RET->F3_SERIE + RET->F3_CLIEFOR + RET->F3_LOJA,"F1_NUMAUT")
						ElseIf AllTrim(RET->F3_ESPECIE) $ "NCP/NCE"
							cCTRDOC:=Posicione("SF2",1,xFilial("SF2") + RET->F3_NFISCAL + RET->F3_SERIE + RET->F3_CLIEFOR + RET->F3_LOJA,"F2_NUMAUT")
						EndIf
						&("clAlias")->CTRDOC := Iif(!Empty(cCTRDOC),cCTRDOC,"0")
						&("clAlias")->VLRDOC := Transform(RET->F3_VALCONT,"@R 999999999999.99")
						&("clAlias")->BASIMP := Transform(&("RET->F3_BASIMP" + clLivro),"@R 999999999999.99")
				  
						If AllTrim(RET->F3_ESPECIE) $ "NDE|NCC|NDP|NCI"
							&("clAlias")->NDOCAF := Posicione("SD1",1,xFilial("SD1") + RET->F3_NFISCAL + RET->F3_SERIE + RET->F3_CLIEFOR + RET->F3_LOJA,"D1_NFORI")
						ElseIf AllTrim(RET->F3_ESPECIE) $ "NDC|NCE|NDI|NCP"
							&("clAlias")->NDOCAF := Posicione("SD2",3,xFilial("SD2") + RET->F3_NFISCAL + RET->F3_SERIE + RET->F3_CLIEFOR + RET->F3_LOJA,"D2_NFORI")
						Else
							&("clAlias")->NDOCAF := "0"
						EndIf					
						If clAlias == "RETINI"
							If AllTrim(RET->F3_TIPOMOV) == "V"      
							     cNumCert:=Posicione("SFE",8,xFilial("SFE") + RET->F3_CLIEFOR + RET->F3_LOJA + RET->F3_NFISCAL + RET->F3_SERIE,"FE_NROCERT")
								&("clAlias")->NUMCPV :=Iif(!Empty(cNumCert),cNumCert,"0")
							ElseIf AllTrim(RET->F3_TIPOMOV) == "C"
								cNumCert:= Posicione("SFE",4,xFilial("SFE") + RET->F3_CLIEFOR + RET->F3_LOJA + RET->F3_NFISCAL + RET->F3_SERIE,"FE_NROCERT")
								&("clAlias")->NUMCPV := Iif(!Empty(cNumCert),cNumCert,"0")
							EndIf
							If AllTrim(RET->F3_ESPECIE) $ "NDP/NCI/NCE/NDC/NF"
								If &("RET->F3_BASIMP" + clLivro) > 0 .and. &("RET->F3_ALQIMP" + clLivro) == 0
									&("clAlias")->VLRISE := Transform(&("RET->F3_BASIMP" + clLivro),"@R 999999999999.99")
								Else
									&("clAlias")->VLRISE := Transform(RET->F3_EXENTAS,"@R 999999999999.99")
								EndIf
							Else
								If &("RET->F3_BASIMP" + clLivro) > 0 .and. &("RET->F3_ALQIMP" + clLivro) == 0
									&("clAlias")->VLRISE := Transform(&("RET->F3_BASIMP" + clLivro) ,"@R 999999999999.99")
								Else
									&("clAlias")->VLRISE := Transform(RET->F3_EXENTAS ,"@R 999999999999.99")
								EndIf
							EndIf
							&("clAlias")->ALIQ := Transform(&("RET->F3_ALQIMP" + clLivro), "@R 999.99")
							&("clAlias")->NUMEXP := "0"
						EndIf
					EndIf
					MsUnlock()   
					lAchouIV:=.T.
				ElseIf lAchouIV
					If RecLock(clAlias,.F.)
						&("clAlias")->VLRIVA := Transform(&("RET->F3_VALIMP" + clLivro),"@R 999999999999.99")
					EndIf	
				EndIf	
			EndIf
		Next nlI
		RET->(DBSkip())
	EndDo

	If MsgYesNo("Desea generar informe de conferencia?")
		U_TRelVenRiva(clAlias)
	EndIf

	RET->(DBCloseArea())
Return alArqTrab
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ TRelVenRiva Autor  ³Felipe C. Seolin      ³ Data ³30/07/10³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Realiza chamadas para gerar relatório de arquivo retenção   ±±
±±³          ³ e exportação                                                ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clArq : Alias do relatório a ser usado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GERAVENRIVA                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TRelVenRiva(clArq)
	Local olReport
	Local clAlias := clArq

	If TRepInUse()
		olReport := ReportDef(clAlias)
		olReport:PrintDialog()
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ ReportDef ³ Autor  ³ Felipe C. Seolin     ³ Data ³30/07/10³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Função auxiliar utilizada para definição do relatório       ±±
±±³          ³ TRelVenRiva                                                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ olReport : Definição do relatório                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clArq : Alias do relatório a ser usado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRelVenRiva                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(clArq)
	Local olReport
	Local olSection
	Local clAlias := clArq

	olReport := TReport():New("VENRIVA.txt","Datos para conferencia. Periodo:  "+SubStr(dtos(MV_PAR01),1,6)+ " Contribuyente: "+SubStr(AllTrim(SM0->M0_CGC),1,10);
	,,{|olReport|PrintReport(olReport,clAlias)},"Conferencia dos datos.   "+SubStr(dtos(MV_PAR01),1,6))
	olSection := TRSection():New(olReport,"Impuestos",{clAlias})

	If clAlias == 'RETINI'
		TRCell():New(olSection,"EMISSAO" ,,"Emision",,13,.F.)
		TRCell():New(olSection,"OPERACAO",,"Tipo",,01,.F.)
		TRCell():New(olSection,"TIPDOC"  ,,"Tp.Doc",,02,.F.)
		TRCell():New(olSection,"CLIFOR"  ,,"Cli/Prov",,14,.F.)
		TRCell():New(olSection,"NUMDOC"  ,,"Num Doc",,12,.F.)
		TRCell():New(olSection,"CTRDOC"  ,,"Ctr Doc",,14,.F.)
		TRCell():New(olSection,"VLRDOC"  ,,"Valor Doc.",,20,.F.)
		TRCell():New(olSection,"BASIMP"  ,,"Base Impuesto",,20,.F.)
		TRCell():New(olSection,"VLRIVA"  ,,"Valor Iva",,20,.F.)
		TRCell():New(olSection,"NDOCAF"  ,,"N.Doc.Af.",,12,.F.)
		TRCell():New(olSection,"NUMCPV"  ,,"Num Comp.",,14,.F.)
		TRCell():New(olSection,"VLRISE"  ,,"Valor ISE",,18,.F.)
		TRCell():New(olSection,"ALIQ"    ,,"Alic.",,08,.F.)
	Else
		TRCell():New(olSection,"EMISSAO" ,,"Emision",,13,.F.)
		TRCell():New(olSection,"OPERACAO",,"Operacion",,01,.F.)
		TRCell():New(olSection,"TIPDOC"  ,,"Tp.Doc",,02,.F.)
		TRCell():New(olSection,"CLIFOR"  ,,"Cli/Prov",,10,.F.)
		TRCell():New(olSection,"NUMDOC"  ,,"Num Doc",,12,.F.)
		TRCell():New(olSection,"CTRDOC"  ,,"Ctr Doc",,09,.F.)
		TRCell():New(olSection,"VLRDOC"  ,,"Valor Doc.",,20,.F.)
		TRCell():New(olSection,"BASIMP"  ,,"Base Impuesto",,20,.F.)
		TRCell():New(olSection,"VLRIVA"  ,,"Valor Iva",,20,.F.)
		TRCell():New(olSection,"NDOCAF"  ,,"N.Doc.Af.",,12,.F.)
	EndIf
Return olReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ PrintReport ³ Autor  ³ Felipe C. Seolin   ³ Data ³02/08/10³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Função auxiliar utilizada para impressão do relatório       ±±
±±³          ³ TRelVenRiva                                                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ olReport : Definição do relatório                          ³±±
±±³          ³ clArq : Alias do relatório a ser usado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRelVenRiva                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(olReport,clArq)
	Local olSection	:= olReport:Section(1)
	Local clAlias	:= clArq

	If clAlias == 'RETINI'
		olReport:Section(1):Cell("EMISSAO" ):SetBlock({||RETINI->EMISSAO })
		olReport:Section(1):Cell("OPERACAO"):SetBlock({||RETINI->OPERACAO})
		olReport:Section(1):Cell("TIPDOC"  ):SetBlock({||RETINI->TIPDOC  })
		olReport:Section(1):Cell("CLIFOR"  ):SetBlock({||RETINI->CLIFOR+" "  })
		olReport:Section(1):Cell("NUMDOC"  ):SetBlock({||RETINI->NUMDOC  })
		olReport:Section(1):Cell("CTRDOC"  ):SetBlock({||RETINI->CTRDOC  })
		olReport:Section(1):Cell("VLRDOC"  ):SetBlock({||RETINI->VLRDOC  })
		olReport:Section(1):Cell("BASIMP"  ):SetBlock({||RETINI->BASIMP  })
		olReport:Section(1):Cell("VLRIVA"  ):SetBlock({||RETINI->VLRIVA  })
		olReport:Section(1):Cell("NDOCAF"  ):SetBlock({||RETINI->NDOCAF  })
		olReport:Section(1):Cell("NUMCPV"  ):SetBlock({||RETINI->NUMCPV })
		olReport:Section(1):Cell("VLRISE"  ):SetBlock({||RETINI->VLRISE  })
		olReport:Section(1):Cell("ALIQ"    ):SetBlock({||RETINI->ALIQ    })
	Else
		olReport:Section(1):Cell("EMISSAO" ):SetBlock({|| EXPINI->EMISSAO })
		olReport:Section(1):Cell("OPERACAO"):SetBlock({|| EXPINI->OPERACAO})
		olReport:Section(1):Cell("TIPDOC"  ):SetBlock({|| EXPINI->TIPDOC  })
		olReport:Section(1):Cell("CLIFOR"  ):SetBlock({|| EXPINI->CLIFOR  })
		olReport:Section(1):Cell("NUMDOC"  ):SetBlock({|| EXPINI->NUMDOC  })
		olReport:Section(1):Cell("CTRDOC"  ):SetBlock({|| EXPINI->CTRDOC  })
		olReport:Section(1):Cell("VLRDOC"  ):SetBlock({|| EXPINI->VLRDOC  })
		olReport:Section(1):Cell("BASIMP"  ):SetBlock({|| EXPINI->BASIMP  })
		olReport:Section(1):Cell("VLRIVA"  ):SetBlock({|| EXPINI->VLRIVA  })
		olReport:Section(1):Cell("NDOCAF"  ):SetBlock({|| EXPINI->NDOCAF  })
	EndIf
	olSection:Print()
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  DELVENRIVA    ºAutor  ³ Felipe C. Seolin     ³ Data ³04/08/10 ³º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui  o arquivo temporário processado                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ alArqTrab : Arquivos temporários de trabalho                 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VENRIVA.INI                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DELVENRIVA(alArqTrab)
	Local nlArq	:= 0
	Local alArq	:= alArqTrab

	For nlArq := 1 to Len(alArq)
		DBSelectArea(alArq[nlArq,2])
		DBCloseArea()
	Next nlArq
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  GetSFP        ºAutor  ³ Felipe C. Seolin     ³ Data ³10/08/10 ³º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca valor de espécie da tabela SFP                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ clFilial : Filial do Sistema                                 ³±±
±±³          ³ clSerie : Série da Nota Fiscal                               ³±±
±±³          ³ clNFis : Número do documento                                 ³±±
±±³          ³ clEsp : Espécie da Nota Fiscal                               ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ clAut : Número da autorização na tabela SFP                  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VENRIVA.INI                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSFP(clFilial,clSerie,clNFis,clEsp)
	Local clQuery	:= ""
	Local clAut		:= ""
	Local nlEsp		:= 0
	Local alEspec := {{"1","NF"},{"2","NCC"},{"3","NDC"},{"4","NDI"},{"5","NCI"},{"6","RTS"}}

	nlEsp := alEspec[aScan(alEspec,{|x| x[2] == AllTrim(clEsp)})][1]

	clQuery := "SELECT FP_NUMAUT AUT "
	clQuery += "FROM " + RetSqlName("SFP") + " SFP "
	clQuery += "WHERE	FP_FILIAL = '" + xFilial("SFP") + "' "
	clQuery += "AND		SFP.D_E_L_E_T_ = '' "
	clQuery += "AND		FP_FILUSO = '" + clFilial + "' "
	clQuery += "AND		FP_SERIE = '" + clSerie + "' "
	clQuery += "AND		FP_ESPECIE = '" + nlEsp + "' "
	clQuery += "AND		'" + clNFis + "' BETWEEN FP_NUMINI AND FP_NUMFIM "

	TcQuery clQuery New Alias "TRBSFP"

	clAut := TRBSFP->AUT

	TRBSFP->(DBCloseArea())
Return(clAut)
