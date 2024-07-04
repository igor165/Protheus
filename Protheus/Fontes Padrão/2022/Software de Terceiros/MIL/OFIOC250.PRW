#Include "protheus.ch"
#Include "OFIOC250.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ OFIOC250 ³ Autor ³ Andre Luis Almeida     ³ Data ³ 26/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Consulta/Retorna CD.SERVICO - Servicos GM                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC250(cCodSer)
Private cMarc := VV1->VV1_CODMAR // Marca do Veiculo
Private M->&("VO6_CODMAR") := cMarc // Variavel com o Cod.Marca utilizado no SXB ( Consulta VS6 )
Private cApli := substr(VV1->VV1_CHASSI,4,4) // Aplicacao substr do VV1_CHASSI
Private aSer  := {}		// Vetor com os Servicos (Dealer)
Private aSerAux := {}	// Vetor com os Servicos Auxiliar (Dealer)
Private cServico:= space(150)	// Filtra Descricao do Servico
Private cObserv := space(250)	// Observacoes
Private cCGrp := space(4)
Private cDGrp := space(50)
Private cCCod := space(15)
Private cDesc := space(200)
If FunName() == "OFIOM030"
	cCGrp := M->VO4_GRUSER
ElseIf FunName() == "OFIOM110"
	If type("oGetInc") == "U"
		cCGrp := M->VS4_GRUSER
	Else
		cCGrp := M->VSM_CODGRU
	EndIf
ElseIf FunName() == "OFIOA140"
	cMarc := M->VO6_CODMAR
EndIf
FS_VALIDAR("GRP")
FS_FILTRAR("0")
If cCodSer # NIL
	cCCod := cCodSer
	FS_FILTRAR("2")
EndIf
DEFINE MSDIALOG oTMOSC TITLE STR0001 From 5,08 to 29,92 of oMainWnd

	@ 045,001 LISTBOX oLbSer FIELDS HEADER OemToAnsi(STR0002),;// Aplicacao
														OemToAnsi(STR0003),;	// Adicional
														OemToAnsi(STR0004),;	// Cod.Servico
														OemToAnsi(STR0005),;	// Detalhe Engenharia
                                       	OemToAnsi(STR0006),;	// Tempo
                                       	OemToAnsi(STR0007),;	// Descricao
                                       	OemToAnsi(STR0008),;	// Marca
                                       	OemToAnsi(STR0009),;	// Grupo
                                       	OemToAnsi(STR0007);	// Descricao Grupo
	COLSIZES 17,15,40,15,20,70,15,15,30 SIZE 331,082 OF oTMOSC PIXEL ON CHANGE FS_OBSTMO() ON DBLCLICK ( FS_RETORNO() , oTMOSC:End() )
	oLbSer:SetArray(aSer)
	oLbSer:bLine := { || {aSer[oLbSer:nAt,6] ,; 
								aSer[oLbSer:nAt,7] ,;
                        aSer[oLbSer:nAt,2] ,;
								Alltrim(aSer[oLbSer:nAt,9]) ,;
                        aSer[oLbSer:nAt,5] ,;
                        aSer[oLbSer:nAt,3] ,;
                        aSer[oLbSer:nAt,10] ,;
                        aSer[oLbSer:nAt,1] ,;
                        Posicione("VOS",1,xFilial("VOS")+aSer[oLbSer:nAt,10]+aSer[oLbSer:nAt,1],"VOS_DESGRU")}}

	@ 006,005 SAY STR0010 SIZE 45,10 OF oTMOSC PIXEL COLOR CLR_BLUE
	@ 005,035 MSGET oCGrp VAR cCGrp PICTURE "@!" F3 "VS6" VALID FS_VALIDAR("GRP") SIZE 30,8 OF oTMOSC PIXEL COLOR CLR_BLUE
	@ 005,070 MSGET oDGrp VAR cDGrp PICTURE "@!" SIZE 160,8 OF oTMOSC PIXEL COLOR CLR_BLUE WHEN .f.

	@ 019,005 SAY (STR0004+":") SIZE 45,10 OF oTMOSC PIXEL COLOR CLR_BLUE
	@ 018,035 MSGET oCCod VAR cCCod PICTURE "@!" SIZE 195,8 OF oTMOSC PIXEL COLOR CLR_BLUE

	@ 032,005 SAY (STR0007+":") SIZE 45,10 OF oTMOSC PIXEL COLOR CLR_BLUE			
	@ 031,035 MSGET oServico VAR cServico PICTURE "@!" SIZE 195,08 OF oTMOSC PIXEL COLOR CLR_BLUE

	@ 009,240 BUTTON oFiltrar PROMPT STR0011 OF oTMOSC SIZE 85,10 PIXEL ACTION (FS_FILTRAR("1"),oLbSer:SetFocus(),FS_OBSTMO())
	@ 027,240 BUTTON oSair PROMPT STR0012 OF oTMOSC SIZE 85,10 PIXEL ACTION (oTMOSC:End())

	@ 130,001 MSGET oDesc VAR cDesc SIZE 332,8 OF oTMOSC PIXEL COLOR CLR_BLUE WHEN .f.
	@ 142,001 GET oObserv VAR cObserv OF oTMOSC MEMO SIZE 331,039 PIXEL READONLY MEMO

