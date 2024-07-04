#INCLUDE "FISA802.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"                      
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"


Function FISA802()
Private aSize	:= MsAdvSize(.T.)
Private aRotina := MenuDef()
Private cpMarca	:= GetMark()
Private cTpBco:=Upper(Alltrim(TcGetDB()))          

Pergunte("FISA802",.F.)         
	dbSelectArea('F0O')
	F0O->(dbSetOrder(1))	
	mBrowse( 6,1,22,75,"F0O",,,,,,/*Fa040Legenda("SE1")*/)
Return


Function F103Gera()
	Local clPerg	:= "FISA802"
	Local clQryTl	:= ""
	Local cSerie	:= ""
	Local cCliFor	:= ""
	Local cLoja		:= ""
	Local cEspecie	:= ""
	Local cConcept	:= ""
	Local cChave    := ""
	Local cIndice   := ""
	Local cTes    	:= ""
	Local cEmissao	:= ""
	Local cDtDigit	:= ""
	Local cDesri	:=""
	Local alCertRet	:= {}
	Local cVar      := Nil
	Local oDlg      := Nil
	Local cTitulo   := STR0002
	Local oOk       := LoadBitmap( GetResources(), "LBOK" )
	Local oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local oChk      := Nil
	local aNfs := {}
	local x   := 0
	Local clQryNCC  := ""
	Local clQryNF   := ""
	Local i := 0
	Local j := 0
	Local clQryTes := ""
	Local Aliq0 := 0
	Local Aliq5 := 0
	Local Aliq10 := 0
	Local aTes := {}
	Local aNF := {}
	Local aNCC := {}
	Local aOrdPg := {}
	Local clQryRetem := ""
	Local clQryParc := ""
	Local clQryNota := ""
	lOCAL TESTE := ""
	Local AliqNF10 := 0
	Local AliqNCC10 := 0
	Local AliqNF0 := 0
	Local AliqNCC0 := 0
	Local AliqNF5 := 0
	Local AliqNCC5 := 0
	Local TotAliq0 := 0
	Local TotAliq5 := 0
	Local TotAliq10 := 0
	Local OrdPagto := ""
	Local nLinha:=0
    
	Private dDtIni  := Ctod("//")
	Private dDtFim  := Ctod("//")
	Private cCodIni	:= ""
	Private cLojIni	:= ""
	Private cCodFim	:= ""
	Private cLojFim	:= ""
	Private cDocIni	:= ""
	Private cDocFim	:= ""
	Private cTipTxt   := ""
	Private lChk     := .F.
	Private oLbx := Nil