ACTIVATE MSDIALOG oTMOSC CENTER 
Return(.t.)

Static Function FS_VALIDAR(cTip)
Local lRet := .f.
If cTip == "GRP"
	cDGrp := ""
	If !Empty(cCGrp)
		DbSelectArea("VOS") 
		DbSetOrder(2)
		If DbSeek(xFilial("VOS")+cCGrp)
			lRet := .t.
			cDGrp := VOS->VOS_DESGRU
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf
Return(lRet)

Static Function FS_FILTRAR(cTip)
Local ni  := 0
Local lOk := .f.
Local cQuery    := ""
Local cQAlias := "cQAlias"
aSer := {}
If cTip == "0" 
	If cMarc # FG_MARCA("CHEVROLET",,.f.)
		#IFDEF TOP
			cQuery := "SELECT VO6.VO6_GRUSER , VO6.VO6_CODSER , VO6.VO6_DESSER , VO6.VO6_DESMEM , VO6.VO6_TEMFAB , VO6.VO6_CODMAR "
			cQuery += "FROM "+RetSqlName("VO6")+" VO6 WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND "
			cQuery += "VO6.VO6_SERATI='1' AND VO6.D_E_L_E_T_=' '"
			cQuery := ChangeQuery( cQuery ) 
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. ) 
			Do While !( cQAlias )->( Eof() ) 
		  		If Empty(cCGrp) .or. ( cCGrp == ( cQAlias )->(VO6_GRUSER) )
					Aadd(aSer,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VO6_TEMFAB),"@R 999:99"),"","","","",( cQAlias )->(VO6_CODMAR)})
				EndIf
				Aadd(aSerAux,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VO6_TEMFAB),"@R 999:99"),"","","","",( cQAlias )->(VO6_CODMAR)})
			   ( cQAlias )->( DbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() ) 
		#ENDIF
		If len(aSer) <= 0 
			Aadd(aSer,{"","","","","","","","","",""})
		EndIf
	Else

		If FunName() # "OFIOA140"

			#IFDEF TOP
				cQuery := "SELECT VO6.VO6_GRUSER , VO6.VO6_CODSER , VO6.VO6_DESSER , VO6.VO6_DESMEM , VJ9.VJ9_TEMFAB , VJ9.VJ9_APLICA , VJ9.VJ9_SRVADI , VJ9.VJ9_MODENG , VJ9.VJ9_DETENG , VO6.VO6_CODMAR "
				cQuery += "FROM "+RetSqlName("VJ9")+" VJ9 INNER JOIN "+RetSqlName("VO6")+" VO6 ON VJ9.VJ9_CODSER=VO6.VO6_CODSER "
				cQuery += "WHERE VJ9.VJ9_FILIAL='"+xFilial("VJ9")+"' AND VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND "
				cQuery += "VJ9.VJ9_CODMAR='"+cMarc+"' AND VJ9.VJ9_APLICA='"+cApli+space(2)+"' AND "
				cQuery += "VJ9.VJ9_SERATI='1' AND VO6.VO6_SERATI='1' AND VJ9.D_E_L_E_T_=' ' AND VO6.D_E_L_E_T_=' '"
				cQuery := ChangeQuery( cQuery ) 
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. ) 
				Do While !( cQAlias )->( Eof() ) 
			  		If Empty(cCGrp) .or. ( cCGrp == ( cQAlias )->(VO6_GRUSER) )
						Aadd(aSer,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VJ9_TEMFAB),"@R 999:99"),( cQAlias )->(VJ9_APLICA),( cQAlias )->(VJ9_SRVADI),( cQAlias )->(VJ9_MODENG),( cQAlias )->(VJ9_DETENG),( cQAlias )->(VO6_CODMAR)})
					EndIf
					Aadd(aSerAux,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VJ9_TEMFAB),"@R 999:99"),( cQAlias )->(VJ9_APLICA),( cQAlias )->(VJ9_SRVADI),( cQAlias )->(VJ9_MODENG),( cQAlias )->(VJ9_DETENG),( cQAlias )->(VO6_CODMAR)})
				   ( cQAlias )->( DbSkip() )
				EndDo
				( cQAlias )->( dbCloseArea() ) 
				cQuery := "SELECT VO6.VO6_GRUSER , VO6.VO6_CODSER , VO6.VO6_DESSER , VO6.VO6_DESMEM , VO6.VO6_TEMFAB , VO6.VO6_CODMAR "
				cQuery += "FROM "+RetSqlName("VO6")+" VO6 WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND "
				cQuery += "VO6.VO6_CODMAR='   ' AND VO6.VO6_SERATI='1' AND VO6.D_E_L_E_T_=' '"
				cQuery := ChangeQuery( cQuery ) 
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. ) 
				Do While !( cQAlias )->( Eof() ) 
					Aadd(aSer,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VO6_TEMFAB),"@R 999:99"),"","","","",( cQAlias )->(VO6_CODMAR)})
					Aadd(aSerAux,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VO6_TEMFAB),"@R 999:99"),"","","","",( cQAlias )->(VO6_CODMAR)})
				   ( cQAlias )->( DbSkip() )
				EndDo
				( cQAlias )->( dbCloseArea() ) 
			#ENDIF
		EndIf
		If len(aSer) <= 0 
			Aadd(aSer,{"","","","","","","","","",""})
		EndIf
	EndIf
	aSort(aSer,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
Else
	If FunName() # "OFIOA140"
		For ni := 1 to len(aSerAux)
			lOk := .t.
		  	If !Empty(cCGrp)
		  		If cCGrp # aSerAux[ni,1]
		  			lOk := .f.
		  		EndIf
		  	EndIf
		  	If lOk .and. !Empty(cCCod)
		  		If Alltrim(cCCod) # left(aSerAux[ni,2],len(Alltrim(cCCod)))
		  			lOk := .f.
		  		EndIf
		  	EndIf
		  	If lOk .and. !Empty(cServico)
		  		If !(Alltrim(cServico) $ aSerAux[ni,3])
		  			lOk := .f.
		  		EndIf
		  	EndIf
			If lOk
				Aadd(aSer,{aSerAux[ni,1],aSerAux[ni,2],aSerAux[ni,3],aSerAux[ni,4],aSerAux[ni,5],aSerAux[ni,6],aSerAux[ni,7],aSerAux[ni,8],aSerAux[ni,9],aSerAux[ni,10]})
			EndIf
		Next
	Else
		#IFDEF TOP
			cQuery := "SELECT VO6.VO6_GRUSER , VO6.VO6_CODSER , VO6.VO6_DESSER , VO6.VO6_DESMEM , VJ9.VJ9_TEMFAB , VJ9.VJ9_APLICA , VJ9.VJ9_SRVADI , VJ9.VJ9_MODENG , VJ9.VJ9_DETENG , VO6.VO6_CODMAR "
			cQuery += "FROM "+RetSqlName("VJ9")+" VJ9 INNER JOIN "+RetSqlName("VO6")+" VO6 ON VJ9.VJ9_CODSER=VO6.VO6_CODSER "
			cQuery += "WHERE VJ9.VJ9_FILIAL='"+xFilial("VJ9")+"' AND VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND "
			cQuery += "VJ9.VJ9_CODMAR='"+cMarc+"' AND VJ9.VJ9_SERATI='1' AND VO6.VO6_SERATI='1' AND "
			If !Empty(cCCod)
				cQuery += "VJ9.VJ9_CODSER like '"+alltrim(cCCod)+"%' AND "
			EndIf
			If !Empty(cCGrp)
				cQuery += "VO6.VO6_GRUSER='"+cCGrp+"' AND "
			EndIf
			If !Empty(cServico)
				cQuery += "VO6.VO6_DESSER like '%"+alltrim(cServico)+"%' AND "
			EndIf
			cQuery += "VJ9.D_E_L_E_T_=' ' AND VO6.D_E_L_E_T_=' '"
			cQuery := ChangeQuery( cQuery ) 
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. ) 
			Do While !( cQAlias )->( Eof() ) 
		  		If Empty(cCGrp) .or. ( cCGrp == ( cQAlias )->(VO6_GRUSER) )
					Aadd(aSer,{( cQAlias )->(VO6_GRUSER),( cQAlias )->(VO6_CODSER),( cQAlias )->(VO6_DESSER),( cQAlias )->(VO6_DESMEM),Transform(( cQAlias )->(VJ9_TEMFAB),"@R 999:99"),( cQAlias )->(VJ9_APLICA),( cQAlias )->(VJ9_SRVADI),( cQAlias )->(VJ9_MODENG),( cQAlias )->(VJ9_DETENG),( cQAlias )->(VO6_CODMAR)})
				EndIf
			   ( cQAlias )->( DbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() ) 
		#ENDIF
	EndIf
	If len(aSer) <= 0 
		Aadd(aSer,{"","","","","","","","","",""})
	EndIf
	aSort(aSer,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
	If cTip == "1" // Filtro
		oLbSer:nAt := 1
		oLbSer:SetArray(aSer)
		oLbSer:bLine := { || {aSer[oLbSer:nAt,6] ,; 
									aSer[oLbSer:nAt,7] ,;
      	                  aSer[oLbSer:nAt,2] ,;
									Alltrim(aSer[oLbSer:nAt,9]) ,;
   	                     aSer[oLbSer:nAt,5] ,;
	                        aSer[oLbSer:nAt,3] ,;
      	                  aSer[oLbSer:nAt,10] ,;
         	               aSer[oLbSer:nAt,1] ,;
            	            Posicione("VOS",1,xFilial("VOS")+aSer[oLbSer:nAt,10]+aSer[oLbSer:nAt,1],"VOS_DESGRU")}}
		oLbSer:SetFocus()
	EndIf
EndIf
Return

Static Function FS_OBSTMO()
cDesc := ""
If !Empty(aSer[oLbSer:nAt,7])
	DbSelectArea("VJ8")
	DbSetOrder(1)
	If DbSeek(xFilial("VJ8")+aSer[oLbSer:nAt,10]+aSer[oLbSer:nAt,7])
		cDesc := STR0003+": "+aSer[oLbSer:nAt,7]+" "+Alltrim(VJ8->VJ8_DESADI)+"   "
	Else
		cDesc := STR0003+": "+aSer[oLbSer:nAt,7]+" "+STR0013+"   "
	EndIf
EndIf
cDesc += If(!Empty(aSer[oLbSer:nAt,8]),STR0014+" "+Alltrim(aSer[oLbSer:nAt,8]),"")
If !Empty(aSer[oLbSer:nAt,9])
	cDesc += " - "+Alltrim(aSer[oLbSer:nAt,9])
	DbSelectArea("VJ6")
	DbSetOrder(1)
	If DbSeek(xFilial("VJ6")+aSer[oLbSer:nAt,9])
		cDesc += " "+Alltrim(VJ6->VJ6_DESENG)
	Else
		cDesc += " "+STR0015
	EndIf
EndIf
cObserv := ""
If !Empty(aSer[oLbSer:nAt,4])
	cObserv := MSMM(aSer[oLbSer:nAt,4],70)
EndIf
oDesc:Refresh()
oObserv:Refresh()
Return

Static Function FS_RETORNO()
If FunName() # "OFIOC250"
	DbSelectArea("VOS") 
	DbSetOrder(1)
	DbSeek(xFilial("VOS")+aSer[oLbSer:nAt,10]+aSer[oLbSer:nAt,1])
	DbSelectArea("VJ9") 
	DbSetOrder(1)
	DbSeek(xFilial("VJ9")+aSer[oLbSer:nAt,10]+aSer[oLbSer:nAt,2]+aSer[oLbSer:nAt,7]+aSer[oLbSer:nAt,6])
	DbSelectArea("VO6") 
	DbSetOrder(3)
	DbSeek(xFilial("VO6")+aSer[oLbSer:nAt,10]+aSer[oLbSer:nAt,1]+aSer[oLbSer:nAt,2])
	If FunName() == "OFIOM030"
		if !Empty(aSer[oLbSer:nAt,2])
			aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_GRUSER")] := M->VO4_GRUSER := aSer[oLbSer:nAt,1]
		endif
		aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_CODSER")] := M->VO4_CODSER := aSer[oLbSer:nAt,2]
		aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_DESSER")] := M->VO4_DESSER := aSer[oLbSer:nAt,3]
	ElseIf FunName() == "OFIOM110"
		If type("oGetInc") == "U"
			if !Empty(aSer[oLbSer:nAt,2])
				aCols[oGetSrvcs:oBrowse:nAt,FG_POSVAR("VS4_GRUSER")] := M->VS4_GRUSER := aSer[oLbSer:nAt,1]
			endif
			aCols[oGetSrvcs:oBrowse:nAt,FG_POSVAR("VS4_CODSER")] := M->VS4_CODSER := aSer[oLbSer:nAt,2]
			aCols[oGetSrvcs:oBrowse:nAt,FG_POSVAR("VS4_DESSER")] := M->VS4_DESSER := aSer[oLbSer:nAt,3]
		Else  
			if !Empty(aSer[oLbSer:nAt,2])
				aCols[oGetInc:oBrowse:nAt,FG_POSVAR("VSM_CODGRU")] := M->VSM_CODGRU := aSer[oLbSer:nAt,1]
			endif
			aCols[oGetInc:oBrowse:nAt,FG_POSVAR("VSM_CODSER")] := M->VSM_CODSER := aSer[oLbSer:nAt,2]
			aCols[oGetInc:oBrowse:nAt,FG_POSVAR("VSM_DESSER")] := M->VSM_DESSER := aSer[oLbSer:nAt,3]
		EndIf
	ElseIf FunName() == "OFIOA140"
		aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO8_CODSRV")] := M->VO8_CODSRV := aSer[oLbSer:nAt,2]
		aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO8_DESSRV")] := M->VO8_DESSRV := aSer[oLbSer:nAt,3]
	EndIf
EndIf
Return

Function OFC250_AUT() // Verifica se o Servico precisa de autorizacao da GM //

&& Verifica tempo por aplicacao		
If VO6->VO6_CODMAR == FG_MARCA("CHEVROLET",,.f.)

	If Alltrim(VO6->VO6_AUTORI) == "*"
		MsgAlert(STR0017,STR0016)
	EndIf	

EndIf	

Return(.t.)