If Pergunte(clPerg,.T.)
	dDtIni  	:= MV_PAR01//Data Inicial
	dDtFim  	:= MV_PAR02//Data Final
	cCodIni	:= MV_PAR03//Cli/For Inicial|Fornecedor Inicial
	cLojIni	:= MV_PAR04//Loja Inicial
	cCodFim	:= MV_PAR05//Cli/For Final|Fornecedor Final
	cLojFim	:= MV_PAR06//Loja Final
	cDocIni	:= MV_PAR07//Ordem de Pagamento Inicial
	cDocFim	:= MV_PAR08//OP Final
	
	
	clQryTl    := ""
     
   //+--------------------------------------------+
   //| Seleciona as NFs que podem ser processadas |
   //+--------------------------------------------+
	If cTpBco =="ORACLE"	
		clQryTl := "SELECT DISTINCT ' ' as OK, FE_ORDPAGO, FE_EMISSAO  " 
	ElseIf cTpBco =="POSTGRES"	
		clQryTl := "SELECT DISTINCT ' ' as CHECK, FE_ORDPAGO, FE_EMISSAO  " 
	Else
		clQryTl := "SELECT DISTINCT '' as 'OK', FE_ORDPAGO, FE_EMISSAO  "
	EndIf
	clQryTl += "  FROM " + RetSqlName("SFE") + " SFE "
	clQryTl += " Where 1=1 AND SFE.FE_EMISSAO BETWEEN '" + dtos(dDtIni) + "' AND '" + dtos(dDtFim)+ "'"
	clQryTl += "   AND FE_FILIAL = '"       + xFilial("SFE") + "'"
	clQryTl += "   AND FE_FORNECE BETWEEN '"+cCodIni+"' AND '"+cCodFim+"'"
	clQryTl += "   AND FE_LOJA    BETWEEN '"+cLojIni+"' AND '"+cLojFim+"'"
	clQryTl += "   AND FE_ORDPAGO BETWEEN '"+cDocIni+"' AND '"+cDocFim+"'"
	clQryTl += "   AND SFE.FE_RETENC > 0  "
	clQryTl += "   AND SFE.D_E_L_E_T_ = ' '  "
	clQryTl += "   AND (SFE.FE_TIPO = 'I' OR SFE.FE_TIPO = 'E' OR SFE.FE_TIPO = 'R') "
	If cTpBco $ "ORACLE|POSTGRES"
		clQryTl += "   AND LENGTH(LTRIM(RTRIM(SFE.FE_ORDPAGO)))>0   "
	Else
		clQryTl += "   AND LEN(LTRIM(RTRIM(SFE.FE_ORDPAGO))) > 0 "
	EndIf
	If cTpBco $ "ORACLE|POSTGRES"
		clQryTl += "   AND SFE.FE_ORDPAGO || SFE.FE_SERIE || SFE.FE_NFISCAL || SFE.FE_FORNECE || SFE.FE_LOJA "
	Else
		clQryTl += "   AND SFE.FE_ORDPAGO +SFE.FE_SERIE+SFE.FE_NFISCAL +SFE.FE_FORNECE+SFE.FE_LOJA "      
	EndIf
	If cTpBco $ "ORACLE|POSTGRES"                                       
		clQryTl += "   NOT IN (SELECT F0O_ORDPAG || F0O_SERIER || F0O_NUMNF || F0O_FORNEC  ||  F0O_LOJA FROM " + RetSqlName("F0O") + " ) AND D_E_L_E_T_ <> '*' "
	Else
		clQryTl += "   NOT IN (SELECT F0O_ORDPAG+F0O_SERIER+F0O_NUMNF+F0O_FORNEC + F0O_LOJA FROM " + RetSqlName("F0O") + " WHERE D_E_L_E_T_ <> '*' )"
    EndIf
    //+----------------------------------------+
   //| Carrega o vetor com o retorno do array |
   //+----------------------------------------+
	aOrdPg := QryArray(clQryTl)
	for x:=1 to Len(aOrdPg)
		aOrdPg[x][1] := .F.
	Next

   //+-----------------------------------------------+
   //| Monta a tela para usuario visualizar consulta |
   //+-----------------------------------------------+
	If Len( aOrdPg ) == 0
		Aviso( cTitulo, STR0003, {"Ok"} )
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
		" ", STR0004, STR0005,STR0006,STR0007,;
		SIZE 230,095 OF oDlg PIXEL ON dblClick(aOrdPg[oLbx:nAt,1] := !aOrdPg[oLbx:nAt,1],oLbx:Refresh())
   
	oLbx:SetArray( aOrdPg )
	oLbx:bLine := {|| {Iif(aOrdPg[oLbx:nAt,1],oOk,oNo),;
		aOrdPg[oLbx:nAt,2],;
		aOrdPg[oLbx:nAt,3],;
		}}

	@ 110,10 CHECKBOX oChk VAR lChk PROMPT STR0008 SIZE 60,007 PIXEL OF oDlg ;
		ON CLICK(aEval(aOrdPg,{|x| x[1]:=lChk}),oLbx:Refresh())

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
   
   
   //+-------------------------------------+
   //| Verifica se foram encontradas NFs   |
   //+-------------------------------------+   
	If Len(aOrdPg) > 0
		for i := 1 to (Len(aOrdPg))
			If aOrdPg[i][1] == .T.                                   
				If cTpBco =="ORACLE"
					clQryNota := "SELECT DISTINCT '' as OK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				ElseIf cTpBco =="POSTGRES"
					clQryNota := "SELECT DISTINCT '' as CHECK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				Else
					clQryNota := "SELECT DISTINCT '' as 'OK', FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				EndIf
				clQryNota += "     FE_EMISSAO,SF1.F1_TIPO,FE_NROCERT, FE_ALIQ, D1_ITEM, D1_COD "
				clQryNota += "  FROM " + RetSqlName("SFE") + " SFE "
				clQryNota += "          INNER JOIN " + RetSqlName("SF1") + " SF1 ON (SFE.FE_FORNECE = SF1.F1_FORNECE "
				clQryNota += "               AND SFE.FE_LOJA = SF1.F1_LOJA "
				clQryNota += "            AND SFE.FE_SERIE= SF1.F1_SERIE  "
				clQryNota += "            AND SFE.FE_NFISCAL= SF1.F1_DOC  "
				clQryNota += "            and SFE.FE_FILIAL = SF1.F1_FILIAL)"				
				clQryNota += "          INNER JOIN " + RetSqlName("SD1") + " SD1 "
				clQryNota += "              ON (SD1.D1_FILIAL = SFE.fe_filial "
				clQryNota += "         AND SD1.D1_DOC = SFE.fe_nfiscal "
				clQryNota += "         AND SD1.D1_SERIE = SFE.fe_serie "
				clQryNota += "         AND SD1.D1_FORNECE = SFE.fe_fornece "
				clQryNota += "         AND SD1.D1_LOJA = SFE.fe_loja)		"		
				clQryNota += "  Where 1=1 AND FE_ORDPAGO = '" + AllTrim(aOrdPg[i][2]) +"'"
				clQryNota += " AND  SFE.D_E_L_E_T_ = ' ' AND SF1.D_E_L_E_T_ <> '*' "
				clQryNota += " GROUP BY fe_nfiscal, fe_serie, Fe_ordpago, fe_fornece, fe_loja, fe_tipo, fe_emissao, "
				clQryNota += "    SF1.F1_TIPO, FE_NROCERT, FE_ALIQ, D1_ITEM, D1_COD  "
				clQryNota := ChangeQuery(clQryNota)
				aNfs := QryArray(clQryNota)
               
                If cTpBco=="ORACLE"                                   
			   		clQryNota := "SELECT DISTINCT '' as OK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				ElseIf cTpBco == "POSTGRES"                                   
			   		clQryNota := "SELECT DISTINCT '' as CHECK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				Else
					clQryNota := "SELECT DISTINCT '' as 'OK', FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
			    EndIf
			    
				clQryNota += "    FE_EMISSAO, SD2.D2_NFORI, SD2.D2_SERIORI, SD2.D2_ITEMORI, SD2.D2_QUANT, SD2.D2_TES  "
				clQryNota += "  FROM " + RetSqlName("SFE") + " SFE "
				clQryNota += "          INNER JOIN " + RetSqlName("SF2") +  " SF2 ON (SFE.FE_FORNECE = SF2.F2_CLIENTE "
				clQryNota += "               AND SFE.FE_LOJA = SF2.F2_LOJA  "
				clQryNota += "            AND SFE.FE_SERIE= SF2.F2_SERIE    "
				clQryNota += "            AND SFE.FE_NFISCAL= SF2.F2_DOC    "
				clQryNota += "            AND SFE.FE_FILIAL = SF2.F2_FILIAL)"
				clQryNota += "           AND  SF2.F2_ESPECIE = 'NCP'        "
				clQryNota += "          INNER JOIN " + RetSqlName("SD2") +  " SD2 ON (SF2.F2_CLIENTE = SD2.D2_CLIENTE "
				clQryNota += "          AND SF2.F2_LOJA = SD2.D2_LOJA       "
				clQryNota += "          AND SF2.F2_SERIE = SD2.D2_SERIE     "
				clQryNota += "          AND SF2.F2_DOC = SD2.D2_DOC         "
				clQryNota += "          AND SF2.F2_FILIAL = SD2.D2_FILIAL)  "   
				
			 	If cTpBco $ "ORACLE|POSTGRES"
					clQryNota += "   AND LENGTH(RTRIM(LTRIM(SD2.D2_NFORI)))>0   "
				Else
					clQryNota += "  AND LEN(RTRIM(LTRIM(SD2.D2_NFORI))) > 0 "
				EndIf
				clQryNota += "  Where 1=1 AND FE_ORDPAGO = '" + AllTrim(aOrdPg[i][2]) +"'"
				clQryNota += " AND  SFE.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ <> '*' "
              //colocar a especie
       
				clQryNota := ChangeQuery(clQryNota)
				aNcps := QryArray(clQryNota)
      
       //+--------------------------------------+
       //| Processa somente as NFs selecionadas |
       //+--------------------------------------+

				TabPorc := GetNextAlias()
				If Len(aNfs) > 0
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1))
					For x:=1 to Len(aNfs)
			
						SD1->(MsSeek(xFilial("SD1")+(aNfs[x][2])+(aNfs[x][3])+(aNfs[x][5])+(aNfs[x][6])))
						While !(SD1->(Eof())) .AND. (SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+aNfs[x][2]+aNfs[x][3]+aNfs[x][5]+aNfs[x][6])
							cTes := SD1->D1_TES
							clQryTes := "SELECT SFB.FB_CPOLVRO FROM " + RetSqlName("SFC")+ " SFC INNER JOIN " + RetSqlName("SFB")+ " SFB "
							clQryTes += "    ON SFC.FC_IMPOSTO = SFB.FB_CODIGO    "
							clQryTes += " WHERE FC_TES = '" + cValToChar(cTes) + "'"
							clQryTes += "   AND SFC.D_E_L_E_T_ <> '*' AND SFB.D_E_L_E_T_ <> '*' "
							clQryTes := ChangeQuery(clQryTes)
							aTES := QryArray(clQryTes)

							cImpostos := ""
							for j := 1 to (Len(aTES))
								/*clQryNCC := "SELECT D2_ALQIMP" + (aTes[j][1]) + " ALIQ, (D2_VALIMP" + (aTes[j][1]) + " + D2_BASIMP" + (aTes[j][1]) + "), "
								clQryNCC += "((SUM(D2_VALIMP" + (aTes[j][1]) + ") * 100) / SUM(D2_TOTAL)) Total_Porc "
								clQryNCC += " FROM " + RetSqlName("SD2")
								clQryNCC += " where D2_DOC = '" + AllTrim(aNfs[x][2]) + "' AND D_E_L_E_T_ <> '*' AND D2_ESPECIE = 'NCP' "
								clQryNCC += " AND D2_CLIENTE = '" + AllTrim(aNfs[x][5]) + "'"
								clQryNCC += " AND D2_SERIE = '"   + AllTrim(aNfs[x][3]) + "'"
								clQryNCC += " AND D2_FILIAL = '"  + xFilial("SD2") + "'"
								clQryNCC += " AND D2_LOJA = '"    + AllTrim(aNfs[x][6]) + "'"
								clQryNCC += " AND D2_ALQIMP" + (aTes[j][1])  +" >0"
								clQryNCC += " GROUP BY D2_ALQIMP" + (aTes[j][1]) + ", D2_VALIMP" + (aTes[j][1]) + ", D2_BASIMP" + (aTes[j][1])
								clQryNCC := ChangeQuery(clQryNCC)
								aNCC     := QryArray(clQryNCC)
	                      */
								clQryNF := "SELECT D1_ALQIMP" + (aTes[j][1]) + " ALIQ, (D1_VALIMP" + (aTes[j][1]) + " + D1_BASIMP" + (aTes[j][1]) + "), "
								clQryNF += " ((SUM(D1_VALIMP" + (aTes[j][1]) + ") * 100) / SUM(D1_TOTAL)) Total_Porc "
								clQryNF += " FROM " + RetSqlName("SD1")
								clQryNF += " where D1_DOC = '" + AllTrim(aNfs[x][2]) + "' AND D_E_L_E_T_ <> '*'"
								clQryNF += " AND D1_FORNECE = '" + AllTrim(aNfs[x][5]) + "'"
								clQryNF += " AND D1_SERIE = '"   + AllTrim(aNfs[x][3]) + "'"
								clQryNF += " AND D1_FILIAL = '"  + xFilial("SD1") + "'"
								clQryNF += " AND D1_LOJA = '"    + AllTrim(aNfs[x][6]) + "'"
								clQryNF += " AND D1_ALQIMP" + (aTes[j][1])  +" >0"
								clQryNF += " GROUP BY D1_ALQIMP" + (aTes[j][1]) + ", D1_VALIMP" + (aTes[j][1]) + ", D1_BASIMP" + (aTes[j][1])
								clQryNF := ChangeQuery(clQryNF)
								aNF     := QryArray(clQryNF)
								If Len(aNF)>0
									If aNF[1][1] == 0
										AliqNF0 += aNF[1][2] 
										If cTpBco =="ORACLE" 
											cImpostos += ", D1_ALQIMP" + (aTes[j][1]) + "' ALQ_0, (D1_BASIMP" + (aTes[j][1]) + " + D1_VALIMP" + (aTes[j][1]) + ") BAS_0 "
										Else
											cImpostos += ", D1_ALQIMP" + (aTes[j][1]) + " 'ALQ_0', (D1_BASIMP" + (aTes[j][1]) + " + D1_VALIMP" + (aTes[j][1]) + ") 'BAS_0' "         
										EndIf
									ElseIf aNF[1][1] == 5
										AliqNF5 += aNF[1][2]
										If cTpBco $ "ORACLE|POSTGRES"
											cImpostos += ", D1_ALQIMP" + (aTes[j][1]) + " ALQ_5, (D1_BASIMP" + (aTes[j][1]) + " + D1_VALIMP" + (aTes[j][1]) + ") BAS_5 " 
										Else
											cImpostos += ", D1_ALQIMP" + (aTes[j][1]) + " 'ALQ_5', (D1_BASIMP" + (aTes[j][1]) + " + D1_VALIMP" + (aTes[j][1]) + ") 'BAS_5' "  
										EndIf	
									ElseIf aNF[1][1] == 10
										AliqNF10 += aNF[1][2]
										If cTpBco $ "ORACLE|POSTGRES"
											cImpostos += ", D1_ALQIMP" + (aTes[j][1]) + " ALQ_10, (D1_BASIMP" + (aTes[j][1]) + " + D1_VALIMP" + (aTes[j][1]) + ") BAS_10 "    
										Else
											cImpostos += ", D1_ALQIMP" + (aTes[j][1]) + " 'ALQ_10', (D1_BASIMP" + (aTes[j][1]) + " + D1_VALIMP" + (aTes[j][1]) + ") 'BAS_10' "
										EndIf
									EndIf
								EndIf
								/*
								If Len(aNCC) > 0
									If aNCC[1][1] == 0
										AliqNCC0 += aNCC[1][2]
									ElseIf aNCC[1][1] == 5
										AliqNCC5 += aNCC[1][2]
									ElseIf aNCC[1][1] == 10
										AliqNCC10 += aNCC[1][2]
									EndIf
								EndIf
	                 */
							Next
	           				 If cTpBco $ "ORACLE|POSTGRES"
								clQryPorc := "SELECT SD1.D1_QUANT,D1_ITEM,D1_TOTAL,D1_CUSORI,D1_VUNIT,SB1.B1_DESC,CONCAT(RTRIM(LTRIM(SD1.D1_COD)),RTRIM(LTRIM(SD1.D1_NUMSEQ))) PRODUTO " + (cImpostos)		 
							Else
								clQryPorc := "SELECT SD1.D1_QUANT,D1_ITEM, D1_TOTAL, D1_VUNIT, SB1.B1_DESC, (RTRIM(LTRIM(SD1.D1_COD))+RTRIM(LTRIM(SD1.D1_NUMSEQ))) PRODUTO,* " + (cImpostos)
							EndIf
							clQryPorc += " FROM " + RetSqlName("SD1") + " SD1 INNER JOIN " + RetSqlName("SB1") + " SB1 ON (SD1.D1_COD = SB1.B1_COD) "
							clQryPorc += " WHERE SD1.D1_DOC = '" + AllTrim(aNfs[x][2]) + "' AND SD1.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*'"
							clQryPorc += " AND SD1.D1_FORNECE = '" + AllTrim(aNfs[x][5]) + "'"
							clQryPorc += " AND SD1.D1_SERIE = '"   + AllTrim(aNfs[x][3]) + "'"
							clQryPorc += " AND SD1.D1_FILIAL = '"  + xFilial("SD1") + "'"
							clQryPorc += " AND SD1.D1_LOJA = '"    + AllTrim(aNfs[x][6]) + "'"
							clQryPorc += " AND SD1.D1_ITEM = '"    + AllTrim(SD1->D1_ITEM) + "'"
							clQryPorc := ChangeQuery(clQryPorc)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryPorc),TabPorc)
	        
	        	    
							DbSelectArea("F0O")
							F0O->(DbSetOrder(1))
							If !(F0O->(MsSeek(xFilial("F0O")+aNfs[x][4]+aNfs[x][3]+aNfs[x][2]+aNfs[x][5]+aNfs[x][6]+aNfs[x][10]+aNfs[x][7])))    //F0O_FILIAL+F0O_ORDPAG+F0O_SERIER+F0O_NUMNF+F0O_FORNEC+F0O_LOJA+F0O_CERTIF+F0O_TPIMPO	              
								nLinha:=0
								RecLock("F0O",.T.)
								F0O->F0O_FILIAL := xFilial("F0O")
								F0O->F0O_FORNEC := AllTrim(aNfs[x][5])
								F0O->F0O_LOJA   := AllTrim(aNfs[x][6])
								F0O->F0O_SERIER := AllTrim(aNfs[x][3])
								F0O->F0O_NUMNF  := AllTrim(aNfs[x][2])
								F0O->F0O_DTGERA := Date()
								F0O->F0O_HRGERA := Time()
								F0O->F0O_NFISCA := AllTrim(aNfs[x][2])
								F0O->F0O_SERIE  := AllTrim(aNfs[x][3])
								F0O->F0O_DTTRAN := nil
								F0O->F0O_HRTRAN := nil
								F0O->F0O_PROT   := nil
								F0O->F0O_SITNOT := nil
								F0O->F0O_SITU   := nil
								F0O->F0O_DTRESG := AllTrim(aNfs[x][8])
								F0O->F0O_MDDOC  := nil
								F0O->F0O_ORDPAG := AllTrim(aNfs[x][4])
								F0O->F0O_CERTIF := AllTrim(aNfs[x][10])
								F0O->F0O_TPIMPO := AllTrim(aNfs[x][7])	                      
								MsUnLock()
							EndIf
								
							nTotalIt:=0
							nTotalIt :=   nTotalIt + Iif(((TabPorc)->(FieldPos("BAS_0"))) > 0, ((TabPorc)->(BAS_0)), 0)
							nTotalIt :=   nTotalIt + Iif(((TabPorc)->(FieldPos("BAS_5"))) > 0, ((TabPorc)->(BAS_5)), 0)
							nTotalIt :=   nTotalIt + Iif(((TabPorc)->(FieldPos("BAS_10"))) > 0, ((TabPorc)->(BAS_10)), 0)
	             					
							If nTotalIt==0
								nTotalIt :=   (TabPorc)->D1_TOTAL
							EndIf	

							If nTotalIt==0    .AND.  (TabPorc)->D1_CUSORI >0
								nTotalIt :=   (TabPorc)->D1_CUSORI
							EndIf
	             
							DbSelectArea("F0P")
							F0P->(DbSetOrder(1))
							If !(F0P->(MsSeek(xFilial("F0P") + aNfs[x][4] +aNfs[x][3]+ aNfs[x][2] + aNfs[x][5] +aNfs[x][6] + (TabPorc)->D1_ITEM +aNfs[x][7] ) ))
								RecLock("F0P",.T.)
								nLinha:=  nLinha+1
								F0P->F0P_FILIAL  := xFilial("F0P")
								F0P->F0P_SERIER  := AllTrim(aNfs[x][3])
								F0P->F0P_NUMNF   := AllTrim(aNfs[x][2]) //Numero da Nota -- N√O TIRAR MEXE NO ÕNDICE.
								F0P->F0P_ESPECI  := "NF"
								F0P->F0P_SERIE   := AllTrim(aNfs[x][3])
								F0P->F0P_NUM     := ((TabPorc)->(Produto))
								F0P->F0P_FORNEC  := AllTrim(aNfs[x][5])
								F0P->F0P_LOJA    := AllTrim(aNfs[x][6])
								F0P->F0P_IMP     := AllTrim(aNfs[x][7])
								F0P->F0P_DTEMDC  := AllTrim(aNfs[x][8])
								F0P->F0P_CODDGI  := nil
								F0P->F0P_TXDOC   := nil
								F0P->F0P_DESCRI  := ((TabPorc)->(B1_DESC))
								F0P->F0P_QUANT   := 1  // ((TabPorc)->(D1_QUANT))
								F0P->F0P_VALUNI  := nTotalIt  // ((TabPorc)->(D1_VUNIT))     
								If(aNfs[x][7] $ "I" )    
								
									F0P->F0P_TAXA0   := Iif(((TabPorc)->(FieldPos("ALQ_0"))) > 0, ((TabPorc)->(ALQ_0)), 0)
									F0P->F0P_TAXA5   := Iif(((TabPorc)->(FieldPos("ALQ_5"))) > 0, ((TabPorc)->(ALQ_5)), 0)
									F0P->F0P_TAXA10  := Iif(((TabPorc)->(FieldPos("ALQ_10"))) > 0, ((TabPorc)->(ALQ_10)), 0)
									F0P->F0P_ALIQ0   := Iif(((TabPorc)->(FieldPos("ALQ_0"))) > 0, ((TabPorc)->(ALQ_0)), 0)
									F0P->F0P_ALIQ5   := Iif(((TabPorc)->(FieldPos("ALQ_5"))) > 0, ((TabPorc)->(ALQ_5)), 0)
									F0P->F0P_ALIQ10  := Iif(((TabPorc)->(FieldPos("ALQ_10"))) > 0, ((TabPorc)->(ALQ_10)), 0)
									F0P->F0P_BSIMP0  := Iif(((TabPorc)->(FieldPos("BAS_0"))) > 0, ((TabPorc)->(BAS_0)), 0)
									F0P->F0P_BSIMP5  := Iif(((TabPorc)->(FieldPos("BAS_5"))) > 0, ((TabPorc)->(BAS_5)), 0)
									F0P->F0P_BSIMP1 := Iif(((TabPorc)->(FieldPos("BAS_10"))) > 0, ((TabPorc)->(BAS_10)), 0)
								Else
									F0P->F0P_ALIQIR  := Iif(aNfs[x][7] $ "R", aNfs[x][11], 0)
								EndIf
								F0P->F0P_ORDPAG  := AllTrim(aNfs[x][4])
								F0P->F0P_LINHA   := (TabPorc)->D1_ITEM									 
								MsUnLock()
							Else
								RecLock("F0P",.f.) 
								If(aNfs[x][7] $ "I" )
								
									F0P->F0P_TAXA0   := Iif(((TabPorc)->(FieldPos("ALQ_0"))) > 0, ((TabPorc)->(ALQ_0)), 0)
									F0P->F0P_TAXA5   := Iif(((TabPorc)->(FieldPos("ALQ_5"))) > 0, ((TabPorc)->(ALQ_5)), 0)
									F0P->F0P_TAXA10  := Iif(((TabPorc)->(FieldPos("ALQ_10"))) > 0, ((TabPorc)->(ALQ_10)), 0)
									F0P->F0P_ALIQ0   := Iif(((TabPorc)->(FieldPos("ALQ_0"))) > 0, ((TabPorc)->(ALQ_0)), 0)
									F0P->F0P_ALIQ5   := Iif(((TabPorc)->(FieldPos("ALQ_5"))) > 0, ((TabPorc)->(ALQ_5)), 0)
									F0P->F0P_ALIQ10  := Iif(((TabPorc)->(FieldPos("ALQ_10"))) > 0, ((TabPorc)->(ALQ_10)), 0)
									F0P->F0P_BSIMP0  := Iif(((TabPorc)->(FieldPos("BAS_0"))) > 0, ((TabPorc)->(BAS_0)), 0)
									F0P->F0P_BSIMP5  := Iif(((TabPorc)->(FieldPos("BAS_5"))) > 0, ((TabPorc)->(BAS_5)), 0)
									F0P->F0P_BSIMP1 := Iif(((TabPorc)->(FieldPos("BAS_10"))) > 0, ((TabPorc)->(BAS_10)), 0)
								ElseIf(aNfs[x][7] $ "R" )
						   			F0P->F0P_ALIQIR  :=  aNfs[x][11]
								EndIf
								MsUnLock()
	                        EndIf
							If (Select(TabPorc) > 0)
								((TabPorc)->(dbCloseArea()))
							EndIf
	                 
							SD1->(DbSkip())
						EndDo
					Next
              
				EndIF //verifica se tem notas na retenÁ„o selecionada
       
       //Nota de credito
      
				If Len(aNcps) > 0
	         
					For x:=1 to Len(aNcps)

						DbSelectArea("F0P")
						F0P->(DbSetOrder(1))
						If (F0P->(MsSeek(xFilial("F0P")+aNcps[x][4]+aNcps[x][10]+aNcps[x][9]+aNcps[x][5]+aNcps[x][6]+aNcps[x][11]))) //F0P_FILIAL+F0P_ORDPAG+F0P_SERIER+F0P_NUMNF+F0P_FORNEC+F0P_LOJA+F0P_LINHA
							                    
							clQryTes := "SELECT SFB.FB_CPOLVRO FROM " + RetSqlName("SFC")+ " SFC INNER JOIN " + RetSqlName("SFB")+ " SFB "
							clQryTes += "    ON SFC.FC_IMPOSTO = SFB.FB_CODIGO    "
							clQryTes += " WHERE FC_TES = '" + cValToChar(cTes) + "'"
							clQryTes += "   AND SFC.D_E_L_E_T_ <> '*' AND SFB.D_E_L_E_T_ <> '*' "
							clQryTes := ChangeQuery(clQryTes)
							aTES := QryArray(clQryTes)
                            
						   DbSelectArea("SD2")
						   SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						   RecLock("F0P",.F.)	                            
							For j := 1 to (Len(aTES))
								If SD2->(FieldPos('D2_ALQIMP' + (aTes[j][1])) > 0) .And. &("SD2->D2_ALQIMP" + aTes[j][1]) == 0
									F0P->F0P_BSIMP0  := F0P->F0P_BSIMP0  - &("SD2->D2_BASIMP" + (aTes[j][1]))
								ElseIf SD2->(FieldPos("D2_ALQIMP" + (aTes[j][1])) > 0) .And. &("SD2->D2_ALQIMP" + aTes[j][1]) == 5
									F0P->F0P_BSIMP5  := F0P->F0P_BSIMP5  - &("SD2->D2_BASIMP" + (aTes[j][1]))
								ElseIf SD2->(FieldPos("D2_ALQIMP" + (aTes[j][1])) > 0) .And. &("SD2->D2_ALQIMP" + aTes[j][1]) == 10
									F0P->F0P_BSIMP1  := F0P->F0P_BSIMP1  - &("SD2->D2_BASIMP" + (aTes[j][1]))
								EndIf
							Next
                           
							If nTotalIt==0 .AND. (TabPorc)->D2_CUSORI >0
								nTotalIt :=   (TabPorc)->D2_CUSORI
							EndIf
	                
							//F0P->F0P_VALUNI  := F0P->F0P_VALUNI  -  nTotalIt  // ((TabPorc)->(D1_VUNIT))									
							MsUnLock()
	            
							If (Select(TabPorc) > 0)
								((TabPorc)->(dbCloseArea()))
							EndIf
						EndIf
						SD2->(DbSkip())
								
						//	EndDo
					Next

          
				EndIF //verifica se tem notas na retenÁ„o selecionada
			EndIf //sÛ processa notas que foram selecionadas
		Next //Enquanto n„o for fim da retenÁ„o
	EndIf  //Se tiver retenÁıes, faÁa...
	EndIf   //if do Pergunte
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna as opcoes disponiveis para utilizacao na mBrowse

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MenuDef()                     
Local aRet	:= {	{ STR0009  , "AxPesqui" 	, 0 , 1,,.F. } ,; 		// "Pesquisa"
					{ STR0010  , "F103VISUA" 	, 0 , 2},; 				// "Incluir"
				 	{ STR0011  , "F103Gera" 	, 0 , 3},; 				// "Incluir"				 	
				 	{ STR0012  , "Fi802Tra" 	, 0 , 6},;           // "Transmitir"
				 	{ STR0013  , "Fi802AcN" 	, 0 , 6},;           // "Transmitir"
				 	{ STR0014  , "FI802ANU" 	, 0 , 6}} 				       // "Anular" 							
Return aRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Fi802Tra  ∫Autor  ≥Fernando Bastos     ∫ Data ≥  08/01/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Faz a remessa dos resguados eletronicos                	  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Uruguai                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Fi802Tra(cAlias)   

Local aArea       := GetArea()
Local nX          := 0
Local i       := 0
Local aGerar  := {}
Local nHdl    := 0
Local nArq    := ""
Local cVirg   := .F.
Local Moeda   := ""
Local Aux     := ""
Local clPergR	:= "FISA8021"
Local nTipImp := 0
Local j := 0
Local lAutomato 	:= IsBlind()
Local lProc			:= .F.


Local cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
Local cReten    := " 'retencion': {'fecha': '<Dt_Fecha>', 'moneda': '<moeda>', 'tipoCambio': <TpCambio>, 'retencionRenta': <RetRenta>,  " +;
                   " 'conceptoRenta': '<CtRenta>', 'ivaPorcentaje5': <Iva5>, 'ivaPorcentaje10': <IVA10>, 'rentaCabezasBase': <BsRenta>, " +;
                   " 'rentaCabezasCantidad': <QtRenta>, 'rentaToneladasBase': <TnRenta>, 'rentaToneladasCantidad': <QtRentasT>,         " +;
                   " 'rentaPorcentaje': <PorcRenta>, 'retencionIva': <RetIva>, 'conceptoIva': '<CptoIva>' }, "
Local cInform   := " 'informado': { 'situacion': '<TpPessoa>', 'nombre': '<Nome>', 'ruc': '<Ruc>', 'dv': '<DV>', 'domicilio': '<Ender>'," +;
                   " 'tipoIdentificacion': '<TpIdent>', 'identificacion': '<Ident>', 'direccion': '<Direcao>', 'correoElectronico':     " +;
                   " '<Email>', 'pais': '<Pais>', 'telefono': '<Tel>' }, "     
Local cTransac  := " 'transaccion': { 'numeroComprobanteVenta': '<NumComp>', 'condicionCompra': '<TpCompra>', 'cuotas': <Quotas>,       " +;
                   " 'tipoComprobante': <TpComp>, 'fecha': '<DtFecha>', 'numeroTimbrado': '<NumTimbr>' }, "    
Local cAtrib    := " 'atributos': { 'fechaCreacion': '<FechaCr>', 'fechaHoraCreacion': '<HoraCr>' }} "                                      
Local cLin1:=""                   


If lAutomato
		lProc := .T.
Else
		lProc :=  Pergunte(clPergR,.T.)
EndIf

If lProc 

  cTipTxt	:="2" //MV_PAR01//Tipo do Relatorio
  cDirec:=Iif(Empty(MV_PAR01),"c:\",ALLTRIM(MV_PAR01))
  cNome:=Iif(Empty(MV_PAR02),"Tesaka.txt",Alltrim(MV_PAR02)+".txt")
  nHdl := fCreate(cDirec+cNome) 
  
  
  If nHdl <= 0
     ApMsgStop(STR0015)
  Else
  
   	
   	cRetencao  := GetNextAlias()
   	cRetenca   := GetNextAlias()   
	
   	clQryTes   := ""
   	clQryParce := ""
   	clQryRete  := ""
	clQryGera  := "" 


   //+--------------------------------------------+
   //| Seleciona as NFs que podem ser geradas     |
   //+--------------------------------------------+
	clQryGera := "SELECT F0O_ORDPAG, F0O_NUMNF, F0O_SERIER, F0O_FORNEC, "
	If cTpBco $ "ORACLE|POSTGRES" 
			clQryGera += " F0O_LOJA, F0O_DTRESG, F0O_TPIMPO                    "
	else
			clQryGera += " F0O_LOJA, F0O_DTRESG, F0O_TPIMPO,*                    "
	endif

	clQryGera += "  FROM " + RetSqlName("F0O") + " F0O            " 
	If cTpBco $ "ORACLE|POSTGRES"                                       
		clQryGera += " WHERE LENGTH(F0O.F0O_DTTRAN) = 0                  "
		clQryGera += " AND LENGTH(F0O.F0O_HRTRAN) = 0                    "
	Else
		clQryGera += " WHERE LEN(F0O.F0O_DTTRAN) = 0                  "
		clQryGera += " AND LEN(F0O.F0O_HRTRAN) = 0                    "
	EndIf
	
	If Len(Trim(MV_PAR03)) > 0
    clQryGera += " AND  F0O_ORDPAG     = '" +MV_PAR03 + "'" 
   Else
    clQryGera += " AND  F0O_ORDPAG     <> '' " 
   EndIf
	clQryGera += " AND F0O.D_E_L_E_T_ <> '*'                      "

	
   //+----------------------------------------+
   //| Carrega o vetor com o retorno do array |
   //+----------------------------------------+
   aGerar := QryArray(clQryGera)

   //+-----------------------------------------------+
   //| Monta a tela para usuario visualizar consulta |
   //+-----------------------------------------------+
   //If Len( aGerar ) > 0
	 If !lAutomato
     	MsgAlert(STR0016,STR0017)  
     ENDIF
	 for i := 1 to (Len(aGerar))

       clQryRete := " SELECT SF1.F1_MOEDA, CASE WHEN SF1.F1_MOEDA = 1 THEN 'true'             " 
       clQryRete += "                         ELSE 'false'                                    "
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                        END            AS MOEDA,                       "
	   Else
       		clQryRete += "                        END            AS 'MOEDA',                       " 
	   EndIf
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                      SFE.FE_EMISSAO AS Fecha,                         "
	   Else
       		clQryRete += "                      SFE.FE_EMISSAO AS 'Fecha',                         "
	   EndIf
       clQryRete += "                      CASE                                               "
       clQryRete += "                        WHEN FE_TIPO = 'I' THEN 'true'                   " 
       clQryRete += "                          ELSE 'false'                                   "
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                       END            AS RetemIVA,                     " 
	   Else
       		clQryRete += "                       END            AS 'RetemIVA',                     " 
	   EndIf
       clQryRete += "                     CASE                                                "
       clQryRete += "       WHEN FE_TIPO = 'E' OR FE_TIPO = 'R'  THEN 'true'                   " 
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                        ELSE 'false' END AS RetemIR,                   "
	   Else
       		clQryRete += "                        ELSE 'false' END AS 'RetemIR',                   "
	   EndIf
       clQryRete += "  F1_NUMTIM, F1_TXMOEDA, FE_NFISCAL, F1_DTDIGIT,                         "
       clQryRete += "  A2_CGC, A2_NOME, A2_END, A2_EMAIL, A2_PAIS, A2_TEL, A2_TPDOC,          "
       clQryRete += "  A2_CLASIR, A2_CLASIVA,                                                 " 
       clQryRete += "  case When (A2_Tipo = 'A' and A2_EST <> 'EX') then 'contribuyente'      "
       clQryRete += "  When (A2_Tipo = 'N' and A2_EST <> 'EX') then 'no contribuyente'        "
       clQryRete += "  When (A2_Tipo = 'N' OR A2_Tipo = 'S' AND A2_EST = 'Ex') then           "
	   If cTpBco == "POSTGRES"
	   		clQryRete += "  'no domiciliado' end as SITU, F0O_DTGERA, F0O_HRGERA ,FE_PARCELA,    "
	   Else
       		clQryRete += "  'no domiciliado' end as 'SITU', F0O_DTGERA, F0O_HRGERA ,FE_PARCELA,    "
       EndIf
	   clQryRete += "  F0O_TPIMPO                 
       clQryRete += " FROM " + RetSqlName("SFE")+ " SFE                                       " 
       clQryRete += "  INNER JOIN " + RetSqlName("SF1")+ " SF1                                " 
       clQryRete += "       ON ( SFE.FE_NFISCAL = SF1.F1_DOC AND SFE.FE_SERIE = SF1.F1_SERIE  "          
       clQryRete += "         AND SFE.FE_FORNECE = SF1.F1_FORNECE )                           "
       clQryRete += "  INNER JOIN " + RetSqlName("SA2")+ " SA2                                "
       clQryRete += "       ON (SFE.FE_FORNECE = SA2.A2_COD)                                  "
       clQryRete += "  INNER JOIN " + RetSqlName("F0O")+ " F0O                                " 
       clQryRete += "       ON (F0O.F0O_NFISCA = SFE.FE_NFISCAL AND                           " 
       clQryRete += "           F0O.F0O_SERIE  = SFE.FE_SERIE   AND                           "
       clQryRete += "           F0O.F0O_FORNEC = SFE.FE_FORNECE  AND                            "
       clQryRete += "           F0O.F0O_TPIMPO = SFE.FE_TIPO)                              "
        
       clQryRete += " WHERE SFE.FE_FILIAL     = '" + xFilial("SFE")         + "'" 
       clQryRete += "   AND SFE.FE_ORDPAGO    = '" + AllTrim(aGerar[i][1])  + "'" 
       clQryRete += "   AND SFE.FE_NFISCAL    = '" + AllTrim(aGerar[i][2])  + "'"   
       clQryRete += "   AND SFE.FE_SERIE      = '" + AllTrim(aGerar[i][3])  + "'" 
       clQryRete += "   AND SFE.FE_FORNECE    = '" + AllTrim(aGerar[i][4])  + "'" 
       clQryRete += "   AND F0O.F0O_TPIMPO    = '" + AllTrim(aGerar[i][7])  + "'" 
       If cTpBco $ "ORACLE|POSTGRES"
       		clQryRete += "   AND LENGTH(F0O.F0O_DTTRAN) = 0 AND  LENGTH(F0O.F0O_HRTRAN) = 0                  "        
	   Else
			clQryRete += "   AND (F0O.F0O_DTTRAN) = 0 AND LEN(F0O.F0O_HRTRAN) = 0
       EndIf
       
       clQryRete += "   AND (SFE.FE_TIPO = 'I' OR SFE.FE_TIPO = 'R' OR SFE.fe_tipo = 'E')     "
       clQryRete += "   AND SFE.D_E_L_E_T_ <> '*' AND SF1.D_E_L_E_T_ <> '*'                   "
       clQryRete += "   AND SA2.D_E_L_E_T_ <> '*' AND F0O.D_E_L_E_T_ <> '*'                   "
       clQryRete += "   AND SFE.FE_LOJA =    '" + AllTrim(aGerar[i][5])  + "'"
       clQryRete := ChangeQuery(clQryRete)       
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryRete),cRetencao)    
       TCSetField(cRetencao,"F1_EMISSAO","D",8,0)
       TCSetField(cRetencao,"FE_VALBASE","N",18,2)
       TCSetField(cRetencao,"F1_MOEDA","N",18,2)  

       If cTpBco == "POSTGRES"
	   		clQryPar := "SELECT  COUNT(E2_PARCELA)  AS PARCELA, E2_EMISSAO AS EMISSAO, E2_VENCTO  AS VENCIMENTO   "
	   Else
	   		clQryPar := "SELECT  COUNT(E2_PARCELA)  AS 'PARCELA', E2_EMISSAO AS 'EMISSAO', E2_VENCTO  AS 'VENCIMENTO'   "
       EndIf
	   clQryPar += "  FROM " + RetSqlName("SE2")  
       clQryPar += " WHERE  E2_FILIAL =  '" + xFilial("SFE")         + "'"  
       clQryPar += "    AND E2_NUM =     '" + AllTrim(aGerar[i][2])  + "'"   
       clQryPar += "    AND E2_PREFIXO = '" + AllTrim(aGerar[i][3])  + "'" 
       clQryPar += "    AND E2_FORNECE = '" + AllTrim(aGerar[i][4])  + "'"
       clQryPar += "    AND E2_LOJA =    '" + AllTrim(aGerar[i][5])  + "'"
       clQryPar += "    AND D_E_L_E_T_ <> '*' "                                 
       clQryPar +=" GROUP BY E2_EMISSAO,E2_VENCTO"
       clQryPar := ChangeQuery(clQryPar)
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryPar),cRetenca)                        
       
       cVirg   := .F.              
       If cValToChar(cTipTxt) == '2'
   	 	  cTabDeta   := GetNextAlias()   
         clQryDeta  := "SELECT * FROM " + RetSqlName("F0P")
         clQryDeta  += " WHERE F0P_FILIAL = '" + xFilial("F0P")       + "'"         
         clQryDeta  += " AND F0P_ORDPAG = '" + AllTrim(aGerar[i][1])  + "'"   
         clQryDeta  += " AND F0P_NUMNF = '" + AllTrim(aGerar[i][2])  + "'"          
         clQryDeta  += " AND F0P_SERIER = '" + AllTrim(aGerar[i][3])  + "'" 
         clQryDeta  += " AND F0P_FORNEC = '" + AllTrim(aGerar[i][4])  + "'"
         clQryDeta  += " AND F0P_LOJA   = '" + AllTrim(aGerar[i][5])  + "'"  
         clQryDeta  += " AND F0P_IMP   = '" + AllTrim(aGerar[i][7])  + "'"  
         clQryDeta += "    AND D_E_L_E_T_ <> '*' "                                 
         clQryDeta  := ChangeQuery(clQryDeta)
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryDeta),cTabDeta)  

		 Iif(i<=1, CLin := '[ { "detalle": [ ', CLin := ', { "detalle": [ ')
         lVirg := .F.
         cDetalhe1:=""
         
         cReten := STRTRAN(cReten, "<PorcRenta>", AllTrim(Str((cTabDeta)->(F0P_ALIQIR))) )  
         While !(&(cTabDeta)->(EOF()))  
               If lVirg
               		cDetalhe1:= cDetalhe1+ ","
               EndIf  
               
                lDet:=.F.
               cReten := IIf(AllTrim(((cRetencao)->(RetemIR))) == 'false', STRTRAN(cReten, "<PorcRenta>", '0'), STRTRAN(cReten, "<PorcRenta>", AllTrim(Str((cTabDeta)->(F0P_ALIQIR))))) 
               cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
               If ((cTabDeta)->(F0P_ALIQ0))  > 0    .And. AllTrim(((cRetencao)->(RetemIVA))) == 'true'
                   cDetalhe := STRTRAN(cDetalhe, "<Qtde>",  cValToChar(((cTabDeta)->(F0P_QUANT))))   
                   cDetalhe := STRTRAN(cDetalhe, "<Tasa>",  cValToChar(((cTabDeta)->(F0P_ALIQ0))))
                   cDetalhe := STRTRAN(cDetalhe, "<Preco>", cValToChar(((cTabDeta)->(F0P_VALUNI))))
                   cDetalhe := STRTRAN(cDetalhe, "<Descr>", cValToChar(((cTabDeta)->(F0P_DESCRI))))  
                   lDet:=.T.
                   lVirg := .T.                
               ElseIf ((cTabDeta)->(F0P_ALIQ5))  > 0   .And. AllTrim(((cRetencao)->(RetemIVA))) == 'true'
                       cDetalhe := STRTRAN(cDetalhe, "<Qtde>",  cValToChar(((cTabDeta)->(F0P_QUANT))))   
                       cDetalhe := STRTRAN(cDetalhe, "<Tasa>",  cValToChar(((cTabDeta)->(F0P_ALIQ5))))
                       cDetalhe := STRTRAN(cDetalhe, "<Preco>", cValToChar(((cTabDeta)->(F0P_VALUNI))))
                       cDetalhe := STRTRAN(cDetalhe, "<Descr>", cValToChar(((cTabDeta)->(F0P_DESCRI))))   
                        lDet:=.T.
                       lVirg := .T. 
                ElseIf ((cTabDeta)->(F0P_ALIQ10))  > 0   .And. AllTrim(((cRetencao)->(RetemIVA))) == 'true'
                           cDetalhe := STRTRAN(cDetalhe, "<Qtde>",  cValToChar(((cTabDeta)->(F0P_QUANT))))   
                           cDetalhe := STRTRAN(cDetalhe, "<Tasa>",  cValToChar(((cTabDeta)->(F0P_ALIQ10))))
                           cDetalhe := STRTRAN(cDetalhe, "<Preco>", cValToChar(((cTabDeta)->(F0P_VALUNI))))
                           cDetalhe := STRTRAN(cDetalhe, "<Descr>", cValToChar(((cTabDeta)->(F0P_DESCRI)))) 
                            lDet:=.T.
                           lVirg := .T. 
               Else
                           cDetalhe := STRTRAN(cDetalhe, "<Qtde>",  cValToChar(((cTabDeta)->(F0P_QUANT))))   
                           cDetalhe := STRTRAN(cDetalhe, "<Tasa>",  cValToChar(0))
                           cDetalhe := STRTRAN(cDetalhe, "<Preco>", cValToChar(((cTabDeta)->(F0P_VALUNI))))
                           cDetalhe := STRTRAN(cDetalhe, "<Descr>", cValToChar(((cTabDeta)->(F0P_DESCRI)))) 
                            lDet:=.T.
                           lVirg := .T. 			
               
               
               
               
               EndIf
               
               
               
               If  lDet   
               	cDetalhe1:= cDetalhe1+cDetalhe
               EndIf
               (&(cTabDeta)->(DbSkip()))
         EndDo
         (&(cTabDeta)->(dbCloseArea()))          
       EndIf        
       cDetalhe := STRTRAN(cDetalhe1, "'", '"')
       cLin     := cLin + cDetalhe + ' ], '       
       cReten   := STRTRAN(cReten, "<Dt_Fecha>", AllTrim(cValToChar(ARRUMADT(aGerar[i][6])))) 
       SYF->(MsSeek(xFilial("SYF")+ (GetMV("MV_SIMB"+cValToChar(((cRetencao)->(F1_MOEDA)))))))      
       cReten   := STRTRAN(cReten, "<moeda>", AllTrim(SYF->YF_COD_GI))       
       
       If cValToChar(((cRetencao)->(F1_MOEDA))) <> "1" //Moeda principal          
         cReten := STRTRAN(cReten, "<TpCambio>", Alltrim(Str((cRetencao)->(F1_TXMOEDA))))
       Else
         cReten := STRTRAN(cReten, "'tipoCambio': <TpCambio>,", '')
       End        

       cReten := STRTRAN(cReten, "<RetRenta>", LOWER(AllTrim(((cRetencao)->(RetemIR)))) ) 
       If (cRetencao)->(F0O_TPIMPO) == 'I'
       cReten := STRTRAN(cReten, "<CtRenta>", "")
        cReten := STRTRAN(cReten, "<Iva5>", '100')
        cReten := STRTRAN(cReten, "<IVA10>", '100')
        cReten := STRTRAN(cReten, "<BsRenta>", '0')
        cReten := STRTRAN(cReten, "<QtRenta>", '0')
        cReten := STRTRAN(cReten, "<TnRenta>", '0')
        cReten := STRTRAN(cReten, "<QtRentasT>", '0')         
       Else
     	              
       	SX5->( MsSeek(xFilial("SX5")+"H6"+((cRetencao)->(A2_CLASIR))))
       	cReten := STRTRAN(cReten, "<CtRenta>", AllTrim(X5DESCRI()))
        cReten := STRTRAN(cReten, "<Iva5>", '0')
        cReten := STRTRAN(cReten, "<IVA10>", '0')
        cReten := STRTRAN(cReten, "<BsRenta>", '0')
        cReten := STRTRAN(cReten, "<QtRenta>", '0')
        cReten := STRTRAN(cReten, "<TnRenta>", '0')
        cReten := STRTRAN(cReten, "<QtRentasT>", '0')
       EndIf

      // cReten := IIf(AllTrim(((cRetencao)->(RetemIR))) == 'false', STRTRAN(cReten, "<PorcRenta>", '0'), STRTRAN(cReten, "<PorcRenta>", (cTabDeta)->(F0P_ALIQIR)))
       
       cReten := STRTRAN(cReten, "<RetIva>", LOWER(AllTrim(((cRetencao)->(RetemIVA)))) )
       If (cRetencao)->(F0O_TPIMPO) == 'I'
       		cReten := STRTRAN(cReten, "<CptoIva>", 'IVA.1')
       Else
       	cReten := STRTRAN(cReten, "<CptoIva>", '')
       EndIf
       cReten := STRTRAN(cReten, "'", '"')
       cLin := cLin + cReten       
       cInform := STRTRAN(cInform, "<TpPessoa>", UPPER(AllTrim(((cRetencao)->(SITU))))) 
       cInform := STRTRAN(cInform, "<Nome>", OemToAnsi(AllTrim(((cRetencao)->(A2_NOME)))))
       
       cInform := STRTRAN(cInform, "<Ender>", OemToAnsi(Iif(AllTrim(((cRetencao)->(SITU))) == 'contribuyente', AllTrim(((cRetencao)->(A2_END))), '')))
       
       cInform := STRTRAN(cInform, "<Ruc>", Iif(AllTrim(((cRetencao)->(SITU))) == 'contribuyente', SubStr(AllTrim(((cRetencao)->(A2_CGC))), 1, Len(AllTrim(((cRetencao)->(A2_CGC))))-2), ''))
       cInform := STRTRAN(cInform, "<DV>", Iif(AllTrim(((cRetencao)->(SITU))) == 'contribuyente',SubStr(AllTrim(((cRetencao)->(A2_CGC))),Len(AllTrim(((cRetencao)->(A2_CGC)))),1) , ''))
     
       SX5->( MsSeek(xFilial("SX5")+"TB"+((cRetencao)->(A2_TPDOC))))       
       cInform := STRTRAN(cInform, "<TpIdent>", Iif(AllTrim(((cRetencao)->(SITU))) <> 'contribuyente', AllTrim(X5DESCRI()), ''))
       cInform := STRTRAN(cInform, "<Ident>", OemToAnsi(Iif(AllTrim(((cRetencao)->(SITU))) <> 'contribuyente', AllTrim(((cRetencao)->(A2_NOME))), '')))       
       cInform := STRTRAN(cInform, "<Direcao>", OemToAnsi(Iif(AllTrim(((cRetencao)->(SITU))) <> 'contribuyente', AllTrim(((cRetencao)->(A2_END))), '')))
       cInform := STRTRAN(cInform, "<Email>", Iif(AllTrim(((cRetencao)->(SITU))) <> 'contribuyente', AllTrim(((cRetencao)->(A2_EMAIL))), ''))
       
       If AllTrim(((cRetencao)->(SITU))) == 'no domiciliado'
       
       	cInform :=  STRTRAN(cInform, "<Pais>", POSICIONE("SYA", 1, xFilial("SYA") + (cRetencao)->A2_PAIS, "YA_SIGLA") )
       	 
       Else
       	cInform :=STRTRAN(cInform, "<Pais>",  '')
       
       EndIf
       
       
       cInform := STRTRAN(cInform, "<Tel>", Iif(AllTrim(((cRetencao)->(SITU))) <> 'contribuyente',  AllTrim(((cRetencao)->(A2_TEL))), ''))
       cInform := STRTRAN(cInform, "'", '"')
       cLin := cLin + cInform      
              
       cTransac := STRTRAN(cTransac, "<NumComp>", TransForm(AllTrim(((cRetencao)->(FE_NFISCAL))),"@R XXX-XXX-XXXXXXX"))       
       cTransac := STRTRAN(cTransac, "<TpCompra>", IIf((cRetenca)->PARCELA==1 .And. ((cRetenca)->(Emissao)) == ((cRetenca)->(Vencimento)),"CONTADO","CREDITO"))
       cTransac := STRTRAN(cTransac, "<Quotas>", Alltrim( str(   (cRetenca)->(PARCELA)       ))     ) // AllTrim(Str(Len(cTabParce))))
       cTransac := STRTRAN(cTransac, "<TpComp>", '1')
       cTransac := STRTRAN(cTransac, "<DtFecha>", AllTrim(ArrumaDt(((cRetencao)->(F1_DTDIGIT)))))
       cTransac := STRTRAN(cTransac, "<NumTimbr>", Iif(AllTrim(((cRetencao)->(SITU))) == 'contribuyente', TransForm(AllTrim(((cRetencao)->(F1_NUMTIM))),"@R XXXXXXXX"), '0'))
       
       
       
       cTransac := STRTRAN(cTransac, "'", '"')
       cLin := cLin + cTransac    
 
       cAtrib := STRTRAN(cAtrib, "<FechaCr>", AllTrim(ARRUMADT(((cRetencao)->(F0O_DTGERA)))))
       cAtrib := STRTRAN(cAtrib, "<HoraCr>", ((cRetencao)->(F0O_HRGERA))) 
       cAtrib := STRTRAN(cAtrib, "'", '"')+ iif( i ==  Len(aGerar),']','')  
       cLin := cLin + cAtrib         
       cLin1:= cLin1 + cLin
       
       (cRetencao)->(dbCloseArea())     
       (cRetenca)->(dbCloseArea())     

	cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
    cReten    := " 'retencion': {'fecha': '<Dt_Fecha>', 'moneda': '<moeda>', 'tipoCambio': <TpCambio>, 'retencionRenta': <RetRenta>,  " +;
                   " 'conceptoRenta': '<CtRenta>', 'ivaPorcentaje5': <Iva5>, 'ivaPorcentaje10': <IVA10>, 'rentaCabezasBase': <BsRenta>, " +;
                   " 'rentaCabezasCantidad': <QtRenta>, 'rentaToneladasBase': <TnRenta>, 'rentaToneladasCantidad': <QtRentasT>,         " +;
                   " 'rentaPorcentaje': <PorcRenta>, 'retencionIva': <RetIva>, 'conceptoIva': '<CptoIva>' }, "
     cInform   := " 'informado': { 'situacion': '<TpPessoa>', 'nombre': '<Nome>', 'ruc': '<Ruc>', 'dv': '<DV>', 'domicilio': '<Ender>'," +;
                   " 'tipoIdentificacion': '<TpIdent>', 'identificacion': '<Ident>', 'direccion': '<Direcao>', 'correoElectronico':     " +;
                   " '<Email>', 'pais': '<Pais>', 'telefono': '<Tel>' }, "     
    cTransac  := " 'transaccion': { 'numeroComprobanteVenta': '<NumComp>', 'condicionCompra': '<TpCompra>', 'cuotas': <Quotas>,       " +;
                   " 'tipoComprobante': <TpComp>, 'fecha': '<DtFecha>', 'numeroTimbrado': '<NumTimbr>' }, "  

	if i ==  Len(aGerar)  
     	cAtrib    := " 'atributos': { 'fechaCreacion': '<FechaCr>', 'fechaHoraCreacion': '<HoraCr>' }}] "  
	else
		   cAtrib    := " 'atributos': { 'fechaCreacion': '<FechaCr>', 'fechaHoraCreacion': '<HoraCr>' }} "  
	EndIf
	                                     

     Next
     fWrite(nHdl, cLin1)
	 If !lAutomato	
     	MsgAlert(STR0018,STR0019)  
   	 EndIf
  EndIf
  fClose(nHdl)
  RestArea(aArea)
EndIf

Return

/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |F103VISUA | Autor |Paulo Augusto          | Data |09/10/2014|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Tratamento da Visualizacao                        |
+------------+------------------------------------------------------------+
| Sintaxe    |F103VISUA(ExpC1,ExpN2,ExpN3)                              |
+------------+------------------------------------------------------------+
| Parametros | ExpC1: Alias do arquivo                                    |
|            | ExpN2: Registro do Arquivo                                 |
|            | ExpN3: Opcao da MBrowse                                    |
+------------+------------------------------------------------------------+
| Retorno    | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Uso        | FISA802                                                   |
+------------+------------------------------------------------------------+
/*/
Function F103VISUA(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local lQuery    := .F.
Local cCadastro := OemToAnsi(STR0001) //"Processo de Venda"
Local cQuery    := ""
Local cTrab     := "TRB"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
PRIVATE aHEADER := {}
PRIVATE aCOLS   := {}
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}
//+----------------------------------------------------------------+
//|   Montagem de Variaveis de Memoria                             |
//+----------------------------------------------------------------+
dbSelectArea("F0O")
dbSetOrder(1)
For nCntFor := 1 To FCount()
   M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//+----------------------------------------------------------------+
//|   Montagem do aHeader                                          |
//+----------------------------------------------------------------+
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("F0P")
While ( !Eof() .And. SX3->X3_ARQUIVO == "F0P" )
   If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
      nUsado++
      Aadd(aHeader,{ TRIM(X3Titulo()),;
      TRIM(SX3->X3_CAMPO),;
      SX3->X3_PICTURE,;
      SX3->X3_TAMANHO,;
      SX3->X3_DECIMAL,;
      SX3->X3_VALID,;
      SX3->X3_USADO,;
      SX3->X3_TIPO,;
      SX3->X3_ARQUIVO,;
      SX3->X3_CONTEXT } )
   EndIf
   dbSelectArea("SX3")
   dbSkip()
EndDo
/*
+----------------------------------------------------------------+
|   Montagem do aCols                                            |
+----------------------------------------------------------------+
*/                                                                                                           
dbSelectArea("F0P")
dbSetOrder(1)
F0P->(MsSeek(xFilial("F0P")+F0O->F0O_ORDPAG+F0O->F0O_SERIER+F0O->F0O_NUMNF))  //filial tpresg  serier numreg especie serie  num
      bWhile := {|| xFilial("F0P")  == F0P->F0P_FILIAL .And.; 
      F0O->F0O_ORDPAG+F0O->F0O_SERIER+F0O->F0O_NUMNF== F0P->F0P_ORDPAG+F0P->F0P_SERIER+F0P_NUMNF} 

While ( !Eof() .And. Eval(bWhile) )
	aadd(aCOLS,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
		aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
	EndIf
	Next nCntFor
	aCOLS[Len(aCols)][Len(aHeader)+1] := .F.

	dbSkip()
EndDo
aObjects := {} 
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .T. ) 
DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL 
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "" ,"AllwaysTrue","",.F.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
RestArea(aArea)

Return(.T.)


Function FI802ANU()
nOP:= F0O->F0O_ORDPAG
	If Aviso(STR0020,STR0021+ ' " ' + F0O->F0O_ORDPAG     +  ' " ' + STR0022 ,{STR0028,STR0029}) == 1
			F0P->(DbSetOrder(1)  )
			F0P->(MsSeek(xfilial("F0P")+nOP,.t.) )
			If F0P->(MsSeek(xfilial("F0P")+nOP,.t.) )//+F0O->F0O_SERIER+F0O->F0O_NUMNF+F0O->F0O_FORNEC+F0O->F0O_LOJA,.t.) )   
				While !(F0P->(Eof())) .AND. ( xFilial("F0P") +nOP/*+F0O->F0O_SERIER+F0O->F0O_NUMNF+F0O->F0O_FORNEC+F0O->F0O_LOJA*/==;
				                              F0P->F0P_FILIAL+F0P->F0P_ORDPAG/*+F0P->F0P_SERIE+ F0P->F0P_NUMNF+F0P->F0P_FORNEC+F0P->F0P_LOJA*/)
					RecLock("F0P",.F.)
					F0P->(dbDelete())		
  					MsUnLock()     
  					F0P->(DbSkip())
			    EndDo
			
				F0O->(DbSetOrder(1)  )  
				F0O->(DbGotop())
				F0O->(MsSeek(xfilial("F0O")+nOP))	
				While !(F0O->(Eof())) .AND. ( xFilial("F0O") +nOP ==   F0O->F0O_FILIAL+F0O->F0O_ORDPAG)       
				
				aArea:=GetArea()
				DbSelectArea("SFE")
				DbSetOrder(2)
				If (MsSeek(xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO)   )
					While !EOF() .And. xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO ==;
							SFE->FE_FILIAL+SFE->FE_ORDPAGO+SFE->FE_TIPO
						If F0O->F0O_FORNEC==SFE->FE_FORNECE .AND. F0O->F0O_LOJA==SFE->FE_LOJA ;
								.AND. F0O->F0O_NFISCA==SFE->FE_NFISCAL .AND. F0O->F0O_SERIE== SFE->FE_SERIE
				  				RecLock("SFE",.F.)
				  				SFE->FE_NROTES:=""
								MsUnlock()
						EndIf
						SFE->(dbSkip())
					EndDo
				EndIf
				RestArea(aArea)
				
				
			
					RecLock("F0O",.F.)
					F0O->(dbDelete())		
  					MsUnLock()
  					F0O->(DbSkip())
  				EndDo
				MsgInfo(STR0023)
			EndIf	
	EndIf
Return


Function QryArray(cQuery) 
Local aRet    := {} 
Local aRet1   := {} 
Local nRegAtu := 0 
Local x       := 0 

cQuery := ChangeQuery(cQuery) 
TCQUERY cQuery NEW ALIAS "_TRB" 

dbSelectArea("_TRB") 
aRet1   := Array(Fcount()) 
nRegAtu := 1 

While !Eof()      
     For x:=1 To Fcount() 
          aRet1[x] := FieldGet(x) 
     Next 
     Aadd(aRet,aclone(aRet1)) 
      
     dbSkip() 
     nRegAtu += 1 
Enddo 

dbSelectArea("_TRB") 
_TRB->(DbCloseArea()) 

Return(aRet) 


Function ARRUMADT(cData)
Local Ret := ""
Ret := (SubStr(cData, 1, 4) + "-" + SubStr(cData, 5, 2) + "-" + SubStr(cData, 7, 2))
Return Ret

 		

Function Fi802AcN()

Local 	cCod:=Space(13)
Local 	dData:= dDataBAse
Local		oDlg
Local 	cAlias:=Alias()
Local 	lMa:=.F.       
Local    cDoc:=F0O->F0O_SERIE + "    /    " + F0O->F0O_NFISCA

If !Empty(F0O->F0O_NROTES)
		lMa:=.T.
EndIf

If lMa
	MsgStop(STR0024,STR0025)
	Return()
EndIf

SFP->(DbSetOrder(6))
lVldExp:=.F.
cTipo:=""


DEFINE MSDIALOG oDlg FROM 00,00 TO 120,400 PIXEL TITLE STR0032
@	007,003 	Say STR0030 OF oDlg PIXEL
@	007,095		Say cDoc OF oDlg PIXEL
@	020,003 	Say  STR0031  OF oDlg PIXEL
@	020,095	    Get  cCod   OF oDlg PIXEL
	
	
DEFINE SBUTTON FROM 045,100	TYPE 1 ACTION Fi802AcT(cCod,oDlg) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return( )

                                                                                  
Function Fi802AcT(cCod,oDlg,lConsWs)
Local aArea:=GetArea()
Default oDlg		:= Nil
Default lConsWs 	:= .F.

RecLock("F0O",.F.)
F0O->F0O_NROTES:=cCod
MsUnlock()

DbSelectArea("SFE")
DbSetOrder(2)
If (MsSeek(xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO)   )
	While !EOF() .And. xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO ==;
			SFE->FE_FILIAL+SFE->FE_ORDPAGO+SFE->FE_TIPO
		If F0O->F0O_FORNEC==SFE->FE_FORNECE .AND. F0O->F0O_LOJA==SFE->FE_LOJA ;
				.AND. F0O->F0O_NFISCA==SFE->FE_NFISCAL .AND. F0O->F0O_SERIE== SFE->FE_SERIE
  				RecLock("SFE",.F.)
  				SFE->FE_NROTES:=cCod
				mSGaLERT(STR0033," ")
				MsUnlock()
		EndIf
		SFE->(dbSkip())
	EndDo
EndIf
RestArea(aArea)
If oDlg <> Nil
	oDlg:End()
endif

Return()

